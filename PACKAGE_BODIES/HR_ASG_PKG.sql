--------------------------------------------------------
--  DDL for Package Body HR_ASG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ASG_PKG" as
/* $Header: hrasg.pkb 115.0 99/07/17 16:33:52 porting ship $ */
/*
  ===========================================================================
 |               Copyright (c) 1996 Oracle Corporation                       |
 |                       All rights reserved.                                |
  ===========================================================================
Name
	HR Libraries server-side agent
Purpose
	Agent handles all server-side traffic to and from forms libraries. This
	is particularly necessary because we wish to avoid the situation where
	a form and its libraries both refer to the same server-side package.
	Forms/libraries appears to be unable to cope with this situation in
	circumstances which we cannot yet define.
History
	21 Apr 95	N Simpson	Created
110.1   03 Sep 97	Khabibul	Fixed problem with 255 chars line width
*/
function chk_job_org_pos_comb ( p_job_id        in number,
				p_org_id        in number,
				p_pos_id        in number,
				p_date_received in date    ) return boolean is
				--
begin
--
return (per_hr_asg_pkg.chk_job_org_pos_comb (
		p_job_id,
		p_org_id,
		p_pos_id,
		p_date_received));
		--
end chk_job_org_pos_comb;
--
procedure exists_val_grd_for_pos_and_job ( p_business_group_id  in number,
					   p_date_received      in date,
					   p_job_id             in number,
					   p_exists_grd_for_job out boolean,
					   p_pos_id             in number,
					   p_exists_grd_for_pos out boolean )
					   is
begin
--
per_hr_asg_pkg.exists_val_grd_for_pos_and_job (
	p_business_group_id,
	p_date_received,
	p_job_id,
	p_exists_grd_for_job,
	p_pos_id,
	p_exists_grd_for_pos);
--
end exists_val_grd_for_pos_and_job;
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
				p_location_code   in out varchar2 ) is
--
begin
--
per_hr_asg_pkg.get_vacancy_details (
	p_vacancy_id,
	p_vacancy_name,
	p_recruiter_id,
	p_recruiter_name,
	p_org_id,
	p_org_name,
	p_people_group_id,
	p_job_id,
	p_job_name,
	p_pos_id,
	p_pos_name,
	p_grade_id,
	p_grade_name,
	p_location_id,
	p_location_code);
--
end get_vacancy_details;
--
end	hr_asg_pkg;

/
