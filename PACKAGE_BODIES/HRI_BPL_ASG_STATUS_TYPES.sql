--------------------------------------------------------
--  DDL for Package Body HRI_BPL_ASG_STATUS_TYPES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_ASG_STATUS_TYPES" AS
 /* $Header: hribastp.pkb 115.1 2004/06/03 06:09 prasharm noship $ */
--
/**************************************************************************
 *Description: This function gets called from the function
 *            HRI_OLTP_VIEW_ASG_STATUS_TYPES.get_asg_user_status
 **************************************************************************/
  FUNCTION get_asg_user_status
    (p_asg_type VARCHAR2,
     p_current_employee_flag VARCHAR2,
     p_user_status VARCHAR2
    )
  RETURN VARCHAR2
  IS
    --
    cursor c_user_status (c_per_system_status varchar2) is
    SELECT
	DECODE(y1.per_system_status,
	        'TERM_APL',
	        y1T.user_status,
	        DECODE(p_current_employee_flag ,
	               'Y',
	               p_user_status,
	               x1T.user_status
	        )
	) appl_user_status,
	DECODE(y1.per_system_status,
		'TERM_ASSIGN',
		y1T.user_status,
		x1T.user_status
	) emp_user_status
    FROM
	per_ass_status_type_amends_tl y1T ,
	 (select *
	  from   per_ass_status_type_amends
	  where  business_group_id = hr_bis.get_sec_profile_bg_id) y1,
	per_assignment_status_types_tl x1T,
	per_assignment_status_types x1
    WHERE
	x1.per_system_status = c_per_system_status AND
	x1.default_flag = 'Y' AND
	x1.business_group_id is null AND
	x1.assignment_status_type_id = x1T.assignment_status_type_id AND
	x1T.language = userenv('LANG') AND
	x1.assignment_status_type_id = y1.assignment_status_type_id(+) AND
	y1.ass_status_type_amend_id = y1T.ass_status_type_amend_id(+) AND
	y1T.language (+) = userenv('LANG');
    --
    l_record c_user_status%ROWTYPE;
    --
  BEGIN
    --
    IF (p_asg_type = 'A') THEN
    --
      open c_user_status ('TERM_APL');
      fetch c_user_status into l_record;
      close c_user_status;
    --
      return l_record.appl_user_status;
    --
    ELSIF (p_asg_type = 'E') THEN
    --
      open c_user_status ('TERM_ASSIGN');
      fetch c_user_status into l_record;
      close c_user_status;
    --
      return l_record.emp_user_status;
    --
    END IF;
    --
  END get_asg_user_status;
  --
END HRI_BPL_ASG_STATUS_TYPES;

/
