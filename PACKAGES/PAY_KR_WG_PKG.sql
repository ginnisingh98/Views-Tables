--------------------------------------------------------
--  DDL for Package PAY_KR_WG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_WG_PKG" AUTHID CURRENT_USER AS
/* $Header: pykrffwg.pkh 120.3.12000000.1 2007/01/17 22:04:48 appldev noship $ */

  TYPE t_court_orders IS RECORD
  (
     element_entry_id                       pay_element_entries_f.element_entry_id%type,
     attachment_sequence_no                 VARCHAR2(100),
     court_order_start_date                 DATE,
     reception_time                         VARCHAR2(10),
     case_number                            VARCHAR2(100),
     processing_type                        VARCHAR2(2),
     principal_base                         NUMBER DEFAULT 0,
     court_fee_base                         NUMBER DEFAULT 0,
     interest_base                          NUMBER DEFAULT 0,
     interest_from_date1                    DATE,
     interest_to_date1                      DATE,
     interest_rate1                         NUMBER DEFAULT 0,
     interest_calculation_base1             NUMBER DEFAULT 0,
     interest_from_date2                    DATE,
     interest_to_date2                      DATE,
     interest_rate2                         NUMBER DEFAULT 0,
     interest_calculation_base2             NUMBER DEFAULT 0,
     interest_from_date3                    DATE,
     interest_to_date3                      DATE,
     interest_rate3                         NUMBER DEFAULT 0,
     interest_calculation_base3             NUMBER DEFAULT 0,
     interest_from_date4                    DATE,
     interest_to_date4                      DATE,
     interest_rate4                         NUMBER DEFAULT 0,
     interest_calculation_base4             NUMBER DEFAULT 0,
     interest_from_date5                    DATE,
     interest_to_date5                      DATE,
     interest_rate5                         NUMBER DEFAULT 0,
     interest_calculation_base5             NUMBER DEFAULT 0,
     previous_case_number                   VARCHAR2(100),
     payout_date                            DATE,
     court_order_origin                     VARCHAR2(30),
     previous_payout_date                   DATE,
     obligation_release			    VARCHAR2(1),
     -- Bug : 4866417
     obligation_release_processed           VARCHAR2(1),
     stop_flag				    VARCHAR2(1),
     attachment_total_base                  NUMBER DEFAULT 0,
     interest_amount                        NUMBER DEFAULT 0,
     real_attach_total_by_creditor          NUMBER DEFAULT 0,
     emp_attach_total_by_creditor           NUMBER DEFAULT 0,
     wg_adjusted_amount                     NUMBER DEFAULT 0,
     wg_adjustment_amount                   NUMBER DEFAULT 0,
     distribution_base                      NUMBER DEFAULT 0,
     distribution_rate                      NUMBER DEFAULT 0,
     curr_emp_paid_amt_by_creditor          NUMBER DEFAULT 0,
     out_message                            VARCHAR2(50) DEFAULT 'XYZ'
  );

  TYPE tab_court_orders IS TABLE OF t_court_orders INDEX BY BINARY_INTEGER;

  g_court_orders		tab_court_orders;

  TYPE t_emp_total IS RECORD
  (
     emp_attach_total        NUMBER DEFAULT 0,
     distribution_base       NUMBER DEFAULT 0,
     curr_emp_paid_amt       NUMBER DEFAULT 0,
     attachable_earnings     NUMBER DEFAULT 0,
     wg_adjustment           NUMBER DEFAULT 0,
     wg_adjusted             NUMBER DEFAULT 0
  );

  TYPE t_actual_attach IS RECORD
  (
      d_actual_attach_date     	      DATE,
      c_actual_attach_prev_case       VARCHAR2(100),
      c_actual_attach_case_found      VARCHAR2(1)  DEFAULT 'N'
  );

  TYPE tab_actual_attach IS TABLE OF t_actual_attach INDEX BY BINARY_INTEGER;

  g_last_assignment_processed    NUMBER;

  FUNCTION calc_wage_garnishment(	p_assignment_id 	IN		NUMBER,
					p_assignment_action_id	IN		NUMBER,
					p_date_earned 		IN		DATE,
					p_element_entry_id 	IN		NUMBER,
					p_net_earnings 		IN		NUMBER,
                                        p_run_type              IN      	VARCHAR2,
					p_attachment_amount	OUT	NOCOPY	NUMBER,
					p_adjusted_amount	OUT	NOCOPY	NUMBER,
					p_attach_total_base	OUT	NOCOPY	NUMBER,
					p_real_attach_total	OUT	NOCOPY	NUMBER,
					p_emp_attach_total	OUT	NOCOPY	NUMBER,
					p_interest_amount	OUT	NOCOPY	NUMBER,
					p_adjustment_amount	OUT	NOCOPY	NUMBER,
					p_unadjusted_amount	OUT	NOCOPY	NUMBER,
					p_stop_flag		OUT	NOCOPY	VARCHAR2,
					p_message		OUT	NOCOPY	VARCHAR2,
                                        p_curr_attach_seq_no    OUT	NOCOPY  VARCHAR2,
                                        p_curr_case_number      OUT	NOCOPY  VARCHAR2,
                                        p_payout_date           OUT	NOCOPY  DATE,
					p_date_paid		IN              DATE,
					p_wg_attach_earnings_mtd IN             NUMBER,
					p_wg_deductions_mtd      IN             NUMBER
                     ) RETURN NUMBER;

  FUNCTION calc_wage_garnishment(	p_assignment_id 	IN		NUMBER,
					p_assignment_action_id	IN		NUMBER,
					p_date_earned 		IN		DATE,
					p_attachment_seq_no 	IN		VARCHAR2,
					p_net_earnings 		IN		NUMBER,
                                        p_run_type              IN      	VARCHAR2,
					p_attachment_amount	OUT	NOCOPY	NUMBER,
					p_adjusted_amount	OUT	NOCOPY	NUMBER,
					p_attach_total_base	OUT	NOCOPY	NUMBER,
					p_real_attach_total	OUT	NOCOPY	NUMBER,
					p_emp_attach_total	OUT	NOCOPY	NUMBER,
					p_interest_amount	OUT	NOCOPY	NUMBER,
					p_adjustment_amount	OUT	NOCOPY	NUMBER,
					p_unadjusted_amount	OUT	NOCOPY	NUMBER,
					p_stop_flag		OUT	NOCOPY	VARCHAR2,
					p_message		OUT	NOCOPY	VARCHAR2,
                                        p_curr_attach_seq_no    OUT     NOCOPY	VARCHAR2,
                                        p_curr_case_number      OUT     NOCOPY	VARCHAR2,
                                        p_payout_date           OUT	NOCOPY  DATE,
					p_date_paid		IN              DATE,
                                        p_wg_attach_earnings_mtd IN		NUMBER,
					p_wg_deductions_mtd      IN		NUMBER

                     ) RETURN NUMBER;

  -- Bug 2856663 : parameter p_assignment_id added.

  FUNCTION attachment_seq_no_is_valid (p_assignment_id          IN      NUMBER,
				       p_element_entry_id	IN	NUMBER,
                                       p_attachment_seq_no      IN      VARCHAR2
                     ) RETURN VARCHAR2;

end pay_kr_wg_pkg;

 

/
