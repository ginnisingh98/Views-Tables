--------------------------------------------------------
--  DDL for Package PN_VAR_RENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_VAR_RENT_PKG" AUTHID CURRENT_USER as
/* $Header: PNVRFUNS.pls 120.12.12010000.2 2008/09/04 12:27:34 mumohan ship $ */

  status VARCHAR2(30) := 'REVERSED';

  TYPE grp_date_info_rec IS RECORD (
          grp_date_id                   PN_VAR_GRP_DATES.grp_date_id%TYPE,
          grp_start_date                PN_VAR_GRP_DATES.grp_start_date%TYPE,
          grp_end_date                  PN_VAR_GRP_DATES.grp_end_date%TYPE,
          group_date                    PN_VAR_GRP_DATES.group_date%TYPE,
          reptg_due_date                PN_VAR_GRP_DATES.reptg_due_date%TYPE,
          inv_start_date                PN_VAR_GRP_DATES.inv_start_date%TYPE,
          inv_end_date                  PN_VAR_GRP_DATES.inv_end_date%TYPE,
          invoice_date                  PN_VAR_GRP_DATES.invoice_date%TYPE,
          inv_schedule_date             PN_VAR_GRP_DATES.inv_schedule_date%TYPE,
          forecasted_exp_code           PN_VAR_GRP_DATES.forecasted_exp_code%TYPE
          );

  TYPE proration_factor_rec IS RECORD (
          per_start_proration           PN_VAR_PERIODS.proration_factor%TYPE,
          first_per_gl_days             PN_VAR_PERIODS.proration_factor%TYPE,
          per_end_proration             PN_VAR_PERIODS.proration_factor%TYPE,
          last_per_gl_days              PN_VAR_PERIODS.proration_factor%TYPE,
          grp_start_proration           PN_VAR_GRP_DATES.proration_factor%TYPE,
          first_grp_gl_days             PN_VAR_GRP_DATES.proration_factor%TYPE,
          grp_end_proration             PN_VAR_GRP_DATES.proration_factor%TYPE,
          last_grp_gl_days              PN_VAR_GRP_DATES.proration_factor%TYPE
          );

PROCEDURE INSERT_PERIODS_ROW (
  X_ROWID               IN OUT NOCOPY VARCHAR2,
  X_PERIOD_ID           IN OUT NOCOPY NUMBER,
  X_PERIOD_NUM          IN OUT NOCOPY NUMBER,
  X_VAR_RENT_ID         IN NUMBER,
  X_START_DATE          IN DATE,
  X_END_DATE            IN DATE,
  X_PRORATION_FACTOR    IN NUMBER,
  X_PARTIAL_PERIOD      IN VARCHAR2,
  X_ATTRIBUTE_CATEGORY  IN VARCHAR2,
  X_ATTRIBUTE1          IN VARCHAR2,
  X_ATTRIBUTE2          IN VARCHAR2,
  X_ATTRIBUTE3          IN VARCHAR2,
  X_ATTRIBUTE4          IN VARCHAR2,
  X_ATTRIBUTE5          IN VARCHAR2,
  X_ATTRIBUTE6          IN VARCHAR2,
  X_ATTRIBUTE7          IN VARCHAR2,
  X_ATTRIBUTE8          IN VARCHAR2,
  X_ATTRIBUTE9          IN VARCHAR2,
  X_ATTRIBUTE10         IN VARCHAR2,
  X_ATTRIBUTE11         IN VARCHAR2,
  X_ATTRIBUTE12         IN VARCHAR2,
  X_ATTRIBUTE13         IN VARCHAR2,
  X_ATTRIBUTE14         IN VARCHAR2,
  X_ATTRIBUTE15         IN VARCHAR2,
  X_CREATION_DATE       IN DATE,
  X_CREATED_BY          IN NUMBER,
  X_LAST_UPDATE_DATE    IN DATE,
  X_LAST_UPDATED_BY     IN NUMBER,
  X_LAST_UPDATE_LOGIN   IN NUMBER,
  X_ORG_ID                 NUMBER DEFAULT NULL
  );

