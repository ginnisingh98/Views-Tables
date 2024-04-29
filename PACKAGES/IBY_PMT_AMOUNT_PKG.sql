--------------------------------------------------------
--  DDL for Package IBY_PMT_AMOUNT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_PMT_AMOUNT_PKG" AUTHID CURRENT_USER as
/*$Header: ibypmtas.pls 115.2 2002/11/19 21:37:59 jleybovi ship $*/

    procedure eval_factor(i_payeeid in varchar2,
                          i_amount in  number,
                          o_score  out nocopy integer);

end iby_pmt_amount_pkg;


 

/
