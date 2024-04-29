--------------------------------------------------------
--  DDL for Package IGS_UC_UCAS_CONTROL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_UCAS_CONTROL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSXI33S.pls 120.0 2005/06/01 17:54:17 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_entry_year                        IN     NUMBER,
    x_time_of_year                      IN     VARCHAR2,
    x_time_of_day                       IN     VARCHAR2,
    x_routeb_time_of_year               IN     VARCHAR2,
    x_appno_first                       IN     NUMBER,
    x_appno_maximum                     IN     NUMBER,
    x_appno_last_used                   IN     NUMBER,
    x_last_daily_run_no                 IN     NUMBER,
    x_last_daily_run_date               IN     DATE,
    x_appno_15dec                       IN     NUMBER,
    x_run_date_15dec                    IN     DATE,
    x_appno_24mar                       IN     NUMBER,
    x_run_date_24mar                    IN     DATE,
    x_appno_16may                       IN     NUMBER,
    x_run_date_16may                    IN     DATE,
    x_appno_decision_proc               IN     NUMBER,
    x_run_date_decision_proc            IN     DATE,
    x_appno_first_pre_num               IN     NUMBER,
    x_news                              IN     VARCHAR2,
    x_no_more_la_tran                   IN     VARCHAR2,
    x_star_x_avail                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    -- Added following 3 Columns as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_appno_first_opf	                IN     NUMBER,
    x_appno_first_rpa_noneu	        IN     NUMBER,
    x_appno_first_rpa_eu                IN     NUMBER,
    -- Added following 3 Columns as part of UCFD06 Build. Bug#2574566 by Nishikant
    x_extra_start_date                  IN     DATE  DEFAULT NULL,
    x_last_passport_date                IN     DATE  DEFAULT NULL,
    x_last_le_date                      IN     DATE  DEFAULT NULL,
    x_system_code                       IN     VARCHAR2 DEFAULT NULL,
    x_ucas_cycle                        IN     NUMBER,
    -- Added following 2 Columns as part of UCCR008 Build. Bug#3239860 by arvsrini
    x_gttr_clear_toy_code               IN     VARCHAR2 DEFAULT NULL,
    x_transaction_toy_code              IN     VARCHAR2 DEFAULT NULL
  );

 FUNCTION get_pk_for_validation (    x_system_code         IN    VARCHAR2,
                                     x_ucas_cycle  IN NUMBER) RETURN BOOLEAN;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_entry_year                        IN     NUMBER,
    x_time_of_year                      IN     VARCHAR2,
    x_time_of_day                       IN     VARCHAR2,
    x_routeb_time_of_year               IN     VARCHAR2,
    x_appno_first                       IN     NUMBER,
    x_appno_maximum                     IN     NUMBER,
    x_appno_last_used                   IN     NUMBER,
    x_last_daily_run_no                 IN     NUMBER,
    x_last_daily_run_date               IN     DATE,
    x_appno_15dec                       IN     NUMBER,
    x_run_date_15dec                    IN     DATE,
    x_appno_24mar                       IN     NUMBER,
    x_run_date_24mar                    IN     DATE,
    x_appno_16may                       IN     NUMBER,
    x_run_date_16may                    IN     DATE,
    x_appno_decision_proc               IN     NUMBER,
    x_run_date_decision_proc            IN     DATE,
    x_appno_first_pre_num               IN     NUMBER,
    x_news                              IN     VARCHAR2,
    x_no_more_la_tran                   IN     VARCHAR2,
    x_star_x_avail                      IN     VARCHAR2,
    -- Added following 3 Columns as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_appno_first_opf	                IN     NUMBER,
    x_appno_first_rpa_noneu	        IN     NUMBER,
    x_appno_first_rpa_eu                IN     NUMBER,
    -- Added following 3 Columns as part of UCFD06 Build. Bug#2574566 by Nishikant
    x_extra_start_date                  IN     DATE  DEFAULT NULL,
    x_last_passport_date                IN     DATE  DEFAULT NULL,
    x_last_le_date                      IN     DATE  DEFAULT NULL,
    x_system_code                       IN     VARCHAR2 ,
    x_ucas_cycle                        IN     NUMBER,
    -- Added following 2 Columns as part of UCCR008 Build. Bug#3239860 by arvsrini
    x_gttr_clear_toy_code               IN     VARCHAR2 DEFAULT NULL,
    x_transaction_toy_code              IN     VARCHAR2 DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_entry_year                        IN     NUMBER,
    x_time_of_year                      IN     VARCHAR2,
    x_time_of_day                       IN     VARCHAR2,
    x_routeb_time_of_year               IN     VARCHAR2,
    x_appno_first                       IN     NUMBER,
    x_appno_maximum                     IN     NUMBER,
    x_appno_last_used                   IN     NUMBER,
    x_last_daily_run_no                 IN     NUMBER,
    x_last_daily_run_date               IN     DATE,
    x_appno_15dec                       IN     NUMBER,
    x_run_date_15dec                    IN     DATE,
    x_appno_24mar                       IN     NUMBER,
    x_run_date_24mar                    IN     DATE,
    x_appno_16may                       IN     NUMBER,
    x_run_date_16may                    IN     DATE,
    x_appno_decision_proc               IN     NUMBER,
    x_run_date_decision_proc            IN     DATE,
    x_appno_first_pre_num               IN     NUMBER,
    x_news                              IN     VARCHAR2,
    x_no_more_la_tran                   IN     VARCHAR2,
    x_star_x_avail                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    -- Added following 3 Columns as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_appno_first_opf	                IN     NUMBER,
    x_appno_first_rpa_noneu	        IN     NUMBER,
    x_appno_first_rpa_eu                IN     NUMBER,
    -- Added following 3 Columns as part of UCFD06 Build. Bug#2574566 by Nishikant
    x_extra_start_date                  IN     DATE  DEFAULT NULL,
    x_last_passport_date                IN     DATE  DEFAULT NULL,
    x_last_le_date                      IN     DATE  DEFAULT NULL,
    x_system_code                       IN     VARCHAR2 DEFAULT NULL,
    x_ucas_cycle                        IN     NUMBER,
    -- Added following 2 Columns as part of UCCR008 Build. Bug#3239860 by arvsrini
    x_gttr_clear_toy_code               IN     VARCHAR2 DEFAULT NULL,
    x_transaction_toy_code              IN     VARCHAR2 DEFAULT NULL
    );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_entry_year                        IN     NUMBER,
    x_time_of_year                      IN     VARCHAR2,
    x_time_of_day                       IN     VARCHAR2,
    x_routeb_time_of_year               IN     VARCHAR2,
    x_appno_first                       IN     NUMBER,
    x_appno_maximum                     IN     NUMBER,
    x_appno_last_used                   IN     NUMBER,
    x_last_daily_run_no                 IN     NUMBER,
    x_last_daily_run_date               IN     DATE,
    x_appno_15dec                       IN     NUMBER,
    x_run_date_15dec                    IN     DATE,
    x_appno_24mar                       IN     NUMBER,
    x_run_date_24mar                    IN     DATE,
    x_appno_16may                       IN     NUMBER,
    x_run_date_16may                    IN     DATE,
    x_appno_decision_proc               IN     NUMBER,
    x_run_date_decision_proc            IN     DATE,
    x_appno_first_pre_num               IN     NUMBER,
    x_news                              IN     VARCHAR2,
    x_no_more_la_tran                   IN     VARCHAR2,
    x_star_x_avail                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    -- Added following 3 Columns as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_appno_first_opf	                IN     NUMBER,
    x_appno_first_rpa_noneu	        IN     NUMBER,
    x_appno_first_rpa_eu                IN     NUMBER,
    -- Added following 3 Columns as part of UCFD06 Build. Bug#2574566 by Nishikant
    x_extra_start_date                  IN     DATE  DEFAULT NULL,
    x_last_passport_date                IN     DATE  DEFAULT NULL,
    x_last_le_date                      IN     DATE  DEFAULT NULL,
    x_system_code                       IN     VARCHAR2 DEFAULT NULL,
    x_ucas_cycle                        IN     NUMBER,
    -- Added following 2 Columns as part of UCCR008 Build. Bug#3239860 by arvsrini
    x_gttr_clear_toy_code               IN     VARCHAR2 DEFAULT NULL,
    x_transaction_toy_code              IN     VARCHAR2 DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_entry_year                        IN     NUMBER      DEFAULT NULL,
    x_time_of_year                      IN     VARCHAR2    DEFAULT NULL,
    x_time_of_day                       IN     VARCHAR2    DEFAULT NULL,
    x_routeb_time_of_year               IN     VARCHAR2    DEFAULT NULL,
    x_appno_first                       IN     NUMBER      DEFAULT NULL,
    x_appno_maximum                     IN     NUMBER      DEFAULT NULL,
    x_appno_last_used                   IN     NUMBER      DEFAULT NULL,
    x_last_daily_run_no                 IN     NUMBER      DEFAULT NULL,
    x_last_daily_run_date               IN     DATE        DEFAULT NULL,
    x_appno_15dec                       IN     NUMBER      DEFAULT NULL,
    x_run_date_15dec                    IN     DATE        DEFAULT NULL,
    x_appno_24mar                       IN     NUMBER      DEFAULT NULL,
    x_run_date_24mar                    IN     DATE        DEFAULT NULL,
    x_appno_16may                       IN     NUMBER      DEFAULT NULL,
    x_run_date_16may                    IN     DATE        DEFAULT NULL,
    x_appno_decision_proc               IN     NUMBER      DEFAULT NULL,
    x_run_date_decision_proc            IN     DATE        DEFAULT NULL,
    x_appno_first_pre_num               IN     NUMBER      DEFAULT NULL,
    x_news                              IN     VARCHAR2    DEFAULT NULL,
    x_no_more_la_tran                   IN     VARCHAR2    DEFAULT NULL,
    x_star_x_avail                      IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    -- Added following 3 Columns as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_appno_first_opf	                IN     NUMBER      DEFAULT NULL,
    x_appno_first_rpa_noneu	        IN     NUMBER      DEFAULT NULL,
    x_appno_first_rpa_eu                IN     NUMBER      DEFAULT NULL,
    -- Added following 3 Columns as part of UCFD06 Build. Bug#2574566 by Nishikant
    x_extra_start_date                  IN     DATE        DEFAULT NULL,
    x_last_passport_date                IN     DATE        DEFAULT NULL,
    x_last_le_date                      IN     DATE        DEFAULT NULL,
    x_system_code                       IN     VARCHAR2    DEFAULT NULL,
    x_ucas_cycle                        IN     NUMBER      DEFAULT NULL,
    -- Added following 2 Columns as part of UCCR008 Build. Bug#3239860 by arvsrini
    x_gttr_clear_toy_code               IN     VARCHAR2    DEFAULT NULL,
    x_transaction_toy_code              IN     VARCHAR2    DEFAULT NULL
  );

END igs_uc_ucas_control_pkg;

 

/
