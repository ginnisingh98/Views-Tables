--------------------------------------------------------
--  DDL for Package HRI_EDW_DIM_JOB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_EDW_DIM_JOB" AUTHID CURRENT_USER AS
/* $Header: hriedjob.pkh 115.2 2002/06/10 01:30:51 pkm ship       $ */

FUNCTION find_job_category(p_job_id          IN NUMBER,
                           p_sequence        IN NUMBER)
                           RETURN VARCHAR2;

PROCEDURE add_job_category( p_job_cat_set     IN NUMBER,
                            p_job_cat_lookup  IN VARCHAR2 := null,
                            p_other_lookup    IN VARCHAR2 := null);

PROCEDURE remove_job_category( p_job_cat_set     IN NUMBER,
                               p_job_cat_lookup  IN VARCHAR2 := null,
                               p_other_lookup    IN VARCHAR2 := null);

PROCEDURE load_row( p_job_cat_set     IN NUMBER,
                    p_job_cat_lookup  IN VARCHAR2,
                    p_other_lookup    IN VARCHAR2,
                    p_owner           IN VARCHAR2 );

END hri_edw_dim_job;

 

/
