--------------------------------------------------------
--  DDL for Package Body CSI_COUNTER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_COUNTER_PVT" AS
/* $Header: csivctib.pls 120.27.12010000.5 2010/02/16 23:17:59 devijay ship $ */

-- --------------------------------------------------------
-- Define global variables
-- --------------------------------------------------------

G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSI_COUNTER_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csivctib.pls';

--|---------------------------------------------------
--|    Object         : ExitWithErrMsg
--|    Scope          : Private to package
--|    Description    : Common procedure to raise error
--|    Parameters     : p_msg_name - message name in CS schema
--|                     p_token?_name/val - Token for message and its value
--|---------------------------------------------------
Procedure ExitWithErrMsg
(
	p_msg_name		in	varchar2,
	p_token1_name	in	varchar2	:=	null,
	p_token1_val	in	varchar2	:=	null,
	p_token2_name	in	varchar2	:=	null,
	p_token2_val	in	varchar2	:=	null,
	p_token3_name	in	varchar2	:=	null,
	p_token3_val	in	varchar2	:=	null,
	p_token4_name	in	varchar2	:=	null,
	p_token4_val	in	varchar2	:=	null
) is
begin
     FND_MESSAGE.SET_NAME('CS',p_msg_name);
  	 if p_token1_name is not null then
		FND_MESSAGE.SET_TOKEN(p_token1_name, p_token1_val);
	 end if;
	if p_token2_name is not null then
		FND_MESSAGE.SET_TOKEN(p_token2_name, p_token2_val);
	end if;
	if p_token3_name is not null then
		FND_MESSAGE.SET_TOKEN(p_token3_name, p_token3_val);
	end if;
	if p_token4_name is not null then
		FND_MESSAGE.SET_TOKEN(p_token4_name, p_token4_val);
	end if;
	--
	FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
end ExitWithErrMsg;

--|---------------------------------------------------
--| procedure name: validate_uom
--| description :   procedure used to
--|                 validate unit of measure
--|---------------------------------------------------

PROCEDURE validate_uom(p_uom_code varchar2) is
	l_dummy	varchar2(1);
BEGIN
	  select 'x'
	  into l_dummy
	  from mtl_units_of_measure
	  where uom_code = p_uom_code;
exception when no_data_found then
   csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_ALL_INVALID_UOM_CODE');
END;

--|---------------------------------------------------
--| function name: counter_name_exists
--| description :  Function used to check
--|                duplicate counter name
--|---------------------------------------------------
FUNCTION counter_name_exists(p_name VARCHAR2, p_ctr_id	NUMBER) RETURN BOOLEAN  IS
 l_return_value	BOOLEAN := TRUE;
	l_dummy	VARCHAR2(1);
BEGIN
 SELECT 'x'
 INTO l_dummy
 FROM csi_counters_vl
 WHERE name = p_name
 AND counter_id <>  nvl(p_ctr_id,-1);

	-- There already exists a counter with the same name.Return true
 RETURN (l_return_value);
EXCEPTION WHEN NO_DATA_FOUND THEN
  --counter name doesnot exist.
	l_return_value := FALSE;
 RETURN (l_return_value);
END;

--|---------------------------------------------------
--| function name: VALIDATE_FORMULA
--| description :   Function used to validate
--|                  and parse formula text
--|---------------------------------------------------
FUNCTION VALIDATE_FORMULA(p_formula_text VARCHAR2) RETURN BOOLEAN IS
        iSQLCur number;
        sSQL varchar2(2090);
BEGIN
    sSQL := 'select ' || P_FORMULA_TEXT || ' from dual';
    iSQLCur := DBMS_SQL.open_cursor;
    dbms_sql.parse(iSQLCur,sSQL,2);
    dbms_sql.close_cursor(iSQLCur);
    return TRUE;
EXCEPTION
    WHEN OTHERS THEN
      return FALSE;
END;


--|---------------------------------------------------
--| procedure name: validate_unique_ctr
--| description :   procedure used to
--|                 validate unique counter name
--|---------------------------------------------------
PROCEDURE Validate_Unique_ctr(p_name VARCHAR2, p_ctr_id	NUMBER) IS
	l_dummy	VARCHAR2(1);
BEGIN
 SELECT 'x'
 INTO l_dummy
 FROM csi_counters_vl
 WHERE name = p_name
 AND counter_id <>  nvl(p_ctr_id,-1);

	-- There already exists a counter with the same name. Raise error
 csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_DUP_NAME','CTR_NAME',p_name);
EXCEPTION WHEN NO_DATA_FOUND THEN
	NULL;
END;

--|---------------------------------------------------
--| procedure name: validate_unique_ctrprop
--| description :   procedure used to
--|                 validate unique counter property name
--|---------------------------------------------------
PROCEDURE Validate_Unique_ctrprop
(
	p_name	 	VARCHAR2,
	p_ctr_id		NUMBER,
	p_ctr_prop_id		NUMBER
)
IS
	l_dummy	VARCHAR2(1);
BEGIN
	SELECT 'x'
	INTO l_dummy
	FROM csi_counter_properties_vl
	WHERE name = p_name
	AND   counter_id =  p_ctr_id
	AND   counter_property_id <>  nvl(p_ctr_prop_id,-1);

	-- There already exists a counter property within the counter with
	-- the same name. Raise error
 ExitWithErrMsg('CSI_API_CTR_PROP_DUP_NAME','CTR_PROP_NAME',p_name,'CTR_NAME',p_ctr_id);

EXCEPTION WHEN NO_DATA_FOUND THEN
	NULL;
END ;

--|---------------------------------------------------
--| procedure name: validate_counter
--| description :   procedure used to
--|                 validate counter
--|---------------------------------------------------

PROCEDURE Validate_Counter
 (
     p_group_id        NUMBER
    ,p_name            VARCHAR2
    ,p_counter_type    VARCHAR2
    ,p_uom_code        VARCHAR2
    ,p_usage_item_id   NUMBER
    ,p_reading_type    VARCHAR2
    ,p_direction       VARCHAR2
    ,p_estimation_id   NUMBER
    ,p_derive_function VARCHAR2
    ,p_formula_text    VARCHAR2
    ,p_derive_counter_id  NUMBER
    ,p_filter_type     VARCHAR2
    ,p_filter_reading_count  NUMBER
    ,p_filter_time_uom  VARCHAR2
    ,p_automatic_rollover  VARCHAR2
    ,p_rollover_last_reading NUMBER
    ,p_rollover_first_reading  NUMBER
    ,p_tolerance_plus   NUMBER
    ,p_tolerance_minus  NUMBER
    ,p_used_in_scheduling  VARCHAR2
    ,p_initial_reading  NUMBER
    ,p_default_usage_rate  NUMBER
    ,p_use_past_reading  NUMBER
    ,p_counter_id  NUMBER
    ,p_start_date_active  DATE
    ,p_end_date_active    DATE
 )
 IS
     l_dummy	varchar2(1);
     l_time_uom varchar2(1);
     l_inv_valdn_org_id NUMBER := fnd_profile.value('CS_INV_VALIDATION_ORG');
