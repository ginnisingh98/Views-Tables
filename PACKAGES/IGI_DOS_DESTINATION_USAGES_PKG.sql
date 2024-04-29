--------------------------------------------------------
--  DDL for Package IGI_DOS_DESTINATION_USAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_DOS_DESTINATION_USAGES_PKG" AUTHID CURRENT_USER AS
/* $Header: igidosns.pls 120.4.12000000.2 2007/06/14 04:25:27 pshivara ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_destination_id                    IN     NUMBER,
    x_segment_name                      IN     VARCHAR2,
    x_segment_name_dsp                  IN     VARCHAR2,
    x_sob_id                            IN     NUMBER,
    x_coa_id                            IN     NUMBER,
    x_visibility                        IN     VARCHAR2,
    x_default_type                      IN     VARCHAR2,
    x_default_value                     IN     VARCHAR2,
    x_updatable                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_destination_id                    IN     NUMBER,
    x_segment_name                      IN     VARCHAR2,
    x_segment_name_dsp                  IN     VARCHAR2,
    x_sob_id                            IN     NUMBER,
    x_coa_id                            IN     NUMBER,
    x_visibility                        IN     VARCHAR2,
    x_default_type                      IN     VARCHAR2,
    x_default_value                     IN     VARCHAR2,
    x_updatable                         IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_destination_id                    IN     NUMBER,
    x_segment_name                      IN     VARCHAR2,
    x_segment_name_dsp                  IN     VARCHAR2,
    x_sob_id                            IN     NUMBER,
    x_coa_id                            IN     NUMBER,
    x_visibility                        IN     VARCHAR2,
    x_default_type                      IN     VARCHAR2,
    x_default_value                     IN     VARCHAR2,
    x_updatable                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_destination_id                    IN     NUMBER,
    x_segment_name                      IN     VARCHAR2,
    x_segment_name_dsp                  IN     VARCHAR2,
    x_sob_id                            IN     NUMBER,
    x_coa_id                            IN     NUMBER,
    x_visibility                        IN     VARCHAR2,
    x_default_type                      IN     VARCHAR2,
    x_default_value                     IN     VARCHAR2,
    x_updatable                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  PROCEDURE get_fk_igi_dos_destinations (
    x_destination_id                    IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_destination_id                    IN     NUMBER      DEFAULT NULL,
    x_segment_name                      IN     VARCHAR2    DEFAULT NULL,
    x_segment_name_dsp                  IN     VARCHAR2    DEFAULT NULL,
    x_sob_id                            IN     NUMBER      DEFAULT NULL,
    x_coa_id                            IN     NUMBER      DEFAULT NULL,
    x_visibility                        IN     VARCHAR2    DEFAULT NULL,
    x_default_type                      IN     VARCHAR2    DEFAULT NULL,
    x_default_value                     IN     VARCHAR2    DEFAULT NULL,
    x_updatable                         IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igi_dos_destination_usages_pkg;

 

/
