--------------------------------------------------------
--  DDL for Package ENI_EDW_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENI_EDW_UTILS" AUTHID CURRENT_USER AS
/* $Header: ENIEDWUS.pls 115.0 2004/01/12 10:47:53 dsakalle noship $  */

-- This Public function will return always TRUE. This is used by EDWCORE to identify whether ENI is
-- supporting the Child Org. in Purchasing category set or not
FUNCTION IS_CHILD_ORG_SUPPORTED RETURN VARCHAR2;

END ENI_EDW_UTILS;

 

/