BEGIN

   -- validate counter name is not null
   if p_name is null then
     csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_REQ_PARM_CTR_NAME');
   end if;

   -- validate uom code
   validate_uom(p_uom_code);

   --validate Usage item id
   if p_usage_item_id is not null then
    begin
      select 'x'
      into l_dummy
      from mtl_system_items
      where inventory_item_id = p_usage_item_id
      and organization_id = l_inv_valdn_org_id
      --and organization_id = cs_std.get_item_valdn_orgzn_id
      and usage_item_flag = 'Y';
    exception when no_data_found then
      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_INV_USAGE_ITEM');
    end;

    if p_group_id is null then
       csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_REQ_PARM_GRP_NAME');
    end if;
   end if;

   -- validate counter group id
   if p_group_id is not null then
    begin
     select 'x'
	    into l_dummy
     from csi_counter_groups_v
     where counter_group_id = p_group_id;
    exception when no_data_found then
     csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_GRP_INVALID');
    end;
   end if;

   --validate estimation id not exist if direction is Bi-Direction
   if p_estimation_id is not null and p_direction not in ('A','D') then
      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_EST_NO_DIRECTION');
   end if;

   -- Validate that automatic rollover should not exist if direction is Bi-Direction
   if nvl(p_automatic_rollover,'N') = 'Y' and p_direction not in ('A','D') then
      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_ARO_NO_DIRECTION');
   end if;

   --validate tolerance plus and tolerance minus for negative values
   if p_tolerance_plus < 0  or p_tolerance_minus <0 then
      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_INV_TOLERANCE');
   end if;

   --validate counter type
   if p_counter_type not in ('REGULAR','FORMULA') then
      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_INVALID_CTR_TYPE');
   end if;

   --validate counter type parameters
   if p_counter_type = 'REGULAR' then
      begin
        select 'Y'
        into l_time_uom
        from mtl_units_of_measure
        where uom_code = p_uom_code
        and upper(UOM_CLASS)='TIME';
      exception
        when no_data_found then
          l_time_uom := 'N';
      end;

      if l_time_uom = 'N' then
        if p_reading_type not in (1,2) then
             --ExitWithErrMsg('CSI_API_CTR_REQ_PARM_CTR_TYPE','PARAM','p_reading_type','CTR_TYPE',p_counter_type);
             csi_ctr_gen_utility_pvt.ExitWithErrMsg
             ( p_msg_name     =>  'CSI_API_CTR_REQ_PARM_CTR_TYPE',
               p_token1_name  =>  'PARAM',
               p_token1_val   =>  'p_reading_type',
               p_token2_name  =>  'CTR_TYPE',
               p_token2_val   =>  p_counter_type
             );
        end if;
        if p_derive_function is not null or
           p_formula_text is not null or
           p_derive_counter_id is not null or
           p_filter_type is not null or
           p_filter_reading_count is not null or
           p_filter_time_uom is not null  then
             --ExitWithErrMsg('CSI_API_CTR_INV_PARM_CTR_TYPE','CTR_TYPE',p_counter_type);
             csi_ctr_gen_utility_pvt.ExitWithErrMsg
             ( p_msg_name     =>  'CSI_API_CTR_INV_PARM_CTR_TYPE',
               p_token1_name  =>  'CTR_TYPE',
               p_token1_val   =>  p_counter_type
             );
        end if;

        --validate required parameter values exist for automatic rollover
        if nvl(p_automatic_rollover,'N') = 'Y' then
           if p_rollover_last_reading is null then
             --ExitWithErrMsg('CSI_API_CTR_REQ_PARM_ROLLOVER','PARAM','p_rollover_last_reading');
             csi_ctr_gen_utility_pvt.ExitWithErrMsg
             ( p_msg_name     =>  'CSI_API_CTR_REQ_PARM',
               p_token1_name  =>  'PARAM',
               p_token1_val   =>  'p_rollover_last_reading'
             );
           elsif p_rollover_first_reading is null then
             --ExitWithErrMsg('CSI_API_CTR_REQ_PARM_ROLLOVER','PARAM','p_rollover_first_reading');
             csi_ctr_gen_utility_pvt.ExitWithErrMsg
             ( p_msg_name     =>  'CSI_API_CTR_REQ_PARM',
               p_token1_name  =>  'PARAM',
               p_token1_val   =>  'p_rollover_first_reading'
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
            --ExitWithErrMsg('CSI_API_CTR_REQ_PARM_USE_SCHD','PARAM','p_initial_reading');
            csi_ctr_gen_utility_pvt.ExitWithErrMsg
             ( p_msg_name     =>  'CSI_API_CTR_REQ_PARM',
               p_token1_name  =>  'PARAM',
               p_token1_val   =>  'p_initial_reading'
             );
          elsif p_default_usage_rate  is null then
            --ExitWithErrMsg('CSI_API_CTR_REQ_PARM_USE_SCHD','PARAM','p_default_usage_rate');
            csi_ctr_gen_utility_pvt.ExitWithErrMsg
             ( p_msg_name     =>  'CSI_API_CTR_REQ_PARM',
               p_token1_name  =>  'PARAM',
               p_token1_val   =>  'p_default_usage_rate'
             );
          elsif p_use_past_reading is null then
            --ExitWithErrMsg('CSI_API_CTR_REQ_PARM_USE_SCHD','PARAM','p_use_past_reading');
            csi_ctr_gen_utility_pvt.ExitWithErrMsg
            ( p_msg_name     =>  'CSI_API_CTR_REQ_PARM',
               p_token1_name  =>  'PARAM',
               p_token1_val   =>  'p_use_past_reading'
             );
          end if;
        end if;
      else -- if type is a time counter
        if p_derive_function is not null or
           p_formula_text is not null or
           p_derive_counter_id is not null or
           p_filter_type is not null or
           p_filter_reading_count is not null or
           p_filter_time_uom is not null or
           --p_reading_type is not null or
           nvl(p_automatic_rollover,'N') = 'Y' or
           p_rollover_last_reading is not null or
           p_rollover_first_reading is not null or
           --nvl(p_used_in_scheduling,'N') = 'Y' or
           --p_initial_reading is not null or
           --p_default_usage_rate is not null or
           --p_use_past_reading is not null  or
           p_tolerance_plus is not null or
           p_tolerance_minus is not null or
           p_estimation_id is not null then
             --ExitWithErrMsg('CSI_API_CTR_INV_PARM_CTR_TYPE','CTR_TYPE',p_counter_type);
             csi_ctr_gen_utility_pvt.ExitWithErrMsg
             ( p_msg_name     =>  'CSI_API_CTR_INV_PARM_CTR_TYPE',
               p_token1_name  =>  'CTR_TYPE',
               p_token1_val   =>  p_counter_type
             );
        end if;
      end if; --l_time_uom
   elsif p_counter_type = 'FORMULA' then
      if p_derive_function is null then
        if p_formula_text is null then
             csi_ctr_gen_utility_pvt.ExitWithErrMsg
             ( p_msg_name     =>  'CSI_API_CTR_REQ_PARM',
               p_token1_name  =>  'PARAM',
               p_token1_val   =>  'p_formula_text'
             );
        end if;
        IF NOT VALIDATE_FORMULA(p_formula_text) THEN
             csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_INV_FORMULA_TEXT');
        END IF;
        if p_derive_counter_id is not null or
           p_filter_type is not null or
           p_filter_reading_count is not null or
           p_filter_time_uom is not null or
           nvl(p_automatic_rollover,'N') = 'Y' or
           p_rollover_last_reading is not null or
           p_rollover_first_reading is not null or
           p_initial_reading is not null or
           p_tolerance_plus is not null or
           p_tolerance_minus is not null then
             csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_INV_PARM_CTR_TYPE','CTR_TYPE',p_counter_type);
        end if;
      elsif p_derive_function='AVERAGE' and p_filter_type='COUNT' then
        if p_filter_reading_count < 0 then
           csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_REQ_PARM','PARAM','p_filter_type');
        end if;
        if p_formula_text is not null or
           p_filter_time_uom is not null or
           nvl(p_automatic_rollover,'N') = 'Y' or
           p_rollover_last_reading is not null or
           p_rollover_first_reading is not null or
           -- nvl(p_used_in_scheduling,'N') = 'Y' or
           p_initial_reading is not null or
           -- p_default_usage_rate is not null or
           -- p_use_past_reading is not null  or
           p_estimation_id is not null or
           p_tolerance_plus is not null or
           p_tolerance_minus is not null then
           csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_INV_PARM_CTR_TYPE','CTR_TYPE',p_counter_type);
        end if;
      elsif p_derive_function='AVERAGE' and p_filter_type='TIME' then
        if p_filter_time_uom is null then
           csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_REQ_PARM','PARAM','p_filter_type');
        end if;
        if p_formula_text is not null or
           p_filter_reading_count is not null or
           nvl(p_automatic_rollover,'N') = 'Y' or
           p_rollover_last_reading is not null or
           p_rollover_first_reading is not null or
           --  nvl(p_used_in_scheduling,'N') = 'Y' or
           p_initial_reading is not null or
           -- p_default_usage_rate is not null or
           -- p_use_past_reading is not null  or
           p_estimation_id is not null or
           p_tolerance_plus is not null or
           p_tolerance_minus is not null then
           csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_INV_PARM_CTR_TYPE','CTR_TYPE',p_counter_type);
        end if;
      elsif p_derive_function in ('SUM','COUNT') then
        -- if p_derive_counter_id is null then
        --    csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_REQ_PARM','PARAM','p_derive_counter_id');
        -- end if;
        if p_formula_text is not null or
           p_filter_time_uom is not null or
           p_filter_reading_count is not null or
           nvl(p_automatic_rollover,'N') = 'Y' or
           p_rollover_last_reading is not null or
           p_rollover_first_reading is not null or
           -- nvl(p_used_in_scheduling,'N') = 'Y' or
           p_initial_reading is not null or
           -- p_default_usage_rate is not null or
           -- p_use_past_reading is not null  or
           p_estimation_id is not null or
           p_tolerance_plus is not null or
           p_tolerance_minus is not null then
           csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_INV_PARM_CTR_TYPE','CTR_TYPE',p_counter_type);
        end if;
      end if;
   end if; -- p_counter_type

END validate_counter;

--|---------------------------------------------------
--| procedure name: validate_data_type
--| description :   procedure used to
--|                 validate property datatype
--|---------------------------------------------------

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
		-- any value is okay becoz even if the values are numbers or dates
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
		csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_INV_PROP_DATA_TYPE');
	END IF;

EXCEPTION WHEN OTHERS THEN
	csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_INV_VAL_DATATYPE','DATA_TYPE',p_property_data_type);

END Validate_Data_Type;

--|---------------------------------------------------
--| procedure name: create_counter
--| description :   procedure used to
--|                 create counter instance
--|---------------------------------------------------

PROCEDURE create_counter
 (
     p_api_version	          IN	NUMBER
    ,p_init_msg_list	          IN	VARCHAR2
    ,p_commit		          IN	VARCHAR2
    ,p_validation_level	          IN	VARCHAR2
    ,p_counter_instance_rec	  IN	out	NOCOPY CSI_CTR_DATASTRUCTURES_PUB.Counter_instance_rec
    ,x_return_status               OUT NOCOPY VARCHAR2
    ,x_msg_count                   OUT NOCOPY NUMBER
    ,x_msg_data                    OUT NOCOPY VARCHAR2
    ,x_ctr_id		           OUT NOCOPY NUMBER
 )
 IS
    l_api_name                      CONSTANT VARCHAR2(30)   := 'CREATE_COUNTER';
    l_api_version                   CONSTANT NUMBER         := 1.0;
    -- l_debug_level                   NUMBER;
    l_flag                          VARCHAR2(1)             := 'N';
    l_msg_data                      VARCHAR2(2000);
    l_msg_index                     NUMBER;
    l_msg_count                     NUMBER;
    l_count                         NUMBER;
    l_return_message                VARCHAR2(100);

    l_counter_id                    NUMBER;
    l_group_id                      NUMBER;
    l_name                          VARCHAR2(80); --Increased size from 50 to 80 from bug 8448273
    l_description                   VARCHAR2(240);
    l_counter_type                  VARCHAR2(30);
    l_uom_code                      VARCHAR2(3);
    l_usage_item_id                 NUMBER;
    l_reading_type                  NUMBER;
    l_direction                     VARCHAR2(1);
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
    l_step_value                    NUMBER;
    l_time_based_manual_entry       VARCHAR2(1);
    l_eam_required_flag             VARCHAR2(1);

    l_dummy                         VARCHAR2(1);
    l_counter_groups_rec   CSI_CTR_DATASTRUCTURES_PUB.counter_groups_rec;
    l_ctr_group_id NUMBER;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  create_counter_pvt;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
   THEN
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

   -- Check the profile option debug_level for debug message reporting
   -- l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

   -- If debug_level = 1 then dump the procedure name
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'create_counter');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 1) THEN
      csi_ctr_gen_utility_pvt.put_line( 'create_counter'     ||
                                     p_api_version         ||'-'||
                                     p_commit              ||'-'||
                                     p_init_msg_list       ||'-'||
                                     p_validation_level );
      csi_ctr_gen_utility_pvt.dump_counter_instance_rec(p_counter_instance_rec);
   END IF;

   -- Start of API Body
   if p_counter_instance_rec.counter_id = FND_API.G_MISS_NUM then
       l_counter_id := null;
   else
       l_counter_id := p_counter_instance_rec.counter_id;
   end if;
   if p_counter_instance_rec.group_id = FND_API.G_MISS_NUM then
       l_group_id := null;
   else
       l_group_id := p_counter_instance_rec.group_id;
   end if;
   if p_counter_instance_rec.name = FND_API.G_MISS_CHAR then
      l_name := null;
   else
      l_name := p_counter_instance_rec.name;
   end if;
   if p_counter_instance_rec.description = FND_API.G_MISS_CHAR then
	      l_description := null;
	  else
       l_description := p_counter_instance_rec.description;
   end if;
   if p_counter_instance_rec.counter_type = FND_API.G_MISS_CHAR then
       l_counter_type := null;
	  else
       l_counter_type := p_counter_instance_rec.counter_type;
   end if;
   if p_counter_instance_rec.uom_code = FND_API.G_MISS_CHAR then
       l_uom_code := null;
	  else
       l_uom_code := p_counter_instance_rec.uom_code;
   end if;
   if p_counter_instance_rec.usage_item_id = FND_API.G_MISS_NUM then
       l_usage_item_id := null;
   else
       l_usage_item_id := p_counter_instance_rec.usage_item_id;
   end if;
   if p_counter_instance_rec.reading_type = FND_API.G_MISS_NUM then
       l_reading_type := null;
   else
       l_reading_type := p_counter_instance_rec.reading_type;
   end if;
   if p_counter_instance_rec.direction = FND_API.G_MISS_CHAR then
       l_direction := null;
	  else
       l_direction := p_counter_instance_rec.direction;
   end if;
   if p_counter_instance_rec.estimation_id = FND_API.G_MISS_NUM then
       l_estimation_id := null;
   else
       l_estimation_id := p_counter_instance_rec.estimation_id;
   end if;
   if p_counter_instance_rec.derive_function = FND_API.G_MISS_CHAR then
       l_derive_function := null;
	  else
       l_derive_function := p_counter_instance_rec.derive_function;
   end if;
   if p_counter_instance_rec.formula_text = FND_API.G_MISS_CHAR then
       l_formula_text := null;
	  else
       l_formula_text := p_counter_instance_rec.formula_text;
   end if;
   if p_counter_instance_rec.derive_counter_id = FND_API.G_MISS_NUM then
       l_derive_counter_id := null;
   else
       l_derive_counter_id := p_counter_instance_rec.derive_counter_id;
   end if;
   if p_counter_instance_rec.filter_type = FND_API.G_MISS_CHAR then
       l_filter_type := null;
	  else
       l_filter_type := p_counter_instance_rec.filter_type;
   end if;
   if p_counter_instance_rec.filter_reading_count = FND_API.G_MISS_NUM then
       l_filter_reading_count := null;
   else
       l_filter_reading_count := p_counter_instance_rec.filter_reading_count;
   end if;
   if p_counter_instance_rec.filter_time_uom = FND_API.G_MISS_CHAR then
       l_filter_time_uom := null;
	  else
       l_filter_time_uom := p_counter_instance_rec.filter_time_uom;
   end if;
   if p_counter_instance_rec.automatic_rollover = FND_API.G_MISS_CHAR then
       l_automatic_rollover := null;
	  else
       l_automatic_rollover := p_counter_instance_rec.automatic_rollover;
   end if;
   if p_counter_instance_rec.rollover_last_reading = FND_API.G_MISS_NUM then
       l_rollover_last_reading := null;
   else
       l_rollover_last_reading := p_counter_instance_rec.rollover_last_reading;
   end if;
   if p_counter_instance_rec.rollover_first_reading = FND_API.G_MISS_NUM then
       l_rollover_first_reading := null;
   else
       l_rollover_first_reading := p_counter_instance_rec.rollover_first_reading;
   end if;
   if p_counter_instance_rec.tolerance_plus = FND_API.G_MISS_NUM then
       l_tolerance_plus := null;
   else
       l_tolerance_plus := p_counter_instance_rec.tolerance_plus;
   end if;
   if p_counter_instance_rec.tolerance_minus = FND_API.G_MISS_NUM then
       l_tolerance_minus := null;
   else
       l_tolerance_minus := p_counter_instance_rec.tolerance_minus;
   end if;
   if p_counter_instance_rec.used_in_scheduling = FND_API.G_MISS_CHAR then
       l_used_in_scheduling := null;
	  else
       l_used_in_scheduling := p_counter_instance_rec.used_in_scheduling;
   end if;
   if p_counter_instance_rec.initial_reading = FND_API.G_MISS_NUM then
       l_initial_reading := null;
   else
       l_initial_reading := p_counter_instance_rec.initial_reading;
   end if;
   if p_counter_instance_rec.default_usage_rate = FND_API.G_MISS_NUM then
       l_default_usage_rate := null;
   else
       l_default_usage_rate := p_counter_instance_rec.default_usage_rate;
   end if;
   if p_counter_instance_rec.use_past_reading = FND_API.G_MISS_NUM then
       l_use_past_reading := null;
   else
       l_use_past_reading := p_counter_instance_rec.use_past_reading;
   end if;
   if p_counter_instance_rec.start_date_active = FND_API.G_MISS_DATE then
       l_start_date_active := sysdate;
   else
       l_start_date_active := p_counter_instance_rec.start_date_active;
   end if;
   if p_counter_instance_rec.end_date_active = FND_API.G_MISS_DATE then
       l_end_date_active := null;
   else
       l_end_date_active := p_counter_instance_rec.end_date_active;
   end if;
   if p_counter_instance_rec.defaulted_group_id = FND_API.G_MISS_NUM then
       l_defaulted_group_id := null;
   else
       l_defaulted_group_id := p_counter_instance_rec.defaulted_group_id;
   end if;
   if p_counter_instance_rec.created_from_counter_tmpl_id = FND_API.G_MISS_NUM then
       l_created_from_counter_tmpl_id := null;
   else
       l_created_from_counter_tmpl_id := p_counter_instance_rec.created_from_counter_tmpl_id;
   end if;
   if p_counter_instance_rec.attribute1 = FND_API.G_MISS_CHAR then
       l_attribute1 := null;
   else
       l_attribute1 := p_counter_instance_rec.attribute1;
   end if;
   if p_counter_instance_rec.attribute2 = FND_API.G_MISS_CHAR then
       l_attribute2 := null;
   else
       l_attribute2 := p_counter_instance_rec.attribute2;
   end if;
   if p_counter_instance_rec.attribute3 = FND_API.G_MISS_CHAR then
       l_attribute3 := null;
   else
       l_attribute3 := p_counter_instance_rec.attribute3;
   end if;
   if p_counter_instance_rec.attribute4 = FND_API.G_MISS_CHAR then
       l_attribute4 := null;
   else
       l_attribute4 := p_counter_instance_rec.attribute4;
   end if;
   if p_counter_instance_rec.attribute5 = FND_API.G_MISS_CHAR then
       l_attribute5 := null;
   else
       l_attribute5 := p_counter_instance_rec.attribute5;
   end if;
   if p_counter_instance_rec.attribute6 = FND_API.G_MISS_CHAR then
       l_attribute6 := null;
   else
       l_attribute6 := p_counter_instance_rec.attribute6;
   end if;
   if p_counter_instance_rec.attribute7 = FND_API.G_MISS_CHAR then
      l_attribute7 := null;
   else
       l_attribute7 := p_counter_instance_rec.attribute7;
   end if;
   if p_counter_instance_rec.attribute8 = FND_API.G_MISS_CHAR then
      l_attribute8 := null;
   else
      l_attribute8 := p_counter_instance_rec.attribute8;
   end if;
   if p_counter_instance_rec.attribute9 = FND_API.G_MISS_CHAR then
      l_attribute9 := null;
   else
       l_attribute9 := p_counter_instance_rec.attribute9;
    end if;
   if p_counter_instance_rec.attribute10 = FND_API.G_MISS_CHAR then
      l_attribute10 := null;
   else
      l_attribute10 := p_counter_instance_rec.attribute10;
   end if;
   if p_counter_instance_rec.attribute11 = FND_API.G_MISS_CHAR then
      l_attribute11 := null;
   else
      l_attribute11 := p_counter_instance_rec.attribute11;
   end if;
   if p_counter_instance_rec.attribute12 = FND_API.G_MISS_CHAR then
      l_attribute12 := null;
   else
      l_attribute12 := p_counter_instance_rec.attribute12;
   end if;
   if p_counter_instance_rec.attribute13 = FND_API.G_MISS_CHAR then
      l_attribute13 := null;
   else
      l_attribute13 := p_counter_instance_rec.attribute13;
   end if;
   if p_counter_instance_rec.attribute14 = FND_API.G_MISS_CHAR then
      l_attribute14 := null;
   else
      l_attribute14 := p_counter_instance_rec.attribute14;
   end if;
   if p_counter_instance_rec.attribute15 = FND_API.G_MISS_CHAR then
      l_attribute15 := null;
   else
      l_attribute15 := p_counter_instance_rec.attribute15;
   end if;
   if p_counter_instance_rec.attribute16 = FND_API.G_MISS_CHAR then
       l_attribute16 := null;
   else
       l_attribute16 := p_counter_instance_rec.attribute16;
   end if;
   if p_counter_instance_rec.attribute17 = FND_API.G_MISS_CHAR then
      l_attribute17 := null;
   else
       l_attribute17 := p_counter_instance_rec.attribute17;
   end if;
   if p_counter_instance_rec.attribute18 = FND_API.G_MISS_CHAR then
      l_attribute18 := null;
   else
      l_attribute18 := p_counter_instance_rec.attribute18;
   end if;
   if p_counter_instance_rec.attribute19 = FND_API.G_MISS_CHAR then
      l_attribute19 := null;
   else
       l_attribute19 := p_counter_instance_rec.attribute19;
    end if;
   if p_counter_instance_rec.attribute20 = FND_API.G_MISS_CHAR then
      l_attribute20 := null;
   else
      l_attribute20 := p_counter_instance_rec.attribute20;
   end if;
   if p_counter_instance_rec.attribute21 = FND_API.G_MISS_CHAR then
       l_attribute21 := null;
   else
       l_attribute21 := p_counter_instance_rec.attribute21;
   end if;
   if p_counter_instance_rec.attribute22 = FND_API.G_MISS_CHAR then
       l_attribute22 := null;
   else
       l_attribute22 := p_counter_instance_rec.attribute22;
   end if;
   if p_counter_instance_rec.attribute23 = FND_API.G_MISS_CHAR then
       l_attribute23 := null;
   else
       l_attribute23 := p_counter_instance_rec.attribute23;
   end if;
   if p_counter_instance_rec.attribute24 = FND_API.G_MISS_CHAR then
       l_attribute24 := null;
   else
       l_attribute24 := p_counter_instance_rec.attribute24;
   end if;
   if p_counter_instance_rec.attribute25 = FND_API.G_MISS_CHAR then
       l_attribute25 := null;
   else
       l_attribute25 := p_counter_instance_rec.attribute25;
   end if;
   if p_counter_instance_rec.attribute26 = FND_API.G_MISS_CHAR then
       l_attribute26 := null;
   else
       l_attribute26 := p_counter_instance_rec.attribute26;
   end if;
   if p_counter_instance_rec.attribute27 = FND_API.G_MISS_CHAR then
      l_attribute27 := null;
   else
       l_attribute27 := p_counter_instance_rec.attribute27;
   end if;
   if p_counter_instance_rec.attribute28 = FND_API.G_MISS_CHAR then
      l_attribute28 := null;
   else
      l_attribute28 := p_counter_instance_rec.attribute28;
   end if;
   if p_counter_instance_rec.attribute29 = FND_API.G_MISS_CHAR then
      l_attribute29 := null;
   else
       l_attribute29 := p_counter_instance_rec.attribute29;
    end if;
   if p_counter_instance_rec.attribute30 = FND_API.G_MISS_CHAR then
      l_attribute30 := null;
   else
      l_attribute30 := p_counter_instance_rec.attribute30;
   end if;
   if p_counter_instance_rec.attribute_category = FND_API.G_MISS_CHAR then
      l_attribute_category := null;
   else
      l_attribute_category := p_counter_instance_rec.attribute_category;
   end if;
   if p_counter_instance_rec.step_value = FND_API.G_MISS_NUM then
       l_step_value := null;
   else
       l_step_value := p_counter_instance_rec.step_value;
   end if;

   if p_counter_instance_rec.time_based_manual_entry = FND_API.G_MISS_CHAR then
       l_time_based_manual_entry := 'N';
   else
       l_time_based_manual_entry := p_counter_instance_rec.time_based_manual_entry;
   end if;

   if p_counter_instance_rec.eam_required_flag = FND_API.G_MISS_CHAR then
       l_eam_required_flag := null;
   else
       l_eam_required_flag := p_counter_instance_rec.eam_required_flag;
   end if;

   -- Validate counter name is unique
   --Validate_Unique_ctr(l_name, l_counter_id);
   -- Validate start date
   /*
   IF l_start_date_active IS NULL THEN
      CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_STDATE_INVALID');
   ELS */
   IF l_start_date_active > sysdate THEN
      CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INVALID_START_DATE');
   END IF;

   if nvl(p_counter_instance_rec.initial_reading_date, FND_API.G_MISS_DATE) = FND_API.G_MISS_DATE then
      l_initial_reading_date := sysdate;
   else
      l_initial_reading_date := p_counter_instance_rec.initial_reading_date;
   end if;


   if l_created_from_counter_tmpl_id is not null then
      begin
       select 'x'
       into l_dummy
       from csi_counter_template_b
       where counter_id = l_created_from_counter_tmpl_id;
     exception when no_data_found then
       csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_TMPL_INVALID');
     end;
  end if;

   --call validate counter to validate the counter instance
   validate_counter(l_group_id, l_name, l_counter_type, l_uom_code, l_usage_item_id,
                    l_reading_type, l_direction, l_estimation_id, l_derive_function,
                    l_formula_text, l_derive_counter_id, l_filter_type, l_filter_reading_count,
                    l_filter_time_uom, l_automatic_rollover, l_rollover_last_reading,
                    l_rollover_first_reading, l_tolerance_plus, l_tolerance_minus,
                    l_used_in_scheduling, l_initial_reading, l_default_usage_rate,
                    l_use_past_reading, -1, l_start_date_active, l_end_date_active
                   );

  -- Check and Generate Counter_value_id
  IF l_counter_id IS NULL OR l_counter_id = FND_API.G_MISS_NUM THEN
      select CSI_COUNTERS_B_S.nextval
      into l_counter_id from dual;
  END IF;
  -- counter name suffix counter id is created from template or if duplicate exist.
  if l_created_from_counter_tmpl_id is not null then
     l_name := l_name||'-'||l_counter_id;
  else
     if counter_name_exists(l_name, l_counter_id) then
       l_name := l_name||'-'||l_counter_id;
     end if;
  end if;

  -- if counter group id is null, generate the defaulted group id
  if l_group_id is null and l_defaulted_group_id is null then
    l_counter_groups_rec.NAME  :=  l_name||'-Group';
    l_counter_groups_rec.DESCRIPTION   := l_name||'-Group';
    IF l_counter_groups_rec.ASSOCIATION_TYPE is NULL THEN
       l_counter_groups_rec.ASSOCIATION_TYPE := 'TRACKABLE';
    END IF;

    SELECT CS_COUNTER_GROUPS_S.nextval
    INTO l_ctr_group_id FROM dual;

    csi_Counter_template_pvt.create_counter_group
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
    IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
        ROLLBACK TO create_counter_pvt;
        RETURN;
   END IF;
   l_defaulted_group_id := l_counter_groups_rec.counter_group_id;
  end if;

  IF l_defaulted_group_id IS NULL and l_group_id IS NOT NULL THEN
     l_defaulted_group_id := l_group_id;
  END IF;

  --
  csi_ctr_gen_utility_pvt.put_line('Inserting Counter with Value ID  '||to_char(l_counter_id));
  -- call table handler here
   CSI_COUNTERS_PKG.Insert_Row
   (
    px_COUNTER_ID	              => l_counter_id
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
   ,p_VALID_FLAG                => null
   ,p_FORMULA_INCOMPLETE_FLAG   => l_formula_incomplete_flag
   ,p_FORMULA_TEXT              => l_formula_text
   ,p_ROLLOVER_LAST_READING     => l_rollover_last_reading
   ,p_ROLLOVER_FIRST_READING	   => l_rollover_first_reading
   ,p_USAGE_ITEM_ID             => l_usage_item_id
   ,p_CTR_VAL_MAX_SEQ_NO        => 0
   ,p_START_DATE_ACTIVE         => l_start_date_active
   ,p_END_DATE_ACTIVE           => l_end_date_active
   ,p_OBJECT_VERSION_NUMBER     => 1
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
   ,p_ATTRIBUTE21                => l_attribute21
   ,p_ATTRIBUTE22                => l_attribute22
   ,p_ATTRIBUTE23                => l_attribute23
   ,p_ATTRIBUTE24                => l_attribute24
   ,p_ATTRIBUTE25                => l_attribute25
   ,p_ATTRIBUTE26                => l_attribute26
   ,p_ATTRIBUTE27                => l_attribute27
   ,p_ATTRIBUTE28                => l_attribute28
   ,p_ATTRIBUTE29                => l_attribute29
   ,p_ATTRIBUTE30               => l_attribute30
   ,p_ATTRIBUTE_CATEGORY        => l_attribute_category
   ,p_MIGRATED_FLAG             => null
   ,p_CUSTOMER_VIEW             => null
   ,p_DIRECTION                 => l_direction
   ,p_FILTER_TYPE               => l_filter_type
   ,p_FILTER_READING_COUNT      => l_filter_reading_count
   ,p_FILTER_TIME_UOM           => l_filter_time_uom
   ,p_ESTIMATION_ID             => l_estimation_id
   --,p_COUNTER_CODE              => l_name||'-'||l_counter_id
   ,p_READING_TYPE              => l_reading_type
   ,p_AUTOMATIC_ROLLOVER        => l_automatic_rollover
   ,p_DEFAULT_USAGE_RATE        => l_default_usage_rate
   ,p_USE_PAST_READING          => l_use_past_reading
   ,p_USED_IN_SCHEDULING        => l_used_in_scheduling
   ,p_DEFAULTED_GROUP_ID        => l_defaulted_group_id
   ,p_CREATED_FROM_COUNTER_TMPL_ID  => l_created_from_counter_tmpl_id
   ,p_SECURITY_GROUP_ID         => NULL
   ,p_STEP_VALUE                => l_step_value
   --,p_NAME	                     => l_name||'-'||l_counter_id
   ,p_NAME	                     => l_name
   ,p_DESCRIPTION               => l_description
   ,p_TIME_BASED_MANUAL_ENTRY   => l_time_based_manual_entry
   ,p_EAM_REQUIRED_FLAG         => l_eam_required_flag
   ,p_comments                  => NULL
   );
   IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
        ROLLBACK TO create_counter_pvt;
        RETURN;
   END IF;
   x_ctr_id := l_counter_id;
    -- End of API body

    -- Standard check of p_commit.
    IF FND_API.To_Boolean(nvl(p_commit,FND_API.G_FALSE)) THEN
       COMMIT WORK;
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO create_counter_pvt;
      FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count,
                 p_data  => x_msg_data
                );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_counter_pvt;
      FND_MSG_PUB.Count_And_Get
      		(p_count => x_msg_count,
                 p_data  => x_msg_data
                );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_counter_pvt;
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

END create_counter;

--|---------------------------------------------------
--| procedure name: create_ctr_property
--| description :   procedure used to
--|                 create counter properties
--|---------------------------------------------------

