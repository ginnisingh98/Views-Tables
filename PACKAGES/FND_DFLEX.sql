--------------------------------------------------------
--  DDL for Package FND_DFLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_DFLEX" AUTHID CURRENT_USER AS
/* $Header: AFFFDDUS.pls 120.2.12010000.1 2008/07/25 14:13:44 appldev ship $ */


/* private */
/* unique identifier of a dflexfield: */
TYPE dflex_r IS RECORD (application_id      fnd_application.application_id%TYPE,
                        flexfield_name      fnd_descriptive_flexs_vl.descriptive_flexfield_name%TYPE);

/* public */
TYPE dflex_dr IS RECORD (title              fnd_descriptive_flexs_vl.title%TYPE,
                         table_name         fnd_descriptive_flexs_vl.application_table_name%TYPE,
                         table_app          fnd_application.application_short_name%TYPE,
                         description        fnd_descriptive_flexs_vl.description%TYPE,
                         segment_delimeter  fnd_descriptive_flexs_vl.concatenated_segment_delimiter%TYPE,
                         default_context_field    fnd_descriptive_flexs_vl.default_context_field_name%TYPE,
                         default_context_value    fnd_descriptive_flexs_vl.default_context_value%TYPE,
                         protected_flag           fnd_descriptive_flexs_vl.protected_flag%TYPE,
                         form_context_prompt      fnd_descriptive_flexs_vl.form_context_prompt%TYPE,
                         context_column_name      fnd_descriptive_flexs_vl.context_column_name%TYPE);

TYPE context_code_a IS TABLE OF fnd_descr_flex_contexts.descriptive_flex_context_code%TYPE INDEX BY BINARY_INTEGER;
TYPE context_name_a IS TABLE OF fnd_descr_flex_contexts_vl.descriptive_flex_context_name%TYPE INDEX BY BINARY_INTEGER;
TYPE context_description_a IS TABLE OF fnd_descr_flex_contexts_vl.description%TYPE INDEX BY BINARY_INTEGER;
TYPE boolean_a IS TABLE OF BOOLEAN INDEX BY BINARY_INTEGER;

/* private */
/* unique identifier of a context: */
TYPE context_r IS RECORD (flexfield             dflex_r,
                          context_code          fnd_descr_flex_contexts.descriptive_flex_context_code%TYPE);

/* public */
TYPE contexts_dr IS RECORD (ncontexts           BINARY_INTEGER,
                            global_context      BINARY_INTEGER,
                            context_code        context_code_a,
                            context_name        context_name_a,
                            context_description context_description_a,
                            is_enabled          boolean_a,
                            is_global           boolean_a);

TYPE segment_description_a IS TABLE OF fnd_descr_flex_col_usage_vl.description%TYPE INDEX BY BINARY_INTEGER;
TYPE application_column_name_a IS TABLE OF fnd_descr_flex_col_usage_vl.application_column_name%TYPE INDEX BY BINARY_INTEGER;
TYPE segment_name_a IS TABLE OF fnd_descr_flex_col_usage_vl.end_user_column_name%TYPE INDEX BY BINARY_INTEGER;
TYPE sequence_a IS TABLE OF fnd_descr_flex_col_usage_vl.column_seq_num%TYPE INDEX BY BINARY_INTEGER;
TYPE display_size_a IS TABLE OF fnd_descr_flex_col_usage_vl.display_size%TYPE INDEX BY BINARY_INTEGER;
TYPE row_prompt_a IS TABLE OF fnd_descr_flex_col_usage_vl.form_left_prompt%TYPE INDEX BY BINARY_INTEGER;
TYPE column_prompt_a IS TABLE OF fnd_descr_flex_col_usage_vl.form_above_prompt%TYPE INDEX BY BINARY_INTEGER;
TYPE value_set_a IS TABLE OF fnd_descr_flex_col_usage_vl.flex_value_set_id%TYPE INDEX BY BINARY_INTEGER;
TYPE default_type_a IS TABLE OF fnd_descr_flex_col_usage_vl.default_type%TYPE INDEX BY BINARY_INTEGER;
TYPE default_value_a IS TABLE OF fnd_descr_flex_col_usage_vl.default_value%TYPE INDEX BY BINARY_INTEGER;

TYPE segments_dr IS RECORD (nsegments           BINARY_INTEGER,
                            application_column_name application_column_name_a,
                            segment_name        segment_name_a,
                            sequence            sequence_a,
                            is_displayed        boolean_a,
                            display_size        display_size_a,
                            row_prompt          row_prompt_a,
                            column_prompt       column_prompt_a,
                            is_enabled          boolean_a,
                            is_required         boolean_a,
                            description         segment_description_a,
                            value_set           value_set_a,
                            default_type        default_type_a,
                            default_value       default_value_a);



/* returns information about the flexfield */
PROCEDURE get_flexfield(appl_short_name  IN  fnd_application.application_short_name%TYPE,
                        flexfield_name   IN  fnd_descriptive_flexs_vl.descriptive_flexfield_name%TYPE,
                        flexfield        OUT nocopy dflex_r,
                        flexinfo         OUT nocopy dflex_dr);

/* returns the contexts in a flexfield */
PROCEDURE get_contexts(flexfield         IN  dflex_r,
                       contexts          OUT nocopy contexts_dr);

FUNCTION make_context(flexfield          IN  dflex_r,
                      context_code       IN  fnd_descr_flex_contexts.descriptive_flex_context_code%TYPE)
  RETURN context_r;

/* returns information about all the segments in a particular context */
PROCEDURE get_segments(context           IN  context_r,
                       segments          OUT nocopy segments_dr,
                       enabled_only      IN BOOLEAN);

-- for back support purposes
-- this procedure originally was defined without enabled_only flag

PROCEDURE get_segments(context           IN  context_r,
                       segments          OUT nocopy segments_dr);



PROCEDURE test;

END fnd_dflex;                  /* end package */

/
