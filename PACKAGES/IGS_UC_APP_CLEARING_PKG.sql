--------------------------------------------------------
--  DDL for Package IGS_UC_APP_CLEARING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_APP_CLEARING_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSXI04S.pls 115.4 2003/06/11 10:27:44 smaddali noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_clearing_app_id                   IN OUT NOCOPY NUMBER,
    x_app_id                            IN     NUMBER,
    x_enquiry_no                        IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_date_cef_sent                     IN     DATE,
    x_cef_no                            IN     NUMBER,
    x_central_clearing                  IN     VARCHAR2,
    x_institution                       IN     VARCHAR2,
    x_course                            IN     VARCHAR2,
    x_campus                            IN     VARCHAR2,
    x_entry_month                       IN     NUMBER,
    x_entry_year                        IN     NUMBER,
    x_entry_point                       IN     VARCHAR2,
    x_result                            IN     VARCHAR2,
    x_cef_received                      IN     VARCHAR2,
    x_clearing_app_source               IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_clearing_app_id                   IN     NUMBER,
    x_app_id                            IN     NUMBER,
    x_enquiry_no                        IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_date_cef_sent                     IN     DATE,
    x_cef_no                            IN     NUMBER,
    x_central_clearing                  IN     VARCHAR2,
    x_institution                       IN     VARCHAR2,
    x_course                            IN     VARCHAR2,
    x_campus                            IN     VARCHAR2,
    x_entry_month                       IN     NUMBER,
    x_entry_year                        IN     NUMBER,
    x_entry_point                       IN     VARCHAR2,
    x_result                            IN     VARCHAR2,
    x_cef_received                      IN     VARCHAR2,
    x_clearing_app_source               IN     VARCHAR2,
    x_imported                          IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_clearing_app_id                   IN     NUMBER,
    x_app_id                            IN     NUMBER,
    x_enquiry_no                        IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_date_cef_sent                     IN     DATE,
    x_cef_no                            IN     NUMBER,
    x_central_clearing                  IN     VARCHAR2,
    x_institution                       IN     VARCHAR2,
    x_course                            IN     VARCHAR2,
    x_campus                            IN     VARCHAR2,
    x_entry_month                       IN     NUMBER,
    x_entry_year                        IN     NUMBER,
    x_entry_point                       IN     VARCHAR2,
    x_result                            IN     VARCHAR2,
    x_cef_received                      IN     VARCHAR2,
    x_clearing_app_source               IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_clearing_app_id                   IN OUT NOCOPY NUMBER,
    x_app_id                            IN     NUMBER,
    x_enquiry_no                        IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_date_cef_sent                     IN     DATE,
    x_cef_no                            IN     NUMBER,
    x_central_clearing                  IN     VARCHAR2,
    x_institution                       IN     VARCHAR2,
    x_course                            IN     VARCHAR2,
    x_campus                            IN     VARCHAR2,
    x_entry_month                       IN     NUMBER,
    x_entry_year                        IN     NUMBER,
    x_entry_point                       IN     VARCHAR2,
    x_result                            IN     VARCHAR2,
    x_cef_received                      IN     VARCHAR2,
    x_clearing_app_source               IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_clearing_app_id                   IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_uc_applicants (
    x_app_id                            IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_clearing_app_id                   IN     NUMBER      DEFAULT NULL,
    x_app_id                            IN     NUMBER      DEFAULT NULL,
    x_enquiry_no                        IN     NUMBER      DEFAULT NULL,
    x_app_no                            IN     NUMBER      DEFAULT NULL,
    x_date_cef_sent                     IN     DATE        DEFAULT NULL,
    x_cef_no                            IN     NUMBER      DEFAULT NULL,
    x_central_clearing                  IN     VARCHAR2    DEFAULT NULL,
    x_institution                       IN     VARCHAR2    DEFAULT NULL,
    x_course                            IN     VARCHAR2    DEFAULT NULL,
    x_campus                            IN     VARCHAR2    DEFAULT NULL,
    x_entry_month                       IN     NUMBER      DEFAULT NULL,
    x_entry_year                        IN     NUMBER      DEFAULT NULL,
    x_entry_point                       IN     VARCHAR2    DEFAULT NULL,
    x_result                            IN     VARCHAR2    DEFAULT NULL,
    x_cef_received                      IN     VARCHAR2    DEFAULT NULL,
    x_clearing_app_source               IN     VARCHAR2    DEFAULT NULL,
    x_imported                          IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_uc_app_clearing_pkg;

 

/
