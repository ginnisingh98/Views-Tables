--------------------------------------------------------
--  DDL for Package Body FND_FLEX_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FLEX_EXT" AS
/* $Header: AFFFEXTB.pls 120.4.12010000.5 2014/08/12 14:43:58 hgeorgi ship $ */


  -- PRIVATE CONSTANTS
  --

  AOL_DATE_FMT          CONSTANT VARCHAR2(21) := 'YYYY/MM/DD HH24:MI:SS';
  OLD_DATE_FMT          CONSTANT VARCHAR2(11) := 'DD-MON-YYYY';
  OLD_DATE_LEN          CONSTANT NUMBER := 11;

  -- PRIVATE FUNCTIONS
  --
  FUNCTION read_displayedsegs(fstruct    IN  FND_FLEX_SERVER1.FlexStructId,
                              disp_segs  OUT nocopy FND_FLEX_SERVER1.DisplayedSegs)
                                                             RETURN BOOLEAN;

  FUNCTION is_allow_id_valuesets(i_application_short_name  IN  VARCHAR2,
                                 i_id_flex_code            IN  VARCHAR2,
                                 o_allow_id_value_sets     OUT nocopy BOOLEAN)
                                                             RETURN BOOLEAN;

  FUNCTION convert_vdate(date_string    IN  VARCHAR2,
                         date_value     OUT nocopy DATE) RETURN BOOLEAN;

  FUNCTION concat_segs(n_segs         IN  NUMBER,
                       segment_array  IN  SegmentArray,
                       delimiter      IN  VARCHAR2,
                       cat_segs       OUT nocopy VARCHAR2) RETURN BOOLEAN;

  FUNCTION output_string(s      IN  VARCHAR2,
                         s_out  OUT nocopy VARCHAR2) RETURN BOOLEAN;

  FUNCTION get_combination_id(application_short_name    IN  VARCHAR2,
                           key_flex_code        IN  VARCHAR2,
                           structure_number     IN  NUMBER,
                           validation_date      IN  DATE,
                           concat_segments      IN  VARCHAR2,
                           combination_id       OUT nocopy NUMBER,
                           data_set             IN  NUMBER DEFAULT -1)
            RETURN BOOLEAN;

  FUNCTION get_segments(application_short_name  IN  VARCHAR2,
                        key_flex_code           IN  VARCHAR2,
                        structure_number        IN  NUMBER,
                        combination_id          IN  NUMBER,
                        concat_segment_values   OUT nocopy VARCHAR2) RETURN BOOLEAN;

  FUNCTION to_segmentarray(catsegs              IN  VARCHAR2,
                           sepchar              IN  VARCHAR2,
                           segs                 OUT nocopy SegmentArray) RETURN NUMBER;

  FUNCTION from_segmentarray(nsegs              IN NUMBER,
                             segs               IN SegmentArray,
                             sepchar            IN VARCHAR2) RETURN VARCHAR2;

  -- PRIVATE GLOBAL VARIABLES
  --
  chr_newline  VARCHAR2(8); -- := fnd_global.newline;

  ext_globals_valid     BOOLEAN := FALSE;
  nvalidated            NUMBER;
  value_dvals           FND_FLEX_SERVER1.ValueArray;
  value_vals            FND_FLEX_SERVER1.ValueArray;
  value_ids             FND_FLEX_SERVER1.ValueIdArray;
  value_descs           FND_FLEX_SERVER1.ValueDescArray;
  value_desclens        FND_FLEX_SERVER1.NumberArray;
  cc_cols               FND_FLEX_SERVER1.TabColArray;
  cc_coltypes           FND_FLEX_SERVER1.CharArray;
  segtypes              FND_FLEX_SERVER1.SegFormats;
  disp_segs             FND_FLEX_SERVER1.DisplayedSegs;
  derv                  FND_FLEX_SERVER1.DerivedVals;
  tbl_derv              FND_FLEX_SERVER1.DerivedVals;
  drv_quals             FND_FLEX_SERVER1.Qualifiers;
  tbl_quals             FND_FLEX_SERVER1.Qualifiers;
  n_xcol_vals           NUMBER;
  xcol_vals             FND_FLEX_SERVER1.StringArray;
  new_comb              BOOLEAN;
  segment_codes         VARCHAR2(30);
  valid_stat    NUMBER;
  ccid_o        NUMBER;
  delim         VARCHAR2(1);
  err_segn      NUMBER;
  segcodes      VARCHAR2(30);
  FLEX_DELIMITER_ESCAPE CONSTANT VARCHAR2(1) := '\';

  -- -----------------------------------------------------------------------
  -- MESSAGING:
  -- -----------------------------------------------------------------------
  g_is_message_get  BOOLEAN := FALSE;
  g_is_failed       BOOLEAN := FALSE;
  g_encoded_message VARCHAR2(2000) := '';
  g_message         VARCHAR2(2000) := '';

  -- ==================================================
  -- CACHING
  -- ==================================================
  g_cache_return_code VARCHAR2(30);
  g_cache_key         VARCHAR2(2000);
  g_cache_value       fnd_plsql_cache.generic_cache_value_type;

  -- ======================================================================
  -- EXT : get_delimiter cache
  -- ======================================================================
  gdl_cache_controller      fnd_plsql_cache.cache_1to1_controller_type;
  gdl_cache_storage         fnd_plsql_cache.generic_cache_values_type;

  -- ======================================================================
  --  EXT ccid cache : IDC
  --
  -- Primary Key For IDC
  -- <application_short_name> || NEWLINE || <id_flex_code> || NEWLINE ||
  -- <id_flex_num> || NEWLINE || <ccid>
  --
  -- ======================================================================
  idc_cache_controller      fnd_plsql_cache.cache_1to1_controller_type;
  idc_cache_storage         fnd_plsql_cache.generic_cache_values_type;

  FUNCTION check_idc(p_appl_short_name IN VARCHAR2,
                     p_id_flex_code    IN VARCHAR2,
                     p_id_flex_num     IN NUMBER,
                     p_ccid            IN NUMBER,
                     x_delimiter       OUT nocopy VARCHAR2,
                     x_newline_comb    OUT nocopy VARCHAR2)
    RETURN VARCHAR2
    IS
  BEGIN
     g_cache_key := (p_appl_short_name || '.' ||
                     p_id_flex_code || '.' ||
                     p_id_flex_num || '.' ||
                     p_ccid);

     fnd_plsql_cache.generic_1to1_get_value(idc_cache_controller,
                                            idc_cache_storage,
                                            g_cache_key,
                                            g_cache_value,
                                            g_cache_return_code);

     IF (g_cache_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
        IF (g_cache_value.varchar2_1 IS NULL) THEN
           --
           -- No error message.
           --
           x_delimiter := g_cache_value.varchar2_2;
           x_newline_comb := g_cache_value.varchar2_3;
           RETURN(fnd_plsql_cache.CACHE_VALID);
         ELSE
           --
           -- Error message.
           --
           fnd_message.set_encoded(g_cache_value.varchar2_1);
           RETURN(fnd_plsql_cache.CACHE_INVALID);
        END IF;
     END IF;
     RETURN(g_cache_return_code);
  EXCEPTION
     WHEN OTHERS THEN
        RETURN(fnd_plsql_cache.CACHE_NOTFOUND);
  END check_idc;

  PROCEDURE update_idc(p_appl_short_name IN VARCHAR2,
                       p_id_flex_code    IN VARCHAR2,
                       p_id_flex_num     IN NUMBER,
                       p_ccid            IN NUMBER,
                       p_delimiter       IN VARCHAR2,
                       p_newline_comb    IN VARCHAR2,
                       p_is_valid        IN BOOLEAN)
    IS
       l_enc_err_msg VARCHAR2(2000) := NULL;
  BEGIN
     g_cache_key := (p_appl_short_name || '.' ||
                     p_id_flex_code || '.' ||
                     p_id_flex_num || '.' ||
                     p_ccid);

     IF (NOT p_is_valid) THEN
        l_enc_err_msg := fnd_message.get_encoded;
        fnd_message.set_encoded(l_enc_err_msg);
     END IF;

     fnd_plsql_cache.generic_cache_new_value
       (x_value      => g_cache_value,
        p_varchar2_1 => l_enc_err_msg,
        p_varchar2_2 => p_delimiter,
        p_varchar2_3 => p_newline_comb);

     fnd_plsql_cache.generic_1to1_put_value(idc_cache_controller,
                                            idc_cache_storage,
                                            g_cache_key,
                                            g_cache_value);

  EXCEPTION
     WHEN OTHERS THEN
        RETURN;
  END update_idc;

  PROCEDURE clear_ccid_cache
    IS
  BEGIN
     fnd_plsql_cache.generic_1to1_clear(idc_cache_controller,
                                        idc_cache_storage);
  END clear_ccid_cache;

  -- -----------------------------------------------------------------------
  -- MESSAGING:
  -- -----------------------------------------------------------------------

  PROCEDURE init_message
    IS
  BEGIN
     g_is_message_get  := FALSE;
     g_is_failed       := FALSE;
     g_encoded_message := '';
     g_message         := '';
  END init_message;

  PROCEDURE get_from_fnd_message
    IS
  BEGIN
     IF (NOT g_is_message_get) THEN
        --
        -- fnd_message.get_* removes message from stack.
        -- put it back.
        --
        g_encoded_message := fnd_message.get_encoded;
        fnd_message.set_encoded(g_encoded_message);

        g_message := fnd_message.get;
        fnd_message.set_encoded(g_encoded_message);

        g_is_message_get := TRUE;
     END IF;
  EXCEPTION
     WHEN OTHERS THEN
        NULL;
  END get_from_fnd_message;

  FUNCTION get_message RETURN VARCHAR2
    IS
  BEGIN
     IF (g_is_failed) THEN
        get_from_fnd_message;
        RETURN g_message;
     END IF;
     RETURN('');
  EXCEPTION
     WHEN OTHERS THEN
        NULL;
  END get_message;

  FUNCTION get_encoded_message RETURN VARCHAR2
    IS
  BEGIN
     IF (g_is_failed) THEN
        get_from_fnd_message;
        RETURN g_encoded_message;
     END IF;
     RETURN('');
  EXCEPTION
     WHEN OTHERS THEN
        NULL;
  END get_encoded_message;

  PROCEDURE set_failed
    IS
  BEGIN
     g_is_failed := TRUE;
  EXCEPTION
     WHEN OTHERS THEN
        NULL;
  END set_failed;


/* ----------------------------------------------------------------------- */
/*                              Public Functions                           */
/* ----------------------------------------------------------------------- */


/* ----------------------------------------------------------------------- */
/*      Concatenates segments from segment array to a string.              */
/*      Raises unhandled exception if any errors.                          */
/* ----------------------------------------------------------------------- */

  FUNCTION concatenate_segments(n_segments     IN  NUMBER,
                                segments       IN  SegmentArray,
                                delimiter      IN  VARCHAR2) RETURN VARCHAR2
    IS
       catsegs  VARCHAR2(2000);
  BEGIN
     init_message;
     IF (concat_segs(n_segments, segments, delimiter, catsegs)) then
        return(catsegs);
      ELSE
        set_failed;
        FND_MESSAGE.raise_error;
     end if;
  EXCEPTION
     WHEN OTHERS THEN
        set_failed;
        RAISE;
  END concatenate_segments;

/* ----------------------------------------------------------------------- */
/*      Breaks up concatenated segments into segment array.                */
/*      Returns number of segments found.                                  */
/*      Truncates segments longer than MAX_SEG_SIZE bytes.                 */
/*      Raises unhandled exception if any errors.                          */
/* ----------------------------------------------------------------------- */
  FUNCTION breakup_segments(concatenated_segs  IN  VARCHAR2,
                            delimiter          IN  VARCHAR2,
                            segments           OUT nocopy SegmentArray)
                                                        RETURN NUMBER IS
    n_segments   NUMBER;
  BEGIN
     init_message;

     n_segments := to_segmentarray(concatenated_segs, delimiter, segments);
     return(n_segments);
  EXCEPTION
     WHEN OTHERS THEN
        set_failed;
        RAISE;
  END breakup_segments;

/* ------------------------------------------------------------------------ */
/*      Gets the character used as the segment delimiter for the            */
/*      specified flexfield structure.                                      */
/*      Returns NULL and sets error on the server if structure not found.   */
/* ------------------------------------------------------------------------ */
  FUNCTION get_delimiter(application_short_name IN  VARCHAR2,
                         key_flex_code          IN  VARCHAR2,
                         structure_number       IN  NUMBER)
    RETURN VARCHAR2
    IS
       delim  VARCHAR2(1);
  BEGIN
     init_message;

     g_cache_key := (application_short_name || '.' || key_flex_code || '.' ||
                     structure_number);
     fnd_plsql_cache.generic_1to1_get_value(gdl_cache_controller,
                                            gdl_cache_storage,
                                            g_cache_key,
                                            g_cache_value,
                                            g_cache_return_code);
     IF (g_cache_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
        delim := g_cache_value.varchar2_1;
      ELSE
        SELECT s.concatenated_segment_delimiter
          INTO delim
          FROM fnd_id_flex_structures s, fnd_application a
          WHERE s.application_id = a.application_id
          AND s.id_flex_code = key_flex_code
          AND s.id_flex_num = structure_number
          AND a.application_short_name = get_delimiter.application_short_name;

        g_cache_value.varchar2_1 := delim;
        fnd_plsql_cache.generic_1to1_put_value(gdl_cache_controller,
                                               gdl_cache_storage,
                                               g_cache_key,
                                               g_cache_value);
     END IF;
     return(delim);
     --
     -- Fixed bug751140. table column name and argument name are same.
     -- (application_short_name) (We should use p_* style, but it is late.)
     --
  EXCEPTION
     WHEN NO_DATA_FOUND then
        FND_MESSAGE.set_name('FND', 'FLEX-CANNOT FIND STRUCT DEF');
        FND_MESSAGE.set_token('ROUTINE', 'FND_FLEX_EXT.GET_DELIMITER');
        FND_MESSAGE.set_token('APPL', application_short_name);
        FND_MESSAGE.set_token('CODE', key_flex_code);
        FND_MESSAGE.set_token('NUM', to_char(structure_number));
        set_failed;
        return(NULL);
     WHEN TOO_MANY_ROWS then
        FND_MESSAGE.set_name('FND', 'FLEX-DUPLICATE STRUCT DEF');
        FND_MESSAGE.set_token('ROUTINE', 'FND_FLEX_EXT.GET_DELIMITER');
        FND_MESSAGE.set_token('APPL', application_short_name);
        FND_MESSAGE.set_token('CODE', key_flex_code);
        FND_MESSAGE.set_token('NUM', to_char(structure_number));
        set_failed;
        return(NULL);
     WHEN OTHERS then
        FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
        FND_MESSAGE.set_token('MSG', 'EXT.get_delimiter() exception:  ' || SQLERRM);
        set_failed;
        return(NULL);
  END get_delimiter;

/* ------------------------------------------------------------------------ */
/*      NOTE:  This function provided primarily for interfacing to          */
/*      forms 4.5 client which cannot pass arrays or call server functions  */
/*      that have variable numbers of arguments.  Please call the           */
/*      get_combination_id() function if calling from the server.           */
/*                                                                          */
/*      Finds combination_id for given concatenated segment values.         */
/*      Pass in validation date in AOL_DATE_FMT format.                     */
/*      Combination is automatically created if it does not already exist.  */
/*      Commit the transaction soon after calling this function since       */
/*      if a combination is created it will prevent other users creating    */
/*      similar combinations on any flexfield until a commit is issued.     */
/*      Returns positive combination_id or 0 and sets error if invalid.     */
/* ------------------------------------------------------------------------ */
  FUNCTION get_ccid(application_short_name  IN  VARCHAR2,
                    key_flex_code           IN  VARCHAR2,
                    structure_number        IN  NUMBER,
                    validation_date         IN  VARCHAR2,
                    concatenated_segments   IN  VARCHAR2) RETURN NUMBER IS

  v_date        DATE;

BEGIN
   init_message;
    if(convert_vdate(validation_date, v_date) and
       get_combination_id(application_short_name, key_flex_code,
                structure_number, v_date, concatenated_segments, ccid_o)) then
      return(ccid_o);
    end if;
    set_failed;
    return(0);

  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG', 'get_ccid() exception:  ' || SQLERRM);
      set_failed;
      return(0);

  END get_ccid;

/* ------------------------------------------------------------------------ */
/*      Finds combination_id for given segment values.                      */
/*      If validation date is NULL checks all cross-validation rules.       */
/*      Returns TRUE if combination valid, or FALSE and sets error message  */
/*      on server using FND_MESSAGE if invalid.                             */
/* ------------------------------------------------------------------------ */
  FUNCTION get_combination_id(application_short_name    IN  VARCHAR2,
                           key_flex_code        IN  VARCHAR2,
                           structure_number     IN  NUMBER,
                           validation_date      IN  DATE,
                           concat_segments      IN  VARCHAR2,
                           combination_id       OUT nocopy NUMBER,
                           data_set             IN  NUMBER DEFAULT -1)
                                                            RETURN BOOLEAN IS
  BEGIN

--  Initialize messages, debugging, and number of sql strings
--
    init_message;
    ext_globals_valid := FALSE;
    if(FND_FLEX_SERVER1.init_globals = FALSE) THEN
       set_failed;
      return(FALSE);
    end if;

    FND_FLEX_SERVER.validation_engine(FND_GLOBAL.RESP_APPL_ID,
        FND_GLOBAL.RESP_ID, FND_GLOBAL.USER_ID,
        application_short_name, key_flex_code, NULL, structure_number,
        validation_date, NULL, data_set, 'V', 'FULL', 'Y', 'Y',
        'N', 'N', 'ALL', concat_segments, 'V', NULL, NULL, NULL,
        NULL, NULL, nvalidated, value_dvals, value_vals, value_ids,
        value_descs, value_desclens, cc_cols, cc_coltypes, segtypes,
        disp_segs, derv, tbl_derv, drv_quals, tbl_quals,
        n_xcol_vals, xcol_vals, delim, ccid_o, new_comb, valid_stat,
        segcodes, err_segn);
    if(valid_stat = FND_FLEX_SERVER1.VV_VALID) then
      combination_id := ccid_o;
      ext_globals_valid := TRUE;
      return(TRUE);
    end if;
    set_failed;
    return(FALSE);

  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG','get_combination_id() exception: '||SQLERRM);
      set_failed;
      return(FALSE);

  END get_combination_id;

/* ------------------------------------------------------------------------ */
/*      Overloaded version of above for use with individual segments.       */
/* ------------------------------------------------------------------------ */

  FUNCTION get_combination_id(application_short_name    IN  VARCHAR2,
                           key_flex_code        IN  VARCHAR2,
                           structure_number     IN  NUMBER,
                           validation_date      IN  DATE,
                           n_segments           IN  NUMBER,
                           segments             IN  SegmentArray,
                           combination_id       OUT nocopy NUMBER,
                           data_set             IN  NUMBER DEFAULT -1)
                                                            RETURN BOOLEAN IS
    sepchar     VARCHAR2(1);
    catsegs     VARCHAR2(2000);

  BEGIN

--  Concatenate the input segments, then send them to the other function.
--
     init_message;
     sepchar := get_delimiter(application_short_name, key_flex_code,
                             structure_number);
    if((sepchar is not null) and
       (concat_segs(n_segments, segments, sepchar, catsegs) = TRUE)) then
      return(get_combination_id(application_short_name, key_flex_code,
                         structure_number, validation_date, catsegs,
                         combination_id, data_set));
    end if;
    set_failed;
    return(FALSE);

  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG','get_combination_id() exception: '||SQLERRM);
      set_failed;
      return(FALSE);

  END get_combination_id;

/* ------------------------------------------------------------------------ */
/*      NOTE:  This function provided primarily for interfacing to          */
/*      forms 4.5 client which cannot pass arrays or call server functions  */
/*      that have variable numbers of arguments.  Please call the           */
/*      get_segments() function if calling from the server.                 */
/*                                                                          */
/*      Returns concatenated segment values string for the given            */
/*      combination id in the specified flexfield.                          */
/*      Caller must provide VARCHAR2(2000) storage for the returned string. */
/*      Returns NULL and sets error on the server if combination not found. */
/* ------------------------------------------------------------------------ */
  FUNCTION get_segs(application_short_name      IN  VARCHAR2,
                    key_flex_code               IN  VARCHAR2,
                    structure_number            IN  NUMBER,
                    combination_id              IN  NUMBER) RETURN VARCHAR2 IS

    cat_vals    VARCHAR2(2000);

  BEGIN
    if(get_segments(application_short_name, key_flex_code,
                structure_number, combination_id, cat_vals)) then
      return(cat_vals);
    end if;
    return(NULL);

--  Do not handle any exceptions here so that if user does not leave enough
--  room for the returned string, it will cause an exception in the user's
--  calling program rather than in here.
  END get_segs;

/* ------------------------------------------------------------------------ */
/*      Returns segment values for the given combination id in the          */
/*      specified flexfield.  Returns TRUE if combination found, otherwise  */
/*      returns FALSE and sets error using FND_MESSAGE on the server.       */
/*      Does not check value security rules.                                */
/*      Concatenated segment string is NULL if error.                       */
/* ------------------------------------------------------------------------ */

  FUNCTION get_segments(application_short_name  IN  VARCHAR2,
                        key_flex_code           IN  VARCHAR2,
                        structure_number        IN  NUMBER,
                        combination_id          IN  NUMBER,
                        concat_segment_values   OUT nocopy VARCHAR2)
                                                        RETURN BOOLEAN IS
    n_segs_out  NUMBER;
    segs_out    SegmentArray;
    catvals_out VARCHAR2(2000);

  BEGIN
     init_message;
--  Call version that returns segments in array, then concatenate them.
--
    if(get_segments(application_short_name, key_flex_code, structure_number,
                    combination_id, n_segs_out, segs_out) and
       concat_segs(n_segs_out, segs_out, delim, catvals_out)) then
       return(output_string(catvals_out, concat_segment_values));
    end if;
    set_failed;
    return(FALSE);

  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG', 'get_segments() exception:  ' || SQLERRM);
      set_failed;
      return(FALSE);

  END get_segments;

/* ------------------------------------------------------------------------ */
/*      Returns segment values for the given combination id in the          */
/*      specified flexfield.  Returns TRUE if combination found, otherwise  */
/*      returns FALSE and sets error using FND_MESSAGE on the server.       */
/*      n_segments is 0 and no elements of segments array are assigned if   */
/*      combination not found or on error.                                  */
/*      Does not check value security rules.                                */
/* ------------------------------------------------------------------------ */

  FUNCTION get_segments(application_short_name  IN  VARCHAR2,
                        key_flex_code           IN  VARCHAR2,
                        structure_number        IN  NUMBER,
                        combination_id          IN  NUMBER,
                        n_segments              OUT nocopy NUMBER,
                        segments                OUT nocopy SegmentArray,
                        data_set                IN  NUMBER DEFAULT -1)
                                                        RETURN BOOLEAN IS
    n_dispsegs  NUMBER;

    kff_id         FND_FLEX_SERVER1.FlexStructId;
    kff_info       FND_FLEX_SERVER1.FlexStructInfo;
    kff_cc         FND_FLEX_SERVER1.CombTblInfo;
    tmp_qualcols   FND_FLEX_SERVER1.TabColArray;
    tmp_xcolnames  FND_FLEX_SERVER1.StringArray;

    nfound         NUMBER;
    ccid           NUMBER;
    struct_def_val NUMBER;
    allow_id_vset  BOOLEAN;
    l_idc_code     VARCHAR2(10);
    l_newline_comb VARCHAR2(32000);
  BEGIN
   init_message;
--  Invalidate EXT globals, initialize no segs returned.
--  Initialize messages, debugging, and number of sql strings
--
    n_segments := 0;
    ext_globals_valid := FALSE;
    if(FND_FLEX_SERVER1.init_globals = FALSE) THEN
       GOTO label_failure;
    end if;

    --
    -- Check IDC first.
    --
    l_idc_code := check_idc(application_short_name,
                            key_flex_code,
                            structure_number,
                            combination_id,
                            delim,
                            l_newline_comb);
    IF (l_idc_code = fnd_plsql_cache.CACHE_VALID) THEN
       n_segments := breakup_segments(l_newline_comb,
                                      chr_newline,
                                      segments);
       GOTO label_success;
     ELSIF (l_idc_code = fnd_plsql_cache.CACHE_INVALID) THEN
       --
       -- message is set by check_idc;
       --
       GOTO label_failure;
    END IF;
    --
    -- l_idc_code is either fnd_plsql_cache.CACHE_NOTFOUND.
    -- continue on validation.
    --

-- Check whether this key flexfield allows id value sets or not.
-- If id valuesets are not allowed there is no need to validate everything.
-- for non-id value sets id and value are equal. So combination table contains
-- actual values.
--
    if(NOT is_allow_id_valuesets(application_short_name, key_flex_code,
                                 allow_id_vset)) THEN
       GOTO label_failure;
    end if;


    IF (NOT allow_id_vset) THEN

    /* This part returns the segment values for a given combination id
     * by directly reading them from the combinations table.  It does not
     * validate the values individually in order to save time.  It can only be
     * used with flexfields that do not allow "ID" type value sets where the
     * segment ID is the segment value.  Because it does not validate the
     * segments it does not return segment descriptions and other
     * segment based information.  This means it can only be used in
     * simplified APIs such as get_ccid() where only the segment values
     * are returned.  This function can not be used with value sets whose
     * displayed values depend on the user's NLS settings.  Presently
     * all value sets with translatable values (standard date and standard
     * time) are considered ID type value sets and therefore will be excluded
     * if the flexfield does not allow ID value sets.
     *
     * Also note that this function relies on the fact that retrieving the
     * segment values from an existing combination does not check expiration
     * or disabling on the combination or its values and does not check
     * value security.
     */

       IF (fnd_flex_server1.g_debug_level > 0) THEN
          FND_FLEX_SERVER1.add_debug('Non-ID value sets.Skip full validation');
       END IF;

       -- Check CCID.
       --
       IF ((combination_id IS NULL) OR (combination_id < 0)) THEN
          FND_MESSAGE.set_name('FND','FLEX-BAD CCID INPUT');
          FND_MESSAGE.set_token('CCID',to_char(combination_id));
          GOTO label_failure;
       END IF;

       -- Read structure and comb. table information.
       --
       IF (NOT FND_FLEX_SERVER2.get_keystruct
           (application_short_name, key_flex_code,
            NULL, structure_number, kff_id, kff_info, kff_cc)) THEN
          GOTO label_failure;
       END IF;

       -- Set global variable delim from kff structure.
       -- used in other procedures.
       --
       delim := kff_info.concatenated_segment_delimiter;

       -- Read segments information : column names, types etc.
       --
       IF (NOT FND_FLEX_SERVER2.get_struct_cols
           (kff_id,
            kff_cc.table_application_id, kff_cc.combination_table_id,
            nvalidated, cc_cols, cc_coltypes, segtypes)) THEN
          GOTO label_failure;
       END IF;

       /* Select from combination table.
        * No qualifiers, no extra columns, no where clause.
        * It is supposed to return seg_ids but since we ensured that they
        * are values no need to convert from id to value.
        * data_set is the structure_number.
        *
        * Only problem:
        * find_combination returns stored_values not displayed_values
        * However conversion to displayed values requires calling
        * validate_structure and we are trying to get rid of it.
        * Since we are guaranteed that flexfield doesn't use id value sets
        * this is not a problem at all. Only non-id value sets which have
        * displayed and stored value different are standard date v.sets.
        * For now, since client implements them as id-value sets they are
        * not problem here at all.
        */
       ccid := combination_id;
       /* Bug 1351313  */
       if (data_set <> -1)  THEN
         struct_def_val := data_set;
       else
         struct_def_val := structure_number;
       end if;
       nfound := FND_FLEX_SERVER.find_combination(struct_def_val,
                 kff_cc, nvalidated, cc_cols, cc_coltypes,
                 segtypes, 0, tmp_qualcols, 0, tmp_xcolnames, NULL, ccid,
                 value_ids, tbl_derv, drv_quals.sq_values, xcol_vals);

       if (nfound = 0) then
          FND_MESSAGE.set_name('FND', 'FLEX-COMBINATION NOT FOUND');
          FND_MESSAGE.set_token('CCID', combination_id);
          FND_MESSAGE.set_token('APNM', application_short_name);
          FND_MESSAGE.set_token('CODE', key_flex_code);
          FND_MESSAGE.set_token('NUM', structure_number);
       end if;
       if (nfound <> 1) THEN
          GOTO label_failure;
       end if;

       -- Convert from id's to displayed values, they are same.
       --
       for i in 1..nvalidated LOOP
         value_dvals(i) := value_ids(i);
       end loop;

       -- Get displayed segments information.
       --
       IF (NOT read_displayedsegs(kff_id, disp_segs)) THEN
          GOTO label_failure;
       END IF;

       valid_stat := FND_FLEX_SERVER1.VV_VALID;

    ELSE
      -- Allow id valuesets is 'Y'; do full validation.
      --
      -- Do not check security, qsecuity was X replaced it with N.
      --
        FND_FLEX_SERVER.validation_engine(FND_GLOBAL.RESP_APPL_ID,
            FND_GLOBAL.RESP_ID, FND_GLOBAL.USER_ID,
            application_short_name, key_flex_code, NULL, structure_number,
            NULL, NULL, -1, 'L', 'FULL', 'N', 'N', 'N', 'N',
            'ALL', NULL, 'V', NULL, NULL, NULL, NULL,
            combination_id, nvalidated, value_dvals, value_vals, value_ids,
            value_descs, value_desclens, cc_cols, cc_coltypes, segtypes,
            disp_segs, derv, tbl_derv, drv_quals, tbl_quals,
            n_xcol_vals, xcol_vals, delim, ccid_o, new_comb, valid_stat,
            segcodes, err_segn);
    END IF;

-- Return only the displayed segments if combination found
--
    l_newline_comb := '';
    if((valid_stat = FND_FLEX_SERVER1.VV_VALID) or
       (valid_stat = FND_FLEX_SERVER1.VV_SECURED)) then
       n_dispsegs := 0;
       for i in 1..nvalidated loop
          if(disp_segs.segflags(i)) THEN
             n_dispsegs := n_dispsegs + 1;
             segments(n_dispsegs) := SUBSTRB(value_dvals(i), 1, MAX_SEG_SIZE);
             l_newline_comb := (l_newline_comb ||
                                SUBSTRB(value_dvals(i), 1, MAX_SEG_SIZE) ||
                                chr_newline);
          end if;
       end loop;
       --
       -- Remove last NEWLINE
       --
       l_newline_comb := Substr(l_newline_comb, 1,
                                Length(l_newline_comb)-Length(chr_newline));
       n_segments := n_dispsegs;
       GOTO label_success;
     ELSE
       -- bug1020410
       GOTO label_failure;
    end if;

   <<label_success>>
     IF (l_idc_code IN (fnd_plsql_cache.CACHE_NOTFOUND)) THEN
        update_idc(application_short_name,
                   key_flex_code,
                   structure_number,
                   combination_id,
                   delim,
                   l_newline_comb,
                   TRUE);
     END IF;
     ext_globals_valid := TRUE;
     RETURN(TRUE);

   <<label_failure>>
     IF (l_idc_code IN (fnd_plsql_cache.CACHE_NOTFOUND)) THEN
        update_idc(application_short_name,
                   key_flex_code,
                   structure_number,
                   combination_id,
                   delim,
                   l_newline_comb,
                   FALSE);
     END IF;
     set_failed;
     RETURN(FALSE);

  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG', 'get_segments() exception:  ' || SQLERRM);
      set_failed;
      return(FALSE);

  END get_segments;

/* ------------------------------------------------------------------------ */
/*      Finds combination_id for given segment values.                      */
/*      If validation date is NULL checks all cross-validation rules.       */
/*      If combination doesn't exist, inserts combination, even if dynamic  */
/*       insert is disabled                                                 */
/*      Returns TRUE if combination valid, or FALSE and sets error message  */
/*      on server using FND_MESSAGE if invalid.                             */
/* ------------------------------------------------------------------------ */
  FUNCTION get_comb_id_allow_insert(application_short_name    IN  VARCHAR2,
                           key_flex_code        IN  VARCHAR2,
                           structure_number     IN  NUMBER,
                           validation_date      IN  DATE,
                           n_segments           IN  NUMBER,
                           segments             IN  SegmentArray,
                           combination_id       OUT nocopy NUMBER,
                           data_set             IN  NUMBER DEFAULT -1)
                                                            RETURN BOOLEAN IS
    sepchar     VARCHAR2(1);
    catsegs     VARCHAR2(2000);

  BEGIN

--  Concatenate the input segments, then send them to the validation engine.
--
     init_message;
     sepchar := get_delimiter(application_short_name, key_flex_code,
                             structure_number);
    if ((sepchar is not null) and
       (concat_segs(n_segments, segments, sepchar, catsegs) = TRUE)) then

    ext_globals_valid := FALSE;
    if(FND_FLEX_SERVER1.init_globals = FALSE) THEN
       set_failed;
      return(FALSE);
    end if;

    FND_FLEX_SERVER.validation_engine(FND_GLOBAL.RESP_APPL_ID,
        FND_GLOBAL.RESP_ID, FND_GLOBAL.USER_ID,
        application_short_name, key_flex_code, NULL, structure_number,
        validation_date, NULL, data_set, 'V', 'FULL', 'F', 'Y',
        'N', 'N', 'ALL', catsegs, 'V', NULL, NULL, NULL,
        NULL, NULL, nvalidated, value_dvals, value_vals, value_ids,
        value_descs, value_desclens, cc_cols, cc_coltypes, segtypes,
        disp_segs, derv, tbl_derv, drv_quals, tbl_quals,
        n_xcol_vals, xcol_vals, delim, ccid_o, new_comb, valid_stat,
        segcodes, err_segn);
    if(valid_stat = FND_FLEX_SERVER1.VV_VALID) then
      combination_id := ccid_o;
      ext_globals_valid := TRUE;
      return(TRUE);
    end if;

    end if;
    set_failed;
    return(FALSE);

  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG','get_combination_id() exception: '||SQLERRM);
      set_failed;
      return(FALSE);

  END get_comb_id_allow_insert;



/* ------------------------------------------------------------------------ */
/*                      PRIVATE FUNCTIONS                                   */
/* ------------------------------------------------------------------------ */

/* ------------------------------------------------------------------------ */
/* This function is copied from SV2[S|B].get_struct_cols()                  */
/* Gets the displayed information.                                          */
/* ------------------------------------------------------------------------ */
  FUNCTION read_displayedsegs(fstruct    IN  FND_FLEX_SERVER1.FlexStructId,
                              disp_segs  OUT nocopy FND_FLEX_SERVER1.DisplayedSegs)
                                                            RETURN BOOLEAN IS
    ncols  NUMBER;

    CURSOR Key_column_cursor(keystruct  IN FND_FLEX_SERVER1.FlexStructId) IS
        SELECT g.display_flag
        FROM  fnd_id_flex_segments g
        WHERE g.application_id = keystruct.application_id
          AND g.id_flex_code = keystruct.id_flex_code
          AND g.id_flex_num = keystruct.id_flex_num
          AND g.enabled_flag = 'Y'
        ORDER BY g.segment_num;

  BEGIN
    ncols := 0;

-- Assumes we are looking at a key flexfield
--
    for seg in Key_column_cursor(fstruct) loop
      ncols := ncols + 1;
      disp_segs.segflags(ncols) := (seg.display_flag = 'Y');
    end loop;

    if(ncols < 1) then
      FND_MESSAGE.set_name('FND', 'FLEX-CANT FIND SEGMENTS');
      FND_MESSAGE.set_token('ROUTINE', 'FND_FLEX_EXT.read_displayedsegs()');
      FND_MESSAGE.set_token('APPID', to_char(fstruct.application_id));
      FND_MESSAGE.set_token('CODE', fstruct.id_flex_code);
      FND_MESSAGE.set_token('NUM', to_char(fstruct.id_flex_num));
      return(FALSE);
    end if;

    disp_segs.n_segflags := ncols;

    return(TRUE);

  EXCEPTION
    WHEN OTHERS then
     FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
     FND_MESSAGE.set_token('MSG', 'read_displayedsegs() exception: '||SQLERRM);
     return(FALSE);

  END read_displayedsegs;

/* ------------------------------------------------------------------------ */
/*  Checks whether key flexfield allows id value sets or not.               */
/*  Designed to improve get_segments() performance.                         */
/* ------------------------------------------------------------------------ */

  FUNCTION is_allow_id_valuesets(i_application_short_name  IN  VARCHAR2,
                                 i_id_flex_code            IN  VARCHAR2,
                                 o_allow_id_value_sets     OUT nocopy BOOLEAN)
                                                             RETURN BOOLEAN IS
    temp VARCHAR2(1);

  BEGIN

    SELECT allow_id_valuesets INTO temp
      FROM fnd_id_flexs idf, fnd_application a
     WHERE a.application_short_name = i_application_short_name
       AND a.application_id = idf.application_id
       AND idf.id_flex_code = i_id_flex_code;

    if(temp = 'Y') then
     o_allow_id_value_sets := true;
    else
     o_allow_id_value_sets := false;
    end if;

    RETURN(true);

  EXCEPTION
    WHEN NO_DATA_FOUND then
      FND_MESSAGE.set_name('FND', 'FLEX-CANNOT FIND STRUCT DEF');
      FND_MESSAGE.set_token('ROUTINE', 'FND_FLEX_EXT.is_allow_id_value_sets');
      FND_MESSAGE.set_token('APPL', i_application_short_name);
      FND_MESSAGE.set_token('CODE', i_id_flex_code);
      FND_MESSAGE.set_token('NUM', null);
      return(FALSE);
    WHEN TOO_MANY_ROWS then
      FND_MESSAGE.set_name('FND', 'FLEX-DUPLICATE STRUCT DEF');
      FND_MESSAGE.set_token('ROUTINE', 'FND_FLEX_EXT.is_allow_id_value_sets');
      FND_MESSAGE.set_token('APPL', i_application_short_name);
      FND_MESSAGE.set_token('CODE', i_id_flex_code);
      FND_MESSAGE.set_token('NUM', null);
      return(FALSE);
     WHEN others THEN
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG','is_allow_valuesets() exception: '||SQLERRM);
      return(false);

  END is_allow_id_valuesets;

/* ------------------------------------------------------------------------ */
/*      Converts text format of validation date to a date.                  */
/*      Sets error message and returns FALSE if format error.               */
/* ------------------------------------------------------------------------ */

  FUNCTION convert_vdate(date_string    IN  VARCHAR2,
                         date_value     OUT nocopy DATE) RETURN BOOLEAN IS
  BEGIN

    if(LENGTH(date_string) = OLD_DATE_LEN) then
      date_value := to_date(date_string, OLD_DATE_FMT);
    else
      date_value := to_date(date_string, AOL_DATE_FMT);
    end if;
    return(TRUE);

  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-BAD VDATE STRING');
      return(FALSE);

  END convert_vdate;


/* ------------------------------------------------------------------------ */
/*      Concatenates segments input by user.                                */
/*      Returns FALSE and sets error message if user input array is bad.    */
/* ------------------------------------------------------------------------ */

  FUNCTION concat_segs(n_segs         IN  NUMBER,
                       segment_array  IN  SegmentArray,
                       delimiter      IN  VARCHAR2,
                       cat_segs       OUT nocopy VARCHAR2) RETURN BOOLEAN IS

  BEGIN

    if(n_segs = 1) then
      cat_segs := segment_array(1);
    else
      cat_segs := from_segmentarray(n_segs, segment_array, delimiter);
    end if;
    return(TRUE);

  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-BAD SEGMENT ARRAY');
      return(FALSE);

  END concat_segs;

/* ------------------------------------------------------------------------ */
/*      Copies varchar2 string to output and traps exception raised if      */
/*      the user's output string buffer is not big enough to hold the       */
/*      input string.                                                       */
/*      Returns FALSE and sets FND_MESSAGE on error.                        */
/* ------------------------------------------------------------------------ */
  FUNCTION output_string(s      IN  VARCHAR2,
                         s_out  OUT nocopy VARCHAR2) RETURN BOOLEAN IS
  BEGIN
    s_out := s;
    return(TRUE);
  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name(NULL, 'FLEX-BUFFER TOO SMALL');
      FND_MESSAGE.set_token('EXCEPTION', SQLERRM);
      return(FALSE);
  END output_string;

/* ----------------------------------------------------------------------- */
/*               Converts concatenated segments to segment array           */
/*      Segment array is 1-based containing entries for 1 <= i <= nsegs    */
/*      Copied from FND_FLEX_SERVER1.to_stringarray. Uses SegmentArray     */
/*      instead of StringArray.                                            */
/* ----------------------------------------------------------------------- */

  FUNCTION to_segmentarray(catsegs IN  VARCHAR2,
                           sepchar IN  VARCHAR2,
                           segs    OUT nocopy SegmentArray)
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
                                'EXT.to_segmentarray. Invalid delimiter:''' ||
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

     /* Bug 8679638. Put a condition so that Un-escaping
        logic is not done for single segment flexfields */
     IF (l_segnum = 1) THEN
         segs(1) := catsegs;
     END IF;
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
        raise_application_error(-20001, 'EXT.to_segmentarray. SQLERRM : ' ||
                                Sqlerrm);
  END to_segmentarray;

/* ----------------------------------------------------------------------- */
/*               Converts segment array to concatenated segments           */
/*      Segment array is 1-based containing entries for 1 <= i <= nsegs    */
/*      Copied from FND_FLEX_SERVER1.from_stringarray. Uses SegmentArray   */
/*      instead of StringArray.                                            */
/* ----------------------------------------------------------------------- */
  FUNCTION from_segmentarray(nsegs   IN NUMBER,
                             segs    IN SegmentArray,
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
        fnd_flex_server1.add_debug('BEGIN EXT.from_segmentarray()');
     END IF;
     --
     -- Make sure delimiter is valid.
     --
     IF ((l_delimiter IS NULL) OR (l_delimiter = FLEX_DELIMITER_ESCAPE)) THEN
        raise_application_error(-20001,
                                'EXT.from_segmentarray. Invalid delimiter:''' ||
                                Nvl(sepchar, '<NULL>') || '''');
     END IF;

     --
     -- Make sure array size is valid.
     --
     IF ((nsegs IS NULL) OR (nsegs < 1)) THEN
        raise_application_error(-20001,
                                'EXT.from_segmentarray. For specified context there are ''' ||
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
          fnd_flex_server1.add_debug('END EXT.from_segmentarray()');
       END IF;
       RETURN(l_return);
  EXCEPTION
     WHEN OTHERS THEN
        IF (fnd_flex_server1.g_debug_level > 0) THEN
           fnd_flex_server1.add_debug('EXCEPTION EXT.from_segmentarray()');
        END IF;
        raise_application_error(-20001, 'EXT.from_segmentarray. SQLERRM : ' || Sqlerrm);
  END from_segmentarray;


  -- Bug 14250283 new procedure to override Right Justify Zero Fill
  -- as defined in ValueSet. When validation routines are called
  -- we may or may not want to throw error for segment values
  -- based on right zero fill justified definition. Example:
  -- Valide Segment value = 0000
  -- The value 0 is passed in to be validated.
  -- We can give error saying 0 is invalid, or if zero fill is defined,
  -- we can do the following. We can take the
  -- value passed in 0 and automatically fill in the rest of the 0's
  -- and return valid value. Sometimes users do not want to zero
  -- fill a value, eventhough it is defined in the valueset.
  -- To override zero fill as defined in vset, call this procedure
  -- set_zero_fill and pass 'N' or 'Y'.
  -- This procedure should be called
  -- just before calling any of the validation procedures such as
  -- FND_FLEX_EXT.GET_CCID().
PROCEDURE set_zero_fill(p_zero_fill IN VARCHAR2)
  IS
BEGIN
      fnd_flex_server1.zero_fill_override:= p_zero_fill;
end set_zero_fill;


/* ------------------------------------------------------------------------ */

BEGIN
   chr_newline  := fnd_global.newline;

   fnd_plsql_cache.generic_1to1_init('EXT.IDC',
                                     idc_cache_controller,
                                     idc_cache_storage);

   fnd_plsql_cache.generic_1to1_init('EXT.GDL',
                                     gdl_cache_controller,
                                     gdl_cache_storage);

END fnd_flex_ext;

/
