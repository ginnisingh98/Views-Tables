--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_VIEW_ASG_STATUS_TYPES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_VIEW_ASG_STATUS_TYPES" AS
/* $Header: hrioastp.pkb 115.1 2004/06/03 06:10 prasharm noship $ */
--
/**************************************************************************
 *Description: This function gets called from the view
 *             HRI_JOB_APPLICATIONS for the column applications_status.
 **************************************************************************/
FUNCTION get_asg_user_status
  (p_asg_type VARCHAR2,
   p_current_employee_flag VARCHAR2,
   p_user_status VARCHAR2
  )
RETURN VARCHAR2
IS
l_status_type		VARCHAR2(4000);
--
BEGIN
	--
	l_status_type := hri_bpl_asg_status_types.get_asg_user_status(p_asg_type,
	                                                              p_current_employee_flag,
	                                                              p_user_status);
	return l_status_type;
	--
--
END get_asg_user_status;
END HRI_OLTP_VIEW_ASG_STATUS_TYPES;

/
