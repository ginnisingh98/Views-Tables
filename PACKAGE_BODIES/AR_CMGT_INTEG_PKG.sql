--------------------------------------------------------
--  DDL for Package Body AR_CMGT_INTEG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CMGT_INTEG_PKG" AS
/* $Header: ARCMINTB.pls 115.5 2003/10/07 22:24:54 apandit noship $ */


/*========================================================================
 | PUBLIC FUNCTION credit_summary_data_exists
 |
 | DESCRIPTION
 |     This function verifies the existence of credit
 |     summary data for a fiven party/account/site in credit management.
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
             ( p_party_id         IN NUMBER  ,
               p_cust_account_id  IN NUMBER  ,
               p_site_use_id      IN  NUMBER )
   RETURN  VARCHAR2 IS
l_return   VARCHAR2(1);
BEGIN

 l_return :=  AR_CMGT_UTIL.check_casefolder_exists(p_party_id,
                                     nvl(p_cust_account_id,-99),
                                     nvl(p_site_use_id,-99));
 RETURN l_return;

END credit_summary_data_exists;

END AR_CMGT_INTEG_PKG;

/
