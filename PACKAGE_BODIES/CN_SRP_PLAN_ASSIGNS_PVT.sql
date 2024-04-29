--------------------------------------------------------
--  DDL for Package Body CN_SRP_PLAN_ASSIGNS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SRP_PLAN_ASSIGNS_PVT" AS
/* $Header: cnvspab.pls 120.2.12010000.2 2009/11/05 21:59:37 rnagaraj ship $ */

-- Global variablefor  the translatable name for all Plan Assign objects.
G_PKG_NAME                CONSTANT VARCHAR2(30) := 'CN_SRP_PLAN_ASSIGNS_PVT';
G_NULL_DATE               CONSTANT DATE := to_date('31-12-9999','DD-MM-YYYY');

--| ----------------------------------------------------------------------+
--| Procedure : valid_srp_plan_assign
--| Desc : Procedure to validate srp plan assignment to a salesrep
--| ---------------------------------------------------------------------+
PROCEDURE valid_srp_plan_assign
  (
   x_return_status          OUT NOCOPY VARCHAR2 ,
   x_msg_count              OUT NOCOPY NUMBER   ,
   x_msg_data               OUT NOCOPY VARCHAR2 ,
   p_srp_role_id            IN    NUMBER,
   p_role_plan_id           IN    NUMBER,
   x_srp_plan_assigns_row   IN OUT NOCOPY cn_srp_plan_assigns%ROWTYPE ,
   x_role_id                OUT NOCOPY NUMBER,
   p_loading_status         IN  VARCHAR2 ,
   x_loading_status         OUT NOCOPY VARCHAR2
   )
  IS
     l_api_name          CONSTANT VARCHAR2(30) := 'valid_srp_plan_assign';
     l_dummy             NUMBER;
     l_srp_roles_row     cn_srp_roles%ROWTYPE;
     l_role_plans_row    cn_role_plans%ROWTYPE;
     l_srp_pay_grp_sd    cn_srp_pay_groups.start_date%TYPE;
     l_srp_pay_grp_ed    cn_srp_pay_groups.end_date%TYPE;
     l_spg_max_sd        cn_srp_pay_groups.start_date%TYPE;
     l_pay_group_id      cn_srp_pay_groups.pay_group_id%TYPE;

     l_temp_count        NUMBER;
