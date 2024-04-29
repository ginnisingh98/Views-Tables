--------------------------------------------------------
--  DDL for Package IGF_AP_APPL_STATUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_APPL_STATUS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFAI77S.pls 120.0 2005/09/09 17:12:00 appldev noship $ */

  FUNCTION get_pk_for_validation (
    x_base_id                           IN     NUMBER,
    x_application_code                  IN     VARCHAR2
  ) RETURN BOOLEAN ;

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_application_code                  IN     VARCHAR2,
    x_base_id                           IN OUT NOCOPY NUMBER,
    x_application_status_code           IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_application_code                  IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_application_status_code           IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_application_code                  IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_application_status_code           IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_application_code                  IN     VARCHAR2,
    x_base_id                           IN OUT NOCOPY NUMBER,
    x_application_status_code           IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_application_code                  IN     VARCHAR2    DEFAULT NULL,
    x_base_id                           IN     NUMBER      DEFAULT NULL,
    x_application_status_code           IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_ap_appl_status_pkg;

 

/
