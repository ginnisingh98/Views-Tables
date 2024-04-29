--------------------------------------------------------
--  DDL for Package Body IBY_SHIPTO_BILLTO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_SHIPTO_BILLTO_PKG" as
/*$Header: ibystbtb.pls 115.2 2002/11/20 00:16:14 jleybovi ship $*/

    procedure eval_factor(i_payeeid varchar2,
                          i_scoreType in varchar2,
                          o_score out nocopy integer)
    is

    begin

        o_score := iby_risk_scores_pkg.getScore(i_payeeid, i_scoreType);

    end eval_factor;

end iby_shipto_billto_pkg;


/
