--------------------------------------------------------
--  DDL for Package Body FND_FLEX_SERVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FLEX_SERVER" AS
/* $Header: AFFFSSVB.pls 120.13.12010000.23 2017/02/13 22:42:28 tebarnes ship $ */

--------
-- PRIVATE TYPES
--

TYPE ValattRqst IS RECORD
  (nrqstd                          NUMBER,
   fq_names                        FND_FLEX_SERVER1.QualNameArray,
   sq_names                        FND_FLEX_SERVER1.QualNameArray);

TYPE DerivedRqst IS RECORD
  (nrqstd                          NUMBER,
   sq_names                        FND_FLEX_SERVER1.QualNameArray);


-- ======================================================================
-- Caching.
-- ======================================================================
g_cache_return_code VARCHAR2(30);
g_cache_key         VARCHAR2(2000);
g_cache_index       BINARY_INTEGER;
g_cache_value       fnd_plsql_cache.generic_cache_value_type;
g_newline           VARCHAR2(8);

-- --------------------------------------------------
-- vst : Value set cache.
-- --------------------------------------------------
TYPE vst_cache_storage_table_type IS TABLE OF fnd_flex_value_sets%ROWTYPE
  INDEX BY BINARY_INTEGER;

vst_cache_controller      fnd_plsql_cache.cache_1to1_controller_type;
vst_cache_storage         vst_cache_storage_table_type;

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

-- --------------------------------------------------
-- Get KFV Concat Segs: Select Statement Cache
-- --------------------------------------------------
TYPE kfvssc_record_type IS RECORD
  (compact_sql              VARCHAR2(32000),
   padded_sql               VARCHAR2(32000),
   set_defining_column_name fnd_id_flexs.set_defining_column_name%TYPE,
   unique_id_column_name    fnd_id_flexs.unique_id_column_name%TYPE);

TYPE kfvssc_table_type IS TABLE OF kfvssc_record_type INDEX BY BINARY_INTEGER;

kfvssc_cache_controller      fnd_plsql_cache.cache_1to1_controller_type;
kfvssc_cache_storage         kfvssc_table_type;

-- --------------------------------------------------
-- Get KFV Concat Segs: Code Combination Table Info Cache
-- --------------------------------------------------
TYPE kfvcct_record_type IS RECORD
  (table_application_id     fnd_id_flexs.table_application_id%TYPE,
   application_table_name   fnd_id_flexs.application_table_name%TYPE,
   table_id                 fnd_tables.table_id%TYPE,
   set_defining_column_name fnd_id_flexs.set_defining_column_name%TYPE,
   unique_id_column_name    fnd_id_flexs.unique_id_column_name%TYPE);

TYPE kfvcct_table_type IS TABLE OF kfvcct_record_type INDEX BY BINARY_INTEGER;

kfvcct_cache_controller     fnd_plsql_cache.cache_1to1_controller_type;
kfvcct_cache_storage        kfvcct_table_type;

TYPE table_of_varchar2_32000 IS TABLE OF VARCHAR2(32000)
  INDEX BY BINARY_INTEGER;

g_non_forms_warnings       table_of_varchar2_32000;
g_non_forms_warnings_count NUMBER;

FLEX_PREFIX                   CONSTANT VARCHAR2(7) := '$FLEX$.';
FLEX_PREFIX_LEN               CONSTANT NUMBER := 7;

PROFILE_PREFIX                CONSTANT VARCHAR2(11) := '$PROFILES$.';
PROFILE_PREFIX_LEN            CONSTANT NUMBER := 11;

FF_SEGMENT                    CONSTANT VARCHAR2(1) := 'S';
FF_PROFILE                    CONSTANT VARCHAR2(1) := 'P';
FF_FIELD                      CONSTANT VARCHAR2(1) := 'F';

FLEX_BIND_CHARS       CONSTANT VARCHAR2(150) := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_$#.:*';

------------
-- PRIVATE CONSTANTS
--
MAX_NSEGS             CONSTANT NUMBER := 30;
MAX_CCID              CONSTANT NUMBER := 2000000000;
NHASH                 CONSTANT NUMBER := 997;
DATE_PASS_FORMAT      CONSTANT VARCHAR2(1) := 'J';
DRV_DATE_FMT          CONSTANT VARCHAR2(9) := 'DD-MON-RR';
DATE_TEST_FMT         CONSTANT VARCHAR2(11) := 'DD-MON-YYYY';
DATE_DEBUG_FMT        CONSTANT VARCHAR2(9) := 'DD-MON-RR';
MAX_ARG_LEN           CONSTANT NUMBER := 1950;
MAX_CATSEG_LEN        CONSTANT NUMBER := 2001;
BLANKS                VARCHAR2(4); -- := FND_FLEX_SERVER1.WHITESPACE;
-------------
-- EXCEPTIONS
--

/* -------------------------------------------------------------------- */
/*                        Private global variables                      */
/* -------------------------------------------------------------------- */

-- SQL string for dynamic SQL processing
sqls          VARCHAR2(30000);
g_debug_text  VARCHAR2(2000);

--  Determines whether or not to call FDFGLI after inserting
--  new combination into accounting flexfield.
--
fdfgli_on     BOOLEAN := TRUE;

--  Determines whether or not to call user validation function
--  FND_FLEX_SERVER.VALIDATE just before inserting a new combination.
--
userval_on    BOOLEAN := TRUE;

--
-- ARCS Revision identifier for SQL statements
--
g_arcs_revision  VARCHAR2(32000);

