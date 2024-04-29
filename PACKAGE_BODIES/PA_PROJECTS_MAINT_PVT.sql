--------------------------------------------------------
--  DDL for Package Body PA_PROJECTS_MAINT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECTS_MAINT_PVT" AS
/* $Header: PARMPRVB.pls 120.10.12010000.6 2009/10/13 11:19:04 nkapling ship $ */
G_PKG_NAME              CONSTANT VARCHAR2(30) := 'PA_PROJECTS_MAINT_PVT';
-- API name     : create_project
-- Type         : Private
-- Pre-reqs     : None.
-- Parameters           :
-- p_commit             IN VARCHAR2   Optional Default = FND_API.G_FALSE
-- p_validate_only      IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_validation_level   IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module     IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode         IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count      IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_orig_project_id    IN NUMBER     Required
-- p_project_name       IN VARCHAR2   Required
-- p_project_number     IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_description        IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_project_type       IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_project_status_code IN VARCHAR2  Optional Default = FND_API.G_MISS_CHAR
-- p_distribution_rule   IN VARCHAR2  Optional Default = FND_API.G_MISS_CHAR
-- p_public_sector_flag  IN VARCHAR2  Optional Default = FND_API.G_MISS_CHAR
-- p_carrying_out_organization_id IN NUMBER Optional
--                                   Default = FND_API.G_MISS_NUM
-- p_start_date          IN DATE      Optional Default = FND_API.G_MISS_DATE
-- p_completion_date     IN DATE      Optional Default = FND_API.G_MISS_DATE
-- p_probability_member_id IN NUMBER  Optional Default = FND_API.G_MISS_NUM
-- p_project_value          IN NUMBER  Optional Default = FND_API.G_MISS_NUM
-- p_expected_approval_date IN DATE    Optional Default = FND_API.G_MISS_DATE
-- p_team_template_id       IN NUMBER  Optional Default = FND_API.G_MISS_NUM
-- p_country_code           IN VARCHAR2 Optional Default = FND_API.G_MISS_CHAR
-- p_region                 IN VARCHAR2 Optional Default = FND_API.G_MISS_CHAR
-- p_city                   IN VARCHAR2 Optional Default = FND_API.G_MISS_CHAR
-- p_customer_id            IN NUMBER  Optional Default = FND_API.G_MISS_NUM
-- p_agreement_currency     IN VARCHAR2 Optional Default = FND_API.G_MISS_CHAR
-- p_agreement_amount       IN NUMBER   Optional Default = FND_API.G_MISS_NUM
-- p_agreement_org_id       IN NUMBER   Optional Default = FND_API.G_MISS_NUM
-- p_opp_value_currency_code      IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
-- p_bill_to_customer_id          IN NUMBER     := NULL                  ,   /* For Bug 2731449 */
-- p_ship_to_customer_id          IN NUMBER     := NULL                  ,   /* For Bug 2731449 */

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
(p_commit                       IN VARCHAR2   := FND_API.G_FALSE       ,
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
 p_distribution_rule            IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_public_sector_flag           IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_carrying_out_organization_id IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_start_date                   IN DATE       := FND_API.G_MISS_DATE   ,
 p_completion_date              IN DATE       := FND_API.G_MISS_DATE   ,
 p_probability_member_id        IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_project_value                IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_expected_approval_date       IN DATE       := FND_API.G_MISS_DATE   ,
 p_team_template_id             IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_country_code                 IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_region                       IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_city                         IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_customer_id                  IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_agreement_currency           IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_agreement_amount             IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_agreement_org_id             IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_opp_value_currency_code      IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_priority_code                IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_template_flag                IN VARCHAR2   := 'N',
 p_security_level               IN NUMBER     := FND_API.G_MISS_NUM    ,
-- Customer Account Relationship
 p_bill_to_customer_id          IN NUMBER     := NULL                  ,   /* For Bug 2731449 */
 p_ship_to_customer_id          IN NUMBER     := NULL                  ,   /* For Bug 2731449 */
--Customer Account Relationship
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

-- 4363092 TCA changes, replaced RA views with HZ tables
--l_customer_id              ra_customers.customer_id%TYPE;
l_customer_id              hz_cust_accounts.cust_account_id%TYPE;
-- 4363092 end

l_organization_id          hr_organization_units.organization_id%TYPE;
l_project_status_code      pa_project_statuses.project_status_code%TYPE;
l_project_id               pa_projects.project_id%TYPE;
l_project_number_out       pa_projects.segment1%TYPE;
l_probability_member_id    pa_probability_members.probability_member_id%TYPE;
l_project_value          PA_PROJECTS_ALL.PROJECT_VALUE%TYPE;
l_expected_approval_date PA_PROJECTS_ALL.EXPECTED_APPROVAL_DATE%TYPE;
l_completion_date          PA_PROJECTS_ALL.COMPLETION_DATE%TYPE;
l_public_sector_flag       PA_PROJECTS_ALL.PUBLIC_SECTOR_FLAG%TYPE;
l_description              PA_PROJECTS_ALL.DESCRIPTION%TYPE;
l_project_number           PA_PROJECTS_ALL.SEGMENT1%TYPE;
l_distribution_rule        PA_PROJECTS_ALL.DISTRIBUTION_RULE%TYPE;
l_team_template_id         PA_TEAM_TEMPLATES.TEAM_TEMPLATE_ID%TYPE;
l_country_code             PA_LOCATIONS.COUNTRY_CODE%TYPE;
l_region                   PA_LOCATIONS.REGION%TYPE;
l_city                     PA_LOCATIONS.CITY%TYPE;
l_return_status            VARCHAR2(1);
l_error_msg_code           VARCHAR2(250);
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(250);
l_err_code                 VARCHAR2(250);
l_err_stage                VARCHAR2(2000);
l_err_stack                VARCHAR2(2000);
l_data                     VARCHAR2(250);
l_msg_index_out            NUMBER;
l_relationship_type        VARCHAR2(30);
l_agreement_currency       FND_CURRENCIES_VL.CURRENCY_CODE%TYPE;
l_agreement_amount         NUMBER;
l_agreement_org_id         NUMBER;
l_opp_value_currency_code  FND_CURRENCIES_VL.CURRENCY_CODE%TYPE;
l_priority_code            VARCHAR2(30);
-- Added the nvl condition in the cursor query for bug 4954698
CURSOR  l_override_fields_csr --(c_project_id NUMBER) Bug 5478390: c_project_id no longer used
   IS
   SELECT      TYPE
   FROM         pa_override_fields_v pof
   WHERE        pof.pa_field_name = 'CUSTOMER_NAME'
     AND        EXISTS(SELECT 'x' from pa_projects_all PP
     -- replaced c_project_id with p_orig_project_id in where clause for Bug 5478390
                       WHERE PP.project_id = p_orig_project_id
                         AND nvl(PP.created_from_project_id,p_orig_project_id) =
                             POF.pa_source_template_id);

-- anlee
-- added for copy retention
-- Modified below cursor for bug 5724556
CURSOR l_get_project_dates_csr (c_project_id NUMBER)
IS
SELECT start_date, completion_date, enable_top_task_customer_flag
FROM   pa_projects_all
WHERE  project_id = c_project_id;

l_proj_start_date             DATE;
l_proj_completion_date        DATE;

/* Bug2450468 Begin */

l_project_type_class_code         VARCHAR2(80);

CURSOR l_get_prj_class_code
IS
select  meaning
from    pa_project_types pt
      , pa_lookups lps
      , pa_projects pp
where  pt.project_type    = pp.project_type
and  lps.lookup_type(+) = 'PROJECT TYPE CLASS'
and  lps.lookup_code(+) = pt.project_type_class_code
and  pp.project_id=p_orig_project_id;

/* Bug2450468 End */
-- bug 5724556
l_calling_context  varchar2(25);
l_top_task_cust_flag varchar2(1) :='N';

BEGIN

-- Standard call to check for call compatibility

   if (p_debug_mode = 'Y') then
       pa_debug.debug('Create_Project PVT: Checking the api version number.');
   end if;

--dbms_output.put_line('Starts here PA_PROJECTS_MAINT_PVT.CREATE_PROJECT  ... ');

   IF p_commit = FND_API.G_TRUE THEN
      SAVEPOINT prm_create_project;
   END IF;

   x_return_status := 'S';

--dbms_output.put_line('Before p_carrying_out_organization_id  ... ');

--dbms_output.put_line('Before copy_project call  ... ');

 if (NOT FND_API.TO_BOOLEAN (p_validate_only)) then

   if (p_debug_mode = 'Y') then
       pa_debug.debug('Create_Project PVT: Calling copy project');
   end if;

        if p_project_Value = FND_API.G_MISS_NUM
        then
          l_project_value := null;
        else
          l_project_value := p_project_value;
        end if;

        if p_expected_Approval_Date= FND_API.G_MISS_DATE
        then
          l_expected_approval_date := null;
        else
          l_expected_approval_Date := p_expected_approval_date;
        end if;

        if p_completion_date = FND_API.G_MISS_DATE
       then
         l_completion_Date := null;
       else
         l_completion_date  := p_completion_date;
       end if;

        if p_public_Sector_Flag = FND_API.G_MISS_CHAR
        then
          l_public_sector_flag := null;
        else
          l_public_sector_flag := p_public_Sector_flag;
        end if;

        if p_distribution_rule = FND_API.G_MISS_CHAR
        then
          l_distribution_rule := null;
        else
          l_distribution_rule := p_distribution_rule;
        end if;

        if p_description = FND_API.G_MISS_CHAR
        then
          l_description  := null;
        else
          l_description   := p_description;
        end if;

        if p_project_number = FND_API.G_MISS_CHAR
        then
          l_project_number := null;
        else
          l_project_number := p_project_number;
        end if;

   if p_team_template_id = FND_API.G_MISS_NUM then
      l_team_template_id := null;
   else
      l_team_template_id := p_team_template_id;
   end if;

   if p_country_code = FND_API.G_MISS_CHAR then
      l_country_code := null;
   else
      l_country_code := p_country_code;
   end if;

   if p_region = FND_API.G_MISS_CHAR then
      l_region := null;
   else
      l_region := p_region;
   end if;

   if p_city = FND_API.G_MISS_CHAR then
      l_city := null;
   else
      l_city := p_city;
   end if;

   if p_agreement_currency = FND_API.G_MISS_CHAR then
      l_agreement_currency := null;
   else
      l_agreement_currency := p_agreement_currency;
   end if;

   if p_agreement_amount = FND_API.G_MISS_NUM then
      l_agreement_amount := null;
   else
      l_agreement_amount := p_agreement_amount;
   end if;

   if p_agreement_org_id = FND_API.G_MISS_NUM then
      l_agreement_org_id := null;
   else
      l_agreement_org_id := p_agreement_org_id;
   end if;

   if p_opp_value_currency_code = FND_API.G_MISS_CHAR then
      l_opp_value_currency_code := null;
   else
      l_opp_value_currency_code := p_opp_value_currency_code;
   end if;

--Priority code changes
   if p_priority_code = FND_API.G_MISS_CHAR then
      l_priority_code := null;
   else
      l_priority_code := p_priority_code;
   end if;

   If (p_project_value is not null and p_project_value < 0) then
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name  =>'PA_BU_NEED_POS_NUM');
    RAISE FND_API.G_EXC_ERROR;
   end if;

--dbms_output.put_line('Before UPDATE PA_PROJECTS_ALL Status : ');

   pa_project_core1.copy_project  (
     x_orig_project_id              => p_orig_project_id
    ,x_project_name                 => RTRIM(p_project_name)
    ,x_project_number               => RTRIM(l_project_number)
    ,x_description                  => RTRIM(l_description)
    ,x_project_type                 => NULL --project_type is always defaulted from template
    ,x_project_status_code          => p_project_status_code
    ,x_distribution_rule            => l_distribution_rule
    ,x_public_sector_flag           => l_public_sector_flag
    ,x_organization_id              => p_carrying_out_organization_id
    ,x_start_date                   => p_start_date
    ,x_completion_date              => l_completion_date
    ,x_probability_member_id        => p_probability_member_id
    ,x_project_value                => l_project_value
    ,x_expected_approval_date       => l_expected_approval_date
    ,x_copy_task_flag               => 'Y'
    ,x_copy_budget_flag             => 'Y'
    ,x_use_override_flag            => 'Y'
    ,x_copy_assignment_flag         => 'N'
    ,x_template_flag                => p_template_flag
    ,x_project_id                   => l_project_id
    ,x_err_code                     => l_err_code
    ,x_err_stage                    => l_err_stage
    ,x_err_stack                    => l_err_stack
    ,x_new_project_number           => l_project_number_out
    ,x_team_template_id             => l_team_template_id
    ,x_country_code                 => l_country_code
    ,x_region                       => l_region
    ,x_city                         => l_city
    ,x_opp_value_currency_code      => l_opp_value_currency_code
    ,x_agreement_currency           => l_agreement_currency
    ,x_agreement_amount             => l_agreement_amount
    ,x_agreement_org_id             => l_agreement_org_id
    ,x_org_project_copy_flag        => 'N'
    ,x_priority_code                => l_priority_code
    ,x_security_level               => p_security_level
-- anlee
-- Project Long Name changes
    ,x_long_name                    => p_long_name
-- End of changes
--maansari   for bug 2783257
    ,x_customer_id                  => p_customer_id
--End of changes.
   );

   if (p_debug_mode = 'Y') then
       pa_debug.debug('Create_Project PVT: Checking error messages returned from copy project');
   end if;
    IF l_err_code > 0
    THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
/*            IF NOT pa_project_pvt.check_valid_message(l_err_stage)
            THEN
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                       p_msg_name      => 'PA_PROJ_COPY_PROJECT_FAILED');

                 x_msg_data := 'PA_PROJ_COPY_PROJECT_FAILED';
             ELSE*/
    /* Bug2450468 Begin - Commenting the following code and adding the code*/
      /*     IF l_err_stage IS NOT NULL
             THEN
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name       => l_err_stage);
             END IF;
       */

             IF l_err_stage = 'PA_INVALID_PT_CLASS_ORG' THEN
                   OPEN l_get_prj_class_code;
           FETCH l_get_prj_class_code INTO l_project_type_class_code;
                   CLOSE l_get_prj_class_code;

                   PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                        p_msg_name       => 'PA_INVALID_PT_CLASS_ORG',
                                        p_token1         => 'PT_CLASS',
                                        p_value1         => l_project_type_class_code);
             ELSE
                   IF l_err_stage IS NOT NULL THEN
                       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name       => l_err_stage);
                   END IF;

             END IF; -- l_err_stage = 'PA_INVALID_PT_CLASS_ORG'
         /* Bug2450468 End */

             x_msg_data := l_err_stage;
--             END IF;

         END IF;

         x_return_status := FND_API.G_RET_STS_ERROR;

     ELSIF l_err_code < 0
     THEN
        /*  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
                  PA_UTILS.ADD_MESSAGE
                    (p_app_short_name => 'PA',
                     p_msg_name       => 'PA_PROJ_COPY_PROJECT_FAILED');
                  x_msg_data := 'PA_PROJ_COPY_PROJECT_FAILED';
          END IF;*/
          IF l_err_stage IS NOT NULL
          THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name       => l_err_stage);
          END IF;
                 x_msg_data := l_err_stage;
          x_return_status := 'E';
      END IF;

   p_project_id         := l_project_id;
   p_new_project_number := l_project_number_out;

 end if; -- p_validate_only = 'Y'

   l_msg_count := FND_MSG_PUB.count_msg;

--dbms_output.put_line('MSG_COUNT : CREATE_PROJECT ERROR : '||to_char(l_msg_count));

   IF l_msg_count > 0 THEN
      x_return_status := 'E';
      x_msg_count := l_msg_count;
      RAISE  FND_API.G_EXC_ERROR;
   END IF;

--dbms_output.put_line('*** Before create_customer call *** '||to_char(p_customer_id));

   -- added below code for bug 5724556
   OPEN l_get_project_dates_csr(l_project_id);
   FETCH l_get_project_dates_csr INTO l_proj_start_date, l_proj_completion_date, l_top_task_cust_flag;
   CLOSE l_get_project_dates_csr;

   if nvl(l_top_task_cust_flag,'N') = 'Y' then
        l_calling_context := 'CREATE_PROJ_TT_CUST';
   else
        l_calling_context := 'CREATE_PROJ_NO_TT_CUST';
   end if;

   IF p_customer_id   is not null
   THEN

--dbms_output.put_line('*** Before create_customer call  ... '||to_char(l_project_id));

        OPEN  l_override_fields_csr; --(p_project_id)Bug 5478390: p_project_id no longer required.
        FETCH l_override_fields_csr INTO l_relationship_type;
        CLOSE l_override_fields_csr;

--dbms_output.put_line('*** Relationship  ... '||l_relationship_type);
-- l_relationship_type := 'Primary';

   if (p_debug_mode = 'Y') then
       pa_debug.debug('Create_Project PVT: Calling create customer private API');
   end if;
        PA_PROJECTS_MAINT_PVT.CREATE_CUSTOMER
                       ( p_commit          => FND_API.G_FALSE          ,
                         p_validate_only    => p_validate_only          ,
                         p_validation_level => p_validation_level      ,
                         p_debug_mode       => p_debug_mode            ,
                         p_max_msg_count   => FND_API.G_MISS_NUM       ,
			 p_calling_module  => l_calling_context        , -- bug 5724556
                         p_project_id      => l_project_id             ,
                         p_customer_id     => p_customer_id            ,
                         p_relationship_type  => l_relationship_type,
               --Customer Account relationship
                         p_bill_to_customer_id => p_bill_to_customer_id,
                         p_ship_to_customer_id => p_ship_to_customer_id,
               --Customer Account relationship
                         x_return_status   => l_return_status          ,
                         x_msg_count       => l_msg_count              ,
                         x_msg_data        => l_msg_data) ;

--dbms_output.put_line('IN create_customer call  ... '||l_return_status);

    END IF;

   l_msg_count := FND_MSG_PUB.count_msg;

--dbms_output.put_line('After create_customer call  ... '||to_char(l_msg_count));

   IF l_msg_count > 0 THEN
--      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count;
      RAISE  FND_API.G_EXC_ERROR;
   END IF;

   -- anlee
   -- Copy rentention
   if (NOT FND_API.TO_BOOLEAN (p_validate_only)) then
     if (p_debug_mode = 'Y') then
       pa_debug.debug('Create_Project PVT: Calling copy retention API');
     end if;

     /* Moved this code to before call to create customer to get enable top task customer flag
        bug 5690529
     OPEN l_get_project_dates_csr(l_project_id);
     FETCH l_get_project_dates_csr INTO l_proj_start_date, l_proj_completion_date;
     CLOSE l_get_project_dates_csr;
     */
     pa_retention_util.copy_retention_setup
     ( p_fr_project_id       => p_orig_project_id
      ,p_to_project_id       => l_project_id
      ,p_fr_date             => l_proj_start_date
      ,p_to_date             => l_proj_completion_date
      ,x_return_status       => l_return_status
      ,x_msg_count           => l_msg_count
      ,x_msg_data            => l_msg_data );

     l_msg_count := FND_MSG_PUB.count_msg;

     IF l_msg_count > 0 THEN
       x_msg_count := l_msg_count;
       RAISE  FND_API.G_EXC_ERROR;
     END IF;

   end if;

   IF FND_API.TO_BOOLEAN(P_COMMIT)
   THEN
      COMMIT WORK;
   END IF;

EXCEPTION WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO prm_create_project;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECTS_MAINT_PVT',
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
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECTS_MAINT_PVT',
                            p_procedure_name => 'CREATE_PROJECT',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    raise;

END CREATE_PROJECT;

-- API name     : create_customer
-- Type         : Public
-- Pre-reqs     : None.
-- Parameters           :
-- p_commit             IN VARCHAR2   Optional Default = FND_API.G_FALSE
-- p_validate_only      IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_validation_level   IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module     IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode         IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count      IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_project_id         IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_customer_id        IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_relationship_type  IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- x_return_status      OUT VARCHAR2  REQUIRED
-- x_msg_count          OUT NUMBER    REQUIRED
-- x_msg_data           OUT VARCHAR2  REQUIRED
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
PROCEDURE CREATE_CUSTOMER
(
 p_commit                       IN VARCHAR2   := FND_API.G_FALSE       ,
 p_validate_only                IN VARCHAR2   := FND_API.G_TRUE        ,
 p_validation_level             IN NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_calling_module               IN VARCHAR2   := 'SELF_SERVICE'        ,
 p_debug_mode                   IN VARCHAR2   := 'N'                   ,
 p_max_msg_count                IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_project_id                   IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_customer_id                  IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_relationship_type            IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
--Customer Account Relationship
 p_bill_to_customer_id          IN NUMBER     := NULL                  ,
 p_ship_to_customer_id          IN NUMBER     := NULL                  ,
--Customer Account Relationship
 x_return_status               OUT NOCOPY VARCHAR2                            , --File.Sql.39 bug 4440895
 x_msg_count                   OUT NOCOPY NUMBER                              , --File.Sql.39 bug 4440895
 x_msg_data                    OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

CURSOR l_project_csr (c_project_id NUMBER) -- Bug 6166197: cursor modified to fetch project_type_class_code also
   Is
   Select project_currency_code, project_type_class_code
   From   pa_projects_all pa, pa_project_types_all pt
   Where  pa.project_id = c_project_id
   And    pa.project_type = pt.project_type
   And    nvl(pa.org_id,-99) = nvl(pt.org_id,-99);

/*Commented since not being used anymore: Bug 5478390
CURSOR  l_override_fields_csr (c_project_id NUMBER)
   IS
   SELECT      TYPE
   FROM         pa_override_fields_v pof
   WHERE        pof.pa_field_name = 'CUSTOMER_NAME'
     AND        EXISTS(SELECT 'x' from pa_projects_all PP
                       WHERE PP.project_id = c_project_id
                         AND PP.created_from_project_id =
                             POF.pa_source_template_id);*/

CURSOR cur_pa_impl IS
   SELECT default_rate_type
     FROM pa_implementations;



-- 4363092 TCA changes, replaced RA views with HZ tables
--l_customer_id              ra_customers.customer_id%TYPE;
l_customer_id              hz_cust_accounts.cust_account_id%TYPE;
-- 4363092 end
l_return_status            VARCHAR2(1);
l_error_msg_code           VARCHAR2(250);
l_bill_to_address_id       NUMBER := NULL; --Initialized to NULL for Bug 3911782
l_ship_to_address_id       NUMBER := NULL; --Initialized to NULL for Bug 3911782
l_bill_to_contact_id       NUMBER := NULL; --Initialized to NULL for Bug 4764943 - R12 Bug 4764449
l_ship_to_contact_id       NUMBER := NULL; --Initialized to NULL for Bug 4764943 - R12 Bug 4764449
l_err_code                 NUMBER;
l_err_stage                VARCHAR2(250);
l_err_stack                VARCHAR2(250);
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(250);
l_msg_index_out            NUMBER;
--customer
l_inv_currency_code        VARCHAR2(15);
l_inv_rate_type            VARCHAR2(30);
l_inv_rate_date            DATE;
l_inv_exchange_rate        NUMBER;
l_allow_inv_rate_type_fg   VARCHAR2(1);
l_bill_another_prj_flag    VARCHAR2(1);
l_receiver_task_id         NUMBER;
-- override
l_relationship_type        VARCHAR2(30);
l_data                     VARCHAR2(250);
l_party_id                      NUMBER;

--Customer account relationship changes

l_bill_to_customer_id     Number;
l_ship_to_customer_id     Number;

--customer Account Relationship changes

l_proj_type_class_code     pa_project_types_all.project_type_class_code%TYPE;  -- Bug 6166197

-- anlee org role changes
   l_project_party_id              NUMBER;
   l_resource_id                   NUMBER;
   l_wf_item_type                  VARCHAR2(30);
   l_wf_type                       VARCHAR2(30);
   l_wf_party_process              VARCHAR2(30);
   l_assignment_id                 NUMBER;
   l_end_date_active               DATE;

   CURSOR l_check_org_csr IS
   SELECT PARTY_ID
   FROM PA_CUSTOMERS_V
   WHERE CUSTOMER_ID = p_customer_id
   AND   PARTY_TYPE = 'ORGANIZATION';


--sunkalya:federal Bug#5511353

     l_date_eff_funds_flag VARCHAR2(1);
     customer_bill_split NUMBER;
     CURSOR get_date_eff_funds_flag( c_project_id IN NUMBER )
     IS
     SELECT
     nvl(DATE_EFF_FUNDS_CONSUMPTION,'N')
     FROM
     pa_projects_all
     WHERE project_id = c_project_id ;
--sunkalya:federal Bug#5511353

-- bug 5724556
   l_default_top_task_customer     varchar2(1) := 'N';
   l_contribution                  number;

BEGIN

--dbms_output.put_line('INSIDE PROCEDURE create_customer call  ... ');

   IF p_commit = FND_API.G_TRUE
   THEN
      SAVEPOINT create_customer;
   END IF;

   x_return_status := 'S';
-- Customer Account Relationship
   l_Bill_To_Customer_id :=  p_bill_To_Customer_id;
   l_Ship_To_Customer_id :=  p_Ship_To_Customer_id;
-- Customer Account Relationship


 if (NOT FND_API.TO_BOOLEAN (p_validate_only)) then

--dbms_output.put_line('Before get customer info call  ... ');

-- Please check only if p_calling_module 'QUECK_ENTRY' ...

   -- Bug 6166197: changes start
   -- l_project_csr moved up here to fetch project-type-class-code before calling pa_customer_info.get_customer_info
     OPEN l_project_csr (p_project_id);
     FETCH l_project_csr INTO l_inv_currency_code, l_proj_type_class_code;
     CLOSE l_project_csr;
   -- Bug 6166197: changes end

-- Bug 6166197: if condition to check for project-type-class-code introduced
-- bypass call to pa_customer_info.get_customer_info for non-contract type projects

  if (nvl(l_proj_type_class_code,'NONE') = 'CONTRACT') then

   if (p_debug_mode = 'Y') then
       pa_debug.debug('Create_customer PVT: Calling get customer info API');
   end if;
    pa_customer_info.get_customer_info
      ( x_customer_id         => p_customer_id
-- Customer Account Relationship
       ,x_Bill_To_Customer_Id => l_bill_to_customer_id
       ,x_Ship_To_Customer_Id => l_ship_to_customer_id
-- Customer Account Relationship
       ,x_bill_to_address_id  =>l_bill_to_address_id
       ,x_ship_to_address_id  =>l_ship_to_address_id
       ,x_bill_to_contact_id  =>l_bill_to_contact_id
       ,x_ship_to_contact_id  =>l_ship_to_contact_id
       ,x_err_code            =>l_err_code
       ,x_err_stage           =>l_err_stage
       ,x_err_stack           =>l_err_stack         );

-- For this API,error code 10 is a warning.Anything above 10 is an error

   if (p_debug_mode = 'Y') then
       pa_debug.debug('Create_customer PVT: Checking Erorr messages returned from get_customer_info API');
   end if;
        IF l_err_code > 10
        THEN

            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                IF NOT pa_project_pvt.check_valid_message(l_err_stage)
                THEN
                    PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                         p_msg_name       =>
                                         'PA_GET_CUSTOMER_INFO_FAILED');
                    x_msg_data := 'PA_GET_CUSTOMER_INFO_FAILED';
                 ELSE
                    PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                        p_msg_name       => l_err_stage);
                    x_msg_data := l_err_stage;
                 END IF;
           END IF;

           x_return_status := 'E';

       ELSIF l_err_code < 0
       THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                  PA_UTILS.ADD_MESSAGE
                    (p_app_short_name => 'PA',
                     p_msg_name       => 'PA_PROJ_GET_CUST_INFO_FAILED');
                  x_msg_data := 'PA_PROJ_GET_CUST_INFO_FAILED';
             END IF;
             x_return_status := 'E';
        END IF;
    end if;  -- Bug 6166197