PROCEDURE DELETE_PERIODS_ROW (
  X_VAR_RENT_ID         IN NUMBER,
  X_TERM_DATE           IN DATE DEFAULT NULL
  );

PROCEDURE CREATE_REPORT_DATES (p_var_rent_id IN NUMBER);

PROCEDURE INSERT_REPORT_DATE_ROW
(
   X_ROWID               IN OUT NOCOPY VARCHAR2,
   X_REPORT_DATE_ID      IN OUT NOCOPY NUMBER,
   X_GRP_DATE_ID         IN NUMBER,
   X_VAR_RENT_ID         IN NUMBER,
   X_REPORT_START_DATE   IN DATE,
   X_REPORT_END_DATE     IN DATE,
   X_CREATION_DATE       IN DATE,
   X_CREATED_BY          IN NUMBER,
   X_LAST_UPDATE_DATE    IN DATE,
   X_LAST_UPDATED_BY     IN NUMBER,
   X_LAST_UPDATE_LOGIN   IN NUMBER,
   X_ATTRIBUTE_CATEGORY  IN VARCHAR2,
   X_ATTRIBUTE1          IN VARCHAR2,
   X_ATTRIBUTE2          IN VARCHAR2,
   X_ATTRIBUTE3          IN VARCHAR2,
   X_ATTRIBUTE4          IN VARCHAR2,
   X_ATTRIBUTE5          IN VARCHAR2,
   X_ATTRIBUTE6          IN VARCHAR2,
   X_ATTRIBUTE7          IN VARCHAR2,
   X_ATTRIBUTE8          IN VARCHAR2,
   X_ATTRIBUTE9          IN VARCHAR2,
   X_ATTRIBUTE10         IN VARCHAR2,
   X_ATTRIBUTE11         IN VARCHAR2,
   X_ATTRIBUTE12         IN VARCHAR2,
   X_ATTRIBUTE13         IN VARCHAR2,
   X_ATTRIBUTE14         IN VARCHAR2,
   X_ATTRIBUTE15         IN VARCHAR2,
   X_ORG_ID              IN NUMBER
);

PROCEDURE DELETE_REPORT_DATE_ROW (
                              X_VAR_RENT_ID IN NUMBER,
                              X_END_DATE    IN DATE
                                 );


PROCEDURE INSERT_GRP_DATE_ROW (
  X_ROWID               IN OUT NOCOPY VARCHAR2,
  X_GRP_DATE_ID         IN OUT NOCOPY NUMBER,
  X_VAR_RENT_ID         IN NUMBER,
  X_PERIOD_ID           IN NUMBER,
  X_GRP_START_DATE      IN DATE,
  X_GRP_END_DATE        IN DATE,
  X_GROUP_DATE          IN DATE,
  X_REPTG_DUE_DATE      IN DATE,
  X_INV_START_DATE      IN DATE,
  X_INV_END_DATE        IN DATE,
  X_INVOICE_DATE        IN DATE,
  X_INV_SCHEDULE_DATE   IN DATE,
  X_PRORATION_FACTOR    IN NUMBER,
  X_ACTUAL_EXP_CODE     IN VARCHAR2,
  X_FORECASTED_EXP_CODE IN VARCHAR2,
  X_VARIANCE_EXP_CODE   IN VARCHAR2,
  X_CREATION_DATE       IN DATE,
  X_CREATED_BY          IN NUMBER,
  X_LAST_UPDATE_DATE    IN DATE,
  X_LAST_UPDATED_BY     IN NUMBER,
  X_LAST_UPDATE_LOGIN   IN NUMBER,
  X_ORG_ID                 NUMBER DEFAULT NULL
  );

PROCEDURE DELETE_GRP_DATE_ROW(x_var_rent_id  IN NUMBER,
                              x_term_date    IN DATE DEFAULT NULL);

