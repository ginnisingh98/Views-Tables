--------------------------------------------------------
--  DDL for Package Body CN_SRP_PERIODS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SRP_PERIODS_PVT" AS
/* $Header: cnvsprdb.pls 120.1.12000000.2 2007/08/06 21:21:11 jxsingh ship $ */

-- Global variable
G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_SRP_PERIODS_PVT';
G_FILE_NAME                 CONSTANT VARCHAR2(12) := 'cnvsprdb.pls';

--| -----------------------------------------------------------------------+
--| Function  : Get_Pay_Period
--| Return    : DATA TYPE:TABLE OF pay_period_rec_type%TYPE
--| Desc      : Procedure to get pay period id, return null table if not found
--| -----------------------------------------------------------------------+
FUNCTION Get_Pay_Period
  (p_start_date     IN DATE,
   p_end_date       IN DATE,
   p_period_set_id  IN NUMBER,
   p_period_type_id IN NUMBER,
   p_org_id         IN NUMBER) RETURN pay_period_rec_tbl_type IS
      l_pay_period_rec_tbl  pay_period_rec_tbl_type;
      l_start_date cn_period_statuses.start_date%TYPE;
      l_end_date   cn_period_statuses.end_date%TYPE;
      l_index      NUMBER;

      CURSOR c_period_rec_csr
	( c_start_date cn_period_statuses.start_date%TYPE,
	  c_end_date   cn_period_statuses.end_date%TYPE) IS
	    SELECT period_id , start_date, end_date
	      FROM cn_period_statuses_all
	      WHERE start_date <= c_end_date
	      AND   end_date >= c_start_date
	      AND   period_type_id = p_period_type_id
	      AND   period_set_id = p_period_set_id
	      AND   org_id        = p_org_id;

BEGIN
   SELECT MIN(start_date), MAX(end_date)
     INTO l_start_date, l_end_date
     FROM cn_acc_period_statuses_v
     WHERE period_status IN ('O','F')
     AND   org_id = p_org_id
     AND   ( ( p_end_date IS NOT NULL AND start_date <= p_end_date
	       AND end_date >= p_start_date )
	     OR
	     ( p_end_date IS NULL AND end_date >= p_start_date )
	   );

   IF l_start_date < p_start_date THEN
      l_start_date := p_start_date;
   END IF;
   IF l_end_date > p_end_date THEN
      l_end_date := p_end_date;
   END IF ;

   l_index := Nvl(l_pay_period_rec_tbl.last,0) + 1;
   FOR l_period_rec_csr IN c_period_rec_csr(l_start_date,l_end_date) LOOP
      -- Get real start date/end date for this pay period
      IF l_period_rec_csr.start_date < l_start_date THEN
	 l_period_rec_csr.start_date := l_start_date;
      END IF;
      IF l_period_rec_csr.end_date > l_end_date THEN
	 l_period_rec_csr.end_date := l_end_date;
      END IF ;

      l_pay_period_rec_tbl(l_index).period_id  := l_period_rec_csr.period_id;
      l_pay_period_rec_tbl(l_index).start_date := l_period_rec_csr.start_date;
      l_pay_period_rec_tbl(l_index).end_date   := l_period_rec_csr.end_date;
      l_index := l_index + 1;
   END LOOP;

   RETURN l_pay_period_rec_tbl;

END Get_Pay_Period;

--| -----------------------------------------------------------------------+
--| Procedure : Sync_Accum_Balances_Start_Pd
--| Desc      : Procedure to update begin balance and summary records in
--|             cn_srp_periods
--| Note      : 2 prerequisite conditions:
--| 1) that periods have all been created and xtd records populated
--| 2) there exists a summary record (null quota ID) for each actual record
--| -----------------------------------------------------------------------+