--dbms_output.put_line('Before create_customer contacts  ... '||to_char(p_project_id));

      -- Bug 6166197: changes start
      -- open/fetch/close of l_project_csr moved up before the call to pa_customer_info.get_customer_info
      -- to fetch project-type-class-code
      --OPEN l_project_csr (p_project_id);
      --FETCH l_project_csr INTO l_inv_currency_code;
      --CLOSE l_project_csr;
      -- Bug 6166197: changes end

--dbms_output.put_line('Before create_customer contacts  ... '||l_inv_currency_code);
--dbms_output.put_line('Before create_customer contacts  ... '||l_relationship_type);

      -- Bug 6166197: changes start
      -- If bill-to or ship-to customer id is null, set them to customer-id
        If l_bill_to_customer_id is null then
            l_bill_to_customer_id := p_customer_id;
        end if;

        If l_ship_to_customer_id is null then
            l_ship_to_customer_id := p_customer_id;
        end if;
      -- Bug 6166197: changes end

   if (p_debug_mode = 'Y') then
       pa_debug.debug('Create_customer PVT: Calling create_customer_contacts API');
   end if;
        OPEN cur_pa_impl;
        FETCH cur_pa_impl INTO l_inv_rate_type;
        CLOSE cur_pa_impl;

-- added below code for bug 5724556
        if p_calling_module = 'CREATE_PROJ_TT_CUST' then
            l_default_top_task_customer := 'Y';
            l_contribution := null;
        elsif p_calling_module = 'CREATE_PROJ_NO_TT_CUST' then
            l_default_top_task_customer := 'N';
            l_contribution :=100;
        end if;

--sunkalya:federal Bug#5511353

OPEN  get_date_eff_funds_flag(p_project_id);
FETCH get_date_eff_funds_flag INTO l_date_eff_funds_flag;
CLOSE get_date_eff_funds_flag;

IF l_date_eff_funds_flag ='Y' THEN
	customer_bill_split :=	null;
ELSE
	customer_bill_split :=	l_contribution;  -- changed for Bug 5724556
END IF;

--sunkalya:federal Bug#5511353

        pa_customer_info.create_customer_contacts
               ( x_project_id  => p_project_id
                ,x_customer_id => p_customer_id
                ,X_Project_Relation_Code => p_relationship_type
                ,X_Customer_Bill_Split  =>customer_bill_split		--sunkalya:federal Bug#5511353
--    Customer Account Relationship
                ,X_Bill_To_Customer_Id => l_bill_to_customer_id
                ,X_Ship_To_Customer_Id => l_ship_to_customer_id
--    Customer Account Relationship
                ,X_Bill_To_Address_Id => l_bill_to_address_id
                ,X_Ship_To_Address_Id => l_ship_to_address_id
                ,X_Bill_To_Contact_Id => l_bill_to_contact_id
                ,X_Ship_To_Contact_Id => l_ship_to_contact_id
                ,X_Inv_Currency_Code  => l_inv_currency_code
                ,X_Inv_Rate_Type      => l_inv_rate_type
                ,X_Inv_Rate_Date      => NULL
                ,X_Inv_Exchange_Rate  => NULL
                ,X_Allow_Inv_Rate_Type_Fg  => 'N'
                ,X_Bill_Another_Project_Fg => 'N'
                ,X_Receiver_Task_Id        => NULL
		,P_default_top_task_customer=>l_default_top_task_customer --bug 5724556
                ,X_User     => fnd_global.user_id
                ,X_Login    => fnd_global.login_id
                ,X_Err_Code => l_err_code
                ,X_Err_Stage => l_err_stage
                ,X_Err_Stack => l_err_stack );

--dbms_output.put_line('ERROR CODE : CREATE_CUSTOMER : '||to_char(l_err_code));

   if (p_debug_mode = 'Y') then
       pa_debug.debug('Create_customer PVT: Checking errors returned from create_customer_contacts API');
   end if;
                IF l_err_code > 0
                THEN
                    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                    THEN
                        IF NOT pa_project_pvt.check_valid_message(l_err_stage)
                        THEN
                              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name      => 'PA_PROJ_CR_CONTACTS_FAILED');
                              x_msg_data := 'PA_PROJ_CR_CONTACTS_FAILED';
                         ELSE
                              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name       => l_err_stage);
                              x_msg_data := l_err_stage ;
                         END IF;

                     END IF;

                     x_return_status := FND_API.G_RET_STS_ERROR;

                ELSIF l_err_code < 0
                THEN
                      PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                           p_msg_name       => 'PA_PROJ_CR_CONTACTS_FAILED');
                      x_msg_data := 'PA_PROJ_CR_CONTACTS_FAILED';
                      x_return_status := 'E';
                END IF;

--dbms_output.put_line('RETURN STATUS : CREATE_CUSTOMER ERROR : '||x_return_status);

    l_msg_count := FND_MSG_PUB.count_msg;

--dbms_output.put_line('MSG_COUNT : CREATE_CUSTOMER ERROR : '||to_char(l_msg_count));

    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      x_return_status := 'E';
      RAISE  FND_API.G_EXC_ERROR;
    END IF;

    -- anlee org role changes
    -- create a project party if the added customer is an organization
    l_party_id := null;
    l_project_party_id := null;
    OPEN l_check_org_csr;
    FETCH l_check_org_csr INTO l_party_id;
    IF l_check_org_csr%NOTFOUND then
      l_party_id := null;
    END IF;
    CLOSE l_check_org_csr;

    if l_party_id is not null then

       PA_PROJECT_PARTIES_PUB.CREATE_PROJECT_PARTY(
         p_validate_only              => FND_API.G_FALSE
       , p_object_id                  => p_project_id
       , p_OBJECT_TYPE                => 'PA_PROJECTS'
       , p_project_role_id            => 100
       , p_project_role_type          => 'CUSTOMER_ORG'
       , p_RESOURCE_TYPE_ID           => 112
       , p_resource_source_id         => l_party_id
       , p_start_date_active          => null
       , p_calling_module             => 'FORM'
       , p_project_id                 => p_project_id
       , p_project_end_date           => null
       , p_end_date_active            => l_end_date_active
       , x_project_party_id           => l_project_party_id
       , x_resource_id                => l_resource_id
       , x_wf_item_type               => l_wf_item_type
       , x_wf_type                    => l_wf_type
       , x_wf_process                 => l_wf_party_process
       , x_assignment_id              => l_assignment_id
       , x_return_status              => l_return_status
       , x_msg_count                  => l_msg_count
       , x_msg_data                   => l_msg_data );

       l_msg_count := FND_MSG_PUB.count_msg;
       IF l_msg_count > 0 THEN
         x_msg_count := l_msg_count;
         x_return_status := 'E';
         RAISE  FND_API.G_EXC_ERROR;
       END IF;

       -- Add the new project party ID to the customers row
       UPDATE PA_PROJECT_CUSTOMERS
       SET project_party_id = l_project_party_id
       WHERE project_id = p_project_id
       AND customer_id = p_customer_id;
    end if;

  end if;


    IF FND_API.TO_BOOLEAN(P_COMMIT)
    THEN
      COMMIT WORK;
    END IF;
--dbms_output.put_line('SUCCESSFULLY CREATED CUSTOMER ... ');

EXCEPTION WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO prm_create_customer;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECTS_MAINT_PVT',
                            p_procedure_name => 'CREATE_CUSTOMER',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

WHEN FND_API.G_EXC_ERROR THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO prm_create_customer;
    END IF;
    x_return_status := 'E';

WHEN OTHERS THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO prm_create_customer;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECTS_MAINT_PVT',
                            p_procedure_name => 'CREATE_CUSTOMER',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    raise;

END CREATE_CUSTOMER;

-- API name     : Update_project_basic_info
-- Type         : Public
-- Pre-reqs     : None.
-- Parameters           :
-- p_commit             IN VARCHAR2   Optional Default = FND_API.G_FALSE
-- p_validate_only      IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_validation_level   IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module     IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode         IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count      IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_project_id         IN NUMBER     Required
-- p_project_name       IN VARCHAR2   Required
-- p_project_number     IN VARCHAR2   Required
-- p_project_type       IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_description        IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_project_status_code IN VARCHAR2  Required
-- p_public_sector_flag  IN VARCHAR2  Required
-- p_carrying_out_organization_id IN NUMBER Optional
--                                   Default = FND_API.G_MISS_NUM
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
-- p_long_name          IN VARCHAR2   Optional Default = NULL
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
 p_commit                       IN VARCHAR2   := FND_API.G_FALSE       ,
 p_validate_only                IN VARCHAR2   := FND_API.G_TRUE        ,
 p_validation_level             IN NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_calling_module               IN VARCHAR2   := 'SELF_SERVICE'        ,
 p_debug_mode                   IN VARCHAR2   := 'N'                   ,
 p_max_msg_count                IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_project_id                   IN NUMBER                              ,
 p_project_name                 IN VARCHAR2                            ,
 p_project_number               IN VARCHAR2                            ,
 p_project_type                 IN VARCHAR2       ,
 p_description                  IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_project_status_code          IN VARCHAR2                            ,
 p_public_sector_flag           IN VARCHAR2                            ,
 p_carrying_out_organization_id IN NUMBER         ,
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
-- Dates changes
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

l_return_status            VARCHAR2(1);
l_dummy                    VARCHAR2(1);
l_error_msg_code           VARCHAR2(250);
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(250);
l_err_code                 VARCHAR2(250);
l_err_stage                VARCHAR2(250);
l_err_stack                VARCHAR2(250);
l_data                     VARCHAR2(250);
l_msg_index_out            NUMBER;
l_calling_module           VARCHAR2(100); -- bug7204572

l_project_name             PA_PROJECTS_ALL.NAME%TYPE;
l_project_number           PA_PROJECTS_ALL.SEGMENT1%TYPE;
l_project_type             PA_PROJECTS_ALL.PROJECT_TYPE%TYPE;
l_description              PA_PROJECTS_ALL.DESCRIPTION%TYPE;
l_project_status_code      PA_PROJECTS_ALL.PROJECT_STATUS_CODE%TYPE;
l_public_sector_flag       PA_PROJECTS_ALL.PUBLIC_SECTOR_FLAG%TYPE;
l_carrying_out_organization_id PA_PROJECTS_ALL.CARRYING_OUT_ORGANIZATION_ID%TYPE;
l_start_date               PA_PROJECTS_ALL.START_DATE%TYPE;
l_completion_date          PA_PROJECTS_ALL.COMPLETION_DATE%TYPE;
l_record_version_number    PA_PROJECTS_ALL.record_Version_number%TYPE;
l_attribute_category       PA_PROJECTS_ALL.attribute_category%TYPE;
l_attribute1               PA_PROJECTS_ALL.attribute1%TYPE;
l_attribute2               PA_PROJECTS_ALL.attribute2%TYPE;
l_attribute3               PA_PROJECTS_ALL.attribute3%TYPE;
l_attribute4               PA_PROJECTS_ALL.attribute4%TYPE;
l_attribute5               PA_PROJECTS_ALL.attribute5%TYPE;
l_attribute6               PA_PROJECTS_ALL.attribute6%TYPE;
l_attribute7               PA_PROJECTS_ALL.attribute7%TYPE;
l_attribute8               PA_PROJECTS_ALL.attribute8%TYPE;
l_attribute9               PA_PROJECTS_ALL.attribute9%TYPE;
l_attribute10              PA_PROJECTS_ALL.attribute10%TYPE;
l_priority_code            PA_PROJECTS_ALL.priority_code%TYPE;
-- anlee
-- Dates changes
l_target_start_date       PA_PROJECTS_ALL.TARGET_START_DATE%TYPE;
l_target_finish_date      PA_PROJECTS_ALL.TARGET_FINISH_DATE%TYPE;
-- End of changes

l_mass_adj_outcome            VARCHAR2(100);
l_batch_id                    NUMBER(25);
l_row_id                      VARCHAR2(25);
l_line_id                     NUMBER;
l_dummy1                      NUMBER;
l_dummy2                      NUMBER;
l_batch_name                  VARCHAR2(100);
l_batch_description           VARCHAR2(100);
l_project_rec           pa_projects%ROWTYPE;
l_old_organization_id         NUMBER;
cursor get_batch_name_csr
IS
SELECT meaning
FROM   pa_lookups
WHERE  lookup_type = 'TRANSLATION'
AND    lookup_code = 'MANUAL';

cursor get_batch_desc_csr
IS
SELECT meaning
FROM   pa_lookups
WHERE  lookup_type = 'TRANSLATION'
AND    lookup_code = 'MASS_UPDATE_BATCH_DESC';

CURSOR l_project_details_csr
IS
SELECT *
FROM    pa_projects p
WHERE  p.project_id = p_project_id;

CURSOR l_get_organization_csr
IS
SELECT carrying_out_organization_id
FROM pa_projects_all
WHERE project_id = p_project_id;

-- anlee
-- Ext Attribute changes
-- Bug 2904327
CURSOR l_get_project_type_id
IS
SELECT ppt.project_type_id
FROM pa_projects_all ppa, pa_project_types ppt
WHERE ppa.project_id = p_project_id
AND ppa.project_type = ppt.project_type;

l_old_project_type_id NUMBER;
l_new_project_type_id NUMBER;
-- anlee end of changes

-- 4199336 commented below code because of pjp dependancy issue
-- 4055319 Added for pjp api call
CURSOR c_template_flag
IS
SELECT template_flag
FROM pa_projects_all
WHERE project_id = p_project_id;

l_template_flag VARCHAR2(1);
-- 4055319 end


BEGIN

   IF p_commit = FND_API.G_TRUE
   THEN
      SAVEPOINT update_project_basic_info;
   END IF;


--dbms_output.put_line('Starts here UPDATE_PROJECT_BASIC_INFO  ... ');

      x_return_status := 'S';

      if (p_debug_mode = 'Y') then
         pa_debug.debug('UPDATE_PROJECT_BASIC_INFO: Calling validate_project_details.');
      end if;

-- Checking Locking Procedures.

      if (p_debug_mode = 'Y') then
         pa_debug.debug('Update_project_basic_info PVT: Locking record');
      end if;
      if p_validate_only <> FND_API.G_TRUE then
        BEGIN
           SELECT 'x' INTO l_dummy
           FROM  pa_projects
           WHERE project_id             = p_project_id
           AND record_version_number  = p_record_version_number
           FOR UPDATE OF record_version_number NOWAIT;
        EXCEPTION WHEN TIMEOUT_ON_RESOURCE THEN
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
               x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
               x_return_status := 'E' ;
           WHEN NO_DATA_FOUND THEN
            if p_calling_module = 'FORM' then
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                    p_msg_name       => 'FORM_RECORD_CHANGED');
               x_msg_data := 'FORM_RECORD_CHANGED';
            else
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_XC_RECORD_CHANGED');
               x_msg_data := 'PA_XC_RECORD_CHANGED';
            end if;
              x_return_status := 'E' ;
            WHEN OTHERS THEN
              IF SQLCODE = -54 THEN
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
                 x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
                 x_return_status := 'E' ;
              ELSE
                raise;
              END IF;
         END;
      else
         BEGIN
           SELECT 'x' INTO l_dummy
           FROM  pa_projects
           WHERE project_id             = p_project_id
           AND record_version_number  = p_record_version_number;
          EXCEPTION WHEN NO_DATA_FOUND THEN
            if p_calling_module = 'FORM' then
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                    p_msg_name       => 'FORM_RECORD_CHANGED');
               x_msg_data := 'FORM_RECORD_CHANGED';
            else
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_XC_RECORD_CHANGED');
               x_msg_data := 'PA_XC_RECORD_CHANGED';
            end if;
            x_return_status := 'E' ;
            WHEN OTHERS THEN
              IF SQLCODE = -54 THEN
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
                 x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
                 x_return_status := 'E' ;
              END IF;
          END;
      end if;
      l_msg_count := FND_MSG_PUB.count_msg;

      IF l_msg_count > 0 THEN
         x_msg_count := l_msg_count;
         x_return_status := 'E';
         RAISE  FND_API.G_EXC_ERROR;
      END IF;

   if p_validation_level > 0 then
      pa_debug.G_err_stage := 'Calling Validate_Basic_Info';

      if (p_debug_mode = 'Y') then
         pa_debug.debug('Update_project_basic_info PVT: Calling validate project info API');
      end if;

--Code starts for bug 7204572
  l_calling_module := p_calling_module;

  if (NVL(l_calling_module,'NO_CM') <> 'SETUP_PAGE') then
    l_calling_module := 'BASIC_INFO';
  end if;
--Code ends for bug 7204572

      PA_PROJECTS_MAINT_PVT.Validate_Project_Info
      (
       p_validation_level             => p_validation_level,
       p_calling_module               => l_calling_module,  -- bug 7204572 changed 'BASIC_INFO' to l_calling_module
       p_debug_mode                   => p_debug_mode,
       p_action                       => 'UPDATE',
       p_max_msg_count                => p_max_msg_count,
       p_project_id                   => p_project_id,
       p_project_name                 => p_project_name,
       p_project_number               => p_project_number,
       p_project_type                 => p_project_type,
       p_description                  => p_description,
       p_project_status_code          => p_project_status_code,
       p_public_sector_flag           => p_public_sector_flag,
       p_carrying_out_organization_id => p_carrying_out_organization_id,
       p_start_date                   => p_start_date,
       p_completion_date              => p_completion_date,
       p_territory_code               => p_territory_code,
       p_country                      => p_country,
       p_location_id                  => p_location_id,
       p_state_region                 => p_state_region,
       p_city                         => p_city,
       p_record_version_number        => p_record_version_number,
-- anlee
-- Dates changes
       p_target_start_date           => p_target_start_date,
       p_target_finish_date          => p_target_finish_date,
-- End of changes
-- anlee
-- Project Long Name changes
       p_long_name                   => p_long_name );
-- End of changes

        l_msg_count := FND_MSG_PUB.count_msg;

        IF l_msg_count > 0 THEN
         x_msg_count := l_msg_count;
         x_return_status := 'E';
         RAISE  FND_API.G_EXC_ERROR;
        END IF;
      END IF;

      if (NOT FND_API.TO_BOOLEAN (p_validate_only)) then
        if p_project_name = FND_API.G_MISS_CHAR
        then
          l_project_name  := null;
        else
          l_project_name   := p_project_name;
        end if;

        if p_project_number = FND_API.G_MISS_CHAR
        then
           l_project_number  := null;
        else
           l_project_number  := p_project_number;
        end if;

        if p_project_type = FND_API.G_MISS_CHAR
        then
          l_project_type  := null;
        else
          l_project_type  := p_project_type;
        end if;

        if p_description = FND_API.G_MISS_CHAR
        then
          l_description  := null;
        else
          l_description   := p_description;
        end if;

        if p_priority_code = FND_API.G_MISS_CHAR
        then
          l_priority_code  := null;
        else
          l_priority_code   := p_priority_code;
        end if;

        if p_project_Status_code = FND_API.G_MISS_CHAR
        then
           l_project_status_code := null;
        else
           l_project_status_code := p_project_status_code;
        end if;

        if p_public_Sector_Flag = FND_API.G_MISS_CHAR
        then
          l_public_sector_flag := null;
        else
          l_public_sector_flag := p_public_Sector_flag;
        end if;
