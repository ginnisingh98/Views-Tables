--------------------------------------------------------
--  DDL for Package AD_MANUAL_STEP_OBJECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_MANUAL_STEP_OBJECT" AUTHID CURRENT_USER as
/* $Header: admsis.pls 120.4 2006/09/13 22:28:52 hxue noship $ */

   --
   -- Checks whether the manual step exists in history with the given
   -- version and status.
   --
   function manual_step_hist_exists(p_step_key varchar2,
                                    p_step_version varchar2,
                                    p_status char)
      return number;

   --
   -- Function that checks whether the manual steps is already applied in
   -- this instance.
   --
   function is_step_already_done(p_step_key varchar2,
                                 p_step_version varchar2)
      return number;

   --
   -- Procedure that adds manual steps in to ad_manual_step_history table
   -- with the given parameters.
   --
   procedure add_manual_step_history(p_patch_number varchar2,
                                     p_step_key varchar2,
                                     p_step_version varchar2,
                                     p_step_text varchar2,
                                     p_cond_code varchar2,
                                     p_username varchar2,
                                     p_status char);

   --
   -- Procedure that updates given manual steps as completed.
   --
   procedure update_step_as_completed(p_patch_number varchar2);

   --
   -- Function that checks whether the customer instance is on a
   -- codelevel passed.
   -- returns : 0, if the customer is not in that codelevel.
   --           1, if the customer is on or above the given codelevel
   --
   function is_on_codelevel (p_entity varchar2,
                             p_level varchar2)
      return number;

   --
   -- Function that checks whether the customer instance is on a
   -- baseline.
   -- returns : 0, if the customer is not in that baseline
   --           1, if the customer is on or above the given baseline.
   --
   function is_on_baseline (p_entity varchar2,
                            p_baseline varchar2)
      return number;

end ad_manual_step_object;

 

/
