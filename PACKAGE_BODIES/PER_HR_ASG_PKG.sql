--------------------------------------------------------
--  DDL for Package Body PER_HR_ASG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_HR_ASG_PKG" AS
/* $Header: peper05t.pkb 115.2 99/07/18 14:14:53 porting ship $ */
--
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
				p_location_code   in out varchar2) is

l_recruiter_number PER_ALL_PEOPLE.EMPLOYEE_NUMBER%TYPE;

begin
--
    per_applicant_pkg.get_vacancy_details ( p_vacancy_id,
				           p_vacancy_name,
				           p_recruiter_id,
				           p_recruiter_name,
				           p_org_id,
				           p_org_name,
				           p_people_group_id ,
				           p_job_id,
				           p_job_name,
				           p_pos_id,
				           p_pos_name,
				           p_grade_id,
				           p_grade_name,
				           p_location_id,
				           p_location_code,
                                           l_recruiter_number   ) ;
--
end get_vacancy_details ;
--
--
--
--
function chk_job_org_pos_comb ( p_job_id        in number,
				p_org_id        in number,
				p_pos_id        in number,
				p_date_received in date    ) return boolean is
begin
--
    return( per_applicant_pkg.chk_job_org_pos_comb ( p_job_id ,
	                                             p_org_id ,
				                     p_pos_id ,
				                     p_date_received  ) ) ;
--
end chk_job_org_pos_comb ;
--
--
--
procedure exists_val_grd_for_pos_and_job ( p_business_group_id  in number,
					   p_date_received      in date,
					   p_job_id             in number,
					   p_exists_grd_for_job out boolean,
					   p_pos_id             in number,
					   p_exists_grd_for_pos out boolean ) is
begin
--
  per_applicant_pkg.exists_val_grd_for_pos_and_job ( p_business_group_id ,
					             p_date_received     ,
					             p_job_id            ,
					             p_exists_grd_for_job,
					             p_pos_id            ,
					             p_exists_grd_for_pos) ;
--
end exists_val_grd_for_pos_and_job ;
--
--
END PER_HR_ASG_PKG ;

/
