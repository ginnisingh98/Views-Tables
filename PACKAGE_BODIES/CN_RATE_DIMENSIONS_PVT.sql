--------------------------------------------------------
--  DDL for Package Body CN_RATE_DIMENSIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_RATE_DIMENSIONS_PVT" AS
/*$Header: cnvrdimb.pls 120.9 2007/08/08 19:21:44 jxsingh ship $*/

G_PKG_NAME         CONSTANT VARCHAR2(30)  :='CN_RATE_DIMENSIONS_PVT';

-- validate dimension name and dim_unit_code
PROCEDURE validate_dimension
  (p_rate_dimension_id          IN      CN_RATE_DIMENSIONS.RATE_DIMENSION_ID%TYPE := NULL,
   p_name                       IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   p_dim_unit_code              IN      CN_RATE_DIMENSIONS.DIM_UNIT_CODE%TYPE,
   p_number_tier                IN      CN_RATE_DIMENSIONS.NUMBER_TIER%TYPE,
   p_tiers_tbl                  IN      tiers_tbl_type := g_miss_tiers_tbl,
   --R12 MOAC Changes--Start
   p_org_id                     IN      CN_RATE_DIMENSIONS.ORG_ID%TYPE)
   --R12 MOAC Changes--End
  IS
     l_prompt                  CN_LOOKUPS.MEANING%TYPE;
     l_dummy                   NUMBER;

     CURSOR exp_info(p_calc_sql_exp_id NUMBER) IS
	SELECT 0
	  FROM dual
         WHERE NOT exists (SELECT 1 FROM cn_calc_sql_exps WHERE calc_sql_exp_id = p_calc_sql_exp_id)
        UNION ALL
        SELECT 1
	  FROM cn_calc_sql_exps
         WHERE calc_sql_exp_id = p_calc_sql_exp_id
	   AND exp_type_code like '%DDT%'
        UNION ALL
        SELECT 2
	  FROM cn_calc_sql_exps
         WHERE calc_sql_exp_id = p_calc_sql_exp_id
	   AND (exp_type_code IS NULL OR exp_type_code NOT LIKE '%DDT%');

     CURSOR name_exists IS
	SELECT 1
	  FROM cn_rate_dimensions
	  WHERE name = p_name
	    AND (p_rate_dimension_id IS NULL OR p_rate_dimension_id <> rate_dimension_id)
          --R12 MOAC Changes--Start
          AND org_id = p_org_id;
          --R12 MOAC Changes--End
BEGIN
   IF (p_name IS NULL) THEN
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	 l_prompt := cn_api.get_lkup_meaning('DIMENSION_NAME', 'CN_PROMPTS');
	 fnd_message.set_name('CN', 'CN_CANNOT_NULL');
	 fnd_message.set_token('OBJ_NAME', l_prompt);
	 fnd_msg_pub.ADD;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   OPEN name_exists;
   FETCH name_exists INTO l_dummy;
   CLOSE name_exists;

   IF (l_dummy = 1) THEN
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	 fnd_message.set_name('CN', 'CN_NAME_NOT_UNIQUE');
	 fnd_msg_pub.ADD;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   -- validate dim_unit_code
   IF (p_dim_unit_code NOT IN ('AMOUNT', 'PERCENT', 'STRING', 'EXPRESSION')) THEN
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	 fnd_message.set_name('CN', 'CN_INVALID_DIM_UOM');
	 fnd_msg_pub.ADD;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   -- if p_tiers_tbl is not empty, then p_number_tier should be equal to the number of records in p_tiers_tbl
   IF (p_tiers_tbl.COUNT > 0 AND p_number_tier <> p_tiers_tbl.count) THEN
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	 fnd_message.set_name('CN', 'CN_X_NUMBER_TIER');
	 fnd_msg_pub.ADD;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   -- 3. if p_dim_unit_code is AMOUNT or PERCENT, then min_amount > max_amount
   IF (p_dim_unit_code IN ('AMOUNT', 'PERCENT') AND p_tiers_tbl.COUNT > 0) THEN
      FOR i IN p_tiers_tbl.first..p_tiers_tbl.last LOOP
	 -- if minimum_amount is greater than maximum_amount, then error
	 IF (p_tiers_tbl(i).minimum_amount >= p_tiers_tbl(i).maximum_amount) THEN
	    IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	       fnd_message.set_name('CN', 'CN_MIN_G_MAX');
	       fnd_msg_pub.ADD;
	    END IF;
	    RAISE fnd_api.g_exc_error;
	 END IF;

	 -- if minimum_amount is not equal to previous tier's maximum_amount, then error
	 IF (i > 1 AND p_tiers_tbl(i).minimum_amount <> p_tiers_tbl(i-1).maximum_amount) THEN
	    IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	       fnd_message.set_name('CN', 'CN_MIN_NE_MAX');
	       fnd_msg_pub.ADD;
	    END IF;
	    RAISE fnd_api.g_exc_error;
	 END IF;
      END LOOP;
   END IF;

   -- if p_dim_unit_code is EXPRESSION, min_exp_id and max_exp_id should be
   -- foreign keys to cn_calc_sql_exps
   -- and exp_type_code should be available for dynamic dimensions
   IF (p_dim_unit_code = 'EXPRESSION' AND p_tiers_tbl.COUNT > 0) THEN
      FOR i IN p_tiers_tbl.first..p_tiers_tbl.last LOOP
	 OPEN exp_info(p_tiers_tbl(i).min_exp_id);
	 FETCH exp_info INTO l_dummy;
	 CLOSE exp_info;

	 IF (l_dummy = 0) THEN
	    IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	       fnd_message.set_name('CN', 'CN_EXP_NOT_EXIST');
	       fnd_msg_pub.ADD;
	    END IF;
	    RAISE fnd_api.g_exc_error;
	  ELSIF (l_dummy = 2) THEN
	    IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	       fnd_message.set_name('CN', 'CN_EXP_NOT_MATCH');
	       fnd_msg_pub.ADD;
	    END IF;
	    RAISE fnd_api.g_exc_error;
	 END IF;

	 OPEN exp_info(p_tiers_tbl(i).max_exp_id);
	 FETCH exp_info INTO l_dummy;
	 CLOSE exp_info;

	 IF (l_dummy = 0) THEN
	    IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	       fnd_message.set_name('CN', 'CN_EXP_NOT_EXIST');
	       fnd_msg_pub.ADD;
	    END IF;
	    RAISE fnd_api.g_exc_error;
	  ELSIF (l_dummy = 2) THEN
	    IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	       fnd_message.set_name('CN', 'CN_EXP_NOT_MATCH');
	       fnd_msg_pub.ADD;
	    END IF;
	    RAISE fnd_api.g_exc_error;
	 END IF;
      END LOOP;
   END IF;

