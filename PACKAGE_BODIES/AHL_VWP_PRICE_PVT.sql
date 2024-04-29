--------------------------------------------------------
--  DDL for Package Body AHL_VWP_PRICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_VWP_PRICE_PVT" AS
/* $Header: AHLVVPRB.pls 120.5 2006/09/18 14:28:19 anraj noship $ */

-- Define global internal variables
G_PKG_NAME VARCHAR2(30) := 'AHL_VWP_PRICE_PVT';

/* $Header: AHLVVPRB.pls 120.5 2006/09/18 14:28:19 anraj noship $ */
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
--      Calculate_Totle_Price               (see below for specification)
--
-- NOTES
--
--
-- HISTORY
-- 02-Sep-2003    yazhou      Created.
--------------------------------------------------------------------

PROCEDURE Calculate_Total_Price
    (p_item_tbl             IN AHL_VWP_RULES_PVT.Item_Tbl_Type,
     p_price_list_id        IN NUMBER,
     p_customer_id          IN NUMBER,
     p_currency_code        IN VARCHAR2,

     x_total_price          OUT NOCOPY NUMBER,
     x_return_status        OUT NOCOPY VARCHAR2
     );

PROCEDURE Check_UOM_Class
    (p_UOM_Code             IN VARCHAR2,
     x_time_type_flag       OUT NOCOPY VARCHAR2
     );

--------------------------------------------------------------------
--  Procedure name    : Get_Task_Estimated_Price
--  Purpose           : To return estimated price for a given task.
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
     )
IS
  -- Define local variables
  l_x_return_status           VARCHAR2(240);
  l_total_price               NUMBER := 0;   -- total price

  l_res_item_tbl              AHL_VWP_RULES_PVT.Item_Tbl_Type;
  l_mat_item_tbl              AHL_VWP_RULES_PVT.Item_Tbl_Type;
  l_x_item_tbl                AHL_VWP_RULES_PVT.Item_Tbl_Type;

  i                           NUMBER := 0;   -- table index
  l_api_name       CONSTANT   VARCHAR2(30) := 'Get_Task_Estimated_Price';


BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
			       'At the start of the procedure');
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': End API',
			       'Visit Task ID: '|| p_visit_task_id);
  END IF;

--Initialize API return status to success
  l_x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Get the items from Resource Requirements of the route

  Check_Item_for_Rt_Res_Req
    (p_visit_task_id        =>p_visit_task_id ,
     p_route_id             =>p_route_id ,
     p_organization_id      =>p_organization_id ,
     p_effective_date       =>p_effective_date,

     x_item_tbl             =>l_res_item_tbl ,
     x_return_status        =>l_x_return_status
     );

     IF (l_x_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
          RAISE Fnd_Api.G_EXC_ERROR;
     END IF;

     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': After Checking Items for Resource Requirements',
			       'Return Status is: '|| l_x_return_status);
	     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': After Checking Items for Resource Requirements',
			       'Number of Items: '||l_mat_item_tbl.COUNT );
     END IF;

-- Get the items from Material Requirements of the route

  Check_Item_for_Rt_Mat_Req
    (p_visit_task_id        =>p_visit_task_id ,
     p_route_id             =>p_route_id ,
     p_effective_date       =>p_effective_date,

     x_item_tbl             =>l_mat_item_tbl ,
     x_return_status        =>l_x_return_status
     );

     IF (l_x_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
          RAISE Fnd_Api.G_EXC_ERROR;
     END IF;

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': After Checking Items for Material Requirements',
			       'Return Status is: '|| l_x_return_status);
	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': After Checking Items for Material Requirements',
			       'Number of Items: '||l_mat_item_tbl.COUNT );
     END IF;

-- Merge the two Item table to get the item table
-- that the same task, item and UOM combination appear only once


    AHL_VWP_RULES_PVT.Merge_for_Unique_Items
      (p_item_tbl1             =>l_res_item_tbl ,
       p_item_tbl2             =>l_mat_item_tbl ,

       x_item_tbl              =>l_x_item_tbl
      );


     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': After Merge Items',
			       'Number of Items: '||l_x_item_tbl.COUNT );
     END IF;

-- Calculate the price for the items required by the route
  IF l_x_item_tbl.count > 0 THEN

    Calculate_Total_Price
      (p_item_tbl             =>l_x_item_tbl,
       p_price_list_id        =>p_price_list_id ,
       p_customer_id          =>p_customer_id ,
       p_currency_code        =>p_currency_code ,

       x_total_price          =>l_total_price ,
       x_return_status        =>l_x_return_status
       );

  END IF;

  IF (l_x_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
          RAISE Fnd_Api.G_EXC_ERROR;
  END IF;

-- Assign return status  and  Item without Price table
  x_return_status:=l_x_return_status;
  x_estimated_price := l_total_price;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': End API',
			       'Return Status is: '|| x_return_status);
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': End API',
			       'Total Price: '|| x_estimated_price);
  END IF;


END Get_Task_Estimated_Price;

--------------------------------------------------------------------
--  Procedure name    : Get_Job_Estimated_Price
--  Purpose           : To return estimated price for the job of a given task.
--------------------------------------------------------------------
PROCEDURE Get_Job_Estimated_Price
    (p_visit_task_id        IN NUMBER,
     p_price_list_id        IN NUMBER,
     p_customer_id          IN NUMBER,
     p_currency_code        IN VARCHAR2,

     x_estimated_price      OUT NOCOPY NUMBER,
     x_return_status        OUT NOCOPY VARCHAR2
     )
IS
  -- Define local variables
  l_x_return_status           VARCHAR2(240);
  l_total_price               NUMBER := 0;   -- total price

  l_res_item_tbl              AHL_VWP_RULES_PVT.Item_Tbl_Type;
  l_mat_item_tbl              AHL_VWP_RULES_PVT.Item_Tbl_Type;
  l_x_item_tbl                AHL_VWP_RULES_PVT.Item_Tbl_Type;

  i                           NUMBER := 0;   -- table index
  l_api_name       CONSTANT   VARCHAR2(30) := 'Get_Job_Estimated_Price';


BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
			       'At the start of the procedure');
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': End API',
			       'Visit Task ID: '|| p_visit_task_id);
  END IF;

--Initialize API return status to success
  l_x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Get the items from Resource Requirements of the route

  Check_Item_for_Prod_Res_Req
    (p_visit_task_id        =>p_visit_task_id ,

     x_item_tbl             =>l_res_item_tbl ,
     x_return_status        =>l_x_return_status
     );

     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': After Checking Items for Resource Requirements',
			       'Return Status is: '|| l_x_return_status);
	     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': After Checking Items for Resource Requirements',
			       'Number of Items: '||l_mat_item_tbl.COUNT );
     END IF;

-- Get the items from Material Requirements of the route

  Check_Item_for_Prod_Mat_Req
    (p_visit_task_id        =>p_visit_task_id ,

     x_item_tbl             =>l_mat_item_tbl ,
     x_return_status        =>l_x_return_status
     );

     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': After Checking Items for Material Requirements',
			       'Return Status is: '|| l_x_return_status);
	     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': After Checking Items for Material Requirements',
			       'Number of Items: '||l_mat_item_tbl.COUNT );
     END IF;

-- Merge the two Item table to get the item table
-- that the same task, item and UOM combination appear only once

  AHL_VWP_RULES_PVT.Merge_for_Unique_Items
    (p_item_tbl1             =>l_res_item_tbl ,
     p_item_tbl2             =>l_mat_item_tbl ,

     x_item_tbl              =>l_x_item_tbl
     );


     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': After Merge Items',
			       'Number of Items: '||l_x_item_tbl.COUNT );
     END IF;

-- Calculate the price for the items required by the route

  IF l_x_item_tbl.count > 0 THEN

   Calculate_Total_Price
    (p_item_tbl             =>l_x_item_tbl,
     p_price_list_id        =>p_price_list_id ,
     p_customer_id          =>p_customer_id ,
     p_currency_code        =>p_currency_code ,

     x_total_price          =>l_total_price ,
     x_return_status        =>l_x_return_status
     );

  END IF;

