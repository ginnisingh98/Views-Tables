--------------------------------------------------------
--  DDL for Package IGS_AD_CRT_APPL_CFG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_CRT_APPL_CFG_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAIH6S.pls 120.1 2005/09/08 14:32:39 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_responsibility                    IN     VARCHAR2,
    x_component_code                    IN OUT NOCOPY VARCHAR2,
    x_display_name                      IN     VARCHAR2,
    x_included_flag                     IN     VARCHAR2,
    x_required_flag                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_responsibility                    IN     VARCHAR2,
    x_component_code                    IN     VARCHAR2,
    x_display_name                      IN     VARCHAR2,
    x_included_flag                     IN     VARCHAR2,
    x_required_flag                     IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_responsibility                    IN     VARCHAR2,
    x_component_code                    IN     VARCHAR2,
    x_display_name                      IN     VARCHAR2,
    x_included_flag                     IN     VARCHAR2,
    x_required_flag                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_responsibility                    IN     VARCHAR2,
    x_component_code                    IN OUT NOCOPY VARCHAR2,
    x_display_name                      IN     VARCHAR2,
    x_included_flag                     IN     VARCHAR2,
    x_required_flag                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_responsibility                    IN     VARCHAR2,
    x_component_code                    IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_responsibility                    IN     VARCHAR2    DEFAULT NULL,
    x_component_code                    IN     VARCHAR2    DEFAULT NULL,
    x_display_name                      IN     VARCHAR2    DEFAULT NULL,
    x_included_flag                     IN     VARCHAR2    DEFAULT NULL,
    x_required_flag                     IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ad_crt_appl_cfg_pkg;

 

/
