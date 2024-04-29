--------------------------------------------------------
--  DDL for Package Body AHL_PRD_PRINT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PRD_PRINT_PVT" AS
/* $Header: AHLVPPRB.pls 120.15 2008/03/14 10:32:34 pdoki ship $ */

G_PKG_NAME        VARCHAR2(30)  :='AHL_PRD_PRINT_PVT';

-- Constants to identify locator and item number elements
G_ITEM_NUMBER_CHAR  NUMBER    := 10;
G_LOCATOR_CHAR    NUMBER    := 15;

procedure build_qa_query(
          p_plan_id   IN NUMBER,
          p_collection_id IN NUMBER,
          x_query_string  OUT NOCOPY VARCHAR2
         );

TYPE EMP_DETAILS_REC_TYPE IS RECORD(employee_id NUMBER, employee_name VARCHAR2(240));

-- Table to hold employee_id and employee name
TYPE EMP_TABLE_TYPE IS TABLE OF EMP_DETAILS_REC_TYPE INDEX BY BINARY_INTEGER;

----------------------------------------------------------------------------
--Function which returns offset for current server timezone as per the profile
--setting in SERVER_TIMEZONE_ID
----------------------------------------------------------------------------
FUNCTION get_tz_offset
RETURN VARCHAR2
IS

CURSOR c_get_tz_code
IS
SELECT
 timezone_code
FROM
  fnd_timezones_vl
WHERE
 upgrade_tz_id = fnd_profile.VALUE('SERVER_TIMEZONE_ID');

CURSOR c_get_tz_offset(c_tz_code IN VARCHAR2)
IS
 SELECT substr(tz_offset(c_tz_code),0,6)
FROM
 dual;

l_tz_offset VARCHAR2(100);
l_tz_code   VARCHAR2(50);

BEGIN
  -- Code added for bug # 5199935
  -- Ref https://metalink.oracle.com/metalink/plsql/f?p=130:14:2578122075547395620::::p14_database_id,p14_docid,
  --p14_show_header,p14_show_help,p14_black_frame,p14_font:NOT,340512.1,1,1,1,helvetica#aref2
  OPEN c_get_tz_code;
  FETCH c_get_tz_code INTO l_tz_code;
  CLOSE c_get_tz_code;

  OPEN c_get_tz_offset(l_tz_code);
  FETCH c_get_tz_offset INTO l_tz_offset;
  CLOSE c_get_tz_offset;
  -- Code added for bug # 5199935

  RETURN l_tz_offset;
END get_tz_offset;

------------------------------------------------------------------------------------------------
-- Procedure to generate XML data for workorder(s).
------------------------------------------------------------------------------------------------
PROCEDURE Gen_Wo_Xml(
   p_api_version               IN           NUMBER    :=1.0,
   p_init_msg_list             IN           VARCHAR2  :=FND_API.G_FALSE,
   p_commit                    IN           VARCHAR2  :=FND_API.G_FALSE,
   p_validation_level          IN     NUMBER    :=FND_API.G_VALID_LEVEL_FULL,
   p_default                   IN           VARCHAR2  :=FND_API.G_FALSE,
   p_module_type               IN           VARCHAR2  :=NULL,
   x_return_status             OUT NOCOPY         VARCHAR2,
   x_msg_count                 OUT NOCOPY         NUMBER,
   x_msg_data                  OUT NOCOPY         VARCHAR2,
   p_workorders_tbl          IN     WORKORDER_TBL_TYPE,
   p_employee_id         IN     NUMBER,
   p_user_role         IN     VARCHAR2,-- required for resource transactions
   p_material_req_flag       IN     VARCHAR2 := 'N',--not required any more
   x_xml_data        OUT NOCOPY   CLOB,
   p_concurrent_flag           IN             VARCHAR2  := 'N'-- pass as N non concurrent programs
)
IS



--1. Gather workorder header details.
l_wo_details VARCHAR2(5000) := '
SELECT
  wo.job_number,
  wo.job_description,
  wo.job_status_meaning,
  wo.visit_number,
  wo.organization_name,
  wo.department_name,
  decode(wo.scheduled_start_date, null, null, TO_CHAR(wo.scheduled_start_date,''YYYY-MM-DD'')||''T''||TO_CHAR(wo.scheduled_start_date, ''hh24:mi:ss'')||AHL_PRD_PRINT_PVT.get_tz_offset ) scheduled_start_date,
  decode(wo.scheduled_end_date, null, null, TO_CHAR(wo.scheduled_end_date, ''YYYY-MM-DD'')||''T''||TO_CHAR(wo.scheduled_end_date, ''hh24:mi:ss'')||AHL_PRD_PRINT_PVT.get_tz_offset ) scheduled_end_date,
  decode(wo.actual_start_date, null, null, TO_CHAR(wo.actual_start_date,''YYYY-MM-DD'')||''T''||TO_CHAR(wo.actual_start_date, ''hh24:mi:ss'')||AHL_PRD_PRINT_PVT.get_tz_offset )actual_start_date,
  decode(wo.actual_end_date, null, null, TO_CHAR(wo.actual_end_date, ''YYYY-MM-DD'')||''T''||TO_CHAR(wo.actual_end_date, ''hh24:mi:ss'')||AHL_PRD_PRINT_PVT.get_tz_offset ) actual_end_date,
  wo.unit_name,
  wo.wo_part_number,
  wo.serial_number,
  wo.mr_title,
  ro.ROUTE_NO route_title
FROM
  AHL_SEARCH_WORKORDERS_V wo,
  ahl_routes_app_v ro, ';


l_wo_details_where VARCHAR2(500) := ' WHERE
  wo.route_id = ro.route_id(+) and
  WODE.workorder_id = wo.workorder_id and
  wo.workorder_id = ';

--2. Gather turnover notes for the workorder.
l_to_notes VARCHAR2(3000) := '
SELECT
  decode(ENTERED_DATE, null, null, TO_CHAR(ENTERED_DATE, ''YYYY-MM-DD'')||''T''||TO_CHAR(ENTERED_DATE, ''hh24:mi:ss'')||AHL_PRD_PRINT_PVT.get_tz_offset ) ENTERED_DATE,
  ENTERED_BY_NAME ,
  notes
FROM
  JTF_NOTES_VL
WHERE
  source_object_code = ''AHL_WO_TURNOVER_NOTES'' and
  source_object_id = ';

--3. Gather operation details.
l_op_details_1 VARCHAR2(500) := '
SELECT
  OPERATION_SEQUENCE_NUM,
  OPERATION_CODE,
  DESCRIPTION,
  STATUS,';

  --AHL_PRD_UTIL_PKG.Get_Op_TotalHours_Assigned(WIP_ENTITY_ID,operation_sequence_num) "Total_Hours",
  --AHL_PRD_UTIL_PKG.Get_Op_transacted_hours(WIP_ENTITY_ID,operation_sequence_num) "Hours_Worked",

