--------------------------------------------------------
--  DDL for Package IEM_SENDMAIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_SENDMAIL_PVT" AUTHID CURRENT_USER as
/* $Header: iemvsoms.pls 115.3 2002/12/05 06:14:03 sboorela shipped $*/
TYPE email_encrypt_rec_type IS RECORD (
          encrypt_key   varchar2(100),
          encrypt_value varchar2(500));

TYPE email_encrypt_tbl IS TABLE OF email_encrypt_rec_type
           INDEX BY BINARY_INTEGER;
	PROCEDURE 	IEM_CHK_TEMPLATE(
				 p_template_id in number,
				 x_status	 OUT NOCOPY varchar2);
	PROCEDURE 	IEM_SENDMAIL(
				p_user in varchar2,
				 p_domain in varchar2,
				 p_password in varchar2,
				 p_replyto in varchar2,
				 p_file_id in number,
				 p_subject in varchar2,
				 p_tostr	 in varchar2,
				 p_fromstr in varchar2,
				 p_encrypt_tbl in email_encrypt_tbl,
				 x_status	 OUT NOCOPY varchar2,
				 x_return_text OUT NOCOPY varchar2
							);
end IEM_SENDMAIL_PVT;

 

/
