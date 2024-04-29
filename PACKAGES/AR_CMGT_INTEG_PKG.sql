--------------------------------------------------------
--  DDL for Package AR_CMGT_INTEG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CMGT_INTEG_PKG" AUTHID CURRENT_USER AS
/* $Header: ARCMINTS.pls 115.1 2003/09/22 19:13:14 apandit noship $ */


/*========================================================================
 | PUBLIC FUNCTION ABC
 |
 | DESCRIPTION
 |     This function verifies the existence of credit
 |     summary data for a fiven party/account/site in credit management.
 |
 |
 | PSEUDO CODE/LOGIC
 |
 |
 | KNOWN ISSUES
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 *=======================================================================*/
FUNCTION credit_summary_data_exists
             (  p_party_id         IN NUMBER  ,
                p_cust_account_id  IN NUMBER,
                p_site_use_id      IN  NUMBER)
   RETURN  VARCHAR2;

END AR_CMGT_INTEG_PKG;

 

/
