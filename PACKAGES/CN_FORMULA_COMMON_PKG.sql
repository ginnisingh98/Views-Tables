--------------------------------------------------------
--  DDL for Package CN_FORMULA_COMMON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_FORMULA_COMMON_PKG" AUTHID CURRENT_USER AS
-- $Header: cnfmcoms.pls 120.2.12010000.2 2009/09/22 19:01:26 rnagired ship $

--
-- Package Body Name
--   cn_formula_common_pkg
-- Purpose
--   This package contains the procedures of calculation engine, some
--   of which will be called from each formula packages.
-- History
--   3/2/1999	Richard Jin   Created

  TYPE mul_input_rec_type is RECORD
    (input_amount NUMBER,
     input_string VARCHAR2(30),
     base_amount NUMBER,
     amount      NUMBER,
     rate_dim_sequence NUMBER ,
     tier_sequence  NUMBER(15) );

  TYPE mul_input_tbl_type IS TABLE OF mul_input_rec_type INDEX BY BINARY_INTEGER;

  TYPE num_table_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  TYPE trx_rec_type is RECORD
    (commission_line_id  NUMBER(15),
     commission_header_id NUMBER(15),
     -- reversal_id  NUMBER(15),
     -- reversal_flag       VARCHAR2(1),
     salesrep_id         NUMBER(15),
     srp_plan_assign_id  NUMBER(15),
     quota_id            NUMBER(15),
     credit_type_id      NUMBER(15),
     processed_date      DATE,
     processed_period_id NUMBER(15),
     pay_period_id       NUMBER(15),
     commission_amount   NUMBER,
     commission_rate     NUMBER,
     rate_tier_id        NUMBER,
     tier_split          NUMBER,
     input_achieved      NUMBER,
     output_achieved     NUMBER,
     perf_achieved       NUMBER,
     posting_status      VARCHAR2(30) := fnd_api.g_miss_char,
     pending_status      VARCHAR2(30) := fnd_api.g_miss_char,
     created_during      VARCHAR2(30) := fnd_api.g_miss_char,
     trx_type            VARCHAR2(30) := fnd_api.g_miss_char,
     error_reason        VARCHAR2(150) := fnd_api.g_miss_char,
     status              VARCHAR2(150) := fnd_api.g_miss_char);

  -- Procedure Name
  --   calc_init
  -- Scope
  --   public
  -- Purpose
  --     To initialize before going to calculation
  -- History
  --   02-March 1999	Richard Jin	Created
  --
  PROCEDURE calculate_init( p_srp_plan_assign_id            NUMBER,
			    p_salesrep_id		    NUMBER,
			    p_period_id			    NUMBER,
			    p_quota_id			    NUMBER,
			    p_start_date                    DATE ,
			    p_process_all_flag              VARCHAR2,
			    p_intel_calc_flag               VARCHAR2,
			    p_calc_type                     VARCHAR2,
			    p_trx_group_code                VARCHAR2,
			    p_itd_flag                      VARCHAR2,
			    p_rollover_flag                 VARCHAR2,
			    x_commission_payed_ptd  OUT NOCOPY NUMBER ,
			    x_commission_payed_itd  OUT NOCOPY NUMBER ,
			    x_input_achieved_ptd  OUT NOCOPY num_table_type,
			    x_input_achieved_itd  OUT NOCOPY num_table_type,
			    x_output_achieved_ptd  OUT NOCOPY NUMBER ,
			    x_output_achieved_itd  OUT NOCOPY 	NUMBER ,
			    x_perf_achieved_ptd  OUT NOCOPY NUMBER ,
			    x_perf_achieved_itd  OUT NOCOPY 	NUMBER ,
			    x_select_status_flag OUT NOCOPY VARCHAR2   );

  -- Procedure Name
  --   calculate_roll
  -- Scope
  --   public
  -- Purpose
  --       To update cn_srp_period_quotas, cn_srp_per_quota_rc, cn_srp_periods
  --   	   after the calculation of a quota is done
  -- History
  --   02-March 1999	Richard Jin	Created
  --
  PROCEDURE calculate_roll (	p_salesrep_id		number,
				p_period_id		number,
				p_quota_id		number,
				p_srp_plan_assign_id    NUMBER,
				p_calc_type             VARCHAR2,
				p_input_achieved_ptd	num_table_type,
				p_input_achieved_itd	num_table_type,
				p_output_achieved_ptd	number,
				p_output_achieved_itd	number,
				p_perf_achieved_ptd	number,
				p_perf_achieved_itd	NUMBER,
				p_rollover              NUMBER) ;

  -- Procedure Name
  --   get_rates
  -- Scope
  --   public
  -- Purpose
  --  	This is used to figure the commission rate and handle split or
  --	accumulative option if any.
  -- History
  --   02-March 1999	Richard Jin	Created
  --
  PROCEDURE get_rates(	p_salesrep_id		NUMBER ,
			p_srp_plan_assign_id    NUMBER ,
			p_period_id		NUMBER ,
			p_quota_id		NUMBER ,
			p_split_flag		VARCHAR2 ,
			p_itd_flag              VARCHAR2,
			p_processed_date	DATE ,
			p_number_dim            NUMBER ,
			p_mul_input_tbl IN OUT NOCOPY  mul_input_tbl_type,
			p_calc_formula_id       NUMBER,
			x_rate	 OUT NOCOPY 	NUMBER,
			x_rate_tier_id  OUT NOCOPY     NUMBER,
			x_tier_split    OUT NOCOPY     NUMBER     );

  --
  -- Name
  --   calculate_batch
  -- Purpose
  --   for all payee in marked srp_periods calculate the actual
  --	commission amounts
  -- History
  --
  --   02/03/93 Tony Lower		Created
  --   05/22/95 P Cook	Debug. Review the performance of the sql without
  --			the hints. May be better than with hints.
  --   07/10/98 Richard Jin  	Intelligent and incremental Calculation

  PROCEDURE calculate_batch( p_physical_batch_id NUMBER);


  -- Procedure Name
  --   revert_batch
  -- Scope
  --   cn_commission_lines_pkg
  -- Purpose
  --
  -- History
  --   10-JUL-98	Richard Jin		Created
  --
  PROCEDURE revert_batch (p_batch_id cn_process_batches.physical_batch_id%TYPE);


  -- Procedure Name
  --   revert_header_lines
  -- Scope
  --
  -- Purpose
  --   delete/update derived commission_lines
  -- History
  --   10-JUL-98	Richard Jin		Created
  PROCEDURE revert_header_lines( p_commission_header_id NUMBER, p_revert_state VARCHAR2);

  -- revert commission lines if posted already
  PROCEDURE revert_posting_line (p_commission_line_id NUMBER) ;

  -- Procedure Name
  --   get_start_period
  -- Scope
  --   public
  -- Purpose
  --  	This procedure is to get the start period of current interval
  -- History
  --   02-March 1999	Richard Jin	Created
  --
  FUNCTION get_start_period_id ( p_quota_id  NUMBER,
				 p_period_id NUMBER ) RETURN NUMBER;

    -- Procedure Name
  --   get_end_period
  -- Scope
  --   public
  -- Purpose
  --  	This procedure is to get the end period of current interval
  -- History
  --   02-March 1999	Richard Jin	Created
  --
  FUNCTION get_end_period_id ( p_quota_id  NUMBER,
				 p_period_id NUMBER ) RETURN NUMBER;

  FUNCTION get_quarter_start_period_id(p_quota_id NUMBER, p_period_id NUMBER) RETURN NUMBER;
  FUNCTION get_quarter_end_period_id(p_quota_id NUMBER, p_period_id NUMBER) RETURN NUMBER;

  --
  -- Name
  --   EndOfInterval
  -- Purpose
  --   Returns 1 if the specified period is the end of an interval of the
  --  type listed int he X_Interval string.
  -- History
  --  06/13/95	Created 	Tony Lower
  --
  FUNCTION EndOfInterval ( p_quota_id  NUMBER, p_period_id NUMBER )
    RETURN BOOLEAN ;


  --
  -- Name
  --   create_update_grp_trx
  -- Purpose
  --   create a new group by trx if not existed
  --   update the existing group by trx if already existed
  --   if already posted, create a reversal first
  -- History
  --  06/13/95	Created 	Tony Lower
  --
  PROCEDURE create_trx( p_trx_rec IN OUT NOCOPY trx_rec_type);

  --
  -- Name
  --   create_update_grp_trx
  -- Purpose
  --   create a new group by trx if not existed
  --   update the existing group by trx if already existed
  --   if already posted, create a reversal first
  -- History
  --  06/13/95	Created 	Tony Lower
  --
  PROCEDURE update_trx( p_trx_rec_old IN OUT NOCOPY trx_rec_type,
			p_trx_rec_new IN OUT NOCOPY trx_rec_type);


  -- Procedure Name
  --   handle_reversal_trx
  -- Scope
  --   public
  -- Purpose
  --  p_commission_header_id will be the commisson_header_id of the reversal trx created
  -- History
  --   10-JUL-98	Richard Jin		Created
  PROCEDURE handle_reversal_trx ( p_commission_header_id NUMBER);

  --
  -- Name
  --   populate_factors
  -- Purpose
  --   populate the event_factor, payment_factor, quota_factor and payees
  --
  -- History
  --   07/12/1999     Created      Richard Jin
  --
  PROCEDURE populate_factors (p_physical_batch_id NUMBER);

  -- Procedure Name
  --   check_itd_calc_trx
  -- Scope
  --   public
  -- Purpose
  --
  -- History
  --   02-March 1999	Richard Jin	Created
  FUNCTION check_itd_calc_trx ( p_salesrep_id         NUMBER,
				p_srp_plan_assign_id  NUMBER,
				p_period_id           NUMBER,
				p_quota_id            NUMBER  ) RETURN BOOLEAN;

  -- Procedure Name
  --   get_pq_itd_target
  -- Scope
  --   public
  -- Purpose
  --
  -- History
  --   02-March 1999	Richard Jin	Created
  FUNCTION get_pq_itd_target ( p_period_id NUMBER,
			       p_quota_id  NUMBER  ) RETURN NUMBER;

  -- Procedure Name
  --   get_spq_itd_target
  -- Scope
  --   public
  -- Purpose
  --
  -- History
  --   02-March 1999	Richard Jin	Created
  FUNCTION get_spq_itd_target (p_salesrep_id        NUMBER,
			       p_srp_plan_assign_id NUMBER,
			       p_period_id          NUMBER,
			       p_quota_id           NUMBER  ) RETURN NUMBER;

  -- Procedure Name
  --   get_pq_itd_payment
  -- Scope
  --   public
  -- Purpose
  --
  -- History
  --   02-March 1999	Richard Jin	Created
  FUNCTION get_pq_itd_payment ( p_period_id NUMBER,
				p_quota_id  NUMBER  ) RETURN NUMBER;

  -- Procedure Name
  --   get_spq_itd_payment
  -- Scope
  --   public
  -- Purpose
  --
  -- History
  --   02-March 1999	Richard Jin	Created
  FUNCTION get_spq_itd_payment (p_salesrep_id        NUMBER,
				p_srp_plan_assign_id NUMBER,
				p_period_id          NUMBER,
				p_quota_id           NUMBER  ) RETURN NUMBER;
-- fix for the Bug 6768210 raj reddy
  FUNCTION EndOfGroupByInterval( p_quota_id  NUMBER, p_period_id NUMBER,p_srp_plan_assign_id NUMBER )
  RETURN BOOLEAN ;


END cn_formula_common_pkg;

/
