--------------------------------------------------------
--  DDL for Package FND_FLEX_SERVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_FLEX_SERVER" AUTHID CURRENT_USER AS
/* $Header: AFFFSSVS.pls 120.3.12010000.3 2015/04/02 19:37:00 hgeorgi ship $ */

-- ----------------------------------------------------------------------
-- Internal functions.
--    These functions are only used within flex and are not to be used
--    by anyone else.  The functions are not supported in any manner
--    and their arguments and functionality are subject to change
--    without notice.
-- ----------------------------------------------------------------------

PROCEDURE validation_engine
  (user_apid             IN NUMBER,
   user_resp             IN NUMBER,
   userid                IN NUMBER,
   flex_app_sname        IN VARCHAR2,
   flex_code             IN VARCHAR2,
   select_comb_from_view IN VARCHAR2,
   flex_num              IN NUMBER,
   val_date              IN DATE,
   vrulestr              IN VARCHAR2,
   data_set              IN NUMBER,
   invoking_mode         IN VARCHAR2,
   validate_mode         IN VARCHAR2,
   dinsert               IN VARCHAR2,
   qsecurity             IN VARCHAR2,
   required              IN VARCHAR2,
   allow_nulls           IN VARCHAR2,
   display_segstr        IN VARCHAR2,
   concat_segs           IN VARCHAR2,
   vals_or_ids           IN VARCHAR2,
   where_clause          IN VARCHAR2,
   no_combmsg            IN VARCHAR2,
   where_clause_msg      IN VARCHAR2,
   get_extra_cols        IN VARCHAR2,
   ccid_in               IN NUMBER,
   nvalidated            OUT nocopy NUMBER,
   displayed_vals        OUT nocopy FND_FLEX_SERVER1.ValueArray,
   stored_vals           OUT nocopy FND_FLEX_SERVER1.ValueArray,
   segment_ids           OUT nocopy FND_FLEX_SERVER1.ValueIdArray,
   descriptions          OUT nocopy FND_FLEX_SERVER1.ValueDescArray,
   desc_lengths          OUT nocopy FND_FLEX_SERVER1.NumberArray,
   seg_colnames          OUT nocopy FND_FLEX_SERVER1.TabColArray,
   seg_coltypes          OUT nocopy FND_FLEX_SERVER1.CharArray,
   segment_types         OUT nocopy FND_FLEX_SERVER1.SegFormats,
   displayed_segs        OUT nocopy FND_FLEX_SERVER1.DisplayedSegs,
   derived_eff           OUT nocopy FND_FLEX_SERVER1.DerivedVals,
   table_eff             OUT nocopy FND_FLEX_SERVER1.DerivedVals,
   derived_quals         OUT nocopy FND_FLEX_SERVER1.Qualifiers,
   table_quals           OUT nocopy FND_FLEX_SERVER1.Qualifiers,
   n_column_vals         OUT nocopy NUMBER,
   column_vals           OUT nocopy FND_FLEX_SERVER1.StringArray,
   seg_delimiter         OUT nocopy VARCHAR2,
   ccid_out              OUT nocopy NUMBER,
   new_combination       OUT nocopy BOOLEAN,
   v_status              OUT nocopy NUMBER,
   seg_codes             OUT nocopy VARCHAR2,
   err_segnum            OUT nocopy NUMBER);

-- ----------------------------------------------------------------------
-- find_combination() function made public and used in AFFFEXTB package.
-- ----------------------------------------------------------------------
FUNCTION find_combination
  (structnum  IN NUMBER,
   combtbl    IN FND_FLEX_SERVER1.CombTblInfo,
   nsegs      IN NUMBER,
   combcols   IN FND_FLEX_SERVER1.TabColArray,
   combtypes  IN FND_FLEX_SERVER1.CharArray,
   segfmts    IN FND_FLEX_SERVER1.SegFormats,
   nquals     IN NUMBER,
   qualcols   IN FND_FLEX_SERVER1.TabColArray,
   nxcols     IN NUMBER,
   xcolnames  IN FND_FLEX_SERVER1.StringArray,
   where_cl   IN VARCHAR2,
   ccid       IN OUT nocopy NUMBER,
   segids     IN OUT nocopy FND_FLEX_SERVER1.ValueIdArray,
   tblderv    OUT nocopy FND_FLEX_SERVER1.DerivedVals,
   qualvals   OUT nocopy FND_FLEX_SERVER1.ValAttribArray,
   xcolvals   OUT nocopy FND_FLEX_SERVER1.StringArray)
  RETURN NUMBER;


