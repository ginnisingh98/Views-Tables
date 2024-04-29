--------------------------------------------------------
--  DDL for Package Body GMO_MBR_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMO_MBR_UTIL" AS
/* $Header: GMOMBRUB.pls 120.12 2006/10/06 11:20:19 rvsingh noship $ */

  FUNCTION GET_TEMPLATE_CODE(P_EVENT_NAME VARCHAR2,P_EVENT_KEY VARCHAR2) RETURN VARCHAR2 IS
    L_ame_rule_ids           FND_TABLE_OF_VARCHAR2_255;
    L_ame_rule_descriptions  FND_TABLE_OF_VARCHAR2_255;
    L_variable_names         FND_TABLE_OF_VARCHAR2_255;
    L_variable_values        FND_TABLE_OF_VARCHAR2_255;
  BEGIN
    edr_utilities.get_rules_and_variables(P_EVENT_NAME => P_EVENT_NAME
                                         ,P_EVENT_KEY =>P_EVENT_KEY
                                         ,X_AME_RULE_IDS          => l_ame_rule_ids
                                         ,X_AME_RULE_DESCRIPTIONS => l_ame_rule_descriptions
                                         ,X_VARIABLE_NAMES        => l_variable_names
                                         ,X_VARIABLE_VALUES       => l_variable_values);
   --  Bug 5563819 : start : rvsingh
    IF l_variable_names IS NOT NULL THEN
	    FOR i in 1..l_variable_names.count
	    LOOP
	      IF l_variable_names(i) = 'EREC_STYLE_SHEET'
	      THEN
	        RETURN l_variable_values(i);
	      END IF;
	    END LOOP;
    END IF;
   --  Bug 5563819 : End : rvsingh
  END;
  FUNCTION GET_MBR_XML(P_EVENT_NAME VARCHAR2,P_EVENT_KEY VARCHAR2) RETURN CLOB IS
    l_xml CLOB;
    l_error_code NUMBER;
    l_error_msg VARCHAR2(4000);
    l_log_file VARCHAR2(4000);
    l_map_code VARCHAR2(50);
    l_CNT      NUMBER;
    CURSOR GET_MAP_CODE IS
       SELECT distinct b.STATUS,
              EDR_INDEXED_XML_UTIL.GET_WF_PARAMS('EDR_XML_MAP_CODE',b.GUID) map_code
       from wf_events_vl a,
            wf_event_subscriptions b
       WHERE a.guid=b.EVENT_FILTER_GUID
         and b.RULE_FUNCTION ='EDR_PSIG_RULE.PSIG_RULE'
         and a.name = p_event_name
       ORDER BY b.STATUS DESC;
  BEGIN
    select count(*) INTO l_cnt
    from   wf_events_vl a,
           wf_event_subscriptions b
    WHERE a.guid=b.EVENT_FILTER_GUID
      and b.RULE_FUNCTION ='EDR_PSIG_RULE.PSIG_RULE'
      and b.status = 'ENABLED'
      and a.name = p_event_name;
    IF l_cnt > 1 THEN
      return null;
    ELSE
      l_cnt := 0;
      FOR GET_MAP_CODE_REC in  GET_MAP_CODE
      LOOP
        l_map_code := GET_MAP_CODE_REC.map_code;
        l_cnt := l_cnt + 1;
      END LOOP;
      IF L_CNT = 1
      THEN
         edr_utilities.generate_xml(P_MAP_CODE     => nvl(l_map_code,P_EVENT_NAME)
                                   ,P_DOCUMENT_ID  => P_EVENT_KEY
                                   ,p_xml          => l_xml
                                   ,p_error_code   => l_error_code
                                   ,p_error_msg    => l_error_msg
                                   ,p_log_file     => l_log_file);
         RETURN l_xml;
       ELSE
         RETURN NULL;
       END IF;
     END IF;
     RETURN l_xml;
  END;
  /************************************************************************
   ** Local function to retrieve Query ID based on event Name and Key
   ** EDR Utility Functions.
   **
   ************************************************************************/

   FUNCTION GET_QUERY_ID(P_EVENT_NAME VARCHAR2,P_EVENT_KEY VARCHAR2) RETURN NUMBER IS
    L_event_names            FND_TABLE_OF_VARCHAR2_255;
    L_event_keys             FND_TABLE_OF_VARCHAR2_255;
    L_QUERY_ID               NUMBER;
    BEGIN
      --Initialize the the event names array containing only one element.
    L_event_names        := FND_TABLE_OF_VARCHAR2_255();
    L_event_names.EXTEND;
        --Initialize the the event key array containing only one element.
    L_event_keys        := FND_TABLE_OF_VARCHAR2_255();
    L_event_keys.EXTEND;
    L_event_names(1)        := P_EVENT_NAME;
    L_event_keys(1)         := P_EVENT_KEY;
    edr_standard.PSIG_QUERY_ONE ( p_event_name => L_event_names ,
                                  p_event_key  => L_event_keys ,
                                  o_query_id   => L_QUERY_ID);
    RETURN L_QUERY_ID;
  END;

  PROCEDURE GET_TEMPLATE_CODE_AND_XML(P_EVENT_NAME VARCHAR2,
                                      P_EVENT_KEY VARCHAR2,
                                      X_TEMPLATE_CODE OUT NOCOPY VARCHAR2,
                                      X_QUERY_ID OUT NOCOPY NUMBER,
                                      X_MBR_XML OUT NOCOPY CLOB) IS
  BEGIN
    X_TEMPLATE_CODE := GMO_MBR_UTIL.get_template_code(p_event_name => P_EVENT_NAME,
                                                      p_event_key => P_EVENT_KEY);

    -- generate XML only when template code is present
    IF X_TEMPLATE_CODE IS NOT NULL
    THEN
       X_MBR_XML :=  GMO_MBR_UTIL.get_mbr_xml(p_event_name => P_EVENT_NAME,
                                              p_event_key => P_EVENT_KEY);
       X_QUERY_ID := GMO_MBR_UTIL.GET_QUERY_ID(p_event_name => P_EVENT_NAME,
                                              p_event_key => P_EVENT_KEY);
    END IF;
  END;


 PROCEDURE GET_TEMPLATE_CODE_AND_QUERYID(P_EVENT_NAME VARCHAR2,
                                      P_EVENT_KEY VARCHAR2,
                                      X_TEMPLATE_CODE OUT NOCOPY VARCHAR2,
                                      X_QUERY_ID OUT NOCOPY NUMBER) IS
 BEGIN
    X_TEMPLATE_CODE := GMO_MBR_UTIL.get_template_code(p_event_name => P_EVENT_NAME,
                                                      p_event_key => P_EVENT_KEY);
    X_QUERY_ID := GMO_MBR_UTIL.GET_QUERY_ID(p_event_name => P_EVENT_NAME,
                                             p_event_key => P_EVENT_KEY);
  END;

