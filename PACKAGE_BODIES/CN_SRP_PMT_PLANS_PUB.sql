--------------------------------------------------------
--  DDL for Package Body CN_SRP_PMT_PLANS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SRP_PMT_PLANS_PUB" AS
/* $Header: cnpsppab.pls 120.4 2005/10/27 16:03:49 mblum noship $ */

G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_SRP_PMT_PLANS_PUB';
G_FILE_NAME                 CONSTANT VARCHAR2(12) := 'cnpsppab.pls';

G_EMP_NUM          CONSTANT VARCHAR2(80)
                   := cn_api.get_lkup_meaning('EMP_NUM','SRP_OBJECT_TYPE');
G_PMT_PLAN         CONSTANT VARCHAR2(80)
                   := cn_api.get_lkup_meaning('PMT_PLAN','SRP_OBJECT_TYPE');
G_SALESREP         CONSTANT VARCHAR2(80)
                   := cn_api.get_lkup_meaning('SALESREP','SRP_OBJECT_TYPE');

--| ----------------------------------------------------------------------+-+
--| Procedure : chk_existence_get_id
--| Desc : Procedure to get ids and check existence
--| ----------------------------------------------------------------------+
PROCEDURE chk_existence_get_id
  (
   x_return_status          OUT NOCOPY VARCHAR2 ,
   x_msg_count              OUT NOCOPY NUMBER   ,
   x_msg_data               OUT NOCOPY VARCHAR2 ,
   p_srp_pmt_plans_rec      IN  srp_pmt_plans_rec_type,
   x_srp_pmt_plans_row      IN OUT NOCOPY cn_srp_pmt_plans%ROWTYPE ,
   x_srp_start_date         OUT NOCOPY cn_salesreps.start_date_active%TYPE,
   x_srp_end_date           OUT NOCOPY cn_salesreps.end_date_active%TYPE,
   x_pp_start_date          OUT NOCOPY cn_pmt_plans.start_date%TYPE,
   x_pp_end_date            OUT NOCOPY cn_pmt_plans.end_date%TYPE,
   p_action                 IN  VARCHAR2 := 'VALIDATE',
   p_loading_status         IN  VARCHAR2,
   x_loading_status         OUT NOCOPY VARCHAR2
   )
  IS
     l_api_name       CONSTANT VARCHAR2(30) := 'chk_existence_get_id';
     l_dummy          NUMBER;
     l_loading_status varchar2(50);

BEGIN
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status;
   -- API body
   -- Check payment plan cannot null or missing
   IF (cn_api.chk_miss_null_char_para
       (p_char_para => p_srp_pmt_plans_rec.pmt_plan_name,
	p_obj_name => G_PMT_PLAN,
	p_loading_status => x_loading_status,
	x_loading_status => x_loading_status) = FND_API.G_TRUE) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- migrate org ID
   x_srp_pmt_plans_row.org_id := p_srp_pmt_plans_rec.org_id;

   -- Check if Payment Plan exist
   BEGIN
      SELECT pmt_plan_id, credit_type_id,
	     start_date, end_date
	INTO x_srp_pmt_plans_row.pmt_plan_id,
	     x_srp_pmt_plans_row.credit_type_id,
	     x_pp_start_date,x_pp_end_date
	FROM cn_pmt_plans_all
       WHERE name = p_srp_pmt_plans_rec.pmt_plan_name
         AND org_id = p_srp_pmt_plans_rec.org_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
	 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.SET_NAME ('CN' , 'CN_PP_NOT_EXIST');
	    FND_MESSAGE.SET_TOKEN('PP_NAME',p_srp_pmt_plans_rec.pmt_plan_name);
	    FND_MSG_PUB.Add;
	 END IF;
	 x_loading_status := 'CN_PP_NOT_EXIST';
	 RAISE FND_API.G_EXC_ERROR ;
   END;
   -- Check if Salesrep exist
   cn_api.chk_and_get_salesrep_id
     (p_emp_num   => p_srp_pmt_plans_rec.emp_num
      ,p_type     => p_srp_pmt_plans_rec.salesrep_type
      ,p_org_id   => p_srp_pmt_plans_rec.org_id
      ,x_salesrep_id => x_srp_pmt_plans_row.salesrep_id
      ,x_return_status => x_return_status
      ,x_loading_status => l_loading_status);
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS  ) THEN
      x_loading_status := l_loading_status;
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- get salesrep start date, end date
   BEGIN
      SELECT start_date_active,end_date_active
	INTO x_srp_start_date,x_srp_end_date
        FROM cn_salesreps
	WHERE salesrep_id = x_srp_pmt_plans_row.salesrep_id
	  AND org_id = x_srp_pmt_plans_row.org_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
	 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.SET_NAME ('CN' , 'CN_SRP_NOT_EXIST');
	    FND_MSG_PUB.Add;
	 END IF;
	 x_loading_status := 'CN_SRP_NOT_EXIST';
	 RAISE FND_API.G_EXC_ERROR ;
   END;

   -- If p_action = 'GETOLDREC'
   --    called by update(), need to get old_rec data
   BEGIN
      IF p_action = 'GETOLDREC'  THEN
	 SELECT *
	   INTO x_srp_pmt_plans_row
	   FROM cn_srp_pmt_plans_all
	   WHERE pmt_plan_id = x_srp_pmt_plans_row.pmt_plan_id
	   AND   salesrep_id = x_srp_pmt_plans_row.salesrep_id
           AND   trunc(start_date) = trunc(p_srp_pmt_plans_rec.start_date)
	   ;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
	 x_srp_pmt_plans_row.srp_pmt_plan_id := NULL;
   END;
   -- End of API body.
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
END chk_existence_get_id;

