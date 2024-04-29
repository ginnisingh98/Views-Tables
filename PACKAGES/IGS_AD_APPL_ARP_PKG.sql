--------------------------------------------------------
--  DDL for Package IGS_AD_APPL_ARP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_APPL_ARP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAIF7S.pls 120.0 2005/06/01 21:33:05 appldev noship $ */


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_appl_arp_id                       IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_appl_rev_profile_id               IN     NUMBER,
    x_appl_revprof_revgr_id             IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_appl_arp_id                       IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_appl_rev_profile_id               IN     NUMBER,
    x_appl_revprof_revgr_id             IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_appl_arp_id                       IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_appl_rev_profile_id               IN     NUMBER,
    x_appl_revprof_revgr_id             IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_appl_arp_id                       IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_appl_rev_profile_id               IN     NUMBER,
    x_appl_revprof_revgr_id             IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
  );

  FUNCTION get_pk_for_validation (
    x_appl_arp_id                       IN     NUMBER
  ) RETURN BOOLEAN;


  PROCEDURE get_fk_igs_ad_apl_rprf_rgr (
    x_appl_revprof_revgr_id             IN     NUMBER
  );

  PROCEDURE get_fk_igs_ad_apl_rev_prf (
    x_appl_rev_profile_id               IN     NUMBER
  );

    PROCEDURE get_fk_igs_ad_ps_appl_inst (
    x_person_id                         IN NUMBER,
    x_admission_appl_number             IN NUMBER,
    x_nominated_course_cd               IN VARCHAR2,
    x_sequence_number                   IN NUMBER
  );


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_appl_arp_id                       IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_admission_appl_number             IN     NUMBER      DEFAULT NULL,
    x_nominated_course_cd               IN     VARCHAR2    DEFAULT NULL,
    x_sequence_number                   IN     NUMBER      DEFAULT NULL,
    x_appl_rev_profile_id               IN     NUMBER      DEFAULT NULL,
    x_appl_revprof_revgr_id             IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ad_appl_arp_pkg;

 

/
