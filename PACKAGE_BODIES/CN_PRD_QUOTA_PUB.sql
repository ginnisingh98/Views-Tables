--------------------------------------------------------
--  DDL for Package Body CN_PRD_QUOTA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PRD_QUOTA_PUB" AS
  /*$Header: cnvpedbb.pls 120.2.12000000.2 2007/10/11 02:55:12 rnagired ship $*/

G_PKG_NAME                  CONSTANT VARCHAR2(30):='CN_PRD_QUOTA_PUB';

   PROCEDURE distribute_target (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_quota_id                 IN       NUMBER,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Distribute_Target';
      l_api_version        CONSTANT NUMBER := 1.0;

      CURSOR period_quotas (
         l_interval_number                   NUMBER,
         l_period_year                       NUMBER
      )
      IS
         SELECT   spq.period_quota_id,
                  spq.period_id,
                  spq.quota_id,
                  spq.quarter_num,
                  spq.period_year
             FROM cn_period_quotas spq,
                  cn_acc_period_statuses_v cp,
                  cn_cal_per_int_types cpit,
                  cn_quotas cq
            WHERE spq.quota_id = p_quota_id
              AND spq.quota_id = cq.quota_id
              AND spq.period_id = cp.period_id
              AND cp.period_id = cpit.cal_period_id
              AND cpit.interval_type_id = cq.interval_type_id
              AND cpit.interval_number = l_interval_number
              AND spq.period_year = l_period_year
         ORDER BY spq.period_id;

      pq_rec                        period_quotas%ROWTYPE;

      -- Get the period quotas that belong to the quota assignment for each
      -- interval
      CURSOR interval_counts
      IS
         SELECT   COUNT (spq.period_quota_id) interval_count,
                  cpit.interval_number interval_number,
                  spq.period_year period_year
             FROM cn_period_quotas spq,
                  cn_acc_period_statuses_v cp,
                  cn_cal_per_int_types cpit,
                  cn_quotas cq
            WHERE spq.quota_id = p_quota_id
              AND spq.quota_id = cq.quota_id
              AND spq.period_id = cp.period_id
              AND cp.period_id = cpit.cal_period_id
              AND cpit.interval_type_id = cq.interval_type_id
         GROUP BY cpit.interval_number,
                  spq.period_year;

      interval_rec                  interval_counts%ROWTYPE;
      l_period_count                NUMBER;
      l_running_total_target        NUMBER;
      l_total_periods               NUMBER;
      l_period_target               NUMBER;
      l_running_total_payment       NUMBER;
      l_period_payment              NUMBER;
      l_running_performance_goal    NUMBER;
      l_performance_goal            NUMBER;
      l_srp_quota_assign_id         NUMBER (15);
      l_quota_target                NUMBER;
      l_quota_payment               NUMBER;
      l_quota_performance_goal      NUMBER;
      l_dist_rule_code              VARCHAR2 (30);
      l_period_type_code            VARCHAR2 (30);
      l_period_performance_goal     NUMBER;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT get_prd_quota_year;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      -- API body
      SELECT NVL (q.target, 0),
             NVL (q.payment_amount, 0),
             NVL (q.performance_goal, 0)
                                        --,qa.period_target_dist_rule_code
      ,
             cn_chk_plan_element_pkg.get_interval_name (q.interval_type_id,q.org_id) period_type_code
        INTO l_quota_target,
             l_quota_payment,
             l_performance_goal
                               --,l_dist_rule_code
      ,
             l_period_type_code
        FROM cn_quotas q
       WHERE q.quota_id = p_quota_id
                                    --AND qa.period_target_dist_rule_code <> 'USER_DEFINED'
      ;

      -- Currently this is the only distribution rule we support
      FOR interval_rec IN interval_counts
      LOOP
         -- Initialize for each interval
         l_period_count := 0;
         l_running_total_target := 0;
         l_period_target := 0;
         l_running_total_payment := 0;
         l_period_payment := 0;
         l_running_performance_goal := 0;
         l_period_performance_goal := 0;

         -- Now that we know the counts per quarter/year we can divide the
         -- quota target correctly for each quarter and set the period quota
         -- target.
         FOR pq_rec IN period_quotas (l_interval_number => interval_rec.interval_number, l_period_year => interval_rec.period_year)
         LOOP
            l_period_count := l_period_count + 1;
            l_period_target := ((l_quota_target * (l_period_count / interval_rec.interval_count)) - l_running_total_target);
            l_running_total_target := l_running_total_target + l_period_target;
            l_period_payment := ((l_quota_payment * (l_period_count / interval_rec.interval_count)) - l_running_total_payment);
            l_running_total_payment := l_running_total_payment + l_period_payment;
            l_period_performance_goal := ((l_performance_goal * (l_period_count / interval_rec.interval_count)) - l_running_performance_goal);
            l_running_performance_goal := l_running_performance_goal + l_period_performance_goal;
             /*  UPDATE cn_srp_period_quotas
            SET
            target_amount  = round(nvl(l_period_target, 0), g_ext_precision),
            itd_target     = round(nvl(l_running_total_target,0), g_ext_precision),
            period_payment = round(nvl(l_period_payment,0), g_ext_precision),
            itd_payment    = round(nvl(l_running_total_payment,0), g_ext_precision),
            performance_goal_ptd = round(nvl(l_period_performance_goal,0), g_ext_precision),
            performance_goal_itd = round(nvl(l_running_performance_goal,0),g_ext_precision)
            WHERE srp_period_quota_id = pq_rec.period_quota_id
            ;*/
            cn_period_quotas_pkg.begin_record (x_operation              => 'UPDATE',
                                               x_period_quota_id        => pq_rec.period_quota_id,
                                               x_period_id              => pq_rec.period_id,
                                               x_quota_id               => pq_rec.quota_id,
                                               x_period_target          => NVL (l_period_target, 0),
                                               x_itd_target             => NVL (l_running_total_target, 0),
                                               x_period_payment         => NVL (l_period_payment, 0),
                                               x_itd_payment            => NVL (l_running_total_payment, 0),
                                               x_quarter_num            => pq_rec.quarter_num,
                                               x_period_year            => pq_rec.period_year,
                                               x_creation_date          => SYSDATE,
                                               x_last_update_date       => SYSDATE,
                                               x_last_update_login      => fnd_global.login_id,
                                               x_last_updated_by        => fnd_global.user_id,
                                               x_created_by             => fnd_global.user_id,
                                               x_period_type_code       => 'PERIOD',
                                               x_performance_goal       => NVL (l_period_performance_goal, 0)
                                              );
         END LOOP;
      END LOOP;

      -- End of API body.
      -- Standard check of p_commit.
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO get_prd_quota_year;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO get_prd_quota_year;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO get_prd_quota_year;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END distribute_target;


PROCEDURE Distribute_Prd_Quota
(       p_api_version              IN   NUMBER   := CN_API.G_MISS_NUM,
        p_init_msg_list            IN   VARCHAR2 := CN_API.G_FALSE,
        p_commit                   IN   VARCHAR2 := CN_API.G_FALSE,
        p_validation_level         IN   NUMBER   := CN_API.G_VALID_LEVEL_FULL,
        p_pe_name                  IN   CN_QUOTAS.NAME%TYPE,
        p_target_amount            IN   CN_QUOTAS.target%TYPE,
        p_fixed_amount            IN   CN_QUOTAS.payment_amount%TYPE,
        p_performance_goal         IN   CN_QUOTAS.performance_goal%TYPE,
        p_even_distribute          IN   VARCHAR2,
        p_prd_quota_tbl            IN   prd_quota_tbl_type,
        p_org_id		   IN   NUMBER,
        x_return_status            OUT NOCOPY VARCHAR2,
        x_msg_count                OUT NOCOPY NUMBER,
        x_msg_data                 OUT NOCOPY VARCHAR2

  ) IS

     l_api_name           CONSTANT VARCHAR2(30)  := 'Distribute_Prd_Quota';
     l_api_version        CONSTANT NUMBER        := 1.0;

     l_quota_id           CN_QUOTAS.quota_id%TYPE;

     tbl_period_id        CN_PERIOD_STATUSES.period_id%TYPE;

     tbl_period_quota_id      CN_PERIOD_QUOTAS.period_quota_id%TYPE;

     tbl_quarter_num      CN_PERIOD_QUOTAS.quarter_num%TYPE;

     tbl_period_year      CN_PERIOD_QUOTAS.period_year%TYPE;

     l_prd_count          NUMBER;

     f_target_amount      CN_QUOTAS.target%TYPE;
     f_fixed_amount       CN_QUOTAS.payment_amount%TYPE;
     f_performance_goal   CN_QUOTAS.performance_goal%TYPE;

     G_LAST_UPDATE_DATE          DATE    := sysdate;
     G_LAST_UPDATED_BY           NUMBER  := fnd_global.user_id;
     G_CREATION_DATE             DATE    := sysdate;
     G_CREATED_BY                NUMBER  := fnd_global.user_id;
     G_LAST_UPDATE_LOGIN         NUMBER  := fnd_global.login_id;

     G_ROWID                     VARCHAR2(30);
     G_PROGRAM_TYPE              VARCHAR2(30);

      l_org_id NUMBER;
      l_status VARCHAR2(1);

      CURSOR l_quota_id_cr (p_quota_name VARCHAR2) IS
      SELECT *
      from cn_quotas
      where name = p_quota_name
      AND   org_id = l_org_id;

      CURSOR l_prd_quota_cr(p_quota_id NUMBER) IS
	  SELECT period_quota_id, quarter_num, period_year, period_id, itd_target, itd_payment, performance_goal_itd
	  FROM cn_period_quotas
	  WHERE quota_id = p_quota_id;


      CURSOR f_quota_row(p_quota_id NUMBER) IS
      SELECT *
      from cn_quotas
      where quota_id = p_quota_id;

      CURSOR l_period_id_cr(p_period_name VARCHAR2) IS
      select *
      from cn_period_statuses
      where period_name = p_period_name
      and   org_id = l_org_id;

      CURSOR tbl_period_quota_info_cr(p_period_id NUMBER, p_quota_id NUMBER) IS
      select *
      from cn_period_quotas
      where quota_id = p_quota_id
      and period_id = p_period_id;

      f_quota_row_rec     CN_QUOTAS%ROWTYPE;
      f_quota_id_rec      CN_QUOTAS%ROWTYPE;
      f_period_id_rec     CN_PERIOD_STATUSES%ROWTYPE;
      f_period_quota_info_rec   CN_PERIOD_QUOTAS%ROWTYPE;


BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Distribute_Prd_Quota;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
     (l_api_version           ,
     p_api_version           ,
     l_api_name              ,
     G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- API body

   -- 1. IF the PE concerned exists.

   IF  p_pe_name IS NULL
   THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	FND_MESSAGE.SET_NAME ('CN' , 'CN_INPUT_CANT_NULL');
    FND_MESSAGE.SET_TOKEN('INPUT_NAME', cn_api.get_lkup_meaning('PE_NAME', 'INPUT_TOKEN'));
	FND_MSG_PUB.Add;
     END IF;
     RAISE FND_API.G_EXC_ERROR ;
   END IF;


   -- Validate and default org id

   l_org_id := p_org_id;
   mo_global.validate_orgid_pub_api(org_id => l_org_id, status => l_status);

   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
	       'cn.plsql.CN_PRD_QUOTA_PUB.Distribute_Prd_Quota.org_validate',
		    'Validated org_id = ' || l_org_id || ' status = '|| l_status);
   end if;


   -- Get the Quota ID if exist


   OPEN l_quota_id_cr(p_pe_name);
   FETCH l_quota_id_cr into f_quota_id_rec;

   IF (l_quota_id_cr%NOTFOUND)
     THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	FND_MESSAGE.SET_NAME ('CN' , 'CN_PLN_NOT_EXIST');
    FND_MESSAGE.SET_TOKEN ('PE_NAME' , p_pe_name);
	FND_MSG_PUB.Add;
     END IF;
     RAISE FND_API.G_EXC_ERROR ;
   END IF;

   CLOSE l_quota_id_cr;

   l_quota_id := f_quota_id_rec.quota_id;


   select nvl(target, 0)
   into f_target_amount
   from cn_quotas
   where quota_id = l_quota_id;


   -- 2. If target_amount, fixed_amount and Performance Goal input is null, select from cn_quotas, else update cn_quotas
   -- target_amount check and update
   IF p_target_amount is NULL THEN


      select nvl(target, 0)
      into f_target_amount
      from cn_quotas
      where quota_id = l_quota_id;

   ELSE



       IF p_target_amount <> f_target_amount THEN


          f_target_amount := p_target_amount;

          OPEN f_quota_row(l_quota_id);
          FETCH f_quota_row INTO f_quota_row_rec;
          CLOSE f_quota_row;


            cn_quotas_pkg.begin_record
	(
	 x_operation              => 'UPDATE'
	 ,x_rowid                 => G_ROWID
	 ,x_quota_id              => f_quota_row_rec.quota_id
	 ,x_name                  => f_quota_row_rec.name
	 ,x_object_version_number => f_quota_row_rec.object_version_number
	 ,x_target                => f_target_amount
	 ,x_quota_type_code       => f_quota_row_rec.quota_type_code
	 ,x_usage_code            => NULL
	 ,x_payment_amount	  => f_quota_row_rec.payment_amount
	 ,x_description           => f_quota_row_rec.description
	 ,x_start_date		  => f_quota_row_rec.start_date
	 ,x_end_date		  => f_quota_row_rec.end_date
	 ,x_quota_status		  => f_quota_row_rec.quota_status
         ,x_calc_formula_id       => f_quota_row_rec.calc_formula_id
         ,x_incentive_type_code   => f_quota_row_rec.incentive_type_code
	 ,x_credit_type_id        => f_quota_row_rec.credit_type_id
	 ,x_rt_sched_custom_flag  => f_quota_row_rec.rt_sched_custom_flag
	 ,x_package_name          => f_quota_row_rec.package_name
	 ,x_performance_goal      => f_quota_row_rec.performance_goal
         ,x_interval_type_id	  => f_quota_row_rec.interval_type_id
         ,x_payee_assign_flag     => f_quota_row_rec.payee_assign_flag
         ,x_vesting_flag	  => f_quota_row_rec.vesting_flag
         ,x_expense_account_id    => f_quota_row_rec.expense_account_id
         ,x_liability_account_id  => f_quota_row_rec.liability_account_id
	 ,x_quota_group_code	  => f_quota_row_rec.quota_group_code
         ,x_quota_unspecified     => NULL
	 ,x_last_update_date      => G_LAST_UPDATE_DATE
	 ,x_last_updated_by       => G_LAST_UPDATED_BY
	 ,x_creation_date         => G_CREATION_DATE
	 ,x_created_by            => G_CREATED_BY
	 ,x_last_update_login     => G_LAST_UPDATE_LOGIN
	 ,x_program_type          => G_PROGRAM_TYPE
	 --,x_status_code           => NULL
	 ,x_period_type_code      => NULL
	 ,x_start_num             => NULL
	 ,x_end_num	          => NULL
	 ,x_addup_from_rev_class_flag => f_quota_row_rec.addup_from_rev_class_flag
         ,x_attribute1            => f_quota_row_rec.attribute1
         ,x_attribute2            => f_quota_row_rec.attribute2
         ,x_attribute3            => f_quota_row_rec.attribute3
         ,x_attribute4            => f_quota_row_rec.attribute4
         ,x_attribute5            => f_quota_row_rec.attribute5
         ,x_attribute6            => f_quota_row_rec.attribute6
         ,x_attribute7            => f_quota_row_rec.attribute7
  	 ,x_attribute8            => f_quota_row_rec.attribute8
	 ,x_attribute9            => f_quota_row_rec.attribute9
         ,x_attribute10           => f_quota_row_rec.attribute10
         ,x_attribute11           => f_quota_row_rec.attribute11
         ,x_attribute12           => f_quota_row_rec.attribute12
         ,x_attribute13           => f_quota_row_rec.attribute13
         ,x_attribute14           => f_quota_row_rec.attribute14
         ,x_attribute15           => f_quota_row_rec.attribute15
         ,x_payment_group_code    => 'STANDARD'
	 ,x_indirect_credit => f_quota_row_rec.indirect_credit
         ,x_org_id=> f_quota_row_rec.org_id
         ,x_salesrep_end_flag => f_quota_row_rec.salesreps_enddated_flag
	);

       END IF;
   END IF;


   select nvl(payment_amount, 0)
   into f_fixed_amount
   from cn_quotas
   where quota_id = l_quota_id;

   -- fixed Amount check and update
      IF p_fixed_amount is NULL THEN


      select nvl(payment_amount, 0)
      into f_fixed_amount
      from cn_quotas
      where quota_id = l_quota_id;

   ELSE




       IF p_fixed_amount <> nvl(f_fixed_amount,0) THEN



          f_fixed_amount := p_fixed_amount;

          OPEN f_quota_row(l_quota_id);
          FETCH f_quota_row INTO f_quota_row_rec;
          CLOSE f_quota_row;

            cn_quotas_pkg.begin_record
	(
	 x_operation              => 'UPDATE'
	 ,x_rowid                 => G_ROWID
	 ,x_quota_id              => f_quota_row_rec.quota_id
	 ,x_name                  => f_quota_row_rec.name
	 ,x_object_version_number => f_quota_row_rec.object_version_number
	 ,x_target                => f_quota_row_rec.target
	 ,x_quota_type_code       => f_quota_row_rec.quota_type_code
	 ,x_usage_code            => NULL
	 ,x_payment_amount	  => f_fixed_amount
	 ,x_description           => f_quota_row_rec.description
	 ,x_start_date		  => f_quota_row_rec.start_date
	 ,x_end_date		  => f_quota_row_rec.end_date
	 ,x_quota_status		  => f_quota_row_rec.quota_status
         ,x_calc_formula_id       => f_quota_row_rec.calc_formula_id
         ,x_incentive_type_code   => f_quota_row_rec.incentive_type_code
	 ,x_credit_type_id        => f_quota_row_rec.credit_type_id
	 ,x_rt_sched_custom_flag  => f_quota_row_rec.rt_sched_custom_flag
	 ,x_package_name          => f_quota_row_rec.package_name
	 ,x_performance_goal      => f_quota_row_rec.performance_goal
         ,x_interval_type_id	  => f_quota_row_rec.interval_type_id
         ,x_payee_assign_flag     => f_quota_row_rec.payee_assign_flag
         ,x_vesting_flag	  => f_quota_row_rec.vesting_flag
         ,x_expense_account_id    => f_quota_row_rec.expense_account_id
         ,x_liability_account_id  => f_quota_row_rec.liability_account_id
	 ,x_quota_group_code	  => f_quota_row_rec.quota_group_code
         ,x_quota_unspecified     => NULL
	 ,x_last_update_date      => G_LAST_UPDATE_DATE
	 ,x_last_updated_by       => G_LAST_UPDATED_BY
	 ,x_creation_date         => G_CREATION_DATE
	 ,x_created_by            => G_CREATED_BY
	 ,x_last_update_login     => G_LAST_UPDATE_LOGIN
	 ,x_program_type          => G_PROGRAM_TYPE
	 --,x_status_code           => NULL
	 ,x_period_type_code      => NULL
	 ,x_start_num             => NULL
	 ,x_end_num	          => NULL
	 ,x_addup_from_rev_class_flag => f_quota_row_rec.addup_from_rev_class_flag
         ,x_attribute1            => f_quota_row_rec.attribute1
         ,x_attribute2            => f_quota_row_rec.attribute2
         ,x_attribute3            => f_quota_row_rec.attribute3
         ,x_attribute4            => f_quota_row_rec.attribute4
         ,x_attribute5            => f_quota_row_rec.attribute5
         ,x_attribute6            => f_quota_row_rec.attribute6
         ,x_attribute7            => f_quota_row_rec.attribute7
  	 ,x_attribute8            => f_quota_row_rec.attribute8
	 ,x_attribute9            => f_quota_row_rec.attribute9
         ,x_attribute10           => f_quota_row_rec.attribute10
         ,x_attribute11           => f_quota_row_rec.attribute11
         ,x_attribute12           => f_quota_row_rec.attribute12
         ,x_attribute13           => f_quota_row_rec.attribute13
         ,x_attribute14           => f_quota_row_rec.attribute14
         ,x_attribute15           => f_quota_row_rec.attribute15
         ,x_payment_group_code    => 'STANDARD'
	 ,x_indirect_credit => f_quota_row_rec.indirect_credit
	 ,x_org_id=> f_quota_row_rec.org_id
         ,x_salesrep_end_flag => f_quota_row_rec.salesreps_enddated_flag
	);

       END IF;
   END IF;


    -- performance goal check and update

   select nvl(performance_goal, 0)
   into f_performance_goal
   from cn_quotas
   where quota_id = l_quota_id;

    IF p_performance_goal is NULL THEN

      select nvl(performance_goal, 0)
      into f_performance_goal
      from cn_quotas
      where quota_id = l_quota_id;

   ELSE
       IF p_performance_goal <> nvl(f_performance_goal,0) THEN

          f_performance_goal := p_performance_goal;

          OPEN f_quota_row(l_quota_id);
          FETCH f_quota_row INTO f_quota_row_rec;
          CLOSE f_quota_row;

            cn_quotas_pkg.begin_record
	(
	 x_operation              => 'UPDATE'
	 ,x_rowid                 => G_ROWID
	 ,x_quota_id              => f_quota_row_rec.quota_id
	 ,x_name                  => f_quota_row_rec.name
	 ,x_object_version_number => f_quota_row_rec.object_version_number
	 ,x_target                => f_quota_row_rec.target
	 ,x_quota_type_code       => f_quota_row_rec.quota_type_code
	 ,x_usage_code            => NULL
	 ,x_payment_amount	  => f_quota_row_rec.payment_amount
	 ,x_description           => f_quota_row_rec.description
	 ,x_start_date		  => f_quota_row_rec.start_date
	 ,x_end_date		  => f_quota_row_rec.end_date
	 ,x_quota_status		  => f_quota_row_rec.quota_status
         ,x_calc_formula_id       => f_quota_row_rec.calc_formula_id
         ,x_incentive_type_code   => f_quota_row_rec.incentive_type_code
	 ,x_credit_type_id        => f_quota_row_rec.credit_type_id
	 ,x_rt_sched_custom_flag  => f_quota_row_rec.rt_sched_custom_flag
	 ,x_package_name          => f_quota_row_rec.package_name
	 ,x_performance_goal      => f_performance_goal
         ,x_interval_type_id	  => f_quota_row_rec.interval_type_id
         ,x_payee_assign_flag     => f_quota_row_rec.payee_assign_flag
         ,x_vesting_flag	  => f_quota_row_rec.vesting_flag
         ,x_expense_account_id    => f_quota_row_rec.expense_account_id
         ,x_liability_account_id  => f_quota_row_rec.liability_account_id
	 ,x_quota_group_code	  => f_quota_row_rec.quota_group_code
         ,x_quota_unspecified     => NULL
	 ,x_last_update_date      => G_LAST_UPDATE_DATE
	 ,x_last_updated_by       => G_LAST_UPDATED_BY
	 ,x_creation_date         => G_CREATION_DATE
	 ,x_created_by            => G_CREATED_BY
	 ,x_last_update_login     => G_LAST_UPDATE_LOGIN
	 ,x_program_type          => G_PROGRAM_TYPE
	 --,x_status_code           => NULL
	 ,x_period_type_code      => NULL
	 ,x_start_num             => NULL
	 ,x_end_num	          => NULL
	 ,x_addup_from_rev_class_flag => f_quota_row_rec.addup_from_rev_class_flag
         ,x_attribute1            => f_quota_row_rec.attribute1
         ,x_attribute2            => f_quota_row_rec.attribute2
         ,x_attribute3            => f_quota_row_rec.attribute3
         ,x_attribute4            => f_quota_row_rec.attribute4
         ,x_attribute5            => f_quota_row_rec.attribute5
         ,x_attribute6            => f_quota_row_rec.attribute6
         ,x_attribute7            => f_quota_row_rec.attribute7
  	 ,x_attribute8            => f_quota_row_rec.attribute8
	 ,x_attribute9            => f_quota_row_rec.attribute9
         ,x_attribute10           => f_quota_row_rec.attribute10
         ,x_attribute11           => f_quota_row_rec.attribute11
         ,x_attribute12           => f_quota_row_rec.attribute12
         ,x_attribute13           => f_quota_row_rec.attribute13
         ,x_attribute14           => f_quota_row_rec.attribute14
         ,x_attribute15           => f_quota_row_rec.attribute15
         ,x_payment_group_code    => 'STANDARD'
	 ,x_indirect_credit => f_quota_row_rec.indirect_credit
	 ,x_org_id=> f_quota_row_rec.org_id
	 ,x_salesrep_end_flag => f_quota_row_rec.salesreps_enddated_flag
	);

       END IF;
   END IF;



   -- 3. if even distribute is Yes, we divide the Variables by the period number.
   IF p_even_distribute = 'Y' THEN

      -- Modified to call the Distribute_Target API to distribute target, 2527429

        Distribute_Target
  (p_api_version                 => p_api_version ,
   p_init_msg_list               => p_init_msg_list,
   p_commit                      => p_commit ,
   p_validation_level            => p_validation_level,
   p_quota_id                    => l_quota_id,
   x_return_status               => x_return_status,
   x_msg_count                   => x_msg_count,
   x_msg_data                    => x_msg_data);


    -- 4. IF not evenly distributed, we update the cn_period_quotas using the values in the table.
    ELSE --IF p_even_distribute = 'Y' THEN

      IF p_prd_quota_tbl.COUNT > 0 THEN

       FOR i IN 1 .. p_prd_quota_tbl.COUNT  LOOP



             IF  p_prd_quota_tbl(i).period_name IS NULL
               THEN
                  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	               FND_MESSAGE.SET_NAME ('CN' , 'CN_INPUT_CANT_NULL');
                   FND_MESSAGE.SET_TOKEN('INPUT_NAME', cn_api.get_lkup_meaning('PERIOD_NAME', 'INPUT_TOKEN'));
	               FND_MSG_PUB.Add;
                  END IF;
                RAISE FND_API.G_EXC_ERROR ;
              END IF;

              OPEN l_period_id_cr(p_prd_quota_tbl(i).period_name);
              FETCH l_period_id_cr into f_period_id_rec;
              IF (l_period_id_cr%NOTFOUND)
                THEN
                  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	                 FND_MESSAGE.SET_NAME ('CN' , 'CN_PERIOD_NOT_FOUND');
                   	 FND_MSG_PUB.Add;
                  END IF;
                   RAISE FND_API.G_EXC_ERROR ;
               END IF;

           CLOSE l_period_id_cr;

           tbl_period_id := f_period_id_rec.period_id;

            OPEN tbl_period_quota_info_cr(tbl_period_id, l_quota_id);
              FETCH tbl_period_quota_info_cr into f_period_quota_info_rec;
              IF (tbl_period_quota_info_cr%NOTFOUND)
                THEN
                  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	                 FND_MESSAGE.SET_NAME ('CN' , 'CN_PERIOD_QUOTA_NOT_EXIST');
                     FND_MESSAGE.SET_TOKEN ('PERIOD_NAME' , p_prd_quota_tbl(i).period_name);
                     FND_MESSAGE.SET_TOKEN ('PLAN_NAME' , p_pe_name);
                   	 FND_MSG_PUB.Add;
                  END IF;
                   RAISE FND_API.G_EXC_ERROR ;
               END IF;

           CLOSE tbl_period_quota_info_cr;

           tbl_period_quota_id := f_period_quota_info_rec.period_quota_id;
           tbl_quarter_num := f_period_quota_info_rec.quarter_num;
           tbl_period_year := f_period_quota_info_rec.period_year;




             CN_PERIOD_QUOTAS_PKG.Begin_Record(
			x_operation	=> 'UPDATE',
			X_period_quota_id => tbl_period_quota_id,
			x_period_id		 => tbl_period_id,
			x_quota_id		 => l_quota_id,
			x_period_target		 => p_prd_quota_tbl(i).PERIOD_TARGET,
			x_itd_target		 => NULL,
			x_period_payment	 => p_prd_quota_tbl(i).PERIOD_PAYMENT ,
			x_itd_payment		 => NULL,
			x_quarter_num		 => tbl_quarter_num,
			x_period_year		 => tbl_period_year,
			x_creation_date		 => sysdate,
			x_last_update_date	 => sysdate,
			x_last_update_login	 => fnd_global.login_id,
			x_last_updated_by	 => fnd_global.user_id,
			x_created_by		 => fnd_global.user_id,
			x_period_type_code	 => 'PERIOD',
			x_performance_goal       => p_prd_quota_tbl(i).PERFORMANCE_GOAL);



       END LOOP;

       END IF; --IF p_prd_quota_tbl%COUNT > 0

   END IF; --IF p_even_distribute = 'Y' THEN






   -- End of API body.
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
     p_data                   =>      x_msg_data              ,
     p_encoded                =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Distribute_Prd_Quota;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Distribute_Prd_Quota;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
     ROLLBACK TO Distribute_Prd_Quota;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     IF      FND_MSG_PUB.Check_Msg_Level
       (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg
          (G_PKG_NAME          ,
          l_api_name           );
     END IF;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
END Distribute_Prd_Quota;


END CN_PRD_QUOTA_PUB;

/
