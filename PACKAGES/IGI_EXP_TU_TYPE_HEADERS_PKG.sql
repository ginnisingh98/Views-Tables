--------------------------------------------------------
--  DDL for Package IGI_EXP_TU_TYPE_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_EXP_TU_TYPE_HEADERS_PKG" AUTHID CURRENT_USER AS
/* $Header: igiexpus.pls 120.4.12000000.1 2007/09/13 04:24:55 mbremkum ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_tu_type_header_id                 IN OUT NOCOPY NUMBER,
    x_tu_type_name                      IN     VARCHAR2,
    x_tu_type_desc                      IN     VARCHAR2,
    x_apprv_profile_id                  IN     NUMBER,
    x_allow_override                    IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_org_id                            IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_tu_type_header_id                 IN     NUMBER,
    x_tu_type_name                      IN     VARCHAR2,
    x_tu_type_desc                      IN     VARCHAR2,
    x_apprv_profile_id                  IN     NUMBER,
    x_allow_override                    IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_org_id                            IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_tu_type_header_id                 IN     NUMBER,
    x_tu_type_name                      IN     VARCHAR2,
    x_tu_type_desc                      IN     VARCHAR2,
    x_apprv_profile_id                  IN     NUMBER,
    x_allow_override                    IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_org_id                            IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_tu_type_header_id                 IN OUT NOCOPY NUMBER,
    x_tu_type_name                      IN     VARCHAR2,
    x_tu_type_desc                      IN     VARCHAR2,
    x_apprv_profile_id                  IN     NUMBER,
    x_allow_override                    IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_org_id                            IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_tu_type_header_id                 IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igi_exp_apprv_profiles (
    x_apprv_profile_id                  IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_tu_type_header_id                 IN     NUMBER      DEFAULT NULL,
    x_tu_type_name                      IN     VARCHAR2    DEFAULT NULL,
    x_tu_type_desc                      IN     VARCHAR2    DEFAULT NULL,
    x_apprv_profile_id                  IN     NUMBER      DEFAULT NULL,
    x_allow_override                    IN     VARCHAR2    DEFAULT NULL,
    x_start_date                        IN     DATE        DEFAULT NULL,
    x_end_date                          IN     DATE        DEFAULT NULL,
    x_org_id                            IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igi_exp_tu_type_headers_pkg;

 

/
