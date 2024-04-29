--------------------------------------------------------
--  DDL for Package PA_AUTOALLOC_UTLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_AUTOALLOC_UTLS" AUTHID CURRENT_USER AS
/*  $Header: PAXAAUTS.pls 115.0 99/07/16 15:16:02 porting ship  $  */

----------------------------------------------------------------------
/* Used_In_AutoAllocWF

   Parameters - Run_ID
   Return - Y : Used in auto allocation set
            N : Not used in auto allocation set

   Given a Run_ID, function determines if the Allocation Run is used
   in a AutoAllocation Set.
*/

FUNCTION USED_IN_AUTOALLOCWF (	p_allocation_run_id	Number )
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (USED_IN_AUTOALLOCWF,WNDS,WNPS);

----------------------------------------------------------------------
/* In_Active_AutoAllocWF

   Parameters - Run_ID
   Return - Y : Used in active auto allocation set
            N : Not used in auto allocation set

   Given a Run_ID, the function first checks if the Allocation Run
   is used in an active AutoAllocation Set. If not, then return 'N'.
   If the first check returns a request_id that is the item_key of
   GL Workflow then it checks from wf view if the top wf process is active.

*/

FUNCTION IN_ACTIVE_AUTOALLOCWF ( p_allocation_run_id	Number )
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (IN_ACTIVE_AUTOALLOCWF,WNDS);

----------------------------------------------------------------------

END;

 

/
