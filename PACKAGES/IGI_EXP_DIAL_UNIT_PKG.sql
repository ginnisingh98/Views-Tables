--------------------------------------------------------
--  DDL for Package IGI_EXP_DIAL_UNIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_EXP_DIAL_UNIT_PKG" AUTHID CURRENT_USER as
-- $Header: igiexpcs.pls 115.9 2002/11/18 08:38:56 sowsubra ship $
  PROCEDURE AP_DOCUMENTS(p_exp_acc in varchar2,
                         p_eng_num in varchar2,
                         p_chart_id in number,
                         p_books_id in number,
                         p_org_id in number,
                         p_dial_unit_id in number,
			 p_curr in varchar2);


  PROCEDURE AR_DOCUMENTS(p_rev_acc in varchar2,
                         p_eng_num in varchar2,
                         p_chart_id in number,
                         p_books_id in number,
                         p_org_id in number,
                         p_dial_unit_id in number,
			 p_curr in varchar2);


 PROCEDURE  ADD_AP_DOCUMENTS(p_exp_acc in varchar2,
                             p_eng_num in varchar2,
                             p_chart_id in number,
                             p_books_id       in number,
                             p_org_id         in number,
                             p_third_party_id in number,
                             p_site_id        in number,
                             p_trx_type_id    in number,
                             p_dial_unit_id   in number,
			     p_curr in varchar2);


 PROCEDURE  ADD_AR_DOCUMENTS(p_rev_acc        in varchar2,
                             p_eng_num        in varchar2,
                             p_chart_id       in number,
                             p_books_id       in number,
                             p_org_id         in number,
                             p_third_party_id in number,
                             p_site_id        in number,
                             p_trx_type_id    in number,
                             p_dial_unit_id   in number,
			     p_curr in varchar2);


 PROCEDURE DELETE_DOCUMENTS(session_id in number);

 PROCEDURE AR_COMPLETE(p_customer_trx in number,
			p_result      out NOCOPY varchar2);

END;

 

/