-- Assign return status  and  Item without Price table
  x_return_status:=l_x_return_status;
  x_estimated_price := l_total_price;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': End API',
			       'Return Status is: '|| x_return_status);
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': End API',
			       'Total Price: '|| x_estimated_price);
  END IF;


END Get_Job_Estimated_Price;

--------------------------------------------------------------------
--  Procedure name    : Get_Job_Actual_Price
--  Purpose           : To return actual price for the job of a given task.
--------------------------------------------------------------------
PROCEDURE Get_Job_Actual_Price
    (p_visit_task_id        IN NUMBER,
     p_price_list_id        IN NUMBER,
     p_customer_id          IN NUMBER,
     p_currency_code        IN VARCHAR2,

     x_actual_price         OUT NOCOPY NUMBER,
     x_return_status        OUT NOCOPY VARCHAR2
     )
IS
  -- Define local variables
  l_x_return_status           VARCHAR2(240);
  l_total_price               NUMBER := 0;   -- total price

  l_res_item_tbl              AHL_VWP_RULES_PVT.Item_Tbl_Type;
  l_mat_item_tbl              AHL_VWP_RULES_PVT.Item_Tbl_Type;
  l_x_item_tbl                AHL_VWP_RULES_PVT.Item_Tbl_Type;

  i                           NUMBER := 0;   -- table index
  l_api_name       CONSTANT   VARCHAR2(30) := 'Get_Task_Actual_Price';


BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
			       'At the start of the procedure');
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': End API',
			       'Visit Task ID: '|| p_visit_task_id);
  END IF;

--Initialize API return status to success
  l_x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Get the items from Resource Transactions of the WIP job of this task

  Check_Item_for_Resource_Trans
    (p_visit_task_id        =>p_visit_task_id ,

     x_item_tbl             =>l_res_item_tbl ,
     x_return_status        =>l_x_return_status
     );

     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': After Checking Items for Resource Transactions',
			       'Return Status is: '|| l_x_return_status);
	     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': After Checking Items for Resource Transactions',
			       'Number of Items: '||l_mat_item_tbl.COUNT );
     END IF;

-- Get the items from Material Transactions of the WIP job of this task

  Check_Item_for_Materials_Trans
    (p_visit_task_id        =>p_visit_task_id ,

     x_item_tbl             =>l_mat_item_tbl ,
     x_return_status        =>l_x_return_status
     );

     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': After Checking Items for Material Transactions',
			       'Return Status is: '|| l_x_return_status);
	     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': After Checking Items for Material Transactions',
			       'Number of Items: '||l_mat_item_tbl.COUNT );
     END IF;

-- Merge the two Item table to get the item table
-- that the same task, item and UOM combination appear only once

  AHL_VWP_RULES_PVT.Merge_for_Unique_Items
    (p_item_tbl1             =>l_res_item_tbl ,
     p_item_tbl2             =>l_mat_item_tbl ,

     x_item_tbl              =>l_x_item_tbl
     );


     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': After Merge Items',
			       'Number of Items: '||l_x_item_tbl.COUNT );
     END IF;

-- Calculate the price for the items required by the WIP job

  IF l_x_item_tbl.count > 0 THEN

   Calculate_Total_Price
    (p_item_tbl             =>l_x_item_tbl,
     p_price_list_id        =>p_price_list_id ,
     p_customer_id          =>p_customer_id ,
     p_currency_code        =>p_currency_code ,

     x_total_price          =>l_total_price ,
     x_return_status        =>l_x_return_status
     );

  END IF;

-- Assign return status  and  Item without Price table
  x_return_status:=l_x_return_status;
  x_actual_price := l_total_price;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': End API',
			       'Return Status is: '|| x_return_status);
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': End API',
			       'Total Price: '|| x_actual_price);
  END IF;

END Get_Job_Actual_Price;

--------------------------------------------------------------------
--  Procedure name    : Get_Item_Price
--  Purpose           : To return price for a given item.
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
     )
IS

  -- Define local variables

 l_p_line_tbl                  QP_PREQ_GRP.LINE_TBL_TYPE;
 l_p_qual_tbl                  QP_PREQ_GRP.QUAL_TBL_TYPE;
 l_p_line_attr_tbl             QP_PREQ_GRP.LINE_ATTR_TBL_TYPE;
 l_p_LINE_DETAIL_tbl           QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
 l_p_LINE_DETAIL_qual_tbl      QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE;
 l_p_LINE_DETAIL_attr_tbl      QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE;
 l_p_related_lines_tbl         QP_PREQ_GRP.RELATED_LINES_TBL_TYPE;
 l_p_control_rec               QP_PREQ_GRP.CONTROL_RECORD_TYPE;
 l_x_line_tbl                  QP_PREQ_GRP.LINE_TBL_TYPE;
 l_x_line_qual                 QP_PREQ_GRP.QUAL_TBL_TYPE;
 l_x_line_attr_tbl             QP_PREQ_GRP.LINE_ATTR_TBL_TYPE;
 l_x_line_detail_tbl           QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
 l_x_line_detail_qual_tbl      QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE;
 l_x_line_detail_attr_tbl      QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE;
 l_x_related_lines_tbl         QP_PREQ_GRP.RELATED_LINES_TBL_TYPE;
 l_x_return_status             VARCHAR2(240);
 l_x_return_status_text        VARCHAR2(240);
 l_qual_rec                    QP_PREQ_GRP.QUAL_REC_TYPE;
 l_line_attr_rec               QP_PREQ_GRP.LINE_ATTR_REC_TYPE;
 l_line_rec                    QP_PREQ_GRP.LINE_REC_TYPE;

  l_duration                    NUMBER :=1; -- duration is default to 1
  i                             NUMBER :=0;  -- loop index
  l_api_name       CONSTANT   VARCHAR2(30) := 'Get_Item_Price';

BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT Get_Item_Price;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
			       'At the start of the procedure');
  END IF;

--Initialize API return status to success
  l_x_return_status := FND_API.G_RET_STS_SUCCESS;

-- If duration passed in is null then default to 1
  IF p_duration is not NULL AND p_duration <> FND_API.G_MISS_NUM THEN
     l_duration := p_duration;
  END IF;

-- Passing Information to the Pricing Engine

-- Setting up the control record variables

 l_p_control_rec.pricing_event := 'LINE';
 l_p_control_rec.calculate_flag := 'Y';
 l_p_control_rec.simulation_flag := 'N';
 l_p_control_rec.use_multi_currency := 'Y';
--Jerry added on 09/27/05 for MOAC change
 l_p_control_rec.org_id := MO_GLOBAL.get_current_org_id;

-- Request Line (Order Line) Information
 l_line_rec.request_type_code :='AHL';
 l_line_rec.line_id :=p_item_id;                  -- Order Line Id. This can be any thing for this script
 l_line_rec.line_Index :='1';                    -- Request Line Index
 l_line_rec.line_type_code := 'LINE';            -- LINE or ORDER(Summary Line)
 l_line_rec.pricing_effective_date := p_effective_date;   -- Pricing as of what date ?
 l_line_rec.line_quantity := 1;                  -- Ordered Quantity
 l_line_rec.line_uom_code := p_UOM_code;               -- Ordered UOM Code
 l_line_rec.currency_code := p_currency_code;              -- Currency Code
 l_line_rec.price_flag := 'Y';                   -- Price Flag can have 'Y' , 'N'(No pricing) , 'P'(Phase)
 l_p_line_tbl(1) := l_line_rec;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Request Line',
			       'Line ID: '||l_p_line_tbl(1).line_id );
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Request Line',
			       'Effective Dates: '||l_p_line_tbl(1).pricing_effective_date );
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Request Line',
			       'UOM Code: '||l_p_line_tbl(1).line_uom_code );
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Request Line',
			       'Currency: '||l_p_line_tbl(1).currency_code );
  END IF;
