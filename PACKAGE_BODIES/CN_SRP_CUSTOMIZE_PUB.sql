--------------------------------------------------------
--  DDL for Package Body CN_SRP_CUSTOMIZE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SRP_CUSTOMIZE_PUB" as
-- $Header: cnpsrpcb.pls 120.1 2005/10/27 16:04:41 mblum noship $ -+

G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_SRP_CUSTOMIZE_PUB';

PROCEDURE Update_srp_quota_assign(
        p_api_version           	IN	NUMBER,
  	p_init_msg_list		        IN	VARCHAR2,
	p_commit	    		IN  	VARCHAR2,
	p_validation_level		IN  	NUMBER,
        p_srp_quota_assign_id           IN      NUMBER,
        p_customized_flag               IN      VARCHAR2,
        p_quota                         IN      NUMBER,
        p_fixed_amount                  IN      NUMBER,
        p_goal                          IN      NUMBER,
	x_return_status		        OUT NOCOPY VARCHAR2,
	x_msg_count		        OUT NOCOPY NUMBER,
	x_msg_data		        OUT NOCOPY VARCHAR2,
        x_loading_status	        OUT NOCOPY     VARCHAR2,
	x_status                        OUT NOCOPY     VARCHAR2
        ) IS

   l_api_name		CONSTANT VARCHAR2(30) := 'Update_srp_quota_assign';
   l_api_version        CONSTANT NUMBER       := 1.0;

   l_customized_flag_old               CN_SRP_QUOTA_ASSIGNS.customized_flag%TYPE;
   l_target_old                        CN_SRP_QUOTA_ASSIGNS.target%TYPE;
   l_ptdr_code_old                     CN_SRP_QUOTA_ASSIGNS.period_target_dist_rule_code%TYPE;
   l_ptu_code_old                      CN_SRP_QUOTA_ASSIGNS.period_target_unit_code%TYPE;
   l_payment_amount_old                CN_SRP_QUOTA_ASSIGNS.payment_amount%TYPE;
   l_performance_goal_old              CN_SRP_QUOTA_ASSIGNS.performance_goal%TYPE;
   l_quota_id  NUMBER;
   l_org_id    NUMBER;
   l_status    VARCHAR2(1);

BEGIN

   --
   -- Standard Start of API savepoint
   --
   SAVEPOINT    update_srp_quota_assign;

   --
   -- Standard call to check for call compatibility.
   --
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
					p_api_version ,
					l_api_name    ,
					G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --
   --  Initialize API return status to success
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_UPDATED';

   select customized_flag
          ,target
          ,period_target_dist_rule_code
          ,period_target_unit_code
          ,payment_amount
          ,performance_goal
          ,quota_id
          ,org_id
         into
          l_customized_flag_old
         ,l_target_old
         ,l_ptdr_code_old
         ,l_ptu_code_old
         ,l_payment_amount_old
         ,l_performance_goal_old
         ,l_quota_id
         ,l_org_id
   from cn_srp_quota_assigns_all
  where srp_quota_assign_id = p_srp_quota_assign_id;

   -- validate org ID
   mo_global.validate_orgid_pub_api
     (org_id => l_org_id,
      status => l_status);

   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
		     'cn.plsql.cn_srp_customize_pub.update_srp_quota_assign.org_validate',
                     'Validated org_id = ' || l_org_id || ' status = ' || l_status);
   end if;


   cn_srp_quota_assigns_pkg.update_record(
                  p_srp_quota_assign_id
 	         ,p_quota
 		 ,l_target_old
 		 ,null       --x_start_period_id
 		 ,null       --x_salesrep_id NUMBER
 		 ,p_customized_flag
 		 ,l_customized_flag_old
 		 ,l_quota_id
 		 ,null       --x_rate_schedule_id
 		 ,l_ptdr_code_old
 		 ,null       --x_attributes_changed		 VARCHAR2
 		 ,null       --x_distribute_target_flag
 		 ,p_fixed_amount  --x_payment_amount		 NUMBER
 		 ,l_payment_amount_old
                 ,p_goal
 		 ,l_performance_goal_old
 	         ,l_ptu_code_old
 	         ,l_ptu_code_old
 		 ,Sysdate            --g_last_update_date
 		 ,fnd_global.user_id --g_last_updated_by
 		 ,fnd_global.login_id); -- g_last_update_login);

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
   END IF;
     --
     -- Standard call to get message count and if count is 1, get message info.
     --

     FND_MSG_PUB.Count_And_Get
       (
	p_count   =>  x_msg_count ,
	p_data    =>  x_msg_data  ,
	p_encoded => FND_API.G_FALSE
	);

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO update_srp_quota_assign;
    x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_srp_quota_assign;
    x_loading_status := 'UNEXPECTED_ERR';
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
     ROLLBACK TO update_srp_quota_assign;
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
END Update_srp_quota_assign;