--dbms_output.put_line('Before UPDATE PA_PROJECTS_ALL Status : ');

        if p_carrying_out_organization_id = FND_API.G_MISS_NUM
        then
          l_carrying_out_organization_id := null;
        else
          l_carrying_out_organization_id := p_carrying_out_organization_id;
        end if;

        if p_start_date = FND_API.G_MISS_DATE
        then
          l_start_date := null;
        else
          l_start_date  := p_start_date;
        end if;

       if p_completion_date = FND_API.G_MISS_DATE
       then
         l_completion_Date := null;
       else
         l_completion_date  := p_completion_date;
       end if;
     /*
      if p_record_Version_number = FND_API.G_MISS_NUM
      then
        l_record_version_number := null;
      else
       l_record_version_number  := p_carrying_out_organization_id;
      end if;
    */

     if p_attribute_category = FND_API.G_MISS_CHAR
       then
         l_attribute_category := null;
       else
         l_attribute_category  := p_attribute_category;
     end if;

     if p_attribute1 = FND_API.G_MISS_CHAR
       then
         l_attribute1 := null;
       else
         l_attribute1  := p_attribute1;
     end if;

     if p_attribute2 = FND_API.G_MISS_CHAR
       then
         l_attribute2 := null;
       else
         l_attribute2  := p_attribute2;
     end if;

     if p_attribute3 = FND_API.G_MISS_CHAR
       then
         l_attribute3 := null;
       else
         l_attribute3  := p_attribute3;
     end if;

     if p_attribute4 = FND_API.G_MISS_CHAR
       then
         l_attribute4 := null;
       else
         l_attribute4  := p_attribute4;
     end if;

     if p_attribute5 = FND_API.G_MISS_CHAR
       then
         l_attribute5 := null;
       else
         l_attribute5  := p_attribute5;
     end if;

     if p_attribute6 = FND_API.G_MISS_CHAR
       then
         l_attribute6 := null;
       else
         l_attribute6  := p_attribute6;
     end if;

     if p_attribute7 = FND_API.G_MISS_CHAR
       then
         l_attribute7 := null;
       else
         l_attribute7  := p_attribute7;
     end if;

     if p_attribute8 = FND_API.G_MISS_CHAR
       then
         l_attribute8 := null;
       else
         l_attribute8  := p_attribute8;
     end if;

     if p_attribute9 = FND_API.G_MISS_CHAR
       then
         l_attribute9 := null;
       else
         l_attribute9  := p_attribute9;
     end if;

     if p_attribute10 = FND_API.G_MISS_CHAR
       then
         l_attribute10 := null;
       else
         l_attribute10  := p_attribute10;
     end if;

-- anlee
-- Dates changes
     if p_target_start_date = FND_API.G_MISS_DATE
       then
         l_target_start_date := null;
       else
         l_target_start_date  := p_target_start_date;
     end if;

     if p_target_finish_date = FND_API.G_MISS_DATE
       then
         l_target_finish_date := null;
       else
         l_target_finish_date  := p_target_finish_date;
     end if;
-- End of changes

     OPEN l_get_organization_csr;
     FETCH l_get_organization_csr INTO l_old_organization_id;
     CLOSE l_get_organization_csr;

     -- anlee
     -- Ext Attribute changes
     -- Bug 2904327
     OPEN  l_get_project_type_id;
     FETCH l_get_project_type_id into l_old_project_type_id;
     CLOSE l_get_project_type_id;
     -- anlee end of changes

      if (p_debug_mode = 'Y') then
         pa_debug.debug('Update_project_basic_info PVT: upating pa_projects table');
      end if;

        UPDATE PA_PROJECTS
        SET name                         = l_project_name,
            segment1                     = l_project_number,
            project_type                 = l_project_type,
            description                  = l_description,
            project_status_code          = l_project_status_code,
            public_sector_flag           = l_public_sector_flag,
            carrying_out_organization_id = l_carrying_out_organization_id,
            start_date                   = l_start_date,
            completion_date              = l_completion_date,
--            location_id                  = p_location_id,
--            calendar_id                  = p_calendar_id,
            priority_code                  = l_priority_code,
            attribute_category           = l_attribute_category,
            attribute1                   = l_attribute1,
            attribute2                   = l_attribute2,
            attribute3                   = l_attribute3,
            attribute4                   = l_attribute4,
            attribute5                   = l_attribute5,
            attribute6                   = l_attribute6,
            attribute7                   = l_attribute7,
            attribute8                   = l_attribute8,
            attribute9                   = l_attribute9,
            attribute10                  = l_attribute10,
            record_version_number        = record_version_number + 1,
-- anlee
-- Dates changes
            last_update_date             = sysdate,
            last_updated_by              = fnd_global.user_id,
            last_update_login            = fnd_global.login_id,
            target_start_date           = l_target_start_date,
            target_finish_date          = l_target_finish_date,
-- End of changes
-- anlee Project Long Name changes
            long_name                   = p_long_name,
-- End of changes
            funding_approval_status_code = p_funding_approval_status, -- 4055319
            security_level              = p_security_level
        WHERE project_id = p_project_id;


        -- 4199336 commented below because of pjp dependancy issue

        -- 4055319 : When ever a project is created or updated in PJT, it may be considered for funding approval,
        -- i.e. Submitted to PJP. below API from PJP is called to achieve this.

        BEGIN
            OPEN  c_template_flag;
            FETCH c_template_flag INTO l_template_flag;
            CLOSE c_template_flag;

            IF l_template_flag = 'N' THEN
              PA_PJP_PVT.Submit_Project_Aw -- Changed from FPA_PROCESS_PVT to PA_PJP_PVT package
              (
                 p_api_version          => 1.0
                ,p_init_msg_list        => FND_API.G_FALSE
                ,p_commit               => FND_API.G_FALSE
                ,p_project_id           => p_project_id
                ,x_return_status        => l_return_status
                ,x_msg_count            => l_msg_count
                ,x_msg_data             => l_msg_data
              );
            END IF;

        EXCEPTION WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECTS_MAINT_PUB',
                                    p_procedure_name => 'UPDATE_PROJECT_BASIC_INFO',
                                    p_error_text     => SUBSTRB(SQLERRM,1,240));
            rollback to copy_project;
            return;
        END;

        -- 4055319 end

        -- 4199336 end

        -- anlee
        -- Added for intermedia search
        PA_PROJECT_CTX_SEARCH_PVT.UPDATE_ROW (
         p_project_id           => p_project_id
        ,p_template_flag        => 'N'
        ,p_project_name         => l_project_name
        ,p_project_number       => l_project_number
        ,p_project_long_name    => p_long_name
        ,p_project_description  => l_description
        ,x_return_status        => l_return_status );

        l_msg_count := FND_MSG_PUB.count_msg;

        IF l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
          x_return_status := 'E';
          RAISE  FND_API.G_EXC_ERROR;
        END IF;
        -- anlee end of changes

        -- anlee
        -- Ext Attribute changes
        -- Bug 2904327
        OPEN  l_get_project_type_id;
        FETCH l_get_project_type_id into l_new_project_type_id;
        CLOSE l_get_project_type_id;

        PA_USER_ATTR_PUB.DELETE_USER_ATTRS_DATA (
         p_validate_only             => FND_API.G_FALSE
        ,p_project_id                => p_project_id
        ,p_old_classification_id     => l_old_project_type_id
        ,p_new_classification_id     => l_new_project_type_id
        ,p_classification_type       => 'PROJECT_TYPE'
        ,x_return_status             => l_return_status
        ,x_msg_count                 => l_msg_count
        ,x_msg_data                  => l_msg_data );

        l_msg_count := FND_MSG_PUB.count_msg;

        IF l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
          x_return_status := 'E';
          RAISE  FND_API.G_EXC_ERROR;
        END IF;
        -- anlee end of changes

    -- hyau
    -- Added validations for recalc if CDLs, txns, or revenues exist
    IF p_recalculate_flag = 'Y' then

         OPEN  l_project_details_csr;
             FETCH l_project_details_csr INTO l_project_rec;
                 CLOSE l_project_details_csr;

                 PA_ADJUSTMENTS.MassAdjust(
                  x_adj_action            => 'COST AND REV RECALC'
                 ,x_module                => 'PAXPREPR'
                 ,x_user                  => fnd_global.user_id
                 ,x_login                 => fnd_global.login_id
                 ,x_project_id            => p_project_id
                 ,x_dest_prj_id           => NULL
                 ,x_dest_task_id          => NULL
                 ,x_project_currency_code => l_project_rec.project_currency_code
                 ,x_project_rate_type     => l_project_rec.project_rate_type
                 ,x_project_rate_date     => l_project_rec.project_rate_date
                 ,x_project_exchange_rate => NULL
                 ,x_task_id               => NULL
                 ,x_inc_by_person_id      => NULL
                 ,x_inc_by_org_id         => NULL
                 ,x_ei_date_low           => SYSDATE /* 8242683 */
                 ,x_ei_date_high          => NULL
                 ,x_ex_end_date_low       => NULL
                 ,x_ex_end_date_high      => NULL
                 ,x_system_linkage        => NULL
                 ,x_expenditure_type      => NULL
                 ,x_expenditure_catg      => NULL
                 ,x_expenditure_group     => NULL
                 ,x_vendor_id             => NULL
                 ,x_job_id                => NULL
                 ,x_nl_resource_org_id    => NULL
                 ,x_nl_resource           => NULL
                 ,x_transaction_source    => NULL
                 ,x_cost_distributed_flag => NULL
                 ,x_revenue_distributed_flag => NULL
                 ,x_grouped_cip_flag      => NULL
                 ,x_bill_status           => NULL
                 ,x_hold_flag             => NULL
                 ,x_billable_flag         => NULL
                 ,x_capitalizable_flag    => NULL
                 ,x_net_zero_adjust_flag  => NULL
                 ,x_inv_num               => NULL
                 ,x_inv_line_num          => NULL
                 ,x_outcome               => l_mass_adj_outcome
                 ,x_num_processed         => l_dummy1
                 ,x_num_rejected          => l_dummy2 );

                 OPEN get_batch_name_csr;
                 FETCH get_batch_name_csr INTO l_batch_name;
                 CLOSE get_batch_name_csr;

                 OPEN get_batch_desc_csr;
                 FETCH get_batch_desc_csr INTO l_batch_description;
                 CLOSE get_batch_desc_csr;

                 PA_MU_BATCHES_V_PKG.INSERT_ROW(
                  x_rowid                  => l_row_id
                 ,x_batch_id               => l_batch_id
                 ,x_creation_date          => l_project_rec.last_update_date
                 ,x_created_by             => l_project_rec.last_updated_by
                 ,x_last_updated_by        => l_project_rec.last_updated_by
                 ,x_last_update_date       => l_project_rec.last_update_date
                 ,x_last_update_login      => l_project_rec.last_update_login
                 ,x_batch_name             => l_batch_name
                 ,x_batch_status_code      => 'C'
                 ,x_description            => l_batch_description
                 ,x_project_attribute      => 'ORGANIZATION'
                 ,x_effective_date         => trunc(sysdate)
                 ,x_attribute_category     => NULL
                 ,x_attribute1             => NULL
                 ,x_attribute2             => NULL
                 ,x_attribute3             => NULL
                 ,x_attribute4             => NULL
                 ,x_attribute5             => NULL
                 ,x_attribute6             => NULL
                 ,x_attribute7             => NULL
                 ,x_attribute8             => NULL
                 ,x_attribute9             => NULL
                 ,x_attribute10            => NULL
                 ,x_attribute11            => NULL
                 ,x_attribute12            => NULL
                 ,x_attribute13            => NULL
                 ,x_attribute14            => NULL
                 ,x_attribute15            => NULL );

                 UPDATE PA_MASS_UPDATE_BATCHES
                 SET batch_name = substr(l_batch_name,1,20)||'-'||to_char(l_batch_id)
                 WHERE rowid = l_row_id;

                 PA_MU_DETAILS_V_PKG.INSERT_ROW(
                  x_rowid                 => l_row_id
                 ,x_line_id               => l_line_id
                 ,x_batch_id              => l_batch_id
                 ,x_creation_date         => l_project_rec.last_update_date
                 ,x_created_by            => l_project_rec.last_updated_by
                 ,x_last_updated_by       => l_project_rec.last_updated_by
                 ,x_last_update_date      => l_project_rec.last_update_date
                 ,x_last_update_login     => l_project_rec.last_update_login
                 ,x_project_id            => p_project_id
                 ,x_task_id               => NULL
                 ,x_old_attribute_value   => to_char(l_old_organization_id)
                 ,x_new_attribute_value   => to_char(p_carrying_out_organization_id)
                 ,x_update_flag           => 'Y'
                 ,x_recalculate_flag      => 'Y' );

    END IF; -- if p_recalculate_flag = 'Y'

     end if;

     IF FND_API.TO_BOOLEAN(P_COMMIT)
     THEN
        COMMIT WORK;
     END IF;

EXCEPTION WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO update_project_basic_info;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECTS_MAINT_PVT',
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
-- p_commit             IN VARCHAR2   Optional Default = FND_API.G_FALSE
-- p_validate_only      IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_validation_level   IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module     IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode         IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count      IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_project_id         IN NUMBER     Required
-- p_calendar_id        IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_work_type_id       IN NUMBER
-- p_role_list_id       IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_cost_job_group_id  IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_bill_job_group_id  IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_record_version_number  IN NUMBER Required
-- x_return_status     OUT VARCHAR2   Required
-- x_msg_count         OUT NUMBER     Required
-- x_msg_data          OUT VARCHAR2   Required
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--           02-Sep-2008      Bug 7286976 : Added WHO columns while updating pa_projects
--
--
PROCEDURE UPDATE_PROJECT_ADDITIONAL_INFO
(
 p_commit                       IN VARCHAR2   := FND_API.G_FALSE       ,
 p_validate_only                IN VARCHAR2     := FND_API.G_TRUE        ,
 p_validation_level             IN NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_calling_module               IN VARCHAR2   := 'SELF_SERVICE'        ,
 p_debug_mode                   IN VARCHAR2   := 'N',
 p_max_msg_count                IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_project_id                   IN NUMBER                              ,
 p_calendar_id                  IN NUMBER     := FND_API.G_MISS_NUM    ,
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
 p_sys_program_flag  IN varchar2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_allow_multi_prog_rollup IN varchar2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 x_return_status                OUT NOCOPY VARCHAR2                           , --File.Sql.39 bug 4440895
 x_msg_count                    OUT NOCOPY NUMBER                             , --File.Sql.39 bug 4440895
 x_msg_data                     OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS


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

l_record_version_number  PA_PROJECTS_ALL.RECORD_VERSION_NUMBER%TYPE;
l_calendar_id            PA_PROJECTS_ALL.CALENDAR_ID%TYPE;
l_work_type_id           PA_PROJECTS_ALL.WORK_TYPE_ID%TYPE;
l_role_list_id           PA_PROJECTS_ALL.ROLE_LIST_ID%TYPE;
l_cost_job_group_id      PA_PROJECTS_ALL.COST_JOB_GROUP_ID%TYPE;
l_bill_job_group_id      PA_PROJECTS_ALL.BILL_JOB_GROUP_ID%TYPE;
l_split_cost_from_wokplan_flag PA_PROJECTS_ALL.split_cost_from_workplan_flag%TYPE;
l_split_cost_from_bill_flag     PA_PROJECTS_ALL.split_cost_from_bill_flag%TYPE;

l_project_name           PA_PROJECTS_ALL.NAME%TYPE;
l_project_number         PA_PROJECTS_ALL.SEGMENT1%TYPE;
l_project_description    PA_PROJECTS_ALL.DESCRIPTION%TYPE;
l_old_split              PA_PROJECTS_ALL.SPLIT_COST_FROM_WORKPLAN_FLAG%TYPE;

l_old_calendar_id        PA_PROJECTS_ALL.CALENDAR_ID%TYPE;

l_attribute_category       PA_PROJECTS_ALL.attribute_category%TYPE;
l_attribute1               PA_PROJECTS_ALL.attribute1%TYPE;
l_attribute2               PA_PROJECTS_ALL.attribute2%TYPE;
l_attribute3               PA_PROJECTS_ALL.attribute3%TYPE;
l_attribute4               PA_PROJECTS_ALL.attribute4%TYPE;
l_attribute5               PA_PROJECTS_ALL.attribute5%TYPE;
l_attribute6               PA_PROJECTS_ALL.attribute6%TYPE;
l_attribute7               PA_PROJECTS_ALL.attribute7%TYPE;
l_attribute8               PA_PROJECTS_ALL.attribute8%TYPE;
l_attribute9               PA_PROJECTS_ALL.attribute9%TYPE;
l_attribute10              PA_PROJECTS_ALL.attribute10%TYPE;

--FPM Changes
--l_sys_program_flag             PA_PROJECTS_ALL.sys_program_flag%TYPE;
--l_allow_multi_program_rollup   PA_PROJECTS_ALL.sys_program_flag%TYPE;
--l_proj_sys_program_flag        PA_PROJECTS_ALL.sys_program_flag%TYPE;
--l_proj_allow_program_rollup   PA_PROJECTS_ALL.sys_program_flag%TYPE;
--l_flag                         VARCHAR2(1);


CURSOR l_get_project_attrs_csr
IS
SELECT name, segment1, description, split_cost_from_workplan_flag, calendar_id
--,sys_program_flag,allow_multi_program_rollup
FROM PA_PROJECTS_ALL
WHERE project_id = p_project_id;

BEGIN

   IF p_commit = FND_API.G_TRUE THEN
      SAVEPOINT update_project_additional_info;
   END IF;

-- write your program logic from here

      if (p_debug_mode = 'Y') then
         pa_debug.debug('Update_project_additional_info PVT: locking record');
      end if;

   if p_validate_only <> FND_API.G_TRUE then
     BEGIN
         SELECT 'x' INTO l_dummy
         FROM  pa_projects
         WHERE project_id             = p_project_id
           AND record_version_number  = p_record_version_number
           FOR UPDATE OF record_version_number NOWAIT;
         EXCEPTION WHEN TIMEOUT_ON_RESOURCE THEN
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
               x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
               x_return_status := 'E' ;
           WHEN NO_DATA_FOUND THEN
            if p_calling_module = 'FORM' then
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                    p_msg_name       => 'FORM_RECORD_CHANGED');
               x_msg_data := 'FORM_RECORD_CHANGED';
            else
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_XC_RECORD_CHANGED');
               x_msg_data := 'PA_XC_RECORD_CHANGED';
            end if;
            x_return_status := 'E' ;
            WHEN OTHERS THEN
              IF SQLCODE = -54 THEN
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
                 x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
                 x_return_status := 'E' ;
              ELSE
                 RAISE;
              END IF;
      END;
   else

     BEGIN
         SELECT 'x' INTO l_dummy
         FROM  pa_projects
         WHERE project_id             = p_project_id
           AND record_version_number  = p_record_version_number;
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
            if p_calling_module = 'FORM' then
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                    p_msg_name       => 'FORM_RECORD_CHANGED');
               x_msg_data := 'FORM_RECORD_CHANGED';
            else
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_XC_RECORD_CHANGED');
               x_msg_data := 'PA_XC_RECORD_CHANGED';
            end if;
            x_return_status := 'E' ;
            WHEN OTHERS THEN
              IF SQLCODE = -54 THEN
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
                 x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
                 x_return_status := 'E' ;
              Else
                 raise;
              END IF;
        END;
    end if;
      l_msg_count := FND_MSG_PUB.count_msg;

      IF l_msg_count > 0 THEN
         x_msg_count := l_msg_count;
         x_return_status := 'E';
         RAISE  FND_API.G_EXC_ERROR;
      END IF;

-- write your program logic from here

--dbms_output.put_line('PA_PROJECTS_MAINT_PVT.VALIDATE_PROJECT_INFO Project Data ');

   if p_validation_level > 0 then
      pa_debug.G_err_stage := 'Calling  validate additional Info';
      if (p_debug_mode = 'Y') then
         pa_debug.debug('Update_project_additional_info PVT: Calling validate project info API');
      end if;
      PA_PROJECTS_MAINT_PVT.VALIDATE_PROJECT_INFO
     (
       p_validation_level             => p_validation_level,
       p_calling_module               => 'ADDITIONAL_INFORMATION',
       p_action                           => 'UPDATE',
       p_debug_mode                   => p_debug_mode,
       p_max_msg_count                => p_max_msg_count,
       p_project_id                   => p_project_id,
       p_calendar_id                  => p_calendar_id,
       p_work_type_id                 => p_work_type_id,
       p_role_list_id                 => p_role_list_id,
       p_cost_job_group_id            => p_cost_job_group_id,
       p_bill_job_group_id            => p_bill_job_group_id,
       p_record_version_number        => p_record_version_number);

      l_msg_count := FND_MSG_PUB.count_msg;

      IF l_msg_count > 0 THEN
         x_msg_count := l_msg_count;
         x_return_status := 'E';
         RAISE  FND_API.G_EXC_ERROR;
      END IF;
  END IF;

  IF NOT FND_API.TO_BOOLEAN(p_validate_only)
  THEN
      if (p_debug_mode = 'Y') then
         pa_debug.debug('Update_project_additional_info PVT: updating pa_projects table');
      end if;
       /* if p_record_version_number = FND_API.G_MISS_NUM
        then
          l_record_version_number := 0;
        else
          l_record_version_number := p_record_version_number;
        end if;
       */
        if p_calendar_id= FND_API.G_MISS_NUM
        then
          l_calendar_id := null;
        else
          l_calendar_id := p_calendar_id ;
        end if;

        if p_work_type_id = FND_API.G_MISS_NUM
        then
          l_work_type_id := null;
        else
          l_work_type_id := p_work_type_id;
        end if;

        if p_role_list_id = FND_API.G_MISS_NUM
        then
          l_role_list_id := null;
        else
          l_role_list_id := p_role_list_id;
        end if;

        if p_cost_job_Group_id = FND_API.G_MISS_NUM
        then
          l_cost_job_group_id := null;
        else
          l_cost_job_group_id := p_cost_job_group_id;
        end if;

        if p_bill_job_Group_id = FND_API.G_MISS_NUM
        then
          l_bill_job_group_id := null;
        else
          l_bill_job_group_id := p_bill_job_group_id;
        end if;

        if p_split_cost_from_wokplan_flag = FND_API.G_MISS_CHAR
        then
          l_split_cost_from_wokplan_flag := null;
        else
          l_split_cost_from_wokplan_flag := p_split_cost_from_wokplan_flag;
        end if;

        if p_split_cost_from_bill_flag = FND_API.G_MISS_CHAR
        then
          l_split_cost_from_bill_flag := null;
        else
          l_split_cost_from_bill_flag := p_split_cost_from_bill_flag;
        end if;

     if p_attribute_category = FND_API.G_MISS_CHAR
       then
         l_attribute_category := null;
       else
         l_attribute_category  := p_attribute_category;
     end if;

     if p_attribute1 = FND_API.G_MISS_CHAR
       then
         l_attribute1 := null;
       else
         l_attribute1  := p_attribute1;
     end if;

     if p_attribute2 = FND_API.G_MISS_CHAR
       then
         l_attribute2 := null;
       else
         l_attribute2  := p_attribute2;
     end if;

     if p_attribute3 = FND_API.G_MISS_CHAR
       then
         l_attribute3 := null;
       else
         l_attribute3  := p_attribute3;
     end if;

     if p_attribute4 = FND_API.G_MISS_CHAR
       then
         l_attribute4 := null;
       else
         l_attribute4  := p_attribute4;
     end if;

     if p_attribute5 = FND_API.G_MISS_CHAR
       then
         l_attribute5 := null;
       else
         l_attribute5  := p_attribute5;
     end if;

     if p_attribute6 = FND_API.G_MISS_CHAR
       then
         l_attribute6 := null;
       else
         l_attribute6  := p_attribute6;
     end if;

     if p_attribute7 = FND_API.G_MISS_CHAR
       then
         l_attribute7 := null;
       else
         l_attribute7  := p_attribute7;
     end if;

     if p_attribute8 = FND_API.G_MISS_CHAR
       then
         l_attribute8 := null;
       else
         l_attribute8  := p_attribute8;
     end if;

     if p_attribute9 = FND_API.G_MISS_CHAR
       then
         l_attribute9 := null;
       else
         l_attribute9  := p_attribute9;
     end if;

     if p_attribute10 = FND_API.G_MISS_CHAR
       then
         l_attribute10 := null;
       else
         l_attribute10  := p_attribute10;
     end if;
/*
    If p_sys_program_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
         l_sys_program_flag := null;
    else
         l_sys_program_flag := p_sys_program_flag;
   end if;

    If p_allow_multi_prog_rollup = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
         l_allow_multi_program_rollup :=null;
    else
         l_allow_multi_program_rollup :=p_allow_multi_prog_rollup;
    end if;
*/
      OPEN l_get_project_attrs_csr;
      FETCH l_get_project_attrs_csr INTO l_project_name, l_project_number, l_project_description, l_old_split,
            l_old_calendar_id;
            -- ,l_proj_sys_program_flag,l_proj_allow_program_rollup;
      CLOSE l_get_project_attrs_csr;

      if l_old_split <> l_split_cost_from_wokplan_flag then
        PA_PROJ_TASK_STRUC_PUB.create_delete_workplan_struc(
         p_calling_module        => p_calling_module
        ,p_project_id            => p_project_id
        ,p_project_number        => l_project_number
        ,p_project_name          => l_project_name
        ,p_project_description   => l_project_description
        ,p_split_workplan        => l_split_cost_from_wokplan_flag
        ,x_msg_count             => l_msg_count
        ,x_msg_data              => l_msg_data
        ,x_return_status         => l_return_status);

        l_msg_count := FND_MSG_PUB.count_msg;

        IF l_msg_count > 0 THEN
           x_msg_count := l_msg_count;
           x_return_status := 'E';
           RAISE  FND_API.G_EXC_ERROR;
        END IF;
      end if;