PROCEDURE create_ctr_property
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_ctr_properties_rec	 IN out	NOCOPY CSI_CTR_DATASTRUCTURES_PUB.Ctr_Properties_Rec
    ,x_return_status                OUT    NOCOPY VARCHAR2
    ,x_msg_count                    OUT    NOCOPY NUMBER
    ,x_msg_data                     OUT    NOCOPY VARCHAR2
    ,x_ctr_property_id	            OUT    NOCOPY NUMBER
 )
  IS
    l_api_name                      CONSTANT VARCHAR2(30)   := 'CREATE_CTR_PROPERTY';
    l_api_version                   CONSTANT NUMBER         := 1.0;
    -- l_debug_level                   NUMBER;
    l_flag                          VARCHAR2(1)             := 'N';
    l_msg_data                      VARCHAR2(2000);
    l_msg_index                     NUMBER;
    l_msg_count                     NUMBER;
    l_count                         NUMBER;
    l_return_message                VARCHAR2(100);

    l_counter_property_id           NUMBER;
    l_counter_id                    NUMBER;
    l_name                          VARCHAR2(50);
    l_description                   VARCHAR2(240);
    l_property_data_type            VARCHAR2(30);
    l_is_nullable                   VARCHAR2(1);
    l_uom_code                      VARCHAR2(3);
    l_property_lov_type             VARCHAR2(30);
    l_default_value                 VARCHAR2(240);
    l_minimum_value                 VARCHAR2(240);
    l_maximum_value                 VARCHAR2(240);
    l_start_date_active             DATE;
    l_end_date_active               DATE;
    l_created_from_ctrprop_tmpl_id  NUMBER;
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
    l_attribute_category            VARCHAR2(30);

    l_dummy	                        VARCHAR2(1);
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  create_ctr_property_pvt;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
   THEN
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

   -- Check the profile option debug_level for debug message reporting
   -- l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

   -- If debug_level = 1 then dump the procedure name
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'create_ctr_property');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 1) THEN
      csi_ctr_gen_utility_pvt.put_line( 'create_ctr_property'       ||
                                     p_api_version         ||'-'||
                                     p_commit              ||'-'||
                                     p_init_msg_list       ||'-'||
                                     p_validation_level );
      csi_ctr_gen_utility_pvt.dump_ctr_properties_rec(p_ctr_properties_rec);
   END IF;

   -- Start of API Body
   if p_ctr_properties_rec.counter_id = FND_API.G_MISS_NUM then
       l_counter_id := null;
   else
       l_counter_id := p_ctr_properties_rec.counter_id;
   end if;
   if p_ctr_properties_rec.name = FND_API.G_MISS_CHAR then
	      l_name := null;
	  else
       l_name := p_ctr_properties_rec.name;
   end if;
   if p_ctr_properties_rec.description = FND_API.G_MISS_CHAR then
	      l_description := null;
	  else
       l_description := p_ctr_properties_rec.description;
   end if;
   if p_ctr_properties_rec.property_data_type = FND_API.G_MISS_CHAR then
       l_property_data_type := null;
	  else
       l_property_data_type := p_ctr_properties_rec.property_data_type;
   end if;
   if p_ctr_properties_rec.is_nullable = FND_API.G_MISS_CHAR then
       l_is_nullable := null;
	  else
       l_is_nullable := p_ctr_properties_rec.is_nullable;
       if l_is_nullable not in ('Y', 'N') then
           l_is_nullable := 'N';
       end if;
   end if;
   if p_ctr_properties_rec.uom_code = FND_API.G_MISS_CHAR then
       l_uom_code := null;
	  else
       l_uom_code := p_ctr_properties_rec.uom_code;
   end if;
   if p_ctr_properties_rec.property_lov_type = FND_API.G_MISS_CHAR then
       l_property_lov_type := null;
	  else
       l_property_lov_type := p_ctr_properties_rec.property_lov_type;
   end if;
   if p_ctr_properties_rec.default_value = FND_API.G_MISS_CHAR then
       l_default_value := null;
	  else
       l_default_value := p_ctr_properties_rec.default_value;
   end if;
   if p_ctr_properties_rec.minimum_value = FND_API.G_MISS_CHAR then
       l_minimum_value := null;
	  else
       l_minimum_value := p_ctr_properties_rec.minimum_value;
   end if;
   if p_ctr_properties_rec.maximum_value = FND_API.G_MISS_CHAR then
       l_maximum_value := null;
	  else
       l_maximum_value := p_ctr_properties_rec.maximum_value;
   end if;
   if p_ctr_properties_rec.start_date_active = FND_API.G_MISS_DATE then
       l_start_date_active := sysdate;
	  else
       l_start_date_active := p_ctr_properties_rec.start_date_active;
   end if;
   if p_ctr_properties_rec.end_date_active = FND_API.G_MISS_DATE then
       l_end_date_active := null;
	  else
       l_end_date_active := p_ctr_properties_rec.end_date_active;
   end if;
   if p_ctr_properties_rec.created_from_ctr_prop_tmpl_id = FND_API.G_MISS_NUM then
       l_created_from_ctrprop_tmpl_id := null;
	  else
       l_created_from_ctrprop_tmpl_id := p_ctr_properties_rec.created_from_ctr_prop_tmpl_id;
   end if;
   if p_ctr_properties_rec.attribute1 = FND_API.G_MISS_CHAR then
	      l_attribute1 := null;
	  else
       l_attribute1 := p_ctr_properties_rec.attribute1;
   end if;
   if p_ctr_properties_rec.attribute2 = FND_API.G_MISS_CHAR then
	      l_attribute2 := null;
	  else
       l_attribute2 := p_ctr_properties_rec.attribute2;
   end if;
   if p_ctr_properties_rec.attribute3 = FND_API.G_MISS_CHAR then
	      l_attribute3 := null;
	  else
       l_attribute3 := p_ctr_properties_rec.attribute3;
   end if;
   if p_ctr_properties_rec.attribute4 = FND_API.G_MISS_CHAR then
	      l_attribute4 := null;
	  else
       l_attribute4 := p_ctr_properties_rec.attribute4;
   end if;
   if p_ctr_properties_rec.attribute5 = FND_API.G_MISS_CHAR then
	      l_attribute5 := null;
	  else
       l_attribute5 := p_ctr_properties_rec.attribute5;
   end if;
   if p_ctr_properties_rec.attribute6 = FND_API.G_MISS_CHAR then
	      l_attribute6 := null;
	  else
       l_attribute6 := p_ctr_properties_rec.attribute6;
   end if;
   if p_ctr_properties_rec.attribute7 = FND_API.G_MISS_CHAR then
	      l_attribute7 := null;
	  else
       l_attribute7 := p_ctr_properties_rec.attribute7;
   end if;
   if p_ctr_properties_rec.attribute8 = FND_API.G_MISS_CHAR then
	      l_attribute8 := null;
	  else
       l_attribute8 := p_ctr_properties_rec.attribute8;
   end if;
   if p_ctr_properties_rec.attribute9 = FND_API.G_MISS_CHAR then
	      l_attribute9 := null;
	  else
       l_attribute9 := p_ctr_properties_rec.attribute9;
   end if;
   if p_ctr_properties_rec.attribute10 = FND_API.G_MISS_CHAR then
	      l_attribute10 := null;
	  else
       l_attribute10 := p_ctr_properties_rec.attribute10;
   end if;
   if p_ctr_properties_rec.attribute11 = FND_API.G_MISS_CHAR then
	      l_attribute11 := null;
	  else
       l_attribute11 := p_ctr_properties_rec.attribute11;
   end if;
   if p_ctr_properties_rec.attribute12 = FND_API.G_MISS_CHAR then
	      l_attribute12 := null;
	  else
       l_attribute12 := p_ctr_properties_rec.attribute12;
   end if;
   if p_ctr_properties_rec.attribute13 = FND_API.G_MISS_CHAR then
	      l_attribute13 := null;
	  else
       l_attribute13 := p_ctr_properties_rec.attribute13;
   end if;
   if p_ctr_properties_rec.attribute14 = FND_API.G_MISS_CHAR then
	      l_attribute14 := null;
	  else
       l_attribute14 := p_ctr_properties_rec.attribute14;
   end if;
   if p_ctr_properties_rec.attribute15 = FND_API.G_MISS_CHAR then
	      l_attribute15 := null;
	  else
       l_attribute15 := p_ctr_properties_rec.attribute15;
   end if;
   if p_ctr_properties_rec.attribute_category = FND_API.G_MISS_CHAR then
	      l_attribute_category := null;
	  else
       l_attribute_category := p_ctr_properties_rec.attribute_category;
   end if;

   --Validate Counter Id
   begin
     select 'x'
     into l_dummy
     from csi_counters_b
     where counter_id = l_counter_id;
   exception when no_data_found then
     csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_INVALID');
   end;

   -- validate unique property name within counter
   Validate_Unique_ctrprop(	l_name, l_counter_id,p_ctr_properties_rec.counter_property_id);

   -- validate property date type in char,number,date
   if l_property_data_type not in ('CHAR', 'NUMBER', 'DATE') then
       csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_INV_PROP_DATA_TYPE');
   end if;

   -- Validate values for data type
   Validate_Data_Type(l_property_data_type, l_default_value,
                      l_minimum_value, l_maximum_value);

   -- Validate uom
   if l_uom_code is not null then
	     Validate_UOM(l_uom_code);
   end if;

   -- Validate start date
   /*
   IF l_start_date_active IS NULL THEN
      CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_STDATE_INVALID');
   ELS */
   IF l_start_date_active > sysdate THEN
      CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INVALID_START_DATE');
   END IF;

   if l_created_from_ctrprop_tmpl_id is not null then
     begin
       select 'x'
       into l_dummy
       from csi_counter_template_b c, csi_ctr_property_template_b p
       where p.counter_id = c.counter_id
       and   p.counter_property_id = l_created_from_ctrprop_tmpl_id;
     exception when no_data_found then
       csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_PROP_TMPL_INVALID');
     end;
   end if;

   -- call table handler here

   CSI_COUNTER_PROPERTIES_PKG.INSERT_ROW
   (
     px_COUNTER_PROPERTY_ID       => l_counter_property_id
     ,p_COUNTER_ID                => l_counter_id
     ,p_PROPERTY_DATA_TYPE        => l_property_data_type
     ,p_IS_NULLABLE               => l_is_nullable
     ,p_DEFAULT_VALUE             => l_default_value
     ,p_MINIMUM_VALUE             => l_minimum_value
     ,p_MAXIMUM_VALUE             => l_maximum_value
     ,p_UOM_CODE                  => l_uom_code
     ,p_START_DATE_ACTIVE         => l_start_date_active
     ,p_END_DATE_ACTIVE           => l_end_date_active
     ,p_OBJECT_VERSION_NUMBER     => 1
     ,p_SECURITY_GROUP_ID         => null
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
     ,p_ATTRIBUTE_CATEGORY        => l_attribute_category
     ,p_MIGRATED_FLAG             => null
     ,p_PROPERTY_LOV_TYPE         => l_property_lov_type
     ,p_NAME	                     => l_name
     ,p_DESCRIPTION               => l_description
     ,p_create_from_ctr_prop_tmpl_id => l_created_from_ctrprop_tmpl_id
   );
   IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
        ROLLBACK TO create_ctr_property_pvt;
        RETURN;
   END IF;

    -- End of API body

    -- Standard check of p_commit.
    IF FND_API.To_Boolean(nvl(p_commit,FND_API.G_FALSE)) THEN
       COMMIT WORK;
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO create_ctr_property_pvt;
      FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count,
                 p_data  => x_msg_data
                );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_ctr_property_pvt;
      FND_MSG_PUB.Count_And_Get
      		(p_count => x_msg_count,
                 p_data  => x_msg_data
                );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_ctr_property_pvt;
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
END create_ctr_property;

--|---------------------------------------------------
--| procedure name: create_ctr_associations
--| description :   procedure used to
--|                 create counter associations
--|---------------------------------------------------

PROCEDURE create_ctr_associations
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,P_counter_associations_rec  IN out	NOCOPY CSI_CTR_DATASTRUCTURES_PUB.counter_associations_rec
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,x_instance_association_id      OUT	NOCOPY NUMBER
 )
 IS
    l_api_name                      CONSTANT VARCHAR2(30)   := 'CREATE_CTR_ASSOCIATIONS';
    l_api_version                   CONSTANT NUMBER         := 1.0;
    -- l_debug_level                   NUMBER;
    l_flag                          VARCHAR2(1)             := 'N';
    l_msg_data                      VARCHAR2(2000);
    l_msg_index                     NUMBER;
    l_msg_count                     NUMBER;
    l_count                         NUMBER;
    l_return_message                VARCHAR2(100);

    l_instance_association_id       NUMBER;
    l_source_object_code            VARCHAR2(30);
    l_source_object_id              NUMBER;
    l_counter_id                    NUMBER;
    l_maint_organization_id         NUMBER;
    l_start_date_active             DATE;
    l_end_date_active               DATE;
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
    l_attribute_category            VARCHAR2(30);
    l_instance_number               VARCHAR2(30);
    l_primary_failure_flag          VARCHAR2(1);
    l_dummy	                    VARCHAR2(1);
    l_is_association_exist          VARCHAR2(1);
    l_maint_organization_i          NUMBER;
    l_cp_inventory_id               NUMBER;
    l_cp_last_vld_org               NUMBER;
    l_eam_item_type                 NUMBER;

    CURSOR association_exist(p_ctr_id number, p_src_obj_id number) IS
    select 'X'
    from   csi_counter_associations
    where  counter_id = p_ctr_id
    and    source_object_id = p_src_obj_id;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  create_ctr_associations_pvt;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
   THEN
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

   -- Check the profile option debug_level for debug message reporting
   -- l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

   -- If debug_level = 1 then dump the procedure name
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'create_ctr_associations');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 1) THEN
      csi_ctr_gen_utility_pvt.put_line( 'create_ctr_associations'     ||
                                     p_api_version         ||'-'||
                                     p_commit              ||'-'||
                                     p_init_msg_list       ||'-'||
                                     p_validation_level );
      csi_ctr_gen_utility_pvt.dump_counter_associations_rec(p_counter_associations_rec);
   END IF;

   -- Start of API Body

   if P_counter_associations_rec.source_object_code = FND_API.G_MISS_CHAR then
      l_source_object_code := null;
   else
       l_source_object_code := P_counter_associations_rec.source_object_code;
   end if;
   if P_counter_associations_rec.source_object_id = FND_API.G_MISS_NUM then
       l_source_object_id := null;
   else
       l_source_object_id := P_counter_associations_rec.source_object_id;
   end if;
   if P_counter_associations_rec.counter_id = FND_API.G_MISS_NUM then
       l_counter_id := null;
   else
       l_counter_id := P_counter_associations_rec.counter_id;
   end if;
   if P_counter_associations_rec.start_date_active = FND_API.G_MISS_DATE then
       l_start_date_active := sysdate;
   else
       l_start_date_active := P_counter_associations_rec.start_date_active;
   end if;
   if P_counter_associations_rec.end_date_active = FND_API.G_MISS_DATE then
       l_end_date_active := null;
   else
       l_end_date_active := P_counter_associations_rec.end_date_active;
   end if;
   if p_counter_associations_rec.attribute1 = FND_API.G_MISS_CHAR then
	      l_attribute1 := null;
	  else
       l_attribute1 := p_counter_associations_rec.attribute1;
   end if;
   if p_counter_associations_rec.attribute2 = FND_API.G_MISS_CHAR then
	      l_attribute2 := null;
	  else
       l_attribute2 := p_counter_associations_rec.attribute2;
   end if;
   if p_counter_associations_rec.attribute3 = FND_API.G_MISS_CHAR then
	      l_attribute3 := null;
	  else
       l_attribute3 := p_counter_associations_rec.attribute3;
   end if;
   if p_counter_associations_rec.attribute4 = FND_API.G_MISS_CHAR then
	      l_attribute4 := null;
	  else
       l_attribute4 := p_counter_associations_rec.attribute4;
   end if;
   if p_counter_associations_rec.attribute5 = FND_API.G_MISS_CHAR then
	      l_attribute5 := null;
	  else
       l_attribute5 := p_counter_associations_rec.attribute5;
   end if;
   if p_counter_associations_rec.attribute6 = FND_API.G_MISS_CHAR then
	      l_attribute6 := null;
	  else
       l_attribute6 := p_counter_associations_rec.attribute6;
   end if;
   if p_counter_associations_rec.attribute7 = FND_API.G_MISS_CHAR then
	      l_attribute7 := null;
	  else
       l_attribute7 := p_counter_associations_rec.attribute7;
   end if;
   if p_counter_associations_rec.attribute8 = FND_API.G_MISS_CHAR then
	      l_attribute8 := null;
	  else
       l_attribute8 := p_counter_associations_rec.attribute8;
   end if;
   if p_counter_associations_rec.attribute9 = FND_API.G_MISS_CHAR then
	      l_attribute9 := null;
	  else
       l_attribute9 := p_counter_associations_rec.attribute9;
   end if;
   if p_counter_associations_rec.attribute10 = FND_API.G_MISS_CHAR then
	      l_attribute10 := null;
	  else
       l_attribute10 := p_counter_associations_rec.attribute10;
   end if;
   if p_counter_associations_rec.attribute11 = FND_API.G_MISS_CHAR then
	      l_attribute11 := null;
	  else
       l_attribute11 := p_counter_associations_rec.attribute11;
   end if;
   if p_counter_associations_rec.attribute12 = FND_API.G_MISS_CHAR then
	      l_attribute12 := null;
	  else
       l_attribute12 := p_counter_associations_rec.attribute12;
   end if;
   if p_counter_associations_rec.attribute13 = FND_API.G_MISS_CHAR then
	      l_attribute13 := null;
	  else
       l_attribute13 := p_counter_associations_rec.attribute13;
   end if;
   if p_counter_associations_rec.attribute14 = FND_API.G_MISS_CHAR then
	      l_attribute14 := null;
	  else
       l_attribute14 := p_counter_associations_rec.attribute14;
   end if;
   if p_counter_associations_rec.attribute15 = FND_API.G_MISS_CHAR then
	      l_attribute15 := null;
	  else
       l_attribute15 := p_counter_associations_rec.attribute15;
   end if;
   if p_counter_associations_rec.attribute_category = FND_API.G_MISS_CHAR then
	      l_attribute_category := null;
	  else
       l_attribute_category := p_counter_associations_rec.attribute_category;
   end if;

   if p_counter_associations_rec.maint_organization_id = FND_API.G_MISS_NUM then
      l_maint_organization_id := null;
   else
      l_maint_organization_id := p_counter_associations_rec.maint_organization_id;
   end if;

   if p_counter_associations_rec.primary_failure_flag = FND_API.G_MISS_CHAR then
      l_primary_failure_flag := null;
   else
      l_primary_failure_flag := p_counter_associations_rec.primary_failure_flag;
   end if;

   --Validate Counter Id
   begin
     select 'x'
     into l_dummy
     from csi_counters_b
     where counter_id = l_counter_id;
   exception when no_data_found then
     csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_INVALID');
   end;

   if l_source_object_code = 'CP' then
      begin
         select inventory_item_id, last_vld_organization_id, instance_number
         into   l_cp_inventory_id, l_cp_last_vld_org, l_instance_number
         from   csi_item_instances
         where  instance_id = l_source_object_id;
      exception
         when no_data_found then
            csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_IB_CPID_INVALID', 'PARAM', to_char(l_source_object_id));
     end;
   elsif l_source_object_code = 'CONTRACT_LINE' then
      begin
         select 'x'
         into   l_dummy
         from   okc_k_lines_b
         where id = l_source_object_id;
      exception when no_data_found then
         csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_INV_CONTRACT_LINE', 'PARAM', to_char(l_source_object_id));
      end;
   else
      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_INV_SRC_OBJ_CD','SRC_OBJ_CODE',l_source_object_code);
   end if;

   /* Check if it is an EAM item to get the maint_organization_id */
   BEGIN
      SELECT eam_item_type
      INTO   l_eam_item_type
      FROM   mtl_system_items_b
      WHERE  inventory_item_id = l_cp_inventory_id
      AND    organization_id = l_cp_last_vld_org;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_eam_item_type := 0;
      WHEN TOO_MANY_ROWS THEN
         l_eam_item_type := 1;
   END;

   IF l_eam_item_type = 1 or l_eam_item_type = 3 THEN
      BEGIN
         SELECT maint_organization_id
         INTO   l_maint_organization_id
         FROM   mtl_parameters
         WHERE  organization_id = l_cp_last_vld_org;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;
   END IF;
   /* End of checking*/
   csi_ctr_gen_utility_pvt.put_line( ' EAM Item Type = '||to_char(l_eam_item_type));
   csi_ctr_gen_utility_pvt.put_line( ' Maint organization id = '||to_char(l_maint_organization_id));

   -- Validate start date
   /*
   IF l_start_date_active IS NULL THEN
      CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_STDATE_INVALID');
   ELS */
   IF l_start_date_active > sysdate THEN
      CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INVALID_START_DATE');
   END IF;

   -- Check for duplicate assocition
   OPEN association_exist(l_counter_id, l_source_object_id );
   FETCH association_exist INTO l_is_association_exist;
   CLOSE association_exist;
   IF l_is_association_exist is not null then
     -- Association exist for this counter. Raise error
     csi_ctr_gen_utility_pvt.put_line('Association exist for this counter. Duplicate error...');
     csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_ASSOCIATION_EXIST','INSTANCE_ID',l_instance_number);
   END IF;

    -- call table handler here

    CSI_COUNTER_ASSOCIATIONS_PKG.INSERT_ROW
   (
    px_INSTANCE_ASSOCIATION_ID  => l_instance_association_id
   ,p_SOURCE_OBJECT_CODE        => l_source_object_code
   ,p_SOURCE_OBJECT_ID          => l_source_object_id
   ,p_COUNTER_ID                => l_counter_id
   ,p_START_DATE_ACTIVE         => l_start_date_active
   ,p_END_DATE_ACTIVE           => l_end_date_active
   ,p_OBJECT_VERSION_NUMBER     => 1
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
   ,p_ATTRIBUTE_CATEGORY        => l_attribute_category
   ,p_MIGRATED_FLAG             => null
   ,p_SECURITY_GROUP_ID         => null
   ,p_MAINT_ORGANIZATION_ID     => l_maint_organization_id
   ,p_PRIMARY_FAILURE_FLAG      => l_primary_failure_flag
   );
   IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
        ROLLBACK TO create_ctr_associations_pvt;
        RETURN;
   END IF;

   -- End of API body

   -- Standard check of p_commit.
   IF FND_API.To_Boolean(nvl(p_commit,FND_API.G_FALSE)) THEN
      COMMIT WORK;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO create_ctr_associations_pvt;
      FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count,
                 p_data  => x_msg_data
                );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_ctr_associations_pvt;
      FND_MSG_PUB.Count_And_Get
      		(p_count => x_msg_count,
                 p_data  => x_msg_data
                );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_ctr_associations_pvt;
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
END create_ctr_associations;

--|---------------------------------------------------
--| procedure name: create_reading_lock
--| description :   procedure used to
--|                 create reading lock on a counter
--|---------------------------------------------------

