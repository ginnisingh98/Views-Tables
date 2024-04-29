--------------------------------------------------------
--  DDL for Package Body CN_PMTPLAN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PMTPLAN_PUB" as
-- $Header: cnppplnb.pls 120.4 2005/11/02 05:37:38 sjustina noship $

-- -------------------------------------------------------------------------*
--  Procedure   : Get_PmtPlan_ID
--  Description : This procedure is used to get the ID for the pmt plan
-- -------------------------------------------------------------------------*
PROCEDURE Get_PmtPlan_ID
  (
   x_return_status	    OUT NOCOPY VARCHAR2 ,
   x_msg_count		    OUT NOCOPY NUMBER	 ,
   x_msg_data		    OUT NOCOPY VARCHAR2 ,
   p_PmtPlan_rec            IN  PmtPlan_Rec_Type,
   p_loading_status         IN  VARCHAR2,
   x_pmt_plan_id            OUT NOCOPY NUMBER,
   x_loading_status         OUT NOCOPY VARCHAR2,
   x_status		    OUT NOCOPY VARCHAR2
   ) IS
      L_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_PmtPlan_PUB';
      L_LAST_UPDATE_DATE          DATE    := sysdate;
      L_LAST_UPDATED_BY           NUMBER  := fnd_global.user_id;
      L_CREATION_DATE             DATE    := sysdate;
      L_CREATED_BY                NUMBER  := fnd_global.user_id;
      L_LAST_UPDATE_LOGIN         NUMBER  := fnd_global.login_id;
      L_ROWID                     VARCHAR2(30);
      L_PROGRAM_TYPE              VARCHAR2(30);
      l_api_name  CONSTANT VARCHAR2(30) := 'Get_PmtPlan_ID';

      CURSOR get_PmtPlan_id is
	 SELECT pmt_plan_id
	   FROM cn_pmt_plans
	   WHERE name = p_PmtPlan_rec.name
	   AND start_date = p_PmtPlan_rec.start_date
	   AND end_date = p_PmtPlan_rec.end_date
	   AND org_id = p_PmtPlan_rec.org_id;

      --If end date is null, then use the following cursor
      CURSOR get_PmtPlan_id2 is
	 SELECT pmt_plan_id
	   FROM cn_pmt_plans
	   WHERE name = p_PmtPlan_rec.name
	   AND start_date = p_PmtPlan_rec.start_date
	   AND org_id = p_PmtPlan_rec.org_id;

      l_get_PmtPlan_id_rec get_PmtPlan_id%ROWTYPE;

BEGIN

   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status;
   x_status := p_loading_status ;


   --Open appropriate cursor and fetch the payment plan ID
   IF p_PmtPlan_rec.end_date IS NOT NULL
     THEN
      OPEN get_PmtPlan_id;
      FETCH get_PmtPlan_id INTO l_get_PmtPlan_id_rec;
      IF get_PmtPlan_id%ROWCOUNT = 0
	THEN
         x_status := 'NEW PMT PLAN';
         SELECT cn_pmt_plans_s.nextval
           INTO x_pmt_plan_id
           FROM dual;
       ELSIF get_PmtPlan_id%ROWCOUNT = 1
	 THEN
         x_status := 'PMT PLAN EXISTS';
         x_pmt_plan_id  := l_get_PmtPlan_id_rec.pmt_plan_id;
      END IF;
      CLOSE get_PmtPlan_id;
    ELSE
      OPEN get_PmtPlan_id2;
      FETCH get_PmtPlan_id2 INTO l_get_PmtPlan_id_rec;
      IF get_PmtPlan_id2%ROWCOUNT = 0
	THEN
         x_status := 'NEW PMT PLAN';
         SELECT cn_pmt_plans_s.nextval
           INTO x_pmt_plan_id
           FROM dual;
       ELSIF get_PmtPlan_id2%ROWCOUNT = 1
	 THEN
         x_status := 'PMT PLAN EXISTS';
         x_pmt_plan_id  := l_get_PmtPlan_id_rec.pmt_plan_id;
      END IF;
      CLOSE get_PmtPlan_id2;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg( L_PKG_NAME ,l_api_name );
      END IF;

END Get_PmtPlan_ID;


