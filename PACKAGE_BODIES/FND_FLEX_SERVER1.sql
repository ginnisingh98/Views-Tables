--------------------------------------------------------
--  DDL for Package Body FND_FLEX_SERVER1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FLEX_SERVER1" AS
/* $Header: AFFFSV1B.pls 120.22.12010000.26 2017/02/13 22:39:05 tebarnes ship $ */

--------
-- PRIVATE TYPES
--
--
--  Segment array is 1-based containing entries for i <= i <= nsegs

TYPE SqlStringArray IS TABLE OF VARCHAR2(10000) INDEX BY BINARY_INTEGER;
TYPE VsNameArray IS TABLE OF VARCHAR2(60) INDEX BY BINARY_INTEGER;
TYPE SegNameArray IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

-- Stored value is value stored in the database.
-- Displayed value is value displayed to the user.  This depends on the
-- users NLS parameters at runtime.
--
TYPE FlexValue IS RECORD
   (displayed_value        VARCHAR2(1000),
    stored_value           VARCHAR2(1000),
    hidden_id              VARCHAR2(1000),
    description            VARCHAR2(1000),
    format                 VARCHAR2(4),
    compiled_attributes    VARCHAR2(2000),
    summary_flag           VARCHAR2(1),
    enabled_flag           VARCHAR2(1),
    start_valid            DATE,
    end_valid              DATE);

TYPE SegmentInfo IS RECORD
   (segname                   fnd_id_flex_segments.segment_name%TYPE,
    colname                   fnd_id_flex_segments.application_column_name%TYPE,
    coltype                   fnd_columns.column_type%TYPE,
    collen                    fnd_columns.width%TYPE,
    required                  fnd_id_flex_segments.required_flag%TYPE,
    segsecure                 fnd_id_flex_segments.security_enabled_flag%TYPE,
    catdesclen                fnd_id_flex_segments.concatenation_description_len%TYPE,
    dflt_type                 fnd_id_flex_segments.default_type%TYPE,
    dflt_val                  fnd_id_flex_segments.default_value%TYPE,
    vsid                      fnd_id_flex_segments.flex_value_set_id%TYPE,
    runtime_property_function fnd_id_flex_segments.runtime_property_function%TYPE,
    additional_where_clause   fnd_id_flex_segments.additional_where_clause%TYPE);

TYPE ValueSetInfo IS RECORD
    (vsid           fnd_flex_value_sets.flex_value_set_id%TYPE,
     parent_vsid    fnd_flex_value_sets.parent_flex_value_set_id%TYPE,
     valsecure      fnd_flex_value_sets.security_enabled_flag%TYPE,
     valtype        fnd_flex_value_sets.validation_type%TYPE,
     vsformat       fnd_flex_value_sets.format_type%TYPE,
     maxsize        fnd_flex_value_sets.maximum_size%TYPE,
     lettersok      fnd_flex_value_sets.alphanumeric_allowed_flag%TYPE,
     capsonly       fnd_flex_value_sets.uppercase_only_flag%TYPE,
     zfill          fnd_flex_value_sets.numeric_mode_enabled_flag%TYPE,
     precis         fnd_flex_value_sets.number_precision%TYPE,
     minval         fnd_flex_value_sets.minimum_value%TYPE,
     maxval         fnd_flex_value_sets.maximum_value%TYPE,
     vsname         fnd_flex_value_sets.flex_value_set_name%TYPE);

------------
-- PRIVATE CONSTANTS

--
-- Character-set independent NEWLINE, TAB and WHITESPACE
--
NEWLINE     VARCHAR2(4);
TAB         VARCHAR2(4);
WHITESPACE  VARCHAR2(12);

DATE_STORAGE_FMT      CONSTANT VARCHAR2(21) := 'YYYY/MM/DD HH24:MI:SS';
TIME_STORAGE_FMT      CONSTANT VARCHAR2(10) := 'HH24:MI:SS';
TIME_DISPLAY_FMT      CONSTANT VARCHAR2(10) := 'HH24:MI:SS';
FLEX_DELIMITER_ESCAPE CONSTANT VARCHAR2(1) := '\';

-- Characters allowed in segment, value set profile and :block.field names
-- for interpreting $FLEX$, $PROFILE$, and :BLOCK.FIELD references
--
FLEX_BIND_CHARS       CONSTANT VARCHAR2(150) := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_$#.:*';


