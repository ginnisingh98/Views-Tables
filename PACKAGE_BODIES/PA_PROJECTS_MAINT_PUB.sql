--------------------------------------------------------
--  DDL for Package Body PA_PROJECTS_MAINT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECTS_MAINT_PUB" AS
/* $Header: PARMPRPB.pls 120.4.12010000.4 2008/09/22 07:17:12 kjai ship $ */
G_PKG_NAME              CONSTANT VARCHAR2(30) := 'PA_PROJECTS_MAINT_PUB';

-- API name     : create_project
-- Type         : Public
-- Pre-reqs     : None.
-- Parameters           :
-- p_api_version        IN NUMBER     Optional Default = 1.0
-- p_init_msg_list      IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_commit             IN VARCHAR2   Optional Default = FND_API.G_FALSE
-- p_validate_only      IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_validation_level   IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module     IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_max_msg_count      IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_orig_project_id    IN NUMBER     Required
-- p_project_name       IN VARCHAR2   Required
-- p_project_number     IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_description        IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_project_type       IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_project_status_code IN VARCHAR2  Optional Default = FND_API.G_MISS_CHAR
-- p_project_status_name IN VARCHAR2  Optional Default = FND_API.G_MISS_CHAR
-- p_distribution_rule   IN VARCHAR2  Optional Default = FND_API.G_MISS_CHAR
-- p_public_sector_flag  IN VARCHAR2  Optional Default = FND_API.G_MISS_CHAR
-- p_carrying_out_organization_id IN NUMBER Optional
--                                   Default = FND_API.G_MISS_NUM
-- p_organization_name   IN VARCHAR2  Optional Default = FND_API.G_MISS_CHAR
-- p_start_date          IN DATE      Optional Default = FND_API.G_MISS_DATE
-- p_completion_date     IN DATE      Optional Default = FND_API.G_MISS_DATE
-- p_probability_member_id IN NUMBER  Optional Default = FND_API.G_MISS_NUM
-- p_probability_percentage IN NUMBER  Optional Default = FND_API.G_MISS_NUM
-- p_project_value          IN NUMBER  Optional Default = FND_API.G_MISS_NUM
-- p_expected_approval_date IN DATE    Optional Default = FND_API.G_MISS_DATE
-- p_team_template_id       IN NUMBER  Optional Default = FND_API.G_MISS_NUM
-- p_team_template_name     IN VARCHAR2 Optional Default = FND_API.G_MISS_CHAR
-- p_country_code           IN VARCHAR2 Optional Default = FND_API.G_MISS_CHAR
-- p_country_name           IN VARCHAR2 Optional Default = FND_API.G_MISS_CHAR
-- p_region                 IN VARCHAR2 Optional Default = FND_API.G_MISS_CHAR
-- p_city                   IN VARCHAR2 Optional Default = FND_API.G_MISS_CHAR
-- p_customer_id            IN NUMBER  Optional Default = FND_API.G_MISS_NUM
-- p_customer_name          IN VARCHAR2 Optional Default = FND_API.G_MISS_CHAR
-- p_agreement_currency     IN VARCHAR2 Optional Default = FND_API.G_MISS_CHAR
-- p_agreement_currency_name IN VARCHAR2 Optional Default = FND_API.G_MISS_CHAR
-- p_agreement_amount       IN NUMBER   Optional Default = FND_API.G_MISS_NUM
-- p_agreement_org_id       IN NUMBER   Optional Default = FND_API.G_MISS_NUM
-- p_opp_value_currency_code      IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
-- p_opp_value_currency_name      IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
-- p_bill_to_customer_id          IN NUMBER     := NULL                  ,
-- p_ship_to_customer_id          IN NUMBER     := NULL                  ,
-- p_long_name              IN VARCHAR2 Optional Default = NULL
-- p_project_id             OUT NUMBER Required
-- p_new_project_number     OUT VARCHAR2 Required
-- x_return_status     OUT VARCHAR2   Required
-- x_msg_count         OUT NUMBER     Required
-- x_msg_data          OUT VARCHAR2   Required
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
PROCEDURE CREATE_PROJECT
(
 p_api_version                  IN NUMBER     := 1.0,
 p_init_msg_list                IN VARCHAR2   := FND_API.G_TRUE        ,
 p_commit                       IN VARCHAR2   := FND_API.G_FALSE       ,
 p_validate_only                IN VARCHAR2   := FND_API.G_TRUE    ,
 p_validation_level             IN NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_calling_module               IN VARCHAR2   := 'SELF_SERVICE'        ,
 p_debug_mode                   IN VARCHAR2   := 'N'                   ,
 p_max_msg_count                IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_orig_project_id              IN NUMBER                              ,
 p_project_name                 IN VARCHAR2                            ,
 p_project_number               IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_description                  IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_project_type                 IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_project_status_code          IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_project_status_name          IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_distribution_rule            IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_public_sector_flag           IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_carrying_out_organization_id IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_organization_name            IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_start_date                   IN DATE       := FND_API.G_MISS_DATE   ,
 p_completion_date              IN DATE       := FND_API.G_MISS_DATE   ,
 p_probability_member_id        IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_probability_percentage       IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_project_value                IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_expected_approval_date       IN DATE       := FND_API.G_MISS_DATE   ,
 p_team_template_id             IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_team_template_name           IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_country_code                 IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_country_name                 IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_region                       IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_city                         IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_customer_id                  IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_customer_name                IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_agreement_currency           IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_agreement_currency_name      IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_agreement_amount             IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_agreement_org_id             IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_agreement_org_name           IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_opp_value_currency_code      IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_opp_value_currency_name      IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_priority_code                IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_template_flag                IN VARCHAR2   := 'N',
 p_security_level               IN NUMBER     := FND_API.G_MISS_NUM    ,
/*Customer Account Relationships*/
 p_bill_to_customer_id          IN NUMBER     := NULL                  ,
 p_ship_to_customer_id          IN NUMBER     := NULL                  ,
/*Customer Account Relationships*/
 p_bill_to_customer_name        IN VARCHAR2   := NULL                  ,   /* Bug2977891*/
 p_ship_to_customer_name        IN VARCHAR2   := NULL                  ,   /* Bug2977891*/
-- anlee
-- Project Long Name changes
 p_long_name                    IN VARCHAR2   DEFAULT NULL             ,
-- end of changes
 p_project_id                  OUT NOCOPY NUMBER                              , --File.Sql.39 bug 4440895
 p_new_project_number          OUT NOCOPY VARCHAR2                            , --File.Sql.39 bug 4440895
 x_return_status               OUT NOCOPY VARCHAR2                            , --File.Sql.39 bug 4440895
 x_msg_count                   OUT NOCOPY NUMBER                              , --File.Sql.39 bug 4440895
 x_msg_data                    OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

l_api_name           CONSTANT VARCHAR(30) := 'create_project';
l_api_version        CONSTANT NUMBER      := 1.0;

-- 4363092 TCA changes, replaced RA views with HZ tables
/*
l_customer_id              ra_customers.customer_id%TYPE;
l_bill_to_customer_id      ra_customers.customer_id%TYPE; -- Bug 2977891
l_ship_to_customer_id      ra_customers.customer_id%TYPE; -- Bug 2977891
*/

l_customer_id              hz_cust_accounts.cust_account_id%TYPE;
l_bill_to_customer_id      hz_cust_accounts.cust_account_id%TYPE; -- Bug 2977891
l_ship_to_customer_id      hz_cust_accounts.cust_account_id%TYPE; -- Bug 2977891
-- 4363092 end

l_organization_id          hr_organization_units.organization_id%TYPE;
l_project_status_code      pa_project_statuses.project_status_code%TYPE;
l_project_id               pa_projects.project_id%TYPE;
l_project_type             pa_projects_all.project_type%TYPE;
l_project_number_out       pa_projects.segment1%TYPE;
l_probability_member_id    pa_probability_members.probability_member_id%TYPE;
l_team_template_id         pa_team_templates.team_template_id%TYPE;
l_country_code             pa_locations.country_code%TYPE;
l_return_status            VARCHAR2(1);
l_error_msg_code           VARCHAR2(250);
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(2000);
l_err_code                 VARCHAR2(2000);
l_err_stage                VARCHAR2(2000);
l_err_stack                VARCHAR2(2000);
l_data                     VARCHAR2(2000);
l_msg_index_out            NUMBER;
l_relationship_type        VARCHAR2(30);
l_new_project_number       VARCHAR2(30);
l_agreement_currency       FND_CURRENCIES_VL.CURRENCY_CODE%TYPE;
l_agreement_org_id         pa_organizations_project_v.organization_id%TYPE;
l_opp_value_currency_code  FND_CURRENCIES_VL.CURRENCY_CODE%TYPE;

CURSOR l_project_csr (c_project_id NUMBER)
   Is
   Select project_type
   From   pa_projects_all
   Where  project_id = c_project_id;

BEGIN

-- Standard call to check for call compatibility

   if (p_debug_mode = 'Y') then
       pa_debug.debug('Create_Project PUB : Checking the api version number.');
   end if;

--dbms_output.put_line('Starts here PA_PROJECTS_MAINT_PUB.CREATE_PROJECT  ... ');

   IF p_commit = FND_API.G_TRUE THEN
      SAVEPOINT prm_create_project;
   END IF;

--dbms_output.put_line('Before FND_API.COMPATIBLE_API_CALL  ... ');

   if NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

-- Initialize the message stack if required

   if (p_debug_mode = 'Y') then
       pa_debug.debug('CREATE_PROJECT PUB : Initializing message stack.');
   end if;

   pa_debug.init_err_stack('PA_PROJECTS_MAINT_PUB.CREATE_PROJECT');

   if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
   end if;

--  dbms_output.put_line('After initializing the stack');

   x_return_status := 'S';

--dbms_output.put_line('Before p_carrying_out_organization_id  ... ');

   IF (p_carrying_out_organization_id   is not null             AND
      p_carrying_out_organization_id   <> FND_API.G_MISS_NUM)   OR
      (p_organization_name              is not null             AND
      p_organization_name              <> FND_API.G_MISS_CHAR)
   THEN
        if (p_debug_mode = 'Y') then
          pa_debug.debug('Create_Project PUB : Checking Carrying out organization');
        end if;
       pa_hr_org_utils.Check_OrgName_Or_Id
      ( p_organization_id     => p_carrying_out_organization_id
       ,p_organization_name                => p_organization_name
       ,p_check_id_flag       => 'A'
       ,x_organization_id     => l_organization_id
       ,x_return_status       => l_return_status
       ,x_error_msg_code      => l_error_msg_code);

--dbms_output.put_line('AFTER check org  ... '||l_return_status);

        IF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => l_error_msg_code);

            x_msg_data := l_error_msg_code;
            x_return_status := 'E';
        END IF;

    END IF;

--dbms_output.put_line('Before p_project_status_code  ... ');

   IF (p_project_status_code            is not null             AND
      p_project_status_code            <> FND_API.G_MISS_CHAR  ) OR
      (p_project_status_name            is not null             AND
      p_project_status_name            <> FND_API.G_MISS_CHAR)
   THEN

--dbms_output.put_line('IN p_project_status_code  ... ');

        if (p_debug_mode = 'Y') then
          pa_debug.debug('Create_Project PUB : Checking Project status');
        end if;

       PA_PROJECTS_MAINT_UTILS.CHECK_PROJECT_STATUS_OR_ID
      (p_project_status_code  => p_project_status_code
       ,p_project_status_name => p_project_status_name
       ,p_check_id_flag       => 'A'
       ,x_project_status_code => l_project_status_code
       ,x_return_status       => l_return_status
       ,x_error_msg_code      => l_error_msg_code);
--dbms_output.put_line('AFTER check project status  ... '||l_return_status);
        IF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name    => l_error_msg_code);
            x_msg_data := l_error_msg_code;
           x_return_status := 'E';
        END IF;
    END IF;

--dbms_output.put_line('Before probability member call  ... ');

   OPEN l_project_csr (p_project_id);
   FETCH l_project_csr INTO l_project_type;
   CLOSE l_project_csr;

   l_probability_member_id := p_probability_member_id;

   IF (p_probability_member_id            is not null             AND
      P_probability_member_id            <> FND_API.G_MISS_NUM )  OR
      (p_probability_percentage           is not null             AND
      p_probability_percentage           <> FND_API.G_MISS_NUM)
   THEN
        if (p_debug_mode = 'Y') then
          pa_debug.debug('Create_Project PUB : Checking Probability code');
        end if;
       PA_PROJECTS_MAINT_UTILS.CHECK_PROBABILITY_CODE_OR_ID
       ( p_probability_member_id  => p_probability_member_id
        ,p_probability_percentage => p_probability_percentage
        ,p_project_type           => l_project_type
        ,p_check_id_flag          => 'Y'
        ,x_probability_member_id  => l_probability_member_id
        ,x_return_status          => l_return_status
        ,x_error_msg_code         => l_error_msg_code);

--dbms_output.put_line('AFTER check probablity  ... '||l_return_status);

        IF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name    => l_error_msg_code);
            x_msg_data := l_error_msg_code;
           x_return_status := 'E';
        END IF;
    END IF;

--dbms_output.put_line('Before customer call  ...'||to_char(p_customer_id));

   l_customer_id := p_customer_id; --bug 2783257

   IF (p_customer_id   is not null
       AND p_customer_id <> FND_API.G_MISS_NUM)             OR
      (p_customer_name is not null AND p_customer_name <> FND_API.G_MISS_CHAR)
   THEN
        if (p_debug_mode = 'Y') then
          pa_debug.debug('Create_Project PUB : Checking Customer code');
        end if;
--dbms_output.put_line('Before check customer or customer call  ... ');
      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_CUSTOMER_NAME_OR_ID
       ( p_customer_id     => p_customer_id
        ,p_customer_name   => p_customer_name
        ,p_check_id_flag   => 'A'
        ,x_customer_id     => l_customer_id
        ,x_return_status   => l_return_status
        ,x_error_msg_code  => l_error_msg_code);

--dbms_output.put_line('AFTER check customer or customer call  ... '||l_return_status);
        IF l_return_status <> 'S'
        THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => l_error_msg_code);
            x_msg_data := l_error_msg_code;
            x_return_status := 'E';
        END IF;

    END IF;

/* Bug2977891 Begin*/
   l_bill_to_customer_id := p_bill_to_customer_id;
   IF (p_bill_to_customer_id   is not null
       AND p_bill_to_customer_id <> FND_API.G_MISS_NUM)             OR
      (p_bill_to_customer_name is not null AND p_bill_to_customer_name <> FND_API.G_MISS_CHAR)
   THEN
        if (p_debug_mode = 'Y') then
          pa_debug.debug('Create_Project PUB : Checking Bill Customer');
        end if;

      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_CUSTOMER_NAME_OR_ID
       ( p_customer_id     => p_bill_to_customer_id
        ,p_customer_name   => p_bill_to_customer_name
        ,p_check_id_flag   => 'A'
        ,x_customer_id     => l_bill_to_customer_id
        ,x_return_status   => l_return_status
        ,x_error_msg_code  => l_error_msg_code);

        IF l_return_status <> 'S'
        THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => l_error_msg_code||'_BILL');
            x_msg_data := l_error_msg_code;
            x_return_status := 'E';
        END IF;

    END IF;

   l_ship_to_customer_id := p_ship_to_customer_id;
   IF (p_ship_to_customer_id   is not null
       AND p_ship_to_customer_id <> FND_API.G_MISS_NUM)             OR
      (p_ship_to_customer_name is not null AND p_ship_to_customer_name <> FND_API.G_MISS_CHAR)
   THEN
        if (p_debug_mode = 'Y') then
          pa_debug.debug('Create_Project PUB : Checking Ship Customer');
        end if;

      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_CUSTOMER_NAME_OR_ID
       ( p_customer_id     => p_ship_to_customer_id
        ,p_customer_name   => p_ship_to_customer_name
        ,p_check_id_flag   => 'A'
        ,x_customer_id     => l_ship_to_customer_id
        ,x_return_status   => l_return_status
        ,x_error_msg_code  => l_error_msg_code);

        IF l_return_status <> 'S'
        THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => l_error_msg_code||'_SHIP');
            x_msg_data := l_error_msg_code;
            x_return_status := 'E';
        END IF;

    END IF;
   /* Bug2977891 End*/

--dbms_output.put_line('Before check team template call  ... ');
   if (p_team_template_id is not null AND p_team_template_id <> FND_API.G_MISS_NUM) OR
      (p_team_template_name is not null AND p_team_template_name <> FND_API.G_MISS_CHAR)
   then
      if (p_debug_mode = 'Y') then
         pa_debug.debug('Create_Project PUB : Checking team template ID');
      end if;

      PA_TEAM_TEMPLATES_UTILS.CHECK_TEAM_TEMPLATE_NAME_OR_ID
      ( p_team_template_id    => p_team_template_id
       ,p_team_template_name  => p_team_template_name
       ,p_check_id_flag       => 'A'
       ,x_team_template_id    => l_team_template_id
       ,x_return_status       => l_return_status
       ,x_error_message_code      => l_error_msg_code);

      if l_return_status <> 'S' then
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name       => l_error_msg_code);
         x_msg_data := l_error_msg_code;
         x_return_status := 'E';
      end if;
   end if;

