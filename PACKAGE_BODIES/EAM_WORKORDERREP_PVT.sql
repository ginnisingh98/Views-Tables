--------------------------------------------------------
--  DDL for Package Body EAM_WORKORDERREP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_WORKORDERREP_PVT" AS
/* $Header: EAMVWRPB.pls 120.12.12010000.12 2010/05/27 00:23:58 mashah ship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVWRPB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_WorkOrderRep_PVT
--
--  NOTES
--
--  HISTORY
--
--  02-MARCH-2006    Smriti Sharma     Initial Creation
--  20-APR-2009      ngoutam           Bug  7758322
***************************************************************************/


G_PKG_NAME 	CONSTANT VARCHAR2(30):='EAM_WorkOrderRep_PVT';
Function getWoReportXML
(
	p_wip_entity_id in system.eam_wipid_tab_type,
	p_operation_flag in int,
	p_material_flag in int,
	p_resource_flag in int,
	p_direct_material_flag in int,
  p_short_attachment_flag in int,
	p_long_attachment_flag in int,
	p_file_attachment_flag in int,
	p_work_request_flag in int,
	p_meter_flag in int,
	p_quality_plan_flag in int,
	p_asset_bom_flag in int,
  p_safety_permit_flag in int -- for permit report
)return CLOB

IS

 l_xmlType XMLType:=null;
 l_xmlType1 XMLType:=null;
 l_xmlTypeParamList XMLType:=null;
 l_xmlTypeOperation XMLType:=null;
 l_xmlTypeResource XMLType:=null;
 l_xmlTypeEmployee XMLType:=null;
 l_xmlTypeDirectMaterial XMLType:=null;
 l_xmlTypeShortAttachment XMLType:=null;
 l_xmlTypeOpShortAttachment XMLType:=null;
 l_xmlTypeLongAttachment XMLType:=null;
 l_xmlTypeOpLongAttachment XMLType:=null;
 l_xmlTypefileattachment XMLType:=null;
 l_xmlTypeWorkRequest XMLType:=null;
 l_xmlTypeMeter XMLType:=null;
 l_xmlTypeMaterial XMLType:=null;
 l_xmlTypeQualityPlan XMLType:=null;
 l_xmlTypeAssetBom XMLType :=null;
 l_xmlTypeFailureData XMLType:=null;
 l_xmlTemp XMLType:=null;
 l_xmlTemp2 XMLType:=null;
 l_xmlTemp3 XMLType:=null;
 l_xmlTemp4 XMLType:=null;
 l_string varchar2(4000);
 l_wip_entity_name varchar2(100);
 l_organization_id number;
 l_org_id number;
 l_asset_group varchar2(100);
 l_instance_number varchar2(100):=null;
 l_serial_number varchar2(100):=null;
 l_asset_activity varchar2(100):=null;
 l_media_id number:=0;
 l_plan_id number;
 i number:=1;
 l_temp clob:=null;

		  -- FP 7493388 for Base Bug 7005666
 l_inventory_id number;
 l_asset_route_flag varchar2(20);
 l_xmlTypeAssetroutecomp XMLType:=null;
		  -- for Bug 7005666

