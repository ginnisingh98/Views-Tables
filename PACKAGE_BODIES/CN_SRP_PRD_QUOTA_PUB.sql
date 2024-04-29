--------------------------------------------------------
--  DDL for Package Body CN_SRP_PRD_QUOTA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SRP_PRD_QUOTA_PUB" AS
  /*$Header: cnvspdbb.pls 120.2 2005/10/27 16:05:39 mblum noship $*/

G_PKG_NAME                  CONSTANT VARCHAR2(30):='CN_SRP_PRD_QUOTA_PUB';


PROCEDURE Distribute_Srp_Prd_Quota
(       p_api_version              IN   NUMBER   := CN_API.G_MISS_NUM,
        p_init_msg_list            IN   VARCHAR2 := CN_API.G_FALSE,
        p_commit                   IN   VARCHAR2 := CN_API.G_FALSE,
        p_validation_level         IN   NUMBER   := CN_API.G_VALID_LEVEL_FULL,
        p_salesrep_name            IN   CN_SALESREPS.NAME%TYPE,
        p_employee_number          IN   CN_SALESREPS.EMPLOYEE_NUMBER%TYPE,
        p_role_name                IN   CN_ROLES.NAME%TYPE,
        p_cp_name                  IN   CN_COMP_PLANS.NAME%TYPE,
        p_srp_plan_start_date      IN   CN_SRP_PLAN_ASSIGNS.START_DATE%TYPE,
        p_srp_plan_end_date        IN   CN_SRP_PLAN_ASSIGNS.END_DATE%TYPE,
        p_pe_name                  IN   CN_QUOTAS.NAME%TYPE,
        p_target_amount            IN   CN_SRP_QUOTA_ASSIGNS.target%TYPE,
        p_fixed_amount             IN   CN_SRP_QUOTA_ASSIGNS.payment_amount%TYPE,
        p_performance_goal         IN   CN_SRP_QUOTA_ASSIGNS.performance_goal%TYPE,
        p_even_distribute          IN   VARCHAR2,
        p_srp_prd_quota_tbl        IN   srp_prd_quota_tbl_type,
        p_org_id                   IN   NUMBER,
        x_return_status            OUT NOCOPY VARCHAR2,
        x_msg_count                OUT NOCOPY NUMBER,
        x_msg_data                 OUT NOCOPY VARCHAR2

  ) IS

     l_api_name           CONSTANT VARCHAR2(30)  := 'Distribute_Srp_Prd_Quota';
     l_api_version        CONSTANT NUMBER        := 1.0;

     l_quota_id             CN_QUOTAS.quota_id%TYPE;
     l_salesrep_id          CN_SALESREPS.salesrep_id%TYPE;
     l_role_id              CN_ROLES.role_id%TYPE;
     l_comp_plan_id         CN_COMP_PLANS.comp_plan_id%TYPE;
     l_srp_plan_assign_id   CN_SRP_PLAN_ASSIGNS.srp_plan_assign_id%TYPE;
     l_srp_quota_assign_id  CN_SRP_quota_ASSIGNS.srp_quota_assign_id%TYPE;
     l_customized_flag      CN_SRP_quota_ASSIGNS.customized_flag%TYPE;

     l_period_target_unit_code   CN_SRP_quota_ASSIGNS.period_target_unit_code%TYPE;

     tbl_period_id               CN_PERIOD_STATUSES.period_id%TYPE;
     tbl_srp_period_quota_id     CN_SRP_PERIOD_QUOTAS.srp_period_quota_id%TYPE;
     tbl_quarter_num             CN_SRP_PERIOD_QUOTAS_V.quarter_num%TYPE;
     tbl_period_year             CN_SRP_PERIOD_QUOTAS_V.period_year%TYPE;
     l_prd_count             NUMBER;
     l_upd_srp_quota_assign  VARCHAR2(1);
     l_commission_payed_ptd  CN_SRP_PERIOD_QUOTAS.commission_payed_ptd%TYPE;

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

     l_status              varchar2(4000);
     l_loading_status      varchar2(50);
     l_return_status       VARCHAR2(50);
     l_msg_count           NUMBER;
     l_msg_data            VARCHAR2(2000);
     l_org_id              NUMBER;

      CURSOR l_quota_id_cr (p_quota_name VARCHAR2) IS
      SELECT *
      from cn_quotas
      where name = p_quota_name AND delete_flag = 'N';

      CURSOR l_salesrep_id_cr (p_salesrep_name VARCHAR2,
			       p_employee_number VARCHAR2) IS
      SELECT *
      from cn_salesreps
	where name = p_salesrep_name
	and employee_number = p_employee_number
	AND org_id = l_org_id;

      CURSOR l_role_id_cr (p_role_name VARCHAR2) IS
      SELECT *
      from cn_roles
      where name = p_role_name;

      CURSOR l_comp_plan_id_cr (p_comp_plan_name VARCHAR2) IS
      SELECT *
      from cn_comp_plans
	where name = p_comp_plan_name
	  AND org_id = l_org_id;

      CURSOR l_srp_plan_assign_id_cr (p_salesrep_id NUMBER,
				      p_role_id NUMBER,
				      p_comp_plan_id NUMBER,
				      p_srp_plan_sd DATE,
				      p_srp_plan_ed DATE) IS
      SELECT *
      from cn_srp_plan_assigns
      where salesrep_id = p_salesrep_id
        and role_id = p_role_id
        and comp_plan_id = p_comp_plan_id
        and start_date =  p_srp_plan_sd
        and end_date = p_srp_plan_ed
	AND org_id   = l_org_id;

      CURSOR l_srp_quota_assign_id_cr (p_srp_plan_assign_id NUMBER,
				       p_quota_id NUMBER) IS
      SELECT *
      from cn_srp_quota_assigns
	where srp_plan_assign_id = p_srp_plan_assign_id
	and quota_id = p_quota_id;

      CURSOR l_srp_prd_quota_cr(p_srp_quota_assign_id NUMBER) IS
	  SELECT *
	  FROM cn_srp_period_quotas_v
	  WHERE srp_quota_assign_id = p_srp_quota_assign_id;

      CURSOR f_quota_row(p_quota_id NUMBER) IS
      SELECT *
      from cn_quotas
      where quota_id = p_quota_id AND delete_flag = 'N';

      CURSOR tbl_period_quota_info_cr(p_period_id NUMBER,
				      p_srp_quota_assign_id NUMBER) IS
      select *
	from cn_srp_period_quotas_v
	where srp_quota_assign_id = p_srp_quota_assign_id
	and period_id = p_period_id;

      CURSOR l_period_id_cr(p_period_name VARCHAR2) IS
       select *
	 from cn_period_statuses
	 where period_name = p_period_name
	   AND org_id = l_org_id;

      f_quota_row_rec     CN_QUOTAS%ROWTYPE;
      f_quota_id_rec      CN_QUOTAS%ROWTYPE;
      f_salesrep_id_rec   CN_SALESREPS%ROWTYPE;
      f_role_id_rec       CN_ROLES%ROWTYPE;
      f_comp_plan_id_rec  CN_COMP_PLANS%ROWTYPE;
      f_srp_plan_assign_id_rec   CN_SRP_PLAN_ASSIGNS%ROWTYPE;
      f_srp_quota_assign_id_rec  CN_SRP_QUOTA_ASSIGNS%ROWTYPE;
      f_period_id_rec            CN_PERIOD_STATUSES%ROWTYPE;
      f_period_quota_info_rec    cn_srp_period_quotas_v%ROWTYPE;



BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Distribute_Srp_Prd_Quota;
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

   -- 0. if the org ID is valid
   l_org_id := p_org_id;
   mo_global.validate_orgid_pub_api
     (org_id => l_org_id,
      status => l_status);

   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
		     'cn.plsql.cn_srp_prd_quota_pub.distribute_srp_prd_quota.org_validate',
                     'Validated org_id = ' || l_org_id || ' status = ' || l_status);
   end if;

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



   -- 2. get the salesrep_id using salesrep_name and employee_number
   IF  p_salesrep_name IS NULL
     THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_INPUT_CANT_NULL');
	 FND_MESSAGE.SET_TOKEN('INPUT_NAME', cn_api.get_lkup_meaning('SR_NAME', 'INPUT_TOKEN'));
	 FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   OPEN l_salesrep_id_cr(p_salesrep_name, p_employee_number);
   FETCH l_salesrep_id_cr into f_salesrep_id_rec;

   IF (l_salesrep_id_cr%NOTFOUND)
     THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_SRP_NOT_FOUND');
	 FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   CLOSE l_salesrep_id_cr;
   l_salesrep_id := f_salesrep_id_rec.salesrep_id;

   -- 3. get Role ID

   IF  p_role_name IS NULL
     THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_INPUT_CANT_NULL');
	 FND_MESSAGE.SET_TOKEN('INPUT_NAME', cn_api.get_lkup_meaning('ROLE_NAME', 'INPUT_TOKEN'));
	 FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   OPEN l_role_id_cr(p_role_name);
   FETCH l_role_id_cr into f_role_id_rec;

   IF (l_role_id_cr%NOTFOUND)
     THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_QM_INVALID_SRPROLE');
	 FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   CLOSE l_role_id_cr;

   l_role_id := f_role_id_rec.role_id;

   -- 4. get Comp Plan ID
   IF  p_cp_name IS NULL
     THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_INPUT_CANT_NULL');
	 FND_MESSAGE.SET_TOKEN('INPUT_NAME', cn_api.get_lkup_meaning('CP_NAME', 'INPUT_TOKEN'));
	 FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   OPEN l_comp_plan_id_cr(p_cp_name);
   FETCH l_comp_plan_id_cr into f_comp_plan_id_rec;

   IF (l_comp_plan_id_cr%NOTFOUND)
     THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_CP_NOT_EXIST');
	 FND_MESSAGE.SET_TOKEN ('CP_NAME' , p_cp_name);
	 FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   CLOSE l_comp_plan_id_cr;

   l_comp_plan_id := f_comp_plan_id_rec.comp_plan_id;

   -- 5. get srp_plan_assign_id using salesrep_id, role_id, comp_plan_id, start_date, end_date

   IF  p_srp_plan_start_date IS NULL
     THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_INPUT_CANT_NULL');
	 FND_MESSAGE.SET_TOKEN('INPUT_NAME', cn_api.get_lkup_meaning('SD', 'INPUT_TOKEN'));
	 FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   OPEN l_srp_plan_assign_id_cr(l_salesrep_id, l_role_id, l_comp_plan_id, p_srp_plan_start_date, p_srp_plan_end_date);
   FETCH l_srp_plan_assign_id_cr into f_srp_plan_assign_id_rec;

   IF (l_srp_plan_assign_id_cr%NOTFOUND)
     THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	FND_MESSAGE.SET_NAME ('CN' , 'CN_SRP_PLN_ASSIGN_NOT_EXIST');
	FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   l_srp_plan_assign_id := f_srp_plan_assign_id_rec.srp_plan_assign_id;

   -- 6. get the srp_quota_assign_id

   OPEN l_srp_quota_assign_id_cr(l_srp_plan_assign_id, l_quota_id);
   FETCH l_srp_quota_assign_id_cr into f_srp_quota_assign_id_rec;

   IF (l_srp_quota_assign_id_cr%NOTFOUND)
     THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_QUOTA_ASSIGN_NOT_EXIST');
	 FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   l_srp_quota_assign_id := f_srp_quota_assign_id_rec.srp_quota_assign_id;
   l_customized_flag := f_srp_quota_assign_id_rec.customized_flag;

   If l_customized_flag <> 'Y'
     THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_PE_NOT_CUSTOMIZABLE');
	 FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   select nvl(target, 0)
     into f_target_amount
     from cn_srp_quota_assigns
     where srp_quota_assign_id = l_srp_quota_assign_id;


   -- 2. If target_amount, fixed_amount and Performance Goal input is null, select from cn_quotas, else update cn_quotas
   -- target_amount check and update

   l_upd_srp_quota_assign := 'N';

   IF p_target_amount is NULL THEN

      select nvl(target, 0)
	into f_target_amount
	from cn_srp_quota_assigns
	where srp_quota_assign_id = l_srp_quota_assign_id;

    ELSE
      IF p_target_amount <> f_target_amount THEN

	 f_target_amount := p_target_amount;

	 l_upd_srp_quota_assign := 'Y';

      END IF;
   END IF;

   select nvl(payment_amount, 0)
     into f_fixed_amount
     from cn_srp_quota_assigns
     where srp_quota_assign_id = l_srp_quota_assign_id;

   -- fixed Amount check and update
   IF p_fixed_amount is NULL THEN

      select nvl(payment_amount, 0)
	into f_fixed_amount
	from cn_srp_quota_assigns
	where srp_quota_assign_id = l_srp_quota_assign_id;

   ELSE

      IF p_fixed_amount <> nvl(f_fixed_amount,0) THEN

	 f_fixed_amount := p_fixed_amount;
	 l_upd_srp_quota_assign := 'Y';

      END IF;
   END IF;

   select nvl(performance_goal, 0)
     into f_performance_goal
     from cn_srp_quota_assigns
     where srp_quota_assign_id = l_srp_quota_assign_id;

   -- performance goal check and update

    IF p_performance_goal is NULL THEN

       select nvl(performance_goal, 0)
	 into f_performance_goal
	 from cn_srp_quota_assigns
	 where srp_quota_assign_id = l_srp_quota_assign_id;

     ELSE
       IF p_performance_goal <> nvl(f_performance_goal,0) THEN

          f_performance_goal := p_performance_goal;
	  l_upd_srp_quota_assign := 'Y';

       END IF;
   END IF;


   If l_upd_srp_quota_assign = 'Y' THEN


      CN_SRP_CUSTOMIZE_PUB.update_srp_quota_assign
	(p_api_version           	=> 1.0,
	 p_init_msg_list		        => 'T',
	 p_commit	    		    => 'F',
	 p_validation_level	     	=> 100,
	 p_srp_quota_assign_id       => l_srp_quota_assign_id,
	 p_customized_flag           => l_customized_flag,
	 p_quota                     => f_target_amount,
	 p_fixed_amount              => f_fixed_amount,
	 p_goal                      => f_performance_goal,
	 x_return_status		        => l_return_status,
	 x_msg_count			=> l_msg_count,
	 x_msg_data			=> l_msg_data,
	 x_loading_status		=> l_loading_status,
	 x_status                => l_status);

   END IF; --If l_upd_srp_quota_assign = 'Y'


   -- 3. if even distribute is Yes, we divide the Variables by the period number.
   IF p_even_distribute = 'Y' THEN

      -- Modified to call the Distribute_Target API to distribute target, 2527429

