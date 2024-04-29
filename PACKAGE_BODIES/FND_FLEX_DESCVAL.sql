--------------------------------------------------------
--  DDL for Package Body FND_FLEX_DESCVAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FLEX_DESCVAL" AS
/* $Header: AFFFDVLB.pls 120.2.12010000.8 2017/02/13 22:15:22 tebarnes ship $ */

--
-- PRIVATE CONSTANTS
--

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

PROCEDURE clear_all_but_error;

PROCEDURE set_stati(v_stat  IN  NUMBER);

FUNCTION return_status
  RETURN BOOLEAN;

PROCEDURE add_column_value(column_name  IN VARCHAR2,
                           column_value IN VARCHAR2,
                           column_type  IN VARCHAR2);

FUNCTION check_api_mode(values_or_ids IN VARCHAR2)
  RETURN VARCHAR2;

FUNCTION get_default_context(p_application_short_name     IN VARCHAR2,
                             p_descriptive_flexfield_name IN VARCHAR2)
  RETURN VARCHAR2;

FUNCTION get_ref_field_context(p_application_short_name     IN VARCHAR2,
                             p_descriptive_flexfield_name IN VARCHAR2)
  RETURN VARCHAR2;


/* ------------------------------------------------------------------------ */
/* The following functions use ROWID and so were not released.  The         */
/* FND_FLEX_SERVER4.descval_engine() supports this functionality and was    */
/* tested, but these cover functions were not.                              */
/* ------------------------------------------------------------------------ */

/* ------------------------------------------------------------------------ */
/*      LOAD_DESC():                                                        */
/*      Retrieves the descriptive flexfield information in an existing row  */
/*      specified by row_id.  If data_field is not null, the descriptive   */
/*      flexfield data is read from that column rather than the individual  */
/*      segment columns.  If interface_table is not null, the row is        */
/*      retrieved from that table rather than the table upon which the      */
/*      descriptive flexfield is defined.  Note that it is an error if the  */
/*      interface table does not contain segment and context value columns  */
/*      of the same names as those in the table upon which the descriptive  */
/*      flexfield is defined.  Also note it is an error if the specified    */
/*      row does not exist, or if the specified data column does not exist  */
/*      in the appropriate table.                                           */
/*                                                                          */
/*      Load_desc() is designed to retrieve existing valid data.  It does   */
/*      not return an error for values that are disabled, expired, or not   */
/*      allowed to be seen by the current user due to value security rules. */
/*                                                                          */
/*      Returns TRUE if all segments of the descriptive flexfield are       */
/*      valid.  Otherwise returns FALSE and sets the validation status      */
/*      codes to indicate the detailed nature of the error.                 */
/*      If this function returns TRUE, the segment information for the      */
/*      most recently validated flexfield can be retrieved using the data   */
/*      retrieval functions.  If the function returns FALSE, the segment    */
/*      data will be null, but the error message can be read.               */
/* ------------------------------------------------------------------------ */

  FUNCTION load_desc(appl_short_name    IN  VARCHAR2,
                     desc_flex_name     IN  VARCHAR2,
                     row_id             IN  ROWID,
                     data_field         IN  VARCHAR2 DEFAULT NULL,
                     interface_table    IN  VARCHAR2 DEFAULT NULL)
                                                        RETURN BOOLEAN;


