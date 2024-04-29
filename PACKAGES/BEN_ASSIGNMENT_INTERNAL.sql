--------------------------------------------------------
--  DDL for Package BEN_ASSIGNMENT_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ASSIGNMENT_INTERNAL" AUTHID CURRENT_USER as
/* $Header: beasgbsi.pkh 120.0.12010000.1 2008/07/29 10:51:29 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< copy_empasg_to_benasg >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This business support process copies employee primary assignment information
--  to a benefits assignment when Oracle Advanced Benefits is installed and
--  the business group for the assignment is in a US or CA legislation. This information
--  is only copied for the following events,
--  - Termination of an employee (The actual termination date is set on the
--    period of service and the leaving reason is not deceased)
--  - Death of an employee (The date of death is set for the person or the period
--    of service has a leaving reason of deceased.
--
-- Prerequisites:
--
-- In Parameters:
--
--
-- Post Success:
--
-- Post Failure:
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure copy_empasg_to_benasg
  (p_person_id             in     number
  --
  ,p_pds_atd               in     date     default null
  ,p_pds_leaving_reason    in     varchar2 default null
  ,p_pds_fpd               in     date     default null
  ,p_per_date_of_death     in     date     default null
  ,p_per_marital_status    in     varchar2 default null
  ,p_per_esd               in     date     default null
  ,p_dpnt_person_id        in     number   default null
  ,p_redu_hrs_flag         in     varchar2 default 'N'
  ,p_effective_date        in     date     default null
  --
  ,p_assignment_id            out nocopy number
  ,p_object_version_number    out nocopy number
  ,p_perhasmultptus           out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< copy_empasg_to_benasg >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This business support process copies employee primary assignment information
--  to a benefits assignment when Oracle Advanced Benefits is installed and
--  the business group for the assignment is in a US legislation. This information
--  is only copied for the following events,
--  - Termination of an employee (The actual termination date is set on the
--    period of service and the leaving reason is not deceased)
--  - Death of an employee (The date of death is set for the person or the period
--    of service has a leaving reason of deceased.
--
-- Prerequisites:
--
-- In Parameters:
--
--
-- Post Success:
--
-- Post Failure:
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure derive_aei_information
  (p_effective_date in     date
  ,p_person_id      in     number
  --
  ,p_age               out nocopy number
  ,p_adj_serv_date     out nocopy date
  ,p_orig_hire_date    out nocopy date
  ,p_salary            out nocopy varchar2
  ,p_termn_date        out nocopy date
  ,p_termn_reason      out nocopy varchar2
  ,p_absence_date      out nocopy date
  ,p_absence_type      out nocopy varchar2
  ,p_absence_reason    out nocopy varchar2
  ,p_date_of_hire      out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< check_bnft_asgn  >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- If a benefit assignment exists, date-track update the current assignment
-- with the new benefit assignment information.
--
-- Prerequisites:
--
-- In Parameters:
--
--
-- Post Success:
--
-- Post Failure:
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure check_bnft_asgn
  (p_person_id       in    number
  ,p_effective_date  in    date
  ,p_asg_dets        in    per_all_assignments_f%rowtype
  ,p_exists            out nocopy boolean
  --RCHASE BENASG bug fix Start
  ,p_emp_person_id   in    number default NULL
  --RCHASE End
  );
--
end ben_assignment_internal;

/