-- Pricing Attributes Passed In
--- Item
 l_line_attr_rec.LINE_INDEX := 1; -- Attributes for the above line. Attributes are attached with the line index
 l_line_attr_rec.PRICING_CONTEXT :='ITEM';
 l_line_attr_rec.PRICING_ATTRIBUTE :='PRICING_ATTRIBUTE1';
 l_line_attr_rec.PRICING_ATTR_VALUE_FROM  := p_item_id; -- Inventory Item Id
 l_line_attr_rec.VALIDATED_FLAG :='N';
 l_p_line_attr_tbl(1):= l_line_attr_rec;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Pricing Attributes',
			       'Item ID: '||l_p_line_attr_tbl(1).PRICING_ATTR_VALUE_FROM );
  END IF;

--- Duration (pricing attribute required by formula)
-- If no formula is associated for the given item then unit price will be derived

 l_line_attr_rec.LINE_INDEX := 1; -- Attributes for the above line. Attributes are attached with the line index
 l_line_attr_rec.PRICING_CONTEXT :='AHL_PRICING'; -- CMRO set up
 l_line_attr_rec.PRICING_ATTRIBUTE :='PRICING_ATTRIBUTE1';
 l_line_attr_rec.PRICING_ATTR_VALUE_FROM  := l_duration; -- resource duration
 l_line_attr_rec.VALIDATED_FLAG :='N';
 l_p_line_attr_tbl(2):= l_line_attr_rec;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Pricing Attributes',
			       'Duration: '||l_p_line_attr_tbl(2).PRICING_ATTR_VALUE_FROM );
  END IF;

-- Qualifiers Passed In
--- Price List
 l_qual_rec.LINE_INDEX := 1; -- Attributes for the above line. Attributes are attached with the line index
 l_qual_rec.QUALIFIER_CONTEXT :='MODLIST';
 l_qual_rec.QUALIFIER_ATTRIBUTE :='QUALIFIER_ATTRIBUTE4';
 l_qual_rec.QUALIFIER_ATTR_VALUE_FROM :=p_price_list_id; -- Price List Id
 l_qual_rec.COMPARISON_OPERATOR_CODE := '=';
 l_qual_rec.VALIDATED_FLAG :='N';
 l_p_qual_tbl(1):= l_qual_rec;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Qualifiers',
			       'Price List ID: '||l_p_qual_tbl(1).QUALIFIER_ATTR_VALUE_FROM );
  END IF;
--- Customer
 l_qual_rec.LINE_INDEX := 1; -- Attributes for the above line. Attributes are attached with the line index
 l_qual_rec.QUALIFIER_CONTEXT :='CUSTOMER';
 l_qual_rec.QUALIFIER_ATTRIBUTE :='QUALIFIER_ATTRIBUTE16';
 l_qual_rec.QUALIFIER_ATTR_VALUE_FROM :=p_customer_id; -- Customer Id
 l_qual_rec.COMPARISON_OPERATOR_CODE := '=';
 l_qual_rec.VALIDATED_FLAG :='N';
 l_p_qual_tbl(2):= l_qual_rec;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Qualifiers',
			       'Customer ID: '||l_p_qual_tbl(2).QUALIFIER_ATTR_VALUE_FROM );
  END IF;
-- Actual Call to the Pricing Engine
 QP_PREQ_PUB.PRICE_REQUEST
       (l_p_line_tbl,
        l_p_qual_tbl,
        l_p_line_attr_tbl,
        l_p_line_detail_tbl,
        l_p_line_detail_qual_tbl,
        l_p_line_detail_attr_tbl,
        l_p_related_lines_tbl,
        l_p_control_rec,
        l_x_line_tbl,
        l_x_line_qual,
        l_x_line_attr_tbl,
        l_x_line_detail_tbl,
        l_x_line_detail_qual_tbl,
        l_x_line_detail_attr_tbl,
        l_x_related_lines_tbl,
        l_x_return_status,
        l_x_return_status_text);

-- Return Status Information ..
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': After Pricing API call',
			       'Return Status: '||l_x_return_status );
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': After Pricing API call',
			       'Return Status text: '||l_x_return_status_text );
  END IF;


 IF (l_x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    FND_MESSAGE.Set_Name('AHL','AHL_VWP_PRICE_API_ERROR');
    FND_MESSAGE.Set_Token('ERROR', l_x_return_status_text);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;


-- Unit Price returned

I := l_x_line_tbl.FIRST;
IF I IS NOT NULL THEN
 LOOP

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': After Pricing API call',
			       'Line Index: '||l_x_line_tbl(I).line_index );
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': After Pricing API call',
			       'Unit Price: '||l_x_line_tbl(I).unit_price );
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': After Pricing API call',
			       'Adjusted Unit Price: '||l_x_line_tbl(I).adjusted_unit_price );
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': After Pricing API call',
			       'Line Status Code: '||l_x_line_tbl(I).status_code );
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': After Pricing API call',
			       'Line Status Text: '||l_x_line_tbl(I).status_text );
  END IF;

  x_item_price := l_x_line_tbl(I).adjusted_unit_price;

  EXIT WHEN I = l_x_line_tbl.LAST;
  I := l_x_line_tbl.NEXT(I);
 END LOOP;
END IF;

-- Assign return status
  x_return_status:=l_x_return_status;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': End API',
			       'Return Status is: '|| x_return_status);
  END IF;

EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Get_Item_Price;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Get_Item_Price;
    X_return_status := FND_API.G_RET_STS_ERROR;

WHEN OTHERS THEN
    ROLLBACK TO Get_Item_Price;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Get_Item_Price;

--------------------------------------------------------------------
--  Procedure name    : Get_Items_without_Price
--  Purpose           : To return items which are not set up in price list.
--------------------------------------------------------------------
PROCEDURE Get_Items_without_Price
    (p_item_tbl             IN AHL_VWP_RULES_PVT.Item_Tbl_Type,
     p_price_list_id        IN NUMBER,
     p_customer_id          IN NUMBER,
     p_currency_code        IN VARCHAR2,

     x_item_tbl             OUT NOCOPY AHL_VWP_RULES_PVT.Item_Tbl_Type,
     x_return_status        OUT NOCOPY VARCHAR2
     )
IS

  -- Define local variables
  l_x_return_status           VARCHAR2(240);
  l_item_tbl                  AHL_VWP_RULES_PVT.Item_Tbl_Type;
  l_x_item_price              NUMBER := 0;

  i                           NUMBER :=0;  -- loop index
  j                           NUMBER :=0;  -- loop index

  l_api_name       CONSTANT   VARCHAR2(30) := 'Get_Items_without_Price';

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
			       'At the start of the procedure');
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': End API',
			       'Number of Items to check: '|| p_item_tbl.count);
  END IF;

--Initialize API return status to success
  l_x_return_status := FND_API.G_RET_STS_SUCCESS;

-- For each item in p_item_tbl, check for price
-- If price is not set up in price list
-- Add this item to output item table

I := p_item_tbl.FIRST;
IF I IS NOT NULL THEN
 LOOP

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': In Loop',
			       'Loop Index: '||I );
  END IF;

-- Check the price of the item
  Get_Item_Price
    (p_item_id              =>p_item_tbl(I).Item_Id ,
     p_price_list_id        =>p_price_list_id ,
     p_customer_id          =>p_customer_id ,
     p_duration             =>p_item_tbl(I).Duration ,
     p_currency_code        =>p_currency_code ,
     p_effective_date       =>p_item_tbl(I).Effective_Date ,
     p_UOM_code             =>p_item_tbl(I).UOM_Code ,

     x_item_price           =>l_x_item_price ,
     x_return_status        =>l_x_return_status
     );

 -- Add the item to output table if returned item price is null
  IF (l_x_item_price IS NULL) THEN

       l_item_tbl(J) := p_item_tbl(I);

       J:= J+1;
  END IF;

  EXIT WHEN I = p_item_tbl.LAST;
  I := p_item_tbl.NEXT(I);
 END LOOP;
END IF;

-- Assign return status  and  Item without Price table
  x_return_status:=l_x_return_status;
  x_item_tbl:= l_item_tbl;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': End API',
			       'Return Status is: '|| x_return_status);
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': End API',
			       'Number of Items without Price: '|| x_item_tbl.count);
  END IF;