--
-- SQL String Parser: Constants
--
SSP_QUOTE      constant varchar2(1)   := '''';
SSP_QUOTE2     constant varchar2(2)   := SSP_QUOTE || SSP_QUOTE;
SSP_COLON      constant varchar2(1)   := ':';
SSP_BIND_CHARS constant varchar2(150) := FLEX_BIND_CHARS;

--
-- SQL String Parser: Piece Types
--
SSP_PIECE_TYPE_QUOTED    constant varchar2(1) := 'Q';
SSP_PIECE_TYPE_BIND      constant varchar2(1) := 'B';
SSP_PIECE_TYPE_SQL       constant varchar2(1) := 'S';

TYPE sql_piece_rec_type IS RECORD
  (piece_type varchar2(1),
   piece_text varchar2(32000),

   bind_value varchar2(32000));

TYPE sql_pieces_tab_type IS TABLE OF
  sql_piece_rec_type INDEX BY binary_integer;

security_begin CONSTANT VARCHAR2(180) :=
  'select M.ERROR_MESSAGE ' ||
  '  from FND_FLEX_VALUE_RULE_USAGES U, FND_FLEX_VALUE_RULES_VL M ' ||
  ' where U.FLEX_VALUE_RULE_ID = M.FLEX_VALUE_RULE_ID ';

security_mid CONSTANT VARCHAR2(180) :=
  'exists (select null ' ||
  '          from FND_FLEX_VALUE_RULE_LINES L ' ||
  '         where 1 = 1 ';

security_end CONSTANT VARCHAR2(180) :=
  'and L.FLEX_VALUE_RULE_ID = U.FLEX_VALUE_RULE_ID ' ||
  'and L.INCLUDE_EXCLUDE_INDICATOR = ';


-------------
-- GLOBAL VARIABLES
--
chr_newline VARCHAR2(8);
utl_file_dir VARCHAR2(4000);
l_session_id NUMBER;
n_sqlstrings  BINARY_INTEGER;
sqlstrings    SqlStringArray;

-- Canonical, Display, and Database decimal separators.
tmp_varchar2 VARCHAR2(1000);
m_nc         VARCHAR2(1);
m_nd         VARCHAR2(1);
m_nb         VARCHAR2(1);

--  Debugging information
TYPE debug_array_type IS TABLE OF VARCHAR2(1500)
  INDEX BY BINARY_INTEGER;

MAX_RETSTR_LEN      CONSTANT NUMBER := 1500;
g_debug_array       debug_array_type;
g_debug_array_size  NUMBER := 0;
g_debug_text        VARCHAR2(2000);

-- Error message information for value error message handling.
-- Value errors are generated by incorrect user input.
-- Only set first value error message in FND_MESSAGE
-- All other error messages override value errors.
value_error_set       BOOLEAN;
entering_new_message  BOOLEAN;

/* -------------------------------------------------------------------- */
/*               Private definitions for value validation               */
/* -------------------------------------------------------------------- */

FUNCTION string_clause(char_string IN VARCHAR2) RETURN VARCHAR2;

FUNCTION validate_seg(seg_in          IN      VARCHAR2,
                      displayed       IN      BOOLEAN,
                      kseg            IN      SegmentInfo,
                      vsinf           IN      ValueSetInfo,
                      vflags          IN      ValueValidationFlags,
                      fstruct         IN      FlexStructId,
                      v_date          IN      DATE,
                      v_ruls          IN      Vrules,
                      uappid          IN      NUMBER,
                      respid          IN      NUMBER,
                      nprev           IN      NUMBER,
                      prev_dispvals   IN      ValueArray,
                      prev_vals       IN      ValueArray,
                      prev_ids        IN      ValueIdArray,
                      prev_descs      IN      ValueDescArray,
                      prev_vsids      IN      NumberArray,
                      prev_segnames   IN      SegNameArray,
                      prev_vsnames    IN      VsNameArray,
                      x_flexvalue     OUT     nocopy FlexValue,
                      squals          OUT     nocopy Qualifiers) RETURN VARCHAR2;

FUNCTION coerce_format(user_value IN     VARCHAR2,
                       p_is_displayed IN BOOLEAN,
                       vs_format  IN     VARCHAR2,
                       vs_name    IN     VARCHAR2,
                       max_length IN     NUMBER,
                       letters_ok IN     VARCHAR2,
                       caps_only  IN     VARCHAR2,
                       zero_fill  IN     VARCHAR2,
                       precision  IN     VARCHAR2,
                       min_value  IN     VARCHAR2,
                       max_value  IN     VARCHAR2,
                       x_storage_value OUT nocopy VARCHAR2,
                       x_display_value OUT nocopy VARCHAR2) RETURN VARCHAR2;

FUNCTION find_value(p_str_info          IN  FlexStructId,
                    p_seg_info          IN  SegmentInfo,
                    p_vs_info           IN  ValueSetInfo,
                    p_vdate             IN  DATE,
                    p_char_val          IN  VARCHAR2,
                    p_is_value          IN  BOOLEAN,
                    p_orphans_ok        IN  BOOLEAN,
                    p_this_segname      IN  VARCHAR2,
                    p_n_prev            IN  NUMBER,
                    p_prev_vsids        IN  NumberArray,
                    p_prev_dispvals     IN  ValueArray,
                    p_prev_vals         IN  ValueArray,
                    p_prev_ids          IN  ValueIdArray,
                    p_prev_descs        IN  ValueDescArray,
                    p_prev_segnames     IN  SegNameArray,
                    p_prev_vsnames      IN  VsNameArray,
                    p_parent_val        IN  VARCHAR2,
                    x_this_val_out      OUT nocopy FlexValue) RETURN VARCHAR2;

FUNCTION table_validate(p_str_info            IN  FlexStructId,
                        p_seg_info            IN  SegmentInfo,
                        p_vs_info             IN  ValueSetInfo,
                        p_vdate               IN  DATE,
                        p_parent_value        IN  VARCHAR2,
                        p_charval             IN  VARCHAR2,
                        p_is_value            IN  BOOLEAN,
                        p_nprev               IN  NUMBER,
                        p_prev_dispvals       IN  ValueArray,
                        p_prev_vals           IN  ValueArray,
                        p_prev_ids            IN  ValueIdArray,
                        p_prev_descs          IN  ValueDescArray,
                        p_prev_segnames       IN  SegNameArray,
                        p_prev_vsnames        IN  VsNameArray,
                        x_check_valtab        OUT nocopy BOOLEAN,
                        x_found_value         OUT nocopy FlexValue)
  RETURN VARCHAR2;

 FUNCTION default_val(def_type        IN  VARCHAR2,
                      def_text        IN  VARCHAR2,
                      valset_fmt      IN  VARCHAR2,
                      valset_len      IN  NUMBER,
                      valset_precis   IN  NUMBER,
                      valset_lettersok IN VARCHAR2,
                      seg_name        IN  VARCHAR2,
                      nprev           IN  NUMBER,
                      prev_dispvals   IN  ValueArray,
                      prev_vals       IN  ValueArray,
                      prev_ids        IN  ValueIdArray,
                      prev_descs      IN  ValueDescArray,
                      prev_segnames   IN  SegNameArray,
                      prev_vsnames    IN  VsNameArray,
                      displayed_val   OUT nocopy VARCHAR2) RETURN VARCHAR2;

PROCEDURE parse_sql_string(p_sql_string  in varchar2,
                           px_sql_pieces in out nocopy sql_pieces_tab_type);

FUNCTION substitute_flex_binds3(p_string_in     IN VARCHAR2,
                                p_nprev         IN NUMBER,
                                p_prev_dispvals IN ValueArray,
                                p_prev_vals     IN ValueArray,
                                p_prev_ids      IN ValueIdArray,
                                p_prev_descs    IN ValueDescArray,
                                p_prev_segnames IN SegNameArray,
                                p_prev_vsnames  IN VsNameArray,
                                px_sql_pieces   in out nocopy sql_pieces_tab_type)
  RETURN VARCHAR2;

FUNCTION substitute_flex_binds5(p_string_in     IN VARCHAR2,
                                p_str_info      IN FlexStructId,
                                p_seg_info      IN SegmentInfo,
                                p_vdate         IN DATE,
                                p_parent_value  IN VARCHAR2,
                                p_nprev         IN NUMBER,
                                p_prev_dispvals IN ValueArray,
                                p_prev_vals     IN ValueArray,
                                p_prev_ids      IN ValueIdArray,
                                p_prev_descs    IN ValueDescArray,
                                p_prev_segnames IN SegNameArray,
                                p_prev_vsnames  IN VsNameArray,
                                px_sql_pieces   in out nocopy sql_pieces_tab_type)
  RETURN VARCHAR2;

FUNCTION convert_bind_token(bind_token    IN  VARCHAR2,
                            nprev         IN  NUMBER,
                            prev_dispvals IN  ValueArray,
                            prev_vals     IN  ValueArray,
                            prev_ids      IN  ValueIdArray,
                            prev_descs    IN  ValueDescArray,
                            prev_segnames IN  SegNameArray,
                            prev_vsnames  IN  VsNameArray,
                            bind_value    OUT nocopy VARCHAR2) RETURN VARCHAR2;

FUNCTION convert_bind_token2(p_bind_token    IN  VARCHAR2,
                             p_str_info      IN  FlexStructId,
                             p_seg_info      IN  SegmentInfo,
                             p_vdate         IN  DATE,
                             p_parent_value  IN  VARCHAR2,
                             p_nprev         IN  NUMBER,
                             p_prev_dispvals IN  ValueArray,
                             p_prev_vals     IN  ValueArray,
                             p_prev_ids      IN  ValueIdArray,
                             p_prev_descs    IN  ValueDescArray,
                             p_prev_segnames IN  SegNameArray,
                             p_prev_vsnames  IN  VsNameArray,
                             x_bind_value    OUT nocopy VARCHAR2) RETURN VARCHAR2;

FUNCTION get_value_set(value_set_id   IN  NUMBER,
                       segment_name   IN  VARCHAR2,
                       vs_info        OUT nocopy ValueSetInfo) RETURN BOOLEAN;

FUNCTION virtual_value_set(column_type  IN  VARCHAR2,
                           column_width IN  NUMBER,
                           segment_name IN  VARCHAR2,
                           vs_info      OUT nocopy ValueSetInfo) RETURN BOOLEAN;

FUNCTION get_qualifiers(ffstruct      IN  FlexStructId,
                        seg_colname   IN  VARCHAR2,
                        seg_quals     OUT nocopy Qualifiers) RETURN NUMBER;


FUNCTION qualifier_values(ffstruct       IN  FlexStructId,
                          valset_id      IN  NUMBER,
                          cvas           IN  VARCHAR2,
                          nqualifs       IN  NUMBER,
                          fqnames        IN  QualNameArray,
                          sqnames        IN  QualNameArray,
                          sqvals         IN OUT nocopy ValAttribArray) RETURN NUMBER;

FUNCTION derive_values(new_dvals      IN      DerivedVals,
                       new_quals      IN      Qualifiers,
                       drv_dvals      IN OUT  nocopy DerivedVals,
                       drv_quals      IN OUT  nocopy Qualifiers) RETURN BOOLEAN;

FUNCTION check_security(val          IN VARCHAR2,
                        valfmt       IN VARCHAR2,
                        parentval    IN VARCHAR2,
                        user_apid    IN NUMBER,
                        user_respid  IN NUMBER,
                        vsinfo       IN ValueSetInfo,
                        set_message  IN BOOLEAN) RETURN VARCHAR2;

FUNCTION check_vrules(vrs     IN Vrules,
                      sqs     IN Qualifiers,
                      sumflg  IN VARCHAR2) RETURN VARCHAR2;

FUNCTION check_displayed(segindex     IN  NUMBER,
                         disp_tokmap  IN  DisplayedSegs,
                         d_flag       OUT nocopy BOOLEAN) RETURN BOOLEAN;

PROCEDURE value_error_init;

PROCEDURE value_error_name(appl_sname      IN  VARCHAR2,
                           errmsg_name     IN  VARCHAR2);

PROCEDURE value_error_token(token_name   IN  VARCHAR2,
                            token_value  IN  VARCHAR2);

FUNCTION msg_val(valset_fmt  IN  VARCHAR2,
                 valset_len  IN  NUMBER,
                 valset_prec IN  NUMBER,
                 valset_lettersok IN VARCHAR2,
                 stored_val  IN  VARCHAR2) RETURN VARCHAR2;

FUNCTION stored_to_displayed(valset_fmt  IN  VARCHAR2,
                             valset_len  IN  NUMBER,
                             valset_prec IN  NUMBER,
                             valset_lettersok IN VARCHAR2,
                             stored_val  IN  VARCHAR2,
                             disp_val    OUT nocopy VARCHAR2) RETURN VARCHAR2;

FUNCTION isa_stored_date(teststr IN VARCHAR2,
                         flexfmt IN VARCHAR2,
                         outdate OUT nocopy DATE) RETURN BOOLEAN;

FUNCTION isa_displayed_date(teststr IN VARCHAR2,
                            flexfmt IN VARCHAR2,
                            outdate OUT nocopy DATE) RETURN BOOLEAN;

FUNCTION isa_date(teststr IN VARCHAR2,
                  datefmt IN VARCHAR2,
                  outdate OUT nocopy DATE) RETURN BOOLEAN;

FUNCTION displayed_date_format(flex_data_type IN VARCHAR2,
                               string_length  IN NUMBER) RETURN VARCHAR2;

-- ======================================================================
-- Caching.
-- ======================================================================
g_cache_return_code   VARCHAR2(30);
g_cache_key           VARCHAR2(2000);
g_cache_value         fnd_plsql_cache.generic_cache_value_type;
g_cache_values        fnd_plsql_cache.generic_cache_values_type;
g_cache_indexes       fnd_plsql_cache.custom_cache_indexes_type;
g_cache_numof_indexes NUMBER;
g_cache_numof_values  NUMBER;

-- ======================================================================
-- Value Set Cache : VST
--
-- PK: <flex_value_set_id>
--
-- ======================================================================
vst_cache_controller      fnd_plsql_cache.cache_1to1_controller_type;
vst_cache_storage         fnd_plsql_cache.generic_cache_values_type;

-- ======================================================================
-- Value Security Cache : VSC
--
-- PK: <application_id> || NEWLINE || <responsibility_id> || NEWLINE ||
--     <value_set_id>   || NEWLINE || <parent_value> || NEWLINE ||
--     <value>
--
-- ======================================================================
vsc_cache_controller      fnd_plsql_cache.cache_1to1_controller_type;
vsc_cache_storage         fnd_plsql_cache.generic_cache_values_type;

-- ======================================================================
-- Flex Value Cache : FVC
--
-- PK: <value_set_id> || NEWLINE || <parent_value> || NEWLINE || <value>
--
-- ======================================================================
fvc_cache_controller      fnd_plsql_cache.cache_1to1_controller_type;
fvc_cache_storage         fnd_plsql_cache.generic_cache_values_type;

-- ======================================================================
-- Flex Segment Qualifiers Cache : FSQ
--
-- PK: <application_id> || NEWLINE || <id_flex_code> || NEWLINE ||
--     <id_flex_num> || NEWLINE || <application_column_name>
--
-- ======================================================================
fsq_cache_controller      fnd_plsql_cache.cache_1tom_controller_type;
fsq_cache_storage         fnd_plsql_cache.generic_cache_values_type;

-- ======================================================================
-- Value Set Qualifiers Cache : VSQ
--
-- PK: <flex_value_set_id>
--
-- ======================================================================
vsq_cache_controller      fnd_plsql_cache.cache_1tom_controller_type;
vsq_cache_storage         fnd_plsql_cache.generic_cache_values_type;

-- ======================================================================
-- Validate Structue Segments Cache : str
-- ======================================================================
TYPE str_cache_storage_type IS TABLE OF segmentinfo
  INDEX BY BINARY_INTEGER;

str_cache_controller      fnd_plsql_cache.cache_1tom_controller_type;
str_cache_storage         str_cache_storage_type;

-- ======================================================================
-- Local Cache Functions
-- ======================================================================
FUNCTION check_vsc(p_application_id    IN NUMBER,
                   p_responsibility_id IN NUMBER,
                   p_value_set_id      IN NUMBER,
                   p_parent_value      IN VARCHAR2,
                   p_value             IN VARCHAR2,
                   px_error_code       IN OUT nocopy VARCHAR2)
  RETURN VARCHAR2
  IS
BEGIN
   --
   -- seperate p_parent_value and p_value to get rid of ambiguity.
   --
   g_cache_key := (p_parent_value || '.' ||
                   p_application_id || '.' ||
                   p_responsibility_id || '.' ||
                   p_value_set_id || '.' ||
                   p_value);

   fnd_plsql_cache.generic_1to1_get_value(vsc_cache_controller,
                                          vsc_cache_storage,
                                          g_cache_key,
                                          g_cache_value,
                                          g_cache_return_code);

   IF (g_cache_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
      px_error_code := g_cache_value.varchar2_1;
      IF (px_error_code = FF_VVALID) THEN
         RETURN(fnd_plsql_cache.CACHE_VALID);
       ELSE
         fnd_message.set_encoded(g_cache_value.varchar2_2);
         RETURN(fnd_plsql_cache.CACHE_INVALID);
      END IF;
    ELSE
      RETURN(g_cache_return_code);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      RETURN(fnd_plsql_cache.CACHE_NOTFOUND);
END check_vsc;

PROCEDURE update_vsc(p_application_id    IN NUMBER,
                     p_responsibility_id IN NUMBER,
                     p_value_set_id      IN NUMBER,
                     p_parent_value      IN VARCHAR2,
                     p_value             IN VARCHAR2,
                     p_error_code        IN VARCHAR2)
  IS
     l_enc_err_msg VARCHAR2(2000) := NULL;
BEGIN
   --
   -- seperate p_parent_value and p_value to get rid of ambiguity.
   --
   g_cache_key := (p_parent_value || '.' ||
                   p_application_id || '.' ||
                   p_responsibility_id || '.' ||
                   p_value_set_id || '.' ||
                   p_value);

   IF (p_error_code <> FF_VVALID) THEN
      l_enc_err_msg := fnd_message.get_encoded;
      fnd_message.set_encoded(l_enc_err_msg);
   END IF;

   fnd_plsql_cache.generic_cache_new_value
     (x_value      => g_cache_value,
      p_varchar2_1 => p_error_code,
      p_varchar2_2 => l_enc_err_msg);

   fnd_plsql_cache.generic_1to1_put_value(vsc_cache_controller,
                                          vsc_cache_storage,
                                          g_cache_key,
                                          g_cache_value);
EXCEPTION
   WHEN OTHERS THEN
      RETURN;
END update_vsc;

-- ----------------------------------------------------------------------
FUNCTION check_fvc(p_value_set_id      IN NUMBER,
                   p_parent_value      IN VARCHAR2,
                   p_value             IN VARCHAR2,
                   px_flexvalue        IN OUT nocopy flexvalue)

  RETURN VARCHAR2
  IS
BEGIN
   --
   -- seperate p_parent_value and p_value to get rid of ambiguity.
   --
   g_cache_key := (p_parent_value || '.' ||
                   p_value_set_id || '.' ||
                   p_value);

   fnd_plsql_cache.generic_1to1_get_value(fvc_cache_controller,
                                          fvc_cache_storage,
                                          g_cache_key,
                                          g_cache_value,
                                          g_cache_return_code);

   IF (g_cache_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
      px_flexvalue.displayed_value     := g_cache_value.varchar2_1;
      px_flexvalue.stored_value        := g_cache_value.varchar2_2;
      px_flexvalue.hidden_id           := g_cache_value.varchar2_3;
      px_flexvalue.description         := g_cache_value.varchar2_4;
      px_flexvalue.format              := g_cache_value.varchar2_5;
      px_flexvalue.compiled_attributes := g_cache_value.varchar2_6;
      px_flexvalue.summary_flag        := g_cache_value.varchar2_7;
      px_flexvalue.enabled_flag        := g_cache_value.varchar2_8;
      px_flexvalue.start_valid         := g_cache_value.date_1;
      px_flexvalue.end_valid           := g_cache_value.date_2;
   END IF;
   RETURN(g_cache_return_code);
EXCEPTION
   WHEN OTHERS THEN
      RETURN(fnd_plsql_cache.CACHE_NOTFOUND);
END check_fvc;

PROCEDURE update_fvc(p_value_set_id    IN NUMBER,
                     p_parent_value    IN VARCHAR2,
                     p_value           IN VARCHAR2,
                     p_flexvalue       IN flexvalue)
  IS
BEGIN
   --
   -- seperate p_parent_value and p_value to get rid of ambiguity.
   --
   g_cache_key := (p_parent_value || '.' ||
                   p_value_set_id || '.' ||
                   p_value);

   fnd_plsql_cache.generic_cache_new_value
     (x_value       => g_cache_value,
      p_varchar2_1  => p_flexvalue.displayed_value,
      p_varchar2_2  => p_flexvalue.stored_value,
      p_varchar2_3  => p_flexvalue.hidden_id,
      p_varchar2_4  => p_flexvalue.description,
      p_varchar2_5  => p_flexvalue.format,
      p_varchar2_6  => p_flexvalue.compiled_attributes,
      p_varchar2_7  => p_flexvalue.summary_flag,
      p_varchar2_8  => p_flexvalue.enabled_flag,
      p_date_1      => p_flexvalue.start_valid,
      p_date_2      => p_flexvalue.end_valid);

   fnd_plsql_cache.generic_1to1_put_value(fvc_cache_controller,
                                          fvc_cache_storage,
                                          g_cache_key,
                                          g_cache_value);
EXCEPTION
   WHEN OTHERS THEN
      RETURN;
END update_fvc;

/* ----------------------------------------------------------------------- */
/*      Checks each segment input to see if it is secured against the      */
/*      current user.  Returns index of first secured segment or 0 if      */
/*      no segments are secured or < 0 if error.                           */
/*      Segment index does not take displayed flag into account.           */
/*      Does not look up the values.  Stops at first secured value.        */
/*      Sets error message if security violated or on error.               */
/*      Uses only the non-coerced values in the segments field.            */
/*      Do not worry about orphans for dependent values.                   */
/* ----------------------------------------------------------------------- */
FUNCTION vals_secured(fstruct IN  FlexStructId,
                      nsegs   IN  NUMBER,
                      segs    IN  StringArray,
                      displ   IN  DisplayedSegs,
                      uappid  IN  NUMBER,
                      respid  IN  NUMBER)
  RETURN NUMBER
  IS
     segcounter          BINARY_INTEGER;
     dispsegcounter      BINARY_INTEGER;
     seg_displayed       BOOLEAN;
     thisval             VARCHAR2(1000);
     parentval           VARCHAR2(60);
     parentindex         BINARY_INTEGER;
     prior_vals          ValueArray;
     prior_vsids         NumberArray;
     segname             VARCHAR2(30);
     segvsid             NUMBER;
     segsecure           VARCHAR2(1);
     vsinfo              ValueSetInfo;
     l_return_code       NUMBER;

     CURSOR KeySegC(keystruct in FlexStructId) IS
        SELECT segment_name, flex_value_set_id, security_enabled_flag
          FROM fnd_id_flex_segments
          WHERE application_id = keystruct.application_id
          AND id_flex_code = keystruct.id_flex_code
          AND id_flex_num = keystruct.id_flex_num
          AND enabled_flag = 'Y'
          ORDER BY segment_num;

     CURSOR DescSegC(descstruct in FlexStructId) IS
        SELECT end_user_column_name, flex_value_set_id, security_enabled_flag
          FROM fnd_descr_flex_column_usages
          WHERE application_id = descstruct.application_id
          AND descriptive_flexfield_name = descstruct.desc_flex_name
          AND descriptive_flex_context_code = descstruct.desc_flex_context
          AND enabled_flag = 'Y'
          ORDER BY column_seq_num;

BEGIN
   IF (fnd_flex_server1.g_debug_level > 0) THEN
      add_debug('BEGIN SV1.vals_secured()');
   END IF;
  segcounter := 0;
  dispsegcounter := 0;
  value_error_init;

  if(fstruct.isa_key_flexfield) then
    open KeySegC(fstruct);
  else
    open DescSegC(fstruct);
  end if;

--  Begin main loop

  loop

    if(fstruct.isa_key_flexfield) then
      fetch KeySegC into segname, segvsid, segsecure;
      exit when (KeySegC%NOTFOUND or (KeySegC%NOTFOUND is null));
    else
      fetch DescSegC into segname, segvsid, segsecure;
      exit when (DescSegC%NOTFOUND or (DescSegC%NOTFOUND is null));
    end if;

    segcounter := segcounter + 1;

--  Exit with error if exception occurred during check.
--
    if(check_displayed(segcounter, displ, seg_displayed) = FALSE) THEN
       l_return_code := -6;
       GOTO goto_return;
    end if;

--  Just ignore non-displayed segments.
--
    if(seg_displayed) then
      dispsegcounter := dispsegcounter + 1;
    else
       IF (fnd_flex_server1.g_debug_level > 0) THEN
          add_debug('Segment ' || to_char(segcounter) || ' not displayed ');
       END IF;
      thisval := NULL;
      goto next_value;
    end if;

--  Treat remaining segments as NULL and quit if too few segments entered.
--
    if(dispsegcounter > nsegs) then
       IF (fnd_flex_server1.g_debug_level > 0) THEN
          add_debug('No more values-exiting. ');
       END IF;
       l_return_code := 0;
       GOTO goto_return;
    end if;

--  Initialize value.  Strip spaces.
--
    thisval := RTRIM(LTRIM(segs(dispsegcounter)));

    IF (fnd_flex_server1.g_debug_level > 0) THEN
       add_debug('(' || thisval || ') ');
    END IF;

--  If null, its not secured.
--
    if(thisval is null) then
      goto next_value;
    end if;

--  Get value set info.  If no value set, then it's not secured.
--
    if(segvsid is null) then
      goto next_value;
    else
       if(get_value_set(segvsid, segname, vsinfo) <> TRUE) THEN
          l_return_code := -7;
          GOTO goto_return;
       end if;
    end if;

    parentval := NULL;

-- If dependent value set find parent value.
-- Orphans do not generate error, but lack of a parent value set does.
--
    if(vsinfo.valtype = 'D') then
      parentindex := 0;
      for i in reverse 1..(segcounter - 1) loop
        if((prior_vsids(i) is not null) and
           (vsinfo.parent_vsid = prior_vsids(i))) then
          parentindex := i;
          parentval := prior_vals(i);
          exit;
        end if;
      end loop;
      if(parentindex = 0) then
        FND_MESSAGE.set_name('FND', 'FLEX-NO PARENT SEGMENT');
        FND_MESSAGE.set_token('CHILD', to_char(segcounter));
          l_return_code := -3;
          GOTO goto_return;
      end if;
    end if;

-- Check security rules.  Stop if any value is secured.
--
    if((vsinfo.valtype in ('I', 'D', 'F')) and
       (vsinfo.valsecure in ('Y', 'H')) and (segsecure = 'Y')) then
      if(check_security(thisval, vsinfo.vsformat, parentval,
                        uappid, respid, vsinfo, TRUE) <> FF_VVALID) then
         l_return_code := segcounter;
         GOTO goto_return;
      end if;
    end if;

    <<next_value>>

--  Record previous value set id's and values for parent value search
--  Add to table column, value_set_id, segment type, and seg_num arrays
--
    prior_vsids(segcounter) := segvsid;
    prior_vals(segcounter) := thisval;

  end loop;

-- Close cursor.
--
  if(fstruct.isa_key_flexfield) then
    close KeySegC;
  else
    close DescSegC;
  end if;

--  Note error if no enabled segments for this flexfield.
--
  if(fstruct.isa_key_flexfield and (segcounter <= 0)) then
    FND_MESSAGE.set_name('FND', 'FLEX-CANT FIND SEGMENTS');
    FND_MESSAGE.set_token('ROUTINE', 'Validate Values');
    FND_MESSAGE.set_token('APPID', to_char(fstruct.application_id));
    FND_MESSAGE.set_token('CODE', fstruct.id_flex_code);
    FND_MESSAGE.set_token('NUM', to_char(fstruct.id_flex_num));
    l_return_code := -1;
    GOTO goto_return;
  end if;

  l_return_code := 0;

  <<goto_return>>
    IF (fnd_flex_server1.g_debug_level > 0) THEN
       add_debug('END SV1.vals_secured()');
    END IF;
    return(l_return_code);

EXCEPTION
  WHEN NO_DATA_FOUND then
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        add_debug('EXCEPTION no_data_found SV1.vals_secured()');
     END IF;
     if(fstruct.isa_key_flexfield) then
        FND_MESSAGE.set_name('FND', 'FLEX-CANT FIND SEGMENTS');
        FND_MESSAGE.set_token('ROUTINE', 'Validate Values');
        FND_MESSAGE.set_token('APPID', to_char(fstruct.application_id));
        FND_MESSAGE.set_token('CODE', fstruct.id_flex_code);
        FND_MESSAGE.set_token('NUM', to_char(fstruct.id_flex_num));
        return(-1);
     end if;
     return(0);
  WHEN OTHERS then
    FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
    FND_MESSAGE.set_token('MSG', 'vals_secured() exception:  ' || SQLERRM);
    IF (fnd_flex_server1.g_debug_level > 0) THEN
       add_debug('EXCEPTION others SV1.vals_secured()');
    END IF;
    return(-2);
END vals_secured;

/* ----------------------------------------------------------------------- */
/*      Performes independent, dependent, and table value validation.      */
/*      Returns value status number in priority order:                     */
/*              VV_VALID        If all values valid.  No errors at all.    */
/*              VV_SECURED      Only error is value security violation.    */
/*              VV_VALUES       A non-security value error was found.      */
/*              VV_UNSUPPORTED  Validation type not suppoted on server.    */
/*              VV_ERROR        Error worse than incorrect value entered.  */
/*                                                                         */
/*      Value validation affected by vflags.  See package spec. for        */
/*      description.  If no flags explicitly call for stopping validation  */
/*      this function tries to validate all segments even if there is an   */
/*      error and returns a message and the number of the first segment    */
/*      which caused the error.  If there is a value error in one segment  */
/*      and a subsequent segment has a more serious error, then the error  */
/*      segment number and message is that of the more serious error. See  */
/*      value_error_name() and token() for description.  This function     */
/*      carefully coordinates the setting of the error segment number with */
/*      the behavior of the value_error functions to ensure the message    */
/*      corresponds to the segment indicated.  The error segment number    */
/*      is the number of enabled segments with segment_num's <= the        */
/*      segment which caused the error.                                    */
/*                                                                         */
/*      If the validation flags indicate to not stop at value errors,      */
/*      then invalid segments will return with the displayed value set     */
/*      to the value the user typed in and the id and description null.    */
/*                                                                         */
/*      Returns the number of segment values and ids output.               */
/*                                                                         */
/*      Outputs several arrays of cached data on each segment:             */
/*        1) Column where to put segments in cross-validation table.       */
/*        2) Segment data types:  'C' = Char, 'N' = Number,                */
/*              'D' = Date "DD-MON-RR" or "DD-MON-YYYY" formats            */
/*              't' or 'I' = Time "HH24:MI" or "HH24:MI:SS" formats        */
/*              'T' = Date-Time in 'D' + space + 't' formats (4 in all)    */
/*        3) Numeric representation for numbers and date type data.        */
/*        4-6) Array of values, value_id's and value_meanings              */
/*        7) Compiled value attribute strings for each value.              */
/*        8) Individual segment value status codes in a char string        */
/*           where one character represents the status for each value.     */
/*                                                                         */
/*   Notes:     Checks format validation on ALL validation types.          */
/*              If format = "Numbers only" disallows non-numbers           */
/*                (present user exit allows any combination of             */
/*                 0-9, +, -, and . even if it is not a number             */
/* ----------------------------------------------------------------------- */

FUNCTION validate_struct(fstruct      IN  FlexStructId,
                         tbl_apid     IN  NUMBER,
                         tbl_id       IN  NUMBER,
                         nsegs_in     IN  NUMBER,
                         segs         IN  StringArray,
                         dispsegs     IN  DisplayedSegs,
                         vflags       IN  ValueValidationFlags,
                         v_date       IN  DATE,
                         v_ruls       IN  Vrules,
                         uappid       IN  NUMBER,
                         respid       IN  NUMBER,
                         nsegs_out    OUT nocopy NUMBER,
                         segfmts      OUT nocopy SegFormats,
                         segstats     OUT nocopy VARCHAR2,
                         tabcols      OUT nocopy TabColArray,
                         tabcoltypes  OUT nocopy CharArray,
                         v_dispvals   OUT nocopy ValueArray,
                         v_vals       OUT nocopy ValueArray,
                         v_ids        OUT nocopy ValueIdArray,
                         v_descs      OUT nocopy ValueDescArray,
                         desc_lens    OUT nocopy NumberArray,
                         dvals        OUT nocopy DerivedVals,
                         dquals       OUT nocopy Qualifiers,
                         errsegn      OUT nocopy NUMBER) RETURN NUMBER IS

  segcount            NUMBER;
  dispsegcount        NUMBER;
  errseg_num          NUMBER;
  return_code         NUMBER;
  isvalu              BOOLEAN;
  seg_displayed       BOOLEAN;
  secured_flag        BOOLEAN;
  val_err_flag        BOOLEAN;
  this_seg            VARCHAR2(1000);
  segerrs             VARCHAR2(201);
  v_status            VARCHAR2(1);
  seg_quals           Qualifiers;
  this_dval           DerivedVals;
  drvd_quals          Qualifiers;
  drvals              DerivedVals;
  l_flexvalue         FlexValue;
  prior_dispvals      ValueArray;
  prior_vals          ValueArray;
  prior_ids           ValueIdArray;
  prior_descs         ValueDescArray;
  prior_vsids         NumberArray;
  prior_segnames      SegNameArray;
  prior_vsnames       VsNameArray;
  catdesc_lens        NumberArray;
  seginfo             SegmentInfo;
  segsetinfo          SegmentInfo;
  l_str_cache_segs    str_cache_storage_type;
  i                   NUMBER;
  vsinfo              ValueSetInfo;

  CURSOR KeyC(keystruct in FlexStructId, t_apid in NUMBER, t_id in NUMBER) IS
      SELECT  g.segment_name, g.application_column_name, c.column_type,
              c.width, g.required_flag, g.security_enabled_flag,
              g.concatenation_description_len,
              g.default_type, g.default_value, g.flex_value_set_id,
              g.runtime_property_function,
              g.additional_where_clause
       FROM fnd_id_flex_segments g, fnd_columns c
      WHERE g.application_id = keystruct.application_id
        AND g.id_flex_code = keystruct.id_flex_code
        AND g.id_flex_num = keystruct.id_flex_num
        AND g.enabled_flag = 'Y'
        AND c.application_id = t_apid
        AND c.table_id = t_id
        AND c.column_name = g.application_column_name
      ORDER BY g.segment_num;

  CURSOR DescC(descstruct in FlexStructId, t_apid in NUMBER, t_id in NUMBER)
    IS SELECT g.end_user_column_name, g.application_column_name,
              c.column_type, c.width, g.required_flag,
              g.security_enabled_flag, g.concatenation_description_len,
              g.default_type, g.default_value, g.flex_value_set_id,
              g.runtime_property_function,
              NULL
       FROM fnd_descr_flex_column_usages g, fnd_columns c
      WHERE g.application_id = descstruct.application_id
        AND g.descriptive_flexfield_name = descstruct.desc_flex_name
        AND g.descriptive_flex_context_code = descstruct.desc_flex_context
        AND g.enabled_flag = 'Y'
        AND c.application_id = t_apid
        AND c.table_id = t_id
        AND c.column_name = g.application_column_name
      ORDER BY g.column_seq_num;

  CURSOR DescCReqSet(descstruct in FlexStructId, t_appid in NUMBER, t_id in Number, t_srs_appl_id in NUMBER, t_srs_id in NUMBER, t_srs_pgm_id in NUMBER)
    IS SELECT g.end_user_column_name, g.application_column_name,
              c.column_type, c.width, g.required_flag,
              g.security_enabled_flag, g.concatenation_description_len,
              s.default_type, s.default_value, g.flex_value_set_id,
              g.runtime_property_function,
              NULL
       FROM fnd_descr_flex_column_usages g, fnd_columns c,
            fnd_request_set_program_args s
      WHERE g.application_id = descstruct.application_id
        AND g.descriptive_flexfield_name = descstruct.desc_flex_name
        AND g.descriptive_flex_context_code = descstruct.desc_flex_context
        AND g.enabled_flag = 'Y'
        AND c.application_id = t_appid
        AND c.table_id = t_id
        AND c.column_name = g.application_column_name
        AND s.application_id = t_srs_appl_id
        AND s.request_set_id = t_srs_id
        AND s.request_set_program_id = t_srs_pgm_id
        AND s.descriptive_flex_appl_id = descstruct.application_id
        AND s.descriptive_flexfield_name = descstruct.desc_flex_name
        AND s.application_column_name = g.application_column_name
      ORDER BY g.column_seq_num;

BEGIN
   IF (fnd_flex_server1.g_debug_level > 0) THEN
      FND_FLEX_SERVER1.add_debug('BEGIN SV1.validate_struct() ');
   END IF;

  value_error_init;
  secured_flag := FALSE;
  val_err_flag := FALSE;

--  Initialize all returned values and all derived values with defaults
--
  segcount := 0;
  dispsegcount := 0;
  nsegs_out := 0;
  segfmts.nsegs := 0;
  return_code := VV_ERROR;

  drvd_quals.nquals := 0;
  dquals.nquals := 0;

  drvals.start_valid := NULL;
  drvals.end_valid := NULL;
  drvals.enabled_flag := 'Y';
  drvals.summary_flag := 'N';
  dvals := drvals;

  IF (fstruct.isa_key_flexfield) THEN
     g_cache_key := ('KFF' || '.' ||
                     fstruct.application_id || '.' ||
                     fstruct.id_flex_code || '.' ||
                     fstruct.id_flex_num || '.' ||
                     tbl_apid || '.' ||
                     tbl_id);
   ELSE
     g_cache_key := ('DFF' || '.' ||
                     fstruct.application_id || '.' ||
                     fstruct.desc_flex_name || '.' ||
                     fstruct.desc_flex_context || '.' ||
                     tbl_apid || '.' ||
                     tbl_id);
  END IF;

  fnd_plsql_cache.custom_1tom_get_get_indexes(str_cache_controller,
                                              g_cache_key,
                                              g_cache_numof_indexes,
                                              g_cache_indexes,
                                              g_cache_return_code);

  IF ((g_cache_return_code = fnd_plsql_cache.CACHE_FOUND) AND
      (vflags.invoking_mode <> 'Q')) THEN
     --
     -- Copy cached values to local array.
     --
     FOR ii IN 1..g_cache_numof_indexes LOOP
        l_str_cache_segs(ii):= str_cache_storage(g_cache_indexes(ii));
     END LOOP;
   ELSE
     if(fstruct.isa_key_flexfield) THEN
        open KeyC(fstruct, tbl_apid, tbl_id);
      else
        open DescC(fstruct, tbl_apid, tbl_id);
     end if;

     i := 0;
     LOOP
        IF (fstruct.isa_key_flexfield) then
           FETCH KeyC INTO seginfo;
           EXIT WHEN (KeyC%NOTFOUND OR (KeyC%NOTFOUND is null));
         ELSE
           FETCH DescC INTO seginfo;
           EXIT WHEN (DescC%NOTFOUND OR (DescC%NOTFOUND is null));
        end if;
        i := i + 1;

        l_str_cache_segs(i) := seginfo;
     END LOOP;
     g_cache_numof_indexes := i;

     if(fstruct.isa_key_flexfield) THEN
        close KeyC;
      else
        close DescC;
     end if;

     IF (vflags.invoking_mode = 'Q' AND
             vflags.srs_req_set_id IS NOT NULL) THEN
        open DescCReqSet(fstruct, tbl_apid, tbl_id, vflags.srs_req_set_appl_id,
                         vflags.srs_req_set_id, vflags.srs_req_set_pgm_id);

     i := 0;
     LOOP

        FETCH DescCReqSet INTO segsetinfo;
        EXIT WHEN (DescCReqSet%NOTFOUND OR (DescCReqSet%NOTFOUND is null));

         LOOP
            i := i + 1;
            EXIT WHEN i > g_cache_numof_indexes;
            IF (l_str_cache_segs(i).colname = segsetinfo.colname) THEN
               l_str_cache_segs(i) := segsetinfo;
            END IF;
            EXIT WHEN (l_str_cache_segs(i).colname = segsetinfo.colname);

         END LOOP;

     END LOOP;
     END IF;

     fnd_plsql_cache.custom_1tom_get_put_indexes(str_cache_controller,
                                                 g_cache_key,
                                                 g_cache_numof_indexes,
                                                 g_cache_indexes,
                                                 g_cache_return_code);
     IF (g_cache_return_code = fnd_plsql_cache.CACHE_PUT_IS_SUCCESSFUL) THEN
        FOR ii IN 1..g_cache_numof_indexes LOOP
           str_cache_storage(g_cache_indexes(ii)) := l_str_cache_segs(ii);
        END LOOP;
     END IF;
  END IF;

  IF (fstruct.isa_key_flexfield) then
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        add_debug('key segments: ');
     END IF;
   else
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        add_debug('desc segments: ');
     END IF;
  end if;

  --
  --  Begin main loop
  --
  segcount := 0;
  WHILE (segcount < g_cache_numof_indexes) LOOP
     segcount := segcount + 1;
     seginfo := l_str_cache_segs(segcount);

     --
     --  Get value set information or make a virtual value set if vsid is null
     --
     if(seginfo.vsid is not null) then
        if(get_value_set(seginfo.vsid, seginfo.segname, vsinfo) <> TRUE) then
           errseg_num := segcount;
           segcount := segcount - 1;
           return_code := VV_ERROR;
           goto return_values;
        end if;
      else
        if(virtual_value_set(seginfo.coltype, seginfo.collen, seginfo.segname,
                             vsinfo) <> TRUE) then
           errseg_num := segcount;
           segcount := segcount - 1;
           return_code := VV_ERROR;
           goto return_values;
        end if;
     end if;

     --
     --  Check if segment displayed.  By definition all segments are
     --  displayed if inputs are ID's.
     --
     if(vflags.values_not_ids) then
        if(check_displayed(segcount, dispsegs, seg_displayed) = FALSE) then
           errseg_num := segcount;
           segcount := segcount - 1;
           return_code := VV_ERROR;
           goto return_values;
        end if;
      else
        seg_displayed := TRUE;
     end if;

     --
     --  If segment not displayed treat it as null.  If it is displayed then
     --  increment displayed count.   If displayed and exact number of segments
     --  not required, then treat missing segs as null.
     --  If nsegs_in = 0, could be that nsegs_in = 1 and that seg is null.
     --
     -- bug 1459072 values for all segs should be validated whether they are
     -- displayed or not. Also code was not validating right segment if a
     -- non-displayed segment was processed before a displayed segment.

     --
     -- Above comment is not quite true (bug 1459072), I need to do
     -- more research on that problem. Now I am backing up the changes.
     -- and adding comments to following code. golgun. 01/15/01
     --

     --
     -- If values are passed, DISPLAY mapping was used to parse concat string.
     -- So segs array has only displayed segment values.
     -- If Ids are passed, even if there is restriction in DISPLAY mapping,
     -- all segment values are assumed to be displayed, and segs array
     -- has all the segment values.
    --
     if(seg_displayed) then
        dispsegcount := dispsegcount + 1;
        if(dispsegcount > nsegs_in) THEN
           --
           -- Out of boundary.
           --
           if(vflags.exact_nsegs_required and
              not ((nsegs_in = 0) and (dispsegcount = 1))) then
              --
              -- Not enough segment values are passed and this is not OK.
              --
              FND_MESSAGE.set_name('FND', 'FLEX-MISSING CONCAT VALUES');
              errseg_num := segcount;
              segcount := segcount - 1;
              return_code := VV_ERROR;
              goto return_values;
            else
              --
              -- Not enough segment values are passed and this is OK.
              --
              this_seg := NULL;
           end if;
         else
           --
           -- seg is displayed (either (displayed 'V'), or 'I'),
           -- and the value is in the array.
           --
           this_seg := segs(dispsegcount);
        end if;
      else
        --
        -- seg is not displayed, only possible in 'V' case.
        --
        this_seg := NULL;
     end if;

     v_status := validate_seg(this_seg,
                              seg_displayed,
                              seginfo,
                              vsinfo,
                              vflags,
                              fstruct,
                              v_date,
                              v_ruls,
                              uappid,
                              respid,
                              segcount - 1,
                              prior_dispvals,
                              prior_vals,
                              prior_ids,
                              prior_descs,
                              prior_vsids,
                              prior_segnames,
                              prior_vsnames,
                              l_flexvalue,
                              seg_quals);

     --
     --  Record value and structure information
     --  Add value validation status to segment error string.
     --
     tabcols(segcount) := seginfo.colname;
     tabcoltypes(segcount) := seginfo.coltype;
     prior_vsids(segcount) := seginfo.vsid;
     prior_dispvals(segcount) := l_flexvalue.displayed_value;
     prior_vals(segcount) := l_flexvalue.stored_value;
     prior_ids(segcount) := l_flexvalue.hidden_id;
     prior_descs(segcount) := l_flexvalue.description;
     prior_segnames(segcount) := seginfo.segname;
     prior_vsnames(segcount) := vsinfo.vsname;
     catdesc_lens(segcount) := seginfo.catdesclen;
     segfmts.vs_format(segcount) := vsinfo.vsformat;
     segfmts.vs_maxsize(segcount) := vsinfo.maxsize;
     segerrs := segerrs || v_status;

     --
     --  If values ok, then derive qualifiers and enabled dates.
     --  If serious error validating values, or if value validation is unsupported
     --  on the server, then set errseg_num to current segment since this error has
     --  overwritten any prior value errors, and then return.
     --  If value is secured or other value error note the error in the local flag
     --  and optionally stop depending on the vflags.  In these cases the value
     --  error message will only have been put into FND_MESSAGE if it is the
     --  first error, so set errseg_num only if it's null.
     --
     IF (v_status = FF_VVALID) then
        this_dval.start_valid := l_flexvalue.start_valid;
        this_dval.end_valid := l_flexvalue.end_valid;
        this_dval.enabled_flag := l_flexvalue.enabled_flag;
        this_dval.summary_flag := l_flexvalue.summary_flag;
        if(derive_values(this_dval, seg_quals, drvals,drvd_quals) = FALSE) then
           return_code := VV_ERROR;
           goto return_values;
        end if;
      elsif(v_status = FF_VERROR) then
        errseg_num := segcount;
        return_code := VV_ERROR;
        goto return_values;
      elsif(v_status = FF_VUNKNOWN) then
        errseg_num := segcount;
        return_code := VV_UNSUPPORTED;
        goto return_values;
      elsif(v_status = FF_VSECURED) then
        secured_flag := TRUE;
        if((errseg_num is null) and vflags.message_on_security) then
           errseg_num := segcount;
        end if;
        if(vflags.stop_on_security) then
           return_code := VV_SECURED;
           goto return_values;
        end if;
      else
        val_err_flag := TRUE;
        if(errseg_num is null) then
           if((v_status <> FF_VREQUIRED) or (vflags.message_on_null)) then
              errseg_num := segcount;
           end if;
        end if;
        if(vflags.stop_on_value_error) then
           return_code := VV_VALUES;
           goto return_values;
        end if;
     end if;

  end loop;

  if(fstruct.isa_key_flexfield) then
     if(segcount <= 0) then
        FND_MESSAGE.set_name('FND', 'FLEX-CANT FIND SEGMENTS');
        FND_MESSAGE.set_token('ROUTINE', 'Validate Values');
        FND_MESSAGE.set_token('APPID', to_char(fstruct.application_id));
        FND_MESSAGE.set_token('CODE', fstruct.id_flex_code);
        FND_MESSAGE.set_token('NUM', to_char(fstruct.id_flex_num));
        return_code := VV_ERROR;
        goto return_values;
     end if;
   ELSE
     NULL;
  end if;

  --
  --  If exact number of segments required, then check for too many.
  --  Otherwise just stop.
  --  If nsegs_in = 0, could be that nsegs_in = 1 and that seg is null.
  --  Do not complain if dispsegcount is 1 in that case.
  --
  if(vflags.exact_nsegs_required and (dispsegcount <> nsegs_in) and
     not ((nsegs_in = 0) and (dispsegcount = 1))) then
     FND_MESSAGE.set_name('FND', 'FLEX-TOO MANY SEGS');
     FND_MESSAGE.set_token('NSEGS', to_char(dispsegcount));
     return_code := VV_ERROR;
     goto return_values;
  end if;

  IF (fnd_flex_server1.g_debug_level > 0) THEN
     add_debug(to_char(segcount) || ' segments found.');
  END IF;

  --
  --  Return most serious error or none if there are none.
  --
  if(val_err_flag) then
     return_code := VV_VALUES;
   elsif(secured_flag) then
     return_code := VV_SECURED;
   else
     return_code := VV_VALID;
  end if;

  <<return_values>>
  --
  -- Return values, derived values, qualifiers, segment format.
  --
  nsegs_out := segcount;
  segfmts.nsegs := segcount;
  segstats := segerrs;
  v_dispvals := prior_dispvals;
  v_vals := prior_vals;
  v_ids := prior_ids;
  v_descs := prior_descs;
  desc_lens := catdesc_lens;
  dvals := drvals;
  dquals := drvd_quals;
  errsegn := errseg_num;

  IF (fnd_flex_server1.g_debug_level > 0) THEN
     FND_FLEX_SERVER1.add_debug('END SV1.validate_struct()');
  END IF;

  return(return_code);

EXCEPTION
   WHEN NO_DATA_FOUND then
      IF (fnd_flex_server1.g_debug_level > 0) THEN
         FND_FLEX_SERVER1.add_debug('EXCEPTION no_data_found SV1.validate_struct() ');
      END IF;
      if(fstruct.isa_key_flexfield) then
         FND_MESSAGE.set_name('FND', 'FLEX-CANT FIND SEGMENTS');
         FND_MESSAGE.set_token('ROUTINE', 'Validate Values');
         FND_MESSAGE.set_token('APPID', to_char(fstruct.application_id));
         FND_MESSAGE.set_token('CODE', fstruct.id_flex_code);
         FND_MESSAGE.set_token('NUM', to_char(fstruct.id_flex_num));
         return(VV_ERROR);
      end if;
      return(VV_VALID);
   WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG', 'validate_struct() exception:  '||SQLERRM);
      IF (fnd_flex_server1.g_debug_level > 0) THEN
         FND_FLEX_SERVER1.add_debug('EXCEPTION others SV1.validate_struct() ');
      END IF;

      return(VV_ERROR);

END validate_struct;

/* ----------------------------------------------------------------------- */
/*      Validates value returing status code indicating if the segment is  */
/*      valid or if what if any errors are present.  Sets error message    */
/*      using error prioritization functions if any errors in user-entered */
/*      values.  If value invalid because of a value error rather than     */
/*      an error in the data structures etc, then this program tries to    */
/*      return as much of the value as possible.  If value cannot be       */
/*      found, this program returns what the user typed in for the value   */
/*      and null ids and descrs.  If the value is found, the whole value   */
/*      is returned even if there is some other validation problem such    */
/*      as a security violation or value is expired or disabled.           */
/*      Outputs actual value, format of segment, and segment qualifiers.   */
/* ----------------------------------------------------------------------- */

FUNCTION validate_seg(seg_in          IN  VARCHAR2,
                    displayed       IN  BOOLEAN,
                    kseg            IN  SegmentInfo,
                    vsinf           IN  ValueSetInfo,
                    vflags          IN  ValueValidationFlags,
                    fstruct         IN  FlexStructId,
                    v_date          IN  DATE,
                    v_ruls          IN  Vrules,
                    uappid          IN  NUMBER,
                    respid          IN  NUMBER,
                    nprev           IN  NUMBER,
                    prev_dispvals   IN  ValueArray,
                    prev_vals       IN  ValueArray,
                    prev_ids        IN  ValueIdArray,
                    prev_descs      IN  ValueDescArray,
                    prev_vsids      IN  NumberArray,
                    prev_segnames   IN  SegNameArray,
                    prev_vsnames    IN  VsNameArray,
                    x_flexvalue     OUT nocopy FlexValue,
                    squals          OUT nocopy Qualifiers)
RETURN VARCHAR2
IS
   isvalu          BOOLEAN;
   defaulted       BOOLEAN;
   orphansok       BOOLEAN;
   vcode           VARCHAR2(1);
   thisseg         VARCHAR2(1000);
   parentval       VARCHAR2(150);
   segquals        Qualifiers;
   l_flexvalue     FlexValue;
   l_fvc_code      VARCHAR2(100);
   l_parent_index  BINARY_INTEGER;
   l_storage_value VARCHAR2(2000);
   l_display_value VARCHAR2(2000);
   l_zero_fill     VARCHAR2(1);
BEGIN
 IF (fnd_flex_server1.g_debug_level > 0) THEN
    FND_FLEX_SERVER1.add_debug('BEGIN SV1.validate_seg() ');
 END IF;

 --
 --  Initialize all returned values
 --
 vcode := FF_VERROR;
 segquals.nquals := 0;
 l_flexvalue.enabled_flag := 'Y';
 l_flexvalue.summary_flag := 'N';

 isvalu := vflags.values_not_ids;

 --  Initialize value.  Strip spaces if user entered value rather than ID
 --
 IF (isvalu) then
    thisseg := RTRIM(LTRIM(seg_in));
    l_flexvalue.displayed_value := thisseg;
    l_flexvalue.stored_value := thisseg;
  else
    thisseg := seg_in;
    l_flexvalue.hidden_id := thisseg;
 end if;

 --  Get all flexfield and segment qualifiers enabled for this segment.
 --
 IF (get_qualifiers(fstruct, kseg.colname, segquals) < 0) then
    vcode := FF_VERROR;
    goto return_val;
 end if;

 --  Add segment qualifier list to debug string
 --
 IF (fnd_flex_server1.g_debug_level > 0) THEN
    if(segquals.nquals > 0) then
       add_debug('DefaultQuals=');
       for i in 1..segquals.nquals loop
          add_debug('(' || segquals.fq_names(i) || ', ' ||
                    segquals.sq_names(i) || ', ' ||
                    segquals.sq_values(i) || ', ' ||
                    segquals.derived_cols(i) || ')');
       end loop;
    end if;
 END IF;

 --  Attempt to default null values.
 --  Do not default if id or if value not null.
 --  Default only displayed value.
 --  Bug 1539718 added check for vflags.allow_nulls
 --  Bug 2221725 Need to default id if invoking_mode = 'D' and seg is null.

 if vflags.invoking_mode = 'D' then
    if thisseg is null then
       isvalu := TRUE;
    else
       isvalu := FALSE;            -- needed in case previous seg was null.
    end if;
 elsif vflags.invoking_mode = 'Q' then
    if (thisseg is null or kseg.dflt_type is not null) then
       isvalu := TRUE;
    else
       isvalu := FALSE;
    end if;
 end if;

 defaulted := FALSE;

 --Bug 6074421, Modified IF statment to not override null value with
 --defalut value, if segment is not required. Added (kseg.required = 'Y')
 --Bug 7028502, Modified IF statment to allow non-req segments to default
 --if the invoking_mode = 'D'.
 -- ER 17602735 Modified If statement to account for the new invoking_mode 'Q'.
 -- If  invoking_mode is Q, then segments will ALWAYS default to defined value.

   IF ((((isvalu) and (thisseg is null) and
      (kseg.required = 'Y' or vflags.invoking_mode = 'D')) and
      ((displayed and vflags.default_all_displayed and not vflags.allow_nulls) or
      ((kseg.required = 'Y') and vflags.default_all_required) or
      ((kseg.required = 'Y') and (not displayed) and vflags.default_non_displayed)))
      OR  (vflags.invoking_mode = 'Q' and isvalu)) then
               vcode := default_val(kseg.dflt_type, kseg.dflt_val, vsinf.vsformat,
                         vsinf.maxsize, vsinf.precis, vsinf.lettersok,
                         kseg.segname, nprev,
                         prev_dispvals, prev_vals, prev_ids, prev_descs,
                         prev_segnames, prev_vsnames, thisseg);
       defaulted := TRUE;
    if(vcode <> FF_VVALID) then

       --  Bug 2778034-Flexfield is set to use defaulting from a form block
       --  and field, but in processing batch jobs this call is made to do
       --  defaulting, and the form block and field are not available, so
       --  ignore the error and set the field to NULL. This is only
       --  implementedfor invoking_mode 'D', which is for defaulting IDs.
       --  We are ONLY handling this case because we can be assured that
       --  the source is a batch job, and the :block.field cannot be
       --  expected to be available.  We will NOT change this for any
       --  other invoking mode since we cannot be sure of the source.
       --

       if ((vcode = FF_VUNKNOWN) and (vflags.invoking_mode = 'D')) then
          thisseg := NULL;
          vcode := FF_VVALID;
          IF (fnd_flex_server1.g_debug_level > 0) THEN
             add_debug('Segment NOT defaulted because of :block.field bind '
                       || to_char(nprev + 1));
          END IF;
        else
          goto return_val;
       end if;

    end if;
    l_flexvalue.displayed_value := thisseg;
    IF (fnd_flex_server1.g_debug_level > 0) THEN
       add_debug('Defaulted segment ' || to_char(nprev + 1));
       add_debug(' to ' || thisseg);
    END IF;
 end if;

 --  Check for nulls.  If null and this is OK then set values, ids and
 --  description to null and move on.
 --
 --  Bug 1879889 - added check for DFF null dependent segment
 --  We need to check the parent segment before issuing error.
 --  If parent seg is null then child can be null also.
 --  Bug 5560451 The same is true for Key Flexfields. If a parent
 --  is not required and is NULL, then dependent seg does not need value
 --  even if it is required. Removing the statment
 --  fstruct.isa_key_flexfield = FALSE

 --  Bug 13394636 - when a required segment is queried and the data is a null
 --  value for that segment, the client and server validation code differ in
 --  behavior.  The client code gives no error, however the server code does.
 --  We are syncing the behaviour in favor of the client code by adding the
 --  check for invoking_mode = 'L'


 if(thisseg is null) then
    if vsinf.parent_vsid is not NULL and vsinf.valtype = 'D'
    then
       NULL;       -- we will check again for DFF nulls after getting parent.
    else
       if((kseg.required = 'N') or (vflags.allow_nulls) or (vflags.invoking_mode = 'L'))
       then
          vcode := FF_VVALID;
          goto return_val;
        else
          vcode := FF_VREQUIRED;
          if(vflags.message_on_null) then
             value_error_name('FND', 'FLEX-NULL REQUIRED SEGMENT');
             value_error_token('SEGMENT_NAME', kseg.segname);
          /* Bug 9006077 value_error_name('FND', 'FLEX-NULL SEGMENT');*/
          end if;
          goto return_val;
       end if;
    end if;
 end if;


 -- Bug 14250283 Check to see if the zero_fill override has been set.
 -- If set, then we over write what was defined in the value set.
 -- The flag is set by calling fnd_flex_ext.set_zero_fill('Y').
 IF (fnd_flex_server1.zero_fill_override = 'Y' OR
     fnd_flex_server1.zero_fill_override = 'N') then
     l_zero_fill := fnd_flex_server1.zero_fill_override;
 ELSE
     l_zero_fill := vsinf.zfill;
 END IF;


 -- Coerces user input from being a rough approximation of the displayed
 -- value format, to the value storage format.
 -- Also checks length and that value is in min-max range.
 -- Side effect: change thisseg to stored format appropriate to the value set.
 -- Added "and thisseg is not null" in conjuction with changes for bug 1879889
 -- as it is now possible to be here with a null segment.

 -- Validate None validated value sets too.
 IF ((isvalu) OR
     (vsinf.valtype = 'N')) and thisseg is not null then
    vcode := coerce_format(thisseg, isvalu, vsinf.vsformat, vsinf.vsname,
                           vsinf.maxsize, vsinf.lettersok, vsinf.capsonly,
                           l_zero_fill, vsinf.precis, vsinf.minval,
                           vsinf.maxval,l_storage_value, l_display_value);
    thisseg := l_storage_value;
    if(vcode <> FF_VVALID) then
       goto return_val;
    end if;
 end if;

 --  Now look up value

 --  GL RELIES ON THE FOLLOWING STRANGE BEHAVIOR:
 --  To be compatible with client, orphans are ok if the child
 --  value was defaulted and nulls are allowed.
 --
 orphansok := (vflags.all_orphans_valid or
               (vflags.allow_nulls and defaulted));

 -- ==
 --
 -- Find parent value: took out from find_value.
 --
 -- ==
 l_fvc_code := fnd_plsql_cache.CACHE_NOTFOUND;
 IF (vsinf.valtype IN ('I','D','X','Y')) THEN
    IF (isvalu) then
       l_flexvalue.displayed_value := thisseg;
       l_flexvalue.stored_value := thisseg;
     else
       l_flexvalue.hidden_id := thisseg;
    end if;
    l_flexvalue.enabled_flag := 'Y';
    l_flexvalue.summary_flag := 'N';
    l_flexvalue.format := vsinf.vsformat;

    parentval := NULL;

    IF (vsinf.valtype in ('D','Y')) then
       IF (fnd_flex_server1.g_debug_level > 0) THEN
          add_debug(vsinf.valtype);
          for i in 1..nprev loop
             add_debug(to_char(prev_vsids(i)) || '.');
          end loop;
       END IF;

       --
       --  Find index to parent value set
       l_parent_index := 0;
       for i in reverse 1..nprev loop
          IF ((prev_vsids(i) is not null) and
              (vsinf.parent_vsid = prev_vsids(i))) then
             l_parent_index := i;
             IF (vsinf.valtype = 'D') THEN
                parentval := prev_vals(i);
              ELSE
                parentval := prev_ids(i);
             END IF;
             exit;
          end if;
       end loop;

       --
       --  Bug 1879889
       --  Check for DFF null dependent segment now that we have parent value.
       --  same if condition as used above to insure that we only process
       --  DFF dependent null segments.
       --  Bug 2933236
       --  Check dependent segment required flag. If a dependent segment
       --  has a parent, but is not is not required, then it is not
       --  requried to have a value. It only must have a value if the
       --  segment is required.
       --  Bug 5560451 The same is true for Key Flexfields.
       --  Removing the statment fstruct.isa_key_flexfield = FALSE
       --  Bug 8579560
       --  Do additional check whether allow_nulls is set to FALSE before
       --  issuing error
       --  Note-Dual checkin was broken for 12.1 at time of last arcs in
       if thisseg is null and vsinf.parent_vsid is not NULL
           and vsinf.valtype = 'D' then
          if parentval is null then
             vcode := FF_VVALID;
           else
             if ((kseg.required = 'Y') AND (not vflags.allow_nulls))then /* Bug 2933236 */
                vcode := FF_VREQUIRED;
                if(vflags.message_on_null) then
                   value_error_name('FND', 'FLEX-NULL REQUIRED SEGMENT');
                   value_error_token('SEGMENT_NAME', kseg.segname);
                /* Bug 9006077 value_error_name('FND', 'FLEX-NULL SEGMENT');*/
                end if;
              else
                vcode := FF_VVALID;
             end if;
          end if;
          goto return_val;
       end if;

       IF (l_parent_index = 0) then
          FND_MESSAGE.set_name('FND', 'FLEX-NO PARENT SEGMENT');
          FND_MESSAGE.set_token('CHILD', kseg.segname);
          vcode := FF_VERROR;
          goto return_val;
       end if;

      IF ((parentval is null) and (not orphansok))then
         --
         -- Use FLEX-ORPHAN but need segment names of previous segments
         --
         value_error_name('FND', 'FLEX-ORPHAN');
         value_error_token('PARENT', prev_segnames(l_parent_index));
         value_error_token('SEGMENT', kseg.segname);
         vcode := FF_VORPHAN;
         goto return_val;
      end if;
     else
       IF (fnd_flex_server1.g_debug_level > 0) THEN
          add_debug(vsinf.valtype);
       END IF;
    end if;

    IF (kseg.additional_where_clause IS NULL) THEN
       IF (vsinf.valtype IN ('I', 'D')) THEN
          l_fvc_code := check_fvc(vsinf.vsid,
                                  parentval,
                                  thisseg,
                                  l_flexvalue);
       END IF;
    END IF;
 END IF;

 IF (l_fvc_code IN (fnd_plsql_cache.CACHE_FOUND)) THEN
    vcode := FF_VVALID;
  ELSE
    vcode := find_value(fstruct, kseg, vsinf, v_date,
                        thisseg,
                        isvalu, orphansok,
                        kseg.segname, nprev, prev_vsids,
                        prev_dispvals, prev_vals, prev_ids, prev_descs,
                        prev_segnames, prev_vsnames, parentval, l_flexvalue);

    --
    -- If value exists then cache it.
    --
    IF (kseg.additional_where_clause IS NULL) THEN
       IF ((vcode = FF_VVALID) AND
           (vsinf.valtype IN ('I', 'D'))) THEN
          update_fvc(vsinf.vsid, parentval, thisseg, l_flexvalue);
       END IF;
    END IF;
 END IF;

 IF (vcode <> FF_VVALID) then
    goto return_val;
 end if;

 --  Determine qualifier values for this segment from
 --  compiled_value_attributes (This function replaces the sq_values
 --  which differ from the defaults)
 if(l_flexvalue.compiled_attributes is not null) then
    if(qualifier_values(fstruct, vsinf.vsid, l_flexvalue.compiled_attributes,
                        segquals.nquals, segquals.fq_names,
                        segquals.sq_names,
                        segquals.sq_values) < 0) then
       vcode := FF_VERROR;
       goto return_val;
    end if;
 end if;

 --  Add modified segment qualifier values to debug string
 --
 IF (fnd_flex_server1.g_debug_level > 0) THEN
    if(segquals.nquals > 0) THEN
       g_debug_text := 'SegQualVals=';
       for i in 1..segquals.nquals loop
          g_debug_text := g_debug_text || '(' || segquals.sq_values(i) || ')';
       end loop;
       add_debug(g_debug_text);
    end if;
 END IF;

 --  Always check vrules.  They should not be checked in LOADID(), but
 --  the client does it anyway.
 --
 /* bug872437. Don't check vrules in loadid. */

 IF ((vflags.invoking_mode <> 'L') AND
     (vflags.invoking_mode <> 'G')) THEN
    vcode := check_vrules(v_ruls, segquals, l_flexvalue.summary_flag);
    if(vcode <> FF_VVALID) then
       goto return_val;
    end if;
 END IF;

 -- Check security rules
 if(NOT vflags.ignore_security) then
    if((vsinf.valtype in ('I', 'D', 'F')) and
       (vsinf.valsecure in ('Y', 'H')) and (kseg.segsecure = 'Y')) THEN
       IF (fnd_flex_server1.g_debug_level > 0) THEN
          add_debug('Calling Security');
       END IF;
       vcode := check_security(l_flexvalue.stored_value, vsinf.vsformat,
                               parentval, uappid, respid, vsinf,
                               vflags.message_on_security);
       IF (vcode <> FF_VVALID) THEN
          IF (fnd_flex_server1.g_debug_level > 0) THEN
             add_debug('Security Failure Code: ' || vcode);
          END IF;
          goto return_val;
       end if;
       IF (fnd_flex_server1.g_debug_level > 0) THEN
          add_debug('NOT SECURED');
       END IF;
    end if;
 end if;

 -- Check to make sure value is enabled for the given validation date.
 --
 if(NOT vflags.ignore_disabled) then
    if(l_flexvalue.enabled_flag <> 'Y') then
       value_error_name('FND', 'FLEX-VALUE IS DISABLED');
       value_error_token('VALUE', l_flexvalue.displayed_value);
       vcode := FF_VDISABLED;
       goto return_val;
    end if;
 end if;

 if((NOT vflags.ignore_expired) and (v_date is not null)) then
    if((Trunc(v_date) < Trunc(nvl(l_flexvalue.start_valid, v_date))) or
       (Trunc(v_date) > Trunc(nvl(l_flexvalue.end_valid, v_date)))) then
       value_error_name('FND', 'FLEX-VALUE IS EXPIRED');
       value_error_token('VALUE', l_flexvalue.displayed_value);
       vcode := FF_VEXPIRED;
       goto return_val;
    end if;
 end if;

 <<return_val>>
 x_flexvalue := l_flexvalue;
 squals := segquals;
 IF (fnd_flex_server1.g_debug_level > 0) THEN
    FND_FLEX_SERVER1.add_debug('END SV1.validate_seg() ');
 END IF;

 return(vcode);

EXCEPTION
 WHEN OTHERS then
    FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
    FND_MESSAGE.set_token('MSG', 'validate_seg() exception:  ' || SQLERRM);
    IF (fnd_flex_server1.g_debug_level > 0) THEN
       FND_FLEX_SERVER1.add_debug('EXCEPTION others SV1.validate_seg() ');
    END IF;
    return(FF_VERROR);
END validate_seg;

/* ----------------------------------------------------------------------- */
/*      Given the dvals and qualifiers for the current segment and the     */
/*      existing derived dvals and qualifiers, compute the new dvals and   */
/*      qualifiers.  Presently only handles one set of derivation rules.   */
/*      Returns TRUE if OK or FALSE and sets error message if errors.      */
/* ----------------------------------------------------------------------- */

FUNCTION derive_values(new_dvals      IN      DerivedVals,
                       new_quals      IN      Qualifiers,
                       drv_dvals      IN OUT  nocopy DerivedVals,
                       drv_quals      IN OUT  nocopy Qualifiers) RETURN BOOLEAN IS

  dqi BINARY_INTEGER;

BEGIN

-- Derive values for the enabled parameters and summary flag
--
  if((new_dvals.start_valid is not null) and
     ((drv_dvals.start_valid is null) or
      (new_dvals.start_valid > drv_dvals.start_valid))) then
    drv_dvals.start_valid := new_dvals.start_valid;
  end if;
  if((new_dvals.end_valid is not null) and
     ((drv_dvals.end_valid is null) or
      (new_dvals.end_valid < drv_dvals.end_valid))) then
    drv_dvals.end_valid := new_dvals.end_valid;
  end if;
  if(new_dvals.enabled_flag = 'N') then
    drv_dvals.enabled_flag := 'N';
  end if;
  if(new_dvals.summary_flag = 'Y') then
    drv_dvals.summary_flag := 'Y';
  end if;

--  Derive the qualifiers.
--  Add each segment qualifier to the accumulated derived qualifiers.
--  If it's a new qualifier add it to the array of derived qualifier names.
--  Otherwise, compute the derived value using the Derivation rules:
--  "If any segment qualifier value is 'N' the derived value is 'N'
--
--  Algorithm:  For each seg qual, find dqi = index to derived qual with
--  the same fq and sq names.  If found, derive the value using the new seg
--  qualifier value.  If not found, add a new qualifier to the list of
--  derived qualifiers.
--
  for i in 1..new_quals.nquals loop
    dqi := NULL;
    for j in 1..drv_quals.nquals loop
      if((drv_quals.fq_names(j) = new_quals.fq_names(i)) and
         (drv_quals.sq_names(j) = new_quals.sq_names(i))) then
        dqi := j;
        exit;
      end if;
    end loop;
    if(dqi is not null) then
      if(new_quals.sq_values(i) = 'N') then
        drv_quals.sq_values(dqi) := 'N';
      end if;
    else
      drv_quals.nquals := drv_quals.nquals + 1;
      dqi := drv_quals.nquals;
      drv_quals.fq_names(dqi) := new_quals.fq_names(i);
      drv_quals.sq_names(dqi) := new_quals.sq_names(i);
      drv_quals.sq_values(dqi) := new_quals.sq_values(i);
      drv_quals.derived_cols(dqi) := new_quals.derived_cols(i);
    end if;
  end loop;

  return(TRUE);

EXCEPTION
  WHEN OTHERS then
    FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
    FND_MESSAGE.set_token('MSG', 'derive_values() exception:  ' || SQLERRM);
    return(FALSE);

END derive_values;

/* ----------------------------------------------------------------------- */
/*      Coerces entered segment value into the value storage format        */
/*      appropriate for the value set,                                     */
/*      and checks to make sure value is not too long and is within the    */
/*      the min-max range specified in the value set.                      */
/*                                                                         */
/*      Returns the value in stored format and TRUE on success or sets     */
/*      error and returns FALSE on error.                                  */
/* ----------------------------------------------------------------------- */

FUNCTION coerce_format(user_value IN     VARCHAR2,
                       p_is_displayed IN BOOLEAN,
                       vs_format  IN     VARCHAR2,
                       vs_name    IN     VARCHAR2,
                       max_length IN     NUMBER,
                       letters_ok IN     VARCHAR2,
                       caps_only  IN     VARCHAR2,
                       zero_fill  IN     VARCHAR2,
                       precision  IN     VARCHAR2,
                       min_value  IN     VARCHAR2,
                       max_value  IN     VARCHAR2,
                       x_storage_value OUT nocopy VARCHAR2,
                       x_display_value OUT nocopy VARCHAR2) RETURN VARCHAR2 IS

  l_return    VARCHAR2(1);
  l_success   NUMBER;
  l_storage_value VARCHAR2(2000);
  l_display_value VARCHAR2(2000);
  l_utv_enc_message VARCHAR2(32000) := NULL;
  l_ssv_enc_message VARCHAR2(32000) := NULL;
BEGIN
   IF (fnd_flex_server1.g_debug_level > 0) THEN
      FND_FLEX_SERVER1.add_debug('BEGIN SV1.coerce_format() ');
   END IF;

   x_storage_value := user_value;
   x_display_value := user_value;

   --
   -- Since validation utility is setting messages by using
   -- fnd_message, we will do a stacking trick here.
   --
   -- For different result, different style of messaging is used.
   -- If the error is serious, always overwrite the existing message.
   --
   IF (value_error_set) THEN
      l_ssv_enc_message := fnd_message.get_encoded;
   END IF;

   fnd_flex_val_util.validate_value_ssv
     (p_value     => user_value,
      p_is_displayed => p_is_displayed,
      p_vset_name => vs_name,
      p_vset_format => vs_format,
      p_max_length => max_length,
      p_precision => To_number(precision),
      p_alpha_allowed => letters_ok,
      p_uppercase_only => caps_only,
      p_zero_fill => zero_fill,
      p_min_value => min_value,
      p_max_value => max_value,
      x_storage_value => l_storage_value,
      x_display_value => l_display_value,
      x_success       => l_success);

   IF (fnd_flex_server1.g_debug_level > 0) THEN
      add_debug(Rtrim(Substr(fnd_flex_val_util.get_debug,1,2000), chr_newline));
   END IF;
   IF (l_success = fnd_flex_val_util.g_ret_no_error) THEN
      --
      -- No error case.
      --
      l_return := FF_VVALID;
      x_storage_value := l_storage_value;
      x_display_value := l_display_value;
      IF (value_error_set) THEN
         fnd_message.set_encoded(l_ssv_enc_message);
      END IF;
    ELSE
      --
      -- Since this is an error case, get the message.
      --
      l_utv_enc_message := fnd_message.get_encoded;

      IF ((l_success = fnd_flex_val_util.g_ret_value_too_long) OR
          (l_success = fnd_flex_val_util.g_ret_invalid_number) OR
          (l_success = fnd_flex_val_util.g_ret_invalid_date)) THEN
          --
          -- Format Errors.
          --
          l_return := FF_VFORMAT;
          IF (value_error_set) THEN
             fnd_message.set_encoded(l_ssv_enc_message);
           ELSE
             fnd_message.set_encoded(l_utv_enc_message);
          END IF;
       ELSIF ((l_success = fnd_flex_val_util.g_ret_vs_bad_precision) OR
              (l_success = fnd_flex_val_util.g_ret_vs_bad_format) OR
              (l_success = fnd_flex_val_util.g_ret_vs_bad_numrange) OR
              (l_success = fnd_flex_val_util.g_ret_vs_bad_daterange) OR
              (l_success = fnd_flex_val_util.g_ret_vs_bad_date) OR
              (l_success = fnd_flex_val_util.g_ret_exception_others)) THEN
         --
         -- Serious errors.
         --
         l_return := FF_VERROR;
         fnd_message.set_encoded(l_utv_enc_message);

       ELSIF (l_success = fnd_flex_val_util.g_ret_val_out_of_range) THEN
         --
         -- Bound Check Error.
         --
         l_return := FF_VBOUNDS;
         IF (value_error_set) THEN
            fnd_message.set_encoded(l_ssv_enc_message);
          ELSE
            fnd_message.set_encoded(l_utv_enc_message);
         END IF;
       ELSE
         --
         -- Other errors. This part is added, in case there will be changes
         -- in UTV package. As of 26-APR-99 code should not enter here.
         --
         l_return := FF_VERROR;
         fnd_message.set_encoded(l_utv_enc_message);
      END IF;
      --
      -- We are in error case, set messaging globals.
      --
      value_error_set := TRUE;
      entering_new_message := FALSE;
   END IF;

   IF (fnd_flex_server1.g_debug_level > 0) THEN
      FND_FLEX_SERVER1.add_debug('END SV1.coerce_format() ');
   END IF;

   RETURN(l_return);

EXCEPTION
   WHEN OTHERS THEN
      IF (fnd_flex_server1.g_debug_level > 0) THEN
         FND_FLEX_SERVER1.add_debug('EXCEPTION SV1.coerce_format() ');
      END IF;

      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG', 'coerce_format() exception:  ' || SQLERRM);
      return(FF_VERROR);
END coerce_format;

/* ----------------------------------------------------------------------- */
/*      Looks up value in appropriate validation tables.  Input the        */
/*      character representation of the stored value or the id.  Returns   */
/*      all information about the value in the FlexValue structure.  Also  */
/*      returns the parent value in stored format if there is a parent.    */
/*      This function needs to know about all previous segments to         */
/*      handle dependent and table validated value sets.                   */
/*      Returns TRUE if value is found or FALSE and sets error if not.     */
/* ----------------------------------------------------------------------- */

FUNCTION find_value(p_str_info          IN  FlexStructId,
                    p_seg_info          IN  SegmentInfo,
                    p_vs_info           IN  ValueSetInfo,
                    p_vdate             IN  DATE,
                    p_char_val          IN  VARCHAR2,
                    p_is_value          IN  BOOLEAN,
                    p_orphans_ok        IN  BOOLEAN,
                    p_this_segname      IN  VARCHAR2,
                    p_n_prev            IN  NUMBER,
                    p_prev_vsids        IN  NumberArray,
                    p_prev_dispvals     IN  ValueArray,
                    p_prev_vals         IN  ValueArray,
                    p_prev_ids          IN  ValueIdArray,
                    p_prev_descs        IN  ValueDescArray,
                    p_prev_segnames     IN  SegNameArray,
                    p_prev_vsnames      IN  VsNameArray,
                    p_parent_val        IN  VARCHAR2,
                    x_this_val_out      OUT nocopy FlexValue)
  RETURN VARCHAR2
  IS
     v_code                VARCHAR2(1);
     l_is_value            VARCHAR2(1);
     check_value_table     BOOLEAN;
     this_value            FlexValue;

  CURSOR IND_cursor(vsid IN NUMBER, val IN VARCHAR2) IS
    SELECT enabled_flag, start_date_active, end_date_active,
           summary_flag, compiled_value_attributes, description
      FROM fnd_flex_values_vl
     WHERE flex_value_set_id = vsid
       AND flex_value = val;

  CURSOR DEP_cursor(vsid IN NUMBER, val IN VARCHAR2, parnt IN VARCHAR2) IS
    SELECT enabled_flag, start_date_active, end_date_active,
           summary_flag, compiled_value_attributes, description
      FROM fnd_flex_values_vl
     WHERE flex_value_set_id = vsid
       AND flex_value = val
       AND parent_flex_value_low = parnt;

  CURSOR INDTL_cursor(vsid IN NUMBER,
                      val IN VARCHAR2,
                      p_is_value IN VARCHAR2) IS
    SELECT enabled_flag, start_date_active, end_date_active,
      summary_flag, compiled_value_attributes,
      flex_value, flex_value_meaning, description
      FROM fnd_flex_values_vl
     WHERE flex_value_set_id = vsid
      AND (((p_is_value = 'V') AND (flex_value_meaning = val)) OR
           ((p_is_value = 'I') AND (flex_value = val)));

  CURSOR DEPTL_cursor(vsid IN NUMBER,
                      val IN VARCHAR2,
                      parnt IN VARCHAR2,
                      p_is_value IN VARCHAR2) IS
    SELECT enabled_flag, start_date_active, end_date_active,
      summary_flag, compiled_value_attributes,
      flex_value, flex_value_meaning, description
      FROM fnd_flex_values_vl
      WHERE flex_value_set_id = vsid
      AND parent_flex_value_low = parnt
      AND (((p_is_value = 'V') AND (flex_value_meaning = val)) OR
           ((p_is_value = 'I') AND (flex_value = val)));

BEGIN
   IF (fnd_flex_server1.g_debug_level > 0) THEN
      FND_FLEX_SERVER1.add_debug('BEGIN SV1.find_value()');
   END IF;

   --  Default the return value

   v_code := FF_VERROR;


   IF (p_is_value) THEN
      l_is_value := 'V';
      --
      -- R11.5 NLS: following is not true any more. char_val is stored value.
      -- However at the end of this function there is a conversion to
      -- displayed value.
      --
      this_value.displayed_value := p_char_val;
      this_value.stored_value := p_char_val;
    ELSE
      l_is_value := 'I';
      this_value.hidden_id := p_char_val;
   end if;
   this_value.enabled_flag := 'Y';
   this_value.summary_flag := 'N';
   this_value.format := p_vs_info.vsformat;

   --  Validation = None, do nothing.
   --
   -- Bug 21393544 Special Validated Value Sets should be
   -- treated the same as a None Value Set. Validating Special
   -- Vsets are not supported in plsql. Special is a user-exit
   -- call and only supported in Forms. If a special vset is
   -- attached to a segment and server validation is being called,
   -- then we will not validate that segment value. It will be
   -- treated as a None validated value set.
   if(p_vs_info.valtype = 'N' OR p_vs_info.valtype = 'U') then
      IF (fnd_flex_server1.g_debug_level > 0) THEN
         add_debug('N');
      END IF;
      this_value.stored_value := p_char_val;
      this_value.hidden_id := p_char_val;
      v_code := FF_VVALID;

      --  Validation = Independent, or dependent look it up
      --
    ELSIF ((p_vs_info.valtype in ('I', 'D')) AND
           (p_seg_info.additional_where_clause IS NULL)) then

      --  Takes care of both dependent and independent VS
      --  Use the independent cursor if this is an independent value set
      --  or if this is a dependent value set and the parent_val is null.
      --  Both of these conditions will set parent_val to null
      --
      if(p_parent_val is null) then
         open IND_cursor(p_vs_info.vsid, p_char_val);
         fetch IND_cursor into this_value.enabled_flag, this_value.start_valid,
           this_value.end_valid, this_value.summary_flag,
           this_value.compiled_attributes, this_value.description;
         if(IND_cursor%NOTFOUND) then
            v_code := FF_VNOTFOUND;
          else
            v_code := FF_VVALID;
         end if;
         close IND_cursor;
       else
         open DEP_cursor(p_vs_info.vsid, p_char_val, p_parent_val);
         fetch DEP_cursor into this_value.enabled_flag, this_value.start_valid,
           this_value.end_valid, this_value.summary_flag,
           this_value.compiled_attributes, this_value.description;
         if(DEP_cursor%NOTFOUND) then
            v_code := FF_VNOTFOUND;
          else
            v_code := FF_VVALID;
         end if;
         close DEP_cursor;
      end if;

      -- Set error if value not found or set the returned value if found.
      -- Assumes v_code was either FF_VNOTFOUND or FF_VVALID.
      --
      if(v_code = FF_VNOTFOUND) then
--         if(p_is_value) then
         if(TRUE) then -- Better error message for user
            value_error_name('FND', 'FLEX-VALUE DOES NOT EXIST');

            value_error_token('VALUE', msg_val(p_vs_info.vsformat, p_vs_info.maxsize, p_vs_info.precis, p_vs_info.lettersok, p_char_val));
            value_error_token('SEGMENT', p_this_segname);
            value_error_token('VALUESET', p_vs_info.vsname);
          else
            value_error_name('FND', 'FLEX-ID DOES NOT EXIST');

            value_error_token('ID', p_char_val);
            value_error_token('SEGMENT', p_this_segname);
            value_error_token('VALUESET', p_vs_info.vsname);
         end if;
         goto return_found_value;
       else
         this_value.stored_value := p_char_val;
         this_value.hidden_id := p_char_val;
      end if;

      --  Validation = TL Independent, or TL dependent look it up
      --
    ELSIF ((p_vs_info.valtype in ('X', 'Y'))  AND
           (p_seg_info.additional_where_clause IS NULL)) then

      --  Takes care of both TL dependent and TL independent VS
      --  Use the independent cursor if this is an independent value set
      --  or if this is a dependent value set and the parent_val is null.
      --  Both of these conditions will set parent_val to null
      --
      if(p_parent_val is null) then
         open INDTL_cursor(p_vs_info.vsid, p_char_val,l_is_value);
         fetch INDTL_cursor into this_value.enabled_flag,
           this_value.start_valid,
           this_value.end_valid, this_value.summary_flag,
           this_value.compiled_attributes,
           this_value.hidden_id, this_value.stored_value,
           this_value.description;
         if(INDTL_cursor%NOTFOUND) then
            v_code := FF_VNOTFOUND;
          else
            v_code := FF_VVALID;
         end if;
         close INDTL_cursor;
       else
         open DEPTL_cursor(p_vs_info.vsid, p_char_val, p_parent_val, l_is_value);
         fetch DEPTL_cursor into this_value.enabled_flag,
           this_value.start_valid,
           this_value.end_valid, this_value.summary_flag,
           this_value.compiled_attributes,
           this_value.hidden_id, this_value.stored_value,
           this_value.description;
         if(DEPTL_cursor%NOTFOUND) then
            v_code := FF_VNOTFOUND;
          else
            v_code := FF_VVALID;
         end if;
         close DEPTL_cursor;
      end if;

      -- Set error if value not found or set the returned value if found.
      -- Assumes v_code was either FF_VNOTFOUND or FF_VVALID.
      --
      IF (v_code = FF_VNOTFOUND) then
--         if(p_is_value) then
         if(TRUE) then -- Better error message for user
            value_error_name('FND', 'FLEX-VALUE DOES NOT EXIST');

            value_error_token('VALUE', msg_val(p_vs_info.vsformat, p_vs_info.maxsize, p_vs_info.precis, p_vs_info.lettersok, p_char_val));
            value_error_token('SEGMENT', p_this_segname);
            value_error_token('VALUESET', p_vs_info.vsname);
          else
            value_error_name('FND', 'FLEX-ID DOES NOT EXIST');

            value_error_token('ID', p_char_val);
            value_error_token('SEGMENT', p_this_segname);
            value_error_token('VALUESET', p_vs_info.vsname);
         end if;
         goto return_found_value;
       else
         NULL;
         --        this_value.stored_value := p_char_val;
         --        this_value.hidden_id := p_char_val;
      end if;

    ELSIF ((p_vs_info.valtype in ('I', 'D')) AND
           (p_seg_info.additional_where_clause IS NOT NULL)) then
      --
      -- Similar to Table validation.
      --

      IF (fnd_flex_server1.g_debug_level > 0) THEN
         add_debug('~F(' || p_vs_info.valtype || ')');
      END IF;

      v_code := table_validate(p_str_info, p_seg_info, p_vs_info,
                               p_vdate, p_parent_val,
                               p_char_val, p_is_value,
                               p_n_prev, p_prev_dispvals, p_prev_vals,
                               p_prev_ids, p_prev_descs, p_prev_segnames,
                               p_prev_vsnames, check_value_table, this_value);

      --  table_validate() does not set error message if the problem is
      --  that the value is not found because we might have to look up
      --  the value in the values table.  Therefore we need to set the
      --  error if value was not found.
      if(v_code = FF_VNOTFOUND) then
--         if(p_is_value) then
         if(TRUE) then -- Better error message for user
            value_error_name('FND', 'FLEX-VALUE DOES NOT EXIST');

            value_error_token('VALUE', msg_val(p_vs_info.vsformat, p_vs_info.maxsize, p_vs_info.precis, p_vs_info.lettersok, p_char_val));
            value_error_token('SEGMENT', p_this_segname);
            value_error_token('VALUESET', p_vs_info.vsname);
          else
            value_error_name('FND', 'FLEX-ID DOES NOT EXIST');

            value_error_token('ID', p_char_val);
            value_error_token('SEGMENT', p_this_segname);
            value_error_token('VALUESET', p_vs_info.vsname);
         end if;
      end if;

    ELSIF ((p_vs_info.valtype in ('X', 'Y'))  AND
           (p_seg_info.additional_where_clause IS NOT NULL)) THEN

      --
      -- Similar to Table validation.
      --

      IF (fnd_flex_server1.g_debug_level > 0) THEN
         add_debug('~F(' || p_vs_info.valtype || ')');
      END IF;

      v_code := table_validate(p_str_info, p_seg_info, p_vs_info,
                               p_vdate, p_parent_val,
                               p_char_val, p_is_value,
                               p_n_prev, p_prev_dispvals, p_prev_vals,
                               p_prev_ids, p_prev_descs, p_prev_segnames,
                               p_prev_vsnames, check_value_table, this_value);

      --  table_validate() does not set error message if the problem is
      --  that the value is not found because we might have to look up
      --  the value in the values table.  Therefore we need to set the
      --  error if value was not found.
      if(v_code = FF_VNOTFOUND) then
--         if(p_is_value) then
         if(TRUE) then -- Better error message for user
            value_error_name('FND', 'FLEX-VALUE DOES NOT EXIST');

            value_error_token('VALUE', msg_val(p_vs_info.vsformat, p_vs_info.maxsize, p_vs_info.precis, p_vs_info.lettersok, p_char_val));
            value_error_token('SEGMENT', p_this_segname);
            value_error_token('VALUESET', p_vs_info.vsname);
          else
            value_error_name('FND', 'FLEX-ID DOES NOT EXIST');

            value_error_token('ID', p_char_val);
            value_error_token('SEGMENT', p_this_segname);
            value_error_token('VALUESET', p_vs_info.vsname);
         end if;
      end if;

      -- Table validation.
      --
    ELSIF (p_vs_info.valtype = 'F') then

      IF (fnd_flex_server1.g_debug_level > 0) THEN
         add_debug('F');
      END IF;

      v_code := table_validate(p_str_info, p_seg_info, p_vs_info,
                               p_vdate, p_parent_val,
                               p_char_val, p_is_value,
                               p_n_prev, p_prev_dispvals, p_prev_vals,
                               p_prev_ids, p_prev_descs, p_prev_segnames,
                               p_prev_vsnames, check_value_table, this_value);

      if((v_code = FF_VNOTFOUND) and (check_value_table = TRUE)) then
         open IND_cursor(p_vs_info.vsid, p_char_val);
         fetch IND_cursor into this_value.enabled_flag, this_value.start_valid,
           this_value.end_valid, this_value.summary_flag,
           this_value.compiled_attributes, this_value.description;
         if(IND_cursor%FOUND) then
            this_value.stored_value := p_char_val;
            this_value.hidden_id := p_char_val;
            v_code := FF_VVALID;
         end if;
         close IND_cursor;
      end if;

      --  table_validate() does not set error message if the problem is
      --  that the value is not found because we might have to look up
      --  the value in the values table.  Therefore we need to set the
      --  error if value was not found.
      if(v_code = FF_VNOTFOUND) then
--         if(p_is_value) then
         if(TRUE) then -- Better error message for user
            value_error_name('FND', 'FLEX-VALUE DOES NOT EXIST');

            value_error_token('VALUE', msg_val(p_vs_info.vsformat, p_vs_info.maxsize, p_vs_info.precis, p_vs_info.lettersok, p_char_val));
            value_error_token('SEGMENT', p_this_segname);
            value_error_token('VALUESET', p_vs_info.vsname);
          else
            value_error_name('FND', 'FLEX-ID DOES NOT EXIST');

            value_error_token('ID', p_char_val);
            value_error_token('SEGMENT', p_this_segname);
            value_error_token('VALUESET', p_vs_info.vsname);
         end if;
      end if;

      -- Pair or Special validation unsupported.
      --
      -- Bug 21393544, We will not throw an error for
      -- Special. It will be treated as a None type vset.
      -- This will be handled above so the code will not
      -- get this far for Special. We will leave Pair alone
      -- for now. Special is being used to make segments
      -- non update-able and we do not want to throw an error
      -- during api server validation.
    ELSIF (p_vs_info.valtype in ('P', 'U')) then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV UNSUPPORTED VDATION');
      FND_MESSAGE.set_token('VSNAME', p_vs_info.vsname);
      v_code := FF_VUNKNOWN;

      -- Undefined validation type
      --
    else
      FND_MESSAGE.set_name('FND', 'FLEX-VS BAD VDATION TYPE');
      FND_MESSAGE.set_token('VSNAME', p_vs_info.vsname);
      FND_MESSAGE.set_token('VTYPE', p_vs_info.valtype);
      v_code := FF_VERROR;
   end if;

   <<return_found_value>>
   if(v_code = FF_VVALID) THEN
      v_code := stored_to_displayed(p_vs_info.vsformat, p_vs_info.maxsize, p_vs_info.precis,
                                    p_vs_info.lettersok,
                                    this_value.stored_value,
                                    this_value.displayed_value);
   end if;
   x_this_val_out := this_value;
   IF (fnd_flex_server1.g_debug_level > 0) THEN
      FND_FLEX_SERVER1.add_debug('END SV1.find_value(returns:' ||
                                 v_code || ')');
   END IF;

   return(v_code);
EXCEPTION
   WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG', 'find_value() exception:  ' || SQLERRM);
      IF (fnd_flex_server1.g_debug_level > 0) THEN
         FND_FLEX_SERVER1.add_debug('EXCEPTION others SV1.find_value()');
      END IF;

      return(FF_VERROR);
END find_value;

/* ----------------------------------------------------------------------- */
/*      Finds value from table validated value set.                        */
/*      Returns value error code and sets message on error.                */
/*      However, if value is not found, does not set the error message     */
/*      because we may have to look it up in the values table if           */
/*      check_valtab is returned as 'Y'                                    */
/*      NOTE:  where_clause declared as VARCHAR2(30000) for implicit       */
/*      conversion from LONG column type in the table.                     */
/*      Generic exception raised if SQL fragment in where_clause is bad.   */
/* ----------------------------------------------------------------------- */
FUNCTION table_validate(p_str_info            IN  FlexStructId,
                        p_seg_info            IN  SegmentInfo,
                        p_vs_info             IN  ValueSetInfo,
                        p_vdate               IN  DATE,
                        p_parent_value        IN  VARCHAR2,
                        p_charval             IN  VARCHAR2,
                        p_is_value            IN  BOOLEAN,
                        p_nprev               IN  NUMBER,
                        p_prev_dispvals       IN  ValueArray,
                        p_prev_vals           IN  ValueArray,
                        p_prev_ids            IN  ValueIdArray,
                        p_prev_descs          IN  ValueDescArray,
                        p_prev_segnames       IN  SegNameArray,
                        p_prev_vsnames        IN  VsNameArray,
                        x_check_valtab        OUT nocopy BOOLEAN,
                        x_found_value         OUT nocopy FlexValue)
  RETURN VARCHAR2
  IS
     l_where_clause          VARCHAR2(32000);
     l_tmp_where_clause      VARCHAR2(32000);
     l_order_by_pos          NUMBER;

     l_vcode                 VARCHAR2(1);
     l_sql                   VARCHAR2(32000);
     l_nrecords              NUMBER;
     l_results               StringArray;

     CURSOR tbl_cursor(p_flex_value_set_id IN NUMBER) IS
        SELECT application_table_name, value_column_name, value_column_type,
          id_column_name, id_column_type, meaning_column_name,
          meaning_column_type, enabled_column_name, start_date_column_name,
          end_date_column_name, summary_column_name,
          compiled_attribute_column_name, additional_quickpick_columns,
          summary_allowed_flag, additional_where_clause
          FROM fnd_flex_validation_tables
          WHERE flex_value_set_id = p_flex_value_set_id;

     l_tbl_rec     tbl_cursor%ROWTYPE;
     l_sql_pieces  sql_pieces_tab_type;
BEGIN
   IF (p_vs_info.valtype IN ('I', 'D', 'X', 'Y')) THEN
      l_tbl_rec.application_table_name := 'FND_FLEX_VALUES_VL FND_FLEX_VALUES_VL';
      l_tbl_rec.value_column_name := 'FND_FLEX_VALUES_VL.FLEX_VALUE';
      l_tbl_rec.value_column_type := 'C';
      l_tbl_rec.id_column_name := NULL;
      l_tbl_rec.id_column_type := NULL;
      l_tbl_rec.meaning_column_name := 'FND_FLEX_VALUES_VL.DESCRIPTION';
      l_tbl_rec.meaning_column_type := 'C';
      l_tbl_rec.enabled_column_name := 'FND_FLEX_VALUES_VL.ENABLED_FLAG';
      l_tbl_rec.start_date_column_name := 'FND_FLEX_VALUES_VL.START_DATE_ACTIVE';
      l_tbl_rec.end_date_column_name := 'FND_FLEX_VALUES_VL.END_DATE_ACTIVE';
      l_tbl_rec.summary_column_name := 'FND_FLEX_VALUES_VL.SUMMARY_FLAG';
      l_tbl_rec.compiled_attribute_column_name := 'FND_FLEX_VALUES_VL.COMPILED_VALUE_ATTRIBUTES';
      l_tbl_rec.additional_quickpick_columns := NULL;
      l_tbl_rec.summary_allowed_flag := 'N';

      IF (p_parent_value IS NULL) THEN
         l_tbl_rec.additional_where_clause := 'WHERE FND_FLEX_VALUES_VL.FLEX_VALUE_SET_ID = :$FLEX$.$VALUE_SET_ID$';
       ELSE
         l_tbl_rec.additional_where_clause := 'WHERE FND_FLEX_VALUES_VL.FLEX_VALUE_SET_ID = :$FLEX$.$VALUE_SET_ID$' ||
           ' AND FND_FLEX_VALUES_VL.PARENT_FLEX_VALUE_LOW = :$FLEX$.$PARENT_VALUE$';
      END IF;

    ELSE
      open TBL_cursor(p_vs_info.vsid);
      FETCH tbl_cursor INTO l_tbl_rec;
      IF (TBL_cursor%NOTFOUND) THEN
         close TBL_cursor;
         FND_MESSAGE.set_name('FND', 'FLEX-SSV MISSING TBLVS');
         FND_MESSAGE.set_token('VSNAME', p_vs_info.vsname);
         return(FF_VERROR);
      end if;
      close TBL_cursor;
   END IF;

   IF (l_tbl_rec.summary_allowed_flag = 'Y') then
      x_check_valtab := TRUE;
    else
      x_check_valtab := FALSE;
   end if;

   --  Return error if unsupported validation.
   --
   if((l_tbl_rec.additional_quickpick_columns is not null) and (INSTR(UPPER(l_tbl_rec.additional_quickpick_columns),'INTO') > 0)) then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV NO TBL VS');
      FND_MESSAGE.set_token('VSNAME', p_vs_info.vsname);
      return(FF_VUNKNOWN);
   end if;

   --  Default column names if null
   --
   if(l_tbl_rec.id_column_name is null) then
      l_tbl_rec.id_column_name := l_tbl_rec.value_column_name;
      l_tbl_rec.id_column_type := l_tbl_rec.value_column_type;
   end if;

   if(l_tbl_rec.meaning_column_name is null) then
      l_tbl_rec.meaning_column_name := 'NULL';
      l_tbl_rec.meaning_column_type := 'V';
   end if;

   -- Now need to parse where/order by clause.  Clause is of the form:
   -- [where <condition>] [order by <ordering>]
   -- The order by portion is not relevant here and is dropped.
   -- "where" is optional, hence the first word in the string need not be
   -- "where".
   -- Note there can only be 1 space between "order" and "by".
   -- "where" and "order by" are found using case-insensitive comparisons.
   -- Case-insensitive comparison requires upper case conversion.
   -- Assume SQL strings in single-byte characters only.
   -- Substitute $FLEX$ and $PROFILES$ in where clause if its not null.
   --
   l_where_clause := ltrim(l_tbl_rec.additional_where_clause, WHITESPACE);

   l_sql_pieces.DELETE;
   if (l_where_clause is not null) then
      -- there is where clause
      l_tmp_where_clause := Upper(l_where_clause);

      if (l_tmp_where_clause LIKE 'WHERE%') then
         -- It starts with WHERE keyword
         -- Skip the leading WHERE keyword
         l_where_clause := Substr(l_where_clause, 6);
         l_tmp_where_clause := Upper(l_where_clause);
      end if;

      l_order_by_pos := Instr(l_tmp_where_clause, 'ORDER BY');
      if (l_order_by_pos > 0) then
         l_where_clause := Substr(l_where_clause, 1, l_order_by_pos - 1);
      end if;

      IF (p_seg_info.additional_where_clause IS NOT NULL) THEN
         l_where_clause := '(' || l_where_clause || ') AND (' ||
           p_seg_info.additional_where_clause || ')';
      END IF;

      l_vcode := substitute_flex_binds5(l_where_clause,
                                        p_str_info, p_seg_info,
                                        p_vdate, p_parent_value,
                                        p_nprev, p_prev_dispvals,
                                        p_prev_vals, p_prev_ids, p_prev_descs,
                                        p_prev_segnames, p_prev_vsnames,
                                        l_sql_pieces);

      if (l_vcode <> FF_VVALID) then
         return(l_vcode);
      end if;

      IF (fnd_flex_server1.g_debug_level > 0) THEN
         l_tmp_where_clause := NULL;
         IF (l_vcode = FF_VVALID) THEN
            FOR i IN 1 .. l_sql_pieces.COUNT LOOP
               IF (l_sql_pieces(i).piece_type = SSP_PIECE_TYPE_BIND) THEN
                  l_tmp_where_clause := l_tmp_where_clause ||
                    string_clause(l_sql_pieces(i).bind_value);

                ELSE
                  l_tmp_where_clause := l_tmp_where_clause ||
                    l_sql_pieces(i).piece_text;
               END IF;
            END LOOP;
         END IF;

         l_where_clause := l_tmp_where_clause;

         if(l_where_clause is not null) then
            add_debug(' (where ' || SUBSTRB(l_where_clause, 1, 1000) || ') ');
         end if;
      END IF;
   end if;

   --  Build SQL statement to do the select from the table specified
   --  by APPLICATION_TABLE_NAME.
   --
   --  The columns SUMMARY_COLUMN_NAME, COMPILED_ATTRIBUTE_COLUMN_NAME,
   --  ENABLED_COLUMN_NAME, and START and END _DATE_COLUMN_NAME in the
   --  FND_FLEX_VALIDATION_TABLES table either contain the name of the
   --  column in the "application table" which contains those parameters,
   --  or they contain text strings which are part of a sql statement.
   --  For example, the COMPILED_ATTRIBUTES_COLUMN_NAME contains either the
   --  name of a column, or a SQL fragment of the form: "'Y\nN\nA'" which
   --  includes the single quotes.
   --
   --  In either case the contents of these fields should be blindly
   --  inserted into the SQL statement.
   --
   --  BUG:  To be compatible with client code behavior, we must surround
   --  non-character columns with the default to_char() conversion in the
   --  select statement.  This causes seconds to be lost from date columns.
   --  It also means that numbers are stored and displayed in their default
   --  format rather than the value set format.
   --
   --  This functionality is now in the select_clause() function.
   --
   l_sql := 'select ' ||
     select_clause(l_tbl_rec.value_column_name, l_tbl_rec.value_column_type,
                   VC_VALUE, p_vs_info.vsformat, p_vs_info.maxsize);
   l_sql := l_sql || ', ' ||
     select_clause(l_tbl_rec.id_column_name, l_tbl_rec.id_column_type,
                   VC_ID, p_vs_info.vsformat, p_vs_info.maxsize);
   l_sql := l_sql || ', ' ||
     select_clause(l_tbl_rec.meaning_column_name, l_tbl_rec.meaning_column_type,
                   VC_DESCRIPTION, p_vs_info.vsformat, p_vs_info.maxsize);
   l_sql := l_sql || ', ' || l_tbl_rec.enabled_column_name || ', ';
   l_sql := l_sql || 'to_char(' || l_tbl_rec.start_date_column_name ||',''YYYY/MM/DD HH24:MI:SS'')' || ', ';
   l_sql := l_sql || 'to_char(' || l_tbl_rec.end_date_column_name ||',''YYYY/MM/DD HH24:MI:SS'')' || ', ';
   l_sql := l_sql || l_tbl_rec.summary_column_name || ', ';
   l_sql := l_sql || l_tbl_rec.compiled_attribute_column_name;
   l_sql := l_sql || ' from ' || l_tbl_rec.application_table_name || ' where ';

   fnd_dsql.init;
   fnd_dsql.add_text(l_sql);

   --
   -- The where clause needs to be surrounded by parentheses so we can
   -- add additional restrictions using AND without overriding ORs inside it.
   --
   IF (l_sql_pieces.COUNT > 0) THEN
      fnd_dsql.add_text('(');

      FOR i IN 1 .. l_sql_pieces.COUNT LOOP
         IF (l_sql_pieces(i).piece_type = SSP_PIECE_TYPE_BIND) THEN
            fnd_dsql.add_bind(l_sql_pieces(i).bind_value);
          ELSE
            fnd_dsql.add_text(l_sql_pieces(i).piece_text);
         END IF;
      END LOOP;

      fnd_dsql.add_text(') and ');
   END IF;

   -- Build comparison appropriate for data type of value or id column
   --
   if(p_is_value) THEN
      fnd_dsql.add_text(l_tbl_rec.value_column_name || ' = ');
      x_compare_clause(l_tbl_rec.value_column_type, l_tbl_rec.value_column_name, p_charval,
                       VC_VALUE, p_vs_info.vsformat, p_vs_info.maxsize);
    else
      fnd_dsql.add_text(l_tbl_rec.id_column_name || ' = ');
      x_compare_clause(l_tbl_rec.id_column_type, l_tbl_rec.id_column_name, p_charval,
                       VC_ID, p_vs_info.vsformat, p_vs_info.maxsize);
   end if;


   --  Select the value from the user's table.
   --
   l_nrecords := x_dsql_select(8, l_results);

   if(l_nrecords > 0) then
      x_found_value.format := p_vs_info.vsformat;
      x_found_value.stored_value := l_results(1);
      x_found_value.hidden_id := l_results(2);
      x_found_value.description := l_results(3);
      x_found_value.enabled_flag := l_results(4);
      x_found_value.start_valid := to_date(l_results(5),'YYYY/MM/DD HH24:MI:SS');
      x_found_value.end_valid := to_date(l_results(6),'YYYY/MM/DD HH24:MI:SS');
      x_found_value.summary_flag := l_results(7);
      x_found_value.compiled_attributes := l_results(8);
      return(FF_VVALID);
    elsif(l_nrecords = 0) then
      return(FF_VNOTFOUND);
    else
      return(FF_VERROR);
   end if;

   return(FF_VERROR);

EXCEPTION
   WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG', 'table_validate() exception:  ' || SQLERRM);
      return(FF_VERROR);

END table_validate;

/* ----------------------------------------------------------------------- */
/*      Returns the default value for this segment in displayed format.    */
/*      For defaulting current date and current time into non-translatable */
/*      date value sets, use the format based on the maximum size of the   */
/*      value set field alone.                                             */
/*      Let ordinary value validation catch problems with the format       */
/*      or length of the defaulted value.  Returns FF_VVALID if default    */
/*      succeeded, FF_VUNKNOWN if unsupported or FF_VERROR.                */
/* ----------------------------------------------------------------------- */
FUNCTION default_val(def_type         IN  VARCHAR2,
                     def_text         IN  VARCHAR2,
                     valset_fmt       IN  VARCHAR2,
                     valset_len       IN  NUMBER,
                     valset_precis    IN  NUMBER,
                     valset_lettersok IN VARCHAR2,
                     seg_name         IN  VARCHAR2,
                     nprev            IN  NUMBER,
                     prev_dispvals    IN  ValueArray,
                     prev_vals        IN  ValueArray,
                     prev_ids         IN  ValueIdArray,
                     prev_descs       IN  ValueDescArray,
                     prev_segnames    IN  SegNameArray,
                     prev_vsnames     IN  VsNameArray,
                     displayed_val    OUT nocopy VARCHAR2)
  RETURN VARCHAR2 IS
     nfound        NUMBER;
     v_code        VARCHAR2(1);
     datefmt       VARCHAR2(30);
     stored_val    VARCHAR2(1000);
     sql_string    VARCHAR2(2000);
     l_sql_pieces  sql_pieces_tab_type;
BEGIN
   v_code := FF_VERROR;

   IF (def_type is null) then
      v_code := FF_VVALID;
    ELSIF (def_type = 'C') then
      --  Constant
      stored_val := SUBSTRB(def_text, 1, 1000);
      v_code := FF_VVALID;

    ELSIF (def_type = 'D') then
      -- Current date.
      IF (valset_fmt in ('X', 'Y')) then
         datefmt := stored_date_format(valset_fmt, valset_len);
       ELSIF (valset_len >= 11) then
         datefmt := stored_date_format('D', 11);
       else
         datefmt := stored_date_format('D', 9);
      end if;
      stored_val := to_char(sysdate, datefmt);
      v_code := FF_VVALID;

    ELSIF (def_type = 'T') then
      -- Current time or date-time depending on the size
      IF (valset_fmt in ('Y', 'Z')) then
         datefmt := stored_date_format(valset_fmt, valset_len);
       ELSIF (valset_len < 8) then
         datefmt := stored_date_format('I', 5);
       ELSIF (valset_len between 8 and 14) then
         datefmt := stored_date_format('I', 8);
       ELSIF (valset_len between 15 and 16) then
         datefmt := stored_date_format('T', 15);
       ELSIF (valset_len = 17) then
         datefmt := stored_date_format('T', 17);
       ELSIF (valset_len between 18 and 19) then
         datefmt := stored_date_format('T', 18);
       else
         datefmt := stored_date_format('T', 20);
      end if;
      stored_val := to_char(sysdate, datefmt);
      v_code := FF_VVALID;

    ELSIF (def_type = 'P') then
      sql_string := ':$PROFILES$.' || def_text;
      v_code := convert_bind_token(sql_string, nprev,
                                   prev_dispvals, prev_vals,
                                   prev_ids, prev_descs,
                                   prev_segnames, prev_vsnames,
                                   stored_val);

    ELSIF ((def_type = 's') OR (def_type = 'A')) then
      sql_string := ':$FLEX$.' || def_text;
      v_code := convert_bind_token(sql_string, nprev,
                                   prev_dispvals, prev_vals,
                                   prev_ids, prev_descs,
                                   prev_segnames, prev_vsnames,
                                   stored_val);

    ELSIF (def_type = 'S') then
      -- SQL statement
      v_code := substitute_flex_binds3(def_text, nprev,
                                       prev_dispvals, prev_vals,
                                       prev_ids, prev_descs,
                                       prev_segnames, prev_vsnames,
                                       l_sql_pieces);
      IF (v_code = FF_VVALID) THEN
         fnd_dsql.init;

         FOR i IN 1 .. l_sql_pieces.COUNT LOOP
            IF (l_sql_pieces(i).piece_type = SSP_PIECE_TYPE_BIND) THEN
               fnd_dsql.add_bind(l_sql_pieces(i).bind_value);
             ELSE
               fnd_dsql.add_text(l_sql_pieces(i).piece_text);
            END IF;
         END LOOP;

         nfound := x_dsql_select_one(stored_val);
         IF (nfound > 1) then
            FND_MESSAGE.set_name('FND', 'FLEX-DFLT MULTIPLE SQL ROWS');
            FND_MESSAGE.set_token('SQLSTR', SUBSTRB(fnd_dsql.get_text(FALSE), 1, 1000));
            v_code := FF_VERROR;
          ELSIF (nfound < 0) then
            v_code := FF_VERROR;
          else
            --Bug 20987882
            -- If the default sql statement returns a
            -- date value, convert it to a canonical format.
            -- The following code expects date to be in
            -- canonical (storage) format.
            if(valset_fmt in ('X', 'Y', 'Z')) then
                stored_val :=FND_DATE.date_to_canonical(stored_val);
            end if;
            v_code := FF_VVALID;
         end if;
      end if;

    ELSIF (def_type = 'F') then
      -- 'F' => :block.field (the colon may or may not be in the def_text string)
      FND_MESSAGE.set_name('FND', 'FLEX-SSV UNSUPPORTED DEFAULT');
      v_code := FF_VUNKNOWN;

    ELSIF (def_type = 'E') then
      -- Environment variable
      FND_MESSAGE.set_name('FND', 'FLEX-SSV UNSUPPORTED DEFAULT');
      v_code := FF_VUNKNOWN;

    ELSE
      -- Unknown type.
      FND_MESSAGE.set_name('FND', 'FLEX-INVALID DEFAULT TYPE');
      FND_MESSAGE.set_token('SEGNAME', seg_name);
      v_code := FF_VERROR;

   END IF;

   IF (v_code = FF_VVALID) then
      v_code := stored_to_displayed(valset_fmt, valset_len, valset_precis,
                                    valset_lettersok,
                                    stored_val, displayed_val);
   end if;
   return(v_code);
EXCEPTION
   WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG', 'default_val() exception:  ' || SQLERRM);
      return(FF_VERROR);
END default_val;

/* ------------------------------------------------------------------------- */
/*      Interprets $PROFILES$ in where token passed into FND_KEY_FLEX.DEFINE */
/*      This cannot take $FLEX$, and :block.field is unsupported.            */
/*      Returns Validataion error codes VV_VALID if ok, VV_UNSUPPORTED       */
/*      if unsupported, or VV_ERROR if other error.                          */
/* ------------------------------------------------------------------------- */

FUNCTION parse_where_token(clause_in  IN  VARCHAR2,
                          clause_out OUT nocopy VARCHAR2) RETURN NUMBER IS
vcode         VARCHAR2(1);
dummy_dispvls ValueArray;
dummy_vals    ValueArray;
dummy_ids     ValueIdArray;
dummy_descs   ValueDescArray;
dummy_segname SegNameArray;
dummy_vsnames VsNameArray;
     l_sql_pieces  sql_pieces_tab_type;

BEGIN

if(clause_in is not null) then
  if(INSTR(clause_in, ':$FLEX$') > 0) then
    FND_MESSAGE.set_name('FND', 'FLEX-NO FLEX IN WHERE TOKEN');
    return(VV_ERROR);
  end if;
  vcode := substitute_flex_binds3(clause_in, 0,
                                  dummy_dispvls, dummy_vals,
                                  dummy_ids, dummy_descs,
                                  dummy_segname, dummy_vsnames,
                                  l_sql_pieces);

  clause_out := NULL;
  IF (vcode = FF_VVALID) THEN
     FOR i IN 1 .. l_sql_pieces.COUNT LOOP
        IF (l_sql_pieces(i).piece_type = SSP_PIECE_TYPE_BIND) THEN
           clause_out := clause_out ||
             string_clause(l_sql_pieces(i).bind_value);

         ELSE
           clause_out := clause_out ||
             l_sql_pieces(i).piece_text;
        END IF;
     END LOOP;
  END IF;

  if(vcode = FF_VVALID) then
    return(VV_VALID);
  elsif(vcode = FF_VUNKNOWN) then
    return(VV_UNSUPPORTED);
  else
    return(VV_ERROR);
  end if;
end if;
return(VV_VALID);

EXCEPTION
  WHEN OTHERS then
    FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
    FND_MESSAGE.set_token('MSG', 'parse_where_token() exception: '||SQLERRM);
    return(VV_ERROR);

END parse_where_token;

/* ------------------------------------------------------------------------ */
/*      Takes input string possibly containing special flex bind variables  */
/*      of :$PROFILES$.<profile>, :$FLEX$.<name>[.<output>] or :block.field */
/*      and substitutes the flex values for them.  Some substitutions such  */
/*      as :block.field cannot be handled on the server and results in an   */
/*      FF_VUNKNOWN being returned.                                         */
/*                                                                          */
/*      Input string can contain quoted regions, within which no            */
/*      substitutions should be performed.  The regions are marked by       */
/*      single quotes.  Double quotes within these regions represent        */
/*      the quote character.                                                */
/*                                                                          */
/*       Limitations:  string_in, string_out up to 30,000 bytes.            */
/*                     bind_token and bind_value up to 2000 bytes.          */
/*                                                                          */
/*      Returns FF_VVALID if default succeeded, FF_VUNKNOWN if unsupported  */
/*      or FF_VERROR on error.                                              */
/* ------------------------------------------------------------------------ */
FUNCTION substitute_flex_binds3(p_string_in     IN VARCHAR2,
                                p_nprev         IN NUMBER,
                                p_prev_dispvals IN ValueArray,
                                p_prev_vals     IN ValueArray,
                                p_prev_ids      IN ValueIdArray,
                                p_prev_descs    IN ValueDescArray,
                                p_prev_segnames IN SegNameArray,
                                p_prev_vsnames  IN VsNameArray,
                                px_sql_pieces   in out nocopy sql_pieces_tab_type)
  RETURN VARCHAR2
  IS
     v_code        VARCHAR2(1);
BEGIN
   IF (fnd_flex_server1.g_debug_level > 0) THEN
      add_debug('BEGIN SV1.substitute_flex_binds3('''||
                SUBSTRB(p_string_in, 1, 500) || ''' ');
   END IF;

   BEGIN
      parse_sql_string(p_string_in, px_sql_pieces);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(FF_VERROR);
   END;

   --
   -- Derive bind values
   --
   FOR i IN 1 .. px_sql_pieces.COUNT LOOP
      IF (px_sql_pieces(i).piece_type = SSP_PIECE_TYPE_BIND) THEN
         v_code := convert_bind_token(px_sql_pieces(i).piece_text,
                                      p_nprev, p_prev_dispvals,
                                      p_prev_vals, p_prev_ids, p_prev_descs,
                                      p_prev_segnames, p_prev_vsnames,
                                      px_sql_pieces(i).bind_value);

         IF (v_code <> FF_VVALID) then
            return(v_code);
         end if;
      END IF;
   END LOOP;

   return(FF_VVALID);

EXCEPTION
   WHEN OTHERS then
      IF (fnd_flex_server1.g_debug_level > 0) THEN
         add_debug('EXCEPTION SV1.substitute_flex_binds3()');
      END IF;
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG', 'substitute_flex_binds3() exception:  '
                            || SQLERRM);
      return(FF_VERROR);
END substitute_flex_binds3;

--
-- The one with extension support.
--
/* ------------------------------------------------------------------------ */
FUNCTION substitute_flex_binds5(p_string_in     IN VARCHAR2,
                                p_str_info      IN FlexStructId,
                                p_seg_info      IN SegmentInfo,
                                p_vdate         IN DATE,
                                p_parent_value  IN VARCHAR2,
                                p_nprev         IN NUMBER,
                                p_prev_dispvals IN ValueArray,
                                p_prev_vals     IN ValueArray,
                                p_prev_ids      IN ValueIdArray,
                                p_prev_descs    IN ValueDescArray,
                                p_prev_segnames IN SegNameArray,
                                p_prev_vsnames  IN VsNameArray,
                                px_sql_pieces   in out nocopy sql_pieces_tab_type)
  RETURN VARCHAR2
  IS
     v_code        VARCHAR2(1);
BEGIN
   IF (fnd_flex_server1.g_debug_level > 0) THEN
      add_debug('BEGIN SV1.substitute_flex_binds5('''||
                SUBSTRB(p_string_in, 1, 500) || ''' ');
   END IF;

   BEGIN
      parse_sql_string(p_string_in, px_sql_pieces);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(FF_VERROR);
   END;

   --
   -- Derive bind values
   --
   FOR i IN 1 .. px_sql_pieces.COUNT LOOP
      IF (px_sql_pieces(i).piece_type = SSP_PIECE_TYPE_BIND) THEN
         v_code := convert_bind_token2(px_sql_pieces(i).piece_text,
                                       p_str_info, p_seg_info,
                                       p_vdate, p_parent_value,
                                       p_nprev, p_prev_dispvals,
                                       p_prev_vals, p_prev_ids, p_prev_descs,
                                       p_prev_segnames, p_prev_vsnames,
                                       px_sql_pieces(i).bind_value);

         IF (v_code <> FF_VVALID) then
            return(v_code);
         end if;
      END IF;
   END LOOP;

   return(FF_VVALID);

EXCEPTION
   WHEN OTHERS then
      IF (fnd_flex_server1.g_debug_level > 0) THEN
         add_debug('EXCEPTION SV1.substitute_flex_binds5()');
      END IF;
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG', 'substitute_flex_binds5() exception:  '
                            || SQLERRM);
      return(FF_VERROR);
END substitute_flex_binds5;

/* ----------------------------------------------------------------------- */
/*      Converts a flex bind token to its character string value.          */
/*      Bind tokens begin with a colon and are of the form:                */
/*      :$FLEX$.<vsname>[.<portion>] or :$PROFILES$.<profile_name>         */
/*      If [.<portion>] not specified uses the ID not the VALUE.           */
/*      Note server can never handle :BLOCK.FIELD                          */
/*      Returns FF_VVALID if substitution succeeded, FF_VUNKNOWN if        */
/*      unsupported or FF_VERROR on error.                                 */
/* ----------------------------------------------------------------------- */
FUNCTION convert_bind_token(bind_token    IN  VARCHAR2,
                            nprev         IN  NUMBER,
                            prev_dispvals IN  ValueArray,
                            prev_vals     IN  ValueArray,
                            prev_ids      IN  ValueIdArray,
                            prev_descs    IN  ValueDescArray,
                            prev_segnames IN  SegNameArray,
                            prev_vsnames  IN  VsNameArray,
                            bind_value    OUT nocopy VARCHAR2)
  RETURN VARCHAR2
  IS
     bind_val      VARCHAR2(2000);
     seg_name      VARCHAR2(60);
     seg_portion   VARCHAR2(30);
     dot_pointer   NUMBER;
     col_pointer   NUMBER;
     l_length      NUMBER;
     s_index       BINARY_INTEGER;
     l_return_code VARCHAR2(100);

BEGIN
   --  Determine character string value of bind token.
   -- :$PROFILES$.<name> where <name> is case-insensitive profile option name.
   -- :$FLEX$.<name>[.<portion>] where name is case-sensitive, but portion not.
   -- :BLOCK.FIELD causes return of FF_VUNKNOWN error.
   --
   IF (fnd_flex_server1.g_debug_level > 0) THEN
      add_debug('BEGIN SV1.convert_bind_token(token=' || bind_token || ')');
   END IF;

   IF (INSTR(bind_token, ':$PROFILES$.') = 1) then
      FND_PROFILE.get(UPPER(SUBSTR(bind_token, 13)), bind_val);

    ELSIF (INSTR(bind_token, ':$FLEX$.') = 1) then

      -- If default segment name is of the form <name>.ID, <name>.VALUE
      -- or <name>.MEANING, then break it into seg_name and seg_portion.
      -- Note ID, VALUE and MEANING are all case insensitive
      --
      -- Bug 1783461: Flexfield API does not handle :NULL suffix.
      -- the original code did not strip off the variables after the value set/
      -- or segment name and when used resulted in a "ORA-20001 The data that
      -- defines the flexfield may be inconsistent".
      -- The syntax for using bind variables in the default where clause of a
      -- value set is as follows (for $FLEX$);
      --
      --    :$FLEX$.[valuesetname|segmentname][.ID|.VALUE|.MEANING][:NULL]

      dot_pointer := INSTR(bind_token, '.', 9);
      col_pointer := INSTR(bind_token,':NULL',9);
      l_length := length(bind_token);
      if (dot_pointer > 0) then
         if (col_pointer > 0) then
            null;
          else
            col_pointer := l_length + 1;
         end if;
       else
         if (col_pointer > 0) then
            dot_pointer := col_pointer;
          else
            dot_pointer := l_length + 1;
            col_pointer := l_length + 1;
         end if;
      end if;

      if (dot_pointer > col_pointer) then
         FND_MESSAGE.set_name('FND','FLEX-INVALID PORTION');
         FND_MESSAGE.set_token('BTOKEN',bind_token);
         l_return_code := FF_VERROR;
         GOTO goto_return;
      end if;

      seg_name := SUBSTR(bind_token,9,dot_pointer-9);
      seg_portion := SUBSTR(bind_token,dot_pointer+1,col_pointer-dot_pointer-1);

      if (seg_portion is null) then
         seg_portion := 'ID';
      end if;

      -- Find index to previous segment or 0 if previous segment not found.
      -- Previous segment value set name or segment name.
      --
      s_index := 0;
      for i in reverse 1..nprev loop
         if((prev_segnames(i) = seg_name) or (prev_vsnames(i) = seg_name)) then
            s_index := i;
            exit;
         end if;
      end loop;

      -- Copy value, id or meaning to output if found, otherwise error.
      --
      if(s_index > 0) then
         if(seg_portion = 'VALUE') then
            bind_val := prev_vals(s_index);
          elsif(seg_portion = 'ID') then
            bind_val := prev_ids(s_index);
          elsif(seg_portion = 'MEANING') then
            bind_val := prev_descs(s_index);
          else
            FND_MESSAGE.set_name('FND', 'FLEX-INVALID PORTION');
            FND_MESSAGE.set_token('BTOKEN', bind_token);
            l_return_code := FF_VERROR;
            GOTO goto_return;
         end if;
       else
         FND_MESSAGE.set_name('FND', 'FLEX-PRIOR SEG NOTFOUND');
         FND_MESSAGE.set_token('BTOKEN', bind_token);
         l_return_code := FF_VERROR;
         GOTO goto_return;
      end if;

    else

      -- :BLOCK.FIELD cannot be handled here
      --
      FND_MESSAGE.set_name('FND', 'FLEX-UNSUPPORTED FLEX BIND');
      l_return_code := FF_VUNKNOWN;
      GOTO goto_return;

   end if;

   bind_value := bind_val;
   l_return_code := FF_VVALID;

   <<goto_return>>
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        add_debug('END SV1.convert_bind_token(value=' || bind_val || ')');
     END IF;
     RETURN(l_return_code);
EXCEPTION
   WHEN OTHERS then
      IF (fnd_flex_server1.g_debug_level > 0) THEN
         add_debug('EXCEPTION others SV1.convert_bind_token()');
      END IF;
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG','convert_bind_token() exception: '||SQLERRM);
      return(FF_VERROR);
END convert_bind_token;

--
-- The one with extension support.
--
FUNCTION convert_bind_token2(p_bind_token    IN  VARCHAR2,
                             p_str_info      IN  FlexStructId,
                             p_seg_info      IN  SegmentInfo,
                             p_vdate         IN  DATE,
                             p_parent_value  IN  VARCHAR2,
                             p_nprev         IN  NUMBER,
                             p_prev_dispvals IN  ValueArray,
                             p_prev_vals     IN  ValueArray,
                             p_prev_ids      IN  ValueIdArray,
                             p_prev_descs    IN  ValueDescArray,
                             p_prev_segnames IN  SegNameArray,
                             p_prev_vsnames  IN  VsNameArray,
                             x_bind_value    OUT nocopy VARCHAR2)
  RETURN VARCHAR2
  IS
     l_bind_value  VARCHAR2(2000);
     l_return_code VARCHAR2(100);

BEGIN
   IF (fnd_flex_server1.g_debug_level > 0) THEN
      add_debug('BEGIN SV1.convert_bind_token2(bind=' || p_bind_token || ')');
   END IF;

   l_bind_value := NULL;
   IF (p_bind_token = ':$FLEX$.$VDATE$') THEN
      IF (p_vdate IS NULL) THEN
         l_bind_value := NULL;
       ELSE
         l_bind_value := To_char(p_vdate, 'YYYY/MM/DD HH24:MI:SS');
      END IF;

    ELSIF (p_bind_token = ':$FLEX$.$APPLICATION_ID$') THEN
      l_bind_value := p_str_info.application_id;

    ELSIF (p_bind_token = ':$FLEX$.$ID_FLEX_CODE$') THEN
      IF (p_str_info.isa_key_flexfield) THEN
         l_bind_value := p_str_info.id_flex_code;
      END IF;

    ELSIF (p_bind_token = ':$FLEX$.$ID_FLEX_NUM$') THEN
      IF (p_str_info.isa_key_flexfield) THEN
         l_bind_value := p_str_info.id_flex_num;
      END IF;

    ELSIF (p_bind_token = ':$FLEX$.$APPLICATION_COLUMN_NAME$') THEN
      l_bind_value := p_seg_info.colname;

    ELSIF (p_bind_token = ':$FLEX$.$VALUE_SET_ID$') THEN
      l_bind_value := p_seg_info.vsid;

    ELSIF (p_bind_token = ':$FLEX$.$PARENT_VALUE$') THEN
      l_bind_value := p_parent_value;

    ELSE
      l_return_code := convert_bind_token(p_bind_token, p_nprev,
                                          p_prev_dispvals, p_prev_vals,
                                          p_prev_ids, p_prev_descs,
                                          p_prev_segnames, p_prev_vsnames,
                                          x_bind_value);
      GOTO goto_return;
   END IF;

   x_bind_value := l_bind_value;
   l_return_code := FF_VVALID;

   <<goto_return>>
   IF (fnd_flex_server1.g_debug_level > 0) THEN
      add_debug('END SV1.convert_bind_token2(value=' || l_bind_value || ')');
   END IF;
   RETURN(l_return_code);
EXCEPTION
   WHEN OTHERS then
      IF (fnd_flex_server1.g_debug_level > 0) THEN
         add_debug('EXCEPTION others SV1.convert_bind_token2()');
      END IF;
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG','convert_bind_token2() exception: '||SQLERRM);
      return(FF_VERROR);
END convert_bind_token2;

/* ----------------------------------------------------------------------- */
/*      Checks vrules.  Returns TRUE and sets error message if any are     */
/*      violated.  Checks rules in forward order for compatibility with    */
/*      C code.  Also checks SUMMARY_FLAG.                                 */
/* ----------------------------------------------------------------------- */
FUNCTION check_vrules(vrs     IN Vrules,
                      sqs     IN Qualifiers,
                      sumflg  IN VARCHAR2) RETURN VARCHAR2 IS

  testval     VARCHAR2(245);

BEGIN

--  Check vrules in forward order for compatibility with C code.
--
  for i in 1..vrs.nvrules loop
    if((vrs.fq_names(i) is null) and (vrs.sq_names(i) = 'SUMMARY_FLAG')) then
      testval := SEPARATOR || sumflg || SEPARATOR;
      if(INSTR(vrs.cat_vals(i), testval) > 0) then
        if(vrs.ie_flags(i) = 'E') then
          value_error_name(vrs.app_names(i), vrs.err_names(i));
          return(FF_VVRULE);
        end if;
      else
        if(vrs.ie_flags(i) = 'I') then
          value_error_name(vrs.app_names(i), vrs.err_names(i));
          return(FF_VVRULE);
        end if;
      end if;
    else
      for j in 1..sqs.nquals loop
        if((vrs.sq_names(i) = sqs.sq_names(j)) and
           (vrs.fq_names(i) = sqs.fq_names(j))) then
          testval := SEPARATOR || sqs.sq_values(j) || SEPARATOR;
          if((vrs.cat_vals(i) is not null) and
              (INSTR(vrs.cat_vals(i), testval) > 0)) then
            if(vrs.ie_flags(i) = 'E') then
              value_error_name(vrs.app_names(i), vrs.err_names(i));
              return(FF_VVRULE);
            end if;
          else
            if(vrs.ie_flags(i) = 'I') then
              value_error_name(vrs.app_names(i), vrs.err_names(i));
              return(FF_VVRULE);
            end if;
          end if;
        end if;
      end loop;
    end if;
  end loop;

  return(FF_VVALID);

  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG', 'check_vrules() exception: ' || SQLERRM);
      return(FF_VERROR);

END check_vrules;

/* ----------------------------------------------------------------------- */
/*      Checks vrules on combinations based on the qualifiers in the       */
/*      combinations table.  This function is external to this file being  */
/*      called from AFFFSSVB.pls.                                          */
/*      Returns VV_VALID if all rules pass, or VV_VALUES or VV_ERROR and   */
/*      sets message name if any rules violated.                           */
/* ----------------------------------------------------------------------- */

FUNCTION check_comb_vrules(vrs    IN  Vrules,
                           sqs    IN  Qualifiers,
                           sumflg IN  VARCHAR2) RETURN NUMBER IS
v_code    VARCHAR2(1);
retcode   NUMBER;

BEGIN

--  First must initialize the value errors since we always want to display
--  the error if any rule violated.
--
  value_error_init;

--  Now call function above to check the rules.
--
  v_code := check_vrules(vrs, sqs, sumflg);
  if(v_code = FF_VVALID) then
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        add_debug(' Combination passed vrules. ');
     END IF;
    retcode := VV_VALID;
  elsif(v_code = FF_VVRULE) then
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        add_debug(' Combination failed vrules. ');
     END IF;
    retcode := VV_VALUES;
  else
    retcode := VV_ERROR;
  end if;

  return(retcode);

  EXCEPTION
    WHEN OTHERS then
     FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
     FND_MESSAGE.set_token('MSG','check_comb_vrules() exception: '||SQLERRM);
     return(VV_ERROR);

END check_comb_vrules;

/* ----------------------------------------------------------------------- */
/*      Checks value security rules for any which are violated.            */
/*      Returns status codes of FF_VVALID if no security rule violated,    */
/*      FF_VSECURED if security violated, or FF_VERROR if some error       */
/*      checking security.                                                 */
/*      If security is violated a value error message is added             */
/*      only if set_message is TRUE.                                       */
/* ----------------------------------------------------------------------- */

FUNCTION check_security(val          IN VARCHAR2,
                        valfmt       IN VARCHAR2,
                        parentval    IN VARCHAR2,
                        user_apid    IN NUMBER,
                        user_respid  IN NUMBER,
                        vsinfo       IN ValueSetInfo,
                        set_message  IN BOOLEAN) RETURN VARCHAR2 IS

  bufstr      VARCHAR2(500);
  rulemsgbuf  VARCHAR2(240);
  nfound      NUMBER;
  l_vsc_code  VARCHAR2(10);
  l_return_code VARCHAR2(10);
  l_security_status VARCHAR2(2000);
  l_error_message   VARCHAR2(2000);
BEGIN
   IF (fnd_flex_server1.g_debug_level > 0) THEN
      add_debug('BEGIN SV1.check_security()');
   END IF;

--
-- Return immediately if user info is not set.
--
 IF ((user_apid = -1) AND (user_respid = -1)) THEN
    RETURN(FF_VVALID);
 END IF;
--
-- First check the VSC
--
   l_vsc_code :=  check_vsc(user_apid, user_respid, vsinfo.vsid,
                            parentval, val, l_return_code);
   IF (l_vsc_code IN (fnd_plsql_cache.CACHE_VALID,
                      fnd_plsql_cache.CACHE_INVALID)) THEN
      IF (fnd_flex_server1.g_debug_level > 0) THEN
         add_debug('Found in vsc.');
      END IF;
      GOTO label_return;
   END IF;

   --
   -- l_vsc_code is either CACHE_NOTFOUND.
   -- Continue on security check.
   --
     l_return_code := FF_VVALID;

     fnd_flex_server.check_value_security
       (p_security_check_mode   => 'YH',
        p_flex_value_set_id     => vsinfo.vsid,
        p_parent_flex_value     => parentval,
        p_flex_value            => val,
        p_resp_application_id   => user_apid,
        p_responsibility_id     => user_respid,
        x_security_status       => l_security_status,
        x_error_message         => l_error_message);
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        add_debug('Hierarchy security: status :'||l_security_status || ' message : ' || l_error_message);
     END IF;

     IF (l_security_status <> 'NOT-SECURED') THEN
        IF (set_message) THEN
           value_error_name('FND', 'FLEX-USER DEFINED ERROR');
           value_error_token('MSG', l_error_message);
        END IF;
        l_return_code := FF_VSECURED;
        GOTO label_return;
     END IF;

     GOTO label_return;


  <<label_return>>
    IF (l_vsc_code IN (fnd_plsql_cache.CACHE_NOTFOUND)) THEN
       update_vsc(user_apid, user_respid, vsinfo.vsid,
                  parentval, val, l_return_code);
    END IF;
    IF (fnd_flex_server1.g_debug_level > 0) THEN
       add_debug('END SV1.check_security()');
    END IF;
    RETURN(l_return_code);
  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG','check_security() exception: ' || SQLERRM);
      IF (fnd_flex_server1.g_debug_level > 0) THEN
         add_debug('EXCEPTION SV1.check_security()');
      END IF;

      return(FF_VERROR);

END check_security;

/* ----------------------------------------------------------------------- */
/*      Checks to see whether this segment is displayed.                   */
/*      Returns displayed_flag as output.                                  */
/*      Returns TRUE on success or FALSE if error or exception.            */
/* ----------------------------------------------------------------------- */

FUNCTION check_displayed(segindex     IN  NUMBER,
                         disp_tokmap  IN  DisplayedSegs,
                         d_flag       OUT nocopy BOOLEAN) RETURN BOOLEAN IS

BEGIN

  d_flag := disp_tokmap.segflags(segindex);
  return(TRUE);

  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG','check_displayed() exception: ' ||SQLERRM);
      return(FALSE);

END check_displayed;

/* ----------------------------------------------------------------------- */
/*      Interprets the compiled value attribute (CVA) string and returns   */
/*      segment qualifier values.  From the value set id looks up all      */
/*      qualifiers which might be associated with this value set and       */
/*      orders them in the same order as they are stored in the CVA        */
/*      string.  Then interprets the CVA string.  For each qualifier       */
/*      associated with this flexfield segment, the default qualifier value*/
/*      is overwritten by the value from the CVA string if the CVA string  */
/*      contains a non-null value.  Returns the updated qualifier values   */
/*      array and number of qualifier values found or < 0 if error.        */
/*      No qualifier values for descriptive flexfields.                    */
/*                                                                         */
/*      Note:  Do not order by segment_attribute_type as this causes       */
/*      GL_ACCOUNT/GL_ACCOUNT_TYPE to appear before GL_GLOBAL/DETAIL...    */
/*      instead of after it as is the case in the client code.             */
/* ----------------------------------------------------------------------- */
FUNCTION qualifier_values(ffstruct       IN  FlexStructId,
                          valset_id      IN  NUMBER,
                          cvas           IN  VARCHAR2,
                          nqualifs       IN  NUMBER,
                          fqnames        IN  QualNameArray,
                          sqnames        IN  QualNameArray,
                          sqvals         IN OUT nocopy ValAttribArray) RETURN NUMBER IS

  cva_index           NUMBER;
  n_value_attributes  NUMBER;
  value_attributes    StringArray;
  l_vsq_code          VARCHAR2(200);
  i                   NUMBER;

  CURSOR CVA_Cursor(vs_id IN NUMBER) IS
    SELECT id_flex_application_id fapid, id_flex_code fcode,
           segment_attribute_type fqname, value_attribute_type sqname
      FROM fnd_flex_validation_qualifiers
     WHERE flex_value_set_id = vs_id
  ORDER BY assignment_date, id_flex_application_id, id_flex_code,
           value_attribute_type;
  vq  cva_cursor%ROWTYPE;
BEGIN
--  Quickly handle case where there are no qualifiers. (eg Descr flex)
--
  if((not ffstruct.isa_key_flexfield) or (nqualifs = 0)) then
    return(0);
  end if;

--  Convert compiled value attributes to array.
  --
  IF (cvas IS NOT NULL) THEN
     n_value_attributes := to_stringarray2(cvas, NEWLINE, value_attributes);
   ELSE
     n_value_attributes := 0;
  END IF;

--  Set returned segment qualifier values to defaults
--
--    for i in 1..nqualifs loop
--      sqvals(i) := default_sqvals(i);
--    end loop;

--  cva_index is position of the value attribute in the CVA string.
--
  cva_index := 0;

--  CVA_Cursor returns the flexfields and names of the attibutes associated
--  with this value set in the order that they are stored in the cva string.
--

  g_cache_key := valset_id;

  fnd_plsql_cache.generic_1tom_get_values(vsq_cache_controller,
                                          vsq_cache_storage,
                                          g_cache_key,
                                          g_cache_numof_values,
                                          g_cache_values,
                                          g_cache_return_code);

  IF (g_cache_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
     NULL;
   ELSE
     i := 0;
     FOR vq IN cva_cursor(valset_id) LOOP
        i := i + 1;
        fnd_plsql_cache.generic_cache_new_value
          (x_value      => g_cache_value,
           p_number_1   => vq.fapid,
           p_varchar2_1 => vq.fcode,
           p_varchar2_2 => vq.fqname,
           p_varchar2_3 => vq.sqname);
        g_cache_values(i) := g_cache_value;
     END LOOP;
     g_cache_numof_values := i;

     fnd_plsql_cache.generic_1tom_put_values(vsq_cache_controller,
                                                  vsq_cache_storage,
                                                  g_cache_key,
                                                  g_cache_numof_values,
                                                  g_cache_values);
  END IF;

  FOR ii IN 1..g_cache_numof_values LOOP
     vq.fapid  := g_cache_values(ii).number_1;
     vq.fcode  := g_cache_values(ii).varchar2_1;
     vq.fqname := g_cache_values(ii).varchar2_2;
     vq.sqname := g_cache_values(ii).varchar2_3;

--    for vq in CVA_Cursor(valset_id) loop
     cva_index := cva_index + 1;

--  If the selected attribute applies to the flexfied under consideration
--  then find the attribute by name in the list of those which apply to this
--  segment and replace its default value with the appropriate value from
--  the cva string.
--
    if((vq.fapid = ffstruct.application_id) and
       (vq.fcode = ffstruct.id_flex_code)) then
      for i in 1..nqualifs loop
        if((vq.fqname = fqnames(i)) and (vq.sqname = sqnames(i)) and
           (cva_index <= n_value_attributes)) then
            sqvals(i) := value_attributes(cva_index);
        end if;
      end loop;
    end if;
  end loop;

  return(cva_index);

EXCEPTION
  WHEN OTHERS then
    FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
    FND_MESSAGE.set_token('MSG', 'qualifier_values() exception:  '||SQLERRM);
    return(-1);

END qualifier_values;

/* ----------------------------------------------------------------------- */
/*      Gets the **enabled** flexfield and segment qualifiers for this     */
/*      segment.  Segment is uniquely determined by combination of         */
/*      flex apid, code, struct num, with the name of the column in the    */
/*      code combinations table which will hold the segment value.         */
/*      No qualifiers enabled for descriptive flexs.                       */
/*                                                                         */
/*      Returns the number of qualifiers found or < 0 if error.            */
/*                                                                         */
/*      Also returns FQ name, SQ name, derived_column, and default value   */
/*      of the segment qualifiers for this segment.                        */
/* ----------------------------------------------------------------------- */
FUNCTION get_qualifiers(ffstruct      IN  FlexStructId,
                        seg_colname   IN  VARCHAR2,
                        seg_quals     OUT nocopy Qualifiers)
  RETURN NUMBER
  IS
     sqcount      NUMBER;

  CURSOR Qual_Cursor(keystruct IN FlexStructId, colname IN VARCHAR2) IS
      SELECT v.segment_attribute_type fq_name,
             v.value_attribute_type sq_name,
             v.application_column_name drv_colname,
             v.default_value dflt_val
        FROM fnd_value_attribute_types v, fnd_segment_attribute_values s
       WHERE v.application_id = s.application_id
         AND v.id_flex_code = s.id_flex_code
         AND v.segment_attribute_type = s.segment_attribute_type
         AND s.application_id = keystruct.application_id
         AND s.id_flex_code = keystruct.id_flex_code
         AND s.id_flex_num = keystruct.id_flex_num
         AND s.application_column_name = colname
         AND s.attribute_value = 'Y';
BEGIN
   IF (fnd_flex_server1.g_debug_level > 0) THEN
      fnd_flex_server1.add_debug('BEGIN SV1.get_qualifiers()');
   END IF;

   sqcount := 0;
   IF (ffstruct.isa_key_flexfield) THEN
      g_cache_key := (ffstruct.application_id || '.' ||
                      ffstruct.id_flex_code || '.' ||
                      ffstruct.id_flex_num || '.' ||
                      seg_colname);

      fnd_plsql_cache.generic_1tom_get_values(fsq_cache_controller,
                                              fsq_cache_storage,
                                              g_cache_key,
                                              g_cache_numof_values,
                                              g_cache_values,
                                              g_cache_return_code);

      IF (g_cache_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
         sqcount := g_cache_numof_values;
       ELSE
         FOR squal IN qual_cursor(ffstruct, seg_colname) LOOP
            sqcount := sqcount + 1;

            fnd_plsql_cache.generic_cache_new_value
              (x_value      => g_cache_value,
               p_varchar2_1 => squal.fq_name,
               p_varchar2_2 => squal.sq_name,
               p_varchar2_3 => squal.dflt_val,
               p_varchar2_4 => squal.drv_colname);
            g_cache_values(sqcount) := g_cache_value;
         END LOOP;
         g_cache_numof_values := sqcount;

         fnd_plsql_cache.generic_1tom_put_values(fsq_cache_controller,
                                                 fsq_cache_storage,
                                                 g_cache_key,
                                                 g_cache_numof_values,
                                                 g_cache_values);
      END IF;

      FOR ii IN 1..sqcount LOOP
         seg_quals.fq_names(ii) := g_cache_values(ii).varchar2_1;
         seg_quals.sq_names(ii) := g_cache_values(ii).varchar2_2;
         seg_quals.sq_values(ii) := g_cache_values(ii).varchar2_3;
         seg_quals.derived_cols(ii) := g_cache_values(ii).varchar2_4;
      END LOOP;
   END IF;

   seg_quals.nquals := sqcount;

   IF (fnd_flex_server1.g_debug_level > 0) THEN
      fnd_flex_server1.add_debug('END SV1.get_qualifiers()');
   END IF;

   RETURN(sqcount);
EXCEPTION
  WHEN OTHERS then
    FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
    FND_MESSAGE.set_token('MSG', 'get_qualifiers() exception:  ' || SQLERRM);
    IF (fnd_flex_server1.g_debug_level > 0) THEN
       fnd_flex_server1.add_debug('EXCEPTION SV1.get_qualifiers()');
    END IF;

    return(-1);

END get_qualifiers;

/* ----------------------------------------------------------------------- */
/*      Gets the value set information for a given value set id.           */
/*      Returns TRUE if found or FALSE and sets error message on error.    */
/* ----------------------------------------------------------------------- */
FUNCTION get_value_set(value_set_id   IN  NUMBER,
                       segment_name   IN  VARCHAR2,
                       vs_info        OUT nocopy ValueSetInfo)
  RETURN BOOLEAN
  IS
     l_vsi  valuesetinfo;
BEGIN
   IF (fnd_flex_server1.g_debug_level > 0) THEN
      fnd_flex_server1.add_debug('CALL SV1.get_value_set(' ||
                                 'vsid:' || value_set_id || ')');
   END IF;

   g_cache_key := value_set_id;
   fnd_plsql_cache.generic_1to1_get_value(vst_cache_controller,
                                          vst_cache_storage,
                                          g_cache_key,
                                          g_cache_value,
                                          g_cache_return_code);

   IF (g_cache_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
      vs_info.vsid        := value_set_id;
      vs_info.parent_vsid := g_cache_value.number_1;
      vs_info.valsecure   := g_cache_value.varchar2_1;
      vs_info.valtype     := g_cache_value.varchar2_2;
      vs_info.vsformat    := g_cache_value.varchar2_3;
      vs_info.maxsize     := g_cache_value.number_2;
      vs_info.lettersok   := g_cache_value.varchar2_4;
      vs_info.capsonly    := g_cache_value.varchar2_5;
      vs_info.zfill       := g_cache_value.varchar2_6;
      vs_info.precis      := g_cache_value.number_3;
      vs_info.minval      := g_cache_value.varchar2_7;
      vs_info.maxval      := g_cache_value.varchar2_8;
      vs_info.vsname      := g_cache_value.varchar2_9;
    ELSE
      SELECT flex_value_set_id, parent_flex_value_set_id,
        security_enabled_flag,
        validation_type, format_type, maximum_size,
        alphanumeric_allowed_flag, uppercase_only_flag,
        numeric_mode_enabled_flag, number_precision, minimum_value,
        maximum_value, flex_value_set_name
        INTO l_vsi
        FROM fnd_flex_value_sets
        WHERE flex_value_set_id = value_set_id;

      fnd_plsql_cache.generic_cache_new_value
        (x_value      => g_cache_value,
         p_number_1   => l_vsi.parent_vsid,
         p_varchar2_1 => l_vsi.valsecure,
         p_varchar2_2 => l_vsi.valtype,
         p_varchar2_3 => l_vsi.vsformat,
         p_number_2   => l_vsi.maxsize,
         p_varchar2_4 => l_vsi.lettersok,
         p_varchar2_5 => l_vsi.capsonly,
         p_varchar2_6 => l_vsi.zfill,
         p_number_3   => l_vsi.precis,
         p_varchar2_7 => l_vsi.minval,
         p_varchar2_8 => l_vsi.maxval,
         p_varchar2_9 => l_vsi.vsname);

      fnd_plsql_cache.generic_1to1_put_value(vst_cache_controller,
                                             vst_cache_storage,
                                             g_cache_key,
                                             g_cache_value);
      vs_info := l_vsi;
   END IF;
   return(TRUE);
EXCEPTION
  WHEN NO_DATA_FOUND then
    FND_MESSAGE.set_name('FND', 'FLEX-VALUE SET NOT FOUND');
    FND_MESSAGE.set_token('SEGMENT', segment_name);
    return(FALSE);
  WHEN OTHERS then
    FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
    FND_MESSAGE.set_token('MSG', 'get_value_set() exception:  ' || SQLERRM);
    return(FALSE);
END get_value_set;

/* ----------------------------------------------------------------------- */
/*      Creates value set information for segment without a value set      */
/*      based on the specification of the column into which it will go.    */
/*      We document that this only works for CHAR or VARCHAR2 type columns.*/
/*      Returns TRUE if ok or FALSE and sets error message on error.       */
/* ----------------------------------------------------------------------- */
FUNCTION virtual_value_set(column_type  IN  VARCHAR2,
                           column_width IN  NUMBER,
                           segment_name IN  VARCHAR2,
                           vs_info      OUT nocopy ValueSetInfo) RETURN BOOLEAN IS
BEGIN

--  Assumes all components of vs_info are initially null
--
  if(column_type in ('C', 'V')) then
    vs_info.valsecure := 'N';
    vs_info.valtype := 'N';
    vs_info.vsformat := 'C';
    vs_info.maxsize := column_width;
    vs_info.lettersok := 'Y';
    vs_info.capsonly := 'N';
    vs_info.zfill := 'N';
    return(TRUE);
  end if;
  FND_MESSAGE.set_name('FND', 'FLEX-VALUE SET REQUIRED');
  FND_MESSAGE.set_token('SEGMENT', segment_name);
  return(FALSE);

EXCEPTION
  WHEN OTHERS then
    FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
    FND_MESSAGE.set_token('MSG','virtual_value_set() exception:  '||SQLERRM);
    return(FALSE);

END virtual_value_set;

/* ----------------------------------------------------------------------- */
/*      Message handler functions for value validation errors.  Needed     */
/*      because value validation does not always stop at the first         */
/*      error encountered.  This handler makes sure that FND_MESSAGE       */
/*      error is set to the first value error if there are no other        */
/*      errors.  For more serious errors, we set the message directly      */
/*      using the FND_MESSAGE package.   Note this assumes the main        */
/*      validate_struct() function knows to stop on the first serious      */
/*      error otherwise we risk overwriting a more serious error with      */
/*      a value error.                                                     */
/*      If the application short name is null, then we use the             */
/*      FLEX-USER DEFINED ERROR to display the message name as text.       */
/*      This is used in check_vrules().                                    */
/* ----------------------------------------------------------------------- */

/* ----------------------------------------------------------------------- */
/*      Initializes value error message global variables.                  */
/* ----------------------------------------------------------------------- */

PROCEDURE value_error_init IS
BEGIN
  value_error_set := FALSE;
  entering_new_message := FALSE;
EXCEPTION
  WHEN OTHERS then
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        add_debug('value_error_init() exception: ' || SQLERRM);
     END IF;
END value_error_init;

/* ------------------------------------------------------------------------ */
/*      Sets error message name if no other value errors have been set.     */
/*      Also sets entering_new_message flag to indicate new message being   */
/*      entered if this is the first value error, otherwise resets it.      */
/* ------------------------------------------------------------------------ */
PROCEDURE value_error_name(appl_sname      IN  VARCHAR2,
                           errmsg_name     IN  VARCHAR2) IS
BEGIN
  if(value_error_set = FALSE) then
    if(appl_sname is null) then
      FND_MESSAGE.set_name('FND', 'FLEX-USER DEFINED ERROR');
      FND_MESSAGE.set_token('MSG', errmsg_name);
    else
      FND_MESSAGE.set_name(appl_sname, errmsg_name);
    end if;
    value_error_set := TRUE;
    entering_new_message := TRUE;
  else
    entering_new_message := FALSE;
  end if;
EXCEPTION
  WHEN OTHERS then
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        add_debug('value_error_name() exception: ' || SQLERRM);
     END IF;
END value_error_name;

/* ----------------------------------------------------------------------- */
/*      Sets error message token if currently entering a new message.      */
/*      Otherwise just ignores the token.  Call only after setting         */
/*      value error name with value_error_name() above.                    */
/* ----------------------------------------------------------------------- */
PROCEDURE value_error_token(token_name   IN  VARCHAR2,
                            token_value  IN  VARCHAR2) IS
BEGIN
  if(entering_new_message) then
    FND_MESSAGE.set_token(token_name, token_value);
  end if;
EXCEPTION
  WHEN OTHERS then
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        add_debug('value_error_token() exception: ' || SQLERRM);
     END IF;
END value_error_token;

/* ----------------------------------------------------------------------- */
/*      Converts the value to be output in an error message from stored    */
/*      format to the displayed format appropriate for the given value set.*/
/*      Returns the value in stored format if any errors encountered.      */
/* ----------------------------------------------------------------------- */
FUNCTION msg_val(valset_fmt  IN  VARCHAR2,
                 valset_len  IN  NUMBER,
                 valset_prec IN  NUMBER,
                 valset_lettersok IN VARCHAR2,
                 stored_val  IN  VARCHAR2) RETURN VARCHAR2 IS
  d_val  VARCHAR2(1000);
BEGIN
  if(stored_to_displayed(valset_fmt, valset_len,
                         valset_prec, valset_lettersok,
                         stored_val, d_val) <> FF_VVALID) then
    d_val := stored_val;
  end if;
  return(d_val);
EXCEPTION
  WHEN OTHERS then
    return(stored_val);
END msg_val;

/* ----------------------------------------------------------------------- */
/*      Converts value from stored format to displayed format.             */
/*      Returns FF_VVALID on success, or FF_VERROR otherwise.              */
/*      Bug 18840251 Support non-gregorian format.                         */
/* ----------------------------------------------------------------------- */
FUNCTION stored_to_displayed(valset_fmt  IN  VARCHAR2,
                             valset_len  IN  NUMBER,
                             valset_prec IN  NUMBER,
                             valset_lettersok IN VARCHAR2,
                             stored_val  IN  VARCHAR2,
                             disp_val    OUT nocopy VARCHAR2) RETURN VARCHAR2 IS
  datebuf     DATE;
  datebuf_char  VARCHAR2(50);
  datebuf_user  VARCHAR2(50);
  err_nbr       NUMBER;
  err_msg       VARCHAR2(2000);
  user_calendar VARCHAR2(30);
  user_mask     VARCHAR2(30);
  ddf           VARCHAR2(30);
BEGIN
if(valset_fmt in ('X', 'Y', 'Z')) then
  if(isa_stored_date(stored_val, valset_fmt, datebuf)) then
   user_calendar := nvl(fnd_profile.value('FND_FORMS_USER_CALENDAR'),'GREGORIAN');
   user_mask :=displayed_date_format(valset_fmt, valset_len);
   datebuf_char := to_char(datebuf, user_mask);
   fnd_flex_val_util.flex_date_converter_cal(valset_fmt,
                                             '1',
                                             '1',
                                             user_mask,
                                             user_calendar,
                                             datebuf_char,
                                             datebuf_user,
                                             err_nbr,
                                             err_msg);
   disp_val := datebuf_user;
  else
    return(FF_VERROR);
  end if;
 ELSIF ((valset_fmt = 'N') OR
        ((valset_fmt = 'C') AND
         (valset_lettersok = 'N'))) THEN
   disp_val := REPLACE(stored_val,m_nc,m_nd);
 else
  disp_val := stored_val;
end if;

return(FF_VVALID);

EXCEPTION
  WHEN OTHERS then
    return(FF_VERROR);
END stored_to_displayed;


/* ----------------------------------------------------------------------- */
/*      Converts character representation of a number to a number.         */
/*      Returns TRUE if it's a valid number, and FALSE otherwise.          */
/* ----------------------------------------------------------------------- */
FUNCTION isa_number(teststr IN VARCHAR2,
                     outnum OUT nocopy NUMBER) RETURN BOOLEAN IS
BEGIN
  outnum := to_number(teststr);
  return(TRUE);
EXCEPTION
  WHEN OTHERS then
    return(FALSE);
END isa_number;

/* ----------------------------------------------------------------------- */
/*      Converts character representation of a stored date to a date.      */
/*      Returns TRUE if it's a valid date, and FALSE otherwise.    */
/* ----------------------------------------------------------------------- */
FUNCTION isa_stored_date(teststr IN VARCHAR2,
                         flexfmt IN VARCHAR2,
                         outdate OUT nocopy DATE) RETURN BOOLEAN IS
BEGIN
  if(teststr is null) then
    return(TRUE);
  end if;
  return(isa_date(teststr, stored_date_format(flexfmt, LENGTH(teststr)),
         outdate));
EXCEPTION
  WHEN OTHERS then
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        add_debug('isa_stored_date() exception: ' || SQLERRM);
     END IF;
    return(FALSE);
END isa_stored_date;


/* ----------------------------------------------------------------------- */
/*      Converts character representation of a displayed date to a date.   */
/*      Returns TRUE if it's a valid date, and FALSE otherwise.            */
/* ----------------------------------------------------------------------- */
FUNCTION isa_displayed_date(teststr IN VARCHAR2,
                            flexfmt IN VARCHAR2,
                            outdate OUT nocopy DATE) RETURN BOOLEAN IS
BEGIN
  if(teststr is null) then
    return(TRUE);
  end if;
  return(isa_date(teststr, displayed_date_format(flexfmt, LENGTH(teststr)),
         outdate));
EXCEPTION
  WHEN OTHERS then
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        add_debug('isa_displayed_date() exception: ' || SQLERRM);
     END IF;
    return(FALSE);
END isa_displayed_date;

/* ----------------------------------------------------------------------- */
/*      Converts test string to date using supplied format.                */
/*      If date conversion fails or supplied format is null, returns FALSE */
/*      otherwise returns TRUE.                                            */
/*      This function is a wrapper around to_date() to make it always work */
/*      even if the supplied format is 'DD-MON-YY'  (See bug)              */
/* ----------------------------------------------------------------------- */
FUNCTION isa_date(teststr IN VARCHAR2,
                  datefmt IN VARCHAR2,
                  outdate OUT nocopy DATE) RETURN BOOLEAN IS
BEGIN
  if(teststr is null) then
    return(TRUE);
  end if;
  if(datefmt is null) then
    return(FALSE);
  elsif(datefmt = 'DD-MON-YY') then
    outdate := to_date(teststr, datefmt);
  elsif(datefmt = 'DD-MON-RR') then
    outdate := to_date(teststr, datefmt);
  else
    outdate := to_date(teststr, datefmt);
  end if;
  return(TRUE);
EXCEPTION
  WHEN OTHERS then
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        add_debug('isa_date() exception: ' || SQLERRM);
     END IF;
    return(FALSE);
END isa_date;

/* ----------------------------------------------------------------------- */
/*      Returns format string for converting a date to a character string  */
/*      that represents the displayed value of a flex date, time, or       */
/*      date-time.                                                         */
/*      Returns NULL if not valid flex date format.                        */
/* ----------------------------------------------------------------------- */
FUNCTION displayed_date_format(flex_data_type IN VARCHAR2,
                               string_length  IN NUMBER) RETURN VARCHAR2 IS

  l_format_in VARCHAR2(500);
  l_format_out VARCHAR2(500);
BEGIN
   IF (fnd_flex_val_util.get_display_format
       (p_vset_format => flex_data_type,
        p_max_length => string_length,
        p_precision => NULL,
        x_format_in => l_format_in,
        x_format_out => l_format_out)) THEN
      RETURN(l_format_out);
    ELSE
      RETURN(NULL);
   END IF;

  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG',
                      'displayed_date_format() exception:  ' || SQLERRM);
      return(NULL);

END displayed_date_format;

/* ----------------------------------------------------------------------- */
/*      Returns format string for converting character representation      */
/*      of stored flex date, time, or date-time data to a date datatype    */
/*      using the to_date() conversion utility.                            */
/*      Returns NULL if not valid flex date format.                        */
/*      Modified for DD-MON-RR conversion in Prod 16   12-26-96            */
/* ----------------------------------------------------------------------- */
FUNCTION stored_date_format(flex_data_type IN VARCHAR2,
                            string_length  IN NUMBER) RETURN VARCHAR2 IS

  l_format VARCHAR2(500);
BEGIN
   IF (fnd_flex_val_util.get_storage_format(p_vset_format => flex_data_type,
                                            p_max_length  => string_length,
                                            p_precision   => NULL,
                                            x_format      => l_format)) THEN
      RETURN(l_format);
    ELSE
      RETURN(NULL);
   END IF;

EXCEPTION
   WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG',
                            'stored_date_format() exception:  ' || SQLERRM);
      return(NULL);

END stored_date_format;

/* ----------------------------------------------------------------------- */
/*              Generally useful utilities - Externalized                  */
/* ----------------------------------------------------------------------- */

/* ----------------------------------------------------------------------- */
/*              Initializes all global variables                           */
/* ----------------------------------------------------------------------- */
FUNCTION init_globals RETURN BOOLEAN IS

BEGIN

  n_sqlstrings := 0;
  g_debug_array_size := 0;
  return(TRUE);

EXCEPTION
  WHEN OTHERS then
    FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
    FND_MESSAGE.set_token('MSG', 'init_globals() exception:  ' || SQLERRM);
    return(FALSE);

END init_globals;

/* ----------------------------------------------------------------------- */
/*      Creates an "and clause" of a SQL select statement for determining  */
/*      if the value passed in is in between the values in the columns     */
/*      whose names are in mincol and maxcol.  Returns NULL if no          */
/*      statement required for this column                                 */
/*                                                                         */
/*      By isolating all in range clauses to this routine we can ensure    */
/*      uniform range behavior.                                            */
/*                                                                         */
/*      Null handling:  If val is NULL, requires either mincol or maxcol   */
/*      to be null.  If the value contained in mincol (maxcol) is NULL it  */
/*      means there is no lower(upper) limit on the range of val           */
/*                                                                         */
/*      Clause is of the form:                                             */
/*      'and (10 between nvl(to_number(MINCOL), 10)                        */
/*             and nvl(to_number(MAXCOL), 10)) '                           */
/*                                                                         */
/* ----------------------------------------------------------------------- */
PROCEDURE x_inrange_clause(valstr  IN VARCHAR2,
                           valtype IN VARCHAR2,
                           mincol  IN VARCHAR2,
                           maxcol  IN VARCHAR2) IS

  clause      VARCHAR2(500);
  val         VARCHAR2(200);
  collo       VARCHAR2(200);
  colhi       VARCHAR2(200);
  datefmt     VARCHAR2(24);

BEGIN
   fnd_dsql.add_text('and (');
   IF (valstr IS NULL) THEN
      fnd_dsql.add_text(mincol || ' is null or ' ||
                        maxcol || ' is null) ');
    ELSE
      IF (valtype = 'N') THEN
         fnd_dsql.add_bind(fnd_number.canonical_to_number(valstr));

         fnd_dsql.add_text(' between nvl(fnd_number.canonical_to_number('
                           || mincol || '),');
         fnd_dsql.add_bind(fnd_number.canonical_to_number(valstr));

         fnd_dsql.add_text(') and nvl(fnd_number.canonical_to_number('
                           || maxcol || '),');
         fnd_dsql.add_bind(fnd_number.canonical_to_number(valstr));

       ELSIF (valtype in ('D', 'T', 't', 'I', 'X', 'Y', 'Z')) THEN
         datefmt := stored_date_format(valtype, LENGTH(valstr));
         fnd_dsql.add_bind(To_date(valstr, datefmt));

         fnd_dsql.add_text(' between nvl(to_date(' ||
                           mincol || ',''' || datefmt || '''),');
         fnd_dsql.add_bind(To_date(valstr, datefmt));

         fnd_dsql.add_text(') and nvl(to_date(' ||
                           maxcol || ',''' || datefmt || '''),');
         fnd_dsql.add_bind(To_date(valstr, datefmt));

       ELSE
         fnd_dsql.add_bind(valstr);

         fnd_dsql.add_text(' between nvl(' || mincol || ',');
         fnd_dsql.add_bind(valstr);

         fnd_dsql.add_text(') and nvl(' || maxcol || ',');
         fnd_dsql.add_bind(valstr);

      END IF;
      fnd_dsql.add_text(')) ');
   END IF;
END x_inrange_clause;

/* ----------------------------------------------------------------------- */
/*      Function to convert a column name into a SQL clause for selecting  */
/*      a value, id, or description from that column into the correct      */
/*      character format for the given value set.                          */
/*                                                                         */
/*      This function does the default to_char() conversion for            */
/*      non-translatable date, time, date-time, or number value sets       */
/*      in order to maintain backward compatibility with old client code.  */
/*      For translatable date, time, and date-time value sets this code    */
/*      converts the data stored in the date column to date storage format */
/*                                                                         */
/*      Does not check for compatibility of column type and value set.     */
/* ----------------------------------------------------------------------- */

FUNCTION select_clause(colname     IN  VARCHAR2,
                       coltype     IN  VARCHAR2,
                       v_component IN  BINARY_INTEGER,
                       vs_fmt      IN  VARCHAR2,
                       vs_len      IN  NUMBER) RETURN VARCHAR2 IS

  clause      VARCHAR2(2000);

BEGIN

  if(coltype not in ('C', 'V')) then
    clause := 'to_char(' || colname;
    if(vs_fmt in ('X', 'Y', 'Z')) then
      clause := clause || ', ''';
      if((v_component = VC_ID) OR (v_component = VC_VALUE)) then
        clause := clause || stored_date_format(vs_fmt, vs_len) || ''')';
      else
        clause := clause || displayed_date_format(vs_fmt, vs_len) || ''')';
      end if;
     ELSIF (vs_fmt = 'N') THEN
       clause := clause || ')';
       clause := 'replace(' || clause || ',''' || m_nb || ''','''
         || m_nc || ''')';
     else
       clause := clause || ')';
    end if;
  else
    clause := colname;
  end if;
  return(clause);

END select_clause;

/* ----------------------------------------------------------------------- */
/*      Function to convert a value into a SQL clause for comparing that   */
/*      value into a table column of the given type, or for inserting that */
/*      value to a value stored in a table column of the given type.       */
/*                                                                         */
/*      If the table column is a number assume the value input is a number */
/*      and just use the text of the number.  If the table column is       */
/*      CHAR or VARCHAR2, then substitute all single quotes in the value   */
/*      with double quotes and surround the value with single quotes.      */
/*      If table column is DATE, do to_date() conversion using the format  */
/*      appropriate for the value set.                                     */
/*                                                                         */
/*      To maintin backward compatibility with existing client code must   */
/*      build in the BUG that if value set format type is old-fashioned    */
/*      date, time or date-time (D, T or t), then default to_date()        */
/*      conversions are done.  This means non-validated Date-time values   */
/*      cannot be inserted into the combinations table.                    */
/* ----------------------------------------------------------------------- */

PROCEDURE x_compare_clause(coltype     IN  VARCHAR2,
                           colname     IN  VARCHAR2,
                           char_val    IN  VARCHAR2,
                           v_component IN  BINARY_INTEGER,
                           vs_fmt      IN  VARCHAR2,
                           vs_len      IN  NUMBER)
  IS
     datefmt VARCHAR2(30);
BEGIN
   IF (coltype = 'N') THEN
      fnd_dsql.add_bind(fnd_number.canonical_to_number(char_val));
    ELSIF (coltype = 'D') then
      IF (vs_fmt in ('X', 'Y', 'Z', 'D', 'T', 'I', 't')) then
         datefmt := stored_date_format(vs_fmt, vs_len);
         fnd_dsql.add_bind(To_date(char_val, datefmt));
       ELSE
         fnd_dsql.add_bind(char_val);
      end if;
    else
      fnd_dsql.add_bind(char_val);
   end if;

END x_compare_clause;

/* ----------------------------------------------------------------------- */
/*      Creates a SQL clause for binding a character string.               */
/*      Replaces single quotes with double quotes and surrounds the        */
/*      string with quotes.                                                */
/* ----------------------------------------------------------------------- */

FUNCTION string_clause(char_string IN VARCHAR2) RETURN VARCHAR2 IS
BEGIN
  return('''' || REPLACE(char_string, '''', '''''') || '''');