-- ----------------------------------------------------------------------
FUNCTION parse_displayed
  (fstruct    IN FND_FLEX_SERVER1.FlexStructId,
   token_str  IN VARCHAR2,
   dispsegs   OUT nocopy FND_FLEX_SERVER1.DisplayedSegs)
  RETURN BOOLEAN;

-- ----------------------------------------------------------------------
FUNCTION concatenate_values
  (nvals      IN NUMBER,
   vals       IN FND_FLEX_SERVER1.ValueArray,
   displ      IN FND_FLEX_SERVER1.DisplayedSegs,
   delimiter  IN VARCHAR2)
  RETURN VARCHAR2;

-- ----------------------------------------------------------------------
FUNCTION concatenate_ids
  (nids       IN NUMBER,
   ids        IN FND_FLEX_SERVER1.ValueIdArray,
   delimiter  IN VARCHAR2)
  RETURN VARCHAR2;

-- ----------------------------------------------------------------------
FUNCTION concatenate_descriptions
  (ndescs     IN NUMBER,
   descs      IN FND_FLEX_SERVER1.ValueDescArray,
   displ      IN FND_FLEX_SERVER1.DisplayedSegs,
   lengths    IN FND_FLEX_SERVER1.NumberArray,
   delimiter  IN VARCHAR2)
  RETURN VARCHAR2;

-- ----------------------------------------------------------------------
-- The general purpose interface to the client c-code
-- ----------------------------------------------------------------------
PROCEDURE validate_combination
  (user_apid             IN NUMBER,
   user_resp             IN NUMBER,
   userid                IN NUMBER,
   flex_app_sname        IN VARCHAR2,
   flex_code             IN VARCHAR2,
   flex_num              IN NUMBER,
   vdate                 IN VARCHAR2,
   vrulestr              IN VARCHAR2,
   data_set              IN NUMBER,
   invoking_mode         IN VARCHAR2,
   validate_mode         IN VARCHAR2,
   dinsert               IN VARCHAR2,
   qsecurity             IN VARCHAR2,
   required              IN VARCHAR2,
   allow_nulls           IN VARCHAR2,
   display_segs          IN VARCHAR2,
   concat_segs           IN VARCHAR2,
   vals_or_ids           IN VARCHAR2,
   concat_vals_out       OUT nocopy VARCHAR2,
   concat_ids_out        OUT nocopy VARCHAR2,
   concat_desc           OUT nocopy VARCHAR2,
   where_clause          IN VARCHAR2,
   get_extra_cols        IN VARCHAR2,
   extra_cols            OUT nocopy VARCHAR2,
   get_valatts           IN VARCHAR2,
   valatts               OUT nocopy VARCHAR2,
   get_derived           IN VARCHAR2,
   derived_vals          OUT nocopy VARCHAR2,
   start_date            OUT nocopy VARCHAR2,
   end_date              OUT nocopy VARCHAR2,
   enabled_flag          OUT nocopy VARCHAR2,
   summary_flag          OUT nocopy VARCHAR2,
   seg_delimiter         OUT nocopy VARCHAR2,
   ccid_in               IN NUMBER,
   ccid_out              OUT nocopy NUMBER,
   vstatus               OUT nocopy NUMBER,
   segcodes              OUT nocopy VARCHAR2,
   error_seg             OUT nocopy NUMBER,
   message               OUT nocopy VARCHAR2,
   select_comb_from_view IN VARCHAR2,
   no_combmsg            IN VARCHAR2,
   where_clause_msg      IN VARCHAR2,
   server_debug_mode     IN VARCHAR2);

