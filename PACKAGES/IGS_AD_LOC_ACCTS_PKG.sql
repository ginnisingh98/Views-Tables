--------------------------------------------------------
--  DDL for Package IGS_AD_LOC_ACCTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_LOC_ACCTS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAIF1S.pls 115.4 2002/11/28 22:34:44 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_location_account_id               IN OUT NOCOPY NUMBER,
    x_location_cd                       IN     VARCHAR2,
    x_segment                           IN     VARCHAR2,
    x_segment_num                       IN     NUMBER,
    x_segment_value                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_location_account_id               IN     NUMBER,
    x_location_cd                       IN     VARCHAR2,
    x_segment                           IN     VARCHAR2,
    x_segment_num                       IN     NUMBER,
    x_segment_value                     IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_location_account_id               IN     NUMBER,
    x_location_cd                       IN     VARCHAR2,
    x_segment                           IN     VARCHAR2,
    x_segment_num                       IN     NUMBER,
    x_segment_value                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_location_account_id               IN OUT NOCOPY NUMBER,
    x_location_cd                       IN     VARCHAR2,
    x_segment                           IN     VARCHAR2,
    x_segment_num                       IN     NUMBER,
    x_segment_value                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_location_account_id               IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ad_location (
    x_location_cd                       IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_location_account_id               IN     NUMBER      DEFAULT NULL,
    x_location_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_segment                           IN     VARCHAR2    DEFAULT NULL,
    x_segment_num                       IN     NUMBER      DEFAULT NULL,
    x_segment_value                     IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ad_loc_accts_pkg;

 

/
