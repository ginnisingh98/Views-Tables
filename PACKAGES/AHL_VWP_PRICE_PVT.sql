--------------------------------------------------------
--  DDL for Package AHL_VWP_PRICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_VWP_PRICE_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVVPRS.pls 115.0 2003/10/17 17:57:28 yazhou noship $ */
-----------------------------------------------------------
-- PACKAGE
--    AHL_VWP_PRICE_PVT
--
-- PURPOSE
--    This package specification is a Private API for managing
--    APIs that integrate with Advanced Pricing
--    in Complex Maintainance, Repair and Overhauling(CMRO).
--
--    It defines the following APIs
--
--      Get_Task_Estimated_Price            (see below for specification)
--      Get_Job_Estimated_Price             (see below for specification)
--      Get_Job_Actual_Price                (see below for specification)
--      Get_Items_without_Price             (see below for specification)
--      Get_Item_Price                      (see below for specification)
--      Check_Item_for_Rt_Mat_Req           (see below for specification)
--      Check_Item_for_Prod_Mat_Req         (see below for specification)
--      Check_Item_for_Rt_Res_Req           (see below for specification)
--      Check_Item_for_Prod_Res_Req         (see below for specification)
--      Check_Item_for_Resource_Trans       (see below for specification)
--      Check_Item_for_Materials_Trans      (see below for specification)

--
-- NOTES
--
--
-- HISTORY
-- 27-Aug-2003    yazhou      Created.
--------------------------------------------------------------------

--------------------------------------------------------------------
--  Procedure name    : Get_Task_Estimated_Price
--  Type              : Private
--  Purpose           : To return estimated price for a given task.
--  Parameters  :
--
--  Standard OUT Parameters :
--   x_return_status        OUT     VARCHAR2     Required
--
--  Get_Task_Estimated_Price IN Parameters:
--   p_visit_task_id         IN  NUMBER     Required,
--   p_route_id              IN  NUMBER     Required,
--   p_price_list_id         IN  NUMBER     Required,
--   p_currency_code         IN  VARCHAR2   Required,
--   p_customer_id           IN  NUMBER     Required,
--   p_effective_date        IN  DATE       Required,
--   p_organization_id       IN  NUMBER     Required,
--
--  Get_Task_Estimated_Price OUT Parameters:
--   x_estimated_price       OUT  NUMBER     Required,
--
--  Version :
--      Initial Version   1.0
--------------------------------------------------------------------
PROCEDURE Get_Task_Estimated_Price
    (p_visit_task_id        IN NUMBER,
     p_route_id             IN NUMBER,
     p_price_list_id        IN NUMBER,
     p_customer_id          IN NUMBER,
     p_currency_code        IN VARCHAR2,
     p_effective_date       IN DATE,
     p_organization_id      IN NUMBER,

     x_estimated_price      OUT NOCOPY NUMBER,
     x_return_status        OUT NOCOPY VARCHAR2
     );

--------------------------------------------------------------------
--  Procedure name    : Get_Job_Estimated_Price
--  Type              : Private
--  Purpose           : To return estimated price for the job of a given task.
--  Parameters  :
--
--  Standard OUT Parameters :
--   x_return_status        OUT     VARCHAR2     Required
--
--  Get_Task_Estimated_Price IN Parameters:
--   p_visit_task_id         IN  NUMBER     Required,
--   p_price_list_id         IN  NUMBER     Required,
--   p_currency_code         IN  VARCHAR2   Required,
--   p_customer_id           IN  NUMBER     Required,
--
--  Get_Task_Estimated_Price OUT Parameters:
--   x_estimated_price       OUT  NUMBER     Required,
--
--  Version :
--      Initial Version   1.0
--------------------------------------------------------------------
PROCEDURE Get_Job_Estimated_Price
    (p_visit_task_id        IN NUMBER,
     p_price_list_id        IN NUMBER,
     p_customer_id          IN NUMBER,
     p_currency_code        IN VARCHAR2,

     x_estimated_price      OUT NOCOPY NUMBER,
     x_return_status        OUT NOCOPY VARCHAR2
     );

--------------------------------------------------------------------
--  Procedure name    : Get_Job_Actual_Price
--  Type              : Private
--  Purpose           : To return actual price for the job of a given task.
--  Parameters  :
--
--  Standard OUT Parameters :
--   x_return_status        OUT     VARCHAR2     Required
--
--  Get_Task_Actual_Price IN Parameters:
--   p_visit_task_id         IN  NUMBER     Required,
--   p_price_list_id         IN  NUMBER     Required,
--   p_currency_code         IN  VARCHAR2   Required,
--   p_customer_id           IN  NUMBER     Required,
--
--  Get_Task_Actual_Price OUT Parameters:
--   x_actual_price          OUT  NUMBER     Required,
--
--  Version :
--      Initial Version   1.0
--------------------------------------------------------------------
PROCEDURE Get_Job_Actual_Price
    (p_visit_task_id        IN NUMBER,
     p_price_list_id        IN NUMBER,
     p_customer_id          IN NUMBER,
     p_currency_code        IN VARCHAR2,

     x_actual_price         OUT NOCOPY NUMBER,
     x_return_status        OUT NOCOPY VARCHAR2
     );