--hsiu
--added for workplan changes
      IF (l_old_calendar_id <> l_calendar_id) THEN
        PA_PROJECT_STRUCTURE_PVT1.update_wp_calendar(
          p_project_id => p_project_id
         ,p_calendar_id => l_calendar_id
         ,x_return_status => l_return_status
         ,x_msg_count => l_msg_count
         ,x_msg_data => l_msg_data
        );

        l_msg_count := FND_MSG_PUB.count_msg;

        IF l_msg_count > 0 THEN
           x_msg_count := l_msg_count;
           x_return_status := 'E';
           RAISE  FND_API.G_EXC_ERROR;
        END IF;

      END IF;
--end workplan changes

--Added for FPM Changes for Project Relationships
/*
    IF (l_proj_sys_program_flag='Y' and nvl(l_sys_program_flag,'N')='N' ) then
        l_flag := PA_RELATIONSHIP_UTILS.DISABLE_SYS_PROG_OK(p_project_id);

         If l_flag='N' Then
          Pa_Utils.ADD_MESSAGE
                ( p_app_short_name => 'PA',
                  p_msg_name     =>'PA_PS_DIS_SYS_PROG_ERR');
           RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

     IF (l_proj_allow_program_rollup='Y' and nvl(l_allow_multi_program_rollup,'N')='N' ) then
        l_flag := PA_RELATIONSHIP_UTILS.DISABLE_MULTI_PROG_OK(p_project_id);

          IF l_flag ='N' Then
           Pa_Utils.ADD_MESSAGE
                ( p_app_short_name => 'PA',
                  p_msg_name     =>'PA_PS_DIS_MULTI_PROG_ERR');
           RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;
*/
      UPDATE pa_projects
      SET record_version_number = record_version_number +1,
          attribute_category           = l_attribute_category,
          attribute1                   = l_attribute1,
          attribute2                   = l_attribute2,
          attribute3                   = l_attribute3,
          attribute4                   = l_attribute4,
          attribute5                   = l_attribute5,
          attribute6                   = l_attribute6,
          attribute7                   = l_attribute7,
          attribute8                   = l_attribute8,
          attribute9                   = l_attribute9,
          attribute10                  = l_attribute10,
          calendar_id           = l_calendar_id    ,
          work_type_id          = l_work_type_id   ,
          role_list_id          = l_role_list_id   ,
          split_cost_from_workplan_flag = l_split_cost_from_wokplan_flag,
          split_cost_from_bill_flag = l_split_cost_from_bill_flag,
          cost_job_group_id     = l_cost_job_group_id ,
          bill_job_group_id     = l_bill_job_group_id ,
          -- Added WHO columns for Bug 7286976
          last_update_date             = sysdate,
          last_updated_by              = fnd_global.user_id,
          last_update_login            = fnd_global.login_id
--,
--          sys_program_flag      = l_sys_program_flag,
--          allow_multi_program_rollup = l_allow_multi_program_rollup
      WHERE project_id = p_project_id;


  END IF;

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
       ROLLBACK TO prm_create_project;
    END IF;
    x_return_status := 'E';

WHEN OTHERS THEN
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
-- p_commit             IN VARCHAR2   Optional Default = FND_API.G_FALSE
-- p_validate_only      IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_validation_level   IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module     IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode         IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count      IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_project_id         IN NUMBER     Required
-- p_probability_member_id  IN NUMBER Optional Default = FND_API.G_MISS_NUM
-- p_project_value          IN NUMBER Optional Default = FND_API.G_MISS_NUM
-- p_expected_approval_date IN DATE   Required
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
( p_commit                       IN VARCHAR2   := FND_API.G_FALSE       ,
 p_validate_only                IN VARCHAR2     := FND_API.G_TRUE        ,
 p_validation_level             IN NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_calling_module               IN VARCHAR2   := 'SELF_SERVICE'        ,
 p_debug_mode                   IN VARCHAR2   := 'N',
 p_max_msg_count                IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_project_id                   IN NUMBER                              ,
 p_probability_member_id        IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_project_value                IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_expected_approval_date       IN DATE                                ,
 p_record_version_number        IN NUMBER                              ,
 x_return_status                OUT NOCOPY VARCHAR2                           , --File.Sql.39 bug 4440895
 x_msg_count                    OUT NOCOPY NUMBER                             , --File.Sql.39 bug 4440895
 x_msg_data                     OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

l_msg_count                     NUMBER;
l_msg_index_out                 NUMBER;
l_msg_data                            VARCHAR2(250);
l_data                          VARCHAR2(250);
l_dummy                         VARCHAR2(1);

l_probability_member_id  PA_PROJECTS_ALL.PROBABILITY_MEMBER_ID%TYPE;
l_project_value          PA_PROJECTS_ALL.PROJECT_VALUE%TYPE;
l_expected_approval_date PA_PROJECTS_ALL.EXPECTED_APPROVAL_DATE%TYPE;
BEGIN

    IF p_commit = FND_API.G_TRUE THEN
       SAVEPOINT update_project_pipeline_info;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

      if (p_debug_mode = 'Y') then
         pa_debug.debug('Update_project_pipeline_info PVT: locking record');
      end if;
  -- write your program logic from here
   if p_validate_only <> FND_API.G_TRUE then
     BEGIN
         SELECT 'x' INTO l_dummy
         FROM  pa_projects_all    -- Bug#3807805 : Modifed pa_projects to pa_projects_all
         WHERE project_id             = p_project_id
           AND record_version_number  = p_record_version_number
           FOR UPDATE OF record_version_number NOWAIT;
         EXCEPTION WHEN TIMEOUT_ON_RESOURCE THEN
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
               x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
               x_return_status := 'E' ;
           WHEN NO_DATA_FOUND THEN
            if p_calling_module = 'FORM' then
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                    p_msg_name       => 'FORM_RECORD_CHANGED');
               x_msg_data := 'FORM_RECORD_CHANGED';
            else
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_XC_RECORD_CHANGED');
               x_msg_data := 'PA_XC_RECORD_CHANGED';
            end if;
            x_return_status := 'E' ;
            WHEN OTHERS THEN
              IF SQLCODE = -54 THEN
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
                 x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
                 x_return_status := 'E' ;
              ELSE
                raise;
              END IF;
       END;
   else
     BEGIN
         SELECT 'x' INTO l_dummy
         FROM  pa_projects_all    -- Bug#3807805 : Modifed pa_projects to pa_projects_all
         WHERE project_id             = p_project_id
           AND record_version_number  = p_record_version_number;
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
            if p_calling_module = 'FORM' then
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                    p_msg_name       => 'FORM_RECORD_CHANGED');
               x_msg_data := 'FORM_RECORD_CHANGED';
            else
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_XC_RECORD_CHANGED');
               x_msg_data := 'PA_XC_RECORD_CHANGED';
            end if;
            x_return_status := 'E' ;
            WHEN OTHERS THEN
              IF SQLCODE = -54 THEN
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
                 x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
                 x_return_status := 'E' ;
              ELSE
                  raise;
              END IF;
       END;
   end if;
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE  FND_API.G_EXC_ERROR;
   END IF;

   if p_validation_level > 0 then
      pa_debug.G_err_stage := 'Calling  validate pipeline Info';
      if (p_debug_mode = 'Y') then
      pa_debug.debug('Update_project_pipeline_info PVT: Calling validate project API');
      end if;
      PA_PROJECTS_MAINT_PVT.VALIDATE_PROJECT_INFO
     ( p_validation_level             => p_validation_level,
       p_calling_module               => 'PIPELINE',
       p_action                       => 'UPDATE',
       p_debug_mode                   => p_debug_mode,
       p_max_msg_count                => p_max_msg_count,
       p_project_id                   => p_project_id,
       p_probability_member_id        => p_probability_member_id,
       p_project_value                => p_project_value,
       p_expected_approval_date       => p_expected_approval_date,
       p_record_version_number        => p_record_version_number);

      l_msg_count := FND_MSG_PUB.count_msg;

      IF l_msg_count > 0 THEN
         x_msg_count := l_msg_count;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         RAISE  FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   IF NOT FND_API.TO_BOOLEAN(p_validate_only)
   THEN
   if (p_debug_mode = 'Y') then
      pa_debug.debug('Update_project_pipeline_info PVT: update pa_projects table');
    end if;
        if p_probability_member_id = FND_API.G_MISS_NUM
        then
          l_probability_member_id := null;
        else
          l_probability_member_id := p_probability_member_id;
        end if;

        if p_project_Value = FND_API.G_MISS_NUM
        then
          l_project_value := null;
        else
          l_project_value := p_project_value;
        end if;

        if p_expected_Approval_Date= FND_API.G_MISS_DATE
        then
          l_expected_approval_date := null;
        else
          l_expected_approval_Date := p_expected_approval_date;
        end if;
       UPDATE pa_projects_all    -- Bug#3807805 : Modifed pa_projects to pa_projects_all
       SET record_version_number  = record_version_number +1 ,
           probability_member_id  = l_probability_member_id,
           project_value          = l_project_value,
           expected_approval_date = l_expected_approval_date
       WHERE project_id = p_project_id;
   END IF;

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
-- p_commit             IN VARCHAR2   Optional Default = FND_API.G_FALSE
-- p_validate_only      IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_validation_level   IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module     IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode         IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count      IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_object_id          IN NUMBER
-- p_object_type        IN VARCHAR2
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
(
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
 x_msg_data                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
l_row_id                   VARCHAR2(50);
l_return_status            VARCHAR2(250);
l_error_msg_code           VARCHAR2(250);
l_msg_count                number;
l_msg_data                 VARCHAR2(250);
l_msg_index_out            number;
l_data                     VARCHAR2(250);
l_code_percentage          NUMBER;
l_attribute_category       VARCHAR2(30);
l_attribute1               VARCHAR2(150);
l_attribute2               VARCHAR2(150);
l_attribute3               VARCHAR2(150);
l_attribute4               VARCHAR2(150);
l_attribute5               VARCHAR2(150);
l_attribute6               VARCHAR2(150);
l_attribute7               VARCHAR2(150);
l_attribute8               VARCHAR2(150);
l_attribute9               VARCHAR2(150);
l_attribute10              VARCHAR2(150);
l_attribute11              VARCHAR2(150);
l_attribute12              VARCHAR2(150);
l_attribute13              VARCHAR2(150);
l_attribute14              VARCHAR2(150);
l_attribute15              VARCHAR2(150);
l_application_id           NUMBER;

BEGIN

--dbms_output.put_line('PA_PROJECTS_MAINT_PVT.CREATE_CLASSIFICATION ');

   IF p_commit = FND_API.G_TRUE THEN
      SAVEPOINT create_classifications_pvt;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   if p_validation_level > 0 then

      if (p_debug_mode = 'Y') then
         pa_debug.debug('create_classification: Calling validate_classifications');
      end if;

     pa_debug.G_err_stage := 'Calling validate_classifications';

--dbms_output.put_line('PA_PROJECTS_MAINT_PVT.VALIDATE_CLASSIFICATIONS Before ');

   if (p_debug_mode = 'Y') then
      pa_debug.debug('Create classification PVT: Calling validate_classification API ');
    end if;

   l_code_percentage := p_code_percentage;

   PA_PROJECTS_MAINT_PVT.VALIDATE_CLASSIFICATIONS
      (
       p_validation_level             => p_validation_level,
       p_calling_module               => p_calling_module,
       p_action                       => 'INSERT',
       p_debug_mode                   => p_debug_mode,
       p_max_msg_count                => p_max_msg_count,
       p_object_id                    => p_object_id,
       p_object_type                  => p_object_type,
       p_class_category               => p_class_category,
       p_class_code                   => p_class_code,
       p_code_percentage              => l_code_percentage);

   l_msg_count := FND_MSG_PUB.count_msg;

--dbms_output.put_line('VALIDATE_CLASSIFICATIONS '||to_char(l_msg_count));

      IF l_msg_count > 0 THEN
         x_msg_count := l_msg_count;
         x_return_status := 'E';
         RAISE  FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   if p_attribute_category = FND_API.G_MISS_CHAR then
     l_attribute_category := NULL;
   else
     l_attribute_category := p_attribute_category;
   end if;

   if p_attribute1 = FND_API.G_MISS_CHAR then
     l_attribute1 := NULL;
   else
     l_attribute1 := p_attribute1;
   end if;

   if p_attribute2 = FND_API.G_MISS_CHAR then
     l_attribute2 := NULL;
   else
     l_attribute2 := p_attribute2;
   end if;

   if p_attribute3 = FND_API.G_MISS_CHAR then
     l_attribute3 := NULL;
   else
     l_attribute3 := p_attribute3;
   end if;

   if p_attribute4 = FND_API.G_MISS_CHAR then
     l_attribute4 := NULL;
   else
     l_attribute4 := p_attribute4;
   end if;

   if p_attribute5 = FND_API.G_MISS_CHAR then
     l_attribute5 := NULL;
   else
     l_attribute5 := p_attribute5;
   end if;

   if p_attribute6 = FND_API.G_MISS_CHAR then
     l_attribute6 := NULL;
   else
     l_attribute6 := p_attribute6;
   end if;

   if p_attribute7 = FND_API.G_MISS_CHAR then
     l_attribute7 := NULL;
   else
     l_attribute7 := p_attribute7;
   end if;

   if p_attribute8 = FND_API.G_MISS_CHAR then
     l_attribute8 := NULL;
   else
     l_attribute8 := p_attribute8;
   end if;

   if p_attribute9 = FND_API.G_MISS_CHAR then
     l_attribute9 := NULL;
   else
     l_attribute9 := p_attribute9;
   end if;

   if p_attribute10 = FND_API.G_MISS_CHAR then
     l_attribute10 := NULL;
   else
     l_attribute10 := p_attribute10;
   end if;

   if p_attribute11 = FND_API.G_MISS_CHAR then
     l_attribute11 := NULL;
   else
     l_attribute11 := p_attribute11;
   end if;

   if p_attribute12 = FND_API.G_MISS_CHAR then
     l_attribute12 := NULL;
   else
     l_attribute12 := p_attribute12;
   end if;

   if p_attribute13 = FND_API.G_MISS_CHAR then
     l_attribute13 := NULL;
   else
     l_attribute13 := p_attribute13;
   end if;

   if p_attribute14 = FND_API.G_MISS_CHAR then
     l_attribute14 := NULL;
   else
     l_attribute14 := p_attribute14;
   end if;

   if p_attribute15 = FND_API.G_MISS_CHAR then
     l_attribute15 := NULL;
   else
     l_attribute15 := p_attribute15;
   end if;

   IF NOT FND_API.TO_BOOLEAN(p_validate_only)
   THEN

/* Call to PA_PROJECT_UTILS.validate_dff as per Bug 5647964*/
IF p_calling_module = 'ADD_CLASS_CATEGORIES' THEN    /*Added ADD_CLASS_CATEGORIES condition to validate only in the add classifications flow. */
    l_application_id :=  FND_GLOBAL.resp_appl_id;
    PA_PROJECT_UTILS.validate_dff(
        p_application_id     =>   l_application_id,
        p_flexfield_name     =>   'PA_PROJECT_CLASSES_DESC_FLEX',
        p_attribute_category =>   l_attribute_category,
        p_calling_module     =>   p_calling_module,
        p_attribute1         =>   l_attribute1,
        p_attribute2         =>   l_attribute2,
        p_attribute3         =>   l_attribute3,
        p_attribute4         =>   l_attribute4,
        p_attribute5         =>   l_attribute5,
        p_attribute6         =>   l_attribute6,
        p_attribute7         =>   l_attribute7,
        p_attribute8         =>   l_attribute8,
        p_attribute9         =>   l_attribute9,
        p_attribute10        =>   l_attribute10,
        p_attribute11        =>   l_attribute11,
        p_attribute12        =>   l_attribute12,
        p_attribute13        =>   l_attribute13,
        p_attribute14        =>   l_attribute14,
        p_attribute15        =>   l_attribute15,
        x_return_status      =>   l_return_status,
        x_msg_count          =>   l_msg_count,
        x_msg_data           =>   l_msg_data);

if l_return_status <> FND_API.G_RET_STS_SUCCESS then

/*
    PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                         p_msg_name => 'FLEX-MISSING SEGMENT VALUE',
                         p_token1   => l_segment_name,
                         p_token2   => p_flexfield_name); */

      RAISE  FND_API.G_EXC_ERROR;
End if;
End if;

--dbms_output.put_line('Pa_project_classes_pkg.insert_row Project Data ');
   if (p_debug_mode = 'Y') then
      pa_debug.debug('Create classification PVT: Calling Table handler to insert new classification record ');
    end if;
            pa_project_classes_pkg.insert_row
            ( l_row_id
             ,p_object_id
             ,p_object_type
             ,p_class_category
             ,p_class_code
             ,l_code_percentage
             ,l_attribute_category
             ,l_attribute1
             ,l_attribute2
             ,l_attribute3
             ,l_attribute4
             ,l_attribute5
             ,l_attribute6
             ,l_attribute7
             ,l_attribute8
             ,l_attribute9
             ,l_attribute10
             ,l_attribute11
             ,l_attribute12
             ,l_attribute13
             ,l_attribute14
             ,l_attribute15
             ,sysdate
             ,fnd_global.user_id
             ,sysdate
             ,fnd_global.user_id
             ,fnd_global.login_id );
   END IF;

   IF FND_API.TO_BOOLEAN(P_COMMIT)
   THEN
      COMMIT WORK;
   END IF;

EXCEPTION WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO create_classifications_pvt;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECTS_MAINT_PVT',
                            p_procedure_name => 'CREATE_CLASSIFICATIONS',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

WHEN FND_API.G_EXC_ERROR THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO create_classifications_pvt;
    END IF;
    x_return_status := 'E';

WHEN OTHERS THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO create_classifications_pvt;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECTS_MAINT_PVT',
                            p_procedure_name => 'CREATE_CLASSIFICATIONS',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    raise;

END CREATE_CLASSIFICATIONS;


-- API name     : Update_Classifications
-- Type         : Public
-- Pre-reqs     : None.
-- Parameters           :
-- p_commit             IN VARCHAR2   Optional Default = FND_API.G_FALSE
-- p_validate_only      IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_validation_level   IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module     IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode         IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count      IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_object_id          IN NUMBER
-- p_object_type        IN VARCHAR2
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
-- p_rowid              IN VARCHAR2   Required
-- p_record_version_number IN NUMBER  Required
-- x_return_status     OUT VARCHAR2   Required
-- x_msg_count         OUT NUMBER     Required
-- x_msg_data          OUT VARCHAR2   Required
--
--  History
--
--           12-OCT-2001 --   anlee     created.
--
--
PROCEDURE UPDATE_CLASSIFICATIONS
(
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
 x_msg_data                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

l_code_percentage   NUMBER;
l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(250);
l_return_status                 VARCHAR2(1);
l_dummy                         VARCHAR2(1);
l_attribute_category       VARCHAR2(30);
l_attribute1               VARCHAR2(150);
l_attribute2               VARCHAR2(150);
l_attribute3               VARCHAR2(150);
l_attribute4               VARCHAR2(150);
l_attribute5               VARCHAR2(150);
l_attribute6               VARCHAR2(150);
l_attribute7               VARCHAR2(150);
l_attribute8               VARCHAR2(150);
l_attribute9               VARCHAR2(150);
l_attribute10              VARCHAR2(150);
l_attribute11              VARCHAR2(150);
l_attribute12              VARCHAR2(150);
l_attribute13              VARCHAR2(150);
l_attribute14              VARCHAR2(150);
l_attribute15              VARCHAR2(150);

-- anlee
-- Ext Attribute changes
-- Bug 2904327
CURSOR l_get_classification
IS
SELECT cat.class_category_id, code.class_code_id
FROM PA_PROJECT_CLASSES ppc, PA_CLASS_CATEGORIES cat, PA_CLASS_CODES code
WHERE ppc.rowid = p_rowid
AND ppc.class_category = cat.class_category
AND ppc.class_category = code.class_category
AND ppc.class_code = code.class_code;

l_old_category_id NUMBER;
l_new_category_id NUMBER;
l_old_code_id NUMBER;
l_new_code_id NUMBER;

-- anlee end of changes

BEGIN
if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_PROJECTS_MAINT_PVT.Update_Classifications BEGIN');
   end if;

   if p_commit = FND_API.G_TRUE then
      savepoint update_classifications_pvt;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('Locking record...');
   end if;

   if p_validate_only <> FND_API.G_TRUE then
      BEGIN
         SELECT 'x' INTO l_dummy
         FROM pa_project_classes
         WHERE rowid = p_rowid
         AND record_version_number = p_record_version_number
         FOR UPDATE OF record_version_number NOWAIT;
      EXCEPTION
         when TIMEOUT_ON_RESOURCE then
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
            l_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
         when NO_DATA_FOUND then
            if p_calling_module = 'FORM' then
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                    p_msg_name       => 'FORM_RECORD_CHANGED');
               l_msg_data := 'FORM_RECORD_CHANGED';
            else
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_XC_RECORD_CHANGED');
               l_msg_data := 'PA_XC_RECORD_CHANGED';
            end if;
         when OTHERS then
            if SQLCODE = -54 then
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
               l_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
            else
               raise;
            end if;
      END;
   else
      BEGIN
         SELECT 'x' INTO l_dummy
         FROM pa_project_classes
         WHERE rowid = p_rowid
         AND record_version_number = p_record_version_number;
      EXCEPTION
         when NO_DATA_FOUND then
            if p_calling_module = 'FORM' then
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                    p_msg_name       => 'FORM_RECORD_CHANGED');
               l_msg_data := 'FORM_RECORD_CHANGED';
            else
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_XC_RECORD_CHANGED');
               l_msg_data := 'PA_XC_RECORD_CHANGED';
            end if;
         when OTHERS then
            raise;
      END;
   end if;

   l_msg_count := FND_MSG_PUB.count_msg;
   if l_msg_count > 0 then
      x_msg_count := l_msg_count;
      if x_msg_count = 1 then
         x_msg_data := l_msg_data;
      end if;
      raise FND_API.G_EXC_ERROR;
   end if;

   if p_validation_level > 0 then
      if (p_debug_mode = 'Y') then
         pa_debug.debug('Performing validation...');
      end if;

      l_code_percentage := p_code_percentage;

      PA_PROJECTS_MAINT_PVT.VALIDATE_CLASSIFICATIONS
      (
       p_validation_level             => p_validation_level,
       p_calling_module               => p_calling_module,
       p_action                       => 'UPDATE',
       p_debug_mode                   => p_debug_mode,
       p_max_msg_count                => p_max_msg_count,
       p_object_id                    => p_object_id,
       p_object_type                  => p_object_type,
       p_class_category               => p_class_category,
       p_class_code                   => p_class_code,
       p_code_percentage              => l_code_percentage,
       p_rowid                        => p_rowid);

      l_msg_count := FND_MSG_PUB.count_msg;
      if l_msg_count > 0 then
         x_msg_count := l_msg_count;

         raise FND_API.G_EXC_ERROR;
      end if;
   end if;

   if p_attribute_category = FND_API.G_MISS_CHAR then
     l_attribute_category := NULL;
   else
     l_attribute_category := p_attribute_category;
   end if;

   if p_attribute1 = FND_API.G_MISS_CHAR then
     l_attribute1 := NULL;
   else
     l_attribute1 := p_attribute1;
   end if;

   if p_attribute2 = FND_API.G_MISS_CHAR then
     l_attribute2 := NULL;
   else
     l_attribute2 := p_attribute2;
   end if;

   if p_attribute3 = FND_API.G_MISS_CHAR then
     l_attribute3 := NULL;
   else
     l_attribute3 := p_attribute3;
   end if;

   if p_attribute4 = FND_API.G_MISS_CHAR then
     l_attribute4 := NULL;
   else
     l_attribute4 := p_attribute4;
   end if;

   if p_attribute5 = FND_API.G_MISS_CHAR then
     l_attribute5 := NULL;
   else
     l_attribute5 := p_attribute5;
   end if;

   if p_attribute6 = FND_API.G_MISS_CHAR then
     l_attribute6 := NULL;
   else
     l_attribute6 := p_attribute6;
   end if;

   if p_attribute7 = FND_API.G_MISS_CHAR then
     l_attribute7 := NULL;
   else
     l_attribute7 := p_attribute7;
   end if;

   if p_attribute8 = FND_API.G_MISS_CHAR then
     l_attribute8 := NULL;
   else
     l_attribute8 := p_attribute8;
   end if;

   if p_attribute9 = FND_API.G_MISS_CHAR then
     l_attribute9 := NULL;
   else
     l_attribute9 := p_attribute9;
   end if;

   if p_attribute10 = FND_API.G_MISS_CHAR then
     l_attribute10 := NULL;
   else
     l_attribute10 := p_attribute10;
   end if;

   if p_attribute11 = FND_API.G_MISS_CHAR then
     l_attribute11 := NULL;
   else
     l_attribute11 := p_attribute11;
   end if;

   if p_attribute12 = FND_API.G_MISS_CHAR then
     l_attribute12 := NULL;
   else
     l_attribute12 := p_attribute12;
   end if;

   if p_attribute13 = FND_API.G_MISS_CHAR then
     l_attribute13 := NULL;
   else
     l_attribute13 := p_attribute13;
   end if;

   if p_attribute14 = FND_API.G_MISS_CHAR then
     l_attribute14 := NULL;
   else
     l_attribute14 := p_attribute14;
   end if;

   if p_attribute15 = FND_API.G_MISS_CHAR then
     l_attribute15 := NULL;
   else
     l_attribute15 := p_attribute15;
   end if;

   -- anlee
   -- Ext Attribute changes
   -- Bug 2904327
   OPEN  l_get_classification;
   FETCH l_get_classification into l_old_category_id, l_old_code_id;
   CLOSE l_get_classification;
   -- anlee end of changes

   if p_validate_only <> FND_API.G_TRUE then
     pa_project_classes_pkg.update_row
            ( X_rowid               => p_rowid
             ,X_object_id           => p_object_id
             ,X_object_type         => p_object_type
             ,X_class_category      => p_class_category
             ,X_class_code          => p_class_code
             ,X_code_percentage     => l_code_percentage
             ,X_attribute_category  => l_attribute_category
             ,X_attribute1          => l_attribute1
             ,X_attribute2          => l_attribute2
             ,X_attribute3          => l_attribute3
             ,X_attribute4          => l_attribute4
             ,X_attribute5          => l_attribute5
             ,X_attribute6          => l_attribute6
             ,X_attribute7          => l_attribute7
             ,X_attribute8          => l_attribute8
             ,X_attribute9          => l_attribute9
             ,X_attribute10         => l_attribute10
             ,X_attribute11         => l_attribute11
             ,X_attribute12         => l_attribute12
             ,X_attribute13         => l_attribute13
             ,X_attribute14         => l_attribute14
             ,X_attribute15         => l_attribute15
             ,X_Last_Update_Date    => sysdate
             ,X_Last_Updated_By     => fnd_global.user_id
             ,X_Creation_Date       => sysdate
             ,X_Created_By          => fnd_global.user_id
             ,X_Last_Update_Login   => fnd_global.login_id
             ,X_record_version_number => p_record_version_number);
   end if;

   -- anlee
   -- Ext Attribute changes
   -- Bug 2904327
   OPEN  l_get_classification;
   FETCH l_get_classification into l_new_category_id, l_new_code_id;
   CLOSE l_get_classification;

   PA_USER_ATTR_PUB.DELETE_USER_ATTRS_DATA (
    p_validate_only             => FND_API.G_FALSE
   ,p_project_id                => p_object_id
   ,p_old_classification_id     => l_old_category_id
   ,p_new_classification_id     => l_new_category_id
   ,p_classification_type       => 'CLASS_CATEGORY'
   ,x_return_status             => l_return_status
   ,x_msg_count                 => l_msg_count
   ,x_msg_data                  => l_msg_data );

   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
     x_msg_count := l_msg_count;
     x_return_status := 'E';
     RAISE  FND_API.G_EXC_ERROR;
   END IF;


   PA_USER_ATTR_PUB.DELETE_USER_ATTRS_DATA (
    p_validate_only             => FND_API.G_FALSE
   ,p_project_id                => p_object_id
   ,p_old_classification_id     => l_old_code_id
   ,p_new_classification_id     => l_new_code_id
   ,p_classification_type       => 'CLASS_CODE'
   ,x_return_status             => l_return_status
   ,x_msg_count                 => l_msg_count
   ,x_msg_data                  => l_msg_data );

   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
     x_msg_count := l_msg_count;
     x_return_status := 'E';
     RAISE  FND_API.G_EXC_ERROR;
   END IF;

   -- anlee end of changes

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if p_commit = FND_API.G_TRUE then
      commit work;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_PROJECTS_MAINT_PVT.Update_Classifications END');
   end if;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_classifications_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
   when others then
      if p_commit = FND_API.G_TRUE then
         rollback to update_classifications_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECTS_MAINT_PVT',
                              p_procedure_name => 'Update_Classifications',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END UPDATE_CLASSIFICATIONS;