/* ------------------------------------------------------------------------ */
/*      CHECK_DESC():                                                       */
/*      Checks that the descriptive flexfield information in an existing    */
/*      row is valid.  This function is designed to be used to verify that  */
/*      newly inserted descriptive flexfield information is correct.  It    */
/*      will indicate an error if any of the values are invalid, disabled,  */
/*      expired or not available for the current user because of value      */
/*      security rules.                                                     */
/*                                                                          */
/*      Returns TRUE if all segments of the descriptive flexfield are       */
/*      valid.  otherwise returns FALSE and sets the validation status      */
/*      codes to indicate the detailed nature of the error.                 */
/*      If this function returns TRUE, the segment information for the      */
/*      most recently validated flexfield can be retrieved using the data   */
/*      retrieval functions.  If the function returns FALSE, the segment    */
/*      data will be null, but the error message can be read.               */
/*                                                                          */
/*      ARGUMENTS:                                                          */
/*      ===========                                                         */
/*      The descriptive flexfield is identified by appl_short_name and      */
/*      desc_flex_name.  Row_id specifies the row that is to be checked.    */
/*      Ordinarily the row is in the table upon which the descriptive       */
/*      flexfield is defined.  If data_field is not null, the descriptive  */
/*      flexfield information in the form of concatenated segment ids is    */
/*      read from that column rather than from the individual segment       */
/*      columns.  If interface_table is not null, the row is retrieved from */
/*      that table rather than from the table upon which the descriptive    */
/*      flexfield is defined.  This allows the use of this function with    */
/*      an interface table where the descriptive flexfield information is   */
/*      validated on the interface table before being inserted into the     */
/*      production table.  The interface table must contain segment and     */
/*      context value columns with the same names as those in the table     */
/*      upon which the descriptive flexfield is defined.  Also note it is   */
/*      an error if the specified row does not exist, or if the specified   */
/*      data column does not exist in the appropriate table.                */
/*      The validation date is used to check whether the values are         */
/*      active for that date.  The resp_appl_id, and resp_id arguments      */
/*      identify the user for the purposes of value security rules.         */
/*      If these are not specified the values from FND_GLOBAL will          */
/*      be used.  The FND_GLOBAL values are set by the form or by           */
/*      the concurrent program that starts this database session.           */
/*      The enabled_activation flag is for internal use only.  It is not     */
/*      supported outside of the Application Object Library.                */
/* ------------------------------------------------------------------------ */

  FUNCTION check_desc(appl_short_name    IN  VARCHAR2,
                      desc_flex_name     IN  VARCHAR2,
                      row_id             IN  ROWID,
                      data_field         IN  VARCHAR2 DEFAULT NULL,
                      interface_table    IN  VARCHAR2 DEFAULT NULL,
                      validation_date    IN  DATE     DEFAULT SYSDATE,
                      enabled_activation IN  BOOLEAN  DEFAULT TRUE,
                      resp_appl_id       IN  NUMBER   DEFAULT NULL,
                      resp_id            IN  NUMBER   DEFAULT NULL)
                                                        RETURN BOOLEAN;

/* ------------------------------------------------------------------------ */

  -- PRIVATE GLOBAL VARIABLES
  --

  nvalidated            NUMBER;
  value_vals            FND_FLEX_SERVER1.ValueArray;
  value_svals           FND_FLEX_SERVER1.ValueArray;
  value_ids             FND_FLEX_SERVER1.ValueIdArray;
  value_descs           FND_FLEX_SERVER1.ValueDescArray;
  value_desclens        FND_FLEX_SERVER1.NumberArray;
  seg_cols              FND_FLEX_SERVER1.TabColArray;
  seg_coltypes          FND_FLEX_SERVER1.CharArray;
  segtypes              FND_FLEX_SERVER1.SegFormats;
  disp_segs             FND_FLEX_SERVER1.DisplayedSegs;
  delim                 VARCHAR2(1);
  err_segn              NUMBER;
  err_msg               VARCHAR2(2000);
  err_text              VARCHAR2(2000);
  segcodes              VARCHAR2(201);

-- Return statuses
--
  sta_valid             BOOLEAN;
  sta_secured           BOOLEAN;
  sta_value_err         BOOLEAN;
  sta_unsupported_err   BOOLEAN;
  sta_serious_err       BOOLEAN;

-- Segment column names and values input
--
  g_coldef              FND_FLEX_SERVER1.ColumnDefinitions;

/* ----------------------------------------------------------------------- */
/*                  THIS PACKAGE IS STILL UNDER DEVELOPMENT                */
/*      The functions herein are not be supported in any way and will      */
/*      change without notice.                                             */
/* ----------------------------------------------------------------------- */

/* ------------------------------------------------------------------------ */
/*      SEE PACKAGE SPECIFICATION FOR DESCRIPTION OF PUBLIC FUNCTIONS.      */
/* ------------------------------------------------------------------------ */

  FUNCTION load_desc(appl_short_name    IN  VARCHAR2,
                     desc_flex_name     IN  VARCHAR2,
                     row_id             IN  ROWID,
                     data_field         IN  VARCHAR2 DEFAULT NULL,
                     interface_table    IN  VARCHAR2 DEFAULT NULL)
                                                        RETURN BOOLEAN IS
    resp_apid   NUMBER;
    uresp_id    NUMBER;
    userid      NUMBER;
    valid_stat  NUMBER;

    dummy_coldef  FND_FLEX_SERVER1.ColumnDefinitions;

  BEGIN

