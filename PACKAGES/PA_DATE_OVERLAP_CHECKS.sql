--------------------------------------------------------
--  DDL for Package PA_DATE_OVERLAP_CHECKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_DATE_OVERLAP_CHECKS" AUTHID CURRENT_USER as
-- $Header: PAXDTCHS.pls 120.2 2005/08/08 12:39:51 sbharath noship $

--
--  PROCEDURE
--              date_overlap_check_lcm
--  PURPOSE
--              This procedure checks if any of the dates overlaps.
--              in the labor cost multipliers. If it overlaps it
--              returns 0 along with the labor cost multiplier
--              name
--  HISTORY
--   14-FEB-96      Sandeep B     Created
--
procedure date_overlap_check_lcm (
          X_Status         Out  NOCOPY Number,
          X_Error_Text     Out  NOCOPY Varchar2,
          X_Labor_Cost_Multiplier_Name Out NOCOPY Varchar2 )  ;


end PA_DATE_OVERLAP_CHECKS;

 

/
