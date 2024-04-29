--------------------------------------------------------
--  DDL for Package Body FND_FLEX_KEYVAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FLEX_KEYVAL" AS
/* $Header: AFFFKVLB.pls 120.2.12010000.7 2016/08/17 17:03:02 tebarnes ship $ */


  -- PRIVATE CONSTANTS
  --

  -- PRIVATE FUNCTIONS
  --

FUNCTION init_all(p_resp_appl_id IN NUMBER,
                  p_resp_id      IN NUMBER,
                  p_user_id      IN NUMBER,
                  x_resp_appl_id OUT nocopy NUMBER,
                  x_resp_id      OUT nocopy NUMBER,
                  x_user_id      OUT nocopy NUMBER)
  RETURN BOOLEAN;

  PROCEDURE clear_combination_globals;

  PROCEDURE clear_all_but_error;


  -- PRIVATE GLOBAL VARIABLES
  --

  nvalidated            NUMBER;
  value_vals            FND_FLEX_SERVER1.ValueArray;
  value_svals           FND_FLEX_SERVER1.ValueArray;
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
  ccid                  NUMBER;
  delim                 VARCHAR2(1);
  err_segn              NUMBER;
  err_msg               VARCHAR2(2000);
  err_text              VARCHAR2(2000);
  segcodes              VARCHAR2(30);
  new_comb              BOOLEAN;

-- Return statuses
--
  sta_valid             BOOLEAN;
  sta_secured           BOOLEAN;
  sta_value_err         BOOLEAN;
  sta_unsupported_err   BOOLEAN;
  sta_serious_err       BOOLEAN;

/* ----------------------------------------------------------------------- */
/*      Please see package specification for public function documentation.*/
/* ----------------------------------------------------------------------- */

  FUNCTION validate_segs(operation              IN  VARCHAR2,
                         appl_short_name        IN  VARCHAR2,
                         key_flex_code          IN  VARCHAR2,
                         structure_number       IN  NUMBER,
                         concat_segments        IN  VARCHAR2,
                         values_or_ids          IN  VARCHAR2 DEFAULT 'V',
                         validation_date        IN  DATE DEFAULT SYSDATE,
                         displayable            IN  VARCHAR2 DEFAULT 'ALL',
                         data_set               IN  NUMBER   DEFAULT NULL,
                         vrule                  IN  VARCHAR2 DEFAULT NULL,
                         where_clause           IN  VARCHAR2 DEFAULT NULL,
                         get_columns            IN  VARCHAR2 DEFAULT NULL,
                         allow_nulls            IN  BOOLEAN  DEFAULT FALSE,
                         allow_orphans          IN  BOOLEAN  DEFAULT FALSE,
                         resp_appl_id           IN  NUMBER   DEFAULT NULL,
                         resp_id                IN  NUMBER   DEFAULT NULL,
                         user_id                IN  NUMBER   DEFAULT NULL,
                         select_comb_from_view  IN  VARCHAR2 DEFAULT NULL,
                         no_combmsg             IN  VARCHAR2 DEFAULT NULL,
                         where_clause_msg       IN  VARCHAR2 DEFAULT NULL)
                                                            RETURN BOOLEAN IS
    resp_apid   NUMBER;
    uresp_id    NUMBER;
    userid      NUMBER;
    valid_stat          NUMBER;
    dins_flag           VARCHAR2(1);
    nulls_ok            VARCHAR2(1);
    required_flag       VARCHAR2(1);
    invoking_mode       VARCHAR2(1);
    validate_mode       VARCHAR2(30);
    catsegs_in          VARCHAR2(5000);

  BEGIN

--  Initialize everything including all global variables and set user
--
    if(init_all(resp_appl_id, resp_id, user_id,
                resp_apid, uresp_id, userid) = FALSE) then
      goto cleanup_and_return;
    end if;

-- Set up flags and optional inputs
--
    nulls_ok := 'N';
    required_flag := 'N';
    invoking_mode := 'V';
    validate_mode := 'FULL';
    catsegs_in := SUBSTRB(concat_segments, 1, 5000);

