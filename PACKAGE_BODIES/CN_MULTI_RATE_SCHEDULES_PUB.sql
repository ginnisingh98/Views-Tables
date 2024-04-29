--------------------------------------------------------
--  DDL for Package Body CN_MULTI_RATE_SCHEDULES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_MULTI_RATE_SCHEDULES_PUB" AS
/*$Header: cnprschb.pls 120.2.12010000.2 2009/09/16 22:51:06 rnagaraj ship $*/

G_PKG_NAME         CONSTANT VARCHAR2(30)  := 'CN_MULTI_RATE_SCHEDULES_PUB';

-- local util functions
-- to get a rate schedule ID from its name
FUNCTION get_rate_schedule_id(p_name in CN_RATE_SCHEDULES.NAME%TYPE)
  RETURN CN_RATE_SCHEDULES.RATE_SCHEDULE_ID%TYPE IS

  l_rate_schedule_id CN_RATE_SCHEDULES.RATE_SCHEDULE_ID%TYPE;

BEGIN
   select RATE_SCHEDULE_ID into l_rate_schedule_id
     from CN_RATE_SCHEDULES
    where name = p_name;

   RETURN l_rate_schedule_id;
EXCEPTION
   when others then
      fnd_message.set_name('CN', 'CN_RATE_SCHEDULE_NOT_EXIST');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
END get_rate_schedule_id;

-- to get a rate dimension ID from its name
FUNCTION get_rate_dimension_id(p_name in CN_RATE_DIMENSIONS.NAME%TYPE)
  RETURN CN_RATE_DIMENSIONS.RATE_DIMENSION_ID%TYPE IS

  l_rate_dimension_id CN_RATE_DIMENSIONS.RATE_DIMENSION_ID%TYPE;

BEGIN
   select RATE_DIMENSION_ID into l_rate_dimension_id
     from CN_RATE_DIMENSIONS
    where name = p_name;

   RETURN l_rate_dimension_id;
EXCEPTION
   when others then
      fnd_message.set_name('CN', 'CN_RATE_DIMENSION_NOT_EXIST');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
END get_rate_dimension_id;

-- to get a rate_sch_dim_id from a given rate dimension ID and rate schedule ID
FUNCTION get_rate_sch_dim_id(p_rate_schedule_id  in CN_RATE_SCHEDULES.RATE_SCHEDULE_ID%TYPE,
			     p_rate_dimension_id in CN_RATE_DIMENSIONS.RATE_DIMENSION_ID%TYPE)
  RETURN CN_RATE_SCH_DIMS.RATE_SCH_DIM_ID%TYPE IS

   l_rate_sch_dim_id CN_RATE_SCH_DIMS.RATE_SCH_DIM_ID%TYPE;
BEGIN
   select rate_sch_dim_id into l_rate_sch_dim_id
     from cn_rate_sch_dims
    where rate_schedule_id  = p_rate_schedule_id
      and rate_dimension_id = p_rate_dimension_id;

   RETURN l_rate_sch_dim_id;
EXCEPTION
   when others THEN
      fnd_message.set_name('CN', 'CN_RATE_DIM_ASSIGN_NOT_EXIST');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
END get_rate_sch_dim_id;

-- to get an expression ID from its name
FUNCTION get_exp_id(p_name in CN_CALC_SQL_EXPS.NAME%TYPE)
  RETURN CN_CALC_SQL_EXPS.CALC_SQL_EXP_ID%TYPE IS

   l_calc_sql_exp_id CN_CALC_SQL_EXPS.CALC_SQL_EXP_ID%TYPE;
BEGIN
   select CALC_SQL_EXP_ID into l_calc_sql_exp_id
     from CN_CALC_SQL_EXPS
    where name = p_name;

   RETURN l_calc_sql_exp_id;
EXCEPTION
   when others THEN
      fnd_message.set_name('CN', 'CN_EXP_NOT_EXIST');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
END get_exp_id;

-- to get a rate_dim_tier_id from the rate_dimension_id and its sequence
FUNCTION get_rate_dim_tier_id(p_rate_dimension_id in CN_RATE_DIM_TIERS.RATE_DIMENSION_ID%TYPE,
			      p_tier_sequence     in CN_RATE_DIM_TIERS.TIER_SEQUENCE%TYPE)
  RETURN CN_RATE_DIM_TIERS.RATE_DIM_TIER_ID%TYPE IS

   l_rate_dim_tier_id CN_RATE_DIM_TIERS.RATE_DIM_TIER_ID%TYPE;
BEGIN
   select rate_dim_tier_id into l_rate_dim_tier_id
     from cn_rate_dim_tiers
    where rate_dimension_id = p_rate_dimension_id
      and tier_sequence     = p_tier_sequence;

   RETURN l_rate_dim_tier_id;
EXCEPTION
   when others THEN
      fnd_message.set_name('CN', 'CN_RATE_DIM_TIER_NOT_EXIST');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
END get_rate_dim_tier_id;

-- to get a rate_dim_tier_id from the rate_schedule and sequence numbers
FUNCTION get_rate_dim_tier_id(p_rate_schedule_id  in CN_RATE_SCHEDULES.RATE_SCHEDULE_ID%TYPE,
			      p_rate_dim_sequence in CN_RATE_SCH_DIMS.RATE_DIM_SEQUENCE%TYPE,
			      p_tier_sequence     in CN_RATE_DIM_TIERS.TIER_SEQUENCE%TYPE)
  RETURN CN_RATE_DIM_TIERS.RATE_DIM_TIER_ID%TYPE IS

   l_rate_dim_tier_id CN_RATE_DIM_TIERS.RATE_DIM_TIER_ID%TYPE;
BEGIN
   select rdt.rate_dim_tier_id into l_rate_dim_tier_id
     from cn_rate_sch_dims rsd, cn_rate_dim_tiers rdt
     where rsd.rate_schedule_id  = p_rate_schedule_id
       and rsd.rate_dim_sequence = p_rate_dim_sequence
       and rdt.rate_dimension_id = rsd.rate_dimension_id
       and rdt.tier_sequence     = p_tier_sequence;

   RETURN l_rate_dim_tier_id;
EXCEPTION
   when others THEN
      fnd_message.set_name('CN', 'CN_RATE_DIM_TIER_NOT_EXIST');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
END get_rate_dim_tier_id;

PROCEDURE translate_values(p_dim_unit_code   IN CN_RATE_DIMENSIONS.DIM_UNIT_CODE%TYPE,
			   p_value1          IN VARCHAR2,
			   p_value2          IN VARCHAR2,
			   p_minimum_amount OUT NOCOPY CN_RATE_DIM_TIERS.MINIMUM_AMOUNT%TYPE,
			   p_maximum_amount OUT NOCOPY CN_RATE_DIM_TIERS.MAXIMUM_AMOUNT%TYPE,
			   p_min_exp_id     OUT NOCOPY CN_RATE_DIM_TIERS.MIN_EXP_ID%TYPE,
			   p_max_exp_id     OUT NOCOPY CN_RATE_DIM_TIERS.MAX_EXP_ID%TYPE,
			   p_string_value   OUT NOCOPY CN_RATE_DIM_TIERS.STRING_VALUE%TYPE) IS
BEGIN
   if p_dim_unit_code = 'AMOUNT' OR p_dim_unit_code = 'PERCENT' then
      p_minimum_amount := p_value1;
      p_maximum_amount := p_value2;
    elsif p_dim_unit_code = 'EXPRESSION' then
      p_min_exp_id := get_exp_id(p_value1);
      p_max_exp_id := get_exp_id(p_value2);
    elsif p_dim_unit_code = 'STRING' then
      p_string_value := p_value1; -- value2 not used for strings
    else
      fnd_message.set_name('CN', 'CN_INVALID_DIM_UOM');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
   end if;

EXCEPTION
   when others THEN
      fnd_message.set_name('CN', 'CN_INVALID_TIER');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
END translate_values;

-- to raise an error according to the return status passed in
PROCEDURE check_ret_sts(l_return_status IN VARCHAR2) IS
BEGIN
   if l_return_status = FND_API.G_RET_STS_ERROR then
      RAISE FND_API.G_EXC_ERROR;
    elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;
END check_ret_sts;


