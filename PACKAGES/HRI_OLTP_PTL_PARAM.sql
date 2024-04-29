--------------------------------------------------------
--  DDL for Package HRI_OLTP_PTL_PARAM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PTL_PARAM" AUTHID CURRENT_USER AS
/* $Header: hriopprm.pkh 115.4 2003/10/23 13:55:33 kthirmiy ship $ */
   FUNCTION get_params(region_id IN VARCHAR2) RETURN VARCHAR2;
   FUNCTION get_dbi_params(region_id IN VARCHAR2) RETURN VARCHAR2;
   --Functions to return default values only
   FUNCTION get_dbi_mgr_id RETURN VARCHAR2;
   FUNCTION get_dbi_curr RETURN VARCHAR2;
   FUNCTION get_dbi_date RETURN VARCHAR2;
END hri_oltp_ptl_param;

 

/
