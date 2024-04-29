--------------------------------------------------------
--  DDL for Package Body IGS_PS_USEC_OCCURS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_USEC_OCCURS_PKG" AS
/* $Header: IGSPI0WB.pls 120.2 2005/09/22 00:58:08 appldev ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_ps_usec_occurs_ALL%RowType;
  new_references igs_ps_usec_occurs_ALL%RowType;

PROCEDURE BeforeRowInsertUpdatedelete1( x_rowid  IN VARCHAR2) IS
/*************************************************************
  Created By : pradhakr
  Date Created By : 2000/06/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
   (reverse chronological order - newest change first)
   vvutukur    05-Nov-2002   Enh#2613933.Modified the cursor cur_ref_cd to add join with igs_ps_usec_occurs_all.
  ***************************************************************/
  CURSOR cur_ref_cd IS
  SELECT reference_code_type
  FROM igs_ps_usec_ocur_ref_v A,
       igs_ps_usec_occurs_all B
  WHERE A.unit_section_occurrence_id = B.unit_section_occurrence_id
  AND   B.rowid = x_rowid;

  l_ref_cd igs_ps_usec_ocur_ref_v.reference_code_type%TYPE;

BEGIN

  OPEN cur_ref_cd;
  FETCH cur_ref_cd INTO l_ref_cd;
  IF cur_ref_cd%FOUND THEN
     IF igs_ps_val_atl.chk_mandatory_ref_cd(l_ref_cd) THEN
        CLOSE cur_ref_cd;
        FND_MESSAGE.SET_NAME( 'IGS', 'IGS_PS_REF_CD_MANDATORY');
        IGS_GE_MSG_STACK.ADD;
        app_exception.raise_exception;
     END IF;
  END IF;
  CLOSE cur_ref_cd;

END BeforeRowInsertUpdatedelete1;