PROCEDURE Sync_Accum_Balances_Start_Pd
  (p_salesrep_id            IN NUMBER,
   p_org_id                 IN NUMBER,
   p_credit_type_id         IN NUMBER,
   p_role_id                IN NUMBER,
   p_start_period_id        IN NUMBER) IS

     l_prev_pd_id        cn_period_statuses.period_id%TYPE      := -1;
     l_prev_year         cn_period_statuses.period_year%TYPE    := -1;
     l_prev_quota        cn_srp_periods.quota_id%TYPE           := -1;
     l_prev_spa          cn_srp_periods.srp_plan_assign_id%TYPE := -1;
     l_reset_balances    boolean := false;
     l_srp_period_id     number;
     l_cache_bal1_bbc    number;
     l_cache_bal1_bbd    number;
     l_cache_bal2_bbc    number;
     l_cache_bal2_bbd    number;
     l_cache_bal3_bbc    number;
     l_cache_bal3_bbd    number;
     l_cache_bal4_bbc    number;
     l_cache_bal4_bbd    number;
     l_cache_bal5_bbc    number;
     l_cache_bal5_bbd    number;

     CURSOR get_bals IS
        SELECT /*+ index (sp, CN_SRP_PERIODS_U2)*/
	      srp_period_id, sp.period_id, quota_id,
	       p.period_year, srp_plan_assign_id,
	       balance1_ctd, balance1_dtd,
	       balance1_bbc, balance1_bbd,
	       balance2_ctd, balance2_dtd,
	       balance2_bbc, balance2_bbd,
	       balance3_ctd, balance3_dtd,
  	       balance3_bbc, balance3_bbd,
	       balance4_ctd, balance4_dtd,
	       balance4_bbc, balance4_bbd,
	       balance5_ctd, balance5_dtd,
	       balance5_bbc, balance5_bbd
	  FROM cn_srp_periods_all sp, cn_period_statuses_all p
	 WHERE role_id            = p_role_id
	   AND salesrep_id        = p_salesrep_id
	   AND sp.org_id          = p_org_id
	   AND credit_type_id     = p_credit_type_id
	   AND quota_id           is not null
	   AND sp.period_id = p.period_id
	   AND sp.org_id    = p.org_id
	 ORDER BY quota_id, sp.period_id;

        CURSOR get_summ_srp_periods IS
	   select /*+ index (p2, CN_SRP_PERIODS_U2)*/
	     p1.srp_period_id, p1.period_id,
 	       nvl(sum(p2.balance1_ctd),0) balance1_ctd,
	       nvl(sum(p2.balance1_dtd),0) balance1_dtd,
	       nvl(sum(p2.balance2_ctd),0) balance2_ctd,
	       nvl(sum(p2.balance2_dtd),0) balance2_dtd,
	       nvl(sum(p2.balance3_ctd),0) balance3_ctd,
	       nvl(sum(p2.balance3_dtd),0) balance3_dtd,
	       nvl(sum(p2.balance4_ctd),0) balance4_ctd,
	       nvl(sum(p2.balance4_dtd),0) balance4_dtd,
	       nvl(sum(p2.balance5_ctd),0) balance5_ctd,
	       nvl(sum(p2.balance5_dtd),0) balance5_dtd,

               nvl(sum(p2.balance1_bbc),0) balance1_bbc,
               nvl(sum(p2.balance1_bbd),0) balance1_bbd,
               nvl(sum(p2.balance2_bbc),0) balance2_bbc,
               nvl(sum(p2.balance2_bbd),0) balance2_bbd,
               nvl(sum(p2.balance3_bbc),0) balance3_bbc,
               nvl(sum(p2.balance3_bbd),0) balance3_bbd,
               nvl(sum(p2.balance4_bbc),0) balance4_bbc,
               nvl(sum(p2.balance4_bbd),0) balance4_bbd,
               nvl(sum(p2.balance5_bbc),0) balance5_bbc,
               nvl(sum(p2.balance5_bbd),0) balance5_bbd,
	       p.period_year
	  from cn_srp_periods_all p1, cn_srp_periods_all p2,
	       cn_period_statuses_all p
	 where p1.salesrep_id    = p_salesrep_id
	   and p1.credit_type_id = p_credit_type_id
	   AND p1.org_id         = p_org_id
	   and p1.quota_id is null and p1.role_id is null
	   and p1.salesrep_id = p2.salesrep_id (+)
	   and p1.period_id = p2.period_id (+)
	   AND p1.org_id    = p2.org_id    (+)
	   and p1.period_id = p.period_id
	   and p1.credit_type_id = p2.credit_type_id (+)
	   and p2.role_id (+) is not null and p2.quota_id (+) is not null
	   AND p.org_id = p_org_id
	 group by p1.period_id, p1.srp_period_id, p.period_year
	 order by p1.period_id, p1.srp_period_id;

        cursor get_carry_bal(l_period_id number) is
        SELECT srp_period_id,
               balance1_bbd, balance1_bbc,
               balance2_bbd, balance2_bbc,
               balance3_bbd, balance3_bbc,
               balance4_bbd, balance4_bbc,
               balance5_bbd, balance5_bbc
          FROM cn_srp_periods_all sp
         WHERE role_id            = -1
	   AND salesrep_id        = p_salesrep_id
	   AND org_id             = p_org_id
           AND credit_type_id     = p_credit_type_id
           AND quota_id           = -1000
           AND period_id          = l_period_id;

        cb get_carry_bal%rowtype;

