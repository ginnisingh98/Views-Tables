--------------------------------------------------------
--  DDL for Package Body AHL_VWP_MR_CST_PR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_VWP_MR_CST_PR_PVT" AS
/* $Header: AHLVMCPB.pls 120.4 2006/06/07 08:27:20 anraj noship $ */

G_PKG_NAME              VARCHAR2(30):='AHL_VWP_MR_CST_PR_PVT';
G_MODULE_NAME          VARCHAR2(250):='ahl.plsql.AHL_VWP_MR_CST_PR_PVT.';
G_DEBUG 	        VARCHAR2(1)  := AHL_DEBUG_PUB.is_log_enabled;
G_APP_NAME         CONSTANT  VARCHAR2(3) := 'AHL';

-----------------------------------------------------------
-- PACKAGE
--    AHL_VWP_MR_CST_PR_PVT
--
-- PROCEDURES
--
-- NOTES
--
-- HISTORY
-- This package is Created By Rajanath Tadikonda (rtadikon) to implement
-- Costing.
--
--
-----------------------------------------------------------------

---------------------------------------------------------------------
-- PROCEDURE
--    ESTIMATE_MR_COST
--    ESTIMATE_MR_PRICE
--    Get_MR_Items_No_Price
--    Get_MR_Cost_Details
---------------------------------------------------------------------
PROCEDURE LOG_MESSAGE
(p_message_text in varchar2,
 p_api_name     in varchar2
)
as
l_api_name      varchar2(10);
begin
IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
fnd_log.string
(
fnd_log.level_statement,
G_MODULE_NAME||p_api_name,
p_message_text
);
END IF;
end LOG_MESSAGE;

PROCEDURE  POPULATE_COST_PRICE_REC
(
  p_x_cost_price_rec     IN  OUT NOCOPY AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type
)
AS
Cursor c_task_csr(c_visit_task_id in number)
Is
Select VISIT_ID,
       VISIT_TASK_ID,
       MR_ID,
       ACTUAL_COST,
       ESTIMATED_PRICE,
       PRICE_LIST_ID,
       SERVICE_REQUEST_ID,
       VISIT_TASK_NAME,
       VISIT_TASK_NUMBER
From ahl_visit_tasks_VL
where visit_task_id=c_visit_task_id;

l_task_rec              c_task_csr%rowtype;

l_visit_task_id 		AHL_VISIT_TASKS_B.visit_task_id%TYPE;

Cursor c_customer (c_incident_id  in number)
Is
select customer_id
from  CS_INCIDENTS_ALL_B
where incident_id=c_incident_id;


Cursor c_visit_csr(c_visit_id in number)
Is
Select VISIT_ID,
       ACTUAL_PRICE,
       ESTIMATED_PRICE,
       PRICE_LIST_ID,
       SERVICE_REQUEST_ID,
       OUTSIDE_PARTY_FLAG,
       ORGANIZATION_ID,
       START_DATE_TIME,
       CLOSE_DATE_TIME
From ahl_visits_vl
where visit_id=c_visit_id;
l_visit_rec              c_visit_csr%rowtype;

Cursor c_work_csr(c_visit_task_id in number)
Is
Select a.WORKORDER_ID,a.MASTER_WORKORDER_FLAG
From ahl_workorders a
where a.visit_task_id=c_visit_task_id
and  a.status_code <>'22' and a.status_code <>'7'
and  a.master_workorder_flag='Y';
l_work_rec       c_work_csr%rowtype;

-- AnRaj: Changed query for fixing the prformance bug# 4919272
Cursor c_mr_csr(c_mr_header_id in number)
Is
/*
Select MR_HEADER_ID,TITLE,DESCRIPTION,BILLING_ITEM_ID,BILLING_ITEM
From ahl_mr_headers_v
where mr_header_id=c_mr_header_id;
*/
   select	MR_HEADER_ID,
            TITLE,
            DESCRIPTION,
            BILLING_ITEM_ID,
            (	SELECT DISTINCT	CONCATENATED_SEGMENTS
               FROM					MTL_SYSTEM_ITEMS_KFV
               WHERE					INVENTORY_ITEM_ID=BILLING_ITEM_ID) BILLING_ITEM
   from		AHL_MR_HEADERS_APP_V
   where		mr_header_id=c_mr_header_id ;
l_mr_rec       c_mr_csr%rowtype;


BEGIN
open  c_task_csr(p_x_cost_price_rec.visit_task_id);
fetch c_task_csr into l_task_rec;
close c_task_csr;

open  c_mr_csr(l_task_rec.mr_id);
fetch c_mr_csr into l_mr_rec;
close c_mr_csr;


open  c_visit_csr(l_task_rec.visit_id);
fetch c_visit_csr into l_visit_rec;
close c_visit_csr;

open c_customer (l_visit_rec.service_request_id);
fetch c_customer into p_x_cost_price_rec.customer_id;
close c_customer;

open  c_work_csr(p_x_cost_price_rec.visit_task_id);
fetch c_work_csr into l_work_rec;
close c_work_csr;

AHL_VWP_RULES_PVT.check_currency_for_costing
(p_visit_id             =>l_task_rec.visit_id,
 x_currency_code        =>p_x_cost_price_rec.currency
);

p_x_cost_price_rec.VISIT_ID             :=l_task_rec.visit_id;
p_x_cost_price_rec.MR_ID                :=l_task_rec.mr_id;
--p_x_cost_price_rec.ACTUAL_COST        :=l_task_rec.ACTUAL_COST;
--p_x_cost_price_rec.ESTIMATED_COST     :=l_task_rec.
--p_x_cost_price_rec.ACTUAL_PRICE       :=l_task_rec.
p_x_cost_price_rec.ESTIMATED_PRICE      :=l_task_rec.estimated_price;
p_x_cost_price_rec.OUTSIDE_PARTY_FLAG   :=l_visit_rec.OUTSIDE_PARTY_FLAG;
p_x_cost_price_rec.PRICE_LIST_ID        :=l_task_rec.PRICE_LIST_ID;
p_x_cost_price_rec.SERVICE_REQUEST_ID   :=l_task_rec.SERVICE_REQUEST_ID;
p_x_cost_price_rec.ORGANIZATION_ID      :=l_visit_rec.ORGANIZATION_ID;
p_x_cost_price_rec.VISIT_START_DATE     :=l_visit_rec.START_DATE_TIME;
p_x_cost_price_rec.VISIT_END_DATE       :=l_visit_rec.CLOSE_DATE_TIME;
--p_x_cost_price_rec.TASK_START_DATE    :=l_task_rec.TASK_START_DATE;
--p_x_cost_price_rec.TASK_END_DATE      :=l_task_rec.TASK_END_DATE;
p_x_cost_price_rec.TASK_NAME            :=l_task_rec.VISIT_TASK_NAME;
p_x_cost_price_rec.VISIT_TASK_NUMBER    :=l_task_rec.VISIT_TASK_NUMBER;
p_x_cost_price_rec.MR_TITLE             :=l_mr_rec.TITLE;
p_x_cost_price_rec.MR_DESCRIPTION       :=l_mr_rec.DESCRIPTION;
p_x_cost_price_rec.BILLING_ITEM_ID      :=l_mr_rec.BILLING_ITEM_ID;
p_x_cost_price_rec.ITEM_NAME            :=l_mr_rec.BILLING_ITEM;
--p_x_cost_price_rec.ITEM_DESCRIPTION     :=l_mr_rec.item_Description;
p_x_cost_price_rec.WORKORDER_ID         :=l_work_rec.workorder_id;
p_x_cost_price_rec.MASTER_WO_FLAG       :=l_work_rec.MASTER_WORKORDER_FLAG;

END;

