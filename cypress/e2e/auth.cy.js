describe("User sign-up and login", () => {
  const password = "password123";
  const uniqueEmail = () => `user_${Date.now()}@example.com`;

  const fillSignupForm = (email) => {
    cy.visit("/users/sign_up");

    // ✅ Fill ALL required fields based on your form HTML
    cy.get("#user_email").type(email);
    cy.get("#user_address").type("123 Coffee Street");
    cy.get("#user_city").type("Winnipeg");
    cy.get("#user_postal_code").type("R3C1A1");

    // Province select: you can select by visible text OR value
    // Option 1: by text
    cy.get("#user_province_id").select("Manitoba");
    // Option 2: by value "1"
    // cy.get("#user_province_id").select("1");

    cy.get("#user_password").type(password);
    cy.get("#user_password_confirmation").type(password);

    cy.get('input[type="submit"], button[type="submit"]').click();
  };

  it("allows a new user to sign up (happy path)", () => {
    const email = uniqueEmail();

    fillSignupForm(email);

    // You said this exact flash shows after sign-up:
    cy.contains("Welcome! You have signed up successfully.").should("exist");
  });

  it("allows an existing user to log in (happy path)", () => {
    const email = uniqueEmail();

    // 1. Create the user (and sign them in)
    fillSignupForm(email);

    // 2. Clear cookies to simulate logout
    cy.clearCookies();

    // 3. Log in with same credentials
    cy.visit("/users/sign_in");
    cy.get("#user_email").type(email);
    cy.get("#user_password").type(password);
    cy.get('input[type="submit"], button[type="submit"]').click();

    cy.contains("Signed in successfully.").should("exist");
  });

  it("shows an error when logging in with wrong password (unhappy path)", () => {
    const email = uniqueEmail();

    // 1. Create user
    fillSignupForm(email);

    // 2. Log out / clear session
    cy.clearCookies();

    // 3. Try wrong password
    cy.visit("/users/sign_in");
    cy.get("#user_email").type(email);
    cy.get("#user_password").type("totallywrong");
    cy.get('input[type="submit"], button[type="submit"]').click();

    // Devise failure.invalid -> "Invalid Email or password."
    cy.contains(/invalid .* or password/i).should("exist");
    cy.location("pathname").should("include", "/users/sign_in");
  });

  it("shows validation errors when signing up with invalid data (unhappy path)", () => {
    cy.visit("/users/sign_up");

    // submit empty form
    cy.get('input[type="submit"], button[type="submit"]').click();

    // ❌ Should NOT see the success message
    cy.contains("Welcome! You have signed up successfully.").should("not.exist");

    // ❌ Should still be somewhere under /users (not redirected away)
    cy.location("pathname").should("include", "/users");
  });
});