END string_clause;

-- /* ----------------------------------------------------------------------- */
-- /*      MADE NULL TO MAKE MORE ROOM FOR USEFUL CODE.                       */
-- /*      Breaks concatenated segments in rule lines table into separate     */
-- /*      columns for each segment.  Returns number of segments or < 0       */
-- /*      and sets FND_MESSAGE if error.  This is called only from trigger   */
-- /*      FND_FLEX_VALIDATION_RULE_LINES_T1.  The trigger should use         */
-- /*      FND_MESSAGE.raise_exception if this function returns error.        */
-- /* ----------------------------------------------------------------------- */
--   FUNCTION breakup_segs(appid IN NUMBER,
--                 flex_code IN VARCHAR2, flex_num IN NUMBER,
--                 catsegs IN VARCHAR2, nsegs OUT NUMBER,
--                 seg1  OUT VARCHAR2, seg2  OUT VARCHAR2,
--                 seg3  OUT VARCHAR2, seg4  OUT VARCHAR2,
--                 seg5  OUT VARCHAR2, seg6  OUT VARCHAR2,
--                 seg7  OUT VARCHAR2, seg8  OUT VARCHAR2,
--                 seg9  OUT VARCHAR2, seg10 OUT VARCHAR2,
--                 seg11 OUT VARCHAR2, seg12 OUT VARCHAR2,
--                 seg13 OUT VARCHAR2, seg14 OUT VARCHAR2,
--                 seg15 OUT VARCHAR2, seg16 OUT VARCHAR2,
--                 seg17 OUT VARCHAR2, seg18 OUT VARCHAR2,
--                 seg19 OUT VARCHAR2, seg20 OUT VARCHAR2,
--                 seg21 OUT VARCHAR2, seg22 OUT VARCHAR2,
--                 seg23 OUT VARCHAR2, seg24 OUT VARCHAR2,
--                 seg25 OUT VARCHAR2, seg26 OUT VARCHAR2,
--                 seg27 OUT VARCHAR2, seg28 OUT VARCHAR2,
--                 seg29 OUT VARCHAR2, seg30 OUT VARCHAR2) RETURN NUMBER IS
--
--     n_segs      NUMBER;
--     sg          StringArray;
--     sepchar     VARCHAR2(1);
--
--   BEGIN
--     return(-1);
--
--   EXCEPTION
--     WHEN OTHERS then
--       FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
--       FND_MESSAGE.set_token('MSG', 'breakup_segs() exception: ' || SQLERRM);
--       return(-2);
--
--   END breakup_segs;

