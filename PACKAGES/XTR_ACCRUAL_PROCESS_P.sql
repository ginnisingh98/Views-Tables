--------------------------------------------------------
--  DDL for Package XTR_ACCRUAL_PROCESS_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_ACCRUAL_PROCESS_P" AUTHID CURRENT_USER as
/* $Header: xtraccls.pls 120.4 2006/03/25 12:57:27 eaggarwa ship $ */
----------------------------------------------------------------------------------------------------------------
G_batch_id		XTR_BATCHES.batch_id%TYPE;


PROCEDURE CALCULATE_EFFECTIVE_INTEREST(
                                       p_face_value  IN NUMBER,
                                       p_all_in_rate IN NUMBER,
				       p_deal_date IN DATE,
                                       p_start_date  IN DATE,
                                       p_maturity_date    IN DATE,
				       p_adjust	     IN VARCHAR2,
                                       p_year_calc_type IN VARCHAR2,
                                       p_calc_basis  IN VARCHAR2,
			               p_pre_disc_end IN NUMBER,
			               p_no_of_days   OUT NOCOPY  NUMBER,
			               p_year_basis   OUT NOCOPY  NUMBER,
			               p_disc_amount  OUT NOCOPY  NUMBER,
                                       p_eff_interest OUT NOCOPY  NUMBER,
                                       p_day_count_type    IN VARCHAR2 DEFAULT NULL,
                                       p_resale_both_flag  IN VARCHAR2 DEFAULT 'N',
                                      p_status_code IN VARCHAR2 DEFAULT NULL);    -- bug 4969194


PROCEDURE CALCULATE_BOND_AMORTISATION (
                                       p_company IN VARCHAR2,
				       p_batch_id IN NUMBER,
                                       p_start_date IN DATE,
                                       p_end_date IN DATE,
                                       p_deal_type IN VARCHAR2);

PROCEDURE CALCULATE_ACCRUAL_AMORTISATION(
                    			 errbuf          OUT NOCOPY  VARCHAR2,
                                         retcode         OUT NOCOPY  NUMBER,
                                         p_company       IN VARCHAR2,
					 p_batch_id      IN NUMBER,
                                         start_date      IN VARCHAR2,
                                         end_date        IN VARCHAR2,
                                         p_upgrade_batch IN VARCHAR2);

PROCEDURE CALC_INTGROUP_CACCT_ACCLS (
                                       p_company IN VARCHAR2,
				       p_batch_id IN NUMBER,
                                       p_start_date IN DATE,
                                       p_end_date IN DATE,
                                       p_deal_type IN VARCHAR2);

PROCEDURE CALCULATE_NI_EFFINT (
                                       p_company         IN VARCHAR2,
				       p_new_batch_id    IN NUMBER,
				       p_cur_batch_id    IN NUMBER,
                                       p_batch_start     IN DATE,
                                       p_batch_end       IN DATE);


PROCEDURE TSFR_ACCRUALS_FOR_JNL_PROCESS(
                                       p_company  IN VARCHAR2,
                                       p_end_date IN DATE);
----------------------------------------------------------------------------------------------------------------
end XTR_ACCRUAL_PROCESS_P;

 

/