l_xmlTypePermits XMLType   :=NULL; --permit safety report


 cursor operation_cursor(p_wip_id number) is
  SELECT XMLELEMENT("OPERATION", XMLFOREST(WO.OPERATION_SEQ_NUM as "OPSEQNUM",
    fnd_date.date_to_displayDT(Convert_to_client_time(WO.FIRST_UNIT_START_DATE)) as "OPSSHEDULEDSTART",
    fnd_date.date_to_displayDT(Convert_to_client_time(WO.LAST_UNIT_COMPLETION_DATE)) as "OPSCHEDULEDCOMPLETION",
    to_char((WO.LAST_UNIT_COMPLETION_DATE-WO.FIRST_UNIT_START_DATE),'99.99') as "OPDURATION",
    LU2.meaning as "OPSHUTDOWNTYPE",
    LU1.meaning as "OPCOMPLETED",
    BS.OPERATION_CODE as "OPCODE",
    BD.DEPARTMENT_CODE as "OPDEPT",
    WO.DESCRIPTION as "OPDESC",
    WO.LONG_DESCRIPTION as "OPLONGDESC",
    fnd_date.date_to_displayDT(Convert_to_client_time(eoctv.actual_start_date)) as "OPACTUALSTARTDATE",
    fnd_date.date_to_displayDT(Convert_to_client_time(eoctv.actual_end_date)) as "OPACTUALENDDATE"))  Operation
  FROM
    eam_op_completion_txns_v eoctv,
    FND_COMMON_LOOKUPS LU1,
    MFG_LOOKUPS LU2,
    WIP_OPERATIONS WO,
    BOM_STANDARD_OPERATIONS BS,
    BOM_DEPARTMENTS BD
  WHERE BD.DEPARTMENT_ID  = WO.DEPARTMENT_ID
    AND NVL(BS.OPERATION_TYPE,1) = 1  and
    eoctv.wip_entity_id(+)=wo.wip_entity_id and
    eoctv.operation_seq_num(+)=wo.operation_seq_num
    AND BS.LINE_ID IS NULL
    AND WO.WIP_ENTITY_ID = p_wip_id
    AND LU2.LOOKUP_CODE(+) = WO.SHUTDOWN_TYPE
    AND LU2.LOOKUP_TYPE(+) = 'BOM_EAM_SHUTDOWN_TYPE'
    AND LU1.LOOKUP_CODE(+) = WO.OPERATION_COMPLETED
    AND LU1.LOOKUP_TYPE(+) = 'EAM_YES_NO'
    AND BS.STANDARD_OPERATION_ID (+) = WO.STANDARD_OPERATION_ID
  ORDER BY WO.OPERATION_SEQ_NUM;

 --Cursor for Materials

 cursor material_cursor(p_wip_id number) is
  SELECT XMLELEMENT("MATERIAL",XMLFOREST(WRO.OPERATION_SEQ_NUM as "OPERATIONSEQNUM",
    milk.concatenated_segments as "REQLOCATORNAME",
    --M.DESCRIPTION as "REQCOMPDESC",
    LU.MEANING as "REQTYPE",
    WRO.SUPPLY_SUBINVENTORY as "REQSUBINVENTORY",
    fnd_date.date_to_displayDT(Convert_to_client_time(WRO.DATE_REQUIRED)) as "REQDATEREQUIRED",
    M.PRIMARY_UOM_CODE as "REQUOM",
    WRO.REQUIRED_QUANTITY as "REQREQUIREDQUANTITY",
    msikfv.concatenated_segments as "REQITEMNAME",
    msikfv.description as "REQITEMDESCRIPTION",
    wro.quantity_issued as "REQISSUEDQUANTITY",
    eam_material_allocqty_pkg.open_quantity(WRO.WIP_ENTITY_ID,WRO.OPERATION_SEQ_NUM,WRO.ORGANIZATION_ID,WRO.INVENTORY_ITEM_ID,WRO.REQUIRED_QUANTITY,WRO.QUANTITY_ISSUED) as "REQQUANTITYOPEN" ,
    eam_material_allocqty_pkg.allocated_quantity(WRO.WIP_ENTITY_ID,WRO.OPERATION_SEQ_NUM,WRO.ORGANIZATION_ID,WRO.INVENTORY_ITEM_ID) as "REQALLOCATEDQUANTITY"))  Material
  FROM
    mtl_system_items_b_kfv msikfv,
    MTL_SYSTEM_ITEMS M,
    MTL_ITEM_LOCATIONS L,
    MFG_LOOKUPS LU,
    WIP_REQUIREMENT_OPERATIONS WRO,
    MTL_ITEM_LOCATIONS_KFV milk
  WHERE
    msikfv.organization_id = wro.organization_id
    AND msikfv.inventory_item_id = wro.inventory_item_id
    AND M.INVENTORY_ITEM_ID = WRO.INVENTORY_ITEM_ID
    AND WRO.WIP_ENTITY_ID= p_wip_id
    AND L.INVENTORY_LOCATION_ID (+) = NVL(WRO.SUPPLY_LOCATOR_ID,'-1')
    AND milk.INVENTORY_LOCATION_ID (+) = NVL(WRO.SUPPLY_LOCATOR_ID,'-1')
    AND M.ORGANIZATION_ID = WRO.ORGANIZATION_ID
    AND L.ORGANIZATION_ID (+) = WRO.ORGANIZATION_ID
    AND milk.organization_id (+) = wro.organization_id
    AND LU.LOOKUP_TYPE = 'WIP_SUPPLY_SHORT'
    AND LU.LOOKUP_CODE = WRO.WIP_SUPPLY_TYPE
    AND wro.inventory_item_id in (SELECT inventory_item_id
			       FROM mtl_system_items
			       WHERE stock_enabled_flag = 'Y')
  ORDER BY msikfv.concatenated_segments;

 -- Cursor for Resources

 cursor resource_cursor(p_wip_id number) is
  SELECT  XMLELEMENT("RESOURCE",XMLFOREST(WOR.OPERATION_SEQ_NUM as  "RESOPSEQNUM",
    WOR.RESOURCE_SEQ_NUM as "RESSEQ",
    WOR.SCHEDULE_SEQ_NUM as "RESSCHEDSEQ",
    BR.RESOURCE_CODE as "RESCODE",
    --BR.RESOURCE_ID  as  "RESRESOURCEID",
    WOR.USAGE_RATE_OR_AMOUNT as "RESUSAGERATE",
    WOR.UOM_CODE as "RESUOM",
    LU.MEANING as "RESBASIS",
    WOR.APPLIED_RESOURCE_UNITS as "ACTUALHRCHARGED",
    WOR.ASSIGNED_UNITS as "RESCAPACITY",
    CA.ACTIVITY as "RESACTIVITY",
    fnd_date.date_to_displayDT(Convert_to_client_time(WOR.START_DATE)) as "RESSTARTDATE",
    fnd_date.date_to_displayDT(Convert_to_client_time(WOR.COMPLETION_DATE)) as "RESCOMPLETIONDATE")) Resources
  FROM
    BOM_RESOURCES BR,
    CST_ACTIVITIES CA,
    MFG_LOOKUPS LU,
    WIP_OPERATION_RESOURCES WOR
  WHERE BR.ORGANIZATION_ID = WOR.ORGANIZATION_ID
    AND WOR.WIP_ENTITY_ID = p_wip_id
    AND BR.RESOURCE_ID = WOR.RESOURCE_ID
    AND CA.ACTIVITY_ID(+) = WOR.ACTIVITY_ID
    AND LU.LOOKUP_CODE = WOR.BASIS_TYPE
    AND LU.LOOKUP_TYPE = 'CST_BASIS'
  ORDER BY WOR.RESOURCE_SEQ_NUM;

 --Cursor for Employees

 cursor employee_cursor(p_wip_id number) is
  SELECT XMLELEMENT("EMPLOYEE",XMLFOREST(
    wori.operation_seq_num as "EMPOPSEQNO",
    wori.resource_seq_num  as "EMPRESSEQNO",
    br.resource_code  as "EMPRESCODE",
    br.resource_type  as "EMPRESTYPE",
    ppf.employee_number  as "EMPNO",
    ppf.full_name  as "EMPFULLNAME",
    fnd_date.date_to_displayDT(Convert_to_client_time(wori.start_date)) as "EMPSTARTDATE",
    fnd_date.date_to_displayDT(Convert_to_client_time(wori.completion_date))  as "EMPENDDATE",
    bd.department_code  as "EMPDEPTCODE")) Employees
   FROM wip_op_resource_instances wori,
    wip_operation_resources wor,
    bom_resources br,
    bom_resource_employees bre,
    per_people_f ppf,
    bom_departments  bd
  WHERE  wor.wip_entity_id = wori.wip_entity_id and
    wor.organization_id = wori.organization_id and
    wor.operation_seq_num = wori.operation_seq_num and
    wor.resource_seq_num = wori.resource_seq_num and
    br.resource_id = wor.resource_id and
    br.resource_type = 2 and
    bre.instance_id = wori.instance_id and
    trunc(sysdate) between ppf.effective_start_date and ppf.effective_end_date and
    ppf.person_id = bre.person_id  and
    wor.department_id=bd.department_id  and
    wor.organization_id=bd.organization_id and
	wor.wip_entity_id=p_wip_id;

 --Cursor for Direct Materials

 cursor directmaterial_cursor(p_wip_id number) is
  SELECT  XMLELEMENT("DIRECTMATERIAL", XMLFOREST(edrv.task_number as "OPERATIONSEQNO",
	edrv.service_line_type as "SERVICELINETYPE",
	edrv.item_description as "ITEMNAME",
	edrv.description as "ITEMDESC",
	DECODE(edrv.order_type_lookup_code,'FIXED PRICE',NVL(edrv.amount,0),NVL(edrv.required_quantity, 0)) as "QUANTITYREQUIRED",
	DECODE(edrv.order_type_lookup_code,'FIXED PRICE',NVL(edrv.rql_amount_ordered,0),NVL(edrv.rql_quantity_ordered,0)) as "REQQUANTITYORDERED",
	DECODE(edrv.order_type_lookup_code,'FIXED PRICE',NVL(edrv.po_amount_ordered,0),NVL(edrv.po_quantity_ordered,0)) as "POQUANTITYORDERED",
	DECODE(edrv.order_type_lookup_code,'FIXED PRICE',NVL(edrv.amount_delivered,0),NVL(edrv.quantity_received, 0)) as "QUANTITYRECEIVED",
	edrv.uom_code as "UOM",
    fnd_date.date_to_displayDT(Convert_to_client_time(edrv.date_required)) as "DATEREQUIRED")) DirectMaterial
  FROM EAM_DIRECT_ITEM_RECS_V edrv
  WHERE edrv.wip_entity_id = p_wip_id;


 -- Cursor for Work Order Short Attachments

cursor shortattachment_cursor(p_wip_id number,p_org_id number) is
  select XMLELEMENT("SHORTATTACHMENT",XMLFOREST(
  --fdst.media_id     as      "AMEDIAID",
    fdst.short_text 	as		"ASHORTTEXT",
    fdv.file_name  	as		"AWORKNAME",
    fdv.description  	as		"AWORKDESC",
    --fdv.datatype_name as      "AWORKTYPE",
   -- fdv.datatype_id	as		"AWORKDATATYPEID",
    --fdv.category_id   as      "ACATEGORYID",
    fdv.category_description as "AWORKCATEGORY",
    fad.seq_num  as   "ASEQNUM"
    --fad.entity_name  as "AENTITYNAME",
    /*fad.attached_document_id as "ATTACHWORKDOCID"*/))  ShortAttachment
  from
    FND_DOCUMENTS_SHORT_TEXT fdst,
    fnd_documents_vl fdv,
    fnd_attached_documents fad
  where
    fdst.media_id = fdv.media_id and
	--fdv.datatype_name = 'Short Text' and
	-- Changed bug 9081077
    fdv.datatype_id = 1 AND
	-- Above is Data Type id for short text.Refer FND_DOCUMENT_DATATYPES table
	-- fvd.datatype_name fetches user name for data type
    fad.document_id = fdv.document_id and
    fad.entity_name = 'EAM_WORK_ORDERS' and
    fad.pk1_value = p_org_id and
    fad.pk2_value =p_wip_id
  order by fdv.file_name;