PROCEDURE create_reading_lock
 (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2
    ,p_init_msg_list         IN     VARCHAR2
    ,p_validation_level      IN     NUMBER
    ,p_ctr_reading_lock_rec  IN out	NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_reading_lock_rec
    ,x_return_status           OUT    NOCOPY VARCHAR2
    ,x_msg_count               OUT    NOCOPY NUMBER
    ,x_msg_data                OUT    NOCOPY VARCHAR2
    ,x_reading_lock_id         OUT	NOCOPY NUMBER
 )
 IS
    l_api_name                      CONSTANT VARCHAR2(30)   := 'CREATE_READING_LOCK';
    l_api_version                   CONSTANT NUMBER         := 1.0;
    -- l_debug_level                   NUMBER;
    l_flag                          VARCHAR2(1)             := 'N';
    l_msg_data                      VARCHAR2(2000);
    l_msg_index                     NUMBER;
    l_msg_count                     NUMBER;
    l_count                         NUMBER;
    l_return_message                VARCHAR2(100);

    l_reading_lock_id               NUMBER;
    l_counter_id                    NUMBER;
    l_reading_lock_date             DATE;
    l_active_start_date             DATE;
    l_active_end_date               DATE;
    l_source_group_ref_id           NUMBER;
    l_source_group_REF              VARCHAR2(50);
    l_source_header_ref_id          NUMBER;
    l_source_header_ref             VARCHAR2(50);
    l_source_line_ref_id            NUMBER;
    l_source_line_ref               VARCHAR2(50);
    l_source_dist_ref_id1           NUMBER;
    l_source_dist_ref_id2           NUMBER;

    CURSOR LAST_CTR_READING_CUR(p_counter_id IN NUMBER,p_reading_lock_date IN DATE) IS
      select value_timestamp
      from CSI_COUNTER_READINGS
      where counter_id = p_counter_id
      and   nvl(disabled_flag,'N') = 'N'
      and   value_timestamp <= p_reading_lock_date
      ORDER BY value_timestamp desc;

    l_last_reading_date  DATE;

    l_dummy	                        VARCHAR2(1);

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  create_reading_lock_pvt;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
   THEN
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

   -- Check the profile option debug_level for debug message reporting
   -- l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

   -- If debug_level = 1 then dump the procedure name
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'create_reading_lock');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 1) THEN
      csi_ctr_gen_utility_pvt.put_line( 'create_reading_lock'       ||
                                     p_api_version         ||'-'||
                                     p_commit              ||'-'||
                                     p_init_msg_list       ||'-'||
                                     p_validation_level );
      csi_ctr_gen_utility_pvt.dump_ctr_reading_lock_rec(p_ctr_reading_lock_rec);
   END IF;

   -- Start of API Body

   if p_ctr_reading_lock_rec.counter_id = FND_API.G_MISS_NUM then
       l_counter_id := null;
   else
       l_counter_id := p_ctr_reading_lock_rec.counter_id;
   end if;
   if p_ctr_reading_lock_rec.reading_lock_date = FND_API.G_MISS_DATE then
       l_reading_lock_date := null;
   else
       l_reading_lock_date := p_ctr_reading_lock_rec.reading_lock_date;
   end if;
  /*
   if p_ctr_reading_lock_rec.active_start_date = FND_API.G_MISS_DATE then
       l_active_start_date := null;
   else
       l_active_start_date := p_ctr_reading_lock_rec.active_start_date;
   end if;
   if p_ctr_reading_lock_rec.active_end_date = FND_API.G_MISS_DATE then
       l_active_end_date := null;
   else
       l_active_end_date := p_ctr_reading_lock_rec.active_end_date;
   end if;
  */
   if p_ctr_reading_lock_rec.source_group_ref_id = FND_API.G_MISS_NUM then
       l_source_group_ref_id := null;
   else
       l_source_group_ref_id := p_ctr_reading_lock_rec.source_group_ref_id;
   end if;
   if p_ctr_reading_lock_rec.source_group_ref = FND_API.G_MISS_CHAR then
       l_source_group_ref := null;
   else
       l_source_group_ref := p_ctr_reading_lock_rec.source_group_ref;
   end if;
   if p_ctr_reading_lock_rec.source_header_ref_id = FND_API.G_MISS_NUM then
       l_source_header_ref_id := null;
   else
       l_source_header_ref_id := p_ctr_reading_lock_rec.source_header_ref_id;
   end if;
   if p_ctr_reading_lock_rec.source_header_ref = FND_API.G_MISS_CHAR then
       l_source_header_ref := null;
   else
       l_source_header_ref := p_ctr_reading_lock_rec.source_header_ref;
   end if;
   if p_ctr_reading_lock_rec.source_line_ref_id = FND_API.G_MISS_NUM then
       l_source_line_ref_id := null;
   else
       l_source_line_ref_id := p_ctr_reading_lock_rec.source_line_ref_id;
   end if;
   if p_ctr_reading_lock_rec.source_line_ref = FND_API.G_MISS_CHAR then
       l_source_line_ref := null;
   else
       l_source_line_ref := p_ctr_reading_lock_rec.source_line_ref;
   end if;
   if p_ctr_reading_lock_rec.source_dist_ref_id1 = FND_API.G_MISS_NUM then
       l_source_dist_ref_id1 := null;
   else
       l_source_dist_ref_id1 := p_ctr_reading_lock_rec.source_dist_ref_id1;
   end if;
   if p_ctr_reading_lock_rec.source_dist_ref_id2 = FND_API.G_MISS_NUM then
       l_source_dist_ref_id2 := null;
   else
       l_source_dist_ref_id2 := p_ctr_reading_lock_rec.source_dist_ref_id2;
   end if;

   --Validate Counter Id
   begin
     select 'x'
     into l_dummy
     from csi_counters_b
     where counter_id = l_counter_id;
   exception when no_data_found then
     csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_INVALID');
   end;

   --validate reading lock date for null
   if l_reading_lock_date is null then
     csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_INV_RDG_LOCK_DT','RDG_LOCK_DATE',l_reading_lock_date);
   end if;
   --validate reading lock date is not future date
   if l_reading_lock_date > sysdate then
     csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_INV_RDG_LOCK_DT','RDG_LOCK_DATE',l_reading_lock_date);
   end if;

    -- Get the last reading for this counter
   OPEN LAST_CTR_READING_CUR(l_counter_id, l_reading_lock_date);
   FETCH LAST_CTR_READING_CUR
   into  l_last_reading_date;
   CLOSE LAST_CTR_READING_CUR;

   If l_last_reading_date is null then
     l_last_reading_date := l_reading_lock_date;
   End If;

   -- call table handler here

   CSI_COUNTER_READING_LOCK_PKG.INSERT_ROW
   (
     px_reading_lock_id          => l_reading_lock_id
    ,p_counter_id                => l_counter_id
    -- ,p_reading_lock_date         => l_last_reading_date
    ,p_reading_lock_date         => l_reading_lock_date
    --,p_active_start_date         => l_active_start_date
    --,p_active_end_date           => l_active_end_date
    ,p_object_version_number     => 1
    ,p_last_update_date          => sysdate
    ,p_last_updated_by           => FND_GLOBAL.USER_ID
    ,p_creation_date             => sysdate
    ,p_created_by                => FND_GLOBAL.USER_ID
    ,p_last_update_login         => FND_GLOBAL.USER_ID
    ,p_SOURCE_GROUP_REF_ID       => l_source_group_ref_id
	   ,p_SOURCE_GROUP_REF          => l_source_group_ref
	   ,p_SOURCE_HEADER_REF_ID      => l_source_header_ref_id
	   ,p_SOURCE_HEADER_REF         => l_source_header_ref
	   ,p_SOURCE_LINE_REF_ID        => l_source_line_ref_id
	   ,p_SOURCE_LINE_REF           => l_source_line_ref
	   ,p_SOURCE_DIST_REF_ID1       => l_source_dist_ref_id1
	   ,p_SOURCE_DIST_REF_ID2       => l_source_dist_ref_id2
   );
   IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
        ROLLBACK TO create_reading_lock_pvt;
        RETURN;
   END IF;

   -- End of API body

   -- Standard check of p_commit.
   IF FND_API.To_Boolean(nvl(p_commit,FND_API.G_FALSE)) THEN
      COMMIT WORK;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO create_reading_lock_pvt;
      FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count,
                 p_data  => x_msg_data
                );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_reading_lock_pvt;
      FND_MSG_PUB.Count_And_Get
      		(p_count => x_msg_count,
                 p_data  => x_msg_data
                );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_reading_lock_pvt;
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
END create_reading_lock;

--|---------------------------------------------------
--| procedure name: create_daily_usage
--| description :   procedure used to
--|                 create daily usage
--|---------------------------------------------------

PROCEDURE create_daily_usage
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_ctr_usage_forecast_rec    IN out	NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_usage_forecast_rec
    ,x_return_status                OUT    NOCOPY VARCHAR2
    ,x_msg_count                    OUT    NOCOPY NUMBER
    ,x_msg_data                     OUT    NOCOPY VARCHAR2
    ,x_instance_forecast_id         OUT	NOCOPY NUMBER
 )
 IS
    l_api_name                      CONSTANT VARCHAR2(30)   := 'CREATE_DAILY_USAGE';
    l_api_version                   CONSTANT NUMBER         := 1.0;
    -- l_debug_level                   NUMBER;
    l_flag                          VARCHAR2(1)             := 'N';
    l_msg_data                      VARCHAR2(2000);
    l_msg_index                     NUMBER;
    l_msg_count                     NUMBER;
    l_count                         NUMBER;
    l_return_message                VARCHAR2(100);

    l_instance_forecast_id          NUMBER;
    l_counter_id                    NUMBER;
    l_usage_rate                    NUMBER;
    l_use_past_reading              NUMBER;
    l_active_start_date             DATE;
    l_active_end_date               DATE;
    l_max_start_date                DATE;

    l_dummy                         VARCHAR2(1);


BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  create_daily_usage_pvt;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
   THEN
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

   -- Check the profile option debug_level for debug message reporting
   -- l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

   -- If debug_level = 1 then dump the procedure name
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'create_daily_usage');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 1) THEN
      csi_ctr_gen_utility_pvt.put_line( 'create_daily_usage'     ||
                                     p_api_version         ||'-'||
                                     p_commit              ||'-'||
                                     p_init_msg_list       ||'-'||
                                     p_validation_level );
      csi_ctr_gen_utility_pvt.dump_ctr_usage_forecast_rec(p_ctr_usage_forecast_rec);
   END IF;

   -- Start of API Body

   if p_ctr_usage_forecast_rec.counter_id = FND_API.G_MISS_NUM then
       l_counter_id := null;
   else
       l_counter_id := p_ctr_usage_forecast_rec.counter_id;
   end if;
   if p_ctr_usage_forecast_rec.usage_rate = FND_API.G_MISS_NUM then
       l_usage_rate := null;
   else
       l_usage_rate := p_ctr_usage_forecast_rec.usage_rate;
   end if;
   if p_ctr_usage_forecast_rec.use_past_reading = FND_API.G_MISS_NUM then
       l_use_past_reading := null;
   else
       l_use_past_reading := p_ctr_usage_forecast_rec.use_past_reading;
   end if;
   if p_ctr_usage_forecast_rec.active_start_date = FND_API.G_MISS_DATE then
       l_active_start_date := null;
   else
       l_active_start_date := p_ctr_usage_forecast_rec.active_start_date;
   end if;

   IF l_active_start_date IS NULL THEN
      l_active_start_date := sysdate;
   ELSE
      IF l_active_start_date > sysdate THEN
         CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INVALID_START_DATE');
      END IF;
   END IF;

   /* Validate start date */
   IF l_counter_id IS NOT NULL THEN
      BEGIN
         SELECT max(active_start_date)
         INTO   l_max_start_date
         FROM   CSI_COUNTER_USAGE_FORECAST
         WHERE  counter_id = l_counter_id;

         IF l_max_start_date IS NOT NULL THEN
            IF l_active_start_date < l_max_start_date THEN
               CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_USAGE_STDATE_INV');
            END IF;
         END IF;
      END;
   END IF;

   if p_ctr_usage_forecast_rec.active_end_date = FND_API.G_MISS_DATE then
       l_active_end_date := null;
   else
       l_active_end_date := p_ctr_usage_forecast_rec.active_end_date;
   end if;

   --Validate Counter Id
   begin
     select 'x'
     into l_dummy
     from csi_counters_b
     where counter_id = l_counter_id;
   exception when no_data_found then
     csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_INVALID');
   end;

   -- Validate usage rate is not negative
   if l_usage_rate < 0 or l_usage_rate is null then
     csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_INV_USAGE_RATE');
   end if;

   -- Validate use past reading is not negative
   if l_use_past_reading < 0 or l_use_past_reading is null then
     csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_INV_USE_PAST_RDG');
   end if;

   -- update to end date existing active usage rate
   UPDATE CSI_COUNTER_USAGE_FORECAST
   SET    active_end_date = l_active_start_date
   -- SET active_end_date = sysdate
   WHERE  instance_forecast_id in (select instance_forecast_id
                                   from   CSI_COUNTER_USAGE_FORECAST
                                   where  counter_id = l_counter_id
                                   and    active_end_date is null);

   -- call table handler here
   CSI_CTR_USAGE_FORECAST_PKG.insert_row
   (
     px_instance_forecast_id      => l_instance_forecast_id
     ,p_counter_id                => l_counter_id
     ,p_usage_rate                => l_usage_rate
     ,p_use_past_reading          => l_use_past_reading
     ,p_active_start_date         => l_active_start_date
     ,p_active_end_date           => l_active_end_date
     ,p_object_version_number     => 1
     ,p_last_update_date          => sysdate
     ,p_last_updated_by           => FND_GLOBAL.USER_ID
     ,p_creation_date             => sysdate
     ,p_created_by                => FND_GLOBAL.USER_ID
     ,p_last_update_login         => FND_GLOBAL.USER_ID
    );
    IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
        ROLLBACK TO create_daily_usage_pvt;
        RETURN;
    END IF;

   -- End of API body

   -- Standard check of p_commit.
   IF FND_API.To_Boolean(nvl(p_commit,FND_API.G_FALSE)) THEN
      COMMIT WORK;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO create_daily_usage_pvt;
      FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count,
                 p_data  => x_msg_data
                );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_daily_usage_pvt;
      FND_MSG_PUB.Count_And_Get
      		(p_count => x_msg_count,
                 p_data  => x_msg_data
                );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_daily_usage_pvt;
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
END create_daily_usage;

 --|---------------------------------------------------
--| procedure name: update_counter
--| description :   procedure used to
--|                 create counter instance
--|---------------------------------------------------

