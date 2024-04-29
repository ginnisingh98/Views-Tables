--------------------------------------------------------
--  DDL for Package Body FND_FLEX_SERVER4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FLEX_SERVER4" AS
/* $Header: AFFFSV4B.pls 120.6.12010000.8 2017/02/13 22:33:46 tebarnes ship $ */



  --------
  -- PRIVATE TYPES
  --

  TYPE ValidatedSegmentArray IS RECORD
       (nvalidated      NUMBER,
        segstats        VARCHAR2(201),
        segfmts         FND_FLEX_SERVER1.SegFormats,
        segcols         FND_FLEX_SERVER1.TabColArray,
        segcoltypes     FND_FLEX_SERVER1.CharArray,
        dispvals        FND_FLEX_SERVER1.ValueArray,
        vals            FND_FLEX_SERVER1.ValueArray,
        ids             FND_FLEX_SERVER1.ValueIdArray,
        descs           FND_FLEX_SERVER1.ValueDescArray,
        catdesclens     FND_FLEX_SERVER1.NumberArray,
        dispsegs        FND_FLEX_SERVER1.DisplayedSegs);

  ------------
  -- PRIVATE CONSTANTS
  --

  MAX_NSEGS             CONSTANT NUMBER := 200;
  MAX_CATSEG_LEN        CONSTANT NUMBER := 700;

  -- ==================================================
  -- CACHING
  -- ==================================================

  g_cache_return_code VARCHAR2(30);
  g_cache_key         VARCHAR2(2000);
  g_cache_value       fnd_plsql_cache.generic_cache_value_type;

  -- --------------------------------------------------
  -- cxc : Context Cache
  -- --------------------------------------------------
  cxc_cache_controller      fnd_plsql_cache.cache_1to1_controller_type;
  cxc_cache_storage         fnd_plsql_cache.generic_cache_values_type;

  -- --------------------------------------------------
  -- gcc : Global Context Cache
  -- --------------------------------------------------
  gcc_cache_controller      fnd_plsql_cache.cache_1to1_controller_type;
  gcc_cache_storage         fnd_plsql_cache.generic_cache_values_type;

/* -------------------------------------------------------------------- */
/*                        Private global variables                      */
/* -------------------------------------------------------------------- */

/* -------------------------------------------------------------------- */
/*                        Private definitions                           */
/* -------------------------------------------------------------------- */

  FUNCTION find_descsegs(dflex_info IN  FND_FLEX_SERVER1.DescFlexInfo,
                         row_id     IN  ROWID,
                         alt_table  IN  VARCHAR2,
                         data_field IN  VARCHAR2,
                         vflags     IN  FND_FLEX_SERVER1.ValueValidationFlags,
                         nsegs_out  OUT nocopy NUMBER,
                         segs_out   OUT nocopy FND_FLEX_SERVER1.StringArray)
                                                        RETURN BOOLEAN;

  FUNCTION read_datafield(dflex_info IN  FND_FLEX_SERVER1.DescFlexInfo,
                          row_id     IN  ROWID,
                          table_name IN  VARCHAR2,
                          datafield  IN  VARCHAR2,
                          nsegs      OUT nocopy NUMBER,
                          segs       OUT nocopy FND_FLEX_SERVER1.StringArray)
                                                           RETURN BOOLEAN;

  FUNCTION read_segment_cols(dflex_info IN  FND_FLEX_SERVER1.DescFlexInfo,
                        row_id     IN  ROWID,
                        table_name IN  VARCHAR2,
                        vflags     IN  FND_FLEX_SERVER1.ValueValidationFlags,
                        nsegs      OUT nocopy NUMBER,
                        segs       OUT nocopy FND_FLEX_SERVER1.StringArray)
                                                        RETURN BOOLEAN;

  FUNCTION get_desc_cols(dff_info   IN  FND_FLEX_SERVER1.DescFlexInfo,
                         context    IN  VARCHAR2,
                         vflags     IN  FND_FLEX_SERVER1.ValueValidationFlags,
                         contextn   OUT nocopy NUMBER,
                         ncols      OUT nocopy NUMBER,
                         cols       OUT nocopy FND_FLEX_SERVER1.TabColArray,
                         coltypes   OUT nocopy FND_FLEX_SERVER1.CharArray,
                         segfmts    OUT nocopy FND_FLEX_SERVER1.SegFormats)
                                                        RETURN BOOLEAN;

  FUNCTION get_descsegs(dff_info IN  FND_FLEX_SERVER1.DescFlexInfo,
                        coldef     IN  FND_FLEX_SERVER1.ColumnDefinitions,
                        vflags     IN  FND_FLEX_SERVER1.ValueValidationFlags,
                        nsegs_out  OUT nocopy NUMBER,
                        segs_out   OUT nocopy FND_FLEX_SERVER1.stringarray,
                        x_context_segment_included OUT nocopy BOOLEAN)
                                                        RETURN BOOLEAN;

  FUNCTION get_column_value(colvals  IN  FND_FLEX_SERVER1.ColumnValues,
                            colname  IN  VARCHAR2,
                            coltype  IN  VARCHAR2,
                            seg_fmt  IN  VARCHAR2,
                            seg_len  IN  NUMBER,
                            val      OUT nocopy VARCHAR2) RETURN BOOLEAN;

  FUNCTION
   validate_descsegs(dff_info   IN  FND_FLEX_SERVER1.DescFlexInfo,
                     nsegs_in   IN  NUMBER,
                     segs       IN  FND_FLEX_SERVER1.StringArray,
                     vflags     IN  FND_FLEX_SERVER1.ValueValidationFlags,
                     v_date     IN  DATE,
                     uappid     IN  NUMBER,
                     respid     IN  NUMBER,
                     nsegs_out  OUT nocopy NUMBER,
                     segfmts    OUT nocopy FND_FLEX_SERVER1.SegFormats,
                     segstats   OUT nocopy VARCHAR2,
                     cols       OUT nocopy FND_FLEX_SERVER1.TabColArray,
                     coltypes   OUT nocopy FND_FLEX_SERVER1.CharArray,
                     v_dispvals OUT nocopy FND_FLEX_SERVER1.ValueArray,
                     v_vals     OUT nocopy FND_FLEX_SERVER1.ValueArray,
                     v_ids      OUT nocopy FND_FLEX_SERVER1.ValueIdArray,
                     v_descs    OUT nocopy FND_FLEX_SERVER1.ValueDescArray,
                     desc_lens  OUT nocopy FND_FLEX_SERVER1.NumberArray,
                     dispsegs   OUT nocopy FND_FLEX_SERVER1.DisplayedSegs,
                     errsegn    OUT nocopy NUMBER) RETURN NUMBER;

  FUNCTION
  validate_context_segs(dff_info     IN  FND_FLEX_SERVER1.DescFlexInfo,
                        contxt_name  IN  VARCHAR2,
                        nsegs        IN  NUMBER,
                        segs         IN  FND_FLEX_SERVER1.StringArray,
                        vflags       IN  FND_FLEX_SERVER1.ValueValidationFlags,
                        vdate        IN  DATE,
                        uappid       IN  NUMBER,
                        respid       IN  NUMBER,
                        vsa          OUT nocopy ValidatedSegmentArray,
                        errsegnum    OUT nocopy NUMBER) RETURN NUMBER;

  FUNCTION
       validate_context(dff_info     IN  FND_FLEX_SERVER1.DescFlexInfo,
                        context_sval IN  VARCHAR2,
                        vflags       IN  FND_FLEX_SERVER1.ValueValidationFlags,
                        vsa          OUT nocopy ValidatedSegmentArray)  RETURN NUMBER;

  FUNCTION find_context_value(appl_id       IN  VARCHAR2,
                              dflex_name    IN  VARCHAR2,
                              p_id_or_value IN  VARCHAR2,
                              seg_in        IN  VARCHAR2,
                              context_id    OUT nocopy VARCHAR2,
                              context_val   OUT nocopy VARCHAR2,
                              context_desc  OUT nocopy VARCHAR2,
                              p_global_flag OUT nocopy VARCHAR2) RETURN VARCHAR2;

  FUNCTION get_global_context(appl_id      IN  NUMBER,
                              dflex_name   IN  VARCHAR2,
                              glob_context OUT nocopy VARCHAR2) RETURN BOOLEAN;

  FUNCTION append_vsegarray(destvsa    IN OUT  nocopy ValidatedSegmentArray,
                            sourcevsa  IN      ValidatedSegmentArray)
                                                             RETURN BOOLEAN;

  PROCEDURE initialize_vsegarray(v_seg_array  OUT nocopy ValidatedSegmentArray);

/* -------------------------------------------------------------------- */
/*                        Functions and procedures                      */
/* -------------------------------------------------------------------- */