l_op_details_2 VARCHAR2(1000) :=  '
  decode(SCHEDULED_START_DATE, null, null, TO_CHAR(SCHEDULED_START_DATE, ''YYYY-MM-DD'')||''T''||TO_CHAR(SCHEDULED_START_DATE, ''hh24:mi:ss'')||AHL_PRD_PRINT_PVT.get_tz_offset )SCHEDULED_START_DATE,
  decode(ACTUAL_START_DATE, null, null, TO_CHAR(ACTUAL_START_DATE, ''YYYY-MM-DD'')||''T''||TO_CHAR(ACTUAL_START_DATE, ''hh24:mi:ss'')||AHL_PRD_PRINT_PVT.get_tz_offset ) ACTUAL_START_DATE,
  decode(ACTUAL_END_DATE, null, null, TO_CHAR(ACTUAL_END_DATE, ''YYYY-MM-DD'')||''T''||TO_CHAR(ACTUAL_END_DATE, ''hh24:mi:ss'')||AHL_PRD_PRINT_PVT.get_tz_offset ) ACTUAL_END_DATE
FROM
   ahl_workorder_operations_v
WHERE
  workorder_operation_id = ';


--4. Gather material requirements.
l_wo_materials VARCHAR2(3000) := '
SELECT
  CONCATENATED_SEGMENTS,
  OPERATION_SEQUENCE,
  DESCRIPTION,
  REQUESTED_QUANTITY required_quantity,
  decode(REQUESTED_DATE, null, null, TO_CHAR(REQUESTED_DATE, ''YYYY-MM-DD'')||''T''||TO_CHAR(REQUESTED_DATE, ''hh24:mi:ss'')||AHL_PRD_PRINT_PVT.get_tz_offset ) required_date,
  SCHEDULE_QUANTITY,
  decode(SCHEDULE_DATE, null, null, TO_CHAR(SCHEDULE_DATE, ''YYYY-MM-DD'')||''T''||TO_CHAR(SCHEDULE_DATE, ''hh24:mi:ss'')||AHL_PRD_PRINT_PVT.get_tz_offset ) SCHEDULE_DATE,
  ISSUED_QTY,
  UOM
FROM
  AHL_JOB_OPER_MATERIALS_V
WHERE
  WORKORDER_ID = ';

--9. gather document requirements.
--1. docs associated to Routes
l_route_doc VARCHAR2(1000) := '
SELECT
  DOC.DOCUMENT_NO,
  DOC.DOCUMENT_TITLE,
  DOC.ASO_OBJECT_TYPE_DESC,
  DOC.REVISION_NO,
  DOC.CHAPTER,
  DOC.SECTION,
  DOC.SUBJECT,
  DOC.PAGE,
  DOC.FIGURE,
  DOC.NOTE
FROM
  AHL_WORKORDERS WO,
  AHL_DOCUMENT_ASSOS_V DOC
WHERE
  WO.ROUTE_ID = DOC.ASO_OBJECT_ID
  AND DOC.ASO_OBJECT_TYPE_CODE = ''ROUTE''
  AND WO.WORKORDER_ID = ';

--2. docs associated to operations
l_op_doc VARCHAR2(2000) := '
UNION ALL
SELECT
  DOC.DOCUMENT_NO,
  DOC.DOCUMENT_TITLE,
  DOC.ASO_OBJECT_TYPE_DESC,
  DOC.REVISION_NO,
  DOC.CHAPTER,
  DOC.SECTION,
  DOC.SUBJECT,
  DOC.PAGE,
  DOC.FIGURE,
  DOC.NOTE
FROM
  AHL_WORKORDER_OPERATIONS WOP,
  AHL_DOCUMENT_ASSOS_V DOC
WHERE
  WOP.OPERATION_ID = DOC.ASO_OBJECT_ID
  AND DOC.ASO_OBJECT_TYPE_CODE = ''OPERATION''
  AND WOP.WORKORDER_ID = ';

-- 3. docs associated to MRs
l_mr_doc VARCHAR2(2000) := '
UNION ALL
SELECT
  DOC.DOCUMENT_NO,
  DOC.DOCUMENT_TITLE,
  DOC.ASO_OBJECT_TYPE_DESC,
  DOC.REVISION_NO,
  DOC.CHAPTER,
  DOC.SECTION,
  DOC.SUBJECT,
  DOC.PAGE,
  DOC.FIGURE,
  DOC.NOTE
FROM
  AHL_WORKORDERS WO,
  AHL_VISIT_TASKS_B VST,
  AHL_DOCUMENT_ASSOS_V DOC
WHERE
  WO.VISIT_TASK_ID = VST.VISIT_TASK_ID
  AND VST.MR_ID = DOC.ASO_OBJECT_ID
  AND DOC.ASO_OBJECT_TYPE_CODE = ''MR''
  AND WO.WORKORDER_ID = ';

--4. Docs associated to MCs
l_mc_doc VARCHAR2(2000) := '
UNION ALL
-- MC DOCUMENT ASSOCIATIONS
SELECT
  DOC.DOCUMENT_NO,
  DOC.DOCUMENT_TITLE,
  DOC.ASO_OBJECT_TYPE_DESC,
  DOC.REVISION_NO,
  DOC.CHAPTER,
  DOC.SECTION,
  DOC.SUBJECT,
  DOC.PAGE,
  DOC.FIGURE,
  DOC.NOTE
FROM
  AHL_WORKORDERS WO,
  CSI_II_RELATIONSHIPS CSI,
  AHL_VISIT_TASKS_B VTS,
  AHL_DOCUMENT_ASSOS_V DOC
WHERE
  WO.VISIT_TASK_ID = VTS.VISIT_TASK_ID
  AND VTS.INSTANCE_ID = CSI.SUBJECT_ID
  AND CSI.RELATIONSHIP_TYPE_CODE = ''COMPONENT-OF''
  AND (SYSDATE BETWEEN NVL(CSI.ACTIVE_START_DATE, SYSDATE) AND NVL(CSI.ACTIVE_END_DATE, SYSDATE))
  AND CSI.POSITION_REFERENCE = TO_CHAR(DOC.ASO_OBJECT_ID)
  AND DOC.ASO_OBJECT_TYPE_CODE = ''MC''
  AND WO.WORKORDER_ID = ';

--5. Docs associated to PC node
l_pc_doc VARCHAR2(2000) := '
UNION ALL
SELECT
  DOC.DOCUMENT_NO,
  DOC.DOCUMENT_TITLE,
  DOC.ASO_OBJECT_TYPE_DESC,
  DOC.REVISION_NO,
  DOC.CHAPTER,
  DOC.SECTION,
  DOC.SUBJECT,
  DOC.PAGE,
  DOC.FIGURE,
  DOC.NOTE
FROM
  AHL_WORKORDERS WO,
  AHL_PC_ASSOCIATIONS PCA,
  AHL_VISIT_TASKS_B VTS,
  AHL_DOCUMENT_ASSOS_V DOC
WHERE
  WO.VISIT_TASK_ID=VTS.VISIT_TASK_ID
  AND AHL_UTIL_UC_PKG.GET_UC_HEADER_ID(VTS.INSTANCE_ID) = PCA.UNIT_ITEM_ID
  AND PCA.PC_NODE_ID = DOC.ASO_OBJECT_ID
  AND DOC.ASO_OBJECT_TYPE_CODE = ''PC''
  AND WO.WORKORDER_ID = ';


