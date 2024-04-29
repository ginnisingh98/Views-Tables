--------------------------------------------------------
--  DDL for Package Body CN_UPGRADE_PE_FORMULA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_UPGRADE_PE_FORMULA_PKG" AS
/* $Header: cnuppefb.pls 120.2 2005/09/19 11:47:42 ymao noship $ */
   api_fail                      EXCEPTION;

   PROCEDURE get_formula_name (
      p_quota_id                 IN       NUMBER,
      x_formula_name             OUT NOCOPY VARCHAR2
   )
   IS
      CURSOR l_quota_csr
      IS
         SELECT *
           FROM cn_quotas_all
          WHERE quota_id = p_quota_id;

      l_quota                       cn_quotas_all%ROWTYPE;
      l_formula_name                VARCHAR2 (30) := '';
   BEGIN
      OPEN l_quota_csr;

      FETCH l_quota_csr
       INTO l_quota;

      CLOSE l_quota_csr;

      SELECT    DECODE (l_quota.quota_type_code,
                        'REVENUE', 'RNQ',
                        'TARGET', 'RQ',
                        'UNIT_BASED_QUOTA', 'UQ',
                        'UNIT_BASED_NON_QUOTA', 'UNQ',
                        'DISCOUNT', 'DIS',
                        'MARGIN', 'MR'
                       )
             || '_'
             || DECODE (l_quota.trx_group_code, 'INDIVIDUAL', 'In', 'GROUP', 'Gr', 'In')
             || '_'
             || DECODE (l_quota.discount_option_code, 'NONE', 'DiN', 'QUOTA', 'DiQ', 'PAYMENT', 'DiP', 'DiN')
             || '_'
             || DECODE (l_quota.payment_type_code, 'FIXED', 'Fix', 'PAYMENT', 'Pay', 'TRANSACTION', 'App', '')
             || '_'
             || DECODE (l_quota.cumulative_flag, 'Y', 'CuY', 'N', 'CuN', 'CuN')
             || '_'
             || DECODE (l_quota.split_flag, 'Y', 'SY', 'N', 'SN', 'SN')
             || '_'
             || DECODE (l_quota.itd_flag, 'Y', 'IY', 'N', 'IN', 'IN')
             || '_'
             || TO_CHAR (l_quota.org_id)
        INTO l_formula_name
        FROM DUAL;

      x_formula_name := l_formula_name;
   END get_formula_name;

   FUNCTION get_perf_measure (
      p_name                              VARCHAR2,
      p_org_id                            NUMBER
   )
      RETURN NUMBER
   IS
      CURSOR measure IS
         SELECT calc_sql_exp_id
           FROM cn_calc_sql_exps_all
          WHERE NAME = p_name
		    AND ORG_ID = p_org_id;

      l_perf_measure_id             NUMBER;
      l_return_status               VARCHAR2 (1);
      l_msg_count                   NUMBER;
      l_msg_data                    VARCHAR2 (2000);
      l_status                      VARCHAR2 (30);
      l_sql_select                  VARCHAR2 (500);
      l_exp_type_code               VARCHAR2 (30);
      l_ovn                         NUMBER;
   BEGIN
      OPEN measure;

      FETCH measure INTO l_perf_measure_id;
      IF (measure%NOTFOUND) THEN
         CLOSE measure;

         SELECT DECODE (p_name,
                        'Revenue', 'ch.transaction_amount',
                        'Quantity', 'ch.quantity',
                        'Discount Percentage/100', 'ch.discount_percentage/100',
                        'Margin Percentage/100', 'ch.margin_percentage/100',
                        'ch.transaction_amount'
                       )
           INTO l_sql_select
           FROM DUAL;

         cn_calc_sql_exps_pvt.create_expression (p_api_version                => 1.0,
                                                 p_org_id                     => p_org_id,
                                                 p_name                       => p_name,
                                                 p_description                => p_name,
                                                 p_expression_disp            => UPPER (p_name),
                                                 p_sql_select                 => UPPER (l_sql_select),
                                                 p_sql_from                   => 'CN_COMMISSION_HEADERS CH',
                                                 p_piped_expression_disp      => '(' || UPPER (p_name) || ')' || '|',
                                                 p_piped_sql_select           => '(' || UPPER (l_sql_select) || ')' || '|',
                                                 p_piped_sql_from             => 'CN_COMMISSION_HEADERS CH|',
                                                 x_calc_sql_exp_id            => l_perf_measure_id,
                                                 x_exp_type_code              => l_exp_type_code,
                                                 x_status                     => l_status,
                                                 x_return_status              => l_return_status,
                                                 x_msg_count                  => l_msg_count,
                                                 x_msg_data                   => l_msg_data,
                                                 x_object_version_number      => l_ovn
                                                );

         IF (l_return_status <> fnd_api.g_ret_sts_success)
         THEN
            FOR i IN 1 .. l_msg_count
            LOOP
               NULL; -- dbms_output.put_line('msg: ' || fnd_msg_pub.get(i, 'F'));
            END LOOP;

            RAISE api_fail;
         END IF;
      ELSE
         CLOSE measure;
      END IF;

      RETURN l_perf_measure_id;
   END get_perf_measure;

   PROCEDURE get_calc_expression (
      p_org_id                            NUMBER,
      p_exp_name                          VARCHAR2,
      p_sql_select                        VARCHAR2,
      p_sql_from                          VARCHAR2,
      p_disp                              VARCHAR2,
      p_piped_sql_from                    VARCHAR2,
      x_calc_sql_exp_id          OUT NOCOPY NUMBER
   )
   IS
      CURSOR expr IS
         SELECT calc_sql_exp_id
           FROM cn_calc_sql_exps_all
          WHERE NAME = p_exp_name
		    AND ORG_ID = p_org_id;

      l_return_status               VARCHAR2 (1);
      l_msg_count                   NUMBER;
      l_msg_data                    VARCHAR2 (2000);
      l_status                      VARCHAR2 (30);
      l_exp_type_code               VARCHAR2 (30);
      l_ovn                         NUMBER;
   BEGIN
      OPEN expr;
      FETCH expr INTO x_calc_sql_exp_id;
      IF (expr%NOTFOUND) THEN
         CLOSE expr;

         cn_calc_sql_exps_pvt.create_expression (p_api_version                => 1.0,
                                                 p_org_id                     => p_org_id,
                                                 p_name                       => p_exp_name,
                                                 p_description                => p_exp_name,
                                                 p_expression_disp            => p_disp,
                                                 p_sql_select                 => p_sql_select,
                                                 p_sql_from                   => p_sql_from,
                                                 p_piped_expression_disp      => '(' || p_disp || ')' || '|',
                                                 p_piped_sql_select           => '(' || p_sql_select || ')|',
                                                 p_piped_sql_from             => p_piped_sql_from,
                                                 x_calc_sql_exp_id            => x_calc_sql_exp_id,
                                                 x_exp_type_code              => l_exp_type_code,
                                                 x_status                     => l_status,
                                                 x_return_status              => l_return_status,
                                                 x_msg_count                  => l_msg_count,
                                                 x_msg_data                   => l_msg_data,
                                                 x_object_version_number      => l_ovn
                                                );

         IF (l_return_status <> fnd_api.g_ret_sts_success)
         THEN
            FOR i IN 1 .. l_msg_count
            LOOP
               NULL; -- dbms_output.put_line('msg: ' || fnd_msg_pub.get(i, 'F'));
            END LOOP;

            RAISE api_fail;
         END IF;
      ELSE
         CLOSE expr;
      END IF;
   END get_calc_expression;

   FUNCTION get_input (
      p_name                              VARCHAR2,
      p_org_id                            NUMBER
   )
      RETURN NUMBER
   IS
      CURSOR input IS
         SELECT calc_sql_exp_id
           FROM cn_calc_sql_exps_all
          WHERE NAME = p_name
		    and org_id = p_org_id;

      l_calc_sql_exp_id             NUMBER;
      l_return_status               VARCHAR2 (1);
      l_msg_count                   NUMBER;
      l_msg_data                    VARCHAR2 (2000);
      l_status                      VARCHAR2 (30);
      l_exp_type_code               VARCHAR2 (30);
      l_ovn                         NUMBER;
   BEGIN
      OPEN input;
      FETCH input INTO l_calc_sql_exp_id;
      IF (input%NOTFOUND) THEN
         CLOSE input;

         cn_calc_sql_exps_pvt.create_expression (p_api_version                => 1.0,
                                                 p_org_id                     => p_org_id,
                                                 p_name                       => p_name,
                                                 p_description                => p_name,
                                                 p_expression_disp            => UPPER (p_name),
                                                 p_sql_select                 => 'CH.DISCOUNT_PERCENTAGE/100',
                                                 p_sql_from                   => 'CN_COMMISSION_HEADERS CH',
                                                 p_piped_expression_disp      => '(' || UPPER (p_name) || ')' || '|',
                                                 p_piped_sql_select           => '(CH.DISCOUNT_PERCENTAGE/100)|',
                                                 p_piped_sql_from             => 'CN_COMMISSION_HEADERS CH|',
                                                 x_calc_sql_exp_id            => l_calc_sql_exp_id,
                                                 x_exp_type_code              => l_exp_type_code,
                                                 x_status                     => l_status,
                                                 x_return_status              => l_return_status,
                                                 x_msg_count                  => l_msg_count,
                                                 x_msg_data                   => l_msg_data,
                                                 x_object_version_number      => l_ovn
                                                );

         IF (l_return_status <> fnd_api.g_ret_sts_success)  THEN
            FOR i IN 1 .. l_msg_count
            LOOP
               NULL;   -- dbms_output.put_line('msg: ' || fnd_msg_pub.get(i, 'F'));
            END LOOP;

            RAISE api_fail;
         END IF;
      ELSE
         CLOSE input;
      END IF;

      RETURN l_calc_sql_exp_id;
   END get_input;

   FUNCTION get_output (
      p_name                              VARCHAR2,
      p_org_id                            NUMBER
   )
      RETURN NUMBER
   IS
      CURSOR output IS
         SELECT calc_sql_exp_id
           FROM cn_calc_sql_exps_all
          WHERE NAME = p_name
		  and org_id = p_org_id;

      l_calc_sql_exp_id             NUMBER;
      l_return_status               VARCHAR2 (1);
      l_msg_count                   NUMBER;
      l_msg_data                    VARCHAR2 (2000);
      l_status                      VARCHAR2 (30);
      l_exp_type_code               VARCHAR2 (30);
      l_ovn                         NUMBER;
   BEGIN
      OPEN output;
      FETCH output INTO l_calc_sql_exp_id;
      IF (output%NOTFOUND) THEN
         CLOSE output;

         cn_calc_sql_exps_pvt.create_expression (p_api_version                => 1.0,
                                                 p_org_id                     => p_org_id,
                                                 p_name                       => p_name,
                                                 p_description                => p_name,
                                                 p_expression_disp            => 'RateResult',
                                                 p_sql_select                 => 'RateResult',
                                                 p_sql_from                   => 'DUAL',
                                                 p_piped_expression_disp      => 'RateResult|',
                                                 p_piped_sql_select           => 'RateResult|',
                                                 p_piped_sql_from             => 'DUAL|',
                                                 x_calc_sql_exp_id            => l_calc_sql_exp_id,
                                                 x_exp_type_code              => l_exp_type_code,
                                                 x_status                     => l_status,
                                                 x_return_status              => l_return_status,
                                                 x_msg_count                  => l_msg_count,
                                                 x_msg_data                   => l_msg_data,
                                                 x_object_version_number      => l_ovn
                                                );

         IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
            FOR i IN 1 .. l_msg_count LOOP
               NULL;    -- dbms_output.put_line('msg: ' || fnd_msg_pub.get(i, 'F'));
            END LOOP;

            RAISE api_fail;
         END IF;
      ELSE
         CLOSE output;
      END IF;

      RETURN l_calc_sql_exp_id;
   END get_output;

   FUNCTION check_formula_exist (
      p_quota_id                 IN       NUMBER
   )
      RETURN NUMBER
   IS
      l_formula_name                VARCHAR2 (30);
      l_formula_id                  NUMBER (15);

      CURSOR l_formula_csr
      IS
         SELECT f.calc_formula_id
           FROM cn_calc_formulas_all f,
                cn_quotas_all q
          WHERE f.NAME = l_formula_name
		    AND q.quota_id = p_quota_id
			AND ((q.org_id = f.org_id) OR (q.org_id IS NULL AND f.org_id IS NULL));
   BEGIN
      get_formula_name (p_quota_id => p_quota_id,
	                    x_formula_name => l_formula_name);

      OPEN l_formula_csr;
      FETCH l_formula_csr INTO l_formula_id;
      IF (l_formula_csr%NOTFOUND)  THEN
         CLOSE l_formula_csr;
         RETURN NULL;
      ELSE
         CLOSE l_formula_csr;
         RETURN l_formula_id;
      END IF;
   END check_formula_exist;

   PROCEDURE create_discount_option_formula (
      p_org_id                   IN         NUMBER,
      x_formula_id               OUT NOCOPY NUMBER
   )
   IS
      l_return_status               VARCHAR2 (1);
      l_msg_count                   NUMBER;
      l_msg_data                    VARCHAR2 (1000);
      l_status                      VARCHAR2 (30);
      l_formula_status              VARCHAR2 (30);
      l_calc_formula_id             NUMBER (15);
      l_process_audit_id            NUMBER;
      l_input_tbl                   cn_calc_formulas_pvt.input_tbl_type;
   BEGIN
      l_input_tbl (1).calc_sql_exp_id := get_input ('discount_percentage/100', p_org_id);
      l_input_tbl (1).rate_dim_sequence := 1;
      cn_calc_formulas_pvt.create_formula (p_api_version                  => 1.0,
                                           p_generate_packages            => fnd_api.g_false,
                                           p_name                         => 'Discount Option Formula',
                                           p_description                  => '',
                                           p_formula_type                 => 'C',
                                           p_trx_group_code               => 'INDIVIDUAL',
                                           p_number_dim                   => 1,
                                           p_cumulative_flag              => 'N',
                                           p_itd_flag                     => 'N',
                                           p_split_flag                   => 'N',
                                           p_threshold_all_tier_flag      => 'N',
                                           p_modeling_flag                => 'N',
                                           p_perf_measure_id              => get_perf_measure ('Discount Percentage', p_org_id),
                                           p_output_exp_id                => get_output ('RateResult', p_org_id),
                                           p_input_tbl                    => l_input_tbl,
                                           p_org_id                       => p_org_id,
                                           x_calc_formula_id              => l_calc_formula_id,
                                           x_formula_status               => l_status,
                                           x_return_status                => l_return_status,
                                           x_msg_count                    => l_msg_count,
                                           x_msg_data                     => l_msg_data
                                          );

      IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
         FOR i IN 1 .. l_msg_count
         LOOP
            NULL; --dbms_output.put_line('msg: ' || fnd_msg_pub.get(i, 'F'));
         END LOOP;

         RAISE api_fail;
      END IF;

      x_formula_id := l_calc_formula_id;
      cn_formula_gen_pkg.generate_formula (p_api_version           => 1.0,
                                           x_return_status         => l_return_status,
                                           x_msg_count             => l_msg_count,
                                           x_msg_data              => l_msg_data,
                                           p_formula_id            => x_formula_id,
                                           p_org_id                => p_org_id,
                                           x_process_audit_id      => l_process_audit_id
                                          );
   END create_discount_option_formula;

   PROCEDURE create_formula_from_quota (
      p_quota_id                 IN       NUMBER,
      x_formula_id               OUT NOCOPY NUMBER,
      x_return_status            OUT NOCOPY VARCHAR2
   )
   IS
      l_return_status               VARCHAR2 (1);
      l_msg_count                   NUMBER;
      l_msg_data                    VARCHAR2 (1000);
      l_status                      VARCHAR2 (30);
      l_discount_formula_id         NUMBER (15);
      l_formula_name                VARCHAR2 (30);
      l_calc_formula_id             NUMBER (15);
      l_input_exp_id                NUMBER (15);
      l_output_exp_id               NUMBER (15);
      l_exp_name                    VARCHAR2 (30);
      l_sql_select                  VARCHAR (500);
      l_sql_from                    VARCHAR2 (500);
      l_piped_sql_from              VARCHAR2 (500);
      l_exp_disp                    VARCHAR2 (500);
      l_input_tbl                   cn_calc_formulas_pvt.input_tbl_type;
      l_perf_measure_name           VARCHAR2 (80);

      CURSOR l_quota_csr
      IS
         SELECT *
           FROM cn_quotas_all
          WHERE quota_id = p_quota_id;

      l_quota                       cn_quotas_all%ROWTYPE;

      CURSOR l_discount_option_csr(p_org_id number)
      IS
         SELECT calc_formula_id
           FROM cn_calc_formulas_all
          WHERE NAME = 'Discount Option Formula'
		    AND org_id = p_org_id;
   BEGIN
      OPEN l_quota_csr;
      FETCH l_quota_csr INTO l_quota;
      CLOSE l_quota_csr;

