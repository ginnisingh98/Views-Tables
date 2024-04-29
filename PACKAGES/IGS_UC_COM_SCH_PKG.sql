--------------------------------------------------------
--  DDL for Package IGS_UC_COM_SCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_COM_SCH_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSXI10S.pls 115.5 2003/06/11 10:33:02 smaddali noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_school                            IN OUT NOCOPY NUMBER,
    x_school_name                       IN     VARCHAR2,
    x_name_change_date                  IN     DATE,
    x_former_name                       IN     VARCHAR2,
    x_ncn                               IN     VARCHAR2,
    x_edexcel_ncn                       IN     VARCHAR2,
    x_dfee_code                         IN     VARCHAR2,
    x_country                           IN     NUMBER,
    x_lea                               IN     VARCHAR2,
    x_ucas_status                       IN     VARCHAR2,
    x_estab_group                       IN     VARCHAR2,
    x_school_type                       IN     VARCHAR2,
    x_stats_date                        IN     DATE,
    x_number_on_roll                    IN     NUMBER,
    x_number_in_5_form                  IN     NUMBER,
    x_number_in_6_form                  IN     NUMBER,
    x_number_to_he                      IN     NUMBER,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_school                            IN     NUMBER,
    x_school_name                       IN     VARCHAR2,
    x_name_change_date                  IN     DATE,
    x_former_name                       IN     VARCHAR2,
    x_ncn                               IN     VARCHAR2,
    x_edexcel_ncn                       IN     VARCHAR2,
    x_dfee_code                         IN     VARCHAR2,
    x_country                           IN     NUMBER,
    x_lea                               IN     VARCHAR2,
    x_ucas_status                       IN     VARCHAR2,
    x_estab_group                       IN     VARCHAR2,
    x_school_type                       IN     VARCHAR2,
    x_stats_date                        IN     DATE,
    x_number_on_roll                    IN     NUMBER,
    x_number_in_5_form                  IN     NUMBER,
    x_number_in_6_form                  IN     NUMBER,
    x_number_to_he                      IN     NUMBER,
    x_imported                          IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_school                            IN     NUMBER,
    x_school_name                       IN     VARCHAR2,
    x_name_change_date                  IN     DATE,
    x_former_name                       IN     VARCHAR2,
    x_ncn                               IN     VARCHAR2,
    x_edexcel_ncn                       IN     VARCHAR2,
    x_dfee_code                         IN     VARCHAR2,
    x_country                           IN     NUMBER,
    x_lea                               IN     VARCHAR2,
    x_ucas_status                       IN     VARCHAR2,
    x_estab_group                       IN     VARCHAR2,
    x_school_type                       IN     VARCHAR2,
    x_stats_date                        IN     DATE,
    x_number_on_roll                    IN     NUMBER,
    x_number_in_5_form                  IN     NUMBER,
    x_number_in_6_form                  IN     NUMBER,
    x_number_to_he                      IN     NUMBER,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_school                            IN OUT NOCOPY NUMBER,
    x_school_name                       IN     VARCHAR2,
    x_name_change_date                  IN     DATE,
    x_former_name                       IN     VARCHAR2,
    x_ncn                               IN     VARCHAR2,
    x_edexcel_ncn                       IN     VARCHAR2,
    x_dfee_code                         IN     VARCHAR2,
    x_country                           IN     NUMBER,
    x_lea                               IN     VARCHAR2,
    x_ucas_status                       IN     VARCHAR2,
    x_estab_group                       IN     VARCHAR2,
    x_school_type                       IN     VARCHAR2,
    x_stats_date                        IN     DATE,
    x_number_on_roll                    IN     NUMBER,
    x_number_in_5_form                  IN     NUMBER,
    x_number_in_6_form                  IN     NUMBER,
    x_number_to_he                      IN     NUMBER,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_school                            IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_uc_ref_apr (
    x_country     IN NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_school                            IN     NUMBER      DEFAULT NULL,
    x_school_name                       IN     VARCHAR2    DEFAULT NULL,
    x_name_change_date                  IN     DATE        DEFAULT NULL,
    x_former_name                       IN     VARCHAR2    DEFAULT NULL,
    x_ncn                               IN     VARCHAR2    DEFAULT NULL,
    x_edexcel_ncn                       IN     VARCHAR2    DEFAULT NULL,
    x_dfee_code                         IN     VARCHAR2    DEFAULT NULL,
    x_country                           IN     NUMBER      DEFAULT NULL,
    x_lea                               IN     VARCHAR2    DEFAULT NULL,
    x_ucas_status                       IN     VARCHAR2    DEFAULT NULL,
    x_estab_group                       IN     VARCHAR2    DEFAULT NULL,
    x_school_type                       IN     VARCHAR2    DEFAULT NULL,
    x_stats_date                        IN     DATE        DEFAULT NULL,
    x_number_on_roll                    IN     NUMBER      DEFAULT NULL,
    x_number_in_5_form                  IN     NUMBER      DEFAULT NULL,
    x_number_in_6_form                  IN     NUMBER      DEFAULT NULL,
    x_number_to_he                      IN     NUMBER      DEFAULT NULL,
    x_imported                          IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_uc_com_sch_pkg;

 

/