-- API name             : validate_classifications
-- Type                 : Validation
-- Pre-reqs             : None.
-- Parameters           :
-- p_validation_level   IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module     IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_action             IN VARCHAR2   Optional Default = 'INSERT'
-- p_debug_mode         IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count      IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_object_id          IN NUMBER     Required
-- p_object_type        IN VARCHAR2   Required
-- p_class_category     IN VARCHAR2   Required
-- p_class_code         IN VARCHAR2   Required
-- p_code_percentage    IN VARCHAR2   Optional Default = FND_API.G_MISS_NUM
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
PROCEDURE VALIDATE_CLASSIFICATIONS
(
 p_validation_level             IN NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_calling_module               IN VARCHAR2   := 'SELF_SERVICE'        ,
 p_action                       IN VARCHAR2   := 'INSERT'  ,
 p_debug_mode                   IN VARCHAR2   := 'N',
 p_max_msg_count                IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_object_id                    IN NUMBER                              ,
 p_object_type                  IN VARCHAR2                            ,
 p_class_category               IN VARCHAR2                            ,
 p_class_code                   IN VARCHAR2,
 p_code_percentage          IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 p_rowid                        IN VARCHAR2   := FND_API.G_MISS_CHAR)
IS
l_return_status            VARCHAR2(250);
l_error_msg_code           VARCHAR2(250);
l_object_type_id           NUMBER;
l_rowid                    VARCHAR2(250);
l_class_category           VARCHAR2(250);

CURSOR C(c_object_id NUMBER, c_object_type VARCHAR2, c_class_category VARCHAR2, c_class_code VARCHAR2)
IS
SELECT rowid
FROM   pa_project_classes
WHERE  object_id = c_object_id
AND    object_type = c_object_type
AND    class_category = c_class_category
AND    class_code = c_class_code;

CURSOR C2(c_rowid VARCHAR2)
IS
SELECT class_category
FROM PA_PROJECT_CLASSES
WHERE rowid = c_rowid;

BEGIN

 if p_action = 'INSERT' then

--dbms_output.put_line('PA_PROJECTS_MAINT_UTILS.CHECK_CLASS_CATG_CAN_OVERRIDE ');

   IF p_calling_module = 'QUICK_ENTRY'
   THEN
   if (p_debug_mode = 'Y') then
      pa_debug.debug('Validate classification PVT: Calling API to check if catg  code can be overridden');
    end if;
       PA_PROJECTS_MAINT_UTILS.CHECK_CLASS_CATG_CAN_OVERRIDE(
                           p_object_id,
                           p_class_category,
                           p_class_code,
                           l_return_status,
                           l_error_msg_code);

       IF l_return_status = 'E'
       THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name  =>l_error_msg_code);
       END IF;
   END IF;

--dbms_output.put_line('CHECK_CLASS_CATG_CAN_OVERRIDE '||l_error_msg_code||'Status :'||l_return_status);

   if (p_debug_mode = 'Y') then
      pa_debug.debug('Validate classification PVT: Calling API to check if category is valid');
   end if;

   if p_object_type = 'PA_PROJECTS' then
     SELECT ppta.project_type_id
     INTO   l_object_type_id
     FROM   PA_PROJECT_TYPES_ALL ppta,
            PA_PROJECTS_ALL ppa
     WHERE  ppa.project_id = p_object_id
     AND    ppa.project_type = ppta.project_type
--     AND    NVL(ppa.org_id, -99) = NVL(ppta.org_id, -99); MOAC Changes: Bug 4363092 - removed nvl
     AND    ppa.org_id = ppta.org_id;
   else
     l_object_type_id := -1;
   end if;

   -- for bug# 3690967, SQL mentioned in issue 3, is used in CHECK_CATEGORY_VALID API . This API is
   -- called from CREATE_CLASSIFICATIONS,UPDATE_CLASSIFICATIONS API which is used
   -- in forms only. In forms class category is already validated as it is picked
   -- from LOV which is based on PA_VALID_CATEGORIES_V. Verified that this API is
   -- not used in AMG/SS flow. Hence we can comment out the call to this API in
   -- CREATE/UPDATE flow from forms.

   /*
   PA_PROJECTS_MAINT_UTILS.CHECK_CATEGORY_VALID(
                           l_object_type_id,
                           p_class_category,
                           l_return_status,
                           l_error_msg_code);

   IF l_return_status = 'E'
   THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name  =>l_error_msg_code);
   END IF;

   */

   PA_PROJECTS_MAINT_UTILS.CHECK_PERCENTAGE_ALLOWED(
                           p_class_category,
                           l_return_status,
                           l_error_msg_code);
   if (p_code_percentage is not NULL) AND (p_code_percentage <> FND_API.G_MISS_NUM) then
     if l_return_status = 'E' then
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name  =>l_error_msg_code);
     else
       if (p_code_percentage < 0) OR (p_code_percentage > 100) then
         l_return_status := 'E';
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name  => 'PA_CODE_PERCENT_INVALID');
       /* Commented for bug 3161704
       else
         if p_calling_module = 'FORMS' then
           PA_PROJECTS_MAINT_UTILS.CHECK_CATEGORY_TOTAL_VALID(
            p_object_id,
            p_object_type,
            p_class_category,
            NULL,
            p_code_percentage,
            l_return_status,
            l_error_msg_code);

           if l_return_status = 'E' then
             PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                  p_msg_name  =>l_error_msg_code);
           end if;
         end if;
     */
       end if;
     end if;
   else
     if l_return_status = 'S' then
       p_code_percentage := 0;
     else
       p_code_percentage := NULL;
     end if;
   end if;


   if (p_debug_mode = 'Y') then
      pa_debug.debug('Validate classification PVT: Calling API to check if only one catg code can be entered');
    end if;
   PA_PROJECTS_MAINT_UTILS.CHECK_CLASS_CATG_ONE_ONLY_CODE(
                           p_object_id,
                           p_object_type,
                           p_class_category,
                           l_return_status,
                           l_error_msg_code);

   IF l_return_status = 'E'
   THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name  =>l_error_msg_code);
   END IF;

--dbms_output.put_line('CHECK_DUPLICATE_CLASS_CATG '||l_error_msg_code||'Status :'||l_return_status);

   if (p_debug_mode = 'Y') then
      pa_debug.debug('Validate classification PVT: Calling API to check if the catg code entered is a duplicate');
    end if;
    PA_PROJECTS_MAINT_UTILS.CHECK_DUPLICATE_CLASS_CATG(
                           p_object_id,
                           p_object_type,
                           p_class_category,
                           p_class_code,
                           l_return_status,
                           l_error_msg_code);
   IF l_return_status = 'E'
   THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name  =>l_error_msg_code);
   END IF;
--dbms_output.put_line('CHECK_DUPLICATE_CLASS_CATG '||l_error_msg_code||'Status :'||l_return_status);


 ELSIF p_action = 'UPDATE' then

   if (p_debug_mode = 'Y') then
      pa_debug.debug('Validate classification PVT: Calling API to check if category is valid');
   end if;

   if p_object_type = 'PA_PROJECTS' then
     SELECT ppta.project_type_id
     INTO   l_object_type_id
     FROM   PA_PROJECT_TYPES_ALL ppta,
            PA_PROJECTS_ALL ppa
     WHERE  ppa.project_id = p_object_id
     AND    ppa.project_type = ppta.project_type
--     AND    NVL(ppa.org_id, -99) = NVL(ppta.org_id, -99);  MOAC Changes: Bug 4363092 - removed nvl
     AND    ppa.org_id = ppta.org_id;
   else
     l_object_type_id := -1;
   end if;

   PA_PROJECTS_MAINT_UTILS.CHECK_CATEGORY_VALID(
                           l_object_type_id,
                           p_class_category,
                           l_return_status,
                           l_error_msg_code);

   IF l_return_status = 'E'
   THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name  =>l_error_msg_code);
   END IF;

   PA_PROJECTS_MAINT_UTILS.CHECK_PERCENTAGE_ALLOWED(
                           p_class_category,
                           l_return_status,
                           l_error_msg_code);
   if (p_code_percentage is not NULL) AND (p_code_percentage <> FND_API.G_MISS_NUM) then
     if l_return_status = 'E' then
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name  =>l_error_msg_code);
     else
       if (p_code_percentage < 0) OR (p_code_percentage > 100) then
         l_return_status := 'E';
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name  => 'PA_CODE_PERCENT_INVALID');
       /* Commented for bug 3161704
       else
         if p_calling_module = 'FORMS' then
           PA_PROJECTS_MAINT_UTILS.CHECK_CATEGORY_TOTAL_VALID(
            p_object_id,
            p_object_type,
            p_class_category,
            p_rowid,
            p_code_percentage,
            l_return_status,
            l_error_msg_code);

           if l_return_status = 'E' then
             PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                  p_msg_name  =>l_error_msg_code);
           end if;
         end if;
     */
       end if;
     end if;
   else
     if l_return_status = 'S' then
       p_code_percentage := 0;
     else
       p_code_percentage := NULL;
     end if;
   end if;


   if (p_rowid = FND_API.G_MISS_CHAR) OR (p_rowid is NULL) then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   OPEN C(p_object_id, p_object_type, p_class_category, p_class_code);
   FETCH C INTO l_rowid;
   close C;

   if p_rowid = l_rowid then
     return;
   end if;

   OPEN C2(p_rowid);
   FETCH C2 INTO l_class_category;
   close C2;

   if l_class_category <> p_class_category then
      if (p_debug_mode = 'Y') then
        pa_debug.debug('Validate classification PVT: Calling API to check if only one catg code can be entered');
      end if;
      PA_PROJECTS_MAINT_UTILS.CHECK_CLASS_CATG_ONE_ONLY_CODE(
                              p_object_id,
                              p_object_type,
                              p_class_category,
                              l_return_status,
                              l_error_msg_code);

      IF l_return_status = 'E'
      THEN
             PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name  =>l_error_msg_code);
      END IF;
   END IF;

--dbms_output.put_line('CHECK_DUPLICATE_CLASS_CATG '||l_error_msg_code||'Status :'||l_return_status);

   if (p_debug_mode = 'Y') then
      pa_debug.debug('Validate classification PVT: Calling API to check if the catg code entered is a duplicate');
    end if;
    PA_PROJECTS_MAINT_UTILS.CHECK_DUPLICATE_CLASS_CATG(
                           p_object_id,
                           p_object_type,
                           p_class_category,
                           p_class_code,
                           l_return_status,
                           l_error_msg_code);
   IF l_return_status = 'E'
   THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name  =>l_error_msg_code);
   END IF;
--dbms_output.put_line('CHECK_DUPLICATE_CLASS_CATG '||l_error_msg_code||'Status :'||l_return_status);


 ELSIF p_action = 'DELETE' then

   if (p_debug_mode = 'Y') then
      pa_debug.debug('Validate classification PVT: Calling API to check if the catg code entered can be deleted');
    end if;
  PA_PROJECTS_MAINT_UTILS.CHECK_CLASS_CATG_CAN_DELETE
                          (p_object_id,
                           p_object_type,
                           p_class_category,
                           l_return_status,
                           l_error_msg_code);
   IF l_return_status = 'E'
   THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => l_error_msg_code);
   END IF;

 END IF;

--dbms_output.put_line('SUCCESSFUL VALIDATION OVER ... '||l_error_msg_code||'Status :'||l_return_status);

EXCEPTION
when FND_API.G_EXC_UNEXPECTED_ERROR then
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECTS_MAINT_PUB',
                            p_procedure_name => 'VALIDATE_CLASSIFICATIONS',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
WHEN OTHERS THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECTS_MAINT_PUB',
                            p_procedure_name => 'VALIDATE_CLASSIFICATIONS',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    raise;

END VALIDATE_CLASSIFICATIONS;

-- API name     : delete_classifications
-- Type         : Public
-- Pre-reqs     : None.
-- Parameters           :
-- p_commit             IN VARCHAR2   Optional Default = FND_API.G_FALSE
-- p_validate_only      IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_validation_level   IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
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
(
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

l_dummy                    VARCHAR2(1);
l_delete_flag              VARCHAR2(1) := 'N';
l_return_status            VARCHAR2(250);
l_error_msg_code           VARCHAR2(250);
l_msg_count                NUMBER;
l_msg_index_out            NUMBER;
l_msg_data                 VARCHAR2(250);
l_data                     VARCHAR2(250);
l_row_id                   VARCHAR2(250);
l_code_percentage          NUMBER;

-- anlee
-- Ext Attribute changes
-- Bug 2904327
CURSOR get_category_id
IS
SELECT class_category_id
FROM PA_CLASS_CATEGORIES
WHERE class_category = p_class_category;

CURSOR get_code_id
IS
SELECT class_code_id
FROM PA_CLASS_CODES
WHERE class_category = p_class_category
AND class_code = p_class_code;

l_category_id NUMBER;
l_code_id NUMBER;
-- anlee end of changes

BEGIN

   IF p_commit = FND_API.G_TRUE THEN
      SAVEPOINT delete_classifications_pvt;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('Delete classification PVT: locking record for deletion');
   end if;
if p_validate_only <> FND_API.G_TRUE then
  BEGIN
   SELECT       rowid INTO l_row_id
   FROM         pa_project_classes
   WHERE        object_id            = p_object_id
     AND        object_type          = p_object_type
     AND        class_category       = p_class_category
     and        class_code           = p_class_code
     and        record_version_number = p_record_version_number
   FOR UPDATE OF class_code NOWAIT;
   EXCEPTION WHEN TIMEOUT_ON_RESOURCE THEN
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
               x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
               x_return_status := 'E' ;
           WHEN NO_DATA_FOUND THEN
            if p_calling_module = 'FORM' then
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                    p_msg_name       => 'FORM_RECORD_CHANGED');
               x_msg_data := 'FORM_RECORD_CHANGED';
            else
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_XC_RECORD_CHANGED');
               x_msg_data := 'PA_XC_RECORD_CHANGED';
            end if;
            x_return_status := 'E' ;
            WHEN OTHERS THEN
              IF SQLCODE = -54 THEN
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
                 x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
                 x_return_status := 'E' ;
              ELSE
                 raise;
              END IF;
   END;
ELSE
     BEGIN
        SELECT       rowid INTO l_row_id
        FROM         pa_project_classes
        WHERE        object_id            = p_object_id
          AND        object_type          = p_object_type
          AND        class_category       = p_class_category
          and        class_code           = p_class_code
          and        record_version_number = p_record_version_number;
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
            if p_calling_module = 'FORM' then
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                    p_msg_name       => 'FORM_RECORD_CHANGED');
               x_msg_data := 'FORM_RECORD_CHANGED';
            else
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_XC_RECORD_CHANGED');
               x_msg_data := 'PA_XC_RECORD_CHANGED';
            end if;
            x_return_status := 'E' ;
            WHEN OTHERS THEN
              IF SQLCODE = -54 THEN
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
                 x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
                 x_return_status := 'E' ;
              ELSE
                  raise;
              END IF;
       END;

END IF;
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE  FND_API.G_EXC_ERROR;
   END IF;

   if p_validation_level > 0 then
     pa_debug.G_err_stage := 'Calling validate_classifications';
     if (p_debug_mode = 'Y') then
      pa_debug.debug('Delete classification PVT: Calling API to validate classfications');
     end if;
     PA_PROJECTS_MAINT_PVT.VALIDATE_CLASSIFICATIONS
      (
       p_validation_level             => p_validation_level,
       p_calling_module                => p_calling_module,
       p_action                       => 'DELETE',
       p_debug_mode                   => p_debug_mode,
       p_max_msg_count                => p_max_msg_count,
       p_object_id                   => p_object_id,
       p_object_type                 => p_object_type,
       p_class_category               => p_class_category ,
       p_class_code                   => p_class_Code,
       p_code_percentage              => l_code_percentage,
       p_rowid                        => l_row_id);

   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE  FND_API.G_EXC_ERROR;
   END IF;
   END IF;
   IF NOT FND_API.TO_BOOLEAN(p_validate_only)
   THEN
   if (p_debug_mode = 'Y') then
      pa_debug.debug('Delete classification PVT: Calling table handler to delete classfications record');
   end if;
            pa_project_classes_pkg.delete_row
            ( l_row_id);

     -- anlee
     -- Ext Attribute changes
     -- Bug 2904327

     OPEN get_category_id;
     FETCH get_category_id INTO l_category_id;
     CLOSE get_category_id;

     PA_USER_ATTR_PUB.DELETE_USER_ATTRS_DATA (
      p_validate_only             => FND_API.G_FALSE
     ,p_project_id                => p_object_id
     ,p_old_classification_id     => l_category_id
     ,p_classification_type       => 'CLASS_CATEGORY'
     ,x_return_status             => l_return_status
     ,x_msg_count                 => l_msg_count
     ,x_msg_data                  => l_msg_data );

     l_msg_count := FND_MSG_PUB.count_msg;

     IF l_msg_count > 0 THEN
       x_msg_count := l_msg_count;
       x_return_status := 'E';
       RAISE  FND_API.G_EXC_ERROR;
     END IF;


     OPEN get_code_id;
     FETCH get_code_id INTO l_code_id;
     CLOSE get_code_id;

     PA_USER_ATTR_PUB.DELETE_USER_ATTRS_DATA (
      p_validate_only             => FND_API.G_FALSE
     ,p_project_id                => p_object_id
     ,p_old_classification_id     => l_code_id
     ,p_classification_type       => 'CLASS_CODE'
     ,x_return_status             => l_return_status
     ,x_msg_count                 => l_msg_count
     ,x_msg_data                  => l_msg_data );

     l_msg_count := FND_MSG_PUB.count_msg;

     IF l_msg_count > 0 THEN
       x_msg_count := l_msg_count;
       x_return_status := 'E';
       RAISE  FND_API.G_EXC_ERROR;
     END IF;

     -- anlee end of changes
   END IF;

   IF FND_API.TO_BOOLEAN(P_COMMIT)
   THEN
      COMMIT WORK;
   END IF;

EXCEPTION WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO delete_classifications_pvt;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECTS_MAINT_PUB',
                            p_procedure_name => 'DELETE_CLASSIFICATIONS',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

WHEN FND_API.G_EXC_ERROR THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO delete_classifications_pvt;
    END IF;
    x_return_status := 'E';

WHEN OTHERS THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO prm_create_project;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECTS_MAINT_PVT',
                            p_procedure_name => 'DELETE_CLASSIFICATIONS',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    raise;

END DELETE_CLASSIFICATIONS;

