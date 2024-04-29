--------------------------------------------------------
--  DDL for Package Body IGI_EXP_DIAL_UNIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_EXP_DIAL_UNIT_PKG" as
-- $Header: igiexpcb.pls 115.13 2003/08/09 11:35:59 rgopalan ship $
PROCEDURE AP_DOCUMENTS(p_exp_acc in varchar2,
                         p_eng_num in varchar2,
                         p_chart_id in number,
                         p_books_id in number,
                         p_org_id in number,
                         p_dial_unit_id in number,
			 p_curr in varchar2)
IS
BEGIN
  null;
END AP_DOCUMENTS;

PROCEDURE  ADD_AP_DOCUMENTS(p_exp_acc        in varchar2,
                            p_eng_num        in varchar2,
                            p_chart_id       in number,
                            p_books_id       in number,
                            p_org_id         in number,
                            p_third_party_id in number,
                            p_site_id        in number,
                            p_trx_type_id    in number,
                            p_dial_unit_id   in number,
			    p_curr in varchar2)
IS
BEGIN
   NULL;
END ADD_AP_DOCUMENTS;


PROCEDURE AR_DOCUMENTS(p_rev_acc in varchar2,
                       p_eng_num in varchar2,
                       p_chart_id in number,
                       p_books_id in number,
                       p_org_id in number,
                       p_dial_unit_id in number,
		       p_curr in varchar2)
IS
BEGIN
   null;
END AR_DOCUMENTS;


PROCEDURE  ADD_AR_DOCUMENTS(p_rev_acc        in varchar2,
                            p_eng_num        in varchar2,
                            p_chart_id       in number,
                            p_books_id       in number,
                            p_org_id         in number,
                            p_third_party_id in number,
                            p_site_id        in number,
                            p_trx_type_id    in number,
                            p_dial_unit_id   in number,
			    p_curr in varchar2)
IS
BEGIN
   NULL;
END ADD_AR_DOCUMENTS;


PROCEDURE DELETE_DOCUMENTS(session_id in number)
IS
p_session_id  number(15) := session_id;
BEGIN
   null;
END DELETE_DOCUMENTS;

Procedure ar_complete
	(p_customer_trx  IN number,
	 p_result	 OUT NOCOPY varchar2)
IS
begin
   null;
end ar_complete;

end IGI_EXP_DIAL_UNIT_PKG;

/
