--------------------------------------------------------
--  DDL for Package Body PA_CUSTOMERS_CONTACTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CUSTOMERS_CONTACTS_PUB" AS
/* $Header: PARPCCPB.pls 120.4.12010000.2 2008/08/22 12:45:55 rballamu ship $ */


-- Global constant
G_PKG_NAME              CONSTANT VARCHAR2(30) := 'PA_CUSTOMERS_CONTACTS_PUB';


-- API name		: Create_Project_Customer
-- Type			: Public
-- Pre-reqs		: None.
-- Parameters           :
-- p_api_version                   IN NUMBER     Required Default = 1.0
-- p_init_msg_list                 IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_commit                        IN VARCHAR2   Required Default = FND_API.G_FALSE
-- p_validate_only                 IN VARCHAR2   Required Default = FND_API.G_TRUE
-- p_validation_level              IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module                IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode                    IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count                 IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_project_id                    IN NUMBER     Required
-- p_customer_id                   IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_customer_name                 IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_customer_number               IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_project_relationship_code     IN VARCHAR2   Required
-- p_customer_bill_split           IN NUMBER     Required
-- p_bill_to_customer_id            IN NUMBER    Optional Default = NULL                  /* For Bug 2731449 */
-- p_ship_to_customer_id            IN NUMBER    Optional Default = NULL                  /* For Bug 2731449 */
-- p_bill_to_address_id            IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_ship_to_address_id            IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_bill_site_name                IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_work_site_name                IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_inv_currency_code             IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_inv_rate_type                 IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_inv_rate_date                 IN DATE       Optional Default = FND_API.G_MISS_DATE
-- p_inv_exchange_rate             IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_allow_user_rate_type_flag     IN VARCHAR2   Required Default = 'N'
-- p_receiver_task_id              IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_receiver_project_name         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- x_customer_id                   OUT NUMBER    Required
-- x_return_status                 OUT VARCHAR2  Required
-- x_msg_count                     OUT NUMBER    Required
-- x_msg_data                      OUT VARCHAR2  Optional

PROCEDURE CREATE_PROJECT_CUSTOMER
(  p_api_version                   IN NUMBER     := 1.0
  ,p_init_msg_list                 IN VARCHAR2   := FND_API.G_TRUE
  ,p_commit                        IN VARCHAR2   := FND_API.G_FALSE
  ,p_validate_only                 IN VARCHAR2   := FND_API.G_TRUE
  ,p_validation_level              IN NUMBER     := FND_API.G_VALID_LEVEL_FULL
  ,p_calling_module                IN VARCHAR2   := 'SELF_SERVICE'
  ,p_debug_mode                    IN VARCHAR2   := 'N'
  ,p_max_msg_count                 IN NUMBER     := FND_API.G_MISS_NUM
  ,p_project_id                    IN NUMBER
  ,p_customer_id                   IN NUMBER     := FND_API.G_MISS_NUM
  ,p_customer_name                 IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_customer_number               IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_project_relationship_code     IN VARCHAR2
  ,p_customer_bill_split           IN NUMBER
  ,p_bill_to_customer_id           IN NUMBER     := FND_API.G_MISS_NUM      /* For Bug 2731449 */
  ,p_ship_to_customer_id           IN NUMBER     := FND_API.G_MISS_NUM      /* For Bug 2731449 */
  ,p_bill_to_customer_name         IN VARCHAR2   := FND_API.G_MISS_CHAR	    /* For Bug 2965841 */
  ,p_bill_to_customer_number       IN VARCHAR2   := FND_API.G_MISS_CHAR	    /* For Bug 2965841 */
  ,p_ship_to_customer_name         IN VARCHAR2   := FND_API.G_MISS_CHAR	    /* For Bug 2965841 */
  ,p_ship_to_customer_number       IN VARCHAR2   := FND_API.G_MISS_CHAR	    /* For Bug 2965841 */
  ,p_bill_to_address_id            IN NUMBER     := FND_API.G_MISS_NUM
  ,p_ship_to_address_id            IN NUMBER     := FND_API.G_MISS_NUM
  ,p_bill_site_name                IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_work_site_name                IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_inv_currency_code             IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_inv_rate_type                 IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_inv_rate_date                 IN DATE       := FND_API.G_MISS_DATE
  ,p_inv_exchange_rate             IN NUMBER     := FND_API.G_MISS_NUM
  ,p_allow_user_rate_type_flag     IN VARCHAR2   := 'N'
  ,p_receiver_task_id              IN NUMBER     := FND_API.G_MISS_NUM
--,p_receiver_project_name         IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,x_customer_id                   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                      OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
  ,p_project_party_id              IN NUMBER DEFAULT NULL
--Billing setup related changes for FP_M development. Tracking bug 3279981
  ,p_Default_Top_Task_Cust_Flag    IN VARCHAR2
  ,p_en_top_task_cust_flag         IN VARCHAR2   := 'N'
)
IS
   l_api_name                      CONSTANT VARCHAR(30) := 'Create_Project_Customer';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_customer_id                   NUMBER := null;
   l_bill_to_address_id            NUMBER;
   l_ship_to_address_id            NUMBER;
-- l_receiver_task_id              NUMBER;
   l_return_status                 VARCHAR2(1);
   l_error_msg_code                VARCHAR2(250);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;
   l_inv_currency_code             VARCHAR2(80);
/* START  For Bug 2731449 */
   l_cust_acc_rel_code             VARCHAR2(1);
   l_valid_bill_id                 Number;
   l_valid_ship_id                 Number;
   l_bill_to_customer_id            NUMBER;
   l_ship_to_customer_id            NUMBER;
   l_check_id_flag               VARCHAR2(1) := 'A'; -- Variable added by aditi for tracking bug

   CURSOR C1 IS
   Select cust_acc_rel_code
   From pa_implementations;

   CURSOR C2 IS
   SELECT related_cust_account_id
    FROM hz_cust_acct_relate
    WHERE cust_account_id = l_customer_id
    AND bill_to_flag = 'Y'
    AND status = 'A'
    AND related_cust_account_id = l_bill_to_customer_id;

    CURSOR C3 IS
   SELECT related_cust_account_id
    FROM hz_cust_acct_relate
    WHERE cust_account_id = l_customer_id
    AND ship_to_flag = 'Y'
    AND status = 'A'
    AND related_cust_account_id = l_ship_to_customer_id;

--Billing setup related changes for FP_M development. Tracking bug 3279981
    CURSOR C4 IS
    SELECT enable_top_task_customer_flag
    FROM pa_projects_all
    WHERE project_id = p_project_id;
    l_en_top_task_cust_flag VARCHAR2(1);

/* End  For Bug 2731449 */


--The following cursor has been added for federal changes by sunkalya bug#5511353
--sunkalya:federal bug#5511353
CURSOR cur_chk_funds_consumption_flag
IS
SELECT DATE_EFF_FUNDS_CONSUMPTION
FROM pa_projects_all
WHERE
project_id= p_project_id;

l_date_eff_funds_consumption VARCHAR2(1);

--End of federal changes by sunkalya
--sunkalya:federal bug#5511353

BEGIN
   pa_debug.init_err_stack('PA_CUSTOMERS_CONTACTS_PUB.Create_Project_Customer');
--dbms_output.put_line('11111111111 Value of p_customer_id'||p_customer_id);
   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_CUSTOMERS_CONTACTS_PUB.Create_Project_Customer BEGIN');
   end if;

   if p_commit = FND_API.G_TRUE then
      savepoint create_project_customer;
   end if;

   if not FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) then
      FND_MSG_PUB.initialize;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('Performing ID validations and conversions...');
   end if;

--Billing setup related changes for FP_M development. Tracking bug 3279981
   IF p_calling_module <> 'FORM' THEN
      OPEN C4;
      FETCH C4 INTO l_en_top_task_cust_flag;
      CLOSE C4;
   ELSE
      l_en_top_task_cust_flag := p_en_top_task_cust_flag;
   END IF;

--The following cursor has been added for federal changes by sunkalya
--sunkalya:federal bug#5511353

OPEN  cur_chk_funds_consumption_flag;
FETCH cur_chk_funds_consumption_flag INTO l_date_eff_funds_consumption;
CLOSE cur_chk_funds_consumption_flag;

--End of federal changes by sunkalya
--sunkalya:federal bug#5511353

   -- Required field validation
   -- This is currently necessary because these validations cannot be done on
   -- the self-service front end
   -- This will be removed once that technology is available
   -- Bug 2965841 : Added the code in front end so that these fields are mandatory. Hence the following code is not needed.
   -- But let it be here, no harm.
   --Billing setup related changes for FP_M development. Tracking bug 3279981. customer_bill_split can
   --be null in case customer at top task is enabled. Adding foll IF condition

--added the AND condition in the IF below for federal changes.Sunkalya
--sunkalya:federal bug#5511353

   IF l_en_top_task_cust_flag = 'N' AND nvl(l_date_eff_funds_consumption,'N') ='N' THEN --bug#5511353
        if p_customer_bill_split is NULL then
           PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                                ,p_msg_name       => 'PA_CUST_BILL_SPLIT_INVALID');
        end if;
   END IF;

--sunkalya:federal bug#5511353

   if p_project_relationship_code is NULL then
      PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_RELATIONSHIP_CODE_REQD');
   end if;


/* START  For Bug 2731449 */
-- checking for not null values as bill to customer and shipt to customer are mandatory  fields
 /* Amit 2965841 : Commented as not sufficent to check only for id. New check is added below.
   if p_bill_to_customer_id is NULL then
      PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_BILL_TO_CUST_NAME_REQD');
   end if;

   if p_ship_to_customer_id is NULL then
      PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_SHIP_TO_CUST_NAME_REQD');
   end if;
: Amit 2965841*/
/* End  For Bug 2731449 */
   -- End of required field validation

--dbms_output.put_line('22222222222222 Value of p_customer_id'||p_customer_id);

   if ((p_customer_name = FND_API.G_MISS_CHAR) OR (p_customer_name is NULL)) AND
      ((p_customer_number = FND_API.G_MISS_CHAR) OR (p_customer_number is NULL)) AND
      ((p_customer_id = FND_API.G_MISS_NUM) OR (p_customer_id is NULL)) then
      PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_CUST_NAME_OR_NUM_REQD');
   end if;
  -- Amit : Bug 2965841 New two checks are added below
   if ((p_bill_to_customer_name = FND_API.G_MISS_CHAR) OR (p_bill_to_customer_name is NULL)) AND
      ((p_bill_to_customer_number = FND_API.G_MISS_CHAR) OR (p_bill_to_customer_number is NULL)) AND
      ((p_bill_to_customer_id = FND_API.G_MISS_NUM) OR (p_bill_to_customer_id is NULL)) then
      PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_BILL_TO_CUST_NAME_REQD');
   end if;

   if ((p_ship_to_customer_name = FND_API.G_MISS_CHAR) OR (p_ship_to_customer_name is NULL)) AND
      ((p_ship_to_customer_number = FND_API.G_MISS_CHAR) OR (p_ship_to_customer_number is NULL)) AND
      ((p_ship_to_customer_id = FND_API.G_MISS_NUM) OR (p_ship_to_customer_id is NULL)) then
      PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_SHIP_TO_CUST_NAME_REQD');
   end if;

IF p_calling_module = 'AMG' THEN
 l_check_id_flag := 'N';
 END IF;

   if p_calling_module <> 'FORM' AND  p_calling_module <> 'SELF_SERVICE' THEN -- Added second condition of 4593317

          -- Check for Customer

	  -- Amit 2965841 : We shd first check for Number as it is unique. And if it is able to find the id then we shd skip the check for name
	   if ((p_customer_number <> FND_API.G_MISS_CHAR) AND (p_customer_number is not NULL)) OR
	      ((p_customer_id <> FND_API.G_MISS_NUM) AND (p_customer_id is not NULL)) then
	      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_CUSTOMER_NUMBER_OR_ID
	      ( p_customer_id     => p_customer_id
	       ,p_customer_number => p_customer_number
	       ,p_check_id_flag   => l_check_id_flag
	       ,x_customer_id     => l_customer_id
	       ,x_return_status   => l_return_status
	       ,x_error_msg_code  => l_error_msg_code);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => l_error_msg_code);
	      end if;
	   end if;
	   --dbms_output.put_line('33333333333 Value of p_customer_id'||p_customer_id);