/* ------------------------------------------------------------------------- */
/*      The general purpose engine for descriptive flexfield validation.     */
/*                                                                           */
/*      Takes concatenated segments or rowid as input.                       */
/*                                                                           */
/*      This function returns output arrays that may or may not be           */
/*      populated depending on the point at which the validation stopped.    */
/*      The number of output array elements populated is specified by        */
/*      nvalidated.  Nvalidated is the number of enabled segments that       */
/*      were validated before validation stopped.                            */
/*      Many error conditions return no array information at all.  In        */
/*      this case nvalidated = 0 is returned.                                */
/*                                                                           */
/*      NOTE:  Make sure to call FND_FLEX_SERVER1.init_globals before        */
/*      calling this function, to initialize debugging and messages.         */
/* ------------------------------------------------------------------------  */

  PROCEDURE descval_engine
    (user_apid       IN  NUMBER,
     user_resp       IN  NUMBER,
     userid          IN  NUMBER,
     flex_app_sname  IN  VARCHAR2,
     desc_flex_name  IN  VARCHAR2,
     val_date        IN  DATE,
     invoking_mode   IN  VARCHAR2,
     allow_nulls     IN  BOOLEAN,
     update_table    IN  BOOLEAN,
     ignore_active   IN  BOOLEAN,
     concat_segs     IN  VARCHAR2,
     vals_not_ids    IN  BOOLEAN,
     use_column_def  IN  BOOLEAN,
     column_def      IN  FND_FLEX_SERVER1.ColumnDefinitions,
     rowid_in        IN  ROWID,
     alt_tbl_name    IN  VARCHAR2,
     data_field_name IN  VARCHAR2,
     srs_appl_id     IN  NUMBER DEFAULT NULL,
     srs_req_id      IN  NUMBER DEFAULT NULL,
     srs_pgm_id      IN  NUMBER DEFAULT NULL,
     nvalidated      OUT nocopy NUMBER,
     displayed_vals  OUT nocopy FND_FLEX_SERVER1.ValueArray,
     stored_vals     OUT nocopy FND_FLEX_SERVER1.ValueArray,
     segment_ids     OUT nocopy FND_FLEX_SERVER1.ValueIdArray,
     descriptions    OUT nocopy FND_FLEX_SERVER1.ValueDescArray,
     desc_lengths    OUT nocopy FND_FLEX_SERVER1.NumberArray,
     seg_colnames    OUT nocopy FND_FLEX_SERVER1.TabColArray,
     seg_coltypes    OUT nocopy FND_FLEX_SERVER1.CharArray,
     segment_types   OUT nocopy FND_FLEX_SERVER1.SegFormats,
     displayed_segs  OUT nocopy FND_FLEX_SERVER1.DisplayedSegs,
     seg_delimiter   OUT nocopy VARCHAR2,
     v_status        OUT nocopy NUMBER,
     seg_codes       OUT nocopy VARCHAR2,
     err_segnum      OUT nocopy NUMBER) IS

    nvals       NUMBER;
    nsegs       NUMBER;
    entered     VARCHAR2(1);
    dff_info    FND_FLEX_SERVER1.DescFlexInfo;
    dff_id      FND_FLEX_SERVER1.FlexStructId;
    segs        FND_FLEX_SERVER1.StringArray;
    value_dvals FND_FLEX_SERVER1.ValueArray;
    value_vals  FND_FLEX_SERVER1.ValueArray;
    value_ids   FND_FLEX_SERVER1.ValueIdArray;
    value_descs FND_FLEX_SERVER1.ValueDescArray;
    cc_cols     FND_FLEX_SERVER1.TabColArray;
    cc_coltypes FND_FLEX_SERVER1.CharArray;
    desc_lens   FND_FLEX_SERVER1.NumberArray;
    disp_segs   FND_FLEX_SERVER1.DisplayedSegs;
    vv_flags    FND_FLEX_SERVER1.ValueValidationFlags;
    segtypes    FND_FLEX_SERVER1.SegFormats;
    segcodes    VARCHAR2(201);
    errcode     NUMBER;
    errsegnum   NUMBER;
    catsegs     VARCHAR2(32000);
    l_context_segment_included BOOLEAN;

  BEGIN
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        FND_FLEX_SERVER1.add_debug(fnd_global.newline ||
                                   'BEGIN SV4.descval_engine() ');
     END IF;

--  Initialize all output variables so that returning from any point
--  results in a valid state.
--
    nvalidated := 0;
    segment_types.nsegs := 0;
    displayed_segs.n_segflags := 0;
    v_status := FND_FLEX_SERVER1.VV_ERROR;
    l_context_segment_included := FALSE;

--  Initialize everything which affects returned information.  This way we
--  can process all returned information before returning when exiting from
--  any point in this code even if there is an error.
--  Dont worry about initializing strings to null.

    nvals := 0;
    nsegs := 0;
    segtypes.nsegs := 0;
    disp_segs.n_segflags := 0;
    errcode := FND_FLEX_SERVER1.VV_ERROR;

    if((concat_segs is null) and (rowid_in is null)) then
      entered := 'N';
    else
      entered := 'Y';
    end if;

--  Get all required info about the desired flexfield structure.
--
    if(FND_FLEX_SERVER2.get_descstruct(flex_app_sname, desc_flex_name,
                                       dff_info) = FALSE) then
      goto return_error;
    end if;

--  Limit concatenated segment length for compatibility with client
--
    if(LENGTHB(concat_segs) > MAX_CATSEG_LEN) then
      FND_MESSAGE.set_name('FND', 'FLEX-CONCAT LEN > IAPFLEN');
      FND_MESSAGE.set_token('MAXFLDLEN', to_char(MAX_CATSEG_LEN));
      goto return_error;
    end if;

--  First check that operation makes sense
--
    if((invoking_mode is null) or
       (invoking_mode NOT IN ('V', 'P', 'L', 'C', 'D', 'Q'))) then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV BAD INVOKE');
      goto return_error;
    end if;

-- Set validation flags.
-- Descriptive flexfields similar to key flexfields except:
--   Required token is always Yes for Descriptive flexfields.
--   Descriptive flexfields always in PARTIAL validation mode (never PIP).
--
    vv_flags.default_all_displayed := TRUE;
    vv_flags.values_not_ids := vals_not_ids and
                               (invoking_mode not in ('L', 'C'));
    vv_flags.default_all_required := ((invoking_mode in ('V', 'D', 'Q')) and (entered='N'));
    vv_flags.default_non_displayed := (invoking_mode in ('P', 'V', 'D', 'Q'));
    vv_flags.allow_nulls := allow_nulls;
    vv_flags.message_on_null := TRUE;
    vv_flags.all_orphans_valid := FALSE;
    vv_flags.ignore_security := (invoking_mode = 'L');
    vv_flags.ignore_expired := (invoking_mode = 'L') or ignore_active;
    vv_flags.ignore_disabled := (invoking_mode = 'L') or ignore_active;
    vv_flags.message_on_security := (invoking_mode <> 'L');
    vv_flags.stop_on_value_error := (invoking_mode <> 'P');
    vv_flags.exact_nsegs_required := ((invoking_mode in ('L', 'C')) or
                ((invoking_mode in ('V', 'D', 'Q')) and not vv_flags.default_all_required));
    vv_flags.stop_on_security := (invoking_mode in ('V', 'C', 'D', 'Q'));

    /* invoking_mode is added for bug872437. */
    vv_flags.invoking_mode := invoking_mode;

    /* SRS request set parameters for redefaulting  */
    vv_flags.srs_req_set_appl_id := srs_appl_id;
    vv_flags.srs_req_set_id := srs_req_id;
    vv_flags.srs_req_set_pgm_id := srs_pgm_id;

--  Add input parameters to the debug information
--
    IF (fnd_flex_server1.g_debug_level > 0) THEN
       FND_FLEX_SERVER1.add_debug('User AppId = ' || to_char(user_apid));
       FND_FLEX_SERVER1.add_debug(', User Resp = ' || to_char(user_resp));
       FND_FLEX_SERVER1.add_debug(', User Id = ' || to_char(userid));
       FND_FLEX_SERVER1.add_debug(', Ap Short Name = ' || flex_app_sname);
       FND_FLEX_SERVER1.add_debug(', Desc Flex Name = '||desc_flex_name||' ');
       FND_FLEX_SERVER1.add_debug(', Val Date = ' ||
                                  to_char(val_date, 'YYYY/MM/DD HH24:MI:SS'));
       FND_FLEX_SERVER1.add_debug(', Invoke = ' || invoking_mode);
       if(ignore_active) then
          FND_FLEX_SERVER1.add_debug(', Ignore disabled/expired');
       end if;
       if(allow_nulls) then
          FND_FLEX_SERVER1.add_debug(', Allow Nulls');
       end if;
       if(update_table) then
          FND_FLEX_SERVER1.add_debug(', Update Table');
       end if;
       FND_FLEX_SERVER1.add_debug(', Concat Segs = ' || concat_segs);
       if(vals_not_ids) then
          FND_FLEX_SERVER1.add_debug(', Vals');
        else
          FND_FLEX_SERVER1.add_debug(', Ids');
       end if;
       FND_FLEX_SERVER1.add_debug(', Rowid = ' || ROWIDTOCHAR(rowid_in));
       FND_FLEX_SERVER1.add_debug(', Alt Table = ' || alt_tbl_name);
       FND_FLEX_SERVER1.add_debug(', Data Field = ' || data_field_name||'.  ');
       if(use_column_def) then
          FND_FLEX_SERVER1.add_debug(', ColDefs: ');
          if(column_def.context_value_set) then
             FND_FLEX_SERVER1.add_debug('*Context* = ('
                                        || column_def.context_value || ') ');
          end if;
          for i in 1..column_def.colvals.ncolumns loop
             FND_FLEX_SERVER1.add_debug
               (column_def.colvals.column_names(i) || ':' ||
                column_def.colvals.column_types(i) || ' = (' ||
                column_def.colvals.column_values(i) || ') ');
          end loop;
       end if;
    END IF;

--  If LOADDESC or CHECKDESC modes get the ids from the row in the table
--  if rowid not null.  If LOADDESC, CHECKDESC or VALDESC and rowid is null
--  then get inputs from the column definitions if use_column_def is TRUE.
--  Otherwise break up the concatenated segments.
--
    if((invoking_mode in ('L', 'C')) and (rowid_in is not null)) THEN
       IF (fnd_flex_server1.g_debug_level > 0) THEN
          fnd_flex_server1.add_debug('calling find_descsegs()');
       END IF;
      if(find_descsegs(dff_info, rowid_in, alt_tbl_name, data_field_name,
                       vv_flags, nsegs, segs) = FALSE) then
        goto return_error;
      end if;
     elsif((invoking_mode in ('L', 'C', 'V', 'D', 'Q')) and use_column_def) THEN
       IF (fnd_flex_server1.g_debug_level > 0) THEN
          fnd_flex_server1.add_debug('calling get_descsegs()');
       END IF;

      if(get_descsegs(dff_info, column_def, vv_flags, nsegs, segs, l_context_segment_included)=FALSE) then
        goto return_error;
      end if;
    else
       IF (fnd_flex_server1.g_debug_level > 0) THEN
          fnd_flex_server1.add_debug('calling to_stringarray()');
       END IF;
       nsegs := FND_FLEX_SERVER1.to_stringarray(concat_segs,
                         dff_info.segment_delimiter, segs);
    end if;

