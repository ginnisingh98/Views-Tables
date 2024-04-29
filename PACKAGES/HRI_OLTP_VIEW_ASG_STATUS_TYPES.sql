--------------------------------------------------------
--  DDL for Package HRI_OLTP_VIEW_ASG_STATUS_TYPES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_VIEW_ASG_STATUS_TYPES" AUTHID CURRENT_USER AS
/* $Header: hrioastp.pkh 115.1 2004/06/03 06:10 prasharm noship $ */
--
FUNCTION get_asg_user_status
  (p_asg_type VARCHAR2,
   p_current_employee_flag VARCHAR2,
   p_user_status VARCHAR2
  )
RETURN VARCHAR2;
--
END HRI_OLTP_VIEW_ASG_STATUS_TYPES;

 

/