PROCEDURE CREATE_VAR_RENT_PERIODS(p_var_rent_id    IN NUMBER,
                                  p_cumulative_vol IN VARCHAR2 DEFAULT NULL,
                                  p_comm_date      IN DATE DEFAULT NULL,
                                  p_term_date      IN DATE DEFAULT NULL,
                                  p_create_flag    IN VARCHAR2 DEFAULT 'Y');

PROCEDURE CREATE_VAR_RENT_PERIODS_NOCAL(p_var_rent_id    IN NUMBER,
                                        p_cumulative_vol IN VARCHAR2,
                                        p_yr_start_date  IN DATE);

PROCEDURE DELETE_VAR_RENT_PERIODS(p_var_rent_id   IN NUMBER,
                                  p_term_date     IN DATE DEFAULT NULL);

PROCEDURE UPDATE_VAR_RENT_PERIODS(p_var_rent_id    IN NUMBER,
                                  p_term_date      IN DATE DEFAULT NULL);

PROCEDURE DELETE_VAR_RENT_CONSTR(p_var_rent_id   IN NUMBER,
                                 p_term_date     IN DATE DEFAULT NULL);

PROCEDURE DELETE_VAR_RENT_LINES(p_var_rent_id   IN NUMBER,
                                p_term_date     IN DATE DEFAULT NULL);

PROCEDURE DELETE_VAR_VOL_HIST(p_line_item_id   IN NUMBER);

PROCEDURE DELETE_VAR_RENT_DEDUCT(p_line_item_id  IN NUMBER);

PROCEDURE DELETE_VAR_BKPTS_HEAD(p_line_item_id   IN NUMBER);

PROCEDURE DELETE_VAR_BKPTS_DET(p_bkpt_header_id  IN NUMBER);

FUNCTION find_if_period_exists (p_var_rent_id   NUMBER)
      RETURN NUMBER;

FUNCTION find_if_invoice_exists (p_var_rent_id   NUMBER)
      RETURN NUMBER;

PROCEDURE DELETE_VAR_RENT_INVOICES(p_var_rent_id   IN NUMBER,
                                   p_term_date     IN DATE DEFAULT NULL);

FUNCTION find_if_calculation_exists (p_var_rent_id   NUMBER)
      RETURN NUMBER;

FUNCTION find_if_vrdates_exists (p_var_rent_id   NUMBER)
      RETURN NUMBER;

FUNCTION find_if_constr_exist (p_var_rent_id   NUMBER,
                               p_term_date     DATE DEFAULT NULL)
      RETURN NUMBER;

FUNCTION find_if_lines_exist (p_var_rent_id   NUMBER,
                              p_period_id     NUMBER DEFAULT NULL,
                              p_term_date     DATE DEFAULT NULL)
      RETURN NUMBER;

FUNCTION find_if_volhist_exist ( p_line_item_id   IN  NUMBER )
      RETURN NUMBER;

FUNCTION find_if_volhist_approved_exist ( p_line_item_id IN NUMBER
                                         ,p_grp_date_id  IN NUMBER )
      RETURN VARCHAR2;

FUNCTION find_if_volhist_bkpts_exist ( p_id       IN  NUMBER,
                                       p_id_type  IN    VARCHAR2 )
      RETURN NUMBER;

FUNCTION find_if_deduct_exist (p_line_item_id   NUMBER)
      RETURN NUMBER;

PROCEDURE LOCK_ROW_EXCEPTION (p_column_name IN VARCHAR2,
                              p_new_value   IN VARCHAR2);

FUNCTION  First_Day ( p_Date  Date )
      RETURN DATE;

FUNCTION find_reporting_periods (p_period_id   NUMBER)
      RETURN NUMBER;

FUNCTION calculate_base_rent (p_var_rent_id    NUMBER,
                              p_period_id      NUMBER,
                              p_base_rent_type VARCHAR2)
      RETURN NUMBER;

FUNCTION  Get_Grp_date_Info ( p_var_rent_id IN NUMBER,
                              p_period_id   IN NUMBER,
                              p_start_date  IN DATE,
                              p_end_date    IN DATE )
      RETURN grp_date_info_rec;

