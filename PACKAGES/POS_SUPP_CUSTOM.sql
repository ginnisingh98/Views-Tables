--------------------------------------------------------
--  DDL for Package POS_SUPP_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_SUPP_CUSTOM" AUTHID CURRENT_USER as
/* $Header: POSSUPCS.pls 115.0 2001/07/08 20:31:40 pkm ship       $ */


 function validateSupplier(p_supplier in varchar2,
			p_addr1 in varchar2,
			p_addr2 in varchar2,
			p_addr3 in varchar2,
			p_city in varchar2,
			p_province in varchar2,
			p_county in varchar2,
			p_state in varchar2,
			p_zip in varchar2,
			p_country in varchar2)
                        return number;

 procedure setDomain(p_username   in varchar2,
		     p_supplier_id       in number,
		     p_email_address     in varchar2,
                     p_new_username out varchar2);

 function validateContact(p_supplier_id in number,
			p_first_name in varchar2,
			p_last_name  in varchar2,
			p_phone_number in varchar2,
			p_mail_stop in varchar2,
                        p_addr1 in varchar2,
                        p_addr2 in varchar2,
                        p_addr3 in varchar2,
                        p_city in varchar2,
                        p_province in varchar2,
                        p_county in varchar2,
                        p_state in varchar2,
                        p_zip in varchar2,
                        p_country in varchar2)
			return number;

 procedure GetApprover (p_supplier_id     IN NUMBER,
			p_contact_id	  IN NUMBER,
			p_user_id	  IN NUMBER,
			p_approver_id	  IN OUT NUMBER,
			p_approver_name   IN OUT VARCHAR2);

 procedure GetContactSelector (p_supplier_id     IN NUMBER,
                        p_approver_id     IN OUT NUMBER,
                        p_approver_name   IN OUT VARCHAR2);

 procedure GetAcctAdmin(p_supplier_id in number,
                       p_admin_id out number,
                       p_admin_name out varchar2,
		       p_display_admin_name out varchar2);

 function VerifySelfApproval(p_supplier_id IN NUMBER)
			     return BOOLEAN;

 function VerifyAuthority(p_supplier_id IN NUMBER,
			  p_approver_id IN NUMBER)
			  return BOOLEAN;

end pos_supp_custom;

 

/
