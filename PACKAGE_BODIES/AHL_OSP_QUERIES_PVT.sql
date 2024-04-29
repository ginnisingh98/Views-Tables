--------------------------------------------------------
--  DDL for Package Body AHL_OSP_QUERIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_OSP_QUERIES_PVT" AS
/*$Header: AHLVOSQB.pls 120.4 2008/03/18 15:04:39 mpothuku ship $ */

G_PKG_NAME   CONSTANT  VARCHAR2(30) := 'AHL_OSP_QUERIES_PVT';

G_OSP_ENTERED_STATUS    CONSTANT VARCHAR2(30) := 'ENTERED';
G_EMPTY_WO_IDS_TABLE AHL_OSP_QUERIES_PVT.work_id_tbl_type;

G_VENDOR_DEPT_CLASS_CODE  CONSTANT VARCHAR2(30) := 'Vendor';

--G_DEBUG 		 VARCHAR2(1):=FND_PROFILE.VALUE('AHL_API_FILE_DEBUG_ON');
G_DEBUG                VARCHAR2(1)   := AHL_DEBUG_PUB.is_log_enabled;
G_LOG_PREFIX        CONSTANT VARCHAR2(100) := 'ahl.plsql.AHL_OSP_QUERIES_PVT';


FUNCTION Get_Suggested_Vendor(p_work_order_id  IN NUMBER ,
                              p_work_order_ids IN AHL_OSP_QUERIES_PVT.work_id_tbl_type)
  RETURN VARCHAR2;


 ----------------------------------------------------------------------------------
 -- PROCEDURE SEARCH_OSP_ORDERS
 ----------------------------------------------------------------------------------
-- This procedure Search for osp order based on the search criteria specify in parameter P_search_order_rec
-- The search result will be populated into x_results_order_tbl.
-- Start of Comments --
--  Procedure name    : Search_OSP
--  Type        : Public
--  Function    : Search OSP Order
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--      p_module_type                   IN    VARCHAR2       Default  Null
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  p_module_type                       IN      VARCHAR2               Required.
--      This parameter indicates the front-end form interface. The default value is null. If the value
--      is JSP, then this API clears out all id columns and validations are done using the values;based
--      on which the Id's are populated.
--
--  Search_OSP Parameters :
--  p_start_row           IN    NUMBER  specify the start row to populate into search result table
--  p_rows_per_page       IN    NUMBER  specify the number of row to be populated in the search result table
--  P_search_order_rec    IN    Search_Order_rec_type, specify the search criteria
--  x_results_order_tbl   OUT   Results_Order_Tbl_Type, the search Result table
--  x_results_count       OUT   NUMBER,  row count from the query, this number can be more than the number of row in search result table
--
--  Version :
--               Initial Version   1.0
--
--  End of Comments.

 PROCEDURE Search_OSP_Orders
      (
        p_api_version                   IN            NUMBER,
        p_init_msg_list                 IN            VARCHAR2,
        p_commit                        IN            VARCHAR2 ,
        p_validation_level              IN            NUMBER,
        p_default                       IN            VARCHAR2,
        p_module_type                   IN            VARCHAR2,
        p_start_row                     IN            NUMBER,
        p_rows_per_page                 IN            NUMBER,
        P_search_order_rec              IN            AHL_OSP_QUERIES_PVT.Search_Order_rec_type,
        x_results_order_tbl             OUT NOCOPY           AHL_OSP_QUERIES_PVT.Results_Order_Tbl_Type,
        x_results_count                 OUT NOCOPY           NUMBER,
        x_return_status                 OUT NOCOPY           VARCHAR2,
        x_msg_count                     OUT NOCOPY           NUMBER,
        x_msg_data                      OUT NOCOPY           VARCHAR2
      ) IS

   l_api_version      CONSTANT NUMBER := 1.0;
   l_api_name         CONSTANT VARCHAR2(30) := 'Search_OSP_Orders';

   l_search_criteria_rec  AHL_OSP_QUERIES_PVT.Search_Order_Rec_Type;
   l_results_rec AHL_OSP_QUERIES_PVT.Results_Order_Rec_Type;
   l_count NUMBER;
   i NUMBER;
   l_cur_index  NUMBER;

   l_cur AHL_OSP_UTIL_PKG.ahl_search_csr;
   l_bind_index NUMBER := 1;
   l_conditions AHL_OSP_UTIL_PKG.ahl_conditions_tbl;


   CURSOR l_department_csr(dept_id IN NUMBER, dept_code IN VARCHAR2) IS
      SELECT 'X' FROM BOM_DEPARTMENTS where DEPARTMENT_ID = dept_id AND DEPARTMENT_CODE = dept_code;

   l_junk           VARCHAR2(1);


    l_OSP_ID	              NUMBER       ;
    l_Object_version_number   NUMBER       ;
    l_Order_Number	          NUMBER       ;
    l_Order_Date	          DATE         ;
    l_Description	          VARCHAR2(2000);
    l_order_type_code         VARCHAR2(30) ;
    l_Order_Type	          VARCHAR2(80) ;
    l_status_code              VARCHAR2(30) ;
    l_Order_Status	          VARCHAR2(80) ;
    l_po_header_id            NUMBER       ;
    l_po_Number	              VARCHAR2(20) ;
    l_oe_header_id            NUMBER       ;
    l_Shipment_Number	      NUMBER       ;
    l_po_interface_header_id  NUMBER     ;

   --l_sql_string hold the query string
   l_sql_string         VARCHAR2(10000);
   l_from_string        VARCHAR2(5000);
   l_search_criteria    VARCHAR2(10000);
   l_count_query        VARCHAR2(10000);
   and_str            VARCHAR(20);
   LI_Field_Exist     BOOLEAN;   --check whether query contain search field that belong to Order Lines

   L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Search_OSP_Orders';

  BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;

	END IF;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