FUNCTION  Get_Proration_Factor ( p_var_rent_id IN NUMBER)
      RETURN proration_factor_rec;

FUNCTION find_if_bkptshd_exist (p_line_item_id   NUMBER)
      RETURN NUMBER;

FUNCTION find_if_bkptsdet_exist (p_bkpt_header_id   NUMBER)
      RETURN NUMBER;

FUNCTION find_if_exported (p_id         IN NUMBER,
                           p_block      IN VARCHAR2,
                           p_start_dt   IN DATE DEFAULT NULL,
                           p_end_dt     IN DATE DEFAULT NULL)
      RETURN NUMBER;
FUNCTION find_if_for_vol_exported (p_id         IN NUMBER)
      RETURN NUMBER;
FUNCTION find_status (p_period_id    IN NUMBER)
      RETURN VARCHAR2;

FUNCTION find_if_adjust_hist_exists (p_period_id    IN NUMBER)
      RETURN NUMBER;

FUNCTION approved_term_exist(p_var_rent_id NUMBER,p_period_id NUMBER DEFAULT NULL)
      RETURN VARCHAR2 ;

PROCEDURE delete_inv_summ (p_var_rent_id IN NUMBER );

FUNCTION find_vol_ready_for_adjust(p_period_id number,p_invoice_on VARCHAR2)
      RETURN NUMBER ;

PROCEDURE UPDATE_LOCATION_FOR_VR_TERMS(p_var_rent_id   IN  NUMBER,
                                       p_location_id   IN  NUMBER,
                                       p_return_status OUT NOCOPY VARCHAR2);

/*codev changes starts*/

FUNCTION  dates_validation (p_var_rent_id IN NUMBER
                           ,p_period_id IN NUMBER
                           ,p_line_item_id IN NUMBER
                           ,p_check_for IN VARCHAR2
                           ,p_called_from IN VARCHAR2)
      RETURN VARCHAR2;

FUNCTION  constr_dates_validation (p_var_rent_id IN NUMBER
                                  ,p_called_from IN VARCHAR2)
      RETURN VARCHAR2;

FUNCTION find_reporting_periods (p_freq_code   VARCHAR2)
      RETURN NUMBER;

PROCEDURE extend_periods ( p_var_rent_id        IN NUMBER,
                           p_extension_end_date IN DATE,
                           p_start_date         IN DATE,
                           p_end_date           IN DATE,
                           x_return_status      OUT NOCOPY VARCHAR2,
                           x_return_message     OUT NOCOPY VARCHAR2);

PROCEDURE extend_group_dates ( p_pn_var_rent_dates_rec IN PN_VAR_RENT_DATES_ALL%ROWTYPE,
                               p_period_id             IN NUMBER,
                               x_return_status         OUT NOCOPY VARCHAR2,
                               x_return_message        OUT NOCOPY VARCHAR2);

PROCEDURE create_new_bkpts(p_var_rent_id         IN NUMBER,
                            p_extension_end_date IN DATE,
                            p_old_end_date       IN DATE,
                            x_return_status      OUT NOCOPY VARCHAR2,
                            x_return_message     OUT NOCOPY VARCHAR2);

/*PROCEDURE process_vr_ext(p_lease_id             IN  NUMBER,
                         p_extension_end_date   IN  DATE,
                         p_old_end_date         IN  DATE,
                         p_var_rent_id          IN  NUMBER DEFAULT NULL,
                         x_return_status        OUT VARCHAR2,
                         x_return_message       OUT VARCHAR2);


PROCEDURE process_vr_early_term ( p_lease_id            IN NUMBER DEFAULT NULL,
                                  p_var_rent_id         IN NUMBER DEFAULT NULL,
                                  p_new_lease_term_date IN DATE,
                                  p_old_end_date        IN DATE,
                                  x_return_status       OUT VARCHAR2,
                                  x_return_message      OUT VARCHAR2);
*/