END validate_dimension;

--    Notes           : Create rate dimensions and dimension tiers
--                      1) Validate dimension name (should be unique)
--                      2) Validate dim_unit_code (valid values are AMOUNT,
--                         PERCENT, STRING, EXPRESSION)
--                      3) Validate number_tier which should equal the number of
--                         tiers in p_tiers_tbl if it is not empty
--                      4) Validate dimension tiers (max_amount > min_amount)
PROCEDURE Create_Dimension
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_name                       IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   p_description                IN      CN_RATE_DIMENSIONS.DESCRIPTION%TYPE := NULL,
   p_dim_unit_code              IN      CN_RATE_DIMENSIONS.DIM_UNIT_CODE%TYPE,
   p_number_tier                IN      CN_RATE_DIMENSIONS.NUMBER_TIER%TYPE, -- not used
   p_tiers_tbl                  IN      tiers_tbl_type := g_miss_tiers_tbl,
   --R12 MOAC Changes--Start
   p_org_id                     IN      CN_RATE_DIMENSIONS.ORG_ID%TYPE,   --new
   x_rate_dimension_id          IN OUT NOCOPY     CN_RATE_DIMENSIONS.RATE_DIMENSION_ID%TYPE, --changed
   --R12 MOAC Changes--End
   x_return_status              OUT NOCOPY     VARCHAR2                        ,
   x_msg_count                  OUT NOCOPY     NUMBER                          ,
   x_msg_data                   OUT NOCOPY     VARCHAR2                        )
  IS
     l_api_name                CONSTANT VARCHAR2(30) := 'Create_Dimension';
     l_api_version             CONSTANT NUMBER       := 1.0;

     l_temp_id                 CN_RATE_DIM_TIERS.RATE_DIM_TIER_ID%TYPE;
     l_number_tier             CN_RATE_DIMENSIONS.NUMBER_TIER%TYPE;

     --R12 Notes Hoistory
     l_dimension_name          VARCHAR2(30);
     l_note_msg                 VARCHAR2(240);
     l_note_id                  NUMBER;

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

   -- calculate number of tiers (p_number_tier not used)
   -- set number_tier := number of tiers of p_tiers_tbl
   l_number_tier := p_tiers_tbl.count;

   validate_dimension(NULL,
		      p_name,
		      p_dim_unit_code,
		      l_number_tier,
		      p_tiers_tbl,
                  --R12 MOAC Changes--Start
                  p_org_id);
                  --R12 MOAC Changes--End

   -- call table handler to create dimension record in cn_rate_dimensions
   cn_rate_dimensions_pkg.insert_row
     (x_rate_dimension_id     => x_rate_dimension_id,
      x_name                  => p_name,
      x_description           => p_description,
      x_dim_unit_code         => p_dim_unit_code,
      x_number_tier           => l_number_tier,
      --R12 MOAC Changes--Start
      x_org_id                => p_org_id
      --R12 MOAC Changes--End
     );

   -- *********************************************************************
   -- ************ Start - R12 Notes History ************** ***************
   -- *********************************************************************
      select name into l_dimension_name
      from   cn_rate_dimensions
      where  rate_dimension_id = x_rate_dimension_id;

      fnd_message.set_name('CN', 'CNR12_NOTE_RT_DIM_CREATE');
      fnd_message.set_token('RT_DIM', l_dimension_name);
      l_note_msg := fnd_message.get;

      jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => x_rate_dimension_id,
                            p_source_object_code      => 'CN_RATE_DIMENSIONS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );

   -- *********************************************************************
   -- ************ End - R12 Notes History **************** ***************
   -- *********************************************************************

   -- *********************************************************************
   -- ************ Start - This code is not required in R12 ***************
   -- *** Start - This code is introduced back in R12+ Import Plan Copy ***
   -- *********************************************************************
   -- Start - Bug#6325544 fixed for Import Plan Copy

   -- call table handler to create dimension tiers
   IF (p_tiers_tbl.COUNT > 0) THEN
      FOR i IN p_tiers_tbl.first..p_tiers_tbl.last LOOP
	 l_temp_id := NULL;
	 cn_rate_dim_tiers_pkg.insert_row
	   (x_rate_dim_tier_id    => l_temp_id,
	    x_rate_dimension_id   => x_rate_dimension_id,
	    x_minimum_amount      => p_tiers_tbl(i).minimum_amount,
	    x_maximum_amount      => p_tiers_tbl(i).maximum_amount,
	    x_min_exp_id          => p_tiers_tbl(i).min_exp_id,
	    x_max_exp_id          => p_tiers_tbl(i).max_exp_id,
	    x_string_value        => p_tiers_tbl(i).string_value,
	    x_tier_sequence       => p_tiers_tbl(i).tier_sequence,
          --R12 MOAC Changes--Start
          x_org_id              => p_org_id
          --R12 MOAC Changes--End
         );
      END LOOP;
   END IF;

   -- End - Bug#6325544 fixed for Import Plan Copy
   -- *********************************************************************
   -- **** End - This code is introduced back in R12+ Import Plan Copy ****
   -- ************ End - This code is not required in R12 *****************
   -- *********************************************************************
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

