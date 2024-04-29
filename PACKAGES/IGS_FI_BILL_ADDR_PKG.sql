--------------------------------------------------------
--  DDL for Package IGS_FI_BILL_ADDR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_BILL_ADDR_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSIB8S.pls 115.3 2002/11/29 04:05:48 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_bill_addr_id                      IN OUT NOCOPY NUMBER,
    x_bill_id                           IN     NUMBER,
    x_addr_type                         IN     VARCHAR2,
    x_addr_line_1                       IN     VARCHAR2,
    x_addr_line_2                       IN     VARCHAR2,
    x_addr_line_3                       IN     VARCHAR2,
    x_addr_line_4                       IN     VARCHAR2,
    x_city                              IN     VARCHAR2,
    x_state                             IN     VARCHAR2,
    x_province                          IN     VARCHAR2,
    x_county                            IN     VARCHAR2,
    x_country                           IN     VARCHAR2,
    x_postal_code                       IN     VARCHAR2,
    x_delivery_point_code               IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_bill_addr_id                      IN     NUMBER,
    x_bill_id                           IN     NUMBER,
    x_addr_type                         IN     VARCHAR2,
    x_addr_line_1                       IN     VARCHAR2,
    x_addr_line_2                       IN     VARCHAR2,
    x_addr_line_3                       IN     VARCHAR2,
    x_addr_line_4                       IN     VARCHAR2,
    x_city                              IN     VARCHAR2,
    x_state                             IN     VARCHAR2,
    x_province                          IN     VARCHAR2,
    x_county                            IN     VARCHAR2,
    x_country                           IN     VARCHAR2,
    x_postal_code                       IN     VARCHAR2,
    x_delivery_point_code               IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_bill_addr_id                      IN     NUMBER,
    x_bill_id                           IN     NUMBER,
    x_addr_type                         IN     VARCHAR2,
    x_addr_line_1                       IN     VARCHAR2,
    x_addr_line_2                       IN     VARCHAR2,
    x_addr_line_3                       IN     VARCHAR2,
    x_addr_line_4                       IN     VARCHAR2,
    x_city                              IN     VARCHAR2,
    x_state                             IN     VARCHAR2,
    x_province                          IN     VARCHAR2,
    x_county                            IN     VARCHAR2,
    x_country                           IN     VARCHAR2,
    x_postal_code                       IN     VARCHAR2,
    x_delivery_point_code               IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_bill_addr_id                      IN OUT NOCOPY NUMBER,
    x_bill_id                           IN     NUMBER,
    x_addr_type                         IN     VARCHAR2,
    x_addr_line_1                       IN     VARCHAR2,
    x_addr_line_2                       IN     VARCHAR2,
    x_addr_line_3                       IN     VARCHAR2,
    x_addr_line_4                       IN     VARCHAR2,
    x_city                              IN     VARCHAR2,
    x_state                             IN     VARCHAR2,
    x_province                          IN     VARCHAR2,
    x_county                            IN     VARCHAR2,
    x_country                           IN     VARCHAR2,
    x_postal_code                       IN     VARCHAR2,
    x_delivery_point_code               IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_bill_addr_id                      IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_fi_bill (
    x_bill_id                           IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_bill_addr_id                      IN     NUMBER      DEFAULT NULL,
    x_bill_id                           IN     NUMBER      DEFAULT NULL,
    x_addr_type                         IN     VARCHAR2    DEFAULT NULL,
    x_addr_line_1                       IN     VARCHAR2    DEFAULT NULL,
    x_addr_line_2                       IN     VARCHAR2    DEFAULT NULL,
    x_addr_line_3                       IN     VARCHAR2    DEFAULT NULL,
    x_addr_line_4                       IN     VARCHAR2    DEFAULT NULL,
    x_city                              IN     VARCHAR2    DEFAULT NULL,
    x_state                             IN     VARCHAR2    DEFAULT NULL,
    x_province                          IN     VARCHAR2    DEFAULT NULL,
    x_county                            IN     VARCHAR2    DEFAULT NULL,
    x_country                           IN     VARCHAR2    DEFAULT NULL,
    x_postal_code                       IN     VARCHAR2    DEFAULT NULL,
    x_delivery_point_code               IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_fi_bill_addr_pkg;

 

/
