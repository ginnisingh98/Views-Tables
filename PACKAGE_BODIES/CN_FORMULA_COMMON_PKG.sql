--------------------------------------------------------
--  DDL for Package Body CN_FORMULA_COMMON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_FORMULA_COMMON_PKG" AS
-- $Header: cnfmcomb.pls 120.18.12010000.2 2008/11/20 09:34:31 ppillai ship $

-- This package contains the procedures of calculation engine, some of which will be called from each formula packages

-- global variable for this package
  G_LAST_UPDATE_DATE    DATE    := sysdate;
  G_LAST_UPDATED_BY     NUMBER  := fnd_global.user_id;
  G_CREATION_DATE       DATE    := sysdate;
  G_CREATED_BY          NUMBER  := fnd_global.user_id;
  G_LAST_UPDATE_LOGIN   NUMBER  := fnd_global.login_id;

  g_intel_calc_flag     VARCHAR2(1);
  g_calc_type           VARCHAR2(30);

  g_precision           NUMBER;
  g_ext_precision       NUMBER;
  api_call_failed       EXCEPTION;

  TYPE comm_line_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE comm_status_tab IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;


  TYPE amt_rate_rec_type is RECORD
    (amount	     NUMBER,
     tier_range      NUMBER,
     rate	     NUMBER);

  TYPE amt_rate_tbl_type IS TABLE OF amt_rate_rec_type INDEX BY BINARY_INTEGER;

  -- caching rate tables:
  -- 1. The information about the rate table currently used in calculation is stored in the following global variables
  -- 2. When there is a dynamic rate dimension, the tiers of this dimension are evaluated and the results are stored in g_dim_tier_table
  -- 3. Upon each call to get_rates, these global variables are refreshed if necessary
  -- 4. If the rate table is the same, then only commission rates are refreshed

  -- global variables for caching of multi-dimensional rate table
  TYPE dim_tier_rec_type IS RECORD
    (tier_sequence    NUMBER,
     minimum_amount   NUMBER,
     maximum_amount   NUMBER,
     min_exp_id       NUMBER,
     max_exp_id       NUMBER,
     string_value     VARCHAR2(30));
  TYPE dim_tier_tbl_type IS TABLE OF dim_tier_rec_type INDEX BY BINARY_INTEGER;
  TYPE number_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE str1_tbl_type IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;

  -- table for caching dimension tiers
  g_dim_tier_table            dim_tier_tbl_type;

  -- table for caching dimension size
  g_dim_size_table            number_tbl_type;

  -- table for caching dimension type
  g_dim_type_table            str1_tbl_type;

  -- table to mark dynamic dimension tiers
  g_dynamic_tier_table        number_tbl_type;

  -- table for caching the initial position of each dimension's tiers in g_dim_tier_table
  g_tier_index_table          number_tbl_type;

  -- table for caching commission_amounts
  g_comm_amount_table         number_tbl_type;

  -- table for caching rate_tier_ids
  g_rate_tier_id_table        number_tbl_type;

  -- variables to uniquely identify a rate table
  -- 1) g_srp_plan_assign_id identifies salesrep and compensation plan
  g_srp_plan_assign_id        NUMBER;
  -- 2) g_rt_quota_asgn_id identifies plan element, formula(main formula or embedded formula), date range and rate table
  g_rt_quota_asgn_id          NUMBER;
  -- 3) g_rate_schedule_id identifies the rate table
  g_rate_schedule_id          NUMBER;
  -- 4) g_customized_flag indicates whether comission_amounts are customized
  g_customized_flag           VARCHAR2(1);
  -- 5) g_period_id tells whether dynamic dimension tiers should be refreshed or not
  g_period_id                 NUMBER;

  g_refresh_flag              VARCHAR2(1);

PROCEDURE revert_posting_line (p_commission_line_id NUMBER)
IS
  l_pmt_trans_rec              CN_PMT_TRANS_PKG.pmt_trans_rec_type;

  CURSOR get_comm_line_rec IS
    (SELECT CN_API.G_MISS_ID payment_transaction_id,
            -1 posting_batch_id,
            cl.credited_salesrep_id,
		    cl.credited_salesrep_id payee_salesrep_id,
            cl.quota_id,
            cl.pay_period_id,
            pe.incentive_type_code,
            cl.credit_type_id,
            NULL, -- payrun_id
            nvl(cl.commission_amount,0)       amount,
            nvl(cl.commission_amount,0)        payment_amount, -- default
            'N'                                hold_flag, -- default N
 	        'N'                                paid_flag, -- default N
            'N'                                waive_flag, -- default N
            'N'                                recoverable_flag, -- default N
            cl.commission_header_id,
            cl.commission_line_id,
            null, -- pay_element_type_id
            cl.srp_plan_assign_id,
            cl.processed_date,
            cl.processed_period_id,
            cl.quota_rule_id,
            cl.event_factor,
            cl.payment_factor,
            cl.quota_factor,
            cl.input_achieved,
            cl.rate_tier_id,
            cl.payee_line_id,
            cl.commission_rate,
            cl.trx_type,
            cl.role_id,
            pe.expense_account_id    expense_ccid,
            pe.liability_account_id    liability_ccid,
            NULL, --cl.attribute_category,
            NULL, --cl.attribute1,
            null, --cl.attribute2,
            null, --cl.attribute3,
            null, --cl.attribute4,
            null, --cl.attribute5,
            null, --cl.attribute6,
            null, --cl.attribute7,
            null, --cl.attribute8,
            null, --cl.attribute9,
            null, --cl.attribute10,
            null, --cl.attribute11,
            null, --cl.attribute12,
            null, --cl.attribute13,
            null, --cl.attribute14,
            null, --cl.attribute15
            cl.org_id,
			0
          FROM cn_commission_lines_all cl,
               cn_quotas_all  pe
         WHERE cl.commission_line_id = p_commission_line_id
           AND cl.quota_id = pe.quota_id
           AND cl.srp_payee_assign_id IS NULL)
      UNION --this is added for assign payees for fixing bug#2495614
    (SELECT CN_API.G_MISS_ID   payment_transaction_id,
            -1 posting_batch_id,
            payee.payee_id credited_salesrep_id,
            payee.payee_id payee_salesrep_id,
            cl.quota_id,
            cl.pay_period_id,
            pe.incentive_type_code,
            cl.credit_type_id,
            NULL, -- payrun_id
            nvl(cl.commission_amount,0)       amount,
            nvl(cl.commission_amount,0)        payment_amount, -- default
            'N'                                hold_flag, -- default N
 	        'N'                                paid_flag, -- default N
            'N'                                waive_flag, -- default N
            'N'                                recoverable_flag, -- default N
            cl.commission_header_id,
            cl.commission_line_id,
            null, -- pay_element_type_id
            cl.srp_plan_assign_id,
            cl.processed_date,
            cl.processed_period_id,
            cl.quota_rule_id,
            cl.event_factor,
            cl.payment_factor,
            cl.quota_factor,
            cl.input_achieved,
            cl.rate_tier_id,
            cl.payee_line_id,
            cl.commission_rate,
            cl.trx_type,
            54,--cl.role_id
            pe.expense_account_id    expense_ccid,
            pe.liability_account_id    liability_ccid,
            NULL, --cl.attribute_category,
            NULL, --cl.attribute1,
            null, --cl.attribute2,
            null, --cl.attribute3,
            null, --cl.attribute4,
            null, --cl.attribute5,
            null, --cl.attribute6,
            null, --cl.attribute7,
            null, --cl.attribute8,
            null, --cl.attribute9,
            null, --cl.attribute10,
            null, --cl.attribute11,
            null, --cl.attribute12,
            null, --cl.attribute13,
            null, --cl.attribute14,
            null, --cl.attribute15
            cl.org_id,
            0
       FROM cn_commission_lines_all cl,
            cn_srp_payee_assigns_all payee,
            cn_quotas_all pe
      WHERE cl.commission_line_id = p_commission_line_id
        AND cl.quota_id = pe.quota_id
        AND cl.srp_payee_assign_id IS NOT NULL
        AND payee.srp_payee_assign_id = cl.srp_payee_assign_id);
BEGIN
  If (fnd_profile.value('CN_PAY_BY_TRANSACTION') = 'Y') THEN
     -- Build Payment Record record from Commission Line
     OPEN get_comm_line_rec;
     FETCH get_comm_line_rec INTO l_pmt_trans_rec;
     IF get_comm_line_rec%ROWCOUNT <> 1 THEN
       CLOSE get_comm_line_rec;
	   FND_MESSAGE.SET_NAME('CN', 'CN_INVALID_COMMISSION_LINE');
	   FND_MESSAGE.SET_TOKEN('COMMISSION_LINE_ID', TO_CHAR(p_commission_line_id));
	   FND_MSG_PUB.ADD;
	   RAISE FND_API.G_EXC_ERROR;
     END IF;
     CLOSE get_comm_line_rec;

	 l_pmt_trans_rec.amount := l_pmt_trans_rec.amount * -1;
	 l_pmt_trans_rec.payment_amount := 0 - l_pmt_trans_rec.payment_amount;

     -- insert record into CN_PAYMENT_TRANSACTIONS
	 CN_PMT_TRANS_PKG.Insert_Record(l_pmt_trans_rec);

	 -- make sure it is not reverted twice
	 update cn_commission_lines
	    set posting_status = 'REVERTED'
	  where commission_line_id = p_commission_line_id;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                     'cn.plsql.cn_formula_common_pkg.revert_posting_line.exception',
	       		     sqlerrm);
    end if;
	cn_message_pkg.debug('Exception occurs in reversing posted line (ID='|| p_commission_line_id||')');
	cn_message_pkg.debug(sqlerrm);
	RAISE;