--------------------------------------------------------------------
--  Procedure name    : Get_Item_Price
--  Type              : Private
--  Purpose           : To return price for a given item.
--  Parameters  :
--
--  Standard OUT Parameters :
--   x_return_status        OUT     VARCHAR2     Required
--
--  Get_Item_Price IN Parameters:
--   p_item_id               IN  NUMBER     Required,
--   p_price_list_id         IN  NUMBER     Required,
--   p_currency_code         IN  VARCHAR2   Required,
--   p_customer_id           IN  NUMBER     Required,
--   p_duration              IN NUMBER      Optional,
--   p_effective_date       IN  DATE       Required,
--   p_UOM_code              IN VARCHAR2    Required,
--
--  Get_Item_Price OUT Parameters:
--   x_item_price            OUT  NUMBER     Required, if return value is null
--                                          then item is not set up in price list
--
--  Version :
--      Initial Version   1.0
--------------------------------------------------------------------
PROCEDURE Get_Item_Price
    (p_item_id              IN NUMBER,
     p_price_list_id        IN NUMBER,
     p_customer_id          IN NUMBER,
     p_duration             IN NUMBER := 1,
     p_currency_code        IN VARCHAR2,
     p_effective_date       IN DATE,
     p_UOM_code             IN VARCHAR2,

     x_item_price           OUT NOCOPY NUMBER,
     x_return_status        OUT NOCOPY VARCHAR2
     );

--------------------------------------------------------------------
--  Procedure name    : Get_Items_without_Price
--  Type              : Private
--  Purpose           : To return items which are not set up in price list.
--  Parameters  :
--
--  Standard OUT Parameters :
--   x_return_status        OUT     VARCHAR2     Required
--
--  Get_Items_without_Price IN Parameters:
--   p_item_tbl               IN  AHL_VWP_RULES_PVT.Item_Tbl_Type     Required,
--   p_price_list_id         IN  NUMBER     Required,
--   p_currency_code         IN  VARCHAR2   Required,
--   p_customer_id           IN  NUMBER     Required,

--
--  Get_Task_Estimated_Price OUT Parameters:
--   x_item_tbl            OUT  AHL_VWP_RULES_PVT.Item_Tbl_Type     Required
--
--  Version :
--      Initial Version   1.0
--------------------------------------------------------------------
PROCEDURE Get_Items_without_Price
    (p_item_tbl             IN AHL_VWP_RULES_PVT.Item_Tbl_Type,
     p_price_list_id        IN NUMBER,
     p_customer_id          IN NUMBER,
     p_currency_code        IN VARCHAR2,

     x_item_tbl             OUT NOCOPY AHL_VWP_RULES_PVT.Item_Tbl_Type,
     x_return_status        OUT NOCOPY VARCHAR2
     );

--------------------------------------------------------------------
--  Procedure name    : Check_Item_for_Prod_Mat_Req
--  Type              : Private
--  Purpose           : To return items required for Material requirements of a given task.
--                      when job is not in draft status
--  Parameters  :
--
--  Standard OUT Parameters :
--   x_return_status        OUT     VARCHAR2     Required
--
--  Check_Item_for_Prod_Mat_Req IN Parameters:
--   p_visit_task_id         IN  NUMBER     Required,
--   p_route_id              IN  NUMBER     Required,

--
--  Check_Item_for_Prod_Mat_Req OUT Parameters:
--   x_item_tbl            OUT  AHL_VWP_RULES_PVT.Item_Tbl_Type     Required
--
--  Version :
--      Initial Version   1.0
--------------------------------------------------------------------
PROCEDURE Check_Item_for_Prod_Mat_Req
    (p_visit_task_id        IN NUMBER,

     x_item_tbl             OUT NOCOPY AHL_VWP_RULES_PVT.Item_Tbl_Type,
     x_return_status        OUT NOCOPY VARCHAR2
     );

--------------------------------------------------------------------
--  Procedure name    : Check_Item_for_Rt_Mat_Req
--  Type              : Private
--  Purpose           : To return items required for Material requirements of a given task.
--                      when job is in Draft status
--  Parameters  :
--
--  Standard OUT Parameters :
--   x_return_status        OUT     VARCHAR2     Required
--
--  Check_Item_for_Rt_Mat_Req IN Parameters:
--   p_visit_task_id         IN  NUMBER     Required,
--   p_route_id              IN  NUMBER     Required,
--   p_effective_date        IN  DATE     Required,

