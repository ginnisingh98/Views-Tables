--------------------------------------------------------
--  DDL for Package PER_JOBS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_JOBS_PKG" AUTHID CURRENT_USER as
/* $Header: pejbd01t.pkh 120.0 2005/05/31 10:33:04 appldev noship $ */
--
PROCEDURE get_next_sequence(p_job_id       IN OUT NOCOPY NUMBER);
--
PROCEDURE check_unique_name(p_job_id            in number,
			    p_business_group_id in number,
			    p_name              in varchar2);
--
PROCEDURE check_date_from(p_job_id           in number,
			  p_date_from        in date);
--
PROCEDURE get_job_flex_structure(p_structure_defining_column in out nocopy varchar2,
				 p_job_group_id         in number);
--
PROCEDURE check_altered_end_date(p_business_group_id      number,
				 p_job_id                 number,
				 p_end_of_time            date,
				 p_date_to                date,
				 p_early_date_to      in out nocopy boolean,
				 p_early_date_from    in out nocopy boolean);
--
PROCEDURE update_valid_grades(p_business_group_id  number,
				     p_job_id             number,
				     p_date_to            date,
				     p_end_of_time        date);
--
PROCEDURE delete_valid_grades(p_business_group_id  number,
				     p_job_id             number,
				     p_date_to            date);
--
PROCEDURE check_delete_record(p_job_id            number,
			      p_business_group_id number);
--

-- ----------------------------------------------------------------------------
-- |---------------------------< check_evaluation_dates >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure will check for the valid evaluations exists outside
--   the effective period, when the user is end dating a job for a given
--   job id.
-- Prerequisites:
--   A valid job must be existing
--
-- In Parameters:
--   Name                           Reqd    Type     Description
--   p_jobid                        yes     number   Job id for the job to be
--                                                   end dated
--   p_job_date_from                yes     date     From date of the job
--   p_job_date_to                          date     End date of the job
--
-- Post Success:
--   User will be stopped from end dating the job, if any evaluation is
--   existing outside the effective end date of the job,for the given job id.
--   and a suitable message will be shown to the user.
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
-- ----------------------------------------------------------------------------
procedure check_evaluation_dates(p_jobid in number,
                                 p_job_date_from in date,
                                 p_job_date_to in date);

--

END PER_JOBS_PKG;

 

/
