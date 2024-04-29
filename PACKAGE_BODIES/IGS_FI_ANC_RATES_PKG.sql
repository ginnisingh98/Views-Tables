--------------------------------------------------------
--  DDL for Package Body IGS_FI_ANC_RATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_ANC_RATES_PKG" AS
/* $Header: IGSSI82B.pls 115.6 2003/02/12 09:35:55 pathipat ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_fi_anc_rates%ROWTYPE;
  new_references igs_fi_anc_rates%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_rate_id                 IN     NUMBER      DEFAULT NULL,
    x_fee_type                          IN     VARCHAR2    DEFAULT NULL,
    x_fee_cal_type                      IN     VARCHAR2    DEFAULT NULL,
    x_fee_ci_sequence_number            IN     NUMBER      DEFAULT NULL,
    x_ancillary_attribute1              IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute2              IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute3              IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute4              IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute5              IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute6              IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute7              IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute8              IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute9              IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute10             IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute11             IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute12             IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute13             IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute14             IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute15             IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_chg_rate                IN     NUMBER      DEFAULT NULL,
    x_enabled_flag                      IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 09-APR-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_ANC_RATES
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF ((cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT'))) THEN
      CLOSE cur_old_ref_values;
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.ancillary_rate_id                 := x_ancillary_rate_id;
    new_references.fee_type                          := x_fee_type;
    new_references.fee_cal_type                      := x_fee_cal_type;
    new_references.fee_ci_sequence_number            := x_fee_ci_sequence_number;
    new_references.ancillary_attribute1              := x_ancillary_attribute1;
    new_references.ancillary_attribute2              := x_ancillary_attribute2;
    new_references.ancillary_attribute3              := x_ancillary_attribute3;
    new_references.ancillary_attribute4              := x_ancillary_attribute4;
    new_references.ancillary_attribute5              := x_ancillary_attribute5;
    new_references.ancillary_attribute6              := x_ancillary_attribute6;
    new_references.ancillary_attribute7              := x_ancillary_attribute7;
    new_references.ancillary_attribute8              := x_ancillary_attribute8;
    new_references.ancillary_attribute9              := x_ancillary_attribute9;
    new_references.ancillary_attribute10             := x_ancillary_attribute10;
    new_references.ancillary_attribute11             := x_ancillary_attribute11;
    new_references.ancillary_attribute12             := x_ancillary_attribute12;
    new_references.ancillary_attribute13             := x_ancillary_attribute13;
    new_references.ancillary_attribute14             := x_ancillary_attribute14;
    new_references.ancillary_attribute15             := x_ancillary_attribute15;
    new_references.ancillary_chg_rate                := x_ancillary_chg_rate;
    new_references.enabled_flag                      := x_enabled_flag;

    IF (p_action = 'UPDATE') THEN
      new_references.creation_date                   := old_references.creation_date;
      new_references.created_by                      := old_references.created_by;
    ELSE
      new_references.creation_date                   := x_creation_date;
      new_references.created_by                      := x_created_by;
    END IF;

    new_references.last_update_date                  := x_last_update_date;
    new_references.last_updated_by                   := x_last_updated_by;
    new_references.last_update_login                 := x_last_update_login;

  END set_column_values;

  PROCEDURE BeforeRowUpdateDelete(p_inserting BOOLEAN DEFAULT FALSE,
                                  p_updating BOOLEAN DEFAULT FALSE,
                                  p_deleting BOOLEAN DEFAULT FALSE) AS

  /*
  ||  Created By : SYKRISHN
  ||  Created On : 20-MAY-2002
  ||  Purpose : Checks if The rate record is used - Prevents deletion and updation
  ||  | Added BeforeRowUpdateDelete as part of bug  2378893
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_impchgs_lines ( cp_anc_att1  IGS_FI_ANC_RATES.ancillary_attribute1%TYPE, cp_anc_att2  IGS_FI_ANC_RATES.ancillary_attribute2%TYPE,
                               cp_anc_att3  IGS_FI_ANC_RATES.ancillary_attribute3%TYPE, cp_anc_att4  IGS_FI_ANC_RATES.ancillary_attribute4%TYPE,
                               cp_anc_att5  IGS_FI_ANC_RATES.ancillary_attribute5%TYPE, cp_anc_att6  IGS_FI_ANC_RATES.ancillary_attribute6%TYPE,
                               cp_anc_att7  IGS_FI_ANC_RATES.ancillary_attribute7%TYPE, cp_anc_att8  IGS_FI_ANC_RATES.ancillary_attribute8%TYPE,
                               cp_anc_att9  IGS_FI_ANC_RATES.ancillary_attribute9%TYPE, cp_anc_att10 IGS_FI_ANC_RATES.ancillary_attribute10%TYPE,
                               cp_anc_att11 IGS_FI_ANC_RATES.ancillary_attribute11%TYPE,cp_anc_att12 IGS_FI_ANC_RATES.ancillary_attribute12%TYPE,
                               cp_anc_att13 IGS_FI_ANC_RATES.ancillary_attribute13%TYPE,cp_anc_att14 IGS_FI_ANC_RATES.ancillary_attribute14%TYPE,
                               cp_anc_att15 IGS_FI_ANC_RATES.ancillary_attribute15%TYPE,cp_fee_type  IGS_FI_F_TYP_CA_INST_LKP_V.fee_type%TYPE,
                               cp_sequence_number   IGS_FI_F_TYP_CA_INST_LKP_V.fee_ci_sequence_number%TYPE,
                               cp_fee_cal_type      IGS_FI_F_TYP_CA_INST_LKP_V.fee_cal_type%TYPE,
			       cp_anc_chg_rate IGS_FI_ANC_RATES.ancillary_chg_rate%TYPE) IS

      SELECT 'x' FROM igs_fi_impchgs_lines i
      WHERE  (ancillary_attribute1  = cp_anc_att1  OR ( ancillary_attribute1 IS NULL AND cp_anc_att1 IS NULL)) AND
             (ancillary_attribute2  = cp_anc_att2  OR ( ancillary_attribute2 IS NULL AND cp_anc_att2 IS NULL)) AND
             (ancillary_attribute3  = cp_anc_att3  OR ( ancillary_attribute3 IS NULL AND cp_anc_att3 IS NULL)) AND
             (ancillary_attribute4  = cp_anc_att4  OR ( ancillary_attribute4 IS NULL AND cp_anc_att4 IS NULL)) AND
             (ancillary_attribute5  = cp_anc_att5  OR ( ancillary_attribute5 IS NULL AND cp_anc_att5 IS NULL)) AND
             (ancillary_attribute6  = cp_anc_att6  OR ( ancillary_attribute6 IS NULL AND cp_anc_att6 IS NULL)) AND
             (ancillary_attribute7  = cp_anc_att7  OR ( ancillary_attribute7 IS NULL AND cp_anc_att7 IS NULL)) AND
             (ancillary_attribute8  = cp_anc_att8  OR ( ancillary_attribute8 IS NULL AND cp_anc_att8 IS NULL)) AND
             (ancillary_attribute9  = cp_anc_att9  OR ( ancillary_attribute9 IS NULL AND cp_anc_att9 IS NULL)) AND
             (ancillary_attribute10 = cp_anc_att10 OR ( ancillary_attribute10 IS NULL AND cp_anc_att10 IS NULL)) AND
             (ancillary_attribute11 = cp_anc_att11 OR ( ancillary_attribute11 IS NULL AND cp_anc_att11 IS NULL)) AND
             (ancillary_attribute12 = cp_anc_att12 OR ( ancillary_attribute12 IS NULL AND cp_anc_att12 IS NULL)) AND
             (ancillary_attribute13 = cp_anc_att13 OR ( ancillary_attribute13 IS NULL AND cp_anc_att13 IS NULL)) AND
             (ancillary_attribute14 = cp_anc_att14 OR ( ancillary_attribute14 IS NULL AND cp_anc_att14 IS NULL)) AND
             (ancillary_attribute15 = cp_anc_att15 OR ( ancillary_attribute15 IS NULL AND cp_anc_att15 IS NULL)) AND
             (transaction_amount = cp_anc_chg_rate)
      AND
      EXISTS
        ( SELECT 'x' from igs_fi_imp_chgs c
          WHERE fee_type = cp_fee_type AND
                fee_ci_sequence_number = cp_sequence_number AND
                fee_cal_type = cp_fee_cal_type AND
                transaction_type = 'ANCILLARY' AND
                c.import_charges_id = i.import_charges_id
        );

    l_bool BOOLEAN DEFAULT FALSE;
    l_var  VARCHAR2(1);
  BEGIN
    l_bool := FALSE;
    IF p_updating THEN
      IF ((new_references.ancillary_attribute1 = old_references.ancillary_attribute1) OR
          (new_references.ancillary_attribute1 IS NULL AND old_references.ancillary_attribute1 IS NULL)) AND
	 ((new_references.ancillary_attribute2 = old_references.ancillary_attribute2) OR
          (new_references.ancillary_attribute2 IS NULL AND old_references.ancillary_attribute2 IS NULL)) AND
	 ((new_references.ancillary_attribute3 = old_references.ancillary_attribute3) OR
          (new_references.ancillary_attribute3 IS NULL AND old_references.ancillary_attribute3 IS NULL)) AND
	 ((new_references.ancillary_attribute4 = old_references.ancillary_attribute4) OR
          (new_references.ancillary_attribute4 IS NULL AND old_references.ancillary_attribute4 IS NULL)) AND
	 ((new_references.ancillary_attribute5 = old_references.ancillary_attribute5) OR
          (new_references.ancillary_attribute5 IS NULL AND old_references.ancillary_attribute5 IS NULL)) AND
    	 ((new_references.ancillary_attribute6 = old_references.ancillary_attribute6) OR
          (new_references.ancillary_attribute6 IS NULL AND old_references.ancillary_attribute6 IS NULL)) AND
	 ((new_references.ancillary_attribute7 = old_references.ancillary_attribute7) OR
          (new_references.ancillary_attribute7 IS NULL AND old_references.ancillary_attribute7 IS NULL)) AND
	 ((new_references.ancillary_attribute8 = old_references.ancillary_attribute8) OR
          (new_references.ancillary_attribute8 IS NULL AND old_references.ancillary_attribute8 IS NULL)) AND
	 ((new_references.ancillary_attribute9 = old_references.ancillary_attribute9) OR
          (new_references.ancillary_attribute9 IS NULL AND old_references.ancillary_attribute9 IS NULL)) AND
	 ((new_references.ancillary_attribute10 = old_references.ancillary_attribute10) OR
          (new_references.ancillary_attribute10 IS NULL AND old_references.ancillary_attribute10 IS NULL)) AND
	 ((new_references.ancillary_attribute11 = old_references.ancillary_attribute11) OR
          (new_references.ancillary_attribute11 IS NULL AND old_references.ancillary_attribute11 IS NULL)) AND
	 ((new_references.ancillary_attribute12 = old_references.ancillary_attribute12) OR
          (new_references.ancillary_attribute12 IS NULL AND old_references.ancillary_attribute12 IS NULL)) AND
	 ((new_references.ancillary_attribute13 = old_references.ancillary_attribute13) OR
          (new_references.ancillary_attribute13 IS NULL AND old_references.ancillary_attribute13 IS NULL)) AND
	 ((new_references.ancillary_attribute14 = old_references.ancillary_attribute14) OR
          (new_references.ancillary_attribute14 IS NULL AND old_references.ancillary_attribute14 IS NULL)) AND
	 ((new_references.ancillary_attribute15 = old_references.ancillary_attribute15) OR
          (new_references.ancillary_attribute15 IS NULL AND old_references.ancillary_attribute15 IS NULL)) AND
	 (new_references.ancillary_chg_rate = old_references.ancillary_chg_rate) THEN
	 l_bool := TRUE;
       END IF;

       OPEN cur_impchgs_lines(old_references.ancillary_attribute1,
                                  old_references.ancillary_attribute2,
                                  old_references.ancillary_attribute3,
                                  old_references.ancillary_attribute4,
                                  old_references.ancillary_attribute5,
                                  old_references.ancillary_attribute6,
                                  old_references.ancillary_attribute7,
				  old_references.ancillary_attribute8,
                                  old_references.ancillary_attribute9,
                                  old_references.ancillary_attribute10,
                                  old_references.ancillary_attribute11,
                                  old_references.ancillary_attribute12,
                                  old_references.ancillary_attribute13,
                                  old_references.ancillary_attribute14,
                                  old_references.ancillary_attribute15,
				  old_references.fee_type,
				  old_references.fee_ci_sequence_number,
				  old_references.fee_cal_type,
				  old_references.ancillary_chg_rate
				  );
       FETCH cur_impchgs_lines INTO l_var;
       IF cur_impchgs_lines%FOUND THEN
         IF NOT l_bool THEN
	   CLOSE cur_impchgs_lines;
	   FND_MESSAGE.SET_NAME('IGS','IGS_FI_IMPCHGS_LINES_EXISTS');
	   --'Update of this record is not allowed since Ancillary Charges exist for these attributes and rate'
	   IGS_GE_MSG_STACK.ADD;
	   APP_EXCEPTION.RAISE_EXCEPTION;
	 END IF;
       END IF;
       CLOSE cur_impchgs_lines;

    ELSIF p_deleting THEN

       OPEN cur_impchgs_lines(old_references.ancillary_attribute1,
                                  old_references.ancillary_attribute2,
                                  old_references.ancillary_attribute3,
                                  old_references.ancillary_attribute4,
                                  old_references.ancillary_attribute5,
                                  old_references.ancillary_attribute6,
                                  old_references.ancillary_attribute7,
				  old_references.ancillary_attribute8,
                                  old_references.ancillary_attribute9,
                                  old_references.ancillary_attribute10,
                                  old_references.ancillary_attribute11,
                                  old_references.ancillary_attribute12,
                                  old_references.ancillary_attribute13,
                                  old_references.ancillary_attribute14,
                                  old_references.ancillary_attribute15,
				  old_references.fee_type,
				  old_references.fee_ci_sequence_number,
				  old_references.fee_cal_type ,
  			          old_references.ancillary_chg_rate
				  );
	         FETCH cur_impchgs_lines INTO l_var;
	         IF cur_impchgs_lines%FOUND THEN
       	  	     CLOSE cur_impchgs_lines;
		     FND_MESSAGE.SET_NAME('IGS','IGS_FI_IMP_CHGS_EXISTS');
		     --'Deletion  of this record is not allowed since Ancillary Charges exist for these attributes'
		     IGS_GE_MSG_STACK.ADD;
		     APP_EXCEPTION.RAISE_EXCEPTION;
		 END IF;
          CLOSE cur_impchgs_lines;
    END IF;

  END BeforeRowUpdateDelete;

  PROCEDURE check_uniqueness AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 09-APR-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.fee_cal_type,
           new_references.fee_ci_sequence_number,
           new_references.fee_type,
           new_references.ancillary_attribute1,
           new_references.ancillary_attribute2,
           new_references.ancillary_attribute3,
           new_references.ancillary_attribute4,
           new_references.ancillary_attribute5,
           new_references.ancillary_attribute6,
           new_references.ancillary_attribute7,
           new_references.ancillary_attribute8,
           new_references.ancillary_attribute9,
           new_references.ancillary_attribute10,
           new_references.ancillary_attribute11,
           new_references.ancillary_attribute12,
           new_references.ancillary_attribute13,
           new_references.ancillary_attribute14,
           new_references.ancillary_attribute15,
           new_references.enabled_flag
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 09-APR-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number) AND
         (old_references.fee_type = new_references.fee_type)) OR
        ((new_references.fee_cal_type IS NULL) OR
         (new_references.fee_ci_sequence_number IS NULL) OR
         (new_references.fee_type IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_f_typ_ca_inst_pkg.get_pk_for_validation (
                new_references.fee_type,
                new_references.fee_cal_type,
                new_references.fee_ci_sequence_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_ancillary_rate_id                 IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 09-APR-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_anc_rates
      WHERE    ancillary_rate_id = x_ancillary_rate_id
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

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

  END get_pk_for_validation;


  FUNCTION get_uk_for_validation (
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_ancillary_attribute1              IN     VARCHAR2,
    x_ancillary_attribute2              IN     VARCHAR2,
    x_ancillary_attribute3              IN     VARCHAR2,
    x_ancillary_attribute4              IN     VARCHAR2,
    x_ancillary_attribute5              IN     VARCHAR2,
    x_ancillary_attribute6              IN     VARCHAR2,
    x_ancillary_attribute7              IN     VARCHAR2,
    x_ancillary_attribute8              IN     VARCHAR2,
    x_ancillary_attribute9              IN     VARCHAR2,
    x_ancillary_attribute10             IN     VARCHAR2,
    x_ancillary_attribute11             IN     VARCHAR2,
    x_ancillary_attribute12             IN     VARCHAR2,
    x_ancillary_attribute13             IN     VARCHAR2,
    x_ancillary_attribute14             IN     VARCHAR2,
    x_ancillary_attribute15             IN     VARCHAR2,
    x_enabled_flag                      IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 09-APR-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_anc_rates
      WHERE    fee_cal_type = x_fee_cal_type
      AND      fee_ci_sequence_number = x_fee_ci_sequence_number
      AND      fee_type = x_fee_type
      AND      ((ancillary_attribute1 = x_ancillary_attribute1) OR (ancillary_attribute1 IS NULL AND x_ancillary_attribute1 IS NULL))
      AND      ((ancillary_attribute2 = x_ancillary_attribute2) OR (ancillary_attribute2 IS NULL AND x_ancillary_attribute2 IS NULL))
      AND      ((ancillary_attribute3 = x_ancillary_attribute3) OR (ancillary_attribute3 IS NULL AND x_ancillary_attribute3 IS NULL))
      AND      ((ancillary_attribute4 = x_ancillary_attribute4) OR (ancillary_attribute4 IS NULL AND x_ancillary_attribute4 IS NULL))
      AND      ((ancillary_attribute5 = x_ancillary_attribute5) OR (ancillary_attribute5 IS NULL AND x_ancillary_attribute5 IS NULL))
      AND      ((ancillary_attribute6 = x_ancillary_attribute6) OR (ancillary_attribute6 IS NULL AND x_ancillary_attribute6 IS NULL))
      AND      ((ancillary_attribute7 = x_ancillary_attribute7) OR (ancillary_attribute7 IS NULL AND x_ancillary_attribute7 IS NULL))
      AND      ((ancillary_attribute8 = x_ancillary_attribute8) OR (ancillary_attribute8 IS NULL AND x_ancillary_attribute8 IS NULL))
      AND      ((ancillary_attribute9 = x_ancillary_attribute9) OR (ancillary_attribute9 IS NULL AND x_ancillary_attribute9 IS NULL))
      AND      ((ancillary_attribute10 = x_ancillary_attribute10) OR (ancillary_attribute10 IS NULL AND x_ancillary_attribute10 IS NULL))
      AND      ((ancillary_attribute11 = x_ancillary_attribute11) OR (ancillary_attribute11 IS NULL AND x_ancillary_attribute11 IS NULL))
      AND      ((ancillary_attribute12 = x_ancillary_attribute12) OR (ancillary_attribute12 IS NULL AND x_ancillary_attribute12 IS NULL))
      AND      ((ancillary_attribute13 = x_ancillary_attribute13) OR (ancillary_attribute13 IS NULL AND x_ancillary_attribute13 IS NULL))
      AND      ((ancillary_attribute14 = x_ancillary_attribute14) OR (ancillary_attribute14 IS NULL AND x_ancillary_attribute14 IS NULL))
      AND      ((ancillary_attribute15 = x_ancillary_attribute15) OR (ancillary_attribute15 IS NULL AND x_ancillary_attribute15 IS NULL))
      AND      ((enabled_flag = x_enabled_flag) OR (enabled_flag IS NULL AND x_enabled_flag IS NULL))
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
        RETURN (true);
        ELSE
       CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;

  END get_uk_for_validation ;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_rate_id                 IN     NUMBER      DEFAULT NULL,
    x_fee_type                          IN     VARCHAR2    DEFAULT NULL,
    x_fee_cal_type                      IN     VARCHAR2    DEFAULT NULL,
    x_fee_ci_sequence_number            IN     NUMBER      DEFAULT NULL,
    x_ancillary_attribute1              IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute2              IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute3              IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute4              IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute5              IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute6              IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute7              IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute8              IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute9              IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute10             IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute11             IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute12             IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute13             IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute14             IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute15             IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_chg_rate                IN     NUMBER      DEFAULT NULL,
    x_enabled_flag                      IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 09-APR-2001
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_ancillary_rate_id,
      x_fee_type,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
      x_ancillary_attribute1,
      x_ancillary_attribute2,
      x_ancillary_attribute3,
      x_ancillary_attribute4,
      x_ancillary_attribute5,
      x_ancillary_attribute6,
      x_ancillary_attribute7,
      x_ancillary_attribute8,
      x_ancillary_attribute9,
      x_ancillary_attribute10,
      x_ancillary_attribute11,
      x_ancillary_attribute12,
      x_ancillary_attribute13,
      x_ancillary_attribute14,
      x_ancillary_attribute15,
      x_ancillary_chg_rate,
      x_enabled_flag,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.ancillary_rate_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_uniqueness;
      check_parent_existance;
      BeforeRowUpdateDelete(p_updating => TRUE);
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.ancillary_rate_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
      BeforeRowUpdateDelete(p_updating => TRUE);
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      BeforeRowUpdateDelete(p_deleting => TRUE);
    ELSIF (p_action = 'DELETE') THEN
      BeforeRowUpdateDelete(p_deleting => TRUE);
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ancillary_rate_id                 IN OUT NOCOPY NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_ancillary_attribute1              IN     VARCHAR2,
    x_ancillary_attribute2              IN     VARCHAR2,
    x_ancillary_attribute3              IN     VARCHAR2,
    x_ancillary_attribute4              IN     VARCHAR2,
    x_ancillary_attribute5              IN     VARCHAR2,
    x_ancillary_attribute6              IN     VARCHAR2,
    x_ancillary_attribute7              IN     VARCHAR2,
    x_ancillary_attribute8              IN     VARCHAR2,
    x_ancillary_attribute9              IN     VARCHAR2,
    x_ancillary_attribute10             IN     VARCHAR2,
    x_ancillary_attribute11             IN     VARCHAR2,
    x_ancillary_attribute12             IN     VARCHAR2,
    x_ancillary_attribute13             IN     VARCHAR2,
    x_ancillary_attribute14             IN     VARCHAR2,
    x_ancillary_attribute15             IN     VARCHAR2,
    x_ancillary_chg_rate                IN     NUMBER,
    x_enabled_flag                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 09-APR-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_fi_anc_rates
      WHERE    ancillary_rate_id                 = x_ancillary_rate_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

  BEGIN

    x_last_update_date := SYSDATE;
    IF (x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (x_mode = 'R') THEN
      x_last_updated_by := fnd_global.user_id;
      IF (x_last_updated_by IS NULL) THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF (x_last_update_login IS NULL) THEN
        x_last_update_login := -1;
      END IF;
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
   SELECT IGS_FI_ANC_RATES_S.NEXTVAL INTO x_ancillary_rate_id FROM DUAL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_ancillary_rate_id                 => x_ancillary_rate_id,
      x_fee_type                          => x_fee_type,
      x_fee_cal_type                      => x_fee_cal_type,
      x_fee_ci_sequence_number            => x_fee_ci_sequence_number,
      x_ancillary_attribute1              => x_ancillary_attribute1,
      x_ancillary_attribute2              => x_ancillary_attribute2,
      x_ancillary_attribute3              => x_ancillary_attribute3,
      x_ancillary_attribute4              => x_ancillary_attribute4,
      x_ancillary_attribute5              => x_ancillary_attribute5,
      x_ancillary_attribute6              => x_ancillary_attribute6,
      x_ancillary_attribute7              => x_ancillary_attribute7,
      x_ancillary_attribute8              => x_ancillary_attribute8,
      x_ancillary_attribute9              => x_ancillary_attribute9,
      x_ancillary_attribute10             => x_ancillary_attribute10,
      x_ancillary_attribute11             => x_ancillary_attribute11,
      x_ancillary_attribute12             => x_ancillary_attribute12,
      x_ancillary_attribute13             => x_ancillary_attribute13,
      x_ancillary_attribute14             => x_ancillary_attribute14,
      x_ancillary_attribute15             => x_ancillary_attribute15,
      x_ancillary_chg_rate                => x_ancillary_chg_rate,
      x_enabled_flag                      => x_enabled_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_fi_anc_rates (
      ancillary_rate_id,
      fee_type,
      fee_cal_type,
      fee_ci_sequence_number,
      ancillary_attribute1,
      ancillary_attribute2,
      ancillary_attribute3,
      ancillary_attribute4,
      ancillary_attribute5,
      ancillary_attribute6,
      ancillary_attribute7,
      ancillary_attribute8,
      ancillary_attribute9,
      ancillary_attribute10,
      ancillary_attribute11,
      ancillary_attribute12,
      ancillary_attribute13,
      ancillary_attribute14,
      ancillary_attribute15,
      ancillary_chg_rate,
      enabled_flag,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.ancillary_rate_id,
      new_references.fee_type,
      new_references.fee_cal_type,
      new_references.fee_ci_sequence_number,
      new_references.ancillary_attribute1,
      new_references.ancillary_attribute2,
      new_references.ancillary_attribute3,
      new_references.ancillary_attribute4,
      new_references.ancillary_attribute5,
      new_references.ancillary_attribute6,
      new_references.ancillary_attribute7,
      new_references.ancillary_attribute8,
      new_references.ancillary_attribute9,
      new_references.ancillary_attribute10,
      new_references.ancillary_attribute11,
      new_references.ancillary_attribute12,
      new_references.ancillary_attribute13,
      new_references.ancillary_attribute14,
      new_references.ancillary_attribute15,
      new_references.ancillary_chg_rate,
      new_references.enabled_flag,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;

    l_rowid := NULL;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_ancillary_rate_id                 IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_ancillary_attribute1              IN     VARCHAR2,
    x_ancillary_attribute2              IN     VARCHAR2,
    x_ancillary_attribute3              IN     VARCHAR2,
    x_ancillary_attribute4              IN     VARCHAR2,
    x_ancillary_attribute5              IN     VARCHAR2,
    x_ancillary_attribute6              IN     VARCHAR2,
    x_ancillary_attribute7              IN     VARCHAR2,
    x_ancillary_attribute8              IN     VARCHAR2,
    x_ancillary_attribute9              IN     VARCHAR2,
    x_ancillary_attribute10             IN     VARCHAR2,
    x_ancillary_attribute11             IN     VARCHAR2,
    x_ancillary_attribute12             IN     VARCHAR2,
    x_ancillary_attribute13             IN     VARCHAR2,
    x_ancillary_attribute14             IN     VARCHAR2,
    x_ancillary_attribute15             IN     VARCHAR2,
    x_ancillary_chg_rate                IN     NUMBER,
    x_enabled_flag                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 09-APR-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        fee_type,
        fee_cal_type,
        fee_ci_sequence_number,
        ancillary_attribute1,
        ancillary_attribute2,
        ancillary_attribute3,
        ancillary_attribute4,
        ancillary_attribute5,
        ancillary_attribute6,
        ancillary_attribute7,
        ancillary_attribute8,
        ancillary_attribute9,
        ancillary_attribute10,
        ancillary_attribute11,
        ancillary_attribute12,
        ancillary_attribute13,
        ancillary_attribute14,
        ancillary_attribute15,
        ancillary_chg_rate,
        enabled_flag
      FROM  igs_fi_anc_rates
      WHERE rowid = x_rowid
      FOR UPDATE NOWAIT;

    tlinfo c1%ROWTYPE;

  BEGIN

    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%notfound) THEN
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      CLOSE c1;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;

    IF (
        (tlinfo.fee_type = x_fee_type)
        AND (tlinfo.fee_cal_type = x_fee_cal_type)
        AND (tlinfo.fee_ci_sequence_number = x_fee_ci_sequence_number)
        AND ((tlinfo.ancillary_attribute1 = x_ancillary_attribute1) OR ((tlinfo.ancillary_attribute1 IS NULL) AND (X_ancillary_attribute1 IS NULL)))
        AND ((tlinfo.ancillary_attribute2 = x_ancillary_attribute2) OR ((tlinfo.ancillary_attribute2 IS NULL) AND (X_ancillary_attribute2 IS NULL)))
        AND ((tlinfo.ancillary_attribute3 = x_ancillary_attribute3) OR ((tlinfo.ancillary_attribute3 IS NULL) AND (X_ancillary_attribute3 IS NULL)))
        AND ((tlinfo.ancillary_attribute4 = x_ancillary_attribute4) OR ((tlinfo.ancillary_attribute4 IS NULL) AND (X_ancillary_attribute4 IS NULL)))
        AND ((tlinfo.ancillary_attribute5 = x_ancillary_attribute5) OR ((tlinfo.ancillary_attribute5 IS NULL) AND (X_ancillary_attribute5 IS NULL)))
        AND ((tlinfo.ancillary_attribute6 = x_ancillary_attribute6) OR ((tlinfo.ancillary_attribute6 IS NULL) AND (X_ancillary_attribute6 IS NULL)))
        AND ((tlinfo.ancillary_attribute7 = x_ancillary_attribute7) OR ((tlinfo.ancillary_attribute7 IS NULL) AND (X_ancillary_attribute7 IS NULL)))
        AND ((tlinfo.ancillary_attribute8 = x_ancillary_attribute8) OR ((tlinfo.ancillary_attribute8 IS NULL) AND (X_ancillary_attribute8 IS NULL)))
        AND ((tlinfo.ancillary_attribute9 = x_ancillary_attribute9) OR ((tlinfo.ancillary_attribute9 IS NULL) AND (X_ancillary_attribute9 IS NULL)))
        AND ((tlinfo.ancillary_attribute10 = x_ancillary_attribute10) OR ((tlinfo.ancillary_attribute10 IS NULL) AND (X_ancillary_attribute10 IS NULL)))
        AND ((tlinfo.ancillary_attribute11 = x_ancillary_attribute11) OR ((tlinfo.ancillary_attribute11 IS NULL) AND (X_ancillary_attribute11 IS NULL)))
        AND ((tlinfo.ancillary_attribute12 = x_ancillary_attribute12) OR ((tlinfo.ancillary_attribute12 IS NULL) AND (X_ancillary_attribute12 IS NULL)))
        AND ((tlinfo.ancillary_attribute13 = x_ancillary_attribute13) OR ((tlinfo.ancillary_attribute13 IS NULL) AND (X_ancillary_attribute13 IS NULL)))
        AND ((tlinfo.ancillary_attribute14 = x_ancillary_attribute14) OR ((tlinfo.ancillary_attribute14 IS NULL) AND (X_ancillary_attribute14 IS NULL)))
        AND ((tlinfo.ancillary_attribute15 = x_ancillary_attribute15) OR ((tlinfo.ancillary_attribute15 IS NULL) AND (X_ancillary_attribute15 IS NULL)))
        AND (tlinfo.ancillary_chg_rate = x_ancillary_chg_rate)
        AND ((tlinfo.enabled_flag = x_enabled_flag) OR ((tlinfo.enabled_flag IS NULL) AND (X_enabled_flag IS NULL)))
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    l_rowid := NULL;
    RETURN;

  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_ancillary_rate_id                 IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_ancillary_attribute1              IN     VARCHAR2,
    x_ancillary_attribute2              IN     VARCHAR2,
    x_ancillary_attribute3              IN     VARCHAR2,
    x_ancillary_attribute4              IN     VARCHAR2,
    x_ancillary_attribute5              IN     VARCHAR2,
    x_ancillary_attribute6              IN     VARCHAR2,
    x_ancillary_attribute7              IN     VARCHAR2,
    x_ancillary_attribute8              IN     VARCHAR2,
    x_ancillary_attribute9              IN     VARCHAR2,
    x_ancillary_attribute10             IN     VARCHAR2,
    x_ancillary_attribute11             IN     VARCHAR2,
    x_ancillary_attribute12             IN     VARCHAR2,
    x_ancillary_attribute13             IN     VARCHAR2,
    x_ancillary_attribute14             IN     VARCHAR2,
    x_ancillary_attribute15             IN     VARCHAR2,
    x_ancillary_chg_rate                IN     NUMBER,
    x_enabled_flag                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 09-APR-2001
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

  BEGIN

    x_last_update_date := SYSDATE;
    IF (X_MODE = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (x_mode = 'R') THEN
      x_last_updated_by := fnd_global.user_id;
      IF x_last_updated_by IS NULL THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF (x_last_update_login IS NULL) THEN
        x_last_update_login := -1;
      END IF;
    ELSE
      fnd_message.set_name( 'FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_ancillary_rate_id                 => x_ancillary_rate_id,
      x_fee_type                          => x_fee_type,
      x_fee_cal_type                      => x_fee_cal_type,
      x_fee_ci_sequence_number            => x_fee_ci_sequence_number,
      x_ancillary_attribute1              => x_ancillary_attribute1,
      x_ancillary_attribute2              => x_ancillary_attribute2,
      x_ancillary_attribute3              => x_ancillary_attribute3,
      x_ancillary_attribute4              => x_ancillary_attribute4,
      x_ancillary_attribute5              => x_ancillary_attribute5,
      x_ancillary_attribute6              => x_ancillary_attribute6,
      x_ancillary_attribute7              => x_ancillary_attribute7,
      x_ancillary_attribute8              => x_ancillary_attribute8,
      x_ancillary_attribute9              => x_ancillary_attribute9,
      x_ancillary_attribute10             => x_ancillary_attribute10,
      x_ancillary_attribute11             => x_ancillary_attribute11,
      x_ancillary_attribute12             => x_ancillary_attribute12,
      x_ancillary_attribute13             => x_ancillary_attribute13,
      x_ancillary_attribute14             => x_ancillary_attribute14,
      x_ancillary_attribute15             => x_ancillary_attribute15,
      x_ancillary_chg_rate                => x_ancillary_chg_rate,
      x_enabled_flag                      => x_enabled_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_fi_anc_rates
      SET
        fee_type                          = new_references.fee_type,
        fee_cal_type                      = new_references.fee_cal_type,
        fee_ci_sequence_number            = new_references.fee_ci_sequence_number,
        ancillary_attribute1              = new_references.ancillary_attribute1,
        ancillary_attribute2              = new_references.ancillary_attribute2,
        ancillary_attribute3              = new_references.ancillary_attribute3,
        ancillary_attribute4              = new_references.ancillary_attribute4,
        ancillary_attribute5              = new_references.ancillary_attribute5,
        ancillary_attribute6              = new_references.ancillary_attribute6,
        ancillary_attribute7              = new_references.ancillary_attribute7,
        ancillary_attribute8              = new_references.ancillary_attribute8,
        ancillary_attribute9              = new_references.ancillary_attribute9,
        ancillary_attribute10             = new_references.ancillary_attribute10,
        ancillary_attribute11             = new_references.ancillary_attribute11,
        ancillary_attribute12             = new_references.ancillary_attribute12,
        ancillary_attribute13             = new_references.ancillary_attribute13,
        ancillary_attribute14             = new_references.ancillary_attribute14,
        ancillary_attribute15             = new_references.ancillary_attribute15,
        ancillary_chg_rate                = new_references.ancillary_chg_rate,
        enabled_flag                      = new_references.enabled_flag,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    l_rowid := NULL;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ancillary_rate_id                 IN OUT NOCOPY NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_ancillary_attribute1              IN     VARCHAR2,
    x_ancillary_attribute2              IN     VARCHAR2,
    x_ancillary_attribute3              IN     VARCHAR2,
    x_ancillary_attribute4              IN     VARCHAR2,
    x_ancillary_attribute5              IN     VARCHAR2,
    x_ancillary_attribute6              IN     VARCHAR2,
    x_ancillary_attribute7              IN     VARCHAR2,
    x_ancillary_attribute8              IN     VARCHAR2,
    x_ancillary_attribute9              IN     VARCHAR2,
    x_ancillary_attribute10             IN     VARCHAR2,
    x_ancillary_attribute11             IN     VARCHAR2,
    x_ancillary_attribute12             IN     VARCHAR2,
    x_ancillary_attribute13             IN     VARCHAR2,
    x_ancillary_attribute14             IN     VARCHAR2,
    x_ancillary_attribute15             IN     VARCHAR2,
    x_ancillary_chg_rate                IN     NUMBER,
    x_enabled_flag                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 09-APR-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_fi_anc_rates
      WHERE    ancillary_rate_id                 = x_ancillary_rate_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_ancillary_rate_id,
        x_fee_type,
        x_fee_cal_type,
        x_fee_ci_sequence_number,
        x_ancillary_attribute1,
        x_ancillary_attribute2,
        x_ancillary_attribute3,
        x_ancillary_attribute4,
        x_ancillary_attribute5,
        x_ancillary_attribute6,
        x_ancillary_attribute7,
        x_ancillary_attribute8,
        x_ancillary_attribute9,
        x_ancillary_attribute10,
        x_ancillary_attribute11,
        x_ancillary_attribute12,
        x_ancillary_attribute13,
        x_ancillary_attribute14,
        x_ancillary_attribute15,
        x_ancillary_chg_rate,
        x_enabled_flag,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_ancillary_rate_id,
      x_fee_type,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
      x_ancillary_attribute1,
      x_ancillary_attribute2,
      x_ancillary_attribute3,
      x_ancillary_attribute4,
      x_ancillary_attribute5,
      x_ancillary_attribute6,
      x_ancillary_attribute7,
      x_ancillary_attribute8,
      x_ancillary_attribute9,
      x_ancillary_attribute10,
      x_ancillary_attribute11,
      x_ancillary_attribute12,
      x_ancillary_attribute13,
      x_ancillary_attribute14,
      x_ancillary_attribute15,
      x_ancillary_chg_rate,
      x_enabled_flag,
      x_mode
    );

    l_rowid := NULL;

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 09-APR-2001
  ||  Purpose : Handles the DELETE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    before_dml (
      p_action => 'DELETE',
      x_rowid => x_rowid
    );

    DELETE FROM igs_fi_anc_rates
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    l_rowid := NULL;

  END delete_row;


END igs_fi_anc_rates_pkg;

/
