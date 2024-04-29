--------------------------------------------------------
--  DDL for Package Body IGS_RU_GEN_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RU_GEN_002" AS
/* $Header: IGSRU02B.pls 115.19 2003/09/04 08:06:40 rghosh ship $ */

Function Rulp_Ins_Parser(
  p_group IN NUMBER ,
  p_return_type IN VARCHAR2 ,
  p_rule_description IN VARCHAR2 ,
  p_rule_processed IN OUT NOCOPY VARCHAR2 ,
  p_rule_unprocessed IN OUT NOCOPY VARCHAR2 ,
  p_generate_rule IN BOOLEAN ,
  p_rule_number IN OUT NOCOPY NUMBER ,
  p_LOV_number IN OUT NOCOPY NUMBER )
RETURN BOOLEAN IS
  ------------------------------------------------------------------
  --Created by  : nsinha, Oracle India
  --Date created: 12-Mar-1999
  --
  --Purpose: Parses the Rule Text for Syntax Checking.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --Nsinha      12-Mar-2002     Bug # 2233951: Changed the reference of
  --                            IGS_RU_GEN_003 and IGS_GE_GEN_004 with IGS_RU_GEN_006
  --
  -------------------------------------------------------------------
/*
 STRUCTURES
*/
TYPE t_number IS TABLE OF
	NUMBER(6)
INDEX BY BINARY_INTEGER;
TYPE r_LOV IS RECORD (
	select_item	IGS_RU_DESCRIPTION.rule_description%TYPE,
	description	VARCHAR2(2000),
	selectable	VARCHAR2(1) );
TYPE t_LOV IS TABLE OF
	r_LOV
INDEX BY BINARY_INTEGER;
TYPE t_param_list IS TABLE OF
	IGS_RU_RET_TYPE.s_return_type%TYPE
INDEX BY BINARY_INTEGER;

/*
 CONSTANTS
*/
cst_space	CONSTANT VARCHAR2(1) := fnd_global.local_chr(31);
cst_spacemod	CONSTANT VARCHAR2(1) := fnd_global.local_chr(9);
/*
 GLOBALS
*/
gv_level	NUMBER(3);
gv_set_number	IGS_RU_SET.sequence_number%TYPE;
gv_min_rule	NUMBER;
/*
 when delete rule, keep rule numbers to reuse
*/
gt_rule_numbers	t_number;
gv_rn_index	NUMBER;
/*
 when delete rule, keep set numbers to reuse
*/
gt_set_numbers	t_number;
gv_sn_index	NUMBER;
/*
 table of selectable items
*/
gt_rule_LOV	t_LOV;
gv_LOV_index	NUMBER;
/*
 list of parameter return types
*/
gt_param_list	t_param_list;
gv_params	NUMBER;
gv_param_type	IGS_RU_RET_TYPE.s_return_type%TYPE;
/*
 string termiate character
*/
gv_string_terminate	VARCHAR2(10);
/*
 selected value in LOV's
*/
gv_prev		VARCHAR2(100);
gv_pprev	VARCHAR2(100);
gv_select_count	NUMBER := 0;
/*

 FORWARD REFERENCE DECLARATIONS

*/
FUNCTION parse_rule(
	p_type		IN VARCHAR2,
	p_rule		IN OUT NOCOPY VARCHAR2,
	p_rule_number	IN NUMBER,
	p_item		IN OUT NOCOPY NUMBER)
RETURN BOOLEAN;
/*

 MISCELLANEOUS FUNCTIONS

*/

/*

 maintain LOV array

*/
PROCEDURE make_LOV(
	p_rule		IN VARCHAR2,
	p_string	IN VARCHAR2,
	p_description	IN VARCHAR2,
	p_selectable	IN VARCHAR2)
IS
BEGIN DECLARE
	v_rule_length	NUMBER;
BEGIN
/*
 RETURN;
*/
	v_rule_length := LENGTH(p_rule);
	IF v_rule_length IS NULL
	THEN
		v_rule_length := 0;
	END IF;
	IF v_rule_length < gv_min_rule
	THEN
/*
		 start again
*/
		gv_min_rule := v_rule_length;
		gv_LOV_index := 0;
	END IF;
	IF v_rule_length = gv_min_rule
	THEN
		gv_LOV_index := gv_LOV_index + 1;
		gt_rule_LOV(gv_LOV_index).select_item := REPLACE(p_string,fnd_global.local_chr(10));
		gt_rule_LOV(gv_LOV_index).description := p_description;
		gt_rule_LOV(gv_LOV_index).selectable := p_selectable;
	END IF;
END;
END make_LOV;
/*

 one item, no directives
 return item or null

*/
FUNCTION LOV_item
RETURN VARCHAR2 IS
	v_description	IGS_RU_LOV.description%TYPE;
	v_selectable	IGS_RU_LOV.selectable%TYPE;
BEGIN
	SELECT	description,
		selectable
	INTO	v_description,
		v_selectable
	FROM	IGS_RU_LOV
	WHERE	sequence_number = p_LOV_number;
	IF v_selectable = 'Y'
	THEN
		RETURN v_description;
	END IF;
	RETURN NULL;
	EXCEPTION
		WHEN TOO_MANY_ROWS THEN
			RETURN NULL;
END LOV_item;
/*

 move LOV's to table

*/
PROCEDURE insert_LOV_tab
IS
X_ROWID  VARCHAR2(25);
v_help_text	igs_ru_lov.help_text%TYPE;
CURSOR C_RL IS
	SELECT ROWID, rl.*
	FROM IGS_RU_LOV rl
	WHERE SEQUENCE_NUMBER = p_LOV_number ;

BEGIN
	IF p_LOV_number IS NULL
	THEN
		SELECT	IGS_RU_LOV_SEQ_NUM_S.nextval
		INTO	p_LOV_number
		FROM	DUAL;
	END IF;

	FOR C_RL_REC IN C_RL LOOP
		IGS_RU_LOV_PKG.DELETE_ROW (X_ROWID => C_RL_REC.ROWID	);
	END LOOP;


	FOR v_index IN 1 .. gv_LOV_index
	LOOP
	BEGIN
		IGS_RU_LOV_PKG.INSERT_ROW (
		X_ROWID => X_ROWID,
		X_SEQUENCE_NUMBER => p_LOV_number,
		X_DESCRIPTION     => LTRIM(RTRIM(gt_rule_LOV(v_index).select_item)),
		X_HELP_TEXT       => LTRIM(RTRIM(gt_rule_LOV(v_index).description)),
		X_SELECTABLE      => LTRIM(RTRIM(gt_rule_LOV(v_index).selectable)) );

		EXCEPTION
			WHEN DUP_VAL_ON_INDEX THEN
/*
				NULL;
				 order of descriptions (better this way)
*/
				UPDATE	igs_ru_lov
				SET	help_text = LTRIM(RTRIM(gt_rule_LOV(v_index).description))
				WHERE	sequence_number = p_LOV_number
				AND	description = LTRIM(RTRIM(gt_rule_LOV(v_index).select_item));

	END;
	END LOOP;
END insert_LOV_tab;
/*

 make new rule

*/
FUNCTION new_rule
  ------------------------------------------------------------------
  --Created by  : nsinha, Oracle India
  --Date created: 12-Mar-2002
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --nsinha      12-Mar-2002     Bug# 2233951: Modified the logic to
  --                            SELECT the next value of the sequence number
  --                            differently when the data is for SEED DB.
  --
  -------------------------------------------------------------------
RETURN NUMBER IS
BEGIN DECLARE
	v_rule_number	NUMBER;
	X_ROWID  		VARCHAR2(25);

	CURSOR C_IGS_RU_RULE_SEQ_NUM_S IS
        SELECT igs_ru_rule_seq_num_s.NEXTVAL
	FROM   DUAL;

     CURSOR cur_max_plus_one IS
      SELECT   (sequence_number + 1) sequence_number
      FROM     igs_ru_rule
      WHERE    sequence_number =
        (SELECT   MAX (sequence_number)
         FROM     igs_ru_rule
         WHERE    sequence_number < 499999)
      FOR UPDATE OF sequence_number NOWAIT;

BEGIN
	IF p_generate_rule = FALSE
	THEN
		RETURN NULL;
	END IF;
	IF gv_rn_index = 0
	THEN
          --
	  --  New description number
          --  If the User creating this record is DATAMERGE (id = 1) then
          --    Get the sequence as the existing maximum value + 1
          --  Else
          --    Get the next value from the database sequence
          --
          IF (fnd_global.user_id = 1) THEN
            OPEN  cur_max_plus_one;
            FETCH cur_max_plus_one INTO v_rule_number;
            CLOSE cur_max_plus_one;
          ELSE
            OPEN C_IGS_RU_RULE_SEQ_NUM_S;
            FETCH C_IGS_RU_RULE_SEQ_NUM_S INTO v_rule_number;
            CLOSE C_IGS_RU_RULE_SEQ_NUM_S;
          END IF;
	ELSE
           /*
		 use deleted rule number
           */
		v_rule_number := gt_rule_numbers(gv_rn_index);
		gv_rn_index := gv_rn_index - 1;
	END IF;

      IGS_RU_RULE_PKG.INSERT_ROW (
	X_ROWID		 => X_ROWID ,
 	X_SEQUENCE_NUMBER	 => V_RULE_NUMBER );

	RETURN v_rule_number;
END;
END new_rule;
/*

 insert new set

*/
FUNCTION new_set (
	p_set_type	IN IGS_RU_SET.set_type%TYPE )
