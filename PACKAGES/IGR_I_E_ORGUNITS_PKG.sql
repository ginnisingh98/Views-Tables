--------------------------------------------------------
--  DDL for Package IGR_I_E_ORGUNITS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGR_I_E_ORGUNITS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSRH10S.pls 120.0 2005/06/01 15:00:04 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ent_org_unit_id                   IN OUT NOCOPY NUMBER,
    x_party_id                          IN     NUMBER,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_inquiry_type_id                   IN     NUMBER DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_ent_org_unit_id                   IN     NUMBER,
    x_party_id                          IN     NUMBER,
    x_closed_ind                        IN     VARCHAR2,
    x_inquiry_type_id                   IN     NUMBER DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_ent_org_unit_id                   IN     NUMBER,
    x_party_id                          IN     NUMBER,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_inquiry_type_id                   IN     NUMBER DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ent_org_unit_id                   IN OUT NOCOPY NUMBER,
    x_party_id                          IN     NUMBER,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'  ,
    x_inquiry_type_id                   IN     NUMBER DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_ent_org_unit_id                   IN     NUMBER ,
    x_closed_ind                        IN     VARCHAR2 DEFAULT NULL
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_party_id                          IN     NUMBER,
    x_closed_ind                        IN     VARCHAR2 DEFAULT NULL,
    x_inquiry_type_id                   IN     NUMBER DEFAULT NULL
  ) RETURN BOOLEAN;



  PROCEDURE get_fk_igr_i_ent_stats (
    x_inquiry_type_id                   IN     NUMBER DEFAULT NULL
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_ent_org_unit_id                   IN     NUMBER      DEFAULT NULL,
    x_party_id                          IN     NUMBER      DEFAULT NULL,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_inquiry_type_id                   IN     NUMBER      DEFAULT NULL
  );

END  igr_i_e_orgunits_pkg ;

 

/
