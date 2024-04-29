--------------------------------------------------------
--  DDL for Package IGS_FI_PARTY_VENDRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_PARTY_VENDRS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSIC8S.pls 115.0 2003/02/25 08:31:00 agairola noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_vendor_id                         IN     NUMBER,
    x_vendor_site_id                    IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_vendor_id                         IN     NUMBER,
    x_vendor_site_id                    IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_vendor_id                         IN     NUMBER,
    x_vendor_site_id                    IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );


  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_party_id                          IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_party_id                          IN     NUMBER      DEFAULT NULL,
    x_vendor_id                         IN     NUMBER      DEFAULT NULL,
    x_vendor_site_id                    IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_fi_party_vendrs_pkg;

 

/
