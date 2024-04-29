--------------------------------------------------------
--  DDL for Package Body IGS_RU_VAL_RUD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RU_VAL_RUD" AS
/* $Header: IGSRU08B.pls 115.6 2002/11/29 03:40:14 nsidana ship $ */

/*
   Routine to clear rowids saved in a PL/SQL TABLE from a prior commit.

   Validate the new IGS_RU_RULE description, compared with old
*/
  FUNCTION RULP_VAL_RUD_DESC(
  p_old_sequence_number IN NUMBER ,
  p_old_return_type IN VARCHAR2 ,
  p_old_rule_description IN VARCHAR2 ,
  p_old_turing_function IN VARCHAR2 ,
  p_new_return_type IN VARCHAR2 ,
  p_new_rule_description IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN boolean IS
/*
   STRUCTURES
*/
  TYPE t_param_list IS TABLE OF
  	IGS_RU_RET_TYPE.s_return_type%TYPE
  INDEX BY BINARY_INTEGER;
/*

   GLOBALS

   list of parameter return types
*/
  gt_param_list	t_param_list;
  gv_params	NUMBER;
/*

   convert the description string into token, action
   string, action, remainder of description
   string, NULL, NULL
   NULL, action, remainder of description

   return FALSE if description is NULL and error

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
  				exit;
  			END IF;
  		END LOOP;
  		IF p_action IS NULL
  		THEN
/*
  			 there must be an action following the #
*/
  			RETURN FALSE;
  		END IF;
  	END IF;
  	p_description := SUBSTR(p_description,v_hash + 1 + LENGTH(p_action));
  	RETURN TRUE;
  END;
  END breakdown_desc;
/*

   validate and save parameter order/type/number of new IGS_RU_RULE description

*/
  FUNCTION validate_desc (
  	p_rule_description	IGS_RU_DESCRIPTION.rule_description%TYPE )
  RETURN BOOLEAN IS
  	v_rule_description	IGS_RU_DESCRIPTION.rule_description%TYPE;
  	v_string		      IGS_RU_DESCRIPTION.rule_description%TYPE;
  	v_action		      IGS_RU_RET_TYPE.s_return_type%TYPE;
  BEGIN
  	gv_params := 0;
  	v_rule_description := p_rule_description;
  	WHILE v_rule_description IS NOT NULL
  	LOOP
  		IF breakdown_desc(v_string,v_action,v_rule_description) = FALSE
  		THEN
  			RETURN FALSE;
  		END IF;
  		IF v_action IS NOT NULL
  		THEN
  			gv_params := gv_params + 1;
  			gt_param_list(gv_params) := v_action;
  		END IF;
  	END LOOP;
  	RETURN TRUE;
  END validate_desc;
/*

   validate parameter order and number (old vs new)

*/
  FUNCTION validate_params (
  	p_rule_description	IGS_RU_DESCRIPTION.rule_description%TYPE,
	p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	v_rule_description	IGS_RU_DESCRIPTION.rule_description%TYPE;
  	v_string		      IGS_RU_DESCRIPTION.rule_description%TYPE;
  	v_action	      	IGS_RU_RET_TYPE.s_return_type%TYPE;
  	v_params	      	NUMBER;
  BEGIN
  	v_params := 0;
  	v_rule_description := p_rule_description;
  	WHILE v_rule_description IS NOT NULL
  	LOOP
  		IF breakdown_desc(v_string,v_action,v_rule_description) = FALSE
  		THEN
/*
  			 invalid old IGS_RU_RULE description (should not occur)
*/
  			p_message_name := 'IGS_GE_INVALID_VALUE';
  			RETURN FALSE;
  		END IF;
  		IF v_action IS NOT NULL
  		THEN
  			v_params := v_params + 1;
  			IF v_params > gv_params
  			THEN
/*
  				 more old parameters
*/
  				p_message_name := 'IGS_GE_INVALID_VALUE';
  				RETURN FALSE;
  			END IF;
  			IF v_action <> gt_param_list(v_params)
  			THEN
/*
  				 different parameter order
*/
  				p_message_name := 'IGS_GE_INVALID_VALUE';
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END LOOP;
  	IF v_params < gv_params
  	THEN
/*
  		 more new parameters
*/
  		p_message_name := 'IGS_GE_INVALID_VALUE';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END validate_params;
/*

   validate new description
   if description in use validate number/type/order of paramters

*/
  BEGIN DECLARE
  	v_turing_count	NUMBER := 0;
  	v_nr_count	NUMBER := 0;
  BEGIN
/*
  	 validate new description
*/
  	IF validate_desc(p_new_rule_description) = FALSE
  	THEN
  		p_message_name := 'IGS_GE_INVALID_VALUE';
  		RETURN FALSE;
  	END IF;
  	IF p_old_return_type IS NOT NULL AND
  	   (p_old_return_type <> p_new_return_type OR
  	    p_old_rule_description <> p_new_rule_description)
  	THEN
/*
  		 UPDATING
*/
  		IF p_old_turing_function IS NOT NULL
  		THEN
  			SELECT	COUNT(*)
  			INTO	v_turing_count
  			FROM	IGS_RU_ITEM
  			WHERE	turin_function = p_old_turing_function;
  		ELSE
  			SELECT	COUNT(*)
  			INTO	v_nr_count
  			FROM	IGS_RU_NAMED_RULE	nr,
  				IGS_RU_ITEM	rui
  			WHERE	nr.rud_sequence_number = p_old_sequence_number
  			AND	rui.named_rule = nr.rul_sequence_number;
  		END IF;
  		IF v_turing_count > 0 OR
  		   v_nr_count > 0
  		THEN
/*
  			 IGS_RU_DESCRIPTION has been used
  			 no change to return type
*/
  			IF p_old_return_type <> p_new_return_type
  			THEN
  				p_message_name := 'IGS_GE_INVALID_VALUE';
  				RETURN FALSE;
  			END IF;
/*
  			 parameter order/number must be same
*/
  			IF validate_params(p_old_rule_description,
  					p_message_name) = FALSE
  			THEN
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;
  END rulp_val_rud_desc;

END IGS_RU_VAL_RUD;

/
