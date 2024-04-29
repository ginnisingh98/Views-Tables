--------------------------------------------------------
--  DDL for Package IGS_SS_TEST_CONF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_SS_TEST_CONF_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAIC3S.pls 115.4 2002/11/28 22:27:42 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_test_config_id                    IN OUT NOCOPY NUMBER,
    x_source_type_id                    IN     NUMBER,
    x_admission_test_type               IN     VARCHAR2,
    x_inactive                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_test_config_id                    IN     NUMBER,
    x_source_type_id                    IN     NUMBER,
    x_admission_test_type               IN     VARCHAR2,
    x_inactive                          IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_test_config_id                    IN     NUMBER,
    x_source_type_id                    IN     NUMBER,
    x_admission_test_type               IN     VARCHAR2,
    x_inactive                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_test_config_id                    IN OUT NOCOPY NUMBER,
    x_source_type_id                    IN     NUMBER,
    x_admission_test_type               IN     VARCHAR2,
    x_inactive                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_test_config_id                    IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_source_type_id                    IN     NUMBER,
    x_admission_test_type               IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_test_config_id                    IN     NUMBER      DEFAULT NULL,
    x_source_type_id                    IN     NUMBER      DEFAULT NULL,
    x_admission_test_type               IN     VARCHAR2    DEFAULT NULL,
    x_inactive                          IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ss_test_conf_pkg;

 

/
