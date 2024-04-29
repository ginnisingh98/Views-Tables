--------------------------------------------------------
--  DDL for Package IGS_PE_FUND_SOURCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_FUND_SOURCE_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNI93S.pls 120.0 2005/06/01 14:41:58 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_fund_source_id                    IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_fund_source_code                  IN     VARCHAR2,
    x_name                              IN     VARCHAR2,
    x_amount                            IN     NUMBER,
    x_relationship_code                 IN     VARCHAR2,
    x_document_ind                      IN     VARCHAR2,
    x_notes                             IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_fund_source_id                    IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_fund_source_code                  IN     VARCHAR2,
    x_name                              IN     VARCHAR2,
    x_amount                            IN     NUMBER,
    x_relationship_code                 IN     VARCHAR2,
    x_document_ind                      IN     VARCHAR2,
    x_notes                             IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_fund_source_id                    IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_fund_source_code                  IN     VARCHAR2,
    x_name                              IN     VARCHAR2,
    x_amount                            IN     NUMBER,
    x_relationship_code                 IN     VARCHAR2,
    x_document_ind                      IN     VARCHAR2,
    x_notes                             IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_fund_source_id                    IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_fund_source_code                  IN     VARCHAR2,
    x_name                              IN     VARCHAR2,
    x_amount                            IN     NUMBER,
    x_relationship_code                 IN     VARCHAR2,
    x_document_ind                      IN     VARCHAR2,
    x_notes                             IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
  );

  FUNCTION get_pk_for_validation (
    x_fund_source_id                    IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_hz_parties (
    x_party_id                          IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_fund_source_id                    IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_fund_source_code                  IN     VARCHAR2    DEFAULT NULL,
    x_name                              IN     VARCHAR2    DEFAULT NULL,
    x_amount                            IN     NUMBER      DEFAULT NULL,
    x_relationship_code                 IN     VARCHAR2    DEFAULT NULL,
    x_document_ind                      IN     VARCHAR2    DEFAULT NULL,
    x_notes                             IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_pe_fund_source_pkg;

 

/
