--------------------------------------------------------
--  DDL for Package Body CN_COMMISSION_CALC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_COMMISSION_CALC_PVT" AS
-- $Header: cnvprcmb.pls 120.6 2005/11/21 22:56:29 raramasa noship $
G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_COMMISSION_CALC_PVT';

g_cached_org_id NUMBER :=0;
g_cached_org_append VARCHAR2(100);


PROCEDURE get_Projected_Commission
(
  p_srp_plan_assign_id IN NUMBER,
  p_salesrep_id        IN NUMBER,
  p_start_period_id    IN NUMBER,
  p_end_period_id      IN NUMBER,
  p_quota_id           IN NUMBER,
  p_quota_name         IN VARCHAR,
  p_sales_credit_amt   IN NUMBER,
  x_proj_comm          OUT NOCOPY NUMBER,
  x_return_status      OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2
)
IS
       l_api_name                CONSTANT VARCHAR2(30) := 'get_Projected_Commission';
       l_api_version             CONSTANT NUMBER       := 1.0;

  CURSOR pe_formula_cr IS
  SELECT ccf.name formula_name
  ,      ccf.calc_formula_id formula_id
  ,      ccf.formula_status  formula_status
  ,      ccf.org_id org_id
  FROM   cn_quotas cq
  ,      cn_calc_formulas ccf
  WHERE  cq.quota_id = p_quota_id
  AND    ccf.calc_formula_id = cq.calc_formula_id;

  CURSOR formula_valid_cr(p_formula_id NUMBER, p_org_id NUMBER) IS
  SELECT count(*)
  FROM   user_objects
  WHERE  object_name = 'CN_FORMULA_'||abs(p_formula_id)||'_'||abs(p_org_id)||'_PKG'
  AND    (object_type = 'PACKAGE' OR object_type = 'PACKAGE BODY');

  l_pe_formula pe_formula_cr%ROWTYPE;
  l_formula_count NUMBER := 0;

BEGIN

    SAVEPOINT get_Projected_Commission;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    x_proj_comm := 0;

    OPEN pe_formula_cr;
    FETCH pe_formula_cr into l_pe_formula;
    IF pe_formula_cr%NOTFOUND THEN
      fnd_message.set_name('CN', 'CN_NO_QUOTA_FORMULA');
      fnd_message.set_token('QUOTA_NAME', p_quota_name);
      fnd_msg_pub.add;
      CLOSE pe_formula_cr;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_pe_formula.formula_status <> 'COMPLETE' THEN
      fnd_message.set_name('CN', 'CN_INV_CALC_FORMULA');
      fnd_message.set_token('QUOTA_NAME', p_quota_name);
      fnd_msg_pub.add;
      CLOSE pe_formula_cr;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE pe_formula_cr;

    OPEN formula_valid_cr(l_pe_formula.formula_id,l_pe_formula.org_id);
    FETCH formula_valid_cr INTO l_formula_count;
    CLOSE formula_valid_cr;

    IF l_formula_count <> 2 THEN
      fnd_message.set_name('CN', 'CN_FORMULA_PKG_NOT_VALID');
      fnd_message.set_token('FORMULA_NAME', l_pe_formula.formula_name);
      fnd_msg_pub.add;
      CLOSE pe_formula_cr;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    EXECUTE IMMEDIATE
      'BEGIN CN_FORMULA_'||abs(l_pe_formula.formula_id)||'_'||abs(l_pe_formula.org_id)||'_PKG.get_forecast_commission(:1,:2,:3,:4,:5,:6,:7);END;'
       USING p_srp_plan_assign_id, p_salesrep_id, p_start_period_id,p_end_period_id,p_quota_id,p_sales_credit_amt,out x_proj_comm;

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.count_and_get(p_count      =>      x_msg_count,
                                  p_data       =>      x_msg_data,
                                  p_encoded    =>      FND_API.G_FALSE );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_proj_comm := 0;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.count_and_get(p_count      =>      x_msg_count,
                                  p_data       =>      x_msg_data,
                                  p_encoded    =>      FND_API.G_FALSE );

      WHEN OTHERS THEN
        x_proj_comm := 0;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.count_and_get(p_count      =>      x_msg_count,
                                  p_data       =>      x_msg_data,
                                  p_encoded    =>      FND_API.G_FALSE );

End get_Projected_Commission;