END revert_posting_line;

  PROCEDURE Select_Tier( p_rate_dim_sequence  NUMBER,
			 p_quota_achieved     NUMBER,
			 p_string_value       VARCHAR2,
			 p_direction          NUMBER,
			 x_tier_sequence  OUT NOCOPY NUMBER)
    IS
       l_tier_min NUMBER;
       l_tier_max NUMBER;
  BEGIN
     -- if it is a string_based dimension, then ...
     IF (g_dim_type_table(p_rate_dim_sequence) = 'S') THEN
       IF (p_string_value IS NOT NULL) THEN
	 FOR i IN g_tier_index_table(p_rate_dim_sequence)..(g_tier_index_table(p_rate_dim_sequence) + g_dim_size_table(p_rate_dim_sequence) - 1) LOOP
	   IF (g_dim_tier_table(i).string_value = p_string_value) THEN
	      x_tier_sequence := g_dim_tier_table(i).tier_sequence;
	      RETURN;
	   END IF;
	 END LOOP;

	 -- if there is no exact match, default to the last tier
	 IF (x_tier_sequence IS NULL) THEN
	   x_tier_sequence := g_dim_size_table(p_rate_dim_sequence);
           return;
	 END IF;
       ELSE
         x_tier_sequence := g_dim_size_table(p_rate_dim_sequence);
         return;
       END IF;
     END IF;

     l_tier_min := g_dim_tier_table(g_tier_index_table(p_rate_dim_sequence)).minimum_amount;
     l_tier_max := g_dim_tier_table(g_tier_index_table(p_rate_dim_sequence) + g_dim_size_table(p_rate_dim_sequence)- 1).maximum_amount;

     IF (p_quota_achieved >= l_tier_max) THEN
	x_tier_sequence := g_dim_size_table(p_rate_dim_sequence);
      ELSIF (p_quota_achieved <= l_tier_min) THEN
	x_tier_sequence := 1;
      ELSIF (p_direction > 0) THEN
	FOR i IN g_tier_index_table(p_rate_dim_sequence)..(g_tier_index_table(p_rate_dim_sequence) + g_dim_size_table(p_rate_dim_sequence) - 1) LOOP
	   IF (p_quota_achieved >= g_dim_tier_table(i).minimum_amount AND p_quota_achieved < g_dim_tier_table(i).maximum_amount) THEN
	      x_tier_sequence := g_dim_tier_table(i).tier_sequence;
	      EXIT;
	   END IF;
	END LOOP;
      ELSE
	FOR i IN g_tier_index_table(p_rate_dim_sequence)..(g_tier_index_table(p_rate_dim_sequence) + g_dim_size_table(p_rate_dim_sequence) - 1) LOOP
	   IF (p_quota_achieved > g_dim_tier_table(i).minimum_amount AND p_quota_achieved <= g_dim_tier_table(i).maximum_amount) THEN
	      x_tier_sequence := g_dim_tier_table(i).tier_sequence;
	      EXIT;
	   END IF;
	END LOOP;
     END IF;
  EXCEPTION
     WHEN OTHERS THEN
		if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                         'cn.plsql.cn_formula_common_pkg.select_tier.exception',
		       		     sqlerrm);
        end if;
	    cn_message_pkg.debug('Exception occurs in identifying rate tier:');
		cn_message_pkg.debug('p_direction=' || p_direction);
		cn_message_pkg.debug('p_quota_achieved='|| p_quota_achieved);
	    cn_message_pkg.debug(sqlerrm);
	    RAISE;
  END Select_Tier;

  PROCEDURE get_rate_sequence(p_number_dim         NUMBER ,
			      p_mul_input_tbl      mul_input_tbl_type,
			      x_rate_sequence  OUT NOCOPY NUMBER)
    IS
       l_base NUMBER := 1;
       l_rate_sequence NUMBER := 0;
  BEGIN
     FOR i IN REVERSE 1..p_mul_input_tbl.COUNT LOOP
	IF (i = p_number_dim) THEN
	   l_rate_sequence := l_rate_sequence + p_mul_input_tbl(i).tier_sequence;
	 ELSE
	   l_rate_sequence := l_rate_sequence + (p_mul_input_tbl(i).tier_sequence - 1) * l_base;
	END IF;

	l_base := l_base * g_dim_size_table(i);
     END LOOP;

     x_rate_sequence := l_rate_sequence;
  EXCEPTION
    WHEN OTHERS THEN
		if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                         'cn.plsql.cn_formula_common_pkg.get_rate_sequence.exception',
		       		     sqlerrm);
        end if;

     cn_message_pkg.debug('Exception occurs in getting rate sequence: ');
     cn_message_pkg.debug(sqlerrm);
     RAISE;
  END get_rate_sequence;


  FUNCTION get_comm_amount(p_rate_sequence NUMBER) RETURN NUMBER IS
     l_comm_amount NUMBER;
  BEGIN
     l_comm_amount := g_comm_amount_table(p_rate_sequence);
     RETURN l_comm_amount;
  EXCEPTION
     WHEN no_data_found THEN
	RETURN 0;
  END get_comm_amount;

  FUNCTION get_rate_tier_id(p_rate_sequence NUMBER) RETURN NUMBER IS
     l_rate_tier_id NUMBER;
  BEGIN
     l_rate_tier_id := g_rate_tier_id_table(p_rate_sequence);
     RETURN l_rate_tier_id;
  EXCEPTION
     WHEN no_data_found THEN
	RETURN -1;
  END get_rate_tier_id;

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
			x_tier_split    OUT NOCOPY     NUMBER   ) IS

    l_rate	number;
    l_rate_schedule_id      NUMBER(15);
    l_rt_quota_asgn_id      NUMBER(15);

    i                       pls_integer := 1;
    n                       pls_integer := 1;
    j                       pls_integer := 1;
    l_refresh_dim_tier_flag VARCHAR2(1) := 'Y';
    l_refresh_rate_flag     VARCHAR2(1) := 'Y';
    l_refresh_all_tier_flag VARCHAR2(1) := 'Y';

    l_sql_select            VARCHAR2(2000);
    l_sql_from              VARCHAR2(1000);
    l_where_clause          VARCHAR2(1000);


    l_split_tbl	            amt_rate_tbl_type;
    l_counter	            NUMBER := 1;
    l_base_amount           NUMBER;
    l_amount                NUMBER;
    l_to_next_tier          NUMBER;
    l_to_prev_tier          NUMBER;
    l_tier_sequence         NUMBER;
    l_rate_sequence         NUMBER;
    l_split_dim             NUMBER;
    l_sequence_cycle        NUMBER;

    l_customized_flag       VARCHAR2(1);

    l_comm_amount_table         number_tbl_type;
    l_rate_tier_id_table        number_tbl_type;
    l_rate_sequence_table       number_tbl_type;

    CURSOR dims_info IS
       SELECT dim.number_tier, dim.dim_unit_code, rsd.rate_dimension_id
	 FROM cn_rate_dimensions_all dim,
	      cn_rate_sch_dims_all rsd
	 WHERE rsd.rate_schedule_id = l_rate_schedule_id
	 AND dim.rate_dimension_id = rsd.rate_dimension_id
	 ORDER BY rsd.rate_dim_sequence;

    CURSOR dim_tiers(p_rate_dimension_id NUMBER) IS
       SELECT tier_sequence, minimum_amount, maximum_amount, min_exp_id, max_exp_id, string_value
	 FROM cn_rate_dim_tiers_all
	 WHERE rate_dimension_id = p_rate_dimension_id
	 ORDER BY tier_sequence;

    CURSOR tier_exp(p_calc_sql_exp_id NUMBER) IS
       SELECT dbms_lob.substr(sql_select) sql_select,
	      dbms_lob.substr(sql_from) sql_from
	 FROM cn_calc_sql_exps_all
	 WHERE calc_sql_exp_id = p_calc_sql_exp_id;

    CURSOR comm_amounts IS
       SELECT commission_amount, rate_tier_id, rate_sequence
	 FROM cn_srp_rate_assigns_all
	 WHERE srp_plan_assign_id = p_srp_plan_assign_id
	 AND rt_quota_asgn_id = l_rt_quota_asgn_id
	 ORDER BY rate_sequence;

    CURSOR comm_amounts2 IS
       SELECT commission_amount, rate_tier_id, rate_sequence
	 FROM cn_rate_tiers_all
	 WHERE rate_schedule_id = l_rate_schedule_id
	 ORDER BY rate_sequence;

    CURSOR split_dim IS
       SELECT rate_dim_sequence
	 FROM cn_formula_inputs_all
	 WHERE calc_formula_id = p_calc_formula_id
         AND nvl(split_flag, 'N') <> 'N';
  BEGIN
     SELECT rate_schedule_id, rt_quota_asgn_id
       INTO l_rate_schedule_id, l_rt_quota_asgn_id
       FROM cn_rt_quota_asgns_all
       WHERE quota_id = p_quota_id
       AND (calc_formula_id = p_calc_formula_id OR (calc_formula_id IS NULL AND p_calc_formula_id IS NULL))
       AND (( end_date IS NOT NULL AND p_processed_date BETWEEN start_date AND end_date)
	    OR (end_date IS NULL AND p_processed_date >= start_date ));

     -- Rate Table Refreshing Rules:
     --    if (g_srp_plan_assign_id = p_srp_plan_assign_id and g_rt_quota_asgn_id = l_rt_quota_asgn_id) then
     --      if (g_period_id = p_period_id) then
     --        no refresh
     --      else
     --        refresh dynamic dimension tiers
     --        g_period_id = p_period_id
     --      end if;
     --    elsif (g_rate_schedule_id = l_rate_schedule_id) then
     --      refresh dynamic dimension tiers and commission amounts
     --      g_srp_plan_assign_id = p_srp_plan_assign_id
     --      g_rt_quota_asgn_id = l_rt_quota_asgn_id
     --      g_period_id
     --    else
     --      refresh everything
     --    end if;

     IF (g_refresh_flag = 'Y') THEN
	g_refresh_flag := 'N';
	g_srp_plan_assign_id := p_srp_plan_assign_id;
	g_rt_quota_asgn_id := l_rt_quota_asgn_id;
	g_rate_schedule_id := l_rate_schedule_id;
	g_period_id := p_period_id;
      ELSIF (g_srp_plan_assign_id = p_srp_plan_assign_id and g_rt_quota_asgn_id = l_rt_quota_asgn_id) THEN
	IF (g_period_id = p_period_id) THEN
	   -- no refresh
	   l_refresh_all_tier_flag := 'N';
	   l_refresh_dim_tier_flag := 'N';
	   l_refresh_rate_flag := 'N';
	 ELSE
	   g_period_id := p_period_id;

	   -- refresh dynamic dimension tiers
	   l_refresh_all_tier_flag := 'N';
	   l_refresh_rate_flag := 'N';
	END IF;
      ELSIF (g_rate_schedule_id = l_rate_schedule_id) THEN
	g_srp_plan_assign_id := p_srp_plan_assign_id;
	g_rt_quota_asgn_id := l_rt_quota_asgn_id;
	g_period_id := p_period_id;

	-- refresh dynamic dimension tiers and commission amounts
	l_refresh_all_tier_flag := 'N';
      ELSE
	-- if (g_rate_schedule_id IS NULL OR g_rate_schedule_id <> l_rate_schedule_id) THEN
	-- refresh everything
	g_srp_plan_assign_id := p_srp_plan_assign_id;
	g_rt_quota_asgn_id := l_rt_quota_asgn_id;
	g_rate_schedule_id := l_rate_schedule_id;
	g_period_id := p_period_id;
     END IF;


     IF (l_refresh_all_tier_flag = 'Y') THEN
	g_dim_tier_table.DELETE;
	g_dim_size_table.DELETE;
        g_dim_type_table.DELETE;
	g_tier_index_table.DELETE;
	g_dynamic_tier_table.DELETE;
	g_comm_amount_table.DELETE;

	FOR dim IN dims_info LOOP
	   g_dim_size_table(i) := dim.number_tier;

           IF (dim.dim_unit_code = 'STRING') then
             g_dim_type_table(i) := 'S';
           ELSE
             g_dim_type_table(i) := 'N';
           END IF;

	   IF (i = 1) THEN
	      g_tier_index_table(i) := 1;
	    ELSE
	      g_tier_index_table(i) := g_tier_index_table(i-1) + g_dim_size_table(i-1);
	   END IF;

	   FOR dim_tier IN dim_tiers(dim.rate_dimension_id) LOOP
	      g_dim_tier_table(n).tier_sequence := dim_tier.tier_sequence;

	      IF (dim.dim_unit_code = 'STRING') THEN
		 g_dim_tier_table(n).string_value := dim_tier.string_value;
	       ELSIF (dim.dim_unit_code = 'EXPRESSION') THEN
		 g_dim_tier_table(n).min_exp_id := dim_tier.min_exp_id;
		 g_dim_tier_table(n).max_exp_id := dim_tier.max_exp_id;
		 g_dynamic_tier_table(j) := n;
		 j := j + 1;
	       ELSE
		 g_dim_tier_table(n).minimum_amount := dim_tier.minimum_amount;
		 g_dim_tier_table(n).maximum_amount := dim_tier.maximum_amount;
	      END IF;

	      n := n + 1;
	   END LOOP;

	   i := i + 1;
	END LOOP;
     END IF;

     IF (l_refresh_dim_tier_flag = 'Y') THEN
	FOR k IN 1..g_dynamic_tier_table.COUNT LOOP
	   IF (k = 1 OR
	       (k > 1 AND g_dim_tier_table(g_dynamic_tier_table(k-1)).max_exp_id <> g_dim_tier_table(g_dynamic_tier_table(k)).min_exp_id))
	   THEN
	      OPEN tier_exp(g_dim_tier_table(g_dynamic_tier_table(k)).min_exp_id);
	      FETCH tier_exp INTO l_sql_select, l_sql_from;
	      CLOSE tier_exp;

	      l_where_clause := ':p_srp_plan_assign_id = :p_srp_plan_assign_id and :p_quota_id = :p_quota_id and :p_period_id = :p_period_id';
	      IF (instr(l_sql_from, 'CN_SRP_QUOTA_ASSIGNS', 1, 1) > 0) THEN
		 l_where_clause := l_where_clause || ' and CSQA.srp_plan_assign_id = :p_srp_plan_assign_id and CSQA.quota_id = :p_quota_id';
	      END IF;

	      IF (instr(l_sql_from, 'CN_SRP_PERIOD_QUOTAS', 1, 1) > 0) THEN
		 l_where_clause := l_where_clause || ' and CSPQ.srp_plan_assign_id = :p_srp_plan_assign_id' ||
		                   ' and CSPQ.quota_id = :p_quota_id and CSPQ.period_id = :p_period_id';
	      END IF;

	      IF (instr(l_sql_from, 'CN_PERIOD_QUOTAS', 1, 1) > 0) THEN
		 l_where_clause := l_where_clause || ' and CPQ.quota_id = :p_quota_id and CPQ.period_id = :p_period_id';
	      END IF;

	      IF (instr(l_sql_from, 'CN_QUOTAS', 1, 1) > 0) THEN
		 l_where_clause := l_where_clause || ' and CQ.quota_id = :p_quota_id';
	      END IF;

	      l_where_clause := ' where ' || l_where_clause;

	      execute immediate 'begin select ' || l_sql_select || ' into :x from ' || l_sql_from || l_where_clause || '; end;'
		using OUT g_dim_tier_table(g_dynamic_tier_table(k)).minimum_amount, p_srp_plan_assign_id, p_quota_id, p_period_id;
	    ELSE
	      g_dim_tier_table(g_dynamic_tier_table(k)).minimum_amount := g_dim_tier_table(g_dynamic_tier_table(k-1)).maximum_amount;
	   END IF;

	   -- get maximum_amount
	   OPEN tier_exp(g_dim_tier_table(g_dynamic_tier_table(k)).max_exp_id);
	   FETCH tier_exp INTO l_sql_select, l_sql_from;
	   CLOSE tier_exp;

	   l_where_clause := ':p_srp_plan_assign_id = :p_srp_plan_assign_id and :p_quota_id = :p_quota_id and :p_period_id = :p_period_id';
	   IF (instr(l_sql_from, 'CN_SRP_QUOTA_ASSIGNS', 1, 1) > 0) THEN
	      l_where_clause := l_where_clause || ' and CSQA.srp_plan_assign_id = :p_srp_plan_assign_id and CSQA.quota_id = :p_quota_id';
	   END IF;

	   IF (instr(l_sql_from, 'CN_SRP_PERIOD_QUOTAS', 1, 1) > 0) THEN
	      l_where_clause := l_where_clause || ' and CSPQ.srp_plan_assign_id = :p_srp_plan_assign_id' ||
		' and CSPQ.quota_id = :p_quota_id and CSPQ.period_id = :p_period_id';
	   END IF;

	   IF (instr(l_sql_from, 'CN_PERIOD_QUOTAS', 1, 1) > 0) THEN
	      l_where_clause := l_where_clause || ' and CPQ.quota_id = :p_quota_id and CPQ.period_id = :p_period_id';
	   END IF;

	   IF (instr(l_sql_from, 'CN_QUOTAS', 1, 1) > 0) THEN
	      l_where_clause := l_where_clause || ' and CQ.quota_id = :p_quota_id';
	   END IF;

	   l_where_clause := ' where ' || l_where_clause;

	   execute immediate 'begin select ' || l_sql_select || ' into :x from ' || l_sql_from || l_where_clause || '; end;'
	     using OUT g_dim_tier_table(g_dynamic_tier_table(k)).maximum_amount, p_srp_plan_assign_id, p_quota_id, p_period_id;
	END LOOP;
     END IF;

     IF (l_refresh_rate_flag = 'Y') THEN
       g_rate_tier_id_table.DELETE;
       g_comm_amount_table.DELETE;

	SELECT customized_flag
	  INTO l_customized_flag
	  FROM cn_srp_quota_assigns_all
	  WHERE srp_plan_assign_id = p_srp_plan_assign_id
	  AND quota_id = p_quota_id;

	IF (l_customized_flag = 'Y') then
           open comm_amounts;
           FETCH comm_amounts bulk collect INTO l_comm_amount_table, l_rate_tier_id_table, l_rate_sequence_table;
	       CLOSE comm_amounts;

           if l_comm_amount_table.count > 0 then
             for i in l_comm_amount_table.first..l_comm_amount_table.last loop
               g_comm_amount_table(l_rate_sequence_table(i)) := l_comm_amount_table(i);
               g_rate_tier_id_table(l_rate_sequence_table(i)) := l_rate_tier_id_table(i);
             end loop;
           end if;
	 ELSE
           open comm_amounts2;
           FETCH comm_amounts2 bulk collect INTO l_comm_amount_table, l_rate_tier_id_table, l_rate_sequence_table;
	       CLOSE comm_amounts2;

           if l_comm_amount_table.count > 0 then
             for i in l_comm_amount_table.first..l_comm_amount_table.last loop
               g_comm_amount_table(l_rate_sequence_table(i)) := l_comm_amount_table(i);
               g_rate_tier_id_table(l_rate_sequence_table(i)) := l_rate_tier_id_table(i);
             end loop;
           end if;
	END IF;
     END IF;

	IF (p_split_flag = 'N') THEN
	   FOR ctr IN 1 .. p_number_dim LOOP
	      select_tier( p_mul_input_tbl(ctr).rate_dim_sequence,
			   p_mul_input_tbl(ctr).base_amount,
			   p_mul_input_tbl(ctr).input_string,
			   p_mul_input_tbl(ctr).amount,
			   p_mul_input_tbl(ctr).tier_sequence);
	   END LOOP ;

	   get_rate_sequence(p_number_dim,
			     p_mul_input_tbl,
			     l_rate_sequence);

	   x_rate := get_comm_amount(l_rate_sequence);
	   x_rate_tier_id := get_rate_tier_id(l_rate_sequence);
	   x_tier_split := 1;
	 ELSE
	   l_rate := 0;

	   FOR ctr IN 1 .. p_number_dim LOOP
	      select_tier(p_mul_input_tbl(ctr).rate_dim_sequence,
			  p_mul_input_tbl(ctr).base_amount,
			  p_mul_input_tbl(ctr).input_string,
			  p_mul_input_tbl(ctr).amount,
			  p_mul_input_tbl(ctr).tier_sequence);
	   END LOOP;

	   get_rate_sequence(p_number_dim,
			     p_mul_input_tbl,
			     l_rate_sequence);

	   --x_rate_tier_id := g_rate_tier_id_table(l_rate_sequence);
	   x_rate_tier_id := get_rate_tier_id(l_rate_sequence);

           -- clku
           IF p_calc_formula_id is null THEN

                     l_split_dim := 1;
           ELSE
	      -- get the splitting dimension
	      OPEN split_dim;
	      FETCH split_dim INTO l_split_dim;
	      CLOSE split_dim;

           END IF;


	   l_tier_sequence := p_mul_input_tbl(l_split_dim).tier_sequence;
	   l_base_amount := p_mul_input_tbl(l_split_dim).base_amount;
	   l_amount := p_mul_input_tbl(l_split_dim).amount;
	   l_counter := 1;

	   l_sequence_cycle := 1;
	   FOR idx IN REVERSE (l_split_dim+1)..g_dim_size_table.COUNT LOOP
	      l_sequence_cycle := l_sequence_cycle * g_dim_size_table(idx);
	   END LOOP;

	   IF (l_amount > 0) THEN
	      l_to_next_tier := g_dim_tier_table(g_tier_index_table(l_split_dim) + l_tier_sequence - 1).maximum_amount - l_base_amount;
	      WHILE (l_amount > l_to_next_tier AND l_to_next_tier >= 0) LOOP
		 IF (l_tier_sequence < g_dim_size_table(l_split_dim)) THEN
		    l_split_tbl(l_counter).amount := l_to_next_tier;
		    l_split_tbl(l_counter).tier_range :=
		      g_dim_tier_table(g_tier_index_table(l_split_dim) + l_tier_sequence - 1).maximum_amount -
		      g_dim_tier_table(g_tier_index_table(l_split_dim) + l_tier_sequence - 1).minimum_amount;
		    l_split_tbl(l_counter).rate := get_comm_amount(l_rate_sequence + (l_counter - 1) * l_sequence_cycle);
		  ELSE
		    EXIT;
		 END IF;

		 l_base_amount := g_dim_tier_table(g_tier_index_table(l_split_dim) + l_tier_sequence - 1).maximum_amount;
		 l_amount := l_amount - l_to_next_tier;
		 l_tier_sequence := l_tier_sequence + 1;
		 l_counter := l_counter + 1;
		 l_to_next_tier := g_dim_tier_table(g_tier_index_table(l_split_dim) + l_tier_sequence - 1).maximum_amount - l_base_amount;
	      END LOOP;
	      IF (l_amount > 0) THEN
		 l_split_tbl(l_counter).amount := l_amount;
		 l_split_tbl(l_counter).tier_range :=
		   g_dim_tier_table(g_tier_index_table(l_split_dim) + l_tier_sequence - 1).maximum_amount -
		   g_dim_tier_table(g_tier_index_table(l_split_dim) + l_tier_sequence - 1).minimum_amount;
		 l_split_tbl(l_counter).rate := get_comm_amount(l_rate_sequence + (l_counter - 1) * l_sequence_cycle);
	      END IF;
	    ELSIF (l_amount < 0) THEN
	      l_to_prev_tier := g_dim_tier_table(g_tier_index_table(l_split_dim) + l_tier_sequence - 1).minimum_amount - l_base_amount;
	      WHILE (l_amount < l_to_prev_tier AND l_to_prev_tier <= 0) LOOP
		 IF (l_tier_sequence > 1) THEN
		    l_split_tbl(l_counter).amount := l_to_prev_tier;
		    l_split_tbl(l_counter).tier_range :=
		      g_dim_tier_table(g_tier_index_table(l_split_dim) + l_tier_sequence - 1).maximum_amount -
		      g_dim_tier_table(g_tier_index_table(l_split_dim) + l_tier_sequence - 1).minimum_amount;
		    l_split_tbl(l_counter).rate := get_comm_amount(l_rate_sequence - (l_counter - 1) * l_sequence_cycle);
		  ELSE
		    EXIT;
		 END IF;

		 l_base_amount := g_dim_tier_table(g_tier_index_table(l_split_dim) + l_tier_sequence - 1).minimum_amount;
		 l_amount := l_amount - l_to_prev_tier;
		 l_tier_sequence := l_tier_sequence - 1;
		 l_counter := l_counter + 1;
		 l_to_prev_tier := g_dim_tier_table(g_tier_index_table(l_split_dim) + l_tier_sequence - 1).minimum_amount - l_base_amount;
	      END LOOP;
	      IF (l_amount < 0) THEN
		 l_split_tbl(l_counter).amount := l_amount;
		 l_split_tbl(l_counter).tier_range :=
		   g_dim_tier_table(g_tier_index_table(l_split_dim) + l_tier_sequence - 1).maximum_amount -
		   g_dim_tier_table(g_tier_index_table(l_split_dim) + l_tier_sequence - 1).minimum_amount;
		 l_split_tbl(l_counter).rate := get_comm_amount(l_rate_sequence - (l_counter - 1) * l_sequence_cycle);
	      END IF;
	    ELSE
		 l_split_tbl(1).amount := l_amount;
		 l_split_tbl(1).tier_range :=
		   g_dim_tier_table(g_tier_index_table(l_split_dim) + l_tier_sequence - 1).maximum_amount -
		   g_dim_tier_table(g_tier_index_table(l_split_dim) + l_tier_sequence - 1).minimum_amount;
		 l_split_tbl(1).rate := get_comm_amount(l_rate_sequence);
	   END IF;


	   IF p_split_flag = 'P' THEN
	      FOR i IN 1 .. l_split_tbl.count LOOP
		    l_rate := l_rate + (l_split_tbl(i).amount/l_split_tbl(i).tier_range) * l_split_tbl(i).rate;
	      END LOOP;
	    ELSIF p_split_flag = 'Y' THEN
	      FOR i IN 1 .. l_split_tbl.count LOOP
		 IF (p_mul_input_tbl(l_split_dim).amount = 0) THEN
		    l_rate := l_rate + l_split_tbl(i).rate;
		  ELSE
		    l_rate := l_rate + (l_split_tbl(i).amount/p_mul_input_tbl(l_split_dim).amount) * l_split_tbl(i).rate;
		 END IF;
	      END LOOP;
	   END IF;

	   x_rate := l_rate;
	   x_tier_split := l_split_tbl.COUNT;

	   l_split_tbl.delete;
	END IF;

    IF x_rate IS NULL THEN
	  RAISE no_data_found;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
	  if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       'cn.plsql.cn_formula_common_pkg.get_rates.exception',
	       		       sqlerrm);
      end if;

     cn_message_pkg.debug('Exception occurs in getting commission rate: ');
     cn_message_pkg.debug(sqlerrm);
     RAISE;
  END get_rates;

  PROCEDURE delete_itd_trx( p_salesrep_id         NUMBER ,
			    p_srp_plan_assign_id  NUMBER ,
			    p_quota_id            NUMBER ,
			    p_period_id           NUMBER     ) IS
     CURSOR l_itd_trx_csr IS
	SELECT commission_line_id, commission_header_id,
           posting_status, commission_amount
       FROM cn_commission_lines_all
       WHERE credited_salesrep_id = p_salesrep_id
       AND srp_plan_assign_id = p_srp_plan_assign_id
       AND processed_period_id = p_period_id
       AND quota_id = p_quota_id
       AND trx_type = 'ITD'
       AND status = 'CALC';

     l_itd_trx  l_itd_trx_csr%ROWTYPE;
  BEGIN
     OPEN l_itd_trx_csr;
     FETCH l_itd_trx_csr INTO l_itd_trx;

     IF l_itd_trx_csr%found THEN
	IF l_itd_trx.posting_status = 'POSTED' THEN
	   revert_posting_line ( l_itd_trx.commission_line_id);
	END IF;

	DELETE cn_commission_headers_all
	  WHERE commission_header_id = l_itd_trx.commission_header_id;

	DELETE cn_commission_lines_all
	  WHERE commission_line_id = l_itd_trx.commission_line_id;

	UPDATE cn_srp_period_quotas_all
	  SET commission_payed_ptd = commission_payed_ptd - l_itd_trx.commission_amount,
	  commission_payed_itd = commission_payed_itd - l_itd_trx.commission_amount
	  WHERE salesrep_id = p_salesrep_id
	  AND period_id = p_period_id
	  AND srp_plan_assign_id = p_srp_plan_assign_id
	  AND quota_id = p_quota_id;
     END IF;

     CLOSE l_itd_trx_csr;
  END delete_itd_trx;

  --     To initialize before going to calculation. Also determine the x_select_status_flag,
  --	 signaling that trxs in which trx_status will be selected to calculate.
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
			    x_input_achieved_ptd  OUT NOCOPY num_table_type ,
			    x_input_achieved_itd  OUT NOCOPY num_table_type ,
			    x_output_achieved_ptd  OUT NOCOPY NUMBER ,
			    x_output_achieved_itd  OUT NOCOPY 	NUMBER ,
			    x_perf_achieved_ptd  OUT NOCOPY NUMBER ,
			    x_perf_achieved_itd  OUT NOCOPY 	NUMBER ,
			    x_select_status_flag OUT NOCOPY VARCHAR2   )
  IS
     l_incremental_flag cn_quotas.incremental_type%TYPE;
     l_input_achieved   NUMBER ;
     l_output_achieved  NUMBER ;
     l_perf_achieved    NUMBER ;
     l_commission_achieved NUMBER;

     l_credit_type_name cn_credit_types.name%TYPE;
     l_start_period_id NUMBER;
     l_end_period_id NUMBER;
     l_interval_type_id NUMBER;
     l_org_id NUMBER;
     l_same_pe_rollover NUMBER;
     l_source_pe_rollover NUMBER;

	 l_commission_payed_itd NUMBER := 0;
	 l_input_achieved_itd NUMBER := 0;
	 l_output_achieved_itd NUMBER := 0;
	 l_perf_achieved_itd NUMBER := 0;
	 l_advance_recovered_itd NUMBER := 0;
	 l_advance_to_rec_itd NUMBER := 0;
	 l_recovery_amount_itd NUMBER := 0;
	 l_comm_pend_itd NUMBER := 0;

	 l_srp_period_quota_id NUMBER(15);
	 l_input_achieved_itd_tbl cn_formula_common_pkg.num_table_type;

     CURSOR l_quota_csr (l_quota_id NUMBER ) IS
	SELECT q.incremental_type, cr.name, q.interval_type_id, q.org_id
	  FROM cn_quotas_all q,
           cn_credit_types cr
	  WHERE q.quota_id = l_quota_id
	  AND cr.credit_type_id = q.credit_type_id
      AND cr.org_id = q.org_id;

     CURSOR other_inputs IS
	select input_sequence,
	  input_achieved_itd,
	  input_achieved_ptd
	  from cn_srp_period_quotas_ext_all
	  where srp_period_quota_id = (select srp_period_quota_id
				       from cn_srp_period_quotas_all
				       where srp_plan_assign_id = p_srp_plan_assign_id
				       and quota_id = p_quota_id
				       and salesrep_id = p_salesrep_id
				       and period_id = p_period_id)
	  order by input_sequence;

	 CURSOR periods_cr IS
	    SELECT spq.rowid,
		       spq.srp_period_quota_id,
	           Nvl(spq.commission_payed_ptd,0) commission_payed_ptd,
	           Nvl(spq.input_achieved_ptd,0) input_achieved_ptd,
	           Nvl(spq.output_achieved_ptd,0) output_achieved_ptd,
	           Nvl(spq.perf_achieved_ptd,0) perf_achieved_ptd,
	           Nvl(spq.advance_recovered_ptd,0) advance_recovered_ptd ,
	           Nvl(spq.advance_to_rec_ptd,0) advance_to_rec_ptd,
	           Nvl(spq.recovery_amount_ptd,0) recovery_amount_ptd,
	           Nvl(spq.comm_pend_ptd,0)comm_pend_ptd
	      FROM cn_srp_period_quotas_all spq
	     WHERE salesrep_id = p_salesrep_id
	       AND period_id > l_start_period_id
	       AND quota_id = p_quota_id
	       AND srp_plan_assign_id = p_srp_plan_assign_id
	       AND period_id <= l_end_period_id
	     ORDER BY spq.period_id ASC;

	 CURSOR periods_ext(p_srp_period_quota_id NUMBER) IS
	    SELECT nvl(input_achieved_ptd, 0) input_achieved_ptd,
	           nvl(input_achieved_itd, 0) input_achieved_itd,
	           input_sequence
	      FROM cn_srp_period_quotas_ext_all
	     WHERE srp_period_quota_id = p_srp_period_quota_id
	     ORDER BY input_sequence;

  BEGIN
	if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     'cn.plsql.cn_formula_common_pkg.calculate_init.begin',
	       		     'Beginning of calculate_init ...');
    end if;

     OPEN l_quota_csr (p_quota_id);
     FETCH l_quota_csr INTO l_incremental_flag, l_credit_type_name, l_interval_type_id, l_org_id;
     CLOSE l_quota_csr;

     l_start_period_id := get_start_period_id(p_quota_id, p_period_id);
	 l_end_period_id := get_end_period_id(p_quota_id, p_period_id);
	 cn_api.get_credit_info(l_credit_type_name, g_precision, g_ext_precision, l_org_id );

	 if (p_calc_type = 'BONUS' and p_period_id = l_end_period_id ) then
	 	update cn_srp_period_quotas_all
	 	set commission_payed_itd = 0, commission_payed_ptd = 0
	 	where salesrep_id = p_salesrep_id
	 	and quota_id = p_quota_id
	 	and period_id >= l_start_period_id
	 	and period_id < l_end_period_id
	 	and srp_plan_assign_id = p_srp_plan_assign_id;
     elsif (p_calc_type = 'COMMISSION' and p_period_id = l_start_period_id) then
        -- initialize the following values for the first period of an interval
        update cn_srp_period_quotas_all
        set perf_achieved_itd = perf_achieved_ptd,
			commission_payed_itd = commission_payed_ptd,
			input_achieved_itd = input_achieved_ptd,
			output_achieved_itd = output_achieved_ptd,
			advance_recovered_itd = advance_recovered_ptd,
			advance_to_rec_itd = advance_to_rec_ptd,
			recovery_amount_itd = recovery_amount_ptd,
			comm_pend_itd = comm_pend_ptd
	 	where salesrep_id = p_salesrep_id
	 	and quota_id = p_quota_id
	 	and period_id = l_start_period_id
	 	and srp_plan_assign_id = p_srp_plan_assign_id
		and (nvl(perf_achieved_ptd, 0) <> nvl(perf_achieved_itd, 0) or
		     nvl(commission_payed_ptd, 0) <> nvl(commission_payed_itd, 0) or
			 nvl(input_achieved_ptd, 0) <> nvl(input_achieved_itd, 0) or
			 nvl(output_achieved_ptd, 0) <> nvl(output_achieved_itd, 0) or
			 nvl(advance_recovered_ptd, 0) <> nvl(advance_recovered_itd, 0) or
			 nvl(advance_to_rec_ptd, 0) <> nvl(advance_to_rec_itd, 0) or
			 nvl(recovery_amount_ptd, 0) <> nvl(recovery_amount_itd, 0) or
			 nvl(comm_pend_ptd, 0) <> nvl(comm_pend_itd, 0))
	    return srp_period_quota_id,
	           perf_achieved_itd,
		       commission_payed_itd,
			   input_achieved_itd,
			   output_achieved_itd,
			   advance_recovered_itd,
			   advance_to_rec_itd,
			   recovery_amount_itd,
			   comm_pend_itd
		  into l_srp_period_quota_id,
	           l_perf_achieved_itd,
		       l_commission_payed_itd,
			   l_input_achieved_itd,
			   l_output_achieved_itd,
			   l_advance_recovered_itd,
			   l_advance_to_rec_itd,
			   l_recovery_amount_itd,
			   l_comm_pend_itd;

        if (SQL%found) then
          update cn_srp_period_quotas_ext_all
          set input_achieved_itd = input_achieved_ptd
          where srp_period_quota_id = l_srp_period_quota_id;

          for period_ext in periods_ext(l_srp_period_quota_id) loop
	        l_input_achieved_itd_tbl(period_ext.input_sequence) := period_ext.input_achieved_itd;
	      end loop;

          for period in periods_cr loop
            l_commission_payed_itd := l_commission_payed_itd + period.commission_payed_ptd;
	        l_input_achieved_itd := l_input_achieved_itd + period.input_achieved_ptd;
	        l_output_achieved_itd := l_output_achieved_itd + period.output_achieved_ptd;
	        l_perf_achieved_itd := l_perf_achieved_itd + period.perf_achieved_ptd;
	        l_advance_recovered_itd := l_advance_recovered_itd + period.advance_recovered_ptd;
	        l_advance_to_rec_itd := l_advance_to_rec_itd + period.advance_to_rec_ptd;
	        l_recovery_amount_itd :=l_recovery_amount_itd + period.recovery_amount_ptd ;
	        l_comm_pend_itd := l_comm_pend_itd + period.comm_pend_ptd;

            update cn_srp_period_quotas_all
	        set commission_payed_itd = l_commission_payed_itd,
	            input_achieved_itd = l_input_achieved_itd,
	            output_achieved_itd = l_output_achieved_itd,
	            perf_achieved_itd = l_perf_achieved_itd,
	            advance_recovered_itd = l_advance_recovered_itd,
	            advance_to_rec_itd = l_advance_to_rec_itd,
	            recovery_amount_itd = l_recovery_amount_itd,
	            comm_pend_itd = l_comm_pend_itd,
	            LAST_UPDATE_DATE = sysdate,
	            LAST_UPDATED_BY = fnd_global.user_id,
	            LAST_UPDATE_LOGIN = fnd_global.login_id
	        where rowid = period.rowid;

	        for period_ext in periods_ext(period.srp_period_quota_id) loop
	          l_input_achieved_itd_tbl(period_ext.input_sequence) :=
			       l_input_achieved_itd_tbl(period_ext.input_sequence) + period_ext.input_achieved_ptd;

	          update cn_srp_period_quotas_ext_all
	          set input_achieved_itd = l_input_achieved_itd_tbl(period_ext.input_sequence),
			      LAST_UPDATE_DATE = sysdate,
			      LAST_UPDATED_BY = fnd_global.user_id,
			      LAST_UPDATE_LOGIN = fnd_global.login_id
			  where srp_period_quota_id = period.srp_period_quota_id
			  and input_sequence = period_ext.input_sequence;
			end loop;

	      end loop;
        end if;
     end if;

     IF (p_rollover_flag = 'Y') THEN
	-- retrieve the current plan element's rollover target from the previous interval
	SELECT nvl(SUM(rollover), 0)
	  INTO l_same_pe_rollover
	  FROM cn_srp_period_quotas_all
	  WHERE srp_plan_assign_id = p_srp_plan_assign_id
	  AND quota_id = p_quota_id
	  AND period_id = (SELECT MAX(cal_period_id)
			   FROM cn_cal_per_int_types_all
			   WHERE interval_type_id = l_interval_type_id
			   AND cal_period_id < p_period_id
               AND org_id = l_org_id
			   AND interval_number <> (SELECT interval_number
						   FROM cn_cal_per_int_types_all
						   WHERE interval_type_id = l_interval_type_id
                           AND org_id = l_org_id
						   AND cal_period_id = p_period_id));

	-- retrieve source plan elements' rollover targets and compute the total amount
	SELECT SUM(nvl(cspq.rollover, 0) * csrq.rollover / 100)
	  INTO l_source_pe_rollover
	  FROM cn_srp_rollover_quotas_all csrq,
           cn_srp_period_quotas_all cspq
	  WHERE csrq.quota_id = p_quota_id
	  AND csrq.srp_quota_assign_id = (SELECT srp_quota_assign_id
					  FROM cn_srp_quota_assigns_all
					  WHERE srp_plan_assign_id = p_srp_plan_assign_id
					  AND quota_id = p_quota_id)
	  AND cspq.salesrep_id = p_salesrep_id
	  AND cspq.quota_id = csrq.source_quota_id
	  AND cspq.period_id = (SELECT MAX(period_id)
				FROM cn_srp_period_quotas_all
				WHERE salesrep_id = p_salesrep_id
				AND quota_id = csrq.source_quota_id
				AND srp_quota_assign_id = cspq.srp_quota_assign_id)
	  AND cspq.period_id < p_period_id
	  AND NOT exists (SELECT 1
			  FROM cn_cal_per_int_types_all ccpit,
                   cn_srp_period_quotas_all cspq2
			  WHERE ccpit.org_id = l_org_id
                AND ccpit.cal_period_id > (SELECT MAX(period_id)
						       FROM cn_srp_period_quotas_all
						       WHERE salesrep_id = p_salesrep_id
						       AND quota_id = csrq.source_quota_id
						       AND srp_quota_assign_id = cspq.srp_quota_assign_id)
			  AND ccpit.cal_period_id < p_period_id
			  AND cspq2.srp_plan_assign_id = p_srp_plan_assign_id
			  AND cspq2.quota_id = p_quota_id
			  AND cspq2.period_id = ccpit.cal_period_id
			  AND ccpit.interval_type_id = l_interval_type_id
			  AND ccpit.interval_number <> (SELECT interval_number
							FROM cn_cal_per_int_types_all
							WHERE interval_type_id = l_interval_type_id
							AND cal_period_id = p_period_id
                            AND org_id = l_org_id))
			  ;

	UPDATE cn_srp_period_quotas_all
	  SET total_rollover = l_same_pe_rollover + nvl(l_source_pe_rollover, 0)
	  WHERE srp_plan_assign_id = p_srp_plan_assign_id
	  AND quota_id = p_quota_id
	  AND period_id = p_period_id;

     END IF;

     IF (p_itd_flag = 'Y' AND p_calc_type <> 'FORECAST') THEN
	delete_itd_trx( p_salesrep_id, p_srp_plan_assign_id,
			p_quota_id, p_period_id              );
     END IF;

     /******************************************************************************
     IF allowing no prior adjustment, plan element with individual and accumulative
       setting can be calculated incrementally.
       ******************************************************************************/
     IF (nvl(cn_system_parameters.value('CN_PRIOR_ADJUSTMENT', l_org_id), 'N') = 'N' ) THEN
	l_incremental_flag := 'Y';
	cn_message_pkg.debug('Profile CN_PRIOR_ADJUSTMENT has value: No ');
     END IF;

     /******************************************************************************
     1). when process_all_flag = 'Y', do non incremental calc.
     2). when process_all_flag = 'N' , then
       a). if l_incremental_flag = 'Y', do incremental calc
       b). else incremental_flag = 'N', do non incremental_calc
       for non incremental calc. pick POP, CALC, XCALC
      	For incremental calculation, only pick trx in 'POP' status
       ******************************************************************************/

     IF p_process_all_flag = 'Y' OR
       (p_process_all_flag = 'N' AND l_incremental_flag = 'N' ) THEN
	x_select_status_flag := 'PCX';
      ELSE
	x_select_status_flag := 'P';
     END IF;

     cn_message_pkg.debug('Parameters that control the calculation initialization');
     cn_message_pkg.debug('--p_process_all_flag: ' || p_process_all_flag);
	 cn_message_pkg.debug('--l_incremental_flag: ' || l_incremental_flag);
	 cn_message_pkg.debug('--p_select_status_flag: ' || x_select_status_flag);
	 cn_message_pkg.debug('--p_trx_group_code: ' || p_trx_group_code);

     -- initialize ptd value to be 0,  ptd = 0;
     x_input_achieved_ptd(1)  := 0;
     x_output_achieved_ptd    := 0;
     x_perf_achieved_ptd      := 0;
     x_commission_payed_ptd   := 0;

     -- initialize itd value to itd minus ptd, itd = itd -ptd
     IF (p_period_id = l_start_period_id) THEN
	x_input_achieved_itd(1) := 0;
	x_output_achieved_itd := 0;
	x_perf_achieved_itd := 0;
	x_commission_payed_itd := 0;
      ELSE
	SELECT Nvl(quota.input_achieved_itd, 0) - Nvl(quota.input_achieved_ptd, 0),
	  Nvl(quota.output_achieved_itd, 0) - Nvl(quota.output_achieved_ptd, 0),
	  Nvl(quota.perf_achieved_itd, 0) - Nvl(quota.perf_achieved_ptd, 0),
	  Nvl(quota.commission_payed_itd, 0) - Nvl(quota.commission_payed_ptd, 0)
	  INTO x_input_achieved_itd(1), x_output_achieved_itd,
	  x_perf_achieved_itd, x_commission_payed_itd
	  FROM cn_srp_period_quotas_all quota
	  WHERE quota.srp_plan_assign_id = p_srp_plan_assign_id
	  AND quota.quota_id = p_quota_id
	  AND quota.salesrep_id = p_salesrep_id
	  AND quota.period_id = p_period_id;
     END IF;

     FOR other_input IN other_inputs LOOP
	x_input_achieved_ptd(other_input.input_sequence) := 0;
	IF (p_period_id = l_start_period_id) THEN
	   x_input_achieved_itd(other_input.input_sequence) := 0;
	 ELSE
	   x_input_achieved_itd(other_input.input_sequence) := nvl(other_input.input_achieved_itd, 0) - nvl(other_input.input_achieved_ptd, 0);
	END IF;
     END LOOP;

     IF p_calc_type = 'COMMISSION' THEN
	IF p_process_all_flag = 'Y' THEN
	   IF p_intel_calc_flag = 'N' THEN
	      -- need to sum the trx before p_start_date to get ptd
	      IF p_trx_group_code = 'INDIVIDUAL' THEN
		 SELECT
		   SUM(line.input_achieved), SUM(line.output_achieved),
		   SUM(line.perf_achieved), SUM(line.commission_amount)
		   INTO l_input_achieved, l_output_achieved,
		   l_perf_achieved, l_commission_achieved
		   FROM cn_commission_lines_all line
		   WHERE line.credited_salesrep_id = p_salesrep_id
		   AND line.quota_id = p_quota_id
		   AND line.srp_plan_assign_id = p_srp_plan_assign_id
		   AND line.status = 'CALC'
		   AND line.processed_date < p_start_date
		   AND line.processed_period_id = p_period_id
		   AND ((g_calc_type ='FORECAST' AND line.trx_type = 'FORECAST')
			OR (g_calc_type ='BONUS' AND line.trx_type = 'BONUS')
			OR (g_calc_type = 'COMMISSION'
			    AND line.trx_type NOT IN ('BONUS','FORECAST', 'GRP') ));

		 x_commission_payed_ptd := Nvl(l_commission_achieved,0);
		 x_input_achieved_ptd(1) := Nvl(l_input_achieved, 0);
		 x_output_achieved_ptd  := Nvl(l_output_achieved, 0);
		 x_perf_achieved_ptd    := Nvl(l_perf_achieved, 0);

		 IF (p_period_id = l_start_period_id) THEN
		    x_commission_payed_itd := x_commission_payed_ptd;
		    x_input_achieved_itd(1) := x_input_achieved_ptd(1);
		    x_output_achieved_itd := x_output_achieved_ptd;
		    x_perf_achieved_itd := x_perf_achieved_ptd;
		  ELSE
		    x_commission_payed_itd := x_commission_payed_itd + x_commission_payed_ptd;
		    x_input_achieved_itd(1)   := x_input_achieved_itd(1)   + x_input_achieved_ptd(1);
		    x_output_achieved_itd  := x_output_achieved_itd  + x_output_achieved_ptd;
		    x_perf_achieved_itd    := x_perf_achieved_itd    + x_perf_achieved_ptd ;
		 END IF;
	      END IF;
	      -- else 'group by', itd = itd-ptd, ptd initialized to 0
	   END IF;
	      -- ELSIF p_process_all_flag = 'Y' AND p_intel_calc_flag = 'Y' THEN
	      ---  non incremental calc     itd = itd -ptd , ptd initialized to 0;

	 ELSIF p_process_all_flag = 'N' THEN  -- must be intel calc
	   -- case1 : IF l_incremental_flag = 'N', need to recalc every trx
	   --         non incremental calc THEN itd = itd -ptd, ptd intialized to 0

	   -- case2 : IF l_incremental_flag = 'Y' and trx_group_code = 'GROUP'
	   --              itd = itd -ptd, ptd initialized to 0
	   --         because group by plan element always do a bulk group function
	   --              when it reaches the end of interval.

	   -- case3 : IF l_incremental_flag = 'Y' and trx_group_code = 'INDIVIDUAL'
	   --              itd = itd, ptd = ptd
	   IF l_incremental_flag = 'Y' AND p_trx_group_code = 'INDIVIDUAL' THEN
	      cn_message_pkg.debug('p_trx_group_code: ' || p_trx_group_code );

	      SELECT nvl(quota.input_achieved_itd,0), Nvl( quota.input_achieved_ptd, 0),
		nvl(quota.output_achieved_itd,0), Nvl(quota.output_achieved_ptd, 0),
		nvl(quota.perf_achieved_itd, 0), Nvl(quota.perf_achieved_ptd, 0),
		nvl(quota.commission_payed_itd ,0), Nvl(quota.commission_payed_ptd, 0)
		INTO x_input_achieved_itd(1), x_input_achieved_ptd(1),
		x_output_achieved_itd, x_output_achieved_ptd,
		x_perf_achieved_itd, x_perf_achieved_ptd,
		x_commission_payed_itd, x_commission_payed_ptd
		FROM cn_srp_period_quotas_all quota
		WHERE quota.srp_plan_assign_id = p_srp_plan_assign_id
		AND quota.quota_id 	= P_quota_id
		AND quota.salesrep_id 	= P_salesrep_id
		AND quota.period_id 	= P_period_id;

	      IF (p_period_id = l_start_period_id) THEN
		 x_input_achieved_itd(1) := x_input_achieved_ptd(1);
		 x_output_achieved_itd := x_output_achieved_ptd;
		 x_perf_achieved_itd := x_perf_achieved_ptd;
		 x_commission_payed_itd := x_commission_payed_ptd;
	      END IF;

	      FOR other_input IN other_inputs LOOP
		 x_input_achieved_ptd(other_input.input_sequence) := nvl(other_input.input_achieved_ptd, 0);
		 IF (p_period_id = l_start_period_id) THEN
		    x_input_achieved_itd(other_input.input_sequence) := x_input_achieved_ptd(other_input.input_sequence);
		  ELSE
		    x_input_achieved_itd(other_input.input_sequence) := nvl(other_input.input_achieved_itd, 0);
		 END IF;
	      END LOOP;

	   END IF;
	END IF;  -- end of p_process_all_flag check

    cn_message_pkg.debug('Initialized values');
	FOR i IN 1..x_input_achieved_itd.COUNT LOOP
	   cn_message_pkg.debug('--x_input_achieved_itd: ' || x_input_achieved_itd(i));
	END LOOP;

	cn_message_pkg.debug('--x_output_achieved_itd: ' || x_output_achieved_itd);
	cn_message_pkg.debug('--x_perf_achieved_itd: ' || x_perf_achieved_itd);
	cn_message_pkg.debug('--x_commission_payed_itd: ' || x_commission_payed_itd );

	FOR i IN 1..x_input_achieved_ptd.COUNT LOOP
	   cn_message_pkg.debug('--x_input_achieved_ptd: ' || x_input_achieved_ptd(i));
	END LOOP;
	cn_message_pkg.debug('--x_output_achieved_ptd: ' || x_output_achieved_ptd);
	cn_message_pkg.debug('--x_perf_achieved_ptd: ' || x_perf_achieved_ptd);
	cn_message_pkg.debug('--x_commission_payed_ptd: ' || x_commission_payed_ptd );

      ELSIF p_calc_type = 'BONUS' THEN
	-- do nothing since we already initialize ptd =0 and itd  = itd - ptd
	-- because bonus type formula are guaranteed to be NON-cumulative, INDIVIDUAL, NON-itd
	NULL;
     END IF;

	if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     'cn.plsql.cn_formula_common_pkg.calculate_init.end',
	       		     'End of calculate_init');
    end if;

  END calculate_init;



     FUNCTION get_last_period_id ( p_quota_id  NUMBER, p_period_id NUMBER,p_srp_plan_assign_id NUMBER )
      RETURN NUMBER  IS
          l_end_period_id NUMBER(15);
    BEGIN
      select max(PERIOD_ID)
       INTO l_end_period_id
      from cn_srp_period_quotas_all
      where QUOTA_ID=p_quota_id
      and srp_plan_assign_id=p_srp_plan_assign_id;

       RETURN l_end_period_id;
    EXCEPTION
      WHEN OTHERS THEN

  	if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       'cn.plsql.cn_formula_common_pkg.get_end_period_id.exception',
  	       		     sqlerrm);
      end if;

  	RETURN NULL ;
    END get_last_period_id;

   FUNCTION EndOfGroupByInterval( p_quota_id  NUMBER, p_period_id NUMBER,p_srp_plan_assign_id NUMBER )
   RETURN BOOLEAN IS
      l_end_period_id NUMBER(15);
      l_last_period_id NUMBER(15);
    BEGIN
       l_end_period_id := get_end_period_id(p_quota_id, p_period_id);


       IF p_period_id = l_end_period_id THEN
        RETURN TRUE;
       ELSE
         l_last_period_id := get_last_period_id(p_quota_id, p_period_id,p_srp_plan_assign_id);

          IF p_period_id = l_last_period_id THEN
              RETURN TRUE;
          ELSE
              RETURN FALSE;
          END IF;

       END IF;

    EXCEPTION
      WHEN OTHERS THEN
  	RETURN FALSE ;
    END EndOfGroupByInterval;







  FUNCTION EndOfInterval (p_quota_id  NUMBER, p_period_id NUMBER)
    RETURN BOOLEAN IS
       l_end_period_id NUMBER(15);
  BEGIN
     l_end_period_id := get_end_period_id(p_quota_id, p_period_id);

     IF p_period_id = l_end_period_id THEN
	RETURN TRUE;
      ELSE
	RETURN FALSE;
     END IF;
  EXCEPTION
    WHEN OTHERS THEN
	RETURN FALSE ;
  END EndOfInterval;

  --   get the start_period_id for the interval
  FUNCTION get_start_period_id ( p_quota_id  NUMBER, p_period_id NUMBER )
    RETURN NUMBER  IS
       l_start_period_id NUMBER(15);
  BEGIN
     SELECT MIN(p2.cal_period_id)
       INTO l_start_period_id
       FROM cn_cal_per_int_types_all p2
      WHERE (p2.interval_type_id, p2.org_id, p2.interval_number) IN
            (SELECT p1.interval_type_id, p1.org_id, p1.interval_number
               FROM cn_cal_per_int_types_all p1,
                    cn_quotas_all q
              WHERE p1.cal_period_id = p_period_id
                AND q.quota_id = p_quota_id
                AND p1.org_id = q.org_id
                AND p1.interval_type_id = q.interval_type_id);

     RETURN l_start_period_id;
  EXCEPTION
    WHEN OTHERS THEN
	RETURN NULL ;
  END get_start_period_id;

  --   get the end_period_id for the interval
  FUNCTION get_end_period_id ( p_quota_id  NUMBER, p_period_id NUMBER )
    RETURN NUMBER  IS
        l_end_period_id NUMBER(15);
  BEGIN
     SELECT MAX(p2.cal_period_id)
       INTO l_end_period_id
       FROM cn_cal_per_int_types_all p2
       WHERE (p2.interval_type_id, p2.org_id, p2.interval_number) IN
             (SELECT p1.interval_type_id, p1.org_id, p1.interval_number
                FROM cn_cal_per_int_types_all p1,
				     cn_quotas_all q
               WHERE p1.cal_period_id = p_period_id
                 AND q.quota_id = p_quota_id
                 AND p1.org_id = q.org_id
                 AND p1.interval_type_id = q.interval_type_id);

     RETURN l_end_period_id;
  EXCEPTION
    WHEN OTHERS THEN

	if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                     'cn.plsql.cn_formula_common_pkg.get_end_period_id.exception',
	       		     sqlerrm);
    end if;

	RETURN NULL ;
  END get_end_period_id;

  FUNCTION get_quarter_start_period_id(p_quota_id NUMBER, p_period_id NUMBER) RETURN NUMBER IS
     l_start_period_id NUMBER(15);
  BEGIN
     select min(a.cal_period_id)
       INTO l_start_period_id
       from cn_cal_per_int_types_all a,
            cn_period_statuses_all b
      where (a.interval_type_id, a.org_id) = (select interval_type_id, org_id
                                                from cn_quotas_all
                                               where quota_id = p_quota_id)
        and a.interval_number = (select interval_number
                                   from cn_cal_per_int_types_all
	      			              where cal_period_id = p_period_id
				                    and (interval_type_id, org_id) = (select interval_type_id, org_id
                                                                        from cn_quotas_all
                                                                       where quota_id = p_quota_id))
        and a.cal_period_id = b.period_id
        and b.quarter_num = (select quarter_num
                              from cn_period_statuses_all
                             where period_id = p_period_id
                               and org_id = (select org_id from cn_quotas_all where quota_id = p_quota_id));

     RETURN l_start_period_id;
  END get_quarter_start_period_id;

  FUNCTION get_quarter_end_period_id(p_quota_id NUMBER, p_period_id NUMBER) RETURN NUMBER IS
     l_end_period_id NUMBER(15);
  BEGIN
     select max(a.cal_period_id)
       INTO l_end_period_id
       from cn_cal_per_int_types_all a,
            cn_period_statuses_all b
      where (a.interval_type_id, a.org_id) = (select interval_type_id, org_id
                                                from cn_quotas_all
                                               where quota_id = p_quota_id)
        and a.interval_number = (select interval_number from cn_cal_per_int_types_all
	      			              where cal_period_id = p_period_id
				                    and (interval_type_id, org_id) = (select interval_type_id, org_id
                                                                        from cn_quotas_all
                                                                       where quota_id = p_quota_id))
        and a.cal_period_id = b.period_id
        and b.quarter_num = (select quarter_num
                               from cn_period_statuses_all
                              where period_id = p_period_id
                                and org_id = (select org_id from cn_quotas_all where quota_id = p_quota_id));

     RETURN l_end_period_id;
  END get_quarter_end_period_id;


  --  To update cn_srp_period_quotas, cn_srp_per_quota_rc, cn_srp_periods after the calculation of a quota is done
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
				p_rollover              NUMBER) IS

     l_srp_pe_subledger cn_calc_subledger_pvt.srp_pe_subledger_rec_type;
     l_return_status VARCHAR2(1);
     l_msg_count     NUMBER;
     l_msg_data      VARCHAR2(2000);
     l_api_version   NUMBER := 1.0;
     l_counter       NUMBER;
  BEGIN
     l_srp_pe_subledger.salesrep_id := p_salesrep_id;
     l_srp_pe_subledger.quota_id := p_quota_id;
     l_srp_pe_subledger.accu_period_id := p_period_id;
     l_srp_pe_subledger.srp_plan_assign_id := p_srp_plan_assign_id;
     l_srp_pe_subledger.input_ptd :=  p_input_achieved_ptd;
     l_srp_pe_subledger.input_itd := p_input_achieved_itd;
     l_srp_pe_subledger.output_ptd := Nvl(p_output_achieved_ptd, 0);
     l_srp_pe_subledger.output_itd := Nvl(p_output_achieved_itd, 0);
     l_srp_pe_subledger.perf_ptd := Nvl(p_perf_achieved_ptd, 0);
     l_srp_pe_subledger.perf_itd := Nvl(p_perf_achieved_itd, 0);
     IF (p_rollover > 0) THEN
	l_srp_pe_subledger.rollover := p_rollover;
      ELSE
	l_srp_pe_subledger.rollover := 0;
     END IF;


     l_srp_pe_subledger.calc_type := p_calc_type;

     cn_calc_subledger_pvt.update_srp_pe_subledger
                                     ( p_api_version => l_api_version,
				       p_init_msg_list => fnd_api.g_true,
				       x_return_status => l_return_status,
				       x_msg_count => l_msg_count,
				       x_msg_data => l_msg_data,
				       p_srp_pe_subledger => l_srp_pe_subledger);


     FOR l_counter IN 1..l_msg_count LOOP
	cn_message_pkg.debug( substr(FND_MSG_PUB.get(p_msg_index => l_counter,
					      p_encoded   => FND_API.G_FALSE), 1, 249 ));
     END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       'cn.plsql.cn_formula_common_pkg.calculate_roll.exception',
		       		   sqlerrm);
      end if;

      cn_message_pkg.debug('Exception occurs in calculate_roll ');
      cn_message_pkg.debug(sqlerrm);
      RAISE;
  END calculate_roll;

  --   Work as a dispatcher to invoke the corresponding cn_formula_id_pkg.calculate_quota
  PROCEDURE  calculate_quota(   p_srp_plan_assign_id   NUMBER,
				p_salesrep_id          NUMBER,
				p_period_id 	       NUMBER,
				p_start_date           DATE ,
		        p_quota_id	       NUMBER,
				p_process_all_flag     VARCHAR2,
				p_intel_calc_flag      VARCHAR2 ,
				p_calc_type            VARCHAR2 ,
				p_latest_processed_date OUT NOCOPY DATE  ) IS
    l_latest_processed_date	DATE ;
    l_quota_type		VARCHAR2(30);
    l_formula_id		NUMBER(15);
    l_formula_name		VARCHAR2(30);
    l_pe_name           VARCHAR2(80);
    l_formula_type              VARCHAR2(30);
    l_role_id                   NUMBER;
    l_credit_type_id            NUMBER;
    l_bonus_credit_type_id      NUMBER;
    l_org_id                    NUMBER;
    l_statement		            VARCHAR2(1000);
    l_debug_flag                VARCHAR2(1) := fnd_profile.value('CN_DEBUG');
  BEGIN
	if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     'cn.plsql.cn_formula_common_pkg.calculate_quota.begin',
	      		     'Begin of Calculate_Quota:'||' p_srp_plan_assign_id ' || p_srp_plan_assign_id ||
			                                      ' p_salesrep_id ' || 	p_salesrep_id ||
												  ' p_period_id ' || 	p_period_id ||
												  ' p_start_date ' ||  p_start_date ||
												  ' p_quota_id ' || p_quota_id ||
												  ' p_intel_calc_flag ' || p_intel_calc_flag ||
												  ' p_calc_type ' || p_calc_type);
    end if;

     SELECT q.quota_type_code,
            q.calc_formula_id,
            q.credit_type_id,
            q.bonus_credit_type_id,
            nvl(f.name, q.package_name),
            nvl(f.formula_type, decode(g_calc_type, 'COMMISSION', 'C', 'B')),
            q.org_id,
            q.name
       INTO l_quota_type,
            l_formula_id,
            l_credit_type_id,
            l_bonus_credit_type_id,
            l_formula_name,
            l_formula_type,
            l_org_id,
            l_pe_name
       FROM cn_quotas_all q,
            cn_calc_formulas_all f
      WHERE q.quota_id = p_quota_id
        AND q.calc_formula_id = f.calc_formula_id(+)
        AND q.org_id = f.org_id(+);

    if (l_debug_flag = 'Y') then
      select name into l_statement from cn_salesreps where salesrep_id = p_salesrep_id and org_id = l_org_id;
      cn_message_pkg.debug('Resource: '||l_statement);
      cn_message_pkg.debug('Plan element: '||l_pe_name);
      cn_message_pkg.debug('Formula: '||l_formula_name);
      cn_message_pkg.debug('Calculation parameters:');
      cn_message_pkg.debug('--p_srp_plan_assign_id: ' || p_srp_plan_assign_id);
      cn_message_pkg.debug('--p_salesrep_id: ' || 	p_salesrep_id);
      cn_message_pkg.debug('--p_period_id: ' || 	p_period_id);
      cn_message_pkg.debug('--p_start_date: ' ||  p_start_date);
      cn_message_pkg.debug('--p_quota_id: ' || p_quota_id);
      cn_message_pkg.debug('--p_intel_calc_flag: ' || p_intel_calc_flag);
      cn_message_pkg.debug('--p_calc_type: ' || p_calc_type);
    end if;

     IF l_quota_type = 'FORMULA' THEN
	l_statement := 'begin cn_formula_' || abs(l_formula_id) || '_' || abs(l_org_id) || '_pkg';
      ELSIF l_quota_type = 'EXTERNAL' THEN
	 l_statement := 'begin ' ||  l_formula_name;
      END IF;

      l_statement := l_statement || '.calculate_quota(:srp_plan_assign_id, :salesrep_id,'||
	':period_id, :start_date, :quota_id, :process_all_flag, ' ||
	':intel_calc_flag, :calc_type, :credit_type_id, ';

      IF l_formula_type = 'C' THEN
	 l_statement := l_statement || ':latest_processed_date ); end ;' ;
	ELSIF l_formula_type = 'B' THEN
	 l_statement :=  l_statement || ':role_id, :latest_processed_date ); end ;' ;
      END IF;
     IF l_formula_type = 'C' THEN
	execute immediate l_statement using p_srp_plan_assign_id, p_salesrep_id, p_period_id,
	  p_start_date, p_quota_id, p_process_all_flag, p_intel_calc_flag, p_calc_type, l_credit_type_id,
	  IN OUT p_latest_processed_date;

      ELSIF l_formula_type = 'B' THEN
	SELECT role.role_id INTO l_role_id
	  FROM cn_srp_plan_assigns_all  spa,
	  cn_srp_roles  role
	  WHERE spa.srp_plan_assign_id = p_srp_plan_assign_id
	  AND role.srp_role_id = spa.srp_role_id
	  AND role.org_id = spa.org_id;

	execute immediate l_statement using p_srp_plan_assign_id, p_salesrep_id, p_period_id,
	  p_start_date, p_quota_id, p_process_all_flag, p_intel_calc_flag, p_calc_type,
	  l_credit_type_id, l_role_id, IN OUT p_latest_processed_date ;
     END IF;

	if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     'cn.plsql.cn_formula_common_pkg.calculate_quota.end',
	      		     'End of Calculate_Quota.');
    end if;
	cn_message_pkg.debug('Finish caculating plan element: '||l_pe_name);
	cn_message_pkg.debug(' ');
  EXCEPTION
    WHEN OTHERS THEN
		if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                         'cn.plsql.cn_formula_common_pkg.calculate_quota.exception',
		       		     sqlerrm);
        end if;
        cn_message_pkg.debug('Excpetion occurs in calculate_quota dispatcher: ');
		cn_message_pkg.debug(sqlerrm);
        RAISE;
  END calculate_quota;


  PROCEDURE update_consistency_flag(    x_calc_batch_id NUMBER ) IS
  BEGIN
     UPDATE  cn_srp_periods_all
       SET  consistency_flag = 'Y'
     WHERE  (salesrep_id, period_id, org_id) IN
             (  SELECT  batch.salesrep_id, batch.period_id, batch.org_id
      	  	  FROM  cn_process_batches_all batch
      		 WHERE  batch.physical_batch_id = x_calc_batch_id);
  END update_consistency_flag;


  PROCEDURE swap_dates ( p_curr_date  IN OUT NOCOPY DATE , p_next_date DATE) IS
  BEGIN
     IF Nvl(p_next_date, p_curr_date) > p_curr_date THEN
	p_curr_date := p_next_date;
     END IF;
  END  swap_dates;

