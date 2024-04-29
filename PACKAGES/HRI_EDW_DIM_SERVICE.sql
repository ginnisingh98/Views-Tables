--------------------------------------------------------
--  DDL for Package HRI_EDW_DIM_SERVICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_EDW_DIM_SERVICE" AUTHID CURRENT_USER AS
/* $Header: hriedlwb.pkh 120.0 2005/05/29 07:08:45 appldev noship $ */

FUNCTION get_days_to_month RETURN NUMBER;

PROCEDURE set_days_to_months( p_days_to_month  NUMBER);

FUNCTION normalize_band( p_band_years        NUMBER,
                         p_band_months       NUMBER,
                         p_band_weeks        NUMBER,
                         p_band_days         NUMBER,
                         p_days_to_month     NUMBER)
         RETURN NUMBER;

PROCEDURE insert_service_band( p_service_min_years    NUMBER,
                               p_service_min_months   NUMBER,
                               p_service_min_weeks    NUMBER,
                               p_service_min_days     NUMBER);

PROCEDURE remove_service_band( p_service_min_years   NUMBER,
                               p_service_min_months  NUMBER,
                               p_service_min_weeks   NUMBER,
                               p_service_min_days    NUMBER);

PROCEDURE load_row( p_band_min_yrs       IN NUMBER,
                    p_band_min_mths      IN NUMBER,
                    p_band_min_wks       IN NUMBER,
                    p_band_min_days      IN NUMBER,
                    p_band_max_yrs       IN NUMBER,
                    p_band_max_mths      IN NUMBER,
                    p_band_max_wks       IN NUMBER,
                    p_band_max_days      IN NUMBER,
                    p_days_to_month      IN NUMBER,
                    p_owner              IN VARCHAR2 );

END hri_edw_dim_service;

 

/