--  Check to make sure there are not too many segments.
--
-- Bug 9929658 added OR (use_column_def = FALSE)
-- use_column_def is always set to FALSE except in one case
-- when called by validate_desccols(). Only when use_column_def=TRUE
-- is l_context_Segment_included set by get_descsegs(). So for all
-- other fnd_flex_descval calls, l_context_Segment_included always was
-- false. So for this case I added OR (use_column_def = FALSE).
-- This whole if statment seems to be worthless, if you 30 segs to
-- api and you don't even have 30 segs defined it will give error.
-- Instead of just removing it, I added this OR stmnt so that I do
-- not undo prvious fix. If use_column_def = TRUE, the code will work
-- as before this change.
    if(nsegs > MAX_NSEGS) then
       if ((l_context_Segment_included and (nsegs = MAX_NSEGS + 1)) OR
           (use_column_def = FALSE)) then
          NULL;
        else
          FND_MESSAGE.set_name('FND', 'FLEX-TOO MANY SEGS');
          FND_MESSAGE.set_token('NSEGS', MAX_NSEGS);
          goto return_error;
       end if;
    END IF;


    if (nsegs = 0) then
       if (column_def.context_value_set) then
          errcode := FND_FLEX_SERVER1.VV_VALID;
          goto return_outvars;
       end if;
    end if;


    IF (fnd_flex_server1.g_debug_level > 0) THEN
       catsegs := substrb(FND_FLEX_SERVER1.from_stringarray(nsegs, segs, '*'), 1, 32000);
        FND_FLEX_SERVER1.add_debug(catsegs);
    END IF;


--  Validate segments.
--
    errcode := validate_descsegs(dff_info, nsegs, segs, vv_flags, val_date,
                user_apid, user_resp, nvals, segtypes, segcodes, cc_cols,
                cc_coltypes, value_dvals, value_vals, value_ids, value_descs,
                desc_lens, disp_segs, errsegnum);

    IF (fnd_flex_server1.g_debug_level > 0) THEN
       FND_FLEX_SERVER1.add_debug(' validate_descsegs() returns errcode ');
       FND_FLEX_SERVER1.add_debug(to_char(errcode) ||' and '|| to_char(nvals));
       FND_FLEX_SERVER1.add_debug(' values.  SegCodes: ' || segcodes);
       FND_FLEX_SERVER1.add_debug(' ErrSeg: ' || to_char(errsegnum));
       FND_FLEX_SERVER1.add_debug(' Returned arrays:');
       for i in 1..nvals loop
          FND_FLEX_SERVER1.add_debug('"' || segtypes.vs_format(i));
          FND_FLEX_SERVER1.add_debug(to_char(segtypes.vs_maxsize(i), 'S099'));
          FND_FLEX_SERVER1.add_debug('*' || value_dvals(i) || '*');
          FND_FLEX_SERVER1.add_debug(cc_cols(i) || ':' ||cc_coltypes(i)||'" ');
       end loop;
    END IF;
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
    seg_delimiter := dff_info.segment_delimiter;
    seg_codes := segcodes;
    err_segnum := errsegnum;
    v_status := errcode;
    return;

  <<return_error>>
    v_status := FND_FLEX_SERVER1.VV_ERROR;
    return;

  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG','descval_engine() exception: ' || SQLERRM);
      v_status := FND_FLEX_SERVER1.VV_ERROR;
      return;
  END descval_engine;

/* ------------------------------------------------------------------------ */
/*      Finds descriptive flexfield segment ids from existing row in table. */
/*      If alt_table is not null looks for the row in that table rather     */
/*      than in the table on which the descriptive flexfield is defined.    */
/*      Note special error if columns do not match up.                      */
/*      If data_field is not null, uses this field as source of             */
/*      concatenated ids rather than the individual segment fields.         */
/*      Returns segment ids for all enabled segments whether or not they    */
/*      are displayed in the order that they are displayed within each      */
/*      context.                                                            */
/*      Returns TRUE if all ok, or FALSE and sets FND_MESSAGE on error.     */
/* ------------------------------------------------------------------------ */

  FUNCTION find_descsegs(dflex_info IN  FND_FLEX_SERVER1.DescFlexInfo,
                         row_id     IN  ROWID,
                         alt_table  IN  VARCHAR2,
                         data_field IN  VARCHAR2,
                         vflags     IN  FND_FLEX_SERVER1.ValueValidationFlags,
                         nsegs_out  OUT nocopy NUMBER,
                         segs_out   OUT nocopy FND_FLEX_SERVER1.StringArray)
                                                        RETURN BOOLEAN IS
    effective_table     VARCHAR2(30);

  BEGIN
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        FND_FLEX_SERVER1.add_debug(fnd_global.newline ||
                                   'BEGIN SV4.find_descsegs() ');
     END IF;

    nsegs_out := 0;

    if(alt_table is not null) then
      effective_table := SUBSTRB(alt_table, 1, 30);
    else
      effective_table := dflex_info.table_name;
    end if;

--  If use data field just select that column and break up segment ids.
--  Otherwise must get all columns.

    if(data_field is not null) then
      return(read_datafield(dflex_info, row_id, effective_table,
                            data_field, nsegs_out, segs_out));
    end if;
    return(read_segment_cols(dflex_info, row_id, effective_table,
                                  vflags, nsegs_out, segs_out));
  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG','find_descsegs() exception: ' || SQLERRM);
      return(FALSE);

  END find_descsegs;

/* ------------------------------------------------------------------------ */
/*      Reads concatenated segment ids from data field in the particular    */
/*      row of the specified table.  Breaks up concatenated segments into   */
/*      a string array for return.                                          */
/*      Returns TRUE on success or FALSE and sets FND_MESSAGE on error.     */
/* ------------------------------------------------------------------------ */

  FUNCTION read_datafield(dflex_info IN  FND_FLEX_SERVER1.DescFlexInfo,
                          row_id     IN  ROWID,
                          table_name IN  VARCHAR2,
                          datafield  IN  VARCHAR2,
                          nsegs      OUT nocopy NUMBER,
                          segs       OUT nocopy FND_FLEX_SERVER1.StringArray)
                                                           RETURN BOOLEAN IS
    concat_segids  VARCHAR2(2000);
    rstat          NUMBER;

  BEGIN
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        FND_FLEX_SERVER1.add_debug(fnd_global.newline ||
                                   'BEGIN SV4.read_datafield() ');
     END IF;

     fnd_dsql.init;
     fnd_dsql.add_text('select SUBSTRB(' || datafield || ', 1, 2000)' ||
                       ' from ' || table_name ||
                       ' where rowid = CHARTOROWID(');
     fnd_dsql.add_bind(ROWIDTOCHAR(row_id));
     fnd_dsql.add_text(')');

--  Look up the segment values or ids.
--
    rstat := FND_FLEX_SERVER1.x_dsql_select_one(concat_segids);
    if(rstat <> 1) then
      if(rstat = 0) then
        FND_MESSAGE.set_name('FND', 'FLEX-DFF ROW NOT FOUND');
        FND_MESSAGE.set_token('TABLE', table_name);
        FND_MESSAGE.set_token('ROWID', ROWIDTOCHAR(row_id));
      elsif(rstat = -2) then
        FND_MESSAGE.set_name('FND', 'FLEX-DFF BAD DATAFIELD');
        FND_MESSAGE.set_token('TABLE', table_name);
        FND_MESSAGE.set_token('DATAFIELD', datafield);
      else
        null;
      end if;
      return(FALSE);
    end if;

    nsegs := FND_FLEX_SERVER1.to_stringarray(concat_segids,
                                dflex_info.segment_delimiter, segs);
    return(TRUE);

  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG','read_datafield() exception: '||SQLERRM);
      return(FALSE);

  END read_datafield;

/* ------------------------------------------------------------------------ */
/*      Reads segment ids from individual attribute columns in the row      */
/*      of the effective table specified.  Validates the context in the     */
/*      process to determine which columns to use for context-sensitive     */
/*      segments.  Looks up the context value from table.                   */
/*      Returns TRUE on success or FALSE and sets FND_MESSAGE on error.     */
/* ------------------------------------------------------------------------ */

  FUNCTION read_segment_cols(dflex_info IN  FND_FLEX_SERVER1.DescFlexInfo,
                        row_id     IN  ROWID,
                        table_name IN  VARCHAR2,
                        vflags     IN  FND_FLEX_SERVER1.ValueValidationFlags,
                        nsegs      OUT nocopy NUMBER,
                        segs       OUT nocopy FND_FLEX_SERVER1.StringArray)
                                                        RETURN BOOLEAN IS
    ncols               NUMBER;
    cols                FND_FLEX_SERVER1.TabColArray;
    coltypes            FND_FLEX_SERVER1.CharArray;
    segfmts             FND_FLEX_SERVER1.SegFormats;
    value_component     NUMBER;
    rstat               NUMBER;
    context             VARCHAR2(80);
    context_number      NUMBER;

    BEGIN
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        FND_FLEX_SERVER1.add_debug(fnd_global.newline ||
                                   'BEGIN SV4.read_segment_cols() ');
     END IF;

    nsegs := 0;

