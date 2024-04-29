--------------------------------------------------------
--  DDL for Package IGS_FI_LB_REC_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_LB_REC_TYPES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSID4S.pls 115.0 2003/06/10 10:21:01 shtatiko noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_lockbox_name                      IN     VARCHAR2,
    x_record_identifier_cd              IN     VARCHAR2,
    x_record_type_code                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_lockbox_name                      IN     VARCHAR2,
    x_record_identifier_cd              IN     VARCHAR2,
    x_record_type_code                  IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_lockbox_name                      IN     VARCHAR2,
    x_record_identifier_cd              IN     VARCHAR2,
    x_record_type_code                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_lockbox_name                      IN     VARCHAR2,
    x_record_identifier_cd              IN     VARCHAR2,
    x_record_type_code                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_lockbox_name                      IN     VARCHAR2,
    x_record_identifier_cd              IN     VARCHAR2
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_lockbox_name                      IN     VARCHAR2,
    x_record_type_code                  IN     VARCHAR2
  ) RETURN BOOLEAN;

  -- Removed get_fk_igs_fi_lockboxes as Deletion on IGS_FI_LOCBOXES table

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_lockbox_name                      IN     VARCHAR2    DEFAULT NULL,
    x_record_identifier_cd              IN     VARCHAR2    DEFAULT NULL,
    x_record_type_code                  IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_fi_lb_rec_types_pkg;

 

/
