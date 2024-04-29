--------------------------------------------------------
--  DDL for Package IGF_SL_DL_BATCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_DL_BATCH_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFLI13S.pls 115.3 2002/11/28 14:24:32 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_dbth_id                           IN OUT NOCOPY NUMBER,
    x_batch_id                          IN     VARCHAR2,
    x_message_class                     IN     VARCHAR2,
    x_bth_creation_date                 IN     DATE,
    x_batch_rej_code                    IN     VARCHAR2,
    x_end_date                          IN     DATE,
    x_batch_type                        IN     VARCHAR2,
    x_send_resp                         IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_dbth_id                           IN     NUMBER,
    x_batch_id                          IN     VARCHAR2,
    x_message_class                     IN     VARCHAR2,
    x_bth_creation_date                 IN     DATE,
    x_batch_rej_code                    IN     VARCHAR2,
    x_end_date                          IN     DATE,
    x_batch_type                        IN     VARCHAR2,
    x_send_resp                         IN     VARCHAR2,
    x_status                            IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_dbth_id                           IN     NUMBER,
    x_batch_id                          IN     VARCHAR2,
    x_message_class                     IN     VARCHAR2,
    x_bth_creation_date                 IN     DATE,
    x_batch_rej_code                    IN     VARCHAR2,
    x_end_date                          IN     DATE,
    x_batch_type                        IN     VARCHAR2,
    x_send_resp                         IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_dbth_id                           IN OUT NOCOPY NUMBER,
    x_batch_id                          IN     VARCHAR2,
    x_message_class                     IN     VARCHAR2,
    x_bth_creation_date                 IN     DATE,
    x_batch_rej_code                    IN     VARCHAR2,
    x_end_date                          IN     DATE,
    x_batch_type                        IN     VARCHAR2,
    x_send_resp                         IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_dbth_id                           IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_dbth_id                           IN     NUMBER      DEFAULT NULL,
    x_batch_id                          IN     VARCHAR2    DEFAULT NULL,
    x_message_class                     IN     VARCHAR2    DEFAULT NULL,
    x_bth_creation_date                 IN     DATE        DEFAULT NULL,
    x_batch_rej_code                    IN     VARCHAR2    DEFAULT NULL,
    x_end_date                          IN     DATE        DEFAULT NULL,
    x_batch_type                        IN     VARCHAR2    DEFAULT NULL,
    x_send_resp                         IN     VARCHAR2    DEFAULT NULL,
    x_status                            IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_sl_dl_batch_pkg;

 

/
