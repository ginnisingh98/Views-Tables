--------------------------------------------------------
--  DDL for Package XLA_ANALYTICAL_CRITERIA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_ANALYTICAL_CRITERIA_PKG" AUTHID CURRENT_USER AS
/* $Header: xlabaacr.pkh 120.8 2007/05/03 23:03:02 masada ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_analytical_criteria_pkg                                        |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Analytical Criteria Package                                    |
|                                                                       |
| HISTORY                                                               |
|    27-AUG-02 A.Quaglia      Created                                   |
|    02-APR-03 A.Quaglia      Major revisions                           |
|    10-APR-03 A.Quaglia      Final adjustments                         |
|    08-SEP-03 A. Quaglia     Included the following functions/procs:   |
|                             compile_criterion                         |
|                             build_criteria_view                       |
+======================================================================*/

TYPE t_list_of_detail_chars   IS TABLE OF VARCHAR2(240);
TYPE t_list_of_detail_dates   IS TABLE OF DATE;
TYPE t_list_of_detail_numbers IS TABLE OF NUMBER;

TYPE t_analytical_criterion  IS RECORD
          ( anacri_code                   VARCHAR2(30)
           ,anacri_type_code              VARCHAR2(1)
           ,amb_context_code              VARCHAR2(30)
           ,list_of_detail_chars          t_list_of_detail_chars
           ,list_of_detail_dates          t_list_of_detail_dates
           ,list_of_detail_numbers        t_list_of_detail_numbers
          );

TYPE t_list_of_criteria      IS TABLE OF t_analytical_criterion;

--Public constants
   --Success
   C_SUCCESS                  CONSTANT INTEGER :=  0;
   --Could not lock row in xla_analytical_hdrs_b
   C_CANNOT_LOCK_DETAIL_ROW   CONSTANT INTEGER := -1;
   --One or more details could not be mapped to a column of
   --the view xla_analytical_criteria_v
   C_NO_AVAILABLE_VIEW_COLUMN CONSTANT INTEGER := -2;

FUNCTION update_detail_value
                       ( p_application_id   IN            INTEGER
                        ,p_ae_header_id     IN            INTEGER
                        ,p_ae_line_num      IN            INTEGER
                        ,p_list_of_criteria IN OUT NOCOPY t_list_of_criteria
                        ,p_update_mode      IN            VARCHAR2
                       )
RETURN BOOLEAN;


FUNCTION single_update_detail_value
                    ( p_application_id             IN INTEGER
                     ,p_ae_header_id               IN INTEGER
                     ,p_ae_line_num                IN INTEGER
                     ,p_analytical_detail_value_id IN INTEGER
                     ,p_anacri_code                IN VARCHAR2
                     ,p_anacri_type_code           IN VARCHAR2
                     ,p_amb_context_code           IN VARCHAR2
                     ,p_update_mode                IN VARCHAR2
                     ,p_detail_char_1              IN VARCHAR2 DEFAULT NULL
                     ,p_detail_date_1              IN DATE     DEFAULT NULL
                     ,p_detail_number_1            IN NUMBER   DEFAULT NULL
                     ,p_detail_char_2              IN VARCHAR2 DEFAULT NULL
                     ,p_detail_date_2              IN DATE     DEFAULT NULL
                     ,p_detail_number_2            IN NUMBER   DEFAULT NULL
                     ,p_detail_char_3              IN VARCHAR2 DEFAULT NULL
                     ,p_detail_date_3              IN DATE     DEFAULT NULL
                     ,p_detail_number_3            IN NUMBER   DEFAULT NULL
                     ,p_detail_char_4              IN VARCHAR2 DEFAULT NULL
                     ,p_detail_date_4              IN DATE     DEFAULT NULL
                     ,p_detail_number_4            IN NUMBER   DEFAULT NULL
                     ,p_detail_char_5              IN VARCHAR2 DEFAULT NULL
                     ,p_detail_date_5              IN DATE     DEFAULT NULL
                     ,p_detail_number_5            IN NUMBER   DEFAULT NULL
                    )
RETURN BOOLEAN;



