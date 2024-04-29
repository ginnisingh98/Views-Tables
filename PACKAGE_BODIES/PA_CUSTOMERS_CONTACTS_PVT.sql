--------------------------------------------------------
--  DDL for Package Body PA_CUSTOMERS_CONTACTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CUSTOMERS_CONTACTS_PVT" AS
/* $Header: PARPCCVB.pls 120.6 2007/02/06 09:55:26 dthakker ship $ */


-- Global constant
G_PKG_NAME              CONSTANT VARCHAR2(30) := 'PA_CUSTOMERS_CONTACTS_PVT';


-- API name     : Create_Project_Customer
-- Type         : Private
-- Pre-reqs     : None.
-- Parameters           :
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
-- p_bill_to_customer_id           IN NUMBER     Required                                /* For Bug 2731449 */
-- p_ship_to_customer_id           IN NUMBER     Required                                /* For Bug 2731449 */
-- p_bill_to_address_id            IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_ship_to_address_id            IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_inv_currency_code             IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_inv_rate_type                 IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_inv_rate_date                 IN DATE       Optional Default = FND_API.G_MISS_DATE
-- p_inv_exchange_rate             IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_allow_user_rate_type_flag     IN VARCHAR2   Required Default = 'N'
-- p_receiver_task_id              IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- x_return_status                 OUT VARCHAR2  Required
-- x_msg_count                     OUT NUMBER    Required
-- x_msg_data                      OUT VARCHAR2  Optional

PROCEDURE CREATE_PROJECT_CUSTOMER
(  p_commit                        IN VARCHAR2   := FND_API.G_FALSE
  ,p_validate_only                 IN VARCHAR2   := FND_API.G_TRUE
  ,p_validation_level              IN NUMBER     := FND_API.G_VALID_LEVEL_FULL
  ,p_calling_module                IN VARCHAR2   := 'SELF_SERVICE'
  ,p_debug_mode                    IN VARCHAR2   := 'N'
  ,p_max_msg_count                 IN NUMBER     := FND_API.G_MISS_NUM
  ,p_project_id                    IN NUMBER
  ,p_customer_id                   IN NUMBER
  ,p_project_relationship_code     IN VARCHAR2
  ,p_customer_bill_split           IN NUMBER
  ,p_bill_to_customer_id           IN NUMBER                             /* For Bug 2731449 */
  ,p_ship_to_customer_id           IN NUMBER                             /* For Bug 2731449 */
  ,p_bill_to_address_id            IN NUMBER     := FND_API.G_MISS_NUM
  ,p_ship_to_address_id            IN NUMBER     := FND_API.G_MISS_NUM
  ,p_inv_currency_code             IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_inv_rate_type                 IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_inv_rate_date                 IN DATE       := FND_API.G_MISS_DATE
  ,p_inv_exchange_rate             IN NUMBER     := FND_API.G_MISS_NUM
  ,p_allow_user_rate_type_flag     IN VARCHAR2   := 'N'
  ,p_receiver_task_id              IN NUMBER     := FND_API.G_MISS_NUM
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,p_project_party_id              IN NUMBER DEFAULT NULL
--Billing setup related changes for FP_M development. Tracking bug 3279981
  ,p_Default_Top_Task_Cust_Flag    IN VARCHAR2
)
IS
   l_bill_another_project_flag     pa_project_customers.bill_another_project_flag%TYPE;
   l_msg_count                     NUMBER;
   l_last_update_date              DATE;
   l_last_updated_by               NUMBER(15);
   l_creation_date                 DATE;
   l_created_by                    NUMBER(15);
   l_last_update_login             NUMBER(15);
   l_rowid                         VARCHAR2(250);
   l_bill_to_address_id            NUMBER;
   l_ship_to_address_id            NUMBER;
   l_inv_currency_code             VARCHAR2(250);
   l_inv_rate_type                 VARCHAR2(250);
   l_inv_rate_date                 DATE;
   l_inv_exchange_rate             NUMBER;
   l_receiver_task_id              NUMBER;
   l_party_id                      NUMBER;
   l_project_party_id              NUMBER;
   l_resource_id                   NUMBER;
   l_wf_item_type                  VARCHAR2(30);
   l_wf_type                       VARCHAR2(30);
   l_wf_party_process              VARCHAR2(30);
   l_assignment_id                 NUMBER;
   l_return_status                 VARCHAR2(1);
   l_msg_data                      VARCHAR2(2000);
   l_end_date_active               DATE;

   -- anlee org role changes
   CURSOR l_check_org_csr IS
   SELECT PARTY_ID
   FROM PA_CUSTOMERS_V
   WHERE CUSTOMER_ID = p_customer_id
   AND   PARTY_TYPE = 'ORGANIZATION';

   l_temp                          NUMBER;
BEGIN
   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_CUSTOMERS_CONTACTS_PVT.Create_Project_Customer BEGIN');
   end if;

   if p_commit = FND_API.G_TRUE then
      savepoint create_project_customer_pvt;
   end if;

   if p_validation_level > 0 then
      if (p_debug_mode = 'Y') then
         pa_debug.debug('Performing validation...');
      end if;
--dbms_output.put_line('Before calling VALIDATE_CUSTOMER p_customer_id '||p_customer_id);
      PA_CUSTOMERS_CONTACTS_PVT.VALIDATE_CUSTOMER
      ( p_validation_level          => p_validation_level
       ,p_calling_module            => p_calling_module
       ,p_debug_mode                => p_debug_mode
       ,p_max_msg_count             => p_max_msg_count
       ,p_action                    => 'INSERT'
       ,p_project_id                => p_project_id
       ,p_customer_id               => p_customer_id
       ,p_customer_bill_split       => p_customer_bill_split
       ,p_bill_to_address_id        => p_bill_to_address_id                    /* For Bug 2731449 */
       ,p_ship_to_address_id        => p_ship_to_address_id                    /* For Bug 2731449 */
       ,p_inv_currency_code         => p_inv_currency_code
       ,p_inv_rate_type             => p_inv_rate_type
       ,p_inv_rate_date             => p_inv_rate_date
       ,p_inv_exchange_rate         => p_inv_exchange_rate
       ,p_allow_user_rate_type_flag => p_allow_user_rate_type_flag
       ,p_receiver_task_id          => p_receiver_task_id
       ,x_bill_another_project_flag => l_bill_another_project_flag);