--  Set rest of parameters based on the requested operation
--
    if(operation = 'FIND_COMBINATION') then
      dins_flag := 'N';
    elsif(operation = 'CREATE_COMBINATION') then
      dins_flag := 'Y';
      required_flag := 'Y';                       -- Bug 1526918
-- CAUTION....CAUTION....CAUTION....CAUTION
-- Operation CREATE_COMBINATION_Z may ONLY be used with prior written
-- permission from the flex team manager. Used incorrectly, this operation
-- has the potential for creating combinations with data integrity issues.
-- If used without permission, the flex team will NOT assist with correcting
-- corrupt data.
    elsif(operation = 'CREATE_COMBINATION_Z') then
         dins_flag := 'Y';
         required_flag := 'Y';
         invoking_mode := 'Z';
--  Bug 1531345
    elsif(operation = 'CREATE_COMB_NO_AT') then
      dins_flag := 'O';
      required_flag := 'Y';
    elsif(operation = 'CHECK_COMBINATION') then
      invoking_mode := 'P';
--  Bug 1414119 - Change dins_flag from 'Y' to 'D'
      dins_flag := 'D';
--    elsif(operation = 'DEFAULT_SEGMENTS') then
--      catsegs_in := NULL;
--      invoking_mode := 'P';
--      dins_flag := 'Y';
--      required_flag := 'Y';
    elsif(operation = 'CHECK_ACTIVE_COMB') then
      invoking_mode := 'G';
      dins_flag := 'D';
    elsif(operation = 'CHECK_SEGMENTS') then
      invoking_mode := 'P';
      if(allow_nulls) then
        nulls_ok := 'Y';
      end if;
      if(allow_orphans) then
        validate_mode := 'PARTIAL_IF_POSSIBLE';
      else
        validate_mode := 'PARTIAL';
      end if;
      dins_flag := 'N';
    else
      FND_MESSAGE.set_name('FND', 'FLEX-BAD OPERATION');
      FND_MESSAGE.set_token('FUNCTNAME', operation);
      goto cleanup_and_return;
    end if;

    FND_FLEX_SERVER.validation_engine(resp_apid, uresp_id, userid,
        appl_short_name, key_flex_code,
        select_comb_from_view, structure_number,
        validation_date, vrule, data_set, invoking_mode,
        validate_mode, dins_flag, 'Y', required_flag, nulls_ok,
        displayable, catsegs_in, values_or_ids, where_clause,
        no_combmsg, where_clause_msg,
        get_columns, NULL, nvalidated, value_vals, value_svals, value_ids,
        value_descs, value_desclens, cc_cols, cc_coltypes, segtypes,
        disp_segs, derv, tbl_derv, drv_quals, tbl_quals,
        n_xcol_vals, xcol_vals, delim, ccid, new_comb, valid_stat,
        segcodes, err_segn);

--  Set status flags.  Secured also set if any segment is secured and there
--  is some other error.
--
    sta_valid := (valid_stat = FND_FLEX_SERVER1.VV_VALID);
    sta_secured := ((valid_stat = FND_FLEX_SERVER1.VV_SECURED) or
                   (INSTR(segcodes, FND_FLEX_SERVER1.FF_VSECURED) > 0));
    sta_value_err := (valid_stat = FND_FLEX_SERVER1.VV_VALUES);
    sta_unsupported_err := (valid_stat = FND_FLEX_SERVER1.VV_UNSUPPORTED);
    sta_serious_err := (valid_stat = FND_FLEX_SERVER1.VV_ERROR);

--  Get message if not valid.
--  Erase only the combination_id, and table columns if just checking
--  segments, otherwise erase everything but the status and error message.
--
    <<cleanup_and_return>>
    if(not sta_valid) then
      err_msg := FND_MESSAGE.get_encoded;
      if(sta_unsupported_err or sta_serious_err or
         (operation not in ('DEFAULT_SEGMENTS', 'CHECK_SEGMENTS'))) then
        clear_all_but_error;
      end if;
    end if;
    return(sta_valid);

  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG','validate_segs() exception: '||SQLERRM);
      err_msg := FND_MESSAGE.get_encoded;
      return(FALSE);

  END validate_segs;