BEGIN
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status;
   -- API body
   -- Check if Comp Plan does assign to the sales role
   BEGIN
      SELECT *
	INTO l_role_plans_row
	FROM cn_role_plans
	WHERE role_plan_id = p_role_plan_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
	 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.SET_NAME ('CN' , 'CN_ROLE_PLAN_ID_NOT_EXIST');
	    FND_MSG_PUB.Add;
	 END IF;
	 x_loading_status := 'CN_ROLE_PLAN_ID_NOT_EXIST';
	 RAISE FND_API.G_EXC_ERROR ;
   END;
   x_srp_plan_assigns_row.role_plan_id := p_role_plan_id;
   x_srp_plan_assigns_row.comp_plan_id := l_role_plans_row.comp_plan_id;
   x_srp_plan_assigns_row.org_id       := l_role_plans_row.org_id; --MOAC


   -- Check if Role does assign to the salesrep
   BEGIN
      SELECT *
	INTO l_srp_roles_row
	FROM cn_srp_roles
	WHERE srp_role_id = p_srp_role_id
	  AND org_id = l_role_plans_row.org_id;  --MOAC
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
	 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.SET_NAME ('CN' , 'CN_SRP_ROLE_ID_NOT_EXIST');
	    FND_MSG_PUB.Add;
	 END IF;
	 x_loading_status := 'CN_SRP_ROLE_ID_NOT_EXIST';
	 RAISE FND_API.G_EXC_ERROR ;
   END;
   x_srp_plan_assigns_row.srp_role_id := p_srp_role_id;
   x_srp_plan_assigns_row.salesrep_id := l_srp_roles_row.salesrep_id;
   x_srp_plan_assigns_row.role_id := l_srp_roles_row.role_id;


   -- Check if pased in role_plan_id and srp_role_id are use the same role
   IF l_role_plans_row.role_id <> l_srp_roles_row.role_id THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_SPA_ROLE_ID_NOT_SAME');
	 FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_SPA_ROLE_ID_NOT_SAME';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   x_role_id := l_role_plans_row.role_id;

   -- Get correct start date/end date
   -- Must be in range of these 3 :
   --   1. srp_roles : start date / end date
   --   2. role_plans: start date / end date
   --   3. srp_pay_groups : min(start date) / max(end date)


   -- check whether paygroup assignment exists or not
   SELECT count(1)
     INTO l_temp_count
     FROM cn_srp_pay_groups
    WHERE salesrep_id = x_srp_plan_assigns_row.salesrep_id
      AND org_id = x_srp_plan_assigns_row.org_id; -- MOAC


   -- Get srp_pay_groups : max(end date) from max(start_date) record
   --   if it's NULL, get the end_date from cn_pay_groups
   IF l_temp_count > 0 THEN

      -- Get srp_pay_groups : min(start date)
      SELECT MIN(start_date), MAX(start_date)
	INTO l_srp_pay_grp_sd, l_spg_max_sd
	FROM cn_srp_pay_groups
       WHERE salesrep_id = x_srp_plan_assigns_row.salesrep_id
	 AND org_id = x_srp_plan_assigns_row.org_id; -- MOAC

     BEGIN
        SELECT Decode(spg.end_date, NULL, pg.end_date,spg.end_date),
	       spg.pay_group_id
  	  INTO l_srp_pay_grp_ed,l_pay_group_id
	  FROM cn_srp_pay_groups spg, cn_pay_groups pg
	 WHERE spg.pay_group_id = pg.pay_group_id
	   AND   spg.salesrep_id = x_srp_plan_assigns_row.salesrep_id
	   AND   spg.org_id      = x_srp_plan_assigns_row.org_id  -- MOAC
	   AND   spg.start_date = l_spg_max_sd;
     EXCEPTION
        WHEN no_data_found THEN
	   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	      FND_MESSAGE.Set_Name('CN', 'CN_PAY_GROUP_NOT_FOUND');
	      FND_MESSAGE.SET_TOKEN('PAY_GROUP_ID', l_pay_group_id);
	      FND_MSG_PUB.Add;
	   END IF;
	   x_loading_status := 'CN_PAY_GROUP_NOT_FOUND';
	   RAISE FND_API.G_EXC_ERROR ;
     END;
   ELSE
     --l_srp_pay_grp_sd := l_role_plans_row.start_date;
     --l_srp_pay_grp_ed := l_role_plans_row.end_date;
      x_loading_status := 'CN_SPA_NO_INTERSECT_DATE';
      GOTO  end_of_valid_srp_plan_assign;
   END IF;

   -- start_date : compare rule 1 and rule 2
   IF l_srp_roles_row.start_date < l_role_plans_row.start_date THEN
      x_srp_plan_assigns_row.start_date := l_role_plans_row.start_date;
    ELSE
      x_srp_plan_assigns_row.start_date := l_srp_roles_row.start_date;
   END IF;
   -- start_date : compare with rule 3
   IF x_srp_plan_assigns_row.start_date < l_srp_pay_grp_sd THEN
      x_srp_plan_assigns_row.start_date := l_srp_pay_grp_sd;
   END IF;
   -- end_date : compare rule 1 and rule 2
   IF l_srp_roles_row.end_date IS NULL THEN
      x_srp_plan_assigns_row.end_date := l_role_plans_row.end_date;
    ELSIF l_role_plans_row.end_date IS NULL THEN
      x_srp_plan_assigns_row.end_date := l_srp_roles_row.end_date;
    ELSIF l_srp_roles_row.end_date > l_role_plans_row.end_date THEN
      x_srp_plan_assigns_row.end_date := l_role_plans_row.end_date;
    ELSE
      x_srp_plan_assigns_row.end_date := l_srp_roles_row.end_date;
   END IF;
   -- end_date : compare with rule 3
   IF x_srp_plan_assigns_row.end_date IS NULL THEN
      x_srp_plan_assigns_row.end_date := l_srp_pay_grp_ed;
    ELSIF l_srp_pay_grp_ed IS NOT NULL AND
      x_srp_plan_assigns_row.end_date > l_srp_pay_grp_ed THEN
      x_srp_plan_assigns_row.end_date := l_srp_pay_grp_ed;
   END IF;

   -- check if no intersection between these 3 start date/end date
   -- If so, at INSERT() : no insert happened
   --        at UPDATE() : delete this record since should not exist now.
   IF (x_srp_plan_assigns_row.end_date IS NOT NULL) AND
     (x_srp_plan_assigns_row.start_date > x_srp_plan_assigns_row.end_date) THEN
      x_loading_status := 'CN_SPA_NO_INTERSECT_DATE';
      GOTO  end_of_valid_srp_plan_assign;
   END IF;

   -- check if duplicate
   BEGIN
      IF x_srp_plan_assigns_row.srp_plan_assign_id IS NULL THEN
	 SELECT 1 INTO l_dummy FROM dual
	   WHERE NOT EXISTS
	   (SELECT 1
	    FROM cn_srp_plan_assigns
	    WHERE role_plan_id = p_role_plan_id
	    AND   srp_role_id = p_srp_role_id);
      END IF ;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
	 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('CN', 'SRP_PLAN_ASSIGNED');
	    FND_MSG_PUB.Add;
	 END IF;
	 x_loading_status := 'SRP_PLAN_ASSIGNED';
	 RAISE FND_API.G_EXC_ERROR ;
   END;
   << end_of_valid_srp_plan_assign >>
     NULL;
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
END valid_srp_plan_assign;

