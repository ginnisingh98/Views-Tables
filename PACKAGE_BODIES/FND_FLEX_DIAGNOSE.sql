--------------------------------------------------------
--  DDL for Package Body FND_FLEX_DIAGNOSE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FLEX_DIAGNOSE" AS
/* $Header: AFFFDGNB.pls 120.4.12010000.1 2008/07/25 14:13:53 appldev ship $ */

-- ==================================================
-- Constants and Types.
-- ==================================================
g_api_name       VARCHAR2(10)  := 'DGN.';
g_std_date_mask  VARCHAR2(100) := 'YYYY/MM/DD HH24:MI:SS';
g_line_size      NUMBER        := 75;
g_text_size      NUMBER        := 1950;
g_newline        VARCHAR2(10);

SUBTYPE app_type         IS fnd_application%ROWTYPE;
SUBTYPE tbl_type         IS fnd_tables%ROWTYPE;
SUBTYPE col_type         IS fnd_columns%ROWTYPE;
SUBTYPE rsp_type         IS fnd_responsibility%ROWTYPE;

SUBTYPE vst_set_type     IS fnd_flex_value_sets%ROWTYPE;
SUBTYPE vst_tbl_type     IS fnd_flex_validation_tables%ROWTYPE;
SUBTYPE vst_evt_type     IS fnd_flex_validation_events%ROWTYPE;
SUBTYPE vst_scr_type     IS fnd_flex_value_rules%ROWTYPE;
SUBTYPE vst_scl_type     IS fnd_flex_value_rule_lines%ROWTYPE;
SUBTYPE vst_scu_type     IS fnd_flex_value_rule_usages%ROWTYPE;
SUBTYPE vst_rlg_type     IS fnd_flex_hierarchies%ROWTYPE;
SUBTYPE vst_val_type     IS fnd_flex_values%ROWTYPE;
SUBTYPE vst_fvn_type     IS fnd_flex_value_norm_hierarchy%ROWTYPE;
SUBTYPE vst_fvh_type     IS fnd_flex_value_hierarchies%ROWTYPE;

SUBTYPE dff_flx_type     IS fnd_descriptive_flexs%ROWTYPE;
SUBTYPE dff_ctx_type     IS fnd_descr_flex_contexts%ROWTYPE;
SUBTYPE dff_seg_type     IS fnd_descr_flex_column_usages%ROWTYPE;

SUBTYPE kff_flx_type     IS fnd_id_flexs%ROWTYPE;
SUBTYPE kff_str_type     IS fnd_id_flex_structures%ROWTYPE;
SUBTYPE kff_seg_type     IS fnd_id_flex_segments%ROWTYPE;
SUBTYPE kff_flq_type     IS fnd_segment_attribute_types%ROWTYPE;
SUBTYPE kff_qlv_type     IS fnd_segment_attribute_values%ROWTYPE;
SUBTYPE kff_sgq_type     IS fnd_value_attribute_types%ROWTYPE;
SUBTYPE kff_sha_type     IS fnd_shorthand_flex_aliases%ROWTYPE;
SUBTYPE kff_cvr_type     IS fnd_flex_validation_rules%ROWTYPE;
SUBTYPE kff_cvl_type     IS fnd_flex_validation_rule_lines%ROWTYPE;
SUBTYPE kff_cvi_type     IS fnd_flex_include_rule_lines%ROWTYPE;
SUBTYPE kff_cve_type     IS fnd_flex_exclude_rule_lines%ROWTYPE;
SUBTYPE kff_fwp_type     IS fnd_flex_workflow_processes%ROWTYPE;

-- ***************************************************************************
-- * Helper functions.
-- ***************************************************************************
-- ---------------------------------------------------------------------------
-- Checks the existance of a lookup code.
--
FUNCTION lookup_code_exists(p_lookup_type IN VARCHAR2,
                            p_lookup_code IN VARCHAR2)
  RETURN BOOLEAN
  IS
     l_vc2 VARCHAR2(100);
BEGIN
   SELECT NULL
     INTO l_vc2
     FROM fnd_lookups
     WHERE lookup_type = p_lookup_type
     AND lookup_code = p_lookup_code;
   RETURN(TRUE);
EXCEPTION
   WHEN OTHERS THEN
      RETURN(FALSE);
END lookup_code_exists;

-- ---------------------------------------------------------------------------
-- Formats the string to fit into single line.
--
FUNCTION line_return(p_in VARCHAR2)
  RETURN VARCHAR2
  IS
BEGIN
   RETURN(Substr(p_in, 1, g_line_size));
END line_return;

-- ---------------------------------------------------------------------------
-- Formats the string to fit into mutliple lines.
--
FUNCTION text_return(p_in VARCHAR2)
  RETURN VARCHAR2
  IS
BEGIN
   RETURN(Substr(p_in, 1, g_text_size));
END text_return;

-- ---------------------------------------------------------------------------
-- Updates flexfield info in fnd_columns.
--
FUNCTION update_fnd_columns(p_col                       IN col_type,
                            p_flexfield_usage_code      IN VARCHAR2,
                            p_flexfield_application_id  IN NUMBER,
                            p_flexfield_name            IN VARCHAR2,
                            x_message                   OUT nocopy VARCHAR2)
  RETURN BOOLEAN
  IS
BEGIN
   UPDATE fnd_columns SET
     flexfield_usage_code     = p_flexfield_usage_code,
     flexfield_application_id = p_flexfield_application_id,
     flexfield_name           = p_flexfield_name,
     last_update_date         = Sysdate,
     last_updated_by          = 1
     WHERE application_id = p_col.application_id
     AND table_id = p_col.table_id
     AND column_id = p_col.column_id;
   x_message := SQL%rowcount || ' row(s) updated.';
   RETURN (TRUE);
EXCEPTION
   WHEN OTHERS THEN
      x_message := 'Unable to update FND_COLUMNS. ' || Sqlerrm;
      RETURN(FALSE);
END update_fnd_columns;