--dbms_output.put_line('33333333333333 Value of l_customer_id'||l_customer_id);

	   if l_customer_id is null then -- Amit 2965841 :
		   if ((p_customer_name <> FND_API.G_MISS_CHAR) AND (p_customer_name is not NULL)) OR
		      ((p_customer_id <> FND_API.G_MISS_NUM) AND (p_customer_id is not NULL)) then
		      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_CUSTOMER_NAME_OR_ID
		      ( p_customer_id    => p_customer_id
		       ,p_customer_name  => p_customer_name
		       ,x_customer_id    => l_customer_id
		       ,x_return_status  => l_return_status
		       ,x_error_msg_code => l_error_msg_code);

		      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => l_error_msg_code);
		      end if;
		   end if;
	   end if; -- : Amit 2965841
  --dbms_output.put_line('44444444444 Value of p_customer_id'||p_customer_id);
--dbms_output.put_line('44444444444444 Value of l_customer_id'||l_customer_id);
	   if ((p_customer_name <> FND_API.G_MISS_CHAR) AND (p_customer_name is not NULL)) AND
	      ((p_customer_number <> FND_API.G_MISS_CHAR) AND (p_customer_number is not NULL)) THEN
	      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_CUSTOMER_NAME_AND_NUMBER
	      ( p_customer_name  => p_customer_name
	       ,p_customer_number => p_customer_number
	       ,x_customer_id    => l_customer_id
	       ,x_return_status  => l_return_status
	       ,x_error_msg_code => l_error_msg_code);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => l_error_msg_code);
	      end if;
	   end if;
	     --dbms_output.put_line('5555555 Value of p_customer_id'||p_customer_id);
--dbms_output.put_line('5555555555555 Value of l_customer_id'||l_customer_id);
       /* START  For Bug 2731449 */
-- check whether bill to and ship to customer passes are valid or not
      /* Amit : Not sufficient to check for id only. New code is added below
	   if(p_bill_to_customer_id <> NULL) THEN
		PA_CUSTOMERS_CONTACTS_UTILS.CHECK_CUSTOMER_NAME_OR_ID
		( p_customer_id    => p_bill_to_customer_id
		,p_check_id_flag  => 'Y'
		,x_customer_id    => l_bill_to_customer_id
		,x_return_status  => l_return_status
		,x_error_msg_code => l_error_msg_code);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => l_error_msg_code);
	      end if;
	   end if;

	   if(p_ship_to_customer_id <> NULL) THEN
		PA_CUSTOMERS_CONTACTS_UTILS.CHECK_CUSTOMER_NAME_OR_ID
		( p_customer_id    => p_ship_to_customer_id
		,p_check_id_flag  => 'Y'
		,x_customer_id    => l_ship_to_customer_id
		,x_return_status  => l_return_status
		,x_error_msg_code => l_error_msg_code);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => l_error_msg_code);
	      end if;
	   end if;
	   : Amit */

	  -- Check for Bill Customer
	  -- Amit 2965841 : We shd first check for Number as it is unique. And if it is able to find the id then we shd skip the check for name
--	if ((p_bill_to_customer_number is not null and p_bill_to_customer_number <> FND_API.G_MISS_CHAR)
--	   or (p_bill_to_customer_name is not null and p_bill_to_customer_name  <> FND_API.G_MISS_CHAR))
--         then
	   if ((p_bill_to_customer_number <> FND_API.G_MISS_CHAR) AND (p_bill_to_customer_number is not NULL)) OR
	      ((p_bill_to_customer_id <> FND_API.G_MISS_NUM) AND (p_bill_to_customer_id is not NULL)) then
	      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_CUSTOMER_NUMBER_OR_ID
	      ( p_customer_id     => p_bill_to_customer_id
	       ,p_customer_number => p_bill_to_customer_number
	       ,x_customer_id     => l_bill_to_customer_id
	       ,x_return_status   => l_return_status
	       ,x_error_msg_code  => l_error_msg_code);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name =>l_error_msg_code||'_BILL');-- Amit 2965841
	      end if;
	   end if;

	   if l_bill_to_customer_id is null then -- Amit 2965841:
		   if ((p_bill_to_customer_name <> FND_API.G_MISS_CHAR) AND (p_bill_to_customer_name is not NULL)) OR
		      ((p_bill_to_customer_id <> FND_API.G_MISS_NUM) AND (p_bill_to_customer_id is not NULL)) then
		      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_CUSTOMER_NAME_OR_ID
		      ( p_customer_id    => p_bill_to_customer_id
		       ,p_customer_name  => p_bill_to_customer_name
		       ,x_customer_id    => l_bill_to_customer_id
		       ,x_return_status  => l_return_status
		       ,x_error_msg_code => l_error_msg_code);

		      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => l_error_msg_code||'_BILL');-- Amit 2965841
		      end if;
		   end if;
	   end if; -- : Amit 2965841

	   if ((p_bill_to_customer_name <> FND_API.G_MISS_CHAR) AND (p_bill_to_customer_name is not NULL)) AND
	      ((p_bill_to_customer_number <> FND_API.G_MISS_CHAR) AND (p_bill_to_customer_number is not NULL)) THEN
	      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_CUSTOMER_NAME_AND_NUMBER
	      ( p_customer_name  => p_bill_to_customer_name
	       ,p_customer_number => p_bill_to_customer_number
	       ,x_customer_id    => l_bill_to_customer_id
	       ,x_return_status  => l_return_status
	       ,x_error_msg_code => l_error_msg_code);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	         if (l_error_msg_code = 'PA_CUST_NAME_NUMBER_INVALID') then
			 l_error_msg_code := l_error_msg_code||'_B';
		 else
			 l_error_msg_code := l_error_msg_code||'_BILL';
		 end if;
	         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => l_error_msg_code);
	      end if;
	   end if;
          --  Bug 2984882 : added following condition
          if (l_bill_to_customer_id is null and p_bill_to_customer_id is not null and p_bill_to_customer_id <> FND_API.G_MISS_NUM and l_return_status = FND_API.G_RET_STS_SUCCESS) then
              l_bill_to_customer_id:=p_bill_to_customer_id;
          end if;


	  -- Check for Ship Customer
	  -- Amit : We shd first check for Number as it is unique. And if it is able to find the id then we shd skip the check for name
	   if ((p_ship_to_customer_number <> FND_API.G_MISS_CHAR) AND (p_ship_to_customer_number is not NULL)) OR
	      ((p_ship_to_customer_id <> FND_API.G_MISS_NUM) AND (p_ship_to_customer_id is not NULL)) then
	      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_CUSTOMER_NUMBER_OR_ID
	      ( p_customer_id     => p_ship_to_customer_id
	       ,p_customer_number => p_ship_to_customer_number
	       ,x_customer_id     => l_ship_to_customer_id
	       ,x_return_status   => l_return_status
	       ,x_error_msg_code  => l_error_msg_code);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => l_error_msg_code||'_SHIP');-- Amit 2965841
	      end if;
	   end if;

	   if l_ship_to_customer_id is null then -- Amit 2965841:
		   if ((p_ship_to_customer_name <> FND_API.G_MISS_CHAR) AND (p_ship_to_customer_name is not NULL)) OR
		      ((p_ship_to_customer_id <> FND_API.G_MISS_NUM) AND (p_ship_to_customer_id is not NULL)) then
		      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_CUSTOMER_NAME_OR_ID
		      ( p_customer_id    => p_ship_to_customer_id
		       ,p_customer_name  => p_ship_to_customer_name
		       ,x_customer_id    => l_ship_to_customer_id
		       ,x_return_status  => l_return_status
		       ,x_error_msg_code => l_error_msg_code);

		      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => l_error_msg_code||'_SHIP');-- Amit 2965841
		      end if;
		   end if;
	   end if; -- : Amit	2965841


	   if ((p_ship_to_customer_name <> FND_API.G_MISS_CHAR) AND (p_ship_to_customer_name is not NULL)) AND
	      ((p_ship_to_customer_number <> FND_API.G_MISS_CHAR) AND (p_ship_to_customer_number is not NULL)) THEN
	      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_CUSTOMER_NAME_AND_NUMBER
	      ( p_customer_name  => p_ship_to_customer_name
	       ,p_customer_number => p_ship_to_customer_number
	       ,x_customer_id    => l_ship_to_customer_id
	       ,x_return_status  => l_return_status
	       ,x_error_msg_code => l_error_msg_code);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	         if (l_error_msg_code = 'PA_CUST_NAME_NUMBER_INVALID') then
			 l_error_msg_code := l_error_msg_code||'_S';
		 else
			 l_error_msg_code := l_error_msg_code||'_SHIP';
		 end if;
	         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => l_error_msg_code);
	      end if;
	   end if;

	  --  Bug 2984882 : added following condition
	  if (l_ship_to_customer_id is null and p_ship_to_customer_id is not null and p_ship_to_customer_id <> FND_API.G_MISS_NUM and l_return_status = FND_API.G_RET_STS_SUCCESS) then
              l_ship_to_customer_id:=p_ship_to_customer_id;
          end if;


-- get the value of customer relationship if value is yes then check for the validity of relations with project customers
          OPEN C1;
	  FETCH C1 into l_cust_acc_rel_code;
	  CLOSE C1;
	  IF l_cust_acc_rel_code = 'Y' THEN
           IF (l_bill_to_customer_id <> l_customer_id) THEN
                OPEN C2;
                FETCH C2 INTO l_valid_bill_id;
                    IF C2%NOTFOUND Then
                        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => 'PA_BILL_TO_NOT_VALID');
                    End If;
                CLOSE C2;  --Bug 3865203
            END IF;
        --BUG#2876256
            IF (l_ship_to_customer_id <> l_customer_id) THEN
                OPEN C3;
                FETCH C3 INTO l_valid_ship_id;
                    IF C3%NOTFOUND Then
                        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => 'PA_SHIP_TO_NOT_VALID');
                    End If;
                CLOSE C3;  --Bug 3865203
            END IF;
	   END If;

        /* End  For Bug 2731449 */
      	   /*changes for bug 7225756 start here*/

	   if ((p_bill_site_name <> FND_API.G_MISS_CHAR) AND (p_bill_site_name is not NULL)) AND
	      ((p_bill_to_address_id = FND_API.G_MISS_NUM) OR (p_bill_to_address_id is NULL)) then

	      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_BILL_SITE_NAME_OR_ID
	      ( p_customer_id        => l_bill_to_customer_id      /* For Bug 2731449 */
	       ,p_bill_to_address_id => p_bill_to_address_id
	       ,p_bill_site_name     => p_bill_site_name
	       ,x_bill_to_address_id => l_bill_to_address_id
	       ,x_return_status      => l_return_status
	       ,x_error_msg_code     => l_error_msg_code);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => l_error_msg_code);
	      end if;
	   end if;

      	   if ((p_bill_to_address_id <> FND_API.G_MISS_NUM) AND (p_bill_to_address_id is not NULL)) then

	      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_BILL_SITE_NAME_OR_ID
	      ( p_customer_id        => l_bill_to_customer_id      /* For Bug 2731449 */
	       ,p_bill_to_address_id => p_bill_to_address_id
	       ,p_bill_site_name     => p_bill_site_name
	       ,p_check_id_flag      => 'Y'  --bug 5563846
	       ,x_bill_to_address_id => l_bill_to_address_id
	       ,x_return_status      => l_return_status
	       ,x_error_msg_code     => l_error_msg_code);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => l_error_msg_code);
	      end if;
	   end if;


	   if((p_work_site_name <> FND_API.G_MISS_CHAR) AND (p_work_site_name is not NULL)) AND
	     ((p_ship_to_address_id = FND_API.G_MISS_NUM) OR (p_ship_to_address_id is NULL)) then
	      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_WORK_SITE_NAME_OR_ID
	      ( p_customer_id        => l_ship_to_customer_id      /* For Bug 2731449 */
	       ,p_ship_to_address_id => p_ship_to_address_id
	       ,p_work_site_name     => p_work_site_name
	       ,x_ship_to_address_id => l_ship_to_address_id
	       ,x_return_status      => l_return_status
	       ,x_error_msg_code     => l_error_msg_code);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => l_error_msg_code);
	      end if;
	   end if;

	   if((p_ship_to_address_id <> FND_API.G_MISS_NUM) AND (p_ship_to_address_id is not NULL)) then
	      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_WORK_SITE_NAME_OR_ID
	      ( p_customer_id        => l_ship_to_customer_id      /* For Bug 2731449 */
	       ,p_ship_to_address_id => p_ship_to_address_id
	       ,p_work_site_name     => p_work_site_name
	       ,p_check_id_flag      => 'Y' --bug 5563846
	       ,x_ship_to_address_id => l_ship_to_address_id
	       ,x_return_status      => l_return_status
	       ,x_error_msg_code     => l_error_msg_code);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => l_error_msg_code);
	      end if;
	   end if;