Procedure processRows(p_proj_comp_rec IN cn_proj_compensation_gtt%rowtype,
                      x_return_status OUT NOCOPY VARCHAR2,
                      x_msg_count     OUT NOCOPY NUMBER,
                      x_msg_data      OUT NOCOPY VARCHAR2
                     ) IS
  CURSOR srpplanassign_cr(p_salesrep_id NUMBER,p_date DATE,p_quota_id NUMBER) IS
    SELECT cspa.srp_plan_assign_id srp_plan_assign_id,
           cspa.salesrep_id salesrep_id,
           cspa.comp_plan_id comp_plan_id,
           cspa.start_date start_date,
           nvl(cspa.end_date,p_date) end_date
    FROM   cn_srp_plan_assigns cspa,
           cn_srp_quota_assigns csqa
    WHERE  cspa.salesrep_id = p_salesrep_id
    AND    p_date BETWEEN cspa.start_date AND nvl(cspa.end_date,p_date)
    AND    csqa.quota_id = p_quota_id
    AND    csqa.srp_plan_assign_id = cspa.srp_plan_assign_id;

  CURSOR compplan_cr(p_comp_plan_id NUMBER) IS
    SELECT count(*) valid_compplan_cnt
    FROM   cn_comp_plans
    WHERE  comp_plan_id = p_comp_plan_id
    AND    status_code = 'INCOMPLETE';

  CURSOR quotadetails_cr(p_salesrep_id NUMBER, p_revenueclass_id NUMBER, p_date DATE) IS
    SELECT
             sqa.quota_id
    ,      q.interval_type_id  interval_type_id
    ,      q.credit_type_id    credit_type_id
    ,      cit.name            interval_type_name
    ,      cci.name            credit_type_name
    ,      q.name              quota_name
    ,      qr.revenue_class_id
	    from cn_srp_plan_assigns spa,
                 cn_srp_quota_assigns sqa,
                 cn_quotas q,
                 cn_quota_rules qr,
	         cn_dim_hierarchies dh,
	         jtf_rs_salesreps jrs,
	         jtf_rs_group_members mem,
	         jtf_rs_role_relations rr,
             cn_interval_types cit,
             cn_credit_types cci,
             cn_repositories cr
           where spa.salesrep_id = p_salesrep_id
             and spa.start_date <= p_date
             and nvl(spa.end_date, p_date) >= p_date
             and jrs.salesrep_id = p_salesrep_id
	     and nvl(jrs.org_id, -9999) = nvl(spa.org_id, -9999)
	     and mem.resource_id = jrs.resource_id
	     and nvl(mem.delete_flag, 'N') <> 'Y'
	     and rr.role_id = spa.role_id
	     and rr.role_resource_id = mem.group_member_id
	     and rr.role_resource_type = 'RS_GROUP_MEMBER'
	     and nvl(rr.delete_flag, 'N') <> 'Y'
	    and exists (select 1 from cn_comp_plans where status_code = 'COMPLETE' AND comp_plan_id = spa.comp_plan_id)
             and rr.start_date_active <= p_date
             and nvl(rr.end_date_active, p_date) >= p_date
             and rr.start_date_active <= nvl(spa.end_date, p_date)
             and nvl(rr.end_date_active, nvl(spa.end_date, p_date)) >= spa.start_date
             and sqa.srp_plan_assign_id = spa.srp_plan_assign_id
             and q.quota_id = sqa.quota_id
             and q.start_date <= p_date
             and nvl(q.end_date, p_date) >= p_date
             and qr.quota_id = sqa.quota_id
             and dh.header_dim_hierarchy_id = cr.rev_class_hierarchy_id
             and dh.start_date <= least(nvl(spa.end_date, p_date), nvl(q.end_date, p_date))
             and nvl(dh.end_date, p_date) >= greatest(spa.start_date, q.start_date)
             and exists (select 1 from cn_dim_explosion de
                                 where de.dim_hierarchy_id = dh.dim_hierarchy_id
                                   and de.ancestor_external_id = qr.revenue_class_id
                                   and de.value_external_id = p_revenueclass_id)
             AND    cit.interval_type_id = q.interval_type_id
             AND    cci.credit_type_id = q.credit_type_id
             order by greatest(dh.start_date, spa.start_date, q.start_date, rr.start_date_active, p_date),
             	    least(nvl(dh.end_date, p_date),
                	nvl(spa.end_date, p_date),
             		nvl(q.end_date, p_date),
		            nvl(rr.end_date_active, p_date), p_date);

  CURSOR periodquotas_cr(p_srp_plan_assign_id NUMBER, p_salesrep_id NUMBER, p_period_id NUMBER, p_quota_id NUMBER) IS
    SELECT nvl(cspq.input_achieved_itd,0) input_achieved_itd
    ,      nvl(cspq.itd_TARGET,0)         target_itd
    ,      nvl(cspq.target_amount,0)      target_amount
    FROM   cn_srp_period_quotas cspq
    WHERE  cspq.srp_plan_assign_id = p_srp_plan_assign_id
    AND    cspq.salesrep_id        = p_salesrep_id
    AND    cspq.quota_id           = p_quota_id
    AND    cspq.period_id          = p_period_id;

  l_quotadetails    quotadetails_cr%ROWTYPE;
  l_srp_plan_assign srpplanassign_cr%ROWTYPE;
  l_periodquotas    periodquotas_cr%ROWTYPE;

  l_stmt VARCHAR2(1000):='';
  l_from_currency VARCHAR2(80) := '';

  l_valid_forecast NUMBER := 0;
  l_valid_compplan NUMBER := 0;
  l_proj_comm_amt NUMBER := 0;
  l_tot_inp_ach_itd NUMBER := 0;
  l_tot_target_itd  NUMBER := 0;
  l_tot_target_amt NUMBER := 0;
  l_quota_achievement NUMBER := 0;
  l_revenueclass_id NUMBER := 0;
  l_tot_proj_comm_amt   NUMBER:=0;

  l_return_status varchar2(1);
  l_msg_count number;
  l_msg_data varchar2(2000);

  BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_tot_target_amt:=0;
    l_tot_inp_ach_itd := 0;
    l_tot_target_itd  := 0;
    l_tot_proj_comm_amt :=0;
    l_proj_comm_amt := 0;
    l_revenueclass_id := 0;

    l_stmt := 'BEGIN ' || ':rev_class_id := ' ||'cn_clsfn_' || To_char(p_proj_comp_rec.ruleset_id) || g_cached_org_append || '.classify_' || To_char(p_proj_comp_rec.ruleset_id) ||'( :p_line_no);' ||    'END;';

    EXECUTE IMMEDIATE  l_stmt USING OUT l_revenueclass_id, p_proj_comp_rec.line_id;

    OPEN  quotadetails_cr(p_proj_comp_rec.salesrep_id,l_revenueclass_id,p_proj_comp_rec.calc_date);
    FETCH quotadetails_cr INTO l_quotadetails;
    IF quotadetails_cr%NOTFOUND THEN
      fnd_message.set_name('CN', 'CN_QUOTA_NOT_MAPPED');
      fnd_message.set_token('LINE_NO', p_proj_comp_rec.line_id);
      fnd_msg_pub.add;
      CLOSE quotadetails_cr;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE quotadetails_cr;

    FOR l_srp_plan_assign IN srpplanassign_cr(p_proj_comp_rec.salesrep_id,p_proj_comp_rec.calc_date,l_quotadetails.quota_id) LOOP

      l_proj_comm_amt :=0;
      l_valid_forecast := 1;
      OPEN compplan_cr(l_srp_plan_assign.comp_plan_id);
      FETCH compplan_cr INTO l_valid_compplan;
      IF l_valid_compplan > 0 THEN
        fnd_message.set_name('CN', 'CN_PR_CP_NOT_VALID');
        fnd_message.set_token('LINE_NO', p_proj_comp_rec.line_id);
        fnd_msg_pub.add;
        CLOSE compplan_cr;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE compplan_cr;

      get_Projected_Commission( p_srp_plan_assign_id => l_srp_plan_assign.srp_plan_assign_id,
                                p_salesrep_id        => l_srp_plan_assign.salesrep_id,
                                p_start_period_id    => p_proj_comp_rec.period_id,
                                p_end_period_id      => p_proj_comp_rec.period_id,
                                p_quota_id           => l_quotadetails.quota_id,
                                p_quota_name         => l_quotadetails.quota_name,
                                p_sales_credit_amt   => p_proj_comp_rec.sales_credit_amount,
                                x_proj_comm          => l_proj_comm_amt,
                                x_return_status      => l_return_status,
                                x_msg_count          => l_msg_count,
                                x_msg_data           => l_msg_data);

      IF l_return_status <> 'S' THEN
        x_return_status := l_return_status;
        x_msg_count     := l_msg_count;
        x_msg_data      := l_msg_data;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      OPEN periodquotas_cr(l_srp_plan_assign.srp_plan_assign_id, l_srp_plan_assign.salesrep_id,p_proj_comp_rec.period_id,l_quotadetails.quota_id);
      FETCH periodquotas_cr INTO l_periodquotas;
      IF periodquotas_cr%NOTFOUND THEN
        l_periodquotas.input_achieved_itd := 0;
        l_periodquotas.target_itd         :=0;
        l_periodquotas.target_amount      :=0;
      END IF;
      CLOSE periodquotas_cr;

      l_tot_inp_ach_itd := l_tot_inp_ach_itd + l_periodquotas.input_achieved_itd;
      l_tot_target_itd  := l_tot_target_itd + l_periodquotas.target_itd;
      l_tot_target_amt  := l_tot_target_amt + l_periodquotas.target_amount;
      l_tot_proj_comm_amt := l_tot_proj_comm_amt + NVL(l_proj_comm_amt,0) ;

    END LOOP;

    IF l_valid_forecast = 0 THEN
      fnd_message.set_name('CN', 'CN_PR_SRPPLAN_NOT_FOUND');
      fnd_message.set_token('LINE_NO', p_proj_comp_rec.line_id);
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_from_currency  := cn_general_utils.get_currency_code;

    BEGIN
      l_tot_proj_comm_amt := cn_api.convert_to_repcurr(l_tot_proj_comm_amt,
                                                       p_proj_comp_rec.calc_date,
                                                       CN_SYSTEM_PARAMETERS.value('CN_CONVERSION_TYPE',g_cached_org_id),
                                                       l_quotadetails.credit_type_id,
                                                       l_from_currency,
                                                       p_proj_comp_rec.currency_code,
                                                       g_cached_org_id);
      l_tot_target_amt := cn_api.convert_to_repcurr(l_tot_target_amt,
                                                    p_proj_comp_rec.calc_date,
                                                    CN_SYSTEM_PARAMETERS.value('CN_CONVERSION_TYPE',g_cached_org_id),
                                                    l_quotadetails.credit_type_id,
                                                    l_from_currency,
                                                    p_proj_comp_rec.currency_code,
                                                    g_cached_org_id);
    EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('CN','CN_CONV_CURR_FAIL');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END;

    IF l_tot_target_itd <> 0 THEN
      l_quota_achievement := (l_tot_inp_ach_itd + l_tot_proj_comm_amt)/ l_tot_target_itd * 100;
    ELSE
      l_quota_achievement := 0;
    END IF;

    UPDATE  cn_proj_compensation_gtt
    SET     PE_NAME       =   l_quotadetails.quota_name,
            PROJ_COMP     =   l_tot_proj_comm_amt,
            PE_QUOTA      =   l_tot_target_amt,
            PE_ACHIEVED   =   l_quota_achievement,
            PE_CREDIT     =   l_tot_inp_ach_itd+l_tot_proj_comm_amt,
            PE_INTERVAL   =   l_quotadetails.interval_type_id,
            CALC_STATUS   =   l_return_status
    WHERE   LINE_ID       =   p_proj_comp_rec.line_id;

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.count_and_get(p_count      =>      x_msg_count,
                                      p_data       =>      x_msg_data,
                                      p_encoded    =>      FND_API.G_FALSE );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.count_and_get(p_count      =>      x_msg_count,
                                  p_data       =>      x_msg_data,
                                  p_encoded    =>      FND_API.G_FALSE );

      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.count_and_get(p_count      =>      x_msg_count,
                                    p_data       =>    x_msg_data,
                                    p_encoded    =>    FND_API.G_FALSE );