/* ------------------------------------------------------------------------ */

  FUNCTION validate_ccid(appl_short_name        IN  VARCHAR2,
                         key_flex_code          IN  VARCHAR2,
                         structure_number       IN  NUMBER,
                         combination_id         IN  NUMBER,
                         displayable            IN  VARCHAR2 DEFAULT 'ALL',
                         data_set               IN  NUMBER   DEFAULT NULL,
                         vrule                  IN  VARCHAR2 DEFAULT NULL,
                         security               IN  VARCHAR2 DEFAULT 'IGNORE',
                         get_columns            IN  VARCHAR2 DEFAULT NULL,
                         resp_appl_id           IN  NUMBER   DEFAULT NULL,
                         resp_id                IN  NUMBER   DEFAULT NULL,
                         user_id                IN  NUMBER   DEFAULT NULL,
                         select_comb_from_view  IN  VARCHAR2 DEFAULT NULL)
                                                        RETURN BOOLEAN IS
    resp_apid   NUMBER;
    uresp_id    NUMBER;
    userid      NUMBER;
    valid_stat  NUMBER;
    n_dispsegs  NUMBER;
    q_security  VARCHAR2(1);
    catvals     VARCHAR2(5000);

  BEGIN

--  Initialize everything including all global variables and set user
--  Isvalid is initialized to FALSE, serious_error initialized to TRUE.
--
    if(init_all(resp_appl_id, resp_id, user_id,
                resp_apid, uresp_id, userid) = FALSE) then
      goto cleanup_and_return;
    end if;

--  Set q_security based on security mode.
--
    if(security = 'IGNORE') then
      q_security := 'N';
    elsif (security = 'CHECK') then
      q_security := 'X';
    elsif (security = 'ENFORCE') then
      q_security := 'Y';
    else
      FND_MESSAGE.set_name('FND', 'FLEX-BAD SECURITY');
      goto cleanup_and_return;
    end if;

    FND_FLEX_SERVER.validation_engine(resp_apid, uresp_id, userid,
        appl_short_name, key_flex_code,
        select_comb_from_view, structure_number,
        NULL, vrule, data_set, 'L', 'FULL', 'N', q_security, 'N', 'N',
        displayable, NULL, 'V', NULL, NULL, NULL, get_columns,
        combination_id, nvalidated, value_vals, value_svals, value_ids,
        value_descs, value_desclens, cc_cols, cc_coltypes, segtypes,
        disp_segs, derv, tbl_derv, drv_quals, tbl_quals,
        n_xcol_vals, xcol_vals, delim, ccid, new_comb, valid_stat,
        segcodes, err_segn);

--  Set validation status flags.
--  Also valid if secured, but not enforcing it.
--
    sta_valid := ((valid_stat = FND_FLEX_SERVER1.VV_VALID) or
                  ((valid_stat = FND_FLEX_SERVER1.VV_SECURED) and
                   (q_security <> 'Y')));
    sta_secured := ((valid_stat = FND_FLEX_SERVER1.VV_SECURED) or
                   (INSTR(segcodes, FND_FLEX_SERVER1.FF_VSECURED) > 0));
    sta_value_err := (valid_stat = FND_FLEX_SERVER1.VV_VALUES);
    sta_unsupported_err := (valid_stat = FND_FLEX_SERVER1.VV_UNSUPPORTED);
    sta_serious_err := (valid_stat = FND_FLEX_SERVER1.VV_ERROR);

--  Get message and erase all but error if not valid
--
    <<cleanup_and_return>>
    if(not sta_valid) then
      err_msg := FND_MESSAGE.get_encoded;
      clear_all_but_error;
    end if;
    return(sta_valid);

  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG', 'validate_ccid() exception:  ' || SQLERRM);
      err_msg := FND_MESSAGE.get_encoded;
      return(FALSE);

  END validate_ccid;

