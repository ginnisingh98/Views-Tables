--------------------------------------------------------
--  DDL for Package ICX_OE_ATTACHMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_OE_ATTACHMENT" AUTHID CURRENT_USER As
/* $Header: ICXOEATS.pls 115.2 99/07/17 03:18:52 porting ship $ */


Procedure Load_QuoteAttachments(p_quote_id	in varchar2,
				p_order_id	in number,
				p_created_by	in number,
				p_last_update_login	in number,
				p_program_app_id	in number,
				p_program_id	in number,
				p_request_id	in number,
				x_err_message	out varchar2);



END ICX_OE_ATTACHMENT;

 

/
