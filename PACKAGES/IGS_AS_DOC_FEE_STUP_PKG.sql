--------------------------------------------------------
--  DDL for Package IGS_AS_DOC_FEE_STUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_DOC_FEE_STUP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSDI69S.pls 115.2 2003/02/11 09:47:39 pathipat noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_tfee_id                           IN OUT NOCOPY NUMBER,
    x_document_type                     IN     VARCHAR2,
    x_lower_range                       IN     NUMBER,
    x_upper_range                       IN     NUMBER,
    x_payment_type                      IN     VARCHAR2,
    x_amount                            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_tfee_id                           IN     NUMBER,
    x_document_type                     IN     VARCHAR2,
    x_lower_range                       IN     NUMBER,
    x_upper_range                       IN     NUMBER,
    x_payment_type                      IN     VARCHAR2,
    x_amount                            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_tfee_id                           IN     NUMBER,
    x_document_type                     IN     VARCHAR2,
    x_lower_range                       IN     NUMBER,
    x_upper_range                       IN     NUMBER,
    x_payment_type                      IN     VARCHAR2,
    x_amount                            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_tfee_id                           IN OUT NOCOPY NUMBER,
    x_document_type                     IN     VARCHAR2,
    x_lower_range                       IN     NUMBER,
    x_upper_range                       IN     NUMBER,
    x_payment_type                      IN     VARCHAR2,
    x_amount                            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_tfee_id                           IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_document_type                     IN     VARCHAR2,
    x_lower_range                       IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_tfee_id                           IN     NUMBER      DEFAULT NULL,
    x_document_type                     IN     VARCHAR2    DEFAULT NULL,
    x_lower_range                       IN     NUMBER      DEFAULT NULL,
    x_upper_range                       IN     NUMBER      DEFAULT NULL,
    x_payment_type                      IN     VARCHAR2    DEFAULT NULL,
    x_amount                            IN     NUMBER      DEFAULT NULL,
    x_fee_type                          IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_as_doc_fee_stup_pkg;

 

/