PROCEDURE Change_srp_quota_custom_flag(
        p_api_version           	IN	NUMBER,
  	p_init_msg_list		        IN	VARCHAR2,
	p_commit	    		IN  	VARCHAR2,
	p_validation_level		IN  	NUMBER,
        p_srp_quota_assign_id           IN      NUMBER,
        p_customized_flag               IN      VARCHAR2,
	x_return_status		        OUT NOCOPY VARCHAR2,
	x_msg_count		 OUT NOCOPY NUMBER,
	x_msg_data		 OUT NOCOPY VARCHAR2,
        x_loading_status	 OUT NOCOPY     VARCHAR2
        )  IS

   l_api_name		      CONSTANT VARCHAR2(30) := 'Change_srp_quota_custom_flag';
   l_api_version              CONSTANT NUMBER       := 1.0;
   l_customized_flag_old      CN_SRP_QUOTA_ASSIGNS.customized_flag%TYPE;
   l_target_old               CN_SRP_QUOTA_ASSIGNS.target%TYPE;
   l_ptdr_code_old            CN_SRP_QUOTA_ASSIGNS.period_target_dist_rule_code%TYPE;
   l_ptu_code_old             CN_SRP_QUOTA_ASSIGNS.period_target_unit_code%TYPE;
   l_payment_amount_old       CN_SRP_QUOTA_ASSIGNS.payment_amount%TYPE;
   l_performance_goal_old     CN_SRP_QUOTA_ASSIGNS.performance_goal%TYPE;

   l_quota_id   	      CN_QUOTAS.quota_id%TYPE;
   l_org_id                   NUMBER;
   l_status                   VARCHAR2(1);

BEGIN

   --
   -- Standard Start of API savepoint
   --
   SAVEPOINT    change_srp_quota_custom_flag;

   --
   -- Standard call to check for call compatibility.
   --
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
					p_api_version ,
					l_api_name    ,
					G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --
   --  Initialize API return status to success
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_UPDATED';

   --
   -- modified By Kumar.
   --
  select customized_flag
         ,quota_id
         ,target
         ,period_target_dist_rule_code
         ,period_target_unit_code
         ,payment_amount
         ,performance_goal
         ,org_id
      into l_customized_flag_old
          ,l_quota_id
          ,l_target_old
          ,l_ptdr_code_old
          ,l_ptu_code_old
          ,l_payment_amount_old
          ,l_performance_goal_old
          ,l_org_id
     from cn_srp_quota_assigns_all
    where srp_quota_assign_id = p_srp_quota_assign_id;

   -- validate org ID
   mo_global.validate_orgid_pub_api
     (org_id => l_org_id,
      status => l_status);

   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
		     'cn.plsql.cn_srp_customize_pub.change_srp_quota_custom_flag.org_validate',
		     'Validated org_id = ' || l_org_id || ' status = ' || l_status);
   end if;

   cn_srp_quota_assigns_pkg.update_record(
                 p_srp_quota_assign_id
 	         ,nvl(l_target_old,0)
 		 ,nvl(l_target_old,0)
 		 ,null       --x_start_period_id
 		 ,null       --x_salesrep_id NUMBER
 		 ,p_customized_flag
 		 ,l_customized_flag_old
 		 ,l_quota_id
 		 ,null       --x_rate_schedule_id
 		 ,l_ptdr_code_old
 		 ,null       --x_attributes_changed		 VARCHAR2
 		 ,null       --x_distribute_target_flag
 		 ,l_payment_amount_old
 		 ,l_payment_amount_old
                 ,l_performance_goal_old
 		 ,l_performance_goal_old
 	         ,l_ptu_code_old
 	         ,l_ptu_code_old
 		 ,Sysdate --g_last_update_date
 		 ,fnd_global.user_id --g_last_updated_by
 		 ,fnd_global.login_id); --g_last_update_login);

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;   END IF;
     --
     -- Standard call to get message count and if count is 1, get message info.
     --

     FND_MSG_PUB.Count_And_Get
       (
	p_count   =>  x_msg_count ,
	p_data    =>  x_msg_data  ,
	p_encoded => FND_API.G_FALSE
	);
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO change_srp_quota_custom_flag;
    x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO change_srp_quota_custom_flag;
    x_loading_status := 'UNEXPECTED_ERR';
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
     ROLLBACK TO change_srp_quota_custom_flag;
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

END Change_srp_quota_custom_flag ;



PROCEDURE Update_Srp_Quota_Rules(
        p_api_version           	IN	NUMBER,
  	p_init_msg_list		        IN	VARCHAR2,
	p_commit	    		IN  	VARCHAR2,
	p_validation_level		IN  	NUMBER,
        p_quota_rule_id                 IN      NUMBER,
        p_srp_quota_rule_id             IN      NUMBER,
        p_target                        IN      NUMBER,
        p_payment_amount                IN      NUMBER,
        p_performance_goal              IN      NUMBER,
	x_return_status		        OUT NOCOPY VARCHAR2,
	x_msg_count		 OUT NOCOPY NUMBER,
	x_msg_data		 OUT NOCOPY VARCHAR2,
        x_loading_status	 OUT NOCOPY     VARCHAR2
        ) IS
   l_api_name		CONSTANT VARCHAR2(30) := 'Update_srp_quota_rules';
   l_api_version        CONSTANT NUMBER       := 1.0;

   l_org_id                   NUMBER;
   l_status                   VARCHAR2(1);