BEGIN
   -- look at profile to see if balances should be reset after each year
   if FND_PROFILE.VALUE('CN_RESET_BALANCES_EACH_YEAR') = 'Y' then
      l_reset_balances := true;
   end if;

   -- populate BBx columns
   for b in get_bals loop
      -- use previous period's BBX and XTD
      if (l_reset_balances = true AND
	  l_prev_year <> b.period_year) OR l_prev_quota <> b.quota_id
	OR l_prev_spa <> b.srp_plan_assign_id THEN
	 l_cache_bal1_bbc := 0;
	 l_cache_bal1_bbd := 0;
	 l_cache_bal2_bbc := 0;
	 l_cache_bal2_bbd := 0;
	 l_cache_bal3_bbc := 0;
	 l_cache_bal3_bbd := 0;
	 l_cache_bal4_bbc := 0;
	 l_cache_bal4_bbd := 0;
	 l_cache_bal5_bbc := 0;
	 l_cache_bal5_bbd := 0;
      end if;

      -- no need to update periods before start period
      if b.period_id >= p_start_period_id then
	 update cn_srp_periods_all
	    set balance1_bbc = l_cache_bal1_bbc,
	        balance1_bbd = l_cache_bal1_bbd,
 	        balance2_bbc = l_cache_bal2_bbc,
	        balance2_bbd = l_cache_bal2_bbd,
	        balance3_bbc = l_cache_bal3_bbc,
	        balance3_bbd = l_cache_bal3_bbd,
	        balance4_bbc = l_cache_bal4_bbc,
	        balance4_bbd = l_cache_bal4_bbd,
	        balance5_bbc = l_cache_bal5_bbc,
	        balance5_bbd = l_cache_bal5_bbd
	  where srp_period_id = b.srp_period_id;
      end if;

      l_cache_bal1_bbc := l_cache_bal1_bbc + nvl(b.balance1_ctd,0);
      l_cache_bal1_bbd := l_cache_bal1_bbd + nvl(b.balance1_dtd,0);
      l_cache_bal2_bbc := l_cache_bal2_bbc + nvl(b.balance2_ctd,0);
      l_cache_bal2_bbd := l_cache_bal2_bbd + nvl(b.balance2_dtd,0);
      l_cache_bal3_bbc := l_cache_bal3_bbc + nvl(b.balance3_ctd,0);
      l_cache_bal3_bbd := l_cache_bal3_bbd + nvl(b.balance3_dtd,0);
      l_cache_bal4_bbc := l_cache_bal4_bbc + nvl(b.balance4_ctd,0);
      l_cache_bal4_bbd := l_cache_bal4_bbd + nvl(b.balance4_dtd,0);
      l_cache_bal5_bbc := l_cache_bal5_bbc + nvl(b.balance5_ctd,0);
      l_cache_bal5_bbd := l_cache_bal5_bbd + nvl(b.balance5_dtd,0);

      l_prev_year      := b.period_year;
      l_prev_quota     := b.quota_id;
      l_prev_spa       := b.srp_plan_assign_id;
   end loop;

   l_prev_pd_id     := -1;
   l_prev_year      := -1;
   l_cache_bal1_bbc := 0;
   l_cache_bal1_bbd := 0;
   l_cache_bal2_bbc := 0;
   l_cache_bal2_bbd := 0;
   l_cache_bal3_bbc := 0;
   l_cache_bal3_bbd := 0;
   l_cache_bal4_bbc := 0;
   l_cache_bal4_bbd := 0;
   l_cache_bal5_bbc := 0;
   l_cache_bal5_bbd := 0;
   for p in get_summ_srp_periods loop
      if p.period_id >= p_start_period_id then
	 update cn_srp_periods_all
	    set balance1_ctd = p.balance1_ctd,
	        balance1_dtd = p.balance1_dtd,
	        balance2_ctd = p.balance2_ctd,
	        balance2_dtd = p.balance2_dtd,
	        balance3_ctd = p.balance3_ctd,
	        balance3_dtd = p.balance3_dtd,
	        balance4_ctd = p.balance4_ctd,
	        balance4_dtd = p.balance4_dtd,
	        balance5_ctd = p.balance5_ctd,
	        balance5_dtd = p.balance5_dtd
	  WHERE srp_period_id = p.srp_period_id;
      end if;

      if l_prev_pd_id = -1 OR
	(l_reset_balances = true AND
	 l_prev_year <> p.period_year) THEN
	 l_cache_bal1_bbc := 0;
	 l_cache_bal1_bbd := 0;
	 l_cache_bal2_bbc := 0;
	 l_cache_bal2_bbd := 0;
	 l_cache_bal3_bbc := 0;
	 l_cache_bal3_bbd := 0;
	 l_cache_bal4_bbc := 0;
	 l_cache_bal4_bbd := 0;
	 l_cache_bal5_bbc := 0;
	 l_cache_bal5_bbd := 0;
      end if;
      -- ***************************************
      -- Bug5707688 is fixed by changing > to >=
      -- ***************************************
      if p.period_id >= p_start_period_id then
	 update cn_srp_periods_all
	    SET	balance1_bbc = l_cache_bal1_bbc,
	        balance1_bbd = l_cache_bal1_bbd,
	        balance2_bbc = l_cache_bal2_bbc,
	        balance2_bbd = l_cache_bal2_bbd,
	        balance3_bbc = l_cache_bal3_bbc,
	        balance3_bbd = l_cache_bal3_bbd,
	        balance4_bbc = l_cache_bal4_bbc,
	        balance4_bbd = l_cache_bal4_bbd,
	        balance5_bbc = l_cache_bal5_bbc,
	        balance5_bbd = l_cache_bal5_bbd
	  where srp_period_id = p.srp_period_id;
      end if;

      -- update carryover balances - equal to summary bbx - sum of bbx's for
      -- detail records
      -- get srp_period_id for PE -1000
      l_srp_period_id := null;
      open  get_carry_bal(p.period_id);
      fetch get_carry_bal into cb;
      close get_carry_bal;

      update cn_srp_periods_all
         SET balance1_bbc=l_cache_bal1_bbc - p.balance1_bbc + cb.balance1_bbc,
             balance1_bbd=l_cache_bal1_bbd - p.balance1_bbd + cb.balance1_bbd,
             balance2_bbc=l_cache_bal2_bbc - p.balance2_bbc + cb.balance2_bbc,
             balance2_bbd=l_cache_bal2_bbd - p.balance2_bbd + cb.balance2_bbd,
             balance3_bbc=l_cache_bal3_bbc - p.balance3_bbc + cb.balance3_bbc,
             balance3_bbd=l_cache_bal3_bbd - p.balance3_bbd + cb.balance3_bbd,
             balance4_bbc=l_cache_bal4_bbc - p.balance4_bbc + cb.balance4_bbc,
             balance4_bbd=l_cache_bal4_bbd - p.balance4_bbd + cb.balance4_bbd,
             balance5_bbc=l_cache_bal5_bbc - p.balance5_bbc + cb.balance5_bbc,
             balance5_bbd=l_cache_bal5_bbd - p.balance5_bbd + cb.balance5_bbd
       where srp_period_id = cb.srp_period_id;

      l_cache_bal1_bbc := l_cache_bal1_bbc + p.balance1_ctd;
      l_cache_bal1_bbd := l_cache_bal1_bbd + p.balance1_dtd;
      l_cache_bal2_bbc := l_cache_bal2_bbc + p.balance2_ctd;
      l_cache_bal2_bbd := l_cache_bal2_bbd + p.balance2_dtd;
      l_cache_bal3_bbc := l_cache_bal3_bbc + p.balance3_ctd;
      l_cache_bal3_bbd := l_cache_bal3_bbd + p.balance3_dtd;
      l_cache_bal4_bbc := l_cache_bal4_bbc + p.balance4_ctd;
      l_cache_bal4_bbd := l_cache_bal4_bbd + p.balance4_dtd;
      l_cache_bal5_bbc := l_cache_bal5_bbc + p.balance5_ctd;
      l_cache_bal5_bbd := l_cache_bal5_bbd + p.balance5_dtd;
      l_prev_pd_id     := p.period_id;
      l_prev_year      := p.period_year;
   end loop;

