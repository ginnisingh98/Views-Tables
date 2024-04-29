--------------------------------------------------------
--  DDL for Package IGS_FI_1098T_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_1098T_DTLS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSIE9S.pls 120.0 2005/09/09 19:19:35 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_stu_1098t_id                      IN     NUMBER,
    x_box_num                           IN     NUMBER,
    x_transaction_id                    IN     NUMBER,
    x_transaction_code                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_stu_1098t_id                      IN     NUMBER,
    x_box_num                           IN     NUMBER,
    x_transaction_id                    IN     NUMBER,
    x_transaction_code                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_stu_1098t_id                      IN     NUMBER,
    x_box_num                           IN     NUMBER,
    x_transaction_id                    IN     NUMBER,
    x_transaction_code                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_stu_1098t_id                      IN     NUMBER,
    x_box_num                           IN     NUMBER,
    x_transaction_id                    IN     NUMBER,
    x_transaction_code                  IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_stu_1098t_id                      IN     NUMBER      DEFAULT NULL,
    x_box_num                           IN     NUMBER      DEFAULT NULL,
    x_transaction_id                    IN     NUMBER      DEFAULT NULL,
    x_transaction_code                  IN     VARCHAR2    DEFAULT NULL,
    x_object_version_number             IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_fi_1098t_dtls_pkg;

 

/
