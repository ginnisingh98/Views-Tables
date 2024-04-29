--------------------------------------------------------
--  DDL for Package Body POR_VIEW_REQS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POR_VIEW_REQS_PKG" AS
/* $Header: PORVRQSB.pls 120.20.12010000.5 2010/11/18 09:15:10 rojain ship $ */

  -- Logging Static Variables
  G_CURRENT_RUNTIME_LEVEL      NUMBER;
  G_LEVEL_UNEXPECTED	       CONSTANT NUMBER	     := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR 	       CONSTANT NUMBER	     := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION	       CONSTANT NUMBER	     := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT 	       CONSTANT NUMBER	     := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE	       CONSTANT NUMBER	     := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT	       CONSTANT NUMBER	     := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME 	       CONSTANT VARCHAR2(30) := 'PO.PLSQL.POR_UTIL_PKG';

 /**************************************************************************
  * liwang, 06/15/2004
  * This function should be obsoleted in release 11.5.10. Due to the dependency
  * from view POR_APPROVAL_STATUS_LINES_V, an empty function body is kept here.
  * This together with the view should be obsoleted in the next release.
  * ******************************************SELECT pap.full_name, pap.email_address, ph.phone_number, wn.begin_date
    FROM
      wf_notifications wn,
      wf_user_roles wlur,
      fnd_user fnd,
      po_requisition_headers_all prh,
      per_phones ph,
      per_all_people_f pap
    WHERE
     prh.requisition_header_id = 140331 AND
     ph.parent_table(+) = 'PER_ALL_PEOPLE_F' AND
     ph.parent_id (+) = fnd.employee_id AND
     ph.phone_type(+)  = 'W1' AND
     wlur.user_name = fnd.user_name AND
     pap.person_id = fnd.employee_id AND
     fnd.employee_id = 57 AND
     wn.recipient_role = wlur.role_name AND
     wn.status = 'OPEN' AND
     wn.message_type = prh.wf_item_type AND
     wn.message_name IN ('PO_REQ_APPROVE',
                         'PO_REQ_REMINDER1',
                         'PO_REQ_APPROVE_WEB_MSG',
                         'PO_REQ_REMINDER2',
                         'PO_REQ_REMINDER1_WEB',
                         'PO_REQ_REMINDER2_WEB',
                         'PO_REQ_APPROVE_JRAD',
                         'PO_REQ_APPROVE_SIMPLE',
                         'PO_REQ_APPROVE_SIMPLE_JRAD',
                         'PO_REQ_REMINDER1_JRAD',
                         'PO_REQ_REMINDER2_JRAD')
     AND effective_start_date < sysdate and effective_end_date > sysdate;*******************************/

  function is_PlacedOnNG(req_header_id NUMBER) RETURN VARCHAR2 is
  begin
      return 'N';
  end is_PlacedOnNG;

 /**************************************************************************
  * This function returns multiple_value or the full name of the requester *
  **************************************************************************/
  function get_requester(req_header_id IN NUMBER) RETURN VARCHAR2 IS
    no_of_values NUMBER := 0;
    value  VARCHAR2(1000) := '';
  begin
    select count(distinct nvl(to_person_id,0))
    into no_of_values
    from po_requisition_lines_all
    where requisition_header_id = req_header_id;

    if (no_of_values > 1) then
      return 'MULTIPLE_VALUE';
    else
      select full_name
      into value
      from
        per_all_people_f hre,
        po_requisition_lines_all prl
      where
        sysdate between hre.effective_start_date AND hre.effective_end_date AND
        prl.to_person_id = hre.person_id AND
        prl.requisition_header_id = req_header_id AND
        rownum = 1;
      return value;
    end if;
  end get_requester;

 /**************************************************************************
  * This function returns empty string or the deliver to address           *
  **************************************************************************/
  function get_deliver_to(req_header_id IN NUMBER) RETURN VARCHAR2 is
    no_of_values NUMBER := 0;
    value  VARCHAR2(1000) := '';
/*
    l_location_id NUMBER;
    l_address_line_1 VARCHAR2(240);
    l_address_line_2 VARCHAR2(240);
    l_address_line_3 VARCHAR2(240);
    l_territory_short_name VARCHAR2(80);
    l_address_info  VARCHAR2(240);
*/

  --Bug#9318897
    l_location_id NUMBER;
    l_address_line_1 VARCHAR2(240);
    l_address_line_2 VARCHAR2(240);
    l_address_line_3 VARCHAR2(240);
    l_town_or_city VARCHAR2(80);
    l_region_1  VARCHAR2(240);
    l_region_2  VARCHAR2(240);
    l_postal_code VARCHAR2(240);
    l_territory_short_name VARCHAR2(80);

begin
    select count(distinct nvl(deliver_to_location_id,0))
    into no_of_values
    from po_requisition_lines_all
    where requisition_header_id = req_header_id;

    if (no_of_values > 1) then
      return '';
    else
        select count(*)
        into no_of_values
	from por_item_attribute_values
	where requisition_header_id = req_header_id;

        if(no_of_values > 0) then

       	  select decode(hrtl.description,null,'',hrtl.description)
      	  into value
          from
          	hr_locations_all_tl hrtl,
        	po_requisition_lines_all prl
      	  where
        	hrtl.location_id = prl.deliver_to_location_id AND
        	prl.requisition_header_id = req_header_id AND
        	hrtl.language = userenv('LANG') AND
        	rownum = 1;
      	  return value;
    	else

          select hrl.location_id
          into l_location_id
          from
            hr_locations hrl,
            po_requisition_lines_all prl
          where
            hrl.location_id = prl.deliver_to_location_id AND
            prl.requisition_header_id = req_header_id AND
            rownum = 1;