/* ----------------------------------------------------------------------- */
/*      Executes a dynamic SQL statement.                                  */
/*      Returns number of rows processed or -1 if error (add_message)      */
/* ----------------------------------------------------------------------- */
FUNCTION x_dsql_execute RETURN NUMBER IS

cursornum     INTEGER;
nprocessed    INTEGER;
sql_statement    VARCHAR2(32000);

BEGIN

--  Copy SQL string to array for debugging purposes
--
  add_sql_string(fnd_dsql.get_text(p_with_debug => TRUE));

  cursornum := dbms_sql.open_cursor;
  fnd_dsql.set_cursor(cursornum);

  sql_statement := fnd_dsql.get_text(p_with_debug => FALSE);
  dbms_sql.parse(cursornum, sql_statement, dbms_sql.v7);

  fnd_dsql.do_binds;

  nprocessed := dbms_sql.execute(cursornum);
  IF (fnd_flex_server1.g_debug_level > 0) THEN
     add_debug('(DSQL_execute processed ' || to_char(nprocessed));
     add_debug(' rows.)');
  END IF;
  dbms_sql.close_cursor(cursornum);
  return(nprocessed);

EXCEPTION
  WHEN OTHERS then
    if(dbms_sql.is_open(cursornum)) then
      dbms_sql.close_cursor(cursornum);
    end if;
    FND_MESSAGE.set_name('FND', 'FLEX-DSQL EXCEPTION');
    FND_MESSAGE.set_token('MSG', SQLERRM);
    FND_MESSAGE.set_token('SQLSTR', SUBSTRB(sql_statement, 1, 1000));
    return(-1);

