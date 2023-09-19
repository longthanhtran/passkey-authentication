require 'rodauth'
require 'sequel/core'

RodauthMain = Rodauth.lib(render: false, csrf: false, flash: false) do
  enable :webauthn, :webauthn_login, :webauthn_autofill

  db Sequel.sqlite(extensions: :activerecord_connection, keep_reference: false)

  accounts_table :users
  account_password_hash_column :password_digest

  # url_options = Rails.application.config.action_mailer.default_url_options
  # webauthn_origin [url_options[:host], url_options[:port]].compact.join(':')

  hmac_secret Rails.application.secret_key_base
  webauthn_origin 'http://localhost:3000'

  before_webauthn_setup do
    if param('nickname').empty?
      throw_error_reason(:missing_nickname, 422, 'nickname', 'nickname must be present')
    end
  end

  webauthn_key_insert_hash do |webauthn_credential|
    super(webauthn_credential).merge(nickname: param('nickname'))
  end

  webauthn_keys_table :webauthn_credentials
  webauthn_keys_account_id_column :user_id

  webauthn_user_ids_table :webauthn_users
  webauthn_user_ids_account_id_column :user_id
end
