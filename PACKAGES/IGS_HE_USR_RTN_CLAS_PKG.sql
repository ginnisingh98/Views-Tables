--------------------------------------------------------
--  DDL for Package IGS_HE_USR_RTN_CLAS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_USR_RTN_CLAS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSWI15S.pls 115.3 2002/11/29 04:38:43 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_usr_rtn_clas_id                   IN OUT NOCOPY NUMBER,
    x_system_return_class_type          IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_record_id                         IN     VARCHAR2,
    x_rec_id_seg1                       IN     VARCHAR2,
    x_rec_id_seg2                       IN     VARCHAR2,
    x_rec_id_seg3                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_usr_rtn_clas_id                   IN     NUMBER,
    x_system_return_class_type          IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_record_id                         IN     VARCHAR2,
    x_rec_id_seg1                       IN     VARCHAR2,
    x_rec_id_seg2                       IN     VARCHAR2,
    x_rec_id_seg3                       IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_usr_rtn_clas_id                   IN     NUMBER,
    x_system_return_class_type          IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_record_id                         IN     VARCHAR2,
    x_rec_id_seg1                       IN     VARCHAR2,
    x_rec_id_seg2                       IN     VARCHAR2,
    x_rec_id_seg3                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_usr_rtn_clas_id                   IN OUT NOCOPY NUMBER,
    x_system_return_class_type          IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_record_id                         IN     VARCHAR2,
    x_rec_id_seg1                       IN     VARCHAR2,
    x_rec_id_seg2                       IN     VARCHAR2,
    x_rec_id_seg3                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_user_return_subclass              IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_he_sys_rtn_clas (
    x_system_return_class_type          IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_usr_rtn_clas_id                   IN     NUMBER      DEFAULT NULL,
    x_system_return_class_type          IN     VARCHAR2    DEFAULT NULL,
    x_user_return_subclass              IN     VARCHAR2    DEFAULT NULL,
    x_description                       IN     VARCHAR2    DEFAULT NULL,
    x_record_id                         IN     VARCHAR2    DEFAULT NULL,
    x_rec_id_seg1                       IN     VARCHAR2    DEFAULT NULL,
    x_rec_id_seg2                       IN     VARCHAR2    DEFAULT NULL,
    x_rec_id_seg3                       IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_he_usr_rtn_clas_pkg;

 

/
