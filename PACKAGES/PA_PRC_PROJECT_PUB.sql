--------------------------------------------------------
--  DDL for Package PA_PRC_PROJECT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PRC_PROJECT_PUB" AUTHID CURRENT_USER AS
/*$Header: PAXPRCPS.pls 115.1 99/07/16 15:30:39 porting ship  $*/
--
-- ================================================
--
--Name       : PRC_Row_Exists
--Type       : Function
--Description:	This function can be used to check against PRC
--             tables for given PRC Assignment Id.
--
--         This function returns 1 if row exists for Assignment id or
--         and returns 0 if no row is found.
--
--Called subprograms: N/A
--
--History:
--    	24-SEP-1998        Sakthivel     	Created
--
--  HISTORY
--   21-SEP-98      Sakthivel       Created
--
FUNCTION PRC_Row_exists (x_assignment_id  IN number) return number;

--------------------------------------------------------------------------------
end PA_PRC_PROJECT_PUB;

 

/