PROCEDURE GET_USER_DISPLAY_NAME (P_USER_ID IN NUMBER, P_USER_DISPLAY_NAME OUT nocopy VARCHAR2)as
BEGIN
  GMO_UTILITIES.GET_USER_DISPLAY_NAME(P_USER_ID,P_USER_DISPLAY_NAME);
END GET_USER_DISPLAY_NAME;

procedure get_organization (P_MBR_EVT_KEY IN VARCHAR2,
                            X_ORG_CODE OUT NOCOPY VARCHAR2,
                            X_ORG_NAME OUT NOCOPY VARCHAR2) IS
l_org_id NUMBER(15) :=NULL;
BEGIN
  Select substr(P_MBR_EVT_KEY,
                      to_number(instr(P_MBR_EVT_KEY,'-'))+1,
                      decode(instr(P_MBR_EVT_KEY,'-',1,2),0,length(P_MBR_EVT_KEY),
                      to_number(instr(P_MBR_EVT_KEY,'-',1,2))-to_number(instr(P_MBR_EVT_KEY,'-'))-1))
  into l_org_id  from dual;

  SELECT hou.name ORGANIZATION_NAME , mp.organization_code ORGANIZATION_CODE into X_ORG_NAME,X_ORG_CODE
      FROM hr_all_organization_units hou, mtl_parameters mp
      WHERE hou.organization_id = l_org_id
         and mp.organization_id = hou.organization_id;
END get_organization;

FUNCTION GET_DISPENSE_CONFIG(P_INVENTORY_ITEM_ID IN NUMBER,P_ORGANIZATION_ID IN  NUMBER,P_RECIPE_ID IN  NUMBER) RETURN NUMBER
IS
l_config_id NUMBER(15);
l_dispense_required varchar2(5);
BEGIN
  GMO_DISPENSE_SETUP_PVT.IS_DISPENSE_ITEM(p_inventory_item_id => p_inventory_item_id,
                                          p_organization_id => nvl(G_ORGANIZATION_ID,p_organization_id),
                                          p_recipe_id => p_recipe_id,
					            x_is_dispense_required => l_dispense_required,
					            x_dispense_config_id => l_config_id);
  RETURN nvl(l_config_id,-1);
END GET_DISPENSE_CONFIG;

FUNCTION SET_GLOBAL_ORGID(P_MBR_EVT_KEY IN VARCHAR2) RETURN NUMBER
IS
l_flag NUMBER :=1;
BEGIN
Select substr(P_MBR_EVT_KEY,
                      to_number(instr(P_MBR_EVT_KEY,'-'))+1,
                      decode(instr(P_MBR_EVT_KEY,'-',1,2),0,length(P_MBR_EVT_KEY),
                      to_number(instr(P_MBR_EVT_KEY,'-',1,2))-to_number(instr(P_MBR_EVT_KEY,'-'))-1))
  into G_ORGANIZATION_ID  from dual;
RETURN l_flag;
END SET_GLOBAL_ORGID;

END GMO_MBR_UTIL;

/
