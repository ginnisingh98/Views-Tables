--------------------------------------------------------
--  DDL for Package Body AHL_VWP_TASK_CST_PR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_VWP_TASK_CST_PR_PVT" AS
/* $Header: AHLVTCPB.pls 120.7 2006/05/24 13:14:53 anraj noship $ */
-----------------------------------------------------------
-- PACKAGE
--    Ahl_VWP_TASK_CST_PR_PVT
--
-- PURPOSE
--    This package is a Private API to process Estimating Cost and Price
--    for a Task It contains specification for pl/sql records and tables
--
--
-- NOTES
--
--
-- HISTORY
-- 25-AUG-2003    SSURAPAN      Created.
--
--
-- PROCEDURES
--       get_task_cost_details   -- update_task_cost_details
--       estimate_task_cost      -- estimate_task_price
--       get_task_items_no_price
--       GET_OTHER_TASK_ITEMS    -- GET_UNASSOCIATED_ITEMS

-----------------------------------------------------------
-- Declare Constants --
-----------------------------------------------------------
 G_PKG_NAME         CONSTANT  VARCHAR(30) := 'AHL_VWP_TASK_CST_PR_PVT';
 G_APP_NAME         CONSTANT  VARCHAR2(3) := 'AHL';
 G_DEBUG            VARCHAR2(1)  := AHL_DEBUG_PUB.is_log_enabled;

PROCEDURE GET_OTHER_TASK_ITEMS (
    p_api_version            IN            NUMBER,
    p_init_msg_list          IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_module_type            IN             VARCHAR2  := NULL,
    x_return_status             OUT NOCOPY        VARCHAR2,
    x_msg_count                 OUT NOCOPY        NUMBER,
    x_msg_data                  OUT NOCOPY        VARCHAR2,
    p_visit_task_id          IN             NUMBER,
    p_job_status_code        IN             VARCHAR2,
    p_task_start_time        IN             DATE,
    x_item_tbl               OUT   NOCOPY   AHL_VWP_RULES_PVT.ITEM_TBL_TYPE
   );


PROCEDURE GET_UNASSOCIATED_ITEMS (
    p_api_version            IN            NUMBER,
    p_init_msg_list          IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_module_type            IN            VARCHAR2  := NULL,
    x_return_status             OUT NOCOPY        VARCHAR2,
    x_msg_count                 OUT NOCOPY        NUMBER,
    x_msg_data                  OUT NOCOPY        VARCHAR2,
    p_visit_task_id          IN            NUMBER,
    p_job_status_code        IN            VARCHAR2,
    x_item_tbl               OUT   NOCOPY   AHL_VWP_RULES_PVT.ITEM_TBL_TYPE
    );

--
-- Start of Comments --
--  Procedure name    : Get_Task_Cost_Details
--  Type              : Private(Called from Estimate and cost/price Task UI
--
--  Function          :
--
--
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Get Task Cost Details Parameters:
--       p_x_cost_price_rec     IN OUT NOCOPY AHL_VWP_VISIT_CST_PR_PVT.Cost_Price_Rec_Type,
--         Contains Cost/Price infor mation relates to Vist and its Task
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE Get_Task_Cost_Details (
    p_api_version            IN            NUMBER,
    p_init_msg_list          IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_module_type            IN            VARCHAR2  := NULL,
    p_x_cost_price_rec       IN OUT NOCOPY AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type,
    x_return_status             OUT NOCOPY        VARCHAR2,
    x_msg_count                 OUT NOCOPY        NUMBER,
    x_msg_data                  OUT NOCOPY        VARCHAR2
  )
  IS
  l_visit_status          VARCHAR2(30);

-- Define Local Cursors
    CURSOR visit_info_csr(p_visit_id IN NUMBER) IS
    SELECT status_code
    FROM ahl_visits_b
    WHERE visit_id = p_visit_id;

   --Cursor to retrieve Costs associated to Task
   CURSOR Get_task_cost_price_cur (C_VISIT_TASK_ID IN NUMBER)
   IS
   SELECT vt.visit_id,
          vt.visit_task_id,
		  vt.estimated_price,
		  vt.actual_price,
          vt.price_list_id,
		  vt.mr_route_id,
		  vt.mr_id,
		  vs.outside_party_flag,
          vs.start_date_time,
          vs.close_date_time,
   		  ci.customer_id

   FROM ahl_visit_tasks_b vt,
        ahl_visits_b vs,
		cs_incidents_all_b ci

   WHERE vt.visit_task_id = C_VISIT_TASK_ID
   AND   vt.visit_id=vs.visit_id
   AND   vs.service_request_id = ci.incident_id(+)
   AND   NVL(vt.status_code, 'Y') <> NVL ('DELETED', 'X');


   --Cursor to retrieve name for defined price list id
   CURSOR Get_price_list_name_cur (C_LIST_HEADER_ID IN NUMBER)
   IS
    SELECT name
     FROM qp_list_headers
	WHERE list_header_id = C_LIST_HEADER_ID;

-- AnRaj: Query changed for fixing performance bug 4919475
   -- Get Billing item id for the associated mr
/*	  SELECT mh.billing_item_id,mh.billing_item, mh.title
	    FROM ahl_mr_routes_v mr, ahl_mr_headers_v mh
	   WHERE mr.mr_header_id = mh.mr_header_id
	     AND mr.mr_header_id =C_MR_ID;*/
    CURSOR Get_billing_item_cur (C_MR_ID IN NUMBER)
    IS
         SELECT   mh.billing_item_id,mtl.CONCATENATED_SEGMENTS billing_item, mh.title
         FROM     ahl_mr_routes_v mr, AHL_MR_HEADERS_VL mh,MTL_SYSTEM_ITEMS_KFV mtl
         WHERE    mr.mr_header_id = mh.mr_header_id
         AND      mtl.INVENTORY_ITEM_ID= MH.BILLING_ITEM_ID
         AND      mr.mr_header_id = C_MR_ID
         AND      mh.APPLICATION_USG_CODE=RTRIM(LTRIM(FND_PROFILE.VALUE('AHL_APPLN_USAGE'))) ;


--Added by amagrawa to retrieve task number from Task ID
    CURSOR c_task_number (p_task_id IN NUMBER)
				IS
				 SELECT VISIT_TASK_NUMBER
					FROM ahl_visit_tasks_b
					where visit_task_id = p_task_id;

    --Standard local variables
				l_task_number number;
    l_api_name	    CONSTANT	VARCHAR2(30)	:= 'Get_Task_Cost_Details';
    l_api_version	CONSTANT	NUMBER		    := 1.0;

    l_msg_data             VARCHAR2(2000);
    l_return_status        VARCHAR2(1);
    l_msg_count            NUMBER;

    l_default              VARCHAR2(30);
    l_error_msg_code       VARCHAR2(30);
	l_module_type          VARCHAR2(10);
  	l_found                VARCHAR2(1);
    l_valid_flag           VARCHAR2(1);
    l_commit               VARCHAR2(10)  := Fnd_Api.G_FALSE;

    l_wo_actual_cost       NUMBER;
    l_wo_estimated_cost	   NUMBER;
  	l_idx                  NUMBER;
    j                      NUMBER := 0;

	l_task_cost_price_rec     Get_task_cost_price_cur%ROWTYPE;
	l_cost_price_rec          AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type := p_x_cost_price_rec;

 BEGIN
   --
     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.Get_Task_Cost_Details.begin',
			'At the start of PLSQL procedure'
		);
     END IF;

     -- Standard start of API savepoint
     SAVEPOINT Get_Task_Cost_Details;

     -- Initialize message list if p_init_msg_list is set to TRUE
     IF FND_API.To_Boolean( p_init_msg_list) THEN
        FND_MSG_PUB.Initialize;
     END IF;

     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     --
     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			'Request for cost details of Visit Task ID : ' || l_cost_price_rec.visit_task_id
		);
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			'Request for task cost details of Cost Session ID : ' || l_cost_price_rec.cost_session_id
		);
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			'Request for task cost details of MR Session ID : ' || l_cost_price_rec.mr_session_id
		);
     END IF;

     -- Check for Required Parameters
     IF(l_cost_price_rec.visit_task_id IS NULL OR
	    l_cost_price_rec.visit_task_id = FND_API.G_MISS_NUM) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_INPUT_MISS');
        FND_MSG_PUB.ADD;
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		    fnd_log.string
		    (
			    fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			    'Visit Task id is mandatory but found null in input '
		    );
        END IF;
        RAISE FND_API.G_EXC_ERROR;
     END IF;

    -- Get Cost and Price associated to task
    OPEN Get_task_cost_price_cur(p_x_cost_price_rec.visit_task_id);
	FETCH Get_task_cost_price_cur INTO l_task_cost_price_rec;
	IF Get_task_cost_price_cur%NOTFOUND THEN
	--Added by amagrawa
	       OPEN c_task_number(p_x_cost_price_rec.visit_task_id);
								FETCH c_task_number into l_task_number;
								close c_task_number;
		--End of changes by amagrawa
        FND_MESSAGE.set_name( 'AHL','AHL_VWP_TASK_INVALID' );
								FND_MESSAGE.SET_TOKEN('TASK_NUM',l_task_number);
        FND_MSG_PUB.add;
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		    fnd_log.string
		    (
			    fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			    'Visit Task not found in ahl_visit_tasks_b table'
		    );
        END IF;
    CLOSE Get_task_cost_price_cur;
    RAISE  FND_API.G_EXC_ERROR;
    END IF;
	CLOSE Get_task_cost_price_cur;

	-- Assign values to out variable
	l_cost_price_rec.ACTUAL_PRICE       := l_task_cost_price_rec.actual_price;
	l_cost_price_rec.ESTIMATED_PRICE    := l_task_cost_price_rec.estimated_price;
	l_cost_price_rec.PRICE_LIST_ID      := l_task_cost_price_rec.price_list_id;
	l_cost_price_rec.VISIT_ID           := l_task_cost_price_rec.visit_id;
	l_cost_price_rec.OUTSIDE_PARTY_FLAG := l_task_cost_price_rec.outside_party_flag;
	l_cost_price_rec.CUSTOMER_ID        := l_task_cost_price_rec.customer_id;
	l_cost_price_rec.MR_ID        	    := l_task_cost_price_rec.mr_id;
    -- Both task dates are visit's start date and planned end dates
    l_cost_price_rec.task_start_date    := l_task_cost_price_rec.start_date_time;
    l_cost_price_rec.task_end_date      := l_task_cost_price_rec.close_date_time;

    --log messages
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
       fnd_log.string
	    (
		    fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
		    'Actual Price : '||l_cost_price_rec.ACTUAL_PRICE
	    );
       fnd_log.string
	    (
		    fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
		    'Estimated Price : '||l_cost_price_rec.ESTIMATED_PRICE
	    );
       fnd_log.string
	    (
		    fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
		    'Price List Id: '||l_cost_price_rec.PRICE_LIST_ID
	    );
       fnd_log.string
	    (
		    fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
		    'Visit Id : '||l_cost_price_rec.VISIT_ID
	    );
       fnd_log.string
	    (
		    fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
		    'Outside Party Flag : '||l_cost_price_rec.OUTSIDE_PARTY_FLAG
	    );
       fnd_log.string
	    (
		    fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
		    'Customer Id: '||l_cost_price_rec.CUSTOMER_ID
	    );
       fnd_log.string
	    (
		    fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
		    'MR Route Id: '||l_task_cost_price_rec.mr_route_id
	    );
    END IF;


	--Get Price list name from qp_list_headers table
    IF l_task_cost_price_rec.price_list_id IS NOT NULL THEN
	--
        OPEN Get_price_list_name_cur(l_task_cost_price_rec.price_list_id);
    	FETCH Get_price_list_name_cur INTO l_cost_price_rec.price_list_name;
	       IF Get_price_list_name_cur%NOTFOUND THEN
                FND_MESSAGE.set_name( 'AHL','AHL_VWP_PRICE_LIST_INVALID' );
                FND_MSG_PUB.add;
                    IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		              fnd_log.string
        		        (
		          	    fnd_log.level_error,
                        'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
		          	    'Price List Name not found in qp_list_headers table'
            		    );
                    END IF;
                CLOSE Get_price_list_name_cur;
                RAISE  FND_API.G_EXC_ERROR;
        END IF;
        CLOSE Get_price_list_name_cur;

	END IF; -- Price list not null

	--Log messages
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
       fnd_log.string
	    (
		    fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
		    'Price List Name from QP_LIST_HEADERS: '||l_cost_price_rec.price_list_name
	    );
       fnd_log.string
	    (
		    fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
		    'Mr Route Id : '||l_task_cost_price_rec.MR_ROUTE_ID
	    );
   END IF;

    -- Get billing item id
	IF (l_task_cost_price_rec.mr_id IS NOT NULL AND
	    l_task_cost_price_rec.mr_id <> FND_API.G_MISS_NUM ) THEN
	   -- Retrieve billing item
	   OPEN Get_billing_item_cur(l_task_cost_price_rec.mr_id);
	   FETCH Get_billing_item_cur INTO l_cost_price_rec.billing_item_id,l_cost_price_rec.item_name,l_cost_price_rec.mr_title;
	   CLOSE Get_billing_item_cur;
	END IF;   --Mr route id not null

	--Log messages
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
       fnd_log.string
	    (
		    fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
		    'Billing Item Id : '||l_cost_price_rec.billing_item_id
	    );
       fnd_log.string
	    (
		    fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
		    'Is Cst Pr Info Required flag : '||l_cost_price_rec.Is_Cst_Pr_Info_Required
	    );
       fnd_log.string
	    (
		    fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
		    'Billing Item : '||l_cost_price_rec.item_name
	    );
   END IF;
   --
     OPEN visit_info_csr(l_cost_price_rec.visit_id);
     FETCH visit_info_csr INTO l_visit_status;

        IF (visit_info_csr%NOTFOUND)THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_INV_VISIT');
            FND_MSG_PUB.ADD;
            IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
		        fnd_log.string
		        (
			        fnd_log.level_exception,
			        'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			        'Visit id not found in ahl_visits_b table'
		        );
            END IF;
            CLOSE visit_info_csr;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
     CLOSE visit_info_csr;

 -- Not to calculate cost if visit is in cancelled status
 IF l_visit_status <>'CANCELLED'  THEN

     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			'Before calling ahl_vwp_cost_pvt.Calculate Wo Cost'
		);
     END IF;

     --Call ahl_vwp_cost_pvt.calculate_wo_cose
	   ahl_vwp_cost_pvt.calculate_wo_cost
		      ( p_x_cost_price_rec   => l_cost_price_rec,
			    x_return_status      => l_return_status);

     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string
		(
		    fnd_log.level_procedure,
                   'ahl.plsql.'||g_pkg_name||'.'||l_api_name||': End API',
			       'After calling Calculate wo cost Return Status is: '|| l_return_status
		);
     END IF;

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			'Cost Session ID : ' || l_cost_price_rec.cost_session_id
		);
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			'MR Session ID : ' || l_cost_price_rec.mr_session_id
		);
     END IF;

     -- Check Error Message stack.
     l_msg_count := FND_MSG_PUB.count_msg;
     IF l_msg_count > 0 THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE  FND_API.G_EXC_ERROR;
     END IF;

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string
		(
		   fnd_log.level_statement,
                   'ahl.plsql.'||g_pkg_name||'.'||l_api_name||': Derieved',
			       'Is Cst Struc Updated Flag: '|| l_cost_price_rec.Is_Cst_Struc_updated
		);
     END IF;

 IF(l_cost_price_rec.Is_Cst_Struc_updated = 'N') AND (l_cost_price_rec.workorder_id IS NOT NULL) THEN

    --Log message
     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string
		(
		  fnd_log.level_statement,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
		       'Inside Cost Struc Updated flag = N, Workorder Id: '|| l_cost_price_rec.workorder_id
		);
        fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			' MR Session ID : ' || l_cost_price_rec.mr_session_id
		);
        fnd_log.string
		 (
		  fnd_log.level_statement,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
    	       'Before calling ahl vwp cost pvt.calculate task cost '
		  );
     END IF;

     ahl_vwp_cost_pvt.calculate_task_cost
		      (
               p_visit_task_id	=> l_cost_price_rec.visit_task_id,
               p_session_id   	=> l_cost_price_rec.mr_session_id,
               x_Actual_cost	=> l_wo_actual_cost,
               x_Estimated_cost	=> l_wo_estimated_cost,
			   x_return_status  => l_return_status);

     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string
		(
		  fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||': End API',
	        'After calling ahl vwp cost pvt.Calculate task Cost Return Status is: '|| l_return_status
		);
     END IF;

     -- Check Error Message stack.
     l_msg_count := FND_MSG_PUB.count_msg;
     IF l_msg_count > 0 THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE  FND_API.G_EXC_ERROR;
     END IF;

    --Log message
     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		fnd_log.string
		(
		      fnd_log.level_statement,
             'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':Derieved ',
		     'Actual Cost : '|| l_wo_actual_cost
		);
		fnd_log.string
		(
		        fnd_log.level_statement,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':Derieved',
		       'Estimated Cost : '|| l_wo_estimated_cost
		);

     END IF;

	 --Assign derived values
	 l_cost_price_rec.actual_cost    := l_wo_actual_cost;
	 l_cost_price_rec.estimated_cost := l_wo_estimated_cost;

    END IF;

    --Log message
     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string
		 (
		  fnd_log.level_procedure,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
    	       'Before calling ahl vwp cost pvt.get profit or loss '
		  );
     END IF;

    -- Call get proft or loss
    ahl_vwp_cost_pvt.get_profit_or_loss
	      (
		   p_actual_price      => l_cost_price_rec.actual_price,
           p_estimated_price   => l_cost_price_rec.estimated_price,
           p_actual_cost	   => l_cost_price_rec.actual_cost,
           p_estimated_cost    => l_cost_price_rec.estimated_cost,
           x_actual_profit	   => l_cost_price_rec.actual_profit,
           x_estimated_profit  => l_cost_price_rec.estimated_profit,
		   x_return_status     => l_return_status);

     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string
		(
		  fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||': End API',
	        'After calling ahl vwp cost pvt.Get Profit Or Loss Return Status is: '|| l_return_status
		);

     END IF;

     -- Check Error Message stack.
     l_msg_count := FND_MSG_PUB.count_msg;
     IF l_msg_count > 0 THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE  FND_API.G_EXC_ERROR;
     END IF;

    --Log message
     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		fnd_log.string
		(
		    fnd_log.level_statement,
             'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':Derieved ',
		     'Actual Profit : '|| l_cost_price_rec.actual_profit
		);

		fnd_log.string
		(
		    fnd_log.level_statement,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':Derieved',
		       'Estimated Profit : '|| l_cost_price_rec.estimated_profit
		);

     END IF;

  END IF; -- status <> CANCELLED

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN

	    fnd_log.string
		 (
		  fnd_log.level_statement,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
    	       'Before calling ahl vwp cost pvt.check currency for costing '
		  );
     END IF;
    -- Get Currency
    ahl_vwp_rules_pvt.check_currency_for_costing
	      (
		   p_visit_id      => l_cost_price_rec.visit_id,
           x_currency_code => l_cost_price_rec.currency);


    --Log message
     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN

		fnd_log.string
		(
		 fnd_log.level_statement,
             'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':Derieved ',
		     'Curency code : '|| l_cost_price_rec.currency
		);
     END IF;

	-- Assign derived values
     	p_x_cost_price_rec := l_cost_price_rec;

    --Log messages
     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		fnd_log.string
		(
		    fnd_log.level_statement,
             'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':Derieved ',
		     'Actual Price : '|| p_x_cost_price_rec.actual_price
		);
		fnd_log.string
		(
		    fnd_log.level_statement,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':Derieved',
		       'Estimated Price : '|| p_x_cost_price_rec.estimated_price
		);

		fnd_log.string
		(
		    fnd_log.level_statement,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':Derieved',
		       'Actual Cost : '|| p_x_cost_price_rec.actual_cost
		);

		fnd_log.string
		(
		    fnd_log.level_statement,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':Derieved',
		       'Estimated Cost : '|| p_x_cost_price_rec.estimated_cost
		);

		fnd_log.string
		(
		    fnd_log.level_statement,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':Derieved',
		       'Actual Profit : '|| p_x_cost_price_rec.actual_profit
		);

		fnd_log.string
		(
		    fnd_log.level_statement,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':Derieved',
		       'Estimated Profit : '|| p_x_cost_price_rec.estimated_profit
		);

		fnd_log.string
		(
		    fnd_log.level_statement,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':Derieved',
		       'Cost Session Id : '|| p_x_cost_price_rec.cost_session_id
		);

		fnd_log.string
		(
		    fnd_log.level_statement,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':Derieved',
		       'Mr Session Id : '|| p_x_cost_price_rec.mr_session_id
		);

		fnd_log.string
		(
		    fnd_log.level_statement,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':Derieved',
		       'Price list Id : '|| p_x_cost_price_rec.price_list_id
		);

		fnd_log.string
		(
		    fnd_log.level_statement,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':Derieved',
		       'Price list Name : '|| p_x_cost_price_rec.price_list_name
		);
		fnd_log.string
		(
		    fnd_log.level_statement,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':Derieved',
		       'OutSide Party Flag : '|| p_x_cost_price_rec.outside_party_flag
		);
		fnd_log.string
		(
		    fnd_log.level_statement,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':Derieved',
		       'Customer Id : '|| p_x_cost_price_rec.customer_id
		);
		fnd_log.string
		(
		    fnd_log.level_statement,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':Derieved',
		       'Workorder Id : '|| p_x_cost_price_rec.workorder_id
		);
		fnd_log.string
		(
		    fnd_log.level_statement,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':Derieved',
		       'Task Start Date : '|| p_x_cost_price_rec.task_start_date
		);
		fnd_log.string
		(
		    fnd_log.level_statement,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':Derieved',
		       'Task End Date : '|| p_x_cost_price_rec.task_end_date
		);

       fnd_log.string
	    (
		    fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
		    'Billing Item : '||p_x_cost_price_rec.item_name
	    );

     END IF;

     -- Check Error Message stack.
     x_msg_count := FND_MSG_PUB.count_msg;
     IF x_msg_count > 0 THEN
       RAISE  FND_API.G_EXC_ERROR;
     END IF;

     -- Standard check of p_commit
    p_x_cost_price_rec:=l_cost_price_rec;
     IF FND_API.TO_BOOLEAN(p_commit) THEN
        COMMIT WORK;
     END IF;

     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.Get_Task_Cost_Details.end',
			'At the end of PLSQL procedure'
		);
     END IF;
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   ROLLBACK TO Get_Task_Cost_Details;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   ROLLBACK TO Get_Task_Cost_Details;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK TO Get_Task_Cost_Details;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Get_Task_Cost_Details',
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);

