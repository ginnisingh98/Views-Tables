--------------------------------------------------------
--  DDL for Package PA_CUSTOMER_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CUSTOMER_INFO" AUTHID CURRENT_USER as
-- $Header: PAXCSINS.pls 120.4 2006/02/13 22:15:59 sunkalya noship $

--
--  PROCEDURE
--              Get_Customer_Info
--

Procedure Get_Customer_Info
                   (X_project_id          IN Number:=Null,
                    X_Customer_Id         In Number,
		    X_Bill_To_Customer_Id In Out NOCOPY Number, /* For Bug 2731449 */ --File.Sql.39 bug 4440895
		    X_Ship_To_Customer_Id In Out NOCOPY Number, /* For Bug 2731449 */ --File.Sql.39 bug 4440895
                    X_Bill_To_Address_Id  In Out NOCOPY Number, -- Changed from 'Out' to 'In Out' parameter for Bug 3911782 --File.Sql.39 bug 4440895
                    X_Ship_To_Address_Id  In Out NOCOPY Number, -- Changed from 'Out' to 'In Out' parameter for Bug 3911782 --File.Sql.39 bug 4440895
                    X_Bill_To_Contact_Id  In Out NOCOPY Number, --File.Sql.39 bug 4440895  -- Changed from 'Out' to 'In Out' parameter aditi for tracking bug
                    X_Ship_To_Contact_Id  In Out NOCOPY Number, --File.Sql.39 bug 4440895  -- Changed from 'Out' to 'In Out' parameter aditi for tracking bug
                    X_Err_Code            In Out NOCOPY Number, --File.Sql.39 bug 4440895
                    X_Err_Stage           In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                    X_Err_Stack           In Out NOCOPY Varchar2 , --File.Sql.39 bug 4440895
                    p_quick_entry_flag    In Varchar2 := 'Y',      -- Bug 2984536
                    p_calling_module      in varchar2 := NULL   --Bug#4770535 for contacts validation.
                    ) ;

--  PROCEDURE
--              Get_Customer_Info
--
Procedure Create_Customer_Contacts
                  ( X_Project_Id                  In  Number,
                    X_Customer_Id                 In  Number,
		    X_Project_Relation_Code       In  Varchar2,
                    X_Customer_Bill_Split         In  Number,
		    X_Bill_To_Customer_Id         In Number := NULL ,   /* For Bug 2731449 */
		    X_Ship_To_Customer_Id         In Number := NULL ,   /* For Bug 2731449 */
                    X_Bill_To_Address_Id          In  Number,
                    X_Ship_To_Address_Id          In  Number,
                    X_Bill_To_Contact_Id          In  Number,
                    X_Ship_To_Contact_Id          In  Number,
                    X_Inv_Currency_Code           In  Varchar2,
                    X_Inv_Rate_Type               In  Varchar2,
                    X_Inv_Rate_Date               In  Date,
                    X_Inv_Exchange_Rate           In Number,
                    X_Allow_Inv_Rate_Type_Fg      In Varchar2,
                    X_Bill_Another_Project_Fg     In Varchar2,
                    X_Receiver_Task_Id            In Number,
                    P_default_top_task_customer   In pa_project_customers.DEFAULT_TOP_TASK_CUST_FLAG%TYPE  default 'N',
                    X_User                        In  Number,
                    X_Login                       In  Number,
                    X_Err_Code                    In Out NOCOPY Number, --File.Sql.39 bug 4440895
                    X_Err_Stage                   In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                    X_Err_Stack                   In Out NOCOPY Varchar2 ); --File.Sql.39 bug 4440895

-- API name                      : Is_Address_Valid
-- Type                          : Function
-- Pre-reqs                      : None
-- Return Value                  : 'Y', 'N'
-- Prameters
-- l_site_use_code IN VARCHAR2
-- l_Customer_Id IN NUMBER
--  l_Address_Id IN NUMBER
--  History
--
--  12-OCT-2004  adarora             -Created
--
--  Notes: This api is called from GET_CUSTOMER_INFO to validate bill_to_address_id and ship_to_address_id

FUNCTION Is_Address_Valid(l_site_use_code IN VARCHAR2 ,
                          l_Customer_Id IN NUMBER,
			  l_Address_Id IN NUMBER) RETURN VARCHAR2;

-- API name                      : Is_Contact_Valid
-- Type                          : Function
-- Pre-reqs                      : None
-- Return Value                  : 'Y', 'N'
-- Prameters
-- l_site_use_code IN VARCHAR2
-- l_Customer_Id IN NUMBER
-- l_Address_Id IN NUMBER
-- l_Contact_Id IN NUMBER
--  History
--
--  12-JUN-2005  adarora             -Created
--
--  Notes: This api is called from GET_CUSTOMER_INFO to validate bill_to_contact_id and ship_to_contact_id

FUNCTION Is_Contact_Valid(l_site_use_code IN VARCHAR2 ,
                          l_Customer_Id IN NUMBER,
			  l_Address_Id IN NUMBER,
			  l_Contact_Id IN NUMBER) RETURN VARCHAR2;

-- API name                      : revenue_accrued_or_billed
-- Type                          : Function
-- Pre-reqs                      : None
-- Return Value                  : True, False
-- Prameters
-- l_Project_Id In  Number
--  History
--
--  12-JUN-2005  adarora             -Created
--
--  Notes: This api is called from UPDATE_PROJECT to check if customer_bill_split is updateable or nor
--  depending upon whether any invoices or revenues have been chanrged against the passed project.


 Function revenue_accrued_or_billed( p_project_Id In  Number)
 return boolean ;

-- API name                      : check_proj_tot_contribution
-- Type                          : Function
-- Pre-reqs                      : None
-- Return Value                  : Number
-- Prameters
-- l_Project_Id In  Number
--  History
--
--  12-JUN-2005  adarora             -Created
--
--  Notes: This api is called from UPDATE_PROJECT to compute the net customer_bill_split
--  for a contract project. It should not exceed 100. if it does, then an error is thrown.

Function check_proj_tot_contribution  ( p_project_Id In  Number, x_valid_proj_flag OUT NOCOPY BOOLEAN )
                                                               -- File.sql.39 Bug 4633405 (For new API)
return number;

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
--  History
--
--  14-SEP-2005  adarora             -Created
--
--  Notes: This api is called from UPDATE_PROJECT to check if the project and task can be specified
--   as receiver project and task for the customer passed.

PROCEDURE CHECK_RECEIVER_PROJ_ENTERABLE
(  p_project_id                    IN NUMBER
  ,p_customer_id                   IN NUMBER
  ,p_receiver_task_id              IN NUMBER     := FND_API.G_MISS_NUM
  ,x_bill_another_project_flag     IN OUT NOCOPY VARCHAR2  -- File.sql.39 Bug 4633405 (For new API)
  ,x_return_status                 OUT NOCOPY VARCHAR2     -- File.sql.39 Bug 4633405 (For new API)
  ,x_error_msg_code                OUT NOCOPY VARCHAR2     -- File.sql.39 Bug 4633405 (For new API)
);

end PA_CUSTOMER_INFO ;

 

/