-- Cursor for Work Order Long Attachments

 cursor longattachment_cursor(p_wip_id number,p_org_id number) is
  select XMLFOREST(
    fdlt.media_id     as      "ALONGMEDIAID",
    --fdlt.long_text 	as 		"ALONGTEXT",
    fdv.file_name  	as		"ALONGWORKNAME",
    fdv.description  	as		"ALONGWORKDESC",
    --fdv.datatype_name as      "AWORKTYPE",
    --fdv.datatype_id	as		"AWORKDATATYPEID",
    --fdv.category_id   as      "ACATEGORYID",
    fdv.category_description as "ALONGWORKCATEGORY",
    fad.seq_num  as   "ALONGSEQNUM"
    --fad.entity_name  as "AENTITYNAME",
    /*fad.attached_document_id as "ATTACHWORKDOCID"*/)  LongAttachment
  from
    FND_DOCUMENTS_LONG_TEXT fdlt,
    fnd_documents_vl fdv,
    fnd_attached_documents fad
  where
    fdlt.media_id = fdv.media_id and
	fdv.datatype_name = 'Long Text' and
    fad.document_id = fdv.document_id and
    fad.entity_name = 'EAM_WORK_ORDERS' and
    fad.pk1_value = p_org_id and
    fad.pk2_value =p_wip_id
  order by fdlt.media_id desc;

--Cursor for Operation Short Attachments

 cursor opshortattachment(p_wip_id number,p_org_id number) is
  select XMLELEMENT("OPSHORTATTACHMENT",XMLFOREST(fdst.short_text as "OPASHORTTEXT",
    fdv.file_name as "OPASHORTNAME",
    fdv.description as "OPASHORTDESC",
    fdv.category_description as "OPASHORTCATEGORY",
	fad.pk2_value as "OPASEQNO")) OpShortAttachment
  from
    FND_DOCUMENTS_SHORT_TEXT fdst,
    fnd_documents_vl fdv,
    fnd_attached_documents fad
  where fdst.media_id = fdv.media_id
    and fad.document_id = fdv.document_id
	and fad.entity_name = 'EAM_DISCRETE_OPERATIONS'
	and fdv.datatype_name = 'Short Text'
    and fad.pk1_value=p_wip_id
    and fad.pk3_value=p_org_id
   order by fdv.file_name;

-- Cursor for Operation Long Attachments
cursor oplongattachment_cursor(p_wip_id number,p_org_id number) is
  select XMLFOREST(
    fdlt.media_id     as      "OPALONGMEDIAID",
    fdv.file_name  	as		"OPALONGWORKNAME",
    fdv.description  	as		"OPALONGWORKDESC",
    fdv.category_description as "OPALONGWORKCATEGORY",
    fad.pk2_value  as   "OPALONGSEQNUM")  OpLongAttachment
  from
    FND_DOCUMENTS_LONG_TEXT fdlt,
    fnd_documents_vl fdv,
    fnd_attached_documents fad
  where
    fdlt.media_id = fdv.media_id and
    fad.document_id = fdv.document_id and
	fdv.datatype_name = 'Long Text' and
    fad.entity_name = 'EAM_DISCRETE_OPERATIONS' and
    fad.pk1_value = p_wip_id and
    fad.pk3_value =p_org_id
  order by fdlt.media_id desc;

--Cursor for File Attachments
cursor fileattachment_cursor(p_wip_id number,p_org_id number) is
  select XMLELEMENT("FILEATTACHMENT",XMLFOREST(
    fdv.file_name  	as		"AFILEWORKNAME",
    fdv.description  	as		"AFILEWORKDESC",
    fdv.category_description as  "AFILEWORKCATEGORY")) FileAttachment
  from
    fnd_documents_vl fdv,
    fnd_attached_documents fad
  where
    fad.document_id = fdv.document_id and
    fad.entity_name = 'EAM_WORK_ORDERS' and
    fad.pk1_value=p_org_id and
    fad.pk2_value= p_wip_id and
    fdv.file_name  is not null and
 	fdv.datatype_name NOT IN ('Long Text', 'Short Text');


-- Cursor for Work Requests

 cursor workrequest_cursor(p_wip_id number,p_org_id number) is
  select XMLELEMENT("WORKREQUEST",XMLFOREST(wewr.work_request_number as "WRNUMBER",
    wewr.description as "WRDESCRIPTION",
    ml1.meaning as "WRSTATUS" ,
    ml2.meaning as "WRPRIORITY",
    bd.department_code as "WROWNINGDEPT",
    fnd_date.date_to_displayDT(Convert_to_client_time(wewr.expected_resolution_date)) as "WREXPECTEDRESOLUTIONDATE",
    fu.user_name as "WRORIGINATOR")) WorkRequest
  from
    wip_eam_work_requests wewr,
    fnd_user fu,
    bom_departments bd,
    mfg_lookups ml1,
    mfg_lookups ml2
  where
    fu.user_id = wewr.created_by
    and bd.department_id = wewr.work_request_owning_dept
    and ml1.lookup_type (+) = 'WIP_EAM_WORK_REQ_STATUS'
    and ml1.lookup_code (+) = wewr.work_request_status_id
    and ml2.lookup_type (+) = 'WIP_EAM_ACTIVITY_PRIORITY'
    and ml2.lookup_code (+) = wewr.work_request_priority_id
    and wewr.wip_entity_id =p_wip_id
    and wewr.organization_id = p_org_id
  order by wewr.work_request_number ;

 -- Cursor for Meters

 cursor meter_cursor(p_wip_id number) is
  SELECT XMLELEMENT("METER",XMLFOREST(
        CTL.NAME as "COUNTERNAME",
        NVL(CTL2.NAME,CTL.NAME) as "SOURCECOUNTERNAME",
        NVL(CBS.COUNTER_TYPE,CB.COUNTER_TYPE) as "COUNTERTYPE",
        NVL(CCR2.COUNTER_READING,CCR1.COUNTER_READING) as "LASTREADING",
        fnd_date.date_to_displayDT(Convert_to_client_time(NVL(CCR2.VALUE_TIMESTAMP,CCR1.VALUE_TIMESTAMP))) as "LASTVALUETIMESTAMP",
        CB.uom_code as "METERUOM",
        TO_NUMBER(NULL) as "NEWREADING",
        EAM_METERS_UTIL.IS_METER_READING_MANDATORY_V(p_wip_id, nvl(CBS.COUNTER_ID,CB.COUNTER_ID)) as "MANDATORY" )) Meter
    FROM csi_counters_b CB,
        CSI_COUNTERS_TL CTL,
        CSI_COUNTERS_TL CTL2,
        CSI_COUNTERS_B CBS,
        CSI_COUNTER_READINGS CCR1,
        CSI_COUNTER_READINGS CCR2,
        csi_item_instances cii,
        wip_discrete_jobs wdj,
        (
        SELECT
            *
        FROM csi_counter_associations
        WHERE sysdate BETWEEN nvl(start_date_Active,sysdate-1) AND nvl(end_date_active,sysdate+1)
        )
        CCA,
        (
        SELECT
            *
        FROM csi_counter_relationships
        WHERE sysdate BETWEEN nvl(Active_end_date,sysdate-1) AND nvl(active_end_date,sysdate+1)
        )
        CCR
    WHERE
        CB.COUNTER_ID=CCA.COUNTER_ID(+)
        AND CB.COUNTER_ID=CTL.COUNTER_ID
        AND CCR.OBJECT_COUNTER_ID(+)=CB.COUNTER_ID
        AND CCR.SOURCE_COUNTER_ID=CBS.COUNTER_ID(+)
        AND CBS.COUNTER_ID=CTL2.COUNTER_ID(+)
        AND CTL.LANGUAGE=USERENV('LANG')
        AND CTL2.LANGUAGE(+)=USERENV('LANG')
        AND CB.COUNTER_TYPE='REGULAR'
        AND CBS.COUNTER_TYPE(+)='REGULAR'
        AND CB.COUNTER_ID=CCR1.COUNTER_ID(+)
        AND CCR1.DISABLED_FLAG(+)='N'
        AND wdj.maintenance_object_id=cii.instance_id
	    AND wdj.maintenance_object_type=3
	    AND cca.source_object_id = cii.instance_id
	    AND wdj.wip_entity_id=p_wip_id
        AND
        (
            CCR1.VALUE_TIMESTAMP =
            (
            SELECT
                MAX(VALUE_TIMESTAMP)
            FROM CSI_COUNTER_READINGS B
            WHERE CCR1.COUNTER_ID=B.COUNTER_ID
                AND B.DISABLED_FLAG='N'
            GROUP BY COUNTER_ID
            )
            OR NOT EXISTS
            (
            SELECT
                COUNTER_ID
            FROM CSI_COUNTER_READINGS B
            WHERE CB.COUNTER_ID=B.COUNTER_ID
                AND B.DISABLED_FLAG='N'
            )
        )
        AND CBS.COUNTER_ID=CCR2.COUNTER_ID(+)
        AND
        (
            CCR2.VALUE_TIMESTAMP =
            (
            SELECT
                MAX(VALUE_TIMESTAMP)
            FROM CSI_COUNTER_READINGS B
            WHERE CCR2.COUNTER_ID=B.COUNTER_ID
                AND B.DISABLED_FLAG='N'
            GROUP BY COUNTER_ID
            )
            OR NOT EXISTS
            (
            SELECT
                COUNTER_ID
            FROM CSI_COUNTER_READINGS B
            WHERE CBS.COUNTER_ID=B.COUNTER_ID
                AND B.DISABLED_FLAG='N'
            )
        )
        AND CCR2.DISABLED_FLAG(+)='N';


