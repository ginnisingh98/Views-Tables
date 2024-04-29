--------------------------------------------------------
--  DDL for Package HRI_EDW_DIM_AGE_BAND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_EDW_DIM_AGE_BAND" AUTHID CURRENT_USER AS
/* $Header: hriedagb.pkh 120.0 2005/05/29 07:08:06 appldev noship $ */

PROCEDURE insert_age_band( p_age_min_years    NUMBER,
                           p_age_min_months   NUMBER);

PROCEDURE remove_age_band( p_age_min_years   NUMBER,
                           p_age_min_months  NUMBER);

PROCEDURE load_row( p_band_min     IN NUMBER,
                    p_band_max     IN NUMBER,
                    p_owner        IN VARCHAR2 );

END hri_edw_dim_age_band;

 

/