--      CN_SRP_PRD_QUOTA_PVT.distribute_target
      CN_SRP_PERIOD_QUOTAS_PKG.Distribute_Target
	(  x_srp_quota_assign_id => l_srp_quota_assign_id,
	   x_target	         => 0,
	   x_period_target_unit_code => NULL);


	-- 4. IF not evenly distributed, we update the cn_period_quotas using the values in the table.
    ELSE --IF p_even_distribute = 'Y' THEN

      IF p_srp_prd_quota_tbl.COUNT > 0 THEN

	 FOR i IN 1 .. p_srp_prd_quota_tbl.COUNT  LOOP

	    IF  p_srp_prd_quota_tbl(i).period_name IS NULL
	      THEN
	       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		  FND_MESSAGE.SET_NAME ('CN' , 'CN_INPUT_CANT_NULL');
		  FND_MESSAGE.SET_TOKEN('INPUT_NAME', cn_api.get_lkup_meaning('PERIOD_NAME', 'INPUT_TOKEN'));
		  FND_MSG_PUB.Add;
	       END IF;
	       RAISE FND_API.G_EXC_ERROR ;
	    END IF;

	    OPEN l_period_id_cr(p_srp_prd_quota_tbl(i).period_name);
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

	    OPEN tbl_period_quota_info_cr(tbl_period_id, l_srp_quota_assign_id);
	    FETCH tbl_period_quota_info_cr into f_period_quota_info_rec;
	    IF (tbl_period_quota_info_cr%NOTFOUND)
	      THEN
	       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		  FND_MESSAGE.SET_NAME ('CN' , 'CN_SRP_PERIOD_QUOTA_NOT_EXIST');
		  FND_MSG_PUB.Add;
	       END IF;
	       RAISE FND_API.G_EXC_ERROR ;
	    END IF;

	    CLOSE tbl_period_quota_info_cr;

	    tbl_srp_period_quota_id := f_period_quota_info_rec.srp_period_quota_id;
	    tbl_period_id := f_period_quota_info_rec.period_id;
	    tbl_quarter_num := f_period_quota_info_rec.quarter_num;
	    tbl_period_year := f_period_quota_info_rec.period_year;

	    select commission_payed_ptd
	      into l_commission_payed_ptd
	      from cn_srp_period_quotas
	      where srp_period_quota_id =  tbl_srp_period_quota_id;

	    CN_SRP_PERIOD_QUOTAS_PKG.Begin_Record
	      (x_operation  	     	=> 'UPDATE'
	       ,x_period_target_unit_code	=> f_srp_quota_assign_id_rec.period_target_unit_code
	       ,x_srp_period_quota_id 	=> tbl_srp_period_quota_id
	       ,x_srp_quota_assign_id 	=> l_srp_quota_assign_id
	       ,x_srp_plan_assign_id  	=> l_srp_plan_assign_id
	       ,x_quota_id            	=> l_quota_id
	       ,x_period_id           	=> tbl_period_id
	       ,x_target_amount       	=> p_srp_prd_quota_tbl(i).PERIOD_TARGET
	       ,x_period_payment		=>p_srp_prd_quota_tbl(i).PERIOD_PAYMENT
	       ,x_performance_goal          => p_srp_prd_quota_tbl(i).PERFORMANCE_GOAL
	       ,x_quarter_num	     	=> tbl_quarter_num
	       ,x_period_year 	    => tbl_period_year
	       ,x_quota_type_code     => f_srp_quota_assign_id_rec.quota_type_code
	       ,x_salesrep_id            => l_salesrep_id
	       ,x_end_date               => NULL
	       ,x_commission_payed_ptd   => l_commission_payed_ptd
	       ,x_creation_date		=> sysdate
	       ,x_created_by			=> fnd_global.user_id
	      ,x_last_update_date	=> sysdate
	      ,x_last_updated_by		=> fnd_global.user_id
	      ,x_last_update_login	=> fnd_global.login_id);

	 END LOOP;

      END IF; --IF p_srp_prd_quota_tbl%COUNT > 0

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
      ROLLBACK TO Distribute_Srp_Prd_Quota;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(p_count                 =>      x_msg_count             ,
	 p_data                   =>      x_msg_data              ,
	 p_encoded                =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Distribute_Srp_Prd_Quota;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(p_count                 =>      x_msg_count             ,
	 p_data                   =>      x_msg_data              ,
	 p_encoded                =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      ROLLBACK TO Distribute_Srp_Prd_Quota;
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
END Distribute_Srp_Prd_Quota;


END CN_SRP_PRD_QUOTA_PUB;

/
