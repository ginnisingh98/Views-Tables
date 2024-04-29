--------------------------------------------------------
--  DDL for Package AHL_PRD_WO_LOGIN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PRD_WO_LOGIN_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVLGNS.pls 120.1.12010000.2 2009/04/21 01:22:57 sikumar ship $ */



TYPE WO_REC_TYPE IS RECORD
(
  workorder_id      NUMBER,
  is_login_allowed VARCHAR2(1)
);

TYPE WO_TBL_TYPE IS TABLE OF WO_REC_TYPE INDEX BY BINARY_INTEGER;

TYPE OP_RES_REC_TYPE IS RECORD
(
  operation_seq_num NUMBER,
  resource_id      NUMBER,
  is_login_allowed VARCHAR2(1)
);

TYPE OP_RES_TBL_TYPE IS TABLE OF OP_RES_REC_TYPE INDEX BY BINARY_INTEGER;

----------------------------------------------------------------------------------------------------
--Wrapper procedure used by Technician workbench, Transit Technician and Data Clerk Search Wo UIs
--This procedure returns whether login is allowed for all all operations of a workorder passed.
----------------------------------------------------------------------------------------------------

PROCEDURE get_wo_login_info(
                p_function_name         IN VARCHAR2,
                p_employee_id           IN NUMBER,
                p_x_wos                 IN OUT NOCOPY  WO_TBL_TYPE
);

----------------------------------------------------------------------------------------------------
--Wrapper procedure used by Technician workbench, Transit Technician and Data Clerk Search Wo UIs
--This procedure returns whether login is allowed for all all operations of a workorder passed.
----------------------------------------------------------------------------------------------------

PROCEDURE get_op_res_login_info(
                p_workorder_id          IN NUMBER,
                p_employee_id           IN NUMBER,
                p_function_name         IN VARCHAR2,
                p_x_op_res              IN OUT NOCOPY  OP_RES_TBL_TYPE
);

---------------------------------------------------------------------------------------------

-- Start of Comments --
--  Function name : Is_Login_Allowed
--
--  Parameters  :
--                  p_employee_id    --  Optional Input Employee Id.
--                  p_wip_entity_id   --  Mandatory Workorder ID.
--                  p_operation_seq_num -- Mandatory Operation Seq Number
--                  p_resource_seq_num  -- Mandatory Resource ID.
--                  p_fnd_function_name  -- Mandatory fnd_function to identify user role.
--
--  Description   : This function returns the number of hours transacted by an employee
--                  for a particular resource requirement and an operation if the user is
--                  has a role of a technician or line maintenance technician. It returns the
--                  number of hours transacted by all employees for a resource requirement
--                  within an operation if the user is a data clerk.
--


FUNCTION Is_Login_Allowed(p_employee_id       IN NUMBER := NULL,
                          p_workorder_id      IN NUMBER,
                          p_operation_seq_num IN NUMBER := NULL,
                          p_resource_seq_num  IN NUMBER := NULL,
                          p_resource_id       IN NUMBER := NULL,
                          p_fnd_function_name IN VARCHAR2)
RETURN VARCHAR2;
---------------------------------------------------------------------------------------------

-- Start of Comments --
--  Procedure name : Workorder_Login
--
--  Parameters  :
--
--
--  Description : This API logs a technician onto a workorder or operation. If the
--                operation sequence number passed to the API is null, then the login
--                is done at the workorder level; if the resource sequence or resource ID is not
--                passed but the workorder and operation is passed, then the login is at operation level.
--                If resource details are passed, then login is at the operation and resource level.
--
--
PROCEDURE Workorder_Login(p_api_version       IN         NUMBER,
                          p_init_msg_list     IN         VARCHAR2 := FND_API.G_FALSE,
                          p_commit            IN         VARCHAR2 := FND_API.G_FALSE,
                          p_validation_level  IN         NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                          p_module_type       IN         VARCHAR2 := NULL,
                          x_return_status     OUT NOCOPY VARCHAR2,
                          x_msg_count         OUT NOCOPY NUMBER,
                          x_msg_data          OUT NOCOPY VARCHAR2,
                          p_employee_num      IN         NUMBER   := NULL,
                          p_employee_id       IN         NUMBER   := NULL,
                          p_workorder_name    IN         VARCHAR2 := NULL,
                          p_workorder_id      IN         NUMBER   := NULL,
                          p_org_code          IN         VARCHAR2 := NULL,
                          p_operation_seq_num IN         NUMBER   := NULL,
                          p_resource_seq_num  IN         NUMBER   := NULL,
                          p_resource_id       IN         NUMBER   := NULL);

---------------------------------------------------------------------------------------------

-- Start of Comments --
--  Procedure name : Workorder_Logout
--
--  Parameters  :
--
--
--  Description   : This API logs a technician out of a workorder or operation.
--                  If the operation related parameters passed to the API are null,
--                  then the logout is done at the workorder level. If the operation
--                  related parameters are not null, then the login is done at the
--                  operation and resource level.At least one of employee number
--                  or employee id should be passed to the API. If the employee id is not null
--                  then the employee number is ignored. Also, at least one of workorder id or
--                  workorder name should be passed. If the workorder id is passed, the workorder
--                  name is ignored. Similarly, at least one of resource sequence number or
--                  resource id should be passed to the API. If the resource id is passed, then
--                  the resource sequence number is ignored.
--
--


