--------------------------------------------------------
--  DDL for Package IGS_AD_PESTAT_GROUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_PESTAT_GROUP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAIG4S.pls 120.1 2005/08/03 06:46:00 appldev ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_group_number                      IN     NUMBER,
    x_admission_application_type        IN     VARCHAR2,
    x_group_min                         IN     NUMBER,
    x_self_message                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_group_name                        IN     VARCHAR2    DEFAULT NULL,
    x_group_required_flag               IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_group_number                      IN     NUMBER,
    x_admission_application_type        IN     VARCHAR2,
    x_group_min                         IN     NUMBER,
    x_self_message                      IN     VARCHAR2,
    x_group_name                        IN     VARCHAR2    DEFAULT NULL,
    x_group_required_flag               IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_group_number                      IN     NUMBER,
    x_admission_application_type        IN     VARCHAR2,
    x_group_min                         IN     NUMBER,
    x_self_message                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_group_name                        IN     VARCHAR2    DEFAULT NULL,
    x_group_required_flag               IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_group_number                      IN     NUMBER,
    x_admission_application_type        IN     VARCHAR2,
    x_group_min                         IN     NUMBER,
    x_self_message                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_group_name                        IN     VARCHAR2    DEFAULT NULL,
    x_group_required_flag               IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_group_number                      IN     NUMBER,
    x_admission_application_type        IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ad_ss_appl_typ (
    x_admission_appl_type               IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_group_number                      IN     NUMBER      DEFAULT NULL,
    x_admission_application_type        IN     VARCHAR2    DEFAULT NULL,
    x_group_min                         IN     NUMBER      DEFAULT NULL,
    x_self_message                      IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_group_name                        IN     VARCHAR2    DEFAULT NULL,
    x_group_required_flag               IN     VARCHAR2    DEFAULT NULL
  );

END igs_ad_pestat_group_pkg;

 

/
