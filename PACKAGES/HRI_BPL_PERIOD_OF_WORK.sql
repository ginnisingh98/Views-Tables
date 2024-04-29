--------------------------------------------------------
--  DDL for Package HRI_BPL_PERIOD_OF_WORK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_BPL_PERIOD_OF_WORK" AUTHID CURRENT_USER AS
/* $Header: hriblow.pkh 120.2 2005/07/05 01:41:02 anmajumd noship $ */

FUNCTION normalize_band( p_band_years        NUMBER,
                         p_band_months       NUMBER,
                         p_band_weeks        NUMBER,
                         p_band_days         NUMBER,
                         p_days_to_month     NUMBER)
         RETURN NUMBER;

FUNCTION get_days_to_month RETURN NUMBER;

PROCEDURE set_days_to_months( p_days_to_month  NUMBER);

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

FUNCTION get_period_of_work_years(p_person_id       IN NUMBER,
                                   p_effective_date  IN DATE,
                                   p_assignment_type IN VARCHAR2)
               RETURN NUMBER;

FUNCTION get_period_of_work_months(p_person_id       IN NUMBER,
                                   p_effective_date  IN DATE,
                                   p_assignment_type IN VARCHAR2)
               RETURN NUMBER;

FUNCTION get_latest_hire_date(p_person_id       IN NUMBER,
                              p_effective_date  IN DATE,
                              p_assignment_type IN VARCHAR2)
               RETURN DATE;

FUNCTION get_pow_band_high_val(p_band_number       NUMBER,
                               p_assignment_type   VARCHAR2)
               RETURN NUMBER;

FUNCTION get_pow_band_sk_fk(p_band_number       NUMBER,
                            p_assignment_type   VARCHAR2)
RETURN NUMBER ;

END hri_bpl_period_of_work;

 

/
