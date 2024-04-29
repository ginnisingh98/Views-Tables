--------------------------------------------------------
--  DDL for Package IGF_AP_CLASS_STD_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_CLASS_STD_MAP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFAI45S.pls 115.4 2002/11/28 14:02:27 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ipcs_id                           IN OUT NOCOPY NUMBER,
    x_igs_pr_css_class_std_id           IN     NUMBER,
    x_ap_std_code                       IN     VARCHAR2,
    x_dl_std_code                       IN     VARCHAR2,
    x_cl_std_code                       IN     VARCHAR2,
    x_ppt_id                            IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_ipcs_id                           IN     NUMBER,
    x_igs_pr_css_class_std_id           IN     NUMBER,
    x_ap_std_code                       IN     VARCHAR2,
    x_dl_std_code                       IN     VARCHAR2,
    x_cl_std_code                       IN     VARCHAR2,
    x_ppt_id                            IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_ipcs_id                           IN     NUMBER,
    x_igs_pr_css_class_std_id           IN     NUMBER,
    x_ap_std_code                       IN     VARCHAR2,
    x_dl_std_code                       IN     VARCHAR2,
    x_cl_std_code                       IN     VARCHAR2,
    x_ppt_id                            IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ipcs_id                           IN OUT NOCOPY NUMBER,
    x_igs_pr_css_class_std_id           IN     NUMBER,
    x_ap_std_code                       IN     VARCHAR2,
    x_dl_std_code                       IN     VARCHAR2,
    x_cl_std_code                       IN     VARCHAR2,
    x_ppt_id                            IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_ipcs_id                           IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_pr_css_class_std (
    x_igs_pr_css_class_std_id           IN     NUMBER
  );

PROCEDURE get_fk_igf_ap_pr_prg_type (
    x_ppt_id           IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_ipcs_id                           IN     NUMBER      DEFAULT NULL,
    x_igs_pr_css_class_std_id           IN     NUMBER      DEFAULT NULL,
    x_ap_std_code                       IN     VARCHAR2    DEFAULT NULL,
    x_dl_std_code                       IN     VARCHAR2    DEFAULT NULL,
    x_cl_std_code                       IN     VARCHAR2    DEFAULT NULL,
    x_ppt_id                            IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_ap_class_std_map_pkg;

 

/