/* -------------------------------------------------------------------- */
/*                        Private definitions                           */
/* -------------------------------------------------------------------- */
  FUNCTION insert_combination(fstruct   IN  FND_FLEX_SERVER1.FlexStructId,
                              structnum IN  NUMBER,
                              maintmode IN  BOOLEAN,
                              v_date    IN  DATE,
                              seg_delim IN  VARCHAR2,
                              ccid_inp  IN  NUMBER,
                              combtbl   IN  FND_FLEX_SERVER1.CombTblInfo,
                              combcols  IN  FND_FLEX_SERVER1.TabColArray,
                              combtypes IN  FND_FLEX_SERVER1.CharArray,
                              user_id   IN  NUMBER,
                              nsegs     IN  NUMBER,
                              segids_in IN  FND_FLEX_SERVER1.ValueIdArray,
                              segfmts   IN  FND_FLEX_SERVER1.SegFormats,
                              dvalues   IN  FND_FLEX_SERVER1.DerivedVals,
                              dquals    IN  FND_FLEX_SERVER1.Qualifiers,
                              nxcols    IN  NUMBER,
                              xcolnames IN  FND_FLEX_SERVER1.StringArray,
                              xcolvals  OUT nocopy FND_FLEX_SERVER1.StringArray,
                              qualvals  OUT nocopy FND_FLEX_SERVER1.ValAttribArray,
                              tblderv   OUT nocopy FND_FLEX_SERVER1.DerivedVals,
                              newcomb   OUT nocopy BOOLEAN,
                              ccid_out  OUT nocopy NUMBER) RETURN BOOLEAN;

  FUNCTION hash_segs(n IN NUMBER,
                     segs IN FND_FLEX_SERVER1.ValueIdArray) RETURN NUMBER;


  FUNCTION call_userval(fstruct   IN  FND_FLEX_SERVER1.FlexStructId,
                        vdate     IN  DATE,
                        nids      IN  NUMBER,
                        delim     IN  VARCHAR2,
                        segids    IN  FND_FLEX_SERVER1.ValueIdArray)
                                                         RETURN BOOLEAN;

  FUNCTION check_table_comb(t_dval          IN  FND_FLEX_SERVER1.DerivedVals,
                            t_quals         IN  FND_FLEX_SERVER1.Qualifiers,
                            v_rules         IN  FND_FLEX_SERVER1.Vrules,
                            v_date          IN  DATE,
                            check_effective IN  BOOLEAN) RETURN NUMBER;


  FUNCTION find_column_index(column_list  IN  FND_FLEX_SERVER1.TabColArray,
                             column_count IN  NUMBER,
                             colname      IN  VARCHAR2) RETURN NUMBER;

  FUNCTION concatenate_fulldescs(ndescs  IN NUMBER,
                                 descs   IN FND_FLEX_SERVER1.ValueDescArray,
                                 displ   IN FND_FLEX_SERVER1.DisplayedSegs,
                                 delimiter      IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION concatenate_segment_formats(segfmts IN FND_FLEX_SERVER1.SegFormats)
                                                            RETURN VARCHAR2;

  FUNCTION ret_derived(d_quals  IN  FND_FLEX_SERVER1.Qualifiers,
                       drv      IN  FND_FLEX_SERVER1.DerivedVals,
                       d_rqst   IN  DerivedRqst) RETURN VARCHAR2;

  FUNCTION ret_valatts(d_quals  IN  FND_FLEX_SERVER1.Qualifiers,
                       drv      IN  FND_FLEX_SERVER1.DerivedVals,
                       v_rqst   IN  ValattRqst) RETURN VARCHAR2;

  FUNCTION parse_va_rqst(s IN VARCHAR2, var OUT nocopy ValattRqst) RETURN NUMBER;

  FUNCTION parse_drv_rqst(s IN VARCHAR2, dr OUT nocopy DerivedRqst) RETURN NUMBER;

  FUNCTION parse_vrules(s IN VARCHAR2,
                        vr OUT nocopy FND_FLEX_SERVER1.Vrules) RETURN NUMBER;

  FUNCTION parse_set_msg(p_msg IN VARCHAR2) RETURN BOOLEAN;

  FUNCTION evaluate_token(token_str  IN  VARCHAR2,
                          n_segs     IN  NUMBER,
                          fq_tab     IN  FND_FLEX_SERVER1.FlexQualTable,
                          token_map  OUT nocopy FND_FLEX_SERVER1.BooleanArray)
                                                            RETURN BOOLEAN;

  FUNCTION call_fdfgli(ccid IN NUMBER) RETURN BOOLEAN;

/* ----------------------------------------------------------------------- */
/*                      Private Functions                                  */
/* ----------------------------------------------------------------------- */

/* ----------------------------------------------------------------------- */
/*              Validates flexfield concatenated segment array             */
/*      Returns 0 if invalid, 1 if valid.  If valid ccid is id of          */
/*      code combination and message is null.  If invalid ccid is 0        */
/*      and message says why its invalid.                                  */
/* ----------------------------------------------------------------------- */

FUNCTION v_comb(user_apid       IN      NUMBER,
                user_resp       IN      NUMBER,
                userid          IN      NUMBER,
                flex_app_sname  IN      VARCHAR2,
                flex_code       IN      VARCHAR2,
                flex_num        IN      NUMBER,
                vdate           IN      VARCHAR2,
                vrulestr        IN      VARCHAR2,
                data_set        IN      NUMBER,
                invoking_mode   IN      VARCHAR2,
                validate_mode   IN      VARCHAR2,
                dinsert         IN      VARCHAR2,
                qsecurity       IN      VARCHAR2,
                required        IN      VARCHAR2,
                allow_nulls     IN      VARCHAR2,
                display_segs    IN      VARCHAR2,
                concat_segs     IN      VARCHAR2,
                vals_or_ids     IN      VARCHAR2,
                where_clause    IN      VARCHAR2,
                extra_cols      IN      VARCHAR2,
                get_valatts     IN      VARCHAR2,
                get_derived     IN      VARCHAR2,
                ccid            IN      NUMBER) RETURN VARCHAR2 IS


  cat_vals              VARCHAR2(5000);
  cat_ids               VARCHAR2(5000);
  cat_desc              VARCHAR2(5000);
  xtra_cols             VARCHAR2(2000);
  valatts               VARCHAR2(2000);
  derived               VARCHAR2(2000);
  valid_d               VARCHAR2(30);
  start_d               VARCHAR2(30);
  end_d                 VARCHAR2(30);
  enab_flag             VARCHAR2(1);
  sum_flag              VARCHAR2(1);
  ccid_o                NUMBER;
  v_stat                NUMBER;
  s_stat                VARCHAR2(30);
  errseg                NUMBER;
  dlim                  VARCHAR2(1);
  retmsg                VARCHAR2(2000);
  retstr                VARCHAR2(15000);

  BEGIN

   valid_d := to_char(to_date(vdate, DATE_TEST_FMT), DATE_PASS_FORMAT);
   validate_combination(user_apid, user_resp, userid, flex_app_sname,flex_code,
                        flex_num, valid_d, vrulestr, data_set, invoking_mode,
                        validate_mode, dinsert, qsecurity, required,
                        allow_nulls, display_segs, concat_segs, vals_or_ids,
                        cat_vals, cat_ids, cat_desc, where_clause,
                        extra_cols, xtra_cols, get_valatts, valatts,
                        get_derived, derived, start_d, end_d, enab_flag,
                        sum_flag, dlim, ccid, ccid_o, v_stat,
                        s_stat, errseg, retmsg,NULL,NULL,NULL,NULL);

  start_d := to_char(to_date(start_d, DATE_PASS_FORMAT), DATE_TEST_FMT);
  end_d := to_char(to_date(end_d, DATE_PASS_FORMAT), DATE_TEST_FMT);

-- Translate returned encoded message
--
  FND_MESSAGE.set_encoded(retmsg);
  retmsg := FND_MESSAGE.get;

  retstr := 'VStatus: ' || to_char(v_stat);
  retstr := retstr || ' CCID: ' || to_char(ccid_o);
  retstr := retstr || ' Vals: ' || cat_vals;
  retstr := retstr || ' Ids: ' || cat_ids;
  retstr := retstr || ' Descs: ' || cat_desc;
  retstr := retstr || ' ExtraCols: ' || xtra_cols;
  retstr := retstr || ' ValAtts: ' || valatts;
  retstr := retstr || ' Derived: ' || derived;
  retstr := retstr || ' StartDate: ' || start_d;
  retstr := retstr || ' EndDate: ' || end_d;
  retstr := retstr || ' Enab: ' || enab_flag;
  retstr := retstr || ' Summary: ' || sum_flag;
  retstr := retstr || ' Delimiter: ' || dlim;
  retstr := retstr || ' SegCodes: ' || s_stat;
  retstr := retstr || ' ErrSeg: ' || to_char(errseg);
  retstr := retstr || ' Msg: ' || retmsg;
  retstr := retstr || ' Debug: ' || get_debug(1);

  return(SUBSTRB(retstr, 1, 1950));

  END v_comb;

/* ----------------------------------------------------------------------- */
/*      Stub for testing validate_descflex()                               */
/* ----------------------------------------------------------------------- */

FUNCTION v_desc(user_apid       IN      NUMBER,
                user_resp       IN      NUMBER,
                userid          IN      NUMBER,
                flex_app_sname  IN      VARCHAR2,
                desc_flex_name  IN      VARCHAR2,
                vdate           IN      VARCHAR2,
                invoking_mode   IN      VARCHAR2,
                allow_nulls     IN      VARCHAR2,
                update_table    IN      VARCHAR2,
                eff_activation  IN      VARCHAR2,
                concat_segs     IN      VARCHAR2,
                vals_or_ids     IN      VARCHAR2,
                c_rowid         IN      VARCHAR2,
                alternate_table IN      VARCHAR2,
                data_field      IN      VARCHAR2) RETURN VARCHAR2 IS

  valid_d               VARCHAR2(30);
  cat_vals              VARCHAR2(5000);
  cat_ids               VARCHAR2(5000);
  cat_desc              VARCHAR2(5000);
  v_stat                NUMBER;
  s_stat                VARCHAR2(30);
  errseg                NUMBER;
  dlim                  VARCHAR2(1);
  retmsg                VARCHAR2(2000);
  retstr                VARCHAR2(15000);

  BEGIN

   valid_d := to_char(to_date(vdate, DATE_TEST_FMT), DATE_PASS_FORMAT);

   validate_descflex(user_apid, user_resp, userid, flex_app_sname,
                     desc_flex_name, valid_d, invoking_mode, allow_nulls,
                     update_table, eff_activation, concat_segs, vals_or_ids,
                     c_rowid, alternate_table, data_field, cat_vals,
                     cat_ids, cat_desc, dlim, v_stat, s_stat, errseg, retmsg);

-- Translate returned encoded message
--
  FND_MESSAGE.set_encoded(retmsg);
  retmsg := FND_MESSAGE.get;

  retstr := 'VStatus: ' || to_char(v_stat);
  retstr := retstr || ' Vals: ' || cat_vals;
  retstr := retstr || ' Ids: ' || cat_ids;
  retstr := retstr || ' Descs: ' || cat_desc;
  retstr := retstr || ' Delimiter: ' || dlim;
  retstr := retstr || ' SegCodes: ' || s_stat;
  retstr := retstr || ' ErrSeg: ' || to_char(errseg);
  retstr := retstr || ' Msg: ' || retmsg;
  retstr := retstr || ' Debug: ' || get_debug(1);

  return(SUBSTRB(retstr, 1, 1950));

  END v_desc;

/* ----------------------------------------------------------------------- */
/*      Test function for debugging pre_window()                           */
/* ----------------------------------------------------------------------- */

 FUNCTION p_win(user_apid       IN      NUMBER,
                user_resp       IN      NUMBER,
                flex_app_sname  IN      VARCHAR2,
                flex_code       IN      VARCHAR2,
                flex_num        IN      NUMBER,
                vdate           IN      VARCHAR2,
                vrulestr        IN      VARCHAR2,
                display_segs    IN      VARCHAR2,
                concat_segs     IN      VARCHAR2) RETURN VARCHAR2 IS

  n_segs        NUMBER;
  errsegn       NUMBER;
  v_stat        NUMBER;
  valid_d       VARCHAR2(30);
  cat_vals      VARCHAR2(5000);
  cat_ids       VARCHAR2(5000);
  cat_desc      VARCHAR2(5000);
  retmsg        VARCHAR2(2000);
  retstr        VARCHAR2(15000);
  dlim          VARCHAR2(1);
  seg_fmts      VARCHAR2(180);
  seg_codes     VARCHAR2(30);

  BEGIN

   valid_d := to_char(to_date(vdate, DATE_TEST_FMT), DATE_PASS_FORMAT);
   pre_window(user_apid, user_resp, flex_app_sname, flex_code, flex_num,
              valid_d, vrulestr, display_segs, concat_segs, cat_vals, cat_ids,
              cat_desc, dlim, seg_fmts, seg_codes, n_segs, v_stat, errsegn,
              retmsg);

-- Translate returned encoded message
--
  FND_MESSAGE.set_encoded(retmsg);
  retmsg := FND_MESSAGE.get;

  retstr := 'VStatus: ' || to_char(v_stat);
  retstr := retstr || ' Nsegs: ' || to_char(n_segs);
  retstr := retstr || ' Vals: ' || cat_vals;
  retstr := retstr || ' Ids: ' || cat_ids;
  retstr := retstr || ' Descs: ' || cat_desc;
  retstr := retstr || ' Delimiter: ' || dlim;
  retstr := retstr || ' Formats: ' || seg_fmts;
  retstr := retstr || ' SegCodes: ' || seg_codes;
  retstr := retstr || ' ErrSeg: ' || to_char(errsegn);
  retstr := retstr || ' Msg: ' || retmsg;
  retstr := retstr || ' Debug: ' || get_debug(1);

  return(SUBSTRB(retstr, 1, 1950));

  END p_win;

/* ----------------------------------------------------------------------- */
/*      Test function for debugging segment_maps()                         */
/* ----------------------------------------------------------------------- */

FUNCTION s_maps(flex_app_sname  IN      VARCHAR2,
                flex_code       IN      VARCHAR2,
                flex_num        IN      NUMBER,
                insert_tok      IN      VARCHAR2,
                update_tok      IN      VARCHAR2,
                display_tok     IN      VARCHAR2) RETURN VARCHAR2 IS

  n_segs        NUMBER;
  insrt_map     VARCHAR2(30);
  updat_map     VARCHAR2(30);
  dspl_map      VARCHAR2(30);
  reqd_map      VARCHAR2(30);
  retmsg        VARCHAR2(2000);
  retstr        VARCHAR2(5000);

  BEGIN

   segment_maps(flex_app_sname, flex_code, flex_num, insert_tok, update_tok,
                display_tok, insrt_map, updat_map, dspl_map, reqd_map,
                n_segs, retmsg);

-- Translate returned encoded message
--
  FND_MESSAGE.set_encoded(retmsg);
  retmsg := FND_MESSAGE.get;

  retstr := retstr || ' Insertable: ' || insrt_map;
  retstr := retstr || ' Updatable: ' || updat_map;
  retstr := retstr || ' Displayable: ' || dspl_map;
  retstr := retstr || ' Required: ' || reqd_map;
  retstr := retstr || ' Nsegs: ' || to_char(n_segs);
  retstr := retstr || ' Msg: ' || retmsg;
  retstr := retstr || ' Debug: ' || get_debug(1);

  return(SUBSTRB(retstr, 1, 1950));

  END s_maps;

/* ----------------------------------------------------------------------- */
/*      Test function for debugging segs_secured()                         */
/* ----------------------------------------------------------------------- */

 FUNCTION s_sec(resp_apid       IN      NUMBER,
                resp_id         IN      NUMBER,
                flex_app_sname  IN      VARCHAR2,
                flex_code       IN      VARCHAR2,
                flex_num        IN      NUMBER,
                display_segs    IN      VARCHAR2,
                concat_segs     IN      VARCHAR2) RETURN VARCHAR2 IS

  segnum        NUMBER;
  retmsg        VARCHAR2(2000);
  retstr        VARCHAR2(15000);

  BEGIN

   segs_secured(resp_apid, resp_id, flex_app_sname, flex_code, flex_num,
                    display_segs, concat_segs, segnum, retmsg);

-- Translate returned encoded message
--
  FND_MESSAGE.set_encoded(retmsg);
  retmsg := FND_MESSAGE.get;

  retstr := retstr || 'Secured_segment: ' || to_char(segnum);
  retstr := retstr || ' Msg: ' || retmsg;
  retstr := retstr || ' Debug: ' || get_debug(1);

  return(SUBSTRB(retstr, 1, 1950));

  END s_sec;

/* ------------------------------------------------------------------------  */
/*      Clear all flexfield server validation caches.                        */
/* ------------------------------------------------------------------------  */

  PROCEDURE clear_cache IS
    BEGIN
    FND_FLEX_SERVER2.x_clear_cv_cache;
  END clear_cache;

/* ------------------------------------------------------------------------  */
/*      Externalized function so client can use hash-lock mechanism.         */
/*      Computes and locks hash value from ids passed in.                    */
/*      Returns hash number 0-999 or sets FND_MESSAGE and returns < 0        */
/*      if error.                                                            */
/* ------------------------------------------------------------------------  */

  FUNCTION hash_lock(application_id  IN  NUMBER,
                     id_flex_code    IN  VARCHAR2,
                     id_flex_num     IN  NUMBER,
                     delimiter       IN  VARCHAR2,
                     concat_ids      IN  VARCHAR2) RETURN NUMBER IS

    deadlock    EXCEPTION;
    nsegs       NUMBER;
    hash_num    NUMBER;
    hash_number NUMBER;
    idsegs      FND_FLEX_SERVER1.StringArray;
    segids      FND_FLEX_SERVER1.ValueIdArray;
    kff_id      FND_FLEX_SERVER1.FlexStructId;
    disp_segs   FND_FLEX_SERVER1.DisplayedSegs;

    PRAGMA EXCEPTION_INIT(deadlock, -60);

  BEGIN
--  Find out how many segments are displayed and
--  convert concatenated segments to array and check there are not too many.
--
    kff_id.application_id := application_id;
    kff_id.id_flex_code := id_flex_code;
    kff_id.id_flex_num := id_flex_num;
    /* Bug 4772388. Explicitly set kff_id.isa_key_flexfield to TRUE
       as otherwise we were getting hash_number of 0 always. */
    kff_id.isa_key_flexfield := TRUE;

    if((parse_displayed(kff_id, 'ALL', disp_segs) = FALSE) or
       (FND_FLEX_SERVER2.breakup_catsegs(concat_ids, delimiter, FALSE,
                        disp_segs, nsegs, idsegs) = FALSE)) then
      return(-20);
    end if;

    for i in 1..nsegs loop
      segids(i) := idsegs(i);
    end loop;

    hash_number := hash_segs(nsegs, segids);
    if(hash_number >= 0) then
      SELECT hash_value INTO hash_num FROM fnd_flex_hash
       WHERE hash_value = hash_number FOR UPDATE;
    end if;
    return(hash_number);

  EXCEPTION
    WHEN deadlock then
      FND_MESSAGE.set_name('FND', 'FLEX-HASH DEADLOCK');
      return(-60);
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG','hash_lock() exception: ' || SQLERRM);
      return(-10);

  END hash_lock;


  FUNCTION client_hash_lock(application_id  IN  NUMBER,
                            id_flex_code    IN  VARCHAR2,
                            id_flex_num     IN  NUMBER,
                            delimiter       IN  VARCHAR2,
                            concat_ids      IN  VARCHAR2,
                            x_message       OUT nocopy VARCHAR2)
    RETURN NUMBER
    IS
       l_message VARCHAR2(2000);
       l_encoded_message VARCHAR2(2000);
       l_number NUMBER;
  BEGIN
     l_message := '';
     l_encoded_message := '';
     l_number := hash_lock(application_id,
                           id_flex_code,
                           id_flex_num,
                           delimiter,
                           concat_ids);
     IF (l_number < 0) THEN
        l_encoded_message := fnd_message.get_encoded;
        fnd_message.set_encoded(l_encoded_message);
        l_message := fnd_message.get;
        fnd_message.set_encoded(l_encoded_message);
     END IF;
     x_message := l_message;
     RETURN(l_number);
  EXCEPTION
     WHEN OTHERS THEN
        --
        -- This part is to take care of fnd_message exceptions.
        -- I cannot call fnd_message here. Just return hard coded
        -- error message.
        --
        x_message := 'FLEX : client_hash_lock() exception:' ||Sqlerrm;
        return(-99);
  END client_hash_lock;


/* ------------------------------------------------------------------------  */
/*      The general purpose interface to the client c-code                   */
/* ------------------------------------------------------------------------  */

PROCEDURE validate_combination
                       (user_apid       IN      NUMBER,
                        user_resp       IN      NUMBER,
                        userid          IN      NUMBER,
                        flex_app_sname  IN      VARCHAR2,
                        flex_code       IN      VARCHAR2,
                        flex_num        IN      NUMBER,
                        vdate           IN      VARCHAR2,
                        vrulestr        IN      VARCHAR2,
                        data_set        IN      NUMBER,
                        invoking_mode   IN      VARCHAR2,
                        validate_mode   IN      VARCHAR2,
                        dinsert         IN      VARCHAR2,
                        qsecurity       IN      VARCHAR2,
                        required        IN      VARCHAR2,
                        allow_nulls     IN      VARCHAR2,
                        display_segs    IN      VARCHAR2,
                        concat_segs     IN      VARCHAR2,
                        vals_or_ids     IN      VARCHAR2,
                        concat_vals_out OUT     nocopy VARCHAR2,
                        concat_ids_out  OUT     nocopy VARCHAR2,
                        concat_desc     OUT     nocopy VARCHAR2,
                        where_clause    IN      VARCHAR2,
                        get_extra_cols  IN      VARCHAR2,
                        extra_cols      OUT     nocopy VARCHAR2,
                        get_valatts     IN      VARCHAR2,
                        valatts         OUT     nocopy VARCHAR2,
                        get_derived     IN      VARCHAR2,
                        derived_vals    OUT     nocopy VARCHAR2,
                        start_date      OUT     nocopy VARCHAR2,
                        end_date        OUT     nocopy VARCHAR2,
                        enabled_flag    OUT     nocopy VARCHAR2,
                        summary_flag    OUT     nocopy VARCHAR2,
                        seg_delimiter   OUT     nocopy VARCHAR2,
                        ccid_in         IN      NUMBER,
                        ccid_out        OUT     nocopy NUMBER,
                        vstatus         OUT     nocopy NUMBER,
                        segcodes        OUT     nocopy VARCHAR2,
                        error_seg       OUT     nocopy NUMBER,
                        message         OUT     nocopy VARCHAR2,
                        select_comb_from_view IN VARCHAR2,
                        no_combmsg       IN     VARCHAR2,
                        where_clause_msg IN     VARCHAR2,
                        server_debug_mode IN    VARCHAR2)
  IS
     v_date             DATE;
     rq_dqual           DerivedRqst;
     rq_valat           ValattRqst;
     nvalidated         NUMBER;
     value_dvals        FND_FLEX_SERVER1.ValueArray;
     value_vals         FND_FLEX_SERVER1.ValueArray;
     value_ids          FND_FLEX_SERVER1.ValueIdArray;
     value_descs        FND_FLEX_SERVER1.ValueDescArray;
     value_desclens     FND_FLEX_SERVER1.NumberArray;
     cc_cols            FND_FLEX_SERVER1.TabColArray;
     cc_coltypes        FND_FLEX_SERVER1.CharArray;
     segtypes           FND_FLEX_SERVER1.SegFormats;
     disp_segs          FND_FLEX_SERVER1.DisplayedSegs;
     derv               FND_FLEX_SERVER1.DerivedVals;
     tbl_derv           FND_FLEX_SERVER1.DerivedVals;
     drv_quals          FND_FLEX_SERVER1.Qualifiers;
     tbl_quals          FND_FLEX_SERVER1.Qualifiers;
     n_xcol_vals        NUMBER;
     xcol_vals          FND_FLEX_SERVER1.StringArray;
     delim              VARCHAR2(1);
     new_comb           BOOLEAN;
BEGIN
   fnd_flex_server1.set_debugging(server_debug_mode);

   IF (fnd_flex_server1.g_debug_level > 0) THEN
       fnd_flex_server1.add_debug('BEGIN SSV.validate_combination()');
       fnd_flex_server1.add_debug('Input Parameters:');
       FND_FLEX_SERVER1.add_debug('user_apid = ' || to_char(user_apid));
       FND_FLEX_SERVER1.add_debug('user_resp = ' || to_char(user_resp));
       FND_FLEX_SERVER1.add_debug('userid = ' || to_char(userid));
       FND_FLEX_SERVER1.add_debug('flex_app_sname = ' || flex_app_sname);
       FND_FLEX_SERVER1.add_debug('flex_code = ' || flex_code);
       FND_FLEX_SERVER1.add_debug('flex_num = ' || to_char(flex_num));
       FND_FLEX_SERVER1.add_debug('vdate = ' || vdate);
       FND_FLEX_SERVER1.add_debug('vrulestr = ' || vrulestr);
       FND_FLEX_SERVER1.add_debug('data_set = ' || to_char(data_set));
       FND_FLEX_SERVER1.add_debug('invoking_mode = ' || invoking_mode);
       FND_FLEX_SERVER1.add_debug('validate_mode = ' || validate_mode);
       FND_FLEX_SERVER1.add_debug('dinsert = ' || dinsert);
       FND_FLEX_SERVER1.add_debug('qsecurity = ' || qsecurity);
       FND_FLEX_SERVER1.add_debug('required = ' || required);
       FND_FLEX_SERVER1.add_debug('allow_nulls = ' || allow_nulls);
       FND_FLEX_SERVER1.add_debug('display_segs = ' || display_segs);
       FND_FLEX_SERVER1.add_debug('concat_segs = ' || concat_segs);
       FND_FLEX_SERVER1.add_debug('vals_or_ids = ' || vals_or_ids);
       FND_FLEX_SERVER1.add_debug('where_clause = ' || where_clause);
       FND_FLEX_SERVER1.add_debug('get_extra_cols = ' || get_extra_cols);
       FND_FLEX_SERVER1.add_debug('get_valatts = ' || get_valatts);
       FND_FLEX_SERVER1.add_debug('get_derived = ' || get_derived);
       FND_FLEX_SERVER1.add_debug('ccid_in = ' || to_char(ccid_in));
       FND_FLEX_SERVER1.add_debug('select_comb_from_view = ' || select_comb_from_view);
       FND_FLEX_SERVER1.add_debug('no_combmsg = ' || no_combmsg);
       FND_FLEX_SERVER1.add_debug('where_clause_msg = ' || where_clause_msg);
       FND_FLEX_SERVER1.add_debug('server_debug_mode = ' || server_debug_mode);
   END IF;

   -- Initialize globals, parse qualifier requests.
   -- If ok, then validate and return results.
   -- Otherwise return error and message.
   --

   if((FND_FLEX_SERVER1.init_globals) and
      (parse_drv_rqst(get_derived, rq_dqual) >= 0) and
      (parse_va_rqst(get_valatts, rq_valat) >= 0)) then

      --  Client passes in julian date of 0 to mean null vdate
      --
      if(vdate = '0') then
         v_date := NULL;
       else
         v_date := to_date(vdate, DATE_PASS_FORMAT);
      end if;

      validation_engine
        (user_apid, user_resp, userid, flex_app_sname,
         flex_code, select_comb_from_view,
         flex_num, v_date, vrulestr, data_set, invoking_mode,
         validate_mode, dinsert, qsecurity, required, allow_nulls,
         display_segs, concat_segs, vals_or_ids, where_clause,
         no_combmsg, where_clause_msg,
         get_extra_cols, ccid_in, nvalidated, value_dvals, value_vals,
         value_ids, value_descs, value_desclens, cc_cols, cc_coltypes,
         segtypes, disp_segs, derv, tbl_derv, drv_quals, tbl_quals,
         n_xcol_vals, xcol_vals, delim, ccid_out, new_comb, vstatus,
         segcodes, error_seg);

      --  Return requested outputs as concatenated strings.
      --
      IF (vstatus <> FND_FLEX_SERVER1.vv_error) THEN
         concat_vals_out := concatenate_values(nvalidated, value_dvals,
                                               disp_segs, delim);
         concat_ids_out := concatenate_ids(nvalidated, value_ids, delim);
         concat_desc := concatenate_fulldescs(nvalidated, value_descs,
                                              disp_segs, delim);
         derived_vals := ret_derived(drv_quals, derv, rq_dqual);
         valatts := ret_valatts(drv_quals, derv, rq_valat);
         extra_cols := FND_FLEX_SERVER1.from_stringarray2
           (n_xcol_vals, xcol_vals,
            FND_FLEX_SERVER1.TERMINATOR);
         start_date := to_char(derv.start_valid, DATE_PASS_FORMAT);
         end_date := to_char(derv.end_valid, DATE_PASS_FORMAT);
         enabled_flag := derv.enabled_flag;
         summary_flag := derv.summary_flag;
         seg_delimiter := delim;
       ELSE
         concat_vals_out := NULL;
         concat_ids_out := NULL;
         concat_desc := NULL;
         extra_cols := NULL;
         valatts := NULL;
         derived_vals := NULL;
         start_date := NULL;
         end_date := NULL;
         enabled_flag := NULL;
         summary_flag := NULL;
         seg_delimiter := NULL;
      END IF;
      GOTO goto_return;
   end if;

   vstatus := FND_FLEX_SERVER1.VV_ERROR;

   <<goto_return>>

   message := FND_MESSAGE.get_encoded;
   IF (fnd_flex_server1.g_debug_level > 0) THEN
      fnd_flex_server1.add_debug('END SSV.validate_combination()');
      fnd_flex_server1.add_debug('Output Parameters:');
      FND_FLEX_SERVER1.add_debug('concat_vals_out = ' || concat_vals_out);
      FND_FLEX_SERVER1.add_debug('concat_ids_out = ' || concat_ids_out);
      FND_FLEX_SERVER1.add_debug('concat_desc = ' || concat_desc);
      FND_FLEX_SERVER1.add_debug('extra_cols = ' || extra_cols);
      FND_FLEX_SERVER1.add_debug('valatts = ' || valatts);
      FND_FLEX_SERVER1.add_debug('derived_vals = ' || derived_vals);
      FND_FLEX_SERVER1.add_debug('start_date = ' || start_date);
      FND_FLEX_SERVER1.add_debug('end_date = ' || end_date);
      FND_FLEX_SERVER1.add_debug('enabled_flag = ' || enabled_flag);
      FND_FLEX_SERVER1.add_debug('summary_flag = ' || summary_flag);
      FND_FLEX_SERVER1.add_debug('seg_delimiter = ' || seg_delimiter);
      FND_FLEX_SERVER1.add_debug('ccid_out = ' || to_char(ccid_out));
      FND_FLEX_SERVER1.add_debug('vstatus = ' || to_char(vstatus));
      FND_FLEX_SERVER1.add_debug('segcodes = ' || segcodes);
      FND_FLEX_SERVER1.add_debug('error_seg = ' || to_char(error_seg));
      FND_FLEX_SERVER1.add_debug('message = ' || message);
      fnd_flex_server1.add_debug('EXIT SSV.validate_combination()');
   END IF;
   return;

EXCEPTION
   WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG','SV1.validate_combination() exception: '||SQLERRM);
      message := FND_MESSAGE.get_encoded;
      vstatus := FND_FLEX_SERVER1.VV_ERROR;
      IF (fnd_flex_server1.g_debug_level > 0) THEN
         fnd_flex_server1.add_debug ('EXCEPTION others SSV.validate_combination()');
         fnd_flex_server1.add_debug('Output Parameters:');
         FND_FLEX_SERVER1.add_debug('concat_vals_out = ' || concat_vals_out);
         FND_FLEX_SERVER1.add_debug('concat_ids_out = ' || concat_ids_out);
         FND_FLEX_SERVER1.add_debug('concat_desc = ' || concat_desc);
         FND_FLEX_SERVER1.add_debug('extra_cols = ' || extra_cols);
         FND_FLEX_SERVER1.add_debug('valatts = ' || valatts);
         FND_FLEX_SERVER1.add_debug('derived_vals = ' || derived_vals);
         FND_FLEX_SERVER1.add_debug('start_date = ' || start_date);
         FND_FLEX_SERVER1.add_debug('end_date = ' || end_date);
         FND_FLEX_SERVER1.add_debug('enabled_flag = ' || enabled_flag);
         FND_FLEX_SERVER1.add_debug('summary_flag = ' || summary_flag);
         FND_FLEX_SERVER1.add_debug('seg_delimiter = ' || seg_delimiter);
         FND_FLEX_SERVER1.add_debug('ccid_out = ' || to_char(ccid_out));
         FND_FLEX_SERVER1.add_debug('vstatus = ' || to_char(vstatus));
         FND_FLEX_SERVER1.add_debug('segcodes = ' || segcodes);
         FND_FLEX_SERVER1.add_debug('error_seg = ' || to_char(error_seg));
         FND_FLEX_SERVER1.add_debug('message = ' || message);
         fnd_flex_server1.add_debug ('EXIT SSV.validate_combination()');
      END IF;
      return;
END validate_combination;

/* ------------------------------------------------------------------------ */
/*      General purpose interface to the client c-code for descr flexs      */
/* ------------------------------------------------------------------------ */

PROCEDURE
      validate_descflex(user_apid       IN      NUMBER,
                        user_resp       IN      NUMBER,
                        userid          IN      NUMBER,
                        flex_app_sname  IN      VARCHAR2,
                        desc_flex_name  IN      VARCHAR2,
                        vdate           IN      VARCHAR2,
                        invoking_mode   IN      VARCHAR2,
                        allow_nulls     IN      VARCHAR2,
                        update_table    IN      VARCHAR2,
                        effective_activ IN      VARCHAR2,
                        concat_segs     IN      VARCHAR2,
                        vals_or_ids     IN      VARCHAR2,
                        c_rowid         IN      VARCHAR2,
                        alternate_table IN      VARCHAR2,
                        data_field      IN      VARCHAR2,
                        concat_vals_out OUT     nocopy VARCHAR2,
                        concat_ids_out  OUT     nocopy VARCHAR2,
                        concat_desc     OUT     nocopy VARCHAR2,
                        seg_delimiter   OUT     nocopy VARCHAR2,
                        vstatus         OUT     nocopy NUMBER,
                        segcodes        OUT     nocopy VARCHAR2,
                        error_seg       OUT     nocopy NUMBER,
                        message         OUT     nocopy VARCHAR2) IS

    v_date              DATE;
    rowid_in            ROWID;
    nvalidated          NUMBER;
    value_dvals         FND_FLEX_SERVER1.ValueArray;
    value_vals          FND_FLEX_SERVER1.ValueArray;
    value_ids           FND_FLEX_SERVER1.ValueIdArray;
    value_descs         FND_FLEX_SERVER1.ValueDescArray;
    value_desclens      FND_FLEX_SERVER1.NumberArray;
    cc_cols             FND_FLEX_SERVER1.TabColArray;
    cc_coltypes         FND_FLEX_SERVER1.CharArray;
    segtypes            FND_FLEX_SERVER1.SegFormats;
    disp_segs           FND_FLEX_SERVER1.DisplayedSegs;
    delim               VARCHAR2(1);
    omit_activation     BOOLEAN;
    dummy_coldef        FND_FLEX_SERVER1.ColumnDefinitions;

  BEGIN

-- Initialize globals.
-- If ok, then validate and return results.
-- Otherwise return error and message.
--
    if(FND_FLEX_SERVER1.init_globals) then

--  Client passes in julian date of 0 to mean null vdate
--
      if(vdate = '0') then
        v_date := NULL;
      else
        v_date := to_date(vdate, DATE_PASS_FORMAT);
      end if;

--  Client passes in rowid as a VC2.  Convert to a real ROWID
--
      rowid_in := CHARTOROWID(c_rowid);

--  Only check disabled and expired values if effective_activ = 'N' or 'n'
--
      omit_activation := FALSE;
      if((effective_activ is not null) and
         (effective_activ in ('n', 'N'))) then
        omit_activation := TRUE;
      end if;

--  Client passes in allow_nulls, update_table, and vals_or_ids as
--  chars.  Change them to boolean.

      FND_FLEX_SERVER4.descval_engine(user_apid, user_resp, userid,
                flex_app_sname, desc_flex_name, v_date, invoking_mode,
                (allow_nulls = 'Y'), (update_table = 'Y'),
                omit_activation, concat_segs, (vals_or_ids = 'V'),
                FALSE, dummy_coldef, rowid_in, alternate_table,
                data_field, NULL, NULL, NULL,
                nvalidated, value_dvals, value_vals,
                value_ids, value_descs, value_desclens, cc_cols,
                cc_coltypes, segtypes, disp_segs, delim, vstatus,
                segcodes, error_seg);

--  Return requested outputs as concatenated strings.
--
      concat_vals_out := concatenate_values(nvalidated, value_dvals,
                                            disp_segs, delim);
      concat_ids_out := concatenate_ids(nvalidated, value_ids, delim);
      concat_desc := concatenate_fulldescs(nvalidated, value_descs,
                                           disp_segs, delim);
      seg_delimiter := delim;
      message := FND_MESSAGE.get_encoded;
      return;
    end if;

    message := FND_MESSAGE.get_encoded;
    vstatus := FND_FLEX_SERVER1.VV_ERROR;
    return;

  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG','validate_descflex() exception: '||SQLERRM);
      message := FND_MESSAGE.get_encoded;
      vstatus := FND_FLEX_SERVER1.VV_ERROR;
      return;
  END validate_descflex;

/* ------------------------------------------------------------------------  */
/*      Call just prior to opening edit window in client popid().            */
/*                                                                           */
/*      Validates and gets segment descriptions for the concatenated         */
/*      segment values which were directly entered.  If concatenated         */
/*      segment values string is null, then defaults all displayed values.   */
/*      Ignores value errors, continuing to validate values to the end.      */
/*      Returns number of segments found and concatenated values, ids        */
/*      and descriptions, segment formats, and segment valid codes.          */
/*      Returns v_status = Value validation status which is the same as      */
/*      that returned by validate_combination.                               */
/*      Returns err_segnum = segment number of first value error or of       */
/*      first more serious error if any occurred.  Error message always      */
/*      applies to the segment specified by err_segnum. Put cursor there.    */
/* ------------------------------------------------------------------------  */

PROCEDURE
     pre_window(user_apid       IN      NUMBER,
                user_resp       IN      NUMBER,
                flex_app_sname  IN      VARCHAR2,
                flex_code       IN      VARCHAR2,
                flex_num        IN      NUMBER,
                vdate           IN      VARCHAR2,
                vrulestr        IN      VARCHAR2,
                display_segs    IN      VARCHAR2,
                concat_segs     IN      VARCHAR2,
                concat_vals_out OUT     nocopy VARCHAR2,
                concat_ids_out  OUT     nocopy VARCHAR2,
                concat_desc     OUT     nocopy VARCHAR2,
                seg_delimiter   OUT     nocopy VARCHAR2,
                seg_formats     OUT     nocopy VARCHAR2,
                seg_codes       OUT     nocopy VARCHAR2,
                n_segments      OUT     nocopy NUMBER,
                v_status        OUT     nocopy NUMBER,
                err_segnum      OUT     nocopy NUMBER,
                message         OUT     nocopy VARCHAR2) IS

    nsegs       NUMBER;
    nvals       NUMBER;
    segs        FND_FLEX_SERVER1.StringArray;
    disp_segs   FND_FLEX_SERVER1.DisplayedSegs;
    errsegnum   NUMBER;
    errcode     NUMBER;
    val_date    DATE;
    segtypes    FND_FLEX_SERVER1.SegFormats;
    segcodes    VARCHAR2(30);
    kff_cc      FND_FLEX_SERVER1.CombTblInfo;
    kff_id      FND_FLEX_SERVER1.FlexStructId;
    kff_info    FND_FLEX_SERVER1.FlexStructInfo;
    vv_flags    FND_FLEX_SERVER1.ValueValidationFlags;
    value_dvals FND_FLEX_SERVER1.ValueArray;
    value_vals  FND_FLEX_SERVER1.ValueArray;
    value_ids   FND_FLEX_SERVER1.ValueIdArray;
    value_descs FND_FLEX_SERVER1.ValueDescArray;
    desc_lens   FND_FLEX_SERVER1.NumberArray;
    cc_cols     FND_FLEX_SERVER1.TabColArray;
    cc_coltypes FND_FLEX_SERVER1.CharArray;
    derv        FND_FLEX_SERVER1.DerivedVals;
    drv_quals   FND_FLEX_SERVER1.Qualifiers;
    v_rules     FND_FLEX_SERVER1.Vrules;

  BEGIN

--  Initialize messages, debugging, and number of sql strings
--
    if(FND_FLEX_SERVER1.init_globals = FALSE) then
      goto return_error;
    end if;

-- Convert the validation date to date format.  Client may pass 0 to mean null.
--
    if(vdate = '0') then
      val_date := NULL;
    else
      val_date := to_date(vdate, DATE_PASS_FORMAT);
    end IF;

--  Get all required info about the desired flexfield structure.
--
    if(FND_FLEX_SERVER2.get_keystruct(flex_app_sname, flex_code,
                        NULL, flex_num,
                        kff_id, kff_info, kff_cc) = FALSE) then
      goto return_error;
    end if;

-- Set validation flags.
--
    vv_flags.values_not_ids := TRUE;
    vv_flags.default_all_displayed := (concat_segs is null);
    vv_flags.default_all_required := FALSE;
    vv_flags.default_non_displayed := TRUE;
    vv_flags.allow_nulls := FALSE;
    vv_flags.message_on_null := (concat_segs is not null);
    vv_flags.all_orphans_valid := FALSE;
    vv_flags.ignore_security := FALSE;
    vv_flags.ignore_expired := FALSE;
    vv_flags.ignore_disabled := FALSE;
    vv_flags.message_on_security := TRUE;
    vv_flags.stop_on_value_error := FALSE;
    vv_flags.exact_nsegs_required := FALSE;
    vv_flags.stop_on_security := FALSE;

    /* invoking_mode is added for bug872437. */

    vv_flags.invoking_mode := 'P';

-- Parse vrule string and displayed token string
--
    if((parse_vrules(vrulestr, v_rules) < 0) OR
       (parse_displayed(kff_id, display_segs, disp_segs) = FALSE)) then
      goto return_error;
    end if;

--  Set up some debug information to return
--
    IF (fnd_flex_server1.g_debug_level > 0) THEN
       FND_FLEX_SERVER1.add_debug('Entering pre_window(). ');
       FND_FLEX_SERVER1.add_debug('Flex Appl Id = ');
       FND_FLEX_SERVER1.add_debug(to_char(kff_id.application_id));
       FND_FLEX_SERVER1.add_debug(', Flex Code = ' || flex_code);
       FND_FLEX_SERVER1.add_debug(', Structure Number = '||to_char(flex_num));
       FND_FLEX_SERVER1.add_debug(', display_segs = ' || display_segs);
    END IF;

--  Convert concatenated segments to array and check there are not too many
--
    if(FND_FLEX_SERVER2.breakup_catsegs(concat_segs,
        kff_info.concatenated_segment_delimiter,
        vv_flags.values_not_ids, disp_segs, nsegs, segs) = FALSE) then
      goto return_error;
    end if;

--  Look up the descriptions and ids.
--
    errcode := FND_FLEX_SERVER1.validate_struct(kff_id,
             kff_cc.table_application_id, kff_cc.combination_table_id,
             nsegs, segs, disp_segs, vv_flags, val_date, v_rules, user_apid,
             user_resp, nvals, segtypes, segcodes, cc_cols, cc_coltypes,
             value_dvals, value_vals, value_ids, value_descs, desc_lens,
             derv, drv_quals, errsegnum);

    IF (fnd_flex_server1.g_debug_level > 0) THEN
       FND_FLEX_SERVER1.add_debug('SV1.validate_struct() returns errcode ');
       FND_FLEX_SERVER1.add_debug(to_char(errcode) ||' and '|| to_char(nvals));
       FND_FLEX_SERVER1.add_debug(' values.  SegCodes: ' || segcodes);
       FND_FLEX_SERVER1.add_debug(' ErrSeg: ' || to_char(errsegnum));
       FND_FLEX_SERVER1.add_debug(' Returned arrays:');
       for i in 1..nvals loop
          FND_FLEX_SERVER1.add_debug('"' || segtypes.vs_format(i));
          FND_FLEX_SERVER1.add_debug(to_char(segtypes.vs_maxsize(i), 'S099'));
          FND_FLEX_SERVER1.add_debug('*' || value_dvals(i) || '*');
          FND_FLEX_SERVER1.add_debug(cc_cols(i) || '" ');
          --FND_FLEX_SERVER1.add_debug(cc_cols(i)||':'||cc_coltypes(i)||'" ');
       end loop;
    END IF;

    concat_vals_out := concatenate_values(nvals, value_dvals, disp_segs,
                                  kff_info.concatenated_segment_delimiter);
    concat_ids_out := concatenate_ids(nvals, value_ids,
                                  kff_info.concatenated_segment_delimiter);
    concat_desc := concatenate_fulldescs(nvals, value_descs, disp_segs,
                                kff_info.concatenated_segment_delimiter);
    seg_delimiter := kff_info.concatenated_segment_delimiter;
    seg_formats := concatenate_segment_formats(segtypes);
    seg_codes := segcodes;
    n_segments := nvals;
    err_segnum := errsegnum;
    v_status := errcode;
    message := FND_MESSAGE.get_encoded;
    return;

    <<return_error>>
    message := FND_MESSAGE.get_encoded;
    v_status := FND_FLEX_SERVER1.VV_ERROR;
    return;

  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG','pre_window() exception: '||SQLERRM);
      message := FND_MESSAGE.get_encoded;
      n_segments := 0;
      return;
  END pre_window;

/* ------------------------------------------------------------------------ */
/*      Interprets INSERTABLE, UPDATABLE and DISPLAYED tokens returning     */
/*      character strings consisting of Y's and N's which are segment by    */
/*      segment maps indicating which segments are insertable, updatable    */
/*      required and displayed.                                             */
/*      Returns n_segments > 0 on success or = 0 and message if failure.    */
/* ------------------------------------------------------------------------ */

 PROCEDURE segment_maps(flex_app_sname  IN  VARCHAR2,
                        flex_code       IN  VARCHAR2,
                        flex_num        IN  NUMBER,
                        insert_token    IN  VARCHAR2,
                        update_token    IN  VARCHAR2,
                        display_token   IN  VARCHAR2,
                        insert_map      OUT nocopy VARCHAR2,
                        update_map      OUT nocopy VARCHAR2,
                        display_map     OUT nocopy VARCHAR2,
                        required_map    OUT nocopy VARCHAR2,
                        n_segments      OUT nocopy NUMBER,
                        message         OUT nocopy VARCHAR2) IS

    n_segs              NUMBER;
    kff_cc              FND_FLEX_SERVER1.CombTblInfo;
    kff_id              FND_FLEX_SERVER1.FlexStructId;
    kff_info            FND_FLEX_SERVER1.FlexStructInfo;
    fq_table            FND_FLEX_SERVER1.FlexQualTable;
    seg_disp            FND_FLEX_SERVER1.CharArray;
    seg_rqd             FND_FLEX_SERVER1.CharArray;
    s_required          FND_FLEX_SERVER1.BooleanArray;
    s_insertable        FND_FLEX_SERVER1.BooleanArray;
    s_updatable         FND_FLEX_SERVER1.BooleanArray;
    s_displayed         FND_FLEX_SERVER1.BooleanArray;
    ins_map             VARCHAR2(30);
    upd_map             VARCHAR2(30);
    disp_map            VARCHAR2(30);
    rqd_map             VARCHAR2(30);

  BEGIN

--  Initialize messages, debugging, and number of sql strings
--
    if(FND_FLEX_SERVER1.init_globals = FALSE) then
      goto return_error;
    end if;

--  Get all required info about the desired flexfield structure.
--
    if(FND_FLEX_SERVER2.get_keystruct(flex_app_sname, flex_code,
                        NULL, flex_num,
                        kff_id, kff_info, kff_cc) = FALSE) then
      goto return_error;
    end if;

--  Set up some debug information to return
--
    IF (fnd_flex_server1.g_debug_level > 0) THEN
       FND_FLEX_SERVER1.add_debug('Starting segment_maps() ');
       FND_FLEX_SERVER1.add_debug('Flex Appl Id = ');
       FND_FLEX_SERVER1.add_debug(to_char(kff_id.application_id));
       FND_FLEX_SERVER1.add_debug(', Flex Code = ' || flex_code);
       FND_FLEX_SERVER1.add_debug(', Structure Number = '||to_char(flex_num));
    END IF;
    if(FND_FLEX_SERVER2.get_qualsegs(kff_id, n_segs, seg_disp,
                                    seg_rqd, fq_table) = FALSE) then
      goto return_error;
    end if;

    if((NOT evaluate_token(display_token, n_segs, fq_table, s_displayed)) OR
       (NOT evaluate_token(update_token, n_segs, fq_table, s_updatable)) OR
       (NOT evaluate_token(insert_token, n_segs, fq_table, s_insertable))) then
      goto return_error;
    end if;

--  Need to merge the displayed map obtained from the DISPLAYED token
--  alone with the display map from the flex structure.
--  Also need to turn required into boolean.
--
    for i in 1..n_segs loop
      s_required(i) := (seg_rqd(i) = 'Y');
      s_displayed(i) := ((seg_disp(i) = 'Y') AND s_displayed(i));
    end loop;

--  Return the completed maps
--
    for i in 1..n_segs loop
      if(s_insertable(i)) then
        ins_map := ins_map || 'Y';
      else
        ins_map := ins_map || 'N';
      end if;
      if(s_updatable(i)) then
        upd_map := upd_map || 'Y';
      else
        upd_map := upd_map || 'N';
      end if;
      if(s_required(i)) then
        rqd_map := rqd_map || 'Y';
      else
        rqd_map := rqd_map || 'N';
      end if;
      if(s_displayed(i)) then
        disp_map := disp_map || 'Y';
      else
        disp_map := disp_map || 'N';
      end if;
    end loop;

    display_map := disp_map;
    insert_map := ins_map;
    update_map := upd_map;
    required_map := rqd_map;
    n_segments := n_segs;
    FND_MESSAGE.clear;
    return;

    <<return_error>>
    message := FND_MESSAGE.get_encoded;
    n_segments := 0;
    return;

  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG', 'segment_maps() exception: ' || SQLERRM);
      message := FND_MESSAGE.get_encoded;
      n_segments := 0;
      return;
  END segment_maps;

/* ------------------------------------------------------------------------  */
/*      Determines if any segments in the combination passed in are secured. */
/*      Returns SEGNUM = the number of the first segment which violates      */
/*      security, 0 if no segment values are secured, or < 0 on error.       */
/*      MESSAGE is the security violation message of the first secured       */
/*      segment or the error message if an error occurred, or NULL if        */
/*      no segments are secured.                                             */
/* ------------------------------------------------------------------------  */

 PROCEDURE segs_secured(resp_apid       IN      NUMBER,
                        resp_id         IN      NUMBER,
                        flex_app_sname  IN      VARCHAR2,
                        flex_code       IN      VARCHAR2,
                        flex_num        IN      NUMBER,
                        display_segs    IN      VARCHAR2,
                        concat_segs     IN      VARCHAR2,
                        segnum          OUT     nocopy NUMBER,
                        message         OUT     nocopy VARCHAR2) IS

    secseg      NUMBER;
    nsegs       NUMBER;
    segs        FND_FLEX_SERVER1.StringArray;
    disp_segs   FND_FLEX_SERVER1.DisplayedSegs;
    kff_cc      FND_FLEX_SERVER1.CombTblInfo;
    kff_id      FND_FLEX_SERVER1.FlexStructId;
    kff_info    FND_FLEX_SERVER1.FlexStructInfo;

  BEGIN

--  Check for null segments
--
    if(concat_segs is null) then
      segnum := 0;
      return;
    end if;

--  Initialize messages, debugging, and number of sql strings
--
    if(FND_FLEX_SERVER1.init_globals = FALSE) then
      goto return_error;
    end if;

--  Get all required info about the desired flexfield structure.
--
    if(FND_FLEX_SERVER2.get_keystruct(flex_app_sname, flex_code,
                        NULL, flex_num,
                        kff_id, kff_info, kff_cc) = FALSE) then
      goto return_error;
    end if;

--  Set up some debug information to return
--
    IF (fnd_flex_server1.g_debug_level > 0) THEN
       FND_FLEX_SERVER1.add_debug('Flex Appl Id = ');
       FND_FLEX_SERVER1.add_debug(to_char(kff_id.application_id));
       FND_FLEX_SERVER1.add_debug(', Flex Code = ' || flex_code);
       FND_FLEX_SERVER1.add_debug(', Structure Number = '|| to_char(flex_num));
    END IF;
    if(parse_displayed(kff_id, display_segs, disp_segs) = FALSE) then
      goto return_error;
    end if;

--  Convert concatenated segments to array and check there are not too many
--
    if(FND_FLEX_SERVER2.breakup_catsegs(concat_segs,
                kff_info.concatenated_segment_delimiter,
                TRUE, disp_segs, nsegs, segs) = FALSE) then
      goto return_error;
    end if;

--  See if any segment values are secured.
--
    secseg := FND_FLEX_SERVER1.vals_secured(kff_id, nsegs, segs, disp_segs,
                                            resp_apid, resp_id);
    segnum := secseg;
    if(secseg = 0) then
      FND_MESSAGE.clear;
    else
      message := FND_MESSAGE.get_encoded;
    end if;
    return;

    <<return_error>>
    message := FND_MESSAGE.get_encoded;
    segnum := -5;
    return;

  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG','segs_secured() exception: '||SQLERRM);
      message := FND_MESSAGE.get_encoded;
      segnum := -4;
      return;
  END segs_secured;

  --
  -- Autonomous Transaction Version of Insert Combination.
  -- copied from insert_combination().
  --
  FUNCTION insert_combination_at
    (fstruct    IN  FND_FLEX_SERVER1.FlexStructId,
     structnum IN  NUMBER,
     maintmode IN  BOOLEAN,
     v_date     IN  DATE,
     seg_delim IN  VARCHAR2,
     ccid_inp  IN  NUMBER,
     combtbl    IN  FND_FLEX_SERVER1.CombTblInfo,
     combcols   IN  FND_FLEX_SERVER1.TabColArray,
     combtypes IN  FND_FLEX_SERVER1.CharArray,
     user_id    IN  NUMBER,
     nsegs      IN  NUMBER,
     segids_in  IN  FND_FLEX_SERVER1.ValueIdArray,
     segvals_in IN  FND_FLEX_SERVER1.valuearray,
     segfmts   IN   FND_FLEX_SERVER1.SegFormats,
     dvalues    IN  FND_FLEX_SERVER1.DerivedVals,
     dquals     IN  FND_FLEX_SERVER1.Qualifiers,
     nxcols     IN  NUMBER,
     xcolnames IN  FND_FLEX_SERVER1.StringArray,
     xcolvals  OUT nocopy FND_FLEX_SERVER1.StringArray,
     qualvals  OUT nocopy FND_FLEX_SERVER1.ValAttribArray,
     tblderv   OUT nocopy FND_FLEX_SERVER1.DerivedVals,
     newcomb    OUT nocopy BOOLEAN,
     ccid_out  OUT nocopy NUMBER) RETURN BOOLEAN
    IS
       PRAGMA AUTONOMOUS_TRANSACTION;
       deadlock         EXCEPTION;
       ccid             NUMBER;
       nfound           NUMBER;
       hash_num         NUMBER;
       hash_number              NUMBER;
       ccid_string              VARCHAR2(50);
       segids           FND_FLEX_SERVER1.ValueIdArray;

       PRAGMA EXCEPTION_INIT(deadlock, -60);

  BEGIN
     SAVEPOINT pre_insert_comb_at;

     -- For debugging...
     --
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        FND_FLEX_SERVER1.add_debug(to_char(nsegs) ||
                                   ' segs passed to insert_combination().');
     END IF;

     --  First lock this combination and prevent other users from inserting.
     --  Generate an almost unique hash number from the segments ids.
     --  and lock that row in the hash table to prevent other users from
     --  inserting the same combination.  The commit will drop the locks.-
     --  GL requires row share lock on combinations table to prevent them from
     --  getting an exclusive lock for their processing.

     segids := segids_in;

     sqls := 'lock table ' || combtbl.application_table_name;
     sqls := sqls || ' in row share mode';

     fnd_dsql.init;
     fnd_dsql.add_text(sqls);
     if(FND_FLEX_SERVER1.x_dsql_execute < 0) THEN
        GOTO return_false;
     end if;

     --  Next compute the hash number that is to be locked.
     --
     hash_number := hash_segs(nsegs, segids);
     if(hash_number < 0) THEN
        GOTO return_false;
     end if;

     IF (fnd_flex_server1.g_debug_level > 0) THEN
        FND_FLEX_SERVER1.add_debug('Hash value = '||to_char(hash_number)||'.');
     END IF;
     SELECT hash_value INTO hash_num FROM fnd_flex_hash
       WHERE hash_value = hash_number FOR UPDATE;

     -- Double-check to see if it has been created.
     -- No where clause this time.
     --
     nfound := find_combination(structnum, combtbl, nsegs, combcols,
                                combtypes, segfmts, dquals.nquals,
                                dquals.derived_cols, nxcols, xcolnames, NULL,
                                ccid, segids, tblderv, qualvals, xcolvals);
     if(nfound <> 0) then
        if(nfound >= 1) then
           newcomb := FALSE;
           ccid_out := ccid;
           GOTO return_true;
        end if;
        GOTO return_false;
     end if;

     -- Get unique code combination ID from a sequence if we dont
     -- already have it.
     -- If ccid_inp is 0 or null or -1 we need to generate a new ccid.
     -- Must use dynamic SQL here since ccid comes from the application table
     -- with a '_S' suffix.  Could do without dynamic sql if we had a fixed
     -- sequence name.
     --
     if(maintmode and (ccid_inp is not null) and (ccid_inp <> 0) and
        (ccid_inp <> -1)) then
        ccid := ccid_inp;
      else
        sqls := 'select to_char(' || combtbl.application_table_name;
        sqls := sqls || '_S.NEXTVAL) from dual';
        fnd_dsql.init;
        fnd_dsql.add_text(sqls);
        if(FND_FLEX_SERVER1.x_dsql_select_one(ccid_string) <> 1) THEN
           GOTO return_false;
        end if;
        ccid := to_number(ccid_string);
        if(ccid > MAX_CCID) then
           FND_MESSAGE.set_name('FND', 'FLEX-CCID TOO BIG');
           FND_MESSAGE.set_token('CCIDLIMIT', to_char(MAX_CCID));
           FND_MESSAGE.set_token('SEQNAME', combtbl.application_table_name||'_S');
           GOTO return_false;
        end if;
     end if;

     --  Call user validation function now if desired.  Bail if error.
     --
     if(userval_on) then
        if(NOT call_userval(fstruct, v_date, nsegs, seg_delim, segids_in)) then
           GOTO return_false;
        end if;
     end if;

     --  If not in maintainence mode do the insert, otherwise skip to the end.
     --
     if(NOT maintmode) then

        --  Build a SQL statement to do the insert.
        --
       fnd_dsql.init;
       sqls := 'insert into ' || combtbl.application_table_name || ' (';
       sqls := sqls || combtbl.unique_id_column_name;
       if(combtbl.set_defining_column_name is not null) then
          sqls := sqls || ', ' || combtbl.set_defining_column_name;
       end if;
       sqls := sqls || ', ENABLED_FLAG, SUMMARY_FLAG, ';
       sqls := sqls || 'START_DATE_ACTIVE, END_DATE_ACTIVE, ';
       sqls := sqls || 'LAST_UPDATE_DATE, LAST_UPDATED_BY';
       for i in 1..dquals.nquals loop
          sqls := sqls || ', ' || dquals.derived_cols(i);
       end loop;
       for i in 1..nsegs loop
          if(segids(i) is not null) then
             sqls := sqls || ', ' || combcols(i);
          end if;
       end loop;
       sqls := sqls || ') values (';

       -- So far the table name and the column names.
       fnd_dsql.add_text(sqls);

       fnd_dsql.add_bind(ccid);

       if(combtbl.set_defining_column_name is not null) THEN
          fnd_dsql.add_text(',');
          fnd_dsql.add_bind(structnum);
       end if;

       fnd_dsql.add_text(',');
       fnd_dsql.add_bind(dvalues.enabled_flag);

       fnd_dsql.add_text(',');
       fnd_dsql.add_bind(dvalues.summary_flag);

       fnd_dsql.add_text(',');
       fnd_dsql.add_bind(dvalues.start_valid);

       fnd_dsql.add_text(',');
       fnd_dsql.add_bind(dvalues.end_valid);

       fnd_dsql.add_text(',sysdate,');
       fnd_dsql.add_bind(user_id);

       for i in 1..dquals.nquals LOOP
          fnd_dsql.add_text(',');
          fnd_dsql.add_bind(dquals.sq_values(i));
       end loop;

       for i in 1..nsegs loop
          if(segids(i) is not null) THEN
             fnd_dsql.add_text(',');
             --
             -- This will call fnd_dsql.add_bind
             --
             fnd_flex_server1.x_compare_clause
               (combtypes(i),
                combcols(i), segids(i), FND_FLEX_SERVER1.VC_ID,
                segfmts.vs_format(i), segfmts.vs_maxsize(i));
          end if;
       end loop;
       fnd_dsql.add_text(')');

       --
       --  Finally do the insert
       --
       if(FND_FLEX_SERVER1.x_dsql_execute < 0) then
          GOTO return_false;
       end if;
       if((fstruct.application_id = 101) and (fstruct.id_flex_code ='GL#')) then
          if(call_fdfgli(ccid) = FALSE) THEN
             GOTO return_false;
          end if;
       end if;
     end if;

     --  Return all out variables.  If comb was found in table these were set
     --  above.
     --
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        FND_FLEX_SERVER1.add_debug(' Returning ccid = '||to_char(ccid)|| '. ');
     END IF;
     ccid_out := ccid;
     newcomb := TRUE;
     tblderv := dvalues;
     for i in 1..nxcols loop
        xcolvals(i) := NULL;
     end loop;
     for i in 1..dquals.nquals loop
        qualvals(i) := dquals.sq_values(i);
     end loop;

     --
     -- return(TRUE);
     --
     -- This point was the end of regular insert_combination.
     --
     -- However following stuff should be done in AT.
     -- copied from validation_engine() function.
     --
     if(FND_FLEX_SERVER2.x_drop_cached_cv_result(fstruct, nsegs, segvals_in)
        = FALSE) then
        GOTO return_false;
     end if;

     GOTO return_true;

     <<return_true>>
       COMMIT;
     RETURN(TRUE);

     <<return_false>>
       ROLLBACK TO SAVEPOINT pre_insert_comb_at;
       ROLLBACK; -- required by AT.
     RETURN(FALSE);

  EXCEPTION
    WHEN NO_DATA_FOUND then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG', 'Hash value ' ||
                            to_char(hash_number) || ' not found.');
      ROLLBACK TO SAVEPOINT pre_insert_comb_at;
      ROLLBACK; -- required by AT.
      return(FALSE);
    WHEN TOO_MANY_ROWS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG', 'Hash value ' ||
                            to_char(hash_number) || ' not unique.');
      ROLLBACK TO SAVEPOINT pre_insert_comb_at;
      ROLLBACK; -- required by AT.
      return(FALSE);
    WHEN TIMEOUT_ON_RESOURCE then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG', 'Timeout waiting for lock on hash table.');
      ROLLBACK TO SAVEPOINT pre_insert_comb_at;
      ROLLBACK; -- required by AT.
      return(FALSE);
    WHEN deadlock then
      FND_MESSAGE.set_name('FND', 'FLEX-HASH DEADLOCK');
      ROLLBACK TO SAVEPOINT pre_insert_comb_at;
      ROLLBACK; -- required by AT.
      return(FALSE);
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG','insert_combination() exception: '||SQLERRM);
      ROLLBACK TO SAVEPOINT pre_insert_comb_at;
      ROLLBACK; -- required by AT.
      return(FALSE);
  END insert_combination_AT;



/* ------------------------------------------------------------------------- */
/*      The general purpose engine for popid(), loadid() and valid()         */
/*                                                                           */
/*      Takes either concatenated segments or segment array as input.        */
/*      assume segment array input unless nsegs = 0.                         */
/*                                                                           */
/*      This function returns output arrays that may or may not be           */
/*      populated depending on the point at which the validation stopped.    */
/*      The number of output array elements populated is specified by        */
/*      an array count for each type of data.  For disp_segs, drv_quals,     */
/*      and tbl_quals the array count is specified within the returned       */
/*      data structure.  The number of extra columns output is specified     */
/*      by n_xcols.  For all other output arrays (including the segcodes     */
/*      string) the number of output values is specified by nvalidated.      */
/*      Nvalidated is the number of enabled segments that were validated     */
/*      before validation stopped.                                           */
/*      Many error conditions return no array information at all.  This      */
/*      condition is indicated by setting the array counts to 0 for all      */
/*      empty arrays.                                                        */
/*                                                                           */
/*      NOTE:  Make sure to call FND_FLEX_SERVER1.init_globals before        */
/*      calling this function, to initialize debugging and messages.         */
/* ------------------------------------------------------------------------  */