BEGIN
   --
   -- Standard Start of API savepoint
   --
   SAVEPOINT    update_srp_quota_rules;

   --
   -- Standard call to check for call compatibility.
   --
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
					p_api_version ,
					l_api_name    ,
					G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --
   --  Initialize API return status to success
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_UPDATED';

   SELECT org_id INTO l_org_id
     FROM cn_srp_quota_rules_all
    WHERE srp_quota_rule_id = p_srp_quota_rule_id;

   -- validate org ID
   mo_global.validate_orgid_pub_api
     (org_id => l_org_id,
      status => l_status);

   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
		     'cn.plsql.cn_srp_customize_pub.update_srp_quota_rules.org_validate',
		     'Validated org_id = ' || l_org_id || ' status = ' || l_status);
   end if;

   cn_srp_quota_rules_pkg.update_record(
              x_quota_rule_id => p_quota_rule_id,
              x_srp_quota_rule_id => p_srp_quota_rule_id,
              x_target => p_target,
              x_payment_amount => p_payment_amount,
              x_performance_goal => p_performance_goal);


   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;   END IF;
     --
     -- Standard call to get message count and if count is 1, get message info.
     --

     FND_MSG_PUB.Count_And_Get
       (
	p_count   =>  x_msg_count ,
	p_data    =>  x_msg_data  ,
	p_encoded => FND_API.G_FALSE
	);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Update_Srp_Quota_Rules;
    x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Update_Srp_Quota_Rules;
    x_loading_status := 'UNEXPECTED_ERR';
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
     ROLLBACK TO Update_Srp_Quota_Rules;
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

END Update_Srp_Quota_Rules;


PROCEDURE Update_Srp_Rule_Uplifts
  (p_api_version           	IN	NUMBER,
   p_init_msg_list		        IN	VARCHAR2,
   p_commit	    		IN  	VARCHAR2,
   p_validation_level		IN  	NUMBER,

   p_srp_rule_uplift_id             IN      NUMBER,
   p_payment_factor                 IN      NUMBER,
   p_quota_factor                   IN      NUMBER,

   x_return_status		        OUT NOCOPY VARCHAR2,
   x_msg_count		 OUT NOCOPY NUMBER,
   x_msg_data		 OUT NOCOPY VARCHAR2,
   x_loading_status	 OUT NOCOPY     VARCHAR2
   ) IS

   l_api_name		CONSTANT VARCHAR2(30) := 'Update_Srp_Rule_Uplifts';
   l_api_version        CONSTANT NUMBER       := 1.0;

   l_org_id                   NUMBER;
   l_status                   VARCHAR2(1);

BEGIN
   --
   -- Standard Start of API savepoint
   --
   SAVEPOINT    update_srp_rule_uplifts;

   --
   -- Standard call to check for call compatibility.
   --
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
					p_api_version ,
					l_api_name    ,
					G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --
   --  Initialize API return status to success
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_UPDATED';

   SELECT org_id INTO l_org_id
     FROM cn_srp_rule_uplifts_all
    WHERE srp_rule_uplift_id = p_srp_rule_uplift_id;

   -- validate org ID
   mo_global.validate_orgid_pub_api
     (org_id => l_org_id,
      status => l_status);

   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
		     'cn.plsql.cn_srp_customize_pub.update_srp_rule_uplifts.org_validate',
		     'Validated org_id = ' || l_org_id || ' status = ' || l_status);
   end if;


   cn_srp_rule_uplifts_pkg.update_record
     (p_srp_rule_uplift_id         => p_srp_rule_uplift_id
      ,p_payment_factor            => p_payment_factor
      ,p_quota_factor              => p_quota_factor
      ,p_last_update_date	   => sysdate
      ,p_last_updated_by	   => fnd_global.user_id
      ,p_last_update_login	   => fnd_global.login_id);


   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;   END IF;

   --
   -- Standard call to get message count and if count is 1, get message info.
   --

   FND_MSG_PUB.Count_And_Get
       (
	p_count   =>  x_msg_count ,
	p_data    =>  x_msg_data  ,
	p_encoded => FND_API.G_FALSE
	);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Update_Srp_Rule_Uplifts;
    x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Update_Srp_Rule_Uplifts;
    x_loading_status := 'UNEXPECTED_ERR';
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
     ROLLBACK TO Update_Srp_Rule_Uplifts;
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

END Update_Srp_Rule_Uplifts;


END CN_Srp_Customize_Pub ;

/