--  Initialize everything including all global variables and set user
--  Isvalid is initialized to FALSE, serious_error initialized to TRUE.
--
    if(init_all(NULL, NULL, NULL, resp_apid, uresp_id, userid)) then
       FND_FLEX_SERVER4.descval_engine(user_apid => resp_apid,
                                       user_resp => uresp_id,
                                       userid => userid,
                                       flex_app_sname => appl_short_name,
                                       desc_flex_name => desc_flex_name,
                                       val_date => NULL,
                                       invoking_mode => 'L',
                                       allow_nulls => FALSE,
                                       update_table => FALSE,
                                       ignore_active => FALSE,
                                       concat_segs => NULL,
                                       vals_not_ids => FALSE,
                                       use_column_def => FALSE,
                                       column_def => dummy_coldef,
                                       rowid_in => row_id,
                                       alt_tbl_name => interface_table,
                                       data_field_name => data_field,
                                       nvalidated => nvalidated,
                                       displayed_vals => value_vals,
                                       stored_vals => value_svals,
                                       segment_ids => value_ids,
                                       descriptions => value_descs,
                                       desc_lengths => value_desclens,
                                       seg_colnames => seg_cols,
                                       seg_coltypes => seg_coltypes,
                                       segment_types => segtypes,
                                       displayed_segs => disp_segs,
                                       seg_delimiter => delim,
                                       v_status => valid_stat,
                                       seg_codes => segcodes,
                                       err_segnum => err_segn);
      set_stati(valid_stat);
    end if;
    return(return_status);

  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG', 'load_desc() exception:  ' || SQLERRM);
      err_msg := FND_MESSAGE.get_encoded;
      return(FALSE);

  END load_desc;

/* ------------------------------------------------------------------------ */

  FUNCTION check_desc(appl_short_name    IN  VARCHAR2,
                      desc_flex_name     IN  VARCHAR2,
                      row_id             IN  ROWID,
                      data_field         IN  VARCHAR2 DEFAULT NULL,
                      interface_table    IN  VARCHAR2 DEFAULT NULL,
                      validation_date    IN  DATE     DEFAULT SYSDATE,
                      enabled_activation IN  BOOLEAN  DEFAULT TRUE,
                      resp_appl_id       IN  NUMBER   DEFAULT NULL,
                      resp_id            IN  NUMBER   DEFAULT NULL)
                                                        RETURN BOOLEAN IS
    resp_apid   NUMBER;
    uresp_id    NUMBER;
    userid      NUMBER;
    valid_stat  NUMBER;

    dummy_coldef  FND_FLEX_SERVER1.ColumnDefinitions;

  BEGIN

--  Initialize everything including all global variables and set user
--  Isvalid is initialized to FALSE, serious_error initialized to TRUE.
--
    if(init_all(resp_appl_id, resp_id, NULL,
                resp_apid, uresp_id, userid)) then
       FND_FLEX_SERVER4.descval_engine(user_apid => resp_apid,
                                       user_resp => uresp_id,
                                       userid => userid,
                                       flex_app_sname => appl_short_name,
                                       desc_flex_name => desc_flex_name,
                                       val_date => validation_date,
                                       invoking_mode => 'C',
                                       allow_nulls => FALSE,
                                       update_table => FALSE,
                                       ignore_active => (not enabled_activation),
                                       concat_segs => NULL,
                                       vals_not_ids => FALSE,
                                       use_column_def => FALSE,
                                       column_def => dummy_coldef,
                                       rowid_in => row_id,
                                       alt_tbl_name => interface_table,
                                       data_field_name => data_field,
                                       nvalidated => nvalidated,
                                       displayed_vals => value_vals,
                                       stored_vals => value_svals,
                                       segment_ids => value_ids,
                                       descriptions => value_descs,
                                       desc_lengths => value_desclens,
                                       seg_colnames => seg_cols,
                                       seg_coltypes => seg_coltypes,
                                       segment_types => segtypes,
                                       displayed_segs => disp_segs,
                                       seg_delimiter => delim,
                                       v_status => valid_stat,
                                       seg_codes => segcodes,
                                       err_segnum => err_segn);
      set_stati(valid_stat);
    end if;
    return(return_status);

  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG', 'check_desc() exception:  ' || SQLERRM);
      err_msg := FND_MESSAGE.get_encoded;
      return(FALSE);

  END check_desc;