/*changes for bug 7225756 end here*/
	   /*
	   PA_CUSTOMERS_CONTACTS_UTILS.CHECK_RECEIVER_PROJ_NAME_OR_ID
	   ( p_receiver_task_id      => p_receiver_task_id
	    ,p_receiver_project_name => p_receiver_project_name
	    ,x_receiver_task_id      => l_receiver_task_id
	    ,x_return_status         => l_return_status
	    ,x_error_msg_code        => l_error_msg_code);

	   if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	      PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => l_error_msg_code);
	   end if;
	   */

           --Added by Ansari for currency name to code check.

           if (p_inv_currency_code <> FND_API.G_MISS_CHAR) AND
              (p_inv_currency_code is not NULL)
           then
               PA_PROJECTS_MAINT_UTILS.Check_currency_name_or_code
                   ( p_agreement_currency       => p_inv_currency_code
                    ,p_agreement_currency_name  => null
                    ,p_check_id_flag            => 'Y'
                    ,x_agreement_currency       => l_inv_currency_code
                    ,x_return_status            => l_return_status
                    ,x_error_msg_code           => l_error_msg_code);

              if l_return_status <> FND_API.G_RET_STS_SUCCESS then
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => l_error_msg_code);
              end if;
           end if;



   else
      	  l_customer_id := p_customer_id;
          l_bill_to_address_id :=  p_bill_to_address_id;
          l_ship_to_address_id :=  p_ship_to_address_id;
          l_inv_currency_code  :=  p_inv_currency_code;
	  l_bill_to_customer_id := p_bill_to_customer_id; -- For Bug 2978086
	  l_ship_to_customer_id := p_ship_to_customer_id; -- For Bug 2978086
  --dbms_output.put_line('9999999999 Value of p_customer_id'||p_customer_id);
--dbms_output.put_line('9999999999999 Value of l_customer_id'||l_customer_id);

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

-- For Bug 2978086 Adding this additional safe code below . If somehow ship and bill cst id is null(which shoule never be)
-- then populate it wioth cust id

IF l_bill_to_customer_id is null then
	l_bill_to_customer_id := l_customer_id;
END IF;
IF l_ship_to_customer_id is null then
	l_ship_to_customer_id := l_customer_id;
END IF;
--dbms_output.put_line('Before calling PA_CUSTOMERS_CONTACTS_PVT.CREATE_PROJECT_CUSTOMER');
--dbms_output.put_line('Before calling value of l_customer_id'||l_customer_id);

   PA_CUSTOMERS_CONTACTS_PVT.CREATE_PROJECT_CUSTOMER
   ( p_commit                    => FND_API.G_FALSE
    ,p_validate_only             => p_validate_only
    ,p_validation_level          => p_validation_level
    ,p_calling_module            => p_calling_module
    ,p_debug_mode                => p_debug_mode
    ,p_max_msg_count             => p_max_msg_count
    ,p_project_id                => p_project_id
    ,p_customer_id               => l_customer_id
    ,p_project_relationship_code => p_project_relationship_code
    ,p_customer_bill_split       => p_customer_bill_split
    ,p_bill_to_customer_id       => l_bill_to_customer_id            /* For Bug 2731449 */
    ,p_ship_to_customer_id       => l_ship_to_customer_id            /* For Bug 2731449 */
    ,p_bill_to_address_id        => l_bill_to_address_id
    ,p_ship_to_address_id        => l_ship_to_address_id
    ,p_inv_currency_code         => l_inv_currency_code
    ,p_inv_rate_type             => p_inv_rate_type
    ,p_inv_rate_date             => p_inv_rate_date
    ,p_inv_exchange_rate         => p_inv_exchange_rate
    ,p_allow_user_rate_type_flag => p_allow_user_rate_type_flag
    ,p_receiver_task_id          => p_receiver_task_id
    ,x_return_status             => l_return_status
    ,x_msg_count                 => l_msg_count
    ,x_msg_data                  => l_msg_data
    ,p_project_party_id          => p_project_party_id
--Billing setup related changes for FP_M development. Tracking bug 3279981
    ,p_Default_Top_Task_Cust_Flag =>  p_Default_Top_Task_Cust_Flag     );
--dbms_output.put_line('Before calling PA_CUSTOMERS_CONTACTS_PVT.CREATE_PROJECT_CUSTOMER l_return_status'||l_return_status);

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

   x_customer_id := l_customer_id;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if p_commit = FND_API.G_TRUE then
      commit work;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_CUSTOMERS_CONTACTS_PUB.Create_Project_Customer END');
   end if;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to create_project_customer;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to create_project_customer;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CUSTOMERS_CONTACTS_PUB',
                              p_procedure_name => 'Create_Project_Customer',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
   when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to create_project_customer;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CUSTOMERS_CONTACTS_PUB',
                              p_procedure_name => 'Create_Project_Customer',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END CREATE_PROJECT_CUSTOMER;


-- API name		: Update_Project_Customer
-- Type			: Public
-- Pre-reqs		: None.
-- Parameters           :
-- p_api_version                   IN NUMBER     Required Default = 1.0
-- p_init_msg_list                 IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_commit                        IN VARCHAR2   Required Default = FND_API.G_FALSE
-- p_validate_only                 IN VARCHAR2   Required Default = FND_API.G_TRUE
-- p_validation_level              IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module                IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode                    IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count                 IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_project_id                    IN NUMBER     Required
-- p_customer_id                   IN NUMBER     Required
-- p_project_relationship_code     IN VARCHAR2   Required
-- p_customer_bill_split           IN NUMBER     Required
-- p_bill_to_customer_id            IN NUMBER    Optional Default = NULL                      /* For Bug 2731449 */
-- p_ship_to_customer_id            IN NUMBER    Optional Default = NULL                      /* For Bug 2731449 */
-- p_bill_to_address_id            IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_ship_to_address_id            IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_bill_site_name                IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_work_site_name                IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_inv_currency_code             IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_inv_rate_type                 IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_inv_rate_date                 IN DATE       Optional Default = FND_API.G_MISS_DATE
-- p_inv_exchange_rate             IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_allow_user_rate_type_flag     IN VARCHAR2   Required Default = 'N'
-- p_receiver_task_id              IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_receiver_project_name         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_record_version_number         IN NUMBER     Required Default = FND_API.G_MISS_NUM
-- x_return_status                 OUT VARCHAR2  Required
-- x_msg_count                     OUT NUMBER    Required
-- x_msg_data                      OUT VARCHAR2  Optional

PROCEDURE UPDATE_PROJECT_CUSTOMER
(  p_api_version                   IN NUMBER     := 1.0
  ,p_init_msg_list                 IN VARCHAR2   := FND_API.G_TRUE
  ,p_commit                        IN VARCHAR2   := FND_API.G_FALSE
  ,p_validate_only                 IN VARCHAR2   := FND_API.G_TRUE
  ,p_validation_level              IN NUMBER     := FND_API.G_VALID_LEVEL_FULL
  ,p_calling_module                IN VARCHAR2   := 'SELF_SERVICE'
  ,p_debug_mode                    IN VARCHAR2   := 'N'
  ,p_max_msg_count                 IN NUMBER     := FND_API.G_MISS_NUM
  ,p_project_id                    IN NUMBER
  ,p_customer_id                   IN NUMBER
  ,p_project_relationship_code     IN VARCHAR2
  ,p_customer_bill_split           IN NUMBER
  ,p_bill_to_customer_id           IN NUMBER     := FND_API.G_MISS_NUM      /* For Bug 2731449 */
  ,p_ship_to_customer_id           IN NUMBER     := FND_API.G_MISS_NUM      /* For Bug 2731449 */
  ,p_bill_to_customer_name         IN VARCHAR2   := FND_API.G_MISS_CHAR	    /* For Bug 2965841 */
  ,p_bill_to_customer_number       IN VARCHAR2   := FND_API.G_MISS_CHAR	    /* For Bug 2965841 */
  ,p_ship_to_customer_name         IN VARCHAR2   := FND_API.G_MISS_CHAR	    /* For Bug 2965841 */
  ,p_ship_to_customer_number       IN VARCHAR2   := FND_API.G_MISS_CHAR	    /* For Bug 2965841 */
  ,p_bill_to_address_id            IN NUMBER     := FND_API.G_MISS_NUM
  ,p_ship_to_address_id            IN NUMBER     := FND_API.G_MISS_NUM
  ,p_bill_site_name                IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_work_site_name                IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_inv_currency_code             IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_inv_rate_type                 IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_inv_rate_date                 IN DATE       := FND_API.G_MISS_DATE
  ,p_inv_exchange_rate             IN NUMBER     := FND_API.G_MISS_NUM
  ,p_allow_user_rate_type_flag     IN VARCHAR2   := 'N'
  ,p_receiver_task_id              IN NUMBER     := FND_API.G_MISS_NUM
--,p_receiver_project_name         IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_bill_another_project_flag     IN VARCHAR2   := 'N' --Added by Aditi for tracking bug 4153629
  ,p_record_version_number         IN NUMBER     := FND_API.G_MISS_NUM
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
--Billing setup related changes for FP_M development. Tracking bug 3279981
  ,p_Default_Top_Task_Cust_Flag    IN VARCHAR2
  ,p_en_top_task_cust_flag         IN VARCHAR2   := 'N'
)
IS
   l_api_name                      CONSTANT VARCHAR(30) := 'Update_Project_Customer';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_bill_to_address_id            NUMBER;
   l_ship_to_address_id            NUMBER;
-- l_receiver_task_id              NUMBER;
   l_return_status                 VARCHAR2(1);
   l_error_msg_code                VARCHAR2(250);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;

   l_inv_rate_type                 VARCHAR2(100);
   l_project_currency_code         VARCHAR2(10);
   l_project_currency_code2        VARCHAR2(10);
   l_inv_currency_code             VARCHAR2(80);

/* START  For Bug 2731449 */
   l_cust_acc_rel_code             VARCHAR2(1);
   l_valid_bill_id                 Number;
   l_valid_ship_id                 Number;
   l_bill_to_customer_id            NUMBER := null;
   l_ship_to_customer_id            NUMBER := null;
   l_db_bill_to_customer_id            NUMBER;
   l_db_ship_to_customer_id            NUMBER;
   l_check_id_flag               VARCHAR2(1) := 'A'; -- Variable added by aditi for tracking bug

   CURSOR C2 IS
   Select cust_acc_rel_code
   From pa_implementations;

   CURSOR C3 IS
   SELECT related_cust_account_id
    FROM hz_cust_acct_relate
    WHERE cust_account_id = p_customer_id
    AND bill_to_flag = 'Y'
    AND status = 'A'
    AND related_cust_account_id = l_bill_to_customer_id;

    CURSOR C4 IS
   SELECT related_cust_account_id
    FROM hz_cust_acct_relate
    WHERE cust_account_id = p_customer_id
    AND ship_to_flag = 'Y'
    AND status = 'A'
    AND related_cust_account_id = l_ship_to_customer_id;

   CURSOR C1(c_project_id NUMBER) IS
      SELECT project_currency_code
      FROM pa_projects_all
      WHERE project_id = c_project_id;

   -- Changed reference from pa_project_customers_v (view) to pa_project_customers (base table)
   -- for Performance Bug 4878827 SQL ID 14907728
   CURSOR C5 IS
   SELECT bill_to_customer_id, ship_to_customer_id
   FROM pa_project_customers
   WHERE project_id = p_project_id
   AND customer_id = p_customer_id
   AND record_version_number = p_record_version_number;

