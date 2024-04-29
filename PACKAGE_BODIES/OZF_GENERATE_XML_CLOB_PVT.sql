--------------------------------------------------------
--  DDL for Package Body OZF_GENERATE_XML_CLOB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_GENERATE_XML_CLOB_PVT" AS
/* $Header: ozfvxmlb.pls 115.2 2004/03/22 21:23:51 mgudivak noship $ */
-- Start of Comments
-- Package name     : ozf_generate_xml_clob_pvt
-- Purpose          :
-- History          : 09-OCT-2003  vansub   Created
-- NOTE             :
-- End of Comments



FUNCTION generate_offer_clob (p_event_name in varchar2,
                              p_event_key in varchar2,
                              p_parameter_list in wf_parameter_list_t default null)
RETURN CLOB
IS
  l_api_name                   CONSTANT VARCHAR2(30) := 'generate_offer_clob';
  l_api_version_number         CONSTANT NUMBER   := 1.0;

  l_ctx		   NUMBER;
  l_clob	   CLOB;

  l_list_header_id VARCHAR2(30);
  l_sql      	   VARCHAR2(32000);

BEGIN

  l_list_header_id := wf_event.GetValueForParameter('P_OFFER_ID',p_parameter_list);

  l_sql	     := 'select offer from ozf_offer_clob_v where list_header_id = :list_header_id';

  dbms_lob.createtemporary(l_clob,true,dbms_lob.session);

  l_ctx := dbms_xmlquery.newContext(l_sql);

  dbms_xmlquery.setbindvalue( l_ctx, 'list_header_id', l_list_header_id );
  dbms_xmlquery.setRaiseNoRowsException( l_ctx,false );

  l_clob := dbms_xmlquery.getXml(l_ctx);

  dbms_xmlquery.closeContext(l_ctx);

  return l_clob ;

EXCEPTION
  WHEN others THEN
    dbms_xmlquery.closeContext(l_ctx);
    raise;
END generate_offer_clob;

FUNCTION generate_quota_clob (p_event_name in varchar2,
                              p_event_key in varchar2,
                              p_parameter_list in wf_parameter_list_t default null)
RETURN CLOB
IS
  l_api_name                   CONSTANT VARCHAR2(30) := 'generate_offer_clob';
  l_api_version_number         CONSTANT NUMBER   := 1.0;

  l_ctx		   NUMBER;
  l_clob	   CLOB;

  l_fund_id	   VARCHAR2(30);
  l_sql      	   VARCHAR2(32000);

BEGIN

  l_fund_id  := wf_event.GetValueForParameter('P_FUND_ID',p_parameter_list);

  l_sql	     := 'select quota from ozf_quota_clob_v where fund_id = :fund_id';

  dbms_lob.createtemporary(l_clob,true,dbms_lob.session);

  l_ctx := dbms_xmlquery.newContext(l_sql);

  dbms_xmlquery.setbindvalue( l_ctx, 'fund_id', l_fund_id );
  dbms_xmlquery.setRaiseNoRowsException( l_ctx,false );

  l_clob := dbms_xmlquery.getXml(l_ctx);

  dbms_xmlquery.closeContext(l_ctx);

  return l_clob;

EXCEPTION
  WHEN others THEN
    dbms_xmlquery.closeContext(l_ctx);
    raise;
END generate_quota_clob;

FUNCTION generate_target_clob (p_event_name in varchar2,
                              p_event_key in varchar2,
                              p_parameter_list in wf_parameter_list_t default null)
RETURN CLOB
IS
  l_api_name                   CONSTANT VARCHAR2(30) := 'generate_target_clob';
  l_api_version_number         CONSTANT NUMBER   := 1.0;

  l_ctx			       NUMBER;
  l_clob		       CLOB;

  l_account_allocation_id      VARCHAR2(30);
  l_sql      		       VARCHAR2(32000);

BEGIN

  l_account_allocation_id  := wf_event.GetValueForParameter('P_ACCOUNT_ALLOCATION_ID',p_parameter_list);

  l_sql	     := 'select target from  ozf_target_clob_v where account_allocation_id = :account_allocation_id';

  dbms_lob.createtemporary(l_clob,true,dbms_lob.session);

  l_ctx := dbms_xmlquery.newContext(l_sql);

  dbms_xmlquery.setbindvalue( l_ctx, 'account_allocation_id', l_account_allocation_id );
  dbms_xmlquery.setRaiseNoRowsException( l_ctx,false );

  l_clob := dbms_xmlquery.getXml(l_ctx);

  dbms_xmlquery.closeContext(l_ctx);

  return l_clob;

EXCEPTION
  WHEN others THEN
    dbms_xmlquery.closeContext(l_ctx);
    raise;
END generate_target_clob;

FUNCTION test(p_subscription_guid in raw,
              p_event in out nocopy wf_event_t) return varchar2
           IS
  l_parameter_list wf_parameter_list_t;
  l_offer_id       VARCHAR2(30);

  l_event_id  VARCHAR2(30);
  l_msg       CLOB;
  l_out       NUMBER;

BEGIN

--Get parameters:

  l_parameter_list := WF_PARAMETER_LIST_T();
  l_parameter_list := p_event.GetParameterList;

  l_offer_id := wf_event.GetValueForParameter('P_OFFER_ID',l_parameter_list);

  l_out := dbms_lob.istemporary(p_event.GetEventData());

  l_msg := p_event.GetEventData();





--  insert into ozf_events values(l_offer_id, sysdate, l_msg);


  return 'SUCCESS';
/*
EXCEPTION
when others then
WF_CORE.CONTEXT('aml_import_event', 'test', p_event.getEventName(), p_subscription_guid);
WF_EVENT.setErrorInfo(p_event, 'ERROR');
raise;
return 'ERROR';
*/
END test;

END ozf_generate_xml_clob_pvt;

/
