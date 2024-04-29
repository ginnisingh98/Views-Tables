--------------------------------------------------------
--  DDL for Package Body CN_SCENARIOS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SCENARIOS_PVT" AS
/*$Header: cnvscnb.pls 120.0 2007/07/26 01:11:26 appldev noship $*/

G_PKG_NAME         CONSTANT VARCHAR2(30)  :='CN_SCENARIOS_PVT';

PROCEDURE delete_scenario_plans
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_role_plan_id               IN      CN_SCENARIO_PLANS_ALL.ROLE_PLAN_ID%TYPE  := NULL,
   p_comp_plan_id               IN      CN_SCENARIO_PLANS_ALL.COMP_PLAN_ID%TYPE  := NULL,
   p_role_id                    IN      CN_SCENARIO_PLANS_ALL.ROLE_ID%TYPE  := NULL,
   x_return_status              OUT NOCOPY     VARCHAR2                        ,
   x_msg_count                  OUT NOCOPY     NUMBER                          ,
   x_msg_data                   OUT NOCOPY     VARCHAR2                        ) IS

   l_api_name                 CONSTANT VARCHAR2(30) := 'delete_scenario_plans';
   l_api_version              CONSTANT NUMBER       := 1.0;
BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT   delete_scenario_plans;
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

   IF p_role_plan_id is not null then
     delete from cn_scenario_plans_all where role_plan_id = p_role_plan_id;
   end if;


   IF p_role_id is not null then
     delete from cn_scenario_plans_all where role_id = p_role_id;
   end if;


   IF p_comp_plan_id is not null then
     delete from cn_scenario_plans_all where comp_plan_id = p_comp_plan_id;
   end if;

   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              ,
      p_encoded               =>      FND_API.G_FALSE         );
   EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_scenario_plans;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_scenario_plans;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      ROLLBACK TO delete_scenario_plans;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF      FND_MSG_PUB.check_msg_level
	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.add_exc_msg
	   (G_PKG_NAME          ,
	    l_api_name           );
      END IF;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
END;

END CN_SCENARIOS_PVT;

/