PROCEDURE business_event
  (p_srp_plan_assign_id     IN NUMBER,
   p_srp_role_id            IN NUMBER,
   p_role_plan_id           IN NUMBER,
   p_salesrep_id            IN NUMBER,
   p_role_id                IN NUMBER,
   p_comp_plan_id           IN NUMBER,
   p_start_date             IN DATE,
   p_end_date               IN DATE) IS

   l_key        VARCHAR2(80);
   l_event_name VARCHAR2(80);
   l_list       wf_parameter_list_t;
BEGIN
   -- p_operation = Add, Update, Remove
   l_event_name := 'oracle.apps.cn.resource.PlanAssign.Add';

   --Get the item key
   -- for create - event_name || srp_paygroup_id
   l_key := l_event_name || '-' || p_srp_plan_assign_id;

   -- build parameter list as appropriate
   wf_event.AddParameterToList('SRP_PLAN_ASSIGN_ID',p_srp_plan_assign_id,l_list);
   wf_event.AddParameterToList('SRP_ROLE_ID',p_srp_role_id,l_list);
   wf_event.AddParameterToList('ROLE_PLAN_ID',p_role_plan_id,l_list);
   wf_event.AddParameterToList('COMP_PLAN_ID',p_comp_plan_id,l_list);
   wf_event.AddParameterToList('ROLE_ID',p_role_id,l_list);
   wf_event.AddParameterToList('SALESREP_ID',p_salesrep_id,l_list);
   wf_event.AddParameterToList('START_DATE',p_start_date,l_list);
   wf_event.AddParameterToList('END_DATE',p_end_date,l_list);

   -- Raise Event
   wf_event.raise
     (p_event_name        => l_event_name,
      p_event_key         => l_key,
      p_parameters        => l_list);

   l_list.DELETE;
END business_event;


