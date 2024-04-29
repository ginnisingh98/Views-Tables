--------------------------------------------------------
--  DDL for Package IBY_RISK_SCORES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_RISK_SCORES_PKG" AUTHID CURRENT_USER as
/*$Header: ibyrisks.pls 115.4 2002/10/05 00:51:49 jleybovi ship $*/

    function getscore ( i_payeeid in varchar2,
                         i_score in varchar2 )
    return integer;

end iby_risk_scores_pkg;


 

/