PROCEDURE calculate_batch(p_physical_batch_id NUMBER) IS
  l_process_all_flag        varchar2(30);
  l_salesrep_option         VARCHAR2(30);
  l_current_processed_date  date;
  l_next_processed_date	    date;
  l_calc_sub_batch_rec      cn_calc_sub_batches_pkg.calc_sub_batch_rec_type;
  l_srp_subledger           cn_calc_subledger_pvt.srp_subledger_rec_type;
  l_msg_data                varchar2(3000);
  l_return_status           VARCHAR2(30);
  l_msg_count               number(15);
  l_counter                 NUMBER;
  l_interval_type_id        VARCHAR2(30);
  l_calc_sub_batch_id       NUMBER(15);
  l_quota_sequence          pls_integer;
  l_org_id                  NUMBER;

  -- select all complete comp plan
  CURSOR l_srp_plan_periods_csr IS
    SELECT spa.salesrep_id,
           spa.srp_plan_assign_id,
           prd.period_id,
           prd.process_all_flag,
           decode(prd.period_id, batch.period_id, batch.start_date, prd.start_date) start_date
      FROM cn_process_batches_all batch,
           cn_srp_plan_assigns_all spa,
           cn_srp_intel_periods_all prd
     WHERE batch.physical_batch_id = p_physical_batch_id
       AND prd.salesrep_id = batch.salesrep_id
	   AND prd.period_id BETWEEN batch.period_id AND batch.end_period_id
       AND prd.org_id = batch.org_id
	   AND spa.salesrep_id = batch.salesrep_id
       AND spa.org_id = batch.org_id
       AND spa.start_date <= prd.end_date
       AND nvl(spa.end_date, prd.end_date) >= prd.start_date
	 ORDER BY spa.salesrep_id, prd.period_id, spa.srp_plan_assign_id;

  CURSOR l_srp_quotas_csr(l_srp_plan_assign_id NUMBER,
			              l_salesrep_id NUMBER,
			              l_period_id NUMBER) IS
    SELECT spq.quota_id,
	       qa.quota_sequence
      FROM cn_srp_period_quotas_all spq,
           cn_quota_assigns_all qa,
           cn_quotas_all q
     WHERE spq.srp_plan_assign_id = l_srp_plan_assign_id
       AND spq.salesrep_id = l_salesrep_id
       AND spq.period_id = l_period_id
       and qa.comp_plan_id = (select comp_plan_id
	                            from cn_srp_plan_assigns_all
                               where srp_plan_assign_id = l_srp_plan_assign_id)
       and qa.quota_id = spq.quota_id
       and q.quota_id = spq.quota_id
       and q.incentive_type_code = 'COMMISSION'
     order by spq.srp_plan_assign_id, qa.quota_sequence;

  CURSOR l_check_calc_entry_csr (l_salesrep_id NUMBER, l_period_id NUMBER ) IS
    SELECT 1
      FROM cn_notify_log_all
     WHERE (salesrep_id = l_salesrep_id OR salesrep_id = -1000)
	   AND period_id = l_period_id
       AND revert_state = 'CALC'
	   AND status = 'INCOMPLETE'
	   AND quota_id IS NULL
       AND org_id = l_org_id;

  -- select those commission, not calculate_for_last type which has an entry
  -- in notify log. If salesrep_option is 'reps_in_notify_log', then we can do
  -- only these plan elements to improve the performance.
  CURSOR l_notify_log_csr (l_salesrep_id NUMBER,
		                   l_period_id NUMBER,
                           l_quota_id number ) IS
    SELECT 1
	  FROM cn_notify_log_all nlog
	 WHERE nlog.salesrep_id = l_salesrep_id
	   AND nlog.period_id = l_period_id
	   AND nlog.status = 'INCOMPLETE'
	   AND nlog.quota_id = l_quota_id
	   AND nlog.revert_state IN ('CALC', 'POP');

  CURSOR l_bonus_pe_csr IS
	SELECT inlv.srp_plan_assign_id, inlv.salesrep_id,
	       inlv.end_period_id, inlv.end_date, inlv.quota_id, inlv.interval_type_id
    FROM (
	SELECT spa.srp_plan_assign_id srp_plan_assign_id, batch.salesrep_id salesrep_id, qa.quota_sequence quota_sequence,
	       batch.end_period_id end_period_id, batch.end_date end_date, pe.quota_id quota_id, pe.interval_type_id interval_type_id
	  FROM cn_srp_plan_assigns_all spa,
	       cn_quota_assigns_all qa,
	       cn_quotas_all pe,
	       cn_process_batches_all batch
	 WHERE batch.physical_batch_id = p_physical_batch_id
	   AND batch.salesrep_id = spa.salesrep_id
       AND spa.org_id = batch.org_id
	   -- find comp plans active on  batch.end_date
	   AND ((spa.end_date IS NOT NULL AND batch.end_date BETWEEN spa.start_date AND spa.end_date)
	        OR (spa.end_date IS NULL AND batch.end_date >= spa.start_date))
	   --  find bonus type plan element
	   AND qa.comp_plan_id = spa.comp_plan_id
       AND qa.quota_id = pe.quota_id
	   AND pe.incentive_type_code = 'BONUS'
       AND ((l_interval_type_id    = -1000 AND pe.interval_type_id = -1000)
	        OR (l_interval_type_id = -1001 AND pe.interval_type_id = -1001)
	        OR (l_interval_type_id = -1002 AND pe.interval_type_id = -1002)
	        OR (l_interval_type_id = -1003 AND pe.interval_type_id IN (-1000, -1001, -1002)))
           -- plan element is effective on batch.end_date
	   AND ((pe.end_date IS NOT NULL AND batch.end_date BETWEEN pe.start_date AND pe.end_date)
		     OR (pe.end_date IS NULL AND batch.end_date >= pe.start_date))
	   -- check if in cn_calc_sub_quotas if that exists
       AND (l_calc_sub_batch_id = -1000	OR pe.quota_id IN (SELECT csq.quota_id
			                                             FROM cn_calc_sub_quotas csq
			                                            WHERE csq.calc_sub_batch_id = l_calc_sub_batch_id))
    UNION
	SELECT spa.srp_plan_assign_id srp_plan_assign_id, batch.salesrep_id salesrep_id, qa.quota_sequence quota_sequence,
	       batch.end_period_id end_period_id, batch.end_date end_date, pe.quota_id quota_id, pe.interval_type_id interval_type_id
	  FROM cn_srp_plan_assigns_all spa,
	       cn_quota_assigns_all qa,
	       cn_quotas_all pe,
	       cn_process_batches_all batch
	 WHERE batch.physical_batch_id = p_physical_batch_id
	   AND batch.salesrep_id = spa.salesrep_id
       AND spa.org_id = batch.org_id
	   -- find comp plans active between batch start and end date
       AND spa.end_date >= batch.start_date
       AND spa.end_date < batch.end_date
	   --  find bonus type plan element
	   AND qa.comp_plan_id = spa.comp_plan_id
       AND qa.quota_id = pe.quota_id
	   AND pe.incentive_type_code = 'BONUS'
       AND pe.salesreps_enddated_flag = 'Y'
       AND ((l_interval_type_id    = -1000 AND pe.interval_type_id = -1000)
	        OR (l_interval_type_id = -1001 AND pe.interval_type_id = -1001)
	        OR (l_interval_type_id = -1002 AND pe.interval_type_id = -1002)
	        OR (l_interval_type_id = -1003 AND pe.interval_type_id IN (-1000, -1001, -1002)))
           -- plan element is effective on comp_plan.end_date
	   AND ( (pe.end_date IS NOT NULL AND spa.end_date BETWEEN pe.start_date AND pe.end_date)
                   OR (spa.end_date >= pe.start_date AND pe.end_date IS NULL))
	   -- check if in cn_calc_sub_quotas if that exists
       AND (l_calc_sub_batch_id = -1000	OR pe.quota_id IN (SELECT csq.quota_id
			                                             FROM cn_calc_sub_quotas csq
			                                            WHERE csq.calc_sub_batch_id = l_calc_sub_batch_id))) inlv
	 ORDER BY inlv.salesrep_id, inlv.end_date, inlv.quota_sequence;