PROCEDURE update_counter
 (
     p_api_version             IN	NUMBER
    ,p_init_msg_list           IN	VARCHAR2
    ,p_commit	               IN	VARCHAR2
    ,p_validation_level	       IN	VARCHAR2
    ,p_counter_instance_rec    IN out NOCOPY CSI_CTR_DATASTRUCTURES_PUB.Counter_instance_rec
    ,x_return_status               OUT NOCOPY VARCHAR2
    ,x_msg_count                   OUT NOCOPY NUMBER
    ,x_msg_data                    OUT NOCOPY VARCHAR2
 )
 IS
    l_api_name                      CONSTANT VARCHAR2(30)   := 'UPDATE_COUNTER';
    l_api_version                   CONSTANT NUMBER         := 1.0;
    -- l_debug_level                   NUMBER;
    l_flag                          VARCHAR2(1)             := 'N';
    l_msg_data                      VARCHAR2(2000);
    l_msg_index                     NUMBER;
    l_msg_count                     NUMBER;
    l_count                         NUMBER;
    l_return_message                VARCHAR2(100);
    l_return_status                 VARCHAR2(40);

    l_old_counter_instance_rec      CSI_CTR_DATASTRUCTURES_PUB.Counter_instance_rec;
    l_counter_instance_rec          CSI_CTR_DATASTRUCTURES_PUB.Counter_instance_rec;

    CURSOR formula_ref_cur(p_counter_id number) IS
       SELECT relationship_id
       FROM csi_counter_relationships
       WHERE object_counter_id = p_counter_id and relationship_type_code = 'FORMULA';
    l_formula_ref_count             NUMBER;
    CURSOR derived_filters_cur(p_counter_id NUMBER) IS
       SELECT counter_derived_filter_id
       FROM csi_counter_derived_filters
       WHERE counter_id = p_counter_id;
    l_der_filter_count              NUMBER;
    CURSOR target_counter_cur(p_counter_id NUMBER) IS
       SELECT relationship_id
       FROM csi_counter_relationships
       WHERE source_counter_id = p_counter_id and relationship_type_code = 'CONFIGURATION';
    l_target_ctr_exist              NUMBER;
    CURSOR counter_readings_cur(p_counter_id  NUMBER) IS
      SELECT counter_value_id
      FROM csi_counter_readings
      WHERE counter_id = p_counter_id;
    l_rdg_exists                    NUMBER;

    -- for counter name check
    l_new_name_instr NUMBER;
    l_old_name_instr NUMBER;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  update_counter_pvt;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
   THEN
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

   -- Check the profile option debug_level for debug message reporting
   -- l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

   -- If debug_level = 1 then dump the procedure name
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'update_counter');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 1) THEN
      csi_ctr_gen_utility_pvt.put_line( 'update_counter'       ||
                                     p_api_version         ||'-'||
                                     p_commit              ||'-'||
                                     p_init_msg_list       ||'-'||
                                     p_validation_level );
      csi_ctr_gen_utility_pvt.dump_counter_instance_rec(p_counter_instance_rec);
   END IF;

   -- Start of API Body

   SELECT group_id,
          counter_type,
          initial_reading,
          initial_reading_date,
          created_from_counter_tmpl_id,
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
          --counter_code,
          reading_type,
          automatic_rollover,
          default_usage_rate,
          use_past_reading,
          used_in_scheduling,
          defaulted_group_id
          ,name
          ,comments
          ,step_value
          ,object_version_number
          ,time_based_manual_entry
          ,eam_required_flag
   INTO   l_old_counter_instance_rec.group_id,
          l_old_counter_instance_rec.counter_type,
          l_old_counter_instance_rec.initial_reading,
          l_old_counter_instance_rec.initial_reading_date,
          l_old_counter_instance_rec.created_from_counter_tmpl_id,
          l_old_counter_instance_rec.tolerance_plus,
          l_old_counter_instance_rec.tolerance_minus,
          l_old_counter_instance_rec.uom_code,
          l_old_counter_instance_rec.derive_counter_id,
          l_old_counter_instance_rec.derive_function,
          l_old_counter_instance_rec.valid_flag,
          l_old_counter_instance_rec.formula_incomplete_flag,
          l_old_counter_instance_rec.formula_text,
          l_old_counter_instance_rec.rollover_last_reading,
          l_old_counter_instance_rec.rollover_first_reading,
          l_old_counter_instance_rec.usage_item_id,
          l_old_counter_instance_rec.ctr_val_max_seq_no,
          l_old_counter_instance_rec.start_date_active,
          l_old_counter_instance_rec.end_date_active,
          l_old_counter_instance_rec.attribute1,
          l_old_counter_instance_rec.attribute2,
          l_old_counter_instance_rec.attribute3,
          l_old_counter_instance_rec.attribute4,
          l_old_counter_instance_rec.attribute5,
          l_old_counter_instance_rec.attribute6,
          l_old_counter_instance_rec.attribute7,
          l_old_counter_instance_rec.attribute8,
          l_old_counter_instance_rec.attribute9,
          l_old_counter_instance_rec.attribute10,
          l_old_counter_instance_rec.attribute11,
          l_old_counter_instance_rec.attribute12,
          l_old_counter_instance_rec.attribute13,
          l_old_counter_instance_rec.attribute14,
          l_old_counter_instance_rec.attribute15,
          l_old_counter_instance_rec.attribute16,
          l_old_counter_instance_rec.attribute17,
          l_old_counter_instance_rec.attribute18,
          l_old_counter_instance_rec.attribute19,
          l_old_counter_instance_rec.attribute20,
          l_old_counter_instance_rec.attribute21,
          l_old_counter_instance_rec.attribute22,
          l_old_counter_instance_rec.attribute23,
          l_old_counter_instance_rec.attribute24,
          l_old_counter_instance_rec.attribute25,
          l_old_counter_instance_rec.attribute26,
          l_old_counter_instance_rec.attribute27,
          l_old_counter_instance_rec.attribute28,
          l_old_counter_instance_rec.attribute29,
          l_old_counter_instance_rec.attribute30,
          l_old_counter_instance_rec.attribute_category,
          l_old_counter_instance_rec.customer_view,
          l_old_counter_instance_rec.direction,
          l_old_counter_instance_rec.filter_type,
          l_old_counter_instance_rec.filter_reading_count,
          l_old_counter_instance_rec.filter_time_uom,
          l_old_counter_instance_rec.estimation_id,
          --l_old_counter_instance_rec.counter_code,
          l_old_counter_instance_rec.reading_type,
          l_old_counter_instance_rec.automatic_rollover,
          l_old_counter_instance_rec.default_usage_rate,
          l_old_counter_instance_rec.use_past_reading,
          l_old_counter_instance_rec.used_in_scheduling,
          l_old_counter_instance_rec.defaulted_group_id
          ,l_old_counter_instance_rec.name
          ,l_old_counter_instance_rec.comments
          ,l_old_counter_instance_rec.step_value
          ,l_old_counter_instance_rec.object_version_number
          ,l_old_counter_instance_rec.time_based_manual_entry
          ,l_old_counter_instance_rec.eam_required_flag
   FROM   csi_counters_vl
   WHERE  counter_id = p_counter_instance_rec.counter_id
   FOR UPDATE OF OBJECT_VERSION_NUMBER;
   IF SQL%NOTFOUND THEN
     csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_INVALID');
   END IF;

   l_counter_instance_rec := p_counter_instance_rec;

   IF p_counter_instance_rec.group_id = FND_API.G_MISS_NUM THEN
      l_counter_instance_rec.group_id := NULL;
   ELSIF p_counter_instance_rec.group_id IS NULL THEN
      l_counter_instance_rec.group_id := l_old_counter_instance_rec.group_id;
   END IF;
   IF p_counter_instance_rec.counter_type = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.counter_type := NULL;
   ELSIF p_counter_instance_rec.counter_type IS NULL THEN
      l_counter_instance_rec.counter_type := l_old_counter_instance_rec.counter_type;
   END IF;
   IF p_counter_instance_rec.initial_reading = FND_API.G_MISS_NUM THEN
      l_counter_instance_rec.initial_reading := NULL;
   ELSIF p_counter_instance_rec.initial_reading IS NULL THEN
      l_counter_instance_rec.initial_reading := l_old_counter_instance_rec.initial_reading;
   END IF;
   IF p_counter_instance_rec.initial_reading_date = FND_API.G_MISS_DATE THEN
      l_counter_instance_rec.initial_reading_date := NULL;
   ELSIF p_counter_instance_rec.initial_reading_date IS NULL THEN
      l_counter_instance_rec.initial_reading_date := l_old_counter_instance_rec.initial_reading_date;
   END IF;
   IF p_counter_instance_rec.created_from_counter_tmpl_id = FND_API.G_MISS_NUM THEN
      l_counter_instance_rec.created_from_counter_tmpl_id := NULL;
   ELSIF p_counter_instance_rec.created_from_counter_tmpl_id IS NULL THEN
      l_counter_instance_rec.created_from_counter_tmpl_id := l_old_counter_instance_rec.created_from_counter_tmpl_id;
   END IF;
   IF p_counter_instance_rec.tolerance_plus = FND_API.G_MISS_NUM THEN
      l_counter_instance_rec.tolerance_plus := NULL;
   ELSIF p_counter_instance_rec.tolerance_plus IS NULL THEN
      l_counter_instance_rec.tolerance_plus := l_old_counter_instance_rec.tolerance_plus;
   END IF;
   IF p_counter_instance_rec.tolerance_minus = FND_API.G_MISS_NUM THEN
      l_counter_instance_rec.tolerance_minus := NULL;
   ELSIF p_counter_instance_rec.tolerance_minus IS NULL THEN
      l_counter_instance_rec.tolerance_minus := l_old_counter_instance_rec.tolerance_minus;
   END IF;
   IF p_counter_instance_rec.uom_code = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.uom_code := NULL;
   ELSIF p_counter_instance_rec.uom_code IS NULL THEN
      l_counter_instance_rec.uom_code := l_old_counter_instance_rec.uom_code;
   END IF;
   IF p_counter_instance_rec.derive_counter_id = FND_API.G_MISS_NUM THEN
      l_counter_instance_rec.derive_counter_id := NULL;
   ELSIF p_counter_instance_rec.derive_counter_id IS NULL THEN
      l_counter_instance_rec.derive_counter_id := l_old_counter_instance_rec.derive_counter_id;
   END IF;
   IF p_counter_instance_rec.derive_function = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.derive_function := NULL;
   ELSIF p_counter_instance_rec.derive_function IS NULL THEN
      l_counter_instance_rec.derive_function := l_old_counter_instance_rec.derive_function;
   END IF;
   IF p_counter_instance_rec.valid_flag = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.valid_flag := NULL;
   ELSIF p_counter_instance_rec.valid_flag IS NULL THEN
      l_counter_instance_rec.valid_flag := l_old_counter_instance_rec.valid_flag;
   END IF;
   IF p_counter_instance_rec.formula_incomplete_flag = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.formula_incomplete_flag := NULL;
   ELSIF p_counter_instance_rec.formula_incomplete_flag IS NULL THEN
      l_counter_instance_rec.formula_incomplete_flag := l_old_counter_instance_rec.formula_incomplete_flag;
   END IF;
   IF p_counter_instance_rec.formula_text = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.formula_text := NULL;
   ELSIF p_counter_instance_rec.formula_text IS NULL THEN
      l_counter_instance_rec.formula_text := l_old_counter_instance_rec.formula_text;
   END IF;
   IF p_counter_instance_rec.rollover_last_reading = FND_API.G_MISS_NUM THEN
      l_counter_instance_rec.rollover_last_reading := NULL;
   ELSIF p_counter_instance_rec.rollover_last_reading IS NULL THEN
      l_counter_instance_rec.rollover_last_reading := l_old_counter_instance_rec.rollover_last_reading;
   END IF;
   IF p_counter_instance_rec.rollover_first_reading = FND_API.G_MISS_NUM THEN
      l_counter_instance_rec.rollover_first_reading := NULL;
   ELSIF p_counter_instance_rec.rollover_first_reading IS NULL THEN
      l_counter_instance_rec.rollover_first_reading := l_old_counter_instance_rec.rollover_first_reading;
   END IF;
   IF p_counter_instance_rec.usage_item_id = FND_API.G_MISS_NUM THEN
      l_counter_instance_rec.usage_item_id := NULL;
   ELSIF p_counter_instance_rec.usage_item_id IS NULL THEN
      l_counter_instance_rec.usage_item_id := l_old_counter_instance_rec.usage_item_id;
   END IF;
   IF p_counter_instance_rec.ctr_val_max_seq_no = FND_API.G_MISS_NUM THEN
      l_counter_instance_rec.ctr_val_max_seq_no := NULL;
   ELSIF p_counter_instance_rec.ctr_val_max_seq_no IS NULL THEN
      l_counter_instance_rec.ctr_val_max_seq_no := l_old_counter_instance_rec.ctr_val_max_seq_no;
   END IF;
   IF p_counter_instance_rec.start_date_active = FND_API.G_MISS_DATE THEN
      l_counter_instance_rec.start_date_active := NULL;
   ELSIF p_counter_instance_rec.start_date_active IS NULL THEN
      l_counter_instance_rec.start_date_active := l_old_counter_instance_rec.start_date_active;
   END IF;
   IF p_counter_instance_rec.end_date_active = FND_API.G_MISS_DATE THEN
      l_counter_instance_rec.end_date_active := NULL;
   ELSIF p_counter_instance_rec.end_date_active IS NULL THEN
      l_counter_instance_rec.end_date_active := l_old_counter_instance_rec.end_date_active;
   END IF;
   IF p_counter_instance_rec.attribute1 = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.attribute1 := NULL;
   ELSIF p_counter_instance_rec.attribute1 IS NULL THEN
      l_counter_instance_rec.attribute1 := l_old_counter_instance_rec.attribute1;
   END IF;
   IF p_counter_instance_rec.attribute2 = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.attribute2 := NULL;
   ELSIF p_counter_instance_rec.attribute2 IS NULL THEN
      l_counter_instance_rec.attribute2 := l_old_counter_instance_rec.attribute2;
   END IF;
   IF p_counter_instance_rec.attribute3 = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.attribute3 := NULL;
   ELSIF p_counter_instance_rec.attribute3 IS NULL THEN
      l_counter_instance_rec.attribute3 := l_old_counter_instance_rec.attribute3;
   END IF;
   IF p_counter_instance_rec.attribute4 = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.attribute4 := NULL;
   ELSIF p_counter_instance_rec.attribute4 IS NULL THEN
      l_counter_instance_rec.attribute4 := l_old_counter_instance_rec.attribute4;
   END IF;
   IF p_counter_instance_rec.attribute5 = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.attribute5 := NULL;
   ELSIF p_counter_instance_rec.attribute5 IS NULL THEN
      l_counter_instance_rec.attribute5 := l_old_counter_instance_rec.attribute5;
   END IF;
   IF p_counter_instance_rec.attribute6 = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.attribute6 := NULL;
   ELSIF p_counter_instance_rec.attribute6 IS NULL THEN
      l_counter_instance_rec.attribute6 := l_old_counter_instance_rec.attribute6;
   END IF;
   IF p_counter_instance_rec.attribute7 = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.attribute7 := NULL;
   ELSIF p_counter_instance_rec.attribute7 IS NULL THEN
      l_counter_instance_rec.attribute7 := l_old_counter_instance_rec.attribute7;
   END IF;
   IF p_counter_instance_rec.attribute8 = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.attribute8 := NULL;
   ELSIF p_counter_instance_rec.attribute8 IS NULL THEN
      l_counter_instance_rec.attribute8 := l_old_counter_instance_rec.attribute8;
   END IF;
   IF p_counter_instance_rec.attribute9 = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.attribute9 := NULL;
   ELSIF p_counter_instance_rec.attribute9 IS NULL THEN
      l_counter_instance_rec.attribute9 := l_old_counter_instance_rec.attribute9;
   END IF;
   IF p_counter_instance_rec.attribute10 = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.attribute10 := NULL;
   ELSIF p_counter_instance_rec.attribute10 IS NULL THEN
      l_counter_instance_rec.attribute10 := l_old_counter_instance_rec.attribute10;
   END IF;
   IF p_counter_instance_rec.attribute11 = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.attribute11 := NULL;
   ELSIF p_counter_instance_rec.attribute11 IS NULL THEN
      l_counter_instance_rec.attribute11 := l_old_counter_instance_rec.attribute11;
   END IF;
   IF p_counter_instance_rec.attribute12 = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.attribute12 := NULL;
   ELSIF p_counter_instance_rec.attribute12 IS NULL THEN
      l_counter_instance_rec.attribute12 := l_old_counter_instance_rec.attribute12;
   END IF;
   IF p_counter_instance_rec.attribute13 = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.attribute13 := NULL;
   ELSIF p_counter_instance_rec.attribute13 IS NULL THEN
      l_counter_instance_rec.attribute13 := l_old_counter_instance_rec.attribute13;
   END IF;
   IF p_counter_instance_rec.attribute14 = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.attribute14 := NULL;
   ELSIF p_counter_instance_rec.attribute14 IS NULL THEN
      l_counter_instance_rec.attribute14 := l_old_counter_instance_rec.attribute14;
   END IF;
   IF p_counter_instance_rec.attribute15 = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.attribute15 := NULL;
   ELSIF p_counter_instance_rec.attribute15 IS NULL THEN
      l_counter_instance_rec.attribute15 := l_old_counter_instance_rec.attribute15;
   END IF;
   IF p_counter_instance_rec.attribute16 = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.attribute16 := NULL;
   ELSIF p_counter_instance_rec.attribute16 IS NULL THEN
      l_counter_instance_rec.attribute16 := l_old_counter_instance_rec.attribute16;
   END IF;
   IF p_counter_instance_rec.attribute17 = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.attribute17 := NULL;
   ELSIF p_counter_instance_rec.attribute17 IS NULL THEN
      l_counter_instance_rec.attribute17 := l_old_counter_instance_rec.attribute17;
   END IF;
   IF p_counter_instance_rec.attribute18 = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.attribute18 := NULL;
   ELSIF p_counter_instance_rec.attribute18 IS NULL THEN
      l_counter_instance_rec.attribute18 := l_old_counter_instance_rec.attribute18;
   END IF;
   IF p_counter_instance_rec.attribute19 = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.attribute19 := NULL;
   ELSIF p_counter_instance_rec.attribute19 IS NULL THEN
      l_counter_instance_rec.attribute19 := l_old_counter_instance_rec.attribute19;
   END IF;
   IF p_counter_instance_rec.attribute20 = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.attribute20 := NULL;
   ELSIF p_counter_instance_rec.attribute20 IS NULL THEN
      l_counter_instance_rec.attribute20 := l_old_counter_instance_rec.attribute20;
   END IF;
   IF p_counter_instance_rec.attribute21 = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.attribute21 := NULL;
   ELSIF p_counter_instance_rec.attribute21 IS NULL THEN
      l_counter_instance_rec.attribute21 := l_old_counter_instance_rec.attribute21;
   END IF;
   IF p_counter_instance_rec.attribute22 = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.attribute22 := NULL;
   ELSIF p_counter_instance_rec.attribute22 IS NULL THEN
      l_counter_instance_rec.attribute22 := l_old_counter_instance_rec.attribute22;
   END IF;
   IF p_counter_instance_rec.attribute23 = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.attribute23 := NULL;
   ELSIF p_counter_instance_rec.attribute23 IS NULL THEN
      l_counter_instance_rec.attribute23 := l_old_counter_instance_rec.attribute23;
   END IF;
   IF p_counter_instance_rec.attribute24 = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.attribute24 := NULL;
   ELSIF p_counter_instance_rec.attribute24 IS NULL THEN
      l_counter_instance_rec.attribute24 := l_old_counter_instance_rec.attribute24;
   END IF;
   IF p_counter_instance_rec.attribute25 = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.attribute25 := NULL;
   ELSIF p_counter_instance_rec.attribute25 IS NULL THEN
      l_counter_instance_rec.attribute25 := l_old_counter_instance_rec.attribute25;
   END IF;
   IF p_counter_instance_rec.attribute26 = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.attribute26 := NULL;
   ELSIF p_counter_instance_rec.attribute26 IS NULL THEN
      l_counter_instance_rec.attribute26 := l_old_counter_instance_rec.attribute26;
   END IF;
   IF p_counter_instance_rec.attribute27 = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.attribute27 := NULL;
   ELSIF p_counter_instance_rec.attribute27 IS NULL THEN
      l_counter_instance_rec.attribute27 := l_old_counter_instance_rec.attribute27;
   END IF;
   IF p_counter_instance_rec.attribute28 = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.attribute28 := NULL;
   ELSIF p_counter_instance_rec.attribute28 IS NULL THEN
      l_counter_instance_rec.attribute28 := l_old_counter_instance_rec.attribute28;
   END IF;
   IF p_counter_instance_rec.attribute29 = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.attribute29 := NULL;
   ELSIF p_counter_instance_rec.attribute29 IS NULL THEN
      l_counter_instance_rec.attribute29 := l_old_counter_instance_rec.attribute29;
   END IF;
   IF p_counter_instance_rec.attribute30 = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.attribute30 := NULL;
   ELSIF p_counter_instance_rec.attribute30 IS NULL THEN
      l_counter_instance_rec.attribute30 := l_old_counter_instance_rec.attribute30;
   END IF;
   IF p_counter_instance_rec.attribute_category = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.attribute_category := NULL;
   ELSIF p_counter_instance_rec.attribute_category IS NULL THEN
      l_counter_instance_rec.attribute_category := l_old_counter_instance_rec.attribute_category;
   END IF;
   IF p_counter_instance_rec.customer_view = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.customer_view := NULL;
   ELSIF p_counter_instance_rec.customer_view IS NULL THEN
      l_counter_instance_rec.customer_view := l_old_counter_instance_rec.customer_view;
   END IF;
   IF p_counter_instance_rec.direction = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.direction := NULL;
   ELSIF p_counter_instance_rec.direction IS NULL THEN
      l_counter_instance_rec.direction := l_old_counter_instance_rec.direction;
   END IF;
   IF p_counter_instance_rec.filter_type = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.filter_type := NULL;
   ELSIF p_counter_instance_rec.filter_type IS NULL THEN
      l_counter_instance_rec.filter_type := l_old_counter_instance_rec.filter_type;
   END IF;
   IF p_counter_instance_rec.filter_reading_count = FND_API.G_MISS_NUM THEN
      l_counter_instance_rec.filter_reading_count := NULL;
   ELSIF p_counter_instance_rec.filter_reading_count IS NULL THEN
      l_counter_instance_rec.filter_reading_count := l_old_counter_instance_rec.filter_reading_count;
   END IF;
   IF p_counter_instance_rec.filter_time_uom = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.filter_time_uom := NULL;
   ELSIF p_counter_instance_rec.filter_time_uom IS NULL THEN
      l_counter_instance_rec.filter_time_uom := l_old_counter_instance_rec.filter_time_uom;
   END IF;
   IF p_counter_instance_rec.estimation_id = FND_API.G_MISS_NUM THEN
      l_counter_instance_rec.estimation_id := NULL;
   ELSIF p_counter_instance_rec.estimation_id IS NULL THEN
      l_counter_instance_rec.estimation_id := l_old_counter_instance_rec.estimation_id;
   END IF;

   IF p_counter_instance_rec.time_based_manual_entry = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.time_based_manual_entry := NULL;
   ELSIF p_counter_instance_rec.time_based_manual_entry IS NULL THEN
      l_counter_instance_rec.time_based_manual_entry := l_old_counter_instance_rec.time_based_manual_entry;
   END IF;

   IF p_counter_instance_rec.reading_type = FND_API.G_MISS_NUM THEN
      l_counter_instance_rec.reading_type := NULL;
   ELSIF p_counter_instance_rec.reading_type IS NULL THEN
      l_counter_instance_rec.reading_type := l_old_counter_instance_rec.reading_type;
   END IF;
   IF p_counter_instance_rec.automatic_rollover = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.automatic_rollover := NULL;
   ELSIF p_counter_instance_rec.automatic_rollover IS NULL THEN
      l_counter_instance_rec.automatic_rollover := l_old_counter_instance_rec.automatic_rollover;
   END IF;
   IF p_counter_instance_rec.default_usage_rate = FND_API.G_MISS_NUM THEN
      l_counter_instance_rec.default_usage_rate := NULL;
   ELSIF p_counter_instance_rec.default_usage_rate IS NULL THEN
      l_counter_instance_rec.default_usage_rate := l_old_counter_instance_rec.default_usage_rate;
   END IF;
   IF p_counter_instance_rec.use_past_reading = FND_API.G_MISS_NUM THEN
      l_counter_instance_rec.use_past_reading := NULL;
   ELSIF p_counter_instance_rec.use_past_reading IS NULL THEN
      l_counter_instance_rec.use_past_reading := l_old_counter_instance_rec.use_past_reading;
   END IF;
   IF p_counter_instance_rec.used_in_scheduling = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.used_in_scheduling := NULL;
   ELSIF p_counter_instance_rec.used_in_scheduling IS NULL THEN
      l_counter_instance_rec.used_in_scheduling := l_old_counter_instance_rec.used_in_scheduling;
   END IF;
   IF p_counter_instance_rec.defaulted_group_id = FND_API.G_MISS_NUM THEN
      l_counter_instance_rec.defaulted_group_id := NULL;
   ELSIF p_counter_instance_rec.defaulted_group_id IS NULL THEN
      l_counter_instance_rec.defaulted_group_id := l_old_counter_instance_rec.defaulted_group_id;
   END IF;
   IF p_counter_instance_rec.name = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.name := NULL;
   ELSIF p_counter_instance_rec.name IS NULL THEN
      l_counter_instance_rec.name := l_old_counter_instance_rec.name;
   END IF;
   IF p_counter_instance_rec.comments = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.comments := NULL;
   ELSIF p_counter_instance_rec.comments IS NULL THEN
      l_counter_instance_rec.comments := l_old_counter_instance_rec.comments;
   END IF;
   IF p_counter_instance_rec.step_value = FND_API.G_MISS_NUM THEN
      l_counter_instance_rec.step_value := NULL;
   ELSIF p_counter_instance_rec.step_value IS NULL THEN
      l_counter_instance_rec.step_value := l_old_counter_instance_rec.step_value;
   END IF;
   IF p_counter_instance_rec.object_version_number = FND_API.G_MISS_NUM THEN
      l_counter_instance_rec.object_version_number := NULL;
   ELSIF p_counter_instance_rec.object_version_number IS NULL THEN
      l_counter_instance_rec.object_version_number := l_old_counter_instance_rec.object_version_number;
   END IF;

   -- compare object version number
   IF l_old_counter_instance_rec.object_version_number <> nvl(l_counter_instance_rec.object_version_number,0) THEN
      csi_ctr_gen_utility_pvt.put_line('Object version mismatch in update counter');
      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_OBJ_VER_MISMATCH');
   END IF;

   IF p_counter_instance_rec.eam_required_flag = FND_API.G_MISS_CHAR THEN
      l_counter_instance_rec.eam_required_flag := NULL;
   ELSIF p_counter_instance_rec.eam_required_flag IS NULL THEN
      l_counter_instance_rec.eam_required_flag := l_old_counter_instance_rec.eam_required_flag;
   END IF;

   -- Check the validation for used in scheduling flag
   IF l_old_counter_instance_rec.used_in_scheduling = 'Y' AND l_counter_instance_rec.used_in_scheduling = 'N' THEN
      Eam_Meters_Util.Validate_Used_In_Scheduling
      (
        p_meter_id         =>   p_counter_instance_rec.counter_id,
        X_return_status    =>   l_return_status,
        X_msg_count        =>   l_msg_count,
        X_msg_data         =>   l_msg_data
     );
     IF NOT (l_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
        csi_ctr_gen_utility_pvt.put_line('used in scheduling cannot be updated');
        csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_USEDINSCHED_NOT_UPDT');
     END IF;

   END IF;

   -- Counter group is not updateable
   /*
   IF l_counter_instance_rec.group_id <> l_old_counter_instance_rec.group_id THEN
      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_GRP_NOT_UPDATABLE');
	  END IF;
   */
   IF l_counter_instance_rec.counter_type <> l_old_counter_instance_rec.counter_type THEN
     IF l_old_counter_instance_rec.counter_type = 'FORMULA'
        and l_old_counter_instance_rec.derive_function is null THEN
       OPEN formula_ref_cur(p_counter_instance_rec.counter_id);
       FETCH formula_ref_cur INTO l_formula_ref_count;
       CLOSE formula_ref_cur;
       IF l_formula_ref_count is not null then
         -- Formula references exist for this counter. You cannot
         -- change the type to something different.
         csi_ctr_gen_utility_pvt.put_line('Formula References exist for this counter. Cannot change counter type...');
         csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_FMLA_REF_EXIST','CTR_NAME',l_counter_instance_rec.name);
       END IF;
     ELSIF l_old_counter_instance_rec.counter_type = 'FORMULA'
             and l_old_counter_instance_rec.derive_function in ('SUM','COUNT') THEN
       OPEN derived_filters_cur(p_counter_instance_rec.counter_id);
       FETCH derived_filters_cur INTO l_der_filter_count;
       CLOSE derived_filters_cur;
       IF l_der_filter_count is not null then
         -- Derived filters exist for this counter. You cannot
         -- change the type to something different.
         csi_ctr_gen_utility_pvt.put_line('Derived Filters exist for this counter. Cannot change counter type...');
         csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_DER_FILTER_EXIST','CTR_NAME',l_counter_instance_rec.name);
       END IF;
     ELSIF l_old_counter_instance_rec.counter_type = 'REGULAR' THEN
       OPEN target_counter_cur(p_counter_instance_rec.counter_id);
       FETCH target_counter_cur INTO l_target_ctr_exist;
       CLOSE target_counter_cur;
       IF l_target_ctr_exist is not null then
         -- Target counters exist for this counter. You cannot
         -- change the type to something different.
         csi_ctr_gen_utility_pvt.put_line('Target Counters exist for this counter. Cannot change counter type...');
         csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_CONFIG_CTR_EXIST','CTR_NAME',l_counter_instance_rec.name);
       END IF;
     END IF;
   END IF;

   -- Validate reading type. Reading type cannot be changed if readings exist
   IF l_counter_instance_rec.reading_type <> l_old_counter_instance_rec.reading_type THEN
      OPEN counter_readings_cur(p_counter_instance_rec.counter_id);
      FETCH counter_readings_cur INTO l_rdg_exists;
      CLOSE counter_readings_cur;
      IF l_rdg_exists is not null then
        -- Counter readings exist for this counter. You cannot
        -- change the reading type to something different.counter.
        csi_ctr_gen_utility_pvt.put_line('Counter readings exist for this counter. Cannot change reading type...');
        csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_RDGS_EXIST','CTR_NAME',l_counter_instance_rec.name);
      END IF;
   END IF;

--bug 9009809.Below check not needed during update.

   -- check and update name
 /*
   IF l_counter_instance_rec.name <> l_old_counter_instance_rec.name THEN
--	l_new_name_instr := instrb(l_counter_instance_rec.name,'-',-1,1);
--	l_old_name_instr := instrb(l_old_counter_instance_rec.name,'-',-1,1);
 --     if l_new_name_instr <> 0  and l_old_name_instr <> 0 then
  --      if substrb(l_counter_instance_rec.name,l_new_name_instr+1) <> substrb(l_old_counter_instance_rec.name,l_old_name_instr+1) then
   --       l_counter_instance_rec.name := l_counter_instance_rec.name||'-'||p_counter_instance_rec.counter_id;
    --    end if;
     -- els
      if (l_counter_instance_rec.created_from_counter_tmpl_id is not null) or (counter_name_exists(l_counter_instance_rec.name, l_counter_instance_rec.counter_id) ) THEN
	    l_counter_instance_rec.name := l_counter_instance_rec.name||'-'||p_counter_instance_rec.counter_id;
      end if;
   END IF;
*/
   -- Validate start date
   IF l_counter_instance_rec.start_date_active IS NULL THEN
      CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_STDATE_INVALID');
   ELSIF l_counter_instance_rec.start_date_active > sysdate THEN
      CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INVALID_START_DATE');
   END IF;

   -- Validate counter name is unique
   Validate_Unique_ctr(l_counter_instance_rec.name, p_counter_instance_rec.counter_id);

   -- Validate Counter
   validate_counter(l_counter_instance_rec.group_id, l_counter_instance_rec.name,
                    l_counter_instance_rec.counter_type, l_counter_instance_rec.uom_code,
                    l_counter_instance_rec.usage_item_id, l_counter_instance_rec.reading_type,
                    l_counter_instance_rec.direction, l_counter_instance_rec.estimation_id,
                    l_counter_instance_rec.derive_function, l_counter_instance_rec.formula_text,
                    l_counter_instance_rec.derive_counter_id,l_counter_instance_rec.filter_type,
                    l_counter_instance_rec.filter_reading_count, l_counter_instance_rec.filter_time_uom,
                    l_counter_instance_rec.automatic_rollover, l_counter_instance_rec.rollover_last_reading,
                    l_counter_instance_rec.rollover_first_reading, l_counter_instance_rec.tolerance_plus,
                    l_counter_instance_rec.tolerance_minus, l_counter_instance_rec.used_in_scheduling,
                    l_counter_instance_rec.initial_reading, l_counter_instance_rec.default_usage_rate,
                    l_counter_instance_rec.use_past_reading, l_old_counter_instance_rec.counter_id,
                    l_counter_instance_rec.start_date_active, l_counter_instance_rec.end_date_active
                   );

   -- call table handler here

   CSI_COUNTERS_PKG.update_row
   (
     p_counter_id                  => p_counter_instance_rec.counter_id
    ,p_group_id                    => p_counter_instance_rec.group_id
    ,p_counter_type                => p_counter_instance_rec.counter_type
    ,p_initial_reading             => p_counter_instance_rec.initial_reading
    ,p_initial_reading_date        => p_counter_instance_rec.initial_reading_date
    ,p_tolerance_plus              => p_counter_instance_rec.tolerance_plus
    ,p_tolerance_minus             => p_counter_instance_rec.tolerance_minus
    ,p_uom_code                    => p_counter_instance_rec.uom_code
    ,p_derive_counter_id           => p_counter_instance_rec.derive_counter_id
    ,p_derive_function             => p_counter_instance_rec.derive_function
    ,p_derive_property_id          => p_counter_instance_rec.derive_property_id
    ,p_valid_flag                  => p_counter_instance_rec.valid_flag
    ,p_formula_incomplete_flag     => p_counter_instance_rec.formula_incomplete_flag
    ,p_formula_text                => p_counter_instance_rec.formula_text
    ,p_rollover_last_reading       => p_counter_instance_rec.rollover_last_reading
    ,p_rollover_first_reading      => p_counter_instance_rec.rollover_first_reading
    ,p_usage_item_id               => p_counter_instance_rec.usage_item_id
    ,p_ctr_val_max_seq_no          => p_counter_instance_rec.ctr_val_max_seq_no
    ,p_start_date_active           => p_counter_instance_rec.start_date_active
    ,p_end_date_active             => p_counter_instance_rec.end_date_active
    ,p_object_version_number       => p_counter_instance_rec.object_version_number + 1
    ,p_last_update_date            => sysdate
    ,p_last_updated_by             => FND_GLOBAL.USER_ID
    ,p_creation_date               => p_counter_instance_rec.creation_date
    ,p_created_by                  => p_counter_instance_rec.created_by
    ,p_last_update_login           => FND_GLOBAL.USER_ID
    ,p_attribute1                  => p_counter_instance_rec.attribute1
    ,p_attribute2                  => p_counter_instance_rec.attribute2
    ,p_attribute3                  => p_counter_instance_rec.attribute3
    ,p_attribute4                  => p_counter_instance_rec.attribute4
    ,p_attribute5                  => p_counter_instance_rec.attribute5
    ,p_attribute6                  => p_counter_instance_rec.attribute6
    ,p_attribute7                  => p_counter_instance_rec.attribute7
    ,p_attribute8                  => p_counter_instance_rec.attribute8
    ,p_attribute9                  => p_counter_instance_rec.attribute9
    ,p_attribute10                 => p_counter_instance_rec.attribute10
    ,p_attribute11                 => p_counter_instance_rec.attribute11
    ,p_attribute12                 => p_counter_instance_rec.attribute12
    ,p_attribute13                 => p_counter_instance_rec.attribute13
    ,p_attribute14                 => p_counter_instance_rec.attribute14
    ,p_attribute15                 => p_counter_instance_rec.attribute15
    ,p_attribute16                 => p_counter_instance_rec.attribute16
    ,p_attribute17                 => p_counter_instance_rec.attribute17
    ,p_attribute18                 => p_counter_instance_rec.attribute18
    ,p_attribute19                 => p_counter_instance_rec.attribute19
    ,p_attribute20                 => p_counter_instance_rec.attribute20
    ,p_attribute21                 => p_counter_instance_rec.attribute21
    ,p_attribute22                 => p_counter_instance_rec.attribute22
    ,p_attribute23                 => p_counter_instance_rec.attribute23
    ,p_attribute24                 => p_counter_instance_rec.attribute24
    ,p_attribute25                 => p_counter_instance_rec.attribute25
    ,p_attribute26                 => p_counter_instance_rec.attribute26
    ,p_attribute27                 => p_counter_instance_rec.attribute27
    ,p_attribute28                 => p_counter_instance_rec.attribute28
    ,p_attribute29                 => p_counter_instance_rec.attribute29
    ,p_attribute30                 => p_counter_instance_rec.attribute30
    ,p_attribute_category          => p_counter_instance_rec.attribute_category
    ,p_migrated_flag               => p_counter_instance_rec.migrated_flag
    ,p_customer_view               => p_counter_instance_rec.customer_view
    ,p_direction                   => p_counter_instance_rec.direction
    ,p_filter_type                 => p_counter_instance_rec.filter_type
    ,p_filter_reading_count        => p_counter_instance_rec.filter_reading_count
    ,p_filter_time_uom             => p_counter_instance_rec.filter_time_uom
    ,p_estimation_id               => p_counter_instance_rec.estimation_id
    --,p_counter_code                => p_counter_instance_rec.counter_code
    ,p_reading_type                => p_counter_instance_rec.reading_type
    ,p_automatic_rollover          => p_counter_instance_rec.automatic_rollover
    ,p_default_usage_rate          => p_counter_instance_rec.default_usage_rate
    ,p_use_past_reading            => p_counter_instance_rec.use_past_reading
    ,p_used_in_scheduling          => p_counter_instance_rec.used_in_scheduling
    ,p_defaulted_group_id          => p_counter_instance_rec.defaulted_group_id
    ,p_created_from_counter_tmpl_id => p_counter_instance_rec.created_from_counter_tmpl_id
    ,p_SECURITY_GROUP_ID           => p_counter_instance_rec.SECURITY_GROUP_ID
    ,p_STEP_VALUE                  => p_counter_instance_rec.step_value
    ,p_name                        => l_counter_instance_rec.name
    ,p_description                 => p_counter_instance_rec.description
    ,p_time_based_manual_entry     => p_counter_instance_rec.time_based_manual_entry
    ,p_eam_required_flag           => p_counter_instance_rec.eam_required_flag
    ,p_comments                    => NULL
   );
   IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
        ROLLBACK TO update_counter_pvt;
        RETURN;
   END IF;

   -- End of API body

   -- Standard check of p_commit.
   IF FND_API.To_Boolean(nvl(p_commit,FND_API.G_FALSE)) THEN
      COMMIT WORK;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO update_counter_pvt;
      FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count,
                 p_data  => x_msg_data
                );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_counter_pvt;
      FND_MSG_PUB.Count_And_Get
      		(p_count => x_msg_count,
                 p_data  => x_msg_data
                );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_counter_pvt;
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
END update_counter;

