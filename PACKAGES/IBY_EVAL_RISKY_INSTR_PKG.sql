--------------------------------------------------------
--  DDL for Package IBY_EVAL_RISKY_INSTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_EVAL_RISKY_INSTR_PKG" AUTHID CURRENT_USER AS
/*$Header: ibyevrks.pls 115.3 2002/11/18 22:31:49 jleybovi ship $*/


/*
** Procedure: eval_factor
** Purpose: Evaluates the risk associated with Risky Instruments
**          risk factor.
**          The risky instrument(creditcard numeber) will be passed into this routine
**          Compare the credit card number with the information stored in the
**          risky instrument repository ,if the ccnumber exists then the credit card
**          is fruadulent- return the risk score of 100.
*/

procedure eval_factor(i_instrid number,
                      i_ccnumber in varchar2,
                      i_payeeid in varchar2,
                      o_score out nocopy number);

end iby_eval_risky_instr_pkg;

 

/