/* ------------------------------------------------------------------------ */

FUNCTION is_valid RETURN BOOLEAN IS
BEGIN
  return(sta_valid);
END is_valid;

FUNCTION is_secured RETURN BOOLEAN IS
BEGIN
  return(sta_secured);
END is_secured;

FUNCTION value_error RETURN BOOLEAN IS
BEGIN
  return(sta_value_err);
END value_error;

FUNCTION unsupported_error RETURN BOOLEAN IS
BEGIN
  return(sta_unsupported_err);
END unsupported_error;

FUNCTION serious_error RETURN BOOLEAN IS
BEGIN
  return(sta_serious_err);
END serious_error;

FUNCTION new_combination RETURN BOOLEAN IS
BEGIN
  return(new_comb);
END new_combination;

FUNCTION error_segment RETURN NUMBER IS
BEGIN
  return(err_segn);
END error_segment;

------------------------------------------------------
-- Notes:
-- function error_message returns the text of an error message with the
--   ampersand literals replaced with the apropriate text value
--   Example:
--   Value Cultural Commissions Manager|137668| for the flexfield segment Name
--      does not exist in the value set UK_POSITION_NAME
-- function encoded_error_message returns the error message name with the
--   ampersand literal and associated text value appended to the message name,
--   each preceeded with the letter N
--   Example:
--   FND-VALUE DOES NOT EXOST N VALUE Cultural Commission Manager|137668| N
--      SEGMENT Name N VALUESET UK_POSITION_NAME

-- error_message() returns just the error msg txt without the msg name
-- ie "Value secured: Company is invalid"
-----------------------------------------------------

FUNCTION error_message RETURN VARCHAR2 IS
BEGIN
-- err_msg hold msg name and msg txt
-- err_text holds just msg txt.
  if((err_text is null) and (err_msg is not null)) then
-- Remove the msg name from the msg. Leave just the message text.
-- "FND FLEX-USER DEFINED ERROR N MSG Value secured: Company is invalid"
-- change to "Value secured: Company is invalid"
    FND_MESSAGE.set_encoded(err_msg);
    err_text := FND_MESSAGE.get;
  end if;
  return(err_text);
END error_message;


-- encoded_error_message() returns the error msg name and msg txt
-- ie "FND FLEX-USER DEFINED ERROR N MSG Value secured: Company is invalid"
FUNCTION encoded_error_message RETURN VARCHAR2 IS
BEGIN

  IF(err_msg is not null) then
    return(err_msg);
  ELSIF(err_text is not null) then
    return(err_text);
  ELSE
    return('encoded_error_message(): No error msg set');
  END IF;

END encoded_error_message;


FUNCTION combination_id RETURN NUMBER IS
BEGIN
  return(ccid);
END combination_id;

FUNCTION segment_delimiter RETURN VARCHAR2 IS
BEGIN
  return(delim);
END segment_delimiter;


FUNCTION concatenated_values RETURN VARCHAR2 IS
BEGIN
   IF (sta_valid) THEN
      return(FND_FLEX_SERVER.concatenate_values(nvalidated, value_vals,
                                                disp_segs, delim));
    ELSE
      raise_application_error
        (-20001, ('Developer Error: KVL.concatenated_values should not ' ||
                  'be called if validation fails.'));
   END IF;
END concatenated_values;


FUNCTION concatenated_ids RETURN VARCHAR2 IS
BEGIN
   IF (sta_valid) THEN
      return(FND_FLEX_SERVER.concatenate_ids(nvalidated, value_ids, delim));
    ELSE
      raise_application_error
        (-20001, ('Developer Error: KVL.concatenated_ids should not ' ||
                  'be called if validation fails.'));
   END IF;
END concatenated_ids;


