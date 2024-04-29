--------------------------------------------------------
--  DDL for Package IGS_UC_APP_STATS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_APP_STATS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSXI07S.pls 115.7 2003/06/11 10:29:26 smaddali noship $ */
  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_app_stat_id                       IN OUT NOCOPY NUMBER,
    x_app_id                            IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_starh_ethnic                      IN     NUMBER,
    x_starh_social_class                IN     VARCHAR2,
    x_starh_pocc_edu_chg_dt             IN     DATE,
    x_starh_pocc                        IN     VARCHAR2,
    x_starh_pocc_text                   IN     VARCHAR2,
    x_starh_last_edu_inst               IN     NUMBER,
    x_starh_edu_leave_date              IN     NUMBER,
    x_starh_lea                         IN     NUMBER,
    x_starx_ethnic                      IN     NUMBER,
    x_starx_pocc_edu_chg                IN     DATE,
    x_starx_pocc                        IN     VARCHAR2,
    x_starx_pocc_text                   IN     VARCHAR2,
    x_sent_to_hesa                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    -- Added following 3 Columns as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_starh_socio_economic              IN     NUMBER      DEFAULT NULL,
    x_starx_socio_economic              IN     NUMBER      DEFAULT NULL,
    x_starx_occ_background              IN     VARCHAR2    DEFAULT NULL,
      -- Added following  Columns as part of UCFD102Build. Bug NO: 2643048 by bayadav
    x_ivstarh_dependants	            	IN		 NUMBER		   DEFAULT NULL,
    x_ivstarh_married		                IN		 VARCHAR2	   DEFAULT NULL,
    x_ivstarx_religion		              IN		 NUMBER		   DEFAULT NULL,
    x_ivstarx_dependants		            IN		 NUMBER		   DEFAULT NULL,
    x_ivstarx_married		                IN		 VARCHAR2	   DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_app_stat_id                       IN     NUMBER,
    x_app_id                            IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_starh_ethnic                      IN     NUMBER,
    x_starh_social_class                IN     VARCHAR2,
    x_starh_pocc_edu_chg_dt             IN     DATE,
    x_starh_pocc                        IN     VARCHAR2,
    x_starh_pocc_text                   IN     VARCHAR2,
    x_starh_last_edu_inst               IN     NUMBER,
    x_starh_edu_leave_date              IN     NUMBER,
    x_starh_lea                         IN     NUMBER,
    x_starx_ethnic                      IN     NUMBER,
    x_starx_pocc_edu_chg                IN     DATE,
    x_starx_pocc                        IN     VARCHAR2,
    x_starx_pocc_text                   IN     VARCHAR2,
    x_sent_to_hesa                      IN     VARCHAR2,
    -- Added following 3 Columns as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_starh_socio_economic              IN     NUMBER      DEFAULT NULL,
    x_starx_socio_economic              IN     NUMBER      DEFAULT NULL,
    x_starx_occ_background              IN     VARCHAR2    DEFAULT NULL,
      -- Added following  Columns as part of UCFD102Build. Bug NO: 2643048 by bayadav
    x_ivstarh_dependants	            	IN		 NUMBER		   DEFAULT NULL,
    x_ivstarh_married		                IN		 VARCHAR2	   DEFAULT NULL,
    x_ivstarx_religion		              IN		 NUMBER		   DEFAULT NULL,
    x_ivstarx_dependants		            IN		 NUMBER		   DEFAULT NULL,
    x_ivstarx_married		                IN		 VARCHAR2	   DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_app_stat_id                       IN     NUMBER,
    x_app_id                            IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_starh_ethnic                      IN     NUMBER,
    x_starh_social_class                IN     VARCHAR2,
    x_starh_pocc_edu_chg_dt             IN     DATE,
    x_starh_pocc                        IN     VARCHAR2,
    x_starh_pocc_text                   IN     VARCHAR2,
    x_starh_last_edu_inst               IN     NUMBER,
    x_starh_edu_leave_date              IN     NUMBER,
    x_starh_lea                         IN     NUMBER,
    x_starx_ethnic                      IN     NUMBER,
    x_starx_pocc_edu_chg                IN     DATE,
    x_starx_pocc                        IN     VARCHAR2,
    x_starx_pocc_text                   IN     VARCHAR2,
    x_sent_to_hesa                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    -- Added following 3 Columns as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_starh_socio_economic              IN     NUMBER      DEFAULT NULL,
    x_starx_socio_economic              IN     NUMBER      DEFAULT NULL,
    x_starx_occ_background              IN     VARCHAR2    DEFAULT NULL,
      -- Added following  Columns as part of UCFD102Build. Bug NO: 2643048 by bayadav
    x_ivstarh_dependants	            	IN		 NUMBER		   DEFAULT NULL,
    x_ivstarh_married		                IN		 VARCHAR2	   DEFAULT NULL,
    x_ivstarx_religion		              IN		 NUMBER		   DEFAULT NULL,
    x_ivstarx_dependants		            IN		 NUMBER		   DEFAULT NULL,
    x_ivstarx_married		                IN		 VARCHAR2	   DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_app_stat_id                       IN OUT NOCOPY NUMBER,
    x_app_id                            IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_starh_ethnic                      IN     NUMBER,
    x_starh_social_class                IN     VARCHAR2,
    x_starh_pocc_edu_chg_dt             IN     DATE,
    x_starh_pocc                        IN     VARCHAR2,
    x_starh_pocc_text                   IN     VARCHAR2,
    x_starh_last_edu_inst               IN     NUMBER,
    x_starh_edu_leave_date              IN     NUMBER,
    x_starh_lea                         IN     NUMBER,
    x_starx_ethnic                      IN     NUMBER,
    x_starx_pocc_edu_chg                IN     DATE,
    x_starx_pocc                        IN     VARCHAR2,
    x_starx_pocc_text                   IN     VARCHAR2,
    x_sent_to_hesa                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    -- Added following 3 Columns as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_starh_socio_economic              IN     NUMBER      DEFAULT NULL,
    x_starx_socio_economic              IN     NUMBER      DEFAULT NULL,
    x_starx_occ_background              IN     VARCHAR2    DEFAULT NULL,
      -- Added following  Columns as part of UCFD102Build. Bug NO: 2643048 by bayadav
    x_ivstarh_dependants	            	IN		 NUMBER		   DEFAULT NULL,
    x_ivstarh_married		                IN		 VARCHAR2	   DEFAULT NULL,
    x_ivstarx_religion		              IN		 NUMBER		   DEFAULT NULL,
    x_ivstarx_dependants		            IN		 NUMBER		   DEFAULT NULL,
    x_ivstarx_married		                IN		 VARCHAR2	   DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_app_stat_id                       IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_app_no                            IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_uc_applicants (
    x_app_id                            IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_app_stat_id                       IN     NUMBER      DEFAULT NULL,
    x_app_id                            IN     NUMBER      DEFAULT NULL,
    x_app_no                            IN     NUMBER      DEFAULT NULL,
    x_starh_ethnic                      IN     NUMBER      DEFAULT NULL,
    x_starh_social_class                IN     VARCHAR2    DEFAULT NULL,
    x_starh_pocc_edu_chg_dt             IN     DATE        DEFAULT NULL,
    x_starh_pocc                        IN     VARCHAR2    DEFAULT NULL,
    x_starh_pocc_text                   IN     VARCHAR2    DEFAULT NULL,
    x_starh_last_edu_inst               IN     NUMBER      DEFAULT NULL,
    x_starh_edu_leave_date              IN     NUMBER      DEFAULT NULL,
    x_starh_lea                         IN     NUMBER      DEFAULT NULL,
    x_starx_ethnic                      IN     NUMBER      DEFAULT NULL,
    x_starx_pocc_edu_chg                IN     DATE        DEFAULT NULL,
    x_starx_pocc                        IN     VARCHAR2    DEFAULT NULL,
    x_starx_pocc_text                   IN     VARCHAR2    DEFAULT NULL,
    x_sent_to_hesa                      IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    -- Added following 3 Columns as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_starh_socio_economic              IN     NUMBER      DEFAULT NULL,
    x_starx_socio_economic              IN     NUMBER      DEFAULT NULL,
    x_starx_occ_background              IN     VARCHAR2    DEFAULT NULL,
      -- Added following  Columns as part of UCFD102Build. Bug NO: 2643048 by bayadav
    x_ivstarh_dependants	            	IN		 NUMBER		   DEFAULT NULL,
    x_ivstarh_married		                IN		 VARCHAR2	   DEFAULT NULL,
    x_ivstarx_religion		              IN		 NUMBER		   DEFAULT NULL,
    x_ivstarx_dependants		            IN		 NUMBER		   DEFAULT NULL,
    x_ivstarx_married		                IN		 VARCHAR2	   DEFAULT NULL
  );

END igs_uc_app_stats_pkg;

 

/