CURSOR get_wo_employees(p_wo_id IN NUMBER, p_employee_id IN NUMBER) IS
SELECT DISTINCT
  wass.employee_id,
  pf.full_name employee_name
FROM
  ahl_Work_Assignments wass,
  ahl_Operation_Resources opr,
  ahl_Workorder_Operations wop,
  per_people_f pf,
  per_Person_Types Pt
WHERE
  wass.Operation_Resource_Id = opr.operation_resource_id and
  opr.Workorder_Operation_Id = wop.workorder_operation_id and
  wop.workorder_id = p_wo_id and
  wass.employee_id = nvl(p_employee_id, wass.employee_id) and
  wass.employee_id = pf.PERSON_ID and
  pt.Person_Type_Id  = Pf.Person_Type_Id And
  pt.System_Person_Type ='EMP' And
  ( Trunc(Sysdate) Between Pf.Effective_Start_Date And
  Pf.Effective_End_Date);

-- cursor to get operations of a workorder
CURSOR c_wo_operations(p_workorder_id IN NUMBER) IS
SELECT
  workorder_operation_id,
  operation_sequence_num
FROM
  ahl_workorder_operations
WHERE
  workorder_id = p_workorder_id;

--Cursor for getting workorder plan_id and collection id
CURSOR get_wo_qa_ids_csr(p_workorder_id IN NUMBER) IS
SELECT
  PLAN_ID,
  COLLECTION_ID
FROM
  AHL_WORKORDERS
WHERE
  workorder_id = p_workorder_id;

--Cursor for getting workorder operation plan_id and collection id
CURSOR get_op_qa_ids_csr(p_wo_id IN NUMBER) IS
SELECT
  OPERATION_SEQUENCE_NUM, --balaji added for Bug 6777371
  PLAN_ID,
  COLLECTION_ID
FROM
  AHL_WORKORDER_OPERATIONS
WHERE
  workorder_id = p_wo_id;

--declare all local variables here.
l_api_name      CONSTANT  VARCHAR2(30)  := 'Gen_Wo_Xml';
l_api_version     CONSTANT  NUMBER    := 1.0;
l_wo_details_lob CLOB;
l_merged_lob CLOB;
l_temp_lob CLOB;
l_ton_lob CLOB;
l_op_lob CLOB;
l_wo_mat_lob CLOB;
l_wo_doc_lob CLOB;
l_wo_qa_lob CLOB;
l_op_qa_lob CLOB;
l_offset NUMBER;
l_next_offset NUMBER;
wo_count NUMBER;
l_emp_tbl EMP_TABLE_TYPE;
l_employee_id NUMBER;
l_dummy_string VARCHAR2(1000);
i NUMBER;
j NUMBER;
l_plan_id NUMBER;
l_collection_id NUMBER;
l_op_seq_num  NUMBER; --balaji added for Bug 6777371
l_emp_name VARCHAR2(100);
l_query_string VARCHAR2(30000); --pdoki changed for Bug 6777371
--l_op_details VARCHAR2(2000);
l_op_con_query VARCHAR2(3000);
l_wo_con_query VARCHAR2(3000);
l_count NUMBER;
l_user_role VARCHAR2(40);
l_fnd_offset     NUMBER;
l_chunk_size NUMBER;
l_clob_size NUMBER;


context DBMS_XMLGEN.ctxHandle;
l_x_res_txn_tbl AHL_PRD_RESOURCE_TRANX_PVT.PRD_RESOURCE_TXNS_TBL;