--|---------------------------------------------------
--| procedure name: update_ctr_property
--| description :   procedure used to
--|                 update counter properties
--|---------------------------------------------------

PROCEDURE update_ctr_property
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,P_ctr_properties_rec        IN out NOCOPY CSI_CTR_DATASTRUCTURES_PUB.Ctr_properties_rec
    ,x_return_status                OUT    NOCOPY VARCHAR2
    ,x_msg_count                    OUT    NOCOPY NUMBER
    ,x_msg_data                     OUT    NOCOPY VARCHAR2
 )
 IS
    l_api_name                      CONSTANT VARCHAR2(30)   := 'UPDATE_CTR_PROPERTY';
    l_api_version                   CONSTANT NUMBER         := 1.0;
    -- l_debug_level                   NUMBER;
    l_flag                          VARCHAR2(1)             := 'N';
    l_msg_data                      VARCHAR2(2000);
    l_msg_index                     NUMBER;
    l_msg_count                     NUMBER;
    l_count                         NUMBER;
    l_return_message                VARCHAR2(100);

    l_old_ctr_properties_rec      CSI_CTR_DATASTRUCTURES_PUB.ctr_properties_rec;
    l_ctr_properties_rec          CSI_CTR_DATASTRUCTURES_PUB.ctr_properties_rec;
    CURSOR prop_rdgs_cur(p_counter_property_id NUMBER) IS
      SELECT counter_prop_value_id
      FROM CSI_CTR_PROPERTY_READINGS
      WHERE counter_property_id = p_counter_property_id;
    l_prop_rdgs_exist             NUMBER;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  update_ctr_property_pvt;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
   THEN
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

   -- Check the profile option debug_level for debug message reporting
   -- l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

   -- If debug_level = 1 then dump the procedure name
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'update_ctr_property');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 1) THEN
      csi_ctr_gen_utility_pvt.put_line( 'update_ctr_property'       ||
                                     p_api_version         ||'-'||
                                     p_commit              ||'-'||
                                     p_init_msg_list       ||'-'||
                                     p_validation_level );
      csi_ctr_gen_utility_pvt.dump_ctr_properties_rec(p_ctr_properties_rec);
   END IF;

   -- Start of API Body

   SELECT NAME
          ,DESCRIPTION
          ,COUNTER_ID
          ,PROPERTY_DATA_TYPE
          ,IS_NULLABLE
          ,DEFAULT_VALUE
          ,MINIMUM_VALUE
          , MAXIMUM_VALUE
          , UOM_CODE
          , START_DATE_ACTIVE
          , END_DATE_ACTIVE
          , ATTRIBUTE1
          , ATTRIBUTE2
          , ATTRIBUTE3
          , ATTRIBUTE4
          , ATTRIBUTE5
          , ATTRIBUTE6
          , ATTRIBUTE7
          , ATTRIBUTE8
          , ATTRIBUTE9
          , ATTRIBUTE10
          , ATTRIBUTE11
          , ATTRIBUTE12
          , ATTRIBUTE13
          , ATTRIBUTE14
          , ATTRIBUTE15
          , ATTRIBUTE_CATEGORY
          , PROPERTY_LOV_TYPE
          , object_version_number
          --, created_from_ctr_prop_tmpl_id
   INTO   l_old_ctr_properties_rec.NAME
          ,l_old_ctr_properties_rec.DESCRIPTION
          ,l_old_ctr_properties_rec.COUNTER_ID
          ,l_old_ctr_properties_rec.PROPERTY_DATA_TYPE
          ,l_old_ctr_properties_rec.IS_NULLABLE
          ,l_old_ctr_properties_rec.DEFAULT_VALUE
          ,l_old_ctr_properties_rec.MINIMUM_VALUE
          ,l_old_ctr_properties_rec.MAXIMUM_VALUE
          ,l_old_ctr_properties_rec.UOM_CODE
          ,l_old_ctr_properties_rec.START_DATE_ACTIVE
          ,l_old_ctr_properties_rec.END_DATE_ACTIVE
          ,l_old_ctr_properties_rec.ATTRIBUTE1
          ,l_old_ctr_properties_rec.ATTRIBUTE2
          ,l_old_ctr_properties_rec.ATTRIBUTE3
          ,l_old_ctr_properties_rec.ATTRIBUTE4
          ,l_old_ctr_properties_rec.ATTRIBUTE5
          ,l_old_ctr_properties_rec.ATTRIBUTE6
          ,l_old_ctr_properties_rec.ATTRIBUTE7
          ,l_old_ctr_properties_rec.ATTRIBUTE8
          ,l_old_ctr_properties_rec.ATTRIBUTE9
          ,l_old_ctr_properties_rec.ATTRIBUTE10
          ,l_old_ctr_properties_rec.ATTRIBUTE11
          ,l_old_ctr_properties_rec.ATTRIBUTE12
          ,l_old_ctr_properties_rec.ATTRIBUTE13
          ,l_old_ctr_properties_rec.ATTRIBUTE14
          ,l_old_ctr_properties_rec.ATTRIBUTE15
          ,l_old_ctr_properties_rec.ATTRIBUTE_CATEGORY
          ,l_old_ctr_properties_rec.PROPERTY_LOV_TYPE
          ,l_old_ctr_properties_rec.object_version_number
          --,l_old_ctr_properties_rec.created_from_ctr_prop_tmpl_id
   FROM   csi_counter_properties_vl
   WHERE  counter_property_id = p_ctr_properties_rec.counter_property_id
   FOR UPDATE OF OBJECT_VERSION_NUMBER;
   IF SQL%NOTFOUND THEN
     csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_PROP_INVALID');
   END IF;

   l_ctr_properties_rec := p_ctr_properties_rec;

   IF p_ctr_properties_rec.NAME = FND_API.G_MISS_CHAR THEN
      l_ctr_properties_rec.NAME := NULL;
   ELSIF p_ctr_properties_rec.NAME  IS NULL THEN
      l_ctr_properties_rec.NAME := l_old_ctr_properties_rec.NAME;
   END IF;
   IF p_ctr_properties_rec.DESCRIPTION = FND_API.G_MISS_CHAR THEN
      l_ctr_properties_rec.DESCRIPTION := NULL;
   ELSIF p_ctr_properties_rec.DESCRIPTION IS NULL THEN
      l_ctr_properties_rec.DESCRIPTION := l_old_ctr_properties_rec.DESCRIPTION;
   END IF;
   IF p_ctr_properties_rec.COUNTER_ID = FND_API.G_MISS_NUM THEN
      l_ctr_properties_rec.COUNTER_ID := NULL;
   ELSIF p_ctr_properties_rec.COUNTER_ID IS NULL THEN
      l_ctr_properties_rec.COUNTER_ID := l_old_ctr_properties_rec.COUNTER_ID;
   END IF;
   IF p_ctr_properties_rec.PROPERTY_DATA_TYPE = FND_API.G_MISS_CHAR THEN
      l_ctr_properties_rec.PROPERTY_DATA_TYPE := NULL;
   ELSIF p_ctr_properties_rec.PROPERTY_DATA_TYPE IS NULL THEN
      l_ctr_properties_rec.PROPERTY_DATA_TYPE := l_old_ctr_properties_rec.PROPERTY_DATA_TYPE;
   END IF;
   IF p_ctr_properties_rec.IS_NULLABLE = FND_API.G_MISS_CHAR THEN
      l_ctr_properties_rec.IS_NULLABLE := NULL;
   ELSIF p_ctr_properties_rec.IS_NULLABLE IS NULL THEN
      l_ctr_properties_rec.IS_NULLABLE := l_old_ctr_properties_rec.IS_NULLABLE;
   END IF;
   IF p_ctr_properties_rec.DEFAULT_VALUE = FND_API.G_MISS_CHAR THEN
      l_ctr_properties_rec.DEFAULT_VALUE := NULL;
   ELSIF p_ctr_properties_rec.DEFAULT_VALUE IS NULL THEN
      l_ctr_properties_rec.DEFAULT_VALUE := l_old_ctr_properties_rec.DEFAULT_VALUE;
   END IF;
   IF p_ctr_properties_rec.MINIMUM_VALUE = FND_API.G_MISS_CHAR THEN
      l_ctr_properties_rec.MINIMUM_VALUE := NULL;
   ELSIF p_ctr_properties_rec.MINIMUM_VALUE IS NULL THEN
      l_ctr_properties_rec.MINIMUM_VALUE := l_old_ctr_properties_rec.MINIMUM_VALUE;
   END IF;
   IF p_ctr_properties_rec.MAXIMUM_VALUE = FND_API.G_MISS_CHAR THEN
      l_ctr_properties_rec.MAXIMUM_VALUE := NULL;
   ELSIF p_ctr_properties_rec.MAXIMUM_VALUE IS NULL THEN
      l_ctr_properties_rec.MAXIMUM_VALUE := l_old_ctr_properties_rec.MAXIMUM_VALUE;
   END IF;
   IF p_ctr_properties_rec.UOM_CODE = FND_API.G_MISS_CHAR THEN
      l_ctr_properties_rec.UOM_CODE := NULL;
   ELSIF p_ctr_properties_rec.UOM_CODE IS NULL THEN
      l_ctr_properties_rec.UOM_CODE := l_old_ctr_properties_rec.UOM_CODE;
   END IF;
   IF p_ctr_properties_rec.START_DATE_ACTIVE = FND_API.G_MISS_DATE THEN
      l_ctr_properties_rec.START_DATE_ACTIVE := NULL;
   ELSIF p_ctr_properties_rec.START_DATE_ACTIVE IS NULL THEN
      l_ctr_properties_rec.START_DATE_ACTIVE := l_old_ctr_properties_rec.START_DATE_ACTIVE;
   END IF;
   IF p_ctr_properties_rec.END_DATE_ACTIVE = FND_API.G_MISS_DATE THEN
      l_ctr_properties_rec.END_DATE_ACTIVE := NULL;
   ELSIF p_ctr_properties_rec.END_DATE_ACTIVE IS NULL THEN
      l_ctr_properties_rec.END_DATE_ACTIVE := l_old_ctr_properties_rec.END_DATE_ACTIVE;
   END IF;
   IF p_ctr_properties_rec.PROPERTY_LOV_TYPE = FND_API.G_MISS_CHAR THEN
      l_ctr_properties_rec.PROPERTY_LOV_TYPE := NULL;
   ELSIF p_ctr_properties_rec.PROPERTY_LOV_TYPE IS NULL THEN
      l_ctr_properties_rec.PROPERTY_LOV_TYPE := l_old_ctr_properties_rec.PROPERTY_LOV_TYPE;
   END IF;
   IF p_ctr_properties_rec.ATTRIBUTE1 = FND_API.G_MISS_CHAR THEN
      l_ctr_properties_rec.ATTRIBUTE1 := NULL;
   ELSIF p_ctr_properties_rec.ATTRIBUTE1 IS NULL THEN
      l_ctr_properties_rec.ATTRIBUTE1 := l_old_ctr_properties_rec.ATTRIBUTE1;
   END IF;
   IF p_ctr_properties_rec.ATTRIBUTE2 = FND_API.G_MISS_CHAR THEN
      l_ctr_properties_rec.ATTRIBUTE2 := NULL;
   ELSIF p_ctr_properties_rec.ATTRIBUTE2 IS NULL THEN
      l_ctr_properties_rec.ATTRIBUTE2 := l_old_ctr_properties_rec.ATTRIBUTE2;
   END IF;
   IF p_ctr_properties_rec.ATTRIBUTE3 = FND_API.G_MISS_CHAR THEN
      l_ctr_properties_rec.ATTRIBUTE3 := NULL;
   ELSIF p_ctr_properties_rec.ATTRIBUTE3 IS NULL THEN
      l_ctr_properties_rec.ATTRIBUTE3 := l_old_ctr_properties_rec.ATTRIBUTE3;
   END IF;
   IF p_ctr_properties_rec.ATTRIBUTE4 = FND_API.G_MISS_CHAR THEN
      l_ctr_properties_rec.ATTRIBUTE4 := NULL;
   ELSIF p_ctr_properties_rec.ATTRIBUTE4 IS NULL THEN
      l_ctr_properties_rec.ATTRIBUTE4 := l_old_ctr_properties_rec.ATTRIBUTE4;
   END IF;
   IF p_ctr_properties_rec.ATTRIBUTE5 = FND_API.G_MISS_CHAR THEN
      l_ctr_properties_rec.ATTRIBUTE5 := NULL;
   ELSIF p_ctr_properties_rec.ATTRIBUTE5 IS NULL THEN
      l_ctr_properties_rec.ATTRIBUTE5 := l_old_ctr_properties_rec.ATTRIBUTE5;
   END IF;
   IF p_ctr_properties_rec.ATTRIBUTE6 = FND_API.G_MISS_CHAR THEN
      l_ctr_properties_rec.ATTRIBUTE6 := NULL;
   ELSIF p_ctr_properties_rec.ATTRIBUTE6 IS NULL THEN
      l_ctr_properties_rec.ATTRIBUTE6 := l_old_ctr_properties_rec.ATTRIBUTE6;
   END IF;
   IF p_ctr_properties_rec.ATTRIBUTE7 = FND_API.G_MISS_CHAR THEN
      l_ctr_properties_rec.ATTRIBUTE7 := NULL;
   ELSIF p_ctr_properties_rec.ATTRIBUTE7 IS NULL THEN
      l_ctr_properties_rec.ATTRIBUTE7 := l_old_ctr_properties_rec.ATTRIBUTE7;
   END IF;
   IF p_ctr_properties_rec.ATTRIBUTE8 = FND_API.G_MISS_CHAR THEN
      l_ctr_properties_rec.ATTRIBUTE8 := NULL;
   ELSIF p_ctr_properties_rec.ATTRIBUTE8 IS NULL THEN
      l_ctr_properties_rec.ATTRIBUTE8 := l_old_ctr_properties_rec.ATTRIBUTE8;
   END IF;
   IF p_ctr_properties_rec.ATTRIBUTE9 = FND_API.G_MISS_CHAR THEN
      l_ctr_properties_rec.ATTRIBUTE9 := NULL;
   ELSIF p_ctr_properties_rec.ATTRIBUTE9 IS NULL THEN
      l_ctr_properties_rec.ATTRIBUTE9 := l_old_ctr_properties_rec.ATTRIBUTE9;
   END IF;
   IF p_ctr_properties_rec.ATTRIBUTE10 = FND_API.G_MISS_CHAR THEN
      l_ctr_properties_rec.ATTRIBUTE10 := NULL;
   ELSIF p_ctr_properties_rec.ATTRIBUTE10 IS NULL THEN
      l_ctr_properties_rec.ATTRIBUTE10 := l_old_ctr_properties_rec.ATTRIBUTE10;
   END IF;
   IF p_ctr_properties_rec.ATTRIBUTE11 = FND_API.G_MISS_CHAR THEN
      l_ctr_properties_rec.ATTRIBUTE11 := NULL;
   ELSIF p_ctr_properties_rec.ATTRIBUTE11 IS NULL THEN
      l_ctr_properties_rec.ATTRIBUTE11 := l_old_ctr_properties_rec.ATTRIBUTE11;
   END IF;
   IF p_ctr_properties_rec.ATTRIBUTE12 = FND_API.G_MISS_CHAR THEN
      l_ctr_properties_rec.ATTRIBUTE12 := NULL;
   ELSIF p_ctr_properties_rec.ATTRIBUTE12 IS NULL THEN
      l_ctr_properties_rec.ATTRIBUTE12 := l_old_ctr_properties_rec.ATTRIBUTE12;
   END IF;
   IF p_ctr_properties_rec.ATTRIBUTE13 = FND_API.G_MISS_CHAR THEN
      l_ctr_properties_rec.ATTRIBUTE13 := NULL;
   ELSIF p_ctr_properties_rec.ATTRIBUTE13 IS NULL THEN
      l_ctr_properties_rec.ATTRIBUTE13 := l_old_ctr_properties_rec.ATTRIBUTE13;
   END IF;
   IF p_ctr_properties_rec.ATTRIBUTE14 = FND_API.G_MISS_CHAR THEN
      l_ctr_properties_rec.ATTRIBUTE14 := NULL;
   ELSIF p_ctr_properties_rec.ATTRIBUTE14 IS NULL THEN
      l_ctr_properties_rec.ATTRIBUTE14 := l_old_ctr_properties_rec.ATTRIBUTE14;
   END IF;
   IF p_ctr_properties_rec.ATTRIBUTE15 = FND_API.G_MISS_CHAR THEN
      l_ctr_properties_rec.ATTRIBUTE15 := NULL;
   ELSIF p_ctr_properties_rec.ATTRIBUTE15 IS NULL THEN
      l_ctr_properties_rec.ATTRIBUTE15 := l_old_ctr_properties_rec.ATTRIBUTE15;
   END IF;
   IF p_ctr_properties_rec.ATTRIBUTE_CATEGORY = FND_API.G_MISS_CHAR THEN
      l_ctr_properties_rec.ATTRIBUTE_CATEGORY := NULL;
   ELSIF p_ctr_properties_rec.ATTRIBUTE_CATEGORY IS NULL THEN
      l_ctr_properties_rec.ATTRIBUTE_CATEGORY := l_old_ctr_properties_rec.ATTRIBUTE_CATEGORY;
   END IF;
   IF p_ctr_properties_rec.created_from_ctr_prop_tmpl_id = FND_API.G_MISS_NUM THEN
      l_ctr_properties_rec.created_from_ctr_prop_tmpl_id := NULL;
   ELSIF p_ctr_properties_rec.created_from_ctr_prop_tmpl_id IS NULL THEN
      l_ctr_properties_rec.created_from_ctr_prop_tmpl_id := l_old_ctr_properties_rec.created_from_ctr_prop_tmpl_id;
   END IF;
   IF p_ctr_properties_rec.object_version_number = FND_API.G_MISS_NUM THEN
      l_ctr_properties_rec.object_version_number := NULL;
   ELSIF p_ctr_properties_rec.object_version_number IS NULL THEN
      l_ctr_properties_rec.object_version_number := l_old_ctr_properties_rec.object_version_number;
   END IF;

   IF l_old_ctr_properties_rec.object_version_number <> nvl(l_ctr_properties_rec.object_version_number,0) THEN
      csi_ctr_gen_utility_pvt.put_line('Object version mismatch in update counter');
      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_OBJ_VER_MISMATCH');
   END IF;

   -- do validation here

   IF l_ctr_properties_rec.counter_id <> l_old_ctr_properties_rec.counter_id THEN
      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_NOT_UPDATABLE');
	  END IF;

   -- validate unique property name within counter
   Validate_Unique_ctrprop(l_ctr_properties_rec.NAME,l_ctr_properties_rec.COUNTER_ID,p_ctr_properties_rec.counter_property_id);

   IF l_ctr_properties_rec.PROPERTY_DATA_TYPE <> l_old_ctr_properties_rec.PROPERTY_DATA_TYPE THEN
      OPEN prop_rdgs_cur(p_ctr_properties_rec.counter_property_id);
      FETCH prop_rdgs_cur into l_prop_rdgs_exist;
      CLOSE prop_rdgs_cur;
      IF l_prop_rdgs_exist is not null then
        -- Counter property readings exist for this counter property. You cannot
        -- change the property datatype to something different.
        csi_ctr_gen_utility_pvt.put_line('Ctr prop rdgs exist for this ctr prop. Cannot change property datatype...');
         csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_PROP_DTYP_NOT_UPD');
      END IF;
	  END IF;

   -- validate property date type in char,number,date
   if l_ctr_properties_rec.PROPERTY_DATA_TYPE not in ('CHAR', 'NUMBER', 'DATE') then
       csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_INV_PROP_DATA_TYPE');
   end if;

   -- Validate start date
   IF l_ctr_properties_rec.START_DATE_ACTIVE IS NULL THEN
      CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_STDATE_INVALID');
   ELSIF l_ctr_properties_rec.START_DATE_ACTIVE > sysdate THEN
      CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INVALID_START_DATE');
   END IF;

   -- Validate values for data type
   Validate_Data_Type(l_ctr_properties_rec.PROPERTY_DATA_TYPE, l_ctr_properties_rec.default_value,
                      l_ctr_properties_rec.minimum_value, l_ctr_properties_rec.maximum_value);

   -- Validate uom
   if l_ctr_properties_rec.uom_code is not null then
     Validate_UOM(l_ctr_properties_rec.uom_code);
   end if;

   -- call table handler here

   CSI_COUNTER_PROPERTIES_PKG.update_row
   (
     p_counter_property_id             => p_ctr_properties_rec.counter_property_id
     ,p_counter_id                     => p_ctr_properties_rec.counter_id
     ,p_property_data_type             => p_ctr_properties_rec.property_data_type
     ,p_is_nullable                    => p_ctr_properties_rec.is_nullable
     ,p_default_value                  => p_ctr_properties_rec.default_value
     ,p_minimum_value                  => p_ctr_properties_rec.minimum_value
     ,p_maximum_value                  => p_ctr_properties_rec.maximum_value
     ,p_uom_code                       => p_ctr_properties_rec.uom_code
     ,p_start_date_active              => p_ctr_properties_rec.start_date_active
     ,p_end_date_active                => p_ctr_properties_rec.end_date_active
     ,p_object_version_number          => p_ctr_properties_rec.object_version_number + 1
     ,p_SECURITY_GROUP_ID              => null
     ,p_last_update_date               => sysdate
     ,p_last_updated_by                => FND_GLOBAL.USER_ID
     ,p_creation_date                  => p_ctr_properties_rec.creation_date
     ,p_created_by                     => p_ctr_properties_rec.created_by
     ,p_last_update_login              => FND_GLOBAL.USER_ID
     ,p_attribute1                     => p_ctr_properties_rec.attribute1
     ,p_attribute2                     => p_ctr_properties_rec.attribute2
     ,p_attribute3                     => p_ctr_properties_rec.attribute3
     ,p_attribute4                     => p_ctr_properties_rec.attribute4
     ,p_attribute5                     => p_ctr_properties_rec.attribute5
     ,p_attribute6                     => p_ctr_properties_rec.attribute6
     ,p_attribute7                     => p_ctr_properties_rec.attribute7
     ,p_attribute8                     => p_ctr_properties_rec.attribute8
     ,p_attribute9                     => p_ctr_properties_rec.attribute9
     ,p_attribute10                    => p_ctr_properties_rec.attribute10
     ,p_attribute11                    => p_ctr_properties_rec.attribute11
     ,p_attribute12                    => p_ctr_properties_rec.attribute12
     ,p_attribute13                    => p_ctr_properties_rec.attribute13
     ,p_attribute14                    => p_ctr_properties_rec.attribute14
     ,p_attribute15                    => p_ctr_properties_rec.attribute15
     ,p_attribute_category             => p_ctr_properties_rec.attribute_category
     ,p_migrated_flag                  => p_ctr_properties_rec.migrated_flag
     ,p_property_lov_type              => p_ctr_properties_rec.property_lov_type
     ,p_name                           => p_ctr_properties_rec.name
     ,p_description                    => p_ctr_properties_rec.description
     ,p_create_from_ctr_prop_tmpl_id   => p_ctr_properties_rec.created_from_ctr_prop_tmpl_id
   );
   IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
       ROLLBACK TO update_ctr_property_pvt;
       RETURN;
   END IF;

   -- End of API body

   -- Standard check of p_commit.
   IF FND_API.To_Boolean(nvl(p_commit,FND_API.G_FALSE)) THEN
      COMMIT WORK;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO update_ctr_property_pvt;
      FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count,
                 p_data  => x_msg_data
                );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_ctr_property_pvt;
      FND_MSG_PUB.Count_And_Get
      		(p_count => x_msg_count,
                 p_data  => x_msg_data
                );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_ctr_property_pvt;
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
END update_ctr_property;