END x_dsql_execute;

/* ----------------------------------------------------------------------- */
/*      Uses dynamic SQL to select up to one varchar2 valued column from   */
/*      a table using the select statement passed in.  Returns 0, NULL     */
/*      if no rows found, or 1 and the column value if 1 row found, or     */
/*      2 and the column value of the first row found if more than 1 row   */
/*      matches selection criteria, or < 0 if other errors.                */
/*      Invalid rowid exception mapped back to no data found.              */
/* ----------------------------------------------------------------------- */
FUNCTION x_dsql_select_one(returned_column OUT nocopy VARCHAR2) RETURN NUMBER IS
cursornum     INTEGER;
num_returned  INTEGER;
selected_col  VARCHAR2(2000);
invalid_rowid EXCEPTION;
sql_statement    VARCHAR2(32000);

PRAGMA EXCEPTION_INIT(invalid_rowid, -1410);

BEGIN

--  Copy SQL string to array for debugging purposes
--
  add_sql_string(fnd_dsql.get_text(p_with_debug => TRUE));

  selected_col := NULL;
  cursornum := dbms_sql.open_cursor;
  fnd_dsql.set_cursor(cursornum);

  sql_statement := fnd_dsql.get_text(p_with_debug => FALSE);
  dbms_sql.parse(cursornum, sql_statement, dbms_sql.v7);

  fnd_dsql.do_binds;

  dbms_sql.define_column(cursornum, 1, selected_col, 2000);
  num_returned := dbms_sql.execute_and_fetch(cursornum, TRUE);
  if(num_returned = 1) then
    dbms_sql.column_value(cursornum, 1, selected_col);
    returned_column := selected_col;
    IF (fnd_flex_server1.g_debug_level > 0) THEN
       add_debug('(DSQL returned ' || selected_col || ')');
    END IF;
  else
    num_returned := -1;
    returned_column := NULL;
    FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
    FND_MESSAGE.set_token('MSG', 'x_dsql_select_one() could not fetch rows');
  end if;
