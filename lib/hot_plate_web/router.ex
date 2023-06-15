defmodule HotPlateWeb.Router do
  use HotPlateWeb, :router

  import HotPlateWeb.CompanyAuth

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {HotPlateWeb.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:fetch_current_company)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", HotPlateWeb do
    pipe_through(:browser)

    get("/", PageController, :index)
    live("/customer_page", CustomerPageLive.Index, :index)
    live("/customerrestaurants/:id", CustomerRestaurantLive.Index, :index)
    live("/customerfoods/:id/:food_type_id", CustomerFoodLive.Index, :index)
  end

  scope "/", HotPlateWeb do
    pipe_through([:browser, :require_authenticated_company])
    live("/dashboard", DashboardLive.Index, :index)
    live("/restaurants", RestaurantLive.Index, :index)
    live("/restaurants/new", RestaurantLive.Index, :new)
    live("/restaurants/:id/edit", RestaurantLive.Index, :edit)

    live("/restaurants/:id", RestaurantLive.Show, :show)
    live("/restaurants/:id/show/edit", RestaurantLive.Show, :edit)

    live("/staff_members", StaffMemberLive.Index, :index)
    live("/staff_members/new", StaffMemberLive.Index, :new)
    live("/staff_members/:id/edit", StaffMemberLive.Index, :edit)

    live("/staff_members/:id", StaffMemberLive.Show, :show)
    live("/staff_members/:id/show/edit", StaffMemberLive.Show, :edit)

    live("/foods", FoodLive.Index, :index)
    live("/foods/new", FoodLive.Index, :new)
    live("/foods/:id/edit", FoodLive.Index, :edit)

    live("/foods/:id", FoodLive.Show, :show)
    live("/foods/:id/show/edit", FoodLive.Show, :edit)

    live("/food_types", FoodTypeLive.Index, :index)
    live("/food_types/new", FoodTypeLive.Index, :new)
    live("/food_types/:id/edit", FoodTypeLive.Index, :edit)

    live("/food_types/:id", FoodTypeLive.Show, :show)
    live("/food_types/:id/show/edit", FoodTypeLive.Show, :edit)
  end

  # Other scopes may use custom stacks.
  # scope "/api", HotPlateWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: HotPlateWeb.Telemetry)
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through(:browser)

      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end

  ## Authentication routes

  scope "/", HotPlateWeb do
    pipe_through([:browser, :redirect_if_company_is_authenticated])

    get("/companies/register", CompanyRegistrationController, :new)
    post("/companies/register", CompanyRegistrationController, :create)
    get("/companies/log_in", CompanySessionController, :new)
    post("/companies/log_in", CompanySessionController, :create)
    get("/companies/reset_password", CompanyResetPasswordController, :new)
    post("/companies/reset_password", CompanyResetPasswordController, :create)
    get("/companies/reset_password/:token", CompanyResetPasswordController, :edit)
    put("/companies/reset_password/:token", CompanyResetPasswordController, :update)
  end

  scope "/", HotPlateWeb do
    pipe_through([:browser, :require_authenticated_company])

    get("/companies/settings", CompanySettingsController, :edit)
    put("/companies/settings", CompanySettingsController, :update)
    get("/companies/settings/confirm_email/:token", CompanySettingsController, :confirm_email)
  end

  scope "/", HotPlateWeb do
    pipe_through([:browser])

    delete("/companies/log_out", CompanySessionController, :delete)
    get("/companies/confirm", CompanyConfirmationController, :new)
    post("/companies/confirm", CompanyConfirmationController, :create)
    get("/companies/confirm/:token", CompanyConfirmationController, :edit)
    post("/companies/confirm/:token", CompanyConfirmationController, :update)
  end
end