-- API name    : Validate_Project_Info
-- Type        : Validation
-- Pre-reqs    : None.
-- Parameters           :
-- p_validation_level   IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module     IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_action             IN VARCHAR2   Optional Default = 'INSERT', 'UPDATE', 'DELETE'
-- p_max_msg_count      IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_project_id         IN NUMBER     Required
-- p_project_name       IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_project_number     IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_project_type       IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_description        IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_project_status_code IN VARCHAR2  Optional Default = FND_API.G_MISS_CHAR
-- p_public_sector_flag  IN VARCHAR2  Optional Default = FND_API.G_MISS_CHAR
-- p_carrying_out_organization_id IN NUMBER Optional
--                                   Default = FND_API.G_MISS_NUM
-- p_start_date          IN DATE      Optional Default = FND_API.G_MISS_DATE
-- p_completion_date     IN DATE      Optional Default = FND_API.G_MISS_DATE
-- p_territory_code      IN VARCHAR2  Optional Default = FND_API.G_MISS_CHAR
-- p_country             IN VARCHAR2  Optional Default = FND_API.G_MISS_CHAR
-- p_location_id         IN NUMBER    Optional Default = FND_API.G_MISS_NUM
-- p_state_region        IN VARCHAR2  Optional Default = FND_API.G_MISS_CHAR
-- p_city                IN VARCHAR2  Optional Default = FND_API.G_MISS_CHAR
-- p_calendar_id        IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_work_type_id       IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_role_list_id       IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_cost_job_group_id  IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_bill_job_group_id  IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_probability_member_id  IN NUMBER Optional Default = FND_API.G_MISS_NUM
-- p_project_value          IN NUMBER Optional Default = FND_API.G_MISS_NUM
-- p_expected_approval_date IN DATE   Optional Default = FND_API.G_MISS_DATE
-- p_record_version_number IN NUMBER  Required
-- p_project_start_date    IN DATE    Optional Default = FND_API.G_MISS_DATE
-- p_project_finish_date   IN DATE    Optional Default = FND_API.G_MISS_DATE
-- p_long_name           IN VARCHAR2  Optional Default = NULL
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
PROCEDURE Validate_Project_Info
(
 p_validation_level             IN NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_calling_module               IN VARCHAR2   := 'SELF_SERVICE'        ,
 p_action                       IN VARCHAR2   := 'UPDATE'                   ,
 p_debug_mode                   IN VARCHAR2   := 'N'                   ,
 p_max_msg_count                IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_project_id                   IN NUMBER                              ,
 p_project_name                 IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_project_number               IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_project_type                 IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_description                  IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_project_status_code          IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_public_sector_flag           IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_carrying_out_organization_id IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_start_date                   IN DATE       := FND_API.G_MISS_DATE   ,
 p_completion_date              IN DATE       := FND_API.G_MISS_DATE   ,
 p_territory_code               IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_country                      IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_location_id                  IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_state_region                 IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_city                         IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_calendar_id                  IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_work_type_id                 IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_role_list_id                 IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_cost_job_group_id            IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_bill_job_group_id            IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_probability_member_id        IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_project_value                IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_expected_approval_date       IN DATE       := FND_API.G_MISS_DATE   ,
 p_record_version_number        IN NUMBER  ,
-- anlee
-- Dates changes
 p_target_start_date           IN DATE       := FND_API.G_MISS_DATE   ,
 p_target_finish_date          IN DATE       := FND_API.G_MISS_DATE   ,
-- End of changes
-- anlee
-- Project Long Name changes
 p_long_name                    IN VARCHAR2   DEFAULT NULL             )
-- end of changes
IS

l_dummy                 VARCHAR2(1)          := 'N';
l_project_id               pa_projects.project_id%TYPE;
l_return_status            VARCHAR2(1);
l_error_msg_code           VARCHAR2(250);
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(250);
l_err_code                 VARCHAR2(250);
l_err_stage                VARCHAR2(250);
l_err_stack                VARCHAR2(250);
l_data                     VARCHAR2(250);
l_msg_index_out            NUMBER;

-- Start date and Completion date validation

l_project_start_date            DATE;
l_project_completion_date  DATE;
l_update_start_date_flag   VARCHAR2(1);
l_update_end_date_flag     VARCHAR2(1);

-- Project Number Validation

l_proj_num_numeric                NUMBER;

-- Organization Name Validation

l_carrying_out_organization_id    NUMBER;
l_calendar_id                     NUMBER;
function_flag                     VARCHAR2(1);
t_project_type_class_code         VARCHAR2(50);
l_calendar_name                   VARCHAR2(250);

-- Project status Validation

l_closing_project                 VARCHAR2(1);
l_project_status_changed          VARCHAR2(1);
l_reopening_project               VARCHAR2(1);
l_verify_ok_flag                  VARCHAR2(1);
l_wf_enabled_flag                 VARCHAR2(1);
l_warnings_only_flag              VARCHAR2(1);
x_status_changeable               VARCHAR2(1);
l_err_msg_count                   NUMBER;
l_wf_status_code                  VARCHAR2(30);

-- Location Validation

x_location_id                     NUMBER;
x_rowid                           VARCHAR2(25);
x_country_name                    VARCHAR2(250);
x_country_code                    VARCHAR2(25);
x_city_name                       VARCHAR2(250);
x_region_name                     VARCHAR2(250);
l_error_message_code              VARCHAR2(250);

--project type validation
l_status_code                     NUMBER ;

   --needed to check whether given project name is unique
   CURSOR   l_project_name_unique_csr( p_project_name VARCHAR2)
   IS
   SELECT   'x'
   FROM     pa_projects_all
   WHERE    name = p_project_name;

   --needed to check whether given project number is unique
   CURSOR   l_project_number_unique_csr( p_project_number VARCHAR2)
   IS
   SELECT   'x'
   FROM     pa_projects_all
   WHERE    segment1 = p_project_number;

   CURSOR l_project_details_csr( p_project_id NUMBER)
   IS
   SELECT *
   FROM    pa_projects_all p  -- Bug#3807805 : Modifed pa_projects to pa_projects_all
   WHERE  p.project_id = p_project_id
   FOR UPDATE OF p.record_version_number;

  Cursor c1 (x_country_code varchar2,
             x_state_region  varchar2,
             x_city          varchar2)
  IS
   Select location_id
   from pa_locations
   where country_code = x_country_code
   and   region       = x_state_region
   and   city         = x_city;

   Cursor c2 (x_country_name Varchar2)
   Is
   select territory_code
   from fnd_territories_tl
   where territory_short_name = x_country_name;

   cursor prob_per (c_probability_member_id number)
   IS
   select probability_percentage
   from pa_probability_members
   where probability_member_id = c_probability_member_id;

   -- anlee
   -- Added validations for bug 2327927
-- MOAC Changes: Bug 4363092 - removed nvl used with org_id
   cursor get_project_type_info (c_project_type VARCHAR2)
   IS
   select *
   from pa_project_types_all -- Bug#3807805 : Modifed pa_project_types to pa_project_types_all
   where project_type = c_project_type
   and  org_id = PA_PROJECT_REQUEST_PVT.G_ORG_ID; -- Added the and condition for Bug#3807805
   -- anlee end of changes

-- MOAC Changes: Bug 4363092 - removed nvl used with org_id
  cursor get_unassigned_time (c_project_type VARCHAR2)
  IS
  Select unassigned_time
  from pa_project_types_all   -- Bug#3807805 : Modifed pa_project_types to pa_project_types_all
  where project_type = c_project_type
  and  org_id = PA_PROJECT_REQUEST_PVT.G_ORG_ID; -- Added the and condition for Bug#3807805

 l_unassigned_time           pa_project_types.unassigned_time%TYPE;
 l_project_old_rec           pa_projects_all%ROWTYPE;  -- Bug#3807805 : Modifed pa_projects to pa_projects_all
 l_project_type_rec          get_project_type_info%ROWTYPE;
 l_probability_member_id     number;

  -- anlee
  -- Added validations for bug 2327927
  -- MOAC Changes: Bug 4363092 - removed nvl used with org_id
  cursor get_project_type_class_code (c_project_type VARCHAR2)
  IS
  Select project_type_class_code
  from   pa_project_types_all  -- Bug#3807805 : Modifed pa_project_types to pa_project_types_all
  where  project_type = c_project_type
  and  org_id = PA_PROJECT_REQUEST_PVT.G_ORG_ID; -- Added the and condition for Bug#3807805

  cursor get_billable_cap_flag (c_work_type_id NUMBER)
  IS
  select billable_capitalizable_flag
  from pa_work_types_vl
  where work_type_id = c_work_type_id;

  cursor get_dist_rule (c_project_type VARCHAR2)
  IS
  select distribution_rule
  from pa_project_type_distributions
  where project_type = c_project_type
  and default_flag = 'Y';

  cursor get_min_task_start_date
  IS
  select min(start_date) task_start_date
  from pa_tasks
  where project_id = p_project_id
  and start_date is not null;

  cursor get_max_task_completion_date
  IS
  select max(completion_date) task_completion_date
  from pa_tasks
  where project_id = p_project_id
  and completion_date is not null;

  l_min_task_start_date         pa_tasks.start_date%TYPE;
  l_max_task_completion_date    pa_tasks.completion_date%TYPE;
  l_start_date_error            BOOLEAN := FALSE;
  l_completion_date_error       BOOLEAN := FALSE;
  l_distribution_rule           pa_project_type_distributions.distribution_rule%TYPE;
  l_billable_capitalizable_flag pa_work_types_vl.billable_capitalizable_flag%TYPE;
  l_old_project_type_class_code pa_project_types.project_type_class_code%TYPE;
  l_project_type_class_code     pa_project_types.project_type_class_code%TYPE;
  l_project_type_error          BOOLEAN := FALSE;
  -- anlee end of changes

  -- anlee project actions changes
  l_delete_project_allowed VARCHAR2(1) := 'Y';
  l_update_proj_num_allowed VARCHAR2(1) := 'Y';
  l_update_proj_name_allowed VARCHAR2(1) := 'Y';
  l_update_proj_desc_allowed VARCHAR2(1) := 'Y';
  l_update_proj_dates_allowed VARCHAR2(1) := 'Y';
  l_update_proj_status_allowed VARCHAR2(1) := 'Y';
  l_update_proj_manager_allowed VARCHAR2(1) := 'Y';
  l_update_proj_org_allowed VARCHAR2(1) := 'Y';
  l_add_task_allowed VARCHAR2(1) := 'Y';
  l_delete_task_allowed VARCHAR2(1) := 'Y';
  l_update_task_num_allowed VARCHAR2(1) := 'Y';
  l_update_task_name_allowed VARCHAR2(1) := 'Y';
  l_update_task_dates_allowed VARCHAR2(1) := 'Y';
  l_update_task_desc_allowed VARCHAR2(1) := 'Y';
  l_update_parent_task_allowed VARCHAR2(1) := 'Y';
  l_update_task_org_allowed VARCHAR2(1) := 'Y';

  l_pm_product_code pa_projects_all.pm_product_code%TYPE;

  CURSOR get_product_code IS
  SELECT pm_product_code
  FROM PA_PROJECTS_ALL
  WHERE project_id = p_project_id;
  -- anlee end of changes
--bug 3068781 maansari
l_multi_currency_billing_flag      VARCHAR2(1);
l_PROJFUNC_BIL_RATE_DATE_CODE      VARCHAR2(30);
l_PROJECT_BIL_RATE_DATE_CODE       VARCHAR2(30);
l_FUNDING_RATE_DATE_CODE           VARCHAR2(30);
l_PROJFUNC_BIL_RATE_TYPE           VARCHAR2(30);
l_PROJECT_BIL_RATE_TYPE            VARCHAR2(30);
l_FUNDING_RATE_TYPE                VARCHAR2(30);
l_BTC_COST_BASE_REV_CODE           VARCHAR2(90);
--end bug 3068781
BEGIN

--dbms_output.put_line('Starts here Validate_Basic_Info  ... ');

   OPEN  l_project_details_csr (p_project_id);
   FETCH l_project_details_csr INTO l_project_old_rec;

--dbms_output.put_line('Check p_validation_level ... '||to_char(p_validation_level));

if (p_validation_level > 0) then

--if (p_calling_module like ('BASIC_INFO')) then
  if (p_calling_module = 'BASIC_INFO' OR p_calling_module = 'SETUP_PAGE') then  -- bug 7204572 added one more condition to IF

   if PA_PROJECT_REQUEST_PVT.G_ORG_ID is null and p_project_type is not null then       -- Added the if block for Bug#3807805
      select org_id into PA_PROJECT_REQUEST_PVT.G_ORG_ID from pa_projects where project_id = p_project_id;--Bug 8882288
   end if;

   -- anlee project actions changes
   OPEN get_product_code;
   FETCH get_product_code INTO l_pm_product_code;
   CLOSE get_product_code;

   if l_pm_product_code IS NOT NULL then

     PA_PM_CONTROLS.Get_Project_Actions_Allowed (
      p_pm_product_code             => l_pm_product_code
     ,p_delete_project_allowed      => l_delete_project_allowed
     ,p_update_proj_num_allowed     => l_update_proj_num_allowed
     ,p_update_proj_name_allowed    => l_update_proj_name_allowed
     ,p_update_proj_desc_allowed    => l_update_proj_desc_allowed
     ,p_update_proj_dates_allowed   => l_update_proj_dates_allowed
     ,p_update_proj_status_allowed  => l_update_proj_status_allowed
     ,p_update_proj_manager_allowed => l_update_proj_manager_allowed
     ,p_update_proj_org_allowed     => l_update_proj_org_allowed
     ,p_add_task_allowed            => l_add_task_allowed
     ,p_delete_task_allowed         => l_delete_task_allowed
     ,p_update_task_num_allowed     => l_update_task_num_allowed
     ,p_update_task_name_allowed    => l_update_task_name_allowed
     ,p_update_task_dates_allowed   => l_update_task_dates_allowed
     ,p_update_task_desc_allowed    => l_update_task_desc_allowed
     ,p_update_parent_task_allowed  => l_update_parent_task_allowed
     ,p_update_task_org_allowed     => l_update_task_org_allowed
     ,p_error_code                  => l_err_code
     ,p_error_stack                 => l_err_stack
     ,p_error_stage                 => l_err_stage );

     IF l_err_code <> 0 THEN
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                            p_msg_name       => l_err_stage);
     END IF;
   end if;
   -- anlee end of changes

   if (p_debug_mode = 'Y') then
      pa_debug.debug('Validate_project_info PVT: Basic info validation');
   end if;
--PROJECT NUMBER
-- Check for implementation defined Project number generation mode
-- If project number generation is automatic then ignore the input
-- project number ,since it cannot be modified.Hence,the following
-- checks will be done only if the mode was 'MANUAL'

  IF (p_debug_mode = 'Y')
  THEN
      pa_debug.debug('Validate_project_info PVT: project number validation');
  END IF;

  IF PA_PROJECT_UTILS.GetProjNumMode = 'MANUAL' THEN
     IF p_project_number IS NOT NULL
     THEN
        IF  p_project_number <> l_project_old_rec.segment1
        THEN

            -- anlee project actions changes
            IF l_update_proj_num_allowed = 'N' THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name      => 'PA_PM_PROJ_NUM_ERR');
            ELSE

              pa_project_utils.change_proj_num_ok
                  (p_project_id,
                   l_err_code,
                   l_err_stage,
                   l_err_stack );

              IF l_err_code <> 0
              THEN
                 IF NOT pa_project_pvt.check_valid_message (l_err_stage)
                 THEN
                    PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name      => 'PA_CANT_CHANGE_PROJ_NUM');
                 ELSE
                    PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name      => l_err_stage);
                 END IF;  -- pa_project_pvt.check_valid_message

              -- Check for project number being numeric if project number type is
              -- defined as numeric

                 BEGIN
                  IF PA_PROJECT_UTILS.GetProjNumType = 'NUMERIC' THEN
                     l_proj_num_numeric  :=
                       TO_NUMBER(p_project_number);
                  END IF;   -- PA_PROJECT_UTILS.GetProjNumType
                 EXCEPTION
                   WHEN VALUE_ERROR THEN
                    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                      THEN
                      PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                            p_msg_name      => 'PA_PR_NUMERIC_NUM_REQ');
                    END IF; -- FND_MSG_PUB.check_msg_level
                 END ;

              END IF; -- l_err_code

              OPEN l_project_number_unique_csr( p_project_number );
              FETCH l_project_number_unique_csr INTO l_DUMMY;
              CLOSE l_project_number_unique_csr;  -- Added for Bug#3876261

              if (pa_project_utils.check_unique_project_number (p_project_number, NULL) = 0)
               then
                      PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name      => 'PA_PR_EPR_PROJ_NUM_NOT_UNIQUE');
               END IF;

            END IF; -- l_update_proj_num_allowed
         END IF; -- p_project_number

     END IF; -- p_project_number

 ELSIF PA_PROJECT_UTILS.GetProjNumMode = 'AUTOMATIC' THEN
   -- Cannot modify project number if numbering mode is AUTOMATIC
   IF p_project_number <> l_project_old_rec.segment1 THEN
     PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                          p_msg_name       => 'PA_CANT_CHANGE_PROJ_NUM');
   END IF;

 END IF;   -- PA_PROJECT_UTILS.GetProjNumMode

--dbms_output.put_line('Check PROJECT NAME ... ');

--PROJECT NAME

     IF (p_debug_mode = 'Y')
     THEN
        pa_debug.debug('Validate_project_info PVT: project name validation');
     END IF;

     IF p_project_name IS NOT NULL
     THEN
        IF p_project_name <> l_project_old_rec.name
        THEN

           -- anlee project actions changes
           IF l_update_proj_name_allowed = 'N' THEN
             PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name      => 'PA_PM_PROJ_NAME_ERR');
           ELSE

             if (pa_project_utils.check_unique_project_name (p_project_name, NULL) = 0)
             then
                PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name      => 'PA_PR_EPR_PROJ_NAME_NOT_UNIQUE');
             END IF;  -- l_project_name_unique_csr
           END IF; -- l_update_proj_name_allowed

        END IF;  -- p_project_in.project_name

     END IF;    -- p_project_in.project_name

-- anlee
-- Project Long Name changes

     IF (p_debug_mode = 'Y')
     THEN
        pa_debug.debug('Validate_project_info PVT: project long name validation');
     END IF;

     IF p_long_name IS NOT NULL
     THEN
        IF p_long_name <> l_project_old_rec.long_name
        THEN

           if (pa_project_utils.check_unique_long_name (p_long_name, NULL) = 0)
           then
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name      => 'PA_PR_EPR_LONG_NAME_NOT_UNIQUE');
           END IF;

        END IF;

     END IF;

-- End of changes

-- PROJECT DESCRIPTION
-- anlee project actions changes
  IF p_description <> l_project_old_rec.description
  THEN
    if l_update_proj_desc_allowed = 'N' then
      PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                           p_msg_name       => 'PA_PM_PROJ_DESC_ERR');
    end if;
  ELSIF (p_description is null and l_project_old_rec.description is not null) OR
        (p_description is not null and l_project_old_rec.description is null) THEN
    if l_update_proj_desc_allowed = 'N' then
      PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                           p_msg_name       => 'PA_PM_PROJ_DESC_ERR');
    end if;
  END IF;
-- anlee end of changes

-- dbms_output.put_line('Check Project Type Changes ... ');

-- PROJECT TYPE CHANGES
-- anlee
-- Added validations for bug 2327927
   IF (p_debug_mode = 'Y')
      THEN
         pa_debug.debug('Validate_project_info PVT: project type validation');
      END IF;

   if p_project_Type is not null and p_project_type <> l_project_old_rec.project_type Then

      -- This procedure checks if a project  has CDLs,Rev  or
      -- Draft invoices.If project has any of
      -- these information, then it's not ok to change the project
      -- type or org and specific reason will be returned.
      --
      -- If it's ok to change project type or org,
      -- the x_err_code will be 0.
      --
      pa_project_utils.change_pt_org_ok(p_project_id,
                                        l_err_code,
                                        l_err_stage,
                                        l_err_stack);
      if l_err_code <> 0 Then
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name      => 'PA_PR_CANT_CHG_PROJ_TYPE');
      else
         -- Check whether funding exists (if it exists cannot change from contract
         -- to non-contract project)

         OPEN get_project_type_class_code(p_project_type);
         FETCH get_project_type_class_code INTO l_project_type_class_code;
         CLOSE get_project_type_class_code;

         OPEN get_project_type_class_code(l_project_old_rec.project_type);
         FETCH get_project_type_class_code INTO l_old_project_type_class_code;
         CLOSE get_project_type_class_code;

         if (l_project_type_class_code <> 'CONTRACT')
            AND (nvl(l_old_project_type_class_code, l_project_type_class_code) <> l_project_type_class_code) then

            if (pa_project_utils.check_proj_funding (p_project_id)) <> 0 Then
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_PR_CANT_CHG_DIR_TO_INDIR');
               l_project_type_error := TRUE;
            end if;
         end if;
          --maansari bug 3068806
          --moved the following code from below
          OPEN  get_project_type_info (p_project_type);
          FETCH get_project_type_info INTO l_project_type_rec;
          CLOSE get_project_type_info;

--bug#2984611
          IF l_project_type_rec.cc_prvdr_flag = 'Y'
          THEN
            l_status_code := pa_project_utils.check_ic_proj_type_allowed(p_project_id,'Y');
            IF nvl(l_status_code ,0) <> 0 THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_IC_PT_NOT_ALLOWED');
              l_project_type_error := TRUE;
            ELSE
              IF l_project_old_rec.multi_currency_billing_flag = 'Y' THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_PR_CANT_CHG_IC_BIL_PT');
              l_project_type_error := TRUE;

              END IF ;
            END IF ;
          END IF ;
--bug#2984611