--| -----------------------------------------------------------------------+
--| Procedure : Create_Srp_Plan_Assigns
--| Desc      : Procedure to create a new comp plan assignment to an salesrep
--| -----------------------------------------------------------------------+
PROCEDURE Create_Srp_Plan_Assigns
  (p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count	        OUT NOCOPY   NUMBER,
   x_msg_data	        OUT NOCOPY   VARCHAR2,
   p_srp_role_id        IN    NUMBER,
   p_role_plan_id       IN    NUMBER,
   p_attribute_rec      IN    cn_global_var.attribute_rec_type := CN_GLOBAL_VAR.G_MISS_ATTRIBUTE_REC,
   x_srp_plan_assign_id OUT NOCOPY   NUMBER,
   x_loading_status     OUT NOCOPY   VARCHAR2
   ) IS

      l_api_name     CONSTANT VARCHAR2(30) := 'Create_Srp_Plan_Assigns';
      l_api_version  CONSTANT NUMBER  := 1.0;
      l_spa_row      cn_srp_plan_assigns%ROWTYPE ;
      l_role_id      cn_roles.role_id%TYPE;
      l_null_date    CONSTANT DATE := to_date('31-12-9999','DD-MM-YYYY');

      l_temp_count   NUMBER;
      l_temp_start_date  DATE;
      l_temp_end_date    DATE;

      CURSOR pg_cur(srp_id number, l_org_id number)
      IS
         select start_date, end_date
         from cn_srp_pay_groups
         where salesrep_id = srp_id
           and org_id = l_org_id; -- MOAC

      pg_cur_rec  pg_cur%ROWTYPE;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT	Create_Srp_Plan_Assigns;
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
   -- API body
   --
   -- Valid compensation plan assignment
   --
   valid_srp_plan_assign
     ( x_return_status  => x_return_status,
       x_msg_count      => x_msg_count,
       x_msg_data       => x_msg_data,
       p_srp_role_id    => p_srp_role_id,
       p_role_plan_id   => p_role_plan_id,
       x_srp_plan_assigns_row => l_spa_row,
       x_role_id        => l_role_id,
       p_loading_status => x_loading_status,
       x_loading_status => x_loading_status
       );

   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS  ) THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF  x_loading_status = 'CN_SPA_NO_INTERSECT_DATE' THEN
      x_loading_status := 'CN_INSERTED';
      GOTO end_of_create_srp_plan_assigns;
    ELSE
	 -- Create comp plan assignment into cn_srp_plan_assigns
	 cn_srp_plan_assigns_pkg.insert_row
	   (x_srp_plan_assign_id    => x_srp_plan_assign_id
	    ,x_srp_role_id          => l_spa_row.srp_role_id
	    ,x_role_plan_id         => l_spa_row.role_plan_id
	    ,x_salesrep_id          => l_spa_row.salesrep_id
	    ,x_role_id              => l_spa_row.role_id
	    ,x_comp_plan_id         => l_spa_row.comp_plan_id
	 ,x_start_date           => l_spa_row.start_date
	 ,x_end_date             => l_spa_row.end_date
	    ,x_created_by            => FND_GLOBAL.USER_ID
	    ,x_creation_date         => sysdate
	    ,x_last_update_date      => sysdate
	    ,x_last_updated_by       => FND_GLOBAL.USER_ID
	    ,x_last_update_login     => FND_GLOBAL.LOGIN_ID
	    ,x_attribute_category    => p_attribute_rec.attribute_category
	    ,x_attribute1            => p_attribute_rec.attribute1
	    ,x_attribute2            => p_attribute_rec.attribute2
	    ,x_attribute3            => p_attribute_rec.attribute3
	    ,x_attribute4            => p_attribute_rec.attribute4
	    ,x_attribute5            => p_attribute_rec.attribute5
	    ,x_attribute6            => p_attribute_rec.attribute6
	    ,x_attribute7            => p_attribute_rec.attribute7
	    ,x_attribute8            => p_attribute_rec.attribute8
	    ,x_attribute9            => p_attribute_rec.attribute9
	    ,x_attribute10           => p_attribute_rec.attribute10
	    ,x_attribute11           => p_attribute_rec.attribute11
	    ,x_attribute12           => p_attribute_rec.attribute12
	    ,x_attribute13           => p_attribute_rec.attribute13
	    ,x_attribute14           => p_attribute_rec.attribute14
	    ,x_attribute15           => p_attribute_rec.attribute15
	     );

	 -- create business event
	 business_event
	   (p_srp_plan_assign_id     => x_srp_plan_assign_id,
	    p_srp_role_id            => l_spa_row.srp_role_id,
	    p_role_plan_id           => l_spa_row.role_plan_id,
	    p_salesrep_id            => l_spa_row.salesrep_id,
	    p_role_id                => l_spa_row.role_id,
	    p_comp_plan_id           => l_spa_row.comp_plan_id,
	    p_start_date             => l_spa_row.start_date,
	    p_end_date               => l_spa_row.end_date);

      -- Check if there're any pay group assignments inside this time period


      FOR pg_cur_rec IN pg_cur(l_spa_row.salesrep_id,
                               l_spa_row.org_id) LOOP
        IF(pg_cur_rec.start_date<=l_spa_row.start_date) THEN
           l_temp_start_date := l_spa_row.start_date;
        ELSE
           l_temp_start_date := pg_cur_rec.start_date;
        END IF;

        IF(nvl(pg_cur_rec.end_date,l_null_date) >= nvl(l_spa_row.end_date,l_null_date)) THEN
           l_temp_end_date := l_spa_row.end_date;
        ELSE
           l_temp_end_date := pg_cur_rec.end_date;
        END IF;

	-- check intersect
	IF l_temp_start_date <= nvl(l_temp_end_date, l_null_date) then
	   -- Create entry in cn_srp_periods
	 CN_SRP_PERIODS_PVT.Create_Srp_Periods
	   (p_api_version          => 1.0,
	    x_return_status        => x_return_status,
	    x_msg_count            => x_msg_count,
	    x_msg_data             => x_msg_data,
	      p_role_id              => l_role_id,
	    p_comp_plan_id         => l_spa_row.comp_plan_id,
	    p_salesrep_id          => l_spa_row.salesrep_id,
	      p_start_date           => l_temp_start_date,
	      p_end_date             => l_temp_end_date,
	    x_loading_status       => x_loading_status
	      );


	 IF (x_return_status <> FND_API.G_RET_STS_SUCCESS  ) THEN
	    RAISE FND_API.G_EXC_ERROR ;
	 END IF;
	END IF;
      END LOOP;

	 -- insert all child records
	 cn_srp_quota_assigns_pkg.insert_record
	   (x_srp_plan_assign_id => x_srp_plan_assign_id
	    ,x_quota_id	   => null);

   END IF;
   -- End of API body.
   << end_of_create_srp_plan_assigns >>
     NULL;
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
      ROLLBACK TO   Create_Srp_Plan_Assigns;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Srp_Plan_Assigns;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Srp_Plan_Assigns;
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
END Create_Srp_Plan_Assigns;

