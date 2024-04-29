--------------------------------------------------------
--  DDL for Package FND_FLEX_SERVER1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_FLEX_SERVER1" AUTHID CURRENT_USER AS
/* $Header: AFFFSV1S.pls 120.1.12010000.5 2017/02/13 22:36:15 tebarnes ship $ */

  --------
  -- PRIVATE INTER-PACKAGE TYPES
  --
  --  Segment array is 1-based containing entries for i <= i <= nsegs
  --

  TYPE ValueArray IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;
  TYPE ValueIdArray IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;
  TYPE ValueDescArray IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;

  TYPE StringArray IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
  TYPE CharArray IS TABLE OF CHAR INDEX BY BINARY_INTEGER;
  TYPE NumberArray IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE BooleanArray IS TABLE OF BOOLEAN INDEX BY BINARY_INTEGER;

  TYPE ValAttribArray IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
  TYPE QualNameArray IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
  TYPE TabColArray IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
  TYPE ErrMsgArray IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;
  TYPE AppNameArray IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;

  TYPE FlexStructId IS RECORD
  (isa_key_flexfield BOOLEAN,
  application_id     FND_ID_FLEX_SEGMENTS.APPLICATION_ID%TYPE,
  id_flex_code	     FND_ID_FLEX_SEGMENTS.ID_FLEX_CODE%TYPE,
  id_flex_num        FND_ID_FLEX_SEGMENTS.ID_FLEX_NUM%TYPE,
  desc_flex_name     FND_DESCR_FLEX_CONTEXTS.DESCRIPTIVE_FLEXFIELD_NAME%TYPE,
  desc_flex_context  FND_DESCR_FLEX_CONTEXTS.DESCRIPTIVE_FLEX_CONTEXT_CODE%TYPE
  );

  TYPE DescFlexInfo IS RECORD
  (application_id	FND_DESCRIPTIVE_FLEXS.APPLICATION_ID%TYPE,
   name			FND_DESCRIPTIVE_FLEXS.DESCRIPTIVE_FLEXFIELD_NAME%TYPE,
   description		FND_DESCRIPTIVE_FLEXS_TL.DESCRIPTION%TYPE,
   table_appl_id	FND_DESCRIPTIVE_FLEXS.TABLE_APPLICATION_ID%TYPE,
   table_name		FND_DESCRIPTIVE_FLEXS.APPLICATION_TABLE_NAME%TYPE,
   table_id		FND_TABLES.TABLE_ID%TYPE,
   context_required	FND_DESCRIPTIVE_FLEXS.CONTEXT_REQUIRED_FLAG%TYPE,
   context_column	FND_DESCRIPTIVE_FLEXS.CONTEXT_COLUMN_NAME%TYPE,
   context_override	FND_DESCRIPTIVE_FLEXS.CONTEXT_USER_OVERRIDE_FLAG%TYPE,
   segment_delimiter FND_DESCRIPTIVE_FLEXS.CONCATENATED_SEGMENT_DELIMITER%TYPE,
   protected_flag	FND_DESCRIPTIVE_FLEXS.PROTECTED_FLAG%TYPE,
   default_context	FND_DESCRIPTIVE_FLEXS.DEFAULT_CONTEXT_VALUE%TYPE,
   reference_field	FND_DESCRIPTIVE_FLEXS.DEFAULT_CONTEXT_FIELD_NAME%TYPE,
   context_override_value_set_id  FND_DESCRIPTIVE_FLEXS.context_override_value_set_id%TYPE,
   context_default_type           FND_DESCRIPTIVE_FLEXS.context_default_type%TYPE,
   context_default_value          FND_DESCRIPTIVE_FLEXS.context_default_value%TYPE,
   context_runtime_property_funct FND_DESCRIPTIVE_FLEXS.context_runtime_property_funct%TYPE);

  TYPE CombTblInfo IS RECORD
	(table_application_id		NUMBER,
	combination_table_id		NUMBER,
	application_table_name		VARCHAR2(30),
	select_comb_from                VARCHAR2(30),
	application_table_type		VARCHAR2(1),
	unique_id_column_name		VARCHAR2(30),
	set_defining_column_name	VARCHAR2(30));

  TYPE FlexStructInfo IS RECORD
	(maximum_concatenation_len	NUMBER(15),
	concatenation_len_warning	VARCHAR2(240),
	enabled_flag			VARCHAR2(1),
	concatenated_segment_delimiter	VARCHAR2(1),
	cross_segment_validation_flag	VARCHAR2(1),
	dynamic_inserts_feasible_flag	VARCHAR2(1),
	dynamic_inserts_allowed_flag	VARCHAR2(1));

  TYPE FlexQualTable IS RECORD
       (nentries			NUMBER,
        seg_indexes			NumberArray,
        fq_names			QualNameArray);

  TYPE DerivedVals IS RECORD
       (enabled_flag		  	VARCHAR2(1),
	summary_flag			VARCHAR2(1),
	start_valid			DATE,
	end_valid			DATE);

  TYPE Qualifiers IS RECORD
       (nquals				NUMBER,
        fq_names			QualNameArray,
        sq_names			QualNameArray,
        sq_values			ValAttribArray,
        derived_cols			TabColArray);

  TYPE Vrules IS RECORD
       (nvrules				NUMBER,
        fq_names			QualNameArray,
        sq_names			QualNameArray,
        ie_flags			CharArray,
        cat_vals			ValAttribArray,
	app_names			AppNameArray,
        err_names			ErrMsgArray);

  TYPE SegFormats IS RECORD
       (nsegs				NUMBER,
        vs_format			CharArray,
        vs_maxsize			NumberArray);

  TYPE ColumnValues IS RECORD
       (ncolumns			NUMBER,
	column_names			TabColArray,
	column_types			CharArray,
	column_values			StringArray);

  TYPE ColumnDefinitions IS RECORD
       (context_value_set		BOOLEAN,
	context_value			VARCHAR2(80),
	colvals				ColumnValues);