PROCEDURE  VALIDATE_EST_MR_COST
(
   p_cost_price_rec     IN  OUT NOCOPY AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type,
   x_return_status        OUT NOCOPY VARCHAR2
)
AS
BEGIN
        x_return_status:=FND_API.G_RET_STS_SUCCESS;

        IF p_cost_price_rec.visit_task_id IS NULL
        THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_VWP_ESTMCOST_TASK_ID_NULL');
                FND_MSG_PUB.ADD;
                x_return_status:=Fnd_Api.g_ret_sts_error;
        END IF;
/*
        IF p_cost_price_rec.mr_session_id IS NULL
        THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_VWP_ESTMCOST_MRSS_ID_NULL');
                FND_MSG_PUB.ADD;
        END IF;

        IF p_cost_price_rec.cost_session_id IS NULL
        THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_VWP_ESTMCOST_MCSS_ID_NULL');
                FND_MSG_PUB.ADD;
        END IF;
*/
END VALIDATE_EST_MR_COST;

PROCEDURE ESTIMATE_MR_Cost (
   p_api_version          IN  NUMBER,
   p_init_msg_list        IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit               IN  VARCHAR2  :=Fnd_Api.g_false,
   p_validation_level     IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type          IN  VARCHAR2,
   p_x_cost_price_rec      IN  OUT NOCOPY AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2
)
IS

-- Cursor to retrieve visit info
Cursor c_visit_csr(c_visit_task_id in number)
Is
Select v.visit_id, v.any_task_chg_flag
From ahl_visits_b V, ahl_visit_tasks_b T
where T.visit_task_id=c_visit_task_id
AND V.visit_id = T.visit_id;

l_visit_rec              c_visit_csr%rowtype;

-- Local Variables

-- Standard in/out parameters
l_api_name       		VARCHAR2(30) := 'ESTIMATE_MR_COST ';
l_api_version  	    	NUMBER       := 1.0;
l_num_rec            	NUMBER;
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
l_return_status         VARCHAR2(1);
l_init_msg_list         VARCHAR2(10):=FND_API.G_FALSE;
l_commit VARCHAR2(30) := Fnd_Api.G_FALSE;


   l_release_visit_required     VARCHAR2(1) :='N';

   l_cost_price_rec AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type;

BEGIN

        SAVEPOINT ESTIMATE_MR_Cost_PVT;

        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                           p_api_version,
                                           l_api_name,G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF FND_API.to_boolean(p_init_msg_list)
        THEN
                FND_MSG_PUB.initialize;
        END IF;

     -- Initialize API return status to success

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     l_cost_price_rec:= p_x_cost_price_rec;


        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
        FND_LOG.STRING
        (
        FND_LOG.LEVEL_PROCEDURE,
        G_MODULE_NAME||l_api_name,
        'START OF '||L_API_NAME
        );
        END IF;


     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN

		fnd_log.string

		(

			fnd_log.level_statement,

			'ahl.plsql.AHL_VWP_MR_CST_PR_PVT.estimate_MR_cost',

			'Got request for estimating cost of Visit Task ID : ' || p_x_cost_price_rec.visit_task_id

		);

        fnd_log.string

		(

			fnd_log.level_statement,

			'ahl.plsql.AHL_VWP_MR_CST_PR_PVT.estimate_MR_cost',

			'input mr session id : ' || p_x_cost_price_rec.mr_session_id

		);

        fnd_log.string

		(

			fnd_log.level_statement,

			'ahl.plsql.AHL_VWP_MR_CST_PR_PVT.estimate_MR_cost',

			'input cost session id : ' || p_x_cost_price_rec.cost_session_id

		);

     END IF;


        VALIDATE_EST_MR_COST
       	(p_cost_price_rec     =>l_cost_price_rec,
         x_return_status      =>x_return_status
        );

          IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
               IF G_DEBUG='Y' THEN
                 AHL_DEBUG_PUB.Debug( G_MODULE_NAME||l_api_name ||' Validate Estimate MR Cost errored');
               END IF;
               RAISE Fnd_Api.G_EXC_ERROR;
          END IF;


-- Retrieve visit information

 open  c_visit_csr(l_cost_price_rec.visit_task_id);
 fetch c_visit_csr into l_visit_rec;
 close c_visit_csr;

-- Need to release the visit only if this API is called from front-end direcly

 IF p_module_type = 'JSP' THEN

     AHL_VWP_VISIT_CST_PR_PVT.check_for_release_visit
     (
          p_visit_id                    =>l_visit_rec.visit_id,
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

	    ahl_vwp_proj_prod_pvt.release_visit (
	           p_api_version => l_api_version,
	           p_init_msg_list => p_init_msg_list,
	           p_commit => l_commit,
	           p_validation_level => p_validation_level,
               p_module_type => 'CST',
	           p_visit_id => l_visit_rec.visit_id,
	           x_return_status => l_return_status,
	           x_msg_count => l_msg_count,
	           x_msg_data => l_msg_data);

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

   END IF;  -- released required flag

END IF; --- p_module type = 'JSP'

                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                fnd_log.string
                (
                fnd_log.level_statement, G_MODULE_NAME||l_api_name,
                'Before Call to AHL_VWP_COST_PVT.estimate_wo_cost'
                );
                END IF;

        AHL_VWP_COST_PVT.estimate_wo_cost
        (p_x_cost_price_rec     =>l_cost_price_rec,
         x_return_status        =>x_return_status);

        IF FND_MSG_PUB.count_msg > 0
        THEN
                x_msg_count := l_msg_count;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF FND_API.TO_BOOLEAN(p_commit) THEN
                     COMMIT;
        END IF;


     p_x_cost_price_rec.Is_Cst_Struc_updated  := l_cost_price_rec.Is_Cst_Struc_updated;

     p_x_cost_price_rec.cost_session_id       := l_cost_price_rec.cost_session_id;

     p_x_cost_price_rec.mr_session_id         := l_cost_price_rec.mr_session_id;

        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                           G_MODULE_NAME||l_api_name,
                          'At the start of the procedure');
        END IF;


EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO ESTIMATE_MR_Cost_PVT;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO ESTIMATE_MR_Cost_PVT;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO ESTIMATE_MR_Cost_PVT;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_unexp_error)
      THEN
         Fnd_Msg_Pub.add_exc_msg (G_PKG_NAME, l_api_name);
      END IF;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END ESTIMATE_MR_COST;


------
------      Estimate MR Price
------

PROCEDURE ESTIMATE_MR_PRICE (
   p_api_version          IN  NUMBER,
   p_init_msg_list        IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit               IN  VARCHAR2  :=Fnd_Api.g_false,
   p_validation_level     IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type          IN  VARCHAR2,
   p_x_cost_price_rec     IN  OUT NOCOPY   AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2
)
AS
-- Cursor to get task price and mr info

Cursor c_task_csr(c_visit_task_id in number)
Is
Select visit_task_id, visit_id,
actual_price,
estimated_price,
mr_id,
start_date_time,
end_date_time
From ahl_visit_tasks_b
where visit_task_id=c_visit_task_id;

l_task_rec              c_task_csr%rowtype;

-- Cursor to retrieve visit info
Cursor c_visit_csr(c_visit_id in number)
Is
Select VISIT_ID,
       ACTUAL_PRICE,
       ESTIMATED_PRICE,
       PRICE_LIST_ID,
       SERVICE_REQUEST_ID,
       OUTSIDE_PARTY_FLAG,
       ORGANIZATION_ID,
       START_DATE_TIME,
       any_task_chg_flag
From ahl_visits_b
where visit_id=c_visit_id;

l_visit_rec              c_visit_csr%rowtype;