--| ----------------------------------------------------------------------+-+
--| Procedure : valid_pp_assign
--| Desc : Procedure to validate pmt plan assignment to a salesrep
--| ----------------------------------------------------------------------+
PROCEDURE valid_pp_assign
  (
   x_return_status          OUT NOCOPY VARCHAR2 ,
   x_msg_count              OUT NOCOPY NUMBER   ,
   x_msg_data               OUT NOCOPY VARCHAR2 ,
   p_srp_pmt_plans_rec      IN  srp_pmt_plans_rec_type,
   x_srp_pmt_plans_row      IN  OUT NOCOPY cn_srp_pmt_plans%ROWTYPE ,
   p_action                 IN  VARCHAR2,
   p_loading_status         IN  VARCHAR2 ,
   x_loading_status         OUT NOCOPY VARCHAR2
   )
  IS
     l_api_name      CONSTANT VARCHAR2(30) := 'valid_pp_assign';
     --Bug 3432689 by Julia Huang on 4/29/04.

     l_dummy         NUMBER;
     l_dummy2        NUMBER;
     l_srp_start_date cn_salesreps.start_date_active%TYPE;
     l_srp_end_date   cn_salesreps.end_date_active%TYPE;
     l_pp_start_date  cn_pmt_plans.start_date%TYPE;
     l_pp_end_date    cn_pmt_plans.end_date%TYPE;
     l_pp_min         cn_pmt_plans.minimum_amount%TYPE;
     l_pp_max         cn_pmt_plans.maximum_amount%TYPE;
     l_payment_group_code cn_pmt_plans.payment_group_code%TYPE;

     -- Cursor to get the quota id and credit type id list from
     -- cn_srp_plan_assigns which falls into
     -- the date range for credit_type_id check.
     CURSOR get_quota_ids_csr (l_salesrep_id NUMBER,
			       l_start_date DATE, l_end_date DATE) IS
       SELECT cq.quota_id,cq.credit_type_id
       FROM cn_srp_plan_assigns cspa, cn_srp_quota_assigns csqa , cn_quotas cq
       WHERE cspa.salesrep_id = l_salesrep_id
         AND cspa.start_date <= l_start_date
         --Bug 3432689 by Julia Huang on 4/29/04.
         --AND nvl(l_end_date,l_null_date) <= nvl(cspa.end_date,l_null_date)
         AND nvl(l_end_date, nvl(cspa.end_date, l_start_date)) <= nvl(cspa.end_date, nvl(l_end_date,l_start_date))
         AND csqa.srp_plan_assign_id = cspa.srp_plan_assign_id
         AND csqa.quota_id = cq.quota_id;

BEGIN
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status;

   -- API body
   -- Get IDs by using Names. Also check the existence
   chk_existence_get_id
     ( x_return_status  => x_return_status,
       x_msg_count      => x_msg_count,
       x_msg_data       => x_msg_data,
       p_srp_pmt_plans_rec => p_srp_pmt_plans_rec,
       x_srp_pmt_plans_row => x_srp_pmt_plans_row,
       x_srp_start_date => l_srp_start_date,
       x_srp_end_date   => l_srp_end_date,
       x_pp_start_date  => l_pp_start_date,
       x_pp_end_date    => l_pp_end_date,
       p_action         => p_action,
       p_loading_status => x_loading_status,
       x_loading_status => x_loading_status
       );
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS  ) THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF x_srp_pmt_plans_row.srp_pmt_plan_id IS NOT NULL AND
      p_action <> 'UPDATE' THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	 FND_MESSAGE.Set_Name('CN', 'CN_SRP_PMT_PLAN_EXIST');
	 FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_SRP_PMT_PLAN_EXIST';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- Get correct start date if it's null
   IF p_srp_pmt_plans_rec.start_date IS NULL THEN
      IF l_srp_start_date < l_pp_start_date THEN
	 x_srp_pmt_plans_row.start_date := l_pp_start_date;
       ELSE
	 x_srp_pmt_plans_row.start_date := l_srp_start_date;
      END IF;
    ELSE
      x_srp_pmt_plans_row.start_date := p_srp_pmt_plans_rec.start_date;
   END IF ;

   x_srp_pmt_plans_row.end_date := p_srp_pmt_plans_rec.end_date;


   -- Get correct min/max amount if it's null
   SELECT minimum_amount, maximum_amount
     INTO l_pp_min, l_pp_max
     FROM cn_pmt_plans
     WHERE pmt_plan_id = x_srp_pmt_plans_row.pmt_plan_id;

   SELECT
     Decode(p_srp_pmt_plans_rec.minimum_amount,FND_API.G_MISS_NUM,l_pp_min,
	    p_srp_pmt_plans_rec.minimum_amount),
     Decode(p_srp_pmt_plans_rec.maximum_amount,FND_API.G_MISS_NUM,l_pp_max,
	    p_srp_pmt_plans_rec.maximum_amount)
     INTO
     x_srp_pmt_plans_row.minimum_amount,
     x_srp_pmt_plans_row.maximum_amount
     FROM dual;

   -- End of API body.
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
END valid_pp_assign;

--| ----------------------------------------------------------------------+-+
--| Procedure : Create_Srp_Pmt_Plan
--| Desc : Procedure to create a new payment plan assignment to salesrep
--| ----------------------------------------------------------------------+