BEGIN
  if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'cn.plsql.cn_formula_common_pkg.calculate_batch.begin',
       		       'Beginning of calculate_batch ...');
  end if;

  select org_id into l_org_id
    from cn_process_batches_all
   where physical_batch_id = p_physical_batch_id and rownum = 1;

  -- for maintaining cn_repositories.latest_processed_date
  SELECT nvl(latest_processed_date, to_date('01/01/1900', 'DD/MM/YYYY'))
    INTO l_current_processed_date
    FROM cn_repositories_all
   WHERE org_id = l_org_id;

  g_refresh_flag := 'Y';

  -- populate uplift factors (payment_factor, quota_factor, event_factor) and payee_assigned first
  populate_factors(p_physical_batch_id);
  commit;

  cn_calc_sub_batches_pkg.get_calc_sub_batch( p_physical_batch_id, l_calc_sub_batch_rec);

  g_intel_calc_flag := l_calc_sub_batch_rec.intelligent_flag;
  l_salesrep_option := l_calc_sub_batch_rec.salesrep_option;
  g_calc_type  := l_calc_sub_batch_rec.calc_type;
  l_calc_sub_batch_id := l_calc_sub_batch_rec.calc_sub_batch_id;
  l_interval_type_id := l_calc_sub_batch_rec.interval_type_id;

  IF (g_calc_type = 'COMMISSION') THEN
    UPDATE cn_commission_lines_all line
       SET line.status = 'XCALC',
           line.error_reason = 'skip calc with null commission_amount',
           last_update_date = sysdate,
           last_updated_by = g_last_updated_by,
           last_update_login = g_last_update_login
     WHERE line.commission_line_id in
                (SELECT line2.commission_line_id
                   FROM cn_process_batches_all batch,
	                    cn_commission_lines_all line2,
                        cn_commission_headers_all ch
	              WHERE batch.physical_batch_id = p_physical_batch_id
                    AND line2.commission_header_id = ch.commission_header_id
	                AND line2.credited_salesrep_id = batch.salesrep_id
	                AND line2.processed_period_id BETWEEN batch.period_id AND batch.end_period_id
	                AND line2.processed_date >= batch.start_date
	                AND line2.status = 'POP'
                    AND line2.org_id = batch.org_id
                    AND line2.trx_type NOT IN ('FORECAST', 'BONUS')
                    AND substr(line2.pre_processed_code, 4, 1) = 'N'
                    AND ch.commission_amount is null );
    commit;

    UPDATE cn_commission_lines_all line
       SET line.status = 'CALC',
           line.commission_amount = (select amthead.commission_amount
                                       from cn_commission_headers_all amthead,
                                            cn_commission_lines_all amtline
                                      where amthead.commission_header_id = amtline.commission_header_id
                                        and amtline.commission_line_id = line.commission_line_id
                                       ),
             line.credit_type_id = (select credit_type_id from cn_quotas_all where quota_id = line.quota_id),
	         last_update_date = sysdate,
	         last_updated_by = g_last_updated_by,
	         last_update_login = g_last_update_login
            WHERE line.commission_line_id in
			    (SELECT line2.commission_line_id
                   FROM cn_process_batches_all batch,
	                    cn_commission_lines_all line2,
                        cn_commission_headers_all ch
	              WHERE batch.physical_batch_id = p_physical_batch_id
                    AND line2.commission_header_id = ch.commission_header_id
	                AND line2.credited_salesrep_id = batch.salesrep_id
	                AND line2.processed_period_id BETWEEN batch.period_id AND batch.end_period_id
	                AND line2.processed_date >= batch.start_date
                    AND line2.org_id = batch.org_id
	                AND line2.status = 'POP'
                    AND line2.trx_type NOT IN ('FORECAST', 'BONUS')
                    AND substr(line2.pre_processed_code, 4, 1) = 'N'
                    AND ch.commission_amount is not null );

    commit;

    FOR spp IN l_srp_plan_periods_csr LOOP
      l_quota_sequence := 10000;

      -- g_intel_calc_flag = 'N'   non intelligent calc
      -- OR (g_intel_calc_flag = 'Y' AND l_process_all_flag = 'Y')
      --      there is revert due to 'COL', 'CLS', 'ROLL', ACTION events
      -- OR (g_intel_calc_flag = 'Y' AND l_salesrep_option = 'ALL_REPS' )
      --     always guarantee that all plan elements will be picked up.
      IF (g_intel_calc_flag = 'N' OR
          (g_intel_calc_flag = 'Y' AND spp.process_all_flag = 'Y') OR
          (g_intel_calc_flag = 'Y' AND l_salesrep_option = 'ALL_REPS'))
      THEN
        FOR l_pe IN l_srp_quotas_csr (spp.srp_plan_assign_id, spp.salesrep_id, spp.period_id) LOOP
          if (l_quota_sequence > l_pe.quota_sequence) then
            l_quota_sequence := l_pe.quota_sequence;
          end if;

          if (l_pe.quota_sequence > l_quota_sequence) then
            l_process_all_flag := 'Y';
          else
            l_process_all_flag := spp.process_all_flag;
          end if;

	      calculate_quota(     spp.srp_plan_assign_id,
                               spp.salesrep_id,
                               spp.period_id,
                               spp.start_date,
                               l_pe.quota_id,
                               l_process_all_flag,
                               g_intel_calc_flag,
                               g_calc_type,
                               l_next_processed_date);
	      swap_dates(l_current_processed_date, l_next_processed_date);

	    END LOOP;
      ELSE --IF (g_intel_calc_flag = 'Y' AND spp.process_all_flag = 'N') THEN
        -- in this scenario, we might not have to do all the plan elements depending on the
        -- entries in notify_log
        -- 1). if 'CALC' with null quota_id exists,
        --       get all quotas
        --          a). IF quotas with entry with 'POP', 'CALC' event
        --                 --> guarantee non incremental CALC
        --          b). ELSE  for those quota with no 'POP', 'CALC' entries
        --                 --> incremental calc is still possible
        -- 2). ELSE only calcualte those quotas with entry 'POP' or 'CALC' plus calculate for last quotas
        --          a). quotas with entry with 'POP', 'CALC' event--> non incremental CALC

        OPEN l_check_calc_entry_csr(spp.salesrep_id, spp.period_id);
        FETCH l_check_calc_entry_csr INTO l_counter;

        IF l_check_calc_entry_csr%found THEN
	      cn_message_pkg.debug('Process plan elements in notify log only (try incremental calc)');
	      FOR l_pe IN l_srp_quotas_csr(spp.srp_plan_assign_id, spp.salesrep_id, spp.period_id) LOOP
            if (l_quota_sequence > l_pe.quota_sequence) then
              l_quota_sequence := l_pe.quota_sequence;
            end if;

            open l_notify_log_csr(spp.salesrep_id, spp.period_id, l_pe.quota_id);
            fetch l_notify_log_csr into l_counter;
            if (l_notify_log_csr%found or l_pe.quota_sequence > l_quota_sequence) then
              l_process_all_flag := 'Y';
            else
              l_process_all_flag := spp.process_all_flag;
            end if;
            close l_notify_log_csr;

	        calculate_quota(
				 spp.srp_plan_assign_id,
				 spp.salesrep_id,
				 spp.period_id,
				 spp.start_date,
				 l_pe.quota_id,
				 l_process_all_flag,
				 g_intel_calc_flag,
				 g_calc_type,
				 l_next_processed_date   );
	        swap_dates ( l_current_processed_date, l_next_processed_date);

	      END LOOP;
	    ELSE
	      cn_message_pkg.debug('Process plan elements in notify log only (Non incremental calc)');
	      FOR l_pe IN l_srp_quotas_csr(spp.srp_plan_assign_id, spp.salesrep_id, spp.period_id) LOOP
            open l_notify_log_csr(spp.salesrep_id, spp.period_id, l_pe.quota_id);
            fetch l_notify_log_csr into l_counter;
            if (l_notify_log_csr%found or l_pe.quota_sequence > l_quota_sequence) then
	          calculate_quota(
				    spp.srp_plan_assign_id,
				    spp.salesrep_id,
				    spp.period_id,
				    spp.start_date,
				    l_pe.quota_id,
				    'Y', -- non incremental calc
				    g_intel_calc_flag,
				    g_calc_type,
				    l_next_processed_date   );
	          swap_dates ( l_current_processed_date, l_next_processed_date);

            end if;
            close l_notify_log_csr;
	      END LOOP;
        END IF;

	    CLOSE l_check_calc_entry_csr;
      END IF;
    END LOOP;
  ELSIF g_calc_type = 'BONUS' THEN
    SELECT COUNT(*) INTO l_counter
      FROM cn_calc_sub_quotas
     WHERE calc_sub_batch_id = l_calc_sub_batch_id;

    -- no particular bonus plan elements are specified
    IF l_counter = 0 THEN
      l_calc_sub_batch_id := -1000;
    END IF;

    FOR l_pe IN l_bonus_pe_csr LOOP
      IF (l_interval_type_id = -1003 AND l_pe.interval_type_id <> -1000) THEN
        -- need to check whether it's the end of the interval
        IF cn_proc_batches_pkg.check_end_of_interval(l_pe.end_period_id, l_pe.interval_type_id, l_org_id) THEN
	      calculate_quota(l_pe.srp_plan_assign_id,
                          l_pe.salesrep_id,
                          l_pe.end_period_id,
                          l_pe.end_date,
                          l_pe.quota_id,
		                  'Y', -- p_process_all_flag
		                  g_intel_calc_flag,
                          g_calc_type,
                          l_next_processed_date);
	      swap_dates(l_current_processed_date, l_next_processed_date);

        END IF;
      ELSE
	    calculate_quota(l_pe.srp_plan_assign_id,
                        l_pe.salesrep_id,
                        l_pe.end_period_id,
                        l_pe.end_date,
                        l_pe.quota_id,
                        'Y', -- p_process_all_flag
                        g_intel_calc_flag,
                        g_calc_type,
                        l_next_processed_date);
        swap_dates(l_current_processed_date, l_next_processed_date);

      END IF;
    END LOOP;
  END IF ;

  IF (g_calc_type = 'COMMISSION') THEN
    -- update all leftover 'POP' status trx to be 'XCALC'.
    UPDATE cn_commission_lines_all line
       SET line.status = 'XCALC',
	       last_update_date = sysdate,
	       last_updated_by = g_last_updated_by,
	       last_update_login = g_last_update_login
     WHERE line.commission_line_id IN
	            (SELECT line2.commission_line_id
	               FROM cn_process_batches_all batch,
	                    cn_commission_lines_all line2
	              WHERE batch.physical_batch_id = p_physical_batch_id
                    AND line2.org_id = batch.org_id
	                AND line2.credited_salesrep_id = batch.salesrep_id
	                AND line2.processed_period_id BETWEEN batch.period_id AND batch.end_period_id
	                AND line2.processed_date >= batch.start_date
	                AND line2.status = 'POP'
                    AND substr(line2.pre_processed_code, 4, 1) = 'C'
                    AND trx_type NOT IN ('FORECAST', 'BONUS'));

    commit;

    -- obsolete the entries in cn_notify_log for single salesrep_id, for all salesrep entries, those are handled in processor
    UPDATE cn_notify_log_all Log
       SET Log.status = 'COMPLETE'
     WHERE Log.notify_log_id IN
	         (SELECT log2.notify_log_id
	            FROM cn_notify_log_all log2,
	                 cn_process_batches_all batch
	           WHERE batch.physical_batch_id = p_physical_batch_id
                 AND log2.org_id = batch.org_id
	             AND log2.salesrep_id = batch.salesrep_id
	             AND log2.period_id BETWEEN batch.period_id AND batch.end_period_id
	             AND log2.status = 'INCOMPLETE'
	             AND log2.start_date >= batch.start_date);
     commit;

     -- Update all records in notify log that are related to Hierarchical changes.
	 UPDATE cn_notify_log_all Log
		SET Log.status = 'COMPLETE'
		 WHERE Log.notify_log_id IN (
			   SELECT event.notify_log_id
			   FROM cn_notify_log_all event
			   WHERE event.physical_batch_id = p_physical_batch_id
			   AND event.action IN ('SOURCE_CLS', 'XROLL', 'ROLL_PULL', 'DELETE_ROLL_PULL')
			   AND event.status = 'INCOMPLETE'
			   UNION
			   SELECT event.notify_log_id
			   FROM cn_notify_log_all event, cn_process_batches_all batch
			   WHERE batch.physical_batch_id = p_physical_batch_id
			   AND batch.salesrep_id = event.salesrep_id
               AND event.org_id = batch.org_id
			   AND event.period_id between batch.period_id and batch.end_period_id
			   AND event.action IN  ('PULL', 'PULL_WITHIN', 'PULL_BELOW')
			   AND event.status = 'INCOMPLETE') ;
     commit;

	-- reset process_all_flag = 'N' since calculation completed sucessfully
    update cn_srp_intel_periods_all a
       set a.process_all_flag = 'N'
     where a.org_id = l_org_id
       and a.salesrep_id in (select salesrep_id from cn_process_batches_all
                              where physical_batch_id = p_physical_batch_id)
       and a.period_id >= (select min(period_id) from cn_process_batches_all
                                 where physical_batch_id = p_physical_batch_id
                                   and salesrep_id = a.salesrep_id)
       and a.period_id <= (select max(end_period_id) from cn_process_batches_all
                                 where physical_batch_id = p_physical_batch_id
                                   and salesrep_id = a.salesrep_id);
    commit;
  END IF;

  -- for maintaining cn_repositories.latest_processed_date
  UPDATE cn_repositories_all
     SET latest_processed_date = l_current_processed_date
   WHERE latest_processed_date < l_current_processed_date
     AND org_id = l_org_id;

  commit;

  -- update each salesrep subledger
  l_srp_subledger.physical_batch_id := p_physical_batch_id;

  cn_calc_subledger_pvt.update_srp_subledger
                                   (p_api_version => 1.0,
                                    p_init_msg_list => fnd_api.g_true,
                                    x_return_status => l_return_status,
                                    x_msg_count => l_msg_count,
                                    x_msg_data => l_msg_data,
                                    p_srp_subledger => l_srp_subledger);

  IF l_return_status <> FND_API.g_ret_sts_success THEN
     cn_message_pkg.debug('Exception occurs in updating subledgers:');
     FOR l_counter IN 1..l_msg_count LOOP
	   cn_message_pkg.debug(FND_MSG_PUB.get(p_msg_index => l_counter,
	                        p_encoded   => FND_API.G_FALSE));
	   fnd_file.put_line(fnd_file.Log, fnd_msg_pub.get(p_msg_index => l_counter,
							p_encoded   => FND_API.G_FALSE));
     END LOOP;

     RAISE api_call_failed;
  END IF;

  if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'cn.plsql.cn_formula_common_pkg.calculate_batch.end',
       		       'End of calculate_batch ...');
  end if;