--dbms_output.put_line('Before check country code call  ... ');
   if (p_country_code is not null AND p_country_code <> FND_API.G_MISS_CHAR) OR
      (p_country_name is not null AND p_country_name <> FND_API.G_MISS_CHAR)
   then
      if (p_debug_mode = 'Y') then
         pa_debug.debug('Create_Project PUB : Checking country code');
      end if;

      PA_LOCATION_UTILS.CHECK_COUNTRY_NAME_OR_CODE
      ( p_country_code        => p_country_code
       ,p_country_name        => p_country_name
       ,p_check_id_flag       => 'A'
       ,x_country_code        => l_country_code
       ,x_return_status       => l_return_status
       ,x_error_message_code  => l_error_msg_code);

      if l_return_status <> 'S' then
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name       => l_error_msg_code);
         x_msg_data := l_error_msg_code;
         x_return_status := 'E';
      end if;
   end if;

   --dbms_output.put_line('Before check agreement currency call  ... ');
   if (p_agreement_currency is not null AND p_agreement_currency <> FND_API.G_MISS_CHAR) OR
      (p_agreement_currency_name is not null AND p_agreement_currency_name <> FND_API.G_MISS_CHAR)
   then
      if (p_debug_mode = 'Y') then
         pa_debug.debug('Create_Project PUB : Checking agreement currency');
      end if;

      PA_PROJECTS_MAINT_UTILS.CHECK_CURRENCY_NAME_OR_CODE
      ( p_agreement_currency       => p_agreement_currency
       ,p_agreement_currency_name  => p_agreement_currency_name
       ,p_check_id_flag            => 'Y'
       ,x_agreement_currency       => l_agreement_currency
       ,x_return_status            => l_return_status
       ,x_error_msg_code       => l_error_msg_code);

      if l_return_status <> 'S' then
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name       => l_error_msg_code);
         x_msg_data := l_error_msg_code;
         x_return_status := 'E';
      end if;
   end if;

   if (p_opp_value_currency_code is not null AND p_opp_value_currency_code <> FND_API.G_MISS_CHAR) OR
      (p_opp_value_currency_name is not null AND p_opp_value_currency_name <> FND_API.G_MISS_CHAR
)
   then
      if (p_debug_mode = 'Y') then
         pa_debug.debug('Create_Project PUB : Checking Opportunity Value currency');
      end if;

      PA_PROJECTS_MAINT_UTILS.CHECK_CURRENCY_NAME_OR_CODE
      ( p_agreement_currency       => p_opp_value_currency_code
       ,p_agreement_currency_name  => p_opp_value_currency_name
       ,p_check_id_flag            => 'Y'
       ,x_agreement_currency       => l_opp_value_currency_code
       ,x_return_status            => l_return_status
       ,x_error_msg_code       => l_error_msg_code);

      if l_return_status <> 'S' then
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name       => l_error_msg_code);
         x_msg_data := l_error_msg_code;
         x_return_status := 'E';
      end if;
   end if;


    --dbms_output.put_line('Before check agreement org call  ... ');
   if (p_agreement_org_id is not null AND p_agreement_org_id <> FND_API.G_MISS_NUM) OR
      (p_agreement_org_name is not null AND p_agreement_org_name <> FND_API.G_MISS_CHAR)
   then
      if (p_debug_mode = 'Y') then
         pa_debug.debug('Create_Project PUB : Checking agreement org');
      end if;

      PA_PROJECTS_MAINT_UTILS.CHECK_AGREEMENT_ORG_NAME_OR_ID
      ( p_agreement_org_id         => p_agreement_org_id
       ,p_agreement_org_name       => p_agreement_org_name
       ,p_check_id_flag            => 'Y'
       ,x_agreement_org_id         => l_agreement_org_id
       ,x_return_status            => l_return_status
       ,x_error_msg_code           => l_error_msg_code);

      if l_return_status <> 'S' then
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name       => l_error_msg_code);
         x_msg_data := l_error_msg_code;
         x_return_status := 'E';
      end if;
   end if;


    if (p_debug_mode = 'Y') then
        pa_debug.debug('Create_Project PUB : checking message count');
    end if;

   l_msg_count := FND_MSG_PUB.count_msg;
   If l_msg_count > 0 THEN
     x_msg_count := l_msg_count;
     If l_msg_count = 1 THEN
       pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE ,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count ,
          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out );
        x_msg_data := l_data;
     End if;
      RAISE  FND_API.G_EXC_ERROR;
   End if;

/*
   IF l_msg_count = 1 THEN
       x_msg_count := l_msg_count;
       x_msg_data := FND_MSG_PUB.get(p_msg_index => 1,
                                     p_encoded   => FND_API.G_TRUE);
   ELSE
      x_msg_count  := l_msg_count;
   END IF;
   if l_msg_count > 0 THEN
      x_return_status := 'E';
      RAISE  FND_API.G_EXC_ERROR;
   end if;
*/

--dbms_output.put_line('Starts here PA_PROJECTS_MAINT_PVT.CREATE_PROJECT  ... ');

/* For Bug 2731449 modified p_bill_to_customer_id to l_bill_to_customer_id
and p_ship_to_customer_id to l_ship_to_customer_id */

   if (p_debug_mode = 'Y') then
      pa_debug.debug('Create_Project PUB : Calling private api Create_project');
   end if;

   PA_PROJECTS_MAINT_PVT.CREATE_PROJECT
   (
    p_commit                       => FND_API.G_FALSE,
    p_validate_only                => p_validate_only,
    p_validation_level             => p_validation_level,
    p_calling_module               => p_calling_module,
    p_debug_mode                   => p_debug_mode,
    p_max_msg_count                => p_max_msg_count,
    p_orig_project_id              => p_orig_project_id,
    p_project_name                 => p_project_name,
    p_project_number               => p_project_number,
    p_description                  => p_description,
    p_project_type                 => p_project_type,
    p_project_status_code          => l_project_status_code,
    p_distribution_rule            => p_distribution_rule,
    p_public_sector_flag           => p_public_sector_flag,
    p_carrying_out_organization_id => l_organization_id,
    p_start_date                   => p_start_date,
    p_completion_date              => p_completion_date,
    p_probability_member_id        => p_probability_member_id,
    p_project_value                => p_project_value,
    p_expected_approval_date       => p_expected_approval_date,
    p_team_template_id             => l_team_template_id,
    p_country_code                 => l_country_code,
    p_region                       => p_region,
    p_city                         => p_city,
    p_customer_id                  => l_customer_id,
    p_agreement_currency           => l_agreement_currency,
    p_agreement_amount             => p_agreement_amount,
    p_agreement_org_id             => l_agreement_org_id,
    p_opp_value_currency_code      => l_opp_value_currency_code ,
    p_priority_code                => p_priority_code,
    p_template_flag                => p_template_flag,
    p_security_level               => p_security_level,
--Customer Account Relationship Changes
    p_bill_to_customer_id          => l_bill_to_customer_id,          /* For Bug 2731449 */
    p_ship_to_customer_id          => l_ship_to_customer_id,          /* For Bug 2731449 */
--Customer Account Relationship Changes
-- anlee
-- Project Long Name changes
    p_long_name                    => p_long_name,
-- End of changes
    p_project_id                   => l_project_id,
    p_new_project_number           => l_new_project_number,
    x_return_status                => l_return_status,
    x_msg_count                    => l_msg_count,
    x_msg_data                     => l_msg_data);

    if (p_debug_mode = 'Y') then
        pa_debug.debug('Create_Project PUB : checking message count');
    end if;
--dbms_output.put_line('After PRIVATE API call  ... '||l_return_status);

   l_msg_count := FND_MSG_PUB.count_msg;
   If l_msg_count > 0 THEN
     x_msg_count := l_msg_count;
     If l_msg_count = 1 THEN
       pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE ,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count ,
          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out );
        x_msg_data := l_data;
     End if;
      RAISE  FND_API.G_EXC_ERROR;
   End if;
/*
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count = 1 THEN
       x_msg_data := FND_MSG_PUB.get(p_msg_index => 1,
                                      p_encoded   => FND_API.G_TRUE);
       x_msg_count := l_msg_count;
   ELSE
      x_msg_count  := l_msg_count;
   END IF;

   IF l_msg_count > 0 THEN
      x_return_status := 'E';
      RAISE  FND_API.G_EXC_ERROR;
   END IF;
*/
   p_project_id         := l_project_id;
   p_new_project_number := l_new_project_number;
   x_return_status      := 'S';

--dbms_output.put_line('Created ProjectID in PUBLIC API : '||to_char(l_project_id)||l_new_project_number);

   IF FND_API.TO_BOOLEAN(P_COMMIT)
   THEN
      COMMIT WORK;
   END IF;

EXCEPTION WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO prm_create_project;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECTS_MAINT_PUB',
                            p_procedure_name => 'CREATE_PROJECT',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

WHEN FND_API.G_EXC_ERROR THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO prm_create_project;
    END IF;
    x_return_status := 'E';

WHEN OTHERS THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO prm_create_project;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECTS_MAINT_PUB',
                            p_procedure_name => 'CREATE_PROJECT',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    raise;

END CREATE_PROJECT;

-- API name     : create_customer
-- Type         : Public
-- Pre-reqs     : None.
-- Parameters           :
-- p_api_version        IN NUMBER     Optional Default = 1.0
-- p_init_msg_list      IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_commit             IN VARCHAR2   Optional Default = FND_API.G_FALSE
-- p_validate_only      IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_validation_level   IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module     IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode         IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count      IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_project_id         IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_customer_id        IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_customer_name      IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_relationship_type  IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- x_return_status      OUT VARCHAR2
-- x_msg_count          OUT NUMBER
-- x_msg_data           OUT VARCHAR2
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
PROCEDURE CREATE_CUSTOMER
(
 p_api_version                  IN NUMBER     := 1.0                   ,
 p_init_msg_list                IN VARCHAR2   := FND_API.G_TRUE        ,
 p_commit                       IN VARCHAR2   := FND_API.G_FALSE       ,
 p_validate_only                IN VARCHAR2   := FND_API.G_TRUE        ,
 p_validation_level             IN NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_calling_module               IN VARCHAR2   := 'SELF_SERVICE'        ,
 p_debug_mode                   IN VARCHAR2   := 'N'                   ,
 p_max_msg_count                IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_project_id                   IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_customer_id                  IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_customer_name                IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_relationship_type            IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 x_return_status               OUT NOCOPY VARCHAR2                            , --File.Sql.39 bug 4440895
 x_msg_count                   OUT NOCOPY NUMBER                              , --File.Sql.39 bug 4440895
 x_msg_data                    OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

l_api_name           CONSTANT VARCHAR(30) := 'create_customer';
l_api_version        CONSTANT NUMBER      := 1.0;

-- 4363092 TCA changes, replaced RA views with HZ tables
/*
l_customer_id              ra_customers.customer_id%TYPE;
*/

l_customer_id              hz_cust_accounts.cust_account_id%TYPE;
-- 4363092 end

l_return_status            VARCHAR2(1);
l_error_msg_code           VARCHAR2(250);
l_err_code                 NUMBER;
l_err_stage                VARCHAR2(250);
l_err_stack                VARCHAR2(250);
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(250);
l_msg_index_out            NUMBER;
l_data                     VARCHAR2(250);

BEGIN

--dbms_output.put_line('INSIDE PROCEDURE create_customer call  ... ');

   IF p_commit = FND_API.G_TRUE
   THEN
      SAVEPOINT create_customer;
   END IF;

   pa_debug.init_err_stack('PA_PROJECTS_MAINT_PUB.CREATE_CUSTOMER');

    if (p_debug_mode = 'Y') then
        pa_debug.debug('Create_Customer PUB : checking API compatibility');
    end if;
   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE))
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   x_return_status := 'S';

--dbms_output.put_line('INSIDE PROCEDURE before p_customer_id check call  ... ');

   IF (p_customer_id   is not null            AND
      P_customer_id   <> FND_API.G_MISS_NUM  ) OR
      (p_customer_name is not null             AND
      p_customer_name <> FND_API.G_MISS_CHAR )
   THEN
    if (p_debug_mode = 'Y') then
        pa_debug.debug('Create_Customer PUB : checking Customer code');
    end if;
--dbms_output.put_line('Before check customer or id call  ... ');
      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_CUSTOMER_NAME_OR_ID
       ( p_customer_id     => p_customer_id
        ,p_customer_name   => p_customer_name
        ,p_check_id_flag   => 'A'
        ,x_customer_id     => l_customer_id
        ,x_return_status   => l_return_status
        ,x_error_msg_code  => l_error_msg_code);

        IF l_return_status <> 'S'
        THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => l_error_msg_code);
            x_msg_data := l_error_msg_code;
           x_return_status := 'E';
        END IF;
--    ELSE
 --         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
--                           p_msg_name       => 'PA_PROJ_CUST_ID_NOT_PASSED');
--            x_msg_data := 'PA_PROJ_CUST_ID_NOT_PASSED';
    END IF;

    l_return_status  :=  FND_API.G_MISS_CHAR;
    l_error_msg_code :=  FND_API.G_MISS_CHAR;

    if (p_debug_mode = 'Y') then
        pa_debug.debug('Create_Customer PUB : calling Create_customer private API');
    end if;

    PA_PROJECTS_MAINT_PVT.CREATE_CUSTOMER
    ( p_commit           => FND_API.G_FALSE         ,
      p_validate_only    => p_validate_only          ,
      p_validation_level => p_validation_level      ,
      p_debug_mode       => p_debug_mode            ,
      p_max_msg_count    => p_max_msg_count,
      p_project_id      => p_project_id             ,
      p_customer_id     => l_customer_id            ,
      p_relationship_type  => p_relationship_type,
      x_return_status   => l_return_status          ,
      x_msg_count       => l_msg_count              ,
      x_msg_data        => l_msg_data) ;

   l_msg_count := FND_MSG_PUB.count_msg;
   If l_msg_count > 0 THEN
     x_msg_count := l_msg_count;
     If l_msg_count = 1 THEN
       pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE ,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count ,
          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out );
        x_msg_data := l_data;
     End if;
      RAISE  FND_API.G_EXC_ERROR;
   End if;
/*
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count = 1 THEN
       x_msg_count := l_msg_count;
       x_msg_data := FND_MSG_PUB.get(p_msg_index => 1,
                                      p_encoded   => FND_API.G_TRUE);
   ELSE
      x_msg_count  := l_msg_count;
   END IF;

    if (p_debug_mode = 'Y') then
        pa_debug.debug('Create_Customer PUB : Checking Message Count');
    end if;

   IF l_msg_count > 0 THEN
      x_return_status := 'E';
      RAISE  FND_API.G_EXC_ERROR;
   END IF;
*/
    IF FND_API.TO_BOOLEAN(P_COMMIT)
    THEN
      COMMIT WORK;
    END IF;

--dbms_output.put_line('SUCCESSFULLY CREATED CUSTOMER ... ');

EXCEPTION WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO create_customer;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECTS_MAINT_PUB',
                            p_procedure_name => 'CREATE_CUSTOMER',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

WHEN FND_API.G_EXC_ERROR THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO create_customer;
    END IF;
    x_return_status := 'E';

WHEN OTHERS THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO create_customer;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECTS_MAINT_PUB',
                            p_procedure_name => 'CREATE_CUSTOMER',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    raise;

END CREATE_CUSTOMER;