FUNCTION concatenated_descriptions RETURN VARCHAR2 IS
BEGIN
   IF (sta_valid) THEN
      return(FND_FLEX_SERVER.concatenate_descriptions(nvalidated,
                value_descs, disp_segs, value_desclens, delim));
    ELSE
      raise_application_error
        (-20001, ('Developer Error: KVL.concatenated_descriptions should not '||
                  'be called if validation fails.'));
   END IF;
END concatenated_descriptions;


-- Implement derived_enabled_flag() if needed.

FUNCTION enabled_flag RETURN BOOLEAN IS
BEGIN
  return((tbl_derv.enabled_flag = 'Y'));
END enabled_flag;


FUNCTION summary_flag RETURN BOOLEAN IS
BEGIN
  return((tbl_derv.summary_flag = 'Y'));
END summary_flag;


FUNCTION start_date RETURN DATE IS
BEGIN
  return(tbl_derv.start_valid);
END start_date;


FUNCTION end_date RETURN DATE IS
BEGIN
  return(tbl_derv.end_valid);
END end_date;


FUNCTION segment_count RETURN NUMBER IS
BEGIN
  return(nvalidated);
END segment_count;


FUNCTION segment_value(segnum  IN  NUMBER) RETURN VARCHAR2 IS
BEGIN
  if(segnum between 1 and nvalidated) then
    return(value_vals(segnum));
  end if;
 return(NULL);
END segment_value;


FUNCTION segment_id(segnum  IN  NUMBER) RETURN VARCHAR2 IS
BEGIN
  if(segnum between 1 and nvalidated) then
    return(value_ids(segnum));
  end if;
 return(NULL);
END segment_id;


FUNCTION segment_description(segnum  IN  NUMBER) RETURN VARCHAR2 IS
BEGIN
  if(segnum between 1 and nvalidated) then
    return(value_descs(segnum));
  end if;
 return(NULL);
END segment_description;


FUNCTION segment_concat_desc_length(segnum  IN  NUMBER) RETURN NUMBER IS
BEGIN
  if(segnum between 1 and nvalidated) then
    return(value_desclens(segnum));
  end if;
 return(0);
END segment_concat_desc_length;


FUNCTION segment_displayed(segnum  IN  NUMBER) RETURN BOOLEAN IS
BEGIN
  if(segnum between 1 and disp_segs.n_segflags) then
    return(disp_segs.segflags(segnum));
  end if;
 return(FALSE);
END segment_displayed;


FUNCTION segment_valid(segnum  IN  NUMBER) RETURN BOOLEAN IS
BEGIN
  if((segcodes is not null) and (segnum between 1 and LENGTH(segcodes))) then
    return(SUBSTR(segcodes, segnum, 1) = FND_FLEX_SERVER1.FF_VVALID);
  end if;
 return(FALSE);
END segment_valid;


FUNCTION segment_column_name(segnum  IN  NUMBER) RETURN VARCHAR2 IS
BEGIN
  if(segnum between 1 and nvalidated) then
    return(cc_cols(segnum));
  end if;
 return(NULL);
END segment_column_name;

-- Returns segment column type as 'VARCHAR2', 'NUMBER' or 'DATE'
-- or returns NULL if unknown type of segment index out of range.
--
FUNCTION segment_column_type(segnum  IN  NUMBER) RETURN VARCHAR2 IS
  type_code VARCHAR2(1);
BEGIN
  if(segnum between 1 and nvalidated) then
    type_code := cc_coltypes(segnum);
    if(type_code = 'V') then
      return('VARCHAR2');
    elsif(type_code = 'N') then
      return('NUMBER');
    elsif(type_code = 'D') then
      return('DATE');
    else
      return(NULL);
    end if;
  end if;
 return(NULL);
END segment_column_type;

FUNCTION column_count RETURN NUMBER IS
BEGIN
  return(n_xcol_vals);
END column_count;


FUNCTION column_value(colnum  IN  NUMBER) RETURN VARCHAR2 IS
BEGIN
  if(colnum between 1 and n_xcol_vals) then
    return(xcol_vals(colnum));
  end if;
 return(NULL);