/* ------------------------------------------------------------------------ */

/*
 * ER 17602735 This function was created for the CP team. They needed
 * an API to always default the defined values. When re-submitting a CP
 * the user has the option to redfault values. This is important when
 * the default is a date or a profile option that can change. So the
 * default value should get updated on re-submission. This function will
 * re-default and validate all values passed in. Then it will return
 * a concatenated string of all the values including the redefaulted values.
 * When calling this function, pass in a concatenated string of all the values
 * to be validated. A segment seperator for each displayed segment must be
 * part of the concatenated string. If the parameter is null, then put no
 * value between the segment seperator. If a parameter has a default value
 * defined, then the null value will be replaced with the default. If a
 * parameter value was passed in, but also has a default defined, then that
 * parameter value will be replaced with the default value.
 * Example: 4 Parameter string: 'Administration.12..10.'
 *
 * To create this new defaulting logic, a new invoking_mode was created.
 * This invoking_mode is 'Q'. When invoking mode is 'Q' the
 * procedure FND_FLEX_SERVER4.descval_engine() will always default values
 *
 * Bug24656581: Added srs request set parameters
 */
  FUNCTION val_desc_and_redefault(appl_short_name IN  VARCHAR2,
                       desc_flex_name      IN  VARCHAR2,
                       concat_segments     IN  VARCHAR2,
                       validation_date     IN  DATE     DEFAULT SYSDATE,
                       enabled_activation  IN  BOOLEAN  DEFAULT TRUE,
                       resp_appl_id        IN  NUMBER   DEFAULT NULL,
                       resp_id             IN  NUMBER   DEFAULT NULL,
                       srs_reqst_appl_id   IN  NUMBER   DEFAULT NULL,
                       srs_reqst_id        IN  NUMBER   DEFAULT NULL,
                       srs_reqst_pgm_id    IN  NUMBER   DEFAULT NULL,
                       concat_ids          OUT nocopy VARCHAR2,
                       error_msg           OUT nocopy VARCHAR2)
                                        RETURN BOOLEAN IS
    resp_apid   NUMBER;
    uresp_id    NUMBER;
    userid      NUMBER;
    valid_stat  NUMBER;
    api_mode    VARCHAR2(1);
    dummy_coldef  FND_FLEX_SERVER1.ColumnDefinitions;


  BEGIN

--  Initialize everything including all global variables and set user
--  Isvalid is initialized to FALSE, serious_error initialized to TRUE.
--

    if(init_all(resp_appl_id, resp_id, NULL,
                resp_apid, uresp_id, userid)) then
       dummy_coldef.context_value := 'Global Data Elements';
       FND_FLEX_SERVER4.descval_engine(user_apid => resp_apid,
                                       user_resp => uresp_id,
                                       userid => userid,
                                       flex_app_sname => appl_short_name,
                                       desc_flex_name => desc_flex_name,
                                       val_date => validation_date,
                                       invoking_mode => 'Q',
                                       allow_nulls => FALSE,
                                       update_table => FALSE,
                                       ignore_active => (not enabled_activation),
                                       concat_segs => concat_segments,
                                       vals_not_ids => FALSE,
                                       use_column_def => FALSE,
                                       column_def => dummy_coldef,
                                       rowid_in => NULL,
                                       alt_tbl_name => NULL,
                                       data_field_name => NULL,
                                       srs_appl_id => srs_reqst_appl_id,
                                       srs_req_id => srs_reqst_id,
                                       srs_pgm_id => srs_reqst_pgm_id,
                                       nvalidated => nvalidated,
                                       displayed_vals => value_vals,
                                       stored_vals => value_svals,
                                       segment_ids => value_ids,
                                       descriptions => value_descs,
                                       desc_lengths => value_desclens,
                                       seg_colnames => seg_cols,
                                       seg_coltypes => seg_coltypes,
                                       segment_types => segtypes,
                                       displayed_segs => disp_segs,
                                       seg_delimiter => delim,
                                       v_status => valid_stat,
                                       seg_codes => segcodes,
                                       err_segnum => err_segn);


      set_stati(valid_stat);
    end if;

    if (return_status) then
        concat_ids := FND_FLEX_DESCVAL.concatenated_ids;
    else
       error_msg  := FND_FLEX_DESCVAL.ERROR_MESSAGE;
    end if;

    return(return_status);

  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG', 'val_desc() exception:  ' || SQLERRM);
      err_msg := FND_MESSAGE.get_encoded;
      error_msg  := FND_FLEX_DESCVAL.ERROR_MESSAGE;
      return(FALSE);

  END val_desc_and_redefault;








  FUNCTION val_desc(appl_short_name     IN  VARCHAR2,
                    desc_flex_name      IN  VARCHAR2,
                    concat_segments     IN  VARCHAR2,
                    values_or_ids       IN  VARCHAR2 DEFAULT 'I',
                    validation_date     IN  DATE     DEFAULT SYSDATE,
                    enabled_activation  IN  BOOLEAN  DEFAULT TRUE,
                    resp_appl_id        IN  NUMBER   DEFAULT NULL,
                    resp_id             IN  NUMBER   DEFAULT NULL)
                                                            RETURN BOOLEAN IS
    resp_apid   NUMBER;
    uresp_id    NUMBER;
    userid      NUMBER;
    valid_stat  NUMBER;

    api_mode    VARCHAR2(1);

    dummy_coldef  FND_FLEX_SERVER1.ColumnDefinitions;

  BEGIN

  api_mode := check_api_mode(values_or_ids);