PROCEDURE Create_Srp_Pmt_Plan
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list	IN    VARCHAR2,
   p_commit	        IN    VARCHAR2,
   p_validation_level   IN    NUMBER,
   x_return_status	OUT NOCOPY  VARCHAR2,
   x_msg_count	        OUT NOCOPY  NUMBER,
   x_msg_data	        OUT NOCOPY  VARCHAR2,
   p_srp_pmt_plans_rec  IN    srp_pmt_plans_rec_type,
   x_srp_pmt_plan_id    OUT NOCOPY  NUMBER,
   x_loading_status     OUT NOCOPY  VARCHAR2
   ) IS

      l_api_name     CONSTANT VARCHAR2(30) := 'Create_Srp_Pmt_Plan';
      l_api_version  CONSTANT NUMBER  := 1.0;
      l_spp_rec      srp_pmt_plans_rec_type;
      l_spp_row      cn_srp_pmt_plans%ROWTYPE ;

      l_pmt_plan_id  cn_srp_pmt_plans.pmt_plan_id%TYPE;
      l_salesrep_id  cn_srp_pmt_plans.salesrep_id%TYPE;
      l_start_date   cn_srp_pmt_plans.start_date%TYPE;
      l_end_date     cn_srp_pmt_plans.end_date%TYPE;
      l_action       VARCHAR2(30) := 'CREATE';
      l_create_rec   cn_srp_pmt_plans_pvt.pmt_plan_assign_rec;
      l_org_id       NUMBER;
      l_status       VARCHAR2(1);

      -- Declaration for user hooks
      l_OAI_array    JTF_USR_HKS.oai_data_array_type;
      l_bind_data_id NUMBER ;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT	Create_Srp_Pmt_Plan;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     ( l_api_version ,p_api_version ,l_api_name ,G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_INSERTED';
   -- Assign the parameter to a local variable
   l_spp_rec := p_srp_pmt_plans_rec;

   --
   -- API body
   --

   --
   --Validate org id
   --
   l_org_id := l_spp_rec.org_id;
   mo_global.validate_orgid_pub_api
     (org_id => l_org_id,
      status => l_status);

   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
		     'cn.plsql.cn_srp_pmt_plans_pub.create_srp_pmt_plan.org_validate',
                     'Validated org_id = ' || l_org_id || ' status = ' || l_status);
   end if;
   l_spp_rec.org_id := l_org_id;

   -- Trim spaces before/after user input string, get Value-Id para assigned
   SELECT
     Decode(p_srp_pmt_plans_rec.pmt_plan_name,
	    FND_API.G_MISS_CHAR, NULL ,
	    Ltrim(Rtrim(p_srp_pmt_plans_rec.pmt_plan_name))),
     Decode(p_srp_pmt_plans_rec.salesrep_type,
	    FND_API.G_MISS_CHAR, NULL ,
	    Ltrim(Rtrim(p_srp_pmt_plans_rec.salesrep_type))),
     Decode(p_srp_pmt_plans_rec.emp_num,
	    FND_API.G_MISS_CHAR, NULL ,
	    Ltrim(Rtrim(p_srp_pmt_plans_rec.emp_num))),
     Decode(p_srp_pmt_plans_rec.start_date,
	    FND_API.G_MISS_DATE,To_date(NULL) ,
	    trunc(p_srp_pmt_plans_rec.start_date)),
     Decode(p_srp_pmt_plans_rec.end_date,
	    FND_API.G_MISS_DATE,To_date(NULL) ,
	    trunc(p_srp_pmt_plans_rec.end_date))
     INTO
     l_spp_rec.pmt_plan_name,
     l_spp_rec.salesrep_type,
     l_spp_rec.emp_num,
     l_spp_rec.start_date,
     l_spp_rec.end_date
     FROM dual;
   --
   -- Valid payment plan assignment
   --
   valid_pp_assign
     ( x_return_status  => x_return_status,
       x_msg_count      => x_msg_count,
       x_msg_data       => x_msg_data,
       p_srp_pmt_plans_rec => l_spp_rec,
       x_srp_pmt_plans_row => l_spp_row,
       p_action         => l_action,
       p_loading_status => x_loading_status,
       x_loading_status => x_loading_status
       );
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS  ) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   --
   -- User hooks
   --
   IF JTF_USR_HKS.Ok_to_Execute('CN_SRP_PMT_PLANS_PUB',
				'CREATE_SRP_PMT_PLAN',
				'B',
				'C')
     THEN
      cn_srp_pmt_plans_pub_cuhk.create_srp_pmt_plan_pre
	(p_api_version          => p_api_version,
	 p_init_msg_list	=> fnd_api.g_false,
	 p_commit	    	=> fnd_api.g_false,
	 p_validation_level	=> p_validation_level,
	 x_return_status        => x_return_status,
	 x_msg_count            => x_msg_count,
	 x_msg_data             => x_msg_data,
	 p_srp_pmt_plans_rec    => l_spp_rec,
	 x_srp_pmt_plan_id      => x_srp_pmt_plan_id,
	 x_loading_status       => x_loading_status
	 );

      IF ( x_return_status = FND_API.G_RET_STS_ERROR )
	THEN
	 RAISE FND_API.G_EXC_ERROR;
       ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
	 THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   IF JTF_USR_HKS.Ok_to_Execute('CN_SRP_PMT_PLANS_PUB',
				'CREATE_SRP_PMT_PLAN',
				'B',
				'V')
     THEN
      cn_srp_pmt_plans_pub_vuhk.create_srp_pmt_plan_pre
	(p_api_version          => p_api_version,
	 p_init_msg_list	=> fnd_api.g_false,
	 p_commit	    	=> fnd_api.g_false,
	 p_validation_level	=> p_validation_level,
	 x_return_status        => x_return_status,
	 x_msg_count            => x_msg_count,
	 x_msg_data             => x_msg_data,
	 p_srp_pmt_plans_rec    => l_spp_rec,
	 x_srp_pmt_plan_id      => x_srp_pmt_plan_id,
	 x_loading_status       => x_loading_status
	 );

      IF ( x_return_status = FND_API.G_RET_STS_ERROR )
	THEN
	 RAISE FND_API.G_EXC_ERROR;
       ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
	 THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;


   -- Call private API
   l_create_rec.pmt_plan_id    := l_spp_row.pmt_plan_id;
   l_create_rec.salesrep_id    := l_spp_row.salesrep_id;
   l_create_rec.org_id         := l_spp_row.org_id;
   l_create_rec.start_date     := l_spp_row.start_date;
   l_create_rec.end_date       := l_spp_row.end_date;
   l_create_rec.minimum_amount := l_spp_row.minimum_amount;
   l_create_rec.maximum_amount := l_spp_row.maximum_amount;
   l_create_rec.srp_role_id      := p_srp_pmt_plans_rec.srp_role_id;
   l_create_rec.role_pmt_plan_id := p_srp_pmt_plans_rec.role_pmt_plan_id;
   l_create_rec.lock_flag        := p_srp_pmt_plans_rec.lock_flag;

   cn_srp_pmt_plans_pvt.create_srp_pmt_plan
     (  p_api_version         => p_api_version,
	p_init_msg_list	      => fnd_api.g_false,
	p_commit	      => fnd_api.g_false,
	p_validation_level    => p_validation_level,
	x_return_status	      => x_return_status,
	x_loading_status      => x_loading_status,
	x_msg_count	      => x_msg_count,
	x_msg_data	      => x_msg_data,
	p_pmt_plan_assign_rec => l_create_rec);

   IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   x_srp_pmt_plan_id       := l_create_rec.srp_pmt_plan_id;

   --
   -- End of API body.
   --

   --
   -- Post processing hooks
   --
   IF JTF_USR_HKS.Ok_to_Execute('CN_SRP_PMT_PLANS_PUB',
				'CREATE_SRP_PMT_PLAN',
				'A',
				'V')
     THEN
      cn_srp_pmt_plans_pub_vuhk.create_srp_pmt_plan_post
	(p_api_version          => p_api_version,
	 p_init_msg_list	=> fnd_api.g_false,
	 p_commit	        => fnd_api.g_false,
	 p_validation_level	=> p_validation_level,
	 x_return_status        => x_return_status,
	 x_msg_count            => x_msg_count,
	 x_msg_data             => x_msg_data,
	 p_srp_pmt_plans_rec    => l_spp_rec,
	 x_srp_pmt_plan_id      => x_srp_pmt_plan_id,
	 x_loading_status       => x_loading_status
	 );

      IF ( x_return_status = FND_API.G_RET_STS_ERROR )
	THEN
	 RAISE FND_API.G_EXC_ERROR;
       ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
	 THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   IF JTF_USR_HKS.Ok_to_Execute('CN_SRP_PMT_PLANS_PUB',
				'CREATE_SRP_PMT_PLAN',
				'A',
				'C')
     THEN
      cn_srp_pmt_plans_pub_cuhk.create_srp_pmt_plan_post
	(p_api_version          => p_api_version,
	 p_init_msg_list	=> fnd_api.g_false,
	 p_commit	        => fnd_api.g_false,
	 p_validation_level	=> p_validation_level,
	 x_return_status        => x_return_status,
	 x_msg_count            => x_msg_count,
	 x_msg_data             => x_msg_data,
	 p_srp_pmt_plans_rec    => l_spp_rec,
	 x_srp_pmt_plan_id      => x_srp_pmt_plan_id,
	 x_loading_status       => x_loading_status
	 );

      IF ( x_return_status = FND_API.G_RET_STS_ERROR )
	THEN
	 RAISE FND_API.G_EXC_ERROR;
       ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
	 THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   --
   -- Message enable hook
   --
   IF JTF_USR_HKS.Ok_to_execute('CN_SRP_PMT_PLANS_PUB',
				'CREATE_SRP_PMT_PLAN',
				'M',
				'M')
     THEN
      IF  cn_srp_pmt_plans_pub_cuhk.ok_to_generate_msg
	 (p_srp_pmt_plans_rec        => l_spp_rec)
	THEN
	 -- Clear bind variables