BEGIN
  --set the operating unit.
  mo_global.init('AHL');

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN

    fnd_log.string
    (
      fnd_log.level_procedure,
      'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
      'At the start of Gen_Wo_Xml'
    );
        END IF;

  --SAVEPOINT Gen_Wo_Xml;


  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
      fnd_log.level_statement,
      'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
      'API input Parameters '
    );
    fnd_log.string
    (
      fnd_log.level_statement,
      'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
      '************************'
    );
    fnd_log.string
    (
      fnd_log.level_statement,
      'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
      'p_employee_id -> '||p_employee_id
    );
    fnd_log.string
    (
      fnd_log.level_statement,
      'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
      'p_user_role -> '||p_user_role
    );
    fnd_log.string
    (
      fnd_log.level_statement,
      'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
      'p_concurrent_flag -> '||p_concurrent_flag
    );
    fnd_log.string
    (
      fnd_log.level_statement,
      'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
      'p_workorders_tbl size -> '||p_workorders_tbl.count
    );

    fnd_log.string
    (
      fnd_log.level_statement,
      'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
      'mo operating unit -> '||mo_global.get_current_org_id()
    );
    fnd_log.string
    (
      fnd_log.level_statement,
      'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
      'AHL_PRD_PRINT_PVT.get_tz_offset -> '||AHL_PRD_PRINT_PVT.get_tz_offset
    );
  END IF;

  -- Initialize return status to success initially
        x_return_status:= FND_API.G_RET_STS_SUCCESS;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                       p_api_version,
                                       l_api_name,G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;

  -- Open a temporary lob for merging the contents.
  dbms_lob.createTemporary( l_merged_lob, true );
  dbms_lob.open( l_merged_lob, dbms_lob.lob_readwrite );

   --determine the user role based on employee parameter if it is not passed already in the input. Concurrent program is an example
  l_user_role := p_user_role;

  IF p_user_role IS NULL
  THEN
     l_user_role := AHL_PRD_WO_LOGIN_PVT.Get_User_Role;
  END IF;

  -- XML generated with dbms_xmlgen doesnt have encoding information. so we need to manually insert into the resultant CLOB.
  dbms_lob.write(l_merged_lob,length('<?xml version="1.0" encoding="UTF-8"?>'),1,'<?xml version="1.0" encoding="UTF-8"?>');

  --Put the root node to maintain the XML completeness.
  dbms_lob.write(l_merged_lob, length('<G_WORKCARD_LIST>'),length(l_merged_lob)+1, '<G_WORKCARD_LIST>');

  /***************************************************************************************
   *Start Actual API processing here
   ***************************************************************************************/
   -- Process all workorders in the input.
   IF p_workorders_tbl.COUNT > 0 THEN
     FOR wo_count IN p_workorders_tbl.FIRST .. p_workorders_tbl.LAST
     LOOP
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
          'p_workorders_tbl('||wo_count||') --> '||p_workorders_tbl(wo_count)
        );
      END IF;

      i := 1;
      FOR emp_rec in get_wo_employees(p_workorders_tbl(wo_count), p_employee_id)
      LOOP
        l_emp_tbl(i).employee_id := emp_rec.employee_id;
        l_emp_tbl(i).employee_name := emp_rec.employee_name;
        i := i + 1;
      END LOOP;

      -- If no employees are assigned to work on the workcard
      -- the report card has to be printed atleast once. hence
      -- put some dummy value for the loop to get through.
      IF l_emp_tbl.COUNT = 0 THEN--AND p_employee_id IS NULL THEN
        l_emp_tbl(1).employee_id := -9999;
      END IF;

      IF l_emp_tbl.COUNT > 0 THEN
        FOR l_count IN l_emp_tbl.FIRST..l_emp_tbl.LAST
        LOOP

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string
            (
              fnd_log.level_statement,
              'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
              'l_emp_tbl('||l_count||') --> '||l_emp_tbl(l_count).employee_id
            );
          END IF;

          --copy the workcard start tag
          dbms_lob.write(l_merged_lob, length('<G_WORKCARD>'),length(l_merged_lob)+1, '<G_WORKCARD>');

               /********************************************************************
          * Create XML data related to employee
          ********************************************************************/
          -- add employee details to the XML output
          IF l_emp_tbl(l_count).employee_name IS NOT NULL
          THEN

             dbms_lob.write(
                  l_merged_lob,
                    length('<G_EMP_NAME><EMP_NAME>'||l_emp_tbl(l_count).employee_name),
                    length(l_merged_lob)+1, '<G_EMP_NAME><EMP_NAME>'||dbms_xmlgen.convert(l_emp_tbl(l_count).employee_name)
                   );

             dbms_lob.write(
                   l_merged_lob,
                   length('</EMP_NAME></G_EMP_NAME>'),
                   length(l_merged_lob)+1,
                   '</EMP_NAME></G_EMP_NAME>'
                 );
          END IF;

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string
            (
              fnd_log.level_statement,
              'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
              'After Processing Employee info '
            );
          END IF;

               /********************************************************************
          * Create XML data related workorder header
          ********************************************************************/

          -- Query and processing workorder details
          l_wo_con_query := l_wo_details || '(
                  SELECT
                   wop.workorder_id,
                   TO_CHAR(MIN(AHL_PRD_UTIL_PKG.Get_Op_Assigned_Start_Date('||
                      l_emp_tbl(l_count).employee_id ||
                        ',wop.workorder_id
                        ,wop.operation_sequence_num
                        ,''LINE''
                        )),
                   ''YYYY-MM-DD hh:mm:ss+HH:MM'')   Assigned_Start_Date,
                   TO_CHAR(MAX(AHL_PRD_UTIL_PKG.Get_Op_Assigned_Start_Date('||
                      l_emp_tbl(l_count).employee_id ||
                      ',wop.workorder_id
                       ,wop.operation_sequence_num
                      ,''LINE'')),
                   ''YYYY-MM-DD hh:mm:ss+HH:MM'') Assigned_End_Date
                  FROM
                    AHL_WORKORDER_OPERATIONS WOP
                  GROUP BY workorder_id
                ) WODE ';

          l_wo_con_query := l_wo_con_query || l_wo_details_where;

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string
            (
              fnd_log.level_statement,
              'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
              'Workorder details query string --->'||l_wo_con_query
            );
          END IF;


          context := dbms_xmlgen.newContext(l_wo_con_query || p_workorders_tbl(wo_count));
          dbms_xmlgen.setRowsetTag(context,null);
          dbms_xmlgen.setRowTag(context,'G_WORKORDER');
          dbms_xmlgen.setConvertSpecialChars ( context, TRUE);
          l_wo_details_lob := dbms_xmlgen.getXML(context,DBMS_XMLGEN.NONE);
          dbms_xmlgen.closeContext(context);

          -- free the temp variable for query after every iteration.
          l_wo_con_query := null;

          -- Write to lob only when some data exists.
          IF dbms_lob.getlength(l_wo_details_lob) > 0
          THEN
            -- The generated XML itself puts the XML instruction tag which is already there
            -- in final CLOB. so copy only rest of the details to the final output.
            l_offset := dbms_lob.INSTR(l_wo_details_lob, '>');

            -- copy workorder details into final lob
            dbms_lob.copy(l_merged_lob, l_wo_details_lob, dbms_lob.getlength(l_wo_details_lob), dbms_lob.getlength(l_merged_lob)+1, l_offset+ 1);
          END IF;

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string
            (
              fnd_log.level_statement,
              'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
              'After Processing Workorder Header Info '
            );
          END IF;

               /********************************************************************
          * Create XML data related to workorder quality
          ********************************************************************/

          -- Query and processing workorder details
          --get the collection_id and plan_id for the workorder.
          OPEN get_wo_qa_ids_csr(p_workorders_tbl(wo_count));
          FETCH get_wo_qa_ids_csr INTO l_plan_id, l_collection_id;
          CLOSE get_wo_qa_ids_csr;

          IF l_plan_id IS NOT NULL AND l_collection_id IS NOT NULL
          THEN

             build_qa_query(
               p_plan_id      =>  l_plan_id,
               p_collection_id    =>  l_collection_id,
               x_query_string   =>  l_query_string
               );

             context := dbms_xmlgen.newContext(l_query_string);
             dbms_xmlgen.setRowsetTag(context,'G_WO_QA_LIST');
             dbms_xmlgen.setRowTag(context,'G_WO_QA');
             dbms_xmlgen.setConvertSpecialChars ( context, TRUE);
             l_wo_qa_lob := dbms_xmlgen.getXML(context,DBMS_XMLGEN.NONE);
             dbms_xmlgen.closeContext(context);

             -- Write to lob only when some data exists.
             IF dbms_lob.getlength(l_wo_qa_lob) > 0
             THEN
                -- The generated XML itself puts the XML instruction tag which is already there
                -- in final CLOB. so copy only rest of the details to the final output.
                l_offset := dbms_lob.INSTR(l_wo_qa_lob, '>');

                -- copy workorder details into final lob
                dbms_lob.copy(l_merged_lob, l_wo_qa_lob, dbms_lob.getlength(l_wo_qa_lob), dbms_lob.getlength(l_merged_lob)+1, l_offset+ 1);
             END IF;
          END IF;

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string
            (
              fnd_log.level_statement,
              'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
              'After Processing Workorder Quality Info '
            );
          END IF;

                  /********************************************************************
          * Create XML data related to workorder operation quality details
          ********************************************************************/

          -- Query and processing workorder details
          --get the collection_id and plan_id for the workorder.
          -- Balaji modified the code for Bug # 6777371.
          -- Multiple Operations under the Work Order need to be accomodated.
          -- Bug # 6777371 -- start
          /*
          OPEN get_op_qa_ids_csr(p_workorders_tbl(wo_count));
          FETCH get_op_qa_ids_csr INTO l_plan_id, l_collection_id;
          CLOSE get_op_qa_ids_csr;
          */
                  dbms_lob.write(
                  l_merged_lob,
                    length('<G_WO_OP_QA_LIST>'),
                    length(l_merged_lob)+1,
                    '<G_WO_OP_QA_LIST>'
                   );

                                        FOR get_op_qa_ids_rec IN get_op_qa_ids_csr(p_workorders_tbl(wo_count))
                                        LOOP

                                                l_plan_id :=  get_op_qa_ids_rec.plan_id;
                                                l_collection_id := get_op_qa_ids_rec.collection_id;
                                                l_op_seq_num := get_op_qa_ids_rec.operation_sequence_num;

            IF l_plan_id IS NOT NULL AND l_collection_id IS NOT NULL
            THEN

                                                  dbms_lob.write(
                  l_merged_lob,
                    length('<G_WO_OP_QA_HEADER><QA_WO_OP_SEQ_NO>'||l_op_seq_num||'</QA_WO_OP_SEQ_NO>'),
                    length(l_merged_lob)+1,
                    '<G_WO_OP_QA_HEADER><QA_WO_OP_SEQ_NO>'||l_op_seq_num||'</QA_WO_OP_SEQ_NO>'
                   );

               build_qa_query(
                 p_plan_id      =>  l_plan_id,
                 p_collection_id    =>  l_collection_id,
                 x_query_string   =>  l_query_string
                 );

               context := dbms_xmlgen.newContext(l_query_string);
               -- Top tag need to be present.
               dbms_xmlgen.setRowsetTag(context,'G_DUMMY_TOP_OP_QA');
               dbms_xmlgen.setRowTag(context,'G_WO_OP_QA');
               dbms_xmlgen.setConvertSpecialChars ( context, TRUE);
               l_op_qa_lob := dbms_xmlgen.getXML(context,DBMS_XMLGEN.NONE);
               dbms_xmlgen.closeContext(context);

               -- Write to lob only when some data exists.
               IF dbms_lob.getlength(l_op_qa_lob) > 0
               THEN
                 -- The generated XML itself puts the XML instruction tag which is already  there
                 -- in final CLOB. so copy only rest of the details to the final output.
                 l_offset := dbms_lob.INSTR(l_op_qa_lob, '>');

                 -- copy workorder details into final lob
                 dbms_lob.copy(l_merged_lob, l_op_qa_lob, dbms_lob.getlength(l_op_qa_lob), dbms_lob.getlength(l_merged_lob)+1, l_offset+ 1);
               END IF;

                                                   dbms_lob.write(
                  l_merged_lob,
                    length('</G_WO_OP_QA_HEADER>'),
                    length(l_merged_lob)+1,
                    '</G_WO_OP_QA_HEADER>'
                   );

            END IF;
          END LOOP;
          -- Bug # 6777371 -- end

                  dbms_lob.write(
                  l_merged_lob,
                    length('</G_WO_OP_QA_LIST>'),
                    length(l_merged_lob)+1,
                    '</G_WO_OP_QA_LIST>'
                   );

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string
            (
              fnd_log.level_statement,
              'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
              'After Processing Workorder Operation Quality Info '
            );
          END IF;

          /********************************************************************
          * Create XML data related to turnover notes
          ********************************************************************/

          context := dbms_xmlgen.newContext(l_to_notes || p_workorders_tbl(wo_count));
          dbms_xmlgen.setRowsetTag(context, 'G_TO_NOTES_LIST');-- turn this off if not required
          dbms_xmlgen.setRowTag(context,'G_TO_NOTES');
          dbms_xmlgen.setConvertSpecialChars ( context, TRUE);
          l_ton_lob := dbms_xmlgen.getXML(context,DBMS_XMLGEN.NONE);
          dbms_xmlgen.closeContext(context);

          -- Write to lob only when some data exists.
          IF dbms_lob.getlength(l_ton_lob) > 0
          THEN
            -- The generated XML itself puts the XML instruction tag which is already there
            -- in final CLOB. so copy only rest of the details to the final output.
            l_offset := dbms_lob.INSTR(l_ton_lob, '>');

            -- copy workorder details into final lob
            dbms_lob.copy(l_merged_lob, l_ton_lob, dbms_lob.getlength(l_ton_lob), dbms_lob.getlength(l_merged_lob)+1, l_offset+ 1);
          END IF;

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string
            (
              fnd_log.level_statement,
              'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
              'After Processing turnover notes '
            );
          END IF;


               /********************************************************************
          * Create XML data for workorder operations
          ********************************************************************/

          --For each operation of the workorder gather operation details and add it to
          --output
          FOR l_op_rec IN c_wo_operations(p_workorders_tbl(wo_count))
          LOOP

            l_op_con_query := l_op_details_1;

            --bind total hours and hours worked
            l_op_con_query := l_op_con_query || 'NVL(AHL_PRD_UTIL_PKG.Get_Op_TotalHours_Assigned('
                      || l_emp_tbl(l_count).employee_id
                      ||', WORKORDER_ID '
                      ||', operation_sequence_num '
                      ||', '''||l_user_role||''' ),0) "TOTAL_HOURS", ';

            l_op_con_query := l_op_con_query || 'NVL(AHL_PRD_UTIL_PKG.Get_Op_transacted_hours('
                      || l_emp_tbl(l_count).employee_id
                      ||', WIP_ENTITY_ID '
                      ||', operation_sequence_num '
                      ||', '''||l_user_role||''' ),0) "HOURS_WORKED", ';

            l_op_con_query := l_op_con_query || l_op_details_2 || l_op_rec.workorder_operation_id;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
              fnd_log.string
              (
                fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
                'operation details query string --->'||l_op_con_query
              );
            END IF;

            context := dbms_xmlgen.newContext(l_op_con_query);

            dbms_xmlgen.setRowsetTag(context,null);-- turn this off if not required
            dbms_xmlgen.setRowTag(context,'G_OP_REC');
            dbms_xmlgen.setConvertSpecialChars ( context, TRUE);
            l_op_lob := dbms_xmlgen.getXML(context,DBMS_XMLGEN.NONE);
            dbms_xmlgen.closeContext(context);

            -- Free temp variable once the query is executed for next iteration.
            l_op_con_query := null;

            -- Write to lob only when some data exists.
            IF dbms_lob.getlength(l_op_lob) > 0
            THEN
              -- The generated XML itself puts the XML instruction tag which is already there
              -- in final CLOB. so copy only rest of the details to the final output.
              l_offset := dbms_lob.INSTR(l_op_lob, '>');

              -- copy workorder details into final lob
              dbms_lob.copy(l_merged_lob, l_op_lob, dbms_lob.getlength(l_op_lob), dbms_lob.getlength(l_merged_lob)+1, l_offset+ 1);
            /********************************************************************
             * Create XML data for resource transactions
             ********************************************************************/
              --Invoke AHL_PRD_RESOURCE_TRANX_PVT.Get_Resource_Txn_Defaults to get
              --resource transaction details for the operation as follows.

              AHL_PRD_RESOURCE_TRANX_PVT.Get_Resource_Txn_Defaults(
              P_api_version   => 1.0,
              P_init_msg_list   => FND_API.G_FALSE,
              p_module_type   => null,
              x_return_status   => x_return_status,
              x_msg_count   => x_msg_count,
              x_msg_data    => x_msg_data,
              p_employee_id   => l_emp_tbl(l_count).employee_id,
              p_workorder_id    => p_workorders_tbl(wo_count),
              p_operation_seq_num => l_op_rec.operation_sequence_num,
              p_function_name   => l_user_role,
              --p_user_role   => p_user_role,
              x_resource_txn_tbl  => l_x_res_txn_tbl
               );

              --For every resource transaction data returned create and include xml data as below

              IF l_x_res_txn_tbl.COUNT > 0
              THEN
                 -- The end tag of operation has to come after its resource transaction records.
                 --hence overwrite the end tag
                 l_offset := dbms_lob.INSTR(l_merged_lob, '</G_OP_REC>', length(l_merged_lob)-12, 1);

                --Insert the start tag for current resource transaction.
                dbms_lob.write(l_merged_lob, length('<G_RES_TXN_LIST>'),l_offset, '<G_RES_TXN_LIST>');

                FOR j IN l_x_res_txn_tbl.FIRST .. l_x_res_txn_tbl.LAST LOOP

                   l_dummy_string := '<G_OP_RES_REC>'||'<OPERATION_SEQUENCE>'||l_x_res_txn_tbl(j).operation_sequence_num||'</OPERATION_SEQUENCE>';
                   l_dummy_string := l_dummy_string ||'<RESOURCE_SEQUENCE>'||l_x_res_txn_tbl(j).resource_sequence_num||'</RESOURCE_SEQUENCE>';
                   l_dummy_string := l_dummy_string || '<RESOURCE_TYPE>'||dbms_xmlgen.convert(l_x_res_txn_tbl(j).resource_type_name)||'</RESOURCE_TYPE>';
                   l_dummy_string := l_dummy_string || '<RESOURCE_NAME>'||dbms_xmlgen.convert(l_x_res_txn_tbl(j).resource_name)||'</RESOURCE_NAME>';
                   l_dummy_string := l_dummy_string || '<EMPLOYEE_NAME>'||dbms_xmlgen.convert(l_x_res_txn_tbl(j).employee_name)||'</EMPLOYEE_NAME>'||'</G_OP_RES_REC>';
                   dbms_lob.write(l_merged_lob, length(l_dummy_string),length(l_merged_lob)+1, l_dummy_string);
                END LOOP;

                --Insert the end tag for current resource transaction.
                dbms_lob.write(l_merged_lob, length('</G_RES_TXN_LIST>'),length(l_merged_lob)+1, '</G_RES_TXN_LIST>');
                dbms_lob.write(l_merged_lob, length('</G_OP_REC>'),length(l_merged_lob)+1, '</G_OP_REC>');
              END IF;
            END IF;
          END LOOP;

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string
            (
              fnd_log.level_statement,
              'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
              'After Processing Workorder Operations '
            );
          END IF;


               /********************************************************************
          * Create XML data for material requirements of a workorder
          ********************************************************************/

          -- Query and process workorder materials
          context := dbms_xmlgen.newContext(l_wo_materials || p_workorders_tbl(wo_count));
          dbms_xmlgen.setRowsetTag(context, 'G_WO_MAT_LIST');
          dbms_xmlgen.setRowTag(context,'G_WO_MAT');
          dbms_xmlgen.setConvertSpecialChars ( context, TRUE);
          l_wo_mat_lob := dbms_xmlgen.getXML(context,DBMS_XMLGEN.NONE);
          dbms_xmlgen.closeContext(context);

          -- Write to lob only when some data exists.
          IF dbms_lob.getlength(l_wo_mat_lob) > 0
          THEN
             -- The generated XML itself puts the XML instruction tag which is already there
             -- in final CLOB. so copy only rest of the details to the final output.
             l_offset := dbms_lob.INSTR(l_wo_mat_lob, '>');

             -- copy workorder details into final lob
             dbms_lob.copy(l_merged_lob, l_wo_mat_lob, dbms_lob.getlength(l_wo_mat_lob), dbms_lob.getlength(l_merged_lob)+1, l_offset+ 1);

          END IF;

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string
            (
              fnd_log.level_statement,
              'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
              'After Processing Workorder Material requirements '
            );
          END IF;

               /********************************************************************
          * Create XML data for Document associations to a workorder
          ********************************************************************/

          -- Query and process workorder materials
          context := dbms_xmlgen.newContext(
              l_route_doc || p_workorders_tbl(wo_count) || ' '||
              l_op_doc || p_workorders_tbl(wo_count) || ' '||
              l_mr_doc || p_workorders_tbl(wo_count) || ' '||
              l_mc_doc || p_workorders_tbl(wo_count) || ' '
              --||l_pc_doc || p_workorders_tbl(wo_count)
               );
          dbms_xmlgen.setRowsetTag(context,'G_WO_DOC_LIST');
          dbms_xmlgen.setRowTag(context,'G_WO_DOC');
          dbms_xmlgen.setConvertSpecialChars ( context, TRUE);
          l_wo_doc_lob := dbms_xmlgen.getXML(context,DBMS_XMLGEN.NONE);
          dbms_xmlgen.closeContext(context);

          -- Write to lob only when some data exists.
          IF dbms_lob.getlength(l_wo_doc_lob) > 0
          THEN
             -- The generated XML itself puts the XML instruction tag which is already there
             -- in final CLOB. so copy only rest of the details to the final output.
             l_offset := dbms_lob.INSTR(l_wo_doc_lob, '>');

             -- copy workorder details into final lob
             dbms_lob.copy(l_merged_lob, l_wo_doc_lob, dbms_lob.getlength(l_wo_doc_lob), dbms_lob.getlength(l_merged_lob)+1, l_offset+ 1);

          END IF;

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string
            (
              fnd_log.level_statement,
              'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
              'After Processing Document associations to workorders'
            );
          END IF;

          --copy the workcard end tag
          dbms_lob.write(l_merged_lob, length('</G_WORKCARD>'),length(l_merged_lob)+1, '</G_WORKCARD>');
        END LOOP;

      END IF;

     END LOOP;
   END IF;
  /***************************************************************************************
   *End Actual API processing here
   ***************************************************************************************/

  -- Insert ending root node to maintain the XML completeness.
  dbms_lob.write(l_merged_lob, length('</G_WORKCARD_LIST>'),length(l_merged_lob)+1, '</G_WORKCARD_LIST>');

  x_xml_data := l_merged_lob;

  --Close and release the temporary lobs
  dbms_lob.close( l_merged_lob );
  --dbms_lob.close(l_wo_details_lob);
  dbms_lob.freeTemporary( l_merged_lob );

  /*
  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
    l_fnd_offset     := 1;
    l_chunk_size := 3000;
    l_clob_size := LENGTH(x_xml_data);

    WHILE (l_clob_size > 0) LOOP
       fnd_log.string
       (
      fnd_log.level_statement,
      'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
      'xml data ->'||substr(x_xml_data, l_chunk_size, l_fnd_offset)
       );
       l_clob_size := l_clob_size - l_chunk_size;
       l_fnd_offset := l_fnd_offset + l_chunk_size;
    END LOOP;

  END IF;
  */

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
      fnd_log.level_procedure,
      'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.end',
      'At the end of AHL_PRD_PRINT_PVT'
    );
        END IF;

EXCEPTION
   WHEN OTHERS THEN

      x_return_status := Fnd_Api.g_ret_sts_unexp_error;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
  fnd_log.string
  (
    fnd_log.level_statement,
    'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
    'xml data ->'||dbms_lob.substr(x_xml_data, dbms_lob.getlength(x_xml_data), 1)
  );
      END IF;

      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_unexp_error)
      THEN
         Fnd_Msg_Pub.add_exc_msg (G_PKG_NAME, l_api_name);
      END IF;

      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );



END Gen_Wo_Xml;


-- procedure to collect all the QA data and return it as a string.
procedure build_qa_query(
          p_plan_id   IN NUMBER,
          p_collection_id IN NUMBER,
          x_query_string  OUT NOCOPY VARCHAR2
         )
IS

  --cursor for getting QA Chars
  CURSOR get_qa_chars_csr(p_plan_id IN NUMBER) IS
  SELECT
    char_id,
    organization_id,
    prompt_sequence ,
    prompt,
    enabled_flag,
    default_value,
    default_value_id,
    result_column_name,
    values_exist_flag,
    displayed_flag,
    plan_name,
    plan_description,
    char_name,
    datatype,
    hardcoded_column,
    developer_name
  FROM
    QA_PLAN_CHARS_V QA
  WHERE
    plan_id = p_plan_id;

  --local variable to hold the query string to retrieve qa results
  l_query_string VARCHAR2(30000) := null; --pdoki changed for Bug 6777371
  l_rec_count NUMBER;
  l_result_column_name VARCHAR2(100);
  l_item_found VARCHAR2(1);
  l_locator_found VARCHAR2(1);
  l_item_hardcoded_column VARCHAR2(100);
  l_locator_hardcoded_column VARCHAR(100);
  l_dummy_query VARCHAR2(3000);
  l_api_name  CONSTANT  VARCHAR2(30)  := 'build_qa_query';

BEGIN

  l_query_string := 'SELECT RESULTS.COLLECTION_ID, RESULTS.OCCURRENCE ';

  l_dummy_query := ' UNION ALL SELECT null collection_id, null occurrence';

  l_rec_count := 1;

  -- retrieve all chars associated with the qa plan
  FOR qa_csr IN get_qa_chars_csr(p_plan_id) LOOP

    IF qa_csr.char_id = G_ITEM_NUMBER_CHAR THEN
    -- its an item number
      l_query_string := l_query_string ||' ,XMLConcat(XMLELEMENT("LABEL", '''|| qa_csr.prompt ||''' )';
      l_query_string := l_query_string || ', XMLELEMENT("VALUE", ITEM.' || 'CONCATENATED_SEGMENTS' || ' ) ) COLL_ELEMENT';

      l_dummy_query := l_dummy_query ||' ,XMLConcat(XMLELEMENT("LABEL", '''|| null ||''' )';
      l_dummy_query := l_dummy_query || ', XMLELEMENT("VALUE", '''|| null ||''' ) ) COLL_ELEMENT';

      l_item_found := FND_API.G_TRUE;
      l_item_hardcoded_column := qa_csr.hardcoded_column;
      --l_column_name_tbl(l_rec_count) := result_column;
    ELSIF qa_csr.char_id = G_LOCATOR_CHAR THEN

      l_query_string := l_query_string ||' ,XMLConcat(XMLELEMENT("LABEL", '''|| qa_csr.prompt ||''' )';
      l_query_string := l_query_string || ', XMLELEMENT("VALUE", LOCATOR.' || 'CONCATENATED_SEGMENTS' || ' ) ) COLL_ELEMENT';

      l_dummy_query := l_dummy_query ||' ,XMLConcat(XMLELEMENT("LABEL", '''|| null ||''' )';
      l_dummy_query := l_dummy_query || ', XMLELEMENT("VALUE", '''|| null ||''' ) ) COLL_ELEMENT';

      l_locator_found := FND_API.G_TRUE;
      l_locator_hardcoded_column := qa_csr.hardcoded_column;
      --l_column_name_tbl(l_rec_count) := result_column;
    ELSE
      IF qa_csr.hardcoded_column IS NOT NULL
      THEN
        l_result_column_name := qa_csr.developer_name;
      ELSE
        l_result_column_name := qa_csr.result_column_name;
      END IF;
      l_query_string := l_query_string ||' ,XMLConcat(XMLELEMENT("LABEL", '''|| qa_csr.prompt ||''' )';
      l_query_string := l_query_string || ', XMLELEMENT("VALUE", RESULTS.' || l_result_column_name || ' ) ) COLL_ELEMENT';

      l_dummy_query := l_dummy_query ||' ,XMLConcat(XMLELEMENT("LABEL", '''|| null ||''' )';
      l_dummy_query := l_dummy_query || ', XMLELEMENT("VALUE", '''|| null ||''' ) ) COLL_ELEMENT';
    END IF;


    l_rec_count := l_rec_count + 1;

  END LOOP;

  --l_query_string := l_query_string || ' ,'''||TO_CHAR(l_rec_count-1)||''''||' AS FIELD_COUNT';

  -- Results will all be included in the from clause
  l_query_string := l_query_string || ' FROM QA_RESULTS_V RESULTS ';

  -- Append required FROM clauses for the API.
  IF l_item_found = FND_API.G_TRUE THEN
    l_query_string := l_query_string || ' , MTL_SYSTEM_ITEMS_KFV ITEM ';
  END IF;

  IF l_locator_found = FND_API.G_TRUE THEN
    l_query_string := l_query_string || ' , MTL_ITEM_LOCATIONS_KFV LOCATOR ';
  END IF;

  -- Append collection id to the where clause
  l_query_string := l_query_string || ' WHERE RESULTS.COLLECTION_ID = ' || p_collection_id;

  -- Append required FROM clauses for the API.
  IF l_item_found = FND_API.G_TRUE THEN
    l_query_string := l_query_string || ' AND ITEM.inventory_item_id (+) = RESULTS.' || l_item_hardcoded_column;
    l_query_string := l_query_string || ' AND ITEM.organization_id (+) = RESULTS.organization_id ';
  END IF;

  IF l_locator_found = FND_API.G_TRUE THEN
    l_query_string := l_query_string || ' AND LOCATOR.inventory_location_id (+) = RESULTS.' || l_locator_hardcoded_column;
    l_query_string := l_query_string || ' AND LOCATOR.organization_id (+) = RESULTS.organization_id ';
  END IF;

  --l_query_string := l_query_string || ' ORDER BY RESULTS.OCCURRENCE ';

  --add dummy query to the original query
  l_query_string := l_query_string || l_dummy_query || ' FROM DUAL CONNECT BY 1 = 1 and level <= 3';
  x_query_string := l_query_string;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
      fnd_log.level_statement,
      'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
      'Quality Collection query string --->'||l_query_string
    );
  END IF;

END build_qa_query;

------------------------------------------------------------------------------------------------
-- Procedure to generate XML data for Workcard concurrent program
------------------------------------------------------------------------------------------------
PROCEDURE Gen_Workcard_Xml(
    errbuf                  OUT NOCOPY  VARCHAR2,
    retcode                 OUT NOCOPY  NUMBER,
    p_api_version           IN          NUMBER,
    p_visit_id        IN    NUMBER,
    p_stage_id        IN    NUMBER,
    p_wo_no_from      IN    VARCHAR2,
    p_wo_no_to        IN    VARCHAR2,
    p_sch_start_from      IN    VARCHAR2,
    p_sch_start_to      IN    VARCHAR2,
    p_employee_id     IN    NUMBER
)
IS

--declare local variables here.
l_return_status     VARCHAR2(30);
l_msg_count         NUMBER;
l_api_name          VARCHAR2(30) := 'Gen_Workcard_Xml';
l_api_version       NUMBER := 1.0;
l_workorder_tbl WORKORDER_TBL_TYPE;
l_wo_count NUMBER;
l_clob CLOB;
l_bind_value_tbl AHL_OSP_UTIL_PKG.ahl_conditions_tbl;
l_vst_wocard_csr AHL_OSP_UTIL_PKG.ahl_search_csr;
l_bind_index NUMBER;
l_query_string VARCHAR2(2000);
i NUMBER;
l_workorder_id NUMBER;
l_offset     NUMBER;
l_chunk_size NUMBER;
l_clob_size NUMBER;

BEGIN

    --set the operating unit.
    mo_global.init('AHL');

    -- this step is not required. peforming since was not getting the output.
    -- dbms_application_info.set_client_info('600');

    -- Initialize error message stack by default
    FND_MSG_PUB.Initialize;

    fnd_file.put_line(fnd_file.log, '*************API input parameters**************');
    fnd_file.put_line(fnd_file.log, 'API inputs p_api_version -> '||p_api_version);
    fnd_file.put_line(fnd_file.log, 'API inputs p_visit_id -> '||p_visit_id);
    fnd_file.put_line(fnd_file.log, 'API inputs p_stage_id -> '||p_stage_id);
    fnd_file.put_line(fnd_file.log, 'API inputs p_wo_no_from -> '||p_wo_no_from);
    fnd_file.put_line(fnd_file.log, 'API inputs p_wo_no_to -> '||p_wo_no_to);
    fnd_file.put_line(fnd_file.log, 'API inputs p_sch_start_from -> '||p_sch_start_from);
    fnd_file.put_line(fnd_file.log, 'API inputs p_sch_start_to -> '||p_sch_start_to);
    fnd_file.put_line(fnd_file.log, 'API inputs p_employee_id -> '||p_employee_id);
    fnd_file.put_line(fnd_file.log, '*************API input parameters**************');

    l_query_string := ' select
              wo.workorder_id
      from
       ahl_workorders wo,
       wip_discrete_jobs wipd,
       ahl_visits_b vst,
       ahl_visit_tasks_b vtsk
      where
       wo.visit_id = vst.visit_id and
       wo.wip_entity_id = wipd.wip_entity_id and
       wo.visit_task_id = vtsk.visit_task_id and
       vst.visit_id = vtsk.visit_id and
       wo.status_code in (3, 4, 5, 6, 7, 12, 19) and
       wo.master_workorder_flag <> ''Y'' and
       vst.status_code in (''RELEASED'',''PARTIALLY RELEASED'') ';

    l_bind_index := 1;

    IF p_visit_id IS NOT NULL THEN
      l_query_string := l_query_string || ' AND wo.visit_id = :'||l_bind_index;
  l_bind_value_tbl(l_bind_index) := p_visit_id;
  l_bind_index := l_bind_index + 1;
    END IF;

    IF p_stage_id IS NOT NULL THEN
      l_query_string := l_query_string || ' AND vtsk.stage_id = :'||l_bind_index;
  l_bind_value_tbl(l_bind_index) := p_stage_id;
  l_bind_index := l_bind_index + 1;
    END IF;

    IF p_wo_no_from IS NOT NULL AND p_wo_no_to IS NOT NULL THEN
      l_query_string := l_query_string || ' AND wo.workorder_name between :'||l_bind_index||' and :'||(l_bind_index+1);
  l_bind_value_tbl(l_bind_index) := p_wo_no_from;
  l_bind_value_tbl(l_bind_index+1) := p_wo_no_to;
  l_bind_index := l_bind_index + 2;
    END IF;

    IF p_sch_start_from IS NOT NULL THEN
      l_query_string := l_query_string || ' AND wipd.scheduled_start_date >= :'||l_bind_index;
  l_bind_value_tbl(l_bind_index) :=  fnd_date.canonical_to_date(p_sch_start_from);
  l_bind_index := l_bind_index + 1;
    END IF;

    IF p_sch_start_to IS NOT NULL THEN
      l_query_string := l_query_string || ' AND wipd.scheduled_completion_date <= :'||l_bind_index;
  l_bind_value_tbl(l_bind_index) := fnd_date.canonical_to_date(p_sch_start_to);
  l_bind_index := l_bind_index + 1;
    END IF;

    fnd_file.put_line(fnd_file.log, l_query_string);

    AHL_OSP_UTIL_PKG.OPEN_SEARCH_CURSOR(l_vst_wocard_csr, l_bind_value_tbl, l_query_string);

    i := 1;
    LOOP
      FETCH l_vst_wocard_csr INTO l_workorder_id;
      EXIT WHEN l_vst_wocard_csr%NOTFOUND;
      l_workorder_tbl(i) := l_workorder_id;
      i := i + 1;
    END LOOP;

    CLOSE l_vst_wocard_csr;


    fnd_file.put_line(fnd_file.log, 'No of workorders ->'||l_workorder_tbl.COUNT);

    IF l_workorder_tbl.COUNT > 0
    THEN
       Gen_Wo_Xml(
     p_api_version  => 1.0,
     p_init_msg_list  => FND_API.G_TRUE,
     p_commit   => FND_API.G_TRUE,
     p_validation_level => FND_API.G_VALID_LEVEL_FULL,
     p_default    => FND_API.G_TRUE,
     p_module_type  => NULL,
     x_return_status  => l_return_status,
     x_msg_count    => l_msg_count,
     x_msg_data   => errbuf,
     p_workorders_tbl => l_workorder_tbl,
     p_employee_id  => p_employee_id,
     p_user_role    => null,
     p_material_req_flag  => 'N',
     x_xml_data   => l_clob,
     p_concurrent_flag    => 'Y'
  );

        l_offset     := 1;
        l_chunk_size := 3000;
        l_clob_size := dbms_lob.getlength(l_clob);

        WHILE (l_clob_size > 0) LOOP
          fnd_file.put(fnd_file.log, dbms_lob.substr (l_clob, l_chunk_size, l_offset));
          l_clob_size := l_clob_size - l_chunk_size;
          l_offset := l_offset + l_chunk_size;
        END LOOP;

        l_msg_count := FND_MSG_PUB.Count_Msg;
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
        THEN
            retcode := 2;  -- error based only on return status
        ELSIF (l_msg_count > 0 AND l_return_status = FND_API.G_RET_STS_SUCCESS)
        THEN
           retcode := 1;  -- warning based on return status + msg count
        ELSE
     --fnd_file.put_line(fnd_file.output, dbms_lob.substr(l_clob, dbms_lob.getlength(l_clob), 1));

     l_offset     := 1;
     l_chunk_size := 3000;
     l_clob_size := dbms_lob.getlength(l_clob);

     WHILE (l_clob_size > 0) LOOP
        fnd_file.put(fnd_file.output, dbms_lob.substr (l_clob, l_chunk_size, l_offset));
        l_clob_size := l_clob_size - l_chunk_size;
        l_offset := l_offset + l_chunk_size;
     END LOOP;

           retcode := 0;  -- success, since nothing is wrong
        END IF;
     END IF;
END Gen_Workcard_Xml;

END AHL_PRD_PRINT_PVT;

/
