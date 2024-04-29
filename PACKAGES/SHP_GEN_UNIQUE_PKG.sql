--------------------------------------------------------
--  DDL for Package SHP_GEN_UNIQUE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."SHP_GEN_UNIQUE_PKG" AUTHID CURRENT_USER as
/* $Header: SHPFXUQS.pls 115.0 99/07/16 08:17:28 porting ship $ */
--
-- Package
--   SHP_GEN_UNIQUE_PKG
-- Purpose
--   Server side generic uniqueness checking functionality
-- History
--   27-APR-95	JGOREE	Created
--

  --
  -- PUBLIC VARIABLES
  --

  --
  -- PUBLIC FUNCTIONS
  --

  --
  -- Name
  --   Gen_Check_Unique
  -- Purpose
  --   Checks for duplicates in database
  -- Arguments
  --   query_text               query to execute to test for uniqueness
  --   prod_name		product name to send message for
  --   msg_name			message to print if duplicate found
  --
  -- Notes
  --   uses DBMS_SQL package

  PROCEDURE Gen_Check_Unique(query_text VARCHAR2,
			 prod_name VARCHAR2,
			 msg_name VARCHAR2);

  PROCEDURE Get_Active_Date(query_text 		IN	VARCHAR2,
   			    date_fetched 	OUT	DATE);

END SHP_GEN_UNIQUE_PKG;

 

/