--	 XMLGEN.clearBindValues;

	 -- Set values for bind variables,
	 -- call this for all bind variables in the business object
--	 XMLGEN.setBindValue('SRP_PMT_PLAN_ID', x_srp_pmt_plan_id);

	 -- Get a ID for workflow/ business object instance
	 l_bind_data_id := JTF_USR_HKS.get_bind_data_id;

	 --  Do this for all the bind variables in the Business Object
	 JTF_USR_HKS.load_bind_data
	   (  l_bind_data_id, 'SRP_PMT_PLAN_ID', x_srp_pmt_plan_id, 'S', 'S');

	 -- Message generation API
	 JTF_USR_HKS.generate_message
	   (p_prod_code    => 'CN',
	    p_bus_obj_code => 'SRP_PMTPLN',
	    p_bus_obj_name => 'SRP_PMT_PLAN',
	    p_action_code  => 'I',
	    p_bind_data_id => l_bind_data_id,
	    p_oai_param    => null,
	    p_oai_array    => l_oai_array,
	    x_return_code  => x_return_status) ;

	 IF (x_return_status = FND_API.G_RET_STS_ERROR)
	   THEN
	    RAISE FND_API.G_EXC_ERROR;
	  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
	    THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;
      END IF;
   END IF;

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
      ROLLBACK TO Create_Srp_Pmt_Plan  ;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Srp_Pmt_Plan;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Srp_Pmt_Plan;
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

END Create_Srp_Pmt_Plan;


--| ----------------------------------------------------------------------+
--| Procedure : Update_Srp_Pmt_Plan
--| Desc : Procedure to update payment plan assignment of an salesrep
--| ----------------------------------------------------------------------+

PROCEDURE Update_Srp_Pmt_Plan
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list	IN    VARCHAR2,
   p_commit	        IN    VARCHAR2,
   p_validation_level   IN    NUMBER,
   x_return_status	OUT NOCOPY  VARCHAR2,
   x_msg_count	        OUT NOCOPY  NUMBER,
   x_msg_data	        OUT NOCOPY  VARCHAR2,
   p_old_srp_pmt_plans_rec IN    srp_pmt_plans_rec_type,
   p_srp_pmt_plans_rec     IN    srp_pmt_plans_rec_type,
   x_loading_status     OUT NOCOPY  VARCHAR2,
   p_check_lock         IN    VARCHAR2 := NULL
   ) IS

      l_api_name     CONSTANT VARCHAR2(30) := 'Update_Srp_Pmt_Plan';
      l_api_version  CONSTANT NUMBER  := 1.0;
      l_spp_rec     srp_pmt_plans_rec_type;
      l_old_spp_rec srp_pmt_plans_rec_type;
      l_spp_row     cn_srp_pmt_plans%ROWTYPE;
      l_old_spp_row cn_srp_pmt_plans%ROWTYPE;
      l_org_id      NUMBER;
      l_status      VARCHAR2(1);

      l_start_date       cn_srp_pmt_plans.start_date%TYPE;
      l_end_date         cn_srp_pmt_plans.end_date%TYPE;
      l_srp_start_date cn_salesreps.start_date_active%TYPE;
      l_srp_end_date   cn_salesreps.end_date_active%TYPE;
      l_pp_start_date  cn_pmt_plans.start_date%TYPE;
      l_pp_end_date    cn_pmt_plans.end_date%TYPE;
      l_action         VARCHAR2(30) := 'UPDATE';
      l_srp_pmt_plan_id cn_srp_pmt_plans.srp_pmt_plan_id%TYPE;
      l_update_rec      cn_srp_pmt_plans_pvt.pmt_plan_assign_rec;

      -- Declaration for user hooks
      l_OAI_array      JTF_USR_HKS.oai_data_array_type;
      l_bind_data_id   NUMBER ;
      l_check_lock     VARCHAR2(1);


BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT	Update_Srp_Pmt_Plan;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     ( l_api_version ,p_api_version ,l_api_name ,G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_UPDATED';

   -- Assign the parameter to a local variable
   l_old_spp_rec := p_old_srp_pmt_plans_rec;
   l_spp_rec     := p_srp_pmt_plans_rec;

   --
   -- API body
   --

   if nvl(l_old_spp_rec.org_id, -99) <>
      Nvl(l_spp_rec.org_id, -99) then
      FND_MESSAGE.SET_NAME ('FND' , 'FND_MO_OU_CANNOT_UPDATE');
      if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
			 'cn.plsql.cn_srp_pmt_plans_pub.update_srp_pmt_plan.error',
			 true);
      end if;

      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	 FND_MESSAGE.SET_NAME ('FND' , 'FND_MO_OU_CANNOT_UPDATE');
	 FND_MSG_PUB.Add;
      END IF;

      RAISE FND_API.G_EXC_ERROR ;
   end if;

   l_org_id := l_old_spp_rec.org_id;
   mo_global.validate_orgid_pub_api
     (org_id => l_org_id,
      status => l_status);

   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
		     'cn.plsql.cn_srp_pmt_plans_pub.update_srp_pmt_plan.org_validate',
                     'Validated org_id = ' || l_org_id || ' status = ' || l_status);
   end if;
   l_old_spp_rec.org_id := l_org_id;
   l_spp_rec.org_id     := l_org_id;

   l_check_lock := NVL(p_check_lock, 'N');

   -- Trim spaces before/after user input string (Old record)
   SELECT Ltrim(Rtrim(p_old_srp_pmt_plans_rec.pmt_plan_name)),
     Ltrim(Rtrim(p_old_srp_pmt_plans_rec.salesrep_type)),
     Ltrim(Rtrim(p_old_srp_pmt_plans_rec.emp_num)),
     trunc(p_old_srp_pmt_plans_rec.start_date),
     trunc(p_old_srp_pmt_plans_rec.end_date)
     INTO
     l_old_spp_rec.pmt_plan_name,
     l_old_spp_rec.salesrep_type,
     l_old_spp_rec.emp_num,
     l_old_spp_rec.start_date,
     l_old_spp_rec.end_date
     FROM dual;
   -- Get IDs
   chk_existence_get_id
     ( x_return_status  => x_return_status,
       x_msg_count      => x_msg_count,
       x_msg_data       => x_msg_data,
       p_srp_pmt_plans_rec => l_old_spp_rec,
       x_srp_pmt_plans_row => l_old_spp_row,
       x_srp_start_date => l_srp_start_date,
       x_srp_end_date   => l_srp_end_date,
       x_pp_start_date  => l_pp_start_date,
       x_pp_end_date    => l_pp_end_date,
       p_action         => 'GETOLDREC',
       p_loading_status => x_loading_status,
       x_loading_status => x_loading_status
       );
   IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
       RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_old_spp_row.srp_pmt_plan_id IS NULL THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	 FND_MESSAGE.Set_Name('CN', 'CN_SRP_PMT_PLAN_NOT_EXIST');
	 FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_SRP_PMT_PLAN_NOT_EXIST';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- Trim spaces before/after user input string (New record) if missing,
   -- assign the old value into it

   IF ((NVL(l_old_spp_row.lock_flag, 'N') <> 'Y') OR (l_check_lock <> 'Y')) THEN
      SELECT
	Decode(p_srp_pmt_plans_rec.pmt_plan_name,
	       FND_API.G_MISS_CHAR, l_old_spp_rec.pmt_plan_name,
	       Ltrim(Rtrim(p_srp_pmt_plans_rec.pmt_plan_name))),
	Decode(p_srp_pmt_plans_rec.salesrep_type,
	       FND_API.G_MISS_CHAR,  l_old_spp_rec.salesrep_type,
	       Ltrim(Rtrim(p_srp_pmt_plans_rec.salesrep_type))),
	Decode(p_srp_pmt_plans_rec.emp_num,
	       FND_API.G_MISS_CHAR,  l_old_spp_rec.emp_num,
	       Ltrim(Rtrim(p_srp_pmt_plans_rec.emp_num))),
	Decode(p_srp_pmt_plans_rec.start_date,
	       FND_API.G_MISS_DATE, l_old_spp_row.start_date,
	       trunc(p_srp_pmt_plans_rec.start_date)),
	Decode(p_srp_pmt_plans_rec.end_date,
	       FND_API.G_MISS_DATE, l_old_spp_row.end_date,
	       trunc(p_srp_pmt_plans_rec.end_date))
	INTO
	l_spp_rec.pmt_plan_name,
	l_spp_rec.salesrep_type,
	l_spp_rec.emp_num,
	l_spp_rec.start_date,
	l_spp_rec.end_date
	FROM dual;

      --
      -- Valid payment plan assignment
      --
      valid_pp_assign
	( x_return_status  => x_return_status,
	  x_msg_count      => x_msg_count,
	  x_msg_data       => x_msg_data,
	  p_srp_pmt_plans_rec => l_spp_rec,
	  x_srp_pmt_plans_row => l_spp_row,
	  p_action         => l_action,
	  p_loading_status => x_loading_status,
	  x_loading_status => x_loading_status
	  );
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS  ) THEN
	 RAISE FND_API.G_EXC_ERROR ;
      END IF;

   --
   -- User hooks
   --
   IF JTF_USR_HKS.Ok_to_Execute('CN_SRP_PMT_PLANS_PUB',
				'UPDATE_SRP_PMT_PLAN',
				'B',
				'C')
     THEN
      cn_srp_pmt_plans_pub_cuhk.update_srp_pmt_plan_pre
	(p_api_version          => p_api_version,
	 p_init_msg_list	=> fnd_api.g_false,
	 p_commit	        => fnd_api.g_false,
	 p_validation_level	=> p_validation_level,
	 x_return_status        => x_return_status,
	 x_msg_count            => x_msg_count,
	 x_msg_data             => x_msg_data,
	 p_old_srp_pmt_plans_rec=> l_old_spp_rec,
	 p_srp_pmt_plans_rec    => l_spp_rec,
	 x_loading_status       => x_loading_status
	 );

      IF ( x_return_status = FND_API.G_RET_STS_ERROR )
	THEN
	 RAISE FND_API.G_EXC_ERROR;
       ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
	 THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   IF JTF_USR_HKS.Ok_to_Execute('CN_SRP_PMT_PLANS_PUB',
				'UPDATE_SRP_PMT_PLAN',
				'B',
				'V')
     THEN
      cn_srp_pmt_plans_pub_vuhk.update_srp_pmt_plan_pre
	(p_api_version          => p_api_version,
	 p_init_msg_list	=> fnd_api.g_false,
	 p_commit	        => fnd_api.g_false,
	 p_validation_level	=> p_validation_level,
	 x_return_status        => x_return_status,
	 x_msg_count            => x_msg_count,
	 x_msg_data             => x_msg_data,
	 p_old_srp_pmt_plans_rec=> l_old_spp_rec,
	 p_srp_pmt_plans_rec    => l_spp_rec,
	 x_loading_status       => x_loading_status
	 );

      IF ( x_return_status = FND_API.G_RET_STS_ERROR )
	THEN
	 RAISE FND_API.G_EXC_ERROR;
       ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
	 THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

      -- Call private API
      l_update_rec.srp_pmt_plan_id := l_old_spp_row.srp_pmt_plan_id;
      l_update_rec.pmt_plan_id    := l_spp_row.pmt_plan_id;
      l_update_rec.salesrep_id    := l_spp_row.salesrep_id;
      l_update_rec.org_id         := l_spp_row.org_id;
      l_update_rec.start_date     := l_spp_row.start_date;
      l_update_rec.end_date       := l_spp_row.end_date;
      l_update_rec.minimum_amount := l_spp_row.minimum_amount;
      l_update_rec.maximum_amount := l_spp_row.maximum_amount;
      l_update_rec.object_version_number := p_old_srp_pmt_plans_rec.object_version_number;
      l_update_rec.srp_role_id      := p_srp_pmt_plans_rec.srp_role_id;
      l_update_rec.role_pmt_plan_id := p_srp_pmt_plans_rec.role_pmt_plan_id;
      l_update_rec.lock_flag        := p_srp_pmt_plans_rec.lock_flag;

      cn_srp_pmt_plans_pvt.update_srp_pmt_plan
	(  p_api_version              => p_api_version,
	   p_init_msg_list	      => fnd_api.g_false,
	   p_commit	              => fnd_api.g_false,
	   p_validation_level         => p_validation_level,
	   x_return_status	      => x_return_status,
	   x_loading_status           => x_loading_status,
	   x_msg_count		      => x_msg_count,
	   x_msg_data		      => x_msg_data,
	   p_pmt_plan_assign_rec      => l_update_rec);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
	 RAISE fnd_api.g_exc_error;
      END IF;

   END IF;
   --
   -- End of API body.
   --

   --
   -- Post processing hooks
   --
   IF JTF_USR_HKS.Ok_to_Execute('CN_SRP_PMT_PLANS_PUB',
				'UPDATE_SRP_PMT_PLAN',
				'A',
				'V')
     THEN
      cn_srp_pmt_plans_pub_vuhk.update_srp_pmt_plan_post
	(p_api_version          => p_api_version,
	 p_init_msg_list        => fnd_api.g_false,
	 p_commit	        => fnd_api.g_false,
	 p_validation_level	=> p_validation_level,
	 x_return_status        => x_return_status,
	 x_msg_count            => x_msg_count,
	 x_msg_data             => x_msg_data,
	 p_old_srp_pmt_plans_rec=> l_old_spp_rec,
	 p_srp_pmt_plans_rec    => l_spp_rec,
	 x_loading_status       => x_loading_status
	 );

      IF ( x_return_status = FND_API.G_RET_STS_ERROR )
	THEN
	 RAISE FND_API.G_EXC_ERROR;
       ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
	 THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

    IF JTF_USR_HKS.Ok_to_Execute('CN_SRP_PMT_PLANS_PUB',
				'UPDATE_SRP_PMT_PLAN',
				'A',
				'C')
     THEN
      cn_srp_pmt_plans_pub_cuhk.update_srp_pmt_plan_post
	(p_api_version          => p_api_version,
	 p_init_msg_list        => fnd_api.g_false,
	 p_commit	        => fnd_api.g_false,
	 p_validation_level	=> p_validation_level,
	 x_return_status        => x_return_status,
	 x_msg_count            => x_msg_count,
	 x_msg_data             => x_msg_data,
	 p_old_srp_pmt_plans_rec=> l_old_spp_rec,
	 p_srp_pmt_plans_rec    => l_spp_rec,
	 x_loading_status       => x_loading_status
	 );

      IF ( x_return_status = FND_API.G_RET_STS_ERROR )
	THEN
	 RAISE FND_API.G_EXC_ERROR;
       ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
	 THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

   --
   -- Message enable hook
   --
   IF JTF_USR_HKS.Ok_to_execute('CN_SRP_PMT_PLANS_PUB',
				'CREATE_SRP_PMT_PLAN',
				'M',
				'M')
     THEN
      IF  cn_srp_pmt_plans_pub_cuhk.ok_to_generate_msg
	 (p_srp_pmt_plans_rec        => l_spp_rec)
	THEN
	 -- Clear bind variables