--|---------------------------------------------------
--| procedure name: update_ctr_associations
--| description :   procedure used to
--|                 update counter associations
--|---------------------------------------------------

PROCEDURE update_ctr_associations
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,P_counter_associations_rec IN out NOCOPY CSI_CTR_DATASTRUCTURES_PUB.counter_associations_rec
    ,x_return_status               OUT    NOCOPY VARCHAR2
    ,x_msg_count                   OUT    NOCOPY NUMBER
    ,x_msg_data                    OUT    NOCOPY VARCHAR2
 )
 IS
    l_api_name                      CONSTANT VARCHAR2(30)   := 'UPDATE_CTR_ASSOCIATIONS';
    l_api_version                   CONSTANT NUMBER         := 1.0;
    -- l_debug_level                   NUMBER;
    l_flag                          VARCHAR2(1)             := 'N';
    l_msg_data                      VARCHAR2(2000);
    l_msg_index                     NUMBER;
    l_msg_count                     NUMBER;
    l_count                         NUMBER;
    l_return_message                VARCHAR2(100);

    l_old_counter_associations_rec  CSI_CTR_DATASTRUCTURES_PUB.counter_associations_rec;
    l_counter_associations_rec  CSI_CTR_DATASTRUCTURES_PUB.counter_associations_rec;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  update_ctr_associations_pvt;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
   THEN
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

   -- Check the profile option debug_level for debug message reporting
   -- l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

   -- If debug_level = 1 then dump the procedure name
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_gen_utility_pvt.put_line( 'update_ctr_associations');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 1) THEN
      csi_gen_utility_pvt.put_line( 'update_ctr_associations'       ||
                                     p_api_version         ||'-'||
                                     p_commit              ||'-'||
                                     p_init_msg_list       ||'-'||
                                     p_validation_level );
      csi_ctr_gen_utility_pvt.dump_counter_associations_rec(p_counter_associations_rec);
   END IF;

   -- Start of API Body
   SELECT   SOURCE_OBJECT_CODE
          , SOURCE_OBJECT_ID
          , COUNTER_ID
          , START_DATE_ACTIVE
          , END_DATE_ACTIVE
          , ATTRIBUTE1
          , ATTRIBUTE2
          , ATTRIBUTE3
          , ATTRIBUTE4
          , ATTRIBUTE5
          , ATTRIBUTE6
          , ATTRIBUTE7
          , ATTRIBUTE8
          , ATTRIBUTE9
          , ATTRIBUTE10
          , ATTRIBUTE11
          , ATTRIBUTE12
          , ATTRIBUTE13
          , ATTRIBUTE14
          , ATTRIBUTE15
          , ATTRIBUTE_CATEGORY
          , object_version_number
          , maint_organization_id
          , primary_failure_flag
   INTO     l_old_counter_associations_rec.SOURCE_OBJECT_CODE
          , l_old_counter_associations_rec.SOURCE_OBJECT_ID
          , l_old_counter_associations_rec.COUNTER_ID
          , l_old_counter_associations_rec.START_DATE_ACTIVE
          , l_old_counter_associations_rec.END_DATE_ACTIVE
          , l_old_counter_associations_rec.ATTRIBUTE1
          , l_old_counter_associations_rec.ATTRIBUTE2
          , l_old_counter_associations_rec.ATTRIBUTE3
          , l_old_counter_associations_rec.ATTRIBUTE4
          , l_old_counter_associations_rec.ATTRIBUTE5
          , l_old_counter_associations_rec.ATTRIBUTE6
          , l_old_counter_associations_rec.ATTRIBUTE7
          , l_old_counter_associations_rec.ATTRIBUTE8
          , l_old_counter_associations_rec.ATTRIBUTE9
          , l_old_counter_associations_rec.ATTRIBUTE10
          , l_old_counter_associations_rec.ATTRIBUTE11
          , l_old_counter_associations_rec.ATTRIBUTE12
          , l_old_counter_associations_rec.ATTRIBUTE13
          , l_old_counter_associations_rec.ATTRIBUTE14
          , l_old_counter_associations_rec.ATTRIBUTE15
          , l_old_counter_associations_rec.ATTRIBUTE_CATEGORY
          , l_old_counter_associations_rec.object_version_number
          , l_old_counter_associations_rec.maint_organization_id
          , l_old_counter_associations_rec.primary_failure_flag
   FROM CSI_COUNTER_ASSOCIATIONS
   WHERE INSTANCE_ASSOCIATION_ID = P_counter_associations_rec.INSTANCE_ASSOCIATION_ID
   FOR UPDATE OF OBJECT_VERSION_NUMBER;
   IF SQL%NOTFOUND THEN
     csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_ASSOC_INVALID');
   END IF;

   l_counter_associations_rec :=  p_counter_associations_rec;

   IF p_counter_associations_rec.SOURCE_OBJECT_CODE = FND_API.G_MISS_CHAR THEN
      l_counter_associations_rec.SOURCE_OBJECT_CODE := NULL;
   ELSIF p_counter_associations_rec.SOURCE_OBJECT_CODE  IS NULL THEN
      l_counter_associations_rec.SOURCE_OBJECT_CODE := l_old_counter_associations_rec.SOURCE_OBJECT_CODE;
   END IF;
   IF p_counter_associations_rec.SOURCE_OBJECT_ID = FND_API.G_MISS_NUM THEN
      l_counter_associations_rec.SOURCE_OBJECT_ID := NULL;
   ELSIF p_counter_associations_rec.SOURCE_OBJECT_ID  IS NULL THEN
      l_counter_associations_rec.SOURCE_OBJECT_ID := l_old_counter_associations_rec.SOURCE_OBJECT_ID;
   END IF;
   IF p_counter_associations_rec.COUNTER_ID = FND_API.G_MISS_NUM THEN
      l_counter_associations_rec.COUNTER_ID := NULL;
   ELSIF p_counter_associations_rec.COUNTER_ID  IS NULL THEN
      l_counter_associations_rec.COUNTER_ID := l_old_counter_associations_rec.COUNTER_ID;
   END IF;
   IF p_counter_associations_rec.START_DATE_ACTIVE = FND_API.G_MISS_DATE THEN
      l_counter_associations_rec.START_DATE_ACTIVE := NULL;
   ELSIF p_counter_associations_rec.START_DATE_ACTIVE IS NULL THEN
      l_counter_associations_rec.START_DATE_ACTIVE := l_old_counter_associations_rec.START_DATE_ACTIVE;
   END IF;
   IF p_counter_associations_rec.END_DATE_ACTIVE = FND_API.G_MISS_DATE THEN
      l_counter_associations_rec.END_DATE_ACTIVE := NULL;
   ELSIF p_counter_associations_rec.END_DATE_ACTIVE IS NULL THEN
      l_counter_associations_rec.END_DATE_ACTIVE := l_old_counter_associations_rec.END_DATE_ACTIVE;
   END IF;
   IF p_counter_associations_rec.ATTRIBUTE1 = FND_API.G_MISS_CHAR THEN
      l_counter_associations_rec.ATTRIBUTE1 := NULL;
   ELSIF p_counter_associations_rec.ATTRIBUTE1 IS NULL THEN
      l_counter_associations_rec.ATTRIBUTE1 := l_old_counter_associations_rec.ATTRIBUTE1;
   END IF;
   IF p_counter_associations_rec.ATTRIBUTE2 = FND_API.G_MISS_CHAR THEN
      l_counter_associations_rec.ATTRIBUTE2 := NULL;
   ELSIF p_counter_associations_rec.ATTRIBUTE2 IS NULL THEN
      l_counter_associations_rec.ATTRIBUTE2 := l_old_counter_associations_rec.ATTRIBUTE2;
   END IF;
   IF p_counter_associations_rec.ATTRIBUTE3 = FND_API.G_MISS_CHAR THEN
      l_counter_associations_rec.ATTRIBUTE3 := NULL;
   ELSIF p_counter_associations_rec.ATTRIBUTE3 IS NULL THEN
      l_counter_associations_rec.ATTRIBUTE3 := l_old_counter_associations_rec.ATTRIBUTE3;
   END IF;
   IF p_counter_associations_rec.ATTRIBUTE4 = FND_API.G_MISS_CHAR THEN
      l_counter_associations_rec.ATTRIBUTE4 := NULL;
   ELSIF p_counter_associations_rec.ATTRIBUTE4 IS NULL THEN
      l_counter_associations_rec.ATTRIBUTE4 := l_old_counter_associations_rec.ATTRIBUTE4;
   END IF;
   IF p_counter_associations_rec.ATTRIBUTE5 = FND_API.G_MISS_CHAR THEN
      l_counter_associations_rec.ATTRIBUTE5 := NULL;
   ELSIF p_counter_associations_rec.ATTRIBUTE5 IS NULL THEN
      l_counter_associations_rec.ATTRIBUTE5 := l_old_counter_associations_rec.ATTRIBUTE5;
   END IF;
   IF p_counter_associations_rec.ATTRIBUTE6 = FND_API.G_MISS_CHAR THEN
      l_counter_associations_rec.ATTRIBUTE6 := NULL;
   ELSIF p_counter_associations_rec.ATTRIBUTE6 IS NULL THEN
      l_counter_associations_rec.ATTRIBUTE6 := l_old_counter_associations_rec.ATTRIBUTE6;
   END IF;
   IF p_counter_associations_rec.ATTRIBUTE7 = FND_API.G_MISS_CHAR THEN
      l_counter_associations_rec.ATTRIBUTE7 := NULL;
   ELSIF p_counter_associations_rec.ATTRIBUTE7 IS NULL THEN
      l_counter_associations_rec.ATTRIBUTE7 := l_old_counter_associations_rec.ATTRIBUTE7;
   END IF;
   IF p_counter_associations_rec.ATTRIBUTE8 = FND_API.G_MISS_CHAR THEN
      l_counter_associations_rec.ATTRIBUTE8 := NULL;
   ELSIF p_counter_associations_rec.ATTRIBUTE8 IS NULL THEN
      l_counter_associations_rec.ATTRIBUTE8 := l_old_counter_associations_rec.ATTRIBUTE8;
   END IF;
   IF p_counter_associations_rec.ATTRIBUTE9 = FND_API.G_MISS_CHAR THEN
      l_counter_associations_rec.ATTRIBUTE9 := NULL;
   ELSIF p_counter_associations_rec.ATTRIBUTE9 IS NULL THEN
      l_counter_associations_rec.ATTRIBUTE9 := l_old_counter_associations_rec.ATTRIBUTE9;
   END IF;
   IF p_counter_associations_rec.ATTRIBUTE10 = FND_API.G_MISS_CHAR THEN
      l_counter_associations_rec.ATTRIBUTE10 := NULL;
   ELSIF p_counter_associations_rec.ATTRIBUTE10 IS NULL THEN
      l_counter_associations_rec.ATTRIBUTE10 := l_old_counter_associations_rec.ATTRIBUTE10;
   END IF;
   IF p_counter_associations_rec.ATTRIBUTE11 = FND_API.G_MISS_CHAR THEN
      l_counter_associations_rec.ATTRIBUTE11 := NULL;
   ELSIF p_counter_associations_rec.ATTRIBUTE11 IS NULL THEN
      l_counter_associations_rec.ATTRIBUTE11 := l_old_counter_associations_rec.ATTRIBUTE11;
   END IF;
   IF p_counter_associations_rec.ATTRIBUTE12 = FND_API.G_MISS_CHAR THEN
      l_counter_associations_rec.ATTRIBUTE12 := NULL;
   ELSIF p_counter_associations_rec.ATTRIBUTE12 IS NULL THEN
      l_counter_associations_rec.ATTRIBUTE12 := l_old_counter_associations_rec.ATTRIBUTE12;
   END IF;
   IF p_counter_associations_rec.ATTRIBUTE13 = FND_API.G_MISS_CHAR THEN
      l_counter_associations_rec.ATTRIBUTE13 := NULL;
   ELSIF p_counter_associations_rec.ATTRIBUTE13 IS NULL THEN
      l_counter_associations_rec.ATTRIBUTE13 := l_old_counter_associations_rec.ATTRIBUTE13;
   END IF;
   IF p_counter_associations_rec.ATTRIBUTE14 = FND_API.G_MISS_CHAR THEN
      l_counter_associations_rec.ATTRIBUTE14 := NULL;
   ELSIF p_counter_associations_rec.ATTRIBUTE14 IS NULL THEN
      l_counter_associations_rec.ATTRIBUTE14 := l_old_counter_associations_rec.ATTRIBUTE14;
   END IF;
   IF p_counter_associations_rec.ATTRIBUTE15 = FND_API.G_MISS_CHAR THEN
      l_counter_associations_rec.ATTRIBUTE15 := NULL;
   ELSIF p_counter_associations_rec.ATTRIBUTE15 IS NULL THEN
      l_counter_associations_rec.ATTRIBUTE15 := l_old_counter_associations_rec.ATTRIBUTE15;
   END IF;
   IF p_counter_associations_rec.ATTRIBUTE_CATEGORY = FND_API.G_MISS_CHAR THEN
      l_counter_associations_rec.ATTRIBUTE_CATEGORY := NULL;
   ELSIF p_counter_associations_rec.ATTRIBUTE_CATEGORY IS NULL THEN
      l_counter_associations_rec.ATTRIBUTE_CATEGORY := l_old_counter_associations_rec.ATTRIBUTE_CATEGORY;
   END IF;
   IF p_counter_associations_rec.object_version_number = FND_API.G_MISS_NUM THEN
      l_counter_associations_rec.object_version_number := NULL;
   ELSIF p_counter_associations_rec.object_version_number IS NULL THEN
      l_counter_associations_rec.object_version_number := l_old_counter_associations_rec.object_version_number;
   END IF;

   IF p_counter_associations_rec.maint_organization_id = FND_API.G_MISS_NUM THEN
      l_counter_associations_rec.maint_organization_id := NULL;
   ELSIF p_counter_associations_rec.maint_organization_id IS NULL THEN
      l_counter_associations_rec.maint_organization_id := l_old_counter_associations_rec.maint_organization_id;
   END IF;

   IF l_old_counter_associations_rec.object_version_number <> nvl(l_counter_associations_rec.object_version_number,0) THEN
      csi_ctr_gen_utility_pvt.put_line('Object version mismatch in update counter');
      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_OBJ_VER_MISMATCH');
   END IF;

   IF p_counter_associations_rec.primary_failure_flag = FND_API.G_MISS_CHAR THEN
      l_counter_associations_rec.primary_failure_flag := NULL;
   ELSIF p_counter_associations_rec.primary_failure_flag IS NULL THEN
      l_counter_associations_rec.primary_failure_flag := l_old_counter_associations_rec.primary_failure_flag;
   END IF;

   -- do validation here
   IF l_counter_associations_rec.counter_id <> l_old_counter_associations_rec.counter_id THEN
      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_ASC_NOT_UPDATABLE');
	  END IF;

   IF l_counter_associations_rec.SOURCE_OBJECT_CODE <> l_old_counter_associations_rec.SOURCE_OBJECT_CODE THEN
      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_SOC_ASC_NOT_UPDATABLE');
	  END IF;

   IF l_counter_associations_rec.SOURCE_OBJECT_ID <> l_old_counter_associations_rec.SOURCE_OBJECT_ID THEN
      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_SOI_ASC_NOT_UPDATABLE');
	  END IF;

   -- Validate start date
   IF l_counter_associations_rec.START_DATE_ACTIVE IS NULL THEN
      CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_STDATE_INVALID');
   ELSIF l_counter_associations_rec.START_DATE_ACTIVE > sysdate THEN
      CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INVALID_START_DATE');
   END IF;

   -- call table handler here
   CSI_COUNTER_ASSOCIATIONS_PKG.UPDATE_ROW
   (
    p_INSTANCE_ASSOCIATION_ID   => p_counter_associations_rec.INSTANCE_ASSOCIATION_ID
    ,p_SOURCE_OBJECT_CODE        =>  p_counter_associations_rec.SOURCE_OBJECT_CODE
    ,p_SOURCE_OBJECT_ID          =>  p_counter_associations_rec.SOURCE_OBJECT_ID
    ,p_OBJECT_VERSION_NUMBER     =>  p_counter_associations_rec.OBJECT_VERSION_NUMBER + 1
    ,p_LAST_UPDATE_DATE            =>  sysdate
    ,p_LAST_UPDATED_BY             =>  FND_GLOBAL.USER_ID
    ,p_LAST_UPDATE_LOGIN           =>  FND_GLOBAL.USER_ID
    ,p_CREATION_DATE               =>  p_counter_associations_rec.CREATION_DATE
    ,p_CREATED_BY                  =>  p_counter_associations_rec.CREATED_BY
    ,p_ATTRIBUTE1                  =>  p_counter_associations_rec.ATTRIBUTE1
    ,p_ATTRIBUTE2                  =>  p_counter_associations_rec.ATTRIBUTE2
    ,p_ATTRIBUTE3                  =>  p_counter_associations_rec.ATTRIBUTE3
    ,p_ATTRIBUTE4                  =>  p_counter_associations_rec.ATTRIBUTE4
    ,p_ATTRIBUTE5                  =>  p_counter_associations_rec.ATTRIBUTE5
    ,p_ATTRIBUTE6                  =>  p_counter_associations_rec.ATTRIBUTE6
    ,p_ATTRIBUTE7                  =>  p_counter_associations_rec.ATTRIBUTE7
    ,p_ATTRIBUTE8                  =>  p_counter_associations_rec.ATTRIBUTE8
    ,p_ATTRIBUTE9                  =>  p_counter_associations_rec.ATTRIBUTE9
    ,p_ATTRIBUTE10                 =>  p_counter_associations_rec.ATTRIBUTE10
    ,p_ATTRIBUTE11                 =>  p_counter_associations_rec.ATTRIBUTE11
    ,p_ATTRIBUTE12                 =>  p_counter_associations_rec.ATTRIBUTE12
    ,p_ATTRIBUTE13                 =>  p_counter_associations_rec.ATTRIBUTE13
    ,p_ATTRIBUTE14                 =>  p_counter_associations_rec.ATTRIBUTE14
    ,p_ATTRIBUTE15                 =>  p_counter_associations_rec.ATTRIBUTE15
    ,p_ATTRIBUTE_CATEGORY          =>  p_counter_associations_rec.ATTRIBUTE_CATEGORY
    ,p_SECURITY_GROUP_ID           =>  p_counter_associations_rec.SECURITY_GROUP_ID
    ,p_MIGRATED_FLAG               =>  p_counter_associations_rec.MIGRATED_FLAG
    ,p_COUNTER_ID                  =>  p_counter_associations_rec.COUNTER_ID
    ,p_START_DATE_ACTIVE           =>  p_counter_associations_rec.START_DATE_ACTIVE
    ,p_END_DATE_ACTIVE             =>  p_counter_associations_rec.END_DATE_ACTIVE
    ,p_MAINT_ORGANIZATION_ID       =>  p_counter_associations_rec.MAINT_ORGANIZATION_ID
    ,p_PRIMARY_FAILURE_FLAG        =>  p_counter_associations_rec.PRIMARY_FAILURE_FLAG
   );
   IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
       ROLLBACK TO update_ctr_associations_pvt;
       RETURN;
   END IF;

  -- End of API body
  -- Standard check of p_commit.
  IF FND_API.To_Boolean(nvl(p_commit,FND_API.G_FALSE)) THEN
     COMMIT WORK;
  END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO update_ctr_associations_pvt;
      FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count,
                 p_data  => x_msg_data
                );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_ctr_associations_pvt;
      FND_MSG_PUB.Count_And_Get
      		(p_count => x_msg_count,
                 p_data  => x_msg_data
                );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_ctr_associations_pvt;
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
END update_ctr_associations;

