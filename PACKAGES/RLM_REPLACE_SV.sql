--------------------------------------------------------
--  DDL for Package RLM_REPLACE_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RLM_REPLACE_SV" AUTHID CURRENT_USER as
/*$Header: RLMDPSWS.pls 120.1.12010000.2 2009/12/01 14:44:59 sunilku ship $*/
/*===========================================================================
  PACKAGE NAME:	RLM_REPLACE_SV

  DESCRIPTION:	Contains all server side code for the DSP sweeper program.

  CLIENT/SERVER:Server

  LIBRARY NAME:	None

  OWNER:

  PROCEDURE/FUNCTIONS:

  GLOBALS:

===========================================================================*/
-- RLM Debug Constants
   C_SDEBUG              CONSTANT   NUMBER := rlm_core_sv.C_LEVEL1;
   C_DEBUG               CONSTANT   NUMBER := rlm_core_sv.C_LEVEL2;
   C_TDEBUG              CONSTANT   NUMBER := rlm_core_sv.C_LEVEL3;

-- For holding SF,ST,CI of the previous eligible replacement schedule lines,
-- declare this global pl/sql table
   TYPE list_rec_type IS RECORD
   (
     ship_from_org_id   NUMBER,
     ship_to_address_id NUMBER,
     customer_item_id   NUMBER,
     order_number       NUMBER
   );

   TYPE list_tbl IS TABLE OF list_rec_type INDEX BY BINARY_INTEGER;

   g_list_tbl list_tbl;

/*=============================================================================
  PROCEDURE NAME:  CompareReplaceSched

  DESCRIPTION:	   This is the top level procedure for sweeper program

  PARAMETERS:	   x_sched_rec          IN rlm_interface_headers%ROWTYPE
		   x_warn_dropped_items IN VARCHAR2
		   x_return_status      OUT NOCOPY BOOLEAN

 ============================================================================*/
  PROCEDURE CompareReplaceSched
  (
    x_sched_rec          IN  rlm_interface_headers%ROWTYPE,
    x_warn_dropped_items IN  VARCHAR2,
    x_return_status      OUT NOCOPY BOOLEAN
  );

/*=============================================================================
  FUNCTION NAME:  IsWarningNeeded

  DESCRIPTION:	  This function returns FALSE if the current schedule
                  does not meet the criteria for running sweeper program.

  PARAMETERS:	  x_sched_rec          IN rlm_interface_headers%ROWTYPE
		  x_warn_dropped_items IN VARCHAR2

 ============================================================================*/

 FUNCTION IsWarningNeeded
 (
   x_sched_rec          IN rlm_interface_headers%ROWTYPE,
   x_warn_dropped_items IN VARCHAR2
 ) RETURN BOOLEAN;

/*=============================================================================
  PROCEDURE NAME:  FindEligibleSched

  DESCRIPTION:	   This procedure finds the highest generation date schedule
                   before the current schedule based on tp translator code,
		   tp location code, schedule type, test flag, schedule
                   source.

  PARAMETERS:	   x_sched_rec          IN  rlm_interface_headers%ROWTYPE
		   x_prev_header_id     OUT NOCOPY NUMBER
		   x_return_status      OUT NOCOPY BOOLEAN

 ============================================================================*/
  PROCEDURE FindEligibleSched
  (
    x_sched_rec          IN  rlm_interface_headers%ROWTYPE,
    x_prev_header_id     OUT NOCOPY NUMBER,
    x_return_status      OUT NOCOPY BOOLEAN
  );

/*=============================================================================
  PROCEDURE NAME:  PopulateList

  DESCRIPTION:	   This procedure builds a list of SF, ST, CI from the
                   eligible schedule found by FindEligibleSched procedure

  PARAMETERS:	   x_prev_header_id     IN  NUMBER
                   x_curr_header_id     IN  NUMBER
		   x_return_status      OUT NOCOPY BOOLEAN

 ============================================================================*/
  PROCEDURE PopulateList
  (
    x_prev_header_id  IN  NUMBER,
    x_curr_header_id  IN NUMBER, /* bugfix 4198327 */
    x_curr_sch_header_id  IN NUMBER,  --Bugfix 8844817
    x_return_status   OUT NOCOPY BOOLEAN
  );

/*=============================================================================
  PROCEDURE NAME:  CompareList

  DESCRIPTION:	   This procedure compares the SF,ST,CI list entries with
                   current schedule

  PARAMETERS:	   x_curr_header_id  IN NUMBER

 ============================================================================*/
  PROCEDURE CompareList
  (
    x_curr_header_id  IN NUMBER
  );

END RLM_REPLACE_SV;

/