-- Cursor to get all the immediate child of the given task
Cursor c_all_task_csr(c_visit_task_id in number,c_visit_id in number)
Is
Select visit_task_id,
task_type_code,
mr_id,
start_date_time,
end_date_time
from ahl_visit_tasks_b
where visit_id = c_visit_id
AND NVL(status_code, 'Y') <> NVL ('DELETED', 'X')
and originating_task_id = c_visit_task_id
and mr_id is not null;

l_all_task_rec          c_all_task_csr%rowtype;

-- Cursor to get customer ID with given service request ID

Cursor c_customer (c_incident_id  in number)
Is
select customer_id
from  CS_INCIDENTS_ALL_B
where incident_id=c_incident_id;

l_customer_id	CS_INCIDENTS_ALL_B.CUSTOMER_ID%TYPE;

-- Cursor to get MR billing Item and UOM code

-- AnRaj: Changed query for fixing the prformance bug# 4919272
Cursor c_mr_csr(c_mr_id in number, c_org_id in number)
Is
   SELECT	mr.billing_item_id, mr.mr_header_id,mtls.primary_uom_code UOM_CODE
	FROM		AHL_MR_HEADERS_APP_V mr, mtl_system_items_b mtls
	WHERE		mr.mr_header_id = c_mr_id
	AND		mr.billing_item_id = mtls.inventory_item_id
	AND		mtls.organization_id = c_org_id
	AND		billing_item_id IS NOT NULL;

--Post11510. Added to get summary task start, end time
CURSOR get_summary_task_times_csr(x_task_id IN NUMBER)IS
      SELECT min(start_date_time)
      FROM ahl_visit_tasks_vl VST
      START WITH visit_task_id  = x_task_id
      AND NVL(VST.status_code, 'Y') <> NVL ('DELETED', 'X')
      CONNECT BY originating_task_id = PRIOR visit_task_id;

l_mr_rec    		   c_mr_csr%rowtype;

-- Define local variables

l_z                     number:=0;

l_flag			        varchar2(1);
l_price			        NUMBER:=0;
l_module_type  		    VARCHAR2(30);

l_job_status_code VARCHAR2(30);
l_job_status_meaning VARCHAR2(80);


l_cost_price_rec        AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type:=p_x_cost_price_rec;
l_temp_cost_price_rec   AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type;

-- Standard in/out parameters
l_api_name       		VARCHAR2(30) := 'ESTIMATE_MR_PRICE ';
L_FULL_NAME         CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;
l_api_version  	    	NUMBER       := 1.0;
l_num_rec            	NUMBER;
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
l_return_status         VARCHAR2(1);
l_init_msg_list         VARCHAR2(10):=FND_API.G_FALSE;
l_commit VARCHAR2(30) := Fnd_Api.G_FALSE;

-- Variables for price calculation
l_actual_price          NUMBER:=0;
l_estimate_price        NUMBER:=0;
l_actual_price_diff     NUMBER:=0;
l_estimated_price_diff  NUMBER:=0;

-- for task derivation
BEGIN

IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
			       'At the start of the procedure');
END IF;

-- Standard start of API savepoint
SAVEPOINT ESTIMATE_MR_PRICE_PVT;

-- Initialize message list if p_init_msg_list is set to TRUE
IF FND_API.To_Boolean( p_init_msg_list) THEN
FND_MSG_PUB.Initialize;
END IF;

-- Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;


IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
	     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': ',
			       'Request for Estimating Price for Task ID: '||l_cost_price_rec.visit_task_id);
END IF;

IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
	     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': ',
			       'Request for Estimating Price for Currency Code: '||l_cost_price_rec.currency);
END IF;


-- Check for Required Parameters
IF(l_cost_price_rec.visit_task_id IS NULL OR
l_cost_price_rec.visit_task_id = FND_API.G_MISS_NUM) THEN
         FND_MESSAGE.Set_Name(G_PKG_NAME,'AHL_VWP_CST_INPUT_MISS');
         FND_MSG_PUB.ADD;


         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
	             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': ',
			       'Visit Task id is mandatory but found null in input ');
         END IF;
        RAISE FND_API.G_EXC_ERROR;
END IF;

-- Retrieve visit task info

 OPEN c_task_csr(l_cost_price_rec.visit_task_id) ;
 FETCH c_task_csr INTO l_task_rec;

 IF c_task_csr%NOTFOUND THEN
     FND_MESSAGE.set_name( 'AHL','AHL_VWP_VISIT_TASK_INVALID' );
     FND_MSG_PUB.add;

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
              'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': ',
    	      ' Visit Task not found in ahl_visit_tasks_b table ');
     END IF;

     CLOSE c_task_csr;
     RAISE FND_API.G_EXC_ERROR;
 END IF;
 CLOSE c_task_csr;

-- Retrieve visit info

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
	             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': ',
			       'After Task Rec ');
         END IF;

 open  c_visit_csr(l_task_rec.visit_id);
 fetch c_visit_csr into l_visit_rec;
 close c_visit_csr;


         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
	             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': ',
			       'After Visit Rec ');

	             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': ',
			       'p_module_type:  '||p_module_type);
         END IF;

-- Need to release the visit only if this API is called from front-end direcly

 IF p_module_type = 'JSP' THEN

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
	             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': ',
			      'Before calling ahl vwp task cost.Estimate Task Cost');
    END IF;

	--Call estimate task cost
	Estimate_MR_Cost (
	p_api_version => l_api_version,
	p_init_msg_list => p_init_msg_list,
	p_commit => l_commit,
	p_validation_level => p_validation_level,
	p_module_type => p_module_type,
	p_x_cost_price_rec => l_cost_price_rec,
	x_return_status => l_return_status,
	x_msg_count => l_msg_count,
	x_msg_data => l_msg_data);


    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
	             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
	    'ahl.plsql.'||g_pkg_name||'.'||l_api_name||': End API',
	    'After calling ahl vwp task cost pvt.Estimate Task cost Return Status : '|| l_return_status
	    );
	END IF;

-- Check Error Message stack.
    if (l_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
	   l_msg_count := FND_MSG_PUB.count_msg;
	   IF l_msg_count > 0 THEN
	    RAISE FND_API.G_EXC_ERROR;
	   END IF;
    END IF;


    --Assign the out variable
    p_x_cost_price_rec.cost_session_id := l_cost_price_rec.cost_session_id;
    p_x_cost_price_rec.mr_session_id := l_cost_price_rec.mr_session_id;
    p_x_cost_price_rec.Is_Cst_Struc_updated := l_cost_price_rec.Is_Cst_Struc_updated;


 END IF; --Module type JSP

--- Check job status

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
	             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': ',
			       'before check job status');
         END IF;

  AHL_VWP_RULES_PVT.check_job_status
  (
         p_id               =>l_cost_price_rec.visit_task_id,
         p_is_task_flag     =>'Y',
         x_status_code      =>l_job_status_code,
         x_status_meaning   =>l_job_status_meaning
   );

  IF (l_job_status_code is NULL) THEN
	 l_msg_count := FND_MSG_PUB.count_msg;
	 IF l_msg_count > 0 THEN
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;
  END IF;



 --- Populate attributes required by pricing API

-- Populate customer ID if not passed
  IF (l_cost_price_rec.Customer_Id is null) OR
  (l_cost_price_rec.Customer_Id = FND_API.G_MISS_NUM) THEN

        open c_customer (l_visit_rec.service_request_id);
        fetch c_customer into l_cost_price_rec.Customer_Id;
        close c_customer;
  END IF;


-- Populate currency code if not passed
IF(l_cost_price_rec.currency IS NULL OR
l_cost_price_rec.currency = FND_API.G_MISS_CHAR) THEN

   ahl_vwp_rules_pvt.check_currency_for_costing
   (
      p_visit_id => l_task_rec.visit_id,
      x_currency_code => l_cost_price_rec.currency);