--  Determine if values or ids are stored in the table columns.
--  Generally only expect ids, but in some cases we may want to
--  allow users to input values into the segment columns and have
--  us turn them into ids.
--
    if(vflags.values_not_ids) then
      value_component := FND_FLEX_SERVER1.VC_VALUE;
    else
      value_component := FND_FLEX_SERVER1.VC_ID;
    end if;

--  Get context value stored in the table
--  Assume context column is CHAR or VARCHAR2
--
    IF (fnd_flex_server1.g_debug_level > 0) THEN
       FND_FLEX_SERVER1.add_debug(' Context col: '||dflex_info.context_column);
    END IF;

    fnd_dsql.init;
    fnd_dsql.add_text('select SUBSTRB(' || dflex_info.context_column || ', 1, 80)' ||
                      ' from ' || table_name ||
                      ' where rowid = CHARTOROWID(');
    fnd_dsql.add_bind(ROWIDTOCHAR(row_id));
    fnd_dsql.add_text(')');

    rstat := FND_FLEX_SERVER1.x_dsql_select_one(context);
    if(rstat <> 1) then
      if(rstat = 0) then
        FND_MESSAGE.set_name('FND', 'FLEX-DFF ROW NOT FOUND');
        FND_MESSAGE.set_token('TABLE', table_name);
        FND_MESSAGE.set_token('ROWID', ROWIDTOCHAR(row_id));
      elsif(rstat = -2) then
        FND_MESSAGE.set_name('FND', 'FLEX-DFF BAD SEGCOLS');
        FND_MESSAGE.set_token('TABLE', table_name);
      else
        null;
      end if;
      return(FALSE);
    end if;

--  Get names of columns used.  Must validate context to do this.
--
    if(get_desc_cols(dflex_info, context, vflags, context_number,
                     ncols, cols, coltypes, segfmts) = FALSE) then
      return(FALSE);
    end if;

    IF (fnd_flex_server1.g_debug_level > 0) THEN
       FND_FLEX_SERVER1.add_debug('Selecting all columns ');
    END IF;

--  Build SQL statement to select segment columns in order for
--  global segments, the context segment, and context-sensitive segments.
--

    fnd_dsql.init;
    fnd_dsql.add_text('select ');
    for i in 1..ncols loop
      if(i > 1) then
         fnd_dsql.add_text(', ');
      end if;
      fnd_dsql.add_text(FND_FLEX_SERVER1.select_clause
                        (cols(i), coltypes(i),
                         value_component, segfmts.vs_format(i), segfmts.vs_maxsize(i)));
    end loop;
    fnd_dsql.add_text(' from ' || table_name ||
                      ' where rowid = CHARTOROWID(');
    fnd_dsql.add_bind(ROWIDTOCHAR(row_id));
    fnd_dsql.add_text(')');

--  Look up the segment values or ids.
--
    rstat := FND_FLEX_SERVER1.x_dsql_select(ncols, segs);
    if(rstat <> 1) then
      if(rstat = 0) then
        FND_MESSAGE.set_name('FND', 'FLEX-DFF ROW NOT FOUND');
        FND_MESSAGE.set_token('TABLE', table_name);
        FND_MESSAGE.set_token('ROWID', ROWIDTOCHAR(row_id));
      elsif(rstat = -2) then
        FND_MESSAGE.set_name('FND', 'FLEX-DFF BAD SEGCOLS');
        FND_MESSAGE.set_token('TABLE', table_name);
      else
        null;
      end if;
      return(FALSE);
    end if;

    nsegs := ncols;
    return(TRUE);

  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG','read_segment_cols() exception: '||SQLERRM);
      return(FALSE);

  END read_segment_cols;

/* ------------------------------------------------------------------------ */
/*      Gets the names of the columns corresponding to the segment ids      */
/*      for the specified descriptive flexfield.  Validates the context     */
/*      value in the process to determine which context segment columns     */
/*      to use.  Returns the columns in display order within each context   */
/*      for all enabled segments even if they are not displayed.  Returns   */
/*      global context segment columns first, then the context segment      */
/*      column, then the columns of the context-sensitive segments.         */
/*      Also returns a number indicating the context segment number.        */
/*      Returns TRUE if all ok, or FALSE and sets FND_MESSAGE on error.     */
/* ------------------------------------------------------------------------ */

  FUNCTION get_desc_cols(dff_info   IN  FND_FLEX_SERVER1.DescFlexInfo,
                         context    IN  VARCHAR2,
                         vflags     IN  FND_FLEX_SERVER1.ValueValidationFlags,
                         contextn   OUT nocopy NUMBER,
                         ncols      OUT nocopy NUMBER,
                         cols       OUT nocopy FND_FLEX_SERVER1.TabColArray,
                         coltypes   OUT nocopy FND_FLEX_SERVER1.CharArray,
                         segfmts    OUT nocopy FND_FLEX_SERVER1.SegFormats)
                                                        RETURN BOOLEAN IS

    fstruct           FND_FLEX_SERVER1.FlexStructId;

    n_global          NUMBER;
    global_cols       FND_FLEX_SERVER1.TabColArray;
    global_coltypes   FND_FLEX_SERVER1.CharArray;
    global_segfmts    FND_FLEX_SERVER1.SegFormats;

    n_context         NUMBER;
    context_cols      FND_FLEX_SERVER1.TabColArray;
    context_coltypes  FND_FLEX_SERVER1.CharArray;
    context_segfmts   FND_FLEX_SERVER1.SegFormats;

    context_vsa       ValidatedSegmentArray;
    colcount          NUMBER;
    rstat             NUMBER;
    vc_return         NUMBER;

  BEGIN
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        FND_FLEX_SERVER1.add_debug(fnd_global.newline ||
                                   'BEGIN SV4.get_desc_cols() ');
     END IF;

--  Initialize outputs to return nothing in case of error.
--
    ncols := 0;
    segfmts.nsegs := 0;

    fstruct.isa_key_flexfield := FALSE;
    fstruct.application_id := dff_info.application_id;
    fstruct.desc_flex_name := dff_info.name;

--  Return name of global context.
--
    if(get_global_context(dff_info.application_id, dff_info.name,
                          fstruct.desc_flex_context) = FALSE) then
      return(FALSE);
    end if;

--  Get segment mapping for global segments
--
    if(FND_FLEX_SERVER2.get_struct_cols(fstruct, dff_info.table_appl_id,
                               dff_info.table_id, n_global, global_cols,
                               global_coltypes, global_segfmts) = FALSE) then
      return(FALSE);
    end if;
    IF (fnd_flex_server1.g_debug_level > 0) THEN
       FND_FLEX_SERVER1.add_debug(' Found global segment mapping: [');
       for i in 1..n_global loop
          FND_FLEX_SERVER1.add_debug(global_cols(i) || ':' ||
                                     global_coltypes(i) ||' ');
       end loop;
       FND_FLEX_SERVER1.add_debug('] ');
    END IF;

--  Validate the context value
--
    vc_return := validate_context(dff_info, context, vflags, context_vsa);
    IF (vc_return <> FND_FLEX_SERVER1.VV_VALID) then
      IF (vc_return <> FND_FLEX_SERVER1.VV_CTXTNOSEG) then
         return(FALSE);
      END IF;
    END IF;
--      return(FALSE);
--    end if;


    IF (fnd_flex_server1.g_debug_level > 0) THEN
       FND_FLEX_SERVER1.add_debug('Context value (' || context_vsa.ids(1) ||
                                  ') valid. ');
    END IF;

--  Get segment mapping for context-sensitive segments
--
    fstruct.desc_flex_context := context_vsa.ids(1);
    IF (fstruct.desc_flex_context IS NOT NULL) AND
       (vc_return <> FND_FLEX_SERVER1.VV_CTXTNOSEG) THEN
       if(FND_FLEX_SERVER2.get_struct_cols
          (fstruct, dff_info.table_appl_id,
           dff_info.table_id, n_context, context_cols,
           context_coltypes, context_segfmts) = FALSE) then
          return(FALSE);
       end if;

       IF (fnd_flex_server1.g_debug_level > 0) THEN
          FND_FLEX_SERVER1.add_debug(' Found context segment mapping: [');
          for i in 1..n_context loop
             FND_FLEX_SERVER1.add_debug(context_cols(i) || ':' ||
                                        context_coltypes(i) ||' ');
          end loop;
          FND_FLEX_SERVER1.add_debug('] ');
       END IF;
     ELSE
       n_context := 0;
       context_segfmts.nsegs := 0;
    END IF;

--  Now concatenate the semgment columns for global,
--  context, and context-sensitive contexts.

    colcount := 0;

--  Global columns
--
    for i in 1..n_global loop
      colcount := colcount + 1;
      cols(colcount) := global_cols(i);
      coltypes(colcount) := global_coltypes(i);
      segfmts.vs_format(colcount) := global_segfmts.vs_format(i);
      segfmts.vs_maxsize(colcount) := global_segfmts.vs_maxsize(i);
    end loop;

--  Context column.  Also note which it is.
--
    colcount := colcount + 1;
    cols(colcount) := context_vsa.segcols(1);
    coltypes(colcount) := context_vsa.segcoltypes(1);
    segfmts.vs_format(colcount) := context_vsa.segfmts.vs_format(1);
    segfmts.vs_maxsize(colcount) := context_vsa.segfmts.vs_maxsize(1);
    contextn := colcount;

--  Context-sensitive columns
--
    for i in 1..n_context loop
      colcount := colcount + 1;
      cols(colcount) := context_cols(i);
      coltypes(colcount) := context_coltypes(i);
      segfmts.vs_format(colcount) := context_segfmts.vs_format(i);
      segfmts.vs_maxsize(colcount) := context_segfmts.vs_maxsize(i);
    end loop;

    segfmts.nsegs := colcount;
    ncols := colcount;
    return(TRUE);

  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG','get_desc_cols() exception: ' || SQLERRM);
      return(FALSE);

  END get_desc_cols;