END processRows;

Procedure calculate_Commission
(
  p_api_version         IN NUMBER,
  p_init_msg_list       IN VARCHAR2 := FND_API.G_FALSE,
  x_inc_plnr_disclaimer OUT NOCOPY cn_repositories.income_planner_disclaimer%TYPE,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2
) IS
     l_api_name                CONSTANT VARCHAR2(30) := 'calculate_Commission';
     l_api_version             CONSTANT NUMBER       := 1.0;
     l_null_date               CONSTANT DATE         := to_date('31-12-9999','DD-MM-RRRR');

BEGIN
    null;
End calculate_Commission;

Procedure calculate_Commission
(
  p_api_version         IN NUMBER,
  p_init_msg_list       IN VARCHAR2 := FND_API.G_FALSE,
  p_org_id		IN NUMBER,
  x_inc_plnr_disclaimer OUT NOCOPY cn_repositories.income_planner_disclaimer%TYPE,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2
) IS
     l_api_name                CONSTANT VARCHAR2(30) := 'calculate_Commission';
     l_api_version             CONSTANT NUMBER       := 1.0;
     l_null_date               CONSTANT DATE         := to_date('31-12-9999','DD-MM-RRRR');

     l_return_status varchar2(1);
     l_msg_count number;
     l_msg_data varchar2(2000);

     l_inc_plnr_profile VARCHAR2(10) := '';

     CURSOR repositories_cr IS
     SELECT cpt.period_type period_type
     ,      cr.set_of_books_id set_of_books_id
     ,      cr.period_set_id   period_set_id
     ,      cr.period_type_id  period_type_id
     ,      cr.income_planner_disclaimer income_planner_disclaimer
     FROM cn_period_types cpt,cn_repositories cr
     WHERE cpt.period_type_id = cr.period_type_id
     AND   cpt.org_id = cr.org_id
     AND   cr.org_id = p_org_id;

     CURSOR proj_comp_cr IS
     SELECT *
     FROM
     cn_proj_compensation_gtt
     WHERE  salesrep_id IS NOT NULL
     AND    period_id   IS NOT NULL
     AND    ruleset_id  IS NOT NULL;

     CURSOR proj_comp_srp_cr IS
     SELECT line_id
     FROM   cn_proj_compensation_gtt
     WHERE  salesrep_id IS NULL;

     CURSOR proj_comp_prd_cr IS
     SELECT line_id
     FROM   cn_proj_compensation_gtt
     WHERE  period_id IS NULL;

     CURSOR proj_comp_rs_cr IS
     SELECT line_id
     FROM   cn_proj_compensation_gtt
     WHERE  ruleset_id IS NULL;

     l_projcomp        proj_comp_cr%ROWTYPE;
     l_repositories    repositories_cr%ROWTYPE;

     TYPE l_salesrep_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
     TYPE l_period_type   IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
     TYPE l_ruleset_type  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

     l_salesrep_tbl dbms_utility.uncl_array;
     l_period_tbl   dbms_utility.uncl_array;
     l_ruleset_tbl  dbms_utility.uncl_array;

     linenos VARCHAR2(1000):='';
     tablength BINARY_INTEGER := 0;

