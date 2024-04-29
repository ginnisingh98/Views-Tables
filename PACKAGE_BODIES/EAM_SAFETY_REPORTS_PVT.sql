--------------------------------------------------------
--  DDL for Package Body EAM_SAFETY_REPORTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_SAFETY_REPORTS_PVT" AS
/* $Header: EAMVSRPB.pls 120.0.12010000.3 2010/04/27 15:42:37 somitra noship $ */
  /***************************************************************************
  --
  --  Copyright (c) 2010 Oracle Corporation, Redwood Shores, CA, USA
  --  All rights reserved.
  --
  --  FILENAME
  --
  --      EAMVSRPS.pls
  --
  --  DESCRIPTION
  --
  --      BODY of package EAM_SAFETY_REPORTS_PVT
  --
  --  NOTES
  --
  --  HISTORY
  --
  --  07-APRIL-2008    Madhuri Shah     Initial Creation
  ***************************************************************************/
  g_pkg_name CONSTANT VARCHAR2(30):= 'EAM_SAFETY_REPORTS_PVT';


  /********************************************************************
  * Function     : getWorkPermitReportXML
  * Purpose       : This procedure generate xml data for work permits
  *********************************************************************/
FUNCTION getWorkPermitReportXML(
    p_permit_ids           IN eam_permit_tab_type,
    p_file_attachment_flag IN NUMBER,
    p_work_order_flag      IN NUMBER )
  RETURN CLOB

IS

  l_xmlType XMLType               :=NULL;
  l_xmlTypeParamList XMLType      :=NULL;
  l_xmlTypefileattachment XMLType :=NULL;
  l_xmlTypeAssociatedWO XMLType   :=NULL;
  l_xmlTypePermitHeader XMLType   :=NULL;
  l_xmlTypeApprover XMLType       :=NULL;
  l_organization_id NUMBER;


  --Cursor for permit header
  CURSOR PERMIT_HEADER_CURSOR(P_PERMIT_ID NUMBER, P_ORGANIZATION_ID NUMBER)
  IS
     SELECT XMLELEMENT("PERMIT_HEADER",
    XMLFOREST(EWP.PERMIT_NAME AS PERMIT_NAME,
              ml.meaning AS PERMIT_TYPE,
              EWP.DESCRIPTION AS PERMIT_DESC,
              EPSV.PERMIT_STATUS AS PERMIT_STATUS,
              ppf.full_name AS PREPARED_BY,
              fnd_date.date_to_displayDT(Convert_to_client_time(EWP.CREATION_DATE)) AS PREPARED_DATE,
              fnd_date.date_to_displayDT(Convert_to_client_time(EWP.VALID_FROM)) AS PERMIT_VALID_FROM,
              fnd_date.date_to_displayDT(Convert_to_client_time(EWP.VALID_TO)) AS PERMIT_VALID_TO
              ))"PERMIT_HEADER"
    FROM EAM_WORK_PERMITS EWP,
      EAM_PERMIT_STATUSES_VL EPSV,
	  mfg_lookups ml,
      fnd_user fu,
      per_people_f ppf
    WHERE EWP.PERMIT_ID     =P_PERMIT_ID
    AND EWP.ORGANIZATION_ID =P_ORGANIZATION_ID
    AND EPSV.STATUS_ID      =EWP.USER_DEFINED_STATUS_ID
    and EWP.created_by = fu.user_id(+)
    and fu.employee_id = ppf.person_id (+)
	and ml.lookup_type (+) = 'EAM_WORK_PERMIT_TYPE'
    AND ml.lookup_code=ewp.permit_type
	AND Nvl(ppf.effective_end_date,SYSDATE)>=sysdate
    ;

   --Cursor for approvers
  CURSOR APPROVER_CURSOR(P_PERMIT_ID NUMBER, P_ORGANIZATION_ID NUMBER)
  IS
    SELECT XMLELEMENT("APPROVER",
    XMLFOREST(
              ppf.full_name AS APPROVER_NAME)) "APPROVER"
    FROM
	  EAM_WORK_PERMITS EWP,
	  per_people_f ppf ,
      fnd_user fu
    WHERE EWP.PERMIT_ID     =P_PERMIT_ID
    AND EWP.ORGANIZATION_ID =P_ORGANIZATION_ID
    AND EWP.approved_by = fu.user_id(+)
    and fu.employee_id = ppf.person_id (+)
	AND Nvl(ppf.effective_end_date,SYSDATE)>=sysdate;

  --Cursor for work order associations
  CURSOR PERMIT_WORKORDER_CURSOR(P_PERMIT_ID NUMBER, P_ORGANIZATION_ID NUMBER)
  IS
    SELECT XMLELEMENT("WORK_ORDER",
    XMLFOREST(WEDV.WIP_ENTITY_NAME AS WORK_ORDER_NAME,
             WEDV.ASSET_NUMBER AS WO_ASSET_NUMBER,
             ASSET_DESCRIPTION AS WO_ASSET_DESC,
             WEDV.DESCRIPTION AS WO_DESC,
             fnd_date.date_to_displayDT(Convert_to_client_time(WEDV.SCHEDULED_START_DATE)) AS WO_SCHEDULED_START_DATE,
             fnd_date.date_to_displayDT(Convert_to_client_time(WEDV.SCHEDULED_COMPLETION_DATE)) AS WO_SCHEDULED_COMPL_DATE)) "WORK_ORDER"
    FROM EAM_WORK_ORDERS_V WEDV,
      EAM_SAFETY_ASSOCIATIONS ESA
    WHERE ESA.ASSOCIATION_TYPE= 3
    AND ESA.SOURCE_ID         =P_PERMIT_ID
    AND ESA.ORGANIZATION_ID   =P_ORGANIZATION_ID
    AND WEDV.WIP_ENTITY_ID    =ESA.TARGET_REF_ID;



  --Cursor for File Attachments
  CURSOR fileattachment_cursor(p_permit_id NUMBER,p_org_id NUMBER)
  IS
    SELECT XMLELEMENT("FILE_ATTACHMENT",
    XMLFOREST( fdv.file_name AS "FILE_NAME",
              fdv.description AS "FILE_DESC",
              fdv.category_description AS "FILE_CATEGORY")) fileAttachment
    FROM fnd_documents_vl fdv,
      fnd_attached_documents fad
    WHERE fad.document_id      = fdv.document_id
    AND fad.entity_name        = 'EAM_WORK_PERMIT'
    AND fad.pk1_value          =  p_org_id
    AND fad.pk2_value          = p_permit_id
    AND fdv.file_name         IS NOT NULL
    AND fdv.datatype_name NOT IN ('Long Text', 'Short Text');


