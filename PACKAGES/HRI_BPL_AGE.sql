--------------------------------------------------------
--  DDL for Package HRI_BPL_AGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_BPL_AGE" AUTHID CURRENT_USER AS
/* $Header: hribage.pkh 115.6 2002/05/10 07:55:01 pkm ship      $ */


PROCEDURE insert_age_band( p_age_min_years	NUMBER,
			     p_age_min_months   NUMBER);

PROCEDURE remove_age_band( p_age_min_years	NUMBER,
                             p_age_min_months   NUMBER);

PROCEDURE load_row( p_band_min     IN NUMBER,
                    p_band_max     IN NUMBER,
                    p_owner        IN VARCHAR2 );

END hri_bpl_age;

 

/