-- API name     : Update_project_basic_info
-- Type         : Public
-- Pre-reqs     : None.
-- Parameters           :
-- p_api_version        IN NUMBER     Optional Default = 1.0
-- p_init_msg_list      IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_commit             IN VARCHAR2   Optional Default = FND_API.G_FALSE
-- p_validate_only      IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_validation_level   IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module     IN VARCHAR2   Optional Default =  'SELF_SERVICE'
-- p_debug_mode         IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count      IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_project_id         IN NUMBER     Required
-- p_project_name       IN VARCHAR2   Required
-- p_project_number     IN VARCHAR2   Required
-- p_project_type       IN VARCHAR2   Required Default = FND_API.G_MISS_CHAR
-- p_description        IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_project_status_code IN VARCHAR2  Required
-- p_public_sector_flag  IN VARCHAR2  Required
-- p_carrying_out_organization_id IN NUMBER Required Default = FND_API.G_MISS_NUM
-- p_organization_name   IN VARCHAR2  Required Default = FND_API.G_MISS_CHAR
-- p_start_date          IN DATE      Required
-- p_completion_date     IN DATE      Optional Default = FND_API.G_MISS_DATE
-- p_territory_code      IN VARCHAR2  Optional Default = FND_API.G_MISS_CHAR
-- p_country             IN VARCHAR2  Optional Default = FND_API.G_MISS_CHAR
-- p_location_id         IN NUMBER    Optional Default = FND_API.G_MISS_NUM
-- p_state_region        IN VARCHAR2  Optional Default = FND_API.G_MISS_CHAR
-- p_city                IN VARCHAR2  Optional Default = FND_API.G_MISS_CHAR
-- p_attribute_category IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute1         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute2         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute3         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute4         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute5         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute6         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute7         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute8         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute9         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute10        IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_record_version_number IN NUMBER  Required
-- p_recalculate_flag   IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_target_start_date IN DATE       Optional Default = FND_API.G_MISS_DATE
-- p_target_finish_dateIN DATE       Optional Default = FND_API.G_MISS_DATE
-- p_security_level               IN NUMBER     := FND_API.G_MISS_NUM    ,
-- p_long_name          IN VARCHAR2 Optional Default = NULL
-- x_return_status     OUT VARCHAR2   Required
-- x_msg_count         OUT NUMBER     Required
-- x_msg_data          OUT VARCHAR2   Required
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
PROCEDURE UPDATE_PROJECT_BASIC_INFO
(
 p_api_version                  IN NUMBER     := 1.0                   ,
 p_init_msg_list                IN VARCHAR2   := FND_API.G_TRUE        ,
 p_commit                       IN VARCHAR2   := FND_API.G_FALSE       ,
 p_validate_only                IN VARCHAR2   := FND_API.G_TRUE        ,
 p_validation_level             IN NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_calling_module               IN VARCHAR2   := 'SELF_SERVICE'        ,
 p_debug_mode                   IN VARCHAR2   := 'N'                   ,
 p_max_msg_count                IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_project_id                   IN NUMBER                              ,
 p_project_name                 IN VARCHAR2                            ,
 p_project_number               IN VARCHAR2                            ,
 p_project_type                 IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_description                  IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_project_status_code          IN VARCHAR2                            ,
 p_public_sector_flag           IN VARCHAR2                            ,
 p_carrying_out_organization_id IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_organization_name            IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_start_date                   IN DATE                                ,
 p_completion_date              IN DATE       := FND_API.G_MISS_DATE   ,
 p_territory_code               IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_country                      IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_location_id                  IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_state_region                 IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_city                         IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_priority_code                IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute_category           IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute1                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute2                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute3                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute4                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute5                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute6                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute7                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute8                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute9                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute10                  IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_record_version_number        IN NUMBER                              ,
 p_recalculate_flag             IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
-- anlee
-- Date changes
 p_target_start_date           IN DATE       := FND_API.G_MISS_DATE   ,
 p_target_finish_date          IN DATE       := FND_API.G_MISS_DATE   ,
-- End of changes
 p_security_level               IN NUMBER     := FND_API.G_MISS_NUM    ,
-- anlee
-- Project Long Name changes
 p_long_name                    IN VARCHAR2   DEFAULT NULL             ,
-- end of changes
 p_funding_approval_status      IN VARCHAR2   DEFAULT NULL             , -- added for 4055319
 x_return_status                OUT NOCOPY VARCHAR2                           , --File.Sql.39 bug 4440895
 x_msg_count                    OUT NOCOPY NUMBER                             , --File.Sql.39 bug 4440895
 x_msg_data                     OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

l_api_name           CONSTANT VARCHAR(30) := 'update_project_basic_info';
l_api_version        CONSTANT NUMBER      := 1.0;
l_dummy                 VARCHAR2(1)          := 'N';

l_carrying_out_organization_id    NUMBER;
l_msg_index_out                   NUMBER;
l_msg_count                       NUMBER;
l_return_status                   VARCHAR2(1);
l_error_msg_code                  VARCHAR2(250);
l_msg_data                        VARCHAR2(250);
l_err_code                        VARCHAR2(250);
l_err_stage                       VARCHAR2(250);
l_err_stack                       VARCHAR2(250);
l_data                            VARCHAR2(250);

BEGIN

--dbms_output.put_line('Starts here PA_PROJECTS_MAINT_PUB.CREATE_PROJECT  ... ');

   IF p_commit = FND_API.G_TRUE THEN
      SAVEPOINT update_project_basic_info;
   END IF;

   pa_debug.init_err_stack('PA_PROJECTS_MAINT_PUB.update_project_basic_info');

--dbms_output.put_line('Starts here FND_API.COMPATIBLE_API_CALL  ... ');

    if (p_debug_mode = 'Y') then
       pa_debug.debug('Update_project_basic_info PUB : Checking API compatibility');
    end if;

   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Check original project id

--dbms_output.put_line('Check original project id  ... ');

      if (p_project_id is null) then
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name      => 'PA_NO_PROJECT_ID');
         x_msg_data := 'PA_NO_PROJECT_ID';
         x_return_status := 'E';
--dbms_output.put_line('p_project_id is null RETURN STATUS : '||x_return_status);
      end if;

--dbms_output.put_line(' after project null');
-- write program logic from here

--CARRYING_OUT_ORGANIZATION_ID

   IF (p_carrying_out_organization_id   is not null             AND
      p_carrying_out_organization_id   <> FND_API.G_MISS_NUM)   OR
      (p_organization_name              is not null             AND
      p_organization_name              <> FND_API.G_MISS_CHAR)
   THEN
    if (p_debug_mode = 'Y') then
       pa_debug.debug('Update_project_basic_info PUB : Checking Carrying out org');
    end if;
        --dbms_output.put_line(' before check_org name or_id');
        pa_hr_org_utils.Check_OrgName_Or_Id
            (p_organization_id      => p_carrying_out_organization_id
             ,p_organization_name                => p_organization_name
             ,p_check_id_flag       => 'A'
             ,x_organization_id     => l_carrying_out_organization_id
             ,x_return_status       => l_return_status
             ,x_error_msg_code      => l_error_msg_code);
         IF l_return_status = FND_API.G_RET_STS_ERROR
         THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => l_error_msg_code);
              x_msg_data := l_error_msg_code;
              x_return_status := 'E';
         END IF;

   END IF;

      --dbms_output.put_line(' after check_org name or_id');

   l_msg_count := FND_MSG_PUB.count_msg;
   If l_msg_count > 0 THEN
     x_msg_count := l_msg_count;
     If l_msg_count = 1 THEN
       pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE ,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count ,
          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out );
        x_msg_data := l_data;
     End if;
      RAISE  FND_API.G_EXC_ERROR;
   End if;
/*
      l_msg_count := FND_MSG_PUB.count_msg;

      IF l_msg_count = 1 THEN
          x_msg_count := l_msg_count;
          x_msg_data := FND_MSG_PUB.get(p_msg_index => 1,
                                        p_encoded   => FND_API.G_TRUE);
      ELSE
         x_msg_count  := l_msg_count;
      END IF;

      if (p_debug_mode = 'Y') then
       pa_debug.debug('Update_project_basic_info PUB : Checking message count');
      end if;

      IF l_msg_count > 0 THEN
         x_return_status := 'E';
         RAISE  FND_API.G_EXC_ERROR;
      END IF;
*/
--dbms_output.put_line(' location **** '||to_char(p_location_id));
   if (p_debug_mode = 'Y') then
      pa_debug.debug('Update_project_basic_info PUB : Calling private API update_project_basic_info');
   end if;
   PA_PROJECTS_MAINT_PVT.UPDATE_PROJECT_BASIC_INFO
   (
    p_commit                       => FND_API.G_FALSE,
    p_validate_only                => p_validate_only,
    p_validation_level             => p_validation_level,
    p_calling_module               => p_calling_module,  -- added for bug 7204572
    p_debug_mode                   => p_debug_mode,
    p_max_msg_count                => p_max_msg_count,
    p_project_id                   => p_project_id,
    p_project_name                 => p_project_name,
    p_project_number               => p_project_number,
    p_project_type                 => p_project_type,
    p_description                  => p_description,
    p_project_status_code          => p_project_status_code,
    p_public_sector_flag           => p_public_sector_flag,
    p_carrying_out_organization_id => l_carrying_out_organization_id,
    p_start_date                   => p_start_date,
    p_completion_date              => p_completion_date,
    p_territory_code               => p_territory_code,
    p_country                      => p_country,
    p_location_id                  => p_location_id,
    p_state_region                 => p_state_region,
    p_city                         => p_city,
    p_priority_code                => p_priority_code,
    p_attribute_category           => p_attribute_category,
    p_attribute1                   => p_attribute1,
    p_attribute2                   => p_attribute2,
    p_attribute3                   => p_attribute3,
    p_attribute4                   => p_attribute4,
    p_attribute5                   => p_attribute5,
    p_attribute6                   => p_attribute6,
    p_attribute7                   => p_attribute7,
    p_attribute8                   => p_attribute8,
    p_attribute9                   => p_attribute9,
    p_attribute10                  => p_attribute10,
    p_record_version_number        => p_record_version_number,
    p_recalculate_flag             => p_recalculate_flag,
-- anlee
-- Dates changes
    p_target_start_date           => p_target_start_date,
    p_target_finish_date          => p_target_finish_date,
-- End of changes
    p_security_level               => p_security_level,
-- anlee
-- Project Long Name changes
    p_long_name                    => p_long_name,
-- End of changes
    p_funding_approval_status      => p_funding_approval_status, -- 4055319
    x_return_status                => l_return_status,
    x_msg_count                    => l_msg_count,
    x_msg_data                     => l_msg_data);

   if (p_debug_mode = 'Y') then
       pa_debug.debug('Update_project_basic_info PUB : Checking message count');
   end if;
   l_msg_count := FND_MSG_PUB.count_msg;
   If l_msg_count > 0 THEN
     x_msg_count := l_msg_count;
     If l_msg_count = 1 THEN
       pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE ,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count ,
          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out );
        x_msg_data := l_data;
     End if;
      RAISE  FND_API.G_EXC_ERROR;
   End if;
/*
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count = 1 THEN
       x_msg_count := l_msg_count;
       x_msg_data := FND_MSG_PUB.get(p_msg_index => 1,
                                      p_encoded   => FND_API.G_TRUE);
   ELSE
      x_msg_count  := l_msg_count;
   END IF;

   IF l_msg_count > 0 THEN
      x_return_status := 'E';
      RAISE  FND_API.G_EXC_ERROR;
   END IF;
*/
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if p_commit = FND_API.G_TRUE then
      commit work;
   end if;

EXCEPTION WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO update_project_basic_info;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECTS_MAINT_PUB',
                            p_procedure_name => 'UPDATE_PROJECT_BASIC_INFO',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

WHEN FND_API.G_EXC_ERROR THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO update_project_basic_info;
    END IF;
    x_return_status := 'E';

WHEN OTHERS THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO update_project_basic_info;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECTS_MAINT_PUB',
                            p_procedure_name => 'UPDATE_PROJECT_BASIC_INFO',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    raise;

END UPDATE_PROJECT_BASIC_INFO;

-- API name     : Update_project_additional_info
-- Type         : Public
-- Pre-reqs     : None.
-- Parameters           :
-- p_api_version        IN NUMBER     Optional Default = 1.0
-- p_init_msg_list      IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_commit             IN VARCHAR2   Optional Default = FND_API.G_FALSE
-- p_validate_only      IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_validation_level   IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module     IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode         IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count      IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_project_id         IN NUMBER     Required
-- p_calendar_id        IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_calendar_name      IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_work_type_id       IN NUMBER     Required
-- p_role_list_id       IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_cost_job_group_id  IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_bill_job_group_id  IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_record_version_number  IN NUMBER Required
-- p_sys_program_flag  IN varchar2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_allow_multi_prog_rollup IN varchar2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- x_return_status     OUT VARCHAR2   Required
-- x_msg_count         OUT NUMBER     Required
-- x_msg_data          OUT VARCHAR2   Required
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--           01-MAr-2004 --   Rajnish           - Added for FPM-Relationship changes
--
--
PROCEDURE UPDATE_PROJECT_ADDITIONAL_INFO
(p_api_version                  IN NUMBER     := 1.0                   ,
 p_init_msg_list                IN VARCHAR2   := FND_API.G_TRUE        ,
 p_commit                       IN VARCHAR2   := FND_API.G_FALSE       ,
 p_validate_only                IN VARCHAR2     := FND_API.G_TRUE        ,
 p_validation_level             IN NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_calling_module               IN VARCHAR2   := 'SELF_SERVICE'        ,
 p_debug_mode                   IN VARCHAR2   := 'N',
 p_max_msg_count                IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_project_id                   IN NUMBER                              ,
 p_calendar_id                  IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_calendar_name                IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_work_type_id                 IN NUMBER                              ,
 p_role_list_id                 IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_cost_job_group_id            IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_bill_job_group_id            IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_split_cost_from_wokplan_flag IN VARCHAR2  := FND_API.G_MISS_CHAR   ,
 p_split_cost_from_bill_flag     IN VARCHAR2  := FND_API.G_MISS_CHAR   ,
 p_attribute_category           IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute1                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute2                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute3                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute4                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute5                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute6                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute7                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute8                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute9                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute10                  IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_record_version_number        IN NUMBER                              ,
 p_sys_program_flag             IN varchar2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_allow_multi_prog_rollup      IN varchar2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 x_return_status                OUT NOCOPY VARCHAR2                           , --File.Sql.39 bug 4440895
 x_msg_count                    OUT NOCOPY NUMBER                             , --File.Sql.39 bug 4440895
 x_msg_data                     OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

l_api_name           CONSTANT VARCHAR(30) := 'update_project_additional_info';
l_api_version        CONSTANT NUMBER      := 1.0;
l_calendar_id              NUMBER;
l_cost_job_group_id        NUMBER;
l_return_status            VARCHAR2(250);
l_error_msg_code           VARCHAR2(250);
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(250);
l_err_code                 VARCHAR2(250);
l_err_stage                VARCHAR2(250);
l_err_stack                VARCHAR2(250);
l_data                     VARCHAR2(250);
l_msg_index_out            NUMBER;
l_dummy                    VARCHAR2(1);
BEGIN

--dbms_output.put_line('ADDITIONAL INFORMATION .,.. ');

   IF p_commit = FND_API.G_TRUE THEN
      SAVEPOINT update_project_additional_info;
   END IF;

   pa_debug.init_err_stack('PA_PROJECTS_MAINT_PUB.update_project_additional_info');

   if (p_debug_mode = 'Y') then
       pa_debug.debug('Update_project_Additional_info PUB : Checking API Compatibility');
   end if;
   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

--dbms_output.put_line('Before PA_PROJECTS_MAINT_PVT.UPDATE_PROJECT_ADDITIONAL_INFO ');
-- write your program logic from here

   IF (p_calendar_id   is not null             AND
      p_calendar_id   <> FND_API.G_MISS_NUM)   OR
      (p_calendar_name              is not null             AND
      p_calendar_name              <> FND_API.G_MISS_CHAR)
   THEN
        if (p_debug_mode = 'Y') then
          pa_debug.debug('Update_Project_additional_info PUB : Checking calendar');
        end if;
       PA_CALENDAR_UTILS.CHECK_CALENDAR_NAME_OR_ID
      ( p_calendar_id     => p_calendar_id
       ,p_calendar_name                => p_calendar_name
       ,p_check_id_flag       => 'A'
       ,x_calendar_id     => l_calendar_id
       ,x_return_status       => l_return_status
       ,x_error_message_code      => l_error_msg_code);

--dbms_output.put_line('AFTER check org  ... '||l_return_status);

        IF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => l_error_msg_code);
            x_msg_data := l_error_msg_code;
            x_return_status := 'E';
        END IF;

    END IF;

--dbms_output.put_line('Before p_project_status_code  ... ');

   l_cost_job_group_id := p_cost_job_group_id;
   IF l_cost_job_Group_id is null
   THEN
      l_cost_job_Group_id := PA_PROJECTS_MAINT_UTILS.GET_COST_JOB_GROUP_ID;
   END IF;

   l_msg_count := FND_MSG_PUB.count_msg;
   If l_msg_count > 0 THEN
     x_msg_count := l_msg_count;
     If l_msg_count = 1 THEN
       pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE ,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count ,
          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out );
        x_msg_data := l_data;
     End if;
      RAISE  FND_API.G_EXC_ERROR;
   End if;
