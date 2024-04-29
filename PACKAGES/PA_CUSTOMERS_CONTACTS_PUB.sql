--------------------------------------------------------
--  DDL for Package PA_CUSTOMERS_CONTACTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CUSTOMERS_CONTACTS_PUB" AUTHID CURRENT_USER AS
/* $Header: PARPCCPS.pls 120.2 2005/10/27 04:20:33 msachan noship $ */


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
-- p_bill_to_customer_id            IN NUMBER    Optional Default = NULL                /* For Bug 2731449 */
-- p_ship_to_customer_id            IN NUMBER    Optional Default = NULL                /* For Bug 2731449 */
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
  ,p_bill_to_customer_id           IN NUMBER     := FND_API.G_MISS_NUM       /* For Bug 2731449 */
  ,p_ship_to_customer_id           IN NUMBER     := FND_API.G_MISS_NUM       /* For Bug 2731449 */
  ,p_bill_to_customer_name         IN VARCHAR2   := FND_API.G_MISS_CHAR      /* For Bug 2965841 */
  ,p_bill_to_customer_number       IN VARCHAR2   := FND_API.G_MISS_CHAR      /* For Bug 2965841 */
  ,p_ship_to_customer_name         IN VARCHAR2   := FND_API.G_MISS_CHAR      /* For Bug 2965841 */
  ,p_ship_to_customer_number       IN VARCHAR2   := FND_API.G_MISS_CHAR      /* For Bug 2965841 */
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
  ,x_msg_data                      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,p_project_party_id              IN NUMBER DEFAULT NULL
--Billing setup related changes for FP_M development. Tracking bug 3279981
  ,p_Default_Top_Task_Cust_Flag    IN VARCHAR2
  ,p_en_top_task_cust_flag         IN VARCHAR2   := 'N'
);


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
-- p_bill_to_customer_id            IN NUMBER    Optional Default = NULL                /* For Bug 2731449 */
-- p_ship_to_customer_id            IN NUMBER    Optional Default = NULL                /* For Bug 2731449 */
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
-- p_bill_another_project_flag     IN VARCHAR2   Optional Default = 'N' -- Added By Aditi for tracking bug 4153629
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
);


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
);


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
  ,p_bill_ship_customer_id         IN NUMBER                            /* For Bug 2731449 */
  ,p_contact_id                    IN NUMBER     := FND_API.G_MISS_NUM
  ,p_contact_name                  IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_project_contact_type_code     IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_project_contact_type_name     IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


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
);


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
);

/*   For Bug 2731449 created this api which gets all the contacts of passed contact type for customer passed and deletes them*/
--
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
( p_api_version                    IN NUMBER     := 1.0
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
);

END PA_CUSTOMERS_CONTACTS_PUB;

 

/