--
--  Check_Item_for_Rt_Mat_Req OUT Parameters:
--   x_item_tbl            OUT  AHL_VWP_RULES_PVT.Item_Tbl_Type     Required
--
--  Version :
--      Initial Version   1.0
--------------------------------------------------------------------
PROCEDURE Check_Item_for_Rt_Mat_Req
    (p_visit_task_id        IN NUMBER,
     p_route_id             IN NUMBER,
     p_effective_date       IN DATE,

     x_item_tbl             OUT NOCOPY AHL_VWP_RULES_PVT.Item_Tbl_Type,
     x_return_status        OUT NOCOPY VARCHAR2
     );

--------------------------------------------------------------------
--  Procedure name    : Check_Item_for_Prod_Res_Req
--  Type              : Private
--  Purpose           : To return items required for Resource requirements of a given task.
--                      when job is not in draft status
--  Parameters  :
--
--  Standard OUT Parameters :
--   x_return_status        OUT     VARCHAR2     Required
--
--  Check_Item_for_Prod_Res_Req IN Parameters:
--   p_visit_task_id         IN  NUMBER     Required,
--   p_route_id              IN  NUMBER     Required,

--
--  Check_Item_for_Prod_Res_Req OUT Parameters:
--   x_item_tbl            OUT  AHL_VWP_RULES_PVT.Item_Tbl_Type     Required
--
--  Version :
--      Initial Version   1.0
--------------------------------------------------------------------
PROCEDURE Check_Item_for_Prod_Res_Req
    (p_visit_task_id        IN NUMBER,

     x_item_tbl             OUT NOCOPY AHL_VWP_RULES_PVT.Item_Tbl_Type,
     x_return_status        OUT NOCOPY VARCHAR2
     );

--------------------------------------------------------------------
--  Procedure name    : Check_Item_for_Rt_Res_Req
--  Type              : Private
--  Purpose           : To return items required for Resource requirements of a given task.
--                      when job is in Draft status
--  Parameters  :
--
--  Standard OUT Parameters :
--   x_return_status        OUT     VARCHAR2     Required
--
--  Check_Item_for_Rt_Res_Req IN Parameters:
--   p_visit_task_id         IN  NUMBER     Required,
--   p_route_id              IN  NUMBER     Required,
--   p_organization_id       IN  NUMBER     Required,
--   p_effective_date        IN  DATE     Required,

--
--  Check_Item_for_Rt_Res_Req OUT Parameters:
--   x_item_tbl            OUT  AHL_VWP_RULES_PVT.Item_Tbl_Type     Required
--
--  Version :
--      Initial Version   1.0
--------------------------------------------------------------------
PROCEDURE Check_Item_for_Rt_Res_Req
    (p_visit_task_id        IN NUMBER,
     p_route_id             IN NUMBER,
     p_organization_id      IN NUMBER,
     p_effective_date       IN DATE,

     x_item_tbl             OUT NOCOPY AHL_VWP_RULES_PVT.Item_Tbl_Type,
     x_return_status        OUT NOCOPY VARCHAR2
     );

--------------------------------------------------------------------
--  Procedure name    : Check_Item_for_Resource_Trans
--  Type              : Private
--  Purpose           : To return items required for Resource transactions of a given task.
--  Parameters  :
--
--  Standard OUT Parameters :
--   x_return_status        OUT     VARCHAR2     Required
--
--  Check_Item_for_Resource_Trans IN Parameters:
--   p_visit_task_id         IN  NUMBER     Required,
--
--  Check_Item_for_Resource_Trans OUT Parameters:
--   x_item_tbl            OUT  AHL_VWP_RULES_PVT.Item_Tbl_Type     Required
--
--  Version :
--      Initial Version   1.0
--------------------------------------------------------------------
PROCEDURE Check_Item_for_Resource_Trans
    (p_visit_task_id        IN NUMBER,

     x_item_tbl             OUT NOCOPY AHL_VWP_RULES_PVT.Item_Tbl_Type,
     x_return_status        OUT NOCOPY VARCHAR2
     );

--------------------------------------------------------------------
--  Procedure name    : Check_Item_for_Material_Trans
--  Type              : Private
--  Purpose           : To return items required for Mateiral transactions of a given task.
--  Parameters  :
--
--  Standard OUT Parameters :
--   x_return_status        OUT     VARCHAR2     Required
--
--  Check_Item_for_Material_Trans IN Parameters:
--   p_visit_task_id         IN  NUMBER     Required,
--
--  Check_Item_for_Material_Trans OUT Parameters:
--   x_item_tbl            OUT  AHL_VWP_RULES_PVT.Item_Tbl_Type     Required
--
--  Version :
--      Initial Version   1.0
--------------------------------------------------------------------
PROCEDURE Check_Item_for_Materials_Trans
    (p_visit_task_id        IN NUMBER,

     x_item_tbl             OUT NOCOPY AHL_VWP_RULES_PVT.Item_Tbl_Type,
     x_return_status        OUT NOCOPY VARCHAR2
     );

END AHL_VWP_PRICE_PVT;


 

/