EXCEPTION
  WHEN others THEN
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                     'cn.plsql.cn_formula_common_pkg.calculate_batch.exception',
	      		     sqlerrm);
    end if;

    cn_message_pkg.debug('Exception occurs in calculate_batch: ');
	cn_message_pkg.rollback_errormsg_commit(sqlerrm);
    raise;
END calculate_batch;

  --  p_commission_header_id will be the commisson_header_id of the reversal trx created
  PROCEDURE handle_reversal_trx ( p_commission_header_id NUMBER) IS

   CURSOR c_affected_reps IS
          select distinct credited_salesrep_id, processed_date, processed_period_id, org_id
          FROM cn_commission_lines_all
          WHERE status = 'OBSOLETE'
           and posting_status = 'UNPOSTED'
          and (commission_header_id = (SELECT reversal_header_id
                                         FROM cn_commission_headers_all
                                        WHERE commission_header_id = p_commission_header_id)
   	     OR commission_header_id = (SELECT parent_header_id
       					            FROM cn_commission_headers_all
   					                WHERE commission_header_id = (SELECT reversal_header_id
   								                                  FROM cn_commission_headers_all
   								                                  WHERE commission_header_id = p_commission_header_id)));

     CURSOR l_orig_posted_trx IS
	SELECT commission_line_id
	  FROM cn_commission_lines_all
	  WHERE (commission_header_id = (SELECT reversal_header_id
                                       FROM cn_commission_headers_all
					 WHERE commission_header_id = p_commission_header_id)
		 OR commission_header_id = (SELECT parent_header_id
					    FROM cn_commission_headers_all
					    WHERE commission_header_id = (SELECT reversal_header_id
									  FROM cn_commission_headers_all
									  WHERE commission_header_id = p_commission_header_id)))

	  AND status = 'CALC'
	  AND posting_status = 'POSTED';
  BEGIN
     -- revert all posted trx generated from the original commission_header line
     FOR l_line IN l_orig_posted_trx LOOP
	revert_posting_line( l_line.commission_line_id );
     END LOOP;

     -- update all trx generated from the original commission_header line
     -- to be obsolete
     UPDATE cn_commission_lines_all
       SET status = 'OBSOLETE', posting_status = 'UNPOSTED'
       WHERE (commission_header_id = (SELECT reversal_header_id FROM cn_commission_headers_all
				      WHERE commission_header_id = p_commission_header_id)
	      OR commission_header_id = (SELECT parent_header_id
					 FROM cn_commission_headers_all
					 WHERE commission_header_id = (SELECT reversal_header_id
								       FROM cn_commission_headers_all
								       WHERE commission_header_id = p_commission_header_id)));

      FOR rep IN c_affected_reps LOOP
		cn_mark_events_pkg.mark_notify
		 ( p_salesrep_id     => rep.credited_salesrep_id,
		   p_period_id       => rep.processed_period_id,
		   p_start_date      => rep.processed_date,
		   p_end_date        => rep.processed_date,
		   p_quota_id        => NULL,
		   p_revert_to_state => 'CALC',
		   p_event_log_id    => NULL,
           p_org_id          => rep.org_id);
     end loop;

     -- create a negative copy of the above lines
     INSERT INTO cn_commission_lines_all
       ( commission_line_id, credited_salesrep_id,
	 processed_period_id, processed_date,
	 quota_id,  credit_type_id, quota_rule_id,
	 event_factor, payment_factor,
	 quota_factor, commission_amount,
	 rate_tier_id, commission_rate,
	 payee_line_id, status,
	 trx_type, tier_split,
	 created_during, created_by,
	 creation_date, last_updated_by,
	 last_update_login, last_update_date,
	 commission_header_id, srp_plan_assign_id,
	 posting_status, input_achieved,
	 output_achieved, perf_achieved,
	 pay_period_id, pending_status,
	 role_id, pending_date, credited_comp_group_id, org_id	)
       SELECT  cn_commission_lines_s.nextval, line.credited_salesrep_id,
       line.processed_period_id, line.processed_date,
       line.quota_id,  line.credit_type_id, line.quota_rule_id,
       line.event_factor, line.payment_factor,
       line.quota_factor, -( Nvl(line.commission_amount, 0) ),
       line.rate_tier_id, line.commission_rate,
       line.commission_line_id, -- specify that it's a negative copy
       line.status,
       line.trx_type, line.tier_split,
       line.created_during, g_created_by,
       g_creation_date, g_last_updated_by,
       g_last_update_login, sysdate,
       p_commission_header_id, line.srp_plan_assign_id,
       line.posting_status, -( Nvl(line.input_achieved,0) ),
       -( Nvl(line.output_achieved,0)), -( Nvl(line.perf_achieved,0)),
       line.pay_period_id, line.pending_status,
       line.role_id, line.pending_date, line.credited_comp_group_id, line.org_id
       FROM cn_commission_lines_all line
       WHERE (line.commission_header_id = (SELECT reversal_header_id FROM cn_commission_headers_all
				      WHERE commission_header_id = p_commission_header_id)
	      OR line.commission_header_id = (SELECT parent_header_id
					 FROM cn_commission_headers_all
					 WHERE commission_header_id = (SELECT reversal_header_id
								       FROM cn_commission_headers_all
								       WHERE commission_header_id = p_commission_header_id)));

     -- update commission_header.status to be 'OBSOLETE'
     UPDATE cn_commission_headers_all ch SET
        ch.status = 'OBSOLETE',
        -- clku, update the last updated info
           last_update_date = sysdate,
           last_updated_by = G_LAST_UPDATED_BY,
           last_update_login = G_LAST_UPDATE_LOGIN
       WHERE commission_header_id = p_commission_header_id;

     UPDATE cn_commission_headers_all ch SET
       ch.status = 'OBSOLETE',
       -- clku, update the last updated info
           last_update_date = sysdate,
           last_updated_by = G_LAST_UPDATED_BY,
           last_update_login = G_LAST_UPDATE_LOGIN
       WHERE commission_header_id
       IN (SELECT head.reversal_header_id
	   FROM cn_commission_headers_all head
	   WHERE head.commission_header_id = p_commission_header_id );

     -- delete sum trx
     DELETE FROM cn_commission_headers_all
       WHERE commission_header_id = (SELECT parent_header_id
					 FROM cn_commission_headers_all
					 WHERE commission_header_id = (SELECT reversal_header_id
								       FROM cn_commission_headers_all
								       WHERE commission_header_id = p_commission_header_id));
     -- for source trxs of the sum trx, set their parent_header_id = null
     UPDATE cn_commission_headers_all
       SET parent_header_id = NULL,
       -- clku, update the last updated info
           last_update_date = sysdate,
           last_updated_by = G_LAST_UPDATED_BY,
           last_update_login = G_LAST_UPDATE_LOGIN
       WHERE parent_header_id = (SELECT parent_header_id
					 FROM cn_commission_headers_all
					 WHERE commission_header_id = (SELECT reversal_header_id
								       FROM cn_commission_headers_all
								       WHERE commission_header_id = p_commission_header_id));
  END handle_reversal_trx;

  --   delete/update derived commission_lines
  --   it's invoked from classification package to intelligently handle reclassification
  --   it's assumed that during CLS phase, a trx with 'OBSOLETE' status would be picked up.
  --   so in this procedure, we don't have to worry about that.
  PROCEDURE revert_header_lines( p_commission_header_id NUMBER, p_revert_state VARCHAR2) IS
     CURSOR l_posted_trxs_csr IS
	SELECT commission_line_id
	  FROM cn_commission_lines_all
	  WHERE commission_header_id = p_commission_header_id
	  AND posting_status = 'POSTED'
	  AND status = 'CALC';

     CURSOR l_posted_trxs_csr2 IS
	SELECT commission_line_id
	  FROM cn_commission_lines_all
	  WHERE commission_header_id = (SELECT parent_header_id
					FROM cn_commission_headers_all
					WHERE commission_header_id = p_commission_header_id)
	  AND posting_status = 'POSTED'
	  AND status = 'CALC';
  BEGIN
     IF p_revert_state = 'XCLS' THEN
	-- revert posted line before deleting any commission lines
	FOR l_line IN l_posted_trxs_csr LOOP
	   revert_posting_line( l_line.commission_line_id);
	END LOOP;

	FOR l_line IN l_posted_trxs_csr2 LOOP
	   revert_posting_line( l_line.commission_line_id);
	END LOOP;

	DELETE cn_commission_lines_all
	  WHERE commission_header_id = p_commission_header_id;

	DELETE cn_commission_lines_all
	  WHERE commission_header_id = (SELECT parent_header_id FROM cn_commission_headers_all
                                     WHERE commission_header_id = p_commission_header_id);

	DELETE cn_commission_headers_all
	  WHERE commission_header_id = (SELECT parent_header_id FROM cn_commission_headers_all
                                     WHERE commission_header_id = p_commission_header_id);

	UPDATE cn_commission_headers_all
	  SET parent_header_id = NULL,
           last_update_date = sysdate,
           last_updated_by = G_LAST_UPDATED_BY,
           last_update_login = G_LAST_UPDATE_LOGIN
	  WHERE parent_header_id = (SELECT parent_header_id FROM cn_commission_headers_all
                                 WHERE commission_header_id = p_commission_header_id);

      ELSIF p_revert_state = 'ROLL' THEN
	-- revert posted line before deleting any commission lines
	FOR l_line IN l_posted_trxs_csr LOOP
	   revert_posting_line( l_line.commission_line_id);
	END LOOP;

	FOR l_line IN l_posted_trxs_csr2 LOOP
	   revert_posting_line( l_line.commission_line_id);
	END LOOP;

	DELETE cn_commission_lines_all
	  WHERE commission_header_id = p_commission_header_id
	  AND created_during IN ( 'POP', 'CALC');

	DELETE cn_commission_lines_all
	  WHERE commission_header_id = (SELECT parent_header_id FROM cn_commission_headers_all
                                     WHERE commission_header_id = p_commission_header_id);

	DELETE cn_commission_headers_all
	  WHERE commission_header_id = (SELECT parent_header_id FROM cn_commission_headers_all
                                     WHERE commission_header_id = p_commission_header_id);

	UPDATE cn_commission_headers_all
	  SET parent_header_id = NULL,
           last_update_date = sysdate,
           last_updated_by = G_LAST_UPDATED_BY,
           last_update_login = G_LAST_UPDATE_LOGIN
	  WHERE parent_header_id = (SELECT parent_header_id FROM cn_commission_headers_all
                                 WHERE commission_header_id = p_commission_header_id);

	UPDATE cn_commission_lines_all
	  SET status = 'ROLL',
	  posting_status = 'UNPOSTED',
	  event_factor = NULL,
	  payment_factor = NULL,
	  quota_factor = NULL,
	  rate_tier_id = NULL,
	  commission_rate = NULL,
	  tier_split = NULL,
	  input_achieved = NULL,
	  output_achieved = NULL,
	  perf_achieved = NULL,
	  error_reason = NULL,
	  srp_payee_assign_id = NULL,
	  threshold_check_status = NULL,
	  srp_plan_assign_id = NULL,
	  quota_id = NULL,
	  quota_rule_id = NULL,
	  last_update_date = sysdate,
	  last_updated_by = g_last_updated_by,
	  last_update_login = g_last_update_login
	  WHERE commission_header_id = p_commission_header_id;
     END IF;
  END revert_header_lines;

  Procedure revert_batch_intel_comm (p_physical_batch_id cn_process_batches.physical_batch_id%TYPE ) IS
     -- 'COL' event which need to reclassify, will be handled in CLASSIFICATION phase
     -- 'CLS' event which only happened when mangerial rollup flag is changed,
     --       will be handled here, set process_all_flag = 'Y'
     -- 'ROLL' event, handled here set process_all_flag = 'Y'
     -- 'POP'  event,  ??? set process_all_flag = 'Y', THRESHOLD ???
     -- 'CALC' event, not handled here, only action 'DELETE' is handled.
     -- 'NCALC' event , not handled here, in ROLLUP phase

     l_mgr_role_flag           jtf_rs_roles_b.manager_flag%TYPE;
	 l_mem_role_flag            jtf_rs_roles_b.member_flag%TYPE;
     l_org_id                   number;

     -- cursor to get the old manager_flag
	 CURSOR role_flag_cur (p_role_id NUMBER)IS
	 SELECT member_flag, manager_flag
	 FROM jtf_rs_roles_b
	 WHERE role_id = p_role_id
     AND role_type_code = 'SALES_COMP';

     CURSOR l_log_rep_del_actions_csr IS
	SELECT batch.salesrep_id, Log.period_id,
	  Log.start_date, Log.end_date,
	  Log.revert_state, Log.comp_group_id,
	  Log.base_salesrep_id, Log.base_comp_group_id,
	  Log.role_id, Log.action
	  FROM cn_process_batches_all batch,
	  cn_notify_log_all  Log
	  WHERE batch.physical_batch_id = p_physical_batch_id
      AND log.org_id = batch.org_id
	  AND Log.period_id BETWEEN batch.period_id AND batch.end_period_id
	  AND Log.salesrep_id = batch.salesrep_id
	  AND Log.status = 'INCOMPLETE'
	  AND Log.action IS NOT NULL
	    AND Log.action IN ('DELETE_TEAM_MEMB', 'DELETE_SOURCE', 'DELETE_DEST_WITHIN', 'DELETE_DEST_XROLL', 'DELETE_DEST')
	  ORDER BY batch.salesrep_id, Log.period_id, Log.revert_sequence, Log.notify_log_id;

     CURSOR l_log_rep_periods_csr IS
	SELECT batch.salesrep_id, Log.period_id,
	  Log.start_date, Log.end_date,
	  Log.revert_state, Log.comp_group_id,
	  Log.base_salesrep_id, Log.base_comp_group_id,
	  Log.quota_id
	  FROM cn_process_batches_all batch,
	  cn_notify_log_all  Log
	  WHERE batch.physical_batch_id = p_physical_batch_id
      AND log.org_id = batch.org_id
	  AND Log.period_id BETWEEN batch.period_id AND batch.end_period_id
	  AND ( Log.salesrep_id = batch.salesrep_id
		OR Log.salesrep_id = -1000 )
	  AND Log.status = 'INCOMPLETE'
	  AND Log.revert_state <> 'NCALC'
	  ORDER BY batch.salesrep_id, Log.period_id, Log.revert_sequence, Log.notify_log_id;

     CURSOR l_pop_lines_csr (l_salesrep_id NUMBER,
			     l_period_id   NUMBER,
			     l_start_date  DATE,
			     l_end_date    DATE,
			     l_quota_id    NUMBER )IS
	SELECT line.commission_line_id,
	  line.posting_status,
	  line.created_during
	  FROM cn_commission_lines_all line
	  WHERE line.credited_salesrep_id = l_salesrep_id
	  AND line.processed_period_id = l_period_id
	  AND line.quota_id = l_quota_id
	  AND line.processed_date BETWEEN l_start_date AND l_end_date
	  AND line.trx_type NOT IN ('FORECAST', 'BONUS')
	  AND line.status NOT IN ( 'XPOP', 'OBSOLETE' );

     CURSOR l_roll_lines_csr (l_salesrep_id NUMBER,
				  l_period_id   NUMBER,
				  l_start_date  DATE,
				  l_end_date    DATE    ) IS
	SELECT line.commission_line_id,
	  line.posting_status,
	  line.created_during
	  FROM cn_commission_lines line
	  WHERE line.credited_salesrep_id = l_salesrep_id
	  AND line.processed_period_id = l_period_id
	  AND line.processed_date BETWEEN l_start_date AND l_end_date
	  AND line.status <> 'OBSOLETE'
	  AND line.trx_type NOT IN ('FORECAST', 'BONUS')
      AND line.org_id = l_org_id;

     CURSOR l_cls_posted_lines_csr  ( l_salesrep_id NUMBER,
				      l_period_id NUMBER,
				      l_start_date DATE,
				      l_end_date  DATE     )  IS
	SELECT line.commission_line_id
	  FROM cn_commission_lines_all line
	  WHERE line.commission_header_id
	  IN ( SELECT header.commission_header_id
	       FROM cn_commission_headers_all header
	       WHERE header.direct_salesrep_id = l_salesrep_id
	       AND header.processed_period_id = l_period_id
	       AND header.processed_date BETWEEN l_start_date AND l_end_date
	       AND header.status = 'ROLL'
           AND header.org_id = l_org_id
	       AND header.trx_type NOT IN ('FORECAST', 'BONUS') )
	  AND line.posting_status = 'POSTED'
	  AND line.status = 'CALC';

     CURSOR l_itd_grp_trx_csr ( l_salesrep_id NUMBER,
				l_period_id   NUMBER,
				l_quota_id    NUMBER,
				l_revert_state VARCHAR2 ) IS
	SELECT line.commission_line_id, line.posting_status
	  FROM cn_commission_lines_all line
	  WHERE line.credited_salesrep_id = l_salesrep_id
	  AND line.processed_period_id = l_period_id
	  AND line.trx_type IN ('ITD', 'GRP')
	  AND line.org_id = l_org_id
	  AND ((l_revert_state = 'POP' AND line.quota_id = l_quota_id) OR
	       (l_revert_state = 'CALC' AND (line.quota_id = l_quota_id or l_quota_id is null)) OR
		   (l_revert_state not in ('POP', 'CALC')));

     CURSOR revert_lines_delete_source(p_salesrep_id NUMBER, p_comp_group_id NUMBER, p_period_id NUMBER,
				       p_start_date DATE, p_end_date DATE, p_role_id NUMBER, p_base_comp_group_id NUMBER,
				       p_base_salesrep_id NUMBER)
       IS
	  SELECT commission_line_id
	    FROM cn_commission_lines_all cl
	    WHERE cl.credited_salesrep_id = p_salesrep_id
	    AND cl.credited_comp_group_id = p_comp_group_id
	    AND cl.processed_period_id = p_period_id
            and cl.status = 'CALC'
	    and cl.posting_status = 'POSTED'
        and cl.org_id = l_org_id
	    AND cl.processed_date BETWEEN p_start_date AND p_end_date
	    AND ((p_role_id IS NOT NULL AND cl.role_id = p_role_id ) OR p_role_id IS NULL)
	    AND exists ( SELECT 1
			 FROM cn_commission_headers_all ch
			 WHERE ch.commission_header_id = cl.commission_header_id
			 AND ch.comp_group_id = p_base_comp_group_id
			 AND ( p_base_salesrep_id IS NULL OR ch.direct_salesrep_id = p_base_salesrep_id));

      CURSOR revert_lines_del_within(p_salesrep_id NUMBER, p_comp_group_id NUMBER, p_period_id NUMBER,
	 					    p_start_date DATE, p_end_date DATE, p_role_id NUMBER)
	        IS
	 	  SELECT commission_line_id
	 	    FROM cn_commission_lines_all cl
	 	    WHERE cl.posting_status = 'POSTED'
                      and cl.status = 'CALC'
	 	      AND cl.credited_comp_group_id = p_comp_group_id
	 	      AND cl.processed_period_id = p_period_id
	 	      AND cl.processed_date BETWEEN p_start_date AND p_end_date
              AND cl.org_id = l_org_id
	 	      AND ((p_role_id IS NOT NULL AND cl.role_id = p_role_id
	                 AND ((l_mgr_role_flag = 'N' and l_mem_role_flag = 'N' and  cl.credited_salesrep_id = p_salesrep_id)
	                   OR (l_mgr_role_flag = 'N' and l_mem_role_flag = 'Y' and  cl.credited_salesrep_id = p_salesrep_id and cl.direct_salesrep_id <> p_salesrep_id))
	                ) OR (p_role_id IS NULL AND cl.credited_salesrep_id = p_salesrep_id))
	 	     AND exists
	 		( SELECT 1
	 		  FROM cn_commission_headers_all ch
	 		  WHERE ch.commission_header_id = cl.commission_header_id
	 		  AND ch.comp_group_id = p_comp_group_id );



     CURSOR revert_lines_delete_dest(p_salesrep_id NUMBER, p_comp_group_id NUMBER, p_period_id NUMBER,
					    p_start_date DATE, p_end_date DATE, p_role_id NUMBER)
       IS
	  SELECT commission_line_id
	    FROM cn_commission_lines_all cl
	    WHERE cl.credited_salesrep_id = p_salesrep_id
	    and cl.posting_status = 'POSTED'
            and cl.status = 'CALC'
	    AND cl.credited_comp_group_id = p_comp_group_id
	    AND cl.processed_period_id = p_period_id
	    AND cl.processed_date BETWEEN p_start_date AND p_end_date
        AND cl.org_id = l_org_id
	    AND ( (p_role_id IS NOT NULL AND cl.role_id = p_role_id ) OR p_role_id IS NULL );

     CURSOR revert_lines_delete_dest2(p_salesrep_id NUMBER, p_comp_group_id NUMBER, p_period_id NUMBER,
					    p_start_date DATE, p_end_date DATE, p_role_id NUMBER)
       IS
	  SELECT commission_line_id
	    FROM cn_commission_lines_all cl
	    WHERE cl.credited_salesrep_id = p_salesrep_id
	    and cl.posting_status = 'POSTED'
            and cl.status = 'CALC'
	    AND cl.credited_comp_group_id = p_comp_group_id
	    AND cl.processed_period_id = p_period_id
	    AND cl.processed_date BETWEEN p_start_date AND p_end_date
        AND cl.org_id = l_org_id
	    AND ( (p_role_id IS NOT NULL AND cl.role_id = p_role_id ) OR p_role_id IS NULL )
	      AND NOT exists (SELECT 1
			      FROM cn_srp_comp_groups_v
			      WHERE comp_group_id = cl.credited_comp_group_id
			      AND salesrep_id = cl.credited_salesrep_id
			      AND role_id = cl.role_id
                  AND org_id = cl.org_id
			      AND cl.processed_date BETWEEN start_date_active AND Nvl(end_date_active, cl.processed_date));

     CURSOR revert_lines_delete_dest3(p_salesrep_id NUMBER, p_comp_group_id NUMBER, p_period_id NUMBER,
					    p_start_date DATE, p_end_date DATE, p_role_id NUMBER)
       IS
	  SELECT commission_line_id
	    FROM cn_commission_lines_all cl
	    WHERE cl.credited_salesrep_id = p_salesrep_id
	    and cl.posting_status = 'POSTED'
            and cl.status = 'CALC'
            and cl.org_id = l_org_id
	    AND cl.credited_comp_group_id = p_comp_group_id
	    AND cl.direct_salesrep_id <> p_salesrep_id
	    AND cl.processed_period_id = p_period_id
	    AND cl.processed_date BETWEEN p_start_date AND p_end_date
	    and not exists (select 1
			    from cn_srp_comp_groups_v
			    where comp_group_id = p_comp_group_id
			    and salesrep_id = cl.credited_salesrep_id
			    and cl.processed_date between start_date_active and nvl(end_date_active, cl.processed_date)
                and org_id = cl.org_id
			    and manager_flag = 'Y')
	    and exists( select 1
			from cn_srp_comp_groups_v
			where comp_group_id = p_comp_group_id
			and salesrep_id = cl.direct_salesrep_id
            and org_id = cl.org_id
			and cl.processed_date between start_date_active and nvl(end_date_active, cl.processed_date));

  CURSOR revert_lines_delete_team_memb(p_salesrep_id NUMBER, p_period_id NUMBER,
				       p_start_date DATE, p_end_date DATE) IS
	  SELECT commission_line_id
	  from cn_commission_lines_all
	  where posting_status = 'POSTED'
	    and (commission_header_id, credited_salesrep_id) in
	  (select commission_header_id, credited_salesrep_id
	  FROM cn_commission_lines_all cl
	  WHERE cl.credited_salesrep_id = p_salesrep_id
	  AND cl.processed_period_id = p_period_id
	  AND cl.created_during = 'TROLL'
      AND cl.org_id = l_org_id
	  AND cl.processed_date BETWEEN p_start_date AND p_end_date);

  BEGIN
     cn_message_pkg.debug('Reversing transactions in physical batch (ID=' || p_physical_batch_id||')');

     select org_id into l_org_id
      from cn_process_batches_all
     where physical_batch_id = p_physical_batch_id
       and rownum = 1;

     -- mark proces_all_flag = 'Y', means that need to recalculate every transaction
     -- in calc phase since some trx has been reverted

     -- since 'POP' event only affect a particular quota, we shouldn't mark the whole period
     --   will be considered in calculate_batch

     UPDATE cn_srp_intel_periods_all
        SET process_all_flag = 'Y'
       WHERE org_id = l_org_id
         AND ( salesrep_id, period_id ) IN
       ( SELECT DISTINCT batch.salesrep_id, Log.period_id
	 FROM cn_process_batches_all batch,
	  cn_notify_log_all  Log
	  WHERE batch.physical_batch_id = p_physical_batch_id
      AND log.org_id = batch.org_id
	  AND Log.period_id BETWEEN batch.period_id AND batch.end_period_id
	  AND ( Log.salesrep_id = batch.salesrep_id
		OR Log.salesrep_id = -1000 )
	  AND Log.status = 'INCOMPLETE'
	  AND ( Log.revert_state NOT IN ( 'NCALC', 'CALC', 'POP')
		OR ( Log.action IS NOT NULL
		     AND Log.action IN ('DELETE_TEAM_MEMB', 'DELETE_SOURCE', 'DELETE_DEST_WITHIN', 'DELETE_DEST_XROLL', 'DELETE_DEST') )
		)
	 );

     -- handle DELETE actions first
     FOR l_log IN l_log_rep_del_actions_csr LOOP
      IF l_log.action = 'DELETE_TEAM_MEMB' THEN
	  	FOR line IN revert_lines_delete_team_memb(l_log.salesrep_id,l_log.period_id,l_log.start_date,
	  						  l_log.end_date)	LOOP
	  		revert_posting_line(line.commission_line_id);
	  	END LOOP;


	  	DELETE cn_commission_lines_all
	  	WHERE (commission_header_id, credited_salesrep_id) in
	  	 (select commission_header_id, credited_salesrep_id
	  	    from cn_commission_lines_all cl
	  	   where cl.credited_salesrep_id = l_log.salesrep_id
	  	     AND cl.processed_period_id = l_log.period_id
	  	     AND cl.processed_date BETWEEN l_log.start_date AND l_log.end_date
	         AND cl.created_during = 'TROLL'
             AND cl.org_id = l_org_id);

	  ELSIF l_log.action = 'DELETE_SOURCE' THEN
	   FOR line IN revert_lines_delete_source(l_log.salesrep_id,l_log.comp_group_id,l_log.period_id,l_log.start_date,
						  l_log.end_date,l_log.role_id,l_log.base_comp_group_id, l_log.base_salesrep_id)
	     LOOP
		revert_posting_line(line.commission_line_id);
	     END LOOP;

	    DELETE cn_commission_lines_all cl
	     WHERE cl.credited_salesrep_id = l_log.salesrep_id
	     AND cl.credited_comp_group_id = l_log.comp_group_id
	     AND cl.processed_period_id = l_log.period_id
	     AND cl.processed_date BETWEEN l_log.start_date AND l_log.end_date
         AND cl.org_id = l_org_id
	     AND ( (l_log.role_id IS NOT NULL AND cl.role_id = l_log.role_id )
		   OR l_log.role_id IS NULL )
	     AND exists
		 (SELECT 1
		  FROM cn_commission_headers_all ch
		  WHERE ch.commission_header_id = cl.commission_header_id
		  AND ch.comp_group_id = l_log.base_comp_group_id
		  AND ( l_log.base_salesrep_id IS NULL
			OR ch.direct_salesrep_id = l_log.base_salesrep_id)
		  );
	   ELSIF l_log.action = 'DELETE_DEST_WITHIN' THEN
	        l_mem_role_flag := 'N';
	        l_mgr_role_flag := 'N';

	        IF l_log.role_id IS NOT NULL THEN
	            open role_flag_cur(l_log.role_id);
	            fetch role_flag_cur into l_mem_role_flag, l_mgr_role_flag;
	            close role_flag_cur;
	        END IF;

	 	   FOR line IN revert_lines_del_within(l_log.salesrep_id,l_log.comp_group_id,l_log.period_id,l_log.start_date,
	 						  l_log.end_date,l_log.role_id)
	 	   LOOP
	 		 revert_posting_line(line.commission_line_id);
	 	   END LOOP;

	 	    DELETE cn_commission_lines_all cl
	 	     WHERE cl.credited_comp_group_id = l_log.comp_group_id
	 	     AND cl.processed_period_id = l_log.period_id
	 	     AND cl.processed_date BETWEEN l_log.start_date AND l_log.end_date
             AND cl.org_id = l_org_id
	 	     AND ((l_log.role_id IS NOT NULL AND
	                cl.role_id = l_log.role_id AND
	                ((l_mgr_role_flag = 'N' and l_mem_role_flag = 'N' and  cl.credited_salesrep_id = l_log.salesrep_id) OR
	                 (l_mgr_role_flag = 'N' and l_mem_role_flag = 'Y' and  cl.credited_salesrep_id = l_log.salesrep_id and cl.direct_salesrep_id <> l_log.salesrep_id))
	           )OR (l_log.role_id IS NULL and cl.credited_salesrep_id = l_log.salesrep_id))
	 	     AND exists
	 		( SELECT 1
	 		  FROM cn_commission_headers_all ch
	 		  WHERE ch.commission_header_id = cl.commission_header_id
	 		  AND ch.comp_group_id = l_log.comp_group_id );

	 ELSIF l_log.action = 'DELETE_DEST_XROLL' THEN
	   FOR line IN revert_lines_delete_dest(l_log.salesrep_id,l_log.comp_group_id,l_log.period_id,l_log.start_date,
						l_log.end_date,l_log.role_id)
	     LOOP
		revert_posting_line(line.commission_line_id);
	     END LOOP;

	   DELETE cn_commission_lines_all cl
	     WHERE cl.credited_salesrep_id = l_log.salesrep_id
	     AND cl.credited_comp_group_id = l_log.comp_group_id
	     AND cl.processed_period_id = l_log.period_id
	     AND cl.processed_date BETWEEN l_log.start_date AND l_log.end_date
         AND cl.org_id = l_org_id
	     AND ( (l_log.role_id IS NOT NULL AND cl.role_id = l_log.role_id )
		   OR l_log.role_id IS NULL );

	   UPDATE cn_commission_headers_all ch
	     SET status = 'XROLL',
	     last_update_date = sysdate,
	     last_updated_by = g_last_updated_by,
	     last_update_login = g_last_update_login
	     WHERE ch.direct_salesrep_id = l_log.salesrep_id
	     AND ch.comp_group_id = l_log.comp_group_id
	     AND ch.processed_period_id = l_log.period_id
	     AND Nvl(ch.parent_header_id, -1) = -1
	     AND ch.processed_date BETWEEN l_log.start_date AND l_log.end_date
         AND ch.org_id = l_org_id;

	 ELSIF l_log.action = 'DELETE_DEST' THEN
	   FOR line IN revert_lines_delete_dest2(l_log.salesrep_id,l_log.comp_group_id,l_log.period_id,l_log.start_date,
						l_log.end_date,l_log.role_id)
	     LOOP
		revert_posting_line(line.commission_line_id);
	     END LOOP;

	     DELETE cn_commission_lines_all cl
	     WHERE cl.credited_salesrep_id = l_log.salesrep_id
	     AND cl.credited_comp_group_id = l_log.comp_group_id
	     AND cl.processed_period_id = l_log.period_id
	     AND cl.processed_date BETWEEN l_log.start_date AND l_log.end_date
         AND cl.org_id = l_org_id
	     AND ((l_log.role_id IS NOT NULL AND cl.role_id = l_log.role_id ) OR l_log.role_id IS NULL )
	       AND NOT exists (SELECT 1
			       FROM cn_srp_comp_groups_v
			       WHERE comp_group_id = l_log.comp_group_id
			       AND role_id = cl.role_id
			       AND salesrep_id = cl.credited_salesrep_id
                   AND org_id = cl.org_id
			       AND cl.processed_date BETWEEN start_date_active AND Nvl(end_date_active, cl.processed_date));


	     UPDATE cn_commission_lines_all cl
	       SET created_during = 'ROLL'
	       WHERE cl.credited_salesrep_id = l_log.salesrep_id
	       AND cl.credited_comp_group_id = l_log.comp_group_id
	       AND cl.processed_period_id = l_log.period_id
	       AND cl.processed_date BETWEEN l_log.start_date AND l_log.end_date
	       AND cl.created_during = 'POP'
           AND org_id = l_org_id
	       AND NOT exists (SELECT 1
			       FROM cn_commission_lines_all
			       WHERE commission_header_id = cl.commission_header_id
			       AND credited_salesrep_id = cl.credited_salesrep_id
			       AND credited_comp_group_id = l_log.comp_group_id
                   AND org_id = cl.org_id
			       AND created_during = 'ROLL')
	       AND cl.commission_line_id IN (SELECT MIN(commission_line_id)
					     FROM cn_commission_lines_all
					     WHERE credited_salesrep_id = l_log.salesrep_id
					     AND credited_comp_group_id = l_log.comp_group_id
					     AND processed_period_id = l_log.period_id
					     AND processed_date BETWEEN l_log.start_date AND l_log.end_date
					     AND created_during = 'POP'
                         AND org_id = l_org_id
					     GROUP BY commission_header_id);

	     FOR line IN revert_lines_delete_dest3(l_log.salesrep_id,l_log.comp_group_id,l_log.period_id,l_log.start_date,
						   l_log.end_date,l_log.role_id)
	       LOOP
		  revert_posting_line(line.commission_line_id);
	       END LOOP;

	       DELETE cn_commission_lines_all cl
		 WHERE cl.credited_salesrep_id = l_log.salesrep_id
		 AND cl.credited_comp_group_id = l_log.comp_group_id
		 AND cl.direct_salesrep_id <> l_log.salesrep_id
		 AND cl.processed_period_id = l_log.period_id
		 AND cl.processed_date BETWEEN l_log.start_date AND l_log.end_date
         AND cl.org_id = l_org_id
		 and not exists (select 1
				 from cn_srp_comp_groups_v
				 where comp_group_id = l_log.comp_group_id
				 and salesrep_id = cl.credited_salesrep_id
				 and cl.processed_date between start_date_active and nvl(end_date_active, cl.processed_date)
				 and manager_flag = 'Y'
                 and org_id = cl.org_id)
		 and exists( select 1
			     from cn_srp_comp_groups_v
			     where comp_group_id = l_log.comp_group_id
			     and salesrep_id = cl.direct_salesrep_id
			     and cl.processed_date between start_date_active and nvl(end_date_active, cl.processed_date)
                 and org_id = cl.org_id);
	END IF;
     END LOOP;

     -- handle reverts here.
     FOR l_log IN l_log_rep_periods_csr LOOP
	IF l_log.revert_state = 'POP' THEN
	   -- 1). delete 'UNPOSTED' and created_during 'CALC'
	   DELETE cn_commission_lines_all line
	     WHERE line.credited_salesrep_id = l_log.salesrep_id
	     AND line.processed_period_id = l_log.period_id
	     AND line.quota_id = l_log.quota_id
	     AND line.processed_date BETWEEN l_log.start_date AND l_log.end_date
	     AND line.trx_type NOT IN ('FORECAST', 'BONUS')
	     AND line.status <> 'OBSOLETE'
	     AND ( line.posting_status IS NULL OR line.posting_status <> 'POSTED' )
	     AND line.created_during = 'CALC';

	   -- 2).take care the following case
	   --    posted either created_during 'CALC' or not
	   --    or unposted and not creadted_during 'CALC'
	   --      ignore 'XPOP' trx here because after repopulating its factor
	   ---            it is still 'XPOP'.
	   FOR l_line IN l_pop_lines_csr( l_log.salesrep_id, l_log.period_id,
					  l_log.start_date, l_log.end_date,
					  l_log.quota_id                     ) LOOP
	     IF l_line.posting_status = 'POSTED' THEN
		revert_posting_line ( l_line.commission_line_id);
     END IF;
	   END LOOP;

          DELETE FROM cn_commission_lines_all
             WHERE credited_salesrep_id = l_log.salesrep_id
             AND processed_period_id = l_log.period_id
             AND quota_id = l_log.quota_id
             AND processed_date BETWEEN l_log.start_date AND l_log.end_date
             AND trx_type NOT IN ('FORECAST', 'BONUS')
             AND status <> 'OBSOLETE'
             AND created_during = 'CALC';

           UPDATE cn_commission_lines_all
             SET status = 'POP',  -- and more
             posting_status = 'UNPOSTED',
             event_factor = NULL,
             payment_factor = NULL,
             quota_factor = NULL,
             commission_amount = NULL,
             rate_tier_id = NULL,
             commission_rate = NULL,
             tier_split = NULL,
             input_achieved = NULL,
             output_achieved = NULL,
             perf_achieved = NULL,
             error_reason = NULL,
             srp_payee_assign_id = NULL,
             threshold_check_status = NULL,
             last_update_date = sysdate,
             last_updated_by = g_last_updated_by,
             last_update_login = g_last_update_login
             WHERE credited_salesrep_id = l_log.salesrep_id
             AND processed_period_id = l_log.period_id
             AND quota_id = l_log.quota_id
             AND processed_date BETWEEN l_log.start_date AND l_log.end_date
             AND trx_type NOT IN ('FORECAST', 'BONUS')
             AND status NOT IN ('XPOP', 'OBSOLETE');

	 ELSIF l_log.revert_state = 'ROLL' THEN
	   -- 1). delete trx created during 'POP', 'CALC' and  'UNPOSTED'
	   DELETE cn_commission_lines_all line
	     WHERE line.credited_salesrep_id = l_log.salesrep_id
	     AND line.processed_period_id = l_log.period_id
	     AND line.processed_date BETWEEN l_log.start_date AND l_log.end_date
	     AND line.trx_type NOT IN ('FORECAST', 'BONUS')
	     AND line.status <> 'OBSOLETE'
	     AND ( line.posting_status IS NULL OR line.posting_status <> 'POSTED')
	     AND line.created_during IN ('POP','CALC')
         AND line.org_id = l_org_id;

	   -- 2). take care the following case
	   --   posted either created_during 'CALC', 'POP' or not
	   --   or unposted and not creadted_during 'CALC', 'POP'
	   FOR l_line IN l_roll_lines_csr ( l_log.salesrep_id, l_log.period_id,
					    l_log.start_date, l_log.end_date    )
	     LOOP
		IF l_line.posting_status = 'POSTED' THEN
		   revert_posting_line ( l_line.commission_line_id);
		END IF;
	     END LOOP;

	     DELETE FROM cn_commission_lines_all
             WHERE credited_salesrep_id = l_log.salesrep_id
             AND processed_period_id = l_log.period_id
             AND processed_date BETWEEN l_log.start_date AND l_log.end_date
             AND trx_type NOT IN ('FORECAST', 'BONUS')
             AND status <> 'OBSOLETE'
             AND created_during in ('POP', 'CALC')
             AND org_id = l_org_id;

           UPDATE cn_commission_lines_all
             SET status = 'ROLL',  -- and more
             posting_status = 'UNPOSTED',
             event_factor = NULL,
             payment_factor = NULL,
             quota_factor = NULL,
             commission_amount = NULL,
             rate_tier_id = NULL,
             commission_rate = NULL,
             tier_split = NULL,
             input_achieved = NULL,
             output_achieved = NULL,
             perf_achieved = NULL,
             error_reason = NULL,
             srp_payee_assign_id = NULL,
             threshold_check_status = NULL,
	     srp_plan_assign_id = NULL,
	     quota_id = NULL,
	     quota_rule_id = NULL,
             last_update_date = sysdate,
             last_updated_by = g_last_updated_by,
             last_update_login = g_last_update_login
             WHERE credited_salesrep_id = l_log.salesrep_id
             AND processed_period_id = l_log.period_id
             AND processed_date BETWEEN l_log.start_date AND l_log.end_date
             AND trx_type NOT IN ('FORECAST', 'BONUS')
             AND status <> 'OBSOLETE'
             AND org_id = l_org_id;

	 ELSIF l_log.revert_state = 'CLS' THEN
	   -- 1). take care the following case
	   --   posted either created_during 'CALC', 'POP' , 'ROLL'
	   FOR l_line IN l_cls_posted_lines_csr ( l_log.salesrep_id, l_log.period_id,
						  l_log.start_date, l_log.end_date    ) LOOP
	       revert_posting_line ( l_line.commission_line_id);
	   END LOOP;

	   -- 2). delete trx created during 'ROLL' 'POP', 'CALC',
	   --    basically everything from lines table
	   DELETE cn_commission_lines_all line
	     WHERE line.org_id = l_org_id
         AND line.commission_header_id
	     IN ( SELECT header.commission_header_id
		  FROM cn_commission_headers header
		  WHERE header.direct_salesrep_id = l_log.salesrep_id
		  AND header.processed_period_id = l_log.period_id
		  AND header.processed_date BETWEEN l_log.start_date AND l_log.end_date
		  AND header.status = 'ROLL'
		  AND header.trx_type NOT IN ('FORECAST', 'BONUS')
          AND header.org_id = l_org_id );

	   -- 3). update header trx status to be 'CLS' ('CLS_SUM' if rolling up summarized trxs)
	   UPDATE cn_commission_headers_all
	     SET status = decode(parent_header_id, -1, 'CLS_SUM', 'CLS'),
	     last_update_date = sysdate,
	     last_updated_by = g_last_updated_by,
	     last_update_login = g_last_update_login
	     WHERE direct_salesrep_id = l_log.salesrep_id
	     AND processed_period_id = l_log.period_id
	     AND processed_date BETWEEN l_log.start_date AND l_log.end_date
	     AND status <> 'OBSOLETE'
	     AND status = 'ROLL'
	     AND trx_type NOT IN ('FORECAST', 'BONUS')
         AND org_id = l_org_id;
	END IF;

	IF l_log.revert_state in  ('POP', 'ROLL', 'CLS', 'COL', 'CALC') THEN
	   -- 1). delete 'ITD','GRP' trx created in commission_lines
	   FOR l_itd_grp_trx IN l_itd_grp_trx_csr ( l_log.salesrep_id,
						    l_log.period_id,
						    l_log.quota_id,
						    l_log.revert_state   )
	     LOOP
		IF l_itd_grp_trx.posting_status = 'POSTED' THEN
		   revert_posting_line( l_itd_grp_trx.commission_line_id);
		END IF;

	     END LOOP;

	     DELETE FROM cn_commission_lines_all line
             WHERE line.credited_salesrep_id =l_log.salesrep_id
             AND line.processed_period_id = l_log.period_id
             AND line.trx_type IN ('ITD', 'GRP')
             AND ((l_log.revert_state = 'POP' AND line.quota_id = l_log.quota_id) OR
                  (l_log.revert_state = 'CALC' AND (line.quota_id = l_log.quota_id or l_log.quota_id is null)) OR
                  (l_log.revert_state not in ('POP', 'CALC')))
             AND line.org_id = l_org_id;


	     -- 2). delete 'GRP' trx created in commission_headers
	     -- need to delete 'GRP' trxs in commission_header since its counterpart in line has been deleted
	     DELETE cn_commission_headers_all header
	       WHERE header.direct_salesrep_id = l_log.salesrep_id
	       --AND header.processed_date BETWEEN l_log.start_date AND l_log.end_date
	       AND header.processed_period_id = l_log.period_id
	       AND header.trx_type IN ('ITD', 'GRP')
	       AND ((l_log.revert_state = 'POP' AND header.quota_id = l_log.quota_id) OR
                (l_log.revert_state = 'CALC' AND (header.quota_id = l_log.quota_id or l_log.quota_id is null)) OR
                (l_log.revert_state not in ('POP', 'CALC')))
           AND header.org_id = l_org_id;

	END IF;

     END LOOP;
  EXCEPTION
     WHEN OTHERS THEN
		if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                         'cn.plsql.cn_formula_common_pkg.revert_batch_intel_comm.exception',
		       		     sqlerrm);
        end if;
	cn_message_pkg.debug('Exception occurs in reversing transactions: ');
	cn_message_pkg.debug(sqlerrm );
	RAISE;
  END revert_batch_intel_comm;

  --   do non intelligent revert. revert every system generated trxs
  --   this procedure will handle both 'FORECAST' and 'COMMISSION' type calculation bonus trx type is handled in different procedure
  PROCEDURE Revert_Batch_nonintel(p_batch_id cn_process_batches.physical_batch_id%TYPE,
				  p_calc_type cn_calc_submission_batches.calc_type%TYPE) IS
     CURSOR l_post_lines_csr IS
	SELECT line.commission_line_id
	  FROM cn_commission_lines_all line,
	  cn_process_batches_all       batch
	  WHERE batch.physical_batch_id = p_batch_id
      AND line.org_id = batch.org_id
	  AND line.credited_salesrep_id = batch.salesrep_id
	  AND line.status = 'CALC'
	  AND line.posting_status = 'POSTED'
	  AND line.processed_period_id BETWEEN batch.period_id AND batch.end_period_id
	  AND line.processed_date BETWEEN batch.start_date AND batch.end_date
	  AND ( (p_calc_type = 'COMMISSION' AND line.trx_type NOT IN ('BONUS', 'FORECAST' ) )
		OR (p_calc_type ='FORECAST' AND line.trx_type = 'FORECAST') );

     CURSOR check_unique_tuple IS
	SELECT DISTINCT period_id, end_period_id, start_date, end_date
	  FROM cn_process_batches_all
	  WHERE physical_batch_id = p_batch_id;

     l_period_id NUMBER;
     l_end_period_id NUMBER;
     l_start_date DATE;
     l_end_date DATE;

     l_unique_flag VARCHAR2(1) := 'N';
     l_org_id NUMBER;

   l_user_id           NUMBER(15) := fnd_global.user_id ;
   l_resp_id           NUMBER(15) := fnd_global.resp_id ;
   l_login_id          NUMBER(15) := fnd_global.login_id ;
   l_conc_prog_id      NUMBER(15) := fnd_global.conc_program_id;
   l_conc_request_id   NUMBER(15) := fnd_global.conc_request_id;
   l_prog_appl_id      NUMBER(15) := fnd_global.prog_appl_id ;

  BEGIN
     cn_message_pkg.debug('Reversing transactions in physical batch (ID='||p_batch_id||')');

     select org_id into l_org_id
      from cn_process_batches_all
     where physical_batch_id = p_batch_id
       and rownum = 1;

     -- mark process_all_flag = 'Y'
    update cn_srp_intel_periods_all a
       set a.process_all_flag = 'Y'
     where a.org_id = l_org_id
       and a.salesrep_id in (select salesrep_id from cn_process_batches_all
                              where physical_batch_id = p_batch_id)
       and a.period_id >= (select min(period_id) from cn_process_batches_all
                                 where physical_batch_id = p_batch_id
                                   and salesrep_id = a.salesrep_id)
       and a.period_id <= (select max(end_period_id) from cn_process_batches_all
                                 where physical_batch_id = p_batch_id
                                   and salesrep_id = a.salesrep_id);

     -- create reversal of posting line
     if (fnd_profile.value('CN_PAY_BY_TRANSACTION') = 'Y') then
       FOR l_line IN l_post_lines_csr LOOP
	     revert_posting_line( l_line.commission_line_id);
       END LOOP;
     end if;


   commit;

   -- then delete all possible commisson_lines
   OPEN check_unique_tuple;
   FETCH check_unique_tuple INTO l_period_id, l_end_period_id, l_start_date, l_end_date;
   FETCH check_unique_tuple INTO l_period_id, l_end_period_id, l_start_date, l_end_date;
   IF (check_unique_tuple%notfound) THEN
 	 CLOSE check_unique_tuple;
	 l_unique_flag := 'Y';

     loop
	   DELETE /*+ index(line cn_commission_lines_n7) */  cn_commission_lines_all line
	    WHERE line.credited_salesrep_id IN (SELECT salesrep_id
                                            FROM cn_process_batches_all
                                           WHERE physical_batch_id = p_batch_id)
	      AND line.processed_period_id BETWEEN l_period_id AND l_end_period_id
	      AND line.processed_date BETWEEN l_start_date AND l_end_date
	      AND line.status <> 'OBSOLETE'
          AND line.org_id = l_org_id
	      AND ((p_calc_type ='FORECAST' AND line.trx_type = 'FORECAST')
		       OR (p_calc_type = 'COMMISSION' AND line.trx_type NOT IN ('BONUS','FORECAST')))
          and rownum < 10000;

        exit when SQL%rowcount = 0;
        commit;
      end loop;
    ELSE
	  CLOSE check_unique_tuple;
      loop
 	    DELETE cn_commission_lines_all  del_line
	     WHERE del_line.commission_line_id IN
	     (SELECT line.commission_line_id
	      FROM cn_commission_lines_all line,
	      cn_process_batches_all       batch
	      WHERE batch.physical_batch_id = p_batch_id
          AND line.org_id = batch.org_id
	      AND line.credited_salesrep_id = batch.salesrep_id
	      AND line.processed_period_id BETWEEN batch.period_id AND batch.end_period_id
	      AND line.processed_date BETWEEN batch.start_date AND batch.end_date
	      AND line.status <> 'OBSOLETE'
	      AND ((p_calc_type ='FORECAST' AND line.trx_type = 'FORECAST')
		   OR (p_calc_type = 'COMMISSION' AND line.trx_type NOT IN ('BONUS','FORECAST')) ) )
              and rownum < 10000;
       exit when SQL%rowcount = 0;
       commit;
       end loop;

     END IF;

     -- update commission header line to be reclassified
     -- also all other related fields like ????, revenue_class_id, ....
     IF p_calc_type = 'COMMISSION' THEN
  	-- need to delete 'ITD','GRP' trxs in commission_header since its counterpart in line has been deleted
	-- bonus trx are all non accumulative, so 'ITD', 'GRP' doesn't apply.
	IF (l_unique_flag = 'Y') THEN
	   delete cn_commission_headers_all ch
	     where ch.direct_salesrep_id in (select salesrep_id
                                           from cn_process_batches_all
                                          where physical_batch_id = p_batch_id)
	     and ch.processed_date between l_start_date and l_end_date
	     AND (ch.trx_type IN ('GRP', 'ITD') OR ch.parent_header_id = -1)
         and ch.org_id = l_org_id;
	 ELSE
	   DELETE cn_commission_headers_all head
	     WHERE head.commission_header_id IN
	     (  SELECT dh.commission_header_id
		FROM cn_commission_headers_all dh,
		cn_process_batches_all batch
		WHERE batch.physical_batch_id = p_batch_id
        AND dh.org_id = batch.org_id
		AND batch.salesrep_id = dh.direct_salesrep_id
		AND dh.processed_date BETWEEN batch.start_date AND batch.end_date
		AND (dh.trx_type IN ('GRP', 'ITD') OR dh.parent_header_id = -1));
	END IF;
     END IF;

     IF (l_unique_flag = 'N') THEN
	UPDATE cn_commission_headers_all up_header
	  SET status = 'COL',
	  revenue_class_id = decode(substr(pre_processed_code,1,1), 'C', NULL, revenue_class_id),
	  parent_header_id = NULL,
	  last_update_date = sysdate,
	  last_updated_by = g_last_updated_by,
	  last_update_login = g_last_update_login
	  WHERE up_header.commission_header_id IN
	  ( SELECT header.commission_header_id
	    FROM cn_commission_headers_all header,
	    cn_process_batches_all batch
	    WHERE batch.physical_batch_id = p_batch_id
	    AND batch.salesrep_id = header.direct_salesrep_id
        AND header.org_id = batch.org_id
	    AND header.status <> 'OBSOLETE'
	    AND header.processed_date BETWEEN batch.start_date AND batch.end_date
	    AND ((p_calc_type ='FORECAST' AND header.trx_type = 'FORECAST')
		 OR (p_calc_type = 'COMMISSION' AND header.trx_type NOT IN ('BONUS','FORECAST')) )  );
      ELSE
	UPDATE cn_commission_headers_all
	  SET status = 'COL',
	  revenue_class_id =  decode(substr(pre_processed_code,1,1), 'C', NULL, revenue_class_id),
	  parent_header_id = NULL,
	  last_update_date = sysdate,
	  last_updated_by = g_last_updated_by,
	  last_update_login = g_last_update_login
	  WHERE org_id = l_org_id
      AND direct_salesrep_id IN (SELECT salesrep_id
                                   FROM cn_process_batches_all
                                  WHERE physical_batch_id = p_batch_id)
	  AND processed_date BETWEEN l_start_date AND l_end_date
	  AND status <> 'OBSOLETE'
	  AND ((p_calc_type ='FORECAST' AND trx_type = 'FORECAST')
	       OR (p_calc_type = 'COMMISSION' AND trx_type NOT IN ('BONUS','FORECAST')));
     END IF;
  END Revert_Batch_nonintel;

  -- do non intelligent revert for bonus calc
  PROCEDURE Revert_Batch_nonintel_bonus(p_batch_id cn_process_batches.physical_batch_id%TYPE) IS
     l_interval_type_id  NUMBER;
     l_calc_sub_batch_id NUMBER;
     l_counter           NUMBER;
     l_org_id            NUMBER;

     CURSOR l_sub_batch_csr IS
	  SELECT calc_sub_batch_id, interval_type_id, org_id
	    FROM cn_calc_submission_batches_all
	   WHERE logical_batch_id IN (SELECT logical_batch_id
				      FROM cn_process_batches_all
				      WHERE physical_batch_id = p_batch_id
                        AND rownum = 1);

     CURSOR l_quota_count_csr IS
	  SELECT COUNT(*)
	    FROM cn_calc_sub_quotas_all
	   WHERE calc_sub_batch_id = l_calc_sub_batch_id;

     CURSOR l_post_lines IS
      select cl.commission_line_id
	    FROM cn_commission_lines_all cl,
	         cn_process_batches_all batch
	   WHERE batch.physical_batch_id = p_batch_id
	     AND batch.salesrep_id = cl.credited_salesrep_id
         and cl.org_id = l_org_id
         --and cl.processed_period_id between batch.period_id and batch.end_period_id
         and cl.processed_date between batch.start_date and batch.end_date
         and cl.status = 'CALC'
         and cl.posting_status = 'POSTED'
         and cl.trx_type = 'BONUS'
         and (exists (select 1 from cn_quotas_all
                       where quota_id = cl.quota_id
                         and (l_interval_type_id = interval_type_id or l_interval_type_id = -1003)))
         and (l_calc_sub_batch_id = -1000 or
              cl.quota_id in (select quota_id from cn_calc_sub_quotas_all
                               where calc_sub_batch_id = l_calc_sub_batch_id));

  BEGIN
     cn_message_pkg.debug('Reversing transactions in physical batch (ID='||p_batch_id||')');

     OPEN l_sub_batch_csr;
     FETCH l_sub_batch_csr INTO l_calc_sub_batch_id, l_interval_type_id, l_org_id;
     CLOSE l_sub_batch_csr;

     OPEN l_quota_count_csr;
     FETCH l_quota_count_csr INTO l_counter;
     CLOSE l_quota_count_csr;

     -- no particular bonus plan elements are specified
     IF l_counter = 0 THEN
	   l_calc_sub_batch_id := -1000;
     END IF;

     for l_post_line in l_post_lines loop
	   revert_posting_line(l_post_line.commission_line_id);
	 end loop;

	-- delete header lines
    delete from cn_commission_headers_all
     where commission_header_id in (
      select cl.commission_header_id
	    from cn_commission_lines_all cl,
	         cn_process_batches_all batch
	   where batch.physical_batch_id = p_batch_id
	     and batch.salesrep_id = cl.credited_salesrep_id
         and cl.org_id = l_org_id
         --and cl.processed_period_id between batch.period_id and batch.end_period_id
         and cl.processed_date between batch.start_date and batch.end_date
         and cl.trx_type = 'BONUS'
         and (exists (select 1 from cn_quotas_all
                       where quota_id = cl.quota_id
                         and (l_interval_type_id = interval_type_id or l_interval_type_id = -1003)))
         and (l_calc_sub_batch_id = -1000 or
              cl.quota_id in (select quota_id from cn_calc_sub_quotas_all
                               where calc_sub_batch_id = l_calc_sub_batch_id)));

	-- delete detail lines
    delete from cn_commission_lines_all
     where commission_line_id in (
      select cl.commission_line_id
	    from cn_commission_lines_all cl,
	         cn_process_batches_all batch
	   where batch.physical_batch_id = p_batch_id
	     and batch.salesrep_id = cl.credited_salesrep_id
         and cl.org_id =l_org_id
         --and cl.processed_period_id between batch.period_id and batch.end_period_id
         and cl.processed_date between batch.start_date and batch.end_date
         and cl.trx_type = 'BONUS'
         and (exists (select 1 from cn_quotas_all
                       where quota_id = cl.quota_id
                         and (l_interval_type_id = interval_type_id or l_interval_type_id = -1003)))
         and (l_calc_sub_batch_id = -1000 or
              cl.quota_id in (select quota_id from cn_calc_sub_quotas_all
                               where calc_sub_batch_id = l_calc_sub_batch_id)));
  END Revert_Batch_nonintel_bonus;