-- Error Handling
   IF l_cost_price_rec.currency IS NULL THEN
      FND_MESSAGE.Set_Name(G_PKG_NAME,'AHL_VWP_CST_NO_CURRENCY');
      FND_MSG_PUB.ADD;

      IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
          fnd_log.string(
            fnd_log.level_error,
            'ahl.plsql.'||G_PKG_NAME||'.'||L_API_NAME,
            'No curency is defined for the organization of the visit'
         );
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
END IF; --If currency is null


-- Get the visit price list if not passed
IF (l_visit_rec.price_list_id IS NULL OR
	l_visit_rec.price_list_id = FND_API.G_MISS_NUM ) THEN
	FND_MESSAGE.set_name( 'AHL','AHL_VWP_PRICE_LIST_INVALID' );
	FND_MSG_PUB.add;
		IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
		fnd_log.level_error,
		'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
		'Price list not found for Visit'
		);
		END IF;
	RAISE FND_API.G_EXC_ERROR;
END IF;

  l_cost_price_rec.PRICE_LIST_ID:=l_visit_rec.price_list_id;
  l_cost_price_rec.Organization_Id:=l_visit_rec.organization_id;


IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN

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
'Visit Id : ' || l_task_rec.visit_id
);

fnd_log.string
(
fnd_log.level_statement,
'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
'Currency : ' || l_cost_price_rec.currency
);

fnd_log.string
(
fnd_log.level_statement,
'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
'Price List Id : ' || l_cost_price_rec.PRICE_LIST_ID
);

fnd_log.string
(
fnd_log.level_statement,
'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
'Organization ID : ' || l_cost_price_rec.Organization_Id
);

fnd_log.string
(
fnd_log.level_statement,
'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
'MR ID : ' || l_task_rec.mr_id
);

fnd_log.string
(
fnd_log.level_statement,
'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
'Task Start Time : ' || l_task_rec.START_DATE_TIME
);

END IF;

-- Retrieve MR info
 open  c_mr_csr(l_task_rec.mr_id, l_visit_rec.organization_id);

 fetch c_mr_csr into l_mr_rec;


 if c_mr_csr%found
 then  --  billing item is associated to MR

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
         fnd_log.string
           (fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'billing item found' );
    END IF;


    OPEN get_summary_task_times_csr(l_cost_price_rec.visit_task_id);
    FETCH get_summary_task_times_csr INTO l_cost_price_rec.task_start_date ;
    CLOSE get_summary_task_times_csr;

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

         AHL_VWP_PRICE_PVT.get_item_price
                            (p_item_id          =>l_mr_rec.billing_item_id,
                             p_price_list_id    =>l_cost_price_rec.price_list_id,
                             p_customer_id      =>l_cost_price_rec.customer_id,
                             p_currency_code    =>l_cost_price_rec.currency,
                             p_effective_date   =>l_cost_price_rec.task_start_date,
                             p_uom_code         =>l_mr_rec.uom_code,
                             x_item_price       =>l_price,
                             x_return_status    =>l_return_status
                            );



       -- Check Error Message stack.
       IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
	      l_msg_count := FND_MSG_PUB.count_msg;
	      IF l_msg_count > 0 THEN
	        RAISE FND_API.G_EXC_ERROR;
	      END IF;
       END IF;

                    l_cost_price_rec.actual_price       := nvl(l_price,0);
                    l_cost_price_rec.estimated_price    := nvl(l_price,0);
                    l_actual_price       := nvl(l_price,0);
                    l_estimate_price    := nvl(l_price,0);


   --- If no billing item is associated then calculate price for all the immediate childen

	Else

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string(
                fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Billing Item not found');


   END IF;

             --initialize input

            l_temp_cost_price_rec.currency := l_cost_price_rec.currency;

            l_temp_cost_price_rec.customer_id := l_cost_price_rec.customer_id;

            l_temp_cost_price_rec.actual_price := NULL;

            l_temp_cost_price_rec.estimated_price := NULL;

            l_temp_cost_price_rec.PRICE_LIST_ID:=l_cost_price_rec.price_list_id;

            l_temp_cost_price_rec.Organization_Id:=l_cost_price_rec.organization_id;


            IF P_MODULE_TYPE='JSP' THEN
               l_module_type:='MR';
            ELSE
               l_module_type:='VST';
            END IF;



       -- get all the immediate child tasks
        open  c_all_task_csr(l_cost_price_rec.visit_task_id,l_task_rec.visit_id);
		loop
                  fetch c_all_task_csr into l_all_task_rec;
			      exit when c_all_task_csr%notfound;


   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
(
fnd_log.level_statement,
'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
'Task ID:  ' || l_all_task_rec.visit_task_id
);


    fnd_log.string
(
fnd_log.level_statement,
'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
'Task Type Code:  ' || l_all_task_rec.task_type_code
);


    fnd_log.string
(
fnd_log.level_statement,
'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
'Task MR ID:  ' || l_all_task_rec.MR_ID
);

   END IF;

            l_temp_cost_price_rec.visit_task_id := l_all_task_rec.visit_task_id;
            l_temp_cost_price_rec.Task_Start_Date := l_all_task_rec.START_DATE_TIME;


            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                fnd_log.string
                                (
                                fnd_log.level_statement,
                                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                                'task_start_date : ' ||l_temp_cost_price_rec.task_start_date
                                );
                                END IF;


        If l_all_task_rec.task_type_code =  'SUMMARY' and l_all_task_rec.MR_ID is not Null
        then -- Child MRs



                                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                fnd_log.string
                                (
                                fnd_log.level_statement,
                                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                                'Before call to AHL_VWP_MR_CST_PR_PVT.estimate_mr_price'
                                );
                                END IF;



			        AHL_VWP_MR_CST_PR_PVT.estimate_mr_price
			        (
			        p_api_version          =>l_api_version,
			        p_init_msg_list        =>Fnd_Api.g_false,
			        p_commit               =>Fnd_Api.g_false,
			        p_validation_level     =>Fnd_Api.g_valid_level_full,
                    P_MODULE_TYPE          =>l_module_type,
			        x_return_status        =>x_return_Status,
			        x_msg_count            =>x_msg_count,
			        x_msg_data             =>x_msg_data,
                    p_x_cost_price_rec     =>l_temp_cost_price_rec);


	else     --- all other tasks

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN

     fnd_log.string
(
fnd_log.level_statement,
'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
'Unplanned/Planned/Unassociated Tasks'
);

   END IF;


                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                fnd_log.string
                (
                fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Before call to AHL_VWP_TASK_CST_PR_PVT.estimate_task_price'
                );
                END IF;


                AHL_VWP_TASK_CST_PR_PVT.estimate_task_price
                (
                 p_api_version           =>l_api_version,
                 p_init_msg_list         =>Fnd_Api.g_false,
                 p_commit                =>Fnd_Api.g_false,
                 p_validation_level      =>Fnd_Api.g_valid_level_full,
                 p_module_type           =>l_module_type,
                 x_return_status         =>x_return_Status,
                 x_msg_count             =>x_msg_count,
                 x_msg_data              =>x_msg_data,
                 p_x_cost_price_rec      =>l_temp_cost_price_rec);

           end if;  -- if child mr or other tasks


                    l_actual_price       := nvl(l_actual_price,0)  + nvl(l_temp_cost_price_rec.actual_price,0);
                    l_estimate_price    := nvl(l_estimate_price,0) +nvl(l_temp_cost_price_rec.estimated_price,0);


	    end loop;
        close c_all_task_csr;

      end if; -- c_mr_csr

      close c_mr_csr;

  --- Assign the total price

                    l_cost_price_rec.actual_price       := l_actual_price;
                    l_cost_price_rec.estimated_price    := l_estimate_price;

  -- Update Visit price if there is any change in price
  -- Only required when called from front-end directly

          If  p_module_type = 'JSP'
              then

                        If  l_task_rec.Actual_price > l_actual_price
                        then
                                l_actual_price_diff := l_task_rec.Actual_price-l_actual_price;
                                l_visit_rec.actual_price :=  l_visit_rec.actual_price - l_actual_price_diff;
                        Else
                                l_actual_price_diff :=  l_actual_price - l_task_rec.Actual_price ;
                                l_visit_rec.actual_price :=  l_visit_rec.actual_price + l_actual_price_diff;
                        End if;

                        If  l_task_rec. Estimated_price > l_estimate_price
                        then
                                l_estimated_price_diff := l_task_rec.Estimated_price - l_estimate_price;
                                l_visit_rec.Estimated_price :=l_visit_rec.Estimated_price - l_estimated_price_diff;
                        Else
                                l_estimated_price_diff :=  l_estimate_price - l_task_rec. Estimated_price ;
                                l_visit_rec.Estimated_price :=l_visit_rec. Estimated_price + l_estimated_price_diff;
                        End if;

                        Update AHL_VISITS_B
                        set actual_price=l_visit_rec.actual_price,
                        estimated_price=l_visit_rec.estimated_price
                        where visit_id=l_visit_rec.visit_id;


                        Update AHL_VISIT_TASKS_B
                        set actual_price=l_actual_price,
                        estimated_price=l_estimate_price
                        where visit_task_id=l_task_rec.visit_task_id;


            Else -- called from Visit


                        Update AHL_VISIT_TASKS_B
                        set actual_price=l_actual_price,
                        estimated_price=l_estimate_price
                        where visit_task_id=l_task_rec.visit_task_id;
            End if;

-- assign output parameters

        p_x_cost_price_rec.estimated_price:=l_cost_price_rec.estimated_price;
        p_x_cost_price_rec.actual_price:=l_cost_price_rec.actual_price;


   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN

     fnd_log.string
(
fnd_log.level_statement,
'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
'MR Estimated Price:  ' || p_x_cost_price_rec.estimated_price
);

          fnd_log.string
(
fnd_log.level_statement,
'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
'MR Actual Price:  ' || p_x_cost_price_rec.actual_price
);

   END IF;


        IF FND_API.TO_BOOLEAN(p_commit) THEN
                     COMMIT;
        END IF;

        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
        G_MODULE_NAME||'.'||l_api_name,'At the end of the procedure');
        END IF;


EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO ESTIMATE_MR_PRICE_PVT;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO ESTIMATE_MR_PRICE_PVT;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO ESTIMATE_MR_PRICE_PVT;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_unexp_error)
      THEN
         Fnd_Msg_Pub.add_exc_msg (G_PKG_NAME, l_api_name);
      END IF;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END ESTIMATE_MR_PRICE;


PROCEDURE get_mr_items_no_price(
   p_api_version          IN  NUMBER,
   p_init_msg_list        IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit               IN  VARCHAR2  :=Fnd_Api.g_false,
   p_validation_level     IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type          IN  VARCHAR2,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2,
   p_cost_price_rec       IN  AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type,
   x_cost_price_tbl       OUT    NOCOPY  AHL_VWP_VISIT_CST_PR_PVT.cost_price_tbl_type

)
AS

Cursor c_task_csr(c_task_id number)
Is
Select visit_task_id,
       visit_id,
       price_list_id,
       mr_id, start_date_time
       from Ahl_visit_tasks_vl
       where visit_task_id=c_task_id;
l_task_rec       c_task_csr%rowtype;

Cursor c_visit_csr(c_visit_id number)
Is
Select visit_id,
       price_list_id,
       service_Request_id,
       organization_id,
       outside_party_flag
From AHL_VISITS_B
Where VISIT_ID=C_VISIT_ID;

l_visit_rec     c_visit_csr%rowtype;

-- AnRaj: Changed query for fixing the prformance bug# 4919272
Cursor c_mr_header(c_mr_header_id number)
Is
/*SELECT 1
From AHL_MR_HEADERS_V
WHERE MR_HEADER_ID=C_MR_HEADER_ID;
*/
	SELECT 1
	From   AHL_MR_HEADERS_APP_V
	WHERE  MR_HEADER_ID=C_MR_HEADER_ID ;

-- Cursor to get MR billing Item and UOM code
-- AnRaj: Changed query for fixing the prformance bug# 4919272
Cursor c_mr_csr(c_mr_id in number, c_org_id in number)
Is
	SELECT	mr.billing_item_id,
				mr.mr_header_id,
				mtls.primary_uom_code UOM_CODE
	FROM		AHL_MR_HEADERS_APP_V mr, mtl_system_items_b mtls
	WHERE		mr.MR_HEADER_ID = C_MR_ID
	AND		mr.BILLING_ITEM_ID = mtls.INVENTORY_ITEM_ID
	AND		mtls.organization_id = c_org_id
	AND		billing_item_id IS NOT NULL ;

l_mr_rec                c_mr_csr%rowtype;

-- Cursor to get all the immediate child of the given task
Cursor c_all_task_csr(c_visit_task_id in number,c_visit_id in number)
Is
Select visit_task_id,task_type_code,
mr_id, start_date_time
from ahl_visit_tasks_b
where visit_id = c_visit_id
AND NVL(status_code, 'Y') <> NVL ('DELETED', 'X')
and originating_task_id = c_visit_task_id
and mr_id is not null;

l_all_task_rec          c_all_task_csr%rowtype;

-- Cusor to get customer id

Cursor c_customer_csr (c_incident_id  in number)
Is
select customer_id
from  CS_INCIDENTS_ALL_B
where incident_id=c_incident_id;


-- AnRaj: Changed query for fixing the prformance bug# 4919272
-- Cursor to get task infomation
/*Select mr_name,
       mr_description,
       task_number,
       task_name
from AHL_SEARCH_VISIT_TASK_V
Where TASK_ID=C_VISIT_TASK_ID;
*/
-- AnRaj: Changed the query to remove the use of AHL_MR_HEADERS_VL
-- Bug Number : 5208387
Cursor c_task_info(c_visit_task_id in number)
Is
   select      mrb.title mr_name,
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
   AND         visit_task_id=c_visit_task_id
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
   AND         VISIT_TASK_ID=c_visit_task_id;

l_task_info_rec  c_task_info%rowtype;

-- cursor to get item information
Cursor c_item_info(c_item_id in number,c_org_id in number)
Is
/*
Select CONCATENATED_SEGMENTS,DESCRIPTION,INVENTORY_ORG_ID,organization_name
FROM AHL_MTL_ITEMS_OU_V
WHERE INVENTORY_ITEM_ID=C_ITEM_ID
AND   INVENTORY_ORG_ID=C_ORG_ID;
*/
-- AnRaj: Changed the cursor query for issues mentioned in Bug Number:5258318
select   mtl.concatenated_segments,
         mtl.description,
         mtl.organization_id inventory_org_id,
         hou.name organization_name
from     mtl_system_items_kfv mtl,
         hr_organization_units hou,
         inv_organization_info_v org
where    mtl.organization_id = org.organization_id
and      hou.organization_id = org.organization_id
and      nvl (org.operating_unit, mo_global.get_current_org_id ())=mo_global.get_current_org_id()
and      mtl.inventory_item_id=c_item_id
and      mtl.organization_id=c_org_id ;


l_item_info_rec          c_item_info%rowtype;

--Post11510. Added to get summary task start, end time
CURSOR get_summary_task_times_csr(x_task_id IN NUMBER)IS
      SELECT min(start_date_time)
      FROM ahl_visit_tasks_vl VST
      START WITH visit_task_id  = x_task_id
      AND NVL(VST.status_code, 'Y') <> NVL ('DELETED', 'X')
      CONNECT BY originating_task_id = PRIOR visit_task_id;

