module Users
  class SalesforceIdSynchronizer
    attr_reader :errors, :sf_users, :users

    def initialize(user_ids)
      @users = User.where(id: user_ids)
      @sf_users = Apiguru::ListUsers.new.call
      @errors = []
    end

    def call
      users.each do |user|
        sf_matched_users = sf_users.select do |u|
          u[:first_name] == user.first_name && u[:last_name] == user.last_name
        end
        next if no_matches?(user, sf_matched_users)
        update(user, sf_matched_users)
      end
      errors.empty? ? true : errors
    end

    private

    def no_matches?(user, sf_matched_users)
      if sf_matched_users.empty?
        errors << UserSyncError.new(user).not_found
        true
      else
        false
      end
    end

    def update(user, sf_matched_users)
      if sf_matched_users.count > 1
        sf_matched_users = sf_matched_users.select { |u| u[:email] == user.email }
        return false if no_matches?(user, sf_matched_users)
      end
      update_user_salesforce_id(user, sf_matched_users.first[:id])
    end

    def update_user_salesforce_id(user, salesforce_id)
      user.update_attributes(salesforce_id: salesforce_id)
    end
  end
end