END column_value;


FUNCTION qualifier_value(segqual_name      IN  VARCHAR2,
                         table_or_derived  IN  VARCHAR2  DEFAULT 'D')
                                                        RETURN VARCHAR2 IS
  qual_val      VARCHAR2(2000);
  sq_name       VARCHAR2(30);
BEGIN
  sq_name := SUBSTRB(UPPER(segqual_name), 1, 30);
  if(table_or_derived = 'T') then
    for i in 1..tbl_quals.nquals loop
      if(tbl_quals.sq_names(i) = sq_name) then
        qual_val := tbl_quals.sq_values(i);
        exit;
      end if;
    end loop;
  else
    for i in 1..drv_quals.nquals loop
      if(drv_quals.sq_names(i) = sq_name) then
        qual_val := drv_quals.sq_values(i);
        exit;
      end if;
    end loop;
  end if;
  return(qual_val);
END qualifier_value;

/* ------------------------------------------------------------------------ */
/*                      PRIVATE FUNCTIONS                                   */
/* ------------------------------------------------------------------------ */

/* ------------------------------------------------------------------------ */
/*      Initializes global variables, status, and determines user.          */
/*      Returns TRUE on success or FALSE and sets error message on failure. */
/* ------------------------------------------------------------------------ */

FUNCTION init_all(p_resp_appl_id IN NUMBER,
                  p_resp_id      IN NUMBER,
                  p_user_id      IN NUMBER,
                  x_resp_appl_id OUT nocopy NUMBER,
                  x_resp_id      OUT nocopy NUMBER,
                  x_user_id      OUT nocopy NUMBER)
  RETURN BOOLEAN
  IS
BEGIN
   --
   --  Initialize messages, debugging, and number of sql strings
   --
   if(FND_FLEX_SERVER1.init_globals = FALSE) then
      return(FALSE);
   end if;

   --
   --  Default security settings, if null.
   --
   x_resp_appl_id := Nvl(p_resp_appl_id, fnd_global.resp_appl_id());
   x_resp_id := Nvl(p_resp_id, fnd_global.resp_id());
   x_user_id := Nvl(p_user_id, fnd_global.user_id());

   --
   --  Initialize status codes
   --
   sta_valid := FALSE;
   sta_secured := FALSE;
   sta_value_err := FALSE;
   sta_unsupported_err := FALSE;
   sta_serious_err := TRUE;
   new_comb := FALSE;

   --
   --  Initialize other globals
   --
   err_segn := NULL;
   err_msg := NULL;
   err_text := NULL;
   clear_all_but_error;

   return(TRUE);

EXCEPTION
   WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG','init_all() exception: ' || SQLERRM);
      return(FALSE);

END init_all;

/* ------------------------------------------------------------------------ */
/*      Clears everything associated with a combination that is not         */
/*      associated with individual segments.                                */
/* ------------------------------------------------------------------------ */

  PROCEDURE clear_combination_globals IS
  BEGIN
    n_xcol_vals := 0;
    ccid := NULL;
    tbl_quals.nquals := 0;

  END clear_combination_globals;

/* ------------------------------------------------------------------------ */
/*      Clears everything except for the status codes and error messages.   */
/* ------------------------------------------------------------------------ */

  PROCEDURE clear_all_but_error IS
  BEGIN

--  Setting array counts to 0 initializes arrays
--
    nvalidated := 0;
    segtypes.nsegs := 0;
    disp_segs.n_segflags := 0;
    derv.enabled_flag := NULL;
    derv.summary_flag := NULL;
    derv.start_valid := NULL;
    derv.end_valid := NULL;
    tbl_derv := derv;
    drv_quals.nquals := 0;
    tbl_quals.nquals := 0;
    n_xcol_vals := 0;
    ccid := NULL;
    delim := NULL;
    segcodes := NULL;

  END clear_all_but_error;

/* ------------------------------------------------------------------------ */

END fnd_flex_keyval;

/