END Get_Task_Cost_Details;

-- Start of Comments --
--  Procedure name    : Update Task Cost Details
--  Type              : Private(Called from Estimate and cost/price Task UI
--
--  Function          : To update task price list
--
--
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Update Task Cost Details Parameters:
--       p_cost_price_rec              IN      Cost_price_rec_type,     Required
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE Update_Task_Cost_Details (
    p_api_version            IN            NUMBER,
    p_init_msg_list          IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_module_type            IN            VARCHAR2  := NULL,
    p_cost_price_rec         IN    AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type,
    x_return_status             OUT NOCOPY        VARCHAR2,
    x_msg_count                 OUT NOCOPY        NUMBER,
    x_msg_data                  OUT NOCOPY        VARCHAR2
  )
  IS
    -- Get visit task details
	CURSOR Get_visit_task_dtls_cur (c_visit_task_id IN NUMBER)
	 IS
	  SELECT vt.price_list_id,
             vt.visit_id,
             vt.visit_task_id,
	         vt.object_version_number,
	         vt.visit_task_number,
	         vt.visit_task_name
     FROM ahl_visit_tasks_vl vt,
          cs_incidents_all_b ci
	  WHERE visit_task_id = c_visit_task_id
          AND  NVL(vt.status_code, 'Y') <> NVL ('DELETED', 'X');
    l_visit_task_dtls_rec   Get_visit_task_dtls_cur%ROWTYPE;

   -- Get visit details
	CURSOR Get_visit_dtls_cur (c_visit_id IN NUMBER)
	 IS
	  SELECT vs.visit_id,
	         vs.start_date_time,
             vs.close_date_time,
             vs.service_request_id,
             ci.customer_id
	  FROM ahl_visits_vl vs,
           cs_incidents_all_b ci
	  WHERE visit_id = c_visit_id
      AND  vs.service_request_id = ci.incident_id(+)
      AND  NVL(vs.status_code, 'Y') <> NVL ('DELETED', 'X');
    l_visit_dtls_rec   Get_visit_dtls_cur%ROWTYPE;


   CURSOR price_list_id_csr(p_price_list_name IN VARCHAR2,p_customer_id IN NUMBER)
     IS
      SELECT qlhv.list_header_id
      FROM qp_list_headers_vl qlhv, qp_qualifiers qpq
      WHERE qlhv.list_type_code = 'PRL'
      AND upper(qlhv.name) like upper(p_price_list_name)
      AND qpq.QUALIFIER_ATTR_VALUE = p_customer_id
      AND qpq.list_header_id=qlhv.list_header_id
      AND  qpq.qualifier_context = 'CUSTOMER'
      AND  qpq.qualifier_attribute = 'QUALIFIER_ATTRIBUTE16';


    -- Get price list name
	CURSOR Get_price_list_cur (c_price_list_id IN NUMBER)
	IS
    SELECT start_date_active,
	       end_date_active
      FROM QP_LIST_HEADERS
    WHERE list_header_id = c_price_list_id;
  	l_price_list_rec   Get_price_list_cur%ROWTYPE;

    -- Local Variables
	l_api_name	    CONSTANT	VARCHAR2(30)	:= 'Update_Task_Cost_Details';
	l_api_version	CONSTANT	NUMBER		    := 1.0;

    l_msg_data             VARCHAR2(2000);
    l_default              VARCHAR2(30);
    l_error_msg_code       VARCHAR2(30);
	l_module_type          VARCHAR2(10);
    l_commit               VARCHAR2(10)  := Fnd_Api.G_FALSE;
    l_return_status        VARCHAR2(1);
    l_flag                 VARCHAR2(1);
    l_valid_flag           VARCHAR2(1);

    l_price_list_active_start_date   DATE;
    l_price_list_active_end_date     DATE;
    l_start_date_time                DATE;
    l_close_date_time                DATE;

x_price_list_id    NUMBER;
p_price_list_name  VARCHAR2(30);
    l_msg_count            NUMBER;
	i                      NUMBER;

    l_cost_price_rec   AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type := p_cost_price_rec;

 BEGIN

     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.Update_Task_Cost_Details.begin',
			'At the start of PLSQL procedure'
		);

     END IF;

     -- Standard start of API savepoint
     SAVEPOINT Update_Task_Cost_Details;

      -- Initialize message list if p_init_msg_list is set to TRUE
     IF FND_API.To_Boolean( p_init_msg_list) THEN
        FND_MSG_PUB.Initialize;
     END IF;

     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     --
     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			'Request for Updating cost details for Task ID : ' || l_cost_price_rec.visit_task_id
		);
     END IF;

     -- Check for Required Parameters
     IF(l_cost_price_rec.visit_task_id IS NULL OR
	    l_cost_price_rec.visit_task_id = FND_API.G_MISS_NUM) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_INPUT_MISS');
        FND_MSG_PUB.ADD;
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		    fnd_log.string
		    (
			    fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			    'Visit Task id is mandatory but found null in input '
		    );
        END IF;
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Retrieve task related information
	 OPEN Get_visit_task_dtls_cur(l_cost_price_rec.visit_task_id);
	 FETCH Get_visit_task_dtls_cur INTO l_visit_task_dtls_rec;
     IF Get_visit_task_dtls_cur%NOTFOUND THEN
           FND_MESSAGE.set_name( 'AHL','AHL_VWP_TASK_INVALID' );
           FND_MESSAGE.Set_Token('TASK_NUM', l_cost_price_rec.visit_task_number);
           FND_MSG_PUB.add;
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		    fnd_log.string
		    (
			    fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			    'Task id not found in ahl_visit_tasks_b table'
		    );
        END IF;
        CLOSE Get_visit_task_dtls_cur;
        RAISE  FND_API.G_EXC_ERROR;
        END IF;
      CLOSE Get_visit_task_dtls_cur;

      --Assign
	  l_cost_price_rec.task_name         := l_visit_task_dtls_rec.visit_task_name;
	  l_cost_price_rec.visit_id          := l_visit_task_dtls_rec.visit_id;
	  l_cost_price_rec.object_version_number  := l_visit_task_dtls_rec.object_version_number;

     -- Retrieve visit related information
	 OPEN Get_visit_dtls_cur(l_cost_price_rec.visit_id);
	 FETCH Get_visit_dtls_cur INTO l_visit_dtls_rec;
     IF Get_visit_dtls_cur%NOTFOUND THEN
           FND_MESSAGE.set_name( 'AHL','AHL_VWP_VISIT_INVALID' );
           FND_MSG_PUB.add;
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		    fnd_log.string
		    (
			    fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			    'Visit id not found in ahl_visits_b table'
		    );
        END IF;
        CLOSE Get_visit_dtls_cur;
        RAISE  FND_API.G_EXC_ERROR;
        END IF;
      CLOSE Get_visit_dtls_cur;

     -- Assign
 	  l_cost_price_rec.visit_start_date  := trunc(l_visit_dtls_rec.start_date_time);
      l_cost_price_rec.visit_end_date    := trunc(l_visit_dtls_rec.close_date_time);

     -- Convert price list name to price list ID
      l_cost_price_rec.price_list_id := NULL;
      IF l_cost_price_rec.price_list_name IS NOT NULL THEN
     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			'Price List conversion : ' || l_cost_price_rec.price_list_name
		);
     END IF;
          p_price_list_name := l_cost_price_rec.price_list_name;

          -- First look if any SR for visit and if has customer defined
          IF l_visit_dtls_rec.service_request_id IS NOT NULL AND
             l_visit_dtls_rec.customer_id IS NOT NULL THEN

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			'Check for customer Id and service request id : '
		);
     END IF;

              l_cost_price_rec.customer_id        := l_visit_dtls_rec.customer_id;

              -- Find out the price list id
              OPEN price_list_id_csr(p_price_list_name,l_visit_dtls_rec.customer_id);
              FETCH price_list_id_csr INTO l_cost_price_rec.price_list_id;
              IF (price_list_id_csr%NOTFOUND)THEN
                   FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_PLIST_NFOUND');
                   FND_MESSAGE.Set_Token('PRICE_LIST',p_price_list_name);
                   FND_MSG_PUB.ADD;

                   IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		            fnd_log.string
                    (
			           fnd_log.level_error,
        			    'ahl.plsql.'||G_PKG_NAME||'.'||L_API_NAME,
		        	    'Valid price list not found with price list name ' || p_price_list_name
                    );
                   END IF;

               x_return_status := FND_API.G_RET_STS_ERROR;
             END IF;
             CLOSE price_list_id_csr;


         END IF;
     END IF;

	 --
     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.string
            (
              fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
					'Price List Id:'||l_cost_price_rec.price_list_id
				);
      END IF;

      IF l_cost_price_rec.price_list_id IS NOT NULL THEN
        OPEN Get_price_list_cur(l_cost_price_rec.price_list_id);
		FETCH Get_price_list_cur INTO l_price_list_rec;
        IF Get_price_list_cur%NOTFOUND THEN
           FND_MESSAGE.set_name( 'AHL','AHL_VWP_PRICE_LIST_INVALID' );
           FND_MSG_PUB.add;
           IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		      fnd_log.string
		      (
			    fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			    'Price List Name not found in qp_list_headers table'
		       );
           END IF;
        END IF;
        CLOSE Get_price_list_cur;

     -- Check for dates fall in between price list
     -- compare it with visit start and end dates
     l_price_list_active_start_date  := l_price_list_rec.start_date_active;
     l_price_list_active_end_date    := l_price_list_rec.end_date_active;
     l_start_date_time               := l_cost_price_rec.visit_start_date;
     l_close_date_time               := l_cost_price_rec.visit_end_date;

  IF(l_price_list_active_start_date IS NOT NULL OR l_price_list_active_end_date IS NOT NULL)THEN

    -- Check if the visit start date and visit planned end date if not null
    IF (l_start_date_time IS NOT NULL OR l_close_date_time IS NOT NULL ) THEN

        -- visit start date validation
        IF (l_start_date_time IS NOT NULL)THEN

           IF (TRUNC(l_price_list_active_start_date) > TRUNC(l_start_date_time)) OR
             (TRUNC(l_price_list_active_end_date) < TRUNC(l_start_date_time)) THEN

             FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_PRICE_LIST_INV_STR');
             FND_MSG_PUB.ADD;
             IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		       fnd_log.string
		         (
			        fnd_log.level_error,
			        'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.update_task_cost_details',
			        'Price List is not active on visit start date'
		         );
             END IF;

          END IF;

       END IF; -- End of visit start_date check

       -- visit planned end date validation
       IF (l_close_date_time IS NOT NULL)THEN

           IF (TRUNC(l_price_list_active_start_date) > TRUNC(l_close_date_time)) OR
              (TRUNC(l_price_list_active_end_date) < TRUNC(l_close_date_time)) THEN

             FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_PRICE_LIST_INV_END');
             FND_MSG_PUB.ADD;
             IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		       fnd_log.string
		         (
			        fnd_log.level_error,
			        'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.update_task_cost_details',
			        'Price List is not active on visit end date'
		         );
             END IF;

          END IF;

        END IF;  -- End of l_close_date_time visit planned end date check

   ELSE -- Else of visit start date and visit planned end date null check

      -- Check if the visit start date and visit planned end date are null
      -- then validate with current sysdate
         IF (l_price_list_active_start_date IS NOT NULL AND TRUNC(l_price_list_active_start_date) > TRUNC(sysdate))
            OR
            (l_price_list_active_end_date IS NOT NULL AND TRUNC(l_price_list_active_end_date) < TRUNC(sysdate))
            THEN

             FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_PRICE_LIST_INV_SYS');
             -- CHANGE THIS MESSAGE TEST AND NAME TOO -- IMPORTANT
             FND_MSG_PUB.ADD;
             IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		       fnd_log.string
		         (
			        fnd_log.level_error,
			        'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.update_task_cost_details',
			        'Price List is not active on current todays date'
		         );
             END IF;

          END IF;

      END IF;  -- End of visit start_date and planned end date check

   END IF; -- End of price_list active_start_date and active_end_date check

 END IF; -- Check for price list id not null

   -- End of changes by Shbhanda on 30th Dec 2003 --

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			' Before Update Ahl Visit Tasks B Table, Price List Id: ' || l_cost_price_rec.price_list_id
		);
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			' Before Update Ahl Visit Tasks B Table, Estimated Price: ' || l_cost_price_rec.estimated_price
		);
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			' Before Update Ahl Visit Tasks B Table, Actual Price: ' || l_cost_price_rec.actual_price
		);
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			' Before Update Ahl Visit Tasks B Table, Actual Cost: ' || l_cost_price_rec.actual_cost
		);
	  END IF;

   -- Update the task record with cost details
    UPDATE AHL_VISIT_TASKS_B SET
        PRICE_LIST_ID           = l_cost_price_rec.price_list_id,
        ESTIMATED_PRICE         = l_cost_price_rec.estimated_price,
        ACTUAL_PRICE            = l_cost_price_rec.actual_price,
        ACTUAL_COST             = l_cost_price_rec.actual_cost,
        LAST_UPDATE_DATE        = SYSDATE,
        LAST_UPDATED_BY         = Fnd_Global.USER_ID,
        LAST_UPDATE_LOGIN       = Fnd_Global.LOGIN_ID,
        OBJECT_VERSION_NUMBER   = l_cost_price_rec.object_version_number + 1
  WHERE VISIT_TASK_ID = l_cost_price_rec.visit_task_id;

     -- Check Error Message stack.
     x_msg_count := FND_MSG_PUB.count_msg;
     IF x_msg_count > 0 THEN
       RAISE  FND_API.G_EXC_ERROR;
     END IF;

     -- Standard check of p_commit
     IF FND_API.TO_BOOLEAN(p_commit) THEN
        COMMIT WORK;
     END IF;

     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.Update_Task_Cost_Details.end',
			'At the end of PLSQL procedure'
		);
     END IF;
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   ROLLBACK TO Update_Task_Cost_Details;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   ROLLBACK TO Update_Task_Cost_Details;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK TO Update_Task_Cost_Details;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Update_Task_Cost_Details',
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);

  END Update_Task_Cost_Details;


