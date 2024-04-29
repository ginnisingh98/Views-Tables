--------------------------------------------------------
--  DDL for Package HZ_BES_BO_SITE_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_BES_BO_SITE_UTIL_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHBESSS.pls 120.0 2005/08/10 22:47:44 smattegu noship $ */

--
-- Purpose: This package offers
-- 1. Checking if a given business object is complete or not
-- 2. Checking the event type for a completed business object
--
-- global variables
G_ORG_BO_CODE       HZ_BUS_OBJ_DEFINITIONS.BUSINESS_OBJECT_CODE%TYPE;
G_PER_BO_CODE       HZ_BUS_OBJ_DEFINITIONS.BUSINESS_OBJECT_CODE%TYPE;
G_ORG_CUST_BO_CODE  HZ_BUS_OBJ_DEFINITIONS.BUSINESS_OBJECT_CODE%TYPE;
G_PER_CUST_BO_CODE  HZ_BUS_OBJ_DEFINITIONS.BUSINESS_OBJECT_CODE%TYPE;

PROCEDURE BO_COMPLETE_CHECK
 ( P_BO_CODE     IN VARCHAR2);

PROCEDURE BO_EVENT_CHECK
 ( P_BO_CODE IN VARCHAR2);

END HZ_BES_BO_SITE_UTIL_PKG; -- end of pkg spec

 

/
