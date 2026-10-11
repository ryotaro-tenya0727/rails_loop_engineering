require "test_helper"

class AuthenticationFlowTest < ActionDispatch::IntegrationTest
  setup { Rails.cache.clear }

  test "the root page displays the login form and sign up link" do
    get root_path

    assert_response :success
    assert_select "form[action='#{login_path}'][method='post']"
    assert_select "input[name='login_id'][type='text']"
    assert_select "input[name='password'][type='password']"
    assert_select "a[href='#{sign_up_path}']", text: "新規登録"
  end

  test "a registered user can log in and see only their login ID" do
    password = "secret-password"
    user = User.create!(login_id: "member", password: password)
    other_user = User.create!(login_id: "other-member", password: "other-password")

    post login_path, params: { login_id: user.login_id, password: password }

    assert_redirected_to profile_path
    follow_redirect!
    assert_response :success
    assert_select "p", text: /#{Regexp.escape(user.login_id)}/
    assert_not_includes response.body, password
    assert_select "body", count: 0, text: user.password_digest
    assert_select "body", count: 0, text: other_user.login_id
  end

  test "invalid login redirects to sign up without creating an account" do
    assert_no_difference "User.count" do
      post login_path, params: { login_id: "unknown", password: "wrong-password" }
    end

    assert_redirected_to sign_up_path
    follow_redirect!
    assert_response :success
    assert_select "h1", text: "新規登録"
    assert_select ".flash.alert", text: "ログインできなかったため、新規登録してください。"
  end

  test "a new user can register and see their profile" do
    get sign_up_path

    assert_select "input[name='user[login_id]'][type='text']"
    assert_select "input[name='user[password]'][type='password']"

    assert_difference "User.count", 1 do
      post sign_up_path, params: { user: { login_id: "new-member", password: "new-password" } }
    end

    assert_redirected_to profile_path
    follow_redirect!
    assert_select "p", text: /new-member/
    assert_select "body", count: 0, text: "new-password"
  end

  test "registration with blank fields does not create an account" do
    assert_no_difference "User.count" do
      post sign_up_path, params: { user: { login_id: "", password: "" } }
    end

    assert_response :unprocessable_entity
    assert_select "p", text: "登録できませんでした。"
  end

  test "registration with a duplicate login ID does not create an account" do
    User.create!(login_id: "member", password: "secret-password")

    assert_no_difference "User.count" do
      post sign_up_path, params: { user: { login_id: "member", password: "another-password" } }
    end

    assert_response :unprocessable_entity
    assert_select "p", text: "登録できませんでした。"
  end

  test "a login with a registered ID and incorrect password redirects to sign up" do
    User.create!(login_id: "member", password: "secret-password")

    assert_no_difference "User.count" do
      post login_path, params: { login_id: "member", password: "wrong-password" }
    end

    assert_redirected_to sign_up_path
    follow_redirect!
    assert_response :success
    assert_select "h1", text: "新規登録"
    assert_select ".flash.alert", text: "ログインできなかったため、新規登録してください。"
  end

  test "a login with a blank login ID redirects to sign up" do
    assert_no_difference "User.count" do
      post login_path, params: { login_id: "", password: "secret-password" }
    end

    assert_redirected_to sign_up_path
    follow_redirect!
    assert_select "h1", text: "新規登録"
  end

  test "a login with a blank password redirects to sign up" do
    User.create!(login_id: "member", password: "secret-password")

    assert_no_difference "User.count" do
      post login_path, params: { login_id: "member", password: "" }
    end

    assert_redirected_to sign_up_path
    follow_redirect!
    assert_select "h1", text: "新規登録"
  end

  test "too many login attempts receive the same generic failure response" do
    headers = { "REMOTE_ADDR" => "203.0.113.10" }

    5.times do
      post login_path, params: { login_id: "unknown", password: "wrong-password" }, headers: headers
      assert_redirected_to sign_up_path
    end

    post login_path, params: { login_id: "unknown", password: "wrong-password" }, headers: headers

    assert_redirected_to sign_up_path
    follow_redirect!
    assert_select ".flash.alert", text: "ログインできなかったため、新規登録してください。"
  end

  test "a failed login clears an existing authenticated session" do
    user = User.create!(login_id: "member", password: "secret-password")
    post login_path, params: { login_id: user.login_id, password: "secret-password" }
    assert_redirected_to profile_path

    post login_path, params: { login_id: user.login_id, password: "wrong-password" }
    assert_redirected_to sign_up_path

    get profile_path
    assert_redirected_to root_path
  end

  test "an unauthenticated user is redirected from the profile" do
    get profile_path

    assert_redirected_to root_path
  end
end