--      IF l_quota.org_id IS NOT NULL THEN
--         fnd_client_info.set_org_context (l_quota.org_id);
--      END IF;

      get_formula_name (p_quota_id => p_quota_id, x_formula_name => l_formula_name);

      SELECT DECODE (l_quota.quota_type_code,
                     'TARGET', 'Revenue',
                     'REVENUE', 'Revenue',
                     'UNIT_BASED_QUOTA', 'Quantity',
                     'UNIT_BASED_NON_QUOTA', 'Quantity',
                     'DISCOUNT', 'Discount Percentage',
                     'MARGIN', 'Margin Percentage',
                     'Revenue'
                    )
        INTO l_perf_measure_name
        FROM DUAL;

      IF l_quota.quota_type_code = 'TARGET'
      THEN
         IF l_quota.itd_flag = 'Y'
         THEN
            l_sql_select := 'CH.TRANSACTION_AMOUNT/CSPQ.ITD_TARGET';
            l_sql_from := 'CN_COMMISSION_HEADERS CH, CN_SRP_PERIOD_QUOTAS CSPQ';
            l_piped_sql_from := 'CN_COMMISSION_HEADERS CH|CN_SRP_PERIOD_QUOTAS CSPQ|';
            l_exp_disp := 'TRANSACTION_AMOUNT/ITD_TARGET';
            l_exp_name := 'TRX_AMOUNT/ITD_TARGET';
         ELSE
            l_sql_select := 'CH.TRANSACTION_AMOUNT/CSQA.TARGET';
            l_sql_from := 'CN_COMMISSION_HEADERS CH, CN_SRP_QUOTA_ASSIGNS CSQA';
            l_piped_sql_from := 'CN_COMMISSION_HEADERS CH|CN_SRP_QUOTA_ASSIGNS CSQA|';
            l_exp_disp := 'TRANSACTION_AMOUNT/TARGET';
            l_exp_name := 'TRX_AMOUNT/TARGET';
         END IF;
      ELSIF l_quota.quota_type_code = 'REVENUE'
      THEN
         l_sql_select := 'CH.TRANSACTION_AMOUNT';
         l_sql_from := 'CN_COMMISSION_HEADERS CH';
         l_piped_sql_from := 'CN_COMMISSION_HEADERS CH|';
         l_exp_disp := 'TRANSACTION_AMOUNT';
         l_exp_name := 'TRX_AMOUNT';
      ELSIF l_quota.quota_type_code = 'UNIT_BASED_QUOTA'
      THEN
         l_sql_select := 'CH.QUANTITY/CSQA.TARGET';
         l_sql_from := 'CN_COMMISSION_HEADERS CH, CN_SRP_QUOTA_ASSIGNS CSQA';
         l_piped_sql_from := 'CN_COMMISSION_HEADERS CH|CN_SRP_QUOTA_ASSIGNS CSQA|';
         l_exp_disp := 'QUANTITY/TARGET';
         l_exp_name := 'QUANTITY/TARGET';
      ELSIF l_quota.quota_type_code = 'UNIT_BASED_NON_QUOTA'
      THEN
         l_sql_select := 'CH.QUANTITY';
         l_sql_from := 'CN_COMMISSION_HEADERS CH';
         l_exp_disp := 'QUANTITY';
         l_exp_name := 'QUANTITY';
      ELSIF l_quota.quota_type_code = 'DISCOUNT'
      THEN
         l_sql_select := 'CH.DISCOUNT_PERCENTAGE/100';
         l_sql_from := 'CN_COMMISSION_HEADERS CH';
         l_piped_sql_from := 'CN_COMMISSION_HEADERS CH|';
         l_exp_disp := 'DISCOUNT_PERCENTAGE/100';
         l_exp_name := 'DISCOUNT';
      ELSIF l_quota.quota_type_code = 'MARGIN'
      THEN
         l_sql_select := 'CH.MARGIN_PERCENTAGE/100';
         l_sql_from := 'CN_COMMISSION_HEADERS CH';
         l_piped_sql_from := 'CN_COMMISSION_HEADERS CH|';
         l_exp_disp := 'MARGIN_PERCENTAGE/100';
         l_exp_name := 'MARGIN';
      END IF;

      l_sql_select := l_sql_select || '*CL.EVENT_FACTOR*CL.QUOTA_FACTOR';
      l_sql_from := l_sql_from || ', CN_COMMISSION_LINES CL';
      l_piped_sql_from := l_piped_sql_from || 'CN_COMMISSION_LINES CL|';
      l_exp_disp := l_exp_disp || '*EVENT_FACTOR*QUOTA_FACTOR';

      -- Handle discount option
      IF l_quota.discount_option_code <> 'NONE'
      THEN
         OPEN l_discount_option_csr(l_quota.org_id);
         FETCH l_discount_option_csr INTO l_discount_formula_id;
         IF l_discount_option_csr%NOTFOUND THEN
            create_discount_option_formula (l_quota.org_id, l_discount_formula_id);
         END IF;
         CLOSE l_discount_option_csr;
      END IF;

      IF l_quota.discount_option_code = 'QUOTA'
      THEN
         l_sql_select :=
                l_sql_select || '*cn_formula_' || ABS (l_discount_formula_id) || '_' || ABS (l_quota.org_id)
                || '_pkg.get_result(p_commission_line_id)';
         l_exp_disp := l_exp_disp || '*Discount Option Formula';
         l_exp_name := l_exp_name || '_Disc';
      END IF;

      IF l_quota.trx_group_code = 'GROUP'
      THEN
         l_sql_select := 'SUM(' || l_sql_select || ')';
         l_exp_disp := 'SUM(' || l_exp_disp || ')';
         l_exp_name := 'SUM(' || l_exp_name || ')';
      END IF;

      get_calc_expression (l_quota.org_id,
	                       l_exp_name,
						   l_sql_select,
						   l_sql_from,
						   l_exp_disp,
						   l_piped_sql_from,
						   l_input_exp_id);
      -- Building output
      l_sql_select := 'RateResult';
      l_sql_from := 'CN_COMMISSION_LINES CL';
      l_piped_sql_from := 'CN_COMMISSION_LINES CL|';
      l_exp_disp := 'RateResult';
      l_exp_name := 'Rate';

      IF l_quota.payment_type_code = 'FIXED'
      THEN
         IF l_quota.quota_type_code IN ('UNIT_BASED_QUOTA', 'UNIT_BASED_NON_QUOTA')
         THEN
            IF (l_quota.trx_group_code = 'GROUP')
            THEN
               l_sql_select := l_sql_select || '*ABS(SUM(CH.QUANTITY))/SUM(CH.QUANTITY)';
               l_exp_disp := l_exp_disp || '*ABS(SUM(QUANTITY))/SUM(QUANTITY)';
               l_exp_name := l_exp_name || '*SumQSign';
            ELSE
               l_sql_select := l_sql_select || '*CL.PAYMENT_FACTOR*ABS(CH.QUANTITY)/CH.QUANTITY';
               l_exp_disp := l_exp_disp || '*PAYMENT_FACTOR*ABS(QUANTITY)/QUANTITY';
               l_exp_name := l_exp_name || '*QSign';
            END IF;

            l_sql_from := l_sql_from || ', CN_COMMISSION_HEADERS CH';
            l_piped_sql_from := l_piped_sql_from || 'CN_COMMISSION_HEADERS CH|';
         ELSIF l_quota.quota_type_code IN ('TARGET', 'REVENUE')
         THEN
            IF (l_quota.trx_group_code = 'GROUP')
            THEN
               l_sql_select := l_sql_select || '*ABS(SUM(CH.TRANSACTION_AMOUNT))/SUM(CH.TRANSACTION_AMOUNT)';
               l_exp_disp := l_exp_disp || '*ABS(SUM(TRANSACTION_AMOUNT))/SUM(TRANSACTION_AMOUNT)';
               l_exp_name := l_exp_name || '*SumRSign';
            ELSE
               l_sql_select := l_sql_select || '*CL.PAYMENT_FACTOR*ABS(CH.TRANSACTION_AMOUNT)/CH.TRANSACTION_AMOUNT';
               l_exp_disp := l_exp_disp || '*PAYMENT_FACTOR*ABS(TRANSACTION_AMOUNT)/TRANSACTION_AMOUNT';
               l_exp_name := l_exp_name || '*RSign';
            END IF;

            l_sql_from := l_sql_from || ', CN_COMMISSION_HEADERS CH';
            l_piped_sql_from := l_piped_sql_from || 'CN_COMMISSION_HEADERS CH|';
         END IF;
      ELSIF l_quota.payment_type_code = 'PAYMENT'
      THEN