PROCEDURE
      validation_engine(user_apid       IN      NUMBER,
                        user_resp       IN      NUMBER,
                        userid          IN      NUMBER,
                        flex_app_sname  IN      VARCHAR2,
                        flex_code       IN      VARCHAR2,
                        select_comb_from_view IN VARCHAR2,
                        flex_num        IN      NUMBER,
                        val_date        IN      DATE,
                        vrulestr        IN      VARCHAR2,
                        data_set        IN      NUMBER,
                        invoking_mode   IN      VARCHAR2,
                        validate_mode   IN      VARCHAR2,
                        dinsert         IN      VARCHAR2,
                        qsecurity       IN      VARCHAR2,
                        required        IN      VARCHAR2,
                        allow_nulls     IN      VARCHAR2,
                        display_segstr  IN      VARCHAR2,
                        concat_segs     IN      VARCHAR2,
                        vals_or_ids     IN      VARCHAR2,
                        where_clause    IN      VARCHAR2,
                        no_combmsg      IN      VARCHAR2,
                        where_clause_msg IN     VARCHAR2,
                        get_extra_cols  IN      VARCHAR2,
                        ccid_in         IN      NUMBER,
                        nvalidated      OUT     nocopy NUMBER,
                        displayed_vals  OUT     nocopy FND_FLEX_SERVER1.ValueArray,
                        stored_vals     OUT     nocopy FND_FLEX_SERVER1.ValueArray,
                        segment_ids     OUT     nocopy FND_FLEX_SERVER1.ValueIdArray,
                        descriptions    OUT     nocopy FND_FLEX_SERVER1.ValueDescArray,
                        desc_lengths    OUT     nocopy FND_FLEX_SERVER1.NumberArray,
                        seg_colnames    OUT     nocopy FND_FLEX_SERVER1.TabColArray,
                        seg_coltypes    OUT     nocopy FND_FLEX_SERVER1.CharArray,
                        segment_types   OUT     nocopy FND_FLEX_SERVER1.SegFormats,
                        displayed_segs  OUT     nocopy FND_FLEX_SERVER1.DisplayedSegs,
                        derived_eff     OUT     nocopy FND_FLEX_SERVER1.DerivedVals,
                        table_eff       OUT     nocopy FND_FLEX_SERVER1.DerivedVals,
                        derived_quals   OUT     nocopy FND_FLEX_SERVER1.Qualifiers,
                        table_quals     OUT     nocopy FND_FLEX_SERVER1.Qualifiers,
                        n_column_vals   OUT     nocopy NUMBER,
                        column_vals     OUT     nocopy FND_FLEX_SERVER1.StringArray,
                        seg_delimiter   OUT     nocopy VARCHAR2,
                        ccid_out        OUT     nocopy NUMBER,
                        new_combination OUT     nocopy BOOLEAN,
                        v_status        OUT     nocopy NUMBER,
                        seg_codes       OUT     nocopy VARCHAR2,
                        err_segnum      OUT     nocopy NUMBER) IS

    big_arg     VARCHAR2(40);
    catsegs     VARCHAR2(2000);
    segtypes    FND_FLEX_SERVER1.SegFormats;
    segcodes    VARCHAR2(30);
    error_col   VARCHAR2(30);
    nfound      NUMBER;
    comb_id     NUMBER;
    errcode     NUMBER;
    errsegnum   NUMBER;
    cc_struct   NUMBER;
    for_insert  BOOLEAN;
    dynam_insrt BOOLEAN;
    defer_insrt BOOLEAN;
    new_comb    BOOLEAN;
    kff_cc      FND_FLEX_SERVER1.CombTblInfo;
    kff_id      FND_FLEX_SERVER1.FlexStructId;
    kff_info    FND_FLEX_SERVER1.FlexStructInfo;
    nvals       NUMBER;
    nsegs       NUMBER;
    segs        FND_FLEX_SERVER1.StringArray;
    value_dvals FND_FLEX_SERVER1.ValueArray;
    value_vals  FND_FLEX_SERVER1.ValueArray;
    value_ids   FND_FLEX_SERVER1.ValueIdArray;
    value_descs FND_FLEX_SERVER1.ValueDescArray;
    cc_cols     FND_FLEX_SERVER1.TabColArray;
    cc_coltypes FND_FLEX_SERVER1.CharArray;
    desc_lens   FND_FLEX_SERVER1.NumberArray;
    derv        FND_FLEX_SERVER1.DerivedVals;
    tbl_derv    FND_FLEX_SERVER1.DerivedVals;
    drv_quals   FND_FLEX_SERVER1.Qualifiers;
    tbl_quals   FND_FLEX_SERVER1.Qualifiers;
    v_rules     FND_FLEX_SERVER1.Vrules;
    n_xcols     NUMBER;
    rq_xcols    FND_FLEX_SERVER1.StringArray;
    xcol_vals   FND_FLEX_SERVER1.StringArray;
    disp_segs   FND_FLEX_SERVER1.DisplayedSegs;
    vv_flags    FND_FLEX_SERVER1.ValueValidationFlags;
    entered     VARCHAR2(1);
    nice_where_cl       VARCHAR2(2000);
    l_dinsert   VARCHAR2(10);
    no_at       BOOLEAN := FALSE;
    validate_off  BOOLEAN := FALSE;
    invoking_mode_l VARCHAR2(1);
    userid_l    NUMBER;
    acct_gen_profile VARCHAR2(1);
  BEGIN


     l_dinsert := Nvl(dinsert, 'N');
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        fnd_flex_server1.add_debug('BEGIN SSV.validation_engine()');
     END IF;

    -- get profile value for "Account Generator: Run in Debug Mode"
    -- This will turn on debug for Work Flow Account Generator
    FND_PROFILE.get('ACCOUNT_GENERATOR:DEBUG_MODE', acct_gen_profile);
    if(acct_gen_profile='Y') then
       fnd_flex_server1.set_debugging('ALL');
       fnd_flex_server1.add_debug('BEGIN SSV.validation_engine() for WF');
       fnd_flex_server1.add_debug('Input Parameters:');
       FND_FLEX_SERVER1.add_debug('user_apid = ' || to_char(user_apid));
       FND_FLEX_SERVER1.add_debug('user_resp = ' || to_char(user_resp));
       FND_FLEX_SERVER1.add_debug('userid = ' || to_char(userid));
       FND_FLEX_SERVER1.add_debug('flex_app_sname = ' || flex_app_sname);
       FND_FLEX_SERVER1.add_debug('flex_code = ' || flex_code);
       FND_FLEX_SERVER1.add_debug('flex_num = ' || to_char(flex_num));
       FND_FLEX_SERVER1.add_debug('vdate = ' || val_date);
       FND_FLEX_SERVER1.add_debug('vrulestr = ' || vrulestr);
       FND_FLEX_SERVER1.add_debug('data_set = ' || to_char(data_set));
       FND_FLEX_SERVER1.add_debug('invoking_mode = ' || invoking_mode);
       FND_FLEX_SERVER1.add_debug('validate_mode = ' || validate_mode);
       FND_FLEX_SERVER1.add_debug('dinsert = ' || dinsert);
       FND_FLEX_SERVER1.add_debug('qsecurity = ' || qsecurity);
       FND_FLEX_SERVER1.add_debug('required = ' || required);
       FND_FLEX_SERVER1.add_debug('allow_nulls = ' || allow_nulls);
       FND_FLEX_SERVER1.add_debug('display_segs = ' || display_segstr);
       FND_FLEX_SERVER1.add_debug('concat_segs = ' || concat_segs);
       FND_FLEX_SERVER1.add_debug('vals_or_ids = ' || vals_or_ids);
       FND_FLEX_SERVER1.add_debug('where_clause = ' || where_clause);
       FND_FLEX_SERVER1.add_debug('get_extra_cols = ' || get_extra_cols);
       FND_FLEX_SERVER1.add_debug('ccid_in = ' || to_char(ccid_in));
       FND_FLEX_SERVER1.add_debug('select_comb_from_view = ' || select_comb_from_view);
       FND_FLEX_SERVER1.add_debug('no_combmsg = ' || no_combmsg);
       FND_FLEX_SERVER1.add_debug('where_clause_msg = ' || where_clause_msg);
    end if;

--  Initialize all output variables so that returning from any point
--  results in a valid state.
--
    nvalidated := 0;
    segment_types.nsegs := 0;
    displayed_segs.n_segflags := 0;
    derived_quals.nquals := 0;
    table_quals.nquals := 0;
    n_column_vals := 0;
    new_combination := FALSE;
    v_status := FND_FLEX_SERVER1.VV_ERROR;

--  Initialize everything which affects returned information.  This way we
--  can process all returned information before returning when exiting from
--  any point in this code even if there is an error.
--  Dont worry about initializing strings to null.

    nvals := 0;
    nsegs := 0;
    segtypes.nsegs := 0;
    disp_segs.n_segflags := 0;
    drv_quals.nquals := 0;
    tbl_quals.nquals := 0;
    n_xcols := 0;
    new_comb := FALSE;
    errcode := FND_FLEX_SERVER1.VV_ERROR;
    userid_l := userid;

    if((concat_segs is null) and (ccid_in is null)) then
      entered := 'N';
    else
      entered := 'Y';
    end if;

--  Set cc_struct to the structure number to be used when interacting
--  with the combinations table
--
    if((data_set is null) or (data_set = -1)) then
      cc_struct := flex_num;
    else
      cc_struct := data_set;
    end if;

--  Get all required info about the desired flexfield structure.
--
    if(FND_FLEX_SERVER2.get_keystruct(flex_app_sname, flex_code,
                        select_comb_from_view, flex_num,
                        kff_id, kff_info, kff_cc) = FALSE) then
      goto return_error;
    end if;

    --
    -- If key flex is multi lingual then no dinsert.
    --
    IF (Upper(kff_cc.application_table_name) <>
        Upper(kff_cc.select_comb_from)) THEN
       l_dinsert := 'N';
    END IF;

--  Check maximum lengths of input strings
--
    if(LENGTHB(display_segstr) > MAX_ARG_LEN) then
      big_arg := 'DISPLAYABLE';
    elsif(LENGTHB(where_clause) > MAX_ARG_LEN) then
      big_arg := 'WHERE_CLAUSE';
    elsif(LENGTHB(vrulestr) > MAX_ARG_LEN) then
      big_arg := 'VRULE';
    elsif(LENGTHB(get_extra_cols) > MAX_ARG_LEN) then
      big_arg := 'COLUMN';
    else
      big_arg := NULL;
    end if;

    if(big_arg is not null) then
      FND_MESSAGE.set_name('FND', 'FLEX-ARGUMENT TOO LONG');
      FND_MESSAGE.set_token('ARG', big_arg);
      FND_MESSAGE.set_token('MAXLEN', to_char(MAX_ARG_LEN));
      goto return_error;
    end if;

--  Limit concatenated segment length for compatibility with client
--
--    if(LENGTHB(concat_segs) > MAX_CATSEG_LEN) then
--      FND_MESSAGE.set_name('FND', 'FLEX-CONCAT LEN > IAPFLEN');
--      FND_MESSAGE.set_token('MAXFLDLEN', to_char(MAX_CATSEG_LEN));
--      goto return_error;
--    end if;

--  First check that operation makes sense
--
    invoking_mode_l := invoking_mode;
    if (invoking_mode_l = 'Z') then
      validate_off := TRUE;
      invoking_mode_l := 'V';
    end if;

    if((invoking_mode_l is null) or
       (invoking_mode_l NOT IN ('V', 'P', 'L', 'G'))) then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV BAD INVOKE');
      goto return_error;
    end if;

    if((validate_mode is null) or
       (validate_mode not in
        ('FULL', 'PARTIAL', 'PARTIAL_IF_POSSIBLE', 'FOR_INSERT'))) then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV BAD VALMODE');
      goto return_error;
    end if;

    if((invoking_mode_l in ('V', 'P', 'G')) and
       ((vals_or_ids is null) or
        (vals_or_ids not in ('V', 'I')))) then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV BAD FLAG');
      goto return_error;
    end if;

-- Set validation flags.
--
    vv_flags.default_all_displayed := TRUE;
    vv_flags.values_not_ids := (vals_or_ids = 'V') AND (invoking_mode_l <> 'L');
    vv_flags.default_all_required := ((invoking_mode_l = 'V') and
                (required = 'Y') and (entered = 'N'));
    vv_flags.default_non_displayed := (invoking_mode_l in ('P', 'G', 'V'));
    vv_flags.allow_nulls := ((allow_nulls = 'Y') and
                  (validate_mode in ('PARTIAL', 'PARTIAL_IF_POSSIBLE')));
    vv_flags.message_on_null := TRUE;
    vv_flags.all_orphans_valid := (validate_mode = 'PARTIAL_IF_POSSIBLE');

/*************************** Bug 18554782 ************************************
 New records call popid to validate. If server validate, fdfksr()
 is called with invoking mode = P from popid(). Existing Records call Valid to
 validate. If server validate, fdfksr() is called with invoking mode = V from valid().
 In Client validation, valid() ignores security errors
 If server validation is on, then valid calls fdfksr() with invoking_mode=V.
 Invoking mode is used in AFFFSSVB.pls validation_engine() to set the flag
 vv_flags.ignore_security. This vv_flags.ignore_security flag is used in AFFFSV1B.pls
 validate_seg()
 -- Check security rules
 if(NOT vflags.ignore_security) then ....
   ...
   ...
    check_security()

 So vv_flags.ignore_security is set to ignore security during a Query.
 invoking_mode=L means Load which means Query. So sec errors are not given
 during query. We must change to code to also ignore security when validating
 existing records. For existing records the invoking mode is V.
***********************************************************************************/
    vv_flags.ignore_security := ((invoking_mode_l = 'L' OR invoking_mode_l = 'V') AND (qsecurity = 'N'));

    vv_flags.ignore_expired := (invoking_mode_l in ('L', 'G'));
    vv_flags.ignore_disabled := (invoking_mode_l in ('L', 'G'));
    if(validate_off) then
       vv_flags.ignore_security := TRUE;
       vv_flags.ignore_expired := TRUE;
       vv_flags.ignore_disabled := TRUE;
    end if;
    vv_flags.message_on_security := ((invoking_mode_l <> 'L') OR
                        ((invoking_mode_l = 'L') AND (qsecurity = 'Y')));
    vv_flags.stop_on_value_error := ((invoking_mode_l <> 'P') AND
                                     (invoking_mode_l <> 'G'));
    vv_flags.exact_nsegs_required := ((invoking_mode_l = 'L') or
                ((invoking_mode_l = 'V') and not vv_flags.default_all_required));
    vv_flags.stop_on_security := ((invoking_mode_l = 'V') OR
                        ((invoking_mode_l = 'L') AND (qsecurity = 'Y')));

    /* invoking_mode is added for bug872437. */

    vv_flags.invoking_mode := invoking_mode_l;

-- Parse inputs
--
    if((parse_vrules(vrulestr, v_rules) < 0) OR
       (parse_displayed(kff_id, display_segstr, disp_segs) = FALSE)) then
      goto return_error;
    end if;

    IF (get_extra_cols IS NOT NULL) THEN
       n_xcols := FND_FLEX_SERVER1.to_stringarray2(get_extra_cols,
                                                   FND_FLEX_SERVER1.TERMINATOR, rq_xcols);
     ELSE
       n_xcols := 0;
    END IF;

--  Initialize extra columns to null
--  to prevent no data found error if combination not looked up.
--
    for i in 1..n_xcols loop
      xcol_vals(i) := NULL;
    end loop;

--  List the parsed v-rules if any
--
    IF (fnd_flex_server1.g_debug_level > 0) THEN
       if(v_rules.nvrules > 0) then
          FND_FLEX_SERVER1.add_debug(to_char(v_rules.nvrules) || '{Vrules: ');
          for i in 1..v_rules.nvrules loop
             FND_FLEX_SERVER1.add_debug('(' || v_rules.fq_names(i) || ', ');
             FND_FLEX_SERVER1.add_debug(v_rules.sq_names(i) || ', ');
             FND_FLEX_SERVER1.add_debug(v_rules.ie_flags(i) || ', ');
             FND_FLEX_SERVER1.add_debug(v_rules.cat_vals(i) || ', ');
             FND_FLEX_SERVER1.add_debug(v_rules.app_names(i) || ', ');
             FND_FLEX_SERVER1.add_debug(v_rules.err_names(i) || ')  ');
          end loop;
          FND_FLEX_SERVER1.add_debug('} ');
       end if;

       --  Set up some debug information to return
       --
       FND_FLEX_SERVER1.add_debug('User AppId = ' || to_char(user_apid) ||
                                  ', User Resp = ' || to_char(user_resp) ||
                                  ', User Id = ' || to_char(userid_l));
       FND_FLEX_SERVER1.add_debug('Flex Appl Id = ' || kff_id.application_id ||
                                  ', Flex Code = ' || flex_code ||
                                  ', Structure Number = '|| flex_num ||
                                  ', Dinsert = ' || l_dinsert || '. ');
    END IF;

--  If dinsert = 'D' we do everything except insert the combination.
--
    defer_insrt := ((l_dinsert is not null) and (l_dinsert = 'D'));

--  Bug 1531345

    no_at := ((l_dinsert is not null) and (l_dinsert = 'O'));

-- Dynamic inserts always allowed in FOR_INSERT mode
--
    dynam_insrt := (validate_mode = 'FOR_INSERT') or
          ((l_dinsert is not null) and (l_dinsert = 'F')) or
          ((l_dinsert is not null) and (l_dinsert in ('Y', 'D', 'O')) and
          ((kff_cc.application_table_type is null) or
           (kff_cc.application_table_type = 'G')) and
          (kff_info.dynamic_inserts_feasible_flag = 'Y') and
          (kff_info.dynamic_inserts_allowed_flag = 'Y'));

--  LOADID in FOR_INSERT mode returns ccid_in as the combination id.

    if((invoking_mode_l = 'L') and (validate_mode = 'FOR_INSERT')) then
      comb_id := ccid_in;
    end if;

--  Concatenated segments are input for VALID() or POPID() modes, and for
--  LOADID() mode for invoking_modes other than FULL.
--  For other modes look up the segments by CCID first and check the table
--  qualifiers against the vrules.  If we need to look up by CCID, we will
--  first have to get the names of the segment columns and qualifier columns.
--
    if((invoking_mode_l IN ('V', 'P', 'G')) or  ((invoking_mode_l = 'L') and
       (validate_mode in ('PARTIAL','PARTIAL_IF_POSSIBLE','FOR_INSERT')))) then

--  Convert concatenated segments to array and check there are not too many
--
      if(FND_FLEX_SERVER2.breakup_catsegs(concat_segs,
                kff_info.concatenated_segment_delimiter,
                vv_flags.values_not_ids, disp_segs, nsegs, segs) = FALSE) then
        goto return_error;
      end if;

      IF (fnd_flex_server1.g_debug_level > 0) THEN
         IF (nsegs > 0) THEN
            catsegs := FND_FLEX_SERVER1.from_stringarray(nsegs, segs, '*');
          ELSE
            catsegs := '';
         END IF;
         FND_FLEX_SERVER1.add_debug(catsegs);
      END IF;

    else

--  LOADID() in FULL mode.
--  Look up the segment id's from the table before validating them.
--
      if((ccid_in is null) or (ccid_in < 0)) then
        FND_MESSAGE.set_name('FND', 'FLEX-BAD CCID INPUT');
        FND_MESSAGE.set_token('CCID', to_char(ccid_in));
        goto return_error;
      end if;

--  Get segment mapping to code combinations table
--
      if(FND_FLEX_SERVER2.get_struct_cols(kff_id, kff_cc.table_application_id,
                                  kff_cc.combination_table_id, nsegs, cc_cols,
                                  cc_coltypes, segtypes) = FALSE) then
        goto return_error;
      end if;
      IF (fnd_flex_server1.g_debug_level > 0) THEN
         FND_FLEX_SERVER1.add_debug(' LOADID() found segment mapping: [');
         for i in 1..nsegs loop
            FND_FLEX_SERVER1.add_debug(cc_cols(i) || ' ');
            --FND_FLEX_SERVER1.add_debug(cc_cols(i)||':'||cc_coltypes(i)||' ');
         end loop;
         FND_FLEX_SERVER1.add_debug('] ');
      END IF;

--  In LOADID() we have to look up the qualifier names, columns, and
--  default values prior to looking for the combination.  Therefore we
--  have to hit the tables now to get this information.  However, in
--  POPID() and VALID() we can wait until after value validation and get
--  the qualifier names and table columns from the returned qualifier info
--  thus avoiding the extra table hit below.
--
      if(FND_FLEX_SERVER2.get_all_segquals(kff_id, tbl_quals) = FALSE) then
        goto return_error;
      end if;

      IF (fnd_flex_server1.g_debug_level > 0) THEN
         FND_FLEX_SERVER1.add_debug(' LOADID() found qualifier cols: [');
         for i in 1..tbl_quals.nquals loop
            FND_FLEX_SERVER1.add_debug(tbl_quals.derived_cols(i) || ' ');
         end loop;
         FND_FLEX_SERVER1.add_debug('] ');
      END IF;

--  Next find combination by CCID
--
      comb_id := ccid_in;

      nfound := find_combination(cc_struct, kff_cc, nsegs, cc_cols,
                        cc_coltypes, segtypes, tbl_quals.nquals,
                        tbl_quals.derived_cols, n_xcols, rq_xcols, NULL,
                        comb_id, value_ids, tbl_derv, tbl_quals.sq_values,
                        xcol_vals);
      if(nfound = 0) then
        FND_MESSAGE.set_name('FND', 'FLEX-COMBINATION NOT FOUND');
        FND_MESSAGE.set_token('CCID', ccid_in);
        FND_MESSAGE.set_token('APNM', flex_app_sname);
        FND_MESSAGE.set_token('CODE', flex_code);
        FND_MESSAGE.set_token('NUM', flex_num);
      end if;
      if(nfound <> 1) then
        goto return_error;
      end if;

--  Assign found ids to segment array in.
--
      for i in 1..nsegs loop
        segs(i) := value_ids(i);
      end loop;

      IF (fnd_flex_server1.g_debug_level > 0) THEN
         FND_FLEX_SERVER1.add_debug(' LOADID() found combination.  Segids: ');
         IF (nsegs > 0) THEN
            catsegs := FND_FLEX_SERVER1.from_stringarray(nsegs, segs, '*');
          ELSE
            catsegs := '';
         END IF;
         FND_FLEX_SERVER1.add_debug(catsegs);
      END IF;

--  Next check qualifiers in the table against the vrules.
--  This is done to mimic client behavior, but I think LOADID() shouldnt care.
--
/* bug872437. No vrule check in loadid().
      errcode := check_table_comb(tbl_derv,tbl_quals,v_rules,val_date,FALSE);
      if(errcode <> FND_FLEX_SERVER1.VV_VALID) then
        goto return_outvars;
      end if;
*/
--  Finally, look up all the displayed values and descriptions and
--  derive the qualifiers.  Also check value validation against vrules
--  and optionally against security rules.
--
--  Let this fall through to the validate_struct call and then exit.

    end if;

--  LOADID() will validate ids.
--  POPID() and VALID() require full value validation.
--  Side effect is to fill cc_cols array with the names of the columns into
--  which the segments will be inserted.
--
    errcode := FND_FLEX_SERVER1.validate_struct(kff_id,
             kff_cc.table_application_id, kff_cc.combination_table_id,
             nsegs, segs, disp_segs, vv_flags, val_date, v_rules, user_apid,
             user_resp, nvals, segtypes, segcodes, cc_cols, cc_coltypes,
             value_dvals, value_vals, value_ids, value_descs, desc_lens,
             derv, drv_quals, errsegnum);

    IF (fnd_flex_server1.g_debug_level > 0) THEN
       FND_FLEX_SERVER1.add_debug('SV1.validate_struct() returns errcode ' ||
                                  to_char(errcode) ||' and '|| to_char(nvals) ||
                                  ' values.  SegCodes: ' || segcodes || '.' ||
                                  ' ErrSeg: ' || to_char(errsegnum));
       FND_FLEX_SERVER1.add_debug(' Returned arrays:');
       for i in 1..nvals loop
          FND_FLEX_SERVER1.add_debug('"' || segtypes.vs_format(i) ||
                                     to_char(segtypes.vs_maxsize(i), 'S099') ||
                                     '*' || value_dvals(i) || '*' ||
                                     cc_cols(i) || ':' || cc_coltypes(i) ||'" ');
       end loop;
       FND_FLEX_SERVER1.add_debug('Derived values: Start Date:' ||
                                  to_char(derv.start_valid, DATE_DEBUG_FMT) ||
                                  ' End Date:' ||
                                  to_char(derv.end_valid, DATE_DEBUG_FMT) ||
                                  ' Enabled=' || derv.enabled_flag ||
                                  ' Summary=' || derv.summary_flag || '.');

       --  Print derived qualifiers to debug string
       --
       FND_FLEX_SERVER1.add_debug('Derived Qualifiers=');
       for i in 1..drv_quals.nquals LOOP
          FND_FLEX_SERVER1.add_debug('(' || drv_quals.fq_names(i) || ', '||
                                     drv_quals.sq_names(i) || ', ' ||
                                     drv_quals.sq_values(i) || ', ' ||
                                     drv_quals.derived_cols(i) || ')');
       end loop;
    END IF;

    if (validate_off) then
       derv.enabled_flag := 'Y';
       derv.start_valid := NULL;
       derv.end_valid := NULL;
       userid_l := 2;
    end if;

-- We are done if this is LOADID() or if PARTIAL or PARTIAL_IF_POSSIBLE
-- or if any errors whatsoever.

    if((invoking_mode_l = 'L') or
       (validate_mode in ('PARTIAL', 'PARTIAL_IF_POSSIBLE')) or
       (errcode <> FND_FLEX_SERVER1.VV_VALID)) then
      goto return_outvars;
    end if;


--  If this is not LOADID(), then we still have to get the names and colums
--  for all the qualifiers stored in the table.  We can get this without an
--  extra table hit, by copying the qualifiers returned by validate_struct().
--  Note that the values may change if the combination is in the table.
--
    for i in 1..drv_quals.nquals loop
      tbl_quals.fq_names(i) := drv_quals.fq_names(i);
      tbl_quals.sq_names(i) := drv_quals.sq_names(i);
      tbl_quals.sq_values(i) := drv_quals.sq_values(i);
      tbl_quals.derived_cols(i) := drv_quals.derived_cols(i);
    end loop;
    tbl_quals.nquals := drv_quals.nquals;
    tbl_derv := derv;

--  Set for_insert flag if in for_insert mode
--
    for_insert := (validate_mode = 'FOR_INSERT');

--  We also have to substitute the values for $PROFILES$ in the where clause
--  before using it.
--  Keep nice_where_cl null if in for insert mode.
--
    if(not for_insert) then
      errcode:=FND_FLEX_SERVER1.parse_where_token(where_clause,nice_where_cl);
      if(errcode <> FND_FLEX_SERVER1.VV_VALID) then
        goto return_outvars;
      end if;
    end if;

--  In FOR_INSERT mode, it is an error if the combination exists even without
--  the where clause, unless the ccid of the found combination is ccid_in
--  (in which case we have re-queried an existing combination).
--
--  Otherwise check to see if the combination is there.  Set comb_id to null
--  to make sure we search by segment ids rather than by CCID.
--

    comb_id := NULL;
    nfound := find_combination(cc_struct, kff_cc, nvals, cc_cols,
                        cc_coltypes, segtypes, tbl_quals.nquals,
                        tbl_quals.derived_cols, n_xcols, rq_xcols,
                        nice_where_cl, comb_id, value_ids, tbl_derv,
                        tbl_quals.sq_values, xcol_vals);

    if(for_insert) then

--  In for insert mode,
--  if combination exists and ccid matches ccid_in we are done.
--  If it exists and ccid does not match its an error.
--  If combination does not exist continue on.
--
      if((nfound = 1) and (ccid_in is not null) and (ccid_in <> 0) and
         (ccid_in <> -1) and (comb_id = ccid_in)) then
        errcode := FND_FLEX_SERVER1.VV_VALID;
        goto return_outvars;
      elsif(nfound >= 1) then
        FND_MESSAGE.set_name('FND', 'FLEX-COMB. ALREADY EXISTS');
        errcode := FND_FLEX_SERVER1.VV_COMBEXISTS;
        goto return_outvars;
      else
        if(nfound <> 0) then
          goto return_error;
        end if;
      end if;

    else

      if(nfound > 0) then
        new_comb := FALSE;
        IF (fnd_flex_server1.g_debug_level > 0) THEN
           FND_FLEX_SERVER1.add_debug(' Combination already exists.  CCID = ');
           FND_FLEX_SERVER1.add_debug(to_char(comb_id));
        END IF;
      end if;

--  If found, Check qualifiers in the table against the vrules and return.
--  This is done to mimic client behavior.
--
      if(nfound = 1) then
        errcode := check_table_comb(tbl_derv, tbl_quals,v_rules,val_date,TRUE);
        goto return_outvars;
      elsif((nfound > 1) or (nfound < 0)) then
        goto return_error;
      else
        null;
      end if;

    end if;

--  If dynamic insert requested, and where clause is not null,
--  then check without the where clause.
--
--    if((dynam_insrt) and (where_clause is not null)) then
-- check where_clause all the time.
--
    if(where_clause is not null) then
      comb_id := NULL;
      nfound := find_combination(cc_struct, kff_cc, nvals, cc_cols,
                        cc_coltypes, segtypes, tbl_quals.nquals,
                        tbl_quals.derived_cols, n_xcols, rq_xcols, NULL,
                        comb_id, value_ids, tbl_derv, tbl_quals.sq_values,
                        xcol_vals);
      if(nfound = 1) THEN
         IF (NOT parse_set_msg(where_clause_msg)) THEN
            FND_MESSAGE.set_name('FND', 'FLEX-WHERE CLAUSE FAILURE');
            FND_MESSAGE.set_token('WHERE', where_clause);
         END IF;
        errcode := FND_FLEX_SERVER1.VV_WHEREFAILURE;
        goto return_outvars;
      elsif((nfound > 1) or (nfound < 0)) then
        goto return_error;
      else
        null;
      end if;
    end if;

--  If we get to here, combination is not found.
--  If dynamic insert not requested, return error.
--
-- This part was before the WHERE_CLAUSE check.
--
    if(not dynam_insrt) THEN
       IF (NOT parse_set_msg(no_combmsg)) THEN
          FND_MESSAGE.set_name('FND', 'FLEX-NO DYNAMIC INSERTS');
       END IF;
       errcode := FND_FLEX_SERVER1.VV_COMBNOTFOUND;
       goto return_outvars;
    end if;


--  Next do the cross validation if flag is set.
--
    if(kff_info.cross_segment_validation_flag = 'Y' AND NOT validate_off) then
      errcode := FND_FLEX_SERVER2.cross_validate(nvals, value_vals, segtypes,
                                                 val_date, kff_id, error_col);
      if(errcode <> FND_FLEX_SERVER1.VV_VALID) then
        errsegnum := find_column_index(cc_cols, nvals, error_col);
        IF (fnd_flex_server1.g_debug_level > 0) THEN
           FND_FLEX_SERVER1.add_debug(' CROSS-VALIDATION-INVALID ON SEG ' ||
                                      to_char(errsegnum) || '. ');
        END IF;
        goto return_outvars;
      end if;
    end if;


