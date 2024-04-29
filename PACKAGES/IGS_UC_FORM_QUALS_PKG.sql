--------------------------------------------------------
--  DDL for Package IGS_UC_FORM_QUALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_FORM_QUALS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSXI51S.pls 120.1 2005/09/27 19:34:37 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_qual_id                           IN     NUMBER,
    x_qual_type                         IN     VARCHAR2,
    x_award_body                        IN     VARCHAR2,
    x_title                             IN     VARCHAR2,
    x_grade                             IN     VARCHAR2,
    x_qual_date                         IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_qual_id                           IN     NUMBER,
    x_qual_type                         IN     VARCHAR2,
    x_award_body                        IN     VARCHAR2,
    x_title                             IN     VARCHAR2,
    x_grade                             IN     VARCHAR2,
    x_qual_date                         IN     DATE
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_qual_id                           IN     NUMBER,
    x_qual_type                         IN     VARCHAR2,
    x_award_body                        IN     VARCHAR2,
    x_title                             IN     VARCHAR2,
    x_grade                             IN     VARCHAR2,
    x_qual_date                         IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_qual_id                           IN     NUMBER,
    x_qual_type                         IN     VARCHAR2,
    x_award_body                        IN     VARCHAR2,
    x_title                             IN     VARCHAR2,
    x_grade                             IN     VARCHAR2,
    x_qual_date                         IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_uk_for_validation (
    x_app_no                            IN     NUMBER,
    x_qual_type                         IN     VARCHAR2,
    x_title                             IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_ufk_igs_uc_applicants (
    x_app_no                            IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_app_no                            IN     NUMBER      DEFAULT NULL,
    x_qual_id                           IN     NUMBER      DEFAULT NULL,
    x_qual_type                         IN     VARCHAR2    DEFAULT NULL,
    x_award_body                        IN     VARCHAR2    DEFAULT NULL,
    x_title                             IN     VARCHAR2    DEFAULT NULL,
    x_grade                             IN     VARCHAR2    DEFAULT NULL,
    x_qual_date                         IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_uc_form_quals_pkg;

 

/
