--------------------------------------------------------
--  DDL for Package IGI_IAC_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_EXTRACT_PKG" AUTHID CURRENT_USER AS
/* $Header: igiacexs.pls 120.0.12000000.2 2007/10/31 09:46:24 npandya noship $ */

PROCEDURE extract
   (p_application_id     IN number,
    p_accounting_mode    IN varchar2);

PROCEDURE extract_revaluations
   (p_application_id     IN number,
    p_accounting_mode    IN varchar2);


PROCEDURE extract_transactions
   (p_application_id     IN number,
    p_accounting_mode    IN varchar2);

function amount_switch(p_adj_type  varchar2,
                       p_side_flag varchar2,
                       p_amount    number)
return number;

END igi_iac_extract_pkg;

 

/
