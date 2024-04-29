--------------------------------------------------------
--  DDL for Package IGS_DA_REQ_FTRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_DA_REQ_FTRS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSKI42S.pls 115.1 2003/04/16 05:39:56 smanglm noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_batch_id                          IN     NUMBER,
    x_feature_code                      IN     VARCHAR2,
    x_feature_value                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_batch_id                          IN     NUMBER,
    x_feature_code                      IN     VARCHAR2,
    x_feature_value                     IN     VARCHAR2,
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_batch_id                          IN     NUMBER,
    x_feature_code                      IN     VARCHAR2,
    x_feature_value                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_batch_id                          IN     NUMBER,
    x_feature_code                      IN     VARCHAR2,
    x_feature_value                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2 ,
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  );

  FUNCTION get_pk_for_validation (
    x_batch_id                          IN     NUMBER,
    x_feature_code                      IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_da_ftr_val_map (
    x_feature_code                      IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_da_rqst (
    x_batch_id                          IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_batch_id                          IN     NUMBER      DEFAULT NULL,
    x_feature_code                      IN     VARCHAR2    DEFAULT NULL,
    x_feature_value                     IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_da_req_ftrs_pkg;

 

/