END Get_Items_without_Price;

--------------------------------------------------------------------
--  Procedure name    : Check_Item_for_Prod_Mat_Req
--  Purpose           : To return items required for Material requirements of a given task.
--                      when job is not in draft status
--------------------------------------------------------------------
PROCEDURE Check_Item_for_Prod_Mat_Req
    (p_visit_task_id        IN NUMBER,

     x_item_tbl             OUT NOCOPY AHL_VWP_RULES_PVT.Item_Tbl_Type,
     x_return_status        OUT NOCOPY VARCHAR2
     )
IS
 -- Define local Cursors

-- Get job material requirements

  CURSOR get_prod_materials_csr (c_visit_task_id NUMBER)
  IS
/*
SELECT MAT.inventory_item_id,
         MAT.requested_date,
         SUM(NVL(MAT.requested_quantity,0)) quantity,
         MAT.uom_code
  FROM AHL_SCHEDULE_MATERIALS_V MAT
  WHERE  MAT.visit_task_id =c_visit_task_id
  AND MAT.JOB_STATUS_CODE <> 22  -- 'deleted' status
  AND MAT.JOB_STATUS_CODE <> 7  -- 'cancelled' status
  AND MAT.inventory_item_id is not null
  AND MAT.uom_code is not null
  GROUP BY MAT.inventory_item_id,
         MAT.requested_date,
         MAT.uom_code;
*/
-- AnRaj: Changed query for fixing the perf issue #2, bug:4919487
-- AnRaj: 5532023, added further WHERE clauses which were missed out during fixing 4919487
SELECT   asm.inventory_item_id,
         wiro.DATE_REQUIRED requested_date,
         sum(nvl(wiro.REQUIRED_QUANTITY,0)) quantity,
         mtl.primary_uom_code uom_code
FROM     ahl_workorders awo,
         ahl_schedule_materials asm,
         wip_requirement_operations wiro,
         mtl_system_items_b mtl
WHERE    awo.visit_task_id = c_visit_task_id
AND      awo.visit_task_id = asm.visit_task_id
AND      asm.inventory_item_id = mtl.inventory_item_id
AND      asm.organization_id   = mtl.organization_id
AND      awo.wip_entity_id = wiro.wip_entity_id
AND      awo.STATUS_CODE NOT IN (22,7)
AND      ASM.inventory_item_id is not null
AND      mtl.primary_uom_code is not null
AND      ASM.OPERATION_SEQUENCE = WIRO.OPERATION_SEQ_NUM
AND      ASM.INVENTORY_ITEM_ID = WIRO.INVENTORY_ITEM_ID
AND      ASM.ORGANIZATION_ID = WIRO.ORGANIZATION_ID
GROUP BY asm.inventory_item_id,
         wiro.DATE_REQUIRED,
         mtl.primary_uom_code;
  l_prod_material_req_rec  get_prod_materials_csr%ROWTYPE;


  -- Define local variables
  l_x_return_status           VARCHAR2(240);
  l_x_item_tbl                AHL_VWP_RULES_PVT.Item_Tbl_Type;

  i                           NUMBER :=0;  -- loop index

  l_api_name       CONSTANT   VARCHAR2(30) := 'Check_Item_for_Prod_Mat_Req';

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
			       'At the start of the procedure');
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
			       'Visit Task ID: '|| p_visit_task_id);

  END IF;

--Initialize API return status to success
  l_x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Get all material requirements for the job

  Open get_prod_materials_csr(p_visit_task_id);

  LOOP
      FETCH get_prod_materials_csr INTO l_prod_material_req_rec;
      EXIT WHEN get_prod_materials_csr%NOTFOUND;

         l_x_item_tbl(I).item_id :=l_prod_material_req_rec.inventory_item_id;
         l_x_item_tbl(I).quantity :=l_prod_material_req_rec.quantity;
         l_x_item_tbl(I).UOM_code :=l_prod_material_req_rec.uom_code;
         l_x_item_tbl(I).effective_date :=l_prod_material_req_rec.requested_date;
         l_x_item_tbl(I).Visit_Task_Id :=p_visit_task_id;

         I := I + 1;

  END LOOP;

  CLOSE get_prod_materials_csr;


-- Assign return status  and  Item without Price table
  x_return_status:=l_x_return_status;
  x_item_tbl:= l_x_item_tbl;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': End API',
			       'Return Status is: '|| x_return_status);
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': End API',
			       'Number of Items for material requirements: '|| x_item_tbl.count);
  END IF;

END Check_Item_for_Prod_Mat_Req;

--------------------------------------------------------------------
--  Procedure name    : Check_Item_for_Prod_Res_Req
--  Purpose           : To return items required for Resource requirements of a given task
--                      when job is not in draft status
--------------------------------------------------------------------
PROCEDURE Check_Item_for_Prod_Res_Req
    (p_visit_task_id        IN NUMBER,

     x_item_tbl             OUT NOCOPY AHL_VWP_RULES_PVT.Item_Tbl_Type,
     x_return_status        OUT NOCOPY VARCHAR2
     )
IS
 -- Define local Cursors

-- Get job resource requirements

  CURSOR get_prod_res_req_csr (c_visit_task_id NUMBER)
  IS
  SELECT sum(NVL(AR.TOTAL_REQUIRED,0)) duration,
--         sum(NVL(AR.quantity,0)) quantity,
--       sum(NVL(AR.TOTAL_REQUIRED,0)) total_quantity,
         BR.BILLABLE_ITEM_ID,
         AR.REQUIRED_START_DATE,
         MSIV.concatenated_segments item_name,
         MSIV.primary_uom_code uom_code
  FROM   AHL_PP_REQUIREMENT_V AR,
         MTL_SYSTEM_ITEMS_VL MSIV,
         AHL_VISITS_B V,
         AHL_VISIT_TASKS_B VT,
         BOM_RESOURCES BR
  WHERE  BR.resource_id=AR.resource_id
  AND    BR.BILLABLE_ITEM_ID is not null
  AND    AR.visit_task_id = c_visit_task_id
  AND    V.visit_id = VT.visit_id
  AND    VT.visit_task_id = c_visit_task_id
  AND    MSIV.inventory_item_id = BR.BILLABLE_ITEM_ID
  AND    MSIV.organization_id = V.organization_id
  AND    AR.JOB_STATUS_CODE <> 22  -- 'deleted' status
  AND    AR.JOB_STATUS_CODE <> 7  -- 'cancelled' status
  Group By BR.BILLABLE_ITEM_ID,
           MSIV.concatenated_segments,
           MSIV.primary_uom_code,
           AR.REQUIRED_START_DATE;

  l_prod_res_req_rec  get_prod_res_req_csr%ROWTYPE;


  -- Define local variables
  l_x_return_status           VARCHAR2(240);
  l_x_item_tbl                AHL_VWP_RULES_PVT.Item_Tbl_Type;

  l_x_time_type_flag          VARCHAR2(1);
  i                           NUMBER :=0;  -- loop index

  l_api_name       CONSTANT   VARCHAR2(30) := 'Check_Item_for_Prod_Res_Req';

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
			       'At the start of the procedure');
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
			       'Visit Task ID: '|| p_visit_task_id);

  END IF;