-- Start of Comments --
--  Procedure name    : Estimate_Task_Cost
--  Type              : Private(Called from Estimate and cost/price Task UI
--
--  Function          : To get task estimated cost and actual cost
--
--
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Estimate Task Cost Parameters:
--       p_x_cost_price_rec     IN OUT NOCOPY AHL_VWP_VISIT_CST_PR_PVT.Cost_Price_Rec_Type,
--         Contains Cost/Price infor mation relates to Vist and its Task
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE Estimate_Task_Cost (
    p_api_version            IN            NUMBER,
    p_init_msg_list          IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_module_type            IN            VARCHAR2  := NULL,
    p_x_cost_price_rec       IN OUT NOCOPY AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type,
    x_return_status             OUT NOCOPY        VARCHAR2,
    x_msg_count                 OUT NOCOPY        NUMBER,
    x_msg_data                  OUT NOCOPY        VARCHAR2 )
  IS

   -- To get visit info
   CURSOR Get_visit_task_cur (C_VISIT_TASK_ID IN NUMBER)
   IS
   SELECT vt.visit_id,
          vt.visit_task_id,
		  vs.any_task_chg_flag
   FROM ahl_visit_tasks_b vt,
		ahl_visits_b vs
   WHERE vt.visit_task_id = C_VISIT_TASK_ID
   AND vt.visit_id = vs.visit_id
   AND   NVL(vt.status_code, 'Y') <> NVL ('DELETED', 'X');

   l_visit_task_rec      Get_visit_task_cur%ROWTYPE;

    --
    l_api_name	    CONSTANT	VARCHAR2(30)	:= 'Estimate_Task_Cost';
    l_api_version	CONSTANT	NUMBER		    := 1.0;
    l_msg_data             VARCHAR2(2000);
    l_return_status        VARCHAR2(1);
    l_msg_count             NUMBER;
    l_commit          VARCHAR2(10)  := Fnd_Api.G_FALSE;
	--
    l_cost_price_rec  AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type := p_x_cost_price_rec;
   --

   l_release_visit_required     VARCHAR2(1) :='N';

   BEGIN

     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.Estimate_Task_Cost.begin',
			'At the start of PLSQL procedure'
		);

     END IF;

     -- Standard start of API savepoint
     SAVEPOINT Estimate_Task_Cost;

      -- Initialize message list if p_init_msg_list is set to TRUE
     IF FND_API.To_Boolean( p_init_msg_list) THEN
        FND_MSG_PUB.Initialize;
     END IF;
     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     --
     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			'Request for Estimating cost for Task ID : ' || l_cost_price_rec.visit_task_id
		);

		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			'Got request for task cost details of Cost Session ID : ' || l_cost_price_rec.cost_session_id
		);

		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			'Got request for task cost details of MR Session ID : ' || l_cost_price_rec.mr_session_id
		);

     END IF;
     -- Check for Required Parameters
     IF(l_cost_price_rec.visit_task_id IS NULL OR
	    l_cost_price_rec.visit_task_id = FND_API.G_MISS_NUM) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_INPUT_MISS');
        FND_MSG_PUB.ADD;
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		    fnd_log.string
		    (
			    fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			    'Visit Task id is mandatory but found null in input '
		    );
        END IF;
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     --Required to get visit id
     OPEN Get_visit_task_cur(l_cost_price_rec.visit_task_id);
	 FETCH Get_visit_task_cur INTO l_visit_task_rec;
	 CLOSE Get_visit_task_cur;


-- Need to release the visit only if this API is called from front-end direcly

 IF p_module_type = 'JSP' THEN

     AHL_VWP_VISIT_CST_PR_PVT.check_for_release_visit
     (
          p_visit_id                    =>l_visit_task_rec.visit_id,
          x_release_visit_required      =>l_release_visit_required
     );