/**********
The commented validation has been moved above as part of fix for bug#2984611
          IF l_project_old_rec.project_type IS NOT NULL AND
            p_project_type <> l_project_old_rec.project_type AND
            l_project_type_rec.cc_prvdr_flag = 'Y' AND
            l_project_old_rec.multi_currency_billing_flag = 'Y'
          THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_PR_CANT_CHG_IC_BIL_PT');
              l_project_type_error := TRUE;

          END IF;
*************/
          --end maansari bug 3068806

         if l_project_type_error = FALSE then

            /* Moved this up for bug 3068806
            OPEN  get_project_type_info (p_project_type);
            FETCH get_project_type_info INTO l_project_type_rec;
            CLOSE get_project_type_info;
            */
            --bug 3068781

            DECLARE
                 CURSOR cur_job_cur IS SELECT rate_sch_currency_code FROM pa_std_bill_rate_schedules_all
                               WHERE bill_rate_sch_id = l_project_type_rec.job_bill_rate_schedule_id ;

                 CURSOR cur_emp_cur IS SELECT rate_sch_currency_code FROM pa_std_bill_rate_schedules_all
                               WHERE bill_rate_sch_id = l_project_type_rec.emp_bill_rate_schedule_id ;

                 CURSOR cur_nl_cur IS SELECT rate_sch_currency_code FROM pa_std_bill_rate_schedules_all
                               WHERE bill_rate_sch_id = l_project_type_rec.non_lab_std_bill_rt_sch_id ;

                 CURSOR cur_impl IS SELECT default_rate_type FROM pa_implementations;

                 x_job_rate_sch_currency  VARCHAR2(30);
                 x_emp_rate_sch_currency  VARCHAR2(30);
                 x_nl_rate_sch_currency   VARCHAR2(30);
                 x_default_rate_type      VARCHAR2(30);

            BEGIN
                IF l_project_type_rec.cc_prvdr_flag = 'N'  --This is not required if the project type is IC billing.  bug 2179904
                THEN
                    OPEN cur_job_cur;
                    FETCH cur_job_cur INTO x_job_rate_sch_currency ;
                    CLOSE cur_job_cur;

                    OPEN cur_emp_cur;
                    FETCH cur_emp_cur INTO x_emp_rate_sch_currency ;
                    CLOSE cur_emp_cur;

                    OPEN cur_nl_cur;
                    FETCH cur_nl_cur INTO x_nl_rate_sch_currency ;
                    CLOSE cur_nl_cur;

                IF x_job_rate_sch_currency is not Null and
                       x_job_rate_sch_currency <> l_project_old_rec.projfunc_currency_code
                    THEN
                       l_multi_currency_billing_flag := 'Y';
                    ELSIF x_emp_rate_sch_currency is not Null and
                       x_emp_rate_sch_currency <> l_project_old_rec.projfunc_currency_code
                    THEN
                       l_multi_currency_billing_flag := 'Y';
                    ELSIF x_nl_rate_sch_currency is not Null and
                       x_nl_rate_sch_currency <> l_project_old_rec.projfunc_currency_code
                    THEN
                       l_multi_currency_billing_flag := 'Y';
                    END IF;

                END IF;

                IF l_project_type_rec.cc_prvdr_flag = 'N' AND
                   l_project_old_rec.multi_currency_billing_flag = 'N' AND
                   NVL( l_multi_currency_billing_flag, 'N') = 'Y'
                THEN
                       OPEN cur_impl;
                       FETCH cur_impl INTO x_default_rate_type ;
                       CLOSE cur_impl;

                       l_PROJFUNC_BIL_RATE_TYPE := x_default_rate_type;
                       l_PROJECT_BIL_RATE_TYPE := x_default_rate_type;
                       l_FUNDING_RATE_TYPE := x_default_rate_type;

                       l_PROJFUNC_BIL_RATE_DATE_CODE := 'PA_INVOICE_DATE';
                       l_PROJECT_BIL_RATE_DATE_CODE := 'PA_INVOICE_DATE';
                       l_FUNDING_RATE_DATE_CODE := 'PA_INVOICE_DATE';
                       l_BTC_COST_BASE_REV_CODE := 'EXP_TRANS_CURR';

                       UPDATE pa_project_customers
                          SET inv_rate_type = x_default_rate_type
                        WHERE project_id = p_project_id;
                ELSE
                       l_PROJFUNC_BIL_RATE_TYPE := l_project_old_rec.PROJFUNC_BIL_RATE_TYPE;
                       l_PROJECT_BIL_RATE_TYPE := l_project_old_rec.PROJECT_BIL_RATE_TYPE;
                       l_FUNDING_RATE_TYPE := l_project_old_rec.FUNDING_RATE_TYPE;

                       l_PROJFUNC_BIL_RATE_DATE_CODE := l_project_old_rec.PROJFUNC_BIL_RATE_DATE_CODE;
                       l_PROJECT_BIL_RATE_DATE_CODE := l_project_old_rec.PROJECT_BIL_RATE_DATE_CODE;
                       l_FUNDING_RATE_DATE_CODE := l_project_old_rec.FUNDING_RATE_DATE_CODE;
                       l_BTC_COST_BASE_REV_CODE := l_project_old_rec.BTC_COST_BASE_REV_CODE;

                END IF;
            END;
            --end bug 3068781


            open  get_unassigned_time (p_project_type);
            fetch get_unassigned_time into l_unassigned_time;
            close get_unassigned_time;

            -- Update project attributes from project_type
            if nvl(l_unassigned_time,'N') ='Y' then
               UPDATE pa_projects_all  -- Bug#3807805 : Modifed pa_projects to pa_projects_all
               SET    role_list_id                  = l_project_type_rec.role_list_id,
                      work_type_id                  = l_project_type_rec.work_type_id,
                      cost_ind_rate_sch_id          = l_project_type_rec.cost_ind_rate_sch_id,
                      labor_sch_type                = l_project_type_rec.labor_sch_type,
                      labor_bill_rate_org_id        = l_project_type_rec.labor_bill_rate_org_id,
                      labor_std_bill_rate_schdl     = l_project_type_rec.labor_std_bill_rate_schdl,
                      non_labor_sch_type            = l_project_type_rec.non_labor_sch_type,
                      non_labor_bill_rate_org_id    = l_project_type_rec.non_labor_bill_rate_org_id,
                      non_labor_std_bill_rate_schdl = l_project_type_rec.non_labor_std_bill_rate_schdl,
                      rev_ind_rate_sch_id           = l_project_type_rec.rev_ind_rate_sch_id,
                      inv_ind_rate_sch_id           = l_project_type_rec.inv_ind_rate_sch_id,
                      labor_invoice_format_id       = l_project_type_rec.labor_invoice_format_id,
                      non_labor_invoice_format_id   = l_project_type_rec.non_labor_invoice_format_id,
                      billing_offset                = l_project_type_rec.billing_offset,
                      billing_cycle_id              = l_project_type_rec.billing_cycle_id,
                      bill_job_group_id             = l_project_type_rec.bill_job_group_id,
                      cost_job_group_id             = l_project_type_rec.cost_job_group_id,
                      emp_bill_rate_schedule_id     = l_project_type_rec.emp_bill_rate_schedule_id,
                      job_bill_rate_schedule_id     = l_project_type_rec.job_bill_rate_schedule_id,
                      project_status_code           = l_project_type_rec.def_start_proj_status_code,
--bug 3068781
--                      multi_currency_billing_flag   = decode(l_project_type_rec.cc_prvdr_flag, 'Y', 'N', multi_currency_billing_flag),
                      multi_currency_billing_flag   = NVL( l_multi_currency_billing_flag,multi_currency_billing_flag ),
                       PROJFUNC_BIL_RATE_TYPE       = l_PROJFUNC_BIL_RATE_TYPE,
                       PROJECT_BIL_RATE_TYPE        = l_PROJECT_BIL_RATE_TYPE,
                       FUNDING_RATE_TYPE            = l_FUNDING_RATE_TYPE,
                       PROJFUNC_BIL_RATE_DATE_CODE  = l_PROJFUNC_BIL_RATE_DATE_CODE,
                       PROJECT_BIL_RATE_DATE_CODE   = l_PROJECT_BIL_RATE_DATE_CODE,
                       FUNDING_RATE_DATE_CODE       = l_FUNDING_RATE_DATE_CODE,
                       BTC_COST_BASE_REV_CODE     = l_BTC_COST_BASE_REV_CODE,
--end bug 3068781
                      cc_process_labor_flag         = 'N',
                      cc_process_nl_flag            = 'N',
                      nl_tp_schedule_id             =  null,
                      labor_tp_schedule_id          =  null,
                      nl_tp_fixed_date              =  null,
                      labor_tp_fixed_date           =  null,
-- anlee
-- patchset K changes
                      revaluate_funding_flag        = l_project_type_rec.revaluate_funding_flag,
                      include_gains_losses_flag   = l_project_type_rec.include_gains_losses_flag,
-- End of changes
--PA L Changes 2872708
                      asset_allocation_method    = l_project_type_rec.asset_allocation_method,
                      capital_event_processing   = l_project_type_rec.capital_event_processing,
                      CINT_RATE_SCH_ID           = l_project_type_rec.CINT_RATE_SCH_ID,
--federal changes by sunkalya. Bug#5511353.
		      date_eff_funds_consumption = nvl(l_project_type_rec.date_eff_funds_consumption,'N')
--federal changes by sunkalya. Bug#5511353.
--End PA L Changes 2872708
               WHERE  project_id   = p_project_id;
            else
               UPDATE pa_projects_all  -- Bug#3807805 : Modifed pa_projects to pa_projects_all
               SET    role_list_id                  = l_project_type_rec.role_list_id,
                      work_type_id                  = l_project_type_rec.work_type_id,
                     -- service_type_code             = l_project_type_rec.service_type_code,
                      cost_ind_rate_sch_id          = l_project_type_rec.cost_ind_rate_sch_id,
                      labor_sch_type                = l_project_type_rec.labor_sch_type,
                      labor_bill_rate_org_id        = l_project_type_rec.labor_bill_rate_org_id,
                      labor_std_bill_rate_schdl     = l_project_type_rec.labor_std_bill_rate_schdl,
                      non_labor_sch_type            = l_project_type_rec.non_labor_sch_type,
                      non_labor_bill_rate_org_id    = l_project_type_rec.non_labor_bill_rate_org_id,
                      non_labor_std_bill_rate_schdl = l_project_type_rec.non_labor_std_bill_rate_schdl,
                      rev_ind_rate_sch_id           = l_project_type_rec.rev_ind_rate_sch_id,
                      inv_ind_rate_sch_id           = l_project_type_rec.inv_ind_rate_sch_id,
                      labor_invoice_format_id       = l_project_type_rec.labor_invoice_format_id,
                      non_labor_invoice_format_id   = l_project_type_rec.non_labor_invoice_format_id,
                      billing_offset                = l_project_type_rec.billing_offset,
                      billing_cycle_id              = l_project_type_rec.billing_cycle_id,
                      bill_job_group_id             = l_project_type_rec.bill_job_group_id,
                      cost_job_group_id             = l_project_type_rec.cost_job_group_id,
                      emp_bill_rate_schedule_id     = l_project_type_rec.emp_bill_rate_schedule_id,
                      job_bill_rate_schedule_id     = l_project_type_rec.job_bill_rate_schedule_id,
                      project_status_code           = l_project_type_rec.def_start_proj_status_code,
--bug 3068781
--                      multi_currency_billing_flag   = decode(l_project_type_rec.cc_prvdr_flag, 'Y', 'N', multi_currency_billing_flag),
                      multi_currency_billing_flag   = NVL( l_multi_currency_billing_flag,multi_currency_billing_flag ),
                       PROJFUNC_BIL_RATE_TYPE       = l_PROJFUNC_BIL_RATE_TYPE,
                       PROJECT_BIL_RATE_TYPE        = l_PROJECT_BIL_RATE_TYPE,
                       FUNDING_RATE_TYPE            = l_FUNDING_RATE_TYPE,
                       PROJFUNC_BIL_RATE_DATE_CODE  = l_PROJFUNC_BIL_RATE_DATE_CODE,
                       PROJECT_BIL_RATE_DATE_CODE   = l_PROJECT_BIL_RATE_DATE_CODE,
                       FUNDING_RATE_DATE_CODE       = l_FUNDING_RATE_DATE_CODE,
                       BTC_COST_BASE_REV_CODE     = l_BTC_COST_BASE_REV_CODE,
--bug end 3068781
-- anlee
-- patchset K changes
                      revaluate_funding_flag        = l_project_type_rec.revaluate_funding_flag,
                      include_gains_losses_flag   = l_project_type_rec.include_gains_losses_flag,
-- End of changes
--PA L Changes 2872708
                      asset_allocation_method    = l_project_type_rec.asset_allocation_method,
                      capital_event_processing   = l_project_type_rec.capital_event_processing,
                      CINT_RATE_SCH_ID           = l_project_type_rec.CINT_RATE_SCH_ID,
--End PA L Changes 2872708
--federal changes by sunkalya. Bug#5511353.
		      date_eff_funds_consumption = nvl(l_project_type_rec.date_eff_funds_consumption,'N')
--federal changes by sunkalya. Bug#5511353.
               WHERE  project_id   = p_project_id;
            end if; -- nvl(l_unassigned_time,'N') ='Y'

            -- BUZA changes
            -- Delete existing budgetary control options for the old project type
            DELETE FROM PA_BUDGETARY_CONTROL_OPTIONS
            WHERE PROJECT_ID = P_PROJECT_ID;

            -- Set cc_tax_task_id if project is a template and cc_prvdr_flag = 'N'
            if (l_project_old_rec.template_flag = 'Y') AND (l_project_type_rec.cc_prvdr_flag = 'N') then
               UPDATE pa_projects_all  -- Bug#3807805 : Modifed pa_projects to pa_projects_all
               SET    cc_tax_task_id = NULL
               WHERE  project_id = p_project_id;
            end if;


	    --Federal changes by sunkalya.Bug#5511353.
	    --Manipulate the customer bill splits w.r.t to the
	    --date_eff_funds_flag from the new type.
	    DECLARE

	    hghst_ctr_cust_id   NUMBER;
	    l_return_status	VARCHAR2(10);
            l_msg_count		NUMBER := 0;
            l_msg_data		VARCHAR2(2000);

	    BEGIN

		IF l_project_type_rec.date_eff_funds_consumption ='Y' THEN

			UPDATE pa_project_customers
			SET
			CUSTOMER_BILL_SPLIT = NULL
			WHERE
			PROJECT_ID = p_project_id;

		ELSIF nvl(l_project_old_rec.date_eff_funds_consumption,'N') = 'Y'  AND l_project_old_rec.enable_top_task_customer_flag = 'N' THEN
			--This api will determine which customer to be made as 100% contributor.
			PA_CUSTOMERS_CONTACTS_UTILS.Get_Highest_Contr_Fed_Cust(
						   P_API_VERSION            => 1.0
						 , P_INIT_MSG_LIST          => 'T'
						 , P_COMMIT                 => 'F'
						 , P_VALIDATE_ONLY          => 'F'
						 , P_VALIDATION_LEVEL       => 100
						 , P_DEBUG_MODE             => 'N'
						 , p_calling_module         => 'AMG'
						 , p_project_id             => p_project_id
						 , x_highst_contr_cust_id   => hghst_ctr_cust_id
						 , x_return_status          => l_return_status
						 , x_msg_count              => l_msg_count
						 , x_msg_data               => l_msg_data );

			IF hghst_ctr_cust_id IS NOT NULL AND l_return_status = FND_API.G_RET_STS_SUCCESS THEN

					UPDATE pa_project_customers SET customer_bill_split = 100
					WHERE customer_id = hghst_ctr_cust_id AND project_id = p_project_id;

					UPDATE pa_project_customers SET customer_bill_split = 0
					WHERE customer_id <> hghst_ctr_cust_id AND project_id = p_project_id;
			END IF;
		END IF;

	   END;

           --Federal changes by sunkalya.Bug#5511353.


            -- Update PA_TASKS with project type values
           OPEN get_billable_cap_flag(l_project_type_rec.work_type_id);
           FETCH get_billable_cap_flag INTO l_billable_capitalizable_flag;
           CLOSE get_billable_cap_flag;

           UPDATE pa_tasks
           SET    work_type_id                    = l_project_type_rec.work_type_id,
                  billable_flag                   = decode(NVL(PA_INSTALL.is_prm_licensed(),'N'), 'Y', l_billable_capitalizable_flag, 'N', billable_flag), /* added decode for bug#3481807 */
                  emp_bill_rate_schedule_id       = l_project_type_rec.emp_bill_rate_schedule_id,
                  job_bill_rate_schedule_id       = l_project_type_rec.job_bill_rate_schedule_id,
                  labor_sch_type                  = l_project_type_rec.labor_sch_type,
                  service_type_code               = l_project_type_rec.service_type_code,
                  cost_ind_rate_sch_id            = l_project_type_rec.cost_ind_rate_sch_id,
                  labor_bill_rate_org_id          = l_project_type_rec.labor_bill_rate_org_id,
                  labor_std_bill_rate_schdl       = l_project_type_rec.labor_std_bill_rate_schdl,
                  non_labor_sch_type              = l_project_type_rec.non_labor_sch_type,
                  non_labor_bill_rate_org_id      = l_project_type_rec.non_labor_bill_rate_org_id,
                  non_labor_std_bill_rate_schdl   = l_project_type_rec.non_labor_std_bill_rate_schdl,
                  rev_ind_rate_sch_id             = l_project_type_rec.rev_ind_rate_sch_id,
                  inv_ind_rate_sch_id             = l_project_type_rec.inv_ind_rate_sch_id
           WHERE  project_id = p_project_id;

           -- Update distribution rule
           OPEN get_dist_rule(p_project_type);
           FETCH get_dist_rule INTO l_distribution_rule;
           CLOSE get_dist_rule;

           UPDATE pa_projects_all  -- Bug#3807805 : Modifed pa_projects to pa_projects_all
           SET    distribution_rule = l_distribution_rule,
                  revenue_accrual_method = substr(l_distribution_rule,1,instr(l_distribution_rule,'/')-1), --Added for bug 8655611
                  invoice_method         = substr(l_distribution_rule,instr(l_distribution_rule,'/')+1)    --Added for bug 8655611
           WHERE  project_id = p_project_id;

         End If; -- l_project_type_error = FALSE
      end if; -- l_err_code <> 0

   end if; -- p_project_Type is not null and p_project_type <> l_project_old_rec.project_type
-- anlee end of changes

--dbms_output.put_line('Check CARRYING_OUT_ORGANIZATION_ID ... ');

     IF (p_debug_mode = 'Y')
     THEN
        pa_debug.debug('Validate_project_info PVT: Carrying out Organization validation');
     END IF;
--CARRYING_OUT_ORGANIZATION_ID
   IF (p_carrying_out_organization_id <> FND_API.G_MISS_NUM
       AND p_carrying_out_organization_id IS NOT NULL)
   THEN

       IF p_carrying_out_organization_id <>
          l_project_old_rec.carrying_out_organization_id
       THEN

         -- anlee project actions changes
         IF l_update_proj_org_allowed = 'N' THEN
           PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name       => 'PA_PM_PROJ_ORG_ERR');
         ELSE

            IF pa_project_pvt.check_valid_org
               (p_carrying_out_organization_id) = 'N' THEN
                   PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                            p_msg_name       => 'PA_INVALID_ORG');
            END IF;

--   Getting X_functional_security_flag through fnd_function_test function

           if fnd_function.test('PA_PAXPREPR_UPDATE_ORG') then
            function_flag := 'Y';  -- function returns TRUE
           else
            function_flag := 'N';  -- function returns FALSE
           end if;

            pa_project_utils2.validate_attribute_change(
              X_Context                => 'ORGANIZATION_VALIDATION'
             ,X_insert_update_mode     => NULL
             ,X_calling_module         => 'UPDATE_PROJECT'
             ,X_project_id             => p_project_id
             ,X_task_id                => NULL
             ,X_old_value              => To_char(l_project_old_rec.carrying_out_organization_id)
             ,X_new_value              => To_char(p_carrying_out_organization_id)
             ,X_project_type           => l_project_old_rec.project_type
             ,X_project_start_date     => l_project_old_rec.start_date
             ,X_project_end_date       => l_project_old_rec.completion_date
             ,X_public_sector_flag     => l_project_old_rec.public_sector_flag
             ,X_task_manager_person_id => NULL
             ,X_Service_type           => NULL
             ,X_task_start_date        => NULL
             ,X_task_end_date          => NULL
             ,X_entered_by_user_id     => FND_GLOBAL.USER_ID
             ,X_attribute_category     => l_project_old_rec.attribute_category
             ,X_attribute1             => l_project_old_rec.attribute1
             ,X_attribute2             => l_project_old_rec.attribute2
             ,X_attribute3             => l_project_old_rec.attribute3
             ,X_attribute4             => l_project_old_rec.attribute4
             ,X_attribute5             => l_project_old_rec.attribute5
             ,X_attribute6             => l_project_old_rec.attribute6
             ,X_attribute7             => l_project_old_rec.attribute7
             ,X_attribute8             => l_project_old_rec.attribute8
             ,X_attribute9             => l_project_old_rec.attribute9
             ,X_attribute10            => l_project_old_rec.attribute10
             ,X_pm_product_code        => l_project_old_rec.pm_product_code
             ,X_pm_project_reference   => l_project_old_rec.pm_project_reference
             ,X_pm_task_reference      => NULL
             ,X_functional_security_flag => function_flag
         ,x_warnings_only_flag     => l_warnings_only_flag --bug3134205
             ,X_err_code               => l_err_code
             ,X_err_stage              => l_err_stage
             ,X_err_stack              => l_err_stack );

           IF (l_err_code <> 0) /* AND (l_err_code <> 15) */ THEN  /* Commented the <> 15 condition for bug 2981386*/

              IF NOT pa_project_pvt.check_valid_message (l_err_stage) THEN

                 if l_err_stage = 'PA_INVALID_PT_CLASS_ORG' then

                 -- MOAC Changes: Bug 4363092 - removed nvl used with org_id
                    select  meaning
                    into    t_project_type_class_code
                    from    pa_project_types_all pt   -- Bug#3807805 : Modifed pa_project_types to pa_project_types_all
                          , pa_lookups lps
                   where  pt.project_type    = p_project_type
                     and  lps.lookup_type(+) = 'PROJECT TYPE CLASS'
                     and  lps.lookup_code(+) = pt.project_type_class_code
             and pt.org_id = PA_PROJECT_REQUEST_PVT.G_ORG_ID; -- Added the and condition for Bug#3807805

                   PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                        p_msg_name       => 'PA_INVALID_PT_CLASS_ORG',
                                        p_token1         => 'PT_CLASS',
                                        p_value1         => t_project_type_class_code);
                 else
                   PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name       => l_err_stage);

                 end if; -- l_err_stage = 'PA_INVALID_PT_CLASS_ORG'

              ELSE
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name       => l_err_stage);
              end if; -- NOT pa_project_pvt.check_valid_message

           END IF; -- (l_err_code <> 0) AND (l_err_code <> 15)


-- anlee
-- Added validations for bug 2327927

           pa_location_utils.Get_ORG_Location_Details
              (p_organization_id     => p_carrying_out_organization_id,
               x_country_name        => x_country_name,
               x_city                => x_city_name,
               x_region              => x_region_name,
               x_country_code        => x_country_code,
               x_return_status       => l_return_status,
               x_error_message_code  => l_error_msg_code);

           if l_return_status <> 'S' Then
                PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                     p_msg_name       => l_error_msg_code);
           End If;

-- Added for bug 2680595
           pa_location_utils.get_location(
                    p_country_code  => x_country_code,
                    p_city          => x_city_name,
                    p_region        => x_region_name,
                    x_return_status => l_return_status,
                    x_location_id   => x_location_id,
                    x_error_message_code => l_error_msg_code);

           if l_return_status <> 'S' Then
                PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                     p_msg_name       => l_error_msg_code);
           End If;

/*
Commented out for bug 2680595
           pa_location_utils.check_location_exists(
                    p_country_code  => x_country_code,
                    p_city          => x_city_name,
                    p_region        => x_region_name,
                    x_return_status => l_return_status,
                    x_location_id   => x_location_id);

           If x_location_id is null then

                 pa_locations_pkg.INSERT_ROW(
                  p_CITY               => x_city_name,
                  p_REGION             => x_region_name,
                  p_COUNTRY_CODE       => x_country_code,
                  p_CREATION_DATE       => sysdate,
                  p_CREATED_BY          => fnd_global.user_id,
                  p_LAST_UPDATE_DATE    => sysdate,
                  p_LAST_UPDATED_BY     => fnd_global.user_id,
                  p_LAST_UPDATE_LOGIN   => fnd_global.login_id,
                  X_ROWID               => x_rowid,
                  X_LOCATION_ID         => x_location_id);

          end if;
*/
          pa_schedule_pub.GET_PROJ_CALENDAR_DEFAULT
            ( p_proj_organization      => p_carrying_out_organization_id,
              p_project_id             => NULL,
              x_calendar_id            => l_calendar_id,
              x_calendar_name          => l_calendar_name,
              x_return_status          => l_return_status,
              x_msg_count              => l_msg_count,
              x_msg_data               => l_error_msg_code);

          if l_return_status <> 'S' Then
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => l_error_msg_code);
          End If; --l_return_status <> 'S'
-- anlee end of changes

         END IF; -- l_update_proj_org_allowed
        END IF; -- IF p_project_in.carrying_out_organization_id <>
                -- PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     END IF; -- IF p_project_in.carrying_out_organization_id <>
             -- l_project_rec.carrying_out_organization_id

-- anlee
-- Dates changes
-- target start date and target finish date validations
   IF(p_target_start_date IS NOT NULL AND p_target_finish_date IS NOT NULL) AND
     (p_target_start_date > p_target_finish_date) THEN

     PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                          p_msg_name       => 'PA_ENTERED_DATES_INVLD');
   END IF;
-- End of changes