dbms_sql.close_cursor(cursornum);
return(num_returned);

EXCEPTION
  WHEN NO_DATA_FOUND or invalid_rowid then
    returned_column := NULL;
    IF (fnd_flex_server1.g_debug_level > 0) THEN
       add_debug('(DSQL returned: NULL)');
    END IF;
    dbms_sql.close_cursor(cursornum);
    return(0);
  WHEN TOO_MANY_ROWS then
    dbms_sql.column_value(cursornum, 1, selected_col);
    returned_column := selected_col;
    IF (fnd_flex_server1.g_debug_level > 0) THEN
       add_debug('(DSQL returned: TOO MANY ROWS)');
    END IF;
    dbms_sql.close_cursor(cursornum);
    return(2);
  WHEN OTHERS then
    if(dbms_sql.is_open(cursornum)) then
      dbms_sql.close_cursor(cursornum);
    end if;
    FND_MESSAGE.set_name('FND', 'FLEX-DSQL EXCEPTION');
    FND_MESSAGE.set_token('MSG', SQLERRM);
    FND_MESSAGE.set_token('SQLSTR', SUBSTRB(sql_statement, 1, 1000));
    return(-2);

END x_dsql_select_one;

/* ----------------------------------------------------------------------- */
/*      Uses dynamic SQL to select n_selected_cols of VARCHAR2 type from   */
/*      a table using the select statement passed in.  Returns number      */
/*      of rows found, or sets error and returns < 0 if error.             */
/*      Invalid rowid exception mapped back to no data found.              */
/* ----------------------------------------------------------------------- */
FUNCTION x_dsql_select(n_selected_cols  IN  NUMBER,
                       returned_columns OUT nocopy StringArray) RETURN NUMBER
  IS
     cursornum        INTEGER;
     num_returned     INTEGER;
     selected_cols    StringArray;
     invalid_rowid    EXCEPTION;
     sql_statement    VARCHAR2(32000);

     PRAGMA EXCEPTION_INIT(invalid_rowid, -1410);