-- Release visit if required
    IF l_release_visit_required ='Y' THEN

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
				'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
				'Before calling ahl vwp proj prod pvt.release visit'
			);

		END IF;

        ahl_vwp_proj_prod_pvt.release_visit (
              p_api_version        => l_api_version,
              p_init_msg_list      => p_init_msg_list,
              p_commit             => l_commit,
              p_validation_level   => p_validation_level,
              p_module_type        => 'CST',
              p_visit_id           => l_visit_task_rec.visit_id,
              x_return_status      => l_return_status,
              x_msg_count          => l_msg_count,
             x_msg_data            => l_msg_data);

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
		     'ahl.plsql.'||g_pkg_name||'.'||l_api_name||': End API',
		     'After calling ahl vwp proj prod pvt.Release Visit task wo Return Status : '|| l_return_status
		  );
		END IF;

       -- Check Error Message stack.
       IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
	      l_msg_count := FND_MSG_PUB.count_msg;
	      IF l_msg_count > 0 THEN
	        RAISE FND_API.G_EXC_ERROR;
	      END IF;
       END IF;

   END IF;  -- released required flag

END IF; --- p_module type = 'JSP'


     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
    	       'Before calling ahl vwp cost pvt.calculate wo cost '
		  );
     END IF;

	 -- Call AHL_VWP_COST_PVT.estimate_wo_cost
	     ahl_vwp_cost_pvt.estimate_wo_cost
		      ( p_x_cost_price_rec   => l_cost_price_rec,
			    x_return_status      => l_return_status);

     -- Check return status.
     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string
		(
		  fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||': End API',
	        'After calling ahl vwp cost pvt.Calculate Wo Cost Return Status : '|| l_return_status
		);
     END IF;


     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			'Is Cst Struc updated Flag: ' || l_cost_price_rec.Is_Cst_Struc_updated
		);
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			'Cost Session Id: ' || l_cost_price_rec.cost_session_id
		);
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			'Mr Session Id: ' || l_cost_price_rec.mr_session_id
		);

      END IF;
      --Assign the out variable
      p_x_cost_price_rec.cost_session_id := l_cost_price_rec.cost_session_id;
      p_x_cost_price_rec.mr_session_id   := l_cost_price_rec.mr_session_id;
      p_x_cost_price_rec.Is_Cst_Struc_updated := l_cost_price_rec.Is_Cst_Struc_updated;

     -- Standard check of p_commit
     IF FND_API.TO_BOOLEAN(p_commit) THEN
        COMMIT WORK;
     END IF;

     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.Estimate_Task_Cost.end',
			'At the end of PLSQL procedure'
		);
     END IF;
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   ROLLBACK TO Estimate_Task_Cost;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   ROLLBACK TO Estimate_Task_Cost;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK TO Estimate_Task_Cost;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Estimate_Task_Cost',
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);

END Estimate_Task_Cost;

-- Start of Comments --
--  Procedure name    : Estimate_Task_Price
--  Type              : Private(Called from Estimate and cost/price Task UI
--
--  Function          :To get Task Estimated Price and Actual Price
--
--
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Estimate Task Price Parameters:
--       p_x_cost_price_rec     IN OUT NOCOPY AHL_VWP_VISIT_CST_PR_PVT.Cost_Price_Rec_Type,
--         Contains Cost/Price infor mation relates to Vist and its Task
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE Estimate_Task_Price (
    p_api_version            IN            NUMBER,
    p_init_msg_list          IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_module_type            IN            VARCHAR2  := NULL,
    p_x_cost_price_rec       IN OUT NOCOPY AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type,
    x_return_status             OUT NOCOPY        VARCHAR2,
    x_msg_count                 OUT NOCOPY        NUMBER,
    x_msg_data                  OUT NOCOPY        VARCHAR2
  )
  IS

    -- Cursor to get visit and task cost details
	CURSOR Get_visit_task_dtls_cur (C_VISIT_TASK_ID IN NUMBER)
	 IS
	 SELECT vs.visit_id,
	        vs.visit_number,
	        vs.actual_price visit_actual_price,
	        vs.estimated_price visit_estimated_price,
			vs.object_version_number visit_object_version_number,
			vs.organization_id,
			vs.any_task_chg_flag,
			nvl(vt.price_list_id, vs.price_list_id) price_list_id,
			vt.visit_task_id,
			vt.visit_task_number,
			vt.object_version_number task_object_version_number,
			vt.actual_price task_actual_price,
			vt.estimated_price task_estimated_price,
			vt.mr_id,
			vt.task_type_code,
			mr_route_id,
			vt.originating_task_id,
			vt.service_request_id,
			cs.customer_id,
			vt.start_date_time,    --Post11510 cxcheng added
			vt.end_date_time
	  FROM ahl_visits_vl vs,
	       ahl_visit_tasks_vl vt,
		   cs_incidents_all_b cs
     WHERE vs.visit_id = vt.visit_id
	   AND vs.service_request_id = cs.incident_id(+)
       AND vt.visit_task_id = C_VISIT_TASK_ID
   AND   NVL(vt.status_code, 'Y') <> NVL ('DELETED', 'X');

    l_visit_task_dtls_rec     Get_visit_task_dtls_cur%ROWTYPE;

    -- Cursor to get parent mr
	CURSOR Get_parent_task_cur (C_ORIG_TASK_ID IN NUMBER,
	                            C_VISIT_ID     IN NUMBER)
	 IS
	 SELECT distinct(vt.visit_task_id) visit_task_id,
	        vt.object_version_number,
	        vt.visit_task_number,
			vt.mr_id,
			vt.mr_route_id,
			vt.actual_price,
			vt.estimated_price
	  FROM ahl_visit_tasks_b vt
    WHERE visit_id = C_VISIT_ID
      AND NVL(vt.status_code, 'Y') <> NVL ('DELETED', 'X')
    START WITH  visit_task_id = C_ORIG_TASK_ID
    CONNECT BY PRIOR originating_task_id = visit_task_id;

    l_parent_task_rec         Get_parent_task_cur%ROWTYPE;

    --Standard local variables
    l_api_name	    CONSTANT	VARCHAR2(30)	:= 'Estimate_Task_Price';
    L_FULL_NAME         CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;
    l_api_version	CONSTANT	NUMBER		    := 1.0;
    l_msg_data             VARCHAR2(2000);
    l_return_status        VARCHAR2(1);
    l_msg_count             NUMBER;
	l_dummy                 NUMBER;

    --
    l_cost_price_rec          AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type :=p_x_cost_price_rec;

    l_route_id             NUMBER;
	l_estimated_price      NUMBER :=0;
	l_actual_price         NUMBER :=0;
    l_act_price_dif        NUMBER;
    l_estimate_price_dif   NUMBER;

	l_job_status_code      VARCHAR2(30);
	l_job_status_mean      VARCHAR2(80);

	-- Varibles for start date time
    l_default              VARCHAR2(30);
	i        NUMBER;

    --Validate visit variables

    l_commit          VARCHAR2(10)  := Fnd_Api.G_FALSE;

   BEGIN
   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.Estimate_Task_Price.begin',
			'At the start of PLSQL procedure'
		);

     END IF;
     -- Standard start of API savepoint
     SAVEPOINT Estimate_Task_Price;
      -- Initialize message list if p_init_msg_list is set to TRUE
     IF FND_API.To_Boolean( p_init_msg_list) THEN
        FND_MSG_PUB.Initialize;
     END IF;
     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     --
     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			'Request for Estimating Price for Task ID : ' || l_cost_price_rec.visit_task_id
		);

     END IF;

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			'Request for Estimating Task Price for Currency code : ' || l_cost_price_rec.currency
		);

     END IF;

     -- Check for Required Parameters
     IF(l_cost_price_rec.visit_task_id IS NULL OR
	    l_cost_price_rec.visit_task_id = FND_API.G_MISS_NUM) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_INPUT_MISS');
        FND_MSG_PUB.ADD;
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		    fnd_log.string
		    (
			    fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			    'Visit Task id is mandatory but found null in input '
		    );
        END IF;
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Retrieve visit info
     OPEN Get_visit_task_dtls_cur(l_cost_price_rec.visit_task_id) ;
	 FETCH Get_visit_task_dtls_cur INTO l_visit_task_dtls_rec;
     IF Get_visit_task_dtls_cur%NOTFOUND THEN
           FND_MESSAGE.set_name( 'AHL','AHL_VWP_VISIT_TASK_INVALID' );
           FND_MSG_PUB.add;
          IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		    fnd_log.string
		    (
			    fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			    'Visit Task not found in ahl_visit_tasks_b table'
		    );
        END IF;
        CLOSE Get_visit_task_dtls_cur;
        RAISE  FND_API.G_EXC_ERROR;
        END IF;
	 CLOSE Get_visit_task_dtls_cur;

	 --Assign derieved values
     l_cost_price_rec.price_list_id := l_visit_task_dtls_rec.price_list_id;
     l_cost_price_rec.visit_id      := l_visit_task_dtls_rec.visit_id;
     l_cost_price_rec.mr_id         := l_visit_task_dtls_rec.mr_id;
     l_cost_price_rec.customer_id   := l_visit_task_dtls_rec.customer_id;
     l_cost_price_rec.organization_id   := l_visit_task_dtls_rec.organization_id;

     --
     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			'Price List Id : ' || l_cost_price_rec.price_list_id
		);

		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			'Customer Id : ' || l_cost_price_rec.customer_id
		);

		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			'Visit Id : ' || l_cost_price_rec.visit_id
		);

     END IF;

   IF l_cost_price_rec.currency IS NULL THEN
    -- Get Currency
    ahl_vwp_rules_pvt.check_currency_for_costing
	      (
		   p_visit_id      => l_cost_price_rec.visit_id,
           x_currency_code => l_cost_price_rec.currency);
    -- error handling
    IF l_cost_price_rec.currency IS NULL THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_NO_CURRENCY');
        FND_MSG_PUB.ADD;
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		    fnd_log.string
		    (
			    fnd_log.level_error,
			    'ahl.plsql.'||G_PKG_NAME||'.'||L_API_NAME,
			    'No curency is defined for the organization of the visit'
		    );
        END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF; -- error handling
   END IF;  --If currency is null

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			'Currency : ' || l_cost_price_rec.currency
		);

	  END IF;

     -- Validation for Price list, Task has price list associated consider it else use
	 -- visit price list. If both not exists then raise an error message
	 IF (l_cost_price_rec.price_list_id IS NULL OR
	     l_cost_price_rec.price_list_id = FND_API.G_MISS_NUM ) THEN
           FND_MESSAGE.set_name( 'AHL','AHL_VWP_PRICE_LIST_INVALID' );
           FND_MSG_PUB.add;
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		    fnd_log.string
		    (
			    fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			    'Price list not found for either Task Or Visit'
		    );
        END IF;
       RAISE  FND_API.G_EXC_ERROR;
	 END IF;

  IF p_module_type = 'JSP' THEN

     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string
		 (
		  fnd_log.level_procedure,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
    	       'Before calling ahl vwp task cost.Estimate Task Cost '
		  );

     END IF;

        --Call estimate task cost
        Estimate_Task_Cost (
           p_api_version         => l_api_version,
           p_init_msg_list       => p_init_msg_list,
           p_commit              => l_commit,
           p_validation_level    => p_validation_level,
           p_module_type         => p_module_type,
           p_x_cost_price_rec    => l_cost_price_rec,
           x_return_status       => l_return_status,
           x_msg_count           => l_msg_count,
           x_msg_data            => l_msg_data);

      -- Check return status.
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string
		(
		  fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||': End API',
	        'After calling ahl vwp task cost pvt.Estimate Task cost Return Status : '|| l_return_status
		);
     END IF;



    --Assign the out variable
    p_x_cost_price_rec.cost_session_id := l_cost_price_rec.cost_session_id;
    p_x_cost_price_rec.mr_session_id := l_cost_price_rec.mr_session_id;
    p_x_cost_price_rec.Is_Cst_Struc_updated := l_cost_price_rec.Is_Cst_Struc_updated;


  END IF; --Module type JSP

    -- If the task has mrs associated and task type is summary get estimated price for the MR

   IF (l_cost_price_rec.mr_id IS NOT NULL AND l_visit_task_dtls_rec.task_type_code = 'SUMMARY')
     THEN
       IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string
		  (
		   fnd_log.level_procedure,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
    	        'Before calling ahl vwp mr cst pr pvt.Estimate Mr Price'
   		  );

      END IF;

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.Estimate_Task_Price',
			'Mr Id : ' || l_cost_price_rec.mr_id
		);

     END IF;

       --Call ahl_vwp_mr_cst_pr_pvt.estimate_mr_price
       ahl_vwp_mr_cst_pr_pvt.Estimate_MR_Price (
           p_api_version        => l_api_version,
           p_init_msg_list      => p_init_msg_list,
           p_commit             => l_commit,
           p_validation_level   => p_validation_level,
           p_x_cost_price_rec   => l_cost_price_rec,
           p_module_type        => p_module_type,
           x_return_status      => l_return_status,
           x_msg_count          => l_msg_count,
           x_msg_data           => l_msg_data);

   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string
		(
		  fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||': End API',
	        'After calling ahl vwp cst pr pvt.Estimate Mr Price Return Status : '|| l_return_status
		);
     END IF;

      -- Check return status.
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    --Assign returned values
	l_estimated_price := l_cost_price_rec.estimated_price;
	l_actual_price    := l_cost_price_rec.actual_price;

	--Log messages
     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.Estimate_Task_Price',
			'Derieved value from Estimate Mr price for Summary task, Estimated Price : ' || l_estimated_price
		);

		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.Estimate_Task_Price',
			'Derieved value from Estimate Mr price for Summary task, Actual Price : ' || l_actual_price
		);

     END IF;

