--------------------------------------------------------
--  DDL for Package Body ENI_EDW_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_EDW_UTILS" AS
/* $Header: ENIEDWUB.pls 115.0 2004/01/12 10:48:06 dsakalle noship $  */

-- This Public function will return always TRUE. This is used by EDWCORE to identify whether ENI is
-- supporting the Child Org. in Purchasing category set or not
FUNCTION IS_CHILD_ORG_SUPPORTED RETURN VARCHAR2 IS
BEGIN
  RETURN 'TRUE';
END IS_CHILD_ORG_SUPPORTED;

END ENI_EDW_UTILS;

/