/*
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count = 1 THEN
       x_msg_count := l_msg_count;
       x_msg_data := FND_MSG_PUB.get(p_msg_index => 1,
                                     p_encoded   => FND_API.G_TRUE);

   ELSE
      x_msg_count  := l_msg_count;
   END IF;

   if l_msg_count > 0 THEN
      x_return_status := 'E';
      RAISE  FND_API.G_EXC_ERROR;
   end if;
*/
   if (p_debug_mode = 'Y') then
       pa_debug.debug('Update_project_Additional_info PUB : Calling private API Update_project_additional_info ');
   end if;

--dbms_output.put_line('Starts here PA_PROJECTS_MAINT_PVT.CREATE_PROJECT  ... ');

   PA_PROJECTS_MAINT_PVT.UPDATE_PROJECT_ADDITIONAL_INFO
   (
    p_commit                       => FND_API.G_FALSE,
    p_validate_only                => p_validate_only,
    p_validation_level             => p_validation_level,
    p_calling_module               => p_calling_module,
    p_debug_mode                   => p_debug_mode,
    p_max_msg_count                => p_max_msg_count,
    p_project_id                   => p_project_id,
    p_calendar_id                  => l_calendar_id,
    p_work_type_id                 => p_work_type_id,
    p_role_list_id                 => p_role_list_id,
    p_cost_job_group_id            => l_cost_job_group_id,
    p_bill_job_group_id            => p_bill_job_group_id,
    p_split_cost_from_wokplan_flag => p_split_cost_from_wokplan_flag,
    p_split_cost_from_bill_flag    => p_split_cost_from_bill_flag,
    p_attribute_category           => p_attribute_category,
    p_attribute1                   => p_attribute1,
    p_attribute2                   => p_attribute2,
    p_attribute3                   => p_attribute3,
    p_attribute4                   => p_attribute4,
    p_attribute5                   => p_attribute5,
    p_attribute6                   => p_attribute6,
    p_attribute7                   => p_attribute7,
    p_attribute8                   => p_attribute8,
    p_attribute9                   => p_attribute9,
    p_attribute10                  => p_attribute10,
    p_record_version_number        => p_record_version_number,
    p_sys_program_flag             => p_sys_program_flag,
    p_allow_multi_prog_rollup      => p_allow_multi_prog_rollup,
    x_return_status                => l_return_status,
    x_msg_count                    => l_msg_count,
    x_msg_data                     => l_msg_data);

   if (p_debug_mode = 'Y') then
      pa_debug.debug('Update_project_Additional_info PUB : Checking message count');
   end if;
   l_msg_count := FND_MSG_PUB.count_msg;
   If l_msg_count > 0 THEN
     x_msg_count := l_msg_count;
     If l_msg_count = 1 THEN
       pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE ,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count ,
          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out );
        x_msg_data := l_data;
     End if;
      RAISE  FND_API.G_EXC_ERROR;
   End if;
/*
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count = 1 THEN
       x_msg_count := l_msg_count;
       x_msg_data := FND_MSG_PUB.get(p_msg_index => 1,
                                     p_encoded   => FND_API.G_TRUE);
   ELSE
      x_msg_count  := l_msg_count;
   END IF;

   IF l_msg_count > 0 THEN
      x_return_status := 'E';
       RAISE  FND_API.G_EXC_ERROR;
   END IF;
*/
   IF FND_API.TO_BOOLEAN(P_COMMIT)
   THEN
       COMMIT WORK;
   END IF;

EXCEPTION WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO update_project_additional_info;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECTS_MAINT_PUB',
                            p_procedure_name => 'UPDATE_PROJECT_ADDITIONAL_INFO',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

WHEN FND_API.G_EXC_ERROR THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO update_project_additional_info;
    END IF;
    x_return_status := 'E';

WHEN OTHERS THEN
--    dbms_output.put_line('additional info'||sqlerrm);
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO update_project_additional_info;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECTS_MAINT_PUB',
                            p_procedure_name => 'UPDATE_PROJECT_ADDITIONAL_INFO',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    raise;

END UPDATE_PROJECT_ADDITIONAL_INFO;

-- API name     : Update_project_pipeline_info
-- Type         : Public
-- Pre-reqs     : None.
-- Parameters           :
-- p_api_version        IN NUMBER     Optional Default = 1.0
-- p_init_msg_list      IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_commit             IN VARCHAR2   Optional Default = FND_API.G_FALSE
-- p_validate_only      IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- validation_level     IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module     IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode         IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count      IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_project_id         IN NUMBER     Required
-- p_probability_member_id  IN NUMBER Optional Default = FND_API.G_MISS_NUM
-- p_probability_percentage IN NUMBER  Optional Default = FND_API.G_MISS_NUM
-- p_project_value          IN NUMBER Optional Default = FND_API.G_MISS_NUM
-- p_opportunity_value  IN NUMBER     Optional Defautl = FND_API.G_MISS_NUM
-- p_opp_value_currency_code IN VARCHAR2 Optional Default = FND_API.G_MISS_CHAR
-- p_expected_approval_date IN DATE   Optional Default = NULL
-- p_record_version_number IN NUMBER  Required
-- x_return_status     OUT VARCHAR2   Required
-- x_msg_count         OUT NUMBER     Required
-- x_msg_data          OUT VARCHAR2   Required
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
PROCEDURE UPDATE_PROJECT_PIPELINE_INFO
(p_api_version                  IN NUMBER     := 1.0                   ,
 p_init_msg_list                IN VARCHAR2   := FND_API.G_TRUE        ,
 p_commit                       IN VARCHAR2   := FND_API.G_FALSE       ,
 p_validate_only                IN VARCHAR2     := FND_API.G_TRUE        ,
 p_validation_level             IN NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_calling_module               IN VARCHAR2   := 'SELF_SERVICE'        ,
 p_debug_mode                   IN VARCHAR2   := 'N',
 p_max_msg_count                IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_project_id                   IN NUMBER                              ,
 p_probability_member_id        IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_probability_percentage       IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_project_value                IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_opportunity_value            IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_opp_value_currency_code      IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_expected_approval_date       IN DATE       := NULL                  ,
 p_record_version_number        IN NUMBER                              ,
 x_return_status                OUT NOCOPY VARCHAR2                           , --File.Sql.39 bug 4440895
 x_msg_count                    OUT NOCOPY NUMBER                             , --File.Sql.39 bug 4440895
 x_msg_data                     OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

l_api_name           CONSTANT VARCHAR(30) := 'update_project_pipeline_info';
l_api_version        CONSTANT NUMBER      := 1.0;

l_return_status            VARCHAR2(250);
l_error_msg_code           VARCHAR2(250);
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(250);
l_err_code                 VARCHAR2(250);
l_err_stage                VARCHAR2(250);
l_err_stack                VARCHAR2(250);
l_data                     VARCHAR2(250);
l_msg_index_out            NUMBER;
l_dummy                    VARCHAR2(1);
l_probability_member_id    pa_probability_members.probability_member_id%TYPE;
l_project_type             pa_projects_all.project_type%TYPE;
l_expected_approval_date   DATE;
l_opportunity_value        NUMBER;
l_opp_value_currency_code  pa_project_opp_attrs.opp_value_currency_code%TYPE;

CURSOR c1
   IS
   Select pr.project_type, pr.probability_member_id, pr.expected_approval_date,
          op.opportunity_value, op.opp_value_currency_code
   From   pa_projects_all pr, pa_project_opp_attrs op
   Where  pr.project_id = op.project_id
   AND    pr.project_id = p_project_id;

v_c1 c1%ROWTYPE;

BEGIN

   IF p_commit = FND_API.G_TRUE THEN
      SAVEPOINT update_project_pipeline_info;
   END IF;

   pa_debug.init_err_stack('PA_PROJECTS_MAINT_PUB.update_project_pipeline_info');

   -- Start: Bug 4469624 - check for p_debug_mode before call to PA_DEBUG.WRITE
   if (p_debug_mode = 'Y') then
   PA_DEBUG.write (x_module      => 'pa.plsql.PA_PROJECTS_MAINT_PUB.update_project_pipeline_info'
                   ,x_msg        => 'Beginning of update_project_pipeline_info'
                   ,x_log_level  => 3);
   end if;
   -- End: Bug 4469624 - check for p_debug_mode before call to PA_DEBUG.WRITE

   if (p_debug_mode = 'Y') then
     pa_debug.debug('Update_project_pipeline_info PUB : Checking API Compatibility');
   end if;
   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN c1;
   FETCH c1 INTO v_c1;
   CLOSE c1;

   -- Assign the local variables with the parameters passed in.
   l_probability_member_id := p_probability_member_id;
   l_opportunity_value := p_opportunity_value;
   l_opp_value_currency_code := p_opp_value_currency_code;
   l_expected_approval_date := p_expected_approval_date;

   -- 2375403: Assign correct value to l_project_type.
   l_project_type := v_c1.project_type;

     IF (p_probability_member_id            is not null             AND
       P_probability_member_id            <> FND_API.G_MISS_NUM )  OR
       (p_probability_percentage           is not null             AND
       p_probability_percentage           <> FND_API.G_MISS_NUM)
     THEN
        if (p_debug_mode = 'Y') then
          pa_debug.debug('Create_Project PUB : Checking Probability code');
        end if;
       PA_PROJECTS_MAINT_UTILS.CHECK_PROBABILITY_CODE_OR_ID
       ( p_probability_member_id  => p_probability_member_id
        ,p_probability_percentage => p_probability_percentage
        ,p_project_type           => l_project_type
        ,p_check_id_flag          => 'A'
        ,x_probability_member_id  => l_probability_member_id
        ,x_return_status          => l_return_status
        ,x_error_msg_code         => l_error_msg_code);

      -- Start: Bug 4469624 - check for p_debug_mode before call to PA_DEBUG.WRITE
      if (p_debug_mode = 'Y') then
      PA_DEBUG.write (x_module      => 'pa.plsql.PA_PROJECTS_MAINT_PUB.update_project_pipeline_info'
                   ,x_msg        => 'AFTER check probablity  ... '||l_return_status
                   ,x_log_level  => 3);
      end if;
      -- End: Bug 4469624 - check for p_debug_mode before call to PA_DEBUG.WRITE

        IF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name    => l_error_msg_code);
            x_msg_data := l_error_msg_code;
           x_return_status := 'E';
        END IF;
    END IF;

    if (p_debug_mode = 'Y') then
     pa_debug.debug('Update_project_pipeline_info PUB : Checking message count');
    end if;
    l_msg_count := FND_MSG_PUB.count_msg;
    If l_msg_count > 0 THEN
     x_msg_count := l_msg_count;
     If l_msg_count = 1 THEN
       pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE ,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count ,
          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out );
        x_msg_data := l_data;
     End if;
      RAISE  FND_API.G_EXC_ERROR;
   End if;

  -- write your program logic from here

   if (p_debug_mode = 'Y') then
     pa_debug.debug('Update_project_pipeline_info PUB : Calling private API update_project_pipeline_info');
   end if;

   -- Start: Bug 4469624 - check for p_debug_mode before call to PA_DEBUG.WRITE
   if (p_debug_mode = 'Y') then
   PA_DEBUG.write (x_module      => 'pa.plsql.PA_PROJECTS_MAINT_PUB.update_project_pipeline_info'
                   ,x_msg        => 'Before calling PA_PROJECTS_MAINT_PVT.UPDATE_PROJECT_PIPELINE_INFO'
                   ,x_log_level  => 3);
   end if;
   -- End: Bug 4469624 - check for p_debug_mode before call to PA_DEBUG.WRITE

   PA_PROJECTS_MAINT_PVT.UPDATE_PROJECT_PIPELINE_INFO (
    p_commit                       => FND_API.G_FALSE,
    p_validate_only                => p_validate_only,
    p_validation_level             => p_validation_level,
    p_calling_module               => p_calling_module,
    p_debug_mode                   => p_debug_mode,
    p_max_msg_count                => p_max_msg_count,
    p_project_id                   => p_project_id,
    p_probability_member_id        => l_probability_member_id,
    p_project_value                => p_project_value,
    p_expected_approval_date       => l_expected_approval_date,
    p_record_version_number        => p_record_version_number,
    x_return_status                => l_return_status,
    x_msg_count                    => l_msg_count,
    x_msg_data                     => l_msg_data);

    -- Start: Bug 4469624 - check for p_debug_mode before call to PA_DEBUG.WRITE
    if (p_debug_mode = 'Y') then
    PA_DEBUG.write (x_module      => 'pa.plsql.PA_PROJECTS_MAINT_PUB.update_project_pipeline_info'
                   ,x_msg        => 'After calling PA_PROJECTS_MAINT_PVT.UPDATE_PROJECT_PIPELINE_INFO'
                   ,x_log_level  => 3);
    end if;
    -- End: Bug 4469624 - check for p_debug_mode before call to PA_DEBUG.WRITE


   -- Call PA_OPPORTUNITY_MGT_PVT.modify_project_attributes to update and convert
   -- opportunity values.
   IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
     PA_OPPORTUNITY_MGT_PVT.modify_project_attributes (
          p_project_id             => p_project_id,
          p_opportunity_value      => l_opportunity_value,
          p_opp_value_currency_code=> l_opp_value_currency_code,
          p_expected_approval_date => l_expected_approval_date,
          p_update_project         => 'Y',
          x_return_status          => l_return_status,
          x_msg_count              => l_msg_count,
          x_msg_data               => l_msg_data);
   END IF;

   if (p_debug_mode = 'Y') then
     pa_debug.debug('Update_project_pipeline_info PUB : Checking message count');
   end if;
   l_msg_count := FND_MSG_PUB.count_msg;
   If l_msg_count > 0 THEN
     x_msg_count := l_msg_count;
     If l_msg_count = 1 THEN
       pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE ,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count ,
          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out );
        x_msg_data := l_data;
     End if;
      RAISE  FND_API.G_EXC_ERROR;
   End if;
/*
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count = 1 THEN
       x_msg_count := l_msg_count;
       x_msg_data := FND_MSG_PUB.get(p_msg_index => 1,
                                     p_encoded   => FND_API.G_TRUE);

   ELSE
      x_msg_count  := l_msg_count;
   END IF;

   IF l_msg_count > 0 THEN
      x_return_status := 'E';
      RAISE  FND_API.G_EXC_ERROR;
   END IF;
*/

   IF FND_API.TO_BOOLEAN(P_COMMIT)
   THEN
      COMMIT WORK;
   END IF;

EXCEPTION WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO update_project_pipeline_info;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECTS_MAINT_PUB',
                            p_procedure_name => 'UPDATE_PROJECT_PIPELINE_INFO',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

WHEN FND_API.G_EXC_ERROR THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO update_project_pipeline_info;
    END IF;
    x_return_status := 'E';

WHEN OTHERS THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO update_project_pipeline_info;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECTS_MAINT_PUB',
                            p_procedure_name => 'UPDATE_PROJECT_PIPELINE_INFO',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    raise;

END UPDATE_PROJECT_PIPELINE_INFO;

