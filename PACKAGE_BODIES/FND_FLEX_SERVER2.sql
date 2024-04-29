--------------------------------------------------------
--  DDL for Package Body FND_FLEX_SERVER2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FLEX_SERVER2" AS
/* $Header: AFFFSV2B.pls 120.2.12010000.14 2017/02/10 21:01:55 hgeorgi ship $ */

g_line_size       NUMBER := 240;  /* Maximum line size.                    */
g_indent          NUMBER := 1;    /* Indentation in Log File.              */
g_numof_errors    NUMBER := 0;    /* Number of errors.                     */
chr_newline       VARCHAR2(8) := fnd_global.newline;

  ---------------
  -- NOTES
  --

  --------
  -- PRIVATE TYPES
  --

  ------------
  -- PRIVATE CONSTANTS
  --

--  Cross-validation rule caching and optimization
--
  CACHE_DELIMITER       VARCHAR2(10); -- := fnd_global.local_chr(0);

-- This should be moved back to key validation engine when it is broken
-- up.  For now it is a duplicate of the definition in FND_FLEX_SERVER.
--
  MAX_NSEGS             CONSTANT NUMBER := 30;

  cvrule_clause_begin         CONSTANT VARCHAR2(2000) :=
    'select R.FLEX_VALIDATION_RULE_NAME ' ||
    '  from FND_FLEX_VALIDATION_RULES R ';

  cvrule_clause_exclude_begin CONSTANT VARCHAR2(2000) :=
    ', FND_FLEX_EXCLUDE_RULE_LINES L ';

  cvrule_clause_where         CONSTANT VARCHAR2(2000) :=
    ' where R.ENABLED_FLAG = ''Y'' ' ||
    '   and (   (:VDATE is null) ' ||
    '        or (    (   R.START_DATE_ACTIVE is null ' ||
    '                 or R.START_DATE_ACTIVE <= :VDATE) ' ||
    '            and (   R.END_DATE_ACTIVE is null ' ||
    '                 or R.END_DATE_ACTIVE >= :VDATE))) ' ||
    '   and R.APPLICATION_ID = :APID ' ||
    '   and R.ID_FLEX_CODE = :CODE ' ||
    '   and R.ID_FLEX_NUM = :NUM ';

  cvrule_clause_exclude_mid   CONSTANT VARCHAR2(2000) :=
    'and R.FLEX_VALIDATION_RULE_NAME = L.FLEX_VALIDATION_RULE_NAME ';

  cvrule_clause_include_mid   CONSTANT VARCHAR2(2000) :=
    'MINUS select L.FLEX_VALIDATION_RULE_NAME ' ||
    '        from FND_FLEX_INCLUDE_RULE_LINES L ' ||
    '       where 1 = 1 ';

  cvrule_clause_end           CONSTANT VARCHAR2(2000) :=
    'and L.APPLICATION_ID = :APID ' ||
    'and L.ID_FLEX_CODE = :CODE ' ||
    'and L.ID_FLEX_NUM = :NUM ' ||
    'and L.ENABLED_FLAG = ''Y'' ';

  DATE_PASS_FORMAT CONSTANT VARCHAR2(1) := 'J';


  -------------
  -- EXCEPTIONS
  --


/* -------------------------------------------------------------------- */
/*                        Private global variables                      */
/* -------------------------------------------------------------------- */
  -- ==================================================
  -- CACHING
  -- ==================================================

  g_cache_return_code  VARCHAR2(30);
  g_cache_key          VARCHAR2(2000);
  g_cache_value        fnd_plsql_cache.generic_cache_value_type;
  g_cache_values       fnd_plsql_cache.generic_cache_values_type;
  g_cache_numof_values NUMBER;

  -- --------------------------------------------------
  -- gks : Get KeyStruct Cache.
  -- --------------------------------------------------
  gks_cache_controller      fnd_plsql_cache.cache_1to1_controller_type;
  gks_cache_storage         fnd_plsql_cache.generic_cache_values_type;

  -- --------------------------------------------------
  -- gds : Get DescStruct Cache.
  -- --------------------------------------------------
  gds_cache_controller      fnd_plsql_cache.cache_1to1_controller_type;
  gds_cache_storage         fnd_plsql_cache.generic_cache_values_type;

  -- --------------------------------------------------
  -- xvc : Cross validated combinations
  -- --------------------------------------------------
  xvc_cache_controller      fnd_plsql_cache.cache_1to1_controller_type;
  xvc_cache_storage         fnd_plsql_cache.generic_cache_values_type;

  -- --------------------------------------------------
  -- coc : Columns cache
  -- --------------------------------------------------
  coc_cache_controller      fnd_plsql_cache.cache_1tom_controller_type;
  coc_cache_storage         fnd_plsql_cache.generic_cache_values_type;

  -- --------------------------------------------------
  -- gas : Get All SegQuals Cache
  -- --------------------------------------------------
  gas_cache_controller      fnd_plsql_cache.cache_1tom_controller_type;
  gas_cache_storage         fnd_plsql_cache.generic_cache_values_type;

  -- --------------------------------------------------
  -- gqs : Get QualSegs Cache
  -- --------------------------------------------------
  gqs_cache_controller      fnd_plsql_cache.cache_1tom_controller_type;
  gqs_cache_storage         fnd_plsql_cache.generic_cache_values_type;

/* -------------------------------------------------------------------- */
/*                        Private definitions                           */
/* -------------------------------------------------------------------- */

  FUNCTION cv_rule_violated(nsegs     IN NUMBER,
                            segs      IN FND_FLEX_SERVER1.StringArray,
                            segfmt    IN FND_FLEX_SERVER1.SegFormats,
                            fstruct   IN FND_FLEX_SERVER1.FlexStructId,
                            inex      IN VARCHAR2,
                            v_date    IN DATE,
                            rule_name OUT nocopy VARCHAR2) RETURN BOOLEAN;

  /* Bug 21612876, This is a copy of cv_rule_violated() function but added more
     parameters for more specific processing for the CVR report. */
  FUNCTION cv_rule_violated_report(nsegs     IN NUMBER,
                                   segs      IN FND_FLEX_SERVER1.StringArray,
                                   segfmt    IN FND_FLEX_SERVER1.SegFormats,
                                   fstruct   IN FND_FLEX_SERVER1.FlexStructId,
                                   inex      IN VARCHAR2,
                                   v_date    IN DATE,
                                   cvr_low   IN VARCHAR2,
                                   cvr_high  IN VARCHAR2,
                                   rule_name OUT nocopy VARCHAR2) RETURN BOOLEAN;

  FUNCTION x_cv_rule_select(fstruct   IN  FND_FLEX_SERVER1.FlexStructId,
                            v_date    IN  DATE,
                            bad_rule  OUT nocopy VARCHAR2) RETURN NUMBER;

  /* Bug 21612876, This is a copy of x_cv_rule_select() function but added more
     parameters for more specific processing for the CVR report. */
  FUNCTION x_cv_rule_select_report(fstruct   IN  FND_FLEX_SERVER1.FlexStructId,
                                   v_date    IN  DATE,
                                   cvr_low   IN VARCHAR2,
                                   cvr_high  IN VARCHAR2,
                                   bad_rule  OUT nocopy VARCHAR2) RETURN NUMBER;

  FUNCTION x_xvc_check_cache(fstruct       IN  FND_FLEX_SERVER1.FlexStructId,
                             v_date        IN  DATE,
                             p_cat_segs    IN VARCHAR2,
                             in_cache      OUT nocopy BOOLEAN,
                             is_violated   OUT nocopy BOOLEAN,
                             rule_name     OUT nocopy VARCHAR2) RETURN BOOLEAN;

  FUNCTION x_xvc_update_cache(fstruct       IN  FND_FLEX_SERVER1.FlexStructId,
                              v_date        IN  DATE,
                              p_cat_segs    IN VARCHAR2,
                              is_violated   IN  BOOLEAN,
                              rule_name     IN  VARCHAR2) RETURN BOOLEAN;

/* ----------------------------------------------------------------------- */
/*                      Private Functions                                  */
/* ----------------------------------------------------------------------- */

/* ----------------------------------------------------------------------- */
/*      Gets flexfield and structure header information for key flexfieds. */
/*      Returns FALSE and sets error message on error.                     */
/* ----------------------------------------------------------------------- */
  FUNCTION get_keystruct(appl_sname   IN  VARCHAR2,
                         flex_code    IN  VARCHAR2,
                         select_comb_from_view IN VARCHAR2,
                         flex_num     IN  NUMBER,
                         flex_struct  OUT nocopy FND_FLEX_SERVER1.FlexStructId,
                         struct_info  OUT nocopy FND_FLEX_SERVER1.FlexStructInfo,
                         cctbl_info   OUT nocopy FND_FLEX_SERVER1.CombTblInfo)
    RETURN BOOLEAN
    IS
  BEGIN