--Initialize API return status to success
  l_x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Get all material requirements for the job

  Open get_prod_res_req_csr(p_visit_task_id);

  LOOP
      FETCH get_prod_res_req_csr INTO l_prod_res_req_rec;
      EXIT WHEN get_prod_res_req_csr%NOTFOUND;

        -- Verify to see if the Item UOM is of Time type
        Check_UOM_Class
        (p_UOM_code             =>l_prod_res_req_rec.uom_code,
         x_time_type_flag       =>l_x_time_type_flag
        );

        IF l_x_time_type_flag <>'Y' THEN

          Fnd_Message.SET_NAME('AHL','AHL_VWP_WRONG_ITEM_UOM');
          Fnd_Message.SET_TOKEN('INV_ITEM',l_prod_res_req_rec.item_name);
          Fnd_Msg_Pub.ADD;
          CLOSE get_prod_res_req_csr;
          RAISE Fnd_Api.G_EXC_ERROR;

        END IF;

         l_x_item_tbl(I).item_id :=l_prod_res_req_rec.BILLABLE_ITEM_ID;
         l_x_item_tbl(I).quantity :=1;
         l_x_item_tbl(I).duration :=l_prod_res_req_rec.duration;
         l_x_item_tbl(I).UOM_code :=l_prod_res_req_rec.uom_code;
         l_x_item_tbl(I).effective_date :=l_prod_res_req_rec.REQUIRED_START_DATE;
         l_x_item_tbl(I).Visit_Task_Id :=p_visit_task_id;

         I := I + 1;

  END LOOP;

  CLOSE get_prod_res_req_csr;

-- Assign return status  and  Item without Price table
  x_return_status:=l_x_return_status;
  x_item_tbl:= l_x_item_tbl;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': End API',
			       'Return Status is: '|| x_return_status);
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': End API',
			       'Number of Items for resource requirements: '|| x_item_tbl.count);
  END IF;

END Check_Item_for_Prod_Res_Req;


--------------------------------------------------------------------
--  Procedure name    : Check_Item_for_Rt_Mat_Req
--  Purpose           : To return items required for Material requirements of a given task.
--                      when job is in draft status
--------------------------------------------------------------------
PROCEDURE Check_Item_for_Rt_Mat_Req
    (p_visit_task_id        IN NUMBER,
     p_route_id             IN NUMBER,
     p_effective_date       IN DATE,

     x_item_tbl             OUT NOCOPY AHL_VWP_RULES_PVT.Item_Tbl_Type,
     x_return_status        OUT NOCOPY VARCHAR2
     )
IS
 -- Define local Cursors
-- Get route material requirements

  CURSOR get_rt_materials_csr (c_route_id NUMBER, c_visit_task_id NUMBER)
  IS
  SELECT MAT.rt_oper_material_id,
         MAT.inventory_item_id,
         MAT.quantity,
         MSIV.primary_uom_code uom_code
--         MAT.uom_code
  FROM AHL_RT_OPER_MATERIALS MAT,
       AHL_VISITS_B V,
       AHL_VISIT_TASKS_B VT,
       MTL_SYSTEM_ITEMS_VL MSIV
  WHERE  MAT.association_type_code='ROUTE'
  AND  MSIV.organization_id = V.organization_id
  AND  V.visit_id = VT.visit_id
  AND  VT.visit_task_id = c_visit_task_id
  AND  MAT.inventory_item_id = MSIV.inventory_item_id
  AND  MAT.object_id=c_route_id;

  l_rt_material_req_rec  get_rt_materials_csr%ROWTYPE;

-- Get operation material requirements

  CURSOR get_oper_materials_csr (c_route_id NUMBER, c_visit_task_id NUMBER)
  IS
  SELECT MAT.inventory_item_id,
         sum(NVL(MAT.quantity,0)) quantity,
         MSIV.primary_uom_code uom_code
--         MAT.uom_code
  FROM   MTL_SYSTEM_ITEMS_VL MSIV,
         AHL_VISITS_B V,
         AHL_VISIT_TASKS_B VT,
         AHL_RT_OPER_MATERIALS MAT
  WHERE  MAT.association_type_code='OPERATION'
--  AND MAT.inventory_item_id is not null
  AND  MSIV.organization_id = V.organization_id
  AND  V.visit_id = VT.visit_id
  AND  VT.visit_task_id = c_visit_task_id
  AND  MSIV.inventory_item_id = MAT.inventory_item_id
  AND  MAT.object_id in
    (  SELECT   RO.operation_id
       FROM     AHL_OPERATIONS_VL OP,
           AHL_ROUTE_OPERATIONS RO
       WHERE    OP.operation_id=RO.operation_id
       AND      OP.revision_status_code='COMPLETE'
       AND      RO.route_id=c_route_id
       AND      OP.revision_number IN
           ( SELECT MAX(revision_number)
             FROM   AHL_OPERATIONS_B_KFV
             WHERE  concatenated_segments=OP.concatenated_segments
             AND    TRUNC(SYSDATE) BETWEEN TRUNC(start_date_active) AND
                                           TRUNC(NVL(end_date_active,SYSDATE+1))
           )
    )
  Group By MAT.inventory_item_id,
           MSIV.primary_uom_code;
--           MAT.uom_code;

  l_oper_material_req_rec  get_oper_materials_csr%ROWTYPE;

  -- Define local variables
  l_x_return_status           VARCHAR2(240);
  l_x_item_tbl                AHL_VWP_RULES_PVT.Item_Tbl_Type;

  l_route_mat_found           BOOLEAN := FALSE;

  i                           NUMBER :=0;  -- loop index

  l_api_name       CONSTANT   VARCHAR2(30) := 'Check_Item_for_Rt_Mat_Req';

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
			       'At the start of the procedure');
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
			       'Visit Task ID: '|| p_visit_task_id);
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
			       'Route ID: '|| p_route_id);
  END IF;

--Initialize API return status to success
  l_x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Check to see if material requirements are defined at route level

  Open get_rt_materials_csr(p_route_id,p_visit_task_id);

  LOOP
      FETCH get_rt_materials_csr INTO l_rt_material_req_rec;
      EXIT WHEN get_rt_materials_csr%NOTFOUND;

     -- Atleast One Material Requirement defined for the Route
      l_route_mat_found := TRUE;

      -- The Material Requirement is based on an Item
      -- Ignore if requirement is based on item group
      -- Do not consider alternate items

      IF ( l_rt_material_req_rec.inventory_item_id IS NOT NULL ) THEN

         l_x_item_tbl(I).item_id :=l_rt_material_req_rec.inventory_item_id;
         l_x_item_tbl(I).quantity :=l_rt_material_req_rec.quantity;
         l_x_item_tbl(I).UOM_code :=l_rt_material_req_rec.uom_code;
         l_x_item_tbl(I).effective_date :=p_effective_date;
         l_x_item_tbl(I).Visit_Task_Id :=p_visit_task_id;

         IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': In Loop',
			       'Item Quantity: '||I||'...'||l_x_item_tbl(I).quantity );
         END IF;

         I := I + 1;

      End IF;

  END LOOP;

  CLOSE get_rt_materials_csr;

-- If material requirements are not defined at route level
-- Then sum up the requirements for associated operations
 IF ( l_route_mat_found = FALSE ) THEN

   Open get_oper_materials_csr(p_route_id,p_visit_task_id);

   LOOP
      FETCH get_oper_materials_csr INTO l_oper_material_req_rec;
      EXIT WHEN get_oper_materials_csr%NOTFOUND;


      -- The Material Requirement is based on an Item
      -- Ignore if requirement is based on item group
      -- Do not consider alternate items

      IF ( l_oper_material_req_rec.inventory_item_id IS NOT NULL ) THEN

         l_x_item_tbl(I).item_id :=l_oper_material_req_rec.inventory_item_id;
         l_x_item_tbl(I).quantity :=l_oper_material_req_rec.quantity;
         l_x_item_tbl(I).UOM_code :=l_oper_material_req_rec.uom_code;
         l_x_item_tbl(I).effective_date :=p_effective_date;
         l_x_item_tbl(I).Visit_Task_Id :=p_visit_task_id;

         IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                    'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': In Loop',
			       'Item Quantity: '||I||'...'||l_x_item_tbl(I).quantity );
         END IF;

         I := I + 1;

      End IF;

   END LOOP;

   CLOSE get_oper_materials_csr;

 END IF;

-- Assign return status  and  Item without Price table
  x_return_status:=l_x_return_status;
  x_item_tbl:= l_x_item_tbl;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': End API',
			       'Return Status is: '|| x_return_status);
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': End API',
			       'Number of Items for material requirements: '|| x_item_tbl.count);
  END IF;


END Check_Item_for_Rt_Mat_Req;