--  Parsed version of the DISPLAYED token.
--  If no_segs_displayed is TRUE then no segments are displayed.
--  If some segments are displayed, then segflags[] array
--  determines whether each segment is displayed.  Segflags has one entry
--  for each enabled segment in the order of segment_num.
--
  TYPE DisplayedSegs IS RECORD
       (n_segflags		NUMBER,
	segflags		BooleanArray);

--  Explanation of value validation flags:
--
--  values_not_ids is TRUE if values rather than ids passed to validate_struct()
--  Defaults all displayed values which are null if default_all_displayed.
--  Defaults all required values which are null if default_all_required.
--  Defaults only those required values which are not displayed if
--    default_non_displayed.
--  If allow_nulls is TRUE then null required segments are valid.
--  message_on_null means set value error message if required segment is null.
--  If all_orphans_valid is TRUE should consider all possible dependent
--    values to be valid if the parent value is null.
--  stop_on_value_error means stop segment validation on non-security value
--    error.  Validation always stops if error is more serious than
--    that the user enterd a bad value.
--  stop_on_security means stop segment validation if a security violated.
--  message_on_security means set value error message if security violated.
--  Does not check value security rules if ignore_security is TRUE
--  Does not check if value is disabled or expired if ignore_disabled TRUE.
--
  /* bug872437 : invoking_mode is added. */

  TYPE ValueValidationFlags IS RECORD
       (values_not_ids			BOOLEAN,
	default_all_displayed		BOOLEAN,
	default_all_required		BOOLEAN,
	default_non_displayed		BOOLEAN,
	allow_nulls			BOOLEAN,
	message_on_null			BOOLEAN,
	all_orphans_valid		BOOLEAN,
	exact_nsegs_required		BOOLEAN,
	stop_on_value_error		BOOLEAN,
	stop_on_security		BOOLEAN,
	message_on_security		BOOLEAN,
	ignore_security			BOOLEAN,
	ignore_expired			BOOLEAN,
	ignore_disabled			BOOLEAN,
	invoking_mode                   VARCHAR2(10),
        srs_req_set_appl_id             NUMBER(15),
        srs_req_set_id                  NUMBER(15),
        srs_req_set_pgm_id              NUMBER(15));


  ----------------------------------
  -- PRIVATE INTER-PACKAGE CONSTANTS
  --

  --  These are used for TOKEN separator characters in parsing
  --  and returning VRULES, DERIVED and VALATT.  And they are also
  --  used to separate multiple messages, and in checking Vrules

  SEPARATOR		CONSTANT VARCHAR2(4) := '\n';
  TERMINATOR		CONSTANT VARCHAR2(4) := '\0';
  DATETIME_FMT		CONSTANT VARCHAR2(21) := 'YYYY/MM/DD HH24:MI:SS';

  --  Components of a value

  VC_DISPVAL		CONSTANT BINARY_INTEGER := 1;
  VC_VALUE		CONSTANT BINARY_INTEGER := 2;
  VC_ID			CONSTANT BINARY_INTEGER := 3;
  VC_DESCRIPTION	CONSTANT BINARY_INTEGER := 4;


  --  Return status for validate_struct() and combination validation
  --  Everything but UNSUPPORTED and ERROR represent errors in what the
  --  user typed in as the combination.
  --
  --  VALID means everything ok.
  --  SECURED means one or more values violate security rules, but otherwise
  --    everything else is ok.
  --  VALUES means there is one or more non-security value error.
  --  COMBNOTFOUND means dynamic inserts off and combination does not exist.
  --    Note that if combination not found by LOADID() this is ERROR.
  --  WHERECLAUSEFAILURE
  --    Combination exists but additonal where clause fails.
  --  CROSSVAL means values violate cross-validation rules.
  --  UNSUPPORTED means server cannot validate because of :block.field or
  --    value validation type not supported by server.
  --  ERROR means inconsistincy in the flex definition or structure.  This is
  --    not returned merely for errors in what the user typed in.

   VV_VALID		CONSTANT NUMBER := 0;
   VV_SECURED		CONSTANT NUMBER := 30;
   VV_VALUES		CONSTANT NUMBER := 100;
   VV_COMBNOTFOUND	CONSTANT NUMBER := 200;
   VV_WHEREFAILURE      CONSTANT NUMBER := 250;
   VV_CROSSVAL		CONSTANT NUMBER := 300;
   VV_COMBEXISTS	CONSTANT NUMBER := 400;
   VV_UNSUPPORTED	CONSTANT NUMBER := 900;
   VV_ERROR		CONSTANT NUMBER := 1000;
   VV_CTXTNOSEG         CONSTANT NUMBER := 1100;


  --  Flexfield value validation status codes
  --  These codes are used to indicate the status of each segment value.

 /* Non-value error validating segment */
  FF_VERROR       CONSTANT VARCHAR2(1) := '*';

  -- The following codes are compatible with the client definitions.
  --

 /* Value is valid */
  FF_VVALID       CONSTANT VARCHAR2(1) := 'V';

 /* validated and not in RDBMS */
  FF_VNOTFOUND    CONSTANT VARCHAR2(1) := 'N';

 /* valid, but not sdate <= vdate <= edate */
  FF_VEXPIRED     CONSTANT VARCHAR2(1) := 'E';

 /* valid, but not enabled  */
  FF_VDISABLED    CONSTANT VARCHAR2(1) := 'D';

 /* Valid, but Security violation */
  FF_VSECURED     CONSTANT VARCHAR2(1) := 'S';

 /* Indicates we don't know whether or not value is valid. */
  FF_VUNKNOWN     CONSTANT VARCHAR2(1) := 'U';

 /* Mandatory segment is null */
  FF_VREQUIRED    CONSTANT VARCHAR2(1) := 'M';

 /* Format violation */
  FF_VFORMAT      CONSTANT VARCHAR2(1) := 'F';

 /* Segment violates Vrule.  Value Rule - qualifiers */
  FF_VVRULE       CONSTANT VARCHAR2(1) := 'Q';

 /* valu out of bounds not BETWEEN min AND max */
  FF_VBOUNDS      CONSTANT VARCHAR2(1) := 'B';

 /* Orphaned - parent is null... */
  FF_VORPHAN      CONSTANT VARCHAR2(1) := 'O';

 /* Inter segment range.  Range flex min is larger than max.  Not used here. */
  FF_VSRANGE      CONSTANT VARCHAR2(1) := 'R';

 /* Key flex column range.  Not used.  */
  FF_VCRANGE      CONSTANT VARCHAR2(1) := 'r';

 /* Descr context valid but no segs defined */
  FF_CTXTNOSEG    CONSTANT VARCHAR2(1) := 'T';

  --  The following codes indicate errors at the combination level

 /* Duplicate combination */
  FF_VDUPLICATE   CONSTANT VARCHAR2(1) := '2';

 /* New combination, and inserts not allowed */
  FF_VNOINSERT    CONSTANT VARCHAR2(1) := '0';

 /* Cross validation failure */
  FF_VXVAL        CONSTANT VARCHAR2(1) := 'X';


   --  The following is used at both the segment and the combination level.

 /* Generic Invalid - used by user-exit.  Not used yet in PLSQL package. */
  FF_VINVALID     CONSTANT VARCHAR2(1) := 'I';

  /* This debug level must be changed through set_debugging() procedure. */
  --  Debugging information
  g_debug_level NUMBER := 0;
  --
  -- 'OFF'       : 0
  -- 'ERROR'     : 1
  -- 'EXCEPTION' : 2
  -- 'EVENT'     : 3
  -- 'PROCEDURE' : 4
  -- 'STATEMENT' : 5
  -- 'ALL'       : 6
  --

  -- Bug 14250283 Used to override Right Justify Zero Fill as defined in ValueSet.
  -- set to T for True to zero fill.
  -- set to N for No to not zero fill
  -- default to X to indicate flag is not set by set_zero_fill() procedure.
  zero_fill_override  VARCHAR2(1) := 'X';