Else  --- other type of tasks (planned/unplanned/unassociated)



     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string
		  (
		   fnd_log.level_procedure,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
    	        'Before calling ahl vwp rules pvt.Check Job Status'
   		  );

     END IF;


     --Check job status
      ahl_vwp_rules_pvt.Check_Job_Status
         (p_id  	       => l_cost_price_rec.visit_task_id,
          p_is_task_flag   => 'Y',
          x_status_code    => l_job_status_code,
          x_status_meaning => l_job_status_mean);

   --Log Messages
   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string
		(
		  fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||': End API',
	        'After calling ahl vwp rules pvt.Check Job Status, Return Status : '|| l_return_status
		);
     END IF;

     -- error hanling
  IF (l_job_status_code is NULL) THEN
	 l_msg_count := FND_MSG_PUB.count_msg;
	 IF l_msg_count > 0 THEN
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;
  END IF;

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.Estimate_Task_Price',
			' Job Status Code: ' || l_job_status_code
		);
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.Estimate_Task_Price',
			' Job Status Mean: ' || l_job_status_mean
		);
		    fnd_log.string
		    (
			    fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			    'task start date :' ||l_cost_price_rec.task_start_date
 		    );
     END IF;

 -- If job is in draft status

   IF l_job_status_code = 17
   THEN

  -- For Unplanned/Planned tasks
  -- Derive estimated price
  -- for unassociated task estimated price is zero

   IF (l_cost_price_rec.mr_id IS NOT NULL AND l_visit_task_dtls_rec.mr_route_id IS NOT NULL )THEN

	   -- Retrieve route id
	   SELECT ROUTE_ID INTO l_route_id
	     FROM ahl_mr_routes_v
		WHERE mr_route_id = l_visit_task_dtls_rec.mr_route_id;

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.Estimate_Task_Price',
			' For task with Route Id: ' || l_route_id
		);
     END IF;

-- derive task start time if job is in draft status
-- and API is called from front-end directly


  IF p_module_type='JSP'
  THEN

     --Use the task start date and end date.
    l_cost_price_rec.task_start_date :=l_visit_task_dtls_rec.start_date_time;
    l_cost_price_rec.task_end_date := l_visit_task_dtls_rec.end_date_time;

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.Estimate_Task_Price',
			' Derieved task start date: ' || l_cost_price_rec.task_start_date
		);

     END IF;

  End IF; -- p_module is JSP

   --When Job Status is DRAFT, estimated price for tasks w/Route will be derived
   -- based on route material requirements and resource requirements

     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string
		  (
		   fnd_log.level_procedure,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
    	        'Before calling ahl vwp price pvt.Get Task Estimated Price'
   		  );

     END IF;

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.Estimate_Task_Price',
			' Before Calling Task Estimated Price, Route Id: ' || l_route_id
		);
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.Estimate_Task_Price',
			' Before Calling Task Estimated Price, Price List Id: ' || l_cost_price_rec.price_list_id
		);

		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.Estimate_Task_Price',
			' Before Calling Task Estimated Price, Customer Id: ' || l_cost_price_rec.customer_id
		);
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.Estimate_Task_Price',
			' Before Calling Task Estimated Price, Currency: ' || l_cost_price_rec.currency
		);
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.Estimate_Task_Price',
			' Before Calling Task Estimated Price, Task Start Date: ' || l_cost_price_rec.task_start_date
		);
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.Estimate_Task_Price',
			' Before Calling Task Estimated Price, Organization Id: ' || l_cost_price_rec.organization_id
		);

     END IF;

     -- Task Date can not be null
    IF (l_cost_price_rec.task_start_date IS NULL OR
	    l_cost_price_rec.task_start_date = FND_API.G_MISS_DATE ) THEN

	    FND_MESSAGE.set_name( 'AHL','AHL_VWP_VALIDATE_ERROR' );
	    FND_MSG_PUB.add;

	    IF G_DEBUG='Y' THEN
	      Ahl_Debug_Pub.debug( l_full_name ||'Task Start Date is null');
        END IF;

    	RAISE FND_API.G_EXC_ERROR;
    END IF;

     ahl_vwp_price_pvt.Get_Task_Estimated_Price (
          p_visit_task_id      => l_cost_price_rec.visit_task_id,
		  p_route_id           => l_route_id,
		  p_price_list_id      => l_cost_price_rec.price_list_id,
		  p_customer_id        => l_cost_price_rec.customer_id,
		  p_currency_code      => l_cost_price_rec.currency,
		  p_effective_date     => l_cost_price_rec.task_start_date,
		  p_organization_id    => l_cost_price_rec.organization_id,
		  x_estimated_price    => l_estimated_price,
          x_return_status      => l_return_status);

   --Log messages
   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string
		(
		  fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||': End API',
	        'After calling ahl vwp price pvt.Get Task Estimated Price, Return Status : '|| l_return_status
		);
    END IF;

      -- Check return status.
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

	 --Assign derived value
	 l_cost_price_rec.estimated_price := l_estimated_price;

  ELSE -- Unassociated Task

     l_cost_price_rec.estimated_price := 0;

  END IF;   --Planned/Unplanned Tasks

	 l_cost_price_rec.actual_price := 0;

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.Estimate_Task_Price',
			' Derieved Value for Estimated Price: ' || l_cost_price_rec.estimated_price
		);
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.Estimate_Task_Price',
			' Derieved Value for Actual Price: ' || l_cost_price_rec.actual_price
		);
     END IF;

ELSE
    --If job status other than 'DRAFT''

     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string
		  (
		   fnd_log.level_procedure,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
    	        'Before calling ahl vwp price pvt.Get Job Estimated Price'
   		  );

     END IF;

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.Estimate_Task_Price',
			' Before Calling Job Estimated Price, Price List Id: ' || l_cost_price_rec.price_list_id
		);
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.Estimate_Task_Price',
			' Before Calling Job Estimated Price, Customer Id: ' || l_cost_price_rec.customer_id
		);
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.Estimate_Task_Price',
			' Before Calling Job Estimated Price, Currency: ' || l_cost_price_rec.currency
		);

    END IF;

    ahl_vwp_price_pvt.Get_Job_Estimated_Price (
          p_visit_task_id      => l_cost_price_rec.visit_task_id,
		  p_price_list_id      => l_cost_price_rec.price_list_id,
		  p_customer_id        => l_cost_price_rec.customer_id,
		  p_currency_code      => l_cost_price_rec.currency,
		  x_estimated_price    => l_estimated_price,
          x_return_status      => l_return_status);
   --Log messages
   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string
		(
		  fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||': End API',
	        'After calling ahl vwp price pvt.Get Job Estimated Price, Return Status : '|| l_return_status
		);
    END IF;

      -- Check return status.
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

	-- Assign
	l_cost_price_rec.estimated_price := l_estimated_price;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
             'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			' Derieved value from Job Estimated Price, Estimated Price: ' || l_estimated_price
		);
    END IF;

     -- Call ahl_vwp_price_pvt.get_task_actual_price
     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string
		  (
		   fnd_log.level_procedure,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
    	        'Before calling ahl vwp price pvt.Get Job Actual Price'
   		  );

     END IF;

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			' Before Calling Job Actual Price, Price List Id: ' || l_cost_price_rec.price_list_id
		);
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			' Before Calling Job Actual Price, Customer Id: ' || l_cost_price_rec.customer_id
		);
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			' Before Calling Job Actual Price, Currency: ' || l_cost_price_rec.currency
		);

    END IF;

     ahl_vwp_price_pvt.Get_job_Actual_Price (
          p_visit_task_id      => l_cost_price_rec.visit_task_id,
		  p_price_list_id      => l_cost_price_rec.price_list_id,
		  p_customer_id        => l_cost_price_rec.customer_id,
		  p_currency_code      => l_cost_price_rec.currency,
		  x_actual_price       => l_actual_price,
          x_return_status      => l_return_status);

   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string
		(
		  fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||': End API',
	        'After calling ahl vwp rules pvt.Get Job Actual Price, Return Status : '|| l_return_status
		);
    END IF;

      -- Check return status.
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

	 --Assign derived value
	 l_cost_price_rec.actual_price := l_actual_price;

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			' Derieved value from Job Actual Price, Actual Price: ' || l_cost_price_rec.actual_price
		);

     END IF;

 END IF; -- Draft status

END IF; -- MR Summary Task

   -- If calling from front-end directly, and the new estimated price or actual price
   -- is different from the previous one, then need to adjust the value stored at Visit level
   -- And all the parent MR level

 IF p_module_type = 'JSP' THEN

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			' If p_module_type = JSP : ' || p_module_type
		);

     END IF;

   IF (l_cost_price_rec.actual_price <> nvl(l_visit_task_dtls_rec.task_actual_price,0) OR
	     l_cost_price_rec.estimated_price <> nvl(l_visit_task_dtls_rec.task_estimated_price,0) ) THEN

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			' After l_Actual Price <> l_visit_task_dtls_rec.task_actual_price: ' || l_visit_task_dtls_rec.task_actual_price
		);
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			' After l_Estimated Price <> l_visit_task_dtls_rec.task_estimated_price: ' || l_visit_task_dtls_rec.task_estimated_price
		);

     END IF;

-- for Unassociated tasks or top level MR tasks, only adjust visit level

	IF (l_visit_task_dtls_rec.task_type_code <> 'UNASSOCIATED'
	   AND l_visit_task_dtls_rec.originating_task_id IS NOT NULL) THEN

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			' If task_type_code <> UNASSOCIATED and task is not at the top level: ' || l_visit_task_dtls_rec.task_type_code
		);

     END IF;
          -- Check for all parent MRs exists for originating task
          OPEN Get_parent_task_cur(l_visit_task_dtls_rec.originating_task_id,
		                           l_visit_task_dtls_rec.visit_id);
          LOOP
		  FETCH Get_parent_task_cur INTO l_parent_task_rec;
          EXIT WHEN Get_parent_task_cur%NOTFOUND;
		  --
		  IF l_parent_task_rec.mr_id IS NOT NULL THEN

		    IF (l_parent_task_rec.estimated_price IS NOT NULL OR
			    l_parent_task_rec.actual_price IS NOT NULL ) THEN
               -- Actual Price
		       IF nvl(l_visit_task_dtls_rec.task_actual_price,0) > l_cost_price_rec.actual_price THEN
			      l_act_price_dif :=  (nvl(l_visit_task_dtls_rec.task_actual_price,0) - l_cost_price_rec.actual_price);
	              l_parent_task_rec.actual_price := (nvl(l_parent_task_rec.actual_price,0) - l_act_price_dif);
			    ELSE
				  l_act_price_dif := (l_cost_price_rec.actual_price - nvl(l_visit_task_dtls_rec.task_actual_price,0));
	              l_parent_task_rec.actual_price := (nvl(l_parent_task_rec.actual_price,0) + l_act_price_dif);
                END IF;
                -- Estimated price
		       IF nvl(l_visit_task_dtls_rec.task_estimated_price,0) > l_cost_price_rec.estimated_price THEN
			      l_estimate_price_dif :=  (nvl(l_visit_task_dtls_rec.task_estimated_price,0) - l_cost_price_rec.estimated_price);
	              l_parent_task_rec.estimated_price := (nvl(l_parent_task_rec.estimated_price,0) - l_estimate_price_dif);
			    ELSE
				  l_estimate_price_dif := (l_cost_price_rec.estimated_price - nvl(l_visit_task_dtls_rec.task_estimated_price,0));
	              l_parent_task_rec.estimated_price := (nvl(l_parent_task_rec.estimated_price,0) + l_estimate_price_dif);
                END IF;

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			' Before updating parent task ahl_visit_tasks_b, Actual Price: ' || l_parent_task_rec.actual_price
		);
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			' Before updating parent task ahl_visit_tasks_b, Estimated Price: ' || l_parent_task_rec.estimated_price
		);

     END IF;

               -- Update visit tasks table with new actual and estimate prices
			    UPDATE ahl_visit_tasks_b
				 SET actual_price = l_parent_task_rec.actual_price,
				     estimated_price = l_parent_task_rec.estimated_price,
					 object_version_number = l_parent_task_rec.object_version_number + 1
				WHERE visit_task_id = l_parent_task_rec.visit_task_id;
          ELSE
			-- If null adjust with derived values
			    UPDATE ahl_visit_tasks_b
				 SET actual_price = l_cost_price_rec.actual_price,
				     estimated_price = l_cost_price_rec.estimated_price,
					 object_version_number = l_parent_task_rec.object_version_number + 1
				WHERE visit_task_id = l_parent_task_rec.visit_task_id;

			 END IF; --Mr id not null
           END IF; --Parent estimate price or Parent actual price not null
  		  END LOOP;
		  CLOSE Get_parent_task_cur;
	 END IF; --Unassociated

         -- Visit should be updated with latest values
		 -- Actual Price
         IF  nvl(l_visit_task_dtls_rec.task_actual_price,0) > l_cost_price_rec.actual_price THEN
             l_act_price_dif := (nvl(l_visit_task_dtls_rec.task_actual_price,0) - l_cost_price_rec.actual_price);
             l_visit_task_dtls_rec.visit_actual_price := (nvl(l_visit_task_dtls_rec.visit_actual_price,0) - l_act_price_dif);
		 ELSE
             l_act_price_dif := (l_cost_price_rec.actual_price - nvl(l_visit_task_dtls_rec.task_actual_price,0));
             l_visit_task_dtls_rec.visit_actual_price := (nvl(l_visit_task_dtls_rec.visit_actual_price,0) + l_act_price_dif);
         END IF;
		 -- Estimated Price
         IF  nvl(l_visit_task_dtls_rec.task_estimated_price,0) > l_cost_price_rec.estimated_price THEN
             l_estimate_price_dif := (nvl(l_visit_task_dtls_rec.task_estimated_price,0) - l_cost_price_rec.estimated_price);
             l_visit_task_dtls_rec.visit_estimated_price := (nvl(l_visit_task_dtls_rec.visit_estimated_price,0) - l_estimate_price_dif);
		 ELSE
             l_estimate_price_dif := (l_cost_price_rec.estimated_price - nvl(l_visit_task_dtls_rec.task_estimated_price,0));
             l_visit_task_dtls_rec.visit_estimated_price := (nvl(l_visit_task_dtls_rec.visit_estimated_price,0) + l_estimate_price_dif);
         END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			' Before updating visit ahl_visits_b, Actual Price: ' || l_visit_task_dtls_rec.visit_actual_price
		);
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			' Before updating visit ahl_visits_b, Estimated Price: ' || l_visit_task_dtls_rec.visit_estimated_price
		);

     END IF;

		 -- Update Visit cost details with new values
		     UPDATE AHL_VISITS_B
			  SET actual_price = l_visit_task_dtls_rec.visit_actual_price,
			      estimated_price = l_visit_task_dtls_rec.visit_estimated_price,
				  object_version_number = l_visit_task_dtls_rec.visit_object_version_number + 1
			WHERE visit_id = l_visit_task_dtls_rec.visit_id;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			' Before updating task ahl_visit_tasks_b, Actual Price: ' || l_actual_price
		);
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			' Before updating task ahl_visit_tasks_b, Estimated Price: ' || l_estimated_price
		);

     END IF;

 END IF; -- new values are different from old values