--	 XMLGEN.clearBindValues;

	 -- Set values for bind variables,
	 -- call this for all bind variables in the business object
--	 XMLGEN.setBindValue('SRP_PMT_PLAN_ID', l_spp_row.srp_pmt_plan_id);

	 -- Get a ID for workflow/ business object instance
	 l_bind_data_id := JTF_USR_HKS.get_bind_data_id;

	 --  Do this for all the bind variables in the Business Object
	 JTF_USR_HKS.load_bind_data
	   (  l_bind_data_id, 'SRP_PMT_PLAN_ID',
	      l_spp_row.srp_pmt_plan_id, 'S', 'S');

	 -- Message generation API
	 JTF_USR_HKS.generate_message
	   (p_prod_code    => 'CN',
	    p_bus_obj_code => 'SRP_PMTPLN',
	    p_bus_obj_name => 'SRP_PMT_PLAN',
	    p_action_code  => 'I',
	    p_bind_data_id => l_bind_data_id,
	    p_oai_param    => null,
	    p_oai_array    => l_oai_array,
	    x_return_code  => x_return_status) ;

	 IF (x_return_status = FND_API.G_RET_STS_ERROR)
	   THEN
	    RAISE FND_API.G_EXC_ERROR;
	  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
	    THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;
      END IF;
   END IF;

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
      ROLLBACK TO Update_Srp_Pmt_Plan  ;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Srp_Pmt_Plan;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Srp_Pmt_Plan;
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

END Update_Srp_Pmt_Plan;

--| ----------------------------------------------------------------------+-+
--| Procedure : Delete_Srp_Pmt_Plan
--| Desc : Procedure to delete a payment plan assignment to salesrep
--| ----------------------------------------------------------------------+