--|---------------------------------------------------
--| procedure name: update_ctr_val_max_seq_no
--| description :   procedure used to update
--|                 the ctr_val_max_seq_no for
--|                 a particular counter
--|---------------------------------------------------

PROCEDURE update_ctr_val_max_seq_no
 (
     p_api_version             IN     NUMBER
    ,p_commit                  IN     VARCHAR2
    ,p_init_msg_list           IN     VARCHAR2
    ,p_validation_level        IN     NUMBER
    ,p_counter_id              IN     NUMBER
    ,px_ctr_val_max_seq_no     IN OUT NOCOPY NUMBER
    ,x_return_status           OUT    NOCOPY VARCHAR2
    ,x_msg_count               OUT    NOCOPY NUMBER
    ,x_msg_data                OUT    NOCOPY VARCHAR2
 )
 IS
    l_api_name                      CONSTANT VARCHAR2(30)   := 'UPDATE_CTR_VAL_MAX_SEQ_NO';
    l_api_version                   CONSTANT NUMBER         := 1.0;

    l_old_ctr_val_max_seq_no        NUMBER;
    l_old_object_version_number     NUMBER;
    l_ctr_val_id_exist              VARCHAR2(1)             := 'N';
    l_new_value_timestamp           DATE                    := NULL;
    l_new_reading_is_latest         VARCHAR2(1)             := 'N';
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  update_ctr_val_max_seq_no;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   csi_ctr_gen_utility_pvt.read_debug_profiles;

   -- If debug_level = 1 then dump the procedure name
   IF (csi_ctr_gen_utility_pvt.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'update_ctr_val_max_seq_no');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (csi_ctr_gen_utility_pvt.g_debug_level > 1) THEN
      csi_ctr_gen_utility_pvt.put_line('update_ctr_val_max_seq_no' ||
                                       p_api_version               ||'-'||
                                       p_commit                    ||'-'||
                                       p_init_msg_list             ||'-'||
                                       p_validation_level);
      csi_ctr_gen_utility_pvt.put_line('p_counter_id                : ' || p_counter_id);
      csi_ctr_gen_utility_pvt.put_line('px_ctr_val_max_seq_no       : ' || px_ctr_val_max_seq_no);
   END IF;

   -- Start of API Body

   IF px_ctr_val_max_seq_no <= 0 THEN
    --px_ctr_val_max_seq_no = -1 means the ctr_val_max_seq_no column for this counter has never been updated
    --px_ctr_val_max_seq_no = 0 means there is currently no non-disabled reading for this counter
    --setting px_ctr_val_max_seq_no to NULL to force the program to figure out the correct value for ctr_val_max_seq_no
    px_ctr_val_max_seq_no := NULL;
   END IF;

   SELECT ctr_val_max_seq_no, object_version_number
   INTO   l_old_ctr_val_max_seq_no, l_old_object_version_number
   FROM   csi_counters_b
   WHERE  counter_id = p_counter_id;

   IF (csi_ctr_gen_utility_pvt.g_debug_level > 1) THEN
      csi_ctr_gen_utility_pvt.put_line('l_old_ctr_val_max_seq_no    : ' || l_old_ctr_val_max_seq_no);
      csi_ctr_gen_utility_pvt.put_line('l_old_object_version_number : ' || l_old_object_version_number);
   END IF;

   IF (px_ctr_val_max_seq_no IS NOT NULL) AND
      (px_ctr_val_max_seq_no <> FND_API.G_MISS_NUM) THEN
      BEGIN
        SELECT 'Y', value_timestamp
        INTO   l_ctr_val_id_exist, l_new_value_timestamp
        FROM   csi_counter_readings
        WHERE  counter_id = p_counter_id
        AND    counter_value_id = px_ctr_val_max_seq_no
        AND    NVL(disabled_flag, 'N') = 'N';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          csi_ctr_gen_utility_pvt.put_line('Invalid parameter px_ctr_val_max_seq_no : '||px_ctr_val_max_seq_no);
          RAISE FND_API.G_EXC_ERROR;
      END;

      IF (l_ctr_val_id_exist = 'Y') AND (px_ctr_val_max_seq_no <> l_old_ctr_val_max_seq_no) THEN
        IF (l_old_ctr_val_max_seq_no <= 0) THEN
          l_new_reading_is_latest := 'Y';
        ELSE --l_old_ctr_val_max_seq_no > 0
          BEGIN
            SELECT 'Y'
            INTO   l_new_reading_is_latest
            FROM   csi_counter_readings
            WHERE  counter_id = p_counter_id
            AND    counter_value_id = l_old_ctr_val_max_seq_no
            AND    NVL(disabled_flag, 'N') = 'N'
            AND    value_timestamp < l_new_value_timestamp;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              l_new_reading_is_latest := 'N';
          END;
        END IF;
      ELSE --l_ctr_val_id_exist = 'N' or px_ctr_val_max_seq_no = l_old_ctr_val_max_seq_no
        l_new_reading_is_latest := 'N';
      END IF;
   ELSE --px_ctr_val_max_seq_no IS NULL or px_ctr_val_max_seq_no = FND_API.G_MISS_NUM
      --Need to figure out the latest valid counter reading
      px_ctr_val_max_seq_no := 0; --Default px_ctr_val_max_seq_no to 0
      BEGIN
        -- Bug 9283089
        SELECT COUNTER_VALUE_ID, VALUE_TIMESTAMP, 'Y', 'Y'
          INTO   px_ctr_val_max_seq_no, l_new_value_timestamp,
               l_ctr_val_id_exist, l_new_reading_is_latest FROM (
          SELECT COUNTER_VALUE_ID, VALUE_TIMESTAMP  FROM CSI_COUNTER_READINGS WHERE COUNTER_ID = p_counter_id AND
          NVL(DISABLED_FLAG, 'N') = 'N' ORDER BY VALUE_TIMESTAMP DESC) WHERE ROWNUM = 1;


      /*  SELECT counter_value_id, value_timestamp, 'Y', 'Y'
        INTO   px_ctr_val_max_seq_no, l_new_value_timestamp,
               l_ctr_val_id_exist, l_new_reading_is_latest
        FROM   csi_counter_readings
        WHERE  counter_id = p_counter_id
        AND    value_timestamp =
          (SELECT MAX(value_timestamp) FROM csi_counter_readings
           WHERE counter_id = p_counter_id AND NVL(disabled_flag, 'N') = 'N');*/

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          px_ctr_val_max_seq_no := 0;
          l_ctr_val_id_exist := 'N';
          l_new_value_timestamp := NULL;
          l_new_reading_is_latest := 'N';
      END;
   END IF;

   IF (csi_ctr_gen_utility_pvt.g_debug_level > 1) THEN
      csi_ctr_gen_utility_pvt.put_line('l_ctr_val_id_exist          : ' || l_ctr_val_id_exist);
      csi_ctr_gen_utility_pvt.put_line('l_new_reading_is_latest     : ' || l_new_reading_is_latest);
      csi_ctr_gen_utility_pvt.put_line('px_ctr_val_max_seq_no       : ' || px_ctr_val_max_seq_no);
      csi_ctr_gen_utility_pvt.put_line('l_new_value_timestamp       : ' || l_new_value_timestamp);
   END IF;

   IF ((l_ctr_val_id_exist = 'Y') AND (l_new_reading_is_latest = 'Y') AND
      (l_old_ctr_val_max_seq_no <> px_ctr_val_max_seq_no)) OR
      (l_old_ctr_val_max_seq_no <> 0 AND px_ctr_val_max_seq_no = 0) THEN

      -- Bug 9283089
      IF NVL(px_ctr_val_max_seq_no, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN

        UPDATE CSI_COUNTERS_B SET CTR_VAL_MAX_SEQ_NO = px_ctr_val_max_seq_no,
          OBJECT_VERSION_NUMBER =  l_old_object_version_number + 1,
          LAST_UPDATE_DATE = sysdate, LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
          LAST_UPDATE_LOGIN = FND_GLOBAL.USER_ID
          WHERE COUNTER_ID = p_counter_id;

      END IF;
      /*CSI_COUNTERS_PKG.update_row
      (
         p_counter_id                   => p_counter_id
        ,p_group_id                     => NULL
        ,p_counter_type                 => NULL
        ,p_initial_reading              => NULL
        ,p_initial_reading_date         => NULL
        ,p_tolerance_plus               => NULL
        ,p_tolerance_minus              => NULL
        ,p_uom_code                     => NULL
        ,p_derive_counter_id            => NULL
        ,p_derive_function              => NULL
        ,p_derive_property_id           => NULL
        ,p_valid_flag                   => NULL
        ,p_formula_incomplete_flag      => NULL
        ,p_formula_text                 => NULL
        ,p_rollover_last_reading        => NULL
        ,p_rollover_first_reading       => NULL
        ,p_usage_item_id                => NULL
        ,p_ctr_val_max_seq_no           => px_ctr_val_max_seq_no
        ,p_start_date_active            => NULL
        ,p_end_date_active              => NULL
        ,p_object_version_number        => l_old_object_version_number + 1
        ,p_last_update_date             => SYSDATE
        ,p_last_updated_by              => FND_GLOBAL.USER_ID
        ,p_creation_date                => NULL
        ,p_created_by                   => NULL
        ,p_last_update_login            => FND_GLOBAL.USER_ID
        ,p_attribute1                   => NULL
        ,p_attribute2                   => NULL
        ,p_attribute3                   => NULL
        ,p_attribute4                   => NULL
        ,p_attribute5                   => NULL
        ,p_attribute6                   => NULL
        ,p_attribute7                   => NULL
        ,p_attribute8                   => NULL
        ,p_attribute9                   => NULL
        ,p_attribute10                  => NULL
        ,p_attribute11                  => NULL
        ,p_attribute12                  => NULL
        ,p_attribute13                  => NULL
        ,p_attribute14                  => NULL
        ,p_attribute15                  => NULL
        ,p_attribute16                  => NULL
        ,p_attribute17                  => NULL
        ,p_attribute18                  => NULL
        ,p_attribute19                  => NULL
        ,p_attribute20                  => NULL
        ,p_attribute21                  => NULL
        ,p_attribute22                  => NULL
        ,p_attribute23                  => NULL
        ,p_attribute24                  => NULL
        ,p_attribute25                  => NULL
        ,p_attribute26                  => NULL
        ,p_attribute27                  => NULL
        ,p_attribute28                  => NULL
        ,p_attribute29                  => NULL
        ,p_attribute30                  => NULL
        ,p_attribute_category           => NULL
        ,p_migrated_flag                => NULL
        ,p_customer_view                => NULL
        ,p_direction                    => NULL
        ,p_filter_type                  => NULL
        ,p_filter_reading_count         => NULL
        ,p_filter_time_uom              => NULL
        ,p_estimation_id                => NULL
        ,p_reading_type                 => NULL
        ,p_automatic_rollover           => NULL
        ,p_default_usage_rate           => NULL
        ,p_use_past_reading             => NULL
        ,p_used_in_scheduling           => NULL
        ,p_defaulted_group_id           => NULL
        ,p_created_from_counter_tmpl_id => NULL
        ,p_security_group_id            => NULL
        ,p_step_value                   => NULL
        ,p_name                         => NULL
        ,p_description                  => NULL
        ,p_time_based_manual_entry      => NULL
        ,p_eam_required_flag            => NULL
        ,p_comments                     => NULL
      );*/
   END IF;
   -- End of API body

   -- Standard check of p_commit.
   IF FND_API.To_Boolean(nvl(p_commit,FND_API.G_FALSE)) THEN
      COMMIT WORK;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      ROLLBACK TO update_ctr_val_max_seq_no;
      FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count,
                 p_data  => x_msg_data
                );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_ctr_val_max_seq_no;
      FND_MSG_PUB.Count_And_Get
      		(p_count => x_msg_count,
                 p_data  => x_msg_data
                );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO update_ctr_val_max_seq_no;
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
END update_ctr_val_max_seq_no;

END CSI_COUNTER_PVT;

/
