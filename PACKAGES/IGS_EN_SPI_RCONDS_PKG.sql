--------------------------------------------------------
--  DDL for Package IGS_EN_SPI_RCONDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_SPI_RCONDS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI81S.pls 120.0 2006/04/10 04:56:50 bdeviset noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_logical_delete_date               IN     DATE,
    x_return_condition                          IN     VARCHAR2,
    x_status_code                            IN     VARCHAR2 DEFAULT 'PENDING',
    x_approved_dt                       IN     DATE,
    x_approved_by                       IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_logical_delete_date               IN     DATE,
    x_return_condition                          IN     VARCHAR2,
    x_status_code                            IN     VARCHAR2,
    x_approved_dt                       IN     DATE,
    x_approved_by                       IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_logical_delete_date               IN     DATE,
    x_return_condition                          IN     VARCHAR2,
    x_status_code                            IN     VARCHAR2,
    x_approved_dt                       IN     DATE,
    x_approved_by                       IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_logical_delete_date               IN     DATE,
    x_return_condition                          IN     VARCHAR2,
    x_status_code                            IN     VARCHAR2,
    x_approved_dt                       IN     DATE,
    x_approved_by                       IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_logical_delete_date               IN     DATE,
    x_return_condition                          IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_en_stdnt_ps_intm
  ( x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_start_dt IN DATE,
    x_logical_delete_date IN DATE
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_course_cd                         IN     VARCHAR2    DEFAULT NULL,
    x_start_dt                          IN     DATE        DEFAULT NULL,
    x_logical_delete_date               IN     DATE        DEFAULT NULL,
    x_return_condition                          IN     VARCHAR2    DEFAULT NULL,
    x_status_code                            IN     VARCHAR2    DEFAULT NULL,
    x_approved_dt                       IN     DATE        DEFAULT NULL,
    x_approved_by                       IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_en_spi_rconds_pkg;

 

/
