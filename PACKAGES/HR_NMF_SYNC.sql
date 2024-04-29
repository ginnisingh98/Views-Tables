--------------------------------------------------------
--  DDL for Package HR_NMF_SYNC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NMF_SYNC" AUTHID CURRENT_USER as
/* $Header: hrnmfsyn.pkh 120.4 2006/04/13 13:04 irgonzal noship $ */

  g_prm_legislation_code VARCHAR2(30);
  g_prm_format_name      HR_NAME_FORMATS.FORMAT_NAME%TYPE;
  g_prm_scope            HR_NAME_FORMATS.USER_FORMAT_CHOICE%TYPE;

  TYPE number_tbl      is TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
  TYPE varchar_30_tbl  is TABLE OF VARCHAR2(30)  INDEX BY BINARY_INTEGER;
  TYPE varchar_80_tbl  is TABLE OF VARCHAR2(80)  INDEX BY BINARY_INTEGER;
  TYPE varchar_250_tbl is TABLE OF VARCHAR2(250) INDEX BY BINARY_INTEGER;

  TYPE leg_mask_cache_r is RECORD
  (
   legislation_code         varchar_80_tbl,
   format_name              varchar_80_tbl,
   user_format_choice       varchar_30_tbl,
   format_mask              varchar_250_tbl,
   seeded_package_name      varchar_80_tbl,
   seeded_procedure_name    varchar_80_tbl,
   sz                       number
  );

  TYPE leg_bg_cache_r is RECORD
  (
    legislation_code   varchar_30_tbl,
    business_group_id  number_tbl,
    bg_name            varchar_250_tbl,
    sz                 number
  );

  TYPE leg_seeded_pkg_cache_r is RECORD
  (
   legislation_code         varchar_80_tbl,
   format_name              varchar_80_tbl,
   seeded_package_name      varchar_80_tbl,
   seeded_procedure_name    varchar_80_tbl,
   sz                       number
  );


  g_leg_masks_cache         leg_mask_cache_r;
  g_masks_cached             boolean := FALSE;

  g_business_groups_cache   leg_bg_cache_r;
  g_bg_cached               boolean := FALSE;

  g_leg_seeded_pkg_cache    leg_seeded_pkg_cache_r;
  g_seeded_pkg_cached       boolean := FALSE;

  g_format_names_tbl        varchar_80_tbl;
-- ----------------------------------------------------------------------------
-- |--------------------------< range_cursor >--------------------------------|
-- ----------------------------------------------------------------------------
--
procedure range_cursor (pactid in 	  number,
			                  sqlstr out NOCOPY varchar2);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< action_creation >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Purpose : This routine creates assignment actions for a specific chunk.
--           Only one action is created for a single person ID. If a person
--           has multiple assignments then we ignore all but the first one.
--           This is so that we can process all the assignment records within
--           the same chunk(and therefore thread). Later in the process we
--           will get a list of all assignment IDs for a person and process
--           each one of them.
--
-- Notes :
--
procedure action_creation (pactid    in number,
                           stperson  in number,
			                     endperson in number,
			                     chunk     in number);
-- ----------------------------------------------------------------------------
-- |---------------------------< initialization >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Purpose : This process is called for each slave process to perform
--           standard initialization.
--
-- Notes :
--
procedure initialization(pactid in number);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< archive_data >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Purpose : This process is called for each assignment action and performs the
--           processing required for each individual person. We have access
--           to an assignment ID but need to determine security for a person
--           so convert the assignment ID into a person ID and then kickoff
--           the processing for that person.
--
-- Notes :
--
procedure archive_data(p_assactid       in number,
                       p_effective_date in date);
--
--
procedure submit_sync_names
      (errbuf 		                 out NOCOPY varchar2
      ,retcode 		                 out NOCOPY number
      ,p_effective_date 	         varchar2
      ,p_action_parameter_group_id varchar2
      ,p_format_name_choice        varchar2
      ,p_legislation_code          varchar2
      ,p_format_name               varchar2
      ,p_user_format_choice        varchar2
      ,p_disable_who_triggers      varchar2);
--
-- --------------------------------------------------------------------------+
--                           ValidateRun
-- --------------------------------------------------------------------------+
-- Purpose: this allows control on whether or not to submit conc. program
--          It is used by the GUP infrastructure when submitting
--          program from ADPATCH.
--
-- Notes:
--
PROCEDURE ValidateRun(p_result OUT nocopy varchar2);
--
--
end hr_nmf_sync;

 

/
