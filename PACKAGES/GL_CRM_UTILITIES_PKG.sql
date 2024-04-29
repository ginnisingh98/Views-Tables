--------------------------------------------------------
--  DDL for Package GL_CRM_UTILITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_CRM_UTILITIES_PKG" AUTHID CURRENT_USER AS
   /* $Header: glcrmuts.pls 120.1.12010000.4 2010/04/26 12:23:04 sommukhe ship $ */
   DEBUG_MODE          BOOLEAN := FALSE;
   enable_trigger      BOOLEAN := FALSE;
   page_line_numbers   NUMBER  := 65;
   page_count          NUMBER  := 1;
   page_line_count     NUMBER  := 1;

   TYPE var_arr15 IS TABLE OF VARCHAR2(15);

   TYPE var_arr30 IS TABLE OF VARCHAR2(30);

   TYPE date_arr IS TABLE OF DATE;

   TYPE num_arr IS TABLE OF NUMBER;

   TYPE curr_rec IS RECORD(
      r_from_curr   var_arr15,
      r_to_curr     var_arr15
   );

   TYPE daily_rate_interface_rec IS RECORD(
      r_from_curr      var_arr15,
      r_to_curr        var_arr15,
      r_from_date      date_arr,
      r_to_date        date_arr,
      r_type           var_arr30,
      r_rate           num_arr,
      r_inverse_rate   num_arr,
      r_error_code     var_arr30
   );

   TYPE daily_rate_rec IS RECORD(
      r_from_curr          var_arr15,
      r_to_curr            var_arr15,
      r_conversion_date    date_arr,
      r_type               var_arr30,
      r_rate               num_arr,
      r_rate_source_code   var_arr30
   );

   PROCEDURE insert_cross_rate_set(
      p_conversion_type          IN       VARCHAR2,
      p_contra_currency          IN       VARCHAR2,
      p_login_user               IN       NUMBER);

   PROCEDURE update_cross_rate_set(
      p_conversion_type          IN       VARCHAR2,
      p_new_contra_currency      IN       VARCHAR2,
      p_old_contra_currency      IN       VARCHAR2,
      p_login_user               IN       NUMBER);

   PROCEDURE delete_cross_rate_set(
      p_conversion_type          IN       VARCHAR2,
      p_contra_currency          IN       VARCHAR2);

   PROCEDURE daily_rates_import(
      errbuf                     OUT NOCOPY VARCHAR2,
      retcode                    OUT NOCOPY NUMBER,
      p_batch_number		 IN  VARCHAR2 DEFAULT NULL);

   FUNCTION submit_conc_request
      RETURN NUMBER;

   PROCEDURE change_flag(
      flag                                BOOLEAN);
END GL_CRM_UTILITIES_PKG;

/
