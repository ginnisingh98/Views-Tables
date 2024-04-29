--------------------------------------------------------
--  DDL for Package IBY_SHIPTO_BILLTO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_SHIPTO_BILLTO_PKG" AUTHID CURRENT_USER as
/*$Header: ibystbts.pls 115.2 2002/11/20 00:16:07 jleybovi ship $*/

    procedure eval_factor(i_payeeid in varchar2,
                          i_scoreType in  varchar2,
                          o_score  out nocopy integer);

end iby_shipto_billto_pkg;


 

/
