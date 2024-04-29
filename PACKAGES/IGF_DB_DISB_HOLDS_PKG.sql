--------------------------------------------------------
--  DDL for Package IGF_DB_DISB_HOLDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_DB_DISB_HOLDS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFDI09S.pls 115.5 2002/11/28 14:15:13 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_hold_id                           IN OUT NOCOPY NUMBER,
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_hold                              IN     VARCHAR2,
    x_hold_date                         IN     VARCHAR2,
    x_hold_type                         IN     VARCHAR2,
    x_release_date                      IN     DATE,
    x_release_flag                      IN     VARCHAR2,
    x_release_reason                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_hold_id                           IN     NUMBER,
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_hold                              IN     VARCHAR2,
    x_hold_date                         IN     VARCHAR2,
    x_hold_type                         IN     VARCHAR2,
    x_release_date                      IN     DATE,
    x_release_flag                      IN     VARCHAR2,
    x_release_reason                    IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_hold_id                           IN     NUMBER,
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_hold                              IN     VARCHAR2,
    x_hold_date                         IN     VARCHAR2,
    x_hold_type                         IN     VARCHAR2,
    x_release_date                      IN     DATE,
    x_release_flag                      IN     VARCHAR2,
    x_release_reason                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_hold_id                           IN OUT NOCOPY NUMBER,
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_hold                              IN     VARCHAR2,
    x_hold_date                         IN     VARCHAR2,
    x_hold_type                         IN     VARCHAR2,
    x_release_date                      IN     DATE,
    x_release_flag                      IN     VARCHAR2,
    x_release_reason                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_hold_id                           IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_aw_awd_disb (
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_hold_id                           IN     NUMBER      DEFAULT NULL,
    x_award_id                          IN     NUMBER      DEFAULT NULL,
    x_disb_num                          IN     NUMBER      DEFAULT NULL,
    x_hold                              IN     VARCHAR2    DEFAULT NULL,
    x_hold_date                         IN     VARCHAR2    DEFAULT NULL,
    x_hold_type                         IN     VARCHAR2    DEFAULT NULL,
    x_release_date                      IN     DATE        DEFAULT NULL,
    x_release_flag                      IN     VARCHAR2    DEFAULT NULL,
    x_release_reason                    IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );





END igf_db_disb_holds_pkg;

 

/
