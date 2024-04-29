--------------------------------------------------------
--  DDL for Package Body IGS_UC_INST_CONTROL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_INST_CONTROL_PKG" AS
/* $Header: IGSXI20B.pls 115.6 2003/07/10 13:45:39 smaddali noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_uc_inst_control%ROWTYPE;
  new_references igs_uc_inst_control%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_updater                           IN     VARCHAR2,
    x_inst_type                         IN     VARCHAR2,
    x_inst_short_name                   IN     VARCHAR2,
    x_inst_name                         IN     VARCHAR2,
    x_inst_full_name                    IN     VARCHAR2,
    x_switchboard_tel_no                IN     VARCHAR2,
    x_decision_cards                    IN     VARCHAR2,
    x_record_cards                      IN     VARCHAR2,
    x_labels                            IN     VARCHAR2,
    x_weekly_mov_list_seq               IN     VARCHAR2,
    x_weekly_mov_paging                 IN     VARCHAR2,
    x_form_seq                          IN     VARCHAR2,
    x_ebl_required                      IN     VARCHAR2,
    x_ebl_media_1or2                    IN     VARCHAR2,
    x_ebl_media_3                       IN     VARCHAR2,
    x_ebl_1or2_merged                   IN     VARCHAR2,
    x_ebl_1or2_board_group              IN     VARCHAR2,
    x_ebl_3_board_group                 IN     VARCHAR2,
    x_ebl_nc_app                        IN     VARCHAR2,
    x_ebl_major_key1                    IN     VARCHAR2,
    x_ebl_major_key2                    IN     VARCHAR2,
    x_ebl_major_key3                    IN     VARCHAR2,
    x_ebl_minor_key1                    IN     VARCHAR2,
    x_ebl_minor_key2                    IN     VARCHAR2,
    x_ebl_minor_key3                    IN     VARCHAR2,
    x_ebl_final_key                     IN     VARCHAR2,
    x_odl1                              IN     VARCHAR2,
    x_odl1a                             IN     VARCHAR2,
    x_odl2                              IN     VARCHAR2,
    x_odl3                              IN     VARCHAR2,
    x_odl_summer                        IN     VARCHAR2,
    x_odl_route_b                       IN     VARCHAR2,
    x_monthly_seq                       IN     VARCHAR2,
    x_monthly_paper                     IN     VARCHAR2,
    x_monthly_page                      IN     VARCHAR2,
    x_monthly_type                      IN     VARCHAR2,
    x_june_list_seq                     IN     VARCHAR2,
    x_june_labels                       IN     VARCHAR2,
    x_june_num_labels                   IN     VARCHAR2,
    x_course_analysis                   IN     VARCHAR2,
    x_campus_used                       IN     VARCHAR2,
    x_d3_doc_required                   IN     VARCHAR2,
    x_clearing_accept_copy_form         IN     VARCHAR2,
    x_online_message                    IN     VARCHAR2,
    x_ethnic_list_seq                   IN     VARCHAR2,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER   ,
    x_starx				IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali 10-jun-03  Obsoleting datetimestamp column for ucfd203 -multiple cycled build ,bug#2669208
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_UC_INST_CONTROL
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
    new_references.updater                           := x_updater;
    new_references.inst_type                         := x_inst_type;
    new_references.inst_short_name                   := x_inst_short_name;
    new_references.inst_name                         := x_inst_name;
    new_references.inst_full_name                    := x_inst_full_name;
    new_references.switchboard_tel_no                := x_switchboard_tel_no;
    new_references.decision_cards                    := x_decision_cards;
    new_references.record_cards                      := x_record_cards;
    new_references.labels                            := x_labels;
    new_references.weekly_mov_list_seq               := x_weekly_mov_list_seq;
    new_references.weekly_mov_paging                 := x_weekly_mov_paging;
    new_references.form_seq                          := x_form_seq;
    new_references.ebl_required                      := x_ebl_required;
    new_references.ebl_media_1or2                    := x_ebl_media_1or2;
    new_references.ebl_media_3                       := x_ebl_media_3;
    new_references.ebl_1or2_merged                   := x_ebl_1or2_merged;
    new_references.ebl_1or2_board_group              := x_ebl_1or2_board_group;
    new_references.ebl_3_board_group                 := x_ebl_3_board_group;
    new_references.ebl_nc_app                        := x_ebl_nc_app;
    new_references.ebl_major_key1                    := x_ebl_major_key1;
    new_references.ebl_major_key2                    := x_ebl_major_key2;
    new_references.ebl_major_key3                    := x_ebl_major_key3;
    new_references.ebl_minor_key1                    := x_ebl_minor_key1;
    new_references.ebl_minor_key2                    := x_ebl_minor_key2;
    new_references.ebl_minor_key3                    := x_ebl_minor_key3;
    new_references.ebl_final_key                     := x_ebl_final_key;
    new_references.odl1                              := x_odl1;
    new_references.odl1a                             := x_odl1a;
    new_references.odl2                              := x_odl2;
    new_references.odl3                              := x_odl3;
    new_references.odl_summer                        := x_odl_summer;
    new_references.odl_route_b                       := x_odl_route_b;
    new_references.monthly_seq                       := x_monthly_seq;
    new_references.monthly_paper                     := x_monthly_paper;
    new_references.monthly_page                      := x_monthly_page;
    new_references.monthly_type                      := x_monthly_type;
    new_references.june_list_seq                     := x_june_list_seq;
    new_references.june_labels                       := x_june_labels;
    new_references.june_num_labels                   := x_june_num_labels;
    new_references.course_analysis                   := x_course_analysis;
    new_references.campus_used                       := x_campus_used;
    new_references.d3_doc_required                   := x_d3_doc_required;
    new_references.clearing_accept_copy_form         := x_clearing_accept_copy_form;
    new_references.online_message                    := x_online_message;
    new_references.ethnic_list_seq                   := x_ethnic_list_seq;
    new_references.starx			     := x_starx ;

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


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_updater                           IN     VARCHAR2,
    x_inst_type                         IN     VARCHAR2,
    x_inst_short_name                   IN     VARCHAR2,
    x_inst_name                         IN     VARCHAR2,
    x_inst_full_name                    IN     VARCHAR2,
    x_switchboard_tel_no                IN     VARCHAR2,
    x_decision_cards                    IN     VARCHAR2,
    x_record_cards                      IN     VARCHAR2,
    x_labels                            IN     VARCHAR2,
    x_weekly_mov_list_seq               IN     VARCHAR2,
    x_weekly_mov_paging                 IN     VARCHAR2,
    x_form_seq                          IN     VARCHAR2,
    x_ebl_required                      IN     VARCHAR2,
    x_ebl_media_1or2                    IN     VARCHAR2,
    x_ebl_media_3                       IN     VARCHAR2,
    x_ebl_1or2_merged                   IN     VARCHAR2,
    x_ebl_1or2_board_group              IN     VARCHAR2,
    x_ebl_3_board_group                 IN     VARCHAR2,
    x_ebl_nc_app                        IN     VARCHAR2,
    x_ebl_major_key1                    IN     VARCHAR2,
    x_ebl_major_key2                    IN     VARCHAR2,
    x_ebl_major_key3                    IN     VARCHAR2,
    x_ebl_minor_key1                    IN     VARCHAR2,
    x_ebl_minor_key2                    IN     VARCHAR2,
    x_ebl_minor_key3                    IN     VARCHAR2,
    x_ebl_final_key                     IN     VARCHAR2,
    x_odl1                              IN     VARCHAR2,
    x_odl1a                             IN     VARCHAR2,
    x_odl2                              IN     VARCHAR2,
    x_odl3                              IN     VARCHAR2,
    x_odl_summer                        IN     VARCHAR2,
    x_odl_route_b                       IN     VARCHAR2,
    x_monthly_seq                       IN     VARCHAR2,
    x_monthly_paper                     IN     VARCHAR2,
    x_monthly_page                      IN     VARCHAR2,
    x_monthly_type                      IN     VARCHAR2,
    x_june_list_seq                     IN     VARCHAR2,
    x_june_labels                       IN     VARCHAR2,
    x_june_num_labels                   IN     VARCHAR2,
    x_course_analysis                   IN     VARCHAR2,
    x_campus_used                       IN     VARCHAR2,
    x_d3_doc_required                   IN     VARCHAR2,
    x_clearing_accept_copy_form         IN     VARCHAR2,
    x_online_message                    IN     VARCHAR2,
    x_ethnic_list_seq                   IN     VARCHAR2,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    x_starx				IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali 10-jun-03  Obsoleting datetimestamp column for ucfd203 -multiple cycled build ,bug#2669208
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_updater,
      x_inst_type,
      x_inst_short_name,
      x_inst_name,
      x_inst_full_name,
      x_switchboard_tel_no,
      x_decision_cards,
      x_record_cards,
      x_labels,
      x_weekly_mov_list_seq,
      x_weekly_mov_paging,
      x_form_seq,
      x_ebl_required,
      x_ebl_media_1or2,
      x_ebl_media_3,
      x_ebl_1or2_merged,
      x_ebl_1or2_board_group,
      x_ebl_3_board_group,
      x_ebl_nc_app,
      x_ebl_major_key1,
      x_ebl_major_key2,
      x_ebl_major_key3,
      x_ebl_minor_key1,
      x_ebl_minor_key2,
      x_ebl_minor_key3,
      x_ebl_final_key,
      x_odl1,
      x_odl1a,
      x_odl2,
      x_odl3,
      x_odl_summer,
      x_odl_route_b,
      x_monthly_seq,
      x_monthly_paper,
      x_monthly_page,
      x_monthly_type,
      x_june_list_seq,
      x_june_labels,
      x_june_num_labels,
      x_course_analysis,
      x_campus_used,
      x_d3_doc_required,
      x_clearing_accept_copy_form,
      x_online_message,
      x_ethnic_list_seq,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_starx
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.

/* commented because theree is no primary key for this table */
/* rgopalan 1-OCT-2001 */