END IF; -- Module type is JSP

		 -- Update task cost details with new values
		     UPDATE AHL_VISIT_TASKS_B
			  SET actual_price = l_cost_price_rec.actual_price,
			      estimated_price = l_cost_price_rec.estimated_price,
				  object_version_number = l_visit_task_dtls_rec.task_object_version_number + 1
			WHERE visit_task_id = l_visit_task_dtls_rec.visit_task_id;

    -- Assign out variable
	p_x_cost_price_rec.actual_price    := l_cost_price_rec.actual_price;
	p_x_cost_price_rec.estimated_price := l_cost_price_rec.estimated_price;


     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
         'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
  		' End of API p_x_cost_price_rec Actual Price: ' || p_x_cost_price_rec.actual_price
		);
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			' End of API p_x_cost_price_rec Estimated Price: ' || p_x_cost_price_rec.estimated_price
		);

		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			' End of API p_x_cost_price_rec Cost Session Id: ' || p_x_cost_price_rec.cost_session_id
		);
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			' End of API p_x_cost_price_rec Mr Session Id: ' || p_x_cost_price_rec.mr_session_id
		);

     END IF;

     -- Check Error Message stack.
     x_msg_count := FND_MSG_PUB.count_msg;
     IF x_msg_count > 0 THEN
       RAISE  FND_API.G_EXC_ERROR;
     END IF;

     -- Standard check of p_commit
     IF FND_API.TO_BOOLEAN(p_commit) THEN
        COMMIT WORK;
     END IF;

     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.Estimate_Task_Price.end',
			'At the end of PLSQL procedure'
		);
     END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   ROLLBACK TO Estimate_Task_Price;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   ROLLBACK TO Estimate_Task_Price;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK TO Estimate_Task_Price;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Estimate_Task_Price',
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
END Estimate_Task_Price;

--  -- Start of Comments --
--  Procedure name    : Get_Node_Cost_Details
--  Type              : Private(Called from Estimate and cost/price Task UI
--
--  Function          : To update task price list
--
--
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Get Node Details Parameters:
--       p_x_cost_price_rec             IN  OUT   Cost_price_rec_type,     Required
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE Get_Node_Cost_Details (
    p_api_version            IN                NUMBER,
    p_init_msg_list          IN                VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN                VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN                NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_module_type            IN                VARCHAR2  := NULL,
    x_return_status          OUT NOCOPY        VARCHAR2,
    x_msg_count              OUT NOCOPY        NUMBER,
    x_msg_data               OUT NOCOPY        VARCHAR2,
    p_x_cost_price_rec       IN OUT NOCOPY     AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type
  )
AS

  l_cost_price_rec      AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type:=p_x_cost_price_rec;
  l_api_version            CONSTANT NUMBER := 1.0;
  l_api_name               CONSTANT VARCHAR2(30) := 'GET_NODE_COST_DETAILS';

    -- yazhou 09Aug2005 starts
    -- bug fix #4542676
    -- Cursor to get visit status
    CURSOR visit_info_csr(c_visit_id IN NUMBER) IS
    SELECT status_code
    FROM ahl_visits_b
    WHERE visit_id = c_visit_id;

    l_visit_status          VARCHAR2(30);
    -- yazhou 09Aug2005 ends

BEGIN

                SAVEPOINT Get_Node_Cost_Details_pvt;

                IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
        		fnd_log.string
		        (
        			fnd_log.level_procedure,
		        	'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.Get_Node_Cost_Details',
        			'At the start of procedure Get_Node_Cost_Details_pvt and the values are visit_id:'||l_cost_price_rec.visit_id||' visit task_id'||l_cost_price_rec.visit_task_id||
                    'mr_Sesion_id'||l_cost_price_rec.mr_session_id|| ' cost session_id '||l_cost_price_rec.cost_Session_id
		        );
                END IF;

                 -- Standard call to check for call compatibility
                IF NOT Fnd_Api.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
                 RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
                 END IF;

                    -- Initialize message list if p_init_msg_list is set to TRUE
                 IF Fnd_Api.To_Boolean(p_init_msg_list) THEN
                    Fnd_Msg_Pub.Initialize;
                 END IF;

                -- Initialize API return status to success
                x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

                 IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
    		          fnd_log.string
    		          (
                      fnd_log.level_statement,
                      'AHL_VWP_TASK_CST_PR_PVT.Get_Node_Cost_Details Visit Task Id'||l_cost_price_rec.visit_task_id,
                      'Visit ID: ' || l_cost_price_rec.visit_id
                      );
                 END IF;


         If l_cost_price_rec.visit_task_id is not null
         then

    -- yazhou 09Aug2005 starts
    -- bug fix #4542676

            OPEN visit_info_csr(l_cost_price_rec.visit_id);
            FETCH visit_info_csr INTO l_visit_status;

            IF (visit_info_csr%NOTFOUND)THEN
                FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_INV_VISIT');
                FND_MSG_PUB.ADD;
                IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
		            fnd_log.string
		            (
			         fnd_log.level_exception,
			        'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			        'Visit id not found in ahl_visits_b table'
		            );
                END IF;
                CLOSE visit_info_csr;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            CLOSE visit_info_csr;

            -- Not to calculate cost if visit is in cancelled status
            IF l_visit_status <>'CANCELLED'  THEN

			   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
        		fnd_log.string
		        (
        			fnd_log.level_procedure,
		        	'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
        			'Before call to AHL_VWP_COST_PVT.calculate_wo_cost'
		        );
               END IF;

                AHL_VWP_COST_PVT.calculate_wo_cost
                (p_api_version  => p_api_version,
                p_init_msg_list => Fnd_Api.G_FALSE,
                p_commit        => Fnd_Api.G_FALSE,
                p_validation_level =>Fnd_Api.G_VALID_LEVEL_FULL,
                p_x_cost_price_rec => l_cost_price_rec,
                x_return_status =>x_return_status );

                --x_msg_count := Fnd_Msg_Pub.count_msg;
                IF x_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN

                    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
            		fnd_log.string
		            (
        	    		fnd_log.level_procedure,
		            	'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
        			    'Error thrown by AHL_VWP_COST_PVT.calculate_wo_cost'
    		        );
                    END IF;

                    RAISE  Fnd_Api.G_EXC_ERROR;
                END IF;


                IF (l_cost_price_rec.Is_Cst_Struc_updated = 'N') AND (l_cost_price_rec.workorder_id IS NOT NULL) THEN


                   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
                		fnd_log.string
		               (
        			     fnd_log.level_procedure,
    		        	'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            			'Before call to AHL_VWP_COST_PVT.calculate_task_cost'
		                );
                    END IF;

                  AHL_VWP_COST_PVT.calculate_node_cost(
                   p_visit_task_id =>l_cost_price_rec.visit_task_id,
                   p_session_id => l_cost_price_rec.cost_session_id,
                   x_actual_cost=>l_cost_price_rec.actual_cost,
                   x_estimated_cost =>l_cost_price_rec.estimated_cost,
                   x_return_status =>x_return_status );

				END IF;

              END IF; --Visit status is not cancelled

    -- yazhou 09Aug2005 ends

        ELSE
             	-- Error : Visit Task id is null
                IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
            		fnd_log.string
                        (
        	    		fnd_log.level_error,
		            	'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.Get_Node_Cost_Details',
        			    'Error : visit task id is null'
  	        	        );

                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_INPUT_MISS');
                    FND_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_ERROR;
     	       	END IF;

        END IF;

                x_msg_count := Fnd_Msg_Pub.count_msg;
                IF x_msg_count > 0 THEN
                    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
            		fnd_log.string
		            (
        	    		fnd_log.level_procedure,
		            	'ahl.plsql.AHL_VWP_COST_PVT.calculate_task_cost',
        			    'Error thrown by AHL_VWP_COST_PVT.calculate_task_cost'
    		        );
                    END IF;

                 RAISE  Fnd_Api.G_EXC_ERROR;
                END IF;

                p_x_cost_price_rec:= l_cost_price_rec;


                IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
                      COMMIT WORK;
                END IF;


 EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   ROLLBACK TO Get_Node_Cost_Details_pvt;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   ROLLBACK TO Get_Node_Cost_Details_pvt;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   ROLLBACK TO Get_Node_Cost_Details_pvt;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Get_Node_Cost_Details',
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);


 end Get_Node_Cost_Details;


PROCEDURE GET_TASK_ITEMS_NO_PRICE (
    p_api_version            IN            NUMBER,
    p_init_msg_list          IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_module_type            IN             VARCHAR2  := NULL,
    x_return_status             OUT NOCOPY        VARCHAR2,
    x_msg_count                 OUT NOCOPY        NUMBER,
    x_msg_data                  OUT NOCOPY        VARCHAR2,
    p_cost_price_rec         IN             AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type,
    x_cost_price_tbl         OUT    NOCOPY  AHL_VWP_VISIT_CST_PR_PVT.cost_price_tbl_type
    )
AS
-- Local Variables

l_valid_flag            varchar2(1);
l_error_msg_code        varchar2(30);

l_cost_price_rec        AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type:=p_cost_price_rec;

l_job_status_code      VARCHAR2(30);
l_job_status_mean      VARCHAR2(80);

l_item_tbl          AHL_VWP_RULES_PVT.ITEM_TBL_TYPE;
l_x_item_tbl         AHL_VWP_RULES_PVT.ITEM_TBL_TYPE;

l_cost_price_tbl    AHL_VWP_VISIT_CST_PR_PVT.cost_price_tbl_type;

l_api_name              VARCHAR2(30)            := 'GET_TASK_ITEMS_NO_PRICE';
l_api_version           NUMBER                  := 1.0;
l_msg_data              VARCHAR2(2000);
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;

l_z                     number:=0;
l_flag			        varchar2(1);

   l_release_visit_required     VARCHAR2(1) :='N';

-- Get task info

Cursor c_task_csr(c_visit_task_id in number)
Is
Select visit_task_id,
       task_type_code,
       mr_id,
       visit_id,
       price_list_id,
       service_request_id,
       start_date_time,
       end_date_time
from ahl_visit_tasks_vl
where visit_task_id=c_visit_task_id;

l_task_rec      c_task_csr%rowtype;

-- Get visit info

Cursor c_visit_csr(c_visit_id in number)
Is
Select visit_id,
       price_list_id,
       outside_party_flag,
       service_request_id,
       organization_id,
       any_task_chg_flag
from ahl_visits_vl
where visit_id=c_visit_id;

l_visit_rec      c_visit_csr%rowtype;

-- Get customer info

Cursor c_customer_csr(c_sr_req_id  in number)
Is
select Customer_id
from CS_INCIDENTS_ALL_B
where incident_id=c_sr_req_id;


-- AnRaj: Query changed for fixing performance bug 4919475
/*
Select mr_name,
       mr_description,
       task_number,
       task_name
from AHL_SEARCH_VISIT_TASK_V
Where TASK_ID=C_VISIT_TASK_ID;
*/
Cursor c_task_info(c_visit_task_id in number)
Is
select         mrb.title mr_name,
               mrtl.description mr_description,
               visit_task_number task_number,
               visit_task_name task_name
   from        ahl_visit_tasks_vl tsk,
               ahl_mr_headers_tl mrtl,
               ahl_mr_headers_b mrb,
               ahl_mr_routes   mrr,
               ahl_visits_vl avts
   where       tsk.mr_route_id = mrr.mr_route_id(+)
   and         mrr.mr_header_id = mrb.mr_header_id(+)
   and         mrb.mr_header_id = mrtl.mr_header_id (+)
   and         mrtl.language(+) = USERENV('LANG')
   and         nvl(tsk.status_code,'X') <> 'DELETED'
   and         avts.visit_id = tsk.visit_id
   and         avts.template_flag = 'N'
   and         tsk.task_type_code <> 'SUMMARY'
   and         visit_task_id=c_visit_task_id
   UNION
   select      title mr_name,
               mrh.description mr_description,
               visit_task_number task_number,
               visit_task_name task_name
   from        ahl_visit_tasks_vl tsk,
               ahl_mr_headers_vl mrh,
               AHL_VISITS_VL AVTS
   where       MRH.MR_HEADER_ID = TSK.MR_ID
   AND         NVL(TSK.STATUS_CODE,'X') <> 'DELETED'
   AND         AVTS.VISIT_ID = TSK.VISIT_ID
   AND         AVTS.TEMPLATE_FLAG = 'N'
   AND        VISIT_TASK_ID=C_VISIT_TASK_ID;