--------------------------------------------------------------------
--  Procedure name    : Check_Item_for_Rt_Res_Req
--  Purpose           : To return items required for Resource requirements of a given task
--                      when job is in draft status
--------------------------------------------------------------------
PROCEDURE Check_Item_for_Rt_Res_Req
    (p_visit_task_id        IN NUMBER,
     p_route_id             IN NUMBER,
     p_organization_id      IN NUMBER,
     p_effective_date       IN DATE,

     x_item_tbl             OUT NOCOPY AHL_VWP_RULES_PVT.Item_Tbl_Type,
     x_return_status        OUT NOCOPY VARCHAR2
     )
IS
 -- Define local Cursors
  -- For checking if Resource Requirements are defined for Route
  CURSOR check_rt_resources_csr(c_route_id NUMBER)
  IS
  SELECT AR.rt_oper_resource_id
  FROM   AHL_RT_OPER_RESOURCES AR
  WHERE  AR.association_type_code='ROUTE'
  AND    AR.object_id=c_route_id;

  -- Bug # : 5532390, regression issues caused by fix for bug number 5258334
  --
  -- For Getting the BOM Resource for the ASO Resource and the Visit's
  -- Organization. Merge rows with same item defined.
  CURSOR get_rt_resources_csr(c_route_id NUMBER,
                          c_org_id NUMBER)
  IS
SELECT sum(NVL(AR.duration,0)* NVL(AR.quantity,0)) duration,
         BR.BILLABLE_ITEM_ID,
         MSIV.concatenated_segments item_name,
         MSIV.primary_uom_code uom_code
  FROM   AHL_RT_OPER_RESOURCES AR,
         BOM_RESOURCES BR,
         MTL_SYSTEM_ITEMS_VL MSIV,
         AHL_RESOURCE_MAPPINGS MAP
  WHERE  AR.association_type_code='ROUTE'
  AND    BR.resource_id=MAP.bom_resource_id
  AND    AR.object_id=c_route_id
  AND    BR.organization_id=c_org_id
  AND    MAP.aso_resource_id=AR.aso_resource_id
  AND    BR.BILLABLE_ITEM_ID is not null
  AND    MSIV.organization_id = c_org_id
  AND    MSIV.inventory_item_id = BR.BILLABLE_ITEM_ID
  Group By BR.BILLABLE_ITEM_ID,
           MSIV.concatenated_segments,
           MSIV.primary_uom_code;

  l_rt_resource_rec  get_rt_resources_csr%ROWTYPE;


-- Get operation material requirements
-- Bug # : 5532390, regression issues caused by fix for bug number 5258334
  CURSOR get_oper_resources_csr (c_route_id NUMBER,c_org_id NUMBER)
  IS
  /*  SELECT sum(NVL(AR.duration,0)* NVL(AR.quantity,0)) duration,
         MSIV.primary_uom_code uom_code,
         MSIV.concatenated_segments item_name,
         BR.BILLABLE_ITEM_ID
  FROM   AHL_RT_OPER_RESOURCES AR,
         BOM_RESOURCES BR,
         MTL_SYSTEM_ITEMS_VL MSIV,
         AHL_RESOURCE_MAPPINGS MAP
  WHERE  AR.association_type_code='OPERATION'
  AND    BR.resource_id=MAP.bom_resource_id
  AND    BR.organization_id=c_org_id
  AND    MAP.aso_resource_id=AR.aso_resource_id
  AND    BR.BILLABLE_ITEM_ID is not null
  AND    MSIV.inventory_item_id = BR.BILLABLE_ITEM_ID
  AND    MSIV.organization_id = c_org_id
  AND  AR.object_id in
    (  SELECT   RO.operation_id
       FROM     AHL_OPERATIONS_VL OP,
           AHL_ROUTE_OPERATIONS RO
       WHERE    OP.operation_id=RO.operation_id
       AND      OP.revision_status_code='COMPLETE'
       AND      RO.route_id=c_route_id
       AND      OP.revision_number IN
           ( SELECT MAX(revision_number)
             FROM   AHL_OPERATIONS_B_KFV
             WHERE  concatenated_segments=OP.concatenated_segments
             AND    TRUNC(SYSDATE) BETWEEN TRUNC(start_date_active) AND
                                           TRUNC(NVL(end_date_active,SYSDATE+1))
           )
    )
  Group By BR.BILLABLE_ITEM_ID,
           MSIV.concatenated_segments,
           MSIV.primary_uom_code;
*/
   select   sum(nvl(ar.duration,0)* nvl(ar.quantity,0)) duration,
            msiv.primary_uom_code uom_code,
            msiv.concatenated_segments item_name,
            br.billable_item_id
   from     ahl_rt_oper_resources ar,
            bom_resources br,
            mtl_system_items_kfv msiv,
            ahl_resource_mappings map
   where    ar.association_type_code='OPERATION'
   and      br.resource_id=map.bom_resource_id
   and      br.organization_id=c_org_id
   and      map.aso_resource_id=ar.aso_resource_id
   and      br.billable_item_id is not null
   and      msiv.inventory_item_id = br.billable_item_id
   and      msiv.organization_id = c_org_id
   and      ar.object_id in
               (  select   ro.operation_id
                  from     ahl_operations_b_kfv op,
                           ahl_route_operations ro
                  where    op.operation_id=ro.operation_id
                  and      op.revision_status_code='COMPLETE'
                  and      ro.route_id=c_route_id
                  and      op.revision_number in
                              (  select   max(revision_number)
                                 from     ahl_operations_b_kfv
                                 where    concatenated_segments=op.concatenated_segments
                                 and      trunc(sysdate) between trunc(start_date_active)
                                 and      trunc(nvl(end_date_active,sysdate+1))
                              )
               )
   group by    br.billable_item_id,
               msiv.concatenated_segments,
               msiv.primary_uom_code;

  l_oper_resource_req_rec  get_oper_resources_csr%ROWTYPE;

  -- Define local variables
  l_x_return_status           VARCHAR2(240);
  l_x_item_tbl                AHL_VWP_RULES_PVT.Item_Tbl_Type;
  l_x_time_type_flag          VARCHAR2(1);

  l_rt_resource_id            NUMBER;

  i                           NUMBER :=0;  -- loop index

  l_api_name       CONSTANT   VARCHAR2(30) := 'Check_Item_for_Rt_Res_Req';

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
			       'At the start of the procedure');
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
			       'Visit Task ID: '|| p_visit_task_id);
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
			       'Route ID: '|| p_route_id);
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
			       'Organization ID: '|| p_organization_id);
  END IF;

