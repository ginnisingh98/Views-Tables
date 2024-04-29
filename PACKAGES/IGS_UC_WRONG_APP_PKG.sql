--------------------------------------------------------
--  DDL for Package IGS_UC_WRONG_APP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_WRONG_APP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSXI34S.pls 115.7 2003/07/30 10:40:05 ayedubat noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_wrong_app_id                      IN OUT NOCOPY NUMBER,
    x_app_no                            IN OUT NOCOPY NUMBER,
    x_miscoded                          IN     VARCHAR2,
    x_cancelled                         IN     VARCHAR2,
    x_cancel_date                       IN     DATE,
    x_remark                            IN     VARCHAR2,
    x_expunge                           IN     VARCHAR2,
    x_batch_id                          IN     NUMBER,
    x_expunged                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_joint_admission_ind               IN     VARCHAR2 DEFAULT NULL,
    x_choice1_lost                      IN     VARCHAR2 DEFAULT NULL,
    x_choice2_lost                      IN     VARCHAR2 DEFAULT NULL,
    x_choice3_lost                      IN     VARCHAR2 DEFAULT NULL,
    x_choice4_lost                      IN     VARCHAR2 DEFAULT NULL,
    x_choice5_lost                      IN     VARCHAR2 DEFAULT NULL,
    x_choice6_lost                      IN     VARCHAR2 DEFAULT NULL,
    x_choice7_lost                      IN     VARCHAR2 DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_wrong_app_id                      IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_miscoded                          IN     VARCHAR2,
    x_cancelled                         IN     VARCHAR2,
    x_cancel_date                       IN     DATE,
    x_remark                            IN     VARCHAR2,
    x_expunge                           IN     VARCHAR2,
    x_batch_id                          IN     NUMBER,
    x_expunged                          IN     VARCHAR2,
    x_joint_admission_ind               IN     VARCHAR2 DEFAULT NULL,
    x_choice1_lost                      IN     VARCHAR2 DEFAULT NULL,
    x_choice2_lost                      IN     VARCHAR2 DEFAULT NULL,
    x_choice3_lost                      IN     VARCHAR2 DEFAULT NULL,
    x_choice4_lost                      IN     VARCHAR2 DEFAULT NULL,
    x_choice5_lost                      IN     VARCHAR2 DEFAULT NULL,
    x_choice6_lost                      IN     VARCHAR2 DEFAULT NULL,
    x_choice7_lost                      IN     VARCHAR2 DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_wrong_app_id                      IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_miscoded                          IN     VARCHAR2,
    x_cancelled                         IN     VARCHAR2,
    x_cancel_date                       IN     DATE,
    x_remark                            IN     VARCHAR2,
    x_expunge                           IN     VARCHAR2,
    x_batch_id                          IN     NUMBER,
    x_expunged                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_joint_admission_ind               IN     VARCHAR2 DEFAULT NULL,
    x_choice1_lost                      IN     VARCHAR2 DEFAULT NULL,
    x_choice2_lost                      IN     VARCHAR2 DEFAULT NULL,
    x_choice3_lost                      IN     VARCHAR2 DEFAULT NULL,
    x_choice4_lost                      IN     VARCHAR2 DEFAULT NULL,
    x_choice5_lost                      IN     VARCHAR2 DEFAULT NULL,
    x_choice6_lost                      IN     VARCHAR2 DEFAULT NULL,
    x_choice7_lost                      IN     VARCHAR2 DEFAULT NULL
);

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_wrong_app_id                      IN OUT NOCOPY NUMBER,
    x_app_no                            IN OUT NOCOPY NUMBER,
    x_miscoded                          IN     VARCHAR2,
    x_cancelled                         IN     VARCHAR2,
    x_cancel_date                       IN     DATE,
    x_remark                            IN     VARCHAR2,
    x_expunge                           IN     VARCHAR2,
    x_batch_id                          IN     NUMBER,
    x_expunged                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_joint_admission_ind               IN     VARCHAR2 DEFAULT NULL,
    x_choice1_lost                      IN     VARCHAR2 DEFAULT NULL,
    x_choice2_lost                      IN     VARCHAR2 DEFAULT NULL,
    x_choice3_lost                      IN     VARCHAR2 DEFAULT NULL,
    x_choice4_lost                      IN     VARCHAR2 DEFAULT NULL,
    x_choice5_lost                      IN     VARCHAR2 DEFAULT NULL,
    x_choice6_lost                      IN     VARCHAR2 DEFAULT NULL,
    x_choice7_lost                      IN     VARCHAR2 DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_app_no                            IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_wrong_app_id                      IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_wrong_app_id                      IN     NUMBER      DEFAULT NULL,
    x_app_no                            IN     NUMBER      DEFAULT NULL,
    x_miscoded                          IN     VARCHAR2    DEFAULT NULL,
    x_cancelled                         IN     VARCHAR2    DEFAULT NULL,
    x_cancel_date                       IN     DATE        DEFAULT NULL,
    x_remark                            IN     VARCHAR2    DEFAULT NULL,
    x_expunge                           IN     VARCHAR2    DEFAULT NULL,
    x_batch_id                          IN     NUMBER      DEFAULT NULL,
    x_expunged                          IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_joint_admission_ind               IN     VARCHAR2 DEFAULT NULL,
    x_choice1_lost                      IN     VARCHAR2 DEFAULT NULL,
    x_choice2_lost                      IN     VARCHAR2 DEFAULT NULL,
    x_choice3_lost                      IN     VARCHAR2 DEFAULT NULL,
    x_choice4_lost                      IN     VARCHAR2 DEFAULT NULL,
    x_choice5_lost                      IN     VARCHAR2 DEFAULT NULL,
    x_choice6_lost                      IN     VARCHAR2 DEFAULT NULL,
    x_choice7_lost                      IN     VARCHAR2 DEFAULT NULL
  );

END igs_uc_wrong_app_pkg;

 

/