-- API name     : Create_classifications
-- Type         : Public
-- Pre-reqs     : None.
-- Parameters           :
-- p_api_version        IN NUMBER     Optional Default = 1.0
-- p_init_msg_list      IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_commit             IN VARCHAR2   Optional Default = FND_API.G_FALSE
-- p_validate_only      IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- validation_level     IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module     IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode         IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count      IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_object_id          IN NUMBER     Required
-- p_object_type        IN VARCHAR2   Required
-- p_class_category     IN VARCHAR2   Required
-- p_class_code         IN VARCHAR2   Required
-- p_code_percentage    IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_attribute_category IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute1         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute2         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute3         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute4         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute5         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute6         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute7         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute8         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute9         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute10        IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute11        IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute12        IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute13        IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute14        IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute15        IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- x_return_status     OUT VARCHAR2   Required
-- x_msg_count         OUT NUMBER     Required
-- x_msg_data          OUT VARCHAR2   Required
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
PROCEDURE CREATE_CLASSIFICATIONS
(p_api_version                  IN NUMBER     := 1.0                   ,
 p_init_msg_list                IN VARCHAR2   := FND_API.G_TRUE        ,
 p_commit                       IN VARCHAR2   := FND_API.G_FALSE       ,
 p_validate_only                IN VARCHAR2   := FND_API.G_TRUE        ,
 p_validation_level             IN NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_calling_module               IN VARCHAR2   := 'SELF_SERVICE'        ,
 p_debug_mode                   IN VARCHAR2   := 'N',
 p_max_msg_count                IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_object_id                    IN NUMBER,
 p_object_type                  IN VARCHAR2,
 p_class_category               IN VARCHAR2                            ,
 p_class_code                   IN VARCHAR2                            ,
 p_code_percentage              IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_attribute_category           IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute1                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute2                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute3                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute4                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute5                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute6                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute7                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute8                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute9                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute10                  IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute11                  IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute12                  IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute13                  IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute14                  IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute15                  IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 x_return_status                OUT NOCOPY VARCHAR2                           , --File.Sql.39 bug 4440895
 x_msg_count                    OUT NOCOPY NUMBER                             , --File.Sql.39 bug 4440895
 x_msg_data                     OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

l_dummy              VARCHAR2(1);
l_created_from_project_id  pa_projects.created_from_project_id%TYPE;
l_api_name           CONSTANT VARCHAR(30) := 'create_classifications';
l_api_version        CONSTANT NUMBER      := 1.0;
l_project_id               pa_projects.project_id%TYPE;
l_row_id                   VARCHAR2(250);
l_return_status            VARCHAR2(250);
l_error_msg_code           VARCHAR2(250);
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(250);
l_err_code                 VARCHAR2(250);
l_err_stage                VARCHAR2(250);
l_err_stack                VARCHAR2(250);
l_data                     VARCHAR2(250);
l_msg_index_out            NUMBER;
BEGIN

   IF p_commit = FND_API.G_TRUE THEN
      SAVEPOINT create_classifications;
   END IF;

   pa_debug.init_err_stack('PA_PROJECTS_MAINT_PUB.create_classifications');

   if (p_debug_mode = 'Y') then
     pa_debug.debug('Create_classifications PUB : Checking API compatibility');
   end if;
   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- write your program logic here

   if (p_debug_mode = 'Y') then
     pa_debug.debug('Create_classifications PUB : Calling Private API Create_classifications');
   end if;

-- Checking Input Parameters

      if (p_debug_mode = 'Y') then
         pa_debug.debug('Create_classifications PUB: Checking Class Cateogory ');
      end if;

      BEGIN

         SELECT 'x' INTO l_dummy
         FROM  pa_class_categories
         WHERE CLASS_CATEGORY         = p_class_category;

      EXCEPTION WHEN NO_DATA_FOUND THEN
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name       => 'PA_AL_INVALID_CLASS_CATG_PROJE');
         x_msg_data := 'PA_AL_INVALID_CLASS_CATG_PROJE';
         x_return_status := 'E' ;
      WHEN OTHERS THEN
         fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECTS_MAINT_PUB',
                                 p_procedure_name => 'CREATE_CLASSIFICATIONS',
                                 p_error_text     => SUBSTRB(SQLERRM,1,240));
         raise;
      END;

      if (p_debug_mode = 'Y') then
         pa_debug.debug('Create_classifications PUB: Checking Class Category / Codes Pair');
      end if;

      -- Validate that the Class category / code pair is valid
      BEGIN

         SELECT 'x' INTO l_dummy
         FROM  pa_class_codes
         WHERE CLASS_CODE         = p_class_code and
               CLASS_CATEGORY     = p_class_category;

      EXCEPTION WHEN NO_DATA_FOUND THEN
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name       => 'PA_CLASS_CATG_CODE_INVALID');
         x_msg_data := 'PA_CLASS_CATG_CODE_INVALID';
         x_return_status := 'E' ;
      WHEN OTHERS THEN
         fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECTS_MAINT_PUB',
                                 p_procedure_name => 'CREATE_CLASSIFICATIONS',
                                 p_error_text     => SUBSTRB(SQLERRM,1,240));
         raise;
      END;

   l_msg_count := FND_MSG_PUB.count_msg;
   If l_msg_count > 0 THEN
     x_msg_count := l_msg_count;
     If l_msg_count = 1 THEN
       pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE ,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count ,
          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out );
        x_msg_data := l_data;
     End if;
      RAISE  FND_API.G_EXC_ERROR;
   End if;

/*
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count = 1 THEN
       x_msg_count := l_msg_count;
       x_msg_data := FND_MSG_PUB.get(p_msg_index => 1,
                                     p_encoded   => FND_API.G_TRUE);

   ELSE
      x_msg_count  := l_msg_count;
   END IF;

   if l_msg_count > 0 THEN
      x_return_status := 'E';
      RAISE  FND_API.G_EXC_ERROR;
   end if;
*/
   PA_PROJECTS_MAINT_PVT.CREATE_CLASSIFICATIONS
   (
    p_commit                       => FND_API.G_FALSE,
    p_validate_only                => p_validate_only,
    p_validation_level             => p_validation_level,
    p_calling_module               => p_calling_module,
    p_debug_mode                   => p_debug_mode,
    p_max_msg_count                => p_max_msg_count,
    p_object_id                    => p_object_id,
    p_object_type                  => p_object_type,
    p_class_category               => p_class_category,
    p_class_code                   => p_class_code,
    p_code_percentage              => p_code_percentage,
    p_attribute_category           => p_attribute_category,
    p_attribute1                   => p_attribute1,
    p_attribute2                   => p_attribute2,
    p_attribute3                   => p_attribute3,
    p_attribute4                   => p_attribute4,
    p_attribute5                   => p_attribute5,
    p_attribute6                   => p_attribute6,
    p_attribute7                   => p_attribute7,
    p_attribute8                   => p_attribute8,
    p_attribute9                   => p_attribute9,
    p_attribute10                  => p_attribute10,
    p_attribute11                  => p_attribute11,
    p_attribute12                  => p_attribute12,
    p_attribute13                  => p_attribute13,
    p_attribute14                  => p_attribute14,
    p_attribute15                  => p_attribute15,
    x_return_status                => l_return_status,
    x_msg_count                    => l_msg_count,
    x_msg_data                     => l_msg_data);

   l_msg_count := FND_MSG_PUB.count_msg;
   If l_msg_count > 0 THEN
     x_msg_count := l_msg_count;
     If l_msg_count = 1 THEN
       pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE ,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count ,
          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out );
        x_msg_data := l_data;
     End if;
      RAISE  FND_API.G_EXC_ERROR;
   End if;
/*
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count = 1 THEN
       x_msg_count := l_msg_count;
       x_msg_data := FND_MSG_PUB.get(p_msg_index => 1,
                                     p_encoded   => FND_API.G_TRUE);
   ELSE
      x_msg_count  := l_msg_count;
   END IF;

--dbms_output.put_line('Before PA_PROJECTS_MAINT_PVT.CREATE_CLASSIFICATIONS '||to_char(l_msg_count));

   if (p_debug_mode = 'Y') then
     pa_debug.debug('Create_classifications PUB : Checking message count');
   end if;

--dbms_output.put_line('Before PA_PROJECTS_MAINT_PVT. '||l_data);

   IF l_msg_count > 0 THEN
      x_return_status := 'E';
      RAISE  FND_API.G_EXC_ERROR;
   END IF;
*/
   IF FND_API.TO_BOOLEAN(P_COMMIT)
   THEN
      COMMIT WORK;
   END IF;

EXCEPTION WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO create_classifications;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECTS_MAINT_PUB',
                            p_procedure_name => 'CREATE_CLASSIFICATIONS',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

WHEN FND_API.G_EXC_ERROR THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO create_classifications;
    END IF;
    x_return_status := 'E';

WHEN OTHERS THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO CREATE_CLASSIFICATIONS;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECTS_MAINT_PUB',
                            p_procedure_name => 'CREATE_CLASSIFICATIONS',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    raise;

END CREATE_CLASSIFICATIONS;


-- API name     : Update_classifications
-- Type         : Public
-- Pre-reqs     : None.
-- Parameters           :
-- p_api_version        IN NUMBER     Optional Default = 1.0
-- p_init_msg_list      IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_commit             IN VARCHAR2   Optional Default = FND_API.G_FALSE
-- p_validate_only      IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- validation_level     IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module     IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode         IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count      IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_object_id          IN NUMBER     Required
-- p_object_type        IN VARCHAR2   Required
-- p_class_category     IN VARCHAR2   Required
-- p_class_code         IN VARCHAR2   Required
-- p_code_percentage    IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_attribute_category IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute1         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute2         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute3         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute4         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute5         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute6         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute7         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute8         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute9         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute10        IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute11        IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute12        IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute13        IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute14        IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute15        IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_rowid              IN VARCHAR2
-- p_record_version_number IN NUMBER
-- x_return_status     OUT VARCHAR2   Required
-- x_msg_count         OUT NUMBER     Required
-- x_msg_data          OUT VARCHAR2   Required
--
--  History
--
--           12-OCT-2001 --     anlee  created
--
--
PROCEDURE UPDATE_CLASSIFICATIONS
(p_api_version                  IN NUMBER     := 1.0                   ,
 p_init_msg_list                IN VARCHAR2   := FND_API.G_TRUE        ,
 p_commit                       IN VARCHAR2   := FND_API.G_FALSE       ,
 p_validate_only                IN VARCHAR2   := FND_API.G_TRUE        ,
 p_validation_level             IN NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_calling_module               IN VARCHAR2   := 'SELF_SERVICE'        ,
 p_debug_mode                   IN VARCHAR2   := 'N',
 p_max_msg_count                IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_object_id                    IN NUMBER,
 p_object_type                  IN VARCHAR2,
 p_class_category               IN VARCHAR2                            ,
 p_class_code                   IN VARCHAR2                            ,
 p_code_percentage              IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_attribute_category           IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute1                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute2                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute3                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute4                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute5                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute6                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute7                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute8                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute9                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute10                  IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute11                  IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute12                  IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute13                  IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute14                  IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute15                  IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_rowid                        IN VARCHAR2                            ,
 p_record_version_number        IN NUMBER                              ,
 x_return_status                OUT NOCOPY VARCHAR2                           , --File.Sql.39 bug 4440895
 x_msg_count                    OUT NOCOPY NUMBER                             , --File.Sql.39 bug 4440895
 x_msg_data                     OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

l_dummy              VARCHAR2(1);
l_created_from_project_id  pa_projects.created_from_project_id%TYPE;
l_api_name           CONSTANT VARCHAR(30) := 'create_classifications';
l_api_version        CONSTANT NUMBER      := 1.0;
l_project_id               pa_projects.project_id%TYPE;
l_row_id                   VARCHAR2(250);
l_return_status            VARCHAR2(250);
l_error_msg_code           VARCHAR2(250);
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(250);
l_err_code                 VARCHAR2(250);
l_err_stage                VARCHAR2(250);
l_err_stack                VARCHAR2(250);
l_data                     VARCHAR2(250);
l_msg_index_out            NUMBER;
BEGIN

   IF p_commit = FND_API.G_TRUE THEN
      SAVEPOINT update_classifications;
   END IF;

   pa_debug.init_err_stack('PA_PROJECTS_MAINT_PUB.update_classifications');

   if (p_debug_mode = 'Y') then
     pa_debug.debug('Update_classifications PUB : Checking API compatibility');
   end if;
   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- write your program logic here

   if (p_debug_mode = 'Y') then
     pa_debug.debug('Update_classifications PUB : Calling Private API Update_classifications');
   end if;

-- Checking Input Parameters

      if (p_debug_mode = 'Y') then
         pa_debug.debug('Update_classifications PUB: Checking Class Cateogory ');
      end if;

      BEGIN

         SELECT 'x' INTO l_dummy
         FROM  pa_class_categories
         WHERE CLASS_CATEGORY         = p_class_category;

      EXCEPTION WHEN NO_DATA_FOUND THEN
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name       => 'PA_AL_INVALID_CLASS_CATG_PROJE');
         x_msg_data := 'PA_AL_INVALID_CLASS_CATG_PROJE';
         x_return_status := 'E' ;
      WHEN OTHERS THEN
         fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECTS_MAINT_PUB',
                                 p_procedure_name => 'UPDATE_CLASSIFICATIONS',
                                 p_error_text     => SUBSTRB(SQLERRM,1,240));
         raise;
      END;

      if (p_debug_mode = 'Y') then
         pa_debug.debug('Update_classifications PUB: Checking Class Category / Codes Pair');
      end if;

      -- Validate that the Class category / code pair is valid
      BEGIN

         SELECT 'x' INTO l_dummy
         FROM  pa_class_codes
         WHERE CLASS_CODE         = p_class_code and
               CLASS_CATEGORY     = p_class_category;

      EXCEPTION WHEN NO_DATA_FOUND THEN
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name       => 'PA_CLASS_CATG_CODE_INVALID');
         x_msg_data := 'PA_CLASS_CATG_CODE_INVALID';
         x_return_status := 'E' ;
      WHEN OTHERS THEN
         fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECTS_MAINT_PUB',
                                 p_procedure_name => 'UPDATE_CLASSIFICATIONS',
                                 p_error_text     => SUBSTRB(SQLERRM,1,240));
         raise;
      END;

   l_msg_count := FND_MSG_PUB.count_msg;
   If l_msg_count > 0 THEN
     x_msg_count := l_msg_count;
     If l_msg_count = 1 THEN
       pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE ,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count ,
          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out );
        x_msg_data := l_data;
     End if;
      RAISE  FND_API.G_EXC_ERROR;
   End if;


   PA_PROJECTS_MAINT_PVT.UPDATE_CLASSIFICATIONS
   (
    p_commit                       => FND_API.G_FALSE,
    p_validate_only                => p_validate_only,
    p_validation_level             => p_validation_level,
    p_calling_module               => p_calling_module,
    p_debug_mode                   => p_debug_mode,
    p_max_msg_count                => p_max_msg_count,
    p_object_id                    => p_object_id,
    p_object_type                  => p_object_type,
    p_class_category               => p_class_category,
    p_class_code                   => p_class_code,
    p_code_percentage              => p_code_percentage,
    p_attribute_category           => p_attribute_category,
    p_attribute1                   => p_attribute1,
    p_attribute2                   => p_attribute2,
    p_attribute3                   => p_attribute3,
    p_attribute4                   => p_attribute4,
    p_attribute5                   => p_attribute5,
    p_attribute6                   => p_attribute6,
    p_attribute7                   => p_attribute7,
    p_attribute8                   => p_attribute8,
    p_attribute9                   => p_attribute9,
    p_attribute10                  => p_attribute10,
    p_attribute11                  => p_attribute11,
    p_attribute12                  => p_attribute12,
    p_attribute13                  => p_attribute13,
    p_attribute14                  => p_attribute14,
    p_attribute15                  => p_attribute15,
    p_rowid                        => p_rowid,
    p_record_version_number        => p_record_version_number,
    x_return_status                => l_return_status,
    x_msg_count                    => l_msg_count,
    x_msg_data                     => l_msg_data);

   l_msg_count := FND_MSG_PUB.count_msg;
   If l_msg_count > 0 THEN
     x_msg_count := l_msg_count;
     If l_msg_count = 1 THEN
       pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE ,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count ,
          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out );
        x_msg_data := l_data;
     End if;
      RAISE  FND_API.G_EXC_ERROR;
   End if;

   IF FND_API.TO_BOOLEAN(P_COMMIT)
   THEN
      COMMIT WORK;
   END IF;

EXCEPTION WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO update_classifications;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECTS_MAINT_PUB',
                            p_procedure_name => 'UPDATE_CLASSIFICATIONS',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

WHEN FND_API.G_EXC_ERROR THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO update_classifications;
    END IF;
    x_return_status := 'E';

WHEN OTHERS THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO UPDATE_CLASSIFICATIONS;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECTS_MAINT_PUB',
                            p_procedure_name => 'UPDATE_CLASSIFICATIONS',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    raise;

END UPDATE_CLASSIFICATIONS;