--  Finally, Insert the combination.  Feasibility already checked above.
--  If combination is new, call FDFGLI on accounting flexfield.
--  Else, check if combination existing in the combinations table is
--  disabled, expired or violates vrules.
--  Set savepoint and rollback if insert or fdfgli fails.
--  Once savepoint has been set we need to go to rollback_error rather
--  than return_error to make sure changes are rolled back on error.
--  Also need to rollback if combination already exists to remove hash lock.
--  Each savepoint outdates the previous one with the same name.
--
--  Bug 1531345 - Commit in AT causing problems, so allow for original insert
--    if no_at is true.
    IF ((invoking_mode_l IN ('V')) and (defer_insrt = FALSE) AND
         ((for_insert) OR (no_at))) THEN
       --
       -- We are in Maintenance Form.
       -- We will not do the real insert, we will just lock the
       -- hash number, and let Maintenenace Form do the insert.
       -- So no need to call AutoTrans function.
       --
       IF (fnd_flex_server1.g_debug_level > 0) THEN
          fnd_flex_server1.add_debug('FOR_INSERT:Maintenance Form');
       END IF;
       SAVEPOINT pre_insert_comb;


       if(insert_combination(kff_id, cc_struct, for_insert, val_date,
                             kff_info.concatenated_segment_delimiter,
                             ccid_in, kff_cc, cc_cols, cc_coltypes,
                             userid_l, nvals, value_ids, segtypes,
                             derv, drv_quals, n_xcols, rq_xcols, xcol_vals,
                             tbl_quals.sq_values, tbl_derv, new_comb,
                             comb_id) = FALSE) then
          ROLLBACK TO SAVEPOINT pre_insert_comb;
          goto return_error;
       end if;

       if(FND_FLEX_SERVER2.x_drop_cached_cv_result(kff_id, nvals, value_vals)
          = FALSE) then
          ROLLBACK TO SAVEPOINT pre_insert_comb;
          goto return_error;
       end if;

       if(new_comb) then
          if((flex_app_sname ='SQLGL') and (flex_code ='GL#')
               and (NOT for_insert)) then
             if(call_fdfgli(comb_id) = FALSE) then
                ROLLBACK TO SAVEPOINT pre_insert_comb;
                goto return_error;
             end if;
          end if;
          errcode := FND_FLEX_SERVER1.VV_VALID;
        else
          ROLLBACK TO SAVEPOINT pre_insert_comb;
          if(for_insert and ((ccid_in is null) or (ccid_in = 0) or
                             (ccid_in = -1) or (comb_id <> ccid_in))) then
             FND_MESSAGE.set_name('FND', 'FLEX-COMB. ALREADY EXISTS');
             errcode := FND_FLEX_SERVER1.VV_COMBEXISTS;
             goto return_error;
          end if;
          errcode:=check_table_comb(tbl_derv,tbl_quals,v_rules,
                                    val_date,TRUE);
       end if;
     ELSIF ((invoking_mode_l IN  ('V','P', 'G')) and (defer_insrt = FALSE) AND
            (NOT for_insert)) THEN
          --
          -- We are called from a foreign key form.
          -- In this case use the AutoTrans.
          --
       IF (fnd_flex_server1.g_debug_level > 0) THEN
          fnd_flex_server1.add_debug('Autonomous Transaction');
       END IF;
          if(insert_combination_at
             (kff_id, cc_struct, for_insert, val_date,
              kff_info.concatenated_segment_delimiter,
              ccid_in, kff_cc, cc_cols, cc_coltypes,
              userid_l, nvals, value_ids, value_vals, segtypes,
              derv, drv_quals, n_xcols, rq_xcols, xcol_vals,
              tbl_quals.sq_values, tbl_derv, new_comb,
              comb_id) = FALSE) then
             goto return_error;
          end if;
          IF (new_comb) THEN
             errcode := FND_FLEX_SERVER1.VV_VALID;
           ELSE
             if(for_insert and ((ccid_in is null) or (ccid_in = 0) or
                                (ccid_in = -1) or (comb_id <> ccid_in))) then
                FND_MESSAGE.set_name('FND', 'FLEX-COMB. ALREADY EXISTS');
                errcode := FND_FLEX_SERVER1.VV_COMBEXISTS;
                goto return_error;
             end if;
             errcode:=check_table_comb(tbl_derv,tbl_quals,v_rules,
                                       val_date,TRUE);
          END IF;
     elsif(invoking_mode_l in ('P', 'G')) then
       if(for_insert and (ccid_in is not null) and (ccid_in <> 0)) then
        comb_id := ccid_in;
      else
        comb_id := -1;
      end if;
      errcode := FND_FLEX_SERVER1.VV_VALID;
    elsif((invoking_mode_l = 'V') and (defer_insrt = TRUE)) then
      comb_id := -1;
      errcode := FND_FLEX_SERVER1.VV_VALID;
    else
      errcode := FND_FLEX_SERVER1.VV_ERROR;
    end if;

  <<return_outvars>>
    displayed_vals := value_dvals;
    stored_vals := value_vals;
    segment_ids := value_ids;
    descriptions := value_descs;
    desc_lengths := desc_lens;
    seg_colnames := cc_cols;
    seg_coltypes := cc_coltypes;
    nvalidated := nvals;
    segment_types := segtypes;
    displayed_segs := disp_segs;
    derived_eff := derv;
    table_eff := tbl_derv;
    table_quals := tbl_quals;
    derived_quals := drv_quals;
    column_vals := xcol_vals;
    n_column_vals := n_xcols;
    seg_delimiter := kff_info.concatenated_segment_delimiter;
    ccid_out := comb_id;
    new_combination := new_comb;
    seg_codes := segcodes;
    err_segnum := errsegnum;
    v_status := errcode;
    GOTO goto_return;

  <<return_error>>
    v_status := FND_FLEX_SERVER1.VV_ERROR;
    GOTO goto_return;

  <<goto_return>>
    IF (fnd_flex_server1.g_debug_level > 0) THEN
       fnd_flex_server1.add_debug('END SSV.validation_engine()');
    END IF;
    RETURN;

  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG','SSV.validation_engine() exception: '||SQLERRM);
      v_status := FND_FLEX_SERVER1.VV_ERROR;
      IF (fnd_flex_server1.g_debug_level > 0) THEN
         fnd_flex_server1.add_debug('EXCEPTION others SSV.validation_engine()');
      END IF;
      return;
  END validation_engine;


  FUNCTION x_bind_additional_where_clause(p_additional_where_clause IN VARCHAR2)
    RETURN BOOLEAN
    IS
       l_awc        VARCHAR2(32000);
       l_awc_len    NUMBER;
       l_pos1       NUMBER;
       l_pos2       NUMBER;
       l_posq       NUMBER;
       l_bind_value VARCHAR2(32000);
  BEGIN
     l_awc := p_additional_where_clause;
     l_awc_len := Length(l_awc);
     IF (l_awc IS NULL) THEN
        RETURN(TRUE);
     END IF;

     fnd_dsql.add_text(' and (');

     l_pos2 := 0;
     l_pos1 := Instr(l_awc, '''', l_pos2 + 1, 1);
     WHILE (l_pos1 > 0) LOOP
        --
        -- Copy upto single quote.
        --
        fnd_dsql.add_text(Substr(l_awc, l_pos2 + 1, (l_pos1 - l_pos2) - 1));

        --
        -- Find the closing quote. Handle single quote escaping.
        --
        l_posq := Instr(l_awc, '''''', l_pos1 + 1, 1);
        l_pos2 := Instr(l_awc, '''', l_pos1 + 1, 1);

        WHILE (l_pos2 = l_posq) LOOP
           l_pos2 := Instr(l_awc, '''', l_posq + 2, 1);
           l_posq := Instr(l_awc, '''''', l_posq + 2, 1);
        END LOOP;

        IF (l_pos2 = 0) THEN
           fnd_message.set_name('FND', 'FLEX-SQL MISSING QUOTE');
           fnd_message.set_token('CLAUSE', Substr(l_awc, 1, 1000));
           RETURN(FALSE);
        END IF;

        fnd_dsql.add_bind(REPLACE(Substr(l_awc, l_pos1 + 1, (l_pos2-l_pos1)- 1),
                                  '''''', ''''));

        l_pos1 := Instr(l_awc, '''', l_pos2 + 1, 1);
     END LOOP;

     fnd_dsql.add_text(Substr(l_awc, l_pos2 + 1, l_awc_len - l_pos2));
     fnd_dsql.add_text(')');

     RETURN(TRUE);
  EXCEPTION
     WHEN OTHERS THEN
        FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
        FND_MESSAGE.set_token('MSG','x_bind_additional_where_clause() exception: '||SQLERRM);
        RETURN(FALSE);
  END x_bind_additional_where_clause;


/* ----------------------------------------------------------------------- */
/*      Finds ccid, segment ids, qualifier values, enabled and expiration  */
/*      info and extra column values for a segment combination.            */
/*      If the CCID input is not null, looks for the combination by CCID   */
/*      otherwise looks for combination whose segment id values match      */
/*      those input in the SEGS parameter.                                 */
/*      If segment passed in is null, then find_combination() looks for    */
/*      a combination with NULL in that column.                            */
/*      Returns number of combinations found or < 0 if error.              */
/*      If combination not found, all output variables are null.           */
/* ----------------------------------------------------------------------- */
  FUNCTION find_combination(structnum IN     NUMBER,
                            combtbl   IN     FND_FLEX_SERVER1.CombTblInfo,
                            nsegs     IN     NUMBER,
                            combcols  IN     FND_FLEX_SERVER1.TabColArray,
                            combtypes IN     FND_FLEX_SERVER1.CharArray,
                            segfmts   IN     FND_FLEX_SERVER1.SegFormats,
                            nquals    IN     NUMBER,
                            qualcols  IN     FND_FLEX_SERVER1.TabColArray,
                            nxcols    IN     NUMBER,
                            xcolnames IN     FND_FLEX_SERVER1.StringArray,
                            where_cl  IN     VARCHAR2,
                            ccid      IN OUT nocopy NUMBER,
                            segids    IN OUT nocopy FND_FLEX_SERVER1.ValueIdArray,
                            tblderv   OUT    nocopy FND_FLEX_SERVER1.DerivedVals,
                            qualvals  OUT    nocopy FND_FLEX_SERVER1.ValAttribArray,
                            xcolvals  OUT    nocopy FND_FLEX_SERVER1.StringArray)
                                                               RETURN NUMBER IS
    offset      BINARY_INTEGER;
    nrecords    NUMBER;
    colvals     FND_FLEX_SERVER1.StringArray;
    l_vc2       VARCHAR2(100);

  BEGIN

--  Assumes all segment columns in combinations table are CHAR or VARCHAR2
--

--  Build SQL statement to select ccid, enabled information, segment columns,
--  qualifiers, and extra cols in that order.
--
    fnd_dsql.init;

    sqls := 'select to_char(' || combtbl.unique_id_column_name || '), ';
    sqls := sqls || 'nvl(ENABLED_FLAG, ''Y''), nvl(SUMMARY_FLAG, ''N''), ';
    sqls := sqls || 'to_char(START_DATE_ACTIVE, ''' ||
                                FND_FLEX_SERVER1.DATETIME_FMT || '''), ';
    sqls := sqls || 'to_char(END_DATE_ACTIVE, ''' ||
                                FND_FLEX_SERVER1.DATETIME_FMT || ''')';
    for i in 1..nsegs loop
      sqls := sqls || ', ' || FND_FLEX_SERVER1.select_clause(combcols(i),
                                combtypes(i), FND_FLEX_SERVER1.VC_ID,
                                segfmts.vs_format(i), segfmts.vs_maxsize(i));
    end loop;
    for i in 1..nquals loop
      sqls := sqls || ', ' || qualcols(i);
    end loop;
    for i in 1..nxcols loop
      sqls := sqls || ', ' || xcolnames(i);
    end loop;

-- If no structure column, Client only finds combinations for struct 101.
    sqls := sqls || ' from ' || combtbl.select_comb_from || ' where ';
    if(combtbl.set_defining_column_name is not null) then
      sqls := sqls || combtbl.set_defining_column_name;
    else
      sqls := sqls || '101';
    end if;

    sqls := sqls || ' = ';

    fnd_dsql.add_text(sqls);
    fnd_dsql.add_bind(structnum);

--  If CCID input select by CCID, otherwise select by segment ids.
--
    if(ccid is not null) THEN
       fnd_dsql.add_text(' and ' || combtbl.unique_id_column_name || ' = ');
       fnd_dsql.add_bind(ccid);
     ELSE
       for i in 1..nsegs LOOP
          fnd_dsql.add_text(' and (' || combcols(i));
          if(segids(i) is null) THEN
             fnd_dsql.add_text(' is null)');
           else
             fnd_dsql.add_text(' = ');
             --
             -- This will call fnd_dsql.add_bind
             --
             fnd_flex_server1.x_compare_clause
               (combtypes(i),
                combcols(i), segids(i), FND_FLEX_SERVER1.VC_ID,
                segfmts.vs_format(i), segfmts.vs_maxsize(i));

             fnd_dsql.add_text(')');
          end if;
       end loop;
       if(where_cl is not null) THEN
          --
          -- Parse the literals out and bind them.
          --
          IF (NOT x_bind_additional_where_clause(where_cl)) THEN
             RETURN(-5);
          END IF;
       end if;
    end if;

--  Do the lookup
--

    --
    -- This will use the sql string stored in fnd_dsql package.
    --
    nrecords := fnd_flex_server1.x_dsql_select(nsegs + nquals + nxcols + 5,
                                             colvals);

--  Return output information.
--
    if(nrecords > 0) then

--    Copy ccid, enabled flag and dates and summary flag values to output.
--
      ccid := to_number(colvals(1));
      tblderv.enabled_flag := colvals(2);
      tblderv.summary_flag := colvals(3);
      tblderv.start_valid := to_date(colvals(4),FND_FLEX_SERVER1.DATETIME_FMT);
      tblderv.end_valid := to_date(colvals(5), FND_FLEX_SERVER1.DATETIME_FMT);

--    Copy segment column values to output
--
      offset := 5;
      for i in 1..nsegs loop
        segids(i) := colvals(i + offset);
      end loop;

--    Copy table qualifier values to output
--
      offset := nsegs + 5;
      for i in 1..nquals loop
        qualvals(i) := colvals(i + offset);
      end loop;

--    Copy extra column values to output
--
      offset := nsegs + nquals + 5;
      for i in 1..nxcols loop
        xcolvals(i) := colvals(i + offset);
      end loop;

    else

--  Null out returned extra column and qualifier value arrays to avoid
--  no data found error when accessing them.
--
      for i in 1..nquals loop
        qualvals(i) := NULL;
      end loop;
      for i in 1..nxcols loop
        xcolvals(i) := NULL;
      end loop;

    end if;

    if(nrecords > 1) then
      FND_MESSAGE.set_name('FND', 'FLEX-DUPLICATE CCID');
      FND_MESSAGE.set_token('CCID', to_char(ccid));
    end if;

    return(nrecords);

    EXCEPTION
      WHEN OTHERS then
        FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
        FND_MESSAGE.set_token('MSG','SSV.find_combination() exception: '||SQLERRM);
        return(-3);

  END find_combination;

/* ----------------------------------------------------------------------- */
/*      Inserts combination of segment ids into code combinations table.   */
/*                                                                         */
/*      If combination has been created since last checked, get it from    */
/*      the combinations table along with all the other table values for   */
/*      the qualifiers, extra columns, and enabled and effective dates.    */
/*      Determine names of qualifier columns from the derived qualifiers   */
/*      input to this function.  Returns table qualifier values = derived  */
/*      qualifier values, table effecitivity information = derived         */
/*      effectivity information, and null for extra columns for new combs. */
/*      returns newcomb = TRUE if just created this combination.           */
/*      If segment column is of type number, then does the default         */
/*      conversion on the character representation of the segment id.      */
/*      If segment column is of type date, does default to_date()          */
/*      conversion for non-translatable date, time and date-time value     */
/*      sets, but does correctly-formatted conversions for translatable    */
/*      dates, times and date times.  This should emulate client behavior. */
/*                                                                         */
/*      If maintmode = TRUE, then user has called this in FOR_INSERT mode. */
/*      In that case do not insert combination if it does not already      */
/*      exist, just return the ccid.  If editing an existing combination   */
/*      the ccid_inp will be the ccid of the combination being edited.     */
/*      In that case, do not create a new ccid, but just return ccid_inp.  */
/*      If the ccid_inp is not null, 0 or -1 consider it to be ok to use.  */
/*                                                                         */
/*      Calls user PLSQL validation function after locking the             */
/*      combination, getting a new CCID, and double-checking to make       */
/*      sure nobody else has created the combination since we last checked.*/
/*      This is done at this time to maintain exact backward compatibility */
/*      with the client c-code.  It would make more sense to do the user   */
/*      validation before calling insert_combination(), but then more than */
/*      one user might call the user validation function with the same     */
/*      combination, and somebody might be relying on this corner-case     */
/*      functionality.                                                     */
/*      If the user PLSQL validation function returns FALSE,               */
/*      insert_combination() returns FALSE indicating a fatal error        */
/*      condition.  In this case the error message is already loaded       */
/*      in FND_MESSAGE.                                                    */
/*      A SAVEPOINT must be issued externally to this function and         */
/*      a rollback must occur if insert_combination returns an error       */
/*      of if it returns new_comb = FALSE to unlock the hash number.       */
/*                                                                         */
/*      Returns TRUE on success or FALSE and sets message on error.        */
/* ----------------------------------------------------------------------- */
  FUNCTION insert_combination(fstruct   IN  FND_FLEX_SERVER1.FlexStructId,
                              structnum IN  NUMBER,
                              maintmode IN  BOOLEAN,
                              v_date    IN  DATE,
                              seg_delim IN  VARCHAR2,
                              ccid_inp  IN  NUMBER,
                              combtbl   IN  FND_FLEX_SERVER1.CombTblInfo,
                              combcols  IN  FND_FLEX_SERVER1.TabColArray,
                              combtypes IN  FND_FLEX_SERVER1.CharArray,
                              user_id   IN  NUMBER,
                              nsegs     IN  NUMBER,
                              segids_in IN  FND_FLEX_SERVER1.ValueIdArray,
                              segfmts   IN  FND_FLEX_SERVER1.SegFormats,
                              dvalues   IN  FND_FLEX_SERVER1.DerivedVals,
                              dquals    IN  FND_FLEX_SERVER1.Qualifiers,
                              nxcols    IN  NUMBER,
                              xcolnames IN  FND_FLEX_SERVER1.StringArray,
                              xcolvals  OUT nocopy FND_FLEX_SERVER1.StringArray,
                              qualvals  OUT nocopy FND_FLEX_SERVER1.ValAttribArray,
                              tblderv   OUT nocopy FND_FLEX_SERVER1.DerivedVals,
                              newcomb   OUT nocopy BOOLEAN,
                              ccid_out  OUT nocopy NUMBER) RETURN BOOLEAN IS

    deadlock            EXCEPTION;
    ccid                NUMBER;
    nfound              NUMBER;
    hash_num            NUMBER;
    hash_number         NUMBER;
    ccid_string         VARCHAR2(50);
    segids              FND_FLEX_SERVER1.ValueIdArray;

    PRAGMA EXCEPTION_INIT(deadlock, -60);

  BEGIN

-- For debugging...
--

     IF (fnd_flex_server1.g_debug_level > 0) THEN
        FND_FLEX_SERVER1.add_debug(to_char(nsegs) ||
                                   ' segs passed to insert_combination().');
     END IF;

--  First lock this combination and prevent other users from inserting.
--  Generate an almost unique hash number from the segments ids.
--  and lock that row in the hash table to prevent other users from
--  inserting the same combination.  The commit will drop the locks.-
--  GL requires row share lock on combinations table to prevent them from
--  getting an exclusive lock for their processing.

    segids := segids_in;

    sqls := 'lock table ' || combtbl.application_table_name;
    sqls := sqls || ' in row share mode';

    fnd_dsql.init;
    fnd_dsql.add_text(sqls);
    if(FND_FLEX_SERVER1.x_dsql_execute < 0) then
       return(FALSE);
    end if;

--  Next compute the hash number that is to be locked.
--
    hash_number := hash_segs(nsegs, segids);
    if(hash_number < 0) then
      return(FALSE);
    end if;

    IF (fnd_flex_server1.g_debug_level > 0) THEN
       FND_FLEX_SERVER1.add_debug('Hash value = '||to_char(hash_number)||'.');
    END IF;
    SELECT hash_value INTO hash_num FROM fnd_flex_hash
     WHERE hash_value = hash_number FOR UPDATE;

--  Double-check to see if it has been created.  No where clause this time.
--
    nfound := find_combination(structnum, combtbl, nsegs, combcols,
                               combtypes, segfmts, dquals.nquals,
                               dquals.derived_cols, nxcols, xcolnames, NULL,
                               ccid, segids, tblderv, qualvals, xcolvals);
    if(nfound <> 0) then
      if(nfound >= 1) then
        newcomb := FALSE;
        ccid_out := ccid;
        return(TRUE);
      end if;
      return(FALSE);
    end if;

--  Get unique code combination ID from a sequence if we dont already have it.
--  If ccid_inp is 0 or null or -1 we need to generate a new ccid.
--  Must use dynamic SQL here since ccid comes from the application table
--  with a '_S' suffix.  Could do without dynamic sql if we had a fixed
--  sequence name.
--
    if(maintmode and (ccid_inp is not null) and (ccid_inp <> 0) and
        (ccid_inp <> -1)) then
      ccid := ccid_inp;
    else
      sqls := 'select to_char(' || combtbl.application_table_name;
      sqls := sqls || '_S.NEXTVAL) from dual';
      fnd_dsql.init;
      fnd_dsql.add_text(sqls);
      if(FND_FLEX_SERVER1.x_dsql_select_one(ccid_string) <> 1) then
        return(FALSE);
      end if;
      ccid := to_number(ccid_string);
      if(ccid > MAX_CCID) then
        FND_MESSAGE.set_name('FND', 'FLEX-CCID TOO BIG');
        FND_MESSAGE.set_token('CCIDLIMIT', to_char(MAX_CCID));
        FND_MESSAGE.set_token('SEQNAME', combtbl.application_table_name||'_S');
        return(FALSE);
      end if;
    end if;

--  Call user validation function now if desired.  Bail if error.
--
    if(userval_on) then
      if(NOT call_userval(fstruct, v_date, nsegs, seg_delim, segids_in)) then
        return(FALSE);
      end if;
    end if;

--  If not in maintainence mode do the insert, otherwise skip to the end.
--
    if(NOT maintmode) then

       --  Build a SQL statement to do the insert.
       --
       fnd_dsql.init;
       sqls := 'insert into ' || combtbl.application_table_name || ' (';
       sqls := sqls || combtbl.unique_id_column_name;
       if(combtbl.set_defining_column_name is not null) then
          sqls := sqls || ', ' || combtbl.set_defining_column_name;
       end if;
       sqls := sqls || ', ENABLED_FLAG, SUMMARY_FLAG, ';
       sqls := sqls || 'START_DATE_ACTIVE, END_DATE_ACTIVE, ';
       sqls := sqls || 'LAST_UPDATE_DATE, LAST_UPDATED_BY';
       for i in 1..dquals.nquals loop
          sqls := sqls || ', ' || dquals.derived_cols(i);
       end loop;
       for i in 1..nsegs loop
          if(segids(i) is not null) then
             sqls := sqls || ', ' || combcols(i);
          end if;
       end loop;
       sqls := sqls || ') values (';

       -- So far the table name and the column names.
       fnd_dsql.add_text(sqls);

       fnd_dsql.add_bind(ccid);

       if(combtbl.set_defining_column_name is not null) THEN
          fnd_dsql.add_text(',');
          fnd_dsql.add_bind(structnum);
       end if;

       fnd_dsql.add_text(',');
       fnd_dsql.add_bind(dvalues.enabled_flag);

       fnd_dsql.add_text(',');
       fnd_dsql.add_bind(dvalues.summary_flag);

       fnd_dsql.add_text(',');
       fnd_dsql.add_bind(dvalues.start_valid);

       fnd_dsql.add_text(',');
       fnd_dsql.add_bind(dvalues.end_valid);

       fnd_dsql.add_text(',sysdate,');
       fnd_dsql.add_bind(user_id);

       for i in 1..dquals.nquals LOOP
          fnd_dsql.add_text(',');
          fnd_dsql.add_bind(dquals.sq_values(i));
       end loop;

       for i in 1..nsegs loop
          if(segids(i) is not null) THEN
             fnd_dsql.add_text(',');
             --
             -- This will call fnd_dsql.add_bind
             --
             fnd_flex_server1.x_compare_clause
               (combtypes(i),
                combcols(i), segids(i), FND_FLEX_SERVER1.VC_ID,
                segfmts.vs_format(i), segfmts.vs_maxsize(i));
          end if;
       end loop;
       fnd_dsql.add_text(')');

       --
       --  Finally do the insert
       --
       if(FND_FLEX_SERVER1.x_dsql_execute < 0) then
          return(FALSE);
       end if;
    end if;

--  Return all out variables.  If comb was found in table these were set
--  above.
--
    IF (fnd_flex_server1.g_debug_level > 0) THEN
       FND_FLEX_SERVER1.add_debug(' Returning ccid = '||to_char(ccid) || '. ');
    END IF;
    ccid_out := ccid;
    newcomb := TRUE;
    tblderv := dvalues;
    for i in 1..nxcols loop
      xcolvals(i) := NULL;
    end loop;
    for i in 1..dquals.nquals loop
      qualvals(i) := dquals.sq_values(i);
    end loop;
    return(TRUE);

  EXCEPTION
    WHEN NO_DATA_FOUND then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG', 'Hash value ' ||
                            to_char(hash_number) || ' not found.');
      return(FALSE);
    WHEN TOO_MANY_ROWS then
      FND_MESSAGE.set_token('MSG', 'Hash value ' ||
                            to_char(hash_number) || ' not unique.');
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      return(FALSE);
    WHEN TIMEOUT_ON_RESOURCE then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG', 'Timeout waiting for lock on hash table.');
      return(FALSE);
    WHEN deadlock then
      FND_MESSAGE.set_name('FND', 'FLEX-HASH DEADLOCK');
      return(FALSE);
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG','insert_combination() exception: '||SQLERRM);
      return(FALSE);

  END insert_combination;


/* ----------------------------------------------------------------------- */
/*      Sums ASCII values of all characters mod NHASH.  ASCII returns code */
/*      up to 64K for multi-byte characters.  Multiply code for each char  */
/*      by the characters position to make non-commutative                 */
/* ----------------------------------------------------------------------- */

  FUNCTION hash_segs(n IN NUMBER, segs IN FND_FLEX_SERVER1.ValueIdArray)
          RETURN NUMBER IS

    hval        NUMBER;
    cval        NUMBER;
    seglen      NUMBER;
    chr_count   NUMBER;

  BEGIN

    hval := 0;
    chr_count := 1;
    for segnum in 1..n loop
      if(segs(segnum) is not null) then
        seglen := LENGTH(segs(segnum));
        for i in 1..seglen loop
          cval := ASCII(SUBSTR(segs(segnum), i, 1));
          hval := hval + cval*chr_count;
          chr_count := chr_count + 1;
        end loop;
      end if;
    end loop;
    return(MOD(hval, NHASH));

    EXCEPTION
      WHEN OTHERS then
        FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
        FND_MESSAGE.set_token('MSG', 'hash_segs() exception: ' || SQLERRM);
        return(-1);

  END hash_segs;

/* ----------------------------------------------------------------------- */
/*      Checks the expiration date, enabled flag and vrules against the    */
/*      combination returned from the combinations tables.  This must be   */
/*      done in case user has updated the combinations table to differ     */
/*      from the derived values.  Only checks the expiration and enabled   */
/*      flags if check_effective flag is TRUE.                             */
/*      Error code indicating result of validation.  VV_VALID means all ok */
/* ----------------------------------------------------------------------- */

  FUNCTION check_table_comb(t_dval          IN  FND_FLEX_SERVER1.DerivedVals,
                            t_quals         IN  FND_FLEX_SERVER1.Qualifiers,
                            v_rules         IN  FND_FLEX_SERVER1.Vrules,
                            v_date          IN  DATE,
                            check_effective IN  BOOLEAN) RETURN NUMBER IS
  BEGIN

--  Print table segments, qualifiers, extra columns and effectivity info.
--
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        FND_FLEX_SERVER1.add_debug('Check expiration/vrules on table quals.');

        FND_FLEX_SERVER1.add_debug('Qualifiers: ');
        for i in 1..t_quals.nquals loop
           FND_FLEX_SERVER1.add_debug('(' || t_quals.sq_names(i) || ' = ');
           FND_FLEX_SERVER1.add_debug(t_quals.sq_values(i) || ') ');
        end loop;

        FND_FLEX_SERVER1.add_debug('Enabled: ' || t_dval.enabled_flag);
        FND_FLEX_SERVER1.add_debug
          (' Starts: ' || to_char(t_dval.start_valid,
                                  FND_FLEX_SERVER1.DATETIME_FMT));
        FND_FLEX_SERVER1.add_debug
          (' Ends: ' || to_char(t_dval.end_valid,
                                FND_FLEX_SERVER1.DATETIME_FMT));
        FND_FLEX_SERVER1.add_debug(' Summary Flag: ' || t_dval.summary_flag);
     END IF;
-- Check if combination turned on
--
    if(check_effective) then
      if(t_dval.enabled_flag <> 'Y') then
        FND_MESSAGE.set_name('FND', 'FLEX-COMBINATION DISABLED');
        return(FND_FLEX_SERVER1.VV_VALUES);
      end if;
      if((v_date is not null) and
         ((Trunc(v_date) < Trunc(nvl(t_dval.start_valid, v_date))) or
          (Trunc(v_date) > Trunc(nvl(t_dval.end_valid, v_date))))) then
        FND_MESSAGE.set_name('FND', 'FLEX-COMBINATION HAS EXPIRED');
        return(FND_FLEX_SERVER1.VV_VALUES);
      end if;
    end if;

-- Check vrules.
--
    return(FND_FLEX_SERVER1.check_comb_vrules(v_rules, t_quals,
                                              t_dval.summary_flag));
    EXCEPTION
      WHEN OTHERS then
        FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
        FND_MESSAGE.set_token('MSG','check_table_comb() exception: '||SQLERRM);
        return(FND_FLEX_SERVER1.VV_ERROR);

  END check_table_comb;

/* ----------------------------------------------------------------------- */
/*      Determines the segment number of the given column name.            */
/*      Returns null without erroring if the name is not on the list.      */
/* ----------------------------------------------------------------------- */

  FUNCTION find_column_index(column_list  IN  FND_FLEX_SERVER1.TabColArray,
                             column_count IN  NUMBER,
                             colname      IN  VARCHAR2) RETURN NUMBER IS
    colnum     NUMBER;

  BEGIN
--  Set colnum only if name found.
--
    for i in 1..column_count loop
      if(UPPER(colname) = UPPER(column_list(i))) then
        colnum := i;
        exit;
      end if;
    end loop;
    return(colnum);

  END find_column_index;

/* ----------------------------------------------------------------------- */
/*      Concatenate Values into a string for return to the client.         */
/*      If only one value displayed does not substitute CR for delimiter.  */
/*      Concatenates only displayed values.                                */
/* ----------------------------------------------------------------------- */

  FUNCTION concatenate_values(nvals     IN NUMBER,
                              vals      IN FND_FLEX_SERVER1.ValueArray,
                              displ     FND_FLEX_SERVER1.DisplayedSegs,
                              delimiter IN VARCHAR2) RETURN VARCHAR2 IS
    n_displayed NUMBER;
    str         FND_FLEX_SERVER1.StringArray;
  BEGIN
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        fnd_flex_server1.add_debug('BEGIN SSV.concatenate_values()');
     END IF;
    n_displayed := 0;
    for i in 1..nvals loop
      if((i <= displ.n_segflags) and displ.segflags(i)) then
        n_displayed := n_displayed + 1;
        str(n_displayed) := vals(i);
      end if;
    end loop;

    IF (n_displayed > 1) THEN
       return(FND_FLEX_SERVER1.from_stringarray(n_displayed, str, delimiter));
     ELSIF (n_displayed = 1) then
       return(str(1));
     ELSE
       RETURN (NULL);
    end if;
  END concatenate_values;

/* ----------------------------------------------------------------------- */
/*      Concatenate Value ids into a string for return to the client.      */
/*      If only one id input does not substitute CR for delimiter.         */
/*      Concatenates all ids whether or not their segments are displayed.  */
/* ----------------------------------------------------------------------- */

  FUNCTION concatenate_ids(nids         IN NUMBER,
                           ids          IN FND_FLEX_SERVER1.ValueIdArray,
                           delimiter    IN VARCHAR2) RETURN VARCHAR2 IS
    str  FND_FLEX_SERVER1.StringArray;
  BEGIN
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        fnd_flex_server1.add_debug('BEGIN SSV.concatenate_ids()');
     END IF;
    if(nids = 1) then
      return(ids(1));
    else
      for i in 1..nids loop
        str(i) := ids(i);
      end loop;
      IF (nids > 1) THEN
         return(FND_FLEX_SERVER1.from_stringarray(nids, str, delimiter));
       ELSIF (nids = 1) THEN
         RETURN(str(1));
       ELSE
         RETURN NULL;
      END IF;
    end if;
  END concatenate_ids;

/* ----------------------------------------------------------------------- */
/*      Concatenate Value descriptions to string for return to the client. */
/*      Only returns descriptions for displayed segments.                  */
/*      Truncates descriptions to lengths specified by flex structure.     */
/*      NOTE:  Lengths are all in BYTES not characters.                    */
/*      If only one value displayed does not substitute CR for delimiter.  */
/* ----------------------------------------------------------------------- */

  FUNCTION concatenate_descriptions(ndescs  IN NUMBER,
                                    descs   IN FND_FLEX_SERVER1.ValueDescArray,
                                    displ   IN FND_FLEX_SERVER1.DisplayedSegs,
                                    lengths IN FND_FLEX_SERVER1.NumberArray,
                                    delimiter   IN VARCHAR2) RETURN VARCHAR2 IS
    n_displayed NUMBER;
    str         FND_FLEX_SERVER1.StringArray;
  BEGIN
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        fnd_flex_server1.add_debug('BEGIN SSV.concatenate_descriptions()');
     END IF;
    n_displayed := 0;
    for i in 1..ndescs loop
      if((i <= displ.n_segflags) and displ.segflags(i)) then
        n_displayed := n_displayed + 1;
        str(n_displayed) := SUBSTRB(descs(i), 1, lengths(i));
      end if;
    end loop;

    IF (n_displayed > 1) THEN
       return(FND_FLEX_SERVER1.from_stringarray(n_displayed, str, delimiter));
     ELSIF (n_displayed = 1) then
       return(str(1));
     ELSE
       RETURN (NULL);
    end if;
  END concatenate_descriptions;

/* ----------------------------------------------------------------------- */
/*      Concatenate Value descriptions to string for return to the client. */
/*      Only returns descriptions for displayed segments.                  */
/*      Does not truncate descriptions.                                    */
/*      If only one value displayed does not substitute CR for delimiter.  */
/* ----------------------------------------------------------------------- */

  FUNCTION concatenate_fulldescs(ndescs  IN NUMBER,
                                 descs   IN FND_FLEX_SERVER1.ValueDescArray,
                                 displ   IN FND_FLEX_SERVER1.DisplayedSegs,
                                 delimiter      IN VARCHAR2) RETURN VARCHAR2 IS
    n_displayed NUMBER;
    str         FND_FLEX_SERVER1.StringArray;
  BEGIN
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        fnd_flex_server1.add_debug('BEGIN SSV.concatenate_fulldesc()');
     END IF;
    n_displayed := 0;
    for i in 1..ndescs loop
      if((i <= displ.n_segflags) and displ.segflags(i)) then
        n_displayed := n_displayed + 1;
        str(n_displayed) := descs(i);
      end if;
    end loop;

    IF (n_displayed > 1) THEN
       return(FND_FLEX_SERVER1.from_stringarray(n_displayed, str, delimiter));
     ELSIF (n_displayed = 1) then
       return(str(1));
     ELSE
       RETURN (NULL);
    end if;
  END concatenate_fulldescs;

/* ----------------------------------------------------------------------- */
/*      Concatenate segment formats to string for return to the client.    */
/* ----------------------------------------------------------------------- */

  FUNCTION concatenate_segment_formats(segfmts IN FND_FLEX_SERVER1.SegFormats)
                                                            RETURN VARCHAR2 IS
    catfmts     VARCHAR2(200);

  BEGIN
    for i in 1..segfmts.nsegs loop
     catfmts := catfmts || segfmts.vs_format(i);
     catfmts := catfmts || to_char(segfmts.vs_maxsize(i), 'S099') || ' ';
    end loop;
    return(catfmts);
  END concatenate_segment_formats;

/* ----------------------------------------------------------------------- */
/*      Returns derived values requested as a concatenated string.         */
/*      Can request SUMMARY_FLAG, START_DATE_ACTIVE and END_DATE_ACTIVE,   */
/*      but not ENABLED_FLAG.                                              */
/*                                                                         */
/*      Any qualifiers not found in the list of derived qualifiers         */
/*      will result in a NULL being returned in the appropriate place.     */
/*      Return string has qualifier values separated by TERMINATOR.        */
/* ----------------------------------------------------------------------- */

  FUNCTION ret_derived(d_quals  IN  FND_FLEX_SERVER1.Qualifiers,
                       drv      IN  FND_FLEX_SERVER1.DerivedVals,
                       d_rqst   IN  DerivedRqst) RETURN VARCHAR2 IS

    str         VARCHAR2(2000);

  BEGIN

    str := NULL;
    for i in 1..d_rqst.nrqstd loop
      if(d_rqst.sq_names(i) = 'SUMMARY_FLAG') then
        str := str || drv.summary_flag;
      elsif(d_rqst.sq_names(i) = 'START_DATE_ACTIVE') then
        str := str || to_char(drv.start_valid, DRV_DATE_FMT);
      elsif(d_rqst.sq_names(i) = 'END_DATE_ACTIVE') then
        str := str || to_char(drv.end_valid, DRV_DATE_FMT);
      else
        for j in 1..d_quals.nquals loop
          if(d_quals.sq_names(j) = d_rqst.sq_names(i)) then
            str := str || d_quals.sq_values(j);
            exit;
          end if;
        end loop;
      end if;
      str := str || FND_FLEX_SERVER1.TERMINATOR;
    end loop;
    if(str is not null) then
      str := SUBSTR(str, 1, LENGTH(str) - LENGTH(FND_FLEX_SERVER1.TERMINATOR));
    end if;
    return(str);

  END ret_derived;

/* ----------------------------------------------------------------------- */
/*      Returns value attributes  requested as a concatenated string.      */
/*      Implemented the same as ret_derived() except checks flexfield      */
/*      qualifier names too.                                               */
/*      Can request SUMMARY_FLAG, START_DATE_ACTIVE and END_DATE_ACTIVE,   */
/*      but not ENABLED_FLAG.                                              */
/*                                                                         */
/*      Any qualifiers not found in the list of derived qualifiers         */
/*      will result in a NULL being returned in the appropriate place.     */
/*      Return string has qualifier values separated by TERMINATOR.        */
/* ----------------------------------------------------------------------- */
  FUNCTION ret_valatts(d_quals  IN  FND_FLEX_SERVER1.Qualifiers,
                       drv      IN  FND_FLEX_SERVER1.DerivedVals,
                       v_rqst   IN  ValattRqst) RETURN VARCHAR2 IS

    str         VARCHAR2(2000);

  BEGIN

    str := NULL;
    for i in 1..v_rqst.nrqstd loop
      if(v_rqst.fq_names(i) is null) then
        if(v_rqst.sq_names(i) = 'SUMMARY_FLAG') then
          str := str || drv.summary_flag;
        elsif(v_rqst.sq_names(i) = 'START_DATE_ACTIVE') then
          str := str || to_char(drv.start_valid, DRV_DATE_FMT);
        elsif(v_rqst.sq_names(i) = 'END_DATE_ACTIVE') then
          str := str || to_char(drv.end_valid, DRV_DATE_FMT);
        end if;
      else
        for j in 1..d_quals.nquals loop
          if((d_quals.sq_names(j) = v_rqst.sq_names(i)) and
             (d_quals.fq_names(j) = v_rqst.fq_names(i))) then
            str := str || d_quals.sq_values(j);
            exit;
          end if;
        end loop;
      end if;
      str := str || FND_FLEX_SERVER1.TERMINATOR;
    end loop;
    if(str is not null) then
      str := SUBSTR(str, 1, LENGTH(str) - LENGTH(FND_FLEX_SERVER1.TERMINATOR));
    end if;
    return(str);

  END ret_valatts;

/* ----------------------------------------------------------------------- */
/*      Parses string which requests value attribue values.                */
/*      Input string of the form:                                          */
/*      'flexfield qualifier1\nsegment qualifier1\0flexfield qualifier2...'*/
/*      Requested segment qualifier names converted to upper case.         */
/*      Returns number of non-null value attributes requested or < 0 if err*/
/* ----------------------------------------------------------------------- */
  FUNCTION parse_va_rqst(s IN VARCHAR2, var OUT nocopy ValattRqst) RETURN NUMBER IS

    nsegs       NUMBER;
    fqname_end  NUMBER;
    fqsq_names  FND_FLEX_SERVER1.StringArray;
    sq_name     VARCHAR2(30);

  BEGIN

--  Make sure it is not too big
--
    if(LENGTHB(s) > MAX_ARG_LEN) then
      FND_MESSAGE.set_name('FND', 'FLEX-ARGUMENT TOO LONG');
      FND_MESSAGE.set_token('ARG', 'VALATT');
      FND_MESSAGE.set_token('MAXLEN', to_char(MAX_ARG_LEN));
      return(-6);
    end if;

    IF (s IS NOT NULL) THEN
       nsegs := FND_FLEX_SERVER1.to_stringarray2(s, FND_FLEX_SERVER1.TERMINATOR,
                                                 fqsq_names);
     ELSE
       nsegs := 0;
    END IF;

    for i in 1..nsegs loop
      if(fqsq_names(i) is not null) then
        fqname_end := INSTR(fqsq_names(i), FND_FLEX_SERVER1.SEPARATOR);
        if(fqname_end <= 0) then
          FND_MESSAGE.set_name('FND', 'FLEX-TOKEN VALATT NOSEP');
          FND_MESSAGE.set_token('SEP', FND_FLEX_SERVER1.SEPARATOR);
          FND_MESSAGE.set_token('NAME', fqsq_names(i));
          return(-1);
        elsif(fqname_end > 31) then
          FND_MESSAGE.set_name('FND', 'FLEX-QUALIFIER TOO LONG');
          FND_MESSAGE.set_token('TOKNAME', 'VALATT');
          FND_MESSAGE.set_token('NAME', SUBSTR(fqsq_names(i), 1, 30));
          return(-2);
        else
          var.fq_names(i) := UPPER(SUBSTR(fqsq_names(i), 1, fqname_end - 1));
          sq_name := UPPER(SUBSTR(fqsq_names(i),
                         fqname_end + LENGTH(FND_FLEX_SERVER1.SEPARATOR), 30));
          if(sq_name is null) then
            FND_MESSAGE.set_name('FND', 'FLEX-MISSING SQNAME');
            FND_MESSAGE.set_token('TOKNAME', 'VALATT');
            return(-3);
          end if;
          var.sq_names(i) := sq_name;
        end if;
      else
        FND_MESSAGE.set_name('FND', 'FLEX-MISSING SQNAME');
        FND_MESSAGE.set_token('TOKNAME', 'VALATT');
        return(-4);
      end if;
    end loop;
    var.nrqstd := nsegs;
    return(nsegs);

    EXCEPTION
      WHEN OTHERS then
        FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
        FND_MESSAGE.set_token('MSG', 'parse_va_rqst() exception: ' || SQLERRM);
        return(-5);

  END parse_va_rqst;

/* ----------------------------------------------------------------------- */
/*      Parses string which requests derived segment qualifier values.     */
/*      Input string of the form:  'seg qual name1\0seg qual name2...'     */
/*      Requested segment qualifier names converted to upper case.         */
/*      Returns number of non-null qualifier names requested or < 0 if err */
/* ----------------------------------------------------------------------- */
  FUNCTION parse_drv_rqst(s IN VARCHAR2, dr OUT nocopy DerivedRqst) RETURN NUMBER IS

    nsegs       NUMBER;
    sqnames     FND_FLEX_SERVER1.StringArray;

  BEGIN

--  Make sure it is not too big
--
    if(LENGTHB(s) > MAX_ARG_LEN) then
      FND_MESSAGE.set_name('FND', 'FLEX-ARGUMENT TOO LONG');
      FND_MESSAGE.set_token('ARG', 'DERIVED');
      FND_MESSAGE.set_token('MAXLEN', to_char(MAX_ARG_LEN));
      return(-6);
    end if;

    IF (s IS NOT NULL) THEN
       nsegs := FND_FLEX_SERVER1.to_stringarray2(s, FND_FLEX_SERVER1.TERMINATOR,
                                                 sqnames);
     ELSE
       nsegs := 0;
    END IF;

    for i in 1..nsegs loop
      if(sqnames(i) is not null) then
        dr.sq_names(i) := UPPER(SUBSTR(sqnames(i), 1, 30));
      else
        FND_MESSAGE.set_name('FND', 'FLEX-MISSING SQNAME');
        FND_MESSAGE.set_token('TOKNAME', 'DERIVED');
        return(-1);
      end if;
    end loop;
    dr.nrqstd := nsegs;
    return(nsegs);

    EXCEPTION
      WHEN OTHERS then
        FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
        FND_MESSAGE.set_token('MSG', 'parse_drv_rqst() exception: '||SQLERRM);
        return(-2);

  END parse_drv_rqst;

/* ----------------------------------------------------------------------- */
/*      Parses vrule string.  Returns number of vrules found or sets error */
/*      message string and returns < 0 if error.                           */
/*                                                                         */
/*      Vrule string format:                                               */
/*      'FLEXFIELD QUALIFIER NAME\nSEGMENT QUALIFIER NAME\n                */
/*       {I[nclude] | E[xclude]}\nAPPL=appl short name;NAME=Message name\n */
/*       value1\nvalue2...\0'                                              */
/*                                                                         */
/*      SEPARATOR = '\n', TERMINATOR = '\0'.                               */
/*                                                                         */
/*      Multiple vrules can be separated by TERMINATOR.  TERMINATOR is not */
/*      required after last vrule.  If 'NAME=' is missing the entire       */
/*      message string is considered the error message.  If 'APPL=' or     */
/*      the ';' is missing the application short name 'FND' is used.       */
/*                                                                         */
/*      Eliminates whitespace from around component names.                 */
/*      Limits vrule string length to < MAX_VRULE_LEN bytes.               */
/* ----------------------------------------------------------------------- */
  FUNCTION parse_vrules(s IN VARCHAR2,
                        vr OUT nocopy FND_FLEX_SERVER1.Vrules) RETURN NUMBER IS

    n                   NUMBER;
    bgn                 NUMBER;
    endp                NUMBER;
    seplen              NUMBER;
    vrulstr_len         NUMBER;
    msg_begin           NUMBER;
    msg_end             NUMBER;
    tokn_len            NUMBER;
    endtok              NUMBER;
    ieval               VARCHAR2(240);
    tokn                VARCHAR2(2000);
    sq_name             VARCHAR2(30);
    ie_flag             VARCHAR2(4);

  BEGIN

    n := 0;
    bgn := 1;
    if(s is null) then
      vr.nvrules := 0;
      return(0);
    end if;

    vrulstr_len := LENGTH(s);
    seplen := LENGTH(FND_FLEX_SERVER1.SEPARATOR);

    while (bgn <= vrulstr_len) loop
      n := n + 1;

--  Flexfield qualifier name
--
      endp := INSTR(s, FND_FLEX_SERVER1.SEPARATOR, bgn);
      if(endp <= 0) then
        FND_MESSAGE.set_name('FND', 'FLEX-TOKEN VRULE NOSEP');
        FND_MESSAGE.set_token('TOKNUM', to_char(n));
        FND_MESSAGE.set_token('SEP', FND_FLEX_SERVER1.SEPARATOR);
        return(-1);
      else
        tokn := UPPER(LTRIM(RTRIM(SUBSTR(s, bgn, endp-bgn), BLANKS), BLANKS));
        if((tokn is not null) and (LENGTHB(tokn) > 30)) then
          FND_MESSAGE.set_name('FND', 'FLEX-QUALIFIER TOO LONG');
          FND_MESSAGE.set_token('TOKNAME', 'VRULE');
          FND_MESSAGE.set_token('NAME', SUBSTR(s, bgn, 30));
          return(-1);
        end if;
        vr.fq_names(n) := tokn;
        bgn := endp + seplen;
      end if;

--  Segment qualifier name
--
      endp := INSTR(s, FND_FLEX_SERVER1.SEPARATOR, bgn);
      if(endp <= 0) then
        FND_MESSAGE.set_name('FND', 'FLEX-TOKEN VRULE NOSEP');
        FND_MESSAGE.set_token('TOKNUM', to_char(n));
        FND_MESSAGE.set_token('SEP', FND_FLEX_SERVER1.SEPARATOR);
        return(-1);
      else
        tokn := UPPER(LTRIM(RTRIM(SUBSTR(s, bgn, endp-bgn), BLANKS), BLANKS));
        if(tokn is null) then
          FND_MESSAGE.set_name('FND', 'FLEX-MISSING SQNAME');
          FND_MESSAGE.set_token('TOKNAME', 'VRULE');
          return(-1);
        elsif(LENGTHB(tokn) > 30) then
          FND_MESSAGE.set_name('FND', 'FLEX-QUALIFIER TOO LONG');
          FND_MESSAGE.set_token('TOKNAME', 'VRULE');
          FND_MESSAGE.set_token('NAME', SUBSTR(s, bgn, 30));
          return(-1);
        else
          sq_name := tokn;
          vr.sq_names(n) := tokn;
        end if;
        bgn := endp + seplen;
      end if;

--  Include/Exclude indicator
--
      endp := INSTR(s, FND_FLEX_SERVER1.SEPARATOR, bgn);
      if(endp <= 0) then
        FND_MESSAGE.set_name('FND', 'FLEX-TOKEN VRULE NOSEP');
        FND_MESSAGE.set_token('TOKNUM', to_char(n));
        FND_MESSAGE.set_token('SEP', FND_FLEX_SERVER1.SEPARATOR);
        return(-1);
      end if;
      tokn := LTRIM(RTRIM(SUBSTR(s, bgn, endp-bgn), BLANKS), BLANKS);
      if(tokn is null) then
        FND_MESSAGE.set_name('FND', 'FLEX-TOKEN VRULE NO IE');
        FND_MESSAGE.set_token('NAME', sq_name);
        return(-1);
      end if;
      ie_flag := SUBSTR(tokn, 1, 1);
      vr.ie_flags(n) := ie_flag;
      if(ie_flag not in ('I', 'E')) then
        FND_MESSAGE.set_name('FND', 'FLEX-TOKEN VRULE BAD IE');
        FND_MESSAGE.set_token('NAME', sq_name);
        return(-1);
      end if;
      bgn := endp + seplen;

--  Error Message and Application short name
--
      endp := INSTR(s, FND_FLEX_SERVER1.SEPARATOR, bgn);
      if(endp <= 0) then
        FND_MESSAGE.set_name('FND', 'FLEX-TOKEN VRULE NOSEP');
        FND_MESSAGE.set_token('TOKNUM', to_char(n));
        FND_MESSAGE.set_token('SEP', FND_FLEX_SERVER1.SEPARATOR);
        return(-1);
      end if;
      tokn := LTRIM(RTRIM(SUBSTR(s, bgn, endp-bgn), BLANKS), BLANKS);
      if(tokn is null) then
        FND_MESSAGE.set_name('FND', 'FLEX-TOKEN VRULE NO MSG');
        FND_MESSAGE.set_token('NAME', sq_name);
        return(-1);
      elsif(LENGTHB(tokn) > 100) then
        FND_MESSAGE.set_name('FND', 'FLEX-TOKEN VRULE BIG MSG');
        FND_MESSAGE.set_token('NAME', sq_name);
        return(-1);
      else
        msg_begin := INSTR(tokn, 'NAME=');
        if(msg_begin <= 0) then
          vr.app_names(n) := NULL;
          vr.err_names(n) := tokn;
        else
          msg_begin := msg_begin + 5;
          if(LENGTH(tokn) < msg_begin) then
            FND_MESSAGE.set_name('FND', 'FLEX-TOKEN VRULE NO MSGNAME');
            FND_MESSAGE.set_token('NAME', sq_name);
            return(-1);
          end if;
          vr.err_names(n) := SUBSTR(tokn, msg_begin);
          msg_begin := INSTR(tokn, 'APPL=');
          msg_end := INSTR(tokn, ';');
          if((msg_begin > 0) and (msg_end > 0) and
             (msg_end - msg_begin > 5)) then
            msg_begin := msg_begin + 5;
            if(msg_end - msg_begin > 50) then
              FND_MESSAGE.set_name('FND', 'FLEX-TOKEN VRULE BIG APNAME');
              FND_MESSAGE.set_token('NAME', sq_name);
              return(-1);
            end if;
            vr.app_names(n) := SUBSTR(tokn, msg_begin, msg_end - msg_begin);
          else
            vr.app_names(n) := 'FND';
          end if;
        end if;
      bgn := endp + seplen;
      end if;

--  Values to include or exclude.
--  Parsed into format where each value is surrounded by the SEPARATOR.
--  First put everything to the terminator into tokn, then parse tokn.
--
      endp := INSTR(s, FND_FLEX_SERVER1.TERMINATOR, bgn);
      if(endp <= 0) then
        endp := vrulstr_len + 1;
      end if;
      tokn := LTRIM(RTRIM(SUBSTR(s, bgn, endp-bgn), BLANKS), BLANKS);
      if(tokn is null) then
        FND_MESSAGE.set_name('FND', 'FLEX-TOKEN VRULE NO VALS');
        FND_MESSAGE.set_token('NAME', sq_name);
        return(-1);
      end if;
      if(LENGTHB(tokn) > 236) then
        FND_MESSAGE.set_name('FND', 'FLEX-TOKEN VRULE BIG VALSTR');
        FND_MESSAGE.set_token('NAME', sq_name);
        return(-1);
      end if;
      bgn := 1;
      ieval := FND_FLEX_SERVER1.SEPARATOR;
      tokn_len := LENGTH(tokn);
      while(bgn <= tokn_len) loop
        endtok := INSTR(tokn, FND_FLEX_SERVER1.SEPARATOR, bgn);
        if(endtok <= 0) then
          endtok := tokn_len + 1;
        end if;
        ieval := ieval || LTRIM(RTRIM(SUBSTR(tokn, bgn, endtok-bgn),
                                                        BLANKS), BLANKS);
        ieval := ieval || FND_FLEX_SERVER1.SEPARATOR;
        bgn := endtok + seplen;
      end loop;
      vr.cat_vals(n) := ieval;
      bgn := endp + seplen;

    end loop;

    vr.nvrules := n;

    return(n);

    EXCEPTION
      WHEN OTHERS then
        FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
        FND_MESSAGE.set_token('MSG', 'parse_vrules() exception: ' || SQLERRM);
        return(-2);

  END parse_vrules;


  /*
   * Parse and set the custom error message.
   * Synatx is 'APPL=<application_short_name>;NAME=<message_name>'
   */
  FUNCTION parse_set_msg(p_msg IN VARCHAR2) RETURN BOOLEAN
    IS
       l_appl VARCHAR2(2000);
       l_name VARCHAR2(2000);
       l_msg  VARCHAR2(2000);
       l_pos_beg NUMBER;
       l_pos_end NUMBER;
  BEGIN
     l_msg := p_msg;
     IF (l_msg IS NULL) THEN
        RETURN FALSE;
     END IF;

     l_pos_beg := Instr(l_msg, 'APPL=');
     IF (l_pos_beg = 0) THEN
        --
        -- No APPL token.
        --
        RETURN FALSE;
     END IF;
     l_pos_beg := l_pos_beg + Length('APPL=');

     l_pos_end := Instr(l_msg, ';NAME=');
     IF (l_pos_end = 0) THEN
        --
        -- No NAME token.
        --
        RETURN FALSE;
     END IF;

     IF (l_pos_end = l_pos_beg) THEN
        --
        -- No APPL value.
        --
        RETURN FALSE;
     END IF;

     --
     -- Application Short Name
     --
     l_appl := Substr(l_msg, l_pos_beg, l_pos_end - l_pos_beg);

     l_pos_beg := l_pos_end + Length(';NAME=');
     l_pos_end := Length(l_msg) + 1;

     IF (l_pos_end = l_pos_beg) THEN
        --
        -- No NAME value.
        --
        RETURN FALSE;
     END IF;

     --
     -- Message Name.
     --
     l_name := Substr(l_msg, l_pos_beg, l_pos_end - l_pos_beg);

     fnd_message.set_name(l_appl, l_name);

     RETURN TRUE;
  EXCEPTION
     WHEN OTHERS THEN
        RETURN FALSE;
  END parse_set_msg;




/* ----------------------------------------------------------------------- */
/*      Function to interpret DISPLAYED token using the approach of        */
/*      selecting all segments and their associated flexfield qualifiers   */
/*      in a single outer join and then interpreting the tokens for all    */
/*      segments at once.  This requires the fewest possible database rows */
/*      retrieved and only a single select statement.                      */
/* ----------------------------------------------------------------------- */

  FUNCTION parse_displayed(fstruct    IN  FND_FLEX_SERVER1.FlexStructId,
                           token_str  IN  VARCHAR2,
                           dispsegs   OUT nocopy FND_FLEX_SERVER1.DisplayedSegs)
                                                        RETURN BOOLEAN IS

    n_segs      NUMBER;
    fq_table    FND_FLEX_SERVER1.FlexQualTable;
    seg_disp    FND_FLEX_SERVER1.CharArray;
    seg_rqd     FND_FLEX_SERVER1.CharArray;
    tokenmap    FND_FLEX_SERVER1.BooleanArray;

  BEGIN

--  Initialize returned segment display map.
--
    dispsegs.n_segflags := 0;

-- Get flexfield qualifier mapping to segments.
--
    if(FND_FLEX_SERVER2.get_qualsegs(fstruct, n_segs, seg_disp,
                                     seg_rqd, fq_table) = FALSE) then
      return(FALSE);
    end if;


    if(evaluate_token(token_str, n_segs, fq_table, tokenmap) = FALSE) then
      return(FALSE);
    end if;

--  Still need to merge the displayed map obtained from the DISPLAYED token
--  alone (n_tokappl) with the display map from the flex structure and
--  return the completed map.
--
    IF (fnd_flex_server1.g_debug_level > 0) THEN
       g_debug_text := 'Displayed Map=';
    END IF;
    for i in 1..n_segs loop
      if((seg_disp(i) = 'Y') and tokenmap(i)) then
        dispsegs.segflags(i) := TRUE;
        IF (fnd_flex_server1.g_debug_level > 0) THEN
           g_debug_text := g_debug_text || 'Y';
        END IF;
      else
        dispsegs.segflags(i) := FALSE;
        IF (fnd_flex_server1.g_debug_level > 0) THEN
           g_debug_text := g_debug_text || 'N';
        END IF;
      end if;
    end loop;
    IF (fnd_flex_server1.g_debug_level > 0) THEN
       FND_FLEX_SERVER1.add_debug(g_debug_text || '.');
    END IF;
    dispsegs.n_segflags := n_segs;
    return(TRUE);

    EXCEPTION
      WHEN OTHERS then
        FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
        FND_MESSAGE.set_token('MSG', 'parse_displayed() exception: '||SQLERRM);
        return(FALSE);

  END parse_displayed;

/* ------------------------------------------------------------------------- */
/*      Interpret the string token passed into FND_KEY_FLEX.DEFINE() call    */
/*      on the client using the table of flexfield qualifiers for each       */
/*      segment which is returned from get_segquals().                       */
/*      Returns an array which has one element for each enabled segment      */
/*      where the entry in the array is TRUE if and only if an odd number    */
/*      of token elements apply to the segment.                              */
/*      Returns TRUE on success or FALSE on error.                           */
/* ------------------------------------------------------------------------- */

  FUNCTION evaluate_token(token_str  IN  VARCHAR2,
                          n_segs     IN  NUMBER,
                          fq_tab     IN  FND_FLEX_SERVER1.FlexQualTable,
                          token_map  OUT nocopy FND_FLEX_SERVER1.BooleanArray)
                                                           RETURN BOOLEAN IS

    n_toks      NUMBER;
    segindex    NUMBER;
    toks        FND_FLEX_SERVER1.StringArray;
    s_ntokappl  FND_FLEX_SERVER1.NumberArray;

  BEGIN

     --  Break up token into individual components
     --
     IF (token_str IS NOT NULL) THEN
        n_toks := FND_FLEX_SERVER1.to_stringarray2(token_str,
                                                   FND_FLEX_SERVER1.TERMINATOR, toks);
      ELSE
        n_toks := 0;
     END IF;

--  Save some debug info
--
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        g_debug_text := 'Tokens:';
        for i in 1..n_toks loop
           g_debug_text := g_debug_text || toks(i) || ' ';
        end loop;
        FND_FLEX_SERVER1.add_debug(g_debug_text);
     END IF;

--  Initialize number of applicable tokens for each segment to 0.
--
    for i in 1..n_segs loop
      s_ntokappl(i) := 0;
    end loop;

    IF (fnd_flex_server1.g_debug_level > 0) THEN
       FND_FLEX_SERVER1.add_debug('Init ' || to_char(n_segs) || ' segs. ');
    END IF;

--  Now interpret each token to create the displayed map.
--  If token is 'ALL' then just toggle the displayed bit for all segments.
--  If token is a number then toggle the displayed bit for that seg number.
--  Otherwise, toggle the displayed bits for all segments for which that
--  qualifier applies.  Exit if any errors.
--
    for i in 1..n_toks loop
      if(toks(i) is null) then
        FND_MESSAGE.set_name('FND', 'FLEX-TOKEN DUI NULL');
        return(FALSE);
      end if;
      if(toks(i) = 'ALL') then
        for j in 1..n_segs loop
          s_ntokappl(j) := s_ntokappl(j) + 1;
        end loop;
      elsif(FND_FLEX_SERVER1.isa_number(toks(i), segindex)) then
        if((segindex < 1) or (segindex > n_segs)) then
          FND_MESSAGE.set_name('FND', 'FLEX-TOKEN DUI BAD SEGNUM');
          FND_MESSAGE.set_token('SEGNUM', to_char(segindex));
          return(FALSE);
        end if;
        s_ntokappl(segindex) := s_ntokappl(segindex) + 1;
      else
        segindex := 0;
        for k in 1..fq_tab.nentries loop
          if((fq_tab.fq_names(k) is not null) and
             (toks(i) = fq_tab.fq_names(k))) then
            segindex := fq_tab.seg_indexes(k);
            s_ntokappl(segindex) := s_ntokappl(segindex) + 1;
          end if;
        end loop;
        if(segindex = 0) then
          FND_MESSAGE.set_name('FND', 'FLEX-TOKEN DUI BAD QUAL');
          FND_MESSAGE.set_token('QTOKEN', toks(i));
          return(FALSE);
        end if;
      end if;
    end loop;

    for i in 1..n_segs loop
      token_map(i) := (MOD(s_ntokappl(i), 2) = 1);
    end loop;
    return(TRUE);

    EXCEPTION
      WHEN OTHERS then
        FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
        FND_MESSAGE.set_token('MSG', 'evaluate_token() exception: ' ||SQLERRM);
        return(FALSE);

  END evaluate_token;

/* ------------------------------------------------------------------------- */
/*      Turns on or off calling of user PLSQL validation just before insert  */
/*      of new combination.                                                  */
/* ------------------------------------------------------------------------- */
  PROCEDURE enable_user_validation(Y_or_N  IN  VARCHAR2) IS
  BEGIN
    if(Y_or_N = 'Y') then
      userval_on := TRUE;
    else
      userval_on := FALSE;
    end if;
  END enable_user_validation;

/* ------------------------------------------------------------------------- */
/*      Turns on or off fdfgli calling after insert of new combination     */
/*      in accounting flexfield.                                           */
/* ----------------------------------------------------------------------- */
  PROCEDURE enable_fdfgli(Y_or_N  IN  VARCHAR2) IS
  BEGIN
    if(Y_or_N = 'Y') then
      fdfgli_on := TRUE;
    else
      fdfgli_on := FALSE;
    end if;
  END enable_fdfgli;

/* ----------------------------------------------------------------------- */
/*                      Calls FDFGLI if enabled.                           */
/*      Processes error messages returned by FDFGLI and handles any        */
/*      possible exceptions.  Returns TRUE on success or sets error        */
/*      and returns FALSE on error.                                        */
/*                                                                         */
/*      Note:  FDFGLI called using dynamic SQL so no error at compile time */
/*      if GL_FLEX_INSERT_PKG is not there.                                */
/* ----------------------------------------------------------------------- */
  FUNCTION call_fdfgli(ccid IN NUMBER) RETURN BOOLEAN IS

    cursornum   INTEGER;
    nprocessed  INTEGER;
    sqlstr      VARCHAR2(500);
    yes_or_no   VARCHAR2(1);
    i_status    VARCHAR2(1);
    i_industry  VARCHAR2(1);

  BEGIN

     IF (fnd_flex_server1.g_debug_level > 0) THEN
        FND_FLEX_SERVER1.add_debug('Entering call_fdfgli() ');
     END IF;

    if(fdfgli_on) then

-- Do not call FDFGLI just exit with TRUE if GL is not fully installed
--
      if(FND_INSTALLATION.get(101, 101, i_status, i_industry) = FALSE) then
        FND_MESSAGE.set_name('FND', 'FLEX-CANT_GET_INSTALL');
        return(FALSE);
      end if;
      if((i_status is null) or (i_status <> 'I')) then
        return(TRUE);
      end if;

      sqlstr := 'BEGIN if(gl_flex_insert_pkg.fdfgli(:n)) then :r := ''Y'';';
      sqlstr := sqlstr || ' else :r := ''N''; end if; END;';
      IF (fnd_flex_server1.g_debug_level > 0) THEN
         FND_FLEX_SERVER1.add_debug(sqlstr);
      END IF;
      cursornum := dbms_sql.open_cursor;
      dbms_sql.parse(cursornum, sqlstr, dbms_sql.v7);
      dbms_sql.bind_variable(cursornum, ':n', ccid);
      dbms_sql.bind_variable(cursornum, ':r', yes_or_no, 1);
      nprocessed := dbms_sql.execute(cursornum);
      dbms_sql.variable_value(cursornum, ':r', yes_or_no);
      IF (fnd_flex_server1.g_debug_level > 0) THEN
         FND_FLEX_SERVER1.add_debug('Dynamic SQL called FDFGLI and returned '||
                                    yes_or_no || '. ');
      END IF;
      dbms_sql.close_cursor(cursornum);
      return(yes_or_no = 'Y');
    end if;

    return(TRUE);

    EXCEPTION
      WHEN OTHERS then
        -- bug#4072642 -- maximum open cursors exceeded
        if dbms_sql.is_open(cursornum) then
          dbms_sql.close_cursor(cursornum);
        end if;
        if((SQLCODE = -6550) and (INSTR(SQLERRM, 'PLS-00201') > 0)) then
          FND_MESSAGE.set_name('FND', 'FLEX-FDFGLI MISSING');
          FND_MESSAGE.set_token('MSG', SQLERRM);
        else
          FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
          FND_MESSAGE.set_token('MSG', 'fdfgli() exception: '||SQLERRM);
        end if;
        return(FALSE);

  END call_fdfgli;

/* ----------------------------------------------------------------------- */
/*      Calls user PLSQL validation function FND_FLEX_PLSQL.validate().    */
/*      Requires FND_FLEX_PLSQL stub package for compilation.              */
/*      The validate() function is called with both concatenated and       */
/*      individual segment ids in order they are defined in the flexfield  */
/*      structure.  It will return TRUE if combination passes all user     */
/*      defined validation rules, or FALSE on error or if it does not      */
/*      pass user-defined validation.                                      */
/*      Saves args input to user validation in uvdbg string.       */
/* ----------------------------------------------------------------------- */
  FUNCTION call_userval(fstruct   IN  FND_FLEX_SERVER1.FlexStructId,
                        vdate     IN  DATE,
                        nids      IN  NUMBER,
                        delim     IN  VARCHAR2,
                        segids    IN  FND_FLEX_SERVER1.ValueIdArray)
                                                         RETURN BOOLEAN IS
    errmsg      VARCHAR2(2000);
    catids      VARCHAR2(5000);
    ids         FND_FLEX_SERVER1.ValueIdArray;

  BEGIN

--  Only do this for key flexfields
--
    if(not fstruct.isa_key_flexfield) then
      return(TRUE);
    end if;

--  First concatenate ids, and populate the ids() array with ids or NULL
--  while adding the input args to the debug string.
--
    catids := concatenate_ids(nids, segids, delim);
    for i in 1..30 loop
      if(i <= nids) then
        ids(i) := segids(i);
      else
        ids(i) := NULL;
      end if;
    end loop;

--  Next save the debugging info to the standard server debug string.
--  Note this is different from the client which will save it to a
--  file fdfplv.log.  Use errmsg as temporary string to store debug info.
--
    errmsg := ' Calling FND_FLEX_PLSQL.validate(';
    errmsg := errmsg || to_char(fstruct.application_id) || ', ';
    errmsg := errmsg || fstruct.id_flex_code || ', ';
    errmsg := errmsg || to_char(fstruct.id_flex_num) || ', ';
    errmsg := errmsg || to_char(vdate, FND_FLEX_SERVER1.DATETIME_FMT) || ', ';
    errmsg := errmsg || delim || ', ';

    IF (fnd_flex_server1.g_debug_level > 0) THEN
       FND_FLEX_SERVER1.add_debug(errmsg);
       FND_FLEX_SERVER1.add_debug(catids);
       FND_FLEX_SERVER1.add_debug(') ');
    END IF;
    errmsg := NULL;

--  Now call the function
--
    if(FND_FLEX_PLSQL.validate(fstruct.application_id, fstruct.id_flex_code,
        fstruct.id_flex_num, vdate, delim, catids, nids, ids(1), ids(2),
        ids(3), ids(4), ids(5), ids(6), ids(7), ids(8), ids(9),
        ids(10), ids(11), ids(12), ids(13), ids(14), ids(15), ids(16),
        ids(17), ids(18), ids(19), ids(20), ids(21), ids(22), ids(23),
        ids(24), ids(25), ids(26), ids(27), ids(28), ids(29), ids(30),
        errmsg) = FALSE) then
      FND_MESSAGE.set_name('FND', 'FLEX-PLSQL VALIDATION ERROR');
      FND_MESSAGE.set_token('ERROR_MSG', errmsg);
      return(FALSE);
    end if;
    return(TRUE);

    EXCEPTION
      WHEN OTHERS then
        FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
        FND_MESSAGE.set_token('MSG', 'call_userval() exception: '||SQLERRM);
        return(FALSE);

  END call_userval;

/* ----------------------------------------------------------------------- */
/*      Returns number of SQL statements created during last call          */
/*      to validate().  Use in conjunction with get_sql().                 */
/* ----------------------------------------------------------------------- */
  FUNCTION get_nsql RETURN NUMBER IS
  BEGIN
    return(FND_FLEX_SERVER1.get_nsql_internal);
  END get_nsql;

/* ----------------------------------------------------------------------- */
/*      Returns SQL statements created during last call                    */
/*      to validate().  Use in conjunction with get_sql().                 */
/* ----------------------------------------------------------------------- */
  FUNCTION get_sql(statement_num   IN NUMBER,
                   statement_piece IN NUMBER DEFAULT 1) RETURN VARCHAR2 IS
  BEGIN
    return(FND_FLEX_SERVER1.get_sql_internal(statement_num, statement_piece));
  EXCEPTION
    WHEN OTHERS then
        return('get_sql() exception: ' || SQLERRM);
  END get_sql;

/* ----------------------------------------------------------------------- */
/*      Returns the debug string.                                          */
/* ----------------------------------------------------------------------- */
  FUNCTION get_debug(stringnum IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    return(FND_FLEX_SERVER1.get_debug_internal(stringnum));
  EXCEPTION
    WHEN OTHERS then
      return('get_debug() exception: ' || SQLERRM);
  END get_debug;

/* ----------------------------------------------------------------------- */



-- ==================================================
-- This procedure is deperecated and is only used for
-- backward compatability. Can be deleted in the future.
-- ==================================================
PROCEDURE do_dynamic_insert_for_java(p_application_id         IN NUMBER,
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
                                     x_encoded_error          OUT nocopy VARCHAR2)
  IS
     l_is_new   VARCHAR2(100);
BEGIN
   do_dynamic_insert_at
     (p_application_id         => p_application_id,
      p_id_flex_code           => p_id_flex_code,
      p_id_flex_num            => p_id_flex_num,
      p_application_table_name => p_application_table_name,
      p_segment_delimiter      => p_segment_delimiter,
      p_segment_count          => p_segment_count,
      p_validation_date        => p_validation_date,
      p_start_date_active      => p_start_date_active,
      p_end_date_active        => p_end_date_active,
      p_insert_sql             => p_insert_sql,
      p_insert_sql_binds       => p_insert_sql_binds,
      p_select_sql             => p_select_sql,
      p_select_sql_binds       => p_select_sql_binds,
      x_ccid                   => x_ccid,
      x_is_new                 => l_is_new,
      x_encoded_error          => x_encoded_error);
END do_dynamic_insert_for_java;
-- ==================================================




-- ==================================================
-- Bug 20057989
-- Called from Flex Java Validation Engine. Based on p_insert_only, it
-- uses autonomous or non-autonomous transaction to insert new combination.
-- TRUE uses autonomous transaction and commits the combination
-- FALSE uses non-autonomous transaction and doesn't commit. The calling
-- transaction has use save-points and do COMMIT or ROLLBACK
-- ==================================================
PROCEDURE do_dynamic_insert_for_java(p_application_id         IN NUMBER,
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
                                     x_encoded_error          OUT nocopy VARCHAR2)
  IS
     l_is_new   VARCHAR2(100);
BEGIN
    IF (p_insert_only = 1)
    THEN
       do_dynamic_insert_no_at
         (p_application_id         => p_application_id,
          p_id_flex_code           => p_id_flex_code,
          p_id_flex_num            => p_id_flex_num,
          p_application_table_name => p_application_table_name,
          p_segment_delimiter      => p_segment_delimiter,
          p_segment_count          => p_segment_count,
          p_validation_date        => p_validation_date,
          p_start_date_active      => p_start_date_active,
          p_end_date_active        => p_end_date_active,
          p_insert_sql             => p_insert_sql,
          p_insert_sql_binds       => p_insert_sql_binds,
          p_select_sql             => p_select_sql,
          p_select_sql_binds       => p_select_sql_binds,
          x_ccid                   => x_ccid,
          x_is_new                 => l_is_new,
          x_encoded_error          => x_encoded_error);
    ELSE
       do_dynamic_insert_at
         (p_application_id         => p_application_id,
          p_id_flex_code           => p_id_flex_code,
          p_id_flex_num            => p_id_flex_num,
          p_application_table_name => p_application_table_name,
          p_segment_delimiter      => p_segment_delimiter,
          p_segment_count          => p_segment_count,
          p_validation_date        => p_validation_date,
          p_start_date_active      => p_start_date_active,
          p_end_date_active        => p_end_date_active,
          p_insert_sql             => p_insert_sql,
          p_insert_sql_binds       => p_insert_sql_binds,
          p_select_sql             => p_select_sql,
          p_select_sql_binds       => p_select_sql_binds,
          x_ccid                   => x_ccid,
          x_is_new                 => l_is_new,
          x_encoded_error          => x_encoded_error);
	END IF;
END do_dynamic_insert_for_java;

-- ----------------------------------------------------------------------
-- Uses autonomous transaction and commits the combination
-- ----------------------------------------------------------------------
PROCEDURE do_dynamic_insert_at      (p_application_id         IN NUMBER,
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
                                     x_encoded_error          OUT nocopy VARCHAR2)
  IS
     PRAGMA AUTONOMOUS_TRANSACTION;

     l_func_name        VARCHAR2(100);
     l_ff_structure     FND_FLEX_SERVER1.flexstructid;
     l_bind_count       NUMBER;
     l_binds            fnd_flex_server1.valuearray;
     l_newline          VARCHAR2(10);
     l_ccid             NUMBER;
     l_cursor           NUMBER;
     l_hash_value       NUMBER;
     l_segment_ids      fnd_flex_server1.valueidarray;

     --
     -- Temporary number and varchar2 buffers.
     --
     l_num              NUMBER;
     l_vc2              VARCHAR2(32000);
     temp               VARCHAR2(32000);
BEGIN
   l_func_name := 'SSV.do_dynamic_insert_at()';
   l_newline := fnd_global.newline;
   x_is_new := 'U';
   --
   -- Lock the combination table.
   --
   BEGIN
      EXECUTE IMMEDIATE ('LOCK TABLE ' || p_application_table_name ||
                         ' IN ROW SHARE MODE');
   EXCEPTION
      WHEN OTHERS THEN
         fnd_message.set_name('FND', 'FLEX-USER DEFINED ERROR');
         fnd_message.set_token('MSG', l_func_name ||
                               ' is unable to lock table ' ||
                               p_application_table_name || '. ' || l_newline ||
                               'SQLERRM: ' || Sqlerrm);
         GOTO return_failure;
   END;

   --
   -- Get the concatenated combination.
   -- End of Insert SQL Binds is concatenated combination.
   -- Final result is something like '10\n20\nA\n'
   --
   -- First step gets concat comb with beginning newline character
   l_vc2 := Substr(p_insert_sql_binds,
                         Instr(p_insert_sql_binds,
                               l_newline, -1, p_segment_count + 1));
   -- Second/final step removes initial newline and puts concat comb in l_vc2
   temp := Substr(l_vc2, 2);
   l_vc2 := temp;

   --
   -- Parse the segment ids.
   --
   FOR i IN 1..p_segment_count LOOP
      l_num := Instr(l_vc2, l_newline, 1, 1);
      l_segment_ids(i) := Substr(l_vc2, 1, l_num - 1);
      l_vc2 := Substr(l_vc2, l_num + 1);
   END LOOP;

   --
   -- Generate a hash value.
   --
   l_hash_value := hash_segs(p_segment_count, l_segment_ids);

   --
   -- Lock the hash table.
   --
   BEGIN
      SELECT hash_value
        INTO l_num
        FROM fnd_flex_hash
        WHERE hash_value = l_hash_value
        FOR UPDATE;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_message.set_name('FND', 'FLEX-USER DEFINED ERROR');
         fnd_message.set_token('MSG', l_func_name ||
                               ' is unable to lock FND_FLEX_HASH. ' ||
                               'Hash Value: ' || l_hash_value || l_newline ||
                               'SQLERRM: ' || Sqlerrm);
         GOTO return_failure;
   END;

   --
   -- We locked Comb. Table and the Hash table, now let's check the
   -- Comb. Table one more time.
   --

   --
   -- See KeyFlexfield.getCCIDfromDynamicInsertion() for a sample SELECT SQL.
   --

   --
   -- Parse SELECT SQL bind values.
   --
   l_bind_count := 0;
   l_vc2 := p_select_sql_binds;
   WHILE (l_vc2 IS NOT NULL) LOOP
      l_bind_count := l_bind_count + 1;
      l_num := Instr(l_vc2, l_newline, 1, 1);
      l_binds(l_bind_count) := Substr(l_vc2, 1, l_num - 1);
      l_vc2 := Substr(l_vc2, l_num + 1);
   END LOOP;

   --
   -- Check if the combination is already in the table.
   --
   BEGIN
      l_cursor := dbms_sql.open_cursor;
      dbms_sql.parse(l_cursor, p_select_sql, dbms_sql.native);
      FOR i IN 1..l_bind_count LOOP
         dbms_sql.bind_variable(l_cursor, 'S' || i , l_binds(i));
      END LOOP;
      dbms_sql.define_column(l_cursor, 1, l_ccid);
      l_num := dbms_sql.execute_and_fetch(l_cursor, TRUE);

      --
      -- Combination already exists.
      --
      dbms_sql.column_value(l_cursor, 1, l_ccid);
      dbms_sql.close_cursor(l_cursor);
      x_is_new := 'N';
      GOTO return_success;
   EXCEPTION
      WHEN no_data_found THEN
         --
         -- Combination doesn't exist, continue to INSERT.
         --
         dbms_sql.close_cursor(l_cursor);
      WHEN OTHERS THEN
         dbms_sql.close_cursor(l_cursor);
         fnd_message.set_name('FND', 'FLEX-USER DEFINED ERROR');
         fnd_message.set_token('MSG', l_func_name ||
                               ' is unable to select from table ' ||
                               p_application_table_name || '. ' || l_newline ||
                               'SQLERRM: ' || Sqlerrm);
         GOTO return_failure;
   END;

   --
   --  Call user validation function.
   --
   IF (userval_on) THEN
      l_ff_structure.isa_key_flexfield := TRUE;
      l_ff_structure.application_id := p_application_id;
      l_ff_structure.id_flex_code := p_id_flex_code;
      l_ff_structure.id_flex_num := p_id_flex_num;

      IF (NOT call_userval(l_ff_structure,
                           p_validation_date,
                           p_segment_count,
                           p_segment_delimiter,
                           l_segment_ids)) THEN
         GOTO return_failure;
      END IF;
   END IF;


   --
   -- Now we are ready to insert.
   --

   --
   -- See KeyFlexfield.getCCIDfromDynamicInsertion() for a sample INSERT SQL.
   --

   --
   -- Parse INSERT SQL bind values.
   --
   l_bind_count := 0;
   l_vc2 := p_insert_sql_binds;
   WHILE (l_vc2 IS NOT NULL) LOOP
      l_bind_count := l_bind_count + 1;
      l_num := Instr(l_vc2, l_newline, 1, 1);
      l_binds(l_bind_count) := Substr(l_vc2, 1, l_num - 1);
      l_vc2 := Substr(l_vc2, l_num + 1);
   END LOOP;

   --
   -- Get the next CCID.
   --
   BEGIN
      EXECUTE IMMEDIATE ('SELECT ' || p_application_table_name ||
                         '_S.NEXTVAL FROM dual')
        INTO l_ccid;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_message.set_name('FND', 'FLEX-USER DEFINED ERROR');
         fnd_message.set_token('MSG', l_func_name ||
                               ' is unable to get next value from sequence ' ||
                               p_application_table_name || '_S. ' ||l_newline||
                               'SQLERRM: ' || Sqlerrm);
         GOTO return_failure;
   END;

   --
   -- INSERT the combination.
   --
   BEGIN
      l_cursor := dbms_sql.open_cursor;
      dbms_sql.parse(l_cursor, p_insert_sql, dbms_sql.native);

      --
      -- First bind is the CCID.
      --
      dbms_sql.bind_variable(l_cursor, 'CCID', l_ccid);

      --
      -- Bind Start and End Dates.
      --
      dbms_sql.bind_variable(l_cursor, 'START_DATE_ACTIVE', p_start_date_active);
      dbms_sql.bind_variable(l_cursor, 'END_DATE_ACTIVE', p_end_date_active);

      --
      -- Bind the rest.
      --
      FOR i IN 1..l_bind_count LOOP
         dbms_sql.bind_variable(l_cursor, 'I' || i, l_binds(i));
      END LOOP;
      l_num := dbms_sql.execute(l_cursor);
      dbms_sql.close_cursor(l_cursor);
      IF (l_num <> 1) THEN
         fnd_message.set_name('FND', 'FLEX-USER DEFINED ERROR');
         fnd_message.set_token('MSG', l_func_name ||
                               ' is unable to insert new combination. ' ||
                               ' Dynamic INSERT SQL returned ' || l_num ||
                               ' rows, it was expected to return 1 row.');
         GOTO return_failure;
      END IF;
      x_is_new := 'Y';
   EXCEPTION
      WHEN OTHERS THEN
         dbms_sql.close_cursor(l_cursor);
         fnd_message.set_name('FND', 'FLEX-USER DEFINED ERROR');
         fnd_message.set_token('MSG', l_func_name ||
                               ' is unable to insert new combination. ' ||
                               ' into table ' || p_application_table_name ||
                               '. ' || l_newline ||
                               'SQLERRM: ' || Sqlerrm);
         GOTO return_failure;
   END;

   --
   -- Now FDFGLI.
   --
   IF ((p_application_id = 101) AND (p_id_flex_code ='GL#')) THEN
      IF (NOT call_fdfgli(l_ccid)) THEN
         GOTO return_failure;
      END IF;
   END IF;

   <<return_success>>
   x_encoded_error := NULL;
   x_ccid := l_ccid;
   COMMIT;
   RETURN;

   <<return_failure>>
   x_encoded_error := fnd_message.get_encoded;
   x_ccid := -1;
   x_is_new := 'U';
   ROLLBACK;
   RETURN;
EXCEPTION
   WHEN OTHERS THEN
      fnd_message.set_name('FND', 'FLEX-USER DEFINED ERROR');
      fnd_message.set_token('MSG', 'Top level exception in ' || l_func_name ||
                            l_newline || 'SQLERRM: ' || Sqlerrm);
      x_encoded_error := fnd_message.get_encoded;
      x_ccid := -1;
      ROLLBACK;
      RETURN;
END do_dynamic_insert_at;


-- ----------------------------------------------------------------------
-- Uses non-autonomous transaction and doesn't commit.
-- The calling transaction has to instantiate the
-- save-points and do COMMIT or ROLLBACK
-- ----------------------------------------------------------------------
PROCEDURE do_dynamic_insert_no_at(p_application_id         IN NUMBER,
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
                                   x_encoded_error          OUT nocopy VARCHAR2)
  IS

     l_func_name        VARCHAR2(100);
     l_ff_structure     FND_FLEX_SERVER1.flexstructid;
     l_bind_count       NUMBER;
     l_binds            fnd_flex_server1.valuearray;
     l_newline          VARCHAR2(10);
     l_ccid             NUMBER;
     l_cursor           NUMBER;
     l_hash_value       NUMBER;
     l_segment_ids      fnd_flex_server1.valueidarray;

     --
     -- Temporary number and varchar2 buffers.
     --
     l_num              NUMBER;
     l_vc2              VARCHAR2(32000);
     temp               VARCHAR2(32000);
BEGIN
   l_func_name := 'SSV.do_dynamic_insert_no_at()';
   l_newline := fnd_global.newline;
   x_is_new := 'U';
   --
   -- Lock the combination table.
   --
   BEGIN
      EXECUTE IMMEDIATE ('LOCK TABLE ' || p_application_table_name ||
                         ' IN ROW SHARE MODE');
   EXCEPTION
      WHEN OTHERS THEN
         fnd_message.set_name('FND', 'FLEX-USER DEFINED ERROR');
         fnd_message.set_token('MSG', l_func_name ||
                               ' is unable to lock table ' ||
                               p_application_table_name || '. ' || l_newline ||
                               'SQLERRM: ' || Sqlerrm);
         GOTO return_failure;
   END;

   --
   -- Get the concatenated combination.
   -- End of Insert SQL Binds is concatenated combination.
   -- Final result is something like '10\n20\nA\n'
   --
   -- First step gets concat comb with beginning newline character
   l_vc2 := Substr(p_insert_sql_binds,
                         Instr(p_insert_sql_binds,
                               l_newline, -1, p_segment_count + 1));
   -- Second/final step removes initial newline and puts concat comb in l_vc2
   temp := Substr(l_vc2, 2);
   l_vc2 := temp;

   --
   -- Parse the segment ids.
   --
   FOR i IN 1..p_segment_count LOOP
      l_num := Instr(l_vc2, l_newline, 1, 1);
      l_segment_ids(i) := Substr(l_vc2, 1, l_num - 1);
      l_vc2 := Substr(l_vc2, l_num + 1);
   END LOOP;

   --
   -- Generate a hash value.
   --
   l_hash_value := hash_segs(p_segment_count, l_segment_ids);

   --
   -- Lock the hash table.
   --
   BEGIN
      SELECT hash_value
        INTO l_num
        FROM fnd_flex_hash
        WHERE hash_value = l_hash_value
        FOR UPDATE;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_message.set_name('FND', 'FLEX-USER DEFINED ERROR');
         fnd_message.set_token('MSG', l_func_name ||
                               ' is unable to lock FND_FLEX_HASH. ' ||
                               'Hash Value: ' || l_hash_value || l_newline ||
                               'SQLERRM: ' || Sqlerrm);
         GOTO return_failure;
   END;

   --
   -- We locked Comb. Table and the Hash table, now let's check the
   -- Comb. Table one more time.
   --

   --
   -- See KeyFlexfield.getCCIDfromDynamicInsertion() for a sample SELECT SQL.
   --

   --
   -- Parse SELECT SQL bind values.
   --
   l_bind_count := 0;
   l_vc2 := p_select_sql_binds;
   WHILE (l_vc2 IS NOT NULL) LOOP
      l_bind_count := l_bind_count + 1;
      l_num := Instr(l_vc2, l_newline, 1, 1);
      l_binds(l_bind_count) := Substr(l_vc2, 1, l_num - 1);
      l_vc2 := Substr(l_vc2, l_num + 1);
   END LOOP;

   --
   -- Check if the combination is already in the table.
   --
   BEGIN
      l_cursor := dbms_sql.open_cursor;
      dbms_sql.parse(l_cursor, p_select_sql, dbms_sql.native);
      FOR i IN 1..l_bind_count LOOP
         dbms_sql.bind_variable(l_cursor, 'S' || i , l_binds(i));
      END LOOP;
      dbms_sql.define_column(l_cursor, 1, l_ccid);
      l_num := dbms_sql.execute_and_fetch(l_cursor, TRUE);

      --
      -- Combination already exists.
      --
      dbms_sql.column_value(l_cursor, 1, l_ccid);
      dbms_sql.close_cursor(l_cursor);
      x_is_new := 'N';
      GOTO return_success;
   EXCEPTION
      WHEN no_data_found THEN
         --
         -- Combination doesn't exist, continue to INSERT.
         --
         dbms_sql.close_cursor(l_cursor);
      WHEN OTHERS THEN
         dbms_sql.close_cursor(l_cursor);
         fnd_message.set_name('FND', 'FLEX-USER DEFINED ERROR');
         fnd_message.set_token('MSG', l_func_name ||
                               ' is unable to select from table ' ||
                               p_application_table_name || '. ' || l_newline ||
                               'SQLERRM: ' || Sqlerrm);
         GOTO return_failure;
   END;

   --
   --  Call user validation function.
   --
   IF (userval_on) THEN
      l_ff_structure.isa_key_flexfield := TRUE;
      l_ff_structure.application_id := p_application_id;
      l_ff_structure.id_flex_code := p_id_flex_code;
      l_ff_structure.id_flex_num := p_id_flex_num;

      IF (NOT call_userval(l_ff_structure,
                           p_validation_date,
                           p_segment_count,
                           p_segment_delimiter,
                           l_segment_ids)) THEN
         GOTO return_failure;
      END IF;
   END IF;


   --
   -- Now we are ready to insert.
   --

   --
   -- See KeyFlexfield.getCCIDfromDynamicInsertion() for a sample INSERT SQL.
   --

   --
   -- Parse INSERT SQL bind values.
   --
   l_bind_count := 0;
   l_vc2 := p_insert_sql_binds;
   WHILE (l_vc2 IS NOT NULL) LOOP
      l_bind_count := l_bind_count + 1;
      l_num := Instr(l_vc2, l_newline, 1, 1);
      l_binds(l_bind_count) := Substr(l_vc2, 1, l_num - 1);
      l_vc2 := Substr(l_vc2, l_num + 1);
   END LOOP;

   --
   -- Get the next CCID.
   --
   BEGIN
      EXECUTE IMMEDIATE ('SELECT ' || p_application_table_name ||
                         '_S.NEXTVAL FROM dual')
        INTO l_ccid;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_message.set_name('FND', 'FLEX-USER DEFINED ERROR');
         fnd_message.set_token('MSG', l_func_name ||
                               ' is unable to get next value from sequence ' ||
                               p_application_table_name || '_S. ' ||l_newline||
                               'SQLERRM: ' || Sqlerrm);
         GOTO return_failure;
   END;

   --
   -- INSERT the combination.
   --
   BEGIN
      l_cursor := dbms_sql.open_cursor;
      dbms_sql.parse(l_cursor, p_insert_sql, dbms_sql.native);

      --
      -- First bind is the CCID.
      --
      dbms_sql.bind_variable(l_cursor, 'CCID', l_ccid);

      --
      -- Bind Start and End Dates.
      --
      dbms_sql.bind_variable(l_cursor, 'START_DATE_ACTIVE', p_start_date_active);
      dbms_sql.bind_variable(l_cursor, 'END_DATE_ACTIVE', p_end_date_active);

      --
      -- Bind the rest.
      --
      FOR i IN 1..l_bind_count LOOP
         dbms_sql.bind_variable(l_cursor, 'I' || i, l_binds(i));
      END LOOP;
      l_num := dbms_sql.execute(l_cursor);
      dbms_sql.close_cursor(l_cursor);
      IF (l_num <> 1) THEN
         fnd_message.set_name('FND', 'FLEX-USER DEFINED ERROR');
         fnd_message.set_token('MSG', l_func_name ||
                               ' is unable to insert new combination. ' ||
                               ' Dynamic INSERT SQL returned ' || l_num ||
                               ' rows, it was expected to return 1 row.');
         GOTO return_failure;
      END IF;
      x_is_new := 'Y';
   EXCEPTION
      WHEN OTHERS THEN
         dbms_sql.close_cursor(l_cursor);
         fnd_message.set_name('FND', 'FLEX-USER DEFINED ERROR');
         fnd_message.set_token('MSG', l_func_name ||
                               ' is unable to insert new combination. ' ||
                               ' into table ' || p_application_table_name ||
                               '. ' || l_newline ||
                               'SQLERRM: ' || Sqlerrm);
         GOTO return_failure;
   END;

   --
   -- Now FDFGLI.
   --
   IF ((p_application_id = 101) AND (p_id_flex_code ='GL#')) THEN
      IF (NOT call_fdfgli(l_ccid)) THEN
         GOTO return_failure;
      END IF;
   END IF;

   <<return_success>>
   x_encoded_error := NULL;
   x_ccid := l_ccid;
   RETURN;

   <<return_failure>>
   x_encoded_error := fnd_message.get_encoded;
   x_ccid := -1;
   x_is_new := 'U';
   RETURN;
EXCEPTION
   WHEN OTHERS THEN
      fnd_message.set_name('FND', 'FLEX-USER DEFINED ERROR');
      fnd_message.set_token('MSG', 'Top level exception in ' || l_func_name ||
                            l_newline || 'SQLERRM: ' || Sqlerrm);
      x_encoded_error := fnd_message.get_encoded;
      x_ccid := -1;
      RETURN;
END do_dynamic_insert_no_at;


-- ======================================================================
-- Local Cache Functions
-- ======================================================================
FUNCTION check_vsc(p_application_id    IN NUMBER,
                   p_responsibility_id IN NUMBER,
                   p_value_set_id      IN NUMBER,
                   p_parent_value      IN VARCHAR2,
                   p_value             IN VARCHAR2,
                   px_security_status  IN OUT nocopy VARCHAR2,
                   px_error_message    IN OUT nocopy VARCHAR2)
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
      px_security_status := g_cache_value.varchar2_1;
      px_error_message := g_cache_value.varchar2_2;
   END IF;

   RETURN(g_cache_return_code);
EXCEPTION
   WHEN OTHERS THEN
      RETURN(fnd_plsql_cache.CACHE_NOTFOUND);
END check_vsc;

PROCEDURE update_vsc(p_application_id    IN NUMBER,
                     p_responsibility_id IN NUMBER,
                     p_value_set_id      IN NUMBER,
                     p_parent_value      IN VARCHAR2,
                     p_value             IN VARCHAR2,
                     p_security_status   IN VARCHAR2,
                     p_error_message     IN VARCHAR2)
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

   fnd_plsql_cache.generic_cache_new_value
     (x_value      => g_cache_value,
      p_varchar2_1 => p_security_status,
      p_varchar2_2 => p_error_message);

   fnd_plsql_cache.generic_1to1_put_value(vsc_cache_controller,
                                          vsc_cache_storage,
                                          g_cache_key,
                                          g_cache_value);
EXCEPTION
   WHEN OTHERS THEN
      RETURN;
END update_vsc;

-- ======================================
-- PROCEDURE : check_value_security
-- ======================================
-- Checks if a value is secured.
--
PROCEDURE check_value_security(p_security_check_mode   IN VARCHAR2,
                               p_flex_value_set_id     IN NUMBER,
                               p_parent_flex_value     IN VARCHAR2,
                               p_flex_value            IN VARCHAR2,
                               p_resp_application_id   IN NUMBER,
                               p_responsibility_id     IN NUMBER,
                               x_security_status       OUT nocopy VARCHAR2,
                               x_error_message         OUT nocopy VARCHAR2)
  IS PRAGMA AUTONOMOUS_TRANSACTION;

     l_x_security_status VARCHAR2(100);
     l_x_error_message   VARCHAR2(32000);

     l_error_message     fnd_flex_value_rules_tl.error_message%TYPE;

     l_sql               VARCHAR2(32000);

     l_vset              fnd_flex_value_sets%ROWTYPE;
     l_lock_handle       VARCHAR2(128) := NULL;
     l_vsc_code          VARCHAR2(10);

     --
     -- Returns '(f(p_column) BETWEEN f(p_min_column) AND f(p_max_column)) '
     -- f() depends on p_format_type and p_apply_nvl.
     --
/**********************************************************************************
  Also note, Dependent vsets do not support Hier security, but Regular sec is supported.
  Translated Ind and Dep vsets do not suport any security.
  None, Special and Pair also do not support any seucrity.
  Table vset does support Hier and Non-Hier security
**********************************************************************************
  For bug 13101244 the code had to be rewritten. the original code was a bug
  waiting to happen. When a number type vset was used, the code added
  fnd_number.canonical_to_number() around the column in the WHERE clause.
  The columns that stores the vset values is of type VARCHAR2, so it can
  store numbers or chars. For number vsets we must convert the 'Num' chars to
  number to be compared in the between clause as numbers not Chars.
  For a Number Type vset we can grantee that all the value are numbers.
  The problem is that the explain plan of the DB does not guarantee that it
  first restricts the values by value set. It can first parse the between
  comparison before it filters the vset. Being that the case, the values
  in the column can be of type Char or number. So when a number conversion
  is attempted on a char, sql throws an error. So the WHERE clause had
  to be written with a decode statement.
***********************************************************************************/

 FUNCTION get_between_sql(p_format_type      IN VARCHAR2,
                          p_column           IN VARCHAR2,
                          p_min_column       IN VARCHAR2,
                          p_max_column       IN VARCHAR2,
                          p_apply_nvl        IN BOOLEAN)
  RETURN VARCHAR2
  IS
  BEGIN

     IF (p_format_type = 'N') THEN -- Number
        IF (p_apply_nvl) THEN
           RETURN(' fnd_number.canonical_to_number(' || p_column || ') ' ||
                  ' BETWEEN fnd_number.canonical_to_number(DECODE(RTRIM(TRANSLATE(Nvl(' ||
                      p_min_column || ', ' || p_column || '),''0123456789'',''0''),''0''), NULL, ' ||
                      'Nvl(' || p_min_column || ', ' || p_column || '),  -99999))' ||
                  ' AND     fnd_number.canonical_to_number(DECODE(RTRIM(TRANSLATE(Nvl(' ||
                      p_max_column || ', ' || p_column || '),''0123456789'',''0''),''0''), NULL, ' ||
                      'Nvl(' || p_max_column || ', ' || p_column || '),  -99999))');
        ELSE -- No NVL()
           RETURN(' fnd_number.canonical_to_number(' || p_column || ') ' ||
                  ' BETWEEN fnd_number.canonical_to_number(DECODE(RTRIM(TRANSLATE(' ||
                      p_min_column || ',''0123456789'',''0''),''0''), NULL, ' ||
                      p_min_column || ',  -99999))' ||
                  ' AND     fnd_number.canonical_to_number(DECODE(RTRIM(TRANSLATE(' ||
                      p_max_column || ',''0123456789'',''0''),''0''), NULL, ' ||
                      p_max_column || ',  -99999))');
        END IF;
/************************************************************************************************************
     Date, DateTime and Time value sets are not supported in vset Security Logic
     At this time it is not feasible to make the code work using Decodes
     ELSIF (p_format_type in ('X', 'Y')) THEN -- Standard Date and Time
        IF (p_apply_nvl) THEN
           RETURN(' fnd_date.canonical_to_date(' || p_column || ') ' ||
                  ' BETWEEN fnd_date.canonical_to_date(DECODE(RTRIM(TRANSLATE(Nvl(' ||
                      p_min_column || ', ' || p_column || '),''0123456789'',''0''),''0''), NULL, ' ||
                      'Nvl(' || p_min_column || ', ' || p_column || '), -99999))' ||
                  ' AND     fnd_date.canonical_to_date(DECODE(RTRIM(TRANSLATE(Nvl(' ||
                      p_max_column || ', ' || p_column || '),''0123456789'',''0''),''0''), NULL, ' ||
                      'Nvl(' || p_max_column || ', ' || p_column || '), -99999))');
        ELSE
           RETURN(' fnd_date.canonical_to_date(' || p_column || ') ' ||
                  ' BETWEEN fnd_date.canonical_to_date(DECODE(RTRIM(TRANSLATE(' ||
                      p_min_column || ',''0123456789'',''0''),''0''), NULL, ' ||
                      p_min_column || ',  -99999))' ||
                  ' AND     fnd_date.canonical_to_date(DECODE(RTRIM(TRANSLATE(' ||
                      p_max_column || ',''0123456789'',''0''),''0''), NULL, ' ||
                      p_max_column || ',  -99999))');
        END IF;
     ELSIF (p_format_type = 'I') THEN -- Time
        IF (p_apply_nvl) THEN
           RETURN('to_date(' || p_column || ', ''HH24:MI:SS'') ' ||
                  ' BETWEEN ' || 'to_date(DECODE(RTRIM(TRANSLATE(Nvl(' ||
                      p_min_column || ', ' || p_column || '), ''0123456789'',''0''),''0''), NULL, ' ||
                      'Nvl(' || p_min_column || ', ' || p_column || '),  -99999), ''HH24:MI:SS'') ' ||
                  ' AND     to_date(DECODE(RTRIM(TRANSLATE(Nvl(' ||
                      p_max_column || ', ' || p_column || '), ''0123456789'',''0''),''0''), NULL, ' ||
                      'Nvl(' || p_max_column || ', ' || p_column || '), -99999), ''HH24:MI:SS'')');
        ELSE
           RETURN('to_date(' || p_column || ', ''HH24:MI:SS'') BETWEEN ' ||
                  'to_date(DECODE(RTRIM(TRANSLATE(' ||
                  p_min_column || ',''0123456789'',''0''),''0''), NULL, ' ||
                  p_min_column || ',  -99999), ''HH24:MI:SS'') AND ' ||
                  'to_date(DECODE(RTRIM(TRANSLATE(' ||
                  p_max_column || ',''0123456789'',''0''),''0''), NULL, ' ||
                  p_max_column || ',  -99999), ''HH24:MI:SS'')');
        END IF;
******************************************************************************************************************/
     ELSE  -- Character, The default code will be Char type.
        IF (p_apply_nvl) THEN
           RETURN(p_column || ' BETWEEN ' ||
                  'Nvl(' || p_min_column || ', ' || p_column ||') AND ' ||
                  'Nvl(' || p_max_column || ', ' || p_column || ') ');
        ELSE
           RETURN(p_column || ' BETWEEN ' ||
                  p_min_column || ' AND ' ||
                  p_max_column || ' ');
        END IF;
    END IF;
 END get_between_sql;



 FUNCTION get_dependent_sql(p_format_type   IN VARCHAR2,
                            p_parent_column IN VARCHAR2)
  RETURN VARCHAR2
  IS
  BEGIN

     IF (p_format_type = 'N') THEN -- Number
             RETURN(' AND r.parent_flex_value_low = ' ||
                      'fnd_number.canonical_to_number(DECODE(RTRIM(TRANSLATE(' || p_parent_column ||
                      ', ''0123456789'',''0''),''0''), NULL, ' ||   p_parent_column || ', -99999))' );
/*
     ELSIF (p_format_type in ('X', 'Y')) THEN -- Standard Date and Time
             RETURN(' AND r.parent_flex_value_low = ' ||
                      'fnd_date.canonical_to_date(DECODE(RTRIM(TRANSLATE(' || p_parent_column ||
                      ', ''0123456789'',''0''),''0''), NULL, ' ||   p_parent_column || ', -99999))' );
     ELSIF (p_format_type = 'I') THEN -- Time
             RETURN(' AND r.parent_flex_value_low = ' ||
                      'to_date(DECODE(RTRIM(TRANSLATE(' || p_parent_column || '''0123456789'',''0''),''0''), NULL,' ||
                      p_parent_column || ', -99999), ''HH24:MI:SS'')');
