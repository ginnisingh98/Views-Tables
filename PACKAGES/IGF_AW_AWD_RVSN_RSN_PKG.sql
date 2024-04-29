--------------------------------------------------------
--  DDL for Package IGF_AW_AWD_RVSN_RSN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_AWD_RVSN_RSN_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFWI32S.pls 115.4 2002/11/28 14:41:12 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_rvsn_id                           IN OUT NOCOPY NUMBER,
    x_rvsn_code                         IN     VARCHAR2,
    x_descp                             IN     VARCHAR2,
    x_active                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_rvsn_id                           IN     NUMBER,
    x_rvsn_code                         IN     VARCHAR2,
    x_descp                             IN     VARCHAR2,
    x_active                            IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_rvsn_id                           IN     NUMBER,
    x_rvsn_code                         IN     VARCHAR2,
    x_descp                             IN     VARCHAR2,
    x_active                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_rvsn_id                           IN OUT NOCOPY NUMBER,
    x_rvsn_code                         IN     VARCHAR2,
    x_descp                             IN     VARCHAR2,
    x_active                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_rvsn_id                           IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_rvsn_code                         IN     VARCHAR2,
    x_org_id                            IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_rvsn_id                           IN     NUMBER      DEFAULT NULL,
    x_rvsn_code                         IN     VARCHAR2    DEFAULT NULL,
    x_descp                             IN     VARCHAR2    DEFAULT NULL,
    x_active                            IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_aw_awd_rvsn_rsn_pkg;

 

/