--Commented by mpothuku as this API is not being used. At a later point, need to consider removing the
--declaration in Spec, Record Structure for Criteria and Rosetta
/*
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  -- Begin build Query
  l_sql_string := 'SELECT  DISTINCT OSP.OSP_ORDER_ID ';
  l_sql_string := l_sql_string ||', OSP.OBJECT_VERSION_NUMBER ';
  l_sql_string := l_sql_string ||', OSP.OSP_ORDER_NUMBER ';
  l_sql_string := l_sql_string ||', OSP.ORDER_DATE ';
  l_sql_string := l_sql_string ||', OSP.DESCRIPTION';
  l_sql_string := l_sql_string ||', OSP.ORDER_TYPE_CODE ';
  l_sql_string := l_sql_string ||', OSP.ORDER_TYPE ';
  l_sql_string := l_sql_string ||', OSP.STATUS_CODE ';
  l_sql_string := l_sql_string ||', OSP.STATUS ';
  l_sql_string := l_sql_string ||', OSP.PO_HEADER_ID ';
  l_sql_string := l_sql_string ||', OSP.PO_NUMBER ';
  l_sql_string := l_sql_string ||', OSP.OE_HEADER_ID ';
  l_sql_string := l_sql_string ||', OSP.SHIPMENT_NUMBER ';
   l_sql_string := l_sql_string ||', OSP.PO_INTERFACE_HEADER_ID ';

  l_from_string :=  ' FROM AHL_OSP_ORDERS_V OSP ';

  and_str := '';
  l_search_criteria := NULL;
  LI_Field_Exist := FALSE;

  IF P_search_order_rec.Order_Number IS NOT NULL THEN
    l_search_criteria := l_search_criteria || ' UPPER(OSP.OSP_ORDER_NUMBER) LIKE UPPER (:b' || l_bind_index || ')';
    l_conditions(l_bind_index) := P_search_order_rec.Order_Number;
    l_bind_index := l_bind_index + 1;
    and_str := ' AND ';
  END IF;
  IF P_search_order_rec.Description IS NOT NULL THEN
    l_search_criteria := l_search_criteria || and_str || ' UPPER(OSP.DESCRIPTION) LIKE UPPER (:b' || l_bind_index || ')';
    l_conditions(l_bind_index) := P_search_order_rec.Description;
    l_bind_index := l_bind_index + 1;
    and_str := ' AND ';
  END IF;
  IF P_search_order_rec.Order_Type_Code IS NOT NULL THEN
    l_search_criteria := l_search_criteria || and_str || ' UPPER(OSP.ORDER_TYPE) LIKE UPPER (:b' || l_bind_index || ')';
    l_conditions(l_bind_index) := P_search_order_rec.Order_Type_Code;
    l_bind_index := l_bind_index + 1;
    and_str := ' AND ';
  END IF;
  IF P_search_order_rec.Order_Status_Code IS NOT NULL THEN
    l_search_criteria := l_search_criteria || and_str || ' UPPER(OSP.STATUS) LIKE UPPER (:b' || l_bind_index || ')';
    l_conditions(l_bind_index) := P_search_order_rec.Order_Status_Code;
    l_bind_index := l_bind_index + 1;
    and_str := ' AND ';
  END IF;
   IF P_search_order_rec.vendor IS NOT NULL THEN
    l_search_criteria := l_search_criteria || and_str || ' UPPER(OSP.VENDOR) LIKE UPPER (:b' || l_bind_index || ')';
    l_conditions(l_bind_index) := P_search_order_rec.vendor;
    l_bind_index := l_bind_index + 1;
    and_str := ' AND ';
  END IF;


  IF P_search_order_rec.job_number IS NOT NULL THEN
    l_search_criteria := l_search_criteria || and_str || ' UPPER(LI.JOB_NUMBER) LIKE UPPER (:b' || l_bind_index || ')';
    l_conditions(l_bind_index) := P_search_order_rec.job_number;
    l_bind_index := l_bind_index + 1;
    and_str := ' AND ';
    LI_Field_Exist := TRUE;
  END IF;
    IF P_search_order_rec.Project_Name IS NOT NULL THEN
    l_search_criteria := l_search_criteria || and_str || ' UPPER(LI.PROJECT_NAME) LIKE UPPER (:b' || l_bind_index || ')';
    l_conditions(l_bind_index) := P_search_order_rec.Project_Name;
    l_bind_index := l_bind_index + 1;
    and_str := ' AND ';
    LI_Field_Exist := TRUE;
  END IF;
  IF P_search_order_rec.Task_Name IS NOT NULL THEN
    l_search_criteria := l_search_criteria || and_str || ' UPPER(LI.PROJECT_TASK_NAME) LIKE UPPER (:b' || l_bind_index || ')';
    l_conditions(l_bind_index) := P_search_order_rec.Task_Name;
    l_bind_index := l_bind_index + 1;
    and_str := ' AND ';
    LI_Field_Exist := TRUE;
  END IF;
  IF P_search_order_rec.Part_Number IS NOT NULL THEN
    l_search_criteria := l_search_criteria || and_str || ' UPPER(LI.WO_PART_NUMBER) LIKE UPPER (:b' || l_bind_index || ')';
    l_conditions(l_bind_index) := P_search_order_rec.Part_Number;
    l_bind_index := l_bind_index + 1;
    and_str := ' AND ';
    LI_Field_Exist := TRUE;
  END IF;
  IF P_search_order_rec.Serial_Number IS NOT NULL THEN
    l_search_criteria := l_search_criteria || and_str || ' UPPER(LI.SERIAL_NUMBER) LIKE UPPER (:b' || l_bind_index || ')';
    l_conditions(l_bind_index) := P_search_order_rec.Serial_Number;
    l_bind_index := l_bind_index + 1;
    and_str := ' AND ';
    LI_Field_Exist := TRUE;
  END IF;
  IF P_search_order_rec.Department IS NOT NULL THEN
    l_search_criteria := l_search_criteria || and_str || ' EXISTS (SELECT OL.OSP_ORDER_LINE_ID FROM AHL_WORKORDERS_OSP_V WO, '
                                                  || ' AHL_OSP_ORDER_LINES OL WHERE '
                                                  || ' OL.OSP_ORDER_ID = OSP.OSP_ORDER_ID AND OL.WORKORDER_ID =  WO.WORKORDER_ID ';
                                                  --|| ' AND UPPER(WO.DEPARTMENT_CODE) LIKE UPPER('''|| P_search_order_rec.Department || ''')) ';

    IF P_search_order_rec.department_id IS NOT NULL THEN
      OPEN l_department_csr(P_search_order_rec.department_id, P_search_order_rec.Department);
        FETCH l_department_csr INTO l_junk;
        IF (l_department_csr%NOTFOUND) THEN
          l_search_criteria := l_search_criteria  || ' AND UPPER(WO.DEPARTMENT_CODE) LIKE UPPER (:b' || l_bind_index || '))';
          l_conditions(l_bind_index) := P_search_order_rec.Department;
        ELSE
          l_search_criteria := l_search_criteria  || ' AND WO.DEPARTMENT_ID = :b' || l_bind_index || ') ';
          l_conditions(l_bind_index) := P_search_order_rec.Department_Id;
        END IF;
      CLOSE l_department_csr;
    ELSE
      l_search_criteria := l_search_criteria  || ' AND UPPER(WO.DEPARTMENT_CODE) LIKE UPPER(:b' || l_bind_index ||')) ';
      l_conditions(l_bind_index) := P_search_order_rec.Department;
    END IF;

    l_bind_index := l_bind_index + 1;
    and_str := ' AND ';
  --  LI_Field_Exist := TRUE;
  END IF;


  IF P_search_order_rec.Has_New_PO_Line = 'Y'  OR P_search_order_rec.Has_New_PO_Line = 'N'  THEN
    l_search_criteria := l_search_criteria || and_str || ' AHL_OSP_PO_PVT.Has_New_PO_Line(OSP.OSP_ORDER_ID) = :b' || l_bind_index;
    l_conditions(l_bind_index) := P_search_order_rec.Has_New_PO_Line;
    l_bind_index := l_bind_index + 1;
    and_str := ' AND ';
  END IF;


  IF LI_Field_Exist THEN
     l_from_string := l_from_string || ', AHL_OSP_ORDER_LINES_V LI ';
     l_search_criteria := l_search_criteria || ' AND LI.OSP_ORDER_ID = OSP.OSP_ORDER_ID ';
  END IF;

  l_sql_string := l_sql_string  || l_from_string ;

  IF l_search_criteria IS NOT NULL THEN
     l_sql_string := l_sql_string || ' WHERE ' || l_search_criteria ;
  END IF;

  l_count_query := 'SELECT COUNT(*) FROM (' || l_sql_string || ')';

  l_sql_string := l_sql_string || ' ORDER BY OSP.OSP_ORDER_ID DESC ';

  IF G_DEBUG='Y' THEN
     AHL_DEBUG_PUB.debug(SUBSTR( l_sql_string, 1, 1000), 'SEARCH_OSP: ');
  END IF;

  --remove this line when not test
  --l_sql_string := l_sql_string || ' WHERE ROWNUM < 3 ';


  AHL_OSP_UTIL_PKG.OPEN_SEARCH_CURSOR(l_cur, l_conditions, l_sql_string);
  i := 0;
  l_cur_index := 0;

  LOOP
    FETCH l_cur into        l_OSP_ID	       ,
                            l_Object_version_number,
                            l_Order_Number	   ,
                            l_Order_Date	   ,
                            l_Description	   ,
                            l_order_type_code  ,
                            l_Order_Type	   ,
                            l_status_code      ,
                            l_Order_Status	   ,
                            l_po_header_id     ,
                            l_po_Number	       ,
                            l_oe_header_id     ,
                            l_Shipment_Number  ,
                            l_po_interface_header_id;
    EXIT WHEN  l_cur%NOTFOUND;
    EXIT WHEN  l_cur_index = p_start_row + p_rows_per_page;   -- stop fetching

    IF (l_cur_index >= p_start_row AND l_cur_index < p_start_row + p_rows_per_page) THEN
      x_results_order_tbl(i).OSP_ID       	     :=  l_OSP_ID      ;
      x_results_order_tbl(i).Object_version_number := l_Object_version_number ;
      x_results_order_tbl(i).Order_Number	         := l_Order_Number ;
      x_results_order_tbl(i).Order_Date	         := l_Order_Date;
      x_results_order_tbl(i).Description	         := l_Description ;
      x_results_order_tbl(i).order_type_code       := l_order_type_code ;
      x_results_order_tbl(i).Order_Type	         := l_Order_Type;
      x_results_order_tbl(i).status_code           := l_status_code;
      x_results_order_tbl(i).Order_Status	         := l_Order_Status;
      x_results_order_tbl(i).po_header_id          := l_po_header_id ;
      x_results_order_tbl(i).po_Number	         := l_po_Number   ;
      x_results_order_tbl(i).oe_header_id          := l_oe_header_id;
      x_results_order_tbl(i).Shipment_Number       := l_Shipment_Number;
      x_results_order_tbl(i).po_interface_header_id  := l_po_interface_header_id;
      i := i+1;
    END IF;

    l_cur_index := l_cur_index + 1;

  END LOOP;
  CLOSE l_cur;


  BEGIN
    AHL_OSP_UTIL_PKG.EXEC_IMMEDIATE(l_conditions, l_count_query, x_results_count);
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
      x_results_count := 0;
  END;
  IF G_DEBUG='Y' THEN
	AHL_DEBUG_PUB.debug(' x_results_count:-' || x_results_count);
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'End Procedure');
  END IF;
*/
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
 --dbms_output.put_line('Excep 1 ');
   x_return_status := FND_API.G_RET_STS_ERROR;
  -- Rollback to Search_OSP_Pvt;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

  IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, L_DEBUG_KEY, 'Execution Exception: ' || x_msg_data);
  END IF;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
 -- dbms_output.put_line('Excep 2 ');
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
 IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, L_DEBUG_KEY, 'Unexpected Exception: ' || x_msg_data);
  END IF;

 WHEN OTHERS THEN
 -- dbms_output.put_line('Excep 3 ');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Rollback to Search_OSP_Pvt;
       FND_MSG_PUB.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Search_OSP_Orders',
                               p_error_text     => SQLERRM);

    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);

  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, L_DEBUG_KEY, 'Unexpected Exception: ' || x_msg_data);
  END IF;



END Search_OSP_Orders;



----------------------------------------------------------------------------------
-- PROCEDURE Search_WO
----------------------------------------------------------------------------------
-- This procedure Search for Work orders based on the search criteria specify in parameter P_search_WO_rec
-- The search result will be populated into x_results_order_tbl.
-- Start of Comments --
--  Procedure name    : Search_OSP
--  Type        : Public
--  Function    : Search OSP Order
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--      p_module_type                   IN    VARCHAR2       Default  Null
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  p_module_type                       IN      VARCHAR2               Required.
--      This parameter indicates the front-end form interface. The default value is null. If the value
--      is JSP, then this API clears out all id columns and validations are done using the values;based
--      on which the Id's are populated.
--
--  Search_OSP Parameters :
--  p_start_row           IN    NUMBER  specify the start row to populate into search result table
--  p_rows_per_page       IN    NUMBER  specify the number of row to be populated in the search result table
--  P_search_order_rec    IN    Search_Order_rec_type, specify the search criteria
--  x_results_order_tbl   OUT   Results_Order_Tbl_Type, the search Result table
--  x_results_count       OUT   NUMBER,  row count from the query, this number can be more than the number of row in search result table
--
--  Version :
--               Initial Version   1.0
--
--  End of Comments.