END Sync_Accum_Balances_Start_Pd;

PROCEDURE Sync_Accum_Balances
  (p_salesrep_id            IN NUMBER,
   p_org_id                 IN NUMBER,
   p_credit_type_id         IN NUMBER,
   p_role_id                IN NUMBER) IS
BEGIN
   -- no start period given... just update all periods
   Sync_Accum_Balances_Start_Pd
     (p_salesrep_id     => p_salesrep_id,
      p_org_id          => p_org_id,
      p_credit_type_id  => p_credit_type_id,
      p_role_id         => p_role_id,
      p_start_period_id => -1);  -- no negative period ID's
END Sync_Accum_Balances;

--| -----------------------------------------------------------------------+
--| Procedure : Create_Srp_Periods
--| Desc      : Procedure to create a new row in cn_srp_periods
--| Note      : This is called by srp_pay_group_assign
--| -----------------------------------------------------------------------+
PROCEDURE Create_Srp_Periods
  (p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2,
   p_commit	        IN    VARCHAR2,
   p_validation_level   IN    NUMBER,
   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count	        OUT NOCOPY   NUMBER,
   x_msg_data	        OUT NOCOPY   VARCHAR2,
   p_salesrep_id        IN    NUMBER,
   p_role_id            IN    NUMBER,
   p_comp_plan_id       IN    NUMBER,
   p_start_date         IN    DATE,
   p_end_date           IN    DATE,
   p_sync_flag          IN    VARCHAR2,
   x_loading_status     OUT NOCOPY   VARCHAR2
   ) IS
BEGIN
   Create_Srp_Periods_Per_Quota
     (p_api_version        => p_api_version,
      p_init_msg_list      => p_init_msg_list,
      p_commit             => p_commit,
      p_validation_level   => p_validation_level,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_salesrep_id        => p_salesrep_id,
      p_role_id            => p_role_id,
      p_comp_plan_id       => p_comp_plan_id,
      p_quota_id           => NULL,  -- do for all quotas
      p_start_date         => p_start_date,
      p_end_date           => p_end_date,
      p_sync_flag          => p_sync_flag,
      x_loading_status     => x_loading_status);
END Create_Srp_Periods;