--Billing setup related changes for FP_M development. Tracking bug 3279981
    CURSOR C6 IS
    SELECT enable_top_task_customer_flag
    FROM pa_projects_all
    WHERE project_id = p_project_id;
    l_en_top_task_cust_flag VARCHAR2(1);

/* END  For Bug 2731449 */

--The following cursor has been added for federal changes by sunkalya bug#5511353

CURSOR cur_chk_funds_consumption_flag
IS
SELECT DATE_EFF_FUNDS_CONSUMPTION
FROM pa_projects_all
WHERE
project_id= p_project_id;

l_date_eff_funds_consumption VARCHAR2(1);

--End of federal changes by sunkalya bug#5511353

BEGIN
   pa_debug.init_err_stack('PA_CUSTOMERS_CONTACTS_PUB.Update_Project_Customer');
   --dbms_output.put_line('value of p_project_relationship_code'||p_project_relationship_code);
   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_CUSTOMERS_CONTACTS_PUB.Update_Project_Customer BEGIN');
   end if;

   if p_commit = FND_API.G_TRUE then
      savepoint update_project_customer;
   end if;

   if not FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) then
      FND_MSG_PUB.initialize;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('Performing ID validations and conversions...');
   end if;

--Billing setup related changes for FP_M development. Tracking bug 3279981
   IF p_calling_module <> 'FORM' THEN
      OPEN C6;
      FETCH C6 INTO l_en_top_task_cust_flag;
      CLOSE C6;
   ELSE
      l_en_top_task_cust_flag := p_en_top_task_cust_flag;
   END IF;

--The following cursor has been added for federal changes by sunkalya bug#5511353

OPEN  cur_chk_funds_consumption_flag;
FETCH cur_chk_funds_consumption_flag INTO l_date_eff_funds_consumption;
CLOSE cur_chk_funds_consumption_flag;

--End of federal changes by sunkalya bug#5511353


   -- Required field validation
   -- This is currently necessary because these validations cannot be done on
   -- the self-service front end
   -- This will be removed once that technology is available
   -- Amit 2965841 : Made these fields mandatory in front end. So no need for the below code now.
   -- But let it be here as no harm.
   --Billing setup related changes for FP_M development. Tracking bug 3279981. customer_bill_split can
   --be null in case customer at top task is enabled. Adding foll IF condition


   --added the AND condition in the IF below for federal changes.Sunkalya bug#5511353

   IF l_en_top_task_cust_flag = 'N' AND nvl(l_date_eff_funds_consumption,'N') ='N' THEN
        if p_customer_bill_split is NULL then
           PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                                ,p_msg_name       => 'PA_CUST_BILL_SPLIT_INVALID');
        end if;
   END IF;
   if p_project_relationship_code is NULL then
      PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_RELATIONSHIP_CODE_REQD');
   end if;
/* START  For Bug 2731449 */
-- checking for not null values as bill to customer and ship to customer are mandatory  fields
  /* Amit 2965841: Chcecking only id is not sufficient . New code added below.
   if p_bill_to_customer_id is NULL then
      PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_BILL_TO_CUST_NAME_REQD');
   end if;

   if p_ship_to_customer_id is NULL then
      PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_SHIP_TO_CUST_NAME_REQD');
   end if;
   : Amit 2965841 */

   -- Amit 2965841 : Added beloe two checks
   --dbms_output.put_line('value of p_project_relationship_code 2'||p_project_relationship_code);

   if ((p_bill_to_customer_name = FND_API.G_MISS_CHAR) OR (p_bill_to_customer_name is NULL)) AND
      ((p_bill_to_customer_number = FND_API.G_MISS_CHAR) OR (p_bill_to_customer_number is NULL)) AND
      ((p_bill_to_customer_id = FND_API.G_MISS_NUM) OR (p_bill_to_customer_id is NULL)) then
      PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_BILL_TO_CUST_NAME_REQD');
   end if;

   if ((p_ship_to_customer_name = FND_API.G_MISS_CHAR) OR (p_ship_to_customer_name is NULL)) AND
      ((p_ship_to_customer_number = FND_API.G_MISS_CHAR) OR (p_ship_to_customer_number is NULL)) AND
      ((p_ship_to_customer_id = FND_API.G_MISS_NUM) OR (p_ship_to_customer_id is NULL)) then
      PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_SHIP_TO_CUST_NAME_REQD');
   end if;


 /* END  For Bug 2731449 */
   -- End of required field validation

   if p_calling_module <> 'FORM' AND  p_calling_module <> 'SELF_SERVICE'  THEN --Added second if condition for 4593317
 /* START  For Bug 2731449 */
          /* Amit 2965841: Chcecking only id is not sufficient. Added new code below

	  -- check whether bill to and ship to customer passes are valid or not
	   if(p_bill_to_customer_id <> NULL) THEN
		PA_CUSTOMERS_CONTACTS_UTILS.CHECK_CUSTOMER_NAME_OR_ID
		( p_customer_id    => p_bill_to_customer_id
		,p_check_id_flag  => 'Y'
		,x_customer_id    => l_bill_to_customer_id
		,x_return_status  => l_return_status
		,x_error_msg_code => l_error_msg_code);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => l_error_msg_code);
	      end if;
	   end if;

	   if(p_ship_to_customer_id <> NULL) THEN
		PA_CUSTOMERS_CONTACTS_UTILS.CHECK_CUSTOMER_NAME_OR_ID
		( p_customer_id    => p_ship_to_customer_id
		,p_check_id_flag  => 'Y'
		,x_customer_id    => l_ship_to_customer_id
		,x_return_status  => l_return_status
		,x_error_msg_code => l_error_msg_code);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => l_error_msg_code);
	      end if;
	   end if;
	   : Amit 2965841*/
	  -- Check for Bill Customer
	  -- Amit 2965841: We shd first check for Number as it is unique. And if it is able to find the id then we shd skip the check for name
	   if ((p_bill_to_customer_number <> FND_API.G_MISS_CHAR) AND (p_bill_to_customer_number is not NULL)) OR
	      ((p_bill_to_customer_id <> FND_API.G_MISS_NUM) AND (p_bill_to_customer_id is not NULL)) then
	      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_CUSTOMER_NUMBER_OR_ID
	      ( p_customer_id     => p_bill_to_customer_id
	       ,p_customer_number => p_bill_to_customer_number
	       ,x_customer_id     => l_bill_to_customer_id
	       ,x_return_status   => l_return_status
	       ,x_error_msg_code  => l_error_msg_code);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name =>l_error_msg_code||'_BILL'); -- Amit 2965841
	      end if;
	   end if;
           if l_bill_to_customer_id is null then -- Amit 2965841:
		   if ((p_bill_to_customer_name <> FND_API.G_MISS_CHAR) AND (p_bill_to_customer_name is not NULL)) OR
		      ((p_bill_to_customer_id <> FND_API.G_MISS_NUM) AND (p_bill_to_customer_id is not NULL)) then
		      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_CUSTOMER_NAME_OR_ID
		      ( p_customer_id    => p_bill_to_customer_id
		       ,p_customer_name  => p_bill_to_customer_name
		       ,x_customer_id    => l_bill_to_customer_id
		       ,x_return_status  => l_return_status
		       ,x_error_msg_code => l_error_msg_code);

		      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
			 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => l_error_msg_code||'_BILL');-- Amit 2965841
		      end if;
		   end if;
	   end if;	-- : Amit 2965841

	   if ((p_bill_to_customer_name <> FND_API.G_MISS_CHAR) AND (p_bill_to_customer_name is not NULL)) AND
	      ((p_bill_to_customer_number <> FND_API.G_MISS_CHAR) AND (p_bill_to_customer_number is not NULL)) THEN
	      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_CUSTOMER_NAME_AND_NUMBER
	      ( p_customer_name  => p_bill_to_customer_name
	       ,p_customer_number => p_bill_to_customer_number
	       ,x_customer_id    => l_bill_to_customer_id
	       ,x_return_status  => l_return_status
	       ,x_error_msg_code => l_error_msg_code);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	         if (l_error_msg_code = 'PA_CUST_NAME_NUMBER_INVALID') then
			 l_error_msg_code := l_error_msg_code||'_B';
		 else
			 l_error_msg_code := l_error_msg_code||'_BILL';
		 end if;
	         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => l_error_msg_code);
	      end if;
	   end if;

          --  Bug 2984882 : added following condition
          if (l_bill_to_customer_id is null and p_bill_to_customer_id is not null and p_bill_to_customer_id <> FND_API.G_MISS_NUM and l_return_status = FND_API.G_RET_STS_SUCCESS) then
              l_bill_to_customer_id:=p_bill_to_customer_id;
          end if;


	  -- Check for Ship Customer
  	  -- Amit 2965841: We shd first check for Number as it is unique. And if it is able to find the id then we shd skip the check for name
	   if ((p_ship_to_customer_number <> FND_API.G_MISS_CHAR) AND (p_ship_to_customer_number is not NULL)) OR
	      ((p_ship_to_customer_id <> FND_API.G_MISS_NUM) AND (p_ship_to_customer_id is not NULL)) then
	      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_CUSTOMER_NUMBER_OR_ID
	      ( p_customer_id     => p_ship_to_customer_id
	       ,p_customer_number => p_ship_to_customer_number
	       ,x_customer_id     => l_ship_to_customer_id
	       ,x_return_status   => l_return_status
	       ,x_error_msg_code  => l_error_msg_code);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => l_error_msg_code||'_SHIP');-- Amit 2965841
	      end if;
	   end if;

	   if l_ship_to_customer_id is null then -- : Amit 2965841
		   if ((p_ship_to_customer_name <> FND_API.G_MISS_CHAR) AND (p_ship_to_customer_name is not NULL)) OR
		      ((p_ship_to_customer_id <> FND_API.G_MISS_NUM) AND (p_ship_to_customer_id is not NULL)) then
		      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_CUSTOMER_NAME_OR_ID
		      ( p_customer_id    => p_ship_to_customer_id
		       ,p_customer_name  => p_ship_to_customer_name
		       ,x_customer_id    => l_ship_to_customer_id
		       ,x_return_status  => l_return_status
		       ,x_error_msg_code => l_error_msg_code);

		      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => l_error_msg_code||'_SHIP');-- Amit 2965841
		      end if;
		   end if;
           end if;	-- : Amit 2965841

	   if ((p_ship_to_customer_name <> FND_API.G_MISS_CHAR) AND (p_ship_to_customer_name is not NULL)) AND
	      ((p_ship_to_customer_number <> FND_API.G_MISS_CHAR) AND (p_ship_to_customer_number is not NULL)) THEN
	      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_CUSTOMER_NAME_AND_NUMBER
	      ( p_customer_name  => p_ship_to_customer_name
	       ,p_customer_number => p_ship_to_customer_number
	       ,x_customer_id    => l_ship_to_customer_id
	       ,x_return_status  => l_return_status
	       ,x_error_msg_code => l_error_msg_code);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	         if (l_error_msg_code = 'PA_CUST_NAME_NUMBER_INVALID') then
			 l_error_msg_code := l_error_msg_code||'_S';
		 else
			 l_error_msg_code := l_error_msg_code||'_SHIP';
		 end if;
	         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => l_error_msg_code);
	      end if;
	   end if;

	  --  Bug 2984882 : added following condition
	  if (l_ship_to_customer_id is null and p_ship_to_customer_id is not null and p_ship_to_customer_id <> FND_API.G_MISS_NUM and l_return_status = FND_API.G_RET_STS_SUCCESS) then
              l_ship_to_customer_id:=p_ship_to_customer_id;
          end if;

