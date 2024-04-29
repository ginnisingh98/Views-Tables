--------------------------------------------------------
--  DDL for Package Body AR_IDEP_STATUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_IDEP_STATUS" AS
/* $Header: ARXIDSTB.pls 120.1 2005/08/01 11:49:44 naneja noship $ */

/*===========================================================================+
 | FUNCTION                                                                  |
 |    ar_idep_flag                                                           |
 |    RETURN VARCHAR2                                                        |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This Fuction returs YES for Ideposit and NO otherwise                      |
+===========================================================================*/

FUNCTION ar_idep_flag
    RETURN VARCHAR2 is
BEGIN
RETURN 'NO';
END ar_idep_flag;

END AR_IDEP_STATUS;


/
