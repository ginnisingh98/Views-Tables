--------------------------------------------------------
--  DDL for Package HRI_OLTP_VIEW_MESSAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_VIEW_MESSAGE" AUTHID CURRENT_USER AS
/* $Header: hriovmsg.pkh 120.1 2005/10/25 07:16:35 jtitmas noship $ */

FUNCTION get_not_used_msg RETURN VARCHAR2;

FUNCTION get_unassigned_msg RETURN VARCHAR2;

FUNCTION get_direct_reports_msg RETURN VARCHAR2;

FUNCTION get_others_msg RETURN VARCHAR2;

FUNCTION get_notapplicable_msg RETURN VARCHAR2;

FUNCTION get_notrated_msg RETURN VARCHAR2;

FUNCTION get_all_msg RETURN VARCHAR2;

FUNCTION get_message(p_msg_name  IN VARCHAR2)
     RETURN VARCHAR2;

FUNCTION get_message(p_msg_name  IN VARCHAR2,
                     p_app_name  IN VARCHAR2)
     RETURN VARCHAR2;

END hri_oltp_view_message;

 

/
