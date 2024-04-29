--------------------------------------------------------
--  DDL for Package PA_CUSTOMERS_CONTACTS_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CUSTOMERS_CONTACTS_UTILS" AUTHID CURRENT_USER AS
/* $Header: PARPCCUS.pls 120.2 2007/02/06 09:54:54 dthakker ship $ */


-- API name		: Check_Customer_Name_Or_Id
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_customer_id                   IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_customer_name                 IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_check_id_flag                 IN VARCHAR2   Optional Default = 'A'
-- x_customer_id                   OUT NUMBER    Required
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required

PROCEDURE CHECK_CUSTOMER_NAME_OR_ID
(  p_customer_id                   IN NUMBER     := FND_API.G_MISS_NUM
  ,p_customer_name                 IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_check_id_flag                 IN VARCHAR2   := 'A'
  ,x_customer_id                   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


-- API name		: Check_Customer_Number_Or_Id
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_customer_id                   IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_customer_number               IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_check_id_flag                 IN VARCHAR2   Optional Default = 'A'
-- x_customer_id                   OUT NUMBER    Required
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required

PROCEDURE CHECK_CUSTOMER_NUMBER_OR_ID
(  p_customer_id                   IN NUMBER     := FND_API.G_MISS_NUM
  ,p_customer_number               IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_check_id_flag                 IN VARCHAR2   := 'A'
  ,x_customer_id                   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


-- API name		: Check_Bill_Site_Name_Or_Id
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_customer_id                   IN NUMBER     Required
-- p_bill_to_address_id            IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_bill_site_name                IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_check_id_flag                 IN VARCHAR2   Optional Default = 'A'
-- x_bill_to_address_id            OUT NUMBER    Optional
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required

PROCEDURE CHECK_BILL_SITE_NAME_OR_ID
(  p_customer_id                   IN NUMBER
  ,p_bill_to_address_id            IN NUMBER     := FND_API.G_MISS_NUM
  ,p_bill_site_name                IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_check_id_flag                 IN VARCHAR2   := 'A'
  ,x_bill_to_address_id            OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


-- API name		: Check_Work_Site_Name_Or_Id
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_customer_id                   IN NUMBER     Required
-- p_ship_to_address_id            IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_work_site_name                IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_check_id_flag                 IN VARCHAR2   Optional Default = 'A'
-- x_ship_to_address_id            OUT NUMBER    Optional
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required

PROCEDURE CHECK_WORK_SITE_NAME_OR_ID
(  p_customer_id                   IN NUMBER
  ,p_ship_to_address_id            IN NUMBER     := FND_API.G_MISS_NUM
  ,p_work_site_name                IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_check_id_flag                 IN VARCHAR2   := 'A'
  ,x_ship_to_address_id            OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

/*
-- API name		: Check_Receiver_Proj_Name_Or_Id
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_receiver_task_id              IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_receiver_project_name         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_check_id_flag                 IN VARCHAR2   Optional Default = 'A'
-- x_receiver_task_id              OUT NUMBER    Optional
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required

PROCEDURE CHECK_RECEIVER_PROJ_NAME_OR_ID
(  p_receiver_task_id              IN NUMBER     := FND_API.G_MISS_NUM
  ,p_receiver_project_name         IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_check_id_flag                 IN VARCHAR2   := 'A'
  ,x_receiver_task_id              OUT NUMBER
  ,x_return_status                 OUT VARCHAR2
  ,x_error_msg_code                OUT VARCHAR2
);
*/

-- API name		: Check_Contact_Name_Or_Id
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_customer_id                   IN NUMBER     Required
-- p_project_contact_type_code     IN VARCHAR2   Required
-- p_contact_id                    IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_contact_name                  IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_check_id_flag                 IN VARCHAR2   Optional Default = 'A'
-- x_contact_id                    OUT NUMBER    Required
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required

PROCEDURE CHECK_CONTACT_NAME_OR_ID
(  p_customer_id                   IN NUMBER
  ,p_project_contact_type_code     IN VARCHAR2
  ,p_contact_id                    IN NUMBER     := FND_API.G_MISS_NUM
  ,p_contact_name                  IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_check_id_flag                 IN VARCHAR2   := 'A'
  ,p_address_id                    IN NUMBER     := NULL -- Added for Bug 2964227
  ,x_contact_id                    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


-- API name		: Check_Contact_Typ_Name_Or_Code
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_project_contact_type_code     IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_project_contact_type_name     IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_check_id_flag                 IN VARCHAR2   Optional Default = 'A'
-- x_project_contact_type_code     OUT VARCHAR2  Required
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required

PROCEDURE CHECK_CONTACT_TYP_NAME_OR_CODE
(  p_project_contact_type_code     IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_project_contact_type_name     IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_check_id_flag                 IN VARCHAR2   := 'A'
  ,x_project_contact_type_code     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


-- API name		: Check_Duplicate_Customer
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_project_id                    IN NUMBER     Required
-- p_customer_id                   IN NUMBER     Required
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required

PROCEDURE CHECK_DUPLICATE_CUSTOMER
(  p_project_id                    IN NUMBER
  ,p_customer_id                   IN NUMBER
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


-- API name		: Check_Duplicate_Contact
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_project_id                    IN NUMBER     Required
-- p_customer_id                   IN NUMBER     Required
-- p_contact_id                    IN NUMBER     Required
-- p_project_contact_type_code     IN VARCHAR2   Required
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required

PROCEDURE CHECK_DUPLICATE_CONTACT
(  p_project_id                    IN NUMBER
  ,p_customer_id                   IN NUMBER
  ,p_contact_id                    IN NUMBER
  ,p_project_contact_type_code     IN VARCHAR2
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


-- API name		: Check_Contribution_Percentage
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_customer_bill_split           IN NUMBER     Required
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required

PROCEDURE CHECK_CONTRIBUTION_PERCENTAGE
(  p_customer_bill_split           IN NUMBER
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


-- API name		: Check_Contribution_Total
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_customer_bill_split           IN NUMBER     Required
-- p_customer_id                   IN NUMBER     Required
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required

PROCEDURE CHECK_CONTRIBUTION_TOTAL
(  p_customer_bill_split           IN NUMBER
  ,p_project_id                    IN NUMBER
  ,p_customer_id                   IN NUMBER
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


-- API name		: Check_Bill_Work_Sites_Required
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_customer_bill_split           IN NUMBER     Required
-- p_bill_to_address_id            IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_ship_to_address_id            IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required

PROCEDURE CHECK_BILL_WORK_SITES_REQUIRED
(  p_customer_bill_split           IN NUMBER
  ,p_bill_to_address_id            IN NUMBER     := FND_API.G_MISS_NUM
  ,p_ship_to_address_id            IN NUMBER     := FND_API.G_MISS_NUM
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


-- API name		: Check_Cc_Prvdr_Flag_Contrib
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_project_id                    IN NUMBER     Required
-- p_customer_id                   IN NUMBER     Required
-- p_customer_bill_split           IN NUMBER     Required
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required

PROCEDURE CHECK_CC_PRVDR_FLAG_CONTRIB
(  p_project_id                    IN NUMBER
  ,p_customer_id                   IN NUMBER
  ,p_customer_bill_split           IN NUMBER
  ,p_action                        IN VARCHAR2
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


-- API name		: Check_Receiver_Proj_Enterable
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_project_id                    IN NUMBER     Required
-- p_customer_id                   IN NUMBER     Required
-- p_receiver_task_id              IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- x_bill_another_project_flag     OUT VARCHAR2  Required
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required

PROCEDURE CHECK_RECEIVER_PROJ_ENTERABLE
(  p_project_id                    IN NUMBER
  ,p_customer_id                   IN NUMBER
  ,p_receiver_task_id              IN NUMBER     := FND_API.G_MISS_NUM
  ,x_bill_another_project_flag     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


-- API name		: Check_Invoice_Currency_Info
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_project_id                    IN NUMBER     Required
-- p_inv_currency_code             IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_inv_rate_type                 IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_inv_rate_date                 IN DATE       Optional Default = FND_API.G_MISS_DATE
-- p_inv_exchange_rate             IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_allow_user_rate_type_flag     IN VARCHAR2   Required Default = 'N'
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required

PROCEDURE CHECK_INVOICE_CURRENCY_INFO
(  p_project_id                    IN NUMBER
  ,p_inv_currency_code             IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_inv_rate_type                 IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_inv_rate_date                 IN DATE       := FND_API.G_MISS_DATE
  ,p_inv_exchange_rate             IN NUMBER     := FND_API.G_MISS_NUM
  ,p_allow_user_rate_type_flag     IN VARCHAR2   := 'N'
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


-- API name		: Check_Update_Contrib_Allowed
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_project_id                    IN NUMBER     Required
-- p_customer_id                   IN NUMBER     Required
-- p_customer_bill_split           IN NUMBER     Required
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required

PROCEDURE CHECK_UPDATE_CONTRIB_ALLOWED
(  p_project_id                    IN NUMBER
  ,p_customer_id                   IN NUMBER
  ,p_customer_bill_split           IN NUMBER
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


-- API name		: Check_Delete_Customer_Allowed
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_project_id                    IN NUMBER     Required
-- p_customer_id                   IN NUMBER     Required
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required

PROCEDURE CHECK_DELETE_CUSTOMER_ALLOWED
(  p_project_id                    IN NUMBER
  ,p_customer_id                   IN NUMBER
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


-- API name		: Get_Org_Id
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           : None.
-- Return Type          : Number
FUNCTION GET_ORG_ID
RETURN NUMBER;


-- API name		: Check_Customer_Name_And_Number
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_customer_name                 IN VARCHAR2   Required
-- p_customer_number               IN VARCHAR2   Required
-- x_customer_id                   OUT NUMBER    Required
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required

PROCEDURE CHECK_CUSTOMER_NAME_AND_NUMBER
(  p_customer_name                 IN VARCHAR2
  ,p_customer_number               IN VARCHAR2
  ,x_customer_id                   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- API name		: Get_Contribution_Total
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           : Project_Id
-- Return Type          : Number
FUNCTION GET_CONTRIBUTION_TOTAL (p_project_id IN NUMBER)
RETURN NUMBER;


--sunkalya federal changes Bug#5511353
-- Procedure            : Get_Highest_Contr_Fed_Cust
-- Type                 : PRIVATE
-- Purpose              : Gets the highest contribution federal customer. If contribution is same,
--                        then sorts on name and if names are also same, then sorts on
--                        customer id. This API is included as a part of
--			  federal changes.
-- Note                 :
-- Assumptions          :
-- Parameters                   Type          Required    Description and Purpose
-- ---------------------------  ------        --------    --------------------------------------------------------
-- p_project_id                 NUMBER           Y        Project ID for which highest contribution customer is
--                                                        to be returned
-- x_highst_contr_cust_id       NUMBER           N        Customer ID of the highest contribution customer

PROCEDURE Get_Highest_Contr_Fed_Cust(
          p_api_version           IN   NUMBER   := 1.0
        , p_init_msg_list         IN   VARCHAR2 := FND_API.G_TRUE
        , p_commit                IN   VARCHAR2 := FND_API.G_FALSE
        , p_validate_only         IN   VARCHAR2 := FND_API.G_TRUE
        , p_validation_level      IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
        , p_calling_module        IN   VARCHAR2 := 'SELF_SERVICE'
        , p_debug_mode            IN   VARCHAR2 := 'N'
        , p_project_id            IN   NUMBER
        , x_highst_contr_cust_id  OUT NOCOPY NUMBER
        , x_return_status         OUT  NOCOPY VARCHAR2
        , x_msg_count             OUT  NOCOPY NUMBER
        , x_msg_data              OUT  NOCOPY VARCHAR2
        );

END PA_CUSTOMERS_CONTACTS_UTILS;

/
