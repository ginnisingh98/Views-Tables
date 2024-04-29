--------------------------------------------------------
--  DDL for Package IGS_UC_MAP_OFF_RESP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_MAP_OFF_RESP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSXI46S.pls 115.3 2002/11/29 04:58:09 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_decision_code                     IN     VARCHAR2,
    x_reply_code                        IN     VARCHAR2,
    x_adm_offer_resp_status             IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_decision_code                     IN     VARCHAR2,
    x_reply_code                        IN     VARCHAR2,
    x_adm_offer_resp_status             IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_decision_code                     IN     VARCHAR2,
    x_reply_code                        IN     VARCHAR2,
    x_adm_offer_resp_status             IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_decision_code                     IN     VARCHAR2,
    x_reply_code                        IN     VARCHAR2,
    x_adm_offer_resp_status             IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_system_code                       IN     VARCHAR2,
    x_decision_code                     IN     VARCHAR2,
    x_reply_code                        IN     VARCHAR2
  ) RETURN BOOLEAN;


  PROCEDURE get_fk_igs_uc_sys_decision (
    x_system_code                       IN     VARCHAR2,
    x_decision_code                     IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_ad_ofr_resp_stat (
    x_adm_offer_resp_status             IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_system_code                       IN     VARCHAR2    DEFAULT NULL,
    x_decision_code                     IN     VARCHAR2    DEFAULT NULL,
    x_reply_code                        IN     VARCHAR2    DEFAULT NULL,
    x_adm_offer_resp_status             IN     VARCHAR2    DEFAULT NULL,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_uc_map_off_resp_pkg;

 

/