-- get the value of customer relationship if value is yes then check for the validity of relations with project customers
       OPEN C2;
	  FETCH C2 into l_cust_acc_rel_code;
	  CLOSE C2;
	  IF l_cust_acc_rel_code = 'Y' THEN
	    IF (l_bill_to_customer_id <> p_customer_id) THEN
            OPEN C3;
            FETCH C3 INTO l_valid_bill_id;
                IF C3%NOTFOUND Then
                    PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => 'PA_BILL_TO_NOT_VALID');
                End If;
            CLOSE C3;  --Bug 3865203
        END IF;
        --BUG#2876256
        IF (l_ship_to_customer_id <> p_customer_id) THEN
            OPEN C4;
            FETCH C4 INTO l_valid_ship_id;
                IF C4%NOTFOUND Then
                    PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => 'PA_SHIP_TO_NOT_VALID');
                End If;
            CLOSE C4;   --Bug 3865203
        END IF;
	   END If;
	   --dbms_output.put_line('Value of l_bill_to_customer_id'||l_bill_to_customer_id);
	   --dbms_output.put_line('Value of p_bill_to_address_id'||p_bill_to_address_id);

	   IF p_calling_module = 'AMG' THEN
           l_check_id_flag := 'N';
	   END IF;
	   if ((p_bill_site_name <> FND_API.G_MISS_CHAR) AND (p_bill_site_name is not NULL)) OR
	      ((p_bill_to_address_id <> FND_API.G_MISS_NUM) AND (p_bill_to_address_id is not NULL)) then
	      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_BILL_SITE_NAME_OR_ID
	      ( p_customer_id        => l_bill_to_customer_id -- Amit 2965841
	       ,p_bill_to_address_id => p_bill_to_address_id
	       ,p_bill_site_name     => p_bill_site_name
	       ,p_check_id_flag      => l_check_id_flag --Variable added for tarcking bug by aditi
	       ,x_bill_to_address_id => l_bill_to_address_id
	       ,x_return_status      => l_return_status
	       ,x_error_msg_code     => l_error_msg_code);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => l_error_msg_code);
	      end if;
	   end if;
	   --dbms_output.put_line('Value of l_bill_to_customer_id after '||l_bill_to_customer_id);
	   --dbms_output.put_line('Value of p_bill_to_address_id after '||p_bill_to_address_id);
 --dbms_output.put_line('Value of l_bill_to_address_id after '||l_bill_to_address_id);
           --dbms_output.put_line('Value of l_ship_to_customer_id'||l_ship_to_customer_id);
	   --dbms_output.put_line('Value of p_ship_to_address_id'||p_ship_to_address_id);

	   if ((p_work_site_name <> FND_API.G_MISS_CHAR) AND (p_work_site_name is not NULL)) OR
	      ((p_ship_to_address_id <> FND_API.G_MISS_NUM) AND (p_ship_to_address_id is not NULL)) then
	      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_WORK_SITE_NAME_OR_ID
	      ( p_customer_id        => l_ship_to_customer_id -- Amit 2965841
	       ,p_ship_to_address_id => p_ship_to_address_id
	       ,p_work_site_name     => p_work_site_name
	       ,p_check_id_flag      => l_check_id_flag --Variable added for tarcking bug by aditi
	       ,x_ship_to_address_id => l_ship_to_address_id
	       ,x_return_status      => l_return_status
	       ,x_error_msg_code     => l_error_msg_code);

/* End  For Bug 2731449 */

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => l_error_msg_code);
	      end if;
	   end if;
           --dbms_output.put_line('Value of l_ship_to_customer_id after '||l_ship_to_customer_id);
	   --dbms_output.put_line('Value of p_ship_to_address_id after '||p_ship_to_address_id);
	   --dbms_output.put_line('Value of l_ship_to_address_id after '||l_ship_to_address_id);

	   /*
	   PA_CUSTOMERS_CONTACTS_UTILS.CHECK_RECEIVER_PROJ_NAME_OR_ID
	   ( p_receiver_task_id      => p_receiver_task_id
	    ,p_receiver_project_name => p_receiver_project_name
	    ,x_receiver_task_id      => l_receiver_task_id
	    ,x_return_status         => l_return_status
	    ,x_error_msg_code        => l_error_msg_code);

	   if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	      PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => l_error_msg_code);
	   end if;
	   */

           --Added by Ansari for currency name to code check.

           if (p_inv_currency_code <> FND_API.G_MISS_CHAR) AND
              (p_inv_currency_code is not NULL)
           then
               PA_PROJECTS_MAINT_UTILS.Check_currency_name_or_code
                   ( p_agreement_currency       => p_inv_currency_code
                    ,p_agreement_currency_name  => null
                    ,p_check_id_flag            => 'Y'
                    ,x_agreement_currency       => l_inv_currency_code
                    ,x_return_status            => l_return_status
                    ,x_error_msg_code           => l_error_msg_code);

              if l_return_status <> FND_API.G_RET_STS_SUCCESS then
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => l_error_msg_code);
              end if;
           end if;
/* START  For Bug 2731449 */
-- Delete all the contacts of type billing or shipping respective of either bill to customer or ship to customer has been changed
	     OPEN C5;
	     FETCH C5 into l_db_bill_to_customer_id,l_db_ship_to_customer_id; -- Amit
	     CLOSE C5;

	     If (p_ship_to_customer_id <> l_ship_to_customer_id) Then
		PA_CUSTOMERS_CONTACTS_PUB.DELETE_ALL_BILL_SHIP_CONTACTS(
			P_API_VERSION              => 1.0
			,P_INIT_MSG_LIST            => 'T'
			, P_COMMIT                   => 'F'
			, P_VALIDATE_ONLY            => 'F'
			, P_VALIDATION_LEVEL         => 100
			, P_DEBUG_MODE               => 'N'
			, P_MAX_MSG_COUNT            => 100
			, P_PROJECT_ID               => P_PROJECT_ID
			, P_CUSTOMER_ID              => P_CUSTOMER_ID
			, P_BILL_SHIP_CUSTOMER_ID    => l_db_ship_to_customer_id
			, P_PROJECT_CONTACT_TYPE_CODE=> 'SHIPPING'
			, X_RETURN_STATUS          => l_return_status
			, X_MSG_COUNT              => l_msg_count
			, X_MSG_DATA               => l_msg_data
			);
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

           End If;

	     If (p_bill_to_customer_id <> l_bill_to_customer_id) Then
		PA_CUSTOMERS_CONTACTS_PUB.DELETE_ALL_BILL_SHIP_CONTACTS(
			P_API_VERSION              => 1.0
			,P_INIT_MSG_LIST            => 'T'
			, P_COMMIT                   => 'F'
			, P_VALIDATE_ONLY            => 'F'
			, P_VALIDATION_LEVEL         => 100
			, P_DEBUG_MODE               => 'N'
			, P_MAX_MSG_COUNT            => 100
			, P_PROJECT_ID               => P_PROJECT_ID
			, P_CUSTOMER_ID              => P_CUSTOMER_ID
			, P_BILL_SHIP_CUSTOMER_ID    => l_db_bill_to_customer_id
			, P_PROJECT_CONTACT_TYPE_CODE=> 'BILLING'
			, X_RETURN_STATUS          => l_return_status
			, X_MSG_COUNT              => l_msg_count
			, X_MSG_DATA               => l_msg_data
			);

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
	    End If;
   else
          l_bill_to_customer_id := p_bill_to_customer_id; -- Amit
	  l_ship_to_customer_id := p_ship_to_customer_id; -- Amit
          l_bill_to_address_id :=  p_bill_to_address_id;
          l_ship_to_address_id :=  p_ship_to_address_id;
          l_inv_currency_code  :=  p_inv_currency_code;
/* End  For Bug 2731449 */
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

   -- Fix for bug #1656846
   open C1(p_project_id);
   fetch C1 into l_project_currency_code;
   close C1;

   if p_inv_currency_code = FND_API.G_MISS_CHAR then
      l_project_currency_code2 := NULL;
   else
      l_project_currency_code2 := p_inv_currency_code;
   end if;

--   if(l_project_currency_code = nvl(l_project_currency_code2, l_project_currency_code)) AND (p_calling_module = 'FORM') then
--     l_inv_rate_type := null;
--   else
     l_inv_rate_type := p_inv_rate_type;
--   end if; --This if condition is commented ( leaving just the preceeding statement only ) by Ansari for fixing 2097530
   -- End of fix
   --dbms_output.put_line('value of p_project_relationship_code 3'||p_project_relationship_code);
--dbms_output.put_line('value of p_calling_module passed from pub to pvt'||p_calling_module);
 --dbms_output.put_line('Value of l_bill_to_customer_id before pvt  '||l_bill_to_customer_id);
--dbms_output.put_line('Value of l_bill_to_address_id before pvt  '||l_bill_to_address_id);
 --dbms_output.put_line('Value of l_ship_to_address_id  before pvt '||l_ship_to_address_id);
--dbms_output.put_line('Value of l_ship_to_customer_id  before pvt '||l_ship_to_customer_id);
--dbms_output.put_line('Value of p_bill_another_project_flag  before pvt '||p_bill_another_project_flag);
   PA_CUSTOMERS_CONTACTS_PVT.UPDATE_PROJECT_CUSTOMER
   ( p_commit                    => FND_API.G_FALSE
    ,p_validate_only             => p_validate_only
    ,p_validation_level          => p_validation_level
    ,p_calling_module            => p_calling_module
    ,p_debug_mode                => p_debug_mode
    ,p_max_msg_count             => p_max_msg_count
    ,p_project_id                => p_project_id
    ,p_customer_id               => p_customer_id
    ,p_project_relationship_code => p_project_relationship_code
    ,p_customer_bill_split       => p_customer_bill_split
    ,p_bill_to_customer_id       => l_bill_to_customer_id                           /*   For Bug 2731449 */
    ,p_ship_to_customer_id       => l_ship_to_customer_id                           /*   For Bug 2731449 */
    ,p_bill_to_address_id        => l_bill_to_address_id
    ,p_ship_to_address_id        => l_ship_to_address_id
    ,p_inv_currency_code         => nvl(l_inv_currency_code, l_project_currency_code)
    ,p_inv_rate_type             => l_inv_rate_type
    ,p_inv_rate_date             => p_inv_rate_date
    ,p_inv_exchange_rate         => p_inv_exchange_rate
    ,p_allow_user_rate_type_flag => p_allow_user_rate_type_flag
    ,p_receiver_task_id          => p_receiver_task_id
    ,p_bill_another_project_flag => p_bill_another_project_flag --Added by Aditi for tracking bug 4153629
    ,p_record_version_number     => p_record_version_number
    ,x_return_status             => l_return_status
    ,x_msg_count                 => l_msg_count
    ,x_msg_data                  => l_msg_data
--Billing setup related changes for FP_M development. Tracking bug 3279981
    ,p_Default_Top_Task_Cust_Flag =>  p_Default_Top_Task_Cust_Flag   );

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

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if p_commit = FND_API.G_TRUE then
      commit work;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_CUSTOMERS_CONTACTS_PUB.Update_Project_Customer END');
   end if;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_project_customer;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_project_customer;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CUSTOMERS_CONTACTS_PUB',
                              p_procedure_name => 'Update_Project_Customer',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
   when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to update_project_customer;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CUSTOMERS_CONTACTS_PUB',
                              p_procedure_name => 'Update_Project_Customer',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END UPDATE_PROJECT_CUSTOMER;


-- API name		: Delete_Project_Customer
-- Type			: Public
-- Pre-reqs		: None.
-- Parameters           :
-- p_api_version                   IN NUMBER     Required Default = 1.0
-- p_init_msg_list                 IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_commit                        IN VARCHAR2   Required Default = FND_API.G_FALSE
-- p_validate_only                 IN VARCHAR2   Required Default = FND_API.G_TRUE
-- p_validation_level              IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module                IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode                    IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count                 IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_project_id                    IN NUMBER     Required
-- p_customer_id                   IN NUMBER     Required
-- p_record_version_number         IN NUMBER     Required Default = FND_API.G_MISS_NUM
-- x_return_status                 OUT VARCHAR2  Required
-- x_msg_count                     OUT NUMBER    Required
-- x_msg_data                      OUT VARCHAR2  Optional