RETURN NUMBER IS
BEGIN DECLARE
	v_set_number	NUMBER;
	X_ROWID		VARCHAR2(25);

	CURSOR C_IGS_RU_SET_SEQ_NUM_S IS
        SELECT igs_ru_set_seq_num_s.NEXTVAL
	FROM   DUAL;

     CURSOR cur_max_plus_one IS
      SELECT   (sequence_number + 1) sequence_number
      FROM     igs_ru_set
      WHERE    sequence_number =
        (SELECT   MAX (sequence_number)
         FROM     igs_ru_set
         WHERE    sequence_number < 499999)
      FOR UPDATE OF sequence_number NOWAIT;
BEGIN
	IF p_generate_rule = FALSE
	THEN
		RETURN NULL;
	END IF;
	IF gv_sn_index = 0 THEN
	  --
	  --  New description number
          --  If the User creating this record is DATAMERGE (id = 1) then
          --    Get the sequence as the existing maximum value + 1
          --  Else
          --    Get the next value from the database sequence
          --
          IF (fnd_global.user_id = 1) THEN
            OPEN  cur_max_plus_one;
            FETCH cur_max_plus_one INTO v_set_number;
            CLOSE cur_max_plus_one;
          ELSE
            OPEN C_IGS_RU_SET_SEQ_NUM_S;
            FETCH C_IGS_RU_SET_SEQ_NUM_S INTO v_set_number;
            CLOSE C_IGS_RU_SET_SEQ_NUM_S;
          END IF;
	ELSE
          /*
		 use deleted set number
          */
		v_set_number := gt_set_numbers(gv_sn_index);
		gv_sn_index := gv_sn_index - 1;
	END IF;

      IGS_RU_SET_PKG.INSERT_ROW (
	X_ROWID => X_ROWID,
	X_SEQUENCE_NUMBER  => v_set_number,
	X_SET_TYPE         => p_set_type );

	RETURN v_set_number;
END;
END new_set;
/*

 consume leading spaces and tabs, return rest of string

*/
PROCEDURE consume_leading_spaces(
	p_rule		IN OUT NOCOPY VARCHAR2)
IS
	v_first		NUMBER;
BEGIN
/*
	 skip internal space and tab
*/
	v_first := 1;
	WHILE SUBSTR(p_rule,v_first,1) = cst_space
	OR    SUBSTR(p_rule,v_first,1) = '	'
	LOOP
		v_first := v_first + 1;
	END LOOP;
	p_rule := SUBSTR(p_rule,v_first);