/* ------------------------------------------------------------------------ */
/*      Gets descriptive flexfield segment ids from the column definitions. */
/*      Error if some required columns are not defined or if the column     */
/*      data types do not match those expected from the segment columns.    */
/*      Returns segment ids for all enabled segments whether or not they    */
/*      are displayed in the order that they are displayed within each      */
/*      context.                                                            */
/*      Returns TRUE if all ok, or FALSE and sets FND_MESSAGE on error.     */
/* ------------------------------------------------------------------------ */

  FUNCTION get_descsegs(dff_info   IN  FND_FLEX_SERVER1.DescFlexInfo,
                        coldef     IN  FND_FLEX_SERVER1.ColumnDefinitions,
                        vflags     IN  FND_FLEX_SERVER1.ValueValidationFlags,
                        nsegs_out  OUT nocopy NUMBER,
                        segs_out   OUT nocopy FND_FLEX_SERVER1.StringArray,
                        x_context_segment_included OUT nocopy BOOLEAN)
                                                        RETURN BOOLEAN IS
    thisval        VARCHAR2(1000);
    fstruct        FND_FLEX_SERVER1.FlexStructId;

    n_segs         NUMBER;
    seg_cols       FND_FLEX_SERVER1.TabColArray;
    seg_coltypes   FND_FLEX_SERVER1.CharArray;
    seg_fmts       FND_FLEX_SERVER1.SegFormats;
    context_seg    NUMBER;

  BEGIN
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        FND_FLEX_SERVER1.add_debug(fnd_global.newline ||
                                   'BEGIN SV4.get_descsegs() ');
     END IF;

--  Initialize outputs in case of error.
--  Start with no defined segments
--
    nsegs_out := 0;
    x_context_segment_included := FALSE;

--  Get the context value.  It might already be set in the coldef.
--  If not, then look it up from the column values.
--

    if(coldef.context_value_set) then
      thisval := coldef.context_value;
      IF (fnd_flex_server1.g_debug_level > 0) THEN
         FND_FLEX_SERVER1.add_debug('*Context* = (' || thisval || ') ');
      END IF;
    else
      if(get_column_value(coldef.colvals, dff_info.context_column,
                          'V', 'C', 30, thisval) = FALSE) then
        return(FALSE);
      end if;
    end if;

--  Get names of columns used.  Must validate context to do this.
--
    if(get_desc_cols(dff_info, thisval, vflags, context_seg,
                     n_segs, seg_cols, seg_coltypes, seg_fmts) = FALSE) then
      return(FALSE);
    end if;

--  Loop through the segment columns and get the corresponding values
--  in the desired order.  Use the context value passed in for the context
--  segment if it is defined.
--
    for i in 1..n_segs loop
      if((i = context_seg) and (coldef.context_value_set)) then
        segs_out(i) := coldef.context_value;
        x_context_segment_included := TRUE;
        IF (fnd_flex_server1.g_debug_level > 0) THEN
           FND_FLEX_SERVER1.add_debug('*Context* = (' ||
                                      coldef.context_value || ') ');
        END IF;
      else
        if(get_column_value(coldef.colvals, seg_cols(i), seg_coltypes(i),
           seg_fmts.vs_format(i), seg_fmts.vs_maxsize(i), thisval)=FALSE) then
          return(FALSE);
        end if;
        segs_out(i) := thisval;
      end if;
    end loop;

--  Return the segments out
--
    nsegs_out := n_segs;
    return(TRUE);

  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG','get_descsegs() exception: ' || SQLERRM);
      return(FALSE);

  END get_descsegs;

/* ----------------------------------------------------------------------- */
/*      Gets the value associated with a given column name from the        */
/*      pre-defined ColumnValues structure.  A column with the same name   */
/*      and data type must be found to consider the column found.          */
/*      Converts the column value stored in the generic character          */
/*      representation into the representation required for a segment      */
/*      with the indicated value set format and size.                      */
/*      Performs case-insensitive column name comparison.                  */
/*      Returns TRUE if all ok, or FALSE and sets FND_MESSAGE on error.    */
/* ----------------------------------------------------------------------- */

  FUNCTION get_column_value(colvals  IN  FND_FLEX_SERVER1.ColumnValues,
                            colname  IN  VARCHAR2,
                            coltype  IN  VARCHAR2,
                            seg_fmt  IN  VARCHAR2,
                            seg_len  IN  NUMBER,
                            val      OUT nocopy VARCHAR2) RETURN BOOLEAN IS
    d         DATE;
    dfmt      VARCHAR2(40);
    valindex  NUMBER;
    niceval   VARCHAR2(1000);

  BEGIN
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        FND_FLEX_SERVER1.add_debug(fnd_global.newline ||
                                   'BEGIN SV4.get_column_value() ');
     END IF;

-- Find index to value in column value table.
--
    valindex := 0;
    for i in 1..colvals.ncolumns loop
      if((colname = colvals.column_names(i)) and
         ((coltype = colvals.column_types(i)) or
           (coltype in ('C', 'V') and
            colvals.column_types(i) in ('C', 'V')))) then
        valindex := i;
        exit;
      end if;
    end loop;

--  Error if column not defined
--
    if(valindex = 0) then
      FND_MESSAGE.set_name('FND', 'FLEX-DFF COLUMN UNDEFINED');
      FND_MESSAGE.set_token('COLNAME', colname);
      FND_MESSAGE.set_token('COLTYPE', coltype);
      return(FALSE);
    end if;

--  Convert format of data to that desired for the value set.
--  Assume numbers are already in the default to_char(n) format, and
--  that dates are in the to_char(d, FND_FLEX_SERVER1.DATETIME_FMT) format.
--
--  Flex expects numbers to be in the default to_char(n) format.
--  Flex expects most dates to be in the default to_char(d) format,
--  except translatable dates which are in FND_FLEX_SERVER1.stored_date_format
--  if ids or FND_FLEX_SERVER1.displayed_date_format if values.  So we need
--  to convert only if column is of date type.
--  Dates input are the stored not displayed formats.
--  See FND_FLEX_SERVER1.select_clause().
--
    if(coltype = 'D') then
      d := to_date(colvals.column_values(valindex),
                   FND_FLEX_SERVER1.DATETIME_FMT);
      if(seg_fmt in ('X', 'Y', 'Z')) then
        dfmt := FND_FLEX_SERVER1.stored_date_format(seg_fmt, seg_len);
        niceval := to_char(d, dfmt);
      else
        niceval := to_char(d);
      end if;
    else
      niceval := colvals.column_values(valindex);
    end if;

    IF (fnd_flex_server1.g_debug_level > 0) THEN
       FND_FLEX_SERVER1.add_debug('Column ' || colname || ':' || coltype ||
                                  ' = (' || niceval || ') ');
    END IF;
    val := niceval;

<<done_return>>

    return(TRUE);

  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG','get_column_value() exception: ' || SQLERRM);
      return(FALSE);

  END get_column_value;

/* ----------------------------------------------------------------------- */
/*      Validates all segments for a given descriptive flexfield.          */
/*      Includes segments from the global context, the context segment     */
/*      and the segments for the particular context.                       */
/*      Input all segments in an array.                                    */
/*      Returns error code and sets FND_MESSAGE on error, or returns       */
/*      VV_VALID if all ok.                                                */
/* ----------------------------------------------------------------------- */

  FUNCTION
   validate_descsegs(dff_info   IN  FND_FLEX_SERVER1.DescFlexInfo,
                     nsegs_in   IN  NUMBER,
                     segs       IN  FND_FLEX_SERVER1.StringArray,
                     vflags     IN  FND_FLEX_SERVER1.ValueValidationFlags,
                     v_date     IN  DATE,
                     uappid     IN  NUMBER,
                     respid     IN  NUMBER,
                     nsegs_out  OUT nocopy NUMBER,
                     segfmts    OUT nocopy FND_FLEX_SERVER1.SegFormats,
                     segstats   OUT nocopy VARCHAR2,
                     cols       OUT nocopy FND_FLEX_SERVER1.TabColArray,
                     coltypes   OUT nocopy FND_FLEX_SERVER1.CharArray,
                     v_dispvals OUT nocopy FND_FLEX_SERVER1.ValueArray,
                     v_vals     OUT nocopy FND_FLEX_SERVER1.ValueArray,
                     v_ids      OUT nocopy FND_FLEX_SERVER1.ValueIdArray,
                     v_descs    OUT nocopy FND_FLEX_SERVER1.ValueDescArray,
                     desc_lens  OUT nocopy FND_FLEX_SERVER1.NumberArray,
                     dispsegs   OUT nocopy FND_FLEX_SERVER1.DisplayedSegs,
                     errsegn    OUT nocopy NUMBER) RETURN NUMBER IS

-- Remember to check all sizes!
--

    global_context_name VARCHAR2(30);

    context_segnum      NUMBER;
    context_seg         VARCHAR2(80);

    context_segs_in     FND_FLEX_SERVER1.StringArray;
    ncontext_segs_in    NUMBER;

    global_segs         ValidatedSegmentArray;
    context_segment     ValidatedSegmentArray;
    context_segs        ValidatedSegmentArray;

    global_vflags       FND_FLEX_SERVER1.ValueValidationFlags;
    global_error_segnum NUMBER;
    global_error_msg    VARCHAR2(2000);
    global_return_code  NUMBER;
    error_segnum        NUMBER;
    return_code         NUMBER;

  BEGIN
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        FND_FLEX_SERVER1.add_debug(fnd_global.newline ||
                                   'BEGIN SV4.validate_descsegs() ');
     END IF;

--  Initialize all returned values and all derived values with defaults
--
    nsegs_out := 0;
    dispsegs.n_segflags := 0;
    segfmts.nsegs := 0;

--  Initialize segment arrays to 0 segments in case of error.
--
    initialize_vsegarray(global_segs);
    initialize_vsegarray(context_segment);
    initialize_vsegarray(context_segs);