BEGIN
  FOR i IN p_permit_ids.FIRST..p_permit_ids.LAST
  LOOP
   -- Get org id

     select ewp.organization_id into l_organization_id
     from EAM_WORK_PERMITS ewp
     where ewp.permit_id=p_permit_ids(i).permit_id;

      l_xmlTypeParamList := xmltype('<PARAM_LIST>
      <FILEATTACH_PARAM>' ||Nvl(p_file_attachment_flag,0)|| '</FILEATTACH_PARAM>
      <PERMIT_WO_PARAM>' ||Nvl(p_work_order_flag,0)|| '</PERMIT_WO_PARAM>
      </PARAM_LIST>');

    --Adding Permit Header
    BEGIN
        FOR permit_header_record IN PERMIT_HEADER_CURSOR(p_permit_ids(i).permit_id,l_organization_id)
        LOOP
          SELECT XMLConcat(l_xmlTypePermitHeader,permit_header_record.PERMIT_HEADER)
          INTO l_xmlTypePermitHeader
          FROM dual;
        END LOOP;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
      END;

     -- Adding approver
     BEGIN
        FOR approver_record IN APPROVER_CURSOR(p_permit_ids(i).permit_id,l_organization_id)
        LOOP
          SELECT XMLConcat(l_xmlTypeApprover,approver_record.APPROVER)
          INTO l_xmlTypeApprover
          FROM dual;
        END LOOP;
        SELECT XMLELEMENT("APPROVERS",l_xmlTypeApprover)
        INTO l_xmlTypeApprover
        FROM dual;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
      END;


    --Adding Work Orders
    IF p_work_order_flag = 1 THEN
      BEGIN
        FOR wo_record IN PERMIT_WORKORDER_CURSOR(p_permit_ids(i).permit_id,l_organization_id)
        LOOP
          SELECT XMLConcat(l_xmlTypeAssociatedWO,wo_record.WORK_ORDER)
          INTO l_xmlTypeAssociatedWO
          FROM dual;
        END LOOP;
        SELECT XMLELEMENT("WORK_ORDERS",l_xmlTypeAssociatedWO)
        INTO l_xmlTypeAssociatedWO
        FROM dual;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
      END;
    END IF;


    --Adding File Attachments
    IF p_file_attachment_flag = 1 THEN
      BEGIN
        FOR fileattachment_record IN fileattachment_cursor(p_permit_ids(i).permit_id,l_organization_id)
        LOOP
          SELECT XMLConcat(l_xmlTypefileattachment,fileattachment_record.FileAttachment)
          INTO l_xmlTypefileattachment
          FROM dual;
        END LOOP;
        SELECT XMLELEMENT("FILE_ATTACHMENTS",l_xmlTypefileattachment)
        INTO l_xmlTypefileattachment
        FROM dual;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
      END;
    END IF;

    -- concatinate all xml string into one

   /* SELECT XMLCONCAT(l_xmlType,
    XMLELEMENT("PERMIT_HEADER"
    XMLFOREST(EWP.PERMIT_NAME AS PERMIT_NAME,
              EWP.PERMIT_TYPE AS PERMIT_TYPE,
              EWP.DESCRIPTION AS PERMIT_DESC,
              EPSV.PERMIT_STATUS AS PERMIT_STATUS,
              fnd_date.date_to_displayDT(Convert_to_client_time(EWP.VALID_FROM)) AS PERMIT_VALID_FROM,
              fnd_date.date_to_displayDT(Convert_to_client_time(EWP.VALID_TO)) AS PERMIT_VALID_TO,
              EWP.APPROVED_BY AS approverName),
           XMLConcat(l_xmlTypeAssociatedWO,l_xmlTypefileattachment)))AS "RESULT"
    INTO l_xmlType
    FROM EAM_WORK_PERMITS EWP,
      EAM_PERMIT_STATUSES_VL EPSV
    WHERE EWP.PERMIT_ID     =p_permit_ids(i).permit_id
    AND EWP.ORGANIZATION_ID =l_organization_id
    AND EPSV.STATUS_ID      =EWP.USER_DEFINED_STATUS_ID;*/

    SELECT XMLCONCAT(l_xmlType,
    XMLELEMENT("PERMIT",
    XMLConcat(l_xmlTypePermitHeader,l_xmlTypeApprover,l_xmlTypeAssociatedWO,l_xmlTypefileattachment))) "PERMIT"
    INTO l_xmlType
    FROM dual;

    l_xmlTypefileattachment:=NULL;
    l_xmlTypeAssociatedWO:=NULL;
    l_xmlTypePermitHeader:=NULL;
    l_xmlTypeApprover:=NULL;

  END LOOP;
   SELECT
    XMLELEMENT("PERMITS",
    XMLConcat(l_xmlTypeParamList,l_xmlType)) "PERMITS"
    INTO l_xmlType
    FROM dual;
  --l_xmlType will have all concatenated work permit records
  RETURN l_xmlType.getClobVal();

END getWorkPermitReportXML;

/********************************************************************
* Procedure     : Convert_to_client_time
* Purpose       : This procedure coverts date from Server Time zone to Client Time Zone
*********************************************************************/
FUNCTION Convert_to_client_time(
    p_server_time IN DATE )
  RETURN DATE
IS
  l_client_tz_id NUMBER;
  l_server_tz_id NUMBER;
  l_msg_count    NUMBER;
  l_msg_data     VARCHAR2(2000);
  l_client_time DATE;
  l_status VARCHAR2(100);
BEGIN
  -- API body
  l_client_tz_id := to_number ( fnd_profile.value_specific('CLIENT_TIMEZONE_ID'));
  l_server_tz_id := to_number( fnd_profile.value_specific('SERVER_TIMEZONE_ID'));
  HZ_TIMEZONE_PUB.Get_Time(1.0, 'F', l_server_tz_id, l_client_tz_id, p_server_time, l_client_time, l_status, l_msg_count, l_msg_data);
  RETURN l_client_time;
  -- API body
END;
/********************************************************************
* Procedure     : getWorkClearanceReportXML
* Purpose       : This procedure generate xml data for work clearances
*********************************************************************/
/*Function getWorkClearanceReportXML
( p_work_clearance_id in system.eam_wipid_tab_type,
p_short_attachment_flag in int,
p_long_attachment_flag in int,
p_file_attachment_flag in int,
p_work_request_flag in int,
p_asset_bom_flag in int
)return CLOB
BEGIN
--Logic for handling xml data for Work Clearance will be similar to that  of  the Procedure getWorkPermitReportXML
END getWorkClearanceReportXML; */
END EAM_SAFETY_REPORTS_PVT;

/
