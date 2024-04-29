--------------------------------------------------------
--  DDL for Package HRI_APL_TIME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_APL_TIME" AUTHID CURRENT_USER AS
/* $Header: hriatime.pkh 115.1 2002/10/10 13:30:45 jtitmas noship $ */

PROCEDURE insert_time_band(p_type           IN VARCHAR2,
                           p_band_min_day_comp   IN NUMBER,
                           p_band_min_week_comp  IN NUMBER,
                           p_band_min_month_comp IN NUMBER,
                           p_band_min_year_comp  IN NUMBER);

PROCEDURE remove_time_band(p_type           IN VARCHAR2,
                           p_band_min_day_comp   IN NUMBER,
                           p_band_min_week_comp  IN NUMBER,
                           p_band_min_month_comp IN NUMBER,
                           p_band_min_year_comp  IN NUMBER);

PROCEDURE remove_time_band(p_type           IN VARCHAR2);

PROCEDURE load_time_band_row(p_type                 IN VARCHAR2,
                             p_band_min             IN NUMBER,
                             p_band_max             IN NUMBER,
                             p_band_sequence        IN NUMBER,
                             p_band_min_day_comp    IN NUMBER,
                             p_band_min_week_comp   IN NUMBER,
                             p_band_min_month_comp  IN NUMBER,
                             p_band_min_year_comp   IN NUMBER,
                             p_band_max_day_comp    IN NUMBER,
                             p_band_max_week_comp   IN NUMBER,
                             p_band_max_month_comp  IN NUMBER,
                             p_band_max_year_comp   IN NUMBER,
                             p_owner                IN VARCHAR2);

END hri_apl_time;

 

/