-- l_sql_select := l_sql_select || '*CSQA.PAYMENT_AMOUNT';
         l_sql_from := l_sql_from || ', CN_SRP_QUOTA_ASSIGNS CSQA';
         l_piped_sql_from := l_piped_sql_from || 'CN_SRP_QUOTA_ASSIGNS CSQA|';
         l_exp_disp := l_exp_disp || '*PAYMENT_AMOUNT';
         l_exp_name := l_exp_name || '*Payment';

         IF l_quota.quota_type_code IN ('UNIT_BASED_QUOTA', 'UNIT_BASED_NON_QUOTA')
         THEN
            IF (l_quota.trx_group_code = 'GROUP')
            THEN
               l_sql_select := l_sql_select || '*ABS(SUM(CSQA.PAYMENT_AMOUNT*CH.QUANTITY))/SUM(CH.QUANTITY)';
               l_exp_disp := l_exp_disp || '*ABS(SUM(QUANTITY))/SUM(QUANTITY)';
               l_exp_name := l_exp_name || '*SumQSign';
            ELSE
               l_sql_select := l_sql_select || '*CSQA.PAYMENT_AMOUNT*CL.PAYMENT_FACTOR*ABS(CH.QUANTITY)/CH.QUANTITY';
               l_exp_disp := l_exp_disp || '*PAYMENT_FACTOR*ABS(QUANTITY)/QUANTITY';
               l_exp_name := l_exp_name || '*QSign';
            END IF;

            l_sql_from := l_sql_from || ', CN_COMMISSION_HEADERS CH';
            l_piped_sql_from := l_piped_sql_from || 'CN_COMMISSION_HEADERS CH|';
         ELSIF l_quota.quota_type_code IN ('REVENUE', 'TARGET')
         THEN
            IF (l_quota.trx_group_code = 'GROUP')
            THEN
               l_sql_select := l_sql_select || '*ABS(SUM(CSQA.PAYMENT_AMOUNT*CH.TRANSACTION_AMOUNT))/SUM(CH.TRANSACTION_AMOUNT)';
               l_exp_disp := l_exp_disp || '*ABS(SUM(TRANSACTION_AMOUNT))/SUM(TRANSACTION_AMOUNT)';
               l_exp_name := l_exp_name || '*SumRSign';
            ELSE
               l_sql_select := l_sql_select || '*CSQA.PAYMENT_AMOUNT*CL.PAYMENT_FACTOR*ABS(CH.TRANSACTION_AMOUNT)/CH.TRANSACTION_AMOUNT';
               l_exp_disp := l_exp_disp || '*PAYMENT_FACTOR*ABS(TRANSACTION_AMOUNT)/TRANSACTION_AMOUNT';
               l_exp_name := l_exp_name || '*RSign';
            END IF;

            l_sql_from := l_sql_from || ', CN_COMMISSION_HEADERS CH';
            l_piped_sql_from := l_piped_sql_from || 'CN_COMMISSION_HEADERS CH|';
         END IF;
      ELSIF l_quota.payment_type_code = 'TRANSACTION'
      THEN
         IF (l_quota.trx_group_code = 'GROUP')
         THEN
            IF (l_quota.discount_option_code = 'PAYMENT')
            THEN
               l_sql_select :=
                     l_sql_select
                  || '*SUM(CL.PAYMENT_FACTOR*CH.TRANSACTION_AMOUNT*cn_formula_'
                  || ABS (l_discount_formula_id)
                  || '_'
                  || ABS (l_quota.org_id)
                  || '_pkg.get_result(p_commission_line_id))';
               l_exp_disp := l_exp_disp || '*SUM(PAYMENT_FACTOR*TRANSACTION_AMOUNT*Discount Option Formula)';
               l_exp_name := l_exp_name || '*SUM(TRX_AMOUNT_Disc)';
            ELSE
               l_sql_select := l_sql_select || '*SUM(CL.PAYMENT_FACTOR*CH.TRANSACTION_AMOUNT)';
               l_exp_disp := l_exp_disp || '*SUM(PAYMENT_FACTOR*TRANSACTION_AMOUNT)';
               l_exp_name := l_exp_name || '*SUM(TRX_AMOUNT)';
            END IF;
         ELSE
            l_sql_select := l_sql_select || '*CL.PAYMENT_FACTOR*CH.TRANSACTION_AMOUNT';
            l_exp_disp := l_exp_disp || '*PAYMENT_FACTOR*TRANSACTION_AMOUNT';
            l_exp_name := l_exp_name || '*TRX_AMOUNT';
         END IF;

         l_sql_from := l_sql_from || ', CN_COMMISSION_HEADERS CH';
         l_piped_sql_from := l_piped_sql_from || 'CN_COMMISSION_HEADERS CH|';
      END IF;

      IF (l_quota.discount_option_code = 'PAYMENT' AND (l_quota.payment_type_code <> 'TRANSACTION' OR l_quota.trx_group_code <> 'GROUP'))
      THEN
         l_sql_select :=
                l_sql_select || '*cn_formula_' || ABS (l_discount_formula_id) || '_' || ABS (l_quota.org_id)
                || '_pkg.get_result(p_commission_line_id)';
         l_exp_disp := l_exp_disp || '*Discount Option Formula';
         l_exp_name := l_exp_name || '_Disc';
      END IF;

      get_calc_expression (l_quota.org_id,
	                       l_exp_name,
						   l_sql_select,
						   l_sql_from,
						   l_exp_disp,
						   l_piped_sql_from,
						   l_output_exp_id);
      l_input_tbl (1).calc_sql_exp_id := l_input_exp_id;
      l_input_tbl (1).rate_dim_sequence := 1;
      cn_calc_formulas_pvt.create_formula (p_api_version                  => 1.0,
                                           p_generate_packages            => fnd_api.g_false,
                                           p_name                         => l_formula_name,
                                           p_description                  => '',
                                           p_formula_type                 => 'C',
                                           p_trx_group_code               => l_quota.trx_group_code,
                                           p_number_dim                   => 1,
                                           p_cumulative_flag              => l_quota.cumulative_flag,
                                           p_itd_flag                     => l_quota.itd_flag,
                                           p_split_flag                   => l_quota.split_flag,
                                           p_threshold_all_tier_flag      => 'N',
                                           p_modeling_flag                => 'N',
                                           p_perf_measure_id              => get_perf_measure (l_perf_measure_name, l_quota.org_id),
                                           p_output_exp_id                => l_output_exp_id,
                                           p_input_tbl                    => l_input_tbl,
                                           p_org_id                       => l_quota.org_id,
                                           x_calc_formula_id              => l_calc_formula_id,
                                           x_formula_status               => l_status,
                                           x_return_status                => l_return_status,
                                           x_msg_count                    => l_msg_count,
                                           x_msg_data                     => l_msg_data
                                          );

      IF (l_return_status <> fnd_api.g_ret_sts_success)
      THEN
         FOR i IN 1 .. l_msg_count
         LOOP
            NULL;  --dbms_output.put_line('msg: ' || fnd_msg_pub.get(i, 'F'));
         END LOOP;

         RAISE api_fail;
      END IF;

      x_formula_id := l_calc_formula_id;
      x_return_status := l_return_status;
   END create_formula_from_quota;

   PROCEDURE get_formula_id (
      p_quota_id                 IN       NUMBER,
      x_formula_id               OUT NOCOPY NUMBER,
      x_return_status            OUT NOCOPY VARCHAR2
   )
   IS
      CURSOR l_quota_csr IS
         SELECT *
           FROM cn_quotas_all
          WHERE quota_id = p_quota_id;

      l_quota                       cn_quotas_all%ROWTYPE;
   BEGIN
      x_return_status := 'S';

      OPEN l_quota_csr;
      FETCH l_quota_csr INTO l_quota;
      CLOSE l_quota_csr;

      IF l_quota.quota_type_code IN ('REVENUE', 'TARGET', 'UNIT_BASED_QUOTA', 'UNIT_BASED_NON_QUOTA', 'DISCOUNT', 'MARGIN')
      THEN
         x_formula_id := check_formula_exist (p_quota_id);

         IF x_formula_id IS NULL THEN
            create_formula_from_quota (p_quota_id => p_quota_id, x_formula_id => x_formula_id, x_return_status => x_return_status);
         END IF;
      ELSIF l_quota.quota_type_code IN ('MANUAL', 'DRAW') THEN
         -- non formula type
         x_formula_id := NULL;
      ELSE
         -- Invalid quota_type_code
         x_formula_id := NULL;
         x_return_status := 'E';
      END IF;
   END get_formula_id;
END cn_upgrade_pe_formula_pkg;

/