-- API name     : delete_classifications
-- Type         : Public
-- Pre-reqs     : None.
-- Parameters           :
-- p_api_version        IN NUMBER     Optional Default = 1.0
-- p_init_msg_list      IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_commit             IN VARCHAR2   Optional Default = FND_API.G_FALSE
-- p_validate_only      IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- validation_level     IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module     IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode         IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count      IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_object_id          IN NUMBER     Required
-- p_object_type        IN VARCHAR2   Required
-- p_class_category     IN VARCHAR2   Required
-- p_class_code         IN VARCHAR2   Required
-- p_record_version_number IN NUMBER  Optional Default = FND_API.G_MISS_NUM
-- x_return_status     OUT VARCHAR2   Required
-- x_msg_count         OUT NUMBER     Required
-- x_msg_data          OUT VARCHAR2   Required
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
PROCEDURE DELETE_CLASSIFICATIONS
(p_api_version                  IN NUMBER     := 1.0                   ,
 p_init_msg_list                IN VARCHAR2   := FND_API.G_TRUE        ,
 p_commit                       IN VARCHAR2   := FND_API.G_FALSE       ,
 p_validate_only                IN VARCHAR2   := FND_API.G_TRUE        ,
 p_validation_level             IN NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_calling_module               IN VARCHAR2   := 'SELF_SERVICE'        ,
 p_debug_mode                   IN VARCHAR2   := 'N',
 p_max_msg_count                IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_object_id                    IN NUMBER                              ,
 p_object_type                  IN VARCHAR2                            ,
 p_class_category               IN VARCHAR2                            ,
 p_class_code                   IN VARCHAR2                            ,
 p_record_version_number        IN NUMBER     := FND_API.G_MISS_NUM    ,
 x_return_status                OUT NOCOPY VARCHAR2                           , --File.Sql.39 bug 4440895
 x_msg_count                    OUT NOCOPY NUMBER                             , --File.Sql.39 bug 4440895
 x_msg_data                     OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
l_api_name           CONSTANT VARCHAR(30) := 'delete_classifications';
l_api_version        CONSTANT NUMBER      := 1.0;
l_project_id               pa_projects.project_id%TYPE;
l_dummy                    VARCHAR2(1);
l_delete_flag              VARCHAR2(1) := 'N';
l_return_status            VARCHAR2(250);
l_error_msg_code           VARCHAR2(250);
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(250);
l_err_code                 VARCHAR2(250);
l_err_stage                VARCHAR2(250);
l_err_stack                VARCHAR2(250);
l_data                     VARCHAR2(250);
l_msg_index_out            NUMBER;
l_row_id                   VARCHAR2(250);
BEGIN

-- Please all debug message into this procedure.

   IF p_commit = FND_API.G_TRUE THEN
      SAVEPOINT delete_classifications;
   END IF;

   pa_debug.init_err_stack('PA_PROJECTS_MAINT_PUB.delete_classifications');

   if (p_debug_mode = 'Y') then
     pa_debug.debug('delete_classifications PUB : Checking API Compatibility');
   end if;
   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- write program logic here

   if (p_debug_mode = 'Y') then
     pa_debug.debug('delete_classifications PUB : Calling private API delete_classifcations');
   end if;
   PA_PROJECTS_MAINT_PVT.DELETE_CLASSIFICATIONS
   (
    p_commit                       => FND_API.G_FALSE,
    p_validate_only                => p_validate_only,
    p_validation_level             => p_validation_level,
    p_calling_module               => p_calling_module,
    p_debug_mode                   => p_debug_mode,
    p_max_msg_count                => p_max_msg_count,
    p_object_id                    => p_object_id,
    p_object_type                  => p_object_type,
    p_class_category               => p_class_category,
    p_class_code                   => p_class_code,
    p_record_version_number        => p_record_version_number,
    x_return_status                => l_return_status,
    x_msg_count                    => l_msg_count,
    x_msg_data                     => l_msg_data);

   if (p_debug_mode = 'Y') then
     pa_debug.debug('delete_classifications PUB : Checking message count');
   end if;
   l_msg_count := FND_MSG_PUB.count_msg;
   If l_msg_count > 0 THEN
     x_msg_count := l_msg_count;
     If l_msg_count = 1 THEN
       pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE ,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count ,
          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out );
        x_msg_data := l_data;
     End if;
      RAISE  FND_API.G_EXC_ERROR;
   End if;
/*
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count = 1 THEN
       x_msg_count := l_msg_count;
       x_msg_data := FND_MSG_PUB.get(p_msg_index => 1,
                                     p_encoded   => FND_API.G_TRUE);
   ELSE
      x_msg_count  := l_msg_count;
   END IF;

   IF l_msg_count > 0 THEN
      x_return_status := 'E';
      RAISE  FND_API.G_EXC_ERROR;
   END IF;
*/
   IF FND_API.TO_BOOLEAN(P_COMMIT)
   THEN
      COMMIT WORK;
   END IF;

EXCEPTION WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO delete_classifications;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECTS_MAINT_PUB',
                            p_procedure_name => 'DELETE_CLASSIFICATIONS',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

WHEN FND_API.G_EXC_ERROR THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO delete_classifications;
    END IF;
    x_return_status := 'E';

WHEN OTHERS THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO delete_classifications;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECTS_MAINT_PUB',
                            p_procedure_name => 'DELETE_CLASSIFICATIONS',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    raise;

END DELETE_CLASSIFICATIONS;


-- API name     : Update_project_staffing_info
-- Type         : Public
-- Pre-reqs     : None.
-- Parameters           :
-- p_api_version        IN NUMBER     Optional Default = 1.0
-- p_init_msg_list      IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_commit             IN VARCHAR2   Optional Default = FND_API.G_FALSE
-- p_validate_only      IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_validation_level   IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module     IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode         IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count      IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_project_id         IN NUMBER     Required
-- p_comp_match_weighting        IN    pa_projects_all.competence_match_weighting%TYPE    := FND_API.G_MISS_NUM
-- p_avail_match_weighting       IN    pa_projects_all.availability_match_weighting%TYPE  := FND_API.G_MISS_NUM
-- p_job_level_match_weighting   IN    pa_projects_all.job_level_match_weighting%TYPE     := FND_API.G_MISS_NUM
-- p_search_min_availability     IN    pa_projects_all.search_min_availability%TYPE       := FND_API.G_MISS_NUM
-- p_search_country_code         IN    pa_projects_all.search_country_code%TYPE           := FND_API.G_MISS_CHAR
-- p_search_country_name         IN    fnd_territories_vl.territory_short_name%TYPE              := FND_API.G_MISS_CHAR
-- p_search_exp_org_struct_ver_id IN   pa_projects_all.search_exp_org_struct_ver_id%TYPE  := FND_API.G_MISS_NUM
-- p_search_exp_org_hier_name    IN  per_organization_structures.name%TYPE                     := FND_API.G_MISS_CHAR
-- p_search_exp_start_org_id     IN   pa_projects_all.search_exp_start_org_id%TYPE       := FND_API.G_MISS_NUM
-- p_search_exp_start_org_name   IN   hr_organization_units.name%TYPE                           := FND_API.G_MISS_CHAR
-- p_search_min_candidate_score  IN   pa_projects_all.search_min_candidate_score%TYPE    := FND_API.G_MISS_NUM
-- p_enable_auto_cand_nom_flag    IN  pa_projects_all.enable_auto_cand_nom_flag%TYPE := FND_API.G_MISS_CHAR
-- p_record_version_number IN NUMBER  Required
-- x_return_status     OUT VARCHAR2   Required
-- x_msg_count         OUT NUMBER     Required
-- x_msg_data          OUT VARCHAR2   Required
--
--  History
--
--           28-SEP-2001 --   hyau    - Created.
--
--
PROCEDURE UPDATE_PROJECT_STAFFING_INFO
(p_api_version                  IN NUMBER     := 1.0                   ,
 p_init_msg_list                IN VARCHAR2   := FND_API.G_TRUE        ,
 p_commit                       IN VARCHAR2   := FND_API.G_FALSE       ,
 p_validate_only                IN VARCHAR2   := FND_API.G_TRUE        ,
 p_validation_level             IN NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_calling_module               IN VARCHAR2   := 'SELF_SERVICE'        ,
 p_debug_mode                   IN VARCHAR2   := 'N'                   ,
 p_max_msg_count                IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_project_id                   IN NUMBER                              ,
 p_comp_match_weighting         IN pa_projects_all.COMPETENCE_MATCH_WT%TYPE    := FND_API.G_MISS_NUM,
 p_avail_match_weighting        IN pa_projects_all.availability_match_wt%TYPE  := FND_API.G_MISS_NUM,
 p_job_level_match_weighting    IN pa_projects_all.job_level_match_wt%TYPE     := FND_API.G_MISS_NUM,
 p_search_min_availability      IN pa_projects_all.search_min_availability%TYPE       := FND_API.G_MISS_NUM,
 p_search_country_code          IN pa_projects_all.search_country_code%TYPE           := FND_API.G_MISS_CHAR,
 p_search_country_name          IN fnd_territories_vl.territory_short_name%TYPE       := FND_API.G_MISS_CHAR,
 p_search_exp_org_struct_ver_id IN pa_projects_all.search_org_hier_id%TYPE  := FND_API.G_MISS_NUM,
 p_search_exp_org_hier_name     IN per_organization_structures.name%TYPE              := FND_API.G_MISS_CHAR,
 p_search_exp_start_org_id      IN pa_projects_all.search_starting_org_id%TYPE       := FND_API.G_MISS_NUM,
 p_search_exp_start_org_name    IN hr_organization_units.name%TYPE                    := FND_API.G_MISS_CHAR,
 p_search_min_candidate_score   IN pa_projects_all.min_cand_score_reqd_for_nom%TYPE    := FND_API.G_MISS_NUM,
 p_enable_auto_cand_nom_flag    IN pa_projects_all.enable_automated_search%TYPE     := FND_API.G_MISS_CHAR,
 p_record_version_number        IN NUMBER                              ,
 x_return_status                OUT NOCOPY VARCHAR2                           , --File.Sql.39 bug 4440895
 x_msg_count                    OUT NOCOPY NUMBER                             , --File.Sql.39 bug 4440895
 x_msg_data                     OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS


l_api_name           CONSTANT VARCHAR(30) := 'update_project_staffing_info';
l_api_version        CONSTANT NUMBER      := 1.0;

l_return_status            VARCHAR2(250);
l_error_message_code       fnd_new_messages.message_name%TYPE;
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(250);
l_err_code                 VARCHAR2(250);
l_err_stage                VARCHAR2(250);
l_err_stack                VARCHAR2(250);
l_data                     VARCHAR2(250);
l_msg_index_out            NUMBER;
l_dummy                    VARCHAR2(1);

l_search_exp_org_struct_ver_id pa_projects_all.search_org_hier_id%TYPE;
l_search_country_code pa_projects_all.search_country_code%TYPE;
l_search_exp_start_org_id pa_projects_all.search_starting_org_id%TYPE;

BEGIN

   IF p_commit = FND_API.G_TRUE THEN
      SAVEPOINT update_project_staffing_info;
   END IF;

   pa_debug.init_err_stack('PA_PROJECTS_MAINT_PUB.update_project_staffing_info');

   if (p_debug_mode = 'Y') then
     pa_debug.debug('Update_project_staffing_info PUB : Checking API Compatibility');
   end if;
   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

     --
     -- Validate Candidate Score Match Weightings
     --
     IF (p_comp_match_weighting <> FND_API.G_MISS_NUM AND p_comp_match_weighting IS NOT NULL) OR
        (p_avail_match_weighting <> FND_API.G_MISS_NUM AND p_avail_match_weighting IS NOT NULL) OR
        (p_job_level_match_weighting <> FND_API.G_MISS_NUM AND p_job_level_match_weighting IS NOT NULL) THEN

        IF p_comp_match_weighting < 0 OR
           p_comp_match_weighting > 100 OR
           p_avail_match_weighting < 0 OR
           p_avail_match_weighting > 100 OR
           p_job_level_match_weighting < 0 OR
           p_job_level_match_weighting > 100 THEN

          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_INVALID_MATCH_WEIGHTING');
          x_msg_data :=  'PA_INVALID_MATCH_WEIGHTING';
          x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;

     END IF;

     --
     -- Validate Search Minimum Availiability
     --
     IF p_search_min_availability <> FND_API.G_MISS_NUM AND p_search_min_availability IS NOT NULL THEN

       IF p_search_min_availability < 0 OR
          p_search_min_availability > 100 THEN

          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_MIN_AVAIL_INVALID');
          x_msg_data :=  'PA_MIN_AVAIL_INVALID';
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
     END IF;



     --
     -- Validate Search Min Candidate Score
     --
     IF p_search_min_candidate_score <> FND_API.G_MISS_NUM AND p_search_min_candidate_score IS NOT NULL THEN

       IF p_search_min_candidate_score < 0 OR
          p_search_min_candidate_score > 100 THEN

          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_MIN_CAN_SCORE_INVALID');
          x_msg_data :=  'PA_MIN_CAN_SCORE_INVALID';
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
     END IF;


   l_msg_count := FND_MSG_PUB.count_msg;
   If l_msg_count > 0 THEN
     x_msg_count := l_msg_count;
     If l_msg_count = 1 THEN
       pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE ,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count ,
          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out );
        x_msg_data := l_data;
     End if;
      RAISE  FND_API.G_EXC_ERROR;
   End if;


     --
     -- Validate Search Org_Hierarchy
     --
     IF (p_search_exp_org_struct_ver_id <> FND_API.G_MISS_NUM AND p_search_exp_org_struct_ver_id  IS NOT NULL) OR (p_search_exp_org_hier_name <> FND_API.G_MISS_CHAR AND p_search_exp_org_hier_name IS NOT NULL ) THEN

        PA_HR_ORG_UTILS.Check_OrgHierName_Or_Id (p_org_hierarchy_version_id => p_search_exp_org_struct_ver_id,
                                                 p_org_hierarchy_name => p_search_exp_org_hier_name,
                                                 p_check_id_flag => PA_STARTUP.G_Check_ID_Flag,
                                                 x_org_hierarchy_version_id => l_search_exp_org_struct_ver_id,
                                                 x_return_status => l_return_status,
                                                 x_error_msg_code => l_error_message_code);


       IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
           PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                ,p_msg_name       => l_error_message_code );
          x_msg_data :=  l_error_message_code;
          x_return_status := FND_API.G_RET_STS_ERROR;
       ELSE

            l_return_status := FND_API.G_MISS_CHAR;
            l_error_message_code := FND_API.G_MISS_CHAR;

          -- check if the org hierarchy is of the correct type, i.e EXPENDITURES
          PA_ORG_UTILS.Check_OrgHierarchy_Type(
                p_org_structure_version_id => l_search_exp_org_struct_ver_id,
                p_org_structure_type => 'EXPENDITURES',
                x_return_status => l_return_status,
                x_error_message_code => l_error_message_code);


            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                     ,p_msg_name       => l_error_message_code );

            END IF;

          END IF;
          l_return_status := FND_API.G_MISS_CHAR;
          l_error_message_code := FND_API.G_MISS_CHAR;



     END IF;

     --
     -- Validate Search Start Org
     --
     IF (p_search_exp_start_org_id <> FND_API.G_MISS_NUM AND p_search_exp_start_org_id IS NOT NULL) OR (p_search_exp_start_org_name <> FND_API.G_MISS_CHAR and p_search_exp_start_org_name IS NOT NULL) THEN
        PA_HR_ORG_UTILS.Check_OrgName_Or_Id (p_organization_id => p_search_exp_start_org_id,
                                             p_organization_name => p_search_exp_start_org_name,
                                             p_check_id_flag => PA_STARTUP.G_Check_ID_Flag,
                                             x_organization_id => l_search_exp_start_org_id,
                                             x_return_status => l_return_status,
                                             x_error_msg_code => l_error_message_code);


       IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
           PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                ,p_msg_name       => l_error_message_code );
          x_msg_data :=  l_error_message_code;
          x_return_status := FND_API.G_RET_STS_ERROR;

       ELSE

          l_return_status := FND_API.G_MISS_CHAR;
          l_error_message_code := FND_API.G_MISS_CHAR;

          -- check if the starting org is of the correct type i.e.EXPENDITURES
          PA_ORG_UTILS.Check_Org_Type(
                p_organization_id => l_search_exp_start_org_id,
                p_org_structure_type => 'EXPENDITURES',
                x_return_status => l_return_status,
                x_error_message_code => l_error_message_code);

          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                   ,p_msg_name       => l_error_message_code );
             x_msg_data :=  l_error_message_code;
             x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

       END IF;
       l_return_status := FND_API.G_MISS_CHAR;
       l_error_message_code := FND_API.G_MISS_CHAR;

     END IF;

     --
     -- Validate if Search Start Org is in the Search Org Hierarchy
     --
     IF (p_search_exp_start_org_id <> FND_API.G_MISS_NUM AND p_search_exp_start_org_id IS NOT NULL) OR (p_search_exp_start_org_name <> FND_API.G_MISS_CHAR and p_search_exp_start_org_name IS NOT NULL) THEN
       IF p_search_exp_start_org_id IS NOT NULL AND p_search_exp_org_struct_ver_id IS NOT NULL THEN

          PA_ORG_UTILS.Check_Org_In_OrgHierarchy(
                p_organization_id => l_search_exp_start_org_id,
                p_org_structure_version_id => l_search_exp_org_struct_ver_id,
                p_org_structure_type => 'EXPENDITURES',
                x_return_status => l_return_status,
                x_error_message_code => l_error_message_code);

          IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
            PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                ,p_msg_name       => l_error_message_code );
            x_msg_data :=  l_error_message_code;
            x_return_status := FND_API.G_RET_STS_ERROR;

      END IF;

       END IF;

     END IF;

     --
     -- Validate Search Country
     --
     IF (p_search_country_code <> FND_API.G_MISS_CHAR AND p_search_country_code IS NOT NULL) OR (p_search_country_name <> FND_API.G_MISS_CHAR AND p_search_country_name IS NOT NULL) THEN
       PA_LOCATION_UTILS.Check_Country_Name_Or_Code(p_country_code => p_search_country_code,
                                                    p_country_name => p_search_country_name,
                                                    p_check_id_flag => PA_STARTUP.G_Check_ID_Flag,
                                                    x_country_code => l_search_country_code,
                                                    x_return_status => l_return_status,
                                                    x_error_message_code => l_error_message_code);

        IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
          PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                ,p_msg_name       => l_error_message_code );
            x_msg_data :=  l_error_message_code;
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
     END IF;

   l_msg_count := FND_MSG_PUB.count_msg;
   If l_msg_count > 0 THEN
     x_msg_count := l_msg_count;
     If l_msg_count = 1 THEN
       pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE ,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count ,
          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out );
        x_msg_data := l_data;
     End if;
      RAISE  FND_API.G_EXC_ERROR;
   End if;


   if (p_debug_mode = 'Y') then
     pa_debug.debug('update_project_staffing_info PUB : Calling private API update_project_staffing_info');
   end if;


   PA_PROJECTS_MAINT_PVT.UPDATE_PROJECT_STAFFING_INFO
   (
    p_commit                       => FND_API.G_FALSE,
    p_validate_only                => p_validate_only,
    p_validation_level             => p_validation_level,
    p_calling_module               => p_calling_module,
    p_debug_mode                   => p_debug_mode,
    p_max_msg_count                => p_max_msg_count,
    p_project_id                   => p_project_id,
    p_comp_match_weighting         => p_comp_match_weighting,
    p_avail_match_weighting        => p_avail_match_weighting,
    p_job_level_match_weighting    => p_job_level_match_weighting,
    p_search_min_availability      => p_search_min_availability,
    p_search_country_code          => l_search_country_code,
    p_search_exp_org_struct_ver_id => l_search_exp_org_struct_ver_id,
    p_search_exp_start_org_id      => l_search_exp_start_org_id,
    p_search_min_candidate_score   => p_search_min_candidate_score,
    p_enable_auto_cand_nom_flag    => p_enable_auto_cand_nom_flag,
    p_record_version_number        => p_record_version_number,
    x_return_status                => l_return_status,
    x_msg_count                    => l_msg_count,
    x_msg_data                     => l_msg_data);

   if (p_debug_mode = 'Y') then
     pa_debug.debug('update_project_staffing_info PUB : Checking message count');
   end if;
   l_msg_count := FND_MSG_PUB.count_msg;
   If l_msg_count > 0 THEN
     x_msg_count := l_msg_count;
     If l_msg_count = 1 THEN
       pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE ,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count ,
          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out );
        x_msg_data := l_data;
     End if;
      RAISE  FND_API.G_EXC_ERROR;
   End if;

   IF FND_API.TO_BOOLEAN(P_COMMIT)
   THEN
      COMMIT WORK;
   END IF;