/* ------------------------------------------------------------------------  */

-- --	Breaks concatenated segments into separate columns
-- --	in rule-lines table.
-- --
-- --	Use ONLY for FND_FLEX_VALIDATION_RULE_LINES_T1 trigger.
-- --
--
--   FUNCTION breakup_segs(appid IN NUMBER,
-- 		flex_code IN VARCHAR2, flex_num IN NUMBER,
-- 		catsegs IN VARCHAR2, nsegs OUT NUMBER,
-- 		seg1  OUT VARCHAR2, seg2  OUT VARCHAR2,
-- 		seg3  OUT VARCHAR2, seg4  OUT VARCHAR2,
-- 		seg5  OUT VARCHAR2, seg6  OUT VARCHAR2,
-- 		seg7  OUT VARCHAR2, seg8  OUT VARCHAR2,
-- 		seg9  OUT VARCHAR2, seg10 OUT VARCHAR2,
-- 		seg11 OUT VARCHAR2, seg12 OUT VARCHAR2,
-- 		seg13 OUT VARCHAR2, seg14 OUT VARCHAR2,
-- 		seg15 OUT VARCHAR2, seg16 OUT VARCHAR2,
-- 		seg17 OUT VARCHAR2, seg18 OUT VARCHAR2,
-- 		seg19 OUT VARCHAR2, seg20 OUT VARCHAR2,
-- 		seg21 OUT VARCHAR2, seg22 OUT VARCHAR2,
-- 		seg23 OUT VARCHAR2, seg24 OUT VARCHAR2,
-- 		seg25 OUT VARCHAR2, seg26 OUT VARCHAR2,
-- 		seg27 OUT VARCHAR2, seg28 OUT VARCHAR2,
-- 		seg29 OUT VARCHAR2, seg30 OUT VARCHAR2) RETURN NUMBER;

