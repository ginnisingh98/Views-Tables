--------------------------------------------------------
--  DDL for Package Body IGS_OR_ADDR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_OR_ADDR_PKG" AS
 /* $Header: IGSOI07B.pls 115.5 2002/02/12 17:08:20 pkm ship    $ */
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
    x_org_unit_cd IN VARCHAR2,
    x_ou_start_dt IN DATE,
    x_addr_type IN VARCHAR2,
    x_start_dt IN DATE
    )RETURN BOOLEAN AS
    CURSOR cur_rowid is
      SELECT   rowid
      FROM     IGS_OR_ADDR
      WHERE    org_unit_cd = x_org_unit_cd
      AND      ou_start_dt = x_ou_start_dt
      AND      addr_type = x_addr_type
      AND      start_dt = x_start_dt
      FOR UPDATE NOWAIT;
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

  PROCEDURE GET_FK_IGS_CO_ADDR_TYPE (
    x_addr_type IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_OR_ADDR
      WHERE    addr_type = x_addr_type ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_OR_OA_ADT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_CO_ADDR_TYPE;

  PROCEDURE GET_FK_IGS_OR_UNIT (
    x_org_unit_cd IN VARCHAR2,
    x_start_dt IN DATE
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_OR_ADDR
      WHERE    org_unit_cd = x_org_unit_cd
      AND      ou_start_dt = x_start_dt ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_OR_OA_OU_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_OR_UNIT;

  PROCEDURE GET_FK_IGS_PE_SUBURB_POSTCD (
    x_postcode IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_OR_ADDR
      WHERE    postal_code = x_postcode ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_OR_OA_SP_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_PE_SUBURB_POSTCD;

end IGS_OR_ADDR_PKG;

/