EXCEPTION WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO update_project_staffing_info;
    END IF;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECTS_MAINT_PUB',
                            p_procedure_name => 'UPDATE_PROJECT_STAFFING_INFO',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

WHEN FND_API.G_EXC_ERROR THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO update_project_staffing_info;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;

WHEN OTHERS THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO update_project_staffing_info;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECTS_MAINT_PUB',
                            p_procedure_name => 'UPDATE_PROJECT_STAFFING_INFO',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    raise;


END UPDATE_PROJECT_STAFFING_INFO;


-- API name     : Create_Org_Role
-- Type         : Public
-- Pre-reqs     : None.
-- Parameters           :
-- p_api_version                   IN NUMBER     Required Default = 1.0
-- p_init_msg_list                 IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_commit                        IN VARCHAR2   Required Default = FND_API.G_FALSE
-- p_validate_only                 IN VARCHAR2   Required Default = FND_API.G_TRUE
-- p_validation_level              IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module                IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode                    IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count                 IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_object_id                     IN NUMBER     Required
-- p_object_type                   IN VARCHAR2   Required
-- p_project_role_type             IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_project_role_id               IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_resource_type_id              IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_resource_source_id            IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_resource_name                 IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_start_date_active             IN DATE       Required
-- p_scheduled_flag                IN VARCHAR2   Optional Default = 'N'
-- p_project_id                    IN NUMBER     Required
-- p_project_end_date              IN DATE       Optional Default = FND_API.G_MISS_DATE
-- p_end_date_active               IN OUT DATE   Required
-- x_return_status                 OUT VARCHAR2  Required
-- x_msg_count                     OUT NUMBER    Required
-- x_msg_data                      OUT VARCHAR2  Required

PROCEDURE CREATE_ORG_ROLE
( p_api_version                  IN NUMBER     := 1.0
 ,p_init_msg_list                IN VARCHAR2   := FND_API.G_TRUE
 ,p_commit                       IN VARCHAR2   := FND_API.G_FALSE
 ,p_validate_only                IN VARCHAR2   := FND_API.G_TRUE
 ,p_validation_level             IN NUMBER     := FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module               IN VARCHAR2   := 'SELF_SERVICE'
 ,p_debug_mode                   IN VARCHAR2   := 'N'
 ,p_max_msg_count                IN NUMBER     := FND_API.G_MISS_NUM
 ,p_object_id                    IN NUMBER
 ,p_object_type                  IN VARCHAR2
 ,p_project_role_type            IN VARCHAR2   := FND_API.G_MISS_CHAR
 ,p_project_role_id              IN NUMBER     := FND_API.G_MISS_NUM
 ,p_resource_type_id             IN NUMBER     := FND_API.G_MISS_NUM
 ,p_resource_source_id           IN NUMBER     := FND_API.G_MISS_NUM
 ,p_resource_name                IN VARCHAR2   := FND_API.G_MISS_CHAR
 ,p_start_date_active            IN DATE
 ,p_scheduled_flag               IN VARCHAR2   := 'N'
 ,p_project_id                   IN NUMBER
 ,p_project_end_date             IN DATE       := FND_API.G_MISS_DATE
 ,p_end_date_active              IN OUT NOCOPY DATE --File.Sql.39 bug 4440895
 ,x_return_status                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
   l_api_name                      CONSTANT VARCHAR(30) := 'Create_Org_Role';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_customer_id                   NUMBER;
   l_record_version_number         NUMBER;
   l_project_party_id              NUMBER;
   l_start_date_active             DATE;
   l_resource_source_id            NUMBER;
   l_resource_type_id              NUMBER;
   l_new_project_party_id          NUMBER;
   l_resource_id                   NUMBER;
   l_wf_type                       VARCHAR2(2000);
   l_wf_item_type                  VARCHAR2(2000);
   l_wf_process                    VARCHAR2(2000);
   l_assignment_id                 NUMBER;
   l_return_status                 VARCHAR2(1);
   l_error_message_code            VARCHAR2(250);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;
   l_role_class                    VARCHAR2(30);
   l_project_role_id               NUMBER;

   CURSOR l_check_existing_customers_csr(c_party_id NUMBER)
   IS
   SELECT ppc.customer_id, ppp.record_version_number, ppc.project_party_id
   FROM PA_PROJECT_CUSTOMERS ppc,
        PA_PROJECT_PARTIES ppp
   WHERE ppc.project_id = p_project_id
   AND ppc.project_party_id = ppp.project_party_id
   AND ppp.resource_source_id = c_party_id
   AND ppp.resource_type_id = 112;

   CURSOR l_get_role_class_csr(c_project_role_id NUMBER)
   IS
   SELECT role_party_class
   FROM pa_project_role_types_b /* Bug#2788814-Changed pa_project_role_types_vl to pa_project_role_types_b */
   WHERE project_role_id = c_project_role_id;

BEGIN
   pa_debug.init_err_stack('PA_PROJECTS_MAINT_PUB.Create_Org_Role');

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_PROJECTS_MAINT_PUB.Create_Org_Role BEGIN');
   end if;

   if p_commit = FND_API.G_TRUE then
      savepoint create_org_role;
   end if;

   if not FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) then
      FND_MSG_PUB.initialize;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('Check if the role to be created is in CUSTOMER role class...');
   end if;

   l_role_class := NULL;

   if p_project_role_id is null or p_project_role_id = FND_API.G_MISS_NUM then
      l_project_role_id := pa_project_parties_utils.get_project_role_id(p_project_role_type,p_calling_module);
   else
      l_project_role_id := p_project_role_id;
   end if;

   OPEN l_get_role_class_csr(l_project_role_id);
   FETCH l_get_role_class_csr INTO l_role_class;
   CLOSE l_get_role_class_csr;

   if l_role_class = 'CUSTOMER' then

      if (p_debug_mode = 'Y') then
         pa_debug.debug('Name to ID conversion for the party...');
      end if;

      if p_start_date_active is null or p_start_date_active = FND_API.G_MISS_DATE then
         l_start_date_active := trunc(sysdate);
      else
         l_start_date_active := p_start_date_active;
      end if;

      PA_RESOURCE_UTILS.Check_ResourceName_Or_Id ( p_resource_id        => p_resource_source_id
                                                  ,p_resource_type_id   => p_resource_type_id
                                                  ,p_resource_name      => p_resource_name
                                                  ,p_check_id_flag      => PA_STARTUP.G_Check_ID_Flag
                                                  ,p_date               => l_start_date_active
                                                  ,x_resource_id        => l_resource_source_id
                                                  ,x_resource_type_id   => l_resource_type_id
                                                  ,x_return_status      => l_return_status
                                                  ,x_error_message_code => l_error_message_code);

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         fnd_message.set_name('PA',l_error_message_code);
         fnd_msg_pub.add;
      end if;

      l_msg_count := FND_MSG_PUB.count_msg;
      if l_msg_count > 0 then
         x_msg_count := l_msg_count;
         if x_msg_count = 1 then
            pa_interface_utils_pub.get_messages
            (p_encoded        => FND_API.G_TRUE,
             p_msg_index      => 1,
             p_msg_count      => l_msg_count,
             p_msg_data       => l_msg_data,
             p_data           => l_data,
             p_msg_index_out  => l_msg_index_out);
             x_msg_data := l_data;
         end if;
         raise FND_API.G_EXC_ERROR;
      end if;

      if (p_debug_mode = 'Y') then
         pa_debug.debug('Check if there is an existing customer for this org...');
      end if;

      l_customer_id := null;
      OPEN l_check_existing_customers_csr(l_resource_source_id);
      FETCH l_check_existing_customers_csr INTO l_customer_id, l_record_version_number, l_project_party_id;
      CLOSE l_check_existing_customers_csr;

      if l_customer_id is not null then

         if (NOT FND_API.TO_BOOLEAN (p_validate_only)) then
            -- Update the project_party_id col in pa_project_customers to null
            UPDATE pa_project_customers
            SET project_party_id = null
            WHERE project_id = p_project_id
            AND customer_id = l_customer_id;
         end if;

         -- Delete the existing role
         PA_PROJECT_PARTIES_PUB.DELETE_PROJECT_PARTY
         ( p_init_msg_list          => p_init_msg_list
          ,p_validate_only          => p_validate_only
          ,p_validation_level       => p_validation_level
          ,p_debug_mode             => p_debug_mode
          ,p_calling_module         => p_calling_module
          ,p_record_version_number  => l_record_version_number
          ,p_project_id             => p_project_id
          ,p_project_party_id       => l_project_party_id
          ,x_return_status          => l_return_status
          ,x_msg_count              => l_msg_count
          ,x_msg_data               => l_msg_data );

         if l_return_status <> FND_API.G_RET_STS_SUCCESS then
            x_msg_count := FND_MSG_PUB.count_msg;
            if x_msg_count = 1 then
               pa_interface_utils_pub.get_messages
               (p_encoded        => FND_API.G_TRUE,
                p_msg_index      => 1,
                p_msg_count      => l_msg_count,
                p_msg_data       => l_msg_data,
                p_data           => l_data,
                p_msg_index_out  => l_msg_index_out);
               x_msg_data := l_data;
            end if;
            raise FND_API.G_EXC_ERROR;
         end if;

      end if;
   end if;

   -- Now create the org role
   PA_PROJECT_PARTIES_PUB.CREATE_PROJECT_PARTY
   ( p_validate_only          => p_validate_only
    ,p_init_msg_list          => p_init_msg_list
    ,p_validation_level       => p_validation_level
    ,p_debug_mode             => p_debug_mode
    ,p_calling_module         => p_calling_module
    ,p_object_id              => p_object_id
    ,p_object_type            => p_object_type
    ,p_project_role_type      => p_project_role_type
    ,p_project_role_id        => p_project_role_id
    ,p_resource_type_id       => p_resource_type_id
    ,p_resource_source_id     => p_resource_source_id
    ,p_resource_name          => p_resource_name
    ,p_start_date_active      => p_start_date_active
    ,p_scheduled_flag         => p_scheduled_flag
    ,p_project_id             => p_project_id
    ,p_project_end_date       => p_project_end_date
    ,p_end_date_active        => p_end_date_active
    ,x_project_party_id       => l_new_project_party_id
    ,x_resource_id            => l_resource_id
    ,x_wf_type                => l_wf_type
    ,x_wf_item_type           => l_wf_item_type
    ,x_wf_process             => l_wf_process
    ,x_assignment_id          => l_assignment_id
    ,x_return_status          => l_return_status
    ,x_msg_count              => l_msg_count
    ,x_msg_data               => l_msg_data );

   if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      x_msg_count := FND_MSG_PUB.count_msg;
      if x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count,
          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      end if;
      raise FND_API.G_EXC_ERROR;
   end if;

   -- Now update the customer record with the new project_party_id
   if l_role_class = 'CUSTOMER' then
      if l_customer_id is not null then
         if (NOT FND_API.TO_BOOLEAN (p_validate_only)) then
             -- Update the project_party_id col in pa_project_customers to null
            UPDATE pa_project_customers
            SET project_party_id = l_new_project_party_id
            WHERE project_id = p_project_id
            AND customer_id = l_customer_id;
         end if;
      end if;
   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if p_commit = FND_API.G_TRUE then
      commit work;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_PROJECTS_MAINT_PUB.Create_Org_Role END');
   end if;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to create_org_role;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to create_org_role;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECTS_MAINT_PUB',
                              p_procedure_name => 'Create_Org_Role',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
   when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to create_org_role;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECTS_MAINT_PUB',
                              p_procedure_name => 'Create_Org_Role',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END CREATE_ORG_ROLE;

-- Procedure            : project_status_change
-- Type                 : PUBLIC
-- Purpose              : This a wrapper API for calling handle_project_status_change and is used from the
--                        Project Change Status Page in self-service
-- Note                 :
-- Parameters                    Type      Required  Description and Purpose
-- ---------------------------  ------     --------  --------------------------------------------------------
-- p_project_id                 NUMBER        Y      The project id
-- p_new_status_code            VARCHAR2      Y      The new project status
-- p_comment                    VARCAHR2      N      Comment enterd while changing project status
PROCEDURE project_status_change ( p_init_msg_list    IN VARCHAR2 := FND_API.G_TRUE
                                 ,p_commit           IN VARCHAR2 := FND_API.G_FALSE
                                 ,p_validate_only    IN VARCHAR2 := FND_API.G_TRUE
                                 ,p_validation_level IN NUMBER   := FND_API.G_VALID_LEVEL_FULL
                                 ,p_debug_mode       IN VARCHAR2 := 'N'
                                 ,p_calling_module   IN VARCHAR2 :=  'SELF_SERVICE'
                                 ,p_project_id       IN NUMBER
                                 ,p_new_status_code  IN VARCHAR2
                                 ,p_comment          IN VARCHAR2
                                 ,x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                 ,x_msg_count     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                 ,x_msg_data      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                ) IS
     CURSOR cur_get_project_details IS
     SELECT project_status_code
           ,project_type
           ,start_date
           ,closed_date
           ,public_sector_flag
           ,attribute_category
           ,attribute1
           ,attribute2
           ,attribute3
           ,attribute4
           ,attribute5
           ,attribute6
           ,attribute7
           ,attribute8
           ,attribute9
           ,attribute10
           ,pm_product_code
           ,segment1        --  3671408 added column to retrieve project number value
     FROM pa_projects_all
     WHERE project_id = p_project_id;

     CURSOR cur_get_project_status_code( c_project_id IN NUMBER ) IS
     SELECT project_status_code
     FROM   pa_projects_all
     WHERE  project_id = c_project_id;

     CURSOR cur_get_system_status(c_status_code IN VARCHAR2) IS
     SELECT pps.project_system_status_code
     FROM   pa_project_statuses pps
     WHERE  pps.project_status_code = nvl(c_status_code,' ');

     Invalid_Arg_Exc          EXCEPTION;
     l_rec_project_details    cur_get_project_details%ROWTYPE;

     l_old_project_status VARCHAR2(30);
     l_old_sys_status     VARCHAR2(30);
     l_verify_ok_flag     VARCHAR2(1);
     l_warnings_only_flag VARCHAR2(1);
     l_wf_enabled_flag    VARCHAR2(1);
     l_err_stage          VARCHAR2(2000);
     l_err_stack          VARCHAR2(2000);
     l_err_code           VARCHAR2(250);
     l_wf_status_code     VARCHAR2(30);

     -- Declared for 4364878
     l_new_sys_status        VARCHAR2(30);

     l_debug_mode         VARCHAR2(1);
     l_msg_count          NUMBER;
     l_msg_data           VARCHAR2(2000);
     l_data               VARCHAR2(2000);
     l_msg_index_out      NUMBER;
	 l_calling_module   VARCHAR2(50);                                -- for BUG# 6661144
 	 l_abort_flag       VARCHAR2(1) :='N';                        -- for BUG# 6661144

     l_debug_level2                   CONSTANT NUMBER := 2;
     l_debug_level3                   CONSTANT NUMBER := 3;
     l_debug_level4                   CONSTANT NUMBER := 4;
     l_debug_level5                   CONSTANT NUMBER := 5;
