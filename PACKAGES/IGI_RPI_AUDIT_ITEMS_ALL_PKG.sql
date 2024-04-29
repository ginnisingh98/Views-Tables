--------------------------------------------------------
--  DDL for Package IGI_RPI_AUDIT_ITEMS_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_RPI_AUDIT_ITEMS_ALL_PKG" AUTHID CURRENT_USER AS
/* $Header: igiraias.pls 120.3.12000000.1 2007/08/31 05:52:33 mbremkum noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_item_id                           IN     NUMBER,
    x_price                             IN     NUMBER,
    x_effective_date                    IN     DATE,
    x_revised_effective_date            IN     DATE,
    x_revised_price                     IN     NUMBER,
    x_run_id                            IN     NUMBER,
    x_org_id                            IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_item_id                           IN     NUMBER,
    x_price                             IN     NUMBER,
    x_effective_date                    IN     DATE,
    x_revised_effective_date            IN     DATE,
    x_revised_price                     IN     NUMBER,
    x_run_id                            IN     NUMBER,
    x_org_id                            IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_item_id                           IN     NUMBER,
    x_price                             IN     NUMBER,
    x_effective_date                    IN     DATE,
    x_revised_effective_date            IN     DATE,
    x_revised_price                     IN     NUMBER,
    x_run_id                            IN     NUMBER,
    x_org_id                            IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_item_id                           IN     NUMBER,
    x_price                             IN     NUMBER,
    x_effective_date                    IN     DATE,
    x_revised_effective_date            IN     DATE,
    x_revised_price                     IN     NUMBER,
    x_run_id                            IN     NUMBER,
    x_org_id                            IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_item_id                           IN     NUMBER      DEFAULT NULL,
    x_price                             IN     NUMBER      DEFAULT NULL,
    x_effective_date                    IN     DATE        DEFAULT NULL,
    x_revised_effective_date            IN     DATE        DEFAULT NULL,
    x_revised_price                     IN     NUMBER      DEFAULT NULL,
    x_run_id                            IN     NUMBER      DEFAULT NULL,
    x_org_id                            IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igi_rpi_audit_items_all_pkg;

 

/
