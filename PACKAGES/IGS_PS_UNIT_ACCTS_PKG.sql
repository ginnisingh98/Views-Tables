--------------------------------------------------------
--  DDL for Package IGS_PS_UNIT_ACCTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_UNIT_ACCTS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI2ZS.pls 115.4 2002/11/29 02:21:07 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_unit_account_id                   IN OUT NOCOPY NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_segment                           IN     VARCHAR2,
    x_segment_num                       IN     NUMBER,
    x_segment_value                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_unit_account_id                   IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_segment                           IN     VARCHAR2,
    x_segment_num                       IN     NUMBER,
    x_segment_value                     IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_unit_account_id                   IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_segment                           IN     VARCHAR2,
    x_segment_num                       IN     NUMBER,
    x_segment_value                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_unit_account_id                   IN OUT NOCOPY NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_segment                           IN     VARCHAR2,
    x_segment_num                       IN     NUMBER,
    x_segment_value                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_unit_account_id                   IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ps_unit_ver (
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_unit_account_id                   IN     NUMBER      DEFAULT NULL,
    x_unit_cd                           IN     VARCHAR2    DEFAULT NULL,
    x_version_number                    IN     NUMBER      DEFAULT NULL,
    x_segment                           IN     VARCHAR2    DEFAULT NULL,
    x_segment_num                       IN     NUMBER      DEFAULT NULL,
    x_segment_value                     IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ps_unit_accts_pkg;

 

/
