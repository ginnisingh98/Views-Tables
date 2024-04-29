--------------------------------------------------------
--  DDL for Package IGF_SL_SERVICER_BRC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_SERVICER_BRC_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFLI05S.pls 115.5 2003/09/10 05:14:02 veramach ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_servicer_id                       IN     VARCHAR2,
    x_srvc_non_ed_brc_id                IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_enabled                           IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_servicer_id                       IN     VARCHAR2,
    x_srvc_non_ed_brc_id                IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_enabled                           IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_servicer_id                       IN     VARCHAR2,
    x_srvc_non_ed_brc_id                IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_enabled                           IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_servicer_id                       IN     VARCHAR2,
    x_srvc_non_ed_brc_id                IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_enabled                           IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_servicer_id                       IN     VARCHAR2,
    x_srvc_non_ed_brc_id                IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_sl_servicer (
    x_servicer_id                       IN     VARCHAR2
  );

  FUNCTION get_uk_for_validation (
    x_party_id                           IN     NUMBER
  ) RETURN BOOLEAN;
 ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 3-SEP-2003
  --
  --Purpose:
  --   Check uniquness of all unique key fields
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_servicer_id                       IN     VARCHAR2    DEFAULT NULL,
    x_srvc_non_ed_brc_id                IN     VARCHAR2    DEFAULT NULL,
    x_description                       IN     VARCHAR2    DEFAULT NULL,
    x_party_id                          IN     NUMBER      DEFAULT NULL,
    x_enabled                           IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_sl_servicer_brc_pkg;

 

/