--| ----------------------------------------------------------------------+
--| Procedure : Update_Srp_Plan_Assigns
--| Desc       : Procedure to update a comp plan assignment to an salesrep
--| ----------------------------------------------------------------------+

PROCEDURE Update_Srp_Plan_Assigns
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count	        OUT NOCOPY   NUMBER,
   x_msg_data	        OUT NOCOPY   VARCHAR2,
   p_srp_role_id        IN    NUMBER,
   p_role_plan_id       IN    NUMBER,
   p_attribute_rec      IN    CN_GLOBAL_VAR.attribute_rec_type := CN_GLOBAL_VAR.G_MISS_ATTRIBUTE_REC,
   x_loading_status     OUT NOCOPY   VARCHAR2
)  IS

      l_api_name     CONSTANT VARCHAR2(30) := 'Update_Srp_Plan_Assigns';
      l_api_version  CONSTANT NUMBER  := 1.0;
      l_spa_row      cn_srp_plan_assigns%ROWTYPE ;
      l_role_id      cn_roles.role_id%TYPE;
      l_old_start_date  cn_srp_plan_assigns.start_date%TYPE;
      l_old_end_date    cn_srp_plan_assigns.end_date%TYPE;
      l_srp_plan_assigns_id cn_srp_plan_assigns.srp_plan_assign_id%TYPE;

      l_temp_count   NUMBER;
      l_temp_start_date DATE;
      l_temp_end_date   DATE;
      l_null_date    CONSTANT DATE := to_date('31-12-9999','DD-MM-YYYY');

      CURSOR pg_cur(srp_id number, l_org_id number) IS
         select start_date, end_date
         from cn_srp_pay_groups
         where salesrep_id = srp_id
           and org_id = l_org_id; --MOAC

      pg_cur_rec  pg_cur%ROWTYPE;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT	Update_Srp_Plan_Assigns;
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
   -- API body
   -- Check old rec exist in cn_srp_plan_assigns
   BEGIN
      SELECT * INTO l_spa_row
	FROM cn_srp_plan_assigns
	WHERE srp_role_id = p_srp_role_id
	AND   role_plan_id = p_role_plan_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
	 -- CN_SRP_PLAN_ASSIGNS_NOT_EXIST, create new record
	 CN_SRP_PLAN_ASSIGNS_PVT.Create_Srp_Plan_Assigns
	   (p_api_version          => 1.0,
	    x_return_status        => x_return_status,
	    x_msg_count            => x_msg_count,
	    x_msg_data             => x_msg_data,
	    p_srp_role_id          => p_srp_role_id,
	    p_role_plan_id         => p_role_plan_id,
	    x_srp_plan_assign_id   => l_srp_plan_assigns_id,
	    x_loading_status       => x_loading_status
	    );
	 IF (x_return_status <> FND_API.G_RET_STS_SUCCESS  ) THEN
	    RAISE FND_API.G_EXC_ERROR ;
	  ELSE
	    GOTO end_of_update_srp_plan_assigns;
	 END IF;
   END;
   l_old_start_date := l_spa_row.start_date;
   l_old_end_date := l_spa_row.end_date;
   --
   -- Valid compensation plan assignment
   --
   valid_srp_plan_assign
     ( x_return_status  => x_return_status,
       x_msg_count      => x_msg_count,
       x_msg_data       => x_msg_data,
       p_srp_role_id    => p_srp_role_id,
       p_role_plan_id   => p_role_plan_id,
       x_srp_plan_assigns_row => l_spa_row,
       x_role_id        => l_role_id,
       p_loading_status => x_loading_status,
       x_loading_status => x_loading_status
       );
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS  ) THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF  x_loading_status = 'CN_SPA_NO_INTERSECT_DATE' THEN
      -- Delete entry in cn_srp_plan_assigns
      Delete_Srp_Plan_Assigns
	(p_api_version          => 1.0,
	 x_return_status        => x_return_status,
	 x_msg_count            => x_msg_count,
	 x_msg_data             => x_msg_data,
	 p_srp_role_id          => p_srp_role_id,
	 p_role_plan_id         => p_role_plan_id,
	 x_loading_status       => x_loading_status
	 );
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS  ) THEN
	 RAISE FND_API.G_EXC_ERROR ;
       ELSE
	 x_loading_status := 'CN_UPDATED';
   END IF;
    ELSE
      -- Update comp plan assignment into cn_srp_plan_assigns
      cn_srp_plan_assigns_pkg.update_row
	(x_srp_plan_assign_id   => l_spa_row.srp_plan_assign_id
	 ,x_srp_role_id         => l_spa_row.srp_role_id
	 ,x_role_plan_id         => l_spa_row.role_plan_id
	 ,x_salesrep_id          => l_spa_row.salesrep_id
	 ,x_role_id              => l_spa_row.role_id
	 ,x_comp_plan_id         => l_spa_row.comp_plan_id
	 ,x_start_date           => l_spa_row.start_date
	 ,x_end_date             => l_spa_row.end_date
	 ,x_last_update_date     => sysdate
	 ,x_last_updated_by       => fnd_global.user_id
	 ,x_last_update_login     => fnd_global.login_id
	 ,x_attribute_category    => NVL(p_attribute_rec.attribute_category,fnd_api.g_miss_char)
	 ,x_attribute1            => NVL(p_attribute_rec.attribute1,fnd_api.g_miss_char)
	 ,x_attribute2            => NVL(p_attribute_rec.attribute2,fnd_api.g_miss_char)
	 ,x_attribute3            => NVL(p_attribute_rec.attribute3 ,fnd_api.g_miss_char)
	 ,x_attribute4            => NVL(p_attribute_rec.attribute4,fnd_api.g_miss_char)
	 ,x_attribute5            => NVL(p_attribute_rec.attribute5,fnd_api.g_miss_char)
	 ,x_attribute6            => NVL(p_attribute_rec.attribute6,fnd_api.g_miss_char)
	 ,x_attribute7            => NVL(p_attribute_rec.attribute7,fnd_api.g_miss_char)
	,x_attribute8            =>  NVL(p_attribute_rec.attribute8,fnd_api.g_miss_char)
	,x_attribute9            =>  NVL(p_attribute_rec.attribute9,fnd_api.g_miss_char)
	,x_attribute10           =>  NVL(p_attribute_rec.attribute10,fnd_api.g_miss_char)
	,x_attribute11           =>  NVL(p_attribute_rec.attribute11,fnd_api.g_miss_char)
	,x_attribute12           =>  NVL(p_attribute_rec.attribute12,fnd_api.g_miss_char)
	,x_attribute13           =>  NVL(p_attribute_rec.attribute13,fnd_api.g_miss_char)
	,x_attribute14           =>  NVL(p_attribute_rec.attribute14,fnd_api.g_miss_char)
	,x_attribute15           =>  NVL(p_attribute_rec.attribute15,fnd_api.g_miss_char)
	);
      -- Create new entry into cn_srp_periods if extend date range
      IF (l_spa_row.start_date < l_old_start_date) OR
	( (Nvl(l_old_end_date,FND_API.G_MISS_DATE) <>
	   Nvl(l_spa_row.end_date,FND_API.G_MISS_DATE)) AND
	  ( (l_spa_row.end_date IS NULL) OR
	    ((l_spa_row.end_date IS NOT NULL) AND (l_old_end_date IS NOT NULL)
	     AND (l_old_end_date < l_spa_row.end_date)) )
	  ) THEN

      FOR  pg_cur_rec IN pg_cur(l_spa_row.salesrep_id,
                                l_spa_row.org_id) LOOP
	 IF(pg_cur_rec.start_date<=l_spa_row.start_date) THEN
	    l_temp_start_date := l_spa_row.start_date;
	  ELSE
	    l_temp_start_date := pg_cur_rec.start_date;
	 END IF;

	 IF(nvl(pg_cur_rec.end_date,l_null_date) >= nvl(l_spa_row.end_date,l_null_date)) THEN
	    l_temp_end_date := l_spa_row.end_date;
	  ELSE
	    l_temp_end_date := pg_cur_rec.end_date;
	 END IF;

	 IF l_temp_start_date <= nvl(l_temp_end_date, l_null_date) THEN
	    -- Create entry in cn_srp_periods
	 CN_SRP_PERIODS_PVT.Create_Srp_Periods
	   (p_api_version          => 1.0,
	    x_return_status        => x_return_status,
	    x_msg_count            => x_msg_count,
	    x_msg_data             => x_msg_data,
	    p_role_id              => l_role_id,
	    p_comp_plan_id         => l_spa_row.comp_plan_id,
	    p_salesrep_id          => l_spa_row.salesrep_id,
	    p_start_date           => l_temp_start_date,
	    p_end_date             => l_temp_end_date,
	    x_loading_status       => x_loading_status
	    );
	 IF (x_return_status <> FND_API.G_RET_STS_SUCCESS  ) THEN
	    RAISE FND_API.G_EXC_ERROR ;
	 END IF;
	 END IF;
      END LOOP;
     END IF;
   END IF;
   -- End of API body.
   << end_of_update_srp_plan_assigns >>
     NULL;
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
      ROLLBACK TO   Update_Srp_Plan_Assigns;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Srp_Plan_Assigns;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Srp_Plan_Assigns;
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
END Update_Srp_Plan_Assigns;

