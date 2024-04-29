--------------------------------------------------------
--  DDL for Package IGF_GR_RFMS_ERROR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_GR_RFMS_ERROR_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFGI07S.pls 115.4 2002/11/28 14:16:50 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_edit_code                         IN     VARCHAR2,
    x_type                              IN     VARCHAR2,
    x_message                           IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_edit_code                         IN     VARCHAR2,
    x_type                              IN     VARCHAR2,
    x_message                           IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_edit_code                         IN     VARCHAR2,
    x_type                              IN     VARCHAR2,
    x_message                           IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_edit_code                         IN     VARCHAR2,
    x_type                              IN     VARCHAR2,
    x_message                           IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_edit_code                         IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_edit_code                         IN     VARCHAR2    DEFAULT NULL,
    x_type                              IN     VARCHAR2    DEFAULT NULL,
    x_message                           IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_gr_rfms_error_pkg;

 

/
