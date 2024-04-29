--------------------------------------------------------
--  DDL for Package AP_WEB_UPLOAD_PDM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_UPLOAD_PDM_PKG" AUTHID CURRENT_USER AS
/* $Header: apwupdms.pls 120.4 2006/08/28 20:40:31 rlangi noship $ */

  g_debug_switch              VARCHAR2(1) := 'N';
  g_last_updated_by           NUMBER;
  g_last_update_login         NUMBER;

  g_num_recs_processed        NUMBER := 0;
  g_num_locs_created          NUMBER := 0;
  g_num_locs_invalid          NUMBER := 0;
  g_num_locs_zero_rates       NUMBER := 0;
  g_num_std_rates_created     NUMBER := 0;
  g_num_night_rates_created   NUMBER := 0;
  g_num_std_rates_updated     NUMBER := 0;

  type Invalid_Locs           is table of varchar2(240);
  g_invalid_locs              Invalid_Locs;
  type Zero_Rates             is table of varchar2(240);
  g_zero_rates                Zero_Rates;

------------------------------------------------------------------------
FUNCTION MyReplace(p_string           IN VARCHAR2) RETURN VARCHAR2;
------------------------------------------------------------------------

------------------------------------------------------------------------
FUNCTION MySoundex(p_string           IN VARCHAR2) RETURN VARCHAR2;
------------------------------------------------------------------------

------------------------------------------------------------------------
FUNCTION GetTerritory(p_country           IN VARCHAR2) RETURN VARCHAR2;
------------------------------------------------------------------------

------------------------------------------------------------------------
FUNCTION GetCityLocation(p_city_locality   IN VARCHAR2,
                         p_county          IN VARCHAR2,
                         p_state_province  IN VARCHAR2,
                         p_country         IN VARCHAR2) RETURN NUMBER;
------------------------------------------------------------------------

------------------------------------------------------------------------
FUNCTION GetRateIncludesMeals(p_per_diem_type_code   IN VARCHAR2) RETURN VARCHAR2;
FUNCTION GetRateIncludesIncidentals(p_per_diem_type_code   IN VARCHAR2) RETURN VARCHAR2;
FUNCTION GetRateIncludesAccommodations(p_per_diem_type_code   IN VARCHAR2) RETURN VARCHAR2;
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE CreateSchedule(errbuf                 OUT NOCOPY VARCHAR2,
                         retcode                OUT NOCOPY NUMBER,
                         p_ratetype             IN VARCHAR2,
                         p_expense_category     IN VARCHAR2,
                         p_policy_name          IN VARCHAR2,
                         p_policy_start_date    IN DATE,
                         p_period_name          IN VARCHAR2,
                         p_period_start_date    IN DATE,
                         p_rate_incl_meals      IN VARCHAR2,
                         p_rate_incl_inc        IN VARCHAR2,
                         p_rate_incl_acc        IN VARCHAR2,
                         p_meals_rate           IN VARCHAR2,
                         p_free_meals_ded       IN VARCHAR2,
                         p_use_free_acc_add     IN VARCHAR2,
                         p_use_free_acc_ded     IN VARCHAR2,
                         p_calc_method          IN VARCHAR2,
                         p_single_deduction     IN NUMBER,
                         p_breakfast_deduction  IN NUMBER,
                         p_lunch_deduction      IN NUMBER,
                         p_dinner_deduction     IN NUMBER);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE UpdateSchedule(errbuf                 OUT NOCOPY VARCHAR2,
                         retcode                OUT NOCOPY NUMBER,
                         p_ratetype             IN VARCHAR2,
                         p_expense_category     IN VARCHAR2,
                         p_policy_id            IN NUMBER,
                         p_period_type          IN VARCHAR2,
                         p_period_id            IN VARCHAR2,
                         p_period_name          IN VARCHAR2,
                         p_period_start_date    IN DATE,
                         p_rate_incl_meals      IN VARCHAR2,
                         p_rate_incl_inc        IN VARCHAR2,
                         p_rate_incl_acc        IN VARCHAR2,
                         p_meals_rate           IN VARCHAR2,
                         p_free_meals_ded       IN VARCHAR2,
                         p_use_free_acc_add     IN VARCHAR2,
                         p_use_free_acc_ded     IN VARCHAR2,
                         p_calc_method          IN VARCHAR2,
                         p_single_deduction     IN NUMBER,
                         p_breakfast_deduction  IN NUMBER,
                         p_lunch_deduction      IN NUMBER,
                         p_dinner_deduction     IN NUMBER);