END consume_leading_spaces;
/*

 consume unit code
 make LOV

*/
FUNCTION consume_unit_code(
	p_rule		IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN IS
	v_char		VARCHAR2(1);
	v_count		NUMBER;
	v_no_units	BOOLEAN := TRUE;
	v_unit_cd	IGS_PS_UNIT_VER.unit_cd%TYPE := '%4$@G!))^';
	v_max_count	NUMBER;
BEGIN
	gv_select_count := 0;
	consume_leading_spaces(p_rule);
	FOR v_ii IN 1 .. 200 /*LENGTH(p_rule)*/
	LOOP
		v_char := SUBSTR(p_rule,v_ii,1);
		IF v_char = ','		/* next set member*/
		OR v_char = '.'		/* versions       */
		OR v_char = '}' 	/* end of set     */
		OR v_char = cst_space	/* internal space */
		OR v_char IS NULL	/* end of line    */
		THEN
			IF v_ii = 1
			THEN
				/* invalid first char, no unit*/
				make_LOV(p_rule,
					'*** Valid Unit Code ***',
					'Input part or all of a valid unit code.',
					'N');
				RETURN FALSE;
			ELSE
				/* count the number of units selected, remember their might be wildcards*/
				SELECT	count(*)
				INTO	v_count
				FROM	IGS_PS_UNIT_VER
				/*WHERE	unit_cd LIKE UPPER(SUBSTR(p_rule,1,v_ii - 1)); --Bug 2395891/2543627 --space not accepted in user defined rules*/
				WHERE	unit_cd LIKE UPPER(SUBSTR(REPLACE(p_rule,cst_spacemod,' '),1,v_ii - 1)); --nshee
				IF v_count = 0
				THEN
/*
					 check if to many selected units (1000)
*/
					SELECT	count(*)
					INTO	v_max_count
					FROM	IGS_PS_UNIT_VER
					/*WHERE	unit_cd LIKE UPPER(SUBSTR(p_rule,1,v_ii - 1))||'%'; --Bug 2395891/2543627 --space not accepted in user defined rules*/
					WHERE	unit_cd LIKE UPPER(SUBSTR(REPLACE(p_rule,cst_spacemod,' '),1,v_ii - 1))||'%';--nshee
					IF v_max_count > 1000
					THEN
						make_LOV(p_rule,
							'*** To many units selected. ***',
							'Suggest you restrict the select criteria further.',
							'N');
						RETURN FALSE;
					END IF;
/*
					 build list of values using the first few chars
*/
					FOR uv IN (
						SELECT	unit_cd,
							version_number,
							unit_status,
							short_title
						FROM	IGS_PS_UNIT_VER
						/*WHERE	unit_cd LIKE UPPER(SUBSTR(p_rule,1,v_ii - 1))||'%' --Bug 2395891/2543627 --space not accepted in user defined rules*/
						WHERE	unit_cd LIKE UPPER(SUBSTR(REPLACE(p_rule,cst_spacemod,' '),1,v_ii - 1))||'%' --nshee
						ORDER BY unit_cd,version_number DESC )
					LOOP
						v_no_units := FALSE;
						IF uv.unit_cd <> v_unit_cd
						THEN
/*
							 latest version of new unit code
*/
							make_LOV(p_rule,
								uv.unit_cd,
								uv.short_title||'   (ALL VERSIONS)',
								'Y');
						END IF;
						v_unit_cd := uv.unit_cd;
/*
						 list all versions
*/
						make_LOV(p_rule,
							uv.unit_cd||'.'||IGS_GE_NUMBER.TO_CANN(uv.version_number),
							uv.short_title||'   ('||uv.unit_status||')',
							'Y');
					END LOOP;
					IF v_no_units
					THEN
						make_LOV(p_rule,
							'*** Valid Unit Code ***',
							'Input part or all of a valid unit code.',
							'N');
					ELSE
						gv_select_count := v_ii - 1;
					END IF;
					RETURN FALSE;
				ELSE
/*
					 found unit(s)
*/
					p_rule := SUBSTR(p_rule,v_ii);
					RETURN TRUE;
				END IF;
			END IF;
		END IF;
	END LOOP;
/*
	 end of line
*/
	p_rule := NULL;
	RETURN TRUE;
END consume_unit_code;
/*

 consume unit set code

*/
FUNCTION consume_us_code(
	p_rule		IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN IS
BEGIN DECLARE
	v_char		VARCHAR2(1);
	v_count		NUMBER;
	v_no_units	BOOLEAN := TRUE;
	v_unit_set_cd	IGS_EN_UNIT_SET.unit_set_cd%TYPE := '#@*&!Vv9(';
	v_max_count	NUMBER;
BEGIN
	consume_leading_spaces(p_rule);
	FOR v_ii IN 1 .. 200
	LOOP
		v_char := SUBSTR(p_rule,v_ii,1);
		IF v_char = ','		/* next set member  */
		OR v_char = '.'		/* versions	      */
		OR v_char = '}' 	/* end of set       */
		OR v_char = cst_space	/* internal space   */
		OR v_char IS NULL	/* end of line      */
		THEN
			IF v_ii = 1
			THEN
/*
				 invalid first char, no unit set
*/
				make_LOV(p_rule,'*** Valid Unit Set Code ***',
					'Input part or all of a valid unit set code.',
					'N');
				RETURN FALSE;
			ELSE
/*
				 count the number of UNIT sets selected, remember their might be wildcards
*/
				SELECT	count(*)
				INTO	v_count
				FROM	IGS_EN_UNIT_SET
/*				WHERE	unit_set_cd LIKE UPPER(SUBSTR(p_rule,1,v_ii - 1)); commented by nshee as part of fix of bug 2381638 and 2395891 and added the next line */
				WHERE	unit_set_cd LIKE UPPER(SUBSTR(REPLACE(p_rule,cst_spacemod,' '),1,v_ii - 1));
				IF v_count = 0
				THEN
/*
					 check if to many selected set members (1000)
*/
					SELECT	count(*)
					INTO	v_max_count
					FROM	IGS_EN_UNIT_SET
					/*WHERE	unit_set_cd LIKE UPPER(SUBSTR(p_rule,1,v_ii - 1))||'%';--Bug 2395891/2543627 --space not accepted in user defined rules*/
					WHERE	unit_set_cd LIKE UPPER(SUBSTR(REPLACE(p_rule,cst_spacemod,' '),1,v_ii - 1))||'%';--nshee
					IF v_max_count > 1000
					THEN
						make_LOV(p_rule,
							'*** To many unit sets selected. ***',
							'Suggest you restrict the select criteria further.',
							'N');
						RETURN FALSE;
					END IF;
/*
					 build list of values using the first few chars
*/
					FOR us IN (
						SELECT	unit_set_cd,
							version_number,
							unit_set_status,
							short_title
						FROM	IGS_EN_UNIT_SET
						/*WHERE	unit_set_cd LIKE UPPER(SUBSTR(p_rule,1,v_ii - 1))||'%'--Bug 2395891/2543627 --space not accepted in user defined rules*/
						WHERE	unit_set_cd LIKE UPPER(SUBSTR(REPLACE(p_rule,cst_spacemod,' '),1,v_ii - 1))||'%'--nshee
						ORDER BY unit_set_cd,version_number DESC )
					LOOP
						v_no_units := FALSE;
						IF us.unit_set_cd <> v_unit_set_cd
						THEN
/*
							 latest version of new unit code
*/
							make_LOV(p_rule,us.unit_set_cd,
								us.short_title||'   (ALL VERSIONS)',
								'Y');
						END IF;
						v_unit_set_cd := us.unit_set_cd;
/*
						 list all versions
*/
						make_LOV(p_rule,us.unit_set_cd||'.'||IGS_GE_NUMBER.TO_CANN(us.version_number),
							us.short_title||'   ('||us.unit_set_status||')',
							'Y');
					END LOOP;
					IF v_no_units
					THEN
						make_LOV(p_rule,'*** Valid Unit Set Code ***',
							'Input part or all of a valid unit set code.',
							'N');
					END IF;
					RETURN FALSE;
				ELSE
/*
					 found unit(s)
*/
					p_rule := SUBSTR(p_rule,v_ii);
					RETURN TRUE;
				END IF;
			END IF;
		END IF;
	END LOOP;
/*
	 end of line
*/
	p_rule := NULL;
	RETURN TRUE;
END;
END consume_us_code;
/*

 consume course code
 make LOV

*/
FUNCTION consume_crs_code(
	p_rule		IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN IS
	v_char		VARCHAR2(1);
	v_count		NUMBER;
	v_no_members	BOOLEAN := TRUE;
	v_member_cd	IGS_PS_VER.course_cd%TYPE := '%4@!)^';
	v_max_count	NUMBER;
BEGIN
	consume_leading_spaces(p_rule);
	FOR v_ii IN 1 .. 200 /*LENGTH(p_rule) */
	LOOP
		v_char := SUBSTR(p_rule,v_ii,1);
		IF v_char = ','		/* next set member */
		OR v_char = '.'		/* versions        */
		OR v_char = '}' 	/* end of set      */
		OR v_char = cst_space	/* internal space  */
		OR v_char IS NULL	/* end of line     */
		THEN
			IF v_ii = 1
			THEN
/*
				 invalid first char, no member(s)
*/
				make_LOV(p_rule,
					'*** Valid Course Code ***',
					'Input part or all of a valid course code.',
					'N');
				RETURN FALSE;
			ELSE
/*
				 count the number of members selected, remember their might be wildcards
*/
				SELECT	count(*)
				INTO	v_count
				FROM	IGS_PS_VER
				/*WHERE	course_cd LIKE UPPER(SUBSTR(p_rule,1,v_ii - 1));--Bug 2395891/2543627 --space not accepted in user defined rules*/
				WHERE	course_cd LIKE UPPER(SUBSTR(REPLACE(p_rule,cst_spacemod,' '),1,v_ii - 1));--nshee
				IF v_count = 0
				THEN
/*
					 check if to many selected set members (1000)
*/
					SELECT	count(*)
					INTO	v_max_count
					FROM	IGS_PS_VER
					/*WHERE	course_cd LIKE UPPER(SUBSTR(p_rule,1,v_ii - 1))||'%';--Bug 2395891/2543627 --space not accepted in user defined rules*/
					WHERE	course_cd LIKE UPPER(SUBSTR(REPLACE(p_rule,cst_spacemod,' '),1,v_ii - 1))||'%';--nshee
					IF v_max_count > 1000
					THEN
						make_LOV(p_rule,
							'*** To many courses selected. ***',
							'Suggest you restrict the select criteria further.',
							'N');
						RETURN FALSE;
					END IF;
/*
					 build list of values using the first few chars
*/
					FOR cv IN (
						SELECT	course_cd,
							version_number,
							course_status,
							short_title
						FROM	IGS_PS_VER
						/*WHERE	course_cd LIKE UPPER(SUBSTR(p_rule,1,v_ii - 1))||'%'--Bug 2395891/2543627 --space not accepted in user defined rules*/
						WHERE	course_cd LIKE UPPER(SUBSTR(REPLACE(p_rule,cst_spacemod,' '),1,v_ii - 1))||'%'--nshee
						ORDER BY course_cd,version_number DESC )
					LOOP
						v_no_members := FALSE;
						IF cv.course_cd <> v_member_cd
						THEN
/*
							 latest version of new member code
*/
							make_LOV(p_rule,
								cv.course_cd,
								cv.short_title||'   (ALL VERSIONS)',
								'Y');
						END IF;
						v_member_cd := cv.course_cd;
/*
						 list all versions
*/
						make_LOV(p_rule,
							cv.course_cd||'.'||IGS_GE_NUMBER.TO_CANN(cv.version_number),
							cv.short_title||'   ('||cv.course_status||')',
							'Y');
					END LOOP;
					IF v_no_members
					THEN
						make_LOV(p_rule,
							'*** Valid Course Code ***',
							'Input part or all of a valid course code.',
							'N');
					END IF;
					RETURN FALSE;
				ELSE
/*
					 found members(s)
*/
					p_rule := SUBSTR(p_rule,v_ii);
					RETURN TRUE;
				END IF;
			END IF;
		END IF;
	END LOOP;
/*
	 end of line
*/
	p_rule := NULL;
	RETURN TRUE;
END consume_crs_code;
/*

 rationalise versions {AAC101.1,AAC101,2} => {AAC101.[1-2]}
 order the versions string 10-12,4,7,5 => 4-5,7,10-12
 versions of form 7-2 are nonsense and will be ignored

*/
FUNCTION do_versions (
	p_current_versions	VARCHAR2,
	p_extra_versions	VARCHAR2 )
RETURN VARCHAR2 IS
	v_concat_versions	VARCHAR2(200);
	v_prev_comma		NUMBER := 1;	/* previous position of comma in string */
	v_curr_comma		NUMBER;		/* current position of comma in string  */
	v_sub_str		VARCHAR2(30);	/* sub-string between comma's           */
	v_dash			NUMBER;		/* position of '-' in sub-string        */
	v_lower			NUMBER;
	v_upper			NUMBER;
	vt_version		t_number;	/* array of version numbers             */
	v_max_ver		NUMBER := 0;
	v_new_versions		IGS_RU_SET_MEMBER.versions%TYPE;
BEGIN
	IF p_current_versions IS NULL OR
	   p_extra_versions IS NULL
	THEN
/*
		 null mean ALL versions
*/
		RETURN NULL;
	END IF;
/*
	 breakdown the versions string and build the versions array
*/
	v_concat_versions := p_current_versions||','||p_extra_versions;
	LOOP
/*
		 find next comma (if exists)
*/
        	v_curr_comma := INSTR(v_concat_versions, ',', v_prev_comma);
        	IF v_curr_comma = 0
        	THEN
/*
			 all/rest of string
*/
			v_sub_str := SUBSTR(v_concat_versions, v_prev_comma);
		ELSE
/*
			 part of string, previous comma to this comma
*/
			v_sub_str := SUBSTR(v_concat_versions, v_prev_comma,
						v_curr_comma - v_prev_comma);
		END IF;
        	v_prev_comma := v_curr_comma + 1;
/*
        	 find next dash in sub-string (if exists)
*/
		v_dash := INSTR(v_sub_str, '-');
        	IF v_dash = 0
        	THEN
			v_lower := IGS_GE_NUMBER.TO_NUM(v_sub_str);
			v_upper := v_lower;
		ELSE
/*
			 dash in sub-string, split lower and upper
*/
			v_lower := IGS_GE_NUMBER.TO_NUM(SUBSTR(v_sub_str, 1, v_dash - 1));
			v_upper := IGS_GE_NUMBER.TO_NUM(SUBSTR(v_sub_str, v_dash + 1));
		END IF;
		IF v_lower IS NOT NULL
		THEN
/*
			 populate array
*/
			FOR v_ii IN 1 .. v_upper - v_lower + 1
			LOOP
/*
				 array index and value are the same
*/
				vt_version(v_ii + v_lower - 1) := v_ii + v_lower - 1;
			END LOOP;
			IF v_max_ver < v_upper
			THEN
/*
				 set max version
*/
				v_max_ver := v_upper;
			END IF;
		END IF;
        	IF v_curr_comma = 0
        	THEN
			EXIT;
		END IF;
	END LOOP;
/*
	 rebuild the versions string from the versions array
*/
	v_lower := NULL;
	FOR v_ii IN 1 .. v_max_ver + 1
	LOOP
	BEGIN
		IF v_lower IS NULL
		THEN
			v_lower := vt_version(v_ii);
			v_upper := vt_version(v_ii);
		ELSE
			v_upper := vt_version(v_ii);
		END IF;
		EXCEPTION
		WHEN NO_DATA_FOUND THEN
			IF v_lower IS NOT NULL
			THEN
				IF v_new_versions IS NOT NULL
				THEN
/*
					 there's more therefor add comma
*/
					v_new_versions := v_new_versions||',';
				END IF;
				IF v_lower = v_upper
				THEN
/*
					 single version
*/
					v_new_versions := v_new_versions||IGS_GE_NUMBER.TO_CANN(v_lower);
				ELSE
/*
					 range
*/
					v_new_versions := v_new_versions||IGS_GE_NUMBER.TO_CANN(v_lower)||'-'||IGS_GE_NUMBER.TO_CANN(v_upper);
				END IF;
			END IF;
			v_lower := NULL;
	END;
	END LOOP;
	RETURN v_new_versions;
END do_versions;
/*

 insert set member

*/
PROCEDURE insert_set_member(
	p_set_number	IN IGS_RU_SET.sequence_number%TYPE,
	p_unit		IN VARCHAR2)
IS
	v_unit			VARCHAR2(200);
	v_dot			NUMBER;
	v_unit_cd		IGS_RU_SET_MEMBER.unit_cd%TYPE;
	v_versions		VARCHAR2(100); /* bigger to allow for spaces etc*/
	v_current_versions	IGS_RU_SET_MEMBER.versions%TYPE;
	v_new_versions		IGS_RU_SET_MEMBER.versions%TYPE;
	X_ROWID			VARCHAR2(25);

	CURSOR C_RSMBR IS
	SELECT ROWID, rsmbr.*
	FROM   IGS_RU_SET_MEMBER rsmbr
	WHERE	rs_sequence_number = p_set_number
	AND	unit_cd = v_unit_cd;

BEGIN
	IF p_generate_rule = FALSE
	THEN
		RETURN;
	END IF;
/*
	 remove spaces and tabs
*/
	v_unit := REPLACE(p_unit,cst_space);
        v_unit := UPPER(REPLACE(v_unit,cst_spacemod,' '));/*added this line by nshee as fix for bug 2395891*/
	v_unit := UPPER(REPLACE(v_unit,'	'));
	v_dot := INSTR(v_unit,'.');
	IF v_dot = 0
	THEN
		v_unit_cd := v_unit;
	ELSE
		v_unit_cd := RTRIM(SUBSTR(v_unit,1,v_dot - 1));
		v_versions := SUBSTR(v_unit,v_dot + 1);
/*
		 remove brackets '[', ']' (range)
*/
		v_versions := REPLACE(v_versions,'[');
		v_versions := REPLACE(v_versions,']');
	END IF;
	IF v_unit_cd IS NOT NULL
	THEN
		IGS_RU_SET_MEMBER_PKG.INSERT_ROW (
		X_ROWID			=>	X_ROWID,
		X_RS_SEQUENCE_NUMBER    =>	p_set_number,
		X_UNIT_CD               =>	v_unit_cd,
		X_VERSIONS              =>	v_versions );

	END IF;
	EXCEPTION
	WHEN DUP_VAL_ON_INDEX THEN
		SELECT	versions
		INTO	v_current_versions
		FROM	IGS_RU_SET_MEMBER
		WHERE	rs_sequence_number = p_set_number
		AND	unit_cd = v_unit_cd;
/*
		 rationalise new versions with existing versions

*/
		  v_new_versions := do_versions(v_current_versions,v_versions);

		FOR C_RSMBR_REC IN C_RSMBR LOOP
                   IGS_RU_SET_MEMBER_PKG.UPDATE_ROW (
			X_ROWID 			=> C_RSMBR_REC.ROWID,
			X_RS_SEQUENCE_NUMBER	=> C_RSMBR_REC.RS_SEQUENCE_NUMBER,
			X_UNIT_CD               => C_RSMBR_REC.UNIT_CD ,
			X_VERSIONS              => v_new_versions );
		END LOOP;

END insert_set_member;
/*

 get a number

*/
FUNCTION get_number (
	p_number	OUT NOCOPY NUMBER,
	p_rule		IN OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN IS
	v_first		NUMBER;	/* first non white space      */
	v_count		NUMBER;	/* count until next non number*/
BEGIN
	IF p_rule IS NULL
	THEN
		RETURN FALSE;
	END IF;
/*
	 skip internal space and tab
*/
	v_first := 1;
	WHILE SUBSTR(p_rule,v_first,1) = cst_space
	OR    SUBSTR(p_rule,v_first,1) = '	'
	LOOP
		v_first := v_first + 1;
	END LOOP;
/*
	 check until end of line or VALUE_ERROR
*/
	v_count := 0;
	LOOP
	BEGIN
		v_count := v_count + 1;
		IF SUBSTR(p_rule,v_first + v_count - 1) IS NULL
		THEN
			EXIT;
		END IF;
/*
		 convert and validate number
*/
		p_number := IGS_GE_NUMBER.TO_NUM(SUBSTR(p_rule,v_first,v_count));
		EXCEPTION
			WHEN VALUE_ERROR THEN
				EXIT;
	END;
	END LOOP;
	IF v_count > 1
	THEN
/*
		 count > 1 therefor must have number
		 consume rule string
*/
		p_rule := SUBSTR(p_rule,v_first + v_count - 1);
		RETURN TRUE;
	END IF;
	RETURN FALSE;
END get_number;
/*

 get string until next quote

*/
FUNCTION get_string (
	p_string	OUT NOCOPY VARCHAR2,
	p_rule		IN OUT NOCOPY VARCHAR2,
	p_terminate	IN VARCHAR2 )
RETURN BOOLEAN IS
	v_quote	NUMBER;
BEGIN
	IF p_rule IS NULL
	THEN
		RETURN FALSE;
	END IF;
	v_quote := INSTR(p_rule,p_terminate);
	IF v_quote = 0
	THEN
		p_string := p_rule;
		p_rule := '';
	ELSE
		p_string := SUBSTR(p_rule,1,v_quote - 1);
		p_rule := SUBSTR(p_rule,v_quote);
	END IF;
	RETURN TRUE;
END get_string;
/*

 get date and validate

*/
FUNCTION get_date (
	p_string	IN OUT NOCOPY VARCHAR2,
	p_rule		IN OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN IS
	v_rule		VARCHAR2(2000);
	v_date_format	VARCHAR2(30);
BEGIN
	v_rule := p_rule;
/*
	 this assumes terminate string is same as commencement string?
*/
	IF get_string(p_string,p_rule,gv_string_terminate) = TRUE AND
	   IGS_RU_GEN_006.jbsp_get_dt_picture(REPLACE(p_string,cst_space),v_date_format) = TRUE
	THEN
		RETURN TRUE;
	END IF;
	p_rule := v_rule;
	RETURN FALSE;
END get_date;
/*

 match string to part of rule ignoring spaces,
 set ramainder of rule and return TRUE
 else FALSE

*/
FUNCTION match_string_to_rule(
	p_string	IN VARCHAR2,
	p_rule		IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN IS
BEGIN DECLARE
	v_string	IGS_RU_DESCRIPTION.rule_description%TYPE;
	v_string_length	NUMBER;
	v_sub_rule	IGS_RU_DESCRIPTION.rule_description%TYPE;
BEGIN
	IF p_rule IS NULL
	THEN
		RETURN FALSE;
	END IF;
	v_string := REPLACE(p_string,' ');
	v_string := REPLACE(v_string,fnd_global.local_chr(10));
	v_string := REPLACE(v_string,'	');
	v_string_length := LENGTH(v_string);
	FOR v_ii IN v_string_length .. LENGTH(p_rule)
	LOOP
/*
		 remove internal spaces
*/
		v_sub_rule := REPLACE(SUBSTR(p_rule,1,v_ii),cst_space);
/*
		 remove returns
*/
		v_sub_rule := REPLACE(v_sub_rule,fnd_global.local_chr(10));
/*
		 remove tabs
*/
		v_sub_rule := REPLACE(v_sub_rule,'	');
		IF LENGTH(v_sub_rule) = v_string_length
		THEN
			IF v_string = v_sub_rule
			THEN
				p_rule := LTRIM(SUBSTR(p_rule,v_ii + 1));
				RETURN TRUE;
			ELSE
				RETURN FALSE;
			END IF;
		END IF;
	END LOOP;
	RETURN FALSE;
END;
END match_string_to_rule;
/*

 convert the description string into token, action
 string, action, remainder of description
 string, NULL, NULL
 NULL, action, remainder of description

 return FALSE if description is NULL

*/
FUNCTION breakdown_desc (
	p_string	IN OUT NOCOPY IGS_RU_DESCRIPTION.rule_description%TYPE,
	p_action	IN OUT NOCOPY IGS_RU_DESCRIPTION.s_return_type%TYPE,
	p_description	IN OUT NOCOPY IGS_RU_DESCRIPTION.rule_description%TYPE )
RETURN BOOLEAN IS
BEGIN DECLARE
	v_hash	NUMBER;
BEGIN
/*
	 check if more to process
*/
	IF p_description IS NULL
	THEN
		RETURN FALSE;
	END IF;
	p_action := NULL;
	v_hash := INSTR(p_description, '#');
	p_string := SUBSTR(p_description,1,v_hash - 1);
	IF v_hash = 0
	THEN
		p_action := '';
		p_string := p_description;
	ELSE
		FOR return_types IN (
			SELECT	s_return_type
			FROM	IGS_RU_RET_TYPE
			WHERE	s_return_type LIKE SUBSTR(p_description,v_hash + 1,1)||'%'
			ORDER BY s_return_type DESC )
		LOOP
			IF SUBSTR(p_description,v_hash + 1,LENGTH(return_types.s_return_type))
				= return_types.s_return_type
			THEN
				p_action := return_types.s_return_type;
				EXIT;
			END IF;
		END LOOP;
		IF p_action IS NULL
		THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_OPER');
			IGS_GE_MSG_STACK.ADD;
		END IF;
	END IF;
	p_description := SUBSTR(p_description,v_hash + 1 + LENGTH(p_action));
	RETURN TRUE;
END;
END breakdown_desc;
/*

 count parameters in rule description

*/
FUNCTION count_params(
	p_rule_description	IN VARCHAR2)
RETURN NUMBER IS
BEGIN DECLARE
	v_rule_description	IGS_RU_DESCRIPTION.rule_description%TYPE;
	v_string		IGS_RU_DESCRIPTION.rule_description%TYPE;
	v_action		IGS_RU_RET_TYPE.s_return_type%TYPE;
	v_count			NUMBER := 0;
BEGIN
	v_rule_description := p_rule_description;
	WHILE breakdown_desc(v_string,v_action,v_rule_description)
	LOOP
		IF v_action IS NOT NULL
		THEN
			v_count := v_count + 1;
		END IF;
	END LOOP;
	RETURN v_count;
END;
END count_params;
/*

 set and count the parameter types in RULE description

*/
FUNCTION set_params(
	p_rule_description	IN VARCHAR2)
RETURN NUMBER IS
BEGIN DECLARE
	v_rule_description	IGS_RU_DESCRIPTION.rule_description%TYPE;
	v_string		IGS_RU_DESCRIPTION.rule_description%TYPE;
	v_action		IGS_RU_RET_TYPE.s_return_type%TYPE;
	v_count			NUMBER := 0;
BEGIN
	v_rule_description := p_rule_description;
	WHILE breakdown_desc(v_string,v_action,v_rule_description)
	LOOP
		IF v_action IS NOT NULL
		THEN
			v_count := v_count + 1;
			gt_param_list(v_count) := v_action;
		END IF;
	END LOOP;
	RETURN v_count;
END;
END set_params;
/*

 check if this parameter type is allowed

*/
FUNCTION valid_param_type (
	p_return_type	IGS_RU_RET_TYPE.s_return_type%TYPE )
RETURN BOOLEAN IS
BEGIN
	FOR v_ii IN 1 .. gv_params
	LOOP
		IF gt_param_list(v_ii) = p_return_type
		THEN
			RETURN TRUE;
		END IF;
	END LOOP;
	RETURN FALSE;
END valid_param_type;
/*

 check if this parameter is of valid type

*/
FUNCTION valid_param (
	p_return_type	IGS_RU_RET_TYPE.s_return_type%TYPE,
	p_param		NUMBER )
RETURN BOOLEAN IS
BEGIN
	IF gt_param_list(p_param) = p_return_type
	THEN
		RETURN TRUE;
	END IF;
	RETURN FALSE;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			RETURN FALSE;
END valid_param;
/*

 cascade delete RULE items
 save RULE and set numbers

*/
PROCEDURE delete_rule_items(
	p_rule_number	IN IGS_RU_RULE.sequence_number%TYPE,
	p_item		IN IGS_RU_ITEM.item%TYPE)
IS
		CURSOR c_rule_items IS
		SELECT	rowid, ri.*
		FROM	IGS_RU_ITEM  ri
		WHERE	rul_sequence_number = p_rule_number
		AND	item >= p_item ;

		CURSOR c_rule (p_rule_number IN IGS_RU_ITEM.RULE_NUMBER%TYPE) IS
		SELECT	rowid, rule.*
		FROM	IGS_RU_RULE  rule
		WHERE	sequence_number = p_rule_number;


		CURSOR c_rule_set_mbr(p_set_number IN IGS_RU_ITEM.SET_NUMBER%TYPE) IS
		SELECT	rowid, rsmbr.*
		FROM	IGS_RU_SET_MEMBER  rsmbr
		WHERE	rs_sequence_number =p_set_number;


		CURSOR C_rule_set (p_set_number IN IGS_RU_ITEM.SET_NUMBER%TYPE) IS
		SELECT	rowid, rs.*
		FROM	IGS_RU_SET  rs
		WHERE	sequence_number = p_set_number;


BEGIN
	FOR c_rule_items_REC IN c_rule_items	LOOP

		IGS_RU_ITEM_PKG.DELETE_ROW (
		X_ROWID => C_RULE_ITEMS_REC.ROWID );

		IF c_rule_items_rec.rule_number IS NOT NULL
		THEN
/*
			 save RULE number
*/
			gv_rn_index := gv_rn_index + 1;
			gt_rule_numbers(gv_rn_index) := c_rule_items_rec.rule_number;
/*
			 remove all items of this IGS_RU_RULE
*/
			delete_rule_items(c_rule_items_rec.rule_number,0);
/*
			 remove RULE
*/
			FOR c_rule_rec  IN c_rule (c_rule_items_rec.rule_number) LOOP
				IGS_RU_RULE_PKG.DELETE_ROW (X_ROWID => C_RULE_REC.ROWID );
			END LOOP;

		ELSIF c_rule_items_rec.set_number IS NOT NULL
		THEN
/*
			 save set number
*/
			gv_sn_index := gv_sn_index + 1;
			gt_set_numbers(gv_sn_index) := c_rule_items_rec.set_number;
/*
			 remove set members
*/
			FOR c_rule_set_mbr_rec IN c_rule_set_mbr(c_rule_items_rec.set_number) LOOP
				IGS_RU_SET_MEMBER_PKG.DELETE_ROW (X_ROWID => C_RULE_SET_MBR_REC.ROWID);
			END LOOP;

/*
			 remove set
*/
			FOR C_RULE_SET_REC IN C_RULE_SET(c_rule_items_rec.set_number) LOOP
				IGS_RU_SET_PKG.DELETE_ROW (X_ROWID => C_RULE_SET_REC.ROWID );
			END LOOP;

		END IF;
	END LOOP;
END delete_rule_items;
/*

 build and insert RULE item
 increment item if used

*/
PROCEDURE make_rule_item(
	p_from			IN VARCHAR2,
	p_rule_num		IN NUMBER,
	p_item			IN OUT NOCOPY NUMBER,
	p_turin_function	IN IGS_RU_ITEM.turin_function%TYPE,
	p_rud_seq_num		IN IGS_RU_DESCRIPTION.sequence_number%TYPE,
	p_rule_number		IN IGS_RU_ITEM.rule_number%TYPE,
	p_set_number		IN IGS_RU_ITEM.set_number%TYPE,
	p_value			IN IGS_RU_ITEM.value%TYPE)
IS
BEGIN DECLARE
	v_named_rule		IGS_RU_ITEM.named_rule%TYPE;
	v_value			IGS_RU_ITEM.value%TYPE;
	v_rule_description	IGS_RU_DESCRIPTION.rule_description%TYPE;
	X_ROWID			VARCHAR2(25);
BEGIN
	IF p_generate_rule = FALSE
	THEN
		RETURN;
	END IF;
	delete_rule_items(p_rule_num,p_item);
	v_value := p_value;
	IF p_turin_function IS NOT NULL
	THEN
		v_value := NULL;
	ELSIF p_rud_seq_num IS NOT NULL
	THEN
	BEGIN
/*
		 match to named RULE
*/
		SELECT	rul_sequence_number
		INTO	v_named_rule
		FROM	IGS_RU_NAMED_RULE
		WHERE	rud_sequence_number = p_rud_seq_num;
/*
		 set number of parameters for called RULE
*/
		SELECT	rule_description
		INTO	v_rule_description
		FROM	IGS_RU_DESCRIPTION
		WHERE	sequence_number = p_rud_seq_num;
		v_value := count_params(v_rule_description);
/*
		 add evaluate RULE item
*/
		make_rule_item('1',p_rule_num,p_item,
			'_ER',
			NULL,NULL,NULL,NULL);
		EXCEPTION
		WHEN NO_DATA_FOUND THEN
			IF p_value IS NULL
			THEN
/*
				 do nothing
*/
				RETURN;
			END IF;
			v_named_rule := NULL;
	END;
	END IF;
	IGS_RU_ITEM_PKG.INSERT_ROW (
	X_ROWID			=>	X_ROWID,
	X_RUL_SEQUENCE_NUMBER	=>	p_rule_num,
	X_ITEM                  => 	p_item,
	X_TURIN_FUNCTION        => 	p_turin_function,
	X_NAMED_RULE            => 	v_named_rule,
	X_RULE_NUMBER           => 	p_rule_number,
	X_SET_NUMBER            => 	p_set_number,
	X_VALUE                 => 	v_value,
	X_DERIVED_RULE          => 	NULL );

/*
	 increment item
*/
	p_item := p_item + 1;
END;
END make_rule_item;
/*

 from an SQL select string match value or create a list of values

*/
FUNCTION do_LOV (
	p_rule		IN OUT NOCOPY	VARCHAR2,
	p_rule_number	IN	NUMBER,
	p_item		IN OUT NOCOPY	NUMBER,
	p_select_string	IN	VARCHAR2 )
RETURN BOOLEAN IS
	v_select_string	VARCHAR2(2000);
	v_cursor	INTEGER;
	v_rows		INTEGER;
	v_value		VARCHAR2(100);
	v_description	VARCHAR2(100);
	v_count		NUMBER := 0;
BEGIN
/*
	 replace previously selected field(s) with their values
*/
	v_select_string := REPLACE(p_select_string,'$PREV',gv_prev);
	v_select_string := REPLACE(v_select_string,'$PPREV',gv_pprev);
	v_cursor := DBMS_SQL.OPEN_CURSOR;
	DBMS_SQL.PARSE(v_cursor,v_select_string||' ORDER BY 1 DESC',dbms_sql.native);
	DBMS_SQL.DEFINE_COLUMN(v_cursor,1,v_value,100);
	DBMS_SQL.DEFINE_COLUMN(v_cursor,2,v_description,100);
	v_rows := DBMS_SQL.EXECUTE(v_cursor);
	WHILE DBMS_SQL.FETCH_ROWS(v_cursor) > 0
	LOOP
		v_count := v_count + 1;
		DBMS_SQL.COLUMN_VALUE(v_cursor,1,v_value);
		IF match_string_to_rule(v_value,p_rule)
		THEN
/*
			 add selected value
*/
			make_rule_item('do_LOV',p_rule_number,p_item,
				NULL,NULL,NULL,NULL,
				v_value);
/*
			 set previous selected values
*/
			gv_pprev := gv_prev;
			gv_prev := v_value;
			DBMS_SQL.CLOSE_CURSOR(v_cursor);
			RETURN TRUE;
		END IF;
		DBMS_SQL.COLUMN_VALUE(v_cursor,2,v_description);
		make_LOV(p_rule,v_value,v_description,'Y');
	END LOOP;
	DBMS_SQL.CLOSE_CURSOR(v_cursor);
	IF v_count = 0
	THEN
		make_LOV(p_rule,
			'*** No values selected ***',
			'ERROR:No values selected while attempting '||
				'match from a database defined LOV''s.',
			'N');
	END IF;
	RETURN FALSE;
END do_LOV;

/*

 from an SQL select string match value, create set member or
 create a list of values

*/
FUNCTION make_set (
	p_rule		IN OUT NOCOPY	VARCHAR2,
	p_rule_number	IN	NUMBER,
	p_item		IN OUT NOCOPY	NUMBER,
	p_select_string	IN	VARCHAR2 )
RETURN BOOLEAN IS
	v_select_string	VARCHAR2(2000);
	v_cursor	INTEGER;
	v_rows		INTEGER;
	v_value		VARCHAR2(100);
	v_description	VARCHAR2(100);
	v_count		NUMBER := 0;
BEGIN
/*
	 replace previously selected field(s) with their values
*/
	v_select_string := REPLACE(p_select_string,'$PREV',gv_prev);
	v_select_string := REPLACE(v_select_string,'$PPREV',gv_pprev);
	v_cursor := DBMS_SQL.OPEN_CURSOR;
	DBMS_SQL.PARSE(v_cursor,v_select_string||' ORDER BY 1 DESC',dbms_sql.v7);
	DBMS_SQL.DEFINE_COLUMN(v_cursor,1,v_value,100);
	DBMS_SQL.DEFINE_COLUMN(v_cursor,2,v_description,100);
	v_rows := DBMS_SQL.EXECUTE(v_cursor);
	WHILE DBMS_SQL.FETCH_ROWS(v_cursor) > 0
	LOOP
		v_count := v_count + 1;
		DBMS_SQL.COLUMN_VALUE(v_cursor,1,v_value);
		IF match_string_to_rule(v_value,p_rule)
		THEN
			DBMS_SQL.CLOSE_CURSOR(v_cursor);
			RETURN TRUE;
		END IF;
		DBMS_SQL.COLUMN_VALUE(v_cursor,2,v_description);
		make_LOV(p_rule,v_value,v_description,'Y');
	END LOOP;
	DBMS_SQL.CLOSE_CURSOR(v_cursor);
	IF v_count = 0
	THEN
		make_LOV(p_rule,
			'*** No values selected ***',
			'ERROR:No values selected while attempting '||
				'match from a database defined LOV''s.',
			'N');
	END IF;
	RETURN FALSE;
END make_set;
/*

 parse RULE stage two

*/
FUNCTION parse_rule2(
	p_type		IN VARCHAR2,
	p_rule		IN OUT NOCOPY VARCHAR2,
	p_rule_number	IN NUMBER,
	p_item		IN OUT NOCOPY NUMBER)
RETURN BOOLEAN IS
BEGIN DECLARE
	v_rule			VARCHAR2(2000);
	v_string		IGS_RU_DESCRIPTION.rule_description%TYPE;
	v_action		IGS_RU_RET_TYPE.s_return_type%TYPE;
	v_rule_description	IGS_RU_DESCRIPTION.rule_description%TYPE;
	v_number		NUMBER;
	v_item			NUMBER;
	v_first			BOOLEAN;
BEGIN
/*
	 save RULE
*/
	v_rule := p_rule;
/*
	 save index
*/
	v_item := p_item;
/*
	 select all descriptions where the first description item <> return type
*/
	FOR rule_descriptions IN (
		SELECT	RUD.sequence_number,
			s_turin_function,
			rule_description,
			description
		FROM	IGS_RU_DESCRIPTION	RUD,
			IGS_RU_GROUP_SET		RGS
		WHERE	s_return_type = p_type
		AND	rule_description NOT LIKE '#'||p_type||'%'
		AND	RUD.sequence_number = RGS.rud_sequence_number
		AND	RGS.rug_sequence_number = p_group
		ORDER BY rule_description DESC )
	LOOP
		v_rule_description := rule_descriptions.rule_description;
		v_first := TRUE;
		WHILE breakdown_desc(v_string,v_action,v_rule_description)
		LOOP
/*
			 only do parameter if applicable
*/
			IF rule_descriptions.s_turin_function = '$'
			THEN
				IF valid_param_type(p_type)
				THEN
					gv_param_type := p_type;
				ELSE
					EXIT; /* while, get next description  */
				END IF;
			END IF;
			IF p_type = 'PARAM_NUMS'
			THEN
				IF NOT valid_param(gv_param_type,v_string)
				THEN
					EXIT; /* while, get next description  */
				END IF;
			END IF;
/*
			 do list of values select thingo
*/
			IF v_action = '[LOV]'
			THEN
				RETURN do_LOV(p_rule,p_rule_number,
					      p_item,v_rule_description);
/*
	 do generic set stuff determined from SQL
*/
			ELSIF v_action = '[GS_MBR]'
			THEN
				RETURN make_set(p_rule,p_rule_number,
					        p_item,v_rule_description);

			ELSIF v_action = '[ASCII]' OR v_action = '[DATE]'
			THEN
/*
				 set termiate string character
*/
				gv_string_terminate := v_string;
			END IF;
			IF v_string IS NOT NULL
			THEN
/*
				 string [action]
*/
				IF match_string_to_rule(v_string,p_rule)
				THEN
/*
					 found match, follow this path
*/
					IF v_first
					THEN
						IF v_action IS NULL
						THEN
/*
							 turin function, named RULE or value
*/
							make_rule_item('2',p_rule_number,p_item,
								rule_descriptions.s_turin_function,
								rule_descriptions.sequence_number,
								NULL,NULL,
								v_string);
						ELSE
/*
							 turin function, named RULE or intermediate action
*/
							make_rule_item('3',p_rule_number,p_item,
								rule_descriptions.s_turin_function,
								rule_descriptions.sequence_number,
								NULL,NULL,NULL);
						END IF;
					END IF;
					IF v_action IS NOT NULL
					THEN
						IF parse_rule(v_action,p_rule,p_rule_number,p_item)
						THEN
							IF v_rule_description IS NULL
							THEN
								RETURN TRUE;
							END IF;
						ELSE
							EXIT;  /* while, next description */
						END IF;
					ELSE
/*
						 no more description
*/
						RETURN TRUE;
					END IF;
				ELSE
					make_LOV(p_rule,v_string,
						rule_descriptions.description,'Y');
					EXIT; /* while, next description */
				END IF;
			ELSIF v_action IS NOT NULL
			THEN
/*
				 action only
				 lt,lte,eq,neq,gte,gt #ALLOWED_TYPE
*/
				make_rule_item('4',p_rule_number,p_item,
					rule_descriptions.s_turin_function,
					rule_descriptions.sequence_number,
					NULL,NULL,NULL);
				IF parse_rule(v_action,p_rule,p_rule_number,p_item)
				THEN
					IF v_rule_description IS NULL
					THEN
						RETURN TRUE;
					END IF;
				ELSE
/*
					 allow for number RETURN FALSE;
*/
					EXIT;
				END IF;
			END IF;
			v_first := FALSE;
		END LOOP;
/*		 restore RULE for next option   */
		p_rule := v_rule;
/*		 restore index for next option  */
		p_item := v_item;
	END LOOP;
	RETURN FALSE;
END;
END parse_rule2;
/*
 parse RULE
*/
FUNCTION parse_rule(
	p_type		IN VARCHAR2,
	p_rule		IN OUT NOCOPY VARCHAR2,
	p_rule_number	IN NUMBER,
	p_item		IN OUT NOCOPY NUMBER)
RETURN BOOLEAN IS
BEGIN DECLARE
	v_rule			VARCHAR2(2000);
	v_string		VARCHAR2(2000);
	v_action		IGS_RU_RET_TYPE.s_return_type%TYPE;
	v_rule_description	IGS_RU_DESCRIPTION.rule_description%TYPE;
	v_first_action		BOOLEAN;
	v_return		BOOLEAN;
	v_item			NUMBER;
	v_new_rule		NUMBER;
	v_new_item		NUMBER;
	v_type			IGS_RU_RET_TYPE.s_return_type%TYPE;
	v_evaluate		BOOLEAN;
	v_number		NUMBER;
	v_set_type		IGS_RU_SET.set_type%TYPE;
	v_next_action		IGS_RU_RET_TYPE.s_return_type%TYPE;
BEGIN
/*
	 special actions
*/
	IF SUBSTR(p_type,1,5) = '[0-9]'
	THEN
		IF get_number(v_number,p_rule) = TRUE
		THEN
			IF SUBSTR(p_type,6) IS NULL OR
			   SUBSTR(p_type,6) <> ':VERIFY'
			THEN
/*
				 add number
*/
				make_rule_item('5',p_rule_number,p_item,
					NULL,NULL,NULL,NULL,
					v_number);
			END IF;
			RETURN TRUE;
		ELSE
			make_LOV(p_rule,'*** A Number ***',
				'Input a number.','N');
			RETURN FALSE;
		END IF;
	ELSIF SUBSTR(p_type,1,7) = '[ASCII]'
	THEN
/*
		 this assumes terminate string is same as commencement string?
*/
		IF get_string(v_string,p_rule,gv_string_terminate) = TRUE
		THEN
/*
			 add string
*/
			make_rule_item('5.1',p_rule_number,p_item,
				NULL,NULL,NULL,NULL,
				v_string);
			RETURN TRUE;
		ELSE
			make_LOV(p_rule,'*** A String ***',
				'Input any text.','N');
			RETURN FALSE;
		END IF;
	ELSIF SUBSTR(p_type,1,6) = '[DATE]'
	THEN
		IF get_date(v_string,p_rule) = TRUE
		THEN
/*
			 add date
*/
			make_rule_item('5.1',p_rule_number,p_item,
				NULL,NULL,NULL,NULL,
				v_string);
			RETURN TRUE;
		ELSE
			make_LOV(p_rule,'*** A Date ***',
				'Input a valid date.','N');
			RETURN FALSE;
		END IF;
/*
	 SET RELATED CODE
	 all set types are described as (only change lower case fields to suit)
		set_name		{#[SET]set_type}
		set_type		#[MEMBER]set_member
		set_type		#[MEMBER]set_member,set_type
		set_member		#[set_cd]
		set_member		#[set_cd].#VERSIONS
	 new set
*/
	ELSIF SUBSTR(p_type,1,5) = '[SET]'
	THEN
/*
		 get set type/next action
		 set type is restricted to 10 chars
*/
		v_set_type := SUBSTR(p_type,6);
		v_next_action := v_set_type;
		gv_set_number := new_set(v_set_type);
		IF parse_rule(v_next_action,p_rule,p_rule_number,p_item)
		THEN
/*
			 add set number
*/
			make_rule_item('6',p_rule_number,p_item,
				NULL,NULL,NULL,
				gv_set_number,
				NULL);
			RETURN TRUE;
		ELSE
			RETURN FALSE;
		END IF;
/*
	 make set member
*/
	ELSIF SUBSTR(p_type,1,8) = '[MEMBER]'
	THEN
		v_rule := p_rule;
/*
		 get next action
*/
		v_next_action := SUBSTR(p_type,9);
		IF parse_rule(v_next_action,p_rule,p_rule_number,p_item)
		THEN
			insert_set_member(gv_set_number,
					SUBSTR(v_rule,1,LENGTH(v_rule) - LENGTH(p_rule)));
			RETURN TRUE;
		ELSE
			RETURN FALSE;
		END IF;
/*
	 consume set member, make LOV's
	 one per set type
*/
	ELSIF p_type = '[UNIT_CD]'
	THEN
		RETURN consume_unit_code(p_rule);
	ELSIF p_type = '[US_CD]'
	THEN
		RETURN consume_us_code(p_rule);
	ELSIF p_type = '[COURSE_CD]'
	THEN
		RETURN consume_crs_code(p_rule);
/*
	 SUB RULE CODE
*/
	ELSIF SUBSTR(p_type,1,5) = 'RULE.'
	THEN
/*
		 make new sub-RULE
*/
		v_type := SUBSTR(p_type,6);
		IF SUBSTR(v_type,1,5) = 'EVAL.'
		THEN
/*
			 evaluate RULE
*/
			v_type := SUBSTR(v_type,6);
			v_evaluate := TRUE;
		ELSE
			v_evaluate := FALSE;
		END IF;
		v_new_rule := new_rule;
		v_new_item := 1;
		IF parse_rule(v_type,p_rule,v_new_rule,v_new_item)
		THEN
			IF v_evaluate
			THEN
/*
				 add evaluate RULE item
*/
				make_rule_item('7',p_rule_number,p_item,
					'_ER',
					NULL,NULL,NULL,NULL);
			END IF;
			make_rule_item('8',p_rule_number,p_item,
				NULL,NULL,
				v_new_rule,
				NULL,gv_params);
			RETURN TRUE;
		END IF;
		RETURN FALSE;
	END IF;
	gv_level := gv_level + 1;
/*
	 save RULE
*/
	v_rule := p_rule;
/*
	 save index
*/
	v_item := p_item;
/*
	 select all descriptions where the first description item = return type
*/
	FOR rule_descriptions IN (
		SELECT	RUD.sequence_number,
			s_turin_function,
			rule_description,
			description
		FROM	IGS_RU_DESCRIPTION	RUD,
			IGS_RU_GROUP_SET		RGS
		WHERE	s_return_type = p_type
		AND	rule_description LIKE '#'||p_type||'%'
		AND	RUD.sequence_number = RGS.rud_sequence_number
		AND	RGS.rug_sequence_number = p_group
		ORDER BY rule_description DESC )
	LOOP
		v_rule_description := rule_descriptions.rule_description;
		v_first_action := TRUE;
		WHILE breakdown_desc(v_string,v_action,v_rule_description)
		LOOP
			IF v_string IS NOT NULL
			THEN
/*
				 string [action]
*/
				IF match_string_to_rule(v_string,p_rule)
				THEN
					IF v_action IS NOT NULL
					THEN
						IF parse_rule(v_action,p_rule,p_rule_number,p_item)
						THEN
							IF v_rule_description IS NULL
							THEN
								gv_level := gv_level - 1;
								RETURN TRUE;
							END IF;
						ELSE
							gv_level := gv_level - 1;
							RETURN FALSE;
						END IF;
					ELSE
/*
						 no more description
*/
						gv_level := gv_level - 1;
						RETURN TRUE;
					END IF;
				ELSE
					make_LOV(p_rule,v_string,
						rule_descriptions.description,'Y');
					EXIT;  /* while, next description */
				END IF;
			ELSIF v_action IS NOT NULL
			THEN
/*
				 first and subsequent action
				 or,and,divide,sutract,plus,mult #ALLOWED_TYPE
*/
				make_rule_item('9',p_rule_number,p_item,
					rule_descriptions.s_turin_function,
					rule_descriptions.sequence_number,
					NULL,NULL,NULL);
				IF v_first_action
				THEN
/*
					 #THIS_TYPE etc
*/
					IF parse_rule2(v_action,p_rule,p_rule_number,p_item)
					THEN
						IF v_rule_description IS NULL
						THEN
							gv_level := gv_level - 1;
							RETURN TRUE;
						END IF;
					ELSE
						gv_level := gv_level - 1;
						RETURN FALSE;
					END IF;
				ELSE
					IF parse_rule(v_action,p_rule,p_rule_number,p_item)
					THEN
						IF v_rule_description IS NULL
						THEN
							gv_level := gv_level - 1;
							RETURN TRUE;
						END IF;
					ELSE
						gv_level := gv_level - 1;
						RETURN FALSE;
					END IF;
				END IF;
			END IF;
			v_first_action := FALSE;

  END LOOP;
/*
		 restore RULE for next option
*/
		p_rule := v_rule;
/*
		 restore index for next option
*/
		p_item := v_item;
	END LOOP;
/*
	 no success therefor try rest of TYPE
*/
	v_return := parse_rule2(p_type,p_rule,p_rule_number,p_item);
	gv_level := gv_level - 1;
	RETURN v_return;
END;
END parse_rule;
/*
Preserve spaces of user defined codes
*/
/* This following function has been added by nshee on 24-JUL-2002 as part of fix for bug:2395891
Changes are:
        v_unit := UPPER(REPLACE(v_unit,cst_spacemod,' '));added this line by nshee as fix for bug 2395891 to insert back the space at the right places to validate with the DB record.
       WHERE	unit_set_cd LIKE UPPER(SUBSTR(p_rule,1,v_ii - 1)); commented by nshee as part of fix of bug 2381638 and 2395891 and added the next line  to validate the DB record correctly.
       WHERE	unit_set_cd LIKE UPPER(SUBSTR(REPLACE(p_rule,cst_spacemod,' '),1,v_ii - 1));
      Earlier,  In case the user defined program code or the milestone type has an internal space in the code
      itself, it was removing the same too. However, the parsing was succesful since the spaces are removed from the
      database record too before the parsing. However, the record was not getting back the spaces later and hence the problem was happening.

     The string manipulation done in the function is a little complex in logic. There is a chance that the logic doesn't cater to all complexities that might arise later,
     it is best suggested that the user defined setup codes should not have any internal space whatsoever.
     In case, one needs to revert it back to the earlier state, here is what you need to do.
     1) remove the following line in the procedure unit insert_set_member.
        v_unit := UPPER(REPLACE(v_unit,cst_spacemod,' '));added this line by nshee as fix for bug 2395891 to insert back the space at the right places to validate with the DB record.
     2) Remove the call to this function below and comment out NOCOPY the entire Function of pres_space begin to end.
     3) remove all declarations of cst_spacemod within this package along with the following variables in the declaration section
     4) Uncomment the line added in FUNCTION consume_us_code and remove the line added
     5) Compile the package in the DB again...enjoy.
*/
FUNCTION pres_space (v_str IN VARCHAR2) RETURN VARCHAR2 AS
  v_out_str VARCHAR2(2000);
  v_desired_str VARCHAR2(2000);
  TYPE rec_pos IS RECORD (start_pos NUMBER, end_pos NUMBER);
  TYPE tab_str IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;
  TYPE tab_pos IS TABLE OF rec_pos INDEX BY BINARY_INTEGER;
  v_tab_str   tab_str;
  ctr BINARY_INTEGER := 1;
  v_tab_str_f tab_str;
  ctr_f BINARY_INTEGER := 1;
  v_tab_pos tab_pos;
  ctr_pos BINARY_INTEGER := 1;
  v_tab_pos_f tab_pos;
  ctr_pos_f BINARY_INTEGER := 1;
  v_curly NUMBER:=0;
  v_start_pos NUMBER;
  v_end_pos NUMBER;
  v_out_str1 VARCHAR2(4000);
  v_start BOOLEAN DEFAULT FALSE;

  PROCEDURE putarray (p_chr VARCHAR2, p_curly NUMBER) IS
  BEGIN
     IF p_curly >= 1 AND p_chr = ' '  THEN
       v_tab_str(ctr) := cst_spacemod;
       ctr := ctr +1;
     ELSE
       v_tab_str(ctr) := p_chr;
       ctr := ctr +1;
     END IF;
  END putarray;

BEGIN
FOR i IN 1..LENGTH(v_str) LOOP
    IF substr(v_str,i,1) = '{' THEN
       v_curly := v_curly + 1;
    ELSIF substr(v_str,i,1) = '}' AND v_curly >= 1 THEN
       v_curly := v_curly - 1;
    END IF;
    putarray (substr(v_str,i,1),v_curly);
END LOOP;
-- print the v_tab_str
FOR i IN v_tab_str.FIRST..v_tab_str.LAST LOOP
   v_out_str := v_out_str || v_tab_str(i);
END LOOP;
IF instr(v_out_str,cst_spacemod) = 0 THEN
    v_desired_str := v_out_str;
    RETURN v_desired_str;
END IF;
FOR i IN v_tab_str.FIRST..v_tab_str.LAST LOOP
    IF v_tab_str(i) = cst_spacemod THEN
  v_tab_str_f (ctr_f) := IGS_GE_NUMBER.TO_CANN(i);
  ctr_f := ctr_f+1;
    END IF;
END LOOP;
FOR i IN v_tab_str_f.FIRST..v_tab_str_f.LAST LOOP
   v_out_str1 := v_out_str1 || v_tab_str_f(i);
END LOOP;
FOR i IN v_tab_str_f.FIRST..v_tab_str_f.LAST LOOP
    IF v_tab_str(IGS_GE_NUMBER.TO_NUM(v_tab_str_f(i))-1) = '{' OR
    v_tab_str(IGS_GE_NUMBER.TO_NUM(v_tab_str_f(i))-1) NOT IN (cst_spacemod) THEN
       v_start_pos := IGS_GE_NUMBER.TO_NUM(v_tab_str_f(i));
    END IF;
    IF v_tab_str(IGS_GE_NUMBER.TO_NUM(v_tab_str_f(i))+1) NOT IN (cst_spacemod) THEN
       v_end_pos := IGS_GE_NUMBER.TO_NUM(v_tab_str_f(i));
    END IF;
    IF v_start_pos IS NOT NULL OR v_end_pos is NOT NULL THEN
       IF v_start_pos IS NOT NULL THEN
          v_tab_pos(ctr_pos).start_pos := v_start_pos;
          v_start := TRUE;
       END IF;
       IF v_end_pos IS NOT NULL AND v_start THEN
          v_tab_pos(ctr_pos).end_pos := v_end_pos;
          v_start := FALSE;
       END IF;
       IF v_tab_pos(ctr_pos).end_pos IS NOT NULL AND
          v_tab_pos(ctr_pos).start_pos IS NOT NULL THEN
          ctr_pos := ctr_pos +1;
       END IF;
    END IF;
    v_start_pos := NULL;
    v_end_pos := NULL;
END LOOP;
-- filter out NOCOPY unwanted rows from v_tab_pos
FOR i IN v_tab_pos.FIRST..v_tab_pos.LAST LOOP
    IF (v_tab_str(IGS_GE_NUMBER.TO_NUM(v_tab_pos(i).start_pos) - 1) = '{' OR
         v_tab_str(IGS_GE_NUMBER.TO_NUM(v_tab_pos(i).end_pos) +1) = '}') OR
        (v_tab_str(IGS_GE_NUMBER.TO_NUM(v_tab_pos(i).start_pos) - 1) = ',' OR
        v_tab_str(IGS_GE_NUMBER.TO_NUM(v_tab_pos(i).end_pos) +1) = ',')THEN
        v_tab_pos_f(ctr_pos_f).start_pos := v_tab_pos(i).start_pos;
        v_tab_pos_f(ctr_pos_f).end_pos := v_tab_pos(i).end_pos;
        ctr_pos_f := ctr_pos_f + 1;
    END IF;
END LOOP;
  v_desired_str := v_out_str;
-- now loop the tab v_tab_pos_f to get the desired output
IF v_tab_pos_f.COUNT = 0 THEN
  RETURN v_desired_str;
END IF;
FOR i IN v_tab_pos_f.FIRST..v_tab_pos_f.LAST LOOP
    v_desired_str := substr(v_desired_str,1,v_tab_pos_f(i).start_pos-1)||rpad(' ',(v_tab_pos_f(i).end_pos-v_tab_pos_f(i).start_pos)+1)||substr(v_desired_str,v_tab_pos_f(i).end_pos+1);
END LOOP;
RETURN v_desired_str;
END pres_space;
/*
 rulp_ins_parser
*/
BEGIN DECLARE
	v_input_rule	VARCHAR2(2000);
	v_rule		VARCHAR2(2000);
	v_return	BOOLEAN;
	v_item		NUMBER;
	v_rule_length	NUMBER;
	v_loop_count	NUMBER := 1;
CURSOR C_RNR IS
	SELECT ROWID, rnr.*
	FROM   IGS_RU_NAMED_RULE rnr
	WHERE	rul_sequence_number = p_rule_number;

BEGIN
	v_input_rule := p_rule_processed||p_rule_unprocessed;
	gv_params := set_params(p_rule_description);
	IF p_generate_rule = TRUE
	THEN
/*
		 new RULE uses index
*/
		gv_rn_index := 0;
		gv_sn_index := 0;
		IF p_rule_number IS NULL
		THEN
			p_rule_number := new_rule;
		END IF;
	END IF;
/*
	 loop until more than 1 item to select
*/
	LOOP
		IF p_generate_rule = TRUE
		THEN
			gv_rn_index := 0;
			gv_sn_index := 0;
			delete_rule_items(p_rule_number,0);
		END IF;
/*
		 initialise for parser
*/
		gv_level := -1;
		gv_min_rule := 2000;
		gv_LOV_index := 0;
		v_item := 1;
/*
		 replace all real spaces with internal spaces
*/
--		v_rule := REPLACE(v_input_rule,' ',cst_space);
/* Start of the call to the function pres_space for bug 2395891 by nshee*/
IF v_input_rule IS NULL THEN
  v_rule := REPLACE(v_input_rule,' ',cst_space);
ELSE
    v_rule:= REPLACE(pres_space(v_input_rule),' ',cst_space);
END IF;
/* End of the call to the function pres_space for bug 2395891 by nshee*/
		v_return := parse_rule(p_return_type,v_rule,p_rule_number,v_item);
		IF v_return = TRUE
		THEN
			make_LOV(v_rule,'*** Parse Successful ***',
				'The rule has been successfully completed.','N');
		END IF;
/*
		 limit the number of parses for safety
*/
		v_loop_count := v_loop_count + 1;
		IF v_loop_count > 8
		THEN
			EXIT;
		END IF;
/*
		 build select from list
*/
		insert_LOV_tab;
/*
		 on more than one item EXIT
*/
		IF LOV_item IS NULL
		THEN
			EXIT;
		END IF;
/*
		 on error, left over RULE
*/
		IF gv_min_rule <> 0
		THEN
			EXIT;
		END IF;
/*
		 append the single item to RULE
*/
		v_input_rule := v_input_rule||' '||LOV_item;
	END LOOP;
/*
	 separate processed and unprocessed portions of RULE
*/
	v_rule_length := LENGTH(v_input_rule);
	p_rule_processed := SUBSTR(v_input_rule,1,v_rule_length - gv_min_rule);
	p_rule_unprocessed := SUBSTR(v_input_rule,v_rule_length - gv_min_rule
					+ 1 /* + gv_select_count */);
/*
	 display_LOV;
*/
	IF p_generate_rule = TRUE
	THEN
/*
		 update RULE text if it exists
*/
		v_rule := IGS_RU_GEN_006.rulp_get_rule(p_rule_number);

		FOR C_RNR_REC IN C_RNR LOOP
		    IGS_RU_NAMED_RULE_PKG.UPDATE_ROW (
			X_ROWID 			=> C_RNR_REC.ROWID,
			X_RUL_SEQUENCE_NUMBER   => C_RNR_REC.RUL_SEQUENCE_NUMBER,
			X_RUD_SEQUENCE_NUMBER   => C_RNR_REC.RUD_SEQUENCE_NUMBER,
			X_MESSAGE_RULE          => C_RNR_REC.MESSAGE_RULE,
			X_RUG_SEQUENCE_NUMBER   => C_RNR_REC.RUG_SEQUENCE_NUMBER,
			X_RULE_TEXT             => v_rule  );
 		END LOOP;

	END IF;
	RETURN v_return;
END;
END rulp_ins_parser;

END IGS_RU_GEN_002;

/