l_task_info_rec  c_task_info%rowtype;

-- AnRaj: Query changed for fixing performance bug 4919475
/*
Select CONCATENATED_SEGMENTS,DESCRIPTION,INVENTORY_ORG_ID,organization_name
FROM AHL_MTL_ITEMS_OU_V
WHERE INVENTORY_ITEM_ID=C_ITEM_ID
AND   INVENTORY_ORG_ID=C_ORG_ID;
*/
Cursor c_item_info(c_item_id in number,c_org_id in number)
Is
   SELECT   mtl.CONCATENATED_SEGMENTS,
            mtl.DESCRIPTION,
            mtl.organization_id INVENTORY_ORG_ID,
            hou.name organization_name
   FROM     mtl_system_items_kfv mtl,hr_organization_units hou,inv_organization_info_v org
   WHERE    mtl.organization_id = org.organization_id
   AND      hou.organization_id = org.organization_id
   AND      NVL (org.operating_unit, mo_global.get_current_org_id ()) =mo_global.get_current_org_id()
   AND      mtl.inventory_item_id=c_item_id
   AND      mtl.organization_id=c_org_id;

l_item_info_rec          c_item_info%rowtype;


BEGIN

   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.GET_TASK_ITEMS_NO_PRICE.begin',
			'At the start of PLSQL procedure'
		);

     END IF;

    SAVEPOINT GET_TASK_ITEMS_NO_PRICE_PVT;

   -- Standard call to check for call compatibility
     IF NOT Fnd_Api.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
                 RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
     END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
     IF Fnd_Api.To_Boolean(p_init_msg_list) THEN
                    Fnd_Msg_Pub.Initialize;
     END IF;

     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			'Request to get items without price for Task ID : ' || l_cost_price_rec.visit_task_id
		);

     END IF;

          -- Check for Required Parameters
     IF(l_cost_price_rec.visit_task_id IS NULL OR
	    l_cost_price_rec.visit_task_id = FND_API.G_MISS_NUM) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_INPUT_MISS');
        FND_MSG_PUB.ADD;
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		    fnd_log.string
		    (
			    fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			    'Visit Task id is mandatory but found null in input '
		    );
        END IF;
        RAISE FND_API.G_EXC_ERROR;
     END IF;



    open  c_task_csr(p_cost_price_rec.visit_Task_id);
    fetch c_task_csr into l_task_rec;


      IF c_task_csr%NOTFOUND THEN
           FND_MESSAGE.set_name( 'AHL','AHL_VWP_VISIT_TASK_INVALID' );
           FND_MSG_PUB.add;
          IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		    fnd_log.string
		    (
			    fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			    'Visit Task not found in ahl_visit_tasks_b table'
		    );
          END IF;
          CLOSE c_task_csr;
          RAISE  FND_API.G_EXC_ERROR;
     END IF;
	 CLOSE c_task_csr;

     l_cost_price_rec.visit_id:=l_task_rec.visit_id;


-- need to add notfound exception handling later

     open  c_visit_csr(l_task_rec.visit_id);
     fetch c_visit_csr into l_visit_rec;
     close c_visit_csr;


 If p_module_type = 'JSP' then

                AHL_VWP_VISIT_CST_PR_PVT.check_for_release_visit
                (
                    p_visit_id                    =>l_task_rec.visit_id,
                    x_release_visit_required      =>l_release_visit_required
                );

-- Release visit if required
    IF l_release_visit_required ='Y' THEN

		IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    		fnd_log.string
			(
				fnd_log.level_procedure,
				'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
				'Before calling ahl vwp proj prod pvt.release visit'
			);

		END IF;

		        AHL_VWP_PROJ_PROD_PVT.release_visit
		        (
		        p_api_version       =>l_api_version,
		        p_init_msg_list     =>Fnd_Api.g_false,
		        p_commit            =>Fnd_Api.g_false,
		        p_validation_level  =>Fnd_Api.g_valid_level_full,
		        p_module_type       => 'CST',
		        x_return_status     =>l_return_Status,
		        x_msg_count         =>x_msg_count,
		        x_msg_data          =>x_msg_data,
                p_visit_id          =>l_task_rec.visit_id
		        );

		IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
		  fnd_log.string
		  (
		    fnd_log.level_procedure,
		     'ahl.plsql.'||g_pkg_name||'.'||l_api_name||': End API',
		     'After calling ahl vwp proj prod pvt.Release Visit task wo Return Status : '|| l_return_status
		  );
		END IF;

       -- Check Error Message stack.
       IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
	      l_msg_count := FND_MSG_PUB.count_msg;
	      IF l_msg_count > 0 THEN
	        RAISE FND_API.G_EXC_ERROR;
	      END IF;
       END IF;

   END IF; -- release required flag

 END IF;  -- FOR P_MODULE_TYPE