PROCEDURE Search_WO
(
        p_api_version	        IN	       NUMBER,
        p_init_msg_list	        IN	       VARCHAR2 ,
        p_commit	            IN	       VARCHAR2 ,
        p_validation_level	    IN	       NUMBER  ,
        p_module_type           IN         VARCHAR2,
        p_start_row             IN         NUMBER,
        p_rows_per_page         IN         NUMBER,
        p_search_WO_rec	        IN	       AHL_OSP_QUERIES_PVT.Search_WO_Rec_Type,
        x_result_WO_tbl	        OUT NOCOPY	       AHL_OSP_QUERIES_PVT.Results_WO_Tbl_Type,
        x_results_count         OUT NOCOPY        NUMBER,
        x_return_status	        OUT NOCOPY 	   VARCHAR2,
        x_msg_count	            OUT NOCOPY 	   NUMBER,
        x_msg_data	            OUT NOCOPY 	   VARCHAR2)
 IS
  l_api_version      CONSTANT NUMBER := 1.0;
  l_api_name         CONSTANT VARCHAR2(30) := 'Search_WO';

   l_l_search_criteria_rec  AHL_OSP_QUERIES_PVT.Search_Order_Rec_Type;
   l_count NUMBER;

   Workorder_ID	       NUMBER;
   job_number	       VARCHAR2(80);
   Part_number	       VARCHAR2(40);
   Instance_number	   VARCHAR2(30);
   Serial_number	   VARCHAR2(30);
   Svc_item_number	   VARCHAR2(40);
   Svc_Description	   VARCHAR2(240);
   Suggested_Vendor    VARCHAR2(240);
   Department          VARCHAR2(10);

   l_wo_cur AHL_OSP_UTIL_PKG.ahl_search_csr;
   l_bind_index NUMBER := 1;
   l_conditions AHL_OSP_UTIL_PKG.ahl_conditions_tbl;

   CURSOR l_department_csr(dept_id IN NUMBER, dept_code IN VARCHAR2) IS
      SELECT 'X' FROM BOM_DEPARTMENTS where DEPARTMENT_ID = dept_id AND DEPARTMENT_CODE = dept_code;

   l_junk           VARCHAR2(1);
   l_sql_string       VARCHAR2(10000);
   l_search_criteria  VARCHAR2(10000);
   l_count_query      VARCHAR2(10000);
   and_str          VARCHAR2(10);

   l_cur_index   NUMBER;   -- index used by cursor
   i NUMBER;               -- index used by table

  L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Search_WO';

  BEGIN


  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;

	END IF;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

--Commented by mpothuku as this API is not being used. At a later point, need to consider removing the
--declaration in Spec, Record Structure for Criteria and Rosetta
 /*
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_sql_string := 'SELECT WORKORDER_ID';
  l_sql_string:= l_sql_string || ', JOB_NUMBER';
  l_sql_string:= l_sql_string || ', WO_PART_NUMBER';
  l_sql_string:= l_sql_string || ', ITEM_INSTANCE_NUMBER';
  l_sql_string:= l_sql_string || ', SERIAL_NUMBER ';
  l_sql_string:= l_sql_string || ', SERVICE_ITEM_NUMBER ';
  l_sql_string:= l_sql_string || ', SERVICE_ITEM_DESCRIPTION ';
  l_sql_string:= l_sql_string || ', DEPARTMENT_CODE ';



  l_sql_string:= l_sql_string || ' FROM AHL_WORKORDERS_OSP_V WO ';

 -- l_search_criteria := '';
  and_str := ' ';

 l_search_criteria := l_search_criteria || ' WO.DEPARTMENT_CLASS_CODE = ''' || G_VENDOR_DEPT_CLASS_CODE || '''';
 l_search_criteria := l_search_criteria || ' AND WO.JOB_STATUS_CODE = ''3'' ';
 l_search_criteria := l_search_criteria || ' AND NOT EXISTS (SELECT OL1.WORKORDER_ID FROM AHL_OSP_ORDER_LINES OL1 WHERE OL1.WORKORDER_ID = WO.WORKORDER_ID AND OL1.STATUS_CODE IS NULL) ';


 -- l_search_criteria := l_search_criteria || ' (WO.WORKORDER_ID NOT IN (SELECT WORKORDER_ID FROM AHL_OSP_ORDER_LINES) OR WO.WORKORDER_ID IN (SELECT WORKORDER_ID FROM AHL_OSP_ORDER_LINES WHERE JOB_STATUS_CODE IN (''PO_DELETED'', ''PO_CANCEL''))) ';

  IF p_search_WO_rec.job_number IS NOT NULL THEN
    l_search_criteria := l_search_criteria || ' AND UPPER(JOB_NUMBER) LIKE UPPER (:b' || l_bind_index || ')';
    l_conditions(l_bind_index) := p_search_WO_rec.job_number;
    l_bind_index := l_bind_index + 1;
  END IF;
  IF p_search_WO_rec.description IS NOT NULL THEN
    l_search_criteria :=  l_search_criteria || ' AND  UPPER(SERVICE_ITEM_DESCRIPTION) LIKE UPPER (:b' || l_bind_index || ')';
    l_conditions(l_bind_index) := p_search_WO_rec.description;
    l_bind_index := l_bind_index + 1;
  END IF;
  IF p_search_WO_rec.project_name IS NOT NULL THEN
    l_search_criteria := l_search_criteria || ' AND UPPER(PROJECT_NAME) LIKE UPPER (:b' || l_bind_index || ')';
    l_conditions(l_bind_index) := p_search_WO_rec.project_name;
    l_bind_index := l_bind_index + 1;
  END IF;
  IF p_search_WO_rec.task_name IS NOT NULL THEN
    l_search_criteria := l_search_criteria || ' AND UPPER(PROJECT_TASK_NAME) LIKE UPPER (:b' || l_bind_index || ')';
    l_conditions(l_bind_index) := p_search_WO_rec.task_name;
    l_bind_index := l_bind_index + 1;
  END IF;
  IF p_search_WO_rec.Part_number IS NOT NULL THEN
    l_search_criteria := l_search_criteria || ' AND UPPER(WO_PART_NUMBER) LIKE UPPER (:b' || l_bind_index || ')';
    l_conditions(l_bind_index) := p_search_WO_rec.Part_number;
    l_bind_index := l_bind_index + 1;
  END IF;
  IF p_search_WO_rec.Instance_number IS NOT NULL THEN
    l_search_criteria := l_search_criteria || ' AND UPPER(ITEM_INSTANCE_NUMBER) LIKE UPPER (:b' || l_bind_index || ')';
    l_conditions(l_bind_index) := p_search_WO_rec.Instance_number;
    l_bind_index := l_bind_index + 1;
  END IF;
  IF p_search_WO_rec.Serial_number IS NOT NULL THEN
    l_search_criteria := l_search_criteria || ' AND UPPER(SERIAL_NUMBER) LIKE UPPER (:b' || l_bind_index || ')';
    l_conditions(l_bind_index) := p_search_WO_rec.Serial_number;
    l_bind_index := l_bind_index + 1;
  END IF;
  IF p_search_WO_rec.Svc_item_number IS NOT NULL THEN
    l_search_criteria := l_search_criteria || ' AND UPPER(SERVICE_ITEM_NUMBER) LIKE UPPER (:b' || l_bind_index || ')';
    l_conditions(l_bind_index) := p_search_WO_rec.Svc_item_number;
    l_bind_index := l_bind_index + 1;
  END IF;
  IF p_search_WO_rec.Department IS NOT NULL THEN
    IF p_search_WO_rec.department_id IS NOT NULL THEN
      OPEN l_department_csr(p_search_WO_rec.department_id, p_search_WO_rec.Department);
        FETCH l_department_csr INTO l_junk;
        IF (l_department_csr%NOTFOUND) THEN
          l_search_criteria := l_search_criteria || ' AND UPPER(DEPARTMENT_CODE) LIKE UPPER (:b' || l_bind_index || ')';
          l_conditions(l_bind_index) := p_search_WO_rec.Department;
        ELSE
          l_search_criteria := l_search_criteria || ' AND DEPARTMENT_ID = :b' || l_bind_index;
          l_conditions(l_bind_index) := p_search_WO_rec.department_id;
        END IF;
      CLOSE l_department_csr;
    ELSE
      l_search_criteria := l_search_criteria || ' AND UPPER(DEPARTMENT_CODE) LIKE UPPER (:b' || l_bind_index || ')';
      l_conditions(l_bind_index) := p_search_WO_rec.Department;
    END IF;
    l_bind_index := l_bind_index + 1;
  END IF;

  IF l_search_criteria IS NOT NULL THEN
     l_sql_string := l_sql_string || ' WHERE ' || l_search_criteria;
  END IF;

  l_count_query := 'SELECT COUNT(*) FROM (' ||l_sql_string || ')';

  l_sql_string := l_sql_string || ' ORDER BY JOB_NUMBER ';

  IF G_DEBUG='Y' THEN
     AHL_DEBUG_PUB.debug(SUBSTR(l_sql_string,1, 1000), 'SEARCH_WO: ');
  END IF;

  AHL_OSP_UTIL_PKG.OPEN_SEARCH_CURSOR(l_wo_cur, l_conditions, l_sql_string);
  i := 0;
  l_cur_index := 0;
  LOOP
    FETCH  l_wo_cur INTO Workorder_ID,
                         job_number,
                         Part_number,
                         Instance_number,
                         Serial_number,
                         Svc_item_number,
                         Svc_Description,
                         Department;
    EXIT WHEN  l_wo_cur%NOTFOUND;
      EXIT WHEN  l_cur_index = p_start_row + p_rows_per_page;   -- stop fetching

    IF (l_cur_index >= p_start_row AND l_cur_index < p_start_row + p_rows_per_page) THEN
      x_result_WO_tbl(i).Workorder_ID         := Workorder_ID;
      x_result_WO_tbl(i).job_number           := job_number;
      x_result_WO_tbl(i).Part_number          := Part_number;
      x_result_WO_tbl(i).Instance_number      := Instance_number;
      x_result_WO_tbl(i).Serial_number        := Serial_number;
      x_result_WO_tbl(i).Svc_item_number      := Svc_item_number;
      x_result_WO_tbl(i).Svc_Description      := Svc_Description;
      x_result_WO_tbl(i).department          := department;

      x_result_WO_tbl(i).Suggested_Vendor     :=  Get_Suggested_Vendor(p_work_order_id => Workorder_ID,
                                                                     p_work_order_ids =>AHL_OSP_QUERIES_PVT.G_EMPTY_WO_IDS_TABLE );

      i:= i + 1;
    END IF;

    l_cur_index := l_cur_index + 1;
  END LOOP;



  BEGIN
    AHL_OSP_UTIL_PKG.EXEC_IMMEDIATE(l_conditions, l_count_query, x_results_count);
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
      x_results_count := 0;
  END;
  IF G_DEBUG='Y' THEN
	 AHL_DEBUG_PUB.debug(' x_results_count:-' || x_results_count);
  END IF;



  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'End Procedure');
  END IF;
*/
  EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
 --dbms_output.put_line('Excep 1 ');
   x_return_status := FND_API.G_RET_STS_ERROR;
  -- Rollback to Search_WO_pvt;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

   IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, L_DEBUG_KEY, 'Execution Exception: ' || x_msg_data);
    END IF;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
 -- dbms_output.put_line('Excep 2 ');
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   --Rollback to Search_WO_pvt;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);


  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, L_DEBUG_KEY, 'Unexpected Exception: ' || x_msg_data);
  END IF;

 WHEN OTHERS THEN
 -- dbms_output.put_line('Excep 3 ');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --Rollback to Search_WO_pvt;
       FND_MSG_PUB.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Search_WO',
                               p_error_text     => SQLERRM);

    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);

  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, L_DEBUG_KEY, 'Unexpected Exception: ' || x_msg_data);
  END IF;