--| -----------------------------------------------------------------------+
--| Procedure : Create_Srp_Periods_Per_Quota
--| Desc      : Procedure to create a new row in cn_srp_periods for a new quota
--| Note      : This is called by srp_pay_group_assign
--| -----------------------------------------------------------------------+
PROCEDURE Create_Srp_Periods_Per_Quota
  (p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2,
   p_commit             IN    VARCHAR2,
   p_validation_level   IN    NUMBER,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count          OUT NOCOPY  NUMBER,
   x_msg_data           OUT NOCOPY  VARCHAR2,
   p_salesrep_id        IN    NUMBER,
   p_role_id            IN    NUMBER,
   p_comp_plan_id       IN    NUMBER,
   p_quota_id           IN    NUMBER,
   p_start_date         IN    DATE,
   p_end_date           IN    DATE,
   p_sync_flag          IN    VARCHAR2,
   x_loading_status     OUT NOCOPY  VARCHAR2
   ) IS
      l_api_name     CONSTANT VARCHAR2(30) := 'Create_Srp_Periods';
      l_api_version  CONSTANT NUMBER  := 1.0;

      l_pay_period_rec_tbl  pay_period_rec_tbl_type;
      l_srp_period_id       cn_srp_periods.srp_period_id%TYPE;
      l_min_period_id       cn_srp_periods.period_id%TYPE;
      l_dummy               NUMBER;
      l_org_id              NUMBER;
      l_pg_found            BOOLEAN;

      CURSOR c_srp_pay_grp_csr IS
	 (SELECT spg.pay_group_id, spg.start_date, spg.end_date,
	  pg.period_set_id, pg.period_type_id
	  FROM cn_srp_pay_groups_all spg,cn_pay_groups_all pg
	  WHERE spg.salesrep_id = p_salesrep_id
	  AND   spg.org_id      = l_org_id
	  AND   spg.pay_group_id = pg.pay_group_id
	  AND ( (  (p_end_date IS NOT NULL) AND (spg.end_date IS NOT NULL)
		   AND (spg.start_date <= p_end_date)
		   AND (spg.end_date >= p_start_date))
		OR ((p_end_date IS NOT NULL) AND (spg.end_date IS NULL)
		    AND (spg.start_date <= p_end_date))
		OR ((p_end_date IS NULL) AND (spg.end_date IS NOT NULL)
		    AND (spg.end_date >= p_start_date))
		OR ((p_end_date IS NULL) AND (spg.end_date IS NULL))
		)
	  ) ;

      -- if null quota ID passed in, then loop through all quotas
      CURSOR c_quota_csr IS
	 (SELECT credit_type_id, quota_id
	  FROM cn_quotas_all
	  WHERE quota_id IN
	  (SELECT quota_id FROM cn_quota_assigns
           WHERE comp_plan_id = p_comp_plan_id)
          AND quota_id = nvl(p_quota_id, quota_id));


      CURSOR get_summ_pds(c_credit_type_id cn_srp_periods.credit_type_id%TYPE) IS
      select p.period_id, p.start_date, p.end_date
	from cn_period_statuses_all p, cn_repositories_all r
       where p.period_id >= l_min_period_id
	 and r.period_type_id = p.period_type_id
	 and r.period_set_id  = p.period_set_id
	 AND p.org_id         = l_org_id
	 AND r.org_id         = l_org_id
	 and not exists (select 1 from cn_srp_periods_all
                 where salesrep_id = p_salesrep_id and period_id = p.period_id
			 and role_id is null and quota_id is NULL
			 AND org_id = l_org_id
			 AND credit_type_id = c_credit_type_id)

       order by 1;

      CURSOR get_carry_pds(c_credit_type_id cn_srp_periods.credit_type_id%TYPE) IS
      select p.period_id, p.start_date, p.end_date
        from cn_period_statuses_all p, cn_repositories_all r
       where p.period_id >= l_min_period_id
         and r.period_type_id = p.period_type_id
	 and r.period_set_id  = p.period_set_id
	 AND p.org_id         = l_org_id
	 AND r.org_id         = l_org_id
         and not exists (select 1 from cn_srp_periods_all
                 where salesrep_id = p_salesrep_id and period_id = p.period_id
                         and role_id = -1 and quota_id = -1000
			 AND org_id = l_org_id
                         AND credit_type_id = c_credit_type_id)
       order by 1;


      CURSOR get_srp_cts IS
      select distinct credit_type_id
	from cn_srp_periods_all
       where salesrep_id = p_salesrep_id
	 AND org_id = l_org_id
	 and quota_id is not null
	 and credit_type_id is not null;

      CURSOR c_get_spa(l_start_date date) IS
      select srp_plan_assign_id
	from cn_srp_plan_assigns_all
       where salesrep_id  = p_salesrep_id
	 AND org_id       = l_org_id
	 and role_id      = p_role_id
	 and comp_plan_id = p_comp_plan_id
	 and l_start_date between start_date and nvl(end_date, l_start_date);

   l_srp_pay_grp_csr     c_srp_pay_grp_csr%ROWTYPE;
   l_quota_csr           c_quota_csr%ROWTYPE;
   l_srp_plan_assign_id  cn_srp_plan_assigns.srp_plan_assign_id%TYPE;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT	Create_Srp_Periods;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     (l_api_version,p_api_version,l_api_name,g_pkg_name) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF ;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_INSERTED';

   -- API body

   -- derive org ID from comp plan ID
   SELECT org_id
     INTO l_org_id
     FROM cn_comp_plans_all
    WHERE comp_plan_id = p_comp_plan_id;

   l_pg_found := FALSE;
   OPEN c_srp_pay_grp_csr;
   LOOP
      FETCH c_srp_pay_grp_csr INTO l_srp_pay_grp_csr;
      EXIT WHEN c_srp_pay_grp_csr%NOTFOUND;

      l_pg_found := TRUE;

      IF l_srp_pay_grp_csr.start_date < p_start_date THEN
	 l_srp_pay_grp_csr.start_date := p_start_date;
      END IF;
      IF ((l_srp_pay_grp_csr.end_date IS NULL)
	  OR ((l_srp_pay_grp_csr.end_date IS NOT NULL)
	      AND (p_end_date IS NOT NULL)
	      AND (l_srp_pay_grp_csr.end_date > p_end_date))) THEN
	 l_srp_pay_grp_csr.end_date := p_end_date;
      END IF ;

      l_pay_period_rec_tbl :=
	Get_Pay_Period
	(p_start_date => l_srp_pay_grp_csr.start_date,
	 p_end_date => l_srp_pay_grp_csr.end_date,
	 p_period_set_id => l_srp_pay_grp_csr.period_set_id,
	 p_period_type_id => l_srp_pay_grp_csr.period_type_id,
	 p_org_id => l_org_id);

      OPEN c_quota_csr;
      LOOP
	 FETCH c_quota_csr INTO l_quota_csr;
	 EXIT WHEN c_quota_csr%NOTFOUND;

	 FOR i IN 1 .. l_pay_period_rec_tbl.COUNT LOOP
	    SELECT count(1) INTO l_dummy
	      FROM cn_srp_periods_all
	     WHERE salesrep_id = p_salesrep_id
	       AND org_id = l_org_id
	       AND period_id = l_pay_period_rec_tbl(i).period_id
	       AND role_id = p_role_id
	       AND quota_id = l_quota_csr.quota_id
	       AND credit_type_id = l_quota_csr.credit_type_id;

	    -- get srp_plan_assign_id
	    OPEN  c_get_spa(l_pay_period_rec_tbl(i).start_date);
	    FETCH c_get_spa INTO l_srp_plan_assign_id;
	    CLOSE c_get_spa;

	    IF  l_dummy = 0 THEN
	       cn_srp_periods_pkg.insert_row
		 (x_srp_period_id   => l_srp_period_id
		  ,x_salesrep_id    => p_salesrep_id
		  ,x_org_id         => l_org_id
		  ,x_period_id      => l_pay_period_rec_tbl(i).period_id
		  ,x_start_date     => l_pay_period_rec_tbl(i).start_date
		  ,x_end_date       => l_pay_period_rec_tbl(i).end_date
		  ,x_credit_type_id => l_quota_csr.credit_type_id
		  ,x_srp_plan_assign_id => l_srp_plan_assign_id
		  ,x_role_id        => p_role_id
		  ,x_quota_id       => l_quota_csr.quota_id
		  ,x_pay_group_id   => l_srp_pay_grp_csr.pay_group_id
		  ,x_created_by        => FND_GLOBAL.USER_ID
		  ,x_creation_date     => SYSDATE
		  ,x_last_update_date  => SYSDATE
		  ,x_last_updated_by   => FND_GLOBAL.USER_ID
		  ,x_last_update_login => FND_GLOBAL.LOGIN_ID
		  );
	     ELSE
	       -- records exist - update plan assign ID
	       update cn_srp_periods_all
		  set srp_plan_assign_id = l_srp_plan_assign_id,
		      start_date         = l_pay_period_rec_tbl(i).start_date,
                      end_date           = l_pay_period_rec_tbl(i).end_date
		where salesrep_id = p_salesrep_id
		  AND org_id = l_org_id
		  AND period_id = l_pay_period_rec_tbl(i).period_id
 		  AND role_id = p_role_id
		  AND quota_id = l_quota_csr.quota_id
		  AND credit_type_id = l_quota_csr.credit_type_id;
	    END IF;
	 END LOOP; -- pay_period loop
      END LOOP; -- quota loop
      CLOSE c_quota_csr;

   END LOOP ; -- pay group assign loop
   IF l_pg_found = FALSE then
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
         FND_MESSAGE.SET_NAME('CN' , 'CN_SRP_PAY_GROUP_NOT_FOUND');
         FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_SRP_PAY_GROUP_NOT_FOUND' ;
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   CLOSE c_srp_pay_grp_csr;

   -- Create summary srp period records where necessary for all applicable
   -- credit types
   -- get min srp period ID
   for ct in get_srp_cts loop
      select min(period_id) into l_min_period_id
	from cn_srp_periods_all
	where salesrep_id = p_salesrep_id
	 AND org_id = l_org_id
	 and quota_id is not null
         and credit_type_id = ct.credit_type_id;

       -- Bug 2690859
       -- Add ct.credit_type_id to cursor get_summ_pds() so it'll create
       -- summary record for different credit_type_id
       for p in get_summ_pds(ct.credit_type_id) loop
	  cn_srp_periods_pkg.insert_row
	    (x_srp_period_id   => l_srp_period_id
	     ,x_salesrep_id    => p_salesrep_id
	     ,x_org_id         => l_org_id
	     ,x_period_id      => p.period_id
	     ,x_start_date     => p.start_date
	     ,x_end_date       => p.end_date
	     ,x_credit_type_id => ct.credit_type_id
	     ,x_srp_plan_assign_id => null
	     ,x_role_id        => null
	     ,x_quota_id       => null
	     ,x_pay_group_id   => null
	     ,x_created_by        => FND_GLOBAL.USER_ID
	     ,x_creation_date     => SYSDATE
	     ,x_last_update_date  => SYSDATE
	     ,x_last_updated_by   => FND_GLOBAL.USER_ID
	     ,x_last_update_login => FND_GLOBAL.LOGIN_ID
	     );
       end loop;  -- periods

       for p in get_carry_pds(ct.credit_type_id) loop
          cn_srp_periods_pkg.insert_row
            (x_srp_period_id   => l_srp_period_id
             ,x_salesrep_id    => p_salesrep_id
	     ,x_org_id         => l_org_id
             ,x_period_id      => p.period_id
             ,x_start_date     => p.start_date
             ,x_end_date       => p.end_date
             ,x_credit_type_id => ct.credit_type_id
             ,x_srp_plan_assign_id => -1
             ,x_role_id        => -1
             ,x_quota_id       => -1000
             ,x_pay_group_id   => -1
             ,x_created_by        => FND_GLOBAL.USER_ID
             ,x_creation_date     => SYSDATE
             ,x_last_update_date  => SYSDATE
             ,x_last_updated_by   => FND_GLOBAL.USER_ID
             ,x_last_update_login => FND_GLOBAL.LOGIN_ID
             );
       end loop;  -- periods

       -- populate begin balance columns and summary records
       -- only if p_sync_flag is true... fixed for bug 3193482
       IF p_sync_flag = FND_API.G_TRUE THEN
	  Sync_Accum_Balances(p_salesrep_id, l_org_id, ct.credit_type_id, p_role_id);
       END IF;
   end loop;  -- credit types

   -- End of API body.
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );

EXCEPTION
   WHEN COLLECTION_IS_NULL THEN
      ROLLBACK TO Create_Srp_Periods;
      x_loading_status := 'CN_PAY_PERIOD_NOT_EXIST';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
        (
         p_count   =>  x_msg_count ,
         p_data    =>  x_msg_data  ,
         p_encoded => FND_API.G_FALSE
         );
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO  Create_Srp_Periods;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Srp_Periods;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Srp_Periods;
      /* Change Made By hithanki -- Start*/
      ROLLBACK TO Create_Srp_Periods;
      IF SQLCODE = '-1'
      THEN
	    fnd_message.set_name('CN', 'CN_CREATE_ROLE_PLAN_ERR');
          fnd_msg_pub.ADD;
   	    RAISE fnd_api.g_exc_error;
       END IF;
      /* Change Made By hithanki --  End */

      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
END Create_Srp_Periods_Per_Quota;

--| -----------------------------------------------------------------------+
--| Procedure : Update_Delta_Srp_Pds_No_Sync
--| Desc      : Procedure to update row in cn_srp_periods, add deltas into it
--| -----------------------------------------------------------------------+

PROCEDURE Update_Delta_Srp_Pds_No_Sync
  (p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2,
   p_commit	        IN    VARCHAR2,
   p_validation_level   IN    NUMBER,
   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count	        OUT NOCOPY   NUMBER,
   x_msg_data	        OUT NOCOPY   VARCHAR2,
   p_del_srp_prd_rec    IN    delta_srp_period_rec_type,
   x_loading_status     OUT NOCOPY   VARCHAR2
   ) IS
      l_api_name     CONSTANT VARCHAR2(30) := 'Update_Delta_Srp_Pds_No_Sync';
      l_api_version  CONSTANT NUMBER  := 1.0;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT	Update_Delta_Srp_Pds_No_Sync;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     (l_api_version,p_api_version,l_api_name,g_pkg_name) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF ;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_UPDATED';
   -- API body

   -- Update record's ctd and dtd
   UPDATE cn_srp_periods_all
     SET
     balance1_ctd = (Nvl(balance1_ctd,0) +
		     Nvl(p_del_srp_prd_rec.del_balance1_ctd,0)),
     balance1_dtd = (Nvl(balance1_dtd,0) +
		     Nvl(p_del_srp_prd_rec.del_balance1_dtd,0)),
     balance2_ctd = (Nvl(balance2_ctd,0) +
		     Nvl(p_del_srp_prd_rec.del_balance2_ctd,0)),
     balance2_dtd = (Nvl(balance2_dtd,0) +
		     Nvl(p_del_srp_prd_rec.del_balance2_dtd,0)),
     balance3_ctd = (Nvl(balance3_ctd,0) +
		     Nvl(p_del_srp_prd_rec.del_balance3_ctd,0)),
     balance3_dtd = (Nvl(balance3_dtd,0) +
		     Nvl(p_del_srp_prd_rec.del_balance3_dtd,0)),
     balance4_ctd = (Nvl(balance4_ctd,0) +
		     Nvl(p_del_srp_prd_rec.del_balance4_ctd,0)),
     balance4_dtd = (Nvl(balance4_dtd,0) +
		     Nvl(p_del_srp_prd_rec.del_balance4_dtd,0)),
     balance5_ctd = (Nvl(balance5_ctd,0) +
		     Nvl(p_del_srp_prd_rec.del_balance5_ctd,0)),
     balance5_dtd = (Nvl(balance5_dtd,0) +
		     Nvl(p_del_srp_prd_rec.del_balance5_dtd,0))
     WHERE srp_period_id = p_del_srp_prd_rec.srp_period_id;

   -- End of API body.
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Update_Delta_Srp_Pds_No_Sync;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Delta_Srp_Pds_No_Sync;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Delta_Srp_Pds_No_Sync;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
END Update_Delta_Srp_Pds_No_Sync;

