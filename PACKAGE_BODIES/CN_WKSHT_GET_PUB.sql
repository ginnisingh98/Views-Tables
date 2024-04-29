--------------------------------------------------------
--  DDL for Package Body CN_WKSHT_GET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_WKSHT_GET_PUB" as
-- $Header: cnpwkgtb.pls 120.3 2006/02/13 15:21:31 fmburu noship $

G_CREDIT_TYPE_ID            CONSTANT NUMBER := -1000;
G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'Cn_wksht_get_pub';

--============================================================================
-- Procedure : Get_srp_wksht
-- Description: To get salespeople assigned to payrun
--============================================================================
PROCEDURE  Get_srp_wksht
   (p_api_version     IN    NUMBER,
    p_init_msg_list     IN    VARCHAR2,
    p_commit            IN    VARCHAR2,
    p_validation_level      IN    NUMBER,
    x_return_status        OUT NOCOPY   VARCHAR2,
    x_msg_count            OUT NOCOPY   NUMBER,
    x_msg_data       OUT NOCOPY   VARCHAR2,
    p_start_record          IN      NUMBER,
    p_increment_count       IN      NUMBER,
    p_payrun_id             IN      NUMBER,
    p_salesrep_name     IN      VARCHAR2,
    p_employee_number     IN      VARCHAR2,
    p_analyst_name      IN      VARCHAR2,
    p_my_analyst      IN      VARCHAR2,
    p_unassigned            IN    VARCHAR2,
    p_worksheet_status      IN    VARCHAR2,
    p_currency_code     IN    VARCHAR2,
    p_order_by        IN    VARCHAR2,
    x_wksht_tbl             OUT NOCOPY     wksht_tbl,
    x_tot_amount_earnings   OUT NOCOPY  NUMBER,
    x_tot_amount_adj        OUT NOCOPY  NUMBER,
    x_tot_amount_adj_rec    OUT NOCOPY  NUMBER,
    x_tot_amount_total      OUT NOCOPY  NUMBER,
    x_tot_held_amount       OUT NOCOPY     NUMBER,
    x_tot_ced                OUT NOCOPY     NUMBER,
    x_tot_earn_diff                OUT NOCOPY     NUMBER,
    x_total_records         OUT NOCOPY     NUMBER
  ) IS

     l_bb_prior_period_adj NUMBER;
     l_bb_pmt_recovery_plans NUMBER;
     l_curr_earnings NUMBER;
     l_bb_total NUMBER;

     l_api_name CONSTANT VARCHAR2(30)  := 'Get_srp_wksht';
     l_api_version CONSTANT NUMBER        := 1.0;
     l_counter NUMBER;

     TYPE wkshtcurtype IS ref CURSOR;
     wksht_cur wkshtcurtype;

     l_select   VARCHAR2(9000);
     -- worksheet earnings = pmt_amount_calc + pmt_amount_recovery
     l_select1  VARCHAR2(9000) :=
      ' Select /*+ first_rows */ w.payment_worksheet_id,
             s.name salesrep_name,
             s.employee_number employee_number,
             s.salesrep_id,
             s.resource_id,
             s.cost_center  cost_center,
             s.charge_to_cost_center,
             0 pmt_amount_diff,
             nvl(w.pmt_amount_calc,0) + nvl(w.pmt_amount_recovery,0) pmt_amount_earnings,
             nvl(w.pmt_amount_adj,0)  pmt_amount_adj ,
             nvl(w.pmt_amount_adj_rec,0) + nvl(w.pmt_amount_adj_nrec,0) Pmt_amount_adj_rec ,
             nvl(w.pmt_amount_recovery,0) pmt_amount_recovery ,
             nvl(w.pmt_amount_calc,0) + nvl(w.pmt_amount_adj,0) +
             nvl(w.pmt_amount_adj_rec,0) + nvl(w.pmt_amount_adj_nrec,0)
             + nvl(w.pmt_amount_recovery,0) Pmt_amount_total,
             nvl(w.held_amount,0) held_amount,
             lk.meaning status_meaning,
             u.user_name status_by,
             s.assigned_to_user_name  analyst_name,
             w.worksheet_status,
             w.object_version_number,
             p.pay_date,
             p.org_id
       from cn_payment_worksheets w,
            cn_salesreps s,
            cn_payruns p,
            cn_lookups lk,
            fnd_user u
       where s.salesrep_id = w.salesrep_id
       and w.org_id        = s.org_id
       and w.worksheet_status = lk.lookup_code
       and w.payrun_id    = p.payrun_id
       and lk.lookup_type = ''WORKSHEET_STATUS'' and w.quota_id is NULL
       and u.user_id (+) = nvl(w.last_updated_by, w.created_by)
       and  w.payrun_id  = :B1 ';

       l_where  VARCHAR2(5000) := null;
       l_where1 VARCHAR2(5000) := ' upper(s.name)  LIKE  :B2 ';
       l_where2 VARCHAR2(5000) := ' upper(s.employee_number) LIKE :B3 ';
       l_where3 varchar2(5000) := ' worksheet_status LIKE  :B4 ';
       l_where4 VARCHAR2(5000) := ' 1 = 1  ';
       l_where5 VARCHAR2(5000) := ' s.assigned_to_user_name LIKE :B5 ';
       l_where7 VARCHAR2(5000) := ' s.assigned_to_user_id IN (
       SELECT
       DISTINCT re2.user_id
       FROM jtf_rs_group_usages u2,
         jtf_rs_rep_managers m2,
         jtf_rs_resource_extns_vl re2,
       (SELECT DISTINCT m1.resource_id,
  greatest(pr.start_date,m1.start_date_active) start_date,
  least(pr.end_date,Nvl(m1.end_date_active,pr.end_date)) end_date
      FROM jtf_rs_resource_extns re1,
        cn_period_statuses pr, jtf_rs_group_usages u1,
        jtf_rs_rep_managers m1
      WHERE re1.user_id = :B7
            AND pr.period_id
                = ( select pay_period_id from cn_payruns where payrun_id = :B8)
            AND u1.usage = ''COMP_PAYMENT''
            AND ((m1.start_date_active <= pr.end_date) AND
                      (pr.start_date <= Nvl(m1.end_date_active,pr.start_date)))
                      AND u1.group_id = m1.group_id
      AND m1.resource_id = re1.resource_id
                    AND m1.parent_resource_id = m1.resource_id
                  AND m1.hierarchy_type IN (''MGR_TO_MGR'',''REP_TO_REP'')
                  AND m1.category <> ''TBH''
         ) v3
   WHERE
   u2.usage = ''COMP_PAYMENT''
         AND u2.group_id = m2.group_id
   AND m2.parent_resource_id = v3.resource_id
         AND ((m2.start_date_active <= v3.end_date)
         AND (v3.start_date <= Nvl(m2.end_date_active,v3.start_date)))
         AND m2.category <> ''TBH''
   AND m2.hierarchy_type IN (''MGR_TO_MGR'',''MGR_TO_REP'',''REP_TO_REP'')
         AND m2.resource_id = re2.resource_id ) ' ;


      l_where9 Varchar2(5000) := ') or ( s.assigned_to_user_id IS NULL ) ';
      l_where11 Varchar2(5000) := ') ';
      l_wksht_rec                 wksht_rec;
      l_payment_worksheet_id      cn_payment_worksheets.payment_worksheet_id%TYPE;
      l_salesrep_name             cn_salesreps.name%TYPE;
      l_employee_number           cn_salesreps.employee_number%TYPE;
      l_cost_center               cn_salesreps.cost_center%TYPE;
      l_charge_to_cost_center cn_salesreps.charge_to_cost_center%TYPE;
      l_salesrep_id               cn_salesreps.salesrep_id%TYPE;
      l_resource_id     cn_salesreps.resource_id%TYPE;
      l_status              cn_payruns.status%TYPE;
      l_worksheet_status      cn_lookups.meaning%TYPE;
      l_user_name           fnd_user.user_name%TYPE;
      l_pay_date            DATE;
      l_diff1             NUMBER := 0;
      l_diff2             NUMBER := 0;
      l_current_earnings          NUMBER;
      l_earnings_diff             NUMBER;
      l_pmt_amount_calc       NUMBER;
      l_pmt_amount_adj        NUMBER;
      l_pmt_amount_adj_rec      NUMBER;
      l_pmt_amount_recovery     NUMBER;
      l_pmt_amount_total      NUMBER;
      l_held_amount                       NUMBER;

      l_analyst_name        cn_salesreps.assigned_to_user_name%TYPE;
      l_object_version_number NUMBER;
      l_worksheet_status_code cn_lookups.lookup_code%TYPE;
      c_salesrep_name        cn_salesreps.name%TYPE;
      c_employee_number      cn_salesreps.employee_number%TYPE;
      c_worksheet_status     cn_payment_worksheets.worksheet_status%TYPE;
      c_analyst_id           NUMBER;
      c_analyst_name       cn_salesreps.assigned_to_user_name%TYPE;
      l_analyst_flag       VARCHAR2(01)  := 'N';
      l_view_ced       VARCHAR2(1);
      l_view_notes     VARCHAR2(1);
      l_b6              Varchar2(100);
      l_b7              Varchar2(100);
      l_b8              Varchar2(100);
      l_b9              Varchar2(100);
      l_tmp   NUMBER;
      l_org_id    NUMBER ;

      CURSOR get_payrun_curs IS
   SELECT status
     FROM cn_payruns WHERE payrun_id = p_payrun_id;

      -- cursor to check if the worksheet is pre-1158 release.
      CURSOR view_ced_cur (l_payment_worksheet_id cn_worksheet_qg_dtls.payment_worksheet_id%TYPE) IS
     SELECT 'Y' FROM dual WHERE exists
     (SELECT 1 FROM cn_worksheet_qg_dtls
      WHERE payment_worksheet_id = l_payment_worksheet_id);

      -- cursor to check if thenote exist
     CURSOR view_notes_cur (l_payment_worksheet_id cn_worksheet_qg_dtls.payment_worksheet_id%TYPE) IS
     SELECT 'Y' FROM dual WHERE exists
     (SELECT 1
      FROM JTF_NOTES_B WHERE SOURCE_OBJECT_CODE = 'CN_PAYMENT_WORKSHEETS'
      AND SOURCE_OBJECT_ID = l_payment_worksheet_id
      );

      FUNCTION Convert_Amount(l_from_amount NUMBER, l_date Date, c_org_id NUMBER)
  RETURN NUMBER IS
     l_to_amount NUMBER;
      BEGIN
         l_to_amount :=
     GL_CURRENCY_API.Convert_Amount
     (x_from_currency => CN_GLOBAL_VAR.GET_CURRENCY_CODE(c_org_id),
      x_to_currency => p_currency_code,
      x_conversion_date => l_date,
      x_conversion_type => nvl(CN_SYSTEM_PARAMETERS.value('CN_CONVERSION_TYPE',c_org_id), 'Corporate'),
      x_amount => l_from_amount
      );
   RETURN l_to_amount;
      EXCEPTION
   WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
         FND_MESSAGE.SET_NAME ('CN' , 'CN1158_CURR_CONV_ERR');
         FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR ;
      END convert_Amount;

BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT    Get_srp_wksht;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
          l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- API body
   l_counter := 0;
   x_total_records := 0;

   -- Check if this payrun is new payrun created after 11.5.8 upgrade
   BEGIN
      l_tmp := 0 ;
      SELECT 1 INTO l_tmp
  FROM cn_payruns pay
  WHERE pay.payrun_id = p_payrun_id
  AND (pay.status <> 'PAID' OR
       (pay.status = 'PAID'
        AND exists
        (SELECT 1
         FROM cn_worksheet_qg_dtls dtls, cn_payment_worksheets wrk
         WHERE dtls.payment_worksheet_id = wrk.payment_worksheet_id
         AND wrk.payrun_id = pay.payrun_id
         AND wrk.salesrep_id = dtls.salesrep_id)
        ));
   EXCEPTION
      WHEN no_data_found THEN
   -- this payrun is old payrun from before 11.5.8, no need to check
   -- from payment analyst hierarchy
   l_tmp := 0 ;
   END;

   IF l_tmp = 1 THEN
      -- Check if login user in payment analyst hierarchy for this
      -- pay period
      BEGIN
   SELECT 1 INTO l_tmp FROM dual WHERE exists
     (SELECT 1
      FROM jtf_rs_resource_extns re1,
           cn_period_statuses pr,
           jtf_rs_group_usages u1,
           jtf_rs_rep_managers m1
      WHERE re1.user_id = fnd_global.user_id
      AND (pr.period_id, pr.org_id) = (
         SELECT pay_period_id, org_id
         FROM cn_payruns
         WHERE payrun_id = p_payrun_id)
      AND u1.usage = 'COMP_PAYMENT'
      AND ((m1.start_date_active <= pr.end_date) AND
          (pr.start_date <= Nvl(m1.end_date_active,pr.start_date)))
      AND u1.group_id = m1.group_id
      AND m1.resource_id = re1.resource_id
      AND m1.parent_resource_id = m1.resource_id
      AND m1.hierarchy_type IN ('MGR_TO_MGR','REP_TO_REP')
      AND m1.category <> 'TBH');
      EXCEPTION
   WHEN no_data_found THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.SET_NAME ('CN','CN_NO_SRP_ACCESS');
         FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR ;
      END;
   END IF;

   c_salesrep_name   := upper(p_salesrep_name);
   c_employee_number := upper(p_employee_number);
   c_worksheet_status := p_worksheet_status;
   -- c_analyst_id        := p_analyst_id;
   c_analyst_name     := p_analyst_name;

   l_select := l_select1 ;
   -- Add salesrep Name is passed
   IF p_salesrep_name IS NOT NULL AND p_salesrep_name <> '%' THEN
      l_select := l_select || ' and ' || l_where1 ;
   ELSE
      l_select := l_select || ' and ' || ' 1 = :B2 ';
      c_salesrep_name := 1;
   END IF;

   -- Add Employee Number is passed
   IF p_employee_number IS NOT NULL AND p_employee_number <> '%' THEN
      l_select := l_select || ' and ' || l_where2 ;
   ELSE
      l_select := l_select || ' and 1 = :B3 ';
      c_employee_number := 1;
   END IF;

   -- Add worksheet status
   IF p_worksheet_status IS NOT NULL AND p_worksheet_status <> '%'
     AND p_worksheet_status <> 'ALL' THEN
      l_select := l_select || ' and ' || l_where3 ;
   ELSE
      l_select := l_select || ' and 1 = :B4 ';
      c_worksheet_status := 1;
   END IF;

   l_select := l_select || ' and  (( ';

   IF p_analyst_name IS NOT NULL AND p_analyst_name <> '%'  THEN
     l_where :=  l_where  || ' ( ' || l_where5 || ') ';
     l_analyst_flag := 'Y';
   ELSE
     l_where :=  l_where || '  ( 1 = :B5  ) ';
     c_analyst_name := 1;
   END IF;

   IF p_my_analyst = 'Y' THEN
     l_where :=  l_where || ' and ( ' ||  l_where7 || ') ';
     l_b7 := fnd_global.user_id;
     l_b8 := p_payrun_id;
   ELSE
     l_where :=  l_where || ' and (  1 = :B7   ) and 1 = :B8 ';
     l_b7 := 1;
     l_b8 := 1;
   END IF;

   -- Bug 3597600: p_my_analyst can be NULL
   --  Old code:   p_my_analyst = 'N' THEN
   IF (p_analyst_name IS NULL OR p_analyst_name = '%') AND
     (p_my_analyst = 'N' OR p_my_analyst IS NULL)  THEN
     l_b9 := fnd_global.user_id;
     l_where := l_where || ' and  assigned_to_user_id = :B11  ' ;
   ELSE
     l_where := l_where || ' and  1 = :B11  ' ;
     l_b9 := 1;
   END IF;

   l_select   := l_select || l_where ;
   IF p_unassigned = 'Y' THEN
     l_select   := l_select || l_where9 ;
   ELSE
     l_select :=   l_select || l_where11 ;
   END IF;

   l_select := l_select || ' ) ' ||  ' ' ||  p_order_by ;

   --
   -- Debugging
   --
   -- CREATE TABLE my_temp
   --  (select_clause1 varchar2(2000),
   --   select_clause2 varchar2(2000),
   --   select_clause3 varchar2(2000))
   /*
   INSERT INTO my_temp (select_clause1,select_clause2,select_clause3)
     SELECT substrb(l_select,1,2000),substrb(l_select,2001,2000),
     p_payrun_id || '*' || c_salesrep_name ||'*'||  c_employee_number ||'*'||
     c_worksheet_status ||'*'|| c_analyst_name ||'*'||   l_b7 ||'*'||  l_b8
     ||'*'||  l_b9
     FROM dual;
     */

   OPEN wksht_cur FOR l_select using p_payrun_id,
     c_salesrep_name, c_employee_number, c_worksheet_status,
     c_analyst_name,  l_b7, l_b8, l_b9, l_org_id;

   LOOP
      FETCH wksht_cur INTO
  l_payment_worksheet_id
  ,l_salesrep_name
  ,l_employee_number
  ,l_salesrep_id
  ,l_resource_id
  ,l_cost_center
  ,l_charge_to_cost_center
  ,l_earnings_diff
  ,l_pmt_amount_calc
  ,l_pmt_amount_adj
  ,l_pmt_amount_adj_rec
  ,l_pmt_amount_recovery
  ,l_pmt_amount_total
  ,l_held_amount
  ,l_worksheet_status
  ,l_user_name
  ,l_analyst_name
  ,l_worksheet_status_code
  ,l_object_version_number
  ,l_pay_date;

      EXIT WHEN wksht_cur%notfound;
      x_total_records := x_total_records + 1;

      IF (l_counter + 1 BETWEEN p_start_record AND (p_start_record + p_increment_count - 1)) THEN
   -- Get current earnings due
   cn_payment_worksheet_pvt.get_ced_and_bb
     ( p_api_version           => 1.0,
       x_return_status         => x_return_status,
       x_msg_count             => x_msg_count,
       x_msg_data              => x_msg_data,
       p_worksheet_id          => l_payment_worksheet_id,
       x_bb_prior_period_adj   => l_bb_prior_period_adj,
       x_bb_pmt_recovery_plans => l_bb_pmt_recovery_plans,
       x_curr_earnings         => l_curr_earnings,
       x_curr_earnings_due     => l_current_earnings,
       x_bb_total              => l_bb_total);

   IF  x_return_status <> FND_API.g_ret_sts_success THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   l_view_ced := 'N';

   OPEN view_ced_cur (l_payment_worksheet_id);
   FETCH view_ced_cur INTO l_view_ced;
   CLOSE view_ced_cur;

   l_view_notes := 'N';

   OPEN view_notes_cur (l_payment_worksheet_id);
   FETCH view_notes_cur INTO l_view_notes;
   CLOSE view_notes_cur;

   x_wksht_tbl(l_counter).payment_worksheet_id := l_payment_worksheet_id;
   x_wksht_tbl(l_counter).view_ced             := l_view_ced;
   x_wksht_tbl(l_counter).view_notes           := l_view_notes;
   x_wksht_tbl(l_counter).salesrep_name        := l_salesrep_name;
   x_wksht_tbl(l_counter).employee_number      := l_employee_number;
   x_wksht_tbl(l_counter).salesrep_id          := l_salesrep_id;
   x_wksht_tbl(l_counter).resource_id          := l_resource_id;
   x_wksht_tbl(l_counter).worksheet_status     := l_worksheet_status;
   x_wksht_tbl(l_counter).status_by            := l_user_name;
   x_wksht_tbl(l_counter).cost_center          := l_cost_center;
   x_wksht_tbl(l_counter).charge_to_cost_center:= l_charge_to_cost_center;

   -- Calc earning difference
   l_earnings_diff := nvl(l_current_earnings,0) - nvl(l_pmt_amount_calc,0) - Nvl(l_held_amount,0);

   -- user currency
   IF nvl(p_currency_code,'FUNC_CURR') <> 'FUNC_CURR' THEN
      x_wksht_tbl(l_counter).current_earnings   := convert_amount(l_current_earnings,   l_pay_date, l_org_id);
      x_wksht_tbl(l_counter).pmt_amount_diff    := convert_amount(l_earnings_diff,      l_pay_date, l_org_id);
      x_wksht_tbl(l_counter).pmt_amount_earnings:= convert_amount(l_pmt_amount_calc,    l_pay_date, l_org_id);
      x_wksht_tbl(l_counter).pmt_amount_adj     := convert_amount(l_pmt_amount_adj,     l_pay_date, l_org_id);
      x_wksht_tbl(l_counter).pmt_amount_adj_rec := convert_amount(l_pmt_amount_adj_rec, l_pay_date, l_org_id);
      x_wksht_tbl(l_counter).pmt_amount_total   := convert_amount(l_pmt_amount_total,l_pay_date, l_org_id);
      x_wksht_tbl(l_counter).held_amount        := convert_amount(l_held_amount,l_pay_date,l_org_id);
    ELSE
      -- Functional Currency
      x_wksht_tbl(l_counter).current_earnings     := l_current_earnings;
      x_wksht_tbl(l_counter).pmt_amount_diff      := l_earnings_diff ;
      x_wksht_tbl(l_counter).pmt_amount_earnings  := l_pmt_amount_calc ;
      x_wksht_tbl(l_counter).pmt_amount_adj       := l_pmt_amount_adj;
      x_wksht_tbl(l_counter).pmt_amount_adj_rec   := l_pmt_amount_adj_rec ;
      x_wksht_tbl(l_counter).pmt_amount_total     := l_pmt_amount_total;
      x_wksht_tbl(l_counter).held_amount          := l_held_amount;
   END IF;

   x_wksht_tbl(l_counter).worksheet_status_code  := l_worksheet_status_code;
   x_wksht_tbl(l_counter).Analyst_name           := l_analyst_name;
   x_wksht_tbl(l_counter).object_version_number  := l_object_version_number;

   -- Cumulative total
   x_tot_amount_earnings :=  nvl(x_tot_amount_earnings,0) + l_pmt_amount_calc;
   x_tot_amount_adj      :=  nvl(x_tot_amount_adj,0)      + l_pmt_amount_adj;
   x_tot_amount_adj_rec  :=  nvl(x_tot_amount_adj_rec,0)  + l_pmt_amount_adj_rec;
   x_tot_amount_total    :=  nvl(x_tot_amount_total,0)    + l_pmt_amount_total;
   x_tot_held_amount     :=  nvl(x_tot_held_amount,0)     + l_held_amount;
   x_tot_ced := Nvl(x_tot_ced,0) + l_current_earnings;
   x_tot_earn_diff := Nvl(x_tot_earn_diff,0) + l_earnings_diff;

      END IF;
      l_counter := l_counter + 1;
   END LOOP;

   -- Convert the total into user currency
   IF nvl(p_currency_code,'FUNC_CURR') <> 'FUNC_CURR' THEN
      x_tot_amount_earnings :=  convert_amount(x_tot_amount_earnings, l_pay_date, l_org_id);
      x_tot_amount_adj      :=  convert_amount(x_tot_amount_adj,      l_pay_date, l_org_id);
      x_tot_amount_adj_rec  :=  convert_amount(x_tot_amount_adj_rec,  l_pay_date, l_org_id);
      x_tot_amount_total    :=  convert_amount(x_tot_amount_total,    l_pay_date, l_org_id);
      x_tot_held_amount     :=  convert_amount(x_tot_held_amount,     l_pay_date, l_org_id);
      x_tot_ced  :=  convert_amount(x_tot_ced,     l_pay_date, l_org_id);
      x_tot_earn_diff :=  convert_amount(x_tot_earn_diff,     l_pay_date, l_org_id);

   END IF;
   CLOSE wksht_cur;

   -- End of API body.
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   --
   -- Standard call to get message count and if count is 1, get message info.
   --
   FND_MSG_PUB.Count_And_Get
     (p_count   =>  x_msg_count,
      p_data    =>  x_msg_data,
      p_encoded => FND_API.G_FALSE);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Get_srp_wksht;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
     (p_count   =>  x_msg_count,
      p_data    =>  x_msg_data,
      p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Get_srp_wksht;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
     (p_count   =>  x_msg_count,
      p_data    =>  x_msg_data,
      p_encoded => FND_API.G_FALSE);
      WHEN OTHERS THEN
      ROLLBACK TO Get_srp_wksht;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
   FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
     (p_count   =>  x_msg_count,
      p_data    =>  x_msg_data,
      p_encoded => FND_API.G_FALSE);
END Get_srp_wksht;

END Cn_wksht_get_pub ;

/