--  Return name of global context.
--
    if(get_global_context(dff_info.application_id, dff_info.name,
                          global_context_name) = FALSE) then
      return_code := FND_FLEX_SERVER1.VV_ERROR;
      goto return_values;
    end if;

--  Global context cannot require exact segs because we dont know
--  how many segments are in the global structure beforehand.
--  Make up a set of value validation flags like those input but which
--  allow extra segments.
--
    global_vflags := vflags;
    global_vflags.exact_nsegs_required := FALSE;

--  Validate global context segments
--
    IF (fnd_flex_server1.g_debug_level > 0) THEN
       FND_FLEX_SERVER1.add_debug('  Global segments: ');
    END IF;
    global_return_code := validate_context_segs(dff_info, global_context_name,
                                nsegs_in, segs, global_vflags, v_date, uappid,
                                respid, global_segs, global_error_segnum);

--  Quit only if invalid and the error requires stopping.  If error does
--  not require stopping, save error message so it doesn't get
--  overwritten by context validation.
--
    if(global_return_code <> FND_FLEX_SERVER1.VV_VALID) then
      if(global_error_segnum is not null) then
        global_error_msg := FND_MESSAGE.GET_ENCODED;
      end if;
      if(not (((global_return_code = FND_FLEX_SERVER1.VV_SECURED) and
               (not global_vflags.stop_on_security)) OR
              ((global_return_code = FND_FLEX_SERVER1.VV_VALUES) and
               (not global_vflags.stop_on_value_error)))) then
        goto return_values;
      end if;
    end if;

--  Determine which segment is the context segment.
--  If IDs input all segments are displayed so the context segment is
--  just global_segs.nvalidated + 1.  However, if VALUES are input,
--  then input segs are only the displayed segments, so have to
--  count the number of displayed segments in the global context
--  to determine the number of the context segment.
--
-- Bug 1459072: There is no need to validate the context segment if one
-- does not exist.

    IF dff_info.context_override = 'N'
       AND dff_info.context_required = 'N'
       AND dff_info.default_context IS NULL
       AND dff_info.reference_field IS NULL
       -- Bug#4220582, to enforce validation checking even when ids are passed and not values.
       AND vflags.values_not_ids = TRUE then
         context_seg := NULL;
         return_code := FND_FLEX_SERVER1.VV_VALID;
    ELSE
      if(vflags.values_not_ids) then
        context_segnum := 1;
        for i in 1..global_segs.dispsegs.n_segflags loop
          if(global_segs.dispsegs.segflags(i)) then
            context_segnum := context_segnum + 1;
          end if;
        end loop;
      else
        context_segnum := global_segs.nvalidated + 1;
      end if;

--  If ids passed in, or if context field displayed, then get context
--  from input segment array.  Otherwise treat it as null and let it
--  get defaulted if necessary.
--  Set context_segnum to the first context-sensitive segment.
--
--  PROBLEM:  IF CONTEXT field not displayed, but defaulted using the
--  reference field mechanism, then the context value won't get passed
--  in and the default value will not be available on the server.
--
    -- if the context segment is set, then use it.
      if((not vflags.values_not_ids) or
         (dff_info.context_override = 'Y') OR
         (context_segnum <= nsegs_in AND
          segs(context_segnum) IS NOT NULL)) then
        if(nsegs_in < context_segnum) then
          if(vflags.exact_nsegs_required and
             not ((nsegs_in = 0) and (context_segnum = 1))) then
            FND_MESSAGE.set_name('FND', 'FLEX-MISSING CONCAT VALUES');
            error_segnum := global_segs.nvalidated + 1;
            return_code := FND_FLEX_SERVER1.VV_ERROR;
            goto return_values;
          else
            context_seg := NULL;
          end if;
        else
          context_seg := SUBSTRB(segs(context_segnum), 1, 80);
        end if;
        IF (fnd_flex_server1.g_debug_level > 0) THEN
          FND_FLEX_SERVER1.add_debug(' Context seg '||to_char(context_segnum));
          FND_FLEX_SERVER1.add_debug(' = (' || context_seg || ') ');
        END IF;
      --
      -- add 1. Beginning index for context sens. segs.
      --
        context_segnum := context_segnum + 1;
      end if;

      IF (fnd_flex_server1.g_debug_level > 0) THEN
        FND_FLEX_SERVER1.add_debug('Context SEG#:' || To_char(context_segnum));
      END IF;
--  Validate context segment.  Default it if it's null and defaults
--  are required.
--
      return_code := validate_context(dff_info, context_seg, vflags,
                                      context_segment);

--  If context field is valid, validate context.  Pass in only context segs.
--
      if((return_code <> FND_FLEX_SERVER1.VV_VALID) and
        (return_code <> FND_FLEX_SERVER1.VV_CTXTNOSEG)) then
        error_segnum := global_segs.nvalidated + 1;
      else
        ncontext_segs_in := 0;
        for i in context_segnum..nsegs_in loop
          ncontext_segs_in := ncontext_segs_in + 1;
          context_segs_in(ncontext_segs_in) := segs(i);
        end loop;
        IF (fnd_flex_server1.g_debug_level > 0) THEN
          FND_FLEX_SERVER1.add_debug('  Context-sensitive segments: ');
        END IF;
        IF (context_segment.ids(1) is NOT NULL) THEN
          return_code := validate_context_segs(dff_info, context_segment.ids(1),
                           ncontext_segs_in, context_segs_in, vflags, v_date,
                           uappid, respid, context_segs, error_segnum);
        END IF;
        if(error_segnum is not null) then
          error_segnum := error_segnum + global_segs.nvalidated + 1;
        end if;
      end if;
    END IF;

    <<return_values>>

-- Join global segments, context segment and context-senstive segments
-- for output.
--
    if((append_vsegarray(global_segs, context_segment) = FALSE) or
       (append_vsegarray(global_segs, context_segs) = FALSE)) then
       return(FND_FLEX_SERVER1.VV_ERROR);
    end if;

--  Return all the segment info
--
    nsegs_out := global_segs.nvalidated;
    segfmts := global_segs.segfmts;
    segstats := global_segs.segstats;
    cols := global_segs.segcols;
    coltypes := global_segs.segcoltypes;
    v_dispvals := global_segs.dispvals;
    v_vals := global_segs.vals;
    v_ids := global_segs.ids;
    v_descs := global_segs.descs;
    desc_lens := global_segs.catdesclens;
    dispsegs := global_segs.dispsegs;

-- Prioritize errors and return code.
-- If error in global segments worse than that in context or
-- context-sensitive segments then use global error code, segnum and message.

-- Return context return code, error message and error segment by default.
--
    errsegn := error_segnum;

    if(global_return_code is not null) then
      if(global_return_code = FND_FLEX_SERVER1.VV_VALID) then
        null;
      elsif(global_return_code = FND_FLEX_SERVER1.VV_SECURED) then
        if((return_code is null) or
           (return_code = FND_FLEX_SERVER1.VV_VALID) or
           (return_code = FND_FLEX_SERVER1.VV_SECURED)) then
          goto return_global_error;
        end if;
      elsif(global_return_code = FND_FLEX_SERVER1.VV_VALUES) then
        if((return_code is null) or
           (return_code = FND_FLEX_SERVER1.VV_VALID) or
           (return_code = FND_FLEX_SERVER1.VV_SECURED) or
           (return_code = FND_FLEX_SERVER1.VV_VALUES)) then
          goto return_global_error;
        end if;
      else
        goto return_global_error;
      end if;
    end if;

    if(return_code is null) then
      return_code := FND_FLEX_SERVER1.VV_ERROR;
    end if;
    return(return_code);

    <<return_global_error>>
    errsegn := global_error_segnum;
    FND_MESSAGE.SET_ENCODED(global_error_msg);
    return(global_return_code);

  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG','validate_descsegs() exception:  '||SQLERRM);
      return(FND_FLEX_SERVER1.VV_ERROR);

  END validate_descsegs;

/* ----------------------------------------------------------------------- */
/*      Validates the context-sensitive segments of the descriptive        */
/*      for the context of the given name returning a validated context    */
/*      structure and error segment number relative to this context        */
/*      as output.  If context name is NULL, returns a valid context with  */
/*      0 segments.  Returns error code and sets FND_MESSAGE with error    */
/*      or returns FND_FLEX_SERVER1.VV_VALID if ok.                        */
/* ----------------------------------------------------------------------- */

  FUNCTION
  validate_context_segs(dff_info     IN  FND_FLEX_SERVER1.DescFlexInfo,
                        contxt_name  IN  VARCHAR2,
                        nsegs        IN  NUMBER,
                        segs         IN  FND_FLEX_SERVER1.StringArray,
                        vflags       IN  FND_FLEX_SERVER1.ValueValidationFlags,
                        vdate        IN  DATE,
                        uappid       IN  NUMBER,
                        respid       IN  NUMBER,
                        vsa          OUT nocopy ValidatedSegmentArray,
                        errsegnum    OUT nocopy NUMBER) RETURN NUMBER IS

    f_struct    FND_FLEX_SERVER1.FlexStructId;
    disp_segs   FND_FLEX_SERVER1.DisplayedSegs;
    no_vrules   FND_FLEX_SERVER1.Vrules;
    no_dvals    FND_FLEX_SERVER1.DerivedVals;
    no_dquals   FND_FLEX_SERVER1.Qualifiers;

    l_nsegs_out   NUMBER;
    l_segfmts     FND_FLEX_SERVER1.segformats;
    l_segstats    VARCHAR2(201);
    l_tabcols     FND_FLEX_SERVER1.tabcolarray;
    l_tabcoltypes FND_FLEX_SERVER1.chararray;
    l_v_dispvals  FND_FLEX_SERVER1.valuearray;
    l_v_vals      FND_FLEX_SERVER1.valuearray;
    l_v_ids       FND_FLEX_SERVER1.valueidarray;
    l_v_descs     FND_FLEX_SERVER1.valuedescarray;
    l_desc_lens   FND_FLEX_SERVER1.numberarray;
    l_errsegn     NUMBER;
    l_ret_code    NUMBER;
  BEGIN
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        FND_FLEX_SERVER1.add_debug(fnd_global.newline ||
                                   'BEGIN SV4.validate_context_segs() ');
     END IF;


