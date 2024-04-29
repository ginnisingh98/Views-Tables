--------------------------------------------------------
--  DDL for Package Body PER_MM_JOB_REQUIREMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_MM_JOB_REQUIREMENTS_PKG" as
/* $Header: pemmv05t.pkb 115.0 99/07/18 14:02:31 porting ship $ */
--
--
procedure load_rows
                  (p_mass_move_id in number)
is

begin
     insert into per_mm_job_requirements
         (MASS_MOVE_ID,
          ANALYSIS_CRITERIA_ID,
          DELETE_FLAG)
     select distinct
         p_mass_move_id,
         analysis_criteria_id,
         'N'
       from per_job_requirements jbr,
            per_mm_positions mmpos
      where mmpos.position_id = jbr.position_id
        and mmpos.mass_move_id = p_mass_move_id;
    exception
       when no_data_found then
         null;
       when others then
         hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
         hr_utility.set_message_token('PROCEDURE','insert_child_rows');
         hr_utility.set_message_token('STEP','1');
         hr_utility.raise_error;

  end load_rows;
--
--
end PER_MM_JOB_REQUIREMENTS_PKG ;


/
