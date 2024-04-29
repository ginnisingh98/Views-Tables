--------------------------------------------------------
--  DDL for Package FII_AR_CUSTOMER_DIMENSION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AR_CUSTOMER_DIMENSION_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIARCUSTS.pls 120.2.12000000.1 2007/02/23 02:27:44 applrt ship $ */

-- *******************************************************************
-- Package level variables
-- *******************************************************************

-- ************************************************************************
-- Procedure
--   Init_Load          This is the main procedure of the customer dimension
--                      maintenance program (initial load).
--                      It will take in all parameters, initialize all necessary
--                      variables and start calling the appropriate routines.
-- Arguments
--   errbuf		Standard error buffer
--   retcode 		Standard return code

  PROCEDURE Init_Load (errbuf		OUT	NOCOPY VARCHAR2,
		       retcode		OUT	NOCOPY VARCHAR2);

-- ************************************************************************
-- Procedure
--   Incre_Update       This is the main procedure of customer dimension
--                      maintenance program (incremental update).
--                      It will take in all parameters, initialize all necessary
--                      variables and start calling the appropriate routines.
-- Arguments
--   errbuf		Standard error buffer
--   retcode 		Standard return code

  PROCEDURE Incre_Update (errbuf   OUT  NOCOPY  VARCHAR2,
		          retcode  OUT  NOCOPY  VARCHAR2);


END FII_AR_CUSTOMER_DIMENSION_PKG;

 

/