END Search_WO;


----------------------------------------------------------------------------------
-- PROCEDURE GET_HEADER_AND_LINES
----------------------------------------------------------------------------------
----------------------------------------
-- Declare Procedures for GET_HEADER_AND_LINES --
----------------------------------------
-- This procedure Search for OSP Order Header and order lines based on the input parameter P_osp_id.
-- When the input parameter p_osp_id is null it will use input parameter P_work_order_ids to search for workorders
-- and populate into order line table.

-- Start of Comments --
--  Procedure name    : Search_OSP
--  Type        : Public
--  Function    : Search OSP Order
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--      p_module_type                   IN    VARCHAR2       Default  Null
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  p_module_type                       IN      VARCHAR2               Required.
--      This parameter indicates the front-end form interface. The default value is null. If the value
--      is JSP, then this API clears out all id columns and validations are done using the values;based
--      on which the Id's are populated.
--
--  Search_OSP Parameters :
--  P_osp_id              IN    NUMBER,                id that the search will be based on.
--  P_work_order_ids      IN    work_id_tbl_type,      List of workorder id that search will be based on if p_osp_id is null
--  x_order_header_rec    IN    order_header_rec_Type, store order header
--  x_order_lines_tbl     OUT   order_line_tbl_Type,   Store order order lines rows
--  x_msg_count           OUT   NUMBER,
--  Version :
--               Initial Version   1.0
--
--  End of Comments.
PROCEDURE GET_HEADER_AND_LINES
(
        p_api_version	          IN	NUMBER,
        p_init_msg_list	          IN	VARCHAR2 ,
        p_commit	              IN	VARCHAR2 ,
        p_validation_level	      IN    NUMBER ,
        p_module_type             IN    VARCHAR2 ,
        P_osp_id	              IN	NUMBER,
        P_work_order_ids          IN    AHL_OSP_QUERIES_PVT.work_id_tbl_type,
        x_order_header_rec	      OUT NOCOPY	AHL_OSP_QUERIES_PVT.order_header_rec_Type,
        x_order_lines_tbl	      OUT NOCOPY	AHL_OSP_QUERIES_PVT.order_line_tbl_Type,
        x_return_status	          OUT NOCOPY 	VARCHAR2,
        x_msg_count	              OUT NOCOPY 	NUMBER,
        x_msg_data	              OUT NOCOPY 	VARCHAR2

) IS

  l_api_version      CONSTANT NUMBER := 1.0;
  l_api_name         CONSTANT VARCHAR2(30) := 'GET_HEADER_AND_LINES';

  TYPE header_csr_type is REF CURSOR;
  TYPE line_csr_type  IS REF CURSOR;
  l_header_csr      header_csr_type;     --cursor to hold order header
  l_line_csr        line_csr_type;       --cursor to hold order lines


  CURSOR l_default_status_csr IS
      SELECT FND.MEANING FROM FND_LOOKUP_VALUES_VL FND
                         WHERE FND.LOOKUP_TYPE = 'AHL_OSP_STATUS_TYPE'
                          AND FND.LOOKUP_CODE = 'ENTERED';
  CURSOR l_default_buyer_csr IS
      SELECT buyer_id, full_name FROM PO_AGENTS_NAME_V, fnd_user fnd
        where buyer_id = fnd.employee_id and   fnd.user_id = fnd_global.user_id ;


  l_header_queries  VARCHAR2(10000);
  l_line_queries VARCHAR2(1000);

  l_po_header_id NUMBER;

     OSP_ID	               NUMBER;
     object_version_number NUMBER;
     order_number	       NUMBER;
     order_description	   VARCHAR2(1000);
     order_type_code        VARCHAR(30);
     order_type	           VARCHAR2(80);
     order_status_code      VARCHAR2(30);
     order_status	       VARCHAR2(80);
     order_date	           DATE;
     VENDOR_ID              NUMBER;
     vendor_name	       VARCHAR2(240);
     vendor_site_id        NUMBER;
     vendor_location	   VARCHAR2(15);
     CUSTOMER_ID            NUMBER;
     CUSTOMER               VARCHAR2(360);
     single_instance_Flag   VARCHAR2(20);
     single_instance_meaning   VARCHAR2(80);
     PO_AGENT_ID            NUMBER;
     buyer_name	           VARCHAR2(240);
     PO_HEADER_ID           NUMBER;
     po_number              VARCHAR2(80);
     po_synch_flag          VARCHAR(20);
     OE_HEADER_ID           NUMBER;
     shipment_number        NUMBER;
     CONTRACT_ID            NUMBER;
     contract_number	       VARCHAR2(120);

     L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.GET_HEADER_AND_LINES';


  BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;
  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;



  IF (P_OSP_ID IS NOT NULL) THEN


    IF G_DEBUG='Y' THEN
	   AHL_DEBUG_PUB.debug('Before Calling Associate_OSP_With_PO', 'GET_HEADER_AND_LINES: ');
    END IF;
      -- CALL PO API to synch OSP with PO
      AHL_OSP_PO_PVT.Associate_OSP_With_PO
     (
       p_api_version            => p_api_version ,
       p_init_msg_list          => p_init_msg_list,
       p_commit                 => p_commit,
       p_validation_level       => p_validation_level,
       p_default                => FND_API.G_TRUE,
       p_module_type            => p_module_type,
       p_osp_order_id           => P_OSP_ID,
       x_po_header_id           => l_po_header_id,
       x_return_status          => x_return_status,
       x_msg_count              => x_msg_count,
       x_msg_data               => x_msg_data
     );

    IF G_DEBUG='Y' THEN
      IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug('After Calling Associate_OSP_With_PO', 'GET_HEADER_AND_LINES: ');

	END IF;
       IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug('x_return_status' || x_return_status, 'GET_HEADER_AND_LINES: ');

	END IF;
        IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug('x_msg_data' || x_msg_data, 'GET_HEADER_AND_LINES: ');

	END IF;

    END IF;


     l_header_queries := 'SELECT OSP.OSP_ORDER_ID ';
     l_header_queries :=  l_header_queries || ', OSP.OBJECT_VERSION_NUMBER ';
     l_header_queries :=  l_header_queries || ', OSP.OSP_ORDER_NUMBER ';
     l_header_queries :=  l_header_queries || ', OSP.DESCRIPTION ';
     l_header_queries :=  l_header_queries || ', OSP.ORDER_TYPE_CODE';
     l_header_queries :=  l_header_queries || ', OSP.ORDER_TYPE ';
     l_header_queries :=  l_header_queries || ', OSP.STATUS_CODE ';
     l_header_queries :=  l_header_queries || ', OSP.STATUS ';
     l_header_queries :=  l_header_queries || ', OSP.ORDER_DATE ';
     l_header_queries :=  l_header_queries || ', OSP.VENDOR_ID ';
     l_header_queries :=  l_header_queries || ', OSP.VENDOR ';
     l_header_queries :=  l_header_queries || ', OSP.VENDOR_SITE_ID ';
     l_header_queries :=  l_header_queries || ', OSP.VENDOR_LOCATION ';
     l_header_queries :=  l_header_queries || ', OSP.CUSTOMER_ID ';
     l_header_queries :=  l_header_queries || ', OSP.CUSTOMER ';
     l_header_queries :=  l_header_queries || ', OSP.SINGLE_INSTANCE_FLAG ';
     l_header_queries :=  l_header_queries || ', OSP.SINGLE_INSTANCE_MEANING ';
     l_header_queries :=  l_header_queries || ', OSP.PO_AGENT_ID ';
     l_header_queries :=  l_header_queries || ', OSP.BUYER';
     l_header_queries :=  l_header_queries || ', OSP.PO_HEADER_ID ';
     l_header_queries :=  l_header_queries || ', OSP.PO_NUMBER ';
     l_header_queries :=  l_header_queries || ', OSP.PO_SYNCH_FLAG ';
     l_header_queries :=  l_header_queries || ', OSP.OE_HEADER_ID ';
     l_header_queries :=  l_header_queries || ', OSP.SHIPMENT_NUMBER ';
     l_header_queries :=  l_header_queries || ', OSP.CONTRACT_ID ';
     l_header_queries :=  l_header_queries || ', OSP.CONTRACT_NUMBER ';

     l_header_queries :=  l_header_queries || ' FROM AHL_OSP_ORDERS_V OSP ';
     l_header_queries :=  l_header_queries || ' WHERE OSP_ORDER_ID = ';
     l_header_queries :=  l_header_queries || p_osp_id;


     IF G_DEBUG='Y' THEN
		AHL_DEBUG_PUB.debug('l_header_queries:  ' || SUBSTR(l_header_queries,1, 900), 'GET_HEADER_AND_LINES: ');
    END IF;

     --dbms_output.put_line( 'SQL:' || l_header_queries );
     OPEN l_header_csr FOR l_header_queries;

     FETCH l_header_csr INTO    OSP_ID,
                                object_version_number,
                                order_number,
                                order_description,
                                order_type_code,
                                order_type,
                                order_status_code,
                                order_status,
                                order_date,
                                vendor_id,
                                vendor_name,
                                vendor_site_id,
                                vendor_location,
                                CUSTOMER_ID,
                                CUSTOMER,
                                single_instance_Flag,
                                single_instance_meaning,
                                PO_AGENT_ID,
                                buyer_name,
                                PO_HEADER_ID,
                                po_number ,
                                po_synch_flag,
                                OE_HEADER_ID,
                                shipment_number,
                                CONTRACT_ID,
                                contract_number;


      IF G_DEBUG='Y' THEN
	    AHL_DEBUG_PUB.debug('After Fetch l_header_queries:  ' , 'GET_HEADER_AND_LINES: ');
      END IF;

       x_order_header_rec.OSP_ID                     := OSP_ID;
       x_order_header_rec.object_version_number      := object_version_number;
       x_order_header_rec.order_number               := order_number;
       x_order_header_rec.order_description          := order_description;
       x_order_header_rec.order_type_code            := order_type_code;
       x_order_header_rec.order_type                 := order_type;
       x_order_header_rec.order_status_code          := order_status_code;
       x_order_header_rec.order_status               := order_status;
       x_order_header_rec.order_date                 := order_date;
       x_order_header_rec.vendor_id                  := vendor_id;
       x_order_header_rec.vendor_name                := vendor_name;
       x_order_header_rec.vendor_site_id             := vendor_site_id;
       x_order_header_rec.vendor_location            := vendor_location;
       x_order_header_rec.CUSTOMER_ID                := CUSTOMER_ID;
       x_order_header_rec.CUSTOMER                   := CUSTOMER;
       x_order_header_rec.single_instance_Flag       := single_instance_Flag;
       x_order_header_rec.single_instance_meaning    := single_instance_meaning;
       x_order_header_rec.PO_AGENT_ID                := PO_AGENT_ID;
       x_order_header_rec.buyer_name                 := buyer_name;
       x_order_header_rec.PO_HEADER_ID               := PO_HEADER_ID;
       x_order_header_rec.po_number                  := po_number;
       x_order_header_rec.po_synch_flag              := po_synch_flag;
       x_order_header_rec.OE_HEADER_ID               := OE_HEADER_ID;
       x_order_header_rec.shipment_number            := shipment_number;
       x_order_header_rec.CONTRACT_ID                := CONTRACT_ID;
       x_order_header_rec.contract_number            := contract_number;

   CLOSE l_header_csr;

  IF G_DEBUG='Y' THEN
	 AHL_DEBUG_PUB.debug('After Assign to x_order_header_rec:  ' , 'GET_HEADER_AND_LINES: ');
  END IF;

  ELSE
    --In Create Mode get Default Values for Order Header
    x_order_header_rec.order_date := SYSDATE;
    x_order_header_rec.order_status_code := G_OSP_ENTERED_STATUS;

    OPEN l_default_status_csr;
      FETCH l_default_status_csr INTO x_order_header_rec.order_status;

    OPEN l_default_buyer_csr;
      FETCH l_default_buyer_csr INTO x_order_header_rec.PO_AGENT_ID,
                                     x_order_header_rec.buyer_name;
     --default vendor name
     x_order_header_rec.vendor_name := Get_Suggested_Vendor(p_work_order_id => null,
                                                            p_work_order_ids => P_work_order_ids);

  END IF;

  AHL_OSP_QUERIES_PVT.GET_ORDER_LINES