*/
     ELSE
          RETURN(' AND (r.parent_flex_value_low = '  || p_parent_column || ') ');
     END IF;

 END get_dependent_sql;



BEGIN

   l_x_security_status := 'NOT-SECURED';
   l_x_error_message := NULL;

   --
   -- Get the value set.
   --
   g_cache_key := p_flex_value_set_id;
   fnd_plsql_cache.custom_1to1_get_get_index(vst_cache_controller,
                                             g_cache_key,
                                             g_cache_index,
                                             g_cache_return_code);
   IF (g_cache_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
      l_vset := vst_cache_storage(g_cache_index);
    ELSE
      BEGIN
         SELECT *
           INTO l_vset
           FROM fnd_flex_value_sets
          WHERE 'AFFFSSVB.pls : $Revision: 120.13.12010000.23 $ : check_value_security' IS NOT NULL
            AND flex_value_set_id = p_flex_value_set_id;
      EXCEPTION
         WHEN OTHERS THEN
            fnd_message.set_name('FND', 'FLEX-ERROR LOADING VALUE SET');
            fnd_message.set_token('VALUE_SET_NAME', p_flex_value_set_id);
            l_x_security_status := 'VSET-NOTFOUND';
            l_x_error_message := fnd_message.get;
            GOTO goto_return;
      END;
      fnd_plsql_cache.custom_1to1_get_put_index(vst_cache_controller,
                                                g_cache_key,
                                                g_cache_index);

      vst_cache_storage(g_cache_index) := l_vset;
   END IF;

   --
   -- p_security_check_mode: Not used anymore. Kept for backward compatibility.
   --
   -- Y : Normal Check Only
   -- H : Hierarchy Check Only
   -- YH : Both Normal and Hierarchy Checks.
   --
   IF (p_security_check_mode NOT IN ('Y', 'H', 'YH')) THEN
      l_x_security_status := 'WRONG-ARG';
      l_x_error_message := 'Developer Error: p_check_security_mode must be Y, H, or YH.';
      GOTO goto_return;
   END IF;

   IF (l_vset.security_enabled_flag NOT IN ('Y', 'H')) THEN
      GOTO goto_return;
   END IF;

   IF (l_vset.validation_type NOT IN ('I', 'D', 'F')) THEN
      GOTO goto_return;
   END IF;

   IF (p_flex_value IS NULL) THEN
      GOTO goto_return;
   END IF;

   --
   -- First check the VSC
   --
   l_vsc_code := check_vsc(p_application_id    => p_resp_application_id,
                           p_responsibility_id => p_responsibility_id,
                           p_value_set_id      => p_flex_value_set_id,
                           p_parent_value      => p_parent_flex_value,
                           p_value             => p_flex_value,
                           px_security_status  => l_x_security_status,
                           px_error_message    => l_x_error_message);

   IF (l_vsc_code = fnd_plsql_cache.CACHE_FOUND) THEN
      IF (fnd_flex_server1.g_debug_level > 0) THEN
         fnd_flex_server1.add_debug('Found in SSV.VSC.');
      END IF;
      GOTO goto_return;
   END IF;

   --
   -- Not in the cache, continue on security check.
   --

   IF ((l_vset.security_enabled_flag = 'H') AND
       (l_vset.validation_type <> 'D')) THEN

      -- Bug 8996310, If  hierarchical security is being used then
      -- request a lock to make sure hier comp is not running.
      -- If the hier comp is running, this request_lock will wait until
      -- the lock is rleased by the hier comp signifying it is complete.
      -- Once he hier is complete we then can continue processing the hier
      -- security check. If the hier comp is not running, then this
      -- request lock will get a lock signifying the hier comp not running
      -- at this moment in time. Once locked, we know the hier comp is
      -- not running and then we can release the lock and continue processing.
      -- We know we can release the lock because this PROCEDURE is defined
      -- to be serializable. Serializable allows the process to take a snap
      -- shot of the data. Eventhough the data maybe be deleted by the hier
      -- comp, this process will still see the snap shot of data before it
      -- was deleted. In this way security is not compromised, if hier comp
      -- starts running in the middle of this process. By releasing the
      -- lock, we will not get process contentions.
      fnd_flex_hierarchy_compiler.request_lock(l_vset.flex_value_set_name, l_lock_handle);
      SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
      IF (l_lock_handle IS NOT NULL) THEN
         fnd_flex_hierarchy_compiler.release_lock(l_vset.flex_value_set_name, l_lock_handle);
      END IF;
   END IF;

   --
   -- Check for value being directly excluded by a security rule...
   --
   l_sql :=
     'SELECT r.error_message' ||
     '  FROM fnd_flex_value_rules_vl r, fnd_flex_value_rule_usages u, fnd_flex_value_rule_lines l' ||
     ' WHERE r.flex_value_set_id = :b_flex_value_set_id' ||
     '   AND u.application_id = :b_resp_application_id' ||
     '   AND u.responsibility_id = :b_responsibility_id' ||
     '   AND u.flex_value_rule_id = r.flex_value_rule_id' ||
     '   AND l.flex_value_set_id = r.flex_value_set_id' ||
     '   AND l.flex_value_rule_id = r.flex_value_rule_id' ||
     '   AND l.include_exclude_indicator = ''E''' ||
     '   AND ' || get_between_sql(l_vset.format_type, ':b_flex_value', 'l.flex_value_low', 'l.flex_value_high', TRUE) ||
     '   AND ROWNUM < 2';

   BEGIN
      IF (l_vset.validation_type = 'D') THEN
         l_sql := l_sql || get_dependent_sql(l_vset.format_type, ':b_parent_flex_value');
--         IF (l_vset.format_type in ('N','X','Y','I')) THEN -- More bind variables are need in these cases.
         IF (l_vset.format_type in ('N')) THEN -- More bind variables are need in these cases.
            EXECUTE IMMEDIATE l_sql INTO l_error_message USING
              p_flex_value_set_id,
              p_resp_application_id,
              p_responsibility_id,
              p_flex_value, p_flex_value, p_flex_value, p_flex_value, p_flex_value,
              p_parent_flex_value, p_parent_flex_value;
         ELSE
            EXECUTE IMMEDIATE l_sql INTO l_error_message USING
              p_flex_value_set_id,
              p_resp_application_id,
              p_responsibility_id,
              p_flex_value, p_flex_value, p_flex_value,
              p_parent_flex_value;
         END IF;
       ELSE
--         IF (l_vset.format_type in ('N','X','Y','I')) THEN
         IF (l_vset.format_type in ('N')) THEN
            EXECUTE IMMEDIATE l_sql INTO l_error_message USING
              p_flex_value_set_id,
              p_resp_application_id,
              p_responsibility_id,
              p_flex_value, p_flex_value, p_flex_value, p_flex_value, p_flex_value;
         ELSE
            EXECUTE IMMEDIATE l_sql INTO l_error_message USING
              p_flex_value_set_id,
              p_resp_application_id,
              p_responsibility_id,
              p_flex_value, p_flex_value, p_flex_value;
         END IF;
      END IF;

      fnd_message.set_name('FND', 'FLEX-EXCLUDED BY SEC. RULE');
      fnd_message.set_token('MESSAGE', l_error_message);

      l_x_security_status := 'EXCLUDED';
      l_x_error_message := fnd_message.get;
      GOTO goto_cache_the_result;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         --
         -- NOT directly excluded, keep checking...
         --
         NULL;
   END;

   --
   -- Check for value being hierarchically excluded by a security rule...
   --
   IF ((l_vset.security_enabled_flag = 'H') AND
       (l_vset.validation_type <> 'D')) THEN

      l_sql :=
        'SELECT /*+ LEADING (h) */ r.error_message' ||
        '  FROM fnd_flex_value_rules_vl r, fnd_flex_value_rule_usages u, fnd_flex_value_hier_all h, fnd_flex_value_rule_lines l' ||
        ' WHERE r.flex_value_set_id = :b_flex_value_set_id' ||
        '   AND u.application_id = :b_resp_application_id' ||
        '   AND u.responsibility_id = :b_responsibility_id' ||
        '   AND u.flex_value_rule_id = r.flex_value_rule_id' ||
        '   AND h.flex_value_set_id = r.flex_value_set_id' ||
        '   AND l.flex_value_set_id = r.flex_value_set_id' ||
        '   AND l.flex_value_rule_id = r.flex_value_rule_id' ||
        '   AND l.include_exclude_indicator = ''E''' ||
        '   AND ' || get_between_sql(l_vset.format_type, ':b_flex_value', 'h.child_flex_value_low', 'h.child_flex_value_high', FALSE) ||
        '   AND ' || get_between_sql(l_vset.format_type, 'h.parent_flex_value', 'l.flex_value_low', 'l.flex_value_high', TRUE) ||
        '   AND ROWNUM < 2 ';

      BEGIN
         EXECUTE IMMEDIATE l_sql INTO l_error_message USING
           p_flex_value_set_id,
           p_resp_application_id,
           p_responsibility_id,
           p_flex_value;

         fnd_message.set_name('FND', 'FLEX-EXCLUDED BY SEC. RULE');
         fnd_message.set_token('MESSAGE', l_error_message);

         l_x_security_status := 'HIER-EXCLUDED';
         l_x_error_message := fnd_message.get;
         GOTO goto_cache_the_result;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            --
            -- Not hierarchically excluded, keep checking...
            --
            NULL;
      END;
   END IF;

   --
   -- Check for value NOT being directly included by a security rule...
   --
   l_sql :=
     'SELECT r.error_message' ||
     '  FROM fnd_flex_value_rules_vl r, fnd_flex_value_rule_usages u' ||
     ' WHERE r.flex_value_set_id = :b_flex_value_set_id' ||
     '   AND u.application_id = :b_resp_application_id' ||
     '   AND u.responsibility_id = :b_responsibility_id' ||
     '   AND u.flex_value_rule_id = r.flex_value_rule_id' ||
     '   AND NOT exists (SELECT NULL' ||
     '                     FROM fnd_flex_value_rule_lines l' ||
     '                    WHERE l.flex_value_rule_id = r.flex_value_rule_id' ||
     '                      AND l.flex_value_set_id = r.flex_value_set_id' ||
     '                      AND l.include_exclude_indicator = ''I''' ||
     '                      AND ' || get_between_sql(l_vset.format_type, ':b_flex_value', 'l.flex_value_low', 'l.flex_value_high', TRUE) ||
     '                  )' ||
     '   AND ROWNUM < 2 ';

   BEGIN
      IF (l_vset.validation_type = 'D') THEN
         l_sql := l_sql || get_dependent_sql(l_vset.format_type, ':b_parent_flex_value');
--         IF (l_vset.format_type in ('N','X','Y','I')) THEN
         IF (l_vset.format_type in ('N')) THEN
            EXECUTE IMMEDIATE l_sql INTO l_error_message USING
              p_flex_value_set_id,
              p_resp_application_id,
              p_responsibility_id,
              p_flex_value, p_flex_value, p_flex_value, p_flex_value, p_flex_value,
              p_parent_flex_value, p_parent_flex_value;
         ELSE
            EXECUTE IMMEDIATE l_sql INTO l_error_message USING
              p_flex_value_set_id,
              p_resp_application_id,
              p_responsibility_id,
              p_flex_value, p_flex_value, p_flex_value,
              p_parent_flex_value;
         END IF;
       ELSE
--         IF (l_vset.format_type in ('N','X','Y','I')) THEN
         IF (l_vset.format_type in ('N')) THEN
            EXECUTE IMMEDIATE l_sql INTO l_error_message USING
              p_flex_value_set_id,
              p_resp_application_id,
              p_responsibility_id,
              p_flex_value, p_flex_value, p_flex_value, p_flex_value, p_flex_value;
         ELSE
            EXECUTE IMMEDIATE l_sql INTO l_error_message USING
              p_flex_value_set_id,
              p_resp_application_id,
              p_responsibility_id,
              p_flex_value, p_flex_value, p_flex_value;
         END IF;
      END IF;

      fnd_message.set_name('FND', 'FLEX-NOT INCL. BY SEC RULE');
      fnd_message.set_token('MESSAGE', l_error_message);

      l_x_security_status := 'NOT-INCLUDED';
      l_x_error_message := fnd_message.get;

      --
      -- NOT directly included, it might be hierarchically included...
      --
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         --
         -- Directly included, we are done.
         --
         GOTO goto_cache_the_result;
   END;

   --
   -- Check for value NOT being hierarchically included by a security rule...
   --
   IF ((l_vset.security_enabled_flag = 'H') AND
       (l_vset.validation_type <> 'D')) THEN

      l_sql :=
        'SELECT r.error_message' ||
        '  FROM fnd_flex_value_rules_vl r, fnd_flex_value_rule_usages u' ||
        ' WHERE r.flex_value_set_id = :b_flex_value_set_id' ||
        '   AND u.application_id = :b_resp_application_id' ||
        '   AND u.responsibility_id = :b_responsibility_id' ||
        '   AND u.flex_value_rule_id = r.flex_value_rule_id' ||
        '   AND NOT exists (SELECT NULL' ||
        '                     FROM fnd_flex_value_hier_all h, fnd_flex_value_rule_lines l' ||
        '                    WHERE h.flex_value_set_id = r.flex_value_set_id' ||
        '                      AND l.flex_value_set_id = r.flex_value_set_id' ||
        '                      AND l.flex_value_rule_id = r.flex_value_rule_id' ||
        '                      AND l.include_exclude_indicator = ''I''' ||
        '                      AND ' || get_between_sql(l_vset.format_type, ':b_flex_value', 'h.child_flex_value_low', 'h.child_flex_value_high', FALSE) ||
        '                      AND ' || get_between_sql(l_vset.format_type, 'h.parent_flex_value', 'l.flex_value_low', 'l.flex_value_high', TRUE) ||
        '                  )' ||
        '   AND ROWNUM < 2';

      BEGIN
         EXECUTE IMMEDIATE l_sql INTO l_error_message USING
           p_flex_value_set_id,
           p_resp_application_id,
           p_responsibility_id,
           p_flex_value;

         --
         -- NOT hierarchically included, Error message is already set above.
         --
         -- Bug 9746618 Setting message from previous check does not
         -- give accurate message when a violation is found from
         -- this security check. Need to set message from this check.
         fnd_message.set_name('FND', 'FLEX-NOT INCL. BY SEC RULE');
         fnd_message.set_token('MESSAGE', l_error_message);

         l_x_security_status := 'NOT-HIER-INCLUDED';
         l_x_error_message := fnd_message.get;


         GOTO goto_cache_the_result;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            --
            -- Hierarchically included. Clear the error message set above.
            --
            l_x_security_status := 'NOT-SECURED';
            l_x_error_message := NULL;

            GOTO goto_cache_the_result;
      END;
   END IF;

   <<goto_cache_the_result>>

   update_vsc(p_application_id    => p_resp_application_id,
              p_responsibility_id => p_responsibility_id,
              p_value_set_id      => p_flex_value_set_id,
              p_parent_value      => p_parent_flex_value,
              p_value             => p_flex_value,
              p_security_status   => l_x_security_status,
              p_error_message     => l_x_error_message);


   <<goto_return>>

   x_security_status := l_x_security_status;
   x_error_message := Substrb(l_x_error_message, 1, 1950);
   COMMIT; -- To end snap shot of Serializable.

   RETURN;
EXCEPTION
   WHEN OTHERS THEN
      IF (l_lock_handle IS NOT NULL) THEN
         fnd_flex_hierarchy_compiler.release_lock(l_vset.flex_value_set_name, l_lock_handle);
      END IF;
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG', 'SSV.check_value_security(): ' || SQLERRM);
      x_security_status := 'EXCEPTION';
      x_error_message := Substrb(fnd_message.get, 1, 1950);
      COMMIT; -- To end snap shot of Serializable.
END check_value_security;

-- ==================================================
-- PROCEDURE : parse_flex_values
-- ==================================================
PROCEDURE parse_flex_values(p_concatenated_flex_values IN VARCHAR2,
                            p_delimiter                IN VARCHAR2,
                            p_numof_flex_values        IN NUMBER DEFAULT NULL,
                            x_flex_values              OUT nocopy fnd_flex_server1.stringarray,
                            x_numof_flex_values        OUT nocopy NUMBER)
  IS
BEGIN
   --
   -- If only one segment is expected then no parsing, and no un-escaping.
   --
   IF ((Nvl(p_numof_flex_values, 0) = 1) OR
       (p_concatenated_flex_values IS NULL)) THEN
      x_numof_flex_values := 1;
      x_flex_values(1) := p_concatenated_flex_values;
    ELSE
      x_numof_flex_values :=
        fnd_flex_server1.to_stringarray(p_concatenated_flex_values,
                                        p_delimiter,
                                        x_flex_values);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      RAISE;
END parse_flex_values;

-- ==================================================
-- PROCEDURE : concatenate_flex_values
-- ==================================================
PROCEDURE concatenate_flex_values(p_flex_values              IN fnd_flex_server1.stringarray,
                                  p_numof_flex_values        IN NUMBER,
                                  p_delimiter                IN VARCHAR2,
                                  x_concatenated_flex_values OUT nocopy VARCHAR2)
  IS
BEGIN
   IF (fnd_flex_server1.g_debug_level > 0) THEN
      fnd_flex_server1.add_debug('BEGIN SSV.concatenate_flex_values()');
   END IF;
   IF (p_numof_flex_values > 0) THEN
      x_concatenated_flex_values :=
        fnd_flex_server1.from_stringarray(p_numof_flex_values,
                                          p_flex_values,
                                          p_delimiter);
    ELSE
      x_concatenated_flex_values := '';
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      raise_application_error(-20001, 'SSV.concatenate_flex_values. SQLERRM : ' || Sqlerrm);
END concatenate_flex_values;

-- ==================================================
FUNCTION get_concatenated_value(p_delimiter IN VARCHAR2,
                                p_segment_count IN NUMBER,
                                p_segment1 IN VARCHAR2 DEFAULT NULL,
                                p_segment2 IN VARCHAR2 DEFAULT NULL,
                                p_segment3 IN VARCHAR2 DEFAULT NULL,
                                p_segment4 IN VARCHAR2 DEFAULT NULL,
                                p_segment5 IN VARCHAR2 DEFAULT NULL,
                                p_segment6 IN VARCHAR2 DEFAULT NULL,
                                p_segment7 IN VARCHAR2 DEFAULT NULL,
                                p_segment8 IN VARCHAR2 DEFAULT NULL,
                                p_segment9 IN VARCHAR2 DEFAULT NULL,
                                p_segment10 IN VARCHAR2 DEFAULT NULL,
                                p_segment11 IN VARCHAR2 DEFAULT NULL,
                                p_segment12 IN VARCHAR2 DEFAULT NULL,
                                p_segment13 IN VARCHAR2 DEFAULT NULL,
                                p_segment14 IN VARCHAR2 DEFAULT NULL,
                                p_segment15 IN VARCHAR2 DEFAULT NULL,
                                p_segment16 IN VARCHAR2 DEFAULT NULL,
                                p_segment17 IN VARCHAR2 DEFAULT NULL,
                                p_segment18 IN VARCHAR2 DEFAULT NULL,
                                p_segment19 IN VARCHAR2 DEFAULT NULL,
                                p_segment20 IN VARCHAR2 DEFAULT NULL,
                                p_segment21 IN VARCHAR2 DEFAULT NULL,
                                p_segment22 IN VARCHAR2 DEFAULT NULL,
                                p_segment23 IN VARCHAR2 DEFAULT NULL,
                                p_segment24 IN VARCHAR2 DEFAULT NULL,
                                p_segment25 IN VARCHAR2 DEFAULT NULL,
                                p_segment26 IN VARCHAR2 DEFAULT NULL,
                                p_segment27 IN VARCHAR2 DEFAULT NULL,
                                p_segment28 IN VARCHAR2 DEFAULT NULL,
                                p_segment29 IN VARCHAR2 DEFAULT NULL,
                                p_segment30 IN VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2
  IS
     l_flex_values        fnd_flex_server1.stringarray;
     l_concatenated_value VARCHAR2(32000);
BEGIN
   l_flex_values(1) := p_segment1;
   l_flex_values(2) := p_segment2;
   l_flex_values(3) := p_segment3;
   l_flex_values(4) := p_segment4;
   l_flex_values(5) := p_segment5;
   l_flex_values(6) := p_segment6;
   l_flex_values(7) := p_segment7;
   l_flex_values(8) := p_segment8;
   l_flex_values(9) := p_segment9;
   l_flex_values(10) := p_segment10;
   l_flex_values(11) := p_segment11;
   l_flex_values(12) := p_segment12;
   l_flex_values(13) := p_segment13;
   l_flex_values(14) := p_segment14;
   l_flex_values(15) := p_segment15;
   l_flex_values(16) := p_segment16;
   l_flex_values(17) := p_segment17;
   l_flex_values(18) := p_segment18;
   l_flex_values(19) := p_segment19;
   l_flex_values(20) := p_segment20;
   l_flex_values(21) := p_segment21;
   l_flex_values(22) := p_segment22;
   l_flex_values(23) := p_segment23;
   l_flex_values(24) := p_segment24;
   l_flex_values(25) := p_segment25;
   l_flex_values(26) := p_segment26;
   l_flex_values(27) := p_segment27;
   l_flex_values(28) := p_segment28;
   l_flex_values(29) := p_segment29;
   l_flex_values(30) := p_segment30;

   concatenate_flex_values(l_flex_values,
                           p_segment_count,
                           p_delimiter,
                           l_concatenated_value);

   RETURN(l_concatenated_value);
END get_concatenated_value;

-- ==================================================
PROCEDURE delete_dff_compiled(p_application_id             IN NUMBER,
                              p_descriptive_flexfield_name IN VARCHAR2)
  IS
     PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   DELETE FROM fnd_compiled_descriptive_flexs
     WHERE application_id = p_application_id
     AND descriptive_flexfield_name = p_descriptive_flexfield_name;

   COMMIT;
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
END delete_dff_compiled;

-- ==================================================
PROCEDURE raise_dff_compiled(p_application_id             IN NUMBER,
                             p_descriptive_flexfield_name IN VARCHAR2)
  IS
     l_parameters             wf_parameter_list_t := wf_parameter_list_t();

     l_application_short_name fnd_application.application_short_name%TYPE;
BEGIN
   SELECT 'AFFFSSVB.pls : $Revision: 120.13.12010000.23 $ : raise_dff_compiled' arcs_revision,
          application_short_name
     INTO g_arcs_revision,
          l_application_short_name
     FROM fnd_application
     WHERE application_id = p_application_id;

   wf_event.addparametertolist(p_name          => 'APPLICATION_SHORT_NAME',
                               p_value         => l_application_short_name,
                               p_parameterlist => l_parameters);

   wf_event.addparametertolist(p_name          => 'APPLICATION_ID',
                               p_value         => p_application_id,
                               p_parameterlist => l_parameters);

   wf_event.addparametertolist(p_name          => 'DESCRIPTIVE_FLEXFIELD_NAME',
                               p_value         => p_descriptive_flexfield_name,
                               p_parameterlist => l_parameters);

   BEGIN
      wf_event.raise(p_event_name => 'oracle.apps.fnd.flex.dff.compiled',
                     p_event_key  => (l_application_short_name || '.' ||
                                      p_descriptive_flexfield_name),
                     p_event_data => NULL,
                     p_parameters => l_parameters,
                     p_send_date  => Sysdate);
   EXCEPTION
      WHEN OTHERS THEN
         --
         -- If event fails, then remove the compiled data.
         -- This event is raised after the data were inserted into
         -- the compiled table.
         --
         -- Bug 5367119. Commenting following delete as we now raise the event
         -- before the data is inserted to compiled table.

         /* delete_dff_compiled(p_application_id,
                             p_descriptive_flexfield_name); */
         --
         -- Raise the exception.
         --
         FND_MESSAGE.set_name('FND', 'FLEX-COMPILE-WF_EVENT-ERROR');
         FND_MESSAGE.set_token('EVENT_NAME', 'oracle.apps.fnd.flex.dff.compiled');
         FND_MESSAGE.set_token('EVENT_KEY', l_application_short_name || '.' || p_descriptive_flexfield_name);
         FND_MESSAGE.set_token('ERROR', SQLERRM);
         FND_MESSAGE.RAISE_ERROR();
   END;

   -- No Exception handling here, let it go up to caller.

END raise_dff_compiled;

-- ==================================================
PROCEDURE delete_kff_structure_compiled(p_application_id IN NUMBER,
                                        p_id_flex_code   IN VARCHAR2,
                                        p_id_flex_num    IN NUMBER)
  IS
     PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   DELETE FROM fnd_compiled_id_flex_structs
     WHERE application_id = p_application_id
     AND id_flex_code = p_id_flex_code
     AND id_flex_num = p_id_flex_num;

   COMMIT;
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
END delete_kff_structure_compiled;

-- ==================================================
PROCEDURE raise_kff_structure_compiled(p_application_id IN NUMBER,
                                       p_id_flex_code   IN VARCHAR2,
                                       p_id_flex_num    IN NUMBER)
  IS
     l_parameters             wf_parameter_list_t := wf_parameter_list_t();

     l_application_short_name fnd_application.application_short_name%TYPE;
     l_id_flex_structure_code fnd_id_flex_structures.id_flex_structure_code%TYPE;
BEGIN
   SELECT 'AFFFSSVB.pls : $Revision: 120.13.12010000.23 $ : raise_kff_structure_compiled' arcs_revision,
          application_short_name
     INTO g_arcs_revision,
          l_application_short_name
     FROM fnd_application
     WHERE application_id = p_application_id;

   SELECT 'AFFFSSVB.pls : $Revision: 120.13.12010000.23 $ : raise_kff_structure_compiled' arcs_revision,
          id_flex_structure_code
     INTO g_arcs_revision,
          l_id_flex_structure_code
     FROM fnd_id_flex_structures
     WHERE application_id = p_application_id
     AND id_flex_code = p_id_flex_code
     AND id_flex_num = p_id_flex_num;

   wf_event.addparametertolist(p_name          => 'APPLICATION_SHORT_NAME',
                               p_value         => l_application_short_name,
                               p_parameterlist => l_parameters);

   wf_event.addparametertolist(p_name          => 'APPLICATION_ID',
                               p_value         => p_application_id,
                               p_parameterlist => l_parameters);

   wf_event.addparametertolist(p_name          => 'ID_FLEX_CODE',
                               p_value         => p_id_flex_code,
                               p_parameterlist => l_parameters);

   wf_event.addparametertolist(p_name          => 'ID_FLEX_STRUCTURE_CODE',
                               p_value         => l_id_flex_structure_code,
                               p_parameterlist => l_parameters);

   wf_event.addparametertolist(p_name          => 'ID_FLEX_NUM',
                               p_value         => p_id_flex_num,
                               p_parameterlist => l_parameters);

   BEGIN
      wf_event.raise(p_event_name => 'oracle.apps.fnd.flex.kff.structure.compiled',
                     p_event_key  => (l_application_short_name || '.' ||
                                      p_id_flex_code || '.' ||
                                      l_id_flex_structure_code),
                     p_event_data => NULL,
                     p_parameters => l_parameters,
                     p_send_date  => Sysdate);
   EXCEPTION
      WHEN OTHERS THEN
         --
         -- If event fails, then remove the compiled data.
         -- This event is raised after the data were inserted into
         -- the compiled table.
         --
         -- Bug 5367119. Commenting following delete as we now raise the event
         -- before the data is inserted to compiled table.

         /* delete_kff_structure_compiled(p_application_id,
                                       p_id_flex_code,
                                       p_id_flex_num); */
         --
         -- Raise the exception.
         --
         FND_MESSAGE.set_name('FND', 'FLEX-COMPILE-WF_EVENT-ERROR');
         FND_MESSAGE.set_token('EVENT_NAME', 'oracle.apps.fnd.flex.kff.structure.compiled');
         FND_MESSAGE.set_token('EVENT_KEY', l_application_short_name || '.' || p_id_flex_code || '.' || l_id_flex_structure_code);
         FND_MESSAGE.set_token('ERROR', SQLERRM);
         FND_MESSAGE.RAISE_ERROR();

   END;

   -- No Exception handling here, let it go up to caller.

END raise_kff_structure_compiled;

-- ==================================================
PROCEDURE raise_vst_updated(p_flex_value_set_id IN NUMBER)
  IS
     l_parameters wf_parameter_list_t := wf_parameter_list_t();

     l_flex_value_set_name fnd_flex_value_sets.flex_value_set_name%TYPE;
BEGIN
   SELECT flex_value_set_name
     INTO l_flex_value_set_name
     FROM fnd_flex_value_sets
     WHERE flex_value_set_id = p_flex_value_set_id;

   wf_event.addparametertolist(p_name          => 'FLEX_VALUE_SET_NAME',
                               p_value         => l_flex_value_set_name,
                               p_parameterlist => l_parameters);

   wf_event.addparametertolist(p_name          => 'FLEX_VALUE_SET_ID',
                               p_value         => p_flex_value_set_id,
                               p_parameterlist => l_parameters);

   wf_event.raise(p_event_name => 'oracle.apps.fnd.flex.vst.updated',
                  p_event_key  => l_flex_value_set_name,
                  p_event_data => NULL,
                  p_parameters => l_parameters,
                  p_send_date  => Sysdate);

   -- No Exception handling here, let it go up to caller.

END raise_vst_updated;

-- ==================================================
PROCEDURE get_kfvcct_record(p_application_id IN NUMBER,
                            p_id_flex_code   IN VARCHAR2,
                            px_kfvcct_record IN OUT nocopy kfvcct_record_type)
  IS
     l_kfvcct_key VARCHAR2(2000);
BEGIN
   l_kfvcct_key := (p_application_id || g_newline ||
                    p_id_flex_code);

   fnd_plsql_cache.custom_1to1_get_get_index(kfvcct_cache_controller,
                                             l_kfvcct_key,
                                             g_cache_index,
                                             g_cache_return_code);

   IF (g_cache_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
      px_kfvcct_record := kfvcct_cache_storage(g_cache_index);

    ELSE

      SELECT 'AFFFSSVB.pls : $Revision: 120.13.12010000.23 $ : get_kfvcct_record' arcs_revision,
             fif.table_application_id,
             fif.application_table_name,
             ft.table_id,
             fif.set_defining_column_name,
             fif.unique_id_column_name
        INTO g_arcs_revision,
             px_kfvcct_record.table_application_id,
             px_kfvcct_record.application_table_name,
             px_kfvcct_record.table_id,
             px_kfvcct_record.set_defining_column_name,
             px_kfvcct_record.unique_id_column_name
        FROM fnd_id_flexs fif, fnd_tables ft
       WHERE fif.application_id = p_application_id
         AND fif.id_flex_code = p_id_flex_code
         AND ft.application_id = fif.table_application_id
         AND ft.table_name = fif.application_table_name;

      fnd_plsql_cache.custom_1to1_get_put_index(kfvcct_cache_controller,
                                                l_kfvcct_key,
                                                g_cache_index);

      kfvcct_cache_storage(g_cache_index) := px_kfvcct_record;
   END IF;
END get_kfvcct_record;

-- ==================================================
PROCEDURE create_kfvssc_record(p_application_id IN NUMBER,
                               p_id_flex_code   IN VARCHAR2,
                               p_id_flex_num    IN NUMBER,
                               px_kfvssc_record IN OUT nocopy kfvssc_record_type)
  IS
     l_kfvcct_record  kfvcct_record_type;

     l_delimiter      fnd_id_flex_structures.concatenated_segment_delimiter%TYPE;

     l_compact_concat VARCHAR2(32000);
     l_padded_concat  VARCHAR2(32000);
     l_padding_type   VARCHAR2(30);
     l_padding_size   NUMBER;

     CURSOR kff_segments_cursor(p_application_id       IN NUMBER,
                                p_id_flex_code         IN VARCHAR2,
                                p_id_flex_num          IN NUMBER,
                                p_table_application_id IN NUMBER,
                                p_table_id             IN NUMBER)
       IS
          SELECT 'AFFFSSVB.pls : $Revision: 120.13.12010000.23 $ : create_kfvssc_record' arcs_revision,
                 fifsg.application_column_name,
                 ffvs.format_type    vset_format_type,
                 ffvs.maximum_size   vset_maximum_size,
                 ffvt.id_column_type vset_id_column_type,
                 ffvt.id_column_size vset_id_column_size,
                 fc.column_type      column_type,
                 fc.width            column_size
            FROM fnd_id_flex_segments fifsg, fnd_flex_value_sets ffvs,
                 fnd_columns fc, fnd_flex_validation_tables ffvt
           WHERE fifsg.application_id = p_application_id
             AND fifsg.id_flex_code = p_id_flex_code
             AND fifsg.id_flex_num = p_id_flex_num
             AND fifsg.enabled_flag = 'Y'
             AND fc.application_id = p_table_application_id
             AND fc.table_id = p_table_id
             AND fc.column_name = fifsg.application_column_name
            AND fifsg.flex_value_set_id = ffvs.flex_value_set_id(+)
            AND fifsg.flex_value_set_id = ffvt.flex_value_set_id(+)
           ORDER BY fifsg.segment_num, fifsg.segment_name;

BEGIN
   get_kfvcct_record(p_application_id,
                     p_id_flex_code,
                     l_kfvcct_record);

   SELECT 'AFFFSSVB.pls : $Revision: 120.13.12010000.23 $ : get_kfv_sql' arcs_revision,
          fifst.concatenated_segment_delimiter
     INTO g_arcs_revision,
          l_delimiter
     FROM fnd_id_flex_structures fifst
    WHERE fifst.application_id = p_application_id
      AND fifst.id_flex_code = p_id_flex_code
      AND fifst.id_flex_num = p_id_flex_num;

   l_compact_concat := NULL;
   l_padded_concat := NULL;

   FOR kff_segment IN kff_segments_cursor(p_application_id,
                                          p_id_flex_code,
                                          p_id_flex_num,
                                          l_kfvcct_record.table_application_id,
                                          l_kfvcct_record.table_id)
     LOOP
        -- Compact
        IF (l_compact_concat IS NOT NULL) THEN
           l_compact_concat := (l_compact_concat ||
                                ' || ''' ||
                                l_delimiter ||
                                ''' || ');
        END IF;

        l_compact_concat := l_compact_concat || kff_segment.application_column_name;


        -- Padded
        IF (l_padded_concat IS NOT NULL) THEN
           l_padded_concat := (l_padded_concat ||
                               ' || ''' ||
                               l_delimiter ||
                               ''' || ');
        END IF;

        IF (kff_segment.vset_format_type IS NULL) THEN
           -- There is no value set attached to segment, use column type and size
           IF (kff_segment.column_type = 'N') THEN
              l_padding_type := 'LPAD';
            ELSE
              l_padding_type := 'RPAD';
           END IF;
           l_padding_size := kff_segment.column_size;

         ELSE
           -- There is a value set attached to the segment
           IF (kff_segment.vset_id_column_type IS NULL) THEN
              -- This is a non-id value set (Not a table validated value set)
              IF (kff_segment.vset_format_type IN ('X', 'Y')) THEN
                 l_padding_type := 'RPAD';
                 l_padding_size := 20; -- ?? Should be 19.

               ELSIF (kff_segment.vset_format_type = 'N') THEN
                 l_padding_type := 'LPAD';
                 l_padding_size := kff_segment.vset_maximum_size ;

               ELSE
                 l_padding_type := 'RPAD';
                 l_padding_size := kff_segment.vset_maximum_size ;

              END IF;

            ELSE
              -- This is a id value set (A table validated value set)
              IF (kff_segment.vset_id_column_type = 'N') THEN
                 l_padding_type := 'LPAD';
               ELSE
                 l_padding_type := 'RPAD';
              END IF;
              l_padding_size := kff_segment.vset_id_column_size;
           END IF;
        END IF;

        l_padded_concat := (l_padded_concat || l_padding_type ||
                            '(NVL(' || kff_segment.application_column_name ||
                            ','' ''), ' || l_padding_size || ')');

     END LOOP;

   px_kfvssc_record.compact_sql := ('SELECT /* AFFFSSVB.pls : $Revision: 120.13.12010000.23 $ : get_kfv_concat_segs */ ' ||
                                    l_compact_concat ||
                                    ' FROM ' || l_kfvcct_record.application_table_name);

   px_kfvssc_record.padded_sql := ('SELECT /* AFFFSSVB.pls : $Revision: 120.13.12010000.23 $ : get_kfv_concat_segs */ ' ||
                                   l_padded_concat ||
                                   ' FROM ' || l_kfvcct_record.application_table_name);

   px_kfvssc_record.set_defining_column_name := l_kfvcct_record.set_defining_column_name;
   px_kfvssc_record.unique_id_column_name := l_kfvcct_record.unique_id_column_name;

END create_kfvssc_record;

-- ==================================================
PROCEDURE get_kfvssc_record(p_application_id IN NUMBER,
                            p_id_flex_code   IN VARCHAR2,
                            p_id_flex_num    IN NUMBER,
                            px_kfvssc_record IN OUT nocopy kfvssc_record_type)
  IS
     l_kfvssc_key  VARCHAR2(2000);
BEGIN
   l_kfvssc_key := (p_application_id || g_newline ||
                    p_id_flex_code || g_newline ||
                    p_id_flex_num);

   fnd_plsql_cache.custom_1to1_get_get_index(kfvssc_cache_controller,
                                             l_kfvssc_key,
                                             g_cache_index,
                                             g_cache_return_code);

   IF (g_cache_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
      px_kfvssc_record := kfvssc_cache_storage(g_cache_index);

    ELSE
      create_kfvssc_record(p_application_id,
                           p_id_flex_code,
                           p_id_flex_num,
                           px_kfvssc_record);

      fnd_plsql_cache.custom_1to1_get_put_index(kfvssc_cache_controller,
                                                l_kfvssc_key,
                                                g_cache_index);

      kfvssc_cache_storage(g_cache_index) := px_kfvssc_record;
   END IF;

END get_kfvssc_record;

-- ==================================================
FUNCTION get_kfv_concat_segs_by_ccid(p_concat_mode    IN VARCHAR2,
                                     p_application_id IN NUMBER,
                                     p_id_flex_code   IN VARCHAR2,
                                     p_id_flex_num    IN NUMBER,
                                     p_ccid           IN NUMBER,
                                     p_data_set       IN NUMBER DEFAULT NULL)
  RETURN VARCHAR2
  IS
     l_kfvssc_record kfvssc_record_type;

     l_data_set      NUMBER;
     l_sql           VARCHAR2(32000);
     l_result        VARCHAR2(32000);
BEGIN
   get_kfvssc_record(p_application_id,
                     p_id_flex_code,
                     p_id_flex_num,
                     l_kfvssc_record);

   IF (p_concat_mode = fnd_flex_server.CONCAT_MODE_PADDED) THEN
      l_sql := l_kfvssc_record.padded_sql;
    ELSE
      l_sql := l_kfvssc_record.compact_sql;
   END IF;

   IF (p_data_set IS NULL) THEN
      l_data_set := p_id_flex_num;
    ELSE
      l_data_set := p_data_set;
   END IF;

   l_sql := l_sql || ' WHERE ' || l_kfvssc_record.unique_id_column_name || ' = :b_unique_id_column';


   IF (l_kfvssc_record.set_defining_column_name IS NOT NULL) THEN
      l_sql := l_sql || ' AND ' || l_kfvssc_record.set_defining_column_name || ' = :b_set_defining_column';

      execute immediate l_sql INTO l_result using p_ccid, l_data_set;

    ELSE
      execute immediate l_sql INTO l_result using p_ccid;

   END IF;

   RETURN l_result;
END get_kfv_concat_segs_by_ccid;

-- ==================================================
FUNCTION get_kfv_concat_segs_by_rowid(p_concat_mode    IN VARCHAR2,
                                      p_application_id IN NUMBER,
                                      p_id_flex_code   IN VARCHAR2,
                                      p_id_flex_num    IN NUMBER,
                                      p_rowid          IN VARCHAR2)
  RETURN VARCHAR2
  IS
     l_kfvssc_record kfvssc_record_type;

     l_sql           VARCHAR2(32000);
     l_result        VARCHAR2(32000);
BEGIN
   get_kfvssc_record(p_application_id,
                     p_id_flex_code,
                     p_id_flex_num,
                     l_kfvssc_record);

   IF (p_concat_mode = fnd_flex_server.CONCAT_MODE_PADDED) THEN
      l_sql := l_kfvssc_record.padded_sql;
    ELSE
      l_sql := l_kfvssc_record.compact_sql;
   END IF;

   l_sql := l_sql || ' WHERE ROWID = :b_rowid';

   execute immediate l_sql INTO l_result using p_rowid;

   RETURN l_result;
END get_kfv_concat_segs_by_rowid;


-- ==============================================================
-- Bug 4725016 dbms_lock.allocate_unique issues a commit, this
-- is a problem during transactionis that are opening cursors
-- with 'select on update'. A commit issued at this point
-- can invalidate those types of cursors. We created a private
-- package that uses autonomous transaction that then calls
-- dbms_lock.allocate_unique. In this way the commit will not
-- affect the cursor.
-- ==============================================================
PROCEDURE autonomous_allocate_unique(p_lock_name    IN VARCHAR2,
                                     px_lock_handle IN OUT nocopy VARCHAR2)
  IS
     PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

   dbms_lock.allocate_unique(lockname        => p_lock_name,
                             lockhandle      => px_lock_handle,
                             expiration_secs => 1*24*60*60); -- 1 day.

  COMMIT;

END autonomous_allocate_unique;
-- ==================================================

PROCEDURE request_lock(p_lock_name    IN VARCHAR2,
                       px_lock_handle IN OUT nocopy VARCHAR2)
  IS
     l_lock_status INTEGER;
BEGIN

   autonomous_allocate_unique(p_lock_name, px_lock_handle);

   l_lock_status := dbms_lock.request(lockhandle        => px_lock_handle,
                                      lockmode          => dbms_lock.x_mode,
                                      timeout           => dbms_lock.maxwait,
                                      release_on_commit => FALSE);

   IF (l_lock_status <> 0) THEN
      raise_application_error(-20001,
                              'Unable to request lock ' || p_lock_name ||
                              '. dbms_lock.request() returned : ' ||
                              l_lock_status);
   END IF;
END request_lock;

-- ==================================================
PROCEDURE release_lock(p_lock_name   IN VARCHAR2,
                       p_lock_handle IN VARCHAR2)
  IS
     l_lock_status INTEGER;
BEGIN
   l_lock_status := dbms_lock.release(lockhandle => p_lock_handle);

   IF (l_lock_status <> 0) THEN
      raise_application_error(-20001,
                              'Unable to release lock ' || p_lock_name ||
                              '. dbms_lock.release() returned : ' ||
                              l_lock_status);
   END IF;
END release_lock;


-- ==================================================

  /*
     Function
        isFlexBindChar
     Returns
        Type    :       Boolean
        Desc    :       Returns TRUE if the char is a valid Flex Bind char
                        else returns FALSE
     Parameters
        p_char  :       Input character
     Scope
        Flex Internal
     Summary
        This function will accept a single character and test whether it is
        a valid Flex bind character or not

  */

  Function isFlexBindChar(p_char in Varchar2) return Boolean is
  Begin
    if instr(FLEX_BIND_CHARS, p_char) > 0 then
          return(TRUE);
        end if;
    return(FALSE);
  End;

  /*
     Procedure
        queue_non_forms_warnings
     Parameters
        p_context       : I :   The context information for which the
                                warning is being queued up
        p_bf_name       : I :   The BLOCK.FIELD name, which is to be
                                displayed in the warning
     Scope
        Flex Internal
     Summary
        This procedure will put the warning messages in the global array.
        Those would be later retrieved by get_nonforms_warnings()
  */
  procedure queue_non_forms_warnings (
                        p_warning_msg IN VARCHAR2
  ) is
  Begin
    g_non_forms_warnings_count := g_non_forms_warnings_count + 1;
    g_non_forms_warnings(g_non_forms_warnings_count) := substr(p_warning_msg, 1, 32000);
  End;

  /*
     Function
        get_bind_name
     Returns :
        Type                    :       Varchar2
        Description             :       Returns the actual Bind variable name
                                        without the prefix or :NULL suffix
     Parameters
        p_string        : I :           The input string to search for the bind
                                        variale name. Assumes the string starts
                                        with the bind variable
        p_bind_type     : I :           Bind variable type to search for. Valid                                         values are :
                                                FF_SEGMENT   -  $FLEX$
                                                FF_PROFILE   -  $PROFILE$
                                                FF_FIELD     -  BLOCK.FIELD
        p_length        : O :           OUT parameter. Returns the length of
                                        the entire bind variable i.e. like
                                        length of $FLEX$.ValueSetName:NULL,
                                        which the caller might skip for further
                                        processing.
     Scope
        Flex internal
     Summary
        This function returns the bind variable name. Assumes the input string
        to start with the bind variable. This function is invoked from
        parse_bf_binds. If you need to invoke this make sure the string starts
        with the bind variable.

        The following scenarios are handled:

                1. $FLEX$
                         - :$FLEX$.ValueSetName
                         - :$FLEX$.ValueSetName [.{ID} | {MEANING} | {DESCRIPTION} ][ :NULL ]
                2. $PROFILES$
                         - :$PROFILES$.ProfileName
                         - :$PROFILES$.ProfileName [ :NULL ]
                3. BLOCK.FIELD
                         - :BLOCK.FIELD
                         - :BLOCK.FIELD:NULL
     Test case link
        -- to be included
  */

  Function get_bind_name (
                   p_string IN VARCHAR2,
                   p_bind_type IN VARCHAR2,
                   p_bind_length OUT nocopy NUMBER
  ) return VARCHAR2 is
    in_squote                   Boolean := FALSE;
        in_dquote               Boolean := FALSE;
        v_bind_name             Varchar2(32000) := NULL;
        v_bind_length           Number := 0;
        v_indx                  Number := 0;
        v_str_len               Number := 0;
        this_char               Varchar2(10) := NULL;
        v_found_flag            Boolean := FALSE;
  Begin

    v_str_len := length(p_string);

    if p_bind_type = FF_SEGMENT then      -- Segment type i.e. $FLEX$ binds

      if substr(p_string, 1, FLEX_PREFIX_LEN) <> FLEX_PREFIX then

        v_bind_name := NULL;
        v_bind_length := -1;

        goto finish;

      end if;

      v_indx := FLEX_PREFIX_LEN + 1;

    elsif p_bind_type = FF_PROFILE then

      if substr(p_string, 1, PROFILE_PREFIX_LEN) <> PROFILE_PREFIX then

        v_bind_name := NULL;
        v_bind_length := -1;

        goto finish;

      end if;

      v_indx := PROFILE_PREFIX_LEN + 1;

    elsif p_bind_type = FF_FIELD then

      v_indx := 1;

    else

      v_bind_name := NULL;
      v_bind_length := -1;

      goto finish;

    end if;

    while ((NOT v_found_flag) AND (v_indx <= v_str_len))
    loop

          this_char := substr(p_string, v_indx, 1);

          /*
                  This assumes the only legal characters in a bind
          variable name are A-Z, a-z, 0-9, '_', '.', ':', '$',
          '#'.  This is covers legal names allowed by the
          database, forms and in c code.  A '.' is needed
          for :block.field references.  A ':' is need because
          it is allowable in profile names
          */

          if NOT isFlexBindChar(this_char) then

                v_found_flag := TRUE;
                v_indx := v_indx - 1;            -- Bind var ends a char before

          end if;

          v_indx := v_indx + 1;                  -- Increment current index

    end loop;

    v_indx := v_indx - 1;               -- Point v_indx to the end of bind var

    v_bind_length := v_indx;

    if p_bind_type = FF_SEGMENT then

          v_bind_name := substr(p_string, FLEX_PREFIX_LEN + 1, v_indx - FLEX_PREFIX_LEN);

    elsif p_bind_type = FF_PROFILE then

          v_bind_name := substr(p_string, PROFILE_PREFIX_LEN + 1, v_indx - PROFILE_PREFIX_LEN);

    else

          v_bind_name := substr(p_string, 1, v_indx);

    end if;

    if instr(upper(v_bind_name), ':NULL') > 0 then

          v_bind_name := substr(v_bind_name, 1, length(v_bind_name) - 5);

    end if;

    <<finish>>

        p_bind_length := v_bind_length;

        return(v_bind_name);

  End get_bind_name;

  /*
     Procedure
        parse_bind_names
     Parameters
        p_string        : I :   Input string to parse
                                queued up. Those will be retrieved by
                                get_nonforms_warnings()
        p_bind_names    : O :   An Array of B.F bind names found in p_string
        p_num_binds     : O :   Out parameter. Contains number of
                                BLOCK.FIELD references found in p_string
     Scope
        Flex Internal
     Summary
        This procedure parses an input string for BLOCK.FIELD references
        and queues warning messages in Global Array. Returns number of
        such references through p_num_binds
  */
  procedure parse_bind_names (
                        p_string IN VARCHAR2,
                        p_bind_names OUT nocopy table_of_varchar2_32000,
                        p_num_binds OUT nocopy NUMBER
        ) is

        v_bind_name             Varchar2(32000);
        v_bind_len              Number := 0;
        v_flag                  Boolean := FALSE;
        v_indx                  Number;
        v_str_len               Number;
        v_bind_count            Number := 0;
        v_bind_names            table_of_varchar2_32000;
        is_squote               Boolean := FALSE;
        is_dquote               Boolean := FALSE;
        is_bind                 Boolean := FALSE;
        this_char               Varchar2(10);
        region_start            Number;
        squote_ptr              Number;
        squote_ptr_end          Number;
        dquote_ptr              Number;
        dquote_ptr_end          Number;
        bind_ptr                Number;

  Begin

    v_str_len := nvl(length(p_string), 0);
    if v_str_len = 0 then
      v_bind_count := 0;
      goto finish;
    end if;
    region_start := 1;

    while (TRUE)
    loop

      is_squote := FALSE;
      is_dquote := FALSE;
      is_bind := FALSE;

      squote_ptr := INSTR(p_string, '''', region_start, 1);
      dquote_ptr := INSTR(p_string, '"', region_start, 1);
      bind_ptr   := INSTR(p_string, ':', region_start, 1);

      if bind_ptr = 0 then
        goto finish;                    -- No more binds ! Finish processing.
      end if;

      if squote_ptr = dquote_ptr then   -- i.e squote_ptr = dquote_ptr = 0
        is_bind := TRUE;
      else
        if squote_ptr = 0 then
          if bind_ptr < dquote_ptr then
            is_bind := TRUE;
          else
            is_dquote := TRUE;
          end if;
        elsif dquote_ptr = 0 then
          if bind_ptr < squote_ptr then
            is_bind := TRUE;
          else
            is_squote := TRUE;
          end if;
        else
          if squote_ptr = least(squote_ptr, dquote_ptr, bind_ptr) then
            is_squote := TRUE;
          elsif dquote_ptr = least(squote_ptr, dquote_ptr, bind_ptr) then
            is_dquote := TRUE;
          else
            is_bind := TRUE;
          end if;
        end if;
      end if;

      if is_squote then
        squote_ptr_end := INSTR(p_string, '''', squote_ptr + 1);
        if squote_ptr_end = 0 then                -- Unterminated quotes
          goto finish;
        else
          region_start := squote_ptr_end + 1;
          is_squote := FALSE;
        end if;
      end if;

      if is_dquote then
        dquote_ptr_end := INSTR(p_string, '"', dquote_ptr + 1);
        if dquote_ptr_end = 0 then                -- Unterminated quotes
          goto finish;
        else
          region_start := dquote_ptr_end + 1;
          is_dquote := FALSE;
        end if;
      end if;

      if is_bind then
        v_indx := bind_ptr + 1;
        v_bind_len := 0;
        if substr(p_string, v_indx, FLEX_PREFIX_LEN) = FLEX_PREFIX then
          v_bind_name := get_bind_name (
                  p_string => substr(p_string, v_indx, v_str_len - v_indx + 1),
                  p_bind_type => FF_SEGMENT,
                  p_bind_length => v_bind_len
                );
        elsif substr(p_string, v_indx, PROFILE_PREFIX_LEN) = PROFILE_PREFIX then
          v_bind_name := get_bind_name (
                  p_string => substr(p_string, v_indx, v_str_len - v_indx + 1),
                  p_bind_type => FF_PROFILE,
                  p_bind_length => v_bind_len
                );
        else                    -- Hmm a B.F reference ... process it ...
          v_bind_name := get_bind_name (
                 p_string => substr(p_string, v_indx, v_str_len - v_indx + 1),
                 p_bind_type => FF_FIELD,
                 p_bind_length => v_bind_len
                );
          v_bind_count := v_bind_count + 1;
          v_bind_names(v_bind_count) := v_bind_name;
        end if;
        if v_bind_len > 0 then
          region_start := v_indx + v_bind_len;
        else
          region_start := v_indx + 1;
        end if;
      end if;

    end loop;

    <<finish>>
      p_num_binds := v_bind_count;
      p_bind_names := v_bind_names;
  End parse_bind_names;

  function get_non_forms_warnings return Varchar2 is
    l_msg_string                Varchar2(32000);
  Begin
        return(l_msg_string);
  End get_non_forms_warnings;

-- ==================================================

PROCEDURE compute_non_forms_warnings_dff(p_application_id             IN NUMBER,
                                         p_descriptive_flexfield_name IN VARCHAR2,
                                         x_warning_count              OUT nocopy NUMBER)
IS
   l_non_forms_warn_table_type    table_of_varchar2_32000;
   l_application_short_name       fnd_application.application_short_name%TYPE;
   l_application_name             fnd_application_tl.application_name%TYPE;
   l_title                        fnd_descriptive_flexs_tl.title%TYPE;
   l_meaning                      fnd_lookup_values_vl.meaning%TYPE;
   l_value_set_name               fnd_flex_value_sets.flex_value_set_name%TYPE;
   l_srs_flag                     BOOLEAN;

   PROCEDURE compute_context_segment_warn(p_application_id in NUMBER)
   IS
      e_DefaultTypeField             EXCEPTION;
      e_DefaultTypeSQL               EXCEPTION;
      l_reference_field              fnd_descriptive_flexs.default_context_field_name%TYPE;
      l_validation_type              fnd_flex_value_sets.validation_type%TYPE;
      l_additional_where_clause      fnd_flex_validation_tables.additional_where_clause%TYPE;
      l_additional_quickpick_columns fnd_flex_validation_tables.additional_quickpick_columns%TYPE;
      l_num_binds                    NUMBER;
      l_segement_name                fnd_descr_flex_contexts.descriptive_flex_context_code%TYPE;
   BEGIN


       SELECT fnd_flex_value_sets.validation_type,fnd_flex_validation_tables.additional_where_clause,
              fnd_flex_validation_tables.additional_quickpick_columns,
              fnd_descriptive_flexs.default_context_field_name,fnd_flex_value_sets.flex_value_set_name
         INTO l_validation_type,l_additional_where_clause,l_additional_quickpick_columns,
              l_reference_field,l_value_set_name
         FROM fnd_flex_value_sets,fnd_descriptive_flexs,fnd_flex_validation_tables
        WHERE fnd_flex_value_sets.flex_value_set_id (+)= fnd_descriptive_flexs.context_override_value_set_id
          AND fnd_flex_value_sets.flex_value_set_id = fnd_flex_validation_tables.flex_value_set_id(+)
          AND fnd_descriptive_flexs.application_id = p_application_id
          AND fnd_descriptive_flexs.descriptive_flexfield_name = p_descriptive_flexfield_name;

       BEGIN -- Check context segment's value set's warnings

          IF l_validation_type  = 'F' THEN   -- If table validated valueset

           IF (l_additional_quickpick_columns is not null) THEN
              parse_bind_names(l_additional_quickpick_columns, l_non_forms_warn_table_type, l_num_binds);
              IF (l_num_binds > 0) THEN
                 FOR i IN 1 .. l_num_binds
                 LOOP
                   fnd_message.set_name('FND','FLEX-BLK_FLD_CTX_VSET_WARN_DFF');
                   fnd_message.set_token('VALUE_SET_NAME',l_value_set_name);
                   fnd_message.set_token('BLOCK_FIELD',l_non_forms_warn_table_type(i));
                   queue_non_forms_warnings(fnd_message.get());
                 END LOOP;
               END IF;
           END IF;

          IF (l_additional_where_clause is not null) THEN
             parse_bind_names(l_additional_where_clause, l_non_forms_warn_table_type, l_num_binds);
            IF (l_num_binds > 0) THEN
               FOR i IN 1 .. l_num_binds
               LOOP
                   fnd_message.set_name('FND','FLEX-BLK_FLD_CTX_VSET_WARN_DFF');
                   fnd_message.set_token('VALUE_SET_NAME',l_value_set_name);
                   fnd_message.set_token('BLOCK_FIELD',l_non_forms_warn_table_type(i));
                   queue_non_forms_warnings(fnd_message.get());
               END LOOP;
            END IF;
          END IF;
        END IF;
        IF l_reference_field IS NOT NULL THEN
           IF (INSTR(l_reference_field,':$PROFILES$.') <> 1) THEN
               fnd_message.set_name('FND','FLEX-CTX_REF_FIELD_WARN_DFF');
               fnd_message.set_token('REFERENCE_FIELD',SUBSTR(l_reference_field,INSTR(l_reference_field,':')+1));
               queue_non_forms_warnings(fnd_message.get());
           END IF;
         END IF;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
          NULL;
       END; -- Check context segment's value set's warnings
   END compute_context_segment_warn;

   PROCEDURE compute_context_warnings(p_context_code IN VARCHAR2)
   IS
    PROCEDURE compute_segment_warnings(p_application_column_name IN VARCHAR2)
    IS
      l_num_binds                    NUMBER;
      i                              NUMBER;
      l_format_type                  fnd_flex_value_sets.format_type%TYPE;
      l_validation_type              fnd_flex_value_sets.validation_type%TYPE;
      l_default_type                 fnd_descr_flex_column_usages.default_type%TYPE;
      l_default_value                fnd_descr_flex_column_usages.default_value%TYPE;
      l_value_set_id                 fnd_flex_value_sets.flex_value_set_id%TYPE;
      l_additional_where_clause      fnd_flex_validation_tables.additional_where_clause%TYPE;
      l_additional_quickpick_columns fnd_flex_validation_tables.additional_quickpick_columns%TYPE;
      l_segment_name                 fnd_descr_flex_column_usages.end_user_column_name%TYPE;
      e_DateTime                     EXCEPTION;
      e_PairOrSpecial                EXCEPTION;
      e_TableValidated               EXCEPTION;
      e_DefaultTypeField             EXCEPTION;
      e_DEfaultTypeSQL               EXCEPTION;
    BEGIN

      SELECT fnd_flex_value_sets.validation_type,fnd_flex_value_sets.format_type,
             fnd_descr_flex_column_usages.default_type,
             fnd_descr_flex_column_usages.default_value,fnd_flex_value_sets.flex_value_set_id,
             fnd_flex_value_sets.flex_value_set_name,fnd_descr_flex_column_usages.end_user_column_name
        INTO l_validation_type,l_format_type,l_default_type,l_default_value,l_value_set_id,
             l_value_set_name,l_segment_name
        FROM fnd_descr_flex_column_usages,fnd_flex_value_sets
       WHERE fnd_descr_flex_column_usages.flex_value_set_id = fnd_flex_value_sets.flex_value_set_id (+)
         AND fnd_descr_flex_column_usages.application_column_name = p_application_column_name
         AND fnd_descr_flex_column_usages.APPLICATION_ID = p_application_id
         AND fnd_descr_flex_column_usages.DESCRIPTIVE_FLEXFIELD_NAME = p_descriptive_flexfield_name
         AND fnd_descr_flex_column_usages.ENABLED_FLAG = 'Y'
         AND fnd_descr_flex_column_usages.DESCRIPTIVE_FLEX_CONTEXT_CODE = p_context_code;

       BEGIN -- Check segment's defaulting logic
          IF l_default_type = 'F' THEN  -- If default type is field
            RAISE e_DefaultTypeField;
          ELSIF l_default_type = 'S' THEN  -- If default type is SQL
            RAISE e_DefaultTypeSQL;
          END IF;
       EXCEPTION
         WHEN e_DefaultTypeField THEN
            IF l_srs_flag = FALSE THEN
               fnd_message.set_name('FND', 'FLEX-BLK_FLD_DEF_WARN_DFF');
               fnd_message.set_token('CONTEXT_CODE', p_context_code);
            ELSE
               fnd_message.set_name('FND', 'FLEX-BLK_FLD_DEF_WARN_SRS');
            END IF;
            fnd_message.set_token('SEGMENT_NAME', l_segment_name);
            fnd_message.set_token('BLOCK_FIELD', substr(l_default_value, instr(l_default_value, ':')+1));
            queue_non_forms_warnings(fnd_message.get());
         WHEN e_DefaultTypeSQL THEN
            parse_bind_names(l_default_value, l_non_forms_warn_table_type, l_num_binds);
            IF (l_num_binds > 0) then
                FOR i in 1 .. l_num_binds
                LOOP
                   IF l_srs_flag = FALSE THEN
                      fnd_message.set_name('FND','FLEX-BLK_FLD_DEF_WARN_DFF');
                      fnd_message.set_token('CONTEXT_CODE', p_context_code);
                   ELSE
                      fnd_message.set_name('FND','FLEX-BLK_FLD_DEF_WARN_SRS');
                   END IF;
                   fnd_message.set_token('SEGMENT_NAME',l_segment_name);
                   fnd_message.set_token('BLOCK_FIELD',l_non_forms_warn_table_type(i));
                   queue_non_forms_warnings(fnd_message.get());
                END LOOP;
            END IF;
       END; -- Check segment's defaulting logic

       BEGIN -- Check segment's value set's warnings
          IF l_validation_type IN ('P','U') THEN  -- If Pair or Special Validation Valueset
             RAISE e_PairOrSpecial;
          ELSIF l_validation_type  = 'F' THEN
            RAISE e_TableValidated;
          END IF;
          IF l_format_type IN ('D','T') THEN
            RAISE e_DateTime;
          END IF;
       EXCEPTION
         WHEN e_PairOrSpecial THEN
             IF l_srs_flag = FALSE THEN
                fnd_message.set_name('FND','FLEX-USER_EXIT_VSET_WARN_DFF');
                fnd_message.set_token('CONTEXT_CODE',p_context_code);
             ELSE
                fnd_message.set_name('FND','FLEX-USER_EXIT_VSET_WARN_SRS');
             END IF;
             fnd_message.set_token('SEGMENT_NAME',l_segment_name);
             fnd_message.set_token('VALUE_SET_NAME',l_value_set_name);
             SELECT meaning
               INTO l_meaning
               FROM fnd_lookup_values_vl
              WHERE lookup_type='SEG_VAL_TYPES'
                AND lookup_code = l_validation_type;
             fnd_message.set_token('VALIDATION_TYPE',l_meaning);
             queue_non_forms_warnings(fnd_message.get());
         WHEN e_TableValidated THEN
           SELECT additional_where_clause,additional_quickpick_columns
             INTO l_additional_where_clause,l_additional_quickpick_columns
             FROM fnd_flex_validation_tables
            WHERE flex_value_set_id = l_value_set_id;
           IF (l_additional_quickpick_columns is not null) THEN
             parse_bind_names(l_additional_quickpick_columns, l_non_forms_warn_table_type, l_num_binds);
              IF (l_num_binds > 0) THEN
                 FOR i IN 1 .. l_num_binds
                 LOOP
                   IF l_srs_flag = FALSE THEN
                      fnd_message.set_name('FND','FLEX-BLK_FLD_VSET_WARN_DFF');
                      fnd_message.set_token('CONTEXT_CODE',p_context_code);
                   ELSE
                      fnd_message.set_name('FND','FLEX-BLK_FLD_VSET_WARN_SRS');
                   END IF;
                   fnd_message.set_token('SEGMENT_NAME',l_segment_name);
                   fnd_message.set_token('VALUE_SET_NAME',l_value_set_name);
                   fnd_message.set_token('BLOCK_FIELD',l_non_forms_warn_table_type(i));
                   queue_non_forms_warnings(fnd_message.get());
                 END LOOP;
               END IF;
           END IF;

          IF (l_additional_where_clause is not null) THEN
             parse_bind_names(l_additional_where_clause, l_non_forms_warn_table_type, l_num_binds);

             IF (l_num_binds > 0) THEN
                 FOR i IN 1 .. l_num_binds
                 LOOP
                   IF l_srs_flag = FALSE THEN
                      fnd_message.set_name('FND','FLEX-BLK_FLD_VSET_WARN_DFF');
                      fnd_message.set_token('CONTEXT_CODE',p_context_code);
                   ELSE
                      fnd_message.set_name('FND','FLEX-BLK_FLD_VSET_WARN_SRS');
                   END IF;
                   fnd_message.set_token('SEGMENT_NAME',l_segment_name);
                   fnd_message.set_token('VALUE_SET_NAME',l_value_set_name);
                   fnd_message.set_token('BLOCK_FIELD',l_non_forms_warn_table_type(i));
                   queue_non_forms_warnings(fnd_message.get());
               END LOOP;
              END IF;
          END IF;
        WHEN e_DateTime THEN
           IF l_srs_flag = FALSE THEN
              fnd_message.set_name('FND','FLEX-DATE_VSET_WARN_DFF');
              fnd_message.set_token('CONTEXT_CODE',p_context_code);
           ELSE
              fnd_message.set_name('FND','FLEX-DATE_VSET_WARN_SRS');
           END IF;
           fnd_message.set_token('SEGMENT_NAME',l_segment_name);
           fnd_message.set_token('VALUE_SET_NAME',l_value_set_name);
           SELECT meaning
            INTO l_meaning
            FROM fnd_lookup_values_vl
           WHERE lookup_type='FIELD_TYPE'
             AND lookup_code = l_format_type;
           fnd_message.set_token('FORMAT_TYPE',l_meaning);
           queue_non_forms_warnings(fnd_message.get());
       END; -- Check segment's value set's warnings
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
         NULL;

    END compute_segment_warnings;
   BEGIN
    FOR v_EnabledSegments IN
        (SELECT application_column_name
          FROM fnd_descr_flex_column_usages
         WHERE application_id = p_application_id
           AND descriptive_flexfield_name = p_descriptive_flexfield_name
           AND descriptive_flex_context_code = p_context_code
           AND enabled_flag = 'Y')
       LOOP
         compute_segment_warnings(v_EnabledSegments.application_column_name);
       END LOOP;

  END compute_context_warnings;

BEGIN

   g_non_forms_warnings_count := 0;

   --
   -- Compute non_forms warnings for DFF
   --

  SELECT application_short_name, application_name
    INTO l_application_short_name, l_application_name
    FROM fnd_application_vl
   WHERE application_id = p_application_id;

  SELECT title
    INTO l_title
    FROM fnd_descriptive_flexs_vl
   WHERE application_id = p_application_id
   AND   descriptive_flexfield_name=p_descriptive_flexfield_name;

  IF p_descriptive_flexfield_name LIKE '$SRS$.%' THEN
     l_srs_flag := TRUE;
  ELSE
     l_srs_flag := FALSE;
  END IF;

  compute_context_segment_warn(p_application_id);

  FOR v_EnabledContext IN
   (SELECT descriptive_flex_context_code
     FROM fnd_descr_flex_contexts
    WHERE application_id = p_application_id
      AND descriptive_flexfield_name = p_descriptive_flexfield_name
      AND enabled_flag = 'Y')
  LOOP
    compute_context_warnings(v_EnabledContext.descriptive_flex_context_code);
  END LOOP;

   --
   -- Top Warning Message
   --

   IF (g_non_forms_warnings_count > 0) THEN
      IF (p_descriptive_flexfield_name LIKE '$SRS$.%') THEN
         fnd_message.set_name('FND', 'FLEX-FORMS_ONLY_WARN_SRS');
         fnd_message.set_token('PROGRAM_SHORT_NAME', Substr(p_descriptive_flexfield_name, Length('$SRS$.') + 1));
       ELSE
         fnd_message.set_name('FND', 'FLEX-FORMS_ONLY_WARN_DFF');
         fnd_message.set_token('TITLE', l_title);
      END IF;
      fnd_message.set_token('APPLICATION_NAME', l_application_name);
      fnd_message.set_token('WARNING_COUNT', g_non_forms_warnings_count);
      g_non_forms_warnings(0) := fnd_message.get();
   END IF;
   x_warning_count := g_non_forms_warnings_count;

END compute_non_forms_warnings_dff;

-- ==================================================

PROCEDURE compute_non_forms_warnings_kff(p_application_id  IN NUMBER,
                                         p_id_flex_code    IN VARCHAR2,
                                         p_id_flex_num     IN NUMBER,
                                         x_warning_count   OUT nocopy NUMBER)
  IS

   --
   -- Compute non_forms warnings for KFF
   --

    l_application_short_name          fnd_application.application_short_name%TYPE;
    l_application_name                fnd_application_tl.application_name%TYPE;
    l_id_flex_structure_code          fnd_id_flex_structures.id_flex_structure_code%TYPE;
    l_additional_quickpick_columns    fnd_flex_validation_tables.additional_quickpick_columns%TYPE;
    l_nsegments                       NUMBER;
    l_message                         VARCHAR2(1000);
    l_validation_type                 VARCHAR2(1000);
    l_format_type                     VARCHAR2(1000);
    l_flextype                        FND_FLEX_KEY_API.FLEXFIELD_TYPE;
    l_strctype                        FND_FLEX_KEY_API.STRUCTURE_TYPE;
    l_segtype                         FND_FLEX_KEY_API.SEGMENT_TYPE;
    l_seglist                         FND_FLEX_KEY_API.SEGMENT_LIST;
    l_vset_r                          FND_VSET.VALUESET_R;
    l_vset_dr                         FND_VSET.VALUESET_DR;

    PROCEDURE compute_segment_warnings (p_application_column_name IN VARCHAR2)
    IS
    l_table_of_varchar2_32000 table_of_varchar2_32000;
    l_num_binds NUMBER;
    i           NUMBER;
    BEGIN

        l_segtype  := fnd_flex_key_api.find_segment(l_flextype, l_strctype, p_application_column_name);

        if (l_segtype.value_set_id is not null) then

            fnd_vset.get_valueset(l_segtype.value_set_id, l_vset_r, l_vset_dr);
            if (l_vset_r.validation_type in ('P', 'U')) then
                fnd_message.set_name('FND', 'FLEX-USER_EXIT_VSET_WARN_KFF');
                fnd_message.set_token('SEGMENT_NAME', l_segtype.segment_name);
                fnd_message.set_token('VALUE_SET_NAME', l_vset_r.name);
                select meaning into l_validation_type
                    from fnd_lookup_values_vl
                    where lookup_type='SEG_VAL_TYPES'
                    and lookup_code=l_vset_r.validation_type;
                fnd_message.set_token('VALIDATION_TYPE', l_validation_type);
                l_message := FND_MESSAGE.get;
                queue_non_forms_warnings(l_message);
            end if;

            if (l_vset_dr.format_type in ('D', 'T')) then
                fnd_message.set_name('FND', 'FLEX-DATE_VSET_WARN_KFF');
                fnd_message.set_token('SEGMENT_NAME', l_segtype.segment_name);
                fnd_message.set_token('VALUE_SET_NAME', l_vset_r.name);
                select meaning into l_format_type
                    from fnd_lookup_values_vl
                    where lookup_type='FIELD_TYPE'
                    and lookup_code=l_vset_dr.format_type;
                fnd_message.set_token('FORMAT_TYPE', l_format_type);
                l_message := FND_MESSAGE.get;
                queue_non_forms_warnings(l_message);
            end if;

            if (l_vset_r.validation_type = 'F') then

                select additional_quickpick_columns into l_additional_quickpick_columns from fnd_flex_validation_tables where flex_value_set_id=l_segtype.value_set_id;

                if (l_additional_quickpick_columns is not null) then
                    parse_bind_names(l_additional_quickpick_columns, l_table_of_varchar2_32000, l_num_binds);
                    if (l_num_binds > 0) then
                        for i in 1 .. l_num_binds
                        loop
                            fnd_message.set_name('FND', 'FLEX-BLK_FLD_VSET_WARN_KFF');
                            fnd_message.set_token('SEGMENT_NAME', l_segtype.segment_name);
                            fnd_message.set_token('VALUE_SET_NAME', l_vset_r.name);
                            fnd_message.set_token('BLOCK_FIELD', l_table_of_varchar2_32000(i));
                            l_message := fnd_message.get;
                            queue_non_forms_warnings(l_message);
                        end loop;
                    end if;
                end if;

                if (l_vset_r.table_info.where_clause is not null) then
                    parse_bind_names(l_vset_r.table_info.where_clause, l_table_of_varchar2_32000, l_num_binds);
                    if (l_num_binds > 0) then
                        for i in 1 .. l_num_binds
                        loop
                            fnd_message.set_name('FND', 'FLEX-BLK_FLD_VSET_WARN_KFF');
                            fnd_message.set_token('SEGMENT_NAME', l_segtype.segment_name);
                            fnd_message.set_token('VALUE_SET_NAME', l_vset_r.name);
                            fnd_message.set_token('BLOCK_FIELD', l_table_of_varchar2_32000(i));
                            l_message := fnd_message.get;
                            queue_non_forms_warnings(l_message);
                        end loop;
                    end if;
                end if;

            end if;

        end if;

        if (l_segtype.default_type = 'S') then
            parse_bind_names(l_segtype.default_value, l_table_of_varchar2_32000, l_num_binds);
            if (l_num_binds > 0) then
                for i in 1 .. l_num_binds
                loop
                    fnd_message.set_name('FND', 'FLEX-BLK_FLD_DEF_WARN_KFF');
                    fnd_message.set_token('SEGMENT_NAME', l_segtype.segment_name);
                    fnd_message.set_token('BLOCK_FIELD', l_table_of_varchar2_32000(i));
                    l_message := fnd_message.get;
                    queue_non_forms_warnings(l_message);
                end loop;
            end if;
        end if;

        if (l_segtype.default_type = 'F') then
            fnd_message.set_name('FND', 'FLEX-BLK_FLD_DEF_WARN_KFF');
            fnd_message.set_token('SEGMENT_NAME', l_segtype.segment_name);
            fnd_message.set_token('BLOCK_FIELD', substr(l_segtype.default_value, instr(l_segtype.default_value, ':')+1));
            l_message := fnd_message.get;
            queue_non_forms_warnings(l_message);
        end if;

    EXCEPTION
    when others then
        null;

    END compute_segment_warnings;

BEGIN

    g_non_forms_warnings_count := 0;

    fnd_flex_key_api.set_session_mode(session_mode => 'customer_data');

    select application_short_name, application_name
        into l_application_short_name, l_application_name
        from fnd_application_vl
        where application_id=p_application_id;

    select id_flex_structure_code into l_id_flex_structure_code
        from fnd_id_flex_structures
        where application_id=p_application_id
        and id_flex_code=p_id_flex_code
        and id_flex_num=p_id_flex_num;

    l_flextype := fnd_flex_key_api.find_flexfield(appl_short_name => l_application_short_name, flex_code => p_id_flex_code);

    l_strctype := fnd_flex_key_api.find_structure(l_flextype, l_id_flex_structure_code);

    fnd_flex_key_api.get_segments(l_flextype, l_strctype, TRUE, l_nsegments, l_seglist);

    for i in 1..l_nsegments loop

        compute_segment_warnings(l_seglist(i));

    end loop;

   --
   -- Top Warning Message
   --
   IF (g_non_forms_warnings_count > 0) THEN
      fnd_message.set_name('FND', 'FLEX-FORMS_ONLY_WARN_KFF');
      fnd_message.set_token('STRUCTURE_CODE', l_id_flex_structure_code);
      fnd_message.set_token('TITLE', l_flextype.flex_title);
      fnd_message.set_token('APPLICATION_NAME', l_application_name);
      fnd_message.set_token('WARNING_COUNT', g_non_forms_warnings_count);
      g_non_forms_warnings(0) := fnd_message.get();
   END IF;
   x_warning_count := g_non_forms_warnings_count;

END compute_non_forms_warnings_kff;

-- ==================================================

FUNCTION get_non_forms_warning(p_warning_index IN NUMBER)
  RETURN VARCHAR2
  IS
BEGIN
   IF (p_warning_index >= 0 AND
       p_warning_index <= g_non_forms_warnings_count) THEN
      RETURN g_non_forms_warnings(p_warning_index);
    ELSE
      RETURN NULL;
   END IF;
END get_non_forms_warning;

BEGIN
   --
   -- Function calls for global initializations
   --
   g_newline := fnd_global.newline;
   blanks := ' ' || fnd_global.tab || fnd_global.newline;
   g_non_forms_warnings_count := 0;

   -- Initialize Caches

   fnd_plsql_cache.custom_1to1_init('SSV.VST',
                                    vst_cache_controller);
   vst_cache_storage.DELETE;

   fnd_plsql_cache.custom_1to1_init('SSV.KFVSSC',
                                    kfvssc_cache_controller);
   kfvssc_cache_storage.DELETE;

   fnd_plsql_cache.custom_1to1_init('SSV.KFVCCT',
                                    kfvcct_cache_controller);

   kfvcct_cache_storage.DELETE;

   fnd_plsql_cache.generic_1to1_init('SSV.VSC',
                                     vsc_cache_controller,
                                     vsc_cache_storage);

END fnd_flex_server;

/