PROCEDURE Dflt_usec_occur_ref_code(p_n_usec_occur_id IN NUMBER, p_c_message_name OUT NOCOPY VARCHAR2) IS
/*************************************************************
  Created By : pradhakr
  Date Created By : 2000/06/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
 sarakshi         7-May-203      Enh#2858431,added restricted_flag,closed_id check in cursor cur_ref_code_type, also inside loop nullified variable l_rowid and l_usec_ref_id
  (reverse chronological order - newest change first)
  ***************************************************************/

  CURSOR cur_ref_code_type IS
  SELECT reference_cd_type
  FROM igs_ge_ref_cd_type
  WHERE unit_section_occurrence_flag ='Y' AND
        restricted_flag='Y' AND
        closed_ind ='N' AND
        mandatory_flag ='Y' ;
  l_ref_cd_type igs_ge_ref_cd_type.reference_cd_type%TYPE;

  CURSOR cur_ref_code( ref_cd_type IN igs_ge_ref_cd.reference_cd_type%TYPE) IS
  SELECT reference_cd,description
  FROM  igs_ge_ref_cd
  WHERE default_flag ='Y' AND
        reference_cd_type = ref_cd_type ;
  l_ref_cd cur_ref_code%ROWTYPE;
  l_usec_ref_id NUMBER;
  l_rowid VARCHAR2(20);

  BEGIN

    FOR ref_cd_count IN cur_ref_code_type LOOP
      OPEN cur_ref_code(ref_cd_count.reference_cd_type);
      FETCH cur_ref_code INTO l_ref_cd;
      IF cur_ref_code%FOUND THEN
      BEGIN
         l_rowid:=NULL;
         l_usec_ref_id:=NULL;
         igs_ps_usec_ocur_ref_pkg.insert_row(
           X_Mode                              => 'R',
           X_RowId                             => l_rowid,
           X_Unit_Sec_Occur_Reference_Id       => l_usec_ref_id,
           X_Unit_Section_Occurrence_Id        => p_n_usec_occur_id,
           X_Reference_Code_Type               => ref_cd_count.reference_cd_type,
           X_Reference_Code                    => l_ref_cd.reference_cd,
           X_reference_code_desc               => l_ref_cd.description
        );
       EXCEPTION
         -- The failure of insertion of reference code should not stop the creation of new Unit Section.
         -- Hence any exception raised by  the TBH is trapped and the current processing is allowed to proceed.
         WHEN OTHERS THEN
          NULL;
       END;
      END IF;
      CLOSE cur_ref_code;
    END LOOP;

  END Dflt_usec_occur_ref_code;


  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_unit_section_occurrence_id IN NUMBER ,
    x_uoo_id IN NUMBER ,
    x_monday IN VARCHAR2 ,
    x_tuesday IN VARCHAR2 ,
    x_wednesday IN VARCHAR2 ,
    x_thursday IN VARCHAR2 ,
    x_friday IN VARCHAR2 ,
    x_saturday IN VARCHAR2 ,
    x_sunday IN VARCHAR2 ,
    x_start_time IN DATE ,
    x_end_time IN DATE ,
    x_building_code IN NUMBER ,
    x_room_code IN NUMBER ,
    x_schedule_status IN VARCHAR2 ,
    x_status_last_updated IN DATE ,
    x_instructor_id IN NUMBER ,
    x_attribute_category  IN VARCHAR2 ,
    x_attribute1          IN VARCHAR2 ,
    x_attribute2          IN VARCHAR2 ,
    x_attribute3          IN VARCHAR2 ,
    x_attribute4          IN VARCHAR2 ,
    x_attribute5          IN VARCHAR2 ,
    x_attribute6          IN VARCHAR2 ,
    x_attribute7          IN VARCHAR2 ,
    x_attribute8          IN VARCHAR2 ,
    x_attribute9          IN VARCHAR2 ,
    x_attribute10         IN VARCHAR2 ,
    x_attribute11         IN VARCHAR2 ,
    x_attribute12         IN VARCHAR2 ,
    x_attribute13         IN VARCHAR2 ,
    x_attribute14         IN VARCHAR2 ,
    x_attribute15         IN VARCHAR2 ,
    x_attribute16         IN VARCHAR2 ,
    x_attribute17         IN VARCHAR2 ,
    x_attribute18         IN VARCHAR2 ,
    x_attribute19         IN VARCHAR2 ,
    x_attribute20         IN VARCHAR2 ,
    x_error_text IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER ,
    x_org_id in NUMBER ,
    x_start_date in DATE ,
    x_end_date in DATE ,
    x_to_be_announced in VARCHAR2 ,
    x_inst_notify_ind IN VARCHAR2 ,
    x_notify_status IN VARCHAR2 ,
    x_dedicated_building_code IN NUMBER ,
    x_dedicated_room_code IN NUMBER ,
    x_preferred_building_code IN NUMBER ,
    x_preferred_room_code IN NUMBER,
    x_preferred_region_code IN VARCHAR2,
    x_no_set_day_ind IN VARCHAR2,
    x_cancel_flag IN VARCHAR2 ,
    x_occurrence_identifier IN VARCHAR2,
    x_abort_flag IN VARCHAR2

 ) AS

  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  smvk            02-Sep-2002     Removed the Default value in the parameters to overcome File.Pkg.22 gscc warnings.
                                  As a part of Build SFCR005_Cleanup_Build (Enhancement Bug # 2531390)
  rgangara        09-May-2001     Added x_notify_status and x_inst_notify_ind args
  Sreenivas.Bonam 28-Aug-2000     Added x_error_text argument
  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_USEC_OCCURS_ALL
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.unit_section_occurrence_id := x_unit_section_occurrence_id;
    new_references.uoo_id := x_uoo_id;
    new_references.monday := x_monday;
    new_references.tuesday := x_tuesday;
    new_references.wednesday := x_wednesday;
    new_references.thursday := x_thursday;
    new_references.friday := x_friday;
    new_references.saturday := x_saturday;
    new_references.sunday := x_sunday;
    new_references.start_time := x_start_time;
    new_references.end_time := x_end_time;
    new_references.building_code := x_building_code;
    new_references.room_code := x_room_code;
    new_references.schedule_status := x_schedule_status;
    new_references.status_last_updated := x_status_last_updated;
    new_references.instructor_id := x_instructor_id;
    new_references.attribute_category := x_attribute_category;
    new_references.attribute1 := x_attribute1;
    new_references.attribute2 := x_attribute2;
    new_references.attribute3 := x_attribute3;
    new_references.attribute4 := x_attribute4;
    new_references.attribute5 := x_attribute5;
    new_references.attribute6 := x_attribute6;
    new_references.attribute7 := x_attribute7;
    new_references.attribute8 := x_attribute8;
    new_references.attribute9 := x_attribute9;
    new_references.attribute10 := x_attribute10;
    new_references.attribute11 := x_attribute11;
    new_references.attribute12 := x_attribute12;
    new_references.attribute13 := x_attribute13;
    new_references.attribute14 := x_attribute14;
    new_references.attribute15 := x_attribute15;
    new_references.attribute16 := x_attribute16;
    new_references.attribute17 := x_attribute17;
    new_references.attribute18 := x_attribute18;
    new_references.attribute19 := x_attribute19;
    new_references.attribute20 := x_attribute20;
    new_references.error_text := x_error_text;
    new_references.org_id := x_org_id;
    new_references.start_date := x_start_date;
    new_references.end_date := x_end_date;
    new_references.to_be_announced := x_to_be_announced;
    IF (p_action = 'UPDATE') THEN
      new_references.creation_date := old_references.creation_date;
      new_references.created_by := old_references.created_by;
    ELSE
      new_references.creation_date := x_creation_date;
      new_references.created_by := x_created_by;
    END IF;
    new_references.last_update_date := x_last_update_date;
    new_references.last_updated_by := x_last_updated_by;
    new_references.last_update_login := x_last_update_login;
    new_references.inst_notify_ind := x_inst_notify_ind;
    new_references.notify_status := x_notify_status;
    new_references.dedicated_building_code := x_dedicated_building_code;
    new_references.dedicated_room_code := x_dedicated_room_code;
    new_references.preferred_building_code := x_preferred_building_code;
    new_references.preferred_room_code := x_preferred_room_code;
    new_references.preferred_region_code := x_preferred_region_code;
    new_references.no_set_day_ind := x_no_set_day_ind;
    new_references.cancel_flag := x_cancel_flag;
    new_references.occurrence_identifier :=  x_occurrence_identifier;
    new_references.abort_flag :=  x_abort_flag;

  END Set_Column_Values;

  PROCEDURE Check_Constraints (
                 Column_Name IN VARCHAR2  ,
                 Column_Value IN VARCHAR2   ) AS
  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  shtatiko        20-NOV-2002     Added checks for to_be_announced and all days.
                                  (Bug# 2649028)
  smvk            02-Sep-2002     Removed the Default value in the parameters to overcome File.Pkg.22 gscc warnings.
                                  As a part of Build SFCR005_Cleanup_Build (Enhancement Bug # 2531390)
  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    IF column_name IS NULL THEN
      NULL;
    ELSIF UPPER ( column_name ) = 'NO_SET_DAY_IND' THEN
      new_references.no_set_day_ind := column_value;
    ELSIF UPPER ( column_name ) = 'TO_BE_ANNOUNCED' THEN
      new_references.to_be_announced := column_value;
    ELSIF UPPER ( column_name ) = 'MONDAY' THEN
      new_references.monday := column_value;
    ELSIF UPPER ( column_name ) = 'TUESDAY' THEN
      new_references.tuesday := column_value;
    ELSIF UPPER ( column_name ) = 'WEDNESDAY' THEN
      new_references.wednesday := column_value;
    ELSIF UPPER ( column_name ) = 'THURSDAY' THEN
      new_references.thursday := column_value;
    ELSIF UPPER ( column_name ) = 'FRIDAY' THEN
      new_references.friday := column_value;
    ELSIF UPPER ( column_name ) = 'SATURDAY' THEN
      new_references.saturday := column_value;
    ELSIF UPPER ( column_name ) = 'SUNDAY' THEN
      new_references.sunday := column_value;
    ELSIF UPPER ( column_name ) = 'CANCEL_FLAG' THEN
      new_references.sunday := column_value;
    ELSIF UPPER ( column_name ) = 'ABORT_FLAG' THEN
      new_references.abort_flag := column_value;
    END IF;

  IF UPPER(column_name)='NO_SET_DAY_IND' OR column_name IS NULL Then
    IF new_references.no_set_day_ind NOT IN ( 'Y' , 'N' ) Then
      fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    END IF;
  END IF;

  IF UPPER(column_name)='TO_BE_ANNOUNCED' OR column_name IS NULL Then
    IF new_references.to_be_announced NOT IN ( 'Y' , 'N' ) Then
      fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    END IF;
  END IF;

  IF UPPER(column_name)='MONDAY' OR column_name IS NULL Then
    IF new_references.monday NOT IN ( 'Y' , 'N' ) Then
      fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    END IF;
  END IF;

  IF UPPER(column_name)='TUESDAY' OR column_name IS NULL Then
    IF new_references.tuesday NOT IN ( 'Y' , 'N' ) Then
      fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    END IF;
  END IF;

  IF UPPER(column_name)='WEDNESDAY' OR column_name IS NULL Then
    IF new_references.wednesday NOT IN ( 'Y' , 'N' ) Then
      fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    END IF;
  END IF;

  IF UPPER(column_name)='THURSDAY' OR column_name IS NULL Then
    IF new_references.thursday NOT IN ( 'Y' , 'N' ) Then
      fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    END IF;
  END IF;

  IF UPPER(column_name)='FRIDAY' OR column_name IS NULL Then
    IF new_references.friday NOT IN ( 'Y' , 'N' ) Then
      fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    END IF;
  END IF;

  IF UPPER(column_name)='SATURDAY' OR column_name IS NULL Then
    IF new_references.saturday NOT IN ( 'Y' , 'N' ) Then
      fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    END IF;
  END IF;

  IF UPPER(column_name)='SUNDAY' OR column_name IS NULL Then
    IF new_references.sunday NOT IN ( 'Y' , 'N' ) Then
      fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    END IF;
  END IF;

  IF UPPER(column_name)='CANCEL_FLAG' OR column_name IS NULL Then
    IF new_references.no_set_day_ind NOT IN ( 'Y' , 'N' ) Then
      fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    END IF;
  END IF;

  IF UPPER(column_name)='ABORT_FLAG' OR column_name IS NULL THEN
    IF new_references.abort_flag NOT IN ( 'Y' , 'N' ) Then
      fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    END IF;
  END IF;


  END Check_Constraints;



 PROCEDURE Check_Uniqueness AS
  /*************************************************************
  Created By : sarakshi
  Date Created By : 19-May-2005
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   BEGIN
              IF Get_Uk_For_Validation (
                new_references.uoo_id
                ,new_references.occurrence_identifier
                ) THEN
                  Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
                  IGS_GE_MSG_STACK.ADD;
                  app_exception.raise_exception;
              END IF;
  END Check_Uniqueness ;

  PROCEDURE Check_Parent_Existance AS
  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  jbegum          21-APR-2003     Added call to Igs_Lookups_View_Pkg.Get_PK_For_Validation
                                  for IGS_OR_LOC_REGION llokup_type.
  Sreenivas.Bonam 28-Aug-2000     Added check for IGS_LOOKUPS_VIEW
  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    IF (((old_references.building_code = new_references.building_code)) OR
        ((new_references.building_code IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Building_Pkg.Get_PK_For_Validation (
                        new_references.building_code,
                        'N'
        )  THEN
         Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.room_code = new_references.room_code)) OR
        ((new_references.room_code IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Room_Pkg.Get_PK_For_Validation (
                        new_references.room_code,
                        'N'
        )  THEN
         Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.uoo_id = new_references.uoo_id)) OR
        ((new_references.uoo_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ps_Unit_Ofr_Opt_Pkg.Get_UK_For_Validation (
                        new_references.uoo_id
        )  THEN
         Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.schedule_status = new_references.schedule_status)) OR
        ((new_references.schedule_status IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Lookups_View_Pkg.Get_PK_For_Validation (
                       'SCHEDULE_TYPE', new_references.schedule_status
        )  THEN
         Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.preferred_region_code = new_references.preferred_region_code)) OR
        ((new_references.preferred_region_code IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Lookups_View_Pkg.Get_PK_For_Validation (
                       'IGS_OR_LOC_REGION', new_references.preferred_region_code
        )  THEN
         Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance IS
  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sarakshi       28-oct-2002     ENh#2613933,removed the call of igs_ps_uso_clas_meet_pkg.get_FK_Igs_Ps_Usec_Occur

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    Igs_Ps_Usec_Ocur_Ref_Pkg.Get_FK_Igs_Ps_Usec_Occurs (
      old_references.unit_section_occurrence_id
      );


    igs_ps_uso_facility_pkg.get_FK_Igs_Ps_Usec_Occurs (
      old_references.unit_section_occurrence_id
      );

    igs_ps_uso_instrctrs_pkg.get_FK_Igs_Ps_Usec_Occurs (
      old_references.unit_section_occurrence_id
      );

    --Bug 3199686
    --Created IGS_AS_USEC_SESSNS table
    igs_as_usec_sessns_pkg.get_fk_igs_ps_usec_occurs(      old_references.unit_section_occurrence_id );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_unit_section_occurrence_id IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_usec_occurs_ALL
      WHERE    unit_section_occurrence_id = x_unit_section_occurrence_id
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Return(TRUE);
    ELSE
      Close cur_rowid;
      Return(FALSE);
    END IF;
  END Get_PK_For_Validation;

 FUNCTION Get_UK_For_Validation (
    x_uoo_id IN NUMBER,
    x_occurrence_identifier IN VARCHAR2
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By : sarakshi
  Date Created On : 19-MAY-2005
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_usec_occurs_all
      WHERE    uoo_id = x_uoo_id
      AND      occurrence_identifier = x_occurrence_identifier
      AND     ((l_rowid is null) or (rowid <> l_rowid));
     lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      RETURN (TRUE);
    ELSE
      CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;

  END Get_UK_For_Validation ;

  PROCEDURE Get_FK_Igs_Ad_Building (
    x_building_id IN NUMBER
    ) AS

  /*************************************************************
  Created By : 19-May-2000
  Date Created By : venagara
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_usec_occurs_ALL
      WHERE    building_code = x_building_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_USO_BLDG_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ad_Building;


  PROCEDURE Get_FK_Igs_Ad_Room (
    x_room_id IN NUMBER
    ) AS

  /*************************************************************
  Created By : 19-May-2000
  Date Created By : venagara
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_usec_occurs_ALL
      WHERE    room_code = x_room_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_USO_ROOM_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ad_Room;


  PROCEDURE Get_UFK_Igs_Ps_Unit_Ofr_Opt (
    x_uoo_id IN NUMBER
    ) AS

  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_usec_occurs_ALL
      WHERE    uoo_id = x_uoo_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_USO_UOO_UFK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_UFK_Igs_Ps_Unit_Ofr_Opt;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_unit_section_occurrence_id IN NUMBER ,
    x_uoo_id IN NUMBER ,
    x_monday IN VARCHAR2 ,
    x_tuesday IN VARCHAR2 ,
    x_wednesday IN VARCHAR2 ,
    x_thursday IN VARCHAR2 ,
    x_friday IN VARCHAR2 ,
    x_saturday IN VARCHAR2 ,
    x_sunday IN VARCHAR2 ,
    x_start_time IN DATE ,
    x_end_time IN DATE ,
    x_building_code IN NUMBER ,
    x_room_code IN NUMBER ,
    x_schedule_status IN VARCHAR2 ,
    x_status_last_updated IN DATE ,
    x_instructor_id IN NUMBER ,
    x_attribute_category  IN VARCHAR2 ,
    x_attribute1          IN VARCHAR2 ,
    x_attribute2          IN VARCHAR2 ,
    x_attribute3          IN VARCHAR2 ,
    x_attribute4          IN VARCHAR2 ,
    x_attribute5          IN VARCHAR2 ,
    x_attribute6          IN VARCHAR2 ,
    x_attribute7          IN VARCHAR2 ,
    x_attribute8          IN VARCHAR2 ,
    x_attribute9          IN VARCHAR2 ,
    x_attribute10         IN VARCHAR2 ,
    x_attribute11         IN VARCHAR2 ,
    x_attribute12         IN VARCHAR2 ,
    x_attribute13         IN VARCHAR2 ,
    x_attribute14         IN VARCHAR2 ,
    x_attribute15         IN VARCHAR2 ,
    x_attribute16         IN VARCHAR2 ,
    x_attribute17         IN VARCHAR2 ,
    x_attribute18         IN VARCHAR2 ,
    x_attribute19         IN VARCHAR2 ,
    x_attribute20         IN VARCHAR2 ,
    x_error_text IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER ,
    x_org_id IN NUMBER ,
    x_start_date IN DATE ,
    x_end_date In DATE ,
    x_to_be_announced IN VARCHAR2 ,
    x_inst_notify_ind IN VARCHAR2 ,
    x_notify_status IN VARCHAR2 ,
    x_dedicated_building_code IN NUMBER ,
    x_dedicated_room_code IN NUMBER ,
    x_preferred_building_code IN NUMBER ,
    x_preferred_room_code IN NUMBER,
    x_preferred_region_code IN VARCHAR2,
    x_no_set_day_ind IN VARCHAR2,
    x_cancel_flag IN VARCHAR2 ,
    x_occurrence_identifier IN VARCHAR2,
    x_abort_flag IN VARCHAR2
  ) AS
  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  smvk            02-Sep-2002     Removed the Default value in the parameters to overcome File.Pkg.22 gscc warnings.
                                  As a part of Build SFCR005_Cleanup_Build (Enhancement Bug # 2531390)
  rgangara        09-May-2001     x_notify_status, x_inst_notify_ind arguments added
  Sreenivas.Bonam 28-Aug-2000     x_error_text argument added
  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_unit_section_occurrence_id,
      x_uoo_id,
      x_monday,
      x_tuesday,
      x_wednesday,
      x_thursday,
      x_friday,
      x_saturday,
      x_sunday,
      x_start_time,
      x_end_time,
      x_building_code,
      x_room_code,
      x_schedule_status,
      x_status_last_updated,
      x_instructor_id,
      x_attribute_category ,
      x_attribute1 ,
      x_attribute2 ,
      x_attribute3 ,
      x_attribute4 ,
      x_attribute5 ,
      x_attribute6 ,
      x_attribute7 ,
      x_attribute8 ,
      x_attribute9 ,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_attribute16,
      x_attribute17,
      x_attribute18,
      x_attribute19,
      x_attribute20,
      x_error_text,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_org_id,
      x_start_date,
      x_end_date,
      x_to_be_announced,
      x_inst_notify_ind,
      x_notify_status,
      x_dedicated_building_code,
      x_dedicated_room_code,
      x_preferred_building_code,
      x_preferred_room_code,
      x_preferred_region_code,
      x_no_set_day_ind,
      x_cancel_flag,
      x_occurrence_identifier,
      x_abort_flag
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.

             IF Get_Pk_For_Validation(
                new_references.unit_section_occurrence_id)  THEN
               Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
                IGS_GE_MSG_STACK.ADD;
               App_Exception.Raise_Exception;
             END IF;

      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
         -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
                new_references.unit_section_occurrence_id)  THEN
               Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
               App_Exception.Raise_Exception;
             END IF;
      Check_Uniqueness;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Uniqueness;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance;
    END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) IS
  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  CURSOR cur_ref_id IS
  SELECT unit_section_occurrence_id
  FROM igs_ps_usec_occurs_v
  WHERE row_id = x_rowid;
  l_ref_id igs_ps_usec_occurs_v.unit_section_occurrence_id%TYPE;
  l_error_message VARCHAR2(300);

  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      -- Null;
      OPEN cur_ref_id;
      FETCH cur_ref_id INTO l_ref_id;
      IF cur_ref_id%FOUND THEN
         Dflt_usec_occur_ref_code(l_ref_id, l_error_message);
         CLOSE cur_ref_id;
      ELSE
         CLOSE cur_ref_id;
      END IF;

    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      Null;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      Null;
    END IF;

    l_rowid := NULL;

  END After_DML;

 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_SECTION_OCCURRENCE_ID IN OUT NOCOPY NUMBER,
       x_UOO_ID IN NUMBER,
       x_MONDAY IN VARCHAR2,
       x_TUESDAY IN VARCHAR2,
       x_WEDNESDAY IN VARCHAR2,
       x_THURSDAY IN VARCHAR2,
       x_FRIDAY IN VARCHAR2,
       x_SATURDAY IN VARCHAR2,
       x_SUNDAY IN VARCHAR2,
       x_START_TIME IN DATE,
       x_END_TIME IN DATE,
       x_BUILDING_CODE IN NUMBER,
       x_ROOM_CODE IN NUMBER,
       x_SCHEDULE_STATUS IN VARCHAR2,
       x_STATUS_LAST_UPDATED IN DATE,
       x_INSTRUCTOR_ID IN NUMBER,
       X_ATTRIBUTE_CATEGORY  IN VARCHAR2 ,
       X_ATTRIBUTE1          IN VARCHAR2 ,
       X_ATTRIBUTE2          IN VARCHAR2 ,
       X_ATTRIBUTE3          IN VARCHAR2 ,
       X_ATTRIBUTE4          IN VARCHAR2 ,
       X_ATTRIBUTE5          IN VARCHAR2 ,
       X_ATTRIBUTE6          IN VARCHAR2 ,
       X_ATTRIBUTE7          IN VARCHAR2 ,
       X_ATTRIBUTE8          IN VARCHAR2 ,
       X_ATTRIBUTE9          IN VARCHAR2 ,
       X_ATTRIBUTE10         IN VARCHAR2 ,
       X_ATTRIBUTE11         IN VARCHAR2 ,
       X_ATTRIBUTE12         IN VARCHAR2 ,
       X_ATTRIBUTE13         IN VARCHAR2 ,
       X_ATTRIBUTE14         IN VARCHAR2 ,
       X_ATTRIBUTE15         IN VARCHAR2 ,
       X_ATTRIBUTE16         IN VARCHAR2 ,
       X_ATTRIBUTE17         IN VARCHAR2 ,
       X_ATTRIBUTE18         IN VARCHAR2 ,
       X_ATTRIBUTE19         IN VARCHAR2 ,
       X_ATTRIBUTE20         IN VARCHAR2 ,
       x_ERROR_TEXT IN VARCHAR2,
       X_MODE in VARCHAR2 ,
       x_org_id in NUMBER,
       x_start_date IN DATE,
       x_end_date IN DATE,
       x_to_be_announced IN VARCHAR2 ,
       X_INST_NOTIFY_IND IN VARCHAR2 ,
       X_NOTIFY_STATUS IN VARCHAR2 ,
       x_dedicated_building_code IN NUMBER ,
       x_dedicated_room_code IN NUMBER ,
       x_preferred_building_code IN NUMBER ,
       x_preferred_room_code IN NUMBER,
       x_preferred_region_code IN VARCHAR2,
       x_no_set_day_ind IN VARCHAR2,
       x_cancel_flag IN VARCHAR2 ,
       x_occurrence_identifier IN VARCHAR2,
       x_abort_flag IN VARCHAR2
  ) AS
  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  smvk            02-Sep-2002     Removed the Default value in the parameters to overcome File.Pkg.22 gscc warnings.
                                  As a part of Build SFCR005_Cleanup_Build (Enhancement Bug # 2531390)
  rgangara        09-May-2001     Added x_notify_status, x_inst_notify_ind arguments
  Sreenivas.Bonam 28-Aug-2000     Added x_ERROR_TEXT argument
  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_PS_USEC_OCCURS_ALL
             where                 UNIT_SECTION_OCCURRENCE_ID= X_UNIT_SECTION_OCCURRENCE_ID
;
     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
     X_REQUEST_ID NUMBER;
     X_PROGRAM_ID NUMBER;
     X_PROGRAM_APPLICATION_ID NUMBER;
     X_PROGRAM_UPDATE_DATE DATE;

 begin
     X_LAST_UPDATE_DATE := SYSDATE;
      if(X_MODE = 'I') then
        X_LAST_UPDATED_BY := 1;
        X_LAST_UPDATE_LOGIN := 0;
      elsif (X_MODE = 'R') then
        X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
        if X_LAST_UPDATED_BY is NULL then
          X_LAST_UPDATED_BY := -1;
        end if;
        X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
        if X_LAST_UPDATE_LOGIN is NULL then
          X_LAST_UPDATE_LOGIN := -1;
        end if;
        X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
        X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
        X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
        IF ( X_REQUEST_ID = -1 ) THEN
          X_REQUEST_ID := NULL;
          X_PROGRAM_ID := NULL;
          X_PROGRAM_APPLICATION_ID := NULL;
          X_PROGRAM_UPDATE_DATE := NULL;
        ELSE
          X_PROGRAM_UPDATE_DATE := SYSDATE;
        END IF;
      else
        FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
      IGS_GE_MSG_STACK.ADD;
          app_exception.raise_exception;
       end if;
   SELECT
     igs_ps_usec_occurs_s.nextval
   INTO
     x_UNIT_SECTION_OCCURRENCE_ID
   FROM dual;
   Before_DML(
                p_action=>'INSERT',
                x_rowid=>X_ROWID,
               x_unit_section_occurrence_id=>X_UNIT_SECTION_OCCURRENCE_ID,
               x_uoo_id=>X_UOO_ID,
               x_monday=>X_MONDAY,
               x_tuesday=>X_TUESDAY,
               x_wednesday=>X_WEDNESDAY,
               x_thursday=>X_THURSDAY,
               x_friday=>X_FRIDAY,
               x_saturday=>X_SATURDAY,
               x_sunday=>X_SUNDAY,
               x_start_time=>X_START_TIME,
               x_end_time=>X_END_TIME,
               x_building_code=>X_BUILDING_CODE,
               x_room_code=>X_ROOM_CODE,
               x_schedule_status=>X_SCHEDULE_STATUS,
               x_status_last_updated=>X_STATUS_LAST_UPDATED,
               x_instructor_id=>X_INSTRUCTOR_ID,
               x_attribute_category=>X_ATTRIBUTE_CATEGORY,
               x_attribute1=>X_ATTRIBUTE1,
               x_attribute2=>X_ATTRIBUTE2,
               x_attribute3=>X_ATTRIBUTE3,
               x_attribute4=>X_ATTRIBUTE4,
               x_attribute5=>X_ATTRIBUTE5,
               x_attribute6=>X_ATTRIBUTE6,
               x_attribute7=>X_ATTRIBUTE7,
               x_attribute8=>X_ATTRIBUTE8,
               x_attribute9=>X_ATTRIBUTE9,
               x_attribute10=>X_ATTRIBUTE10,
               x_attribute11=>X_ATTRIBUTE11,
               x_attribute12=>X_ATTRIBUTE12,
               x_attribute13=>X_ATTRIBUTE13,
               x_attribute14=>X_ATTRIBUTE14,
               x_attribute15=>X_ATTRIBUTE15,
               x_attribute16=>X_ATTRIBUTE16,
               x_attribute17=>X_ATTRIBUTE17,
               x_attribute18=>X_ATTRIBUTE18,
               x_attribute19=>X_ATTRIBUTE19,
               x_attribute20=>X_ATTRIBUTE20,
               x_error_text=>X_ERROR_TEXT,
               x_creation_date=>X_LAST_UPDATE_DATE,
               x_created_by=>X_LAST_UPDATED_BY,
               x_last_update_date=>X_LAST_UPDATE_DATE,
               x_last_updated_by=>X_LAST_UPDATED_BY,
               x_last_update_login=>X_LAST_UPDATE_LOGIN,
               x_org_id=>igs_ge_gen_003.get_org_id,
               x_start_date => X_START_DATE,
               x_end_date => X_END_DATE,
               x_to_be_announced => X_TO_BE_ANNOUNCED,
               x_inst_notify_ind => X_INST_NOTIFY_IND,
               x_notify_status => X_NOTIFY_STATUS,
               x_dedicated_building_code => x_dedicated_building_code,
               x_dedicated_room_code => x_dedicated_room_code,
               x_preferred_building_code => x_preferred_building_code,
               x_preferred_room_code => x_preferred_room_code,
               x_preferred_region_code => x_preferred_region_code,
               x_no_set_day_ind => x_no_set_day_ind,
               x_cancel_flag => x_cancel_flag,
	       x_occurrence_identifier => x_occurrence_identifier,
               x_abort_flag => x_abort_flag

     );
     insert into IGS_PS_USEC_OCCURS_ALL (
                UNIT_SECTION_OCCURRENCE_ID
                ,UOO_ID
                ,MONDAY
                ,TUESDAY
                ,WEDNESDAY
                ,THURSDAY
                ,FRIDAY
                ,SATURDAY
                ,SUNDAY
                ,START_TIME
                ,END_TIME
                ,BUILDING_CODE
                ,ROOM_CODE
                ,SCHEDULE_STATUS
                ,STATUS_LAST_UPDATED
                ,INSTRUCTOR_ID
                ,ATTRIBUTE_CATEGORY
                ,ATTRIBUTE1
                ,ATTRIBUTE2
                ,ATTRIBUTE3
                ,ATTRIBUTE4
                ,ATTRIBUTE5
                ,ATTRIBUTE6
                ,ATTRIBUTE7
                ,ATTRIBUTE8
                ,ATTRIBUTE9
                ,ATTRIBUTE10
                ,ATTRIBUTE11
                ,ATTRIBUTE12
                ,ATTRIBUTE13
                ,ATTRIBUTE14
                ,ATTRIBUTE15
                ,ATTRIBUTE16
                ,ATTRIBUTE17
                ,ATTRIBUTE18
                ,ATTRIBUTE19
                ,ATTRIBUTE20
               ,ERROR_TEXT
                ,CREATION_DATE
                ,CREATED_BY
                ,LAST_UPDATE_DATE
                ,LAST_UPDATED_BY
                ,LAST_UPDATE_LOGIN
                ,REQUEST_ID
                ,PROGRAM_ID
                ,PROGRAM_APPLICATION_ID
                ,PROGRAM_UPDATE_DATE
                ,ORG_ID
                ,START_DATE
                ,END_DATE
                ,TO_BE_ANNOUNCED
                ,INST_NOTIFY_IND
                ,NOTIFY_STATUS
                ,dedicated_building_code,
                 dedicated_room_code,
                 preferred_building_code,
                 preferred_room_code,
                 preferred_region_code,
                 no_set_day_ind,
                 cancel_flag,
	         occurrence_identifier,
                 abort_flag

        ) values  (
                NEW_REFERENCES.UNIT_SECTION_OCCURRENCE_ID
                ,NEW_REFERENCES.UOO_ID
                ,NEW_REFERENCES.MONDAY
                ,NEW_REFERENCES.TUESDAY
                ,NEW_REFERENCES.WEDNESDAY
                ,NEW_REFERENCES.THURSDAY
                ,NEW_REFERENCES.FRIDAY
                ,NEW_REFERENCES.SATURDAY
                ,NEW_REFERENCES.SUNDAY
                ,NEW_REFERENCES.START_TIME
                ,NEW_REFERENCES.END_TIME
                ,NEW_REFERENCES.BUILDING_CODE
                ,NEW_REFERENCES.ROOM_CODE
                ,NEW_REFERENCES.SCHEDULE_STATUS
                ,NEW_REFERENCES.STATUS_LAST_UPDATED
                ,NEW_REFERENCES.INSTRUCTOR_ID
                ,NEW_REFERENCES.ATTRIBUTE_CATEGORY
                ,NEW_REFERENCES.ATTRIBUTE1
                ,NEW_REFERENCES.ATTRIBUTE2
                ,NEW_REFERENCES.ATTRIBUTE3
                ,NEW_REFERENCES.ATTRIBUTE4
                ,NEW_REFERENCES.ATTRIBUTE5
                ,NEW_REFERENCES.ATTRIBUTE6
                ,NEW_REFERENCES.ATTRIBUTE7
                ,NEW_REFERENCES.ATTRIBUTE8
                ,NEW_REFERENCES.ATTRIBUTE9
                ,NEW_REFERENCES.ATTRIBUTE10
                ,NEW_REFERENCES.ATTRIBUTE11
                ,NEW_REFERENCES.ATTRIBUTE12
                ,NEW_REFERENCES.ATTRIBUTE13
                ,NEW_REFERENCES.ATTRIBUTE14
                ,NEW_REFERENCES.ATTRIBUTE15
                ,NEW_REFERENCES.ATTRIBUTE16
                ,NEW_REFERENCES.ATTRIBUTE17
                ,NEW_REFERENCES.ATTRIBUTE18
                ,NEW_REFERENCES.ATTRIBUTE19
                ,NEW_REFERENCES.ATTRIBUTE20
                ,NEW_REFERENCES.ERROR_TEXT
                ,X_LAST_UPDATE_DATE
                ,X_LAST_UPDATED_BY
                ,X_LAST_UPDATE_DATE
                ,X_LAST_UPDATED_BY
                ,X_LAST_UPDATE_LOGIN
                ,X_REQUEST_ID
                ,X_PROGRAM_ID
                ,X_PROGRAM_APPLICATION_ID
                ,X_PROGRAM_UPDATE_DATE
                ,NEW_REFERENCES.ORG_ID
                ,NEW_REFERENCES.START_DATE
                ,NEW_REFERENCES.END_DATE
                ,NEW_REFERENCES.TO_BE_ANNOUNCED
                ,NEW_REFERENCES.INST_NOTIFY_IND
                ,NEW_REFERENCES.NOTIFY_STATUS
                ,new_references.dedicated_building_code
                ,new_references.dedicated_room_code
                ,new_references.preferred_building_code
                ,new_references.preferred_room_code
                ,new_references.preferred_region_code
                ,new_references.no_set_day_ind
                ,new_references.cancel_flag
	       ,new_references.occurrence_identifier
               ,new_references.abort_flag

        );
                open c;
                 fetch c into X_ROWID;
                if (c%notfound) then
                close c;
             raise no_data_found;
                end if;
                close c;
    After_DML (
                p_action => 'INSERT' ,
                x_rowid => X_ROWID );
end INSERT_ROW;

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_UNIT_SECTION_OCCURRENCE_ID IN NUMBER,
       x_UOO_ID IN NUMBER,
       x_MONDAY IN VARCHAR2,
       x_TUESDAY IN VARCHAR2,
       x_WEDNESDAY IN VARCHAR2,
       x_THURSDAY IN VARCHAR2,
       x_FRIDAY IN VARCHAR2,
       x_SATURDAY IN VARCHAR2,
       x_SUNDAY IN VARCHAR2,
       x_START_TIME IN DATE,
       x_END_TIME IN DATE,
       x_BUILDING_CODE IN NUMBER,
       x_ROOM_CODE IN NUMBER,
       x_SCHEDULE_STATUS IN VARCHAR2,
       x_STATUS_LAST_UPDATED IN DATE,
       x_INSTRUCTOR_ID IN NUMBER,
       X_ATTRIBUTE_CATEGORY  IN VARCHAR2 ,
       X_ATTRIBUTE1          IN VARCHAR2 ,
       X_ATTRIBUTE2          IN VARCHAR2 ,
       X_ATTRIBUTE3          IN VARCHAR2 ,
       X_ATTRIBUTE4          IN VARCHAR2 ,
       X_ATTRIBUTE5          IN VARCHAR2 ,
       X_ATTRIBUTE6          IN VARCHAR2 ,
       X_ATTRIBUTE7          IN VARCHAR2 ,
       X_ATTRIBUTE8          IN VARCHAR2 ,
       X_ATTRIBUTE9          IN VARCHAR2 ,
       X_ATTRIBUTE10         IN VARCHAR2 ,
       X_ATTRIBUTE11         IN VARCHAR2 ,
       X_ATTRIBUTE12         IN VARCHAR2 ,
       X_ATTRIBUTE13         IN VARCHAR2 ,
       X_ATTRIBUTE14         IN VARCHAR2 ,
       X_ATTRIBUTE15         IN VARCHAR2 ,
       X_ATTRIBUTE16         IN VARCHAR2 ,
       X_ATTRIBUTE17         IN VARCHAR2 ,
       X_ATTRIBUTE18         IN VARCHAR2 ,
       X_ATTRIBUTE19         IN VARCHAR2 ,
       X_ATTRIBUTE20         IN VARCHAR2 ,
       x_ERROR_TEXT IN VARCHAR2,
       X_START_DATE IN DATE,
       X_END_DATE IN DATE,
       X_TO_BE_ANNOUNCED IN VARCHAR2,
       X_INST_NOTIFY_IND IN VARCHAR2 ,
       X_NOTIFY_STATUS IN VARCHAR2 ,
       x_dedicated_building_code IN NUMBER ,
       x_dedicated_room_code IN NUMBER ,
       x_preferred_building_code IN NUMBER ,
       x_preferred_room_code IN NUMBER,
       x_preferred_region_code IN VARCHAR2,
       x_no_set_day_ind IN VARCHAR2,
       x_cancel_flag IN VARCHAR2,
       x_occurrence_identifier IN VARCHAR2,
       x_abort_flag IN VARCHAR2

 ) AS

  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  smvk            02-Sep-2002     Removed the Default value in the parameters to overcome File.Pkg.22 gscc warnings.
                                  As a part of Build SFCR005_Cleanup_Build (Enhancement Bug # 2531390)
  smvk            27-Jun-2002     Truncating status_last_updated as a part of bug # 2427627
  rgangara        09-May-2001     Added x_NOTIFY_STATUS, x_INST_NOTIFY_IND args
  Sreenivas.Bonam 28-Aug-2000     Added x_ERROR_TEXT argument
  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select
      UOO_ID
,      MONDAY
,      TUESDAY
,      WEDNESDAY
,      THURSDAY
,      FRIDAY
,      SATURDAY
,      SUNDAY
,      START_TIME
,      END_TIME
,      BUILDING_CODE
,      ROOM_CODE
,      SCHEDULE_STATUS
,      STATUS_LAST_UPDATED
,      INSTRUCTOR_ID
,      ATTRIBUTE_CATEGORY
,      ATTRIBUTE1
,      ATTRIBUTE2
,      ATTRIBUTE3
,      ATTRIBUTE4
,      ATTRIBUTE5
,      ATTRIBUTE6
,      ATTRIBUTE7
,      ATTRIBUTE8
,      ATTRIBUTE9
,      ATTRIBUTE10
,      ATTRIBUTE11
,      ATTRIBUTE12
,      ATTRIBUTE13
,      ATTRIBUTE14
,      ATTRIBUTE15
,      ATTRIBUTE16
,      ATTRIBUTE17
,      ATTRIBUTE18
,      ATTRIBUTE19
,      ATTRIBUTE20
,      ERROR_TEXT
,      START_DATE
,      END_DATE
,      TO_BE_ANNOUNCED
,      INST_NOTIFY_IND
,      NOTIFY_STATUS,
      dedicated_building_code,
      dedicated_room_code,
      preferred_building_code,
      preferred_room_code,
      preferred_region_code,
      no_set_day_ind,
      cancel_flag,
      occurrence_identifier,
      abort_flag
    from IGS_PS_USEC_OCCURS_ALL
    where ROWID = X_ROWID
    for update nowait;
     tlinfo c1%rowtype;
begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
    close c1;
    app_exception.raise_exception;
    return;
  end if;
  close c1;
if (( tlinfo.UOO_ID = X_UOO_ID)
  AND ((tlinfo.MONDAY = X_MONDAY)
            OR ((tlinfo.MONDAY is null)
                AND (X_MONDAY is null)))
  AND ((tlinfo.TUESDAY = X_TUESDAY)
            OR ((tlinfo.TUESDAY is null)
                AND (X_TUESDAY is null)))
  AND ((tlinfo.WEDNESDAY = X_WEDNESDAY)
            OR ((tlinfo.WEDNESDAY is null)
                AND (X_WEDNESDAY is null)))
  AND ((tlinfo.THURSDAY = X_THURSDAY)
            OR ((tlinfo.THURSDAY is null)
                AND (X_THURSDAY is null)))
  AND ((tlinfo.FRIDAY = X_FRIDAY)
            OR ((tlinfo.FRIDAY is null)
                AND (X_FRIDAY is null)))
  AND ((tlinfo.SATURDAY = X_SATURDAY)
            OR ((tlinfo.SATURDAY is null)
                AND (X_SATURDAY is null)))
  AND ((tlinfo.SUNDAY = X_SUNDAY)
            OR ((tlinfo.SUNDAY is null)
                AND (X_SUNDAY is null)))
  AND ((tlinfo.START_TIME = X_START_TIME)
            OR ((tlinfo.START_TIME is null)
                AND (X_START_TIME is null)))
  AND ((tlinfo.END_TIME = X_END_TIME)
            OR ((tlinfo.END_TIME is null)
                AND (X_END_TIME is null)))
  AND ((tlinfo.BUILDING_CODE = X_BUILDING_CODE)
            OR ((tlinfo.BUILDING_CODE is null)
                AND (X_BUILDING_CODE is null)))
  AND ((tlinfo.ROOM_CODE = X_ROOM_CODE)
            OR ((tlinfo.ROOM_CODE is null)
                AND (X_ROOM_CODE is null)))
  AND ((tlinfo.SCHEDULE_STATUS = X_SCHEDULE_STATUS)
            OR ((tlinfo.SCHEDULE_STATUS is null)
                AND (X_SCHEDULE_STATUS is null)))
  AND ((trunc(tlinfo.STATUS_LAST_UPDATED) = trunc(X_STATUS_LAST_UPDATED))
            OR ((tlinfo.STATUS_LAST_UPDATED is null)
                AND (X_STATUS_LAST_UPDATED is null)))
  AND ((tlinfo.ERROR_TEXT = X_ERROR_TEXT)
            OR ((tlinfo.ERROR_TEXT is null)
                AND (X_ERROR_TEXT is null)))
  AND ((tlinfo.INSTRUCTOR_ID = X_INSTRUCTOR_ID)
            OR ((tlinfo.INSTRUCTOR_ID is null)
                AND (X_INSTRUCTOR_ID is null)))
  AND ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
            OR ((tlinfo.ATTRIBUTE_CATEGORY is null)
                AND (X_ATTRIBUTE_CATEGORY is null)))
  AND ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
            OR ((tlinfo.ATTRIBUTE1 is null)
                AND (X_ATTRIBUTE1 is null)))
  AND ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
            OR ((tlinfo.ATTRIBUTE2 is null)
                AND (X_ATTRIBUTE2 is null)))
  AND ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
            OR ((tlinfo.ATTRIBUTE3 is null)
                AND (X_ATTRIBUTE3 is null)))
  AND ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
            OR ((tlinfo.ATTRIBUTE4 is null)
                AND (X_ATTRIBUTE4 is null)))
  AND ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
            OR ((tlinfo.ATTRIBUTE5 is null)
                AND (X_ATTRIBUTE5 is null)))
  AND ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
            OR ((tlinfo.ATTRIBUTE6 is null)
                AND (X_ATTRIBUTE6 is null)))
  AND ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
            OR ((tlinfo.ATTRIBUTE7 is null)
                AND (X_ATTRIBUTE7 is null)))
  AND ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
            OR ((tlinfo.ATTRIBUTE8 is null)
                AND (X_ATTRIBUTE8 is null)))
  AND ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
            OR ((tlinfo.ATTRIBUTE9 is null)
                AND (X_ATTRIBUTE9 is null)))
  AND ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
            OR ((tlinfo.ATTRIBUTE10 is null)
                AND (X_ATTRIBUTE10 is null)))
  AND ((tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
            OR ((tlinfo.ATTRIBUTE11 is null)
                AND (X_ATTRIBUTE11 is null)))
  AND ((tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
            OR ((tlinfo.ATTRIBUTE12 is null)
                AND (X_ATTRIBUTE12 is null)))
  AND ((tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
            OR ((tlinfo.ATTRIBUTE13 is null)
                AND (X_ATTRIBUTE13 is null)))
  AND ((tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
            OR ((tlinfo.ATTRIBUTE14 is null)
                AND (X_ATTRIBUTE14 is null)))
  AND ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
            OR ((tlinfo.ATTRIBUTE15 is null)
                AND (X_ATTRIBUTE15 is null)))
  AND ((tlinfo.ATTRIBUTE16 = X_ATTRIBUTE16)
            OR ((tlinfo.ATTRIBUTE16 is null)
                AND (X_ATTRIBUTE16 is null)))
  AND ((tlinfo.ATTRIBUTE17 = X_ATTRIBUTE17)
            OR ((tlinfo.ATTRIBUTE17 is null)
                AND (X_ATTRIBUTE17 is null)))
  AND ((tlinfo.ATTRIBUTE18 = X_ATTRIBUTE18)
            OR ((tlinfo.ATTRIBUTE18 is null)
                AND (X_ATTRIBUTE18 is null)))
  AND ((tlinfo.ATTRIBUTE19 = X_ATTRIBUTE19)
            OR ((tlinfo.ATTRIBUTE19 is null)
                AND (X_ATTRIBUTE19 is null)))
  AND ((tlinfo.ATTRIBUTE20 = X_ATTRIBUTE20)
            OR ((tlinfo.ATTRIBUTE20 is null)
                AND (X_ATTRIBUTE20 is null)))
  AND ((tlinfo.ERROR_TEXT = X_ERROR_TEXT)
            OR ((tlinfo.ERROR_TEXT is null)
                AND (X_ERROR_TEXT is null)))
  AND ((trunc(tlinfo.START_DATE) = trunc(X_START_DATE))
            OR ((tlinfo.START_DATE is null)
                AND (X_START_DATE is null)))
  AND ((trunc(tlinfo.END_DATE) = trunc(X_END_DATE))
            OR ((tlinfo.END_DATE is null)
                AND (X_END_DATE is null)))
  AND ((tlinfo.TO_BE_ANNOUNCED = X_TO_BE_ANNOUNCED)
            OR ((tlinfo.TO_BE_ANNOUNCED is null)
                AND (X_TO_BE_ANNOUNCED is null)))
  AND ((tlinfo.NOTIFY_STATUS = X_NOTIFY_STATUS)
            OR ((tlinfo.NOTIFY_STATUS is null)
                AND (X_NOTIFY_STATUS is null)))
  AND ((tlinfo.INST_NOTIFY_IND = X_INST_NOTIFY_IND)
            OR ((tlinfo.INST_NOTIFY_IND is null)
                AND (X_INST_NOTIFY_IND is null)))
  AND ((tlinfo.dedicated_building_code = X_dedicated_building_code)
            OR ((tlinfo.dedicated_building_code is null)
                AND (X_dedicated_building_code is null)))
  AND ((tlinfo.dedicated_room_code = X_dedicated_room_code)
            OR ((tlinfo.dedicated_room_code is null)
                AND (X_dedicated_room_code is null)))
  AND ((tlinfo.preferred_building_code = X_preferred_building_code)
            OR ((tlinfo.preferred_building_code is null)
                AND (X_preferred_building_code is null)))
  AND ((tlinfo.preferred_room_code = X_preferred_room_code)
            OR ((tlinfo.preferred_room_code is null)
                AND (X_preferred_room_code is null)))
  AND ((tlinfo.preferred_region_code = X_preferred_region_code)
            OR ((tlinfo.preferred_region_code is null)
                AND (X_preferred_region_code is null)))
  AND ((tlinfo.no_set_day_ind = X_no_set_day_ind)
            OR ((tlinfo.no_set_day_ind is null)
                AND (X_no_set_day_ind is null)))
  AND ((tlinfo.cancel_flag = X_cancel_flag)
            OR ((tlinfo.cancel_flag is null)
                AND (X_cancel_flag is null)))

  AND ( tlinfo.occurrence_identifier = x_occurrence_identifier)
  AND ( tlinfo.abort_flag = x_abort_flag)

  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;
 Procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_UNIT_SECTION_OCCURRENCE_ID IN NUMBER,
       x_UOO_ID IN NUMBER,
       x_MONDAY IN VARCHAR2,
       x_TUESDAY IN VARCHAR2,
       x_WEDNESDAY IN VARCHAR2,
       x_THURSDAY IN VARCHAR2,
       x_FRIDAY IN VARCHAR2,
       x_SATURDAY IN VARCHAR2,
       x_SUNDAY IN VARCHAR2,
       x_START_TIME IN DATE,
       x_END_TIME IN DATE,
       x_BUILDING_CODE IN NUMBER,
       x_ROOM_CODE IN NUMBER,
       x_SCHEDULE_STATUS IN VARCHAR2,
       x_STATUS_LAST_UPDATED IN DATE,
       x_INSTRUCTOR_ID IN NUMBER,
       X_ATTRIBUTE_CATEGORY  IN VARCHAR2 ,
       X_ATTRIBUTE1          IN VARCHAR2 ,
       X_ATTRIBUTE2          IN VARCHAR2 ,
       X_ATTRIBUTE3          IN VARCHAR2 ,
       X_ATTRIBUTE4          IN VARCHAR2 ,
       X_ATTRIBUTE5          IN VARCHAR2 ,
       X_ATTRIBUTE6          IN VARCHAR2 ,
       X_ATTRIBUTE7          IN VARCHAR2 ,
       X_ATTRIBUTE8          IN VARCHAR2 ,
       X_ATTRIBUTE9          IN VARCHAR2 ,
       X_ATTRIBUTE10         IN VARCHAR2 ,
       X_ATTRIBUTE11         IN VARCHAR2 ,
       X_ATTRIBUTE12         IN VARCHAR2 ,
       X_ATTRIBUTE13         IN VARCHAR2 ,
       X_ATTRIBUTE14         IN VARCHAR2 ,
       X_ATTRIBUTE15         IN VARCHAR2 ,
       X_ATTRIBUTE16         IN VARCHAR2 ,
       X_ATTRIBUTE17         IN VARCHAR2 ,
       X_ATTRIBUTE18         IN VARCHAR2 ,
       X_ATTRIBUTE19         IN VARCHAR2 ,
       X_ATTRIBUTE20         IN VARCHAR2 ,
       x_ERROR_TEXT IN VARCHAR2,
      X_MODE in VARCHAR2 ,
      X_START_DATE IN DATE,
      X_END_DATE IN DATE,
      X_TO_BE_ANNOUNCED IN VARCHAR2,
      X_INST_NOTIFY_IND IN VARCHAR2 ,
      X_NOTIFY_STATUS IN VARCHAR2 ,
       x_dedicated_building_code IN NUMBER ,
       x_dedicated_room_code IN NUMBER ,
       x_preferred_building_code IN NUMBER ,
       x_preferred_room_code IN NUMBER ,
       x_preferred_region_code IN VARCHAR2,
       x_no_set_day_ind IN VARCHAR2,
       x_cancel_flag IN VARCHAR2 ,
       x_occurrence_identifier IN VARCHAR2,
       x_abort_flag IN VARCHAR2

  ) AS
  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sarakshi        22-Nov-2005     Bug#4589690, error text to be nullified if the status is not ERROR
  smvk            02-Sep-2002     Removed the Default value in the parameters to overcome File.Pkg.22 gscc warnings.
                                  As a part of Build SFCR005_Cleanup_Build (Enhancement Bug # 2531390)
  rgangara        09-May-2001     Added x_NOTIFY_STATUS, x_INST_NOTIFY_IND argument
  Sreenivas.Bonam 28-Aug-2000     Added x_ERROR_TEXT argument
  (reverse chronological order - newest change first)
  ***************************************************************/

     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
     X_REQUEST_ID NUMBER;
     X_PROGRAM_ID NUMBER;
     X_PROGRAM_APPLICATION_ID NUMBER;
     X_PROGRAM_UPDATE_DATE DATE;
 begin
     X_LAST_UPDATE_DATE := SYSDATE;
      if(X_MODE = 'I') then
        X_LAST_UPDATED_BY := 1;
        X_LAST_UPDATE_LOGIN := 0;
      elsif (X_MODE = 'R') then
        X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
        if X_LAST_UPDATED_BY is NULL then
          X_LAST_UPDATED_BY := -1;
        end if;
        X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
        if X_LAST_UPDATE_LOGIN is NULL then
          X_LAST_UPDATE_LOGIN := -1;
        end if;
      else
        FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
        IGS_GE_MSG_STACK.ADD;
        app_exception.raise_exception;
       end if;
   Before_DML(
                p_action=>'UPDATE',
                x_rowid=>X_ROWID,
               x_unit_section_occurrence_id=>X_UNIT_SECTION_OCCURRENCE_ID,
               x_uoo_id=>X_UOO_ID,
               x_monday=>X_MONDAY,
               x_tuesday=>X_TUESDAY,
               x_wednesday=>X_WEDNESDAY,
               x_thursday=>X_THURSDAY,
               x_friday=>X_FRIDAY,
               x_saturday=>X_SATURDAY,
               x_sunday=>X_SUNDAY,
               x_start_time=>X_START_TIME,
               x_end_time=>X_END_TIME,
               x_building_code=>X_BUILDING_CODE,
               x_room_code=>X_ROOM_CODE,
               x_schedule_status=>X_SCHEDULE_STATUS,
               x_status_last_updated=>X_STATUS_LAST_UPDATED,
               x_instructor_id=>X_INSTRUCTOR_ID,
               x_attribute_category=>X_ATTRIBUTE_CATEGORY,
               x_attribute1=>X_ATTRIBUTE1,
               x_attribute2=>X_ATTRIBUTE2,
               x_attribute3=>X_ATTRIBUTE3,
               x_attribute4=>X_ATTRIBUTE4,
               x_attribute5=>X_ATTRIBUTE5,
               x_attribute6=>X_ATTRIBUTE6,
               x_attribute7=>X_ATTRIBUTE7,
               x_attribute8=>X_ATTRIBUTE8,
               x_attribute9=>X_ATTRIBUTE9,
               x_attribute10=>X_ATTRIBUTE10,
               x_attribute11=>X_ATTRIBUTE11,
               x_attribute12=>X_ATTRIBUTE12,
               x_attribute13=>X_ATTRIBUTE13,
               x_attribute14=>X_ATTRIBUTE14,
               x_attribute15=>X_ATTRIBUTE15,
               x_attribute16=>X_ATTRIBUTE16,
               x_attribute17=>X_ATTRIBUTE17,
               x_attribute18=>X_ATTRIBUTE18,
               x_attribute19=>X_ATTRIBUTE19,
               x_attribute20=>X_ATTRIBUTE20,
               x_error_text=>X_ERROR_TEXT,
               x_creation_date=>X_LAST_UPDATE_DATE,
               x_created_by=>X_LAST_UPDATED_BY,
               x_last_update_date=>X_LAST_UPDATE_DATE,
               x_last_updated_by=>X_LAST_UPDATED_BY,
               x_last_update_login=>X_LAST_UPDATE_LOGIN,
               x_start_date => X_START_DATE,
               x_end_date => X_END_DATE,
               x_to_be_announced => X_TO_BE_ANNOUNCED,
               x_inst_notify_ind => X_INST_NOTIFY_IND,
               x_notify_status => X_NOTIFY_STATUS,
               x_dedicated_building_code => x_dedicated_building_code,
               x_dedicated_room_code => x_dedicated_room_code,
               x_preferred_building_code => x_preferred_building_code,
               x_preferred_room_code => x_preferred_room_code,
               x_preferred_region_code => x_preferred_region_code,
               x_no_set_day_ind => x_no_set_day_ind,
               x_cancel_flag => x_cancel_flag,
               x_occurrence_identifier =>x_occurrence_identifier,
               x_abort_flag => x_abort_flag
);

   IF ( X_MODE = 'R' ) THEN
     X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
     X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
     X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
     IF ( X_REQUEST_ID = -1 ) THEN
       X_REQUEST_ID := OLD_REFERENCES.REQUEST_ID;
       X_PROGRAM_ID := OLD_REFERENCES.PROGRAM_ID;
       X_PROGRAM_APPLICATION_ID := OLD_REFERENCES.PROGRAM_APPLICATION_ID;
       X_PROGRAM_UPDATE_DATE := OLD_REFERENCES.PROGRAM_UPDATE_DATE;
     ELSE
       X_PROGRAM_UPDATE_DATE := SYSDATE;
     END IF;
   END IF;

   update IGS_PS_USEC_OCCURS_ALL set
      UOO_ID =  NEW_REFERENCES.UOO_ID,
      MONDAY =  NEW_REFERENCES.MONDAY,
      TUESDAY =  NEW_REFERENCES.TUESDAY,
      WEDNESDAY =  NEW_REFERENCES.WEDNESDAY,
      THURSDAY =  NEW_REFERENCES.THURSDAY,
      FRIDAY =  NEW_REFERENCES.FRIDAY,
      SATURDAY =  NEW_REFERENCES.SATURDAY,
      SUNDAY =  NEW_REFERENCES.SUNDAY,
      START_TIME =  NEW_REFERENCES.START_TIME,
      END_TIME =  NEW_REFERENCES.END_TIME,
      BUILDING_CODE =  NEW_REFERENCES.BUILDING_CODE,
      ROOM_CODE =  NEW_REFERENCES.ROOM_CODE,
      SCHEDULE_STATUS =  NEW_REFERENCES.SCHEDULE_STATUS,
      STATUS_LAST_UPDATED =  NEW_REFERENCES.STATUS_LAST_UPDATED,
      INSTRUCTOR_ID =  NEW_REFERENCES.INSTRUCTOR_ID,
      ATTRIBUTE_CATEGORY =  NEW_REFERENCES.ATTRIBUTE_CATEGORY,
      ATTRIBUTE1 =  NEW_REFERENCES.ATTRIBUTE1,
      ATTRIBUTE2 =  NEW_REFERENCES.ATTRIBUTE2,
      ATTRIBUTE3 =  NEW_REFERENCES.ATTRIBUTE3,
      ATTRIBUTE4 =  NEW_REFERENCES.ATTRIBUTE4,
      ATTRIBUTE5 =  NEW_REFERENCES.ATTRIBUTE5,
      ATTRIBUTE6 =  NEW_REFERENCES.ATTRIBUTE6,
      ATTRIBUTE7 =  NEW_REFERENCES.ATTRIBUTE7,
      ATTRIBUTE8 =  NEW_REFERENCES.ATTRIBUTE8,
      ATTRIBUTE9 =  NEW_REFERENCES.ATTRIBUTE9,
      ATTRIBUTE10 =  NEW_REFERENCES.ATTRIBUTE10,
      ATTRIBUTE11 =  NEW_REFERENCES.ATTRIBUTE11,
      ATTRIBUTE12 =  NEW_REFERENCES.ATTRIBUTE12,
      ATTRIBUTE13 =  NEW_REFERENCES.ATTRIBUTE13,
      ATTRIBUTE14 =  NEW_REFERENCES.ATTRIBUTE14,
      ATTRIBUTE15 =  NEW_REFERENCES.ATTRIBUTE15,
      ATTRIBUTE16 =  NEW_REFERENCES.ATTRIBUTE16,
      ATTRIBUTE17 =  NEW_REFERENCES.ATTRIBUTE17,
      ATTRIBUTE18 =  NEW_REFERENCES.ATTRIBUTE18,
      ATTRIBUTE19 =  NEW_REFERENCES.ATTRIBUTE19,
      ATTRIBUTE20 =  NEW_REFERENCES.ATTRIBUTE20,
      ERROR_TEXT = (SELECT DECODE(NEW_REFERENCES.SCHEDULE_STATUS,'ERROR',NEW_REFERENCES.ERROR_TEXT,NULL) FROM DUAL),
      LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
      REQUEST_ID = X_REQUEST_ID,
      PROGRAM_ID = X_PROGRAM_ID,
      PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
      PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE,
      START_DATE = X_START_DATE,
      END_DATE = X_END_DATE,
      TO_BE_ANNOUNCED = X_TO_BE_ANNOUNCED,
      INST_NOTIFY_IND = NEW_REFERENCES.INST_NOTIFY_IND,
      NOTIFY_STATUS = NEW_REFERENCES.NOTIFY_STATUS,
      dedicated_building_code = new_references.dedicated_building_code,
      dedicated_room_code = new_references.dedicated_room_code,
      preferred_building_code = new_references.preferred_building_code,
      preferred_room_code = new_references.preferred_room_code,
      preferred_region_code = new_references.preferred_region_code,
      no_set_day_ind = new_references.no_set_day_ind,
      cancel_flag = new_references.cancel_flag,
      occurrence_identifier = new_references.occurrence_identifier ,
      abort_flag = new_references.abort_flag

          where ROWID = X_ROWID;
        if (sql%notfound) then
                raise no_data_found;
        end if;

 After_DML (
        p_action => 'UPDATE' ,
        x_rowid => X_ROWID
        );
end UPDATE_ROW;
 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_SECTION_OCCURRENCE_ID IN OUT NOCOPY NUMBER,
       x_UOO_ID IN NUMBER,
       x_MONDAY IN VARCHAR2,
       x_TUESDAY IN VARCHAR2,
       x_WEDNESDAY IN VARCHAR2,
       x_THURSDAY IN VARCHAR2,
       x_FRIDAY IN VARCHAR2,
       x_SATURDAY IN VARCHAR2,
       x_SUNDAY IN VARCHAR2,
       x_START_TIME IN DATE,
       x_END_TIME IN DATE,
       x_BUILDING_CODE IN NUMBER,
       x_ROOM_CODE IN NUMBER,
       x_SCHEDULE_STATUS IN VARCHAR2,
       x_STATUS_LAST_UPDATED IN DATE,
       x_INSTRUCTOR_ID IN NUMBER,
       X_ATTRIBUTE_CATEGORY  IN VARCHAR2 ,
       X_ATTRIBUTE1          IN VARCHAR2 ,
       X_ATTRIBUTE2          IN VARCHAR2 ,
       X_ATTRIBUTE3          IN VARCHAR2 ,
       X_ATTRIBUTE4          IN VARCHAR2 ,
       X_ATTRIBUTE5          IN VARCHAR2 ,
       X_ATTRIBUTE6          IN VARCHAR2 ,
       X_ATTRIBUTE7          IN VARCHAR2 ,
       X_ATTRIBUTE8          IN VARCHAR2 ,
       X_ATTRIBUTE9          IN VARCHAR2 ,
       X_ATTRIBUTE10         IN VARCHAR2 ,
       X_ATTRIBUTE11         IN VARCHAR2 ,
       X_ATTRIBUTE12         IN VARCHAR2 ,
       X_ATTRIBUTE13         IN VARCHAR2 ,
       X_ATTRIBUTE14         IN VARCHAR2 ,
       X_ATTRIBUTE15         IN VARCHAR2 ,
       X_ATTRIBUTE16         IN VARCHAR2 ,
       X_ATTRIBUTE17         IN VARCHAR2 ,
       X_ATTRIBUTE18         IN VARCHAR2 ,
       X_ATTRIBUTE19         IN VARCHAR2 ,
       X_ATTRIBUTE20         IN VARCHAR2 ,
       x_ERROR_TEXT IN VARCHAR2,
      X_MODE in VARCHAR2,
      X_ORG_ID IN NUMBER ,
      X_START_DATE IN DATE,
      X_END_DATE IN DATE,
      X_TO_BE_ANNOUNCED In VARCHAR2 ,
      X_INST_NOTIFY_IND IN VARCHAR2 ,
      X_NOTIFY_STATUS        IN VARCHAR2 ,
       x_dedicated_building_code IN NUMBER ,
       x_dedicated_room_code IN NUMBER ,
       x_preferred_building_code IN NUMBER ,
       x_preferred_room_code IN NUMBER   ,
       x_preferred_region_code IN VARCHAR2,
       x_no_set_day_ind IN VARCHAR2,
       x_cancel_flag IN VARCHAR2  ,
       x_occurrence_identifier IN VARCHAR2,
       x_abort_flag IN VARCHAR2

 ) AS
  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  smvk            02-Sep-2002     Removed the Default value in the parameters to overcome File.Pkg.22 gscc warnings.
                                  As a part of Build SFCR005_Cleanup_Build (Enhancement Bug # 2531390)
  rgangara        09-May-2001     Added x_notify_status, x_inst_notify_ind args
  Sreenivas.Bonam 28-Aug-2000     Added x_error_text argument
  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from IGS_PS_USEC_OCCURS_ALL
             where     UNIT_SECTION_OCCURRENCE_ID= X_UNIT_SECTION_OCCURRENCE_ID
;
begin
        open c1;
                fetch c1 into X_ROWID;
        if (c1%notfound) then
        close c1;
    INSERT_ROW (
      X_ROWID,
       X_UNIT_SECTION_OCCURRENCE_ID,
       X_UOO_ID,
       X_MONDAY,
       X_TUESDAY,
       X_WEDNESDAY,
       X_THURSDAY,
       X_FRIDAY,
       X_SATURDAY,
       X_SUNDAY,
       X_START_TIME,
       X_END_TIME,
       X_BUILDING_CODE,
       X_ROOM_CODE,
       X_SCHEDULE_STATUS,
       X_STATUS_LAST_UPDATED,
       X_INSTRUCTOR_ID,
       X_ATTRIBUTE_CATEGORY,
       X_ATTRIBUTE1,
       X_ATTRIBUTE2,
       X_ATTRIBUTE3,
       X_ATTRIBUTE4,
       X_ATTRIBUTE5,
       X_ATTRIBUTE6,
       X_ATTRIBUTE7,
       X_ATTRIBUTE8,
       X_ATTRIBUTE9,
       X_ATTRIBUTE10,
       X_ATTRIBUTE11,
       X_ATTRIBUTE12,
       X_ATTRIBUTE13,
       X_ATTRIBUTE14,
       X_ATTRIBUTE15,
       X_ATTRIBUTE16,
       X_ATTRIBUTE17,
       X_ATTRIBUTE18,
       X_ATTRIBUTE19,
       X_ATTRIBUTE20,
       X_ERROR_TEXT,
      X_MODE,
      X_ORG_ID,
      X_START_DATE,
      X_END_DATE,
      X_TO_BE_ANNOUNCED,
      X_INST_NOTIFY_IND,
      X_NOTIFY_STATUS,
            x_dedicated_building_code,
      x_dedicated_room_code,
      x_preferred_building_code,
      x_preferred_room_code     ,
      x_preferred_region_code,
      x_no_set_day_ind,
      x_cancel_flag,
      x_occurrence_identifier ,
      x_abort_flag

 );
     return;
        end if;
           close c1;
UPDATE_ROW (
      X_ROWID,
       X_UNIT_SECTION_OCCURRENCE_ID,
       X_UOO_ID,
       X_MONDAY,
       X_TUESDAY,
       X_WEDNESDAY,
       X_THURSDAY,
       X_FRIDAY,
       X_SATURDAY,
       X_SUNDAY,
       X_START_TIME,
       X_END_TIME,
       X_BUILDING_CODE,
       X_ROOM_CODE,
       X_SCHEDULE_STATUS,
       X_STATUS_LAST_UPDATED,
       X_INSTRUCTOR_ID,
       X_ATTRIBUTE_CATEGORY,
       X_ATTRIBUTE1,
       X_ATTRIBUTE2,
       X_ATTRIBUTE3,
       X_ATTRIBUTE4,
       X_ATTRIBUTE5,
       X_ATTRIBUTE6,
       X_ATTRIBUTE7,
       X_ATTRIBUTE8,
       X_ATTRIBUTE9,
       X_ATTRIBUTE10,
       X_ATTRIBUTE11,
       X_ATTRIBUTE12,
       X_ATTRIBUTE13,
       X_ATTRIBUTE14,
       X_ATTRIBUTE15,
       X_ATTRIBUTE16,
       X_ATTRIBUTE17,
       X_ATTRIBUTE18,
       X_ATTRIBUTE19,
       X_ATTRIBUTE20,
       X_ERROR_TEXT,
      X_MODE,
      X_START_DATE,
      X_END_DATE,
      X_TO_BE_ANNOUNCED,
      X_INST_NOTIFY_IND,
      X_NOTIFY_STATUS,
      x_dedicated_building_code,
      x_dedicated_room_code,
      x_preferred_building_code,
      x_preferred_room_code,
      x_preferred_region_code,
      x_no_set_day_ind,
      x_cancel_flag,
      x_occurrence_identifier ,
      x_abort_flag
);
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

begin
Before_DML (
p_action => 'DELETE',
x_rowid => X_ROWID
);

 BeforeRowInsertUpdatedelete1(X_ROWID);
 delete from IGS_PS_USEC_OCCURS_ALL
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;
END igs_ps_usec_occurs_pkg;

/