--    Notes           : Update rate dimensions and dimension tiers
--                      1) Validate dimension name (should be unique)
--                      2) Validate dim_unit_code (valid values are AMOUNT,
--                         PERCENT, STRING, EXPRESSION)
--                      3) Validate number_tier which should equal the number of
--                         tiers in p_tiers_tbl if it is not empty
--                      4) Validate dimension tiers (max_amount > min_amount)
--                      5) Insert new tiers and delete obsolete tiers
--                      6) If this dimension is used in a rate table which is in
--                         turn used in a formula, then dim_unit_code
--                         can not be updated
PROCEDURE Update_Dimension
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_rate_dimension_id          IN      CN_RATE_DIMENSIONS.RATE_DIMENSION_ID%TYPE,
   p_name                       IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   p_description                IN      CN_RATE_DIMENSIONS.DESCRIPTION%TYPE := NULL,
   p_dim_unit_code              IN      CN_RATE_DIMENSIONS.DIM_UNIT_CODE%TYPE,
   p_number_tier                IN      CN_RATE_DIMENSIONS.NUMBER_TIER%TYPE, -- not used
   p_tiers_tbl                  IN      tiers_tbl_type := g_miss_tiers_tbl,
   --R12 MOAC Changes--Start
   p_org_id                     IN      CN_RATE_DIMENSIONS.ORG_ID%TYPE,   --new
   p_object_version_number      IN OUT NOCOPY CN_RATE_DIMENSIONS.OBJECT_VERSION_NUMBER%TYPE, --Changed
   --R12 MOAC Changes--End
   x_return_status              OUT NOCOPY     VARCHAR2                        ,
   x_msg_count                  OUT NOCOPY     NUMBER                          ,
   x_msg_data                   OUT NOCOPY     VARCHAR2                        )
  IS
     l_api_name                CONSTANT VARCHAR2(30) := 'Update_Dimension';
     l_api_version             CONSTANT NUMBER       := 1.0;

     l_temp_id                 CN_RATE_DIM_TIERS.RATE_DIM_TIER_ID%TYPE;
     l_dim_unit_code           CN_RATE_DIM_TIERS.DIM_UNIT_CODE%TYPE;
     l_delete_flag             VARCHAR2(1);
     l_dummy                   NUMBER;
     l_number_tier             CN_RATE_DIMENSIONS.NUMBER_TIER%TYPE;

     --R12 Notes Hoistory
     l_dimension_name_old    VARCHAR2(30);
     l_type_old              VARCHAR2(30);
     l_note_msg              VARCHAR2(240);
     l_note_id               NUMBER;
     l_consolidated_note     VARCHAR2(2000);
     CURSOR dim_unit_code IS
	SELECT dim_unit_code
	  FROM cn_rate_dimensions
	  WHERE rate_dimension_id = p_rate_dimension_id;

     CURSOR formula_info IS
	SELECT 1
	  FROM dual
	  WHERE exists (SELECT 1
			FROM cn_rate_sch_dims rsd
			WHERE rsd.rate_dimension_id = p_rate_dimension_id
			AND exists (SELECT 1
				    FROM cn_rt_formula_asgns
				    WHERE rate_schedule_id = rsd.rate_schedule_id));

     CURSOR db_tiers IS
	SELECT rate_dim_tier_id
	  FROM cn_rate_dim_tiers
	  WHERE rate_dimension_id = p_rate_dimension_id;
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
   -- calculate number of tiers (p_number_tier not used)
   -- set number_tier := number of tiers of p_tiers_tbl
   l_number_tier := p_tiers_tbl.count;

   validate_dimension(p_rate_dimension_id,
		      p_name,
		      p_dim_unit_code,
		      l_number_tier,
		      p_tiers_tbl,
                  --R12 MOAC Changes--Start
                  p_org_id);
                  --R12 MOAC Changes--End

   OPEN dim_unit_code;
   FETCH dim_unit_code INTO l_dim_unit_code;
   CLOSE dim_unit_code;

   IF (l_dim_unit_code <> p_dim_unit_code) THEN
      OPEN formula_info;
      FETCH formula_info INTO l_dummy;
      CLOSE formula_info;

      -- if it is used in a formula, then can not update dim_unit_code
      IF (l_dummy = 1) THEN
	 IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	    fnd_message.set_name('CN', 'CN_X_UPDATE_DUC1');
	    fnd_msg_pub.ADD;
	 END IF;
	 RAISE fnd_api.g_exc_error;
      END IF;

      -- dim_unit_code can be changed only between AMOUNT and PERCENT
      IF (p_dim_unit_code NOT IN ('AMOUNT', 'PERCENT') OR
	  l_dim_unit_code NOT IN ('AMOUNT', 'PERCENT')) THEN
	 IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	    fnd_message.set_name('CN', 'CN_X_UPDATE_DUC2');
	    fnd_msg_pub.ADD;
	 END IF;
	 RAISE fnd_api.g_exc_error;
      END IF;
   END IF;

   -- *********************************************************************
   -- ************ Start - This code is not required in R12 ***************
   -- *********************************************************************
   /*
   IF (p_tiers_tbl.COUNT > 0) THEN
      -- delete the obsolete tiers
      FOR db_tier IN db_tiers LOOP
	 l_delete_flag := 'Y';
	 FOR j IN p_tiers_tbl.first..p_tiers_tbl.last LOOP
	    IF (p_tiers_tbl(j).rate_dim_tier_id IS NOT NULL AND
		p_tiers_tbl(j).rate_dim_tier_id = db_tier.rate_dim_tier_id) THEN
	       l_delete_flag := 'N';
	       EXIT;
	    END IF;
	 END LOOP;

	 IF (l_delete_flag = 'Y') THEN
	    delete_tier(p_api_version       => 1.0,
			p_rate_dim_tier_id  => db_tier.rate_dim_tier_id,
			x_return_status     => x_return_status,
			x_msg_count         => x_msg_count,
			x_msg_data          => x_msg_data);
	    IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
	       RAISE fnd_api.g_exc_error;
	    END IF;
	 END IF;
      END LOOP;

      -- update the existing tiers
      FOR i IN p_tiers_tbl.first..p_tiers_tbl.last LOOP
	 IF (p_tiers_tbl(i).rate_dim_tier_id IS NOT NULL) THEN
	    cn_rate_dim_tiers_pkg.lock_row
	      (x_rate_dim_tier_id      => p_tiers_tbl(i).rate_dim_tier_id,
	       x_object_version_number => p_tiers_tbl(i).object_version_number);
	    cn_rate_dim_tiers_pkg.update_row
	      (x_rate_dim_tier_id      => p_tiers_tbl(i).rate_dim_tier_id,
	       x_rate_dimension_id     => p_rate_dimension_id,
	       x_minimum_amount        => p_tiers_tbl(i).minimum_amount,
	       x_maximum_amount        => p_tiers_tbl(i).maximum_amount,
	       x_min_exp_id            => p_tiers_tbl(i).min_exp_id,
	       x_max_exp_id            => p_tiers_tbl(i).max_exp_id,
	       x_string_value          => p_tiers_tbl(i).string_value,
	       x_tier_sequence         => p_tiers_tbl(i).tier_sequence,
	       x_object_version_number => p_tiers_tbl(i).object_version_number);
	 END IF;
      END LOOP;

      -- create the new tiers
      FOR i IN p_tiers_tbl.first..p_tiers_tbl.last LOOP
	 IF (p_tiers_tbl(i).rate_dim_tier_id IS NULL) then
	    l_temp_id := NULL;
	    create_tier(p_api_version       => 1.0,
			p_rate_dimension_id => p_rate_dimension_id,
			p_dim_unit_code     => p_dim_unit_code,
			p_minimum_amount    => p_tiers_tbl(i).minimum_amount,
			p_maximum_amount    => p_tiers_tbl(i).maximum_amount,
			p_min_exp_id        => p_tiers_tbl(i).min_exp_id,
			p_max_exp_id        => p_tiers_tbl(i).max_exp_id,
			p_string_value      => p_tiers_tbl(i).string_value,
			p_tier_sequence     => p_tiers_tbl(i).tier_sequence,
			--R12 MOAC Changes--Start
            p_org_id            => p_org_id,
            --R12 MOAC Changes--End
			x_rate_dim_tier_id  => l_temp_id,
			x_return_status     => x_return_status,
			x_msg_count         => x_msg_count,
			x_msg_data          => x_msg_data);

	    IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
	       RAISE fnd_api.g_exc_error;
	    END IF;
	 END IF;
      END LOOP;
   END IF;
   */
   -- *********************************************************************
   -- ************ End - This code is not required in R12 *****************
   -- *********************************************************************

   -- Start - R12 Notes History Query for old Dimension Name
   select name into l_dimension_name_old
   from   cn_rate_dimensions
   where  rate_dimension_id = p_rate_dimension_id;

   select dim_unit_code into l_type_old
   from   cn_rate_dimensions
   where  rate_dimension_id = p_rate_dimension_id;
   -- End - R12 Notes History Query for old Dimension Name

   -- call table handler to update dimension record in cn_rate_dimensions
   -- get the appropriate number of tiers
   select count(*) into l_number_tier from cn_rate_dim_tiers
    where rate_dimension_id = p_rate_dimension_id;

   cn_rate_dimensions_pkg.lock_row
     (x_rate_dimension_id      => p_rate_dimension_id,
      x_object_version_number  => p_object_version_number);

   cn_rate_dimensions_pkg.update_row
     (x_rate_dimension_id      => p_rate_dimension_id,
      x_name                   => p_name,
      x_description            => p_description,
      x_dim_unit_code          => p_dim_unit_code,
      x_number_tier            => l_number_tier,
      x_object_version_number  => p_object_version_number);

   -- *********************************************************************
   -- ************ Start - R12 Notes History ************** ***************
   -- *********************************************************************
   l_consolidated_note := '';
   IF (p_name <> l_dimension_name_old) THEN
        fnd_message.set_name('CN', 'CNR12_NOTE_RT_DIM_UPDATE');
        fnd_message.set_token('OLD_RT_DIM', l_dimension_name_old);
        fnd_message.set_token('NEW_RT_DIM', p_name);
        l_note_msg := fnd_message.get;
        l_consolidated_note := l_note_msg || fnd_global.local_chr(10);
        /*jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => p_rate_dimension_id,
                            p_source_object_code      => 'CN_RATE_DIMENSIONS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );*/
     END IF;

     IF (p_dim_unit_code <> l_type_old) THEN
        fnd_message.set_name('CN', 'CNR12_NOTE_RT_DIM_TYPE_UPDATE');
        fnd_message.set_token('OLD_DIM_TYPE', cn_api.get_lkup_meaning(l_type_old, 'UNIT_OF_MEASURE'));
        fnd_message.set_token('NEW_DIM_TYPE', cn_api.get_lkup_meaning(p_dim_unit_code, 'UNIT_OF_MEASURE'));
        l_note_msg := fnd_message.get;
        l_consolidated_note := l_consolidated_note || l_note_msg || fnd_global.local_chr(10);