--Initialize API return status to success
  l_x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Check to see if resource requirements are defined at route level

  Open check_rt_resources_csr(p_route_id);

  FETCH check_rt_resources_csr INTO l_rt_resource_id;

  IF check_rt_resources_csr%NOTFOUND THEN  -- no resource requirements defined for route

    Open get_oper_resources_csr(p_route_id,p_organization_id);

    LOOP
      FETCH get_oper_resources_csr INTO l_oper_resource_req_rec;
      EXIT WHEN get_oper_resources_csr%NOTFOUND;

      -- The Material Requirement is based on an Item
      -- Ignore if requirement is based on item group
      -- Do not consider alternate items

      IF ( l_oper_resource_req_rec.BILLABLE_ITEM_ID IS NOT NULL ) AND
        ( l_oper_resource_req_rec.uom_code IS NOT NULL )  THEN

        -- Verify to see if the Item UOM is of Time type
        Check_UOM_Class
        (p_UOM_code             =>l_oper_resource_req_rec.uom_code,
         x_time_type_flag       =>l_x_time_type_flag
        );

        IF l_x_time_type_flag <>'Y' THEN

          Fnd_Message.SET_NAME('AHL','AHL_VWP_WRONG_ITEM_UOM');
          Fnd_Message.SET_TOKEN('INV_ITEM',l_oper_resource_req_rec.item_name);
          Fnd_Msg_Pub.ADD;
          CLOSE get_oper_resources_csr;
          CLOSE check_rt_resources_csr;
          RAISE Fnd_Api.G_EXC_ERROR;

        END IF;

         l_x_item_tbl(I).item_id :=l_oper_resource_req_rec.BILLABLE_ITEM_ID;
         l_x_item_tbl(I).quantity :=1;
         l_x_item_tbl(I).duration :=l_oper_resource_req_rec.duration;
         l_x_item_tbl(I).UOM_code :=l_oper_resource_req_rec.uom_code;
         l_x_item_tbl(I).effective_date :=p_effective_date;
         l_x_item_tbl(I).Visit_Task_Id :=p_visit_task_id;

         I := I + 1;
      End IF;

    END LOOP;

    CLOSE get_oper_resources_csr;

  ELSE      ---- resource requirements are defined for route

     Open get_rt_resources_csr(p_route_id,p_organization_id);

     LOOP
      FETCH get_rt_resources_csr INTO l_rt_resource_rec;
      EXIT WHEN get_rt_resources_csr%NOTFOUND;

      -- The Material Requirement is based on an Item
      -- Ignore if requirement is based on item group
      -- Do not consider alternate items

      IF ( l_rt_resource_rec.BILLABLE_ITEM_ID IS NOT NULL ) AND
        ( l_rt_resource_rec.uom_code IS NOT NULL )  THEN

        -- Verify to see if the Item UOM is of Time type
        Check_UOM_Class
        (p_UOM_code             =>l_rt_resource_rec.uom_code,
         x_time_type_flag       =>l_x_time_type_flag
        );

        IF l_x_time_type_flag <>'Y' THEN

          Fnd_Message.SET_NAME('AHL','AHL_VWP_WRONG_ITEM_UOM');
          Fnd_Message.SET_TOKEN('INV_ITEM',l_rt_resource_rec.item_name);
          Fnd_Msg_Pub.ADD;
          CLOSE get_rt_resources_csr;
          CLOSE check_rt_resources_csr;
          RAISE Fnd_Api.G_EXC_ERROR;

        END IF;

         l_x_item_tbl(I).item_id :=l_rt_resource_rec.BILLABLE_ITEM_ID;
         l_x_item_tbl(I).quantity :=1;
         l_x_item_tbl(I).duration :=l_rt_resource_rec.duration;
         l_x_item_tbl(I).UOM_code :=l_rt_resource_rec.uom_code;
         l_x_item_tbl(I).effective_date :=p_effective_date;
         l_x_item_tbl(I).Visit_Task_Id :=p_visit_task_id;

         I := I + 1;
      End IF;

    END LOOP;

    CLOSE get_rt_resources_csr;

  END IF;

  CLOSE check_rt_resources_csr;


-- Assign return status  and  Item without Price table
  x_return_status:=l_x_return_status;
  x_item_tbl:= l_x_item_tbl;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': End API',
			       'Return Status is: '|| x_return_status);
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': End API',
			       'Number of Items for resource requirements: '|| x_item_tbl.count);
  END IF;

END Check_Item_for_Rt_Res_Req;


--------------------------------------------------------------------
--  Procedure name    : Check_Item_for_Resource_Trans
--  Purpose           : To return items required for Resource transactions of a given task.
--------------------------------------------------------------------
PROCEDURE Check_Item_for_Resource_Trans
    (p_visit_task_id        IN NUMBER,

     x_item_tbl             OUT NOCOPY AHL_VWP_RULES_PVT.Item_Tbl_Type,
     x_return_status        OUT NOCOPY VARCHAR2
     )
IS
 -- Define local Cursors

-- Get job resource requirements

  CURSOR get_resource_trans_csr (c_visit_task_id NUMBER)
  IS
  SELECT sum(NVL(AR.USAGE_RATE_OR_AMOUNT,0)) duration,
       --sum(NVL(AR.QUANTITY,0)) quantity,
--         AR.primary_uom uom_code,
         BR.BILLABLE_ITEM_ID,
         AR.TRANSACTION_DATE,
         MSIV.concatenated_segments item_name,
         MSIV.primary_uom_code uom_code
  FROM   AHL_WIP_RESOURCE_TXNS_V AR,
         MTL_SYSTEM_ITEMS_VL MSIV,
         AHL_VISITS_B V,
         AHL_VISIT_TASKS_B VT,
         BOM_RESOURCES BR
  WHERE  BR.resource_id=AR.resource_id
  AND    BR.BILLABLE_ITEM_ID is not null
  AND    AR.visit_task_id = c_visit_task_id
  AND    MSIV.organization_id = V.organization_id
  AND    V.visit_id = VT.visit_id
  AND    VT.visit_task_id = c_visit_task_id
  AND    MSIV.inventory_item_id = BR.BILLABLE_ITEM_ID
  AND    AR.JOB_STATUS_CODE <> 22  -- 'deleted' status
  AND    AR.JOB_STATUS_CODE <> 7  -- 'cancelled' status
  Group By BR.BILLABLE_ITEM_ID,
           MSIV.concatenated_segments,
           MSIV.primary_uom_code,
           AR.TRANSACTION_DATE;

  l_resource_trans_rec  get_resource_trans_csr%ROWTYPE;


  -- Define local variables
  l_x_return_status           VARCHAR2(240);
  l_x_item_tbl                AHL_VWP_RULES_PVT.Item_Tbl_Type;

  l_x_time_type_flag          VARCHAR2(1);
  i                           NUMBER :=0;  -- loop index

  l_api_name       CONSTANT   VARCHAR2(30) := 'Check_Item_for_Resource_Trans';

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
			       'At the start of the procedure');
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
			       'Visit Task ID: '|| p_visit_task_id);

  END IF;

--Initialize API return status to success
  l_x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Get all material requirements for the job

  Open get_resource_trans_csr(p_visit_task_id);

  LOOP
      FETCH get_resource_trans_csr INTO l_resource_trans_rec;
      EXIT WHEN get_resource_trans_csr%NOTFOUND;

         l_x_item_tbl(I).item_id :=l_resource_trans_rec.BILLABLE_ITEM_ID;
         l_x_item_tbl(I).quantity :=1;
         l_x_item_tbl(I).duration :=l_resource_trans_rec.duration;
         l_x_item_tbl(I).UOM_code :=l_resource_trans_rec.uom_code;
         l_x_item_tbl(I).effective_date :=l_resource_trans_rec.TRANSACTION_DATE;
         l_x_item_tbl(I).Visit_Task_Id :=p_visit_task_id;

         I := I + 1;

  END LOOP;

  CLOSE get_resource_trans_csr;

-- Assign return status  and  Item without Price table
  x_return_status:=l_x_return_status;
  x_item_tbl:= l_x_item_tbl;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': End API',
			       'Return Status is: '|| x_return_status);
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': End API',
			       'Number of Items for resource transactions: '|| x_item_tbl.count);
  END IF;

END Check_Item_for_Resource_Trans;

--------------------------------------------------------------------
--  Procedure name    : Check_Item_for_Material_Trans
--  Purpose           : To return items required for Mateiral transactions of a given task.
--------------------------------------------------------------------
PROCEDURE Check_Item_for_Materials_Trans
    (p_visit_task_id        IN NUMBER,

     x_item_tbl             OUT NOCOPY AHL_VWP_RULES_PVT.Item_Tbl_Type,
     x_return_status        OUT NOCOPY VARCHAR2
     )
IS
 -- Define local Cursors

-- Get job material requirements

  CURSOR get_materials_trans_csr (c_visit_task_id NUMBER)
  IS