BEGIN

     x_msg_count     := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode    := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF (p_commit = FND_API.G_TRUE) THEN
        SAVEPOINT project_status_change;
     END IF;

     IF p_init_msg_list = FND_API.G_TRUE THEN
          FND_MSG_PUB.initialize;
     END IF;

     IF l_debug_mode = 'Y' THEN
        PA_DEBUG.set_curr_function( p_function   => 'project_status_change',
                                    p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y' THEN
        Pa_Debug.g_err_stage:= 'Printing Input parameters';
        Pa_Debug.WRITE(G_PKG_NAME,Pa_Debug.g_err_stage,
                                   l_debug_level3);

        Pa_Debug.WRITE(G_PKG_NAME,'p_project_id'||':'||p_project_id,
                                   l_debug_level3);

        Pa_Debug.WRITE(G_PKG_NAME,'p_new_status_code'||':'||p_new_status_code,
                                   l_debug_level3);
     END IF;

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Validating Input parameters';
          Pa_Debug.WRITE(G_PKG_NAME,Pa_Debug.g_err_stage,
                                     l_debug_level3);
     END IF;

     IF ( ( p_project_id       IS NULL OR p_project_id         = FND_API.G_MISS_NUM  ) AND
          ( p_new_status_code  IS NULL OR p_new_status_code    = FND_API.G_MISS_CHAR )
        )
     THEN
           IF l_debug_mode = 'Y' THEN
               Pa_Debug.g_err_stage:= 'PA_PROJECTS_MAINT_PUB : project_status_change :
                                      p_project_id, p_new_status_code are NULL';
               Pa_Debug.WRITE(G_PKG_NAME,Pa_Debug.g_err_stage,
                                     l_debug_level3);
           END IF;
          RAISE Invalid_Arg_Exc;
     END IF;

	      l_calling_module := p_calling_module;
 	      IF (p_calling_module = 'SSO_ABORT') THEN                   -- for BUG# 6661144
 	        l_calling_module := 'SELF_SERVICE';
 	        l_abort_flag := 'Y';
 	      END IF;

     IF ( (p_project_id      IS NOT NULL AND p_project_id      <> FND_API.G_MISS_NUM  ) AND
          (p_new_status_code IS NOT NULL AND p_new_status_code <> FND_API.G_MISS_CHAR )
        ) THEN

          --Fetch the (old) project status before changing it
          OPEN  cur_get_project_status_code(p_project_id);
          FETCH cur_get_project_status_code INTO l_old_project_status;
          CLOSE cur_get_project_status_code;

          --Fetch the (old) project system status before changing it
          OPEN  cur_get_system_status(l_old_project_status);
          FETCH cur_get_system_status INTO l_old_sys_status;
          CLOSE cur_get_system_status;

          OPEN  cur_get_project_details;
          FETCH cur_get_project_details INTO l_rec_project_details;
          CLOSE cur_get_project_details;

          /* <**A**> Start Bug 4364878 */
                OPEN  cur_get_system_status(p_new_status_code);
                FETCH cur_get_system_status INTO l_new_sys_status;
                CLOSE cur_get_system_status;
          /* <**A**> End  Bug 4364878 */

-- Bug 4565023: Begin
          IF (l_debug_mode = 'Y') THEN
               Pa_Debug.WRITE(G_PKG_NAME,'Calling ALLOW_STATUS_CHANGE', l_debug_level3);
          END IF;

	  IF (PA_PROJECT_STUS_UTILS.ALLOW_STATUS_CHANGE(l_old_project_status,p_new_status_code) = 'N') THEN
	       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
				    p_msg_name       => 'PA_STATUS_CANT_CHANGE');
	       RAISE FND_API.G_EXC_ERROR;
	  END IF;
-- Bug 4565023: End

          IF (l_debug_mode = 'Y') THEN
               Pa_Debug.WRITE(G_PKG_NAME,'Calling HANDLE_PROJECT_STATUS_CHANGE', l_debug_level3);
          END IF;

          --The following API call will verify the projects status change
          PA_PROJECT_STUS_UTILS.HANDLE_PROJECT_STATUS_CHANGE
          ( x_calling_module                => L_calling_module
           ,X_project_id                    => p_project_id
           ,X_old_proj_status_code          => l_rec_project_details.project_status_code
           ,X_new_proj_status_code          => p_new_status_code
           ,X_project_type                  => l_rec_project_details.project_type
           ,X_project_start_date            => l_rec_project_details.start_date
           ,X_project_end_date              => l_rec_project_details.closed_date
           ,X_public_sector_flag            => l_rec_project_details.public_sector_flag
           ,X_attribute_category            => l_rec_project_details.attribute_category
           ,X_attribute1                    => l_rec_project_details.attribute1
           ,X_attribute2                    => l_rec_project_details.attribute2
           ,X_attribute3                    => l_rec_project_details.attribute3
           ,X_attribute4                    => l_rec_project_details.attribute4
           ,X_attribute5                    => l_rec_project_details.attribute5
           ,X_attribute6                    => l_rec_project_details.attribute6
           ,X_attribute7                    => l_rec_project_details.attribute7
           ,X_attribute8                    => l_rec_project_details.attribute8
           ,X_attribute9                    => l_rec_project_details.attribute9
           ,X_attribute10                   => l_rec_project_details.attribute10
           ,X_pm_product_code               => l_rec_project_details.pm_product_code
           ,x_init_msg                      => 'N'
           ,x_verify_ok_flag                => l_verify_ok_flag
           ,x_wf_enabled_flag               => l_wf_enabled_flag
           ,X_err_stage                     => l_err_stage
           ,X_err_stack                     => l_err_stack
           ,x_err_msg_count                 => l_msg_count
           ,x_warnings_only_flag            => l_warnings_only_flag  );

           IF (l_debug_mode = 'Y') THEN
               Pa_Debug.WRITE(G_PKG_NAME,'l_verify_ok_flag ='||l_verify_ok_flag||' l_wf_enabled_flag ='||l_wf_enabled_flag,
                              l_debug_level3);
           END IF;

           IF l_verify_ok_flag <> 'Y' THEN
                x_msg_data := l_err_stack||'-> '||l_err_stage;
                RAISE FND_API.G_EXC_ERROR;
           ELSIF l_verify_ok_flag = 'Y' THEN
		            -- Moved this block so that the comment is available in the table before the
 	                 -- workflow is initiated (Bug 6720288)
 	                 DECLARE
 	                     l_rowid               VARCHAR2(255);
 	                     l_obj_status_change_id  NUMBER;
 	                 BEGIN
 	                      SELECT pa_obj_status_changes_s.NEXTVAL INTO l_obj_status_change_id
 	                      FROM dual;
 	                      /* 4364878 : Moved this code to Block tagged with <**A**>
 	                      OPEN  cur_get_system_status(p_new_status_code);
 	                      FETCH cur_get_system_status INTO l_new_sys_status;
 	                      CLOSE cur_get_system_status;
 	                       Moved this code to Block tagged with <**A**> */

 	                     IF (l_debug_mode = 'Y') THEN
 	                          pa_debug.debug('Calling PA_OBJ_STATUS_CHANGES_PKG.INSERT_ROW');
 	                     END IF;

 	                      --For inserting status change comment into the status history table
 	                      PA_OBJ_STATUS_CHANGES_PKG.INSERT_ROW
 	                      ( X_ROWID                        => l_rowid,
 	                        X_OBJ_STATUS_CHANGE_ID         => l_obj_status_change_id,
 	                        X_OBJECT_TYPE                  => 'PA_PROJECTS',
 	                        X_OBJECT_ID                    => p_project_id,
 	                        X_STATUS_TYPE                  => 'PROJECT',
 	                        X_NEW_PROJECT_STATUS_CODE      => p_new_status_code,
 	                        X_NEW_PROJECT_SYSTEM_STATUS_CO => l_new_sys_status,
 	                        X_OLD_PROJECT_STATUS_CODE      => l_old_project_status,
 	                        X_OLD_PROJECT_SYSTEM_STATUS_CO => l_old_sys_status,
 	                        X_CHANGE_COMMENT               => p_comment,
 	                        X_LAST_UPDATED_BY              => fnd_global.user_id,
 	                        X_CREATED_BY                   => fnd_global.user_id,
 	                        X_CREATION_DATE                => sysdate,
 	                        X_LAST_UPDATE_DATE             => sysdate,
 	                        X_LAST_UPDATE_LOGIN            => fnd_global.user_id );

 	                      IF (l_debug_mode = 'Y') THEN
 	                           pa_debug.debug('Updated PA_PROJECTS_ALL for status history');
 	                      END IF;

 	                       /*Stubbed Out Auto Initiate Demand On Project Approval Functionality
 	                         Bug 3819086 */
 	                      /* Bug 3611598  Start of Changes by avaithia on 05-May-2004
 	                         Included Call to wrapper API to automatically Initiate Demand when the Project Status
 	                         is changed to 'Approved' (provided workflow is not enabled)*/
 	                      /*Start of Commenting Bug 3819086 */
 	                      /*IF nvl(l_new_sys_status,'-99') = 'APPROVED'  AND  nvl(l_wf_enabled_flag,'N') = 'N' THEN
 	                          PA_ACTIONS_PUB.RUN_ACTION_CONC_PROCESS_WRP
 	                          (p_project_id       =>  p_project_id
 	                          -- 3671408 added IN parameter, passing retrieve project_number
 	                          ,p_project_number   =>  l_rec_project_details.segment1
 	                          ,x_return_status    =>  x_return_status
 	                          ,x_msg_count        =>  x_msg_count
 	                          ,x_msg_data         =>  x_msg_data
 	                          );
 	                         IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
 	                              RAISE FND_API.G_EXC_ERROR ;
 	                         END IF;
 	                      END IF;*/
 	                      /* End of Changes for Bug   3611598  */
 	                     /*End of Commenting Bug 3819086 */

 	                 END;

                SELECT wf_status_code INTO l_wf_status_code
                FROM  PA_PROJECTS_ALL
                WHERE project_id = p_project_id;

                IF (l_debug_mode = 'Y') THEN
                     Pa_Debug.WRITE(G_PKG_NAME,'l_wf_status_code ='||l_wf_status_code,
                                    l_debug_level3);
                END IF;

                IF (l_abort_flag='Y') THEN                        -- for BUG# 6661144

 	                               -- 4364878 : if new system status corresponds to CLOSED
 	                               -- Then Populate the closed date as sysdate

 	                               IF l_new_sys_status = 'CLOSED' THEN
 	                                    UPDATE pa_projects_all
 	                                    SET  wf_status_code = NULL
 	                                         ,project_status_code = p_new_status_code
 	                                         ,closed_date        = sysdate
 	                                         ,last_update_date    = sysdate
 	                                         ,last_updated_by     = fnd_global.user_id
 	                                         ,last_update_login   = fnd_global.login_id
 	                                    WHERE project_id = p_project_id;
 	                               ELSE

 	                               UPDATE pa_projects_all
 	                               SET  wf_status_code = NULL
 	                                   ,project_status_code = p_new_status_code  --Added for bug 3818322
 	                                  /*4364878 : Included update of who columns also*/
 	                                   ,closed_date        = to_date(null) --For any status other than Closed,this field should be NULL
 	                                   ,last_update_date    = sysdate
 	                                   ,last_updated_by     = fnd_global.user_id
 	                                   ,last_update_login   = fnd_global.login_id
 	                               WHERE project_id = p_project_id;
 	                               END IF;

 	                               --Start the workflow for the project



 	            ELSIF l_wf_status_code IS NULL  THEN                -- Made ELSEIF against the existing IF, for BUG# 6661144
                       IF l_wf_enabled_flag = 'Y' THEN
                              -- Update wf status in pa_projects_all

                              -- 4364878 : if new system status corresponds to CLOSED
                  -- Then Populate the closed date as sysdate

                              If l_new_sys_status = 'CLOSED' THEN
                                   UPDATE pa_projects_all
                   SET  wf_status_code = 'IN_ROUTE'
                    ,project_status_code = p_new_status_code
                    ,closed_date        = sysdate
                    ,last_update_date    = sysdate
                    ,last_updated_by     = fnd_global.user_id
                    ,last_update_login   = fnd_global.login_id
                   WHERE project_id = p_project_id;
                              ELSE

                              UPDATE pa_projects_all
                              SET  wf_status_code = 'IN_ROUTE'
                                  ,project_status_code = p_new_status_code  --Added for bug 3818322
                 /*4364878 : Included update of who columns also*/
                  ,closed_date        = to_date(null) --For any status other than Closed,this field should be NULL
                  ,last_update_date    = sysdate
                  ,last_updated_by     = fnd_global.user_id
                  ,last_update_login   = fnd_global.login_id
                              WHERE project_id = p_project_id;
                  END IF;

                              --Start the workflow for the project
                              pa_project_wf.start_project_wf
                              (  p_project_id
                               , l_err_stack
                               , l_err_stage
                               , l_err_code  );

                              IF l_err_code <> 0 THEN
                                PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                                     p_msg_name       => l_err_stage);
                                x_msg_data := l_err_stack||'-> '||l_err_stage;
                                RAISE FND_API.G_EXC_ERROR;
                              END IF;
                       END IF;
                ELSE
                       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                            p_msg_name       => 'PA_STATUS_CANT_CHANGE');
                       RAISE FND_API.G_EXC_ERROR;
                END IF;

                --Uncommented the foll. code and added IF condition for bug 3940861
                --(had been commented for 3818322)
               IF l_wf_enabled_flag = 'N'  AND l_abort_flag='N' THEN   -- Added the AND condition for BUG# 6661144

              -- 4364878 : if new system status corresponds to CLOSED
              -- Then Populate the closed date as sysdate
             If l_new_sys_status = 'CLOSED' THEN

                     UPDATE pa_projects_all
                     SET    project_status_code = p_new_status_code
             ,closed_date        = sysdate
             ,last_update_date    = sysdate
             ,last_updated_by     = fnd_global.user_id
             ,last_update_login   = fnd_global.login_id
                     WHERE  project_id = p_project_id ;

             Else

                     UPDATE pa_projects_all
                     SET    project_status_code = p_new_status_code
             /*4364878 : Included update of who columns also*/
             ,closed_date        = to_date(null) --For any status other than Closed,this field should be NULL
                     ,last_update_date    = sysdate
                     ,last_updated_by     = fnd_global.user_id
                     ,last_update_login   = fnd_global.login_id
                     WHERE  project_id = p_project_id ;

             End if;
                END IF;
           END IF;


     END IF;--IF p_project_id IS NOT NULL

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN

     x_return_status := Fnd_Api.G_RET_STS_ERROR;

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO project_status_change;
     END IF;

     l_msg_count := Fnd_Msg_Pub.count_msg;
     IF l_msg_count = 1 AND x_msg_data IS NULL
      THEN
          Pa_Interface_Utils_Pub.get_messages
              ( p_encoded        => Fnd_Api.G_FALSE
              , p_msg_index      => 1
              , p_msg_count      => l_msg_count
              , p_msg_data       => l_msg_data
              , p_data           => l_data
              , p_msg_index_out  => l_msg_index_out);
          x_msg_data := l_data;
          x_msg_count := l_msg_count;
     ELSE
          x_msg_count := l_msg_count;
     END IF;

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.reset_curr_function;
     END IF;

WHEN Invalid_Arg_Exc THEN
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := ' PA_PROJECTS_MAINT_PUB : project_status_change : NULL parameters passed';

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO project_status_change;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
                   (  p_pkg_name         => 'PA_PROJECTS_MAINT_PUB'
                    , p_procedure_name  => 'project_status_change'
                    , p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(G_PKG_NAME,Pa_Debug.g_err_stage,
                              l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;

WHEN OTHERS THEN
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO project_status_change;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
           ( p_pkg_name         => 'PA_PROJECTS_MAINT_PUB'
            , p_procedure_name  => 'project_status_change'
            , p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(G_PKG_NAME,Pa_Debug.g_err_stage,
                              l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;

END project_status_change;


END PA_PROJECTS_MAINT_PUB;

/
