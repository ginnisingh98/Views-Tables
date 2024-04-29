--------------------------------------------------------
--  DDL for Package HR_ASG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASG_PKG" AUTHID CURRENT_USER as
/* $Header: hrasg.pkh 115.0 99/07/17 16:33:56 porting ship $ */
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
				p_date_received in date    ) return boolean;
--
procedure exists_val_grd_for_pos_and_job ( p_business_group_id  in number,
					   p_date_received      in date,
					   p_job_id             in number,
					   p_exists_grd_for_job out boolean,
					   p_pos_id             in number,
					   p_exists_grd_for_pos out boolean );
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
				p_location_code   in out varchar2 );
--
end	hr_asg_pkg;

 

/
