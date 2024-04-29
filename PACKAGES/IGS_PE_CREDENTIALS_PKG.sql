--------------------------------------------------------
--  DDL for Package IGS_PE_CREDENTIALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_CREDENTIALS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNI96S.pls 120.0 2005/06/02 03:41:55 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_credential_id                     IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_credential_type_id                IN     NUMBER,
    x_date_received                     IN     DATE,
    x_reviewer_id                       IN     NUMBER,
    x_reviewer_notes                    IN     VARCHAR2,
    x_recommender_name                  IN     VARCHAR2,
    x_recommender_title                 IN     VARCHAR2,
    x_recommender_organization          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_rating_code                       IN     VARCHAR2
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_credential_id                     IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_credential_type_id                IN     NUMBER,
    x_date_received                     IN     DATE,
    x_reviewer_id                       IN     NUMBER,
    x_reviewer_notes                    IN     VARCHAR2,
    x_recommender_name                  IN     VARCHAR2,
    x_recommender_title                 IN     VARCHAR2,
    x_recommender_organization          IN     VARCHAR2,
    x_rating_code                       IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_credential_id                     IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_credential_type_id                IN     NUMBER,
    x_date_received                     IN     DATE,
    x_reviewer_id                       IN     NUMBER,
    x_reviewer_notes                    IN     VARCHAR2,
    x_recommender_name                  IN     VARCHAR2,
    x_recommender_title                 IN     VARCHAR2,
    x_recommender_organization          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_rating_code                       IN     VARCHAR2
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_credential_id                     IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_credential_type_id                IN     NUMBER,
    x_date_received                     IN     DATE,
    x_reviewer_id                       IN     NUMBER,
    x_reviewer_notes                    IN     VARCHAR2,
    x_recommender_name                  IN     VARCHAR2,
    x_recommender_title                 IN     VARCHAR2,
    x_recommender_organization          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_rating_code                       IN     VARCHAR2
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
  );

  FUNCTION get_pk_for_validation (
    x_credential_id                     IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ad_cred_types (
    x_credential_type_id                IN     NUMBER
  );

 /* PROCEDURE get_fk_igs_ad_code_classes (
    x_code_id                IN     NUMBER
  ); */

  PROCEDURE get_fk_hz_parties (
    x_party_id                          IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_credential_id                     IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_credential_type_id                IN     NUMBER      DEFAULT NULL,
    x_date_received                     IN     DATE        DEFAULT NULL,
    x_reviewer_id                       IN     NUMBER      DEFAULT NULL,
    x_reviewer_notes                    IN     VARCHAR2    DEFAULT NULL,
    x_recommender_name                  IN     VARCHAR2    DEFAULT NULL,
    x_recommender_title                 IN     VARCHAR2    DEFAULT NULL,
    x_recommender_organization          IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_rating_code                       IN     VARCHAR2    DEFAULT NULL
  );

END igs_pe_credentials_pkg;

 

/