/*
SELECT MAT.inventory_item_id,
         MAT.creation_date,
         SUM(NVL(MAT.quantity,0)) quantity,
         MSIV.primary_uom_code uom_code
 --        MAT.uom uom_code
  FROM AHL_WORKORDER_MTL_TXNS MAT,
       AHL_WORKORDERS_V AWOS,
       MTL_SYSTEM_ITEMS_VL MSIV,
       AHL_VISITS_B V,
       AHL_VISIT_TASKS_B VT,
       AHL_WORKORDER_OPERATIONS_V AWOP
  WHERE AWOP.WORKORDER_ID = AWOS.WORKORDER_ID
  AND  AWOP.WORKORDER_OPERATION_ID = MAT.WORKORDER_OPERATION_ID
  AND  MAT.inventory_item_id = MSIV.inventory_item_id
  AND  MSIV.organization_id = V.organization_id
  AND  V.visit_id = VT.visit_id
  AND  VT.visit_task_id = c_visit_task_id
  AND  AWOS.visit_task_id = c_visit_task_id
  AND  AWOS.job_status_code <> 22  -- 'deleted' status
  AND  AWOS.JOB_STATUS_CODE <> 7  -- 'cancelled' status
  GROUP BY MAT.inventory_item_id,
         MAT.creation_date,
         MSIV.primary_uom_code;
--         MAT.uom;
*/
-- AnRaj: Changed query for fixing the perf issue #1, bug:4919487
SELECT   MAT.inventory_item_id,
         MAT.creation_date,
         SUM(NVL(MAT.quantity,0)) quantity,
         MSIV.primary_uom_code uom_code
FROM     AHL_WORKORDER_MTL_TXNS MAT,
         AHL_WORKORDERS AWOS,
         MTL_SYSTEM_ITEMS_B MSIV,
         AHL_VISITS_B V,
         AHL_VISIT_TASKS_B VT,
         AHL_WORKORDER_OPERATIONS_V AWOP
WHERE    AWOP.WORKORDER_ID = AWOS.WORKORDER_ID
AND      AWOP.WORKORDER_OPERATION_ID = MAT.WORKORDER_OPERATION_ID
AND      MAT.inventory_item_id = MSIV.inventory_item_id
AND      MSIV.organization_id = V.organization_id
AND      V.visit_id = VT.visit_id
AND      VT.visit_task_id = c_visit_task_id
AND      AWOS.visit_task_id = c_visit_task_id
AND      AWOS.status_code <> 22  -- 'deleted' status
AND      AWOS.STATUS_CODE <> 7  -- 'cancelled' status
GROUP BY MAT.inventory_item_id,
         MAT.creation_date,
         MSIV.primary_uom_code;

l_materials_trans_rec  get_materials_trans_csr%ROWTYPE;


  -- Define local variables
  l_x_return_status           VARCHAR2(240);
  l_x_item_tbl                AHL_VWP_RULES_PVT.Item_Tbl_Type;

  i                           NUMBER :=0;  -- loop index

  l_api_name       CONSTANT   VARCHAR2(30) := 'Check_Item_for_Prod_Mat_Req';

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
			       'At the start of the procedure');
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
			       'Visit Task ID: '|| p_visit_task_id);

  END IF;

--Initialize API return status to success
  l_x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Get all material requirements for the job

  Open get_materials_trans_csr(p_visit_task_id);

  LOOP
      FETCH get_materials_trans_csr INTO l_materials_trans_rec;
      EXIT WHEN get_materials_trans_csr%NOTFOUND;

         l_x_item_tbl(I).item_id :=l_materials_trans_rec.inventory_item_id;
         l_x_item_tbl(I).quantity :=l_materials_trans_rec.quantity;
         l_x_item_tbl(I).UOM_code :=l_materials_trans_rec.uom_code;
         l_x_item_tbl(I).effective_date :=l_materials_trans_rec.creation_date;
         l_x_item_tbl(I).Visit_Task_Id :=p_visit_task_id;

         I := I + 1;

  END LOOP;

  CLOSE get_materials_trans_csr;


-- Assign return status  and  Item without Price table
  x_return_status:=l_x_return_status;
  x_item_tbl:= l_x_item_tbl;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': End API',
			       'Return Status is: '|| x_return_status);
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': End API',
			       'Number of Items for material transactions: '|| x_item_tbl.count);
  END IF;

END Check_Item_for_Materials_Trans;


--------------------------------------------------------------------
--  Procedure name    : Calculate_Total_Price
--  Purpose           : To return total price of the item table with quantity.
--------------------------------------------------------------------
PROCEDURE Calculate_Total_Price
    (p_item_tbl             IN AHL_VWP_RULES_PVT.Item_Tbl_Type,
     p_price_list_id        IN NUMBER,
     p_customer_id          IN NUMBER,
     p_currency_code        IN VARCHAR2,

     x_total_price          OUT NOCOPY NUMBER,
     x_return_status        OUT NOCOPY VARCHAR2
     )
IS
  -- Define local variables
  l_x_return_status           VARCHAR2(240);
  l_x_item_price              NUMBER := 0;
  i                      NUMBER := 0;   -- table index
  l_total_price          NUMBER := 0;   -- total price
  l_api_name       CONSTANT   VARCHAR2(30) := 'Calculate_Total_Price';


BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
			       'At the start of the procedure');
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': End API',
			       'Number of Items to calculate: '|| p_item_tbl.count);
  END IF;

--Initialize API return status to success
  l_x_return_status := FND_API.G_RET_STS_SUCCESS;

-- For each item in p_item_tbl, check for price

I := p_item_tbl.FIRST;
IF I IS NOT NULL THEN
 LOOP

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': In Loop',
			       'Loop Index: '||I );
  END IF;

-- Check the price of the item
  Get_Item_Price
    (p_item_id              =>p_item_tbl(I).Item_Id ,
     p_price_list_id        =>p_price_list_id ,
     p_customer_id          =>p_customer_id ,
     p_duration             =>p_item_tbl(I).Duration ,
     p_currency_code        =>p_currency_code ,
     p_effective_date       =>p_item_tbl(I).Effective_Date ,
     p_UOM_code             =>p_item_tbl(I).UOM_Code ,

     x_item_price           =>l_x_item_price ,
     x_return_status        =>l_x_return_status
     );

 -- Multiply the item price with quantity
 -- And add the result to total price
 -- Consider the item price as 0 if item is not set up in price list
  IF (l_x_item_price IS NOT NULL) THEN

     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': In Loop',
			       'Item Quantity: '||p_item_tbl(I).quantity );
     END IF;

     l_total_price  := l_total_price + l_x_item_price * p_item_tbl(I).quantity;

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': In Loop',
			       'Current Total Price: '||l_total_price );
     END IF;
  END IF;

  EXIT WHEN I = p_item_tbl.LAST;
  I := p_item_tbl.NEXT(I);
 END LOOP;
END IF;

-- Assign return status  and  Item without Price table
  x_return_status:=l_x_return_status;
  x_total_price := l_total_price;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': End API',
			       'Return Status is: '|| x_return_status);
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': End API',
			       'Total Price: '|| x_total_price);
  END IF;
END Calculate_Total_Price;


--------------------------------------------------------------------
--  Procedure name    : Check_UOM_Class
--  Purpose           : To check if the Item UOM is of type TIME.
--------------------------------------------------------------------

PROCEDURE Check_UOM_Class
    (p_UOM_code             IN VARCHAR2,
     x_time_type_flag       OUT NOCOPY VARCHAR2
     )
IS
 -- Define local Cursors

-- Get job material requirements

  CURSOR get_uom_csr (c_UOM_code VARCHAR2)
  IS
  SELECT UOM_CODE
  FROM mtl_units_of_measure_vl
  WHERE UOM_CLASS = 'Time'
  AND UOM_CODE = c_UOM_code;

  -- Define local variables
  l_UOM_code                  VARCHAR2(3);

  l_api_name       CONSTANT   VARCHAR2(30) := 'Check_UOM_Class';

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
			       'At the start of the procedure');
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
			       'UOM Code: '|| p_UOM_code);

  END IF;

-- Check to see if the uom code passed in is of Time type

  Open get_uom_csr(p_UOM_code);

  FETCH get_uom_csr INTO l_UOM_code;

  IF get_uom_csr%NOTFOUND THEN
        x_time_type_flag := 'N';
  ELSE
        x_time_type_flag := 'Y';
  END IF;

  CLOSE get_uom_csr;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': End API',
			       'Time Type flag is: '|| x_time_type_flag);
  END IF;

END Check_UOM_Class;


END AHL_VWP_PRICE_PVT;


/