--------------------------------------------------------------------------*
-- Procedure  : Create_PmtPlan
-- Description: Public API to create a pmt plan
-- Calls      : CN_PMTPLAN_PVT.Create_PmtPlan
--------------------------------------------------------------------------*
PROCEDURE Create_PmtPlan(
				p_api_version           	IN	NUMBER,
				p_init_msg_list		IN	VARCHAR2 ,
				p_commit	    		IN  	VARCHAR2,
				p_validation_level		IN  	NUMBER,
				x_return_status	 OUT NOCOPY VARCHAR2,
				x_msg_count		 OUT NOCOPY NUMBER,
				x_msg_data		 OUT NOCOPY VARCHAR2,
				p_PmtPlan_rec       	IN  OUT NOCOPY   PmtPlan_Rec_Type,
				x_loading_status	 OUT NOCOPY     VARCHAR2,
				x_status                    OUT NOCOPY     VARCHAR2
				) IS

    L_PKG_NAME      CONSTANT VARCHAR2(30) := 'CN_PmtPlan_PUB';
    l_api_name		CONSTANT VARCHAR2(30)  := 'Create_PmtPlan';
    l_api_version   CONSTANT NUMBER        := 1.0;


    l_create_rec   cn_pmtplan_pvt.PmtPlan_rec_type;
    l_payment_grp_code varchar2(40);
    l_status VARCHAR2(1);

BEGIN

   -- Copy the Record values into l_create_rec and call private

   l_create_rec.org_id := p_PmtPlan_rec.org_id;
   mo_global.validate_orgid_pub_api(org_id => l_create_rec.org_id,status =>l_status);
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'cn.plsql.cn_pmtplan_pub.Create_PmtPlan.org_validate',
                      'Validated org_id = ' || l_create_rec.org_id || ' status ='||l_status);
   end if;

   l_create_rec.name := p_PmtPlan_rec.name;
   l_create_rec.minimum_amount := p_PmtPlan_rec.minimum_amount;
   l_create_rec.maximum_amount := p_PmtPlan_rec.maximum_amount;
   l_create_rec.min_rec_flag := p_PmtPlan_rec.min_rec_flag;
   l_create_rec.max_rec_flag := p_PmtPlan_rec.max_rec_flag;
   l_create_rec.max_recovery_amount := p_PmtPlan_rec.max_recovery_amount;
   l_create_rec.credit_type_name := p_PmtPlan_rec.credit_type_name;
   l_create_rec.pay_interval_type_name := p_PmtPlan_rec.pay_interval_type_name;
   l_create_rec.start_date := p_PmtPlan_rec.start_date;
   l_create_rec.end_date := p_PmtPlan_rec.end_date;
   l_create_rec.object_version_number := 1;
   l_create_rec.recoverable_interval_type := p_PmtPlan_rec.recoverable_interval_type;
   l_create_rec.pay_against_commission := p_PmtPlan_rec.pay_against_commission;
   l_create_rec.payment_group_code := p_PmtPlan_rec.payment_group_code;

   if ((p_PmtPlan_rec.pay_against_commission <> 'Y' and
        p_PmtPlan_rec.pay_against_commission <> 'N')
        or p_PmtPlan_rec.pay_against_commission is null)
   then
       l_create_rec.pay_against_commission := 'Y';
   end if;


   CN_PMTPLAN_PVT.Create_PmtPlan
     (p_api_version      => p_api_version,
      p_init_msg_list    => p_init_msg_list,
      p_commit           => p_commit,
      p_validation_level => p_validation_level,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_PmtPlan_rec      => l_create_rec,
      x_loading_status   => x_loading_status,
      x_status           => x_status);

   -- End of Create Pmt Plans.
   -- Standard call to get message count and if count is 1,
   -- get message info.

   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count,
      p_data    =>  x_msg_data,
      p_encoded => FND_API.G_FALSE
     );

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
	 FND_MSG_PUB.Add_Exc_Msg( L_PKG_NAME ,l_api_name );
      END IF;

END Create_PmtPlan;

---------------------------------------------------------------------------*
--  Procedure   : 	Update PmtPlan
--  Description : 	This is a public procedure to update pmt plans
--  Calls       : 	CN_PMTPLAN_PVT.Update_PmtPlan
---------------------------------------------------------------------------*

