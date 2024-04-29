--------------------------------------------------------
--  DDL for Package IGS_AD_PNMEMBR_NOTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_PNMEMBR_NOTS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAIH3S.pls 115.0 2003/06/20 12:42:52 akadam noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_panel_dtls_id                     IN     NUMBER,
    x_member_person_id                  IN     NUMBER,
    x_notes_version_num                 IN     NUMBER,
    x_member_notes                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_panel_dtls_id                     IN     NUMBER,
    x_member_person_id                  IN     NUMBER,
    x_notes_version_num                 IN     NUMBER,
    x_member_notes                      IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_panel_dtls_id                     IN     NUMBER,
    x_member_person_id                  IN     NUMBER,
    x_notes_version_num                 IN     NUMBER,
    x_member_notes                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_panel_dtls_id                     IN     NUMBER,
    x_member_person_id                  IN     NUMBER,
    x_notes_version_num                 IN     NUMBER,
    x_member_notes                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_panel_dtls_id                     IN     NUMBER,
    x_member_person_id                  IN     NUMBER,
    x_notes_version_num                 IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ad_pnmembr_dtls (
    x_panel_dtls_id                     IN     NUMBER,
    x_member_person_id                  IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_panel_dtls_id                     IN     NUMBER      DEFAULT NULL,
    x_member_person_id                  IN     NUMBER      DEFAULT NULL,
    x_notes_version_num                 IN     NUMBER      DEFAULT NULL,
    x_member_notes                      IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ad_pnmembr_nots_pkg;

 

/