PROCEDURE Delete_Srp_Pmt_Plan
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list	IN    VARCHAR2,
   p_commit	        IN    VARCHAR2,
   p_validation_level   IN    NUMBER,
   x_return_status	OUT NOCOPY  VARCHAR2,
   x_msg_count	        OUT NOCOPY  NUMBER,
   x_msg_data	        OUT NOCOPY  VARCHAR2,
   p_srp_pmt_plans_rec  IN    srp_pmt_plans_rec_type,
   x_loading_status     OUT NOCOPY  VARCHAR2,
   p_check_lock         IN  VARCHAR2 := NULL
   ) IS

      l_api_name     CONSTANT VARCHAR2(30) := 'Delete_Srp_Pmt_Plan';
      l_api_version  CONSTANT NUMBER  := 1.0;
      l_spp_rec     srp_pmt_plans_rec_type := G_MISS_SRP_PMT_PLANS_REC;
      l_spp_row     cn_srp_pmt_plans%ROWTYPE;

      l_srp_start_date cn_salesreps.start_date_active%TYPE;
      l_srp_end_date   cn_salesreps.end_date_active%TYPE;
      l_pp_start_date  cn_pmt_plans.start_date%TYPE;
      l_pp_end_date    cn_pmt_plans.end_date%TYPE;

      l_org_id         NUMBER;
      l_status         VARCHAR2(1);

      -- Declaration for user hooks
      l_OAI_array      JTF_USR_HKS.oai_data_array_type;
      l_bind_data_id   NUMBER ;
      l_check_lock     VARCHAR2(1);

BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT	Delete_Srp_Pmt_Plan;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     ( l_api_version ,p_api_version ,l_api_name ,G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_DELETED';
   -- Assign the parameter to a local variable
   l_spp_rec := p_srp_pmt_plans_rec;

   --
   -- API body
   --

   --
   --Validate org id
   --
   l_org_id := l_spp_rec.org_id;
   mo_global.validate_orgid_pub_api
     (org_id => l_org_id,
      status => l_status);

   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
		     'cn.plsql.cn_srp_pmt_plans_pub.delete_srp_pmt_plan.org_validate',
                     'Validated org_id = ' || l_org_id || ' status = ' || l_status);
   end if;
   l_spp_rec.org_id := l_org_id;

   l_check_lock := NVL(p_check_lock, 'N');

   -- Trim spaces before/after user input string (Old record)
   SELECT Ltrim(Rtrim(p_srp_pmt_plans_rec.pmt_plan_name)),
     Ltrim(Rtrim(p_srp_pmt_plans_rec.salesrep_type)),
     Ltrim(Rtrim(p_srp_pmt_plans_rec.emp_num)),
     trunc(p_srp_pmt_plans_rec.start_date),
     trunc(p_srp_pmt_plans_rec.end_date)
     INTO
     l_spp_rec.pmt_plan_name,
     l_spp_rec.salesrep_type,
     l_spp_rec.emp_num,
     l_spp_rec.start_date,
     l_spp_rec.end_date
     FROM dual;
   -- Get IDs
   chk_existence_get_id
     ( x_return_status  => x_return_status,
       x_msg_count      => x_msg_count,
       x_msg_data       => x_msg_data,
       p_srp_pmt_plans_rec => l_spp_rec,
       x_srp_pmt_plans_row => l_spp_row,
       x_srp_start_date => l_srp_start_date,
       x_srp_end_date   => l_srp_end_date,
       x_pp_start_date  => l_pp_start_date,
       x_pp_end_date    => l_pp_end_date,
       p_action         => 'GETOLDREC',
       p_loading_status => x_loading_status,
       x_loading_status => x_loading_status
       );
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS  ) THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_spp_row.srp_pmt_plan_id IS NULL THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	 FND_MESSAGE.Set_Name('CN', 'CN_SRP_PMT_PLAN_NOT_EXIST');
	 FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_SRP_PMT_PLAN_NOT_EXIST';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   --
   -- User hooks
   --
   IF JTF_USR_HKS.Ok_to_Execute('CN_SRP_PMT_PLANS_PUB',
				'DELETE_SRP_PMT_PLAN',
				'B',
				'C')
     THEN
      cn_srp_pmt_plans_pub_cuhk.delete_srp_pmt_plan_pre
	(p_api_version          => p_api_version,
	 p_init_msg_list        => fnd_api.g_false,
	 p_commit	        => fnd_api.g_false,
	 p_validation_level	=> p_validation_level,
	 x_return_status        => x_return_status,
	 x_msg_count            => x_msg_count,
	 x_msg_data             => x_msg_data,
	 p_srp_pmt_plans_rec    => l_spp_rec,
	 x_loading_status       => x_loading_status
	 );
      IF ( x_return_status = FND_API.G_RET_STS_ERROR )
	THEN
	 RAISE FND_API.G_EXC_ERROR;
       ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
	 THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   IF JTF_USR_HKS.Ok_to_Execute('CN_SRP_PMT_PLANS_PUB',
				'DELETE_SRP_PMT_PLAN',
				'B',
				'V')
     THEN
      cn_srp_pmt_plans_pub_vuhk.delete_srp_pmt_plan_pre
	(p_api_version          => p_api_version,
	 p_init_msg_list        => fnd_api.g_false,
	 p_commit	        => fnd_api.g_false,
	 p_validation_level	=> p_validation_level,
	 x_return_status        => x_return_status,
	 x_msg_count            => x_msg_count,
	 x_msg_data             => x_msg_data,
	 p_srp_pmt_plans_rec    => l_spp_rec,
	 x_loading_status       => x_loading_status
	 );
      IF ( x_return_status = FND_API.G_RET_STS_ERROR )
	THEN
	 RAISE FND_API.G_EXC_ERROR;
       ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
	 THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   -- API body

   cn_srp_pmt_plans_pvt.delete_srp_pmt_plan
     (
      p_api_version        => p_api_version,
      p_init_msg_list      => fnd_api.g_false,
      p_commit	           => fnd_api.g_false,
      p_validation_level   => p_validation_level,
      x_return_status      => x_return_status,
      x_loading_status     => x_loading_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_srp_pmt_plan_id    => l_spp_row.srp_pmt_plan_id);

   IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   --
   -- End of API body.
   --

   --
   -- Post processing hooks
   --
   IF JTF_USR_HKS.Ok_to_Execute('CN_SRP_PMT_PLANS_PUB',
				'DELETE_SRP_PMT_PLAN',
				'A',
				'V')
     THEN
      cn_srp_pmt_plans_pub_vuhk.delete_srp_pmt_plan_post
	(p_api_version          => p_api_version,
	 p_init_msg_list        => fnd_api.g_false,
	 p_commit	        => fnd_api.g_false,
	 p_validation_level	=> p_validation_level,
	 x_return_status        => x_return_status,
	 x_msg_count            => x_msg_count,
	 x_msg_data             => x_msg_data,
	 p_srp_pmt_plans_rec    => l_spp_rec,
	 x_loading_status       => x_loading_status
	 );

      IF ( x_return_status = FND_API.G_RET_STS_ERROR )
	THEN
	 RAISE FND_API.G_EXC_ERROR;
       ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
	 THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   IF JTF_USR_HKS.Ok_to_Execute('CN_SRP_PMT_PLANS_PUB',
				'DELETE_SRP_PMT_PLAN',
				'A',
				'C')
     THEN
      cn_srp_pmt_plans_pub_cuhk.delete_srp_pmt_plan_post
	(p_api_version          => p_api_version,
	 p_init_msg_list        => fnd_api.g_false,
	 p_commit	        => fnd_api.g_false,
	 p_validation_level	=> p_validation_level,
	 x_return_status        => x_return_status,
	 x_msg_count            => x_msg_count,
	 x_msg_data             => x_msg_data,
	 p_srp_pmt_plans_rec    => l_spp_rec,
	 x_loading_status       => x_loading_status
	 );

      IF ( x_return_status = FND_API.G_RET_STS_ERROR )
	THEN
	 RAISE FND_API.G_EXC_ERROR;
       ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
	 THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;
   --
   -- Message enable hook
   --
   IF JTF_USR_HKS.Ok_to_execute('CN_SRP_PMT_PLANS_PUB',
				'DELETE_SRP_PMT_PLAN',
				'M',
				'M')
     THEN
      IF  cn_srp_pmt_plans_pub_cuhk.ok_to_generate_msg
	 (p_srp_pmt_plans_rec        => l_spp_rec)
	THEN
	 -- Clear bind variables