-- ----------------------------------------------------------------------
-- General purpose interface to the client c-code for descr flexs
-- ----------------------------------------------------------------------
PROCEDURE validate_descflex
  (user_apid       IN NUMBER,
   user_resp       IN NUMBER,
   userid          IN NUMBER,
   flex_app_sname  IN VARCHAR2,
   desc_flex_name  IN VARCHAR2,
   vdate           IN VARCHAR2,
   invoking_mode   IN VARCHAR2,
   allow_nulls     IN VARCHAR2,
   update_table    IN VARCHAR2,
   effective_activ IN VARCHAR2,
   concat_segs     IN VARCHAR2,
   vals_or_ids     IN VARCHAR2,
   c_rowid         IN VARCHAR2,
   alternate_table IN VARCHAR2,
   data_field      IN VARCHAR2,
   concat_vals_out OUT nocopy VARCHAR2,
   concat_ids_out  OUT nocopy VARCHAR2,
   concat_desc     OUT nocopy VARCHAR2,
   seg_delimiter   OUT nocopy VARCHAR2,
   vstatus         OUT nocopy NUMBER,
   segcodes        OUT nocopy VARCHAR2,
   error_seg       OUT nocopy NUMBER,
   message         OUT nocopy VARCHAR2);

-- ----------------------------------------------------------------------
-- Externalized function so client can use hash-lock mechanism.
-- Computes and locks hash value from ids passed in.
-- Returns hash number 0-999 or sets FND_MESSAGE and returns < 0
-- if error.
-- ----------------------------------------------------------------------
FUNCTION hash_lock
  (application_id  IN NUMBER,
   id_flex_code    IN VARCHAR2,
   id_flex_num     IN NUMBER,
   delimiter       IN VARCHAR2,
   concat_ids      IN VARCHAR2)
  RETURN NUMBER;

-- ----------------------------------------------------------------------
-- Externalized function so client can use hash-lock mechanism.
-- Computes and locks hash value from ids passed in.
-- Returns hash number 0-999 or sets FND_MESSAGE and returns < 0
-- if error.
-- This version returns error message if any.
-- ----------------------------------------------------------------------
FUNCTION client_hash_lock
  (application_id  IN NUMBER,
   id_flex_code    IN VARCHAR2,
   id_flex_num     IN NUMBER,
   delimiter       IN VARCHAR2,
   concat_ids      IN VARCHAR2,
   x_message       OUT nocopy VARCHAR2)
  RETURN NUMBER;

-- ----------------------------------------------------------------------
FUNCTION v_comb
  (user_apid       IN NUMBER,
   user_resp       IN NUMBER,
   userid          IN NUMBER,
   flex_app_sname  IN VARCHAR2,
   flex_code       IN VARCHAR2,
   flex_num        IN NUMBER,
   vdate           IN VARCHAR2,
   vrulestr        IN VARCHAR2,
   data_set        IN NUMBER,
   invoking_mode   IN VARCHAR2,
   validate_mode   IN VARCHAR2,
   dinsert         IN VARCHAR2,
   qsecurity       IN VARCHAR2,
   required        IN VARCHAR2,
   allow_nulls     IN VARCHAR2,
   display_segs    IN VARCHAR2,
   concat_segs     IN VARCHAR2,
   vals_or_ids     IN VARCHAR2,
   where_clause    IN VARCHAR2,
   extra_cols      IN VARCHAR2,
   get_valatts     IN VARCHAR2,
   get_derived     IN VARCHAR2,
   ccid            IN NUMBER)
  RETURN VARCHAR2;

-- ----------------------------------------------------------------------
FUNCTION v_desc
  (user_apid       IN NUMBER,
   user_resp       IN NUMBER,
   userid          IN NUMBER,
   flex_app_sname  IN VARCHAR2,
   desc_flex_name  IN VARCHAR2,
   vdate           IN VARCHAR2,
   invoking_mode   IN VARCHAR2,
   allow_nulls     IN VARCHAR2,
   update_table    IN VARCHAR2,
   eff_activation  IN VARCHAR2,
   concat_segs     IN VARCHAR2,
   vals_or_ids     IN VARCHAR2,
   c_rowid         IN VARCHAR2,
   alternate_table IN VARCHAR2,
   data_field      IN VARCHAR2)
  RETURN VARCHAR2;

