--------------------------------------------------------
--  DDL for Package IGS_PE_HZ_LOCATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_HZ_LOCATIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNI71S.pls 120.0 2005/06/02 04:19:02 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_location_id                       IN     NUMBER,
    x_other_details_1                   IN     VARCHAR2,
    x_other_details_2                   IN     VARCHAR2,
    x_other_details_3                   IN     VARCHAR2,
    x_date_last_verified                IN     DATE,
    x_contact_person                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_location_id                       IN     NUMBER,
    x_other_details_1                   IN     VARCHAR2,
    x_other_details_2                   IN     VARCHAR2,
    x_other_details_3                   IN     VARCHAR2,
    x_date_last_verified                IN     DATE,
    x_contact_person                    IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_location_id                       IN     NUMBER,
    x_other_details_1                   IN     VARCHAR2,
    x_other_details_2                   IN     VARCHAR2,
    x_other_details_3                   IN     VARCHAR2,
    x_date_last_verified                IN     DATE,
    x_contact_person                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_location_id                       IN     NUMBER,
    x_other_details_1                   IN     VARCHAR2,
    x_other_details_2                   IN     VARCHAR2,
    x_other_details_3                   IN     VARCHAR2,
    x_date_last_verified                IN     DATE,
    x_contact_person                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

PROCEDURE Check_Parent_Existance;

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
  );

  FUNCTION get_pk_for_validation (
    x_location_id                       IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_location_id                       IN     NUMBER      DEFAULT NULL,
    x_other_details_1                   IN     VARCHAR2    DEFAULT NULL,
    x_other_details_2                   IN     VARCHAR2    DEFAULT NULL,
    x_other_details_3                   IN     VARCHAR2    DEFAULT NULL,
    x_date_last_verified                IN     DATE        DEFAULT NULL,
    x_contact_person                    IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_pe_hz_locations_pkg;

 

/