------------------------------------------------------------------------

------------------------------------------------------------------------
FUNCTION CheckPolicyExists(p_expense_category       IN VARCHAR2,
                           p_policy_name            IN VARCHAR2) RETURN VARCHAR2;
------------------------------------------------------------------------
------------------------------------------------------------------------
FUNCTION CheckPeriodExists(p_policy_id            IN VARCHAR2,
                           p_period_name          IN VARCHAR2,
                           p_period_start_date    IN DATE) RETURN VARCHAR2;
------------------------------------------------------------------------
------------------------------------------------------------------------
FUNCTION GetLatestPeriodStartDate(p_policy_id            IN VARCHAR2) RETURN DATE;
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE UploadRates(errbuf                 OUT NOCOPY VARCHAR2,
                      retcode                OUT NOCOPY NUMBER,
                      p_ratetype             IN VARCHAR2,
                      p_action               IN VARCHAR2,
                      p_source               IN VARCHAR2,
                      p_datafile             IN VARCHAR2,
                      p_expense_category     IN VARCHAR2,
                      p_policy_id            IN NUMBER,
                      p_policy_name          IN VARCHAR2,
                      p_policy_start_date    IN VARCHAR2,
                      p_period_type          IN VARCHAR2,
                      p_period_id            IN NUMBER,
                      p_period_name          IN VARCHAR2,
                      p_period_start_date    IN VARCHAR2,
                      p_rate_incl_meals      IN VARCHAR2,
                      p_rate_incl_inc        IN VARCHAR2,
                      p_rate_incl_acc        IN VARCHAR2,
                      p_meals_rate           IN VARCHAR2,
                      p_free_meals_ded       IN VARCHAR2,
                      p_use_free_acc_add     IN VARCHAR2,
                      p_use_free_acc_ded     IN VARCHAR2,
                      p_calc_method          IN VARCHAR2,
                      p_single_deduction     IN NUMBER,
                      p_breakfast_deduction  IN NUMBER,
                      p_lunch_deduction      IN NUMBER,
                      p_dinner_deduction     IN NUMBER);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE UploadCONUS(errbuf out nocopy varchar2,
                      retcode out nocopy number,
                      p_datafile in varchar2,
                      p_request_status out nocopy varchar2);

PROCEDURE UploadOCONUS(errbuf out nocopy varchar2,
                       retcode out nocopy number,
                       p_datafile in varchar2,
                       p_request_status out nocopy varchar2);
------------------------------------------------------------------------
PROCEDURE ValidateCONUS(errbuf out nocopy varchar2,
                        retcode out nocopy number,
                        p_datafile in varchar2);
PROCEDURE ValidateOCONUS(errbuf out nocopy varchar2,
                         retcode out nocopy number,
                         p_datafile in varchar2);
------------------------------------------------------------------------
PROCEDURE ValidateFileFormat(errbuf out nocopy varchar2,
                             retcode out nocopy number,
                             p_ratetype in varchar2,
                             p_datafile in varchar2);
/*
PROCEDURE ValidateFileFormat(p_ratetype in varchar2,
                             p_datafile in varchar2);
*/
------------------------------------------------------------------------

END AP_WEB_UPLOAD_PDM_PKG;

 

/