-- ----------------------------------------------------------------------
FUNCTION p_win
  (user_apid       IN NUMBER,
   user_resp       IN NUMBER,
   flex_app_sname  IN VARCHAR2,
   flex_code       IN VARCHAR2,
   flex_num        IN NUMBER,
   vdate           IN VARCHAR2,
   vrulestr        IN VARCHAR2,
   display_segs    IN VARCHAR2,
   concat_segs     IN VARCHAR2)
  RETURN VARCHAR2;

-- ----------------------------------------------------------------------
PROCEDURE pre_window
  (user_apid       IN NUMBER,
   user_resp       IN NUMBER,
   flex_app_sname  IN VARCHAR2,
   flex_code       IN VARCHAR2,
   flex_num        IN NUMBER,
   vdate           IN VARCHAR2,
   vrulestr        IN VARCHAR2,
   display_segs    IN VARCHAR2,
   concat_segs     IN VARCHAR2,
   concat_vals_out OUT nocopy VARCHAR2,
   concat_ids_out  OUT nocopy VARCHAR2,
   concat_desc     OUT nocopy VARCHAR2,
   seg_delimiter   OUT nocopy VARCHAR2,
   seg_formats     OUT nocopy VARCHAR2,
   seg_codes       OUT nocopy VARCHAR2,
   n_segments      OUT nocopy NUMBER,
   v_status        OUT nocopy NUMBER,
   err_segnum      OUT nocopy NUMBER,
   message         OUT nocopy VARCHAR2);

-- ----------------------------------------------------------------------
FUNCTION s_maps
  (flex_app_sname  IN VARCHAR2,
   flex_code       IN VARCHAR2,
   flex_num        IN NUMBER,
   insert_tok      IN VARCHAR2,
   update_tok      IN VARCHAR2,
   display_tok     IN VARCHAR2)
  RETURN VARCHAR2;

-- ----------------------------------------------------------------------
PROCEDURE segment_maps
  (flex_app_sname  IN VARCHAR2,
   flex_code       IN VARCHAR2,
   flex_num        IN NUMBER,
   insert_token    IN VARCHAR2,
   update_token    IN VARCHAR2,
   display_token   IN VARCHAR2,
   insert_map      OUT nocopy VARCHAR2,
   update_map      OUT nocopy VARCHAR2,
   display_map     OUT nocopy VARCHAR2,
   required_map    OUT nocopy VARCHAR2,
   n_segments      OUT nocopy NUMBER,
   message         OUT nocopy VARCHAR2);

-- ----------------------------------------------------------------------
PROCEDURE segs_secured
  (resp_apid       IN NUMBER,
   resp_id         IN NUMBER,
   flex_app_sname  IN VARCHAR2,
   flex_code       IN VARCHAR2,
   flex_num        IN NUMBER,
   display_segs    IN VARCHAR2,
   concat_segs     IN VARCHAR2,
   segnum          OUT nocopy NUMBER,
   message         OUT nocopy VARCHAR2);

-- ----------------------------------------------------------------------
FUNCTION s_sec
  (resp_apid       IN NUMBER,
   resp_id         IN NUMBER,
   flex_app_sname  IN VARCHAR2,
   flex_code       IN VARCHAR2,
   flex_num        IN NUMBER,
   display_segs    IN VARCHAR2,
   concat_segs     IN VARCHAR2)
  RETURN VARCHAR2;

-- ----------------------------------------------------------------------
-- For debugging. Gets sql strings used for dynamic sql statements.
-- ----------------------------------------------------------------------
FUNCTION get_nsql
  RETURN NUMBER;

FUNCTION get_sql
  (statement_num   IN NUMBER,
   statement_piece IN NUMBER DEFAULT 1)
  RETURN VARCHAR2;