--dbms_output.put_line('after  calling VALIDATE_CUSTOMER end '||l_msg_count);

      l_msg_count := FND_MSG_PUB.count_msg;
      if l_msg_count > 0 then
         x_msg_count := l_msg_count;

         raise FND_API.G_EXC_ERROR;
      end if;
   end if;

   -- Populate who column values
   l_last_update_date := sysdate;
   l_last_updated_by := fnd_global.user_id;
   l_creation_date := sysdate;
   l_created_by := fnd_global.user_id;
   l_last_update_login := fnd_global.login_id;

   -- Convert default constants to null
   if p_bill_to_address_id = FND_API.G_MISS_NUM then
      l_bill_to_address_id := NULL;
   else
      l_bill_to_address_id := p_bill_to_address_id;
   end if;

   if p_ship_to_address_id = FND_API.G_MISS_NUM then
      l_ship_to_address_id := NULL;
   else
      l_ship_to_address_id := p_ship_to_address_id;
   end if;

   if p_inv_currency_code = FND_API.G_MISS_CHAR then
      l_inv_currency_code := NULL;
   else
      l_inv_currency_code := p_inv_currency_code;
   end if;

   if p_inv_rate_type = FND_API.G_MISS_CHAR then
      l_inv_rate_type := NULL;
   else
      l_inv_rate_type := p_inv_rate_type;
   end if;

   if p_inv_rate_date = FND_API.G_MISS_DATE then
      l_inv_rate_date := NULL;
   else
      l_inv_rate_date := p_inv_rate_date;
   end if;

   if p_inv_exchange_rate = FND_API.G_MISS_NUM  OR
      upper(NVL(l_inv_rate_type,'x')) <> 'USER'		--Bug#5554475
   then
      l_inv_exchange_rate := NULL;
   else
      l_inv_exchange_rate := p_inv_exchange_rate;
   end if;

   if p_receiver_task_id = FND_API.G_MISS_NUM then
      l_receiver_task_id := NULL;
   else
      l_receiver_task_id := p_receiver_task_id;
   end if;

   if p_validate_only <> FND_API.G_TRUE then

      PA_PROJECT_CUSTOMERS_PKG.INSERT_ROW
      ( X_Rowid                       => l_rowid
       ,X_Project_Id                  => p_project_id
       ,X_Customer_Id                 => p_customer_id
       ,X_Last_Update_Date            => l_last_update_date
       ,X_Last_Updated_By             => l_last_updated_by
       ,X_Creation_Date               => l_creation_date
       ,X_Created_By                  => l_created_by
       ,X_Last_Update_Login           => l_last_update_login
       ,X_Project_Relationship_Code   => p_project_relationship_code
       ,X_Customer_Bill_Split         => p_customer_bill_split
       ,X_Bill_To_Customer_Id         => p_bill_to_customer_id                          /* For Bug 2731449 */
       ,X_Ship_To_Customer_Id         => p_ship_to_customer_id                          /* For Bug 2731449 */
       ,X_Bill_To_Address_Id          => l_bill_to_address_id
       ,X_Ship_To_Address_Id          => l_ship_to_address_id
       ,X_Inv_Currency_Code           => l_inv_currency_code
       ,X_Inv_Rate_Type               => l_inv_rate_type
       ,X_Inv_Rate_Date               => l_inv_rate_date
       ,X_Inv_Exchange_Rate           => l_inv_exchange_rate
       ,X_Allow_Inv_User_Rate_Type_Fg => p_allow_user_rate_type_flag
       ,X_Bill_Another_Project_Flag   => l_bill_another_project_flag
       ,X_Receiver_Task_Id            => l_receiver_task_id
       ,X_Record_Version_Number       => 1
--Billing setup related changes for FP_M development. Tracking bug 3279981
       ,X_Default_Top_Task_Cust_Flag  => p_Default_Top_Task_Cust_Flag );

      -- anlee org role changes
      -- If p_project_party_id is not null, then this API has been
      -- called from org details flow
      -- In this case, just update pa_project_customers with this
      -- project_party_id
      if p_project_party_id is not null then
         UPDATE PA_PROJECT_CUSTOMERS
         SET project_party_id = p_project_party_id
         WHERE rowid = l_rowid;
      else
         -- Not from org details flow
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
            l_temp := null;
            -- check if the org already exists as a customer org on the project
            l_temp := PA_PROJECT_PARTIES_UTILS.get_customer_project_party_id
                      ( p_project_id  => p_project_id
                       ,p_customer_id => p_customer_id);

            if l_temp is null then

               PA_PROJECT_PARTIES_PUB.CREATE_PROJECT_PARTY(
                 p_validate_only              => FND_API.G_FALSE
               , p_object_id                  => p_project_id
               , p_OBJECT_TYPE                => 'PA_PROJECTS'
               , p_project_role_id            => 100
               , p_project_role_type          => 'CUSTOMER ORG'
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
               if l_msg_count > 0 then
                  x_msg_count := l_msg_count;

                  raise FND_API.G_EXC_ERROR;
               end if;

               -- Add the new project party ID to the customers row
               UPDATE PA_PROJECT_CUSTOMERS
               SET project_party_id = l_project_party_id
               WHERE rowid = l_rowid;
            else
               -- Add the existing project party ID to the customers row
               UPDATE PA_PROJECT_CUSTOMERS
               SET project_party_id = l_temp
               WHERE rowid = l_rowid;
            end if;
         end if;

      end if;
   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if p_commit = FND_API.G_TRUE then
      commit work;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_CUSTOMERS_CONTACTS_PVT.Create_Project_Customer END');
   end if;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to create_project_customer_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
   when others then
      if p_commit = FND_API.G_TRUE then
         rollback to create_project_customer_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CUSTOMERS_CONTACTS_PVT',
                              p_procedure_name => 'Create_Project_Customer',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END CREATE_PROJECT_CUSTOMER;


-- API name     : Update_Project_Customer
-- Type         : Private
-- Pre-reqs     : None.
-- Parameters           :
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
-- p_bill_to_customer_id           IN NUMBER     Required
-- p_ship_to_customer_id           IN NUMBER     Required
-- p_bill_to_address_id            IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_ship_to_address_id            IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_inv_currency_code             IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_inv_rate_type                 IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_inv_rate_date                 IN DATE       Optional Default = FND_API.G_MISS_DATE
-- p_inv_exchange_rate             IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_allow_user_rate_type_flag     IN VARCHAR2   Required Default = 'N'
-- p_receiver_task_id              IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_record_version_number         IN NUMBER     Required Default = FND_API.G_MISS_NUM
-- x_return_status                 OUT VARCHAR2  Required
-- x_msg_count                     OUT NUMBER    Required
-- x_msg_data                      OUT VARCHAR2  Optional

PROCEDURE UPDATE_PROJECT_CUSTOMER
(  p_commit                        IN VARCHAR2   := FND_API.G_FALSE
  ,p_validate_only                 IN VARCHAR2   := FND_API.G_TRUE
  ,p_validation_level              IN NUMBER     := FND_API.G_VALID_LEVEL_FULL
  ,p_calling_module                IN VARCHAR2   := 'SELF_SERVICE'
  ,p_debug_mode                    IN VARCHAR2   := 'N'
  ,p_max_msg_count                 IN NUMBER     := FND_API.G_MISS_NUM
  ,p_project_id                    IN NUMBER
  ,p_customer_id                   IN NUMBER
  ,p_project_relationship_code     IN VARCHAR2
  ,p_customer_bill_split           IN NUMBER
  ,p_bill_to_customer_id           IN NUMBER                                     /* For Bug 2731449 */
  ,p_ship_to_customer_id           IN NUMBER                                     /* For Bug 2731449 */
  ,p_bill_to_address_id            IN NUMBER     := FND_API.G_MISS_NUM
  ,p_ship_to_address_id            IN NUMBER     := FND_API.G_MISS_NUM
  ,p_inv_currency_code             IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_inv_rate_type                 IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_inv_rate_date                 IN DATE       := FND_API.G_MISS_DATE
  ,p_inv_exchange_rate             IN NUMBER     := FND_API.G_MISS_NUM
  ,p_allow_user_rate_type_flag     IN VARCHAR2   := 'N'
  ,p_receiver_task_id              IN NUMBER     := FND_API.G_MISS_NUM
  ,p_bill_another_project_flag     IN VARCHAR2   := 'N' --Added by Aditi for tracking bug 4153629
  ,p_record_version_number         IN NUMBER     := FND_API.G_MISS_NUM
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
--Billing setup related changes for FP_M development. Tracking bug 3279981
  ,p_Default_Top_Task_Cust_Flag    IN VARCHAR2
)
IS
   l_bill_another_project_flag     pa_project_customers.bill_another_project_flag%TYPE;
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR(250);
   l_last_update_date              DATE;
   l_last_updated_by               NUMBER(15);
   l_last_update_login             NUMBER(15);
   l_rowid                         VARCHAR2(250);
   l_dummy                         VARCHAR2(1);
   l_bill_to_address_id            NUMBER;
   l_ship_to_address_id            NUMBER;
   l_inv_currency_code             VARCHAR2(250);
   l_inv_rate_type                 VARCHAR2(250);
   l_inv_rate_date                 DATE;
   l_inv_exchange_rate             NUMBER;
   l_receiver_task_id              NUMBER;

   CURSOR C (c_project_id NUMBER, c_customer_id NUMBER) IS
      SELECT rowid
      FROM pa_project_customers
      WHERE project_id = c_project_id AND
            customer_id = c_customer_id;

BEGIN
--dbms_output.put_line('value of p_project_relationship_code in pvt '||p_project_relationship_code);
--dbms_output.put_line('Value of p_validate_only'||p_validate_only);
--dbms_output.put_line('Value of p_validation_level'||p_validation_level);

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_CUSTOMERS_CONTACTS_PVT.Update_Project_Customer BEGIN');
   end if;

   if p_commit = FND_API.G_TRUE then
      savepoint update_project_customer_pvt;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('Locking record...');
   end if;

   if p_validate_only <> FND_API.G_TRUE then
      BEGIN
         SELECT 'x' INTO l_dummy
         FROM pa_project_customers
         WHERE project_id = p_project_id
         AND customer_id = p_customer_id
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
   --dbms_output.put_line('control wil come till here - print ');
      --dbms_output.put_line('control wil come till here - print p_project_id '||p_project_id);

   --dbms_output.put_line('control wil come till here - print p_customer_id'||p_customer_id);
   --dbms_output.put_line('control wil come till here - print p_record_version_number'||p_record_version_number);

      BEGIN
         SELECT 'x' INTO l_dummy
         FROM pa_project_customers
         WHERE project_id = p_project_id
         AND customer_id = p_customer_id
         AND record_version_number = p_record_version_number;
      EXCEPTION
         when NO_DATA_FOUND then
	 --dbms_output.put_line('comes here');
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
	 	 --dbms_output.put_line('comes here'||sqlerrm);

            raise;
      END;
   end if;
--dbms_output.put_line('thuis tooo');
   l_msg_count := FND_MSG_PUB.count_msg;
--dbms_output.put_line('thuis tooo l_msg_count'||l_msg_count);

   if l_msg_count > 0 then
      x_msg_count := l_msg_count;
      if x_msg_count = 1 then
         x_msg_data := l_msg_data;
      end if;
      raise FND_API.G_EXC_ERROR;
   end if;
--dbms_output.put_line('Value of p_validate_only'||p_validate_only);
--dbms_output.put_line('Value of p_bill_another_project_flag  before 11 insert_row '||p_bill_another_project_flag);



--dbms_output.put_line('Value of l_bill_another_project_flag  before 11 insert_row '||l_bill_another_project_flag);

   if p_validation_level > 0 then
      if (p_debug_mode = 'Y') then
         pa_debug.debug('Performing validation...');
      end if;
--dbms_output.put_line('value of p_project_relationship_code in pvt '||p_project_relationship_code);
--dbms_output.put_line('value of p_calling_module passed from pvt to validate'||p_calling_module);
      PA_CUSTOMERS_CONTACTS_PVT.VALIDATE_CUSTOMER
      ( p_validation_level          => p_validation_level
       ,p_calling_module            => p_calling_module
       ,p_debug_mode                => p_debug_mode
       ,p_max_msg_count             => p_max_msg_count
       ,p_action                    => 'UPDATE'
       ,p_project_id                => p_project_id
       ,p_customer_id               => p_customer_id
       ,p_customer_bill_split       => p_customer_bill_split
       ,p_bill_to_address_id        => p_bill_to_address_id
       ,p_ship_to_address_id        => p_ship_to_address_id
       ,p_inv_currency_code         => p_inv_currency_code
       ,p_inv_rate_type             => p_inv_rate_type
       ,p_inv_rate_date             => p_inv_rate_date
       ,p_inv_exchange_rate         => p_inv_exchange_rate
       ,p_allow_user_rate_type_flag => p_allow_user_rate_type_flag
       ,p_receiver_task_id          => p_receiver_task_id
       ,x_bill_another_project_flag => l_bill_another_project_flag);
--dbms_output.put_line('Value of l_bill_another_project_flag  before 22222 insert_row '||l_bill_another_project_flag);

      l_msg_count := FND_MSG_PUB.count_msg;
      --dbms_output.put_line('Value of l_msg_count'||l_msg_count);
      if l_msg_count > 0 then
         x_msg_count := l_msg_count;

         raise FND_API.G_EXC_ERROR;
      end if;
   end if;
--dbms_output.put_line('value of p_project_relationship_code after validate  '||p_project_relationship_code);

   -- Populate who column values
   l_last_update_date := sysdate;
   l_last_updated_by := fnd_global.user_id;
   l_last_update_login := fnd_global.login_id;

   -- Convert default constants to null
   if p_bill_to_address_id = FND_API.G_MISS_NUM then
      l_bill_to_address_id := NULL;
   else
      l_bill_to_address_id := p_bill_to_address_id;
   end if;

   if p_ship_to_address_id = FND_API.G_MISS_NUM then
      l_ship_to_address_id := NULL;
   else
      l_ship_to_address_id := p_ship_to_address_id;
   end if;

   if p_inv_currency_code = FND_API.G_MISS_CHAR then
      l_inv_currency_code := NULL;
   else
      l_inv_currency_code := p_inv_currency_code;
   end if;

   if p_inv_rate_type = FND_API.G_MISS_CHAR then
      l_inv_rate_type := NULL;
   else
      l_inv_rate_type := p_inv_rate_type;
   end if;

   if p_inv_rate_date = FND_API.G_MISS_DATE then
      l_inv_rate_date := NULL;
   else
      l_inv_rate_date := p_inv_rate_date;
   end if;

   if p_inv_exchange_rate = FND_API.G_MISS_NUM  OR
      upper(NVL(l_inv_rate_type,'x')) <> 'USER' --bug 3116595
   then
      l_inv_exchange_rate := NULL;
   else
      l_inv_exchange_rate := p_inv_exchange_rate;
   end if;

   if p_receiver_task_id = FND_API.G_MISS_NUM then
      l_receiver_task_id := NULL;
   else
      l_receiver_task_id := p_receiver_task_id;
   end if;
--dbms_output.put_line('Value of p_validate_only'||p_validate_only);
   if p_validate_only <> FND_API.G_TRUE then
      open C(p_project_id, p_customer_id);
      fetch C into l_rowid;
      close C;
--dbms_output.put_line('value of p_project_relationship_code in pvt be4 update_row '||p_project_relationship_code);
--dbms_output.put_line('Value of l_bill_another_project_flag  before insert_row '||l_bill_another_project_flag);
/* Added for tracking bug 4153629 */
 IF (p_calling_module = 'AMG') THEN
 l_bill_another_project_flag := p_bill_another_project_flag; -- aDDED FOR TRACKING bug
 End If;
 /* End of changes for tracking bug 4153629*/
      PA_PROJECT_CUSTOMERS_PKG.UPDATE_ROW
      ( X_Rowid                       => l_rowid
       ,X_Project_Id                  => p_project_id
       ,X_Customer_Id                 => p_customer_id
       ,X_Last_Update_Date            => l_last_update_date
       ,X_Last_Updated_By             => l_last_updated_by
       ,X_Last_Update_Login           => l_last_update_login
       ,X_Project_Relationship_Code   => p_project_relationship_code
       ,X_Customer_Bill_Split         => p_customer_bill_split
       ,X_Bill_To_Customer_Id         => p_bill_to_customer_id           /* For Bug 2731449 */
       ,X_Ship_To_Customer_Id         => p_ship_to_customer_id           /* For Bug 2731449 */
       ,X_Bill_To_Address_Id          => l_bill_to_address_id
       ,X_Ship_To_Address_Id          => l_ship_to_address_id
       ,X_Inv_Currency_Code           => l_inv_currency_code
       ,X_Inv_Rate_Type               => l_inv_rate_type
       ,X_Inv_Rate_Date               => l_inv_rate_date
       ,X_Inv_Exchange_Rate           => l_inv_exchange_rate
       ,X_Allow_Inv_User_Rate_Type_Fg => p_allow_user_rate_type_flag
       ,X_Bill_Another_Project_Flag   => l_bill_another_project_flag
       ,X_Receiver_Task_Id            => l_receiver_task_id
       ,X_Record_Version_Number       => p_record_version_number
--Billing setup related changes for FP_M development. Tracking bug 3279981
       ,X_Default_Top_Task_Cust_Flag  => p_Default_Top_Task_Cust_Flag    );
   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if p_commit = FND_API.G_TRUE then
      commit work;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_CUSTOMERS_CONTACTS_PVT.Update_Project_Customer END');
   end if;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_project_customer_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
   when others then
      if p_commit = FND_API.G_TRUE then
         rollback to update_project_customer_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CUSTOMERS_CONTACTS_PVT',
                              p_procedure_name => 'Update_Project_Customer',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END UPDATE_PROJECT_CUSTOMER;


-- API name     : Delete_Project_Customer
-- Type         : Private
-- Pre-reqs     : None.
-- Parameters           :
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
(  p_commit                        IN VARCHAR2   := FND_API.G_FALSE
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
   l_bill_another_project_flag     pa_project_customers.bill_another_project_flag%TYPE;
   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_rowid                         VARCHAR2(250);
   l_dummy                         VARCHAR2(1);
/* Variables declared for bug 3101990 */
   l_project_party_id              pa_project_customers.project_party_id%TYPE;
   l_ext_people_exists         pa_project_customers.project_party_id%TYPE;
   l_billing_accnt_exists      pa_project_customers.project_party_id%TYPE;

   CURSOR C (c_project_id NUMBER, c_customer_id NUMBER) IS
      SELECT rowid
      FROM pa_project_customers
      WHERE project_id = c_project_id AND
            customer_id = c_customer_id;

/* 3 new cursors defined for bug 3101990 */

   CURSOR get_project_party_id IS
      SELECT project_party_id
      FROM  pa_project_customers
      WHERE project_id = p_project_id AND
            customer_id = p_customer_id;

   -- 4616302 TCA UPTAKE: HZ_PARTY_RELATIONS IMPACTS
   -- changed hz_party_relationships usage to hz_relationships
   -- changed column party_relationship_type usage to relationship_type

   /*
   CURSOR c_ext_people_exists(c_project_party_id NUMBER) IS
        SELECT pp.project_party_id project_party_id
    FROM pa_project_parties po,
         pa_project_parties pp,
         hz_party_relationships hzr
    WHERE po.resource_type_id = 112
    AND po.project_party_id = c_project_party_id
    AND pp.resource_type_id = 112
    AND pp.object_type = po.object_type
    AND pp.object_id = po.object_id
    AND hzr.party_relationship_type IN ( 'EMPLOYEE_OF', 'CONTACT_OF')
    AND hzr.subject_id = pp.resource_source_id
    AND hzr.object_id = po.resource_source_id;
    */

   CURSOR c_ext_people_exists(c_project_party_id NUMBER) IS
        SELECT pp.project_party_id project_party_id
    FROM pa_project_parties po,
         pa_project_parties pp,
         hz_relationships hzr
    WHERE po.resource_type_id = 112
    AND po.project_party_id = c_project_party_id
    AND pp.resource_type_id = 112
    AND pp.object_type = po.object_type
    AND pp.object_id = po.object_id
    AND hzr.relationship_code IN ( 'EMPLOYEE_OF', 'CONTACT_OF')
    AND hzr.subject_id = pp.resource_source_id
    AND hzr.object_id = po.resource_source_id
    AND hzr.object_table_name = 'HZ_PARTIES'
    AND hzr.subject_type = 'PERSON'
    AND hzr.subject_table_name = 'HZ_PARTIES';

   -- 4616302 end

   CURSOR c_billing_accnt_exists(c_project_party_id NUMBER) IS
      SELECT project_party_id
    FROM pa_project_customers
    WHERE project_id = p_project_id
    AND project_party_id = c_project_party_id
    AND customer_id <> p_customer_id;

/* End of cursors added for bug 3101990 */

BEGIN
   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_CUSTOMERS_CONTACTS_PVT.Delete_Project_Customer BEGIN');
   end if;

   if p_commit = FND_API.G_TRUE then
      savepoint delete_project_customer_pvt;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('Locking record...');
   end if;

   if p_validate_only <> FND_API.G_TRUE then
      BEGIN
         SELECT 'x' INTO l_dummy
         FROM pa_project_customers
         WHERE project_id = p_project_id
         AND customer_id = p_customer_id
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
         FROM pa_project_customers
         WHERE project_id = p_project_id
         AND customer_id = p_customer_id
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

      PA_CUSTOMERS_CONTACTS_PVT.VALIDATE_CUSTOMER
      ( p_validation_level          => p_validation_level
       ,p_calling_module            => p_calling_module
       ,p_debug_mode                => p_debug_mode
       ,p_max_msg_count             => p_max_msg_count
       ,p_action                    => 'DELETE'
       ,p_project_id                => p_project_id
       ,p_customer_id               => p_customer_id
       ,x_bill_another_project_flag => l_bill_another_project_flag);

      l_msg_count := FND_MSG_PUB.count_msg;
      if l_msg_count > 0 then
         x_msg_count := l_msg_count;

         raise FND_API.G_EXC_ERROR;
      end if;
   end if;

   PA_CUSTOMERS_CONTACTS_PVT.DELETE_ALL_CONTACTS
      ( p_commit           => FND_API.G_FALSE
       ,p_validate_only    => p_validate_only
       ,p_validation_level => p_validation_level
       ,p_calling_module   => p_calling_module
       ,p_debug_mode       => p_debug_mode
       ,p_max_msg_count    => p_max_msg_count
       ,p_project_id       => p_project_id
       ,p_customer_id      => p_customer_id
       ,x_return_status    => l_return_status
       ,x_msg_count        => l_msg_count
       ,x_msg_data         => l_msg_data);

   if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      x_msg_count := l_msg_count;
      if x_msg_count = 1 then
         x_msg_data := l_msg_data;
      end if;
      raise FND_API.G_EXC_ERROR;
   end if;

   if p_validate_only <> FND_API.G_TRUE then

      -- anlee
      -- retention changes
      PA_RETENTION_UTIL.delete_retn_rules_customer
      ( p_project_id    => p_project_id
       ,p_customer_id   => p_customer_id
       ,x_return_status => l_return_status
       ,x_msg_count     => l_msg_count
       ,x_msg_data      => l_msg_data);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
         x_msg_count := l_msg_count;
         if x_msg_count = 1 then
            x_msg_data := l_msg_data;
         end if;
         raise FND_API.G_EXC_ERROR;
      end if;

/*  Bug 3101990 - We are deleting the Customer Org role record in pa_project_parties if calling module is FORM,
and if there are no references for this project party record */

     IF p_calling_module = 'FORM' THEN

      OPEN get_project_party_id;
      FETCH get_project_party_id INTO l_project_party_id;
      CLOSE get_project_party_id;

      IF (l_project_party_id IS NOT NULL) THEN
       OPEN c_ext_people_exists(l_project_party_id);
       FETCH c_ext_people_exists INTO l_ext_people_exists;
       IF (c_ext_people_exists%NOTFOUND) THEN
              OPEN c_billing_accnt_exists(l_project_party_id);
          FETCH c_billing_accnt_exists INTO l_billing_accnt_exists;
          IF (c_billing_accnt_exists%NOTFOUND) THEN
                  pa_project_parties_pkg.delete_row(x_project_id => p_project_id,
                                     x_project_party_id => l_project_party_id,
                     x_record_version_number => null);

                       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  CLOSE c_billing_accnt_exists;
                  CLOSE c_ext_people_exists;
                  x_msg_count := l_msg_count;
                  IF x_msg_count = 1 THEN
                     x_msg_data := l_msg_data;
                  END IF;
                  RAISE FND_API.G_EXC_ERROR;
              END IF;
          END IF;
              CLOSE c_billing_accnt_exists;
       END IF;
       CLOSE c_ext_people_exists;
      END IF;
    END IF; --- If p_calling_module

/* End of code added for bug 3101990 */

      -- Delete the customer
      open C(p_project_id, p_customer_id);
      fetch C into l_rowid;
      close C;

      PA_PROJECT_CUSTOMERS_PKG.DELETE_ROW(l_rowid, p_record_version_number);
   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if p_commit = FND_API.G_TRUE then
      commit work;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_CUSTOMERS_CONTACTS_PVT.Delete_Project_Customer END');
   end if;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_project_customer_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
   when others then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_project_customer_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CUSTOMERS_CONTACTS_PVT',
                              p_procedure_name => 'Delete_Project_Customer',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END DELETE_PROJECT_CUSTOMER;


-- API name     : Create_Customer_Contact
-- Type         : Private
-- Pre-reqs     : None.
-- Parameters           :
-- p_commit                        IN VARCHAR2   Required Default = FND_API.G_FALSE
-- p_validate_only                 IN VARCHAR2   Required Default = FND_API.G_TRUE
-- p_validation_level              IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module                IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode                    IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count                 IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_project_id                    IN NUMBER     Required
-- p_customer_id                   IN NUMBER     Required
-- p_bill_ship_customer_id         IN NUMBER     Required
-- p_contact_id                    IN NUMBER     Required
-- p_project_contact_type_code     IN VARCHAR2   Required
-- x_return_status                 OUT VARCHAR2  Required
-- x_msg_count                     OUT NUMBER    Required
-- x_msg_data                      OUT VARCHAR2  Optional

PROCEDURE CREATE_CUSTOMER_CONTACT
(  p_commit                        IN VARCHAR2   := FND_API.G_FALSE
  ,p_validate_only                 IN VARCHAR2   := FND_API.G_TRUE
  ,p_validation_level              IN NUMBER     := FND_API.G_VALID_LEVEL_FULL
  ,p_calling_module                IN VARCHAR2   := 'SELF_SERVICE'
  ,p_debug_mode                    IN VARCHAR2   := 'N'
  ,p_max_msg_count                 IN NUMBER     := FND_API.G_MISS_NUM
  ,p_project_id                    IN NUMBER
  ,p_customer_id                   IN NUMBER
  ,p_bill_ship_customer_id         IN NUMBER                                 /* For Bug 2731449 */
  ,p_contact_id                    IN NUMBER
  ,p_project_contact_type_code     IN VARCHAR2
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
   l_msg_count                     NUMBER;
   l_last_update_date              DATE;
   l_last_updated_by               NUMBER(15);
   l_creation_date                 DATE;
   l_created_by                    NUMBER(15);
   l_last_update_login             NUMBER(15);
   l_rowid                         VARCHAR2(250);
BEGIN
   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_CUSTOMERS_CONTACTS_PVT.Create_Customer_Contact BEGIN');
   end if;

   if p_commit = FND_API.G_TRUE then
      savepoint create_customer_contact_pvt;
   end if;

   if p_validation_level > 0 then
      if (p_debug_mode = 'Y') then
         pa_debug.debug('Performing validation...');
      end if;

      PA_CUSTOMERS_CONTACTS_PVT.VALIDATE_CONTACT
      ( p_validation_level          => p_validation_level
       ,p_calling_module            => p_calling_module
       ,p_debug_mode                => p_debug_mode
       ,p_max_msg_count             => p_max_msg_count
       ,p_action                    => 'INSERT'
       ,p_project_id                => p_project_id
       ,p_customer_id               => p_bill_ship_customer_id              /* For Bug 2731449 */
       ,p_contact_id                => p_contact_id
       ,p_project_contact_type_code => p_project_contact_type_code);

      l_msg_count := FND_MSG_PUB.count_msg;
      if l_msg_count > 0 then
         x_msg_count := l_msg_count;

         raise FND_API.G_EXC_ERROR;
      end if;
   end if;

   -- Populate who column values
   l_last_update_date := sysdate;
   l_last_updated_by := fnd_global.user_id;
   l_creation_date := sysdate;
   l_created_by := fnd_global.user_id;
   l_last_update_login := fnd_global.login_id;

   if p_validate_only <> FND_API.G_TRUE then
      PA_PROJECT_CONTACTS_PKG.INSERT_ROW
      ( X_Rowid                     => l_rowid
       ,X_Project_Id                => p_project_id
       ,X_Customer_Id               => p_customer_id
       ,X_Bill_Ship_Customer_Id     => p_bill_ship_customer_id                     /* For Bug 2731449 */
       ,X_Contact_Id                => p_contact_id
       ,X_Project_Contact_Type_Code => p_project_contact_type_code
       ,X_Last_Update_Date          => l_last_update_date
       ,X_Last_Updated_By           => l_last_updated_by
       ,X_Creation_Date             => l_creation_date
       ,X_Created_By                => l_created_by
       ,X_Last_Update_Login         => l_last_update_login
       ,X_Record_Version_Number     => 1);
   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if p_commit = FND_API.G_TRUE then
      commit work;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_CUSTOMERS_CONTACTS_PVT.Create_Customer_Contact END');
   end if;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to create_customer_contact_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
   when others then
      if p_commit = FND_API.G_TRUE then
         rollback to create_customer_contact_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CUSTOMERS_CONTACTS_PVT',
                              p_procedure_name => 'Create_Customer_Contact',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END CREATE_CUSTOMER_CONTACT;


-- API name     : Update_Customer_Contact
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
-- p_project_id                    IN NUMBER     Required
-- p_customer_id                   IN NUMBER     Required
-- p_bill_ship_customer_id         IN NUMBER     Required
-- p_contact_id                    IN NUMBER     Required
-- p_project_contact_type_code     IN VARCHAR2   Required
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
  ,p_bill_ship_customer_id         IN NUMBER                                      /* For Bug 2731449 */
  ,p_contact_id                    IN NUMBER
  ,p_project_contact_type_code     IN VARCHAR2
  ,p_rowid                         IN VARCHAR2
  ,p_record_version_number         IN NUMBER
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_dummy                         VARCHAR2(1);
   l_last_update_date              DATE;
   l_last_updated_by               NUMBER(15);
   l_last_update_login             NUMBER(15);
BEGIN
   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_CUSTOMERS_CONTACTS_PVT.Update_Customer_Contact BEGIN');
   end if;

   if p_commit = FND_API.G_TRUE then
      savepoint update_customer_contact_pvt;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('Locking record...');
   end if;

   if p_validate_only <> FND_API.G_TRUE then
      BEGIN
         SELECT 'x' INTO l_dummy
         FROM pa_project_contacts
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
         FROM pa_project_contacts
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

      PA_CUSTOMERS_CONTACTS_PVT.VALIDATE_CONTACT
      ( p_validation_level          => p_validation_level
       ,p_calling_module            => p_calling_module
       ,p_debug_mode                => p_debug_mode
       ,p_max_msg_count             => p_max_msg_count
       ,p_action                    => 'UPDATE'
       ,p_project_id                => p_project_id
       ,p_customer_id               => p_bill_ship_customer_id               /* For Bug 2731449 */
       ,p_contact_id                => p_contact_id
       ,p_project_contact_type_code => p_project_contact_type_code
       ,p_rowid                     => p_rowid);

      l_msg_count := FND_MSG_PUB.count_msg;
      if l_msg_count > 0 then
         x_msg_count := l_msg_count;

         raise FND_API.G_EXC_ERROR;
      end if;
   end if;

   -- Populate who column values
   l_last_update_date := sysdate;
   l_last_updated_by := fnd_global.user_id;
   l_last_update_login := fnd_global.login_id;

   if p_validate_only <> FND_API.G_TRUE then
      PA_PROJECT_CONTACTS_PKG.UPDATE_ROW
      ( X_Rowid                     => p_rowid
       ,X_Project_Id                => p_project_id
       ,X_Customer_Id               => p_customer_id
       ,X_Bill_Ship_Customer_Id     => p_bill_ship_customer_id                /* For Bug 2731449 */
       ,X_Contact_Id                => p_contact_id
       ,X_Project_Contact_Type_Code => p_project_contact_type_code
       ,X_Last_Update_Date          => l_last_update_date
       ,X_Last_Updated_By           => l_last_updated_by
       ,X_Last_Update_Login         => l_last_update_login
       ,X_Record_Version_Number     => p_record_version_number);
   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if p_commit = FND_API.G_TRUE then
      commit work;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_CUSTOMERS_CONTACTS_PVT.Update_Customer_Contact END');
   end if;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_customer_contact_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
   when others then
      if p_commit = FND_API.G_TRUE then
         rollback to update_customer_contact_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CUSTOMERS_CONTACTS_PVT',
                              p_procedure_name => 'Update_Customer_Contact',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END UPDATE_CUSTOMER_CONTACT;


-- API name     : Delete_Customer_Contact
-- Type         : Private
-- Pre-reqs     : None.
-- Parameters           :
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
(  p_commit                        IN VARCHAR2   := FND_API.G_FALSE
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
   l_rowid                         VARCHAR2(250);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_dummy                         VARCHAR2(1);

   CURSOR C (c_project_id NUMBER, c_customer_id NUMBER, c_contact_id NUMBER,
             c_project_contact_type_code VARCHAR2) IS
      SELECT rowid
      FROM pa_project_contacts
      WHERE project_id = c_project_id AND
            customer_id = c_customer_id AND
            contact_id = c_contact_id AND
            project_contact_type_code = c_project_contact_type_code;
BEGIN
   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_CUSTOMERS_CONTACTS_PVT.Delete_Customer_Contact BEGIN');
   end if;

   if p_commit = FND_API.G_TRUE then
      savepoint delete_customer_contact_pvt;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('Locking record...');
   end if;

   if p_validate_only <> FND_API.G_TRUE then
      BEGIN
         SELECT 'x' INTO l_dummy
         FROM pa_project_contacts
         WHERE project_id = p_project_id
         AND customer_id = p_customer_id
         AND contact_id = p_contact_id
         AND project_contact_type_code = p_project_contact_type_code
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
         FROM pa_project_contacts
         WHERE project_id = p_project_id
         AND customer_id = p_customer_id
         AND contact_id = p_contact_id
         AND project_contact_type_code = p_project_contact_type_code
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

   if p_validate_only <> FND_API.G_TRUE then
      open C(p_project_id, p_customer_id, p_contact_id, p_project_contact_type_code);
      fetch C into l_rowid;
      close C;

      PA_PROJECT_CONTACTS_PKG.DELETE_ROW(l_rowid, p_record_version_number);
   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if p_commit = FND_API.G_TRUE then
      commit work;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_CUSTOMERS_CONTACTS_PVT.Delete_Customer_Contact END');
   end if;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_customer_contact_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
   when others then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_customer_contact_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CUSTOMERS_CONTACTS_PVT',
                              p_procedure_name => 'Delete_Customer_Contact',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END DELETE_CUSTOMER_CONTACT;


-- API name     : Delete_All_Contacts
-- Type         : Private
-- Pre-reqs     : None.
-- Parameters           :
-- p_commit                        IN VARCHAR2   Required Default = FND_API.G_FALSE
-- p_validate_only                 IN VARCHAR2   Required Default = FND_API.G_TRUE
-- p_validation_level              IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module                IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode                    IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count                 IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_project_id                    IN NUMBER     Required
-- p_customer_id                   IN NUMBER     Required
-- x_return_status                 OUT VARCHAR2  Required
-- x_msg_count                     OUT NUMBER    Required
-- x_msg_data                      OUT VARCHAR2  Optional

PROCEDURE DELETE_ALL_CONTACTS
(  p_commit                        IN VARCHAR2   := FND_API.G_FALSE
  ,p_validate_only                 IN VARCHAR2   := FND_API.G_TRUE
  ,p_validation_level              IN NUMBER     := FND_API.G_VALID_LEVEL_FULL
  ,p_calling_module                IN VARCHAR2   := 'SELF_SERVICE'
  ,p_debug_mode                    IN VARCHAR2   := 'N'
  ,p_max_msg_count                 IN NUMBER     := FND_API.G_MISS_NUM
  ,p_project_id                    IN NUMBER
  ,p_customer_id                   IN NUMBER
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);

   CURSOR C (c_project_id NUMBER, c_customer_id NUMBER) IS
      SELECT contact_id, project_contact_type_code, record_version_number
      FROM pa_project_contacts
      WHERE project_id = c_project_id AND
            customer_id = c_customer_id;
   l_recinfo                       C%ROWTYPE;
BEGIN
   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_CUSTOMERS_CONTACTS_PVT.Delete_All_Contacts BEGIN');
   end if;

   if p_commit = FND_API.G_TRUE then
      savepoint delete_all_contacts_pvt;
   end if;

   for l_recinfo in C(p_project_id, p_customer_id) loop
      PA_CUSTOMERS_CONTACTS_PVT.DELETE_CUSTOMER_CONTACT
      ( p_commit                    => FND_API.G_FALSE
       ,p_validate_only             => p_validate_only
       ,p_validation_level          => p_validation_level
       ,p_calling_module            => p_calling_module
       ,p_debug_mode                => p_debug_mode
       ,p_max_msg_count             => p_max_msg_count
       ,p_project_id                => p_project_id
       ,p_customer_id               => p_customer_id
       ,p_contact_id                => l_recinfo.contact_id
       ,p_project_contact_type_code => l_recinfo.project_contact_type_code
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
      pa_debug.debug('PA_CUSTOMERS_CONTACTS_PVT.Delete_All_Contacts END');
   end if;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_all_contacts_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
   when others then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_all_contacts_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CUSTOMERS_CONTACTS_PVT',
                              p_procedure_name => 'Delete_All_Contacts',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END DELETE_ALL_CONTACTS;


-- API name     : Validate_Customer
-- Type         : Private
-- Pre-reqs     : None.
-- Parameters           :
-- p_validation_level              IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module                IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode                    IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count                 IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_action                        IN VARCHAR2   Required
-- p_project_id                    IN NUMBER     Required
-- p_customer_id                   IN NUMBER     Required
-- p_customer_bill_split           IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_bill_to_address_id            IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_ship_to_address_id            IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_inv_currency_code             IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_inv_rate_type                 IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_inv_rate_date                 IN DATE       Optional Default = FND_API.G_MISS_DATE
-- p_inv_exchange_rate             IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_allow_user_rate_type_flag     IN VARCHAR2   Optional Default = 'N'
-- p_receiver_task_id              IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- x_bill_another_project_flag     OUT VARCHAR2  Optional

PROCEDURE VALIDATE_CUSTOMER
(  p_validation_level              IN NUMBER     := FND_API.G_VALID_LEVEL_FULL
  ,p_calling_module                IN VARCHAR2   := 'SELF_SERVICE'
  ,p_debug_mode                    IN VARCHAR2   := 'N'
  ,p_max_msg_count                 IN NUMBER     := FND_API.G_MISS_NUM
  ,p_action                        IN VARCHAR2
  ,p_project_id                    IN NUMBER
  ,p_customer_id                   IN NUMBER
  ,p_customer_bill_split           IN NUMBER     := FND_API.G_MISS_NUM
  ,p_bill_to_address_id            IN NUMBER     := FND_API.G_MISS_NUM
  ,p_ship_to_address_id            IN NUMBER     := FND_API.G_MISS_NUM
  ,p_inv_currency_code             IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_inv_rate_type                 IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_inv_rate_date                 IN DATE       := FND_API.G_MISS_DATE
  ,p_inv_exchange_rate             IN NUMBER     := FND_API.G_MISS_NUM
  ,p_allow_user_rate_type_flag     IN VARCHAR2   := 'N'
  ,p_receiver_task_id              IN NUMBER     := FND_API.G_MISS_NUM
  ,x_bill_another_project_flag     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
   l_return_status                 VARCHAR2(1);
   l_error_msg_code                VARCHAR2(250);
   l_bill_another_project_flag     VARCHAR2(1);
BEGIN
   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_CUSTOMERS_CONTACTS_PVT.Validate_Customer BEGIN');
   end if;
--dbms_output.put_line('value of p_action'||p_action);
--dbms_output.put_line('value of p_customer_id'||p_customer_id);

   if p_action = 'INSERT' then
      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_DUPLICATE_CUSTOMER
      ( p_project_id     => p_project_id
       ,p_customer_id    => p_customer_id
       ,x_return_status  => l_return_status
       ,x_error_msg_code => l_error_msg_code);
       --dbms_output.put_line('Value of l_return_status 1'||l_return_status);
      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name       => l_error_msg_code);
      end if;
   end if;

   if ((p_action = 'INSERT') OR (p_action = 'UPDATE')) then

       --dbms_output.put_line('Before Calling CHECK_CONTRIBUTION_PERCENTAGE');

      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_CONTRIBUTION_PERCENTAGE
      ( p_customer_bill_split => p_customer_bill_split
       ,x_return_status       => l_return_status
       ,x_error_msg_code      => l_error_msg_code);
       --dbms_output.put_line('Value of l_return_status 2'||l_return_status||'det'||l_error_msg_code);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name       => l_error_msg_code);
      end if;

     IF (p_calling_module <> 'FORM')  AND  (p_calling_module <> 'AMG') -- Added by aditi for tracking Bug     --bug 2838822
      THEN
      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_CONTRIBUTION_TOTAL
      ( p_customer_bill_split => p_customer_bill_split
       ,p_project_id          => p_project_id
       ,p_customer_id         => p_customer_id
       ,x_return_status       => l_return_status
       ,x_error_msg_code      => l_error_msg_code);
       --dbms_output.put_line('Value of l_return_status 3'||l_return_status);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name       => l_error_msg_code);
      end if;
   END IF;
   --dbms_output.put_line('value of p_bill_to_address_id'||p_bill_to_address_id);
   --dbms_output.put_line('value of p_ship_to_address_id'||p_ship_to_address_id);

      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_BILL_WORK_SITES_REQUIRED
      ( p_customer_bill_split => p_customer_bill_split
       ,p_bill_to_address_id  => p_bill_to_address_id
       ,p_ship_to_address_id  => p_ship_to_address_id
       ,x_return_status       => l_return_status
       ,x_error_msg_code      => l_error_msg_code);
              --dbms_output.put_line('Value of l_return_status 4'||l_return_status);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name       => l_error_msg_code);
      end if;

      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_CC_PRVDR_FLAG_CONTRIB
      ( p_project_id          => p_project_id
       ,p_customer_id         => p_customer_id
       ,p_customer_bill_split => p_customer_bill_split
       ,p_action              => p_action
       ,x_return_status       => l_return_status
       ,x_error_msg_code      => l_error_msg_code);
              --dbms_output.put_line('Value of l_return_status 5'||l_return_status);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name       => l_error_msg_code);
      end if;
       --dbms_output.put_line('Value of l_bill_another_project_flag outside loop'||l_bill_another_project_flag);
      IF p_calling_module <> 'AMG' THEN -- Added by aditi for tracking Bug 4153629
      /* These checks are performed in Update_project, hence need not be done here again */
      --dbms_output.put_line('Value of l_bill_another_project_flag'||l_bill_another_project_flag);
      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_RECEIVER_PROJ_ENTERABLE
      ( p_project_id                => p_project_id
       ,p_customer_id               => p_customer_id
       ,p_receiver_task_id          => p_receiver_task_id
       ,x_bill_another_project_flag => l_bill_another_project_flag
       ,x_return_status             => l_return_status
       ,x_error_msg_code            => l_error_msg_code);
              --dbms_output.put_line('Value of l_return_status 6'||l_return_status);
      END IF; -- Tracking Bug 4153629
       --dbms_output.put_line('Value of l_bill_another_project_flag outside loop'||l_bill_another_project_flag);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name       => l_error_msg_code);
      end if;
      x_bill_another_project_flag := l_bill_another_project_flag;

      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_INVOICE_CURRENCY_INFO
      ( p_project_id                => p_project_id
       ,p_inv_currency_code         => p_inv_currency_code
       ,p_inv_rate_type             => p_inv_rate_type
       ,p_inv_rate_date             => p_inv_rate_date
       ,p_inv_exchange_rate         => p_inv_exchange_rate
       ,p_allow_user_rate_type_flag => p_allow_user_rate_type_flag
       ,x_return_status             => l_return_status
       ,x_error_msg_code            => l_error_msg_code);
              --dbms_output.put_line('Value of l_return_status 7'||l_return_status);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name       => l_error_msg_code);
      end if;
   end if;

   if p_action = 'UPDATE' then
      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_UPDATE_CONTRIB_ALLOWED
      ( p_project_id          => p_project_id
       ,p_customer_id         => p_customer_id
       ,p_customer_bill_split => p_customer_bill_split
       ,x_return_status       => l_return_status
       ,x_error_msg_code      => l_error_msg_code);
              --dbms_output.put_line('Value of l_return_status 8'||l_return_status);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name       => l_error_msg_code);
      end if;
   end if;

   if p_action = 'DELETE' then
      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_DELETE_CUSTOMER_ALLOWED
      ( p_project_id          => p_project_id
       ,p_customer_id         => p_customer_id
       ,x_return_status       => l_return_status
       ,x_error_msg_code      => l_error_msg_code);
              --dbms_output.put_line('Value of l_return_status 9'||l_return_status);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name       => l_error_msg_code);
      end if;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_CUSTOMERS_CONTACTS_PVT.Validate_Customer END');
   end if;

