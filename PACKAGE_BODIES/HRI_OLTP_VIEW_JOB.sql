--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_VIEW_JOB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_VIEW_JOB" AS
/* $Header: hriovjob.pkb 120.0 2005/05/29 07:42:47 appldev noship $ */

/******************************************************************************/
/* Returns the configurable display format to use for a job name              */
/******************************************************************************/
FUNCTION get_job_display_name(p_job_id             IN NUMBER,
                              p_business_group_id  IN NUMBER,
                              p_job_name           IN VARCHAR2)
            RETURN VARCHAR2 IS

BEGIN

  RETURN hri_bpl_job.get_job_display_name
           (p_job_id => p_job_id,
            p_business_group_id => p_business_group_id,
            p_job_name => p_job_name);

EXCEPTION WHEN OTHERS THEN
  RETURN p_job_name;

END get_job_display_name;

END hri_oltp_view_job;

/
