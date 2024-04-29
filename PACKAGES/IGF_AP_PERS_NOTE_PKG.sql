--------------------------------------------------------
--  DDL for Package IGF_AP_PERS_NOTE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_PERS_NOTE_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFAI43S.pls 115.5 2002/11/28 14:01:57 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_reference_number                  IN OUT NOCOPY NUMBER,
    x_base_id                           IN     NUMBER,
    x_pe_note_type                      IN     VARCHAR2,
    x_short_desc                        IN     VARCHAR2,
    x_rec_resp                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_reference_number                  IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_pe_note_type                      IN     VARCHAR2,
    x_short_desc                        IN     VARCHAR2,
    x_rec_resp                          IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_reference_number                  IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_pe_note_type                      IN     VARCHAR2,
    x_short_desc                        IN     VARCHAR2,
    x_rec_resp                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_reference_number                  IN OUT NOCOPY NUMBER,
    x_base_id                           IN     NUMBER,
    x_pe_note_type                      IN     VARCHAR2,
    x_short_desc                        IN     VARCHAR2,
    x_rec_resp                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_reference_number                  IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_pe_note_type (
    x_pe_note_type                      IN     VARCHAR2
  );

  PROCEDURE get_fk_igf_ap_fa_base_rec (
    x_base_id                           IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_reference_number                  IN     NUMBER      DEFAULT NULL,
    x_base_id                           IN     NUMBER      DEFAULT NULL,
    x_pe_note_type                      IN     VARCHAR2    DEFAULT NULL,
    x_short_desc                        IN     VARCHAR2    DEFAULT NULL,
    x_rec_resp                          IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_ap_pers_note_pkg;

 

/