-- ----------------------------------------------------------------------
--  Gets additional string of debug information.
-- ----------------------------------------------------------------------
FUNCTION get_debug
  (stringnum IN NUMBER)
  RETURN VARCHAR2;

-- ----------------------------------------------------------------------
--  Turns on or off user PLSQL validation
-- ----------------------------------------------------------------------
PROCEDURE enable_user_validation
  (Y_or_N  IN VARCHAR2);

-- ----------------------------------------------------------------------
--  Turns on or off fdfgli calling from flex
-- ----------------------------------------------------------------------
PROCEDURE enable_fdfgli
  (Y_or_N  IN VARCHAR2);

-- ----------------------------------------------------------------------
--  Clears all caches in flex server validation package.
-- ----------------------------------------------------------------------
PROCEDURE clear_cache;


-- ----------------------------------------------------------------------
-- This procedure is deperecated and is only used for
-- backward compatability. Can be deleted in the future.
-- Called from Flex Java Validation Engine.
-- Uses autonomous transaction to insert new combination.
-- ----------------------------------------------------------------------
PROCEDURE do_dynamic_insert_for_java
  (p_application_id         IN NUMBER,
   p_id_flex_code           IN VARCHAR2,
   p_id_flex_num            IN NUMBER,
   p_application_table_name IN VARCHAR2,
   p_segment_delimiter      IN VARCHAR2,
   p_segment_count          IN NUMBER,
   p_validation_date        IN DATE,
   p_start_date_active      IN DATE,
   p_end_date_active        IN DATE,
   p_insert_sql             IN VARCHAR2,
   p_insert_sql_binds       IN VARCHAR2,
   p_select_sql             IN VARCHAR2,
   p_select_sql_binds       IN VARCHAR2,
   x_ccid                   OUT nocopy NUMBER,
   x_encoded_error          OUT nocopy VARCHAR2);


-- ----------------------------------------------------------------------
-- Bug 20057989
-- Called from Flex Java Validation Engine. Based on p_insert_only, it
-- uses autonomous or non-autonomous transaction to insert new combination.
-- TRUE uses autonomous transaction and commits the combination
-- FALSE uses non-autonomous transaction and doesn't commit. The calling
-- transaction has use save-points and do COMMIT or ROLLBACK
-- ----------------------------------------------------------------------
PROCEDURE do_dynamic_insert_for_java
  (p_application_id         IN NUMBER,
   p_id_flex_code           IN VARCHAR2,
   p_id_flex_num            IN NUMBER,
   p_application_table_name IN VARCHAR2,
   p_segment_delimiter      IN VARCHAR2,
   p_segment_count          IN NUMBER,
   p_validation_date        IN DATE,
   p_start_date_active      IN DATE,
   p_end_date_active        IN DATE,
   p_insert_sql             IN VARCHAR2,
   p_insert_sql_binds       IN VARCHAR2,
   p_select_sql             IN VARCHAR2,
   p_select_sql_binds       IN VARCHAR2,
   p_insert_only            IN NUMBER,
   x_ccid                   OUT nocopy NUMBER,
   x_encoded_error          OUT nocopy VARCHAR2);

-- ----------------------------------------------------------------------
-- Uses autonomous transaction and commits the combination
-- ----------------------------------------------------------------------
PROCEDURE do_dynamic_insert_at
  (p_application_id         IN NUMBER,
   p_id_flex_code           IN VARCHAR2,
   p_id_flex_num            IN NUMBER,
   p_application_table_name IN VARCHAR2,
   p_segment_delimiter      IN VARCHAR2,
   p_segment_count          IN NUMBER,
   p_validation_date        IN DATE,
   p_start_date_active      IN DATE,
   p_end_date_active        IN DATE,
   p_insert_sql             IN VARCHAR2,
   p_insert_sql_binds       IN VARCHAR2,
   p_select_sql             IN VARCHAR2,
   p_select_sql_binds       IN VARCHAR2,
   x_ccid                   OUT nocopy NUMBER,
   x_is_new                 OUT nocopy VARCHAR2,
   x_encoded_error          OUT nocopy VARCHAR2);