--  Initialize returned ValidatedSegmentArray to no segments.
--
    initialize_vsegarray(vsa);

--  Return a null ValidatedSegmentArray if no context name.
--
    if(contxt_name is null) then
      return(FND_FLEX_SERVER1.VV_VALID);
    end if;

--  Set up flex structure
--
    f_struct.isa_key_flexfield := FALSE;
    f_struct.application_id := dff_info.application_id;
    f_struct.desc_flex_name := dff_info.name;
    f_struct.desc_flex_context := contxt_name;

--  Set up dummy vrules.  No vrules for descriptive flexfields
--
    no_vrules.nvrules := 0;

--  Determine displayed segments for this context
--
    if(FND_FLEX_SERVER.parse_displayed(f_struct, 'ALL', disp_segs)) then
       l_ret_code := FND_FLEX_SERVER1.validate_struct
         (f_struct, dff_info.table_appl_id,
          dff_info.table_id, nsegs, segs, disp_segs, vflags,
          vdate, no_vrules, uappid, respid,
          l_nsegs_out, l_segfmts, l_segstats, l_tabcols,
          l_tabcoltypes, l_v_dispvals, l_v_vals,
          l_v_ids, l_v_descs, l_desc_lens,
          no_dvals, no_dquals, l_errsegn);

       vsa.nvalidated  := l_nsegs_out;
       vsa.segfmts     := l_segfmts;
       vsa.segstats    := l_segstats;
       vsa.segcols     := l_tabcols;
       vsa.segcoltypes := l_tabcoltypes;
       vsa.dispvals    := l_v_dispvals;
       vsa.vals        := l_v_vals;
       vsa.ids         := l_v_ids;
       vsa.descs       := l_v_descs;
       vsa.catdesclens := l_desc_lens;
       errsegnum       := l_errsegn;
       vsa.dispsegs    := disp_segs;
       RETURN(l_ret_code);
    end if;
    return(FND_FLEX_SERVER1.VV_ERROR);

  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG', 'validate_context_segs() exception: '
                                                               || SQLERRM);
      return(FND_FLEX_SERVER1.VV_ERROR);

  END validate_context_segs;

/* ----------------------------------------------------------------------- */
/*      Validates the context value for the specified descriptive          */
/*      flexfield.  Returns an error code and sets FND_MESSAGE on error    */
/*      or returns FND_FLEX_SERVER1.VV_VALID and a ValidatedSegmentArray   */
/*      with only one segment if valid.                                    */
/*      Note:  Unlike regular value validation, validation must always     */
/*      stop if the context segment is invalid because the remaining       */
/*      segments all depend on it.                                         */
/* ----------------------------------------------------------------------- */

  FUNCTION
       validate_context(dff_info     IN  FND_FLEX_SERVER1.DescFlexInfo,
                        context_sval IN  VARCHAR2,
                        vflags       IN  FND_FLEX_SERVER1.ValueValidationFlags,
                        vsa          OUT nocopy ValidatedSegmentArray)
                                                        RETURN NUMBER IS

    context_segval      VARCHAR2(80);
    context_id          VARCHAR2(30);
    context_val         VARCHAR2(80);
    context_description VARCHAR2(240);
    context_displayed   BOOLEAN;
    vcode               VARCHAR2(1);
    l_id_or_value       VARCHAR2(10);
    l_max_lengthb       NUMBER;
    l_global_flag       VARCHAR2(10);
    vset                FND_VSET.valueset_r;
    fmt                 FND_VSET.valueset_dr;
    c_found             BOOLEAN;
    c_row               NUMBER;
    c_value             FND_VSET.value_dr;

  BEGIN
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        FND_FLEX_SERVER1.add_debug(fnd_global.newline ||
                                   'BEGIN SV4.validate_context() ');
     END IF;


--  Prepare to return error in case of exception
--
    context_displayed := (dff_info.context_override = 'Y');

    vsa.nvalidated := 1;
    vsa.segstats := FND_FLEX_SERVER1.FF_VERROR;
    vsa.segfmts.nsegs := 1;
    vsa.segfmts.vs_format(1) := 'C';
    vsa.segfmts.vs_maxsize(1) := 30;
    vsa.segcols(1) := dff_info.context_column;
    vsa.segcoltypes(1) := 'V';
    vsa.dispvals(1) := context_sval;
    vsa.vals(1) := context_sval;
    vsa.ids(1) := context_sval;
    vsa.descs(1) := NULL;
    vsa.catdesclens(1) := 240;
    vsa.dispsegs.n_segflags := 1;
    vsa.dispsegs.segflags(1) := context_displayed;

    IF (fnd_flex_server1.g_debug_level > 0) THEN
       FND_FLEX_SERVER1.add_debug('CONTEXT:'||context_sval);
    END IF;

--  Strip whitespace from around context value only if its a value
--
    if(vflags.values_not_ids) THEN
       l_id_or_value := 'V';
       l_max_lengthb := 80;
       context_segval := SUBSTRB(LTRIM(RTRIM(context_sval)), 1, l_max_lengthb);
     ELSE
       l_id_or_value := 'I';
       l_max_lengthb := 30;
       context_segval := SUBSTRB(context_sval, 1, l_max_lengthb);
    end if;

    if((context_segval is not null) and
       (LENGTHB(context_segval) > l_max_lengthb)) then
      FND_MESSAGE.set_name('FND', 'FLEX-VALUE TOO LONG');
      FND_MESSAGE.set_token('VALUE', context_segval || '...');
      FND_MESSAGE.set_token('LENGTH', to_char(l_max_lengthb));
      vcode := FND_FLEX_SERVER1.FF_VFORMAT;
      goto return_status;
    end if;

--  Default the context if necessary
--
    if((context_segval is null) and
       ((context_displayed and vflags.default_all_displayed) or
         ((dff_info.context_required = 'Y') and vflags.default_all_required) or
         ((dff_info.context_required = 'Y') and (not context_displayed) and
          vflags.default_non_displayed))) then
      context_segval := dff_info.default_context;
      IF (fnd_flex_server1.g_debug_level > 0) THEN
         FND_FLEX_SERVER1.add_debug('Defaulted context segment to '
                                    || context_segval);
      END IF;
    end if;

    IF (context_segval IS NOT NULL) THEN
       vcode := find_context_value(dff_info.application_id, dff_info.name,
                                   l_id_or_value, context_segval, context_id,
                                   context_val, context_description, l_global_flag);
       if (vcode = FND_FLEX_SERVER1.FF_CTXTNOSEG) THEN
          IF (dff_info.context_override_value_set_id IS NOT NULL) THEN
             fnd_vset.get_valueset(dff_info.context_override_value_set_id, vset, fmt);
             fnd_vset.get_value_init(vset, TRUE);
             fnd_vset.get_value(vset, c_row, c_found, c_value);
             WHILE(c_found) LOOP
                IF (context_segval = c_value.value) THEN
                   vcode := FND_FLEX_SERVER1.FF_VVALID;
                   EXIT;
                END IF;
                fnd_vset.get_value(vset, c_row, c_found, c_value);
             END LOOP;
             fnd_vset.get_value_end(vset);
             IF (c_found = FALSE) THEN
                vcode:= FND_FLEX_SERVER1.FF_VNOTFOUND;
             END IF;
          END IF;

       END IF;
       --
       -- Some developers set Global as regular context.
       --
       IF (l_global_flag = 'Y') THEN
          IF (fnd_flex_server1.g_debug_level > 0) THEN
             FND_FLEX_SERVER1.add_debug('Setting context to NULL, Global Data Elements is not a context.');
          END IF;
          context_id := NULL;
          context_val := NULL;
          context_description := NULL;
       END IF;
    END IF;

--  If value still null its an error if required, or valid if not.
--

    if(context_segval is null) then
      if((dff_info.context_required = 'N') or (vflags.allow_nulls)) then
        vcode := FND_FLEX_SERVER1.FF_VVALID;
      else
        vcode := FND_FLEX_SERVER1.FF_VREQUIRED;
        if(vflags.message_on_null) then
          FND_MESSAGE.set_name('FND', 'FLEX-MISSING CONTEXT VALUE');
          FND_MESSAGE.set_token('FLEXFIELD', dff_info.name);
--        FND_MESSAGE.set_name('FND', 'FLEX-NULL SEGMENT');
        end if;
      end if;
    end if;

    <<return_status>>
--  Return vcode as the segment status
--
    vsa.segstats := vcode;

--  Pretend context field is a non-validated character value set
--  I assume context field must be on a VARCHAR2 type column.
--
    if(vcode = FND_FLEX_SERVER1.FF_VVALID) then
      vsa.dispvals(1) := context_val;
      vsa.vals(1) := context_val;
      vsa.ids(1) := context_id;
      vsa.descs(1) := context_description;
      return(FND_FLEX_SERVER1.VV_VALID);
    elsif(vcode = FND_FLEX_SERVER1.FF_VERROR) then
      return(FND_FLEX_SERVER1.VV_ERROR);
    else
      FND_MESSAGE.set_name('FND', 'FLEX-CONTEXT NOT FOUND');
      FND_MESSAGE.set_token('VALUE', context_segval);
      FND_MESSAGE.set_token('DFF', dff_info.name);
      return(FND_FLEX_SERVER1.VV_VALUES);
    end if;

    return(FND_FLEX_SERVER1.VV_ERROR);

  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG', 'validate_context() exception: '||SQLERRM);
      return(FND_FLEX_SERVER1.VV_ERROR);

  END validate_context;