/* -------------------------------------------------------------------- */
/*    		          Private definitions                       	*/
/*									*/
/*	The following functions are for use internal only by the 	*/
/*	FND_FLEX_SERVER package.  They are externalized only because    */
/*	the flexfield validation routines cannot be put into a single	*/
/*	package.  They are not supported for any other purpose and	*/
/*	will almost certainly change without notice.			*/
/* -------------------------------------------------------------------- */

  FUNCTION parse_where_token(clause_in  IN  VARCHAR2,
			     clause_out OUT nocopy VARCHAR2) RETURN NUMBER;

  FUNCTION check_comb_vrules(vrs    IN  Vrules,
			     sqs    IN  Qualifiers,
			     sumflg IN  VARCHAR2) RETURN NUMBER;

  FUNCTION vals_secured(fstruct	IN  FlexStructId,
    			nsegs	IN  NUMBER,
			segs	IN  StringArray,
			displ	IN  DisplayedSegs,
			uappid  IN  NUMBER,
			respid  IN  NUMBER) RETURN NUMBER;

  FUNCTION validate_struct(fstruct	IN  FlexStructId,
			   tbl_apid	IN  NUMBER,
			   tbl_id	IN  NUMBER,
    			   nsegs_in	IN  NUMBER,
			   segs		IN  StringArray,
			   dispsegs	IN  DisplayedSegs,
			   vflags	IN  ValueValidationFlags,
		           v_date  	IN  DATE,
			   v_ruls	IN  Vrules,
			   uappid  	IN  NUMBER,
			   respid  	IN  NUMBER,
			   nsegs_out	OUT nocopy NUMBER,
			   segfmts  	OUT nocopy SegFormats,
			   segstats	OUT nocopy VARCHAR2,
  			   tabcols	OUT nocopy TabColArray,
			   tabcoltypes	OUT nocopy CharArray,
			   v_dispvals	OUT nocopy ValueArray,
			   v_vals	OUT nocopy ValueArray,
			   v_ids	OUT nocopy ValueIdArray,
			   v_descs	OUT nocopy ValueDescArray,
			   desc_lens	OUT nocopy NumberArray,
			   dvals	OUT nocopy DerivedVals,
			   dquals	OUT nocopy Qualifiers,
  			   errsegn	OUT nocopy NUMBER) RETURN NUMBER;

