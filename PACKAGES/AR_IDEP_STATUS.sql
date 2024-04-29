--------------------------------------------------------
--  DDL for Package AR_IDEP_STATUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_IDEP_STATUS" AUTHID CURRENT_USER AS
/* $Header: ARXIDSTS.pls 120.1 2005/08/01 11:51:12 naneja noship $ */
/*===========================================================================+
 | FUNCTION                                                                  |
 |    ar_idep_flag                                                           |
 |    RETURN VARCHAR2                                                        |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This Fuction returs Yes for iDeposit user and NO otherwise                      |
 =============================================================================*/

FUNCTION ar_idep_flag RETURN VARCHAR2;

END AR_IDEP_STATUS;


 

/
