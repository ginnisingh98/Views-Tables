--------------------------------------------------------
--  DDL for Package Body IGF_AW_TARGET_GRP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_TARGET_GRP_PKG" AS
/* $Header: IGFWI07B.pls 120.1 2005/09/01 00:10:29 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igf_aw_target_grp_all%ROWTYPE;
  new_references igf_aw_target_grp_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_group_cd                          IN     VARCHAR2    ,
    x_description                       IN     VARCHAR2    ,
    x_max_grant_amt                     IN     NUMBER      ,
    x_max_grant_perct                   IN     NUMBER      ,
    x_max_grant_perct_fact              IN     VARCHAR2    ,
    x_max_loan_amt                      IN     NUMBER      ,
    x_max_loan_perct                    IN     NUMBER      ,
    x_max_loan_perct_fact               IN     VARCHAR2    ,
    x_max_work_amt                      IN     NUMBER      ,
    x_max_work_perct                    IN     NUMBER      ,
    x_max_work_perct_fact               IN     VARCHAR2    ,
    x_max_shelp_amt                     IN     NUMBER      ,
    x_max_shelp_perct                   IN     NUMBER      ,
    x_max_shelp_perct_fact              IN     VARCHAR2    ,
    x_max_gap_amt                       IN     NUMBER      ,
    x_max_gap_perct                     IN     NUMBER      ,
    x_max_gap_perct_fact                IN     VARCHAR2    ,
    x_use_fixed_costs                   IN     VARCHAR2    ,
    x_max_aid_pkg                       IN     NUMBER      ,
    x_max_gift_amt                      IN     NUMBER      ,
    x_max_gift_perct                    IN     NUMBER      ,
    x_max_gift_perct_fact               IN     VARCHAR2    ,
    x_max_schlrshp_amt                  IN     NUMBER      ,
    x_max_schlrshp_perct                IN     NUMBER      ,
    x_max_schlrshp_perct_fact           IN     VARCHAR2    ,
    x_cal_type                          IN     VARCHAR2 ,
    x_sequence_number                   IN     NUMBER   ,
    x_rule_order                        IN     NUMBER      ,
    x_s_rule_call_cd                    IN     VARCHAR2    ,
    x_rul_sequence_number               IN     NUMBER      ,
    x_active                            IN     VARCHAR2    ,
    x_tgrp_id                           IN     NUMBER      ,
    x_adplans_id                        IN     NUMBER,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 13-JUL-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  veramach        06-NOV-2003     FA 125 Multiple distr methods
  ||                                  Added new column adplans_id
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGF_AW_TARGET_GRP_ALL
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
    new_references.group_cd                          := x_group_cd;
    new_references.description                       := x_description;
    new_references.max_grant_amt                     := x_max_grant_amt;
    new_references.max_grant_perct                   := x_max_grant_perct;
    new_references.max_grant_perct_fact              := x_max_grant_perct_fact;
    new_references.max_loan_amt                      := x_max_loan_amt;
    new_references.max_loan_perct                    := x_max_loan_perct;
    new_references.max_loan_perct_fact               := x_max_loan_perct_fact;
    new_references.max_work_amt                      := x_max_work_amt;
    new_references.max_work_perct                    := x_max_work_perct;
    new_references.max_work_perct_fact               := x_max_work_perct_fact;
    new_references.max_shelp_amt                     := x_max_shelp_amt;
    new_references.max_shelp_perct                   := x_max_shelp_perct;
    new_references.max_shelp_perct_fact              := x_max_shelp_perct_fact;
    new_references.max_gap_amt                       := x_max_gap_amt;
    new_references.max_gap_perct                     := x_max_gap_perct;
    new_references.max_gap_perct_fact                := x_max_gap_perct_fact;
    new_references.use_fixed_costs                   := x_use_fixed_costs;
    new_references.max_aid_pkg                       := x_max_aid_pkg;
    new_references.max_gift_amt                      := x_max_gift_amt;
    new_references.max_gift_perct                    := x_max_gift_perct;
    new_references.max_gift_perct_fact               := x_max_gift_perct_fact;
    new_references.max_schlrshp_amt                  := x_max_schlrshp_amt;
    new_references.max_schlrshp_perct                := x_max_schlrshp_perct;
    new_references.max_schlrshp_perct_fact           := x_max_schlrshp_perct_fact;
    new_references.cal_type                          := x_cal_type;
    new_references.sequence_number                   := x_sequence_number;
    new_references.rule_order                        := x_rule_order;
    new_references.s_rule_call_cd                    := x_s_rule_call_cd;
    new_references.rul_sequence_number               := x_rul_sequence_number;
    new_references.active                            := x_active;
    new_references.tgrp_id                           := x_tgrp_id;
    new_references.adplans_id                        := x_adplans_id;

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

  PROCEDURE check_parent_existance AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created:
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  BEGIN
    IF ((old_references.adplans_id = new_references.adplans_id)) OR
       ((new_references.adplans_id IS NULL)) THEN
      NULL;
    ELSIF NOT igf_aw_awd_dist_plans_pkg.get_pk_for_validation(new_references.adplans_id) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
  END check_parent_existance;

  PROCEDURE check_uniqueness AS
  /*
  ||  Created By : prchandr
  ||  Created On : 13-JUL-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.group_cd,
           new_references.cal_type,
           new_references.sequence_number,
           new_references.org_id
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_child_existance IS
  /*
  ||  Created By : prchandr
  ||  Created On : 13-JUL-2001
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || adhawan         24-oct-2002       igf_aw_awd_frml_pkg.get_ufk_igf_aw_target_grp removed
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igf_aw_awd_frml_det_pkg.get_ufk_igf_aw_target_grp (
      old_references.group_cd,
      old_references.cal_type,
      old_references.sequence_number
    );

  END check_child_existance;

  FUNCTION get_pk_for_validation (
    x_tgrp_id                           IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : prchandr
  ||  Created On : 13-JUL-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_target_grp_all
      WHERE    tgrp_id = x_tgrp_id
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
    x_group_cd                          IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_org_id                            IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : prchandr
  ||  Created On : 13-JUL-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History : 2166848
  ||  Who             When            What
  ||  adhawan         23-feb-02'      made the UNIQUE key incasesensitive by adding the UPPER clause
  ||  (reverse chronological order - newest change first)
  */
  -- Change History:
  -- Who         When            What
  -- ridas       31-Aug-2005     Removed the UPPER function from parameter x_group_cd in Cursor 'cur_rowid'.

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_target_grp
      WHERE    group_cd = x_group_cd
      AND      cal_type = x_cal_type
      AND      sequence_number = x_sequence_number
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid))
      FOR UPDATE NOWAIT;

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
    x_rowid                             IN     VARCHAR2    ,
    x_group_cd                          IN     VARCHAR2    ,
    x_description                       IN     VARCHAR2    ,
    x_max_grant_amt                     IN     NUMBER      ,
    x_max_grant_perct                   IN     NUMBER      ,
    x_max_grant_perct_fact              IN     VARCHAR2    ,
    x_max_loan_amt                      IN     NUMBER      ,
    x_max_loan_perct                    IN     NUMBER      ,
    x_max_loan_perct_fact               IN     VARCHAR2    ,
    x_max_work_amt                      IN     NUMBER      ,
    x_max_work_perct                    IN     NUMBER      ,
    x_max_work_perct_fact               IN     VARCHAR2    ,
    x_max_shelp_amt                     IN     NUMBER      ,
    x_max_shelp_perct                   IN     NUMBER      ,
    x_max_shelp_perct_fact              IN     VARCHAR2    ,
    x_max_gap_amt                       IN     NUMBER      ,
    x_max_gap_perct                     IN     NUMBER      ,
    x_max_gap_perct_fact                IN     VARCHAR2    ,
    x_use_fixed_costs                   IN     VARCHAR2    ,
    x_max_aid_pkg                       IN     NUMBER      ,
    x_max_gift_amt                      IN     NUMBER      ,
    x_max_gift_perct                    IN     NUMBER      ,
    x_max_gift_perct_fact               IN     VARCHAR2    ,
    x_max_schlrshp_amt                  IN     NUMBER      ,
    x_max_schlrshp_perct                IN     NUMBER      ,
    x_max_schlrshp_perct_fact           IN     VARCHAR2    ,
    x_cal_type                          IN     VARCHAR2 ,
    x_sequence_number                   IN     NUMBER   ,
    x_rule_order                        IN     NUMBER      ,
    x_s_rule_call_cd                    IN     VARCHAR2    ,
    x_rul_sequence_number               IN     NUMBER      ,
    x_active                            IN     VARCHAR2    ,
    x_tgrp_id                           IN     NUMBER      ,
    x_adplans_id                        IN     NUMBER,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 13-JUL-2001
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  veramach        06-NOV-2003     FA 125 Multiple distr methods
  ||                                  Added new column adplans_id
  ||  kpadiyar        11-SEP-2001     Removed the call to check_uk_child_existance
  ||                                  from the Check for the UPDATE and VALIDATE_UPDATE
  ||                                  call which is not required.
  ||                                  Bug No # 1978576 - WRONG ERROR IS PROMPTING OUT NOCOPY
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_group_cd,
      x_description,
      x_max_grant_amt,
      x_max_grant_perct,
      x_max_grant_perct_fact,
      x_max_loan_amt,
      x_max_loan_perct,
      x_max_loan_perct_fact,
      x_max_work_amt,
      x_max_work_perct,
      x_max_work_perct_fact,
      x_max_shelp_amt,
      x_max_shelp_perct,
      x_max_shelp_perct_fact,
      x_max_gap_amt,
      x_max_gap_perct,
      x_max_gap_perct_fact,
      x_use_fixed_costs,
      x_max_aid_pkg,
      x_max_gift_amt,
      x_max_gift_perct ,
      x_max_gift_perct_fact,
      x_max_schlrshp_amt,
      x_max_schlrshp_perct ,
      x_max_schlrshp_perct_fact,
      x_cal_type,
      x_sequence_number,
      x_rule_order,
      x_s_rule_call_cd,
      x_rul_sequence_number,
      x_active,
      x_tgrp_id,
      x_adplans_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.tgrp_id
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
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.tgrp_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;

  PROCEDURE get_fk_igf_aw_awd_dist_plans(
                                         x_adplans_id IN NUMBER
                                        ) AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 06-NOV-2003
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_awd_frml_det_all
      WHERE   ((adplans_id = x_adplans_id));

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_AW_TGRP_ADPLANS_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_aw_awd_dist_plans;

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_group_cd                          IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_max_grant_amt                     IN     NUMBER,
    x_max_grant_perct                   IN     NUMBER,
    x_max_grant_perct_fact              IN     VARCHAR2,
    x_max_loan_amt                      IN     NUMBER,
    x_max_loan_perct                    IN     NUMBER,
    x_max_loan_perct_fact               IN     VARCHAR2,
    x_max_work_amt                      IN     NUMBER,
    x_max_work_perct                    IN     NUMBER,
    x_max_work_perct_fact               IN     VARCHAR2,
    x_max_shelp_amt                     IN     NUMBER,
    x_max_shelp_perct                   IN     NUMBER,
    x_max_shelp_perct_fact              IN     VARCHAR2,
    x_max_gap_amt                       IN     NUMBER,
    x_max_gap_perct                     IN     NUMBER,
    x_max_gap_perct_fact                IN     VARCHAR2,
    x_use_fixed_costs                   IN     VARCHAR2,
    x_max_aid_pkg                       IN     NUMBER,
    x_max_gift_amt                      IN     NUMBER,
    x_max_gift_perct                    IN     NUMBER,
    x_max_gift_perct_fact               IN     VARCHAR2,
    x_max_schlrshp_amt                  IN     NUMBER,
    x_max_schlrshp_perct                IN     NUMBER,
    x_max_schlrshp_perct_fact           IN     VARCHAR2,
     x_cal_type                          IN     VARCHAR2 ,
    x_sequence_number                   IN     NUMBER   ,
    x_rule_order                        IN     NUMBER,
    x_s_rule_call_cd                    IN     VARCHAR2,
    x_rul_sequence_number               IN     NUMBER,
    x_active                            IN     VARCHAR2,
    x_tgrp_id                           IN OUT NOCOPY NUMBER,
    x_mode                              IN     VARCHAR2,
    x_adplans_id                        IN     NUMBER
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 13-JUL-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  veramach        06-NOV-2003     FA 125 Multiple distr methods
  ||                                  Added new column adplans_id
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_aw_target_grp_all
      WHERE    tgrp_id                           = x_tgrp_id;

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

    SELECT    igf_aw_target_grp_all_s.NEXTVAL
    INTO      x_tgrp_id
    FROM      dual;

    new_references.org_id := igs_ge_gen_003.get_org_id;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_group_cd                          => x_group_cd,
      x_description                       => x_description,
      x_max_grant_amt                     => x_max_grant_amt,
      x_max_grant_perct                   => x_max_grant_perct,
      x_max_grant_perct_fact              => x_max_grant_perct_fact,
      x_max_loan_amt                      => x_max_loan_amt,
      x_max_loan_perct                    => x_max_loan_perct,
      x_max_loan_perct_fact               => x_max_loan_perct_fact,
      x_max_work_amt                      => x_max_work_amt,
      x_max_work_perct                    => x_max_work_perct,
      x_max_work_perct_fact               => x_max_work_perct_fact,
      x_max_shelp_amt                     => x_max_shelp_amt,
      x_max_shelp_perct                   => x_max_shelp_perct,
      x_max_shelp_perct_fact              => x_max_shelp_perct_fact,
      x_max_gap_amt                       => x_max_gap_amt,
      x_max_gap_perct                     => x_max_gap_perct,
      x_max_gap_perct_fact                => x_max_gap_perct_fact,
      x_use_fixed_costs                   => x_use_fixed_costs,
      x_max_aid_pkg                       => x_max_aid_pkg,
      x_max_gift_amt                      => x_max_gift_amt,
      x_max_gift_perct                    => x_max_gift_perct,
      x_max_gift_perct_fact               => x_max_gift_perct_fact,
      x_max_schlrshp_amt                  => x_max_schlrshp_amt,
      x_max_schlrshp_perct                => x_max_schlrshp_perct,
      x_max_schlrshp_perct_fact           => x_max_schlrshp_perct_fact,
      x_cal_type                        => x_cal_type,
      x_sequence_number                   => x_sequence_number,
      x_rule_order                        => x_rule_order,
      x_s_rule_call_cd                    => x_s_rule_call_cd,
      x_rul_sequence_number               => x_rul_sequence_number,
      x_active                            => x_active,
      x_tgrp_id                           => x_tgrp_id,
      x_adplans_id                        => x_adplans_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igf_aw_target_grp_all (
      group_cd,
      description,
      max_grant_amt,
      max_grant_perct,
      max_grant_perct_fact,
      max_loan_amt,
      max_loan_perct,
      max_loan_perct_fact,
      max_work_amt,
      max_work_perct,
      max_work_perct_fact,
      max_shelp_amt,
      max_shelp_perct,
      max_shelp_perct_fact,
      max_gap_amt,
      max_gap_perct,
      max_gap_perct_fact,
      use_fixed_costs,
      max_aid_pkg,
      max_gift_amt,
      max_gift_perct,
      max_gift_perct_fact,
      max_schlrshp_amt,
      max_schlrshp_perct,
      max_schlrshp_perct_fact,
      cal_type,
      sequence_number,
      rule_order,
      s_rule_call_cd,
      rul_sequence_number,
      active,
      org_id,
      tgrp_id,
      adplans_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.group_cd,
      new_references.description,
      new_references.max_grant_amt,
      new_references.max_grant_perct,
      new_references.max_grant_perct_fact,
      new_references.max_loan_amt,
      new_references.max_loan_perct,
      new_references.max_loan_perct_fact,
      new_references.max_work_amt,
      new_references.max_work_perct,
      new_references.max_work_perct_fact,
      new_references.max_shelp_amt,
      new_references.max_shelp_perct,
      new_references.max_shelp_perct_fact,
      new_references.max_gap_amt,
      new_references.max_gap_perct,
      new_references.max_gap_perct_fact,
      new_references.use_fixed_costs,
      new_references.max_aid_pkg,
      new_references.max_gift_amt,
      new_references.max_gift_perct,
      new_references.max_gift_perct_fact,
      new_references.max_schlrshp_amt,
      new_references.max_schlrshp_perct,
      new_references.max_schlrshp_perct_fact,
     new_references.cal_type,
      new_references.sequence_number,
      new_references.rule_order,
      new_references.s_rule_call_cd,
      new_references.rul_sequence_number,
      new_references.active,
      new_references.org_id,
      new_references.tgrp_id,
      new_references.adplans_id,
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

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_group_cd                          IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_max_grant_amt                     IN     NUMBER,
    x_max_grant_perct                   IN     NUMBER,
    x_max_grant_perct_fact              IN     VARCHAR2,
    x_max_loan_amt                      IN     NUMBER,
    x_max_loan_perct                    IN     NUMBER,
    x_max_loan_perct_fact               IN     VARCHAR2,
    x_max_work_amt                      IN     NUMBER,
    x_max_work_perct                    IN     NUMBER,
    x_max_work_perct_fact               IN     VARCHAR2,
    x_max_shelp_amt                     IN     NUMBER,
    x_max_shelp_perct                   IN     NUMBER,
    x_max_shelp_perct_fact              IN     VARCHAR2,
    x_max_gap_amt                       IN     NUMBER,
    x_max_gap_perct                     IN     NUMBER,
    x_max_gap_perct_fact                IN     VARCHAR2,
    x_use_fixed_costs                   IN     VARCHAR2,
    x_max_aid_pkg                       IN     NUMBER,
    x_max_gift_amt                      IN     NUMBER,
    x_max_gift_perct                    IN     NUMBER,
    x_max_gift_perct_fact               IN     VARCHAR2,
    x_max_schlrshp_amt                  IN     NUMBER,
    x_max_schlrshp_perct                IN     NUMBER,
    x_max_schlrshp_perct_fact           IN     VARCHAR2,
     x_cal_type                          IN     VARCHAR2 ,
    x_sequence_number                   IN     NUMBER   ,
    x_rule_order                        IN     NUMBER,
    x_s_rule_call_cd                    IN     VARCHAR2,
    x_rul_sequence_number               IN     NUMBER,
    x_active                            IN     VARCHAR2,
    x_tgrp_id                           IN     NUMBER,
    x_adplans_id                        IN     NUMBER
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 13-JUL-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  veramach        06-NOV-2003     FA 125 Multiple distr methods
  ||                                  Added new column adplans_id
  */
    CURSOR c1 IS
      SELECT
        group_cd,
        description,
        max_grant_amt,
        max_grant_perct,
        max_grant_perct_fact,
        max_loan_amt,
        max_loan_perct,
        max_loan_perct_fact,
        max_work_amt,
        max_work_perct,
        max_work_perct_fact,
        max_shelp_amt,
        max_shelp_perct,
        max_shelp_perct_fact,
        max_gap_amt,
        max_gap_perct,
        max_gap_perct_fact,
        use_fixed_costs,
        max_aid_pkg,
        max_gift_amt,
        max_gift_perct ,
        max_gift_perct_fact,
        max_schlrshp_amt,
        max_schlrshp_perct ,
        max_schlrshp_perct_fact,
        cal_type,
        sequence_number,
        rule_order,
        s_rule_call_cd,
        rul_sequence_number,
        active,
        adplans_id
      FROM  igf_aw_target_grp_all
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
        (tlinfo.group_cd = x_group_cd)
        AND (tlinfo.description = x_description)
        AND ((tlinfo.max_grant_amt = x_max_grant_amt) OR ((tlinfo.max_grant_amt IS NULL) AND (X_max_grant_amt IS NULL)))
        AND ((tlinfo.max_grant_perct = x_max_grant_perct) OR ((tlinfo.max_grant_perct IS NULL) AND (X_max_grant_perct IS NULL)))
        AND ((tlinfo.max_grant_perct_fact = x_max_grant_perct_fact) OR ((tlinfo.max_grant_perct_fact IS NULL) AND (X_max_grant_perct_fact IS NULL)))
        AND ((tlinfo.max_loan_amt = x_max_loan_amt) OR ((tlinfo.max_loan_amt IS NULL) AND (X_max_loan_amt IS NULL)))
        AND ((tlinfo.max_loan_perct = x_max_loan_perct) OR ((tlinfo.max_loan_perct IS NULL) AND (X_max_loan_perct IS NULL)))
        AND ((tlinfo.max_loan_perct_fact = x_max_loan_perct_fact) OR ((tlinfo.max_loan_perct_fact IS NULL) AND (X_max_loan_perct_fact IS NULL)))
        AND ((tlinfo.max_work_amt = x_max_work_amt) OR ((tlinfo.max_work_amt IS NULL) AND (X_max_work_amt IS NULL)))
        AND ((tlinfo.max_work_perct = x_max_work_perct) OR ((tlinfo.max_work_perct IS NULL) AND (X_max_work_perct IS NULL)))
        AND ((tlinfo.max_work_perct_fact = x_max_work_perct_fact) OR ((tlinfo.max_work_perct_fact IS NULL) AND (X_max_work_perct_fact IS NULL)))
        AND ((tlinfo.max_shelp_amt = x_max_shelp_amt) OR ((tlinfo.max_shelp_amt IS NULL) AND (X_max_shelp_amt IS NULL)))
        AND ((tlinfo.max_shelp_perct = x_max_shelp_perct) OR ((tlinfo.max_shelp_perct IS NULL) AND (X_max_shelp_perct IS NULL)))
        AND ((tlinfo.max_shelp_perct_fact = x_max_shelp_perct_fact) OR ((tlinfo.max_shelp_perct_fact IS NULL) AND (X_max_shelp_perct_fact IS NULL)))
        AND ((tlinfo.max_gap_amt = x_max_gap_amt) OR ((tlinfo.max_gap_amt IS NULL) AND (X_max_gap_amt IS NULL)))
        AND ((tlinfo.max_gap_perct = x_max_gap_perct) OR ((tlinfo.max_gap_perct IS NULL) AND (X_max_gap_perct IS NULL)))
        AND ((tlinfo.max_gap_perct_fact = x_max_gap_perct_fact) OR ((tlinfo.max_gap_perct_fact IS NULL) AND (X_max_gap_perct_fact IS NULL)))
        AND ((tlinfo.use_fixed_costs = x_use_fixed_costs) OR ((tlinfo.use_fixed_costs IS NULL) AND (X_use_fixed_costs IS NULL)))
        AND ((tlinfo.max_aid_pkg = x_max_aid_pkg) OR ((tlinfo.max_aid_pkg IS NULL) AND (X_max_aid_pkg IS NULL)))
--        AND ((tlinfo.max_gift_amt = x_max_gift_amt) OR ((tlinfo.max_gift_amt IS NULL) AND (X_max_gift_amt IS NULL)))
--        AND ((tlinfo.max_gift_perct = x_max_gift_perct) OR ((tlinfo.max_gift_perct IS NULL) AND (X_max_gift_perct IS NULL)))
--        AND ((tlinfo.max_gift_perct_fact = x_max_gift_perct_fact) OR ((tlinfo.max_gift_perct_fact IS NULL) AND (X_max_gift_perct_fact IS NULL)))
--        AND ((tlinfo.max_schlrshp_amt = x_max_schlrshp_amt) OR ((tlinfo.max_schlrshp_amt IS NULL) AND (X_max_schlrshp_amt IS NULL)))
--        AND ((tlinfo.max_schlrshp_perct = x_max_schlrshp_perct) OR ((tlinfo.max_schlrshp_perct IS NULL) AND (X_max_schlrshp_perct IS NULL)))
--        AND ((tlinfo.max_schlrshp_perct_fact = x_max_schlrshp_perct_fact) OR ((tlinfo.max_schlrshp_perct_fact IS NULL) AND (X_max_schlrshp_perct_fact IS NULL)))
--        AND ((tlinfo.rule_order = x_rule_order) OR ((tlinfo.rule_order IS NULL) AND (X_rule_order IS NULL)))
--        AND ((tlinfo.s_rule_call_cd = x_s_rule_call_cd) OR ((tlinfo.s_rule_call_cd IS NULL) AND (X_s_rule_call_cd IS NULL)))
--        AND ((tlinfo.rul_sequence_number = x_rul_sequence_number) OR ((tlinfo.rul_sequence_number IS NULL) AND (X_rul_sequence_number IS NULL)))
        AND (tlinfo.active = x_active)
        AND ((tlinfo.adplans_id = x_adplans_id) OR ((tlinfo.adplans_id IS NULL) AND (x_adplans_id IS NULL)))
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    RETURN;

  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_group_cd                          IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_max_grant_amt                     IN     NUMBER,
    x_max_grant_perct                   IN     NUMBER,
    x_max_grant_perct_fact              IN     VARCHAR2,
    x_max_loan_amt                      IN     NUMBER,
    x_max_loan_perct                    IN     NUMBER,
    x_max_loan_perct_fact               IN     VARCHAR2,
    x_max_work_amt                      IN     NUMBER,
    x_max_work_perct                    IN     NUMBER,
    x_max_work_perct_fact               IN     VARCHAR2,
    x_max_shelp_amt                     IN     NUMBER,
    x_max_shelp_perct                   IN     NUMBER,
    x_max_shelp_perct_fact              IN     VARCHAR2,
    x_max_gap_amt                       IN     NUMBER,
    x_max_gap_perct                     IN     NUMBER,
    x_max_gap_perct_fact                IN     VARCHAR2,
    x_use_fixed_costs                   IN     VARCHAR2,
    x_max_aid_pkg                       IN     NUMBER,
    x_max_gift_amt                      IN     NUMBER,
    x_max_gift_perct                    IN     NUMBER,
    x_max_gift_perct_fact               IN     VARCHAR2,
    x_max_schlrshp_amt                  IN     NUMBER,
    x_max_schlrshp_perct                IN     NUMBER,
    x_max_schlrshp_perct_fact           IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2 ,
    x_sequence_number                   IN     NUMBER   ,
    x_rule_order                        IN     NUMBER,
    x_s_rule_call_cd                    IN     VARCHAR2,
    x_rul_sequence_number               IN     NUMBER,
    x_active                            IN     VARCHAR2,
    x_tgrp_id                           IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_adplans_id                        IN     NUMBER
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 13-JUL-2001
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  veramach        06-NOV-2003     FA 125 Multiple distr methods
  ||                                  Added new column adplans_id
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
      x_group_cd                          => x_group_cd,
      x_description                       => x_description,
      x_max_grant_amt                     => x_max_grant_amt,
      x_max_grant_perct                   => x_max_grant_perct,
      x_max_grant_perct_fact              => x_max_grant_perct_fact,
      x_max_loan_amt                      => x_max_loan_amt,
      x_max_loan_perct                    => x_max_loan_perct,
      x_max_loan_perct_fact               => x_max_loan_perct_fact,
      x_max_work_amt                      => x_max_work_amt,
      x_max_work_perct                    => x_max_work_perct,
      x_max_work_perct_fact               => x_max_work_perct_fact,
      x_max_shelp_amt                     => x_max_shelp_amt,
      x_max_shelp_perct                   => x_max_shelp_perct,
      x_max_shelp_perct_fact              => x_max_shelp_perct_fact,
      x_max_gap_amt                       => x_max_gap_amt,
      x_max_gap_perct                     => x_max_gap_perct,
      x_max_gap_perct_fact                => x_max_gap_perct_fact,
      x_use_fixed_costs                   => x_use_fixed_costs,
      x_max_aid_pkg                       => x_max_aid_pkg,
      x_max_gift_amt                      => x_max_gift_amt,
      x_max_gift_perct                    => x_max_gift_perct,
      x_max_gift_perct_fact               => x_max_gift_perct_fact,
      x_max_schlrshp_amt                  => x_max_schlrshp_amt,
      x_max_schlrshp_perct                => x_max_schlrshp_perct,
      x_max_schlrshp_perct_fact           => x_max_schlrshp_perct_fact,
      x_cal_type                        => x_cal_type,
      x_sequence_number                 => x_sequence_number,
      x_rule_order                        => x_rule_order,
      x_s_rule_call_cd                    => x_s_rule_call_cd,
      x_rul_sequence_number               => x_rul_sequence_number,
      x_active                            => x_active,
      x_tgrp_id                           => x_tgrp_id,
      x_adplans_id                        => x_adplans_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igf_aw_target_grp_all
      SET
        group_cd                          = new_references.group_cd,
        description                       = new_references.description,
        max_grant_amt                     = new_references.max_grant_amt,
        max_grant_perct                   = new_references.max_grant_perct,
        max_grant_perct_fact              = new_references.max_grant_perct_fact,
        max_loan_amt                      = new_references.max_loan_amt,
        max_loan_perct                    = new_references.max_loan_perct,
        max_loan_perct_fact               = new_references.max_loan_perct_fact,
        max_work_amt                      = new_references.max_work_amt,
        max_work_perct                    = new_references.max_work_perct,
        max_work_perct_fact               = new_references.max_work_perct_fact,
        max_shelp_amt                     = new_references.max_shelp_amt,
        max_shelp_perct                   = new_references.max_shelp_perct,
        max_shelp_perct_fact              = new_references.max_shelp_perct_fact,
        max_gap_amt                       = new_references.max_gap_amt,
        max_gap_perct                     = new_references.max_gap_perct,
        max_gap_perct_fact                = new_references.max_gap_perct_fact,
        use_fixed_costs                   = new_references.use_fixed_costs,
        max_aid_pkg                       = new_references.max_aid_pkg,
        max_gift_amt                      = new_references.max_gift_amt,
        max_gift_perct                    = new_references.max_gift_perct,
        max_gift_perct_fact               = new_references.max_gift_perct_fact,
        max_schlrshp_amt                  = new_references.max_schlrshp_amt,
        max_schlrshp_perct                = new_references.max_schlrshp_perct,
        max_schlrshp_perct_fact           = new_references.max_schlrshp_perct_fact,
        cal_type                          = new_references.cal_type,
        sequence_number                   = new_references.sequence_number,
        rule_order                        = new_references.rule_order,
        s_rule_call_cd                    = new_references.s_rule_call_cd,
        rul_sequence_number               = new_references.rul_sequence_number,
        active                            = new_references.active,
        adplans_id                        = new_references.adplans_id,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_group_cd                          IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_max_grant_amt                     IN     NUMBER,
    x_max_grant_perct                   IN     NUMBER,
    x_max_grant_perct_fact              IN     VARCHAR2,
    x_max_loan_amt                      IN     NUMBER,
    x_max_loan_perct                    IN     NUMBER,
    x_max_loan_perct_fact               IN     VARCHAR2,
    x_max_work_amt                      IN     NUMBER,
    x_max_work_perct                    IN     NUMBER,
    x_max_work_perct_fact               IN     VARCHAR2,
    x_max_shelp_amt                     IN     NUMBER,
    x_max_shelp_perct                   IN     NUMBER,
    x_max_shelp_perct_fact              IN     VARCHAR2,
    x_max_gap_amt                       IN     NUMBER,
    x_max_gap_perct                     IN     NUMBER,
    x_max_gap_perct_fact                IN     VARCHAR2,
    x_use_fixed_costs                   IN     VARCHAR2,
    x_max_aid_pkg                       IN     NUMBER,
    x_max_gift_amt                      IN     NUMBER,
    x_max_gift_perct                    IN     NUMBER,
    x_max_gift_perct_fact               IN     VARCHAR2,
    x_max_schlrshp_amt                  IN     NUMBER,
    x_max_schlrshp_perct                IN     NUMBER,
    x_max_schlrshp_perct_fact           IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2 ,
    x_sequence_number                   IN     NUMBER   ,
    x_rule_order                        IN     NUMBER,
    x_s_rule_call_cd                    IN     VARCHAR2,
    x_rul_sequence_number               IN     NUMBER,
    x_active                            IN     VARCHAR2,
    x_tgrp_id                           IN OUT NOCOPY NUMBER,
    x_mode                              IN     VARCHAR2,
    x_adplans_id                        IN     NUMBER
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 13-JUL-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  veramach        06-NOV-2003     FA 125 Multiple distr methods
  ||                                  Added new column adplans_id
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_aw_target_grp_all
      WHERE    tgrp_id                           = x_tgrp_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_group_cd,
        x_description,
        x_max_grant_amt,
        x_max_grant_perct,
        x_max_grant_perct_fact,
        x_max_loan_amt,
        x_max_loan_perct,
        x_max_loan_perct_fact,
        x_max_work_amt,
        x_max_work_perct,
        x_max_work_perct_fact,
        x_max_shelp_amt,
        x_max_shelp_perct,
        x_max_shelp_perct_fact,
        x_max_gap_amt,
        x_max_gap_perct,
        x_max_gap_perct_fact,
        x_use_fixed_costs,
        x_max_aid_pkg,
        x_max_gift_amt,
        x_max_gift_perct ,
        x_max_gift_perct_fact,
        x_max_schlrshp_amt,
        x_max_schlrshp_perct ,
        x_max_schlrshp_perct_fact,
        x_cal_type,
        x_sequence_number,
        x_rule_order,
        x_s_rule_call_cd,
        x_rul_sequence_number,
        x_active,
        x_tgrp_id,
        x_mode,
        x_adplans_id
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_group_cd,
      x_description,
      x_max_grant_amt,
      x_max_grant_perct,
      x_max_grant_perct_fact,
      x_max_loan_amt,
      x_max_loan_perct,
      x_max_loan_perct_fact,
      x_max_work_amt,
      x_max_work_perct,
      x_max_work_perct_fact,
      x_max_shelp_amt,
      x_max_shelp_perct,
      x_max_shelp_perct_fact,
      x_max_gap_amt,
      x_max_gap_perct,
      x_max_gap_perct_fact,
      x_use_fixed_costs,
      x_max_aid_pkg,
      x_max_gift_amt,
      x_max_gift_perct ,
      x_max_gift_perct_fact,
      x_max_schlrshp_amt,
      x_max_schlrshp_perct ,
      x_max_schlrshp_perct_fact,
      x_cal_type,
      x_sequence_number,
      x_rule_order,
      x_s_rule_call_cd,
      x_rul_sequence_number,
      x_active,
      x_tgrp_id,
      x_mode,
      x_adplans_id
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 13-JUL-2001
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

    DELETE FROM igf_aw_target_grp_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_aw_target_grp_pkg;

/
