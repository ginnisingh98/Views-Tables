--------------------------------------------------------
--  DDL for Package IGS_HE_SYS_RT_CL_ASS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_SYS_RT_CL_ASS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSWI50S.pls 120.0 2006/02/06 19:28:21 anwest noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_igs_he_sys_rt_cl_ass_id           IN OUT NOCOPY NUMBER,
    x_system_return_class_type          IN     VARCHAR2,
    x_field_number                      IN     NUMBER,
    x_association_code                  IN     VARCHAR2,
    x_oss_seq                           IN     NUMBER,
    x_hesa_seq                          IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_igs_he_sys_rt_cl_ass_id           IN     NUMBER,
    x_system_return_class_type          IN     VARCHAR2,
    x_field_number                      IN     NUMBER,
    x_association_code                  IN     VARCHAR2,
    x_oss_seq                           IN     NUMBER,
    x_hesa_seq                          IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_igs_he_sys_rt_cl_ass_id           IN     NUMBER,
    x_system_return_class_type          IN     VARCHAR2,
    x_field_number                      IN     NUMBER,
    x_association_code                  IN     VARCHAR2,
    x_oss_seq                           IN     NUMBER,
    x_hesa_seq                          IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_igs_he_sys_rt_cl_ass_id           IN OUT NOCOPY NUMBER,
    x_system_return_class_type          IN     VARCHAR2,
    x_field_number                      IN     NUMBER,
    x_association_code                  IN     VARCHAR2,
    x_oss_seq                           IN     NUMBER,
    x_hesa_seq                          IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_igs_he_sys_rt_cl_ass_id           IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_system_return_class_type          IN     VARCHAR2,
    x_field_number                      IN     NUMBER,
    x_association_code                  IN     VARCHAR2,
    x_oss_seq                           IN     NUMBER,
    x_hesa_seq                          IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_he_sys_rt_cl_fld (
    x_system_return_class_type          IN     VARCHAR2,
    x_field_number                      IN     NUMBER
  );

  PROCEDURE get_fk_igs_he_code_assoc (
    x_association_code                  IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_igs_he_sys_rt_cl_ass_id           IN     NUMBER      DEFAULT NULL,
    x_system_return_class_type          IN     VARCHAR2    DEFAULT NULL,
    x_field_number                      IN     NUMBER      DEFAULT NULL,
    x_association_code                  IN     VARCHAR2    DEFAULT NULL,
    x_oss_seq                           IN     NUMBER      DEFAULT NULL,
    x_hesa_seq                          IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_he_sys_rt_cl_ass_pkg;

 

/
