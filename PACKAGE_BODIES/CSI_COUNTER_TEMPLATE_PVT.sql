--------------------------------------------------------
--  DDL for Package Body CSI_COUNTER_TEMPLATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_COUNTER_TEMPLATE_PVT" AS
/* $Header: csivcttb.pls 120.41.12010000.12 2009/11/30 09:37:49 aradhakr ship $ */

-- --------------------------------------------------------
-- Define global variables
-- --------------------------------------------------------

G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSI_COUNTER_TEMPLATE_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csivcttb.pls';

PROCEDURE validate_counter_group
(
   p_name               VARCHAR2,
   p_template_flag      VARCHAR2
) IS

   l_dummy  VARCHAR2(1);
BEGIN
   IF nvl(p_template_flag,'N') =  'Y' THEN
      BEGIN
         SELECT 'x'
         INTO   l_dummy
         FROM   cs_csi_counter_groups
         WHERE  name = p_name
         AND    template_flag = p_template_flag;

         CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_GRP_DUPLICATE');
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
         WHEN OTHERS THEN
            csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_GRP_DUPLICATE');
      END;
   END IF;
END validate_counter_group;

PROCEDURE validate_start_date
(
   p_start_date   DATE
) IS
BEGIN
   IF p_start_date IS NULL THEN
      CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_STDATE_INVALID');
   END IF;
END validate_start_date;

PROCEDURE validate_inventory_item
(
   p_inventory_item_id NUMBER
) IS

   l_dummy VARCHAR2(1);
   l_inv_valdn_org_id NUMBER := fnd_profile.value('CS_INV_VALIDATION_ORG');
BEGIN
   IF p_inventory_item_id IS NOT NULL THEN
      BEGIN
         SELECT 'x'
         INTO   l_dummy
         FROM   mtl_system_items
         WHERE  inventory_item_id = p_inventory_item_id
         AND    organization_id = l_inv_valdn_org_id;
         -- AND    organization_id = cs_std.get_item_valdn_orgzn_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_ITEM_INVALID','INVENTORY_ITEM',p_inventory_item_id,'ORG_ID',l_inv_valdn_org_id);
      END;
   ELSE
      CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_ITEM_ISNULL');
   END IF;
END validate_inventory_item;

PROCEDURE validate_lookups
(
   p_lookup_type   VARCHAR2
   ,p_lookup_code  VARCHAR2
) IS
   l_dummy  VARCHAR2(1);

BEGIN
   BEGIN
      SELECT 'x'
      INTO   l_dummy
      FROM   csi_lookups
      WHERE  lookup_type = p_lookup_type
      AND    lookup_code = p_lookup_code
      OR     meaning= p_lookup_code; --Added for bug #6904836

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_LOOKUP_INVALID','LOOKUP_TYPE',p_lookup_type,'LOOKUP_CODE',p_lookup_code);
   END;
END validate_lookups;

PROCEDURE Validate_Data_Type
(
   p_property_data_type	IN	VARCHAR2,
   p_default_value		IN	VARCHAR2,
   p_minimum_value		IN	VARCHAR2,
   p_maximum_value		IN	VARCHAR2
)
IS
   l_char	VARCHAR2(240);
   l_num	NUMBER;
   l_date	DATE;
   l_default_value	VARCHAR2(240);
   l_minimum_value	VARCHAR2(240);
   l_maximum_value	VARCHAR2(240);
BEGIN
   IF p_default_value = FND_API.G_MISS_CHAR THEN
      l_default_value := NULL;
   END IF;

   IF p_maximum_value = FND_API.G_MISS_CHAR THEN
      l_maximum_value := NULL;
   END IF;

   IF p_minimum_value = FND_API.G_MISS_CHAR THEN
      l_minimum_value := NULL;
   END IF;

   IF p_property_data_type = 'CHAR' THEN
      NULL;
      -- any value is okay even if the values are numbers or dates
      -- they are going to be varchar2
   ELSIF p_property_data_type = 'NUMBER' THEN
      l_num :=	l_default_value;
      l_num :=	l_minimum_value;
      l_num :=	l_maximum_value;
   ELSIF p_property_data_type = 'DATE' THEN
      l_date :=	l_default_value;
      l_date :=	l_minimum_value;
      l_date :=	l_maximum_value;
   ELSE
      CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_PROP_DATA_TYPE');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_VAL_DATATYPE','DATA_TYPE',p_property_data_type);
END Validate_Data_Type;

PROCEDURE validate_uom
(
   p_uom_code varchar2
) IS

   l_dummy	varchar2(1);
BEGIN
   SELECT 'x'
   INTO   l_dummy
   FROM   mtl_units_of_measure
   WHERE  uom_code = p_uom_code;
EXCEPTION
   WHEN no_data_found THEN
      CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_INVALID_UOM_CODE','UNIT_OF_MEASURE',p_uom_code);
END validate_uom;

PROCEDURE validate_ctr_relationship
(
   p_counter_id  IN NUMBER,
   x_direction   OUT NOCOPY VARCHAR2,
   x_start_date  OUT NOCOPY DATE,
   x_end_date    OUT NOCOPY DATE
) IS

   l_direction   varchar2(1);

BEGIN
   SELECT direction, start_date_active, end_date_active
   INTO   x_direction, x_start_date, x_end_date
   FROM   csi_counters_b
   WHERE  counter_id = p_counter_id;

EXCEPTION
   WHEN no_data_found THEN
      CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_INVALID_COUNTER');
END validate_ctr_relationship;

PROCEDURE Validate_Counter
(
   p_group_id                 NUMBER
   ,p_name                    VARCHAR2
   ,p_counter_type            VARCHAR2
   ,p_uom_code                VARCHAR2
   ,p_usage_item_id           NUMBER
   ,p_reading_type            NUMBER
   ,p_direction               VARCHAR2
   ,p_estimation_id           NUMBER
   ,p_derive_function         VARCHAR2
   ,p_formula_text            VARCHAR2
   ,p_derive_counter_id       NUMBER
   ,p_filter_type             VARCHAR2
   ,p_filter_reading_count    NUMBER
   ,p_filter_time_uom         VARCHAR2
   ,p_automatic_rollover      VARCHAR2
   ,p_rollover_last_reading   NUMBER
   ,p_rollover_first_reading  NUMBER
   ,p_tolerance_plus          NUMBER
   ,p_tolerance_minus         NUMBER
   ,p_used_in_scheduling      VARCHAR2
   ,p_initial_reading         NUMBER
   ,p_default_usage_rate      NUMBER
   ,p_use_past_reading        NUMBER
   ,p_counter_id              NUMBER
   ,p_start_date_active       DATE
   ,p_end_date_active         DATE
   ,p_update_flag             VARCHAR2
)  IS

   l_dummy	    varchar2(1);
   l_exists	    varchar2(1);
   l_time_uom       varchar2(1);
   l_ctr_type_valid varchar2(1);
   l_inv_valdn_org_id NUMBER := fnd_profile.value('CS_INV_VALIDATION_ORG');
BEGIN
  -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   -- validate counter name is not null
   if p_name is null then
      CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_REQ_PARM_CTR_NAME');
   else
	--Changed for Bug 7462345, validating the name while update
         BEGIN
            SELECT 'x'
            INTO   l_exists
            FROM   csi_counter_template_vl
            WHERE  upper(name) = upper(p_name)
            AND    Nvl(group_id, FND_API.G_MISS_NUM) = Nvl(p_group_id, FND_API.G_MISS_NUM)-- Added for bug 9088368
	          AND COUNTER_ID <> Nvl(p_counter_id, FND_API.G_MISS_NUM);
            csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_DUP_NAME','CTR_NAME',p_name);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
            WHEN TOO_MANY_ROWS THEN
               csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_DUP_NAME','CTR_NAME',p_name);
         END;

   END IF;

   -- validate uom code
   validate_uom(p_uom_code);

   --validate Usage item id
   if p_usage_item_id is not null then
      begin
         select 'x'
         into   l_dummy
         from   mtl_system_items
         where  inventory_item_id = p_usage_item_id
         and    organization_id = l_inv_valdn_org_id
         -- and    organization_id = cs_std.get_item_valdn_orgzn_id
         and    usage_item_flag = 'Y';
      exception
         when no_data_found then
            CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_USAGE_ITEM');
      end;

      if p_group_id is null then
         CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_REQ_PARM_GRP_NAME');
      end if;
   end if;

   -- validate counter group id
   if p_group_id is not null then
      begin
         select 'x'
	 into   l_dummy
         from   cs_csi_counter_groups
         where  counter_group_id = p_group_id;
      exception
         when no_data_found then
            CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_GRP_INVALID');
      end;
   end if;

   --validate estimation id exists only if direction is not null
   if p_estimation_id is not null and p_direction is null then
      CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_EST_NO_DIRECTION');
   end if;

   -- Validate that automatic rollover should not exist if direction is Bi-Direction
   if nvl(p_automatic_rollover,'N') = 'Y' and p_direction not in ('A','D') then
      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_ARO_NO_DIRECTION');
   end if;

   --validate tolerance plus and tolerance minus for negative values
   if p_tolerance_plus < 0  or p_tolerance_minus <0 then
      CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_TOLERANCE');
   end if;

   --validate counter type
   IF p_counter_type IS NULL THEN
      CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INVALID_CTR_TYPE');
   ELSE
      BEGIN
         select 'x'
         into   l_ctr_type_valid
         from   csi_lookups
         where  lookup_type = 'CSI_COUNTER_TYPE'
         and    lookup_code = p_counter_type;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INVALID_CTR_TYPE');
      END;
   end if;

   --validate counter type parameters
   if p_counter_type = 'REGULAR' then
      begin
         select 'Y'
         into   l_time_uom
         from   mtl_units_of_measure
         where  uom_code = p_uom_code
         and    upper(UOM_CLASS) = 'TIME';
      exception
         when no_data_found then
            l_time_uom := 'N';
      end;

      if l_time_uom = 'N' then
         if p_reading_type not in (1,2) then
         csi_ctr_gen_utility_pvt.put_line(' Regular ');
         CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_REQ_PARM_CTR_TYPE','PARAM','p_reading_type','CTR_TYPE',p_counter_type);
         end if;

         if p_derive_function is not null or
            p_formula_text is not null or
            p_derive_counter_id is not null or
            p_filter_type is not null or
            p_filter_reading_count is not null or
            p_filter_time_uom is not null  then

            CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_PARM_CTR_TYPE','CTR_TYPE',p_counter_type);
         end if;

         --validate required parameter values exist for automatic rollover
         if nvl(p_automatic_rollover,'N') = 'Y' then
           if p_rollover_last_reading is null then
             csi_ctr_gen_utility_pvt.ExitWithErrMsg
             ( p_msg_name     =>  'CSI_API_CTR_REQ_PARM',
               p_token1_name  =>  'PARAM',
               p_token1_val   =>  'for rollover attribute'
             );
           elsif p_rollover_first_reading is null then
             csi_ctr_gen_utility_pvt.ExitWithErrMsg
             ( p_msg_name     =>  'CSI_API_CTR_REQ_PARM',
               p_token1_name  =>  'PARAM',
               p_token1_val   =>  'for rollover attribute'
               -- p_token1_val   =>  'p_rollover_first_reading'
             );
           end if;
           --Rollover from must be greater than Rollover to for direction Ascending
           if  p_direction = 'A' and p_rollover_last_reading <= p_rollover_first_reading then
             csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_INV_RO_DATA');
           end if;
            --Rollover from must be less than Rollover to for direction Descending
           if p_direction = 'D' and p_rollover_last_reading >= p_rollover_first_reading then
             csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_INV_RO_DATA');
           end if;
        end if;
        -- Rollover from and Rollover to field should not have values if automatic rollover is not checked.
        if nvl(p_automatic_rollover,'N') = 'N' and (p_rollover_last_reading is NOT NULL or p_rollover_first_reading IS NOT NULL) then
           csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_INV_RO_ARO');
        end if;

         --validate if required parameter values exist for used in scheduling
         if nvl(p_used_in_scheduling,'N') = 'Y' then
            if p_initial_reading is null then
               CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_REQ_PARM_USE_SCHD');
            elsif p_default_usage_rate  is null then
               CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_REQ_PARM_USE_SCHD');
            elsif p_use_past_reading is null then
               CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_REQ_PARM_USE_SCHD');
            end if;
         end if;
      else -- if type is a time counter
         if p_derive_function is not null or
            p_formula_text is not null or
            p_derive_counter_id is not null or
            p_filter_type is not null or
            p_filter_reading_count is not null or
            p_filter_time_uom is not null or
            nvl(p_automatic_rollover,'N') = 'Y' or
            p_rollover_last_reading is not null or
            p_rollover_first_reading is not null or
            p_tolerance_plus is not null or
            p_tolerance_minus is not null or
            p_estimation_id is not null
         then
            csi_ctr_gen_utility_pvt.put_line(' Time ');
            CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_PARM_CTR_TYPE','CTR_TYPE',p_counter_type);
         end if;

         if nvl(p_used_in_scheduling,'N') = 'Y' then
            if p_initial_reading is null then
               CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_REQ_PARM_USE_SCHD');
            elsif p_default_usage_rate  is null then
               CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_REQ_PARM_USE_SCHD');
            elsif p_use_past_reading is null then
               CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_REQ_PARM_USE_SCHD');
            end if;
         end if;

      end if; --l_time_uom
   elsif p_counter_type = 'FORMULA' then
      if p_derive_function is null then
         if p_formula_text is null then
            CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_REQ_PARM_FORMULA');
         end if;

         if p_derive_counter_id is not null or
            p_filter_type is not null or
            p_filter_reading_count is not null or
            p_filter_time_uom is not null or
            nvl(p_automatic_rollover,'N') = 'Y' or
            p_rollover_last_reading is not null or
            p_rollover_first_reading is not null or
            p_initial_reading is not null
            -- p_tolerance_plus is not null or
            -- p_tolerance_minus is not null
         then
            csi_ctr_gen_utility_pvt.put_line(' Formula');
            CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_PARM_CTR_TYPE','CTR_TYPE',p_counter_type);
         end if;
      elsif p_derive_function='AVERAGE' and p_filter_type='COUNT' then
         if p_filter_reading_count < 0 then
            CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_REQ_PARM_FORMULA');
         end if;

         if p_formula_text is not null or
            p_filter_time_uom is not null or
            nvl(p_automatic_rollover,'N') = 'Y' or
            p_rollover_last_reading is not null or
            p_rollover_first_reading is not null or
            nvl(p_used_in_scheduling,'N') = 'Y' or
            p_initial_reading is not null or
            -- p_default_usage_rate is not null or
            -- p_use_past_reading is not null  or
            p_estimation_id is not null
            -- p_tolerance_plus is not null or
            -- p_tolerance_minus is not null
         then
            csi_ctr_gen_utility_pvt.put_line(' Failed Average and Count');
            CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_PARM_CTR_TYPE','CTR_TYPE',p_counter_type);
         end if;
      elsif p_derive_function='AVERAGE' and p_filter_type='TIME' then
         if p_filter_time_uom is null then
            CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_REQ_PARM_FORMULA');
         end if;

         if p_formula_text is not null or
            p_filter_reading_count is not null or
            nvl(p_automatic_rollover,'N') = 'Y' or
            p_rollover_last_reading is not null or
            p_rollover_first_reading is not null or
            nvl(p_used_in_scheduling,'N') = 'Y' or
            p_initial_reading is not null or
            -- p_default_usage_rate is not null or
            -- p_use_past_reading is not null  or
            p_estimation_id is not null
            -- p_tolerance_plus is not null or
            -- p_tolerance_minus is not null
         then
            csi_ctr_gen_utility_pvt.put_line(' Failed Average and Time');
            CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_PARM_CTR_TYPE','CTR_TYPE',p_counter_type);
         end if;
      elsif p_derive_function in ('SUM','COUNT') then
         /* if p_derive_counter_id is null then
            CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_REQ_PARM_FORMULA');
         end if;
        */

         if p_formula_text is not null or
            p_filter_time_uom is not null or
            p_filter_reading_count is not null or
            nvl(p_automatic_rollover,'N') = 'Y' or
            p_rollover_last_reading is not null or
            p_rollover_first_reading is not null or
            nvl(p_used_in_scheduling,'N') = 'Y' or
            p_initial_reading is not null or
            -- p_default_usage_rate is not null or
            -- p_use_past_reading is not null  or
            p_estimation_id is not null
            -- p_tolerance_plus is not null or
            -- p_tolerance_minus is not null
         then
            csi_ctr_gen_utility_pvt.put_line(' Failed Sum and Count');
            CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_PARM_CTR_TYPE','CTR_TYPE',p_counter_type);
         end if;
      end if;
   end if; -- p_counter_type

END validate_counter;

PROCEDURE create_counter_group
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_counter_groups_rec        IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.counter_groups_rec
    ,x_return_status                OUT    NOCOPY VARCHAR2
    ,x_msg_count                    OUT    NOCOPY NUMBER
    ,x_msg_data                     OUT    NOCOPY VARCHAR2
 ) IS
   l_api_name                     CONSTANT VARCHAR2(30)   := 'CREATE_COUNTER_GROUP';
   l_api_version                  CONSTANT NUMBER         := 1.0;
   l_msg_data                     VARCHAR2(2000);
   l_msg_index                    NUMBER;
   l_msg_count                    NUMBER;
   -- l_debug_level                  NUMBER;


   l_COUNTER_GROUP_ID 		  NUMBER;
   l_NAME                         VARCHAR2(100);
   l_DESCRIPTION                  VARCHAR2(240);
   l_TEMPLATE_FLAG                VARCHAR2(1);
   -- l_CP_SERVICE_ID                NUMBER;
   -- l_CUSTOMER_PRODUCT_ID          NUMBER;
   l_LAST_UPDATE_DATE             DATE;
   l_LAST_UPDATED_BY              NUMBER;
   l_CREATION_DATE                DATE;
   l_CREATED_BY                   NUMBER;
   l_LAST_UPDATE_LOGIN            NUMBER;
   l_START_DATE_ACTIVE            DATE;
   l_END_DATE_ACTIVE              DATE;
   l_ATTRIBUTE1                   VARCHAR2(150);
   l_ATTRIBUTE2                   VARCHAR2(150);
   l_ATTRIBUTE3                   VARCHAR2(150);
   l_ATTRIBUTE4                   VARCHAR2(150);
   l_ATTRIBUTE5                   VARCHAR2(150);
   l_ATTRIBUTE6                   VARCHAR2(150);
   l_ATTRIBUTE7                   VARCHAR2(150);
   l_ATTRIBUTE8                   VARCHAR2(150);
   l_ATTRIBUTE9                   VARCHAR2(150);
   l_ATTRIBUTE10                  VARCHAR2(150);
   l_ATTRIBUTE11                  VARCHAR2(150);
   l_ATTRIBUTE12                  VARCHAR2(150);
   l_ATTRIBUTE13                  VARCHAR2(150);
   l_ATTRIBUTE14                  VARCHAR2(150);
   l_ATTRIBUTE15                  VARCHAR2(150);
   l_CONTEXT                      VARCHAR2(30);
   l_OBJECT_VERSION_NUMBER        NUMBER;
   l_CREATED_FROM_CTR_GRP_TMPL_ID NUMBER;
   l_ASSOCIATION_TYPE             VARCHAR2(30);
   l_SOURCE_OBJECT_CODE           VARCHAR2(30);
   l_SOURCE_OBJECT_ID             NUMBER;
   l_SOURCE_COUNTER_GROUP_ID      NUMBER;
   l_SECURITY_GROUP_ID            NUMBER;
   l_UPGRADED_STATUS_FLAG         VARCHAR2(1);
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  create_counter_group_pvt;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   --
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line
         ('create_counter_group_pvt'              ||'-'||
           p_api_version                              ||'-'||
           nvl(p_commit,FND_API.G_FALSE)              ||'-'||
           nvl(p_init_msg_list,FND_API.G_FALSE)       ||'-'||
           nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL) );
   END IF;

   ----
   -- Initialize_Desc_Flex(p_ctr_grp_rec.desc_flex, l_desc_flex);

   -- validate_DFF_ReqdParms(l_api_name, l_desc_flex, 'CS_COUNTER_GROUPS',
	--  		  p_ctr_grp_rec.name, 'p_ctr_grp_rec.name',
	--		  p_ctr_grp_rec.association_type, 'p_ctr_grp_rec.association_type');

   l_name := p_counter_groups_rec.name;


   IF p_counter_groups_rec.description = FND_API.G_MISS_CHAR then
      l_description := null;
   ELSE
      l_description := p_counter_groups_rec.description;
   END IF;

   IF p_counter_groups_rec.template_flag = FND_API.G_MISS_CHAR then
      l_template_flag := 'N';
   ELSE
      l_template_flag := nvl(p_counter_groups_rec.template_flag,'N');
   END IF;

   validate_counter_group(l_name, l_template_flag);

   IF p_counter_groups_rec.association_type = FND_API.G_MISS_CHAR then
      l_association_type := null;
   ELSE
      l_association_type := p_counter_groups_rec.association_type;
   END IF;

   if nvl(p_counter_groups_rec.start_date_active,FND_API.G_MISS_DATE) = FND_API.G_MISS_DATE then
      l_start_date_active := sysdate;
   else
      l_start_date_active := p_counter_groups_rec.start_date_active;
   end if;

   validate_start_date(l_start_date_active);

   if p_counter_groups_rec.end_date_active = FND_API.G_MISS_DATE then
      l_end_date_active := null;
   else
      l_end_date_active := p_counter_groups_rec.end_date_active;
   end if;

   if l_end_date_active IS NOT NULL then
      if l_end_date_active < l_start_date_active then
         CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_ALL_END_DATE');
      end if;
   end if;

   if p_counter_groups_rec.attribute1 = FND_API.G_MISS_CHAR then
      l_attribute1 := null;
   else
      l_attribute1 := p_counter_groups_rec.attribute1;
   end if;

   if p_counter_groups_rec.attribute2 = FND_API.G_MISS_CHAR then
      l_attribute2 := null;
   else
      l_attribute2 := p_counter_groups_rec.attribute2;
   end if;

   if p_counter_groups_rec.attribute3 = FND_API.G_MISS_CHAR then
      l_attribute3 := null;
   else
      l_attribute3 := p_counter_groups_rec.attribute3;
   end if;

   if p_counter_groups_rec.attribute4 = FND_API.G_MISS_CHAR then
      l_attribute4 := null;
   else
      l_attribute4 := p_counter_groups_rec.attribute4;
   end if;

   if p_counter_groups_rec.attribute5 = FND_API.G_MISS_CHAR then
      l_attribute5 := null;
   else
      l_attribute5 := p_counter_groups_rec.attribute5;
   end if;

   if p_counter_groups_rec.attribute6 = FND_API.G_MISS_CHAR then
      l_attribute6 := null;
   else
      l_attribute6 := p_counter_groups_rec.attribute6;
   end if;

   if p_counter_groups_rec.attribute7 = FND_API.G_MISS_CHAR then
      l_attribute7 := null;
   else
      l_attribute7 := p_counter_groups_rec.attribute7;
   end if;

   if p_counter_groups_rec.attribute8 = FND_API.G_MISS_CHAR then
      l_attribute8 := null;
   else
      l_attribute8 := p_counter_groups_rec.attribute8;
   end if;

   if p_counter_groups_rec.attribute9 = FND_API.G_MISS_CHAR then
      l_attribute9 := null;
   else
      l_attribute9 := p_counter_groups_rec.attribute9;
   end if;

   if p_counter_groups_rec.attribute10 = FND_API.G_MISS_CHAR then
      l_attribute10 := null;
   else
      l_attribute10 := p_counter_groups_rec.attribute10;
   end if;

   if p_counter_groups_rec.attribute11 = FND_API.G_MISS_CHAR then
      l_attribute11 := null;
   else
      l_attribute11 := p_counter_groups_rec.attribute11;
   end if;

   if p_counter_groups_rec.attribute12 = FND_API.G_MISS_CHAR then
      l_attribute12 := null;
   else
      l_attribute12 := p_counter_groups_rec.attribute12;
   end if;

   if p_counter_groups_rec.attribute13 = FND_API.G_MISS_CHAR then
      l_attribute13 := null;
   else
      l_attribute13 := p_counter_groups_rec.attribute13;
   end if;

   if p_counter_groups_rec.attribute14 = FND_API.G_MISS_CHAR then
      l_attribute14 := null;
   else
      l_attribute14 := p_counter_groups_rec.attribute14;
   end if;

   if p_counter_groups_rec.attribute15 = FND_API.G_MISS_CHAR then
      l_attribute15 := null;
   else
      l_attribute15 := p_counter_groups_rec.attribute15;
   end if;

   if p_counter_groups_rec.context = FND_API.G_MISS_CHAR then
      l_context := null;
   else
      l_context := p_counter_groups_rec.context;
   end if;

   if p_counter_groups_rec.created_from_ctr_grp_tmpl_id = FND_API.G_MISS_NUM then
      l_created_from_ctr_grp_tmpl_id := null;
   else
      l_created_from_ctr_grp_tmpl_id := p_counter_groups_rec.created_from_ctr_grp_tmpl_id;
   end if;

   --Code added for bug 8326815 -Start
   l_source_object_code:=p_counter_groups_rec.SOURCE_OBJECT_CODE;
   l_source_object_id:=p_counter_groups_rec.SOURCE_OBJECT_ID;
   l_SOURCE_COUNTER_GROUP_ID:=p_counter_groups_rec.SOURCE_COUNTER_GROUP_ID;
   --Code added for bug 8326815 -End

   -- IF NOT(CS_COUNTERS_EXT_PVT.Is_StartEndDate_Valid(l_st_dt,l_end_dt)) THEN
      -- RAISE FND_API.G_EXC_ERROR;
   -- END IF;

   /* Call the table Handler */
   CSI_GROUPING_PKG.Insert_Row(
        px_COUNTER_GROUP_ID 		=> l_counter_group_id
        ,p_NAME                         => l_name
        ,p_DESCRIPTION                  => l_description
        ,p_TEMPLATE_FLAG                => l_template_flag
        ,p_CP_SERVICE_ID                => NULL
        ,p_CUSTOMER_PRODUCT_ID          => NULL
        ,p_LAST_UPDATE_DATE             => sysdate
        ,p_LAST_UPDATED_BY              => FND_GLOBAL.USER_ID
        ,p_CREATION_DATE                => sysdate
        ,p_CREATED_BY                   => FND_GLOBAL.USER_ID
        ,p_LAST_UPDATE_LOGIN            => FND_GLOBAL.USER_ID
        ,p_START_DATE_ACTIVE            => l_start_date_active
        ,p_END_DATE_ACTIVE              => l_end_date_active
        ,p_ATTRIBUTE1                   => l_attribute1
        ,p_ATTRIBUTE2                   => l_attribute2
        ,p_ATTRIBUTE3                   => l_attribute3
        ,p_ATTRIBUTE4                   => l_attribute4
        ,p_ATTRIBUTE5                   => l_attribute5
        ,p_ATTRIBUTE6                   => l_attribute6
        ,p_ATTRIBUTE7                   => l_attribute7
        ,p_ATTRIBUTE8                   => l_attribute8
        ,p_ATTRIBUTE9                   => l_attribute9
        ,p_ATTRIBUTE10                  => l_attribute10
        ,p_ATTRIBUTE11                  => l_attribute11
        ,p_ATTRIBUTE12                  => l_attribute12
        ,p_ATTRIBUTE13                  => l_attribute13
        ,p_ATTRIBUTE14                  => l_attribute14
        ,p_ATTRIBUTE15                  => l_attribute15
        ,p_CONTEXT                      => l_context
        ,p_OBJECT_VERSION_NUMBER        => 1
	,p_CREATED_FROM_CTR_GRP_TMPL_ID => l_created_from_ctr_grp_tmpl_id
	,p_ASSOCIATION_TYPE             => l_association_type
	,p_SOURCE_OBJECT_CODE           => l_source_object_code
	,p_SOURCE_OBJECT_ID             => l_source_object_id
	,p_SOURCE_COUNTER_GROUP_ID      => l_source_counter_group_id
	,p_SECURITY_GROUP_ID            => l_security_group_id
        );

   p_counter_groups_rec.counter_group_id := l_counter_group_id;

   IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
        ROLLBACK TO create_counter_group_pvt;
        RETURN;
   END IF;

   /* End of table handler call */

   IF FND_API.to_Boolean(nvl(p_commit,FND_API.G_FALSE)) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and IF count is  get message info.
   FND_MSG_PUB.Count_And_Get
      ( p_count  =>  x_msg_count,
        p_data   =>  x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO create_counter_group_pvt;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_counter_group_pvt;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_counter_group_pvt;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg
            ( G_PKG_NAME,
              l_api_name
            );
      END IF;
      FND_MSG_PUB.Count_And_Get
         ( p_count  => x_msg_count,
           p_data   => x_msg_data
         );
END create_counter_group;

--|---------------------------------------------------
--| procedure name: create_item_association
--| description :   procedure used to
--|                 create item association to
--|                 counter group or counters
--|---------------------------------------------------

PROCEDURE create_item_association
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_ctr_item_associations_rec IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_item_associations_rec
    ,x_return_status                OUT    NOCOPY VARCHAR2
    ,x_msg_count                    OUT    NOCOPY NUMBER
    ,x_msg_data                     OUT    NOCOPY VARCHAR2
 ) IS
   l_api_name                     CONSTANT VARCHAR2(30)   := 'CREATE_ITEM_ASSOCIATION';
   l_api_version                  CONSTANT NUMBER         := 1.0;
   l_msg_data                     VARCHAR2(2000);
   l_msg_index                    NUMBER;
   l_msg_count                    NUMBER;
   -- l_debug_level                  NUMBER;

   l_CTR_ASSOCIATION_ID		  NUMBER;
   l_GROUP_ID		          NUMBER;
   l_INVENTORY_ITEM_ID            NUMBER;
   l_LAST_UPDATE_DATE             DATE;
   l_LAST_UPDATED_BY              NUMBER;
   l_CREATION_DATE                DATE;
   l_CREATED_BY                   NUMBER;
   l_LAST_UPDATE_LOGIN            NUMBER;
   l_START_DATE_ACTIVE            DATE;
   l_END_DATE_ACTIVE              DATE;
   l_ATTRIBUTE1                   VARCHAR2(150);
   l_ATTRIBUTE2                   VARCHAR2(150);
   l_ATTRIBUTE3                   VARCHAR2(150);
   l_ATTRIBUTE4                   VARCHAR2(150);
   l_ATTRIBUTE5                   VARCHAR2(150);
   l_ATTRIBUTE6                   VARCHAR2(150);
   l_ATTRIBUTE7                   VARCHAR2(150);
   l_ATTRIBUTE8                   VARCHAR2(150);
   l_ATTRIBUTE9                   VARCHAR2(150);
   l_ATTRIBUTE10                  VARCHAR2(150);
   l_ATTRIBUTE11                  VARCHAR2(150);
   l_ATTRIBUTE12                  VARCHAR2(150);
   l_ATTRIBUTE13                  VARCHAR2(150);
   l_ATTRIBUTE14                  VARCHAR2(150);
   l_ATTRIBUTE15                  VARCHAR2(150);
   l_ATTRIBUTE_CATEGORY           VARCHAR2(30);
   l_OBJECT_VERSION_NUMBER        NUMBER;
   l_COUNTER_ID			  NUMBER;
   l_USE_PAST_READING             NUMBER;
   l_USAGE_RATE                   NUMBER;
   l_MAINT_ORGANIZATION_ID        NUMBER;
   l_ASSOCIATED_TO_GROUP          VARCHAR2(1);
   l_SECURITY_GROUP_ID            NUMBER;
   l_MIGRATED_FLAG                VARCHAR2(1);
   l_ITEM_FOUND                   VARCHAR2(1);
   l_ITEM_INVALID                 VARCHAR2(1);
   l_PRIMARY_FAILURE_FLAG         VARCHAR2(1);
   l_eam_item_type                NUMBER;
   l_valid_start_date             DATE;

   CURSOR c1_group(p_group_id NUMBER) IS
   select start_date_active
   from   cs_csi_counter_groups
   where  counter_group_id = p_group_id;

   CURSOR c2_counter(p_counter_id NUMBER) IS
   select start_date_active
   from   csi_counter_template_b
   where  counter_id = p_counter_id;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  create_item_association_pvt;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line
         ( 'create_item_association_pvt'           ||'-'||
           p_api_version                              ||'-'||
           nvl(p_commit,FND_API.G_FALSE)              ||'-'||
           nvl(p_init_msg_list,FND_API.G_FALSE)       ||'-'||
           nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL) );
   END IF;

   if p_ctr_item_associations_rec.group_id = FND_API.G_MISS_NUM then
      l_group_id := null;
   else
      l_group_id := p_ctr_item_associations_rec.group_id;
   end if;

   if p_ctr_item_associations_rec.inventory_item_id = FND_API.G_MISS_NUM then
      l_inventory_item_id := null;
   else
      l_inventory_item_id := p_ctr_item_associations_rec.inventory_item_id;
   end if;

   if p_ctr_item_associations_rec.associated_to_group= FND_API.G_MISS_CHAR then
      l_associated_to_group := 'N';
   else
      l_associated_to_group := p_ctr_item_associations_rec.associated_to_group;
   end if;

   if p_ctr_item_associations_rec.counter_id = FND_API.G_MISS_NUM then
      l_counter_id := null;
   else
      l_counter_id := p_ctr_item_associations_rec.counter_id;
   end if;

   if p_ctr_item_associations_rec.security_group_id = FND_API.G_MISS_NUM then
      l_security_group_id := null;
   else
      l_security_group_id := p_ctr_item_associations_rec.security_group_id;
   end if;

   if p_ctr_item_associations_rec.use_past_reading = FND_API.G_MISS_NUM then
      l_use_past_reading := null;
   else
      l_use_past_reading := p_ctr_item_associations_rec.use_past_reading;
   end if;

   if p_ctr_item_associations_rec.usage_rate = FND_API.G_MISS_NUM then
      l_usage_rate := null;
   else
      l_usage_rate := p_ctr_item_associations_rec.usage_rate;
   end if;

   if nvl(p_ctr_item_associations_rec.start_date_active, FND_API.G_MISS_DATE) = FND_API.G_MISS_DATE then
      l_start_date_active := sysdate;
   else
      l_start_date_active := p_ctr_item_associations_rec.start_date_active;
   end if;

   validate_start_date(l_start_date_active);

   IF l_start_date_active > sysdate THEN
      CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_GRP_FUT_DATE');
   END IF;

   IF l_associated_to_group = 'Y' THEN
      OPEN c1_group(l_group_id);
      FETCH c1_group INTO l_valid_start_date;

      IF l_start_date_active < l_valid_start_date THEN
         csi_ctr_gen_utility_pvt.ExitWithErrMsg
             ( p_msg_name     =>  'CSI_API_CTR_VAL_ST_DATE',
               p_token1_name  =>  'PARAM',
               p_token1_val   =>  'The item association start date cannot be less than the active start date of the counter group.');
      END IF;
      CLOSE c1_group;
   ELSE
      OPEN c2_counter(l_counter_id);
      FETCH c2_counter INTO l_valid_start_date;

      IF l_start_date_active < l_valid_start_date THEN
         csi_ctr_gen_utility_pvt.ExitWithErrMsg
             ( p_msg_name     =>  'CSI_API_CTR_VAL_ST_DATE',
               p_token1_name  =>  'PARAM',
               p_token1_val   =>  'The item association start date cannot be less than the active start date of the counter.');
      END IF;
      CLOSE c2_counter;
   END IF;

   if p_ctr_item_associations_rec.end_date_active = FND_API.G_MISS_DATE then
      l_end_date_active := null;
   else
      l_end_date_active := p_ctr_item_associations_rec.end_date_active;
   end if;

   if l_end_date_active IS NOT NULL then
      if l_end_date_active < l_start_date_active then
         CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_ALL_END_DATE');
      end if;
   end if;

   if p_ctr_item_associations_rec.attribute1 = FND_API.G_MISS_CHAR then
      l_attribute1 := null;
   else
      l_attribute1 := p_ctr_item_associations_rec.attribute1;
   end if;

   if p_ctr_item_associations_rec.attribute2 = FND_API.G_MISS_CHAR then
      l_attribute2 := null;
   else
      l_attribute2 := p_ctr_item_associations_rec.attribute2;
   end if;

   if p_ctr_item_associations_rec.attribute3 = FND_API.G_MISS_CHAR then
      l_attribute3 := null;
   else
      l_attribute3 := p_ctr_item_associations_rec.attribute3;
   end if;

   if p_ctr_item_associations_rec.attribute4 = FND_API.G_MISS_CHAR then
      l_attribute4 := null;
   else
      l_attribute4 := p_ctr_item_associations_rec.attribute4;
   end if;

   if p_ctr_item_associations_rec.attribute5 = FND_API.G_MISS_CHAR then
      l_attribute5 := null;
   else
      l_attribute5 := p_ctr_item_associations_rec.attribute5;
   end if;

   if p_ctr_item_associations_rec.attribute6 = FND_API.G_MISS_CHAR then
      l_attribute6 := null;
   else
      l_attribute6 := p_ctr_item_associations_rec.attribute6;
   end if;

   if p_ctr_item_associations_rec.attribute7 = FND_API.G_MISS_CHAR then
      l_attribute7 := null;
   else
      l_attribute7 := p_ctr_item_associations_rec.attribute7;
   end if;

   if p_ctr_item_associations_rec.attribute8 = FND_API.G_MISS_CHAR then
      l_attribute8 := null;
   else
      l_attribute8 := p_ctr_item_associations_rec.attribute8;
   end if;

   if p_ctr_item_associations_rec.attribute9 = FND_API.G_MISS_CHAR then
      l_attribute9 := null;
   else
      l_attribute9 := p_ctr_item_associations_rec.attribute9;
   end if;

   if p_ctr_item_associations_rec.attribute10 = FND_API.G_MISS_CHAR then
      l_attribute10 := null;
   else
      l_attribute10 := p_ctr_item_associations_rec.attribute10;
   end if;

   if p_ctr_item_associations_rec.attribute11 = FND_API.G_MISS_CHAR then
      l_attribute11 := null;
   else
      l_attribute11 := p_ctr_item_associations_rec.attribute11;
   end if;

   if p_ctr_item_associations_rec.attribute12 = FND_API.G_MISS_CHAR then
      l_attribute12 := null;
   else
      l_attribute12 := p_ctr_item_associations_rec.attribute12;
   end if;

   if p_ctr_item_associations_rec.attribute13 = FND_API.G_MISS_CHAR then
      l_attribute13 := null;
   else
      l_attribute13 := p_ctr_item_associations_rec.attribute13;
   end if;

   if p_ctr_item_associations_rec.attribute14 = FND_API.G_MISS_CHAR then
      l_attribute14 := null;
   else
      l_attribute14 := p_ctr_item_associations_rec.attribute14;
   end if;

   if p_ctr_item_associations_rec.attribute15 = FND_API.G_MISS_CHAR then
      l_attribute15 := null;
   else
      l_attribute15 := p_ctr_item_associations_rec.attribute15;
   end if;

   if p_ctr_item_associations_rec.attribute_category = FND_API.G_MISS_CHAR then
      l_attribute_category := null;
   else
      l_attribute_category := p_ctr_item_associations_rec.attribute_category;
   end if;

   if p_ctr_item_associations_rec.migrated_flag = FND_API.G_MISS_CHAR then
      l_migrated_flag := null;
   else
      l_migrated_flag := p_ctr_item_associations_rec.migrated_flag;
   end if;

   if p_ctr_item_associations_rec.maint_organization_id = FND_API.G_MISS_NUM then
      l_maint_organization_id := null;
   else
      l_maint_organization_id := p_ctr_item_associations_rec.maint_organization_id;
   end if;

   if p_ctr_item_associations_rec.primary_failure_flag = FND_API.G_MISS_CHAR then
      l_primary_failure_flag := null;
   else
      l_primary_failure_flag := p_ctr_item_associations_rec.primary_failure_flag;
   end if;

   validate_start_date(l_start_date_active);

   /* Check if the item is an EAM item */
   BEGIN
      SELECT distinct nvl(eam_item_type,0) eam_item_type
      INTO   l_eam_item_type
      FROM   mtl_system_items_b
      WHERE  inventory_item_id = l_inventory_item_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_eam_item_type := 0;
   END;

   IF l_eam_item_type = 0 THEN
      validate_inventory_item(l_inventory_item_id);
   END IF;
   /* end of EAM item checking */

   IF l_group_id IS NOT NULL THEN
      IF l_associated_to_group = 'Y' and l_counter_id IS NULL THEN
         BEGIN
            SELECT 'x'
            INTO   l_item_invalid
            FROM   csi_ctr_item_associations
            WHERE  inventory_item_id = l_inventory_item_id
            AND    nvl(associated_to_group,'N') = 'Y';

            CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_ITEM_ASSOC');
         EXCEPTION
            WHEN NO_DATA_FOUND THEN NULL;
            WHEN TOO_MANY_ROWS THEN
               CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_ITEM_ASSOC');
         END;
      END IF;
   END IF;

   IF l_associated_to_group = 'Y' THEN
      IF l_group_id IS NOT NULL THEN
         BEGIN
            SELECT 'x'
            INTO   l_item_invalid
            FROM   csi_ctr_item_associations
            WHERE  inventory_item_id = l_inventory_item_id
            AND    associated_to_group = l_associated_to_group
            -- AND    group_id = l_group_id
            AND    counter_id = l_counter_id;

            CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_ITEM_ASSOC');
         EXCEPTION
            WHEN NO_DATA_FOUND THEN NULL;
            WHEN TOO_MANY_ROWS THEN
               CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_ITEM_ASSOC');
         END;
      ELSE
         CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_REQ_PARM_GRP_NAME');
      END IF;
   ELSE
      IF l_group_id IS NULL THEN
         IF l_counter_id IS NULL THEN
            CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_CTR_ID');
         END IF;

         BEGIN
            SELECT 'Y'
            INTO   l_item_found
            FROM   csi_ctr_item_associations
            WHERE  inventory_item_id = l_inventory_item_id
            AND    associated_to_group = 'Y';

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               l_item_found := 'N';
            WHEN TOO_MANY_ROWS THEN
               l_item_found := 'Y';
         END;

         IF l_item_found = 'Y' THEN
            CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_ITEM_ASSOC');
         ELSE
            BEGIN
               SELECT 'x'
               INTO   l_item_invalid
               FROM   csi_ctr_item_associations
               WHERE  inventory_item_id = l_inventory_item_id
               AND    associated_to_group = l_associated_to_group
               AND    group_id IS NULL
               AND    counter_id = l_counter_id;

               CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_ITEM_ASSOC');
            EXCEPTION
               WHEN NO_DATA_FOUND THEN NULL;
               WHEN OTHERS THEN
                  CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_ITEM_ASSOC');
            END;
         END IF;
      ELSE
         CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_GRP_NULL');
      END IF;
   END IF;

   /* Call the table Handler */
   CSI_CTR_ITEM_ASSOCIATIONS_PKG.Insert_Row(
	px_CTR_ASSOCIATION_ID           => l_ctr_association_id
	,p_GROUP_ID                     => l_group_id
	,p_INVENTORY_ITEM_ID            => l_inventory_item_id
	,p_OBJECT_VERSION_NUMBER        => 1
	,p_LAST_UPDATE_DATE             => sysdate
	,p_LAST_UPDATED_BY              => FND_GLOBAL.USER_ID
	,p_LAST_UPDATE_LOGIN            => FND_GLOBAL.USER_ID
	,p_CREATION_DATE                => sysdate
        ,p_CREATED_BY                   => FND_GLOBAL.USER_ID
        ,p_ATTRIBUTE1                   => l_attribute1
        ,p_ATTRIBUTE2                   => l_attribute2
        ,p_ATTRIBUTE3                   => l_attribute3
        ,p_ATTRIBUTE4                   => l_attribute4
        ,p_ATTRIBUTE5                   => l_attribute5
        ,p_ATTRIBUTE6                   => l_attribute6
        ,p_ATTRIBUTE7                   => l_attribute7
        ,p_ATTRIBUTE8                   => l_attribute8
        ,p_ATTRIBUTE9                   => l_attribute9
        ,p_ATTRIBUTE10                  => l_attribute10
        ,p_ATTRIBUTE11                  => l_attribute11
        ,p_ATTRIBUTE12                  => l_attribute12
        ,p_ATTRIBUTE13                  => l_attribute13
        ,p_ATTRIBUTE14                  => l_attribute14
        ,p_ATTRIBUTE15                  => l_attribute15
	,p_ATTRIBUTE_CATEGORY           => l_attribute_category
	,p_SECURITY_GROUP_ID            => l_security_group_id
	,p_MIGRATED_FLAG                => l_migrated_flag
	,p_COUNTER_ID                   => l_counter_id
        ,p_START_DATE_ACTIVE            => l_start_date_active
        ,p_END_DATE_ACTIVE              => l_end_date_active
        ,p_USAGE_RATE                   => l_usage_rate
        -- ,p_ASSOCIATION_TYPE             => l_association_type
        ,p_USE_PAST_READING             => l_use_past_reading
	,p_ASSOCIATED_TO_GROUP          => l_associated_to_group
	,p_MAINT_ORGANIZATION_ID        => NULL
	,p_PRIMARY_FAILURE_FLAG         => l_primary_failure_flag
        );


   IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
        ROLLBACK TO create_item_association_pvt;
        RETURN;
   END IF;

   /* End of table handler call */

   IF FND_API.to_Boolean(nvl(p_commit,FND_API.G_FALSE)) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and IF count is  get message info.
   FND_MSG_PUB.Count_And_Get
      ( p_count  =>  x_msg_count,
        p_data   =>  x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO create_item_association_pvt;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_item_association_pvt;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_item_association_pvt;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg
            ( G_PKG_NAME,
              l_api_name
            );
      END IF;
      FND_MSG_PUB.Count_And_Get
         ( p_count  => x_msg_count,
           p_data   => x_msg_data
         );
END create_item_association;

--|---------------------------------------------------
--| procedure name: create_counter_template
--| description :   procedure used to
--|                 create counter template
--|---------------------------------------------------

PROCEDURE create_counter_template
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_counter_template_rec      IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.counter_template_rec
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
 ) IS
   l_api_name                     CONSTANT VARCHAR2(30)   := 'CREATE_COUNTER_TEMPLATE';
   l_api_version                  CONSTANT NUMBER         := 1.0;
   l_msg_data                     VARCHAR2(2000);
   l_msg_index                    NUMBER;
   l_msg_count                    NUMBER;
   -- l_debug_level                  NUMBER;

   l_counter_id                    NUMBER;
   l_group_id                      NUMBER;
   l_name                          VARCHAR2(50);
   l_description                   VARCHAR2(240);
   l_counter_type                  VARCHAR2(30);
   l_uom_code                      VARCHAR2(3);
   l_usage_item_id                 NUMBER;
   l_reading_type                  NUMBER;
   l_direction                     VARCHAR2(1);
   l_customer_view                 VARCHAR2(1);
   l_estimation_id                 NUMBER;
   l_derive_function               VARCHAR2(30);
   l_formula_text                  VARCHAR2(1996);
   l_derive_counter_id             NUMBER;
   l_filter_type                   VARCHAR2(30);
   l_filter_reading_count          NUMBER;
   l_filter_time_uom               VARCHAR2(30);
   l_automatic_rollover            VARCHAR2(1);
   l_rollover_last_reading         NUMBER;
   l_rollover_first_reading        NUMBER;
   l_tolerance_plus                NUMBER;
   l_tolerance_minus               NUMBER;
   l_formula_incomplete_flag       VARCHAR2(1);
   l_used_in_scheduling            VARCHAR2(1);
   l_initial_reading               NUMBER;
   l_default_usage_rate            NUMBER;
   l_use_past_reading              NUMBER;
   l_start_date_active             DATE;
   l_end_date_active               DATE;
   l_initial_reading_date          DATE;
   l_defaulted_group_id            NUMBER;
   l_step_value                    NUMBER;
   l_security_group_id             NUMBER;
   l_created_from_counter_tmpl_id  NUMBER;
   l_attribute1                    VARCHAR2(150);
   l_attribute2                    VARCHAR2(150);
   l_attribute3                    VARCHAR2(150);
   l_attribute4                    VARCHAR2(150);
   l_attribute5                    VARCHAR2(150);
   l_attribute6                    VARCHAR2(150);
   l_attribute7                    VARCHAR2(150);
   l_attribute8                    VARCHAR2(150);
   l_attribute9                    VARCHAR2(150);
   l_attribute10                   VARCHAR2(150);
   l_attribute11                   VARCHAR2(150);
   l_attribute12                   VARCHAR2(150);
   l_attribute13                   VARCHAR2(150);
   l_attribute14                   VARCHAR2(150);
   l_attribute15                   VARCHAR2(150);
   l_attribute16                   VARCHAR2(150);
   l_attribute17                   VARCHAR2(150);
   l_attribute18                   VARCHAR2(150);
   l_attribute19                   VARCHAR2(150);
   l_attribute20                   VARCHAR2(150);
   l_attribute21                   VARCHAR2(150);
   l_attribute22                   VARCHAR2(150);
   l_attribute23                   VARCHAR2(150);
   l_attribute24                   VARCHAR2(150);
   l_attribute25                   VARCHAR2(150);
   l_attribute26                   VARCHAR2(150);
   l_attribute27                   VARCHAR2(150);
   l_attribute28                   VARCHAR2(150);
   l_attribute29                   VARCHAR2(150);
   l_attribute30                   VARCHAR2(150);
   l_attribute_category            VARCHAR2(30);
   l_association_type              VARCHAR2(30);
   l_migrated_flag                 VARCHAR2(1);
   l_dummy                         VARCHAR2(1);
   l_time_based_manual_entry       VARCHAR2(1);
   l_eam_required_flag             VARCHAR2(1);

   l_counter_groups_rec   CSI_CTR_DATASTRUCTURES_PUB.counter_groups_rec;
   l_valid_start_date             DATE;

   CURSOR c1_group(p_group_id NUMBER) IS
   select start_date_active
   from   cs_csi_counter_groups
   where  counter_group_id = p_group_id;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  create_counter_template_pvt;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line
         ( 'create_counter_template_pvt'           ||'-'||
           p_api_version                              ||'-'||
           nvl(p_commit,FND_API.G_FALSE)              ||'-'||
           nvl(p_init_msg_list,FND_API.G_FALSE)       ||'-'||
           nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL) );
   END IF;

   if p_counter_template_rec.group_id = FND_API.G_MISS_NUM then
       l_group_id := null;
   else
       l_group_id := p_counter_template_rec.group_id;
   end if;

   if p_counter_template_rec.counter_id = FND_API.G_MISS_NUM then
       l_counter_id := null;
   else
       l_counter_id := p_counter_template_rec.counter_id;
   end if;

   if p_counter_template_rec.name = FND_API.G_MISS_CHAR then
      l_name := null;
   else
      l_name := p_counter_template_rec.name;
   end if;

   if p_counter_template_rec.description = FND_API.G_MISS_CHAR then
      l_description := null;
   else
      l_description := p_counter_template_rec.description;
   end if;

   if p_counter_template_rec.counter_type = FND_API.G_MISS_CHAR then
      l_counter_type := null;
   else
      l_counter_type := p_counter_template_rec.counter_type;
   end if;

   if p_counter_template_rec.uom_code = FND_API.G_MISS_CHAR then
       l_uom_code := null;
   else
       l_uom_code := p_counter_template_rec.uom_code;
   end if;

   if p_counter_template_rec.usage_item_id = FND_API.G_MISS_NUM then
       l_usage_item_id := null;
   else
       l_usage_item_id := p_counter_template_rec.usage_item_id;
   end if;

   if p_counter_template_rec.reading_type = FND_API.G_MISS_NUM then
       l_reading_type := null;
   else
       l_reading_type := p_counter_template_rec.reading_type;
   end if;

   if p_counter_template_rec.step_value = FND_API.G_MISS_NUM then
       l_step_value := null;
   else
       l_step_value := p_counter_template_rec.step_value;
   end if;

   if p_counter_template_rec.direction = FND_API.G_MISS_CHAR then
       l_direction := null;
   else
       l_direction := p_counter_template_rec.direction;
   end if;

   if p_counter_template_rec.estimation_id = FND_API.G_MISS_NUM then
       l_estimation_id := null;
   else
       l_estimation_id := p_counter_template_rec.estimation_id;
   end if;

   if p_counter_template_rec.derive_function = FND_API.G_MISS_CHAR then
       l_derive_function := null;
   else
       l_derive_function := p_counter_template_rec.derive_function;
   end if;

   if p_counter_template_rec.formula_text = FND_API.G_MISS_CHAR then
       l_formula_text := null;
   else
       l_formula_text := p_counter_template_rec.formula_text;
   end if;

   if p_counter_template_rec.derive_counter_id = FND_API.G_MISS_NUM then
       l_derive_counter_id := null;
   else
       l_derive_counter_id := p_counter_template_rec.derive_counter_id;
   end if;

   if p_counter_template_rec.filter_type = FND_API.G_MISS_CHAR then
       l_filter_type := null;
   else
       l_filter_type := p_counter_template_rec.filter_type;
   end if;

   if p_counter_template_rec.filter_reading_count = FND_API.G_MISS_NUM then
       l_filter_reading_count := null;
   else
       l_filter_reading_count := p_counter_template_rec.filter_reading_count;
   end if;

   if p_counter_template_rec.filter_time_uom = FND_API.G_MISS_CHAR then
       l_filter_time_uom := null;
   else
       l_filter_time_uom := p_counter_template_rec.filter_time_uom;
   end if;

   if p_counter_template_rec.automatic_rollover = FND_API.G_MISS_CHAR then
       l_automatic_rollover := null;
   else
       l_automatic_rollover := p_counter_template_rec.automatic_rollover;
   end if;

   if p_counter_template_rec.rollover_last_reading = FND_API.G_MISS_NUM then
       l_rollover_last_reading := null;
   else
       l_rollover_last_reading := p_counter_template_rec.rollover_last_reading;
   end if;

   if p_counter_template_rec.rollover_first_reading = FND_API.G_MISS_NUM then
       l_rollover_first_reading := null;
   else
       l_rollover_first_reading := p_counter_template_rec.rollover_first_reading;
   end if;

   if p_counter_template_rec.tolerance_plus = FND_API.G_MISS_NUM then
       l_tolerance_plus := null;
   else
       l_tolerance_plus := p_counter_template_rec.tolerance_plus;
   end if;

   if p_counter_template_rec.security_group_id = FND_API.G_MISS_NUM then
       l_security_group_id := null;
   else
       l_security_group_id := p_counter_template_rec.security_group_id;
   end if;

   if p_counter_template_rec.tolerance_minus = FND_API.G_MISS_NUM then
       l_tolerance_minus := null;
   else
       l_tolerance_minus := p_counter_template_rec.tolerance_minus;
   end if;

   if p_counter_template_rec.used_in_scheduling = FND_API.G_MISS_CHAR then
       l_used_in_scheduling := null;
   else
       l_used_in_scheduling := p_counter_template_rec.used_in_scheduling;
   end if;

   if p_counter_template_rec.initial_reading = FND_API.G_MISS_NUM then
       l_initial_reading := null;
   else
       l_initial_reading := p_counter_template_rec.initial_reading;
   end if;

   if p_counter_template_rec.default_usage_rate = FND_API.G_MISS_NUM then
       l_default_usage_rate := null;
   else
       l_default_usage_rate := p_counter_template_rec.default_usage_rate;
   end if;

   if p_counter_template_rec.use_past_reading = FND_API.G_MISS_NUM then
       l_use_past_reading := null;
   else
       l_use_past_reading := p_counter_template_rec.use_past_reading;
   end if;

   if nvl(p_counter_template_rec.start_date_active,FND_API.G_MISS_DATE) = FND_API.G_MISS_DATE then
       l_start_date_active := sysdate;
   else
       l_start_date_active := p_counter_template_rec.start_date_active;
   end if;

   validate_start_date(l_start_date_active);

   IF l_group_id IS NOT NULL THEN
      OPEN c1_group(l_group_id);
      FETCH c1_group INTO l_valid_start_date;

      IF l_start_date_active < l_valid_start_date THEN
         csi_ctr_gen_utility_pvt.ExitWithErrMsg
             ( p_msg_name     =>  'CSI_API_CTR_VAL_ST_DATE',
               p_token1_name  =>  'PARAM',
               p_token1_val   =>  'The counter template start date cannot be less than the active start date of the counter group.');
      END IF;
      CLOSE c1_group;

   END IF;

   if p_counter_template_rec.end_date_active = FND_API.G_MISS_DATE then
       l_end_date_active := null;
   else
       l_end_date_active := p_counter_template_rec.end_date_active;
   end if;

   if l_end_date_active IS NOT NULL then
      if l_end_date_active < l_start_date_active then
         CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_ALL_END_DATE');
      end if;
   end if;

   if p_counter_template_rec.attribute1 = FND_API.G_MISS_CHAR then
       l_attribute1 := null;
   else
       l_attribute1 := p_counter_template_rec.attribute1;
   end if;

   if p_counter_template_rec.attribute2 = FND_API.G_MISS_CHAR then
       l_attribute2 := null;
   else
       l_attribute2 := p_counter_template_rec.attribute2;
   end if;

   if p_counter_template_rec.attribute3 = FND_API.G_MISS_CHAR then
       l_attribute3 := null;
   else
       l_attribute3 := p_counter_template_rec.attribute3;
   end if;

   if p_counter_template_rec.attribute4 = FND_API.G_MISS_CHAR then
       l_attribute4 := null;
   else
       l_attribute4 := p_counter_template_rec.attribute4;
   end if;

   if p_counter_template_rec.attribute5 = FND_API.G_MISS_CHAR then
       l_attribute5 := null;
   else
       l_attribute5 := p_counter_template_rec.attribute5;
   end if;

   if p_counter_template_rec.attribute6 = FND_API.G_MISS_CHAR then
       l_attribute6 := null;
   else
       l_attribute6 := p_counter_template_rec.attribute6;
   end if;

   if p_counter_template_rec.attribute7 = FND_API.G_MISS_CHAR then
      l_attribute7 := null;
   else
       l_attribute7 := p_counter_template_rec.attribute7;
   end if;

   if p_counter_template_rec.attribute8 = FND_API.G_MISS_CHAR then
      l_attribute8 := null;
   else
      l_attribute8 := p_counter_template_rec.attribute8;
   end if;

   if p_counter_template_rec.attribute9 = FND_API.G_MISS_CHAR then
      l_attribute9 := null;
   else
       l_attribute9 := p_counter_template_rec.attribute9;
   end if;

   if p_counter_template_rec.attribute10 = FND_API.G_MISS_CHAR then
      l_attribute10 := null;
   else
      l_attribute10 := p_counter_template_rec.attribute10;
   end if;

   if p_counter_template_rec.attribute11 = FND_API.G_MISS_CHAR then
      l_attribute11 := null;
   else
      l_attribute11 := p_counter_template_rec.attribute11;
   end if;

   if p_counter_template_rec.attribute12 = FND_API.G_MISS_CHAR then
      l_attribute12 := null;
   else
      l_attribute12 := p_counter_template_rec.attribute12;
   end if;

   if p_counter_template_rec.attribute13 = FND_API.G_MISS_CHAR then
      l_attribute13 := null;
   else
      l_attribute13 := p_counter_template_rec.attribute13;
   end if;

   if p_counter_template_rec.attribute14 = FND_API.G_MISS_CHAR then
      l_attribute14 := null;
   else
      l_attribute14 := p_counter_template_rec.attribute14;
   end if;

   if p_counter_template_rec.attribute15 = FND_API.G_MISS_CHAR then
      l_attribute15 := null;
   else
      l_attribute15 := p_counter_template_rec.attribute15;
   end if;

   if p_counter_template_rec.attribute16 = FND_API.G_MISS_CHAR then
       l_attribute16 := null;
   else
       l_attribute16 := p_counter_template_rec.attribute16;
   end if;

   if p_counter_template_rec.attribute17 = FND_API.G_MISS_CHAR then
      l_attribute17 := null;
   else
       l_attribute17 := p_counter_template_rec.attribute17;
   end if;

   if p_counter_template_rec.attribute18 = FND_API.G_MISS_CHAR then
      l_attribute18 := null;
   else
      l_attribute18 := p_counter_template_rec.attribute18;
   end if;

   if p_counter_template_rec.attribute19 = FND_API.G_MISS_CHAR then
      l_attribute19 := null;
   else
       l_attribute19 := p_counter_template_rec.attribute19;
   end if;

   if p_counter_template_rec.attribute20 = FND_API.G_MISS_CHAR then
      l_attribute20 := null;
   else
      l_attribute20 := p_counter_template_rec.attribute20;
   end if;

   if p_counter_template_rec.attribute21 = FND_API.G_MISS_CHAR then
       l_attribute21 := null;
   else
       l_attribute21 := p_counter_template_rec.attribute21;
   end if;

   if p_counter_template_rec.attribute22 = FND_API.G_MISS_CHAR then
       l_attribute22 := null;
   else
       l_attribute22 := p_counter_template_rec.attribute22;
   end if;

   if p_counter_template_rec.attribute23 = FND_API.G_MISS_CHAR then
       l_attribute23 := null;
   else
       l_attribute23 := p_counter_template_rec.attribute23;
   end if;

   if p_counter_template_rec.attribute24 = FND_API.G_MISS_CHAR then
       l_attribute24 := null;
   else
       l_attribute24 := p_counter_template_rec.attribute24;
   end if;

   if p_counter_template_rec.attribute25 = FND_API.G_MISS_CHAR then
       l_attribute25 := null;
   else
       l_attribute25 := p_counter_template_rec.attribute25;
   end if;

   if p_counter_template_rec.attribute26 = FND_API.G_MISS_CHAR then
       l_attribute26 := null;
   else
       l_attribute26 := p_counter_template_rec.attribute26;
   end if;

   if p_counter_template_rec.attribute27 = FND_API.G_MISS_CHAR then
      l_attribute27 := null;
   else
       l_attribute27 := p_counter_template_rec.attribute27;
   end if;

   if p_counter_template_rec.attribute28 = FND_API.G_MISS_CHAR then
      l_attribute28 := null;
   else
      l_attribute28 := p_counter_template_rec.attribute28;
   end if;

   if p_counter_template_rec.attribute29 = FND_API.G_MISS_CHAR then
      l_attribute29 := null;
   else
       l_attribute29 := p_counter_template_rec.attribute29;
   end if;

   if p_counter_template_rec.attribute30 = FND_API.G_MISS_CHAR then
      l_attribute30 := null;
   else
      l_attribute30 := p_counter_template_rec.attribute30;
   end if;

   if p_counter_template_rec.attribute_category = FND_API.G_MISS_CHAR then
      l_attribute_category := null;
   else
      l_attribute_category := p_counter_template_rec.attribute_category;
   end if;

   if p_counter_template_rec.association_type = FND_API.G_MISS_CHAR then
       l_association_type := null;
   else
       l_association_type := p_counter_template_rec.association_type;
   end if;

   if l_association_type is null then
      l_association_type := 'TRACKABLE';
   end if;

   if p_counter_template_rec.group_id = FND_API.G_MISS_NUM then
       l_group_id := null;
   else
       l_group_id := p_counter_template_rec.group_id;
   end if;

   if p_counter_template_rec.time_based_manual_entry = FND_API.G_MISS_CHAR then
       l_time_based_manual_entry := 'N';
   else
       l_time_based_manual_entry := p_counter_template_rec.time_based_manual_entry;
   end if;

   if p_counter_template_rec.eam_required_flag = FND_API.G_MISS_CHAR then
       l_eam_required_flag := null;
   else
       l_eam_required_flag := p_counter_template_rec.eam_required_flag;
   end if;

   if nvl(p_counter_template_rec.initial_reading_date, FND_API.G_MISS_DATE) = FND_API.G_MISS_DATE then
      l_initial_reading_date := sysdate;
   else
      l_initial_reading_date := p_counter_template_rec.initial_reading_date;
   end if;

   if l_group_id IS NULL THEN
      l_counter_groups_rec.NAME  :=  l_name||'-Group';
      l_counter_groups_rec.DESCRIPTION   := l_name||'-Group';

      create_counter_group
        (
         p_api_version        => p_api_version
         ,p_commit             => p_commit
         ,p_init_msg_list      => p_init_msg_list
         ,p_validation_level   => p_validation_level
         ,p_counter_groups_rec => l_counter_groups_rec
         ,x_return_status      => x_return_status
         ,x_msg_count          => x_msg_count
         ,x_msg_data           => x_msg_data
        );

       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;

          WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                            FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line('Error from CSI_COUNTER_PVT.CREATE_COUNTER_GROUP');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
          END LOOP;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_defaulted_group_id := l_counter_groups_rec.counter_group_id;
   else
      l_defaulted_group_id := l_group_id;
   end if;

   --call validate counter to validate the counter instance
   validate_counter(l_group_id, l_name, l_counter_type, l_uom_code,
                    l_usage_item_id, l_reading_type, l_direction,
                    l_estimation_id, l_derive_function, l_formula_text,
                    l_derive_counter_id, l_filter_type, l_filter_reading_count,
                    l_filter_time_uom, l_automatic_rollover,
                    l_rollover_last_reading, l_rollover_first_reading,
                    l_tolerance_plus, l_tolerance_minus, l_used_in_scheduling,
                    l_initial_reading, l_default_usage_rate,
                    l_use_past_reading, -1,
                    l_start_date_active, l_end_date_active,'N'
                   );

   /* Call the table Handler */
   CSI_COUNTER_TEMPLATE_PKG.Insert_Row(
	    px_COUNTER_ID	        => l_counter_id
	   ,p_GROUP_ID                  => l_group_id
	   ,p_COUNTER_TYPE              => l_counter_type
	   ,p_INITIAL_READING           => l_initial_reading
	   ,p_INITIAL_READING_DATE      => l_initial_reading_date
	   ,p_TOLERANCE_PLUS            => l_tolerance_plus
	   ,p_TOLERANCE_MINUS           => l_tolerance_minus
	   ,p_UOM_CODE                  => l_uom_code
	   ,p_DERIVE_COUNTER_ID         => l_derive_counter_id
	   ,p_DERIVE_FUNCTION           => l_derive_function
	   ,p_DERIVE_PROPERTY_ID        => null
	   ,p_VALID_FLAG                => 'Y'
	   ,p_FORMULA_INCOMPLETE_FLAG   => l_formula_incomplete_flag
	   ,p_FORMULA_TEXT              => l_formula_text
	   ,p_ROLLOVER_LAST_READING     => l_rollover_last_reading
	   ,p_ROLLOVER_FIRST_READING	=> l_rollover_first_reading
	   ,p_USAGE_ITEM_ID             => l_usage_item_id
	   ,p_CTR_VAL_MAX_SEQ_NO        => 1
	   ,p_START_DATE_ACTIVE         => l_start_date_active
	   ,p_END_DATE_ACTIVE           => l_end_date_active
	   ,p_OBJECT_VERSION_NUMBER     => 1
           ,p_SECURITY_GROUP_ID         => l_security_group_id
	   ,p_LAST_UPDATE_DATE          => sysdate
	   ,p_LAST_UPDATED_BY           => FND_GLOBAL.USER_ID
	   ,p_CREATION_DATE             => sysdate
	   ,p_CREATED_BY                => FND_GLOBAL.USER_ID
	   ,p_LAST_UPDATE_LOGIN         => FND_GLOBAL.USER_ID
	   ,p_ATTRIBUTE1                => l_attribute1
	   ,p_ATTRIBUTE2                => l_attribute2
	   ,p_ATTRIBUTE3                => l_attribute3
	   ,p_ATTRIBUTE4                => l_attribute4
	   ,p_ATTRIBUTE5                => l_attribute5
	   ,p_ATTRIBUTE6                => l_attribute6
	   ,p_ATTRIBUTE7                => l_attribute7
	   ,p_ATTRIBUTE8                => l_attribute8
	   ,p_ATTRIBUTE9                => l_attribute9
	   ,p_ATTRIBUTE10               => l_attribute10
	   ,p_ATTRIBUTE11               => l_attribute11
	   ,p_ATTRIBUTE12               => l_attribute12
	   ,p_ATTRIBUTE13               => l_attribute13
	   ,p_ATTRIBUTE14               => l_attribute14
	   ,p_ATTRIBUTE15               => l_attribute15
	   ,p_ATTRIBUTE16               => l_attribute16
	   ,p_ATTRIBUTE17               => l_attribute17
	   ,p_ATTRIBUTE18               => l_attribute18
	   ,p_ATTRIBUTE19               => l_attribute19
	   ,p_ATTRIBUTE20               => l_attribute20
	   ,p_ATTRIBUTE21               => l_attribute21
	   ,p_ATTRIBUTE22               => l_attribute22
	   ,p_ATTRIBUTE23               => l_attribute23
	   ,p_ATTRIBUTE24               => l_attribute24
	   ,p_ATTRIBUTE25               => l_attribute25
	   ,p_ATTRIBUTE26               => l_attribute26
	   ,p_ATTRIBUTE27               => l_attribute27
	   ,p_ATTRIBUTE28               => l_attribute28
	   ,p_ATTRIBUTE29               => l_attribute29
	   ,p_ATTRIBUTE30               => l_attribute30
	   ,p_ATTRIBUTE_CATEGORY        => l_attribute_category
	   ,p_MIGRATED_FLAG             => l_migrated_flag
	   ,p_CUSTOMER_VIEW             => l_customer_view
	   ,p_DIRECTION                 => l_direction
	   ,p_FILTER_TYPE               => l_filter_type
	   ,p_FILTER_READING_COUNT      => l_filter_reading_count
	   ,p_FILTER_TIME_UOM           => l_filter_time_uom
	   ,p_ESTIMATION_ID             => l_estimation_id
	   ,p_ASSOCIATION_TYPE          => l_association_type
	   ,p_READING_TYPE              => l_reading_type
	   ,p_AUTOMATIC_ROLLOVER        => l_automatic_rollover
	   ,p_DEFAULT_USAGE_RATE        => l_default_usage_rate
	   ,p_USE_PAST_READING          => l_use_past_reading
	   ,p_USED_IN_SCHEDULING        => l_used_in_scheduling
	   ,p_DEFAULTED_GROUP_ID        => l_defaulted_group_id
	   ,p_STEP_VALUE                => l_step_value
	   ,p_NAME	                => l_name
	   ,p_DESCRIPTION               => l_description
	   ,p_TIME_BASED_MANUAL_ENTRY   => l_time_based_manual_entry
	   ,p_EAM_REQUIRED_FLAG         => l_eam_required_flag
      );

   p_counter_template_rec.counter_id := l_counter_id;

   IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
        ROLLBACK TO create_counter_template_pvt;
        RETURN;
   END IF;

   /* End of table handler call */

   IF FND_API.to_Boolean(nvl(p_commit,FND_API.G_FALSE)) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and IF count is  get message info.
   FND_MSG_PUB.Count_And_Get
      ( p_count  =>  x_msg_count,
        p_data   =>  x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO create_counter_template_pvt;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_counter_template_pvt;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_counter_template_pvt;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg
            ( G_PKG_NAME,
              l_api_name
            );
      END IF;
      FND_MSG_PUB.Count_And_Get
         ( p_count  => x_msg_count,
           p_data   => x_msg_data
         );
END create_counter_template;

--|---------------------------------------------------
--| procedure name: create_ctr_property_template
--| description :   procedure used to
--|                 create counter properties
--|---------------------------------------------------

PROCEDURE create_ctr_property_template
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_ctr_property_template_rec IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_property_template_rec
    ,x_return_status                OUT    NOCOPY VARCHAR2
    ,x_msg_count                    OUT    NOCOPY NUMBER
    ,x_msg_data                     OUT    NOCOPY VARCHAR2
 ) IS
   l_api_name                     CONSTANT VARCHAR2(30)   := 'CREATE_CTR_PROPERTY_TEMPLATE';
   l_api_version                  CONSTANT NUMBER         := 1.0;
   l_msg_data                     VARCHAR2(2000);
   l_msg_index                    NUMBER;
   l_msg_count                    NUMBER;
   -- l_debug_level                  NUMBER;

   l_COUNTER_PROPERTY_ID	  NUMBER;
   l_COUNTER_ID                   NUMBER;
   l_PROPERTY_DATA_TYPE           VARCHAR2(30);
   l_IS_NULLABLE                  VARCHAR2(1);
   l_DEFAULT_VALUE                VARCHAR2(240);
   l_MINIMUM_VALUE                VARCHAR2(240);
   l_MAXIMUM_VALUE                VARCHAR2(240);
   l_UOM_CODE                     VARCHAR2(3);
   l_LAST_UPDATE_DATE             DATE;
   l_LAST_UPDATED_BY              NUMBER;
   l_CREATION_DATE                DATE;
   l_CREATED_BY                   NUMBER;
   l_LAST_UPDATE_LOGIN            NUMBER;
   l_START_DATE_ACTIVE            DATE;
   l_END_DATE_ACTIVE              DATE;
   l_ATTRIBUTE1                   VARCHAR2(150);
   l_ATTRIBUTE2                   VARCHAR2(150);
   l_ATTRIBUTE3                   VARCHAR2(150);
   l_ATTRIBUTE4                   VARCHAR2(150);
   l_ATTRIBUTE5                   VARCHAR2(150);
   l_ATTRIBUTE6                   VARCHAR2(150);
   l_ATTRIBUTE7                   VARCHAR2(150);
   l_ATTRIBUTE8                   VARCHAR2(150);
   l_ATTRIBUTE9                   VARCHAR2(150);
   l_ATTRIBUTE10                  VARCHAR2(150);
   l_ATTRIBUTE11                  VARCHAR2(150);
   l_ATTRIBUTE12                  VARCHAR2(150);
   l_ATTRIBUTE13                  VARCHAR2(150);
   l_ATTRIBUTE14                  VARCHAR2(150);
   l_ATTRIBUTE15                  VARCHAR2(150);
   l_ATTRIBUTE_CATEGORY           VARCHAR2(30);
   l_OBJECT_VERSION_NUMBER        NUMBER;
   l_PROPERTY_LOV_TYPE            VARCHAR2(30);
   l_SECURITY_GROUP_ID            NUMBER;
   l_MIGRATED_FLAG                VARCHAR2(1);
   l_NAME                         VARCHAR2(50);
   l_DESCRIPTION                  VARCHAR2(240);
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  create_ctr_property_tmpl_pvt;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'create_ctr_property_tmpl_pvt'          ||'-'||
                                     p_api_version                              ||'-'||
                                     nvl(p_commit,FND_API.G_FALSE)              ||'-'||
                                     nvl(p_init_msg_list,FND_API.G_FALSE)       ||'-'||
                                     nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL) );
   END IF;

   if p_ctr_property_template_rec.name = FND_API.G_MISS_CHAR then
      l_name := null;
   else
      l_name := p_ctr_property_template_rec.name;
   end if;

   if p_ctr_property_template_rec.description = FND_API.G_MISS_CHAR then
      l_description := null;
   else
      l_description := p_ctr_property_template_rec.description;
   end if;

   if p_ctr_property_template_rec.counter_property_id = FND_API.G_MISS_NUM then
      l_counter_property_id := null;
   else
      l_counter_property_id := p_ctr_property_template_rec.counter_property_id;
   end if;

   if p_ctr_property_template_rec.property_data_type = FND_API.G_MISS_CHAR then
      l_property_data_type := null;
   else
      l_property_data_type := p_ctr_property_template_rec.property_data_type;
   end if;

   if p_ctr_property_template_rec.IS_NULLABLE= FND_API.G_MISS_CHAR then
      l_IS_NULLABLE := null;
   else
      l_IS_NULLABLE := p_ctr_property_template_rec.IS_NULLABLE;
   end if;

   if p_ctr_property_template_rec.DEFAULT_VALUE= FND_API.G_MISS_CHAR then
      l_DEFAULT_VALUE := null;
   else
      l_DEFAULT_VALUE := p_ctr_property_template_rec.DEFAULT_VALUE;
   end if;

   if p_ctr_property_template_rec.MINIMUM_VALUE= FND_API.G_MISS_CHAR then
      l_MINIMUM_VALUE := null;
   else
      l_MINIMUM_VALUE := p_ctr_property_template_rec.MINIMUM_VALUE;
   end if;

   if p_ctr_property_template_rec.MAXIMUM_VALUE = FND_API.G_MISS_CHAR then
      l_MAXIMUM_VALUE := null;
   else
      l_MAXIMUM_VALUE := p_ctr_property_template_rec.MAXIMUM_VALUE;
   end if;

   if p_ctr_property_template_rec.UOM_CODE = FND_API.G_MISS_CHAR then
      l_UOM_CODE := null;
   else
      l_UOM_CODE := p_ctr_property_template_rec.UOM_CODE;
   end if;

   if p_ctr_property_template_rec.property_lov_type = FND_API.G_MISS_CHAR then
      l_property_lov_type := null;
   else
      l_property_lov_type := p_ctr_property_template_rec.property_lov_type;
   end if;

   if p_ctr_property_template_rec.counter_id = FND_API.G_MISS_NUM then
      l_counter_id := null;
   else
      l_counter_id := p_ctr_property_template_rec.counter_id;
   end if;

   if p_ctr_property_template_rec.security_group_id = FND_API.G_MISS_NUM then
      l_security_group_id := null;
   else
      l_security_group_id := p_ctr_property_template_rec.security_group_id;
   end if;

   if nvl(p_ctr_property_template_rec.start_date_active,FND_API.G_MISS_DATE) = FND_API.G_MISS_DATE then
      l_start_date_active := sysdate;
   else
      l_start_date_active := p_ctr_property_template_rec.start_date_active;
   end if;

   if p_ctr_property_template_rec.end_date_active = FND_API.G_MISS_DATE then
      l_end_date_active := null;
   else
      l_end_date_active := p_ctr_property_template_rec.end_date_active;
   end if;

   if p_ctr_property_template_rec.attribute1 = FND_API.G_MISS_CHAR then
      l_attribute1 := null;
   else
      l_attribute1 := p_ctr_property_template_rec.attribute1;
   end if;

   if p_ctr_property_template_rec.attribute2 = FND_API.G_MISS_CHAR then
      l_attribute2 := null;
   else
      l_attribute2 := p_ctr_property_template_rec.attribute2;
   end if;

   if p_ctr_property_template_rec.attribute3 = FND_API.G_MISS_CHAR then
      l_attribute3 := null;
   else
      l_attribute3 := p_ctr_property_template_rec.attribute3;
   end if;

   if p_ctr_property_template_rec.attribute4 = FND_API.G_MISS_CHAR then
      l_attribute4 := null;
   else
      l_attribute4 := p_ctr_property_template_rec.attribute4;
   end if;

   if p_ctr_property_template_rec.attribute5 = FND_API.G_MISS_CHAR then
      l_attribute5 := null;
   else
      l_attribute5 := p_ctr_property_template_rec.attribute5;
   end if;

   if p_ctr_property_template_rec.attribute6 = FND_API.G_MISS_CHAR then
      l_attribute6 := null;
   else
      l_attribute6 := p_ctr_property_template_rec.attribute6;
   end if;

   if p_ctr_property_template_rec.attribute7 = FND_API.G_MISS_CHAR then
      l_attribute7 := null;
   else
      l_attribute7 := p_ctr_property_template_rec.attribute7;
   end if;

   if p_ctr_property_template_rec.attribute8 = FND_API.G_MISS_CHAR then
      l_attribute8 := null;
   else
      l_attribute8 := p_ctr_property_template_rec.attribute8;
   end if;

   if p_ctr_property_template_rec.attribute9 = FND_API.G_MISS_CHAR then
      l_attribute9 := null;
   else
      l_attribute9 := p_ctr_property_template_rec.attribute9;
   end if;

   if p_ctr_property_template_rec.attribute10 = FND_API.G_MISS_CHAR then
      l_attribute10 := null;
   else
      l_attribute10 := p_ctr_property_template_rec.attribute10;
   end if;

   if p_ctr_property_template_rec.attribute11 = FND_API.G_MISS_CHAR then
      l_attribute11 := null;
   else
      l_attribute11 := p_ctr_property_template_rec.attribute11;
   end if;

   if p_ctr_property_template_rec.attribute12 = FND_API.G_MISS_CHAR then
      l_attribute12 := null;
   else
      l_attribute12 := p_ctr_property_template_rec.attribute12;
   end if;

   if p_ctr_property_template_rec.attribute13 = FND_API.G_MISS_CHAR then
      l_attribute13 := null;
   else
      l_attribute13 := p_ctr_property_template_rec.attribute13;
   end if;

   if p_ctr_property_template_rec.attribute14 = FND_API.G_MISS_CHAR then
      l_attribute14 := null;
   else
      l_attribute14 := p_ctr_property_template_rec.attribute14;
   end if;

   if p_ctr_property_template_rec.attribute15 = FND_API.G_MISS_CHAR then
      l_attribute15 := null;
   else
      l_attribute15 := p_ctr_property_template_rec.attribute15;
   end if;

   if p_ctr_property_template_rec.attribute_category = FND_API.G_MISS_CHAR then
      l_attribute_category := null;
   else
      l_attribute_category := p_ctr_property_template_rec.attribute_category;
   end if;

   if p_ctr_property_template_rec.migrated_flag = FND_API.G_MISS_CHAR then
      l_migrated_flag := null;
   else
      l_migrated_flag := p_ctr_property_template_rec.migrated_flag;
   end if;

   validate_start_date(l_start_date_active);
   IF l_property_data_type IS NOT NULL THEN
      validate_lookups('CSI_CTR_PROPERTY_DATA_TYPE',l_property_data_type);
      Validate_Data_Type(l_property_data_type, l_default_value, l_minimum_value, l_maximum_value);
   END IF;

   IF l_property_lov_type IS NOT NULL THEN
      validate_lookups('CSI_CTR_PROPERTY_LOV_TYPE',l_property_lov_type);
   END IF;

   IF l_property_lov_type IS NOT NULL and l_default_value IS NOT NULL THEN
      validate_lookups(l_property_lov_type,l_default_value);
   END IF;

   IF l_uom_code IS NOT NULL THEN
       validate_uom(l_uom_code);
   END IF;

   /* Call the table Handler */
   CSI_CTR_PROPERTY_TEMPLATE_PKG.Insert_Row(
 	 px_COUNTER_PROPERTY_ID         => l_counter_property_id
	,p_COUNTER_ID                   => l_counter_id
	,p_PROPERTY_DATA_TYPE           => l_property_data_type
	,p_IS_NULLABLE                  => l_is_nullable
	,p_DEFAULT_VALUE                => l_default_value
	,p_MINIMUM_VALUE                => l_minimum_value
	,p_MAXIMUM_VALUE                => l_maximum_value
	,p_UOM_CODE                     => l_uom_code
	,p_START_DATE_ACTIVE            => l_start_date_active
	,p_END_DATE_ACTIVE              => l_end_date_active
	,p_OBJECT_VERSION_NUMBER        => 1
        ,p_LAST_UPDATE_DATE             => sysdate
        ,p_LAST_UPDATED_BY              => FND_GLOBAL.USER_ID
        ,p_CREATION_DATE                => sysdate
        ,p_CREATED_BY                   => FND_GLOBAL.USER_ID
        ,p_LAST_UPDATE_LOGIN            => FND_GLOBAL.USER_ID
        ,p_ATTRIBUTE1                   => l_attribute1
        ,p_ATTRIBUTE2                   => l_attribute2
        ,p_ATTRIBUTE3                   => l_attribute3
        ,p_ATTRIBUTE4                   => l_attribute4
        ,p_ATTRIBUTE5                   => l_attribute5
        ,p_ATTRIBUTE6                   => l_attribute6
        ,p_ATTRIBUTE7                   => l_attribute7
        ,p_ATTRIBUTE8                   => l_attribute8
        ,p_ATTRIBUTE9                   => l_attribute9
        ,p_ATTRIBUTE10                  => l_attribute10
        ,p_ATTRIBUTE11                  => l_attribute11
        ,p_ATTRIBUTE12                  => l_attribute12
        ,p_ATTRIBUTE13                  => l_attribute13
        ,p_ATTRIBUTE14                  => l_attribute14
        ,p_ATTRIBUTE15                  => l_attribute15
        ,p_ATTRIBUTE_CATEGORY           => l_attribute_category
	,p_MIGRATED_FLAG                => l_migrated_flag
	,p_PROPERTY_LOV_TYPE            => l_property_lov_type
        ,p_SECURITY_GROUP_ID            => l_security_group_id
        ,p_NAME	                        => l_name
        ,p_DESCRIPTION                  => l_description
        );

   IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
        ROLLBACK TO create_ctr_property_tmpl_pvt;
        RETURN;
   END IF;

   /* End of table handler call */

   IF FND_API.to_Boolean(nvl(p_commit,FND_API.G_FALSE)) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and IF count is  get message info.
   FND_MSG_PUB.Count_And_Get
      ( p_count  =>  x_msg_count,
        p_data   =>  x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO create_ctr_property_tmpl_pvt;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_ctr_property_tmpl_pvt;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_ctr_property_tmpl_pvt;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg
            ( G_PKG_NAME,
              l_api_name
            );
      END IF;
      FND_MSG_PUB.Count_And_Get
         ( p_count  => x_msg_count,
           p_data   => x_msg_data
         );
END create_ctr_property_template;

--|---------------------------------------------------
--| procedure name: create_counter_relationship
--| description :   procedure used to
--|                 create counter relationship
--|---------------------------------------------------

PROCEDURE create_counter_relationship
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_counter_relationships_rec IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.counter_relationships_rec
    ,x_return_status                OUT    NOCOPY VARCHAR2
    ,x_msg_count                    OUT    NOCOPY NUMBER
    ,x_msg_data                     OUT    NOCOPY VARCHAR2
 ) IS
   l_api_name                     CONSTANT VARCHAR2(30)   := 'CREATE_COUNTER_RELATIONSHIP';
   l_api_version                  CONSTANT NUMBER         := 1.0;
   l_msg_data                     VARCHAR2(2000);
   l_msg_index                    NUMBER;
   l_msg_count                    NUMBER;
   -- l_debug_level                  NUMBER;

   l_RELATIONSHIP_ID  	          NUMBER;
   l_CTR_ASSOCIATION_ID           NUMBER;
   l_RELATIONSHIP_TYPE_CODE       VARCHAR2(30);
   l_BIND_VARIABLE_NAME           VARCHAR2(30);
   l_SOURCE_COUNTER_ID            NUMBER;
   l_OBJECT_COUNTER_ID            NUMBER;
   l_LAST_UPDATE_DATE             DATE;
   l_LAST_UPDATED_BY              NUMBER;
   l_CREATION_DATE                DATE;
   l_CREATED_BY                   NUMBER;
   l_LAST_UPDATE_LOGIN            NUMBER;
   l_ACTIVE_START_DATE            DATE;
   l_ACTIVE_END_DATE              DATE;
   l_ATTRIBUTE1                   VARCHAR2(150);
   l_ATTRIBUTE2                   VARCHAR2(150);
   l_ATTRIBUTE3                   VARCHAR2(150);
   l_ATTRIBUTE4                   VARCHAR2(150);
   l_ATTRIBUTE5                   VARCHAR2(150);
   l_ATTRIBUTE6                   VARCHAR2(150);
   l_ATTRIBUTE7                   VARCHAR2(150);
   l_ATTRIBUTE8                   VARCHAR2(150);
   l_ATTRIBUTE9                   VARCHAR2(150);
   l_ATTRIBUTE10                  VARCHAR2(150);
   l_ATTRIBUTE11                  VARCHAR2(150);
   l_ATTRIBUTE12                  VARCHAR2(150);
   l_ATTRIBUTE13                  VARCHAR2(150);
   l_ATTRIBUTE14                  VARCHAR2(150);
   l_ATTRIBUTE15                  VARCHAR2(150);
   l_ATTRIBUTE_CATEGORY           VARCHAR2(30);
   l_OBJECT_VERSION_NUMBER        NUMBER;
   l_PROPERTY_LOV_TYPE            VARCHAR2(30);
   l_SECURITY_GROUP_ID            NUMBER;
   l_MIGRATED_FLAG                VARCHAR2(1);
   l_VALID_FLAG                   VARCHAR2(1);
   l_FACTOR                       NUMBER;
   l_source_direction             VARCHAR2(1);
   l_object_direction             VARCHAR2(1);
   l_src_ctr_start_date           DATE;
   l_src_ctr_end_date             DATE;
   l_obj_ctr_start_date           DATE;
   l_obj_ctr_end_date             DATE;
   l_reading_date                 DATE;

   CURSOR c1(p_counter_id IN NUMBER) IS
   SELECT max(value_timestamp)
   FROM   csi_counter_readings
   WHERE  counter_id = p_counter_id;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  create_ctr_relationship_pvt;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line
         ( 'create_ctr_relationship_pvt'       ||'-'||
            p_api_version                              ||'-'||
            nvl(p_commit,FND_API.G_FALSE)              ||'-'||
            nvl(p_init_msg_list,FND_API.G_FALSE)       ||'-'||
            nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL) );
   END IF;

   if p_counter_relationships_rec.relationship_id = FND_API.G_MISS_NUM then
      l_relationship_id := null;
   else
      l_relationship_id := p_counter_relationships_rec.relationship_id;
   end if;

   if p_counter_relationships_rec.ctr_association_id = FND_API.G_MISS_NUM then
      l_ctr_association_id := null;
   else
      l_ctr_association_id := p_counter_relationships_rec.ctr_association_id;
   end if;

   if p_counter_relationships_rec.relationship_type_code = FND_API.G_MISS_CHAR then
      l_relationship_type_code := null;
   else
      l_relationship_type_code := p_counter_relationships_rec.relationship_type_code;
   end if;

   if p_counter_relationships_rec.source_counter_id = FND_API.G_MISS_NUM then
      l_source_counter_id := null;
   else
      l_source_counter_id := p_counter_relationships_rec.source_counter_id;
   end if;

   if p_counter_relationships_rec.object_counter_id = FND_API.G_MISS_NUM then
      l_object_counter_id := null;
   else
      l_object_counter_id := p_counter_relationships_rec.object_counter_id;
   end if;

   if p_counter_relationships_rec.security_group_id = FND_API.G_MISS_NUM then
      l_security_group_id := null;
   else
      l_security_group_id := p_counter_relationships_rec.security_group_id;
   end if;

   if nvl(p_counter_relationships_rec.active_start_date,FND_API.G_MISS_DATE) = FND_API.G_MISS_DATE then
      l_active_start_date := sysdate;
   else
      l_active_start_date := p_counter_relationships_rec.active_start_date;
   end if;

   if p_counter_relationships_rec.active_end_date = FND_API.G_MISS_DATE then
      l_active_end_date := null;
   else
      l_active_end_date := p_counter_relationships_rec.active_end_date;
   end if;

   if p_counter_relationships_rec.attribute1 = FND_API.G_MISS_CHAR then
      l_attribute1 := null;
   else
      l_attribute1 := p_counter_relationships_rec.attribute1;
   end if;

   if p_counter_relationships_rec.attribute2 = FND_API.G_MISS_CHAR then
      l_attribute2 := null;
   else
      l_attribute2 := p_counter_relationships_rec.attribute2;
   end if;

   if p_counter_relationships_rec.attribute3 = FND_API.G_MISS_CHAR then
      l_attribute3 := null;
   else
      l_attribute3 := p_counter_relationships_rec.attribute3;
   end if;

   if p_counter_relationships_rec.attribute4 = FND_API.G_MISS_CHAR then
      l_attribute4 := null;
   else
      l_attribute4 := p_counter_relationships_rec.attribute4;
   end if;

   if p_counter_relationships_rec.attribute5 = FND_API.G_MISS_CHAR then
      l_attribute5 := null;
   else
      l_attribute5 := p_counter_relationships_rec.attribute5;
   end if;

   if p_counter_relationships_rec.attribute6 = FND_API.G_MISS_CHAR then
      l_attribute6 := null;
   else
      l_attribute6 := p_counter_relationships_rec.attribute6;
   end if;

   if p_counter_relationships_rec.attribute7 = FND_API.G_MISS_CHAR then
      l_attribute7 := null;
   else
      l_attribute7 := p_counter_relationships_rec.attribute7;
   end if;

   if p_counter_relationships_rec.attribute8 = FND_API.G_MISS_CHAR then
      l_attribute8 := null;
   else
      l_attribute8 := p_counter_relationships_rec.attribute8;
   end if;

   if p_counter_relationships_rec.attribute9 = FND_API.G_MISS_CHAR then
      l_attribute9 := null;
   else
      l_attribute9 := p_counter_relationships_rec.attribute9;
   end if;

   if p_counter_relationships_rec.attribute10 = FND_API.G_MISS_CHAR then
      l_attribute10 := null;
   else
      l_attribute10 := p_counter_relationships_rec.attribute10;
   end if;

   if p_counter_relationships_rec.attribute11 = FND_API.G_MISS_CHAR then
      l_attribute11 := null;
   else
      l_attribute11 := p_counter_relationships_rec.attribute11;
   end if;

   if p_counter_relationships_rec.attribute12 = FND_API.G_MISS_CHAR then
      l_attribute12 := null;
   else
      l_attribute12 := p_counter_relationships_rec.attribute12;
   end if;

   if p_counter_relationships_rec.attribute13 = FND_API.G_MISS_CHAR then
      l_attribute13 := null;
   else
      l_attribute13 := p_counter_relationships_rec.attribute13;
   end if;

   if p_counter_relationships_rec.attribute14 = FND_API.G_MISS_CHAR then
      l_attribute14 := null;
   else
      l_attribute14 := p_counter_relationships_rec.attribute14;
   end if;

   if p_counter_relationships_rec.attribute15 = FND_API.G_MISS_CHAR then
      l_attribute15 := null;
   else
      l_attribute15 := p_counter_relationships_rec.attribute15;
   end if;

   if p_counter_relationships_rec.attribute_category = FND_API.G_MISS_CHAR then
      l_attribute_category := null;
   else
      l_attribute_category := p_counter_relationships_rec.attribute_category;
   end if;

   if p_counter_relationships_rec.migrated_flag = FND_API.G_MISS_CHAR then
      l_migrated_flag := null;
   else
      l_migrated_flag := p_counter_relationships_rec.migrated_flag;
   end if;

   if p_counter_relationships_rec.bind_variable_name = FND_API.G_MISS_CHAR then
      l_bind_variable_name := null;
   else
      l_bind_variable_name := p_counter_relationships_rec.bind_variable_name;
   end if;

   if p_counter_relationships_rec.factor = FND_API.G_MISS_NUM then
      l_factor := null;
   else
      l_factor := p_counter_relationships_rec.factor;
   end if;

csi_ctr_gen_utility_pvt.put_line('Relationship type code = '||l_relationship_type_code);

   validate_start_date(l_active_start_date);
   validate_lookups('CSI_CTR_RELATIONSHIP_TYPE_CODE', l_relationship_type_code);

   IF l_relationship_type_code = 'CONFIGURATION' THEN
      validate_ctr_relationship(l_source_counter_id, l_source_direction
                                ,l_src_ctr_start_date, l_src_ctr_end_date);
      validate_ctr_relationship(l_object_counter_id, l_object_direction
                                ,l_obj_ctr_start_date, l_obj_ctr_end_date);
      /* Validate direction */
      IF l_source_direction = 'B' and l_object_direction <> 'B'  THEN
         CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_REL_DIR');
      END IF;

      IF l_object_direction = 'B' and l_source_direction <> 'B' THEN
         CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_REL_DIR');
      END IF;

      IF l_active_start_date < l_src_ctr_start_date THEN
         CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_SOURCE_ST_DATE');
      ELSIF l_active_start_date < l_obj_ctr_start_date THEN
         CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_SOURCE_ST_DATE');
      END IF;

      IF l_src_ctr_end_date IS NOT NULL THEN
         IF l_active_start_date > l_src_ctr_end_date THEN
            CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_SOURCE_ST_DATE');
         END IF;
      END IF;

      IF l_obj_ctr_end_date IS NOT NULL THEN
         IF l_active_start_date > l_obj_ctr_end_date THEN
            CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_SOURCE_ST_DATE');
         END IF;
      END IF;

      OPEN c1(l_source_counter_id);
      FETCH c1 into l_reading_date;
      IF l_reading_date IS NOT  NULL THEN
         IF l_active_start_date < l_reading_date THEN
            CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_SOURCE_ST_DATE');
         END IF;
      END IF;
      CLOSE c1;

      OPEN c1(l_object_counter_id);
      FETCH c1 into l_reading_date;
      IF l_reading_date IS NOT  NULL THEN
         IF l_active_start_date < l_reading_date THEN
            CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_SOURCE_ST_DATE');
         END IF;
      END IF;
      CLOSE c1;

      /* A source counter cannot be a target counter */
      BEGIN
         SELECT 'N'
         INTO   l_valid_flag
         FROM   csi_counter_relationships
         WHERE  relationship_type_code = 'CONFIGURATION'
         AND    source_counter_id = l_object_counter_id
         AND    NVL(active_end_date, SYSDATE+1) > SYSDATE; --bug9160706

	 csi_ctr_gen_utility_pvt.put_line('Source relationship exists');--bug9160706

         CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_TARGET_CTR_EXIST');

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            csi_ctr_gen_utility_pvt.put_line('No source relationship exists');--bug9160706
	    NULL;
         WHEN TOO_MANY_ROWS THEN
            CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_TARGET_CTR_EXIST');

      END;
   ELSIF l_relationship_type_code = 'FORMULA' THEN
      IF l_source_counter_id IS NULL THEN
         CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_REQ_FORMULA_REF');
      END IF;
   END IF;

   /* Call the table Handler */
   CSI_COUNTER_RELATIONSHIP_PKG.Insert_Row(
	px_RELATIONSHIP_ID              => l_relationship_id
  	,p_CTR_ASSOCIATION_ID           => l_ctr_association_id
  	,p_RELATIONSHIP_TYPE_CODE       => l_relationship_type_code
  	,p_SOURCE_COUNTER_ID            => l_source_counter_id
  	,p_OBJECT_COUNTER_ID            => l_object_counter_id
  	,p_ACTIVE_START_DATE            => l_active_start_date
  	,p_ACTIVE_END_DATE              => l_active_end_date
  	,p_OBJECT_VERSION_NUMBER        => 1
        ,p_LAST_UPDATE_DATE             => sysdate
        ,p_LAST_UPDATED_BY              => FND_GLOBAL.USER_ID
        ,p_CREATION_DATE                => sysdate
        ,p_CREATED_BY                   => FND_GLOBAL.USER_ID
        ,p_LAST_UPDATE_LOGIN            => FND_GLOBAL.USER_ID
  	,p_ATTRIBUTE_CATEGORY           => l_attribute_category
        ,p_ATTRIBUTE1                   => l_attribute1
        ,p_ATTRIBUTE2                   => l_attribute2
        ,p_ATTRIBUTE3                   => l_attribute3
        ,p_ATTRIBUTE4                   => l_attribute4
        ,p_ATTRIBUTE5                   => l_attribute5
        ,p_ATTRIBUTE6                   => l_attribute6
        ,p_ATTRIBUTE7                   => l_attribute7
        ,p_ATTRIBUTE8                   => l_attribute8
        ,p_ATTRIBUTE9                   => l_attribute9
        ,p_ATTRIBUTE10                  => l_attribute10
        ,p_ATTRIBUTE11                  => l_attribute11
        ,p_ATTRIBUTE12                  => l_attribute12
        ,p_ATTRIBUTE13                  => l_attribute13
        ,p_ATTRIBUTE14                  => l_attribute14
        ,p_ATTRIBUTE15                  => l_attribute15
        ,p_SECURITY_GROUP_ID            => l_security_group_id
	,p_MIGRATED_FLAG                => l_migrated_flag
  	,p_BIND_VARIABLE_NAME           => l_bind_variable_name
  	,p_FACTOR                       => l_factor);

   IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
        ROLLBACK TO create_ctr_relationship_pvt;
        RETURN;
   END IF;

   /* End of table handler call */

   IF FND_API.to_Boolean(nvl(p_commit,FND_API.G_FALSE)) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and IF count is  get message info.
   FND_MSG_PUB.Count_And_Get
      ( p_count  =>  x_msg_count,
        p_data   =>  x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO create_ctr_relationship_pvt;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_ctr_relationship_pvt;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_ctr_relationship_pvt;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg
            ( G_PKG_NAME,
              l_api_name
            );
      END IF;
      FND_MSG_PUB.Count_And_Get
         ( p_count  => x_msg_count,
           p_data   => x_msg_data
         );
END create_counter_relationship;

--|---------------------------------------------------
--| procedure name: create_derived_filters
--| description :   procedure used to
--|                 create derived filters
--|---------------------------------------------------

PROCEDURE create_derived_filters
(
   p_api_version               IN     NUMBER
   ,p_commit                    IN     VARCHAR2
   ,p_init_msg_list             IN     VARCHAR2
   ,p_validation_level          IN     NUMBER
   ,p_ctr_derived_filters_tbl IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_tbl
   ,x_return_status                OUT    NOCOPY VARCHAR2
   ,x_msg_count                    OUT    NOCOPY NUMBER
   ,x_msg_data                     OUT    NOCOPY VARCHAR2
) IS

   l_api_name                   CONSTANT VARCHAR2(30)   := 'CREATE_DERIVED_FILTERS';
   l_api_version                CONSTANT NUMBER         := 1.0;

   l_dummy			VARCHAR2(1);
   -- l_debug_level                NUMBER;
   l_msg_data                   VARCHAR2(2000);
   l_msg_count                  NUMBER;

   --l_rec_number			NUMBER;
   l_ctr_derived_filters_rec	CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_rec;
   l_desc_flex                  CSI_CTR_DATASTRUCTURES_PUB.dff_rec_type;
   l_type			VARCHAR2(30);
   l_name			VARCHAR2(50);
   l_log_op			VARCHAR2(30);
   l_seq_no			NUMBER;
   l_return_status		VARCHAR2(1);
   l_valid_flag			VARCHAR2(1);

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  create_derived_filters;

   -- Check for freeze_flag in csi_install_parameters is set to 'Y'

   -- csi_ctr_gen_utility_pvt.check_ib_active;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   -- Check the profile option debug_level for debug message reporting
   -- l_debug_level:=fnd_profile.value('CSI_COUNTER_DEBUG_LEVEL');

   -- If debug_level = 1 then dump the procedure name
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'create_derived_filters');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 1) THEN
      csi_ctr_gen_utility_pvt.put_line( 'create_derived_filters'   ||
					p_api_version         ||'-'||
					p_commit              ||'-'||
                                        p_init_msg_list       ||'-'||
					p_validation_level );
      csi_ctr_gen_utility_pvt.dump_ctr_derived_filters_tbl(p_ctr_derived_filters_tbl);
   END IF;

   IF (p_ctr_derived_filters_tbl.count > 0) THEN
      FOR tab_row IN p_ctr_derived_filters_tbl.FIRST .. p_ctr_derived_filters_tbl.LAST
      LOOP
   l_ctr_derived_filters_rec := p_ctr_derived_filters_tbl(tab_row);

   BEGIN
      -- validate all counters
      SELECT nvl(type, 'REGULAR'), name
      into   l_type, l_name
      FROM   csi_counters_bc_v
      WHERE  counter_id = l_ctr_derived_filters_rec.counter_id;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_INVALID');

      -- validate all counter types are GROUP type
      IF l_type <> 'FORMULA' THEN
         csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_INV_GROUP_CTR','CTR_NAME',l_name);
      END IF;
   END;

   BEGIN
      -- validate all counter properties
      SELECT 'x'
      into   l_dummy
      FROM   csi_ctr_properties_bc_v
      WHERE  counter_property_id = l_ctr_derived_filters_rec.counter_property_id;

   EXCEPTION WHEN NO_DATA_FOUND THEN
      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_PROP_INVALID');
   END;

   -- validate LEFT_PARENT
   IF l_ctr_derived_filters_rec.LEFT_PARENT NOT IN ('(', '((', '(((', '((((', '(((((') THEN
      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_INV_DER_LEFT_PARENT',
					     'PARM',l_ctr_derived_filters_rec.LEFT_PARENT);
   END IF;

   -- validate RIGHT_PARENT
   IF l_ctr_derived_filters_rec.RIGHT_PARENT NOT IN (')', '))', ')))', '))))', ')))))') THEN
      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_INV_DER_RIGHT_PARENT',
					     'PARM',l_ctr_derived_filters_rec.RIGHT_PARENT);
   END IF;

   -- validate RELATIONAL_OPERATOR
   IF l_ctr_derived_filters_rec.RELATIONAL_OPERATOR NOT IN ('=', '<', '<=', '>', '>=', '!=', '<>') THEN
      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_INV_DER_REL_OPERATOR',
					     'PARM',l_ctr_derived_filters_rec.RELATIONAL_OPERATOR);
   END IF;

   -- validate LOGICAL_OPERATOR
   -- l_log_op := upper(l_ctr_derived_filters_rec.LOGICAL_OPERATOR);

   IF l_ctr_derived_filters_rec.LOGICAL_OPERATOR = FND_API.G_MISS_CHAR then
      l_log_op := null;
   ELSE
      l_log_op := upper(l_ctr_derived_filters_rec.LOGICAL_OPERATOR);
   END IF;

   IF l_log_op IS NOT NULL THEN
      IF l_log_op NOT IN ('AND', 'OR') THEN
         csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_INV_DER_LOG_OPERATOR',
  					     'PARM',l_ctr_derived_filters_rec.LOGICAL_OPERATOR);
      END IF;
   END IF;

   -- initialize descritive flexfield
   --csi_ctr_gen_utility_pvt.Initialize_Desc_Flex(l_desc_flex);

   -- validate Descritive Flexfields
/*
   csi_ctr_gen_utility_pvt.Is_DescFlex_Valid
   (
      p_api_name => l_api_name,
      p_appl_short_name => 'CSI',
      p_desc_flex_name => 'CSI_COUNTER_DERIVED_FILTERS',
      p_seg_partial_name => 'ATTRIBUTE',
      p_num_of_attributes => 15,
      p_seg_values => l_desc_flex
   );
*/
   -- get the SEQ_NO
   IF l_ctr_derived_filters_rec.seq_no = FND_API.G_MISS_NUM then
      l_ctr_derived_filters_rec.seq_no := null;
   END IF;

   IF l_ctr_derived_filters_rec.SEQ_NO IS NULL THEN
      SELECT nvl(max(seq_no), 0) + 1
             into l_seq_no
      FROM   CSI_COUNTER_DERIVED_FILTERS
      WHERE  counter_id = l_ctr_derived_filters_rec.COUNTER_ID;
   ELSE
      BEGIN
         SELECT	'x'
                into l_dummy
         FROM	CSI_COUNTER_DERIVED_FILTERS
         WHERE	counter_id = l_ctr_derived_filters_rec.COUNTER_ID
                AND seq_no = l_ctr_derived_filters_rec.SEQ_NO;

         -- this means that for this counter, there is one another
         -- derived filter record with the same sequence number.
	 -- Raise error.
         csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_DUP_DERFILTER_SEQNO',
						'SEQNO',to_char(l_ctr_derived_filters_rec.SEQ_NO),
						'CTR_NAME',l_name);

      EXCEPTION WHEN NO_DATA_FOUND THEN
         -- good. you can proceed.
         NULL;
      END;
   END IF;

   -- call table handler here
   CSI_CTR_DERIVED_FILTERS_PKG.Insert_Row
   (
      l_ctr_derived_filters_rec.COUNTER_DERIVED_FILTER_ID
      ,l_ctr_derived_filters_rec.COUNTER_ID
      ,l_seq_no
      ,l_ctr_derived_filters_rec.LEFT_PARENT
      ,l_ctr_derived_filters_rec.COUNTER_PROPERTY_ID
      ,l_ctr_derived_filters_rec.RELATIONAL_OPERATOR
      ,l_ctr_derived_filters_rec.RIGHT_VALUE
      ,l_ctr_derived_filters_rec.RIGHT_PARENT
      ,l_ctr_derived_filters_rec.LOGICAL_OPERATOR
      ,l_ctr_derived_filters_rec.START_DATE_ACTIVE
      ,l_ctr_derived_filters_rec.END_DATE_ACTIVE
      ,1
      ,sysdate
      ,FND_GLOBAL.USER_ID
      ,sysdate
      ,FND_GLOBAL.USER_ID
      ,FND_GLOBAL.USER_ID
      ,l_ctr_derived_filters_rec.ATTRIBUTE1
      ,l_ctr_derived_filters_rec.ATTRIBUTE2
      ,l_ctr_derived_filters_rec.ATTRIBUTE3
      ,l_ctr_derived_filters_rec.ATTRIBUTE4
      ,l_ctr_derived_filters_rec.ATTRIBUTE5
      ,l_ctr_derived_filters_rec.ATTRIBUTE6
      ,l_ctr_derived_filters_rec.ATTRIBUTE7
      ,l_ctr_derived_filters_rec.ATTRIBUTE8
      ,l_ctr_derived_filters_rec.ATTRIBUTE9
      ,l_ctr_derived_filters_rec.ATTRIBUTE10
      ,l_ctr_derived_filters_rec.ATTRIBUTE11
      ,l_ctr_derived_filters_rec.ATTRIBUTE12
      ,l_ctr_derived_filters_rec.ATTRIBUTE13
      ,l_ctr_derived_filters_rec.ATTRIBUTE14
      ,l_ctr_derived_filters_rec.ATTRIBUTE15
      ,l_ctr_derived_filters_rec.ATTRIBUTE_CATEGORY
      ,l_ctr_derived_filters_rec.SECURITY_GROUP_ID
      ,l_ctr_derived_filters_rec.MIGRATED_FLAG
   );
    END LOOP;
  END IF;
   --Check if the counter can be marked "valid" with the
   --addition of this filter.
   csi_ctr_gen_utility_pvt.Validate_GrpOp_ctr
   (
      p_api_version => 1.0,
      p_commit => FND_API.G_FALSE,
      p_validation_level => FND_API.G_VALID_LEVEL_NONE,
      x_return_status => l_return_status,
      x_msg_count	=> l_msg_count,
      x_msg_data => l_msg_data,
      p_counter_id => l_ctr_derived_filters_rec.COUNTER_ID,
      x_valid_flag => l_valid_flag
   );

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   UPDATE	csi_counters_b
   SET	valid_flag = decode(l_valid_flag, 'Y', 'Y', 'N')
   WHERE	counter_id = l_ctr_derived_filters_rec.COUNTER_ID;

   --l_ctr_derived_filters_rec.OBJECT_VERSION_NUMBER := 1;

   -- End of API body

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   FND_MSG_PUB.Count_And_Get
      (p_count => x_msg_count,
       p_data  => x_msg_data
      );

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		ROLLBACK TO create_derived_filters;
		FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count,
                 p_data  => x_msg_data
                );

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		ROLLBACK TO create_derived_filters;
		FND_MSG_PUB.Count_And_Get
      			(p_count => x_msg_count,
                 p_data  => x_msg_data
                );
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		ROLLBACK TO create_derived_filters;
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.Add_Exc_Msg
				(G_PKG_NAME,
				 l_api_name
				);
		END IF;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count,
             p_data  => x_msg_data
            );

END create_derived_filters;


--|---------------------------------------------------
--| procedure name: update_counter_group
--| description :   procedure used to
--|                 update counter group
--|---------------------------------------------------

PROCEDURE update_counter_group
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_counter_groups_rec        IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.counter_groups_rec
    ,x_return_status                OUT    NOCOPY VARCHAR2
    ,x_msg_count                    OUT    NOCOPY NUMBER
    ,x_msg_data                     OUT    NOCOPY VARCHAR2
 ) IS

   CURSOR cur_group_rec(p_counter_group_id IN NUMBER) IS
   SELECT name
          ,description
          ,template_flag
          ,cp_service_id
          ,customer_product_id
          ,last_update_date
          ,last_updated_by
          ,creation_date
          ,created_by
          ,last_update_login
          ,start_date_active
          ,end_date_active
          ,attribute1
          ,attribute2
          ,attribute3
          ,attribute4
          ,attribute5
          ,attribute6
          ,attribute7
          ,attribute8
          ,attribute9
          ,attribute10
          ,attribute11
          ,attribute12
          ,attribute13
          ,attribute14
          ,attribute15
          ,context
          ,object_version_number
          ,created_from_ctr_grp_tmpl_id
          ,association_type
          ,source_object_code
          ,source_object_id
          ,source_counter_group_id
          ,security_group_id
   FROM  cs_csi_counter_groups
   WHERE counter_group_id = p_counter_group_id
   FOR UPDATE OF OBJECT_VERSION_NUMBER;
   l_old_counter_groups_rec  cur_group_rec%ROWTYPE;

   l_api_name                      CONSTANT VARCHAR2(30)   := 'UPDATE_COUNTER_GROUP';
   l_api_version                   CONSTANT NUMBER         := 1.0;
   l_msg_data                      VARCHAR2(2000);
   l_msg_index                     NUMBER;
   l_msg_count                     NUMBER;
   -- l_debug_level                   NUMBER;

   l_counter_groups_rec            CSI_CTR_DATASTRUCTURES_PUB.counter_groups_rec;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  update_counter_group_pvt;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   --
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line
         ( 'update_counter_group_pvt'              ||'-'||
           p_api_version                              ||'-'||
           nvl(p_commit,FND_API.G_FALSE)              ||'-'||
           nvl(p_init_msg_list,FND_API.G_FALSE)       ||'-'||
           nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL) );
   END IF;

   /* Start of API Body */
   OPEN cur_group_rec(p_counter_groups_rec.counter_group_id);
   FETCH cur_group_rec INTO l_old_counter_groups_rec;
   IF  (l_old_counter_groups_rec.object_version_number <> nvl(p_counter_groups_rec.OBJECT_VERSION_NUMBER,0)) THEN
      FND_MESSAGE.Set_Name('CSI', 'CSI_API_OBJ_VER_MISMATCH');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   CLOSE cur_group_rec;

   -- IF SQL%NOTFOUND THEN
   --    CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_GRP_NOTEXISTS');
   -- END IF;

   l_counter_groups_rec := p_counter_groups_rec;

   IF p_counter_groups_rec.name IS NULL THEN
      l_counter_groups_rec.name:= l_old_counter_groups_rec.name;
   ELSIF p_counter_groups_rec.name = FND_API.G_MISS_CHAR THEN
      l_counter_groups_rec.name := NULL;
   END IF;

   IF p_counter_groups_rec.description IS NULL THEN
      l_counter_groups_rec.description := l_old_counter_groups_rec.description;
   ELSIF p_counter_groups_rec.description = FND_API.G_MISS_CHAR THEN
      l_counter_groups_rec.description := NULL;
   END IF;

   IF p_counter_groups_rec.start_date_active IS NULL THEN
      l_counter_groups_rec.start_date_active := l_old_counter_groups_rec.start_date_active;
   ELSIF p_counter_groups_rec.start_date_active = FND_API.G_MISS_DATE THEN
      l_counter_groups_rec.start_date_active := NULL;
   END IF;

   IF p_counter_groups_rec.end_date_active IS NULL THEN
      l_counter_groups_rec.end_date_active := l_old_counter_groups_rec.end_date_active;
   ELSIF p_counter_groups_rec.end_date_active = FND_API.G_MISS_DATE THEN
      l_counter_groups_rec.end_date_active := NULL;
   END IF;

   if l_counter_groups_rec.end_date_active IS NOT NULL then
      if l_counter_groups_rec.end_date_active < l_counter_groups_rec.start_date_active then
         CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_ALL_END_DATE');
      end if;
   end if;

   IF p_counter_groups_rec.attribute1 IS NULL THEN
      l_counter_groups_rec.attribute1 := l_old_counter_groups_rec.attribute1;
   ELSIF p_counter_groups_rec.attribute1 = FND_API.G_MISS_CHAR THEN
      l_counter_groups_rec.attribute1 := NULL;
   END IF;

   IF p_counter_groups_rec.attribute2 IS NULL THEN
      l_counter_groups_rec.attribute2 := l_old_counter_groups_rec.attribute2;
   ELSIF p_counter_groups_rec.attribute2 = FND_API.G_MISS_CHAR THEN
      l_counter_groups_rec.attribute2 := NULL;
   END IF;

   IF p_counter_groups_rec.attribute3 IS NULL THEN
      l_counter_groups_rec.attribute3 := l_old_counter_groups_rec.attribute3;
   ELSIF p_counter_groups_rec.attribute3 = FND_API.G_MISS_CHAR THEN
      l_counter_groups_rec.attribute3 := NULL;
   END IF;

   IF p_counter_groups_rec.attribute4 IS NULL THEN
      l_counter_groups_rec.attribute4 := l_old_counter_groups_rec.attribute4;
   ELSIF p_counter_groups_rec.attribute4 = FND_API.G_MISS_CHAR THEN
      l_counter_groups_rec.attribute4 := NULL;
   END IF;

   IF p_counter_groups_rec.attribute5 IS NULL THEN
      l_counter_groups_rec.attribute5 := l_old_counter_groups_rec.attribute5;
   ELSIF p_counter_groups_rec.attribute5 = FND_API.G_MISS_CHAR THEN
      l_counter_groups_rec.attribute5 := NULL;
   END IF;

   IF p_counter_groups_rec.attribute6 IS NULL THEN
      l_counter_groups_rec.attribute6 := l_old_counter_groups_rec.attribute6;
   ELSIF p_counter_groups_rec.attribute6 = FND_API.G_MISS_CHAR THEN
      l_counter_groups_rec.attribute6 := NULL;
   END IF;

   IF p_counter_groups_rec.attribute7 IS NULL THEN
      l_counter_groups_rec.attribute7 := l_old_counter_groups_rec.attribute6;
   ELSIF p_counter_groups_rec.attribute7 = FND_API.G_MISS_CHAR THEN
      l_counter_groups_rec.attribute7 := NULL;
   END IF;

   IF p_counter_groups_rec.attribute8 IS NULL THEN
      l_counter_groups_rec.attribute8 := l_old_counter_groups_rec.attribute8;
   ELSIF p_counter_groups_rec.attribute8 = FND_API.G_MISS_CHAR THEN
      l_counter_groups_rec.attribute8 := NULL;
   END IF;

   IF p_counter_groups_rec.attribute9 IS NULL THEN
      l_counter_groups_rec.attribute9 := l_old_counter_groups_rec.attribute9;
   ELSIF p_counter_groups_rec.attribute9 = FND_API.G_MISS_CHAR THEN
      l_counter_groups_rec.attribute9 := NULL;
   END IF;

   IF p_counter_groups_rec.attribute10 IS NULL THEN
      l_counter_groups_rec.attribute10 := l_old_counter_groups_rec.attribute10;
   ELSIF p_counter_groups_rec.attribute10 = FND_API.G_MISS_CHAR THEN
      l_counter_groups_rec.attribute10 := NULL;
   END IF;

   IF p_counter_groups_rec.attribute11 IS NULL THEN
      l_counter_groups_rec.attribute11 := l_old_counter_groups_rec.attribute11;
   ELSIF p_counter_groups_rec.attribute11 = FND_API.G_MISS_CHAR THEN
      l_counter_groups_rec.attribute11 := NULL;
   END IF;

   IF p_counter_groups_rec.attribute12 IS NULL THEN
      l_counter_groups_rec.attribute12 := l_old_counter_groups_rec.attribute12;
   ELSIF p_counter_groups_rec.attribute12 = FND_API.G_MISS_CHAR THEN
      l_counter_groups_rec.attribute12 := NULL;
   END IF;

   IF p_counter_groups_rec.attribute13 IS NULL THEN
      l_counter_groups_rec.attribute13 := l_old_counter_groups_rec.attribute13;
   ELSIF p_counter_groups_rec.attribute13 = FND_API.G_MISS_CHAR THEN
      l_counter_groups_rec.attribute13 := NULL;
   END IF;

   IF p_counter_groups_rec.attribute14 IS NULL THEN
      l_counter_groups_rec.attribute14 := l_old_counter_groups_rec.attribute14;
   ELSIF p_counter_groups_rec.attribute14 = FND_API.G_MISS_CHAR THEN
      l_counter_groups_rec.attribute14 := NULL;
   END IF;

   IF p_counter_groups_rec.attribute15 IS NULL THEN
      l_counter_groups_rec.attribute15 := l_old_counter_groups_rec.attribute15;
   ELSIF p_counter_groups_rec.attribute15 = FND_API.G_MISS_CHAR THEN
      l_counter_groups_rec.attribute15 := NULL;
   END IF;

   IF p_counter_groups_rec.context IS NULL THEN
      l_counter_groups_rec.context := l_old_counter_groups_rec.context;
   ELSIF p_counter_groups_rec.context = FND_API.G_MISS_CHAR THEN
      l_counter_groups_rec.context := NULL;
   END IF;

   IF p_counter_groups_rec.association_type IS NULL THEN
      l_counter_groups_rec.association_type := l_old_counter_groups_rec.association_type;
   ELSIF p_counter_groups_rec.association_type = FND_API.G_MISS_CHAR THEN
      l_counter_groups_rec.association_type := NULL;
   END IF;

   IF p_counter_groups_rec.source_object_code IS NULL THEN
      l_counter_groups_rec.source_object_code := l_old_counter_groups_rec.source_object_code;
   ELSIF p_counter_groups_rec.source_object_code = FND_API.G_MISS_CHAR THEN
      l_counter_groups_rec.source_object_code := NULL;
   END IF;

   IF p_counter_groups_rec.source_object_id IS NULL THEN
      l_counter_groups_rec.source_object_id := l_old_counter_groups_rec.source_object_id;
   ELSIF p_counter_groups_rec.source_object_id = FND_API.G_MISS_NUM THEN
      l_counter_groups_rec.source_object_id := NULL;
   END IF;

   IF p_counter_groups_rec.source_counter_group_id IS NULL THEN
      l_counter_groups_rec.source_counter_group_id := l_old_counter_groups_rec.source_counter_group_id;
   ELSIF p_counter_groups_rec.source_counter_group_id = FND_API.G_MISS_NUM THEN
      l_counter_groups_rec.source_counter_group_id := NULL;
   END IF;

   IF p_counter_groups_rec.security_group_id IS NULL THEN
      l_counter_groups_rec.security_group_id := l_old_counter_groups_rec.security_group_id;
   ELSIF p_counter_groups_rec.security_group_id = FND_API.G_MISS_NUM THEN
      l_counter_groups_rec.security_group_id := NULL;
   END IF;

   -- Counter group name is not updateable

   IF l_counter_groups_rec.name <> l_old_counter_groups_rec.name THEN
       CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_GRP_NOT_UPDATABLE');
   END IF;


   -- Call the table handler
   CSI_GROUPING_PKG.Update_Row(
        p_COUNTER_GROUP_ID 		=> p_counter_groups_rec.counter_group_id
        ,p_NAME                         => p_counter_groups_rec.name
        ,p_DESCRIPTION                  => p_counter_groups_rec.description
        ,p_TEMPLATE_FLAG                => p_counter_groups_rec.template_flag
        ,p_CP_SERVICE_ID                => NULL
        ,p_CUSTOMER_PRODUCT_ID          => NULL
        ,p_LAST_UPDATE_DATE             => sysdate
        ,p_LAST_UPDATED_BY              => FND_GLOBAL.USER_ID
        ,p_CREATION_DATE                => p_counter_groups_rec.creation_date
        ,p_CREATED_BY                   => p_counter_groups_rec.created_by
        ,p_LAST_UPDATE_LOGIN            => FND_GLOBAL.USER_ID
        ,p_START_DATE_ACTIVE            => p_counter_groups_rec.start_date_active
        ,p_END_DATE_ACTIVE              => p_counter_groups_rec.end_date_active
        ,p_ATTRIBUTE1                   => p_counter_groups_rec.attribute1
        ,p_ATTRIBUTE2                   => p_counter_groups_rec.attribute2
        ,p_ATTRIBUTE3                   => p_counter_groups_rec.attribute3
        ,p_ATTRIBUTE4                   => p_counter_groups_rec.attribute4
        ,p_ATTRIBUTE5                   => p_counter_groups_rec.attribute5
        ,p_ATTRIBUTE6                   => p_counter_groups_rec.attribute6
        ,p_ATTRIBUTE7                   => p_counter_groups_rec.attribute7
        ,p_ATTRIBUTE8                   => p_counter_groups_rec.attribute8
        ,p_ATTRIBUTE9                   => p_counter_groups_rec.attribute9
        ,p_ATTRIBUTE10                  => p_counter_groups_rec.attribute10
        ,p_ATTRIBUTE11                  => p_counter_groups_rec.attribute11
        ,p_ATTRIBUTE12                  => p_counter_groups_rec.attribute12
        ,p_ATTRIBUTE13                  => p_counter_groups_rec.attribute13
        ,p_ATTRIBUTE14                  => p_counter_groups_rec.attribute14
        ,p_ATTRIBUTE15                  => p_counter_groups_rec.attribute15
        ,p_CONTEXT                      => p_counter_groups_rec.context
        ,p_OBJECT_VERSION_NUMBER        => p_counter_groups_rec.object_version_number + 1
	,p_CREATED_FROM_CTR_GRP_TMPL_ID => p_counter_groups_rec.created_from_ctr_grp_tmpl_id
	,p_ASSOCIATION_TYPE             => p_counter_groups_rec.association_type
	,p_SOURCE_OBJECT_CODE           => p_counter_groups_rec.source_object_code
	,p_SOURCE_OBJECT_ID             => p_counter_groups_rec.source_object_id
	,p_SOURCE_COUNTER_GROUP_ID      => p_counter_groups_rec.source_counter_group_id
	,p_SECURITY_GROUP_ID            => p_counter_groups_rec.security_group_id
        );

   IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
        ROLLBACK TO update_counter_group_pvt;
        RETURN;
   END IF;


   /* End of API Body */

   IF FND_API.to_Boolean(nvl(p_commit,FND_API.G_FALSE)) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and IF count is  get message info.
   FND_MSG_PUB.Count_And_Get
      ( p_count  =>  x_msg_count,
        p_data   =>  x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO update_counter_group_pvt;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_counter_group_pvt;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_counter_group_pvt;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg
            ( G_PKG_NAME,
              l_api_name
            );
      END IF;
      FND_MSG_PUB.Count_And_Get
         ( p_count  => x_msg_count,
           p_data   => x_msg_data
         );
END update_counter_group;

--|---------------------------------------------------
--| procedure name: update_item_association
--| description :   procedure used to
--|                 update item association to
--|                 counter group or counters
--|---------------------------------------------------

PROCEDURE update_item_association
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_ctr_item_associations_rec IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_item_associations_rec
    ,x_return_status                OUT    NOCOPY VARCHAR2
    ,x_msg_count                    OUT    NOCOPY NUMBER
    ,x_msg_data                     OUT    NOCOPY VARCHAR2
 ) IS

   CURSOR cur_item_assoc_rec(p_ctr_association_id IN NUMBER) IS
   SELECT group_id
	  ,inventory_item_id
  	  ,object_version_number
	  ,last_update_date
  	  ,last_updated_by
  	  ,last_update_login
	  ,creation_date
	  ,created_by
	  ,attribute1
	  ,attribute2
	  ,attribute3
	  ,attribute4
	  ,attribute5
	  ,attribute6
	  ,attribute7
	  ,attribute8
	  ,attribute9
	  ,attribute10
	  ,attribute11
	  ,attribute12
	  ,attribute13
	  ,attribute14
	  ,attribute15
	  ,attribute_category
	  ,security_group_id
	  ,migrated_flag
	  ,counter_id
	  ,start_date_active
	  ,end_date_active
	  ,usage_rate
	  -- ,association_type
  	  ,use_past_reading
	  ,associated_to_group
	  ,maint_organization_id
	  ,primary_failure_flag
   FROM  csi_ctr_item_associations_v
   WHERE ctr_association_id = p_ctr_association_id
   FOR UPDATE OF OBJECT_VERSION_NUMBER;
   l_old_item_associations_rec  cur_item_assoc_rec%ROWTYPE;

   l_api_name                      CONSTANT VARCHAR2(30)   := 'UPDATE_ITEM_ASSOCIATION';
   l_api_version                   CONSTANT NUMBER         := 1.0;
   l_msg_data                      VARCHAR2(2000);
   l_msg_index                     NUMBER;
   l_msg_count                     NUMBER;
   -- l_debug_level                   NUMBER;
   l_group_id                      NUMBER;
   l_counter_id                    NUMBER;
   l_inventory_item_id             NUMBER;
   l_associated_to_group           VARCHAR2(1);
   l_item_found                    VARCHAR2(1);
   l_item_invalid                  VARCHAR2(1);
   l_item_associations_rec         CSI_CTR_DATASTRUCTURES_PUB.ctr_item_associations_rec;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  update_item_association_pvt;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   --
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'update_item_association_pvt'           ||'-'||
                                     p_api_version                              ||'-'||
                                     nvl(p_commit,FND_API.G_FALSE)              ||'-'||
                                     nvl(p_init_msg_list,FND_API.G_FALSE)       ||'-'||
                                     nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL) );
   END IF;

   /* Start of API Body */
   OPEN cur_item_assoc_rec(p_ctr_item_associations_rec.ctr_association_id);
   FETCH cur_item_assoc_rec INTO l_old_item_associations_rec;
   IF  (l_old_item_associations_rec.object_version_number <> nvl(p_ctr_item_associations_rec.OBJECT_VERSION_NUMBER,0)) THEN
      FND_MESSAGE.Set_Name('CSI', 'CSI_API_OBJ_VER_MISMATCH');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   CLOSE cur_item_assoc_rec;

   -- IF SQL%NOTFOUND THEN
   --     CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_ITEM_ASSOC_NOTEXISTS');
   -- END IF;

   l_item_associations_rec := p_ctr_item_associations_rec;

   IF p_ctr_item_associations_rec.group_id  IS NULL THEN
      l_item_associations_rec.group_id := l_old_item_associations_rec.group_id;
   ELSIF p_ctr_item_associations_rec.group_id = FND_API.G_MISS_NUM THEN
      l_item_associations_rec.group_id := NULL;
   END IF;

   IF p_ctr_item_associations_rec.inventory_item_id IS NULL THEN
      l_item_associations_rec.inventory_item_id := l_old_item_associations_rec.inventory_item_id;
   ELSIF p_ctr_item_associations_rec.inventory_item_id = FND_API.G_MISS_NUM THEN
      l_item_associations_rec.inventory_item_id := NULL;
   END IF;

   IF p_ctr_item_associations_rec.start_date_active IS NULL THEN
      l_item_associations_rec.start_date_active := l_old_item_associations_rec.start_date_active;
   ELSIF p_ctr_item_associations_rec.start_date_active = FND_API.G_MISS_DATE THEN
      l_item_associations_rec.start_date_active := NULL;
   END IF;

   IF p_ctr_item_associations_rec.end_date_active IS NULL THEN
      l_item_associations_rec.end_date_active := l_old_item_associations_rec.end_date_active;
   ELSIF p_ctr_item_associations_rec.end_date_active = FND_API.G_MISS_DATE THEN
      l_item_associations_rec.end_date_active := NULL;
   END IF;

   if l_item_associations_rec.end_date_active IS NOT NULL then
      if l_item_associations_rec.end_date_active < l_item_associations_rec.start_date_active then
         CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_ALL_END_DATE');
      end if;
   end if;

   IF p_ctr_item_associations_rec.attribute1 IS NULL THEN
      l_item_associations_rec.attribute1 := l_old_item_associations_rec.attribute1;
   ELSIF p_ctr_item_associations_rec.attribute1 = FND_API.G_MISS_CHAR THEN
      l_item_associations_rec.attribute1 := NULL;
   END IF;

   IF p_ctr_item_associations_rec.attribute2 IS NULL THEN
      l_item_associations_rec.attribute2 := l_old_item_associations_rec.attribute2;
   ELSIF p_ctr_item_associations_rec.attribute2 = FND_API.G_MISS_CHAR THEN
      l_item_associations_rec.attribute2 := NULL;
   END IF;

   IF p_ctr_item_associations_rec.attribute3 IS NULL THEN
      l_item_associations_rec.attribute3 := l_old_item_associations_rec.attribute3;
   ELSIF p_ctr_item_associations_rec.attribute3 = FND_API.G_MISS_CHAR THEN
      l_item_associations_rec.attribute3 := NULL;
   END IF;

   IF p_ctr_item_associations_rec.attribute4 IS NULL THEN
      l_item_associations_rec.attribute4 := l_old_item_associations_rec.attribute4;
   ELSIF p_ctr_item_associations_rec.attribute4 = FND_API.G_MISS_CHAR THEN
      l_item_associations_rec.attribute4 := NULL;
   END IF;

   IF p_ctr_item_associations_rec.attribute5 IS NULL THEN
      l_item_associations_rec.attribute5 := l_old_item_associations_rec.attribute5;
   ELSIF p_ctr_item_associations_rec.attribute5 = FND_API.G_MISS_CHAR THEN
      l_item_associations_rec.attribute5 := NULL;
   END IF;

   IF p_ctr_item_associations_rec.attribute6 IS NULL THEN
      l_item_associations_rec.attribute6 := l_old_item_associations_rec.attribute6;
   ELSIF p_ctr_item_associations_rec.attribute6 = FND_API.G_MISS_CHAR THEN
      l_item_associations_rec.attribute6 := NULL;
   END IF;

   IF p_ctr_item_associations_rec.attribute7 IS NULL THEN
      l_item_associations_rec.attribute7 := l_old_item_associations_rec.attribute7;
   ELSIF p_ctr_item_associations_rec.attribute7 = FND_API.G_MISS_CHAR THEN
      l_item_associations_rec.attribute7 := NULL;
   END IF;

   IF p_ctr_item_associations_rec.attribute8 IS NULL THEN
      l_item_associations_rec.attribute8 := l_old_item_associations_rec.attribute8;
   ELSIF p_ctr_item_associations_rec.attribute8 = FND_API.G_MISS_CHAR THEN
      l_item_associations_rec.attribute8 := NULL;
   END IF;

   IF p_ctr_item_associations_rec.attribute9 IS NULL THEN
      l_item_associations_rec.attribute9 := l_old_item_associations_rec.attribute9;
   ELSIF p_ctr_item_associations_rec.attribute9 = FND_API.G_MISS_CHAR THEN
      l_item_associations_rec.attribute9 := NULL;
   END IF;

   IF p_ctr_item_associations_rec.attribute10 IS NULL THEN
      l_item_associations_rec.attribute10 := l_old_item_associations_rec.attribute10;
   ELSIF p_ctr_item_associations_rec.attribute10 = FND_API.G_MISS_CHAR THEN
      l_item_associations_rec.attribute10 := NULL;
   END IF;

   IF p_ctr_item_associations_rec.attribute11 IS NULL THEN
      l_item_associations_rec.attribute11 := l_old_item_associations_rec.attribute11;
   ELSIF p_ctr_item_associations_rec.attribute11 = FND_API.G_MISS_CHAR THEN
      l_item_associations_rec.attribute11 := NULL;
   END IF;

   IF p_ctr_item_associations_rec.attribute12 IS NULL THEN
      l_item_associations_rec.attribute12 := l_old_item_associations_rec.attribute12;
   ELSIF p_ctr_item_associations_rec.attribute12 = FND_API.G_MISS_CHAR THEN
      l_item_associations_rec.attribute12 := NULL;
   END IF;

   IF p_ctr_item_associations_rec.attribute13 IS NULL THEN
      l_item_associations_rec.attribute13 := l_old_item_associations_rec.attribute13;
   ELSIF p_ctr_item_associations_rec.attribute13 = FND_API.G_MISS_CHAR THEN
      l_item_associations_rec.attribute13 := NULL;
   END IF;

   IF p_ctr_item_associations_rec.attribute14 IS NULL THEN
      l_item_associations_rec.attribute14 := l_old_item_associations_rec.attribute14;
   ELSIF p_ctr_item_associations_rec.attribute14 = FND_API.G_MISS_CHAR THEN
      l_item_associations_rec.attribute14 := NULL;
   END IF;

   IF p_ctr_item_associations_rec.attribute15 IS NULL THEN
      l_item_associations_rec.attribute15 := l_old_item_associations_rec.attribute15;
   ELSIF p_ctr_item_associations_rec.attribute15 = FND_API.G_MISS_CHAR THEN
      l_item_associations_rec.attribute15 := NULL;
   END IF;

   IF p_ctr_item_associations_rec.attribute_category IS NULL THEN
      l_item_associations_rec.attribute_category := l_old_item_associations_rec.attribute_category;
   ELSIF p_ctr_item_associations_rec.attribute_category = FND_API.G_MISS_CHAR THEN
      l_item_associations_rec.attribute_category := NULL;
   END IF;

   IF p_ctr_item_associations_rec.associated_to_group IS NULL THEN
      l_item_associations_rec.associated_to_group := l_old_item_associations_rec.associated_to_group;
   ELSIF p_ctr_item_associations_rec.associated_to_group = FND_API.G_MISS_CHAR THEN
      l_item_associations_rec.associated_to_group := NULL;
   END IF;

   IF p_ctr_item_associations_rec.usage_rate IS NULL THEN
      l_item_associations_rec.usage_rate := l_old_item_associations_rec.usage_rate;
   ELSIF p_ctr_item_associations_rec.usage_rate = FND_API.G_MISS_NUM THEN
      l_item_associations_rec.usage_rate := NULL;
   END IF;

   IF p_ctr_item_associations_rec.counter_id IS NULL THEN
      l_item_associations_rec.counter_id := l_old_item_associations_rec.counter_id;
   ELSIF p_ctr_item_associations_rec.counter_id = FND_API.G_MISS_NUM THEN
      l_item_associations_rec.counter_id := NULL;
   END IF;

   IF p_ctr_item_associations_rec.security_group_id IS NULL THEN
      l_item_associations_rec.security_group_id := l_old_item_associations_rec.security_group_id;
   ELSIF p_ctr_item_associations_rec.security_group_id = FND_API.G_MISS_NUM THEN
      l_item_associations_rec.security_group_id := NULL;

   END IF;

   IF p_ctr_item_associations_rec.migrated_flag IS NULL THEN
      l_item_associations_rec.migrated_flag := l_old_item_associations_rec.migrated_flag;
   ELSIF p_ctr_item_associations_rec.migrated_flag = FND_API.G_MISS_CHAR THEN
      l_item_associations_rec.migrated_flag := NULL;
   END IF;

   IF p_ctr_item_associations_rec.use_past_reading IS NULL THEN
      l_item_associations_rec.use_past_reading := l_old_item_associations_rec.use_past_reading;
   ELSIF p_ctr_item_associations_rec.use_past_reading = FND_API.G_MISS_NUM THEN
      l_item_associations_rec.use_past_reading := NULL;
   END IF;

   IF p_ctr_item_associations_rec.maint_organization_id IS NULL THEN
      l_item_associations_rec.maint_organization_id := l_old_item_associations_rec.maint_organization_id;
   ELSIF p_ctr_item_associations_rec.maint_organization_id = FND_API.G_MISS_NUM THEN
      l_item_associations_rec.maint_organization_id := NULL;
   END IF;

   IF p_ctr_item_associations_rec.primary_failure_flag IS NULL THEN
      l_item_associations_rec.primary_failure_flag := l_old_item_associations_rec.primary_failure_flag;
   ELSIF p_ctr_item_associations_rec.primary_failure_flag = FND_API.G_MISS_CHAR THEN
      l_item_associations_rec.primary_failure_flag := NULL;
   END IF;

   IF l_item_associations_rec.group_id IS NOT NULL THEN
      IF l_item_associations_rec.inventory_item_id IS NOT NULL THEN
         IF l_item_associations_rec.inventory_item_id <> l_old_item_associations_rec.inventory_item_id THEN
            BEGIN
               SELECT 'x'
               INTO   l_item_invalid
               FROM   csi_ctr_item_associations
               WHERE  inventory_item_id = l_item_associations_rec.inventory_item_id;

               CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_ITEM_ASSOC');
            EXCEPTION
               WHEN NO_DATA_FOUND THEN NULL;
               WHEN TOO_MANY_ROWS THEN
               CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_ITEM_ASSOC');
            END;
         END IF;
      END IF;
   END IF;

   /* IF l_item_associations_rec.associated_to_group = 'Y' THEN
      IF l_item_associations_rec.group_id IS NOT NULL THEN
         BEGIN
            SELECT 'x'
            INTO   l_item_invalid
            FROM   csi_ctr_item_associations
            WHERE  inventory_item_id = l_item_associations_rec.inventory_item_id
            AND    associated_to_group = l_item_associations_rec.associated_to_group
            -- AND    group_id = l_group_id
            AND    counter_id = l_item_associations_rec.counter_id;

            CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_ITEM_ASSOC');
         EXCEPTION
            WHEN NO_DATA_FOUND THEN NULL;
            WHEN TOO_MANY_ROWS THEN
               CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_ITEM_ASSOC');
         END;
      ELSE
         CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_REQ_PARM_GRP_NAME');
      END IF;
   ELSE
      IF l_item_associations_rec.group_id IS NULL THEN
         IF l_item_associations_rec.counter_id IS NULL THEN
            CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_CTR_ID');
         END IF;

         BEGIN
            SELECT 'Y'
            INTO   l_item_found
            FROM   csi_ctr_item_associations
            WHERE  inventory_item_id = l_item_associations_rec.inventory_item_id
            AND    associated_to_group = 'Y';

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               l_item_found := 'N';
            WHEN TOO_MANY_ROWS THEN
               l_item_found := 'Y';
         END;

         IF l_item_found = 'Y' THEN
            CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_ITEM_ASSOC');
         ELSE
            BEGIN
               SELECT 'x'
               INTO   l_item_invalid
               FROM   csi_ctr_item_associations
               WHERE  inventory_item_id = l_item_associations_rec.inventory_item_id
               AND    associated_to_group = l_item_associations_rec.associated_to_group
               AND    group_id IS NULL
               AND    counter_id = l_item_associations_rec.counter_id;

               CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_ITEM_ASSOC');
            EXCEPTION
               WHEN NO_DATA_FOUND THEN NULL;
               WHEN OTHERS THEN
                  CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_ITEM_ASSOC');
            END;
         END IF;
      ELSE
         CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_GRP_NULL');
      END IF;
   END IF;

   */
   -- Call the table handler

   CSI_CTR_ITEM_ASSOCIATIONS_PKG.Update_Row(
	p_CTR_ASSOCIATION_ID            => p_ctr_item_associations_rec.ctr_association_id
	,p_GROUP_ID                     => p_ctr_item_associations_rec.group_id
	,p_INVENTORY_ITEM_ID            => p_ctr_item_associations_rec.inventory_item_id
	,p_OBJECT_VERSION_NUMBER        => p_ctr_item_associations_rec.object_version_number + 1
	,p_LAST_UPDATE_DATE             => sysdate
	,p_LAST_UPDATED_BY              => FND_GLOBAL.USER_ID
	,p_LAST_UPDATE_LOGIN            => FND_GLOBAL.USER_ID
	,p_CREATION_DATE                => p_ctr_item_associations_rec.creation_date
        ,p_CREATED_BY                   => p_ctr_item_associations_rec.created_by
        ,p_ATTRIBUTE1                   => p_ctr_item_associations_rec.attribute1
        ,p_ATTRIBUTE2                   => p_ctr_item_associations_rec.attribute2
        ,p_ATTRIBUTE3                   => p_ctr_item_associations_rec.attribute3
        ,p_ATTRIBUTE4                   => p_ctr_item_associations_rec.attribute4
        ,p_ATTRIBUTE5                   => p_ctr_item_associations_rec.attribute5
        ,p_ATTRIBUTE6                   => p_ctr_item_associations_rec.attribute6
        ,p_ATTRIBUTE7                   => p_ctr_item_associations_rec.attribute7
        ,p_ATTRIBUTE8                   => p_ctr_item_associations_rec.attribute8
        ,p_ATTRIBUTE9                   => p_ctr_item_associations_rec.attribute9
        ,p_ATTRIBUTE10                  => p_ctr_item_associations_rec.attribute10
        ,p_ATTRIBUTE11                  => p_ctr_item_associations_rec.attribute11
        ,p_ATTRIBUTE12                  => p_ctr_item_associations_rec.attribute12
        ,p_ATTRIBUTE13                  => p_ctr_item_associations_rec.attribute13
        ,p_ATTRIBUTE14                  => p_ctr_item_associations_rec.attribute14
        ,p_ATTRIBUTE15                  => p_ctr_item_associations_rec.attribute15
	,p_ATTRIBUTE_CATEGORY           => p_ctr_item_associations_rec.attribute_category
	,p_SECURITY_GROUP_ID            => p_ctr_item_associations_rec.security_group_id
	,p_MIGRATED_FLAG                => p_ctr_item_associations_rec.migrated_flag
	,p_COUNTER_ID                   => p_ctr_item_associations_rec.counter_id
        ,p_START_DATE_ACTIVE            => p_ctr_item_associations_rec.start_date_active
        ,p_END_DATE_ACTIVE              => p_ctr_item_associations_rec.end_date_active
        ,p_USAGE_RATE                   => p_ctr_item_associations_rec.usage_rate
        -- ,p_ASSOCIATION_TYPE             => p_ctr_item_associations_rec.association_type
        ,p_USE_PAST_READING             => p_ctr_item_associations_rec.use_past_reading
	,p_ASSOCIATED_TO_GROUP          => p_ctr_item_associations_rec.associated_to_group
	,p_MAINT_ORGANIZATION_ID        => NULL
	,p_PRIMARY_FAILURE_FLAG         => p_ctr_item_associations_rec.primary_failure_flag
        );

   IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
        ROLLBACK TO update_item_association_pvt;
        RETURN;
   END IF;

    /* End of API Body */

   IF FND_API.to_Boolean(nvl(p_commit,FND_API.G_FALSE)) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and IF count is  get message info.
   FND_MSG_PUB.Count_And_Get
      ( p_count  =>  x_msg_count,
        p_data   =>  x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO update_item_association_pvt;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_item_association_pvt;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_item_association_pvt;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg
            ( G_PKG_NAME,
              l_api_name
            );
      END IF;
      FND_MSG_PUB.Count_And_Get
         ( p_count  => x_msg_count,
           p_data   => x_msg_data
         );
END update_item_association;

--|---------------------------------------------------
--| procedure name: update_counter_template
--| description :   procedure used to
--|                 update counter template
--|---------------------------------------------------

PROCEDURE update_counter_template
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_counter_template_rec      IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.counter_template_rec
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
 ) IS

   CURSOR cur_ctr_template_rec(p_counter_id IN NUMBER) IS
   SELECT counter_id,
          group_id,
          counter_type,
          initial_reading,
          initial_reading_date,
          step_value,
          tolerance_plus,
          tolerance_minus,
          uom_code,
          derive_counter_id,
          derive_function,
          valid_flag,
          formula_incomplete_flag,
          formula_text,
          rollover_last_reading,
          rollover_first_reading,
          usage_item_id,
          ctr_val_max_seq_no,
          start_date_active,
          end_date_active,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          attribute16,
          attribute17,
          attribute18,
          attribute19,
          attribute20,
          attribute21,
          attribute22,
          attribute23,
          attribute24,
          attribute25,
          attribute26,
          attribute27,
          attribute28,
          attribute29,
          attribute30,
          attribute_category,
          customer_view,
          direction,
          filter_type,
          filter_reading_count,
          filter_time_uom,
          estimation_id,
          reading_type,
          automatic_rollover,
          default_usage_rate,
          use_past_reading,
          used_in_scheduling,
          defaulted_group_id,
          object_version_number,
          comments,
          association_type,
          time_based_manual_entry,
          eam_required_flag
   FROM   csi_counter_template_vl
   WHERE  counter_id = p_counter_id
   FOR UPDATE OF OBJECT_VERSION_NUMBER;
   l_old_counter_template_rec  cur_ctr_template_rec%ROWTYPE;


   CURSOR formula_ref_cur(p_counter_id number) IS
   SELECT relationship_id
   FROM   csi_counter_relationships
   WHERE  object_counter_id = p_counter_id
   AND    relationship_type_code = 'FORMULA';

   CURSOR derived_filters_cur(p_counter_id NUMBER) IS
   SELECT counter_derived_filter_id
   FROM   csi_counter_derived_filters
   WHERE  counter_id = p_counter_id;

   CURSOR target_counter_cur(p_counter_id NUMBER) IS
   SELECT relationship_id
   FROM   csi_counter_relationships
   WHERE  source_counter_id = p_counter_id
   AND    relationship_type_code = 'CONFIGURATION';

   CURSOR counter_readings_cur(p_counter_id  NUMBER) IS
   SELECT counter_value_id
   FROM   csi_counter_readings
   WHERE  counter_id = p_counter_id;


   l_api_name                      CONSTANT VARCHAR2(30)   := 'UPDATE_COUNTER_TEMPLATE';
   l_api_version                   CONSTANT NUMBER         := 1.0;
   l_msg_data                      VARCHAR2(2000);
   l_msg_index                     NUMBER;
   l_msg_count                     NUMBER;
   -- l_debug_level                   NUMBER;

   l_counter_template_rec            CSI_CTR_DATASTRUCTURES_PUB.counter_template_rec;
   l_formula_ref_count             NUMBER;
   l_der_filter_count              NUMBER;
   l_target_ctr_exist              NUMBER;
   l_rdg_exists                    NUMBER;
   l_return_status		   VARCHAR2(1);

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  update_counter_template_pvt;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   --
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'update_counter_template_pvt'           ||'-'||
                                     p_api_version                              ||'-'||
                                     nvl(p_commit,FND_API.G_FALSE)              ||'-'||
                                     nvl(p_init_msg_list,FND_API.G_FALSE)       ||'-'||
                                     nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL) );
   END IF;

   /* Start of API body */
   OPEN cur_ctr_template_rec(p_counter_template_rec.counter_id);
   FETCH cur_ctr_template_rec INTO l_old_counter_template_rec;
   IF  (l_old_counter_template_rec.object_version_number <> nvl(p_counter_template_rec.OBJECT_VERSION_NUMBER,0)) THEN
      FND_MESSAGE.Set_Name('CSI', 'CSI_API_OBJ_VER_MISMATCH');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   CLOSE cur_ctr_template_rec;

   -- IF SQL%NOTFOUND THEN
   --   CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INVALID');
   -- END IF;

   -- Bug  8686933
   -- Assigning group id to defaulted group id column
   --
   IF (NVL(p_counter_template_rec.group_id, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM) THEN
   p_counter_template_rec.defaulted_group_id := p_counter_template_rec.group_id;
   END IF;

   l_counter_template_rec := p_counter_template_rec;

   IF p_counter_template_rec.group_id  = NULL THEN
      l_counter_template_rec.group_id := l_old_counter_template_rec.group_id;
   ELSIF p_counter_template_rec.group_id = FND_API.G_MISS_NUM THEN
      l_counter_template_rec.group_id := NULL;
   END IF;

   IF p_counter_template_rec.counter_type  IS NULL THEN
      l_counter_template_rec.counter_type := l_old_counter_template_rec.counter_type;
   ELSIF p_counter_template_rec.counter_type = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.counter_type := NULL;
   END IF;

   IF p_counter_template_rec.initial_reading  IS NULL THEN
      l_counter_template_rec.initial_reading := l_old_counter_template_rec.initial_reading;
   ELSIF p_counter_template_rec.initial_reading = FND_API.G_MISS_NUM THEN
      l_counter_template_rec.initial_reading := NULL;
   END IF;

   IF p_counter_template_rec.step_value IS NULL THEN
      l_counter_template_rec.step_value := l_old_counter_template_rec.step_value;
   ELSIF p_counter_template_rec.step_value = FND_API.G_MISS_NUM THEN
      l_counter_template_rec.step_value := NULL;
   END IF;

   IF p_counter_template_rec.initial_reading_date IS NULL THEN
      l_counter_template_rec.initial_reading_date := l_old_counter_template_rec.initial_reading_date;
   ELSIF p_counter_template_rec.initial_reading_date = FND_API.G_MISS_DATE THEN
      l_counter_template_rec.initial_reading_date := NULL;
   END IF;

   IF p_counter_template_rec.tolerance_plus IS NULL THEN
      l_counter_template_rec.tolerance_plus := l_old_counter_template_rec.tolerance_plus;
   ELSIF p_counter_template_rec.tolerance_plus = FND_API.G_MISS_NUM THEN
      l_counter_template_rec.tolerance_plus := NULL;
   END IF;

   IF p_counter_template_rec.tolerance_minus IS NULL THEN
      l_counter_template_rec.tolerance_minus := l_old_counter_template_rec.tolerance_minus;
   ELSIF p_counter_template_rec.tolerance_minus = FND_API.G_MISS_NUM THEN
      l_counter_template_rec.tolerance_minus := NULL;
   END IF;

   IF p_counter_template_rec.uom_code IS NULL THEN
      l_counter_template_rec.uom_code := l_old_counter_template_rec.uom_code;
   ELSIF p_counter_template_rec.uom_code = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.uom_code := NULL;
   END IF;

   IF p_counter_template_rec.derive_counter_id IS NULL THEN
      l_counter_template_rec.derive_counter_id := l_old_counter_template_rec.derive_counter_id;
   ELSIF p_counter_template_rec.derive_counter_id = FND_API.G_MISS_NUM THEN
      l_counter_template_rec.derive_counter_id := NULL;
   END IF;

   IF p_counter_template_rec.derive_function IS NULL THEN
      l_counter_template_rec.derive_function := l_old_counter_template_rec.derive_function;
   ELSIF p_counter_template_rec.derive_function = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.derive_function := NULL;
   END IF;

   IF p_counter_template_rec.valid_flag IS NULL THEN
      l_counter_template_rec.valid_flag := l_old_counter_template_rec.valid_flag;
   ELSIF p_counter_template_rec.valid_flag = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.valid_flag := NULL;
   END IF;

   IF p_counter_template_rec.formula_incomplete_flag IS NULL THEN
      l_counter_template_rec.formula_incomplete_flag := l_old_counter_template_rec.formula_incomplete_flag;
   ELSIF p_counter_template_rec.formula_incomplete_flag = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.formula_incomplete_flag := NULL;
   END IF;

   IF p_counter_template_rec.formula_text IS NULL THEN
      l_counter_template_rec.formula_text := l_old_counter_template_rec.formula_text;
   ELSIF p_counter_template_rec.formula_text = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.formula_text := NULL;
   END IF;

   IF p_counter_template_rec.rollover_last_reading IS NULL THEN
      l_counter_template_rec.rollover_last_reading := l_old_counter_template_rec.rollover_last_reading;
   ELSIF p_counter_template_rec.rollover_last_reading = FND_API.G_MISS_NUM THEN
      l_counter_template_rec.rollover_last_reading := NULL;
   END IF;

   IF p_counter_template_rec.rollover_first_reading IS NULL THEN
      l_counter_template_rec.rollover_first_reading := l_old_counter_template_rec.rollover_first_reading;
   ELSIF p_counter_template_rec.rollover_first_reading = FND_API.G_MISS_NUM THEN
      l_counter_template_rec.rollover_first_reading := NULL;
   END IF;

   IF p_counter_template_rec.usage_item_id IS NULL THEN
      l_counter_template_rec.usage_item_id := l_old_counter_template_rec.usage_item_id;
   ELSIF p_counter_template_rec.usage_item_id = FND_API.G_MISS_NUM THEN
      l_counter_template_rec.usage_item_id := NULL;
   END IF;

   IF p_counter_template_rec.ctr_val_max_seq_no IS NULL THEN
      l_counter_template_rec.ctr_val_max_seq_no := l_old_counter_template_rec.ctr_val_max_seq_no;
   ELSIF p_counter_template_rec.ctr_val_max_seq_no = FND_API.G_MISS_NUM THEN
      l_counter_template_rec.ctr_val_max_seq_no := NULL;
   END IF;

   IF p_counter_template_rec.start_date_active IS NULL THEN
      l_counter_template_rec.start_date_active := l_old_counter_template_rec.start_date_active;
   ELSIF p_counter_template_rec.start_date_active = FND_API.G_MISS_DATE THEN
      l_counter_template_rec.start_date_active := NULL;
   END IF;

   IF p_counter_template_rec.end_date_active IS NULL THEN
      l_counter_template_rec.end_date_active := l_old_counter_template_rec.end_date_active;
   ELSIF p_counter_template_rec.end_date_active = FND_API.G_MISS_DATE THEN
      l_counter_template_rec.end_date_active := NULL;
   END IF;

   if l_counter_template_rec.end_date_active IS NOT NULL then
      if l_counter_template_rec.end_date_active < l_counter_template_rec.start_date_active then
         CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_ALL_END_DATE');
      end if;
   end if;


   IF p_counter_template_rec.attribute1 IS NULL THEN
      l_counter_template_rec.attribute1 := l_old_counter_template_rec.attribute1;
   ELSIF p_counter_template_rec.attribute1 = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.attribute1 := NULL;
   END IF;

   IF p_counter_template_rec.attribute2 IS NULL THEN
      l_counter_template_rec.attribute2 := l_old_counter_template_rec.attribute2;
   ELSIF p_counter_template_rec.attribute2 = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.attribute2 := NULL;
   END IF;

   IF p_counter_template_rec.attribute3 IS NULL THEN
      l_counter_template_rec.attribute3 := l_old_counter_template_rec.attribute3;
   ELSIF p_counter_template_rec.attribute3 = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.attribute3 := NULL;
   END IF;

   IF p_counter_template_rec.attribute4 IS NULL THEN
      l_counter_template_rec.attribute4 := l_old_counter_template_rec.attribute4;
   ELSIF p_counter_template_rec.attribute4 = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.attribute4 := NULL;
   END IF;

   IF p_counter_template_rec.attribute5 IS NULL THEN
      l_counter_template_rec.attribute5 := l_old_counter_template_rec.attribute5;
   ELSIF p_counter_template_rec.attribute5 = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.attribute5 := NULL;
   END IF;

   IF p_counter_template_rec.attribute6 IS NULL THEN
      l_counter_template_rec.attribute6 := l_old_counter_template_rec.attribute6;
   ELSIF p_counter_template_rec.attribute6 = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.attribute6 := NULL;
   END IF;

   IF p_counter_template_rec.attribute7 IS NULL THEN
      l_counter_template_rec.attribute7 := l_old_counter_template_rec.attribute7;
   ELSIF p_counter_template_rec.attribute7 = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.attribute7 := NULL;
   END IF;

   IF p_counter_template_rec.attribute8 IS NULL THEN
      l_counter_template_rec.attribute8 := l_old_counter_template_rec.attribute8;
   ELSIF p_counter_template_rec.attribute8 = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.attribute8 := NULL;
   END IF;

   IF p_counter_template_rec.attribute9 IS NULL THEN
      l_counter_template_rec.attribute9 := l_old_counter_template_rec.attribute9;
   ELSIF p_counter_template_rec.attribute9 = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.attribute9 := NULL;
   END IF;

   IF p_counter_template_rec.attribute10 IS NULL THEN
      l_counter_template_rec.attribute10 := l_old_counter_template_rec.attribute10;
   ELSIF p_counter_template_rec.attribute10 = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.attribute10 := NULL;
   END IF;

   IF p_counter_template_rec.attribute11 IS NULL THEN
      l_counter_template_rec.attribute11 := l_old_counter_template_rec.attribute11;
   ELSIF p_counter_template_rec.attribute11 = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.attribute11 := NULL;
   END IF;

   IF p_counter_template_rec.attribute12 IS NULL THEN
      l_counter_template_rec.attribute12 := l_old_counter_template_rec.attribute12;
   ELSIF p_counter_template_rec.attribute12 = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.attribute12 := NULL;
   END IF;

   IF p_counter_template_rec.attribute13 IS NULL THEN
      l_counter_template_rec.attribute13 := l_old_counter_template_rec.attribute13;
   ELSIF p_counter_template_rec.attribute13 = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.attribute13 := NULL;
   END IF;

   IF p_counter_template_rec.attribute14 IS NULL THEN
      l_counter_template_rec.attribute14 := l_old_counter_template_rec.attribute14;
   ELSIF p_counter_template_rec.attribute14 = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.attribute14 := NULL;
   END IF;

   IF p_counter_template_rec.attribute15 IS NULL THEN
      l_counter_template_rec.attribute15 := l_old_counter_template_rec.attribute15;
   ELSIF p_counter_template_rec.attribute15 = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.attribute15 := NULL;
   END IF;

   IF p_counter_template_rec.attribute16 IS NULL THEN
      l_counter_template_rec.attribute16 := l_old_counter_template_rec.attribute16;
   ELSIF p_counter_template_rec.attribute16 = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.attribute16 := NULL;
   END IF;

   IF p_counter_template_rec.attribute17 IS NULL THEN
      l_counter_template_rec.attribute17 := l_old_counter_template_rec.attribute17;
   ELSIF p_counter_template_rec.attribute17 = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.attribute17 := NULL;
   END IF;

   IF p_counter_template_rec.attribute18 IS NULL THEN
      l_counter_template_rec.attribute18 := l_old_counter_template_rec.attribute18;
   ELSIF p_counter_template_rec.attribute18 = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.attribute18 := NULL;
   END IF;

   IF p_counter_template_rec.attribute19 IS NULL THEN
      l_counter_template_rec.attribute19 := l_old_counter_template_rec.attribute19;
   ELSIF p_counter_template_rec.attribute19 = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.attribute19 := NULL;
   END IF;

   IF p_counter_template_rec.attribute20 IS NULL THEN
      l_counter_template_rec.attribute20 := l_old_counter_template_rec.attribute20;
   ELSIF p_counter_template_rec.attribute20 = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.attribute20 := NULL;
   END IF;

   IF p_counter_template_rec.attribute21 IS NULL THEN
      l_counter_template_rec.attribute21 := l_old_counter_template_rec.attribute21;
   ELSIF p_counter_template_rec.attribute21 = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.attribute21 := NULL;
   END IF;

   IF p_counter_template_rec.attribute22 IS NULL THEN
      l_counter_template_rec.attribute22 := l_old_counter_template_rec.attribute22;
   ELSIF p_counter_template_rec.attribute22 = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.attribute22 := NULL;
   END IF;

   IF p_counter_template_rec.attribute23 IS NULL THEN
      l_counter_template_rec.attribute23 := l_old_counter_template_rec.attribute23;
   ELSIF p_counter_template_rec.attribute23 = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.attribute23 := NULL;
   END IF;

   IF p_counter_template_rec.attribute24 IS NULL THEN
      l_counter_template_rec.attribute24 := l_old_counter_template_rec.attribute24;
   ELSIF p_counter_template_rec.attribute24 = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.attribute24 := NULL;
   END IF;

   IF p_counter_template_rec.attribute25 IS NULL THEN
      l_counter_template_rec.attribute25 := l_old_counter_template_rec.attribute25;
   ELSIF p_counter_template_rec.attribute25 = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.attribute25 := NULL;
   END IF;

   IF p_counter_template_rec.attribute26 IS NULL THEN
      l_counter_template_rec.attribute26 := l_old_counter_template_rec.attribute26;
   ELSIF p_counter_template_rec.attribute26 = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.attribute26 := NULL;
   END IF;

   IF p_counter_template_rec.attribute27 IS NULL THEN
      l_counter_template_rec.attribute27 := l_old_counter_template_rec.attribute27;
   ELSIF p_counter_template_rec.attribute27 = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.attribute27 := NULL;
   END IF;

   IF p_counter_template_rec.attribute28 IS NULL THEN
      l_counter_template_rec.attribute28 := l_old_counter_template_rec.attribute28;
   ELSIF p_counter_template_rec.attribute28 = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.attribute28 := NULL;
   END IF;

   IF p_counter_template_rec.attribute29 IS NULL THEN
      l_counter_template_rec.attribute29 := l_old_counter_template_rec.attribute29;
   ELSIF p_counter_template_rec.attribute29 = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.attribute29 := NULL;
   END IF;

   IF p_counter_template_rec.attribute30 IS NULL THEN
      l_counter_template_rec.attribute30 := l_old_counter_template_rec.attribute30;
   ELSIF p_counter_template_rec.attribute30 = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.attribute30 := NULL;
   END IF;

   IF p_counter_template_rec.attribute_category IS NULL THEN
      l_counter_template_rec.attribute_category := l_old_counter_template_rec.attribute_category;
   ELSIF p_counter_template_rec.attribute_category = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.attribute_category := NULL;
   END IF;

   IF p_counter_template_rec.customer_view IS NULL THEN
      l_counter_template_rec.customer_view := l_old_counter_template_rec.customer_view;
   ELSIF p_counter_template_rec.customer_view = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.customer_view := NULL;
   END IF;

   IF p_counter_template_rec.direction IS NULL THEN
      l_counter_template_rec.direction := l_old_counter_template_rec.direction;
   ELSIF p_counter_template_rec.direction = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.direction := NULL;
   END IF;

   IF p_counter_template_rec.filter_type IS NULL THEN
      l_counter_template_rec.filter_type := l_old_counter_template_rec.filter_type;
   ELSIF p_counter_template_rec.filter_type = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.filter_type := NULL;
   END IF;

   IF p_counter_template_rec.filter_reading_count IS NULL THEN
      l_counter_template_rec.filter_reading_count := l_old_counter_template_rec.filter_reading_count;
   ELSIF p_counter_template_rec.filter_reading_count = FND_API.G_MISS_NUM THEN
      l_counter_template_rec.filter_reading_count := NULL;
   END IF;

   IF p_counter_template_rec.filter_time_uom IS NULL THEN
      l_counter_template_rec.filter_time_uom := l_old_counter_template_rec.filter_time_uom;
   ELSIF p_counter_template_rec.filter_time_uom = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.filter_time_uom := NULL;
   END IF;

   IF p_counter_template_rec.estimation_id IS NULL THEN
      l_counter_template_rec.estimation_id := l_old_counter_template_rec.estimation_id;
   ELSIF p_counter_template_rec.estimation_id = FND_API.G_MISS_NUM THEN
      l_counter_template_rec.estimation_id := NULL;
   END IF;

   IF p_counter_template_rec.association_type IS NULL THEN
      l_counter_template_rec.association_type := l_old_counter_template_rec.association_type;
   ELSIF p_counter_template_rec.association_type = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.association_type := NULL;
   END IF;

   IF p_counter_template_rec.reading_type IS NULL THEN
      l_counter_template_rec.reading_type := l_old_counter_template_rec.reading_type;
   ELSIF p_counter_template_rec.reading_type = FND_API.G_MISS_NUM THEN
      l_counter_template_rec.reading_type := NULL;
   END IF;

   IF p_counter_template_rec.automatic_rollover IS NULL THEN
      l_counter_template_rec.automatic_rollover := l_old_counter_template_rec.automatic_rollover;
   ELSIF p_counter_template_rec.automatic_rollover = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.automatic_rollover := NULL;
   END IF;

   IF p_counter_template_rec.default_usage_rate IS NULL THEN
      l_counter_template_rec.default_usage_rate := l_old_counter_template_rec.default_usage_rate;
   ELSIF p_counter_template_rec.default_usage_rate = FND_API.G_MISS_NUM THEN
      l_counter_template_rec.default_usage_rate := NULL;
   END IF;

   IF p_counter_template_rec.use_past_reading IS NULL THEN
      l_counter_template_rec.use_past_reading := l_old_counter_template_rec.use_past_reading;
   ELSIF p_counter_template_rec.use_past_reading = FND_API.G_MISS_NUM THEN
      l_counter_template_rec.use_past_reading := NULL;
   END IF;

   IF p_counter_template_rec.used_in_scheduling IS NULL THEN
      l_counter_template_rec.used_in_scheduling := l_old_counter_template_rec.used_in_scheduling;
   ELSIF p_counter_template_rec.used_in_scheduling = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.used_in_scheduling := NULL;
   END IF;

   IF p_counter_template_rec.time_based_manual_entry IS NULL THEN
      l_counter_template_rec.time_based_manual_entry := l_old_counter_template_rec.time_based_manual_entry;
   ELSIF p_counter_template_rec.time_based_manual_entry = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.time_based_manual_entry := NULL;
   END IF;

   IF l_old_counter_template_rec.used_in_scheduling = 'Y' AND l_counter_template_rec.used_in_scheduling = 'N' THEN
      Eam_Meters_Util.Validate_Used_In_Scheduling
      (
        p_meter_id         =>   p_counter_template_rec.counter_id,
        X_return_status    =>   l_return_status,
        X_msg_count        =>   l_msg_count,
        X_msg_data         =>   l_msg_data
     );

     IF NOT (l_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
        csi_ctr_gen_utility_pvt.put_line('used in scheduling cannot be updated');
        csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_USEDINSCHED_NOT_UPDT');
     END IF;
   END IF;

   csi_ctr_gen_utility_pvt.put_line('p_counter_template_rec.defaulted_group_id - ' || p_counter_template_rec.defaulted_group_id);
   IF p_counter_template_rec.defaulted_group_id IS NULL THEN
      l_counter_template_rec.defaulted_group_id := l_old_counter_template_rec.defaulted_group_id;
   ELSIF p_counter_template_rec.defaulted_group_id = FND_API.G_MISS_NUM THEN
      l_counter_template_rec.defaulted_group_id := NULL;
   END IF;

   IF p_counter_template_rec.comments IS NULL THEN
      l_counter_template_rec.comments := l_old_counter_template_rec.comments;
   ELSIF p_counter_template_rec.comments = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.comments := NULL;
   END IF;

   IF p_counter_template_rec.eam_required_flag IS NULL THEN
      l_counter_template_rec.eam_required_flag := l_old_counter_template_rec.eam_required_flag;
   ELSIF p_counter_template_rec.eam_required_flag = FND_API.G_MISS_CHAR THEN
      l_counter_template_rec.eam_required_flag := NULL;
   END IF;

   -- Counter group is not updateable
   IF l_counter_template_rec.counter_id <> l_old_counter_template_rec.counter_id    THEN
      CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_GRP_NOT_UPDATABLE');
   END IF;

   IF l_counter_template_rec.counter_type <> l_old_counter_template_rec.counter_type THEN
      IF l_old_counter_template_rec.counter_type = 'FORMULA' AND
         l_old_counter_template_rec.derive_function is null
      THEN
         OPEN  formula_ref_cur(p_counter_template_rec.counter_id);
         FETCH formula_ref_cur INTO l_formula_ref_count;
         CLOSE formula_ref_cur;
       IF l_formula_ref_count is not null then
         -- Formula references exist for this counter. You cannot
         -- change the type to something different.
         csi_ctr_gen_utility_pvt.put_line('Formula References exist for this counter. Cannot change counter type...');
         CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CS_API_CTR_FMLA_REF_EXIST','CTR_NAME',l_counter_template_rec.name);
       END IF;
     ELSIF l_old_counter_template_rec.counter_type = 'FORMULA'
             and l_old_counter_template_rec.derive_function in ('SUM','COUNT') THEN
       OPEN derived_filters_cur(p_counter_template_rec.counter_id);
       FETCH derived_filters_cur INTO l_der_filter_count;
       CLOSE derived_filters_cur;
       IF l_der_filter_count is not null then
         -- Derived filters exist for this counter. You cannot
         -- change the type to something different.
         csi_ctr_gen_utility_pvt.put_line('Derived Filters exist for this counter. Cannot change counter type...');
         CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_DER_FILTER_EXIST','CTR_NAME',l_counter_template_rec.name);
       END IF;
     ELSIF l_old_counter_template_rec.counter_type = 'REGULAR' THEN
       OPEN target_counter_cur(p_counter_template_rec.counter_id);
       FETCH target_counter_cur INTO l_target_ctr_exist;
       CLOSE target_counter_cur;
       IF l_target_ctr_exist is not null then
         -- Target counters exist for this counter. You cannot
         -- change the type to something different.
         csi_ctr_gen_utility_pvt.put_line('Target Counters exist for this counter. Cannot change counter type...');
         CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_CONFIG_CTR_EXIST','CTR_NAME',l_counter_template_rec.name);
       END IF;
     END IF;
   END IF;

   -- Validate reading type. Reading type cannot be changed if readings exist
   IF l_counter_template_rec.reading_type <> l_old_counter_template_rec.reading_type THEN
      OPEN counter_readings_cur(p_counter_template_rec.counter_id);
      FETCH counter_readings_cur INTO l_rdg_exists;
      CLOSE counter_readings_cur;
      IF l_rdg_exists is not null then
         -- Counter readings exist for this counter. You cannot
         -- change the reading type to something different.counter.
         csi_ctr_gen_utility_pvt.put_line('Counter readings exist for this counter. Cannot change reading type...');
         CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_RDGS_EXIST','CTR_NAME',l_counter_template_rec.name);
      END IF;
   END IF;

   -- Start add code for bug 6418952
   IF (l_counter_template_rec.name IS NULL AND l_old_counter_template_rec.counter_id IS NOT NULL) then
    BEGIN
      SELECT name
      INTO l_counter_template_rec.name
      FROM csi_counter_template_tl
      WHERE counter_id = l_old_counter_template_rec.counter_id;
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;
   END IF;
   -- End add code for bug 6418952

   -- Validate Counter
   validate_counter(l_counter_template_rec.group_id, l_counter_template_rec.name,
                    l_counter_template_rec.counter_type, l_counter_template_rec.uom_code,
                    l_counter_template_rec.usage_item_id, l_counter_template_rec.reading_type,
                    l_counter_template_rec.direction, l_counter_template_rec.estimation_id,
                    l_counter_template_rec.derive_function, l_counter_template_rec.formula_text,
                    l_counter_template_rec.derive_counter_id,l_counter_template_rec.filter_type,
                    l_counter_template_rec.filter_reading_count, l_counter_template_rec.filter_time_uom,
                    l_counter_template_rec.automatic_rollover, l_counter_template_rec.rollover_last_reading,
                    l_counter_template_rec.rollover_first_reading, l_counter_template_rec.tolerance_plus,
                    l_counter_template_rec.tolerance_minus, l_counter_template_rec.used_in_scheduling,
                    l_counter_template_rec.initial_reading, l_counter_template_rec.default_usage_rate,
                    l_counter_template_rec.use_past_reading, l_old_counter_template_rec.counter_id,
                    l_counter_template_rec.start_date_active, l_counter_template_rec.end_date_active, 'Y'
                   );

   -- call table handler here

   CSI_COUNTER_TEMPLATE_PKG.update_row
   (
     p_counter_id                  => p_counter_template_rec.counter_id
    ,p_group_id                    => p_counter_template_rec.group_id
    ,p_counter_type                => p_counter_template_rec.counter_type
    ,p_initial_reading             => p_counter_template_rec.initial_reading
    ,p_initial_reading_date        => p_counter_template_rec.initial_reading_date
    ,p_tolerance_plus              => p_counter_template_rec.tolerance_plus
    ,p_tolerance_minus             => p_counter_template_rec.tolerance_minus
    ,p_uom_code                    => p_counter_template_rec.uom_code
    ,p_derive_counter_id           => p_counter_template_rec.derive_counter_id
    ,p_derive_function             => p_counter_template_rec.derive_function
    ,p_derive_property_id          => p_counter_template_rec.derive_property_id
    ,p_valid_flag                  => p_counter_template_rec.valid_flag
    ,p_formula_incomplete_flag     => p_counter_template_rec.formula_incomplete_flag
    ,p_formula_text                => p_counter_template_rec.formula_text
    ,p_rollover_last_reading       => p_counter_template_rec.rollover_last_reading
    ,p_rollover_first_reading      => p_counter_template_rec.rollover_first_reading
    ,p_usage_item_id               => p_counter_template_rec.usage_item_id
    ,p_ctr_val_max_seq_no          => nvl(p_counter_template_rec.ctr_val_max_seq_no,1)
    ,p_start_date_active           => p_counter_template_rec.start_date_active
    ,p_end_date_active             => p_counter_template_rec.end_date_active
    ,p_object_version_number       => p_counter_template_rec.object_version_number
    ,p_last_update_date            => sysdate
    ,p_last_updated_by             => FND_GLOBAL.USER_ID
    ,p_creation_date               => p_counter_template_rec.creation_date
    ,p_created_by                  => p_counter_template_rec.created_by
    ,p_last_update_login           => FND_GLOBAL.USER_ID
    ,p_attribute1                  => p_counter_template_rec.attribute1
    ,p_attribute2                  => p_counter_template_rec.attribute2
    ,p_attribute3                  => p_counter_template_rec.attribute3
    ,p_attribute4                  => p_counter_template_rec.attribute4
    ,p_attribute5                  => p_counter_template_rec.attribute5
    ,p_attribute6                  => p_counter_template_rec.attribute6
    ,p_attribute7                  => p_counter_template_rec.attribute7
    ,p_attribute8                  => p_counter_template_rec.attribute8
    ,p_attribute9                  => p_counter_template_rec.attribute9
    ,p_attribute10                 => p_counter_template_rec.attribute10
    ,p_attribute11                 => p_counter_template_rec.attribute11
    ,p_attribute12                 => p_counter_template_rec.attribute12
    ,p_attribute13                 => p_counter_template_rec.attribute13
    ,p_attribute14                 => p_counter_template_rec.attribute14
    ,p_attribute15                 => p_counter_template_rec.attribute15
    ,p_attribute16                 => p_counter_template_rec.attribute16
    ,p_attribute17                 => p_counter_template_rec.attribute17
    ,p_attribute18                 => p_counter_template_rec.attribute18
    ,p_attribute19                 => p_counter_template_rec.attribute19
    ,p_attribute20                 => p_counter_template_rec.attribute20
    ,p_attribute21                 => p_counter_template_rec.attribute21
    ,p_attribute22                 => p_counter_template_rec.attribute22
    ,p_attribute23                 => p_counter_template_rec.attribute23
    ,p_attribute24                 => p_counter_template_rec.attribute24
    ,p_attribute25                 => p_counter_template_rec.attribute25
    ,p_attribute26                 => p_counter_template_rec.attribute26
    ,p_attribute27                 => p_counter_template_rec.attribute27
    ,p_attribute28                 => p_counter_template_rec.attribute28
    ,p_attribute29                 => p_counter_template_rec.attribute29
    ,p_attribute30                 => p_counter_template_rec.attribute30
    ,p_attribute_category          => p_counter_template_rec.attribute_category
    ,p_migrated_flag               => null
    ,p_customer_view               => p_counter_template_rec.customer_view
    ,p_direction                   => p_counter_template_rec.direction
    ,p_filter_type                 => p_counter_template_rec.filter_type
    ,p_filter_reading_count        => p_counter_template_rec.filter_reading_count
    ,p_filter_time_uom             => p_counter_template_rec.filter_time_uom
    ,p_estimation_id               => p_counter_template_rec.estimation_id
    ,p_association_type            => p_counter_template_rec.association_type
    ,p_reading_type                => p_counter_template_rec.reading_type
    ,p_automatic_rollover          => p_counter_template_rec.automatic_rollover
    ,p_default_usage_rate          => p_counter_template_rec.default_usage_rate
    ,p_use_past_reading            => p_counter_template_rec.use_past_reading
    ,p_used_in_scheduling          => p_counter_template_rec.used_in_scheduling
    ,p_defaulted_group_id          => p_counter_template_rec.defaulted_group_id
    ,p_SECURITY_GROUP_ID           => p_counter_template_rec.step_value
    ,p_STEP_VALUE                  => p_counter_template_rec.step_value
    ,p_name                        => p_counter_template_rec.name
    ,p_description                 => p_counter_template_rec.description
    ,p_time_based_manual_entry     => p_counter_template_rec.time_based_manual_entry
    ,p_eam_required_flag       => p_counter_template_rec.eam_required_flag
   );


   IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
        ROLLBACK TO update_counter_template_pvt;
        RETURN;
   END IF;

   /* End of API Body */

   IF FND_API.to_Boolean(nvl(p_commit,FND_API.G_FALSE)) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and IF count is  get message info.
   FND_MSG_PUB.Count_And_Get
      ( p_count  =>  x_msg_count,
        p_data   =>  x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO update_counter_template_pvt;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_counter_template_pvt;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_counter_template_pvt;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg
            ( G_PKG_NAME,
              l_api_name
            );
      END IF;
      FND_MSG_PUB.Count_And_Get
         ( p_count  => x_msg_count,
           p_data   => x_msg_data
         );
END update_counter_template;

--|---------------------------------------------------
--| procedure name: update_ctr_property_template
--| description :   procedure used to
--|                 create counter properties
--|---------------------------------------------------

PROCEDURE update_ctr_property_template
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_ctr_property_template_rec IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_property_template_rec
    ,x_return_status                OUT    NOCOPY VARCHAR2
    ,x_msg_count                    OUT    NOCOPY NUMBER
    ,x_msg_data                     OUT    NOCOPY VARCHAR2
 ) IS

   CURSOR cur_ctr_prop_rec(p_counter_property_id IN NUMBER) IS
   SELECT name
          ,description
          ,counter_id
          ,property_data_type
          ,is_nullable
          ,default_value
          ,minimum_value
          ,maximum_value
          ,uom_code
          ,start_date_active
          ,end_date_active
          ,object_version_number
          ,last_update_date
          ,last_updated_by
          ,creation_date
          ,created_by
          ,last_update_login
          ,attribute1
          ,attribute2
          ,attribute3
          ,attribute4
          ,attribute5
          ,attribute6
          ,attribute7
          ,attribute8
          ,attribute9
          ,attribute10
          ,attribute11
          ,attribute12
          ,attribute13
          ,attribute14
          ,attribute15
          ,attribute_category
          ,migrated_flag
          ,property_lov_type
          ,security_group_id
   FROM  csi_ctr_prop_template_vl
   WHERE counter_property_id = p_counter_property_id
   FOR UPDATE OF OBJECT_VERSION_NUMBER;
   l_old_ctr_property_tmpl_rec  cur_ctr_prop_rec%ROWTYPE;


   l_api_name                      CONSTANT VARCHAR2(30)   := 'UPDATE_CTR_PROPERTY_TEMPLATE';
   l_api_version                   CONSTANT NUMBER         := 1.0;
   l_msg_data                      VARCHAR2(2000);
   l_msg_index                     NUMBER;
   l_msg_count                     NUMBER;
   -- l_debug_level                   NUMBER;

   l_ctr_property_tmpl_rec         CSI_CTR_DATASTRUCTURES_PUB.ctr_property_template_rec;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  update_ctr_property_tmpl_pvt;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   --
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'update_ctr_property_tmpl_pvt'         ||'-'||
                                     p_api_version                              ||'-'||
                                     nvl(p_commit,FND_API.G_FALSE)              ||'-'||
                                     nvl(p_init_msg_list,FND_API.G_FALSE)       ||'-'||
                                     nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL) );
   END IF;

   /* Start of API Body */
   OPEN cur_ctr_prop_rec(p_ctr_property_template_rec.counter_property_id);
   FETCH cur_ctr_prop_rec INTO l_old_ctr_property_tmpl_rec;
   IF  (l_old_ctr_property_tmpl_rec.object_version_number <> nvl(p_ctr_property_template_rec.OBJECT_VERSION_NUMBER,0)) THEN
      FND_MESSAGE.Set_Name('CSI', 'CSI_API_OBJ_VER_MISMATCH');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   CLOSE cur_ctr_prop_rec;

   -- IF SQL%NOTFOUND THEN
   --     CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_GRP_NOTEXISTS');
   -- END IF;

   l_ctr_property_tmpl_rec := p_ctr_property_template_rec;

   IF p_ctr_property_template_rec.name  IS NULL THEN
      l_ctr_property_tmpl_rec.name := l_old_ctr_property_tmpl_rec.name;
   ELSIF p_ctr_property_template_rec.name = FND_API.G_MISS_CHAR THEN
      l_ctr_property_tmpl_rec.name := NULL;
   END IF;

   IF p_ctr_property_template_rec.description  IS NULL THEN
      l_ctr_property_tmpl_rec.description := l_old_ctr_property_tmpl_rec.description;
   ELSIF p_ctr_property_template_rec.description = FND_API.G_MISS_CHAR THEN
      l_ctr_property_tmpl_rec.description := NULL;
   END IF;

   IF p_ctr_property_template_rec.counter_id  IS NULL THEN
      l_ctr_property_tmpl_rec.counter_id := l_old_ctr_property_tmpl_rec.counter_id;
   ELSIF p_ctr_property_template_rec.counter_id = FND_API.G_MISS_NUM THEN
      l_ctr_property_tmpl_rec.counter_id := NULL;
   END IF;

   IF p_ctr_property_template_rec.start_date_active IS NULL THEN
      l_ctr_property_tmpl_rec.start_date_active := l_old_ctr_property_tmpl_rec.start_date_active;
   ELSIF p_ctr_property_template_rec.start_date_active = FND_API.G_MISS_DATE THEN
      l_ctr_property_tmpl_rec.start_date_active := NULL;
   END IF;

   IF p_ctr_property_template_rec.end_date_active IS NULL THEN
      l_ctr_property_tmpl_rec.end_date_active := l_old_ctr_property_tmpl_rec.end_date_active;
   ELSIF p_ctr_property_template_rec.end_date_active = FND_API.G_MISS_DATE THEN
      l_ctr_property_tmpl_rec.end_date_active := NULL;
   END IF;

   IF p_ctr_property_template_rec.attribute1 IS NULL THEN
      l_ctr_property_tmpl_rec.attribute1 := l_old_ctr_property_tmpl_rec.attribute1;
   ELSIF p_ctr_property_template_rec.attribute1 = FND_API.G_MISS_CHAR THEN
      l_ctr_property_tmpl_rec.attribute1 := NULL;
   END IF;

   IF p_ctr_property_template_rec.attribute2 IS NULL THEN
      l_ctr_property_tmpl_rec.attribute2 := l_old_ctr_property_tmpl_rec.attribute2;
   ELSIF p_ctr_property_template_rec.attribute2 = FND_API.G_MISS_CHAR THEN
      l_ctr_property_tmpl_rec.attribute2 := NULL;
   END IF;

   IF p_ctr_property_template_rec.attribute3 IS NULL THEN
      l_ctr_property_tmpl_rec.attribute3 := l_old_ctr_property_tmpl_rec.attribute3;
   ELSIF p_ctr_property_template_rec.attribute3 = FND_API.G_MISS_CHAR THEN
      l_ctr_property_tmpl_rec.attribute3 := NULL;
   END IF;

   IF p_ctr_property_template_rec.attribute4 IS NULL THEN
      l_ctr_property_tmpl_rec.attribute4 := l_old_ctr_property_tmpl_rec.attribute4;
   ELSIF p_ctr_property_template_rec.attribute4 = FND_API.G_MISS_CHAR THEN
      l_ctr_property_tmpl_rec.attribute4 := NULL;
   END IF;

   IF p_ctr_property_template_rec.attribute5 IS NULL THEN
      l_ctr_property_tmpl_rec.attribute5 := l_old_ctr_property_tmpl_rec.attribute5;
   ELSIF p_ctr_property_template_rec.attribute5 = FND_API.G_MISS_CHAR THEN
      l_ctr_property_tmpl_rec.attribute5 := NULL;
   END IF;

   IF p_ctr_property_template_rec.attribute6 IS NULL THEN
      l_ctr_property_tmpl_rec.attribute6 := l_old_ctr_property_tmpl_rec.attribute6;
   ELSIF p_ctr_property_template_rec.attribute6 = FND_API.G_MISS_CHAR THEN
      l_ctr_property_tmpl_rec.attribute6 := NULL;
   END IF;

   IF p_ctr_property_template_rec.attribute7 IS NULL THEN
      l_ctr_property_tmpl_rec.attribute7 := l_old_ctr_property_tmpl_rec.attribute7;
   ELSIF p_ctr_property_template_rec.attribute7 = FND_API.G_MISS_CHAR THEN
      l_ctr_property_tmpl_rec.attribute7 := NULL;
   END IF;

   IF p_ctr_property_template_rec.attribute8 IS NULL THEN
      l_ctr_property_tmpl_rec.attribute8 := l_old_ctr_property_tmpl_rec.attribute8;
   ELSIF p_ctr_property_template_rec.attribute8 = FND_API.G_MISS_CHAR THEN
      l_ctr_property_tmpl_rec.attribute8 := NULL;
   END IF;

   IF p_ctr_property_template_rec.attribute9 IS NULL THEN
      l_ctr_property_tmpl_rec.attribute9 := l_old_ctr_property_tmpl_rec.attribute9;
   ELSIF p_ctr_property_template_rec.attribute9 = FND_API.G_MISS_CHAR THEN
      l_ctr_property_tmpl_rec.attribute9 := NULL;
   END IF;

   IF p_ctr_property_template_rec.attribute10 IS NULL THEN
      l_ctr_property_tmpl_rec.attribute10 := l_old_ctr_property_tmpl_rec.attribute10;
   ELSIF p_ctr_property_template_rec.attribute10 = FND_API.G_MISS_CHAR THEN
      l_ctr_property_tmpl_rec.attribute10 := NULL;
   END IF;

   IF p_ctr_property_template_rec.attribute11 IS NULL THEN
      l_ctr_property_tmpl_rec.attribute11 := l_old_ctr_property_tmpl_rec.attribute11;
   ELSIF p_ctr_property_template_rec.attribute11 = FND_API.G_MISS_CHAR THEN
      l_ctr_property_tmpl_rec.attribute11 := NULL;
   END IF;

   IF p_ctr_property_template_rec.attribute12 IS NULL THEN
      l_ctr_property_tmpl_rec.attribute12 := l_old_ctr_property_tmpl_rec.attribute12;
   ELSIF p_ctr_property_template_rec.attribute12 = FND_API.G_MISS_CHAR THEN
      l_ctr_property_tmpl_rec.attribute12 := NULL;
   END IF;

   IF p_ctr_property_template_rec.attribute13 IS NULL THEN
      l_ctr_property_tmpl_rec.attribute13 := l_old_ctr_property_tmpl_rec.attribute13;
   ELSIF p_ctr_property_template_rec.attribute13 = FND_API.G_MISS_CHAR THEN
      l_ctr_property_tmpl_rec.attribute13 := NULL;
   END IF;

   IF p_ctr_property_template_rec.attribute14 IS NULL THEN
      l_ctr_property_tmpl_rec.attribute14 := l_old_ctr_property_tmpl_rec.attribute14;
   ELSIF p_ctr_property_template_rec.attribute14 = FND_API.G_MISS_CHAR THEN
      l_ctr_property_tmpl_rec.attribute14 := NULL;
   END IF;

   IF p_ctr_property_template_rec.attribute15 IS NULL THEN
      l_ctr_property_tmpl_rec.attribute15 := l_old_ctr_property_tmpl_rec.attribute15;
   ELSIF p_ctr_property_template_rec.attribute15 = FND_API.G_MISS_CHAR THEN
      l_ctr_property_tmpl_rec.attribute15 := NULL;
   END IF;

   IF p_ctr_property_template_rec.attribute_category IS NULL THEN
      l_ctr_property_tmpl_rec.attribute_category := l_old_ctr_property_tmpl_rec.attribute_category;
   ELSIF p_ctr_property_template_rec.attribute_category = FND_API.G_MISS_CHAR THEN
      l_ctr_property_tmpl_rec.attribute_category := NULL;
   END IF;

   IF p_ctr_property_template_rec.property_data_type IS NULL THEN
      l_ctr_property_tmpl_rec.property_data_type := l_old_ctr_property_tmpl_rec.property_data_type;
   ELSIF p_ctr_property_template_rec.property_data_type = FND_API.G_MISS_CHAR THEN
      l_ctr_property_tmpl_rec.property_data_type := NULL;
   END IF;

   IF p_ctr_property_template_rec.is_nullable IS NULL THEN
      l_ctr_property_tmpl_rec.is_nullable := l_old_ctr_property_tmpl_rec.is_nullable;
   ELSIF p_ctr_property_template_rec.is_nullable = FND_API.G_MISS_CHAR THEN
      l_ctr_property_tmpl_rec.is_nullable := NULL;
   END IF;

   IF p_ctr_property_template_rec.default_value IS NULL THEN
      l_ctr_property_tmpl_rec.default_value := l_old_ctr_property_tmpl_rec.default_value;
   ELSIF p_ctr_property_template_rec.default_value = FND_API.G_MISS_CHAR THEN
      l_ctr_property_tmpl_rec.default_value := NULL;
   END IF;

   IF p_ctr_property_template_rec.minimum_value IS NULL THEN
      l_ctr_property_tmpl_rec.minimum_value := l_old_ctr_property_tmpl_rec.minimum_value;
   ELSIF p_ctr_property_template_rec.minimum_value = FND_API.G_MISS_CHAR THEN
      l_ctr_property_tmpl_rec.minimum_value := NULL;
   END IF;

   IF p_ctr_property_template_rec.maximum_value IS NULL THEN
      l_ctr_property_tmpl_rec.maximum_value := l_old_ctr_property_tmpl_rec.maximum_value;
   ELSIF p_ctr_property_template_rec.maximum_value = FND_API.G_MISS_CHAR THEN
      l_ctr_property_tmpl_rec.maximum_value:= NULL;
   END IF;

   IF p_ctr_property_template_rec.uom_code IS NULL THEN
      l_ctr_property_tmpl_rec.uom_code := l_old_ctr_property_tmpl_rec.uom_code;
   ELSIF p_ctr_property_template_rec.uom_code = FND_API.G_MISS_CHAR THEN
      l_ctr_property_tmpl_rec.uom_code:= NULL;
   END IF;

   IF p_ctr_property_template_rec.property_lov_type IS NULL THEN
      l_ctr_property_tmpl_rec.property_lov_type := l_old_ctr_property_tmpl_rec.property_lov_type;
   ELSIF p_ctr_property_template_rec.property_lov_type = FND_API.G_MISS_CHAR THEN
      l_ctr_property_tmpl_rec.property_lov_type:= NULL;
   END IF;

   IF p_ctr_property_template_rec.migrated_flag IS NULL THEN
      l_ctr_property_tmpl_rec.migrated_flag := l_old_ctr_property_tmpl_rec.migrated_flag;
   ELSIF p_ctr_property_template_rec.migrated_flag = FND_API.G_MISS_CHAR THEN
      l_ctr_property_tmpl_rec.migrated_flag:= NULL;
   END IF;

   IF p_ctr_property_template_rec.security_group_id IS NULL THEN
      l_ctr_property_tmpl_rec.security_group_id := l_old_ctr_property_tmpl_rec.security_group_id;
   ELSIF p_ctr_property_template_rec.security_group_id = FND_API.G_MISS_NUM THEN
      l_ctr_property_tmpl_rec.security_group_id := NULL;
   END IF;

   -- Counter property name is not updateable

   IF l_ctr_property_tmpl_rec.name <> l_old_ctr_property_tmpl_rec.name THEN
       CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_PROP_NOT_UPDATABLE');
   END IF;

   -- Call the table handler
   validate_start_date(l_ctr_property_tmpl_rec.start_date_active);
   Validate_Data_Type(l_ctr_property_tmpl_rec.property_data_type, l_ctr_property_tmpl_rec.default_value, l_ctr_property_tmpl_rec.minimum_value, l_ctr_property_tmpl_rec.maximum_value);

   IF l_ctr_property_tmpl_rec.property_lov_type IS NOT NULL THEN
      validate_lookups('CSI_CTR_PROPERTY_LOV_TYPE',l_ctr_property_tmpl_rec.property_lov_type);
   END IF;

 csi_ctr_gen_utility_pvt.put_line(' Default Value = '||l_ctr_property_tmpl_rec.default_value);
   IF l_ctr_property_tmpl_rec.property_lov_type IS NOT NULL and l_ctr_property_tmpl_rec.default_value IS NOT NULL THEN
      validate_lookups(l_ctr_property_tmpl_rec.property_lov_type,l_ctr_property_tmpl_rec.default_value);
   END IF;

   IF l_ctr_property_tmpl_rec.uom_code IS NOT NULL THEN
      validate_uom(l_ctr_property_tmpl_rec.uom_code);
   END IF;

   /* Call the table Handler */
   CSI_CTR_PROPERTY_TEMPLATE_PKG.update_Row(
 	 p_COUNTER_PROPERTY_ID          => p_ctr_property_template_rec.counter_property_id
	,p_COUNTER_ID                   => p_ctr_property_template_rec.counter_id
	,p_PROPERTY_DATA_TYPE           => p_ctr_property_template_rec.property_data_type
	,p_IS_NULLABLE                  => p_ctr_property_template_rec.is_nullable
	,p_DEFAULT_VALUE                => p_ctr_property_template_rec.default_value
	,p_MINIMUM_VALUE                => p_ctr_property_template_rec.minimum_value
	,p_MAXIMUM_VALUE                => p_ctr_property_template_rec.maximum_value
	,p_UOM_CODE                     => p_ctr_property_template_rec.uom_code
	,p_START_DATE_ACTIVE            => p_ctr_property_template_rec.start_date_active
	,p_END_DATE_ACTIVE              => p_ctr_property_template_rec.end_date_active
	,p_OBJECT_VERSION_NUMBER        => p_ctr_property_template_rec.object_version_number + 1
        ,p_LAST_UPDATE_DATE             => sysdate
        ,p_LAST_UPDATED_BY              => FND_GLOBAL.USER_ID
        ,p_CREATION_DATE                => p_ctr_property_template_rec.creation_date
        ,p_CREATED_BY                   => p_ctr_property_template_rec.created_by
        ,p_LAST_UPDATE_LOGIN            => FND_GLOBAL.USER_ID
        ,p_ATTRIBUTE1                   => p_ctr_property_template_rec.attribute1
        ,p_ATTRIBUTE2                   => p_ctr_property_template_rec.attribute2
        ,p_ATTRIBUTE3                   => p_ctr_property_template_rec.attribute3
        ,p_ATTRIBUTE4                   => p_ctr_property_template_rec.attribute4
        ,p_ATTRIBUTE5                   => p_ctr_property_template_rec.attribute5
        ,p_ATTRIBUTE6                   => p_ctr_property_template_rec.attribute6
        ,p_ATTRIBUTE7                   => p_ctr_property_template_rec.attribute7
        ,p_ATTRIBUTE8                   => p_ctr_property_template_rec.attribute8
        ,p_ATTRIBUTE9                   => p_ctr_property_template_rec.attribute9
        ,p_ATTRIBUTE10                  => p_ctr_property_template_rec.attribute10
        ,p_ATTRIBUTE11                  => p_ctr_property_template_rec.attribute11
        ,p_ATTRIBUTE12                  => p_ctr_property_template_rec.attribute12
        ,p_ATTRIBUTE13                  => p_ctr_property_template_rec.attribute13
        ,p_ATTRIBUTE14                  => p_ctr_property_template_rec.attribute14
        ,p_ATTRIBUTE15                  => p_ctr_property_template_rec.attribute15
        ,p_ATTRIBUTE_CATEGORY           => p_ctr_property_template_rec.attribute_category
	,p_MIGRATED_FLAG                => p_ctr_property_template_rec.migrated_flag
	,p_PROPERTY_LOV_TYPE            => p_ctr_property_template_rec.property_lov_type
        ,p_SECURITY_GROUP_ID            => p_ctr_property_template_rec.security_group_id
        ,p_NAME	                        => p_ctr_property_template_rec.name
        ,p_DESCRIPTION                  => p_ctr_property_template_rec.description
        );

   IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
        ROLLBACK TO update_ctr_property_tmpl_pvt;
        RETURN;
   END IF;


   /* End of API Body */

   IF FND_API.to_Boolean(nvl(p_commit,FND_API.G_FALSE)) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and IF count is  get message info.
   FND_MSG_PUB.Count_And_Get
      ( p_count  =>  x_msg_count,
        p_data   =>  x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO update_ctr_property_tmpl_pvt;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_ctr_property_tmpl_pvt;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_ctr_property_tmpl_pvt;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg
            ( G_PKG_NAME,
              l_api_name
            );
      END IF;
      FND_MSG_PUB.Count_And_Get
         ( p_count  => x_msg_count,
           p_data   => x_msg_data
         );
END update_ctr_property_template;

--|---------------------------------------------------
--| procedure name: update_counter_relationship
--| description :   procedure used to
--|                 update counter relationship
--|---------------------------------------------------

PROCEDURE update_counter_relationship
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_counter_relationships_rec IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.counter_relationships_rec
    ,x_return_status                OUT    NOCOPY VARCHAR2
    ,x_msg_count                    OUT    NOCOPY NUMBER
    ,x_msg_data                     OUT    NOCOPY VARCHAR2
 ) IS

  CURSOR cur_rel_rec(p_relationship_id IN  NUMBER) IS
  SELECT ctr_association_id
          ,relationship_type_code
          ,source_counter_id
          ,object_counter_id
          ,active_start_date
          ,active_end_date
          ,object_version_number
          ,last_update_date
          ,last_updated_by
          ,creation_date
          ,created_by
          ,last_update_login
          ,attribute_category
          ,attribute1
          ,attribute2
          ,attribute3
          ,attribute4
          ,attribute5
          ,attribute6
          ,attribute7
          ,attribute8
          ,attribute9
          ,attribute10
          ,attribute11
          ,attribute12
          ,attribute13
          ,attribute14
          ,attribute15
          ,security_group_id
          ,migrated_flag
          ,bind_variable_name
          ,factor
   FROM  csi_ctr_relationships_v
   WHERE relationship_id = p_relationship_id
   FOR UPDATE OF OBJECT_VERSION_NUMBER;
   l_old_ctr_relationships_rec  cur_rel_rec%ROWTYPE;


   l_api_name                      CONSTANT VARCHAR2(30)   := 'UPDATE_COUNTER_RELATIONSHIP';
   l_api_version                   CONSTANT NUMBER         := 1.0;
   l_msg_data                      VARCHAR2(2000);
   l_msg_index                     NUMBER;
   l_msg_count                     NUMBER;
   -- l_debug_level                   NUMBER;

   l_ctr_relationships_rec         CSI_CTR_DATASTRUCTURES_PUB.counter_relationships_rec;
   l_source_direction              VARCHAR2(1);
   l_object_direction              VARCHAR2(1);
   l_valid_flag                    VARCHAR2(1);
   l_src_ctr_start_date            DATE;
   l_src_ctr_end_date              DATE;
   l_obj_ctr_start_date            DATE;
   l_obj_ctr_end_date              DATE;
   l_reading_date                  DATE;

   CURSOR c1(p_counter_id IN NUMBER) IS
   SELECT max(value_timestamp)
   FROM   csi_counter_readings
   WHERE  counter_id = p_counter_id;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  update_ctr_relationship_pvt;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   --
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'update_ctr_relationship_pvt'           ||'-'||
                                     p_api_version                              ||'-'||
                                     nvl(p_commit,FND_API.G_FALSE)              ||'-'||
                                     nvl(p_init_msg_list,FND_API.G_FALSE)       ||'-'||
                                     nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL) );
   END IF;

   /* Start of API Body */
   OPEN cur_rel_rec(p_counter_relationships_rec.relationship_id);
   FETCH cur_rel_rec INTO l_old_ctr_relationships_rec;

   IF p_counter_relationships_rec.object_version_number  IS NULL THEN
      l_ctr_relationships_rec.object_version_number := l_old_ctr_relationships_rec.object_version_number;
   ELSIF p_counter_relationships_rec.object_version_number = FND_API.G_MISS_NUM THEN
      l_ctr_relationships_rec.object_version_number := NULL;
   END IF;

   IF  (l_old_ctr_relationships_rec.object_version_number <> nvl(p_counter_relationships_rec.OBJECT_VERSION_NUMBER,0)) THEN
      FND_MESSAGE.Set_Name('CSI', 'CSI_API_OBJ_VER_MISMATCH');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   CLOSE cur_rel_rec;

   -- IF SQL%NOTFOUND THEN
   --    CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_GRP_NOTEXISTS');
   -- END IF;

   l_ctr_relationships_rec := p_counter_relationships_rec;

   IF p_counter_relationships_rec.ctr_association_id  IS NULL THEN
      l_ctr_relationships_rec.ctr_association_id := l_old_ctr_relationships_rec.ctr_association_id;
   ELSIF p_counter_relationships_rec.ctr_association_id = FND_API.G_MISS_NUM THEN
      l_ctr_relationships_rec.ctr_association_id := NULL;
   END IF;

   IF p_counter_relationships_rec.relationship_type_code IS NULL THEN
      l_ctr_relationships_rec.relationship_type_code := l_old_ctr_relationships_rec.relationship_type_code;
   ELSIF p_counter_relationships_rec.relationship_type_code = FND_API.G_MISS_CHAR THEN
      l_ctr_relationships_rec.relationship_type_code := NULL;
   END IF;

   IF p_counter_relationships_rec.source_counter_id  IS NULL THEN
      l_ctr_relationships_rec.source_counter_id := l_old_ctr_relationships_rec.source_counter_id;
   ELSIF p_counter_relationships_rec.source_counter_id = FND_API.G_MISS_NUM THEN
      l_ctr_relationships_rec.source_counter_id := NULL;
   END IF;

   IF p_counter_relationships_rec.object_counter_id  IS NULL THEN
      l_ctr_relationships_rec.object_counter_id := l_old_ctr_relationships_rec.object_counter_id;
   ELSIF p_counter_relationships_rec.object_counter_id = FND_API.G_MISS_NUM THEN
      l_ctr_relationships_rec.object_counter_id := NULL;
   END IF;

   IF p_counter_relationships_rec.active_start_date IS NULL THEN
      l_ctr_relationships_rec.active_start_date := l_old_ctr_relationships_rec.active_start_date;
   ELSIF p_counter_relationships_rec.active_start_date = FND_API.G_MISS_DATE THEN
      l_ctr_relationships_rec.active_start_date := NULL;
   END IF;

   IF p_counter_relationships_rec.active_end_date IS NULL THEN
      l_ctr_relationships_rec.active_end_date := l_old_ctr_relationships_rec.active_end_date;
   ELSIF p_counter_relationships_rec.active_end_date = FND_API.G_MISS_DATE THEN
      l_ctr_relationships_rec.active_end_date := NULL;
   END IF;

   IF p_counter_relationships_rec.attribute1 IS NULL THEN
      l_ctr_relationships_rec.attribute1 := l_old_ctr_relationships_rec.attribute1;
   ELSIF p_counter_relationships_rec.attribute1 = FND_API.G_MISS_CHAR THEN
      l_ctr_relationships_rec.attribute1 := NULL;
   END IF;

   IF p_counter_relationships_rec.attribute2 IS NULL THEN
      l_ctr_relationships_rec.attribute2 := l_old_ctr_relationships_rec.attribute2;
   ELSIF p_counter_relationships_rec.attribute2 = FND_API.G_MISS_CHAR THEN
      l_ctr_relationships_rec.attribute2 := NULL;
   END IF;

   IF p_counter_relationships_rec.attribute3 IS NULL THEN
      l_ctr_relationships_rec.attribute3 := l_old_ctr_relationships_rec.attribute3;
   ELSIF p_counter_relationships_rec.attribute3 = FND_API.G_MISS_CHAR THEN
      l_ctr_relationships_rec.attribute3 := NULL;
   END IF;

   IF p_counter_relationships_rec.attribute4 IS NULL THEN
      l_ctr_relationships_rec.attribute4 := l_old_ctr_relationships_rec.attribute4;
   ELSIF p_counter_relationships_rec.attribute4 = FND_API.G_MISS_CHAR THEN
      l_ctr_relationships_rec.attribute4 := NULL;
   END IF;

   IF p_counter_relationships_rec.attribute5 IS NULL THEN
      l_ctr_relationships_rec.attribute5 := l_old_ctr_relationships_rec.attribute5;
   ELSIF p_counter_relationships_rec.attribute5 = FND_API.G_MISS_CHAR THEN
      l_ctr_relationships_rec.attribute5 := NULL;
   END IF;

   IF p_counter_relationships_rec.attribute6 IS NULL THEN
      l_ctr_relationships_rec.attribute6 := l_old_ctr_relationships_rec.attribute6;
   ELSIF p_counter_relationships_rec.attribute6 = FND_API.G_MISS_CHAR THEN
      l_ctr_relationships_rec.attribute6 := NULL;
   END IF;

   IF p_counter_relationships_rec.attribute7 IS NULL THEN
      l_ctr_relationships_rec.attribute7 := l_old_ctr_relationships_rec.attribute7;
   ELSIF p_counter_relationships_rec.attribute7 = FND_API.G_MISS_CHAR THEN
      l_ctr_relationships_rec.attribute7 := NULL;
   END IF;

   IF p_counter_relationships_rec.attribute8 IS NULL THEN
      l_ctr_relationships_rec.attribute8 := l_old_ctr_relationships_rec.attribute8;
   ELSIF p_counter_relationships_rec.attribute8 = FND_API.G_MISS_CHAR THEN
      l_ctr_relationships_rec.attribute8 := NULL;
   END IF;

   IF p_counter_relationships_rec.attribute9 IS NULL THEN
      l_ctr_relationships_rec.attribute9 := l_old_ctr_relationships_rec.attribute9;
   ELSIF p_counter_relationships_rec.attribute9 = FND_API.G_MISS_CHAR THEN
      l_ctr_relationships_rec.attribute9 := NULL;
   END IF;

   IF p_counter_relationships_rec.attribute10 IS NULL THEN
      l_ctr_relationships_rec.attribute10 := l_old_ctr_relationships_rec.attribute10;
   ELSIF p_counter_relationships_rec.attribute10 = FND_API.G_MISS_CHAR THEN
      l_ctr_relationships_rec.attribute10 := NULL;
   END IF;

   IF p_counter_relationships_rec.attribute11 IS NULL THEN
      l_ctr_relationships_rec.attribute11 := l_old_ctr_relationships_rec.attribute11;
   ELSIF p_counter_relationships_rec.attribute11 = FND_API.G_MISS_CHAR THEN
      l_ctr_relationships_rec.attribute11 := NULL;
   END IF;

   IF p_counter_relationships_rec.attribute12 IS NULL THEN
      l_ctr_relationships_rec.attribute12 := l_old_ctr_relationships_rec.attribute12;
   ELSIF p_counter_relationships_rec.attribute12 = FND_API.G_MISS_CHAR THEN
      l_ctr_relationships_rec.attribute12 := NULL;
   END IF;

   IF p_counter_relationships_rec.attribute13 IS NULL THEN
      l_ctr_relationships_rec.attribute13 := l_old_ctr_relationships_rec.attribute13;
   ELSIF p_counter_relationships_rec.attribute13 = FND_API.G_MISS_CHAR THEN
      l_ctr_relationships_rec.attribute13 := NULL;
   END IF;

   IF p_counter_relationships_rec.attribute14 IS NULL THEN
      l_ctr_relationships_rec.attribute14 := l_old_ctr_relationships_rec.attribute14;
   ELSIF p_counter_relationships_rec.attribute14 = FND_API.G_MISS_CHAR THEN
      l_ctr_relationships_rec.attribute14 := NULL;
   END IF;

   IF p_counter_relationships_rec.attribute15 IS NULL THEN
      l_ctr_relationships_rec.attribute15 := l_old_ctr_relationships_rec.attribute15;
   ELSIF p_counter_relationships_rec.attribute15 = FND_API.G_MISS_CHAR THEN
      l_ctr_relationships_rec.attribute15 := NULL;
   END IF;

   IF p_counter_relationships_rec.attribute_category IS NULL THEN
      l_ctr_relationships_rec.attribute_category := l_old_ctr_relationships_rec.attribute_category;
   ELSIF p_counter_relationships_rec.attribute_category = FND_API.G_MISS_CHAR THEN
      l_ctr_relationships_rec.attribute_category := NULL;
   END IF;

   IF p_counter_relationships_rec.bind_variable_name IS NULL THEN
      l_ctr_relationships_rec.bind_variable_name := l_old_ctr_relationships_rec.bind_variable_name;
   ELSIF p_counter_relationships_rec.bind_variable_name = FND_API.G_MISS_CHAR THEN
      l_ctr_relationships_rec.bind_variable_name := NULL;
   END IF;

   IF p_counter_relationships_rec.migrated_flag IS NULL THEN
      l_ctr_relationships_rec.migrated_flag := l_old_ctr_relationships_rec.migrated_flag;
   ELSIF p_counter_relationships_rec.migrated_flag = FND_API.G_MISS_CHAR THEN
      l_ctr_relationships_rec.migrated_flag := NULL;
   END IF;

   IF p_counter_relationships_rec.factor IS NULL THEN
      l_ctr_relationships_rec.factor := l_old_ctr_relationships_rec.factor;
   ELSIF p_counter_relationships_rec.factor = FND_API.G_MISS_NUM THEN
      l_ctr_relationships_rec.factor := NULL;
   END IF;

   IF p_counter_relationships_rec.security_group_id IS NULL THEN
      l_ctr_relationships_rec.security_group_id := l_old_ctr_relationships_rec.security_group_id;
   ELSIF p_counter_relationships_rec.security_group_id = FND_API.G_MISS_NUM THEN
      l_ctr_relationships_rec.security_group_id := NULL;
   END IF;


   validate_start_date(l_ctr_relationships_rec.active_start_date);
   validate_lookups('CSI_CTR_RELATIONSHIP_TYPE_CODE', l_ctr_relationships_rec.relationship_type_code);

   csi_ctr_gen_utility_pvt.put_line(' type code = '||l_ctr_relationships_rec.relationship_type_code);
   IF l_ctr_relationships_rec.relationship_type_code = 'CONFIGURATION' THEN
      validate_ctr_relationship(l_ctr_relationships_rec.source_counter_id, l_source_direction,
                                l_src_ctr_start_date, l_src_ctr_end_date);
      validate_ctr_relationship(l_ctr_relationships_rec.object_counter_id, l_object_direction,
                                l_obj_ctr_start_date, l_obj_ctr_end_date);
      /* Validate direction */
      IF l_source_direction = 'B' and l_object_direction <> 'B'  THEN
         CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_REL_DIR');
      END IF;

      IF l_object_direction = 'B' and l_source_direction <> 'B' THEN
         CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_REL_DIR');
      END IF;

      IF p_counter_relationships_rec.active_start_date < l_src_ctr_start_date THEN
         CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_SOURCE_ST_DATE');
      ELSIF p_counter_relationships_rec.active_start_date < l_obj_ctr_start_date THEN
         CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_SOURCE_ST_DATE');
      END IF;

      IF l_src_ctr_end_date IS NOT NULL THEN
         IF p_counter_relationships_rec.active_start_date > l_src_ctr_end_date THEN
            CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_SOURCE_ST_DATE');
         END IF;
      END IF;

      IF l_obj_ctr_end_date IS NOT NULL THEN
         IF p_counter_relationships_rec.active_start_date > l_obj_ctr_end_date THEN
            CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_SOURCE_ST_DATE');
         END IF;
      END IF;

      OPEN c1(l_ctr_relationships_rec.source_counter_id);
      FETCH c1 into l_reading_date;
      IF l_reading_date IS NOT  NULL THEN
         IF p_counter_relationships_rec.active_start_date < l_reading_date THEN
            CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_SOURCE_ST_DATE');
         END IF;
      END IF;
      CLOSE c1;

      OPEN c1(l_ctr_relationships_rec.object_counter_id);
      FETCH c1 into l_reading_date;
      IF l_reading_date IS NOT  NULL THEN
         IF p_counter_relationships_rec.active_start_date < l_reading_date THEN
            CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_SOURCE_ST_DATE');
         END IF;
      END IF;
      CLOSE c1;

      /* A source counter cannot be a target counter */
      BEGIN
         SELECT 'N'
         INTO   l_valid_flag
         FROM   csi_counter_relationships
         WHERE  relationship_type_code = 'CONFIGURATION'
         AND    source_counter_id = l_ctr_relationships_rec.object_counter_id;

         CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_TARGET_CTR_EXIST');

      EXCEPTION
         WHEN NO_DATA_FOUND THEN NULL;
         WHEN TOO_MANY_ROWS THEN
            CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_TARGET_CTR_EXIST');

      END;
   ELSIF l_ctr_relationships_rec.relationship_type_code = 'FORMULA' THEN
      IF p_counter_relationships_rec.source_counter_id IS NULL THEN
         CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_REQ_FORMULA_REF');
      END IF;

   END IF;

   /* Call the table Handler */
   CSI_COUNTER_RELATIONSHIP_PKG.update_Row(
	p_RELATIONSHIP_ID              => p_counter_relationships_rec.relationship_id
  	,p_CTR_ASSOCIATION_ID           => p_counter_relationships_rec.ctr_association_id
  	,p_RELATIONSHIP_TYPE_CODE       => p_counter_relationships_rec.relationship_type_code
  	,p_SOURCE_COUNTER_ID            => p_counter_relationships_rec.source_counter_id
  	,p_OBJECT_COUNTER_ID            => p_counter_relationships_rec.object_counter_id
  	,p_ACTIVE_START_DATE            => p_counter_relationships_rec.active_start_date
  	,p_ACTIVE_END_DATE              => p_counter_relationships_rec.active_end_date
  	,p_OBJECT_VERSION_NUMBER        => p_counter_relationships_rec.object_version_number + 1
        ,p_LAST_UPDATE_DATE             => sysdate
        ,p_LAST_UPDATED_BY              => FND_GLOBAL.USER_ID
        ,p_CREATION_DATE                => p_counter_relationships_rec.creation_date
        ,p_CREATED_BY                   => p_counter_relationships_rec.created_by
        ,p_LAST_UPDATE_LOGIN            => FND_GLOBAL.USER_ID
  	,p_ATTRIBUTE_CATEGORY           => p_counter_relationships_rec.attribute_category
        ,p_ATTRIBUTE1                   => p_counter_relationships_rec.attribute1
        ,p_ATTRIBUTE2                   => p_counter_relationships_rec.attribute2
        ,p_ATTRIBUTE3                   => p_counter_relationships_rec.attribute3
        ,p_ATTRIBUTE4                   => p_counter_relationships_rec.attribute4
        ,p_ATTRIBUTE5                   => p_counter_relationships_rec.attribute5
        ,p_ATTRIBUTE6                   => p_counter_relationships_rec.attribute6
        ,p_ATTRIBUTE7                   => p_counter_relationships_rec.attribute7
        ,p_ATTRIBUTE8                   => p_counter_relationships_rec.attribute8
        ,p_ATTRIBUTE9                   => p_counter_relationships_rec.attribute9
        ,p_ATTRIBUTE10                  => p_counter_relationships_rec.attribute10
        ,p_ATTRIBUTE11                  => p_counter_relationships_rec.attribute11
        ,p_ATTRIBUTE12                  => p_counter_relationships_rec.attribute12
        ,p_ATTRIBUTE13                  => p_counter_relationships_rec.attribute13
        ,p_ATTRIBUTE14                  => p_counter_relationships_rec.attribute14
        ,p_ATTRIBUTE15                  => p_counter_relationships_rec.attribute15
        ,p_SECURITY_GROUP_ID            => p_counter_relationships_rec.security_group_id
	,p_MIGRATED_FLAG                => p_counter_relationships_rec.migrated_flag
  	,p_BIND_VARIABLE_NAME           => p_counter_relationships_rec.bind_variable_name
  	,p_FACTOR                       => p_counter_relationships_rec.factor);

   IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
        ROLLBACK TO update_ctr_relationship_pvt;
        RETURN;
   END IF;


   /* End of API Body */

   IF FND_API.to_Boolean(nvl(p_commit,FND_API.G_FALSE)) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and IF count is  get message info.
   FND_MSG_PUB.Count_And_Get
      ( p_count  =>  x_msg_count,
        p_data   =>  x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO update_ctr_relationship_pvt;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_ctr_relationship_pvt;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_ctr_relationship_pvt;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg
            ( G_PKG_NAME,
              l_api_name
            );
      END IF;
      FND_MSG_PUB.Count_And_Get
         ( p_count  => x_msg_count,
           p_data   => x_msg_data
         );
END update_counter_relationship;


--|---------------------------------------------------
--| procedure name: update_derived_filters
--| description :   procedure used to
--|                 update derived filters
--|---------------------------------------------------

PROCEDURE update_derived_filters
(
   p_api_version	       IN     NUMBER
   ,p_commit                   IN     VARCHAR2
   ,p_init_msg_list            IN     VARCHAR2
   ,p_validation_level         IN     NUMBER
   ,p_ctr_derived_filters_tbl  IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_tbl
   ,x_return_status            OUT    NOCOPY VARCHAR2
   ,x_msg_count                OUT    NOCOPY NUMBER
   ,x_msg_data                 OUT    NOCOPY VARCHAR2
) IS

   l_api_name			   CONSTANT VARCHAR2(30)   := 'UPDATE_DERIVED_FILTERS';
   l_api_version                   CONSTANT NUMBER         := 1.0;
   l_dummy			   VARCHAR2(1);
   l_found			   VARCHAR2(1);
   -- l_debug_level                   NUMBER;
   --l_flag                        VARCHAR2(1)             := 'N';
   l_msg_data                      VARCHAR2(2000);
   l_msg_index                     NUMBER;
   l_msg_count                     NUMBER;

   l_count                         NUMBER;
   l_return_message                VARCHAR2(100);
   l_ctr_derived_filters_rec	   CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_rec;
   l_old_ctr_derived_filters_rec   CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_rec;
   l_counter_id			   NUMBER;
   l_type			   VARCHAR2(30);
   l_name			   VARCHAR2(50);
   l_log_op			   VARCHAR2(30);
   l_desc_flex                     CSI_CTR_DATASTRUCTURES_PUB.dff_rec_type;

   l_return_status                 VARCHAR2(1);
   l_valid_flag                    VARCHAR2(1);

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  update_derived_filters;

   -- Check for freeze_flag in csi_install_parameters is set to 'Y'

   -- csi_ctr_gen_utility_pvt.check_ib_active;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   -- Check the profile option debug_level for debug message reporting
   -- l_debug_level:=fnd_profile.value('CSI_COUNTER_DEBUG_LEVEL');

   -- If debug_level = 1 then dump the procedure name
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'update_derived_filters');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 1) THEN
      csi_ctr_gen_utility_pvt.put_line( 'update_derived_filters'     ||
					p_api_version           ||'-'||
					p_commit                ||'-'||
					p_init_msg_list         ||'-'||
					p_validation_level );
      csi_ctr_gen_utility_pvt.dump_ctr_derived_filters_tbl(p_ctr_derived_filters_tbl);
   END IF;

   IF (p_ctr_derived_filters_tbl.count > 0) THEN
      FOR tab_row IN p_ctr_derived_filters_tbl.FIRST .. p_ctr_derived_filters_tbl.LAST
      LOOP
         IF p_ctr_derived_filters_tbl.EXISTS(tab_row) THEN
            IF ((p_ctr_derived_filters_tbl(tab_row).counter_derived_filter_id IS NULL)
               OR
               (p_ctr_derived_filters_tbl(tab_row).counter_derived_filter_id = FND_API.G_MISS_NUM))
            THEN
		   create_derived_filters
	           (p_api_version      => p_api_version
	            ,p_commit           => fnd_api.g_false
	            ,p_init_msg_list    => p_init_msg_list
	            ,p_validation_level => p_validation_level
                  ,p_ctr_derived_filters_tbl => p_ctr_derived_filters_tbl
	            ,x_return_status    => x_return_status
	            ,x_msg_count        => x_msg_count
	            ,x_msg_data         => x_msg_data
	           );

 	          IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	            l_msg_index := 1;
	            l_msg_count := x_msg_count;
	            WHILE l_msg_count > 0 LOOP
	               x_msg_data := FND_MSG_PUB.GET
	                             (l_msg_index,
	                              FND_API.G_FALSE);
	               csi_ctr_gen_utility_pvt.put_line('Error from CSI_COUNTER_TEMPLATE_PVT.CREATE_DERIVED_FILTERS');
	               csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
	               l_msg_index := l_msg_index + 1;
	               l_msg_count := l_msg_count - 1;
	            END LOOP;
	            RAISE FND_API.G_EXC_ERROR;
	         END IF;

            ELSE
               SELECT	counter_id,
		        counter_property_id,
               		attribute1,
             		attribute2,
            		attribute3,
 		        attribute4,
		        attribute5,
		        attribute6,
		        attribute7,
		        attribute8,
		        attribute9,
            		attribute10,
		        attribute11,
             		attribute12,
		        attribute13,
		        attribute14,
		        attribute15,
		        attribute_category
                 INTO	l_old_ctr_derived_filters_rec.counter_id,
          		l_old_ctr_derived_filters_rec.counter_property_id,
			l_old_ctr_derived_filters_rec.attribute1,
			l_old_ctr_derived_filters_rec.attribute2,
			l_old_ctr_derived_filters_rec.attribute3,
			l_old_ctr_derived_filters_rec.attribute4,
			l_old_ctr_derived_filters_rec.attribute5,
			l_old_ctr_derived_filters_rec.attribute6,
			l_old_ctr_derived_filters_rec.attribute7,
			l_old_ctr_derived_filters_rec.attribute8,
			l_old_ctr_derived_filters_rec.attribute9,
			l_old_ctr_derived_filters_rec.attribute10,
			l_old_ctr_derived_filters_rec.attribute11,
			l_old_ctr_derived_filters_rec.attribute12,
			l_old_ctr_derived_filters_rec.attribute13,
			l_old_ctr_derived_filters_rec.attribute14,
			l_old_ctr_derived_filters_rec.attribute15,
			l_old_ctr_derived_filters_rec.attribute_category
		   FROM CSI_COUNTER_DERIVED_FILTERS
		   -- WHERE   COUNTER_DERIVED_FILTER_ID = l_ctr_derived_filters_rec.COUNTER_DERIVED_FILTER_ID;
		   WHERE  COUNTER_DERIVED_FILTER_ID = p_ctr_derived_filters_tbl(tab_row).counter_derived_filter_id;

		   IF SQL%NOTFOUND THEN
		      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_DERIVED_FILTER_INVALID');
		   END IF;

		   IF NVL(l_old_ctr_derived_filters_rec.counter_id, -1) = FND_API.G_MISS_NUM THEN
		      l_counter_id := NULL;
		   ELSE
		      l_counter_id := l_old_ctr_derived_filters_rec.counter_id;
		   END IF;

		   IF NVL(l_counter_id, -1) <> l_old_ctr_derived_filters_rec.counter_id THEN
		      BEGIN
		         -- validate all counters
		         SELECT	NVL(type, 'REGULAR'), name
		         INTO l_type, l_name
		         FROM	csi_counters_bc_v
		         WHERE	counter_id = p_ctr_derived_filters_tbl(tab_row).counter_id;
		      EXCEPTION WHEN NO_DATA_FOUND THEN
		         csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_INVALID');
		      END;

		      -- validate all counter types are GROUP type
		      IF l_type <> 'FORMULA' THEN
		         csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_INV_GROUP_CTR','CTR_NAME',l_name);
		      END IF;
		   END IF;

		   -- validate all counter properties
		   IF NVL(p_ctr_derived_filters_tbl(tab_row).counter_property_id, -1) <> FND_API.G_MISS_NUM AND
		      NVL(p_ctr_derived_filters_tbl(tab_row).counter_property_id, -1) <> l_old_ctr_derived_filters_rec.counter_property_id THEN
		      BEGIN
		         SELECT	'x'
	                 INTO   l_dummy
		         FROM	csi_ctr_properties_bc_v
		         WHERE	counter_property_id = l_ctr_derived_filters_rec.counter_property_id;
		      EXCEPTION WHEN NO_DATA_FOUND THEN
		         csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_PROP_INVALID');
		      END;
		   END IF;

		   -- validate LEFT_PARENT
		   IF p_ctr_derived_filters_tbl(tab_row).LEFT_PARENT NOT IN (FND_API.G_MISS_CHAR,'(', '((', '(((', '((((', '(((((') THEN
		      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_INV_DER_LEFT_PARENT',
							     'PARM',l_ctr_derived_filters_rec.LEFT_PARENT);
		   END IF;

		   -- validate RIGHT_PARENT
		   IF p_ctr_derived_filters_tbl(tab_row).RIGHT_PARENT NOT IN (FND_API.G_MISS_CHAR,')', '))', ')))', '))))', ')))))') THEN
		      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_INV_DER_RIGHT_PARENT',
		   					     'PARM',l_ctr_derived_filters_rec.RIGHT_PARENT);
		   END IF;

		   -- validate RELATIONAL_OPERATOR
		   IF p_ctr_derived_filters_tbl(tab_row).RELATIONAL_OPERATOR NOT IN (FND_API.G_MISS_CHAR,'=', '<', '<=', '>', '>=', '!=', '<>') THEN
		      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_INV_DER_REL_OPERATOR',
							     'PARM',l_ctr_derived_filters_rec.RELATIONAL_OPERATOR);
		   END IF;

		   -- validate LOGICAL_OPERATOR
		   -- l_log_op := upper(l_ctr_derived_filters_rec.LOGICAL_OPERATOR);
                   IF p_ctr_derived_filters_tbl(tab_row).LOGICAL_OPERATOR = FND_API.G_MISS_CHAR then
                      l_log_op := null;
                   ELSE
                      l_log_op := upper(p_ctr_derived_filters_tbl(tab_row).LOGICAL_OPERATOR);
                   END IF;

		   IF l_log_op IS NOT NULL THEN
                      IF l_log_op NOT IN (FND_API.G_MISS_CHAR, 'AND', 'OR') THEN
		         csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_INV_DER_LOG_OPERATOR', 'PARM',l_ctr_derived_filters_rec.LOGICAL_OPERATOR);
		      END IF;
		   END IF;

		   -- initialize descritive flexfield
		   -- csi_ctr_gen_utility_pvt.Initialize_Desc_Flex_For_Upd(p_ctr_derived_filters_rec,l_old_ctr_derived_filters_rec);

		   -- validate SEQ_NO
                   IF p_ctr_derived_filters_tbl(tab_row).seq_no = FND_API.G_MISS_NUM then
                      p_ctr_derived_filters_tbl(tab_row).seq_no := null;
                   END IF;

		   IF p_ctr_derived_filters_tbl(tab_row).SEQ_NO IS NULL THEN
		      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_DER_FILTER_NULL_SEQ');
		   ELSE
		      IF p_ctr_derived_filters_tbl(tab_row).SEQ_NO <> FND_API.G_MISS_NUM THEN
		         BEGIN
		            SELECT 'x'
		            INTO   l_dummy
		            FROM   CSI_COUNTER_DERIVED_FILTERS
		            WHERE  counter_id = p_ctr_derived_filters_tbl(tab_row).counter_id
		            AND    seq_no = p_ctr_derived_filters_tbl(tab_row).seq_no
		            AND    counter_derived_filter_id <> p_ctr_derived_filters_tbl(tab_row).counter_derived_filter_id;

			    -- this means that for this counter, there is one another
			    -- derived filter record with the same sequence number.
			    -- Raise error.
			    csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_DUP_DERFILTER_SEQNO',
						   'SEQNO',to_char(p_ctr_derived_filters_tbl(tab_row).seq_no),
						   'CTR_NAME',l_name);

		         EXCEPTION WHEN NO_DATA_FOUND THEN
		            -- good. you can proceed.
			         NULL;
		         END;
		      END IF;
		   END IF;

		   -- call table handler here
		   CSI_CTR_DERIVED_FILTERS_PKG.Update_Row
		   (
	      	     p_ctr_derived_filters_tbl(tab_row).COUNTER_DERIVED_FILTER_ID
		,p_ctr_derived_filters_tbl(tab_row).COUNTER_ID
		,p_ctr_derived_filters_tbl(tab_row).SEQ_NO
		,p_ctr_derived_filters_tbl(tab_row).LEFT_PARENT
		,p_ctr_derived_filters_tbl(tab_row).COUNTER_PROPERTY_ID
		,p_ctr_derived_filters_tbl(tab_row).RELATIONAL_OPERATOR
		,p_ctr_derived_filters_tbl(tab_row).RIGHT_VALUE
		,p_ctr_derived_filters_tbl(tab_row).RIGHT_PARENT
		,p_ctr_derived_filters_tbl(tab_row).LOGICAL_OPERATOR
		,p_ctr_derived_filters_tbl(tab_row).START_DATE_ACTIVE
		,p_ctr_derived_filters_tbl(tab_row).END_DATE_ACTIVE
		,p_ctr_derived_filters_tbl(tab_row).OBJECT_VERSION_NUMBER +1
		,sysdate
		,FND_GLOBAL.USER_ID
		,p_ctr_derived_filters_tbl(tab_row).CREATION_DATE
		,p_ctr_derived_filters_tbl(tab_row).CREATED_BY
		,FND_GLOBAL.USER_ID
		,p_ctr_derived_filters_tbl(tab_row).ATTRIBUTE1
		,p_ctr_derived_filters_tbl(tab_row).ATTRIBUTE2
		,p_ctr_derived_filters_tbl(tab_row).ATTRIBUTE3
		,p_ctr_derived_filters_tbl(tab_row).ATTRIBUTE4
		,p_ctr_derived_filters_tbl(tab_row).ATTRIBUTE5
		,p_ctr_derived_filters_tbl(tab_row).ATTRIBUTE6
		,p_ctr_derived_filters_tbl(tab_row).ATTRIBUTE7
		,p_ctr_derived_filters_tbl(tab_row).ATTRIBUTE8
		,p_ctr_derived_filters_tbl(tab_row).ATTRIBUTE9
		,p_ctr_derived_filters_tbl(tab_row).ATTRIBUTE10
		,p_ctr_derived_filters_tbl(tab_row).ATTRIBUTE11
		,p_ctr_derived_filters_tbl(tab_row).ATTRIBUTE12
		,p_ctr_derived_filters_tbl(tab_row).ATTRIBUTE13
		,p_ctr_derived_filters_tbl(tab_row).ATTRIBUTE14
		,p_ctr_derived_filters_tbl(tab_row).ATTRIBUTE15
		,p_ctr_derived_filters_tbl(tab_row).ATTRIBUTE_CATEGORY
		,p_ctr_derived_filters_tbl(tab_row).SECURITY_GROUP_ID
		,p_ctr_derived_filters_tbl(tab_row).MIGRATED_FLAG
		);

		   csi_ctr_gen_utility_pvt.Validate_GrpOp_ctr
		   (
		      p_api_version => 1.0,
		      p_commit => FND_API.G_FALSE,
		      p_validation_level => FND_API.G_VALID_LEVEL_NONE,
		      x_return_status => l_return_status,
		      x_msg_count	=> l_msg_count,
		      x_msg_data => l_msg_data,
		      p_counter_id => p_ctr_derived_filters_tbl(tab_row).COUNTER_ID,
		      x_valid_flag => l_valid_flag
		   );

		   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		      RAISE FND_API.G_EXC_ERROR;
		   END IF;

		   -- l_ctr_derived_filters_rec.OBJECT_VERSION_NUMBER := l_ctr_derived_filters_rec.OBJECT_VERSION_NUMBER+1;
                   csi_ctr_gen_utility_pvt.put_line('before updating csi_counters_vl');
                   BEGIN
                      SELECT 'x'
                      INTO   l_found
                      FROM   csi_counter_template_vl
                      WHERE  counter_id = p_ctr_derived_filters_tbl(tab_row).COUNTER_ID;

                      UPDATE  csi_counter_template_b
                      SET     valid_flag = decode(l_valid_flag, 'Y', 'Y', 'N')
                      WHERE   counter_id = p_ctr_derived_filters_tbl(tab_row).COUNTER_ID;
                      csi_ctr_gen_utility_pvt.put_line('after updating csi_counters_vl');
                   EXCEPTION
                      WHEN NO_DATA_FOUND THEN
		         UPDATE csi_counters_b
		         SET    valid_flag = decode(l_valid_flag, 'Y', 'Y', 'N')
		         WHERE  counter_id = p_ctr_derived_filters_tbl(tab_row).COUNTER_ID;
                         csi_ctr_gen_utility_pvt.put_line('after updating csi_counters_vl');
                   END;
            END IF;
         END IF;
      END LOOP;
 END IF;
 -- End of API body

 -- Standard check of p_commit.
 IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
 END IF;

 FND_MSG_PUB.Count_And_Get
   (   p_count => x_msg_count,
       p_data  => x_msg_data
   );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO update_derived_filters;
      FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count,
                 p_data  => x_msg_data
                );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_derived_filters;
      FND_MSG_PUB.Count_And_Get
      		(p_count => x_msg_count,
             p_data  => x_msg_data
            );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_derived_filters;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
            (G_PKG_NAME,
             l_api_name
            );
       END IF;
       FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data
            );

END update_derived_filters;


PROCEDURE Create_Estimation_Method
(
    p_api_version                IN      NUMBER
    ,p_init_msg_list             IN      VARCHAR2
    ,p_commit                    IN      VARCHAR2
    ,p_validation_level          IN      NUMBER
    ,x_return_status                 OUT NOCOPY     VARCHAR2
    ,x_msg_count                     OUT NOCOPY     NUMBER
    ,x_msg_data                      OUT NOCOPY     VARCHAR2
    ,p_ctr_estimation_rec        IN      CSI_CTR_DATASTRUCTURES_PUB.ctr_estimation_methods_rec
) IS


   l_api_name                     CONSTANT VARCHAR2(30)   := 'CREATE_ESTIMATION_METHOD';
   l_api_version                  CONSTANT NUMBER         := 1.0;
   l_msg_data                     VARCHAR2(2000);
   l_msg_index                    NUMBER;
   l_msg_count                    NUMBER;
   -- l_debug_level                  NUMBER;
   l_ESTIMATION_ID	          NUMBER;
   l_NAME                         VARCHAR2(50);
   l_DESCRIPTION                  VARCHAR2(240);
   l_ESTIMATION_TYPE              VARCHAR2(10);
   l_FIXED_VALUE                  NUMBER;
   l_USAGE_MARKUP                 NUMBER;
   l_DEFAULT_VALUE                NUMBER;
   l_COUNTER_ID                   NUMBER;
   l_ESTIMATION_AVG_TYPE          VARCHAR2(10);
   l_START_DATE_ACTIVE            DATE;
   l_END_DATE_ACTIVE              DATE;
   l_LAST_UPDATE_DATE             DATE;
   l_LAST_UPDATED_BY              NUMBER;
   l_CREATION_DATE                DATE;
   l_CREATED_BY                   NUMBER;
   l_LAST_UPDATE_LOGIN            NUMBER;
   l_ATTRIBUTE1                   VARCHAR2(150);
   l_ATTRIBUTE2                   VARCHAR2(150);
   l_ATTRIBUTE3                   VARCHAR2(150);
   l_ATTRIBUTE4                   VARCHAR2(150);
   l_ATTRIBUTE5                   VARCHAR2(150);
   l_ATTRIBUTE6                   VARCHAR2(150);
   l_ATTRIBUTE7                   VARCHAR2(150);
   l_ATTRIBUTE8                   VARCHAR2(150);
   l_ATTRIBUTE9                   VARCHAR2(150);
   l_ATTRIBUTE10                  VARCHAR2(150);
   l_ATTRIBUTE11                  VARCHAR2(150);
   l_ATTRIBUTE12                  VARCHAR2(150);
   l_ATTRIBUTE13                  VARCHAR2(150);
   l_ATTRIBUTE14                  VARCHAR2(150);
   l_ATTRIBUTE15                  VARCHAR2(150);
   l_ATTRIBUTE_CATEGORY           VARCHAR2(30);
   l_OBJECT_VERSION_NUMBER        NUMBER;
   l_MIGRATED_FLAG                VARCHAR2(1);
   l_dummy                        VARCHAR2(1);
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  create_estimation_method_pvt;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   --
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'create_estimation_method_pvt'          ||'-'||
                                     p_api_version                              ||'-'||
                                     nvl(p_commit,FND_API.G_FALSE)              ||'-'||
                                     nvl(p_init_msg_list,FND_API.G_FALSE)       ||'-'||
                                     nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL) );
   END IF;


   if p_ctr_estimation_rec.estimation_id = FND_API.G_MISS_NUM then
      l_estimation_id := null;
   else
      l_estimation_id := p_ctr_estimation_rec.estimation_id;
   end if;

   if p_ctr_estimation_rec.name = FND_API.G_MISS_CHAR then
      l_name := null;
   else
      l_name := p_ctr_estimation_rec.name;
   end if;

   if p_ctr_estimation_rec.description= FND_API.G_MISS_CHAR then
      l_description := null;
   else
      l_description := p_ctr_estimation_rec.description;
   end if;

   if p_ctr_estimation_rec.estimation_type= FND_API.G_MISS_CHAR then
      l_estimation_type := null;
   else
      l_estimation_type := p_ctr_estimation_rec.estimation_type;
   end if;

   if p_ctr_estimation_rec.estimation_avg_type = FND_API.G_MISS_CHAR then
      l_estimation_avg_type := null;
   else
      l_estimation_avg_type := p_ctr_estimation_rec.estimation_avg_type;
   end if;

   if p_ctr_estimation_rec.fixed_value = FND_API.G_MISS_NUM then
      l_fixed_value := null;
   else
      l_fixed_value := p_ctr_estimation_rec.fixed_value;
   end if;

   if p_ctr_estimation_rec.usage_markup = FND_API.G_MISS_NUM then
      l_usage_markup := null;
   else
      l_usage_markup := p_ctr_estimation_rec.usage_markup;
   end if;

   if p_ctr_estimation_rec.default_value = FND_API.G_MISS_NUM then
      l_default_value := null;
   else
      l_default_value := p_ctr_estimation_rec.default_value;
   end if;

   if nvl(p_ctr_estimation_rec.start_date_active,FND_API.G_MISS_DATE) = FND_API.G_MISS_DATE then
      l_start_date_active := sysdate;
   else
      l_start_date_active := p_ctr_estimation_rec.start_date_active;
   end if;

   if p_ctr_estimation_rec.end_date_active = FND_API.G_MISS_DATE then
      l_end_date_active := null;
   else
      l_end_date_active := p_ctr_estimation_rec.end_date_active;
   end if;

   if p_ctr_estimation_rec.attribute1 = FND_API.G_MISS_CHAR then
      l_attribute1 := null;
   else
      l_attribute1 := p_ctr_estimation_rec.attribute1;
   end if;

   if p_ctr_estimation_rec.attribute2 = FND_API.G_MISS_CHAR then
      l_attribute2 := null;
   else
      l_attribute2 := p_ctr_estimation_rec.attribute2;
   end if;

   if p_ctr_estimation_rec.attribute3 = FND_API.G_MISS_CHAR then
      l_attribute3 := null;
   else
      l_attribute3 := p_ctr_estimation_rec.attribute3;
   end if;

   if p_ctr_estimation_rec.attribute4 = FND_API.G_MISS_CHAR then
      l_attribute4 := null;
   else
      l_attribute4 := p_ctr_estimation_rec.attribute4;
   end if;

   if p_ctr_estimation_rec.attribute5 = FND_API.G_MISS_CHAR then
      l_attribute5 := null;
   else
      l_attribute5 := p_ctr_estimation_rec.attribute5;
   end if;

   if p_ctr_estimation_rec.attribute6 = FND_API.G_MISS_CHAR then
      l_attribute6 := null;
   else
      l_attribute6 := p_ctr_estimation_rec.attribute6;
   end if;

   if p_ctr_estimation_rec.attribute7 = FND_API.G_MISS_CHAR then
      l_attribute7 := null;
   else
      l_attribute7 := p_ctr_estimation_rec.attribute7;
   end if;

   if p_ctr_estimation_rec.attribute8 = FND_API.G_MISS_CHAR then
      l_attribute8 := null;
   else
      l_attribute8 := p_ctr_estimation_rec.attribute8;
   end if;

   if p_ctr_estimation_rec.attribute9 = FND_API.G_MISS_CHAR then
      l_attribute9 := null;
   else
      l_attribute9 := p_ctr_estimation_rec.attribute9;
   end if;

   if p_ctr_estimation_rec.attribute10 = FND_API.G_MISS_CHAR then
      l_attribute10 := null;
   else
      l_attribute10 := p_ctr_estimation_rec.attribute10;
   end if;

   if p_ctr_estimation_rec.attribute11 = FND_API.G_MISS_CHAR then
      l_attribute11 := null;
   else
      l_attribute11 := p_ctr_estimation_rec.attribute11;
   end if;

   if p_ctr_estimation_rec.attribute12 = FND_API.G_MISS_CHAR then
      l_attribute12 := null;
   else
      l_attribute12 := p_ctr_estimation_rec.attribute12;
   end if;

   if p_ctr_estimation_rec.attribute13 = FND_API.G_MISS_CHAR then
      l_attribute13 := null;
   else
      l_attribute13 := p_ctr_estimation_rec.attribute13;
   end if;

   if p_ctr_estimation_rec.attribute14 = FND_API.G_MISS_CHAR then
      l_attribute14 := null;
   else
      l_attribute14 := p_ctr_estimation_rec.attribute14;
   end if;

   if p_ctr_estimation_rec.attribute15 = FND_API.G_MISS_CHAR then
      l_attribute15 := null;
   else
      l_attribute15 := p_ctr_estimation_rec.attribute15;
   end if;

   if p_ctr_estimation_rec.attribute_category = FND_API.G_MISS_CHAR then
      l_attribute_category := null;
   else
      l_attribute_category := p_ctr_estimation_rec.attribute_category;
   end if;

   if p_ctr_estimation_rec.migrated_flag = FND_API.G_MISS_CHAR then
      l_migrated_flag := null;
   else
      l_migrated_flag := p_ctr_estimation_rec.migrated_flag;
   end if;

   -- validate_start_date(l_start_date_active);

   BEGIN
      SELECT 'X'
      INTO   l_dummy
      FROM   csi_ctr_estimate_methods_vl
      WHERE  name = l_name;

      CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_EST_DUP_NAME','CTR_EST_NAME',l_name);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         NULL;
   END;

   validate_lookups('CSI_COUNTER_ESTIMATION_TYPE',l_estimation_type);

   IF l_estimation_avg_type not in ('DLY','MTH') THEN
      CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_EST_AVG_TYPE_INV','CTR_EST_AVG_TYPE',l_estimation_avg_type);
   END IF;

   IF l_estimation_type = 'FIXED' then
      IF l_fixed_value IS NULL THEN
         CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_EST_INV_FIXED');
      END IF;
   -- ELSIF l_estimation_type = 'USAGE' then
     --  IF l_default_value IS NULL OR l_usage_markup IS NULL THEN
       --   CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_EST_INV_USAGE');
      -- END IF;
   END IF;

   /* Table Handler call */
   CSI_CTR_ESTIMATE_METHODS_PKG.Insert_Row(
	px_ESTIMATION_ID                => l_estimation_id
 	,p_ESTIMATION_TYPE              => l_estimation_type
 	,p_FIXED_VALUE                  => l_fixed_value
 	,p_USAGE_MARKUP                 => l_usage_markup
 	,p_DEFAULT_VALUE                => l_default_value
 	,p_ESTIMATION_AVG_TYPE          => l_estimation_avg_type
	,p_START_DATE_ACTIVE            => l_start_date_active
	,p_END_DATE_ACTIVE              => l_end_date_active
        ,p_LAST_UPDATE_DATE             => sysdate
        ,p_LAST_UPDATED_BY              => FND_GLOBAL.USER_ID
        ,p_CREATION_DATE                => sysdate
        ,p_CREATED_BY                   => FND_GLOBAL.USER_ID
        ,p_LAST_UPDATE_LOGIN            => FND_GLOBAL.USER_ID
        ,p_ATTRIBUTE1                   => l_attribute1
        ,p_ATTRIBUTE2                   => l_attribute2
        ,p_ATTRIBUTE3                   => l_attribute3
        ,p_ATTRIBUTE4                   => l_attribute4
        ,p_ATTRIBUTE5                   => l_attribute5
        ,p_ATTRIBUTE6                   => l_attribute6
        ,p_ATTRIBUTE7                   => l_attribute7
        ,p_ATTRIBUTE8                   => l_attribute8
        ,p_ATTRIBUTE9                   => l_attribute9
        ,p_ATTRIBUTE10                  => l_attribute10
        ,p_ATTRIBUTE11                  => l_attribute11
        ,p_ATTRIBUTE12                  => l_attribute12
        ,p_ATTRIBUTE13                  => l_attribute13
        ,p_ATTRIBUTE14                  => l_attribute14
        ,p_ATTRIBUTE15                  => l_attribute15
        ,p_ATTRIBUTE_CATEGORY           => l_attribute_category
	,p_OBJECT_VERSION_NUMBER        => 1
 	,p_MIGRATED_FLAG                => l_migrated_flag
        ,p_NAME	                        => l_name
        ,p_DESCRIPTION                  => l_description
        );

   IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
        ROLLBACK TO create_estimation_method_pvt;
        RETURN;
   END IF;

   /* End of table handler call */

   IF FND_API.to_Boolean(nvl(p_commit,FND_API.G_FALSE)) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and IF count is  get message info.
   FND_MSG_PUB.Count_And_Get
      ( p_count  =>  x_msg_count,
        p_data   =>  x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO create_estimation_method_pvt;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_estimation_method_pvt;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_estimation_method_pvt;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg
            ( G_PKG_NAME,
              l_api_name
            );
      END IF;
      FND_MSG_PUB.Count_And_Get
         ( p_count  => x_msg_count,
           p_data   => x_msg_data
         );
END create_estimation_method;

PROCEDURE Update_Estimation_Method
(
    p_api_version                IN      NUMBER
    ,p_init_msg_list             IN      VARCHAR2
    ,p_commit                    IN      VARCHAR2
    ,p_validation_level          IN      NUMBER
    ,x_return_status                 OUT NOCOPY  VARCHAR2
    ,x_msg_count                     OUT NOCOPY  NUMBER
    ,x_msg_data                      OUT NOCOPY  VARCHAR2
    ,p_ctr_estimation_rec        IN      CSI_CTR_DATASTRUCTURES_PUB.ctr_estimation_methods_rec
) IS

   CURSOR cur_estimation_rec(p_estimation_id IN NUMBER) IS
   SELECT name
          ,description
          ,estimation_type
          ,fixed_value
          ,usage_markup
          ,default_value
          ,estimation_avg_type
          ,start_date_active
          ,end_date_active
          ,last_update_date
          ,last_updated_by
          ,creation_date
          ,created_by
          ,last_update_login
          ,attribute1
          ,attribute2
          ,attribute3
          ,attribute4
          ,attribute5
          ,attribute6
          ,attribute7
          ,attribute8
          ,attribute9
          ,attribute10
          ,attribute11
          ,attribute12
          ,attribute13
          ,attribute14
          ,attribute15
          ,attribute_category
          ,object_version_number
          ,migrated_flag
   FROM  csi_ctr_estimate_methods_vl
   WHERE estimation_id = p_estimation_id
   FOR UPDATE OF OBJECT_VERSION_NUMBER;
   l_old_ctr_estimation_rec  cur_estimation_rec%ROWTYPE;

   l_api_name                      CONSTANT VARCHAR2(30)   := 'UPDATE_ESTIMATION_METHOD';
   l_api_version                   CONSTANT NUMBER         := 1.0;
   l_msg_data                      VARCHAR2(2000);
   l_msg_index                     NUMBER;
   l_msg_count                     NUMBER;
   -- l_debug_level                   NUMBER;

   l_ctr_estimation_rec            CSI_CTR_DATASTRUCTURES_PUB.ctr_estimation_methods_rec;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  update_estimation_method_pvt;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   --
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'update_estimation_method_pvt'          ||'-'||
           p_api_version                              ||'-'||
           nvl(p_commit,FND_API.G_FALSE)              ||'-'||
           nvl(p_init_msg_list,FND_API.G_FALSE)       ||'-'||
           nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL) );
   END IF;

   /* Start of API Body */
   OPEN cur_estimation_rec(p_ctr_estimation_rec.estimation_id);
   FETCH cur_estimation_rec INTO l_old_ctr_estimation_rec;
   IF  (l_old_ctr_estimation_rec.object_version_number <> nvl(p_ctr_estimation_rec.OBJECT_VERSION_NUMBER,0)) THEN
      FND_MESSAGE.Set_Name('CSI', 'CSI_API_OBJ_VER_MISMATCH');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   CLOSE cur_estimation_rec;

   -- IF SQL%NOTFOUND THEN
   --    CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_ESTIM_NOTEXISTS');
   -- END IF;

   l_ctr_estimation_rec := p_ctr_estimation_rec;


   IF p_ctr_estimation_rec.name IS NULL THEN
      l_ctr_estimation_rec.name := l_old_ctr_estimation_rec.name;
   ELSIF p_ctr_estimation_rec.name = FND_API.G_MISS_CHAR THEN
      l_ctr_estimation_rec.name := NULL;
   END IF;

   IF p_ctr_estimation_rec.description IS NULL THEN
      l_ctr_estimation_rec.description := l_old_ctr_estimation_rec.description;
   ELSIF p_ctr_estimation_rec.description = FND_API.G_MISS_CHAR THEN
      l_ctr_estimation_rec.description := NULL;
   END IF;

   IF p_ctr_estimation_rec.estimation_type IS NULL THEN
      l_ctr_estimation_rec.estimation_type := l_old_ctr_estimation_rec.estimation_type;
   ELSIF p_ctr_estimation_rec.estimation_type = FND_API.G_MISS_CHAR THEN
      l_ctr_estimation_rec.estimation_type := NULL;
   END IF;

   IF p_ctr_estimation_rec.fixed_value IS NULL THEN
      l_ctr_estimation_rec.fixed_value := l_old_ctr_estimation_rec.fixed_value;
   ELSIF p_ctr_estimation_rec.fixed_value = FND_API.G_MISS_NUM THEN
      l_ctr_estimation_rec.fixed_value := NULL;
   END IF;

   IF p_ctr_estimation_rec.usage_markup IS NULL THEN
      l_ctr_estimation_rec.usage_markup := l_old_ctr_estimation_rec.usage_markup;
   ELSIF p_ctr_estimation_rec.usage_markup = FND_API.G_MISS_NUM THEN
      l_ctr_estimation_rec.usage_markup := NULL;
   END IF;

   IF p_ctr_estimation_rec.default_value IS NULL THEN
      l_ctr_estimation_rec.default_value := l_old_ctr_estimation_rec.default_value;
   ELSIF p_ctr_estimation_rec.default_value = FND_API.G_MISS_NUM THEN
      l_ctr_estimation_rec.default_value := NULL;
   END IF;

   IF p_ctr_estimation_rec.estimation_avg_type IS NULL THEN
      l_ctr_estimation_rec.estimation_avg_type := l_old_ctr_estimation_rec.estimation_avg_type;
   ELSIF p_ctr_estimation_rec.estimation_avg_type = FND_API.G_MISS_CHAR THEN
      l_ctr_estimation_rec.estimation_avg_type := NULL;
   END IF;

   IF p_ctr_estimation_rec.start_date_active IS NULL THEN
      l_ctr_estimation_rec.start_date_active := l_old_ctr_estimation_rec.start_date_active;
   ELSIF p_ctr_estimation_rec.start_date_active = FND_API.G_MISS_DATE THEN
      l_ctr_estimation_rec.start_date_active := NULL;
   END IF;

   IF p_ctr_estimation_rec.end_date_active IS NULL THEN
      l_ctr_estimation_rec.end_date_active := l_old_ctr_estimation_rec.end_date_active;
   ELSIF p_ctr_estimation_rec.end_date_active = FND_API.G_MISS_DATE THEN
      l_ctr_estimation_rec.end_date_active := NULL;
   END IF;

   IF p_ctr_estimation_rec.attribute_category IS NULL THEN
      l_ctr_estimation_rec.attribute_category := l_old_ctr_estimation_rec.attribute_category;
   ELSIF p_ctr_estimation_rec.attribute_category = FND_API.G_MISS_CHAR THEN
      l_ctr_estimation_rec.attribute_category := NULL;
   END IF;
--
   IF p_ctr_estimation_rec.attribute1 IS NULL THEN
      l_ctr_estimation_rec.attribute1 := l_old_ctr_estimation_rec.attribute1;
   ELSIF p_ctr_estimation_rec.attribute1 = FND_API.G_MISS_CHAR THEN
      l_ctr_estimation_rec.attribute1 := NULL;
   END IF;

   IF p_ctr_estimation_rec.attribute2 IS NULL THEN
      l_ctr_estimation_rec.attribute2 := l_old_ctr_estimation_rec.attribute2;
   ELSIF p_ctr_estimation_rec.attribute2 = FND_API.G_MISS_CHAR THEN
      l_ctr_estimation_rec.attribute2 := NULL;
   END IF;

   IF p_ctr_estimation_rec.attribute3 IS NULL THEN
      l_ctr_estimation_rec.attribute3 := l_old_ctr_estimation_rec.attribute3;
   ELSIF p_ctr_estimation_rec.attribute3 = FND_API.G_MISS_CHAR THEN
      l_ctr_estimation_rec.attribute3 := NULL;
   END IF;

   IF p_ctr_estimation_rec.attribute4 IS NULL THEN
      l_ctr_estimation_rec.attribute4 := l_old_ctr_estimation_rec.attribute4;
   ELSIF p_ctr_estimation_rec.attribute4 = FND_API.G_MISS_CHAR THEN
      l_ctr_estimation_rec.attribute4 := NULL;
   END IF;

   IF p_ctr_estimation_rec.attribute5 IS NULL THEN
      l_ctr_estimation_rec.attribute5 := l_old_ctr_estimation_rec.attribute5;
   ELSIF p_ctr_estimation_rec.attribute5 = FND_API.G_MISS_CHAR THEN
      l_ctr_estimation_rec.attribute5 := NULL;
   END IF;

   IF p_ctr_estimation_rec.attribute6 IS NULL THEN
      l_ctr_estimation_rec.attribute6 := l_old_ctr_estimation_rec.attribute6;
   ELSIF p_ctr_estimation_rec.attribute6 = FND_API.G_MISS_CHAR THEN
      l_ctr_estimation_rec.attribute6 := NULL;
   END IF;

   IF p_ctr_estimation_rec.attribute7 IS NULL THEN
      l_ctr_estimation_rec.attribute7 := l_old_ctr_estimation_rec.attribute7;
   ELSIF p_ctr_estimation_rec.attribute7 = FND_API.G_MISS_CHAR THEN
      l_ctr_estimation_rec.attribute7 := NULL;
   END IF;

   IF p_ctr_estimation_rec.attribute8 IS NULL THEN
      l_ctr_estimation_rec.attribute8 := l_old_ctr_estimation_rec.attribute8;
   ELSIF p_ctr_estimation_rec.attribute8 = FND_API.G_MISS_CHAR THEN
      l_ctr_estimation_rec.attribute8 := NULL;
   END IF;

   IF p_ctr_estimation_rec.attribute9 IS NULL THEN
      l_ctr_estimation_rec.attribute9 := l_old_ctr_estimation_rec.attribute9;
   ELSIF p_ctr_estimation_rec.attribute9 = FND_API.G_MISS_CHAR THEN
      l_ctr_estimation_rec.attribute9 := NULL;
   END IF;

   IF p_ctr_estimation_rec.attribute10 IS NULL THEN
      l_ctr_estimation_rec.attribute10 := l_old_ctr_estimation_rec.attribute10;
   ELSIF p_ctr_estimation_rec.attribute10 = FND_API.G_MISS_CHAR THEN
      l_ctr_estimation_rec.attribute10 := NULL;
   END IF;

   IF p_ctr_estimation_rec.attribute11 IS NULL THEN
      l_ctr_estimation_rec.attribute11 := l_old_ctr_estimation_rec.attribute11;
   ELSIF p_ctr_estimation_rec.attribute11 = FND_API.G_MISS_CHAR THEN
      l_ctr_estimation_rec.attribute11 := NULL;
   END IF;

   IF p_ctr_estimation_rec.attribute12 IS NULL THEN
      l_ctr_estimation_rec.attribute12 := l_old_ctr_estimation_rec.attribute12;
   ELSIF p_ctr_estimation_rec.attribute12= FND_API.G_MISS_CHAR THEN
      l_ctr_estimation_rec.attribute12 := NULL;
   END IF;

   IF p_ctr_estimation_rec.attribute13 IS NULL THEN
      l_ctr_estimation_rec.attribute13 := l_old_ctr_estimation_rec.attribute13;
   ELSIF p_ctr_estimation_rec.attribute13 = FND_API.G_MISS_CHAR THEN
      l_ctr_estimation_rec.attribute13 := NULL;
   END IF;

   IF p_ctr_estimation_rec.attribute14 IS NULL THEN
      l_ctr_estimation_rec.attribute14 := l_old_ctr_estimation_rec.attribute14;
   ELSIF p_ctr_estimation_rec.attribute14 = FND_API.G_MISS_CHAR THEN
      l_ctr_estimation_rec.attribute14 := NULL;
   END IF;

   IF p_ctr_estimation_rec.attribute15 IS NULL THEN
      l_ctr_estimation_rec.attribute15 := l_old_ctr_estimation_rec.attribute15;
   ELSIF p_ctr_estimation_rec.attribute15 = FND_API.G_MISS_CHAR THEN
      l_ctr_estimation_rec.attribute15 := NULL;
   END IF;

   IF p_ctr_estimation_rec.migrated_flag IS NULL THEN
      l_ctr_estimation_rec.migrated_flag := l_old_ctr_estimation_rec.migrated_flag;
   ELSIF p_ctr_estimation_rec.migrated_flag = FND_API.G_MISS_CHAR THEN
      l_ctr_estimation_rec.migrated_flag := NULL;
   END IF;

   -- validate_start_date(l_ctr_estimation_rec.start_date_active);
   validate_lookups('CSI_COUNTER_ESTIMATION_TYPE',l_ctr_estimation_rec.estimation_type);

   /* IF l_ctr_estimation_rec.estimation_avg_type not in ('DLY','MTH') THEN
   CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_EST_AVG_TYPE_INV','CTR_EST_AVG_TYPE',l_ctr_estimation_rec.estimation_avg_type);
   END IF; */

   IF l_ctr_estimation_rec.estimation_type = 'FIXED' then
      IF l_ctr_estimation_rec.fixed_value IS NULL THEN
         CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_EST_INV_FIXED');
      END IF;
   END IF;

   /* Table Handler call */
   CSI_CTR_ESTIMATE_METHODS_PKG.update_Row(
	p_ESTIMATION_ID                 => p_ctr_estimation_rec.estimation_id
 	,p_ESTIMATION_TYPE              => p_ctr_estimation_rec.estimation_type
 	,p_FIXED_VALUE                  => p_ctr_estimation_rec.fixed_value
 	,p_USAGE_MARKUP                 => p_ctr_estimation_rec.usage_markup
 	,p_DEFAULT_VALUE                => p_ctr_estimation_rec.default_value
 	,p_ESTIMATION_AVG_TYPE          => p_ctr_estimation_rec.estimation_avg_type
	,p_START_DATE_ACTIVE            => p_ctr_estimation_rec.start_date_active
	,p_END_DATE_ACTIVE              => p_ctr_estimation_rec.end_date_active
        ,p_LAST_UPDATE_DATE             => sysdate
        ,p_LAST_UPDATED_BY              => FND_GLOBAL.USER_ID
        ,p_CREATION_DATE                => p_ctr_estimation_rec.creation_date
        ,p_CREATED_BY                   => p_ctr_estimation_rec.created_by
        ,p_LAST_UPDATE_LOGIN            => FND_GLOBAL.USER_ID
        ,p_ATTRIBUTE1                   => p_ctr_estimation_rec.attribute1
        ,p_ATTRIBUTE2                   => p_ctr_estimation_rec.attribute2
        ,p_ATTRIBUTE3                   => p_ctr_estimation_rec.attribute3
        ,p_ATTRIBUTE4                   => p_ctr_estimation_rec.attribute4
        ,p_ATTRIBUTE5                   => p_ctr_estimation_rec.attribute5
        ,p_ATTRIBUTE6                   => p_ctr_estimation_rec.attribute6
        ,p_ATTRIBUTE7                   => p_ctr_estimation_rec.attribute7
        ,p_ATTRIBUTE8                   => p_ctr_estimation_rec.attribute8
        ,p_ATTRIBUTE9                   => p_ctr_estimation_rec.attribute9
        ,p_ATTRIBUTE10                  => p_ctr_estimation_rec.attribute10
        ,p_ATTRIBUTE11                  => p_ctr_estimation_rec.attribute11
        ,p_ATTRIBUTE12                  => p_ctr_estimation_rec.attribute12
        ,p_ATTRIBUTE13                  => p_ctr_estimation_rec.attribute13
        ,p_ATTRIBUTE14                  => p_ctr_estimation_rec.attribute14
        ,p_ATTRIBUTE15                  => p_ctr_estimation_rec.attribute15
        ,p_ATTRIBUTE_CATEGORY           => p_ctr_estimation_rec.attribute_category
	,p_OBJECT_VERSION_NUMBER        => p_ctr_estimation_rec.object_version_number + 1
 	,p_MIGRATED_FLAG                => p_ctr_estimation_rec.migrated_flag
        ,p_NAME	                        => p_ctr_estimation_rec.name
        ,p_DESCRIPTION                  => p_ctr_estimation_rec.description
        );

   IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
        ROLLBACK TO update_estimation_method_pvt;
        RETURN;
   END IF;

   /* End of API Body */

   IF FND_API.to_Boolean(nvl(p_commit,FND_API.G_FALSE)) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and IF count is  get message info.
   FND_MSG_PUB.Count_And_Get
      ( p_count  =>  x_msg_count,
        p_data   =>  x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO update_estimation_method_pvt;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_estimation_method_pvt;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_estimation_method_pvt;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg
            ( G_PKG_NAME,
              l_api_name
            );
      END IF;
      FND_MSG_PUB.Count_And_Get
         ( p_count  => x_msg_count,
           p_data   => x_msg_data
         );
END update_estimation_method;

PROCEDURE Instantiate_Counters
(
   p_api_version		IN	NUMBER
   ,p_init_msg_list		IN	VARCHAR2
   ,p_commit			IN	VARCHAR2
   ,x_return_status		    OUT NOCOPY	VARCHAR2
   ,x_msg_count		    OUT NOCOPY	NUMBER
   ,x_msg_data			    OUT NOCOPY	VARCHAR2
   ,p_counter_id_template        	IN	NUMBER
   ,p_source_object_code_instance IN      VARCHAR2
   ,p_source_object_id_instance   IN	NUMBER
   ,x_ctr_id_template	    OUT NOCOPY	NUMBER
   ,x_ctr_id_instance	    OUT NOCOPY	NUMBER
   ,p_maint_org_id                IN   NUMBER
   ,p_primary_failure_flag        IN   VARCHAR2
) IS


   l_api_name                      CONSTANT VARCHAR2(30)   := 'INSTANTIATE_COUNTERS';
   l_api_version                   CONSTANT NUMBER         := 1.0;
   l_msg_data                      VARCHAR2(2000);
   l_msg_index                     NUMBER;
   l_msg_count                     NUMBER;
   -- l_debug_level                   NUMBER;

   l_ctr_grp_rec                   csi_ctr_datastructures_pub.counter_groups_rec;
   l_counter_instance_rec          csi_ctr_datastructures_pub.counter_instance_rec;
   l_ctr_properties_rec            csi_ctr_datastructures_pub.ctr_properties_rec;
   l_ctr_rec                       csi_ctr_datastructures_pub.ctr_rec_type;
   l_ctr_prop_rec                  csi_ctr_datastructures_pub.ctr_prop_rec_type;
   l_counter_relationships_rec     csi_ctr_datastructures_pub.counter_relationships_rec;
   l_ctr_derived_filters_tbl       csi_ctr_datastructures_pub.ctr_derived_filters_tbl;
   l_counter_associations_rec      csi_ctr_datastructures_pub.counter_associations_rec;

   l_COMMS_NL_TRACKABLE_FLAG       VARCHAR2(1);
   l_source_object_cd              VARCHAR2(30);
   l_source_object_id_instance     NUMBER;
   l_ctr_grp_id                    NUMBER;
   l_new_ctr_grp_id                NUMBER;
   l_new_ctr_id                    NUMBER;
   l_new_ctr_prop_id               NUMBER;
   l_new_mapped_Ctr_id             NUMBER;
   l_new_ctr_formula_bvar_id       NUMBER;
   l_new_ctr_der_filter_id         NUMBER;
   l_new_der_ctr_prop_id           NUMBER;
   l_ctr_grp_id_instance           NUMBER;
   l_maint_organization_id         NUMBER;
   l_desc_flex                     csi_ctr_datastructures_pub.dff_rec_type;
   l_item                          VARCHAR2(40);
   l_config_root_id                NUMBER;
   l_mapped_item_id                NUMBER;
   l_org_id                        NUMBER;
   l_reading_type                  NUMBER;
   l_ctr_grp_rec                   csi_ctr_datastructures_pub.counter_groups_rec;
   p_relationship_query_rec        CSI_DATASTRUCTURES_PUB.RELATIONSHIP_QUERY_REC;
   x_relationship_tbl              CSI_DATASTRUCTURES_PUB.II_RELATIONSHIP_TBL;

   l_validation_level              NUMBER;
   l_counter_id                    NUMBER;
   l_instance_association_id       NUMBER;
   l_rel_type                      VARCHAR2(30) := 'CONFIGURATION';
   l_c_ind_txn                     BINARY_INTEGER := 0;
   l_c_ind_rdg                     BINARY_INTEGER := 0;
   l_c_ind_prop                    BINARY_INTEGER := 0;
   l_transaction_type_id           NUMBER;
   l_new_derive_counter_id         NUMBER;
   l_transaction_tbl               csi_datastructures_pub.transaction_tbl;
   l_counter_readings_tbl          csi_ctr_datastructures_pub.counter_readings_tbl;
   l_ctr_property_readings_tbl     csi_ctr_datastructures_pub.ctr_property_readings_tbl;

  CURSOR DFLT_PROP_RDG(p_counter_id IN NUMBER) IS
    SELECT ccp.counter_property_id,ccp.default_value,ccp.property_data_type, ccp.is_nullable
    FROM CSI_COUNTER_PROPERTIES_B ccp
    WHERE ccp.counter_id = p_counter_id AND NVL(ccp.is_nullable,'N') = 'N'
    AND   NVL(end_date_active,(SYSDATE+1)) > SYSDATE;

   CURSOR ctr_cur(p_counter_id NUMBER) IS
   SELECT counter_id,
          name,
          description,
          counter_type,
          initial_reading,
          initial_reading_date,
          tolerance_plus,
          tolerance_minus,
          uom_code,
          derive_function,
          derive_counter_id,
          derive_property_id,
          valid_flag,
          formula_incomplete_flag,
          formula_text,
          rollover_last_reading,
          rollover_first_reading,
          comments,
          usage_item_id,
          ctr_val_max_seq_no,
          start_date_active,
          end_date_active ,
          customer_view,
          direction,
          filter_reading_count,
          filter_type,
          filter_time_uom,
          estimation_id,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          attribute16,
          attribute17,
          attribute18,
          attribute19,
          attribute20,
          attribute21,
          attribute22,
          attribute23,
          attribute24,
          attribute25,
          attribute26,
          attribute27,
          attribute28,
          attribute29,
          attribute30,
          attribute_category,
          group_id,
          defaulted_group_id,
          reading_type,
          automatic_rollover,
          default_usage_rate,
          use_past_reading,
          used_in_scheduling,
          security_group_id,
          nvl(time_based_manual_entry, 'N') tm_based_manual_entry,
          eam_required_flag
   FROM   csi_counter_template_vl
   WHERE  counter_id = p_counter_id
   AND    NVL(end_date_active, SYSDATE+1) > SYSDATE;

   CURSOR fmla_ctr_cur(p_counter_id NUMBER) IS
   SELECT counter_id,
          name,
          description,
          counter_type,
          initial_reading,
          tolerance_plus,
          tolerance_minus,
          uom_code,
          derive_function,
          derive_counter_id,
          derive_property_id,
          valid_flag,
          formula_incomplete_flag,
          formula_text,
          rollover_last_reading,
          rollover_first_reading,
          comments,
          usage_item_id,
          ctr_val_max_seq_no,
          start_date_active,
          end_date_active,
          -- created_from_counter_tmpl_id,
          customer_view,
          filter_reading_count,
          filter_type,
          filter_time_uom,
          estimation_id,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          attribute16,
          attribute17,
          attribute18,
          attribute19,
          attribute20,
          attribute21,
          attribute22,
          attribute23,
          attribute24,
          attribute25,
          attribute26,
          attribute27,
          attribute28,
          attribute29,
          attribute30,
          attribute_category,
          eam_required_flag
   FROM   csi_counters_vl
   WHERE  counter_id = p_counter_id
   AND    counter_type = 'FORMULA';

   CURSOR ctr_prop_cur(p_counter_id NUMBER) IS
   SELECT counter_property_id,
          name,
          description,
          property_data_type,
          is_nullable,
          default_value,
          minimum_value,
          maximum_value,
          uom_code,
          start_date_active,
          end_date_active ,
          property_lov_type,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          attribute_category,
          security_group_id
   FROM   csi_ctr_prop_template_vl
   WHERE  counter_id = p_counter_id;

   CURSOR ctr_formula_bvars_cur(p_counter_id NUMBER) IS
   SELECT relationship_id,
          ctr_association_id,
          relationship_type_code,
          source_counter_id,
          object_counter_id,
          bind_variable_name,
          factor,
          active_start_date,
          active_end_date,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          attribute_category,
          security_group_id
   FROM   csi_counter_relationships
   -- WHERE  source_counter_id = p_counter_id;
   WHERE  object_counter_id = p_counter_id;

   CURSOR ctr_der_filter_cur(p_counter_id NUMBER) IS
   SELECT counter_id,
          seq_no,
          left_parent,
          counter_property_id,
          relational_operator,
          right_value,
          right_parent,
          logical_operator,
          start_date_active,
          end_date_active,
          security_group_id,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          attribute_category
   FROM   csi_counter_derived_filters
   WHERE  counter_id = p_counter_id;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  instantiate_ctr_pvt;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   --
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line(
            'instantiate_ctr_pvt'||'-'||
            p_api_version           ||'-'||
            nvl(p_commit,FND_API.G_FALSE) ||'-'||
            nvl(p_init_msg_list,FND_API.G_FALSE)||'-'||
            nvl(l_validation_level,FND_API.G_VALID_LEVEL_FULL) );
   END IF;

   l_source_object_cd := p_source_object_code_instance;
   l_source_object_id_instance := p_source_object_id_instance;

   l_counter_id := p_counter_id_template;
   csi_ctr_gen_utility_pvt.put_line('Template counter id = '||to_char(l_counter_id));

   FOR ctr_cur_rec IN ctr_cur(l_counter_id) LOOP
      IF ctr_cur_rec.group_id IS NOT NULL THEN
         l_counter_instance_rec.group_id := ctr_cur_rec.defaulted_group_id;
      END IF;
      l_counter_instance_rec.name := ctr_cur_rec.name;
      l_counter_instance_rec.description := ctr_cur_rec.description;
      l_counter_instance_rec.counter_type := ctr_cur_rec.counter_type;
      l_counter_instance_rec.initial_reading := ctr_cur_rec.initial_reading;
      l_counter_instance_rec.initial_reading_date := ctr_cur_rec.initial_reading_date;
      l_counter_instance_rec.created_from_counter_tmpl_id := ctr_cur_rec.counter_id;
      l_counter_instance_rec.tolerance_plus := ctr_cur_rec.tolerance_plus;
      l_counter_instance_rec.tolerance_minus := ctr_cur_rec.tolerance_minus;
      l_counter_instance_rec.uom_code := ctr_cur_rec.uom_code;

      IF ctr_cur_rec.derive_counter_id IS NOT NULL THEN
         BEGIN

            -- Bug 9068223 Fixing in both R12 and 12.1 code
            /*SELECT max(counter_id)
            INTO   l_new_derive_counter_id
            FROM   csi_counters_b
            WHERE  created_from_counter_tmpl_id = ctr_cur_rec.derive_counter_id;*/

            -- To fetch the maximum counter id
           SELECT counter_id INTO l_new_derive_counter_id FROM
           (SELECT counter_id
           FROM   csi_counters_b
           WHERE  created_from_counter_tmpl_id = ctr_cur_rec.derive_counter_id
           ORDER BY counter_id DESC)
           WHERE ROWNUM = 1;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               csi_ctr_gen_utility_pvt.put_line( ' New counter id not found for deriver counte id '||to_char(ctr_cur_rec.derive_counter_id));
               NULL;
         END;

         l_counter_instance_rec.derive_counter_id := l_new_derive_counter_id;
      ELSE
         l_counter_instance_rec.derive_counter_id := ctr_cur_rec.derive_counter_id;
      END IF;

      l_counter_instance_rec.derive_function := ctr_cur_rec.derive_function;
      l_counter_instance_rec.derive_property_id := ctr_cur_rec.derive_property_id;
      l_counter_instance_rec.valid_flag := 'Y';
      l_counter_instance_rec.formula_text := ctr_cur_rec.formula_text;
      l_counter_instance_rec.rollover_last_reading := ctr_cur_rec.rollover_last_reading;
      l_counter_instance_rec.rollover_first_reading := ctr_cur_rec.rollover_first_reading;
      l_counter_instance_rec.usage_item_id := ctr_cur_rec.usage_item_id;
      l_counter_instance_rec.start_date_active := ctr_cur_rec.start_date_active;
      l_counter_instance_rec.end_date_active := ctr_cur_rec.end_date_active;
      l_counter_instance_rec.security_group_id := ctr_cur_rec.security_group_id;
      l_counter_instance_rec.object_version_number := 1;
      l_counter_instance_rec.last_update_date := sysdate;
      l_counter_instance_rec.last_Updated_by  := fnd_global.user_id;
      l_counter_instance_rec.creation_date := sysdate;
      l_counter_instance_rec.created_by := FND_GLOBAL.user_id;
      l_counter_instance_rec.last_update_login := FND_GLOBAL.user_id;
      l_counter_instance_rec.attribute_category := ctr_cur_rec.attribute_category;
      l_counter_instance_rec.attribute1 := ctr_cur_rec.attribute1;
      l_counter_instance_rec.attribute2 := ctr_cur_rec.attribute2;
      l_counter_instance_rec.attribute3 := ctr_cur_rec.attribute3;
      l_counter_instance_rec.attribute4 := ctr_cur_rec.attribute4;
      l_counter_instance_rec.attribute5 := ctr_cur_rec.attribute5;
      l_counter_instance_rec.attribute6 := ctr_cur_rec.attribute6;
      l_counter_instance_rec.attribute7 := ctr_cur_rec.attribute7;
      l_counter_instance_rec.attribute8 := ctr_cur_rec.attribute8;
      l_counter_instance_rec.attribute9 := ctr_cur_rec.attribute9;
      l_counter_instance_rec.attribute10 := ctr_cur_rec.attribute10;
      l_counter_instance_rec.attribute11 := ctr_cur_rec.attribute11;
      l_counter_instance_rec.attribute12 := ctr_cur_rec.attribute12;
      l_counter_instance_rec.attribute13 := ctr_cur_rec.attribute13;
      l_counter_instance_rec.attribute14 := ctr_cur_rec.attribute14;
      l_counter_instance_rec.attribute15 := ctr_cur_rec.attribute15;
      l_counter_instance_rec.attribute16 := ctr_cur_rec.attribute16;
      l_counter_instance_rec.attribute17 := ctr_cur_rec.attribute17;
      l_counter_instance_rec.attribute18 := ctr_cur_rec.attribute18;
      l_counter_instance_rec.attribute19 := ctr_cur_rec.attribute19;
      l_counter_instance_rec.attribute20 := ctr_cur_rec.attribute20;
      l_counter_instance_rec.attribute21 := ctr_cur_rec.attribute21;
      l_counter_instance_rec.attribute22 := ctr_cur_rec.attribute22;
      l_counter_instance_rec.attribute23 := ctr_cur_rec.attribute23;
      l_counter_instance_rec.attribute24 := ctr_cur_rec.attribute24;
      l_counter_instance_rec.attribute25 := ctr_cur_rec.attribute25;
      l_counter_instance_rec.attribute26 := ctr_cur_rec.attribute26;
      l_counter_instance_rec.attribute27 := ctr_cur_rec.attribute27;
      l_counter_instance_rec.attribute28 := ctr_cur_rec.attribute28;
      l_counter_instance_rec.attribute29 := ctr_cur_rec.attribute29;
      l_counter_instance_rec.attribute30 := ctr_cur_rec.attribute30;
      l_counter_instance_rec.customer_view := ctr_cur_rec.customer_view;
      l_counter_instance_rec.direction := ctr_cur_rec.direction;
      l_counter_instance_rec.filter_type := ctr_cur_rec.filter_type;
      l_counter_instance_rec.filter_reading_count := ctr_cur_rec.filter_reading_count;
      l_counter_instance_rec.filter_time_uom := ctr_cur_rec.filter_time_uom;
      l_counter_instance_rec.estimation_id := ctr_cur_rec.estimation_id;
      l_counter_instance_rec.reading_type := ctr_cur_rec.reading_type;
      l_counter_instance_rec.automatic_rollover := ctr_cur_rec.automatic_rollover;
      l_counter_instance_rec.default_usage_rate := ctr_cur_rec.default_usage_rate;
      l_counter_instance_rec.use_past_reading   := ctr_cur_rec.use_past_reading;
      l_counter_instance_rec.used_in_scheduling := ctr_cur_rec.used_in_scheduling;
      l_counter_instance_rec.defaulted_group_id := ctr_cur_rec.defaulted_group_id;
      l_new_ctr_grp_id := ctr_cur_rec.defaulted_group_id;
      l_counter_instance_rec.comments := ctr_cur_rec.comments;
      l_counter_instance_rec.time_based_manual_entry := ctr_cur_rec.tm_based_manual_entry;
      l_counter_instance_rec.eam_required_flag := ctr_cur_rec.eam_required_flag;

csi_ctr_gen_utility_pvt.put_line('Calling csi_counter_pvt.create_counter....');

      CSI_COUNTER_PVT.CREATE_COUNTER
          (
            p_api_version           => p_api_version,
            p_init_msg_list         => p_init_msg_list,
            p_commit                => p_commit,
            p_validation_level      => l_validation_level,
            p_counter_instance_rec  => l_counter_instance_rec,
            x_return_status         => x_return_status,
            x_msg_count             => x_msg_count,
            x_msg_data              => x_msg_data,
            x_ctr_id                => l_new_ctr_id
          );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;

          WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                            FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_PVT.CREATE_COUNTER');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
          END LOOP;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

      -- x_ctr_id_instance := l_counter_instance_rec.group_id;
      -- Create Counter Associations
      l_counter_associations_rec.source_object_code := l_source_object_cd;
      l_counter_associations_rec.source_object_id   := l_source_object_id_instance;
      l_counter_associations_rec.counter_id         := l_new_ctr_id;
      l_counter_associations_rec.start_date_active  := sysdate;
      l_counter_associations_rec.maint_organization_id := p_maint_org_id;
      l_counter_associations_rec.primary_failure_flag := p_primary_failure_flag;

      csi_ctr_gen_utility_pvt.put_line( ' Maint organization id = '||to_char(p_maint_org_id));
csi_ctr_gen_utility_pvt.put_line('Calling csi_counter_pvt.create_ctr_associations....');
      CSI_COUNTER_PVT.CREATE_CTR_ASSOCIATIONS
         (
           p_api_version            => p_api_version
           ,p_commit                => p_commit
           ,p_init_msg_list         => p_init_msg_list
           ,p_validation_level      => l_validation_level
           ,p_counter_associations_rec  => l_counter_associations_rec
           ,x_return_status         => x_return_status
           ,x_msg_count             => x_msg_count
           ,x_msg_data              => x_msg_data
           ,x_instance_association_id  => l_instance_association_id
         );

      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;

          WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                            FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_PVT.CREATE_CTR_ASSOCIATIONS');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
          END LOOP;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       -- Insert initial reading by calling counter reading api.
       IF ctr_cur_rec.counter_type = 'REGULAR' AND
          (ctr_cur_rec.initial_reading is not null AND
          ctr_cur_rec.initial_reading <> FND_API.G_MISS_NUM) AND
          nvl(l_counter_relationships_rec.RELATIONSHIP_TYPE_CODE,'X') <>
          l_rel_type THEN

csi_ctr_gen_utility_pvt.put_line('Inside the call reading api...');

          --create transaction record
          l_transaction_tbl(l_c_ind_txn)                    := NULL;
          l_transaction_tbl(l_c_ind_txn).TRANSACTION_ID     := NULL;
          l_transaction_tbl(l_c_ind_txn).TRANSACTION_DATE   := sysdate;
          l_transaction_tbl(l_c_ind_txn).SOURCE_TRANSACTION_DATE  := sysdate;

          if l_source_object_cd = 'CP' then
             l_transaction_type_id := 80;
          elsif l_source_object_cd = 'CONTRACT_LINE' then
             l_transaction_type_id := 81;
          end if;

          if l_transaction_type_id is null then
             l_transaction_type_id := 80;
          end if;

          l_transaction_tbl(l_c_ind_txn).TRANSACTION_TYPE_ID   := l_transaction_type_id;
          l_transaction_tbl(l_c_ind_txn).TXN_SUB_TYPE_ID       := NULL;
          l_transaction_tbl(l_c_ind_txn).SOURCE_GROUP_REF_ID   := NULL;
          l_transaction_tbl(l_c_ind_txn).SOURCE_GROUP_REF      := NULL;
          l_transaction_tbl(l_c_ind_txn).SOURCE_HEADER_REF_ID  := l_source_object_id_instance;

          -- create counter readings table
          l_counter_readings_tbl(l_c_ind_rdg).COUNTER_VALUE_ID :=  NULL;
          l_counter_readings_tbl(l_c_ind_rdg).COUNTER_ID       :=  l_new_ctr_id;
          l_counter_readings_tbl(l_c_ind_rdg).VALUE_TIMESTAMP  :=  ctr_cur_rec.initial_reading_date;
          l_counter_readings_tbl(l_c_ind_rdg).COUNTER_READING  :=  ctr_cur_rec.initial_reading;
          l_counter_readings_tbl(l_c_ind_rdg).initial_reading_flag := 'Y';
          l_counter_readings_tbl(l_c_ind_rdg).DISABLED_FLAG    :=  'N';
          l_counter_readings_tbl(l_c_ind_rdg).COMMENTS         :=  'Initial Reading';
          l_counter_readings_tbl(l_c_ind_rdg).PARENT_TBL_INDEX :=  l_c_ind_txn;

          FOR dflt_rec IN DFLT_PROP_RDG(l_new_ctr_id)
          LOOP
             l_ctr_property_readings_tbl(l_c_ind_prop).COUNTER_PROP_VALUE_ID := NULL;
             l_ctr_property_readings_tbl(l_c_ind_prop).COUNTER_PROPERTY_ID   := dflt_rec.counter_property_id;
             IF dflt_rec.default_value IS NOT NULL THEN
                l_ctr_property_readings_tbl(l_c_ind_prop).PROPERTY_VALUE := dflt_rec.default_value;
             ELSE
                IF dflt_rec.property_data_type = 'CHAR' THEN
                   l_ctr_property_readings_tbl(l_c_ind_prop).PROPERTY_VALUE := 'Initial Reading';
                ELSIF dflt_rec.property_data_type = 'DATE' THEN
                   l_ctr_property_readings_tbl(l_c_ind_prop).PROPERTY_VALUE := sysdate;
                ELSE
                   l_ctr_property_readings_tbl(l_c_ind_prop).PROPERTY_VALUE := '1';
                END IF;
             END IF;

             l_ctr_property_readings_tbl(l_c_ind_prop).VALUE_TIMESTAMP := sysdate;
             l_ctr_property_readings_tbl(l_c_ind_prop).PARENT_TBL_INDEX  := l_c_ind_rdg;
             l_c_ind_prop := l_c_ind_prop + 1;
          END LOOP;

csi_ctr_gen_utility_pvt.put_line('Calling the capture counter reading...');
          csi_counter_readings_pub.capture_counter_reading(
             p_api_version      => 1.0,
             p_commit           => p_commit,
             p_init_msg_list    => p_init_msg_list,
             p_validation_level => l_validation_level,
             p_txn_tbl          => l_transaction_tbl,
             p_ctr_rdg_tbl      => l_counter_readings_tbl,
             p_ctr_prop_rdg_tbl => l_ctr_property_readings_tbl,
             x_return_status    => x_return_status,
             x_msg_count        => x_msg_count,
             x_msg_data         => x_msg_data
             );

          IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
             l_msg_index := 1;
             l_msg_count := x_msg_count;

             WHILE l_msg_count > 0 LOOP
                x_msg_data := FND_MSG_PUB.GET
                        (l_msg_index,
                        FND_API.G_FALSE );
                csi_ctr_gen_utility_pvt.put_line( ' Error from Instantiate-Capture Readings');
                csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                l_msg_index := l_msg_index + 1;
                l_msg_count := l_msg_count - 1;
             END LOOP;
             RAISE FND_API.G_EXC_ERROR;
          END IF;
      END IF;

      -- INstantiate all the properties for that counter.
      FOR ctr_prop_cur_rec IN ctr_prop_cur(ctr_cur_rec.counter_id) LOOP

         l_ctr_properties_rec.counter_id := l_new_ctr_id;
         l_ctr_properties_rec.name := ctr_prop_cur_rec.name;
         l_ctr_properties_rec.description := ctr_prop_cur_rec.description;
         l_ctr_properties_rec.property_data_type := ctr_prop_cur_rec.property_data_type;
         l_ctr_properties_rec.property_lov_type  :=  ctr_prop_cur_rec.property_lov_type;
         l_ctr_properties_rec.created_from_ctr_prop_tmpl_id := ctr_prop_cur_rec.counter_property_id;
         l_ctr_properties_rec.is_nullable := ctr_prop_cur_rec.is_nullable;
         l_ctr_properties_rec.default_value := ctr_prop_cur_rec.default_value;
         l_ctr_properties_rec.minimum_value := ctr_prop_cur_rec.minimum_value;
         l_ctr_properties_rec.maximum_value := ctr_prop_cur_rec.maximum_value;
         l_ctr_properties_rec.uom_code := ctr_prop_cur_rec.uom_code;
         l_ctr_properties_rec.start_date_active := ctr_prop_cur_rec.start_date_active;
         l_ctr_properties_rec.end_date_active := ctr_prop_cur_rec.end_date_active;
         l_ctr_properties_rec.security_group_id := ctr_prop_cur_rec.security_group_id;
         l_ctr_properties_rec.object_version_number := 1;
         l_ctr_properties_rec.last_update_date := sysdate;
         l_ctr_properties_rec.last_Updated_by  := fnd_global.user_id;
         l_ctr_properties_rec.creation_date := sysdate;
         l_ctr_properties_rec.created_by := FND_GLOBAL.user_id;
         l_ctr_properties_rec.last_update_login := FND_GLOBAL.user_id;
         l_ctr_properties_rec.attribute_category := ctr_prop_cur_rec.attribute_category;
         l_ctr_properties_rec.attribute1 := ctr_prop_cur_rec.attribute1;
         l_ctr_properties_rec.attribute2 := ctr_prop_cur_rec.attribute2;
         l_ctr_properties_rec.attribute3 := ctr_prop_cur_rec.attribute3;
         l_ctr_properties_rec.attribute4 := ctr_prop_cur_rec.attribute4;
         l_ctr_properties_rec.attribute5 := ctr_prop_cur_rec.attribute5;
         l_ctr_properties_rec.attribute6 := ctr_prop_cur_rec.attribute6;
         l_ctr_properties_rec.attribute7 := ctr_prop_cur_rec.attribute7;
         l_ctr_properties_rec.attribute8 := ctr_prop_cur_rec.attribute8;
         l_ctr_properties_rec.attribute9 := ctr_prop_cur_rec.attribute9;
         l_ctr_properties_rec.attribute10 := ctr_prop_cur_rec.attribute10;
         l_ctr_properties_rec.attribute11 := ctr_prop_cur_rec.attribute11;
         l_ctr_properties_rec.attribute12 := ctr_prop_cur_rec.attribute12;
         l_ctr_properties_rec.attribute13 := ctr_prop_cur_rec.attribute13;
         l_ctr_properties_rec.attribute14 := ctr_prop_cur_rec.attribute14;
         l_ctr_properties_rec.attribute15 := ctr_prop_cur_rec.attribute15;


         CSI_Counter_PVT.Create_Ctr_Property
            (
             p_api_version       => p_api_version
             ,p_commit           => p_commit
             ,p_init_msg_list    => p_init_msg_list
             ,p_validation_level => l_validation_level
             ,p_ctr_properties_rec => l_ctr_properties_rec
             ,x_return_status     => x_return_status
             ,x_msg_count         => x_msg_count
             ,x_msg_data          => x_msg_data
             ,x_ctr_property_id   => l_new_ctr_prop_id
          );

      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;

          WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                            FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_Counter_PVT.Create_Ctr_Property');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
          END LOOP;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

      END LOOP;

      -- All the counter properties belonging to this counter have been
      -- instantiated.

   END LOOP;
 csi_ctr_gen_utility_pvt.put_line('After the end loop ');
 csi_ctr_gen_utility_pvt.put_line('New counter id = '||to_char(l_new_ctr_id));

   FOR fmla_ctr_cur_rec IN fmla_ctr_cur(l_new_ctr_id) LOOP
      csi_ctr_gen_utility_pvt.put_line('Formula Counter Id = '||to_char(fmla_ctr_cur_rec.counter_id));
      FOR ctr_der_filter_cur_rec IN ctr_der_filter_cur(fmla_ctr_cur_rec.counter_id)
      LOOP
 csi_ctr_gen_utility_pvt.put_line('Inside the ctr_der_filter_cur_rec ');

         SELECT counter_property_id
         INTO   l_new_der_ctr_prop_id
         FROM   csi_counter_template_vl ctr,
                csi_ctr_prop_template_vl ctrprop
         WHERE  ctrprop.counter_property_id = ctr_der_filter_cur_rec.counter_property_id
         AND    ctrprop.counter_id = l_new_ctr_id;

/*         l_ctr_derived_filters_tbl.attribute1 := ctr_der_filter_cur_rec.attribute1;
         l_ctr_derived_filters_tbl.attribute2 := ctr_der_filter_cur_rec.attribute2;
         l_ctr_derived_filters_tbl.attribute3 := ctr_der_filter_cur_rec.attribute3;
         l_ctr_derived_filters_tbl.attribute4 := ctr_der_filter_cur_rec.attribute4;
         l_ctr_derived_filters_tbl.attribute5 := ctr_der_filter_cur_rec.attribute5;
         l_ctr_derived_filters_tbl.attribute6 := ctr_der_filter_cur_rec.attribute6;
         l_ctr_derived_filters_tbl.attribute7 := ctr_der_filter_cur_rec.attribute7;
         l_ctr_derived_filters_tbl.attribute8 := ctr_der_filter_cur_rec.attribute8;
         l_ctr_derived_filters_tbl.attribute9 := ctr_der_filter_cur_rec.attribute9;
         l_ctr_derived_filters_tbl.attribute10 := ctr_der_filter_cur_rec.attribute10;
         l_ctr_derived_filters_tbl.attribute11 := ctr_der_filter_cur_rec.attribute11;
         l_ctr_derived_filters_tbl.attribute12 := ctr_der_filter_cur_rec.attribute12;
         l_ctr_derived_filters_tbl.attribute13 := ctr_der_filter_cur_rec.attribute13;
         l_ctr_derived_filters_tbl.attribute14 := ctr_der_filter_cur_rec.attribute14;
         l_ctr_derived_filters_tbl.attribute15 := ctr_der_filter_cur_rec.attribute15;
         l_ctr_derived_filters_tbl.attribute_category := ctr_der_filter_cur_rec.attribute_category;
         l_ctr_derived_filters_tbl.security_group_id := ctr_der_filter_cur_rec.security_group_id;
         l_ctr_derived_filters_tbl.counter_id := ctr_der_filter_cur_rec.counter_id;
         l_ctr_derived_filters_tbl.left_parent := ctr_der_filter_cur_rec.left_parent;
         l_ctr_derived_filters_tbl.counter_property_id := l_new_der_ctr_prop_id;
         l_ctr_derived_filters_tbl.relational_operator := ctr_der_filter_cur_rec.relational_operator;
         l_ctr_derived_filters_tbl.right_value := ctr_der_filter_cur_rec.right_value;
         l_ctr_derived_filters_tbl.right_parent := ctr_der_filter_cur_rec.right_parent;
         l_ctr_derived_filters_tbl.logical_operator := ctr_der_filter_cur_rec.logical_operator;
         l_ctr_derived_filters_tbl.start_date_active := ctr_der_filter_cur_rec.start_date_active;
         l_ctr_derived_filters_tbl.end_date_active := ctr_der_filter_cur_rec.end_date_active;
         l_ctr_derived_filters_tbl.object_version_number := 1;
         l_ctr_derived_filters_tbl.last_update_date := sysdate;
         l_ctr_derived_filters_tbl.last_Updated_by  := fnd_global.user_id;
         l_ctr_derived_filters_tbl.creation_date := sysdate;
         l_ctr_derived_filters_tbl.created_by := FND_GLOBAL.user_id;
         l_ctr_derived_filters_tbl.last_update_login := FND_GLOBAL.user_id;
*/
         CSI_COUNTER_TEMPLATE_PVT.CREATE_DERIVED_FILTERS
            (
             p_api_version           => p_api_version
             ,p_commit               => p_commit
             ,p_init_msg_list        => p_init_msg_list
             ,p_validation_level     => l_validation_level
             ,p_ctr_derived_filters_tbl => l_ctr_derived_filters_tbl
             ,x_return_status         => x_return_status
             ,x_msg_count             => x_msg_count
             ,x_msg_data              => x_msg_data
            );

      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;

          WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                            FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_TEMPLATE_PVT.CREATE_DERIVED_FILTERS');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
          END LOOP;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

      END LOOP;

      -- FOR ctr_formula_bvars_cur_rec IN ctr_formula_bvars_cur(l_new_ctr_id)
      csi_ctr_gen_utility_pvt.put_line( 'Passed counter_id = '||to_char(l_counter_id));
      csi_ctr_gen_utility_pvt.put_line( 'Passed new grp id = '||to_char(l_new_ctr_grp_id));
      FOR ctr_formula_bvars_cur_rec IN ctr_formula_bvars_cur(l_counter_id)
      LOOP
         -- Bug 9068223 Fixing in both R12 and 12.1 code
         /*SELECT max(counter_id)
         INTO   l_new_mapped_ctr_id
         FROM   csi_counters_b
         WHERE  created_from_counter_tmpl_id = ctr_formula_bvars_cur_rec.source_counter_id;*/

         -- To fetch the maximum counter id
         SELECT counter_id INTO l_new_mapped_ctr_id FROM
         (SELECT counter_id
         FROM   csi_counters_b
         WHERE  created_from_counter_tmpl_id = ctr_formula_bvars_cur_rec.source_counter_id
         ORDER BY counter_id DESC)
         WHERE ROWNUM = 1;

         -- AND    defaulted_group_id = l_new_ctr_grp_id;

         IF ctr_formula_bvars_cur_rec.source_counter_id IS NOT NULL THEN
            -- THIS IS a configuration counter. I need to see if I can
            -- find out the CP to which the mapped_counter is attached.
            -- It may not be instantiated yet, so its possible that its
            -- not possible to get the mapped cp id. If i can't get it,
            -- set the formula_incompl_flag to 'N' for that counter.

            -- You cannot have configuration counters fro service items
            -- only for serviceable products. So, I can safely look at
            -- cs_customer_products and assume this is a product.

            FND_PROFILE.Get('ORG_ID',l_org_id);

            l_config_root_id := csi_generic_grp.config_root_node(p_source_object_id_instance,'COMPONENT-OF');

            BEGIN
               p_relationship_query_rec.RELATIONSHIP_ID := NULL;
               p_relationship_query_rec.RELATIONSHIP_TYPE_CODE := 'COMPONENT-OF';
               p_relationship_query_rec.OBJECT_ID := l_config_root_id;
               p_relationship_query_rec.SUBJECT_ID := NULL;

               -- Now call the stored program
               csi_ii_relationships_pub.get_relationships
                  (1.0,
                   '',
                   '',
                   NULL,
                   p_relationship_query_rec,
                   NULL,
                   NULL,
                   '',
                   x_relationship_tbl,
                   x_return_status,
                   x_msg_count,
                   x_msg_data);


               -- Output the results
               IF x_relationship_tbl IS NOT NULL THEN
                  IF x_relationship_tbl.count > 0 THEN
                     FOR i IN x_relationship_tbl.first..x_relationship_tbl.last LOOP
                        IF x_relationship_tbl.exists(i) THEN
                           --null; -- type of data not known
                           SELECT inventory_item_id
                           INTO   l_mapped_item_id
                           FROM   csi_item_instances
                           WHERE  instance_id = x_relationship_tbl(i).subject_id
                           AND    inv_master_organization_id = l_org_id;

                           --IF l_mapped_item_id = ctr_formula_bvars_cur_rec.mapped_inv_item_id then
                            --  exit;
                           --END IF;
                        END IF;
                     END LOOP;
                  END IF;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  -- l_mapped_item_id := ctr_formula_bvars_cur_rec.mapped_inv_item_id;
                  NULL;
            END;

         END IF;

         -- l_reading_type   := ctr_formula_bvars_cur_rec.reading_type;
         l_counter_relationships_rec.attribute1 := ctr_formula_bvars_cur_rec.attribute1;
         l_counter_relationships_rec.attribute2 := ctr_formula_bvars_cur_rec.attribute2;
         l_counter_relationships_rec.attribute3 := ctr_formula_bvars_cur_rec.attribute3;
         l_counter_relationships_rec.attribute4 := ctr_formula_bvars_cur_rec.attribute4;
         l_counter_relationships_rec.attribute5 := ctr_formula_bvars_cur_rec.attribute5;
         l_counter_relationships_rec.attribute6 := ctr_formula_bvars_cur_rec.attribute6;
         l_counter_relationships_rec.attribute7 := ctr_formula_bvars_cur_rec.attribute7;
         l_counter_relationships_rec.attribute8 := ctr_formula_bvars_cur_rec.attribute8;
         l_counter_relationships_rec.attribute9 := ctr_formula_bvars_cur_rec.attribute9;
         l_counter_relationships_rec.attribute10 := ctr_formula_bvars_cur_rec.attribute10;
         l_counter_relationships_rec.attribute11 := ctr_formula_bvars_cur_rec.attribute11;
         l_counter_relationships_rec.attribute12 := ctr_formula_bvars_cur_rec.attribute12;
         l_counter_relationships_rec.attribute13 := ctr_formula_bvars_cur_rec.attribute13;
         l_counter_relationships_rec.attribute14 := ctr_formula_bvars_cur_rec.attribute14;
         l_counter_relationships_rec.attribute15 := ctr_formula_bvars_cur_rec.attribute15;
         l_counter_relationships_rec.attribute_category := ctr_formula_bvars_cur_rec.attribute_category;
         l_counter_relationships_rec.security_group_id := ctr_formula_bvars_cur_rec.security_group_id;
         l_counter_relationships_rec.object_version_number := 1;
         l_counter_relationships_rec.last_update_date := sysdate;
         l_counter_relationships_rec.last_Updated_by  := fnd_global.user_id;
         l_counter_relationships_rec.creation_date := sysdate;
         l_counter_relationships_rec.created_by := FND_GLOBAL.user_id;
         l_counter_relationships_rec.last_update_login := FND_GLOBAL.user_id;
         l_counter_relationships_rec.ctr_association_id := ctr_formula_bvars_cur_rec.ctr_association_id;
         l_counter_relationships_rec.relationship_type_code := ctr_formula_bvars_cur_rec.relationship_type_code;
         -- l_counter_relationships_rec.source_counter_id := ctr_formula_bvars_cur_rec.source_counter_id;
         --l_counter_relationships_rec.object_counter_id := ctr_formula_bvars_cur_rec.object_counter_id;
         l_counter_relationships_rec.source_counter_id := l_new_mapped_ctr_id;
         l_counter_relationships_rec.object_counter_id := l_new_ctr_id;
         l_counter_relationships_rec.bind_variable_name := ctr_formula_bvars_cur_rec.bind_variable_name;
         l_counter_relationships_rec.factor := ctr_formula_bvars_cur_rec.factor;
         l_counter_relationships_rec.active_start_date := ctr_formula_bvars_cur_rec.active_start_date;
         l_counter_relationships_rec.active_end_date := ctr_formula_bvars_cur_rec.active_end_date;

         csi_counter_template_pvt.create_counter_relationship
            (
            p_api_version         => p_api_version
            ,p_commit             => fnd_api.g_false
            ,p_init_msg_list      => p_init_msg_list
            ,p_validation_level   => l_validation_level
            ,p_counter_relationships_rec => l_counter_relationships_rec
            ,x_return_status      => x_return_status
            ,x_msg_count          => x_msg_count
            ,x_msg_data           => x_msg_data
            );

       END LOOP;
   END LOOP;

   x_ctr_id_template := p_counter_id_template;
   -- x_ctr_id_instance := l_new_ctr_id;

   IF FND_API.to_Boolean(nvl(p_commit,FND_API.G_FALSE)) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and IF count is  get message info.
   FND_MSG_PUB.Count_And_Get
      ( p_count  =>  x_msg_count,
        p_data   =>  x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO instantiate_ctr_pvt;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO instantiate_ctr_pvt;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO instantiate_ctr_pvt;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg
            ( G_PKG_NAME,
              l_api_name
            );
      END IF;
      FND_MSG_PUB.Count_And_Get
         ( p_count  => x_msg_count,
           p_data   => x_msg_data
         );
END Instantiate_Counters;

PROCEDURE Instantiate_Grp_Counters
(
   p_api_version		IN	NUMBER
   ,p_init_msg_list		IN	VARCHAR2
   ,p_commit			IN	VARCHAR2
   ,x_return_status		OUT NOCOPY VARCHAR2
   ,x_msg_count		        OUT NOCOPY NUMBER
   ,x_msg_data		        OUT NOCOPY VARCHAR2
   ,p_group_id_template        	IN	NUMBER
   ,p_source_object_code_instance IN    VARCHAR2
   ,p_source_object_id_instance   IN	NUMBER
   ,x_ctr_grp_id_instance	  OUT NOCOPY	NUMBER
   ,p_maint_org_id                IN    NUMBER
   ,p_primary_failure_flag        IN    VARCHAR2
) IS

   l_api_name                      CONSTANT VARCHAR2(30)   := 'INSTANTIATE_GRP_COUNTERS';
   l_api_version                   CONSTANT NUMBER         := 1.0;
   l_msg_data                      VARCHAR2(2000);
   l_msg_index                     NUMBER;
   l_msg_count                     NUMBER;
   -- l_debug_level                   NUMBER;

   l_ctr_grp_rec                   csi_ctr_datastructures_pub.counter_groups_rec;
   l_counter_instance_rec          csi_ctr_datastructures_pub.counter_instance_rec;
   l_ctr_properties_rec            csi_ctr_datastructures_pub.ctr_properties_rec;
   l_ctr_rec                       csi_ctr_datastructures_pub.ctr_rec_type;
   l_ctr_prop_rec                  csi_ctr_datastructures_pub.ctr_prop_rec_type;
   l_counter_relationships_rec     csi_ctr_datastructures_pub.counter_relationships_rec;
   l_ctr_derived_filters_tbl       csi_ctr_datastructures_pub.ctr_derived_filters_tbl;
   l_counter_associations_rec      csi_ctr_datastructures_pub.counter_associations_rec;

   l_COMMS_NL_TRACKABLE_FLAG       VARCHAR2(1);
   l_source_object_cd              VARCHAR2(30);
   l_source_object_id_instance     NUMBER;
   l_ctr_grp_id                    NUMBER;
   l_new_ctr_grp_id                NUMBER;
   l_new_ctr_id                    NUMBER;
   l_new_ctr_prop_id               NUMBER;
   l_new_mapped_Ctr_id             NUMBER;
   l_new_ctr_formula_bvar_id       NUMBER;
   l_new_ctr_der_filter_id         NUMBER;
   l_new_der_ctr_prop_id           NUMBER;
   l_counter_group_id              NUMBER;
   l_ctr_grp_id_instance           NUMBER;
   l_maint_organization_id         NUMBER;
   l_desc_flex                     csi_ctr_datastructures_pub.dff_rec_type;
   l_item                          VARCHAR2(40);
   l_config_root_id                NUMBER;
   l_mapped_item_id                NUMBER;
   l_org_id                        NUMBER;
   l_reading_type                  NUMBER;
   p_relationship_query_rec        CSI_DATASTRUCTURES_PUB.RELATIONSHIP_QUERY_REC;
   x_relationship_tbl              CSI_DATASTRUCTURES_PUB.II_RELATIONSHIP_TBL;

   l_validation_level              NUMBER;
   l_counter_id                    NUMBER;
   l_instance_association_id       NUMBER;
   l_new_derive_counter_id         NUMBER;
   l_created_map_id                NUMBER;

   CURSOR ctr_cur(p_counter_group_id NUMBER) IS
   SELECT counter_id,
          name,
          description,
          counter_type,
          initial_reading,
          initial_reading_date,
          tolerance_plus,
          tolerance_minus,
          uom_code,
          derive_function,
          derive_counter_id,
          derive_property_id,
          valid_flag,
          formula_incomplete_flag,
          formula_text,
          rollover_last_reading,
          rollover_first_reading,
          comments,
          usage_item_id,
          ctr_val_max_seq_no,
          start_date_active,
          end_date_active ,
          customer_view,
          direction,
          filter_reading_count,
          filter_type,
          filter_time_uom,
          estimation_id,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          attribute16,
          attribute17,
          attribute18,
          attribute19,
          attribute20,
          attribute21,
          attribute22,
          attribute23,
          attribute24,
          attribute25,
          attribute26,
          attribute27,
          attribute28,
          attribute29,
          attribute30,
          attribute_category,
          group_id,
          defaulted_group_id,
          reading_type,
          automatic_rollover,
          default_usage_rate,
          use_past_reading,
          used_in_scheduling,
          security_group_id,
          nvl(time_based_manual_entry, 'N') tm_based_manual_entry,
          eam_required_flag
   FROM   csi_counter_template_vl
   WHERE  group_id = p_counter_group_id
   AND    NVL(end_date_active, SYSDATE+1) > SYSDATE; --Added for bug 9115470

   CURSOR fmla_ctr_cur(p_counter_group_id NUMBER) IS
   SELECT counter_id,
          name,
          description,
          counter_type,
          initial_reading,
          tolerance_plus,
          tolerance_minus,
          uom_code,
          derive_function,
          derive_counter_id,
          derive_property_id,
          valid_flag,
          formula_incomplete_flag,
          formula_text,
          rollover_last_reading,
          rollover_first_reading,
          comments,
          usage_item_id,
          ctr_val_max_seq_no,
          start_date_active,
          end_date_active,
          -- created_from_counter_tmpl_id,
          customer_view,
          filter_reading_count,
          filter_type,
          filter_time_uom,
          estimation_id,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          attribute16,
          attribute17,
          attribute18,
          attribute19,
          attribute20,
          attribute21,
          attribute22,
          attribute23,
          attribute24,
          attribute25,
          attribute26,
          attribute27,
          attribute28,
          attribute29,
          attribute30,
          attribute_category,
          eam_required_flag
   FROM   csi_counters_vl
   WHERE  group_id = p_counter_group_id
   AND    counter_type = 'FORMULA';

   CURSOR ctr_prop_cur(p_counter_id NUMBER) IS
   SELECT counter_property_id,
          name,
          description,
          property_data_type,
          is_nullable,
          default_value,
          minimum_value,
          maximum_value,
          uom_code,
          start_date_active,
          end_date_active ,
          property_lov_type,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          attribute_category,
          security_group_id
   FROM   csi_ctr_prop_template_vl
   WHERE  counter_id = p_counter_id;

   CURSOR ctr_formula_bvars_cur(p_counter_id NUMBER) IS
   SELECT relationship_id,
          ctr_association_id,
          relationship_type_code,
          source_counter_id,
          object_counter_id,
          bind_variable_name,
          factor,
          active_start_date,
          active_end_date,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          attribute_category,
          security_group_id
   FROM   csi_counter_relationships
   -- WHERE  source_counter_id = p_counter_id;
   WHERE  object_counter_id = p_counter_id;

   CURSOR ctr_der_filter_cur(p_counter_id NUMBER) IS
   SELECT counter_id,
          seq_no,
          left_parent,
          counter_property_id,
          relational_operator,
          right_value,
          right_parent,
          logical_operator,
          start_date_active,
          end_date_active,
          security_group_id,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          attribute_category
   FROM   csi_counter_derived_filters
   WHERE  counter_id = p_counter_id;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  instantiate_grp_counters;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   --
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line(
            'instantiate_grp_counters'||'-'||
            p_api_version           ||'-'||
            nvl(p_commit,FND_API.G_FALSE) ||'-'||
            nvl(p_init_msg_list,FND_API.G_FALSE)||'-'||
            nvl(l_validation_level,FND_API.G_VALID_LEVEL_FULL) );
   END IF;

   l_source_object_cd := p_source_object_code_instance;
   l_source_object_id_instance := p_source_object_id_instance;
   l_counter_group_id := p_group_id_template;

   BEGIN
      SELECT name,
             description,
             association_type,
             start_date_active,
             end_date_active ,
             attribute1,
             attribute2,
             attribute3,
             attribute4,
             attribute5,
             attribute6,
             attribute7,
             attribute8,
             attribute9,
             attribute10,
             attribute11,
             attribute12,
             attribute13,
             attribute14,
             attribute15,
             context,
             'N'
      INTO   l_ctr_grp_rec.name,
             l_ctr_grp_rec.description,
             l_ctr_grp_rec.association_type,
             l_ctr_grp_rec.start_date_active,
             l_ctr_grp_rec.end_date_active ,
             l_ctr_grp_rec.attribute1,
             l_ctr_grp_rec.attribute2,
             l_ctr_grp_rec.attribute3,
             l_ctr_grp_rec.attribute4,
             l_ctr_grp_rec.attribute5,
             l_ctr_grp_rec.attribute6,
             l_ctr_grp_rec.attribute7,
             l_ctr_grp_rec.attribute8,
             l_ctr_grp_rec.attribute9,
             l_ctr_grp_rec.attribute10,
             l_ctr_grp_rec.attribute11,
             l_ctr_grp_rec.attribute12,
             l_ctr_grp_rec.attribute13,
             l_ctr_grp_rec.attribute14,
             l_ctr_grp_rec.attribute15,
             l_ctr_grp_rec.context,
             l_ctr_grp_rec.template_flag
      FROM   cs_csi_counter_groups
      WHERE  counter_group_id = l_counter_group_id;

      csi_ctr_gen_utility_pvt.put_line('Counter group Id = '||to_char(l_counter_group_id));
      csi_ctr_gen_utility_pvt.put_line('Template Flag = '||l_ctr_grp_rec.template_flag);
      -- Added Bug 8510631
      l_ctr_grp_rec.source_object_code := l_source_object_cd;
      l_ctr_grp_rec.source_object_id := l_source_object_id_instance;
      l_ctr_grp_rec.source_counter_group_id := l_counter_group_id;
      -- End Addition Bug 8510631
      l_ctr_grp_rec.created_from_ctr_grp_tmpl_id := l_counter_group_id;
      create_counter_group
        (
         p_api_version        => p_api_version
         ,p_commit             => p_commit
         ,p_init_msg_list      => p_init_msg_list
         ,p_validation_level   => l_validation_level
         ,p_counter_groups_rec => l_ctr_grp_rec
         ,x_return_status      => x_return_status
         ,x_msg_count          => x_msg_count
         ,x_msg_data           => x_msg_data
        );

       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;

          WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                            FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line('Error from CSI_COUNTER_TEMPLATE_PVT.CREATE_COUNTER_GROUP');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
          END LOOP;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_ctr_grp_id_instance := l_ctr_grp_rec.counter_group_id;
      x_ctr_grp_id_instance := l_ctr_grp_rec.counter_group_id;
   EXCEPTION
      WHEN OTHERS THEN
         CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_GRP_INVALID');
   END;

   FOR ctr_cur_rec IN ctr_cur(l_counter_group_id) LOOP
      l_counter_instance_rec.group_id := l_ctr_grp_id_instance;
      l_counter_instance_rec.name := ctr_cur_rec.name;
      l_counter_instance_rec.description := ctr_cur_rec.description;
      l_counter_instance_rec.counter_type := ctr_cur_rec.counter_type;
      l_counter_instance_rec.initial_reading := ctr_cur_rec.initial_reading;
      l_counter_instance_rec.initial_reading_date := ctr_cur_rec.initial_reading_date;
      l_counter_instance_rec.created_from_counter_tmpl_id := ctr_cur_rec.counter_id;
      l_counter_instance_rec.tolerance_plus := ctr_cur_rec.tolerance_plus;
      l_counter_instance_rec.tolerance_minus := ctr_cur_rec.tolerance_minus;
      l_counter_instance_rec.uom_code := ctr_cur_rec.uom_code;

      IF ctr_cur_rec.derive_counter_id IS NOT NULL THEN
         BEGIN
            -- Bug 9068223 Fixing in both R12 and 12.1 code
            /*SELECT max(counter_id)
            INTO   l_new_derive_counter_id
            FROM   csi_counters_b
            WHERE  created_from_counter_tmpl_id = ctr_cur_rec.derive_counter_id;*/

            -- To fetch the maximum counter id
           SELECT counter_id INTO l_new_derive_counter_id FROM
           (SELECT counter_id
           FROM   csi_counters_b
           WHERE  created_from_counter_tmpl_id = ctr_cur_rec.derive_counter_id
           ORDER BY counter_id DESC)
           WHERE ROWNUM = 1;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               csi_ctr_gen_utility_pvt.put_line( ' New counter id not found for deriver counte id '||to_char(ctr_cur_rec.derive_counter_id));
               NULL;
         END;

         l_counter_instance_rec.derive_counter_id := l_new_derive_counter_id;
      ELSE
         l_counter_instance_rec.derive_counter_id := ctr_cur_rec.derive_counter_id;
      END IF;

      l_counter_instance_rec.derive_function := ctr_cur_rec.derive_function;
      l_counter_instance_rec.derive_property_id := ctr_cur_rec.derive_property_id;
      l_counter_instance_rec.valid_flag := 'Y';
      l_counter_instance_rec.formula_text := ctr_cur_rec.formula_text;
      l_counter_instance_rec.rollover_last_reading := ctr_cur_rec.rollover_last_reading;
      l_counter_instance_rec.rollover_first_reading := ctr_cur_rec.rollover_first_reading;
      l_counter_instance_rec.usage_item_id := ctr_cur_rec.usage_item_id;
      l_counter_instance_rec.start_date_active := ctr_cur_rec.start_date_active;
      l_counter_instance_rec.end_date_active := ctr_cur_rec.end_date_active;
      l_counter_instance_rec.security_group_id := ctr_cur_rec.security_group_id;
      l_counter_instance_rec.object_version_number := 1;
      l_counter_instance_rec.last_update_date := sysdate;
      l_counter_instance_rec.last_Updated_by  := fnd_global.user_id;
      l_counter_instance_rec.creation_date := sysdate;
      l_counter_instance_rec.created_by := FND_GLOBAL.user_id;
      l_counter_instance_rec.last_update_login := FND_GLOBAL.user_id;
      l_counter_instance_rec.attribute_category := ctr_cur_rec.attribute_category;
      l_counter_instance_rec.attribute1 := ctr_cur_rec.attribute1;
      l_counter_instance_rec.attribute2 := ctr_cur_rec.attribute2;
      l_counter_instance_rec.attribute3 := ctr_cur_rec.attribute3;
      l_counter_instance_rec.attribute4 := ctr_cur_rec.attribute4;
      l_counter_instance_rec.attribute5 := ctr_cur_rec.attribute5;
      l_counter_instance_rec.attribute6 := ctr_cur_rec.attribute6;
      l_counter_instance_rec.attribute7 := ctr_cur_rec.attribute7;
      l_counter_instance_rec.attribute8 := ctr_cur_rec.attribute8;
      l_counter_instance_rec.attribute9 := ctr_cur_rec.attribute9;
      l_counter_instance_rec.attribute10 := ctr_cur_rec.attribute10;
      l_counter_instance_rec.attribute11 := ctr_cur_rec.attribute11;
      l_counter_instance_rec.attribute12 := ctr_cur_rec.attribute12;
      l_counter_instance_rec.attribute13 := ctr_cur_rec.attribute13;
      l_counter_instance_rec.attribute14 := ctr_cur_rec.attribute14;
      l_counter_instance_rec.attribute15 := ctr_cur_rec.attribute15;
      l_counter_instance_rec.attribute16 := ctr_cur_rec.attribute16;
      l_counter_instance_rec.attribute17 := ctr_cur_rec.attribute17;
      l_counter_instance_rec.attribute18 := ctr_cur_rec.attribute18;
      l_counter_instance_rec.attribute19 := ctr_cur_rec.attribute19;
      l_counter_instance_rec.attribute20 := ctr_cur_rec.attribute20;
      l_counter_instance_rec.attribute21 := ctr_cur_rec.attribute21;
      l_counter_instance_rec.attribute22 := ctr_cur_rec.attribute22;
      l_counter_instance_rec.attribute23 := ctr_cur_rec.attribute23;
      l_counter_instance_rec.attribute24 := ctr_cur_rec.attribute24;
      l_counter_instance_rec.attribute25 := ctr_cur_rec.attribute25;
      l_counter_instance_rec.attribute26 := ctr_cur_rec.attribute26;
      l_counter_instance_rec.attribute27 := ctr_cur_rec.attribute27;
      l_counter_instance_rec.attribute28 := ctr_cur_rec.attribute28;
      l_counter_instance_rec.attribute29 := ctr_cur_rec.attribute29;
      l_counter_instance_rec.attribute30 := ctr_cur_rec.attribute30;
      l_counter_instance_rec.customer_view := ctr_cur_rec.customer_view;
      l_counter_instance_rec.direction := ctr_cur_rec.direction;
      l_counter_instance_rec.filter_type := ctr_cur_rec.filter_type;
      l_counter_instance_rec.filter_reading_count := ctr_cur_rec.filter_reading_count;
      l_counter_instance_rec.filter_time_uom := ctr_cur_rec.filter_time_uom;
      l_counter_instance_rec.estimation_id := ctr_cur_rec.estimation_id;
      l_counter_instance_rec.reading_type := ctr_cur_rec.reading_type;
      l_counter_instance_rec.automatic_rollover := ctr_cur_rec.automatic_rollover;
      l_counter_instance_rec.default_usage_rate := ctr_cur_rec.default_usage_rate;
      l_counter_instance_rec.use_past_reading   := ctr_cur_rec.use_past_reading;
      l_counter_instance_rec.used_in_scheduling := ctr_cur_rec.used_in_scheduling;
      l_counter_instance_rec.defaulted_group_id := l_ctr_grp_id_instance;
      l_new_ctr_grp_id := l_ctr_grp_id_instance;
      l_counter_instance_rec.comments := ctr_cur_rec.comments;
      l_counter_instance_rec.time_based_manual_entry := ctr_cur_rec.tm_based_manual_entry;
      l_counter_instance_rec.eam_required_flag := ctr_cur_rec.eam_required_flag;

      CSI_COUNTER_PVT.CREATE_COUNTER
          (
            p_api_version           => p_api_version,
            p_init_msg_list         => p_init_msg_list,
            p_commit                => p_commit,
            p_validation_level      => l_validation_level,
            p_counter_instance_rec  => l_counter_instance_rec,
            x_return_status         => x_return_status,
            x_msg_count             => x_msg_count,
            x_msg_data              => x_msg_data,
            x_ctr_id                => l_new_ctr_id
          );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;

          WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                            FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_PVT.CREATE_COUNTER');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
          END LOOP;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

      -- x_ctr_id_instance := l_counter_instance_rec.group_id;
      -- Create Counter Associations
      l_counter_associations_rec.source_object_code := l_source_object_cd;
      l_counter_associations_rec.source_object_id   := l_source_object_id_instance;
      l_counter_associations_rec.counter_id         := l_new_ctr_id;
      l_counter_associations_rec.start_date_active  := sysdate;
      l_counter_associations_rec.maint_organization_id := p_maint_org_id;
      l_counter_associations_rec.primary_failure_flag := p_primary_failure_flag;

      CSI_COUNTER_PVT.CREATE_CTR_ASSOCIATIONS
         (
           p_api_version            => p_api_version
           ,p_commit                => p_commit
           ,p_init_msg_list         => p_init_msg_list
           ,p_validation_level      => l_validation_level
           ,p_counter_associations_rec  => l_counter_associations_rec
           ,x_return_status         => x_return_status
           ,x_msg_count             => x_msg_count
           ,x_msg_data              => x_msg_data
           ,x_instance_association_id  => l_instance_association_id
         );

      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;

          WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                            FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_PVT.CREATE_CTR_ASSOCIATIONS');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
          END LOOP;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
      -- INstantiate all the properties for that counter.

      FOR ctr_prop_cur_rec IN ctr_prop_cur(ctr_cur_rec.counter_id) LOOP

         l_ctr_properties_rec.counter_id := l_new_ctr_id;
         l_ctr_properties_rec.name := ctr_prop_cur_rec.name;
         l_ctr_properties_rec.description := ctr_prop_cur_rec.description;
         l_ctr_properties_rec.property_data_type := ctr_prop_cur_rec.property_data_type;
         l_ctr_properties_rec.property_lov_type  :=  ctr_prop_cur_rec.property_lov_type;
         l_ctr_properties_rec.created_from_ctr_prop_tmpl_id := ctr_prop_cur_rec.counter_property_id;
         l_ctr_properties_rec.is_nullable := ctr_prop_cur_rec.is_nullable;
         l_ctr_properties_rec.default_value := ctr_prop_cur_rec.default_value;
         l_ctr_properties_rec.minimum_value := ctr_prop_cur_rec.minimum_value;
         l_ctr_properties_rec.maximum_value := ctr_prop_cur_rec.maximum_value;
         l_ctr_properties_rec.uom_code := ctr_prop_cur_rec.uom_code;
         l_ctr_properties_rec.start_date_active := ctr_prop_cur_rec.start_date_active;
         l_ctr_properties_rec.end_date_active := ctr_prop_cur_rec.end_date_active;
         l_ctr_properties_rec.security_group_id := ctr_prop_cur_rec.security_group_id;
         l_ctr_properties_rec.object_version_number := 1;
         l_ctr_properties_rec.last_update_date := sysdate;
         l_ctr_properties_rec.last_Updated_by  := fnd_global.user_id;
         l_ctr_properties_rec.creation_date := sysdate;
         l_ctr_properties_rec.created_by := FND_GLOBAL.user_id;
         l_ctr_properties_rec.last_update_login := FND_GLOBAL.user_id;
         l_ctr_properties_rec.attribute_category := ctr_prop_cur_rec.attribute_category;
         l_ctr_properties_rec.attribute1 := ctr_prop_cur_rec.attribute1;
         l_ctr_properties_rec.attribute2 := ctr_prop_cur_rec.attribute2;
         l_ctr_properties_rec.attribute3 := ctr_prop_cur_rec.attribute3;
         l_ctr_properties_rec.attribute4 := ctr_prop_cur_rec.attribute4;
         l_ctr_properties_rec.attribute5 := ctr_prop_cur_rec.attribute5;
         l_ctr_properties_rec.attribute6 := ctr_prop_cur_rec.attribute6;
         l_ctr_properties_rec.attribute7 := ctr_prop_cur_rec.attribute7;
         l_ctr_properties_rec.attribute8 := ctr_prop_cur_rec.attribute8;
         l_ctr_properties_rec.attribute9 := ctr_prop_cur_rec.attribute9;
         l_ctr_properties_rec.attribute10 := ctr_prop_cur_rec.attribute10;
         l_ctr_properties_rec.attribute11 := ctr_prop_cur_rec.attribute11;
         l_ctr_properties_rec.attribute12 := ctr_prop_cur_rec.attribute12;
         l_ctr_properties_rec.attribute13 := ctr_prop_cur_rec.attribute13;
         l_ctr_properties_rec.attribute14 := ctr_prop_cur_rec.attribute14;
         l_ctr_properties_rec.attribute15 := ctr_prop_cur_rec.attribute15;


         CSI_Counter_PVT.Create_Ctr_Property
            (
             p_api_version       => p_api_version
             ,p_commit           => p_commit
             ,p_init_msg_list    => p_init_msg_list
             ,p_validation_level => l_validation_level
             ,p_ctr_properties_rec => l_ctr_properties_rec
             ,x_return_status     => x_return_status
             ,x_msg_count         => x_msg_count
             ,x_msg_data          => x_msg_data
             ,x_ctr_property_id   => l_new_ctr_prop_id
          );

      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;

          WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                            FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_Counter_PVT.Create_Ctr_Property');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
          END LOOP;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

      END LOOP;

      -- All the counter properties belonging to this counter have been
      -- instantiated.

   END LOOP;
   csi_ctr_gen_utility_pvt.put_line('After the end loop ');
   csi_ctr_gen_utility_pvt.put_line('Passed counter group id  = '||to_char(l_ctr_grp_rec.counter_group_id));

   FOR fmla_ctr_cur_rec IN fmla_ctr_cur(l_ctr_grp_rec.counter_group_id) LOOP
   csi_ctr_gen_utility_pvt.put_line('Formula Counter Id = '||to_char(fmla_ctr_cur_rec.counter_id));
      FOR ctr_der_filter_cur_rec IN ctr_der_filter_cur(fmla_ctr_cur_rec.counter_id)
      LOOP
 csi_ctr_gen_utility_pvt.put_line('Inside the ctr_der_filter_cur_rec ');

         SELECT counter_property_id
         INTO   l_new_der_ctr_prop_id
         FROM   csi_counter_template_vl ctr,
                csi_ctr_prop_template_vl ctrprop
         WHERE  ctrprop.counter_property_id = ctr_der_filter_cur_rec.counter_property_id
         AND    ctrprop.counter_id = l_new_ctr_id;

         CSI_COUNTER_TEMPLATE_PVT.CREATE_DERIVED_FILTERS
            (
             p_api_version           => p_api_version
             ,p_commit               => p_commit
             ,p_init_msg_list        => p_init_msg_list
             ,p_validation_level     => l_validation_level
             ,p_ctr_derived_filters_tbl => l_ctr_derived_filters_tbl
             ,x_return_status         => x_return_status
             ,x_msg_count             => x_msg_count
             ,x_msg_data              => x_msg_data
            );

      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;

          WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                            FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_TEMPLATE_PVT.CREATE_DERIVED_FILTERS');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
          END LOOP;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

      END LOOP;

      csi_ctr_gen_utility_pvt.put_line('Created from ctr id = '||to_char(fmla_ctr_cur_rec.counter_id));
      BEGIN
         SELECT created_from_counter_tmpl_id
         INTO   l_created_map_id
         FROM   csi_counters_b
         WHERE  counter_id = fmla_ctr_cur_rec.counter_id;
      EXCEPTION
         WHEN OTHERS THEN NULL;
      END;

      -- FOR ctr_formula_bvars_cur_rec IN ctr_formula_bvars_cur(l_new_ctr_id)
      FOR ctr_formula_bvars_cur_rec IN ctr_formula_bvars_cur(l_created_map_id)
      LOOP
         -- Bug 9068223 Fixing in both R12 and 12.1 code
         /*SELECT max(counter_id)
         INTO   l_new_mapped_ctr_id
         FROM   csi_counters_b
         WHERE  created_from_counter_tmpl_id = ctr_formula_bvars_cur_rec.source_counter_id;
         -- AND    group_id = l_ctr_grp_rec.counter_group_id;*/

         -- To fetch the maximum counter id
         SELECT counter_id INTO l_new_mapped_ctr_id FROM
         (SELECT counter_id
         FROM   csi_counters_b
         WHERE  created_from_counter_tmpl_id = ctr_formula_bvars_cur_rec.source_counter_id
         ORDER BY counter_id DESC)
         WHERE ROWNUM = 1;

         IF ctr_formula_bvars_cur_rec.source_counter_id IS NOT NULL THEN
            -- THIS IS a configuration counter. I need to see if I can
            -- find out the CP to which the mapped_counter is attached.
            -- It may not be instantiated yet, so its possible that its
            -- not possible to get the mapped cp id. If i can't get it,
            -- set the formula_incompl_flag to 'N' for that counter.

            -- You cannot have configuration counters fro service items
            -- only for serviceable products. So, I can safely look at
            -- cs_customer_products and assume this is a product.

            FND_PROFILE.Get('ORG_ID',l_org_id);

            l_config_root_id := csi_generic_grp.config_root_node(p_source_object_id_instance,'COMPONENT-OF');

            BEGIN
               p_relationship_query_rec.RELATIONSHIP_ID := NULL;
               p_relationship_query_rec.RELATIONSHIP_TYPE_CODE := 'COMPONENT-OF';
               p_relationship_query_rec.OBJECT_ID := l_config_root_id;
               p_relationship_query_rec.SUBJECT_ID := NULL;

               -- Now call the stored program
               csi_ii_relationships_pub.get_relationships
                  (1.0,
                   '',
                   '',
                   NULL,
                   p_relationship_query_rec,
                   NULL,
                   NULL,
                   '',
                   x_relationship_tbl,
                   x_return_status,
                   x_msg_count,
                   x_msg_data);


               -- Output the results
               IF x_relationship_tbl IS NOT NULL THEN
                  IF x_relationship_tbl.count > 0 THEN
                     FOR i IN x_relationship_tbl.first..x_relationship_tbl.last LOOP
                        IF x_relationship_tbl.exists(i) THEN
                           --null; -- type of data not known
                           SELECT inventory_item_id
                           INTO   l_mapped_item_id
                           FROM   csi_item_instances
                           WHERE  instance_id = x_relationship_tbl(i).subject_id
                           AND    inv_master_organization_id = l_org_id;

                           --IF l_mapped_item_id = ctr_formula_bvars_cur_rec.mapped_inv_item_id then
                            --  exit;
                           --END IF;
                        END IF;
                     END LOOP;
                  END IF;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  -- l_mapped_item_id := ctr_formula_bvars_cur_rec.mapped_inv_item_id;
                  NULL;
            END;

         END IF;

         -- l_reading_type   := ctr_formula_bvars_cur_rec.reading_type;
         l_counter_relationships_rec.attribute1 := ctr_formula_bvars_cur_rec.attribute1;
         l_counter_relationships_rec.attribute2 := ctr_formula_bvars_cur_rec.attribute2;
         l_counter_relationships_rec.attribute3 := ctr_formula_bvars_cur_rec.attribute3;
         l_counter_relationships_rec.attribute4 := ctr_formula_bvars_cur_rec.attribute4;
         l_counter_relationships_rec.attribute5 := ctr_formula_bvars_cur_rec.attribute5;
         l_counter_relationships_rec.attribute6 := ctr_formula_bvars_cur_rec.attribute6;
         l_counter_relationships_rec.attribute7 := ctr_formula_bvars_cur_rec.attribute7;
         l_counter_relationships_rec.attribute8 := ctr_formula_bvars_cur_rec.attribute8;
         l_counter_relationships_rec.attribute9 := ctr_formula_bvars_cur_rec.attribute9;
         l_counter_relationships_rec.attribute10 := ctr_formula_bvars_cur_rec.attribute10;
         l_counter_relationships_rec.attribute11 := ctr_formula_bvars_cur_rec.attribute11;
         l_counter_relationships_rec.attribute12 := ctr_formula_bvars_cur_rec.attribute12;
         l_counter_relationships_rec.attribute13 := ctr_formula_bvars_cur_rec.attribute13;
         l_counter_relationships_rec.attribute14 := ctr_formula_bvars_cur_rec.attribute14;
         l_counter_relationships_rec.attribute15 := ctr_formula_bvars_cur_rec.attribute15;
         l_counter_relationships_rec.attribute_category := ctr_formula_bvars_cur_rec.attribute_category;
         l_counter_relationships_rec.security_group_id := ctr_formula_bvars_cur_rec.security_group_id;
         l_counter_relationships_rec.object_version_number := 1;
         l_counter_relationships_rec.last_update_date := sysdate;
         l_counter_relationships_rec.last_Updated_by  := fnd_global.user_id;
         l_counter_relationships_rec.creation_date := sysdate;
         l_counter_relationships_rec.created_by := FND_GLOBAL.user_id;
         l_counter_relationships_rec.last_update_login := FND_GLOBAL.user_id;
         l_counter_relationships_rec.ctr_association_id := ctr_formula_bvars_cur_rec.ctr_association_id;
         l_counter_relationships_rec.relationship_type_code := ctr_formula_bvars_cur_rec.relationship_type_code;
         -- l_counter_relationships_rec.source_counter_id := ctr_formula_bvars_cur_rec.source_counter_id;
         -- l_counter_relationships_rec.object_counter_id := ctr_formula_bvars_cur_rec.object_counter_id;
         l_counter_relationships_rec.source_counter_id := l_new_mapped_ctr_id;
         l_counter_relationships_rec.object_counter_id := fmla_ctr_cur_rec.counter_id;
         l_counter_relationships_rec.bind_variable_name := ctr_formula_bvars_cur_rec.bind_variable_name;
         l_counter_relationships_rec.factor := ctr_formula_bvars_cur_rec.factor;
         l_counter_relationships_rec.active_start_date := ctr_formula_bvars_cur_rec.active_start_date;
         l_counter_relationships_rec.active_end_date := ctr_formula_bvars_cur_rec.active_end_date;

         csi_counter_template_pvt.create_counter_relationship
            (
            p_api_version         => p_api_version
            ,p_commit             => fnd_api.g_false
            ,p_init_msg_list      => p_init_msg_list
            ,p_validation_level   => l_validation_level
            ,p_counter_relationships_rec => l_counter_relationships_rec
            ,x_return_status      => x_return_status
            ,x_msg_count          => x_msg_count
            ,x_msg_data           => x_msg_data
            );

       END LOOP;
   END LOOP;

   -- x_ctr_id_template := p_counter_id_template;
   -- x_ctr_id_instance := l_new_ctr_id;

   IF FND_API.to_Boolean(nvl(p_commit,FND_API.G_FALSE)) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and IF count is  get message info.
   FND_MSG_PUB.Count_And_Get
      ( p_count  =>  x_msg_count,
        p_data   =>  x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO instantiate_grp_counters;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO instantiate_grp_counters;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO  instantiate_grp_counters;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg
            ( G_PKG_NAME,
              l_api_name
            );
      END IF;
      FND_MSG_PUB.Count_And_Get
         ( p_count  => x_msg_count,
           p_data   => x_msg_data
         );
END Instantiate_Grp_Counters;

--|---------------------------------------------------
--| procedure name: delete_item_association
--| description :   procedure used to
--|                 delete item association to
--|                 counter group or counters
--|---------------------------------------------------

PROCEDURE delete_item_association
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_ctr_associations_id       IN     NUMBER
    ,x_return_status                OUT    NOCOPY VARCHAR2
    ,x_msg_count                    OUT    NOCOPY NUMBER
    ,x_msg_data                     OUT    NOCOPY VARCHAR2
 ) IS
   l_api_name                     CONSTANT VARCHAR2(30)   := 'DELETE_ITEM_ASSOCIATION';
   l_api_version                  CONSTANT NUMBER         := 1.0;
   l_msg_data                     VARCHAR2(2000);
   l_msg_index                    NUMBER;
   l_msg_count                    NUMBER;
   -- l_debug_level                  NUMBER;

   l_CTR_ASSOCIATIONS_ID	  NUMBER;
   l_instantiated_counter	  NUMBER;
   l_group_id	                  NUMBER;
   l_counter_id	                  NUMBER;
   l_associations_exists          VARCHAR2(1);
   l_associated_to_group          VARCHAR2(1);

   CURSOR get_item_details(p_group_id NUMBER) IS
   SELECT ctr_association_id, counter_id
   FROM   csi_ctr_item_associations
   WHERE  counter_id IS NOT NULL
   AND    associated_to_group = 'Y'
   AND    group_id  = p_group_id;

   CURSOR check_counters(p_counter_id NUMBER) IS
   SELECT counter_id instantiated_counter_id
   FROM   csi_counters_b
   WHERE  created_from_counter_tmpl_id = p_counter_id;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  delete_item_association_pvt;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   --
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line
         ( 'delete_item_association_pvt'           ||'-'||
           p_api_version                              ||'-'||
           nvl(p_commit,FND_API.G_FALSE)              ||'-'||
           nvl(p_init_msg_list,FND_API.G_FALSE)       ||'-'||
           nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL) );
   END IF;

   if p_ctr_associations_id = FND_API.G_MISS_NUM then
      l_ctr_associations_id := null;
   else
      l_ctr_associations_id := p_ctr_associations_id;
   end if;

 csi_ctr_gen_utility_pvt.put_line('Inside delete Item association = '||to_char(l_ctr_associations_id));
   /* Start of validation */
   BEGIN
      SELECT associated_to_group, group_id, counter_id
      INTO   l_associated_to_group, l_group_id, l_counter_id
      FROM   csi_ctr_item_associations
      WHERE  ctr_association_id = l_ctr_associations_id;

      IF l_associated_to_group = 'Y' THEN
         FOR get_item_rec in get_item_details(l_group_id) LOOP
            FOR get_ctr_rec in check_counters(get_item_rec.counter_id) LOOP
               /* Verify if counter association exists */
               BEGIN
                  SELECT 'x'
                  INTO   l_associations_exists
                  FROM   csi_counter_associations
                  WHERE  counter_id = get_ctr_rec.instantiated_counter_id;

                  CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_ITEM_DEL_NOTALLOW');
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     NULL;
                  WHEN OTHERS THEN
                     CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_ITEM_DEL_NOTALLOW');
               END;
            END LOOP;
         END LOOP;

         /* Now Delete the data that was verified */
         FOR get_item_rec in get_item_details(l_group_id) LOOP
             /* Call the table Handler */
             CSI_CTR_ITEM_ASSOCIATIONS_PKG.Delete_Row
                 (p_CTR_ASSOCIATION_ID  => get_item_rec.ctr_association_id);

             IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
                 ROLLBACK TO delete_item_association_pvt;
                 RETURN;
             END IF;
         END LOOP;

         /* Now Delete the main group-item association */
         /* Call the table Handler */
         CSI_CTR_ITEM_ASSOCIATIONS_PKG.Delete_Row
             (p_CTR_ASSOCIATION_ID  => l_ctr_associations_id);

         IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
            ROLLBACK TO delete_item_association_pvt;
            RETURN;
         END IF;
      ELSE
         FOR get_ctr_rec in check_counters(l_counter_id) LOOP
            /* Verify if counter association exists */
            BEGIN
               SELECT 'x'
               INTO   l_associations_exists
               FROM   csi_counter_associations
               WHERE  counter_id = get_ctr_rec.instantiated_counter_id;

               CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_ITEM_DEL_NOTALLOW');
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
               WHEN OTHERS THEN
                  CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_ITEM_DEL_NOTALLOW');
            END;
         END LOOP;
         /* Now Delete the data that was verified */
         /* Call the table Handler */
         CSI_CTR_ITEM_ASSOCIATIONS_PKG.Delete_Row
             (p_CTR_ASSOCIATION_ID  => l_ctr_associations_id);

         IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
            ROLLBACK TO delete_item_association_pvt;
            RETURN;
         END IF;
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_ITEM_DEL_NOTALLOW');
   END;

   IF FND_API.to_Boolean(nvl(p_commit,FND_API.G_FALSE)) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and IF count is  get message info.
   FND_MSG_PUB.Count_And_Get
      ( p_count  =>  x_msg_count,
        p_data   =>  x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO delete_item_association_pvt;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO delete_item_association_pvt;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_item_association_pvt;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg
            ( G_PKG_NAME,
              l_api_name
            );
      END IF;
      FND_MSG_PUB.Count_And_Get
         ( p_count  => x_msg_count,
           p_data   => x_msg_data
         );
END delete_item_association;

END CSI_COUNTER_TEMPLATE_PVT;

/