--  Get all required info about the desired flexfield structure.
--  Note exceptions handle the case that the structure not found or not unique.
--
     g_cache_key := (appl_sname || '.' || flex_code || '.' ||
                     flex_num || '.' || select_comb_from_view);
     fnd_plsql_cache.generic_1to1_get_value(gks_cache_controller,
                                            gks_cache_storage,
                                            g_cache_key,
                                            g_cache_value,
                                            g_cache_return_code);
     IF (g_cache_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
        NULL;
      ELSE
        SELECT
          f.application_id,            f.table_application_id,
          t.table_id,                  f.application_table_name,
          Nvl(select_comb_from_view, f.application_table_name),
          f.application_table_type,    f.unique_id_column_name,
          f.set_defining_column_name,  f.dynamic_inserts_feasible_flag,
          f.maximum_concatenation_len, f.concatenation_len_warning
          INTO
          g_cache_value.number_1,   g_cache_value.number_2,
          g_cache_value.number_3,   g_cache_value.varchar2_1,
          g_cache_value.varchar2_2,
          g_cache_value.varchar2_3, g_cache_value.varchar2_4,
          g_cache_value.varchar2_5, g_cache_value.varchar2_6,
          g_cache_value.number_4,   g_cache_value.varchar2_7
          FROM fnd_id_flexs f, fnd_tables t, fnd_application a
          WHERE f.id_flex_code = flex_code
          AND f.application_id = a.application_id
          AND a.application_short_name = appl_sname
          AND t.application_id = f.table_application_id
          AND t.table_name = f.application_table_name;

        --      NOTE:  Should select from structures _VL table if selecting on
        --             structure name.
        SELECT
          enabled_flag, concatenated_segment_delimiter,
          cross_segment_validation_flag, dynamic_inserts_allowed_flag
          INTO
          g_cache_value.varchar2_8,
          g_cache_value.varchar2_9,
          g_cache_value.varchar2_10,
          g_cache_value.varchar2_11
          FROM fnd_id_flex_structures
          WHERE application_id = g_cache_value.number_1
          AND id_flex_code = flex_code
          AND id_flex_num = flex_num;

        fnd_plsql_cache.generic_1to1_put_value(gks_cache_controller,
                                               gks_cache_storage,
                                               g_cache_key,
                                               g_cache_value);
     END IF;

     flex_struct.isa_key_flexfield := TRUE;
     flex_struct.application_id := g_cache_value.number_1;
     flex_struct.id_flex_code := flex_code;
     flex_struct.id_flex_num := flex_num;

     cctbl_info.table_application_id := g_cache_value.number_2;
     cctbl_info.combination_table_id := g_cache_value.number_3;
     cctbl_info.application_table_name := g_cache_value.varchar2_1;
     cctbl_info.select_comb_from := g_cache_value.varchar2_2;
     cctbl_info.application_table_type :=  g_cache_value.varchar2_3;
     cctbl_info.unique_id_column_name := g_cache_value.varchar2_4;
     cctbl_info.set_defining_column_name :=  g_cache_value.varchar2_5;

     struct_info.dynamic_inserts_feasible_flag := g_cache_value.varchar2_6;
     struct_info.maximum_concatenation_len := g_cache_value.number_4;
     struct_info.concatenation_len_warning := g_cache_value.varchar2_7;

     struct_info.enabled_flag := g_cache_value.varchar2_8;
     struct_info.concatenated_segment_delimiter := g_cache_value.varchar2_9;
     struct_info.cross_segment_validation_flag := g_cache_value.varchar2_10;
     struct_info.dynamic_inserts_allowed_flag := g_cache_value.varchar2_11;

     return(TRUE);

  EXCEPTION
    WHEN NO_DATA_FOUND then
      FND_MESSAGE.set_name('FND', 'FLEX-CANNOT FIND STRUCT DEF');
      FND_MESSAGE.set_token('ROUTINE', 'SV2.GET_KEYSTRUCT');
      FND_MESSAGE.set_token('APPL', appl_sname);
      FND_MESSAGE.set_token('CODE', flex_code);
      FND_MESSAGE.set_token('NUM', to_char(flex_num));
      return(FALSE);
    WHEN TOO_MANY_ROWS then
      FND_MESSAGE.set_name('FND', 'FLEX-DUPLICATE STRUCT DEF');
      FND_MESSAGE.set_token('ROUTINE', 'SV2.GET_KEYSTRUCT');
      FND_MESSAGE.set_token('APPL', appl_sname);
      FND_MESSAGE.set_token('CODE', flex_code);
      FND_MESSAGE.set_token('NUM', to_char(flex_num));
      return(FALSE);
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG', 'SV2.get_keystruct() exception:  ' || SQLERRM);
      return(FALSE);

  END get_keystruct;

/* ----------------------------------------------------------------------- */
/*      Function to get descriptive flexfield information.                 */
/*      Returns TRUE and DescFlexInfo on success or FALSE and sets         */
/*      FND_MESSAGE to error name if not found or error.                   */
/* ----------------------------------------------------------------------- */

  FUNCTION get_descstruct(flex_app_sname  IN  VARCHAR2,
                          desc_flex_name  IN  VARCHAR2,
                          dfinfo          OUT nocopy FND_FLEX_SERVER1.DescFlexInfo)
    RETURN BOOLEAN
    IS
  BEGIN
     g_cache_key := flex_app_sname || '.' || desc_flex_name;
     fnd_plsql_cache.generic_1to1_get_value(gds_cache_controller,
                                            gds_cache_storage,
                                            g_cache_key,
                                            g_cache_value,
                                            g_cache_return_code);

     IF (g_cache_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
        NULL;
      ELSE
        SELECT
          df.application_id,             df.descriptive_flexfield_name,
          df.description,                df.table_application_id,
          df.application_table_name,     t.table_id,
          df.context_required_flag,      df.context_column_name,
          df.context_user_override_flag, df.concatenated_segment_delimiter,
          df.protected_flag,             df.default_context_value,
          df.default_context_field_name, df.context_override_value_set_id,
          df.context_default_type,       df.context_default_value,
          df.context_runtime_property_funct
          INTO
          g_cache_value.number_1,            g_cache_value.varchar2_1,
          g_cache_value.varchar2_2,          g_cache_value.number_2,
          g_cache_value.varchar2_3,          g_cache_value.number_3,
          g_cache_value.varchar2_4,          g_cache_value.varchar2_5,
          g_cache_value.varchar2_6,          g_cache_value.varchar2_7,
          g_cache_value.varchar2_8,          g_cache_value.varchar2_9,
          g_cache_value.varchar2_10,         g_cache_value.number_4,
          g_cache_value.varchar2_11,         g_cache_value.varchar2_12,
          g_cache_value.varchar2_13
          FROM fnd_tables t, fnd_descriptive_flexs_vl df, fnd_application a
          WHERE a.application_short_name = flex_app_sname
          AND df.application_id = a.application_id
          AND df.descriptive_flexfield_name = desc_flex_name
          AND t.application_id = df.table_application_id
          AND t.table_name = df.application_table_name;

        fnd_plsql_cache.generic_1to1_put_value(gds_cache_controller,
                                               gds_cache_storage,
                                               g_cache_key,
                                               g_cache_value);
     END IF;

     dfinfo.application_id                 := g_cache_value.number_1;
     dfinfo.name                           := g_cache_value.varchar2_1;
     dfinfo.description                    := g_cache_value.varchar2_2;
     dfinfo.table_appl_id                  := g_cache_value.number_2;
     dfinfo.table_name                     := g_cache_value.varchar2_3;
     dfinfo.table_id                       := g_cache_value.number_3;
     dfinfo.context_required               := g_cache_value.varchar2_4;
     dfinfo.context_column                 := g_cache_value.varchar2_5;
     dfinfo.context_override               := g_cache_value.varchar2_6;
     dfinfo.segment_delimiter              := g_cache_value.varchar2_7;
     dfinfo.protected_flag                 := g_cache_value.varchar2_8;
     dfinfo.default_context                := g_cache_value.varchar2_9;
     dfinfo.reference_field                := g_cache_value.varchar2_10;
     dfinfo.context_override_value_set_id  := g_cache_value.number_4;
     dfinfo.context_default_type           := g_cache_value.varchar2_11;
     dfinfo.context_default_value          := g_cache_value.varchar2_12;
     dfinfo.context_runtime_property_funct := g_cache_value.varchar2_13;

     return(TRUE);

  EXCEPTION
    WHEN NO_DATA_FOUND then
      FND_MESSAGE.set_name('FND', 'FLEX-DESC DEF NOT FOUND');
      FND_MESSAGE.set_token('APPID', flex_app_sname);
      FND_MESSAGE.set_token('DESCR_FLEX_NAME', desc_flex_name);
      return(FALSE);
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG','SV2.get_descstruct() exception: ' || SQLERRM);
      return(FALSE);

  END get_descstruct;

/* ----------------------------------------------------------------------- */
/*      Gets column names, column types, segment value set formats and     */
/*      maximum sizes for all enabled segments of the given key or         */
/*      descriptive flexfield structure.  Error if no key segments found.  */
/*      Returns FALSE and sets error message on error.                     */
/* ----------------------------------------------------------------------- */
  FUNCTION get_struct_cols(fstruct      IN  FND_FLEX_SERVER1.FlexStructId,
                           table_apid   IN  NUMBER,
                           table_id     IN  NUMBER,
                           n_columns    OUT nocopy NUMBER,
                           cols         OUT nocopy FND_FLEX_SERVER1.TabColArray,
                           coltypes     OUT nocopy FND_FLEX_SERVER1.CharArray,
                           seg_formats  OUT nocopy FND_FLEX_SERVER1.SegFormats)
    RETURN BOOLEAN
    IS
       CURSOR kff_column_cursor(p_application_id       IN NUMBER,
                                p_id_flex_code         IN VARCHAR2,
                                p_id_flex_num          IN NUMBER,
                                p_table_application_id IN NUMBER,
                                p_table_id             IN NUMBER)
         IS
            SELECT /*+ LEADING (G) USE_NL (G C S) */
              g.application_column_name     application_column_name,
              c.column_type                 application_column_type,
              Nvl(s.format_type, 'C')       value_set_format_type,
              Nvl(s.maximum_size, c.width)  value_set_maximum_size
              FROM fnd_flex_value_sets s, fnd_columns c, fnd_id_flex_segments g
              WHERE g.application_id = p_application_id
              AND g.id_flex_code = p_id_flex_code
              AND g.id_flex_num = p_id_flex_num
              AND g.enabled_flag = 'Y'
              AND s.flex_value_set_id(+) = g.flex_value_set_id
              AND c.application_id = p_table_application_id
              AND c.table_id = p_table_id
              AND c.column_name = g.application_column_name
              ORDER BY g.segment_num;

       CURSOR dff_column_cursor(p_application_id              IN NUMBER,
                                p_descriptive_flexfield_name  IN VARCHAR2,
                                p_descriptive_flex_context_co IN VARCHAR2,
                                p_table_application_id        IN NUMBER,
                                p_table_id                    IN NUMBER)
         IS
            SELECT
              g.application_column_name     application_column_name,
              c.column_type                 application_column_type,
              Nvl(s.format_type, 'C')       value_set_format_type,
              Nvl(s.maximum_size, c.width)  value_set_maximum_size
              FROM fnd_flex_value_sets s, fnd_columns c, fnd_descr_flex_column_usages g
              WHERE g.application_id = p_application_id
              AND g.descriptive_flexfield_name = p_descriptive_flexfield_name
              AND g.descriptive_flex_context_code = p_descriptive_flex_context_co
              AND g.enabled_flag = 'Y'
              AND s.flex_value_set_id(+) = g.flex_value_set_id
              AND c.application_id = p_table_application_id
              AND c.table_id = p_table_id
              AND c.column_name = g.application_column_name
              ORDER BY g.column_seq_num;

       i NUMBER;
  BEGIN
     IF (fstruct.isa_key_flexfield) THEN
        g_cache_key := ('KFF.' ||
                        fstruct.application_id || '.' ||
                        fstruct.id_flex_code   || '.' ||
                        fstruct.id_flex_num    || '.' ||
                        table_apid             || '.' ||
                        table_id);
        fnd_plsql_cache.generic_1tom_get_values(coc_cache_controller,
                                                coc_cache_storage,
                                                g_cache_key,
                                                g_cache_numof_values,
                                                g_cache_values,
                                                g_cache_return_code);

        IF (g_cache_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
           NULL;
         ELSE
           i := 0;
           FOR col_rec IN kff_column_cursor(fstruct.application_id,
                                            fstruct.id_flex_code,
                                            fstruct.id_flex_num,
                                            table_apid,
                                            table_id) LOOP
              i := i + 1;
              fnd_plsql_cache.generic_cache_new_value
                (x_value      => g_cache_value,
                 p_varchar2_1 => col_rec.application_column_name,
                 p_varchar2_2 => col_rec.application_column_type,
                 p_varchar2_3 => col_rec.value_set_format_type,
                 p_varchar2_4 => col_rec.value_set_maximum_size);
              g_cache_values(i) := g_cache_value;
           END LOOP;
           g_cache_numof_values := i;
           fnd_plsql_cache.generic_1tom_put_values(coc_cache_controller,
                                                   coc_cache_storage,
                                                   g_cache_key,
                                                   g_cache_numof_values,
                                                   g_cache_values);
        END IF;

        IF (g_cache_numof_values < 1) THEN
           FND_MESSAGE.set_name('FND', 'FLEX-CANT FIND SEGMENTS');
           FND_MESSAGE.set_token('ROUTINE', 'Get Comb Table Column Names');
           FND_MESSAGE.set_token('APPID', to_char(fstruct.application_id));
           FND_MESSAGE.set_token('CODE', fstruct.id_flex_code);
           FND_MESSAGE.set_token('NUM', to_char(fstruct.id_flex_num));
           return(FALSE);
        END IF;
      ELSE
        g_cache_key := ('DFF.' ||
                        fstruct.application_id    || '.' ||
                        fstruct.desc_flex_name    || '.' ||
                        fstruct.desc_flex_context || '.' ||
                        table_apid                || '.' ||
                        table_id);
        fnd_plsql_cache.generic_1tom_get_values(coc_cache_controller,
                                                coc_cache_storage,
                                                g_cache_key,
                                                g_cache_numof_values,
                                                g_cache_values,
                                                g_cache_return_code);


        IF (g_cache_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
           NULL;
         ELSE
           i := 0;
           FOR col_rec IN dff_column_cursor(fstruct.application_id,
                                            fstruct.desc_flex_name,
                                            fstruct.desc_flex_context,
                                            table_apid,
                                            table_id) LOOP
              i := i + 1;
              fnd_plsql_cache.generic_cache_new_value
                (x_value      => g_cache_value,
                 p_varchar2_1 => col_rec.application_column_name,
                 p_varchar2_2 => col_rec.application_column_type,
                 p_varchar2_3 => col_rec.value_set_format_type,
                 p_varchar2_4 => col_rec.value_set_maximum_size);
              g_cache_values(i) := g_cache_value;
           END LOOP;
           g_cache_numof_values := i;
           fnd_plsql_cache.generic_1tom_put_values(coc_cache_controller,
                                                   coc_cache_storage,
                                                   g_cache_key,
                                                   g_cache_numof_values,
                                                   g_cache_values);
        END IF;
     END IF;

     n_columns := g_cache_numof_values;
     seg_formats.nsegs := g_cache_numof_values;
     FOR i IN 1..g_cache_numof_values LOOP
        cols(i)                   := g_cache_values(i).varchar2_1;
        coltypes(i)               := g_cache_values(i).varchar2_2;
        seg_formats.vs_format(i)  := g_cache_values(i).varchar2_3;
        seg_formats.vs_maxsize(i) := g_cache_values(i).varchar2_4;
     END LOOP;

     RETURN(TRUE);

  EXCEPTION
     WHEN OTHERS then
        FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
        FND_MESSAGE.set_token('MSG', 'SV2.get_struct_cols() exception: '||SQLERRM);
        return(FALSE);
  END get_struct_cols;

/* ----------------------------------------------------------------------- */
/*      Gets flexfield qualifier name, segment qualifier name,             */
/*      combination table column name and default value, for all segment   */
/*      qualifiers associated with a given flexfield.                      */
/*      No qualifiers associated with descriptive flexfields.              */
/*      Returns TRUE on success or FALSE and sets error message if error.  */
/* ----------------------------------------------------------------------- */
  FUNCTION get_all_segquals(fstruct   IN  FND_FLEX_SERVER1.FlexStructId,
                            seg_quals OUT nocopy FND_FLEX_SERVER1.Qualifiers)
    RETURN BOOLEAN IS

       i NUMBER;

    CURSOR all_qual_cursor(keystruct in FND_FLEX_SERVER1.FlexStructId) IS
        SELECT segment_attribute_type fq_name, value_attribute_type sq_name,
               application_column_name drv_colname, default_value dflt_val
          FROM fnd_value_attribute_types
         WHERE application_id = keystruct.application_id
           AND id_flex_code = keystruct.id_flex_code;

  BEGIN
    seg_quals.nquals := 0;

    if(fstruct.isa_key_flexfield) THEN
       g_cache_key := fstruct.application_id || '.' || fstruct.id_flex_code;

       fnd_plsql_cache.generic_1tom_get_values(gas_cache_controller,
                                               gas_cache_storage,
                                               g_cache_key,
                                               g_cache_numof_values,
                                               g_cache_values,
                                               g_cache_return_code);

        IF (g_cache_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
           NULL;
         ELSE
           i := 0;
           for squal in all_qual_cursor(fstruct) LOOP
              i := i + 1;
              fnd_plsql_cache.generic_cache_new_value
                (x_value      => g_cache_value,
                 p_varchar2_1 => squal.fq_name,
                 p_varchar2_2 => squal.sq_name,
                 p_varchar2_3 => squal.dflt_val,
                 p_varchar2_4 => squal.drv_colname);
              g_cache_values(i) := g_cache_value;
           END LOOP;
           g_cache_numof_values := i;
           fnd_plsql_cache.generic_1tom_put_values(gas_cache_controller,
                                                   gas_cache_storage,
                                                   g_cache_key,
                                                   g_cache_numof_values,
                                                   g_cache_values);
        END IF;

        FOR i IN 1..g_cache_numof_values LOOP
           seg_quals.fq_names(i)     := g_cache_values(i).varchar2_1;
           seg_quals.sq_names(i)     := g_cache_values(i).varchar2_2;
           seg_quals.sq_values(i)    := g_cache_values(i).varchar2_3;
           seg_quals.derived_cols(i) := g_cache_values(i).varchar2_4;
        END LOOP;
        seg_quals.nquals := g_cache_numof_values;
    end if;

    return(TRUE);

  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG', 'SV2.get_all_segquals() exception: ' ||SQLERRM);
      return(FALSE);

  END get_all_segquals;

/* ------------------------------------------------------------------------- */
/*      Returns a table of flexfield qualifiers for each enabled segment     */
/*      for this flexfield, and a count of enabled segments and a map of     */
/*      which segments are required and displayed at the segment level.      */
/*      Does an outer join to get all segments in their display order and    */
/*      all flexfield qualifiers associated with each segment using a single */
/*      select.  For descriptive flexfields there are no qualifiers.  In     */
/*      this case return just the segment info for the given context.        */
/*      For key flexfields it's an error if no enabled segments found.       */
/*      Returns FALSE and sets error message if error, or returns TRUE of OK */
/* ------------------------------------------------------------------------- */

  FUNCTION get_qualsegs(fstruct    IN  FND_FLEX_SERVER1.FlexStructId,
                        nsegs      OUT nocopy NUMBER,
                        segdisp    OUT nocopy FND_FLEX_SERVER1.CharArray,
                        segrqd     OUT nocopy FND_FLEX_SERVER1.CharArray,
                        fqtab      OUT nocopy FND_FLEX_SERVER1.FlexQualTable)
                                                        RETURN BOOLEAN IS

    n_segs      NUMBER;
    n_fqual     NUMBER;
    segnums     FND_FLEX_SERVER1.NumberArray;

    CURSOR KeyFQCursor(kff_struct IN FND_FLEX_SERVER1.FlexStructId) IS
      SELECT s.segment_num segnum,
             s.display_flag displayed,
             s.required_flag required,
             sav.segment_attribute_type fqname
        FROM fnd_id_flex_segments s, fnd_segment_attribute_values sav
       WHERE s.application_id = kff_struct.application_id
         AND s.id_flex_code = kff_struct.id_flex_code
         AND s.id_flex_num = kff_struct.id_flex_num
         AND s.enabled_flag = 'Y'
         AND sav.application_column_name(+) = s.application_column_name
         AND sav.application_id(+) = kff_struct.application_id
         AND sav.id_flex_code(+) = kff_struct.id_flex_code
         AND sav.id_flex_num(+) = kff_struct.id_flex_num
         AND sav.attribute_value(+) = 'Y'
    ORDER BY s.segment_num;

    CURSOR DescFQCursor(dff_struct IN FND_FLEX_SERVER1.FlexStructId) IS
      SELECT column_seq_num segnum, display_flag displayed,
             required_flag required
        FROM fnd_descr_flex_column_usages
       WHERE application_id = dff_struct.application_id
         AND descriptive_flexfield_name = dff_struct.desc_flex_name
         AND descriptive_flex_context_code = dff_struct.desc_flex_context
         AND enabled_flag = 'Y'
    ORDER BY column_seq_num;

    kflexqual keyfqcursor%ROWTYPE;
    dflexqual descfqcursor%ROWTYPE;

    i NUMBER;
  BEGIN
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        fnd_flex_server1.add_debug('BEGIN SV2.get_qualsegs()');
     END IF;

--  Outer join on segments and flexfield qualifiers tables.
--  Fill segdisp, segrqd with the values only for the distict segments
--  which are separated by their segment numbers.  n_segs is the number
--  of distinct segments.  seg_indexes is order of distinct segments.
--  FlexQualTable maps qualifiers to seg_indexes.

     IF (fnd_flex_server1.g_debug_level > 0) THEN
        FND_FLEX_SERVER1.add_debug('Segments+quals: ');
     END IF;

    n_segs := 0;
    n_fqual := 0;
    if(fstruct.isa_key_flexfield) THEN

       g_cache_key:= ('KFF' || '.' ||
                      fstruct.application_id || '.' ||
                      fstruct.id_flex_code || '.' ||
                      fstruct.id_flex_num);

       fnd_plsql_cache.generic_1tom_get_values(gqs_cache_controller,
                                               gqs_cache_storage,
                                               g_cache_key,
                                               g_cache_numof_values,
                                               g_cache_values,
                                               g_cache_return_code);

       IF (g_cache_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
           NULL;
         ELSE
          i := 0;
          FOR kflexqual IN keyfqcursor(fstruct) LOOP
             i := i + 1;
             fnd_plsql_cache.generic_cache_new_value
               (x_value      => g_cache_value,
                p_number_1   => kflexqual.segnum,
                p_varchar2_1 => kflexqual.displayed,
                p_varchar2_2 => kflexqual.required,
                p_varchar2_3 => kflexqual.fqname);
             g_cache_values(i) := g_cache_value;
          END LOOP;
          g_cache_numof_values := i;
          fnd_plsql_cache.generic_1tom_put_values(gqs_cache_controller,
                                                  gqs_cache_storage,
                                                  g_cache_key,
                                                  g_cache_numof_values,
                                                  g_cache_values);
       END IF;

       FOR i IN 1..g_cache_numof_values LOOP
          kflexqual.segnum    := g_cache_values(i).number_1;
          kflexqual.displayed := g_cache_values(i).varchar2_1;
          kflexqual.required  := g_cache_values(i).varchar2_2;
          kflexqual.fqname    := g_cache_values(i).varchar2_3;

--      for flexqual in KeyFQCursor(fstruct) loop
        n_fqual := n_fqual + 1;
        segnums(n_fqual) := kflexqual.segnum;
        fqtab.fq_names(n_fqual) := kflexqual.fqname;
        if((n_fqual = 1) or (segnums(n_fqual) <> segnums(n_fqual - 1))) then
--  This is a new distinct segment.
          n_segs := n_segs + 1;
          segdisp(n_segs) := kflexqual.displayed;
          segrqd(n_segs) := kflexqual.required;
        end if;
        fqtab.seg_indexes(n_fqual) := n_segs;
        IF (fnd_flex_server1.g_debug_level > 0) THEN
           FND_FLEX_SERVER1.add_debug('(' || to_char(kflexqual.segnum) || ', ' ||
                                      kflexqual.fqname || ') ');
        END IF;
      end loop;
-- Key flexfield must have enabled segments
      if(n_fqual <= 0) then
        FND_MESSAGE.set_name('FND', 'FLEX-CANT FIND SEGMENTS');
        FND_MESSAGE.set_token('ROUTINE', 'FND_FLEX_SERVER2.get_qualsegs()');
        FND_MESSAGE.set_token('APPID', to_char(fstruct.application_id));
        FND_MESSAGE.set_token('CODE', fstruct.id_flex_code);
        FND_MESSAGE.set_token('NUM', to_char(fstruct.id_flex_num));
        return(FALSE);
      end if;
    else
       -- Descriptive flexfield segments

       g_cache_key:= ('DFF' || '.' ||
                      fstruct.application_id || '.' ||
                      fstruct.desc_flex_name || '.' ||
                      fstruct.desc_flex_context);

       fnd_plsql_cache.generic_1tom_get_values(gqs_cache_controller,
                                               gqs_cache_storage,
                                               g_cache_key,
                                               g_cache_numof_values,
                                               g_cache_values,
                                               g_cache_return_code);

       IF (g_cache_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
          NULL;
        ELSE
          i := 0;
          FOR dflexqual in descfqcursor(fstruct) LOOP
             i := i + 1;
             fnd_plsql_cache.generic_cache_new_value
               (x_value     => g_cache_value,
                p_number_1  => dflexqual.segnum,
                p_varchar2_1=> dflexqual.displayed,
                p_varchar2_2=> dflexqual.required);
             g_cache_values(i) := g_cache_value;
          END LOOP;
          g_cache_numof_values := i;
          fnd_plsql_cache.generic_1tom_put_values(gqs_cache_controller,
                                                  gqs_cache_storage,
                                                  g_cache_key,
                                                  g_cache_numof_values,
                                                  g_cache_values);
       END IF;

       FOR i IN 1..g_cache_numof_values LOOP
          dflexqual.segnum    := g_cache_values(i).number_1;
          dflexqual.displayed := g_cache_values(i).varchar2_1;
          dflexqual.required  := g_cache_values(i).varchar2_2;


--      for flexqual in DescFQCursor(fstruct) loop
          n_segs := n_segs + 1;
          segdisp(n_segs) := dflexqual.displayed;
          segrqd(n_segs) := dflexqual.required;
          fqtab.fq_names(n_segs) := NULL;
          fqtab.seg_indexes(n_segs) := n_segs;
          IF (fnd_flex_server1.g_debug_level > 0) THEN
             FND_FLEX_SERVER1.add_debug('(' || to_char(dflexqual.segnum) || ') ');
          END IF;
       end loop;
       n_fqual := n_segs;
    end if;

    fqtab.nentries := n_fqual;
    nsegs := n_segs;
    IF (fnd_flex_server1.g_debug_level > 0) THEN
       fnd_flex_server1.add_debug('END SV2.get_qualsegs()');
    END IF;

    return(TRUE);

  EXCEPTION
    WHEN OTHERS THEN
       IF (fnd_flex_server1.g_debug_level > 0) THEN
          fnd_flex_server1.add_debug('EXCEPTION others SV2.get_qualsegs()');
       END IF;
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG','SV2.get_qualsegs() exception: ' || SQLERRM);
      return(FALSE);

  END get_qualsegs;




/* ----------------------------------------------------------------------- */
/*      Performes cross-validation against validation rules.               */
/*      Returns VV_VALID if combination valid, VV_CROSSVAL if              */
/*      rule violated or VV_ERROR if error.                                */
/*      Returns error_column_name and sets error message in                */
/*      FND_MESSAGE if not valid.                                          */
/*      Segment array is 1-based containing entries for 1 <= i <= nsegs    */
/* ----------------------------------------------------------------------- */

  FUNCTION cross_validate(nsegs   IN NUMBER,
                          segs    IN FND_FLEX_SERVER1.ValueArray,
                          segfmt  IN FND_FLEX_SERVER1.SegFormats,
                          vdt     IN DATE,
                          fstruct IN FND_FLEX_SERVER1.FlexStructId,
                          errcol  OUT nocopy VARCHAR2)
    RETURN NUMBER
    IS
       isviolated  BOOLEAN;
       incache     BOOLEAN;
       rulemsg     VARCHAR2(240);
       rulename    VARCHAR2(15);
       segments    FND_FLEX_SERVER1.StringArray;
       l_cat_segs  VARCHAR2(32000);
  BEGIN

     --  Convert value array to string array for subsequent processing.
     --
     for i in 1..nsegs loop
        segments(i) := segs(i);
     end loop;

     --  Concatenate segments
     --
     l_cat_segs := FND_FLEX_SERVER1.from_stringarray2(nsegs, segments,
                                                      CACHE_DELIMITER);

     --  Next see if cross-validation result in cache.  If not, check the
     --  cross validation rules and cache the result.  Implement our own
     --  cost-based optimization to check the rules more efficiently
     --
     if(x_xvc_check_cache(fstruct, vdt,
                          l_cat_segs,
                          incache, isviolated, rulename) = FALSE) then
        return(FND_FLEX_SERVER1.VV_ERROR);
     end if;

     IF (NOT incache) then

        -- Check to see if rules violated.
        --
        isviolated := (cv_rule_violated(nsegs, segments, segfmt, fstruct, 'E',
                                        vdt, rulename) OR
                       cv_rule_violated(nsegs, segments, segfmt, fstruct, 'I',
                                        vdt, rulename));
        -- Save the result in cache
        --
        if(x_xvc_update_cache(fstruct, vdt,
                              l_cat_segs,
                              isviolated, rulename) = FALSE) then
           return(FND_FLEX_SERVER1.VV_ERROR);
        end if;

     end if;

     IF (isviolated and fstruct.isa_key_flexfield) then
        IF (rulename is not null) then
           select error_message_text, error_segment_column_name
             into rulemsg, errcol
             from fnd_flex_vdation_rules_vl
             where application_id = fstruct.application_id
             and id_flex_code = fstruct.id_flex_code
             and id_flex_num = fstruct.id_flex_num
             and flex_validation_rule_name = rulename;
           FND_MESSAGE.set_name('FND', 'FLEX-EXCLUDED BY XVAL RULE');
           FND_MESSAGE.set_token('MESSAGE', rulemsg);
           return(FND_FLEX_SERVER1.VV_CROSSVAL);
        end if;
        return(FND_FLEX_SERVER1.VV_ERROR);
     end if;
     return(FND_FLEX_SERVER1.VV_VALID);

  EXCEPTION
     WHEN NO_DATA_FOUND then
        FND_MESSAGE.set_name('FND', 'FLEX-XVAL RULE MSG NOT FOUND');
        FND_MESSAGE.set_token('RULENAME', rulename);
        return(FND_FLEX_SERVER1.VV_ERROR);
     WHEN TOO_MANY_ROWS then
        FND_MESSAGE.set_name('FND', 'FLEX-XVAL RULE MSG NOT UNIQUE');
        FND_MESSAGE.set_token('RULENAME', rulename);
        return(FND_FLEX_SERVER1.VV_ERROR);
     WHEN OTHERS then
        FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
        FND_MESSAGE.set_token('MSG','SV2.cross_validate() exception: '||SQLERRM);
        return(FND_FLEX_SERVER1.VV_ERROR);
  END cross_validate;



/* ----------------------------------------------------------------------- */
/* Bug 21612876, This procedure is called from C code fdfgcx.lc            */
/* This procedure processes the CVR report. This procedure has better      */
/* performance than the original C validation api fdfvxr().                */
/* parameters for more specific processing for the CVR report.             */
/* ----------------------------------------------------------------------- */
  PROCEDURE cross_validate_report(
                          appid             IN NUMBER,
                          code              IN VARCHAR2,
                          structid          IN NUMBER,
        concat_segs     IN VARCHAR2,
        concat_vs_format  IN VARCHAR2,
        concat_vs_maxsize IN VARCHAR2,
        delim             IN VARCHAR2,
        nsegments         IN NUMBER,
        cvr_low           IN VARCHAR2,
        cvr_high          IN VARCHAR2,
                          vdate             IN VARCHAR2,
                          errcode           OUT nocopy NUMBER,
                          cvrmsg            OUT nocopy VARCHAR2)

    IS
       segment_array FND_FLEX_EXT.SegmentArray;
       vs_format_array FND_FLEX_EXT.SegmentArray;
       vs_maxsize_array FND_FLEX_EXT.SegmentArray;
       segs FND_FLEX_SERVER1.ValueArray;
       segtypes FND_FLEX_SERVER1.SegFormats;
       kff_id FND_FLEX_SERVER1.FlexStructId;
       cvr_errormsg VARCHAR2(26);
       errbuf VARCHAR2(100);
       i number;
       status NUMBER;
       result boolean;
       v_date DATE;
       l_cvr_low VARCHAR2(15);
       l_cvr_high VARCHAR2(15);

    BEGIN
       i :=0;
       kff_id.isa_key_flexfield := TRUE;
       kff_id.application_id :=appid;
       kff_id.id_flex_code :=code;
       kff_id.id_flex_num := structid;
       l_cvr_low := cvr_low;
       l_cvr_high := cvr_high;

       if(vdate = '0') then
          v_date := NULL;
       else
          v_date := to_date(vdate, DATE_PASS_FORMAT);
       end if;

       status:=fnd_flex_ext.breakup_segments(concat_segs,delim,segment_array);
       status:=fnd_flex_ext.breakup_segments(concat_vs_format,delim,vs_format_array);
       status:=fnd_flex_ext.breakup_segments(concat_vs_maxsize,delim,vs_maxsize_array);

     FOR i IN 1..nsegments LOOP
        segs(i):=segment_array(i);
        segtypes.vs_format(i):=vs_format_array(i);
        segtypes.vs_maxsize(i):=to_number(vs_maxsize_array(i));
     END LOOP;
     segtypes.nsegs := nsegments;

     result := fnd_flex_server1.init_globals;

     errcode :=FND_FLEX_SERVER2.cross_validate_segs_report
                               (nsegments, segs, segtypes, v_date, kff_id, cvr_low, cvr_high, cvr_errormsg);
     cvrmsg  := cvr_errormsg;

  EXCEPTION
     WHEN OTHERS then
       errbuf := Substr('cross_validate_report:SQLERRM: ' || Sqlerrm, 1, 240);

  END cross_validate_report;



/* ----------------------------------------------------------------------- */
/*      Performes cross-validation against validation rules.               */
/*      Returns VV_VALID if combination valid, VV_CROSSVAL if              */
/*      rule violated or VV_ERROR if error.                                */
/*      Returns cvr error msg and sets error message in                    */
/*      FND_MESSAGE if not valid.                                          */
/*      Segment array is 1-based containing entries for 1 <= i <= nsegs    */
/* ----------------------------------------------------------------------- */
/* Bug 21612876, This is a copy of cross_validate() function but added more
   parameters for more specific processing for the CVR report. */

  FUNCTION cross_validate_segs_report(nsegs   IN NUMBER,
                                     segs     IN FND_FLEX_SERVER1.ValueArray,
                                     segfmt   IN FND_FLEX_SERVER1.SegFormats,
                                     vdt      IN DATE,
                                     fstruct  IN FND_FLEX_SERVER1.FlexStructId,
                                     cvr_low  IN VARCHAR2,
                                     cvr_high IN VARCHAR2,
                                     cvrmsg   OUT nocopy VARCHAR2)
    RETURN NUMBER
    IS
       isviolated  BOOLEAN;
       incache     BOOLEAN;
       rulemsg     VARCHAR2(240);
       rulename    VARCHAR2(15);
       errcol      VARCHAR2(30);
       segments    FND_FLEX_SERVER1.StringArray;
       l_cat_segs  VARCHAR2(32000);
  BEGIN

     --  Convert value array to string array for subsequent processing.
     --
     for i in 1..nsegs loop
        segments(i) := segs(i);
     end loop;

     --  Concatenate segments
     --
     l_cat_segs := FND_FLEX_SERVER1.from_stringarray2(nsegs, segments,
                                                      CACHE_DELIMITER);

     --  Next see if cross-validation result in cache.  If not, check the
     --  cross validation rules and cache the result.  Implement our own
     --  cost-based optimization to check the rules more efficiently
     --
     if(x_xvc_check_cache(fstruct, vdt,
                          l_cat_segs,
                          incache, isviolated, rulename) = FALSE) then
        return(FND_FLEX_SERVER1.VV_ERROR);
     end if;

     IF (NOT incache) then

        -- Check to see if rules violated.
        --
        isviolated := (cv_rule_violated_report(nsegs, segments, segfmt, fstruct, 'E',
                                        vdt, cvr_low, cvr_high, rulename) OR
                       cv_rule_violated_report(nsegs, segments, segfmt, fstruct, 'I',
                                        vdt, cvr_low, cvr_high, rulename));
        -- Save the result in cache
        --
        if(x_xvc_update_cache(fstruct, vdt,
                              l_cat_segs,
                              isviolated, rulename) = FALSE) then
           return(FND_FLEX_SERVER1.VV_ERROR);
        end if;

     end if;

     IF (isviolated and fstruct.isa_key_flexfield) then
        IF (rulename is not null) then
           select error_message_text, error_segment_column_name
             into rulemsg, errcol
             from fnd_flex_vdation_rules_vl
             where application_id = fstruct.application_id
             and id_flex_code = fstruct.id_flex_code
             and id_flex_num = fstruct.id_flex_num
             and flex_validation_rule_name = rulename;

             cvrmsg := substr(rulemsg,1,25);

           FND_MESSAGE.set_name('FND', 'FLEX-EXCLUDED BY XVAL RULE');
           FND_MESSAGE.set_token('MESSAGE', rulemsg);
           return(FND_FLEX_SERVER1.VV_CROSSVAL);
        end if;
        return(FND_FLEX_SERVER1.VV_ERROR);
     end if;
     return(FND_FLEX_SERVER1.VV_VALID);

  EXCEPTION
     WHEN NO_DATA_FOUND then
        FND_MESSAGE.set_name('FND', 'FLEX-XVAL RULE MSG NOT FOUND');
        FND_MESSAGE.set_token('RULENAME', rulename);
        return(FND_FLEX_SERVER1.VV_ERROR);
     WHEN TOO_MANY_ROWS then
        FND_MESSAGE.set_name('FND', 'FLEX-XVAL RULE MSG NOT UNIQUE');
        FND_MESSAGE.set_token('RULENAME', rulename);
        return(FND_FLEX_SERVER1.VV_ERROR);
     WHEN OTHERS then
        FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
        FND_MESSAGE.set_token('MSG','SV2.cross_validate() exception: '||SQLERRM);
        return(FND_FLEX_SERVER1.VV_ERROR);
  END cross_validate_segs_report;


/* ----------------------------------------------------------------------- */
/* Bug 23601325, This report is called from the Conc Request to run        */
/* the cross validation report. This report is purely run in plsql         */
/* as opposed to other cvr reports that are run partly in C code           */
/* ----------------------------------------------------------------------- */
PROCEDURE submit_cvr_report(p_errbuf            OUT nocopy VARCHAR2,
                            p_retcode           OUT nocopy VARCHAR2,
                            p_appid             IN NUMBER,
                            p_code              IN VARCHAR2,
                            p_structid          IN NUMBER,
                            p_nonsummary        IN VARCHAR2,
                            p_disnonsummary     IN VARCHAR2,
                            p_summary           IN VARCHAR2,
                            p_dissummary        IN VARCHAR2,
                            p_enddate           IN VARCHAR2,
                            p_cvr_low           IN VARCHAR2,
                            p_cvr_high          IN VARCHAR2,
                            p_num_workers       IN NUMBER)
   IS

   l_errbuf  VARCHAR2(240);
   l_retcode VARCHAR2(30);
   l_appid   NUMBER;
   l_structid NUMBER;

   BEGIN

      IF ( p_num_workers > 1 ) THEN
              cvr_report_parallel(p_application_id => p_appid,
                                  p_id_flex_code => p_code,
                                  p_id_flex_num => p_structid,
                                  p_show_non_sum_comb => p_nonsummary,
                                  p_dis_non_sum_comb => p_disnonsummary,
                                  p_show_sum_comb => p_summary,
                                  p_dis_sum_comb => p_dissummary,
                                  p_enddate_flag => p_enddate,
                                  p_cvr_name_low => p_cvr_low,
                                  p_cvr_name_high => p_cvr_high,
                                  p_num_workers => p_num_workers,
                                  p_errbuf => l_errbuf,
                                  p_retcode => l_retcode);
      ELSE
                       cvr_report(errbuf => l_errbuf,
                                  retcode => l_retcode,
                                  appid => p_appid,
                                  code => p_code,
                                  structid => p_structid,
                                  nonsummary => p_nonsummary,
                                  disnonsummary => p_disnonsummary,
                                  summary => p_summary,
                                  dissummary => p_dissummary,
                                  enddate => p_enddate,
                                  cvr_low => p_cvr_low,
                                  cvr_high => p_cvr_high,
                                  vdate => '0',
                                  minccid => NULL,
                                  maxccid => NULL);
      END IF;

      p_errbuf := l_errbuf;
      p_retcode := l_retcode;

   END submit_cvr_report;


/* ----------------------------------------------------------------------- */
/* Bug 23601325,  Main routine to run the plsql cvr report                 */
/* ----------------------------------------------------------------------- */
  PROCEDURE cvr_report(errbuf            OUT nocopy VARCHAR2,
                       retcode           OUT nocopy VARCHAR2,
                       appid             IN NUMBER,
                       code              IN VARCHAR2,
                       structid          IN NUMBER,
                       nonsummary        IN VARCHAR2,
                       disnonsummary     IN VARCHAR2, -- Y or N if Y then update
                       summary           IN VARCHAR2,
                       dissummary        IN VARCHAR2,
                       enddate           IN VARCHAR2,
                       cvr_low           IN VARCHAR2,
                       cvr_high          IN VARCHAR2,
                       vdate             IN VARCHAR2,
                       minccid           IN NUMBER,
                       maxccid           IN NUMBER)
   IS

   l_errbuf VARCHAR2(240);
   l_retcode VARCHAR2(30);

   BEGIN

        cvr_report_segs(appid             => cvr_report.appid             ,
                       code              => cvr_report.code              ,
                       structid          => cvr_report.structid          ,
                       nonsummary        => cvr_report.nonsummary        ,
                       disnonsummary     => cvr_report.disnonsummary     ,
                       summary           => cvr_report.summary           ,
                       dissummary        => cvr_report.dissummary        ,
                       enddate           => cvr_report.enddate           ,
                       cvr_low           => cvr_report.cvr_low           ,
                       cvr_high          => cvr_report.cvr_high          ,
                       vdate             => cvr_report.vdate             ,
                       minccid           => cvr_report.minccid           ,
                       maxccid           => cvr_report.maxccid           ,
                       errbuf            => l_errbuf                     ,
                       retcode           => l_retcode);

   errbuf := l_errbuf;
   retcode := l_retcode;

   END cvr_report;


/* ----------------------------------------------------------------------- */
/*  11-Aug-2016  - emiranda - Created                                      */
/* ----------------------------------------------------------------------- */
/* Bug 23601325,  Routine to process segments for the cvr report           */
/* ----------------------------------------------------------------------- */
  PROCEDURE    cvr_report_segs(appid         IN NUMBER,
                               code          IN VARCHAR2,
                               structid      IN NUMBER,
                               nonsummary    IN VARCHAR2,
                               disnonsummary IN VARCHAR2, -- Y or N if Y then update
                               summary       IN VARCHAR2,
                               dissummary    IN VARCHAR2,
                               enddate       IN VARCHAR2,
                               cvr_low       IN VARCHAR2,
                               cvr_high      IN VARCHAR2,
                               vdate         IN VARCHAR2,
                               minccid       IN NUMBER,
                               maxccid       IN NUMBER,
                               errbuf        OUT nocopy VARCHAR2,
                               retcode       OUT nocopy VARCHAR2)
   IS
    l_appl_name         VARCHAR2(50);
    segtypes            FND_FLEX_SERVER1.SegFormats;
    kff_id              FND_FLEX_SERVER1.FlexStructId;
    l_concat_vs_format  FND_FLEX_SERVER1.SegFormats;

    loc_initime      PLS_INTEGER;
    loc_tottime      PLS_INTEGER;

    C_tkn_date CONSTANT VARCHAR2(300) :=
       'AND ( G.SEGMENTYY BETWEEN NVL(TO_DATE( L.SEGMENTXX_LOW,''FF_FMT''), M.L_LOWXX) ' ||
                            'AND NVL(TO_DATE( L.SEGMENTXX_HIGH,''FF_FMT''), M.L_HIGHXX )) ';

    C_tkn_num CONSTANT VARCHAR2(300) :=
       'AND ( G.SEGMENTYY BETWEEN NVL(FND_NUMBER.CANONICAL_TO_NUMBER(L.SEGMENTXX_LOW), M.L_LOWXX) ' ||
                             'AND NVL(FND_NUMBER.CANONICAL_TO_NUMBER(L.SEGMENTXX_HIGH), M.L_HIGHXX )) ';

    C_tkn_other CONSTANT VARCHAR2(300) :=
       'AND ( G.SEGMENTYY BETWEEN NVL(L.SEGMENTXX_LOW, M.L_LOWXX) AND NVL(L.SEGMENTXX_HIGH, M.L_HIGHXX )) ';

    C_tkn_cvr_R CONSTANT VARCHAR2(100) := 'AND R.FLEX_VALIDATION_RULE_NAME BETWEEN ''XX'' AND ''YY'' ';
    C_tkn_cvr_L CONSTANT VARCHAR2(100) := 'AND L.FLEX_VALIDATION_RULE_NAME BETWEEN ''XX'' AND ''YY'' ';

    C_tkn_date_filt1 CONSTANT VARCHAR2(200) :=
        'AND (G.START_DATE_ACTIVE IS NULL OR G.START_DATE_ACTIVE <= SYSDATE) ' ||
        ' AND (G.END_DATE_ACTIVE IS NULL OR G.END_DATE_ACTIVE >= SYSDATE) ';

    -- The Alias on the dynamic SELECT-command is G
    C_tkn_sumflg_Y CONSTANT VARCHAR2(50) := 'AND G.SUMMARY_FLAG = ''Y'' ';
    C_tkn_sumflg_N CONSTANT VARCHAR2(50) := 'AND G.SUMMARY_FLAG = ''N'' ';

    -- The Alias on the dynamic UPDATE-command is A
    C_tkn_upd_sumflg_Y     CONSTANT VARCHAR2(50) := 'AND A.SUMMARY_FLAG = ''Y'' ';
    C_tkn_upd_sumflg_not_Y CONSTANT VARCHAR2(50) := 'AND A.SUMMARY_FLAG != ''Y'' ';

    C_tkn_ccid_filt1 CONSTANT VARCHAR2(200) := 'AND G.XX BETWEEN YY AND ZZ ';

    TYPE gl_comb_rt IS RECORD
     (
       ccid         FND_ID_FLEXS.SET_DEFINING_COLUMN_NAME%TYPE,
       concat_segs  VARCHAR2(400),
       rowid_g      VARCHAR2(30),
       fv_rule_name FND_FLEX_VALIDATION_RULES.FLEX_VALIDATION_RULE_NAME%TYPE,
       errmesg_det  FND_FLEX_VDATION_RULES_VL.ERROR_MESSAGE_TEXT%TYPE,
       errmesg_col  FND_FLEX_VDATION_RULES_VL.ERROR_SEGMENT_COLUMN_NAME%TYPE
     );

    TYPE      glcomb_info_t IS TABLE OF gl_comb_rt INDEX BY PLS_INTEGER;
    t_glcomb  glcomb_info_t;

    -- cvr_errormsg     VARCHAR2(26);
    i                NUMBER;
    RESULT           BOOLEAN;
    l_upd_flag       BOOLEAN := FALSE;
    l_use_key_binds  BOOLEAN := FALSE;
    v_date           DATE;
    l_sql_dyn        VARCHAR2(12000);
    l_dyn_totseg     VARCHAR2(2000);
    l_dyn_eachseg    VARCHAR2(2000);
    l_dyn_lows       VARCHAR2(2000);
    l_dyn_highs      VARCHAR2(2000);
    l_dyn_LowsHighs  VARCHAR2(2000);
    lim_rec          PLS_INTEGER := 500;
    l_cnt            pls_integer;
    cv               sys_refcursor;
    l_tmp_date       date;
    l_tmp_date_str   varchar2(100);
    l_tmp_cvr_data_r VARCHAR2(100);
    l_tmp_cvr_data_l VARCHAR2(100);

    l_userDT_mask    VARCHAR2(100);
    l_ccid_flt_tmp   VARCHAR2(150);
    l_key_binds      VARCHAR2(150);
    l_tmp_summary    VARCHAR2(150);  -- Temp filter for SELECT-command summary_flag
    l_tmp_upd_summary    VARCHAR2(150); -- Temp filter for UPDATE-command summary_flag
    l_tmp_date_fltr1 VARCHAR2(150);

    l_app_table_name    fnd_id_flexs.APPLICATION_TABLE_NAME%TYPE;
    l_set_def_col_name  fnd_id_flexs.SET_DEFINING_COLUMN_NAME%TYPE;
    l_uniq_col_id_name  fnd_id_flexs.UNIQUE_ID_COLUMN_NAME%TYPE;

    l_application_name          FND_APPLICATION_TL.APPLICATION_NAME%TYPE;
    l_id_flex_structure_name    FND_ID_FLEX_STRUCTURES_TL.ID_FLEX_STRUCTURE_NAME%TYPE;
    l_id_flex_name              FND_ID_FLEXS.ID_FLEX_NAME%TYPE;

/* Translate Heading
    appl_prompt         VARCHAR2(80);
    flex_code_prompt    VARCHAR2(80);
    flex_struct_prompt  VARCHAR2(80);
    cvr_from_prompt     VARCHAR2(80);
    cvr_to_prompt       VARCHAR2(80);
    ccid_prompt         VARCHAR2(80);
    cvr_heading         VARCHAR2(240);
    date_heading        VARCHAR2(80);
*/

    --
    -- Structure control variable, segments parsing
    --
    l_flex_struct  FND_FLEX_SERVER1.FlexStructId;
    l_struct_info  FND_FLEX_SERVER1.FlexStructInfo;
    l_cctbl_info   FND_FLEX_SERVER1.CombTblInfo;
    l_cols         FND_FLEX_SERVER1.TabColArray;
    l_coltypes     FND_FLEX_SERVER1.CharArray;
    l_delim        VARCHAR2(1);
    l_nsegments    NUMBER;
    l_max_segs_len NUMBER;   -- Maximum segments lenght plus a 1-character separator per segment.

    PROCEDURE print_params AS

    BEGIN
      -- Uncomment to print the Input parameters

      /*
      ol('. ');
      ol('DBG: cvr_report_segs - parameters: ');
      ol('DBG: appid         :[ '|| appid         || ' ] ');
      ol('DBG: code          :[ '|| code          || ' ] ');
      ol('DBG: structid      :[ '|| structid      || ' ] ');
      ol('DBG: nonsummary    :[ '|| nonsummary    || ' ] ');
      ol('DBG: disnonsummary :[ '|| disnonsummary || ' ] ');
      ol('DBG: summary       :[ '|| summary       || ' ] ');
      ol('DBG: dissummary    :[ '|| dissummary    || ' ] ');
      ol('DBG: enddate       :[ '|| enddate       || ' ] ');
      ol('DBG: cvr_low       :[ '|| cvr_low       || ' ] ');
      ol('DBG: cvr_high      :[ '|| cvr_high      || ' ] ');
      ol('DBG: vdate         :[ '|| vdate         || ' ] ');
      ol('DBG: minccid       :[ '|| minccid       || ' ] ');
      ol('DBG: maxccid       :[ '|| maxccid       || ' ] ');
      ol('. ');
      */

      NULL;
    END print_params;

    -- Loc_tnk_rpl - Local Token replace
    -- Generates Segments by type: number, date and others
    FUNCTION LOC_TNK_RPL(p_hierchy_pos NUMBER,
                         p_position  NUMBER,
                         p_maxsize   NUMBER,
                         p_type      VARCHAR2) RETURN VARCHAR2 AS
      l_rtn     VARCHAR2(300);
      l_tmp1    VARCHAR2(300);
      l_datefmt VARCHAR2(100);
    BEGIN
      IF (p_type = 'N') THEN
        l_tmp1 := REPLACE(c_tkn_num, 'YY', to_char(p_hierchy_pos));
        l_rtn := REPLACE(l_tmp1, 'XX', to_char(p_position));
      ELSIF (p_type IN ('D', 'T', 't', 'I', 'X', 'Y', 'Z')) THEN
        l_datefmt  := fnd_flex_server1.stored_date_format(p_type, p_maxsize);
        if l_datefmt is NULL then
           l_datefmt := fnd_flex_server1.stored_date_format('D', 11);
        end if;
        l_tmp1      := REPLACE(
                              REPLACE(c_tkn_date, 'XX', to_char(p_position)) ,
                              'FF_FMT',
                              l_datefmt
                             );
        l_rtn := REPLACE(l_tmp1, 'YY', to_char(p_hierchy_pos));
      ELSE
        l_tmp1 := REPLACE(c_tkn_other,   'YY', to_char(p_hierchy_pos));
        l_rtn := REPLACE(l_tmp1, 'XX', to_char(p_position));
      END IF;
      RETURN l_rtn;
    END LOC_TNK_RPL;

    -- Loc_low_high_rpl
    --    Replace low and HIGH values dymically base on : type, position and maximum-size
    --    ie variables l_low1 and l_high1 for the main query
    --
    PROCEDURE Loc_low_high_rpl ( p_position  number,
                                 p_type      varchar2,
                                 p_maxsize   number,
                                 p_dyn_lows  IN OUT nocopy VARCHAR2,
                                 p_dyn_highs IN OUT nocopy VARCHAR2 ) AS
       l_datefmt   varchar2(100) := 'TO_DATE(''31/12/9999 23:59:59'', ''DD/MM/YYYY HH24:MI:SS'')';
       l_datefmt_j varchar2(100) := 'TO_DATE(''1'',''J'')';
    BEGIN

      IF p_type = 'N' THEN
         -- Numeric type - min and max
          p_dyn_lows    := p_dyn_lows ||
                            ' 0 l_low'|| p_position||',';

          p_dyn_highs   := p_dyn_highs ||
                           ' '|| LPAD('9', p_maxsize, '9' ) || ' l_high'|| p_position||',';

      ELSIF (p_type IN ('D', 'T', 't', 'I', 'X', 'Y', 'Z')) THEN
         -- Date type
         p_dyn_lows    := p_dyn_lows  || ' ' || l_datefmt_j || ' l_low'|| p_position||',';

         p_dyn_highs   := p_dyn_highs || ' ' || l_datefmt || ' l_high'|| p_position||',';

      ELSE
         -- Character or VARCHAR2 type
          p_dyn_lows    := p_dyn_lows ||
                            ' '''|| '0' || ''' l_low'|| p_position||',';

          p_dyn_highs   := p_dyn_highs ||
                           ' '''|| LPAD('Z', p_maxsize , 'Z' ) || ''' l_high'|| p_position||',';
      END IF;

    END Loc_low_high_rpl;


    --
    -- int_upd_cmbtbl
    --  Internal Update Combination Table to DISABLE
    --
    Procedure int_upd_cmbtbl ( p_tbl_name    varchar2,
                              p_tbl_process glcomb_info_t )
    AS
     PRAGMA AUTONOMOUS_TRANSACTION;
     l_sql_upd      VARCHAR2(2000);
     l_tmp_userid   NUMBER;
    BEGIN
      IF p_tbl_name is NOT NULL THEN

         l_tmp_userid   :=  fnd_global.USER_ID;

         l_sql_upd := 'UPDATE /*+ ROWID(A) parallel(auto) */ ' ||
                              p_tbl_name || ' A ' ||
                          'SET A.ENABLED_FLAG = ''N'', ' ||
                            ' A.LAST_UPDATE_DATE = SYSDATE, ' ||
                            ' A.LAST_UPDATED_BY = '|| l_tmp_userid || ' ' ||
                        'WHERE A.ROWID = :1 ' ||
                        l_tmp_upd_summary ;

         /*
         ol('. ');
         ol('DBG: int_upd_cmbtbl ' );
         ol('DBG: p_tbl_name [ '|| p_tbl_name ||' ]' );
         ol('DBG: l_sql_upd [ '|| l_sql_upd ||' ]' );
         ol('DBG: p_tbl_process [ '|| p_tbl_process.count ||' ]' );
         ol('. ');
         */

         FORALL i IN p_tbl_process.first .. p_tbl_process.last
            EXECUTE IMMEDIATE l_sql_upd
              USING p_tbl_process(i).ROWID_G;
         commit;
      END IF;
    EXCEPTION
     WHEN OTHERS THEN
       -- Report NO error if the UPDATE is NOT possible
       -- Uncomment below for debug information
       /*
       ol('DBG: int_upd_cmbtbl - Exist ERROR ...');
       ol('Error code    :' || sqlcode);
       ol('Error message :' || sqlerrm , 80);
       */
       NULL;
    END int_upd_cmbtbl;

    --
    -- Initialize main local variables
    --
    PROCEDURE INIT as
    BEGIN
      i                        := 0;
      kff_id.isa_key_flexfield := TRUE;
      kff_id.application_id    := appid;
      kff_id.id_flex_code      := code;
      kff_id.id_flex_num       := structid;
      L_TMP_CVR_DATA_R         := NULL;
      L_TMP_CVR_DATA_L         := NULL;
      l_ccid_flt_tmp           := NULL;
      l_tmp_summary            := NULL;
      l_tmp_upd_summary        := NULL;
      l_cnt                    := 0;
      l_max_segs_len           := 0;

      BEGIN
         SELECT A.APPLICATION_SHORT_NAME
           INTO l_appl_name
           FROM FND_APPLICATION A
          WHERE A.APPLICATION_ID = APPID ;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
           l_appl_name := NULL;
      END;

      RESULT := fnd_flex_server1.init_globals;

    END INIT;

    PROCEDURE SET_DYN_NAMES AS

    BEGIN
     ------------------------------------------------------------
     -- Select the information needed to add dynamic names -
     ------------------------------------------------------------
     SELECT a.application_table_name,
            a.set_defining_column_name,
            a.UNIQUE_ID_COLUMN_NAME
       INTO l_app_table_name,
            l_set_def_col_name,
            l_uniq_col_id_name
       FROM fnd_id_flexs a
      WHERE a.application_id = appid
        AND a.id_flex_code   = code;

      IF (vdate = '0') THEN
        v_date := NULL;
      ELSE
        v_date := to_date(vdate, DATE_PASS_FORMAT);
      END IF;

    END SET_DYN_NAMES;

    PROCEDURE intLoad_segments AS
     l_rtn1 BOOLEAN;
     l_rtn2 BOOLEAN;
    BEGIN

      l_rtn1 := get_keystruct(appl_sname            => l_appl_name ,
                              flex_code             => code,
                              select_comb_from_view => NULL,
                              flex_num              => structid,
                              flex_struct           => l_flex_struct,
                              struct_info           => l_struct_info,
                              cctbl_info            => l_cctbl_info );

      l_rtn2 :=  get_struct_cols(fstruct    => l_flex_struct,
                               table_apid   => l_cctbl_info.table_application_id,
                               table_id     => l_cctbl_info.combination_table_id,
                               n_columns    => l_nsegments ,
                               cols         => l_cols,
                               coltypes     => l_coltypes,
                               seg_formats  => l_concat_vs_format);

      l_delim  := l_struct_info.concatenated_segment_delimiter ;

    END intLoad_segments;


   PROCEDURE BUILD_CVR_LH AS

   BEGIN
    -- Replace values of :CVR_LOW AND :CVR_HIGH if there are NOT null
    IF ( CVR_LOW IS NOT NULL AND CVR_HIGH IS NOT NULL) THEN
       L_TMP_CVR_DATA_R := REPLACE(
                              REPLACE(C_TKN_CVR_R,'XX', CVR_LOW ),
                              'YY',
                              CVR_HIGH
                              );
       L_TMP_CVR_DATA_L := REPLACE(
                              REPLACE(C_TKN_CVR_L,'XX', CVR_LOW ),
                              'YY',
                              CVR_HIGH
                              );
    END IF;
   END BUILD_CVR_LH;

   PROCEDURE BUILD_SEGMENTS_WHERE AS
    l_position_seg number;

    -- Remove the word SEGMENT from the string ( p_segname)
    -- and separated , then return only the number value
    FUNCTION infer_seg_position(p_segname VARCHAR2) RETURN NUMBER AS
      C_field_name CONSTANT VARCHAR2(30) := 'SEGMENT';
      l_temp1   VARCHAR2(30);
      l_rtn_num NUMBER;
    BEGIN
      -- Remove the word SEGMENT from the string
      -- and separate only the number
      l_temp1   := REPLACE( upper(p_segname), c_field_name);
      -- transform the result-string into NUMBER
      l_rtn_num := to_number(l_temp1);
      RETURN(l_rtn_num);
    EXCEPTION
      WHEN OTHERS THEN
        RETURN(-1);
    END infer_seg_position;


   BEGIN
    FOR i IN 1 .. l_nsegments LOOP
      l_position_seg := infer_seg_position( l_cols(i) ); -- position Hierarchy
      -- Check posstion segment
      IF l_position_seg > 0 THEN
        segtypes.vs_format(i)  := l_concat_vs_format.vs_format(i);
        segtypes.vs_maxsize(i) := l_concat_vs_format.vs_maxsize(i);
        l_max_segs_len         := l_max_segs_len + l_concat_vs_format.vs_maxsize(i) + 1;

        l_dyn_totseg  := l_dyn_totseg ||
                         'g.segment'|| l_position_seg || ' ||'''|| l_delim || '''||';

        l_dyn_eachseg := l_dyn_eachseg ||
                         'g.segment'|| l_position_seg || ' ,';

        -- Generates LOW and HIGH values base on : type, position and maximum-size
        --
        Loc_low_high_rpl ( i,                -- position array
                           segtypes.vs_format(i),   -- type field
                           segtypes.vs_maxsize(i)  ,  -- maximum size
                           l_dyn_lows  ,
                           l_dyn_highs
                         );

        -- Generates BETWEEN condition base on: position, maximum-size and type
        --
        l_dyn_LowsHighs := l_dyn_LowsHighs ||
                            LOC_TNK_RPL( l_position_seg ,      -- position Hierarchy
                                         i,                    -- position array
                                         segtypes.vs_maxsize(i)  , -- maximum size
                                         segtypes.vs_format(i)        -- type field
                                       );

        /*
        -- Print Debug
        printl('dbg: segs('||i||') =>'|| segs(i) );
        printl('dbg: segtypes.vs_format('||i||') =>'|| segtypes.vs_format(i) );
        printl('dbg: segtypes.vs_maxsize('||i||') =>'|| segtypes.vs_maxsize(i) );
        */
      END IF; -- end check position_segment

    END LOOP;
    segtypes.nsegs := l_nsegments;

   END BUILD_SEGMENTS_WHERE;


   PROCEDURE intClean_up AS

   BEGIN
    -- cleanup meta-data of dyn-select
    l_dyn_totseg  := rtrim(l_dyn_totseg , ' ||'''|| l_delim || '''||') || ' v_segments, ';
    l_dyn_eachseg := rtrim(l_dyn_eachseg, ',' );
    l_dyn_highs   := rtrim(l_dyn_highs, ',' );

   END intClean_up;

   PROCEDURE intBldDate_mask as

   BEGIN
    l_userDT_mask := fnd_date.userDT_mask;
    -- printl('DBG: fnd_date.userDT_mask [ '|| l_userDT_mask ||' ]');

    -- Date transformation from varchar2 to date in the Dyn-sql string
    l_tmp_date := to_date( nvl(v_date, sysdate) , l_userDT_mask ) ;
    l_tmp_date_str := ' to_date(''' ||
                  to_char( l_tmp_date , l_userDT_mask )  ||
                  ''' ,''' || l_userDT_mask ||''' ) vdate, ';
    -- printl('DBG: l_tmp_date_str [ '|| l_tmp_date_str ||' ]');
   END intBldDate_mask;

   PROCEDURE build_ccid AS

   BEGIN
     IF ( minccid is not null AND maxccid is not NULL ) THEN
        l_ccid_flt_tmp  := replace(
                             replace (
                                 replace( C_tkn_ccid_filt1 ,
                                          'XX',
                                          l_uniq_col_id_name
                                         ),
                                     'YY',
                                     minccid
                                      ),
                                  'ZZ',
                                   maxccid
                                  );

        ol('DBG: build_ccid - l_uniq_col_id_name [ ' || l_uniq_col_id_name ||' ]');

     END IF;

     ol('DBG: build_ccid - l_ccid_flt_tmp     [ ' || l_ccid_flt_tmp ||' ]');

   END build_ccid;

   PROCEDURE intKey_binds AS
     l_flt_flex_join varchar2(200);
   BEGIN
     -- Dynamic calculate the  JOIN condition with  M.p_flex_num
     l_flt_flex_join  := 'AND G.'|| l_set_def_col_name ||' = M.p_flex_num ';

     IF l_ccid_flt_tmp IS NULL THEN
        l_key_binds  := ' :1 p_appl, '
                     || ' :2 p_flex_code, '
                     || ' :3 p_flex_num , ';
        --
        -- The CCID is assign inside bld_main_dynQuery
        -- so this varaible can be used to link the values
        --
        l_ccid_flt_tmp := l_flt_flex_join ;

        l_use_key_binds := TRUE;

     ELSE
        l_key_binds  := ' '|| appid    || ' p_appl, '
                     || ' '''|| code   || ''' p_flex_code, '
                     || ' '|| structid || ' p_flex_num , ';

        --
        -- the l_ccid_flt_tmp is not NULL then
        -- first add the JOIN-variable l_flt_flex_join and concatenate it with the ccid-filter
        --
        l_ccid_flt_tmp := l_flt_flex_join || l_ccid_flt_tmp;

     END IF;

   END intKey_binds;

   PROCEDURE intSet_Flags AS
   BEGIN
     /*
     ol('. ');
     ol('DBG: intSet_Flags ');
     */

     l_tmp_date_fltr1 := NULL;
     IF enddate = 'N' THEN
       -- ol('DBG: condition 1 => TRUE ');
       l_tmp_date_fltr1 := C_tkn_date_filt1;
     END IF;

     --
     -- Process flags to build the where-clause of
     -- the SELECT-command to DISPLAY rows
     --
     l_tmp_summary := NULL;
     IF ( summary = 'Y' AND nonsummary = 'Y' ) THEN
        -- ol('DBG: condition 2 => TRUE ');
        l_tmp_summary :=  NULL;
     END IF;

     IF ( summary = 'N' AND nonsummary = 'Y' ) THEN
        -- ol('DBG: condition 3 => TRUE ');
        l_tmp_summary :=  C_tkn_sumflg_N;
     END IF;

     IF ( summary = 'Y' AND nonsummary = 'N' ) THEN
        -- ol('DBG: condition 4 => TRUE ');
        l_tmp_summary :=  C_tkn_sumflg_Y;
     END IF;

     /*
     ol('DBG: l_tmp_date_fltr1 = [ '|| l_tmp_date_fltr1 || ' ]');
     ol('DBG: l_tmp_summary = [ '|| l_tmp_summary || ' ]');
     ol('. ');
     */

   END intSet_Flags;

   FUNCTION check_flags_validate RETURN BOOLEAN AS
     l_rtn boolean := TRUE;

    -- Evaluate values for l_tmp_summary as
    -- C_tkn_sumflg_Y  'AND G.SUMMARY_FLAG = ''Y'' ';
    -- C_tkn_sumflg_N  'AND G.SUMMARY_FLAG = ''N'' ';

    -- Evaluate values for l_tmp_EnaFlg as
    -- C_tkn_Enaflg_Y  'AND G.ENABLE_FLAG = ''Y'' ';
    -- C_tkn_Enaflg_N  'AND G.ENABLE_FLAG = ''N'' ';

   BEGIN
      /*
      ol('. ');
      ol('DBG: check_flags_validate ');
      */

      -- Check for invalid Flag combinations
      IF  ( summary = 'N' AND nonsummary = 'N' ) THEN
         -- Error can not have an "n" "n" case
         printl('Error: Combination summary = N AND nonsummary = N !!! ');
         printl('Error: Exit Report');
         RETURN(FALSE);
      END IF;

      --
      -- Process flags to build the where-clause of
      -- the UPDATE-command for procedure int_upd_cmbtb
      --

      l_upd_flag        := FALSE;
      l_tmp_upd_summary := NULL;

      If ( disnonsummary = 'Y' and dissummary = 'Y' ) then
        -- ol('DBG: condition 1 - TRUE ');
        l_upd_flag    := TRUE;
      elsif (disnonsummary = 'Y' and dissummary = 'N' ) then
        -- ol('DBG: condition 2 - TRUE ');
        l_upd_flag    := TRUE;
        l_tmp_upd_summary :=  C_tkn_upd_sumflg_not_Y ;
      elsif (disnonsummary = 'N' and dissummary = 'Y' ) then
        -- ol('DBG: condition 3 - TRUE ');
        l_upd_flag    := TRUE;
        l_tmp_upd_summary :=  C_tkn_upd_sumflg_Y ;
      elsif (disnonsummary = 'N' and dissummary = 'N' ) then
        -- ol('DBG: condition 4 - TRUE ');
        l_upd_flag    := FALSE;
      END IF;

      /*
      IF ( l_upd_flag = TRUE ) THEN
         ol('DBG: l_upd_flag = [ TRUE ]');
      ELSE
         ol('DBG: l_upd_flag = [ FALSE ]');
      END IF;
      ol('DBG: l_tmp_upd_summary = [ '|| l_tmp_upd_summary || ' ]');

      ol('. ');
      */

      RETURN l_rtn;
   END check_flags_validate;

   --
   -- Build Main Dynamic QUERY
   --
   PROCEDURE bld_main_dynQUERY AS
   BEGIN

l_sql_dyn  :=
    'WITH '
  || 'C_main AS '
  || '( '
  ||  'SELECT /* QID_FLEXGL_V1 */ '
  ||  l_key_binds
  ||  l_tmp_date_str ||' '
  ||    l_dyn_lows
  ||    l_dyn_highs || ' '
  || 'FROM dual '
  || '), '
  ||  'DYN_COMB AS '
  ||  '( '
  ||    'SELECT g.rowid ROWID_G, '
  ||           'g.'|| l_uniq_col_id_name || ' CCID, '
  ||           'g.'|| l_uniq_col_id_name || ' , '
  ||           'g.'|| l_set_def_col_name || ' , '
  || l_dyn_totseg  || ' '
  || l_dyn_eachseg || ' '
  ||      'FROM C_main M, '
  ||           l_app_table_name || ' G '
  ||     'WHERE 1=1 ' || l_ccid_flt_tmp
  ||       'AND G.ENABLED_FLAG = ''Y'' '
  ||       l_tmp_summary
  ||       l_tmp_date_fltr1
  ||  '), '
  ||'process_rem AS '
  ||  '( SELECT /*+ PARALLEL PQ_DISTRIBUTE(DYN_COMB BROADCAST, NONE) USE_HASH(DYN_COMB) QID_FLEXGL_V1S3 */ '
  ||           'G.ROWID_G ROWID_D, R.FLEX_VALIDATION_RULE_NAME '
  ||      'FROM C_main M, '
  ||           'FND_FLEX_VALIDATION_RULES R, '
  ||           'FND_FLEX_EXCLUDE_RULE_LINES L, '
  ||           'DYN_COMB                    G '
  ||     'WHERE R.APPLICATION_ID = M.p_appl '
  ||       'AND R.ID_FLEX_CODE   = M.p_flex_code '
  ||       'AND R.ID_FLEX_NUM    = M.p_flex_num '
  ||       'AND R.ENABLED_FLAG   = ''Y'' '
  ||       l_dyn_LowsHighs || ' '
  ||       'AND L.APPLICATION_ID = M.p_appl '
  ||       'AND L.ID_FLEX_CODE   = M.p_flex_code '
  ||       'AND L.ID_FLEX_NUM    = M.p_flex_num '
  ||       'AND L.ENABLED_FLAG   = ''Y'' '
  ||       'AND L.FLEX_VALIDATION_RULE_NAME = R.FLEX_VALIDATION_RULE_NAME '
  ||       l_ccid_flt_tmp
  ||       L_TMP_CVR_DATA_L
  ||  '), '
  || 'DYN_COMB_X AS '
  ||  '(SELECT A.* '
  ||     'FROM DYN_COMB A '
  ||    'WHERE NOT EXISTS ( '
  ||             'SELECT 1 '
  ||               'FROM PROCESS_REM DEL '
  ||              'WHERE DEL.ROWID_D = A.ROWID_G '
  ||                    ') '
  ||   '), '
  ||'process_det AS '
  ||  '( SELECT /*+ PARALLEL PQ_DISTRIBUTE(DYN_COMB_X BROADCAST, NONE) USE_HASH(DYN_COMB_X) QID_FLEXGL_V1S1 */ '
  ||           'G.ROWID_G ROWID_D, '
  ||           'R.FLEX_VALIDATION_RULE_NAME '
  ||      'FROM C_main M, '
  ||           'FND_FLEX_VALIDATION_RULES R, '
  ||           'DYN_COMB_X G '
  ||     'WHERE R.APPLICATION_ID = M.p_appl '
  ||       'AND R.ID_FLEX_CODE   = M.p_flex_code '
  ||       'AND R.ID_FLEX_NUM    = M.p_flex_num '
  ||       'AND R.ENABLED_FLAG = ''Y'' '
  ||       l_ccid_flt_tmp
  ||       'AND ((M.VDATE IS NULL) OR '
  ||            '((R.START_DATE_ACTIVE IS NULL OR R.START_DATE_ACTIVE <= M.VDATE) '
  ||            'AND '
  ||            '(R.END_DATE_ACTIVE IS NULL OR R.END_DATE_ACTIVE >= M.VDATE)) '
  ||           ') '
  ||       L_TMP_CVR_DATA_R
  ||    'MINUS '
  ||    'SELECT /*+ PARALLEL PQ_DISTRIBUTE(DYN_COMB_X BROADCAST, NONE) USE_HASH(DYN_COMB_X) QID_FLEXGL_V1S2 */ '
  ||           'G.ROWID_G ROWID_D, '
  ||           'L.FLEX_VALIDATION_RULE_NAME '
  ||      'FROM C_main M, '
  ||           'FND_FLEX_INCLUDE_RULE_LINES L, '
  ||           'DYN_COMB_X G '
  ||     'WHERE 1=1 '
  ||       l_dyn_LowsHighs || ' '
  ||       'AND L.APPLICATION_ID = M.p_appl '
  ||       'AND L.ID_FLEX_CODE   = M.p_flex_code '
  ||       'AND L.ID_FLEX_NUM    = M.p_flex_num '
  ||       'AND L.ENABLED_FLAG = ''Y'' '
  ||       l_ccid_flt_tmp
  ||       L_TMP_CVR_DATA_L
  ||  ') '
  ||  'SELECT A.* FROM ( '
  ||'SELECT '
  ||       'G.CCID , '
  ||       'G.v_segments , '
  ||       'G.rowid_g , '
  ||       'del.FLEX_VALIDATION_RULE_NAME, '
  ||       'E.error_message_text, '
  ||       'E.error_segment_column_name '
  ||  'FROM C_main M, '
  ||       'DYN_COMB G, '
  ||       'process_rem del, '
  ||       'fnd_flex_vdation_rules_vl E '
  ||  'WHERE 1=1 ' || l_ccid_flt_tmp
  ||    'AND del.ROWID_D = G.ROWID_G  '
  ||    'AND E.APPLICATION_ID = M.p_appl '
  ||    'AND E.ID_FLEX_CODE   = M.p_flex_code '
  ||    'AND E.ID_FLEX_NUM    = M.p_flex_num '
  ||    'AND E.FLEX_VALIDATION_RULE_NAME  = del.FLEX_VALIDATION_RULE_NAME '
  ||    'AND E.ENABLED_FLAG   = ''Y'' '
  || 'UNION '
  ||'SELECT '
  ||       'G.CCID , '
  ||       'G.v_segments , '
  ||       'G.rowid_g , '
  ||       'dat.FLEX_VALIDATION_RULE_NAME, '
  ||       'E.error_message_text, '
  ||       'E.error_segment_column_name '
  ||  'FROM C_main M, '
  ||       'DYN_COMB_X G, '
  ||       'process_det dat, '
  ||       'fnd_flex_vdation_rules_vl E '
  ||  'WHERE 1=1 ' || l_ccid_flt_tmp
  ||    'AND dat.ROWID_D = G.ROWID_G  '
  ||    'AND E.APPLICATION_ID = M.p_appl '
  ||    'AND E.ID_FLEX_CODE   = M.p_flex_code '
  ||    'AND E.ID_FLEX_NUM    = M.p_flex_num '
  ||    'AND E.FLEX_VALIDATION_RULE_NAME  = DAT.FLEX_VALIDATION_RULE_NAME '
  ||    'AND E.ENABLED_FLAG   = ''Y'' '
  ||  ') A ORDER BY A.CCID, A.V_SEGMENTS '
  ;

   END bld_main_dynQUERY;

   PROCEDURE read_names AS
   BEGIN
     SELECT fa.APPLICATION_NAME ,
            flexs.ID_FLEX_STRUCTURE_NAME ,
            iflex.ID_FLEX_NAME
       into l_APPLICATION_NAME        ,
            l_ID_FLEX_STRUCTURE_NAME  ,
            l_ID_FLEX_NAME
       from FND_APPLICATION_TL        fa,
            fnd_id_flex_structures_tl flexs,
            fnd_id_flexs              iflex
      WHERE fa.APPLICATION_ID     = appid
        and fa.LANGUAGE           = USERENV('LANG')
        AND flexs.APPLICATION_ID  = fa.APPLICATION_ID
        and flexs.ID_FLEX_CODE    = code
        and flexs.ID_FLEX_NUM     = structid
        and flexs.LANGUAGE        = fa.LANGUAGE
        AND iflex.application_id  = fa.APPLICATION_ID
        and iflex.ID_FLEX_CODE    = flexs.ID_FLEX_CODE
        AND ROWNUM < 2;

/* Translate Heading
     select FORM_LEFT_PROMPT into appl_prompt from fnd_descr_flex_col_usage_vl
     where APPLICATION_ID=0 and DESCRIPTIVE_FLEXFIELD_NAME='$SRS$.FNDCVR'
     and END_USER_COLUMN_NAME='Appl_id';

     select FORM_LEFT_PROMPT into flex_code_prompt from fnd_descr_flex_col_usage_vl
     where APPLICATION_ID=0 and DESCRIPTIVE_FLEXFIELD_NAME='$SRS$.FNDCVR'
     and END_USER_COLUMN_NAME='Flex_code';

     select FORM_LEFT_PROMPT into flex_struct_prompt from fnd_descr_flex_col_usage_vl
     where APPLICATION_ID=0 and DESCRIPTIVE_FLEXFIELD_NAME='$SRS$.FNDCVR'
     and END_USER_COLUMN_NAME='Flex_struct';

     select FORM_LEFT_PROMPT into cvr_from_prompt from fnd_descr_flex_col_usage_vl
     where APPLICATION_ID=0 and DESCRIPTIVE_FLEXFIELD_NAME='$SRS$.FNDCVR'
     and END_USER_COLUMN_NAME='Cross_Validation_Rule_From';

     select FORM_LEFT_PROMPT into cvr_to_prompt from fnd_descr_flex_col_usage_vl
     where APPLICATION_ID=0 and DESCRIPTIVE_FLEXFIELD_NAME='$SRS$.FNDCVR'
     and END_USER_COLUMN_NAME='Cross_Validation_Rule_To';
*/


   EXCEPTION
     WHEN OTHERS THEN
       l_APPLICATION_NAME        := 'n/a';
       l_ID_FLEX_STRUCTURE_NAME  := 'n/a';
       l_ID_FLEX_NAME            := 'n/a';
   END read_names;

   PROCEDURE Rpt_print_header AS

   BEGIN

     READ_NAMES;

/* Translate Heading
     printl('----------------------------------------------------------------------------------------------------');
     printl(appl_prompt || ': ' || l_application_name);
     printl(flex_code_prompt || ': ' || l_id_flex_name);
     printl(flex_struct_prompt || ': ' || l_id_flex_structure_name);
     if ( cvr_low is NULL or cvr_high is NULL) then
       printl( cvr_from_prompt || ': ( ALL )' );
     else
       printl(cvr_from_prompt || ': ' || cvr_low);
       printl(cvr_to_prompt || ': ' || cvr_high);
     end if;

     IF ( minccid is not null AND maxccid is not NULL ) THEN
     ccid_prompt := fnd_message.get_string('FND', 'FND_CCID');
     --   (use instead of seach range ccid_prompt instead of Search Range for Translate)
     -- printl(ccid_prompt | '             : [ ' || minccid || ' - ' || maxccid ||' ]' );
        printl(' Search Range             : [ ' || minccid || ' to ' || maxccid ||' ]' );
     END IF;
     date_heading := fnd_message.get_string('FND', 'DATE');
     printl(date_heading || ': ' || TO_CHAR(SYSDATE, 'MON-DD-YYYY / HH24:MI:SS'));

     -- Need to create a new message called CVR2-REPORT-HEADER with proper arranged heading
     cvr_heading := fnd_message.get_string('FND', 'CVR-REPORT-HEADER');
*/

     printl('----------------------------------------------------------------------------------------------------');
     printl(' Application Name         : [ ' || l_application_name || ' ]' );
     printl(' Flexfield Name           : [ ' || l_id_flex_name || ' ]' );
     printl(' Flexfield Structure Name : [ ' || l_id_flex_structure_name || ' ]' );
     if ( cvr_low is NULL or cvr_high is NULL) then
       printl(' CVR Name Range           : [ ALL ]' );
     else
       printl(' CVR Name Range           : [ (' || cvr_low || ') to (' || cvr_high  || ') ]' );
     end if;

     IF ( minccid is not null AND maxccid is not NULL ) THEN
        printl(' Search Range             : [ ' || minccid || ' to ' || maxccid ||' ]' );
     END IF;
     printl(' Date/Time                : [ ' || TO_CHAR(SYSDATE, 'MON-DD-YYYY / HH24:MI:SS') ||' ]' );

     -- ol('DBG: start after OPEN ... m3 ');

     printl('---------------'|| rpad('-' , l_max_segs_len,'-')  ||'-----------------------------------------------');
     -- printl('----------------------------------------------------------------------------------------------------');
     -- Tranlate Headeing, Heading should not be hard coded.
     -- printl(cvr_heading);
     printl('     CCID      '|| rpad('Concatenated Segment Values' ,l_max_segs_len,' ')  ||' Error Message Text  ');
     -- printl('     CCID  Error Message Text                  Concatenated Segment Values     ');
--           1234567890 12345678901234567890123456789012345 123456789012345678901234567890123456789012345678901234567890
     printl('---------------'|| rpad('-' , l_max_segs_len,'-')  ||'-----------------------------------------------');

   END Rpt_print_header;


   PROCEDURE Rpt_open_dyncursor AS
   BEGIN
     -- Open CURSOR CV
     IF l_use_key_binds = TRUE THEN
        /*
        printl('DBG: cvr_report_segs - Cursor version 1 - with binds ...');
        printl('DBG: cvr_report_segs - appid[ ' || appid ||' ]');
        printl('DBG: cvr_report_segs - code[ ' || code ||' ]');
        printl('DBG: cvr_report_segs - structid[ ' || structid ||' ]');
        printl('DBG: cvr_report_segs - l_sql_dyn[ ' || l_sql_dyn ||' ]');
        printl('.');
        */
        OPEN CV FOR l_sql_dyn USING IN appid, IN code, IN structid;
     ELSE
        /*
        printl('DBG: cvr_report_segs - Cursor version 2 - no binds ...');
        printl('DBG: cvr_report_segs - l_sql_dyn[ ' || l_sql_dyn ||' ]');
        printl('.');
        */
        OPEN CV FOR l_sql_dyn;
     END IF;

     -- ol('DBG: start after OPEN ... m1 ');

     l_cnt := 0;
     -- ol('DBG: start after OPEN ... m2 ');

     loc_initime := DBMS_UTILITY.get_time;

     -- ol('DBG: end header');

   EXCEPTION
    WHEN OTHERS THEN
      IF (CV%ISOPEN) THEN
        CLOSE CV;
      END IF;
      /*
      ol('DBG: Header - Exist ERROR ...');
      ol('Error code    :' || sqlcode);
      ol('Error message :' || sqlerrm , 80);
      */
   END Rpt_open_dyncursor;

   PROCEDURE Rpt_print_body AS
   BEGIN

     -- ol('DBG: start-body');

     LOOP

       FETCH cv bulk collect
         into t_glcomb LIMIT lim_rec;

       -- ol('DBG: Fetch ROWS: .... ' || t_glcomb.count );

       exit when t_glcomb.count < 1 ;

       for i in t_glcomb.FIRST .. t_glcomb.LAST LOOP

          l_cnt := l_cnt + 1;

          printl(
                  lpad(t_glcomb(i).ccid         ,10,' ') || '     ' ||
                  rpad(substr(t_glcomb(i).concat_segs , 1,l_max_segs_len) ,l_max_segs_len,' ')  ||
                  ' ' ||
                  rpad(substr(t_glcomb(i).errmesg_det ,1,35) ,35,' ')
                );

       end LOOP i;

       -- Update TABLE if the FLAG is set to TRUE
       --
       IF ( l_upd_flag = TRUE ) THEN
              int_upd_cmbtbl ( p_tbl_name    => l_app_table_name,
                               p_tbl_process => t_glcomb  );
       END IF;

     END LOOP;

     -- ol('DBG: end-body');

   EXCEPTION
    WHEN OTHERS THEN
      IF (CV%ISOPEN) THEN
        CLOSE CV;
      END IF;
     /*
     ol('DBG: body - Exist ERROR ...');
     ol('Error code    :' || sqlcode);
     ol('Error message :' || sqlerrm , 80);
     */

   END Rpt_print_body;

   PROCEDURE Rpt_print_footer AS
   BEGIN
     -- CLOSE cursor CV
     IF (CV%ISOPEN) THEN
        CLOSE CV;
     END IF;
     loc_tottime := DBMS_UTILITY.get_time - loc_initime;

     printl('----------------------------------------------------------------------------------------------------');
     printl('  Total Cross Validation Rule Violations: [ ' || l_cnt || ' ]');
     printl('----------------------------------------------------------------------------------------------------');
--     printl('.');
--     printl('  .... Total Elapse time => [ ' || loc_tottime || ' ]');
--     printl('  End => Date/time: ' || TO_CHAR(SYSDATE, 'MON-DD-YYYY / HH24:MI:SS'));
--     printl('-------------------------------------');

--     printl('=== END REPORT === ');

      IF utl_file.is_open( fnd_flex_server2.file_print_rpt ) THEN
         utl_file.fclose( fnd_flex_server2.file_print_rpt );
      END IF;

   EXCEPTION
    WHEN OTHERS THEN
      IF (CV%ISOPEN) THEN
        CLOSE CV;
      END IF;
      IF utl_file.is_open( fnd_flex_server2.file_print_rpt ) THEN
         utl_file.fclose( fnd_flex_server2.file_print_rpt );
      END IF;
      /*
      ol('DBG: footer - Exist ERROR ...');
      ol('Error code    :' || sqlcode);
      ol('Error message :' || sqlerrm , 80);
      */

   END Rpt_print_footer;

  BEGIN

    -- Print input parameters if debug activated
    print_params;

    INIT;

    SET_DYN_NAMES;

    intLoad_segments;

    -- Replace values of :CVR_LOW AND :CVR_HIGH if there are NOT null
    BUILD_CVR_LH;

    BUILD_SEGMENTS_WHERE;

    -- printl('DBG: l_dyn_LowsHighs [ '|| l_dyn_LowsHighs ||' ]');

    -- cleanup meta-data of dyn-select
    intClean_up;

    -- Build Internal Date Mask
    intBldDate_mask;

    -- Generates a filter base on CCID min and max
    -- something like :
    --   and code_combination_id between minccid and maxccid
    --
    BUILD_CCID;

    -- Genrate bind Keys
    intKey_binds;

    -- Set internal flags
    intSet_Flags;

    IF check_flags_validate() = FALSE THEN
       -- EXIT error
       RETURN;
    END IF;

    --
    -- Call -> Build Main Dynamic QUERY
    --
    bld_main_dynQUERY;

    Rpt_print_header;

    Rpt_open_dyncursor;

    Rpt_print_body;

    Rpt_print_footer;

  EXCEPTION
    WHEN OTHERS THEN

      IF CV%ISOPEN THEN
        CLOSE CV;
      END IF;

      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE',
                            'cross_validate_report.cvr_report_segs:Exit-Err');
      fnd_message.set_token('ERRNO', SQLCODE);
      fnd_message.set_token('REASON', SQLERRM);

      errbuf := SQLERRM;
      retcode := SQLCODE;

  END cvr_report_segs;


/* ----------------------------------------------------------------------- */
/* Bug 23601325,  Routine to process cvr report in parallel                */
/* ----------------------------------------------------------------------- */
-- ======================================================================
-- This procedure submits parallel processes for cvr_report which
-- generates the Cross Validatoin rule violation report.
-- ======================================================================
PROCEDURE cvr_report_parallel(p_application_id  IN NUMBER,
                              p_id_flex_code      IN VARCHAR2,
                              p_id_flex_num       IN NUMBER,
                              p_show_non_sum_comb IN VARCHAR2 DEFAULT 'Y',
                              p_dis_non_sum_comb  IN VARCHAR2 DEFAULT 'N',
                              p_show_sum_comb     IN VARCHAR2 DEFAULT 'Y',
                              p_dis_sum_comb      IN VARCHAR2 DEFAULT 'N',
                              p_enddate_flag      IN VARCHAR2 DEFAULT NULL,
                              p_cvr_name_low      IN VARCHAR2 DEFAULT NULL,
                              p_cvr_name_high     IN VARCHAR2 DEFAULT NULL,
                              p_num_workers       IN NUMBER,
                              p_errbuf            OUT nocopy VARCHAR2,
                              p_retcode           OUT nocopy VARCHAR2)
  IS
     ----------------------
     -- Local definitions -
     ----------------------
     l_request_id          NUMBER;
     l_sub_request_id      NUMBER;
     l_request_count       NUMBER :=0;
     i                     NUMBER;
     l_min_ccid            NUMBER;
     l_max_ccid            NUMBER;
     l_total_ccid          NUMBER;
     l_min_ccid_range      NUMBER;
     l_max_ccid_range      NUMBER;
     l_batch_size          NUMBER;
     l_num_workers         NUMBER := 0;
     l_normal_count        NUMBER := 0;
     l_warning_count       NUMBER := 0;
     l_error_count         NUMBER := 0;
     l_request_data        VARCHAR2(100);
     l_action_message      VARCHAR2(200);
     l_sub_program         VARCHAR2(30);
     l_sub_description     VARCHAR2(100);
     l_ccid_partition_sql  VARCHAR2(1000);
     l_max_ccid_range_sql  VARCHAR2(1000);
     l_set_def_col_name    VARCHAR2(30);
     l_unique_id_col_name  VARCHAR2(30);
     l_app_table_name      VARCHAR2(30);
     l_cp_appl_name        VARCHAR2(30);
     l_sub_requests        fnd_concurrent.requests_tab_type;
     TYPE cursor_type IS REF CURSOR;
     l_ccid_partition_cur  cursor_type;
     l_max_ccid_range_cur  cursor_type;


  BEGIN

   ------------------------------------------------
   -- Defining values for the sumbit request call -
   ------------------------------------------------
   l_cp_appl_name := 'FND';
   l_sub_program := 'FNDCVRP';
   l_sub_description := 'Cross-Validation Rule Violation Report';

   ------------------------------------------------------------
   -- Select the information needed to partition the CC table -
   ------------------------------------------------------------
   SELECT
   application_table_name,
   set_defining_column_name,
   unique_id_column_name
   INTO
   l_app_table_name,
   l_set_def_col_name,
   l_unique_id_col_name
   FROM
   fnd_id_flexs
   WHERE
   application_id = p_application_id and
   id_flex_code = p_id_flex_code;

   -- Some KFF's do not have a Structure Column. For
   -- those KFF's they are hard coded to 101.
   -- Will set l_set_def_col_name=101 so that the sql
   -- below will not be mal formed.
   IF (l_set_def_col_name is null) THEN
       l_set_def_col_name := 101;
   END IF;

   --
   --  select count(*) total_ccid,
   --         min(code_combination_id) min_ccid,
   --         max(code_combination_id) max_ccid
   --  from gl_code_combinations
   --  where chart_of_accounts_id = 101;
   --
   l_ccid_partition_sql :=
     ('SELECT /* $Header: AFFFSV2B.pls 120.2.12010000.14 2017/02/10 21:01:55 hgeorgi ship $ */ ' ||
      ' COUNT(*), ' ||
      ' MIN('   || l_unique_id_col_name || '), ' ||
      ' MAX('   || l_unique_id_col_name || ')'   ||
      ' FROM '  || l_app_table_name     ||
      ' WHERE ' || l_set_def_col_name   || '= :b_id_flex_num' ||
      ' AND enabled_flag = ''Y'' ');

   l_request_id := fnd_global.conc_request_id;
   l_request_data := fnd_conc_global.request_data;

   cp_debug('DEBUG: Request Id   : ' || l_request_id);
   cp_debug('DEBUG: Request Data : ' || l_request_data);
   cp_debug(' ');

   IF (l_request_data IS NULL) THEN
      --
      -- Print the header.
      --
      cp_debug(Lpad('Request ID', 10) || ' ' ||
               Rpad('Cross-Validation Rule Violation Report', 60));
      cp_debug(Lpad('-',10, '-') || ' ' ||
               Rpad('-',60, '-'));

      BEGIN

         OPEN l_ccid_partition_cur FOR l_ccid_partition_sql USING p_id_flex_num;
         l_request_count := 0;

         FETCH l_ccid_partition_cur INTO l_total_ccid, l_min_ccid, l_max_ccid;

         CLOSE l_ccid_partition_cur;


         --------------------------------------
         -- Initialize partitioning variables -
         --------------------------------------
         i := 0;
         l_num_workers    := p_num_workers;
         -- If more workers than ccid's, then set
         -- number of workers to number of ccid's
         if(l_total_ccid < l_num_workers) then
            l_num_workers := l_total_ccid;
         end if;

         -- Set l_num_workers to 1 if user enters 0 or less
         IF (l_num_workers <= 1) THEN
             l_num_workers :=1;

         END IF;

         l_batch_size := (trunc((l_total_ccid)/l_num_workers ));
         l_min_ccid_range  := l_min_ccid;

            -- SELECT
            -- MAX(code_combination_id)
            -- FROM
            --     (SELECT code_combination_id
            --      FROM gl_code_combinations
            --      WHERE chart_of_accounts_id = 101
            --      AND enabled_flag = 'Y'
            --      AND code_combination_id >= l_min_ccid_range
            --      ORDER BY code_combination_id)
            -- where rownum <= BATCH_SIZE

        l_max_ccid_range_sql :=
        ('SELECT /* $Header: AFFFSV2B.pls 120.2.12010000.14 2017/02/10 21:01:55 hgeorgi ship $ */ ' ||
       ' MAX(' || l_unique_id_col_name || ')' ||
       ' FROM'  ||
          ' (SELECT '  || l_unique_id_col_name ||
          ' FROM ' ||     l_app_table_name     ||
          ' WHERE ' || l_set_def_col_name || '= :b_id_flex_num' ||
          ' AND enabled_flag = ''Y'' ' ||
          ' AND ' || l_unique_id_col_name || '>= :b_l_min_ccid_range' ||
          ' ORDER BY ' || l_unique_id_col_name || ')' ||
       ' WHERE rownum <= :b_batch_size');

         l_request_count := 0;

         FOR i in 1..l_num_workers LOOP

              -- Last worker should get the max ccid
              IF (i = l_num_workers) THEN
                  l_max_ccid_range := l_max_ccid;
              ELSE
                  OPEN l_max_ccid_range_cur FOR l_max_ccid_range_sql
                     USING p_id_flex_num, l_min_ccid_range, l_batch_size;
                  FETCH l_max_ccid_range_cur INTO l_max_ccid_range;
                  CLOSE l_max_ccid_range_cur;
              END IF;

              l_request_count := l_request_count + 1;
              commit;

              l_sub_request_id := fnd_request.submit_request
                 (application => l_cp_appl_name,
                  program     => l_sub_program,
                  description => l_sub_description,
                  start_time  => NULL,
                  sub_request => TRUE,
                  argument1   => p_application_id,
                  argument2   => p_id_flex_code,
                  argument3   => p_id_flex_num,
                  argument4   => p_show_non_sum_comb,
                  argument5   => p_dis_non_sum_comb,
                  argument6   => p_show_sum_comb,
                  argument7   => p_dis_sum_comb,
                  argument8   => p_enddate_flag,
                  argument9   => p_cvr_name_low,
                  argument10  => p_cvr_name_high,
                  argument11  => '0',
                  argument12  => l_min_ccid_range,
                  argument13  => l_max_ccid_range);

              l_min_ccid_range := l_max_ccid_range + 1;

              cp_debug(Lpad(l_sub_request_id, 10) || ' ' ||
                       Rpad(l_sub_program, 60));

              IF (l_sub_request_id = 0) THEN
                 null;
                 cp_debug('ERROR   : Unable to submit sub request.');
                 cp_debug('MESSAGE : ' || fnd_message.get);
              END IF;
           END LOOP;

      END;

      l_request_count := Nvl(l_request_count, 0);

      fnd_conc_global.set_req_globals(conc_status  => 'PAUSED',
                                      request_data => To_char(l_request_count));

      p_errbuf := l_request_count || ' sub request(s) submitted.';
      cp_debug(' ');
      cp_debug(p_errbuf);
      cp_debug(' ');
      p_retcode := 0;
      RETURN;
    ELSE
      l_request_count := To_number(l_request_data);

      cp_debug(l_request_count || ' sub request(s) completed.');
      --
      -- Print the header.
      --
      cp_debug(' ');
      cp_debug('Status Report');
      cp_debug(Rpad('-',72,'-'));
      cp_debug(Lpad('Request ID', 10) || ' ' ||
               Rpad('Status', 10) || ' ' ||
               Rpad('Action', 50));
      cp_debug(Lpad('-',10, '-') || ' ' ||
               Lpad('-',10, '-') || ' ' ||
               Lpad('-',50, '-'));

      l_sub_requests := fnd_concurrent.get_sub_requests(l_request_id);
      i := l_sub_requests.first;
      WHILE i IS NOT NULL LOOP
         IF (l_sub_requests(i).dev_status = 'NORMAL') THEN
            l_normal_count := l_normal_count + 1;
            l_action_message := 'Completed successfully.';
          ELSIF (l_sub_requests(i).dev_status = 'WARNING') THEN
            l_warning_count := l_warning_count + 1;
            l_action_message := 'Warnings reported, please see the sub-request log file.';
          ELSIF (l_sub_requests(i).dev_status = 'ERROR') THEN
            l_error_count := l_error_count + 1;
            l_action_message := 'Errors reported, please see the sub-request log file.';
          ELSE
            l_error_count := l_error_count + 1;
            l_action_message := 'Unknown status reported, please see the sub-request log file.';
         END IF;
         cp_debug(Lpad(l_sub_requests(i).request_id, 10) || ' ' ||
                  Rpad(l_sub_requests(i).dev_status, 10) || ' ' ||
                  l_action_message);
         i := l_sub_requests.next(i);
      END LOOP;

      cp_debug(' ');
      cp_debug('Summary Report');
      cp_debug(Rpad('-',72,'-'));
      cp_debug(Rpad('Status', 20) || ' ' ||
              Rpad('Count', 10));
      cp_debug(Rpad('-', 20, '-') || ' ' ||
               Rpad('-', 10, '-'));
      cp_debug(Rpad('Normal', 20) || ' ' ||
               Rpad(l_normal_count, 10));
      cp_debug(Rpad('Warning', 20) || ' ' ||
               Rpad(l_warning_count, 10));
      cp_debug(Rpad('Error', 20) || ' ' ||
               Rpad(l_error_count, 10));
      cp_debug(Rpad('-', 20, '-') || ' ' ||
               Rpad('-', 10, '-'));
      cp_debug(Rpad('Total', 20) || ' ' ||
               Rpad(l_sub_requests.COUNT, 10));
      cp_debug(' ');
      p_errbuf := l_sub_requests.COUNT || ' sub request(s) completed.';
      IF (l_error_count > 0) THEN
         p_retcode := 2;
       ELSIF (l_warning_count > 0) THEN
         p_retcode := 1;
       ELSE
         p_retcode := 0;
      END IF;
      RETURN;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      p_retcode := 2;
      p_errbuf := Substr('cvr_report_parallel:SQLERRM: ' || Sqlerrm, 1, 70);
END cvr_report_parallel;



/* ----------------------------------------------------------------------- */
/*      Determines if any cross-validation include (inex = 'I') or         */
/*      exclude (inex = 'E') rule is violated. Returns name of first       */
/*      violated rule and TRUE if so, otherwise returns FALSE.             */
/* ----------------------------------------------------------------------- */
  FUNCTION cv_rule_violated(nsegs     IN NUMBER,
                            segs      IN FND_FLEX_SERVER1.StringArray,
                            segfmt    IN FND_FLEX_SERVER1.SegFormats,
                            fstruct   IN FND_FLEX_SERVER1.FlexStructId,
                            inex      IN VARCHAR2,
                            v_date    IN DATE,
                            rule_name OUT nocopy VARCHAR2) RETURN BOOLEAN
    IS
       sqls          VARCHAR2(32000);
       nfound        NUMBER;
       datatype      VARCHAR2(1);
       locol         VARCHAR2(100);
       hicol         VARCHAR2(100);
       violated_rule VARCHAR2(15);
       isviolated    BOOLEAN;

  BEGIN

     --  VERY IMPORTANT!!!
     --  Must put the portions of SQL statement that select the specific flex
     --  structure LAST in the SQL statement.  This is so they will be evaluated
     --  FIRST.  If they are not evaluated first, then SQL may attempt to do
     --  format conversions on the segments before checking what structure we
     --  have and this will cause a data format type error.

     --  First build the select statement appropriate for the include or
     --  exclude rule search.
     --

     fnd_dsql.init;

     sqls := cvrule_clause_begin;

     IF (inex = 'E') THEN
        sqls := sqls || cvrule_clause_exclude_begin;
     end if;

     sqls := sqls || cvrule_clause_where;

     if(inex = 'I') then
        sqls := sqls || cvrule_clause_include_mid;
      else
        sqls := sqls || cvrule_clause_exclude_mid;
     end if;

     fnd_dsql.add_text(sqls);

     --  Build column select statements for each column.
     --
     for i in reverse 1..nsegs loop
        datatype := segfmt.vs_format(i);
        locol := 'L.SEGMENT' || to_char(i) || '_LOW';
        hicol := 'L.SEGMENT' || to_char(i) || '_HIGH';
        fnd_flex_server1.x_inrange_clause(segs(i), datatype,locol, hicol);
     end loop;

     fnd_dsql.add_text(cvrule_clause_end);

     --  Stop at the first row if exclude rule violated
     --
     if(inex = 'E') then
        fnd_dsql.add_text('and ROWNUM = 1 ');
     end if;

     --  Now do the select using dynamic sql
     --
     nfound := x_cv_rule_select(fstruct, v_date, violated_rule);

     if(nfound = 0) then
        isviolated := FALSE;
        rule_name := NULL;
      elsif(nfound > 0) then
        isviolated := TRUE;
        rule_name := violated_rule;
      else
        isviolated := TRUE;
        rule_name := NULL;
     end if;
     return(isviolated);

  EXCEPTION
     WHEN OTHERS then
        FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
        FND_MESSAGE.set_token('MSG','SV2.cv_rule_violated() exception: ' || SQLERRM);
        rule_name := NULL;
        return(TRUE);
  END cv_rule_violated;



/* ----------------------------------------------------------------------- */
/*      Determines if any cross-validation include (inex = 'I') or         */
/*      exclude (inex = 'E') rule is violated. Returns name of first       */
/*      violated rule and TRUE if so, otherwise returns FALSE.             */
/* ----------------------------------------------------------------------- */
/* ----------------------------------------------------------------------- */
/* Bug 21612876, This procedure is called from C code fdfgcx.lc            */
/* This procedure processes the CVR report. This procedure has better      */
/* performance than the original C validation api fdfvxr().                */
/* ----------------------------------------------------------------------- */
  FUNCTION cv_rule_violated_report(nsegs     IN NUMBER,
                            segs      IN FND_FLEX_SERVER1.StringArray,
                            segfmt    IN FND_FLEX_SERVER1.SegFormats,
                            fstruct   IN FND_FLEX_SERVER1.FlexStructId,
                            inex      IN VARCHAR2,
                            v_date    IN DATE,
                            cvr_low   IN VARCHAR2,
                            cvr_high  IN VARCHAR2,
                            rule_name OUT nocopy VARCHAR2) RETURN BOOLEAN
    IS
       sqls          VARCHAR2(32000);
       nfound        NUMBER;
       datatype      VARCHAR2(1);
       locol         VARCHAR2(100);
       hicol         VARCHAR2(100);
       violated_rule VARCHAR2(15);
       isviolated    BOOLEAN;

  BEGIN

     --  VERY IMPORTANT!!!
     --  Must put the portions of SQL statement that select the specific flex
     --  structure LAST in the SQL statement.  This is so they will be evaluated
     --  FIRST.  If they are not evaluated first, then SQL may attempt to do
     --  format conversions on the segments before checking what structure we
     --  have and this will cause a data format type error.

     --  First build the select statement appropriate for the include or
     --  exclude rule search.
     --

     fnd_dsql.init;

     sqls := cvrule_clause_begin;

     IF (inex = 'E') THEN
        sqls := sqls || cvrule_clause_exclude_begin;
     end if;

       sqls := sqls || cvrule_clause_where;

     if(inex = 'I') then
          if (cvr_low is not NULL and cvr_high is not NULL) then
             sqls := sqls || ' and R.FLEX_VALIDATION_RULE_NAME BETWEEN :CVR_LOW AND :CVR_HIGH ' || cvrule_clause_include_mid;
          else
           sqls := sqls || cvrule_clause_include_mid;
          end if;
      else
        sqls := sqls || cvrule_clause_exclude_mid;
     end if;

     fnd_dsql.add_text(sqls);

     --  Build column select statements for each column.
     --
     for i in reverse 1..nsegs loop
        datatype := segfmt.vs_format(i);
        locol := 'L.SEGMENT' || to_char(i) || '_LOW';
        hicol := 'L.SEGMENT' || to_char(i) || '_HIGH';
        fnd_flex_server1.x_inrange_clause(segs(i), datatype,locol, hicol);
     end loop;

        fnd_dsql.add_text(cvrule_clause_end);

      --  Add ROWNUM = 1 to stop at the first row if exclude rule violated

     if(inex = 'E') then
          if (cvr_low is not NULL and cvr_high is not NULL) then
             fnd_dsql.add_text('and L.FLEX_VALIDATION_RULE_NAME BETWEEN :CVR_LOW AND :CVR_HIGH and ROWNUM = 1 ');
          else
             fnd_dsql.add_text('and ROWNUM = 1 ');
          end if;
      else
          if (cvr_low is not NULL and cvr_high is not NULL) then
             fnd_dsql.add_text('and L.FLEX_VALIDATION_RULE_NAME BETWEEN :CVR_LOW AND :CVR_HIGH ');
          end if;
      end if;

     --  Now do the select using dynamic sql
     --
     nfound := x_cv_rule_select_report(fstruct, v_date, cvr_low, cvr_high, violated_rule);

     if(nfound = 0) then
        isviolated := FALSE;
        rule_name := NULL;
      elsif(nfound > 0) then
        isviolated := TRUE;
        rule_name := violated_rule;
      else
        isviolated := TRUE;
        rule_name := NULL;
     end if;
     return(isviolated);

  EXCEPTION
     WHEN OTHERS then
        FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
        FND_MESSAGE.set_token('MSG','SV2.cv_rule_violated() exception: ' || SQLERRM);
        rule_name := NULL;
        return(TRUE);
  END cv_rule_violated_report;




/* ----------------------------------------------------------------------- */
/*      Uses dynamic SQL to select violated cross-validation rule.         */
/*      Returns 1 and first violated rule name if any rule violated.       */
/*      Returns 0 if no violated rules, or < 0 and sets message if error.  */
/*      Returns 0 for descritive flexfields because they have no cv rules. */
/* ----------------------------------------------------------------------- */
  FUNCTION x_cv_rule_select(fstruct   IN  FND_FLEX_SERVER1.FlexStructId,
                            v_date    IN  DATE,
                            bad_rule  OUT nocopy VARCHAR2) RETURN NUMBER IS

  num_returned  NUMBER;
  selected_rule VARCHAR2(15);
  cursornum     INTEGER;
  sql_str VARCHAR2(32000);

  BEGIN

--  No cv rules for descriptive flexfields
--
    if(not fstruct.isa_key_flexfield) then
      return(0);
    end if;

-- Save the SQL string in the debug string
--
    FND_FLEX_SERVER1.add_sql_string(fnd_dsql.get_text(p_with_debug => TRUE));

    cursornum := dbms_sql.open_cursor;
    fnd_dsql.set_cursor(cursornum);

    sql_str := fnd_dsql.get_text(p_with_debug => FALSE);
    dbms_sql.parse(cursornum, sql_str, dbms_sql.v7);

    fnd_dsql.do_binds;
    dbms_sql.bind_variable(cursornum, ':VDATE', v_date);
    dbms_sql.bind_variable(cursornum, ':APID', fstruct.application_id);
    dbms_sql.bind_variable(cursornum, ':CODE', fstruct.id_flex_code);
    dbms_sql.bind_variable(cursornum, ':NUM', fstruct.id_flex_num);
    dbms_sql.define_column(cursornum, 1, selected_rule, 15);
    num_returned := dbms_sql.execute_and_fetch(cursornum, FALSE);
    if(num_returned = 1) then
      dbms_sql.column_value(cursornum, 1, selected_rule);
      IF (fnd_flex_server1.g_debug_level > 0) THEN
         FND_FLEX_SERVER1.add_debug('(DSQL returned ' || selected_rule || ')');
      END IF;
      bad_rule := selected_rule;
    else
      num_returned := 0;
      IF (fnd_flex_server1.g_debug_level > 0) THEN
         FND_FLEX_SERVER1.add_debug('(DSQL returned: NULL)');
      END IF;
    end if;
    dbms_sql.close_cursor(cursornum);
    return(num_returned);

  EXCEPTION
    WHEN OTHERS then
      if(dbms_sql.is_open(cursornum)) then
        dbms_sql.close_cursor(cursornum);
      end if;
      FND_MESSAGE.set_name('FND', 'FLEX-DSQL EXCEPTION');
      FND_MESSAGE.set_token('MSG', SQLERRM);
      FND_MESSAGE.set_token('SQLSTR', SUBSTRB(sql_str, 1, 1000));
      return(-1);
  END x_cv_rule_select;



/* ----------------------------------------------------------------------- */
/*      Uses dynamic SQL to select violated cross-validation rule.         */
/*      Returns 1 and first violated rule name if any rule violated.       */
/*      Returns 0 if no violated rules, or < 0 and sets message if error.  */
/*      Returns 0 for descritive flexfields because they have no cv rules. */
/* ----------------------------------------------------------------------- */
  FUNCTION x_cv_rule_select_report(fstruct   IN  FND_FLEX_SERVER1.FlexStructId,
                                   v_date    IN  DATE,
                                   cvr_low   IN VARCHAR2,
                                   cvr_high  IN VARCHAR2,
                                   bad_rule  OUT nocopy VARCHAR2) RETURN NUMBER IS

  num_returned  NUMBER;
  selected_rule VARCHAR2(15);
  cursornum     INTEGER;
  sql_str VARCHAR2(32000);

  BEGIN

--  No cv rules for descriptive flexfields
--
    if(not fstruct.isa_key_flexfield) then
      return(0);
    end if;

-- Save the SQL string in the debug string
--
    FND_FLEX_SERVER1.add_sql_string(fnd_dsql.get_text(p_with_debug => TRUE));

    cursornum := dbms_sql.open_cursor;
    fnd_dsql.set_cursor(cursornum);


    sql_str := fnd_dsql.get_text(p_with_debug => FALSE);
--insert into elvis values (sql_str,orc_debug_seq.nextval);
    dbms_sql.parse(cursornum, sql_str, dbms_sql.v7);

    if (cvr_low is not NULL and cvr_high is not NULL) then
       fnd_dsql.do_binds;
       dbms_sql.bind_variable(cursornum, ':VDATE', v_date);
       dbms_sql.bind_variable(cursornum, ':APID', fstruct.application_id);
       dbms_sql.bind_variable(cursornum, ':CODE', fstruct.id_flex_code);
       dbms_sql.bind_variable(cursornum, ':NUM', fstruct.id_flex_num);
       dbms_sql.bind_variable(cursornum, ':CVR_LOW',  cvr_low);
       dbms_sql.bind_variable(cursornum, ':CVR_HIGH', cvr_high);
       dbms_sql.define_column(cursornum, 1, selected_rule, 15);
    else
       fnd_dsql.do_binds;
       dbms_sql.bind_variable(cursornum, ':VDATE', v_date);
       dbms_sql.bind_variable(cursornum, ':APID', fstruct.application_id);
       dbms_sql.bind_variable(cursornum, ':CODE', fstruct.id_flex_code);
       dbms_sql.bind_variable(cursornum, ':NUM', fstruct.id_flex_num);
       dbms_sql.define_column(cursornum, 1, selected_rule, 15);
    end if;
    num_returned := dbms_sql.execute_and_fetch(cursornum, FALSE);
    if(num_returned = 1) then
      dbms_sql.column_value(cursornum, 1, selected_rule);
--insert into elvis values(selected_rule, orc_debug_seq.nextval);
      IF (fnd_flex_server1.g_debug_level > 0) THEN
         FND_FLEX_SERVER1.add_debug('(DSQL returned ' || selected_rule || ')');
      END IF;
      bad_rule := selected_rule;
    else
      num_returned := 0;
      IF (fnd_flex_server1.g_debug_level > 0) THEN
         FND_FLEX_SERVER1.add_debug('(DSQL returned: NULL)');
      END IF;
    end if;
    dbms_sql.close_cursor(cursornum);
    return(num_returned);

  EXCEPTION
    WHEN OTHERS then
      if(dbms_sql.is_open(cursornum)) then
        dbms_sql.close_cursor(cursornum);
      end if;
      FND_MESSAGE.set_name('FND', 'FLEX-DSQL EXCEPTION');
      FND_MESSAGE.set_token('MSG', SQLERRM);
      FND_MESSAGE.set_token('SQLSTR', SUBSTRB(sql_str, 1, 1000));
      return(-1);
  END x_cv_rule_select_report;




/* ----------------------------------------------------------------------- */
/*      Checks to see if the segments already have been cross-validated.   */
/*      If so, sets in_cache flag = TRUE and returns the isviolated flag   */
/*      and the rule name of the violated rule if any.                     */
/*      Returns TRUE on success or FALSE and sets error message if error.  */
/*      Combination must have been validated for the same vdate day.       */
/*      Combination will be cleared after inserting in VALID().            */
/*      Cached is limited in size.                                         */
/*      Returns in_cache = TRUE and is_violated = FALSE for descriptive    */
/*      flexfields since there are no cv rules for descriptive flexfields. */
/* ----------------------------------------------------------------------- */
  FUNCTION x_xvc_check_cache(fstruct       IN  FND_FLEX_SERVER1.FlexStructId,
                             v_date        IN  DATE,
                             p_cat_segs    IN  VARCHAR2,
                             in_cache      OUT nocopy BOOLEAN,
                             is_violated   OUT nocopy BOOLEAN,
                             rule_name     OUT nocopy VARCHAR2)
    RETURN BOOLEAN
    IS
       l_v_day    DATE;
  BEGIN
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        fnd_flex_server1.add_debug('BEGIN SV2.x_xvc_check_cache()');
     END IF;

     in_cache := FALSE;

     -- No cv rules for descriptive flexfields.
     --
     IF (not fstruct.isa_key_flexfield) then
        in_cache := TRUE;
        is_violated := FALSE;
        return(TRUE);
     end if;

     g_cache_key := (fstruct.application_id ||
                     fstruct.id_flex_code ||
                     fstruct.id_flex_num || '.' ||
                     p_cat_segs);

     fnd_plsql_cache.generic_1to1_get_value(xvc_cache_controller,
                                            xvc_cache_storage,
                                            g_cache_key,
                                            g_cache_value,
                                            g_cache_return_code);

     IF (g_cache_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
        --  Convert v_date to the day, so that if user calls validation
        --  with SYSDATE as the v_date, the value cached a few seconds earlier
        --  will still have the same v_date.  Client code does not even consier
        --  seconds when checking v_date so this should cause no problems.
        --  note v_date may be null.
        --
        l_v_day := Trunc(v_date);

        IF ((l_v_day IS NULL AND g_cache_value.date_1 IS NULL) OR
            (l_v_day IS NOT NULL AND l_v_day = g_cache_value.date_1)) THEN
           is_violated := g_cache_value.boolean_1;
           rule_name := g_cache_value.varchar2_1;
           in_cache := TRUE;
        END IF;

     END IF;

     return(TRUE);
  EXCEPTION
     WHEN OTHERS then
        FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
        FND_MESSAGE.set_token('MSG','SV2.x_xvc_check_cache() exception: ' || SQLERRM);
        return(FALSE);
  END x_xvc_check_cache;

/* ----------------------------------------------------------------------- */
/*      Saves the results of validating a combination to cache.            */
/*      Returns TRUE on success or FALSE and sets error message if error.  */
/* ----------------------------------------------------------------------- */
  FUNCTION x_xvc_update_cache(fstruct       IN  FND_FLEX_SERVER1.FlexStructId,
                              v_date        IN  DATE,
                              p_cat_segs    IN  VARCHAR2,
                              is_violated   IN  BOOLEAN,
                              rule_name     IN  VARCHAR2)
    RETURN BOOLEAN
    IS
       l_v_day    DATE;
       l_in_cache BOOLEAN;
  BEGIN
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        fnd_flex_server1.add_debug('BEGIN SV2.x_xvc_update_cache()');
     END IF;

     -- No cv rules for descriptive flexfields.
     --
     if(not fstruct.isa_key_flexfield) then
        return(TRUE);
     end if;

     g_cache_key := (fstruct.application_id ||
                     fstruct.id_flex_code ||
                     fstruct.id_flex_num || '.' ||
                     p_cat_segs);

     fnd_plsql_cache.generic_1to1_get_value(xvc_cache_controller,
                                            xvc_cache_storage,
                                            g_cache_key,
                                            g_cache_value,
                                            g_cache_return_code);



     IF (g_cache_return_code = fnd_plsql_cache.CACHE_NOTFOUND) THEN
        l_in_cache := FALSE;
      ELSE
        l_v_day := Trunc(v_date);

        IF ((l_v_day IS NULL AND g_cache_value.date_1 IS NULL) OR
            (l_v_day IS NOT NULL AND l_v_day = g_cache_value.date_1)) THEN

           l_in_cache := TRUE;

           fnd_plsql_cache.generic_cache_new_value(x_value      => g_cache_value,
                                                   p_boolean_1  => is_violated,
                                                   p_varchar2_1 => rule_name,
                                                   p_date_1     => l_v_day);
        END IF;
     END IF;


     IF (NOT l_in_cache) THEN
        fnd_plsql_cache.generic_cache_new_value(x_value      => g_cache_value,
                                                p_boolean_1  => is_violated,
                                                p_varchar2_1 => rule_name,
                                                p_date_1     => l_v_day);
     END IF;

     fnd_plsql_cache.generic_1to1_put_value(xvc_cache_controller,
                                            xvc_cache_storage,
                                            g_cache_key,
                                            g_cache_value);

     IF (fnd_flex_server1.g_debug_level > 0) THEN
        FND_FLEX_SERVER1.add_debug('Added to xvc_cache key : ' ||
                                   REPLACE(g_cache_key, CACHE_DELIMITER, '.'));

        fnd_flex_server1.add_debug('is_violated :');
        if(is_violated) then
           FND_FLEX_SERVER1.add_debug('Y ');
         else
           FND_FLEX_SERVER1.add_debug('N ');
        end if;
        FND_FLEX_SERVER1.add_debug('rule_name :' || rule_name);
     END IF;
     return(TRUE);

  EXCEPTION
     WHEN OTHERS then
        FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
        FND_MESSAGE.set_token('MSG','SV2.x_xvc_cache_result() exception: ' || SQLERRM);
        return(FALSE);

  END x_xvc_update_cache;

/* ----------------------------------------------------------------------- */
/*      Deletes the specified combination from the cross-validation cache. */
/* ----------------------------------------------------------------------- */
  FUNCTION x_drop_cached_cv_result(fstruct   IN  FND_FLEX_SERVER1.FlexStructId,
                                   n_segs    IN  NUMBER,
                                   segs      IN FND_FLEX_SERVER1.ValueArray)
    RETURN BOOLEAN IS
       l_count  NUMBER;
       cat_segs VARCHAR2(5000);
       segments FND_FLEX_SERVER1.StringArray;

  BEGIN
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        fnd_flex_server1.add_debug('BEGIN SV2.x_drop_cached_cv_result()');
     END IF;

     -- No cv rules for descriptive flexfields.
     --
     if(not fstruct.isa_key_flexfield) then
        return(TRUE);
     end if;

     --  Concatenate segments
     --
     for i in 1..n_segs loop
        segments(i) := segs(i);
     end loop;
     cat_segs := FND_FLEX_SERVER1.from_stringarray2(n_segs, segments,
                                                    CACHE_DELIMITER);

     g_cache_key := (fstruct.application_id ||
                     fstruct.id_flex_code ||
                     fstruct.id_flex_num || '.' ||
                     cat_segs);

     fnd_plsql_cache.generic_1to1_get_value(xvc_cache_controller,
                                            xvc_cache_storage,
                                            g_cache_key,
                                            g_cache_value,
                                            g_cache_return_code);

     IF (g_cache_return_code = fnd_plsql_cache.CACHE_NOTFOUND) THEN
        l_count := 0;
      ELSE
        l_count := 1;

        fnd_plsql_cache.generic_1to1_remove_key(xvc_cache_controller,
                                                g_cache_key);
     END IF;

     IF (fnd_flex_server1.g_debug_level > 0) THEN
        FND_FLEX_SERVER1.add_debug('Cleared ' || to_char(l_count) ||
                                   ' cached cv results. ');
     END IF;
     return(TRUE);

  EXCEPTION
     WHEN OTHERS then
        FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
        FND_MESSAGE.set_token('MSG','SV2.x_drop_cached_cv_result() exception: '
                              || SQLERRM);
        return(FALSE);

  END x_drop_cached_cv_result;

/* ----------------------------------------------------------------------- */
/*      Clears the cross-validation rule cache altogether.                 */
/* ----------------------------------------------------------------------- */
  PROCEDURE x_clear_cv_cache IS
  BEGIN
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        FND_FLEX_SERVER1.add_debug('Zeroing xvr_comb cache');
     END IF;
     fnd_plsql_cache.generic_1to1_clear(xvc_cache_controller,
                                        xvc_cache_storage);
  END x_clear_cv_cache;

/* ----------------------------------------------------------------------- */
/*      Breaks up concatenated values or ids into a StringArray.           */
/*      Also checks that there are not too many segments.                  */
/*      If segment delimiter in a segment it is assumed to have been       */
/*      replaced by a carriage return UNLESS there is only one segment     */
/*      in which case the delimiter is not substituted.                    */
/*      The parsed displayed segments token is input to count the number   */
/*      of segments expected.                                              */
/*      Returns TRUE and nsegs_out > 0 if all ok, or FALSE, nsegs_out = 0, */
/*      and sets error using FND_MESSAGE on error.                         */
/* ----------------------------------------------------------------------- */

  FUNCTION breakup_catsegs(catsegs        IN  VARCHAR2,
                           delim          IN  VARCHAR2,
                           vals_not_ids   IN  BOOLEAN,
                           displayed_segs IN  FND_FLEX_SERVER1.DisplayedSegs,
                           nsegs_out      OUT nocopy NUMBER,
                           segs_out       IN OUT nocopy FND_FLEX_SERVER1.StringArray)
                                                            RETURN BOOLEAN IS
    cat_nsegs   NUMBER;
    disp_nsegs  NUMBER;
    j           NUMBER;
    l_min       NUMBER;
    cat_nsegs1  NUMBER;

  BEGIN

    disp_nsegs := 0;
    cat_nsegs := 0;
    nsegs_out := 0;

--  Count the number of segments to expect.  Only displayed ones if values.
--
    if(vals_not_ids) then
      for i in 1..displayed_segs.n_segflags loop
        if(displayed_segs.segflags(i)) then
          disp_nsegs := disp_nsegs + 1;
        end if;
      end loop;
    else
      disp_nsegs := displayed_segs.n_segflags;
    end if;

--  If only expecting one segment return it immediately without
--  calling to_stringarray() which might replace the delimiter.
--  Otherwise call to_stringarray to break up the segments.
--
    if(disp_nsegs = 1) then
       segs_out(1) := catsegs;
       cat_nsegs := 1;
     else
       cat_nsegs := FND_FLEX_SERVER1.to_stringarray(catsegs, delim, segs_out);
    end if;
       cat_nsegs := cat_nsegs - 1;


/*************************************************************************
  Bug 2050531 The correct format (In V mode) is to pass only displayed
  segments to fnd_flex_keyval.validate_segs(concat_segs). If for some
  reason the calling program passes in the concatenated displayed and
  non-displayed segments, then we need to parse out the concatednated
  segments removing the non-displayed segments. The validation code
  does not expect to receive non-diplayed segments and will error out
  if it does. Non-displayed segments are handeled differently because
  the are automatically defaulted and validated at that time. How will
  the we know if the concat segs passed in include non displayed
  segments ? We will assume that if the concat segment count is
  greater than the number of displayed segment count, then we have
  non-disp segments and they need to be parsed and removed out of
  the concatenation.
*************************************************************************/

    if((cat_nsegs > disp_nsegs) AND vals_not_ids) then

      IF (cat_nsegs < displayed_segs.n_segflags) THEN
         l_min := cat_nsegs;
       ELSE
         -- Concat string has more values than the number of segments.
         l_min := displayed_segs.n_segflags;
      END IF;

      -- Shift displayed values in the array.
      j := 1;
      for i in 1..l_min loop
        if(displayed_segs.segflags(i)) then
           segs_out(j) := segs_out(i);
           j := j + 1;
        end if;
      end loop;

      -- Re-set array size.
      disp_nsegs := j - 1;

      -- Nullify the rest of the array.
      FOR i IN j..cat_nsegs LOOP
         segs_out(i) := NULL;
      END LOOP;

    end if;

-- Bug 20700239
    cat_nsegs1 := cat_nsegs + 1;
    if (cat_nsegs1 < disp_nsegs) then


       if ((substr(catsegs, lengthb(catsegs), 1) = delim)) then
          cat_nsegs1 := cat_nsegs1 - 1;
       end if;

       if ((lengthb(segs_out(cat_nsegs1))) <= (disp_nsegs - cat_nsegs1)) then
          segs_out(cat_nsegs1) := NULL;
          cat_nsegs1 := cat_nsegs1 - 1;
       end if;


       segs_out(cat_nsegs1) := substrb(segs_out(cat_nsegs1), 1, LENGTHB(segs_out(cat_nsegs1)) - disp_nsegs-cat_nsegs1);

       j := cat_nsegs1 + 1;
       FOR i IN j..disp_nsegs LOOP
          segs_out(i) := NULL;
       END LOOP;
       cat_nsegs1 := disp_nsegs;
       cat_nsegs := disp_nsegs;
    end if;

-- Bug 16528881
-- Check to make sure the number of cat segs is not greater
-- than the total number of defined enabled segments.
--
    if(cat_nsegs > displayed_segs.n_segflags) then
      FND_MESSAGE.set_name('FND', 'FLEX-TOO MANY SEGS');
      FND_MESSAGE.set_token('NSEGS', displayed_segs.n_segflags);
      return(FALSE);
    end if;

--  Check to make sure there are not too many segments.
--
    if(disp_nsegs > MAX_NSEGS) then
      FND_MESSAGE.set_name('FND', 'FLEX-TOO MANY SEGS');
      FND_MESSAGE.set_token('NSEGS', MAX_NSEGS);
      return(FALSE);
    end if;

--  Return the segment count
    nsegs_out := disp_nsegs;
    return(TRUE);

    EXCEPTION
      WHEN OTHERS then
        FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
        FND_MESSAGE.set_token('MSG','SV2.breakup_catsegs() exception: '||SQLERRM);
        return(FALSE);

  END breakup_catsegs;


/* ----------------------------------------------------------------------- */

-- ======================================================================
PROCEDURE cp_debug(p_debug IN VARCHAR2)
  IS
     l_debug     VARCHAR2(32000) := p_debug;
     l_len       NUMBER := Nvl(Length(l_debug),0);
     l_pos       NUMBER;
BEGIN
   IF (p_debug LIKE 'ERROR%') THEN
      g_numof_errors := g_numof_errors + 1;
   END IF;

   WHILE l_len > 0 LOOP
      l_pos := Instr(l_debug, chr_newline, 1, 1);
      IF ((l_pos + g_indent > g_line_size) OR (l_pos = 0)) THEN
         l_pos := g_line_size - g_indent;
         fnd_file.put_line(FND_FILE.LOG,
                           Lpad(' ',g_indent-1,' ') ||
                           Substr(l_debug, 1, l_pos));
       ELSE
         fnd_file.put(FND_FILE.LOG,
                      Lpad(' ',g_indent-1,' ') ||
                      Substr(l_debug, 1, l_pos));
      END IF;

      l_debug := Substr(l_debug, l_pos + 1);
      l_len := Nvl(Length(l_debug),0);
   END LOOP;
EXCEPTION
   WHEN OTHERS THEN
      NULL;
END cp_debug;

-- --------------------------------------------------

  PROCEDURE cp_debug_out(p_debug IN VARCHAR2)
    IS
       l_debug     VARCHAR2(32000) := p_debug;
       l_len       NUMBER := Nvl(Length(l_debug),0);
       l_pos       NUMBER;
  BEGIN
     IF (p_debug LIKE 'ERROR%') THEN
        g_numof_errors := g_numof_errors + 1;
     END IF;

     WHILE l_len > 0 LOOP
        l_pos := Instr(l_debug, chr_newline, 1, 1);
        IF ((l_pos + g_indent > g_line_size) OR (l_pos = 0)) THEN
           l_pos := g_line_size - g_indent;
           fnd_file.put_line(FND_FILE.OUTPUT,
                             Lpad(' ',g_indent-1,' ') ||
                             Substr(l_debug, 1, l_pos));
         ELSE
           fnd_file.put(FND_FILE.OUTPUT,
                        Lpad(' ',g_indent-1,' ') ||
                        Substr(l_debug, 1, l_pos));
        END IF;

        l_debug := Substr(l_debug, l_pos + 1);
        l_len := Nvl(Length(l_debug),0);
     END LOOP;
  EXCEPTION
     WHEN OTHERS THEN
        NULL;
  END cp_debug_out;


  PROCEDURE ol(vbuff  VARCHAR2, -- Buffer
               vright PLS_INTEGER DEFAULT 135, -- Optional Right-Margin size
               LEVEL  PLS_INTEGER DEFAULT 0 -- Optional Left-Margin size
               ) IS
    tmp_r   VARCHAR2(32765);
    vo      PLS_INTEGER := vright;
    l_space PLS_INTEGER := NVL(2 * LEVEL, 0);
    l_strout varchar2(300) :=
           'Declare '
        ||   'p1 varchar2(4000); '
        || 'begin '
        ||   'p1 := :1 ; '
        ||   'DB'|| 'MS'|| '_OUTPUT'|| '.put'|| '_line' || '( p1 ); '
        || 'end; ';

    procedure ol_int( p_data varchar2 ) IS

    begin
      null;
      -- uncomment the following line to print-out dbg information
      execute immediate l_strout using p_data;
    end ol_int;

  BEGIN
    NULL;
    --
    -- Uncomment the following lines for DEBUG print-information
    --

    -- cp_debug_out( vbuff || chr(10) );


    tmp_r := RTRIM(vbuff);
    WHILE LENGTH(tmp_r) > vo LOOP
      vo := INSTR(SUBSTR(tmp_r, 1, vright), ' ', -1);
      IF NVL(vo, 0) < 3 THEN
        vo := vright;
      END IF;
      IF l_space > 0 THEN
        ol_int(LPAD('.', l_space, ' ') ||
                             SUBSTR(tmp_r, 1, vo));
        l_space := 0;
      ELSE
        ol_int(SUBSTR(tmp_r, 1, vo));
      END IF;
      tmp_r := SUBSTR(tmp_r, vo+1);
    END LOOP;
    IF l_space > 0 THEN
      ol_int(LPAD('.', l_space, ' ') || SUBSTR(tmp_r, 1, vo));
    ELSE
      ol_int(tmp_r);
    END IF;

  END ol;


  /*
  ** Procedure: printl
  ** description: created as a shortcut for DBMS_OUTPUT.put_line
  **              with logic to use margin and indent
  **          by: Enrique Miranda
  */
  PROCEDURE printl(vbuff   VARCHAR2
               ) IS
    tmp_r   VARCHAR2(32765);
  BEGIN
    tmp_r := RTRIM(vbuff);
    cp_debug_out( tmp_r );

    --
    -- Uncomment the following line for DEBUG print-information
    --
    -- ol( tmp_r );
  END printl;


-- ======================================================================
-- This procedure submits parallel processes for FNDFFRXR which
-- generates the Cross Validatoin rule violation report.
-- ======================================================================
PROCEDURE submit_rxr_report(errbuf            OUT nocopy VARCHAR2,
                            retcode           OUT nocopy VARCHAR2,
                            p_application_id  IN VARCHAR2,
                            p_id_flex_code    IN VARCHAR2,
                            p_id_flex_num     IN VARCHAR2,
                            p_show_non_sum_comb IN VARCHAR2 DEFAULT 'Y',
                            p_dis_non_sum_comb IN VARCHAR2,
                            p_show_sum_comb    IN VARCHAR2 DEFAULT 'N',
                            p_dis_sum_comb     IN VARCHAR2 DEFAULT 'N',
                            p_enddate_flag    IN VARCHAR2 DEFAULT NULL,
                            p_cvr_name_low    IN VARCHAR2 DEFAULT NULL,
                            p_cvr_name_high   IN VARCHAR2 DEFAULT NULL,
                            p_num_workers     IN NUMBER,
                            p_debug_flag      IN VARCHAR2)
  IS
     ----------------------
     -- Local definitions -
     ----------------------
     l_request_id          NUMBER;
     l_sub_request_id      NUMBER;
     l_request_count       NUMBER;
     i                     NUMBER;
     l_min_ccid            NUMBER;
     l_max_ccid            NUMBER;
     l_total_ccid          NUMBER;
     l_min_ccid_range      NUMBER;
     l_max_ccid_range      NUMBER;
     l_batch_size          NUMBER;
     l_num_workers         NUMBER;
     l_normal_count        NUMBER := 0;
     l_warning_count       NUMBER := 0;
     l_error_count         NUMBER := 0;
     l_request_data        VARCHAR2(100);
     l_action_message      VARCHAR2(200);
     l_sub_program         VARCHAR2(8);
     l_sub_description     VARCHAR2(100);
     l_ccid_partition_sql  VARCHAR2(1000);
     l_max_ccid_range_sql  VARCHAR2(1000);
     l_set_def_col_name    VARCHAR2(30);
     l_unique_id_col_name  VARCHAR2(30);
     l_app_table_name      VARCHAR2(30);
     l_cp_appl_name        VARCHAR2(30);
     l_sub_requests        fnd_concurrent.requests_tab_type;
     TYPE cursor_type IS REF CURSOR;
     l_ccid_partition_cur  cursor_type;
     l_max_ccid_range_cur  cursor_type;


  BEGIN

   ------------------------------------------------
   -- Defining values for the sumbit request call -
   ------------------------------------------------
   l_cp_appl_name := 'FND';
   l_sub_program := 'FNDRXR';
   l_sub_description := 'Cross-Validation Rule Violation Report';

   ------------------------------------------------------------
   -- Select the information needed to partition the CC table -
   ------------------------------------------------------------
   SELECT
   application_table_name,
   set_defining_column_name,
   unique_id_column_name
   INTO
   l_app_table_name,
   l_set_def_col_name,
   l_unique_id_col_name
   FROM
   fnd_id_flexs
   WHERE
   application_id = p_application_id and
   id_flex_code = p_id_flex_code;

   -- Some KFF's do not have a Structure Column. For
   -- those KFF's they are hard coded to 101.
   -- Will set l_set_def_col_name=101 so that the sql
   -- below will not be mal formed.
   IF (l_set_def_col_name is null) THEN
       l_set_def_col_name := 101;
   END IF;

   /************************************************************
     select count(*) total_ccid,
            min(code_combination_id) min_ccid,
            max(code_combination_id) max_ccid
     from gl_code_combinations
     where chart_of_accounts_id = 101;
   ************************************************************/
   l_ccid_partition_sql :=
     ('SELECT /* $Header: AFFFSV2B.pls 120.2.12010000.14 2017/02/10 21:01:55 hgeorgi ship $ */ ' ||
      ' COUNT(*), ' ||
      ' MIN('   || l_unique_id_col_name || '), ' ||
      ' MAX('   || l_unique_id_col_name || ')'   ||
      ' FROM '  || l_app_table_name     ||
      ' WHERE ' || l_set_def_col_name   || '= :b_id_flex_num' ||
      ' AND enabled_flag = ''Y'' ');

   l_request_id := fnd_global.conc_request_id;
   l_request_data := fnd_conc_global.request_data;

   cp_debug('DEBUG: Request Id   : ' || l_request_id);
   cp_debug('DEBUG: Request Data : ' || l_request_data);
   cp_debug(' ');

   IF (l_request_data IS NULL) THEN
      --
      -- Print the header.
      --
      cp_debug(Lpad('Request ID', 10) || ' ' ||
               Rpad('Cross-Validation Rule Violation Report', 60));
      cp_debug(Lpad('-',10, '-') || ' ' ||
               Rpad('-',60, '-'));

      BEGIN

         OPEN l_ccid_partition_cur FOR l_ccid_partition_sql USING p_id_flex_num;
         l_request_count := 0;

         FETCH l_ccid_partition_cur INTO l_total_ccid, l_min_ccid, l_max_ccid;

         CLOSE l_ccid_partition_cur;


         --------------------------------------
         -- Initialize partitioning variables -
         --------------------------------------
         i := 0;
         l_num_workers    := p_num_workers;
         -- If more workers than ccid's, then set
         -- number of workers to number of ccid's
         if(l_total_ccid < l_num_workers) then
            l_num_workers := l_total_ccid;
         end if;

         -- Set l_num_workers to 1 if user enters 0 or less
         IF (l_num_workers <= 0) THEN
             l_num_workers :=1;

         END IF;

         l_batch_size := (trunc((l_total_ccid)/l_num_workers ));
         l_min_ccid_range  := l_min_ccid;

        /************************************************************
            SELECT
            MAX(code_combination_id)
            FROM
                   (SELECT code_combination_id
                    FROM gl_code_combinations
                    WHERE chart_of_accounts_id = 101
                    AND enabled_flag = 'Y'
                    AND code_combination_id >= l_min_ccid_range
                    ORDER BY code_combination_id)
             where rownum <= BATCH_SIZE
        ************************************************************/
        l_max_ccid_range_sql :=
        ('SELECT /* $Header: AFFFSV2B.pls 120.2.12010000.14 2017/02/10 21:01:55 hgeorgi ship $ */ ' ||
       ' MAX(' || l_unique_id_col_name || ')' ||
       ' FROM'  ||
          ' (SELECT '  || l_unique_id_col_name ||
          ' FROM ' ||     l_app_table_name     ||
          ' WHERE ' || l_set_def_col_name || '= :b_id_flex_num' ||
          ' AND enabled_flag = ''Y'' ' ||
          ' AND ' || l_unique_id_col_name || '>= :b_l_min_ccid_range' ||
          ' ORDER BY ' || l_unique_id_col_name || ')' ||
       ' WHERE rownum <= :b_batch_size');

         l_request_count := 0;

         FOR i in 1..l_num_workers LOOP

              -- Last worker should get the max ccid
              IF (i = l_num_workers) THEN
                  l_max_ccid_range := l_max_ccid;
              ELSE
                  OPEN l_max_ccid_range_cur FOR l_max_ccid_range_sql
                     USING p_id_flex_num, l_min_ccid_range, l_batch_size;
                  FETCH l_max_ccid_range_cur INTO l_max_ccid_range;
                  CLOSE l_max_ccid_range_cur;
              END IF;

              l_request_count := l_request_count + 1;

              /* Updated the call to the function with the new parameters added for ER#2335710*/
              l_sub_request_id := fnd_request.submit_request
                 (application => l_cp_appl_name,
                  program     => l_sub_program,
                  description => l_sub_description,
                  start_time  => NULL,
                  sub_request => TRUE,
                  argument1   => p_application_id,
                  argument2   => p_id_flex_code,
                  argument3   => p_id_flex_num,
                  argument4   => p_show_non_sum_comb,
                  argument5   => p_dis_non_sum_comb,
                  argument6   => p_show_sum_comb,
                  argument7   => p_dis_sum_comb,
                  argument8   => p_enddate_flag,
                  argument9   => p_cvr_name_low,
                  argument10  => p_cvr_name_high,
                  argument11  => l_min_ccid_range,
                  argument12  => l_max_ccid_range,
                  argument13  => p_debug_flag);

              l_min_ccid_range := l_max_ccid_range + 1;

              cp_debug(Lpad(l_sub_request_id, 10) || ' ' ||
                       Rpad(l_sub_program, 60));

              IF (l_sub_request_id = 0) THEN
                 null;
                 cp_debug('ERROR   : Unable to submit sub request.');
                 cp_debug('MESSAGE : ' || fnd_message.get);
              END IF;
           END LOOP;

      END;

      l_request_count := Nvl(l_request_count, 0);

      fnd_conc_global.set_req_globals(conc_status  => 'PAUSED',
                                      request_data => To_char(l_request_count));

      errbuf := l_request_count || ' sub request(s) submitted.';
      cp_debug(' ');
      cp_debug(errbuf);
      cp_debug(' ');
      retcode := 0;
      RETURN;
    ELSE
      l_request_count := To_number(l_request_data);

      cp_debug(l_request_count || ' sub request(s) completed.');
      --
      -- Print the header.
      --
      cp_debug(' ');
      cp_debug('Status Report');
      cp_debug(Rpad('-',72,'-'));
      cp_debug(Lpad('Request ID', 10) || ' ' ||
               Rpad('Status', 10) || ' ' ||
               Rpad('Action', 50));
      cp_debug(Lpad('-',10, '-') || ' ' ||
               Lpad('-',10, '-') || ' ' ||
               Lpad('-',50, '-'));

      l_sub_requests := fnd_concurrent.get_sub_requests(l_request_id);
      i := l_sub_requests.first;
      WHILE i IS NOT NULL LOOP
         IF (l_sub_requests(i).dev_status = 'NORMAL') THEN
            l_normal_count := l_normal_count + 1;
            l_action_message := 'Completed successfully.';
          ELSIF (l_sub_requests(i).dev_status = 'WARNING') THEN
            l_warning_count := l_warning_count + 1;
            l_action_message := 'Warnings reported, please see the sub-request log file.';
          ELSIF (l_sub_requests(i).dev_status = 'ERROR') THEN
            l_error_count := l_error_count + 1;
            l_action_message := 'Errors reported, please see the sub-request log file.';
          ELSE
            l_error_count := l_error_count + 1;
            l_action_message := 'Unknown status reported, please see the sub-request log file.';
         END IF;
         cp_debug(Lpad(l_sub_requests(i).request_id, 10) || ' ' ||
                  Rpad(l_sub_requests(i).dev_status, 10) || ' ' ||
                  l_action_message);
         i := l_sub_requests.next(i);
      END LOOP;

      cp_debug(' ');
      cp_debug('Summary Report');
      cp_debug(Rpad('-',72,'-'));
      cp_debug(Rpad('Status', 20) || ' ' ||
              Rpad('Count', 10));
      cp_debug(Rpad('-', 20, '-') || ' ' ||
               Rpad('-', 10, '-'));
      cp_debug(Rpad('Normal', 20) || ' ' ||
               Rpad(l_normal_count, 10));
      cp_debug(Rpad('Warning', 20) || ' ' ||
               Rpad(l_warning_count, 10));
      cp_debug(Rpad('Error', 20) || ' ' ||
               Rpad(l_error_count, 10));
      cp_debug(Rpad('-', 20, '-') || ' ' ||
               Rpad('-', 10, '-'));
      cp_debug(Rpad('Total', 20) || ' ' ||
               Rpad(l_sub_requests.COUNT, 10));
      cp_debug(' ');
      errbuf := l_sub_requests.COUNT || ' sub request(s) completed.';
      IF (l_error_count > 0) THEN
         retcode := 2;
       ELSIF (l_warning_count > 0) THEN
         retcode := 1;
       ELSE
         retcode := 0;
      END IF;
      RETURN;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      retcode := 2;
      errbuf := Substr('submit_rxr_report:SQLERRM: ' || Sqlerrm, 1, 240);
END submit_rxr_report;

/* ----------------------------------------------------------------------- */

BEGIN
   CACHE_DELIMITER  := fnd_global.local_chr(0);

   fnd_plsql_cache.generic_1to1_init('SV2.GKS',
                                     gks_cache_controller,
                                     gks_cache_storage);

   fnd_plsql_cache.generic_1to1_init('SV2.GDS',
                                     gds_cache_controller,
                                     gds_cache_storage);

   fnd_plsql_cache.generic_1to1_init('SV2.XVC',
                                     xvc_cache_controller,
                                     xvc_cache_storage);

   fnd_plsql_cache.generic_1tom_init('SV2.COC',
                                     coc_cache_controller,
                                     coc_cache_storage);

   fnd_plsql_cache.generic_1tom_init('SV2.GAS',
                                     gas_cache_controller,
                                     gas_cache_storage);

   fnd_plsql_cache.generic_1tom_init('SV2.GQS',
                                     gqs_cache_controller,
                                     gqs_cache_storage);

END fnd_flex_server2;

/