/*Bug#9318897 Commented the following code and instead implementing the sql query
          po_hr_location.get_address(l_location_id,
            l_address_line_1,
            l_address_line_2,
            l_address_line_3,
            l_territory_short_name,
            l_address_info);
*/

          Select  HLC.ADDRESS_LINE_1,
                 HLC.ADDRESS_LINE_2,
             HLC.ADDRESS_LINE_3,
             HLC.TOWN_OR_CITY,
             NVL(DECODE(HLC.REGION_1, NULL, HLC.REGION_2,
                          DECODE(FCL1.MEANING, NULL,
                               DECODE(FCL2.MEANING, NULL,FCL3.MEANING, FCL2.MEANING),
                          FCL1.MEANING)), HLC.REGION_2),
             Decode(HLC.REGION_1,NULL,NULL,
                                 Decode(HLC.REGION_2,NULL,NULL,HLC.REGION_2)),
             HLC.POSTAL_CODE,
             FTE.TERRITORY_SHORT_NAME
           INTO l_address_line_1,
                l_address_line_2,
                l_address_line_3,
                l_town_or_city,
                l_region_1,
                l_region_2,
                l_postal_code,
                l_territory_short_name
           FROM
             HR_LOCATIONS             HLC,
             FND_TERRITORIES_TL       FTE,
             FND_LOOKUP_VALUES        FCL1,
             FND_LOOKUP_VALUES        FCL2,
             FND_LOOKUP_VALUES        FCL3
           Where
            HLC.LOCATION_ID = l_location_id AND
            HLC.COUNTRY = FTE.TERRITORY_CODE (+) AND
            DECODE(FTE.TERRITORY_CODE, NULL, '1', FTE.LANGUAGE) =
                  DECODE(FTE.TERRITORY_CODE, NULL, '1', USERENV('LANG')) AND
            HLC.REGION_1 = FCL1.LOOKUP_CODE (+) AND
            HLC.COUNTRY || '_PROVINCE' = FCL1.LOOKUP_TYPE (+) AND
            DECODE(FCL1.LOOKUP_CODE, NULL, '1', FCL1.SECURITY_GROUP_ID) =
                  DECODE(FCL1.LOOKUP_CODE, NULL, '1',
                       FND_GLOBAL.LOOKUP_SECURITY_GROUP(FCL1.LOOKUP_TYPE, FCL1.VIEW_APPLICATION_ID)) AND
            DECODE(FCL1.LOOKUP_CODE, NULL, '1', FCL1.VIEW_APPLICATION_ID) =
                  DECODE(FCL1.LOOKUP_CODE, NULL, '1', 3) AND
            DECODE(FCL1.LOOKUP_CODE, NULL, '1', FCL1.LANGUAGE) =
                  DECODE(FCL1.LOOKUP_CODE, NULL, '1', USERENV('LANG')) AND
            HLC.REGION_2 = FCL2.LOOKUP_CODE (+) AND
            HLC.COUNTRY || '_STATE' = FCL2.LOOKUP_TYPE (+) AND
            DECODE(FCL2.LOOKUP_CODE, NULL, '1', FCL2.SECURITY_GROUP_ID) =
                  DECODE(FCL2.LOOKUP_CODE, NULL, '1',
                       FND_GLOBAL.LOOKUP_SECURITY_GROUP(FCL2.LOOKUP_TYPE, FCL2.VIEW_APPLICATION_ID)) AND
            DECODE(FCL2.LOOKUP_CODE, NULL, '1', FCL2.VIEW_APPLICATION_ID) =
                  DECODE(FCL2.LOOKUP_CODE, NULL, '1', 3) AND
            DECODE(FCL2.LOOKUP_CODE, NULL, '1', FCL2.LANGUAGE) =
                  DECODE(FCL2.LOOKUP_CODE, NULL, '1', USERENV('LANG')) AND
            HLC.REGION_1 = FCL3.LOOKUP_CODE (+) AND
            HLC.COUNTRY || '_COUNTY' = FCL3.LOOKUP_TYPE (+) AND
            DECODE(FCL3.LOOKUP_CODE, NULL, '1', FCL3.SECURITY_GROUP_ID) =
                  DECODE(FCL3.LOOKUP_CODE, NULL, '1',
                        FND_GLOBAL.LOOKUP_SECURITY_GROUP(FCL3.LOOKUP_TYPE, FCL3.VIEW_APPLICATION_ID)) AND
            DECODE(FCL3.LOOKUP_CODE, NULL, '1', FCL3.VIEW_APPLICATION_ID) =
                  DECODE(FCL3.LOOKUP_CODE, NULL, '1', 3) AND
            DECODE(FCL3.LOOKUP_CODE, NULL, '1', FCL3.LANGUAGE) =
                  DECODE(FCL3.LOOKUP_CODE, NULL, '1', USERENV('LANG')) ;

          select decode(l_address_line_1,null,'',l_address_line_1||' ')||
            decode(l_address_line_2,null,'',l_address_line_2||' ')||
            decode(l_address_line_3,null,'',l_address_line_3||' ')||
            decode(l_town_or_city,null,'',l_town_or_city||',')||
            decode(l_region_1,null,'',l_region_1||',')||
            decode(l_region_2,null,'',l_region_2||',')||
            l_postal_code
          into value
          from dual;

       return value;

       end if;
    end if;
  end get_deliver_to;

 /****************************************************************************
  * This function returns requisition total of a given requisition header id *
  ****************************************************************************/
  function get_req_total(req_header_id IN NUMBER) RETURN NUMBER is
    value  NUMBER := 0;
  begin
    select nvl(SUM(decode(prl.matching_basis, 'AMOUNT', prl.amount,
prl.unit_price * (prl.quantity - nvl(prl.quantity_cancelled,0)))),0)
    into value
    from
      po_requisition_lines_all prl
    where
      requisition_header_id = req_header_id
      and nvl(modified_by_agent_flag, 'N') = 'N'
      and nvl(cancel_flag, 'N') = 'N';

    return value;
  end get_req_total;

 /****************************************************************************
  * This function returns note to agent value of a given requisition         *
  * header id                             				     *
  ****************************************************************************/
  function get_note_to_agent(req_header_id IN NUMBER) RETURN VARCHAR2 is
    value  VARCHAR2(1000) := '';
  begin
    select note_to_agent
    into value
    from po_requisition_lines_all
    where
      requisition_header_id = req_header_id and
      rownum = 1;

    return value;

  end get_note_to_agent;


 /**************************************************************************
  * This function returns multiple_value or account number of a given      *
  * requisition line id 						   *
  **************************************************************************/
  function get_account_number(req_line_id NUMBER) RETURN VARCHAR2 is
    no_of_values NUMBER := 0;
    value  VARCHAR2(1000) := '';
  begin
    select count(distinct nvl(code_combination_id,0))
    into no_of_values
    from po_req_distributions_all
    where requisition_line_id = req_line_id;

    if (no_of_values > 1) then
      return 'MULTIPLE_VALUE';
    else
      select concatenated_segments
      into value
      from
        po_req_distributions_all prd,
        gl_code_combinations_kfv cc,
        gl_sets_of_books sob,
        financials_system_params_all fsp
      where
        prd.requisition_line_id = req_line_id and
        cc.code_combination_id = prd.code_combination_id and
        cc.chart_of_accounts_id = sob.chart_of_accounts_id and
        sob.set_of_books_id = fsp.set_of_books_id and
        rownum =1;
      return value;
    end if;

  end get_account_number;


 /**************************************************************************
  * This function returns multiple_value or project number of a given      *
  * requisition line id 						   *
  **************************************************************************/
  function get_project_number(req_line_id NUMBER) RETURN VARCHAR2 is
    no_of_values NUMBER := 0;
    value  VARCHAR2(1000) := '';
  begin
    select count(distinct nvl(project_id,0))
    into no_of_values
    from po_req_distributions_all
    where requisition_line_id = req_line_id;

    if (no_of_values > 1) then
      return 'MULTIPLE_VALUE';
    else
      select projects.segment1
      into value
      from
        po_req_distributions_all prd,
        pa_projects_all projects
      where
        prd.requisition_line_id = req_line_id and
        projects.project_id = prd.project_id and
        rownum = 1;
      return value;
    end if;

  end get_project_number;

 /**************************************************************************
  * This function returns multiple_value or task name of a given           *
  * requisition line id 						   *
  **************************************************************************/
  function get_task_name(req_line_id NUMBER) RETURN VARCHAR2 is
    no_of_values NUMBER := 0;
    value  VARCHAR2(1000) := '';
  begin
    select count(distinct nvl(task_id,0))
    into no_of_values
    from po_req_distributions_all
    where requisition_line_id = req_line_id;

    if (no_of_values > 1) then
      return 'MULTIPLE_VALUE';
    else
      select tasks.task_name
      into value
      from
        po_req_distributions_all prd,
        pa_tasks tasks
      where
        prd.requisition_line_id = req_line_id and
        tasks.task_id = prd.task_id and
        rownum = 1;
      return value;
    end if;

  end get_task_name;

 /**************************************************************************
  * This function returns multiple_value or expenditure type of a given    *
  * requisition line id 						   *
  **************************************************************************/
  function get_expenditure_type(req_line_id NUMBER) RETURN VARCHAR2 is
    no_of_values NUMBER := 0;
    value  VARCHAR2(1000) := '';
  begin
    select count(distinct nvl(expenditure_type,''))
    into no_of_values
    from po_req_distributions_all
    where requisition_line_id = req_line_id;

    if (no_of_values > 1) then
      return 'MULTIPLE_VALUE';
    else
      select expenditure_type
      into value
      from po_req_distributions_all
      where
        requisition_line_id = req_line_id and
        rownum =1 ;

      return value;
    end if;

  end get_expenditure_type;

 /**************************************************************************
  * This function returns sales order number and status of a given    *
  * requisition line id 						   *
  **************************************************************************/
  function get_so_number(req_line_id NUMBER) RETURN VARCHAR2 is
    l_status_code VARCHAR2(50);
    l_flow_meaning VARCHAR2(50);
    l_so_number VARCHAR2(50);
    l_line_id NUMBER;
    l_released_count NUMBER;
    l_total_count NUMBER;
  begin
    select to_char(OOH.ORDER_NUMBER), OOL.FLOW_STATUS_CODE, OOL.LINE_ID
    INTO l_so_number, l_status_code, l_line_id
    from PO_REQUISITION_LINES PRL,
         PO_REQUISITION_HEADERS PRH,
         OE_ORDER_HEADERS_ALL OOH,
         OE_ORDER_LINES_ALL OOL,
	 PO_SYSTEM_PARAMETERS PSP
    WHERE PRL.REQUISITION_HEADER_ID = PRH.REQUISITION_HEADER_ID
    AND PRL.REQUISITION_LINE_ID = req_line_id
    AND PRH.SEGMENT1 = OOH.ORIG_SYS_DOCUMENT_REF
    AND OOL.HEADER_ID = OOH.HEADER_ID
    AND PSP.ORDER_SOURCE_ID = OOH.ORDER_SOURCE_ID
   AND OOL.Source_document_line_id = PRL.REQUISITION_LINE_ID
    AND ROWNUM =1;  /* To handle the case of so line split*/

    return l_so_number;

  EXCEPTION
    WHEN no_data_found THEN
      RETURN null;
  end get_so_number;
 /**************************************************************************
  * This function returns sales order number and status of a given    *
  * requisition line id 						   *
  **************************************************************************/
  function get_so_number_status(req_line_id NUMBER,p_prefix_so_number VARCHAR2 DEFAULT 'Y') RETURN VARCHAR2 is
    l_status_code VARCHAR2(50);
    l_so_number VARCHAR2(50);
    l_so_number_status VARCHAR2(50);
    l_split_line_num NUMBER;
    l_line_id NUMBER;
  begin

    l_split_line_num :=0;
    select count(OOL.LINE_ID)
    INTO l_split_line_num
    from PO_REQUISITION_LINES PRL,
         PO_REQUISITION_HEADERS PRH,
         OE_ORDER_HEADERS_ALL OOH,
         OE_ORDER_LINES_ALL OOL,
	 PO_SYSTEM_PARAMETERS PSP
    WHERE PRL.REQUISITION_HEADER_ID = PRH.REQUISITION_HEADER_ID
    AND PRL.REQUISITION_LINE_ID = req_line_id
    AND PRH.SEGMENT1 = OOH.ORIG_SYS_DOCUMENT_REF
    AND OOL.HEADER_ID = OOH.HEADER_ID
    AND OOL.ORIG_SYS_LINE_REF = to_char(PRL.LINE_NUM)
    AND PSP.ORDER_SOURCE_ID = OOH.ORDER_SOURCE_ID;

    -- Added the new parameter to check if the LifecycleCO invokes this code indirectly.
    -- In case, from LifecyclePG do not return Multiple_value.
    -- if the internal order line is split, the return 'MULTIPLE_VALUE'
    if ( l_split_line_num > 1 ) then
      return 'MULTIPLE_VALUE';
    end if;

    select to_char(OOH.ORDER_NUMBER), OOL.FLOW_STATUS_CODE, OOL.LINE_ID
    INTO l_so_number, l_status_code, l_line_id
    from PO_REQUISITION_LINES PRL,
         PO_REQUISITION_HEADERS PRH,
         OE_ORDER_HEADERS_ALL OOH,
         OE_ORDER_LINES_ALL OOL,
         PO_SYSTEM_PARAMETERS PSP
    WHERE PRL.REQUISITION_HEADER_ID = PRH.REQUISITION_HEADER_ID
    AND PRL.REQUISITION_LINE_ID = req_line_id
    AND PRH.SEGMENT1 = OOH.ORIG_SYS_DOCUMENT_REF
    AND OOL.HEADER_ID = OOH.HEADER_ID
    AND OOL.ORIG_SYS_LINE_REF = to_char(PRL.LINE_NUM)
    AND PSP.ORDER_SOURCE_ID = OOH.ORDER_SOURCE_ID;

    l_so_number_status := get_so_number_status_code(l_status_code, l_line_id, l_so_number,p_prefix_so_number);

    return l_so_number_status;
    EXCEPTION
    WHEN no_data_found THEN
      RETURN null;
  end get_so_number_status;

  --Invoked when coming from Lifecycle page
 function get_so_number_status(req_line_id NUMBER,p_prefix_so_number VARCHAR2 DEFAULT 'Y', p_line_id IN NUMBER) RETURN VARCHAR2 is
    l_status_code VARCHAR2(50);
    l_so_number VARCHAR2(50);
    l_so_number_status VARCHAR2(50);
    l_line_id NUMBER;
  begin
      select to_char(OOH.ORDER_NUMBER), OOL.FLOW_STATUS_CODE, OOL.LINE_ID
      INTO l_so_number, l_status_code, l_line_id
      from PO_REQUISITION_LINES PRL,
           PO_REQUISITION_HEADERS PRH,
           OE_ORDER_HEADERS_ALL OOH,
           OE_ORDER_LINES_ALL OOL,
           PO_SYSTEM_PARAMETERS PSP
      WHERE PRL.REQUISITION_HEADER_ID = PRH.REQUISITION_HEADER_ID
      AND PRL.REQUISITION_LINE_ID = req_line_id
      AND PRH.SEGMENT1 = OOH.ORIG_SYS_DOCUMENT_REF
      AND OOL.HEADER_ID = OOH.HEADER_ID
      AND OOL.ORIG_SYS_LINE_REF = to_char(PRL.LINE_NUM)
      AND OOL.LINE_ID = p_line_id
      AND PSP.ORDER_SOURCE_ID = OOH.ORDER_SOURCE_ID;

    l_so_number_status := get_so_number_status_code(l_status_code, l_line_id, l_so_number,p_prefix_so_number);

    return l_so_number_status;
    EXCEPTION
    WHEN no_data_found THEN
      RETURN null;

  end get_so_number_status;

  --Code to return the status of a line
  function get_so_number_status_code(p_status_code IN VARCHAR2, p_line_id IN NUMBER, p_so_number IN NUMBER,p_prefix_so_number VARCHAR2 DEFAULT 'Y') RETURN VARCHAR2 IS
    l_released_count NUMBER;
    l_total_count NUMBER;
    l_flow_meaning VARCHAR2(50);
    l_so_number_status VARCHAR2(50);
  Begin
    IF (p_status_code is not null) THEN
      IF p_status_code <> 'AWAITING_SHIPPING' AND
	       p_status_code <> 'PRODUCTION_COMPLETE' AND
	       p_status_code <> 'PICKED' AND
	       p_status_code <> 'PICKED_PARTIAL'
      THEN
          SELECT meaning
          INTO l_flow_meaning
          FROM fnd_lookup_values lv
          WHERE lookup_type = 'LINE_FLOW_STATUS'
          AND lookup_code = p_status_code
          AND LANGUAGE = userenv('LANG')
          AND VIEW_APPLICATION_ID = 660
          AND SECURITY_GROUP_ID =
              fnd_global.Lookup_Security_Group(lv.lookup_type,
                                               lv.view_application_id);

       /* status is AWAITING_SHIPPING or PRODUCTION_COMPLETE etc.
          get value from shipping table */
       ELSE
          SELECT sum(decode(released_status, 'Y', 1, 0)), sum(1)
          INTO l_released_count, l_total_count
          FROM wsh_delivery_details
          WHERE source_line_id   = p_line_id
          AND   source_code      = 'OE'
          AND   released_status  <> 'D';

          IF l_released_count = l_total_count THEN
           SELECT meaning
           INTO l_flow_meaning
           FROM fnd_lookup_values lv
           WHERE lookup_type = 'LINE_FLOW_STATUS'
           AND lookup_code = 'PICKED'
           AND LANGUAGE = userenv('LANG')
           AND VIEW_APPLICATION_ID = 660
           AND SECURITY_GROUP_ID =
                fnd_global.Lookup_Security_Group(lv.lookup_type,
                                                 lv.view_application_id);

          ELSIF l_released_count < l_total_count and l_released_count <> 0 THEN
           SELECT meaning
           INTO l_flow_meaning
           FROM fnd_lookup_values lv
           WHERE lookup_type = 'LINE_FLOW_STATUS'
           AND lookup_code = 'PICKED_PARTIAL'
           AND LANGUAGE = userenv('LANG')
           AND VIEW_APPLICATION_ID = 660
           AND SECURITY_GROUP_ID =
                fnd_global.Lookup_Security_Group(lv.lookup_type,
                                                 lv.view_application_id);
          ELSE
           SELECT meaning
           INTO l_flow_meaning
           FROM fnd_lookup_values lv
           WHERE lookup_type = 'LINE_FLOW_STATUS'
           AND lookup_code = p_status_code
           AND LANGUAGE = userenv('LANG')
           AND VIEW_APPLICATION_ID = 660
           AND SECURITY_GROUP_ID =
                fnd_global.Lookup_Security_Group(lv.lookup_type,
                                                 lv.view_application_id);
          END IF;
       END IF;

       if(p_prefix_so_number = 'Y') then
        l_so_number_status := p_so_number || ' (' || l_flow_meaning || ')';
       else
        l_so_number_status := l_flow_meaning;
       end if;
    END IF;
    return l_so_number_status;

  EXCEPTION
    WHEN no_data_found THEN
      RETURN null;
  end get_so_number_status_code;

 /**************************************************************************
  * This function returns sales order status (header) of a given           *
  * requisition line id 						   *
  **************************************************************************/
  function get_so_status(req_line_id NUMBER) RETURN VARCHAR2 is
    l_status_code VARCHAR2(50);
    l_flow_meaning VARCHAR2(50);
    l_so_number VARCHAR2(50);
    l_line_id NUMBER;
    l_released_count NUMBER;
    l_total_count NUMBER;
  begin
    select to_char(OOH.ORDER_NUMBER), OOH.FLOW_STATUS_CODE, OOL.LINE_ID
    INTO l_so_number, l_status_code, l_line_id
    from PO_REQUISITION_LINES_ALL PRL,
         PO_REQUISITION_HEADERS_ALL PRH,
         OE_ORDER_HEADERS_ALL OOH,
         OE_ORDER_LINES_ALL OOL,
	 PO_SYSTEM_PARAMETERS_ALL PSP
    WHERE PRL.REQUISITION_HEADER_ID = PRH.REQUISITION_HEADER_ID
    AND PRL.REQUISITION_LINE_ID = req_line_id
    AND NVL(OOH.ORG_ID, -99) = NVL(PSP.ORG_ID, -99)
    AND PRH.SEGMENT1 = OOH.ORIG_SYS_DOCUMENT_REF
    AND OOL.HEADER_ID = OOH.HEADER_ID
    AND PSP.ORDER_SOURCE_ID = OOH.ORDER_SOURCE_ID
    AND OOL.source_document_line_id =PRL.REQUISITION_LINE_ID
    AND ROWNUM =1;  /* To handle the case of so line split*/

     IF (l_status_code is not null) THEN
          SELECT meaning
          INTO l_flow_meaning
          FROM fnd_lookup_values lv
          WHERE lookup_type = 'LINE_FLOW_STATUS'
          AND lookup_code = l_status_code
          AND LANGUAGE = userenv('LANG')
          AND VIEW_APPLICATION_ID = 660
          AND SECURITY_GROUP_ID =
              fnd_global.Lookup_Security_Group(lv.lookup_type,
                                               lv.view_application_id);
    END IF;
    return l_flow_meaning;

  EXCEPTION
    WHEN no_data_found THEN
      RETURN null;
  end get_so_status;

 /**************************************************************************
  * This function returns multiple_value or shipment number of a given    *
  * requisition line id 						   *
  **************************************************************************/
  function get_shipment_number(req_line_id NUMBER) RETURN VARCHAR2 is
    p_values  dbms_sql.VARCHAR2_TABLE;
  begin
    select RSH.SHIPMENT_NUM BULK COLLECT INTO p_values
    from RCV_SHIPMENT_HEADERS RSH, RCV_SHIPMENT_LINES RSL
    WHERE RSL.SHIPMENT_HEADER_ID = RSH.SHIPMENT_HEADER_ID
    AND RSL.REQUISITION_LINE_ID = req_line_id;

    if (p_values IS NULL or p_values.COUNT < 1) then
      return null;
    elsif (p_values.COUNT > 1) then
      return FND_MESSAGE.GET_STRING('ICX', 'ICX_POR_MULTIPLE');
    else
      return p_values(1);
    end if;

  end get_shipment_number;