EXCEPTION
   when others then
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CUSTOMERS_CONTACTS_PVT',
                              p_procedure_name => 'Validate_Customer',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END VALIDATE_CUSTOMER;


-- API name     : Validate_Contact
-- Type         : Private
-- Pre-reqs     : None.
-- Parameters           :
-- p_validation_level              IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module                IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode                    IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count                 IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_action                        IN VARCHAR2   Required
-- p_project_id                    IN NUMBER     Required
-- p_customer_id                   IN NUMBER     Required
-- p_contact_id                    IN NUMBER     Required
-- p_project_contact_type_code     IN VARCHAR2   Required
-- p_rowid                         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR

PROCEDURE VALIDATE_CONTACT
(  p_validation_level              IN NUMBER     := FND_API.G_VALID_LEVEL_FULL
  ,p_calling_module                IN VARCHAR2   := 'SELF_SERVICE'
  ,p_debug_mode                    IN VARCHAR2   := 'N'
  ,p_max_msg_count                 IN NUMBER     := FND_API.G_MISS_NUM
  ,p_action                        IN VARCHAR2
  ,p_project_id                    IN NUMBER
  ,p_customer_id                   IN NUMBER
  ,p_contact_id                    IN NUMBER
  ,p_project_contact_type_code     IN VARCHAR2
  ,p_rowid                         IN VARCHAR2   := FND_API.G_MISS_CHAR
)
IS
   l_return_status                 VARCHAR2(1);
   l_error_msg_code                VARCHAR2(250);
   l_rowid                         VARCHAR2(250);

   CURSOR C(c_project_id NUMBER, c_customer_id NUMBER, c_contact_id NUMBER,
            c_project_contact_type_code VARCHAR2) IS
      SELECT rowid
      FROM pa_project_contacts
      WHERE project_id = c_project_id AND
            customer_id = c_customer_id AND
            contact_id = c_contact_id AND
            project_contact_type_code = c_project_contact_type_code;
