--------------------------------------------------------
--  DDL for Package IGS_AS_DOC_DLVY_FEE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_DOC_DLVY_FEE_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSDI68S.pls 115.2 2003/02/11 10:04:40 pathipat noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_dfee_id                           IN OUT NOCOPY NUMBER,
    x_delivery_method_type              IN     VARCHAR2,
    x_amount                            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_dfee_id                           IN     NUMBER,
    x_delivery_method_type              IN     VARCHAR2,
    x_amount                            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_dfee_id                           IN     NUMBER,
    x_delivery_method_type              IN     VARCHAR2,
    x_amount                            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_dfee_id                           IN OUT NOCOPY NUMBER,
    x_delivery_method_type              IN     VARCHAR2,
    x_amount                            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_dfee_id                           IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_delivery_method_type              IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_as_doc_dlvy_typ (
    x_delivery_method_type              IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_dfee_id                           IN     NUMBER      DEFAULT NULL,
    x_delivery_method_type              IN     VARCHAR2    DEFAULT NULL,
    x_amount                            IN     NUMBER      DEFAULT NULL,
    x_fee_type                          IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_as_doc_dlvy_fee_pkg;

 

/