--  Initialize everything including all global variables and set user
--  Isvalid is initialized to FALSE, serious_error initialized to TRUE.
--

    if(init_all(resp_appl_id, resp_id, NULL,
                resp_apid, uresp_id, userid)) then
       FND_FLEX_SERVER4.descval_engine(user_apid => resp_apid,
                                       user_resp => uresp_id,
                                       userid => userid,
                                       flex_app_sname => appl_short_name,
                                       desc_flex_name => desc_flex_name,
                                       val_date => validation_date,
                                       invoking_mode => api_mode,
                                       allow_nulls => FALSE,
                                       update_table => FALSE,
                                       ignore_active => (not enabled_activation),
                                       concat_segs => concat_segments,
                                       vals_not_ids => (values_or_ids = 'V'),
                                       use_column_def => FALSE,
                                       column_def => dummy_coldef,
                                       rowid_in => NULL,
                                       alt_tbl_name => NULL,
                                       data_field_name => NULL,
                                       nvalidated => nvalidated,
                                       displayed_vals => value_vals,
                                       stored_vals => value_svals,
                                       segment_ids => value_ids,
                                       descriptions => value_descs,
                                       desc_lengths => value_desclens,
                                       seg_colnames => seg_cols,
                                       seg_coltypes => seg_coltypes,
                                       segment_types => segtypes,
                                       displayed_segs => disp_segs,
                                       seg_delimiter => delim,
                                       v_status => valid_stat,
                                       seg_codes => segcodes,
                                       err_segnum => err_segn);
      set_stati(valid_stat);
    end if;
    return(return_status);

  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG', 'val_desc() exception:  ' || SQLERRM);
      err_msg := FND_MESSAGE.get_encoded;
      return(FALSE);

  END val_desc;

/* ------------------------------------------------------------------------ */

  FUNCTION validate_desccols(appl_short_name    IN  VARCHAR2,
                    desc_flex_name      IN  VARCHAR2,
                    values_or_ids       IN  VARCHAR2 DEFAULT 'I',
                    validation_date     IN  DATE     DEFAULT SYSDATE,
                    enabled_activation  IN  BOOLEAN  DEFAULT TRUE,
                    resp_appl_id        IN  NUMBER   DEFAULT NULL,
                    resp_id             IN  NUMBER   DEFAULT NULL)
                                                            RETURN BOOLEAN IS
    resp_apid   NUMBER;
    uresp_id    NUMBER;
    userid      NUMBER;
    valid_stat  NUMBER;
    api_mode    VARCHAR2(1);
    l_default_context_value VARCHAR2(2000);

  BEGIN

    api_mode := check_api_mode(values_or_ids);