--| -----------------------------------------------------------------------+
--| Procedure : Delete_Srp_Plan_Assigns
--| Desc      : Procedure to create a new comp plan assignment to an salesrep
--| -----------------------------------------------------------------------+

PROCEDURE Delete_Srp_Plan_Assigns
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count	        OUT NOCOPY   NUMBER,
   x_msg_data	        OUT NOCOPY   VARCHAR2,
   p_srp_role_id        IN    NUMBER,
   p_role_plan_id       IN    NUMBER,
   x_loading_status     OUT NOCOPY   VARCHAR2
)  IS

      l_api_name     CONSTANT VARCHAR2(30) := 'Delete_Srp_Plan_Assigns';
      l_api_version  CONSTANT NUMBER  := 1.0;
      l_srp_plan_assign_id    cn_srp_plan_assigns.srp_plan_assign_id%TYPE;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT	Delete_Srp_Plan_Assigns;
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
   -- API body
   -- Check if record exist in db
   BEGIN
      SELECT srp_plan_assign_id INTO l_srp_plan_assign_id
	FROM cn_srp_plan_assigns
	WHERE srp_role_id = p_srp_role_id
	AND   role_plan_id = p_role_plan_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
	 -- IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	 --   FND_MESSAGE.Set_Name('CN', 'CN_SRP_PLAN_ASSIGNS_NOT_EXIST');
	 --   FND_MSG_PUB.Add;
	 -- END IF;
	 -- x_loading_status := 'CN_SRP_PLAN_ASSIGNS_NOT_EXIST';
	 -- RAISE FND_API.G_EXC_ERROR ;

	 -- CN_SRP_PLAN_ASSIGNS_NOT_EXIST, nothing to delete, exit api
	 GOTO end_of_delete_srp_plan_assigns;
   END;
      -- Delete detail record
   cn_srp_quota_assigns_pkg.delete_record
     (x_srp_plan_assign_id => l_srp_plan_assign_id
      ,x_quota_id	      => null);

   -- Delete comp plan assignment from cn_srp_plan_assigns
   cn_srp_plan_assigns_pkg.delete_row
     (x_srp_plan_assign_id   => l_srp_plan_assign_id);
   -- End of API body.
   << end_of_delete_srp_plan_assigns >>
     NULL;
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
      ROLLBACK TO   Delete_Srp_Plan_Assigns;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_Srp_Plan_Assigns;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_Srp_Plan_Assigns;
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
END Delete_Srp_Plan_Assigns;

END CN_SRP_PLAN_ASSIGNS_PVT ;

/
