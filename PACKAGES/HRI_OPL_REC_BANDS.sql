--------------------------------------------------------
--  DDL for Package HRI_OPL_REC_BANDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OPL_REC_BANDS" AUTHID CURRENT_USER AS
/* $Header: hriprbnd.pkh 115.0 2002/09/25 13:36:17 jtitmas noship $ */

FUNCTION is_in_apl_band(p_value          IN NUMBER,
                        p_band_sequence  IN NUMBER)
             RETURN NUMBER;

FUNCTION is_in_vac_band(p_value          IN NUMBER,
                        p_band_sequence  IN NUMBER)
             RETURN NUMBER;

FUNCTION get_apl_time_band_name(p_band_sequence    IN NUMBER)
                 RETURN VARCHAR2;

FUNCTION get_vac_time_band_name(p_band_sequence    IN NUMBER)
                 RETURN VARCHAR2;

END hri_opl_rec_bands;

 

/