/* ----------------------------------------------------------------------- */
/*      Appends segments from one ValidatedSegmentArray to another.        */
/*      Returns TRUE if OK, or FALSE if any errors.                        */
/* ----------------------------------------------------------------------- */

  FUNCTION append_vsegarray(destvsa    IN OUT  nocopy ValidatedSegmentArray,
                            sourcevsa  IN      ValidatedSegmentArray)
                                                             RETURN BOOLEAN IS
    n   NUMBER;

  BEGIN
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        FND_FLEX_SERVER1.add_debug(fnd_global.newline ||
                                   'BEGIN SV4.append_vsegarray() ');
     END IF;

    n := destvsa.nvalidated;
    for i in 1..sourcevsa.nvalidated loop
      n := n + 1;
      destvsa.segfmts.vs_format(n) := sourcevsa.segfmts.vs_format(i);
      destvsa.segfmts.vs_maxsize(n) := sourcevsa.segfmts.vs_maxsize(i);
      destvsa.segcols(n) := sourcevsa.segcols(i);
      destvsa.segcoltypes(n) := sourcevsa.segcoltypes(i);
      destvsa.dispvals(n) := sourcevsa.dispvals(i);
      destvsa.vals(n) := sourcevsa.vals(i);
      destvsa.ids(n) := sourcevsa.ids(i);
      destvsa.descs(n) := sourcevsa.descs(i);
      destvsa.catdesclens(n) := sourcevsa.catdesclens(i);
      destvsa.dispsegs.segflags(n) := sourcevsa.dispsegs.segflags(i);
    end loop;

    destvsa.nvalidated := n;
    destvsa.segfmts.nsegs := n;
    destvsa.dispsegs.n_segflags := n;
    destvsa.segstats := destvsa.segstats || sourcevsa.segstats;

    return(TRUE);

  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG','append_vsegarray() exception:  '||SQLERRM);
      return(FALSE);

  END append_vsegarray;

/* ----------------------------------------------------------------------- */
/*      Initializes ValidatedSegmentArray.                                 */
/* ----------------------------------------------------------------------- */

  PROCEDURE initialize_vsegarray(v_seg_array  OUT nocopy ValidatedSegmentArray) IS
  BEGIN
    v_seg_array.nvalidated := 0;
    v_seg_array.segfmts.nsegs := 0;
    v_seg_array.dispsegs.n_segflags := 0;
  END initialize_vsegarray;

/* ----------------------------------------------------------------------- */
/*      Initializes ColumnDefinitions.                                     */
/* ----------------------------------------------------------------------- */

  PROCEDURE init_coldef(column_defn OUT nocopy FND_FLEX_SERVER1.ColumnDefinitions) IS
  BEGIN
    column_defn.context_value_set := FALSE;
    column_defn.context_value := NULL;
    init_colvals(column_defn.colvals);
  END init_coldef;

/* ----------------------------------------------------------------------- */
/*      Initializes ColumnValues.                                          */
/* ----------------------------------------------------------------------- */

  PROCEDURE init_colvals(column_vals OUT nocopy FND_FLEX_SERVER1.ColumnValues) IS
  BEGIN
    column_vals.ncolumns := 0;
  END init_colvals;

/* ----------------------------------------------------------------------- */
/*      Finds enabled context value and description from context segment.  */
/*      Only considers enabled contexts.                                   */
/*                                                                         */
/*      In future we may support:                                          */
/*      If no context is found that exactly matches the context segment    */
/*      input, then a case-insensitive match is done on values that start  */
/*      with the context segment input.  If only one value matches that,   */
/*      that context is returned.  Otherwise the context is not found.     */
/*                                                                         */
/*      Returns value validation code FND_FLEX_SERVER1.FF_VALID if ok.     */
/*      Otherwise sets error message in FND_MESSAGE and returns            */
/*      FF_VVALUES if not found or FF_VERROR on error.                     */
/* ----------------------------------------------------------------------- */

  FUNCTION find_context_value(appl_id       IN  VARCHAR2,
                              dflex_name    IN  VARCHAR2,
                              p_id_or_value IN  VARCHAR2,
                              seg_in        IN  VARCHAR2,
                              context_id    OUT nocopy VARCHAR2,
                              context_val   OUT nocopy VARCHAR2,
                              context_desc  OUT nocopy VARCHAR2,
                              p_global_flag OUT nocopy VARCHAR2) RETURN VARCHAR2 IS

    vcode               VARCHAR2(1);

  BEGIN
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        FND_FLEX_SERVER1.add_debug(fnd_global.newline ||
                                   'BEGIN SV4.find_context_value(' ||
                                   p_id_or_value || ',' || seg_in ||') ');
     END IF;

     g_cache_key := (appl_id || '.' || dflex_name || '.' ||
                     p_id_or_value  || '.' || seg_in);
     fnd_plsql_cache.generic_1to1_get_value(cxc_cache_controller,
                                            cxc_cache_storage,
                                            g_cache_key,
                                            g_cache_value,
                                            g_cache_return_code);
     IF (g_cache_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
        NULL;
      ELSE
        SELECT
          descriptive_flex_context_code,
          descriptive_flex_context_name,
          description,
          global_flag
          INTO
          g_cache_value.varchar2_1,
          g_cache_value.varchar2_2,
          g_cache_value.varchar2_3,
          g_cache_value.varchar2_4
      FROM fnd_descr_flex_contexts_vl
     WHERE application_id = appl_id
       AND descriptive_flexfield_name = dflex_name
       AND ((p_id_or_value = 'I' AND
             descriptive_flex_context_code = seg_in) OR
            (p_id_or_value = 'V' AND
             descriptive_flex_context_name = seg_in))
       AND enabled_flag = 'Y';

        fnd_plsql_cache.generic_1to1_put_value(cxc_cache_controller,
                                               cxc_cache_storage,
                                               g_cache_key,
                                               g_cache_value);
     END IF;

     context_id := g_cache_value.varchar2_1;
     context_val := g_cache_value.varchar2_2;
     context_desc := g_cache_value.varchar2_3;
     p_global_flag := g_cache_value.varchar2_4;

     return(FND_FLEX_SERVER1.FF_VVALID);

  EXCEPTION
    WHEN NO_DATA_FOUND then
----      vcode := context_vs_validation();
--      context_id := seg_in;
--      context_val := seg_in;
--      context_desc := 'Dummy';
--      p_global_flag := 'X';
        vcode := FND_FLEX_SERVER1.FF_CTXTNOSEG;
--      IF(vcode = FND_FLEX_SERVER1.FF_CTXTNOSEG) THEN
        return(FND_FLEX_SERVER1.FF_CTXTNOSEG);
--      ELSE
--        FND_MESSAGE.set_name('FND', 'FLEX-CONTEXT NOT FOUND');
--        FND_MESSAGE.set_token('VALUE', seg_in);
--        FND_MESSAGE.set_token('DFF', dflex_name);
--        return(FND_FLEX_SERVER1.FF_VNOTFOUND);
--      END IF;
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG','find_context_value() exception: '||SQLERRM);
      return(FND_FLEX_SERVER1.FF_VERROR);

   END find_context_value;

/* ----------------------------------------------------------------------- */
/*      Gets the name of the global context for the specified flexfield.   */
/*      Error if the global context name is not enabled.                   */
/*      Returns TRUE if OK or FALSE and sets FND_MESSAGE if error.         */
/* ----------------------------------------------------------------------- */

  FUNCTION get_global_context(appl_id      IN  NUMBER,
                              dflex_name   IN  VARCHAR2,
                              glob_context OUT nocopy VARCHAR2) RETURN BOOLEAN IS
  BEGIN
     IF (fnd_flex_server1.g_debug_level > 0) THEN
        FND_FLEX_SERVER1.add_debug(fnd_global.newline ||
                                   'BEGIN SV4.get_global_context() ');
     END IF;

     g_cache_key := appl_id || '.' || dflex_name;
     fnd_plsql_cache.generic_1to1_get_value(gcc_cache_controller,
                                            gcc_cache_storage,
                                            g_cache_key,
                                            g_cache_value,
                                            g_cache_return_code);
     IF (g_cache_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
        NULL;
      ELSE
        SELECT
          descriptive_flex_context_code
          INTO
          g_cache_value.varchar2_1
          FROM fnd_descr_flex_contexts
          WHERE application_id = appl_id
          AND descriptive_flexfield_name = dflex_name
          AND enabled_flag = 'Y'
          AND global_flag = 'Y';

        fnd_plsql_cache.generic_1to1_put_value(gcc_cache_controller,
                                               gcc_cache_storage,
                                               g_cache_key,
                                               g_cache_value);
     END IF;

     glob_context := g_cache_value.varchar2_1;

     return(TRUE);

  EXCEPTION
    WHEN NO_DATA_FOUND then
      FND_MESSAGE.set_name('FND', 'FLEX-NO ENABLED GLOBAL CONTEXT');
      return(FALSE);
    WHEN TOO_MANY_ROWS then
      FND_MESSAGE.set_name('FND', 'FLEX-DUPLICATE GLOBAL CONTEXTS');
      FND_MESSAGE.set_token('APID', appl_id);
      FND_MESSAGE.set_token('NAME', dflex_name);
      return(FALSE);
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG','get_global_context() exception: '||SQLERRM);
      return(FALSE);
  END get_global_context;

/* ----------------------------------------------------------------------- */

BEGIN
   fnd_plsql_cache.generic_1to1_init('SV4.CXC',
                                     cxc_cache_controller,
                                     cxc_cache_storage);

   fnd_plsql_cache.generic_1to1_init('SV4.GCC',
                                     gcc_cache_controller,
                                     gcc_cache_storage);
END fnd_flex_server4;

/
