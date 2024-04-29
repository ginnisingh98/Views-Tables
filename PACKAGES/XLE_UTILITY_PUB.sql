--------------------------------------------------------
--  DDL for Package XLE_UTILITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLE_UTILITY_PUB" AUTHID CURRENT_USER AS
/* $Header: xleutils.pls 120.1 2005/01/21 23:32:58 guyuan ship $ */

FUNCTION created_by RETURN NUMBER;

FUNCTION creation_date RETURN DATE;

FUNCTION last_updated_by RETURN NUMBER;

FUNCTION last_update_date RETURN DATE;

FUNCTION last_update_login RETURN NUMBER;

END XLE_Utility_PUB;

 

/
