unless Rails.env.test?
  Rails.application.config.action_mailer.delivery_method = :smtp
end

Rails.application.config.action_mailer.smtp_settings = {
  address: 'smtp.gmail.com',
  port: 587,
  domain: Rails.application.secrets.gmail_email.split('@').last,
  user_name: Rails.application.secrets.gmail_email,
  password: Rails.application.secrets.gmail_password,
  authentication: 'plain',
  enable_starttls_auto: true
}