(
        p_api_version         => p_api_version ,
        p_init_msg_list	      => p_init_msg_list,
        p_commit	          => p_commit,
        p_validation_level	  => p_validation_level,
        p_module_type         => p_module_type,
        P_osp_id	          => P_osp_id,
        P_work_order_ids      => P_work_order_ids,
        x_order_lines_tbl	  => x_order_lines_tbl,
        x_return_status	      => x_return_status,
        x_msg_count	          => x_msg_count,
        x_msg_data	          => x_msg_data

);

IF x_order_lines_tbl.COUNT > 0 THEN
  FOR i IN x_order_lines_tbl.FIRST..x_order_lines_tbl.LAST  LOOP
    IF(x_order_lines_tbl(i).status_code IS NULL) THEN
      -- use header status
      x_order_lines_tbl(i).status_code := x_order_header_rec.order_status_code;
      x_order_lines_tbl(i).status      := x_order_header_rec.order_status;
    END IF;
  END LOOP;
END IF;


  -- Check return status.
  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Standard check of p_commit
  /*IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT WORK;
  END IF;
  */

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false
    );

IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'End Procedure');
END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
 --dbms_output.put_line('Excep 1 ');
   x_return_status := FND_API.G_RET_STS_ERROR;
   --Rollback to get_header_lines_pvt;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
  IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, L_DEBUG_KEY, 'Execution Exception: ' || x_msg_data);
  END IF;


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
 -- dbms_output.put_line('Excep 2 ');
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  -- Rollback to get_header_lines_pvt;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, L_DEBUG_KEY, 'Unexpected Exception: ' || x_msg_data);
  END IF;

 WHEN OTHERS THEN
  --dbms_output.put_line('Excep 3 ');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Rollback to get_header_lines_pvt;
       FND_MSG_PUB.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'GET_HEADER_AND_LINES',
                               p_error_text     => SQLERRM);

    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, L_DEBUG_KEY, 'Unexpected Exception: ' || x_msg_data);
    END IF;
END Get_Header_And_Lines;


----------------------------------------------------------------------------------
-- PROCEDURE GET_ORDER_LINES
----------------------------------------------------------------------------------
-- This procedure Search for OSP Order lines based on the input parameter P_osp_id.
-- When the input parameter p_osp_id is null it will use input parameter P_work_order_ids to search for workorders
-- and populate into order line table.