--Cursor for Quality Plan
 cursor qualityplan_cursor(p_quality_flag int, p_organization_id number,p_wip_entity_name varchar2 , p_asset_group varchar2,
  p_instance_number varchar2,p_serial_number varchar2,p_asset_activity varchar2) is
  Select XMLFOREST(
    qpv.plan_id as "PLANID",
    ml.meaning as "PLANMANDATORY",
	qpv.DESCRIPTION as "PLANDESCRIPTION",
	qpv.NAME as "PLANNAME",
	qpv.plan_type_meaning as "PLANTYPE") QualityPlan
  FROM
    QA_PLANS_VAL_V qpv,
	qa_plan_transactions qpt,
	mfg_lookups ml
  Where qpt.plan_id=qpv.plan_id
    and ml.lookup_code=qpt.mandatory_collection_flag
    and ml.lookup_type='SYS_YES_NO'
    and nvl(p_quality_flag,2)=decode(p_quality_flag,1,qpt.mandatory_collection_flag,2,p_quality_flag,2)
    and decode(qpt.transaction_number,31,qa_web_txn_api.plan_applies(qpv.plan_id,qpt.transaction_number,to_char(p_organization_id),
    p_asset_group,p_serial_number,p_asset_activity,p_wip_entity_name,'',p_instance_number,'','','','','EAM'),'N')='Y';

 --Cursor for Quality Plan Elements
 cursor qplanelement_cursor(p_plan_id number) is
  select XMLELEMENT("ELEMENTNAME",q.prompt ) QPlanElement
  from  QA_PLAN_CHARS q
  where q.plan_id=p_plan_id;

 --Cursor for Asset BOM
 cursor assetbom_cursor(p_wip_id in number) is
 select XMLELEMENT("ITEM",XMLFOREST(msik.concatenated_segments as "COMPONENTITEM",
	   msik.description as "DESCRIPTION",
	   bic.component_quantity as "QUANTITY",
	   msik.primary_uom_code as "UOM",
	   lu.meaning as "SUPPLYTYPE")) AssetBom
    from bom_inventory_components bic,
	 mtl_system_items_kfv msik,
	 wip_discrete_jobs wdj,
         csi_item_instances cii,
	 bom_bill_of_materials bbom,
	 mfg_lookups lu
    where bic.effectivity_date <= sysdate
      and (bic.disable_date >= sysdate or
	   bic.disable_date is null)
      and wdj.maintenance_object_id = cii.instance_id
      and wdj.maintenance_object_type=3
      and wdj.wip_entity_id =p_wip_id
      and cii.inventory_item_id = bbom.assembly_item_id
      and wdj.organization_id = bbom.organization_id
      and bic.bill_sequence_id=bbom.common_bill_sequence_id
      and bic.component_item_id=msik.inventory_item_id
      and msik.organization_id=wdj.organization_id
      and lu.lookup_type(+) = 'EAM_CONSTANTS.G_SUPPLY_TYPE'
      and lu.lookup_code(+) = bic.wip_supply_type
      and (wdj.rebuild_item_id is not null OR
               ((NVL(bic.from_end_item_unit_number,'0') = '0') OR bic.from_end_item_unit_number <= cii.serial_number)
                          and    ( bic.to_end_item_unit_number >=cii.serial_number or NVL(bic.to_end_item_unit_number,'0')='0')
           )

 union all

   select XMLELEMENT("ITEM",XMLFOREST(msik.concatenated_segments as "COMPONENTITEM",
	   msik.description as "DESCRIPTION",
	   bic.component_quantity as "QUANTITY",
	   msik.primary_uom_code as "UOM",
	   lu.meaning as "SUPPLYTYPE")) AssetBom
    from bom_inventory_components bic,
	 mtl_system_items_kfv msik,
	 wip_discrete_jobs wdj,
	 bom_bill_of_materials bbom,
	 mfg_lookups lu
     where bic.effectivity_date <= sysdate
      and (bic.disable_date >= sysdate or
	   bic.disable_date is null)
      and wdj.wip_entity_id =p_wip_id
      and wdj.maintenance_object_type=2
      and wdj.maintenance_object_id = bbom.assembly_item_id
      and wdj.organization_id = bbom.organization_id
      and bic.bill_sequence_id = bbom.common_bill_sequence_id
      and bic.component_item_id=msik.inventory_item_id
      and wdj.organization_id = msik.organization_id
      and lu.lookup_type(+) = 'EAM_CONSTANTS.G_SUPPLY_TYPE'
      and lu.lookup_code(+) = bic.wip_supply_type;

--begin changes for FP 7493388 (base bug 7005666)
--cursor for Asset Route

cursor assetroutecomp_cursor(l_serial_number  varchar2,l_inventory_id number) is
SELECT XMLELEMENT("ASSETROUTECOMP", XMLFOREST(
	  R_components_name as "ASSET_NUMBER",
	  R_component_group as "ASSET_GROUP",
	  R_component_description as "DESCRIPTION",
	  area  as "AREA")) AssetRoutecomp
 from	  (select  mena.network_serial_number R_asset_number,
msn1.concatenated_segments R_asset_group,
mena.serial_number R_components_name,
msn2.concatenated_segments  R_component_group,
msn2.descriptive_text  R_component_description,
msn2.area area,
mena.network_item_id   R_asset_group_id,
mena.organization_id  R_asset_org_id
 from
 mtl_eam_network_assets_v  mena
, mtl_eam_asset_numbers_v  msn1
, mtl_eam_asset_numbers_v msn2
,csi_item_instances cii
where
mena.organization_id=msn1.current_organization_id
and mena.network_item_id=msn1.inventory_item_id
and mena.network_serial_number=msn1.serial_number
and mena.organization_id=msn2.current_organization_id
and mena.inventory_item_id=msn2.inventory_item_id
and mena.serial_number=msn2.serial_number
AND mena.network_object_id = cii.instance_id
AND cii.instance_number=l_instance_number
order by mena.serial_number)  ;

