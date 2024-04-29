--------------------------------------------------------
--  DDL for Package HRI_OLTP_VIEW_JOB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_VIEW_JOB" AUTHID CURRENT_USER AS
/* $Header: hriovjob.pkh 120.0 2005/05/29 07:43:02 appldev noship $ */

/******************************************************************************/
/* Returns the configurable display format to use for a job name              */
/******************************************************************************/
FUNCTION get_job_display_name(p_job_id             IN NUMBER,
                              p_business_group_id  IN NUMBER,
                              p_job_name           IN VARCHAR2)
            RETURN VARCHAR2;

END hri_oltp_view_job;

 

/