PROCEDURE  Update_PmtPlan (
			       p_api_version		IN 	NUMBER,
			       p_init_msg_list		IN	VARCHAR2,
			       p_commit	    		IN  	VARCHAR2,
			       p_validation_level		IN  	NUMBER,
			       x_return_status        OUT NOCOPY 	VARCHAR2,
			       x_msg_count	         OUT NOCOPY 	NUMBER,
			       x_msg_data		 OUT NOCOPY 	VARCHAR2,
			       p_old_PmtPlan_rec          IN      PmtPlan_rec_type,
			       p_PmtPlan_rec              IN  OUT NOCOPY    PmtPlan_rec_type,
			       x_status             OUT NOCOPY 	VARCHAR2,
			       x_loading_status     OUT NOCOPY 	VARCHAR2
			       )  IS

				  l_api_name		CONSTANT VARCHAR2(30)  := 'Update_PmtPlan';
				  l_api_version           	CONSTANT NUMBER        := 1.0;
				  l_PmtPlans_rec            PmtPlan_rec_type;
				  l_pmt_plan_id		NUMBER;
				  l_credit_type_id		NUMBER;
				  l_pay_interval_type_id    NUMBER;
				  l_count                   NUMBER := 0;
				  l_start_date              DATE;
				  l_end_date                DATE;

				  L_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_PmtPlan_PUB';
				  L_LAST_UPDATE_DATE          DATE    := sysdate;
				  L_LAST_UPDATED_BY           NUMBER  := fnd_global.user_id;
				  L_CREATION_DATE             DATE    := sysdate;
				  L_CREATED_BY                NUMBER  := fnd_global.user_id;
				  L_LAST_UPDATE_LOGIN         NUMBER  := fnd_global.login_id;
				  L_ROWID                     VARCHAR2(30);
				  L_PROGRAM_TYPE              VARCHAR2(30);

				  l_update_rec   cn_pmtplan_pvt.PmtPlan_rec_type;
				  l_update_old_rec   cn_pmtplan_pvt.PmtPlan_rec_type;
                  l_status VARCHAR2(1);
    cursor get_start_date is
        select start_date from cn_pmt_plans
        where name = p_PmtPlan_rec.name
        and org_id = p_PmtPlan_rec.org_id;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT    Update_PmtPlan;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
					p_api_version ,
					l_api_name    ,
					L_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_UPDATED';
   -- API body

   --Initialize g_mode
   g_mode := 'UPDATE';

   -- copy the old record values
   l_update_old_rec.org_id := p_old_PmtPlan_rec.org_id;
   --mo_global.validate_orgid_pub_api(org_id => l_update_old_rec.org_id,status =>l_status);
   l_update_old_rec.name := p_old_PmtPlan_rec.name;
   l_update_old_rec.minimum_amount := p_old_PmtPlan_rec.minimum_amount;
   l_update_old_rec.maximum_amount := p_old_PmtPlan_rec.maximum_amount;
   l_update_old_rec.min_rec_flag := p_old_PmtPlan_rec.min_rec_flag;
   l_update_old_rec.max_rec_flag := p_old_PmtPlan_rec.max_rec_flag;
   l_update_old_rec.max_recovery_amount := p_old_PmtPlan_rec.max_recovery_amount;
   l_update_old_rec.credit_type_name := p_old_PmtPlan_rec.credit_type_name;
   l_update_old_rec.pay_interval_type_name := p_old_PmtPlan_rec.pay_interval_type_name;
   l_update_old_rec.start_date := p_old_PmtPlan_rec.start_date;
   l_update_old_rec.end_date := p_old_PmtPlan_rec.end_date;
   l_update_old_rec.object_version_number := p_old_PmtPlan_rec.object_version_number;
   l_update_old_rec.recoverable_interval_type := p_old_PmtPlan_rec.recoverable_interval_type;
   l_update_old_rec.pay_against_commission := p_old_PmtPlan_rec.pay_against_commission;
   l_update_old_rec.payment_group_code := p_old_PmtPlan_rec.payment_group_code;

    IF (p_old_PmtPlan_rec.start_date is null)
    THEN
        OPEN get_start_date;
        FETCH get_start_date INTO l_update_old_rec.start_date;
    END IF;

     get_PmtPlan_id(
           x_return_status      => x_return_status,
           x_msg_count          => x_msg_count,
           x_msg_data           => x_msg_data,
           p_PmtPlan_rec        => p_old_PmtPlan_rec,
           x_pmt_plan_id        => l_pmt_plan_id,
           p_loading_status     => x_loading_status,
           x_loading_status     => x_loading_status,
           x_status             => x_status
	   );

    l_update_old_rec.pmt_plan_id := l_pmt_plan_id;

   -- Copy the new Record values into l_update_rec and call private

   l_update_rec.org_id := p_PmtPlan_rec.org_id;
   mo_global.validate_orgid_pub_api(org_id => l_update_rec.org_id,status =>l_status);
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'cn.plsql.cn_pmtplan_pub.Update_PmtPlan.org_validate',
                      'Validated org_id = ' || l_update_rec.org_id || ' status ='||l_status);
   end if;

   if (l_update_rec.org_id <> l_update_old_rec.org_id ) then
    FND_MESSAGE.SET_NAME ('FND' , 'FND_MO_OU_CANNOT_UPDATE');
    if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                      'cn.plsql.cn_paygroup_pub.update_PmtPlan.error',
                      true);
    end if;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME ('FND' , 'FND_MO_OU_CANNOT_UPDATE');
      FND_MSG_PUB.Add;
    END IF;

    RAISE FND_API.G_EXC_ERROR ;
  end if;
   l_update_rec.name := p_PmtPlan_rec.name;
   l_update_rec.minimum_amount := p_PmtPlan_rec.minimum_amount;
   l_update_rec.maximum_amount := p_PmtPlan_rec.maximum_amount;
   l_update_rec.min_rec_flag := p_PmtPlan_rec.min_rec_flag;
   l_update_rec.max_rec_flag := p_PmtPlan_rec.max_rec_flag;
   l_update_rec.max_recovery_amount := p_PmtPlan_rec.max_recovery_amount;
   l_update_rec.credit_type_name := p_PmtPlan_rec.credit_type_name;
   l_update_rec.pay_interval_type_name := p_PmtPlan_rec.pay_interval_type_name;
   l_update_rec.start_date := p_PmtPlan_rec.start_date;
   l_update_rec.end_date := p_PmtPlan_rec.end_date;
   l_update_rec.object_version_number := p_PmtPlan_rec.object_version_number;
   l_update_rec.recoverable_interval_type := p_PmtPlan_rec.recoverable_interval_type;
   l_update_rec.pay_against_commission := p_PmtPlan_rec.pay_against_commission;
   l_update_rec.payment_group_code := p_PmtPlan_rec.payment_group_code;

     get_PmtPlan_id(
           x_return_status      => x_return_status,
           x_msg_count          => x_msg_count,
           x_msg_data           => x_msg_data,
           p_PmtPlan_rec        => p_PmtPlan_rec,
           x_pmt_plan_id        => l_pmt_plan_id,
           p_loading_status     => x_loading_status,
           x_loading_status     => x_loading_status,
           x_status             => x_status
	   );

    l_update_rec.pmt_plan_id := l_pmt_plan_id;
   CN_PMTPLAN_PVT.Update_PmtPlan
     (p_api_version      => p_api_version,
      p_init_msg_list    => p_init_msg_list,
      p_commit           => p_commit,
      p_validation_level => p_validation_level,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_old_PmtPlan_rec  => l_update_old_rec,
      p_PmtPlan_rec      => l_update_rec,
      x_status           => x_status,
      x_loading_status   => x_loading_status
      );

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
      ROLLBACK TO Update_PmtPlan;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_PmtPlan;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Update_PmtPlan;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg( L_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
END Update_PmtPlan;

---------------------------------------------------------------------------*
--  Procedure Name : Delete Pmt Plans
---------------------------------------------------------------------------*
PROCEDURE  Delete_PmtPlan
  (    p_api_version			IN 	NUMBER,
       p_init_msg_list		        IN	VARCHAR2,
       p_commit	    		IN  	VARCHAR2,
       p_validation_level		IN  	NUMBER,
       x_return_status       	 OUT NOCOPY 	VARCHAR2,
       x_msg_count	           OUT NOCOPY 	NUMBER,
       x_msg_data		   OUT NOCOPY 	VARCHAR2,
       p_PmtPlan_rec                  IN    PmtPlan_rec_type ,
       x_status		 OUT NOCOPY 	VARCHAR2,
       x_loading_status    	 OUT NOCOPY 	VARCHAR2
       )  IS

    l_api_name		CONSTANT VARCHAR2(30) := 'Delete_PmtPlan';
    l_api_version     CONSTANT NUMBER := 1.0;
    L_PKG_NAME        CONSTANT VARCHAR2(30) := 'CN_PmtPlan_PUB';

    l_create_rec   cn_pmtplan_pvt.PmtPlan_rec_type;
    l_start_date   cn_pmt_plans.start_date%TYPE;
    l_status VARCHAR2(1);
    cursor get_start_date is
        select start_date from cn_pmt_plans
        where name = p_PmtPlan_rec.name
        and org_id = p_PmtPlan_rec.org_id;

BEGIN

    -- Get the start date for payment plan using the payment plan name and org id
    l_create_rec.org_id := p_PmtPlan_rec.org_id;
    mo_global.validate_orgid_pub_api(org_id => l_create_rec.org_id,status =>l_status);
    if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'cn.plsql.cn_pmtplan_pub.delete_PmtPlan.org_validate',
                      'Validated org_id = ' || l_create_rec.org_id || ' status ='||l_status);
   end if;
    l_create_rec.name := p_PmtPlan_rec.name;
    l_create_rec.start_date := p_PmtPlan_rec.start_date;

    IF (p_PmtPlan_rec.start_date is null)
    THEN
        OPEN get_start_date;
        FETCH get_start_date INTO l_create_rec.start_date;
    END IF;

    -- call the private package for deleting the payment plan
    CN_PMTPLAN_PVT.Delete_PmtPlan
     (p_api_version      => p_api_version,
      p_init_msg_list    => p_init_msg_list,
      p_commit           => p_commit,
      p_validation_level => p_validation_level,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_PmtPlan_rec      => l_create_rec,
      x_status           => x_status,
      x_loading_status   => x_loading_status);

END Delete_PmtPlan;

END CN_PmtPlan_PUB ;

/