--end changes for FP 7493388 (base bug 7005666)


-- Cursor for Safety Permit
CURSOR workpermit_cursor(p_wip_id NUMBER,p_org_id NUMBER)
IS
  SELECT XMLELEMENT("WORKPERMIT",
  XMLFOREST(EWP.PERMIT_NAME AS permitName,
    ml.meaning AS permitType, EWP.DESCRIPTION AS permitDesc,
    EPSV.PERMIT_STATUS AS permitStatus,
    fnd_date.date_to_displayDT(Convert_to_client_time(EWP.VALID_FROM)) AS permitValidFrom,
    fnd_date.date_to_displayDT(Convert_to_client_time(EWP.VALID_TO)) AS permitValidTo
    )) workpermit
  FROM EAM_WORK_PERMITS EWP,
    EAM_SAFETY_ASSOCIATIONS ESA,
    EAM_PERMIT_STATUSES_VL EPSV,
    mfg_lookups ml
  WHERE EWP.PERMIT_ID     = ESA.SOURCE_ID
  AND ESA.TARGET_REF_ID   =p_wip_id
  AND EWP.ORGANIZATION_ID =p_org_id
  AND EPSV.STATUS_ID      =EWP.USER_DEFINED_STATUS_ID
  AND ml.lookup_type (+) = 'EAM_WORK_PERMIT_TYPE'
  AND ml.lookup_code=ewp.permit_type;


BEGIN

for i in p_wip_entity_id.FIRST..p_wip_entity_id.LAST
 loop

  select wdj.organization_id into l_org_id
  from wip_discrete_jobs wdj
  where wdj.wip_entity_id=p_wip_entity_id(i);

  --begin changes for FP 7493388 (base bug 7005666)

  select Nvl(wdj.ASSET_NUMBER,wdj.REBUILD_SERIAL_NUMBER),Nvl(wdj.ASSET_GROUP_ID,REBUILD_ITEM_ID) into l_serial_number ,l_inventory_id
  from wip_discrete_jobs wdj
  where wdj.wip_entity_id=p_wip_entity_id(i);


 SELECT nvl(instance_number,'hghg') into l_instance_number
 FROM eam_work_orders_v
 WHERE  wip_entity_id=p_wip_entity_id(i);

--Exception block added for bug 7758322
 BEGIN
 SELECT NETWORK_ASSET_FLAG into l_asset_route_flag
 FROM csi_item_instances
 WHERE INSTANCE_NUMBER = l_instance_number
 AND INVENTORY_ITEM_ID = l_inventory_id
 AND SERIAL_NUMBER = l_serial_number;

 EXCEPTION
   WHEN No_Data_Found THEN
       l_asset_route_flag:='N';
 END;