PROCEDURE DELETE_PROJECT_CUSTOMER
(  p_api_version                   IN NUMBER     := 1.0
  ,p_init_msg_list                 IN VARCHAR2   := FND_API.G_TRUE
  ,p_commit                        IN VARCHAR2   := FND_API.G_FALSE
  ,p_validate_only                 IN VARCHAR2   := FND_API.G_TRUE
  ,p_validation_level              IN NUMBER     := FND_API.G_VALID_LEVEL_FULL
  ,p_calling_module                IN VARCHAR2   := 'SELF_SERVICE'
  ,p_debug_mode                    IN VARCHAR2   := 'N'
  ,p_max_msg_count                 IN NUMBER     := FND_API.G_MISS_NUM
  ,p_project_id                    IN NUMBER
  ,p_customer_id                   IN NUMBER
  ,p_record_version_number         IN NUMBER     := FND_API.G_MISS_NUM
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
   l_api_name                      CONSTANT VARCHAR(30) := 'Delete_Project_Customer';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;
BEGIN
   pa_debug.init_err_stack('PA_CUSTOMERS_CONTACTS_PUB.Delete_Project_Customer');

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_CUSTOMERS_CONTACTS_PUB.Delete_Project_Customer BEGIN');
   end if;

   if p_commit = FND_API.G_TRUE then
      savepoint delete_project_customer;
   end if;

   if not FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) then
      FND_MSG_PUB.initialize;
   end if;

   PA_CUSTOMERS_CONTACTS_PVT.DELETE_PROJECT_CUSTOMER
   ( p_commit                    => FND_API.G_FALSE
    ,p_validate_only             => p_validate_only
    ,p_validation_level          => p_validation_level
    ,p_calling_module            => p_calling_module
    ,p_debug_mode                => p_debug_mode
    ,p_max_msg_count             => p_max_msg_count
    ,p_project_id                => p_project_id
    ,p_customer_id               => p_customer_id
    ,p_record_version_number     => p_record_version_number
    ,x_return_status             => l_return_status
    ,x_msg_count                 => l_msg_count
    ,x_msg_data                  => l_msg_data);

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

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if p_commit = FND_API.G_TRUE then
      commit work;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_CUSTOMERS_CONTACTS_PUB.Delete_Project_Customer END');
   end if;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_project_customer;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_project_customer;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CUSTOMERS_CONTACTS_PUB',
                              p_procedure_name => 'Delete_Project_Customer',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
   when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_project_customer;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CUSTOMERS_CONTACTS_PUB',
                              p_procedure_name => 'Delete_Project_Customer',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END DELETE_PROJECT_CUSTOMER;


-- API name		: Create_Customer_Contact
-- Type			: Public
-- Pre-reqs		: None.
-- Parameters           :
-- p_api_version                   IN NUMBER     Required Default = 1.0
-- p_init_msg_list                 IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_commit                        IN VARCHAR2   Required Default = FND_API.G_FALSE
-- p_validate_only                 IN VARCHAR2   Required Default = FND_API.G_TRUE
-- p_validation_level              IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module                IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode                    IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count                 IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_project_id                    IN NUMBER     Required
-- p_customer_id                   IN NUMBER     Required
-- p_bill_ship_customer_id         IN NUMBER     Required
-- p_contact_id                    IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_contact_name                  IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_project_contact_type_code     IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_project_contact_type_name     IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- x_return_status                 OUT VARCHAR2  Required
-- x_msg_count                     OUT NUMBER    Required
-- x_msg_data                      OUT VARCHAR2  Optional

PROCEDURE CREATE_CUSTOMER_CONTACT
(  p_api_version                   IN NUMBER     := 1.0
  ,p_init_msg_list                 IN VARCHAR2   := FND_API.G_TRUE
  ,p_commit                        IN VARCHAR2   := FND_API.G_FALSE
  ,p_validate_only                 IN VARCHAR2   := FND_API.G_TRUE
  ,p_validation_level              IN NUMBER     := FND_API.G_VALID_LEVEL_FULL
  ,p_calling_module                IN VARCHAR2   := 'SELF_SERVICE'
  ,p_debug_mode                    IN VARCHAR2   := 'N'
  ,p_max_msg_count                 IN NUMBER     := FND_API.G_MISS_NUM
  ,p_project_id                    IN NUMBER
  ,p_customer_id                   IN NUMBER
  ,p_bill_ship_customer_id         IN NUMBER       /*   For Bug 2731449 */
  ,p_contact_id                    IN NUMBER     := FND_API.G_MISS_NUM
  ,p_contact_name                  IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_project_contact_type_code     IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_project_contact_type_name     IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
   l_api_name                      CONSTANT VARCHAR(30) := 'Create_Customer_Contact';
   l_api_version                   CONSTANT NUMBER      := 1.0;

 /* Bug 2874261 */
 /*  l_address_id              Number;
     l_contact_idt              Number; */
     l_site_use_code           VARCHAR2(30);
   l_validate                      Number;

   l_contact_id                    NUMBER;
   l_project_contact_type_code     pa_project_contacts.project_contact_type_code%TYPE;
   l_return_status                 VARCHAR2(1);
   l_error_msg_code                VARCHAR2(250);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;
   l_address_id                    NUMBER; -- Added for Bug 2964227

  /*   For Bug 2731449 */

  /* Bug 2874261 - Commenting the cursors below */
  /*  CURSOR C1 IS
    SELECT a.Address_id, su.Contact_id, su.site_use_code
    FROM   Ra_Addresses a,
           Ra_Site_Uses su
    WHERE  a.Address_Id        = su.Address_Id
      AND  Nvl(a.Status,'A')   = 'A'
      AND  a.Customer_id       = p_bill_ship_customer_id
      AND  Nvl(su.Status, 'A') = 'A'
      AND  su.primary_flag     = 'Y'
      AND su.site_use_code     = l_site_use_code
      AND su.Contact_id        = p_contact_id;

   CURSOR C2 IS
    SELECT a.Address_id, su.Contact_id, su.site_use_code
    FROM   Ra_Addresses a,
           Ra_Site_Uses su
    WHERE  a.Address_Id        = su.Address_Id
      AND  Nvl(a.Status,'A')   = 'A'
      AND  a.Customer_id       = p_customer_id
      AND  Nvl(su.Status, 'A') = 'A'
      AND  su.primary_flag     = 'Y'
      AND su.Contact_id        = p_contact_id; */

   /* Bug 2874261 - Adding the modified cursors below */
/*Bug 3691196 - Commenting out both the cursors below
     CURSOR C1 IS
     SELECT 1 from dual
     where exists (select c.contact_id
                   from ra_contacts c ,
                        ra_contact_roles cr ,
                        ra_addresses a
		   where c.contact_id = cr.contact_id
                     AND nvl(c.status, 'A') = 'A'
                     AND nvl(c.address_id, a.address_id) = a.address_id
                     and c.customer_id = p_bill_ship_customer_id
                     and cr.usage_code = l_site_use_code
                     and c.contact_id  = p_contact_id);

       CURSOR C2 IS
       SELECT 1 from dual
       where exists (select c.contact_id
                   from ra_contacts c ,
                        ra_contact_roles cr ,
                        ra_addresses a
		   where c.contact_id = cr.contact_id
                     AND nvl(c.status, 'A') = 'A'
                     AND nvl(c.address_id, a.address_id) = a.address_id
                     and c.customer_id = p_customer_id
                     and c.contact_id  = p_contact_id);
*/

BEGIN
   pa_debug.init_err_stack('PA_CUSTOMERS_CONTACTS_PUB.Create_Customer_Contact');

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_CUSTOMERS_CONTACTS_PUB.Create_Customer_Contact BEGIN');
   end if;

   if p_commit = FND_API.G_TRUE then
      savepoint create_customer_contact;
   end if;

   if not FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) then
      FND_MSG_PUB.initialize;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('Performing ID validations and conversions...');
   end if;

   if ((p_project_contact_type_code = FND_API.G_MISS_CHAR) OR (p_project_contact_type_code is NULL)) AND
      ((p_project_contact_type_name = FND_API.G_MISS_CHAR) OR (p_project_contact_type_name is NULL)) then
      PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_CONTACT_TYPE_REQD');
   end if;

   if p_calling_module <> 'FORM' then
	   if ((p_project_contact_type_name <> FND_API.G_MISS_CHAR) AND (p_project_contact_type_name is not NULL)) OR
	      ((p_project_contact_type_code <> FND_API.G_MISS_CHAR) AND (p_project_contact_type_code is not NULL)) then
	      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_CONTACT_TYP_NAME_OR_CODE
	      ( p_project_contact_type_code => p_project_contact_type_code
	       ,p_project_contact_type_name => p_project_contact_type_name
	       ,p_check_id_flag => 'N'
	       ,x_project_contact_type_code => l_project_contact_type_code
	       ,x_return_status             => l_return_status
	       ,x_error_msg_code            => l_error_msg_code);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => l_error_msg_code);
	      end if;
	   end if;
   end if;

	   if ((p_contact_id = FND_API.G_MISS_NUM) OR (p_contact_id is NULL)) AND
	      ((p_contact_name = FND_API.G_MISS_CHAR) OR (p_contact_name is NULL)) then
	      PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
	                           ,p_msg_name       => 'PA_CONTACT_NAME_REQD');
	   end if;

