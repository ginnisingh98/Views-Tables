--------------------------------------------------------
--  DDL for Package IGF_AP_OUTCORR_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_OUTCORR_WF_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFAI52S.pls 115.6 2002/11/28 14:03:38 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_number                     IN     VARCHAR2,
    x_given_names                       IN     VARCHAR2,
    x_transaction_number                IN     VARCHAR2,
    x_item_key                          IN     VARCHAR2,
    x_ow_id		                IN OUT NOCOPY NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_person_number                     IN     VARCHAR2,
    x_given_names                       IN     VARCHAR2,
    x_transaction_number                IN     VARCHAR2,
    x_ow_id                             IN     NUMBER,
    x_item_key                          IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_person_number                     IN     VARCHAR2,
    x_given_names                       IN     VARCHAR2,
    x_transaction_number                IN     VARCHAR2,
    x_item_key                          IN     VARCHAR2,
    x_ow_id                             IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_number                     IN     VARCHAR2,
    x_given_names                       IN     VARCHAR2,
    x_transaction_number                IN     VARCHAR2,
    x_item_key                          IN     VARCHAR2,
    x_ow_id                             IN OUT NOCOPY NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_person_number                     IN     VARCHAR2    DEFAULT NULL,
    x_given_names                       IN     VARCHAR2    DEFAULT NULL,
    x_transaction_number                IN     VARCHAR2    DEFAULT NULL,
    x_item_key                          IN     VARCHAR2    DEFAULT NULL,
    x_ow_id                             IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_ap_outcorr_wf_pkg;

 

/
