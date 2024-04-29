--------------------------------------------------------
--  DDL for Package IGS_AS_SUA_REF_CDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_SUA_REF_CDS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSDI84S.pls 120.0 2005/09/16 15:43:34 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_suar_id                           IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_reference_code_id                 IN     NUMBER,
    x_reference_cd_type                 IN     VARCHAR2,
    x_reference_cd                      IN     VARCHAR2,
    x_applied_course_cd                 IN     VARCHAR2,
    x_deleted_date                      IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_suar_id                           IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_reference_code_id                 IN     NUMBER,
    x_reference_cd_type                 IN     VARCHAR2,
    x_reference_cd                      IN     VARCHAR2,
    x_applied_course_cd                 IN     VARCHAR2,
    x_deleted_date                      IN     DATE
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_suar_id                           IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_reference_code_id                 IN     NUMBER,
    x_reference_cd_type                 IN     VARCHAR2,
    x_reference_cd                      IN     VARCHAR2,
    x_applied_course_cd                 IN     VARCHAR2,
    x_deleted_date                      IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_suar_id                           IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_reference_code_id                 IN     NUMBER,
    x_reference_cd_type                 IN     VARCHAR2,
    x_reference_cd                      IN     VARCHAR2,
    x_applied_course_cd                 IN     VARCHAR2,
    x_deleted_date                      IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_suar_id                           IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_reference_code_id                 IN     NUMBER,
    x_applied_course_cd                 IN     VARCHAR2,
    x_deleted_date                      IN     DATE
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_suar_id                           IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_course_cd                         IN     VARCHAR2    DEFAULT NULL,
    x_uoo_id                            IN     NUMBER      DEFAULT NULL,
    x_reference_code_id                 IN     NUMBER      DEFAULT NULL,
    x_reference_cd_type                 IN     VARCHAR2    DEFAULT NULL,
    x_reference_cd                      IN     VARCHAR2    DEFAULT NULL,
    x_applied_course_cd                 IN     VARCHAR2    DEFAULT NULL,
    x_deleted_date                      IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE Get_UFK_Igs_As_Sua_Ref_Cds (
    x_reference_cd_type IN VARCHAR2,
    x_reference_cd IN VARCHAR2
  );

END igs_as_sua_ref_cds_pkg;

 

/
