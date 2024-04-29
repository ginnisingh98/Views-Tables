--------------------------------------------------------
--  DDL for Package IGS_DA_REQ_STDNTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_DA_REQ_STDNTS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSKI49S.pls 120.0 2005/07/05 11:42:20 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_batch_id                          IN     NUMBER,
    x_igs_da_req_stdnts_id              IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_program_code                      IN     VARCHAR2,
    x_wif_program_code                  IN     VARCHAR2,
    x_special_program_code              IN     VARCHAR2,
    x_major_unit_set_cd                 IN     VARCHAR2,
    x_program_major_code                IN     VARCHAR2,
    x_report_text                       IN     CLOB,
    x_wif_id                            IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_error_code                        IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_batch_id                          IN     NUMBER,
    x_igs_da_req_stdnts_id              IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_program_code                      IN     VARCHAR2,
    x_wif_program_code                  IN     VARCHAR2,
    x_special_program_code              IN     VARCHAR2,
    x_major_unit_set_cd                 IN     VARCHAR2,
    x_program_major_code                IN     VARCHAR2,
    x_report_text                       IN     CLOB,
    x_wif_id                            IN     NUMBER,
    x_error_code                        IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_batch_id                          IN     NUMBER,
    x_igs_da_req_stdnts_id              IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_program_code                      IN     VARCHAR2,
    x_wif_program_code                  IN     VARCHAR2,
    x_special_program_code              IN     VARCHAR2,
    x_major_unit_set_cd                 IN     VARCHAR2,
    x_program_major_code                IN     VARCHAR2,
    x_report_text                       IN     CLOB,
    x_wif_id                            IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_error_code                        IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_batch_id                          IN     NUMBER,
    x_igs_da_req_stdnts_id              IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_program_code                      IN     VARCHAR2,
    x_wif_program_code                  IN     VARCHAR2,
    x_special_program_code              IN     VARCHAR2,
    x_major_unit_set_cd                 IN     VARCHAR2,
    x_program_major_code                IN     VARCHAR2,
    x_report_text                       IN     CLOB,
    x_wif_id                            IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_error_code                        IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_igs_da_req_stdnts_id              IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ps_course (
    x_course_cd                         IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_da_req_wif (
    x_batch_id                          IN     NUMBER,
    x_wif_id                            IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_batch_id                          IN     NUMBER      DEFAULT NULL,
    x_igs_da_req_stdnts_id              IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_program_code                      IN     VARCHAR2    DEFAULT NULL,
    x_wif_program_code                  IN     VARCHAR2    DEFAULT NULL,
    x_special_program_code              IN     VARCHAR2    DEFAULT NULL,
    x_major_unit_set_cd                 IN     VARCHAR2    DEFAULT NULL,
    x_program_major_code                IN     VARCHAR2    DEFAULT NULL,
    x_report_text                       IN     CLOB        DEFAULT NULL,
    x_wif_id                            IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_error_code                        IN     VARCHAR2    DEFAULT NULL
  );

END igs_da_req_stdnts_pkg;

 

/
