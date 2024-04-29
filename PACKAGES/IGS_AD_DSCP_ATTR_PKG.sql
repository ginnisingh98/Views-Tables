--------------------------------------------------------
--  DDL for Package IGS_AD_DSCP_ATTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_DSCP_ATTR_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAIE1S.pls 115.3 2002/11/28 22:32:19 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_discrepancy_attr_id               IN OUT NOCOPY NUMBER,
    x_src_cat_id                        IN     NUMBER,
    x_attribute_name                    IN     VARCHAR2,
    x_discrepancy_rule_cd               IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_discrepancy_attr_id               IN     NUMBER,
    x_src_cat_id                        IN     NUMBER,
    x_attribute_name                    IN     VARCHAR2,
    x_discrepancy_rule_cd               IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_discrepancy_attr_id               IN     NUMBER,
    x_src_cat_id                        IN     NUMBER,
    x_attribute_name                    IN     VARCHAR2,
    x_discrepancy_rule_cd               IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_discrepancy_attr_id               IN OUT NOCOPY NUMBER,
    x_src_cat_id                        IN     NUMBER,
    x_attribute_name                    IN     VARCHAR2,
    x_discrepancy_rule_cd               IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_discrepancy_attr_id               IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_src_cat_id                        IN     NUMBER,
    x_attribute_name                    IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ad_source_cat_all (
    x_src_cat_id                        IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_discrepancy_attr_id               IN     NUMBER      DEFAULT NULL,
    x_src_cat_id                        IN     NUMBER      DEFAULT NULL,
    x_attribute_name                    IN     VARCHAR2    DEFAULT NULL,
    x_discrepancy_rule_cd               IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ad_dscp_attr_pkg;

 

/