--  Initialize everything including all global variables and set user
--  Isvalid is initialized to FALSE, serious_error initialized to TRUE.
--
    if(init_all(resp_appl_id, resp_id, NULL,
                resp_apid, uresp_id, userid)) then

       if (g_coldef.context_value is null) then
           if (api_mode = 'D') then
              l_default_context_value := get_ref_field_context(appl_short_name,
                                                 desc_flex_name);
           else
              l_default_context_value := get_default_context(appl_short_name,
                                                 desc_flex_name);
           end if;

           if (l_default_context_value is NOT NULL) then
               g_coldef.context_value_set := TRUE;
               g_coldef.context_value := SUBSTRB(l_default_context_value, 1, 30);
           end if;
       end if;

       FND_FLEX_SERVER4.descval_engine(user_apid => resp_apid,
                                       user_resp => uresp_id,
                                       userid => userid,
                                       flex_app_sname => appl_short_name,
                                       desc_flex_name => desc_flex_name,
                                       val_date => validation_date,
                                       invoking_mode => api_mode,
                                       allow_nulls => FALSE,
                                       update_table => FALSE,
                                       ignore_active => (not enabled_activation),
                                       concat_segs => NULL,
                                       vals_not_ids => (values_or_ids = 'V'),
                                       use_column_def => TRUE,
                                       column_def => g_coldef,
                                       rowid_in => NULL,
                                       alt_tbl_name => NULL,
                                       data_field_name => NULL,
                                       nvalidated => nvalidated,
                                       displayed_vals => value_vals,
                                       stored_vals => value_svals,
                                       segment_ids => value_ids,
                                       descriptions => value_descs,
                                       desc_lengths => value_desclens,
                                       seg_colnames => seg_cols,
                                       seg_coltypes => seg_coltypes,
                                       segment_types => segtypes,
                                       displayed_segs => disp_segs,
                                       seg_delimiter => delim,
                                       v_status => valid_stat,
                                       seg_codes => segcodes,
                                       err_segnum => err_segn);
      set_stati(valid_stat);

    end if;
    return(return_status);

  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG', 'validate_desccols() exception: '||SQLERRM);
      err_msg := FND_MESSAGE.get_encoded;
      return(FALSE);

  END validate_desccols;

/* ------------------------------------------------------------------------ */

  PROCEDURE set_context_value(context_value  IN  VARCHAR2) IS
  BEGIN
    g_coldef.context_value := SUBSTRB(context_value, 1, 80);
    g_coldef.context_value_set := TRUE;
  END set_context_value;

/* ------------------------------------------------------------------------ */

  PROCEDURE set_column_value(column_name  IN VARCHAR2,
                             column_value IN VARCHAR2) IS
  BEGIN
    add_column_value(column_name, column_value, 'V');
  END set_column_value;

/* ------------------------------------------------------------------------ */
/*      Sets number column value converting the number to the character     */
/*      representation appropriate for flexfields.                          */
/* ------------------------------------------------------------------------ */

  PROCEDURE set_column_value(column_name  IN VARCHAR2,
                             column_value IN NUMBER) IS
  BEGIN
    add_column_value(column_name, to_char(column_value), 'N');
  END set_column_value;

/* ------------------------------------------------------------------------ */
/*      Sets date column value converting the date to the character         */
/*      representation appropriate for flexfields.                          */
/* ------------------------------------------------------------------------ */

  PROCEDURE set_column_value(column_name  IN VARCHAR2,
                             column_value IN DATE) IS
  BEGIN
    add_column_value(column_name,
                to_char(column_value, FND_FLEX_SERVER1.DATETIME_FMT), 'D');
  END set_column_value;

/* ------------------------------------------------------------------------ */
/*      Clears all defined column values.  Column values are also cleared   */
/*      after validation by val_desc() or validate_desccols().              */
/* ------------------------------------------------------------------------ */

  PROCEDURE clear_column_values IS
  BEGIN
    FND_FLEX_SERVER4.init_coldef(g_coldef);
  END clear_column_values;

/* ------------------------------------------------------------------------ */
/*      Functions for getting more details about the most recently          */
/*      validated combination.  These typically do not trap errors          */
/*      related to the user not leaving enough room in destination          */
/*      strings to store the result.                                        */
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

FUNCTION error_segment RETURN NUMBER IS
BEGIN
  return(err_segn);
END error_segment;

FUNCTION error_message RETURN VARCHAR2 IS
BEGIN
  if((err_text is null) and (err_msg is not null)) then
    FND_MESSAGE.set_encoded(err_msg);
    err_text := FND_MESSAGE.get;
  end if;
  return(err_text);
END error_message;

FUNCTION encoded_error_message RETURN VARCHAR2 IS
BEGIN
  return(err_msg);
END encoded_error_message;


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
        (-20001, ('Developer Error: DVL.concatenated_values should not ' ||
                  'be called if validation fails.'));
   END IF;
END concatenated_values;


