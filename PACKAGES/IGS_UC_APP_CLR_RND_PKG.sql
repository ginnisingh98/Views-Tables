--------------------------------------------------------
--  DDL for Package IGS_UC_APP_CLR_RND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_APP_CLR_RND_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSXI05S.pls 115.7 2003/06/11 10:28:20 smaddali noship $ */
  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_app_clear_round_id                IN OUT NOCOPY NUMBER,
    x_clearing_app_id                   IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_enquiry_no                        IN     NUMBER,
    x_round_no                          IN     NUMBER,
    x_institution                       IN     VARCHAR2,
    x_ucas_program_code                 IN     VARCHAR2,
    x_ucas_campus                       IN     VARCHAR2,
    x_oss_program_code                  IN     VARCHAR2,
    x_oss_program_version               IN     NUMBER,
    x_oss_location                      IN     VARCHAR2,
    x_faculty                           IN     VARCHAR2,
    x_accommodation_reqd                IN     VARCHAR2,
    x_round_type                        IN     VARCHAR2,
    x_result                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_oss_attendance_type               IN     VARCHAR2,
    x_oss_attendance_mode               IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_app_clear_round_id                IN     NUMBER,
    x_clearing_app_id                   IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_enquiry_no                        IN     NUMBER,
    x_round_no                          IN     NUMBER,
    x_institution                       IN     VARCHAR2,
    x_ucas_program_code                 IN     VARCHAR2,
    x_ucas_campus                       IN     VARCHAR2,
    x_oss_program_code                  IN     VARCHAR2,
    x_oss_program_version               IN     NUMBER,
    x_oss_location                      IN     VARCHAR2,
    x_faculty                           IN     VARCHAR2,
    x_accommodation_reqd                IN     VARCHAR2,
    x_round_type                        IN     VARCHAR2,
    x_result                            IN     VARCHAR2,
    x_oss_attendance_type               IN     VARCHAR2,
    x_oss_attendance_mode               IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_app_clear_round_id                IN     NUMBER,
    x_clearing_app_id                   IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_enquiry_no                        IN     NUMBER,
    x_round_no                          IN     NUMBER,
    x_institution                       IN     VARCHAR2,
    x_ucas_program_code                 IN     VARCHAR2,
    x_ucas_campus                       IN     VARCHAR2,
    x_oss_program_code                  IN     VARCHAR2,
    x_oss_program_version               IN     NUMBER,
    x_oss_location                      IN     VARCHAR2,
    x_faculty                           IN     VARCHAR2,
    x_accommodation_reqd                IN     VARCHAR2,
    x_round_type                        IN     VARCHAR2,
    x_result                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_oss_attendance_type               IN     VARCHAR2,
    x_oss_attendance_mode               IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_app_clear_round_id                IN OUT NOCOPY NUMBER,
    x_clearing_app_id                   IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_enquiry_no                        IN     NUMBER,
    x_round_no                          IN     NUMBER,
    x_institution                       IN     VARCHAR2,
    x_ucas_program_code                 IN     VARCHAR2,
    x_ucas_campus                       IN     VARCHAR2,
    x_oss_program_code                  IN     VARCHAR2,
    x_oss_program_version               IN     NUMBER,
    x_oss_location                      IN     VARCHAR2,
    x_faculty                           IN     VARCHAR2,
    x_accommodation_reqd                IN     VARCHAR2,
    x_round_type                        IN     VARCHAR2,
    x_result                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_oss_attendance_type               IN     VARCHAR2,
    x_oss_attendance_mode               IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_app_clear_round_id                IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_uc_crse_dets (
    x_ucas_program_code                 IN     VARCHAR2,
    x_institute                         IN     VARCHAR2,
    x_ucas_campus                       IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_uc_app_clearing (
    x_clearing_app_id                   IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_app_clear_round_id                IN     NUMBER      DEFAULT NULL,
    x_clearing_app_id                   IN     NUMBER      DEFAULT NULL,
    x_app_no                            IN     NUMBER      DEFAULT NULL,
    x_enquiry_no                        IN     NUMBER      DEFAULT NULL,
    x_round_no                          IN     NUMBER      DEFAULT NULL,
    x_institution                       IN     VARCHAR2    DEFAULT NULL,
    x_ucas_program_code                 IN     VARCHAR2    DEFAULT NULL,
    x_ucas_campus                       IN     VARCHAR2    DEFAULT NULL,
    x_oss_program_code                  IN     VARCHAR2    DEFAULT NULL,
    x_oss_program_version               IN     NUMBER      DEFAULT NULL,
    x_oss_location                      IN     VARCHAR2    DEFAULT NULL,
    x_faculty                           IN     VARCHAR2    DEFAULT NULL,
    x_accommodation_reqd                IN     VARCHAR2    DEFAULT NULL,
    x_round_type                        IN     VARCHAR2    DEFAULT NULL,
    x_result                            IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_oss_attendance_type               IN     VARCHAR2    DEFAULT NULL,
    x_oss_attendance_mode               IN     VARCHAR2    DEFAULT NULL,
    x_system_code                       IN     VARCHAR2    DEFAULT NULL
  );

END igs_uc_app_clr_rnd_pkg;

 

/