BEGIN
   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_CUSTOMERS_CONTACTS_PVT.Validate_Contact BEGIN');
   end if;

   if ((p_action = 'INSERT') OR (p_action = 'UPDATE')) then
      if p_action = 'UPDATE' then
         if (p_rowid = FND_API.G_MISS_CHAR) OR (p_rowid is NULL) then
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         end if;

         open C(p_project_id, p_customer_id, p_contact_id, p_project_contact_type_code);
         fetch C into l_rowid;
         close C;

         if p_rowid = l_rowid then
            return;
         end if;
      end if;

      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_DUPLICATE_CONTACT
      ( p_project_id                => p_project_id
       ,p_customer_id               => p_customer_id
       ,p_contact_id                => p_contact_id
       ,p_project_contact_type_code => p_project_contact_type_code
       ,x_return_status             => l_return_status
       ,x_error_msg_code            => l_error_msg_code);
      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name       => l_error_msg_code);
      end if;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_CUSTOMERS_CONTACTS_PVT.Validate_Contact END');
   end if;

EXCEPTION
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CUSTOMERS_CONTACTS_PVT',
                              p_procedure_name => 'Validate_Contact',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
   when others then
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CUSTOMERS_CONTACTS_PVT',
                              p_procedure_name => 'Validate_Contact',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END VALIDATE_CONTACT;

END PA_CUSTOMERS_CONTACTS_PVT;

/