-- Start of Comments --
--  Procedure name    : Search_OSP
--  Type        : Public
--  Function    : Search OSP Order
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--      p_module_type                   IN    VARCHAR2       Default  Null
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  p_module_type                       IN      VARCHAR2               Required.
--      This parameter indicates the front-end form interface. The default value is null. If the value
--      is JSP, then this API clears out all id columns and validations are done using the values;based
--      on which the Id's are populated.
--
--  Search_OSP Parameters :
--  P_osp_id              IN    NUMBER,                id that the search will be based on.
--  P_work_order_ids      IN    work_id_tbl_type,      List of workorder id that search will be based on if p_osp_id is null
--  x_order_lines_tbl     OUT   order_line_tbl_Type,   Store order order lines rows
--  x_msg_count           OUT   NUMBER,
--  Version :
--               Initial Version   1.0
--
--  End of Comments.
PROCEDURE GET_ORDER_LINES
(
        p_api_version	          IN	NUMBER,
        p_init_msg_list	          IN	VARCHAR2,
        p_commit	              IN	VARCHAR2,
        p_validation_level	      IN	NUMBER,
        p_module_type             IN    VARCHAR2,
        P_osp_id	              IN	NUMBER,
        P_work_order_ids           IN    AHL_OSP_QUERIES_PVT.work_id_tbl_type,
        x_order_lines_tbl	      OUT NOCOPY	AHL_OSP_QUERIES_PVT.order_line_tbl_Type,
        x_return_status	          OUT NOCOPY 	VARCHAR2,
        x_msg_count	              OUT NOCOPY 	NUMBER,
        x_msg_data	              OUT NOCOPY 	VARCHAR2

) IS

  l_api_version      CONSTANT NUMBER := 1.0;
  l_api_name         CONSTANT VARCHAR2(30) := 'GET_HEADER_AND_LINES';

  TYPE line_csr_type  IS REF CURSOR;
  l_line_csr        line_csr_type;       --cursor to hold order lines

  l_line_queries VARCHAR2(10000);
  i      NUMBER;
  testNum NUMBER;

    l_osp_order_line_id	      NUMBER;
	l_object_version_number 	  NUMBER;
    l_osp_order_id              NUMBER;
    l_osp_line_number           NUMBER;
	l_status_code			      VARCHAR2(30);
    l_status     			      VARCHAR2(80);
    l_po_line_type_id    		  NUMBER;
    l_po_line_type    		  VARCHAR2(25);
    l_service_item_id    		  NUMBER;
    l_service_item_number    	  VARCHAR2(40);
	l_service_item_description  VARCHAR2(2000);
	l_service_item_uom_code  	  VARCHAR2(3);
    l_need_by_date           	  DATE;
    l_ship_by_date              DATE;
    l_po_line_id             	  NUMBER;
    l_oe_ship_line_id           NUMBER;
    l_oe_return_line_id         NUMBER;
    l_workorder_id              NUMBER;
    l_job_number                VARCHAR2(80);
	l_operation_id              NUMBER;
	l_attribute_category		  VARCHAR2(30);
    l_wo_part_number              VARCHAR2(40);
    l_quantity                  NUMBER;
    l_item_instance_id          NUMBER;
    l_item_instance_number      VARCHAR2(30);
    l_exchange_instance_number  VARCHAR2(30);
    l_project_id                NUMBER;
    l_project_name              VARCHAR2(30);
    l_PROJECT_TASK_ID               NUMBER;
    l_PROJECT_TASK_NAME             VARCHAR2(20);

    L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.GET_ORDER_LINES';

   BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;
  IF G_DEBUG='Y' THEN
	AHL_DEBUG_PUB.enable_debug;
  END IF;

  IF G_DEBUG='Y' THEN
    IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug('Begin Get_order_lines', 'GET_ORDER_LINES: ');

	END IF;
    --i := 0;
    IF P_work_order_ids IS NULL THEN
      IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug('P_work_order_ids is null', 'GET_ORDER_LINES: ');
	  END IF;
    END IF;

    IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug('P_osp_id = ' || P_osp_id, 'GET_ORDER_LINES: ');
	END IF;

  END IF;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
 IF(P_OSP_ID IS NOT NULL) THEN
  l_line_queries := 'SELECT OSP_ORDER_LINE_ID ';
  l_line_queries := l_line_queries ||', OBJECT_VERSION_NUMBER ';
  l_line_queries := l_line_queries ||', OSP_ORDER_ID ';
  l_line_queries := l_line_queries ||', OSP_LINE_NUMBER ';
  l_line_queries := l_line_queries ||', STATUS_CODE ';
  l_line_queries := l_line_queries ||', STATUS ';
  l_line_queries := l_line_queries ||', PO_LINE_TYPE_ID ';
  l_line_queries := l_line_queries ||', PO_LINE_TYPE ';
  l_line_queries := l_line_queries ||', SERVICE_ITEM_ID ';
  l_line_queries := l_line_queries ||', SERVICE_ITEM_NUMBER ';
  l_line_queries := l_line_queries ||', SERVICE_ITEM_DESCRIPTION ';
  l_line_queries := l_line_queries ||', SERVICE_ITEM_UOM_CODE ';
  l_line_queries := l_line_queries ||', NEED_BY_DATE ';
  l_line_queries := l_line_queries ||', SHIP_BY_DATE ';
  l_line_queries := l_line_queries ||', PO_LINE_ID ';
  l_line_queries := l_line_queries ||', OE_SHIP_LINE_ID ';
  l_line_queries := l_line_queries ||', OE_RETURN_LINE_ID ';
  l_line_queries := l_line_queries ||', WORKORDER_ID ';
  l_line_queries := l_line_queries ||', JOB_NUMBER ';
  l_line_queries := l_line_queries ||', OPERATION_ID ';
  l_line_queries := l_line_queries ||', ATTRIBUTE_CATEGORY ';

  l_line_queries := l_line_queries ||', WO_PART_NUMBER';
  l_line_queries := l_line_queries ||', QUANTITY ';
  l_line_queries := l_line_queries ||', ITEM_INSTANCE_ID ';
  l_line_queries := l_line_queries ||', ITEM_INSTANCE_NUMBER ';
  l_line_queries := l_line_queries ||', EXCHANGE_INSTANCE_NUMBER ';
  l_line_queries := l_line_queries ||', PROJECT_ID ';
  l_line_queries := l_line_queries ||', PROJECT_NAME ';
  l_line_queries := l_line_queries ||', PROJECT_TASK_ID ';
  l_line_queries := l_line_queries ||', PROJECT_TASK_NAME ';

  l_line_queries := l_line_queries || ' FROM AHL_OSP_ORDER_LINES_V ';
  l_line_queries := l_line_queries || ' WHERE OSP_ORDER_ID = ';
  l_line_queries := l_line_queries || P_OSP_ID;
  l_line_queries := l_line_queries || ' ORDER BY OSP_LINE_NUMBER  ';


  IF G_DEBUG='Y' THEN
	AHL_DEBUG_PUB.debug('l_line_queries: ' || SUBSTR(l_line_queries, 1, 900), 'GET_ORDER_LINES: ');
  END IF;

  OPEN l_line_csr FOR l_line_queries;
  i := 0;
  LOOP
    FETCH l_line_csr INTO     l_osp_order_line_id	,
	                          l_object_version_number,
                              l_osp_order_id        ,
                              l_osp_line_number     ,
	                          l_status_code	,
                              l_status ,
                              l_po_line_type_id ,
                              l_po_line_type ,
                              l_service_item_id,
                              l_service_item_number,
	                          l_service_item_description,
	                          l_service_item_uom_code ,
                              l_need_by_date,
                              l_ship_by_date ,
                              l_po_line_id ,
                              l_oe_ship_line_id     ,
                              l_oe_return_line_id   ,
                              l_workorder_id        ,
                              l_job_number ,
	                          l_operation_id        ,
	                          l_attribute_category,
                              l_wo_part_number ,
                              l_quantity ,
                              l_item_instance_id ,
                              l_item_instance_number ,
                              l_exchange_instance_number,
                              l_project_id   ,
                              l_project_name ,
                              l_PROJECT_TASK_ID  ,
                              l_PROJECT_TASK_NAME ;

    EXIT WHEN  l_line_csr%NOTFOUND;

    IF G_DEBUG='Y' THEN
		AHL_DEBUG_PUB.debug('After FETCH Order Lines', 'GET_ORDER_LINES: ');
    END IF;

    x_order_lines_tbl(i).OSP_ORDER_LINE_ID            := l_osp_order_line_id;
	x_order_lines_tbl(i).OBJECT_VERSION_NUMBER        := l_object_version_number;
    x_order_lines_tbl(i).OSP_ORDER_ID                 := l_osp_order_id ;
    x_order_lines_tbl(i).OSP_LINE_NUMBER              := l_osp_line_number ;
	x_order_lines_tbl(i).STATUS_CODE                  := l_status_code;
    x_order_lines_tbl(i).STATUS                       := l_status;
    x_order_lines_tbl(i).PO_LINE_TYPE_ID              := l_po_line_type_id;
    x_order_lines_tbl(i).PO_LINE_TYPE                 := l_po_line_type;
    x_order_lines_tbl(i).SERVICE_ITEM_ID              := l_service_item_id;
    x_order_lines_tbl(i).SERVICE_ITEM_NUMBER          := l_service_item_number;
	x_order_lines_tbl(i).SERVICE_ITEM_DESCRIPTION     := l_service_item_description;
	x_order_lines_tbl(i).SERVICE_ITEM_UOM_CODE        := l_service_item_uom_code;
    x_order_lines_tbl(i).NEED_BY_DATE                 := l_need_by_date;
    x_order_lines_tbl(i).SHIP_BY_DATE                 := l_ship_by_date;
    x_order_lines_tbl(i).PO_LINE_ID                   := l_po_line_id;
    x_order_lines_tbl(i).OE_SHIP_LINE_ID              := l_oe_ship_line_id;
    x_order_lines_tbl(i).OE_RETURN_LINE_ID            := l_oe_return_line_id;
    x_order_lines_tbl(i).WORKORDER_ID                 := l_workorder_id;
    x_order_lines_tbl(i).JOB_NUMBER                   := l_job_number;
	x_order_lines_tbl(i).OPERATION_ID                 := l_operation_id;
	x_order_lines_tbl(i).ATTRIBUTE_CATEGORY           := l_attribute_category;

    x_order_lines_tbl(i).WO_PART_NUMBER               := l_wo_part_number ;
    x_order_lines_tbl(i).QUANTITY                     := l_quantity ;
    x_order_lines_tbl(i).ITEM_INSTANCE_ID             := l_item_instance_id ;
    x_order_lines_tbl(i).ITEM_INSTANCE_NUMBER         := l_item_instance_number ;
    x_order_lines_tbl(i).EXCHANGE_INSTANCE_NUMBER     := l_exchange_instance_number ;
    x_order_lines_tbl(i).PROJECT_ID                   := l_project_id   ;
    x_order_lines_tbl(i).PROJECT_NAME                 := l_project_name ;
    x_order_lines_tbl(i).PRJ_TASK_ID                  := l_PROJECT_TASK_ID  ;
    x_order_lines_tbl(i).PRJ_TASK_NAME                := l_PROJECT_TASK_NAME ;

    IF G_DEBUG='Y' THEN
	   AHL_DEBUG_PUB.debug('After Assign Order Lines', 'GET_ORDER_LINES: ');
    END IF;

    i:= i + 1;


END LOOP;

--END IF;   --P_OSP_ID NOT NULL

