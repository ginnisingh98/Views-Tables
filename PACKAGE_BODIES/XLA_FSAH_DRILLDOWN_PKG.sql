--------------------------------------------------------
--  DDL for Package Body XLA_FSAH_DRILLDOWN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_FSAH_DRILLDOWN_PKG" AS
/* $Header: xlafsahdrl.pkb 120.1.12010000.2 2009/08/05 12:28:32 karamakr noship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     XLA_FSAH_DRILLDOWN_PKG                                                      |
|                                                                            |
| DESCRIPTION                                                                |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|									     |
+===========================================================================*/

--====================================================================
--
--
--
--
--
--        PUBLIC  procedures and functions
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--======================================================================
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/

procedure GenerateUrl(ae_header_id IN number
               ,application_id IN number
	       ,p_lang_code IN varchar2
               ,p_url OUT NOCOPY varchar2) IS

	l_protocol_port VARCHAR2(1000) := ' ';
	l_protocol_port_value VARCHAR2(1000) := ' ';
	l_virtual_path VARCHAR2(1000) := ' ';
	l_preview_link VARCHAR2(4000) := ' ';
	l_function_id NUMBER;
        l_resp_id NUMBER;
        l_resp_appl_id NUMBER;
        l_security_group_id NUMBER;

	BEGIN
	  SELECT fnd_profile.VALUE('ICX_FORMS_LAUNCHER')
	  INTO l_protocol_port
	  FROM dual;

	  SELECT fnd_profile.VALUE('ICX_OA_HTML')
	  INTO l_virtual_path
	  FROM dual;

	  SELECT function_id
	  INTO l_function_id
	  FROM fnd_form_functions
	  WHERE function_name = 'XLA_LINESINQ_FSAH_DRILLDOWN';


	  select SUBSTR(FND_PROFILE.VALUE('ICX_FORMS_LAUNCHER'),1,INSTR(FND_PROFILE.VALUE('ICX_FORMS_LAUNCHER'),'/',1,3))
	  into l_protocol_port_value
	  from dual;

	  SELECT distinct
		rs.responsibility_id,
		rs.APPLICATION_ID,
		ur.SECURITY_GROUP_ID
	  INTO  l_resp_id,l_resp_appl_id,l_security_group_id
	  FROM fnd_responsibility rs,
	  FND_USER_RESP_GROUPS_ALL ur
	  WHERE rs.responsibility_id= ur.responsibility_id
	  and  responsibility_key='SLA_FSAH_LINESINQ_DRILLDOWN';


	  l_preview_link := l_protocol_port_value || l_virtual_path||'/'||
	                  'RF.jsp?function_id='||l_function_id
	                  ||'&'||'resp_id='||l_resp_id||'&'||'resp_appl_id='||l_resp_appl_id||'&'||'security_group_id='||l_security_group_id||'&'||'lang_code='||p_lang_code ||'&'||'aeHeaderId='||ae_header_id||'&'||'applId='||application_id;

	  p_url := l_preview_link;

	  EXCEPTION
	  WHEN OTHERS  THEN
		xla_exceptions_pkg.raise_message
               (p_location => 'XLA_FSAH_DRILLDOWN_PKG.GenerateUrl');



END;
END XLA_FSAH_DRILLDOWN_PKG; --

/
