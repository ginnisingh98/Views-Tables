--------------------------------------------------------
--  DDL for Package PER_HR_ASG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_HR_ASG_PKG" AUTHID CURRENT_USER as
/* $Header: peper05t.pkh 115.0 99/07/18 14:14:56 porting ship $ */
--
-- Name
--   get_vacancy_details
-- Notes
--   See PER_APPLICANT_PKG for details
procedure get_vacancy_details ( p_vacancy_id      in number,
				p_vacancy_name    in out varchar2,
				p_recruiter_id    in out number,
				p_recruiter_name  in out varchar2,
				p_org_id	  in out number,
				p_org_name	  in out varchar2,
				p_people_group_id in out number,
				p_job_id	  in out number,
				p_job_name	  in out varchar2,
				p_pos_id	  in out number,
				p_pos_name	  in out varchar2,
				p_grade_id	  in out number,
				p_grade_name	  in out varchar2,
				p_location_id     in out number,
				p_location_code   in out varchar2 ) ;

--
-- Name
--   chk_job_org_pos_comb
-- Notes
--   See PER_APPLICANT_PKG for details
function chk_job_org_pos_comb ( p_job_id        in number,
				p_org_id        in number,
				p_pos_id        in number,
				p_date_received in date    ) return boolean ;
-- Name
--   exists_val_grd_for_pos_and_job
-- Notes
--   See PER_APPLICANT_PKG for details
procedure exists_val_grd_for_pos_and_job ( p_business_group_id  in number,
					   p_date_received      in date,
					   p_job_id             in number,
					   p_exists_grd_for_job out boolean,
					   p_pos_id             in number,
					   p_exists_grd_for_pos out boolean );

end PER_HR_ASG_PKG ;

 

/