ELSIF (P_work_order_ids.COUNT > 0)  THEN
  -- testNum := p_work_order_ids(0).work_order_id;

  l_line_queries := 'SELECT    WO.WORKORDER_ID ';
  l_line_queries := l_line_queries ||', WO.JOB_NUMBER';
  l_line_queries := l_line_queries ||', WO.WO_PART_NUMBER ';
  l_line_queries := l_line_queries ||', WO.ITEM_INSTANCE_ID ';
  l_line_queries := l_line_queries ||', WO.item_instance_number ';
  l_line_queries := l_line_queries ||', WO.SERVICE_ITEM_ID ';
  l_line_queries := l_line_queries ||', WO.SERVICE_ITEM_NUMBER ';
  l_line_queries := l_line_queries ||', WO.SERVICE_ITEM_DESCRIPTION ';
  l_line_queries := l_line_queries ||', WO.SERVICE_ITEM_UOM ';
  l_line_queries := l_line_queries ||', WO.QUANTITY ';
  l_line_queries := l_line_queries ||', WO.PROJECT_ID ';
  l_line_queries := l_line_queries ||', WO.PROJECT_NAME ';
  l_line_queries := l_line_queries ||', WO.PROJECT_TASK_ID ';
  l_line_queries := l_line_queries ||', WO.PROJECT_TASK_NAME ';

  l_line_queries := l_line_queries || ' FROM AHL_WORKORDERS_OSP_V WO ';
  l_line_queries := l_line_queries || ' WHERE  ';

  l_line_queries := l_line_queries || ' (';
  i := 0;
  FOR i IN P_work_order_ids.FIRST .. P_work_order_ids.LAST
  LOOP
    IF (i <> P_work_order_ids.FIRST) THEN
      l_line_queries := l_line_queries || ' OR ';
    END IF;
      l_line_queries := l_line_queries || ' WO.WORKORDER_ID =' || p_work_order_ids(i).work_order_id;
  END LOOP;
  l_line_queries := l_line_queries || ' )';

  IF G_DEBUG='Y' THEN
	 AHL_DEBUG_PUB.debug('Search_WO: l_line_queries = ' || SUBSTR(l_line_queries, 1, 900));
  END IF;

  IF G_DEBUG='Y' THEN
	 AHL_DEBUG_PUB.debug('l_line_queries: ' || SUBSTR(l_line_queries, 1, 900), 'GET_ORDER_LINES: ');
  END IF;

   OPEN l_line_csr FOR l_line_queries;
  i := 0;
  LOOP

    FETCH l_line_csr INTO     l_workorder_id,
                              l_Job_number,
                              l_wo_Part_number,
                              l_item_instance_id,
                              l_item_instance_number,
                              l_service_item_id,
                              l_service_item_number,
	                          l_service_item_description,
	                          l_service_item_uom_code ,
                              l_quantity,
                              l_project_id  ,
                              l_Project_Name,
                              l_PROJECT_TASK_ID,
                              l_PROJECT_TASK_NAME;

    EXIT WHEN  l_line_csr%NOTFOUND;

    x_order_lines_tbl(i).workorder_id               := l_workorder_id;
    x_order_lines_tbl(i).Job_number                 := l_Job_number;
    x_order_lines_tbl(i).WO_PART_NUMBER             := l_wo_Part_number;
    x_order_lines_tbl(i).ITEM_INSTANCE_ID           := l_item_instance_id ;
    x_order_lines_tbl(i).item_instance_number       := l_item_instance_number;
    x_order_lines_tbl(i).SERVICE_ITEM_ID              := l_service_item_id;
    x_order_lines_tbl(i).SERVICE_ITEM_NUMBER          := l_service_item_number;
	x_order_lines_tbl(i).SERVICE_ITEM_DESCRIPTION     := l_service_item_description;
	x_order_lines_tbl(i).SERVICE_ITEM_UOM_CODE        := l_service_item_uom_code;
    x_order_lines_tbl(i).quantity                   := l_quantity;
    x_order_lines_tbl(i).PROJECT_ID                 := l_project_id   ;
    x_order_lines_tbl(i).Project_Name               := l_Project_Name;
    x_order_lines_tbl(i).PRJ_TASK_ID                := l_PROJECT_TASK_ID  ;
    x_order_lines_tbl(i).PRJ_TASK_NAME              := l_PROJECT_TASK_NAME;

    i := i + 1;
  END LOOP;  -- END LOOP FOR L_LINE_CSR

END IF;

IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'End Procedure');
 END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
 --dbms_output.put_line('Excep 1 ');
   x_return_status := FND_API.G_RET_STS_ERROR;
   --Rollback to get_order_lines_pvt;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
   IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, L_DEBUG_KEY, 'Execution Exception: ' || x_msg_data);
   END IF;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  --dbms_output.put_line('Excep 2 ');
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   --Rollback to get_order_lines_pvt;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
   IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, L_DEBUG_KEY, 'Unexpected Exception: ' || x_msg_data);
   END IF;

 WHEN OTHERS THEN
  --dbms_output.put_line('Excep 3 ');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Rollback to get_order_lines_pvt;
       FND_MSG_PUB.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'GET_ORDER_LINES',
                               p_error_text     => SQLERRM);

    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, L_DEBUG_KEY, 'Unexpected Exception: ' || x_msg_data);
    END IF;



END GET_ORDER_LINES;