/*        jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => p_rate_dimension_id,
                            p_source_object_code      => 'CN_RATE_DIMENSIONS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           ); */
     END IF;

     IF LENGTH(l_consolidated_note) > 1 THEN
         jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => p_rate_dimension_id,
                            p_source_object_code      => 'CN_RATE_DIMENSIONS',
                            p_notes                   => l_consolidated_note,
                            p_notes_detail            => l_consolidated_note,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );
      END IF;

   -- *********************************************************************
   -- ************ End - R12 Notes History ********************************
   -- *********************************************************************

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

--    Notes           : Delete rate dimensions and dimension tiers
--                      1) If it is used in a rate table, it can not be deleted
PROCEDURE Delete_Dimension
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_rate_dimension_id          IN      CN_RATE_DIMENSIONS.RATE_DIMENSION_ID%TYPE,
   --R12 MOAC Changes--Start
   p_object_version_number      IN     CN_RATE_DIMENSIONS.OBJECT_VERSION_NUMBER%TYPE, --new
   --R12 MOAC Changes--End
   x_return_status              OUT NOCOPY     VARCHAR2                        ,
   x_msg_count                  OUT NOCOPY     NUMBER                          ,
   x_msg_data                   OUT NOCOPY     VARCHAR2                        )
  IS
     l_api_name                  CONSTANT VARCHAR2(30) := 'Delete_Dimension';
     l_api_version               CONSTANT NUMBER       := 1.0;
     l_dummy                     pls_integer;

     --R12 Notes Hoistory
     l_dimension_name    VARCHAR2(30);
     l_org_id           Number;
     l_note_msg          VARCHAR2(240);
     l_note_id           NUMBER;

     CURSOR parent_table_exist IS
	SELECT 1
	  FROM dual
	  WHERE exists (SELECT 1
			FROM cn_rate_sch_dims
			WHERE rate_dimension_id = p_rate_dimension_id);
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

   OPEN parent_table_exist;
   FETCH parent_table_exist INTO l_dummy;
   CLOSE parent_table_exist;

   IF (l_dummy = 1) THEN
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	 fnd_message.set_name('CN', 'CN_DIMENSION_IN_USE');
	 fnd_msg_pub.ADD;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   /* Start - R12 Notes History */
   SELECT org_id INTO l_org_id
   FROM   cn_rate_dimensions
   WHERE  rate_dimension_id = p_rate_dimension_id;

   SELECT name INTO l_dimension_name
   FROM   cn_rate_dimensions
   WHERE  rate_dimension_id = p_rate_dimension_id;
   /* End - R12 Notes History */


   -- table handler does cascading delete of dimension tiers
   cn_rate_dimensions_pkg.delete_row(p_rate_dimension_id);

   -- *********************************************************************
   -- ************ Start - R12 Notes History ******************************
   -- *********************************************************************
        IF (l_org_id <> -999) THEN
        fnd_message.set_name('CN', 'CNR12_NOTE_RT_DIM_DELETE');
        fnd_message.set_token('RT_DIM', l_dimension_name);
        l_note_msg := fnd_message.get;

        jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => l_org_id,
                            p_source_object_code      => 'CN_DELETED_OBJECTS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );
     END IF;

   -- *********************************************************************
   -- ************ End - R12 Notes History ********************************
   -- *********************************************************************
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