-- ----------------------------------------------------------------------
-- Uses non-autonomous transaction and doesn't commit.
-- The calling transaction has to instantiate the
-- save-points and do COMMIT or ROLLBACK
-- ----------------------------------------------------------------------
PROCEDURE do_dynamic_insert_no_at
  (p_application_id         IN NUMBER,
   p_id_flex_code           IN VARCHAR2,
   p_id_flex_num            IN NUMBER,
   p_application_table_name IN VARCHAR2,
   p_segment_delimiter      IN VARCHAR2,
   p_segment_count          IN NUMBER,
   p_validation_date        IN DATE,
   p_start_date_active      IN DATE,
   p_end_date_active        IN DATE,
   p_insert_sql             IN VARCHAR2,
   p_insert_sql_binds       IN VARCHAR2,
   p_select_sql             IN VARCHAR2,
   p_select_sql_binds       IN VARCHAR2,
   x_ccid                   OUT nocopy NUMBER,
   x_is_new                 OUT nocopy VARCHAR2,
   x_encoded_error          OUT nocopy VARCHAR2);


-- ----------------------------------------------------------------------
-- Checks if a value is secured.
-- ----------------------------------------------------------------------
PROCEDURE check_value_security
  (p_security_check_mode   IN VARCHAR2,
   p_flex_value_set_id     IN NUMBER,
   p_parent_flex_value     IN VARCHAR2,
   p_flex_value            IN VARCHAR2,
   p_resp_application_id   IN NUMBER,
   p_responsibility_id     IN NUMBER,
   x_security_status       OUT nocopy VARCHAR2,
   x_error_message         OUT nocopy VARCHAR2);