PROCEDURE Workorder_Logout( p_api_version        IN         NUMBER,
                            p_init_msg_list      IN         VARCHAR2 := FND_API.G_FALSE,
                            p_commit             IN         VARCHAR2 := FND_API.G_FALSE,
                            p_validation_level   IN         NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                            p_module_type        IN         VARCHAR2 := NULL,
                            x_return_status      OUT NOCOPY VARCHAR2,
                            x_msg_count          OUT NOCOPY NUMBER,
                            x_msg_data           OUT NOCOPY VARCHAR2,
                            p_employee_num       IN         NUMBER   := NULL,
                            p_employee_id        IN         NUMBER   := NULL,
                            p_workorder_name     IN         VARCHAR2 := NULL,
                            p_workorder_id       IN         NUMBER   := NULL,
                            p_org_code           IN         VARCHAR2 := NULL,
                            p_operation_seq_num  IN         NUMBER   := NULL,
                            p_resource_seq_num   IN         NUMBER   := NULL,
                            p_resource_id        IN         NUMBER   := NULL);

---------------------------------------------------------------------------------------------


-- Start of Comments --
--  Function name : Get_User_Role
--
--  Parameters  :
--                  None
--
--  Description   : This function is used to retrieve the role associated with the current
--                  user - it could be a Production Tech, Production Data Clerk or
--                  Production Transit Tech.
--


FUNCTION Get_User_Role
RETURN VARCHAR2;
---------------------------------------------------------------------------------------------


-- Start of Comments --
--  Function name : Get_Employee_ID
--
--  Parameters  :
--                  p_employee_number
--
--  Description   : This function is used to retrieve the employee ID given an employee number.
--                  If employee number is not passed in, then the logged in user's employee ID
--                  is returned. This function is a helper function for other APIs.
--
--

FUNCTION Get_Employee_ID (p_Employee_Number  IN  VARCHAR2 := NULL)
RETURN VARCHAR2;
---------------------------------------------------------------------------------------------


-- Start of Comments --
--  Function name : Get_Current_Emp_Login
--
--  Parameters  :
--                  p_employee_id    -  Optional Input Employee Id.
--                  x_return_status  -- Procedure return status.
--                  x_workorder_id   -- Workorder ID employee is logged into.
--                                      only valid id Employee logged into workorder.
--                  x_workorder_number -- Workorder Name.
--                  x_operation_seq_num -- Operation Seq Number
--                                      -- Only valid if Employee logged into an Operation-Resource.
--                  x_resource_id       -- Resource sequence employee is logged into.
--                  x_resource_seq_num  -- Resource Sequence number.
--
--  Description   : This procedure returns the workorder or operation the input employee ID
--                  is currently logged into. If input employee ID is null, then the values are
--                  retrieved for the currently logged in employee.
--


PROCEDURE Get_Current_Emp_Login (x_return_status     OUT NOCOPY VARCHAR2,
                                 x_msg_data          OUT NOCOPY VARCHAR2,
                                 x_msg_count         OUT NOCOPY NUMBER,
                                 p_employee_id       IN NUMBER := NULL,
                                 x_employee_name     OUT NOCOPY VARCHAR2,
                                 x_workorder_id      OUT NOCOPY NUMBER,
                                 x_workorder_number  OUT NOCOPY VARCHAR2,
                                 x_operation_seq_num OUT NOCOPY NUMBER,
                                 x_resource_id       OUT NOCOPY NUMBER,
                                 x_resource_seq_num  OUT NOCOPY NUMBER);


---------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------

-- Start of Comments --
--  Function name : Is_Login_Enabled
--
--  Parameters  :
--                  p_employee_id    --  Optional Input Employee Id.
--                  p_wip_entity_id   --  Mandatory Workorder ID.
--                  p_operation_seq_num -- Operation Seq Number
--                  p_resource_seq_num  -- Resource ID.
--                  p_fnd_function_name  -- fnd_function to identify user role.
--
--  Description   : This function returns whether user is allowed to login into a
--                  wrokorder/operation-resource
--


FUNCTION Is_Login_Enabled(p_employee_id       IN NUMBER := NULL,
                          p_workorder_id      IN NUMBER,
                          p_operation_seq_num IN NUMBER := NULL,
                          p_resource_seq_num  IN NUMBER := NULL,
                          p_resource_id       IN NUMBER := NULL,
                          p_fnd_function_name IN VARCHAR2 := NULL)
RETURN VARCHAR2;

---------------------------------------------------------------------------------------------

-- Start of Comments --
--  Function name : Is_Logout_Enabled
--
--  Parameters  :
--                  p_employee_id    --  Optional Input Employee Id.
--                  p_wip_entity_id   --  Mandatory Workorder ID.
--                  p_operation_seq_num -- Operation Seq Number
--                  p_resource_seq_num  -- Resource ID.
--                  p_fnd_function_name  -- fnd_function to identify user role.
--
--  Description   : This function returns whether user is allowed to logout into a
--                  wrokorder/operation-resource
--


FUNCTION Is_Logout_Enabled(p_employee_id       IN NUMBER := NULL,
                          p_workorder_id      IN NUMBER,
                          p_operation_seq_num IN NUMBER := NULL,
                          p_resource_seq_num  IN NUMBER := NULL,
                          p_resource_id       IN NUMBER := NULL,
                          p_fnd_function_name IN VARCHAR2 := NULL)
RETURN VARCHAR2;


END AHL_PRD_WO_LOGIN_PVT;

/
