--------------------------------------------------------
--  DDL for Package Body AHL_PRD_LOV_SERVICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PRD_LOV_SERVICE_PVT" AS
/* $Header: AHLVLOVB.pls 120.0.12010000.5 2009/03/04 00:05:19 sikumar noship $ */

G_PKG_NAME     CONSTANT VARCHAR2(30) := 'AHL_PRD_LOV_SERVICE_PVT';
G_DEBUG                 VARCHAR2(1)  := AHL_DEBUG_PUB.is_log_enabled;


------------------------------------
-- Common constants and variables --
------------------------------------
l_log_current_level     NUMBER      := fnd_log.g_current_runtime_level;
l_log_statement         NUMBER      := fnd_log.level_statement;
l_log_procedure         NUMBER      := fnd_log.level_procedure;
l_log_error             NUMBER      := fnd_log.level_error;
l_log_unexpected        NUMBER      := fnd_log.level_unexpected;


---------------------------------------------------------------------
-- PROCEDURE
-- getVisitNumberMetaData
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getVisitNumberMetaData(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_meta_output_rec      OUT NOCOPY LovMetaData_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

l_Meta_Attribute_Rec LovMetaAttribute_Rec_Type;
l_Meta_Attribute_Tbl LovMetaAttribute_Tbl_Type;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Create Attributes Table
   -- Visit ID
   l_Meta_Attribute_Rec.AttributeName := 'VisitId';
   l_Meta_Attribute_Rec.Prompt := null;
   l_Meta_Attribute_Rec.IsDisplayed := 'F';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'integer';

   l_Meta_Attribute_Tbl(0) := l_Meta_Attribute_Rec;

   -- Visit Numbeer
   l_Meta_Attribute_Rec.AttributeName := 'VisitNumber';
   l_Meta_Attribute_Rec.Prompt := 'Visit Number';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(1) := l_Meta_Attribute_Rec;

   -- Visit Type
   l_Meta_Attribute_Rec.AttributeName := 'VisitTypeMean';
   l_Meta_Attribute_Rec.Prompt := 'Visit Type';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(2) := l_Meta_Attribute_Rec;

   -- Item Description
   l_Meta_Attribute_Rec.AttributeName := 'ItemDescription';
   l_Meta_Attribute_Rec.Prompt := 'Item Description';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(3) := l_Meta_Attribute_Rec;

   -- Serial Number
   l_Meta_Attribute_Rec.AttributeName := 'SerialNumber';
   l_Meta_Attribute_Rec.Prompt := 'Serial Number';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(4) := l_Meta_Attribute_Rec;

   -- Unit Name
   l_Meta_Attribute_Rec.AttributeName := 'UnitName';
   l_Meta_Attribute_Rec.Prompt := 'Unit';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(5) := l_Meta_Attribute_Rec;

   -- Organization Name
   l_Meta_Attribute_Rec.AttributeName := 'OrganizationName';
   l_Meta_Attribute_Rec.Prompt := 'Organization';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(6) := l_Meta_Attribute_Rec;

   -- Department Name
   l_Meta_Attribute_Rec.AttributeName := 'DepartmentName';
   l_Meta_Attribute_Rec.Prompt := 'Department';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(7) := l_Meta_Attribute_Rec;

   -- Populate output parameter
   x_lov_meta_output_rec.LovTitle := 'Search Visits';
   x_lov_meta_output_rec.LovMetaAttributeTbl := l_Meta_Attribute_Tbl;

END getVisitNumberMetaData;

---------------------------------------------------------------------
-- PROCEDURE
-- getVisitNumberResults
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getVisitNumberResults(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_result_output_rec    OUT NOCOPY LovOutput_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

l_criteria_tbl LovCriteria_Tbl_Type;
l_results_tbl  LovResult_Tbl_Type;
l_attributes_tbl LovResultAttribute_Tbl_Type;

i    integer ;

-- Local Variables for the sql string.
l_sql_string     VARCHAR2(30000);
l_bind_index     NUMBER;
l_bindvar_tbl AHL_OSP_UTIL_PKG.ahl_conditions_tbl;
-- dynamic cursor
l_cur            AHL_OSP_UTIL_PKG.ahl_search_csr;

--Local Variables for search results
l_rownum         NUMBER;
l_visit_id       NUMBER;
l_visit_num      NUMBER;
l_visit_type     fnd_lookup_values_vl.meaning%type;
l_item           MTL_SYSTEM_ITEMS_KFV.concatenated_segments%type;
l_serial_number  CSI_ITEM_INSTANCES.serial_number%type;
l_org            HR_ALL_ORGANIZATION_UNITS.name%type;
l_dept           BOM_DEPARTMENTS.description%type;
l_unit           ahl_unit_config_headers.name%type;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- SELECT CLAUSE AND BASIC WHERE CONDITIONS
   l_sql_string := 'SELECT * FROM ( SELECT DISTINCT Rownum RN, vst.visit_id,';
   l_sql_string := l_sql_string || ' vst.visit_number,fndvt.meaning visit_type_mean, ';
   l_sql_string := l_sql_string || ' mtsb.concatenated_segments item_description, csis.serial_number, ';
   l_sql_string := l_sql_string || ' HROU.name organization_name,BDPT.description department_name, ';
   l_sql_string := l_sql_string || ' AHL_UTILITY_PVT.GET_UNIT_NAME(VST.ITEM_INSTANCE_ID) UNIT_NAME ';

   l_sql_string := l_sql_string || ' FROM  ahl_visits_b vst, AHL_SIMULATION_PLANS_B ASML, ';
   l_sql_string := l_sql_string || ' fnd_lookup_values_vl fndvt, MTL_SYSTEM_ITEMS_KFV MTSB, ';
   l_sql_string := l_sql_string || ' CSI_ITEM_INSTANCES CSIS, HR_ALL_ORGANIZATION_UNITS HROU, ';
   l_sql_string := l_sql_string || ' BOM_DEPARTMENTS BDPT ';

   l_sql_string := l_sql_string || ' WHERE vst.simulation_plan_id = asml.simulation_plan_id AND ';
   l_sql_string := l_sql_string || ' ASML.PRIMARY_PLAN_FLAG = ''Y'' AND ';
   l_sql_string := l_sql_string || ' vst.status_code not in ( ''PLANNING'', ''DELETED'' ) AND ';
   l_sql_string := l_sql_string || ' vst.visit_type_code = fndvt.lookup_code(+) AND ';
   l_sql_string := l_sql_string || ' fndvt.lookup_type(+) = ''AHL_PLANNING_VISIT_TYPE'' AND ';
   l_sql_string := l_sql_string || ' VSt.INVENTORY_ITEM_ID = MTSB.INVENTORY_ITEM_ID(+) AND ';
   l_sql_string := l_sql_string || ' VSt.ITEM_ORGANIZATION_ID = MTSB.ORGANIZATION_ID AND ';
   l_sql_string := l_sql_string || ' Vst.ITEM_INSTANCE_ID = CSIS.INSTANCE_ID(+) AND ';
   l_sql_string := l_sql_string || ' Vst.ORGANIZATION_ID = HROU.ORGANIZATION_ID AND ';
   l_sql_string := l_sql_string || ' VSt.DEPARTMENT_ID = BDPT.DEPARTMENT_ID AND ';
   l_sql_string := l_sql_string || ' vSt.TEMPLATE_FLAG = ''N'' ';

   --Get Dynamic Search Criteria
   l_criteria_tbl :=p_lov_input_rec.LovCriteriaTbl;
   l_bind_index     := 1;

   IF l_criteria_tbl.count > 0 THEN
      i:=l_criteria_tbl.first;
      LOOP

         IF upper(l_criteria_tbl(i).AttributeName) = upper('VisitTypeMean') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(fndvt.meaning) like :VISIT_TYPE ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('VisitId') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND vst.visit_id like :VISIT_ID ';
              l_bindvar_tbl(l_bind_index) := l_criteria_tbl(i).AttributeValue;
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('VisitNumber') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND vst.visit_number like :VISIT_NUM ';
              l_bindvar_tbl(l_bind_index) := l_criteria_tbl(i).AttributeValue;
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('DepartmentName') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(BDPT.description) like :DEPT ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('ItemDescription') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(mtsb.concatenated_segments) like :ITEM ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('SerialNumber') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(csis.serial_number) like :SN ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('UnitName') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(UNIT_NAME) like :UNIT ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('OrganizationName') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(HROU.name) like :ORG ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

      EXIT WHEN i= l_criteria_tbl.last;
      i:= i+1;
      END LOOP;
   END IF;

   -- SET START/END Row
   l_sql_string := l_sql_string || ' and rownum < :MAX_ROW ';
   --Max Row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows+1;
   l_bind_index := l_bind_index + 1;

   l_sql_string := l_sql_string || ' Order By vst.visit_number ) ';
   l_sql_string := l_sql_string || ' WHERE RN BETWEEN :START_ROW AND :END_ROW ';
   --start row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow+1;
   l_bind_index := l_bind_index + 1;
   --end row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows;
   l_bind_index := l_bind_index + 1;

   --open l_cur FOR l_sql_string;
   AHL_OSP_UTIL_PKG.OPEN_SEARCH_CURSOR
   (
       p_conditions_tbl => l_bindvar_tbl,
       p_sql_str        => l_sql_string,
       p_x_csr          => l_cur
   );

   i:=1;
   LOOP
     FETCH l_cur INTO     l_rownum,
                          l_visit_id,
                          l_visit_num,
                          l_visit_type,
                          l_item,
                          l_serial_number,
                          l_org,
                          l_dept,
                          l_unit;


     EXIT WHEN l_cur%NOTFOUND;

     -- Visit ID
     l_attributes_tbl(1).AttributeName := 'VisitId';
     l_attributes_tbl(1).AttributeValue := l_visit_id;

     -- Visit Numbeer
     l_attributes_tbl(2).AttributeName := 'VisitNumber';
     l_attributes_tbl(2).AttributeValue := l_visit_num;

     -- Visit Type
     l_attributes_tbl(3).AttributeName := 'VisitTypeMean';
     l_attributes_tbl(3).AttributeValue := l_visit_type;

     -- Item Description
     l_attributes_tbl(4).AttributeName := 'ItemDescription';
     l_attributes_tbl(4).AttributeValue := l_item;

     -- Serial Number
     l_attributes_tbl(5).AttributeName := 'SerialNumber';
     l_attributes_tbl(5).AttributeValue := l_serial_number;

     -- Unit Name
     l_attributes_tbl(6).AttributeName := 'UnitName';
     l_attributes_tbl(6).AttributeValue := l_unit;

     -- Organization Name
     l_attributes_tbl(7).AttributeName := 'OrganizationName';
     l_attributes_tbl(7).AttributeValue := l_org;

     -- Department Name
     l_attributes_tbl(8).AttributeName := 'DepartmentName';
     l_attributes_tbl(8).AttributeValue := l_dept;

     l_results_tbl(i) := l_attributes_tbl;
     i:=i+1;

   END LOOP;
   CLOSE l_cur;
   -- Create Attributes Table

   -- Populate output parameter
   x_lov_result_output_rec.StartRow := p_lov_input_rec.StartRow;
   x_lov_result_output_rec.NumberOfRows := i-1;
   x_lov_result_output_rec.LovResultTbl := l_results_tbl;

END getVisitNumberResults;

---------------------------------------------------------------------
-- PROCEDURE
-- getUnitMetaData
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getUnitMetaData(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_meta_output_rec      OUT NOCOPY LovMetaData_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

l_Meta_Attribute_Rec LovMetaAttribute_Rec_Type;
l_Meta_Attribute_Tbl LovMetaAttribute_Tbl_Type;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Create Attributes Table
   -- Unit Config Header ID
   l_Meta_Attribute_Rec.AttributeName := 'UnitConfigHeaderId';
   l_Meta_Attribute_Rec.Prompt := null;
   l_Meta_Attribute_Rec.IsDisplayed := 'F';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'integer';

   l_Meta_Attribute_Tbl(0) := l_Meta_Attribute_Rec;

   -- Unit Name
   l_Meta_Attribute_Rec.AttributeName := 'UnitName';
   l_Meta_Attribute_Rec.Prompt := 'Unit Name';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(1) := l_Meta_Attribute_Rec;

   -- Instance Number
   l_Meta_Attribute_Rec.AttributeName := 'InstanceNumber';
   l_Meta_Attribute_Rec.Prompt := 'Instance Number';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(2) := l_Meta_Attribute_Rec;

   -- Item Number
   l_Meta_Attribute_Rec.AttributeName := 'ItemNumber';
   l_Meta_Attribute_Rec.Prompt := 'Item Number';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(3) := l_Meta_Attribute_Rec;

   -- Serial Number
   l_Meta_Attribute_Rec.AttributeName := 'SerialNumber';
   l_Meta_Attribute_Rec.Prompt := 'Serial Number';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(4) := l_Meta_Attribute_Rec;

   -- Populate output parameter
   x_lov_meta_output_rec.LovTitle := 'Search Tail Number';
   x_lov_meta_output_rec.LovMetaAttributeTbl := l_Meta_Attribute_Tbl;

END getUnitMetaData;

---------------------------------------------------------------------
-- PROCEDURE
-- getUnitResults
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getUnitResults(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_result_output_rec    OUT NOCOPY LovOutput_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

l_criteria_tbl LovCriteria_Tbl_Type;
l_results_tbl  LovResult_Tbl_Type;
l_attributes_tbl LovResultAttribute_Tbl_Type;

i    integer ;

-- Local Variables for the sql string.
l_sql_string     VARCHAR2(30000);
l_bind_index     NUMBER;
l_bindvar_tbl AHL_OSP_UTIL_PKG.ahl_conditions_tbl;
-- dynamic cursor
l_cur            AHL_OSP_UTIL_PKG.ahl_search_csr;

--Local Variables for search results
l_rownum         NUMBER;
l_uc_header_id   NUMBER;
l_uc_name        AHL_UNIT_CONFIG_HEADERS.NAME%type;
l_instance_num   MTL_SYSTEM_ITEMS_KFV.concatenated_segments%type;
l_serial_number  CSI_ITEM_INSTANCES.INSTANCE_NUMBER%type;
l_item           MTL_SYSTEM_ITEMS_KFV.CONCATENATED_SEGMENTS%type;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- SELECT CLAUSE AND BASIC WHERE CONDITIONS
   l_sql_string := 'SELECT * FROM ( SELECT DISTINCT Rownum RN, U.UNIT_CONFIG_HEADER_ID UC_HEADER_ID,';
   l_sql_string := l_sql_string || ' U.NAME UC_NAME,C.INSTANCE_NUMBER , ';
   l_sql_string := l_sql_string || ' I.CONCATENATED_SEGMENTS ITEM_NUMBER, ';
   l_sql_string := l_sql_string || ' C.SERIAL_NUMBER ';

   l_sql_string := l_sql_string || ' FROM  AHL_UNIT_CONFIG_HEADERS U, ';
   l_sql_string := l_sql_string || ' CSI_ITEM_INSTANCES C, ';
   l_sql_string := l_sql_string || ' MTL_SYSTEM_ITEMS_KFV I ';

   l_sql_string := l_sql_string || ' WHERE U.csi_item_instance_id = C.instance_id ';
   l_sql_string := l_sql_string || ' AND C.inventory_item_id = I.inventory_item_id ';
   l_sql_string := l_sql_string || ' AND C.last_vld_organization_id = I.organization_id ';
   l_sql_string := l_sql_string || ' AND ahl_util_uc_pkg.get_uc_status_code(U.UNIT_CONFIG_HEADER_ID) NOT IN (''DRAFT'', ''EXPIRED'')';

   --Get Dynamic Search Criteria
   l_criteria_tbl :=p_lov_input_rec.LovCriteriaTbl;
   l_bind_index     := 1;

   IF l_criteria_tbl.count > 0 THEN
      i:=l_criteria_tbl.first;
      LOOP

         IF upper(l_criteria_tbl(i).AttributeName) = upper('UnitName') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(U.NAME) like :UNIT_NAME ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('UnitConfigHeaderId') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND U.UNIT_CONFIG_HEADER_ID like :UC_ID ';
              l_bindvar_tbl(l_bind_index) := l_criteria_tbl(i).AttributeValue;
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('InstanceNumber') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(C.INSTANCE_NUMBER) like :INS_NUM ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('ItemNumber') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(I.CONCATENATED_SEGMENTS) like :ITEM ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('SerialNumber') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(C.SERIAL_NUMBER) like :SN ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

      EXIT WHEN i= l_criteria_tbl.last;
      i:= i+1;
      END LOOP;
   END IF;

   -- SET START/END Row
   l_sql_string := l_sql_string || ' and rownum < :MAX_ROW ';
   --Max Row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows +1;
   l_bind_index := l_bind_index + 1;

   l_sql_string := l_sql_string || ' Order By U.NAME ) ';
   l_sql_string := l_sql_string || ' WHERE RN BETWEEN :START_ROW AND :END_ROW ';
   --start row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow +1;
   l_bind_index := l_bind_index + 1;
   --end row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows ;
   l_bind_index := l_bind_index + 1;

   --open l_cur FOR l_sql_string;
   AHL_OSP_UTIL_PKG.OPEN_SEARCH_CURSOR
   (
       p_conditions_tbl => l_bindvar_tbl,
       p_sql_str        => l_sql_string,
       p_x_csr          => l_cur
   );

   i:=1;
   LOOP
     FETCH l_cur INTO     l_rownum,
                          l_uc_header_id,
                          l_uc_name,
                          l_instance_num,
                          l_item,
                          l_serial_number;

     EXIT WHEN l_cur%NOTFOUND;

     l_attributes_tbl(1).AttributeName := 'UnitConfigHeaderId';
     l_attributes_tbl(1).AttributeValue := l_uc_header_id;

     l_attributes_tbl(2).AttributeName := 'UnitName';
     l_attributes_tbl(2).AttributeValue := l_uc_name;

     l_attributes_tbl(3).AttributeName := 'InstanceNumber';
     l_attributes_tbl(3).AttributeValue := l_instance_num;

     l_attributes_tbl(4).AttributeName := 'ItemNumber';
     l_attributes_tbl(4).AttributeValue := l_item;

     l_attributes_tbl(5).AttributeName := 'SerialNumber';
     l_attributes_tbl(5).AttributeValue := l_serial_number;

     l_results_tbl(i) := l_attributes_tbl;
     i:=i+1;

   END LOOP;
   CLOSE l_cur;
   -- Create Attributes Table

   -- Populate output parameter
   x_lov_result_output_rec.StartRow := p_lov_input_rec.StartRow;
   x_lov_result_output_rec.NumberOfRows := i-1;
   x_lov_result_output_rec.LovResultTbl := l_results_tbl;

END getUnitResults;

---------------------------------------------------------------------
-- PROCEDURE
-- getEmployeeMetaData
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getEmployeeMetaData(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_meta_output_rec      OUT NOCOPY LovMetaData_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

l_Meta_Attribute_Rec LovMetaAttribute_Rec_Type;
l_Meta_Attribute_Tbl LovMetaAttribute_Tbl_Type;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Create Attributes Table
   l_Meta_Attribute_Rec.AttributeName := 'EmployeeNumber';
   l_Meta_Attribute_Rec.Prompt := 'Employee Number';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(0) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'EmpName';
   l_Meta_Attribute_Rec.Prompt := 'Name';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(1) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'EffectiveStartDate';
   l_Meta_Attribute_Rec.Prompt := 'Effective Start Date';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'date';

   l_Meta_Attribute_Tbl(2) := l_Meta_Attribute_Rec;

   -----
   l_Meta_Attribute_Rec.AttributeName := 'EffectiveEndDate';
   l_Meta_Attribute_Rec.Prompt := 'Effective End Date';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'date';

   l_Meta_Attribute_Tbl(3) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'OrgName';
   l_Meta_Attribute_Rec.Prompt := 'Organization';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(4) := l_Meta_Attribute_Rec;
   ----
   l_Meta_Attribute_Rec.AttributeName := 'OrgID';
   l_Meta_Attribute_Rec.Prompt := null;
   l_Meta_Attribute_Rec.IsDisplayed := 'F';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'integer';

   l_Meta_Attribute_Tbl(5) := l_Meta_Attribute_Rec;
   ----
   l_Meta_Attribute_Rec.AttributeName := 'EmployeeId';
   l_Meta_Attribute_Rec.Prompt := null;
   l_Meta_Attribute_Rec.IsDisplayed := 'F';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'integer';

   l_Meta_Attribute_Tbl(6) := l_Meta_Attribute_Rec;

   -- Populate output parameter
   x_lov_meta_output_rec.LovTitle := 'Search Employee';
   x_lov_meta_output_rec.LovMetaAttributeTbl := l_Meta_Attribute_Tbl;

END getEmployeeMetaData;

---------------------------------------------------------------------
-- PROCEDURE
-- getEmployeeResults
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getEmployeeResults(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_result_output_rec    OUT NOCOPY LovOutput_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

l_criteria_tbl LovCriteria_Tbl_Type;
l_results_tbl  LovResult_Tbl_Type;
l_attributes_tbl LovResultAttribute_Tbl_Type;

i    integer ;

-- Local Variables for the sql string.
l_sql_string     VARCHAR2(30000);
l_bind_index     NUMBER;
l_bindvar_tbl AHL_OSP_UTIL_PKG.ahl_conditions_tbl;
-- dynamic cursor
l_cur            AHL_OSP_UTIL_PKG.ahl_search_csr;

--Local Variables for search results
l_rownum       NUMBER;
l_emp_num      mtl_employees_current_view.EMPLOYEE_NUM%type;
l_emp_name     mtl_employees_current_view.FULL_NAME%type;
l_org_name     HR_ORGANIZATION_UNITS.NAME%type;
l_start_date   DATE;
l_end_date     DATE;
l_org_id       NUMBER;
l_emp_id       NUMBER;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- SELECT CLAUSE AND BASIC WHERE CONDITIONS
   l_sql_string := 'SELECT * FROM ( SELECT DISTINCT Rownum RN, PF.EMPLOYEE_NUM EMPLOYEE_NUMBER,';
   l_sql_string := l_sql_string || ' PF.FULL_NAME EMP_NAME, BRE.EFFECTIVE_START_DATE , ';
   l_sql_string := l_sql_string || ' BRE.EFFECTIVE_END_DATE ,HOU.NAME ORG_NAME, ';
   l_sql_string := l_sql_string || ' HOU.ORGANIZATION_ID,pf.employee_id EMPLOYEE_ID ';

   l_sql_string := l_sql_string || ' FROM  mtl_employees_current_view pf, bom_resource_employees bre, ';
   l_sql_string := l_sql_string || ' HR_ORGANIZATION_UNITS HOU, FND_USER FU ';

   l_sql_string := l_sql_string || ' WHERE pf.employee_id = bre.person_id ';
   l_sql_string := l_sql_string || ' and pf.organization_id = bre.organization_id ';
   l_sql_string := l_sql_string || ' and sysdate between BRE.EFFECTIVE_START_DATE and BRE.EFFECTIVE_END_DATE ';
   l_sql_string := l_sql_string || ' and pf.organization_id = hou.organization_id ';
   l_sql_string := l_sql_string || ' and FU.employee_id = pf.employee_id ';

   --Get Dynamic Search Criteria
   l_criteria_tbl :=p_lov_input_rec.LovCriteriaTbl;
   l_bind_index     := 1;

   IF l_criteria_tbl.count > 0 THEN
      i:=l_criteria_tbl.first;
      LOOP

         IF upper(l_criteria_tbl(i).AttributeName) = upper('EmployeeNumber') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(PF.EMPLOYEE_NUM) like :EMP_NUM ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('EffectiveStartDate') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND BRE.EFFECTIVE_START_DATE like :START_DATE ';
              l_bindvar_tbl(l_bind_index) := l_criteria_tbl(i).AttributeValue;
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('EffectiveEndDate') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND BRE.EFFECTIVE_END_DATE like :END_DATE ';
              l_bindvar_tbl(l_bind_index) := l_criteria_tbl(i).AttributeValue;
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('EmpName') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(PF.FULL_NAME) like :EMP_NAME ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('OrgName') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(HOU.NAME) like :ORG_NAME ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('OrgID') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND HOU.ORGANIZATION_ID like :ORG_ID ';
              l_bindvar_tbl(l_bind_index) := l_criteria_tbl(i).AttributeValue;
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('EmployeeId') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND pf.employee_id like :EMP_ID ';
              l_bindvar_tbl(l_bind_index) := l_criteria_tbl(i).AttributeValue;
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

      EXIT WHEN i= l_criteria_tbl.last;
      i:= i+1;
      END LOOP;
   END IF;

   -- SET START/END Row
   l_sql_string := l_sql_string || ' and rownum < :MAX_ROW ';
   --Max Row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows+1;
   l_bind_index := l_bind_index + 1;

   l_sql_string := l_sql_string || ' Order By PF.FULL_NAME ) ';
   l_sql_string := l_sql_string || ' WHERE RN BETWEEN :START_ROW AND :END_ROW ';
   --start row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow+1;
   l_bind_index := l_bind_index + 1;
   --end row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows;
   l_bind_index := l_bind_index + 1;

   --open l_cur FOR l_sql_string;
   AHL_OSP_UTIL_PKG.OPEN_SEARCH_CURSOR
   (
       p_conditions_tbl => l_bindvar_tbl,
       p_sql_str        => l_sql_string,
       p_x_csr          => l_cur
   );

   i:=1;
   LOOP
     FETCH l_cur INTO     l_rownum,
                          l_emp_num,
                          l_emp_name,
                          l_start_date,
                          l_end_date,
                          l_org_name,
                          l_org_id,
                          l_emp_id;

     EXIT WHEN l_cur%NOTFOUND;

     l_attributes_tbl(1).AttributeName := 'EmployeeNumber';
     l_attributes_tbl(1).AttributeValue := l_emp_num;

     l_attributes_tbl(2).AttributeName := 'EmpName';
     l_attributes_tbl(2).AttributeValue := l_emp_name;

     l_attributes_tbl(3).AttributeName := 'EffectiveStartDate';
     l_attributes_tbl(3).AttributeValue := l_start_date;

     l_attributes_tbl(4).AttributeName := 'EffectiveEndDate';
     l_attributes_tbl(4).AttributeValue := l_end_date;

     l_attributes_tbl(5).AttributeName := 'OrgName';
     l_attributes_tbl(5).AttributeValue := l_org_name;

     l_attributes_tbl(6).AttributeName := 'OrgID';
     l_attributes_tbl(6).AttributeValue := l_org_id;

     l_attributes_tbl(7).AttributeName := 'EmployeeId';
     l_attributes_tbl(7).AttributeValue := l_emp_id;

     l_results_tbl(i) := l_attributes_tbl;
     i:=i+1;

   END LOOP;
   CLOSE l_cur;
   -- Create Attributes Table

   -- Populate output parameter
   x_lov_result_output_rec.StartRow := p_lov_input_rec.StartRow;
   x_lov_result_output_rec.NumberOfRows := i-1;
   x_lov_result_output_rec.LovResultTbl := l_results_tbl;

END getEmployeeResults;

---------------------------------------------------------------------
-- PROCEDURE
-- getEmpNameMetaData
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getEmpNameMetaData(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_meta_output_rec      OUT NOCOPY LovMetaData_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

l_Meta_Attribute_Rec LovMetaAttribute_Rec_Type;
l_Meta_Attribute_Tbl LovMetaAttribute_Tbl_Type;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Create Attributes Table
   l_Meta_Attribute_Rec.AttributeName := 'EmpName';
   l_Meta_Attribute_Rec.Prompt := 'Name';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(0) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'EmpLovEmpNum';
   l_Meta_Attribute_Rec.Prompt := 'Employee Number';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(1) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'EmpLovEmpId';
   l_Meta_Attribute_Rec.Prompt := null;
   l_Meta_Attribute_Rec.IsDisplayed := 'F';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'integer';

   l_Meta_Attribute_Tbl(2) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'EmpLovDepartmentId';
   l_Meta_Attribute_Rec.Prompt := null;
   l_Meta_Attribute_Rec.IsDisplayed := 'F';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'integer';

   l_Meta_Attribute_Tbl(3) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'EmpLovResourceId';
   l_Meta_Attribute_Rec.Prompt := null;
   l_Meta_Attribute_Rec.IsDisplayed := 'F';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'integer';

   l_Meta_Attribute_Tbl(4) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'EmpLovEmpId';
   l_Meta_Attribute_Rec.Prompt := null;
   l_Meta_Attribute_Rec.IsDisplayed := 'F';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'integer';

   l_Meta_Attribute_Tbl(5) := l_Meta_Attribute_Rec;

   -- Populate output parameter
   x_lov_meta_output_rec.LovTitle := 'Search Employee';
   x_lov_meta_output_rec.LovMetaAttributeTbl := l_Meta_Attribute_Tbl;

END getEmpNameMetaData;

---------------------------------------------------------------------
-- PROCEDURE
-- getEmpNameResults
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getEmpNameResults(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_result_output_rec    OUT NOCOPY LovOutput_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

-- Define local Variables
L_API_VERSION           CONSTANT NUMBER := 1.0;
L_API_NAME              CONSTANT VARCHAR2(30) := 'getEmpNameResults';
L_FULL_NAME             CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

l_criteria_tbl LovCriteria_Tbl_Type;
l_results_tbl  LovResult_Tbl_Type;
l_attributes_tbl LovResultAttribute_Tbl_Type;

i    integer ;

-- Local Variables for the sql string.
l_sql_string     VARCHAR2(30000);
l_bind_index     NUMBER;
l_bindvar_tbl AHL_OSP_UTIL_PKG.ahl_conditions_tbl;
-- dynamic cursor
l_cur            AHL_OSP_UTIL_PKG.ahl_search_csr;

--Local Variables for search results
    l_rownum	              NUMBER       ;
    l_Resource_ID             NUMBER       ;
    l_Emp_Number	          mtl_employees_current_view.employee_num%type;
    l_Emp_Name  	          mtl_employees_current_view.full_name%type;
    l_Dept_ID       	      NUMBER       ;
    l_Emp_ID                  NUMBER     ;


BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- SELECT CLAUSE AND BASIC WHERE CONDITIONS
   l_sql_string := 'SELECT * FROM ( SELECT rownum RN, bdri.resource_id ,pf.employee_num,pf.full_name, bdri.department_id,pf.employee_id ';
   l_sql_string := l_sql_string || ' FROM  mtl_employees_current_view pf, bom_resource_employees bre, bom_dept_res_instances bdri ';
   l_sql_string := l_sql_string || ' WHERE bre.instance_id = bdri.instance_id ';
   l_sql_string := l_sql_string || ' and pf.employee_id=bre.person_id ';
   l_sql_string := l_sql_string || ' and pf.organization_id = bre.organization_id ';
   l_sql_string := l_sql_string || ' and sysdate between BRE.EFFECTIVE_START_DATE and BRE.EFFECTIVE_END_DATE ';

   --Get Dynamic Search Criteria
   l_criteria_tbl :=p_lov_input_rec.LovCriteriaTbl;
   l_bind_index     := 1;

   IF l_criteria_tbl.count > 0 THEN
      i:=l_criteria_tbl.first;
      LOOP
         IF upper(l_criteria_tbl(i).AttributeName) = upper('EmpName') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(pf.full_name) like :EMP_NAME ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('EmpLovDepartmentId') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND bdri.department_id like :DEPT_ID ';
              l_bindvar_tbl(l_bind_index) := l_criteria_tbl(i).AttributeValue;
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('EmpLovResourceId') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND bdri.resource_id like :RES_ID ';
              l_bindvar_tbl(l_bind_index) := l_criteria_tbl(i).AttributeValue;
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('EmpLovEmpNum') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(pf.employee_num) like :EMP_NUM ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('EmpLovEmpId') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND pf.employee_id like :EMP_ID ';
              l_bindvar_tbl(l_bind_index) := l_criteria_tbl(i).AttributeValue;
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

      EXIT WHEN i= l_criteria_tbl.last;
      i:= i+1;
      END LOOP;
   END IF;

   -- SET START/END Row
   l_sql_string := l_sql_string || ' and rownum < :MAX_ROW ';
   --Max Row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows +1;
   l_bind_index := l_bind_index + 1;

   l_sql_string := l_sql_string || ' Order By pf.full_name) ';
   l_sql_string := l_sql_string || ' WHERE RN BETWEEN :START_ROW AND :END_ROW ';
   --start row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow +1;
   l_bind_index := l_bind_index + 1;
   --end row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows;
   l_bind_index := l_bind_index + 1;

   --open l_cur FOR l_sql_string;
   AHL_OSP_UTIL_PKG.OPEN_SEARCH_CURSOR
   (
       p_conditions_tbl => l_bindvar_tbl,
       p_sql_str        => l_sql_string,
       p_x_csr          => l_cur
   );

   i:=1;
   LOOP
     FETCH l_cur INTO     l_rownum,
                          l_Resource_ID,
                          l_Emp_Number,
                          l_Emp_Name,
                          l_Dept_ID,
                          l_Emp_ID;
     EXIT WHEN l_cur%NOTFOUND;

     --
     l_attributes_tbl(1).AttributeName := 'EmpName';
     l_attributes_tbl(1).AttributeValue := l_Emp_Name;

     --
     l_attributes_tbl(2).AttributeName := 'EmpLovEmpNum';
     l_attributes_tbl(2).AttributeValue := l_Emp_Number;

     --
     l_attributes_tbl(3).AttributeName := 'EmpLovEmpId';
     l_attributes_tbl(3).AttributeValue := l_Emp_ID;

     --
     l_attributes_tbl(4).AttributeName := 'EmpLovDepartmentId';
     l_attributes_tbl(4).AttributeValue := l_Dept_ID;

     --
     l_attributes_tbl(5).AttributeName := 'EmpLovResourceId';
     l_attributes_tbl(5).AttributeValue := l_Resource_ID;

     l_results_tbl(i) := l_attributes_tbl;
     i:=i+1;

   END LOOP;
   CLOSE l_cur;
   -- Create Attributes Table

   -- Populate output parameter
   x_lov_result_output_rec.StartRow := p_lov_input_rec.StartRow;
   x_lov_result_output_rec.NumberOfRows := i-1;
   x_lov_result_output_rec.LovResultTbl := l_results_tbl;

END getEmpNameResults;

---------------------------------------------------------------------
-- PROCEDURE
-- getWOStatusMetaData
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getWOStatusMetaData(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_meta_output_rec      OUT  NOCOPY LovMetaData_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

l_Meta_Attribute_Rec LovMetaAttribute_Rec_Type;
l_Meta_Attribute_Tbl LovMetaAttribute_Tbl_Type;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Create Attributes Table
   l_Meta_Attribute_Rec.AttributeName := 'Code';
   l_Meta_Attribute_Rec.Prompt := 'Code';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(0) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'Meaning';
   l_Meta_Attribute_Rec.Prompt := 'Name';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(1) := l_Meta_Attribute_Rec;

   -- Populate output parameter
   x_lov_meta_output_rec.LovTitle := 'Search Work Order Status';
   x_lov_meta_output_rec.LovMetaAttributeTbl := l_Meta_Attribute_Tbl;

END getWOStatusMetaData;

---------------------------------------------------------------------
-- PROCEDURE
-- getWOStatusResults
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getWOStatusResults(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_result_output_rec    OUT NOCOPY LovOutput_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

-- Define local Variables
L_API_VERSION           CONSTANT NUMBER := 1.0;
L_API_NAME              CONSTANT VARCHAR2(30) := 'getWOStatusResults';
L_FULL_NAME             CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

l_criteria_tbl LovCriteria_Tbl_Type;
l_results_tbl  LovResult_Tbl_Type;
l_attributes_tbl LovResultAttribute_Tbl_Type;

i    integer ;

-- Local Variables for the sql string.
l_sql_string     VARCHAR2(30000);
l_bind_index     NUMBER;
l_bindvar_tbl AHL_OSP_UTIL_PKG.ahl_conditions_tbl;
-- dynamic cursor
l_cur            AHL_OSP_UTIL_PKG.ahl_search_csr;

--Local Variables for search results
    l_code	          FND_LOOKUP_VALUES_VL.lookup_code%type;
    l_mean 	          FND_LOOKUP_VALUES_VL.meaning%type;
    l_rownum          NUMBER;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- SELECT CLAUSE AND BASIC WHERE CONDITIONS
   l_sql_string := 'SELECT rownum , meaning,STATUS_CODE FROM ( select DISTINCT FND.MEANING meaning, SOR.NEXT_STATUS_CODE STATUS_CODE ';
   l_sql_string := l_sql_string || ' FROM  AHL_STATUS_ORDER_RULES SOR, FND_LOOKUP_VALUES_VL FND ';
   l_sql_string := l_sql_string || ' where SOR.SYSTEM_STATUS_TYPE = ''AHL_JOB_STATUS'' AND FND.LOOKUP_TYPE(+)= ''AHL_JOB_STATUS'' ';
   l_sql_string := l_sql_string || ' AND FND.LOOKUP_CODE(+) = SOR.NEXT_STATUS_CODE ';
   --Get Dynamic Search Criteria
   l_criteria_tbl :=p_lov_input_rec.LovCriteriaTbl;
   l_bind_index     := 1;

   IF l_criteria_tbl.count > 0 THEN
      i:=l_criteria_tbl.first;
      LOOP
         IF upper(l_criteria_tbl(i).AttributeName) = upper('Code') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND SOR.CURRENT_STATUS_CODE like :CODE ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         ELSIF upper(l_criteria_tbl(i).AttributeName) = upper('Meaning') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(FND.MEANING) like :MEAN ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

      EXIT WHEN i= l_criteria_tbl.last;
      i:= i+1;
      END LOOP;
   END IF;



   l_sql_string := l_sql_string || ' Order By meaning) ';   -- SET START/END Row

   l_sql_string := l_sql_string || ' WHERE rownum BETWEEN :START_ROW AND :END_ROW ';
   --start row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow+1;
   l_bind_index := l_bind_index + 1;
   --end row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows;
   l_bind_index := l_bind_index + 1;
   l_sql_string := l_sql_string || ' and rownum < :MAX_ROW ';
   --Max Row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows+1;
   l_bind_index := l_bind_index + 1;

   --open l_cur FOR l_sql_string;
   AHL_OSP_UTIL_PKG.OPEN_SEARCH_CURSOR
   (
       p_conditions_tbl => l_bindvar_tbl,
       p_sql_str        => l_sql_string,
       p_x_csr          => l_cur
   );

   i:=1;
   LOOP
     FETCH l_cur INTO     l_rownum,
                          l_mean,
                          l_code;

     EXIT WHEN l_cur%NOTFOUND;

     --
     l_attributes_tbl(1).AttributeName := 'Code';
     l_attributes_tbl(1).AttributeValue := l_code;

     --
     l_attributes_tbl(2).AttributeName := 'Meaning';
     l_attributes_tbl(2).AttributeValue := l_mean;

     l_results_tbl(i) := l_attributes_tbl;
     i:=i+1;

   END LOOP;
   CLOSE l_cur;
   -- Create Attributes Table

   -- Populate output parameter
   x_lov_result_output_rec.StartRow := p_lov_input_rec.StartRow;
   x_lov_result_output_rec.NumberOfRows := i-1;
   x_lov_result_output_rec.LovResultTbl := l_results_tbl;

END getWOStatusResults;

---------------------------------------------------------------------
---------------------------------------------------------------------
-- PROCEDURE
-- getHoldReasonMetaData
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getHoldReasonMetaData(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_meta_output_rec      OUT  NOCOPY LovMetaData_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

l_Meta_Attribute_Rec LovMetaAttribute_Rec_Type;
l_Meta_Attribute_Tbl LovMetaAttribute_Tbl_Type;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Create Attributes Table
   l_Meta_Attribute_Rec.AttributeName := 'Code';
   l_Meta_Attribute_Rec.Prompt := 'Code';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(0) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'Meaning';
   l_Meta_Attribute_Rec.Prompt := 'Name';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(1) := l_Meta_Attribute_Rec;

   -- Populate output parameter
   x_lov_meta_output_rec.LovTitle := 'Search Hold Reason Code';
   x_lov_meta_output_rec.LovMetaAttributeTbl := l_Meta_Attribute_Tbl;

END getHoldReasonMetaData;

---------------------------------------------------------------------
-- PROCEDURE
-- getHoldReasonResults
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getHoldReasonResults(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_result_output_rec    OUT NOCOPY LovOutput_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

-- Define local Variables
L_API_VERSION           CONSTANT NUMBER := 1.0;
L_API_NAME              CONSTANT VARCHAR2(30) := 'getHoldReasonResults';
L_FULL_NAME             CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

l_criteria_tbl LovCriteria_Tbl_Type;
l_results_tbl  LovResult_Tbl_Type;
l_attributes_tbl LovResultAttribute_Tbl_Type;

i    integer ;

-- Local Variables for the sql string.
l_sql_string     VARCHAR2(30000);
l_bind_index     NUMBER;
l_bindvar_tbl AHL_OSP_UTIL_PKG.ahl_conditions_tbl;
-- dynamic cursor
l_cur            AHL_OSP_UTIL_PKG.ahl_search_csr;

--Local Variables for search results
    l_code	          FND_LOOKUP_VALUES_VL.lookup_code%type;
    l_mean 	          FND_LOOKUP_VALUES_VL.meaning%type;
    l_rownum          NUMBER;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- SELECT CLAUSE AND BASIC WHERE CONDITIONS
   l_sql_string := 'SELECT rownum , meaning,lookup_code FROM ( select meaning , lookup_code  from ';
   l_sql_string := l_sql_string || ' FND_LOOKUP_VALUES_VL FND where lookup_type=''AHL_PRD_WO_HOLD_REASON'' ';
   --Get Dynamic Search Criteria
   l_criteria_tbl :=p_lov_input_rec.LovCriteriaTbl;
   l_bind_index     := 1;

   IF l_criteria_tbl.count > 0 THEN
      i:=l_criteria_tbl.first;
      LOOP
         IF upper(l_criteria_tbl(i).AttributeName) = upper('Code') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND FND.lookup_code like :CODE ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         ELSIF upper(l_criteria_tbl(i).AttributeName) = upper('Meaning') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(FND.MEANING) like :MEAN ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

      EXIT WHEN i= l_criteria_tbl.last;
      i:= i+1;
      END LOOP;
   END IF;



   l_sql_string := l_sql_string || ' Order By meaning) ';   -- SET START/END Row

   l_sql_string := l_sql_string || ' WHERE rownum BETWEEN :START_ROW AND :END_ROW ';
   --start row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow+1;
   l_bind_index := l_bind_index + 1;
   --end row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows;
   l_bind_index := l_bind_index + 1;
   l_sql_string := l_sql_string || ' and rownum < :MAX_ROW ';
   --Max Row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows+1;
   l_bind_index := l_bind_index + 1;

   --open l_cur FOR l_sql_string;
   AHL_OSP_UTIL_PKG.OPEN_SEARCH_CURSOR
   (
       p_conditions_tbl => l_bindvar_tbl,
       p_sql_str        => l_sql_string,
       p_x_csr          => l_cur
   );

   i:=1;
   LOOP
     FETCH l_cur INTO     l_rownum,
                          l_mean,
                          l_code;

     EXIT WHEN l_cur%NOTFOUND;

     --
     l_attributes_tbl(1).AttributeName := 'Code';
     l_attributes_tbl(1).AttributeValue := l_code;

     --
     l_attributes_tbl(2).AttributeName := 'Meaning';
     l_attributes_tbl(2).AttributeValue := l_mean;

     l_results_tbl(i) := l_attributes_tbl;
     i:=i+1;

   END LOOP;
   CLOSE l_cur;
   -- Create Attributes Table

   -- Populate output parameter
   x_lov_result_output_rec.StartRow := p_lov_input_rec.StartRow;
   x_lov_result_output_rec.NumberOfRows := i-1;
   x_lov_result_output_rec.LovResultTbl := l_results_tbl;

END getHoldReasonResults;

---------------------------------------------------------------------
-- PROCEDURE
-- getOperSeqMetaData
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getOperSeqMetaData(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_meta_output_rec      OUT NOCOPY LovMetaData_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

l_Meta_Attribute_Rec LovMetaAttribute_Rec_Type;
l_Meta_Attribute_Tbl LovMetaAttribute_Tbl_Type;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Create Attributes Table
   l_Meta_Attribute_Rec.AttributeName := 'WorkorderOperationId';
   l_Meta_Attribute_Rec.Prompt := null;
   l_Meta_Attribute_Rec.IsDisplayed := 'F';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'integer';

   l_Meta_Attribute_Tbl(0) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'OrganizationId';
   l_Meta_Attribute_Rec.Prompt := null;
   l_Meta_Attribute_Rec.IsDisplayed := 'F';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'integer';

   l_Meta_Attribute_Tbl(1) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'DepartmentId';
   l_Meta_Attribute_Rec.Prompt := null;
   l_Meta_Attribute_Rec.IsDisplayed := 'F';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'integer';

   l_Meta_Attribute_Tbl(2) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'OperationSequenceNum';
   l_Meta_Attribute_Rec.Prompt := 'Operation Sequence';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'integer';

   l_Meta_Attribute_Tbl(3) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'WorkorderId';
   l_Meta_Attribute_Rec.Prompt := null;
   l_Meta_Attribute_Rec.IsDisplayed := 'F';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'integer';

   l_Meta_Attribute_Tbl(4) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'Status';
   l_Meta_Attribute_Rec.Prompt := 'Status';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(5) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'Description';
   l_Meta_Attribute_Rec.Prompt := 'Description';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(6) := l_Meta_Attribute_Rec;

   -- Populate output parameter
   x_lov_meta_output_rec.LovTitle := 'Search Operation Status';
   x_lov_meta_output_rec.LovMetaAttributeTbl := l_Meta_Attribute_Tbl;

END getOperSeqMetaData;

---------------------------------------------------------------------
-- PROCEDURE
-- getOperSeqResults
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getOperSeqResults(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_result_output_rec    OUT NOCOPY LovOutput_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

-- Define local Variables
L_API_VERSION           CONSTANT NUMBER := 1.0;
L_API_NAME              CONSTANT VARCHAR2(30) := 'getOperSeqResults';
L_FULL_NAME             CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

l_criteria_tbl LovCriteria_Tbl_Type;
l_results_tbl  LovResult_Tbl_Type;
l_attributes_tbl LovResultAttribute_Tbl_Type;

i    integer ;

-- Local Variables for the sql string.
l_sql_string     VARCHAR2(30000);
l_bind_index     NUMBER;
l_bindvar_tbl AHL_OSP_UTIL_PKG.ahl_conditions_tbl;
-- dynamic cursor
l_cur            AHL_OSP_UTIL_PKG.ahl_search_csr;

--Local Variables for search results
l_rownum          NUMBER;
l_wo_oper_id      NUMBER;
l_org_id          NUMBER;
l_oper_seq        NUMBER;
l_wo_id           NUMBER;
l_status	      AHL_WORKORDER_OPERATIONS_V.STATUS%type;
l_desc 	          AHL_WORKORDER_OPERATIONS_V.DESCRIPTION%type;
l_dept_id         NUMBER;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- SELECT CLAUSE AND BASIC WHERE CONDITIONS
   l_sql_string := 'SELECT * FROM ( SELECT Rownum RN, WORKORDER_OPERATION_ID, ';
   l_sql_string := l_sql_string || ' ORGANIZATION_ID, OPERATION_SEQUENCE_NUM, ';
   l_sql_string := l_sql_string || ' WORKORDER_ID, STATUS, DESCRIPTION, DEPARTMENT_ID ';
   l_sql_string := l_sql_string || ' FROM  AHL_WORKORDER_OPERATIONS_V ';
   l_sql_string := l_sql_string || ' WHERE 0=0 ';

   --Get Dynamic Search Criteria
   l_criteria_tbl :=p_lov_input_rec.LovCriteriaTbl;
   l_bind_index     := 1;

   IF l_criteria_tbl.count > 0 THEN
      i:=l_criteria_tbl.first;
      LOOP
         IF upper(l_criteria_tbl(i).AttributeName) = upper('WorkorderOperationId') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND WORKORDER_OPERATION_ID like :WO_OPER_ID ';
              l_bindvar_tbl(l_bind_index) := l_criteria_tbl(i).AttributeValue;
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('OrganizationId') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND ORGANIZATION_ID like :ORG_ID ';
              l_bindvar_tbl(l_bind_index) := l_criteria_tbl(i).AttributeValue;
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('DepartmentId') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND DEPARTMENT_ID like :DEPT_ID ';
              l_bindvar_tbl(l_bind_index) := l_criteria_tbl(i).AttributeValue;
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('OperationSequenceNum') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND OPERATION_SEQUENCE_NUM like :OPER_SEQ ';
              l_bindvar_tbl(l_bind_index) := l_criteria_tbl(i).AttributeValue;
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('WorkorderId') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND WORKORDER_ID like :WO_ID ';
              l_bindvar_tbl(l_bind_index) := l_criteria_tbl(i).AttributeValue;
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('Status') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(STATUS) like :STATUS ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('Description') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(Description) like :DESC ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

      EXIT WHEN i= l_criteria_tbl.last;
      i:= i+1;
      END LOOP;
   END IF;

   -- SET START/END Row
   l_sql_string := l_sql_string || ' and rownum < :MAX_ROW ';
   --Max Row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows +1;
   l_bind_index := l_bind_index + 1;

   l_sql_string := l_sql_string || ' Order By WORKORDER_ID,OPERATION_SEQUENCE_NUM ) ';
   l_sql_string := l_sql_string || ' WHERE RN BETWEEN :START_ROW AND :END_ROW ';
   --start row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow +1;
   l_bind_index := l_bind_index + 1;
   --end row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows;
   l_bind_index := l_bind_index + 1;

   --open l_cur FOR l_sql_string;
   AHL_OSP_UTIL_PKG.OPEN_SEARCH_CURSOR
   (
       p_conditions_tbl => l_bindvar_tbl,
       p_sql_str        => l_sql_string,
       p_x_csr          => l_cur
   );

   i:=1;
   LOOP
     FETCH l_cur INTO     l_rownum,
                          l_wo_oper_id,
                          l_org_id,
                          l_oper_seq,
                          l_wo_id,
                          l_status,
                          l_desc,
                          l_dept_id;


     EXIT WHEN l_cur%NOTFOUND;

     --
     l_attributes_tbl(1).AttributeName := 'WorkorderOperationId';
     l_attributes_tbl(1).AttributeValue := l_wo_oper_id;

     --
     l_attributes_tbl(2).AttributeName := 'OrganizationId';
     l_attributes_tbl(2).AttributeValue := l_org_id;

     --
     l_attributes_tbl(3).AttributeName := 'DepartmentId';
     l_attributes_tbl(3).AttributeValue := l_dept_id;

     --
     l_attributes_tbl(4).AttributeName := 'OperationSequenceNum';
     l_attributes_tbl(4).AttributeValue := l_oper_seq;

     --
     l_attributes_tbl(5).AttributeName := 'WorkorderId';
     l_attributes_tbl(5).AttributeValue := l_wo_id;

     --
     l_attributes_tbl(6).AttributeName := 'Status';
     l_attributes_tbl(6).AttributeValue := l_status;

     --
     l_attributes_tbl(7).AttributeName := 'Description';
     l_attributes_tbl(7).AttributeValue := l_desc;

     l_results_tbl(i) := l_attributes_tbl;
     i:=i+1;

   END LOOP;
   CLOSE l_cur;
   -- Create Attributes Table

   -- Populate output parameter
   x_lov_result_output_rec.StartRow := p_lov_input_rec.StartRow;
   x_lov_result_output_rec.NumberOfRows := i-1;
   x_lov_result_output_rec.LovResultTbl := l_results_tbl;

END getOperSeqResults;

---------------------------------------------------------------------
-- PROCEDURE
-- getResCodeMetaData
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getResCodeMetaData(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_meta_output_rec      OUT NOCOPY LovMetaData_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

l_Meta_Attribute_Rec LovMetaAttribute_Rec_Type;
l_Meta_Attribute_Tbl LovMetaAttribute_Tbl_Type;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Create Attributes Table
   l_Meta_Attribute_Rec.AttributeName := 'ResCodeLovResCode';
   l_Meta_Attribute_Rec.Prompt := 'Resource';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(0) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'ResCodeLovDescription';
   l_Meta_Attribute_Rec.Prompt := 'Description';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(1) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'ResCodeLovUom';
   l_Meta_Attribute_Rec.Prompt := 'UOM';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(2) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'ResCodeLovResType';
   l_Meta_Attribute_Rec.Prompt := 'Resource Type';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(3) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'ResCodeLovResId';
   l_Meta_Attribute_Rec.Prompt := null;
   l_Meta_Attribute_Rec.IsDisplayed := 'F';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'integer';

   l_Meta_Attribute_Tbl(4) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'ResCodeLovDepartmentId';
   l_Meta_Attribute_Rec.Prompt := null;
   l_Meta_Attribute_Rec.IsDisplayed := 'F';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'integer';

   l_Meta_Attribute_Tbl(5) := l_Meta_Attribute_Rec;

   -- Populate output parameter
   x_lov_meta_output_rec.LovTitle := 'Search Resource';
   x_lov_meta_output_rec.LovMetaAttributeTbl := l_Meta_Attribute_Tbl;

END getResCodeMetaData;

---------------------------------------------------------------------
-- PROCEDURE
-- getResCodeResults
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getResCodeResults(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_result_output_rec    OUT NOCOPY LovOutput_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

-- Define local Variables
L_API_VERSION           CONSTANT NUMBER := 1.0;
L_API_NAME              CONSTANT VARCHAR2(30) := 'getResCodeResults';
L_FULL_NAME             CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

l_criteria_tbl LovCriteria_Tbl_Type;
l_results_tbl  LovResult_Tbl_Type;
l_attributes_tbl LovResultAttribute_Tbl_Type;

i    integer ;

-- Local Variables for the sql string.
l_sql_string     VARCHAR2(30000);
l_bind_index     NUMBER;
l_bindvar_tbl AHL_OSP_UTIL_PKG.ahl_conditions_tbl;
-- dynamic cursor
l_cur            AHL_OSP_UTIL_PKG.ahl_search_csr;

--Local Variables for search results
l_rownum          NUMBER;
l_res_id          NUMBER;
l_res_code        BOM_RESOURCES.RESOURCE_CODE%type;
l_desc 	          BOM_RESOURCES.DESCRIPTION%type;
l_res_type        MFG_LOOKUPS.MEANING%type;
l_UOM             mtl_units_of_measure.unit_of_measure%type;
l_dept_id         NUMBER;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- SELECT CLAUSE AND BASIC WHERE CONDITIONS
   l_sql_string := 'SELECT * FROM ( SELECT Rownum RN, ';
   l_sql_string := l_sql_string || ' BR.RESOURCE_ID ,BR.RESOURCE_CODE, BR.description , ';
   l_sql_string := l_sql_string || ' MFGL.MEANING RESOURCE_TYPE,UOM.unit_of_measure, BDR.DEPARTMENT_ID ';
   l_sql_string := l_sql_string || ' FROM  BOM_RESOURCES BR,BOM_DEPARTMENT_RESOURCES BDR, ';
   l_sql_string := l_sql_string || ' MFG_LOOKUPS MFGL, mtl_units_of_measure UOM ';
   l_sql_string := l_sql_string || ' WHERE UOM.uom_code(+) = BR.UNIT_OF_MEASURE ';
   l_sql_string := l_sql_string || ' AND BR.RESOURCE_ID = BDR.RESOURCE_ID ';
   l_sql_string := l_sql_string || ' AND MFGL.LOOKUP_TYPE(+) = ''BOM_RESOURCE_TYPE'' ';
   l_sql_string := l_sql_string || ' AND MFGL.LOOKUP_CODE(+) = BR.RESOURCE_TYPE ';

   --Get Dynamic Search Criteria
   l_criteria_tbl :=p_lov_input_rec.LovCriteriaTbl;
   l_bind_index     := 1;

   IF l_criteria_tbl.count > 0 THEN
      i:=l_criteria_tbl.first;
      LOOP

         IF upper(l_criteria_tbl(i).AttributeName) = upper('ResCodeLovResCode') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(BR.RESOURCE_CODE) like :RES_CODE ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('ResCodeLovDescription') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(BR.description) like :RES_DESC ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('ResCodeLovUom') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(UOM.unit_of_measure) like :UOM ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('ResCodeLovResType') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(MFGL.MEANING) like :RES_TYPE ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('ResCodeLovResId') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND BR.RESOURCE_ID like :RES_ID ';
              l_bindvar_tbl(l_bind_index) := l_criteria_tbl(i).AttributeValue;
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('ResCodeLovDepartmentId') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND BDR.DEPARTMENT_ID like :DEPT_ID ';
              l_bindvar_tbl(l_bind_index) := l_criteria_tbl(i).AttributeValue;
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

      EXIT WHEN i= l_criteria_tbl.last;
      i:= i+1;
      END LOOP;
   END IF;

   -- SET START/END Row
   l_sql_string := l_sql_string || ' and rownum < :MAX_ROW ';
   --Max Row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows+1;
   l_bind_index := l_bind_index + 1;

   l_sql_string := l_sql_string || ' Order By BDR.DEPARTMENT_ID,BR.RESOURCE_CODE ) ';
   l_sql_string := l_sql_string || ' WHERE RN BETWEEN :START_ROW AND :END_ROW ';
   --start row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow+1;
   l_bind_index := l_bind_index + 1;
   --end row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows;
   l_bind_index := l_bind_index + 1;

   --open l_cur FOR l_sql_string;
   AHL_OSP_UTIL_PKG.OPEN_SEARCH_CURSOR
   (
       p_conditions_tbl => l_bindvar_tbl,
       p_sql_str        => l_sql_string,
       p_x_csr          => l_cur
   );

   i:=1;
   LOOP
     FETCH l_cur INTO     l_rownum,
                          l_res_id,
                          l_res_code,
                          l_desc,
                          l_res_type,
                          l_UOM,
                          l_dept_id;


     EXIT WHEN l_cur%NOTFOUND;

     --
     l_attributes_tbl(1).AttributeName := 'ResCodeLovResCode';
     l_attributes_tbl(1).AttributeValue := l_res_code;

     --
     l_attributes_tbl(2).AttributeName := 'ResCodeLovDescription';
     l_attributes_tbl(2).AttributeValue := l_desc;

     --
     l_attributes_tbl(3).AttributeName := 'ResCodeLovUom';
     l_attributes_tbl(3).AttributeValue := l_UOM;

     --
     l_attributes_tbl(4).AttributeName := 'ResCodeLovResType';
     l_attributes_tbl(4).AttributeValue := l_res_type;

     --
     l_attributes_tbl(5).AttributeName := 'ResCodeLovResId';
     l_attributes_tbl(5).AttributeValue := l_res_id;

     --
     l_attributes_tbl(6).AttributeName := 'ResCodeLovDepartmentId';
     l_attributes_tbl(6).AttributeValue := l_dept_id;

     l_results_tbl(i) := l_attributes_tbl;
     i:=i+1;

   END LOOP;
   CLOSE l_cur;
   -- Create Attributes Table

   -- Populate output parameter
   x_lov_result_output_rec.StartRow := p_lov_input_rec.StartRow;
   x_lov_result_output_rec.NumberOfRows := i-1;
   x_lov_result_output_rec.LovResultTbl := l_results_tbl;

END getResCodeResults;

---------------------------------------------------------------------
-- PROCEDURE
-- getATACodeMetaData
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getATACodeMetaData(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_meta_output_rec      OUT NOCOPY LovMetaData_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

l_Meta_Attribute_Rec LovMetaAttribute_Rec_Type;
l_Meta_Attribute_Tbl LovMetaAttribute_Tbl_Type;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Create Attributes Table
   l_Meta_Attribute_Rec.AttributeName := 'ATACode';
   l_Meta_Attribute_Rec.Prompt := 'ATA Code';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(0) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := '   ';
   l_Meta_Attribute_Rec.Prompt := 'Description';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(1) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'Position';
   l_Meta_Attribute_Rec.Prompt := 'Position';
   l_Meta_Attribute_Rec.IsDisplayed := 'F';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(2) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'PositionID';
   l_Meta_Attribute_Rec.Prompt := null;
   l_Meta_Attribute_Rec.IsDisplayed := 'F';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'integer';

   l_Meta_Attribute_Tbl(3) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'UnitName';
   l_Meta_Attribute_Rec.Prompt := 'Unit';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(4) := l_Meta_Attribute_Rec;

   -- Populate output parameter
   x_lov_meta_output_rec.LovTitle := 'Search ATA Code';
   x_lov_meta_output_rec.LovMetaAttributeTbl := l_Meta_Attribute_Tbl;

END getATACodeMetaData;

---------------------------------------------------------------------
-- PROCEDURE
-- getATACodeResults
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getATACodeResults(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_result_output_rec    OUT NOCOPY LovOutput_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

-- Define local Variables
L_API_VERSION           CONSTANT NUMBER := 1.0;
L_API_NAME              CONSTANT VARCHAR2(30) := 'getATACodeResults';
L_FULL_NAME             CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

l_criteria_tbl LovCriteria_Tbl_Type;
l_results_tbl  LovResult_Tbl_Type;
l_attributes_tbl LovResultAttribute_Tbl_Type;

i    integer ;

-- Local Variables for the sql string.
l_sql_string     VARCHAR2(30000);
l_bind_index     NUMBER;
l_bindvar_tbl AHL_OSP_UTIL_PKG.ahl_conditions_tbl;
-- dynamic cursor
l_cur            AHL_OSP_UTIL_PKG.ahl_search_csr;

--Local Variables for search results
l_rownum          NUMBER;
l_ata   ahl_mc_relationships_v.ATA_MEANING%type;
l_ata_desc     ahl_mc_relationships_v.ATA_DESC%type;
l_position_id         NUMBER;
l_unit          ahl_unit_config_headers.name%type;
l_position      ahl_mc_relationships_v.position_ref_meaning%type;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- SELECT CLAUSE AND BASIC WHERE CONDITIONS
   l_sql_string := 'SELECT * FROM ( SELECT DISTINCT Rownum RN, ATA_meaning, ATA_Desc, position_ref_meaning, position_key,uc.name ';
   l_sql_string := l_sql_string || ' from ahl_mc_relationships_v mc, ahl_unit_config_headers uc ';
   l_sql_string := l_sql_string || ' where uc.MASTER_CONFIG_ID = mc.mc_header_id AND  ATA_meaning IS NOT NULL ';

   --Get Dynamic Search Criteria
   l_criteria_tbl :=p_lov_input_rec.LovCriteriaTbl;
   l_bind_index     := 1;

   IF l_criteria_tbl.count > 0 THEN
      i:=l_criteria_tbl.first;
      LOOP

         IF upper(l_criteria_tbl(i).AttributeName) = upper('ATACode') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(ATA_meaning) like :ATAC ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         ELSIF upper(l_criteria_tbl(i).AttributeName) = upper('Position') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(position_ref_meaning) like :POS ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         ELSIF upper(l_criteria_tbl(i).AttributeName) = upper('UnitName') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(uc.name) like :UNIT ';
              l_bindvar_tbl(l_bind_index) := l_criteria_tbl(i).AttributeValue;
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

      EXIT WHEN i= l_criteria_tbl.last;
      i:= i+1;
      END LOOP;
   END IF;

   -- SET START/END Row
   l_sql_string := l_sql_string || ' and rownum < :MAX_ROW ';
   --Max Row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows +1;
   l_bind_index := l_bind_index + 1;

   l_sql_string := l_sql_string || ' Order By ATA_meaning ) ';
   l_sql_string := l_sql_string || ' WHERE RN BETWEEN :START_ROW AND :END_ROW ';
   --start row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow +1;
   l_bind_index := l_bind_index + 1;
   --end row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows;
   l_bind_index := l_bind_index + 1;

   --open l_cur FOR l_sql_string;
   AHL_OSP_UTIL_PKG.OPEN_SEARCH_CURSOR
   (
       p_conditions_tbl => l_bindvar_tbl,
       p_sql_str        => l_sql_string,
       p_x_csr          => l_cur
   );

   i:=1;
   LOOP
     FETCH l_cur INTO     l_rownum,
                          l_ata,
                          l_ata_desc,
                          l_position,
                          l_position_id,
                          l_unit;




     EXIT WHEN l_cur%NOTFOUND;

     --
     l_attributes_tbl(1).AttributeName := 'ATACode';
     l_attributes_tbl(1).AttributeValue := l_ata;

     --
     l_attributes_tbl(2).AttributeName := 'Description';
     l_attributes_tbl(2).AttributeValue := l_ata_desc;

     --
     l_attributes_tbl(3).AttributeName := 'Position';
     l_attributes_tbl(3).AttributeValue := l_position;

     --
     l_attributes_tbl(4).AttributeName := 'PositionID';
     l_attributes_tbl(4).AttributeValue := l_position_id;

     l_attributes_tbl(5).AttributeName := 'UnitName';
     l_attributes_tbl(5).AttributeValue := l_unit;


     l_results_tbl(i) := l_attributes_tbl;
     i:=i+1;

   END LOOP;
   CLOSE l_cur;
   -- Create Attributes Table

   -- Populate output parameter
   x_lov_result_output_rec.StartRow := p_lov_input_rec.StartRow;
   x_lov_result_output_rec.NumberOfRows := i-1;
   x_lov_result_output_rec.LovResultTbl := l_results_tbl;

END getATACodeResults;

---------------------------------------------------------------------
-- PROCEDURE
-- getPositionMetaData
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getPositionMetaData(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_meta_output_rec      OUT NOCOPY LovMetaData_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

l_Meta_Attribute_Rec LovMetaAttribute_Rec_Type;
l_Meta_Attribute_Tbl LovMetaAttribute_Tbl_Type;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'Position';
   l_Meta_Attribute_Rec.Prompt := 'Position';
   l_Meta_Attribute_Rec.IsDisplayed := 'F';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(0) := l_Meta_Attribute_Rec;
   ----
   l_Meta_Attribute_Rec.AttributeName := 'Description';
   l_Meta_Attribute_Rec.Prompt := 'Description';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(1) := l_Meta_Attribute_Rec;

    -- Create Attributes Table
   l_Meta_Attribute_Rec.AttributeName := 'ATACode';
   l_Meta_Attribute_Rec.Prompt := 'ATA Code';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(2) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'PositionID';
   l_Meta_Attribute_Rec.Prompt := null;
   l_Meta_Attribute_Rec.IsDisplayed := 'F';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'integer';

   l_Meta_Attribute_Tbl(3) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'UnitName';
   l_Meta_Attribute_Rec.Prompt := 'Unit';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(4) := l_Meta_Attribute_Rec;

   -- Populate output parameter
   x_lov_meta_output_rec.LovTitle := 'Search Position';
   x_lov_meta_output_rec.LovMetaAttributeTbl := l_Meta_Attribute_Tbl;

END getPositionMetadata;

---------------------------------------------------------------------
-- PROCEDURE
-- getATACodeResults
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getPositionResults(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_result_output_rec    OUT NOCOPY LovOutput_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

-- Define local Variables
L_API_VERSION           CONSTANT NUMBER := 1.0;
L_API_NAME              CONSTANT VARCHAR2(30) := 'getPositionResults';
L_FULL_NAME             CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

l_criteria_tbl LovCriteria_Tbl_Type;
l_results_tbl  LovResult_Tbl_Type;
l_attributes_tbl LovResultAttribute_Tbl_Type;

i    integer ;

-- Local Variables for the sql string.
l_sql_string     VARCHAR2(30000);
l_bind_index     NUMBER;
l_bindvar_tbl AHL_OSP_UTIL_PKG.ahl_conditions_tbl;
-- dynamic cursor
l_cur            AHL_OSP_UTIL_PKG.ahl_search_csr;

--Local Variables for search results
l_rownum          NUMBER;
l_ata   ahl_mc_relationships_v.ATA_MEANING%type;
l_pos_desc     ahl_mc_relationships_v.position_ref_desc%type;
l_position_id         NUMBER;
l_unit          ahl_unit_config_headers.name%type;
l_position      ahl_mc_relationships_v.position_ref_meaning%type;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- SELECT CLAUSE AND BASIC WHERE CONDITIONS
   l_sql_string := 'SELECT * FROM ( SELECT DISTINCT Rownum RN, ATA_meaning, position_ref_desc, position_ref_meaning, position_key,uc.name ';
   l_sql_string := l_sql_string || ' from ahl_mc_relationships_v mc, ahl_unit_config_headers uc ';
   l_sql_string := l_sql_string || ' where uc.MASTER_CONFIG_ID = mc.mc_header_id ';

   --Get Dynamic Search Criteria
   l_criteria_tbl :=p_lov_input_rec.LovCriteriaTbl;
   l_bind_index     := 1;

   IF l_criteria_tbl.count > 0 THEN
      i:=l_criteria_tbl.first;
      LOOP

         IF upper(l_criteria_tbl(i).AttributeName) = upper('ATACode') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(ATA_meaning) like :ATAC ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         ELSIF upper(l_criteria_tbl(i).AttributeName) = upper('Position') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(position_ref_meaning) like :POS ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         ELSIF upper(l_criteria_tbl(i).AttributeName) = upper('UnitName') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(uc.name) like :UNIT ';
              l_bindvar_tbl(l_bind_index) := l_criteria_tbl(i).AttributeValue;
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

      EXIT WHEN i= l_criteria_tbl.last;
      i:= i+1;
      END LOOP;
   END IF;

   -- SET START/END Row
   l_sql_string := l_sql_string || ' and rownum < :MAX_ROW ';
   --Max Row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows +1;
   l_bind_index := l_bind_index + 1;

   l_sql_string := l_sql_string || ' Order By position_ref_meaning ) ';
   l_sql_string := l_sql_string || ' WHERE RN BETWEEN :START_ROW AND :END_ROW ';
   --start row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow +1;
   l_bind_index := l_bind_index + 1;
   --end row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows;
   l_bind_index := l_bind_index + 1;

   --open l_cur FOR l_sql_string;
   AHL_OSP_UTIL_PKG.OPEN_SEARCH_CURSOR
   (
       p_conditions_tbl => l_bindvar_tbl,
       p_sql_str        => l_sql_string,
       p_x_csr          => l_cur
   );

   i:=1;
   LOOP
     FETCH l_cur INTO     l_rownum,
                          l_ata,
                          l_pos_desc,
                          l_position,
                          l_position_id,
                          l_unit;




     EXIT WHEN l_cur%NOTFOUND;
     --
     l_attributes_tbl(1).AttributeName := 'Position';
     l_attributes_tbl(1).AttributeValue := l_position;
     --
     l_attributes_tbl(2).AttributeName := 'Description';
     l_attributes_tbl(2).AttributeValue := l_pos_desc;
     --
     l_attributes_tbl(3).AttributeName := 'ATACode';
     l_attributes_tbl(3).AttributeValue := l_ata;

     --
     l_attributes_tbl(4).AttributeName := 'PositionID';
     l_attributes_tbl(4).AttributeValue := l_position_id;

     l_attributes_tbl(5).AttributeName := 'UnitName';
     l_attributes_tbl(5).AttributeValue := l_unit;


     l_results_tbl(i) := l_attributes_tbl;
     i:=i+1;

   END LOOP;
   CLOSE l_cur;
   -- Create Attributes Table

   -- Populate output parameter
   x_lov_result_output_rec.StartRow := p_lov_input_rec.StartRow;
   x_lov_result_output_rec.NumberOfRows := i-1;
   x_lov_result_output_rec.LovResultTbl := l_results_tbl;

END getPositionResults;
---------------------------------------------------------------------
-- PROCEDURE
-- getSerialNumMetaData
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getSerialNumMetaData(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_meta_output_rec      OUT NOCOPY LovMetaData_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

l_Meta_Attribute_Rec LovMetaAttribute_Rec_Type;
l_Meta_Attribute_Tbl LovMetaAttribute_Tbl_Type;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Create Attributes Table
   l_Meta_Attribute_Rec.AttributeName := 'SerNumLovSerNum';
   l_Meta_Attribute_Rec.Prompt := 'Serial Number';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(0) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'SerNumLovInstId';
   l_Meta_Attribute_Rec.Prompt := null;
   l_Meta_Attribute_Rec.IsDisplayed := 'F';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'integer';

   l_Meta_Attribute_Tbl(1) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'SerNumLovDeptId';
   l_Meta_Attribute_Rec.Prompt := null;
   l_Meta_Attribute_Rec.IsDisplayed := 'F';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'integer';

   l_Meta_Attribute_Tbl(2) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'SerNumLovResId';
   l_Meta_Attribute_Rec.Prompt := null;
   l_Meta_Attribute_Rec.IsDisplayed := 'F';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'integer';

   l_Meta_Attribute_Tbl(3) := l_Meta_Attribute_Rec;

   -- Populate output parameter
   x_lov_meta_output_rec.LovTitle := 'Search Serial Number';
   x_lov_meta_output_rec.LovMetaAttributeTbl := l_Meta_Attribute_Tbl;

END getSerialNumMetaData;

---------------------------------------------------------------------
-- PROCEDURE
-- getSerialNumResults
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getSerialNumResults(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_result_output_rec    OUT NOCOPY LovOutput_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

-- Define local Variables
L_API_VERSION           CONSTANT NUMBER := 1.0;
L_API_NAME              CONSTANT VARCHAR2(30) := 'getSerialNumResults';
L_FULL_NAME             CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

l_criteria_tbl LovCriteria_Tbl_Type;
l_results_tbl  LovResult_Tbl_Type;
l_attributes_tbl LovResultAttribute_Tbl_Type;

i    integer ;

-- Local Variables for the sql string.
l_sql_string     VARCHAR2(30000);
l_bind_index     NUMBER;
l_bindvar_tbl AHL_OSP_UTIL_PKG.ahl_conditions_tbl;
-- dynamic cursor
l_cur            AHL_OSP_UTIL_PKG.ahl_search_csr;

--Local Variables for search results
l_rownum          NUMBER;
l_serial_num      bom_dept_res_instances.SERIAL_NUMBER%type;
l_instance_id     NUMBER;
l_dept_id         NUMBER;
l_res_id          NUMBER;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- SELECT CLAUSE AND BASIC WHERE CONDITIONS
   l_sql_string := 'SELECT * FROM ( SELECT DISTINCT Rownum RN, bdri.SERIAL_NUMBER,';
   l_sql_string := l_sql_string || ' bdri.instance_id, bdri.department_id, bdri.resource_id ';
   l_sql_string := l_sql_string || ' FROM  bom_dept_res_instances BDRI ';
   l_sql_string := l_sql_string || ' WHERE bdri.SERIAL_NUMBER is not null ';

   --Get Dynamic Search Criteria
   l_criteria_tbl :=p_lov_input_rec.LovCriteriaTbl;
   l_bind_index     := 1;

   IF l_criteria_tbl.count > 0 THEN
      i:=l_criteria_tbl.first;
      LOOP

         IF upper(l_criteria_tbl(i).AttributeName) = upper('SerNumLovSerNum') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(bdri.SERIAL_NUMBER) like :SN ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('SerNumLovInstId') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(bdri.instance_id) like :INS_ID ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('SerNumLovResId') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND bdri.resource_id like :RES_ID ';
              l_bindvar_tbl(l_bind_index) := l_criteria_tbl(i).AttributeValue;
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('SerNumLovDeptId') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND bdri.department_id like :DEPT_ID ';
              l_bindvar_tbl(l_bind_index) := l_criteria_tbl(i).AttributeValue;
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

      EXIT WHEN i= l_criteria_tbl.last;
      i:= i+1;
      END LOOP;
   END IF;

   -- SET START/END Row
   l_sql_string := l_sql_string || ' and rownum < :MAX_ROW ';
   --Max Row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows+1;
   l_bind_index := l_bind_index + 1;

   l_sql_string := l_sql_string || ' Order By bdri.department_id,bdri.resource_id,bdri.SERIAL_NUMBER ) ';
   l_sql_string := l_sql_string || ' WHERE RN BETWEEN :START_ROW AND :END_ROW ';
   --start row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow+1;
   l_bind_index := l_bind_index + 1;
   --end row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows;
   l_bind_index := l_bind_index + 1;

   --open l_cur FOR l_sql_string;
   AHL_OSP_UTIL_PKG.OPEN_SEARCH_CURSOR
   (
       p_conditions_tbl => l_bindvar_tbl,
       p_sql_str        => l_sql_string,
       p_x_csr          => l_cur
   );

   i:=1;
   LOOP
     FETCH l_cur INTO     l_rownum,
                          l_serial_num,
                          l_instance_id,
                          l_dept_id,
                          l_res_id;


     EXIT WHEN l_cur%NOTFOUND;

     --
     l_attributes_tbl(1).AttributeName := 'SerNumLovSerNum';
     l_attributes_tbl(1).AttributeValue := l_serial_num;

     --
     l_attributes_tbl(2).AttributeName := 'SerNumLovInstId';
     l_attributes_tbl(2).AttributeValue := l_instance_id;

     --
     l_attributes_tbl(3).AttributeName := 'SerNumLovDeptId';
     l_attributes_tbl(3).AttributeValue := l_dept_id;

     --
     l_attributes_tbl(4).AttributeName := 'SerNumLovResId';
     l_attributes_tbl(4).AttributeValue := l_res_id;


     l_results_tbl(i) := l_attributes_tbl;
     i:=i+1;

   END LOOP;
   CLOSE l_cur;
   -- Create Attributes Table

   -- Populate output parameter
   x_lov_result_output_rec.StartRow := p_lov_input_rec.StartRow;
   x_lov_result_output_rec.NumberOfRows := i-1;
   x_lov_result_output_rec.LovResultTbl := l_results_tbl;

END getSerialNumResults;

---------------------------------------------------------------------
-- PROCEDURE
-- getWOPositionMetaData
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getWOPositionMetaData(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_meta_output_rec      OUT NOCOPY LovMetaData_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

l_Meta_Attribute_Rec LovMetaAttribute_Rec_Type;
l_Meta_Attribute_Tbl LovMetaAttribute_Tbl_Type;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Create Attributes Table
   l_Meta_Attribute_Rec.AttributeName := 'SerNumLovSerNum';
   l_Meta_Attribute_Rec.Prompt := 'Serial Number';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(0) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'SerNumLovInstId';
   l_Meta_Attribute_Rec.Prompt := null;
   l_Meta_Attribute_Rec.IsDisplayed := 'F';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'integer';

   l_Meta_Attribute_Tbl(1) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'SerNumLovDeptId';
   l_Meta_Attribute_Rec.Prompt := null;
   l_Meta_Attribute_Rec.IsDisplayed := 'F';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'integer';

   l_Meta_Attribute_Tbl(2) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'SerNumLovResId';
   l_Meta_Attribute_Rec.Prompt := null;
   l_Meta_Attribute_Rec.IsDisplayed := 'F';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'integer';

   l_Meta_Attribute_Tbl(3) := l_Meta_Attribute_Rec;

   -- Populate output parameter
   x_lov_meta_output_rec.LovTitle := 'Search Serial Number';
   x_lov_meta_output_rec.LovMetaAttributeTbl := l_Meta_Attribute_Tbl;

END getWOPositionMetaData;

---------------------------------------------------------------------
-- PROCEDURE
-- getWOPositionResults
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getWOPositionResults(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_result_output_rec    OUT NOCOPY LovOutput_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

-- Define local Variables
L_API_VERSION           CONSTANT NUMBER := 1.0;
L_API_NAME              CONSTANT VARCHAR2(30) := 'getWOPositionResults';
L_FULL_NAME             CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

l_criteria_tbl LovCriteria_Tbl_Type;
l_results_tbl  LovResult_Tbl_Type;
l_attributes_tbl LovResultAttribute_Tbl_Type;

i    integer ;

-- Local Variables for the sql string.
l_sql_string     VARCHAR2(30000);
l_bind_index     NUMBER;
l_bindvar_tbl AHL_OSP_UTIL_PKG.ahl_conditions_tbl;
-- dynamic cursor
l_cur            AHL_OSP_UTIL_PKG.ahl_search_csr;

--Local Variables for search results
l_rownum          NUMBER;
l_serial_num      bom_dept_res_instances.SERIAL_NUMBER%type;
l_instance_id     NUMBER;
l_dept_id         NUMBER;
l_res_id          NUMBER;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- SELECT CLAUSE AND BASIC WHERE CONDITIONS
   l_sql_string := 'SELECT * FROM ( SELECT DISTINCT Rownum RN, bdri.SERIAL_NUMBER,';
   l_sql_string := l_sql_string || ' bdri.instance_id, bdri.department_id, bdri.resource_id ';
   l_sql_string := l_sql_string || ' FROM  bom_dept_res_instances BDRI ';
   l_sql_string := l_sql_string || ' WHERE bdri.SERIAL_NUMBER is not null ';

   --Get Dynamic Search Criteria
   l_criteria_tbl :=p_lov_input_rec.LovCriteriaTbl;
   l_bind_index     := 1;

   IF l_criteria_tbl.count > 0 THEN
      i:=l_criteria_tbl.first;
      LOOP

         IF upper(l_criteria_tbl(i).AttributeName) = upper('SerNumLovSerNum') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(bdri.SERIAL_NUMBER) like :SN ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('SerNumLovInstId') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND bdri.instance_id like :INS_ID ';
              l_bindvar_tbl(l_bind_index) := l_criteria_tbl(i).AttributeValue;
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('SerNumLovResId') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND bdri.resource_id like :RES_ID ';
              l_bindvar_tbl(l_bind_index) := l_criteria_tbl(i).AttributeValue;
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('SerNumLovDeptId') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND bdri.department_id like :DEPT_ID ';
              l_bindvar_tbl(l_bind_index) := l_criteria_tbl(i).AttributeValue;
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

      EXIT WHEN i= l_criteria_tbl.last;
      i:= i+1;
      END LOOP;
   END IF;

   -- SET START/END Row
   l_sql_string := l_sql_string || ' and rownum < :MAX_ROW ';
   --Max Row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows+1;
   l_bind_index := l_bind_index + 1;

   l_sql_string := l_sql_string || ' Order By bdri.department_id,bdri.resource_id,bdri.SERIAL_NUMBER ) ';
   l_sql_string := l_sql_string || ' WHERE RN BETWEEN :START_ROW AND :END_ROW ';
   --start row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow+1;
   l_bind_index := l_bind_index + 1;
   --end row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows;
   l_bind_index := l_bind_index + 1;

   --open l_cur FOR l_sql_string;
   AHL_OSP_UTIL_PKG.OPEN_SEARCH_CURSOR
   (
       p_conditions_tbl => l_bindvar_tbl,
       p_sql_str        => l_sql_string,
       p_x_csr          => l_cur
   );

   i:=1;
   LOOP
     FETCH l_cur INTO     l_rownum,
                          l_serial_num,
                          l_instance_id,
                          l_dept_id,
                          l_res_id;


     EXIT WHEN l_cur%NOTFOUND;

     --
     l_attributes_tbl(1).AttributeName := 'SerNumLovSerNum';
     l_attributes_tbl(1).AttributeValue := l_serial_num;

     --
     l_attributes_tbl(2).AttributeName := 'SerNumLovInstId';
     l_attributes_tbl(2).AttributeValue := l_instance_id;

     --
     l_attributes_tbl(3).AttributeName := 'SerNumLovDeptId';
     l_attributes_tbl(3).AttributeValue := l_dept_id;

     --
     l_attributes_tbl(4).AttributeName := 'SerNumLovResId';
     l_attributes_tbl(4).AttributeValue := l_res_id;


     l_results_tbl(i) := l_attributes_tbl;
     i:=i+1;

   END LOOP;
   CLOSE l_cur;
   -- Create Attributes Table

   -- Populate output parameter
   x_lov_result_output_rec.StartRow := p_lov_input_rec.StartRow;
   x_lov_result_output_rec.NumberOfRows := i-1;
   x_lov_result_output_rec.LovResultTbl := l_results_tbl;

END getWOPositionResults;

---------------------------------------------------------------------
-- PROCEDURE
-- getOnItemMetaData
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getOnItemMetaData(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_meta_output_rec      OUT NOCOPY LovMetaData_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

l_Meta_Attribute_Rec LovMetaAttribute_Rec_Type;
l_Meta_Attribute_Tbl LovMetaAttribute_Tbl_Type;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Create Attributes Table
   l_Meta_Attribute_Rec.AttributeName := 'ItemNum';
   l_Meta_Attribute_Rec.Prompt := 'Item';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(0) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'Description';
   l_Meta_Attribute_Rec.Prompt := 'Description';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(1) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'WorkOrderId';
   l_Meta_Attribute_Rec.Prompt := null;
   l_Meta_Attribute_Rec.IsDisplayed := 'F';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'integer';

   l_Meta_Attribute_Tbl(2) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'Position';
   l_Meta_Attribute_Rec.Prompt := null;
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'integer';

   l_Meta_Attribute_Tbl(3) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'PositionId';
   l_Meta_Attribute_Rec.Prompt := null;
   l_Meta_Attribute_Rec.IsDisplayed := 'F';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'integer';

   l_Meta_Attribute_Tbl(4) := l_Meta_Attribute_Rec;

   -- Populate output parameter
   x_lov_meta_output_rec.LovTitle := 'Search Item';
   x_lov_meta_output_rec.LovMetaAttributeTbl := l_Meta_Attribute_Tbl;

END getOnItemMetaData;

---------------------------------------------------------------------
-- PROCEDURE
-- getOnItemResults
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getOnItemResults(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_result_output_rec    OUT NOCOPY LovOutput_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

-- Define local Variables
L_API_VERSION           CONSTANT NUMBER := 1.0;
L_API_NAME              CONSTANT VARCHAR2(30) := 'getOnItemResults';
L_FULL_NAME             CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

l_criteria_tbl LovCriteria_Tbl_Type;
l_results_tbl  LovResult_Tbl_Type;
l_attributes_tbl LovResultAttribute_Tbl_Type;

i    integer ;

-- Local Variables for the sql string.
l_sql_string     VARCHAR2(30000);
l_bind_index     NUMBER;
l_bindvar_tbl AHL_OSP_UTIL_PKG.ahl_conditions_tbl;
-- dynamic cursor
l_cur            AHL_OSP_UTIL_PKG.ahl_search_csr;

--Local Variables for search results
l_rownum          NUMBER;
l_serial_num      bom_dept_res_instances.SERIAL_NUMBER%type;
l_instance_id     NUMBER;
l_dept_id         NUMBER;
l_res_id          NUMBER;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- SELECT CLAUSE AND BASIC WHERE CONDITIONS
   l_sql_string := 'SELECT * FROM ( SELECT DISTINCT Rownum RN, bdri.SERIAL_NUMBER,';
   l_sql_string := l_sql_string || ' bdri.instance_id, bdri.department_id, bdri.resource_id ';
   l_sql_string := l_sql_string || ' FROM  bom_dept_res_instances BDRI ';
   l_sql_string := l_sql_string || ' WHERE bdri.SERIAL_NUMBER is not null ';

   --Get Dynamic Search Criteria
   l_criteria_tbl :=p_lov_input_rec.LovCriteriaTbl;
   l_bind_index     := 1;

   IF l_criteria_tbl.count > 0 THEN
      i:=l_criteria_tbl.first;
      LOOP

         IF upper(l_criteria_tbl(i).AttributeName) = upper('SerNumLovSerNum') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(bdri.SERIAL_NUMBER) like :SN ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('SerNumLovInstId') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND bdri.instance_id like :INS_ID ';
              l_bindvar_tbl(l_bind_index) := l_criteria_tbl(i).AttributeValue;
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('SerNumLovResId') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND bdri.resource_id like :RES_ID ';
              l_bindvar_tbl(l_bind_index) := l_criteria_tbl(i).AttributeValue;
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('SerNumLovDeptId') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND bdri.department_id like :DEPT_ID ';
              l_bindvar_tbl(l_bind_index) := l_criteria_tbl(i).AttributeValue;
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

      EXIT WHEN i= l_criteria_tbl.last;
      i:= i+1;
      END LOOP;
   END IF;

   -- SET START/END Row
   l_sql_string := l_sql_string || ' and rownum < :MAX_ROW ';
   --Max Row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows +1;
   l_bind_index := l_bind_index + 1;

   l_sql_string := l_sql_string || ' Order By bdri.department_id,bdri.resource_id,bdri.SERIAL_NUMBER ) ';
   l_sql_string := l_sql_string || ' WHERE RN BETWEEN :START_ROW AND :END_ROW ';
   --start row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow +1;
   l_bind_index := l_bind_index + 1;
   --end row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows;
   l_bind_index := l_bind_index + 1;

   --open l_cur FOR l_sql_string;
   AHL_OSP_UTIL_PKG.OPEN_SEARCH_CURSOR
   (
       p_conditions_tbl => l_bindvar_tbl,
       p_sql_str        => l_sql_string,
       p_x_csr          => l_cur
   );

   i:=1;
   LOOP
     FETCH l_cur INTO     l_rownum,
                          l_serial_num,
                          l_instance_id,
                          l_dept_id,
                          l_res_id;


     EXIT WHEN l_cur%NOTFOUND;

     --
     l_attributes_tbl(1).AttributeName := 'SerNumLovSerNum';
     l_attributes_tbl(1).AttributeValue := l_serial_num;

     --
     l_attributes_tbl(2).AttributeName := 'SerNumLovInstId';
     l_attributes_tbl(2).AttributeValue := l_instance_id;

     --
     l_attributes_tbl(3).AttributeName := 'SerNumLovDeptId';
     l_attributes_tbl(3).AttributeValue := l_dept_id;

     --
     l_attributes_tbl(4).AttributeName := 'SerNumLovResId';
     l_attributes_tbl(4).AttributeValue := l_res_id;


     l_results_tbl(i) := l_attributes_tbl;
     i:=i+1;

   END LOOP;
   CLOSE l_cur;
   -- Create Attributes Table

   -- Populate output parameter
   x_lov_result_output_rec.StartRow := p_lov_input_rec.StartRow;
   x_lov_result_output_rec.NumberOfRows := i-1;
   x_lov_result_output_rec.LovResultTbl := l_results_tbl;

END getOnItemResults;

---------------------------------------------------------------------
-- PROCEDURE
-- getConditionMetaData
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getConditionMetaData(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_meta_output_rec      OUT NOCOPY LovMetaData_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

l_Meta_Attribute_Rec LovMetaAttribute_Rec_Type;
l_Meta_Attribute_Tbl LovMetaAttribute_Tbl_Type;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Create Attributes Table
   l_Meta_Attribute_Rec.AttributeName := 'Condition';
   l_Meta_Attribute_Rec.Prompt := 'Condition';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(0) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'Description';
   l_Meta_Attribute_Rec.Prompt := 'Description';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(1) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'ConditionId';
   l_Meta_Attribute_Rec.Prompt := null;
   l_Meta_Attribute_Rec.IsDisplayed := 'F';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'integer';

   l_Meta_Attribute_Tbl(2) := l_Meta_Attribute_Rec;

   -- Populate output parameter
   x_lov_meta_output_rec.LovTitle := 'Search Condition';
   x_lov_meta_output_rec.LovMetaAttributeTbl := l_Meta_Attribute_Tbl;

END getConditionMetaData;

---------------------------------------------------------------------
-- PROCEDURE
-- getConditionResults
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getConditionResults(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_result_output_rec    OUT NOCOPY LovOutput_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

-- Define local Variables
L_API_VERSION           CONSTANT NUMBER := 1.0;
L_API_NAME              CONSTANT VARCHAR2(30) := 'getConditionResults';
L_FULL_NAME             CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

l_criteria_tbl LovCriteria_Tbl_Type;
l_results_tbl  LovResult_Tbl_Type;
l_attributes_tbl LovResultAttribute_Tbl_Type;

i    integer ;

-- Local Variables for the sql string.
l_sql_string     VARCHAR2(30000);
l_bind_index     NUMBER;
l_bindvar_tbl AHL_OSP_UTIL_PKG.ahl_conditions_tbl;
-- dynamic cursor
l_cur            AHL_OSP_UTIL_PKG.ahl_search_csr;

--Local Variables for search results
l_rownum          NUMBER;
l_status_id       NUMBER;
l_status_code     mtl_material_statuses.status_code%type;
l_status_desc     mtl_material_statuses.description%type;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- SELECT CLAUSE AND BASIC WHERE CONDITIONS
   l_sql_string := 'SELECT * FROM ( SELECT Rownum RN,  status_id,';
   l_sql_string := l_sql_string || ' status_code, description ';
   l_sql_string := l_sql_string || ' FROM  mtl_material_statuses ';
   l_sql_string := l_sql_string || ' WHERE enabled_flag = 1 ';

   --Get Dynamic Search Criteria
   l_criteria_tbl :=p_lov_input_rec.LovCriteriaTbl;
   l_bind_index     := 1;

   IF l_criteria_tbl.count > 0 THEN
      i:=l_criteria_tbl.first;
      LOOP

         IF upper(l_criteria_tbl(i).AttributeName) = upper('Condition') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(status_code) like :CODE ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('Description') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(description) like :DESC ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('ConditionId') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND status_id like :ID ';
              l_bindvar_tbl(l_bind_index) := l_criteria_tbl(i).AttributeValue;
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

      EXIT WHEN i= l_criteria_tbl.last;
      i:= i+1;
      END LOOP;
   END IF;

   -- SET START/END Row
   l_sql_string := l_sql_string || ' and rownum < :MAX_ROW ';
   --Max Row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows +1;
   l_bind_index := l_bind_index + 1;

   l_sql_string := l_sql_string || ' Order By status_code ) ';
   l_sql_string := l_sql_string || ' WHERE RN BETWEEN :START_ROW AND :END_ROW ';
   --start row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow +1;
   l_bind_index := l_bind_index + 1;
   --end row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows;
   l_bind_index := l_bind_index + 1;

   --open l_cur FOR l_sql_string;
   AHL_OSP_UTIL_PKG.OPEN_SEARCH_CURSOR
   (
       p_conditions_tbl => l_bindvar_tbl,
       p_sql_str        => l_sql_string,
       p_x_csr          => l_cur
   );

   i:=1;
   LOOP
     FETCH l_cur INTO     l_rownum,
                          l_status_id,
                          l_status_code,
                          l_status_desc;


     EXIT WHEN l_cur%NOTFOUND;

     --
     l_attributes_tbl(1).AttributeName := 'Condition';
     l_attributes_tbl(1).AttributeValue := l_status_code;

     --
     l_attributes_tbl(2).AttributeName := 'Description';
     l_attributes_tbl(2).AttributeValue := l_status_desc;

     --
     l_attributes_tbl(3).AttributeName := 'ConditionId';
     l_attributes_tbl(3).AttributeValue := l_status_id;


     l_results_tbl(i) := l_attributes_tbl;
     i:=i+1;

   END LOOP;
   CLOSE l_cur;
   -- Create Attributes Table

   -- Populate output parameter
   x_lov_result_output_rec.StartRow := p_lov_input_rec.StartRow;
   x_lov_result_output_rec.NumberOfRows := i-1;
   x_lov_result_output_rec.LovResultTbl := l_results_tbl;

END getConditionResults;

---------------------------------------------------------------------
-- PROCEDURE
-- getRemReasonMetaData
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getRemReasonMetaData(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_meta_output_rec      OUT NOCOPY LovMetaData_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

l_Meta_Attribute_Rec LovMetaAttribute_Rec_Type;
l_Meta_Attribute_Tbl LovMetaAttribute_Tbl_Type;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Create Attributes Table
   l_Meta_Attribute_Rec.AttributeName := 'RemovalLovReason';
   l_Meta_Attribute_Rec.Prompt := 'Removal Reason';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(0) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'RemovalLovDescription';
   l_Meta_Attribute_Rec.Prompt := 'Description';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(1) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'RemovalLovReasonId';
   l_Meta_Attribute_Rec.Prompt := null;
   l_Meta_Attribute_Rec.IsDisplayed := 'F';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'integer';

   l_Meta_Attribute_Tbl(2) := l_Meta_Attribute_Rec;

   -- Populate output parameter
   x_lov_meta_output_rec.LovTitle := 'Search Removal Reason';
   x_lov_meta_output_rec.LovMetaAttributeTbl := l_Meta_Attribute_Tbl;

END getRemReasonMetaData;

---------------------------------------------------------------------
-- PROCEDURE
-- getRemReasonResults
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getRemReasonResults(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_result_output_rec    OUT NOCOPY LovOutput_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

-- Define local Variables
L_API_VERSION           CONSTANT NUMBER := 1.0;
L_API_NAME              CONSTANT VARCHAR2(30) := 'getRemReasonResults';
L_FULL_NAME             CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

l_criteria_tbl LovCriteria_Tbl_Type;
l_results_tbl  LovResult_Tbl_Type;
l_attributes_tbl LovResultAttribute_Tbl_Type;

i    integer ;

-- Local Variables for the sql string.
l_sql_string     VARCHAR2(30000);
l_bind_index     NUMBER;
l_bindvar_tbl AHL_OSP_UTIL_PKG.ahl_conditions_tbl;
-- dynamic cursor
l_cur            AHL_OSP_UTIL_PKG.ahl_search_csr;

--Local Variables for search results
l_rownum          NUMBER;
l_reason_name     mtl_transaction_reasons.reason_name%type;
l_reason_id       NUMBER;
l_reason_desc     mtl_transaction_reasons.description%type;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- SELECT CLAUSE AND BASIC WHERE CONDITIONS
   l_sql_string := 'SELECT * FROM ( SELECT Rownum RN,  reason_name,';
   l_sql_string := l_sql_string || ' reason_id, description ';
   l_sql_string := l_sql_string || ' FROM  mtl_transaction_reasons ';
   l_sql_string := l_sql_string || ' WHERE nvl(disable_date,sysdate) >= sysdate ';

   --Get Dynamic Search Criteria
   l_criteria_tbl :=p_lov_input_rec.LovCriteriaTbl;
   l_bind_index     := 1;

   IF l_criteria_tbl.count > 0 THEN
      i:=l_criteria_tbl.first;
      LOOP

         IF upper(l_criteria_tbl(i).AttributeName) = upper('RemovalLovReason') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(reason_name) like :NAME ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('RemovalLovDescription') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(description) like :DESC ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('RemovalLovReasonId') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND reason_id like :ID ';
              l_bindvar_tbl(l_bind_index) := l_criteria_tbl(i).AttributeValue;
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

      EXIT WHEN i= l_criteria_tbl.last;
      i:= i+1;
      END LOOP;
   END IF;

   -- SET START/END Row
   l_sql_string := l_sql_string || ' and rownum < :MAX_ROW ';
   --Max Row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows+1;
   l_bind_index := l_bind_index + 1;

   l_sql_string := l_sql_string || ' Order By reason_name ) ';
   l_sql_string := l_sql_string || ' WHERE RN BETWEEN :START_ROW AND :END_ROW ';
   --start row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow+1;
   l_bind_index := l_bind_index + 1;
   --end row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows;
   l_bind_index := l_bind_index + 1;

   --open l_cur FOR l_sql_string;
   AHL_OSP_UTIL_PKG.OPEN_SEARCH_CURSOR
   (
       p_conditions_tbl => l_bindvar_tbl,
       p_sql_str        => l_sql_string,
       p_x_csr          => l_cur
   );

   i:=1;
   LOOP
     FETCH l_cur INTO     l_rownum,
                          l_reason_name,
                          l_reason_id,
                          l_reason_desc;


     EXIT WHEN l_cur%NOTFOUND;

     --
     l_attributes_tbl(1).AttributeName := 'RemovalLovReason';
     l_attributes_tbl(1).AttributeValue := l_reason_name;

     --
     l_attributes_tbl(2).AttributeName := 'RemovalLovDescription';
     l_attributes_tbl(2).AttributeValue := l_reason_desc;

     --
     l_attributes_tbl(3).AttributeName := 'RemovalLovReasonId';
     l_attributes_tbl(3).AttributeValue := l_reason_id;


     l_results_tbl(i) := l_attributes_tbl;
     i:=i+1;

   END LOOP;
   CLOSE l_cur;
   -- Create Attributes Table

   -- Populate output parameter
   x_lov_result_output_rec.StartRow := p_lov_input_rec.StartRow;
   x_lov_result_output_rec.NumberOfRows := i-1;
   x_lov_result_output_rec.LovResultTbl := l_results_tbl;

END getRemReasonResults;

---------------------------------------------------------------------
-- PROCEDURE
-- getRemCodeMetaData
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getRemCodeMetaData(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_meta_output_rec      OUT NOCOPY LovMetaData_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

l_Meta_Attribute_Rec LovMetaAttribute_Rec_Type;
l_Meta_Attribute_Tbl LovMetaAttribute_Tbl_Type;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Create Attributes Table
   l_Meta_Attribute_Rec.AttributeName := 'RemovalLovCode';
   l_Meta_Attribute_Rec.Prompt := 'Removal Code';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(0) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'RemovalLovMeaning';
   l_Meta_Attribute_Rec.Prompt := 'Meaning';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(1) := l_Meta_Attribute_Rec;

   -- Populate output parameter
   x_lov_meta_output_rec.LovTitle := 'Search Removal Code';
   x_lov_meta_output_rec.LovMetaAttributeTbl := l_Meta_Attribute_Tbl;

END getRemCodeMetaData;

---------------------------------------------------------------------
-- PROCEDURE
-- getRemCodeResults
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getRemCodeResults(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_result_output_rec    OUT NOCOPY LovOutput_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

-- Define local Variables
L_API_VERSION           CONSTANT NUMBER := 1.0;
L_API_NAME              CONSTANT VARCHAR2(30) := 'getRemCodeResults';
L_FULL_NAME             CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

l_criteria_tbl LovCriteria_Tbl_Type;
l_results_tbl  LovResult_Tbl_Type;
l_attributes_tbl LovResultAttribute_Tbl_Type;

i    integer ;

-- Local Variables for the sql string.
l_sql_string     VARCHAR2(30000);
l_bind_index     NUMBER;
l_bindvar_tbl AHL_OSP_UTIL_PKG.ahl_conditions_tbl;
-- dynamic cursor
l_cur            AHL_OSP_UTIL_PKG.ahl_search_csr;

--Local Variables for search results
l_rownum          NUMBER;
l_code            FND_LOOKUP_VALUES_VL.lookup_code%type;
l_mean            FND_LOOKUP_VALUES_VL.meaning%type;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- SELECT CLAUSE AND BASIC WHERE CONDITIONS
   l_sql_string := 'SELECT * FROM ( SELECT Rownum RN,  meaning,';
   l_sql_string := l_sql_string || ' lookup_code ';
   l_sql_string := l_sql_string || ' FROM  FND_LOOKUP_VALUES_VL ';
   l_sql_string := l_sql_string || ' WHERE lookup_type=''AHL_REMOVAL_CODE'' ';
   l_sql_string := l_sql_string || ' and sysdate between nvl(start_date_active,sysdate) and nvl(end_date_active,sysdate)  ';

   --Get Dynamic Search Criteria
   l_criteria_tbl :=p_lov_input_rec.LovCriteriaTbl;
   l_bind_index     := 1;

   IF l_criteria_tbl.count > 0 THEN
      i:=l_criteria_tbl.first;
      LOOP

         IF upper(l_criteria_tbl(i).AttributeName) = upper('RemovalLovCode') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(lookup_code) like :CODE ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('RemovalLovMeaning') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(meaning) like :MEAN ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

      EXIT WHEN i= l_criteria_tbl.last;
      i:= i+1;
      END LOOP;
   END IF;

   -- SET START/END Row
   l_sql_string := l_sql_string || ' and rownum < :MAX_ROW ';
   --Max Row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows+1;
   l_bind_index := l_bind_index + 1;

   l_sql_string := l_sql_string || ' Order By meaning ) ';
   l_sql_string := l_sql_string || ' WHERE RN BETWEEN :START_ROW AND :END_ROW ';
   --start row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow+1;
   l_bind_index := l_bind_index + 1;
   --end row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows;
   l_bind_index := l_bind_index + 1;

   --open l_cur FOR l_sql_string;
   AHL_OSP_UTIL_PKG.OPEN_SEARCH_CURSOR
   (
       p_conditions_tbl => l_bindvar_tbl,
       p_sql_str        => l_sql_string,
       p_x_csr          => l_cur
   );

   i:=1;
   LOOP
     FETCH l_cur INTO     l_rownum,
                          l_mean,
                          l_code;


     EXIT WHEN l_cur%NOTFOUND;

     --
     l_attributes_tbl(1).AttributeName := 'RemovalLovCode';
     l_attributes_tbl(1).AttributeValue := l_code;

     --
     l_attributes_tbl(2).AttributeName := 'RemovalLovMeaning';
     l_attributes_tbl(2).AttributeValue := l_mean;

     l_results_tbl(i) := l_attributes_tbl;
     i:=i+1;

   END LOOP;
   CLOSE l_cur;
   -- Create Attributes Table

   -- Populate output parameter
   x_lov_result_output_rec.StartRow := p_lov_input_rec.StartRow;
   x_lov_result_output_rec.NumberOfRows := i-1;
   x_lov_result_output_rec.LovResultTbl := l_results_tbl;

END getRemCodeResults;

---------------------------------------------------------------------
-- PROCEDURE
-- getResolutionMetaData
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getResolutionMetaData(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_meta_output_rec      OUT NOCOPY LovMetaData_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

l_Meta_Attribute_Rec LovMetaAttribute_Rec_Type;
l_Meta_Attribute_Tbl LovMetaAttribute_Tbl_Type;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Create Attributes Table
   l_Meta_Attribute_Rec.AttributeName := 'ResolutionLovCode';
   l_Meta_Attribute_Rec.Prompt := 'Resolution Code';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(0) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'ResolutionLovMeaning';
   l_Meta_Attribute_Rec.Prompt := 'Name';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(1) := l_Meta_Attribute_Rec;

   -- Populate output parameter
   x_lov_meta_output_rec.LovTitle := 'Search Resolution Code';
   x_lov_meta_output_rec.LovMetaAttributeTbl := l_Meta_Attribute_Tbl;

END getResolutionMetaData;

---------------------------------------------------------------------
-- PROCEDURE
-- getResolutionResults
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getResolutionResults(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_result_output_rec    OUT NOCOPY LovOutput_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

-- Define local Variables
L_API_VERSION           CONSTANT NUMBER := 1.0;
L_API_NAME              CONSTANT VARCHAR2(30) := 'getResolutionResults';
L_FULL_NAME             CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

l_criteria_tbl LovCriteria_Tbl_Type;
l_results_tbl  LovResult_Tbl_Type;
l_attributes_tbl LovResultAttribute_Tbl_Type;

i    integer ;

-- Local Variables for the sql string.
l_sql_string     VARCHAR2(30000);
l_bind_index     NUMBER;
l_bindvar_tbl AHL_OSP_UTIL_PKG.ahl_conditions_tbl;
-- dynamic cursor
l_cur            AHL_OSP_UTIL_PKG.ahl_search_csr;

--Local Variables for search results
l_rownum          NUMBER;
l_code            FND_LOOKUP_VALUES_VL.lookup_code%type;
l_mean            FND_LOOKUP_VALUES_VL.meaning%type;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- SELECT CLAUSE AND BASIC WHERE CONDITIONS
   l_sql_string := 'SELECT * FROM ( SELECT Rownum RN,  meaning,';
   l_sql_string := l_sql_string || ' lookup_code ';
   l_sql_string := l_sql_string || ' FROM  FND_LOOKUP_VALUES_VL ';
   l_sql_string := l_sql_string || ' WHERE lookup_type=''REQUEST_RESOLUTION_CODE'' ';
   l_sql_string := l_sql_string || ' and sysdate between nvl(start_date_active,sysdate) and nvl(end_date_active,sysdate)  ';

   --Get Dynamic Search Criteria
   l_criteria_tbl :=p_lov_input_rec.LovCriteriaTbl;
   l_bind_index     := 1;

   IF l_criteria_tbl.count > 0 THEN
      i:=l_criteria_tbl.first;
      LOOP

         IF upper(l_criteria_tbl(i).AttributeName) = upper('ResolutionLovCode') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(lookup_code) like :CODE ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('ResolutionLovMeaning') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(meaning) like :MEAN ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

      EXIT WHEN i= l_criteria_tbl.last;
      i:= i+1;
      END LOOP;
   END IF;

   -- SET START/END Row
   l_sql_string := l_sql_string || ' and rownum < :MAX_ROW ';
   --Max Row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows+1;
   l_bind_index := l_bind_index + 1;

   l_sql_string := l_sql_string || ' Order By meaning ) ';
   l_sql_string := l_sql_string || ' WHERE RN BETWEEN :START_ROW AND :END_ROW ';
   --start row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow+1;
   l_bind_index := l_bind_index + 1;
   --end row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows;
   l_bind_index := l_bind_index + 1;

   --open l_cur FOR l_sql_string;
   AHL_OSP_UTIL_PKG.OPEN_SEARCH_CURSOR
   (
       p_conditions_tbl => l_bindvar_tbl,
       p_sql_str        => l_sql_string,
       p_x_csr          => l_cur
   );

   i:=1;
   LOOP
     FETCH l_cur INTO     l_rownum,
                          l_mean,
                          l_code;


     EXIT WHEN l_cur%NOTFOUND;

     --
     l_attributes_tbl(1).AttributeName := 'ResolutionLovCode';
     l_attributes_tbl(1).AttributeValue := l_code;

     --
     l_attributes_tbl(2).AttributeName := 'ResolutionLovMeaning';
     l_attributes_tbl(2).AttributeValue := l_mean;

     l_results_tbl(i) := l_attributes_tbl;
     i:=i+1;

   END LOOP;
   CLOSE l_cur;
   -- Create Attributes Table

   -- Populate output parameter
   x_lov_result_output_rec.StartRow := p_lov_input_rec.StartRow;
   x_lov_result_output_rec.NumberOfRows := i-1;
   x_lov_result_output_rec.LovResultTbl := l_results_tbl;

END getResolutionResults;

---------------------------------------------------------------------
-- PROCEDURE
-- getProblemMetaData
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getProblemMetaData(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_meta_output_rec      OUT NOCOPY LovMetaData_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

l_Meta_Attribute_Rec LovMetaAttribute_Rec_Type;
l_Meta_Attribute_Tbl LovMetaAttribute_Tbl_Type;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Create Attributes Table
   l_Meta_Attribute_Rec.AttributeName := 'ProblemLovCode';
   l_Meta_Attribute_Rec.Prompt := 'Problem Code';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(0) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'ProblemLovMeaning';
   l_Meta_Attribute_Rec.Prompt := 'Meaning';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(1) := l_Meta_Attribute_Rec;

   -- Populate output parameter
   x_lov_meta_output_rec.LovTitle := 'Search Problem Code';
   x_lov_meta_output_rec.LovMetaAttributeTbl := l_Meta_Attribute_Tbl;

END getProblemMetaData;

---------------------------------------------------------------------
-- PROCEDURE
-- getProblemResults
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getProblemResults(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_result_output_rec    OUT NOCOPY LovOutput_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

-- Define local Variables
L_API_VERSION           CONSTANT NUMBER := 1.0;
L_API_NAME              CONSTANT VARCHAR2(30) := 'getProblemResults';
L_FULL_NAME             CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

l_criteria_tbl LovCriteria_Tbl_Type;
l_results_tbl  LovResult_Tbl_Type;
l_attributes_tbl LovResultAttribute_Tbl_Type;

i    integer ;

-- Local Variables for the sql string.
l_sql_string     VARCHAR2(30000);
l_bind_index     NUMBER;
l_bindvar_tbl AHL_OSP_UTIL_PKG.ahl_conditions_tbl;
-- dynamic cursor
l_cur            AHL_OSP_UTIL_PKG.ahl_search_csr;

--Local Variables for search results
l_rownum          NUMBER;
l_code            FND_LOOKUP_VALUES_VL.lookup_code%type;
l_mean            FND_LOOKUP_VALUES_VL.meaning%type;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- SELECT CLAUSE AND BASIC WHERE CONDITIONS
   l_sql_string := 'SELECT * FROM ( SELECT Rownum RN,  description,';
   l_sql_string := l_sql_string || ' lookup_code ';
   l_sql_string := l_sql_string || ' FROM  FND_LOOKUP_VALUES_VL fl ';
   l_sql_string := l_sql_string || ' WHERE lookup_type=''REQUEST_PROBLEM_CODE'' ';
   l_sql_string := l_sql_string || ' and sysdate between nvl(start_date_active,sysdate) and nvl(end_date_active,sysdate)  ';
   l_sql_string := l_sql_string || ' and enabled_flag = ''Y''   ';
   l_sql_string := l_sql_string || ' and ((NOT EXISTS (SELECT 1 FROM CS_SR_PROB_CODE_MAPPING_V WHERE INCIDENT_TYPE_ID = FND_PROFILE.Value(''AHL_PRD_SR_TYPE'') ';
   l_sql_string := l_sql_string || ' AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(START_DATE_ACTIVE,SYSDATE)) AND TRUNC(NVL(END_DATE_ACTIVE,SYSDATE)))) ';
   l_sql_string := l_sql_string || ' OR (EXISTS (SELECT 1 FROM CS_SR_PROB_CODE_MAPPING_V MAP WHERE MAP.INCIDENT_TYPE_ID = FND_PROFILE.Value(''AHL_PRD_SR_TYPE'') ';
   l_sql_string := l_sql_string || ' AND MAP.INVENTORY_ITEM_ID IS NULL AND MAP.PROBLEM_CODE = FL.LOOKUP_CODE AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(MAP.START_DATE_ACTIVE,SYSDATE)) AND TRUNC(NVL(MAP.END_DATE_ACTIVE,SYSDATE)))))  ';

   --Get Dynamic Search Criteria
   l_criteria_tbl :=p_lov_input_rec.LovCriteriaTbl;
   l_bind_index     := 1;

   IF l_criteria_tbl.count > 0 THEN
      i:=l_criteria_tbl.first;
      LOOP

         IF upper(l_criteria_tbl(i).AttributeName) = upper('ProblemLovCode') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(lookup_code) like :CODE ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('ProblemLovMeaning') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(description) like :MEAN ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

      EXIT WHEN i= l_criteria_tbl.last;
      i:= i+1;
      END LOOP;
   END IF;

   -- SET START/END Row
   l_sql_string := l_sql_string || ' and rownum < :MAX_ROW ';
   --Max Row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows +1;
   l_bind_index := l_bind_index + 1;

   l_sql_string := l_sql_string || ' Order By meaning ) ';
   l_sql_string := l_sql_string || ' WHERE RN BETWEEN :START_ROW AND :END_ROW ';
   --start row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow+1;
   l_bind_index := l_bind_index + 1;
   --end row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows;
   l_bind_index := l_bind_index + 1;

   --open l_cur FOR l_sql_string;
   AHL_OSP_UTIL_PKG.OPEN_SEARCH_CURSOR
   (
       p_conditions_tbl => l_bindvar_tbl,
       p_sql_str        => l_sql_string,
       p_x_csr          => l_cur
   );

   i:=1;
   LOOP
     FETCH l_cur INTO     l_rownum,
                          l_mean,
                          l_code;


     EXIT WHEN l_cur%NOTFOUND;

     --
     l_attributes_tbl(1).AttributeName := 'ProblemLovCode';
     l_attributes_tbl(1).AttributeValue := l_code;

     --
     l_attributes_tbl(2).AttributeName := 'ProblemLovMeaning';
     l_attributes_tbl(2).AttributeValue := l_mean;

     l_results_tbl(i) := l_attributes_tbl;
     i:=i+1;

   END LOOP;
   CLOSE l_cur;
   -- Create Attributes Table

   -- Populate output parameter
   x_lov_result_output_rec.StartRow := p_lov_input_rec.StartRow;
   x_lov_result_output_rec.NumberOfRows := i-1;
   x_lov_result_output_rec.LovResultTbl := l_results_tbl;

END getProblemResults;

---------------------------------------------------------------------
-- PROCEDURE
-- getSeverityMetaData
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getSeverityMetaData(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_meta_output_rec      OUT NOCOPY LovMetaData_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

l_Meta_Attribute_Rec LovMetaAttribute_Rec_Type;
l_Meta_Attribute_Tbl LovMetaAttribute_Tbl_Type;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Create Attributes Table
   l_Meta_Attribute_Rec.AttributeName := 'SeverityLovName';
   l_Meta_Attribute_Rec.Prompt := 'Severity';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(0) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'SeverityLovDescription';
   l_Meta_Attribute_Rec.Prompt := 'Description';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(1) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'SeverityLovSeverityId';
   l_Meta_Attribute_Rec.Prompt := null;
   l_Meta_Attribute_Rec.IsDisplayed := 'F';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'integer';

   l_Meta_Attribute_Tbl(2) := l_Meta_Attribute_Rec;

   -- Populate output parameter
   x_lov_meta_output_rec.LovTitle := 'Search Severity';
   x_lov_meta_output_rec.LovMetaAttributeTbl := l_Meta_Attribute_Tbl;

END getSeverityMetaData;

---------------------------------------------------------------------
-- PROCEDURE
-- getSeverityResults
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getSeverityResults(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_result_output_rec    OUT NOCOPY LovOutput_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

-- Define local Variables
L_API_VERSION           CONSTANT NUMBER := 1.0;
L_API_NAME              CONSTANT VARCHAR2(30) := 'getSeverityResults';
L_FULL_NAME             CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

l_criteria_tbl LovCriteria_Tbl_Type;
l_results_tbl  LovResult_Tbl_Type;
l_attributes_tbl LovResultAttribute_Tbl_Type;

i    integer ;

-- Local Variables for the sql string.
l_sql_string     VARCHAR2(30000);
l_bind_index     NUMBER;
l_bindvar_tbl AHL_OSP_UTIL_PKG.ahl_conditions_tbl;
-- dynamic cursor
l_cur            AHL_OSP_UTIL_PKG.ahl_search_csr;

--Local Variables for search results
l_rownum          NUMBER;
l_name            cs_incident_severities_vl.name%type;
l_id              NUMBER;
l_desc            cs_incident_severities_vl.description%type;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- SELECT CLAUSE AND BASIC WHERE CONDITIONS
   l_sql_string := 'SELECT * FROM ( SELECT Rownum RN,  name,';
   l_sql_string := l_sql_string || ' incident_severity_id, description ';
   l_sql_string := l_sql_string || ' FROM  cs_incident_severities_vl ';
   l_sql_string := l_sql_string || ' WHERE trunc(sysdate) between trunc(nvl(start_date_active,sysdate))  and  trunc(nvl(end_date_active,sysdate)) ';
   l_sql_string := l_sql_string || ' and incident_subtype = ''INC''  ';
   l_sql_string := l_sql_string || ' and name is not null ';

   --Get Dynamic Search Criteria
   l_criteria_tbl :=p_lov_input_rec.LovCriteriaTbl;
   l_bind_index     := 1;

   IF l_criteria_tbl.count > 0 THEN
      i:=l_criteria_tbl.first;
      LOOP

         IF upper(l_criteria_tbl(i).AttributeName) = upper('SeverityLovName') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(name) like :NAME ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('SeverityLovDescription') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(description) like :DESC ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('SeverityLovSeverityId') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND incident_severity_id like :ID ';
              l_bindvar_tbl(l_bind_index) := l_criteria_tbl(i).AttributeValue;
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

      EXIT WHEN i= l_criteria_tbl.last;
      i:= i+1;
      END LOOP;
   END IF;

   -- SET START/END Row
   l_sql_string := l_sql_string || ' and rownum < :MAX_ROW ';
   --Max Row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows+1;
   l_bind_index := l_bind_index + 1;

   l_sql_string := l_sql_string || ' Order By name ) ';
   l_sql_string := l_sql_string || ' WHERE RN BETWEEN :START_ROW AND :END_ROW ';
   --start row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow+1;
   l_bind_index := l_bind_index + 1;
   --end row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows;
   l_bind_index := l_bind_index + 1;

   --open l_cur FOR l_sql_string;
   AHL_OSP_UTIL_PKG.OPEN_SEARCH_CURSOR
   (
       p_conditions_tbl => l_bindvar_tbl,
       p_sql_str        => l_sql_string,
       p_x_csr          => l_cur
   );

   i:=1;
   LOOP
     FETCH l_cur INTO     l_rownum,
                          l_name,
                          l_id,
                          l_desc;


     EXIT WHEN l_cur%NOTFOUND;

     --
     l_attributes_tbl(1).AttributeName := 'SeverityLovName';
     l_attributes_tbl(1).AttributeValue := l_name;

     --
     l_attributes_tbl(2).AttributeName := 'SeverityLovDescription';
     l_attributes_tbl(2).AttributeValue := l_desc;

     --
     l_attributes_tbl(3).AttributeName := 'SeverityLovSeverityId';
     l_attributes_tbl(3).AttributeValue := l_id;


     l_results_tbl(i) := l_attributes_tbl;
     i:=i+1;

   END LOOP;
   CLOSE l_cur;
   -- Create Attributes Table

   -- Populate output parameter
   x_lov_result_output_rec.StartRow := p_lov_input_rec.StartRow;
   x_lov_result_output_rec.NumberOfRows := i-1;
   x_lov_result_output_rec.LovResultTbl := l_results_tbl;

END getSeverityResults;

---------------------------------------------------------------------
-- PROCEDURE
-- getItemMetaData
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getItemMetaData(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_meta_output_rec      OUT NOCOPY LovMetaData_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

l_Meta_Attribute_Rec LovMetaAttribute_Rec_Type;
l_Meta_Attribute_Tbl LovMetaAttribute_Tbl_Type;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Create Attributes Table
   l_Meta_Attribute_Rec.AttributeName := 'InstanceNum';
   l_Meta_Attribute_Rec.Prompt := 'Instance Number';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(0) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'SerialNum';
   l_Meta_Attribute_Rec.Prompt := 'Serial Number';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(1) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'ItemNum';
   l_Meta_Attribute_Rec.Prompt := 'Item';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(2) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'LotNum';
   l_Meta_Attribute_Rec.Prompt := 'lot Number';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(3) := l_Meta_Attribute_Rec;

   -- Populate output parameter
   x_lov_meta_output_rec.LovTitle := 'Search Item';
   x_lov_meta_output_rec.LovMetaAttributeTbl := l_Meta_Attribute_Tbl;

END getItemMetaData;

---------------------------------------------------------------------
-- PROCEDURE
-- getItemResults
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getItemResults(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_result_output_rec    OUT NOCOPY LovOutput_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

-- Define local Variables
L_API_VERSION           CONSTANT NUMBER := 1.0;
L_API_NAME              CONSTANT VARCHAR2(30) := 'getItemResults';
L_FULL_NAME             CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

l_criteria_tbl LovCriteria_Tbl_Type;
l_results_tbl  LovResult_Tbl_Type;
l_attributes_tbl LovResultAttribute_Tbl_Type;

i    integer ;

-- Local Variables for the sql string.
l_sql_string     VARCHAR2(30000);
l_bind_index     NUMBER;
l_bindvar_tbl AHL_OSP_UTIL_PKG.ahl_conditions_tbl;
-- dynamic cursor
l_cur            AHL_OSP_UTIL_PKG.ahl_search_csr;

--Local Variables for search results
l_rownum          NUMBER;
l_instance        csi_item_instances.instance_number%type;
l_lot             csi_item_instances.lot_number%type;
l_serial          csi_item_instances.serial_number%type;
l_item            mtl_system_items_kfv.concatenated_segments%type;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- SELECT CLAUSE AND BASIC WHERE CONDITIONS
   l_sql_string := 'SELECT * FROM ( SELECT Rownum RN,  csi1.instance_number, csi1.lot_number,';
   l_sql_string := l_sql_string || ' csi1.serial_number, ahl1.concatenated_segments ';
   l_sql_string := l_sql_string || ' FROM  csi_item_instances csi1,mtl_system_items_kfv ahl1 ';
   l_sql_string := l_sql_string || ' WHERE csi1.INV_MASTER_ORGANIZATION_ID=ahl1.organization_id ';
   l_sql_string := l_sql_string || ' and csi1.inventory_item_id=ahl1.inventory_item_id  ';
   l_sql_string := l_sql_string || ' and csi1.INV_MASTER_ORGANIZATION_ID IN (SELECT master_organization_id ';
   l_sql_string := l_sql_string || ' FROM org_organization_definitions org, mtl_parameters mp WHERE org.organization_id = mp.organization_id AND NVL(operating_unit,mo_global.get_current_org_id()) = mo_global.get_current_org_id()) ';

   --Get Dynamic Search Criteria
   l_criteria_tbl :=p_lov_input_rec.LovCriteriaTbl;
   l_bind_index     := 1;

   IF l_criteria_tbl.count > 0 THEN
      i:=l_criteria_tbl.first;
      LOOP

         IF upper(l_criteria_tbl(i).AttributeName) = upper('InstanceNum') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(csi1.instance_number) like :INST ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('SerialNum') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(csi1.serial_number) like :SN ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('ItemNum') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(ahl1.concatenated_segments) like :ITEM ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

         IF upper(l_criteria_tbl(i).AttributeName) = upper('LotNum') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(csi1.lot_number) like :LOT ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         END IF;

      EXIT WHEN i= l_criteria_tbl.last;
      i:= i+1;
      END LOOP;
   END IF;

   -- SET START/END Row
   l_sql_string := l_sql_string || ' and rownum < :MAX_ROW ';
   --Max Row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows +1;
   l_bind_index := l_bind_index + 1;

   l_sql_string := l_sql_string || ' Order By ahl1.concatenated_segments,csi1.serial_number ) ';
   l_sql_string := l_sql_string || ' WHERE RN BETWEEN :START_ROW AND :END_ROW ';
   --start row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow +1;
   l_bind_index := l_bind_index + 1;
   --end row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows;
   l_bind_index := l_bind_index + 1;

   --open l_cur FOR l_sql_string;
   AHL_OSP_UTIL_PKG.OPEN_SEARCH_CURSOR
   (
       p_conditions_tbl => l_bindvar_tbl,
       p_sql_str        => l_sql_string,
       p_x_csr          => l_cur
   );

   i:=1;
   LOOP
     FETCH l_cur INTO     l_rownum,
                          l_instance,
                          l_lot,
                          l_serial,
                          l_item;


     EXIT WHEN l_cur%NOTFOUND;

     --
     l_attributes_tbl(1).AttributeName := 'InstanceNum';
     l_attributes_tbl(1).AttributeValue := l_instance;

     --
     l_attributes_tbl(2).AttributeName := 'SerialNum';
     l_attributes_tbl(2).AttributeValue := l_serial;

     --
     l_attributes_tbl(3).AttributeName := 'ItemNum';
     l_attributes_tbl(3).AttributeValue := l_item;

     --
     l_attributes_tbl(4).AttributeName := 'LotNum';
     l_attributes_tbl(4).AttributeValue := l_lot;

     l_results_tbl(i) := l_attributes_tbl;
     i:=i+1;

   END LOOP;
   CLOSE l_cur;
   -- Create Attributes Table

   -- Populate output parameter
   x_lov_result_output_rec.StartRow := p_lov_input_rec.StartRow;
   x_lov_result_output_rec.NumberOfRows := i-1;
   x_lov_result_output_rec.LovResultTbl := l_results_tbl;

END getItemResults;

PROCEDURE getReqItemMetaData(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_meta_output_rec      OUT NOCOPY LovMetaData_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

l_Meta_Attribute_Rec LovMetaAttribute_Rec_Type;
l_Meta_Attribute_Tbl LovMetaAttribute_Tbl_Type;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Create Attributes Table
   l_Meta_Attribute_Rec.AttributeName := 'ItemNum';
   l_Meta_Attribute_Rec.Prompt := 'Item';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(0) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'Description';
   l_Meta_Attribute_Rec.Prompt := 'Description';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(1) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'UOM';
   l_Meta_Attribute_Rec.Prompt := 'UOM';
   l_Meta_Attribute_Rec.IsDisplayed := 'T';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'string';

   l_Meta_Attribute_Tbl(2) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'InventoryItemId';
   l_Meta_Attribute_Rec.Prompt := '';
   l_Meta_Attribute_Rec.IsDisplayed := 'F';
   l_Meta_Attribute_Rec.IsSearcheable := 'F';
   l_Meta_Attribute_Rec.DataType := 'integer';

   l_Meta_Attribute_Tbl(3) := l_Meta_Attribute_Rec;

   ----
   l_Meta_Attribute_Rec.AttributeName := 'WorkorderId';
   l_Meta_Attribute_Rec.Prompt := '';
   l_Meta_Attribute_Rec.IsDisplayed := 'F';
   l_Meta_Attribute_Rec.IsSearcheable := 'T';
   l_Meta_Attribute_Rec.DataType := 'integer';

   l_Meta_Attribute_Tbl(4) := l_Meta_Attribute_Rec;

   -- Populate output parameter
   x_lov_meta_output_rec.LovTitle := 'Search Item';
   x_lov_meta_output_rec.LovMetaAttributeTbl := l_Meta_Attribute_Tbl;

END getReqItemMetaData;

---------------------------------------------------------------------
-- PROCEDURE
-- getItemResults
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getReqItemResults(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_result_output_rec    OUT NOCOPY LovOutput_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS

-- Define local Variables
L_API_VERSION           CONSTANT NUMBER := 1.0;
L_API_NAME              CONSTANT VARCHAR2(30) := 'getReqItemResults';
L_FULL_NAME             CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

l_criteria_tbl LovCriteria_Tbl_Type;
l_results_tbl  LovResult_Tbl_Type;
l_attributes_tbl LovResultAttribute_Tbl_Type;

i    integer ;

-- Local Variables for the sql string.
l_sql_string     VARCHAR2(30000);
l_sql_string1     VARCHAR2(30000);
l_sql_string2     VARCHAR2(30000);
l_bind_index     NUMBER;
l_bindvar_tbl AHL_OSP_UTIL_PKG.ahl_conditions_tbl;
-- dynamic cursor
l_cur            AHL_OSP_UTIL_PKG.ahl_search_csr;

--Local Variables for search results
l_rownum          NUMBER;
l_inv_item_id     NUMBER;
l_wo_id           NUMBER;
l_uom             mtl_system_items_kfv.primary_unit_of_measure%type;
l_desc            mtl_system_items_kfv.description%type;
l_item            mtl_system_items_kfv.concatenated_segments%type;
l_wo_id_input BOOLEAN;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_wo_id_input := FALSE;

   -- SELECT CLAUSE AND BASIC WHERE CONDITIONS when wo_id is not null
   l_sql_string1 := 'SELECT * FROM ( SELECT Rownum RN,  mtl.concatenated_segments , mtl.description , mtl.primary_unit_of_measure, WO.workorder_id, mtl.inventory_item_id ';
   l_sql_string1 := l_sql_string1 || ' from mtl_system_items_kfv mtl,mtl_parameters mtlp, ahl_workorders wo, ahl_visits_b VST ';
   l_sql_string1 := l_sql_string1 || ' WHERE mtl.organization_id = mtlp.organization_id  ';
   l_sql_string1 := l_sql_string1 || ' and mtlp.eam_enabled_flag = ''Y'' and mtl.organization_id = VST.organization_id  ';
   l_sql_string1 := l_sql_string1 || ' and VST.visit_id = WO.visit_id ';

   -- SELECT CLAUSE AND BASIC WHERE CONDITIONS when wo id is null
   l_sql_string2 := 'SELECT * FROM ( SELECT Rownum RN,  mtl.concatenated_segments , mtl.description , mtl.primary_unit_of_measure, to_number(NULL), mtl.inventory_item_id ';
   l_sql_string2 := l_sql_string2 || ' from mtl_system_items_kfv mtl,mtl_parameters mtlp ';
   l_sql_string2 := l_sql_string2 || ' WHERE mtl.organization_id = mtlp.organization_id  ';
   l_sql_string2 := l_sql_string2 || ' and mtlp.eam_enabled_flag = ''Y'' and mtl.organization_id IN (SELECT master_organization_id ';
   l_sql_string2 := l_sql_string2 || ' FROM org_organization_definitions org, mtl_parameters mp WHERE org.organization_id = mp.organization_id AND NVL(operating_unit,mo_global.get_current_org_id()) = mo_global.get_current_org_id()) ';

   --Get Dynamic Search Criteria
   l_criteria_tbl :=p_lov_input_rec.LovCriteriaTbl;
   l_bind_index     := 1;

   IF l_criteria_tbl.count > 0 THEN
      i:=l_criteria_tbl.first;
      LOOP
         IF upper(l_criteria_tbl(i).AttributeName) = upper('ItemNum') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(mtl.concatenated_segments) like :ITEM ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         ELSIF upper(l_criteria_tbl(i).AttributeName) = upper('Description') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND upper(mtl.description) like :DESC ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         ELSIF upper(l_criteria_tbl(i).AttributeName) = upper('InventoryItemId') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND  mtl.inventory_item_id like :INVID ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
            END IF;
         ELSIF upper(l_criteria_tbl(i).AttributeName) = upper('WorkorderId') THEN
            IF l_criteria_tbl(i).AttributeValue is not NULL THEN
              l_sql_string := l_sql_string || ' AND WO.workorder_id like :WOID ';
              l_bindvar_tbl(l_bind_index) := upper(l_criteria_tbl(i).AttributeValue);
              l_bind_index := l_bind_index + 1;
              l_wo_id_input := TRUE;
            END IF;
         END IF;

      EXIT WHEN i= l_criteria_tbl.last;
      i:= i+1;
      END LOOP;
   END IF;
   IF(l_wo_id_input)THEN
      l_sql_string := l_sql_string1 || l_sql_string;
   ELSE
      l_sql_string := l_sql_string2 || l_sql_string;
   END IF;
   -- SET START/END Row
   l_sql_string := l_sql_string || ' and rownum < :MAX_ROW ';
   --Max Row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows +1;
   l_bind_index := l_bind_index + 1;

   l_sql_string := l_sql_string || ' Order By mtl.concatenated_segments ) ';
   l_sql_string := l_sql_string || ' WHERE RN BETWEEN :START_ROW AND :END_ROW ';
   --start row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow +1;
   l_bind_index := l_bind_index + 1;
   --end row
   l_bindvar_tbl(l_bind_index) := p_lov_input_rec.StartRow + p_lov_input_rec.NumberOfRows;
   l_bind_index := l_bind_index + 1;

   --open l_cur FOR l_sql_string;
   AHL_OSP_UTIL_PKG.OPEN_SEARCH_CURSOR
   (
       p_conditions_tbl => l_bindvar_tbl,
       p_sql_str        => l_sql_string,
       p_x_csr          => l_cur
   );

   i:=1;
   LOOP
     FETCH l_cur INTO     l_rownum,
                          l_item,
                          l_desc,
                          l_uom,
                          l_wo_id,
                          l_inv_item_id;


     EXIT WHEN l_cur%NOTFOUND;

--
     l_attributes_tbl(1).AttributeName := 'ItemNum';
     l_attributes_tbl(1).AttributeValue := l_item;
     --
     l_attributes_tbl(2).AttributeName := 'Description';
     l_attributes_tbl(2).AttributeValue := l_desc;

     --
     l_attributes_tbl(3).AttributeName := 'UOM';
     l_attributes_tbl(3).AttributeValue := l_uom;

--
     l_attributes_tbl(4).AttributeName := 'WorkorderId';
     l_attributes_tbl(4).AttributeValue := l_wo_id;

     l_attributes_tbl(5).AttributeName := 'InventoryItemId';
     l_attributes_tbl(5).AttributeValue := l_inv_item_id;


     l_results_tbl(i) := l_attributes_tbl;
     i:=i+1;

   END LOOP;
   CLOSE l_cur;
   -- Create Attributes Table

   -- Populate output parameter
   x_lov_result_output_rec.StartRow := p_lov_input_rec.StartRow;
   x_lov_result_output_rec.NumberOfRows := i-1;
   x_lov_result_output_rec.LovResultTbl := l_results_tbl;

END getReqItemResults;
---------------------------------------------------------------------
-- PROCEDURE
-- getLOVMetaData
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getLOVMetaData(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_meta_output_rec      OUT NOCOPY LovMetaData_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   CASE upper(p_lov_input_rec.lovID)

     WHEN 'AHL_PRD_VISITNUM_LOV' THEN

        getVisitNumberMetaData(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_meta_output_rec      => x_lov_meta_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );

     WHEN 'AHL_UNIT_LOV' THEN

        getUnitMetaData(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_meta_output_rec      => x_lov_meta_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );

     WHEN 'AHL_PRD_EMP_LOV' THEN

        getEmployeeMetaData(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_meta_output_rec      => x_lov_meta_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );

     WHEN 'AHL_PRD_EMPNAME_LOV' THEN

        getEmpNameMetaData(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_meta_output_rec      => x_lov_meta_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );

     WHEN 'AHL_PRD_WOSTATUS_LOV' THEN

        getWOStatusMetaData(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_meta_output_rec      => x_lov_meta_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );

     WHEN 'AHL_PRD_OPERSEQ_LOV' THEN

        getOperSeqMetaData(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_meta_output_rec      => x_lov_meta_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );

     WHEN 'AHL_PRD_RESCODE_LOV' THEN

        getResCodeMetaData(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_meta_output_rec      => x_lov_meta_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );

     WHEN 'AHL_PRD_RESSERIALNUM_LOV' THEN

        getSerialNumMetaData(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_meta_output_rec      => x_lov_meta_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );

     WHEN 'AHL_PRD_ATACODE_LOV' THEN

        getATACodeMetaData(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_meta_output_rec      => x_lov_meta_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );
     WHEN 'AHL_PRD_POSITION_LOV' THEN

        getPositionMetaData(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_meta_output_rec      => x_lov_meta_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );

     WHEN 'AHL_PRD_WOPOSITION_LOV' THEN

        getWOPositionMetaData(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_meta_output_rec      => x_lov_meta_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );

     WHEN 'AHL_PRD_ONITEM_LOV' THEN

        getOnItemMetaData(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_meta_output_rec      => x_lov_meta_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );

     WHEN 'AHL_PRD_CONDITION_LOV' THEN

        getConditionMetaData(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_meta_output_rec      => x_lov_meta_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );

     WHEN 'AHL_PRD_REM_REASON_LOV' THEN

        getRemReasonMetaData(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_meta_output_rec      => x_lov_meta_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );

     WHEN 'AHL_PRD_REMOVAL_LOV' THEN

        getRemCodeMetaData(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_meta_output_rec      => x_lov_meta_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );

     WHEN 'AHL_PRD_RESOLUTION_LOV' THEN

        getResolutionMetaData(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_meta_output_rec      => x_lov_meta_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );

     WHEN 'AHL_PRD_PROBLEM_LOV' THEN

        getProblemMetaData(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_meta_output_rec      => x_lov_meta_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );

     WHEN 'AHL_PRD_SEVERITY_LOV' THEN

        getSeverityMetaData(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_meta_output_rec      => x_lov_meta_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );

     WHEN 'AHL_PRD_ITEM_LOV' THEN

        getItemMetaData(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_meta_output_rec      => x_lov_meta_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );
     WHEN 'AHL_PRD_REQ_MTL_ITEM_LOV' THEN

        getReqItemMetaData(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_meta_output_rec      => x_lov_meta_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );
     WHEN 'AHL_PRD_HOLD_REASON_LOV' THEN

        getHoldReasonMetaData(
                p_lov_input_rec            => p_lov_input_rec,
                x_lov_meta_output_rec      => x_lov_meta_output_rec,
                x_return_status            => x_return_status,
                x_msg_count                => x_msg_count,
                x_msg_data                 => x_msg_data );

   ELSE
     --throw exception;
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_LOV_NOT_FOUND');
      FND_MSG_PUB.ADD;
      RAISE  FND_API.G_EXC_ERROR;
   END CASE;

END getLOVMetaData;

---------------------------------------------------------------------
-- PROCEDURE
-- getLOVResults
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE getLOVResults(
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_result_output_rec    OUT NOCOPY LovOutput_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2)
IS
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   CASE upper(p_lov_input_rec.lovID)

     WHEN 'AHL_PRD_VISITNUM_LOV' THEN

      getVisitNumberResults(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_result_output_rec    => x_lov_result_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );

     WHEN 'AHL_UNIT_LOV' THEN

      getUnitResults(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_result_output_rec    => x_lov_result_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );

     WHEN 'AHL_PRD_EMP_LOV' THEN

        getEmployeeResults(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_result_output_rec    => x_lov_result_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );

     WHEN 'AHL_PRD_EMPNAME_LOV' THEN

        getEmpNameResults(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_result_output_rec    => x_lov_result_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );

     WHEN 'AHL_PRD_WOSTATUS_LOV' THEN

        getWOStatusResults(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_result_output_rec    => x_lov_result_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );

     WHEN 'AHL_PRD_OPERSEQ_LOV' THEN

        getOperSeqResults(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_result_output_rec    => x_lov_result_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );

     WHEN 'AHL_PRD_RESCODE_LOV' THEN

        getResCodeResults(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_result_output_rec    => x_lov_result_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );

     WHEN 'AHL_PRD_RESSERIALNUM_LOV' THEN

        getSerialNumResults(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_result_output_rec    => x_lov_result_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );

     WHEN 'AHL_PRD_ATACODE_LOV' THEN

        getATACodeResults(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_result_output_rec    => x_lov_result_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );
     WHEN 'AHL_PRD_POSITION_LOV' THEN
        getPositionResults(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_result_output_rec    => x_lov_result_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );

     WHEN 'AHL_PRD_WOPOSITION_LOV' THEN

        getWOPositionResults(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_result_output_rec    => x_lov_result_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );

     WHEN 'AHL_PRD_ONITEM_LOV' THEN

        getOnItemResults(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_result_output_rec    => x_lov_result_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );

     WHEN 'AHL_PRD_CONDITION_LOV' THEN

        getConditionResults(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_result_output_rec    => x_lov_result_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );

     WHEN 'AHL_PRD_REM_REASON_LOV' THEN

        getRemReasonResults(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_result_output_rec    => x_lov_result_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );

     WHEN 'AHL_PRD_REMOVAL_LOV' THEN

        getRemCodeResults(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_result_output_rec    => x_lov_result_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );

     WHEN 'AHL_PRD_RESOLUTION_LOV' THEN

        getResolutionResults(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_result_output_rec    => x_lov_result_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );

     WHEN 'AHL_PRD_PROBLEM_LOV' THEN

        getProblemResults(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_result_output_rec    => x_lov_result_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );

     WHEN 'AHL_PRD_SEVERITY_LOV' THEN

        getSeverityResults(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_result_output_rec    => x_lov_result_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );

     WHEN 'AHL_PRD_ITEM_LOV' THEN

        getItemResults(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_result_output_rec    => x_lov_result_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );
    WHEN 'AHL_PRD_REQ_MTL_ITEM_LOV' THEN

        getReqItemResults(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_result_output_rec    => x_lov_result_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );
    WHEN 'AHL_PRD_HOLD_REASON_LOV' THEN

        getHoldReasonResults(
                p_lov_input_rec            => p_lov_input_rec,
                x_lov_result_output_rec    => x_lov_result_output_rec,
                x_return_status            => x_return_status,
                x_msg_count                => x_msg_count,
                x_msg_data                 => x_msg_data );

   ELSE
     --throw exception;
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_LOV_NOT_FOUND');
      FND_MSG_PUB.ADD;
      RAISE  FND_API.G_EXC_ERROR;

   END CASE;

END getLOVResults;

---------------------------------------------------------------------
-- PROCEDURE
-- Call_LOV_Services
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------

PROCEDURE Call_LOV_Services (
   p_api_version              IN  NUMBER    :=1.0,
   p_init_msg_list            IN  VARCHAR2  :=Fnd_Api.g_false,
   p_commit                   IN  VARCHAR2  :=Fnd_Api.g_false,
   p_validation_level         IN  NUMBER    :=Fnd_Api.g_valid_level_full,
   p_module_type              IN  VARCHAR2  :=null,
   p_userid                   IN  VARCHAR2   := NULL,
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_result_output_rec    OUT NOCOPY LovOutput_Rec_Type,
   x_lov_meta_output_rec      OUT NOCOPY LovMetaData_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2 )
IS
l_api_version      CONSTANT NUMBER := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'Call_LOV_Services';
BEGIN


   IF(p_module_type = 'BPEL') THEN
      x_return_status := AHL_PRD_WO_PUB.init_user_and_role(p_userid);
      IF(x_return_status <> Fnd_Api.G_RET_STS_SUCCESS)THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   -- Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version,l_api_name, G_PKG_NAME ) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
   END IF;

   -- Initialize output variables
   x_lov_meta_output_rec.LovMetaAttributeTbl(0).AttributeName := null;
   x_lov_result_output_rec.LovResultTbl(0)(0).AttributeName := null;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_lov_input_rec.getMetaData is not null and
     upper(p_lov_input_rec.getMetaData) = 'T' THEN

      getLOVMetaData(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_meta_output_rec      => x_lov_meta_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );
   END IF;
   IF p_lov_input_rec.getResults is not null and
         upper(p_lov_input_rec.getResults) = 'T' THEN

      getLOVResults(
           p_lov_input_rec            => p_lov_input_rec,
           x_lov_result_output_rec    => x_lov_result_output_rec,
           x_return_status            => x_return_status,
           x_msg_count                => x_msg_count,
           x_msg_data                 => x_msg_data );

   END IF;
   IF(x_lov_result_output_rec.NumberOfRows IS NULL OR x_lov_result_output_rec.NumberOfRows < 1)THEN
     x_lov_result_output_rec.LovResultTbl(0)(0).AttributeName := NULL;
   END IF;
   IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
     RAISE  FND_API.G_EXC_ERROR;
   END IF;
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   x_msg_count := FND_MSG_PUB.count_msg;
   x_msg_data := AHL_PRD_WO_PUB.GET_MSG_DATA(x_msg_count);
   /*FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);*/



 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   x_msg_count := FND_MSG_PUB.count_msg;
   x_msg_data := AHL_PRD_WO_PUB.GET_MSG_DATA(x_msg_count);
   /*FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);*/


 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => l_api_name,
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;
    x_msg_count := FND_MSG_PUB.count_msg;
   x_msg_data := AHL_PRD_WO_PUB.GET_MSG_DATA(x_msg_count);
    /*FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);*/
END Call_LOV_Services;

END AHL_PRD_LOV_SERVICE_PVT;

/