-- ---------------------------------------------------------------------------
-- Returns 'Unable to select from...' error.
--
FUNCTION msg_uts(p_table_name IN VARCHAR2,
                 p_key1       IN VARCHAR2,
                 p_value1     IN VARCHAR2,
                 p_key2       IN VARCHAR2 DEFAULT NULL,
                 p_value2     IN VARCHAR2 DEFAULT NULL,
                 p_key3       IN VARCHAR2 DEFAULT NULL,
                 p_value3     IN VARCHAR2 DEFAULT NULL,
                 p_key4       IN VARCHAR2 DEFAULT NULL,
                 p_value4     IN VARCHAR2 DEFAULT NULL,
                 p_key5       IN VARCHAR2 DEFAULT NULL,
                 p_value5     IN VARCHAR2 DEFAULT NULL,
                 p_key6       IN VARCHAR2 DEFAULT NULL,
                 p_value6     IN VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2
  IS
     l_message VARCHAR2(32000);
BEGIN
   l_message := 'Unable to select from ' || p_table_name || g_newline ||
     Rpad(Upper(p_key1),31,' ') || ':''' || p_value1 || '''';
   IF (p_key2 IS NOT NULL) THEN
      l_message := l_message || g_newline ||
        Rpad(Upper(p_key2),31,' ') || ':''' || p_value2 || '''';
      IF (p_key3 IS NOT NULL) THEN
         l_message := l_message || g_newline ||
           Rpad(Upper(p_key3),31,' ') || ':''' || p_value3 || '''';
         IF (p_key4 IS NOT NULL) THEN
            l_message := l_message || g_newline ||
              Rpad(Upper(p_key4),31,' ') || ':''' || p_value4 || '''';
            IF (p_key5 IS NOT NULL) THEN
               l_message := l_message || g_newline ||
                 Rpad(Upper(p_key5),31,' ') || ':''' || p_value5 || '''';
               IF (p_key6 IS NOT NULL) THEN
                  l_message := l_message || g_newline ||
                    Rpad(Upper(p_key6),31,' ') || ':''' || p_value6 || '''';
               END IF;
            END IF;
         END IF;
      END IF;
   END IF;
   l_message := l_message || g_newline || 'SQLERRM: ' || Sqlerrm;
   RETURN(text_return(l_message));
EXCEPTION
   WHEN OTHERS THEN
      RETURN(text_return('Unable to select from ' || p_table_name ||
                         g_newline || 'SQLERRM: ' || Sqlerrm));
END msg_uts;

-- ***************************************************************************
-- * Common fetch_stg() functions.
-- ***************************************************************************
-- ---------------------------------------------------------------------------
FUNCTION fetch_tbl(p_application_id IN NUMBER,
                   p_table_name     IN VARCHAR2,
                   x_tbl            OUT nocopy tbl_type,
                   x_message        OUT nocopy VARCHAR2)
  RETURN BOOLEAN
  IS
BEGIN
   SELECT *
     INTO x_tbl
     FROM fnd_tables
     WHERE application_id = p_application_id
     AND table_name = p_table_name;
   RETURN(TRUE);
EXCEPTION
   WHEN OTHERS THEN
      x_message := msg_uts('FND_TABLES',
                           'application_id', p_application_id,
                           'table_name', p_table_name);
      RETURN(FALSE);
END fetch_tbl;
-- ---------------------------------------------------------------------------
FUNCTION fetch_col(p_tbl            IN tbl_type,
                   p_column_name    IN VARCHAR2,
                   x_col            OUT nocopy col_type,
                   x_message        OUT nocopy VARCHAR2)
  RETURN BOOLEAN
  IS
BEGIN
   SELECT *
     INTO x_col
     FROM fnd_columns
     WHERE application_id = p_tbl.application_id
     AND table_id = p_tbl.table_id
     AND column_name = p_column_name;
   RETURN(TRUE);
EXCEPTION
   WHEN OTHERS THEN
      x_message := msg_uts('FND_COLUMNS',
                           'application_id', p_tbl.application_id,
                           'table_id', p_tbl.table_id,
                           'column_name', p_column_name);
      RETURN(FALSE);
END fetch_col;

-- ***************************************************************************
-- * VST fetch_vst_stg() functions.
-- ***************************************************************************
-- ---------------------------------------------------------------------------
FUNCTION fetch_vst_set(p_flex_value_set_id            IN NUMBER,
                       x_vst_set                      OUT nocopy vst_set_type,
                       x_message                      OUT nocopy VARCHAR2)
  RETURN BOOLEAN
  IS
BEGIN
   SELECT *
     INTO x_vst_set
     FROM fnd_flex_value_sets
     WHERE flex_value_set_id = p_flex_value_set_id;
   RETURN(TRUE);
EXCEPTION
   WHEN OTHERS THEN
      x_message := msg_uts('FND_FLEX_VALUE_SETS',
                           'flex_value_set_id', p_flex_value_set_id);
      RETURN(FALSE);
END fetch_vst_set;
-- ---------------------------------------------------------------------------
FUNCTION fetch_vst_tbl(p_vst_set                      IN vst_set_type,
                       x_vst_tbl                      OUT nocopy vst_tbl_type,
                       x_message                      OUT nocopy VARCHAR2)
  RETURN BOOLEAN
  IS
BEGIN
   SELECT *
     INTO x_vst_tbl
     FROM fnd_flex_validation_tables
     WHERE flex_value_set_id = p_vst_set.flex_value_set_id;
   RETURN(TRUE);
EXCEPTION
   WHEN OTHERS THEN
      x_message := msg_uts('FND_FLEX_VALIDATION_TABLES',
                           'flex_value_set_id', p_vst_set.flex_value_set_id);
      RETURN(FALSE);
END fetch_vst_tbl;
-- ---------------------------------------------------------------------------
FUNCTION fetch_vst_evt(p_vst_set                      IN vst_set_type,
                       p_event_code                   IN VARCHAR2,
                       x_vst_evt                      OUT nocopy vst_evt_type,
                       x_message                      OUT nocopy VARCHAR2)
  RETURN BOOLEAN
  IS
BEGIN
   SELECT *
     INTO x_vst_evt
     FROM fnd_flex_validation_events
     WHERE flex_value_set_id = p_vst_set.flex_value_set_id
     AND event_code = p_event_code;
   RETURN(TRUE);
EXCEPTION
   WHEN OTHERS THEN
      x_message := msg_uts('FND_FLEX_VALIDATION_EVENTS',
                           'flex_value_set_id', p_vst_set.flex_value_set_id,
                           'event_code', p_event_code);
      RETURN(FALSE);
END fetch_vst_evt;
-- ---------------------------------------------------------------------------
FUNCTION fetch_vst_scr(p_vst_set                      IN vst_set_type,
                       p_flex_value_rule_id           IN NUMBER,
                       x_vst_scr                      OUT nocopy vst_scr_type,
                       x_message                      OUT nocopy VARCHAR2)
  RETURN BOOLEAN
  IS
BEGIN
   SELECT *
     INTO x_vst_scr
     FROM fnd_flex_value_rules
     WHERE flex_value_set_id = p_vst_set.flex_value_set_id
     AND flex_value_rule_id = p_flex_value_rule_id;
   RETURN(TRUE);
EXCEPTION
   WHEN OTHERS THEN
      x_message := msg_uts('FND_FLEX_VALUE_RULES',
                           'flex_value_set_id', p_vst_set.flex_value_set_id,
                           'flex_value_rule_id', p_flex_value_rule_id);
      RETURN(FALSE);
END fetch_vst_scr;
-- ---------------------------------------------------------------------------
FUNCTION fetch_vst_scl(p_vst_scr                      IN vst_scr_type,
                       p_include_exclude_indicator    IN VARCHAR2,
                       p_flex_value_low               IN VARCHAR2,
                       p_flex_value_high              IN VARCHAR2,
                       x_vst_scl                      OUT nocopy vst_scl_type,
                       x_message                      OUT nocopy VARCHAR2)
  RETURN BOOLEAN
  IS
BEGIN
   SELECT *
     INTO x_vst_scl
     FROM fnd_flex_value_rule_lines
     WHERE flex_value_set_id = p_vst_scr.flex_value_set_id
     AND flex_value_rule_id = p_vst_scr.flex_value_rule_id
     AND include_exclude_indicator = p_include_exclude_indicator
     AND Nvl(flex_value_low, '$FLEX$.NULL') =
         Nvl(p_flex_value_low, '$FLEX$.NULL')
     AND Nvl(flex_value_high, '$FLEX$.NULL') =
         Nvl(p_flex_value_high, '$FLEX$.NULL');
   RETURN(TRUE);
EXCEPTION
   WHEN OTHERS THEN
      x_message := msg_uts('FND_FLEX_VALUE_RULE_LINES',
                           'flex_value_set_id', p_vst_scr.flex_value_set_id,
                           'flex_value_rule_id', p_vst_scr.flex_value_rule_id,
                           'include_exclude_indicator', p_include_exclude_indicator,
                           'flex_value_low', p_flex_value_low,
                           'flex_value_high', p_flex_value_high);
      RETURN(FALSE);
END fetch_vst_scl;
-- ---------------------------------------------------------------------------
FUNCTION fetch_vst_scu(p_vst_scr                      IN vst_scr_type,
                       p_application_id               IN NUMBER,
                       p_responsibility_id            IN NUMBER,
                       x_vst_scu                      OUT nocopy vst_scu_type,
                       x_message                      OUT nocopy VARCHAR2)
  RETURN BOOLEAN
  IS
BEGIN
   SELECT *
     INTO x_vst_scu
     FROM fnd_flex_value_rule_usages
     WHERE flex_value_set_id = p_vst_scr.flex_value_set_id
     AND flex_value_rule_id = p_vst_scr.flex_value_rule_id
     AND application_id = p_application_id
     AND responsibility_id = p_responsibility_id;
   RETURN(TRUE);
EXCEPTION
   WHEN OTHERS THEN
      x_message := msg_uts('FND_FLEX_VALUE_RULE_USAGES',
                           'flex_value_set_id', p_vst_scr.flex_value_set_id,
                           'flex_value_rule_id', p_vst_scr.flex_value_rule_id,
                           'application_id', p_application_id,
                           'responsibility_id', p_responsibility_id);
      RETURN(FALSE);
END fetch_vst_scu;
-- ---------------------------------------------------------------------------
FUNCTION fetch_vst_rlg(p_vst_set                      IN vst_set_type,
                       p_hierarchy_id                 IN NUMBER,
                       x_vst_rlg                      OUT nocopy vst_rlg_type,
                       x_message                      OUT nocopy VARCHAR2)
  RETURN BOOLEAN
  IS
BEGIN
   SELECT *
     INTO x_vst_rlg
     FROM fnd_flex_hierarchies
     WHERE flex_value_set_id = p_vst_set.flex_value_set_id
     AND hierarchy_id = p_hierarchy_id;
   RETURN(TRUE);
EXCEPTION
   WHEN OTHERS THEN
      x_message := msg_uts('FND_FLEX_HIERARCHIES',
                           'flex_value_set_id', p_vst_set.flex_value_set_id,
                           'hierarchy_id', p_hierarchy_id);
      RETURN(FALSE);
END fetch_vst_rlg;
-- ---------------------------------------------------------------------------
FUNCTION fetch_vst_val(p_vst_set                      IN vst_set_type,
                       p_flex_value_id                IN NUMBER,
                       x_vst_val                      OUT nocopy vst_val_type,
                       x_message                      OUT nocopy VARCHAR2)
  RETURN BOOLEAN
  IS
BEGIN
   SELECT *
     INTO x_vst_val
     FROM fnd_flex_values
     WHERE flex_value_set_id = p_vst_set.flex_value_set_id
     AND flex_value_id = p_flex_value_id;
   RETURN(TRUE);
EXCEPTION
   WHEN OTHERS THEN
      x_message := msg_uts('FND_FLEX_VALUES',
                           'flex_value_set_id', p_vst_set.flex_value_set_id,
                           'flex_value_id', p_flex_value_id);
      RETURN(FALSE);
END fetch_vst_val;

-- ***************************************************************************
-- * DFF fetch_dff_stg() functions.
-- ***************************************************************************
-- ---------------------------------------------------------------------------
FUNCTION fetch_dff_flx(p_application_id               IN NUMBER,
                       p_descriptive_flexfield_name   IN VARCHAR2,
                       x_dff_flx                      OUT nocopy dff_flx_type,
                       x_message                      OUT nocopy VARCHAR2)
  RETURN BOOLEAN
  IS
BEGIN
   SELECT *
     INTO x_dff_flx
     FROM fnd_descriptive_flexs
     WHERE application_id = p_application_id
     AND descriptive_flexfield_name = p_descriptive_flexfield_name;
   RETURN(TRUE);
EXCEPTION
   WHEN OTHERS THEN
      x_message := msg_uts('FND_DESCRIPTIVE_FLEXS',
                           'application_id', p_application_id,
                           'descriptive_flexfield_name', p_descriptive_flexfield_name);
      RETURN(FALSE);
END fetch_dff_flx;
-- ---------------------------------------------------------------------------
FUNCTION fetch_dff_ctx(p_dff_flx                      IN dff_flx_type,
                       p_descriptive_flex_context_cod IN VARCHAR2,
                       x_dff_ctx                      OUT nocopy dff_ctx_type,
                       x_message                      OUT nocopy VARCHAR2)
  RETURN BOOLEAN
  IS
BEGIN
   SELECT *
     INTO x_dff_ctx
     FROM fnd_descr_flex_contexts
     WHERE application_id = p_dff_flx.application_id
     AND descriptive_flexfield_name = p_dff_flx.descriptive_flexfield_name
     AND descriptive_flex_context_code = p_descriptive_flex_context_cod;
   RETURN(TRUE);
EXCEPTION
   WHEN OTHERS THEN
      x_message := msg_uts('FND_DESCR_FLEX_CONTEXTS',
                           'application_id', p_dff_flx.application_id,
                           'descriptive_flexfield_name', p_dff_flx.descriptive_flexfield_name,
                           'descriptive_flex_context_code', p_descriptive_flex_context_cod);
      RETURN(FALSE);
END fetch_dff_ctx;
-- ---------------------------------------------------------------------------
FUNCTION fetch_dff_seg(p_dff_ctx                  IN dff_ctx_type,
                       p_application_column_name  IN VARCHAR2,
                       x_dff_seg                  OUT nocopy dff_seg_type,
                       x_message                  OUT nocopy VARCHAR2)
  RETURN BOOLEAN
  IS
BEGIN
   SELECT *
     INTO x_dff_seg
     FROM fnd_descr_flex_column_usages
     WHERE application_id = p_dff_ctx.application_id
     AND descriptive_flexfield_name = p_dff_ctx.descriptive_flexfield_name
     AND descriptive_flex_context_code =p_dff_ctx.descriptive_flex_context_code
     AND application_column_name = p_application_column_name;
   RETURN(TRUE);
EXCEPTION
   WHEN OTHERS THEN
      x_message := msg_uts('FND_DESCR_FLEX_COLUMN_USAGES',
                           'application_id', p_dff_ctx.application_id,
                           'descriptive_flexfield_name', p_dff_ctx.descriptive_flexfield_name,
                           'descriptive_flex_context_code', p_dff_ctx.descriptive_flex_context_code,
                           'application_column_name', p_application_column_name);
      RETURN(FALSE);
END fetch_dff_seg;

-- ***************************************************************************
-- * KFF fetch_kff_stg() functions.
-- ***************************************************************************
-- ---------------------------------------------------------------------------
FUNCTION fetch_kff_flx(p_application_id               IN NUMBER,
                       p_id_flex_code                 IN VARCHAR2,
                       x_kff_flx                      OUT nocopy kff_flx_type,
                       x_message                      OUT nocopy VARCHAR2)
  RETURN BOOLEAN
  IS
BEGIN
   SELECT *
     INTO x_kff_flx
     FROM fnd_id_flexs
     WHERE application_id = p_application_id
     AND id_flex_code = p_id_flex_code;
   RETURN(TRUE);
EXCEPTION
   WHEN OTHERS THEN
      x_message := msg_uts('FND_ID_FLEXS',
                           'application_id', p_application_id,
                           'id_flex_code', p_id_flex_code);
      RETURN(FALSE);
END fetch_kff_flx;
-- ---------------------------------------------------------------------------
FUNCTION fetch_kff_str(p_kff_flx                      IN kff_flx_type,
                       p_id_flex_num                  IN NUMBER,
                       x_kff_str                      OUT nocopy kff_str_type,
                       x_message                      OUT nocopy VARCHAR2)
  RETURN BOOLEAN
  IS
BEGIN
   SELECT *
     INTO x_kff_str
     FROM fnd_id_flex_structures
     WHERE application_id = p_kff_flx.application_id
     AND id_flex_code = p_kff_flx.id_flex_code
     AND id_flex_num = p_id_flex_num;
   RETURN(TRUE);
EXCEPTION
   WHEN OTHERS THEN
      x_message := msg_uts('FND_ID_FLEX_STRUCTURES',
                           'application_id', p_kff_flx.application_id,
                           'id_flex_code', p_kff_flx.id_flex_code,
                           'id_flex_num', p_id_flex_num);
      RETURN(FALSE);
END fetch_kff_str;
-- ---------------------------------------------------------------------------
FUNCTION fetch_kff_seg(p_kff_str                      IN kff_str_type,
                       p_application_column_name      IN VARCHAR2,
                       x_kff_seg                      OUT nocopy kff_seg_type,
                       x_message                      OUT nocopy VARCHAR2)
  RETURN BOOLEAN
  IS
BEGIN
   SELECT *
     INTO x_kff_seg
     FROM fnd_id_flex_segments
     WHERE application_id = p_kff_str.application_id
     AND id_flex_code = p_kff_str.id_flex_code
     AND id_flex_num = p_kff_str.id_flex_num
     AND application_column_name = p_application_column_name;
   RETURN(TRUE);
EXCEPTION
   WHEN OTHERS THEN
      x_message := msg_uts('FND_ID_FLEX_SEGMENTS',
                           'application_id', p_kff_str.application_id,
                           'id_flex_code', p_kff_str.id_flex_code,
                           'id_flex_num', p_kff_str.id_flex_num,
                           'application_column_name', p_application_column_name);
      RETURN(FALSE);
END fetch_kff_seg;
-- ---------------------------------------------------------------------------
FUNCTION fetch_kff_flq(p_kff_flx                      IN kff_flx_type,
                       p_segment_attribute_type       IN VARCHAR2,
                       x_kff_flq                      OUT nocopy kff_flq_type,
                       x_message                      OUT nocopy VARCHAR2)
  RETURN BOOLEAN
  IS
BEGIN
   SELECT *
     INTO x_kff_flq
     FROM fnd_segment_attribute_types
     WHERE application_id = p_kff_flx.application_id
     AND id_flex_code = p_kff_flx.id_flex_code
     AND segment_attribute_type = p_segment_attribute_type;
   RETURN(TRUE);
EXCEPTION
   WHEN OTHERS THEN
      x_message := msg_uts('FND_SEGMENT_ATTRIBUTE_TYPES',
                           'application_id', p_kff_flx.application_id,
                           'id_flex_code', p_kff_flx.id_flex_code,
                           'segment_attribute_type', p_segment_attribute_type);
      RETURN(FALSE);
END fetch_kff_flq;
-- ---------------------------------------------------------------------------
FUNCTION fetch_kff_sgq(p_kff_flq                      IN kff_flq_type,
                       p_value_attribute_type         IN VARCHAR2,
                       x_kff_sgq                      OUT nocopy kff_sgq_type,
                       x_message                      OUT nocopy VARCHAR2)
  RETURN BOOLEAN
  IS
BEGIN
   SELECT *
     INTO x_kff_sgq
     FROM fnd_value_attribute_types
     WHERE application_id = p_kff_flq.application_id
     AND id_flex_code = p_kff_flq.id_flex_code
     AND segment_attribute_type = p_kff_flq.segment_attribute_type
     AND value_attribute_type = p_value_attribute_type;
   RETURN(TRUE);
EXCEPTION
   WHEN OTHERS THEN
      x_message := msg_uts('FND_VALUE_ATTRIBUTE_TYPES',
                           'application_id', p_kff_flq.application_id,
                           'id_flex_code', p_kff_flq.id_flex_code,
                           'segment_attribute_type', p_kff_flq.segment_attribute_type,
                           'value_attribute_type', p_value_attribute_type);
      RETURN(FALSE);
END fetch_kff_sgq;
-- ---------------------------------------------------------------------------
FUNCTION fetch_kff_qlv(p_kff_seg                      IN kff_seg_type,
                       p_kff_flq                      IN kff_flq_type,
                       x_kff_qlv                      OUT nocopy kff_qlv_type,
                       x_message                      OUT nocopy VARCHAR2)
  RETURN BOOLEAN
  IS
BEGIN
   IF (p_kff_seg. application_id <> p_kff_flq.application_id OR
       p_kff_seg.id_flex_code <> p_kff_flq.id_flex_code) THEN
      x_message := 'KFF does not match in SEG and FLQ records.';
      RETURN(FALSE);
   END IF;

   SELECT *
     INTO x_kff_qlv
     FROM fnd_segment_attribute_values
     WHERE application_id = p_kff_seg.application_id
     AND id_flex_code = p_kff_seg.id_flex_code
     AND id_flex_num = p_kff_seg.id_flex_num
     AND application_column_name = p_kff_seg.application_column_name
     AND segment_attribute_type = p_kff_flq.segment_attribute_type;
   RETURN(TRUE);
EXCEPTION
   WHEN OTHERS THEN
      x_message := msg_uts('FND_SEGMENT_ATTRIBUTE_VALUES',
                           'application_id', p_kff_seg.application_id,
                           'id_flex_code', p_kff_seg.id_flex_code,
                           'id_flex_num', p_kff_seg.id_flex_num,
                           'application_column_name', p_kff_seg.application_column_name,
                           'segment_attribute_type', p_kff_flq.segment_attribute_type);
      RETURN(FALSE);
END fetch_kff_qlv;
-- ---------------------------------------------------------------------------
FUNCTION fetch_kff_sha(p_kff_str                      IN kff_str_type,
                       p_alias_name                   IN VARCHAR2,
                       x_kff_sha                      OUT nocopy kff_sha_type,
                       x_message                      OUT nocopy VARCHAR2)
  RETURN BOOLEAN
  IS
BEGIN
   SELECT *
     INTO x_kff_sha
     FROM fnd_shorthand_flex_aliases
     WHERE application_id = p_kff_str.application_id
     AND id_flex_code = p_kff_str.id_flex_code
     AND id_flex_num = p_kff_str.id_flex_num
     AND alias_name = p_alias_name;
   RETURN(TRUE);
EXCEPTION
   WHEN OTHERS THEN
      x_message := msg_uts('FND_SHORTHAND_FLEX_ALIASES',
                           'application_id', p_kff_str.application_id,
                           'id_flex_code', p_kff_str.id_flex_code,
                           'id_flex_num', p_kff_str.id_flex_num,
                           'alias_name', p_alias_name);
      RETURN(FALSE);
END fetch_kff_sha;
-- ---------------------------------------------------------------------------
FUNCTION fetch_kff_cvr(p_kff_str                      IN kff_str_type,
                       p_flex_validation_rule_name    IN VARCHAR2,
                       x_kff_cvr                      OUT nocopy kff_cvr_type,
                       x_message                      OUT nocopy VARCHAR2)
  RETURN BOOLEAN
  IS
BEGIN
   SELECT *
     INTO x_kff_cvr
     FROM fnd_flex_validation_rules
     WHERE application_id = p_kff_str.application_id
     AND id_flex_code = p_kff_str.id_flex_code
     AND id_flex_num = p_kff_str.id_flex_num
     AND flex_validation_rule_name = p_flex_validation_rule_name;
   RETURN(TRUE);
EXCEPTION
   WHEN OTHERS THEN
      x_message := msg_uts('FND_FLEX_VALIDATION_RULES',
                           'application_id', p_kff_str.application_id,
                           'id_flex_code', p_kff_str.id_flex_code,
                           'id_flex_num', p_kff_str.id_flex_num,
                           'flex_validation_rule_name', p_flex_validation_rule_name);
      RETURN(FALSE);
END fetch_kff_cvr;
-- ---------------------------------------------------------------------------
FUNCTION fetch_kff_cvl(p_kff_cvr                      IN kff_cvr_type,
                       p_rule_line_id                 IN NUMBER,
                       x_kff_cvl                      OUT nocopy kff_cvl_type,
                       x_message                      OUT nocopy VARCHAR2)
  RETURN BOOLEAN
  IS
BEGIN
   SELECT *
     INTO x_kff_cvl
     FROM fnd_flex_validation_rule_lines
     WHERE application_id = p_kff_cvr.application_id
     AND id_flex_code = p_kff_cvr.id_flex_code
     AND id_flex_num = p_kff_cvr.id_flex_num
     AND flex_validation_rule_name = p_kff_cvr.flex_validation_rule_name
     AND rule_line_id = p_rule_line_id;
   RETURN(TRUE);
EXCEPTION
   WHEN OTHERS THEN
      x_message := msg_uts('FND_FLEX_VALIDATION_RULE_LINES',
                           'application_id', p_kff_cvr.application_id,
                           'id_flex_code', p_kff_cvr.id_flex_code,
                           'id_flex_num', p_kff_cvr.id_flex_num,
                           'flex_validation_rule_name', p_kff_cvr.flex_validation_rule_name,
                           'rule_line_id', p_rule_line_id);
      RETURN(FALSE);
END fetch_kff_cvl;
-- ---------------------------------------------------------------------------
FUNCTION fetch_kff_cvi(p_kff_cvr                      IN kff_cvr_type,
                       p_rule_line_id                 IN NUMBER,
                       x_kff_cvi                      OUT nocopy kff_cvi_type,
                       x_message                      OUT nocopy VARCHAR2)
  RETURN BOOLEAN
  IS
BEGIN
   SELECT *
     INTO x_kff_cvi
     FROM fnd_flex_include_rule_lines
     WHERE application_id = p_kff_cvr.application_id
     AND id_flex_code = p_kff_cvr.id_flex_code
     AND id_flex_num = p_kff_cvr.id_flex_num
     AND flex_validation_rule_name = p_kff_cvr.flex_validation_rule_name
     AND rule_line_id = p_rule_line_id;
   RETURN(TRUE);
EXCEPTION
   WHEN OTHERS THEN
      x_message := msg_uts('FND_FLEX_INCLUDE_RULE_LINES',
                           'application_id', p_kff_cvr.application_id,
                           'id_flex_code', p_kff_cvr.id_flex_code,
                           'id_flex_num', p_kff_cvr.id_flex_num,
                           'flex_validation_rule_name', p_kff_cvr.flex_validation_rule_name,
                           'rule_line_id', p_rule_line_id);
      RETURN(FALSE);
END fetch_kff_cvi;
-- ---------------------------------------------------------------------------
FUNCTION fetch_kff_cve(p_kff_cvr                      IN kff_cvr_type,
                       p_rule_line_id                 IN NUMBER,
                       x_kff_cve                      OUT nocopy kff_cve_type,
                       x_message                      OUT nocopy VARCHAR2)
  RETURN BOOLEAN
  IS
BEGIN
   SELECT *
     INTO x_kff_cve
     FROM fnd_flex_exclude_rule_lines
     WHERE application_id = p_kff_cvr.application_id
     AND id_flex_code = p_kff_cvr.id_flex_code
     AND id_flex_num = p_kff_cvr.id_flex_num
     AND flex_validation_rule_name = p_kff_cvr.flex_validation_rule_name
     AND rule_line_id = p_rule_line_id;
   RETURN(TRUE);
EXCEPTION
   WHEN OTHERS THEN
      x_message := msg_uts('FND_FLEX_EXCLUDE_RULE_LINES',
                           'application_id', p_kff_cvr.application_id,
                           'id_flex_code', p_kff_cvr.id_flex_code,
                           'id_flex_num', p_kff_cvr.id_flex_num,
                           'flex_validation_rule_name', p_kff_cvr.flex_validation_rule_name,
                           'rule_line_id', p_rule_line_id);
      RETURN(FALSE);
END fetch_kff_cve;
-- ---------------------------------------------------------------------------
FUNCTION fetch_kff_fwp(p_kff_str                      IN kff_str_type,
                       p_wf_item_type                 IN VARCHAR2,
                       x_kff_fwp                      OUT nocopy kff_fwp_type,
                       x_message                      OUT nocopy VARCHAR2)
  RETURN BOOLEAN
  IS
BEGIN
   SELECT *
     INTO x_kff_fwp
     FROM fnd_flex_workflow_processes
     WHERE application_id = p_kff_str.application_id
     AND id_flex_code = p_kff_str.id_flex_code
     AND id_flex_num = p_kff_str.id_flex_num
     AND wf_item_type = p_wf_item_type;
   RETURN(TRUE);
EXCEPTION
   WHEN OTHERS THEN
      x_message := msg_uts('FND_FLEX_WORKFLOW_PROCESSES',
                           'application_id', p_kff_str.application_id,
                           'id_flex_code', p_kff_str.id_flex_code,
                           'id_flex_num', p_kff_str.id_flex_num,
                           'wf_item_type', p_wf_item_type);
      RETURN(FALSE);
END fetch_kff_fwp;


-- ***************************************************************************
-- * Common get_something() RETURN VARCHAR2; functions.
-- ***************************************************************************
-- ===========================================================================
FUNCTION get_db RETURN VARCHAR2
  IS
     l_return VARCHAR2(2000);
BEGIN
   SELECT name
     INTO l_return
     FROM v$database
     WHERE ROWNUM = 1;
   RETURN(line_return(l_return));
EXCEPTION
   WHEN OTHERS THEN
      RETURN(line_return('Unknown DB.'));
END get_db;

-- ===========================================================================
FUNCTION get_rel RETURN VARCHAR2
  IS
     l_return VARCHAR2(2000);
BEGIN
   SELECT release_name
     INTO l_return
     FROM fnd_product_groups
     WHERE rownum = 1;
   RETURN(line_return(l_return));
EXCEPTION
   WHEN OTHERS THEN
      RETURN(line_return('00'));
END get_rel;

-- ===========================================================================
FUNCTION get_who(p_table_name   IN VARCHAR2,
                 p_rowid        IN ROWID)
  RETURN VARCHAR2
  IS
     l_sql               VARCHAR2(2000);
     l_creation_date     DATE;
     l_created_by        NUMBER;
     l_last_update_date  DATE;
     l_last_updated_by   NUMBER;
     l_last_update_login NUMBER;
BEGIN
   l_sql := ('SELECT creation_date, created_by,' ||
             ' last_update_date, last_updated_by, last_update_login' ||
             ' FROM ' || p_table_name ||
             ' WHERE ROWID = :B1');

   --
   -- Oracle 8.1
   --
   EXECUTE IMMEDIATE l_sql
     INTO l_creation_date, l_created_by,
     l_last_update_date, l_last_updated_by, l_last_update_login
     USING p_rowid;


   RETURN(line_return(get_who(l_creation_date, l_created_by,
                              l_last_update_date, l_last_updated_by,
                              l_last_update_login)));
EXCEPTION
   WHEN no_data_found THEN
      RETURN(line_return(p_table_name || p_rowid ||
                         '/get_who: no data found.'));
   WHEN OTHERS THEN
      RETURN(line_return(p_table_name || p_rowid ||
                         '/get_who SQLCODE:' || To_char(SQLCODE)));
END get_who;

-- ===========================================================================
FUNCTION get_who(p_creation_date     IN DATE,
                 p_created_by        IN NUMBER,
                 p_last_update_date  IN DATE,
                 p_last_updated_by   IN NUMBER,
                 p_last_update_login IN NUMBER)
  RETURN VARCHAR2
  IS
BEGIN
   RETURN(line_return('CD:'    || To_char(p_creation_date, 'YYYY/MM/DD') ||
                      '  CB:'  || To_char(p_created_by) ||
                      '  LUD:' || To_char(p_last_update_date, 'YYYY/MM/DD') ||
                      '  LUB:' || To_char(p_last_updated_by) ||
                      '  LUL:' || To_char(p_last_update_login)));
EXCEPTION
   WHEN OTHERS THEN
      RETURN(line_return('/get_who SQLCODE:' || To_char(SQLCODE)));
END get_who;

-- ===========================================================================
FUNCTION get_app(p_application_id IN NUMBER)
  RETURN VARCHAR2
  IS
     l_return VARCHAR2(2000);
BEGIN
   SELECT To_char(application_id) || '/' ||
          application_short_name  || '/' ||
          application_name
     INTO l_return
     FROM fnd_application_vl
     WHERE application_id = p_application_id;
   RETURN(line_return(l_return));
EXCEPTION
   WHEN no_data_found THEN
      RETURN(line_return(To_char(p_application_id) ||
                         '/get_app: no data found.'));
   WHEN OTHERS THEN
      RETURN(line_return(To_char(p_application_id) ||
                         '/get_app SQLCODE:' || To_char(SQLCODE)));
END get_app;

-- ===========================================================================
FUNCTION get_tbl(p_application_id IN NUMBER,
                 p_table_name     IN VARCHAR2)
  RETURN VARCHAR2
  IS
     l_return VARCHAR2(2000);
BEGIN
   BEGIN
      SELECT ft.table_name || '/' ||
        To_char(table_id)
        INTO l_return
        FROM fnd_tables ft
        WHERE ft.application_id = p_application_id
        AND ft.table_name = p_table_name;
   EXCEPTION
      WHEN no_data_found THEN
         RETURN(line_return(p_table_name ||
                            '/get_tbl(FND_TABLES): no data found.'));
   END;
   BEGIN
      SELECT us.table_owner || '/' || l_return
        INTO l_return
        FROM user_synonyms us
        WHERE us.synonym_name = p_table_name;
   EXCEPTION
      WHEN no_data_found THEN
         RETURN(line_return(l_return ||
                            '/get_tbl(USER_SYNONYMS): no data found.'));
   END;
   RETURN(line_return(l_return));
EXCEPTION
   WHEN no_data_found THEN
      RETURN(line_return(p_table_name ||
                         '/get_tbl: no data found.'));
   WHEN OTHERS THEN
      RETURN(line_return(p_table_name ||
                         '/get_tbl SQLCODE:' || To_char(SQLCODE)));
END get_tbl;

-- ===========================================================================
FUNCTION get_col(p_application_id  IN NUMBER,
                 p_table_name      IN VARCHAR2,
                 p_column_name     IN VARCHAR2)
  RETURN VARCHAR2
  IS
     l_return        VARCHAR2(2000);
BEGIN
   SELECT column_name || '/' ||
     To_char(column_id) || '/' ||
     column_type || '/' ||
     To_char(width) || '/' ||
     flexfield_usage_code || '/' ||
     Nvl(To_char(flexfield_application_id), '<NULL>') || '/' ||
     Nvl(flexfield_name, '<NULL>')
     INTO l_return
     FROM fnd_columns
     WHERE ((application_id, table_id) =
            (SELECT application_id, table_id
             FROM fnd_tables
             WHERE application_id = p_application_id
             AND table_name = p_table_name))
     AND column_name = p_column_name;
   RETURN(line_return(l_return));
EXCEPTION
   WHEN no_data_found THEN
      RETURN(line_return(p_column_name ||
                         '/get_col: no data found.'));
   WHEN OTHERS THEN
      RETURN(line_return(p_column_name ||
                         '/get_col SQLCODE:' || To_char(SQLCODE)));
END get_col;

-- ===========================================================================
FUNCTION get_lng(p_language_code IN VARCHAR2)
  RETURN VARCHAR2
  IS
     l_return VARCHAR2(2000);
BEGIN
   SELECT language_code || '/' ||
     installed_flag || '/' ||
     nls_language || '/' ||
     nls_territory
     INTO l_return
     FROM fnd_languages
     WHERE language_code = p_language_code;
   RETURN(line_return(l_return));
EXCEPTION
   WHEN no_data_found THEN
      RETURN(line_return(p_language_code ||
                         '/get_lng: no data found.'));
   WHEN OTHERS THEN
      RETURN(line_return(p_language_code ||
                         '/get_lng SQLCODE:' || To_char(SQLCODE)));
END get_lng;

-- ===========================================================================
FUNCTION get_rsp(p_application_id               IN NUMBER,
                 p_responsibility_id            IN NUMBER)
  RETURN VARCHAR2
  IS
     l_return VARCHAR2(2000);
BEGIN
   SELECT To_char(responsibility_id) || '/' ||
     responsibility_key || '/' ||
     responsibility_name
     INTO l_return
     FROM fnd_responsibility_vl
     WHERE application_id = p_application_id
     AND responsibility_id = p_responsibility_id;
   RETURN(line_return(l_return));
EXCEPTION
   WHEN no_data_found THEN
      RETURN(line_return(To_char(p_responsibility_id) ||
                         '/get_rsp: no data found.'));
   WHEN OTHERS THEN
      RETURN(line_return(To_char(p_responsibility_id) ||
                         '/get_rsp SQLCODE:' || To_char(SQLCODE)));
END get_rsp;

-- ***************************************************************************
-- * FB get_fb_something() RETURN VARCHAR2; functions.
-- ***************************************************************************
-- ===========================================================================
FUNCTION get_fb_func(p_application_id IN NUMBER,
                     p_function_code  IN VARCHAR2)
  RETURN VARCHAR2
  IS
     l_return VARCHAR2(2000);
BEGIN
   SELECT function_code || '/' ||
          function_name || '/' ||
          description
     INTO l_return
     FROM fnd_flexbuilder_functions
     WHERE application_id = p_application_id
     AND function_code = p_function_code;
   RETURN(line_return(l_return));
EXCEPTION
   WHEN no_data_found THEN
      RETURN(line_return(p_function_code ||
                         '/get_fb_func: no data found.'));
   WHEN OTHERS THEN
      RETURN(line_return(p_function_code ||
                         '/get_fb_func SQLCODE:' || To_char(SQLCODE)));
END get_fb_func;

-- ===========================================================================
FUNCTION get_fb_kapp(p_application_id IN NUMBER,
                     p_function_code  IN VARCHAR2)
  RETURN VARCHAR2
  IS
     l_kff_app_id NUMBER;
BEGIN
   SELECT flexfield_application_id
     INTO l_kff_app_id
     FROM fnd_flexbuilder_functions
     WHERE application_id = p_application_id
     AND function_code = p_function_code;

   RETURN(get_app(l_kff_app_id));
EXCEPTION
   WHEN no_data_found THEN
      RETURN(line_return(p_function_code ||
                         '/get_fb_kapp: no data found.'));
   WHEN OTHERS THEN
      RETURN(line_return(p_function_code ||
                         '/get_fb_kapp SQLCODE:' || To_char(SQLCODE)));
END get_fb_kapp;

-- ===========================================================================
FUNCTION get_fb_kflx(p_application_id IN NUMBER,
                     p_function_code  IN VARCHAR2)
  RETURN VARCHAR2
  IS
     l_kff_app_id NUMBER;
     l_kff_code   VARCHAR2(100);
BEGIN
   SELECT flexfield_application_id, id_flex_code
     INTO l_kff_app_id, l_kff_code
     FROM fnd_flexbuilder_functions
     WHERE application_id = p_application_id
     AND function_code = p_function_code;

   RETURN(get_kff_flx(l_kff_app_id, l_kff_code));
EXCEPTION
   WHEN no_data_found THEN
      RETURN(line_return(p_function_code ||
                         '/get_fb_kflx: no data found.'));
   WHEN OTHERS THEN
      RETURN(line_return(p_function_code ||
                         '/get_fb_kflx SQLCODE:' || To_char(SQLCODE)));
END get_fb_kflx;

-- ===========================================================================
FUNCTION get_fb_kstr(p_application_id IN NUMBER,
                     p_function_code  IN VARCHAR2,
                     p_id_flex_num    IN NUMBER)
  RETURN VARCHAR2
  IS
     l_kff_app_id NUMBER;
     l_kff_code   VARCHAR2(100);
BEGIN
   SELECT flexfield_application_id, id_flex_code
     INTO l_kff_app_id, l_kff_code
     FROM fnd_flexbuilder_functions
     WHERE application_id = p_application_id
     AND function_code = p_function_code;

   RETURN(get_kff_str(l_kff_app_id, l_kff_code, p_id_flex_num));
EXCEPTION
   WHEN no_data_found THEN
      RETURN(line_return(p_function_code || '/' || p_id_flex_num ||
                         '/get_fb_kstr: no data found.'));
   WHEN OTHERS THEN
      RETURN(line_return(p_function_code || '/' || p_id_flex_num ||
                         '/get_fb_kstr SQLCODE:' || To_char(SQLCODE)));
END get_fb_kstr;

-- ***************************************************************************
-- * VST get_vst_something() RETURN VARCHAR2; functions.
-- ***************************************************************************
-- ===========================================================================
FUNCTION get_vst_set(p_flex_value_set_id IN NUMBER)
  RETURN VARCHAR2
  IS
     l_return VARCHAR2(2000);
BEGIN
   SELECT To_char(flex_value_set_id) || '/' ||
     flex_value_set_name || '/' ||
     validation_type || '/' ||
     format_type || '/' ||
     To_char(maximum_size) || '/' ||
     Nvl(description, '<NULL>')
     INTO l_return
     FROM fnd_flex_value_sets
     WHERE flex_value_set_id = p_flex_value_set_id;
   RETURN(line_return(l_return));
EXCEPTION
   WHEN no_data_found THEN
      RETURN(line_return(To_char(p_flex_value_set_id) ||
                         '/get_vst_set: no data found.'));
   WHEN OTHERS THEN
      RETURN(line_return(To_char(p_flex_value_set_id) ||
                         '/get_vst_set SQLCODE:' || To_char(SQLCODE)));
END get_vst_set;

-- ===========================================================================
FUNCTION get_vst_tbl(p_flex_value_set_id            IN NUMBER)
  RETURN VARCHAR2
  IS
     l_return VARCHAR2(2000);
BEGIN
   SELECT application_table_name || '/' ||
     value_column_name || '/' ||
     value_column_type || '/' ||
     value_column_size || '/' ||
     Nvl(id_column_name,'<NULL>') || '/' ||
     Nvl(id_column_type,'<NULL>') || '/' ||
     Nvl(To_char(id_column_size),'<NULL>')
     INTO l_return
     FROM fnd_flex_validation_tables
     WHERE flex_value_set_id = p_flex_value_set_id;
   RETURN(line_return(l_return));
EXCEPTION
   WHEN no_data_found THEN
      RETURN(line_return(To_char(p_flex_value_set_id) ||
                         '/get_vst_tbl: no data found.'));
   WHEN OTHERS THEN
      RETURN(line_return(To_char(p_flex_value_set_id) ||
                         '/get_vst_tbl SQLCODE:' || To_char(SQLCODE)));
END get_vst_tbl;

-- ===========================================================================
FUNCTION get_vst_evt(p_flex_value_set_id            IN NUMBER,
                     p_event_code                   IN VARCHAR2)
  RETURN VARCHAR2
  IS
     l_return    VARCHAR2(2000);
     l_user_exit VARCHAR2(32000);
BEGIN
   SELECT fve.event_code || '/' ||
     fl.meaning || '/',
     fve.user_exit
     INTO l_return, l_user_exit
     FROM fnd_flex_validation_events fve, fnd_lookups fl
     WHERE fl.lookup_type = 'FLEX_VALIDATION_EVENTS'
     AND fl.lookup_code = fve.event_code
     AND fve.flex_value_set_id = p_flex_value_set_id
     AND fve.event_code = p_event_code;
   l_return := l_return || Substr(l_user_exit,
                                  1, g_line_size - Length(l_return));
   l_return := REPLACE(l_return, g_newline, '\n');
   RETURN(line_return(l_return));
EXCEPTION
   WHEN no_data_found THEN
      RETURN(line_return(p_event_code ||
                         '/get_vst_evt: no data found.'));
   WHEN OTHERS THEN
      RETURN(line_return(p_event_code ||
                         '/get_vst_evt SQLCODE:' || To_char(SQLCODE)));
END get_vst_evt;

-- ===========================================================================
FUNCTION get_vst_scr(p_flex_value_set_id            IN NUMBER,
                     p_flex_value_rule_id           IN NUMBER)
  RETURN VARCHAR2
  IS
     l_return    VARCHAR2(2000);
BEGIN
   SELECT flex_value_rule_id || '/' ||
     flex_value_rule_name || '/' ||
     Nvl(parent_flex_value_low,'<NULL>') || '/' ||
     error_message
     INTO l_return
     FROM fnd_flex_value_rules_vl
     WHERE flex_value_set_id = p_flex_value_set_id
     AND flex_value_rule_id = p_flex_value_rule_id;
   RETURN(line_return(l_return));
EXCEPTION
   WHEN no_data_found THEN
      RETURN(line_return(To_char(p_flex_value_rule_id) ||
                         '/get_vst_scr: no data found.'));
   WHEN OTHERS THEN
      RETURN(line_return(To_char(p_flex_value_rule_id) ||
                         '/get_vst_scr SQLCODE:' || To_char(SQLCODE)));
END get_vst_scr;

-- ===========================================================================
FUNCTION get_vst_scl(p_flex_value_set_id            IN NUMBER,
                     p_flex_value_rule_id           IN NUMBER,
                     p_include_exclude_indicator    IN VARCHAR2,
                     p_flex_value_low               IN VARCHAR2,
                     p_flex_value_high              IN VARCHAR2)
  RETURN VARCHAR2
  IS
     l_return VARCHAR2(2000);
BEGIN
   SELECT include_exclude_indicator || '/' ||
     Nvl(parent_flex_value_low,'<NULL>') || '/' ||
     Nvl(flex_value_low, '<NULL>') || '/' ||
     Nvl(flex_value_high, '<NULL>')
     INTO l_return
     FROM fnd_flex_value_rule_lines
     WHERE flex_value_set_id = p_flex_value_set_id
     AND flex_value_rule_id = p_flex_value_rule_id
     AND include_exclude_indicator = p_include_exclude_indicator
     AND Nvl(flex_value_low, '$FLEX$.NULL') =
         Nvl(p_flex_value_low, '$FLEX$.NULL')
     AND Nvl(flex_value_high, '$FLEX$.NULL') =
         Nvl(p_flex_value_high, '$FLEX$.NULL');
   RETURN(line_return(l_return));
EXCEPTION
   WHEN no_data_found THEN
      RETURN(line_return(p_include_exclude_indicator || '/' ||
                         p_flex_value_low || '/' ||
                         p_flex_value_high ||
                         '/get_vst_scl: no data found.'));
   WHEN OTHERS THEN
      RETURN(line_return(p_include_exclude_indicator || '/' ||
                         p_flex_value_low || '/' ||
                         p_flex_value_high ||
                         '/get_vst_scl SQLCODE:' || To_char(SQLCODE)));
END get_vst_scl;

-- ===========================================================================
FUNCTION get_vst_scu(p_flex_value_set_id            IN NUMBER,
                     p_flex_value_rule_id           IN NUMBER,
                     p_application_id               IN NUMBER,
                     p_responsibility_id            IN NUMBER)
  RETURN VARCHAR2
  IS
     l_return VARCHAR2(2000);
BEGIN
   SELECT To_char(flex_value_rule_id) || '/' ||
     To_char(application_id) || '/' ||
     To_char(responsibility_id)
     INTO l_return
     FROM fnd_flex_value_rule_usages
     WHERE flex_value_set_id = p_flex_value_set_id
     AND flex_value_rule_id = p_flex_value_rule_id
     AND application_id = p_application_id
     AND responsibility_id = p_responsibility_id;
   RETURN(line_return(l_return));
EXCEPTION
   WHEN no_data_found THEN
      RETURN(line_return(To_char(p_flex_value_rule_id) || '/' ||
                         To_char(p_application_id) || '/' ||
                         To_char(p_responsibility_id) ||
                         '/get_vst_scu: no data found.'));
   WHEN OTHERS THEN
      RETURN(line_return(To_char(p_flex_value_rule_id) || '/' ||
                         To_char(p_application_id) || '/' ||
                         To_char(p_responsibility_id) ||
                         '/get_vst_scu SQLCODE:' || To_char(SQLCODE)));
END get_vst_scu;

-- ===========================================================================
FUNCTION get_vst_val(p_flex_value_set_id            IN NUMBER,
                     p_flex_value_id                IN NUMBER)
  RETURN VARCHAR2
  IS
     l_return VARCHAR2(2000);
BEGIN
   SELECT To_char(flex_value_id) || '/' ||
     Nvl(parent_flex_value_low, '<NULL>') || '/' ||
     flex_value || '/' ||
     enabled_flag || '/' ||
     flex_value_meaning || '/' ||
     Nvl(description, '<NULL>')
     INTO l_return
     FROM fnd_flex_values_vl
     WHERE flex_value_set_id = p_flex_value_set_id
     AND flex_value_id = p_flex_value_id;
   RETURN(line_return(l_return));
EXCEPTION
   WHEN no_data_found THEN
      RETURN(line_return(To_char(p_flex_value_id) ||
                         '/get_vst_val: no data found.'));
   WHEN OTHERS THEN
      RETURN(line_return(To_char(p_flex_value_id) ||
                         '/get_vst_val SQLCODE:' || To_char(SQLCODE)));
END get_vst_val;

-- ===========================================================================
FUNCTION get_vst_rlg(p_flex_value_set_id            IN NUMBER,
                     p_hierarchy_id                 IN NUMBER)
  RETURN VARCHAR2
  IS
     l_return VARCHAR2(2000);
BEGIN
   SELECT To_char(hierarchy_id) || '/' ||
     hierarchy_name || '/' ||
     Nvl(description,'<NULL>')
     INTO l_return
     FROM fnd_flex_hierarchies_vl
     WHERE flex_value_set_id = p_flex_value_set_id
     AND hierarchy_id = p_hierarchy_id;
   RETURN(line_return(l_return));
EXCEPTION
   WHEN no_data_found THEN
      RETURN(line_return(To_char(p_hierarchy_id) ||
                         '/get_vst_rlg: no data found.'));
   WHEN OTHERS THEN
      RETURN(line_return(To_char(p_hierarchy_id) ||
                         '/get_vst_rlg SQLCODE:' || To_char(SQLCODE)));
END get_vst_rlg;

-- ===========================================================================
FUNCTION get_vst_fvn(p_flex_value_set_id            IN NUMBER,
                     p_parent_flex_value            IN VARCHAR2,
                     p_range_attribute              IN VARCHAR2,
                     p_child_flex_value_low         IN VARCHAR2,
                     p_child_flex_value_high        IN VARCHAR2)
  RETURN VARCHAR2
  IS
     l_return VARCHAR2(2000);
BEGIN
   SELECT parent_flex_value || '/' ||
     range_attribute || '/' ||
     child_flex_value_low || '/' ||
     child_flex_value_high
     INTO l_return
     FROM fnd_flex_value_norm_hierarchy
     WHERE flex_value_set_id = p_flex_value_set_id
     AND parent_flex_value = p_parent_flex_value
     AND range_attribute = p_range_attribute
     AND child_flex_value_low = p_child_flex_value_low
     AND child_flex_value_high = p_child_flex_value_high;
   RETURN(line_return(l_return));
EXCEPTION
   WHEN no_data_found THEN
      RETURN(line_return(p_parent_flex_value || '/' ||
                         p_range_attribute || '/' ||
                         p_child_flex_value_low || '/' ||
                         p_child_flex_value_high ||
                         '/get_vst_fvn: no data found.'));
   WHEN OTHERS THEN
      RETURN(line_return(p_parent_flex_value || '/' ||
                         p_range_attribute || '/' ||
                         p_child_flex_value_low || '/' ||
                         p_child_flex_value_high ||
                         '/get_vst_fvn SQLCODE:' || To_char(SQLCODE)));
END get_vst_fvn;

-- ===========================================================================
FUNCTION get_vst_fvh(p_flex_value_set_id            IN NUMBER,
                     p_parent_flex_value            IN VARCHAR2,
                     p_child_flex_value_low         IN VARCHAR2,
                     p_child_flex_value_high        IN VARCHAR2)
  RETURN VARCHAR2
  IS
     l_return VARCHAR2(2000);
BEGIN
   SELECT parent_flex_value || '/' ||
     child_flex_value_low || '/' ||
     child_flex_value_high
     INTO l_return
     FROM fnd_flex_value_hierarchies
     WHERE flex_value_set_id = p_flex_value_set_id
     AND parent_flex_value = p_parent_flex_value
     AND child_flex_value_low = p_child_flex_value_low
     AND child_flex_value_high = p_child_flex_value_high;
   RETURN(line_return(l_return));
EXCEPTION
   WHEN no_data_found THEN
      RETURN(line_return(p_parent_flex_value || '/' ||
                         p_child_flex_value_low || '/' ||
                         p_child_flex_value_high ||
                         '/get_vst_fvh: no data found.'));
   WHEN OTHERS THEN
      RETURN(line_return(p_parent_flex_value || '/' ||
                         p_child_flex_value_low || '/' ||
                         p_child_flex_value_high ||
                         '/get_vst_fvh SQLCODE:' || To_char(SQLCODE)));
END get_vst_fvh;

-- ===========================================================================
FUNCTION get_vst_fix(p_rule                         IN VARCHAR2,
                     p_pk1                          IN VARCHAR2 DEFAULT NULL,
                     p_pk2                          IN VARCHAR2 DEFAULT NULL,
                     p_pk3                          IN VARCHAR2 DEFAULT NULL,
                     p_pk4                          IN VARCHAR2 DEFAULT NULL,
                     p_pk5                          IN VARCHAR2 DEFAULT NULL,
                     p_pk6                          IN VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2
  IS
     l_beg    VARCHAR2(100);
     l_mid    VARCHAR2(2000) := NULL;
     l_end    VARCHAR2(100);
     l_cn     VARCHAR2(100) := ',' || g_newline;
BEGIN
   l_beg := (g_newline ||
             'variable msg VARCHAR2(2000);' || g_newline ||
             'BEGIN' || g_newline ||
             ' fnd_flex_diagnose.');
   IF (p_rule IN ('A.01', 'A.02', 'A.03', 'A.04', 'A.05', 'B.01', 'B.02')) THEN
      l_mid :=
        'fix_vst_set' || g_newline ||
        '  (p_rule                         => ''' || p_rule || '''' || l_cn ||
        '   p_flex_value_set_id            => '   || p_pk1  || l_cn;
   END IF;
   IF (p_rule IN ('C.01', 'C.02')) THEN
      l_mid :=
        'fix_vst_evt' || g_newline ||
        '  (p_rule                         => ''' || p_rule || '''' || l_cn ||
        '   p_flex_value_set_id            => '   || p_pk1  || l_cn ||
        '   p_event_code                   => ''' || p_pk2  || '''' || l_cn;
   END IF;
   IF (p_rule IN ('D.03')) THEN
      l_mid :=
        'fix_vst_scr' || g_newline ||
        '  (p_rule                         => ''' || p_rule || '''' || l_cn ||
        '   p_flex_value_set_id            => '   || p_pk1  || l_cn ||
        '   p_flex_value_rule_id           => '   || p_pk2  || l_cn;
   END IF;
   IF (p_rule IN ('E.01', 'E.02')) THEN
      l_mid :=
        'fix_vst_scl' || g_newline ||
        '  (p_rule                         => ''' || p_rule || '''' || l_cn ||
        '   p_flex_value_set_id            => '   || p_pk1  || l_cn ||
        '   p_flex_value_rule_id           => '   || p_pk2  || l_cn ||
        '   p_include_exclude_indicator    => ''' || p_pk3  || '''' || l_cn ||
        '   p_flex_value_low               => ''' || p_pk4  || '''' || l_cn ||
        '   p_flex_value_high              => ''' || p_pk5  || '''' || l_cn;
   END IF;
   IF (p_rule IN ('F.01', 'F.02', 'F.03')) THEN
      l_mid :=
        'fix_vst_scu' || g_newline ||
        '  (p_rule                         => ''' || p_rule || '''' || l_cn ||
        '   p_flex_value_set_id            => '   || p_pk1  || l_cn ||
        '   p_flex_value_rule_id           => '   || p_pk2  || l_cn ||
        '   p_application_id               => '   || p_pk3  || l_cn ||
        '   p_responsibility_id            => '   || p_pk4  || l_cn;
   END IF;
   IF (p_rule IN ('G.03', 'G.04')) THEN
      l_mid :=
        'fix_vst_val' || g_newline ||
        '  (p_rule                         => ''' || p_rule || '''' || l_cn ||
        '   p_flex_value_set_id            => '   || p_pk1  || l_cn ||
        '   p_flex_value_id                => '   || p_pk2  || l_cn;
   END IF;
   IF (p_rule IN ('H.03')) THEN
      l_mid :=
        'fix_vst_rlg' || g_newline ||
        '  (p_rule                         => ''' || p_rule || '''' || l_cn ||
        '   p_flex_value_set_id            => '   || p_pk1  || l_cn ||
        '   p_hierarchy_id                 => '   || p_pk2  || l_cn;
   END IF;
   IF (p_rule IN ('I.01')) THEN
      l_mid :=
        'fix_vst_fvn' || g_newline ||
        '  (p_rule                         => ''' || p_rule || '''' || l_cn ||
        '   p_flex_value_set_id            => '   || p_pk1  || l_cn ||
        '   p_parent_flex_value            => ''' || p_pk2  || '''' || l_cn ||
        '   p_range_attribute              => ''' || p_pk3  || '''' || l_cn ||
        '   p_child_flex_value_low         => ''' || p_pk4  || '''' || l_cn ||
        '   p_child_flex_value_high        => ''' || p_pk5  || '''' || l_cn;
   END IF;
   IF (p_rule IN ('J.01')) THEN
      l_mid :=
        'fix_vst_fvh' || g_newline ||
        '  (p_rule                         => ''' || p_rule || '''' || l_cn ||
        '   p_flex_value_set_id            => '   || p_pk1  || l_cn ||
        '   p_parent_flex_value            => ''' || p_pk2  || '''' || l_cn ||
        '   p_child_flex_value_low         => ''' || p_pk3  || '''' || l_cn ||
        '   p_child_flex_value_high        => ''' || p_pk4  || '''' || l_cn;
   END IF;
   l_end :=  ('   x_message                      => :msg);' || g_newline ||
              'END;' || g_newline ||
              '/' || g_newline ||
              'print msg;' || g_newline || g_newline);


   IF (l_mid IS NOT NULL) THEN
      RETURN(l_beg || l_mid || l_end);
    ELSE
      RETURN('VST fix is not available for rule : ' || p_rule);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      RETURN('get_vst_fix : SQLERRM ' || Sqlerrm);
END get_vst_fix;


-- ***************************************************************************
-- * VST validate_vst_something(); functions
-- ***************************************************************************
-- ===========================================================================
-- Validates vset table definition
-- ===========================================================================
FUNCTION validate_vst_tbl(p_flex_value_set_id IN NUMBER)
  RETURN VARCHAR2
  IS
     l_vst_set  vst_set_type;
     l_vst_tbl  vst_tbl_type;
     l_result   VARCHAR2(20);
     l_message  VARCHAR2(2000);
BEGIN
   IF (NOT fetch_vst_set(p_flex_value_set_id,
                         l_vst_set,
                         l_message)) THEN
      GOTO return_error;
   END IF;

   IF (NOT fetch_vst_tbl(l_vst_set,
                         l_vst_tbl,
                         l_message)) THEN
      GOTO return_error;
   END IF;

   fnd_flex_val_api.validate_table_vset
     (p_flex_value_set_name          => l_vst_set.flex_value_set_name,
      p_id_column_name               => l_vst_tbl.id_column_name,
      p_value_column_name            => l_vst_tbl.value_column_name,
      p_meaning_column_name          => l_vst_tbl.meaning_column_name,
      p_additional_quickpick_columns => l_vst_tbl.additional_quickpick_columns,
      p_application_table_name       => l_vst_tbl.application_table_name,
      p_additional_where_clause      => l_vst_tbl.additional_where_clause,
      x_result                       => l_result,
      x_message                      => l_message);

   IF (l_result = 'Failure') THEN
      GOTO return_error;
   END IF;

   <<return_success>>
     RETURN ('Success');

   <<return_error>>
     RETURN (l_message);

EXCEPTION
   WHEN OTHERS THEN
      RETURN('validate_vst_tbl : SQLERRM ' || Sqlerrm);
END validate_vst_tbl;

-- ***************************************************************************
-- * VST fix_vst_something(); procedures.
-- ***************************************************************************
-- ===========================================================================
PROCEDURE fix_vst_set(p_rule                         IN VARCHAR2,
                      p_flex_value_set_id            IN NUMBER,
                      x_message                      OUT nocopy VARCHAR2)
  IS
     l_vst_set  vst_set_type;
     l_dep_set  vst_set_type;
     l_vst_tbl  vst_tbl_type;
     l_count    NUMBER;
BEGIN
   IF (p_rule = 'B.01') THEN
      --
      -- Table without set.
      --
      BEGIN
         DELETE
           FROM fnd_flex_validation_tables fvt
           WHERE flex_value_set_id = p_flex_value_set_id
           AND NOT EXISTS
           (SELECT null
            FROM fnd_flex_value_sets fvs
            WHERE fvs.flex_value_set_id = fvt.flex_value_set_id
            AND fvs.validation_type = 'F');
         x_message := SQL%rowcount || ' row(s) deleted.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to delete from FND_FLEX_VALIDATION_TABLES. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (NOT fetch_vst_set(p_flex_value_set_id,
                         l_vst_set,
                         x_message)) THEN
      GOTO return_error;
   END IF;

   IF (p_rule = 'A.01') THEN
      --
      -- Dep vset with NULL parent_flex_value_set_id.
      --
      IF (l_vst_set.validation_type NOT IN ('D', 'Y')) THEN
         x_message := 'This is not a dependent value set. No need to fix.';
         GOTO return_error;
      END IF;

      IF (l_vst_set.parent_flex_value_set_id IS NOT NULL) THEN
         x_message := 'Parent flex value set id is not null. No need to fix.';
         GOTO return_error;
      END IF;

      BEGIN
         UPDATE fnd_flex_value_sets SET
           validation_type  = 'N',
           last_update_date = Sysdate,
           last_updated_by  = 1
           WHERE flex_value_set_id = l_vst_set.flex_value_set_id;
         x_message := SQL%rowcount || ' row(s) updated.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message := 'Unable to update FND_FLEX_VALUE_SETS. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (p_rule = 'A.02') THEN
      --
      -- Dep vset with non-existing parent_flex_value_set_id.
      --
      IF (l_vst_set.validation_type NOT IN ('D', 'Y')) THEN
         x_message := 'This is not a dependent value set. No need to fix.';
         GOTO return_error;
      END IF;

      IF (fetch_vst_set(l_vst_set.parent_flex_value_set_id,
                        l_dep_set,
                        x_message)) THEN
         x_message := 'Parent value set exists. No need to fix.';
         GOTO return_error;
      END IF;

      BEGIN
         UPDATE fnd_flex_value_sets SET
           validation_type           = 'N',
           parent_flex_value_set_id  = NULL,
           dependant_default_value   = NULL,
           dependant_default_meaning = NULL,
           last_update_date          = Sysdate,
           last_updated_by           = 1
           WHERE flex_value_set_id = l_vst_set.flex_value_set_id;
         x_message := SQL%rowcount || ' row(s) updated.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message := 'Unable to update FND_FLEX_VALUE_SETS. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (p_rule = 'A.03') THEN
      --
      -- Table vsets without table info.
      --
      IF (l_vst_set.validation_type <> 'F') THEN
         x_message := 'This is not a table value set. No need to fix.';
         GOTO return_error;
      END IF;

      IF (fetch_vst_tbl(l_vst_set,
                        l_vst_tbl,
                        x_message)) THEN
         x_message := 'Table info exists. No need to fix.';
         GOTO return_error;
      END IF;

      BEGIN
         UPDATE fnd_flex_value_sets SET
           validation_type  = 'N',
           last_update_date = Sysdate,
           last_updated_by  = 1
           WHERE flex_value_set_id = l_vst_set.flex_value_set_id;
         x_message := SQL%rowcount || ' row(s) updated.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message := 'Unable to update FND_FLEX_VALUE_SETS. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (p_rule = 'A.04') THEN
      --
      -- Uexit vsets without any uexit.
      --
      IF (l_vst_set.validation_type NOT IN ('U', 'P')) THEN
         x_message := 'This is not a user exit value set. No need to fix.';
         GOTO return_error;
      END IF;

      BEGIN
         SELECT COUNT(*) INTO l_count
           FROM fnd_flex_validation_events
           WHERE flex_value_set_id = l_vst_set.flex_value_set_id;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to count FND_FLEX_VALIDATION_EVENTS. ' || Sqlerrm;
            GOTO return_error;
      END;

      IF (l_count > 0) THEN
         x_message :=
           'There are ' || To_char(l_count) || ' user exits. No need to fix.';
         GOTO return_error;
      END IF;

      BEGIN
         UPDATE fnd_flex_value_sets SET
           validation_type  = 'N',
           last_update_date = Sysdate,
           last_updated_by  = 1
           WHERE flex_value_set_id = l_vst_set.flex_value_set_id;
         x_message := SQL%rowcount || ' row(s) updated.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message := 'Unable to update FND_FLEX_VALUE_SETS. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (p_rule = 'A.05') THEN
      --
      -- Problems in flags.
      --
      IF (NOT lookup_code_exists('SEG_VAL_TYPES',
                                 l_vst_set.validation_type)) THEN
         l_vst_set.validation_type := 'N';
      END IF;

      IF (NOT lookup_code_exists('FIELD_TYPE',
                                 l_vst_set.format_type)) THEN
         l_vst_set.format_type := 'C';
      END IF;

      IF (NOT lookup_code_exists('YES_NO',
                                 l_vst_set.protected_flag)) THEN
         l_vst_set.protected_flag := 'N';
      END IF;

      IF (NOT lookup_code_exists('FLEX_VALUESET_LONGLIST_FLAG',
                                 l_vst_set.longlist_flag)) THEN
         l_vst_set.longlist_flag := 'N';
      END IF;

      IF (NOT lookup_code_exists('FLEX_VST_SECURITY_ENABLED_FLAG',
                                 l_vst_set.security_enabled_flag)) THEN
         l_vst_set.security_enabled_flag := 'N';
      END IF;

      IF (NOT lookup_code_exists('YES_NO',
                                 l_vst_set.alphanumeric_allowed_flag)) THEN
         l_vst_set.alphanumeric_allowed_flag := 'N';
      END IF;

      IF (NOT lookup_code_exists('YES_NO',
                                 l_vst_set.numeric_mode_enabled_flag)) THEN
         l_vst_set.numeric_mode_enabled_flag := 'N';
      END IF;

      IF (NOT lookup_code_exists('YES_NO',
                                 l_vst_set.uppercase_only_flag)) THEN
         l_vst_set.uppercase_only_flag := 'N';
      END IF;

      IF (l_vst_set.validation_type IN ('D', 'Y')) THEN
         IF (l_vst_set.dependant_default_value IS NULL) THEN
            l_vst_set.dependant_default_value := 'N/A';
         END IF;
         IF (l_vst_set.dependant_default_meaning IS NULL) THEN
            l_vst_set.dependant_default_meaning := 'N/A';
         END IF;
      END IF;

      BEGIN
         UPDATE fnd_flex_value_sets SET
           validation_type           = l_vst_set.validation_type,
           format_type               = l_vst_set.format_type,
           protected_flag            = l_vst_set.protected_flag,
           longlist_flag             = l_vst_set.longlist_flag,
           security_enabled_flag     = l_vst_set.security_enabled_flag,
           alphanumeric_allowed_flag = l_vst_set.alphanumeric_allowed_flag,
           numeric_mode_enabled_flag = l_vst_set.numeric_mode_enabled_flag,
           uppercase_only_flag       = l_vst_set.uppercase_only_flag,
           dependant_default_value   = l_vst_set.dependant_default_value,
           dependant_default_meaning = l_vst_set.dependant_default_meaning,
           last_update_date          = Sysdate,
           last_updated_by           = 1
           WHERE flex_value_set_id = l_vst_set.flex_value_set_id;
         x_message := SQL%rowcount || ' row(s) updated.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message := 'Unable to update FND_FLEX_VALUE_SETS. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (p_rule = 'B.02') THEN
      --
      -- Problems in flags.
      --
      IF (NOT fetch_vst_tbl(l_vst_set,
                            l_vst_tbl,
                            x_message)) THEN
         GOTO return_error;
      END IF;

      IF ((l_vst_tbl.id_column_type IS NOT NULL) AND
          (NOT lookup_code_exists('COLUMN_TYPE',
                                  l_vst_tbl.id_column_type))) THEN
         l_vst_tbl.id_column_type := 'V';
      END IF;

      IF (NOT lookup_code_exists('COLUMN_TYPE',
                                 l_vst_tbl.value_column_type)) THEN
         l_vst_tbl.value_column_type := 'V';
      END IF;

      IF ((l_vst_tbl.meaning_column_type IS NOT NULL) AND
          (NOT lookup_code_exists('COLUMN_TYPE',
                                  l_vst_tbl.meaning_column_type))) THEN
         l_vst_tbl.meaning_column_type := 'V';
      END IF;

      IF (NOT lookup_code_exists('YES_NO',
                                 l_vst_tbl.summary_allowed_flag)) THEN
         l_vst_tbl.summary_allowed_flag := 'N';
      END IF;

      BEGIN
         UPDATE fnd_flex_validation_tables SET
           id_column_type       = l_vst_tbl.id_column_type,
           value_column_type    = l_vst_tbl.value_column_type,
           meaning_column_type  = l_vst_tbl.meaning_column_type,
           summary_allowed_flag = l_vst_tbl.summary_allowed_flag,
           last_update_date     = Sysdate,
           last_updated_by      = 1
           WHERE flex_value_set_id = l_vst_tbl.flex_value_set_id;
         x_message := SQL%rowcount || ' row(s) updated.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message := 'Unable to update FND_FLEX_VALIDATION_TABLES. ' ||
              Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   <<return_success>>
   <<return_error>>
   RETURN;
EXCEPTION
   WHEN OTHERS THEN
      x_message := 'fix_vst_set: Top level error: ' || Sqlerrm;
END fix_vst_set;

-- ===========================================================================
PROCEDURE fix_vst_evt(p_rule                         IN VARCHAR2,
                      p_flex_value_set_id            IN NUMBER,
                      p_event_code                   IN VARCHAR2,
                      x_message                      OUT nocopy VARCHAR2)
  IS
     l_vst_set   vst_set_type;
     l_vst_evt   vst_evt_type;
BEGIN
   IF (p_rule = 'C.01') THEN
      --
      -- Events without set.
      --
      BEGIN
         DELETE
           FROM fnd_flex_validation_events fve
           WHERE flex_value_set_id = p_flex_value_set_id
           AND event_code = p_event_code
           AND NOT EXISTS
           (SELECT null
            FROM fnd_flex_value_sets fvs
            WHERE fvs.flex_value_set_id = fve.flex_value_set_id
            AND fvs.validation_type IN ('U', 'P'));
         x_message := SQL%rowcount || ' row(s) deleted.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to delete from FND_FLEX_VALIDATION_EVENTS. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (NOT fetch_vst_set(p_flex_value_set_id,
                         l_vst_set,
                         x_message)) THEN
      GOTO return_error;
   END IF;

   IF (NOT fetch_vst_evt(l_vst_set,
                         p_event_code,
                         l_vst_evt,
                         x_message)) THEN
      GOTO return_error;
   END IF;

   IF (p_rule = 'C.02') THEN
      --
      -- Event code is unknown.
      --
      IF (NOT lookup_code_exists('FLEX_VALIDATION_EVENTS',
                                 l_vst_evt.event_code)) THEN
         BEGIN
            DELETE
              FROM fnd_flex_validation_events fve
              WHERE flex_value_set_id = l_vst_evt.flex_value_set_id
              AND event_code = l_vst_evt.event_code;
            x_message := SQL%rowcount || ' row(s) deleted.';
            GOTO return_success;
         EXCEPTION
            WHEN OTHERS THEN
               x_message :=
                 'Unable to delete from FND_FLEX_VALIDATION_EVENTS. ' ||
                 Sqlerrm;
               GOTO return_error;
         END;
      END IF;
   END IF;

   <<return_success>>
   <<return_error>>
   RETURN;
EXCEPTION
   WHEN OTHERS THEN
      x_message := 'fix_vst_evt: Top level error: ' || Sqlerrm;
END fix_vst_evt;

-- ===========================================================================
PROCEDURE fix_vst_scr(p_rule                         IN VARCHAR2,
                      p_flex_value_set_id            IN NUMBER,
                      p_flex_value_rule_id           IN NUMBER,
                      x_message                      OUT nocopy VARCHAR2)
  IS
BEGIN
   IF (p_rule = 'D.03') THEN
      --
      -- Security rules without set.
      --
      BEGIN
         DELETE
           FROM fnd_flex_value_rules fvr
           WHERE flex_value_set_id = p_flex_value_set_id
           AND flex_value_rule_id = p_flex_value_rule_id
           AND NOT EXISTS
           (SELECT null
            FROM fnd_flex_value_sets fvs
            WHERE fvs.flex_value_set_id = fvr.flex_value_set_id);
         x_message := SQL%rowcount || ' row(s) deleted.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to delete from FND_FLEX_VALUE_RULES. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   <<return_success>>
   <<return_error>>
   RETURN;
EXCEPTION
   WHEN OTHERS THEN
      x_message := 'fix_vst_scr: Top level error: ' || Sqlerrm;
END fix_vst_scr;

-- ===========================================================================
PROCEDURE fix_vst_scl(p_rule                         IN VARCHAR2,
                      p_flex_value_set_id            IN NUMBER,
                      p_flex_value_rule_id           IN NUMBER,
                      p_include_exclude_indicator    IN VARCHAR2,
                      p_flex_value_low               IN VARCHAR2,
                      p_flex_value_high              IN VARCHAR2,
                      x_message                      OUT nocopy VARCHAR2)
  IS
     l_vst_set   vst_set_type;
     l_vst_scr   vst_scr_type;
     l_vst_scl   vst_scl_type;
BEGIN
   IF (p_rule = 'E.01') THEN
      --
      -- Security lines without rules.
      --
      BEGIN
         DELETE
           FROM fnd_flex_value_rule_lines fvrl
           WHERE flex_value_set_id = p_flex_value_set_id
           AND flex_value_rule_id = p_flex_value_rule_id
           AND include_exclude_indicator = p_include_exclude_indicator
           AND flex_value_low = p_flex_value_low
           AND flex_value_high = p_flex_value_high
           AND NOT EXISTS
           (SELECT null
            FROM fnd_flex_value_rules fvr
            WHERE fvr.flex_value_set_id = fvrl.flex_value_set_id
            AND fvr.flex_value_rule_id = fvrl.flex_value_rule_id);
         x_message := SQL%rowcount || ' row(s) deleted.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to delete from FND_FLEX_VALUE_RULE_LINES. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (NOT fetch_vst_set(p_flex_value_set_id,
                         l_vst_set,
                         x_message)) THEN
      GOTO return_error;
   END IF;

   IF (NOT fetch_vst_scr(l_vst_set,
                         p_flex_value_rule_id,
                         l_vst_scr,
                         x_message)) THEN
      GOTO return_error;
   END IF;

   IF (NOT fetch_vst_scl(l_vst_scr,
                         p_include_exclude_indicator,
                         p_flex_value_low,
                         p_flex_value_high,
                         l_vst_scl,
                         x_message)) THEN
      GOTO return_error;
   END IF;

   IF (p_rule = 'E.02') THEN
      --
      -- I/E indicator is unknown.
      --
      IF (NOT lookup_code_exists('INCLUDE_EXCLUDE',
                                 l_vst_scl.include_exclude_indicator)) THEN
         BEGIN
            DELETE
              FROM fnd_flex_value_rule_lines fvrl
              WHERE flex_value_set_id = l_vst_scl.flex_value_set_id
              AND flex_value_rule_id = l_vst_scl.flex_value_rule_id
              AND include_exclude_indicator=l_vst_scl.include_exclude_indicator
              AND flex_value_low = l_vst_scl.flex_value_low
              AND flex_value_high = l_vst_scl.flex_value_high;
            x_message := SQL%rowcount || ' row(s) deleted.';
            GOTO return_success;
         EXCEPTION
            WHEN OTHERS THEN
               x_message :=
                 'Unable to delete from FND_FLEX_VALUE_RULES. ' || Sqlerrm;
               GOTO return_error;
         END;
      END IF;
   END IF;

   <<return_success>>
   <<return_error>>
   RETURN;
EXCEPTION
   WHEN OTHERS THEN
      x_message := 'fix_vst_scl: Top level error: ' || Sqlerrm;
END fix_vst_scl;

-- ===========================================================================
PROCEDURE fix_vst_scu(p_rule                         IN VARCHAR2,
                      p_flex_value_set_id            IN NUMBER,
                      p_flex_value_rule_id           IN NUMBER,
                      p_application_id               IN NUMBER,
                      p_responsibility_id            IN NUMBER,
                      x_message                      OUT nocopy VARCHAR2)
  IS
     l_vst_set   vst_set_type;
     l_vst_scr   vst_scr_type;
     l_vst_scu   vst_scu_type;
BEGIN
   IF (p_rule = 'F.01') THEN
      --
      -- Security usage without rule.
      --
      BEGIN
         DELETE
           FROM fnd_flex_value_rule_usages fvru
           WHERE flex_value_set_id = p_flex_value_set_id
           AND flex_value_rule_id = p_flex_value_rule_id
           AND application_id = p_application_id
           AND responsibility_id = p_responsibility_id
           AND NOT EXISTS
           (SELECT null
            FROM fnd_flex_value_rules fvr
            WHERE fvr.flex_value_set_id = fvru.flex_value_set_id
            AND fvr.flex_value_rule_id = fvru.flex_value_rule_id);
         x_message := SQL%rowcount || ' row(s) deleted.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to delete from FND_FLEX_VALUE_RULE_USAGES. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (NOT fetch_vst_set(p_flex_value_set_id,
                         l_vst_set,
                         x_message)) THEN
      GOTO return_error;
   END IF;

   IF (NOT fetch_vst_scr(l_vst_set,
                         p_flex_value_rule_id,
                         l_vst_scr,
                         x_message)) THEN
      GOTO return_error;
   END IF;

   IF (NOT fetch_vst_scu(l_vst_scr,
                         p_application_id,
                         p_responsibility_id,
                         l_vst_scu,
                         x_message)) THEN
      GOTO return_error;
   END IF;

   IF (p_rule = 'F.02') THEN
      --
      -- Security usage with invalid application id.
      --
      BEGIN
         DELETE
           FROM fnd_flex_value_rule_usages fvru
           WHERE flex_value_set_id = l_vst_scu.flex_value_set_id
           AND flex_value_rule_id = l_vst_scu.flex_value_rule_id
           AND application_id = l_vst_scu.application_id
           AND responsibility_id = l_vst_scu.responsibility_id
           AND NOT EXISTS
           (SELECT null
            FROM fnd_application a
            WHERE a.application_id = fvru.application_id);
         x_message := SQL%rowcount || ' row(s) deleted.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to delete from FND_FLEX_VALUE_RULE_USAGES. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (p_rule = 'F.03') THEN
      --
      -- Security usage with invalid responsibility id.
      --
      BEGIN
         DELETE
           FROM fnd_flex_value_rule_usages fvru
           WHERE flex_value_set_id = l_vst_scu.flex_value_set_id
           AND flex_value_rule_id = l_vst_scu.flex_value_rule_id
           AND application_id = l_vst_scu.application_id
           AND responsibility_id = l_vst_scu.responsibility_id
           AND NOT EXISTS
           (SELECT null
            FROM fnd_responsibility r
            WHERE r.application_id = fvru.application_id
            AND r.responsibility_id = fvru.responsibility_id);
         x_message := SQL%rowcount || ' row(s) deleted.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to delete from FND_FLEX_VALUE_RULE_USAGES. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   <<return_success>>
   <<return_error>>
   RETURN;
EXCEPTION
   WHEN OTHERS THEN
      x_message := 'fix_vst_scu: Top level error: ' || Sqlerrm;
END fix_vst_scu;

-- ===========================================================================
PROCEDURE fix_vst_val(p_rule                         IN VARCHAR2,
                      p_flex_value_set_id            IN NUMBER,
                      p_flex_value_id                IN NUMBER,
                      x_message                      OUT nocopy VARCHAR2)
  IS
     l_vst_set  vst_set_type;
     l_vst_val  vst_val_type;
BEGIN
   IF (p_rule = 'G.03') THEN
      --
      -- Values without set.
      --
      BEGIN
         DELETE
           FROM fnd_flex_values fv
           WHERE flex_value_set_id = p_flex_value_set_id
           AND flex_value_id = p_flex_value_id
           AND NOT EXISTS
           (SELECT null
            FROM fnd_flex_value_sets fvs
            WHERE fvs.flex_value_set_id = fv.flex_value_set_id);
         x_message := SQL%rowcount || ' row(s) deleted.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to delete from FND_FLEX_VALUES. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (NOT fetch_vst_set(p_flex_value_set_id,
                         l_vst_set,
                         x_message)) THEN
      GOTO return_error;
   END IF;

   IF (NOT fetch_vst_val(l_vst_set,
                         p_flex_value_id,
                         l_vst_val,
                         x_message)) THEN
      GOTO return_error;
   END IF;

   IF (p_rule = 'G.04') THEN
      --
      -- Problems in flags.
      --
      IF ((l_vst_val.start_date_active IS NOT NULL) AND
          (l_vst_val.end_date_active IS NOT NULL) AND
          (l_vst_val.start_date_active > l_vst_val.end_date_active)) THEN
         l_vst_val.end_date_active := l_vst_val.start_date_active;
      END IF;

      IF (NOT lookup_code_exists('YES_NO',
                                 l_vst_val.enabled_flag)) THEN
         l_vst_val.enabled_flag := 'Y';
      END IF;

      IF (NOT lookup_code_exists('YES_NO',
                                 l_vst_val.summary_flag)) THEN
         l_vst_val.summary_flag := 'N';
      END IF;

      BEGIN
         UPDATE fnd_flex_values fv SET
           start_date_active     = l_vst_val.start_date_active,
           end_date_active       = l_vst_val.end_date_active,
           enabled_flag          = l_vst_val.enabled_flag,
           summary_flag          = l_vst_val.summary_flag,
           last_update_date      = Sysdate,
           last_updated_by       = 1
           WHERE flex_value_set_id = l_vst_val.flex_value_set_id
           AND flex_value_id = l_vst_val.flex_value_id;
         x_message := SQL%rowcount || ' row(s) updated.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message := 'Unable to update FND_FLEX_VALUES. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   <<return_success>>
   <<return_error>>
   RETURN;
EXCEPTION
   WHEN OTHERS THEN
      x_message := 'fix_vst_val: Top level error: ' || Sqlerrm;
END fix_vst_val;

-- ===========================================================================
PROCEDURE fix_vst_rlg(p_rule                         IN VARCHAR2,
                      p_flex_value_set_id            IN NUMBER,
                      p_hierarchy_id                 IN NUMBER,
                      x_message                      OUT nocopy VARCHAR2)
  IS
BEGIN
   IF (p_rule = 'H.03') THEN
      --
      -- Rollup group without set.
      --
      BEGIN
         DELETE
           FROM fnd_flex_hierarchies fh
           WHERE flex_value_set_id = p_flex_value_set_id
           AND hierarchy_id = p_hierarchy_id
           AND NOT EXISTS
           (SELECT null
            FROM fnd_flex_value_sets fvs
            WHERE fvs.flex_value_set_id = fh.flex_value_set_id);
         x_message := SQL%rowcount || ' row(s) deleted.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to delete from FND_FLEX_HIERARCHIES. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   <<return_success>>
   <<return_error>>
   RETURN;
EXCEPTION
   WHEN OTHERS THEN
      x_message := 'fix_vst_rlg: Top level error: ' || Sqlerrm;
END fix_vst_rlg;

-- ===========================================================================
PROCEDURE fix_vst_fvn(p_rule                         IN VARCHAR2,
                      p_flex_value_set_id            IN NUMBER,
                      p_parent_flex_value            IN VARCHAR2,
                      p_range_attribute              IN VARCHAR2,
                      p_child_flex_value_low         IN VARCHAR2,
                      p_child_flex_value_high        IN VARCHAR2,
                      x_message                      OUT nocopy VARCHAR2)
  IS
BEGIN
   IF (p_rule = 'I.01') THEN
      --
      -- Norm hierarchy without value.
      --
      BEGIN
         DELETE
           FROM fnd_flex_value_norm_hierarchy fvnh
           WHERE flex_value_set_id = p_flex_value_set_id
           AND parent_flex_value = p_parent_flex_value
           AND range_attribute = p_range_attribute
           AND child_flex_value_low = p_child_flex_value_low
           AND child_flex_value_high = p_child_flex_value_high
           AND NOT EXISTS
           (SELECT null
            FROM fnd_flex_values fv
            WHERE fv.flex_value_set_id = fvnh.flex_value_set_id
            AND fv.flex_value = fvnh.parent_flex_value);
         x_message := SQL%rowcount || ' row(s) deleted.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to delete from FND_FLEX_VALUE_NORM_HIERARCHY. ' ||
              Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   <<return_success>>
   <<return_error>>
   RETURN;
EXCEPTION
   WHEN OTHERS THEN
      x_message := 'fix_vst_fvn: Top level error: ' || Sqlerrm;
END fix_vst_fvn;

-- ===========================================================================
PROCEDURE fix_vst_fvh(p_rule                         IN VARCHAR2,
                      p_flex_value_set_id            IN NUMBER,
                      p_parent_flex_value            IN VARCHAR2,
                      p_child_flex_value_low         IN VARCHAR2,
                      p_child_flex_value_high        IN VARCHAR2,
                      x_message                      OUT nocopy VARCHAR2)
  IS
BEGIN
   IF (p_rule = 'J.01') THEN
      --
      -- Denorm Hierarchy without norm hierarchy.
      --
      BEGIN
         DELETE
           FROM fnd_flex_value_hierarchies fvh
           WHERE flex_value_set_id = p_flex_value_set_id
           AND parent_flex_value = p_parent_flex_value
           AND child_flex_value_low = p_child_flex_value_low
           AND child_flex_value_high = p_child_flex_value_high
           AND NOT EXISTS
           (SELECT null
            FROM fnd_flex_value_norm_hierarchy fvnh
            WHERE fvnh.flex_value_set_id = fvh.flex_value_set_id
            AND fvnh.parent_flex_value = fvh.parent_flex_value);
         x_message := SQL%rowcount || ' row(s) deleted.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to delete from FND_FLEX_VALUE_HIERARCHIES. ' ||
              Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   <<return_success>>
   <<return_error>>
   RETURN;
EXCEPTION
   WHEN OTHERS THEN
      x_message := 'fix_vst_fvh: Top level error: ' || Sqlerrm;
END fix_vst_fvh;

-- ***************************************************************************
-- * DFF get_dff_something() RETURN VARCHAR2; functions.
-- ***************************************************************************
-- ===========================================================================
FUNCTION get_dff_flx(p_application_id             IN NUMBER,
                     p_descriptive_flexfield_name IN VARCHAR2)
  RETURN VARCHAR2
  IS
     l_return VARCHAR2(2000);
BEGIN
   SELECT descriptive_flexfield_name  || '/' || title
     INTO l_return
     FROM fnd_descriptive_flexs_vl
     WHERE application_id = p_application_id
     AND descriptive_flexfield_name = p_descriptive_flexfield_name;
   RETURN(line_return(l_return));
EXCEPTION
   WHEN no_data_found THEN
      RETURN(line_return(p_descriptive_flexfield_name ||
                         '/get_dff_flx: no data found.'));
   WHEN OTHERS THEN
      RETURN(line_return(p_descriptive_flexfield_name ||
                         '/get_dff_flx SQLCODE:' || To_char(SQLCODE)));
END get_dff_flx;

-- ===========================================================================
FUNCTION get_dff_ctx(p_application_id               IN NUMBER,
                     p_descriptive_flexfield_name   IN VARCHAR2,
                     p_descriptive_flex_context_cod IN VARCHAR2)
  RETURN VARCHAR2
  IS
     l_return VARCHAR2(2000);
BEGIN
   SELECT descriptive_flex_context_code || '/' ||
     global_flag || '/' ||
     enabled_flag || '/' ||
     descriptive_flex_context_name || '/' ||
     Nvl(description, '<NULL>')
     INTO l_return
     FROM fnd_descr_flex_contexts_vl
     WHERE application_id = p_application_id
     AND descriptive_flexfield_name = p_descriptive_flexfield_name
     AND descriptive_flex_context_code = p_descriptive_flex_context_cod;
   RETURN(line_return(l_return));
EXCEPTION
   WHEN no_data_found THEN
      RETURN(line_return(p_descriptive_flex_context_cod ||
                         '/get_dff_ctx: no data found.'));
   WHEN OTHERS THEN
      RETURN(line_return(p_descriptive_flex_context_cod ||
                         '/get_dff_ctx SQLCODE:' || To_char(SQLCODE)));
END get_dff_ctx;

-- ===========================================================================
FUNCTION get_dff_seg(p_application_id               IN NUMBER,
                     p_descriptive_flexfield_name   IN VARCHAR2,
                     p_descriptive_flex_context_cod IN VARCHAR2,
                     p_application_column_name      IN VARCHAR2)
  RETURN VARCHAR2
  IS
     l_return VARCHAR2(2000);
BEGIN
   SELECT application_column_name || '/' ||
     enabled_flag || '/' ||
     display_flag || '/' ||
     end_user_column_name || '/' ||
     form_left_prompt || '/' ||
     Nvl(description, '<NULL>')
     INTO l_return
     FROM fnd_descr_flex_col_usage_vl
     WHERE application_id = p_application_id
     AND descriptive_flexfield_name = p_descriptive_flexfield_name
     AND descriptive_flex_context_code = p_descriptive_flex_context_cod
     AND application_column_name = p_application_column_name;
   RETURN(line_return(l_return));
EXCEPTION
   WHEN no_data_found THEN
      RETURN(line_return(p_application_column_name ||
                         '/get_dff_seg: no data found.'));
   WHEN OTHERS THEN
      RETURN(line_return(p_application_column_name ||
                         '/get_dff_seg SQLCODE:' || To_char(SQLCODE)));
END get_dff_seg;

-- ===========================================================================
FUNCTION get_dff_tap(p_application_id               IN NUMBER,
                     p_descriptive_flexfield_name   IN VARCHAR2)
  RETURN VARCHAR2
  IS
     l_return VARCHAR2(2000);
BEGIN
   SELECT To_char(avl.application_id) || '/' ||
          avl.application_short_name  || '/' ||
          avl.application_name
     INTO l_return
     FROM fnd_application_vl avl, fnd_descriptive_flexs df
     WHERE avl.application_id = df.table_application_id
     AND df.application_id = p_application_id
     AND df.descriptive_flexfield_name = p_descriptive_flexfield_name;
   RETURN(line_return(l_return));
EXCEPTION
   WHEN no_data_found THEN
      RETURN(line_return('get_dff_tap: no data found.'));
   WHEN OTHERS THEN
      RETURN(line_return('get_dff_tap SQLCODE:' || To_char(SQLCODE)));
END get_dff_tap;

-- ===========================================================================
FUNCTION get_dff_tbl(p_application_id               IN NUMBER,
                     p_descriptive_flexfield_name   IN VARCHAR2)
  RETURN VARCHAR2
  IS
     l_return VARCHAR2(2000);
BEGIN
   SELECT us.table_owner || '/' ||
     ft.table_name || '/' ||
     To_char(table_id)
     INTO l_return
     FROM user_synonyms us, fnd_tables ft, fnd_descriptive_flexs df
     WHERE us.synonym_name = df.application_table_name
     AND ft.application_id = df.table_application_id
     AND ft.table_name = df.application_table_name
     AND df.application_id = p_application_id
     AND df.descriptive_flexfield_name = p_descriptive_flexfield_name;
   RETURN(line_return(l_return));
EXCEPTION
   WHEN no_data_found THEN
      RETURN(line_return('get_dff_tbl: no data found.'));
   WHEN OTHERS THEN
      RETURN(line_return('get_dff_tbl SQLCODE:' || To_char(SQLCODE)));
END get_dff_tbl;

-- ===========================================================================
FUNCTION get_dff_col(p_application_id               IN NUMBER,
                     p_descriptive_flexfield_name   IN VARCHAR2,
                     p_application_column_name      IN VARCHAR2)
  RETURN VARCHAR2
  IS
     l_return VARCHAR2(2000);
BEGIN
   SELECT fc.column_name || '/' ||
     To_char(fc.column_id) || '/' ||
     fc.column_type || '/' ||
     To_char(fc.width) || '/' ||
     fc.flexfield_usage_code || '/' ||
     Nvl(To_char(fc.flexfield_application_id), '<NULL>') || '/' ||
     Nvl(fc.flexfield_name, '<NULL>')
     INTO l_return
     FROM fnd_columns fc, fnd_tables ft, fnd_descriptive_flexs df
     WHERE df.application_id = p_application_id
     AND df.descriptive_flexfield_name = p_descriptive_flexfield_name
     AND ft.application_id = df.table_application_id
     AND ft.table_name = df.application_table_name
     AND fc.application_id = ft.application_id
     AND fc.table_id = ft.table_id
     AND fc.column_name = p_application_column_name;
   RETURN(line_return(l_return));
EXCEPTION
   WHEN no_data_found THEN
      RETURN(line_return('get_dff_col: no data found.'));
   WHEN OTHERS THEN
      RETURN(line_return('get_dff_col SQLCODE:' || To_char(SQLCODE)));
END get_dff_col;

-- ===========================================================================
FUNCTION get_dff_fix(p_rule                         IN VARCHAR2,
                     p_pk1                          IN VARCHAR2 DEFAULT NULL,
                     p_pk2                          IN VARCHAR2 DEFAULT NULL,
                     p_pk3                          IN VARCHAR2 DEFAULT NULL,
                     p_pk4                          IN VARCHAR2 DEFAULT NULL,
                     p_pk5                          IN VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2
  IS
     l_beg    VARCHAR2(100);
     l_mid    VARCHAR2(2000) := NULL;
     l_end    VARCHAR2(100);
     l_cn     VARCHAR2(100) := ',' || g_newline;
BEGIN
   l_beg := (g_newline ||
             'variable msg VARCHAR2(2000);' || g_newline ||
             'BEGIN' || g_newline ||
             ' fnd_flex_diagnose.');
   IF (p_rule IN ('A.03', 'A.09', 'A.10', 'A.11', 'A.12', 'A.13', 'D.01')) THEN
      l_mid :=
        'fix_dff_flx' || g_newline ||
        '  (p_rule                         => ''' || p_rule || '''' || l_cn ||
        '   p_application_id               => '   || p_pk1  || l_cn ||
        '   p_descriptive_flexfield_name   => ''' || p_pk2  || '''' || l_cn;
   END IF;
   IF (p_rule IN ('B.01')) THEN
      l_mid :=
        'fix_dff_ref' || g_newline ||
        '  (p_rule                         => ''' || p_rule || '''' || l_cn ||
        '   p_application_id               => '   || p_pk1  || l_cn ||
        '   p_descriptive_flexfield_name   => ''' || p_pk2  || '''' || l_cn ||
        '   p_default_context_field_name   => ''' || p_pk3  || '''' || l_cn;
   END IF;
   IF (p_rule IN ('C.03', 'C.04', 'C.05', 'C.06')) THEN
      l_mid :=
        'fix_dff_ctx' || g_newline ||
        '  (p_rule                         => ''' || p_rule || '''' || l_cn ||
        '   p_application_id               => '   || p_pk1  || l_cn ||
        '   p_descriptive_flexfield_name   => ''' || p_pk2  || '''' || l_cn ||
        '   p_descriptive_flex_context_cod => ''' || p_pk3  || '''' || l_cn;
   END IF;
   IF (p_rule IN ('E.03', 'E.06', 'E.07', 'E.08')) THEN
      l_mid :=
        'fix_dff_seg' || g_newline ||
        '  (p_rule                         => ''' || p_rule || '''' || l_cn ||
        '   p_application_id               => '   || p_pk1  || l_cn ||
        '   p_descriptive_flexfield_name   => ''' || p_pk2  || '''' || l_cn ||
        '   p_descriptive_flex_context_cod => ''' || p_pk3  || '''' || l_cn ||
        '   p_application_column_name      => ''' || p_pk4  || '''' || l_cn;
   END IF;
   IF (p_rule IN ('F.01', 'F.02')) THEN
      l_mid :=
        'fix_dff_col' || g_newline ||
        '  (p_rule                         => ''' || p_rule || '''' || l_cn ||
        '   p_application_id               => '   || p_pk1  || l_cn ||
        '   p_table_name                   => ''' || p_pk2  || '''' || l_cn ||
        '   p_column_name                  => ''' || p_pk3  || '''' || l_cn;
   END IF;
   l_end :=  ('   x_message                      => :msg);' || g_newline ||
              'END;' || g_newline ||
              '/' || g_newline ||
              'print msg;' || g_newline || g_newline);

   IF (l_mid IS NOT NULL) THEN
      RETURN(l_beg || l_mid || l_end);
    ELSE
      RETURN('DFF fix is not available for rule : ' || p_rule);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      RETURN('get_dff_fix : SQLERRM ' || Sqlerrm);
END get_dff_fix;


-- ***************************************************************************
-- * DFF fix_dff_something(); procedures.
-- ***************************************************************************
-- ===========================================================================
PROCEDURE fix_dff_flx(p_rule                         IN VARCHAR2,
                      p_application_id               IN NUMBER,
                      p_descriptive_flexfield_name   IN VARCHAR2,
                      x_message                      OUT nocopy VARCHAR2)
  IS
     l_tbl        tbl_type;
     l_col        col_type;
     l_dff_flx    dff_flx_type;
     l_dff_ctx    dff_ctx_type;
     l_vst_set    vst_set_type;
     l_rowid      VARCHAR2(100);
     l_count      NUMBER;
BEGIN
   IF (p_rule = 'A.03') THEN
      --
      -- DFF with invalid APPLICATION_ID.
      --
      BEGIN
         DELETE
           FROM fnd_descriptive_flexs df
           WHERE application_id = p_application_id
           AND descriptive_flexfield_name = p_descriptive_flexfield_name
           AND NOT EXISTS
           (SELECT null
            FROM fnd_application aa
            WHERE aa.application_id = df.application_id);
         x_message := SQL%rowcount || ' row(s) deleted.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to delete from FND_DESCRIPTIVE_FLEXS. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (p_rule = 'D.01') THEN
      --
      -- Compiled definitions without DFF.
      --
      BEGIN
         DELETE
           FROM fnd_compiled_descriptive_flexs cdf
           WHERE application_id = p_application_id
           AND descriptive_flexfield_name = p_descriptive_flexfield_name
           AND NOT EXISTS
           (SELECT null
            FROM fnd_descriptive_flexs df
            WHERE df.application_id = cdf.application_id
            AND df.descriptive_flexfield_name =cdf.descriptive_flexfield_name);
         x_message := SQL%rowcount || ' row(s) deleted.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to delete from FND_COMPILED_DESCRIPTIVE_FLEXS. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (NOT fetch_dff_flx(p_application_id,
                         p_descriptive_flexfield_name,
                         l_dff_flx,
                         x_message)) THEN
      GOTO return_error;
   END IF ;

   IF (p_rule = 'A.09') THEN
      --
      -- Context column is not registered properly.
      --
      IF (NOT fetch_tbl(l_dff_flx.table_application_id,
                        l_dff_flx.application_table_name,
                        l_tbl,
                        x_message)) THEN
         GOTO return_error;
      END IF;

      IF (NOT fetch_col(l_tbl,
                        l_dff_flx.context_column_name,
                        l_col,
                        x_message)) THEN
         GOTO return_error;
      END IF;

      IF (l_col.flexfield_application_id = l_dff_flx.application_id AND
          l_col.flexfield_name = l_dff_flx.descriptive_flexfield_name AND
          l_col.flexfield_usage_code = 'C') THEN
         x_message := 'Context column is properly registered. No need to fix.';
         GOTO return_error;
      END IF;

      IF (update_fnd_columns(l_col,
                             'C',
                             l_dff_flx.application_id,
                             l_dff_flx.descriptive_flexfield_name,
                             x_message)) THEN
         GOTO return_success;
       ELSE
         GOTO return_error;
      END IF;
   END IF;

   IF (p_rule = 'A.10') THEN
      --
      -- Global Context doesn't exist.
      --
      SELECT COUNT(*)
        INTO l_count
        FROM fnd_descr_flex_contexts
        WHERE application_id = l_dff_flx.application_id
        AND descriptive_flexfield_name = l_dff_flx.descriptive_flexfield_name
        AND global_flag = 'Y';

      IF (l_count > 0) THEN
         x_message := ('There is at least one global context. You cannot ' ||
                       'create another one.');
         GOTO return_error;
      END IF;

      --
      -- At this point there are no global contexts.
      --
      IF (NOT fetch_dff_ctx(l_dff_flx,
                            'Global Data Elements',
                            l_dff_ctx,
                            x_message)) THEN
         --
         -- GDE doesn't exist, insert it.
         --
         fnd_descr_flex_contexts_pkg.insert_row
           (x_rowid                        => l_rowid,
            x_application_id               => l_dff_flx.application_id,
            x_descriptive_flexfield_name   => l_dff_flx.descriptive_flexfield_name,
            x_descriptive_flex_context_cod => 'Global Data Elements',
            x_enabled_flag                 => 'Y',
            x_global_flag                  => 'Y',
            x_description                  => 'Global Data Elements Context',
            x_descriptive_flex_context_nam => 'Global Data Elements',
            x_creation_date                => Sysdate,
            x_created_by                   => 1,
            x_last_update_date             => Sysdate,
            x_last_updated_by              => 1,
            x_last_update_login            => 0);
         x_message := 'Global Data Elements Context is inserted.';
         GOTO return_success;
       ELSE
         --
         -- GDE exists but is not marked as global.
         --
         BEGIN
            UPDATE fnd_descr_flex_contexts SET
              global_flag      = 'Y',
              last_update_date = Sysdate,
              last_updated_by  = 1
              WHERE application_id = l_dff_flx.application_id
              AND descriptive_flexfield_name = l_dff_flx.descriptive_flexfield_name
              AND descriptive_flex_context_code = 'Global Data Elements';
            x_message := 'Global Data Elements context is marked as global.';
            GOTO return_success;
         EXCEPTION
            WHEN OTHERS THEN
               x_message :=
                 'Unable to update FND_DESCR_FLEX_CONTEXTS. ' || Sqlerrm;
               GOTO return_error;
         END;
      END IF;
   END IF;

   IF (p_rule = 'A.11') THEN
      --
      -- Default context value should exist and be enabled.
      --
      IF (l_dff_flx.default_context_value IS NULL) THEN
         x_message := 'Default context is already NULL. No need to fix.';
         GOTO return_error;
      END IF;

      IF (fetch_dff_ctx(l_dff_flx,
                        l_dff_flx.default_context_value,
                        l_dff_ctx,
                        x_message)) THEN
         IF (l_dff_ctx.enabled_flag = 'Y' AND
             l_dff_ctx.global_flag <> 'Y') THEN
            x_message := 'Non-global default context exists and is enabled. No need to fix.';
            GOTO return_error;
         END IF;
      END IF;

      BEGIN
         UPDATE fnd_descriptive_flexs SET
           default_context_value = NULL,
           last_update_date      = Sysdate,
           last_updated_by       = 1
           WHERE application_id = l_dff_flx.application_id
           AND descriptive_flexfield_name = l_dff_flx.descriptive_flexfield_name;
         x_message := SQL%rowcount || ' row(s) updated.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message := 'Unable to update FND_DESCRIPTIVE_FLEXS. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (p_rule = 'A.12') THEN
      --
      -- Problems in flags.
      --
      IF (NOT lookup_code_exists('YES_NO',
                                 l_dff_flx.context_required_flag)) THEN
         l_dff_flx.context_required_flag := 'N';
      END IF;

      IF (NOT lookup_code_exists('YES_NO',
                                 l_dff_flx.context_user_override_flag)) THEN
         l_dff_flx.context_user_override_flag := 'Y';
      END IF;

      IF (NOT lookup_code_exists('YES_NO',
                                 l_dff_flx.freeze_flex_definition_flag)) THEN
         l_dff_flx.freeze_flex_definition_flag := 'Y';
      END IF;

      IF (l_dff_flx.descriptive_flexfield_name LIKE '$SRS$.%') THEN
         l_dff_flx.protected_flag := 'S';
       ELSE
         IF (NOT lookup_code_exists('YES_NO',
                                    l_dff_flx.protected_flag)) THEN
            l_dff_flx.protected_flag := 'N';
         END IF;
      END IF;

      IF ((Nvl(l_dff_flx.context_default_type, 'C')
           NOT IN ('C', 'F', 'P', 'S')) OR
          (l_dff_flx.context_default_type IS NOT NULL AND
           l_dff_flx.context_default_value IS NULL) OR
          (l_dff_flx.context_default_type IS NULL AND
           l_dff_flx.context_default_value IS NOT NULL)) THEN
         l_dff_flx.context_default_type := NULL;
         l_dff_flx.context_default_value := NULL;
      END IF;

      BEGIN
         UPDATE fnd_descriptive_flexs SET
           context_required_flag       = l_dff_flx.context_required_flag,
           context_user_override_flag  = l_dff_flx.context_user_override_flag,
           freeze_flex_definition_flag = l_dff_flx.freeze_flex_definition_flag,
           protected_flag              = l_dff_flx.protected_flag,
           context_default_type        = l_dff_flx.context_default_type,
           context_default_value       = l_dff_flx.context_default_value,
           last_update_date            = Sysdate,
           last_updated_by             = 1
           WHERE application_id = l_dff_flx.application_id
           AND descriptive_flexfield_name = l_dff_flx.descriptive_flexfield_name;
         x_message := SQL%rowcount || ' row(s) updated.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message := 'Unable to update FND_DESCRIPTIVE_FLEXS. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (p_rule = 'A.13') THEN
      --
      -- Problem with context override value set.
      --
      IF (l_dff_flx.context_override_value_set_id IS NULL) THEN
         x_message := 'No context override value set. No need to fix.';
         GOTO return_error;
      END IF;

      IF (fetch_vst_set(l_dff_flx.context_override_value_set_id,
                        l_vst_set,
                        x_message)) THEN
         x_message := 'Override value set already exists. No need to fix.';
         GOTO return_error;
      END IF;

      BEGIN
         UPDATE fnd_descriptive_flexs SET
           context_override_value_set_id = NULL,
           last_update_date              = Sysdate,
           last_updated_by               = 1
           WHERE application_id = l_dff_flx.application_id
           AND descriptive_flexfield_name = l_dff_flx.descriptive_flexfield_name;
         x_message := SQL%rowcount || ' row(s) updated.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message := 'Unable to update FND_DESCRIPTIVE_FLEXS. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   <<return_success>>
   <<return_error>>
   RETURN;
EXCEPTION
   WHEN OTHERS THEN
      x_message := 'fix_dff_flx: Top level error: ' || Sqlerrm;
END fix_dff_flx;
-- ===========================================================================
PROCEDURE fix_dff_ref(p_rule                         IN VARCHAR2,
                      p_application_id               IN NUMBER,
                      p_descriptive_flexfield_name   IN VARCHAR2,
                      p_default_context_field_name   IN VARCHAR2,
                      x_message                      OUT nocopy VARCHAR2)
  IS
BEGIN
   IF (p_rule = 'B.01') THEN
      --
      -- Reference fields without DFF.
      --
      BEGIN
         DELETE
           FROM fnd_default_context_fields dcf
           WHERE application_id = p_application_id
           AND descriptive_flexfield_name = p_descriptive_flexfield_name
           AND default_context_field_name = p_default_context_field_name
           AND NOT EXISTS
           (SELECT null
            FROM fnd_descriptive_flexs df
            WHERE df.application_id = dcf.application_id
            AND df.descriptive_flexfield_name =dcf.descriptive_flexfield_name);
         x_message := SQL%rowcount || ' row(s) deleted.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to delete from FND_DEFAULT_CONTEXT_FIELDS. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   <<return_success>>
   <<return_error>>
   RETURN;
EXCEPTION
   WHEN OTHERS THEN
      x_message := 'fix_dff_ref: Top level error: ' || Sqlerrm;
END fix_dff_ref;
-- ===========================================================================
PROCEDURE fix_dff_ctx(p_rule                         IN VARCHAR2,
                      p_application_id               IN NUMBER,
                      p_descriptive_flexfield_name   IN VARCHAR2,
                      p_descriptive_flex_context_cod IN VARCHAR2,
                      x_message                      OUT nocopy VARCHAR2)
  IS
     l_dff_flx   dff_flx_type;
     l_dff_ctx   dff_ctx_type;
     l_count     NUMBER;
BEGIN
   IF (p_rule = 'C.03') THEN
      --
      -- Contexts without DFF.
      --
      BEGIN
         DELETE
           FROM fnd_descr_flex_contexts dfc
           WHERE application_id = p_application_id
           AND descriptive_flexfield_name = p_descriptive_flexfield_name
           AND descriptive_flex_context_code = p_descriptive_flex_context_cod
           AND NOT EXISTS
           (SELECT null
            FROM fnd_descriptive_flexs df
            WHERE df.application_id = dfc.application_id
            AND df.descriptive_flexfield_name =dfc.descriptive_flexfield_name);
         x_message := SQL%rowcount || ' row(s) deleted.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to delete from FND_DESCR_FLEX_CONTEXTS. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (NOT fetch_dff_flx(p_application_id,
                         p_descriptive_flexfield_name,
                         l_dff_flx,
                         x_message)) THEN
      GOTO return_error;
   END IF ;

   IF (NOT fetch_dff_ctx(l_dff_flx,
                         p_descriptive_flex_context_cod,
                         l_dff_ctx,
                         x_message)) THEN
      GOTO return_error;
   END IF ;

   IF (p_rule = 'C.04') THEN
      --
      -- There are more than one global context.
      --
      SELECT COUNT(*)
        INTO l_count
        FROM fnd_descr_flex_contexts
        WHERE application_id = l_dff_ctx.application_id
        AND descriptive_flexfield_name = l_dff_ctx.descriptive_flexfield_name
        AND global_flag = 'Y';

      IF (l_count <= 1) THEN
         x_message := 'There is only one global context. No need to fix.';
         GOTO return_error;
      END IF;

      IF (l_dff_ctx.global_flag = 'N') THEN
         x_message := 'This is not a global context.';
         GOTO return_error;
      END IF;

      BEGIN
         UPDATE fnd_descr_flex_contexts SET
           global_flag      = 'N',
           last_update_date = Sysdate,
           last_updated_by  = 1
           WHERE application_id = l_dff_ctx.application_id
           AND descriptive_flexfield_name = l_dff_ctx.descriptive_flexfield_name
           AND descriptive_flex_context_code = l_dff_ctx.descriptive_flex_context_code;

         x_message := SQL%rowcount || ' row(s) updated.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to update FND_DESCR_FLEX_CONTEXTS. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (p_rule = 'C.05') THEN
      --
      -- Global context should be enabled.
      --
      IF (l_dff_ctx.global_flag = 'N') THEN
         x_message := 'This is not a global context.';
         GOTO return_error;
      END IF;

      IF (l_dff_ctx.enabled_flag = 'Y') THEN
         x_message := 'Global context is already enabled. No need to fix.';
         GOTO return_error;
      END IF;

      BEGIN
         UPDATE fnd_descr_flex_contexts SET
           enabled_flag     = 'Y',
           last_update_date = Sysdate,
           last_updated_by  = 1
           WHERE application_id = l_dff_ctx.application_id
           AND descriptive_flexfield_name = l_dff_ctx.descriptive_flexfield_name
           AND descriptive_flex_context_code = l_dff_ctx.descriptive_flex_context_code;

         x_message := SQL%rowcount || ' row(s) updated.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to update FND_DESCR_FLEX_CONTEXTS. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (p_rule = 'C.06') THEN
      --
      -- Problem in flags.
      --
      IF (NOT lookup_code_exists('YES_NO',
                                 l_dff_ctx.global_flag)) THEN
         l_dff_ctx.global_flag := 'N';
      END IF;

      IF (NOT lookup_code_exists('YES_NO',
                                 l_dff_ctx.enabled_flag)) THEN
         l_dff_ctx.enabled_flag := 'N';
      END IF;

      BEGIN
         UPDATE fnd_descr_flex_contexts SET
           global_flag      = l_dff_ctx.global_flag,
           enabled_flag     = l_dff_ctx.enabled_flag,
           last_update_date = Sysdate,
           last_updated_by  = 1
           WHERE application_id = l_dff_ctx.application_id
           AND descriptive_flexfield_name = l_dff_ctx.descriptive_flexfield_name
           AND descriptive_flex_context_code = l_dff_ctx.descriptive_flex_context_code;
         x_message := SQL%rowcount || ' row(s) updated.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to update FND_DESCR_FLEX_CONTEXTS. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   <<return_success>>
   <<return_error>>
   RETURN;
EXCEPTION
   WHEN OTHERS THEN
      x_message := 'fix_dff_ctx: Top level error: ' || Sqlerrm;
END fix_dff_ctx;
-- ===========================================================================
PROCEDURE fix_dff_seg(p_rule                         IN VARCHAR2,
                      p_application_id               IN NUMBER,
                      p_descriptive_flexfield_name   IN VARCHAR2,
                      p_descriptive_flex_context_cod IN VARCHAR2,
                      p_application_column_name      IN VARCHAR2,
                      x_message                      OUT nocopy VARCHAR2)
  IS
     l_tbl          tbl_type;
     l_col          col_type;
     l_vst_set      vst_set_type;
     l_dff_flx      dff_flx_type;
     l_dff_ctx      dff_ctx_type;
     l_dff_seg      dff_seg_type;
BEGIN
   IF (p_rule = 'E.03') THEN
      --
      -- Segments without DFF Context.
      --
      BEGIN
         DELETE
           FROM fnd_descr_flex_column_usages dfcu
           WHERE application_id = p_application_id
           AND descriptive_flexfield_name = p_descriptive_flexfield_name
           AND descriptive_flex_context_code = p_descriptive_flex_context_cod
           AND application_column_name = p_application_column_name
           AND NOT EXISTS
           (SELECT null
            FROM fnd_descr_flex_contexts dfc
            WHERE dfc.application_id = dfcu.application_id
            AND dfc.descriptive_flexfield_name =dfcu.descriptive_flexfield_name
            AND dfc.descriptive_flex_context_code = dfcu.descriptive_flex_context_code);
         x_message := SQL%rowcount || ' row(s) deleted.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to delete from FND_DESCR_FLEX_COLUMN_USAGES. ' ||Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (NOT fetch_dff_flx(p_application_id,
                         p_descriptive_flexfield_name,
                         l_dff_flx,
                         x_message)) THEN
      GOTO return_error;
   END IF ;

   IF (NOT fetch_dff_ctx(l_dff_flx,
                         p_descriptive_flex_context_cod,
                         l_dff_ctx,
                         x_message)) THEN
      GOTO return_error;
   END IF ;

   IF (NOT fetch_dff_seg(l_dff_ctx,
                         p_application_column_name,
                         l_dff_seg,
                         x_message)) THEN
      GOTO return_error;
   END IF;

   IF (p_rule = 'E.06') THEN
      --
      -- Segment column is not registered properly.
      --
      IF (NOT fetch_tbl(l_dff_flx.table_application_id,
                        l_dff_flx.application_table_name,
                        l_tbl,
                        x_message)) THEN
         GOTO return_error;
      END IF;

      IF (NOT fetch_col(l_tbl,
                        l_dff_seg.application_column_name,
                        l_col,
                        x_message)) THEN
         GOTO return_error;
      END IF;

      IF (l_col.flexfield_application_id = l_dff_flx.application_id AND
          l_col.flexfield_name = l_dff_flx.descriptive_flexfield_name AND
          l_col.flexfield_usage_code = 'D') THEN
         x_message := 'Segment column is registered properly. No need to fix.';
         GOTO return_error;
      END IF;

      IF (update_fnd_columns(l_col,
                             'D',
                             l_dff_flx.application_id,
                             l_dff_flx.descriptive_flexfield_name,
                             x_message)) THEN
         GOTO return_success;
       ELSE
         GOTO return_error;
      END IF;
   END IF;

   IF (p_rule = 'E.07') THEN
      --
      -- Non-existing value set is used.
      --
      IF (l_dff_seg.flex_value_set_id IS NULL) THEN
         x_message := 'No value set is used in this segment. No need to fix.';
         GOTO return_error;
      END IF;

      IF (fetch_vst_set(l_dff_seg.flex_value_set_id,
                        l_vst_set,
                        x_message)) THEN
         x_message := 'Value set already exists. No need to fix.';
         GOTO return_error;
      END IF;

      BEGIN
         UPDATE fnd_descr_flex_column_usages SET
           flex_value_set_id = NULL,
           last_update_date  = Sysdate,
           last_updated_by   = 1
           WHERE application_id = l_dff_seg.application_id
           AND descriptive_flexfield_name = l_dff_seg.descriptive_flexfield_name
           AND descriptive_flex_context_code = l_dff_seg.descriptive_flex_context_code
           AND application_column_name = l_dff_seg.application_column_name;
         x_message := SQL%rowcount || ' row(s) updated.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to update FND_DESCR_FLEX_COLUMN_USAGES. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (p_rule = 'E.08') THEN
      --
      -- Problem in flags.
      --
      IF (NOT lookup_code_exists('FLEX_DEFAULT_TYPE',
                                 l_dff_seg.default_type)) THEN
         l_dff_seg.default_type := NULL;
      END IF;

      IF (NOT lookup_code_exists('YES_NO',
                                 l_dff_seg.enabled_flag)) THEN
         l_dff_seg.enabled_flag := 'N';
      END IF;

      IF (NOT lookup_code_exists('YES_NO',
                                 l_dff_seg.display_flag)) THEN
         l_dff_seg.display_flag := 'N';
      END IF;

      IF (NOT lookup_code_exists('RANGE_CODES',
                                 l_dff_seg.range_code)) THEN
         l_dff_seg.range_code := NULL;
      END IF;

      IF (NOT lookup_code_exists('YES_NO',
                                 l_dff_seg.required_flag)) THEN
         l_dff_seg.required_flag := 'N';
      END IF;

      IF (NOT lookup_code_exists('YES_NO',
                                 l_dff_seg.security_enabled_flag)) THEN
         l_dff_seg.security_enabled_flag := 'N';
      END IF;

      BEGIN
         UPDATE fnd_descr_flex_column_usages SET
           default_type          = l_dff_seg.default_type,
           enabled_flag          = l_dff_seg.enabled_flag,
           display_flag          = l_dff_seg.display_flag,
           range_code            = l_dff_seg.range_code,
           required_flag         = l_dff_seg.required_flag,
           security_enabled_flag = l_dff_seg.security_enabled_flag,
           last_update_date      = Sysdate,
           last_updated_by       = 1
           WHERE application_id = l_dff_seg.application_id
           AND descriptive_flexfield_name = l_dff_seg.descriptive_flexfield_name
           AND descriptive_flex_context_code = l_dff_seg.descriptive_flex_context_code
           AND application_column_name = l_dff_seg.application_column_name;
         x_message := SQL%rowcount || ' row(s) updated.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to update FND_DESCR_FLEX_COLUMN_USAGES. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   <<return_success>>
   <<return_error>>
   RETURN;
EXCEPTION
   WHEN OTHERS THEN
      x_message := 'fix_dff_seg: Top level error: ' || Sqlerrm;
END fix_dff_seg;
-- ===========================================================================
PROCEDURE fix_dff_col(p_rule           IN VARCHAR2,
                      p_application_id IN NUMBER,
                      p_table_name     IN VARCHAR2,
                      p_column_name    IN VARCHAR2,
                      x_message        OUT nocopy VARCHAR2)
  IS
     l_tbl     tbl_type;
     l_col     col_type;
     l_dff_flx dff_flx_type;
     l_count   NUMBER;
BEGIN
   IF (NOT fetch_tbl(p_application_id,
                     p_table_name,
                     l_tbl,
                     x_message)) THEN
      GOTO return_error;
   END IF;

   IF (l_tbl.table_name = 'FND_SRS_MASTER') THEN
      x_message := 'No change for FND_SRS_MASTER table columns.';
      GOTO return_error;
   END IF;

   IF (NOT fetch_col(l_tbl,
                     p_column_name,
                     l_col,
                     x_message)) THEN
      GOTO return_error;
   END IF;

   IF (p_rule = 'F.01') THEN
      --
      -- 'C' columns.
      --
      IF (l_col.flexfield_usage_code <> 'C') THEN
         x_message := 'This is not a ''C'' column.';
         GOTO return_error;
      END IF;

      IF (fetch_dff_flx(l_col.flexfield_application_id,
                        l_col.flexfield_name,
                        l_dff_flx,
                        x_message)) THEN
         IF (l_dff_flx.table_application_id = l_tbl.application_id AND
             l_dff_flx.application_table_name = l_tbl.table_name AND
             l_dff_flx.context_column_name = l_col.column_name) THEN
            x_message := ('This column is used by ' ||
                          To_char(l_dff_flx.application_id) || '/' ||
                          l_dff_flx.descriptive_flexfield_name ||
                          '. No need to fix.');
            GOTO return_error;
         END IF;
      END IF;

      IF (update_fnd_columns(l_col, 'N', NULL, NULL, x_message)) THEN
         GOTO return_success;
       ELSE
         GOTO return_error;
      END IF;
   END IF;

   IF (p_rule = 'F.02') THEN
      --
      -- 'D' columns.
      --
      IF (l_col.flexfield_usage_code <> 'D') THEN
         x_message := 'This is not a ''D'' column.';
         GOTO return_error;
      END IF;

      IF (fetch_dff_flx(l_col.flexfield_application_id,
                        l_col.flexfield_name,
                        l_dff_flx,
                        x_message)) THEN
         IF (l_dff_flx.table_application_id = l_tbl.application_id AND
             l_dff_flx.application_table_name = l_tbl.table_name) THEN
            x_message := ('This column is possibly used by ' ||
                          To_char(l_dff_flx.application_id) || '/' ||
                          l_dff_flx.descriptive_flexfield_name ||
                          '. No need to fix.');
            GOTO return_error;
         END IF;
      END IF;

      IF (update_fnd_columns(l_col, 'N', NULL, NULL, x_message)) THEN
         GOTO return_success;
       ELSE
         GOTO return_error;
      END IF;
   END IF;

   <<return_success>>
   <<return_error>>
   RETURN;
EXCEPTION
   WHEN OTHERS THEN
      x_message := 'fix_dff_col: Top level error: ' || Sqlerrm;
END fix_dff_col;

-- ***************************************************************************
-- * KFF get_kff_something() RETURN VARCHAR2; functions.
-- ***************************************************************************
-- ===========================================================================
FUNCTION get_kff_flx(p_application_id               IN NUMBER,
                     p_id_flex_code                 IN VARCHAR2)
  RETURN VARCHAR2
  IS
     l_return VARCHAR2(2000);
BEGIN
   SELECT id_flex_code || '/' ||
     id_flex_name  || '/' ||
     Nvl(description, '<NULL>')
     INTO l_return
     FROM fnd_id_flexs
     WHERE application_id = p_application_id
     AND id_flex_code = p_id_flex_code;
   RETURN(line_return(l_return));
EXCEPTION
   WHEN no_data_found THEN
      RETURN(line_return(p_id_flex_code ||
                         '/get_kff_flx: no data found.'));
   WHEN OTHERS THEN
      RETURN(line_return(p_id_flex_code ||
                         '/get_kff_flx SQLCODE:' || To_char(SQLCODE)));
END get_kff_flx;
-- ===========================================================================
FUNCTION get_kff_str(p_application_id               IN NUMBER,
                     p_id_flex_code                 IN VARCHAR2,
                     p_id_flex_num                  IN NUMBER)
  RETURN VARCHAR2
  IS
     l_return VARCHAR2(2000);
BEGIN
   SELECT id_flex_num || '/' ||
     enabled_flag || '/' ||
     freeze_flex_definition_flag || '/' ||
     concatenated_segment_delimiter || '/' ||
     id_flex_structure_name
     INTO l_return
     FROM fnd_id_flex_structures_vl
     WHERE application_id = p_application_id
     AND id_flex_code = p_id_flex_code
     AND id_flex_num = p_id_flex_num;
   RETURN(line_return(l_return));
EXCEPTION
   WHEN no_data_found THEN
      RETURN(line_return(p_id_flex_num ||
                         '/get_kff_str: no data found.'));
   WHEN OTHERS THEN
      RETURN(line_return(p_id_flex_num ||
                         '/get_kff_str SQLCODE:' || To_char(SQLCODE)));
END get_kff_str;
-- ===========================================================================
FUNCTION get_kff_seg(p_application_id               IN NUMBER,
                     p_id_flex_code                 IN VARCHAR2,
                     p_id_flex_num                  IN NUMBER,
                     p_application_column_name      IN VARCHAR2)
  RETURN VARCHAR2
  IS
     l_return VARCHAR2(2000);
BEGIN
   SELECT application_column_name || '/' ||
     enabled_flag || '/' ||
     display_flag || '/' ||
     segment_name || '/' ||
     form_left_prompt || '/' ||
     Nvl(description, '<NULL>')
     INTO l_return
     FROM fnd_id_flex_segments_vl
     WHERE application_id = p_application_id
     AND id_flex_code = p_id_flex_code
     AND id_flex_num = p_id_flex_num
     AND application_column_name = p_application_column_name;
   RETURN(line_return(l_return));
EXCEPTION
   WHEN no_data_found THEN
      RETURN(line_return(p_application_column_name ||
                         '/get_kff_seg: no data found.'));
   WHEN OTHERS THEN
      RETURN(line_return(p_application_column_name ||
                         '/get_kff_seg SQLCODE:' || To_char(SQLCODE)));
END get_kff_seg;
-- ===========================================================================
FUNCTION get_kff_sha(p_application_id               IN NUMBER,
                     p_id_flex_code                 IN VARCHAR2,
                     p_id_flex_num                  IN NUMBER,
                     p_alias_name                   IN VARCHAR2)
  RETURN VARCHAR2
  IS
     l_return VARCHAR2(32000);
BEGIN
   SELECT alias_name || '/' || enabled_flag || '/' ||
     concatenated_segments || '/' || Nvl(description, '<NULL>')
     INTO l_return
     FROM fnd_shorthand_flex_aliases
     WHERE application_id = p_application_id
     AND id_flex_code = p_id_flex_code
     AND id_flex_num = p_id_flex_num
     AND alias_name = p_alias_name;
   RETURN(line_return(l_return));
EXCEPTION
   WHEN no_data_found THEN
      RETURN(line_return(p_alias_name ||
                         '/get_kff_sha: no data found.'));
   WHEN OTHERS THEN
      RETURN(line_return(p_alias_name ||
                         '/get_kff_sha SQLCODE:' || To_char(SQLCODE)));
END get_kff_sha;
-- ===========================================================================
FUNCTION get_kff_cvr(p_application_id               IN NUMBER,
                     p_id_flex_code                 IN VARCHAR2,
                     p_id_flex_num                  IN NUMBER,
                     p_flex_validation_rule_name    IN VARCHAR2)
  RETURN VARCHAR2
  IS
     l_return VARCHAR2(32000);
BEGIN
   SELECT flex_validation_rule_name || '/' || enabled_flag || '/' ||
     error_message_text || '/' || Nvl(description, '<NULL>')
     INTO l_return
     FROM fnd_flex_vdation_rules_vl
     WHERE application_id = p_application_id
     AND id_flex_code = p_id_flex_code
     AND id_flex_num = p_id_flex_num
     AND flex_validation_rule_name = p_flex_validation_rule_name;
   RETURN(line_return(l_return));
EXCEPTION
   WHEN no_data_found THEN
      RETURN(line_return(p_flex_validation_rule_name ||
                         '/get_kff_cvr: no data found.'));
   WHEN OTHERS THEN
      RETURN(line_return(p_flex_validation_rule_name ||
                         '/get_kff_cvr SQLCODE:' || To_char(SQLCODE)));
END get_kff_cvr;
-- ===========================================================================
FUNCTION get_kff_cvl(p_application_id               IN NUMBER,
                     p_id_flex_code                 IN VARCHAR2,
                     p_id_flex_num                  IN NUMBER,
                     p_flex_validation_rule_name    IN VARCHAR2,
                     p_rule_line_id                 IN NUMBER)
  RETURN VARCHAR2
  IS
     l_return VARCHAR2(32000);
BEGIN
   SELECT rule_line_id || '/' || enabled_flag || '/' ||
     include_exclude_indicator || '/' ||
     concatenated_segments_low || '/' ||
     concatenated_segments_high
     INTO l_return
     FROM fnd_flex_validation_rule_lines
     WHERE application_id = p_application_id
     AND id_flex_code = p_id_flex_code
     AND id_flex_num = p_id_flex_num
     AND flex_validation_rule_name = p_flex_validation_rule_name
     AND rule_line_id = p_rule_line_id;
   RETURN(line_return(l_return));
EXCEPTION
   WHEN no_data_found THEN
      RETURN(line_return(p_rule_line_id ||
                         '/get_kff_cvl: no data found.'));
   WHEN OTHERS THEN
      RETURN(line_return(p_rule_line_id ||
                         '/get_kff_cvl SQLCODE:' || To_char(SQLCODE)));
END get_kff_cvl;
-- ===========================================================================
FUNCTION get_kff_flq(p_application_id               IN NUMBER,
                     p_id_flex_code                 IN VARCHAR2,
                     p_segment_attribute_type       IN VARCHAR2)
  RETURN VARCHAR2
  IS
     l_return VARCHAR2(32000);
BEGIN
   SELECT segment_attribute_type || '/' ||
     global_flag || '/' || required_flag || '/' || unique_flag || '/' ||
     segment_prompt
     INTO l_return
     FROM fnd_segment_attribute_types
     WHERE application_id = p_application_id
     AND id_flex_code = p_id_flex_code
     AND segment_attribute_type = p_segment_attribute_type;
   RETURN(line_return(l_return));
EXCEPTION
   WHEN no_data_found THEN
      RETURN(line_return(p_segment_attribute_type ||
                         '/get_kff_flq: no data found.'));
   WHEN OTHERS THEN
      RETURN(line_return(p_segment_attribute_type ||
                         '/get_kff_flq SQLCODE:' || To_char(SQLCODE)));
END get_kff_flq;
-- ===========================================================================
FUNCTION get_kff_sgq(p_application_id               IN NUMBER,
                     p_id_flex_code                 IN VARCHAR2,
                     p_segment_attribute_type       IN VARCHAR2,
                     p_value_attribute_type         IN VARCHAR2)
  RETURN VARCHAR2
  IS
     l_return VARCHAR2(32000);
BEGIN
   SELECT value_attribute_type || '/' || application_column_name || '/' ||
     lookup_type || '/' || default_value || '/' || prompt
     INTO l_return
     FROM fnd_val_attribute_types_vl
     WHERE application_id = p_application_id
     AND id_flex_code = p_id_flex_code
     AND segment_attribute_type = p_segment_attribute_type
     AND value_attribute_type = p_value_attribute_type;
   RETURN(line_return(l_return));
EXCEPTION
   WHEN no_data_found THEN
      RETURN(line_return(p_value_attribute_type ||
                         '/get_kff_sgq: no data found.'));
   WHEN OTHERS THEN
      RETURN(line_return(p_value_attribute_type ||
                         '/get_kff_sgq SQLCODE:' || To_char(SQLCODE)));
END get_kff_sgq;
-- ===========================================================================
FUNCTION get_kff_tap(p_application_id               IN NUMBER,
                     p_id_flex_code                 IN VARCHAR2)
  RETURN VARCHAR2
  IS
     l_return VARCHAR2(2000);
BEGIN
   SELECT To_char(avl.application_id) || '/' ||
          avl.application_short_name  || '/' ||
          avl.application_name
     INTO l_return
     FROM fnd_application_vl avl, fnd_id_flexs idf
     WHERE avl.application_id = idf.table_application_id
     AND idf.application_id = p_application_id
     AND idf.id_flex_code = p_id_flex_code;
   RETURN(line_return(l_return));
EXCEPTION
   WHEN no_data_found THEN
      RETURN(line_return('get_kff_tap: no data found.'));
   WHEN OTHERS THEN
      RETURN(line_return('get_kff_tap SQLCODE:' || To_char(SQLCODE)));
END get_kff_tap;
-- ===========================================================================
FUNCTION get_kff_tbl(p_application_id               IN NUMBER,
                     p_id_flex_code                 IN VARCHAR2)
  RETURN VARCHAR2
  IS
     l_return VARCHAR2(2000);
BEGIN
   SELECT us.table_owner || '/' ||
     ft.table_name || '/' ||
     To_char(table_id)
     INTO l_return
     FROM user_synonyms us, fnd_tables ft, fnd_id_flexs idf
     WHERE us.synonym_name = idf.application_table_name
     AND ft.application_id = idf.table_application_id
     AND ft.table_name = idf.application_table_name
     AND idf.application_id = p_application_id
     AND idf.id_flex_code = p_id_flex_code;
   RETURN(line_return(l_return));
EXCEPTION
   WHEN no_data_found THEN
      RETURN(line_return('get_kff_tbl: no data found.'));
   WHEN OTHERS THEN
      RETURN(line_return('get_kff_tbl SQLCODE:' || To_char(SQLCODE)));
END get_kff_tbl;
-- ===========================================================================
FUNCTION get_kff_col(p_application_id               IN NUMBER,
                     p_id_flex_code                 IN VARCHAR2,
                     p_application_column_name      IN VARCHAR2)
  RETURN VARCHAR2
  IS
     l_return VARCHAR2(2000);
BEGIN
   SELECT fc.column_name || '/' ||
     To_char(fc.column_id) || '/' ||
     fc.column_type || '/' ||
     To_char(fc.width) || '/' ||
     fc.flexfield_usage_code || '/' ||
     Nvl(To_char(fc.flexfield_application_id), '<NULL>') || '/' ||
     Nvl(fc.flexfield_name, '<NULL>')
     INTO l_return
     FROM fnd_columns fc, fnd_tables ft, fnd_id_flexs idf
     WHERE idf.application_id = p_application_id
     AND idf.id_flex_code = p_id_flex_code
     AND ft.application_id = idf.table_application_id
     AND ft.table_name = idf.application_table_name
     AND fc.application_id = ft.application_id
     AND fc.table_id = ft.table_id
     AND fc.column_name = p_application_column_name;
   RETURN(line_return(l_return));
EXCEPTION
   WHEN no_data_found THEN
      RETURN(line_return('get_kff_col: no data found.'));
   WHEN OTHERS THEN
      RETURN(line_return('get_kff_col SQLCODE:' || To_char(SQLCODE)));
END get_kff_col;
-- ===========================================================================
FUNCTION get_kff_fwp(p_application_id               IN NUMBER,
                     p_id_flex_code                 IN VARCHAR2,
                     p_id_flex_num                  IN NUMBER,
                     p_wf_item_type                 IN VARCHAR2)
  RETURN VARCHAR2
  IS
     l_return VARCHAR2(2000);
BEGIN
   SELECT wf_item_type || '/' || wf_process_name
     INTO l_return
     FROM fnd_flex_workflow_processes fwp
     WHERE application_id = p_application_id
     AND id_flex_code = p_id_flex_code
     AND id_flex_num = p_id_flex_num
     AND wf_item_type = p_wf_item_type;
   RETURN(line_return(l_return));
EXCEPTION
   WHEN no_data_found THEN
      RETURN(line_return(p_wf_item_type ||
                         '/get_kff_fwp: no data found.'));
   WHEN OTHERS THEN
      RETURN(line_return(p_wf_item_type ||
                         '/get_kff_fwp SQLCODE:' || To_char(SQLCODE)));
END get_kff_fwp;
-- ===========================================================================
FUNCTION get_kff_fix(p_rule                         IN VARCHAR2,
                     p_pk1                          IN VARCHAR2 DEFAULT NULL,
                     p_pk2                          IN VARCHAR2 DEFAULT NULL,
                     p_pk3                          IN VARCHAR2 DEFAULT NULL,
                     p_pk4                          IN VARCHAR2 DEFAULT NULL,
                     p_pk5                          IN VARCHAR2 DEFAULT NULL,
                     p_pk6                          IN VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2
  IS
     l_beg    VARCHAR2(100);
     l_mid    VARCHAR2(2000) := NULL;
     l_end    VARCHAR2(100);
     l_cn     VARCHAR2(100) := ',' || g_newline;
BEGIN
   l_beg := (g_newline ||
             'variable msg VARCHAR2(2000);' || g_newline ||
             'BEGIN' || g_newline ||
             ' fnd_flex_diagnose.');
   IF (p_rule IN ('A.01', 'A.07', 'A.10', 'A.11', 'A.12', 'D.01')) THEN
      l_mid :=
        'fix_kff_flx' || g_newline ||
        '  (p_rule                         => ''' || p_rule || '''' || l_cn ||
        '   p_application_id               => '   || p_pk1  || l_cn ||
        '   p_id_flex_code                 => ''' || p_pk2  || '''' || l_cn;
   END IF;
   IF (p_rule IN ('B.03', 'B.04', 'E.01', 'E.02', 'K.01', 'K.02')) THEN
      l_mid :=
        'fix_kff_str' || g_newline ||
        '  (p_rule                         => ''' || p_rule || '''' || l_cn ||
        '   p_application_id               => '   || p_pk1  || l_cn ||
        '   p_id_flex_code                 => ''' || p_pk2  || '''' || l_cn ||
        '   p_id_flex_num                  => '   || p_pk3  || l_cn;
   END IF;
   IF (p_rule IN ('C.03', 'C.06', 'C.07', 'C.08')) THEN
      l_mid :=
        'fix_kff_seg' || g_newline ||
        '  (p_rule                         => ''' || p_rule || '''' || l_cn ||
        '   p_application_id               => '   || p_pk1  || l_cn ||
        '   p_id_flex_code                 => ''' || p_pk2  || '''' || l_cn ||
        '   p_id_flex_num                  => '   || p_pk3  || l_cn ||
        '   p_application_column_name      => ''' || p_pk4  || '''' || l_cn;
   END IF;
   IF (p_rule IN ('F.01', 'F.02')) THEN
      l_mid :=
        'fix_kff_sha' || g_newline ||
        '  (p_rule                         => ''' || p_rule || '''' || l_cn ||
        '   p_application_id               => '   || p_pk1  || l_cn ||
        '   p_id_flex_code                 => ''' || p_pk2  || '''' || l_cn ||
        '   p_id_flex_num                  => '   || p_pk3  || l_cn ||
        '   p_alias_name                   => ''' || p_pk4  || '''' || l_cn;
   END IF;
   IF (p_rule IN ('G.03', 'G.04', 'G.05', 'G.07')) THEN
      l_mid :=
        'fix_kff_cvr' || g_newline ||
        '  (p_rule                         => ''' || p_rule || '''' || l_cn ||
        '   p_application_id               => '   || p_pk1  || l_cn ||
        '   p_id_flex_code                 => ''' || p_pk2  || '''' || l_cn ||
        '   p_id_flex_num                  => '   || p_pk3  || l_cn ||
        '   p_flex_validation_rule_name    => ''' || p_pk4  || '''' || l_cn;
   END IF;
   IF (p_rule IN ('H.01', 'H.02', 'I.01', 'J.01')) THEN
      l_mid :=
        'fix_kff_cvl' || g_newline ||
        '  (p_rule                         => ''' || p_rule || '''' || l_cn ||
        '   p_application_id               => '   || p_pk1  || l_cn ||
        '   p_id_flex_code                 => ''' || p_pk2  || '''' || l_cn ||
        '   p_id_flex_num                  => '   || p_pk3  || l_cn ||
        '   p_flex_validation_rule_name    => ''' || p_pk4  || '''' || l_cn ||
        '   p_rule_line_id                 => '   || p_pk5  || l_cn;
   END IF;
   IF (p_rule IN ('G.06', 'H.03')) THEN
      l_mid :=
        'fix_kff_cvrls' || g_newline ||
        '  (p_rule                         => ''' || p_rule || '''' || l_cn;
   END IF;
   IF (p_rule IN ('L.01', 'L.02')) THEN
      l_mid :=
        'fix_kff_flq' || g_newline ||
        '  (p_rule                         => ''' || p_rule || '''' || l_cn ||
        '   p_application_id               => '   || p_pk1  || l_cn ||
        '   p_id_flex_code                 => ''' || p_pk2  || '''' || l_cn ||
        '   p_segment_attribute_type       => ''' || p_pk3  || '''' || l_cn;
   END IF;
   IF (p_rule IN ('M.01', 'M.02', 'M.03', 'M.04')) THEN
      l_mid :=
        'fix_kff_qlv' || g_newline ||
        '  (p_rule                         => ''' || p_rule || '''' || l_cn ||
        '   p_application_id               => '   || p_pk1  || l_cn ||
        '   p_id_flex_code                 => ''' || p_pk2  || '''' || l_cn ||
        '   p_id_flex_num                  => '   || p_pk3  || l_cn ||
        '   p_application_column_name      => ''' || p_pk4  || '''' || l_cn ||
        '   p_segment_attribute_type       => ''' || p_pk5  || '''' || l_cn;
   END IF;
   IF (p_rule IN ('N.03', 'N.06', 'N.07')) THEN
      l_mid :=
        'fix_kff_sgq' || g_newline ||
        '  (p_rule                         => ''' || p_rule || '''' || l_cn ||
        '   p_application_id               => '   || p_pk1  || l_cn ||
        '   p_id_flex_code                 => ''' || p_pk2  || '''' || l_cn ||
        '   p_segment_attribute_type       => ''' || p_pk3  || '''' || l_cn ||
        '   p_value_attribute_type         => ''' || p_pk4  || '''' || l_cn;
   END IF;
   IF (p_rule IN ('O.01', 'O.02')) THEN
      l_mid :=
        'fix_kff_fvq' || g_newline ||
        '  (p_rule                         => ''' || p_rule || '''' || l_cn ||
        '   p_id_flex_application_id       => '   || p_pk1  || l_cn ||
        '   p_id_flex_code                 => ''' || p_pk2  || '''' || l_cn ||
        '   p_segment_attribute_type       => ''' || p_pk3  || '''' || l_cn ||
        '   p_value_attribute_type         => ''' || p_pk4  || '''' || l_cn ||
        '   p_flex_value_set_id            => '   || p_pk5  || l_cn;
   END IF;
   IF (p_rule IN ('P.01', 'P.02', 'P.03', 'P.04')) THEN
      l_mid :=
        'fix_kff_col' || g_newline ||
        '  (p_rule                         => ''' || p_rule || '''' || l_cn ||
        '   p_application_id               => '   || p_pk1  || l_cn ||
        '   p_table_name                   => ''' || p_pk2  || '''' || l_cn ||
        '   p_column_name                  => ''' || p_pk3  || '''' || l_cn;
   END IF;
   IF (p_rule IN ('R.01', 'R.02')) THEN
      l_mid :=
        'fix_kff_fwp' || g_newline ||
        '  (p_rule                         => ''' || p_rule || '''' || l_cn ||
        '   p_application_id               => '   || p_pk1  || l_cn ||
        '   p_id_flex_code                 => ''' || p_pk2  || '''' || l_cn ||
        '   p_id_flex_num                  => '   || p_pk3  || l_cn ||
        '   p_wf_item_type                 => ''' || p_pk4  || '''' || l_cn;
   END IF;
   l_end :=  ('   x_message                      => :msg);' || g_newline ||
              'END;' || g_newline ||
              '/' || g_newline ||
              'print msg;' || g_newline || g_newline);

   IF (l_mid IS NOT NULL) THEN
      RETURN(l_beg || l_mid || l_end);
    ELSE
      RETURN('KFF fix is not available for rule : ' || p_rule);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      RETURN('get_kff_fix : SQLERRM ' || Sqlerrm);
END get_kff_fix;


-- ***************************************************************************
-- * KFF fix_kff_something(); procedures.
-- ***************************************************************************
-- ---------------------------------------------------------------------------
FUNCTION populate_kff_cvrls(p_kff_str                      IN kff_str_type,
                            x_message                      OUT nocopy VARCHAR2)
  RETURN BOOLEAN
  IS
     l_r_count    NUMBER;
     l_l_count    NUMBER;
     l_i_count    NUMBER;
     l_e_count    NUMBER;

     CURSOR kff_cvl_cur(p_kff_str kff_str_type) IS
        SELECT *
          FROM fnd_flex_validation_rule_lines
          WHERE application_id = p_kff_str.application_id
          AND id_flex_code = p_kff_str.id_flex_code
          AND id_flex_num = p_kff_str.id_flex_num
          ORDER BY flex_validation_rule_name;
BEGIN
   SAVEPOINT sp_populate_kff_cvrls;

   BEGIN
      SELECT COUNT(*)
        INTO l_r_count
        FROM fnd_flex_validation_rules
        WHERE application_id = p_kff_str.application_id
        AND id_flex_code = p_kff_str.id_flex_code
        AND id_flex_num = p_kff_str.id_flex_num;
   EXCEPTION
      WHEN OTHERS THEN
         x_message :=
           'Unable to count FND_FLEX_VALIDATION_RULES.  ' || Sqlerrm;
         GOTO return_error;
   END;

   BEGIN
      SELECT COUNT(*)
        INTO l_l_count
        FROM fnd_flex_validation_rule_lines
        WHERE application_id = p_kff_str.application_id
        AND id_flex_code = p_kff_str.id_flex_code
        AND id_flex_num = p_kff_str.id_flex_num;
   EXCEPTION
      WHEN OTHERS THEN
         x_message :=
           'Unable to count FND_FLEX_VALIDATION_RULE_LINES.  ' || Sqlerrm;
         GOTO return_error;
   END;

   BEGIN
      DELETE
        FROM fnd_flex_include_rule_lines
        WHERE application_id = p_kff_str.application_id
        AND id_flex_code = p_kff_str.id_flex_code
        AND id_flex_num = p_kff_str.id_flex_num;
   EXCEPTION
      WHEN OTHERS THEN
         x_message :=
           'Unable to delete from FND_FLEX_INCLUDE_RULE_LINES. ' ||
           Sqlerrm;
         GOTO return_error;
   END;

   BEGIN
      DELETE
        FROM fnd_flex_exclude_rule_lines
        WHERE application_id = p_kff_str.application_id
        AND id_flex_code = p_kff_str.id_flex_code
        AND id_flex_num = p_kff_str.id_flex_num;
   EXCEPTION
      WHEN OTHERS THEN
         x_message :=
           'Unable to delete from FND_FLEX_EXCLUDE_RULE_LINES. ' ||
           Sqlerrm;
         GOTO return_error;
   END;

   BEGIN
      DELETE
        FROM fnd_flex_validation_rule_stats
        WHERE application_id = p_kff_str.application_id
        AND id_flex_code = p_kff_str.id_flex_code
        AND id_flex_num = p_kff_str.id_flex_num;
   EXCEPTION
      WHEN OTHERS THEN
         x_message :=
           'Unable to delete from FND_FLEX_VALIDATION_RULE_STATS. ' ||
           Sqlerrm;
         GOTO return_error;
   END;

   IF (l_l_count > 0) THEN
      BEGIN
         INSERT
           INTO fnd_flex_validation_rule_stats
           (application_id,
            id_flex_code,
            id_flex_num,
            creation_date, created_by,
            last_update_date, last_updated_by, last_update_login,
            rule_count, include_line_count, exclude_line_count)
           VALUES
           (p_kff_str.application_id,
            p_kff_str.id_flex_code,
            p_kff_str.id_flex_num,
            Sysdate, -1,
            Sysdate, -1, -1,
            0, 0, 0);
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to insert into FND_FLEX_VALIDATION_RULE_STATS. ' ||
              Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   BEGIN
      FOR kff_cvl_rec IN kff_cvl_cur(p_kff_str) LOOP
         IF (fnd_flex_trigger.insert_rule_line
             (kff_cvl_rec.rule_line_id,
              kff_cvl_rec.application_id,
              kff_cvl_rec.id_flex_code,
              kff_cvl_rec.id_flex_num,
              kff_cvl_rec.flex_validation_rule_name,
              kff_cvl_rec.include_exclude_indicator,
              kff_cvl_rec.enabled_flag,
              kff_cvl_rec.created_by,
              kff_cvl_rec.creation_date,
              kff_cvl_rec.last_update_date,
              kff_cvl_rec.last_updated_by,
              kff_cvl_rec.last_update_login,
              kff_cvl_rec.concatenated_segments_low,
              kff_cvl_rec.concatenated_segments_high) = FALSE) THEN
            x_message := fnd_message.get;
            GOTO return_error;
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         x_message := 'Unable to populate I/E tables.  ' || Sqlerrm;
         GOTO return_error;
   END;

   BEGIN
      SELECT COUNT(*)
        INTO l_i_count
        FROM fnd_flex_include_rule_lines
        WHERE application_id = p_kff_str.application_id
        AND id_flex_code = p_kff_str.id_flex_code
        AND id_flex_num = p_kff_str.id_flex_num;
   EXCEPTION
      WHEN OTHERS THEN
         x_message :=
           'Unable to count FND_FLEX_INCLUDE_RULE_LINES.  ' || Sqlerrm;
         GOTO return_error;
   END;

   BEGIN
      SELECT COUNT(*)
        INTO l_e_count
        FROM fnd_flex_exclude_rule_lines
        WHERE application_id = p_kff_str.application_id
        AND id_flex_code = p_kff_str.id_flex_code
        AND id_flex_num = p_kff_str.id_flex_num;
   EXCEPTION
      WHEN OTHERS THEN
         x_message :=
           'Unable to count FND_FLEX_EXCLUDE_RULE_LINES.  ' || Sqlerrm;
         GOTO return_error;
   END;

   IF (l_i_count + l_e_count <> l_l_count) THEN
      x_message := 'I/E count sum is not equal to total line count. '||
        'Please open a bug and assign it to AOL/FLEXFIELDS team. ';
      GOTO return_error;
   END IF;

   BEGIN
      UPDATE fnd_flex_validation_rule_stats fvrs SET
        last_update_date   = Sysdate,
        last_updated_by    = 1,
        rule_count         = l_r_count,
        include_line_count = l_i_count,
        exclude_line_count = l_e_count
        WHERE application_id = p_kff_str.application_id
        AND id_flex_code = p_kff_str.id_flex_code
        AND id_flex_num = p_kff_str.id_flex_num;
   EXCEPTION
      WHEN OTHERS THEN
         x_message := 'Unable to update FND_FLEX_VALIDATION_RULE_STATS. ' ||
           Sqlerrm;
         GOTO return_error;
   END;

   <<return_success>>
   RETURN(TRUE);

   <<return_error>>
   ROLLBACK TO sp_populate_kff_cvrls;
   RETURN(FALSE);
EXCEPTION
   WHEN OTHERS THEN
      x_message := 'populate_kff_cvrls: Top level error: ' || Sqlerrm;
      ROLLBACK TO sp_populate_kff_cvrls;
      RETURN(FALSE);
END populate_kff_cvrls;

-- ===========================================================================
PROCEDURE fix_kff_flx(p_rule                         IN VARCHAR2,
                      p_application_id               IN NUMBER,
                      p_id_flex_code                 IN VARCHAR2,
                      x_message                      OUT nocopy VARCHAR2)
  IS
     l_tbl        tbl_type;
     l_col        col_type;
     l_kff_flx    kff_flx_type;
     l_kff_str    kff_str_type;
     l_rowid      VARCHAR2(100);
     l_count      NUMBER;
BEGIN
   IF (p_rule = 'A.01') THEN
      --
      -- KFF with invalid APPLICATION_ID.
      --
      BEGIN
         DELETE
           FROM fnd_id_flexs idf
           WHERE application_id = p_application_id
           AND id_flex_code = p_id_flex_code
           AND NOT EXISTS
           (SELECT null
            FROM fnd_application aa
            WHERE aa.application_id = idf.application_id);
         x_message := SQL%rowcount || ' row(s) deleted.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to delete from FND_ID_FLEXS. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (p_rule = 'D.01') THEN
      --
      -- Compiled definitions without KFF.
      --
      BEGIN
         DELETE
           FROM fnd_compiled_id_flexs cif
           WHERE application_id = p_application_id
           AND id_flex_code = p_id_flex_code
           AND NOT EXISTS
           (SELECT null
            FROM fnd_id_flexs idf
            WHERE idf.application_id = cif.application_id
            AND idf.id_flex_code = cif.id_flex_code);
         x_message := SQL%rowcount || ' row(s) deleted.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to delete from FND_COMPILED_ID_FLEXS. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (NOT fetch_kff_flx(p_application_id,
                         p_id_flex_code,
                         l_kff_flx,
                         x_message)) THEN
      GOTO return_error;
   END IF;

   IF (p_rule = 'A.07') THEN
      --
      -- CCID column is not registered properly.
      --
      IF (NOT fetch_tbl(l_kff_flx.table_application_id,
                        l_kff_flx.application_table_name,
                        l_tbl,
                        x_message)) THEN
         GOTO return_error;
      END IF;

      IF (NOT fetch_col(l_tbl,
                        l_kff_flx.unique_id_column_name,
                        l_col,
                        x_message)) THEN
         GOTO return_error;
      END IF;

      IF (l_col.flexfield_usage_code = 'I') THEN
         x_message := 'CCID column is properly registered. No need to fix.';
         GOTO return_error;
      END IF;

      IF (update_fnd_columns(l_col,
                             'I',
                             NULL, -- l_kff_flx.application_id,
                             NULL, -- l_kff_flx.id_flex_code,
                             x_message)) THEN
         GOTO return_success;
       ELSE
         GOTO return_error;
      END IF;
   END IF;

   IF (p_rule = 'A.10') THEN
      --
      -- Structure column is not registered properly.
      --
      IF (l_kff_flx.set_defining_column_name IS NULL) THEN
         x_message := 'This KFF has no structure column. No need to fix. ';
         GOTO return_error;
      END IF;

      IF (NOT fetch_tbl(l_kff_flx.table_application_id,
                        l_kff_flx.application_table_name,
                        l_tbl,
                        x_message)) THEN
         GOTO return_error;
      END IF;

      IF (NOT fetch_col(l_tbl,
                        l_kff_flx.set_defining_column_name,
                        l_col,
                        x_message)) THEN
         GOTO return_error;
      END IF;

      IF (l_col.flexfield_usage_code = 'S') THEN
         x_message := 'Structure column is properly registered. No need to fix.';
         GOTO return_error;
      END IF;

      IF (update_fnd_columns(l_col,
                             'S',
                             NULL, -- l_kff_flx.application_id,
                             NULL, -- l_kff_flx.id_flex_code,
                             x_message)) THEN
         GOTO return_success;
       ELSE
         GOTO return_error;
      END IF;
   END IF;

   IF (p_rule = 'A.11') THEN
      --
      -- No structures.
      --
      SELECT COUNT(*)
        INTO l_count
        FROM fnd_id_flex_structures
        WHERE application_id = l_kff_flx.application_id
        AND id_flex_code = l_kff_flx.id_flex_code;

      IF (l_count > 0) THEN
         x_message := 'There is at least one structure. No need to fix.';
         GOTO return_error;
      END IF;

      --
      -- At this point there are no structures.
      --
      IF (NOT fetch_kff_str(l_kff_flx,
                            101,
                            l_kff_str,
                            x_message)) THEN
         --
         -- 101 structure doesn't exist, insert it.
         --
         fnd_id_flex_structures_pkg.insert_row
           (x_rowid                        => l_rowid,
            x_application_id               => l_kff_flx.application_id,
            x_id_flex_code                 => l_kff_flx.id_flex_code,
            x_id_flex_num                  => 101,
            x_id_flex_structure_code       => Upper(l_kff_flx.id_flex_name),
            x_concatenated_segment_delimit => '.',
            x_cross_segment_validation_fla => 'N',
            x_dynamic_inserts_allowed_flag => 'N',
            x_enabled_flag                 => 'Y',
            x_freeze_flex_definition_flag  => 'N',
            x_freeze_structured_hier_flag  => 'N',
            x_shorthand_enabled_flag       => 'N',
            x_shorthand_length             => NULL,
            x_structure_view_name          => NULL,
            x_id_flex_structure_name       => l_kff_flx.id_flex_name,
            x_description                  => NULL,
            x_shorthand_prompt             => NULL,
            x_creation_date                => Sysdate,
            x_created_by                   => 1,
            x_last_update_date             => Sysdate,
            x_last_updated_by              => 1,
            x_last_update_login            => 0);
         x_message := '101 Structure is inserted.';
         GOTO return_success;
      END IF;
   END IF;

   IF (p_rule = 'A.12') THEN
      --
      -- Problems in flags.
      --
      IF (NOT lookup_code_exists('KEY_FLEXFIELD_TABLE_TYPE',
                                 l_kff_flx.application_table_type)) THEN
         l_kff_flx.application_table_type := NULL;
      END IF;

      IF (NOT lookup_code_exists('YES_NO',
                                 l_kff_flx.allow_id_valuesets)) THEN
         l_kff_flx.allow_id_valuesets := 'Y';
      END IF;

      IF (NOT lookup_code_exists('YES_NO',
                                 l_kff_flx.dynamic_inserts_feasible_flag)) THEN
         l_kff_flx.dynamic_inserts_feasible_flag := 'N';
      END IF;

      IF (NOT lookup_code_exists('YES_NO',
                                 l_kff_flx.index_flag)) THEN
         l_kff_flx.index_flag := 'N';
      END IF;

      BEGIN
         UPDATE fnd_id_flexs SET
           application_table_type        = l_kff_flx.application_table_type,
           allow_id_valuesets            = l_kff_flx.allow_id_valuesets,
           dynamic_inserts_feasible_flag = l_kff_flx.dynamic_inserts_feasible_flag,
           index_flag                    = l_kff_flx.index_flag,
           last_update_date              = Sysdate,
           last_updated_by               = 1
           WHERE application_id = l_kff_flx.application_id
           AND id_flex_code = l_kff_flx.id_flex_code;
         x_message := SQL%rowcount || ' row(s) updated.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message := 'Unable to update FND_ID_FLEXS. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   <<return_success>>
   <<return_error>>
   RETURN;
EXCEPTION
   WHEN OTHERS THEN
      x_message := 'fix_kff_flx: Top level error: ' || Sqlerrm;
END fix_kff_flx;

-- ===========================================================================
PROCEDURE fix_kff_str(p_rule                         IN VARCHAR2,
                      p_application_id               IN NUMBER,
                      p_id_flex_code                 IN VARCHAR2,
                      p_id_flex_num                  IN NUMBER,
                      x_message                      OUT nocopy VARCHAR2)
  IS
     l_kff_flx    kff_flx_type;
     l_kff_str    kff_str_type;
     l_count      NUMBER;
BEGIN
   IF (p_rule = 'B.03') THEN
      --
      -- Structure without KFF.
      --
      BEGIN
         DELETE
           FROM fnd_id_flex_structures ifst
           WHERE application_id = p_application_id
           AND id_flex_code = p_id_flex_code
           AND id_flex_num = p_id_flex_num
           AND NOT EXISTS
           (SELECT null
            FROM fnd_id_flexs idf
            WHERE idf.application_id = ifst.application_id
            AND idf.id_flex_code = ifst.id_flex_code);
         x_message := SQL%rowcount || ' row(s) deleted.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to delete from FND_ID_FLEX_STRUCTURES. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (p_rule = 'E.01') THEN
      --
      -- Compiled definitions without structure.
      --
      BEGIN
         DELETE
           FROM fnd_compiled_id_flex_structs cifs
           WHERE application_id = p_application_id
           AND id_flex_code = p_id_flex_code
           AND id_flex_num = p_id_flex_num
           AND NOT EXISTS
           (SELECT null
            FROM fnd_id_flex_structures ifst
            WHERE ifst.application_id = cifs.application_id
            AND ifst.id_flex_code = cifs.id_flex_code
            AND ifst.id_flex_num = cifs.id_flex_num);
         x_message := SQL%rowcount || ' row(s) deleted.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to delete from FND_COMPILED_ID_FLEX_STRUCTS. ' ||
              Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (p_rule = 'E.02') THEN
      --
      -- Compiled Structures without compiled KFF.
      --
      BEGIN
         DELETE
           FROM fnd_compiled_id_flex_structs cifs
           WHERE application_id = p_application_id
           AND id_flex_code = p_id_flex_code
           AND id_flex_num = p_id_flex_num
           AND NOT EXISTS
           (SELECT null
            FROM fnd_compiled_id_flexs  cif
            WHERE cif.application_id = cifs.application_id
            AND cif.id_flex_code = cifs.id_flex_code);
         x_message := SQL%rowcount || ' row(s) deleted.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to delete from FND_COMPILED_ID_FLEX_STRUCTS. ' ||
              Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (NOT fetch_kff_flx(p_application_id,
                         p_id_flex_code,
                         l_kff_flx,
                         x_message)) THEN
      GOTO return_error;
   END IF;

   IF (NOT fetch_kff_str(l_kff_flx,
                         p_id_flex_num,
                         l_kff_str,
                         x_message)) THEN
      GOTO return_error;
   END IF;

   IF (p_rule = 'B.04') THEN
      --
      -- Problems in flags.
      --
      IF (NOT lookup_code_exists('YES_NO',
                                 l_kff_str.cross_segment_validation_flag)) THEN
         l_kff_str.cross_segment_validation_flag := 'N';
      END IF;

      IF (NOT lookup_code_exists('YES_NO',
                                 l_kff_str.dynamic_inserts_allowed_flag)) THEN
         l_kff_str.dynamic_inserts_allowed_flag := 'N';
      END IF;

      IF (NOT lookup_code_exists('YES_NO',
                                 l_kff_str.enabled_flag)) THEN
         l_kff_str.enabled_flag := 'N';
      END IF;

      IF (NOT lookup_code_exists('YES_NO',
                                 l_kff_str.freeze_flex_definition_flag)) THEN
         l_kff_str.freeze_flex_definition_flag := 'N';
      END IF;

      IF (NOT lookup_code_exists('YES_NO',
                                 l_kff_str.freeze_structured_hier_flag)) THEN
         l_kff_str.freeze_structured_hier_flag := 'N';
      END IF;

      IF (NOT lookup_code_exists('YES_NO',
                                 l_kff_str.shorthand_enabled_flag)) THEN
         l_kff_str.shorthand_enabled_flag := 'N';
      END IF;

      BEGIN
         UPDATE fnd_id_flex_structures SET
           cross_segment_validation_flag = l_kff_str.cross_segment_validation_flag,
           dynamic_inserts_allowed_flag  = l_kff_str.dynamic_inserts_allowed_flag,
           enabled_flag                  = l_kff_str.enabled_flag,
           freeze_flex_definition_flag   = l_kff_str.freeze_flex_definition_flag,
           freeze_structured_hier_flag   = l_kff_str.freeze_structured_hier_flag,
           shorthand_enabled_flag        = l_kff_str.shorthand_enabled_flag,
           last_update_date              = Sysdate,
           last_updated_by               = 1
           WHERE application_id = l_kff_str.application_id
           AND id_flex_code = l_kff_str.id_flex_code
           AND id_flex_num = l_kff_str.id_flex_num;
         x_message := SQL%rowcount || ' row(s) updated.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to update FND_ID_FLEX_STRUCTURES. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (p_rule IN ('K.01', 'K.02')) THEN
      --
      -- Problems in CVR stats table.
      --
      IF (NOT populate_kff_cvrls(l_kff_str,
                                 x_message)) THEN
         GOTO return_error;
      END IF;
   END IF;

   <<return_success>>
   <<return_error>>
   RETURN;
EXCEPTION
   WHEN OTHERS THEN
      x_message := 'fix_kff_str: Top level error: ' || Sqlerrm;
END fix_kff_str;

-- ===========================================================================
PROCEDURE fix_kff_seg(p_rule                         IN VARCHAR2,
                      p_application_id               IN NUMBER,
                      p_id_flex_code                 IN VARCHAR2,
                      p_id_flex_num                  IN NUMBER,
                      p_application_column_name      IN VARCHAR2,
                      x_message                      OUT nocopy VARCHAR2)
  IS
     l_tbl        tbl_type;
     l_col        col_type;
     l_vst_set    vst_set_type;
     l_kff_flx    kff_flx_type;
     l_kff_str    kff_str_type;
     l_kff_seg    kff_seg_type;
BEGIN
   IF (p_rule = 'C.03') THEN
      --
      -- Segments without Structure.
      --
      BEGIN
         DELETE
           FROM fnd_id_flex_segments ifsg
           WHERE application_id = p_application_id
           AND id_flex_code = p_id_flex_code
           AND id_flex_num = p_id_flex_num
           AND application_column_name = p_application_column_name
           AND NOT EXISTS
           (SELECT null
            FROM fnd_id_flex_structures ifst
            WHERE ifst.application_id = ifsg.application_id
            AND ifst.id_flex_code = ifsg.id_flex_code
            AND ifst.id_flex_num = ifsg.id_flex_num);
         x_message := SQL%rowcount || ' row(s) deleted.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to delete from FND_ID_FLEX_SEGMENTS. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (NOT fetch_kff_flx(p_application_id,
                         p_id_flex_code,
                         l_kff_flx,
                         x_message)) THEN
      GOTO return_error;
   END IF;

   IF (NOT fetch_kff_str(l_kff_flx,
                         p_id_flex_num,
                         l_kff_str,
                         x_message)) THEN
      GOTO return_error;
   END IF;

   IF (NOT fetch_kff_seg(l_kff_str,
                         p_application_column_name,
                         l_kff_seg,
                         x_message)) THEN
      GOTO return_error;
   END IF;

   IF (p_rule = 'C.06') THEN
      --
      -- Segment column is not registered properly.
      --
      IF (NOT fetch_tbl(l_kff_flx.table_application_id,
                        l_kff_flx.application_table_name,
                        l_tbl,
                        x_message)) THEN
         GOTO return_error;
      END IF;

      IF (NOT fetch_col(l_tbl,
                        l_kff_seg.application_column_name,
                        l_col,
                        x_message)) THEN
         GOTO return_error;
      END IF;

      IF (l_col.flexfield_usage_code = 'K') THEN
         x_message := 'Segment column is properly registered. No need to fix.';
         GOTO return_error;
      END IF;

      IF (update_fnd_columns(l_col,
                             'K',
                             NULL, -- l_kff_flx.application_id,
                             NULL, -- l_kff_flx.id_flex_code,
                             x_message)) THEN
         GOTO return_success;
       ELSE
         GOTO return_error;
      END IF;
   END IF;

   IF (p_rule = 'C.07') THEN
      --
      -- Non-existing value set is used.
      --
      IF (l_kff_seg.flex_value_set_id IS NULL) THEN
         x_message := 'No value set is used in this segment. No need to fix.';
         GOTO return_error;
      END IF;

      IF (fetch_vst_set(l_kff_seg.flex_value_set_id,
                        l_vst_set,
                        x_message)) THEN
         x_message := 'Value set already exists. No need to fix.';
         GOTO return_error;
      END IF;

      BEGIN
         UPDATE fnd_id_flex_segments SET
           flex_value_set_id = NULL,
           last_update_date  = Sysdate,
           last_updated_by   = 1
           WHERE application_id = l_kff_seg.application_id
           AND id_flex_code = l_kff_seg.id_flex_code
           AND id_flex_num = l_kff_seg.id_flex_num
           AND application_column_name = l_kff_seg.application_column_name;
         x_message := SQL%rowcount || ' row(s) updated.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to update FND_ID_FLEX_SEGMENTS. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (p_rule = 'C.08') THEN
      --
      -- Problem in flags.
      --
      IF (NOT lookup_code_exists('FLEX_DEFAULT_TYPE',
                                 l_kff_seg.default_type)) THEN
         l_kff_seg.default_type := NULL;
      END IF;

      IF (NOT lookup_code_exists('RANGE_CODES',
                                 l_kff_seg.range_code)) THEN
         l_kff_seg.range_code := NULL;
      END IF;

      IF (NOT lookup_code_exists('YES_NO',
                                 l_kff_seg.application_column_index_flag)) THEN
         l_kff_seg.application_column_index_flag := 'N';
      END IF;

      IF (NOT lookup_code_exists('YES_NO',
                                 l_kff_seg.enabled_flag)) THEN
         l_kff_seg.enabled_flag := 'N';
      END IF;

      IF (NOT lookup_code_exists('YES_NO',
                                 l_kff_seg.required_flag)) THEN
         l_kff_seg.required_flag := 'N';
      END IF;

      IF (NOT lookup_code_exists('YES_NO',
                                 l_kff_seg.display_flag)) THEN
         l_kff_seg.display_flag := 'N';
      END IF;

      IF (NOT lookup_code_exists('YES_NO',
                                 l_kff_seg.security_enabled_flag)) THEN
         l_kff_seg.security_enabled_flag := 'N';
      END IF;

      BEGIN
         UPDATE fnd_id_flex_segments SET
           default_type                  = l_kff_seg.default_type,
           range_code                    = l_kff_seg.range_code,
           application_column_index_flag = l_kff_seg.application_column_index_flag,
           enabled_flag                  = l_kff_seg.enabled_flag,
           required_flag                 = l_kff_seg.required_flag,
           display_flag                  = l_kff_seg.display_flag,
           security_enabled_flag         = l_kff_seg.security_enabled_flag,
           last_update_date              = Sysdate,
           last_updated_by               = 1
           WHERE application_id = l_kff_seg.application_id
           AND id_flex_code = l_kff_seg.id_flex_code
           AND id_flex_num = l_kff_seg.id_flex_num
           AND application_column_name = l_kff_seg.application_column_name;
         x_message := SQL%rowcount || ' row(s) updated.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to update FND_ID_FLEX_SEGMENTS. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   <<return_success>>
   <<return_error>>
   RETURN;
EXCEPTION
   WHEN OTHERS THEN
      x_message := 'fix_kff_seg: Top level error: ' || Sqlerrm;
END fix_kff_seg;

-- ===========================================================================
PROCEDURE fix_kff_sha(p_rule                         IN VARCHAR2,
                      p_application_id               IN NUMBER,
                      p_id_flex_code                 IN VARCHAR2,
                      p_id_flex_num                  IN NUMBER,
                      p_alias_name                   IN VARCHAR2,
                      x_message                      OUT nocopy VARCHAR2)
  IS
     l_kff_flx    kff_flx_type;
     l_kff_str    kff_str_type;
     l_kff_sha    kff_sha_type;
BEGIN
   IF (p_rule = 'F.01') THEN
      --
      -- SHAs without Structure.
      --
      BEGIN
         DELETE
           FROM fnd_shorthand_flex_aliases sfa
           WHERE application_id = p_application_id
           AND id_flex_code = p_id_flex_code
           AND id_flex_num = p_id_flex_num
           AND alias_name = p_alias_name
           AND NOT EXISTS
           (SELECT null
            FROM fnd_id_flex_structures ifst
            WHERE ifst.application_id = sfa.application_id
            AND ifst.id_flex_code = sfa.id_flex_code
            AND ifst.id_flex_num = sfa.id_flex_num);
         x_message := SQL%rowcount || ' row(s) deleted.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to delete from FND_SHORTHAND_FLEX_ALIASES. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (NOT fetch_kff_flx(p_application_id,
                         p_id_flex_code,
                         l_kff_flx,
                         x_message)) THEN
      GOTO return_error;
   END IF;

   IF (NOT fetch_kff_str(l_kff_flx,
                         p_id_flex_num,
                         l_kff_str,
                         x_message)) THEN
      GOTO return_error;
   END IF;

   IF (NOT fetch_kff_sha(l_kff_str,
                         p_alias_name,
                         l_kff_sha,
                         x_message)) THEN
      GOTO return_error;
   END IF;

   IF (p_rule = 'F.02') THEN
      --
      -- Problems in flags.
      --
      IF (NOT lookup_code_exists('YES_NO',
                                 l_kff_sha.enabled_flag)) THEN
         l_kff_sha.enabled_flag := 'N';
      END IF;

      IF ((l_kff_sha.start_date_active IS NOT NULL) AND
          (l_kff_sha.end_date_active IS NOT NULL) AND
          (l_kff_sha.start_date_active > l_kff_sha.end_date_active)) THEN
         l_kff_sha.end_date_active := l_kff_sha.start_date_active;
      END IF;

      BEGIN
         UPDATE fnd_shorthand_flex_aliases SET
           enabled_flag                  = l_kff_sha.enabled_flag,
           start_date_active             = l_kff_sha.start_date_active,
           end_date_active               = l_kff_sha.end_date_active,
           last_update_date              = Sysdate,
           last_updated_by               = 1
           WHERE application_id = l_kff_sha.application_id
           AND id_flex_code = l_kff_sha.id_flex_code
           AND id_flex_num = l_kff_sha.id_flex_num
           AND alias_name = l_kff_sha.alias_name;
         x_message := SQL%rowcount || ' row(s) updated.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to update FND_SHORTHAND_FLEX_ALIASES. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   <<return_success>>
   <<return_error>>
   RETURN;
EXCEPTION
   WHEN OTHERS THEN
      x_message := 'fix_kff_sha: Top level error: ' || Sqlerrm;
END fix_kff_sha;

-- ===========================================================================
PROCEDURE fix_kff_cvr(p_rule                         IN VARCHAR2,
                      p_application_id               IN NUMBER,
                      p_id_flex_code                 IN VARCHAR2,
                      p_id_flex_num                  IN NUMBER,
                      p_flex_validation_rule_name    IN VARCHAR2,
                      x_message                      OUT nocopy VARCHAR2)
  IS
     l_kff_flx    kff_flx_type;
     l_kff_str    kff_str_type;
     l_kff_cvr    kff_cvr_type;
     l_kff_seg    kff_seg_type;
     l_count      NUMBER;
BEGIN
   IF (p_rule = 'G.03') THEN
      --
      -- CVRs without Structure.
      --
      BEGIN
         DELETE
           FROM fnd_flex_validation_rules fvr
           WHERE application_id = p_application_id
           AND id_flex_code = p_id_flex_code
           AND id_flex_num = p_id_flex_num
           AND flex_validation_rule_name = p_flex_validation_rule_name
           AND NOT EXISTS
           (SELECT null
            FROM fnd_id_flex_structures ifst
            WHERE ifst.application_id = fvr.application_id
            AND ifst.id_flex_code = fvr.id_flex_code
            AND ifst.id_flex_num = fvr.id_flex_num);
         x_message := SQL%rowcount || ' row(s) deleted.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to delete from FND_FLEX_VALIDATION_RULES. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (NOT fetch_kff_flx(p_application_id,
                         p_id_flex_code,
                         l_kff_flx,
                         x_message)) THEN
      GOTO return_error;
   END IF;

   IF (NOT fetch_kff_str(l_kff_flx,
                         p_id_flex_num,
                         l_kff_str,
                         x_message)) THEN
      GOTO return_error;
   END IF;

   IF (NOT fetch_kff_cvr(l_kff_str,
                         p_flex_validation_rule_name,
                         l_kff_cvr,
                         x_message)) THEN
      GOTO return_error;
   END IF;

   IF (p_rule = 'G.04') THEN
      --
      -- Non-existing error segment.
      --
      IF (l_kff_cvr.error_segment_column_name IS NULL) THEN
         x_message := 'No error segment is defined. No need to fix.';
         GOTO return_error;
      END IF;

      IF (fetch_kff_seg(l_kff_str,
                        l_kff_cvr.error_segment_column_name,
                        l_kff_seg,
                        x_message)) THEN
         x_message := 'Error segment exists. No need to fix.';
         GOTO return_error;
      END IF;

      BEGIN
         UPDATE fnd_flex_validation_rules SET
           error_segment_column_name = NULL,
           last_update_date          = Sysdate,
           last_updated_by           = 1
           WHERE application_id = p_application_id
           AND id_flex_code = p_id_flex_code
           AND id_flex_num = p_id_flex_num
           AND flex_validation_rule_name = p_flex_validation_rule_name;
         x_message := SQL%rowcount || ' row(s) updated.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message := 'Unable to update FND_FLEX_VALIDATION_RULES. ' ||
              Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (p_rule = 'G.05') THEN
      --
      -- Problem in flags.
      --
      IF (NOT lookup_code_exists('YES_NO',
                                 l_kff_cvr.enabled_flag)) THEN
         l_kff_cvr.enabled_flag := 'N';
      END IF;

      IF ((l_kff_cvr.start_date_active IS NOT NULL) AND
          (l_kff_cvr.end_date_active IS NOT NULL) AND
          (l_kff_cvr.start_date_active > l_kff_cvr.end_date_active)) THEN
         l_kff_cvr.end_date_active := l_kff_cvr.start_date_active;
      END IF;

      BEGIN
         UPDATE fnd_flex_validation_rules SET
           enabled_flag                  = l_kff_cvr.enabled_flag,
           start_date_active             = l_kff_cvr.start_date_active,
           end_date_active               = l_kff_cvr.end_date_active,
           last_update_date              = Sysdate,
           last_updated_by               = 1
           WHERE application_id = l_kff_cvr.application_id
           AND id_flex_code = l_kff_cvr.id_flex_code
           AND id_flex_num = l_kff_cvr.id_flex_num
           AND flex_validation_rule_name = l_kff_cvr.flex_validation_rule_name;
         x_message := SQL%rowcount || ' row(s) updated.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to update FND_FLEX_VALIDATION_RULES. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (p_rule = 'G.07') THEN
      --
      -- Rules without lines.
      --
      SELECT COUNT(*)
        INTO l_count
        FROM fnd_flex_validation_rule_lines
        WHERE application_id = l_kff_cvr.application_id
        AND id_flex_code = l_kff_cvr.id_flex_code
        AND id_flex_num = l_kff_cvr.id_flex_num
        AND flex_validation_rule_name = l_kff_cvr.flex_validation_rule_name;

      IF (l_count > 0) THEN
         x_message := 'There are ' || l_count || ' lines for this rule. ' ||
           'No need to fix.';
         GOTO return_error;
      END IF;

      IF (l_kff_cvr.enabled_flag = 'N') THEN
         x_message := 'This rule is already disabled. No need to fix.';
         GOTO return_error;
      END IF;


      BEGIN
         UPDATE fnd_flex_validation_rules SET
           enabled_flag      = 'N',
           last_update_date  = Sysdate,
           last_updated_by   = 1
           WHERE application_id = l_kff_cvr.application_id
           AND id_flex_code = l_kff_cvr.id_flex_code
           AND id_flex_num = l_kff_cvr.id_flex_num
           AND flex_validation_rule_name = l_kff_cvr.flex_validation_rule_name;
         x_message := SQL%rowcount || ' row(s) deleted.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to delete from FND_FLEX_VALIDATION_RULES. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   <<return_success>>
   <<return_error>>
   RETURN;
EXCEPTION
   WHEN OTHERS THEN
      x_message := 'fix_kff_cvr: Top level error: ' || Sqlerrm;
END fix_kff_cvr;
-- ===========================================================================
PROCEDURE fix_kff_cvl(p_rule                         IN VARCHAR2,
                      p_application_id               IN NUMBER,
                      p_id_flex_code                 IN VARCHAR2,
                      p_id_flex_num                  IN NUMBER,
                      p_flex_validation_rule_name    IN VARCHAR2,
                      p_rule_line_id                 IN NUMBER,
                      x_message                      OUT nocopy VARCHAR2)
  IS
     l_kff_flx    kff_flx_type;
     l_kff_str    kff_str_type;
     l_kff_cvr    kff_cvr_type;
     l_kff_cvl    kff_cvl_type;
     l_kff_cvi    kff_cvi_type;
     l_kff_cve    kff_cve_type;
BEGIN
   IF (p_rule = 'H.01') THEN
      --
      -- Lines without Rule.
      --
      BEGIN
         DELETE
           FROM fnd_flex_validation_rule_lines fvrl
           WHERE application_id = p_application_id
           AND id_flex_code = p_id_flex_code
           AND id_flex_num = p_id_flex_num
           AND flex_validation_rule_name = p_flex_validation_rule_name
           AND rule_line_id = p_rule_line_id
           AND NOT EXISTS
           (SELECT null
            FROM fnd_flex_validation_rules fvr
            WHERE fvr.application_id = fvrl.application_id
            AND fvr.id_flex_code = fvrl.id_flex_code
            AND fvr.id_flex_num = fvrl.id_flex_num
            AND fvr.flex_validation_rule_name =fvrl.flex_validation_rule_name);
         x_message := SQL%rowcount || ' row(s) deleted.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to delete from FND_FLEX_VALIDATION_RULE_LINES. ' ||
              Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (NOT fetch_kff_flx(p_application_id,
                         p_id_flex_code,
                         l_kff_flx,
                         x_message)) THEN
      GOTO return_error;
   END IF;

   IF (NOT fetch_kff_str(l_kff_flx,
                         p_id_flex_num,
                         l_kff_str,
                         x_message)) THEN
      GOTO return_error;
   END IF;

   IF (NOT fetch_kff_cvr(l_kff_str,
                         p_flex_validation_rule_name,
                         l_kff_cvr,
                         x_message)) THEN
      GOTO return_error;
   END IF;

   IF (p_rule LIKE 'H.%') THEN
      IF (NOT fetch_kff_cvl(l_kff_cvr,
                            p_rule_line_id,
                            l_kff_cvl,
                            x_message)) THEN
         GOTO return_error;
      END IF;
    ELSIF (p_rule LIKE 'I.%') THEN
      IF (NOT fetch_kff_cvi(l_kff_cvr,
                            p_rule_line_id,
                            l_kff_cvi,
                            x_message)) THEN
         GOTO return_error;
      END IF;
    ELSIF (p_rule LIKE 'J.%') THEN
      IF (NOT fetch_kff_cve(l_kff_cvr,
                            p_rule_line_id,
                            l_kff_cve,
                            x_message)) THEN
         GOTO return_error;
      END IF;
   END IF;

   IF (p_rule = 'H.02') THEN
      --
      -- Problems in flags.
      --
      IF (NOT lookup_code_exists('YES_NO',
                                 l_kff_cvl.enabled_flag)) THEN
         l_kff_cvl.enabled_flag := 'Y';
      END IF;

      IF (NOT lookup_code_exists('INCLUDE_EXCLUDE',
                                 l_kff_cvl.include_exclude_indicator)) THEN
         l_kff_cvl.include_exclude_indicator := 'I';
      END IF;

      BEGIN
         UPDATE fnd_flex_validation_rule_lines SET
           enabled_flag                  = l_kff_cvl.enabled_flag,
           include_exclude_indicator     = l_kff_cvl.include_exclude_indicator,
           last_update_date              = Sysdate,
           last_updated_by               = 1
           WHERE application_id = l_kff_cvl.application_id
           AND id_flex_code = l_kff_cvl.id_flex_code
           AND id_flex_num = l_kff_cvl.id_flex_num
           AND flex_validation_rule_name = l_kff_cvl.flex_validation_rule_name
           AND rule_line_id = l_kff_cvl.rule_line_id;
         x_message := SQL%rowcount || ' row(s) updated.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to update FND_FLEX_VALIDATION_RULE_LINES. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (p_rule = 'I.01') THEN
      --
      -- Include Lines without actual Line.
      --
      BEGIN
         DELETE FROM fnd_flex_include_rule_lines firl
           WHERE application_id = p_application_id
           AND id_flex_code = p_id_flex_code
           AND id_flex_num = p_id_flex_num
           AND flex_validation_rule_name = p_flex_validation_rule_name
           AND rule_line_id = p_rule_line_id
           AND NOT EXISTS
           (SELECT null
            FROM fnd_flex_validation_rule_lines fvrl
            WHERE firl.rule_line_id = fvrl.rule_line_id
            AND firl.enabled_flag = fvrl.enabled_flag
            AND fvrl.include_exclude_indicator = 'I');
         x_message := SQL%rowcount || ' row(s) deleted.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to delete from FND_FLEX_INCLUDE_RULE_LINES. ' ||
              Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (p_rule = 'J.01') THEN
      --
      -- Exclude Lines without actual Line.
      --
      BEGIN
         DELETE FROM fnd_flex_exclude_rule_lines ferl
           WHERE application_id = p_application_id
           AND id_flex_code = p_id_flex_code
           AND id_flex_num = p_id_flex_num
           AND flex_validation_rule_name = p_flex_validation_rule_name
           AND rule_line_id = p_rule_line_id
           AND NOT EXISTS
           (SELECT null
            FROM fnd_flex_validation_rule_lines fvrl
            WHERE ferl.rule_line_id = fvrl.rule_line_id
            AND ferl.enabled_flag = fvrl.enabled_flag
            AND fvrl.include_exclude_indicator = 'E');
         x_message := SQL%rowcount || ' row(s) deleted.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to delete from FND_FLEX_EXCLUDE_RULE_LINES. ' ||
              Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   <<return_success>>
   <<return_error>>
   RETURN;
EXCEPTION
   WHEN OTHERS THEN
      x_message := 'fix_kff_cvl: Top level error: ' || Sqlerrm;
END fix_kff_cvl;

-- ===========================================================================
PROCEDURE fix_kff_cvrls(p_rule                         IN VARCHAR2,
                        x_message                      OUT nocopy VARCHAR2)
  IS
     l_kff_flx   kff_flx_type;
     l_kff_str   kff_str_type;

     CURSOR kff_str_cur IS
        SELECT *
          FROM fnd_id_flex_structures
          ORDER BY application_id, id_flex_code, id_flex_num;
BEGIN

   IF (p_rule IN ('G.06', 'H.03')) THEN
      --
      -- CVR fix. Run after triggers are enabled.
      -- See $FND_TOP/sql/afffcvr1.sql and afffcvr2.sql
      --
      FOR kff_str_rec IN kff_str_cur LOOP

         IF (NOT fetch_kff_flx(kff_str_rec.application_id,
                               kff_str_rec.id_flex_code,
                               l_kff_flx,
                               x_message)) THEN
            GOTO return_error;
         END IF;

         IF (NOT fetch_kff_str(l_kff_flx,
                               kff_str_rec.id_flex_num,
                               l_kff_str,
                               x_message)) THEN
            GOTO return_error;
         END IF;

         IF (NOT populate_kff_cvrls(l_kff_str,
                                    x_message)) THEN
            GOTO return_error;
         END IF;
      END LOOP;
   END IF;

   <<return_success>>
   <<return_error>>
   RETURN;
EXCEPTION
   WHEN OTHERS THEN
      x_message := 'fix_kff_cvrls: Top level error: ' || Sqlerrm;
END fix_kff_cvrls;

-- ===========================================================================
PROCEDURE fix_kff_flq(p_rule                         IN VARCHAR2,
                      p_application_id               IN NUMBER,
                      p_id_flex_code                 IN VARCHAR2,
                      p_segment_attribute_type       IN VARCHAR2,
                      x_message                      OUT nocopy VARCHAR2)
  IS
     l_kff_flx    kff_flx_type;
     l_kff_flq    kff_flq_type;
BEGIN
   IF (p_rule = 'L.01') THEN
      --
      -- Flex Qualfiers without KFF.
      --
      BEGIN
         DELETE
           FROM fnd_segment_attribute_types sat
           WHERE application_id = p_application_id
           AND id_flex_code = p_id_flex_code
           AND segment_attribute_type = p_segment_attribute_type
           AND NOT EXISTS
           (SELECT null
            FROM fnd_id_flexs idf
            WHERE idf.application_id = sat.application_id
            AND idf.id_flex_code = sat.id_flex_code);
         x_message := SQL%rowcount || ' row(s) deleted.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to delete from FND_SEGMENT_ATTRIBUTE_TYPES. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (NOT fetch_kff_flx(p_application_id,
                         p_id_flex_code,
                         l_kff_flx,
                         x_message)) THEN
      GOTO return_error;
   END IF;

   IF (NOT fetch_kff_flq(l_kff_flx,
                         p_segment_attribute_type,
                         l_kff_flq,
                         x_message)) THEN
      GOTO return_error;
   END IF;

   IF (p_rule = 'L.02') THEN
      --
      -- Problems in flags.
      --
      IF (NOT lookup_code_exists('YES_NO',
                                 l_kff_flq.global_flag)) THEN
         l_kff_flq.global_flag := 'N';
      END IF;

      IF (NOT lookup_code_exists('YES_NO',
                                 l_kff_flq.required_flag)) THEN
         l_kff_flq.required_flag := 'N';
      END IF;

      IF (NOT lookup_code_exists('YES_NO',
                                 l_kff_flq.unique_flag)) THEN
         l_kff_flq.unique_flag := 'N';
      END IF;

      BEGIN
         UPDATE fnd_segment_attribute_types SET
           global_flag      = l_kff_flq.global_flag,
           required_flag    = l_kff_flq.required_flag,
           unique_flag      = l_kff_flq.unique_flag,
           last_update_date = Sysdate,
           last_updated_by  = 1
           WHERE application_id = l_kff_flq.application_id
           AND id_flex_code = l_kff_flq.id_flex_code
           AND segment_attribute_type = l_kff_flq.segment_attribute_type;
         x_message := SQL%rowcount || ' row(s) updated.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to update FND_SEGMENT_ATTRIBUTE_TYPES. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   <<return_success>>
   <<return_error>>
   RETURN;
EXCEPTION
   WHEN OTHERS THEN
      x_message := 'fix_kff_flq: Top level error: ' || Sqlerrm;
END fix_kff_flq;

-- ===========================================================================
PROCEDURE fix_kff_qlv(p_rule                         IN VARCHAR2,
                      p_application_id               IN NUMBER,
                      p_id_flex_code                 IN VARCHAR2,
                      p_id_flex_num                  IN NUMBER,
                      p_application_column_name      IN VARCHAR2,
                      p_segment_attribute_type       IN VARCHAR2,
                      x_message                      OUT nocopy VARCHAR2)
  IS
     l_kff_flx   kff_flx_type;
     l_kff_str   kff_str_type;
     l_kff_seg   kff_seg_type;
     l_kff_flq   kff_flq_type;
     l_kff_qlv   kff_qlv_type;
BEGIN
   IF (p_rule = 'M.01') THEN
      --
      -- Qualifier assignments without segments.
      --
      BEGIN
         DELETE
           FROM fnd_segment_attribute_values sav
           WHERE  application_id = p_application_id
           AND id_flex_code = p_id_flex_code
           AND id_flex_num = p_id_flex_num
           AND application_column_name = p_application_column_name
           AND segment_attribute_type = p_segment_attribute_type
           AND NOT EXISTS
           (SELECT null
            FROM fnd_id_flex_segments ifsg
            WHERE ifsg.application_id = sav.application_id
            AND ifsg.id_flex_code = sav.id_flex_code
            AND ifsg.id_flex_num = sav.id_flex_num
            AND ifsg.application_column_name = sav.application_column_name);
         x_message := SQL%rowcount || ' row(s) deleted.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to delete from FND_SEGMENT_ATTRIBUTE_VALUES. ' ||Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (p_rule = 'M.02') THEN
      --
      -- Qualifier assignments without qualifiers.
      --
      BEGIN
         DELETE
           FROM fnd_segment_attribute_values sav
           WHERE  application_id = p_application_id
           AND id_flex_code = p_id_flex_code
           AND id_flex_num = p_id_flex_num
           AND application_column_name = p_application_column_name
           AND segment_attribute_type = p_segment_attribute_type
           AND NOT EXISTS
           (SELECT null
            FROM fnd_segment_attribute_types sat
            WHERE sat.application_id = sav.application_id
            AND sat.id_flex_code = sav.id_flex_code
            AND sat.segment_attribute_type = sav.segment_attribute_type);
         x_message := SQL%rowcount || ' row(s) deleted.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to delete from FND_SEGMENT_ATTRIBUTE_VALUES. ' ||Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (NOT fetch_kff_flx(p_application_id,
                         p_id_flex_code,
                         l_kff_flx,
                         x_message)) THEN
      GOTO return_error;
   END IF;

   IF (NOT fetch_kff_str(l_kff_flx,
                         p_id_flex_num,
                         l_kff_str,
                         x_message)) THEN
      GOTO return_error;
   END IF;

   IF (NOT fetch_kff_seg(l_kff_str,
                         p_application_column_name,
                         l_kff_seg,
                         x_message)) THEN
      GOTO return_error;
   END IF;

   IF (NOT fetch_kff_flq(l_kff_flx,
                         p_segment_attribute_type,
                         l_kff_flq,
                         x_message)) THEN
      GOTO return_error;
   END IF;


   IF (p_rule = 'M.03') THEN
      --
      -- No assignments between Segments and Qualifiers.
      --
      IF (fetch_kff_qlv(l_kff_seg,
                        l_kff_flq,
                        l_kff_qlv,
                        x_message)) THEN
         x_message := 'Assignment exists. No need to fix.';
         GOTO return_error;
      END IF;

      BEGIN
         INSERT INTO fnd_segment_attribute_values
           (
            application_id,
            id_flex_code,
            id_flex_num,
            application_column_name,
            segment_attribute_type,
            attribute_value,

            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            last_update_login
            )
           VALUES
           (
            l_kff_seg.application_id,
            l_kff_seg.id_flex_code,
            l_kff_seg.id_flex_num,
            l_kff_seg.application_column_name,
            l_kff_flq.segment_attribute_type,
            l_kff_flq.global_flag,

            1,
            Sysdate,
            1,
            Sysdate,
            0);
         x_message := SQL%rowcount || ' row(s) inserted.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to insert into FND_SEGMENT_ATTRIBUTE_VALUES. ' ||Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (NOT fetch_kff_qlv(l_kff_seg,
                         l_kff_flq,
                         l_kff_qlv,
                         x_message)) THEN
      GOTO return_error;
   END IF;

   IF (p_rule = 'M.04') THEN
      --
      -- Problems in flags.
      --
      IF (NOT lookup_code_exists('YES_NO',
                                 l_kff_qlv.attribute_value)) THEN
         l_kff_qlv.attribute_value := l_kff_flq.global_flag;
      END IF;

      BEGIN
         UPDATE fnd_segment_attribute_values SET
           attribute_value  = l_kff_qlv.attribute_value,
           last_update_date = Sysdate,
           last_updated_by  = 1
           WHERE application_id = l_kff_qlv.application_id
           AND id_flex_code = l_kff_qlv.id_flex_code
           AND id_flex_num = l_kff_qlv.id_flex_num
           AND application_column_name = l_kff_qlv.application_column_name
           AND segment_attribute_type = l_kff_qlv.segment_attribute_type;
         x_message := SQL%rowcount || ' row(s) updated.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to update FND_SEGMENT_ATTRIBUTE_VALUES. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   <<return_success>>
   <<return_error>>
   RETURN;
EXCEPTION
   WHEN OTHERS THEN
      x_message := 'fix_kff_qlv: Top level error: ' || Sqlerrm;
END fix_kff_qlv;
-- ===========================================================================
PROCEDURE fix_kff_sgq(p_rule                         IN VARCHAR2,
                      p_application_id               IN NUMBER,
                      p_id_flex_code                 IN VARCHAR2,
                      p_segment_attribute_type       IN VARCHAR2,
                      p_value_attribute_type         IN VARCHAR2,
                      x_message                      OUT nocopy VARCHAR2)
  IS
     l_tbl        tbl_type;
     l_col        col_type;
     l_kff_flx    kff_flx_type;
     l_kff_flq    kff_flq_type;
     l_kff_sgq    kff_sgq_type;
     l_dummy      VARCHAR2(100);
BEGIN
   IF (p_rule = 'N.03') THEN
      --
      -- Segment Qualifiers without Flexfield Qualifier.
      --
      BEGIN
         DELETE
           FROM fnd_value_attribute_types vat
           WHERE application_id = p_application_id
           AND id_flex_code = p_id_flex_code
           AND segment_attribute_type = p_segment_attribute_type
           AND value_attribute_type = p_value_attribute_type
           AND NOT EXISTS
           (SELECT null
            FROM fnd_segment_attribute_types sat
            WHERE sat.application_id = vat.application_id
            AND sat.id_flex_code = vat.id_flex_code
            AND sat.segment_attribute_type = vat.segment_attribute_type);
         x_message := SQL%rowcount || ' row(s) deleted.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to delete from FND_VALUE_ATTRIBUTE_TYPES. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (NOT fetch_kff_flx(p_application_id,
                         p_id_flex_code,
                         l_kff_flx,
                         x_message)) THEN
      GOTO return_error;
   END IF;

   IF (NOT fetch_kff_flq(l_kff_flx,
                         p_segment_attribute_type,
                         l_kff_flq,
                         x_message)) THEN
      GOTO return_error;
   END IF;

   IF (NOT fetch_kff_sgq(l_kff_flq,
                         p_value_attribute_type,
                         l_kff_sgq,
                         x_message)) THEN
      GOTO return_error;
   END IF;

   IF (p_rule = 'N.06') THEN
      --
      -- Qualifier column is not registered properly.
      --
      IF (NOT fetch_tbl(l_kff_flx.table_application_id,
                        l_kff_flx.application_table_name,
                        l_tbl,
                        x_message)) THEN
         GOTO return_error;
      END IF;

      IF (NOT fetch_col(l_tbl,
                        l_kff_sgq.application_column_name,
                        l_col,
                        x_message)) THEN
         GOTO return_error;
      END IF;

      IF (l_col.flexfield_usage_code = 'Q') THEN
         x_message := 'Qualifier column is properly registered. No need to fix.';
         GOTO return_error;
      END IF;

      IF (update_fnd_columns(l_col,
                             'Q',
                             NULL, -- l_kff_flx.application_id,
                             NULL, -- l_kff_flx.id_flex_code,
                             x_message)) THEN
         GOTO return_success;
       ELSE
         GOTO return_error;
      END IF;
   END IF;

   IF (p_rule = 'N.07') THEN
      --
      -- Problem in flags.
      --
      IF (NOT lookup_code_exists('YES_NO',
                                 l_kff_sgq.required_flag)) THEN
         l_kff_sgq.required_flag := 'Y';
      END IF;

      BEGIN
         UPDATE fnd_value_attribute_types SET
           required_flag    = l_kff_sgq.required_flag,
           last_update_date = Sysdate,
           last_updated_by  = 1
           WHERE application_id = l_kff_sgq.application_id
           AND id_flex_code = l_kff_sgq.id_flex_code
           AND segment_attribute_type = l_kff_sgq.segment_attribute_type
           AND value_attribute_type = l_kff_sgq.value_attribute_type;
         x_message := SQL%rowcount || ' row(s) updated.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to update FND_VALUE_ATTRIBUTE_TYPES. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   <<return_success>>
   <<return_error>>
   RETURN;
EXCEPTION
   WHEN OTHERS THEN
      x_message := 'fix_kff_sgq: Top level error: ' || Sqlerrm;
END fix_kff_sgq;

-- ===========================================================================
PROCEDURE fix_kff_fvq(p_rule                         IN VARCHAR2,
                      p_id_flex_application_id       IN NUMBER,
                      p_id_flex_code                 IN VARCHAR2,
                      p_segment_attribute_type       IN VARCHAR2,
                      p_value_attribute_type         IN VARCHAR2,
                      p_flex_value_set_id            IN NUMBER,
                      x_message                      OUT nocopy VARCHAR2)
  IS
BEGIN
   IF (p_rule = 'O.01') THEN
      --
      -- Validation Qualifiers without Segment qualifier.
      --
      BEGIN
         DELETE
           FROM fnd_flex_validation_qualifiers fvq
           WHERE id_flex_application_id = p_id_flex_application_id
           AND id_flex_code = p_id_flex_code
           AND segment_attribute_type = p_segment_attribute_type
           AND value_attribute_type = p_value_attribute_type
           AND flex_value_set_id = p_flex_value_set_id
           AND NOT EXISTS
           (SELECT null
            FROM fnd_value_attribute_types vat
            WHERE vat.application_id = fvq.id_flex_application_id
            AND vat.id_flex_code = fvq.id_flex_code
            AND vat.segment_attribute_type = fvq.segment_attribute_type
            AND vat.value_attribute_type = fvq.value_attribute_type);
         x_message := SQL%rowcount || ' row(s) deleted.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to delete from FND_FLEX_VALIDATION_QUALIFIERS. ' ||
              Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (p_rule = 'O.02') THEN
      --
      -- Validation Qualifiers without Value sets.
      --
      BEGIN
         DELETE
           FROM fnd_flex_validation_qualifiers fvq
           WHERE id_flex_application_id = p_id_flex_application_id
           AND id_flex_code = p_id_flex_code
           AND segment_attribute_type = p_segment_attribute_type
           AND value_attribute_type = p_value_attribute_type
           AND flex_value_set_id = p_flex_value_set_id
           AND NOT EXISTS
           (SELECT null
            FROM fnd_flex_value_sets fvs
            WHERE fvs.flex_value_set_id = fvq.flex_value_set_id);
         x_message := SQL%rowcount || ' row(s) deleted.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to delete from FND_FLEX_VALIDATION_QUALIFIERS. ' ||
              Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   <<return_success>>
   <<return_error>>
   RETURN;
EXCEPTION
   WHEN OTHERS THEN
      x_message := 'fix_kff_fvq: Top level error: ' || Sqlerrm;
END fix_kff_fvq;

-- ===========================================================================
PROCEDURE fix_kff_col(p_rule                         IN VARCHAR2,
                      p_application_id               IN NUMBER,
                      p_table_name                   IN VARCHAR2,
                      p_column_name                  IN VARCHAR2,
                      x_message                      OUT nocopy VARCHAR2)
  IS
     l_tbl      tbl_type;
     l_col      col_type;
     l_kff_flx  kff_flx_type;
     l_kff_sgq  kff_sgq_type;
BEGIN
   IF (NOT fetch_tbl(p_application_id,
                     p_table_name,
                     l_tbl,
                     x_message)) THEN
      GOTO return_error;
   END IF;

   IF (NOT fetch_col(l_tbl,
                     p_column_name,
                     l_col,
                     x_message)) THEN
      GOTO return_error;
   END IF;

   IF (p_rule = 'P.01') THEN
      --
      -- 'I' columns.
      --
      IF (l_col.flexfield_usage_code <> 'I') THEN
         x_message := 'This is not a ''I'' column.';
         GOTO return_error;
      END IF;

      BEGIN
         SELECT *
           INTO l_kff_flx
           FROM fnd_id_flexs
           WHERE table_application_id = l_tbl.application_id
           AND application_table_name = l_tbl.table_name
           AND unique_id_column_name = l_col.column_name;
         x_message := ('This column is used by ' ||
                       To_char(l_kff_flx.application_id) || '/' ||
                       l_kff_flx.id_flex_code ||
                       '. No need to fix.');
         GOTO return_error;
      EXCEPTION
         WHEN no_data_found THEN
            NULL;
         WHEN OTHERS THEN
            x_message := 'Unable to select from FND_ID_FLEXS. ' || Sqlerrm;
            GOTO return_error;
      END;

      IF (update_fnd_columns(l_col, 'N', NULL, NULL, x_message)) THEN
         GOTO return_success;
       ELSE
         GOTO return_error;
      END IF;
   END IF;

   IF (p_rule = 'P.02') THEN
      --
      -- 'S' columns.
      --
      IF (l_col.flexfield_usage_code <> 'S') THEN
         x_message := 'This is not a ''S'' column.';
         GOTO return_error;
      END IF;

      BEGIN
         SELECT *
           INTO l_kff_flx
           FROM fnd_id_flexs
           WHERE table_application_id = l_tbl.application_id
           AND application_table_name = l_tbl.table_name
           AND set_defining_column_name = l_col.column_name;
         x_message := ('This column is used by ' ||
                       To_char(l_kff_flx.application_id) || '/' ||
                       l_kff_flx.id_flex_code ||
                       '. No need to fix.');
         GOTO return_error;
      EXCEPTION
         WHEN no_data_found THEN
            NULL;
         WHEN OTHERS THEN
            x_message := 'Unable to select from FND_ID_FLEXS. ' || Sqlerrm;
            GOTO return_error;
      END;

      IF (update_fnd_columns(l_col, 'N', NULL, NULL, x_message)) THEN
         GOTO return_success;
       ELSE
         GOTO return_error;
      END IF;
   END IF;

   IF (p_rule = 'P.03') THEN
      --
      -- 'K' columns.
      --
      IF (l_col.flexfield_usage_code <> 'K') THEN
         x_message := 'This is not a ''K'' column.';
         GOTO return_error;
      END IF;

      BEGIN
         SELECT *
           INTO l_kff_flx
           FROM fnd_id_flexs
           WHERE table_application_id = l_tbl.application_id
           AND application_table_name = l_tbl.table_name;
         x_message := ('This column is possibly used by ' ||
                       To_char(l_kff_flx.application_id) || '/' ||
                       l_kff_flx.id_flex_code ||
                       '. No need to fix.');
         GOTO return_error;
      EXCEPTION
         WHEN no_data_found THEN
            NULL;
         WHEN OTHERS THEN
            x_message := 'Unable to select from FND_ID_FLEXS. ' || Sqlerrm;
            GOTO return_error;
      END;

      IF (update_fnd_columns(l_col, 'N', NULL, NULL, x_message)) THEN
         GOTO return_success;
       ELSE
         GOTO return_error;
      END IF;
   END IF;

   IF (p_rule = 'P.04') THEN
      --
      -- 'Q' columns.
      --
      IF (l_col.flexfield_usage_code <> 'Q') THEN
         x_message := 'This is not a ''Q'' column.';
         GOTO return_error;
      END IF;

      BEGIN
         SELECT *
           INTO l_kff_flx
           FROM fnd_id_flexs
           WHERE table_application_id = l_tbl.application_id
           AND application_table_name = l_tbl.table_name;
         BEGIN
            SELECT *
              INTO l_kff_sgq
              FROM fnd_value_attribute_types
              WHERE application_id = l_kff_flx.application_id
              AND id_flex_code = l_kff_flx.id_flex_code
              AND application_column_name = l_col.column_name;
            x_message := ('This column is used by ' ||
                          To_char(l_kff_flx.application_id) || '/' ||
                          l_kff_flx.id_flex_code || '/' ||
                          l_kff_sgq.segment_attribute_type || '/' ||
                          l_kff_sgq.value_attribute_type ||
                          '. No need to fix.');
            GOTO return_error;
         EXCEPTION
            WHEN no_data_found THEN
               NULL;
            WHEN OTHERS THEN
               x_message :=
                 'Unable to select from FND_VALUE_ATTRIBUTE_TYPES. ' ||
                 Sqlerrm;
               GOTO return_error;
         END;
      EXCEPTION
         WHEN no_data_found THEN
            NULL;
         WHEN OTHERS THEN
            x_message := 'Unable to select from FND_ID_FLEXS. ' || Sqlerrm;
            GOTO return_error;
      END;

      IF (update_fnd_columns(l_col, 'N', NULL, NULL, x_message)) THEN
         GOTO return_success;
       ELSE
         GOTO return_error;
      END IF;
   END IF;

   <<return_success>>
   <<return_error>>
   RETURN;
EXCEPTION
   WHEN OTHERS THEN
      x_message := 'fix_kff_col: Top level error: ' || Sqlerrm;
END fix_kff_col;

-- ===========================================================================
PROCEDURE fix_kff_fwp(p_rule                         IN VARCHAR2,
                      p_application_id               IN NUMBER,
                      p_id_flex_code                 IN VARCHAR2,
                      p_id_flex_num                  IN NUMBER,
                      p_wf_item_type                 IN VARCHAR2,
                      x_message                      OUT nocopy VARCHAR2)
  IS
BEGIN
   IF (p_rule = 'R.01') THEN
      --
      -- FWPs without Structure.
      --
      BEGIN
         DELETE
           FROM fnd_flex_workflow_processes fwp
           WHERE application_id = p_application_id
           AND id_flex_code = p_id_flex_code
           AND id_flex_num = p_id_flex_num
           AND wf_item_type = p_wf_item_type
           AND NOT EXISTS
           (SELECT null
            FROM fnd_id_flex_structures ifst
            WHERE ifst.application_id = fwp.application_id
            AND ifst.id_flex_code = fwp.id_flex_code
            AND ifst.id_flex_num = fwp.id_flex_num);
         x_message := SQL%rowcount || ' row(s) deleted.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to delete from FND_FLEX_WORKFLOW_PROCESSES. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   IF (p_rule = 'R.02') THEN
      --
      -- FWPs without WF Items.
      --
      BEGIN
         DELETE
           FROM fnd_flex_workflow_processes fwp
           WHERE application_id = p_application_id
           AND id_flex_code = p_id_flex_code
           AND id_flex_num = p_id_flex_num
           AND wf_item_type = p_wf_item_type
           AND NOT exists
           (SELECT null
            FROM wf_item_types wit
            WHERE wit.name = fwp.wf_item_type);
         x_message := SQL%rowcount || ' row(s) deleted.';
         GOTO return_success;
      EXCEPTION
         WHEN OTHERS THEN
            x_message :=
              'Unable to delete from FND_FLEX_WORKFLOW_PROCESSES. ' || Sqlerrm;
            GOTO return_error;
      END;
   END IF;

   <<return_success>>
   <<return_error>>
   RETURN;
EXCEPTION
   WHEN OTHERS THEN
      x_message := 'fix_kff_fwp: Top level error: ' || Sqlerrm;
END fix_kff_fwp;

BEGIN
   g_newline := fnd_global.newline;
END fnd_flex_diagnose;

/