--      Notes           : Delete dimension tiers
--                        1) If the dimension is used in a rate table, at least one
--                           tier should be left in the rate dimension
--                        2) If it is used in a rate table, delete the corresponding
--                           records in cn_sch_dim_tiers,
--                           cn_srp_rate_assigns, cn_rate_tiers, and cn_rate_dim_tiers
--                        3) update cn_rate_dimensions.number_tier
--                        4) tier_sequence is not adjusted here, users should take
--                           care of the adjustment by calling update_tier
--                        5) the other validations should be done by users also
--                           (like minimum_amount < maximum_amount, etc.)
PROCEDURE delete_tier
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_rate_dim_tier_id           IN      CN_RATE_DIM_TIERS.RATE_DIM_TIER_ID%TYPE,
   x_return_status              OUT NOCOPY     VARCHAR2                        ,
   x_msg_count                  OUT NOCOPY     NUMBER                          ,
   x_msg_data                   OUT NOCOPY     VARCHAR2                        )
  IS
     l_api_name                CONSTANT VARCHAR2(30) := 'Delete_Tier';
     l_api_version             CONSTANT NUMBER       := 1.0;

     l_rate_dim_sequence       CN_RATE_SCH_DIMS.RATE_DIM_SEQUENCE%TYPE;
     l_tier_sequence           CN_RATE_DIM_TIERS.TIER_SEQUENCE%TYPE;
     l_dummy                   pls_integer;
     l_rate_dimension_id       CN_RATE_DIMENSIONS.RATE_DIMENSION_ID%TYPE;

     --R12 Notes Hoistory
     l_from              VARCHAR2(100);
     l_to                VARCHAR2(100);
     l_org_old           Number;
     l_note_msg          VARCHAR2(240);
     l_note_id           NUMBER;

     CURSOR rate_tables IS
	SELECT rate_schedule_id
	  FROM cn_rate_sch_dims
	  WHERE rate_dimension_id = l_rate_dimension_id;

     CURSOR last_tier IS
	SELECT 1
	  FROM dual
	  WHERE NOT exists (SELECT 1
			    FROM cn_rate_dim_tiers
			    WHERE rate_dimension_id = l_rate_dimension_id
			    AND rate_dim_tier_id <> p_rate_dim_tier_id);

	--R12 History Cursor
    CURSOR  get_old_rec IS
    Select  minimum_amount, maximum_amount, min_exp_id, max_exp_id,
    string_value, org_id
    from    cn_rate_dim_tiers
    where   rate_dim_tier_id = p_rate_dim_tier_id;

    l_old_rec   get_old_rec%ROWTYPE;

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

   -- get dimension ID
   begin
      SELECT rate_dimension_id, tier_sequence
	INTO l_rate_dimension_id, l_tier_sequence
	FROM cn_rate_dim_tiers
       WHERE rate_dim_tier_id = p_rate_dim_tier_id;
   exception
      when no_data_found then
	 fnd_message.set_name('CN', 'CN_RECORD_DELETED');
	 fnd_msg_pub.add;
	 raise fnd_api.g_exc_unexpected_error;
   end;

   FOR rate_table IN rate_tables LOOP
      OPEN last_tier;
      FETCH last_tier INTO l_dummy;
      CLOSE last_tier;

      IF (l_dummy = 1) THEN
	 IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	    fnd_message.set_name('CN', 'CN_DIM_LAST_TIER');
	    fnd_msg_pub.ADD;
	 END IF;
	 RAISE fnd_api.g_exc_error;
      END IF;

      SELECT rate_dim_sequence
	INTO l_rate_dim_sequence
	FROM cn_rate_sch_dims
	WHERE rate_schedule_id = rate_table.rate_schedule_id
	AND rate_dimension_id = l_rate_dimension_id;

      -- delete corresponding records in cn_rate_tiers
      cn_multi_rate_schedules_pvt.delete_rate_tiers
	(p_rate_schedule_id   => rate_table.rate_schedule_id,
	 p_rate_dim_sequence  => l_rate_dim_sequence,
	 p_tier_sequence      => l_tier_sequence);
   END LOOP;

   /* Start - R12 Notes History */
   Open  get_old_rec;
   Fetch get_old_rec into l_old_rec;
   close get_old_rec;

   /* End - R12 Notes History */

   -- delete this tier in cn_rate_dim_tiers
   cn_rate_dim_tiers_pkg.delete_row(p_rate_dim_tier_id);

   -- *********************************************************************
   -- ************ Start - R12 Notes History ******************************
   -- *********************************************************************
   IF (l_old_rec.org_id <> -999) THEN
     if (l_old_rec.minimum_amount is NOT NULL AND l_old_rec.maximum_amount is NOT NULL)
     then
         l_from := l_old_rec.minimum_amount;
         l_to   := l_old_rec.maximum_amount;
         fnd_message.set_name('CN', 'CNR12_NOTE_RT_DIM_TI_DELETE');
         fnd_message.set_token('FROM', l_from);
         fnd_message.set_token('TO', l_to);
     end if;
     if (l_old_rec.min_exp_id is NOT NULL AND l_old_rec.max_exp_id is NOT NULL)
     then
         select name into l_from from cn_calc_sql_exps
         where calc_sql_exp_id = l_old_rec.min_exp_id;
         select name into l_to from cn_calc_sql_exps
         where calc_sql_exp_id = l_old_rec.max_exp_id;
         fnd_message.set_name('CN', 'CNR12_NOTE_RT_DIM_TI_DELETE');
         fnd_message.set_token('FROM', l_from);
         fnd_message.set_token('TO', l_to);
     end if;
     if (l_old_rec.string_value is NOT NULL)
     then
         fnd_message.set_name('CN', 'CNR12_NOTE_RT_DIM_TI_ST_DELETE');
         fnd_message.set_token('STR_VAL', l_old_rec.string_value);
     end if;

        l_note_msg := fnd_message.get;

        jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => l_rate_dimension_id,
                            p_source_object_code      => 'CN_RATE_DIMENSIONS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );
     END IF;

   -- *********************************************************************
   -- ************ End - R12 Notes History ********************************
   -- *********************************************************************


   -- push tier sequence numbers down by one
   update cn_rate_dim_tiers set tier_sequence = tier_sequence - 1
    where rate_dimension_id = l_rate_dimension_id
      and tier_sequence    >= l_tier_sequence;

   -- update rate dimension (number_tier is treated as a "virtual column" - just a
   -- count(*) of tiers assigned to the rate_dimension... it is not ovn controlled here
   UPDATE cn_rate_dimensions
      SET number_tier = (select count(*) from cn_rate_dim_tiers
	 		 where rate_dimension_id = l_rate_dimension_id)
    WHERE rate_dimension_id = l_rate_dimension_id;

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

--      Notes           : Update dimension tiers
PROCEDURE update_tier
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_rate_dim_tier_id           IN      CN_RATE_DIM_TIERS.RATE_DIM_TIER_ID%TYPE,
   p_rate_dimension_id          IN      CN_RATE_DIM_TIERS.RATE_DIMENSION_ID%TYPE,
   p_dim_unit_code              IN      CN_RATE_DIM_TIERS.DIM_UNIT_CODE%TYPE,
   p_minimum_amount             IN      CN_RATE_DIM_TIERS.MINIMUM_AMOUNT%TYPE := cn_api.g_miss_num,
   p_maximum_amount             IN      CN_RATE_DIM_TIERS.MAXIMUM_AMOUNT%TYPE := cn_api.g_miss_num,
   p_min_exp_id                 IN      CN_RATE_DIM_TIERS.MIN_EXP_ID%TYPE     := cn_api.g_miss_num,
   p_max_exp_id                 IN      CN_RATE_DIM_TIERS.MAX_EXP_ID%TYPE     := cn_api.g_miss_num,
   p_string_value               IN      CN_RATE_DIM_TIERS.STRING_VALUE%TYPE   := cn_api.g_miss_char,
   p_tier_sequence              IN      CN_RATE_DIM_TIERS.TIER_SEQUENCE%TYPE  := cn_api.g_miss_num,
   -- R12 MOAC Changes --Start
   p_object_version_number      IN OUT NOCOPY CN_RATE_DIM_TIERS.OBJECT_VERSION_NUMBER%TYPE, --changed
   -- R12 MOAC Changes --End
   x_return_status              OUT NOCOPY     VARCHAR2                        ,
   x_msg_count                  OUT NOCOPY     NUMBER                          ,
   x_msg_data                   OUT NOCOPY     VARCHAR2                        )
  IS
     l_api_name                CONSTANT VARCHAR2(30) := 'Update_Tier';
     l_api_version             CONSTANT NUMBER       := 1.0;

   --R12 Notes Hoistory
     l_from_old         VARCHAR2(100);
     l_to_old           VARCHAR2(100);
     l_from_new         VARCHAR2(100);
     l_to_new           VARCHAR2(100);
     l_note_msg         VARCHAR2(240);
     l_note_id          NUMBER;

     --R12 History Cursor
    CURSOR  get_old_rec IS
    Select  minimum_amount, maximum_amount, min_exp_id, max_exp_id, string_value
    from    cn_rate_dim_tiers
    where   rate_dim_tier_id = p_rate_dim_tier_id;

    l_old_rec   get_old_rec%ROWTYPE;


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

   IF (p_dim_unit_code IN ('AMOUNT', 'PERCENT')) THEN
      IF (p_minimum_amount = fnd_api.g_miss_num OR
	  p_maximum_amount = fnd_api.g_miss_num OR
	  p_minimum_amount IS NULL OR
	  p_maximum_amount IS NULL)
	    THEN
	 IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	    fnd_message.set_name('CN', 'CN_TIER_NULL_MISS');
	    fnd_msg_pub.ADD;
	 END IF;
	 RAISE fnd_api.g_exc_error;
      END IF;

      IF (p_minimum_amount >= p_maximum_amount) THEN
	 IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	    fnd_message.set_name('CN', 'CN_MIN_G_MAX');
	    fnd_msg_pub.ADD;
	 END IF;
	 RAISE fnd_api.g_exc_error;
      END IF;
   END IF;

   /* Start - R12 Notes History */
   Open  get_old_rec;
   Fetch get_old_rec into l_old_rec;
   close get_old_rec;
   /* End - R12 Notes History */

   -- update this tier in cn_rate_dim_tiers
   cn_rate_dim_tiers_pkg.lock_row
     (x_rate_dim_tier_id      => p_rate_dim_tier_id,
      x_object_version_number => p_object_version_number);

   cn_rate_dim_tiers_pkg.update_row
     (x_rate_dim_tier_id      => p_rate_dim_tier_id,
      x_rate_dimension_id     => p_rate_dimension_id,
      x_minimum_amount        => p_minimum_amount,
      x_maximum_amount        => p_maximum_amount,
      x_min_exp_id            => p_min_exp_id,
      x_max_exp_id            => p_max_exp_id,
      x_string_value          => p_string_value,
      x_tier_sequence         => p_tier_sequence,
      x_object_version_number => p_object_version_number);


   -- *********************************************************************
   -- ************ Start - R12 Notes History ******************************
   -- *********************************************************************
     IF ((l_old_rec.minimum_amount <> p_minimum_amount) OR
         (l_old_rec.maximum_amount <> p_maximum_amount) OR
         (l_old_rec.min_exp_id     <> p_min_exp_id) OR
         (l_old_rec.max_exp_id     <> p_max_exp_id) OR
         (l_old_rec.string_value   <> p_string_value))
     THEN
        if (p_minimum_amount is NOT NULL AND p_maximum_amount is NOT NULL)
         then
            l_from_old := l_old_rec.minimum_amount;
            l_to_old   := l_old_rec.maximum_amount;
            l_from_new := p_minimum_amount;
            l_to_new   := p_maximum_amount;
            fnd_message.set_name('CN', 'CNR12_NOTE_RT_DIM_TI_UPDATE');
            fnd_message.set_token('OLD_FROM', l_from_old);
            fnd_message.set_token('OLD_TO', l_to_old);
            fnd_message.set_token('NEW_FROM', l_from_new);
            fnd_message.set_token('NEW_TO', l_to_new);
        end if;
        if (p_min_exp_id is NOT NULL AND p_max_exp_id is NOT NULL)
         then
            select name into l_from_old from cn_calc_sql_exps
            where calc_sql_exp_id = l_old_rec.min_exp_id;
            select name into l_to_old from cn_calc_sql_exps
            where calc_sql_exp_id = l_old_rec.max_exp_id;
            select name into l_from_new from cn_calc_sql_exps
            where calc_sql_exp_id = p_min_exp_id;
            select name into l_to_new from cn_calc_sql_exps
            where calc_sql_exp_id = p_max_exp_id;
            fnd_message.set_name('CN', 'CNR12_NOTE_RT_DIM_TI_UPDATE');
            fnd_message.set_token('OLD_FROM', l_from_old);
            fnd_message.set_token('OLD_TO', l_to_old);
            fnd_message.set_token('NEW_FROM', l_from_new);
            fnd_message.set_token('NEW_TO', l_to_new);
        end if;
        if (p_string_value is not null) then
            fnd_message.set_name('CN', 'CNR12_NOTE_RT_DIM_TI_ST_UPDATE');
            fnd_message.set_token('OLD_STR_VAL', l_old_rec.string_value);
            fnd_message.set_token('NEW_STR_VAL', p_string_value);
        end if;

        l_note_msg := fnd_message.get;

        jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => p_rate_dimension_id,
                            p_source_object_code      => 'CN_RATE_DIMENSIONS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );
     END IF;

   -- *********************************************************************
   -- ************ End - R12 Notes History ********************************
   -- *********************************************************************

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

