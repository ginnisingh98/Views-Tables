--------------------------------------------------------
--  DDL for Package IGS_PR_STDNT_PR_FND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_STDNT_PR_FND_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSQI45S.pls 120.0 2005/07/05 11:45:27 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_spo_sequence_number               IN     NUMBER,
    x_fund_code                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_spo_sequence_number               IN     NUMBER,
    x_fund_code                         IN     VARCHAR2
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2,
     x_mode				IN     VARCHAR2 DEFAULT 'R'
  );

  FUNCTION get_pk_for_validation (
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_spo_sequence_number               IN     NUMBER,
    x_fund_code                         IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_pr_stdnt_pr_ou (
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  );

  PROCEDURE get_fk_igf_aw_fund_cat (
    x_fund_code                         IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_course_cd                         IN     VARCHAR2    DEFAULT NULL,
    x_spo_sequence_number               IN     NUMBER      DEFAULT NULL,
    x_fund_code                         IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_pr_stdnt_pr_fnd_pkg;

 

/
