--------------------------------------------------------
--  DDL for Package HRI_EDW_DIM_SIZING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_EDW_DIM_SIZING" AUTHID CURRENT_USER AS
/* $Header: hriezdmn.pkh 120.0 2005/05/29 07:20:46 appldev noship $ */

FUNCTION get_size_agb_pk  RETURN NUMBER;
FUNCTION get_size_acg_pk  RETURN NUMBER;
FUNCTION get_size_asg_pk  RETURN NUMBER;
FUNCTION get_size_grd_pk  RETURN NUMBER;
FUNCTION get_size_job_pk  RETURN NUMBER;
FUNCTION get_size_lwb_pk  RETURN NUMBER;
FUNCTION get_size_mvt_pk  RETURN NUMBER;
FUNCTION get_size_pty_pk  RETURN NUMBER;
FUNCTION get_size_pos_pk  RETURN NUMBER;
FUNCTION get_size_psn_pk  RETURN NUMBER;
FUNCTION get_size_org_pk  RETURN NUMBER;
FUNCTION get_size_rsn_pk  RETURN NUMBER;
FUNCTION get_size_vac_pk  RETURN NUMBER;
FUNCTION get_size_rec_pk  RETURN NUMBER;
FUNCTION get_size_geog_pk RETURN NUMBER;
FUNCTION get_size_time_pk RETURN NUMBER;

END hri_edw_dim_sizing;

 

/