-- anlee
-- Added validations for bug 2327927
--dbms_output.put_line('Check pa_project_pvt.check_start_end_date ... ');

   IF (p_debug_mode = 'Y')
   THEN
      pa_debug.debug('Validate_project_info PVT:  Start and completion date validation');
   END IF;

   l_project_start_date      := p_start_date;
   l_project_completion_date := p_completion_date;

   IF p_start_date = FND_API.G_MISS_DATE
   THEN l_project_start_date := NULL;
   END IF;

   IF p_completion_date = FND_API.G_MISS_DATE
   THEN l_project_completion_date := NULL;
   END IF;

   pa_project_pvt.check_start_end_date
   (p_old_start_date               => l_project_old_rec.start_date
   ,p_new_start_date               => l_project_start_date
   ,p_old_end_date                 => l_project_old_rec.completion_date
   ,p_new_end_date                 => l_project_completion_date
   ,p_update_start_date_flag       => l_update_start_date_flag
   ,p_update_end_date_flag         => l_update_end_date_flag
   ,p_return_status                => l_return_status );

   IF l_return_status <> 'S' THEN
      PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                           p_msg_name       => 'PA_SU_INVALID_DATES');
   else
      -- Do validation if start date has changed
      if (nvl(l_project_old_rec.start_date,FND_API.G_MISS_DATE) <>
          nvl(l_project_start_date,FND_API.G_MISS_DATE)) then --Bug 6408115

         -- anlee project actions changes
         IF l_update_proj_dates_allowed = 'N' THEN
           PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name       => 'PA_PM_PROJ_DATES_ERR');
         ELSE
           -- Check that project start date is less than min (task start dates)
           OPEN get_min_task_start_date;
           FETCH get_min_task_start_date INTO l_min_task_start_date;
           if (get_min_task_start_date%FOUND) AND (l_project_start_date is not null) then
              if l_min_task_start_date < l_project_start_date then
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                      p_msg_name       => 'PA_PR_INVALID_START_DATE');
                 l_start_date_error := TRUE;
              end if;
           end if;
           CLOSE get_min_task_start_date; -- Added for Bug#3876261
           -- Do not allow start date modification if there exists project level budget at completion
          if p_calling_module <> 'SETUP_PAGE' then  -- bug 7204572 added an IF condition
           if l_start_date_error = FALSE then
              if pa_budget_utils2.check_budget_at_compl_exists(p_project_id,null) = 'Y' then
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                      p_msg_name       => 'PA_PRJ_LVL_BUD_ERR');
                 l_start_date_error := TRUE;
              end if;
           end if;
          end if; -- end if for p_calling module bug 7204572
         END IF; -- l_update_proj_dates_allowed
      end if; -- l_project_old_rec.start_date <> l_project_start_date

      -- Do validation if completion date has changed
      if (nvl(l_project_old_rec.completion_date,FND_API.G_MISS_DATE) <>
          nvl(l_project_completion_date,FND_API.G_MISS_DATE)) then --Bug 6408115
        -- anlee project actions changes
        IF l_update_proj_dates_allowed = 'N' THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name       => 'PA_PM_PROJ_DATES_ERR');
        ELSE

          -- Check that project completion date is greater than max (task completion dates)
          OPEN get_max_task_completion_date;
          FETCH get_max_task_completion_date INTO l_max_task_completion_date;
          if (get_max_task_completion_date%FOUND) AND (l_project_completion_date is not null) then
             if l_max_task_completion_date > l_project_completion_date then
                PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                     p_msg_name       => 'PA_PR_INVALID_COMPLETION_DATE');
                l_completion_date_error := TRUE;
             end if;
          end if;
      CLOSE get_max_task_completion_date; -- Added for Bug#3876261

          -- Do not allow completion date modification if there exists project level budget at completion
         if p_calling_module <> 'SETUP_PAGE' then  -- bug 7204572 added an IF condition
          if l_completion_date_error = FALSE then
             if pa_budget_utils2.check_budget_at_compl_exists(p_project_id,null) = 'Y' then
                PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                     p_msg_name       => 'PA_PRJ_LVL_BUD_ERR');

            end if;
          end if;
         end if; -- end if for calling module bug 7204572

        END IF; -- l_update_proj_dates_allowed
      end if; -- l_project_old_rec.completion_date <> l_project_completion_date

   END IF; -- l_return_status <> 'S'
-- anlee end of changes


IF (p_debug_mode = 'Y')
THEN
    pa_debug.debug('Validate_project_info PVT:  Public sector flag validation');
END IF;
 IF p_public_sector_flag <> FND_API.G_MISS_CHAR AND
    p_public_sector_flag IS NOT NULL
 THEN
       IF  p_public_sector_flag <>   l_project_old_rec.public_sector_flag
       THEN
            IF p_public_sector_flag NOT IN ('Y','N')
            THEN
                     PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                          p_msg_name       => 'PA_PUBLIC_SECTOR_INVALID');
             END IF;
        END IF;
 END IF;


   IF (p_debug_mode = 'Y')
   THEN
      pa_debug.debug('Validate_project_info PVT:  project status validation');
   END IF;

   IF p_project_status_code <> FND_API.G_MISS_CHAR AND
      p_project_status_code IS NOT NULL
   THEN
      IF p_project_status_code <>
         l_project_old_rec.project_status_code THEN

         -- anlee project actions changes
         IF l_update_proj_status_allowed = 'N' THEN
           PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name       => 'PA_PM_PROJ_STATUS_ERR');
         ELSE
           IF pa_project_pvt.check_valid_project_status
              (p_project_status => p_project_status_code ) = 'N'
           THEN
                PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_PROJECT_STATUS_INVALID');
           END IF;
              -- special case for update to and from 'CLOSED'
           IF  Pa_project_stus_utils.is_project_status_closed
             (p_project_status_code) = 'Y' THEN
              l_closing_project := 'Y';
              l_project_status_changed := 'Y';

              -- anlee
              -- Added validations for bug 2327927
              UPDATE pa_projects_all  -- Bug#3807805 : Modifed pa_projects to pa_projects_all
              SET    closed_date = trunc(sysdate)
              WHERE  project_id = p_project_id;
              -- anlee end of changes
           ELSIF  Pa_project_stus_utils.is_project_status_closed
               (l_project_old_rec.project_status_code) = 'Y' THEN
                l_reopening_project := 'Y';
                l_project_status_changed := 'Y';
           ELSE
               l_project_status_changed := 'Y';
           END IF;
        END IF; -- l_update_proj_status_allowed
      END IF;
   END IF;

   -- Check Next Allowable Status

   IF p_project_status_code <> FND_API.G_MISS_CHAR AND
      p_project_status_code IS NOT NULL
   THEN
      IF p_project_status_code <>
         l_project_old_rec.project_status_code
      THEN
            x_status_changeable := PA_Project_Stus_Utils.allow_status_change
             (l_project_old_rec.project_status_code,
              p_project_status_code);

           IF  (x_status_changeable = 'N')
           THEN
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name       => 'PA_STATUS_CANT_CHANGE');
           END IF;
       END IF;
   END IF;

IF l_project_status_changed = 'Y' THEN
             Pa_project_stus_utils.Handle_Project_Status_Change
                (x_calling_module          => 'UPDATE_PROJECT'
                 ,X_project_id             => l_project_old_rec.project_id
                 ,X_old_proj_status_code   => l_project_old_rec.project_status_code
                 ,X_new_proj_status_code   => p_project_status_code
                 ,X_project_type           => l_project_old_rec.project_type
                 ,X_project_start_date     => l_project_old_rec.start_date
                 ,X_project_end_date       => l_project_old_rec.completion_date
                 ,X_public_sector_flag     => l_project_old_rec.public_sector_flag
                 ,X_attribute_category     => l_project_old_rec.attribute_category
                 ,X_attribute1             => l_project_old_rec.attribute1
                 ,X_attribute2             => l_project_old_rec.attribute2
                 ,X_attribute3             => l_project_old_rec.attribute3
                 ,X_attribute4             => l_project_old_rec.attribute4
                 ,X_attribute5             => l_project_old_rec.attribute5
                 ,X_attribute6             => l_project_old_rec.attribute6
                 ,X_attribute7             => l_project_old_rec.attribute7
                 ,X_attribute8             => l_project_old_rec.attribute8
                 ,X_attribute9             => l_project_old_rec.attribute9
                 ,X_attribute10            => l_project_old_rec.attribute10
                 ,X_pm_product_code        => l_project_old_rec.pm_product_code
                 ,x_init_msg               => 'N'
                 ,x_verify_ok_flag         => l_verify_ok_flag
                 ,x_wf_enabled_flag        => l_wf_enabled_flag
                 ,X_err_stage              => l_err_stage
                 ,X_err_stack              => l_err_stack
                 ,x_err_msg_count          => l_err_msg_count
                 ,x_warnings_only_flag     => l_warnings_only_flag );

             IF  l_verify_ok_flag = 'N' THEN
--                 x_return_status := 'E';
                   NULL;
--dbms_output.put_line('l_verify_ok_flag Check ERROR IORGANIZATION ERROR ... ');

             ELSIF l_verify_ok_flag = 'Y' THEN
                SELECT wf_status_code
                INTO l_wf_status_code
                FROM PA_PROJECTS_ALL
                WHERE project_id = p_project_id;

                if l_wf_status_code is null then
                  IF l_wf_enabled_flag = 'Y' THEN

                    -- update wf status in pa_projects_all
                    UPDATE pa_projects_all
                    SET wf_status_code = 'IN_ROUTE',
                        project_status_code = p_project_status_code
                    WHERE project_id = p_project_id;

                    pa_project_wf.start_project_wf
                    (  p_project_id
                     , l_err_stack
                     , l_err_stage
                     , l_err_code  );

                    If l_err_code <> 0 Then
                      PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                           p_msg_name       => l_err_stage);
                    end if;
                  end if;
                else
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_STATUS_CANT_CHANGE');
                end if;

             END IF;

END IF;

--dbms_output.put_line('Check LOCATION DETAILS ... ');

-- LOCATION DETAILS

   if p_location_id is not null and
      p_location_id <>   FND_API.G_MISS_NUM
   then
        x_location_id := p_location_id;
    else
        if p_territory_code is null or
           p_territory_code = FND_API.G_MISS_CHAR
        then
             open c2(p_country);
             fetch c2 into x_country_code;
             close c2;
         else
             x_country_code  := p_territory_code;
         end if;
/*
         open c1(x_country_code,p_state_region,p_city);
         fetch c1 into x_location_id;
         close c1;
*/
        IF (p_debug_mode = 'Y')
        THEN
            pa_debug.debug('Validate_project_info PVT:  location validation');
        END IF;
-- Modified for bug 2038542
--        If     p_city           is not null
--           and p_state_region   is not null
--           and x_country_code is not null then

         If x_country_code is not null then

            pa_location_utils.check_location_exists(
                       p_country_code  => x_country_code,
                       p_city          => p_city,
                       p_region        => p_state_region,
                       x_return_status => l_return_status,
                       x_location_id   => x_location_id);

         end if;

         If x_location_id is null or x_location_id = FND_API.G_MISS_NUM then

-- Modified for bug 2038542
--           If     p_city           is not null
--              and p_state_region   is not null
--              and x_country_code is not null then

             If x_country_code is not null then

                   IF (p_debug_mode = 'Y')
                   THEN
                      pa_debug.debug('Validate_project_info PVT:  location
                      table handler to insert new record');
                   End if;
                    pa_locations_pkg.INSERT_ROW(
                     p_CITY                => p_city,
                     p_REGION              => p_state_region,
                     p_COUNTRY_CODE        => x_country_code,
                     p_CREATION_DATE       => sysdate,
                     p_CREATED_BY          => fnd_global.user_id,
                     p_LAST_UPDATE_DATE    => sysdate,
                     p_LAST_UPDATED_BY     => fnd_global.user_id,
                     p_LAST_UPDATE_LOGIN   => fnd_global.login_id,
                     X_ROWID               => x_rowid,
                     X_LOCATION_ID         => x_location_id);

             End if;
          End if;
        end if;
        update pa_projects_all  -- Bug#3807805 : Modifed pa_projects to pa_projects_all
        set location_id = x_location_id
        where project_id = p_project_id;
  end if; -- P_calling_module 'BASIC_INFO'

  if (p_calling_module like ('ADDITIONAL_INFORMATION')) then
-- Cost job group defaulting logic.

    IF (p_debug_mode = 'Y')
    THEN
       pa_debug.debug('Validate_project_info PVT:  Additional information validation');
    END IF;
--dbms_output.put_line('INSDIE ADDITIONAL_INFORMATION PROCEDURE ...  ');

   IF nvl(p_bill_job_group_id, -999) <>
       nvl(l_project_old_rec.bill_job_group_id,-999)
   THEN

    IF (p_debug_mode = 'Y')
    THEN
       pa_debug.debug('Validate_project_info PVT:  Bill job group validation');
    END IF;
--dbms_output.put_line('BEFORE PA_PROJECTS_MAINT_UTILS.CHECK_BILL_JOB_GRP_REQ ');

      PA_PROJECTS_MAINT_UTILS.CHECK_BILL_JOB_GRP_REQ(
                              l_project_old_rec.project_type,
                              p_bill_job_group_id,
                              l_return_status,
                              l_error_msg_code);

--dbms_output.put_line('AFTER PA_PROJECTS_MAINT_UTILS.CHECK_BILL_JOB_GRP_REQ ');

      IF l_return_status = 'E'
      THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name  =>l_error_msg_code);
      END IF;

   END IF;

  end if; -- p_calling_module like ('ADDITIONAL_INFORMATION')

  if (p_calling_module like ('PIPELINE')) then

    IF (p_debug_mode = 'Y')
    THEN
       pa_debug.debug('Validate_project_info PVT:  pipeline validation');
    END IF;
    IF (p_debug_mode = 'Y')
    THEN
       pa_debug.debug('Validate_project_info PVT:  probability member id validation');
    END IF;

   If (p_project_value is not null and p_project_value < 0) then
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name  =>'PA_BU_NEED_POS_NUM');
   end if;

   IF nvl(p_probability_member_id, -999) <>
       nvl(l_project_old_rec.probability_member_id,-999)
   THEN

      PA_PROJECTS_MAINT_UTILS.CHECK_PROBABILITY_CAN_CHANGE(
                           l_project_old_rec.project_status_code,
                           l_return_status,
                           l_error_msg_code);
      IF l_return_status = 'E'
      THEN
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name  =>l_error_msg_code);
      END IF;
   END IF;
   open prob_per (p_probability_member_id);
   fetch prob_per into l_probability_member_id;
   close prob_per;
   IF l_probability_member_id is not null and p_expected_approval_date is null Then
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name  =>'PA_EXP_APP_DATE_REQUIRED');
   End if;

   IF l_probability_member_id is null and p_expected_approval_date is not null Then
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name  =>'PA_PROBA_PERCENT_REQUIRED');
   End if;

  end if; -- p_calling_module like ('PIPELINE')

 end if; -- p_validation_level > 0

 close l_project_details_csr;

EXCEPTION WHEN OTHERS THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECTS_MAINT_PVT',
                            p_procedure_name => 'VALIDATE_PROJECT_INFO',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    raise;

END VALIDATE_PROJECT_INFO;


-- API name     : Update_project_staffing_info
-- Type         : Public
-- Pre-reqs     : None.
-- Parameters           :
-- p_commit             IN VARCHAR2   Optional Default = FND_API.G_FALSE
-- p_validate_only      IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_validation_level   IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module     IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode         IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count      IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_project_id         IN NUMBER     Required
-- p_comp_match_weighting        IN    pa_projects_all.COMPETENCE_MATCH_WT%TYPE    Optional Default = FND_API.G_MISS_NUM
-- p_avail_match_weighting       IN    pa_projects_all.availability_match_wt%TYPE  Optional Default = FND_API.G_MISS_NUM
-- p_job_level_match_weighting   IN    pa_projects_all.job_level_match_wt%TYPE     Optional Default = FND_API.G_MISS_NUM
-- p_search_min_availability     IN    pa_projects_all.search_min_availability%TYPE       Optional Default = FND_API.G_MISS_NUM
-- p_search_country_code         IN    pa_projects_all.search_country_code%TYPE           Optional Default = FND_API.G_MISS_CHAR
-- p_search_country_name         IN    fnd_territories_vl.territory_short_name%TYPE       Optional Default = FND_API.G_MISS_CHAR,
-- p_search_exp_org_struct_ver_id IN   pa_projects_all.search_org_hier_id%TYPE  Optional Default = FND_API.G_MISS_NUM
-- p_search_exp_org_hier_name     IN per_organization_structures.name%TYPE       Optional Default = FND_API.G_MISS_CHAR,
-- p_search_exp_start_org_id     IN   pa_projects_all.search_starting_org_id%TYPE        Optional Default = FND_API.G_MISS_NUM
-- p_search_exp_start_org_name    IN hr_organization_units.name%TYPE                     Optional Default = FND_API.G_MISS_CHAR,
-- p_search_min_candidate_score  IN   pa_projects_all.min_cand_score_reqd_for_nom%TYPE     Optional Default = FND_API.G_MISS_NUM
-- p_enable_auto_cand_nom_flag    IN  pa_projects_all.enable_automated_search%TYPE      Optional Default = FND_API.G_MISS_CHAR
-- p_record_version_number IN NUMBER  Required
-- x_return_status     OUT VARCHAR2   Required
-- x_msg_count         OUT NUMBER     Required
-- x_msg_data          OUT VARCHAR2   Required
--
--  History
--
--           28-SEP-2000 --   hyau    - Created.
--
--
PROCEDURE UPDATE_PROJECT_STAFFING_INFO
(
 p_commit                       IN VARCHAR2   := FND_API.G_FALSE       ,
 p_validate_only                IN VARCHAR2     := FND_API.G_TRUE        ,
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
 p_search_exp_org_struct_ver_id IN pa_projects_all.search_org_hier_id%TYPE  := FND_API.G_MISS_NUM,
 p_search_exp_start_org_id      IN pa_projects_all.search_starting_org_id%TYPE       := FND_API.G_MISS_NUM,
 p_search_min_candidate_score   IN pa_projects_all.min_cand_score_reqd_for_nom%TYPE    := FND_API.G_MISS_NUM,
 p_enable_auto_cand_nom_flag    IN pa_projects_all.enable_automated_search%TYPE     := FND_API.G_MISS_CHAR,
 p_record_version_number        IN NUMBER                              ,
 x_return_status                OUT NOCOPY VARCHAR2                           , --File.Sql.39 bug 4440895
 x_msg_count                    OUT NOCOPY NUMBER                             , --File.Sql.39 bug 4440895
 x_msg_data                     OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

l_msg_count                     NUMBER;
l_msg_index_out                 NUMBER;
l_msg_data                            VARCHAR2(250);
l_data                          VARCHAR2(250);
l_dummy                         VARCHAR2(1);


l_comp_match_weighting          pa_projects_all.COMPETENCE_MATCH_WT%TYPE;
l_avail_match_weighting         pa_projects_all.availability_match_wt%TYPE;
l_job_level_match_weighting     pa_projects_all.job_level_match_wt%TYPE;
l_search_min_availability       pa_projects_all.search_min_availability%TYPE;
l_search_country_code           pa_projects_all.search_country_code%TYPE;
l_search_exp_org_struct_ver_id  pa_projects_all.search_org_hier_id%TYPE;
l_search_exp_start_org_id       pa_projects_all.search_starting_org_id%TYPE;
l_search_min_candidate_score    pa_projects_all.min_cand_score_reqd_for_nom%TYPE;
l_enable_auto_cand_nom_flag     pa_projects_all.enable_automated_search%TYPE;

BEGIN

    IF p_commit = FND_API.G_TRUE THEN
       SAVEPOINT update_project_staffing_info;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

      if (p_debug_mode = 'Y') then
         pa_debug.debug('Update_project_staffing_info PVT: locking record');
      end if;
  -- write your program logic from here
   if p_validate_only <> FND_API.G_TRUE then
     BEGIN
         SELECT 'x' INTO l_dummy
         FROM  pa_projects
         WHERE project_id             = p_project_id
           AND record_version_number  = p_record_version_number
           FOR UPDATE OF record_version_number NOWAIT;
         EXCEPTION WHEN TIMEOUT_ON_RESOURCE THEN
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
               x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
               x_return_status := FND_API.G_RET_STS_ERROR ;
           WHEN NO_DATA_FOUND THEN
            if p_calling_module = 'FORM' then
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                    p_msg_name       => 'FORM_RECORD_CHANGED');
               x_msg_data := 'FORM_RECORD_CHANGED';
            else
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_XC_RECORD_CHANGED');
               x_msg_data := 'PA_XC_RECORD_CHANGED';
            end if;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            WHEN OTHERS THEN
              IF SQLCODE = -54 THEN
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
                 x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
                 x_return_status := FND_API.G_RET_STS_ERROR ;
              ELSE
                raise;
              END IF;
       END;
   else
     BEGIN
         SELECT 'x' INTO l_dummy
         FROM  pa_projects
         WHERE project_id             = p_project_id
           AND record_version_number  = p_record_version_number;
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
            if p_calling_module = 'FORM' then
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                    p_msg_name       => 'FORM_RECORD_CHANGED');
               x_msg_data := 'FORM_RECORD_CHANGED';
            else
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_XC_RECORD_CHANGED');
               x_msg_data := 'PA_XC_RECORD_CHANGED';
            end if;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            WHEN OTHERS THEN
              IF SQLCODE = -54 THEN
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
                 x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
                 x_return_status := FND_API.G_RET_STS_ERROR ;
              ELSE
                  raise;
              END IF;
       END;
   end if;
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE  FND_API.G_EXC_ERROR;
   END IF;


   IF NOT FND_API.TO_BOOLEAN(p_validate_only)
   THEN
   if (p_debug_mode = 'Y') then
      pa_debug.debug('Update_project_staffing_info PVT: update pa_projects table');
    end if;
        if p_comp_match_weighting = FND_API.G_MISS_NUM then
        l_comp_match_weighting := null;
    else
        l_comp_match_weighting := p_comp_match_weighting;
    end if;

        if p_avail_match_weighting = FND_API.G_MISS_NUM then
        l_avail_match_weighting := null;
    else
        l_avail_match_weighting := p_avail_match_weighting;
    end if;

        if p_job_level_match_weighting = FND_API.G_MISS_NUM then
        l_job_level_match_weighting := null;
    else
        l_job_level_match_weighting := p_job_level_match_weighting;
    end if;

        if p_search_min_availability = FND_API.G_MISS_NUM then
        l_search_min_availability := null;
    else
        l_search_min_availability := p_search_min_availability;
    end if;

        if p_search_country_code = FND_API.G_MISS_CHAR then
        l_search_country_code := null;
    else
        l_search_country_code := p_search_country_code;
    end if;


        if p_search_exp_org_struct_ver_id = FND_API.G_MISS_NUM then
        l_search_exp_org_struct_ver_id := null;
    else
        l_search_exp_org_struct_ver_id := p_search_exp_org_struct_ver_id;
    end if;

        if p_search_exp_start_org_id = FND_API.G_MISS_NUM then
        l_search_exp_start_org_id := null;
    else
        l_search_exp_start_org_id := p_search_exp_start_org_id;
    end if;

        if p_search_min_candidate_score = FND_API.G_MISS_NUM then
        l_search_min_candidate_score := null;
    else
        l_search_min_candidate_score := p_search_min_candidate_score;
    end if;

        if p_enable_auto_cand_nom_flag = FND_API.G_MISS_CHAR then
        l_enable_auto_cand_nom_flag := null;
    else
        l_enable_auto_cand_nom_flag := p_enable_auto_cand_nom_flag;
    end if;

       UPDATE pa_projects_all
       SET record_version_number    = record_version_number +1 ,
       COMPETENCE_MATCH_WT      = p_comp_match_weighting,
       AVAILABILITY_MATCH_WT    = p_avail_match_weighting,
       JOB_LEVEL_MATCH_WT       = p_job_level_match_weighting,
       ENABLE_AUTOMATED_SEARCH  = p_enable_auto_cand_nom_flag,
       MIN_CAND_SCORE_REQD_FOR_NOM  = p_search_min_candidate_score,
       SEARCH_MIN_AVAILABILITY  = p_search_min_availability,
       SEARCH_ORG_HIER_ID       = p_search_exp_org_struct_ver_id,
       SEARCH_STARTING_ORG_ID   = p_search_exp_start_org_id,
       SEARCH_COUNTRY_CODE      = p_search_country_code
       WHERE project_id = p_project_id;
   END IF;

   IF FND_API.TO_BOOLEAN(P_COMMIT)
   THEN
      COMMIT WORK;
   END IF;

EXCEPTION WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO update_project_staffing_info;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
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

END PA_PROJECTS_MAINT_PVT;

/