--end changes for FP 7493388 (base bug 7005666)
-- changes for FP 7658452

	 l_xmlTypeParamList := xmltype('<PARAM_LIST>
 	 <OP_PARAM>'|| p_operation_flag || '</OP_PARAM>
 	 <INV_PARAM>' || p_material_flag|| '</INV_PARAM>
 	 <DIRECT_PARAM>' ||p_direct_material_flag|| '</DIRECT_PARAM>
 	 <RES_PARAM>' ||p_resource_flag|| '</RES_PARAM>
 	 <WOREQ_PARAM>' ||p_work_request_flag|| '</WOREQ_PARAM>
 	 <METER_PARAM>' ||p_meter_flag|| '</METER_PARAM>
 	 <PLAN_PARAM>' ||p_quality_plan_flag|| '</PLAN_PARAM>
 	 <SHORTATTACH_PARAM>' ||p_short_attachment_flag|| '</SHORTATTACH_PARAM>
 	 <LONGATTACH_PARAM>' ||p_long_attachment_flag|| '</LONGATTACH_PARAM>
 	 <FILEATTACH_PARAM>' ||p_file_attachment_flag|| '</FILEATTACH_PARAM>
 	 <BOM_PARAM>' ||p_asset_bom_flag|| '</BOM_PARAM>
   <PERMITS_PARAM>' ||p_safety_permit_flag|| '</PERMITS_PARAM>
 	 </PARAM_LIST>');

-- end changes for FP 7658452

--Adding Operations

  if p_operation_flag = 1 then
   begin
     for operation_record in operation_cursor(p_wip_entity_id(i)) loop
       select XMLConcat(l_xmlTypeOperation,operation_record.Operation) into l_xmlTypeOperation from dual;
     end loop;
    select XMLELEMENT("OPERATION_LIST",l_xmlTypeOperation) into l_xmlTypeOperation from dual;
   exception
   when  NO_DATA_FOUND then
    null;
   end;
 end if;

--Adding Materials
  if p_material_flag = 1 then
   begin
     for material_record in material_cursor(p_wip_entity_id(i)) loop
       select XMLConcat(l_xmlTypeMaterial,material_record.Material) into l_xmlTypeMaterial from dual;
     end loop;
     select XMLELEMENT("MATERIAL_LIST",l_xmlTypeMaterial) into l_xmlTypeMaterial from dual;
   exception
   when  NO_DATA_FOUND then
    null;
   end;
  end if;

--Adding Resources
  if p_resource_flag = 1 then
   begin
     for resource_record in resource_cursor(p_wip_entity_id(i)) loop
       select XMLConcat(l_xmlTypeResource,resource_record.Resources) into l_xmlTypeResource from dual;
     end loop;
     select XMLELEMENT("RESOURCE_LIST",l_xmlTypeResource) into l_xmlTypeResource from dual;
   --Adding Employees
   for employee_record in employee_cursor(p_wip_entity_id(i)) loop
     select XMLConcat(l_xmlTypeEmployee,employee_record.Employees) into l_xmlTypeEmployee from dual;
   end loop;
     select XMLELEMENT("EMPLOYEE_LIST",l_xmlTypeEmployee) into l_xmlTypeEmployee from dual;
     select XMLConcat(l_xmlTypeResource,l_xmlTypeEmployee) into l_xmlTypeResource from dual;
   exception
   when  NO_DATA_FOUND then
    null;
   end;
  end if;

--Adding Direct Materials
  if p_direct_material_flag = 1 then
   begin
     for directmaterial_record in directmaterial_cursor(p_wip_entity_id(i)) loop
       select XMLConcat(l_xmlTypeDirectMaterial,directmaterial_record.DirectMaterial) into l_xmlTypeDirectMaterial from dual;
     end loop;
     select XMLELEMENT("DIRECTMATERIAL_LIST",l_xmlTypeDirectMaterial) into l_xmlTypeDirectMaterial from dual;
   exception
   when  NO_DATA_FOUND then
    null;
   end;
  end if;

--Adding Work Order Short Text Attachments
 if p_short_attachment_flag =1 then
   begin
    for attachment_record in shortattachment_cursor(p_wip_entity_id(i),l_org_id) loop
      select XMLConcat(l_xmlTypeShortAttachment,attachment_record.ShortAttachment) into l_xmlTypeShortAttachment from dual;
    end loop;
    select XMLELEMENT("WOSHORTATTACHMENT_LIST",l_xmlTypeShortAttachment) into l_xmlTypeShortAttachment from dual;
   exception
   when  NO_DATA_FOUND then
     null;
   end;

--Adding Operation Short Text Attachments
  begin
   for opattachment_record in opshortattachment(p_wip_entity_id(i),l_org_id) loop
     select XMLConcat(l_xmlTypeOpShortAttachment,opattachment_record.OpShortAttachment) into l_xmlTypeOpShortAttachment from dual;
   end loop;
   select XMLELEMENT("OPSHORTATTACHMENT_LIST",l_xmlTypeOpShortAttachment) into l_xmlTypeOpShortAttachment from dual;
   select XMLConcat(l_xmlTypeShortAttachment,l_xmlTypeOpShortAttachment) into l_xmlTypeShortAttachment from dual;
  exception
  when  NO_DATA_FOUND then
     null;
  end;
 end if;

 --Adding Work Order Long Text Attachments
 if p_long_attachment_flag =1 then
   begin
    for longattachment_record in longattachment_cursor(p_wip_entity_id(i),l_org_id) loop
      select longattachment_record.LongAttachment into l_xmlTemp from dual;
      select extractValue(l_xmlTemp,'/ALONGMEDIAID') into l_media_id  from dual;
      l_temp:=getLong(p_wip_entity_id(i),l_org_id,l_media_id,1);
      select XMLConcat(l_xmlTemp,xmlType('<ALONGTEXT>'||l_temp||'</ALONGTEXT>')) into l_xmlTemp from dual;
      select XMLELEMENT("LONGATTACHMENT",l_xmlTemp) into l_xmlTemp from dual;
      select XMLConcat(l_xmlTemp,l_xmlTypeLongAttachment) into l_xmlTypeLongAttachment from dual;
      l_xmlTemp:=null;
    end loop;
    select XMLELEMENT("WOLONGATTACHMENT_LIST",l_xmlTypeLongAttachment) into l_xmlTypeLongAttachment from dual;
   exception
   when  NO_DATA_FOUND then
     null;
   end;

--Adding Operation Long Text Attachments
   begin
     for oplongattachment_record in oplongattachment_cursor(p_wip_entity_id(i),l_org_id) loop
      select oplongattachment_record.OpLongAttachment into l_xmlTemp from dual;
      select extractValue(l_xmlTemp,'/OPALONGMEDIAID') into l_media_id  from dual;
      l_temp:=getLong(p_wip_entity_id(i),l_org_id,l_media_id,2);
      select XMLConcat(l_xmlTemp,xmlType('<OPALONGTEXT>'||l_temp||'</OPALONGTEXT>')) into l_xmlTemp from dual;
      select XMLELEMENT("OPLONGATTACHMENT",l_xmlTemp) into l_xmlTemp from dual;
      select XMLConcat(l_xmlTemp,l_xmlTypeOpLongAttachment) into l_xmlTypeOpLongAttachment from dual;
      l_xmlTemp:=null;
    end loop;
      select XMLELEMENT("OPLONGATTACHMENT_LIST",l_xmlTypeOpLongAttachment) into l_xmlTypeOpLongAttachment from dual;
      select XMLConcat(l_xmlTypeLongAttachment,l_xmlTypeOpLongAttachment) into l_xmlTypeLongAttachment from dual;
   exception
   when  NO_DATA_FOUND then
     null;
   end;
 end if;

--Adding File Attachments
 if p_file_attachment_flag = 1 then
   begin
     for fileattachment_record in fileattachment_cursor(p_wip_entity_id(i),l_org_id) loop
       select XMLConcat(l_xmlTypefileattachment,fileattachment_record.FileAttachment) into l_xmlTypefileattachment from dual;
     end loop;
     select XMLELEMENT("FILEATTACHMENT_LIST",l_xmlTypefileattachment) into l_xmlTypefileattachment from dual;
   exception
   when  NO_DATA_FOUND then
    null;
   end;
  end if;

--Adding Work Request
  if p_work_request_flag =1 then
    begin
     for workrequest_record in workrequest_cursor(p_wip_entity_id(i),l_org_id) loop
       select XMLConcat(l_xmlTypeWorkRequest,workrequest_record.WorkRequest) into l_xmlTypeWorkRequest from dual;
     end loop;
     select XMLELEMENT("WORKREQUEST_LIST",l_xmlTypeWorkRequest) into l_xmlTypeWorkRequest from dual;
    exception
    when  NO_DATA_FOUND then
      null;
    end;
  end if;


--Adding Meters
  if p_meter_flag =1 then
    begin
     for meter_record in meter_cursor(p_wip_entity_id(i)) loop
       select XMLConcat(l_xmlTypeMeter,meter_record.Meter) into l_xmlTypeMeter from dual;
     end loop;
     select XMLELEMENT("METER_LIST",l_xmlTypeMeter) into l_xmlTypeMeter from dual;
    exception
    when  NO_DATA_FOUND then
      null;
    end;
  end if;

--Adding Quality Plan
 if p_quality_plan_flag =1 or p_quality_plan_flag=2 then
   begin
     select we.wip_entity_name,
     wdj.organization_id,
     msi.concatenated_segments,
     cii.instance_number,cii.serial_number into l_wip_entity_name,l_organization_id,l_asset_group,l_instance_number,l_serial_number
    from  wip_discrete_jobs wdj,
     csi_item_instances cii,
     mtl_system_items_b_kfv msi,
     wip_entities we
    where wdj.wip_entity_id=p_wip_entity_id(i)
     and wdj.wip_entity_id=we.wip_entity_id
     and cii.instance_id(+) = DECODE(wdj.maintenance_object_type,3,wdj.maintenance_object_id,NULL)
     and nvl(wdj.asset_group_id,wdj.rebuild_item_id) = msi.inventory_item_id
     and wdj.organization_id=msi.organization_id;

    begin
     select msi.concatenated_segments  into l_asset_activity
     from mtl_system_items_b_kfv msi,
      wip_discrete_jobs wdj
     where wdj.primary_item_id=msi.inventory_item_id and
      wdj.organization_id=msi.organization_id and
      wdj.wip_entity_id=p_wip_entity_id(i) ;
    exception
    when no_data_found then
     null;
    end;

   for qualityplan_record in qualityplan_cursor(p_quality_plan_flag,l_organization_id,l_wip_entity_name,l_asset_group,l_instance_number,l_serial_number,l_asset_activity) loop
      select XMLConcat(l_xmlTypeQualityPlan,qualityplan_record.QualityPlan) into l_xmlTypeQualityPlan from dual;
      select extractValue(l_xmlTypeQualityPlan,'/PLANID') into l_plan_id  from dual;
      l_xmlTemp2 := null;
      for qplanelement_record in qplanelement_cursor(l_plan_id) loop
        select qplanelement_record.QPlanElement into l_xmlTemp from dual;
        select XMLConcat(l_xmlTemp,xmlType('<VALUE>  </VALUE>')) into l_xmlTemp from dual;
        select XMLELEMENT("ELEMENT",l_xmlTemp) into l_xmlTemp from dual;
        select XMLConcat(l_xmlTemp2,l_xmlTemp) into l_xmlTemp2 from dual;
      end loop;
      select XMLELEMENT("ELEMENT_LIST",l_xmlTemp2) into l_xmlTemp2 from dual;
      select XMLConcat(l_xmlTypeQualityPlan,l_xmlTemp2) into l_xmlTypeQualityPlan from dual;
      select XMLELEMENT("QUALITYPLAN",l_xmlTypeQualityPlan) into l_xmlTypeQualityPlan from dual;
	  --changed bug fix 8289633
 	  SELECT XMLConcat(l_xmlTemp4,l_xmlTypeQualityPlan)INTO l_xmlTemp4 FROM dual;
 	  l_xmlTypeQualityPlan:=NULL;
   end loop;
      select XMLELEMENT("QUALITYPLAN_LIST",l_xmlTemp4) into l_xmlTypeQualityPlan from dual;
 	  --end of change bug fix 8289633

   exception
   when  NO_DATA_FOUND then
     null;
   end;
 end if;

 --Adding Asset BOM
  if p_asset_bom_flag =1 then
    begin
     for assetbom_record in assetbom_cursor(p_wip_entity_id(i)) loop
       select XMLConcat(l_xmlTypeAssetBom,assetbom_record.AssetBom) into l_xmlTypeAssetBom from dual;
     end loop;
     select XMLELEMENT("ASSETBOM_LIST",l_xmlTypeAssetBom) into l_xmlTypeAssetBom from dual;
    exception
    when  NO_DATA_FOUND then
      null;
    end;
  end if;

--begin changes for FP 7493388 (base bug 7005666)
  --Adding Asset route components
  if l_asset_route_flag = 'Y' then
   begin

     for asset_route_record in assetroutecomp_cursor(l_serial_number,l_inventory_id) loop
      select XMLConcat(l_xmlTypeAssetroutecomp,asset_route_record.AssetRoutecomp) into l_xmlTypeAssetroutecomp from dual;
     end loop;
     select XMLELEMENT("ASSETROUTECOMP_LIST",l_xmlTypeAssetroutecomp) into l_xmlTypeAssetroutecomp from dual;
   exception
   when  NO_DATA_FOUND then
    null;
   end;
  end if;
--end changes for FP 7493388 (base bug 7005666)

 --begin adding safety permit
  if p_safety_permit_flag = 1 then
   begin
     for permits_record in workpermit_cursor(p_wip_entity_id(i),l_org_id) loop
      select XMLConcat(l_xmlTypePermits,permits_record.workpermit) into l_xmlTypePermits from dual;
     end loop;
     select XMLELEMENT("WORKPERMIT_LIST",l_xmlTypePermits) into l_xmlTypePermits from dual;
   exception
   when  NO_DATA_FOUND then
    null;
   end;
  end if;
--end adding safety permit


--Adding Failure Data
  begin
   select XMLELEMENT("FAILUREDATA",XMLFOREST(ewod.failure_code_required as "CODEREQUIRED",
   fnd_date.date_to_displayDT(Convert_to_client_time(eaf.failure_date)) as "FAILUREDATE",
   eafc.failure_code as "FAILURECODE",
   eafc.cause_code as "CAUSECODE",
   eafc.resolution_code as "RESOLUTIONCODE",
   efs.set_name as "SETNAME",
   eafc.comments as "COMMENTS")) into l_xmlTypeFailureData
   from eam_asset_failures eaf,
   eam_asset_failure_codes eafc,
   eam_work_order_details ewod,
   wip_discrete_jobs wdj,
   eam_failure_set_associations easa,
   eam_failure_sets efs
   where wdj.wip_entity_id =eaf.source_id and
   eaf.source_type=1 and
   eaf.failure_id =eafc.failure_id and
   wdj.wip_entity_id= ewod.wip_entity_id and
   easa.inventory_item_id(+)=nvl(wdj.asset_group_id,wdj.rebuild_item_id)  and
   efs.set_id(+)=easa.set_id and
   wdj.wip_entity_id=p_wip_entity_id(i);
  exception
  WHEN  OTHERS THEN
   null;
  end;

--Main Work Order Header

 --Adding PM Base Meter Name
  begin
  select XMLFOREST(ewod.warranty_active as "WARRANTYACTIVE",cct.name as "PMBASEMETER") into l_xmlTemp3
  from eam_work_order_details ewod,csi_counters_tl cct
  where ewod.wip_entity_id=p_wip_entity_id(i)
  and ewod.pm_base_meter=cct.counter_id
  and cct.language=userenv('Lang');
  exception
  when  NO_DATA_FOUND then
   null;
  end;

  --Adding Warranty Expiration Date
  begin
  select XMLConcat(XMLELEMENT("WARRANTYEXPDATE",fnd_date.date_to_displayDT(Convert_to_client_time(csi.SUPPLIER_WARRANTY_EXP_DATE))),l_xmlTemp3) into l_xmlTemp3
  from csi_item_instances csi, wip_discrete_jobs wdj
  where wdj.maintenance_object_id=csi.instance_id
  and wdj.maintenance_object_type=3
  and wdj.wip_entity_id=p_wip_entity_id(i);
  exception
  when  NO_DATA_FOUND then
   null;
  end;

  --Adding Actual Start Date and Actual End Date
  begin
  SELECT XMLConcat(XMLFOREST(fnd_date.date_to_displayDT(Convert_to_client_time(ACTUAL_START_DATE)) as "ACTUALSTARTDATE", fnd_date.date_to_displayDT(Convert_to_client_time(ACTUAL_END_DATE)) as "ACTUALENDDATE",
  round((ACTUAL_END_DATE-ACTUAL_START_DATE)*24,2) as "ACTUALDURATION"),l_xmlTemp3) into l_xmlTemp3
  FROM EAM_JOB_COMPLETION_TXNS
  WHERE TRANSACTION_TYPE=1
  AND TRANSACTION_ID=
        (
        SELECT MAX(TRANSACTION_ID)
        FROM EAM_JOB_COMPLETION_TXNS EJT,WIP_DISCRETE_JOBS WDJ
        WHERE EJT.WIP_ENTITY_ID=WDJ.WIP_ENTITY_ID
        AND EJT.ORGANIZATION_ID=WDJ.ORGANIZATION_ID
        AND WDJ.WIP_ENTITY_ID=p_wip_entity_id(i)
        );
  exception
  when  NO_DATA_FOUND then
   null;
  end;


  --Adding Asset Group Description
  begin
  select XMLConcat(XMLELEMENT("ASSETGRPDESC",msi.description),l_xmlTemp3) into l_xmlTemp3
  from mtl_system_items_kfv msi, wip_discrete_jobs wdj
  where nvl(wdj.asset_group_id,wdj.rebuild_item_id)=msi.inventory_item_id
  and wdj.organization_id=msi.organization_id
  and wdj.wip_entity_id=p_wip_entity_id(i);
  exception
  when  NO_DATA_FOUND then
   null;
  end;

  --Adding Area Info
  begin
  select XMLConcat(XMLFOREST(mel.location_codes as "AREA" ,mel.description as "AREADESC"),l_xmlTemp3) into l_xmlTemp3
  from eam_org_maint_defaults eomd, mtl_eam_locations mel, wip_discrete_jobs wdj
  where eomd.object_id = wdj.maintenance_object_id
  and eomd.object_type = 50
  and eomd.organization_id =wdj.organization_id
  and wdj.wip_entity_id=p_wip_entity_id(i)
  and eomd.area_id=mel.location_id;
  exception
  when  NO_DATA_FOUND then
   null;
  end;

  select XMLConcat(l_xmlType,
   XMLELEMENT("WORKORDER",XMLATTRIBUTES(wewdv.wip_entity_id as "WIPENTITYID"),
   XMLFOREST(wewdv.wip_entity_name as "NAME",
   wewdv.description as "DESCRIPTION",
   wewdv.work_order_status as "STATUS",
   wewdv.asset_description as "ASSETDESC",
   wewdv.priority_disp as "PRIORITY",
   wewdv.class_code as "CLASSCODE",
   wewdv.instance_number as "ASSETNUMBER",
   flm1.meaning as "PENDING",
   wewdv.shutdown_type_disp as "SHUTDOWNTYPE",
   wewdv.asset_rebuild_group as "ASSETGROUP",
   wewdv.rebuild_serial_number as "REBSERIALNO",
   msi.concatenated_segments as "ACTIVITY",
   msi.description as "ACTIVITYDESC",
   wewdv.activity_type_disp as "ACTIVITYTYPE",
   wewdv.activity_cause_disp as "ACTIVITYCAUSE",
   wewdv.activity_source_meaning as "ACTIVITYSOURCE",
   wewdv.warranty_claim_status as "WARRANTY",
   wewdv.parent_wip_entity_name as "PARENTNAME",
   flm4.meaning as "NOTIFICATION",
   flm3.meaning  as "TAGOUT",
   flm5.meaning as "PLANNED",
   wewdv.project_name as "PROJECTNAME",
   wewdv.task_name as "TASKNAME",
   fnd_date.date_to_displayDT(Convert_to_client_time(wewdv.pm_suggested_start_date)) as "PMSTARTDATE",
   fnd_date.date_to_displayDT(Convert_to_client_time(wewdv.pm_suggested_end_date)) as "PMENDDATE",
   flm2.meaning as "MATISSUEREQUEST",
   lu1.meaning as "FIRM",
   lu2.meaning as "MATSHORTAGE",
   fnd_date.date_to_displayDT(Convert_to_client_time(wewdv.material_shortage_check_date)) as "ASOFDATE",
   wewdv.owning_department_code as "DEPARTMENT",
   wewdv.work_order_type_disp as "WOTYPE",
   fnd_date.date_to_displayDT(Convert_to_client_time(wewdv.scheduled_start_date)) as "STARTDATE",
   fnd_date.date_to_displayDT(Convert_to_client_time(wewdv.scheduled_completion_date)) as "ENDDATE",
   round((wewdv.scheduled_completion_date-wewdv.scheduled_start_date)*24,2) as "SCHEDULEDDURATION",
   eps.name as "PMNAME",
   fnd_date.date_to_displayDT(Convert_to_client_time(eps.base_date)) as "BASEDATE",
   bd.description as "DEPTDESCRIPTION"),
   XMLConcat(l_xmlTemp3,l_xmlTypeFailureData,l_xmlType1,l_xmlTypeOperation,l_xmlTypeMaterial,l_xmlTypeResource,l_xmlTypeDirectMaterial,l_xmlTypeShortAttachment,
   l_xmlTypeLongAttachment,l_xmlTypefileattachment,l_xmlTypeWorkRequest,l_xmlTypeMeter,l_xmlTypeQualityPlan,l_xmlTypeAssetBom,l_xmlTypeAssetroutecomp,l_xmlTypePermits,l_xmlTypeParamList))) AS "RESULT" into l_xmlType
    from eam_work_orders_v wewdv ,mtl_system_items_b_kfv msi,eam_pm_schedulings eps,bom_departments bd,mfg_lookups lu1,mfg_lookups lu2
   ,fnd_common_lookups flm1,fnd_common_lookups flm2,fnd_common_lookups flm3,fnd_common_lookups flm4 ,fnd_common_lookups flm5
   where wewdv.wip_entity_id=p_wip_entity_id(i)
   and msi.inventory_item_id(+)= wewdv.primary_item_id
   and msi.organization_id(+)=wewdv.organization_id
   and lu1.lookup_code(+)=wewdv.firm_planned_flag
   and lu1.lookup_type(+)='SYS_YES_NO'
   and lu2.lookup_code(+)=wewdv.material_shortage_flag
   and lu2.lookup_type(+)='SYS_YES_NO'
   and eps.pm_schedule_id(+)=wewdv.pm_schedule_id
   and bd.department_id(+)=wewdv.owning_department
   and flm1.lookup_type(+) = 'EAM_YES_NO'
   and flm1.lookup_code(+)=wewdv.pending_flag
   and flm2.lookup_type(+) = 'EAM_YES_NO'
   and flm2.lookup_code(+)=wewdv.material_issue_by_mo
   and flm3.lookup_type(+) = 'EAM_YES_NO'
   and flm3.lookup_code(+)=wewdv.tagout_required
   and flm4.lookup_type(+) = 'EAM_YES_NO'
   and flm4.lookup_code(+)=wewdv.notification_required
   and flm5.lookup_type(+) = 'EAM_YES_NO'
   and flm5.lookup_code(+)=wewdv.plan_maintenance;

   l_xmlTypeOperation:=null;
   l_xmlTypeMaterial:=null;
   l_xmlTypeResource:=null;
   l_xmlTypeEmployee:=null;
   l_xmlTypeDirectMaterial:=null;
   l_xmlTypeShortAttachment:=null;
   l_xmlTypeOpShortAttachment:=null;
   l_xmlTypeOpLongAttachment:=null;
   l_xmlTypeLongAttachment:=null;
   l_xmlTypefileattachment:=null;
   l_xmlTypeWorkRequest:=null;
   l_xmlTypeMeter:=null;
   l_xmlTypeQualityPlan:=null;
   l_xmlTypeAssetBom:=null;
   l_xmlTypeFailureData:=null;
   l_xmlTemp3:=null;
   l_xmlTypeAssetroutecomp:=null;
   l_xmlTypePermits :=NULL; --permit safety report
 end loop;

 select XMLELEMENT("WORKORDER_LIST", l_xmlType) into l_xmlType from dual;

 return l_xmlType.getClobVal();
-- End of API body.


END getWoReportXML;

--Function to convert Long data into Clob

Function getLong
(
	p_wip_id in number,
	p_org_id in number,
	p_media_id in number,
	p_select in number


) return CLOB
IS

l_longVal long:=null;
l_lobVal clob;
l_attachmenttype varchar2(50);
BEGIN

	-- API body
   if p_select=1 then
    insert into EAM_WOREP_LONG_ATTACH_TEMP
	(select to_lob(fdlt.long_text)
   from
    FND_DOCUMENTS_LONG_TEXT fdlt,
    fnd_documents_vl fdv,
    fnd_attached_documents fad
   where
    fdlt.media_id = fdv.media_id and
    fad.document_id = fdv.document_id and
    fad.entity_name ='EAM_WORK_ORDERS' and
	fad.pk2_value =to_char(p_wip_id)  and
	fdlt.media_id =to_char(p_media_id) and
	fad.pk1_value = to_char(p_org_id));

	select long_text into l_lobVal from EAM_WOREP_LONG_ATTACH_TEMP ;
	delete from EAM_WOREP_LONG_ATTACH_TEMP;

  else

   insert into EAM_WOREP_LONG_ATTACH_TEMP (select to_lob(fdlt.long_text)
   from
    FND_DOCUMENTS_LONG_TEXT fdlt,
    fnd_documents_vl fdv,
    fnd_attached_documents fad
    where
    fdlt.media_id = fdv.media_id and
    fad.document_id = fdv.document_id and
    fad.entity_name ='EAM_DISCRETE_OPERATIONS'and
	fad.pk1_value = to_char(p_wip_id) and
	fdlt.media_id =to_char(p_media_id) and
	fad.pk3_value =to_char(p_org_id));

	select long_text  into l_lobVal from EAM_WOREP_LONG_ATTACH_TEMP;
	delete from EAM_WOREP_LONG_ATTACH_TEMP;

  end if;
 return l_lobVal;
	-- End of API body.
END getLong;


--Function to covert date from Server Time zone to Client Time Zone

Function Convert_to_client_time (
p_server_time	in 	date
) return date
IS
l_client_tz_id		number;
l_server_tz_id		number;
l_msg_count		number;
l_msg_data		varchar2(2000);
l_client_time           date;
l_status                varchar2(100);
BEGIN
   -- API body
    l_client_tz_id :=         to_number ( fnd_profile.value_specific('CLIENT_TIMEZONE_ID'));
    l_server_tz_id :=         to_number( fnd_profile.value_specific('SERVER_TIMEZONE_ID'));

    HZ_TIMEZONE_PUB.Get_Time(1.0, 'F', l_server_tz_id, l_client_tz_id,    p_server_time,
				 l_client_time, l_status, l_msg_count, l_msg_data);
    return l_client_time;
   -- API body

END;

END EAM_WorkOrderRep_PVT;


/