function get_supplier_name(req_header_id NUMBER) RETURN VARCHAR2 is

  CURSOR req_supplier_info (c_req_header_id NUMBER) IS
    SELECT	PRL.suggested_vendor_name, PRL.vendor_id
    FROM 	PO_REQUISITION_LINES_ALL PRL,
         	po_line_types plt
    where 	prl.requisition_header_id = c_req_header_id
    and   	prl.source_type_code = 'VENDOR'
    and   	prl.line_type_id = plt.line_type_id
    and   	plt.outside_operation_flag = 'N';


  CURSOR contractor_req_supplier_info (c_req_header_id NUMBER) IS
    SELECT      prl.suggested_vendor_name, prl.requisition_line_id
    FROM 	PO_REQUISITION_LINES_ALL PRL,
 		po_line_types plt
    where 	prl.requisition_header_id = c_req_header_id
    and   	prl.source_type_code = 'VENDOR'
    and   	prl.line_type_id = plt.line_type_id
    and   	plt.outside_operation_flag = 'N'
    and   	prl.LABOR_REQ_LINE_ID is null; -- labor line only

  x_counter number := 0;
  x_vendor_name varchar2(1000);
  x_vendor_id number;
  x_current_vendor_name varchar2(1000);
  x_current_vendor_id number;
  x_req_line_id number;
  l_contractor_requisition_flag VARCHAR2(1);

  begin

    select CONTRACTOR_REQUISITION_FLAG
    into l_contractor_requisition_flag
    from po_requisition_headers
    where requisition_header_id = req_header_id;

    if ( l_contractor_requisition_flag = 'Y') then
      -- contrctor requisition. There might be multiple suppliers in
      -- the requisition line.

      OPEN contractor_req_supplier_info(req_header_id);
      LOOP
        FETCH contractor_req_supplier_info INTO x_vendor_name, x_req_line_id;
        EXIT WHEN contractor_req_supplier_info %NOTFOUND;

        if(x_vendor_name is null) then
          x_vendor_name := get_labor_line_supplier_name(x_req_line_id);
        end if;

        if(x_vendor_name is not null) then
          if(x_counter = 0) then
            x_current_vendor_name := x_vendor_name;
            x_counter := x_counter + 1;
          elsif (x_current_vendor_name <> x_vendor_name) then
            x_current_vendor_name := 'MULTIPLE_VALUE';
            exit;
          end if;
        end if;
      END LOOP;
      CLOSE contractor_req_supplier_info;
    else
      -- There should be at most 1 supplier for each requisition line
      OPEN req_supplier_info(req_header_id);
      LOOP
        FETCH req_supplier_info INTO x_vendor_name, x_vendor_id;
        EXIT WHEN req_supplier_info %NOTFOUND;
        if(x_counter = 0) then
          x_current_vendor_name := x_vendor_name;
          x_current_vendor_id := x_vendor_id;
          x_counter := x_counter + 1;
        elsif (x_current_vendor_name <> x_vendor_name
          or x_current_vendor_id <> x_vendor_id) then
          x_current_vendor_name := 'MULTIPLE_VALUE';
          exit;
        end if;
      END LOOP;
      CLOSE req_supplier_info;

    end if;

  return x_current_vendor_name;


  exception
  when others then
    return null;

