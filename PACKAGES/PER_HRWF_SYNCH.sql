--------------------------------------------------------
--  DDL for Package PER_HRWF_SYNCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_HRWF_SYNCH" AUTHID CURRENT_USER AS
/* $Header: perhrwfs.pkh 120.0.12010000.1 2008/07/28 05:43:09 appldev ship $ */
  --
  --
  --
  --
  -- ----------------------------------------------------------------------------
  -- |------------------------------< call_back >-------------------------------|
  -- ----------------------------------------------------------------------------
  --
  -- {Start Of Comments}
  --
  -- Description:
  --   This is a callbackable routine from WF_EVENT. This procedure calls
  --   the routines WF_LOCAL_SYNCH.propagate_user and propagate_user_role.
  --   WF_EVENT.call_me_later defferrs calling this procedure until the future
  --   dated transactions' effective start date equals sysdate.
  --
  --
  -- Pre Conditions:
  --   Start date must equal sysdate.
  --
  -- In Arguments:
  --   wf_parameter_list_t type varry.
  --
  -- Post Success:
  --   Processing continues.
  --   This procedure calls the routines WF_LOCAL_SYNCH.propagate_user
  --   or WF_LOCAL_SYNCH.propagate_user_role, whichever is appropriate.
  --
  -- Post Failure:
  --   No specific error handling is required within this procedure.
  --
  -- Access Status:
  --   Internal Table Handler Use Only.
  --
  -- {End Of Comments}
  -- ----------------------------------------------------------------------------
  --
  --
  procedure call_back
  (p_parameters           in wf_parameter_list_t default null);
  --
  --
  -- ----------------------------------------------------------------------------
  -- |--------------------------< chk_date_status >-----------------------------|
  -- ----------------------------------------------------------------------------
  --
  -- {Start Of Comments}
  --
  -- Description:
  --
  --   This function will return the status of the dates provided, where
  --   the dates fall with respect to the sysdate. Possible options are
  --   CURRENT, FUTURE or PAST.
  --
  -- Pre Conditions:
  --   None.
  --
  -- In Arguments:
  --   Two dates (start date and end date).
  --
  -- Post Success:
  --   Processing continues.
  --   This function returns one of the value CURRENT, FUTURE or PAST.
  --
  -- Post Failure:
  --   None.
  --
  -- Access Status:
  --   Internal Table Handler Use Only.
  --
  -- {End Of Comments}
  -- ----------------------------------------------------------------------------
  function chk_date_status
    (p_start_date           in date,
     p_end_date             in date) return varchar2;
  --
  --
  -- ----------------------------------------------------------------------------
  -- |-----------------------------< per_per_wf >-------------------------------|
  -- ----------------------------------------------------------------------------
  --
  -- {Start Of Comments}
  --
  -- Description:
  --
  --   This procedure calls the appropriate routines, depending on the status of the
  --   effective dates.
  --
  -- Pre Conditions:
  --   None.
  --
  -- In Arguments:
  --   per_all_people_f%rowtype and p_action(INSERT, DELETE, UPDATE).
  --
  -- Post Success:
  --   Processing continues.
  --   If the status is CURRENT then the routine WF_LOCAL_SYNCH.propagate_user
  --   is called. If the status is FUTURE then WF_EVENT. call_me_later is called.
  --
  -- Post Failure:
  --   None.
  --
  -- Access Status:
  --   Internal Table Handler Use Only.
  --
  -- {End Of Comments}
  -- ----------------------------------------------------------------------------
  procedure per_per_wf(
     p_rec                  in per_all_people_f%rowtype,
     p_action               in varchar2);
  --
  --
  -- ----------------------------------------------------------------------------
  -- |-----------------------------< per_asg_wf >-------------------------------|
  -- ----------------------------------------------------------------------------
  --
  -- {Start Of Comments}
  --
  -- Description:
  --
  --   This procedure calls the appropriate routines, depending on the status of the
  --   effective dates.
  --
  -- Pre Conditions:
  --   None.
  --
  -- In Arguments:
  --   per_all_assignments_f%rowtype and p_action(INSERT, DELETE, UPDATE).
  --
  -- Post Success:
  --   Processing continues.
  --   If the status is CURRENT then the routine WF_LOCAL_SYNCH.propagate_user_role
  --   is called. If the status is FUTURE then WF_EVENT. call_me_later is called.
  --
  -- Post Failure:
  --   None.
  --
  -- Access Status:
  --   Internal Table Handler Use Only.
  --
  -- {End Of Comments}
  -- ----------------------------------------------------------------------------

  procedure per_asg_wf(
     p_rec                  in per_all_assignments_f%rowtype,
     p_action               in varchar2);
  --
  --
  -- ----------------------------------------------------------------------------
  -- |-----------------------------< per_pds_wf >-------------------------------|
  -- ----------------------------------------------------------------------------
  --
  -- {Start Of Comments}
  --
  -- Description:
  --
  --   This procedure calls the WF_LOCAL_SYNCGH.propagate_user routine.
  --
  -- Pre Conditions:
  --   None.
  --
  -- In Arguments:
  --   per_periods_of_service%rowtype and p_action(TERMINATION, REVERSE TERMINATION).
  --
  -- Post Success:
  --   Processing continues.
  --   If the status is CURRENT then the routine WF_LOCAL_SYNCH.propagate_user
  --   is called. If the status is FUTURE then WF_EVENT. call_me_later is called.
  --
  -- Post Failure:
  --   None.
  --
  -- Access Status:
  --   Internal Table Handler Use Only.
  --
  -- {End Of Comments}
  -- ----------------------------------------------------------------------------
  procedure per_pds_wf(
     p_rec                  in per_periods_of_service%rowtype,
     p_date                 in date default null,
     p_action               in varchar2);
  --
  -- --------------------------------------------------------------------------
  -- |-----------------------------< per_per_wf >-----------------------------|
  -- --------------------------------------------------------------------------
  --
  -- {Start Of Comments}
  --
  -- Description:
  --
  --   This overloaded procedure is just to overcome the %rowtype issues
  --   in forms. This will be directly called from the form and
  --   this procedure will be inturn calling the actual procedure
  --
  -- Pre Conditions:
  --   None.
  --
  -- In Arguments:
  --   p_rec  per_per_shd.g_rec_type
  --   p_action(INSERT, DELETE, UPDATE).
  --
  -- Post Success:
  --   Processing continues.
  --
  -- Post Failure:
  --   None.
  --
  -- Access Status:
  --   Internal Table Handler Use Only.
  --
  -- {End Of Comments}
  -- --------------------------------------------------------------------------
     procedure per_per_wf(
       p_rec                  in per_per_shd.g_rec_type,
       p_action               in varchar2);
  --
  -- --------------------------------------------------------------------------
  -- |-----------------------------< per_pds_wf >-----------------------------|
  -- --------------------------------------------------------------------------
  --
  -- {Start Of Comments}
  --
  -- Description:
  --
  --   This overloaded procedure is just to overcome the %rowtype issues
  --   in forms. This will be directly called from the form and
  --   this procedure will be inturn calling the actual procedure
  --
  -- Pre Conditions:
  --   None.
  --
  -- In Arguments:
  --   p_person_id
  --   p_date
  --   p_date_start Start date of the period of employment
  --   p_action(TERMINATION, REVERSE TERMINATION)
  --
  -- Post Success:
  --   Processing continues.
  --
  -- Post Failure:
  --   None.
  --
  -- Access Status:
  --   Internal Table Handler Use Only.
  --
  -- {End Of Comments}
  -- ----------------------------------------------------------------------------
     procedure per_pds_wf(
       p_person_id            in number,
       p_date                 in date default null,
       p_date_start           in date,
       p_action               in varchar2);
  --
end per_hrwf_synch;

/