FUNCTION get_detail_value_id
                ( p_anacri_code              IN VARCHAR2
                 ,p_anacri_type_code         IN VARCHAR2
                 ,p_amb_context_code         IN VARCHAR2
                 ,p_detail_char_1            IN VARCHAR2 DEFAULT NULL
                 ,p_detail_date_1            IN DATE     DEFAULT NULL
                 ,p_detail_number_1          IN NUMBER   DEFAULT NULL
                 ,p_detail_char_2            IN VARCHAR2 DEFAULT NULL
                 ,p_detail_date_2            IN DATE     DEFAULT NULL
                 ,p_detail_number_2          IN NUMBER   DEFAULT NULL
                 ,p_detail_char_3            IN VARCHAR2 DEFAULT NULL
                 ,p_detail_date_3            IN DATE     DEFAULT NULL
                 ,p_detail_number_3          IN NUMBER   DEFAULT NULL
                 ,p_detail_char_4            IN VARCHAR2 DEFAULT NULL
                 ,p_detail_date_4            IN DATE     DEFAULT NULL
                 ,p_detail_number_4          IN NUMBER   DEFAULT NULL
                 ,p_detail_char_5            IN VARCHAR2 DEFAULT NULL
                 ,p_detail_date_5            IN DATE     DEFAULT NULL
                 ,p_detail_number_5          IN NUMBER   DEFAULT NULL
                )
RETURN INTEGER;

FUNCTION single_update_detail_value
                    ( p_application_id             IN INTEGER
                     ,p_ae_header_id               IN INTEGER
                     ,p_ae_line_num                IN INTEGER
                     ,p_anacri_code                IN VARCHAR2
                     ,p_anacri_type_code           IN VARCHAR2
                     ,p_amb_context_code           IN VARCHAR2
                     ,p_update_mode                IN VARCHAR2
                     ,p_ac1                        IN VARCHAR2 DEFAULT NULL
                     ,p_ac2                        IN VARCHAR2 DEFAULT NULL
                     ,p_ac3                        IN VARCHAR2 DEFAULT NULL
                     ,p_ac4                        IN VARCHAR2 DEFAULT NULL
                     ,p_ac5                        IN VARCHAR2 DEFAULT NULL
                    )
RETURN BOOLEAN;

FUNCTION compile_criterion ( p_anacri_code              IN VARCHAR2
                            ,p_anacri_type_code         IN VARCHAR2
                            ,p_amb_context_code         IN VARCHAR2
                           )

RETURN INTEGER;

FUNCTION concat_detail_values
                ( p_anacri_code              IN VARCHAR2
                 ,p_anacri_type_code         IN VARCHAR2
                 ,p_amb_context_code         IN VARCHAR2
                 ,p_detail_char_1            IN VARCHAR2 DEFAULT NULL
                 ,p_detail_date_1            IN DATE     DEFAULT NULL
                 ,p_detail_number_1          IN NUMBER   DEFAULT NULL
                 ,p_detail_char_2            IN VARCHAR2 DEFAULT NULL
                 ,p_detail_date_2            IN DATE     DEFAULT NULL
                 ,p_detail_number_2          IN NUMBER   DEFAULT NULL
                 ,p_detail_char_3            IN VARCHAR2 DEFAULT NULL
                 ,p_detail_date_3            IN DATE     DEFAULT NULL
                 ,p_detail_number_3          IN NUMBER   DEFAULT NULL
                 ,p_detail_char_4            IN VARCHAR2 DEFAULT NULL
                 ,p_detail_date_4            IN DATE     DEFAULT NULL
                 ,p_detail_number_4          IN NUMBER   DEFAULT NULL
                 ,p_detail_char_5            IN VARCHAR2 DEFAULT NULL
                 ,p_detail_date_5            IN DATE     DEFAULT NULL
                 ,p_detail_number_5          IN NUMBER   DEFAULT NULL
                )
RETURN VARCHAR2;

FUNCTION build_criteria_view
RETURN INTEGER;

FUNCTION get_hdr_ac_count
RETURN INTEGER;

FUNCTION get_line_ac_count
RETURN INTEGER;

END xla_analytical_criteria_pkg;

/
