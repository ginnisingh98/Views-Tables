--------------------------------------------------------
--  DDL for Package IGF_SL_CL_PREF_LENDERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_CL_PREF_LENDERS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFLI34S.pls 115.1 2003/10/07 09:43:16 bkkumar noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_clprl_id                          IN OUT NOCOPY NUMBER,
    x_msg_count                            OUT NOCOPY NUMBER,
    x_msg_data                             OUT NOCOPY VARCHAR2,
    x_return_status                        OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_relationship_cd                   IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_object_version_number             IN     NUMBER DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_clprl_id                          IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_relationship_cd             IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_object_version_number             IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_clprl_id                          IN     NUMBER,
    x_msg_count                            OUT NOCOPY NUMBER,
    x_msg_data                             OUT NOCOPY VARCHAR2,
    x_return_status                        OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_relationship_cd                   IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_object_version_number             IN     NUMBER DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );



  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_clprl_id                          IN     NUMBER
  ) RETURN BOOLEAN;


 PROCEDURE get_fk_igf_sl_cl_recipient (
    x_relationship_cd           IN     VARCHAR2
  ) ;
  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_clprl_id                          IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_relationship_cd             IN     VARCHAR2    DEFAULT NULL,
    x_start_date                        IN     DATE        DEFAULT NULL,
    x_end_date                          IN     DATE        DEFAULT NULL,
    x_object_version_number             IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_sl_cl_pref_lenders_pkg;

 

/
