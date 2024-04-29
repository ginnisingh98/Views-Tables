--------------------------------------------------------
--  DDL for Package Body IGS_OR_UNIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_OR_UNIT_PKG" AS
 /* $Header: IGSOI10B.pls 115.6 2003/12/17 08:54:41 pkpatel ship $ */
  /*************************************************************
  Changed By : smanglm
  Date       : 2000/08/25
  Purpose    : to remove the procedures like insert_row, update_row,lock_row,
               before DML, check_parent_existence,check_child_existence,
               check_constraints, set_column_values, after_dml for
               TCA related work as this would now be taken care through TCA
               table handlers.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  pkpatel         26-OCT-2002     Bug 2613704
                                  Removed GET_FK_IGS_OR_MEMBER_TYPE and GET_FK_IGS_OR_MEMBER_TYPE procedures since
								  the tables will be obsolete for lookup migration
  pkpatel         17-DEC-2003     Bug 3319026 (Replaced ROWID with ROW_ID while selecting from the complex view IGS_OR_UNIT)
  (reverse chronological order - newest change first)
  ***************************************************************/

  l_rowid VARCHAR2(25);

  FUNCTION Get_PK_For_Validation (
    x_org_unit_cd IN VARCHAR2,
    x_start_dt IN DATE
    )RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   row_id
      FROM     IGS_OR_UNIT
      WHERE    org_unit_cd = x_org_unit_cd
      AND      start_dt = x_start_dt;

    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;

    IF (cur_rowid%FOUND) THEN
        Close cur_rowid;
 		RETURN(TRUE);
	ELSE
        Close cur_rowid;
	    RETURN(FALSE);
	END IF;

  END Get_PK_For_Validation;

   /****  for validating Structure Id's   *****/

 FUNCTION Get_PK_For_Str_Validation (
        x_org_unit_cd IN VARCHAR2
    )RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   row_id
      FROM     IGS_OR_UNIT
      WHERE    org_unit_cd = x_org_unit_cd;

    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;

    IF (cur_rowid%FOUND) THEN
        Close cur_rowid;
 		RETURN(TRUE);
	ELSE
        Close cur_rowid;
	    RETURN(FALSE);
	END IF;

  END Get_PK_For_Str_Validation;

  PROCEDURE GET_FK_IGS_OR_INSTITUTION (
    x_institution_cd IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   row_id
      FROM     IGS_OR_UNIT
      WHERE    institution_cd = x_institution_cd ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_OR_OU_INS_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_OR_INSTITUTION;

  PROCEDURE GET_FK_IGS_OR_STATUS (
    x_org_status IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   row_id
      FROM     IGS_OR_UNIT
      WHERE    org_status = x_org_status ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_OR_OU_OS_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_OR_STATUS;

END igs_or_unit_pkg ;

/