PROCEDURE process_vr_ext (p_lease_id       IN NUMBER
                         ,p_var_rent_id    IN NUMBER
                         ,p_new_termn_date IN DATE
                         ,p_old_termn_date IN DATE
                         ,p_extend_setup   IN VARCHAR2
                         ,x_return_status  OUT NOCOPY VARCHAR2
                         ,x_return_message OUT NOCOPY VARCHAR2);


PROCEDURE process_vr_early_term ( p_lease_id       IN NUMBER
                                 ,p_var_rent_id    IN NUMBER
                                 ,p_new_termn_date IN DATE
                                 ,p_old_termn_date IN DATE
                                 ,x_return_status  OUT NOCOPY VARCHAR2
                                 ,x_return_message  OUT NOCOPY VARCHAR2);

FUNCTION get_proration_rule( p_var_rent_id IN NUMBER DEFAULT NULL,
                             p_period_id   IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

TYPE new_periods IS RECORD (
    var_rent_id NUMBER,
    period_id   NUMBER,
    start_date  DATE,
    end_date    DATE,
    flag        VARCHAR2(1),
    proration_days NUMBER
);
-- use 'N' for New period created and
-- 'U' for updating dates of existing period

TYPE new_periods_tbl IS TABLE OF new_periods INDEX BY BINARY_INTEGER;

TYPE cal_periods IS RECORD (
    period_year NUMBER,
    start_date  DATE,
    end_date    DATE
);

TYPE cal_periods_tbl IS TABLE OF cal_periods INDEX BY BINARY_INTEGER;

TYPE group_dates_rec IS RECORD (
    start_date  DATE,
    end_date    DATE,
    rec_found   VARCHAR2(1)
);

TYPE group_dates_tbl IS TABLE OF group_dates_rec INDEX BY BINARY_INTEGER;

PROCEDURE generate_group_inv_tbl ( p_pn_var_rent_dates_rec IN pn_var_rent_dates_all%rowtype,
                                   p_period_start_date  IN DATE,
                                   p_period_end_date    IN DATE,
                                   x_group_dates_tbl    OUT NOCOPY group_dates_tbl,
                                   x_inv_dates_tbl      OUT NOCOPY group_dates_tbl);

PROCEDURE generate_cal_periods_tbl ( p_var_rent_dates_rec IN pn_var_rent_dates_all%rowtype,
                                 p_start_date         IN DATE,
                                 p_end_date           IN DATE,
                                 p_extension_end_date IN DATE,
                                 x_cal_periods_tbl    OUT NOCOPY cal_periods_tbl);

/*
PROCEDURE remove_later_periods ( p_var_rent_id IN NUMBER,
                                 p_lease_id    IN NUMBER,
                                 p_new_lease_term_date IN DATE,
                                 p_old_end_date       IN DATE,
                                 x_return_status      OUT NOCOPY VARCHAR2,
                                 x_return_message     OUT NOCOPY VARCHAR2) ;
*/

PROCEDURE remove_later_periods (  p_var_rent_id    IN NUMBER
                                , p_new_termn_date IN DATE
                                , p_old_termn_date IN DATE
                                , x_return_status  OUT NOCOPY VARCHAR2
                                , x_return_message OUT NOCOPY VARCHAR2);

/*
PROCEDURE early_terminate_period ( p_var_rent_id IN NUMBER,
                                   p_old_term_date IN DATE,
                                   p_new_lease_term_date IN DATE,
                                   x_period_id      OUT NOCOPY NUMBER,
                                   x_return_status  OUT NOCOPY VARCHAR2,
                                   x_return_message OUT NOCOPY VARCHAR2);
*/

PROCEDURE early_terminate_period  ( p_var_rent_id    IN NUMBER
                                   ,p_period_id      IN NUMBER
                                   ,p_new_termn_date IN DATE
                                   ,p_old_termn_date IN DATE
                                   ,x_return_status  OUT NOCOPY VARCHAR2
                                   ,x_return_message OUT NOCOPY VARCHAR2);

FUNCTION exists_bkpt_dtldateintersect ( p_var_rent_id IN NUMBER,
                                        p_line_default_id IN NUMBER,
                                        p_start_date   IN DATE,
                                        p_end_date     IN DATE)
      RETURN BOOLEAN;

PROCEDURE check_continious_def_dates ( p_var_rent_id IN NUMBER,
                                  p_line_default_id IN NUMBER,
                                  p_start_date IN DATE,
                                  p_end_date   IN DATE,
                                  x_return_status OUT NOCOPY BOOLEAN,
                                  x_return_message OUT NOCOPY VARCHAR2,
                                  x_date1 OUT NOCOPY DATE,
                                  x_date2 OUT NOCOPY DATE);

PROCEDURE check_continious_def_dates ( p_var_rent_id IN NUMBER,
                                  p_line_item_id IN NUMBER,
                                  p_start_date IN DATE,
                                  p_end_date   IN DATE,
                                  x_return_status OUT NOCOPY BOOLEAN,
                                  x_return_message OUT NOCOPY VARCHAR2,
                                  x_date1 OUT NOCOPY DATE,
                                  x_date2 OUT NOCOPY DATE);

FUNCTION is_template_used ( p_template_id IN NUMBER)
      RETURN BOOLEAN ;

FUNCTION FIND_IF_BKPTS_SETUP_EXISTS (p_var_rent_id   NUMBER)
      RETURN BOOLEAN;

PROCEDURE put_log(p_string VARCHAR2);

FUNCTION is_partial_period (p_period_id IN NUMBER)
      RETURN VARCHAR2;

FUNCTION DETERMINE_FREQUENCY (
   X_VAR_RENT_START_DATE IN PN_VAR_RENTS_ALL.COMMENCEMENT_DATE%TYPE
  ,X_VAR_RENT_END_DATE   IN PN_VAR_RENTS_ALL.TERMINATION_DATE%TYPE)
      RETURN PN_VAR_RENT_DATES_ALL.REPTG_FREQ_CODE%TYPE;

PROCEDURE update_bkpt_details(p_var_rent_id     IN NUMBER,
                              p_bkdt_dflt_id    IN NUMBER,
                              p_bkpt_rate       IN NUMBER);

PROCEDURE change_stratified_rows(p_bkhd_default_id      IN NUMBER,
                                 p_bkdt_st_date_old     IN DATE,
                                 p_bkdt_end_date_old    IN DATE,
                                 p_bkdt_default_id      IN NUMBER,
                                 p_bkdt_st_date         IN DATE,
                                 p_bkdt_end_date        IN DATE);

PROCEDURE process_vr_exp_con (errbuf              OUT NOCOPY VARCHAR2,
                              retcode             OUT NOCOPY VARCHAR2,
                              p_lease_id          NUMBER,
                              p_lease_change_id   NUMBER DEFAULT NULL,
                              p_old_term_date     VARCHAR2,
                              p_new_term_date     VARCHAR2,
                              p_vr_context        VARCHAR2,
                              p_setup_exp_context VARCHAR2 DEFAULT NULL,
                              p_rollover          VARCHAR2 DEFAULT NULL,
			      p_request_id        NUMBER DEFAULT NULL);


PROCEDURE copy_bkpt_main_to_setup (errbuf              OUT NOCOPY VARCHAR2,
                                   retcode             OUT NOCOPY VARCHAR2,
                                   p_prop_id           IN NUMBER,
                                   p_loc_id            IN NUMBER,
                                   p_lease_id          IN NUMBER,
                                   p_var_rent_id       IN NUMBER);

FUNCTION find_if_inv_exp (p_var_rent_id NUMBER, p_invoice_date DATE) RETURN NUMBER;

FUNCTION rates_validation (p_var_rent_id IN NUMBER
                          ,p_agr_start_date IN DATE
                          ,p_agr_end_date IN DATE) RETURN VARCHAR2;
FUNCTION FIND_IF_ABAT_DEF_EXIST (p_var_rent_id NUMBER)
RETURN NUMBER ;
FUNCTION FIND_IF_CONSTR_DEF_EXIST (p_var_rent_id NUMBER)
RETURN NUMBER ;

END PN_VAR_RENT_PKG;

/