Procedure revert_batch (p_batch_id cn_process_batches.physical_batch_id%TYPE) IS
     l_intel_calc_flag  VARCHAR2(30);
     l_calc_type        VARCHAR2(30);
BEGIN

     l_intel_calc_flag := cn_calc_sub_batches_pkg.get_intel_calc_flag(p_batch_id);
     l_calc_type := cn_calc_sub_batches_pkg.get_calc_type(p_batch_id);

     IF l_calc_type = 'COMMISSION' THEN
	IF l_intel_calc_flag = 'Y' THEN
	   revert_batch_intel_comm(p_batch_id);
	 ELSE
	   revert_batch_nonintel(p_batch_id, l_calc_type);
	END IF;
      ELSIF l_calc_type = 'FORECAST' THEN
	IF l_intel_calc_flag = 'Y' THEN
	  null; --revert_batch_intel_f(p_batch_id);
	 ELSE
	   revert_batch_nonintel(p_batch_id, l_calc_type);
	END IF;
      ELSIF l_calc_type = 'BONUS' THEN
	revert_batch_nonintel_bonus(p_batch_id);
     END IF;
  EXCEPTION
     when others then
		if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                         'cn.plsql.cn_formula_common_pkg.revert_batch.exception',
		       		     sqlerrm);
        end if;

        cn_message_pkg.debug('Exception occurs in reversing transactions: ');
		cn_message_pkg.rollback_errormsg_commit(sqlerrm);
        raise;
  END revert_batch;

  --   create a new group by trx if not existed update the existing group by trx if already existed
  --   if already posted, create a reversal first
  PROCEDURE update_trx( p_trx_rec_old IN OUT NOCOPY trx_rec_type,
			p_trx_rec_new IN OUT NOCOPY trx_rec_type) IS
  BEGIN
     -- do the rounding first
     p_trx_rec_new.commission_amount := Round(Nvl(p_trx_rec_new.commission_amount,0),
					     g_ext_precision);
     p_trx_rec_new.commission_rate := Round( Nvl(p_trx_rec_new.commission_rate,0),
					    CN_GLOBAL_VAR.g_ext_precision);
     p_trx_rec_new.input_achieved := Round( Nvl(p_trx_rec_new.input_achieved,0),
					   CN_GLOBAL_VAR.g_ext_precision);
     p_trx_rec_new.output_achieved := Round( Nvl(p_trx_rec_new.output_achieved,0),
					    CN_GLOBAL_VAR.g_ext_precision);
     p_trx_rec_new.perf_achieved := Round( Nvl(p_trx_rec_new.perf_achieved,0),
					  CN_GLOBAL_VAR.g_ext_precision);
     p_trx_rec_new.rate_tier_id := Nvl( p_trx_rec_new.rate_tier_id,0);
     p_trx_rec_new.tier_split := Nvl( p_trx_rec_new.tier_split, 0) ;

     IF p_trx_rec_old.status = 'CALC' AND p_trx_rec_old.posting_status = 'POSTED' THEN
	IF p_trx_rec_new.status = 'CALC' THEN
	   IF p_trx_rec_old.commission_amount <> p_trx_rec_new.commission_amount
	     OR p_trx_rec_old.commission_rate <> p_trx_rec_new.commission_rate
	     OR p_trx_rec_old.rate_tier_id <> p_trx_rec_new.rate_tier_id
	     OR p_trx_rec_old.tier_split <> p_trx_rec_new.tier_split
	     OR p_trx_rec_old.input_achieved <> p_trx_rec_new.input_achieved
	     OR p_trx_rec_old.output_achieved <> p_trx_rec_new.output_achieved
	     OR p_trx_rec_old.perf_achieved <> p_trx_rec_new.perf_achieved
	     OR nvl(p_trx_rec_old.credit_type_id, -999999) <> p_trx_rec_new.credit_type_id
	   THEN
	      revert_posting_line(p_trx_rec_old.commission_line_id);
	   END IF;
	 ELSE  -- p_trx_rec_new.status = 'XCALC'
	   revert_posting_line( p_trx_rec_old.commission_line_id);
	END IF;
     END IF;
     UPDATE cn_commission_lines_all
       SET commission_amount = p_trx_rec_new.commission_amount,
       commission_rate = p_trx_rec_new.commission_rate,
       rate_tier_id = p_trx_rec_new.rate_tier_id,
       tier_split = p_trx_rec_new.tier_split,
       input_achieved = p_trx_rec_new.input_achieved,
       output_achieved = p_trx_rec_new.output_achieved,
       perf_achieved = p_trx_rec_new.perf_achieved,
       status = p_trx_rec_new.status,
       credit_type_id = p_trx_rec_new.credit_type_id,
       posting_status = decode(posting_status, 'REVERTED', decode(p_trx_rec_new.status, 'CALC', 'UNPOSTED', posting_status), posting_status),
       error_reason = p_trx_rec_new.error_reason,
       last_update_date = sysdate,
       last_updated_by = g_last_updated_by,
       last_update_login = g_last_update_login
       WHERE commission_line_id = p_trx_rec_old.commission_line_id;
  END update_trx;

  --   create a new trx if not existed, create a line in commission_header first
  FUNCTION check_pending_trx ( p_salesrep_id        NUMBER,
			       p_srp_plan_assign_id NUMBER,
			       p_quota_id           NUMBER,
			       p_period_id          NUMBER ) RETURN VARCHAR2 IS
     l_start_period_id NUMBER(15);
     l_counter         NUMBER := 0;

     CURSOR l_chk_pending_trx_csr IS
      SELECT 1
	    FROM cn_commission_lines_all
	    WHERE credited_salesrep_id = p_salesrep_id
	    AND srp_plan_assign_id = p_srp_plan_assign_id
	    AND quota_id = p_quota_id
	    AND processed_period_id BETWEEN l_start_period_id AND p_period_id
	    AND status = 'CALC'
	    AND created_during <> 'CALC'
	    AND pending_status = 'Y';

     l_pending_status VARCHAR2(30);
  BEGIN
     l_start_period_id := get_start_period_id(p_quota_id, p_period_id);

     OPEN l_chk_pending_trx_csr;
     FETCH l_chk_pending_trx_csr INTO l_counter;
     CLOSE l_chk_pending_trx_csr;

     IF l_counter = 0 THEN
	l_pending_status := 'N';
      ELSE
	l_pending_status := 'Y';
     END IF;

     RETURN l_pending_status;
  END check_pending_trx;

  --   create a new trx if not existed, create a line in commission_header first
  PROCEDURE create_new_trx (p_trx_rec  trx_rec_type) IS
     l_header_id NUMBER;
     l_role_id   NUMBER;
     l_org_id    NUMBER;
     l_commission_line_id number;
  BEGIN
     SELECT cn_commission_headers_s.NEXTVAL INTO l_header_id FROM dual;

     SELECT role_id, org_id INTO l_role_id, l_org_id
      FROM cn_srp_plan_assigns_all
     WHERE srp_plan_assign_id = p_trx_rec.srp_plan_assign_id;

     INSERT INTO cn_commission_headers_all
       (commission_header_id, direct_salesrep_id, processed_date,
	processed_period_id, trx_type, status, quota_id,
	last_update_date, last_updated_by, creation_date,
	created_by, last_update_login, org_id )
       VALUES
       (l_header_id, p_trx_rec.salesrep_id, p_trx_rec.processed_date ,
	p_trx_rec.processed_period_id, p_trx_rec.trx_type, 'ROLL', p_trx_rec.quota_id,
	sysdate, g_last_updated_by, g_creation_date,
	g_created_by, g_last_update_login, l_org_id);

     -- then create a line in commission_lines
     -- the pending status is determined by checking all trx in all periods?????

     INSERT INTO cn_commission_lines_all
       (commission_line_id, credited_salesrep_id, commission_header_id,
	quota_id, credit_type_id, srp_plan_assign_id, role_id, status ,
	commission_amount, commission_rate, rate_tier_id, tier_split,
	input_achieved, output_achieved,
	perf_achieved, posting_status, pending_status,
	processed_date, processed_period_id, pay_period_id,
	trx_type, created_during, error_reason,
	last_update_date, last_updated_by, creation_date,
	created_by, last_update_login, org_id )
       VALUES
       (cn_commission_lines_s.NEXTVAL, p_trx_rec.salesrep_id, l_header_id,
	p_trx_rec.quota_id, p_trx_rec.credit_type_id, p_trx_rec.srp_plan_assign_id, l_role_id, p_trx_rec.status,
	Round(Nvl(p_trx_rec.commission_amount,0), g_ext_precision),
	Round(Nvl(p_trx_rec.commission_rate,0), CN_GLOBAL_VAR.g_ext_precision ),
	Nvl(p_trx_rec.rate_tier_id, 0), Nvl(p_trx_rec.tier_split, 0),
	Round( Nvl(p_trx_rec.input_achieved, 0), CN_GLOBAL_VAR.g_ext_precision),
	Round( Nvl(p_trx_rec.output_achieved, 0), CN_GLOBAL_VAR.g_ext_precision),
	Round( Nvl(p_trx_rec.perf_achieved, 0 ), CN_GLOBAL_VAR.g_ext_precision),
	p_trx_rec.posting_status, p_trx_rec.pending_status,
	p_trx_rec.processed_date, p_trx_rec.processed_period_id,p_trx_rec.pay_period_id,
	p_trx_rec.trx_type, p_trx_rec.created_during, p_trx_rec.error_reason,
	sysdate, g_last_updated_by, g_creation_date,
	g_created_by, g_last_update_login, l_org_id)
    return commission_line_id into l_commission_line_id;

    update cn_commission_lines_all cl
       set srp_payee_assign_id = (SELECT spa.srp_payee_assign_id
			            FROM cn_srp_quota_assigns_all sqa,
			                 cn_srp_payee_assigns_all spa
			           WHERE sqa.srp_plan_assign_id = cl.srp_plan_assign_id
			             AND sqa.quota_id = cl.quota_id
			             AND nvl(spa.delete_flag, 'N') <> 'Y'
			             AND sqa.srp_quota_assign_id = spa.srp_quota_assign_id
			             AND cl.processed_date BETWEEN spa.start_date AND nvl(spa.end_date,cl.processed_date))
    where cl.commission_line_id = l_commission_line_id;

  END create_new_trx;

  --   create a new group by trx if not existed update the existing group by trx if already existed
  --   if already posted, create a reversal first
  PROCEDURE create_update_grp_trx( p_grp_trx_rec IN OUT NOCOPY trx_rec_type) IS
     l_commission_line_id   NUMBER(15);
     l_posting_status       VARCHAR2(30);
     l_existed              BOOLEAN := FALSE;

     l_header_id            NUMBER(15);

     CURSOR l_grp_trx_csr IS
	SELECT cl.commission_line_id ,cl.commission_header_id,
          -- null reversal_header_id, null reversal_flag,
	  cl.credited_salesrep_id salesrep_id,
	  cl.srp_plan_assign_id, cl.quota_id, cl.credit_type_id,
	  cl.processed_date, cl.processed_period_id,
	  cl.pay_period_id, cl.commission_amount,
	  cl.commission_rate, cl.rate_tier_id ,
	  cl.tier_split, cl.input_achieved ,
	  cl.output_achieved, cl.perf_achieved,
	  cl.posting_status, cl.pending_status,
	  cl.created_during, cl.trx_type,
	  cl.error_reason, cl.status
	  FROM cn_commission_lines cl
	  WHERE cl.credited_salesrep_id = p_grp_trx_rec.salesrep_id
	  AND cl.quota_id = p_grp_trx_rec.quota_id
	  AND cl.srp_plan_assign_id = p_grp_trx_rec.srp_plan_assign_id
	  AND cl.created_during = 'CALC'
	  AND cl.trx_type = 'GRP'
	  AND cl.processed_period_id = p_grp_trx_rec.processed_period_id;

     l_grp_trx_rec_old   trx_rec_type;
  BEGIN
     OPEN l_grp_trx_csr;
     FETCH l_grp_trx_csr INTO l_grp_trx_rec_old;

     IF l_grp_trx_csr%found THEN
	l_existed := TRUE;
     END IF;
     CLOSE l_grp_trx_csr;

     p_grp_trx_rec.pending_status := check_pending_trx( p_grp_trx_rec.salesrep_id,
							p_grp_trx_rec.srp_plan_assign_id,
							p_grp_trx_rec.quota_id,
							p_grp_trx_rec.processed_period_id );

     IF l_existed THEN -- the grp trx is already created
	update_trx( l_grp_trx_rec_old, p_grp_trx_rec );
      ELSE -- the grp trx is not created yet or has been deleted
	create_new_trx( p_grp_trx_rec);
     END IF;
  END create_update_grp_trx;

  --   create a new group by trx if not existed; update the existing group by trx if already existed
  --   if already posted, create a reversal first
  PROCEDURE create_trx( p_trx_rec IN OUT NOCOPY trx_rec_type) IS
     l_msg_count     NUMBER;
     l_msg_data      VARCHAR2(2000);
     l_return_status VARCHAR2(30);
     l_validation_status VARCHAR2(1);
     l_srp_pe_rec    cn_srp_validation_pub.srp_pe_rec_type ;
  BEGIN
	if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                         'cn.plsql.cn_formula_common_pkg.create_trx.begin',
		       		     'Within create_trx.');
    end if;

    cn_message_pkg.debug('Creating or updating system-generated transaction ');

    IF p_trx_rec.trx_type = 'GRP' THEN
	create_update_grp_trx(p_trx_rec);
    ELSIF p_trx_rec.trx_type = 'ITD' THEN
	p_trx_rec.pending_status := check_pending_trx( p_trx_rec.salesrep_id,
						       p_trx_rec.srp_plan_assign_id,
						       p_trx_rec.quota_id,
						       p_trx_rec.processed_period_id );
	create_new_trx(p_trx_rec);
      ELSIF p_trx_rec.trx_type = 'BONUS' THEN
	l_srp_pe_rec.salesrep_id := p_trx_rec.salesrep_id;
	l_srp_pe_rec.quota_id := p_trx_rec.quota_id;

	IF Nvl(fnd_profile.value('CN_SRP_VALIDATION'), 'N') = 'N' THEN
	   --no need of validation
	   p_trx_rec.pending_status := 'N';
	 ELSE  -- need to validate

	   cn_srp_validation_pub.validate_pe
	     ( p_api_version => 1.0,
	       p_init_msg_list => fnd_api.g_true,
	       p_commit => fnd_api.g_false ,
	       x_return_status => l_return_status,
	       x_msg_count => l_msg_count,
	       x_msg_data => l_msg_data,
	       p_srp_pe  => l_srp_pe_rec,
	       x_validation_status => l_validation_status );

	   IF l_return_status <> FND_API.g_ret_sts_success THEN
	      p_trx_rec.error_reason := Substr( p_trx_rec.error_reason
						|| ' FAILED TO VALIDATE PENDING_STATUS.'
						, 1, 150);
	      p_trx_rec.pending_status := 'Y';
	    ELSE
	      IF l_validation_status = 'Y' THEN
		 p_trx_rec.pending_status := 'N';
	       ELSE
		 p_trx_rec.pending_status := 'Y';
	      END IF;
	   END IF;
	END IF;
	create_new_trx(p_trx_rec);
     END IF;
  EXCEPTION
    WHEN OTHERS THEN
		if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                         'cn.plsql.cn_formula_common_pkg.create_trx.exception',
		       		     sqlerrm);
        end if;

     cn_message_pkg.debug('Exception occurs in creating or updating system-generated transaction: ');
	 cn_message_pkg.debug(sqlerrm);
     RAISE;
  END create_trx ;

  --   populate the event_factor, payment_factor, quota_factor and payees
  PROCEDURE populate_factors (p_physical_batch_id NUMBER) IS
     CURSOR salesreps IS
	SELECT salesrep_id,
	  period_id,
	  end_period_id,
	  start_date,
	  end_date,
      org_id
	  FROM cn_process_batches_all
	  WHERE physical_batch_id = p_physical_batch_id;

     l_calc_type VARCHAR2(30);
  BEGIN
     l_calc_type := cn_calc_sub_batches_pkg.get_calc_type(p_physical_batch_id);

     IF (l_calc_type = 'BONUS') THEN
	RETURN;
     END IF;

     FOR salesrep IN salesreps LOOP
	UPDATE cn_commission_lines_all cl
	  SET (payment_factor,quota_factor) =
	    (SELECT squ.payment_factor/100,
				squ.quota_factor/100
		   FROM cn_srp_quota_rules_all sqr,
				cn_srp_rule_uplifts_all squ,
				cn_quota_rule_uplifts_all qru
		  WHERE sqr.srp_plan_assign_id = cl.srp_plan_assign_id
			AND sqr.quota_rule_id = cl.quota_rule_id
			AND sqr.srp_quota_rule_id = squ.srp_quota_rule_id
			AND qru.quota_rule_id = cl.quota_rule_id
			AND cl.processed_date BETWEEN qru.start_date AND Nvl(qru.end_date, cl.processed_date)
			AND qru.quota_rule_uplift_id = squ.quota_rule_uplift_id),
	      last_update_date = sysdate,
	      last_updated_by = g_last_updated_by,
	      last_update_login = g_last_update_login,
	      event_factor = (SELECT event_factor/100
		                    FROM cn_trx_factors_all tf
			               WHERE tf.quota_rule_id = cl.quota_rule_id
			                 AND tf.trx_type = cl.trx_type),
	     (srp_payee_assign_id) = (SELECT spa.srp_payee_assign_id
			                        FROM cn_srp_quota_assigns_all sqa,
                         			     cn_srp_payee_assigns_all spa
			                       WHERE sqa.srp_plan_assign_id = cl.srp_plan_assign_id
			                         AND sqa.quota_id = cl.quota_id
			                         AND nvl(spa.delete_flag, 'N') <> 'Y'
			                         AND sqa.srp_quota_assign_id = spa.srp_quota_assign_id
			                         AND cl.processed_date BETWEEN spa.start_date AND nvl(spa.end_date,cl.processed_date))
	  WHERE cl.credited_salesrep_id = salesrep.salesrep_id
	  AND cl.processed_period_id between salesrep.period_id AND salesrep.end_period_id
	  AND cl.processed_date BETWEEN salesrep.start_date AND salesrep.end_date
      AND cl.org_id = salesrep.org_id
	  AND cl.status = 'POP' -- IN ('POP', 'CALC', 'XCALC')
	  AND ((l_calc_type = 'COMMISSION'
		AND cl.trx_type NOT IN ('BONUS', 'GRP', 'FORECAST')) OR
	       (l_calc_type = 'FORECAST'
		AND cl.trx_type = 'FORECAST'));

     END LOOP;
  END populate_factors;

  FUNCTION check_itd_calc_trx ( p_salesrep_id         NUMBER,
				p_srp_plan_assign_id  NUMBER,
				p_period_id           NUMBER,
				p_quota_id            NUMBER  ) RETURN BOOLEAN IS
     CURSOR l_itd_calc_trx_csr IS
	SELECT 1
	    FROM cn_commission_lines_all
	    WHERE credited_salesrep_id = p_salesrep_id
	    AND srp_plan_assign_id = p_srp_plan_assign_id
	    AND processed_period_id = p_period_id
	    AND quota_id = p_quota_id
	    AND status = 'CALC';

     l_counter NUMBER := 0;
  BEGIN
     OPEN l_itd_calc_trx_csr;
     FETCH l_itd_calc_trx_csr INTO l_counter;
     CLOSE l_itd_calc_trx_csr;

     IF l_counter = 0 THEN
	RETURN FALSE;
      ELSE
	RETURN TRUE;
     END IF;
  END check_itd_calc_trx;

  FUNCTION get_pq_itd_target ( p_period_id NUMBER,
			       p_quota_id  NUMBER  ) RETURN NUMBER IS
     CURSOR l_itd_target_csr IS
	SELECT pq.itd_target
	  FROM cn_period_quotas_all pq
	  WHERE pq.period_id = p_period_id
	  AND pq.quota_id = p_quota_id;

     x_itd_target   NUMBER := 0;
  BEGIN
     OPEN l_itd_target_csr;
     FETCH l_itd_target_csr INTO x_itd_target;
     CLOSE l_itd_target_csr;

     RETURN x_itd_target;
  END get_pq_itd_target;


  FUNCTION get_spq_itd_target (p_salesrep_id        NUMBER,
			       p_srp_plan_assign_id NUMBER,
			       p_period_id          NUMBER,
			       p_quota_id           NUMBER  ) RETURN NUMBER IS
     CURSOR l_itd_target_csr IS
	SELECT spq.itd_target
	  FROM cn_srp_period_quotas_all spq
	  WHERE spq.period_id = p_period_id
	  AND spq.quota_id = p_quota_id
	  AND spq.salesrep_id = p_salesrep_id
	  AND spq.srp_plan_assign_id = p_srp_plan_assign_id;

     x_itd_target   NUMBER := 0;
  BEGIN
     OPEN l_itd_target_csr;
     FETCH l_itd_target_csr INTO x_itd_target;
     CLOSE l_itd_target_csr;

     RETURN x_itd_target;
  END get_spq_itd_target;


  FUNCTION get_pq_itd_payment ( p_period_id NUMBER,
			       p_quota_id  NUMBER  ) RETURN NUMBER IS
     CURSOR l_itd_payment_csr IS
	SELECT pq.itd_payment
	  FROM cn_period_quotas_all pq
	  WHERE pq.period_id = p_period_id
	  AND pq.quota_id = p_quota_id;

     x_itd_payment   NUMBER := 0;
  BEGIN
     OPEN l_itd_payment_csr;
     FETCH l_itd_payment_csr INTO x_itd_payment;
     CLOSE l_itd_payment_csr;

     RETURN x_itd_payment;
  END get_pq_itd_payment;


  FUNCTION get_spq_itd_payment (p_salesrep_id        NUMBER,
			       p_srp_plan_assign_id NUMBER,
			       p_period_id          NUMBER,
			       p_quota_id           NUMBER  ) RETURN NUMBER IS
     CURSOR l_itd_payment_csr IS
	SELECT spq.itd_payment
	  FROM cn_srp_period_quotas_all spq
	  WHERE spq.period_id = p_period_id
	  AND spq.quota_id = p_quota_id
	  AND spq.salesrep_id = p_salesrep_id
	  AND spq.srp_plan_assign_id = p_srp_plan_assign_id;

     x_itd_payment   NUMBER := 0;
  BEGIN
     OPEN l_itd_payment_csr;
     FETCH l_itd_payment_csr INTO x_itd_payment;
     CLOSE l_itd_payment_csr;

     RETURN x_itd_payment;
  END get_spq_itd_payment;
END cn_formula_common_pkg;

/
