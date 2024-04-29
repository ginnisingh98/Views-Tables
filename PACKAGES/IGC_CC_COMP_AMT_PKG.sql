--------------------------------------------------------
--  DDL for Package IGC_CC_COMP_AMT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CC_COMP_AMT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGCCCBAS.pls 120.4.12000000.1 2007/08/20 12:11:25 mbremkum ship $ */

FUNCTION COMPUTE_PF_BILLED_AMT(p_cc_det_pf_line_id NUMBER,
			       p_cc_det_pf_line_num NUMBER,
		               p_cc_acct_line_id    NUMBER)
RETURN NUMBER;

--PRAGMA RESTRICT_REFERENCES(COMPUTE_PF_BILLED_AMT, WNDS, WNPS);

FUNCTION COMPUTE_PF_FUNC_BILLED_AMT(p_cc_det_pf_line_id NUMBER,
			            p_cc_det_pf_line_num NUMBER,
		                    p_cc_acct_line_id    NUMBER)
RETURN NUMBER;

--PRAGMA RESTRICT_REFERENCES(COMPUTE_PF_BILLED_AMT, WNDS, WNPS);

FUNCTION COMPUTE_ACCT_BILLED_AMT(p_cc_acct_line_id  NUMBER)
RETURN NUMBER;

--PRAGMA RESTRICT_REFERENCES(COMPUTE_ACCT_BILLED_AMT, WNDS, WNPS);

FUNCTION COMPUTE_ACCT_FUNC_BILLED_AMT(p_cc_acct_line_id  NUMBER)
RETURN NUMBER;

FUNCTION COMPUTE_FUNCTIONAL_AMT(p_cc_header_id NUMBER, p_cc_func_amt NUMBER)
RETURN NUMBER;

FUNCTION COMPUTE_PF_BILL_AMT_CURR(p_cc_det_pf_line_id  NUMBER,
			            p_cc_det_pf_line_num  NUMBER,
		                    p_cc_acct_line_id     NUMBER)
RETURN NUMBER;

--PRAGMA RESTRICT_REFERENCES(COMPUTE_FUNCTIONAL_AMT, WNDS, WNPS);

FUNCTION COMPUTE_ACCT_BILLED_AMT_CURR(p_cc_acct_line_id NUMBER)
RETURN NUMBER;

END IGC_CC_COMP_AMT_PKG;

 

/
