--------------------------------------------------------
--  DDL for Package IGS_CO_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CO_TYPE_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSLI23S.pls 115.8 2002/11/29 01:07:34 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_correspondence_type               IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_sys_generated_ind                 IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_job_application_id                IN     NUMBER,
    x_job_program_id                    IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_correspondence_type               IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_sys_generated_ind                 IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_job_application_id                IN     NUMBER,
    x_job_program_id                    IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_correspondence_type               IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_sys_generated_ind                 IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_job_application_id                IN     NUMBER,
    x_job_program_id                    IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_correspondence_type               IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_sys_generated_ind                 IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_job_application_id                IN     NUMBER,
    x_job_program_id                    IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  PROCEDURE check_constraints (
    column_name                         IN     VARCHAR2    DEFAULT NULL,
    column_value                        IN     VARCHAR2    DEFAULT NULL
  );

  FUNCTION get_pk_for_validation (
    x_correspondence_type               IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_correspondence_type               IN     VARCHAR2    DEFAULT NULL,
    x_description                       IN     VARCHAR2    DEFAULT NULL,
    x_sys_generated_ind                 IN     VARCHAR2    DEFAULT NULL,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_job_application_id                IN     NUMBER      DEFAULT NULL,
    x_job_program_id                    IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_co_type_pkg;

 

/