BEGIN

   --  Copy SQL string to array for debugging purposes
   --
   add_sql_string(fnd_dsql.get_text(p_with_debug => TRUE));

   cursornum := dbms_sql.open_cursor;
   fnd_dsql.set_cursor(cursornum);

   sql_statement := fnd_dsql.get_text(p_with_debug => FALSE);
   dbms_sql.parse(cursornum, sql_statement, dbms_sql.v7);

   fnd_dsql.do_binds;

   for i in 1..n_selected_cols loop
      --    The following prevents NO-DATA-FOUND exception...
      selected_cols(i) := NULL;
      dbms_sql.define_column(cursornum, i, selected_cols(i), 2000);
   end loop;
   num_returned := dbms_sql.execute_and_fetch(cursornum, TRUE);
   if(num_returned = 1) then
      IF (fnd_flex_server1.g_debug_level > 0) THEN
         add_debug('(DSQL returned');
      END IF;
      for i in 1..n_selected_cols loop
         dbms_sql.column_value(cursornum, i, selected_cols(i));
         IF (fnd_flex_server1.g_debug_level > 0) THEN
            add_debug(' ''' || selected_cols(i) || '''');
         END IF;
      end loop;
      IF (fnd_flex_server1.g_debug_level > 0) THEN
         add_debug(')');
      END IF;
    else
      num_returned := -1;
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG', 'x_dsql_select() could not fetch rows');
   end if;
   dbms_sql.close_cursor(cursornum);
   returned_columns := selected_cols;
   return(num_returned);

EXCEPTION
  WHEN NO_DATA_FOUND OR invalid_rowid then
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        add_debug('(DSQL returned: NULL)');
     END IF;
    dbms_sql.close_cursor(cursornum);
    return(0);
  WHEN TOO_MANY_ROWS then
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        add_debug('(DSQL returned');
     END IF;
    for i in 1..n_selected_cols loop
      dbms_sql.column_value(cursornum, i, selected_cols(i));
      IF (fnd_flex_server1.g_debug_level > 0) THEN
         add_debug(' ''' || selected_cols(i) || '''');
      END IF;
    end loop;
    IF (fnd_flex_server1.g_debug_level > 0) THEN
       add_debug(')');
       add_debug('(DSQL returned: TOO MANY ROWS)');
    END IF;
    dbms_sql.close_cursor(cursornum);
    returned_columns := selected_cols;
    return(2);
  WHEN OTHERS then
    if(dbms_sql.is_open(cursornum)) then
      dbms_sql.close_cursor(cursornum);
    end if;
    FND_MESSAGE.set_name('FND', 'FLEX-DSQL EXCEPTION');
    FND_MESSAGE.set_token('MSG', SQLERRM);
    FND_MESSAGE.set_token('SQLSTR', SUBSTRB(sql_statement, 1, 1000));
    return(-2);

END x_dsql_select;

/* ----------------------------------------------------------------------- */
/*      Adds string to array of dynamic sql strings.                       */
/*      The buffer is zeroed when init_globals is called.                  */
/* ----------------------------------------------------------------------- */
PROCEDURE add_sql_string(sql_statement IN VARCHAR2) IS
BEGIN
  n_sqlstrings := n_sqlstrings + 1;
  sqlstrings(n_sqlstrings) := sql_statement;
END add_sql_string;

/* ----------------------------------------------------------------------- */
/*      For debugging.                                                     */
/*      Returns number of SQL statements created during last call          */
/*      to validate().  Use in conjunction with get_sql().                 */
/* ----------------------------------------------------------------------- */
FUNCTION get_nsql_internal RETURN NUMBER IS
BEGIN
  return(nvl(to_number(n_sqlstrings), 0));
END get_nsql_internal;

/* ----------------------------------------------------------------------- */
/*      For debugging.                                                     */
/*      Returns SQL statements created during last call                    */
/*      to validate().  Use in conjunction with get_sql().                 */
/* ----------------------------------------------------------------------- */
FUNCTION get_sql_internal(statement_number IN NUMBER,
                 statement_portion IN NUMBER DEFAULT 1) RETURN VARCHAR2 IS

  dsql_start  NUMBER;

BEGIN

  if((statement_number is null) or (statement_number < 1) or
     (statement_number > nvl(to_number(n_sqlstrings), 0)) or
     (statement_portion is null) or (statement_portion < 1) or
     (sqlstrings(statement_number) is null)) then
     return(NULL);
  end if;

  dsql_start := 1 + ((statement_portion - 1) * MAX_RETSTR_LEN);
  if(dsql_start > LENGTH(sqlstrings(statement_number))) then
    return(NULL);
  end if;

  return(SUBSTR(sqlstrings(statement_number), dsql_start, MAX_RETSTR_LEN));

  EXCEPTION
  WHEN NO_DATA_FOUND then
      return('get_sql_internal('||to_char(statement_number)||') statement not found');
  WHEN OTHERS then
      return('get_sql_internal() exception: ' || SQLERRM);

END get_sql_internal;

/* ----------------------------------------------------------------------- */
/*                      Adds to debug string                               */
/* ----------------------------------------------------------------------- */
PROCEDURE set_debugging(p_debug_mode IN VARCHAR2)
  IS
BEGIN
   IF (p_debug_mode = 'OFF') THEN
      fnd_flex_server1.g_debug_level := 0;
    ELSIF (p_debug_mode = 'ERROR') THEN
      fnd_flex_server1.g_debug_level := 1;
    ELSIF (p_debug_mode = 'EXCEPTION') THEN
      fnd_flex_server1.g_debug_level := 2;
    ELSIF (p_debug_mode = 'EVENT') THEN
      fnd_flex_server1.g_debug_level := 3;
    ELSIF (p_debug_mode = 'PROCEDURE') THEN
      fnd_flex_server1.g_debug_level := 4;
    ELSIF (p_debug_mode = 'STATEMENT') THEN
      fnd_flex_server1.g_debug_level := 5;
    ELSIF (p_debug_mode = 'ALL') THEN
      fnd_flex_server1.g_debug_level := 6;
      fnd_flex_val_util.set_debugging(TRUE);
    ELSE
      fnd_flex_server1.g_debug_level := 0;
   END IF;

   IF (fnd_flex_server1.g_debug_level > 0) THEN
      --get the directory where we can write
      SELECT value into utl_file_dir FROM V$PARAMETER WHERE NAME = 'utl_file_dir';
      --get the session id
      SELECT userenv('SESSIONID') into l_session_id from dual;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      fnd_flex_server1.g_debug_level := 0;
END set_debugging;

/* ----------------------------------------------------------------------- */
/*                      Adds to debug string                               */
/* ----------------------------------------------------------------------- */
PROCEDURE add_debug(p_debug_string IN VARCHAR2,
                    p_debug_mode   IN VARCHAR2 DEFAULT 'STATEMENT')
  IS
     l_code_level NUMBER;
     l_debug_string VARCHAR2(32000);
     l_newline_pos  NUMBER;
     l_debug_line   VARCHAR2(32000);

     L_HANDLER UTL_FILE.FILE_TYPE;
BEGIN
   IF (fnd_flex_server1.g_debug_level = 0) THEN
      RETURN;
   END IF;
   IF (p_debug_mode = 'OFF') THEN
      l_code_level := 0;
    ELSIF (p_debug_mode = 'ERROR') THEN
      l_code_level := 1;
    ELSIF (p_debug_mode = 'EXCEPTION') THEN
      l_code_level := 2;
    ELSIF (p_debug_mode = 'EVENT') THEN
      l_code_level := 3;
    ELSIF (p_debug_mode = 'PROCEDURE') THEN
      l_code_level := 4;
    ELSIF (p_debug_mode = 'STATEMENT') THEN
      l_code_level := 5;
    ELSIF (p_debug_mode = 'ALL') THEN
      l_code_level := 6;
    ELSE
      l_code_level := 0;
   END IF;

   IF (l_code_level <= fnd_flex_server1.g_debug_level) THEN
      IF (g_debug_array_size = 0) THEN
         g_debug_array_size := 1;
         g_debug_array(g_debug_array_size) :=
           ('DEBUG LEVEL:'||To_char(fnd_flex_server1.g_debug_level) ||
            chr_newline);
      END IF;


      -- If no dir defined, then try using /usr/tmp, it may not work.
      -- So you need to edit the init.ora file to include the UTL_FILE_DIR parameter.
      IF utl_file_dir IS NULL THEN
         L_HANDLER := UTL_FILE.FOPEN('/usr/tmp', 'fdfsrvdbg.log', 'A');
      ELSE
        --get the first directory from a possible several dirs
        IF instr(utl_file_dir,',') > 0 THEN
           utl_file_dir := substr(utl_file_dir,1,instr(utl_file_dir,',')-1);
         END IF;
         L_HANDLER := UTL_FILE.FOPEN(utl_file_dir, 'fdfsrvdbg.log', 'A');
      END IF;

      l_debug_string := (Substr(Rtrim(Ltrim(p_debug_string)), 1, MAX_RETSTR_LEN-10) ||
                         chr_newline);

      WHILE (l_debug_string IS NOT NULL) LOOP
         l_newline_pos := Instr(l_debug_string, chr_newline, 1, 1);
         IF (l_newline_pos +
             Nvl(Length(g_debug_array(g_debug_array_size)), 0) < MAX_RETSTR_LEN) THEN
            l_debug_line := Substr(l_debug_string, 1, l_newline_pos);
            l_debug_string := Substr(l_debug_string, l_newline_pos + 1);
            IF (l_debug_line LIKE 'BEGIN %' OR
                l_debug_line LIKE 'END %' OR
                l_debug_line LIKE 'CALL %' OR
                l_debug_line LIKE 'EXCEPTION %') THEN
               g_debug_array(g_debug_array_size) :=
                 g_debug_array(g_debug_array_size) || l_debug_line;
               UTL_FILE.PUT_LINE(L_HANDLER, CONCAT(l_session_id || ' ', l_debug_line));
             ELSE
               g_debug_array(g_debug_array_size) :=
                 g_debug_array(g_debug_array_size) || ' ' || l_debug_line;
               UTL_FILE.PUT_LINE(L_HANDLER, CONCAT(l_session_id || ' ', l_debug_line));
            END IF;
          ELSE
            g_debug_array_size := g_debug_array_size + 1;
            g_debug_array(g_debug_array_size) := NULL;
         END IF;
      END LOOP;
   END IF;
   UTL_FILE.FCLOSE(L_HANDLER);
EXCEPTION
   WHEN OTHERS THEN
     UTL_FILE.FCLOSE(L_HANDLER);
END add_debug;

/* ----------------------------------------------------------------------- */
/*      Returns the debug string.                                          */
/* ----------------------------------------------------------------------- */
FUNCTION get_debug_internal(string_n IN NUMBER) RETURN VARCHAR2 IS
BEGIN
   IF ((string_n is not null) and
       (string_n >= 1) AND
       (string_n) <= g_debug_array_size) THEN
      RETURN(g_debug_array(string_n));
   end if;
   return(NULL);

EXCEPTION
   WHEN OTHERS then
      return('get_debug_internal() exception: ' || SQLERRM);
END get_debug_internal;

/* -------------------------------------------------- */
/* New client side debug functions                    */
/* -------------------------------------------------- */
PROCEDURE x_get_nsql(x_nsql OUT nocopy NUMBER)
  IS
BEGIN
   x_nsql := fnd_flex_server1.get_nsql_internal;
EXCEPTION
   WHEN OTHERS THEN
      x_nsql := 0;
END;

PROCEDURE x_get_sql_npiece(p_sql_num IN NUMBER,
                           x_npiece  OUT nocopy NUMBER)
  IS
     l_sql_num NUMBER;
BEGIN
   l_sql_num := Nvl(p_sql_num, 0);
   x_npiece := 0;
   IF ((l_sql_num > 0) AND
       (l_sql_num <= fnd_flex_server1.get_nsql_internal)) THEN
      x_npiece :=Ceil(Nvl(Lengthb(sqlstrings(l_sql_num)),0)/MAX_RETSTR_LEN);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      x_npiece := 0;
END;

PROCEDURE x_get_sql_piece(p_sql_num   IN NUMBER,
                          p_piece_num IN NUMBER,
                          x_sql_piece OUT nocopy VARCHAR2)
  IS
     l_sql_num NUMBER;
     l_piece_num NUMBER;
BEGIN
   l_sql_num := Nvl(p_sql_num, 0);
   l_piece_num := Nvl(p_piece_num, 0);
   x_sql_piece := NULL;
   IF ((l_sql_num > 0) AND
       (l_sql_num <= fnd_flex_server1.get_nsql_internal) AND
       (l_piece_num > 0)) THEN
      x_sql_piece := substrb(sqlstrings(l_sql_num),
                             1 + (l_piece_num - 1) * MAX_RETSTR_LEN,
                             MAX_RETSTR_LEN);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      x_sql_piece := substrb('EXCEPTION:' || Sqlerrm,1,MAX_RETSTR_LEN);
END;

PROCEDURE x_get_ndebug(x_ndebug OUT nocopy NUMBER)
  IS
BEGIN
   x_ndebug := g_debug_array_size;
EXCEPTION
   WHEN OTHERS THEN
      x_ndebug := 0;
END;

PROCEDURE x_get_debug(p_debug_num IN NUMBER,
                      x_debug OUT nocopy VARCHAR2)
  IS
     l_debug_num NUMBER;
BEGIN
   l_debug_num := Nvl(p_debug_num, 0);
   IF (l_debug_num >= 1 AND
       l_debug_num <= g_debug_array_size) THEN
      x_debug := g_debug_array(l_debug_num);
    ELSE
      x_debug := 'INDEX OUT OF RANGE [1..' || g_debug_array_size || '].';
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      x_debug := substrb('EXCEPTION:' || Sqlerrm,1,MAX_RETSTR_LEN);
END;

/* ----------------------------------------------------------------------- */
/*               Converts concatenated segments to segment array           */
/*      Segment array is 1-based containing entries for 1 <= i <= nsegs    */
/* ----------------------------------------------------------------------- */
FUNCTION to_stringarray(catsegs IN  VARCHAR2,
                        sepchar in  VARCHAR2,
                        segs    OUT nocopy StringArray)
  RETURN NUMBER
  IS
     l_wc         VARCHAR2(10);
     l_flex_value VARCHAR2(2000);
     i            NUMBER;
     l_segnum     PLS_INTEGER;
     l_delimiter  VARCHAR2(10);
     l_tmp_str    VARCHAR2(32000);
     l_delim_pos  PLS_INTEGER;
     l_old_delim_pos  PLS_INTEGER;
BEGIN
   l_delimiter := Substr(sepchar, 1, 1);

   --
   -- Make sure delimiter is valid.
   --
   IF ((l_delimiter IS NULL) OR (l_delimiter = FLEX_DELIMITER_ESCAPE)) THEN
      raise_application_error(-20001,
                              'SV2.to_stringarray. Invalid delimiter:''' ||
                              Nvl(sepchar, '<NULL>') || '''');
   END IF;

   --
   -- If catsegs is NULL then assume there is only one segment.
   --
   IF (catsegs IS NULL) THEN
      l_segnum := 1;
      segs(1) := catsegs;
      GOTO return_success;
   END IF;

   l_segnum := 0;
   i := 1;

   -- We need to go through un-escaping logic only if
   -- there is an ESCAPE character in the string.
   -- Bug 4501279.

   IF (instr(catsegs, FLEX_DELIMITER_ESCAPE) > 0) THEN

      --
      -- Loop for each segment.
      --
      LOOP
         l_flex_value := NULL;

         --
         -- Un-escaping loop.
         --
         LOOP

            l_wc := Substr(catsegs, i, 1);
            i := i + 1;

            IF (l_wc IS NULL) THEN
               EXIT;
            ELSIF (l_wc = l_delimiter) THEN
               EXIT;
            ELSIF (l_wc = FLEX_DELIMITER_ESCAPE) THEN

               l_wc := Substr(catsegs, i, 1);
               i := i + 1;

               IF (l_wc IS NULL) THEN
                  EXIT;
               END IF;

            END IF;

            l_flex_value := l_flex_value || l_wc;

         END LOOP;

         l_segnum := l_segnum + 1;
         segs(l_segnum) := l_flex_value;
         IF (l_wc IS NULL) THEN
            EXIT;
         END IF;
      END LOOP;

   ELSE

      -- No un-escaping logic required here.

      l_tmp_str := catsegs;
      l_delim_pos := 0;
      l_old_delim_pos := 0;

      LOOP

         l_delim_pos := instr(l_tmp_str, l_delimiter, l_delim_pos+1);

         IF (l_delim_pos <> 0) THEN
            l_segnum := l_segnum + 1;
            segs(l_segnum) := substr(l_tmp_str, l_old_delim_pos+1, l_delim_pos-l_old_delim_pos-1);
            l_old_delim_pos := l_delim_pos;
         ELSE
            l_segnum := l_segnum + 1;
            segs(l_segnum) := substr(l_tmp_str, l_old_delim_pos+1);
            EXIT;
         END IF;

      END LOOP;

   END IF;

   <<return_success>>
     RETURN(l_segnum);

EXCEPTION
   WHEN OTHERS THEN
      raise_application_error(-20001, 'SV2.to_stringarray. SQLERRM : ' ||
                              Sqlerrm);
END to_stringarray;

/* ----------------------------------------------------------------------- */
/*               Converts segment array to concatenated segments           */
/*      Segment array is 1-based containing entries for 1 <= i <= nsegs    */
/* ----------------------------------------------------------------------- */
FUNCTION from_stringarray(nsegs   IN NUMBER,
                          segs    IN StringArray,
                          sepchar IN VARCHAR2) RETURN VARCHAR2
  IS
     l_wc          VARCHAR2(10);
     l_return      VARCHAR2(32000) := NULL;
     i             pls_integer;
     l_segnum      pls_integer;
     l_delimiter   VARCHAR2(10);
BEGIN
   l_delimiter := Substr(sepchar, 1, 1);
   IF (fnd_flex_server1.g_debug_level > 0) THEN
      fnd_flex_server1.add_debug('BEGIN SV1.from_stringarray()');
   END IF;
   --
   -- Make sure delimiter is valid.
   --
   IF ((l_delimiter IS NULL) OR (l_delimiter = FLEX_DELIMITER_ESCAPE)) THEN
      raise_application_error(-20001,
                              'SV1.from_stringarray. Invalid delimiter:''' ||
                              Nvl(sepchar, '<NULL>') || '''');
   END IF;

   --
   -- Make sure array size is valid.
   --
   IF ((nsegs IS NULL) OR (nsegs < 1)) THEN
      raise_application_error(-20001,
                              'SV1.from_stringarray. For specified context there are ''' ||
                              Nvl(to_char(nsegs), '<NULL>') || '''' || ' displayed segments');
   END IF;

   --
   -- If only one segment then no need for concatenating or escaping.
   --
   IF (nsegs = 1) THEN
      l_return := segs(1);
      GOTO return_success;
   END IF;

   --
   -- Loop for each segment
   --
   FOR l_segnum IN 1..nsegs LOOP

      i := 1;

      --
      -- Escaping loop.
      --
      LOOP

         l_wc := Substr(segs(l_segnum), i, 1);
         i := i + 1;

         IF (l_wc IS NULL) THEN
            EXIT;
          ELSIF (l_wc = FLEX_DELIMITER_ESCAPE) THEN
            l_return := l_return || FLEX_DELIMITER_ESCAPE;
            l_return := l_return || FLEX_DELIMITER_ESCAPE;
          ELSIF (l_wc = l_delimiter) THEN
            l_return := l_return || FLEX_DELIMITER_ESCAPE;
            l_return := l_return || l_delimiter;
          ELSE
            l_return := l_return || l_wc;
         END IF;

      END LOOP;

      --
      -- No delimiter after the last value.
      --
      IF (l_segnum < nsegs) THEN
         l_return := l_return || l_delimiter;
      END IF;
   END LOOP;

   <<return_success>>
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        fnd_flex_server1.add_debug('END SV1.from_stringarray()');
     END IF;
     RETURN(l_return);
EXCEPTION
   WHEN OTHERS THEN
      IF (fnd_flex_server1.g_debug_level > 0) THEN
         fnd_flex_server1.add_debug('EXCEPTION SV1.from_stringarray()');
      END IF;
      raise_application_error(-20001, 'SV1.from_stringarray. SQLERRM : ' || Sqlerrm);
END from_stringarray;

/* ----------------------------------------------------------------------- */
/*               Converts concatenated segments to segment array           */
/*      Segment array is 1-based containing entries for 1 <= i <= nsegs    */
/*      Bug 1375146 added elsif statement to allow for only 1 segment      */
/*                  which is null.                                         */
/* ----------------------------------------------------------------------- */
FUNCTION to_stringarray2(catsegs IN  VARCHAR2,
                         sepchar in  VARCHAR2,
                         segs    OUT nocopy StringArray)
  RETURN NUMBER
  IS
     seg_start        NUMBER;
     seg_end          NUMBER;
     seg_len          NUMBER;
     catseg_len       NUMBER;
     sepchar_len      NUMBER;
     seg_index        BINARY_INTEGER;
     keep_going       BOOLEAN;
BEGIN
   seg_index := 1;
   seg_start := 1;
   keep_going := TRUE;
   IF ((catsegs IS NOT NULL) AND (sepchar IS NOT NULL)) THEN
      catseg_len := LENGTH(catsegs);
      sepchar_len := LENGTH(sepchar);
      WHILE (keep_going = TRUE) LOOP
         IF (seg_start > catseg_len) THEN
            segs(seg_index) := NULL;
            keep_going := FALSE;
          ELSE
            seg_end := INSTR(catsegs, sepchar, seg_start);
            IF (seg_end = 0) THEN
               seg_end := catseg_len + 1;
               keep_going := FALSE;
            END IF;
            seg_len := seg_end - seg_start;
            IF (seg_len = 0) THEN
               segs(seg_index) := NULL;
             ELSE
               segs(seg_index) := REPLACE(SUBSTR(catsegs, seg_start, seg_len),
                                          NEWLINE, sepchar);
            END IF;
         END IF;
         seg_index := seg_index + 1;
         seg_start := seg_end + sepchar_len;
      END LOOP;
    ELSIF ((catsegs IS NULL) AND (sepchar IS NULL)) THEN
      seg_index :=1;
    ELSIF ((catsegs IS NULL) AND (sepchar IS NOT NULL)) THEN
      segs(1) := NULL;
      seg_index := 2;
    ELSIF ((catsegs IS NOT NULL) AND (sepchar IS NULL)) THEN
      seg_index := 1;
   END IF;
   RETURN(To_number(seg_index - 1));
END to_stringarray2;

/* ----------------------------------------------------------------------- */
/*               Converts segment array to concatenated segments           */
/*      Segment array is 1-based containing entries for 1 <= i <= nsegs    */
/* ----------------------------------------------------------------------- */
FUNCTION from_stringarray2(nsegs   IN NUMBER,
                           segs    IN StringArray,
                           sepchar IN VARCHAR2) RETURN VARCHAR2
  IS
     l_return VARCHAR2(2000) := NULL;
BEGIN
   IF (fnd_flex_server1.g_debug_level > 0) THEN
      fnd_flex_server1.add_debug('CALL SV1.from_stringarray2()');
   END IF;
   --
   -- Concatenate the segment values. No separator after the last value.
   --
   IF (nsegs > 0) THEN
      FOR i IN 1..(nsegs-1) LOOP
         l_return := l_return || REPLACE(segs(i), sepchar, NEWLINE) || sepchar;
      END LOOP;
      l_return := l_return || REPLACE(segs(nsegs), sepchar, NEWLINE);
   END IF;
   RETURN(l_return);
END from_stringarray2;


--------------------------------------------------------------------------------
-- This procedure parses a SQL string into following pieces:
--   - bind               (i.e. :bind portion of a SQL statement)
--   - single quoted      (i.e. string literal portion of a SQL statement)
--   - sql                (i.e. rest of the sql statement)
--
--------------------------------------------------------------------------------
procedure parse_sql_string(p_sql_string  in varchar2,
                           px_sql_pieces in out nocopy sql_pieces_tab_type)
  IS
     l_sql_string      varchar2(32000);
     l_sql_piece_count BINARY_INTEGER;
     l_first_chr       varchar2(1);
     l_tmp_string      varchar2(32000);

     l_quote_pos       number;
     l_quote2_pos      number;
     l_colon_pos       number;
     l_end_pos         number;
begin
   l_sql_string := p_sql_string;
   l_sql_piece_count := 0;
   px_sql_pieces.DELETE;

   while (l_sql_string is not null) loop

      l_first_chr := substr(l_sql_string, 1, 1);

      if (l_first_chr = SSP_QUOTE) then
         --
         -- single quoted section, find the end
         --
         l_quote2_pos := 0;
         loop
            --
            -- Skip double single quotes
            --
            l_quote_pos := instr(l_sql_string, SSP_QUOTE, l_quote2_pos + 2);
            if (l_quote_pos = 0) then
               --
               -- Error, not terminated properly
               --
               FND_MESSAGE.set_name('FND', 'FLEX-SQL MISSING QUOTE');
               FND_MESSAGE.set_token('CLAUSE', p_sql_string);

               raise_application_error
                 (-20001,
                  'Error: Single Quote is not terminated properly. ' ||
                  'SQL: ' || p_sql_string);
            else
               l_quote2_pos := instr(l_sql_string, SSP_QUOTE2, l_quote_pos);
               if (l_quote2_pos = l_quote_pos) then
                  --
                  -- double single quote, skip it
                  --
                  null;
               else
                  --
                  -- end of single quoted section
                  --
                  exit;
               end if;
            end if;
         end loop;

         l_sql_piece_count := l_sql_piece_count + 1;
         px_sql_pieces(l_sql_piece_count).piece_type := SSP_PIECE_TYPE_QUOTED;
         px_sql_pieces(l_sql_piece_count).piece_text := substr(l_sql_string, 1, l_quote_pos);

         l_sql_string := substr(l_sql_string, l_quote_pos + 1);

      elsif (l_first_chr = SSP_COLON) then
         --
         -- bind section
         --
         l_tmp_string := ltrim(l_sql_string, SSP_BIND_CHARS);

         l_sql_piece_count := l_sql_piece_count + 1;
         px_sql_pieces(l_sql_piece_count).piece_type := SSP_PIECE_TYPE_BIND;
         px_sql_pieces(l_sql_piece_count).piece_text := substr(l_sql_string, 1, length(l_sql_string) - nvl(length(l_tmp_string), 0));

         l_sql_string := l_tmp_string;

      else
         --
         -- sql section, find the end
         --
         l_quote_pos := instr(l_sql_string, SSP_QUOTE);
         l_colon_pos := instr(l_sql_string, SSP_COLON);

         if ((l_quote_pos = 0) and (l_colon_pos = 0)) then
            --
            -- no quotes, no binds, the remaining section is just sql
            --
            l_end_pos := length(l_sql_string);

         elsif (l_quote_pos = 0) then
            --
            -- no quotes
            --
            l_end_pos := l_colon_pos - 1;

         elsif (l_colon_pos = 0) then
            --
            -- no binds
            --
            l_end_pos := l_quote_pos - 1;

         else
            --
            -- both quotes, and binds
            --
            l_end_pos := least(l_quote_pos, l_colon_pos) - 1;

         end if;

         l_sql_piece_count := l_sql_piece_count + 1;
         px_sql_pieces(l_sql_piece_count).piece_type := SSP_PIECE_TYPE_SQL;
         px_sql_pieces(l_sql_piece_count).piece_text := substr(l_sql_string, 1, l_end_pos);

         l_sql_string := substr(l_sql_string, l_end_pos + 1);

      end if;
   end loop;
end parse_sql_string;


/**** ReadOnly Project UnComment when ready
--******************************************************************************************
-- This procedure reads the rbac api's to determine which KFF
-- segments need to be readonly during insert/update
--------------------------------------------------------------------------------
-- This procedure gets rbac security settings for kff segment
-- settings.  Rbac api's are called to determine if rbac secuirty
-- is defined. If so, then insert/update permissions are checked for each segment.
-- The permissions are returned in a concatenated string.
-- Types of permissions are E/D/U.  E=enabled, D=disabled, U=unknown
-- Example: checking insert permissions
-- segment1.segment2.segment3.segment4
-- segment1 is enabled
-- segment2 is disabled
-- segment3 is enabled
-- segment4 is enabled
-- x_ins_permissions will return E.D.E.E

-- Example: checking update permissions
-- segment1.segment2.segment3.segment4
-- segment1 is disabled
-- segment2 is enabled
-- segment3 is disabled
-- segment4 is enabled
-- x_upd_permissions will return D.E.D.E

-- The Calling routine will parse these variables and set each segment accordingly to
-- the permission defined. If the segment is enabled then the UI will allow
-- user entry into the segment field. If the segment is disabled, then the UI
-- will make the segment field Read Only.

-- Out Variables:
-- x_status returns true or false. True if rbac is defined and false if rbac is  not defined.
-- x_ins_permissions returns a concatenated string of insert permissions as desc above.
-- x_upd_permissions returns a concatenated string of update permissions as desc above.
--******************************************************************************************
PROCEDURE KFF_RO_SEGMENT_RBAC(
   p_appid    in NUMBER,
   p_code     in VARCHAR2,
   p_structid in NUMBER,
   x_segment_names      out nocopy VARCHAR2,
   x_status             out nocopy VARCHAR2,
   x_ins_permissions    out nocopy VARCHAR2,
   x_upd_permissions    out nocopy VARCHAR2)

 IS
   l_predicate varchar2(31900);
   l_status varchar2(1);
   InsertEnabled varchar2(1);
   InsertDisabled varchar2(1);
   updateEnabled varchar2(1);
   updateDisabled varchar2(1);
   rbac_key_sql VARCHAR2(32000);
   key_sql VARCHAR2(32000);
   num_returned NUMBER;
   seg_name VARCHAR2(30);
   cursornum INTEGER;
   application_id NUMBER;
   id_flex_code VARCHAR2(10);
   id_flex_num NUMBER;
   l_string long;
   i integer;

   begin

   x_ins_permissions :='';
   x_upd_permissions :='';
   x_segment_names :='';

   application_id := p_appid;
   id_flex_code:= p_code;
   id_flex_num := p_structid;

   -- RBAC API, determine if a security predicate is defined.
   -- If not, then there is not secuirty defined for this object.
   FND_DATA_SECURITY.get_security_predicate(
   p_api_version => 1.0,
   p_object_name => 'FND_FLEX_RO_KFF_SEG_OBJ',
   p_grant_instance_type => 'SET',
   x_predicate => l_predicate,
   x_return_status => l_status);


   IF (l_status = 'T') THEN -- rbac is defined

       -- Build the filter sql statement to prepend to the rbac predicate
       -- The filter sql "key_sql" limits the query to the kff being processed by the UI.
       key_sql :=
       ' select segment_name
       from fnd_id_flex_segments ckalias
       where
       ckalias.application_id= :APID and
       ckalias.id_flex_code= :CODE and
       ckalias.id_flex_num = :NUM and
       ckalias.enabled_flag=''Y'' and ';

       -- Concatenate the filter "key_sql" with the predicate sql "l_predicate" for complete sql "rbac_key_sql"
       -- to be executed to return segment names that have security defined.
       -- The filter sql "key_sql" limits the query to the kff being processed
       -- by the UI. There maybe multiple kff's on a UI so we must restrict the predicate
       -- sql to the kff being processed. We do that by adding "key_sql".
       -- The predicate by itself will give false positives. It will give segment names for
       -- for all mataching flexfields even if it is not the one being processed.

       -- Example of complete sql built "rbac_key_sql":
       ------------------------------------------------------------------------------------------------
       -- select segment_name from fnd_id_flex_segments ckalias (Begining of filter sql)
       -- where
       -- ckalias.application_id=101 and
       -- ckalias.id_flex_code= 'GL#' and
       -- ckalias.id_flex_num = 50214 and
       -- ckalias.enabled_flag = 'Y' and                        (End of filter sql)
       -- ( exists (select null from fnd_grants gnt             (Beginning of predicate sql)
       -- where gnt.grant_guid in (hextoraw('43B86ADFBC5D37CBE0533C8E8D0A6629')) AND segment_name in (select segment_name from
       -- fnd_id_flex_segments b where ckalias.application_id=b.application_id and
       -- ckalias.id_flex_code=b.id_flex_code and ckalias.id_flex_num = b.id_flex_num and
       -- b.application_id= GNT.PARAMETER1 and b.id_flex_code = GNT.PARAMETER2 and
       -- b.id_flex_num in (GNT.PARAMETER3, GNT.PARAMETER4, GNT.PARAMETER5, GNT.PARAMETER6, GNT.PARAMETER7,
       -- GNT.PARAMETER8, GNT.PARAMETER9, GNT.PARAMETER10))))   (End of predicate sql)

       -- Note: The filter sql uses the alias ckalias because the rbac predicate creates an alias
       -- named ckalias. In order for both parts of the sql to match. I had to call the filter alias ckalias.
       -- The predicate here will return all segments for all structures defined


       rbac_key_sql := key_sql || l_predicate;

       cursornum := dbms_sql.open_cursor;
       fnd_dsql.set_cursor(cursornum);

       dbms_sql.parse(cursornum, rbac_key_sql, dbms_sql.v7);
       fnd_dsql.do_binds;
       dbms_sql.bind_variable(cursornum, ':APID', application_id);
       dbms_sql.bind_variable(cursornum, ':CODE', id_flex_code);
       dbms_sql.bind_variable(cursornum, ':NUM', id_flex_num);
       dbms_sql.define_column(cursornum, 1, seg_name, 30);
       num_returned := dbms_sql.execute(cursornum);

       i := 0;
       LOOP
         EXIT
         WHEN dbms_sql.fetch_rows(cursornum) = 0;

         dbms_sql.column_value(cursornum, 1, seg_name);
         x_segment_names := x_segment_names || seg_name || ':';

         -- If the rbac_key_sql statement returns rows/segment names,
         -- then we check the permission for each segment and build
         -- a concatenated string that indicates the permission for each
         -- segment to pass back to calling function

         InsertEnabled := FND_DATA_SECURITY.check_function(
                 p_api_version => 1.0,
                 p_function =>'FND_FLEX_RO_SEG_INSERT_ENABLE',
                 p_object_name => 'FND_FLEX_RO_KFF_SEG_OBJ',
                 p_instance_pk1_value => application_id,
                 p_instance_pk2_value => id_flex_code,
                 p_instance_pk3_value => id_flex_num,
                 p_instance_pk4_value => seg_name);

         InsertDisabled := FND_DATA_SECURITY.check_function(
                 p_api_version => 1.0,
                 p_function =>'FND_FLEX_RO_SEG_INSERT_DISABLE',
                 p_object_name => 'FND_FLEX_RO_KFF_SEG_OBJ',
                 p_instance_pk1_value => application_id,
                 p_instance_pk2_value => id_flex_code,
                 p_instance_pk3_value => id_flex_num,
                 p_instance_pk4_value => seg_name);

         UpdateEnabled := FND_DATA_SECURITY.check_function(
                 p_api_version => 1.0,
                 p_function =>'FND_FLEX_RO_SEG_UPDATE_ENABLE',
                 p_object_name => 'FND_FLEX_RO_KFF_SEG_OBJ',
                 p_instance_pk1_value => application_id,
                 p_instance_pk2_value => id_flex_code,
                 p_instance_pk3_value => id_flex_num,
                 p_instance_pk4_value => seg_name);

         UpdateDisabled := FND_DATA_SECURITY.check_function(
                 p_api_version => 1.0,
                 p_function =>'FND_FLEX_RO_SEG_UPDATE_DISABLE',
                 p_object_name => 'FND_FLEX_RO_KFF_SEG_OBJ',
                 p_instance_pk1_value => application_id,
                 p_instance_pk2_value => id_flex_code,
                 p_instance_pk3_value => id_flex_num,
                 p_instance_pk4_value => seg_name);

         if (InsertEnabled = 'T' AND InsertDisabled = 'T' ) then  -- Use most restrictive
             x_ins_permissions := x_ins_permissions || 'D' || ':';
         elsif (InsertEnabled <> 'T' AND InsertDisabled <> 'T' ) then  -- No permission defined
             x_ins_permissions := x_ins_permissions || 'U' || ':';
         elsif (InsertEnabled = 'T') then
             x_ins_permissions := x_ins_permissions || 'E' || ':';
         elsif (InsertDisabled = 'T' ) then
             x_ins_permissions := x_ins_permissions || 'D' || ':';
         end if;

         if (UpdateEnabled = 'T' AND UpdateDisabled = 'T' ) then  -- Use most restrictive
             x_upd_permissions := x_upd_permissions || 'D' || ':';
         elsif (UpdateEnabled <> 'T' AND UpdateDisabled <> 'T' ) then  -- No permission defined
             x_upd_permissions := x_upd_permissions || 'U' || ':';
         elsif (UpdateEnabled = 'T') then
             x_upd_permissions := x_upd_permissions || 'E' || ':';
         elsif (UpdateDisabled = 'T' ) then
             x_upd_permissions := x_upd_permissions || 'D' || ':';
         end if;

         i := i+1;

       END LOOP;

       if(dbms_sql.is_open(cursornum)) then
          dbms_sql.close_cursor(cursornum);
       end if;

   END IF;
   x_status := l_status;

END;


--******************************************************************************************
-- This procedure reads the rbac api's to determine which DFF
-- segments need to be readonly during insert/update
--------------------------------------------------------------------------------
-- This procedure gets rbac security settings for dff segment
-- settings.  Rbac api's are called to determine if rbac secuirty
-- is defined. If so, then insert/update permissions are checked for each segment.
-- The permissions are returned in a concatenated string.
-- Types of permissions are E/D/U.  E=enabled, D=disabled, U=unknown
-- Example: checking insert permissions
-- segment1.segment2.segment3.segment4
-- segment1 is enabled
-- segment2 is disabled
-- segment3 is enabled
-- segment4 is enabled
-- x_ins_permissions will return E.D.E.E

-- Example: checking update permissions
-- segment1.segment2.segment3.segment4
-- segment1 is disabled
-- segment2 is enabled
-- segment3 is disabled
-- segment4 is enabled
-- x_upd_permissions will return D.E.D.E

-- The Calling routine will parse these variables and set each segment accordingly to
-- the permission defined. If the segment is enabled then the UI will allow
-- user entry into the segment field. If the segment is disabled, then the UI
-- will make the segment field Read Only.

-- Out Variables:
-- x_status returns true or false. True if rbac is defined and false if rbac is  not defined.
-- x_ins_permissions returns a concatenated string of insert permissions as desc above.
-- x_upd_permissions returns a concatenated string of update permissions as desc above.
--******************************************************************************************
PROCEDURE DFF_RO_SEGMENT_RBAC(
   p_appid        in NUMBER,
   p_dff_name     in VARCHAR2,
   p_context_code in VARCHAR2,
   x_segment_names out nocopy VARCHAR2,
   x_seg_status        out nocopy VARCHAR2,
   x_ins_permissions   out nocopy VARCHAR2,
   x_upd_permissions   out nocopy VARCHAR2)

 IS
   l_predicate varchar2(31900);
   l_status varchar2(1);
   InsertEnabled varchar2(1);
   InsertDisabled varchar2(1);
   updateEnabled varchar2(1);
   updateDisabled varchar2(1);
   rbac_dff_sql VARCHAR2(32000);
   dff_sql VARCHAR2(32000);
   num_returned NUMBER;
   seg_name VARCHAR2(30);
   cursornum INTEGER;
   application_id NUMBER;
   dff_name VARCHAR2(40);
   context_code VARCHAR2(30);
   l_string long;
   i integer;

   begin

   x_ins_permissions :='';
   x_upd_permissions :='';
   x_segment_names :='';

   application_id := p_appid;
   dff_name:= p_dff_name;
   context_code:= p_context_code;

   FND_DATA_SECURITY.get_security_predicate(
   p_api_version => 1.0,
   p_object_name => 'FND_FLEX_RO_DFF_SEG_OBJ',
   p_grant_instance_type => 'SET',
   x_predicate => l_predicate,
   x_return_status => l_status);


   IF (l_status = 'T') THEN
       dff_sql :=
       ' select end_user_column_name
       from fnd_descr_flex_column_usages ckalias
       where
       ckalias.application_id= :APID and
       ckalias.descriptive_flexfield_name= :DFF_NAME and
       ckalias.descriptive_flex_context_code = :CONTEXT_CODE and
       ckalias.enabled_flag=''Y'' and ';


       -- Concatenate the filter "dff_sql" with the predicate sql "l_predicate" for complete sql "rbac_dff_sql"
       -- to be executed to return segment names that have security defined.
       -- The filter sql "dff_sql" limits the query to the dff being processed
       -- by the UI. There maybe multiple dff's on a UI so we must restrict the predicate
       -- sql to the dff being processed. We do that by adding "dff_sql".
       -- The predicate by itself will give false positives. It will give segment names for
       -- for all mataching flexfields even if it is not the one being processed.

       -- Example of complete sql built "rbac_dff_sql":
       ------------------------------------------------------------------------------------------------
       -- select segment_name from fnd_id_flex_segments ckalias (Begining of filter sql)
       -- where
       -- ckalias.application_id=101 and
       -- ckalias.descriptive_flexfield_name= 'FND_FLEX_TEST' and
       -- ckalias.descriptive_flex_context_code = 'CC1' and
       -- ckalias.enabled_flag = 'Y' and                        (End of filter sql)
       -- ( exists (select null from fnd_grants gnt             (Beginning of predicate sql)
       -- where gnt.grant_guid in (hextoraw('43B86ADFBC5D37CBE0533C8E8D0A6629')) AND segment_name in (select segment_name from
       -- fnd_descr_flex_column_usages b where ckalias.application_id=b.application_id and
       -- ckalias.descriptive_flexfield_name=b.descriptive_flexfield_name and
       -- ckalias.descriptive_flex_context_code = b.descriptive_flex_context_code and
       -- b.application_id= GNT.PARAMETER1 and b.descriptive_flexfield_name = GNT.PARAMETER2 and
       -- b.descriptive_flex_context_code in (GNT.PARAMETER3, GNT.PARAMETER4, GNT.PARAMETER5, GNT.PARAMETER6, GNT.PARAMETER7,
       -- GNT.PARAMETER8, GNT.PARAMETER9, GNT.PARAMETER10))))   (End of predicate sql)

       -- Note: The filter sql uses the alias ckalias because the rbac predicate creates an alias
       -- named ckalias. In order for both parts of the sql to match. I had to call the filter alias ckalias.
       -- The predicate here will return all segments for all contexts defined


       rbac_dff_sql := dff_sql || l_predicate;

       cursornum := dbms_sql.open_cursor;
       fnd_dsql.set_cursor(cursornum);

       dbms_sql.parse(cursornum, rbac_dff_sql, dbms_sql.v7);
       fnd_dsql.do_binds;
       dbms_sql.bind_variable(cursornum, ':APID', application_id);
       dbms_sql.bind_variable(cursornum, ':DFF_NAME', dff_name);
       dbms_sql.bind_variable(cursornum, ':CONTEXT_CODE', context_code);
       dbms_sql.define_column(cursornum, 1, seg_name, 30);
       num_returned := dbms_sql.execute(cursornum);
       LOOP
         EXIT
         WHEN dbms_sql.fetch_rows(cursornum) = 0;

         dbms_sql.column_value(cursornum, 1, seg_name);
         x_segment_names := x_segment_names || seg_name || ':';

         -- If the rbac_key_sql statement returns rows/segment names,
         -- then we check the permission for each segment and build
         -- a concatenated string that indicates the permission for each
         -- segment to pass back to calling function

         InsertEnabled := FND_DATA_SECURITY.check_function(
                 p_api_version => 1.0,
                 p_function =>'FND_FLEX_RO_SEG_INSERT_ENABLE',
                 p_object_name => 'FND_FLEX_RO_DFF_SEG_OBJ',
                 p_instance_pk1_value => application_id,
                 p_instance_pk2_value => dff_name,
                 p_instance_pk3_value => context_code,
                 p_instance_pk4_value => seg_name);

         InsertDisabled := FND_DATA_SECURITY.check_function(
                 p_api_version => 1.0,
                 p_function =>'FND_FLEX_RO_SEG_INSERT_DISABLE',
                 p_object_name => 'FND_FLEX_RO_DFF_SEG_OBJ',
                 p_instance_pk1_value => application_id,
                 p_instance_pk2_value => dff_name,
                 p_instance_pk3_value => context_code,
                 p_instance_pk4_value => seg_name);

         UpdateEnabled := FND_DATA_SECURITY.check_function(
                 p_api_version => 1.0,
                 p_function =>'FND_FLEX_RO_SEG_UPDATE_ENABLE',
                 p_object_name => 'FND_FLEX_RO_DFF_SEG_OBJ',
                 p_instance_pk1_value => application_id,
                 p_instance_pk2_value => dff_name,
                 p_instance_pk3_value => context_code,
                 p_instance_pk4_value => seg_name);

         UpdateDisabled := FND_DATA_SECURITY.check_function(
                 p_api_version => 1.0,
                 p_function =>'FND_FLEX_RO_SEG_UPDATE_DISABLE',
                 p_object_name => 'FND_FLEX_RO_DFF_SEG_OBJ',
                 p_instance_pk1_value => application_id,
                 p_instance_pk2_value => dff_name,
                 p_instance_pk3_value => context_code,
                 p_instance_pk4_value => seg_name);

         if (InsertEnabled = 'T' AND InsertDisabled = 'T' ) then  -- Use most restrictive
             x_ins_permissions := x_ins_permissions || 'D' || ':';
         elsif (InsertEnabled <> 'T' AND InsertDisabled <> 'T' ) then  -- No permission defined
             x_ins_permissions := x_ins_permissions || 'U' || ':';
         elsif (InsertEnabled = 'T') then
             x_ins_permissions := x_ins_permissions || 'E' || ':';
         elsif (InsertDisabled = 'T' ) then
             x_ins_permissions := x_ins_permissions || 'D' || ':';
         end if;

         if (UpdateEnabled = 'T' AND UpdateDisabled = 'T' ) then  -- Use most restrictive
             x_upd_permissions := x_upd_permissions || 'D' || ':';
         elsif (UpdateEnabled <> 'T' AND UpdateDisabled <> 'T' ) then  -- No permission defined
             x_upd_permissions := x_upd_permissions || 'U' || ':';
         elsif (UpdateEnabled = 'T') then
             x_upd_permissions := x_upd_permissions || 'E' || ':';
         elsif (UpdateDisabled = 'T' ) then
             x_upd_permissions := x_upd_permissions || 'D' || ':';
         end if;

       END LOOP;

       if(dbms_sql.is_open(cursornum)) then
          dbms_sql.close_cursor(cursornum);
       end if;

   END IF;

   if (x_segment_names IS NULL) then
      x_seg_status := 'F';
   else
      x_seg_status := l_status;
   end if;

END;


--******************************************************************************************
-- This procedure reads the rbac api's to determine if Context DFF
-- field needs to be readonly during insert/update
--------------------------------------------------------------------------------
-- This procedure gets rbac security settings for dff context field
-- settings.  Rbac api's are called to determine if rbac secuirty
-- is defined. If so, then insert/update permissions are checked for context field.
-- The permission is returned in a string.
-- Types of permissions are E/D/U.  E=enabled, D=disabled, U=unknown
-- Example: checking insert permissions
-- context field is enabled
-- x_ins_permissions will return E

-- Example: checking update permissions
-- context field is disabled
-- x_upd_permissions will return D

-- The Calling routine will parse this variable and set context field accordingly to
-- the permission defined. If the context field is enabled then the UI will allow
-- user entry into the context field. If the context field is disabled, then the UI
-- will make the context field Read Only.

-- Out Variables:
-- x_ctxf_status returns true or false. True if rbac is defined and false if rbac is  not defined.
-- x_ins_permissions returns a string of insert permission as desc above.
-- x_upd_permissions returns a string of update permission as desc above.
--******************************************************************************************
PROCEDURE DFF_RO_CTXT_FLD_RBAC(
   p_appid        in NUMBER,
   p_dff_name     in VARCHAR2,
   x_ctxf_status        out nocopy VARCHAR2,
   x_ins_permissions   out nocopy VARCHAR2,
   x_upd_permissions   out nocopy VARCHAR2)

 IS
   l_predicate varchar2(31900);
   l_status varchar2(1);
   InsertEnabled varchar2(1);
   InsertDisabled varchar2(1);
   updateEnabled varchar2(1);
   updateDisabled varchar2(1);
   rbac_dff_sql VARCHAR2(32000);
   dff_sql VARCHAR2(32000);
   num_returned NUMBER;
   cursornum INTEGER;
   application_id NUMBER;
   dff_name VARCHAR2(40);
   context_name VARCHAR2(30);
   l_string long;
   i integer;

   begin

   x_ins_permissions :='';
   x_upd_permissions :='';

   application_id := p_appid;
   dff_name:= p_dff_name;

   FND_DATA_SECURITY.get_security_predicate(
   p_api_version => 1.0,
   p_object_name => 'FND_FLEX_RO_DFF_CTXT_FLD_OBJ',
   p_grant_instance_type => 'SET',
   x_predicate => l_predicate,
   x_return_status => l_status);


   IF (l_status = 'T') THEN
       dff_sql :=
       ' select ''Context''
       from fnd_descriptive_flexs ckalias
       where
       ckalias.application_id= :APID and
       ckalias.descriptive_flexfield_name= :DFF_NAME and ';

       -- Concatenate the filter "dff_sql" with the predicate sql "l_predicate" for complete sql "rbac_dff_sql"
       -- to be executed to return 'Context' if security is defined for context field.
       -- The filter sql "dff_sql" limits the query to the dff being processed
       -- by the UI. There maybe multiple dff's on a UI so we must restrict the predicate
       -- sql to the dff being processed. We do that by adding "dff_sql".
       -- The predicate by itself will give false positives. It will give segment names for
       -- for all mataching flexfields even if it is not the one being processed.

       -- Example of complete sql built "rbac_dff_sql":
       ------------------------------------------------------------------------------------------------
       -- select segment_name from fnd_id_flex_segments ckalias (Begining of filter sql)
       -- where
       -- ckalias.application_id=101 and
       -- ckalias.descriptive_flexfield_name= 'FND_FLEX_TEST' and (End of filter sql)
       -- ( exists (select null from fnd_grants gnt             (Beginning of predicate sql)
       -- where gnt.grant_guid in (hextoraw('43B86ADFBC5D37CBE0533C8E8D0A6629')) AND descriptive_flexfield_name in
       -- (select descriptive_flexfield_name from
       -- fnd_descriptive_flexs b where ckalias.application_id=b.application_id and
       -- ckalias.descriptive_flexfield_name=b.descriptive_flexfield_name and
       -- b.application_id= GNT.PARAMETER1 and b.descriptive_flexfield_name = GNT.PARAMETER2)))   (End of predicate sql)

       -- Note: The filter sql uses the alias ckalias because the rbac predicate creates an alias
       -- named ckalias. In order for both parts of the sql to match. I had to call the filter alias ckalias.



       rbac_dff_sql := dff_sql || l_predicate;

       cursornum := dbms_sql.open_cursor;
       fnd_dsql.set_cursor(cursornum);

       dbms_sql.parse(cursornum, rbac_dff_sql, dbms_sql.v7);
       fnd_dsql.do_binds;
       dbms_sql.bind_variable(cursornum, ':APID', application_id);
       dbms_sql.bind_variable(cursornum, ':DFF_NAME', dff_name);
       dbms_sql.define_column(cursornum, 1, context_name, 30);
       num_returned := dbms_sql.execute_and_fetch(cursornum, FALSE);

       dbms_sql.column_value(cursornum, 1, context_name);

       if (context_name IS NOT NULL) then

         -- If the rbac_dff_sql statement returns Context,
         -- then we check the permission for the context and
         -- return a string that indicates the permission of that context fld

            InsertEnabled := FND_DATA_SECURITY.check_function(
                    p_api_version => 1.0,
                    p_function =>'FND_FLEX_RO_SEG_INSERT_ENABLE',
                    p_object_name => 'FND_FLEX_RO_DFF_CTXT_FLD_OBJ',
                    p_instance_pk1_value => application_id,
                    p_instance_pk2_value => dff_name);

            InsertDisabled := FND_DATA_SECURITY.check_function(
                    p_api_version => 1.0,
                    p_function =>'FND_FLEX_RO_SEG_INSERT_DISABLE',
                    p_object_name => 'FND_FLEX_RO_DFF_CTXT_FLD_OBJ',
                    p_instance_pk1_value => application_id,
                    p_instance_pk2_value => dff_name);

            UpdateEnabled := FND_DATA_SECURITY.check_function(
                    p_api_version => 1.0,
                    p_function =>'FND_FLEX_RO_SEG_UPDATE_ENABLE',
                    p_object_name => 'FND_FLEX_RO_DFF_CTXT_FLD_OBJ',
                    p_instance_pk1_value => application_id,
                    p_instance_pk2_value => dff_name);

            UpdateDisabled := FND_DATA_SECURITY.check_function(
                    p_api_version => 1.0,
                    p_function =>'FND_FLEX_RO_SEG_UPDATE_DISABLE',
                    p_object_name => 'FND_FLEX_RO_DFF_CTXT_FLD_OBJ',
                    p_instance_pk1_value => application_id,
                    p_instance_pk2_value => dff_name);

            if (InsertEnabled = 'T' AND InsertDisabled = 'T' ) then  -- Use most restrictive
                x_ins_permissions := 'D';
            elsif (InsertEnabled <> 'T' AND InsertDisabled <> 'T' ) then  -- No permission defined
                x_ins_permissions := 'U';
            elsif (InsertEnabled = 'T') then
                x_ins_permissions := 'E';
            elsif (InsertDisabled = 'T' ) then
                x_ins_permissions := 'D';
            end if;

            if (UpdateEnabled = 'T' AND UpdateDisabled = 'T' ) then  -- Use most restrictive
                x_upd_permissions := 'D';
            elsif (UpdateEnabled <> 'T' AND UpdateDisabled <> 'T' ) then  -- No permission defined
                x_upd_permissions := 'U';
            elsif (UpdateEnabled = 'T') then
                x_upd_permissions := 'E';
            elsif (UpdateDisabled = 'T' ) then
                x_upd_permissions := 'D';
            end if;

            if (context_name IS NULL) then
               x_ctxf_status := 'F';
            else
               x_ctxf_status := l_status;
            end if;
       ELSE
            x_ctxf_status := 'F';
       end if;

     if(dbms_sql.is_open(cursornum)) then
        dbms_sql.close_cursor(cursornum);
     end if;

   END IF;

END;

*** End of ReadOnly code *****/


BEGIN
   chr_newline := fnd_global.newline;
   NEWLINE     := fnd_global.newline;
   TAB         := fnd_global.tab;
   WHITESPACE  := ' ' || TAB || NEWLINE;

   fnd_plsql_cache.generic_1to1_init('SV1.VST',
                                     vst_cache_controller,
                                     vst_cache_storage);

   fnd_plsql_cache.generic_1to1_init('SV1.VSC',
                                     vsc_cache_controller,
                                     vsc_cache_storage);

   fnd_plsql_cache.generic_1to1_init('SV1.FVC',
                                     fvc_cache_controller,
                                     fvc_cache_storage);

   fnd_plsql_cache.generic_1tom_init('SV1.FSQ',
                                     fsq_cache_controller,
                                     fsq_cache_storage);

   fnd_plsql_cache.generic_1tom_init('SV1.VSQ',
                                     vsq_cache_controller,
                                     vsq_cache_storage);

   fnd_plsql_cache.custom_1tom_init('SV1.STR',
                                    str_cache_controller);
   str_cache_storage.DELETE;

   --
   -- Decimal separators.
   --
   IF (fnd_flex_val_util.get_mask('CANONICAL_NUMERIC_CHARS',tmp_varchar2)) THEN
      m_nc := Substr(tmp_varchar2,1,1);
    ELSE
      m_nc := '.';
   END IF;

   IF (fnd_flex_val_util.get_mask('DB_NUMERIC_CHARS',tmp_varchar2)) THEN
      m_nb := Substr(tmp_varchar2,1,1);
    ELSE
      m_nb := '.';
   END IF;

   IF (fnd_flex_val_util.get_mask('NLS_NUMERIC_CHARS_OUT',tmp_varchar2)) THEN
      m_nd := Substr(tmp_varchar2,1,1);
    ELSE
      m_nd := '.';
   END IF;
END fnd_flex_server1;

/