end get_supplier_name;


  /**************************************************************************
  * This function returns 'Y' if there is even one reqline on a PO          *
  * *************************************************************************/
  function is_PlacedOnPO(req_header_id NUMBER) RETURN VARCHAR2 is

    is_aPO  VARCHAR2(1) := '';
    no_of_linesOnPO NUMBER := 0;

  begin
    select decode(count(prl.line_location_id),0,'N','Y')
    into is_aPO
    from po_requisition_lines prl
    where prl.requisition_header_id = req_header_id
    and   prl.line_location_id is not null;

    return is_aPO;

  exception
     when others then
        return null;

  end is_PlacedOnPO;

  /**************************************************************************
  * This function returns 'Y' if there is even one reqline on a SO          *
  * *************************************************************************/
  function is_PlacedOnSO(req_header_id NUMBER) RETURN VARCHAR2 is

    is_aSO  VARCHAR2(1) := '';

  begin
    select prh.TRANSFERRED_TO_OE_FLAG
    into is_aSO
    from po_requisition_headers prh
    where prh.requisition_header_id = req_header_id;

    return is_aSO;

  exception
     when others then
        return null;

  end is_PlacedOnSO;

 /**************************************************************************
  * This function returns the full name of the approver *
  **************************************************************************/
  function get_approver_name(approver_id IN NUMBER) RETURN VARCHAR2 IS
    value  VARCHAR2(1000) := '';
  begin
    /** bgu, Apr. 08, 1999
     *  (1) Even the approver is no longer with the org, still need to retieve his/her
     *      Full Name.
     *  (2) Suppose a person has multiple employing history with the org, there're
     *      multiple records for the person in per_all_people_f table.
     */
    select distinct full_name
    into   value
    from   per_all_people_f hre
    where  hre.person_id = approver_id
    and trunc(sysdate) BETWEEN effective_start_date
        and effective_end_date;

    return value;
  exception
     when others then
        return null;

  end get_approver_name;

