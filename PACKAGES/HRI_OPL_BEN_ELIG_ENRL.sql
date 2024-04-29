--------------------------------------------------------
--  DDL for Package HRI_OPL_BEN_ELIG_ENRL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OPL_BEN_ELIG_ENRL" AUTHID CURRENT_USER AS
/* $Header: hripbeec.pkh 120.0 2005/09/21 01:28:40 anmajumd noship $ */
--
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	Name	:	HRI_OPL_BEN_ELIG_ENRL
	Purpose	:	Populate Benefits Eligbility and Enrollment Fact
------------------------------------------------------------------------------
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

TYPE g_pil_rec_type IS RECORD
(per_in_ler_id NUMBER
,person_id NUMBER
,lf_evt_ocrd_dt DATE
,per_in_ler_stat_cd VARCHAR2(30)
,business_group_id NUMBER
);
--
TYPE g_pil_tab_type IS TABLE OF g_pil_rec_type
INDEX BY BINARY_INTEGER;
--
TYPE g_date_tab_type IS TABLE OF DATE
INDEX BY BINARY_INTEGER;
--
TYPE g_number_tab_type IS TABLE OF NUMBER
INDEX BY BINARY_INTEGER;
--
TYPE g_varchar2_tab_type IS TABLE OF VARCHAR2(30)
INDEX BY BINARY_INTEGER;
--
TYPE g_rowid_tab_type IS TABLE OF ROWID
INDEX BY BINARY_INTEGER;
--
-- ----------------------------------------------------------------------------
-- PRE_PROCESS
-- This procedure includes the logic required for performing the pre_process
-- task of HRI multithreading utility.
-- ----------------------------------------------------------------------------
PROCEDURE pre_process
  (p_mthd_action_id    IN NUMBER
  ,p_sqlstr            OUT NOCOPY VARCHAR2);
--
-- ----------------------------------------------------------------------------
-- PROCESS_RANGE
-- This procedure is dynamically called from HRI Multithreading utility.
-- Calls Collection procedures for Election Event and Elibility Enrollment Event Facts
-- for All PER_IN_LER_IDs obtained from the thread range.
-- ----------------------------------------------------------------------------
PROCEDURE process_range
  (errbuf              OUT NOCOPY VARCHAR2
  ,retcode             OUT NOCOPY NUMBER
  ,p_mthd_action_id    IN NUMBER
  ,p_mthd_range_id     IN NUMBER
  ,p_start_object_id   IN NUMBER
  ,p_end_object_id     IN NUMBER);
--
-- ----------------------------------------------------------------------------
-- POST_PROCESS
-- This procedure is dynamically invoked by the HRI Multithreading utility.
-- It performs all the clean up action for after collection.
--       Enable the MV logs
--       Purge the Election and Eligibility Events' incremental events queue
--       Update BIS Refresh Log
-- ----------------------------------------------------------------------------
PROCEDURE post_process
  (p_mthd_action_id    IN NUMBER);
--
END HRI_OPL_BEN_ELIG_ENRL;

 

/
