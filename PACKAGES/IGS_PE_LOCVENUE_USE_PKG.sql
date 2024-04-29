--------------------------------------------------------
--  DDL for Package IGS_PE_LOCVENUE_USE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_LOCVENUE_USE_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNI76S.pls 115.4 2002/11/29 01:31:24 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_locvenue_use_id                   IN OUT NOCOPY NUMBER,
    x_loc_venue_addr_id                 IN     NUMBER,
    x_site_use_code                     IN     VARCHAR2,
    x_active_ind                        IN     VARCHAR2,
    x_location                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_locvenue_use_id                   IN     NUMBER,
    x_loc_venue_addr_id                 IN     NUMBER,
    x_site_use_code                     IN     VARCHAR2,
    x_active_ind                        IN     VARCHAR2,
    x_location                          IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_locvenue_use_id                   IN     NUMBER,
    x_loc_venue_addr_id                 IN     NUMBER,
    x_site_use_code                     IN     VARCHAR2,
    x_active_ind                        IN     VARCHAR2,
    x_location                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_locvenue_use_id                   IN OUT NOCOPY NUMBER,
    x_loc_venue_addr_id                 IN     NUMBER,
    x_site_use_code                     IN     VARCHAR2,
    x_active_ind                        IN     VARCHAR2,
    x_location                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_locvenue_use_id                   IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ad_locvenue_addr (
    x_location_venue_addr_id            IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_locvenue_use_id                   IN     NUMBER      DEFAULT NULL,
    x_loc_venue_addr_id                 IN     NUMBER      DEFAULT NULL,
    x_site_use_code                     IN     VARCHAR2    DEFAULT NULL,
    x_active_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_location                          IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

 FUNCTION get_uk_for_validation(
    x_loc_venue_addr_id  IN NUMBER,
    x_site_use_code      IN VARCHAR2
    ) RETURN BOOLEAN;

END igs_pe_locvenue_use_pkg;

 

/