/**************************************************************************
  * This function returns the email address of the approver *
  **************************************************************************/
  function get_approver_email(approver_id IN NUMBER) RETURN VARCHAR2 IS
    value  VARCHAR2(1000) := '';
  begin
    /** bgu, Apr. 08, 1999
     *  (1) Even the approver is no longer with the org, still need to retieve his/her
     *      Full Name.
     *  (2) Suppose a person has multiple employing history with the org, there're
     *      multiple records for the person in per_all_people_f table.
     */
    select distinct email_address
    into   value
    from   per_all_people_f hre
    where  hre.person_id = approver_id
    and trunc(sysdate) BETWEEN effective_start_date
        and effective_end_date;

    return value;
  exception
     when others then
        return null;

  end get_approver_email;


  /**************************************************************************
   * This procedure is used to return requisition total in currency format, *
   * supplier name and placed on po flag all together to improve the        *
   * performance                                                            *
   **************************************************************************/
  procedure getLineInfo( reqHeaderId IN NUMBER,
			 currencyFormat IN VARCHAR2,
                         reqTotal OUT NOCOPY varchar2,
	                 supplierName OUT NOCOPY VARCHAR2,
			 placedOnPoFlag OUT NOCOPY VARCHAR2) IS
  begin
    reqTotal       := to_char(get_req_total(reqHeaderId), currencyFormat);
    supplierName   := get_supplier_name(reqHeaderId);
    placedOnPoFlag := is_PlacedOnPO(reqHeaderId);
  end getLineInfo;

  /**************************************************************************
   * This procedure is same with the procedure getLineInfo except that      *
   * it returns reqTotal as a unformatted number instead of a formatted     *
   * String.                                                                *
   **************************************************************************/
  procedure getUnformattedLineInfo( reqHeaderId IN NUMBER,
			 currencyFormat IN VARCHAR2,
                         reqTotal OUT NOCOPY NUMBER,
	                 supplierName OUT NOCOPY VARCHAR2,
			 placedOnPoFlag OUT NOCOPY VARCHAR2) IS
  begin
    reqTotal       := get_req_total(reqHeaderId);
    supplierName   := get_supplier_name(reqHeaderId);
    placedOnPoFlag := is_PlacedOnPO(reqHeaderId);
  end getUnformattedLineInfo;

 /****************************************************************************
  * This function returns urgent flag value of a given requisition header id *
  ****************************************************************************/
  function get_urgent_flag(req_header_id IN NUMBER) RETURN VARCHAR2 is
    value  PO_LOOKUP_CODES.DISPLAYED_FIELD%TYPE := '';
  begin
    select plc_urg.displayed_field
    into value
    from
      po_requisition_headers_all prh,
      po_requisition_lines_all prl,
      po_lookup_codes plc_urg
    where
      prh.requisition_header_id = req_header_id and
      prl.requisition_header_id = prh.requisition_header_id and
      plc_urg.lookup_code = nvl(prl.urgent_flag, 'N') and
      plc_urg.lookup_type = 'YES/NO' and
      rownum = 1;

    return value;

  end get_urgent_flag;


 /**************************************************************************
  * This procedure returns distribution related info of a given            *
  * requisition line.                                                      *
  **************************************************************************/
  procedure getDistributionInfo(req_line_id IN NUMBER,
                                date_format IN VARCHAR2,
			        account_number OUT NOCOPY VARCHAR2,
                                project_id OUT NOCOPY NUMBER,
                                project_number OUT NOCOPY VARCHAR2,
                                task_id OUT NOCOPY NUMBER,
                                task_number OUT NOCOPY VARCHAR2,
	                        expenditure_type OUT NOCOPY VARCHAR2,
			        expenditure_org_id OUT NOCOPY NUMBER,
                                expenditure_org OUT NOCOPY VARCHAR2,
                                expenditure_item_date OUT NOCOPY VARCHAR2) IS
  begin
    account_number := get_account_number(req_line_id);

    select prd.project_id, prd.task_id, prd.expenditure_type,
           prd.expenditure_organization_id,
           to_char(prd.expenditure_item_date, date_format)
    into project_id, task_id, expenditure_type,
      expenditure_org_id, expenditure_item_date
    from
      po_req_distributions prd
    where prd.requisition_line_id = req_line_id and
      rownum = 1;

    if (project_id is not null) then
      select projects.segment1
      into project_number
      from
        po_req_distributions prd,
        pa_projects projects
      where
        prd.requisition_line_id = req_line_id and
        projects.project_id = prd.project_id and
        rownum = 1;
    end if;

    if (task_id is not null) then
      select tasks.task_number
      into task_number
      from
        po_req_distributions prd,
        pa_tasks tasks
      where
        prd.requisition_line_id = req_line_id and
        tasks.task_id = prd.task_id and rownum = 1 ;
    end if;

    if (expenditure_org_id is not null) then
      select orgs.name
      into expenditure_org
      from
        po_req_distributions prd,
        pa_organizations_expend_v orgs
      where
        prd.requisition_line_id = req_line_id and
        prd.expenditure_organization_id = orgs.organization_id and
        rownum = 1;
    end if;

  end getDistributionInfo;

 /****************************************************************************
  * This function returns requisition line total of a given requisition      *
  * line. If the requisition line is cancelled, returns zero                 *
  ****************************************************************************/
  function get_line_total(req_line_id IN NUMBER, currency_code IN VARCHAR2) RETURN VARCHAR2 is
    value  VARCHAR2(2000) := '';
    cancelled VARCHAR2(1) := 'N';
    total NUMBER := 0;
  begin
    select nvl(cancel_flag, 'N')
    into cancelled
    from po_requisition_lines_all
    where requisition_line_id = req_line_id;

    if (cancelled = 'Y') then
      select to_char(0, fnd_currency.safe_get_format_mask(currency_code, 30))
      into value
      from sys.dual;
    else
      select prl.unit_price * (prl.quantity - nvl(prl.quantity_cancelled,0))
      into total
      from po_requisition_lines_all prl
      where requisition_line_id = req_line_id;

      select to_char(total, fnd_currency.safe_get_format_mask(currency_code, 30))
      into value
      from sys.dual;
    end if;

    return value;
  end get_line_total;

  /* This function returns whether the req is modified by buyer */

  function is_req_modified_by_buyer(reqHeaderId IN NUMBER) return varchar2 is

    num_line_modified number := 0;

  begin

    select count(*)
      into num_line_modified
      from po_requisition_lines_all
     where requisition_header_id = reqHeaderId
       and MODIFIED_BY_AGENT_FLAG = 'Y';

    if num_line_modified > 0 then
      return 'Y';
    else
      return 'N';
    end if;

  end is_req_modified_by_buyer;

  function get_business_group_name(approver_id IN NUMBER) RETURN VARCHAR2 IS
    value  VARCHAR2(1000) := '';
  begin
    select distinct pb.name
    into value
    from PER_BUSINESS_GROUPS_PERF pb,
         per_all_people_f hre
    where  hre.person_id = approver_id
    and hre.business_group_id=pb.business_group_id
    and trunc(sysdate) BETWEEN effective_start_date
        and effective_end_date;

    return value;
  exception
     when others then
        return null;

  end get_business_group_name;

 /****************************************************************************
  * This function returns non recoverable tax total for a given requisition  *
  * header id.                                                               *
  ****************************************************************************/
  FUNCTION get_nonrec_tax_total(ReqHeaderId  IN NUMBER)
     RETURN NUMBER IS
    total NUMBER := 0;
  BEGIN

    SELECT sum(nvl(prd.nonrecoverable_tax,0))
    INTO total
    FROM
      po_req_distributions prd,
      po_requisition_lines prl
    WHERE
      prd.requisition_line_id = prl.requisition_line_id and
      prl.requisition_header_id= ReqHeaderId and
      NVL(prl.cancel_flag, 'N') = 'N' and
      NVL(prl.modified_by_agent_flag, 'N') = 'N';

    RETURN total;

  END get_nonrec_tax_total;

 /****************************************************************************
  * This function returns non recoverable tax total for a given requisition  *
  * line id.                                                                 *
  ****************************************************************************/
 FUNCTION get_line_nonrec_tax_total(ReqLineId IN NUMBER) RETURN NUMBER IS
    total NUMBER := 0;

 BEGIN
    SELECT sum(nvl(prd.nonrecoverable_tax,0))
    INTO total
    FROM
      po_req_distributions prd,
      po_requisition_lines prl
    WHERE
      prd.requisition_line_id = ReqLineId AND
      prd.requisition_line_id = prl.requisition_line_id AND
      NVL(prl.cancel_flag, 'N') = 'N' AND
      NVL(prl.modified_by_agent_flag, 'N') = 'N';

    RETURN total;

  END get_line_nonrec_tax_total;


 /****************************************************************************
  * This function returns recoverable tax total for a given requisition      *
  * line id.                                                                 *
  ****************************************************************************/
  FUNCTION get_line_rec_tax_total(ReqLineId IN NUMBER) RETURN NUMBER is
    total NUMBER := 0;

  BEGIN
    SELECT sum(nvl(prd.recoverable_tax,0))
    INTO total
    FROM
      po_req_distributions prd,
      po_requisition_lines prl
    WHERE
      prd.requisition_line_id = ReqLineId AND
      prd.requisition_line_id = prl.requisition_line_id AND
      NVL(prl.cancel_flag, 'N') = 'N' AND
      NVL(prl.modified_by_agent_flag, 'N') = 'N';

  RETURN total;
  END get_line_rec_tax_total;

  /**
   *  Returns Y if there is cancelled lines for the given requisition;
   *  Else returns N
   */
  FUNCTION GET_CANCEL_FLAG(p_req_header_id IN NUMBER)
     RETURN VARCHAR2 IS
     x_cancels              NUMBER := 0;
   BEGIN
    SELECT COUNT(*)
    INTO   X_CANCELS
    FROM   PO_REQUISITION_LINES_ALL PRL
    WHERE  PRL.REQUISITION_HEADER_ID = P_REQ_HEADER_ID
    AND    NVL(CANCEL_FLAG, 'N') = 'N';

    IF ( X_CANCELS > 0 ) THEN
	RETURN 'Y';
    ELSE
	RETURN 'N';
    END IF;
  END  GET_CANCEL_FLAG;

  /**
   *  Returns Y if there is return transaction for the given parent trxn id;
   *  Else returns N
   */
  FUNCTION GET_RETURN_FLAG(p_txn_id IN NUMBER)
    RETURN VARCHAR2 IS
    x_returns              NUMBER := 0;
   BEGIN
    SELECT COUNT(*)
    INTO   X_RETURNS
    FROM   RCV_TRANSACTIONS RT
    WHERE  RT.PARENT_TRANSACTION_ID = P_TXN_ID
    AND    RT.TRANSACTION_TYPE = 'RETURN TO RECEIVING';

    IF ( X_RETURNS > 0 ) THEN
	RETURN 'Y';
    ELSE
    	RETURN 'N';
    END IF;
  END GET_RETURN_FLAG;

  /**
   * This function returns the po release id
   * if there is only one purchase order associated with the requisition;
   * or returns null if there is more than one order
   * associated with the requisition
   */
  FUNCTION GET_PO_RELEASE_ID(p_req_header_id in number)
    RETURN number IS

  x_po_header_id number;
  x_po_release_id number;

  BEGIN
    get_po_info (p_req_header_id,x_po_header_id, x_po_release_id );

    return x_po_release_id;
  END GET_PO_RELEASE_ID;


  /**
   * This function returns the po header id
   * if there is only one purchase order associated with the requisition;
   * or returns null if there is more than one order
   * associated with the requisition
   */

  FUNCTION GET_PO_HEADER_ID(p_req_header_id in number)
    RETURN number IS

  x_po_header_id number;
  x_po_release_id number;

  BEGIN
    get_po_info (p_req_header_id,x_po_header_id, x_po_release_id );

    return x_po_header_id;
  END GET_PO_HEADER_ID;


  PROCEDURE GET_PO_INFO(p_req_header_id in number,
			p_po_header_id out NOCOPY number,
			p_po_release_id out NOCOPY number)  IS

  CURSOR c_po_info (c_req_header_id NUMBER) IS
   SELECT
     PH.PO_HEADER_ID, PR.PO_RELEASE_ID
   FROM
     PO_REQUISITION_LINES_ALL PRL,
     PO_REQ_DISTRIBUTIONS_ALL PRD,
     PO_DISTRIBUTIONS_ALL PD,
     PO_RELEASES_ALL PR,
     PO_HEADERS_ALL PH
   WHERE
     PD.PO_HEADER_ID = PH.PO_HEADER_ID AND
     PD.PO_RELEASE_ID = PR.PO_RELEASE_ID(+) AND
     PRD.DISTRIBUTION_ID = PD.REQ_DISTRIBUTION_ID AND
     PRD.REQUISITION_LINE_ID = PRL.REQUISITION_LINE_ID AND
     PRL.REQUISITION_HEADER_ID = C_REQ_HEADER_ID;

  x_counter number := 0;
  x_po_header_id number := null;
  x_old_po_header_id number := null;
  x_po_release_id number := null;
  x_old_po_release_id number := null;


  BEGIN
    OPEN c_po_info(p_req_header_id);
    LOOP
      FETCH c_po_info INTO x_po_header_id, x_po_release_id;
       EXIT WHEN c_po_info %NOTFOUND;
         if(x_counter = 0) then
  	   x_old_po_header_id := x_po_header_id;
  	   x_old_po_release_id := x_po_release_id;
           x_counter := x_counter + 1;
         elsif (x_old_po_header_id <> x_po_header_id
		or x_old_po_release_id <> x_po_release_id) then
  	   x_po_header_id := null;
           x_po_release_id := null;
           exit;
         end if;
    END LOOP;
    CLOSE c_po_info;

    p_po_header_id := x_po_header_id;
    p_po_release_id := x_po_release_id;

  -- Exception

  end GET_PO_INFO;

  PROCEDURE GET_ORDER_RELATED_INFO(p_req_header_id in number,
			   order_number out NOCOPY varchar2,
			   order_source_type out NOCOPY varchar2,
			   header_id out NOCOPY number,
			   po_release_id out NOCOPY number,
			   purchasing_org out NOCOPY varchar2,
			   placed_on_po_flag out NOCOPY varchar2,
			   order_status out NOCOPY varchar2) IS

  no_of_po number :=0;
  req_line_id_po number :=0;

  no_of_so number :=0;
  req_line_id_so number :=0;

  no_of_order number := 0;

  BEGIN

    order_number:= null;
    order_source_type := null;
    purchasing_org := null;
    header_id := null;
    po_release_id := null;
    placed_on_po_flag := 'N';
    order_status := null;
    SELECT COUNT(DISTINCT(
     	    PH.SEGMENT1 ||DECODE(PR.RELEASE_NUM, NULL,'','-'||PR.RELEASE_NUM))),
	   min(PRL.REQUISITION_LINE_ID)
	   into no_of_po, req_line_id_po
    FROM
     	    PO_REQUISITION_LINES_ALL PRL,
     	    PO_REQUISITION_HEADERS_ALL PRH,
     	    PO_LINE_LOCATIONS_ALL PLL,
     	    PO_RELEASES_ALL PR,
     	    PO_HEADERS_ALL PH
    WHERE
     	    PLL.PO_HEADER_ID = PH.PO_HEADER_ID AND
     	    PR.PO_RELEASE_ID(+) = PLL.PO_RELEASE_ID AND
     	    PLL.LINE_LOCATION_ID = PRL.LINE_LOCATION_ID AND
     	    PRL.REQUISITION_HEADER_ID = PRH.REQUISITION_HEADER_ID AND
	    PRH.REQUISITION_HEADER_ID = p_req_header_id;

    if (no_of_po > 1) then
	   order_number:= 'MULTIPLE_VALUE';
	   order_source_type := 'MULTIPLE_VALUE';
	   purchasing_org := 'MULTIPLE_VALUE';
  	   header_id := null;
           po_release_id := null;
    	   placed_on_po_flag := 'Y';
	   order_status := 'MULTIPLE_VALUE';
    else
      SELECT COUNT(DISTINCT(OOH.HEADER_ID)), min(PRL.REQUISITION_LINE_ID)
	     into no_of_so, req_line_id_so
      FROM
        PO_REQUISITION_HEADERS PRH,
        PO_REQUISITION_LINES_ALL PRL,
        OE_ORDER_HEADERS_ALL OOH,
        OE_ORDER_LINES_ALL OOL,
        PO_SYSTEM_PARAMETERS PSP
      WHERE
        OOH.ORDER_SOURCE_ID = PSP.ORDER_SOURCE_ID AND
        OOH.ORIG_SYS_DOCUMENT_REF = PRH.SEGMENT1 AND
        OOH.SOURCE_DOCUMENT_ID = PRH.REQUISITION_HEADER_ID AND
        OOH.HEADER_ID = OOL.HEADER_ID AND
        OOL.SOURCE_DOCUMENT_LINE_ID = PRL.REQUISITION_LINE_ID AND
        PRH.REQUISITION_HEADER_ID = PRL.REQUISITION_HEADER_ID AND
        PRH.REQUISITION_HEADER_ID = p_req_header_id;

      no_of_order := no_of_po + no_of_so;

      if (no_of_order > 1 ) then
	   order_number:= 'MULTIPLE_VALUE';
	   order_source_type := 'MULTIPLE_VALUE';
	   purchasing_org := 'MULTIPLE_VALUE';
  	   header_id := null;
           po_release_id := null;
	   order_status := 'MULTIPLE_VALUE';

	   if (no_of_po > 0) then
             placed_on_po_flag := 'Y';
	   end if;

      elsif (no_of_order = 0) then
	   order_number:= null;
	   order_source_type := null;
	   purchasing_org := null;
  	   header_id := null;
           po_release_id := null;
    	   placed_on_po_flag := 'N';
	   order_status := null;

      else
	if(no_of_po = 1) then
	  -- ONLY ONE PO
  	  SELECT
     	    PH.SEGMENT1 ||DECODE(PR.RELEASE_NUM, NULL,'','-'||PR.RELEASE_NUM),
	    PH.PO_HEADER_ID,
            PRL.SOURCE_TYPE_CODE,
            PR.PO_RELEASE_ID,
	    HOU.NAME,
	    'Y',
	    DECODE(PR.PO_RELEASE_ID,
			NULL, PH.AUTHORIZATION_STATUS,
			PR.AUTHORIZATION_STATUS)
	  into
            order_number,
	    header_id,
            order_source_type,
            po_release_id,
	    purchasing_org,
            placed_on_po_flag,
	    order_status
   	  FROM
     	    PO_REQUISITION_LINES_ALL PRL,
     	    PO_LINE_LOCATIONS_ALL PLL,
     	    PO_RELEASES_ALL PR,
     	    PO_HEADERS_ALL PH,
     	    HR_ALL_ORGANIZATION_UNITS_VL HOU
   	  WHERE
     	    PLL.PO_HEADER_ID = PH.PO_HEADER_ID(+) AND
     	    PR.PO_RELEASE_ID(+) = PLL.PO_RELEASE_ID AND
     	    PLL.LINE_LOCATION_ID(+) = PRL.LINE_LOCATION_ID AND
     	    PRL.REQUISITION_LINE_ID = req_line_id_po AND
	    PH.ORG_ID = HOU.ORGANIZATION_ID (+);

	else
	  -- no_of_so = 1
	  -- ONLY ONE SO
   	  SELECT
	    TO_CHAR(OOH.ORDER_NUMBER),
	    OOH.HEADER_ID,
            PRL.SOURCE_TYPE_CODE,
	    null,
	    null,
	    'N',
	    get_so_number_status(prl.requisition_line_id)
	  into
            order_number,
	    header_id,
            order_source_type,
            po_release_id,
	    purchasing_org,
	    placed_on_po_flag,
	    order_status
   	  FROM
     	    PO_REQUISITION_HEADERS PRH,
     	    PO_REQUISITION_LINES_ALL PRL,
     	    OE_ORDER_HEADERS_ALL OOH,
     	    OE_ORDER_LINES_ALL OOL,
     	    PO_SYSTEM_PARAMETERS PSP
   	  WHERE
     	    OOH.ORDER_SOURCE_ID = PSP.ORDER_SOURCE_ID AND
     	    OOH.ORIG_SYS_DOCUMENT_REF = PRH.SEGMENT1 AND
     	    OOH.HEADER_ID = OOL.HEADER_ID AND
     	    OOL.SOURCE_DOCUMENT_LINE_ID = PRL.REQUISITION_LINE_ID AND
     	    PRL.REQUISITION_LINE_ID = req_line_id_so AND
     	    OOH.SOURCE_DOCUMENT_ID = PRH.REQUISITION_HEADER_ID AND
	    PRH.REQUISITION_HEADER_ID = p_req_header_id AND
            rownum = 1;

	end if;
      end if;

    end if;

    -- EXCEPTION
  END GET_ORDER_RELATED_INFO;

  /**
   * This function returns the purchasing organization name
   * if there is only one org associated with the requisition;
   * or returns 'MULTIPLE' if there is more than one org
   * associated with the requisition
   */
  FUNCTION GET_PURCHASING_ORG(p_req_header_id in number)
    RETURN varchar2 IS
  CURSOR c_purchasing_org (c_req_header_id NUMBER) IS
   SELECT
     HOU.NAME ORG_NAME,  PH.ORG_ID
   FROM
     PO_REQUISITION_LINES_ALL PRL,
     PO_REQ_DISTRIBUTIONS_ALL PRD,
     PO_DISTRIBUTIONS_ALL PD,
     PO_HEADERS_ALL PH,
     HR_ALL_ORGANIZATION_UNITS_VL HOU
   WHERE
     PD.PO_HEADER_ID = PH.PO_HEADER_ID AND
     PRD.DISTRIBUTION_ID = PD.REQ_DISTRIBUTION_ID AND
     PRD.REQUISITION_LINE_ID = PRL.REQUISITION_LINE_ID AND
     PRL.REQUISITION_HEADER_ID = C_REQ_HEADER_ID AND
     PH.ORG_ID = HOU.ORGANIZATION_ID (+);

    x_org varchar2(80);
    x_counter number := 0;
    x_org_id number := 0;
    x_old_org_id number := 0;
  BEGIN
    -- retrieve purchasing org id
    OPEN c_purchasing_org(p_req_header_id);
    LOOP
      FETCH c_purchasing_org INTO x_org, x_org_id;
       EXIT WHEN c_purchasing_org %NOTFOUND;
         if(x_counter = 0) then
           x_old_org_id := x_org_id;
           x_counter := x_counter + 1;
         elsif (x_old_org_id <> x_org_id) then
           x_org := 'MULTIPLE_VALUE';
           exit;
         end if;
    END LOOP;
    CLOSE c_purchasing_org;
    RETURN x_org;
  END GET_PURCHASING_ORG;

  /**
   * This function returns the purchasing organization name
   * if there is only one org associated with the requisition;
   * or returns 'MULTIPLE' if there is more than one org
   * associated with the requisition
   */
  FUNCTION GET_PURCH_ORG_FOR_LINE(p_req_line_id in number)
    RETURN varchar2 IS
  CURSOR c_purchasing_org (c_req_line_id NUMBER) IS
   SELECT
     HOU.NAME ORG_NAME,  PH.ORG_ID
   FROM
     PO_REQ_DISTRIBUTIONS_ALL PRD,
     PO_DISTRIBUTIONS_ALL PD,
     PO_HEADERS_ALL PH,
     HR_ALL_ORGANIZATION_UNITS_VL HOU
   WHERE
     PD.PO_HEADER_ID = PH.PO_HEADER_ID AND
     PRD.DISTRIBUTION_ID = PD.REQ_DISTRIBUTION_ID AND
     PRD.REQUISITION_LINE_ID = c_req_line_id AND
     PH.ORG_ID = HOU.ORGANIZATION_ID (+);

    x_org varchar2(80);
    x_counter number := 0;
    x_org_id number := 0;
    x_old_org_id number := 0;
  BEGIN
    -- retrieve purchasing org id
    OPEN c_purchasing_org(p_req_line_id);
    LOOP
      FETCH c_purchasing_org INTO x_org, x_org_id;
       EXIT WHEN c_purchasing_org %NOTFOUND;
         if(x_counter = 0) then
           x_old_org_id := x_org_id;
           x_counter := x_counter + 1;
         elsif (x_old_org_id <> x_org_id) then
           x_org := 'MULTIPLE_VALUE';
           exit;
         end if;
    END LOOP;
    CLOSE c_purchasing_org;

    RETURN x_org;
  END GET_PURCH_ORG_FOR_LINE;

