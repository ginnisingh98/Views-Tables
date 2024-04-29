--------------------------------------------------------
--  DDL for Package AMS_QP_INS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_QP_INS_PVT" AUTHID CURRENT_USER as
/* $Header: amsvqiss.pls 115.4 2002/09/12 19:14:58 julou ship $ */

-- Start of Comments
--
-- NAME
--   AMS_QP_INS_PVT
--
-- PURPOSE
--   This package is a Private API for creating the Mapping Rules for
--   different attributes used by Marketing
--
--   Procedures and Functions:
--     Create_MappingRule (see below for specification)
--
-- NOTES
--
--
-- HISTORY
--   01/26/2000        ptendulk         Created
-- End of Comments


--------------- start of comments --------------------------
-- NAME
--    Create_MappingRule
--
-- USAGE
--    This Procedure will map the Attributes by calling
--    different QP APIs
-- NOTES
--
-- HISTORY
--   01/26/2000        ptendulk            created
-- End of Comments
--
--------------- end of comments ----------------------------
PROCEDURE Create_MappingRule ;



END AMS_QP_INS_PVT ;

 

/