BEGIN

-- Standard Start of API savepoint
    SAVEPOINT calculate_Commission;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Standard Call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,l_api_name,G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.to_Boolean(p_init_msg_list)  THEN
      FND_MSG_PUB.initialize;
    END IF;

    MO_GLOBAL.SET_POLICY_CONTEXT ('S',p_org_id);
    g_cached_org_id := p_org_id;

    x_inc_plnr_disclaimer := '';

    IF g_cached_org_id = -99 THEN
      g_cached_org_append := '_MINUS99';
    ELSE
      g_cached_org_append := '_' || g_cached_org_id;
    END IF;

    OPEN  repositories_cr;
    FETCH repositories_cr INTO l_repositories;
    CLOSE repositories_cr;

    UPDATE cn_proj_compensation_gtt cpcg
    SET line_id = cn_proj_compensation_gtt_s.NEXTVAL
    , cpcg.period_id =
    (
     SELECT cps.period_id period_id
     FROM   cn_period_statuses cps
     WHERE  cps.period_set_id  = l_repositories.period_set_id
     AND    cps.period_type_id = l_repositories.period_type_id
     AND    cpcg.calc_date between cps.start_date and cps.end_Date
     AND    cps.period_status = 'O'
     AND    cps.org_id = g_cached_org_id
   )
    , cpcg.salesrep_id = (
                          SELECT salesrep_id
                          FROM cn_salesreps cs
                          WHERE cs.resource_id = cpcg.resource_id
                          AND cs.org_id = g_cached_org_id
                         )
    , cpcg.ruleset_id =  (
                          SELECT ruleset_id
                          FROM cn_rulesets cr
                          WHERE  cpcg.calc_date BETWEEN cr.start_date AND nvl(cr.end_date,cpcg.calc_date)
                          AND    cr.module_type = 'PECLS'
                          and    cr.org_id = g_cached_org_id
                         )
    , cpcg.pe_name       =   FND_API.G_MISS_CHAR
    , cpcg.proj_comp     =   0
    , cpcg.pe_quota      =   0
    , cpcg.pe_achieved   =   0
    , cpcg.pe_credit     =   0
    , cpcg.pe_interval   =   FND_API.G_MISS_NUM
    , cpcg.calc_status   =   FND_API.G_RET_STS_ERROR;

    OPEN  proj_comp_srp_cr;
    FETCH proj_comp_srp_cr BULK COLLECT INTO l_salesrep_tbl;

    IF l_salesrep_tbl.count > 0 THEN
	    dbms_utility.table_to_comma(l_salesrep_tbl,tablength,linenos);
            x_return_status := FND_API.G_RET_STS_ERROR;
	    fnd_message.set_name('CN','CN_INVALID_RES_ID');
	    fnd_message.set_token('LINE_NO', linenos);
            fnd_msg_pub.ADD;
    END IF;

    CLOSE proj_comp_srp_cr;

    OPEN  proj_comp_prd_cr;
    FETCH proj_comp_prd_cr BULK COLLECT INTO l_period_tbl;

    IF l_period_tbl.count > 0 THEN
	    dbms_utility.table_to_comma(l_period_tbl,tablength,linenos);
	    x_return_status := FND_API.G_RET_STS_ERROR;
	    fnd_message.set_name('CN','CN_INVALID_PRD_ID');
	    fnd_message.set_token('LINE_NO', linenos);
            fnd_msg_pub.ADD;
    END IF;

    CLOSE proj_comp_prd_cr;

    OPEN  proj_comp_rs_cr;
    FETCH proj_comp_rs_cr BULK COLLECT INTO l_ruleset_tbl;

    IF l_ruleset_tbl.count > 0 THEN
	    dbms_utility.table_to_comma(l_ruleset_tbl,tablength,linenos);
            x_return_status := FND_API.G_RET_STS_ERROR;
	    fnd_message.set_name('CN','CN_INVALID_RS_ID');
	    fnd_message.set_token('LINE_NO', linenos);
            fnd_msg_pub.ADD;
    END IF;

    CLOSE proj_comp_rs_cr;

    FOR proj_comp_rec IN proj_comp_cr LOOP
      processRows(p_proj_comp_rec => proj_comp_rec,
                  x_return_status => l_return_status,
                  x_msg_count     => l_msg_count,
                  x_msg_data      => l_msg_data);

      IF l_return_status <> 'S' THEN
        x_return_status := l_return_status;
        x_msg_count     := l_msg_count;
        x_msg_data      := l_msg_data;
      END IF;
    END LOOP;

     --FND_PROFILE.GET('CN_CUST_DISCLAIMER',l_inc_plnr_profile);
     CN_SYSTEM_PARAMETERS.GET_SYSTEM_PARAMETER(P_PROFILE_CODE => 'CN_CUST_DISCLAIMER',P_ORG_ID => g_cached_org_id,X_VALUE => l_inc_plnr_profile);

      IF NVL(l_inc_plnr_profile,'N') = 'N' THEN
        x_inc_plnr_disclaimer :=   FND_API.G_MISS_CHAR; -- temporarily hardcoded for testing purpose.  need to add a new message
      ELSE
        x_inc_plnr_disclaimer := l_repositories.income_planner_disclaimer ;
      END IF;

        FND_MSG_PUB.count_and_get(p_count      =>      x_msg_count,
                                          p_data       =>      x_msg_data,
                                          p_encoded    =>      FND_API.G_FALSE );


  EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.count_and_get(p_count      =>      x_msg_count,
                                      p_data       =>      x_msg_data,
                                      p_encoded    =>      FND_API.G_FALSE );


      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.count_and_get(p_count      =>      x_msg_count,
                                  p_data       =>      x_msg_data,
                                  p_encoded    =>      FND_API.G_FALSE );


      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.count_and_get(p_count      =>      x_msg_count,
                                    p_data       =>      x_msg_data,
                                    p_encoded    =>      FND_API.G_FALSE );

End calculate_Commission;


End CN_COMMISSION_CALC_PVT;

/
