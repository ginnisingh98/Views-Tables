--------------------------------------------------------
--  DDL for Package IGS_AD_LOCVENUE_ADDR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_LOCVENUE_ADDR_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAIC0S.pls 115.4 2002/11/28 22:26:56 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_location_venue_addr_id            IN OUT NOCOPY NUMBER,
    x_location_id                       IN     NUMBER,
    x_location_venue_cd                 IN     VARCHAR2,
    x_source_type                       IN     VARCHAR2,
    x_identifying_address_flag          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_location_venue_addr_id            IN     NUMBER,
    x_location_id                       IN     NUMBER,
    x_location_venue_cd                 IN     VARCHAR2,
    x_source_type                       IN     VARCHAR2,
    x_identifying_address_flag          IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_location_venue_addr_id            IN     NUMBER,
    x_location_id                       IN     NUMBER,
    x_location_venue_cd                 IN     VARCHAR2,
    x_source_type                       IN     VARCHAR2,
    x_identifying_address_flag          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_location_venue_addr_id            IN OUT NOCOPY NUMBER,
    x_location_id                       IN     NUMBER,
    x_location_venue_cd                 IN     VARCHAR2,
    x_source_type                       IN     VARCHAR2,
    x_identifying_address_flag          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  PROCEDURE check_constraints (
    column_name                         IN     VARCHAR2    DEFAULT NULL,
    column_value                        IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE check_parent_existance;

  PROCEDURE check_child_existance;

  FUNCTION get_pk_for_validation (
    x_location_venue_addr_id            IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_pe_hz_locations (
    x_location_id                       IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_location_venue_addr_id            IN     NUMBER      DEFAULT NULL,
    x_location_id                       IN     NUMBER      DEFAULT NULL,
    x_location_venue_cd                 IN     VARCHAR2    DEFAULT NULL,
    x_source_type                       IN     VARCHAR2    DEFAULT NULL,
    x_identifying_address_flag          IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ad_locvenue_addr_pkg;

 

/
