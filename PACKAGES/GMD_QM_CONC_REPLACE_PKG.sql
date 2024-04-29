--------------------------------------------------------
--  DDL for Package GMD_QM_CONC_REPLACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_QM_CONC_REPLACE_PKG" AUTHID CURRENT_USER AS
/* $Header: GMDQRPLS.pls 120.1.12010000.1 2008/07/24 09:58:41 appldev ship $ */

   p_last_update_date    DATE   := SYSDATE;
   p_last_updated_by     NUMBER := fnd_profile.VALUE ('USER_ID');
   p_last_update_login   NUMBER := fnd_profile.VALUE ('LOGIN_ID');

   TYPE search_result_rec IS RECORD (
      object_id            NUMBER
    , object_name          VARCHAR2 (240)
    , object_vers          NUMBER
    , object_desc          VARCHAR2 (240)
    , object_status_desc   VARCHAR2 (240)
    , object_select_ind    NUMBER
    , object_status_code   VARCHAR2 (240)
   );

   TYPE test_values IS RECORD (
      optional_ind        gmd_spec_tests_b.optional_ind%TYPE
    , print_spec_ind      gmd_spec_tests_b.print_spec_ind%TYPE
    , print_result_ind    gmd_spec_tests_b.print_result_ind%TYPE
    , target_value_num    gmd_spec_tests_b.target_value_num%TYPE
    , target_value_char   gmd_spec_tests_b.target_value_char%TYPE
    , min_value_num       gmd_spec_tests_b.min_value_num%TYPE
    , min_value_char      gmd_spec_tests_b.min_value_char%TYPE
    , max_value_num       gmd_spec_tests_b.max_value_num%TYPE
    , max_value_char      gmd_spec_tests_b.max_value_char%TYPE
    , report_precision    gmd_spec_tests_b.report_precision%TYPE
    , store_precision     gmd_spec_tests_b.display_precision%TYPE
    , test_priority       gmd_spec_tests_b.test_priority%TYPE
   );

   TYPE search_result_tbl IS TABLE OF search_result_rec INDEX BY BINARY_INTEGER;

   PROCEDURE populate_search_table (x_search_tbl OUT NOCOPY search_result_tbl);

   PROCEDURE mass_replace_oper_spec_val (
      err_buf             OUT NOCOPY      VARCHAR2
    , ret_code            OUT NOCOPY      VARCHAR2
    , pconcurrent_id      IN              VARCHAR2 DEFAULT NULL
    , pobject_type        IN              VARCHAR2
    , preplace_type       IN              VARCHAR2
    , pold_name           IN              VARCHAR2
    , pnew_name           IN              VARCHAR2
    , poptional_ind       IN              VARCHAR2 DEFAULT NULL
    , pprint_spec_ind     IN              VARCHAR2 DEFAULT NULL
    , pprint_result_ind   IN              VARCHAR2 DEFAULT NULL
    , ptarget_value       IN              VARCHAR2 DEFAULT NULL
    , ptarget_min         IN              VARCHAR2 DEFAULT NULL
    , ptarget_max         IN              VARCHAR2 DEFAULT NULL
    , preport_precision   IN              VARCHAR2 DEFAULT NULL
    , pstore_precision    IN              VARCHAR2 DEFAULT NULL
    , ptest_priority      IN              VARCHAR2 DEFAULT NULL
    , pcreate_vers        IN              VARCHAR2 DEFAULT 'N'
   );

END GMD_QM_CONC_REPLACE_PKG;

/
