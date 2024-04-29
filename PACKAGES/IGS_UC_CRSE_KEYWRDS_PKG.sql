--------------------------------------------------------
--  DDL for Package IGS_UC_CRSE_KEYWRDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_CRSE_KEYWRDS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSXI15S.pls 120.1 2005/09/27 19:34:22 appldev ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ucas_program_code                 IN     VARCHAR2,
    x_institute                         IN     VARCHAR2,
    x_ucas_campus                       IN     VARCHAR2,
    x_option_code                       IN     VARCHAR2,
    x_preference                        IN     NUMBER,
    x_keyword                           IN     VARCHAR2,
    x_updater                           IN     VARCHAR2,
    x_active                            IN     VARCHAR2,
    x_deleted                           IN     VARCHAR2,
    x_sent_to_ucas                      IN     VARCHAR2,
    x_system_code                       IN      VARCHAR2 DEFAULT NULL,
    x_crse_keyword_id                   IN OUT NOCOPY    NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_ucas_program_code                 IN     VARCHAR2,
    x_institute                         IN     VARCHAR2,
    x_ucas_campus                       IN     VARCHAR2,
    x_option_code                       IN     VARCHAR2,
    x_preference                        IN     NUMBER,
    x_keyword                           IN     VARCHAR2,
    x_updater                           IN     VARCHAR2,
    x_active                            IN     VARCHAR2,
    x_deleted                           IN     VARCHAR2,
    x_sent_to_ucas                      IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2 DEFAULT NULL,
    x_crse_keyword_id                   IN     NUMBER  DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_ucas_program_code                 IN     VARCHAR2,
    x_institute                         IN     VARCHAR2,
    x_ucas_campus                       IN     VARCHAR2,
    x_option_code                       IN     VARCHAR2,
    x_preference                        IN     NUMBER,
    x_keyword                           IN     VARCHAR2,
    x_updater                           IN     VARCHAR2,
    x_active                            IN     VARCHAR2,
    x_deleted                           IN     VARCHAR2,
    x_sent_to_ucas                      IN     VARCHAr2 ,
    x_system_code                       IN     VARCHAR2 DEFAULT NULL,
    x_crse_keyword_id                   IN     NUMBER DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ucas_program_code                 IN     VARCHAR2,
    x_institute                         IN     VARCHAR2,
    x_ucas_campus                       IN     VARCHAR2,
    x_option_code                       IN     VARCHAR2,
    x_preference                        IN     NUMBER,
    x_keyword                           IN     VARCHAR2,
    x_updater                           IN     VARCHAR2,
    x_active                            IN     VARCHAR2,
    x_deleted                           IN     VARCHAR2,
    x_sent_to_ucas                      IN     VARCHAR2 ,
    x_system_code                       IN     VARCHAR2 DEFAULT NULL,
    x_crse_keyword_id                   IN OUT NOCOPY    NUMBER ,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_uk_for_validation (
    x_ucas_program_code                 IN     VARCHAR2,
    x_institute                         IN     VARCHAR2,
    x_ucas_campus                       IN     VARCHAR2,
    x_option_code                       IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_keyword                           IN     VARCHAR2
  ) RETURN BOOLEAN;


 FUNCTION get_pk_for_validation (
    x_crse_keyword_id NUMBER
  ) RETURN BOOLEAN;


  PROCEDURE get_fk_igs_uc_ref_keywords (
    x_keyword                           IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_uc_crse_dets (
    x_ucas_program_code                 IN     VARCHAR2,
    x_institute                         IN     VARCHAR2,
    x_ucas_campus                       IN     VARCHAR2   ,
    x_system_code                       IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_ucas_program_code                 IN     VARCHAR2    DEFAULT NULL,
    x_institute                         IN     VARCHAR2    DEFAULT NULL,
    x_ucas_campus                       IN     VARCHAR2    DEFAULT NULL,
    x_option_code                       IN     VARCHAR2    DEFAULT NULL,
    x_preference                        IN     NUMBER      DEFAULT NULL,
    x_keyword                           IN     VARCHAR2    DEFAULT NULL,
    x_updater                           IN     VARCHAR2    DEFAULT NULL,
    x_active                            IN     VARCHAR2    DEFAULT NULL,
    x_deleted                           IN     VARCHAR2    DEFAULT NULL,
    x_sent_to_ucas                      IN     VARCHAR2    DEFAULT NULL,
    x_system_code                       IN     VARCHAR2    DEFAULT NULL,
    x_crse_keyword_id                   IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_uc_crse_keywrds_pkg;

 

/
