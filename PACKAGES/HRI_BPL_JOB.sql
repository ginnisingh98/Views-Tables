--------------------------------------------------------
--  DDL for Package HRI_BPL_JOB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_BPL_JOB" AUTHID CURRENT_USER AS
/* $Header: hribjob.pkh 120.0 2005/05/29 06:53:25 appldev noship $ */



PROCEDURE add_job_category( p_job_cat_set     IN NUMBER,
                            p_job_cat_lookup  IN VARCHAR2 := null,
                            p_other_lookup    IN VARCHAR2 := null );

PROCEDURE remove_job_category( p_job_cat_set     IN NUMBER,
                               p_job_cat_lookup  IN VARCHAR2 := null,
                               p_other_lookup    IN VARCHAR2 := null );

PROCEDURE load_row( p_job_cat_set     IN NUMBER,
                    p_job_cat_lookup  IN VARCHAR2,
                    p_other_lookup    IN VARCHAR2,
                    p_owner           IN VARCHAR2 );

FUNCTION lookup_product_category( p_job_id     IN NUMBER )
     RETURN VARCHAR2;

FUNCTION get_job_display_name(p_job_id             IN NUMBER,
                              p_business_group_id  IN NUMBER,
                              p_job_name           IN VARCHAR2)
            RETURN VARCHAR2;

g_warning_flag VARCHAR2(30);

FUNCTION get_job_role_code(p_job_fmly_code   IN VARCHAR,
                           p_job_fnctn_code  IN VARCHAR2)
  RETURN VARCHAR2;

END hri_bpl_job;

 

/