-- Local variables

   l_cost_price_rec     AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type:=p_cost_price_rec;
   l_temp_cost_price_rec     AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type;

   L_API_VERSION     		NUMBER := 1.0;
   L_API_NAME                   VARCHAR2(30) :='GET_MR_ITEMS_NO_PRICE';
   L_FULL_NAME         CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;
   l_msg_data              VARCHAR2(2000);
   l_return_status         VARCHAR2(1);
   l_msg_count             NUMBER;

   l_release_visit_required     VARCHAR2(1) :='N';


   l_cost_price_tbl     AHL_VWP_VISIT_CST_PR_PVT.cost_price_tbl_type;
   l_cost_price_tbl1    AHL_VWP_VISIT_CST_PR_PVT.cost_price_tbl_type;

   l_job_status_code       ahl_workorders_v.job_status_code%type;
   l_job_status_mean       ahl_workorders_v.job_status_meaning%type;

   l_price                 number:=0;
   l_index                 NUMBER:=0;

	l_dummy                 NUMBER;
    l_z                     number:=0;
    l_flag			        varchar2(1);
    l_module_type  		    VARCHAR2(30);


BEGIN

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
			    'At the start of the procedure');
        END IF;

        SAVEPOINT  Get_MR_Items_No_Price_pvt;

        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                           p_api_version,
                                           l_api_name,G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF FND_API.to_boolean(p_init_msg_list)
        THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- initialize return status

        x_return_status:=FND_API.G_RET_STS_SUCCESS;

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
                FND_MESSAGE.Set_Name('AHL','AHL_VWP_CST_INPUT_MISS');
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

        -- retrieve task info

        Open  c_task_csr(l_cost_price_rec.visit_task_id);

        Fetch c_task_csr into l_task_rec;

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

        -- Get visit info

        Open  c_visit_csr(l_task_rec.visit_id);
        Fetch c_visit_csr into l_visit_rec;
        If c_visit_csr%notfound
        Then
                Fnd_Message.SET_NAME('AHL','AHL_VWP_VISIT_INVALID');
                Fnd_Msg_Pub.ADD;
                Close c_visit_csr;
                RAISE FND_API.G_EXC_ERROR;
        End if;
        Close c_visit_csr;

        -- Need to release visit only if the module type is JSP

        If p_module_type = 'JSP' then

          AHL_VWP_VISIT_CST_PR_PVT.check_for_release_visit
         (
                    p_visit_id                    =>l_task_rec.visit_id,
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

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		    fnd_log.string
		  (
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
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

   -- check if MR id is valid
   IF l_task_rec.mr_id is not null
   Then
                Open  c_mr_header(l_task_rec.mr_id);
                Fetch c_mr_header into 	l_dummy;
                If c_mr_header%notfound
                Then
                     Fnd_Message.SET_NAME('AHL','AHL_VWP_MR_HEADER_ID_NULL');
                     Fnd_Msg_Pub.ADD;
                     Close c_mr_header;
                     RAISE FND_API.G_EXC_ERROR;
                End if;
                Close c_mr_header;
    End if;

    -- Check outside party flag

    If l_visit_rec.outside_party_flag ='N'
    then
                 FND_MESSAGE.Set_Name('AHL','AHL_VWP_CST_OUTSDPRTY_FLAG');
                 FND_MSG_PUB.ADD;
                 RAISE FND_API.G_EXC_ERROR;
                --Display an error message `Visit number visit_number is not an outside party.'
     END if;


-- Populate pricing attributes

-- Populate price list ID

     if l_visit_rec.price_list_id is not Null and l_visit_rec.price_list_id <> FND_API.G_MISS_NUM
     then
                  l_cost_price_rec.price_list_id :=l_visit_rec.price_list_id;
     Else
                  FND_MESSAGE.Set_Name('AHL','AHL_VWP_CST_PRICELISTIDNULL'); --AHL_VWP_PRICE_LIST_ID_NULL
                  FND_MSG_PUB.ADD;
                  RAISE FND_API.G_EXC_ERROR;

     END IF;


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

         -- Error handling
        IF l_cost_price_rec.currency IS NULL THEN
             FND_MESSAGE.Set_Name(G_PKG_NAME,'AHL_VWP_CST_NO_CURRENCY');
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

     --- Check for job status

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
			    'task start date passed in :' ||l_cost_price_rec.task_start_date
 		    );
    END IF;

    --- Check to see if billing item is associated
    open  c_mr_csr(l_task_rec.mr_id, l_visit_rec.organization_id);
    fetch c_mr_csr into l_mr_rec;

    IF c_mr_csr%found
    then  ----  billing item is associated to MR

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string(fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'billing item found');
    END IF;

    OPEN get_summary_task_times_csr(l_cost_price_rec.visit_task_id);
    FETCH get_summary_task_times_csr INTO l_cost_price_rec.task_start_date ;
    CLOSE get_summary_task_times_csr;

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

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN

		    fnd_log.string
		    (
			    fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			    'current task start date  :' ||l_cost_price_rec.task_start_date
 		    );
     END IF;

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                        fnd_log.string
                        (
                        fnd_log.level_statement,
                        'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                        'Before call to AHL_VWP_PRICE_PVT.get_item_price'
                        );
     END IF;

    AHL_VWP_PRICE_PVT.get_item_price
   (
                        p_item_id          =>l_mr_rec.billing_item_id,
                        p_price_list_id    =>l_cost_price_rec.price_list_id,
                        p_customer_id      =>l_cost_price_rec.customer_id,
                        p_currency_code    =>l_cost_price_rec.currency,
                        p_effective_date   =>l_cost_price_rec.task_start_date,
                        p_uom_code         =>l_mr_rec.uom_code,
                        x_item_price       =>l_price,
                        x_return_status    =>l_return_status
     );

    -- Check Error Message stack.
    IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
	      l_msg_count := FND_MSG_PUB.count_msg;
	      IF l_msg_count > 0 THEN
	        RAISE FND_API.G_EXC_ERROR;
	      END IF;
    END IF;

    -- no price set up for the mr billing item

    If l_price is  Null
    then
                           l_cost_price_tbl(0).billing_item_id  := l_mr_rec.billing_item_id;
                           l_cost_price_tbl(0).visit_task_id    := l_task_rec.visit_task_id;
                           l_cost_price_tbl(0).mr_id            := l_mr_rec.mr_header_id;


                   --- Populate infomation to be displayed on UI


                   open  c_task_info(l_cost_price_tbl(0).visit_task_id);
                   fetch c_task_info into l_task_info_rec;
                   If c_task_info%found
                   then
                           l_cost_price_tbl(0).mr_Title:=l_task_info_rec.MR_name;
                           l_cost_price_tbl(0).MR_Description:= l_task_info_rec.MR_Description;
                           l_cost_price_tbl(0).Visit_task_number := l_task_info_rec.task_number;
                           l_cost_price_tbl(0).task_name := l_task_info_rec.task_name;
                   End if;
                   close c_task_info;

                open  c_item_info(l_cost_price_tbl(0).billing_item_id,l_visit_rec.organization_id);
                fetch c_item_info into l_item_info_rec;
                If c_item_info%found
                then
                        l_cost_price_tbl(0).Item_name := l_item_info_rec.concatenated_segments;
                        l_cost_price_tbl(0).Item_Description := l_item_info_rec.DESCRIPTION;
                        l_cost_price_tbl(0).Organization_name:=l_item_info_rec.organization_name;
                End if;
                close c_item_info;

     End if;   -- item price is null

   --- If no billing item is associated then check the item price for all the immediate childen

     Else

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
          fnd_log.string
         (
            fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'Billing Item not found'
          );
         END IF;

         --initialize input

        l_temp_cost_price_rec.currency := l_cost_price_rec.currency;

        l_temp_cost_price_rec.customer_id := l_cost_price_rec.customer_id;

        l_temp_cost_price_rec.PRICE_LIST_ID:=l_cost_price_rec.price_list_id;

        l_temp_cost_price_rec.Organization_Id:=l_cost_price_rec.organization_id;

        IF P_MODULE_TYPE='JSP' THEN
            l_module_type:='MR';
        END IF;

       -- get all the immediate child tasks
        open  c_all_task_csr(l_cost_price_rec.visit_task_id,l_task_rec.visit_id);
		loop
                  fetch c_all_task_csr into l_all_task_rec;
			      exit when c_all_task_csr%notfound;


        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
             fnd_log.string
           (
               fnd_log.level_statement,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
               'Current Task ID:  ' || l_all_task_rec.visit_task_id
           );

             fnd_log.string
           (
               fnd_log.level_statement,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
               'Task Type Code:  ' || l_all_task_rec.task_type_code
            );

             fnd_log.string
           (
            fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
             'Task MR ID:  ' || l_all_task_rec.MR_ID
           );

         END IF;

         --initialize input
         l_temp_cost_price_rec.visit_task_id := l_all_task_rec.visit_task_id;
         l_temp_cost_price_rec.Task_Start_Date := l_all_task_rec.START_DATE_TIME;

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                                fnd_log.string
                                (
                                fnd_log.level_statement,
                                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                                'task_start_date : ' ||l_temp_cost_price_rec.task_start_date
                                );
         END IF;

         If l_all_task_rec.task_type_code =  'SUMMARY' and l_all_task_rec.MR_ID is not Null
         then -- Child MRs


                    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                               fnd_log.string
                              (
                               fnd_log.level_statement,
                                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                                'Child MR'
                               );

                                fnd_log.string
                                (
                                fnd_log.level_statement,
                                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                                'Before call to AHL_VWP_MR_CST_PR_PVT.get_mr_items_no_price'
                                );
                    END IF;

                                AHL_VWP_MR_CST_PR_PVT.get_mr_items_no_price
			                    (
                			        p_api_version          =>l_api_version,
                			        p_init_msg_list        =>Fnd_Api.g_false,
                			        p_commit               =>Fnd_Api.g_false,
                			        p_validation_level     =>Fnd_Api.g_valid_level_full,
                                    p_module_type          =>l_module_type,
                 			        x_return_status        =>l_return_status,
                			        x_msg_count            =>x_msg_count,
                			        x_msg_data             =>x_msg_data,
                                    p_cost_price_rec       =>l_temp_cost_price_rec,
                                    x_cost_price_tbl       =>l_cost_price_tbl1
                                );
                               IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
                                   RAISE Fnd_Api.G_EXC_ERROR;
                               END IF;
        	else     --- all other tasks


                    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                               fnd_log.string
                              (
                               fnd_log.level_statement,
                                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                                'Unplanned/Planned/Unassociated Tasks'
                               );
                                fnd_log.string
                                (
                                fnd_log.level_statement,
                                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                                'Before call to AHL_VWP_TASK_CST_PR_PVT.GET_TASK_ITEMS_NO_PRICE'
                                );

                    END IF;


                                AHL_VWP_TASK_CST_PR_PVT.GET_TASK_ITEMS_NO_PRICE
                                (
                                p_api_version            =>p_api_version,
                                p_init_msg_list          =>Fnd_Api.G_FALSE,
                                p_commit                 =>Fnd_Api.G_FALSE,
                                p_validation_level       =>Fnd_Api.G_VALID_LEVEL_FULL,
                                p_module_type            =>l_module_type,
                                x_return_status          =>l_return_status,
                                x_msg_count              =>x_msg_count,
                                x_msg_data               =>x_msg_data,
                                p_cost_price_rec         =>l_temp_cost_price_rec,
                                x_cost_price_tbl         =>l_cost_price_tbl1
                                );
                               IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
                                   RAISE Fnd_Api.G_EXC_ERROR;
                               END IF;

      	END IF; ----- if child mr or other tasks

       -- Merge the return value of the child to the current total
        if  l_cost_price_tbl.count =0 then

           l_cost_price_tbl :=l_cost_price_tbl1;

        elsif l_cost_price_tbl1.count >0
           then

                l_index:=l_cost_price_tbl.count;

                for i in l_cost_price_tbl1.first .. l_cost_price_tbl1.last
                loop
                        l_cost_price_tbl(l_index):=l_cost_price_tbl1(i);
                        l_index:=l_index+1;
                end  loop;

        end if;

	        end loop;
        	close c_all_task_csr;

  end if;   -- billing item associated to mr

  close c_mr_csr;

       -- Check Error Message stack.
       IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
	      l_msg_count := FND_MSG_PUB.count_msg;
	      IF l_msg_count > 0 THEN
	        RAISE FND_API.G_EXC_ERROR;
	      END IF;
       END IF;

        x_cost_price_tbl:=l_cost_price_tbl;


   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN

          fnd_log.string
         (
             fnd_log.level_statement,
              'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
              'Total number of items w/o price for the MR:  ' || x_cost_price_tbl.count
          );

   END IF;

   IF FND_API.TO_BOOLEAN(p_commit) THEN
          COMMIT;
   END IF;

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
        'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
        'At the end of the procedure');
   END IF;


EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Get_MR_Items_No_Price_pvt;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO Get_MR_Items_No_Price_pvt;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Get_MR_Items_No_Price_pvt;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_unexp_error)
      THEN
         Fnd_Msg_Pub.add_exc_msg (G_PKG_NAME, l_api_name);
      END IF;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END Get_MR_Items_No_Price;



PROCEDURE Get_MR_Cost_Details(
   p_api_version          IN  NUMBER,
   p_init_msg_list        IN  VARCHAR2 :=Fnd_Api.g_false,
   p_commit               IN  VARCHAR2 :=Fnd_Api.g_false,
   p_validation_level     IN  NUMBER   :=Fnd_Api.g_valid_level_full,
   p_module_type          IN  VARCHAR2,
   p_x_cost_price_rec     IN  OUT NOCOPY   AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type,
   x_return_status        OUT NOCOPY     VARCHAR2,
   x_msg_count            OUT NOCOPY     NUMBER,
   x_msg_data             OUT NOCOPY     VARCHAR2
)
AS
l_api_name     CONSTANT VARCHAR2(30) := 'Get_MR_Cost_Details';
l_api_version  CONSTANT NUMBER       := 1.0;
l_num_rec               NUMBER;
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
l_return_status         VARCHAR2(1);
l_init_msg_list         VARCHAR2(10):=FND_API.G_FALSE;

l_visit_status          VARCHAR2(30);


-- Define Local Cursors
    CURSOR visit_info_csr(p_visit_id IN NUMBER) IS
    SELECT status_code
    FROM ahl_visits_b
    WHERE visit_id = p_visit_id;


Cursor  c_task_rec(c_visit_task_id NUMBER)
Is
SELECT actual_price,ESTIMATEd_price, MR_Id
FROM AHL_VISIT_TASKS_VL
WHERE VISIT_TASK_ID=C_VISIT_TASK_ID;

l_visit_task_rec        c_task_rec%rowtype;

l_cost_price_rec        AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type:=p_x_cost_price_rec;


l_job_status_code       varchar2(30);
l_job_status_meaning    varchar2(80);

-- AnRaj: Changed query for fixing the prformance bug# 4919272
Cursor c_mr_csr(c_mr_id in number)
Is
/*
Select title, billing_item_id,description,mr_header_id
From ahl_mr_headers_v
where mr_header_id=c_mr_id;
*/
	Select title, billing_item_id,description,mr_header_id
	From   AHL_MR_HEADERS_APP_V
	where  mr_header_id=c_mr_id;

l_mr_rec                c_mr_csr%rowtype;


BEGIN

        SAVEPOINT Get_MR_Cost_Details_PVT;

        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                           p_api_version,
                                           l_api_name,G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF FND_API.to_boolean(p_init_msg_list)
        THEN
                FND_MSG_PUB.initialize;
        END IF;

        x_return_status:=FND_API.G_RET_STS_SUCCESS;

        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                G_MODULE_NAME||'.'||l_api_name,'At the start of the procedure');
        END IF;

        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                G_MODULE_NAME||'.'||l_api_name,'Visit Task ID:'||p_x_cost_price_rec.visit_task_id);
        END IF;

        POPULATE_COST_PRICE_REC(l_cost_price_rec);

        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                G_MODULE_NAME||'.'||l_api_name,'Visit ID:'||l_cost_price_rec.visit_id);
        END IF;

     OPEN visit_info_csr(l_cost_price_rec.visit_id);
     FETCH visit_info_csr INTO l_visit_status;


        IF (visit_info_csr%NOTFOUND)THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_INV_VISIT');
            FND_MSG_PUB.ADD;
            IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
		        fnd_log.string
		        (
			        fnd_log.level_exception,
			        G_MODULE_NAME||'.'||l_api_name,
			        'Visit id not found in ahl_visits_b table'
		        );
            END IF;
            CLOSE visit_info_csr;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
     CLOSE visit_info_csr;

--
        --DBMS_OUTPUT.PUT_LINE('STAGE 2');

        If l_cost_price_rec.visit_task_id is not null then
        --DBMS_OUTPUT.PUT_LINE('STAGE 2');

        open  c_task_rec(l_cost_price_rec.visit_task_id);
        fetch c_task_rec  into l_visit_task_rec;
        if c_task_rec%found
        then
                If l_visit_task_rec.actual_price  is  Null
                then
                        l_cost_price_rec.actual_price:= NULL;
                Else
                        l_cost_price_rec.actual_price:=l_visit_task_rec.actual_price;
                end if;

                If l_visit_task_rec.ESTIMATEd_price  is null
                then
                        l_cost_price_rec.ESTIMATEd_price := NULL;
                Else
                        l_cost_price_rec.ESTIMATEd_price := l_visit_task_rec.ESTIMATEd_price;
                end if;
        end  if;
        end if;
        close c_task_rec;



 -- Not to calculate cost if visit is in cancelled status
 IF l_visit_status <>'CANCELLED'  THEN


           log_message('Before call to AHL_VWP_COST_PVT.estimate_wo_cost',l_api_name);

           log_message('before l_cost_price_rec.visit_id'||l_cost_price_rec.visit_id,l_api_name);
           log_message('before call to calculate_wo_cost l_cost_price_rec.estimated_price:'||l_cost_price_rec.estimated_price,l_api_name);
           log_message('before call to calculate_wo_cost l_cost_price_rec.estimated_cost :'||l_cost_price_rec.estimated_cost ,l_api_name);

            AHL_VWP_COST_PVT.calculate_wo_cost(
            p_api_version       =>p_api_version,
            p_init_msg_list     =>p_init_msg_list,
            p_commit            =>FND_API.G_FALSE,
            p_validation_level  =>p_validation_level,
            p_x_cost_price_rec  =>l_cost_price_rec,
            x_return_status     =>x_return_status
            );
            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

           log_message('after call to calculate_wo_cost l_cost_price_rec.visit_id'||l_cost_price_rec.visit_id,l_api_name);
           log_message('after call to calculate_wo_cost l_cost_price_rec.estimated_price:'||l_cost_price_rec.estimated_price,l_api_name);
           log_message('after call to calculate_wo_cost l_cost_price_rec.estimated_cost :'||l_cost_price_rec.estimated_cost ,l_api_name);


        IF(l_cost_price_rec.Is_Cst_Struc_updated = 'N') AND (l_cost_price_rec.workorder_id IS NOT NULL)
            then
                log_message('Before call to AHL_VWP_COST_PVT.calculate_mr_cost',l_api_name);
                log_message('bef call to calculate_mr_cost l_cost_price_rec.visit_id'||l_cost_price_rec.visit_id,l_api_name);
                log_message('bef call to calculate_mr_cost l_cost_price_rec.estimated_price:'||l_cost_price_rec.estimated_price,l_api_name);
                log_message('bef call to calculate_mr_cost l_cost_price_rec.estimated_cost :'||l_cost_price_rec.estimated_cost ,l_api_name);


                AHL_VWP_COST_PVT.calculate_mr_cost
                (
                p_visit_task_id    =>l_cost_price_rec.visit_task_id  ,
                p_session_id       =>l_cost_price_rec.mr_session_id,
                x_actual_cost      =>l_cost_price_rec.actual_cost,
                x_ESTIMATEd_cost   =>l_cost_price_rec.ESTIMATEd_cost,
                x_return_status    =>x_return_status
                );
                IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
                   RAISE Fnd_Api.G_EXC_ERROR;
                END IF;

                log_message('after call to calculate_mr_cost l_cost_price_rec.visit_id'||l_cost_price_rec.visit_id,l_api_name);
                log_message('after call to calculate_mr_cost l_cost_price_rec.estimated_price:'||l_cost_price_rec.estimated_price,l_api_name);
                log_message('after call to calculate_mr_cost l_cost_price_rec.estimated_cost :'||l_cost_price_rec.estimated_cost ,l_api_name);


                log_message(
                'Before call to AHL_VWP_COST_PVT.get_profit_or_loss',l_api_name
                );


            AHL_VWP_COST_PVT.get_profit_or_loss
            (
             p_actual_price     =>l_cost_price_rec.actual_price ,
             p_ESTIMATEd_price  =>l_cost_price_rec.ESTIMATEd_price,
             p_actual_cost      =>l_cost_price_rec.actual_cost,
             p_ESTIMATEd_cost   =>l_cost_price_rec.ESTIMATEd_cost,
             x_actual_profit    =>l_cost_price_rec.actual_profit,
             x_ESTIMATEd_profit =>l_cost_price_rec.ESTIMATEd_profit,
             x_return_status    =>x_return_status
             );
             IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
                 RAISE Fnd_Api.G_EXC_ERROR;
             END IF;

        end if;


  END IF; -- status <> CANCELLED


        If l_cost_price_rec.MR_Id is not null
        then
                open  c_mr_csr(l_cost_price_rec.MR_Id);
                Fetch c_mr_csr into l_mr_rec;
                if c_mr_csr%found
                then
                        l_cost_price_rec.mr_title:=l_mr_rec.Title ;
                        l_cost_price_rec.billing_item_id:=l_mr_rec.billing_item_id;
                        l_cost_price_rec.mr_description := l_mr_rec.description;
                end if;
                close c_mr_csr;
        end if;

        IF FND_MSG_PUB.count_msg > 0
        THEN
                x_msg_count := l_msg_count;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_x_cost_price_rec:=l_cost_price_rec;
        log_message('billing_item_id :'||l_mr_rec.billing_item_id,l_api_name);


        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                G_MODULE_NAME||'.'||l_api_name,'At the end of the procedure');
        END IF;


EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Get_MR_Cost_Details_PVT;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO Get_MR_Cost_Details_PVT;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Get_MR_Cost_Details_PVT;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_unexp_error)
      THEN
         Fnd_Msg_Pub.add_exc_msg (G_PKG_NAME, l_api_name);
      END IF;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END Get_MR_Cost_Details;

END AHL_VWP_MR_CST_PR_PVT;

/