--	 XMLGEN.clearBindValues;

	 -- Set values for bind variables,
	 -- call this for all bind variables in the business object
--	 XMLGEN.setBindValue('SRP_PMT_PLAN_ID', l_spp_row.srp_pmt_plan_id);

	 -- Get a ID for workflow/ business object instance
	 l_bind_data_id := JTF_USR_HKS.get_bind_data_id;

	 --  Do this for all the bind variables in the Business Object
	 JTF_USR_HKS.load_bind_data
	   (  l_bind_data_id, 'SRP_PMT_PLAN_ID',
	      l_spp_row.srp_pmt_plan_id, 'S', 'S');

	 -- Message generation API
	 JTF_USR_HKS.generate_message
	   (p_prod_code    => 'CN',
	    p_bus_obj_code => 'SRP_PMTPLN',
	    p_bus_obj_name => 'SRP_PMT_PLAN',
	    p_action_code  => 'I',
	    p_bind_data_id => l_bind_data_id,
	    p_oai_param    => null,
	    p_oai_array    => l_oai_array,
	    x_return_code  => x_return_status) ;

	 IF (x_return_status = FND_API.G_RET_STS_ERROR)
	   THEN
	    RAISE FND_API.G_EXC_ERROR;
	  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
	    THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;
      END IF;
   END IF;

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
      ROLLBACK TO Delete_Srp_Pmt_Plan  ;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_Srp_Pmt_Plan;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_Srp_Pmt_Plan;
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

END Delete_Srp_Pmt_Plan;


-- --------------------------------------------------------------------------*
-- Procedure: Create_Mass_Asgn_Srp_Pmt_plan
-- --------------------------------------------------------------------------*

PROCEDURE Create_Mass_Asgn_Srp_Pmt_Plan
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count	        OUT NOCOPY  NUMBER,
   x_msg_data	        OUT NOCOPY  VARCHAR2,
   p_srp_role_id        IN    NUMBER,
   p_role_pmt_plan_id   IN    NUMBER,
   x_srp_pmt_plan_id    OUT NOCOPY  NUMBER,
   x_loading_status     OUT NOCOPY  VARCHAR2
   ) IS
BEGIN
   cn_srp_pmt_plans_pvt.create_mass_asgn_srp_pmt_plan
     (p_api_version      => p_api_version,
      p_init_msg_list    => p_init_msg_list,
      p_commit           => p_commit,
      p_validation_level => p_validation_level,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_srp_role_id      => p_srp_role_id,
      p_role_pmt_plan_id => p_role_pmt_plan_id,
      x_srp_pmt_plan_id  => x_srp_pmt_plan_id,
      x_loading_status   => x_loading_status);
END Create_Mass_Asgn_Srp_Pmt_Plan;

-- --------------------------------------------------------------------------*
-- Procedure: Update_Mass_Asgn_Srp_Pmt_plan
-- --------------------------------------------------------------------------*

PROCEDURE Update_Mass_Asgn_Srp_Pmt_plan
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count	        OUT NOCOPY  NUMBER,
   x_msg_data	        OUT NOCOPY  VARCHAR2,
   p_srp_role_id        IN    NUMBER,
   p_role_pmt_plan_id   IN    NUMBER,
   x_loading_status     OUT NOCOPY  VARCHAR2
   ) IS
BEGIN
   cn_srp_pmt_plans_pvt.update_mass_asgn_srp_pmt_plan
     (p_api_version      => p_api_version,
      p_init_msg_list    => p_init_msg_list,
      p_commit           => p_commit,
      p_validation_level => p_validation_level,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_srp_role_id      => p_srp_role_id,
      p_role_pmt_plan_id => p_role_pmt_plan_id,
      x_loading_status   => x_loading_status);
END update_mass_asgn_srp_pmt_plan;


-- --------------------------------------------------------------------------*
-- Procedure: Delete_Mass_Asgn_Srp_Pmt_plan
-- --------------------------------------------------------------------------*

PROCEDURE Delete_Mass_Asgn_Srp_Pmt_Plan
  (p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count	        OUT NOCOPY  NUMBER,
   x_msg_data	        OUT NOCOPY  VARCHAR2,
   p_srp_role_id        IN    NUMBER,
   p_role_pmt_plan_id   IN    NUMBER,
   x_loading_status     OUT NOCOPY  VARCHAR2
   ) IS
BEGIN
   cn_srp_pmt_plans_pvt.delete_mass_asgn_srp_pmt_plan
     (p_api_version      => p_api_version,
      p_init_msg_list    => p_init_msg_list,
      p_commit           => p_commit,
      p_validation_level => p_validation_level,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_srp_role_id      => p_srp_role_id,
      p_role_pmt_plan_id => p_role_pmt_plan_id,
      x_loading_status   => x_loading_status);

END Delete_Mass_Asgn_Srp_Pmt_Plan;

END  CN_SRP_PMT_PLANS_PUB;

/