----------------------------- actual public API's ----------------------------
PROCEDURE Create_Schedule
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_name                       IN      CN_RATE_SCHEDULES.NAME%TYPE,
   p_commission_unit_code       IN      CN_RATE_SCHEDULES.COMMISSION_UNIT_CODE%TYPE,
   p_dims_tbl                   IN      dim_assign_tbl_type := g_miss_dim_assign_tbl,
   -- Start - MOAC Change
   p_org_id                     IN      CN_RATE_SCHEDULES.ORG_ID%TYPE := NULL,
   -- End  - MOAC Change
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2) IS

   l_rate_schedule_id           CN_RATE_SCHEDULES.RATE_SCHEDULE_ID%TYPE;
   l_api_name                   CONSTANT VARCHAR2(30) := 'Create_Schedule';
   l_api_version                CONSTANT NUMBER       := 1.0;
   l_dims_tbl                   CN_MULTI_RATE_SCHEDULES_PVT.dims_tbl_type;
   -- Start - MOAC Change
   l_org_id  NUMBER;
   l_status  VARCHAR2(1);
   -- End   - MOAC Change
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT    Create_Schedule;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                        p_api_version ,
                                        l_api_name    ,
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

   -- Start - R12 MOAC Changes
   l_org_id := p_org_id;
   mo_global.validate_orgid_pub_api(org_id => l_org_id,
                                    status => l_status);
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'cn.plsql.cn_multi_rate_schedules_pub.create_schedule.org_validate',
                     'Validated org_id = ' || l_org_id || ' status = '||l_status);
   end if;
   -- End - R12 MOAC Changes

   -- get ID's in the dims_tbl to pass on to private API
   if p_dims_tbl.count > 0 then
      for i in 1..p_dims_tbl.count loop
	 l_dims_tbl(i).rate_dimension_id :=
	   get_rate_dimension_id(p_dims_tbl(i).rate_dim_name);
	 l_dims_tbl(i).rate_dim_sequence := p_dims_tbl(i).rate_dim_sequence;
      end loop;
   end if;

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'CREATE_SCHEDULE', 'B', 'C') then
      CN_MULTI_RATE_SCHEDULES_CUHK.CREATE_SCHEDULE_PRE
	(p_name                     => p_name,
	 p_commission_unit_code     => p_commission_unit_code,
	 p_dims_tbl                 => p_dims_tbl,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'CREATE_SCHEDULE', 'B', 'V') then
      CN_MULTI_RATE_SCHEDULES_VUHK.CREATE_SCHEDULE_PRE
	(p_name                     => p_name,
	 p_commission_unit_code     => p_commission_unit_code,
	 p_dims_tbl                 => p_dims_tbl,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   CN_MULTI_RATE_SCHEDULES_PVT.Create_Schedule
     (p_api_version                => p_api_version,
      p_init_msg_list              => p_init_msg_list,
      p_commit                     => p_commit,
      p_validation_level           => p_validation_level,
      p_name                       => p_name,
      p_commission_unit_code       => p_commission_unit_code,
      p_number_dim                 => null, -- not used
      p_dims_tbl                   => l_dims_tbl,
      -- Start - R12 MOAC Changes
      p_org_id                     => p_org_id,
      -- End  - R12 MOAC Changes
      x_rate_schedule_id           => l_rate_schedule_id,
      x_return_status              => x_return_status,
      x_msg_count                  => x_msg_count,
      x_msg_data                   => x_msg_data);

   check_ret_sts(x_return_status);

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'CREATE_SCHEDULE', 'A', 'V') then
      CN_MULTI_RATE_SCHEDULES_VUHK.CREATE_SCHEDULE_POST
	(p_name                     => p_name,
	 p_commission_unit_code     => p_commission_unit_code,
	 p_dims_tbl                 => p_dims_tbl,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'CREATE_SCHEDULE', 'A', 'C') then
      CN_MULTI_RATE_SCHEDULES_CUHK.CREATE_SCHEDULE_POST
	(p_name                     => p_name,
	 p_commission_unit_code     => p_commission_unit_code,
	 p_dims_tbl                 => p_dims_tbl,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
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
      ROLLBACK TO Create_Schedule;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Schedule;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Schedule;
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
END Create_Schedule;

PROCEDURE Update_Schedule
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_original_name              IN      CN_RATE_SCHEDULES.NAME%TYPE,
   p_new_name                   IN      CN_RATE_SCHEDULES.NAME%TYPE :=
                                        cn_api.g_miss_char,
   p_commission_unit_code       IN      CN_RATE_SCHEDULES.COMMISSION_UNIT_CODE%TYPE :=
                                        cn_api.g_miss_char,
   p_object_version_number      IN OUT NOCOPY      CN_RATE_SCHEDULES.OBJECT_VERSION_NUMBER%TYPE,
   p_dims_tbl                   IN      dim_assign_tbl_type := g_miss_dim_assign_tbl,
   -- Start - MOAC Change
   p_org_id                     IN      CN_RATE_SCHEDULES.ORG_ID%TYPE,
   -- End  - MOAC Change
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2) IS

   l_api_name                   CONSTANT VARCHAR2(30) := 'Update_Schedule';
   l_api_version                CONSTANT NUMBER       := 1.0;
   l_rate_schedule_id           CN_RATE_SCHEDULES.RATE_SCHEDULE_ID%TYPE;
   l_name                       CN_RATE_SCHEDULES.NAME%TYPE;
   l_original_comm_unit_code    CN_RATE_SCHEDULES.COMMISSION_UNIT_CODE%TYPE;
   l_comm_unit_code             CN_RATE_SCHEDULES.COMMISSION_UNIT_CODE%TYPE;
   l_dims_tbl                   CN_MULTI_RATE_SCHEDULES_PVT.dims_tbl_type;
   -- Start - MOAC Change
   l_org_id  NUMBER;
   -- End   - MOAC Change
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT    Update_Schedule;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                        p_api_version ,
                                        l_api_name    ,
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
   l_rate_schedule_id := get_rate_schedule_id(p_original_name);

   -- Start - MOAC Change
   SELECT org_id INTO l_org_id
   FROM   cn_rate_schedules
   WHERE  rate_schedule_id = l_rate_schedule_id;

   IF   (l_org_id <> p_org_id)
   THEN
        FND_MESSAGE.SET_NAME ('FND' , 'FND_MO_OU_CANNOT_UPDATE');
        IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
        THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                         'cn.plsql.cn_multi_rate_schedule_pub.update_schedule.error',
                         true);
        END IF;

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.SET_NAME ('FND' , 'FND_MO_OU_CANNOT_UPDATE');
           FND_MSG_PUB.Add;
        END IF;

    RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- End   - MOAC Change

   -- handle G_MISSES (validation for this select already performed)
   select commission_unit_code into l_original_comm_unit_code
     from cn_rate_schedules
    where rate_schedule_id = l_rate_schedule_id;

   select decode(p_new_name, cn_api.g_miss_char, p_original_name, p_new_name),
          decode(p_commission_unit_code, cn_api.g_miss_char,
		 l_original_comm_unit_code, p_commission_unit_code)
     into l_name, l_comm_unit_code from dual;

   -- get ID's in the dims_tbl to pass on to private API
   if p_dims_tbl.count > 0 then
      for i in 1..p_dims_tbl.count loop
	 l_dims_tbl(i).rate_dimension_id :=
	   get_rate_dimension_id(p_dims_tbl(i).rate_dim_name);
	 l_dims_tbl(i).rate_dim_sequence := p_dims_tbl(i).rate_dim_sequence;
      end loop;
   end if;

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'UPDATE_SCHEDULE', 'B', 'C') then
      CN_MULTI_RATE_SCHEDULES_CUHK.UPDATE_SCHEDULE_PRE
	(p_original_name            => p_original_name,
	 p_new_name                 => p_new_name,
	 p_commission_unit_code     => p_commission_unit_code,
	 p_object_version_number    => p_object_version_number,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'UPDATE_SCHEDULE', 'B', 'V') then
      CN_MULTI_RATE_SCHEDULES_VUHK.UPDATE_SCHEDULE_PRE
	(p_original_name            => p_original_name,
	 p_new_name                 => p_new_name,
	 p_commission_unit_code     => p_commission_unit_code,
	 p_object_version_number    => p_object_version_number,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   CN_MULTI_RATE_SCHEDULES_PVT.Update_Schedule
     (p_api_version                => p_api_version,
      p_init_msg_list              => p_init_msg_list,
      p_commit                     => p_commit,
      p_validation_level           => p_validation_level,
      p_rate_schedule_id           => l_rate_schedule_id,
      p_name                       => l_name,
      p_commission_unit_code       => l_comm_unit_code,
      p_number_dim                 => null, -- not used
      -- Start - R12 MOAC Changes
      p_org_id                     => p_org_id,
      -- End  - R12 MOAC Changes
      p_object_version_number      => p_object_version_number,
      p_dims_tbl                   => l_dims_tbl,
      x_return_status              => x_return_status,
      x_msg_count                  => x_msg_count,
      x_msg_data                   => x_msg_data);

   check_ret_sts(x_return_status);

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'UPDATE_SCHEDULE', 'A', 'V') then
      CN_MULTI_RATE_SCHEDULES_VUHK.UPDATE_SCHEDULE_POST
	(p_original_name            => p_original_name,
	 p_new_name                 => p_new_name,
	 p_commission_unit_code     => p_commission_unit_code,
	 p_object_version_number    => p_object_version_number,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'UPDATE_SCHEDULE', 'A', 'C') then
      CN_MULTI_RATE_SCHEDULES_CUHK.UPDATE_SCHEDULE_POST
	(p_original_name            => p_original_name,
	 p_new_name                 => p_new_name,
	 p_commission_unit_code     => p_commission_unit_code,
	 p_object_version_number    => p_object_version_number,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.count_and_get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              ,
      p_encoded               =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Update_Schedule;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Schedule;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Schedule;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.check_msg_level
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
END Update_Schedule;


PROCEDURE Delete_Schedule
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_name                       IN      CN_RATE_SCHEDULES.NAME%TYPE,
   -- Start - R12 MOAC Changes
   p_object_version_number      IN      CN_RATE_SCHEDULES.OBJECT_VERSION_NUMBER%TYPE, -- new
   -- End  - R12 MOAC Changes
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2) IS

   l_rate_schedule_id      CN_RATE_SCHEDULES.RATE_SCHEDULE_ID%TYPE := 0;
   l_api_name              CONSTANT VARCHAR2(30) := 'Delete_Schedule';
   l_api_version           CONSTANT NUMBER       := 1.0;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Delete_Schedule;
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

   -- validate ID
   l_rate_schedule_id := get_rate_schedule_id(p_name);

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'DELETE_SCHEDULE', 'B', 'C') then
      CN_MULTI_RATE_SCHEDULES_CUHK.DELETE_SCHEDULE_PRE
	(p_name                     => p_name,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'DELETE_SCHEDULE', 'B', 'V') then
      CN_MULTI_RATE_SCHEDULES_VUHK.DELETE_SCHEDULE_PRE
	(p_name                     => p_name,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   CN_MULTI_RATE_SCHEDULES_PVT.Delete_Schedule
     (p_api_version                => p_api_version,
      p_init_msg_list              => p_init_msg_list,
      p_commit                     => p_commit,
      p_validation_level           => p_validation_level,
      p_rate_schedule_id           => l_rate_schedule_id,
      -- Start - R12 MOAC Changes
      p_object_version_number      => p_object_version_number,
      -- End  - R12 MOAC Changes
      x_return_status              => x_return_status,
      x_msg_count                  => x_msg_count,
      x_msg_data                   => x_msg_data);

   check_ret_sts(x_return_status);

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'DELETE_SCHEDULE', 'A', 'V') then
      CN_MULTI_RATE_SCHEDULES_VUHK.DELETE_SCHEDULE_POST
	(p_name                     => p_name,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'DELETE_SCHEDULE', 'A', 'C') then
      CN_MULTI_RATE_SCHEDULES_CUHK.DELETE_SCHEDULE_POST
	(p_name                     => p_name,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.count_and_get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              ,
      p_encoded               =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Delete_Schedule;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_Schedule;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_Schedule;
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
END Delete_Schedule;

PROCEDURE Create_Dimension_Assign
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_rate_schedule_name         IN      CN_RATE_SCHEDULES.NAME%TYPE,
   p_rate_dimension_name        IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   p_rate_dim_sequence          IN      CN_RATE_SCH_DIMS.RATE_DIM_SEQUENCE%TYPE,
   -- Start - MOAC Change
   p_org_id                     IN      CN_RATE_DIMENSIONS.ORG_ID%TYPE := NULL,
   -- End  - MOAC Change
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2) IS

   l_api_name                CONSTANT VARCHAR2(30) := 'Create_Dimension_Assign';
   l_api_version             CONSTANT NUMBER       := 1.0;
   l_rate_schedule_id        CN_RATE_SCHEDULES.RATE_SCHEDULE_ID%TYPE;
   l_rate_dimension_id       CN_RATE_DIMENSIONS.RATE_DIMENSION_ID%TYPE;
   l_rate_sch_dim_id         CN_RATE_SCH_DIMS.RATE_SCH_DIM_ID%TYPE;
   -- Start - MOAC Change
   l_org_id  NUMBER;
   l_status  VARCHAR2(1);
   -- End   - MOAC Change

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Create_Dimension_Assign;
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

   -- Start - R12 MOAC Changes
   l_org_id := p_org_id;
   mo_global.validate_orgid_pub_api(org_id => l_org_id,
                                    status => l_status);
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'cn.plsql.cn_multi_rate_schedules_pub.create_dimension_assign.org_validate',
                     'Validated org_id = ' || l_org_id || ' status = '||l_status);
   end if;
   -- End - R12 MOAC Changes

   -- look up ID's
   l_rate_schedule_id  := get_rate_schedule_id (p_rate_schedule_name);
   l_rate_dimension_id := get_rate_dimension_id(p_rate_dimension_name);

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'CREATE_DIMENSION_ASSIGN', 'B', 'C') then
      CN_MULTI_RATE_SCHEDULES_CUHK.CREATE_DIMENSION_ASSIGN_PRE
	(p_rate_schedule_name       => p_rate_schedule_name,
	 p_rate_dimension_name      => p_rate_dimension_name,
	 p_rate_dim_sequence        => p_rate_dim_sequence,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'CREATE_DIMENSION_ASSIGN', 'B', 'V') then
      CN_MULTI_RATE_SCHEDULES_VUHK.CREATE_DIMENSION_ASSIGN_PRE
	(p_rate_schedule_name       => p_rate_schedule_name,
	 p_rate_dimension_name      => p_rate_dimension_name,
	 p_rate_dim_sequence        => p_rate_dim_sequence,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   CN_MULTI_RATE_SCHEDULES_PVT.create_dimension_assign
     (p_api_version                => p_api_version,
      p_init_msg_list              => p_init_msg_list,
      p_commit                     => p_commit,
      p_validation_level           => p_validation_level,
      p_rate_schedule_id           => l_rate_schedule_id,
      p_rate_dimension_id          => l_rate_dimension_id,
      p_rate_dim_sequence          => p_rate_dim_sequence,
      -- Start - R12 MOAC Changes
      p_org_id                     => p_org_id,
      -- End  - R12 MOAC Changes
      x_rate_sch_dim_id            => l_rate_sch_dim_id,
      x_return_status              => x_return_status,
      x_msg_count                  => x_msg_count,
      x_msg_data                   => x_msg_data);

   check_ret_sts(x_return_status);

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'CREATE_DIMENSION_ASSIGN', 'A', 'V') then
      CN_MULTI_RATE_SCHEDULES_VUHK.CREATE_DIMENSION_ASSIGN_POST
	(p_rate_schedule_name       => p_rate_schedule_name,
	 p_rate_dimension_name      => p_rate_dimension_name,
	 p_rate_dim_sequence        => p_rate_dim_sequence,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'CREATE_DIMENSION_ASSIGN', 'A', 'C') then
      CN_MULTI_RATE_SCHEDULES_CUHK.CREATE_DIMENSION_ASSIGN_POST
	(p_rate_schedule_name       => p_rate_schedule_name,
	 p_rate_dimension_name      => p_rate_dimension_name,
	 p_rate_dim_sequence        => p_rate_dim_sequence,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
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
      ROLLBACK TO Create_Dimension_Assign;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Dimension_Assign;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Dimension_Assign;
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
END Create_Dimension_Assign;


PROCEDURE Update_Dimension_Assign
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_rate_schedule_name         IN      CN_RATE_SCHEDULES.NAME%TYPE,
   p_orig_rate_dim_name         IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   p_new_rate_dim_name          IN      CN_RATE_DIMENSIONS.NAME%TYPE := cn_api.g_miss_char,
   p_rate_dim_sequence          IN      CN_RATE_SCH_DIMS.RATE_DIM_SEQUENCE%TYPE :=
                                        cn_api.g_miss_num,
   p_object_version_number      IN OUT NOCOPY     CN_RATE_SCH_DIMS.OBJECT_VERSION_NUMBER%TYPE,
   -- Start - MOAC Change
   p_org_id                     IN      CN_RATE_DIMENSIONS.ORG_ID%TYPE,
   -- End  - MOAC Change
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2) IS

   l_api_name                 CONSTANT VARCHAR2(30) := 'Update_Dimension_Assign';
   l_api_version              CONSTANT NUMBER       := 1.0;
   l_rate_schedule_id         CN_RATE_SCHEDULES.RATE_SCHEDULE_ID%TYPE;
   l_rate_dimension_id        CN_RATE_DIMENSIONS.RATE_DIMENSION_ID%TYPE;
   l_rate_dim_sequence        CN_RATE_SCH_DIMS.RATE_DIM_SEQUENCE%TYPE;
   l_rate_sch_dim_id          CN_RATE_SCH_DIMS.RATE_SCH_DIM_ID%TYPE;
   -- Start - MOAC Change
   l_org_id  NUMBER;
   -- End   - MOAC Change
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Update_Dimension_Assign;
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

   -- get ID's
   l_rate_schedule_id  := get_rate_schedule_id (p_rate_schedule_name);
   l_rate_dimension_id := get_rate_dimension_id(p_orig_rate_dim_name);
   l_rate_sch_dim_id   := get_rate_sch_dim_id  (l_rate_schedule_id, l_rate_dimension_id);

    -- Start - MOAC Change
   SELECT org_id INTO l_org_id
   FROM   cn_rate_sch_dims
   WHERE  rate_sch_dim_id = l_rate_sch_dim_id;

   IF   (l_org_id <> p_org_id)
   THEN
        FND_MESSAGE.SET_NAME ('FND' , 'FND_MO_OU_CANNOT_UPDATE');
        IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
        THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                         'cn.plsql.cn_multi_rate_schedule_pub.update_dimension_assign.error',
                         true);
        END IF;

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.SET_NAME ('FND' , 'FND_MO_OU_CANNOT_UPDATE');
           FND_MSG_PUB.Add;
        END IF;

    RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- End   - MOAC Change
   -- get rate_dim_sequence (validation for this select already performed)
   select rate_dim_sequence into l_rate_dim_sequence
     from cn_rate_sch_dims
    where rate_sch_dim_id = l_rate_sch_dim_id;

   -- get new rate dim name if necessary
   if p_new_rate_dim_name <> cn_api.g_miss_char then
      l_rate_dimension_id := get_rate_dimension_id(p_new_rate_dim_name);
   end if;

   if p_rate_dim_sequence <> cn_api.g_miss_num then
      l_rate_dim_sequence := p_rate_dim_sequence;
   end if;

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'UPDATE_DIMENSION_ASSIGN', 'B', 'C') then
      CN_MULTI_RATE_SCHEDULES_CUHK.UPDATE_DIMENSION_ASSIGN_PRE
	(p_rate_schedule_name       => p_rate_schedule_name,
	 p_orig_rate_dim_name       => p_orig_rate_dim_name,
	 p_new_rate_dim_name        => p_new_rate_dim_name,
	 p_rate_dim_sequence        => p_rate_dim_sequence,
	 p_object_version_number    => p_object_version_number,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'UPDATE_DIMENSION_ASSIGN', 'B', 'V') then
      CN_MULTI_RATE_SCHEDULES_VUHK.UPDATE_DIMENSION_ASSIGN_PRE
	(p_rate_schedule_name       => p_rate_schedule_name,
	 p_orig_rate_dim_name       => p_orig_rate_dim_name,
	 p_new_rate_dim_name        => p_new_rate_dim_name,
	 p_rate_dim_sequence        => p_rate_dim_sequence,
	 p_object_version_number    => p_object_version_number,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   CN_MULTI_RATE_SCHEDULES_PVT.update_dimension_assign
     (p_api_version                => p_api_version,
      p_init_msg_list              => p_init_msg_list,
      p_commit                     => p_commit,
      p_validation_level           => p_validation_level,
      p_rate_sch_dim_id            => l_rate_sch_dim_id,
      p_rate_schedule_id           => l_rate_schedule_id,
      p_rate_dimension_id          => l_rate_dimension_id,
      p_rate_dim_sequence          => l_rate_dim_sequence,
      -- Start - MOAC Change
      p_org_id                     => p_org_id,
      -- End  - MOAC Change
      p_object_version_number      => p_object_version_number,
      x_return_status              => x_return_status,
      x_msg_count                  => x_msg_count,
      x_msg_data                   => x_msg_data);

   check_ret_sts(x_return_status);

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'UPDATE_DIMENSION_ASSIGN', 'A', 'V') then
      CN_MULTI_RATE_SCHEDULES_VUHK.UPDATE_DIMENSION_ASSIGN_POST
	(p_rate_schedule_name       => p_rate_schedule_name,
	 p_orig_rate_dim_name       => p_orig_rate_dim_name,
	 p_new_rate_dim_name        => p_new_rate_dim_name,
	 p_rate_dim_sequence        => p_rate_dim_sequence,
	 p_object_version_number    => p_object_version_number,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'UPDATE_DIMENSION_ASSIGN', 'A', 'C') then
      CN_MULTI_RATE_SCHEDULES_CUHK.UPDATE_DIMENSION_ASSIGN_POST
	(p_rate_schedule_name       => p_rate_schedule_name,
	 p_orig_rate_dim_name       => p_orig_rate_dim_name,
	 p_new_rate_dim_name        => p_new_rate_dim_name,
	 p_rate_dim_sequence        => p_rate_dim_sequence,
	 p_object_version_number    => p_object_version_number,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
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
      ROLLBACK TO Update_Dimension_Assign;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Dimension_Assign;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Dimension_Assign;
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
END Update_Dimension_Assign;

PROCEDURE Delete_Dimension_Assign
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_rate_schedule_name         IN      CN_RATE_SCHEDULES.NAME%TYPE,
   p_rate_dimension_name        IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   -- Start - R12 MOAC Changes
   p_object_version_number      IN      CN_RATE_DIMENSIONS.OBJECT_VERSION_NUMBER%TYPE, -- new
   -- End  - R12 MOAC Changes
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2) IS

   l_api_name                 CONSTANT VARCHAR2(30) := 'Delete_Dimension_Assign';
   l_api_version              CONSTANT NUMBER       := 1.0;
   l_rate_schedule_id         CN_RATE_SCHEDULES.RATE_SCHEDULE_ID%TYPE;
   l_rate_dimension_id        CN_RATE_DIMENSIONS.RATE_DIMENSION_ID%TYPE;
   l_rate_sch_dim_id          CN_RATE_SCH_DIMS.RATE_SCH_DIM_ID%TYPE;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Delete_Dimension_Assign;
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

   l_rate_schedule_id  := get_rate_schedule_id (p_rate_schedule_name);
   l_rate_dimension_id := get_rate_dimension_id(p_rate_dimension_name);
   l_rate_sch_dim_id   := get_rate_sch_dim_id  (l_rate_schedule_id, l_rate_dimension_id);

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'DELETE_DIMENSION_ASSIGN', 'B', 'C') then
      CN_MULTI_RATE_SCHEDULES_CUHK.DELETE_DIMENSION_ASSIGN_PRE
	(p_rate_schedule_name       => p_rate_schedule_name,
	 p_rate_dimension_name      => p_rate_dimension_name,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'DELETE_DIMENSION_ASSIGN', 'B', 'V') then
      CN_MULTI_RATE_SCHEDULES_VUHK.DELETE_DIMENSION_ASSIGN_PRE
	(p_rate_schedule_name       => p_rate_schedule_name,
	 p_rate_dimension_name      => p_rate_dimension_name,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   CN_MULTI_RATE_SCHEDULES_PVT.delete_dimension_assign
     (p_api_version                => p_api_version,
      p_init_msg_list              => p_init_msg_list,
      p_commit                     => p_commit,
      p_validation_level           => p_validation_level,
      p_rate_sch_dim_id            => l_rate_sch_dim_id,
      p_rate_schedule_id           => l_rate_schedule_id,
      -- Start - R12 MOAC Changes
      p_object_version_number      => p_object_version_number,
      -- End  - R12 MOAC Changes
      x_return_status              => x_return_status,
      x_msg_count                  => x_msg_count,
      x_msg_data                   => x_msg_data);

   check_ret_sts(x_return_status);

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'DELETE_DIMENSION_ASSIGN', 'A', 'V') then
      CN_MULTI_RATE_SCHEDULES_VUHK.DELETE_DIMENSION_ASSIGN_POST
	(p_rate_schedule_name       => p_rate_schedule_name,
	 p_rate_dimension_name      => p_rate_dimension_name,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'DELETE_DIMENSION_ASSIGN', 'A', 'C') then
      CN_MULTI_RATE_SCHEDULES_CUHK.DELETE_DIMENSION_ASSIGN_POST
	(p_rate_schedule_name       => p_rate_schedule_name,
	 p_rate_dimension_name      => p_rate_dimension_name,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
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
      ROLLBACK TO Delete_Dimension_Assign;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_Dimension_Assign;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_Dimension_Assign;
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
END Delete_Dimension_Assign;

PROCEDURE Update_Rate
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_rate_schedule_name         IN      CN_RATE_SCHEDULES.NAME%TYPE,
   p_tier_coordinates_tbl       IN      tier_coordinates_tbl,
   p_commission_amount          IN      CN_RATE_TIERS.COMMISSION_AMOUNT%TYPE,
   p_object_version_number      IN OUT NOCOPY     CN_RATE_TIERS.OBJECT_VERSION_NUMBER%TYPE,
   -- Start - MOAC Change
   p_org_id                     IN      CN_RATE_TIERS.ORG_ID%TYPE,
   -- End  - MOAC Change
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2) IS

   l_api_name                 CONSTANT VARCHAR2(30) := 'Update_Rate';
   l_api_version              CONSTANT NUMBER       := 1.0;
   l_rate_schedule_id         CN_RATE_SCHEDULES.RATE_SCHEDULE_ID%TYPE;
   l_rate_tier_id             CN_RATE_TIERS.RATE_TIER_ID%TYPE;
   l_rate_sequence            CN_RATE_DIM_TIERS.TIER_SEQUENCE%TYPE;
   l_commission_amount        CN_RATE_TIERS.COMMISSION_AMOUNT%TYPE;
   l_object_version_number    CN_RATE_TIERS.OBJECT_VERSION_NUMBER%TYPE;
   l_rate_dim_tier_id_tbl     CN_MULTI_RATE_SCHEDULES_PVT.num_tbl_type;
   -- Start - MOAC Change
   l_org_id  NUMBER;
   -- End   - MOAC Change

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Update_Rate;
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

   l_rate_schedule_id := get_rate_schedule_id(p_rate_schedule_name);

   -- Start - MOAC Change
   SELECT org_id INTO l_org_id
   FROM   cn_rate_schedules
   WHERE  rate_schedule_id = l_rate_schedule_id;

   IF   (l_org_id <> p_org_id)
   THEN
        FND_MESSAGE.SET_NAME ('FND' , 'FND_MO_OU_CANNOT_UPDATE');
        IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
        THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                         'cn.plsql.cn_multi_rate_schedule_pub.update_rate.error',
                         true);
        END IF;

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.SET_NAME ('FND' , 'FND_MO_OU_CANNOT_UPDATE');
           FND_MSG_PUB.Add;
        END IF;

    RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- End   - MOAC Change

   for i in p_tier_coordinates_tbl.first..p_tier_coordinates_tbl.last loop
      l_rate_dim_tier_id_tbl(i) := get_rate_dim_tier_id
	(l_rate_schedule_id, i, p_tier_coordinates_tbl(i));
   end loop;

   CN_MULTI_RATE_SCHEDULES_PVT.get_rate_tier_info
     (p_rate_schedule_id           => l_rate_schedule_id,
      p_rate_dim_tier_id_tbl       => l_rate_dim_tier_id_tbl,
      x_rate_tier_id               => l_rate_tier_id,
      x_rate_sequence              => l_rate_sequence,
      x_commission_amount          => l_commission_amount,      -- not used
      x_object_version_number      => l_object_version_number); -- not used

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'UPDATE_RATE', 'B', 'C') then
      CN_MULTI_RATE_SCHEDULES_CUHK.UPDATE_RATE_PRE
	(p_rate_schedule_name       => p_rate_schedule_name,
	 p_tier_coordinates_tbl     => p_tier_coordinates_tbl,
	 p_commission_amount        => p_commission_amount,
	 p_object_version_number    => p_object_version_number,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'UPDATE_RATE', 'B', 'V') then
      CN_MULTI_RATE_SCHEDULES_VUHK.UPDATE_RATE_PRE
	(p_rate_schedule_name       => p_rate_schedule_name,
	 p_tier_coordinates_tbl     => p_tier_coordinates_tbl,
	 p_commission_amount        => p_commission_amount,
	 p_object_version_number    => p_object_version_number,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   CN_MULTI_RATE_SCHEDULES_PVT.update_rate
     (p_rate_schedule_id           => l_rate_schedule_id,
      p_rate_sequence              => l_rate_sequence,
      p_commission_amount          => p_commission_amount,
      p_object_version_number      => p_object_version_number,
      -- Start - MOAC Change
      p_org_id                     => p_org_id);
      -- End  - MOAC Change


   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'UPDATE_RATE', 'A', 'V') then
      CN_MULTI_RATE_SCHEDULES_VUHK.UPDATE_RATE_POST
	(p_rate_schedule_name       => p_rate_schedule_name,
	 p_tier_coordinates_tbl     => p_tier_coordinates_tbl,
	 p_commission_amount        => p_commission_amount,
	 p_object_version_number    => p_object_version_number,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'UPDATE_RATE', 'A', 'C') then
      CN_MULTI_RATE_SCHEDULES_CUHK.UPDATE_RATE_POST
	(p_rate_schedule_name       => p_rate_schedule_name,
	 p_tier_coordinates_tbl     => p_tier_coordinates_tbl,
	 p_commission_amount        => p_commission_amount,
	 p_object_version_number    => p_object_version_number,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
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
      ROLLBACK TO Update_Rate;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Rate;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Rate;
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
END Update_Rate;

PROCEDURE Create_Dimension
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_name                       IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   p_description                IN      CN_RATE_DIMENSIONS.DESCRIPTION%TYPE := NULL,
   p_dim_unit_code              IN      CN_RATE_DIMENSIONS.DIM_UNIT_CODE%TYPE,
   p_tiers_tbl                  IN      rate_tier_tbl_type := g_miss_rate_tier_tbl,
   -- Start - MOAC Change
   p_org_id                     IN      CN_RATE_DIMENSIONS.ORG_ID%TYPE := NULL,
   -- End  - MOAC Change
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2) IS

   l_api_name                 CONSTANT VARCHAR2(30) := 'Create_Dimension';
   l_api_version              CONSTANT NUMBER       := 1.0;
   l_rate_dimension_id        CN_RATE_DIMENSIONS.RATE_DIMENSION_ID%TYPE;
   l_tiers_tbl                CN_RATE_DIMENSIONS_PVT.TIERS_TBL_TYPE;
   -- Start - MOAC Change
   l_org_id  NUMBER;
   l_status  VARCHAR2(1);
   -- End   - MOAC Change

BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT   Create_Dimension;
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

   -- Start - R12 MOAC Changes
   l_org_id := p_org_id;
   mo_global.validate_orgid_pub_api(org_id => l_org_id,
                                    status => l_status);
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'cn.plsql.cn_multi_rate_schedules_pub.create_dimension.org_validate',
                     'Validated org_id = ' || l_org_id || ' status = '||l_status);
   end if;
   -- End - R12 MOAC Changes

   -- build l_tiers_tbl from the p_tiers_tbl
   if p_tiers_tbl.count > 0 then
      for i in p_tiers_tbl.first..p_tiers_tbl.last loop
	 l_tiers_tbl(i).tier_sequence := p_tiers_tbl(i).tier_sequence;
	 translate_values(p_dim_unit_code, p_tiers_tbl(i).value1, p_tiers_tbl(i).value2,
			  l_tiers_tbl(i).minimum_amount, l_tiers_tbl(i).maximum_amount,
			  l_tiers_tbl(i).min_exp_id, l_tiers_tbl(i).max_exp_id,
			  l_tiers_tbl(i).string_value);
      end loop;
   end if;

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'CREATE_DIMENSION', 'B', 'C') then
      CN_MULTI_RATE_SCHEDULES_CUHK.CREATE_DIMENSION_PRE
	(p_name                     => p_name,
	 p_description              => p_description,
	 p_dim_unit_code            => p_dim_unit_code,
	 p_tiers_tbl                => p_tiers_tbl,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'CREATE_DIMENSION', 'B', 'V') then
      CN_MULTI_RATE_SCHEDULES_VUHK.CREATE_DIMENSION_PRE
	(p_name                     => p_name,
	 p_description              => p_description,
	 p_dim_unit_code            => p_dim_unit_code,
	 p_tiers_tbl                => p_tiers_tbl,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   CN_RATE_DIMENSIONS_PVT.Create_Dimension
     (p_api_version                => p_api_version,
      p_init_msg_list              => p_init_msg_list,
      p_commit                     => p_commit,
      p_validation_level           => p_validation_level,
      p_name                       => p_name,
      p_description                => p_description,
      p_dim_unit_code              => p_dim_unit_code,
      p_number_tier                => l_tiers_tbl.count,
      p_tiers_tbl                  => l_tiers_tbl,
      -- Start - MOAC Change
      p_org_id                     => p_org_id,
      -- End  - MOAC Change
      x_rate_dimension_id          => l_rate_dimension_id,
      x_return_status              => x_return_status,
      x_msg_count                  => x_msg_count,
      x_msg_data                   => x_msg_data);

   check_ret_sts(x_return_status);

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'CREATE_DIMENSION', 'A', 'V') then
      CN_MULTI_RATE_SCHEDULES_VUHK.CREATE_DIMENSION_POST
	(p_name                     => p_name,
	 p_description              => p_description,
	 p_dim_unit_code            => p_dim_unit_code,
	 p_tiers_tbl                => p_tiers_tbl,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'CREATE_DIMENSION', 'A', 'C') then
      CN_MULTI_RATE_SCHEDULES_CUHK.CREATE_DIMENSION_POST
	(p_name                     => p_name,
	 p_description              => p_description,
	 p_dim_unit_code            => p_dim_unit_code,
	 p_tiers_tbl                => p_tiers_tbl,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
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
      ROLLBACK TO Create_Dimension;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Dimension;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Dimension;
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
END Create_Dimension;

PROCEDURE Update_Dimension
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_original_name              IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   p_new_name                   IN      CN_RATE_DIMENSIONS.NAME%TYPE :=
                                        cn_api.g_miss_char,
   p_description                IN      CN_RATE_DIMENSIONS.DESCRIPTION%TYPE :=
                                        cn_api.g_miss_char,
   p_dim_unit_code              IN      CN_RATE_DIMENSIONS.DIM_UNIT_CODE%TYPE :=
                                        cn_api.g_miss_char,
   p_tiers_tbl                  IN      rate_tier_tbl_type :=
                                        g_miss_rate_tier_tbl,
   p_object_version_number      IN OUT NOCOPY     CN_RATE_DIMENSIONS.OBJECT_VERSION_NUMBER%TYPE,
   -- Start - MOAC Change
   p_org_id                     IN      CN_RATE_DIMENSIONS.ORG_ID%TYPE,
   -- End  - MOAC Change
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2) IS

   l_api_name                 CONSTANT VARCHAR2(30) := 'Update_Dimension';
   l_api_version              CONSTANT NUMBER       := 1.0;
   l_rate_dimension_id        CN_RATE_DIMENSIONS.RATE_DIMENSION_ID%TYPE;
   l_description              CN_RATE_DIMENSIONS.DESCRIPTION%TYPE;
   l_name                     CN_RATE_DIMENSIONS.NAME%TYPE;
   l_tiers_tbl                CN_RATE_DIMENSIONS_PVT.TIERS_TBL_TYPE;
   -- Start - MOAC Change
   l_org_id  NUMBER;
   -- End   - MOAC Change

   CURSOR get_rdt_id(p_rate_dimension_id IN CN_RATE_DIM_TIERS.RATE_DIMENSION_ID%TYPE,
		     p_tier_sequence     IN CN_RATE_DIM_TIERS.TIER_SEQUENCE%TYPE) IS
   select rate_dim_tier_id from cn_rate_dim_tiers
    where rate_dimension_id = p_rate_dimension_id
      and tier_sequence     = p_tier_sequence;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Update_Dimension;
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

   l_rate_dimension_id := get_rate_dimension_id(p_original_name);

   -- Start - MOAC Change
   SELECT org_id INTO l_org_id
   FROM   cn_rate_dimensions
   WHERE  rate_dimension_id = l_rate_dimension_id;

   IF   (l_org_id <> p_org_id)
   THEN
        FND_MESSAGE.SET_NAME ('FND' , 'FND_MO_OU_CANNOT_UPDATE');
        IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
        THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                         'cn.plsql.cn_multi_rate_schedule_pub.update_dimenstion.error',
                         true);
        END IF;

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.SET_NAME ('FND' , 'FND_MO_OU_CANNOT_UPDATE');
           FND_MSG_PUB.Add;
        END IF;

    RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- End   - MOAC Change

   select description into l_description from cn_rate_dimensions
    where rate_dimension_id = l_rate_dimension_id;

   select decode(p_new_name, cn_api.g_miss_char, p_original_name, p_new_name),
          decode(p_description, cn_api.g_miss_char, l_description, p_description)
     into l_name, l_description from dual;

   -- build l_tiers_tbl from the p_tiers_tbl
   if p_tiers_tbl.count > 0 then
      for i in p_tiers_tbl.first..p_tiers_tbl.last loop
	 l_tiers_tbl(i).tier_sequence    := p_tiers_tbl(i).tier_sequence;
	 open  get_rdt_id(l_rate_dimension_id, p_tiers_tbl(i).tier_sequence);
	 fetch get_rdt_id into l_tiers_tbl(i).rate_dim_tier_id;
	 close get_rdt_id; -- if ID not found, then row is to be newly created

	 translate_values(p_dim_unit_code, p_tiers_tbl(i).value1, p_tiers_tbl(i).value2,
			  l_tiers_tbl(i).minimum_amount, l_tiers_tbl(i).maximum_amount,
			  l_tiers_tbl(i).min_exp_id, l_tiers_tbl(i).max_exp_id,
			  l_tiers_tbl(i).string_value);
	 l_tiers_tbl(i).object_version_number := p_tiers_tbl(i).object_version_number;
      end loop;
   end if;

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'UPDATE_DIMENSION', 'B', 'C') then
      CN_MULTI_RATE_SCHEDULES_CUHK.UPDATE_DIMENSION_PRE
	(p_original_name            => p_original_name,
	 p_new_name                 => p_new_name,
	 p_description              => p_description,
	 p_dim_unit_code            => p_dim_unit_code,
	 p_tiers_tbl                => p_tiers_tbl,
	 p_object_version_number    => p_object_version_number,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'UPDATE_DIMENSION', 'B', 'V') then
      CN_MULTI_RATE_SCHEDULES_VUHK.UPDATE_DIMENSION_PRE
	(p_original_name            => p_original_name,
	 p_new_name                 => p_new_name,
	 p_description              => p_description,
	 p_dim_unit_code            => p_dim_unit_code,
	 p_tiers_tbl                => p_tiers_tbl,
	 p_object_version_number    => p_object_version_number,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   CN_RATE_DIMENSIONS_PVT.Update_Dimension
     (p_api_version                => p_api_version,
      p_init_msg_list              => p_init_msg_list,
      p_commit                     => p_commit,
      p_validation_level           => p_validation_level,
      p_rate_dimension_id          => l_rate_dimension_id,
      p_name                       => l_name,
      p_description                => l_description,
      p_dim_unit_code              => p_dim_unit_code,
      p_number_tier                => l_tiers_tbl.count,
      p_tiers_tbl                  => l_tiers_tbl,
      -- Start - MOAC Change
      p_org_id                     => p_org_id,
      -- End  - MOAC Change
      p_object_version_number      => p_object_version_number,
      x_return_status              => x_return_status,
      x_msg_count                  => x_msg_count,
      x_msg_data                   => x_msg_data);

   check_ret_sts(x_return_status);

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'UPDATE_DIMENSION', 'A', 'V') then
      CN_MULTI_RATE_SCHEDULES_VUHK.UPDATE_DIMENSION_POST
	(p_original_name            => p_original_name,
	 p_new_name                 => p_new_name,
	 p_description              => p_description,
	 p_dim_unit_code            => p_dim_unit_code,
	 p_tiers_tbl                => p_tiers_tbl,
	 p_object_version_number    => p_object_version_number,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'UPDATE_DIMENSION', 'A', 'C') then
      CN_MULTI_RATE_SCHEDULES_CUHK.UPDATE_DIMENSION_POST
	(p_original_name            => p_original_name,
	 p_new_name                 => p_new_name,
	 p_description              => p_description,
	 p_dim_unit_code            => p_dim_unit_code,
	 p_tiers_tbl                => p_tiers_tbl,
	 p_object_version_number    => p_object_version_number,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.count_and_get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              ,
      p_encoded               =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Update_Dimension;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Dimension;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Dimension;
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
END Update_Dimension;

PROCEDURE Delete_Dimension
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_name                       IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   -- Start - R12 MOAC Changes
   p_object_version_number      IN      CN_RATE_DIMENSIONS.OBJECT_VERSION_NUMBER%TYPE, -- new
   -- End  - R12 MOAC Changes
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2) IS

   l_api_name                  CONSTANT VARCHAR2(30) := 'Delete_Dimension';
   l_api_version               CONSTANT NUMBER       := 1.0;
   l_rate_dimension_id         CN_RATE_DIMENSIONS.RATE_DIMENSION_ID%TYPE;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Delete_Dimension;
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

   l_rate_dimension_id := get_rate_dimension_id(p_name);

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'DELETE_DIMENSION', 'B', 'C') then
      CN_MULTI_RATE_SCHEDULES_CUHK.DELETE_DIMENSION_PRE
	(p_name                     => p_name,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'DELETE_DIMENSION', 'B', 'V') then
      CN_MULTI_RATE_SCHEDULES_VUHK.DELETE_DIMENSION_PRE
	(p_name                     => p_name,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   CN_RATE_DIMENSIONS_PVT.Delete_Dimension
     (p_api_version                => p_api_version,
      p_init_msg_list              => p_init_msg_list,
      p_commit                     => p_commit,
      p_validation_level           => p_validation_level,
      p_rate_dimension_id          => l_rate_dimension_id,
      -- Start - MOAC Change
      p_object_version_number      => p_object_version_number,
      -- End  - MOAC Change
      x_return_status              => x_return_status,
      x_msg_count                  => x_msg_count,
      x_msg_data                   => x_msg_data);

   check_ret_sts(x_return_status);

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'DELETE_DIMENSION', 'A', 'V') then
      CN_MULTI_RATE_SCHEDULES_VUHK.DELETE_DIMENSION_POST
	(p_name                     => p_name,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'DELETE_DIMENSION', 'A', 'C') then
      CN_MULTI_RATE_SCHEDULES_CUHK.DELETE_DIMENSION_POST
	(p_name                     => p_name,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.count_and_get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              ,
      p_encoded               =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Delete_Dimension;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_Dimension;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_Dimension;
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
END Delete_Dimension;

PROCEDURE Create_Tier
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_dimension_name             IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   p_value1                     IN      VARCHAR2,
   p_value2                     IN      VARCHAR2,
   p_tier_sequence              IN      CN_RATE_DIM_TIERS.TIER_SEQUENCE%TYPE,
   -- Start - MOAC Change
   p_org_id                     IN      CN_RATE_TIERS.ORG_ID%TYPE := NULL,
   -- End  - MOAC Change
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2) IS

   l_api_name                CONSTANT VARCHAR2(30) := 'Create_Tier';
   l_api_version             CONSTANT NUMBER       := 1.0;
   l_rate_dimension_id       CN_RATE_DIMENSIONS.RATE_DIMENSION_ID%TYPE;
   l_rate_dim_tier_id        CN_RATE_DIM_TIERS.RATE_DIM_TIER_ID%TYPE;
   l_dim_unit_code           CN_RATE_DIMENSIONS.DIM_UNIT_CODE%TYPE;
   l_minimum_amount          CN_RATE_DIM_TIERS.MINIMUM_AMOUNT%TYPE;
   l_maximum_amount          CN_RATE_DIM_TIERS.MAXIMUM_AMOUNT%TYPE;
   l_min_exp_id              CN_RATE_DIM_TIERS.MIN_EXP_ID%TYPE;
   l_max_exp_id              CN_RATE_DIM_TIERS.MAX_EXP_ID%TYPE;
   l_string_value            CN_RATE_DIM_TIERS.STRING_VALUE%TYPE;
   -- Start - MOAC Change
   l_org_id  NUMBER;
   l_status  VARCHAR2(1);
   -- End   - MOAC Change

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Create_tier;
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

   -- Start - R12 MOAC Changes
   l_org_id := p_org_id;
   mo_global.validate_orgid_pub_api(org_id => l_org_id,
                                    status => l_status);
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'cn.plsql.cn_multi_rate_schedules_pub.create_tier.org_validate',
                     'Validated org_id = ' || l_org_id || ' status = '||l_status);
   end if;
   -- End - R12 MOAC Changes

   l_rate_dimension_id := get_rate_dimension_id(p_dimension_name);

   -- get dim_unit_code from the dimension
   select dim_unit_code into l_dim_unit_code from cn_rate_dimensions
    where rate_dimension_id = l_rate_dimension_id;

   translate_values(l_dim_unit_code, p_value1, p_value2, l_minimum_amount, l_maximum_amount,
		    l_min_exp_id, l_max_exp_id, l_string_value);

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'CREATE_TIER', 'B', 'C') then
      CN_MULTI_RATE_SCHEDULES_CUHK.CREATE_TIER_PRE
	(p_dimension_name           => p_dimension_name,
	 p_value1                   => p_value1,
	 p_value2                   => p_value2,
	 p_tier_sequence            => p_tier_sequence,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'CREATE_TIER', 'B', 'V') then
      CN_MULTI_RATE_SCHEDULES_VUHK.CREATE_TIER_PRE
	(p_dimension_name           => p_dimension_name,
	 p_value1                   => p_value1,
	 p_value2                   => p_value2,
	 p_tier_sequence            => p_tier_sequence,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   CN_RATE_DIMENSIONS_PVT.create_tier
     (p_api_version                => p_api_version,
      p_init_msg_list              => p_init_msg_list,
      p_commit                     => p_commit,
      p_validation_level           => p_validation_level,
      p_rate_dimension_id          => l_rate_dimension_id,
      p_dim_unit_code              => l_dim_unit_code,
      p_minimum_amount             => l_minimum_amount,
      p_maximum_amount             => l_maximum_amount,
      p_min_exp_id                 => l_min_exp_id,
      p_max_exp_id                 => l_max_exp_id,
      p_string_value               => l_string_value,
      p_tier_sequence              => p_tier_sequence,
      -- Start - MOAC Change
      p_org_id                     => p_org_id,
      -- End  - MOAC Change
      x_rate_dim_tier_id           => l_rate_dim_tier_id,
      x_return_status              => x_return_status,
      x_msg_count                  => x_msg_count,
      x_msg_data                   => x_msg_data);

   check_ret_sts(x_return_status);

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'CREATE_TIER', 'A', 'V') then
      CN_MULTI_RATE_SCHEDULES_VUHK.CREATE_TIER_POST
	(p_dimension_name           => p_dimension_name,
	 p_value1                   => p_value1,
	 p_value2                   => p_value2,
	 p_tier_sequence            => p_tier_sequence,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'CREATE_TIER', 'A', 'C') then
      CN_MULTI_RATE_SCHEDULES_CUHK.CREATE_TIER_POST
	(p_dimension_name           => p_dimension_name,
	 p_value1                   => p_value1,
	 p_value2                   => p_value2,
	 p_tier_sequence            => p_tier_sequence,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
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
      ROLLBACK TO Create_tier;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_tier;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      ROLLBACK TO Create_tier;
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
END Create_tier;

PROCEDURE Update_Tier
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_dimension_name             IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   p_tier_sequence              IN      CN_RATE_DIM_TIERS.TIER_SEQUENCE%TYPE,
   p_value1                     IN      VARCHAR2,
   p_value2                     IN      VARCHAR2,
   p_object_version_number      IN OUT NOCOPY     CN_RATE_DIM_TIERS.OBJECT_VERSION_NUMBER%TYPE,
   -- Start - MOAC Change
   p_org_id                     IN      CN_RATE_TIERS.ORG_ID%TYPE,
   -- End  - MOAC Change
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2) IS

   l_api_name                CONSTANT VARCHAR2(30) := 'Update_Tier';
   l_api_version             CONSTANT NUMBER       := 1.0;
   l_rate_dimension_id       CN_RATE_DIMENSIONS.RATE_DIMENSION_ID%TYPE;
   l_rate_dim_tier_id        CN_RATE_DIM_TIERS.RATE_DIM_TIER_ID%TYPE;
   l_dim_unit_code           CN_RATE_DIMENSIONS.DIM_UNIT_CODE%TYPE;
   l_minimum_amount          CN_RATE_DIM_TIERS.MINIMUM_AMOUNT%TYPE;
   l_maximum_amount          CN_RATE_DIM_TIERS.MAXIMUM_AMOUNT%TYPE;
   l_min_exp_id              CN_RATE_DIM_TIERS.MIN_EXP_ID%TYPE;
   l_max_exp_id              CN_RATE_DIM_TIERS.MAX_EXP_ID%TYPE;
   l_string_value            CN_RATE_DIM_TIERS.STRING_VALUE%TYPE;
   -- Start - MOAC Change
   l_org_id  NUMBER;
   -- End   - MOAC Change
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Update_tier;
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

   l_rate_dimension_id := get_rate_dimension_id(p_dimension_name);
   l_rate_dim_tier_id  := get_rate_dim_tier_id(l_rate_dimension_id, p_tier_sequence);

   -- Start - MOAC Change
   SELECT org_id INTO l_org_id
   FROM   cn_rate_dim_tiers
   WHERE  rate_dim_tier_id = l_rate_dim_tier_id;

   IF   (l_org_id <> p_org_id)
   THEN
        FND_MESSAGE.SET_NAME ('FND' , 'FND_MO_OU_CANNOT_UPDATE');
        IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
        THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                         'cn.plsql.cn_multi_rate_schedule_pub.update_tier.error',
                         true);
        END IF;

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.SET_NAME ('FND' , 'FND_MO_OU_CANNOT_UPDATE');
           FND_MSG_PUB.Add;
        END IF;

    RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- End   - MOAC Change

   -- get dim_unit_code from the dimension
   select dim_unit_code into l_dim_unit_code from cn_rate_dimensions
    where rate_dimension_id = l_rate_dimension_id;

   translate_values(l_dim_unit_code, p_value1, p_value2, l_minimum_amount, l_maximum_amount,
		    l_min_exp_id, l_max_exp_id, l_string_value);

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'UPDATE_TIER', 'B', 'C') then
      CN_MULTI_RATE_SCHEDULES_CUHK.UPDATE_TIER_PRE
	(p_dimension_name           => p_dimension_name,
	 p_tier_sequence            => p_tier_sequence,
	 p_value1                   => p_value1,
	 p_value2                   => p_value2,
	 p_object_version_number    => p_object_version_number,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'UPDATE_TIER', 'B', 'V') then
      CN_MULTI_RATE_SCHEDULES_VUHK.UPDATE_TIER_PRE
	(p_dimension_name           => p_dimension_name,
	 p_tier_sequence            => p_tier_sequence,
	 p_value1                   => p_value1,
	 p_value2                   => p_value2,
	 p_object_version_number    => p_object_version_number,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   CN_RATE_DIMENSIONS_PVT.update_tier
     (p_api_version                => p_api_version,
      p_init_msg_list              => p_init_msg_list,
      p_commit                     => p_commit,
      p_validation_level           => p_validation_level,
      p_rate_dim_tier_id           => l_rate_dim_tier_id,
      p_rate_dimension_id          => l_rate_dimension_id,
      p_dim_unit_code              => l_dim_unit_code,
      p_minimum_amount             => l_minimum_amount,
      p_maximum_amount             => l_maximum_amount,
      p_min_exp_id                 => l_min_exp_id,
      p_max_exp_id                 => l_max_exp_id,
      p_string_value               => l_string_value,
      p_tier_sequence              => p_tier_sequence,
      p_object_version_number      => p_object_version_number,
      x_return_status              => x_return_status,
      x_msg_count                  => x_msg_count,
      x_msg_data                   => x_msg_data);

   check_ret_sts(x_return_status);

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'UPDATE_TIER', 'A', 'V') then
      CN_MULTI_RATE_SCHEDULES_VUHK.UPDATE_TIER_POST
	(p_dimension_name           => p_dimension_name,
	 p_tier_sequence            => p_tier_sequence,
	 p_value1                   => p_value1,
	 p_value2                   => p_value2,
	 p_object_version_number    => p_object_version_number,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'UPDATE_TIER', 'A', 'C') then
      CN_MULTI_RATE_SCHEDULES_CUHK.UPDATE_TIER_POST
	(p_dimension_name           => p_dimension_name,
	 p_tier_sequence            => p_tier_sequence,
	 p_value1                   => p_value1,
	 p_value2                   => p_value2,
	 p_object_version_number    => p_object_version_number,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
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
      ROLLBACK TO Update_tier;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_tier;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      ROLLBACK TO Update_tier;
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
END Update_tier;

PROCEDURE Delete_Tier
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_dimension_name             IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   p_tier_sequence              IN      CN_RATE_DIM_TIERS.TIER_SEQUENCE%TYPE,
   -- Start - R12 MOAC Changes
   p_object_version_number      IN      CN_RATE_TIERS.OBJECT_VERSION_NUMBER%TYPE, -- new
   -- End  - R12 MOAC Changes
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2) IS

   l_api_name                CONSTANT VARCHAR2(30) := 'Delete_Tier';
   l_api_version             CONSTANT NUMBER       := 1.0;
   l_rate_dimension_id       CN_RATE_DIMENSIONS.RATE_DIMENSION_ID%TYPE;
   l_rate_dim_tier_id        CN_RATE_DIM_TIERS.RATE_DIM_TIER_ID%TYPE;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Delete_Tier;
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

   l_rate_dimension_id := get_rate_dimension_id(p_dimension_name);
   l_rate_dim_tier_id  := get_rate_dim_tier_id(l_rate_dimension_id, p_tier_sequence);

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'DELETE_TIER', 'B', 'C') then
      CN_MULTI_RATE_SCHEDULES_CUHK.DELETE_TIER_PRE
	(p_dimension_name           => p_dimension_name,
	 p_tier_sequence            => p_tier_sequence,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'DELETE_TIER', 'B', 'V') then
      CN_MULTI_RATE_SCHEDULES_VUHK.DELETE_TIER_PRE
	(p_dimension_name           => p_dimension_name,
	 p_tier_sequence            => p_tier_sequence,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   CN_RATE_DIMENSIONS_PVT.delete_tier
     (p_api_version                => p_api_version,
      p_init_msg_list              => p_init_msg_list,
      p_commit                     => p_commit,
      p_validation_level           => p_validation_level,
      p_rate_dim_tier_id           => l_rate_dim_tier_id,
      x_return_status              => x_return_status,
      x_msg_count                  => x_msg_count,
      x_msg_data                   => x_msg_data);

   check_ret_sts(x_return_status);

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'DELETE_TIER', 'A', 'V') then
      CN_MULTI_RATE_SCHEDULES_VUHK.DELETE_TIER_POST
	(p_dimension_name           => p_dimension_name,
	 p_tier_sequence            => p_tier_sequence,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
   end if;

   if JTF_USR_HKS.Ok_to_Execute('CN_MULTI_RATE_SCHEDULES_PUB',
				'DELETE_TIER', 'A', 'C') then
      CN_MULTI_RATE_SCHEDULES_CUHK.DELETE_TIER_POST
	(p_dimension_name           => p_dimension_name,
	 p_tier_sequence            => p_tier_sequence,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data);

      check_ret_sts(x_return_status);
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
      ROLLBACK TO Delete_Tier;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_Tier;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_Tier;
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
END Delete_Tier;

END CN_MULTI_RATE_SCHEDULES_PUB;

/