--| -----------------------------------------------------------------------+
--| Procedure : Update_Delta_Srp_Periods
--| Desc      : Procedure to update row in cn_srp_periods, add deltas into it
--| Note      : updates xtd and bbx columns and summary srp periods
--| -----------------------------------------------------------------------+

PROCEDURE Update_Delta_Srp_Periods
  (p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2,
   p_commit	        IN    VARCHAR2,
   p_validation_level   IN    NUMBER,
   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count	        OUT NOCOPY   NUMBER,
   x_msg_data	        OUT NOCOPY   VARCHAR2,
   p_del_srp_prd_rec    IN    delta_srp_period_rec_type,
   x_loading_status     OUT NOCOPY   VARCHAR2
   ) IS
      l_api_name     CONSTANT VARCHAR2(30) := 'Update_Delta_Srp_Periods';
      l_api_version  CONSTANT NUMBER  := 1.0;

      -- get parameters for sync_accum_bals
      l_salesrep_id        NUMBER;
      l_role_id            NUMBER;
      l_credit_type_id     NUMBER;
      l_org_id             NUMBER;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT	Update_Delta_Srp_Periods;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     (l_api_version,p_api_version,l_api_name,g_pkg_name) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF ;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_UPDATED';
   -- API body

   -- populate header info of delta srp period rec
   BEGIN
      SELECT salesrep_id, credit_type_id, role_id, org_id
	INTO l_salesrep_id, l_credit_type_id, l_role_id, l_org_id
	FROM cn_srp_periods_all
       WHERE srp_period_id = p_del_srp_prd_rec.srp_period_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
	 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	   THEN
	    FND_MESSAGE.SET_NAME('CN' , 'CN_SRP_PERIOD_NOT_EXIST');
	    FND_MSG_PUB.Add;
	 END IF;
	 x_loading_status := 'CN_SRP_PERIOD_NOT_EXIST' ;
	 RAISE FND_API.G_EXC_ERROR ;
   END;

   -- update balances
   Update_Delta_Srp_Pds_No_Sync
     (p_api_version        => 1.0,
      x_return_status      => x_return_status,
      x_msg_count	   => x_msg_count,
      x_msg_data	   => x_msg_data,
      p_del_srp_prd_rec    => p_del_srp_prd_rec,
      x_loading_status     => x_loading_status);

   if x_return_status <> FND_API.G_RET_STS_SUCCESS then
      RAISE FND_API.G_EXC_ERROR;
   end if;

   -- populate begin balance columns and summary records
   Sync_Accum_Balances(l_salesrep_id, l_org_id, l_credit_type_id, l_role_id);

   -- End of API body.
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Update_Delta_Srp_Periods;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Delta_Srp_Periods;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Delta_Srp_Periods;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );

END Update_Delta_Srp_Periods;

--| -----------------------------------------------------------------------+
--| Procedure : Update_Pmt_Delta_Srp_Periods
--| Desc      : Procedure to update row in cn_srp_periods, add deltas into it
--| Note      : no longer used - obsolete
--| -----------------------------------------------------------------------+

PROCEDURE Update_Pmt_Delta_Srp_Periods
  (p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2,
   p_commit	        IN    VARCHAR2,
   p_validation_level   IN    NUMBER,
   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count	        OUT NOCOPY   NUMBER,
   x_msg_data	        OUT NOCOPY   VARCHAR2,
   p_del_srp_prd_rec    IN    delta_srp_period_rec_type,
   x_loading_status     OUT NOCOPY   VARCHAR2
   ) IS

BEGIN
   null;
END Update_Pmt_Delta_Srp_Periods ;

END CN_SRP_PERIODS_PVT ;

/
