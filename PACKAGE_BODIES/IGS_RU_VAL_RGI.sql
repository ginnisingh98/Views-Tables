--------------------------------------------------------
--  DDL for Package Body IGS_RU_VAL_RGI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RU_VAL_RGI" AS
/* $Header: IGSRU07B.pls 120.1 2005/09/16 06:17:58 appldev ship $ */

  gv_rug_sequence_number NUMBER(6,0);
  gv_description_number NUMBER(6,0);
  gv_description_type VARCHAR2(10);

/*
  Populate IGS_RU_GROUP_SET from IGS_RU_GROUP_ITEM
*/
  PROCEDURE rulp_ins_rgi
  IS
	v_rowid_gs1 VARCHAR2(25);
	v_rowid_gs2 VARCHAR2(25);

	CURSOR Cur_Gs_Del(r_rug_sequence_number gv_rug_sequence_number%TYPE) IS
		SELECT rowid
		FROM IGS_RU_GROUP_SET
		WHERE rug_sequence_number = r_rug_sequence_number
		FOR UPDATE;

	CURSOR Cur_Gi(r_rug_sequence_number gv_rug_sequence_number%TYPE) IS
		SELECT rug_sequence_number, description_number
		FROM IGS_RU_GROUP_ITEM
		WHERE rug_sequence_number = r_rug_sequence_number
			AND description_type = 'RUD';

/*
  for the marked group
  insert into IGS_RU_GROUP_SET all RUD's and expanded RUG's
  cause parent groups to be expanded
  NOTE this will cascade to all IGS_RU_RULE group ancestors
*/
  BEGIN

/*
delete all members of IGS_RU_GROUP_SET
*/

	for Gs_rec in Cur_Gs_Del(gv_rug_sequence_number) loop
		IGS_RU_GROUP_SET_PKG.DELETE_ROW(
		X_ROWID => Gs_rec.rowid);
	end loop;
/*
 insert all items of type 'RUD'
*/

	for Gi_rec in Cur_Gi(gv_rug_sequence_number) loop
		IGS_RU_GROUP_SET_PKG.Insert_Row(
			x_rowid => v_rowid_gs1,
			x_rug_sequence_number => Gi_rec.rug_sequence_number,
			x_rud_sequence_number => Gi_rec.description_number,
			x_mode => 'R'
			);
	end loop;

/*
 get all items of type 'RUG'
*/
  	FOR rgi IN (
  		SELECT	description_number
  		FROM	IGS_RU_GROUP_ITEM
  		WHERE	rug_sequence_number = gv_rug_sequence_number
  		AND	description_type = 'RUG' )
  	LOOP
/*
  		 insert all members of this group
*/
  		FOR rgs IN (
  			SELECT	rud_sequence_number
  			FROM	IGS_RU_GROUP_SET
  			WHERE	rug_sequence_number = rgi.description_number )
  		LOOP
  		BEGIN
			IGS_RU_GROUP_SET_PKG.Insert_Row(
				x_rowid => v_rowid_gs2,
				x_rug_sequence_number => gv_rug_sequence_number,
				x_rud_sequence_number => rgs.rud_sequence_number,
				x_mode => 'R'
				);

  			EXCEPTION
  				WHEN DUP_VAL_ON_INDEX THEN
  					NULL;
  		END;
  		END LOOP;
  	END LOOP;



/*
 force trigger on groups containing the current updated group
*/
  		FOR rgi IN (
  		SELECT	ROWID, srgi.*
  		FROM	IGS_RU_GROUP_ITEM srgi
  		WHERE	description_number = gv_rug_sequence_number
  		AND	description_type = 'RUG' )
  	LOOP
/*
  		 IGS_GE_NOTE: gv_rug_sequence_number is volatile, changed by this update
  		 update these records one at a time
*/

		IGS_RU_GROUP_ITEM_PKG.UPDATE_ROW (
		X_ROWID => RGI.ROWID,
		X_RUG_SEQUENCE_NUMBER => RGI.RUG_SEQUENCE_NUMBER,
		X_DESCRIPTION_NUMBER  => RGI.DESCRIPTION_NUMBER,
		X_DESCRIPTION_TYPE    => RGI.DESCRIPTION_TYPE );

  	END LOOP;
  END rulp_ins_rgi;


/*
   To set gv_group_number
*/
  PROCEDURE rulp_set_rgi(
  P_RUG_SEQUENCE_NUMBER  NUMBER ,
  P_DESCRIPTION_NUMBER  NUMBER ,
  P_DESCRIPTION_TYPE  VARCHAR2 )
  IS
  BEGIN
  	gv_rug_sequence_number := p_rug_sequence_number;
  	gv_description_number := p_description_number;
  	gv_description_type := p_description_type;
  END rulp_set_rgi;
/*
   To verify if the insert group can be inserted into the current group.
*/
  FUNCTION rulp_val_grp_rgi
  RETURN BOOLEAN IS
/*
   validate if the insert group can be inserted into the current group
     can not insert self
     can not insert ancestor
*/
  FUNCTION validate_insert_group (
  	p_current_group	NUMBER,
  	p_insert_group	NUMBER,
  	p_description_type	VARCHAR2 )
  RETURN BOOLEAN IS
  BEGIN
  	IF p_description_type = 'RUD'
  	THEN
  		RETURN TRUE;
  	END IF;
  	IF p_current_group = p_insert_group
  	THEN
/*
  		 can not insert self
*/
  		RETURN FALSE;
  	END IF;
/*
  	 for all parent groups of current group
*/
  	FOR parent IN (
  		SELECT	rug_sequence_number
  		FROM	IGS_RU_GROUP_ITEM
  		WHERE	description_number = p_current_group
  		AND	description_type = 'RUG' )
  	LOOP
/*
  		 try ancestor
*/
  		IF validate_insert_group(parent.rug_sequence_number,
  				p_insert_group,
  				'RUG') = FALSE
  		THEN
/*
  			 can not insert ancestor
*/
  			RETURN FALSE;
  		END IF;
  	END LOOP;
/*
  	 not false therefore true
*/
  	RETURN TRUE;
  END validate_insert_group;
/*
   rulp_val_grp_rgi
*/
  BEGIN
  	RETURN validate_insert_group(gv_rug_sequence_number,
  				gv_description_number,
  				gv_description_type);
  END rulp_val_grp_rgi;

END IGS_RU_VAL_RGI;

/