function get_labor_line_supplier_name(req_line_id IN number) return varchar2 is
  no_of_suppliers number :=0;
  x_vendor_id number;
  suppliername varchar2(1000);

  begin

    select count(distinct nvl(vendor_id,0)), min(vendor_id)
    into no_of_suppliers, x_vendor_id
    from po_requisition_suppliers
    where requisition_line_id = req_line_id;

    if (no_of_suppliers > 1) then
      return 'MULTIPLE_VALUE';
    else
      if (x_vendor_id is not null) then
        select vendor_name
        into suppliername
        from po_vendors
        where vendor_id = x_vendor_id;

        return suppliername;
      else
        return null;
      end if;
    end if;
  end get_labor_line_supplier_name;

 /**************************************************************************
  * This procedure returns the given req's current approver's full name    *
  * and email.                                                             *
  **************************************************************************/
  PROCEDURE getCurrentApproverInfo(req_header_id IN NUMBER,
                      		   full_name OUT NOCOPY VARCHAR2,
                      		   email_address OUT NOCOPY VARCHAR2,
                                   phone OUT NOCOPY VARCHAR2,
                                   date_notified OUT NOCOPY DATE)
 IS
    l_approver_id       NUMBER;
    l_procedure_name    CONSTANT VARCHAR2(30) := 'getCurrentApproverInfo';
    l_log_msg           FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

  BEGIN

    G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    l_approver_id := POR_UTIL_PKG.GET_CURRENT_APPROVER(req_header_id);

    IF (nvl(l_approver_id, -1) = -1) THEN
       RETURN;
    END IF;

    SELECT pap.full_name, pap.email_address, (select ph.phone_number from per_phones ph  where
         ph.parent_table(+) = 'PER_ALL_PEOPLE_F' AND
         ph.parent_id (+) = fnd.employee_id AND
         ph.phone_type(+)  = 'W1' AND
         trunc(SYSDATE) BETWEEN nvl(PH.DATE_FROM, trunc(SYSDATE)) AND
         nvl(PH.DATE_TO, trunc(SYSDATE)) ) phone_number,
       wn.begin_date
    INTO   full_name, email_address, phone, date_notified
    FROM
      wf_notifications wn,
      wf_notification_attributes wna,
      wf_user_roles wlur,
      fnd_user fnd,
      po_requisition_headers_all prh,
      per_all_people_f pap
    WHERE
     prh.requisition_header_id = req_header_id AND
     wlur.user_name = fnd.user_name AND
     pap.person_id = fnd.employee_id AND
     fnd.employee_id = l_approver_id AND
     prh.requisition_header_id = wna.number_value AND
     wna.name = 'DOCUMENT_ID' AND
     wna.notification_id = wn.notification_id AND
     wn.recipient_role = wlur.role_name AND
     wn.status = 'OPEN' AND
     wn.message_type = prh.wf_item_type AND
     wn.message_name IN ('PO_REQ_APPROVE',
                         'PO_REQ_REMINDER1',
                         'PO_REQ_APPROVE_WEB_MSG',
                         'PO_REQ_REMINDER2',
                         'PO_REQ_REMINDER1_WEB',
                         'PO_REQ_REMINDER2_WEB',
                         'PO_REQ_APPROVE_JRAD',
                         'PO_REQ_APPROVE_SIMPLE',
                         'PO_REQ_APPROVE_SIMPLE_JRAD',
                         'PO_REQ_REMINDER1_JRAD',
                         'PO_REQ_REMINDER2_JRAD')
     AND TRUNC(sysdate) between pap.effective_start_date and pap.effective_end_date
     AND rownum = 1;

     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
       l_log_msg := 'Name: ' || full_name || ',Email: ' || email_address ||
                    ',Phone: ' || phone || ',Date Notified: ' || date_notified ;
       FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
     END IF;

  EXCEPTION
    when others then

      IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
        l_log_msg := 'Error in getCurrentApproverInfo. SQLERRM= ' || SQLERRM;
        FND_LOG.STRING(G_LEVEL_EXCEPTION, G_MODULE_NAME||l_procedure_name, l_log_msg);
      END IF;

      full_name := null;
      email_address := null;
      phone := null;
      date_notified := null;

  END getCurrentApproverInfo;

end por_view_reqs_pkg;

/