-----------------------------------------------
--This is a published function wrapper just for the convenience usage in view
-----------------------------------------------
FUNCTION Get_Suggested_Vendor(p_work_order_id  IN NUMBER)
RETURN VARCHAR2 IS
  CURSOR get_items_from_wo IS
  --Modified by mpothuku to fix the Perf Bug# 4919307
  /*
    SELECT inventory_item_id,
           organization_id,
           service_item_id
      FROM ahl_workorders_osp_v
     WHERE workorder_id = p_work_order_id;
 */
	 SELECT vts.inventory_item_id,
		   vst.organization_id,
		   arb.service_item_id
	  FROM ahl_workorders wo,
		   ahl_visits_b vst,
		   ahl_visit_tasks_b vts,
		   ahl_routes_b arb
	 WHERE workorder_id = p_work_order_id
	   AND wo.visit_task_id = vts.visit_task_id
	   AND vts.visit_id = vst.visit_id
	   AND wo.route_id = arb.route_id(+);

  CURSOR get_vendor_certs(c_inv_item_id NUMBER, c_inv_org_id NUMBER, c_service_item_id NUMBER) IS
    SELECT IV.vendor_certification_id,
           IV.rank
      FROM ahl_inv_service_item_rels SI,
           ahl_item_vendor_rels IV
     WHERE SI.inv_service_item_rel_id = IV.inv_service_item_rel_id
       AND SI.inv_item_id = c_inv_item_id
       AND SI.inv_org_id = c_inv_org_id
       AND SI.service_item_id = c_service_item_id
       AND trunc(IV.active_start_date) <= trunc(SYSDATE)
       AND trunc(nvl(IV.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
       AND trunc(SI.active_start_date) <= trunc(SYSDATE)
       AND trunc(nvl(SI.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
  ORDER BY IV.rank;
  l_get_vendor_certs get_vendor_certs%ROWTYPE;
  CURSOR get_vendor_name(c_vendor_cert_id NUMBER) IS
    SELECT vendor_name
      FROM ahl_vendor_certifications_v
     WHERE vendor_certification_id = c_vendor_cert_id
       AND trunc(active_start_date) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);
  l_vendor_name VARCHAR2(240) := NULL;
  l_vendor_cert_id NUMBER := NULL;
  l_inv_item_id    NUMBER;
  l_inv_org_id     NUMBER;
  l_service_item_id NUMBER;
BEGIN
  --The following line is only line in original code, commented out by Jerry on 06/10/2005
  --RETURN Get_Suggested_Vendor(p_work_order_id, G_EMPTY_WO_IDS_TABLE);
  OPEN get_items_from_wo;
  FETCH get_items_from_wo INTO l_inv_item_id, l_inv_org_id, l_service_item_id;
  IF (get_items_from_wo%FOUND AND l_service_item_id IS NOT NULL) THEN
    OPEN get_vendor_certs(l_inv_item_id, l_inv_org_id, l_service_item_id);
    FETCH get_vendor_certs INTO l_get_vendor_certs;
    IF get_vendor_certs%FOUND THEN
      l_vendor_cert_id := l_get_vendor_certs.vendor_certification_id;
      IF l_vendor_cert_id IS NOT NULL THEN
        OPEN get_vendor_name(l_vendor_cert_id);
        FETCH get_vendor_name INTO l_vendor_name;
        CLOSE get_vendor_name;
      END IF;
    END IF;
    CLOSE get_vendor_certs;
  END IF;
  CLOSE get_items_from_wo;
  RETURN l_vendor_name;
END;

/* Added by mpothuku on 03-17-05 for calculating the onhand quantity for an inventory item */
-----------------------------------------------
--Function for calculating the onhand quantity of an item
-----------------------------------------------
FUNCTION Get_Onhand_Quantity(p_org_id  IN NUMBER, p_subinventory_code  IN VARCHAR2, p_inventory_item_id IN NUMBER,
                             --Added by mpothuku on 23rd Aug, 06 to fix the Bug 5252627
                             p_lot_number IN VARCHAR2)

RETURN NUMBER IS
l_debug_key       CONSTANT VARCHAR2(150) := g_log_prefix || '.Get_Onhand_Quantity';
l_onhand_quantity NUMBER;
l_apparent_quantity NUMBER;
--l_quant_withoutship NUMBER;
l_quant_ship_notbooked NUMBER;
l_quant_notshippedout NUMBER;

BEGIN

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string(fnd_log.level_procedure, l_debug_key || '.begin:', 'Entered Get_Onhand_Quantity Function');
  END IF;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
      fnd_log.level_statement, l_debug_key|| ':',
      'p_org_id: '|| p_org_id ||
      'and p_subinventory_code :' || p_subinventory_code ||
      'and p_inventory_item_id :' || p_inventory_item_id ||
      --Added by mpothuku on 23rd Aug, 06 to fix the Bug 5252627
      'and p_lot_number :' || p_lot_number
    );
  END IF;

  Select nvl(sum(transaction_quantity),0) into l_apparent_quantity from mtl_onhand_quantities  where
    organization_id = p_org_id and
    inventory_item_id = p_inventory_item_id and
    subinventory_code = p_subinventory_code and
    --Added by mpothuku on 23rd Aug, 06 to fix the Bug 5252627
    (p_lot_number is null or lot_number = p_lot_number);

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string(fnd_log.level_statement, l_debug_key|| ':', 'l_apparent_quantity : '|| l_apparent_quantity);
  END IF;

  --Gives the quantity of the items without ship lines reserved by osp
  /***** For Bug 5673279,
  1. we need not deduct this quantity from onhand anymore
  Instead we show an indicator in the front end saying that there are Orders already created against this item in the subinventory
  in question
  2. We need to use this query in the front end to decide on the visibility of the indicator
  3. We need to retain the ospl.status_code clause as, if the order does not have shipments and PO is deleted, we consider it released */
  /*
  Select
    nvl(sum(nvl(AHL_LTP_MTL_REQ_PVT.Get_Primary_UOM_Qty
            (ospl.inventory_item_id,ospl.inventory_item_uom,ospl.inventory_item_quantity),0)
         ),0) into l_quant_withoutship
  from ahl_osp_order_lines ospl, ahl_osp_orders_b osp  where
    ospl.osp_order_id = osp.osp_order_id and
    osp.status_code <> 'CLOSED' and
    --Added by mpothuku on 23-Aug-06 to exclude the quantity involved in PO_CANCELLED or PO_DELETED Lines for Bug 5252627
    ospl.status_code is null and
    --mpothuku End
    ospl.oe_ship_line_id is null and
    ospl.inventory_org_id = p_org_id and
    ospl.inventory_item_id = p_inventory_item_id and
    ospl.sub_inventory = p_subinventory_code and
    --Added by mpothuku on 23rd Aug, 06 to fix the Bug 5252627
    (p_lot_number is null or ospl.lot_number = p_lot_number);

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string(fnd_log.level_statement, l_debug_key ||':', 'l_quant_withoutship : '|| l_quant_withoutship);
  END IF;
  */

  --Gives the quantity of the items that have ship lines, but whose shipments are not booked.
  /***** For Bug 5673279
  1. Need to consider the clause for the cases where OE Lines or Orders are deleted from OM forms. For such cases
     we still hold the reference in AHL tables.
  2. Need to consider the case where the Shipments are cancelled
  3. Need to remove the ospl.status code clause as the items are not considered released till the shipments are deleted
     and PO deletion no more enables the items to be released for Osp.
 */
  Select
    nvl(sum(nvl(AHL_LTP_MTL_REQ_PVT.Get_Primary_UOM_Qty
            (ospl.inventory_item_id,ospl.inventory_item_uom,ospl.inventory_item_quantity),0)
         ),0) into l_quant_ship_notbooked

  from ahl_osp_order_lines ospl, ahl_osp_orders_b osp,
  /* Fix for the AE Bug 5673279 (Release/Holding of inventory items) */
  oe_order_lines_all oel
  where
    ospl.osp_order_id = osp.osp_order_id and
    osp.status_code <> 'CLOSED' and
    /* Fix for the AE Bug 5673279 (Release/Holding of inventory items)
    --Added by mpothuku on 23-Aug-06 to exclude the quantity involved in PO_CANCELLED or PO_DELETED Lines for Bug 5252627
    ospl.status_code is null and
    --mpothuku End
    */
    ospl.oe_ship_line_id  is not null and
    ospl.inventory_org_id = p_org_id and
    ospl.inventory_item_id = p_inventory_item_id and
    ospl.sub_inventory = p_subinventory_code and
    /* Fix for the AE Bug 5673279 (Release/Holding of inventory items) */
    --This join ensure that if the OE ship lines are deleted from the OM forms the quantity is not reserved.
    oel.line_id = ospl.OE_SHIP_LINE_ID and
    --The order line should not be closed and should not be cancelled to be considered here
    --mpothuku 16-Nov-06, following two checks may be redundant as, the order cannot be closed if there are no deliveries
    --and unless the order is booked, it cannot be in the cancelled status
    (nvl(oel.cancelled_flag, 'N') <> 'Y' OR nvl(oel.flow_status_code, 'XXX') <> 'CANCELLED') and
    (oel.open_flag <> 'N' OR nvl(oel.flow_status_code, 'XXX') <> 'CLOSED') and
    --Added by mpothuku on 23rd Aug, 06 to fix the Bug 5252627
    (p_lot_number is null or ospl.lot_number = p_lot_number) and
    not exists
    (select 1 from wsh_delivery_details where SOURCE_CODE = 'OE' and SOURCE_LINE_ID = OSPL.oe_ship_line_id);

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string(fnd_log.level_statement, l_debug_key||':','l_quant_ship_notbooked:'|| l_quant_ship_notbooked);
  END IF;

  --Gives the quantity of the items that have ship lines, and whose shipments are in those phases, where
  --the quantity is not reduced from the inventory yet, but nonetheless reserved.

  Select
    nvl(sum(nvl(AHL_LTP_MTL_REQ_PVT.Get_Primary_UOM_Qty
          (inventory_item_id, requested_quantity_uom, requested_quantity),0)
       ),0) into l_quant_notshippedout

  from wsh_delivery_details where
    organization_id = p_org_id and
    inventory_item_id = p_inventory_item_id and
    subinventory = p_subinventory_code and
    released_status in ('R','S','Y','C','B') and
    --Added by mpothuku on 17th May, 06 to fix the Bug 5231358
    (p_lot_number is null or lot_number = p_lot_number);

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string(fnd_log.level_statement, l_debug_key||':','l_quant_notshippedout : '|| l_quant_notshippedout);
  END IF;


  l_onhand_quantity := l_apparent_quantity - (l_quant_ship_notbooked + l_quant_notshippedout);

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string(fnd_log.level_statement, l_debug_key||':' , 'l_onhand_quantity : '|| l_onhand_quantity);
  END IF;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string(fnd_log.level_procedure, l_debug_key||'.end','End Get_Onhand_Quantity Function');
  END IF;

  return l_onhand_quantity;

END;


-------------------------------GET SUGGESTED VENDOR--------------------------------------------------

-- Return the suggested vendor for a work order/multiple workorders
-- For a single work order (p_work_order_id parameter):
--   If there are no suggested vendors, returns null
--   If there are multiple suggested vendors, returns '*'
--   If there is only one vendor, returns the vendor name
-- For multiple work orders (p_work_order_ids parameter)
--   If all work orders have the same (not null, not multiple) suggested vendor, that vendor name is returned
--   Else, null is returned
----------------------------------------------------------------------------
FUNCTION Get_Suggested_Vendor(p_work_order_id  IN NUMBER,
                              p_work_order_ids IN AHL_OSP_QUERIES_PVT.work_id_tbl_type )
         RETURN VARCHAR2 IS
  l_vendor_name VARCHAR2(240) := NULL;
  l_dummy VARCHAR2(80) := NULL;
  l_org_id NUMBER;
  CURSOR l_approved_vendors_csr(l_workorder_id IN NUMBER,
                                l_org_id       IN NUMBER) IS
    /*
    SELECT VENDOR_NAME
    from  PO_VENDORS_VIEW VEN, PO_ASL_STATUSES AST, PO_APPROVED_SUPPLIER_LIST ASL, AHL_WORKORDERS_OSP_V WO
    WHERE WO.WORKORDER_ID = l_workorder_id AND
          ASL.ITEM_ID = WO.SERVICE_ITEM_ID AND
          (ASL.USING_ORGANIZATION_ID = l_org_id OR
            (ASL.OWNING_ORGANIZATION_ID = l_org_id AND ASL.USING_ORGANIZATION_ID = -1)) AND
          ASL.ASL_STATUS_ID = AST.STATUS_ID AND
          AST.STATUS = 'Approved' AND
          VEN.VENDOR_ID = ASL.VENDOR_ID AND
          VEN.ENABLED_FLAG = 'Y' AND
          NVL(VENDOR_START_DATE_ACTIVE, SYSDATE - 1) <= SYSDATE AND
          NVL(VENDOR_END_DATE_ACTIVE, SYSDATE + 1) > SYSDATE;
  */
  -- Modified by mpothuku on 13-Mar-06 to fix the Perf Bug #4919307
    SELECT VENDOR_NAME
      from PO_VENDORS_VIEW VEN,
           PO_ASL_STATUSES AST,
           PO_APPROVED_SUPPLIER_LIST ASL,
           AHL_WORKORDERS WO,
           AHL_ROUTES_B arb
     WHERE WO.WORKORDER_ID = l_workorder_id
       AND arb.route_id = wo.route_id
       AND ASL.ITEM_ID = arb.SERVICE_ITEM_ID
       AND (ASL.USING_ORGANIZATION_ID = l_org_id
            OR (ASL.OWNING_ORGANIZATION_ID = l_org_id
            AND ASL.USING_ORGANIZATION_ID = -1))
       AND ASL.ASL_STATUS_ID = AST.STATUS_ID
       AND AST.STATUS = 'Approved'
       AND VEN.VENDOR_ID = ASL.VENDOR_ID
       AND VEN.ENABLED_FLAG = 'Y'
       AND NVL(VENDOR_START_DATE_ACTIVE, SYSDATE - 1) <= SYSDATE
       AND NVL(VENDOR_END_DATE_ACTIVE, SYSDATE + 1) > SYSDATE;

  L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Get_Suggested_Vendor';

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Function');
  END IF;

  l_org_id := FND_PROFILE.VALUE('ORG_ID');
  IF (p_work_order_id IS NOT NULL) THEN
    IF (p_work_order_ids IS NOT NULL AND p_work_order_ids.COUNT > 0) THEN
      -- Cannot provide values in both the parameters of this function
      RAISE TOO_MANY_ROWS;
    END IF;
    -- Get the Suggested Vendor for the given Work order
    OPEN l_approved_vendors_csr(p_work_order_id, l_org_id);
    FETCH l_approved_vendors_csr INTO l_vendor_name;
    IF (l_approved_vendors_csr%NOTFOUND) THEN
      -- No active approved vendor for this item
      CLOSE l_approved_vendors_csr;
      RETURN null;
    ELSE
      FETCH l_approved_vendors_csr INTO l_dummy;
      IF (l_approved_vendors_csr%NOTFOUND) THEN
        -- Only one approved vendor: return this vendor name
        CLOSE l_approved_vendors_csr;
        RETURN l_vendor_name;
      ELSE
        -- Multiple approved vendors: Return '*'
        CLOSE l_approved_vendors_csr;
        RETURN '*';
      END IF;
    END IF;
  ELSE
    -- Get the common vendor for all the given work orders
    IF (p_work_order_ids IS NULL OR p_work_order_ids.COUNT = 0) THEN
      -- Don't throw any error: return null
      return NULL;
    END IF;
    FOR i IN p_work_order_ids.FIRST..p_work_order_ids.LAST LOOP
      l_dummy := Get_Suggested_Vendor(p_work_order_id => p_work_order_ids(i).work_order_id,
                                      p_work_order_ids => AHL_OSP_QUERIES_PVT.G_EMPTY_WO_IDS_TABLE);
      IF ((l_dummy IS NULL) OR (l_dummy = '*')) THEN
        -- No vendor or Multiple vendors
        RETURN NULL;
      ELSIF ((l_vendor_name IS NOT NULL) AND (l_dummy <> l_vendor_name)) THEN
        -- Different Vendors
        RETURN NULL;
      ELSE
        -- Unique (Not null and not multiple) Vendor so far
        l_vendor_name := l_dummy;
      END IF;
    END LOOP;
    RETURN l_vendor_name;
  END IF;
END Get_Suggested_Vendor;


END AHL_OSP_QUERIES_PVT;

/
