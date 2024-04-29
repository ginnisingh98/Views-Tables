--------------------------------------------------------
--  DDL for Package Body IGS_OR_INSTITUTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_OR_INSTITUTION_PKG" AS
 /* $Header: IGSOI02B.pls 115.8 2002/10/28 03:13:46 pkpatel ship $ */
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

  (reverse chronological order - newest change first)
  ***************************************************************/


  l_rowid VARCHAR2(25);

  FUNCTION Get_PK_For_Validation (
    x_institution_cd IN VARCHAR2
    )
  RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   ROW_ID
      FROM     IGS_OR_INSTITUTION
      WHERE    institution_cd = x_institution_cd;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
        CLOSE cur_rowid;
 		RETURN(TRUE);
	ELSE
        CLOSE cur_rowid;
	    RETURN(FALSE);
	END IF;
  END Get_PK_For_Validation;

  PROCEDURE GET_FK_IGS_OR_GOVT_INST_CD (
    x_govt_institution_cd IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
     SELECT   ROW_ID
      FROM     IGS_OR_INSTITUTION
      WHERE    GOVT_INSTITUTION_CD = x_govt_institution_cd ;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_OR_INS_GIC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END GET_FK_IGS_OR_GOVT_INST_CD;

  PROCEDURE GET_FK_IGS_OR_INST_STAT (
    x_institution_status IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   ROW_ID
      FROM     IGS_OR_INSTITUTION
      WHERE    institution_status = x_institution_status ;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_OR_INS_IST_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END GET_FK_IGS_OR_INST_STAT;

  PROCEDURE Get_FK_Igs_Or_Org_Inst_Type (
    x_institution_type IN VARCHAR2
    ) AS

  /*************************************************************
  Created By : sbonam.in
  Date Created By : 2000/05/18
  Purpose : This procedure is called from other tbh's check_child_existence
            to validate against the existence of records in the current table
            which is actually a child of the master table whose name appears
            in Get_Fk_<table_name>
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   ROW_ID
      FROM     igs_or_institution
      WHERE    institution_type = x_institution_type ;

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_OR_INS_OIT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END Get_FK_Igs_Or_Org_Inst_Type;

  PROCEDURE Get_FK_Igs_Or_Org_In_Ctltyp (
    x_inst_control_type IN VARCHAR2
    ) AS

  /*************************************************************
  Created By : sbonam.in
  Date Created By : 2000/05/18
  Purpose : This procedure is called from other tbh's check_child_existence
            to validate against the existence of records in the current table
            which is actually a child of the master table whose name appears
            in Get_Fk_<table_name>
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   ROW_ID
      FROM     igs_or_institution
      WHERE    inst_control_type = x_inst_control_type ;

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_OR_INS_OIC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END Get_FK_Igs_Or_Org_In_Ctltyp;

END Igs_Or_Institution_Pkg;

/