--      Notes           : Create dimension tiers
--                        1) If it is used in a rate table, update cn_sch_dim_tiers,
--                           cn_srp_rate_assigns, and cn_rate_tiers,
--                           and adjust cn_rate_tiers.rate_sequence
--                        2) update cn_rate_dimensions.number_tier
--                        3) tier_sequence is not adjusted here, users should do it by calling
--                           update_tier
--                        4) minimum_amount < maximum_amount
--                        5) validation of minimum_amount = previous maximum_amount should be
--                           done by users
PROCEDURE create_tier
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_rate_dimension_id          IN      CN_RATE_DIM_TIERS.RATE_DIMENSION_ID%TYPE,
   p_dim_unit_code              IN      CN_RATE_DIM_TIERS.DIM_UNIT_CODE%TYPE,
   p_minimum_amount             IN      CN_RATE_DIM_TIERS.MINIMUM_AMOUNT%TYPE := null,
   p_maximum_amount             IN      CN_RATE_DIM_TIERS.MAXIMUM_AMOUNT%TYPE := null,
   p_min_exp_id                 IN      CN_RATE_DIM_TIERS.MIN_EXP_ID%TYPE     := null,
   p_max_exp_id                 IN      CN_RATE_DIM_TIERS.MAX_EXP_ID%TYPE     := null,
   p_string_value               IN      CN_RATE_DIM_TIERS.STRING_VALUE%TYPE   := null,
   p_tier_sequence              IN      CN_RATE_DIM_TIERS.TIER_SEQUENCE%TYPE  := null,
   -- R12 MOAC Changes --Start
   p_org_id                     IN      CN_RATE_DIM_TIERS.ORG_ID%TYPE, --new
   x_rate_dim_tier_id           IN OUT NOCOPY     CN_RATE_DIM_TIERS.RATE_DIM_TIER_ID%TYPE, --changed
   -- R12 MOAC Changes --End
   x_return_status              OUT NOCOPY     VARCHAR2                        ,
   x_msg_count                  OUT NOCOPY     NUMBER                          ,
   x_msg_data                   OUT NOCOPY     VARCHAR2                        )
  IS
     l_api_name                CONSTANT VARCHAR2(30) := 'Create_Tier';
     l_api_version             CONSTANT NUMBER       := 1.0;

     l_rate_dim_sequence       CN_RATE_SCH_DIMS.RATE_DIM_SEQUENCE%TYPE;
     i                         pls_integer := 1;

     --R12 Notes Hoistory
     l_from             VARCHAR2(100);
     l_to               VARCHAR2(100);
     l_note_msg         VARCHAR2(240);
     l_note_id          NUMBER;

     CURSOR rate_tables IS
	SELECT rate_schedule_id
	  FROM cn_rate_sch_dims
	  WHERE rate_dimension_id = p_rate_dimension_id;
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

   IF (p_dim_unit_code IN ('AMOUNT', 'PERCENT')) THEN
      IF (p_minimum_amount = fnd_api.g_miss_num OR
	  p_maximum_amount = fnd_api.g_miss_num OR
	  p_minimum_amount IS NULL OR
	  p_maximum_amount IS NULL)
	    THEN
	 IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	    fnd_message.set_name('CN', 'CN_TIER_NULL_MISS');
	    fnd_msg_pub.ADD;
	 END IF;
	 RAISE fnd_api.g_exc_error;
      END IF;

      IF (p_minimum_amount >= p_maximum_amount) THEN
	 IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
	    fnd_message.set_name('CN', 'CN_MIN_G_MAX');
	    fnd_msg_pub.ADD;
	 END IF;
	 RAISE fnd_api.g_exc_error;
      END IF;
   END IF;

   FOR rate_table IN rate_tables LOOP
      -- NOTE: a rate table can not have two dimensions with the same rate_dimension_id
      SELECT rate_dim_sequence
	INTO l_rate_dim_sequence
	FROM cn_rate_sch_dims
       WHERE rate_dimension_id = p_rate_dimension_id
	 AND rate_schedule_id  = rate_table.rate_schedule_id;

      cn_multi_rate_schedules_pvt.create_rate_tiers
	(p_rate_schedule_id   => rate_table.rate_schedule_id,
	 p_rate_dim_sequence  => l_rate_dim_sequence,
	 p_tier_sequence      => p_tier_sequence,
	 -- R12 MOAC Changes --Start
     p_org_id             => p_org_id);
     -- R12 MOAC Changes --End
   END LOOP;

   -- push tiers with higher sequence numbers than p_tier_sequence up by one
   update cn_rate_dim_tiers set tier_sequence = tier_sequence + 1
    where rate_dimension_id  = p_rate_dimension_id
      and tier_sequence     >= p_tier_sequence;

   -- create this tier in cn_rate_dim_tiers
   cn_rate_dim_tiers_pkg.insert_row
     (x_rate_dim_tier_id    => x_rate_dim_tier_id,
      x_rate_dimension_id   => p_rate_dimension_id,
      x_minimum_amount      => p_minimum_amount,
      x_maximum_amount      => p_maximum_amount,
      x_min_exp_id          => p_min_exp_id,
      x_max_exp_id          => p_max_exp_id,
      x_string_value        => p_string_value,
      x_tier_sequence       => p_tier_sequence,
      -- R12 MOAC Changes --Start
      x_org_id              => p_org_id
      -- R12 MOAC Changes --End
     );

   -- *********************************************************************
   -- ************ Start - R12 Notes History ************** ***************
   -- *********************************************************************
      if (p_minimum_amount is NOT NULL AND p_maximum_amount is NOT NULL)
      then
          l_from := p_minimum_amount;
          l_to   := p_maximum_amount;
          fnd_message.set_name('CN', 'CNR12_NOTE_RT_DIM_TI_CREATE');
          fnd_message.set_token('FROM', l_from);
          fnd_message.set_token('TO', l_to);
      end if;
      if (p_min_exp_id is NOT NULL AND p_max_exp_id is NOT NULL)
      then
          select name into l_from from cn_calc_sql_exps
          where calc_sql_exp_id = p_min_exp_id;
          select name into l_to from cn_calc_sql_exps
          where calc_sql_exp_id = p_max_exp_id;
          fnd_message.set_name('CN', 'CNR12_NOTE_RT_DIM_TI_CREATE');
          fnd_message.set_token('FROM', l_from);
          fnd_message.set_token('TO', l_to);
      end if;
      if (p_string_value is NOT NULL) then
          fnd_message.set_name('CN', 'CNR12_NOTE_RT_DIM_TI_ST_CREATE');
          fnd_message.set_token('STR_VAL', p_string_value);
      end if;

      l_note_msg := fnd_message.get;

      jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => p_rate_dimension_id,
                            p_source_object_code      => 'CN_RATE_DIMENSIONS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );

   -- *********************************************************************
   -- ************ End - R12 Notes History ********************************
   -- *********************************************************************

   -- update rate dimension (number_tier is treated as a "virtual column" - just a
   -- count(*) of tiers assigned to the rate_dimension... it is not ovn controlled here
   UPDATE cn_rate_dimensions
      SET number_tier = (select count(*) from cn_rate_dim_tiers
	 		 where rate_dimension_id = p_rate_dimension_id)
    WHERE rate_dimension_id = p_rate_dimension_id;

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

END CN_RATE_DIMENSIONS_PVT;

/