FUNCTION concatenated_ids RETURN VARCHAR2 IS
BEGIN
   IF (sta_valid) THEN
      return(FND_FLEX_SERVER.concatenate_ids(nvalidated, value_ids, delim));
    ELSE
      raise_application_error
        (-20001, ('Developer Error: DVL.concatenated_ids should not ' ||
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
        (-20001, ('Developer Error: DVL.concatenated_descriptions should not '||
                  'be called if validation fails.'));
   END IF;
END concatenated_descriptions;


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
    return(seg_cols(segnum));
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
    type_code := seg_coltypes(segnum);
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
/*      Clears all output variables except for the status codes and         */
/*      error messages.  Does not clear input column definitions.           */
/* ------------------------------------------------------------------------ */

  PROCEDURE clear_all_but_error IS
  BEGIN

--  Setting array counts to 0 initializes arrays
--
    nvalidated := 0;
    segtypes.nsegs := 0;
    disp_segs.n_segflags := 0;
    delim := NULL;
    segcodes := NULL;

  END clear_all_but_error;

/* ------------------------------------------------------------------------ */
/*      Set status flags and clears input arguments.                        */
/*      Secured also set if any segment is secured and there is some        */
/*      other error.                                                        */
/* ------------------------------------------------------------------------ */

  PROCEDURE set_stati(v_stat  IN  NUMBER) IS
  BEGIN
    sta_valid := (v_stat = FND_FLEX_SERVER1.VV_VALID);
    sta_secured := ((v_stat = FND_FLEX_SERVER1.VV_SECURED) or
                   (INSTR(segcodes, FND_FLEX_SERVER1.FF_VSECURED) > 0));
    sta_value_err := (v_stat = FND_FLEX_SERVER1.VV_VALUES);
    sta_unsupported_err := (v_stat = FND_FLEX_SERVER1.VV_UNSUPPORTED);
    sta_serious_err := (v_stat = FND_FLEX_SERVER1.VV_ERROR);

-- Clear column definitions
--
    FND_FLEX_SERVER4.init_coldef(g_coldef);

  END set_stati;

/* ------------------------------------------------------------------------ */
/*  Gets message and erase all but error if not valid.                      */
/* ------------------------------------------------------------------------ */

  FUNCTION return_status RETURN BOOLEAN IS
  BEGIN
    if(not sta_valid) then
      err_msg := FND_MESSAGE.get_encoded;
      clear_all_but_error;
    end if;
    return(sta_valid);
  END return_status;

/* ------------------------------------------------------------------------ */
/*  Converts column type code to a name such as VARCHAR2 etc.               */
/* ------------------------------------------------------------------------ */

--  FUNCTION column_type_name(type_code  IN VARCHAR2) RETURN VARCHAR2 IS
--  BEGIN
--    if(type_code = 'V') then
--      return('VARCHAR2');
--    else if(type_code = 'C') then
--      return('CHAR');
--    else if(type_code = 'N') then
--      return('NUMBER');
--    else if(type_code = 'D') then
--      return('DATE');
--    else
--      return(NULL);
--    end if;
--    return(NULL);
--  END column_type_name;

/* ------------------------------------------------------------------------ */
/*      Internal function for setting column value and data type.           */
/* ------------------------------------------------------------------------ */

  PROCEDURE add_column_value(column_name  IN VARCHAR2,
                             column_value IN VARCHAR2,
                             column_type  IN VARCHAR2) IS
    n        NUMBER;
    ndefined NUMBER;
    colname  VARCHAR2(30);

  BEGIN
-- Initialize column count if necessary
--
    if(g_coldef.colvals.ncolumns is null) then
      ndefined := 0;
    else
      ndefined := g_coldef.colvals.ncolumns;
    end if;

-- Get the column name
--
    colname := UPPER(SUBSTRB(column_name, 1, 30));

-- Redefine value if column already defined.
--
    for i in 1..ndefined loop
      if(g_coldef.colvals.column_names(i) = colname) then
        n := i;
        exit;
      end if;
    end loop;

--  If column not already defined, add a new one.
--
    if(n is null) then
      ndefined := ndefined + 1;
      n := ndefined;
    end if;

-- Set the column value
--
    g_coldef.colvals.column_names(n) := colname;
    g_coldef.colvals.column_values(n) := SUBSTRB(column_value, 1, 1000);
    g_coldef.colvals.column_types(n) := SUBSTRB(column_type, 1, 1);
    g_coldef.colvals.ncolumns := ndefined;

  END add_column_value;

/* ------------------------------------------------------------------------ */
/*        Added for Bug 2221725 - need to default IDs as well as Values.    */
/*                                                                          */
/* Previously we always passed invoking_mode => 'V' to the descval_engine.  */
/* Now we will pass invoking_mode => api_mode which is set by this function */
/* based on the value for values_or_ids which is passed by the code calling */
/* this api.  Checks for invoking mode = 'D' have been added to the engine  */
/* in AFFFSV4B.pls and AFFFSV1B.pls.  When invoking_mode = 'D' and the      */
/* segment is null we will temporarily switch to "values" mode and get the  */
/* default value. This will allow the user to retrieve the defaulted ID if  */
/* descval_engine returns success.                                          */
/*                                                                          */
/* Note: no change had to be made to logic involving values_or_ids as       */
/* we always pass vals_not_ids => (values_or_ids = 'V') to descval_engine,  */
/* which means vals_not_ids will be FALSE if values_or_ids = 'I' or 'D'.    */
/* ------------------------------------------------------------------------ */

FUNCTION check_api_mode(values_or_ids IN VARCHAR2)
  RETURN VARCHAR2
  IS
     l_api_mode VARCHAR2(1);
BEGIN
   IF values_or_ids = 'D' then
      l_api_mode := 'D';
    ELSE
      l_api_mode := 'V';
   END IF;

   RETURN (l_api_mode);

END check_api_mode;

FUNCTION get_default_context(p_application_short_name     IN VARCHAR2,
                             p_descriptive_flexfield_name IN VARCHAR2)
  RETURN VARCHAR2
  IS
     l_default_context_value fnd_descriptive_flexs_vl.default_context_value%TYPE;
BEGIN
   SELECT fdfv.default_context_value
     INTO l_default_context_value
     FROM fnd_application fa,
          fnd_descriptive_flexs_vl fdfv
     WHERE fa.application_short_name =  p_application_short_name
     AND fdfv.application_id = fa.application_id
     AND fdfv.descriptive_flexfield_name = p_descriptive_flexfield_name;

   RETURN (l_default_context_value);

EXCEPTION
   WHEN OTHERS THEN
      raise_application_error
        (-20005, 'DVLB.get_default_context() failed. SQLERRM: ' || Sqlerrm,
         TRUE);
END get_default_context;

FUNCTION get_ref_field_context(p_application_short_name     IN VARCHAR2,
                             p_descriptive_flexfield_name IN VARCHAR2)
  RETURN VARCHAR2
  IS
     l_default_context_value fnd_descriptive_flexs_vl.default_context_value%TYPE;
     l_default_context_field_name fnd_descriptive_flexs_vl.default_context_field_name%TYPE;
     bind_val  VARCHAR2(2000);

BEGIN
   SELECT fdfv.default_context_value, fdfv.default_context_field_name
     INTO l_default_context_value, l_default_context_field_name
     FROM fnd_application fa,
          fnd_descriptive_flexs_vl fdfv
     WHERE fa.application_short_name =  p_application_short_name
     AND fdfv.application_id = fa.application_id
     AND fdfv.descriptive_flexfield_name = p_descriptive_flexfield_name;

   if ((l_default_context_value is null) and
       (l_default_context_field_name is not null)) then
      IF (INSTR(l_default_context_field_name, ':$PROFILES$.') = 1) then
         FND_PROFILE.get(UPPER(SUBSTR(l_default_context_field_name, 13)), bind_val);
         BEGIN
            SELECT ctx.descriptive_flex_context_code
              INTO l_default_context_value
              FROM fnd_application fa,
                   fnd_descr_flex_contexts ctx
              WHERE fa.application_short_name = p_application_short_name
              AND fa.application_id = ctx.application_id
              AND ctx.descriptive_flexfield_name = p_descriptive_flexfield_name
              AND ctx.enabled_flag = 'Y'
              AND ctx.descriptive_flex_context_code = bind_val;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               l_default_context_value := NULL;
         END;
      END IF;
   end if;

   RETURN (l_default_context_value);

EXCEPTION
   WHEN OTHERS THEN
      raise_application_error
        (-20005, 'DVLB.get_ref_field_context() failed. SQLERRM: ' || Sqlerrm,
         TRUE);
END get_ref_field_context;

END fnd_flex_descval;

/
