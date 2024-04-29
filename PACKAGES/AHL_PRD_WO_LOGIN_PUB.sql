--------------------------------------------------------
--  DDL for Package AHL_PRD_WO_LOGIN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PRD_WO_LOGIN_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPLGNS.pls 120.1 2006/09/21 11:34:04 sracha noship $ */
/*#
 * Package containing APIs to allow a user to login or logout out of a
 * work order, operation or a operation-resource.
 * @rep:scope public
 * @rep:product AHL
 * @rep:displayname Work Order Login and Logout
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AHL_MAINT_WORKORDER
 */

---------------------------------------------------------------------------------------------

-- Start of Comments --
--
--  Procedure name : Workorder_Login
--  Type           : Public
--  Description    : This API logs a technician into a workorder or operation or operation-resource. If the
--                   operation sequence number passed to the API is null, then the login
--                   is done at the workorder level; if the resource sequence or resource ID is not
--                   passed but the workorder and operation is passed, then the login is at operation level.
--                   If resource details are passed, then login is at the operation and resource level.
--  Parameters     :
--
--  Standard IN  Parameters :
--      p_api_version           IN      NUMBER          Required
--      p_init_msg_list         IN      VARCHAR2        Required, default FND_API.G_FALSE
--      p_commit                IN      VARCHAR2        Required, default FND_API.G_FALSE
--      p_validation_level      IN      NUMBER          Required, default FND_API.G_VALID_LEVEL_FULL
--      p_default               IN      VARCHAR2        Required, default FND_API.G_FALSE
--      p_module_type           IN      VARCHAR2        Required, default NULL

--  Standard OUT Parameters :
--      x_return_status         OUT     VARCHAR2        Required
--      x_msg_count             OUT     NUMBER          Required
--      x_msg_data              OUT     VARCHAR2        Required
--
--  Procedure Parameters :
--      p_employee_num          --      Employee Number (Optional)
--      p_employee_id           --      Employee ID     (Optional. If both Employee Num and Employee ID are
--                                                       not passed, then employee is derived based on the
--                                                       logged in user.)
--      p_workorder_name        --      Workorder Name  (Optional)
--      p_org_code              --      Organization Code (Mandatory only if workorder_name is input. Used to derive
--                                                         workorder_id if workorder_name is input.)
--      p_workorder_id          --      Workorder ID    (mandatory of workorder name/Org not provided).
--      p_operation_seq_num     --      WO Operation seq (optional)
--      p_resource_seq_num      --      WO Operation resource seq (optional)
--      p_resource_id           --      WO Operation resource ID  (optional)
--
--  Version :
--      Initial Version         1.0
--
--
--
--
--  End of Comments  --
--
/*#
 * Use this procedure to Login an employee/user into a work order or work order-operation-resource.
 * @param p_api_version API Version Number.
 * @param p_init_msg_list Initialize the message stack, Standard API parameter, default value FND_API.G_FALSE
 * @param p_commit Parameter to decide whether to commit the transaction or not, Standard API parameter, default value FND_API.G_FALSE
 * @param p_validation_level Validation level, Standard API parameter, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_module_type For Internal use only, should always be NULL, default value NULL
 * @param x_return_status API Return status. Standard API parameter
 * @param x_msg_count API Return message count, if any. Standard API parameter
 * @param x_msg_data API Return message data, if any. Standard API parameter
 * @param p_employee_num Employee Number
 * @param p_employee_id  Employee ID
 * @param p_workorder_name Work Order name the employee wants to login into.
 * @param p_workorder_id   Work Order ID the employee wants to login into.
 * @param p_org_code       Work Order Organization Code
 * @param p_operation_seq_num  Work Order Operation Sequence-required if employee needs to login at the operation-resource level.
 * @param p_resource_seq_num  Work Order Resource Sequence-required if employee needs to login at the operation-resource level.
 * @param p_resource_id  Work Order Resource ID-optionally required if employee needs to login at the operation-resource level and p_resource_seq_num is not available.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Work Order Login
 */

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
--  Type           : Public
--  Description    : This API logs a technician out of a workorder or operation.
--                   If the operation related parameters passed to the API are null,
--                   then the logout is done at the workorder level. If the operation
--                   related parameters are not null, then the login is done at the
--                   operation and resource level.At least one of employee number
--                   or employee id should be passed to the API. If the employee id is not null
--                   then the employee number is ignored. Also, at least one of workorder id or
--                   workorder name should be passed. If the workorder id is passed, the workorder
--                   name is ignored. Similarly, at least one of resource sequence number or
--                   resource id should be passed to the API. If the resource id is passed, then
--                   the resource sequence number is ignored.
--  Parameters     :
--
--  Standard IN  Parameters :
--      p_api_version           IN      NUMBER          Required
--      p_init_msg_list         IN      VARCHAR2        Required, default FND_API.G_FALSE
--      p_commit                IN      VARCHAR2        Required, default FND_API.G_FALSE
--      p_validation_level      IN      NUMBER          Required, default FND_API.G_VALID_LEVEL_FULL
--      p_default               IN      VARCHAR2        Required, default FND_API.G_FALSE
--      p_module_type           IN      VARCHAR2        Required, default NULL

--  Standard OUT Parameters :
--      x_return_status         OUT     VARCHAR2        Required
--      x_msg_count             OUT     NUMBER          Required
--      x_msg_data              OUT     VARCHAR2        Required
--
--  Procedure Parameters :
--      p_employee_num          --      Employee Number (Optional)
--      p_employee_id           --      Employee ID     (Optional. If both Employee Num and Employee ID are
--                                                       not passed, then employee is derived based on the
--                                                       logged in user.)
--      p_workorder_name        --      Workorder Name  (Optional)
--      p_org_code              --      Organization Code (Mandatory only if workorder_name is input. Used to derive
--                                                         workorder_id if workorder_name is input.)
--      p_workorder_id          --      Workorder ID    (mandatory of workorder name/Org not provided).
--      p_operation_seq_num     --      WO Operation seq (optional)
--      p_resource_seq_num      --      WO Operation resource seq (optional)
--      p_resource_id           --      WO Operation resource ID  (optional)
--
--  Version :
--      Initial Version         1.0
--
--
--
--
--  End of Comments  --
--

/*#
 * Use this procedure to Logout an employee/user out of a work order or work order-operation-resource.
 * @param p_api_version API Version Number.
 * @param p_init_msg_list Initialize the message stack, Standard API parameter, default value FND_API.G_FALSE
 * @param p_commit Parameter to decide whether to commit the transaction or not, Standard API parameter, default value FND_API.G_FALSE
 * @param p_validation_level Validation level, Standard API parameter, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_module_type For Internal use only, should always be NULL, default value NULL
 * @param x_return_status API Return status. Standard API parameter
 * @param x_msg_count API Return message count, if any. Standard API parameter
 * @param x_msg_data API Return message data, if any. Standard API parameter
 * @param p_employee_num Employee Number
 * @param p_employee_id  Employee ID
 * @param p_workorder_name Work Order name the employee wants to login into.
 * @param p_workorder_id   Work Order ID the employee wants to login into.
 * @param p_org_code       Work Order Organization Code
 * @param p_operation_seq_num  Work Order Operation Sequence-required if employee needs to login at the operation-resource level.
 * @param p_resource_seq_num  Work Order Resource Sequence-required if employee needs to login at the operation-resource level.
 * @param p_resource_id  Work Order Resource ID-optionally required if employee needs to login at the operation-resource level and p_resource_seq_num is not available.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Work Order Logout
 */
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

END AHL_PRD_WO_LOGIN_PUB;

 

/