-- Amit 2965841 :  Commented the whole code for p_calling_module <> 'FORM' condition and added new code below it.
/*   if p_calling_module <> 'FORM' then
        For Bug 2731449

     -- check for contact id with respect to bill to or ship to or project customer depending on value of p_project_contact_type_code
	   if ((p_contact_name <> FND_API.G_MISS_CHAR) AND (p_contact_name is not NULL)) OR
	      ((p_contact_id <> FND_API.G_MISS_NUM) AND (p_contact_id is not NULL)) then
	       PA_CUSTOMERS_CONTACTS_UTILS.CHECK_CONTACT_NAME_OR_ID
	      ( p_customer_id               => p_customer_id
	       ,p_project_contact_type_code => l_project_contact_type_code
	       ,p_contact_id                => p_contact_id
	       ,p_contact_name              => p_contact_name
	       ,x_contact_id                => l_contact_id
	       ,x_return_status             => l_return_status
	       ,x_error_msg_code            => l_error_msg_code);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => l_error_msg_code);
	      end if;
	   end if;

     if ((p_project_contact_type_code <> 'BILLING') AND  (p_project_contact_type_code <> 'SHIPPING'))THEN

		OPEN C2;
		FETCH C2 INTO l_validate;
                IF C2%NOTFOUND THEN
		   PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => 'PA_INV_CONTRACT_CONTACT');
		END IF;
		CLOSE C2; -- Bug 2874261
     else
        if(p_project_contact_type_code <> 'BILLING') Then
	  l_site_use_code := 'SHIP_TO';
	else
          l_site_use_code := 'BILL_TO';
	end if;
		OPEN C1;
		FETCH C1 INTO l_validate;
                IF C1%NOTFOUND THEN
                   if(p_project_contact_type_code <> 'BILLING') Then
                	   PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => 'PA_INV_SHIP_CONTACT');
	           else
                	   PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => 'PA_INV_BILL_CONTACT');
	           end if;
		END IF;
		CLOSE C1; -- Bug 2874261
      End if;
      END IF;
          Bug 2874261
	  l_contact_id := p_contact_id;
          l_project_contact_type_code := p_project_contact_type_code;
   else
      	   l_contact_id := p_contact_id;
           l_project_contact_type_code := p_project_contact_type_code;

   end if;
: Amit 2965841 */
-- Amit 2965841 Added the below code for p_calling_module <> FORM
 if p_calling_module <> 'FORM' then
       -- Added the following of condition for Bug 2964227
	IF l_project_contact_type_code = 'BILLING' THEN
		begin
		 select bill_to_address_id into l_address_id from pa_project_customers where project_id = p_project_id and customer_id=p_customer_id;
		exception when others then
		  l_address_id := null;
		end;
	ELSIF l_project_contact_type_code = 'SHIPPING' THEN
		begin
		 select ship_to_address_id into l_address_id from pa_project_customers where project_id = p_project_id and customer_id=p_customer_id;
		exception when others then
		  l_address_id := null;
		end;
	END IF;

     -- check for contact id with respect to bill to or ship to or project customer depending on value of p_project_contact_type_code
      if ((l_project_contact_type_code <> 'BILLING') AND  (l_project_contact_type_code <> 'SHIPPING'))THEN
           PA_CUSTOMERS_CONTACTS_UTILS.CHECK_CONTACT_NAME_OR_ID
	      ( p_customer_id               => p_customer_id
	       ,p_project_contact_type_code => l_project_contact_type_code
	       ,p_contact_id                => p_contact_id
	       ,p_contact_name              => p_contact_name
	       ,x_contact_id                => l_contact_id
	       ,x_return_status             => l_return_status
	       ,x_error_msg_code            => l_error_msg_code);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => l_error_msg_code);
	      end if;
      else
            PA_CUSTOMERS_CONTACTS_UTILS.CHECK_CONTACT_NAME_OR_ID
	      ( p_customer_id               => p_bill_ship_customer_id
	       ,p_project_contact_type_code => l_project_contact_type_code
	       ,p_contact_id                => p_contact_id
	       ,p_contact_name              => p_contact_name
	       ,p_address_id                => l_address_id -- Added for Bug 2964227
	       ,x_contact_id                => l_contact_id
	       ,x_return_status             => l_return_status
	       ,x_error_msg_code            => l_error_msg_code);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name =>  l_error_msg_code);
	      end if;
      end if;

 else -- p_calling_module <> 'FORM'
      	   l_contact_id := p_contact_id;
           l_project_contact_type_code := p_project_contact_type_code;

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

   PA_CUSTOMERS_CONTACTS_PVT.CREATE_CUSTOMER_CONTACT
   ( p_commit                    => FND_API.G_FALSE
    ,p_validate_only             => p_validate_only
    ,p_validation_level          => p_validation_level
    ,p_calling_module            => p_calling_module
    ,p_debug_mode                => p_debug_mode
    ,p_max_msg_count             => p_max_msg_count
    ,p_project_id                => p_project_id
    ,p_customer_id               => p_customer_id
    ,p_bill_ship_customer_id     => p_bill_ship_customer_id           /*   For Bug 2731449 */
    ,p_contact_id                => l_contact_id
    ,p_project_contact_type_code => l_project_contact_type_code
    ,x_return_status             => l_return_status
    ,x_msg_count                 => l_msg_count
    ,x_msg_data                  => l_msg_data);

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

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if p_commit = FND_API.G_TRUE then
      commit work;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_CUSTOMERS_CONTACTS_PUB.Create_Customer_Contact END');
   end if;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to create_customer_contact;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to create_customer_contact;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CUSTOMERS_CONTACTS_PUB',
                              p_procedure_name => 'Create_Customer_Contact',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
   when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to create_customer_contact;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CUSTOMERS_CONTACTS_PUB',
                              p_procedure_name => 'Create_Customer_Contact',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END CREATE_CUSTOMER_CONTACT;


-- API name		: Update_Customer_Contact
-- Type			: Public
-- Pre-reqs		: None.
-- Parameters           :
-- p_api_version                   IN NUMBER     Required Default = 1.0
-- p_init_msg_list                 IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_commit                        IN VARCHAR2   Required Default = FND_API.G_FALSE
-- p_validate_only                 IN VARCHAR2   Required Default = FND_API.G_TRUE
-- p_validation_level              IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module                IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode                    IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count                 IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_project_id                    IN NUMBER     Required
-- p_customer_id                   IN NUMBER     Required
-- p_bill_ship_customer_id         IN NUMBER     Required
-- p_contact_id                    IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_contact_name                  IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_project_contact_type_code     IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_project_contact_type_name     IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_rowid                         IN VARCHAR2   Required
-- p_record_version_number         IN NUMBER     Required
-- x_return_status                 OUT VARCHAR2  Required
-- x_msg_count                     OUT NUMBER    Required
-- x_msg_data                      OUT VARCHAR2  Optional

PROCEDURE UPDATE_CUSTOMER_CONTACT
(  p_api_version                   IN NUMBER     := 1.0
  ,p_init_msg_list                 IN VARCHAR2   := FND_API.G_TRUE
  ,p_commit                        IN VARCHAR2   := FND_API.G_FALSE
  ,p_validate_only                 IN VARCHAR2   := FND_API.G_TRUE
  ,p_validation_level              IN NUMBER     := FND_API.G_VALID_LEVEL_FULL
  ,p_calling_module                IN VARCHAR2   := 'SELF_SERVICE'
  ,p_debug_mode                    IN VARCHAR2   := 'N'
  ,p_max_msg_count                 IN NUMBER     := FND_API.G_MISS_NUM
  ,p_project_id                    IN NUMBER
  ,p_customer_id                   IN NUMBER
  ,p_bill_ship_customer_id         IN NUMBER
  ,p_contact_id                    IN NUMBER     := FND_API.G_MISS_NUM
  ,p_contact_name                  IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_project_contact_type_code     IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_project_contact_type_name     IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_rowid                         IN VARCHAR2
  ,p_record_version_number         IN NUMBER
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
   l_api_name                      CONSTANT VARCHAR(30) := 'Update_Customer_Contact';
   l_api_version                   CONSTANT NUMBER      := 1.0;

 /* Bug 2874261 */
  /* l_address_id              Number;
   l_contact_idt              Number; */
   l_site_use_code           VARCHAR2(30);
   l_validate                      NUMBER;

   l_contact_id                    NUMBER;
   l_project_contact_type_code     pa_project_contacts.project_contact_type_code%TYPE;
   l_return_status                 VARCHAR2(1);
   l_error_msg_code                VARCHAR2(250);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;
   l_address_id                    NUMBER; -- Added for Bug 2964227

   /*  Bug 2874261 - Commenting the cursors below */
    /*   For Bug 2731449 */
  /*  CURSOR C1 IS
    SELECT a.Address_id, su.Contact_id, su.site_use_code
    FROM   Ra_Addresses a,
           Ra_Site_Uses su
    WHERE  a.Address_Id        = su.Address_Id
      AND  Nvl(a.Status,'A')   = 'A'
      AND  a.Customer_id       = p_bill_ship_customer_id
      AND  Nvl(su.Status, 'A') = 'A'
      AND  su.primary_flag     = 'Y'
      AND su.site_use_code     = l_site_use_code
      AND su.Contact_id        = p_contact_id;

   CURSOR C2 IS
    SELECT a.Address_id, su.Contact_id, su.site_use_code
    FROM   Ra_Addresses a,
           Ra_Site_Uses su
    WHERE  a.Address_Id        = su.Address_Id
      AND  Nvl(a.Status,'A')   = 'A'
      AND  a.Customer_id       = p_customer_id
      AND  Nvl(su.Status, 'A') = 'A'
      AND  su.primary_flag     = 'Y'
      AND su.Contact_id        = p_contact_id; */


      /* Bug 2874261 - Adding the modified cursors below */
/*Bug 3691196 - Commenting out both the cursors below
     CURSOR C1 IS
     SELECT 1 from dual
     where exists (select c.contact_id
                   from ra_contacts c ,
                        ra_contact_roles cr ,
                        ra_addresses a
		   where c.contact_id = cr.contact_id
                     AND nvl(c.status, 'A') = 'A'
                     AND nvl(c.address_id, a.address_id) = a.address_id
                     and c.customer_id = p_bill_ship_customer_id
                     and cr.usage_code = l_site_use_code
                     and c.contact_id  = p_contact_id);

       CURSOR C2 IS
       SELECT 1 from dual
       where exists (select c.contact_id
                   from ra_contacts c ,
                        ra_contact_roles cr ,
                        ra_addresses a
		   where c.contact_id = cr.contact_id
                     AND nvl(c.status, 'A') = 'A'
                     AND nvl(c.address_id, a.address_id) = a.address_id
                     and c.customer_id = p_customer_id
                     and c.contact_id  = p_contact_id);
*/
BEGIN
   pa_debug.init_err_stack('PA_CUSTOMERS_CONTACTS_PUB.Update_Customer_Contact');

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_CUSTOMERS_CONTACTS_PUB.Update_Customer_Contact BEGIN');
   end if;

   if p_commit = FND_API.G_TRUE then
      savepoint update_customer_contact;
   end if;

   if not FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) then
      FND_MSG_PUB.initialize;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('Performing ID validations and conversions...');
   end if;

   if ((p_project_contact_type_code = FND_API.G_MISS_CHAR) OR (p_project_contact_type_code is NULL)) AND
      ((p_project_contact_type_name = FND_API.G_MISS_CHAR) OR (p_project_contact_type_name is NULL)) then
      PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_CONTACT_TYPE_REQD');
   end if;

-- Amit 2965841: Uncommented the below code. It is required.

   if p_calling_module <> 'FORM' then
	   if ((p_project_contact_type_name <> FND_API.G_MISS_CHAR) AND (p_project_contact_type_name is not NULL)) OR
	      ((p_project_contact_type_code <> FND_API.G_MISS_CHAR) AND (p_project_contact_type_code is not NULL)) then
	      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_CONTACT_TYP_NAME_OR_CODE
	      ( p_project_contact_type_code => p_project_contact_type_code
	       ,p_project_contact_type_name => p_project_contact_type_name
	       ,p_check_id_flag => 'N'
	       ,x_project_contact_type_code => l_project_contact_type_code
	       ,x_return_status             => l_return_status
	       ,x_error_msg_code            => l_error_msg_code);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => l_error_msg_code);
	      end if;
	   end if;
   end if;

   if ((p_contact_id = FND_API.G_MISS_NUM) OR (p_contact_id is NULL)) AND
      ((p_contact_name = FND_API.G_MISS_CHAR) OR (p_contact_name is NULL)) then
      PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_CONTACT_NAME_REQD');
   end if;

