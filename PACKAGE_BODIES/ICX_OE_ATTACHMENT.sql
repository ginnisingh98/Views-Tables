--------------------------------------------------------
--  DDL for Package Body ICX_OE_ATTACHMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_OE_ATTACHMENT" As
/* $Header: ICXOEATB.pls 115.1 99/07/17 03:18:49 porting ship $ */


PROCEDURE Load_QuoteAttachments(p_quote_id	in varchar2,
				p_order_id	in number,
				p_created_by	in number,
				p_last_update_login	in number,
				p_program_app_id	in number,
				p_program_id	in number,
				p_request_id	in number,
				x_err_message	out varchar2) is

begin

  fnd_attached_documents2_pkg.copy_attachments(x_from_entity_name => 'AS_QUOTE_ATTCH',
			x_from_pk1_value => p_quote_id,
			x_to_entity_name => 'SO_HEADERS_ALL',
			x_to_pk1_value => p_order_id,
			x_created_by => p_created_by,
			x_last_update_login => p_last_update_login,
			x_program_application_id => p_program_app_id,
			x_program_id => p_program_id,
			x_request_id => p_request_id);

exception
  when OTHERS then
	x_err_message := SQLERRM;

end Load_QuoteAttachments;


END ICX_OE_ATTACHMENT;

/