-- Populate pricing attributes

                If l_visit_rec.outside_party_flag ='N'
                then
                        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_OUTSDPRTY_FLAG');
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
                 --Display an error message `Visit number visit_number is not an outside party.'
                Else
                        If l_task_rec.price_list_id is not  Null
                        then
                                l_cost_price_rec.price_list_id :=l_task_rec.price_list_id;
                        Elsif l_visit_rec.price_list_id is not Null
                        then
                                l_cost_price_rec.price_list_id :=l_visit_rec.price_list_id;
                        Else
                                FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_PRICELISTIDNULL');
                                FND_MSG_PUB.ADD;
                                RAISE FND_API.G_EXC_ERROR;

                        END IF;

                End if;

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		    fnd_log.string
		    (
			    fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			    'Price List ID :' ||l_cost_price_rec.price_list_id
 		    );
          END IF;


        l_cost_price_rec.organization_id:=l_visit_rec.organization_id;


     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		    fnd_log.string
		    (
			    fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			    'Organization ID :' ||l_cost_price_rec.organization_id
 		    );
          END IF;

-- Populate customer ID if not passed
  IF (l_cost_price_rec.Customer_Id is null) OR
  (l_cost_price_rec.Customer_Id = FND_API.G_MISS_NUM) THEN

        Open  c_customer_csr(l_visit_rec.service_request_id);
        fetch c_customer_csr into l_cost_price_rec.customer_id;
        close c_customer_csr;
  END IF;

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		    fnd_log.string
		    (
			    fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			    'Customer ID :' ||l_cost_price_rec.customer_id
 		    );
          END IF;

-- Populate currency code if not passed
IF(l_cost_price_rec.currency IS NULL OR
l_cost_price_rec.currency = FND_API.G_MISS_CHAR) THEN

      AHL_VWP_RULES_PVT.check_currency_for_costing
        (p_visit_id             =>l_task_rec.visit_id,
         x_currency_code        =>l_cost_price_rec.currency
        );

  -- Check for value is null
  IF l_cost_price_rec.currency IS NULL THEN
    FND_MESSAGE.Set_Name(G_PKG_NAME,'AHL_VWP_CST_NO_CURRENCY');
    FND_MSG_PUB.ADD;
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
       fnd_log.string
     (
         fnd_log.level_statement,
          'ahl.plsql.'||G_PKG_NAME||'.'||L_API_NAME,
         'No curency is defined for the organization of the visit'
      );
   END IF;
   RAISE FND_API.G_EXC_ERROR;
  END IF;
END IF; --If currency is null

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		    fnd_log.string
		    (
			    fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			    'Currency Code :' ||l_cost_price_rec.currency
 		    );
          END IF;



         ahl_vwp_rules_pvt.Check_Job_Status
         (
          p_id             => l_cost_price_rec.visit_task_id,
          p_is_task_flag   => 'Y',
          x_status_code    => l_job_status_code,
          x_status_meaning => l_job_status_mean);

  IF (l_job_status_code is NULL) THEN
	 l_msg_count := FND_MSG_PUB.count_msg;
	 IF l_msg_count > 0 THEN
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;
  END IF;

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		    fnd_log.string
		    (
			    fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			    'Job Status :' ||l_job_status_code
 		    );
		    fnd_log.string
		    (
			    fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			    'task start date :' ||l_cost_price_rec.task_start_date
 		    );
          END IF;



        IF (l_job_status_code='17'
         and l_cost_price_rec.task_start_date  is null)
        THEN

            l_cost_price_rec.Task_Start_Date := l_task_rec.start_date_time;
        END IF;  -- job status



     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                        fnd_log.string
                        (
                        fnd_log.level_statement,
                        'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                        'Task Start Date is: ' ||l_cost_price_rec.Task_Start_Date
                        );
                END IF;

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                        fnd_log.string
                        (
                        fnd_log.level_statement,
                        'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                        'Task Type is: ' ||l_task_rec.task_type_code
                        );
                END IF;


          If l_task_rec.MR_ID is not  Null and l_task_rec.task_type_code='SUMMARY'
          then

                                AHL_VWP_MR_CST_PR_PVT.get_mr_items_no_price
			                    (
                			        p_api_version          =>l_api_version,
                			        p_init_msg_list        =>Fnd_Api.g_false,
                			        p_commit               =>Fnd_Api.g_false,
                			        p_validation_level     =>Fnd_Api.g_valid_level_full,
                                    p_module_type          =>p_module_type,
                 			        x_return_status        =>l_return_status,
                			        x_msg_count            =>x_msg_count,
                			        x_msg_data             =>x_msg_data,
                                    p_cost_price_rec       =>l_cost_price_rec,
                                    x_cost_price_tbl       =>l_cost_price_tbl
                                );
          else



         If l_task_rec.task_type_code='UNASSOCIATED'
         then
                AHL_VWP_TASK_CST_PR_PVT.Get_Unassociated_Items
                (
                p_api_version            =>p_api_version,
                p_init_msg_list          =>Fnd_Api.G_FALSE,
                p_commit                 =>Fnd_Api.G_FALSE,
                p_validation_level       =>Fnd_Api.G_VALID_LEVEL_FULL,
                p_module_type            =>NULL,
                x_return_status          =>l_return_Status,
                x_msg_count              =>x_msg_count,
                x_msg_data               =>x_msg_data,
                p_visit_task_id          =>l_task_rec.visit_task_id,
                p_job_status_code        =>l_job_status_code,
                x_item_tbl               =>l_item_tbl
                );

          elsif l_task_rec.MR_ID is not  Null and (l_task_rec.task_type_code ='PLANNED'
                        OR   l_task_rec.task_type_code ='UNPLANNED')
          then
                        AHL_VWP_TASK_CST_PR_PVT.get_other_task_items
                        (
                        p_api_version            =>p_api_version,
                        p_init_msg_list          =>Fnd_Api.G_FALSE,
                        p_commit                 =>Fnd_Api.G_FALSE,
                        p_validation_level       =>Fnd_Api.G_VALID_LEVEL_FULL,
                        p_module_type            =>NULL,
                        x_return_status          =>l_return_Status,
                        x_msg_count              =>x_msg_count,
                        x_msg_data               =>x_msg_data,
                        p_visit_task_id          =>l_task_rec.visit_task_id,
                        p_job_status_code        =>l_job_status_code,
                        p_task_start_time        =>l_cost_price_rec.Task_Start_Date,
                        x_item_tbl               =>l_item_tbl
                        );
          end if;

                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
                THEN
                        fnd_log.string
                        (
                        fnd_log.level_statement,
                        'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                        'Number of rows in Item List table : ' ||l_item_tbl.count
                        );
                END IF;


        AHL_VWP_PRICE_PVT.get_items_without_price
        (
        p_item_tbl      =>l_item_tbl,
        p_price_list_id =>l_cost_price_rec.price_list_id,
        p_customer_id   =>l_cost_price_rec.customer_id,
        p_currency_code =>l_cost_price_rec.currency,
        x_item_tbl      =>l_x_item_tbl,
        x_return_status =>l_return_status
        );

                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
                THEN
                        fnd_log.string
                        (
                        fnd_log.level_statement,
                        'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                        'Number of rows in Item Without Price table : ' ||l_item_tbl.count
                        );
                END IF;

        If l_x_item_tbl.count > 0 then
                For i in l_x_item_tbl.first .. l_x_item_tbl.last
                loop
                        l_cost_price_tbl(i).billing_item_id := l_x_item_tbl(i).item_id;
                        l_cost_price_tbl(i).visit_task_id := l_x_item_tbl(i).visit_task_id;
                End loop;
        End if;

        if l_cost_price_tbl.count >0
        then
                For i in l_cost_price_tbl.first .. l_cost_price_tbl.last
                loop
                   open  c_task_info(l_cost_price_tbl(i).visit_task_id);
                   fetch c_task_info into l_task_info_rec;
                   If c_task_info%found
                   then
                           l_cost_price_tbl(i).mr_Title:=l_task_info_rec.MR_name;
                           l_cost_price_tbl(i).MR_Description:= l_task_info_rec.MR_Description;
                           l_cost_price_tbl(i).Visit_task_number := l_task_info_rec.task_number;
                           l_cost_price_tbl(i).task_name := l_task_info_rec.task_name;
                   End if;
                   close c_task_info;

                open  c_item_info(l_cost_price_tbl(i).billing_item_id,l_visit_rec.organization_id);
                fetch c_item_info into l_item_info_rec;
                If c_item_info%found
                then
                        l_cost_price_tbl(i).Item_name := l_item_info_rec.concatenated_segments;
                        l_cost_price_tbl(i).Item_Description := l_item_info_rec.DESCRIPTION;
                        l_cost_price_tbl(i).Organization_name:=l_item_info_rec.organization_name;
                End if;
                close c_item_info;

                End loop;
        end if;

     End IF; --- mr or other tasks

       -- Check Error Message stack.
       IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
	      l_msg_count := FND_MSG_PUB.count_msg;
	      IF l_msg_count > 0 THEN
	        RAISE FND_API.G_EXC_ERROR;
	      END IF;
       END IF;

     x_cost_price_tbl:=l_cost_price_tbl;

     -- Standard check of p_commit
     IF FND_API.TO_BOOLEAN(p_commit) THEN
        COMMIT;
     END IF;


   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.GET_TASK_ITEMS_NO_PRICE.begin',
			'At the end of PLSQL procedure'
		);

     END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
    ROLLBACK TO GET_TASK_ITEMS_NO_PRICE_PVT;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK TO GET_TASK_ITEMS_NO_PRICE_PVT;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK TO GET_TASK_ITEMS_NO_PRICE_PVT;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => L_API_NAME,
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);


END GET_TASK_ITEMS_NO_PRICE;

--  GET_TASK_ITEMS_NO_PRICE Parameters:    modified code as per dld 1.9
--  GET_UNASSOCIATED_ITEMS Parameters
--  GET_MR_SUMMARY_ITEMS
--  GET_OTHER_TASK_ITEMS
--  Refer  for more details \\Industry1-nt\telecom\Advanced Services Online\300 DLD\11.5.10\VWP\Costing_DLD_Part2_V1.8.doc
--
PROCEDURE GET_UNASSOCIATED_ITEMS (
    p_api_version            IN            NUMBER,
    p_init_msg_list          IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_module_type            IN            VARCHAR2  := NULL,
    x_return_status             OUT NOCOPY        VARCHAR2,
    x_msg_count                 OUT NOCOPY        NUMBER,
    x_msg_data                  OUT NOCOPY        VARCHAR2,
    p_visit_task_id          IN            NUMBER,
    p_job_status_code        IN            VARCHAR2,
    x_item_tbl               OUT   NOCOPY   AHL_VWP_RULES_PVT.ITEM_TBL_TYPE
    )
AS
l_api_name                  VARCHAR2(30):='GET_UNASSOCIATED_ITEMS';
l_api_version               NUMBER:= 1.0;
l_msg_data                  VARCHAR2(2000);
l_return_status             VARCHAR2(1);
l_msg_count                 NUMBER;


l_item_tbl1         AHL_VWP_RULES_PVT.ITEM_TBL_TYPE;
l_item_tbl2         AHL_VWP_RULES_PVT.ITEM_TBL_TYPE;
l_item_tbl          AHL_VWP_RULES_PVT.ITEM_TBL_TYPE;

BEGIN

   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.GET_UNASSOCIATED_ITEMS.begin',
			'At the start of PLSQL procedure'
		);

     END IF;

        SAVEPOINT GET_UNASSOCIATED_ITEMS_PVT;

        If p_job_status_code<>'17'
        then

                AHL_VWP_PRICE_PVT.Check_Item_for_Resource_Trans
                (
                p_visit_task_id   =>p_visit_task_id,
                x_item_tbl        =>l_item_tbl1,
                x_return_status   =>l_return_status
                );

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		      fnd_log.string
		      (
			    fnd_log.level_statement,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.GET_UNASSOCIATED_ITEMS.begin',
			'Number of items for resource transactions: ' || l_item_tbl1.count
		     );

              END IF;

                AHL_VWP_PRICE_PVT.Check_Item_for_Materials_Trans
                (
                p_visit_task_id   =>p_visit_task_id,
                x_item_tbl        =>l_item_tbl2,
                x_return_status   =>l_return_status
                );


     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.GET_UNASSOCIATED_ITEMS.begin',
			'Number of items for materials transactions: ' || l_item_tbl2.count
		);

     END IF;

        end if;

       -- Check Error Message stack.
       IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
	      l_msg_count := FND_MSG_PUB.count_msg;
	      IF l_msg_count > 0 THEN
	        RAISE FND_API.G_EXC_ERROR;
	      END IF;
       END IF;

               ahl_vwp_rules_pvt.merge_for_unique_items
                (
                p_item_tbl1    =>l_item_tbl1,
                p_item_tbl2    =>l_item_tbl2,
                x_item_tbl     =>l_item_tbl
                );

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.GET_UNASSOCIATED_ITEMS.begin',
			'Number of items for material and resource transactions: ' || l_item_tbl.count
		);

     END IF;

     x_item_tbl:=l_item_tbl;

     -- Standard check of p_commit
     IF FND_API.TO_BOOLEAN(p_commit) THEN
        COMMIT WORK;
     END IF;

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.GET_UNASSOCIATED_ITEMS.end',
			'At the end of PLSQL procedure'
		);

     END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   ROLLBACK TO GET_UNASSOCIATED_ITEMS_PVT;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   ROLLBACK TO GET_UNASSOCIATED_ITEMS_PVT;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK TO GET_UNASSOCIATED_ITEMS_PVT;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => L_API_NAME,
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
END GET_UNASSOCIATED_ITEMS;


PROCEDURE GET_OTHER_TASK_ITEMS (
    p_api_version            IN            NUMBER,
    p_init_msg_list          IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_module_type            IN             VARCHAR2  := NULL,
    x_return_status             OUT NOCOPY        VARCHAR2,
    x_msg_count                 OUT NOCOPY        NUMBER,
    x_msg_data                  OUT NOCOPY        VARCHAR2,
    p_visit_task_id          IN             NUMBER,
    p_job_status_code        IN             VARCHAR2,
    p_task_start_time        IN             DATE,
    x_item_tbl               OUT   NOCOPY   AHL_VWP_RULES_PVT.ITEM_TBL_TYPE
   )
AS

Cursor  c_task_csr (c_visit_task_id in number)
Is
Select a.mr_route_id,a.mr_id,b.organization_id
From  AHL_VISIT_TASKS_B a,ahl_visits_b b
Where a.visit_task_id=c_visit_task_id
and   a.visit_id=b.visit_id;

l_task_rec      c_task_csr%rowtype;

Cursor  c_mr_route_csr(c_mr_route_id in number)
Is
Select mr_route_id,route_id
From ahl_mr_Routes_v
where mr_route_id=c_mr_route_id;

l_mr_route_rec      c_mr_route_csr%rowtype;

l_item_tbl_res      AHL_VWP_RULES_PVT.ITEM_TBL_TYPE;
l_item_tbl_mat      AHL_VWP_RULES_PVT.ITEM_TBL_TYPE;
l_item_tbl1         AHL_VWP_RULES_PVT.ITEM_TBL_TYPE;
l_item_tbl2         AHL_VWP_RULES_PVT.ITEM_TBL_TYPE;
l_item_tbl          AHL_VWP_RULES_PVT.ITEM_TBL_TYPE;

l_api_name                  VARCHAR2(30):='GET_OTHER_TASK_ITEMS';
L_FULL_NAME                 CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;
l_api_version               NUMBER:= 1.0;
l_msg_data                  VARCHAR2(2000);
l_return_status             VARCHAR2(1);
l_msg_count                 NUMBER;

BEGIN

   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.GET_OTHER_TASK_ITEMS.begin',
			'At the begining of PLSQL procedure'
		);

     END IF;

    SAVEPOINT GET_OTHER_TASK_ITEMS_PVT;

    open  c_task_csr(p_visit_task_id);
    fetch c_task_csr into l_task_rec;
    close c_task_csr;

-- Job in draft status

If p_job_status_code='17'
then

     -- Task Date can not be null
    IF (p_task_start_time IS NULL OR
	    p_task_start_time = FND_API.G_MISS_DATE ) THEN

	    FND_MESSAGE.set_name( 'AHL','AHL_VWP_VALIDATE_ERROR' );
	    FND_MSG_PUB.add;

	    IF G_DEBUG='Y' THEN
	      Ahl_Debug_Pub.debug( l_full_name ||'Task Start Date is null');
        END IF;

    	RAISE FND_API.G_EXC_ERROR;
    END IF;

-- need to add notfound exception handling here

    open  c_mr_route_csr (l_task_rec.mr_route_id);
    fetch c_mr_route_csr into l_mr_route_rec;
    close c_mr_route_csr;

    AHL_VWP_PRICE_PVT.check_item_for_rt_res_req
    (
    p_visit_task_id     =>p_visit_task_id,
    p_route_id          =>l_mr_route_Rec.route_id,
    p_organization_id   =>l_task_rec.organization_id,
    p_effective_date    =>p_task_start_time,
    x_item_tbl          =>l_item_tbl_res,
    x_return_status     =>l_return_status
    );


     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.GET_OTHER_TASK_ITEMS',
			'Number of items for route resource requirements: ' || l_item_tbl_res.count
		);

     END IF;

    AHL_VWP_PRICE_PVT.Check_Item_for_Rt_Mat_Req
    (
    p_visit_task_id     =>p_visit_task_id,
    p_route_id          =>l_mr_route_rec.route_id,
    p_effective_date    =>p_task_start_time,
    x_item_tbl          =>l_item_tbl_mat,
    x_return_status     =>l_return_status
    );


   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.GET_OTHER_TASK_ITEMS',
			'Number of items for route material requirements: ' || l_item_tbl_mat.count
		);

     END IF;

    ahl_vwp_rules_pvt.merge_for_unique_items
    (
    p_item_tbl1    =>l_item_tbl_res,
    p_item_tbl2    =>l_item_tbl_mat,
    x_item_tbl     =>l_item_tbl
    );


     Else

    AHL_VWP_PRICE_PVT.check_item_for_prod_res_req
    (
     p_visit_task_id   =>p_visit_task_id,
     x_item_tbl        =>l_item_tbl_res,
     x_return_status   =>l_return_status
     );

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.GET_OTHER_TASK_ITEMS',
			'Number of items for production resource requirements: ' || l_item_tbl_res.count
		);

     END IF;

    AHL_VWP_PRICE_PVT.check_item_for_prod_mat_req
    (
     p_visit_task_id   =>p_visit_task_id,
     x_item_tbl        =>l_item_tbl_mat,
     x_return_status   =>l_return_status
     );

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.GET_OTHER_TASK_ITEMS',
			'Number of items for production material requirements: ' || l_item_tbl_mat.count
		);

     END IF;

    ahl_vwp_rules_pvt.merge_for_unique_items
    (
    p_item_tbl1    =>l_item_tbl_res,
    p_item_tbl2    =>l_item_tbl_mat,
    x_item_tbl     =>l_item_tbl2
    );

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.GET_OTHER_TASK_ITEMS',
			'Number of items for production material and resource requirements: ' || l_item_tbl.count
		);

     END IF;

    AHL_VWP_PRICE_PVT.Check_Item_for_Resource_Trans
    (
     p_visit_task_id   =>p_visit_task_id,
     x_item_tbl        =>l_item_tbl_res,
     x_return_status   =>l_return_status
     );

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.GET_OTHER_TASK_ITEMS',
			'Number of items for production resource transactions: ' || l_item_tbl_res.count
		);

     END IF;

    AHL_VWP_PRICE_PVT.Check_Item_for_Materials_Trans
    (
     p_visit_task_id   =>p_visit_task_id,
     x_item_tbl        =>l_item_tbl_mat,
     x_return_status   =>l_return_status
     );

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.GET_OTHER_TASK_ITEMS',
			'Number of items for production material transactions: ' || l_item_tbl_mat.count
		);

     END IF;

    ahl_vwp_rules_pvt.merge_for_unique_items
    (
    p_item_tbl1    =>l_item_tbl_res,
    p_item_tbl2    =>l_item_tbl_mat,
    x_item_tbl     =>l_item_tbl1
    );

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.GET_OTHER_TASK_ITEMS',
			'Number of items for production material and resource transactions: ' || l_item_tbl1.count
		);

     END IF;


    ahl_vwp_rules_pvt.merge_for_unique_items
    (
    p_item_tbl1    =>l_item_tbl2,
    p_item_tbl2    =>l_item_tbl1,
    x_item_tbl     =>l_item_tbl
    );


End if;

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN

		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.GET_OTHER_TASK_ITEMS',
			'Number of items for all requirements and transactions: ' || l_item_tbl.count
		);

     END IF;

       -- Check Error Message stack.
       IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
	      l_msg_count := FND_MSG_PUB.count_msg;
	      IF l_msg_count > 0 THEN
	        RAISE FND_API.G_EXC_ERROR;
	      END IF;
       END IF;

     x_item_tbl:=l_item_tbl;

     -- Standard check of p_commit
     IF FND_API.TO_BOOLEAN(p_commit) THEN
        COMMIT WORK;
     END IF;

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_VWP_TASK_CST_PR_PVT.GET_OTHER_TASK_ITEMS.end',
			'At the end of PLSQL procedure'
		);

     END IF;


EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   ROLLBACK TO GET_OTHER_TASK_ITEMS_PVT;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   ROLLBACK TO GET_OTHER_TASK_ITEMS_PVT;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK TO GET_OTHER_TASK_ITEMS_PVT;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => L_API_NAME,
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);

END GET_OTHER_TASK_ITEMS;


END AHL_VWP_TASK_CST_PR_PVT;

/
