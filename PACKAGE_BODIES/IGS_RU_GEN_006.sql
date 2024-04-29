--------------------------------------------------------
--  DDL for Package Body IGS_RU_GEN_006
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RU_GEN_006" AS
/* $Header: IGSRU12B.pls 115.4 2003/10/14 11:05:25 nsinha noship $ */

FUNCTION Rulp_Val_Desc_Rgi(
  p_description_number IN NUMBER ,
  p_description_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN VARCHAR2 IS
  ------------------------------------------------------------------
  --Created by  : nsinha, Oracle India
  --Date created: 12-Mar-2002
  --
  --Purpose: Expand description_number to IGS_RU_DESCRIPTION or group_name
  --         if invalid set message number and return NULL
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --nsinha      12-Mar-2002     Bug# 2233951: Moved the function from Igs_ru_gen_004.
  --
  -------------------------------------------------------------------
	v_description	igs_ru_description.rule_description%TYPE;
BEGIN
	IF p_description_type = 'RUD'
	THEN
	BEGIN
		SELECT	rule_description
		INTO	v_description
		FROM	IGS_RU_DESCRIPTION
		WHERE	sequence_number = p_description_number;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				p_message_name := 'IGS_GE_RULE_DESCR_NOT_EXISTS';
				RETURN NULL;
	END;
	ELSIF p_description_type = 'RUG'
	THEN
	BEGIN
		SELECT	group_name
		INTO	v_description
		FROM	IGS_RU_GROUP
		WHERE	sequence_number = p_description_number;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				p_message_name := 'IGS_GE_RULE_GROUP_NOT_EXISTS';
				RETURN NULL;
	END;
	ELSE
          /*
	    invalid type
          */
	  p_message_name := 'IGS_GE_INVALID_VALUE';
	  RETURN NULL;
	END IF;
	RETURN v_description;
END Rulp_Val_Desc_Rgi;

PROCEDURE Rulp_Ins_Make_Rule(
  p_description_number IN NUMBER ,
  p_return_type  VARCHAR2 ,
  p_rule_description  VARCHAR2 ,
  p_turing_function  VARCHAR2 ,
  p_rule_text  VARCHAR2 ,
  p_message_rule_text  VARCHAR2 ,
  p_description_text  VARCHAR2 ,
  p_group IN NUMBER ,
  p_select_group IN NUMBER )
IS
  ------------------------------------------------------------------
  --Created by  : nsinha, Oracle India
  --Date created: 12-Mar-2002
  --
  --Purpose: If description number exists then use the existing IGS_RU_RULE
  --         number or message number
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --nsinha      12-Mar-2002     Bug# 2233951: Moved the function from Igs_ru_gen_004.
  --
  -------------------------------------------------------------------
FUNCTION make_rule (
	p_rule_number		NUMBER,
	p_return_type		VARCHAR2,
	p_rule_description	VARCHAR2,
	p_rule_text		VARCHAR2 )
RETURN NUMBER IS
	v_processed	VARCHAR(2000);
	v_unprocessed	VARCHAR(2000);
	v_rule_number	NUMBER;
	v_lov_number	NUMBER;
	v_count		NUMBER;
BEGIN
	v_rule_number := p_rule_number;
	v_processed := p_rule_text;
	IF IGS_RU_GEN_002.RULP_INS_PARSER(p_select_group,
		p_return_type,
		p_rule_description,
		v_processed,
		v_unprocessed,
		TRUE,
		v_rule_number,
		v_lov_number)
	THEN
		NULL;
	END IF;
	RETURN v_rule_number;
END make_rule;

/*
 insert/update IGS_RU_DESCRIPTION
*/
FUNCTION insert_rule_description
RETURN NUMBER IS
  ------------------------------------------------------------------
  --Created by  : nsinha, Oracle India
  --Date created: 12-Mar-2002
  --
  --Purpose: Calls the before_dml of igs_ru_group_item_pkg
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
  -- nsinha      10/9/2003      Bug#: 3193855 : Change the reference of igs_ru_set with igs_ru_description.
  --				for CURSOR cur_max_plus_one.
  -------------------------------------------------------------------
	v_rud_sequence_number	NUMBER;
	v_count			NUMBER DEFAULT 0;
	v_rowid 		VARCHAR2(25);
	CURSOR Cur_Desc(r_rud_sequence_number NUMBER) IS
		SELECT rowid,IGS_RU_DESCRIPTION.*
		FROM IGS_RU_DESCRIPTION
		WHERE sequence_number = r_rud_sequence_number;

	CURSOR Cur_Desc_Count(cp_rud_sequence_number NUMBER) IS
 	  SELECT	COUNT(*)
	  FROM	IGS_RU_DESCRIPTION
	  WHERE	sequence_number = cp_rud_sequence_number;

        CURSOR cur_max_plus_one IS
          SELECT   (sequence_number + 1) sequence_number
          FROM     igs_ru_description
          WHERE    sequence_number =
            (SELECT   MAX (sequence_number)
             FROM     igs_ru_description	-- Changed By: Navin.Sinha On: 10/9/2003 Fix: Change the reference of igs_ru_set with igs_ru_description.
             WHERE    sequence_number < 499999)
          FOR UPDATE OF sequence_number NOWAIT;
BEGIN
	IF p_description_number IS NULL	THEN
          --
	  --  New description number
          --  If the User creating this record is DATAMERGE (id = 1) then
          --    Get the sequence as the existing maximum value + 1
          --  Else
          --    Get the next value from the database sequence
          --
          IF (fnd_global.user_id = 1) THEN
            OPEN  cur_max_plus_one;
            FETCH cur_max_plus_one INTO v_rud_sequence_number;
            CLOSE cur_max_plus_one;
          ELSE
            SELECT igs_ru_description_seq_num_s.nextval
            INTO   v_rud_sequence_number
            FROM   dual;
          END IF;
	ELSE
		v_rud_sequence_number := p_description_number;
	END IF;

	OPEN  Cur_Desc_Count(v_rud_sequence_number);
	FETCH Cur_Desc_Count INTO v_count;
	CLOSE Cur_Desc_Count;

	IF v_count = 0
	THEN
              --
	      -- insert IGS_RU_DESCRIPTION
              --
		IGS_RU_DESCRIPTION_PKG.Insert_Row(
			x_rowid => v_rowid,
			x_sequence_number => v_rud_sequence_number,
			x_s_return_type => p_return_type,
			x_rule_description => p_rule_description,
			x_description => p_description_text,
			x_s_turin_function => NULL,
			x_parenthesis_ind => NULL,
			x_mode => 'R'
			);
	ELSE
          --
	  --	 update IGS_RU_DESCRIPTION
          --
		for Desc_Rec in Cur_Desc(v_rud_sequence_number) loop
			Desc_Rec.s_return_type := p_return_type;
			Desc_Rec.rule_description := p_rule_description;
			Desc_Rec.description := p_description_text;
			IGS_RU_DESCRIPTION_PKG.Update_Row(
				x_rowid => Desc_Rec.rowid,
				x_sequence_number => Desc_Rec.sequence_number,
				x_s_return_type => Desc_Rec.s_return_type,
				x_rule_description => Desc_Rec.rule_description,
				x_description => Desc_Rec.description,
				x_s_turin_function => Desc_Rec.s_turin_function,
				x_parenthesis_ind => Desc_Rec.parenthesis_ind,
				x_mode => 'R'
				);
		end loop;

	END IF;
	RETURN v_rud_sequence_number;
END insert_rule_description;

BEGIN DECLARE
	v_rowid_nr			VARCHAR2(25);
	v_rowid_tur			VARCHAR2(25);
	v_rowid_rgi			VARCHAR2(25);
	v_rule_number		NUMBER;
	v_description_number	NUMBER;
	v_count			NUMBER;
	v_rule_description	IGS_RU_DESCRIPTION.rule_description%TYPE;

	CURSOR Cur_Desc(r_description_number NUMBER) IS
		SELECT rowid,IGS_RU_DESCRIPTION.*
		FROM IGS_RU_DESCRIPTION
		WHERE sequence_number = r_description_number;
	CURSOR Cur_Nr(r_description_number NUMBER) IS
		SELECT rowid,IGS_RU_NAMED_RULE.*
		FROM IGS_RU_NAMED_RULE
		WHERE rud_sequence_number = r_description_number;

BEGIN
	IF p_return_type IS NOT NULL AND
	   p_rule_description IS NOT NULL
	THEN
		v_description_number := insert_rule_description;
		IF p_turing_function IS NOT NULL
		THEN
			SELECT	COUNT(*)
			INTO	v_count
			FROM	IGS_RU_TURIN_FNC
			WHERE	s_turin_function = p_turing_function;
			IF v_count = 0
			THEN
                   /*
				 master turing function
                   */

				IGS_RU_TURIN_FNC_PKG.Insert_Row(
					x_rowid => v_rowid_tur,
					x_s_turin_function => p_turing_function,
					x_rud_sequence_number => v_description_number,
					x_parenthesis_ind => NULL,
					x_mode => 'R'
					);
			END IF;

			for Desc_Rec in Cur_Desc(v_description_number) loop
				Desc_Rec.s_turin_function := p_turing_function;
				IGS_RU_DESCRIPTION_PKG.Update_Row(
					x_rowid => Desc_Rec.rowid,
					x_sequence_number => Desc_Rec.sequence_number,
					x_s_return_type => Desc_Rec.s_return_type,
					x_rule_description => Desc_Rec.rule_description,
					x_description => Desc_Rec.description,
					x_s_turin_function => Desc_Rec.s_turin_function,
					x_parenthesis_ind => Desc_Rec.parenthesis_ind,
					x_mode => 'R'
					);
			end loop;

		ELSE
			IF p_rule_text IS NOT NULL
			THEN
                            /*
				 NAMED IGS_RU_RULE
                            */
				IF p_description_number IS NOT NULL
				THEN
				BEGIN
                            /*
					 find existing IGS_RU_RULE number
                            */
					SELECT	rul_sequence_number
					INTO	v_rule_number
					FROM	IGS_RU_NAMED_RULE
					WHERE	rud_sequence_number = p_description_number;
					EXCEPTION
						WHEN NO_DATA_FOUND THEN
							v_rule_number := NULL;
				END;
				END IF;
				v_rule_number := make_rule(v_rule_number,
							p_return_type,
							p_rule_description,
							p_rule_text);
				SELECT	COUNT(*)
				INTO	v_count
				FROM	IGS_RU_NAMED_RULE
				WHERE	rud_sequence_number = v_description_number;
				IF v_count = 0
				THEN
                                  /*
					 add named IGS_RU_RULE
                                  */
					IGS_RU_NAMED_RULE_PKG.Insert_Row(
						x_rowid => v_rowid_nr,
						x_rul_sequence_number => v_rule_number,
						x_rud_sequence_number => v_description_number,
						x_message_rule => NULL,
						x_rug_sequence_number => 1,
						x_rule_text => p_rule_text,
						x_mode => 'R'
						);

				END IF;
			ELSE
                               /*
				 TURING LOV or language directive
                               */
				NULL;
			END IF;
		END IF;
		IF p_group IS NOT NULL
		THEN
                        /*
			 check/insert into group
                        */
			SELECT	COUNT(*)
			INTO	v_count
			FROM	IGS_RU_GROUP_ITEM
			WHERE	rug_sequence_number = p_group
			AND	description_number = v_description_number
			AND	description_type = 'RUD';
			IF v_count = 0
			THEN
			IGS_RU_GROUP_ITEM_PKG.Insert_Row(
				x_rowid => v_rowid_rgi,
				x_rug_sequence_number => p_group,
				x_description_number => v_description_number,
				x_description_type => 'RUD',
				x_mode => 'R'
				);
			END IF;
		END IF;
	ELSE
		NULL; /*error*/
	END IF;
	IF p_message_rule_text IS NOT NULL
	THEN
          /*
		MESSAIGS_RU_RULE
		find existing message IGS_RU_RULE number
          */
		SELECT	message_rule
		INTO	v_rule_number
		FROM	IGS_RU_NAMED_RULE
		WHERE	rud_sequence_number = p_description_number;
          /*
            get the IGS_RU_RULE description of the owner IGS_RU_RULE
          */
		SELECT	rule_description
		INTO	v_rule_description
		FROM	IGS_RU_DESCRIPTION
		WHERE	sequence_number = p_description_number;
		v_rule_number := make_rule(v_rule_number,
					'STRING',
					v_rule_description,
					p_message_rule_text);
          /*
		date the message number
          */
		for Nr_Rec in Cur_Nr(p_description_number) loop
			Nr_Rec.message_rule := v_rule_number;
			IGS_RU_NAMED_RULE_PKG.Update_Row(
				x_rowid => Nr_Rec.rowid,
				x_rul_sequence_number => Nr_Rec.rul_sequence_number,
				x_rud_sequence_number => Nr_Rec.rud_sequence_number,
				x_message_rule => Nr_Rec.message_rule,
				x_rug_sequence_number => Nr_Rec.rug_sequence_number,
				x_rule_text => Nr_Rec.rule_text,
				x_mode => 'R'
				);
		end loop;
	END IF;
END;
END Rulp_Ins_Make_Rule;


FUNCTION Rulp_Get_Rule(
  p_rule_number IN NUMBER )
RETURN VARCHAR2 IS
/*
 return the textual form of the IGS_RU_RULE

 CONSTANTS
*/
cst_space	CONSTANT VARCHAR2(1) := Fnd_Global.Local_Chr(31);
/*
 return set string
*/
FUNCTION show_set (
	p_set_number	IN IGS_RU_SET.sequence_number%TYPE )
RETURN VARCHAR2 IS
BEGIN DECLARE
	v_more		BOOLEAN;
	v_set		VARCHAR2(255);
BEGIN
	v_more := FALSE;
	v_set := '{';
  	FOR set_members IN (
  		SELECT	unit_cd,
  			versions
  		FROM	IGS_RU_SET_MEMBER
  		WHERE	rs_sequence_number = p_set_number
		ORDER BY unit_cd )
  	LOOP
		IF v_more
		THEN
			v_set := v_set||', ';
		END IF;
		v_set := v_set||set_members.unit_cd;
		IF set_members.versions IS NOT NULL
		THEN
			IF INSTR(set_members.versions,',') <> 0 OR
			   INSTR(set_members.versions,'-') <> 0
			THEN
				v_set := v_set||'.['||set_members.versions||']';
			ELSE
				v_set := v_set||'.'||set_members.versions;
			END IF;
		END IF;
		v_more := TRUE;
	END LOOP;
	v_set := v_set||'}';
	RETURN v_set;
END;
END show_set;

/*
 convert the description string into token, action
 and remainder of description
 return FALSE if description is NULL
*/
FUNCTION breakdown_desc (
	p_display	IN OUT NOCOPY IGS_RU_DESCRIPTION.rule_description%TYPE,
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
	p_display := SUBSTR(p_description,1,v_hash - 1);
	IF v_hash = 0
	THEN
		p_action := '';
		p_display := p_description;
	ELSE
		FOR return_types IN (
			SELECT s_return_type
			FROM	IGS_RU_RET_TYPE
			ORDER BY s_return_type DESC )
		LOOP
			IF SUBSTR(p_description,v_hash + 1,LENGTH(return_types.s_return_type))
				= return_types.s_return_type
			THEN
				p_action := return_types.s_return_type;
				exit;
			END IF;
		END LOOP;

	END IF;
	p_description := SUBSTR(p_description,v_hash + 1 + LENGTH(p_action));
	RETURN TRUE;
END;
END breakdown_desc;
/*
 Convert the stored IGS_RU_RULE into a readable form
*/
FUNCTION display_rule (
	p_rule_number	IN IGS_RU_ITEM.rul_sequence_number%TYPE,
	p_rule_item	IN OUT NOCOPY IGS_RU_ITEM.item%TYPE )
RETURN VARCHAR2 IS
BEGIN DECLARE
	v_rule			VARCHAR2(2000);
	v_rule_item		IGS_RU_ITEM.item%TYPE;
	v_rule_description	IGS_RU_DESCRIPTION.rule_description%TYPE;
	v_parenthesis_ind	IGS_RU_DESCRIPTION.parenthesis_ind%TYPE;
	v_action		IGS_RU_DESCRIPTION.s_return_type%TYPE;
	v_display		IGS_RU_DESCRIPTION.rule_description%TYPE;
BEGIN
	FOR rule_items IN (
		SELECT	rul_sequence_number,
			item,
			turin_function,
			named_rule,
			rule_number,
			derived_rule,
			set_number,
			value
		FROM	IGS_RU_ITEM
		WHERE	rul_sequence_number = p_rule_number
		AND	item > p_rule_item
		ORDER BY item ASC )
	LOOP
		p_rule_item := rule_items.item;
		IF rule_items.turin_function IS NOT NULL
		THEN
			SELECT	rud.rule_description,
				rud.parenthesis_ind
			INTO	v_rule_description,
				v_parenthesis_ind
			FROM	IGS_RU_TURIN_FNC stf,
				IGS_RU_DESCRIPTION rud
			WHERE	stf.s_turin_function = rule_items.turin_function
			AND	rud.sequence_number = stf.rud_sequence_number;
			IF v_parenthesis_ind = 'Y'
			THEN
				v_rule := v_rule||'(';
			END IF;
			WHILE breakdown_desc(v_display,
					v_action,
					v_rule_description)
			LOOP
				v_rule := v_rule||v_display;
				IF LENGTH(v_action) > 0
				THEN
					v_rule := v_rule||display_rule(p_rule_number,p_rule_item);
				END IF;
			END LOOP;
			IF v_parenthesis_ind = 'Y'
			THEN
				v_rule := v_rule||')';
			END IF;
		ELSIF rule_items.named_rule IS NOT NULL
		THEN
			SELECT	rud.rule_description,
				rud.parenthesis_ind
			INTO	v_rule_description,
				v_parenthesis_ind
			FROM	IGS_RU_NAMED_RULE nr,
				IGS_RU_DESCRIPTION rud
			WHERE	nr.rul_sequence_number = rule_items.named_rule
			AND	rud.sequence_number = nr.rud_sequence_number;
			IF v_parenthesis_ind = 'Y'
			THEN
				v_rule := v_rule||'(';
			END IF;
			WHILE breakdown_desc(v_display,
					v_action,
					v_rule_description)
			LOOP
				v_rule := v_rule||v_display;
				IF LENGTH(v_action) > 0
				THEN
					v_rule := v_rule||display_rule(p_rule_number,p_rule_item);
				END IF;
			END LOOP;
			IF v_parenthesis_ind = 'Y'
			THEN
				v_rule := v_rule||')';
			END IF;
		ELSIF rule_items.rule_number IS NOT NULL
		THEN
			v_rule_item := 0;
			v_rule := v_rule||display_rule(rule_items.rule_number,v_rule_item);
		ELSIF rule_items.derived_rule IS NOT NULL
		THEN
			SELECT	rule_description
			INTO	v_rule_description
			FROM	IGS_RU_DESCRIPTION
			WHERE	sequence_number = rule_items.derived_rule;
			WHILE breakdown_desc(v_display,
					v_action,
					v_rule_description)
			LOOP
				v_rule := v_rule||v_display;
				IF LENGTH(v_action) > 0
				THEN
					v_rule := v_rule||display_rule(p_rule_number,p_rule_item);
				END IF;
			END LOOP;
		ELSIF rule_items.set_number IS NOT NULL
		THEN
			v_rule := v_rule||show_set(rule_items.set_number);
		ELSIF rule_items.value IS NOT NULL
		THEN
			v_rule := v_rule||rule_items.value;
		END IF;
		exit;
	END LOOP;
	RETURN v_rule;
END;
END display_rule;
/*
 Rulp_Get_Rule
*/
BEGIN
  DECLARE
	v_rule_item	IGS_RU_ITEM.item%TYPE := -1;
  BEGIN
  /*
    return IGS_RU_RULE, replace internal spaces for real spaces
  */
	RETURN REPLACE(display_rule(p_rule_number,v_rule_item),cst_space,' ');
  END;
END Rulp_Get_Rule;

PROCEDURE Set_Token(Token Varchar2) IS
BEGIN
  FND_MESSAGE.SET_TOKEN('ADM',Token);
END Set_Token;

FUNCTION Jbsp_Get_Dt_Picture(
  p_char_dt IN VARCHAR2 ,
  p_dt_picture OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN AS
BEGIN
DECLARE
	v_return_dt	DATE	:= NULL;
	v_char_dt	VARCHAR2(40);
BEGIN
	-- This function accepts a date string, determines what format
	-- should be used to convert the string to a date and returns
	-- the date picture and true if a valid date picture found.
	v_char_dt := SUBSTR(REPLACE(p_char_dt, '''', ''), 1, 40);
	IF v_char_dt IS NULL THEN
		p_dt_picture := ' ';
		RETURN FALSE;
	END IF;
	v_return_dt := TO_DATE(v_char_dt, 'DD/MM/YY');
	p_dt_picture := 'DD/MM/YY';
	RETURN TRUE;
	EXCEPTION WHEN OTHERS THEN
	BEGIN
		v_return_dt := TO_DATE(v_char_dt, 'DD/MM/YYYY');
		p_dt_picture := 'DD/MM/YYYY';
		RETURN TRUE;
		EXCEPTION WHEN OTHERS THEN
		BEGIN
			v_return_dt := TO_DATE(v_char_dt, 'DD-MM-YY');
			p_dt_picture := 'DD-MM-YY';
			RETURN TRUE;
			EXCEPTION WHEN OTHERS THEN
			BEGIN
				v_return_dt := TO_DATE(v_char_dt, 'DD-MM-YYYY');
				p_dt_picture := 'DD-MM-YYYY';
				RETURN TRUE;
				EXCEPTION WHEN OTHERS THEN
				BEGIN
					v_return_dt := TO_DATE(v_char_dt, 'DD-MM-YY HH24:MI:SS');
					p_dt_picture := 'DD-MM-YY HH24:MI:SS';
					RETURN TRUE;
					EXCEPTION WHEN OTHERS THEN
					BEGIN
						v_return_dt := TO_DATE(v_char_dt, 'DD-MM-YYYY HH24:MI:SS');
						p_dt_picture := 'DD-MM-YYYY HH24:MI:SS';
						RETURN TRUE;
						EXCEPTION WHEN OTHERS THEN
						BEGIN
							v_return_dt := TO_DATE(v_char_dt, 'DD/MM/YY HH24:MI:SS');
							p_dt_picture := 'DD/MM/YY HH24:MI:SS';
							RETURN TRUE;
							EXCEPTION WHEN OTHERS THEN
							BEGIN
								v_return_dt := TO_DATE(v_char_dt, 'DD/MM/YYYY HH24:MI:SS');
								p_dt_picture := 'DD/MM/YYYY HH24:MI:SS';
								RETURN TRUE;
								EXCEPTION WHEN OTHERS THEN
									p_dt_picture := ' ';
									RETURN FALSE;
							END;
						END;
					END;
				END;
			END;
		END;
	END;
END;
END Jbsp_Get_Dt_Picture;

END IGS_RU_GEN_006;

/
