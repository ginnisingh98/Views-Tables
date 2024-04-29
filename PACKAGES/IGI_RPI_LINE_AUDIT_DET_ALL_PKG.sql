--------------------------------------------------------
--  DDL for Package IGI_RPI_LINE_AUDIT_DET_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_RPI_LINE_AUDIT_DET_ALL_PKG" AUTHID CURRENT_USER AS
/* $Header: igirlads.pls 120.3.12010000.2 2010/02/08 23:20:23 gaprasad ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_standing_charge_id                IN     NUMBER,
    x_line_item_id                      IN     NUMBER,
    x_charge_item_number                IN     NUMBER,
    x_item_id                           IN     NUMBER,
    x_price                             IN     NUMBER,
    x_effective_date                    IN     DATE,
    x_revised_price                     IN     NUMBER,
    x_revised_effective_date            IN     DATE,
    x_run_id                            IN     NUMBER,
    x_org_id                            IN     NUMBER,
    x_previous_price                    IN     NUMBER,
    x_previous_effective_date           IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_old_vat_id                        IN     NUMBER      DEFAULT NULL,
    x_new_vat_id                        IN     NUMBER      DEFAULT NULL,
    x_request_id                        IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_standing_charge_id                IN     NUMBER,
    x_line_item_id                      IN     NUMBER,
    x_charge_item_number                IN     NUMBER,
    x_item_id                           IN     NUMBER,
    x_price                             IN     NUMBER,
    x_effective_date                    IN     DATE,
    x_revised_price                     IN     NUMBER,
    x_revised_effective_date            IN     DATE,
    x_run_id                            IN     NUMBER,
    x_org_id                            IN     NUMBER,
    x_previous_price                    IN     NUMBER,
    x_previous_effective_date           IN     DATE
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_standing_charge_id                IN     NUMBER,
    x_line_item_id                      IN     NUMBER,
    x_charge_item_number                IN     NUMBER,
    x_item_id                           IN     NUMBER,
    x_price                             IN     NUMBER,
    x_effective_date                    IN     DATE,
    x_revised_price                     IN     NUMBER,
    x_revised_effective_date            IN     DATE,
    x_run_id                            IN     NUMBER,
    x_org_id                            IN     NUMBER,
    x_previous_price                    IN     NUMBER,
    x_previous_effective_date           IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_standing_charge_id                IN     NUMBER,
    x_line_item_id                      IN     NUMBER,
    x_charge_item_number                IN     NUMBER,
    x_item_id                           IN     NUMBER,
    x_price                             IN     NUMBER,
    x_effective_date                    IN     DATE,
    x_revised_price                     IN     NUMBER,
    x_revised_effective_date            IN     DATE,
    x_run_id                            IN     NUMBER,
    x_org_id                            IN     NUMBER,
    x_previous_price                    IN     NUMBER,
    x_previous_effective_date           IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  PROCEDURE get_fk_igi_rpi_line_det_all (
    x_line_item_id                      IN     NUMBER
  );

  PROCEDURE get_fk_igi_rpi_items_all (
    x_item_id                           IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_standing_charge_id                IN     NUMBER      DEFAULT NULL,
    x_line_item_id                      IN     NUMBER      DEFAULT NULL,
    x_charge_item_number                IN     NUMBER      DEFAULT NULL,
    x_item_id                           IN     NUMBER      DEFAULT NULL,
    x_price                             IN     NUMBER      DEFAULT NULL,
    x_effective_date                    IN     DATE        DEFAULT NULL,
    x_revised_price                     IN     NUMBER      DEFAULT NULL,
    x_revised_effective_date            IN     DATE        DEFAULT NULL,
    x_run_id                            IN     NUMBER      DEFAULT NULL,
    x_org_id                            IN     NUMBER      DEFAULT NULL,
    x_previous_price                    IN     NUMBER      DEFAULT NULL,
    x_previous_effective_date           IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igi_rpi_line_audit_det_all_pkg;

/
