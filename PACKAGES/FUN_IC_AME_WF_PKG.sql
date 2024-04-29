--------------------------------------------------------
--  DDL for Package FUN_IC_AME_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_IC_AME_WF_PKG" AUTHID CURRENT_USER AS
/* $Header: funicameas.pls 120.0 2004/10/13 12:56:50 bsilveir noship $ */


/* ---------------------------------------------------------------------------
Name      : get_attribute_value
Pre-reqs  : None.
Modifies  : None.
Function  : This function returns the values for the intercompany  transaction
            attributes that are used within AME. These values are used when
            evaluating AME rules and conditions
Parameters:
    IN    : p_transaction_id - fun_trx_headers.trx_id
            p_dist_id        - fun_trx_dist_lines.dist_id
            p_attribute_name - Name of the attribute whose value is required.
    OUT   : Value of the attribute.
Notes     : None.
Testing   : This function can be tested using the 'Test' tab provided within AME
            setup pages
------------------------------------------------------------------------------*/
FUNCTION get_attribute_value
         (p_transaction_id      IN NUMBER,
          p_dist_id             IN NUMBER DEFAULT NULL,
          p_attribute_name      IN VARCHAR2)
RETURN VARCHAR2 ;

/* ---------------------------------------------------------------------------
Name      : get_fun_dist_acct_flex
Pre-reqs  : None.
Modifies  : None.
Function  : This function will be called from within AME to get the value of
            the accounting flexfields qualifying segments enabling users to
            build rules based on them.
Parameters:
    IN    : p_seg_name       - Name of the Segment
                  Eg. GL_ACCOUNT, GL_BALANCING, FA_COST_CTR
            p_ccid           - Code Combination Id
            p_dist_id        - fun_trx_dist_lines.dist_id
            p_transaction_id - fun_trx_headers.trx_id
    OUT   : Value of the attribute.
Notes     : None.
Testing   : This function can be tested using the 'Test' tab provided within AME
            setup pages
------------------------------------------------------------------------------*/
FUNCTION get_fun_dist_acct_flex(p_seg_name IN VARCHAR2,
               P_ccid     IN NUMBER,
               p_dist_id  IN NUMBER,
               p_transaction_id IN NUMBER)
RETURN VARCHAR2 ;


END;


 

/
