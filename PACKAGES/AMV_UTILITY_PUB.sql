--------------------------------------------------------
--  DDL for Package AMV_UTILITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMV_UTILITY_PUB" AUTHID CURRENT_USER AS
/* $Header: amvputls.pls 115.4 2000/01/19 18:12:36 pkm ship $ */
-- Start of Comments
--
-- NAME
--   AMV_UTILITY_PUB
--
-- PURPOSE
--   This package is a Public Utility API in AMV.
--   It contains specification for pl/sql records, array, and procedures.
--
--   Procedures:
--        ...
--
-- NOTES
--
--
-- HISTORY
--   06/01/1999        PWU            created
-- End of Comments

------------------------------
-- Global Package Variables --
------------------------------
  G_MAX_VARRAY_SIZE       CONSTANT    NUMBER   := 5000;
-----------------------------------
-- System-wide Initialized Objects --
-------------------------------------
  init_request_obj  amv_request_obj_type
       := amv_request_obj_type(G_MAX_VARRAY_SIZE, 1, FND_API.G_FALSE);
-----------------------------
-- System-wide collections --
-----------------------------
--
------------------------------------
-- Group Functions and Procedures --
------------------------------------
--
end amv_utility_pub;

 

/