/*      IF ( get_pk_for_validation(

           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
*/
		NULL;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
/*      IF ( get_pk_for_validation (

           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
*/
	NULL;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_updater                           IN     VARCHAR2,
    x_inst_type                         IN     VARCHAR2,
    x_inst_short_name                   IN     VARCHAR2,
    x_inst_name                         IN     VARCHAR2,
    x_inst_full_name                    IN     VARCHAR2,
    x_switchboard_tel_no                IN     VARCHAR2,
    x_decision_cards                    IN     VARCHAR2,
    x_record_cards                      IN     VARCHAR2,
    x_labels                            IN     VARCHAR2,
    x_weekly_mov_list_seq               IN     VARCHAR2,
    x_weekly_mov_paging                 IN     VARCHAR2,
    x_form_seq                          IN     VARCHAR2,
    x_ebl_required                      IN     VARCHAR2,
    x_ebl_media_1or2                    IN     VARCHAR2,
    x_ebl_media_3                       IN     VARCHAR2,
    x_ebl_1or2_merged                   IN     VARCHAR2,
    x_ebl_1or2_board_group              IN     VARCHAR2,
    x_ebl_3_board_group                 IN     VARCHAR2,
    x_ebl_nc_app                        IN     VARCHAR2,
    x_ebl_major_key1                    IN     VARCHAR2,
    x_ebl_major_key2                    IN     VARCHAR2,
    x_ebl_major_key3                    IN     VARCHAR2,
    x_ebl_minor_key1                    IN     VARCHAR2,
    x_ebl_minor_key2                    IN     VARCHAR2,
    x_ebl_minor_key3                    IN     VARCHAR2,
    x_ebl_final_key                     IN     VARCHAR2,
    x_odl1                              IN     VARCHAR2,
    x_odl1a                             IN     VARCHAR2,
    x_odl2                              IN     VARCHAR2,
    x_odl3                              IN     VARCHAR2,
    x_odl_summer                        IN     VARCHAR2,
    x_odl_route_b                       IN     VARCHAR2,
    x_monthly_seq                       IN     VARCHAR2,
    x_monthly_paper                     IN     VARCHAR2,
    x_monthly_page                      IN     VARCHAR2,
    x_monthly_type                      IN     VARCHAR2,
    x_june_list_seq                     IN     VARCHAR2,
    x_june_labels                       IN     VARCHAR2,
    x_june_num_labels                   IN     VARCHAR2,
    x_course_analysis                   IN     VARCHAR2,
    x_campus_used                       IN     VARCHAR2,
    x_d3_doc_required                   IN     VARCHAR2,
    x_clearing_accept_copy_form         IN     VARCHAR2,
    x_online_message                    IN     VARCHAR2,
    x_ethnic_list_seq                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_starx				IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali 10-jun-03  Obsoleting datetimestamp column for ucfd203 -multiple cycled build ,bug#2669208
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_uc_inst_control;


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

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_updater                           => x_updater,
      x_inst_type                         => x_inst_type,
      x_inst_short_name                   => x_inst_short_name,
      x_inst_name                         => x_inst_name,
      x_inst_full_name                    => x_inst_full_name,
      x_switchboard_tel_no                => x_switchboard_tel_no,
      x_decision_cards                    => x_decision_cards,
      x_record_cards                      => x_record_cards,
      x_labels                            => x_labels,
      x_weekly_mov_list_seq               => x_weekly_mov_list_seq,
      x_weekly_mov_paging                 => x_weekly_mov_paging,
      x_form_seq                          => x_form_seq,
      x_ebl_required                      => x_ebl_required,
      x_ebl_media_1or2                    => x_ebl_media_1or2,
      x_ebl_media_3                       => x_ebl_media_3,
      x_ebl_1or2_merged                   => x_ebl_1or2_merged,
      x_ebl_1or2_board_group              => x_ebl_1or2_board_group,
      x_ebl_3_board_group                 => x_ebl_3_board_group,
      x_ebl_nc_app                        => x_ebl_nc_app,
      x_ebl_major_key1                    => x_ebl_major_key1,
      x_ebl_major_key2                    => x_ebl_major_key2,
      x_ebl_major_key3                    => x_ebl_major_key3,
      x_ebl_minor_key1                    => x_ebl_minor_key1,
      x_ebl_minor_key2                    => x_ebl_minor_key2,
      x_ebl_minor_key3                    => x_ebl_minor_key3,
      x_ebl_final_key                     => x_ebl_final_key,
      x_odl1                              => x_odl1,
      x_odl1a                             => x_odl1a,
      x_odl2                              => x_odl2,
      x_odl3                              => x_odl3,
      x_odl_summer                        => x_odl_summer,
      x_odl_route_b                       => x_odl_route_b,
      x_monthly_seq                       => x_monthly_seq,
      x_monthly_paper                     => x_monthly_paper,
      x_monthly_page                      => x_monthly_page,
      x_monthly_type                      => x_monthly_type,
      x_june_list_seq                     => x_june_list_seq,
      x_june_labels                       => x_june_labels,
      x_june_num_labels                   => x_june_num_labels,
      x_course_analysis                   => x_course_analysis,
      x_campus_used                       => x_campus_used,
      x_d3_doc_required                   => x_d3_doc_required,
      x_clearing_accept_copy_form         => x_clearing_accept_copy_form,
      x_online_message                    => x_online_message,
      x_ethnic_list_seq                   => x_ethnic_list_seq,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login ,
      x_starx				  => x_starx
    );

    INSERT INTO igs_uc_inst_control (
      updater,
      inst_type,
      inst_short_name,
      inst_name,
      inst_full_name,
      switchboard_tel_no,
      decision_cards,
      record_cards,
      labels,
      weekly_mov_list_seq,
      weekly_mov_paging,
      form_seq,
      ebl_required,
      ebl_media_1or2,
      ebl_media_3,
      ebl_1or2_merged,
      ebl_1or2_board_group,
      ebl_3_board_group,
      ebl_nc_app,
      ebl_major_key1,
      ebl_major_key2,
      ebl_major_key3,
      ebl_minor_key1,
      ebl_minor_key2,
      ebl_minor_key3,
      ebl_final_key,
      odl1,
      odl1a,
      odl2,
      odl3,
      odl_summer,
      odl_route_b,
      monthly_seq,
      monthly_paper,
      monthly_page,
      monthly_type,
      june_list_seq,
      june_labels,
      june_num_labels,
      course_analysis,
      campus_used,
      d3_doc_required,
      clearing_accept_copy_form,
      online_message,
      ethnic_list_seq,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      starx
    ) VALUES (
      new_references.updater,
      new_references.inst_type,
      new_references.inst_short_name,
      new_references.inst_name,
      new_references.inst_full_name,
      new_references.switchboard_tel_no,
      new_references.decision_cards,
      new_references.record_cards,
      new_references.labels,
      new_references.weekly_mov_list_seq,
      new_references.weekly_mov_paging,
      new_references.form_seq,
      new_references.ebl_required,
      new_references.ebl_media_1or2,
      new_references.ebl_media_3,
      new_references.ebl_1or2_merged,
      new_references.ebl_1or2_board_group,
      new_references.ebl_3_board_group,
      new_references.ebl_nc_app,
      new_references.ebl_major_key1,
      new_references.ebl_major_key2,
      new_references.ebl_major_key3,
      new_references.ebl_minor_key1,
      new_references.ebl_minor_key2,
      new_references.ebl_minor_key3,
      new_references.ebl_final_key,
      new_references.odl1,
      new_references.odl1a,
      new_references.odl2,
      new_references.odl3,
      new_references.odl_summer,
      new_references.odl_route_b,
      new_references.monthly_seq,
      new_references.monthly_paper,
      new_references.monthly_page,
      new_references.monthly_type,
      new_references.june_list_seq,
      new_references.june_labels,
      new_references.june_num_labels,
      new_references.course_analysis,
      new_references.campus_used,
      new_references.d3_doc_required,
      new_references.clearing_accept_copy_form,
      new_references.online_message,
      new_references.ethnic_list_seq,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      new_references.starx
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
    x_updater                           IN     VARCHAR2,
    x_inst_type                         IN     VARCHAR2,
    x_inst_short_name                   IN     VARCHAR2,
    x_inst_name                         IN     VARCHAR2,
    x_inst_full_name                    IN     VARCHAR2,
    x_switchboard_tel_no                IN     VARCHAR2,
    x_decision_cards                    IN     VARCHAR2,
    x_record_cards                      IN     VARCHAR2,
    x_labels                            IN     VARCHAR2,
    x_weekly_mov_list_seq               IN     VARCHAR2,
    x_weekly_mov_paging                 IN     VARCHAR2,
    x_form_seq                          IN     VARCHAR2,
    x_ebl_required                      IN     VARCHAR2,
    x_ebl_media_1or2                    IN     VARCHAR2,
    x_ebl_media_3                       IN     VARCHAR2,
    x_ebl_1or2_merged                   IN     VARCHAR2,
    x_ebl_1or2_board_group              IN     VARCHAR2,
    x_ebl_3_board_group                 IN     VARCHAR2,
    x_ebl_nc_app                        IN     VARCHAR2,
    x_ebl_major_key1                    IN     VARCHAR2,
    x_ebl_major_key2                    IN     VARCHAR2,
    x_ebl_major_key3                    IN     VARCHAR2,
    x_ebl_minor_key1                    IN     VARCHAR2,
    x_ebl_minor_key2                    IN     VARCHAR2,
    x_ebl_minor_key3                    IN     VARCHAR2,
    x_ebl_final_key                     IN     VARCHAR2,
    x_odl1                              IN     VARCHAR2,
    x_odl1a                             IN     VARCHAR2,
    x_odl2                              IN     VARCHAR2,
    x_odl3                              IN     VARCHAR2,
    x_odl_summer                        IN     VARCHAR2,
    x_odl_route_b                       IN     VARCHAR2,
    x_monthly_seq                       IN     VARCHAR2,
    x_monthly_paper                     IN     VARCHAR2,
    x_monthly_page                      IN     VARCHAR2,
    x_monthly_type                      IN     VARCHAR2,
    x_june_list_seq                     IN     VARCHAR2,
    x_june_labels                       IN     VARCHAR2,
    x_june_num_labels                   IN     VARCHAR2,
    x_course_analysis                   IN     VARCHAR2,
    x_campus_used                       IN     VARCHAR2,
    x_d3_doc_required                   IN     VARCHAR2,
    x_clearing_accept_copy_form         IN     VARCHAR2,
    x_online_message                    IN     VARCHAR2,
    x_ethnic_list_seq                   IN     VARCHAR2,
    x_starx				IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali 10-jun-03  Obsoleting datetimestamp column for ucfd203 -multiple cycled build ,bug#2669208
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        updater,
        inst_type,
        inst_short_name,
        inst_name,
        inst_full_name,
        switchboard_tel_no,
        decision_cards,
        record_cards,
        labels,
        weekly_mov_list_seq,
        weekly_mov_paging,
        form_seq,
        ebl_required,
        ebl_media_1or2,
        ebl_media_3,
        ebl_1or2_merged,
        ebl_1or2_board_group,
        ebl_3_board_group,
        ebl_nc_app,
        ebl_major_key1,
        ebl_major_key2,
        ebl_major_key3,
        ebl_minor_key1,
        ebl_minor_key2,
        ebl_minor_key3,
        ebl_final_key,
        odl1,
        odl1a,
        odl2,
        odl3,
        odl_summer,
        odl_route_b,
        monthly_seq,
        monthly_paper,
        monthly_page,
        monthly_type,
        june_list_seq,
        june_labels,
        june_num_labels,
        course_analysis,
        campus_used,
        d3_doc_required,
        clearing_accept_copy_form,
        online_message,
        ethnic_list_seq,
	starx
      FROM  igs_uc_inst_control
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
        (tlinfo.updater = x_updater)
        AND (tlinfo.inst_type = x_inst_type)
        AND ((tlinfo.inst_short_name = x_inst_short_name) OR ((tlinfo.inst_short_name IS NULL) AND (X_inst_short_name IS NULL)))
        AND ((tlinfo.inst_name = x_inst_name) OR ((tlinfo.inst_name IS NULL) AND (X_inst_name IS NULL)))
        AND ((tlinfo.inst_full_name = x_inst_full_name) OR ((tlinfo.inst_full_name IS NULL) AND (X_inst_full_name IS NULL)))
        AND ((tlinfo.switchboard_tel_no = x_switchboard_tel_no) OR ((tlinfo.switchboard_tel_no IS NULL) AND (X_switchboard_tel_no IS NULL)))
        AND ((tlinfo.decision_cards = x_decision_cards) OR ((tlinfo.decision_cards IS NULL) AND (X_decision_cards IS NULL)))
        AND ((tlinfo.record_cards = x_record_cards) OR ((tlinfo.record_cards IS NULL) AND (X_record_cards IS NULL)))
        AND ((tlinfo.labels = x_labels) OR ((tlinfo.labels IS NULL) AND (X_labels IS NULL)))
        AND ((tlinfo.weekly_mov_list_seq = x_weekly_mov_list_seq) OR ((tlinfo.weekly_mov_list_seq IS NULL) AND (X_weekly_mov_list_seq IS NULL)))
        AND ((tlinfo.weekly_mov_paging = x_weekly_mov_paging) OR ((tlinfo.weekly_mov_paging IS NULL) AND (X_weekly_mov_paging IS NULL)))
        AND ((tlinfo.form_seq = x_form_seq) OR ((tlinfo.form_seq IS NULL) AND (X_form_seq IS NULL)))
        AND ((tlinfo.ebl_required = x_ebl_required) OR ((tlinfo.ebl_required IS NULL) AND (X_ebl_required IS NULL)))
        AND ((tlinfo.ebl_media_1or2 = x_ebl_media_1or2) OR ((tlinfo.ebl_media_1or2 IS NULL) AND (X_ebl_media_1or2 IS NULL)))
        AND ((tlinfo.ebl_media_3 = x_ebl_media_3) OR ((tlinfo.ebl_media_3 IS NULL) AND (X_ebl_media_3 IS NULL)))
        AND ((tlinfo.ebl_1or2_merged = x_ebl_1or2_merged) OR ((tlinfo.ebl_1or2_merged IS NULL) AND (X_ebl_1or2_merged IS NULL)))
        AND ((tlinfo.ebl_1or2_board_group = x_ebl_1or2_board_group) OR ((tlinfo.ebl_1or2_board_group IS NULL) AND (X_ebl_1or2_board_group IS NULL)))
        AND ((tlinfo.ebl_3_board_group = x_ebl_3_board_group) OR ((tlinfo.ebl_3_board_group IS NULL) AND (X_ebl_3_board_group IS NULL)))
        AND ((tlinfo.ebl_nc_app = x_ebl_nc_app) OR ((tlinfo.ebl_nc_app IS NULL) AND (X_ebl_nc_app IS NULL)))
        AND ((tlinfo.ebl_major_key1 = x_ebl_major_key1) OR ((tlinfo.ebl_major_key1 IS NULL) AND (X_ebl_major_key1 IS NULL)))
        AND ((tlinfo.ebl_major_key2 = x_ebl_major_key2) OR ((tlinfo.ebl_major_key2 IS NULL) AND (X_ebl_major_key2 IS NULL)))
        AND ((tlinfo.ebl_major_key3 = x_ebl_major_key3) OR ((tlinfo.ebl_major_key3 IS NULL) AND (X_ebl_major_key3 IS NULL)))
        AND ((tlinfo.ebl_minor_key1 = x_ebl_minor_key1) OR ((tlinfo.ebl_minor_key1 IS NULL) AND (X_ebl_minor_key1 IS NULL)))
        AND ((tlinfo.ebl_minor_key2 = x_ebl_minor_key2) OR ((tlinfo.ebl_minor_key2 IS NULL) AND (X_ebl_minor_key2 IS NULL)))
        AND ((tlinfo.ebl_minor_key3 = x_ebl_minor_key3) OR ((tlinfo.ebl_minor_key3 IS NULL) AND (X_ebl_minor_key3 IS NULL)))
        AND ((tlinfo.ebl_final_key = x_ebl_final_key) OR ((tlinfo.ebl_final_key IS NULL) AND (X_ebl_final_key IS NULL)))
        AND ((tlinfo.odl1 = x_odl1) OR ((tlinfo.odl1 IS NULL) AND (X_odl1 IS NULL)))
        AND ((tlinfo.odl1a = x_odl1a) OR ((tlinfo.odl1a IS NULL) AND (X_odl1a IS NULL)))
        AND ((tlinfo.odl2 = x_odl2) OR ((tlinfo.odl2 IS NULL) AND (X_odl2 IS NULL)))
        AND ((tlinfo.odl3 = x_odl3) OR ((tlinfo.odl3 IS NULL) AND (X_odl3 IS NULL)))
        AND ((tlinfo.odl_summer = x_odl_summer) OR ((tlinfo.odl_summer IS NULL) AND (X_odl_summer IS NULL)))
        AND ((tlinfo.odl_route_b = x_odl_route_b) OR ((tlinfo.odl_route_b IS NULL) AND (X_odl_route_b IS NULL)))
        AND ((tlinfo.monthly_seq = x_monthly_seq) OR ((tlinfo.monthly_seq IS NULL) AND (X_monthly_seq IS NULL)))
        AND ((tlinfo.monthly_paper = x_monthly_paper) OR ((tlinfo.monthly_paper IS NULL) AND (X_monthly_paper IS NULL)))
        AND ((tlinfo.monthly_page = x_monthly_page) OR ((tlinfo.monthly_page IS NULL) AND (X_monthly_page IS NULL)))
        AND ((tlinfo.monthly_type = x_monthly_type) OR ((tlinfo.monthly_type IS NULL) AND (X_monthly_type IS NULL)))
        AND ((tlinfo.june_list_seq = x_june_list_seq) OR ((tlinfo.june_list_seq IS NULL) AND (X_june_list_seq IS NULL)))
        AND ((tlinfo.june_labels = x_june_labels) OR ((tlinfo.june_labels IS NULL) AND (X_june_labels IS NULL)))
        AND ((tlinfo.june_num_labels = x_june_num_labels) OR ((tlinfo.june_num_labels IS NULL) AND (X_june_num_labels IS NULL)))
        AND ((tlinfo.course_analysis = x_course_analysis) OR ((tlinfo.course_analysis IS NULL) AND (X_course_analysis IS NULL)))
        AND ((tlinfo.campus_used = x_campus_used) OR ((tlinfo.campus_used IS NULL) AND (X_campus_used IS NULL)))
        AND ((tlinfo.d3_doc_required = x_d3_doc_required) OR ((tlinfo.d3_doc_required IS NULL) AND (X_d3_doc_required IS NULL)))
        AND ((tlinfo.clearing_accept_copy_form = x_clearing_accept_copy_form) OR ((tlinfo.clearing_accept_copy_form IS NULL) AND (X_clearing_accept_copy_form IS NULL)))
        AND ((tlinfo.online_message = x_online_message) OR ((tlinfo.online_message IS NULL) AND (X_online_message IS NULL)))
        AND ((tlinfo.ethnic_list_seq = x_ethnic_list_seq) OR ((tlinfo.ethnic_list_seq IS NULL) AND (X_ethnic_list_seq IS NULL)))
        AND ((tlinfo.starx = x_starx) OR ((tlinfo.starx IS NULL) AND (X_starx IS NULL)))
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
    x_updater                           IN     VARCHAR2,
    x_inst_type                         IN     VARCHAR2,
    x_inst_short_name                   IN     VARCHAR2,
    x_inst_name                         IN     VARCHAR2,
    x_inst_full_name                    IN     VARCHAR2,
    x_switchboard_tel_no                IN     VARCHAR2,
    x_decision_cards                    IN     VARCHAR2,
    x_record_cards                      IN     VARCHAR2,
    x_labels                            IN     VARCHAR2,
    x_weekly_mov_list_seq               IN     VARCHAR2,
    x_weekly_mov_paging                 IN     VARCHAR2,
    x_form_seq                          IN     VARCHAR2,
    x_ebl_required                      IN     VARCHAR2,
    x_ebl_media_1or2                    IN     VARCHAR2,
    x_ebl_media_3                       IN     VARCHAR2,
    x_ebl_1or2_merged                   IN     VARCHAR2,
    x_ebl_1or2_board_group              IN     VARCHAR2,
    x_ebl_3_board_group                 IN     VARCHAR2,
    x_ebl_nc_app                        IN     VARCHAR2,
    x_ebl_major_key1                    IN     VARCHAR2,
    x_ebl_major_key2                    IN     VARCHAR2,
    x_ebl_major_key3                    IN     VARCHAR2,
    x_ebl_minor_key1                    IN     VARCHAR2,
    x_ebl_minor_key2                    IN     VARCHAR2,
    x_ebl_minor_key3                    IN     VARCHAR2,
    x_ebl_final_key                     IN     VARCHAR2,
    x_odl1                              IN     VARCHAR2,
    x_odl1a                             IN     VARCHAR2,
    x_odl2                              IN     VARCHAR2,
    x_odl3                              IN     VARCHAR2,
    x_odl_summer                        IN     VARCHAR2,
    x_odl_route_b                       IN     VARCHAR2,
    x_monthly_seq                       IN     VARCHAR2,
    x_monthly_paper                     IN     VARCHAR2,
    x_monthly_page                      IN     VARCHAR2,
    x_monthly_type                      IN     VARCHAR2,
    x_june_list_seq                     IN     VARCHAR2,
    x_june_labels                       IN     VARCHAR2,
    x_june_num_labels                   IN     VARCHAR2,
    x_course_analysis                   IN     VARCHAR2,
    x_campus_used                       IN     VARCHAR2,
    x_d3_doc_required                   IN     VARCHAR2,
    x_clearing_accept_copy_form         IN     VARCHAR2,
    x_online_message                    IN     VARCHAR2,
    x_ethnic_list_seq                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_starx				IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali 10-jun-03  Obsoleting datetimestamp column for ucfd203 -multiple cycled build ,bug#2669208
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
      x_updater                           => x_updater,
      x_inst_type                         => x_inst_type,
      x_inst_short_name                   => x_inst_short_name,
      x_inst_name                         => x_inst_name,
      x_inst_full_name                    => x_inst_full_name,
      x_switchboard_tel_no                => x_switchboard_tel_no,
      x_decision_cards                    => x_decision_cards,
      x_record_cards                      => x_record_cards,
      x_labels                            => x_labels,
      x_weekly_mov_list_seq               => x_weekly_mov_list_seq,
      x_weekly_mov_paging                 => x_weekly_mov_paging,
      x_form_seq                          => x_form_seq,
      x_ebl_required                      => x_ebl_required,
      x_ebl_media_1or2                    => x_ebl_media_1or2,
      x_ebl_media_3                       => x_ebl_media_3,
      x_ebl_1or2_merged                   => x_ebl_1or2_merged,
      x_ebl_1or2_board_group              => x_ebl_1or2_board_group,
      x_ebl_3_board_group                 => x_ebl_3_board_group,
      x_ebl_nc_app                        => x_ebl_nc_app,
      x_ebl_major_key1                    => x_ebl_major_key1,
      x_ebl_major_key2                    => x_ebl_major_key2,
      x_ebl_major_key3                    => x_ebl_major_key3,
      x_ebl_minor_key1                    => x_ebl_minor_key1,
      x_ebl_minor_key2                    => x_ebl_minor_key2,
      x_ebl_minor_key3                    => x_ebl_minor_key3,
      x_ebl_final_key                     => x_ebl_final_key,
      x_odl1                              => x_odl1,
      x_odl1a                             => x_odl1a,
      x_odl2                              => x_odl2,
      x_odl3                              => x_odl3,
      x_odl_summer                        => x_odl_summer,
      x_odl_route_b                       => x_odl_route_b,
      x_monthly_seq                       => x_monthly_seq,
      x_monthly_paper                     => x_monthly_paper,
      x_monthly_page                      => x_monthly_page,
      x_monthly_type                      => x_monthly_type,
      x_june_list_seq                     => x_june_list_seq,
      x_june_labels                       => x_june_labels,
      x_june_num_labels                   => x_june_num_labels,
      x_course_analysis                   => x_course_analysis,
      x_campus_used                       => x_campus_used,
      x_d3_doc_required                   => x_d3_doc_required,
      x_clearing_accept_copy_form         => x_clearing_accept_copy_form,
      x_online_message                    => x_online_message,
      x_ethnic_list_seq                   => x_ethnic_list_seq,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login ,
      x_starx				  => x_starx
    );

    UPDATE igs_uc_inst_control
      SET
        updater                           = new_references.updater,
        inst_type                         = new_references.inst_type,
        inst_short_name                   = new_references.inst_short_name,
        inst_name                         = new_references.inst_name,
        inst_full_name                    = new_references.inst_full_name,
        switchboard_tel_no                = new_references.switchboard_tel_no,
        decision_cards                    = new_references.decision_cards,
        record_cards                      = new_references.record_cards,
        labels                            = new_references.labels,
        weekly_mov_list_seq               = new_references.weekly_mov_list_seq,
        weekly_mov_paging                 = new_references.weekly_mov_paging,
        form_seq                          = new_references.form_seq,
        ebl_required                      = new_references.ebl_required,
        ebl_media_1or2                    = new_references.ebl_media_1or2,
        ebl_media_3                       = new_references.ebl_media_3,
        ebl_1or2_merged                   = new_references.ebl_1or2_merged,
        ebl_1or2_board_group              = new_references.ebl_1or2_board_group,
        ebl_3_board_group                 = new_references.ebl_3_board_group,
        ebl_nc_app                        = new_references.ebl_nc_app,
        ebl_major_key1                    = new_references.ebl_major_key1,
        ebl_major_key2                    = new_references.ebl_major_key2,
        ebl_major_key3                    = new_references.ebl_major_key3,
        ebl_minor_key1                    = new_references.ebl_minor_key1,
        ebl_minor_key2                    = new_references.ebl_minor_key2,
        ebl_minor_key3                    = new_references.ebl_minor_key3,
        ebl_final_key                     = new_references.ebl_final_key,
        odl1                              = new_references.odl1,
        odl1a                             = new_references.odl1a,
        odl2                              = new_references.odl2,
        odl3                              = new_references.odl3,
        odl_summer                        = new_references.odl_summer,
        odl_route_b                       = new_references.odl_route_b,
        monthly_seq                       = new_references.monthly_seq,
        monthly_paper                     = new_references.monthly_paper,
        monthly_page                      = new_references.monthly_page,
        monthly_type                      = new_references.monthly_type,
        june_list_seq                     = new_references.june_list_seq,
        june_labels                       = new_references.june_labels,
        june_num_labels                   = new_references.june_num_labels,
        course_analysis                   = new_references.course_analysis,
        campus_used                       = new_references.campus_used,
        d3_doc_required                   = new_references.d3_doc_required,
        clearing_accept_copy_form         = new_references.clearing_accept_copy_form,
        online_message                    = new_references.online_message,
        ethnic_list_seq                   = new_references.ethnic_list_seq,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
	starx				  = x_starx
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_updater                           IN     VARCHAR2,
    x_inst_type                         IN     VARCHAR2,
    x_inst_short_name                   IN     VARCHAR2,
    x_inst_name                         IN     VARCHAR2,
    x_inst_full_name                    IN     VARCHAR2,
    x_switchboard_tel_no                IN     VARCHAR2,
    x_decision_cards                    IN     VARCHAR2,
    x_record_cards                      IN     VARCHAR2,
    x_labels                            IN     VARCHAR2,
    x_weekly_mov_list_seq               IN     VARCHAR2,
    x_weekly_mov_paging                 IN     VARCHAR2,
    x_form_seq                          IN     VARCHAR2,
    x_ebl_required                      IN     VARCHAR2,
    x_ebl_media_1or2                    IN     VARCHAR2,
    x_ebl_media_3                       IN     VARCHAR2,
    x_ebl_1or2_merged                   IN     VARCHAR2,
    x_ebl_1or2_board_group              IN     VARCHAR2,
    x_ebl_3_board_group                 IN     VARCHAR2,
    x_ebl_nc_app                        IN     VARCHAR2,
    x_ebl_major_key1                    IN     VARCHAR2,
    x_ebl_major_key2                    IN     VARCHAR2,
    x_ebl_major_key3                    IN     VARCHAR2,
    x_ebl_minor_key1                    IN     VARCHAR2,
    x_ebl_minor_key2                    IN     VARCHAR2,
    x_ebl_minor_key3                    IN     VARCHAR2,
    x_ebl_final_key                     IN     VARCHAR2,
    x_odl1                              IN     VARCHAR2,
    x_odl1a                             IN     VARCHAR2,
    x_odl2                              IN     VARCHAR2,
    x_odl3                              IN     VARCHAR2,
    x_odl_summer                        IN     VARCHAR2,
    x_odl_route_b                       IN     VARCHAR2,
    x_monthly_seq                       IN     VARCHAR2,
    x_monthly_paper                     IN     VARCHAR2,
    x_monthly_page                      IN     VARCHAR2,
    x_monthly_type                      IN     VARCHAR2,
    x_june_list_seq                     IN     VARCHAR2,
    x_june_labels                       IN     VARCHAR2,
    x_june_num_labels                   IN     VARCHAR2,
    x_course_analysis                   IN     VARCHAR2,
    x_campus_used                       IN     VARCHAR2,
    x_d3_doc_required                   IN     VARCHAR2,
    x_clearing_accept_copy_form         IN     VARCHAR2,
    x_online_message                    IN     VARCHAR2,
    x_ethnic_list_seq                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_starx				IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali 10-jun-03  Obsoleting datetimestamp column for ucfd203 -multiple cycled build ,bug#2669208
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_uc_inst_control;


  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_updater,
        x_inst_type,
        x_inst_short_name,
        x_inst_name,
        x_inst_full_name,
        x_switchboard_tel_no,
        x_decision_cards,
        x_record_cards,
        x_labels,
        x_weekly_mov_list_seq,
        x_weekly_mov_paging,
        x_form_seq,
        x_ebl_required,
        x_ebl_media_1or2,
        x_ebl_media_3,
        x_ebl_1or2_merged,
        x_ebl_1or2_board_group,
        x_ebl_3_board_group,
        x_ebl_nc_app,
        x_ebl_major_key1,
        x_ebl_major_key2,
        x_ebl_major_key3,
        x_ebl_minor_key1,
        x_ebl_minor_key2,
        x_ebl_minor_key3,
        x_ebl_final_key,
        x_odl1,
        x_odl1a,
        x_odl2,
        x_odl3,
        x_odl_summer,
        x_odl_route_b,
        x_monthly_seq,
        x_monthly_paper,
        x_monthly_page,
        x_monthly_type,
        x_june_list_seq,
        x_june_labels,
        x_june_num_labels,
        x_course_analysis,
        x_campus_used,
        x_d3_doc_required,
        x_clearing_accept_copy_form,
        x_online_message,
        x_ethnic_list_seq,
        x_mode ,
	x_starx
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_updater,
      x_inst_type,
      x_inst_short_name,
      x_inst_name,
      x_inst_full_name,
      x_switchboard_tel_no,
      x_decision_cards,
      x_record_cards,
      x_labels,
      x_weekly_mov_list_seq,
      x_weekly_mov_paging,
      x_form_seq,
      x_ebl_required,
      x_ebl_media_1or2,
      x_ebl_media_3,
      x_ebl_1or2_merged,
      x_ebl_1or2_board_group,
      x_ebl_3_board_group,
      x_ebl_nc_app,
      x_ebl_major_key1,
      x_ebl_major_key2,
      x_ebl_major_key3,
      x_ebl_minor_key1,
      x_ebl_minor_key2,
      x_ebl_minor_key3,
      x_ebl_final_key,
      x_odl1,
      x_odl1a,
      x_odl2,
      x_odl3,
      x_odl_summer,
      x_odl_route_b,
      x_monthly_seq,
      x_monthly_paper,
      x_monthly_page,
      x_monthly_type,
      x_june_list_seq,
      x_june_labels,
      x_june_num_labels,
      x_course_analysis,
      x_campus_used,
      x_d3_doc_required,
      x_clearing_accept_copy_form,
      x_online_message,
      x_ethnic_list_seq,
      x_mode ,
      x_starx
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
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

    DELETE FROM igs_uc_inst_control
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_uc_inst_control_pkg;

/