-- ----------------------------------------------------------------------
-- parse_flex_values:
--
-- Escape character:
--   While concatenating segment values, flex uses '\' to escape
--   delimiter character and escape character if they appear inside the
--   segment values.
--
-- Arguments:
--   p_concatenated_flex_values : Concatenated combination.
--   p_delimiter                : Flexfield delimiter.
--   p_numof_flex_values        : Expected number of flex values.
--                                If 1, then the full combination is returned
--                                as the value of the first segment. (This
--                                ensures that escaping logic is not used for
--                                single segment flexfields.
--                                Ideally speaking this function should not be
--                                called if it is known that there is only one
--                                segment.
--                                If this value is not 1, then flex will parse
--                                the combination by using delimiter.
--   x_flex_values              : Flex values array.
--   x_numof_flex_values        : Number of flex values that parser found out.
--                                This value may not be same as
--                                p_numof_flex_values. See examples.
--
--
-- Examples: Assume delimiter is '.'.
--
-- p_concatenated_  p_numof_                                x_numof_
-- flex_values      flex_values   x_flex_values             flex_values
-- ---------------  ------------  ------------------------- ------------
-- "A\B\\C.D\.E"    1             "A\B\\C.D\.E"             1
-- "A\B\\C.D\.E"    not 1         "AB\C", "D.E"             2
-- "A\B\\CD\.E"     not 1         "AB\CD.E"                 1
-- "A.B.C"          not 1         "A", "B", "C"             3
-- ""               not 1         ""                        1
-- "AB.CD\\"        not 1         "AB", "CD\"               2
-- "AB.CD\"         not 1         "AB", "CD"                2
--
-- ----------------------------------------------------------------------
PROCEDURE parse_flex_values
  (p_concatenated_flex_values IN VARCHAR2,
   p_delimiter                IN VARCHAR2,
   p_numof_flex_values        IN NUMBER DEFAULT NULL,
   x_flex_values              OUT nocopy fnd_flex_server1.stringarray,
   x_numof_flex_values        OUT nocopy NUMBER);

-- ----------------------------------------------------------------------
-- concatenate_flex_values:
--
-- Arguments:
--   p_flex_values              : Flex values array.
--   p_numof_flex_values        : Number of elements in p_flex_values array.
--                                If 1 then the first element of p_flex_values
--                                array is copied to x_concatenated_flex_values
--                                If not 1 then the values are concatenated by
--                                using flex delimiter and applying the
--                                escaping logic to special characters.
--   p_delimiter                : Flexfield delimiter.
--   x_concatenated_flex_values : Concatenated combination.
--
-- Examples: Assume delimiter is '.'.
--
-- p_flex_values      p_numof_flex_values  x_concatenated_flex_values
-- -----------------  -------------------  --------------------------
-- "A\B\\C.D\.E"      1                    "A\B\\C.D\.E"
-- "AB\C", "D.E"      2                    "A\B\\C.D\.E"
-- "AB\CD.E"          1                    "AB\CD.E"
-- "A", "B", "C"      3                    "A.B.C"
-- ""                 1                    ""
-- "AB", "CD\"        2                    "AB.CD\\"
-- "AB", "CD"         2                    "AB.CD"
--
-- ----------------------------------------------------------------------
PROCEDURE concatenate_flex_values
  (p_flex_values              IN fnd_flex_server1.stringarray,
   p_numof_flex_values        IN NUMBER,
   p_delimiter                IN VARCHAR2,
   x_concatenated_flex_values OUT nocopy VARCHAR2);

-- ----------------------------------------------------------------------
FUNCTION get_concatenated_value
  (p_delimiter     IN VARCHAR2,
   p_segment_count IN NUMBER,
   p_segment1      IN VARCHAR2 DEFAULT NULL,
   p_segment2      IN VARCHAR2 DEFAULT NULL,
   p_segment3      IN VARCHAR2 DEFAULT NULL,
   p_segment4      IN VARCHAR2 DEFAULT NULL,
   p_segment5      IN VARCHAR2 DEFAULT NULL,
   p_segment6      IN VARCHAR2 DEFAULT NULL,
   p_segment7      IN VARCHAR2 DEFAULT NULL,
   p_segment8      IN VARCHAR2 DEFAULT NULL,
   p_segment9      IN VARCHAR2 DEFAULT NULL,
   p_segment10     IN VARCHAR2 DEFAULT NULL,
   p_segment11     IN VARCHAR2 DEFAULT NULL,
   p_segment12     IN VARCHAR2 DEFAULT NULL,
   p_segment13     IN VARCHAR2 DEFAULT NULL,
   p_segment14     IN VARCHAR2 DEFAULT NULL,
   p_segment15     IN VARCHAR2 DEFAULT NULL,
   p_segment16     IN VARCHAR2 DEFAULT NULL,
   p_segment17     IN VARCHAR2 DEFAULT NULL,
   p_segment18     IN VARCHAR2 DEFAULT NULL,
   p_segment19     IN VARCHAR2 DEFAULT NULL,
   p_segment20     IN VARCHAR2 DEFAULT NULL,
   p_segment21     IN VARCHAR2 DEFAULT NULL,
   p_segment22     IN VARCHAR2 DEFAULT NULL,
   p_segment23     IN VARCHAR2 DEFAULT NULL,
   p_segment24     IN VARCHAR2 DEFAULT NULL,
   p_segment25     IN VARCHAR2 DEFAULT NULL,
   p_segment26     IN VARCHAR2 DEFAULT NULL,
   p_segment27     IN VARCHAR2 DEFAULT NULL,
   p_segment28     IN VARCHAR2 DEFAULT NULL,
   p_segment29     IN VARCHAR2 DEFAULT NULL,
   p_segment30     IN VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2;

-- ----------------------------------------------------------------------
PROCEDURE raise_dff_compiled
  (p_application_id             IN NUMBER,
   p_descriptive_flexfield_name IN VARCHAR2);

-- ----------------------------------------------------------------------
PROCEDURE raise_kff_structure_compiled
  (p_application_id IN NUMBER,
   p_id_flex_code   IN VARCHAR2,
   p_id_flex_num    IN NUMBER);

-- ----------------------------------------------------------------------
PROCEDURE raise_vst_updated
  (p_flex_value_set_id IN NUMBER);

-- ----------------------------------------------------------------------
-- Concatenation Modes
--
-- COMPACT : Values are returned as they are.
-- PADDED  : Numbers are left padded to their value set maximum size
--           Everything else is right padded to their value set maximum size
--
CONCAT_MODE_COMPACT     CONSTANT VARCHAR2(30) := 'COMPACT';
CONCAT_MODE_PADDED      CONSTANT VARCHAR2(30) := 'PADDED';

-- ---------------------------------------------------------------------
-- Returns concatenated segments for a given CCID (Code Combination ID)
-- from the code combinations table.
--
-- p_concat_mode - concat mode. e.g. CONCAT_MODE_COMPACT
-- p_application_id - application_id of the KFF. e.g. 101
-- p_id_flex_code - id_flex_code of the KFF. e.g. 'GL#'
-- p_id_flex_num - id_flx_num of the KFF. e.g. 101
-- p_ccid - code combination id from the code combinations table.
-- p_data_set - (optional) Data striping number. Used by certain KFFs
--              (Usually the organization_id). e.g. 101
-- ----------------------------------------------------------------------
FUNCTION get_kfv_concat_segs_by_ccid
  (p_concat_mode    IN VARCHAR2,
   p_application_id IN NUMBER,
   p_id_flex_code   IN VARCHAR2,
   p_id_flex_num    IN NUMBER,
   p_ccid           IN NUMBER,
   p_data_set       IN NUMBER DEFAULT NULL)
  RETURN VARCHAR2;

-- ----------------------------------------------------------------------
-- Returns concatenated segments for a given ROWID
-- from the code combinations table.
--
-- p_concat_mode - concat mode. e.g. CONCAT_MODE_COMPACT
-- p_application_id - application_id of the KFF. e.g. 101
-- p_id_flex_code - id_flex_code of the KFF. e.g. 'GL#'
-- p_id_flex_num - id_flx_num of the KFF. e.g. 101
-- p_rowid - ROWID from the code combinations table.
-- ----------------------------------------------------------------------
FUNCTION get_kfv_concat_segs_by_rowid
  (p_concat_mode    IN VARCHAR2,
   p_application_id IN NUMBER,
   p_id_flex_code   IN VARCHAR2,
   p_id_flex_num    IN NUMBER,
   p_rowid          IN VARCHAR2)
  RETURN VARCHAR2;

-- ----------------------------------------------------------------------
-- PRIVATE: FLEX INTERNAL USE ONLY
-- ----------------------------------------------------------------------
PROCEDURE request_lock
  (p_lock_name    IN VARCHAR2,
   px_lock_handle IN OUT nocopy VARCHAR2);

-- ----------------------------------------------------------------------
-- PRIVATE: FLEX INTERNAL USE ONLY
-- ----------------------------------------------------------------------
PROCEDURE release_lock
  (p_lock_name   IN VARCHAR2,
   p_lock_handle IN VARCHAR2);

-- ----------------------------------------------------------------------
-- PRIVATE: FLEX INTERNAL USE ONLY
-- ----------------------------------------------------------------------
PROCEDURE compute_non_forms_warnings_dff
  (p_application_id             IN NUMBER,
   p_descriptive_flexfield_name IN VARCHAR2,
   x_warning_count              OUT nocopy NUMBER);

-- ----------------------------------------------------------------------
-- PRIVATE: FLEX INTERNAL USE ONLY
-- ----------------------------------------------------------------------
PROCEDURE compute_non_forms_warnings_kff
  (p_application_id  IN NUMBER,
   p_id_flex_code    IN VARCHAR2,
   p_id_flex_num     IN NUMBER,
   x_warning_count   OUT nocopy NUMBER);

-- ----------------------------------------------------------------------
-- PRIVATE: FLEX INTERNAL USE ONLY
-- ----------------------------------------------------------------------
FUNCTION get_non_forms_warning
  (p_warning_index IN NUMBER)
  RETURN VARCHAR2;

END fnd_flex_server;

/
