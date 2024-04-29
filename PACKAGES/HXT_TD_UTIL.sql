--------------------------------------------------------
--  DDL for Package HXT_TD_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_TD_UTIL" AUTHID CURRENT_USER AS
/* $Header: hxttdutl.pkh 120.0.12010000.3 2009/02/25 15:09:54 asrajago ship $ */




   TYPE rre_details IS RECORD
   ( session_date          DATE,
     upd_mode              VARCHAR2(15),
     ret_code              NUMBER
   );

   TYPE rre_details_assoc_array IS TABLE OF RRE_DETAILS INDEX BY VARCHAR2(25);

   g_rre_details_tab  RRE_DETAILS_ASSOC_ARRAY;

   g_td_session_date  DATE;



   FUNCTION get_weekly_total (
      a_location               IN   VARCHAR2,
      a_date_worked            IN   DATE,
      a_start_day_of_week      IN   VARCHAR2,
      a_tim_id                 IN   NUMBER,
      a_base_element_type_id   IN   NUMBER,
      a_ep_id                  IN   NUMBER,

   -- Added the following parameter for
   -- OTLR Recurring Period Preference Support.
      a_for_person_id          IN   NUMBER
   )
      RETURN NUMBER;

   FUNCTION get_weekly_total_prev_days (
      a_location               IN   VARCHAR2,
      a_date_worked            IN   DATE,
      a_start_day_of_week      IN   VARCHAR2,
      a_tim_id                 IN   NUMBER,
      a_base_element_type_id   IN   NUMBER,
      a_ep_id                  IN   NUMBER,

   -- Added the following parameter for
   -- OTLR Recurring Period Preference Support.
      a_for_person_id          IN   NUMBER
   )
      RETURN NUMBER;

   FUNCTION include_for_ot_cap (
      a_earn_group     IN   NUMBER,
      a_element_type   IN   NUMBER,
      a_base_element   IN   NUMBER,
      a_date_worked    IN   DATE
   )
      RETURN BOOLEAN;

   FUNCTION load_changed_status (a_hrw_id IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION load_error_status (a_hrw_id IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION determine_fixed_premium (
      p_tim_id                              NUMBER,
      p_id                                  NUMBER,
      p_hours                               NUMBER,
      p_element_type_id                     NUMBER,
      p_effective_start_date                DATE,
      p_effective_end_date                  DATE,
      p_return_code            OUT NOCOPY   NUMBER
   )
      RETURN NUMBER;

   FUNCTION get_hourly_rate (
      p_eff_date                     DATE,
      p_ptp_id                       NUMBER,
      p_assignment_id                NUMBER,
      p_hourly_rate     OUT NOCOPY   NUMBER
   )
      RETURN NUMBER;

   PROCEDURE retro_restrict_edit (
      p_tim_id          IN              hxt_det_hours_worked_f.tim_id%TYPE,
      p_session_date    IN              DATE,
      o_dt_update_mod   OUT NOCOPY      VARCHAR2,
      o_error_message   OUT NOCOPY      VARCHAR2,
      o_return_code     OUT NOCOPY      NUMBER,
      p_parent_id       IN              hxt_det_hours_worked_f.parent_id%TYPE
            DEFAULT NULL
   );

   FUNCTION load_tim_error_status (p_tim_id IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION load_hrw_error_change_status (
      p_hrw_id       IN   NUMBER,
      p_tim_status   IN   VARCHAR2
   )
      RETURN VARCHAR2;

   FUNCTION get_sum_hours_worked (
      p_tim_id        IN   NUMBER, -- p_hrw_group_id IN NUMBER,
      p_date_worked   IN   DATE
   )
      RETURN NUMBER;

   PROCEDURE get_contig_hrs_and_start (
      p_date_worked       IN              DATE,
      p_person_id         IN              NUMBER,
      p_current_time_in   IN              DATE,
      p_egt_id            IN              NUMBER,
      p_tim_id            IN              NUMBER,
      o_first_time_in     OUT NOCOPY      DATE,
      o_contig_hrs        OUT NOCOPY      NUMBER
   );
END;

/
