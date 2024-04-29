--------------------------------------------------------
--  DDL for Package Body IBY_EVAL_RISKY_INSTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_EVAL_RISKY_INSTR_PKG" AS
/*$Header: ibyevrkb.pls 120.1.12010000.2 2008/07/29 05:15:34 sugottum ship $*/


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
                      o_score out nocopy number)

is
l_count number;
l_ccnumber varchar2(30);
lx_cc_number iby_creditcard.ccnumber%TYPE;
lx_return_status VARCHAR2(1);
lx_msg_count     NUMBER;
lx_msg_data      VARCHAR2(200);
l_cc_hash1  iby_irf_risky_instr.cc_number_hash1%TYPE;
l_cc_hash2  iby_irf_risky_instr.cc_number_hash2%TYPE;
l_cc_strip_number iby_creditcard.ccnumber%TYPE;
begin
--dbms_output.put_line('ccnumber = '||i_ccnumber);
--dbms_output.put_line('instrid = '||to_char(i_instrid));
if (i_ccnumber is null and i_instrid <> -99) then
   select ccnumber into l_ccnumber
   from iby_creditcard
   where instrid = i_instrid;
else
   l_ccnumber := i_ccnumber;
end if;

-- Added for bug# 7228388. Compare the hash values of the credit card instead of
-- plain credit card number
IBY_CC_VALIDATE.StripCC
(1.0, FND_API.G_FALSE, l_ccnumber,
IBY_CC_VALIDATE.c_FillerChars,
lx_return_status, lx_msg_count, lx_msg_data, lx_cc_number);
-- Get hash values of the credit number
l_cc_hash1 := iby_security_pkg.get_hash(lx_cc_number,FND_API.G_FALSE);
l_cc_hash2 := iby_security_pkg.get_hash(lx_cc_number,FND_API.G_TRUE);
-- changed the query to include hash values in the column comparison
select count(*) into l_count
from iby_irf_risky_instr
where instrtype = 'CREDITCARD' and
      cc_number_hash1 = l_cc_hash1 and
      cc_number_hash2 = l_cc_hash2;

if (l_count = 0) then
   o_score := 0;
else
   o_score := iby_risk_scores_pkg.getscore(i_payeeid,'H');
end if;

end eval_factor;
end iby_eval_risky_instr_pkg;

/
