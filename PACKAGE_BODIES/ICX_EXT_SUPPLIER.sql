--------------------------------------------------------
--  DDL for Package Body ICX_EXT_SUPPLIER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_EXT_SUPPLIER" as
/* $Header: ICXEXSPB.pls 115.4 2001/11/14 09:50:13 pkm ship    $ */

PROCEDURE authenticate_user(ticket in number) is

	user_record		icx_requisitioner_info%ROWTYPE;
	l_session_id 	number;
	l_company 	varchar2(100);
	l_url			varchar2(2000);
	l_user_name		varchar2(100);

	CURSOR req_user_cursor IS
	SELECT fu.user_name, ipss.company, iri.operating_unit,
		 iri.ship_to, iri.deliver_to, iri.req_token,
		 iri.http_host, ipss.callback_URL
	FROM 	 icx_procurement_server_setup ipss,
		 icx_sessions ics, fnd_user fu,
		 icx_requisitioner_info iri,
                 icx_por_item_sources it
	WHERE	 ics.disabled_flag = 'N'
	AND	 iri.session_id = ics.session_id
	AND 	 ics.user_id = fu.user_id
	AND 	 iri.encrypted_session_id = ticket
        AND      it.item_source_id = ipss.item_source_id
        AND      it.protocol_supported is null;
BEGIN

	OPEN req_user_cursor ;

	FETCH req_user_cursor
	INTO  l_user_name, l_company, user_record.operating_unit,
	      user_record.ship_to, user_record.deliver_to,
	      user_record.req_token, user_record.http_host, l_url;

	if (req_user_cursor%FOUND) THEN

		htp.p('<?xml version=''1.0''?>');
		htp.p('<RequisitionUser>');
		htp.p('<userName>'||l_user_name||'</userName>');
		htp.p('<company>'||l_company ||'</company>');
		htp.p('<operatingUnit>'||user_record.operating_unit||'</operatingUnit>');
		htp.p('<shipTo>'||user_record.ship_to||'</shipTo>');
		htp.p('<deliverTo>'||user_record.deliver_to||'</deliverTo>');
		htp.p('<reqToken>'||user_record.req_token||'</reqToken>');
		htp.p('<returnURL>'|| FND_WEB_CONFIG.PROTOCOL ||'//'||user_record.http_host||l_url||'</returnURL>');
		htp.p('</RequisitionUser>');

	else
		htp.p('<?xml version=''1.0''?>');
		htp.p('<InvalidUser>');
		htp.p('<message>Invalid User</message>');
		htp.p('</InvalidUser>');

	end if;

	CLOSE req_user_cursor;

	EXCEPTION
        	when others then
                htp.p(SQLERRM);


END authenticate_user;

END icx_ext_supplier;

/