-- Amit 2965841:  Commented the whole code for p_calling_module <> 'FORM' condition and added new code below it.
/*   if p_calling_module <> 'FORM' then
	   if ((p_contact_name <> FND_API.G_MISS_CHAR) AND (p_contact_name is not NULL)) OR
	      ((p_contact_id <> FND_API.G_MISS_NUM) AND (p_contact_id is not NULL)) then
        For Bug 2731449
     -- check for contact id with respect to bill to or ship to or project customer depending on value of p_project_contact_type_code

	      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_CONTACT_NAME_OR_ID
	      ( p_customer_id               => p_customer_id
	       ,p_project_contact_type_code => l_project_contact_type_code
	       ,p_contact_id                => p_contact_id
	       ,p_contact_name              => p_contact_name
	       ,x_contact_id                => l_contact_id
	       ,x_return_status             => l_return_status
	       ,x_error_msg_code            => l_error_msg_code);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => l_error_msg_code);
	      end if;
	   end if;

           if ((p_project_contact_type_code <> 'BILLING') AND  (p_project_contact_type_code <> 'SHIPPING'))THEN

		OPEN C2;
		FETCH C2 INTO l_validate;
                IF C2%NOTFOUND THEN
		   PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => 'PA_INV_CONTRACT_CONTACT');
		END IF;
		CLOSE C2;
     else
        if(p_project_contact_type_code <> 'BILLING') Then
	  l_site_use_code := 'SHIP_TO';
	else
          l_site_use_code := 'BILL_TO';
	end if;
		OPEN C1;
		FETCH C1 INTO l_validate;
                IF C1%NOTFOUND THEN
                   if(p_project_contact_type_code <> 'BILLING') Then
                	   PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => 'PA_INV_SHIP_CONTACT');
	           else
                	   PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => 'PA_INV_BILL_CONTACT');
	           end if;
		END IF;
		CLOSE C1;
      End if;
     END IF;
      Bug 2874261
     l_contact_id := p_contact_id;
     l_project_contact_type_code := p_project_contact_type_code;

   else
      	   l_contact_id := p_contact_id;
           l_project_contact_type_code := p_project_contact_type_code;
   end if;
: Amit */
-- Amit 2965841 Added the below code for p_calling_module <> FORM
 if p_calling_module <> 'FORM' then
        -- Added the following of condition for Bug 2964227
	IF l_project_contact_type_code = 'BILLING' THEN
		begin
		 select bill_to_address_id into l_address_id from pa_project_customers where project_id = p_project_id and customer_id=p_customer_id;
		exception when others then
		  l_address_id := null;
		end;
	ELSIF l_project_contact_type_code = 'SHIPPING' THEN
		begin
		 select ship_to_address_id into l_address_id from pa_project_customers where project_id = p_project_id and customer_id=p_customer_id;
		exception when others then
		  l_address_id := null;
		end;
	END IF;

     -- check for contact id with respect to bill to or ship to or project customer depending on value of p_project_contact_type_code
      if ((l_project_contact_type_code <> 'BILLING') AND  (l_project_contact_type_code <> 'SHIPPING'))THEN
           PA_CUSTOMERS_CONTACTS_UTILS.CHECK_CONTACT_NAME_OR_ID
	      ( p_customer_id               => p_customer_id
	       ,p_project_contact_type_code => l_project_contact_type_code
	       ,p_contact_id                => p_contact_id
	       ,p_contact_name              => p_contact_name
	       ,x_contact_id                => l_contact_id
	       ,x_return_status             => l_return_status
	       ,x_error_msg_code            => l_error_msg_code);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => l_error_msg_code);
	      end if;
      else
            PA_CUSTOMERS_CONTACTS_UTILS.CHECK_CONTACT_NAME_OR_ID
	      ( p_customer_id               => p_bill_ship_customer_id
	       ,p_project_contact_type_code => l_project_contact_type_code
	       ,p_contact_id                => p_contact_id
	       ,p_contact_name              => p_contact_name
	       ,p_address_id                => l_address_id -- Added for Bug 2964227
	       ,x_contact_id                => l_contact_id
	       ,x_return_status             => l_return_status
	       ,x_error_msg_code            => l_error_msg_code);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA', p_msg_name => l_error_msg_code);
	      end if;
      end if;

 else -- p_calling_module <> 'FORM'
      	   l_contact_id := p_contact_id;
           l_project_contact_type_code := p_project_contact_type_code;
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

   PA_CUSTOMERS_CONTACTS_PVT.UPDATE_CUSTOMER_CONTACT
   ( p_commit                    => FND_API.G_FALSE
    ,p_validate_only             => p_validate_only
    ,p_validation_level          => p_validation_level
    ,p_calling_module            => p_calling_module
    ,p_debug_mode                => p_debug_mode
    ,p_max_msg_count             => p_max_msg_count
    ,p_project_id                => p_project_id
    ,p_customer_id               => p_customer_id
    ,p_bill_ship_customer_id     => p_bill_ship_customer_id         /*   For Bug 2731449 */
    ,p_contact_id                => l_contact_id
    ,p_project_contact_type_code => l_project_contact_type_code
    ,p_rowid                     => p_rowid
    ,p_record_version_number     => p_record_version_number
    ,x_return_status             => l_return_status
    ,x_msg_count                 => l_msg_count
    ,x_msg_data                  => l_msg_data);

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

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if p_commit = FND_API.G_TRUE then
      commit work;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_CUSTOMERS_CONTACTS_PUB.Update_Customer_Contact END');
   end if;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_customer_contact;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_customer_contact;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CUSTOMERS_CONTACTS_PUB',
                              p_procedure_name => 'Update_Customer_Contact',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
   when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to update_customer_contact;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CUSTOMERS_CONTACTS_PUB',
                              p_procedure_name => 'Update_Customer_Contact',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END UPDATE_CUSTOMER_CONTACT;


-- API name		: Delete_Customer_Contact
-- Type			: Public
-- Pre-reqs		: None.
-- Parameters           :
-- p_api_version                   IN NUMBER     Required Default = 1.0
-- p_init_msg_list                 IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_commit                        IN VARCHAR2   Required Default = FND_API.G_FALSE
-- p_validate_only                 IN VARCHAR2   Required Default = FND_API.G_TRUE
-- p_validation_level              IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module                IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode                    IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count                 IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_project_id                    IN NUMBER     Required
-- p_customer_id                   IN NUMBER     Required
-- p_contact_id                    IN NUMBER     Required
-- p_project_contact_type_code     IN VARCHAR2   Required
-- p_record_version_number         IN NUMBER     Required Default = FND_API.G_MISS_NUM
-- x_return_status                 OUT VARCHAR2  Required
-- x_msg_count                     OUT NUMBER    Required
-- x_msg_data                      OUT VARCHAR2  Optional

PROCEDURE DELETE_CUSTOMER_CONTACT
(  p_api_version                   IN NUMBER     := 1.0
  ,p_init_msg_list                 IN VARCHAR2   := FND_API.G_TRUE
  ,p_commit                        IN VARCHAR2   := FND_API.G_FALSE
  ,p_validate_only                 IN VARCHAR2   := FND_API.G_TRUE
  ,p_validation_level              IN NUMBER     := FND_API.G_VALID_LEVEL_FULL
  ,p_calling_module                IN VARCHAR2   := 'SELF_SERVICE'
  ,p_debug_mode                    IN VARCHAR2   := 'N'
  ,p_max_msg_count                 IN NUMBER     := FND_API.G_MISS_NUM
  ,p_project_id                    IN NUMBER
  ,p_customer_id                   IN NUMBER
  ,p_contact_id                    IN NUMBER
  ,p_project_contact_type_code     IN VARCHAR2
  ,p_record_version_number         IN NUMBER     := FND_API.G_MISS_NUM
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
   l_api_name                      CONSTANT VARCHAR(30) := 'Delete_Customer_Contact';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;
BEGIN
   pa_debug.init_err_stack('PA_CUSTOMERS_CONTACTS_PUB.Delete_Customer_Contact');

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_CUSTOMERS_CONTACTS_PUB.Delete_Customer_Contact BEGIN');
   end if;

   if p_commit = FND_API.G_TRUE then
      savepoint delete_customer_contact;
   end if;

   if not FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) then
      FND_MSG_PUB.initialize;
   end if;

   PA_CUSTOMERS_CONTACTS_PVT.DELETE_CUSTOMER_CONTACT
   ( p_commit                    => FND_API.G_FALSE
    ,p_validate_only             => p_validate_only
    ,p_validation_level          => p_validation_level
    ,p_calling_module            => p_calling_module
    ,p_debug_mode                => p_debug_mode
    ,p_max_msg_count             => p_max_msg_count
    ,p_project_id                => p_project_id
    ,p_customer_id               => p_customer_id
    ,p_contact_id                => p_contact_id
    ,p_project_contact_type_code => p_project_contact_type_code
    ,p_record_version_number     => p_record_version_number
    ,x_return_status             => l_return_status
    ,x_msg_count                 => l_msg_count
    ,x_msg_data                  => l_msg_data);

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

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if p_commit = FND_API.G_TRUE then
      commit work;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_CUSTOMERS_CONTACTS_PUB.Delete_Customer_Contact END');
   end if;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_customer_contact;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_customer_contact;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CUSTOMERS_CONTACTS_PUB',
                              p_procedure_name => 'Delete_Customer_Contact',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
   when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_customer_contact;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CUSTOMERS_CONTACTS_PUB',
                              p_procedure_name => 'Delete_Customer_Contact',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END DELETE_CUSTOMER_CONTACT;

/*   For Bug 2731449 created this api which gets all the contacts of passed contact type for customer passed and deletes them*/

-- API name		: Delete_All_Bill_Ship_Contacts
-- Type			: Private
-- Pre-reqs		: None.
-- Parameters           :
-- p_api_version                   IN NUMBER     Required Default = 1.0
-- p_init_msg_list                 IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_commit                        IN VARCHAR2   Required Default = FND_API.G_FALSE
-- p_validate_only                 IN VARCHAR2   Required Default = FND_API.G_TRUE
-- p_validation_level              IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module                IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode                    IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count                 IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_project_id                    IN NUMBER     Required
-- p_customer_id                   IN NUMBER     Required
-- p_bill_ship_customer_id         IN NUMBER     Required
-- p_project_contact_type_code     IN VARCHAR2   Required
-- x_return_status                 OUT VARCHAR2  Required
-- x_msg_count                     OUT NUMBER    Required
-- x_msg_data                      OUT VARCHAR2  Optional

PROCEDURE DELETE_ALL_BILL_SHIP_CONTACTS
( p_api_version                   IN NUMBER     := 1.0
  ,p_init_msg_list                 IN VARCHAR2   := FND_API.G_TRUE
  ,p_commit                        IN VARCHAR2   := FND_API.G_FALSE
  ,p_validate_only                 IN VARCHAR2   := FND_API.G_TRUE
  ,p_validation_level              IN NUMBER     := FND_API.G_VALID_LEVEL_FULL
  ,p_debug_mode                    IN VARCHAR2   := 'N'
  ,p_max_msg_count                 IN NUMBER     := FND_API.G_MISS_NUM
  ,p_project_id                    IN NUMBER
  ,p_customer_id                   IN NUMBER
  ,p_bill_ship_customer_id         IN NUMBER
  ,p_project_contact_type_code     IN VARCHAR2
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
   l_api_name                      CONSTANT VARCHAR(30) := 'Delete_All_Bill_Ship_Contacts';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);

   CURSOR C (c_project_id NUMBER, c_customer_id NUMBER, c_bill_ship_customer_id NUMBER, c_project_contact_type_code VARCHAR2) IS
      SELECT contact_id, record_version_number
      FROM pa_project_contacts
      WHERE project_id = c_project_id AND
            customer_id = c_customer_id AND
	    bill_ship_customer_id = c_bill_ship_customer_id AND
	    project_contact_type_code = c_project_contact_type_code;

   l_recinfo                       C%ROWTYPE;
BEGIN

    pa_debug.init_err_stack('PA_CUSTOMERS_CONTACTS_PUB.Delete_All_Bill_Ship_Contacts');

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_CUSTOMERS_CONTACTS_PVT.Delete_All_BILL_SHIP_Contacts BEGIN');
   end if;

   if p_commit = FND_API.G_TRUE then
      savepoint delete_all_bill_ship_contacts;
   end if;

    if not FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) then
      FND_MSG_PUB.initialize;
   end if;

   for l_recinfo in C(p_project_id, p_customer_id, p_bill_ship_customer_id, p_project_contact_type_code) loop
      PA_CUSTOMERS_CONTACTS_PVT.DELETE_CUSTOMER_CONTACT
      ( p_commit                    => FND_API.G_FALSE
       ,p_validate_only             => p_validate_only
       ,p_validation_level          => p_validation_level
       ,p_calling_module            => 'FORM'
       ,p_debug_mode                => p_debug_mode
       ,p_max_msg_count             => p_max_msg_count
       ,p_project_id                => p_project_id
       ,p_customer_id               => p_customer_id
       ,p_contact_id                => l_recinfo.contact_id
       ,p_project_contact_type_code => p_project_contact_type_code
       ,p_record_version_number     => l_recinfo.record_version_number
       ,x_return_status             => l_return_status
       ,x_msg_count                 => l_msg_count
       ,x_msg_data                  => l_msg_data);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
         x_msg_count := l_msg_count;
         if x_msg_count = 1 then
            x_msg_data := l_msg_data;
         end if;
         raise FND_API.G_EXC_ERROR;
      end if;
   end loop;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if p_commit = FND_API.G_TRUE then
      commit work;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_CUSTOMERS_CONTACTS_PVT.Delete_All_BILL_SHIP_Contacts END');
   end if;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_all_bill_ship_contacts;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
   when others then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_all_bill_ship_contacts;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CUSTOMERS_CONTACTS_PVT',
                              p_procedure_name => 'Delete_All_Bill_Ship_Contacts',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END DELETE_ALL_BILL_SHIP_CONTACTS;

END PA_CUSTOMERS_CONTACTS_PUB;

/
