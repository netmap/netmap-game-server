# Be sure to restart your server when you modify this file.

Netmap::Application.config.session_store :cookie_store,
    key: '_netmap_session', expire_after: 14.days