/* ------------------------------------------------------------------------  */
--  General utility functions
--

  FUNCTION to_stringarray(catsegs IN  VARCHAR2,
		          sepchar in  VARCHAR2,
		          segs    OUT nocopy StringArray) RETURN NUMBER;

  FUNCTION from_stringarray(nsegs   IN NUMBER,
		            segs    IN StringArray,
			    sepchar IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION to_stringarray2(catsegs IN  VARCHAR2,
			   sepchar in  VARCHAR2,
			   segs    OUT nocopy StringArray) RETURN NUMBER;

  FUNCTION from_stringarray2(nsegs   IN NUMBER,
			     segs    IN StringArray,
			     sepchar IN VARCHAR2) RETURN VARCHAR2;

  PROCEDURE x_inrange_clause(valstr  IN VARCHAR2,
			     valtype IN VARCHAR2,
			     mincol  IN VARCHAR2,
			     maxcol  IN VARCHAR2);

  FUNCTION select_clause(colname     IN  VARCHAR2,
			 coltype     IN  VARCHAR2,
			 v_component IN  BINARY_INTEGER,
			 vs_fmt      IN  VARCHAR2,
			 vs_len      IN  NUMBER) RETURN VARCHAR2;

  PROCEDURE x_compare_clause(coltype     IN  VARCHAR2,
			     colname     IN  VARCHAR2,
			     char_val    IN  VARCHAR2,
			     v_component IN  BINARY_INTEGER,
			     vs_fmt      IN  VARCHAR2,
			     vs_len      IN  NUMBER);

  FUNCTION x_dsql_execute RETURN NUMBER;

  FUNCTION x_dsql_select_one(returned_column OUT nocopy VARCHAR2) RETURN NUMBER;

  FUNCTION x_dsql_select(n_selected_cols  IN  NUMBER,
			 returned_columns OUT nocopy StringArray) RETURN NUMBER;

  FUNCTION stored_date_format(flex_data_type IN VARCHAR2,
		  	      string_length  IN NUMBER) RETURN VARCHAR2;

  FUNCTION isa_number(teststr IN VARCHAR2,
		       outnum OUT nocopy NUMBER) RETURN BOOLEAN;

  FUNCTION init_globals RETURN BOOLEAN;


/* ------------------------------------------------------------------------  */

  PROCEDURE add_sql_string(sql_statement IN VARCHAR2);

--  For debugging.  Gets sql strings used for dynamic sql statements.
--
  FUNCTION get_nsql_internal RETURN NUMBER;

  FUNCTION get_sql_internal(statement_number IN NUMBER,
	              statement_portion IN NUMBER DEFAULT 1) RETURN VARCHAR2;

--  Gets and adds to additional string of debug information.
--
  PROCEDURE add_debug(p_debug_string IN VARCHAR2,
		      p_debug_mode   IN VARCHAR2 DEFAULT 'STATEMENT');

  PROCEDURE set_debugging(p_debug_mode IN VARCHAR2);

  FUNCTION get_debug_internal(string_n IN NUMBER) RETURN VARCHAR2;

  /* New client side debug functions */
  PROCEDURE x_get_nsql(x_nsql OUT nocopy NUMBER);

  PROCEDURE x_get_sql_npiece(p_sql_num IN NUMBER,
			     x_npiece  OUT nocopy NUMBER);

  PROCEDURE x_get_sql_piece(p_sql_num   IN NUMBER,
			    p_piece_num IN NUMBER,
			    x_sql_piece OUT nocopy VARCHAR2);

  PROCEDURE x_get_ndebug(x_ndebug OUT nocopy NUMBER);

  PROCEDURE x_get_debug(p_debug_num IN NUMBER,
			x_debug OUT nocopy VARCHAR2);

/***** ReadOnly ER ***
--------------------------------------------------------------------------------
-- The following three procedures gets rbac security settings for kff, dff and
-- dff context field. Rbac api's are called to determine if rbac secuirty
-- is defined. If so, then insert/update permissions are checked for flexfields.
-- The permission is returned in a string.
-- Types of permissions are E/D/U.  E=enabled, D=disabled, U=unknown
-- Out Variables:
-- x_status returns true or false. True if rbac is defined and false if rbac is  not defined.
-- x_ins_permissions returns a string of insert permission as desc above.
-- x_upd_permissions returns a string of update permission as desc above.
-- For more informaiton see the package body
--------------------------------------------------------------------------------
PROCEDURE KFF_RO_SEGMENT_RBAC(
   p_appid    in NUMBER,
   p_code     in VARCHAR2,
   p_structid in NUMBER,
   x_segment_names  out nocopy VARCHAR2,
   x_status         out nocopy VARCHAR2,
   x_ins_permissions     out nocopy VARCHAR2,
   x_upd_permissions    out nocopy VARCHAR2);
PROCEDURE DFF_RO_SEGMENT_RBAC(
   p_appid        in NUMBER,
   p_dff_name     in VARCHAR2,
   p_context_code in VARCHAR2,
   x_segment_names out nocopy VARCHAR2,
   x_seg_status        out nocopy VARCHAR2,
   x_ins_permissions   out nocopy VARCHAR2,
   x_upd_permissions   out nocopy VARCHAR2);
 PROCEDURE DFF_RO_CTXT_FLD_RBAC(
   p_appid        in NUMBER,
   p_dff_name     in VARCHAR2,
   x_ctxf_status        out nocopy VARCHAR2,
   x_ins_permissions   out nocopy VARCHAR2,
   x_upd_permissions   out nocopy VARCHAR2);
--------------------------------------------------------------------------------
*****/

END fnd_flex_server1;

/
