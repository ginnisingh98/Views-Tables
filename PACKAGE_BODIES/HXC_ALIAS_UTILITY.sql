--------------------------------------------------------
--  DDL for Package Body HXC_ALIAS_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_ALIAS_UTILITY" AS
/* $Header: hxcaltutl.pkb 120.13.12010000.4 2008/12/30 09:02:27 sabvenug ship $ */


-- initialize the global variable

g_debug	boolean := hr_utility.debug_enabled;

PROCEDURE initialize IS

BEGIN

g_alias_def_item.delete;
g_alias_val_att_to_match.delete;
g_alias_def_att_to_match.delete;
g_alias_def_att_rec.delete;
g_alias_def_val_att_rec.delete;
g_alias_definition_info.delete;
g_alias_att_info.delete;
g_alias_apps_tab_info.delete;

END initialize;

-- -----------------------------------------------------------------------------|
-- |------------------------< process_attribute          >---------------------|
-- -----------------------------------------------------------------------------|

FUNCTION process_attribute(p_attribute HXC_ATTRIBUTE_TYPE)
RETURN BOOLEAN IS

BEGIN

  IF p_attribute.new = 'Y'
   AND
     p_attribute.attribute1 is NULL
   AND
     p_attribute.attribute2 is NULL
   AND
     p_attribute.attribute3 is NULL
   AND
     p_attribute.attribute4 is NULL
   AND
     p_attribute.attribute5 is NULL
   AND
     p_attribute.attribute6 is NULL
   AND
     p_attribute.attribute7 is NULL
   AND
     p_attribute.attribute8 is NULL
   AND
     p_attribute.attribute9 is NULL
   AND
     p_attribute.attribute10 is NULL
   AND
     p_attribute.attribute11 is NULL
   AND
     p_attribute.attribute12 is NULL
   AND
     p_attribute.attribute13 is NULL
   AND
     p_attribute.attribute14 is NULL
   AND
     p_attribute.attribute15 is NULL
   AND
     p_attribute.attribute16 is NULL
   AND
     p_attribute.attribute17 is NULL
   AND
     p_attribute.attribute18 is NULL
   AND
     p_attribute.attribute19 is NULL
   AND
     p_attribute.attribute20 is NULL
   AND
     p_attribute.attribute21 is NULL
   AND
     p_attribute.attribute22 is NULL
   AND
     p_attribute.attribute23 is NULL
   AND
     p_attribute.attribute24 is NULL
   AND
     p_attribute.attribute25 is NULL
   AND
     p_attribute.attribute26 is NULL
   AND
     p_attribute.attribute27 is NULL
   AND
     p_attribute.attribute28 is NULL
   AND
     p_attribute.attribute29 is NULL
   AND
     p_attribute.attribute30 is NULL
   THEN
     return FALSE;
   ELSE
     return TRUE;
   END IF;

END;

-- -----------------------------------------------------------------------------|
-- |------------------------< get_alias_att_info          >---------------------|
-- -----------------------------------------------------------------------------|
-- | This procedure is used to return the alias information attached to a 	|
-- | timekeeper. That is returning a pl/sql table that contains the info	|
-- ----------------------------------------------------------------------------
PROCEDURE get_alias_att_info
  (p_timekeeper_id	IN	NUMBER,
   p_alias_att_info	IN OUT  NOCOPY	t_alias_att_info)
   IS

l_found boolean := FALSE;

l_alias_def_item_tab            t_alias_def_item;
l_alias_val_att_to_match        t_alias_val_att_to_match;

l_index_alias_val_att number;
l_index_alias_def     number;

l_alias_type 		hxc_alias_types.alias_type%TYPE;
l_reference_object	hxc_alias_types.reference_object%TYPE;
l_prompt		hxc_alias_definitions_tl.prompt%TYPE;

BEGIN

g_debug:=hr_utility.debug_enabled;

-- first we look if the we have already
IF g_alias_att_info.exists(1) THEN
   -- populate the out parameter
   IF g_alias_att_info(1).TIMEKEEPER_ID = p_timekeeper_id THEN
      p_alias_att_info :=g_alias_att_info;
      l_found := true;
   END IF;

END IF;

IF not(l_found) THEN


   -- get the alias definition item
   get_alias_def_item
                   (p_timekeeper_id        => P_TIMEKEEPER_ID,
                    p_alias_def_item       => l_alias_def_item_tab);

   l_index_alias_def := l_alias_def_item_tab.first;

   LOOP
   EXIT WHEN
   (NOT l_alias_def_item_tab.exists(l_index_alias_def));
     -- get the alias attribute values to match with the attribute.

     -- get the alias type
     get_alias_definition_info
      (l_alias_def_item_tab(l_index_alias_def).alias_definition_id,
       l_alias_type,
       l_reference_object,
       l_prompt);

--if g_debug then
	--hr_utility.trace('l_alias_def_item_tab(l_index_alias_def).alias_definition_id'||l_alias_def_item_tab(l_index_alias_def).alias_definition_id);
--end if;


     --IF l_alias_type like 'VALUE_SET%' THEN
     --   get_alias_val_att_to_match
     --      (l_alias_def_item_tab(l_index_alias_def).alias_definition_id,
     --       l_alias_val_att_to_match);
     --ELSE



     --l_index_alias_val_att:=l_alias_val_att_to_match.first;
     -- LOOP
     -- EXIT WHEN
     --  NOT (l_alias_val_att_to_match.exists(l_index_alias_val_att)) ;

     p_alias_att_info(
           substr(l_alias_def_item_tab(l_index_alias_def).ITEM_ATTRIBUTE_CATEGORY,16)).TIMEKEEPER_ID
                 :=p_timekeeper_id;

     p_alias_att_info(
           substr(l_alias_def_item_tab(l_index_alias_def).ITEM_ATTRIBUTE_CATEGORY,16)).alias_definition_id
                 :=l_alias_def_item_tab(l_index_alias_def).alias_definition_id;

     p_alias_att_info(
            substr(l_alias_def_item_tab(l_index_alias_def).ITEM_ATTRIBUTE_CATEGORY,16)).alias_type
                 :=l_alias_type;
        --p_alias_att_info(
        --   substr(l_alias_def_item_tab(l_index_alias_def).ITEM_ATTRIBUTE_CATEGORY,16)).BLD_BLK_INFO_TYPE_ID
        --        := NULL;-- l_alias_val_att_to_match(l_index_alias_val_att).BLD_BLK_INFO_TYPE_ID;
        -- p_alias_att_info(
        --    substr(l_alias_def_item_tab(l_index_alias_def).ITEM_ATTRIBUTE_CATEGORY,16)).BLD_BLK_INFO_TYPE
        --         :=NULL; --l_alias_val_att_to_match(l_index_alias_val_att).BLD_BLK_INFO_TYPE;

         --l_index_alias_val_att:=l_alias_val_att_to_match.next(l_index_alias_val_att);
       --END LOOP;
     l_index_alias_def := l_alias_def_item_tab.next(l_index_alias_def);
     END LOOP;

END IF;


END get_alias_att_info;


-- -----------------------------------------------------------------------------
-- |----------------------< get_next_negative_attribute_id>---------------------|
-- -----------------------------------------------------------------------------
-- | This procedure return the next negative id. We are looking into 		|
-- | p_attributes to find out what is the next negative index		|
-- ----------------------------------------------------------------------------

FUNCTION get_next_negative_attribute_id(
  p_attributes IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE--hxc_self_service_time_deposit.building_block_attribute_info
)
RETURN NUMBER
IS

l_attribute_index NUMBER;
l_next_att_id     NUMBER;

BEGIN
  l_next_att_id := -2;

  l_attribute_index := p_attributes.first;
  LOOP
    EXIT WHEN NOT p_attributes.exists(l_attribute_index);

    IF p_attributes(l_attribute_index).TIME_ATTRIBUTE_ID <= l_next_att_id    THEN
      l_next_att_id := p_attributes(l_attribute_index).TIME_ATTRIBUTE_ID - 1;
    END IF;

    l_attribute_index := p_attributes.next(l_attribute_index);
  END LOOP;

  RETURN l_next_att_id;

END get_next_negative_attribute_id;


-- ----------------------------------------------------------------------------
-- |--------------------------< set_attribute_information>--------------------|
-- ----------------------------------------------------------------------------
-- | This procedure set the value on a certain attribute into 		      |
-- | p_attributes at a certain index.				      |
-- ----------------------------------------------------------------------------
PROCEDURE set_attribute_information
  (p_attributes 		IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE,--hxc_self_service_time_deposit.building_block_attribute_info,
   p_index_in_table		IN  NUMBER,
   p_attribute_to_set		IN  VARCHAR2,
   p_value_to_set		IN  VARCHAR2) IS

BEGIN

   if p_attribute_to_set = 'ATTRIBUTE_CATEGORY' THEN
      p_attributes(p_index_in_table).ATTRIBUTE_CATEGORY := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE1' THEN
      p_attributes(p_index_in_table).ATTRIBUTE1 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE2' THEN
      p_attributes(p_index_in_table).ATTRIBUTE2 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE3' THEN
      p_attributes(p_index_in_table).ATTRIBUTE3 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE4' THEN
      p_attributes(p_index_in_table).ATTRIBUTE4 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE5' THEN
      p_attributes(p_index_in_table).ATTRIBUTE5 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE6' THEN
      p_attributes(p_index_in_table).ATTRIBUTE6 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE7' THEN
      p_attributes(p_index_in_table).ATTRIBUTE7 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE8' THEN
      p_attributes(p_index_in_table).ATTRIBUTE8 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE9' THEN
      p_attributes(p_index_in_table).ATTRIBUTE9 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE10' THEN
      p_attributes(p_index_in_table).ATTRIBUTE10 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE11' THEN
      p_attributes(p_index_in_table).ATTRIBUTE11 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE12' THEN
      p_attributes(p_index_in_table).ATTRIBUTE12 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE13' THEN
      p_attributes(p_index_in_table).ATTRIBUTE13 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE14' THEN
      p_attributes(p_index_in_table).ATTRIBUTE14 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE15' THEN
      p_attributes(p_index_in_table).ATTRIBUTE15 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE16' THEN
      p_attributes(p_index_in_table).ATTRIBUTE16 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE17' THEN
      p_attributes(p_index_in_table).ATTRIBUTE17 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE18' THEN
      p_attributes(p_index_in_table).ATTRIBUTE18 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE19' THEN
      p_attributes(p_index_in_table).ATTRIBUTE19 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE20' THEN
      p_attributes(p_index_in_table).ATTRIBUTE2 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE21' THEN
      p_attributes(p_index_in_table).ATTRIBUTE21 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE22' THEN
      p_attributes(p_index_in_table).ATTRIBUTE22 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE23' THEN
      p_attributes(p_index_in_table).ATTRIBUTE23 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE24' THEN
      p_attributes(p_index_in_table).ATTRIBUTE24 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE25' THEN
      p_attributes(p_index_in_table).ATTRIBUTE25 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE26' THEN
      p_attributes(p_index_in_table).ATTRIBUTE26 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE27' THEN
      p_attributes(p_index_in_table).ATTRIBUTE27 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE28' THEN
      p_attributes(p_index_in_table).ATTRIBUTE28 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE29' THEN
      p_attributes(p_index_in_table).ATTRIBUTE29 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE30' THEN
      p_attributes(p_index_in_table).ATTRIBUTE30 := p_value_to_set;
   END if;

END;


-- ----------------------------------------------------------------------------
-- |--------------------------< get_attribute_information>--------------------|
-- ----------------------------------------------------------------------------
-- | This procedure get the value on a certain attribute into 		      |
-- | p_attributes at a certain index.				      |
-- ----------------------------------------------------------------------------
PROCEDURE get_attribute_information
  (p_attributes 		IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE,--hxc_self_service_time_deposit.building_block_attribute_info,
   p_index_in_table		IN   NUMBER,
   p_attribute_to_get		IN   VARCHAR2,
   p_get_value		 OUT NOCOPY  VARCHAR2) IS

BEGIN

   if p_attribute_to_get = 'ATTRIBUTE_CATEGORY' THEN
      p_get_value := p_attributes(p_index_in_table).ATTRIBUTE_CATEGORY;
   elsif p_attribute_to_get = 'ATTRIBUTE1' THEN
      p_get_value := p_attributes(p_index_in_table).ATTRIBUTE1;
   elsif p_attribute_to_get = 'ATTRIBUTE2' THEN
      p_get_value := p_attributes(p_index_in_table).ATTRIBUTE2;
   elsif p_attribute_to_get = 'ATTRIBUTE3' THEN
      p_get_value := p_attributes(p_index_in_table).ATTRIBUTE3;
   elsif p_attribute_to_get = 'ATTRIBUTE4' THEN
      p_get_value := p_attributes(p_index_in_table).ATTRIBUTE4;
   elsif p_attribute_to_get = 'ATTRIBUTE5' THEN
      p_get_value := p_attributes(p_index_in_table).ATTRIBUTE5;
   elsif p_attribute_to_get = 'ATTRIBUTE6' THEN
      p_get_value := p_attributes(p_index_in_table).ATTRIBUTE6;
   elsif p_attribute_to_get = 'ATTRIBUTE7' THEN
      p_get_value := p_attributes(p_index_in_table).ATTRIBUTE7;
   elsif p_attribute_to_get = 'ATTRIBUTE8' THEN
      p_get_value := p_attributes(p_index_in_table).ATTRIBUTE8;
   elsif p_attribute_to_get = 'ATTRIBUTE9' THEN
      p_get_value := p_attributes(p_index_in_table).ATTRIBUTE9;
   elsif p_attribute_to_get = 'ATTRIBUTE10' THEN
      p_get_value := p_attributes(p_index_in_table).ATTRIBUTE10;
   elsif p_attribute_to_get = 'ATTRIBUTE11' THEN
      p_get_value := p_attributes(p_index_in_table).ATTRIBUTE11;
   elsif p_attribute_to_get = 'ATTRIBUTE12' THEN
      p_get_value := p_attributes(p_index_in_table).ATTRIBUTE12;
   elsif p_attribute_to_get = 'ATTRIBUTE13' THEN
      p_get_value := p_attributes(p_index_in_table).ATTRIBUTE13;
   elsif p_attribute_to_get = 'ATTRIBUTE14' THEN
      p_get_value := p_attributes(p_index_in_table).ATTRIBUTE14;
   elsif p_attribute_to_get = 'ATTRIBUTE15' THEN
      p_get_value := p_attributes(p_index_in_table).ATTRIBUTE15;
   elsif p_attribute_to_get = 'ATTRIBUTE16' THEN
      p_get_value := p_attributes(p_index_in_table).ATTRIBUTE16;
   elsif p_attribute_to_get = 'ATTRIBUTE17' THEN
      p_get_value := p_attributes(p_index_in_table).ATTRIBUTE17;
   elsif p_attribute_to_get = 'ATTRIBUTE18' THEN
      p_get_value := p_attributes(p_index_in_table).ATTRIBUTE18;
   elsif p_attribute_to_get = 'ATTRIBUTE19' THEN
      p_get_value := p_attributes(p_index_in_table).ATTRIBUTE19;
   elsif p_attribute_to_get = 'ATTRIBUTE20' THEN
      p_get_value := p_attributes(p_index_in_table).ATTRIBUTE20;
   elsif p_attribute_to_get = 'ATTRIBUTE21' THEN
      p_get_value := p_attributes(p_index_in_table).ATTRIBUTE21;
   elsif p_attribute_to_get = 'ATTRIBUTE22' THEN
      p_get_value := p_attributes(p_index_in_table).ATTRIBUTE22;
   elsif p_attribute_to_get = 'ATTRIBUTE23' THEN
      p_get_value := p_attributes(p_index_in_table).ATTRIBUTE23;
   elsif p_attribute_to_get = 'ATTRIBUTE24' THEN
      p_get_value := p_attributes(p_index_in_table).ATTRIBUTE24;
   elsif p_attribute_to_get = 'ATTRIBUTE25' THEN
      p_get_value := p_attributes(p_index_in_table).ATTRIBUTE25;
   elsif p_attribute_to_get = 'ATTRIBUTE26' THEN
      p_get_value := p_attributes(p_index_in_table).ATTRIBUTE26;
   elsif p_attribute_to_get = 'ATTRIBUTE27' THEN
      p_get_value := p_attributes(p_index_in_table).ATTRIBUTE27;
   elsif p_attribute_to_get = 'ATTRIBUTE28' THEN
      p_get_value := p_attributes(p_index_in_table).ATTRIBUTE28;
   elsif p_attribute_to_get = 'ATTRIBUTE29' THEN
      p_get_value := p_attributes(p_index_in_table).ATTRIBUTE29;
   elsif p_attribute_to_get = 'ATTRIBUTE30' THEN
      p_get_value := p_attributes(p_index_in_table).ATTRIBUTE30;
   END if;


END;

-- ----------------------------------------------------------------------------
-- |--------------------------< get_attribute_to_match_info>------------------|
-- ----------------------------------------------------------------------------
-- | This procedure get the value on a certain attribute into 		      |
-- | p_attribute_to_match at a certain index.				      |
-- ----------------------------------------------------------------------------
PROCEDURE get_attribute_to_match_info
  (p_attribute_to_match 	IN OUT NOCOPY t_alias_val_att_to_match,
   p_index_in_table		IN   NUMBER,
   p_attribute_to_get		IN   VARCHAR2,
   p_get_value		 OUT NOCOPY  VARCHAR2) IS

BEGIN

   if p_attribute_to_get = 'ATTRIBUTE_CATEGORY' THEN
      p_get_value := p_attribute_to_match(p_index_in_table).ATTRIBUTE_CATEGORY;
   elsif p_attribute_to_get = 'ATTRIBUTE1' THEN
      p_get_value := p_attribute_to_match(p_index_in_table).ATTRIBUTE1;
   elsif p_attribute_to_get = 'ATTRIBUTE2' THEN
      p_get_value := p_attribute_to_match(p_index_in_table).ATTRIBUTE2;
   elsif p_attribute_to_get = 'ATTRIBUTE3' THEN
      p_get_value := p_attribute_to_match(p_index_in_table).ATTRIBUTE3;
   elsif p_attribute_to_get = 'ATTRIBUTE4' THEN
      p_get_value := p_attribute_to_match(p_index_in_table).ATTRIBUTE4;
   elsif p_attribute_to_get = 'ATTRIBUTE5' THEN
      p_get_value := p_attribute_to_match(p_index_in_table).ATTRIBUTE5;
   elsif p_attribute_to_get = 'ATTRIBUTE6' THEN
      p_get_value := p_attribute_to_match(p_index_in_table).ATTRIBUTE6;
   elsif p_attribute_to_get = 'ATTRIBUTE7' THEN
      p_get_value := p_attribute_to_match(p_index_in_table).ATTRIBUTE7;
   elsif p_attribute_to_get = 'ATTRIBUTE8' THEN
      p_get_value := p_attribute_to_match(p_index_in_table).ATTRIBUTE8;
   elsif p_attribute_to_get = 'ATTRIBUTE9' THEN
      p_get_value := p_attribute_to_match(p_index_in_table).ATTRIBUTE9;
   elsif p_attribute_to_get = 'ATTRIBUTE10' THEN
      p_get_value := p_attribute_to_match(p_index_in_table).ATTRIBUTE10;
   elsif p_attribute_to_get = 'ATTRIBUTE11' THEN
      p_get_value := p_attribute_to_match(p_index_in_table).ATTRIBUTE11;
   elsif p_attribute_to_get = 'ATTRIBUTE12' THEN
      p_get_value := p_attribute_to_match(p_index_in_table).ATTRIBUTE12;
   elsif p_attribute_to_get = 'ATTRIBUTE13' THEN
      p_get_value := p_attribute_to_match(p_index_in_table).ATTRIBUTE13;
   elsif p_attribute_to_get = 'ATTRIBUTE14' THEN
      p_get_value := p_attribute_to_match(p_index_in_table).ATTRIBUTE14;
   elsif p_attribute_to_get = 'ATTRIBUTE15' THEN
      p_get_value := p_attribute_to_match(p_index_in_table).ATTRIBUTE15;
   elsif p_attribute_to_get = 'ATTRIBUTE16' THEN
      p_get_value := p_attribute_to_match(p_index_in_table).ATTRIBUTE16;
   elsif p_attribute_to_get = 'ATTRIBUTE17' THEN
      p_get_value := p_attribute_to_match(p_index_in_table).ATTRIBUTE17;
   elsif p_attribute_to_get = 'ATTRIBUTE18' THEN
      p_get_value := p_attribute_to_match(p_index_in_table).ATTRIBUTE18;
   elsif p_attribute_to_get = 'ATTRIBUTE19' THEN
      p_get_value := p_attribute_to_match(p_index_in_table).ATTRIBUTE19;
   elsif p_attribute_to_get = 'ATTRIBUTE20' THEN
      p_get_value := p_attribute_to_match(p_index_in_table).ATTRIBUTE20;
   elsif p_attribute_to_get = 'ATTRIBUTE21' THEN
      p_get_value := p_attribute_to_match(p_index_in_table).ATTRIBUTE21;
   elsif p_attribute_to_get = 'ATTRIBUTE22' THEN
      p_get_value := p_attribute_to_match(p_index_in_table).ATTRIBUTE22;
   elsif p_attribute_to_get = 'ATTRIBUTE23' THEN
      p_get_value := p_attribute_to_match(p_index_in_table).ATTRIBUTE23;
   elsif p_attribute_to_get = 'ATTRIBUTE24' THEN
      p_get_value := p_attribute_to_match(p_index_in_table).ATTRIBUTE24;
   elsif p_attribute_to_get = 'ATTRIBUTE25' THEN
      p_get_value := p_attribute_to_match(p_index_in_table).ATTRIBUTE25;
   elsif p_attribute_to_get = 'ATTRIBUTE26' THEN
      p_get_value := p_attribute_to_match(p_index_in_table).ATTRIBUTE26;
   elsif p_attribute_to_get = 'ATTRIBUTE27' THEN
      p_get_value := p_attribute_to_match(p_index_in_table).ATTRIBUTE27;
   elsif p_attribute_to_get = 'ATTRIBUTE28' THEN
      p_get_value := p_attribute_to_match(p_index_in_table).ATTRIBUTE28;
   elsif p_attribute_to_get = 'ATTRIBUTE29' THEN
      p_get_value := p_attribute_to_match(p_index_in_table).ATTRIBUTE29;
   elsif p_attribute_to_get = 'ATTRIBUTE30' THEN
      p_get_value := p_attribute_to_match(p_index_in_table).ATTRIBUTE30;
   END if;


END get_attribute_to_match_info;

-- ----------------------------------------------------------------------------
-- |--------------------------< set_attribute_to_match_info>------------------|
-- ----------------------------------------------------------------------------
-- | This procedure set the value on a certain attribute into 		      |
-- | p_attribute_to_match at a certain index.				      |
-- ----------------------------------------------------------------------------
PROCEDURE set_attribute_to_match_info
  (p_attribute_to_match 	IN OUT NOCOPY t_alias_val_att_to_match,
   p_index_in_table		IN   NUMBER,
   p_attribute_to_set		IN   VARCHAR2,
   p_bld_blk_info_type		IN   VARCHAR2,
   p_mapping_att_cat		IN   VARCHAR2,
   p_value_to_set		IN   VARCHAR2) IS

BEGIN

--if g_debug then
	--hr_utility.trace('p_bld_blk_info_type :'||p_bld_blk_info_type);
	--hr_utility.trace('p_mapping_att_cat :'||p_mapping_att_cat);
	--hr_utility.trace('p_attribute_to_set :'||p_attribute_to_set);
--end if;

    if p_attribute_to_set = 'ATTRIBUTE_CATEGORY' THEN
        IF (p_bld_blk_info_type like 'Dummy%') THEN
            p_attribute_to_match(p_index_in_table).ATTRIBUTE_CATEGORY :=
	     p_mapping_att_cat||' - '||p_value_to_set;
        ELSE
            p_attribute_to_match(p_index_in_table).ATTRIBUTE_CATEGORY := p_value_to_set;
        END IF;
   elsif p_attribute_to_set = 'ATTRIBUTE1' THEN
      p_attribute_to_match(p_index_in_table).ATTRIBUTE1 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE2' THEN
      p_attribute_to_match(p_index_in_table).ATTRIBUTE2 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE3' THEN
      p_attribute_to_match(p_index_in_table).ATTRIBUTE3 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE4' THEN
      p_attribute_to_match(p_index_in_table).ATTRIBUTE4 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE5' THEN
      p_attribute_to_match(p_index_in_table).ATTRIBUTE5 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE6' THEN
      p_attribute_to_match(p_index_in_table).ATTRIBUTE6 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE7' THEN
      p_attribute_to_match(p_index_in_table).ATTRIBUTE7 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE8' THEN
      p_attribute_to_match(p_index_in_table).ATTRIBUTE8 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE9' THEN
      p_attribute_to_match(p_index_in_table).ATTRIBUTE9 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE10' THEN
      p_attribute_to_match(p_index_in_table).ATTRIBUTE10 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE11' THEN
      p_attribute_to_match(p_index_in_table).ATTRIBUTE11 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE12' THEN
      p_attribute_to_match(p_index_in_table).ATTRIBUTE12 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE13' THEN
      p_attribute_to_match(p_index_in_table).ATTRIBUTE13 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE14' THEN
      p_attribute_to_match(p_index_in_table).ATTRIBUTE14 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE15' THEN
      p_attribute_to_match(p_index_in_table).ATTRIBUTE15 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE16' THEN
      p_attribute_to_match(p_index_in_table).ATTRIBUTE16 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE17' THEN
      p_attribute_to_match(p_index_in_table).ATTRIBUTE17 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE18' THEN
      p_attribute_to_match(p_index_in_table).ATTRIBUTE18 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE19' THEN
      p_attribute_to_match(p_index_in_table).ATTRIBUTE19 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE20' THEN
      p_attribute_to_match(p_index_in_table).ATTRIBUTE2 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE21' THEN
      p_attribute_to_match(p_index_in_table).ATTRIBUTE21 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE22' THEN
      p_attribute_to_match(p_index_in_table).ATTRIBUTE22 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE23' THEN
      p_attribute_to_match(p_index_in_table).ATTRIBUTE23 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE24' THEN
      p_attribute_to_match(p_index_in_table).ATTRIBUTE24 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE25' THEN
      p_attribute_to_match(p_index_in_table).ATTRIBUTE25 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE26' THEN
      p_attribute_to_match(p_index_in_table).ATTRIBUTE26 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE27' THEN
      p_attribute_to_match(p_index_in_table).ATTRIBUTE27 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE28' THEN
      p_attribute_to_match(p_index_in_table).ATTRIBUTE28 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE29' THEN
      p_attribute_to_match(p_index_in_table).ATTRIBUTE29 := p_value_to_set;
   elsif p_attribute_to_set = 'ATTRIBUTE30' THEN
      p_attribute_to_match(p_index_in_table).ATTRIBUTE30 := p_value_to_set;
   END if;

END set_attribute_to_match_info;


-- ----------------------------------------------------------------------------
-- |------------------------< attribute_check             >--------------------|
-- ----------------------------------------------------------------------------
-- | Thie procedure is used to find out if a bld_blk_info_type_id is 	       |
-- | attached to a particular time_building_block_id.			       |
-- | This procedure is used while the deposit translation 		       |
-- ----------------------------------------------------------------------------
PROCEDURE attribute_check
           (p_bld_blk_info_type_id	IN NUMBER
           ,p_time_building_block_id 	IN hxc_time_building_blocks.time_building_block_id%TYPE
           ,p_attributes 		IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE--hxc_self_service_time_deposit.building_block_attribute_info
           ,p_tbb_id_reference_table 	IN OUT NOCOPY t_tbb_id_reference
           ,p_attribute_index	   	IN OUT NOCOPY NUMBER
           ,p_attribute_found	   	IN OUT NOCOPY BOOLEAN)
           IS

l_attribute_count 	NUMBER;
l_doesnt_exist		BOOLEAN := TRUE;

l_index_string		VARCHAR2(2000);
--l_index_return		NUMBER  := -1;

l_index_next		NUMBER;
l_index_start		NUMBER;
l_result		VARCHAR2(10);

l_attribute_category    VARCHAR2(80);
l_to_check		VARCHAR2(80);

BEGIN

p_attribute_found := FALSE;

IF (p_tbb_id_reference_table.exists(p_time_building_block_id)) THEN
  -- we need to send the check if all index have an attribute_category = p_to_check
  -- get the index string
  l_index_string := p_tbb_id_reference_table(p_time_building_block_id).ATTRIBUTE_INDEX;

--if g_debug then
	--hr_utility.trace('Joel : p_bld_blk_info_type_id'||p_bld_blk_info_type_id);
	--hr_utility.trace('Joel : p_time_building_block_id'||p_time_building_block_id);
	--hr_utility.trace('Joel : l_index_string'||l_index_string);
--end if;

  -- go through the string and check the to_check
  l_index_start:=INSTR(l_index_string,'|',1,1)+1;
  LOOP

       l_index_next := INSTR(l_index_string,'|',l_index_start,1);

       IF(l_index_next = 0) THEN
    	 l_result := SUBSTR(l_index_string,
    	 		    l_index_start,
    	 		    length(l_index_string)+1-l_index_start);
       ELSE
	 l_result := SUBSTR(l_index_string,
	 		    l_index_start,
	 		    l_index_next-l_index_start);
       END IF;

       IF (l_result is not null) THEN
        if p_attributes.exists(l_result) THEN
    	 IF (p_attributes(l_result).BLD_BLK_INFO_TYPE_ID = p_bld_blk_info_type_id) THEN
     	   p_attribute_index := l_result;
     	   p_attribute_found := TRUE;
         END IF;
        END if;
       END if;

     l_index_start	:= l_index_next + 1;
     l_result 		:= NULL;

  EXIT WHEN l_index_next = 0;
  END LOOP; -- attribute for a tbb_id
END if;

--return l_index_return;

END attribute_check;

-- ----------------------------------------------------------------------------
-- |------------------------< set_attribute_on_att_to_match>--------------------|
-- ----------------------------------------------------------------------------
PROCEDURE set_attribute_on_att_to_match(
   		p_alias_val_att_to_match_row 	IN OUT NOCOPY r_alias_val_att_to_match,
   		p_alias_value_id		NUMBER,
   		p_component_type		VARCHAR2,
   		p_segment			VARCHAR2,
   		p_bld_blk_info_type		VARCHAR2,
   		p_attribute_mapping_category	VARCHAR2,
   		p_match_to_delete	 OUT NOCOPY BOOLEAN)
   		IS

CURSOR csr_alias_value_attribute
IS
select attribute1
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
      ,attribute16
      ,attribute17
      ,attribute18
      ,attribute19
      ,attribute20
      ,attribute21
      ,attribute22
      ,attribute23
      ,attribute24
      ,attribute25
      ,attribute26
      ,attribute27
      ,attribute28
      ,attribute29
      ,attribute30
from hxc_alias_values
where alias_value_id = p_alias_value_id;

l_alias_attribute_value VARCHAR2(150);

BEGIN

-- following the p_component_type we need to pick up the right information
-- of hxc_alias_values, then following the segment name, we will put it into
-- the right segment in p_alias_val_att_to_match_row

FOR c_alias_value_attribute in csr_alias_value_attribute LOOP
   -- first we look for the attribute to find
   IF p_component_type = 'ATTRIBUTE1' THEN
     l_alias_attribute_value := c_alias_value_attribute.ATTRIBUTE1;
   ELSIF p_component_type = 'ATTRIBUTE2' THEN
     l_alias_attribute_value := c_alias_value_attribute.ATTRIBUTE2;
   ELSIF p_component_type = 'ATTRIBUTE3' THEN
     l_alias_attribute_value := c_alias_value_attribute.ATTRIBUTE3;
   ELSIF p_component_type = 'ATTRIBUTE4' THEN
     l_alias_attribute_value := c_alias_value_attribute.ATTRIBUTE4;
   ELSIF p_component_type = 'ATTRIBUTE5' THEN
     l_alias_attribute_value := c_alias_value_attribute.ATTRIBUTE5;
   ELSIF p_component_type = 'ATTRIBUTE6' THEN
     l_alias_attribute_value := c_alias_value_attribute.ATTRIBUTE6;
   ELSIF p_component_type = 'ATTRIBUTE7' THEN
     l_alias_attribute_value := c_alias_value_attribute.ATTRIBUTE7;
   ELSIF p_component_type = 'ATTRIBUTE8' THEN
     l_alias_attribute_value := c_alias_value_attribute.ATTRIBUTE8;
   ELSIF p_component_type = 'ATTRIBUTE9' THEN
     l_alias_attribute_value := c_alias_value_attribute.ATTRIBUTE9;
   ELSIF p_component_type = 'ATTRIBUTE10' THEN
     l_alias_attribute_value := c_alias_value_attribute.ATTRIBUTE10;
   ELSIF p_component_type = 'ATTRIBUTE11' THEN
     l_alias_attribute_value := c_alias_value_attribute.ATTRIBUTE11;
   ELSIF p_component_type = 'ATTRIBUTE12' THEN
     l_alias_attribute_value := c_alias_value_attribute.ATTRIBUTE12;
   ELSIF p_component_type = 'ATTRIBUTE13' THEN
     l_alias_attribute_value := c_alias_value_attribute.ATTRIBUTE13;
   ELSIF p_component_type = 'ATTRIBUTE14' THEN
     l_alias_attribute_value := c_alias_value_attribute.ATTRIBUTE14;
   ELSIF p_component_type = 'ATTRIBUTE15' THEN
     l_alias_attribute_value := c_alias_value_attribute.ATTRIBUTE15;
   ELSIF p_component_type = 'ATTRIBUTE16' THEN
     l_alias_attribute_value := c_alias_value_attribute.ATTRIBUTE16;
   ELSIF p_component_type = 'ATTRIBUTE17' THEN
     l_alias_attribute_value := c_alias_value_attribute.ATTRIBUTE17;
   ELSIF p_component_type = 'ATTRIBUTE18' THEN
     l_alias_attribute_value := c_alias_value_attribute.ATTRIBUTE18;
   ELSIF p_component_type = 'ATTRIBUTE19' THEN
     l_alias_attribute_value := c_alias_value_attribute.ATTRIBUTE19;
   ELSIF p_component_type = 'ATTRIBUTE20' THEN
     l_alias_attribute_value := c_alias_value_attribute.ATTRIBUTE20;
   ELSIF p_component_type = 'ATTRIBUTE21' THEN
     l_alias_attribute_value := c_alias_value_attribute.ATTRIBUTE21;
   ELSIF p_component_type = 'ATTRIBUTE22' THEN
     l_alias_attribute_value := c_alias_value_attribute.ATTRIBUTE22;
   ELSIF p_component_type = 'ATTRIBUTE23' THEN
     l_alias_attribute_value := c_alias_value_attribute.ATTRIBUTE23;
   ELSIF p_component_type = 'ATTRIBUTE24' THEN
     l_alias_attribute_value := c_alias_value_attribute.ATTRIBUTE24;
   ELSIF p_component_type = 'ATTRIBUTE25' THEN
     l_alias_attribute_value := c_alias_value_attribute.ATTRIBUTE25;
   ELSIF p_component_type = 'ATTRIBUTE26' THEN
     l_alias_attribute_value := c_alias_value_attribute.ATTRIBUTE26;
   ELSIF p_component_type = 'ATTRIBUTE27' THEN
     l_alias_attribute_value := c_alias_value_attribute.ATTRIBUTE27;
   ELSIF p_component_type = 'ATTRIBUTE28' THEN
     l_alias_attribute_value := c_alias_value_attribute.ATTRIBUTE28;
   ELSIF p_component_type = 'ATTRIBUTE29' THEN
     l_alias_attribute_value := c_alias_value_attribute.ATTRIBUTE29;
   ELSIF p_component_type = 'ATTRIBUTE30' THEN
     l_alias_attribute_value := c_alias_value_attribute.ATTRIBUTE30;
   END IF;
END LOOP;

----dbms_output.put_line
           --('l_alias_attribute_value: '||l_alias_attribute_value);

-- which mean we don't need to find this match.
IF l_alias_attribute_value is null THEN
  p_match_to_delete := TRUE;
  RETURN;
END IF;

-- now we have the attribute information of the alias value
-- we need to put at the right place in	p_alias_val_att_to_match_row
IF p_segment = 'ATTRIBUTE_CATEGORY' THEN
   IF (p_bld_blk_info_type like 'Dummy%') THEN
       p_alias_val_att_to_match_row.attribute_category :=
	   p_attribute_mapping_category||' - '||l_alias_attribute_value;
   ELSE
     p_alias_val_att_to_match_row.attribute_category := l_alias_attribute_value;
   END IF;

ELSIF p_segment = 'ATTRIBUTE1'  THEN
  p_alias_val_att_to_match_row.ATTRIBUTE1 := l_alias_attribute_value;
ELSIF p_segment = 'ATTRIBUTE2'  THEN
  p_alias_val_att_to_match_row.ATTRIBUTE2 := l_alias_attribute_value;
ELSIF p_segment = 'ATTRIBUTE3'  THEN
  p_alias_val_att_to_match_row.ATTRIBUTE3 := l_alias_attribute_value;
ELSIF p_segment = 'ATTRIBUTE4'  THEN
  p_alias_val_att_to_match_row.ATTRIBUTE4 := l_alias_attribute_value;
ELSIF p_segment = 'ATTRIBUTE5'  THEN
  p_alias_val_att_to_match_row.ATTRIBUTE5 := l_alias_attribute_value;
ELSIF p_segment = 'ATTRIBUTE6'  THEN
  p_alias_val_att_to_match_row.ATTRIBUTE6 := l_alias_attribute_value;
ELSIF p_segment = 'ATTRIBUTE7'  THEN
  p_alias_val_att_to_match_row.ATTRIBUTE7 := l_alias_attribute_value;
ELSIF p_segment = 'ATTRIBUTE8'  THEN
  p_alias_val_att_to_match_row.ATTRIBUTE8 := l_alias_attribute_value;
ELSIF p_segment = 'ATTRIBUTE9'  THEN
  p_alias_val_att_to_match_row.ATTRIBUTE9 := l_alias_attribute_value;
ELSIF p_segment = 'ATTRIBUTE10'  THEN
  p_alias_val_att_to_match_row.ATTRIBUTE10 := l_alias_attribute_value;
ELSIF p_segment = 'ATTRIBUTE11'  THEN
  p_alias_val_att_to_match_row.ATTRIBUTE11 := l_alias_attribute_value;
ELSIF p_segment = 'ATTRIBUTE12'  THEN
  p_alias_val_att_to_match_row.ATTRIBUTE12 := l_alias_attribute_value;
ELSIF p_segment = 'ATTRIBUTE13'  THEN
  p_alias_val_att_to_match_row.ATTRIBUTE13 := l_alias_attribute_value;
ELSIF p_segment = 'ATTRIBUTE14'  THEN
  p_alias_val_att_to_match_row.ATTRIBUTE14 := l_alias_attribute_value;
ELSIF p_segment = 'ATTRIBUTE15'  THEN
  p_alias_val_att_to_match_row.ATTRIBUTE15 := l_alias_attribute_value;
ELSIF p_segment = 'ATTRIBUTE16'  THEN
  p_alias_val_att_to_match_row.ATTRIBUTE16 := l_alias_attribute_value;
ELSIF p_segment = 'ATTRIBUTE17'  THEN
  p_alias_val_att_to_match_row.ATTRIBUTE17 := l_alias_attribute_value;
ELSIF p_segment = 'ATTRIBUTE18'  THEN
  p_alias_val_att_to_match_row.ATTRIBUTE18 := l_alias_attribute_value;
ELSIF p_segment = 'ATTRIBUTE19'  THEN
  p_alias_val_att_to_match_row.ATTRIBUTE19 := l_alias_attribute_value;
ELSIF p_segment = 'ATTRIBUTE20'  THEN
  p_alias_val_att_to_match_row.ATTRIBUTE20 := l_alias_attribute_value;
ELSIF p_segment = 'ATTRIBUTE21'  THEN
  p_alias_val_att_to_match_row.ATTRIBUTE21 := l_alias_attribute_value;
ELSIF p_segment = 'ATTRIBUTE22'  THEN
  p_alias_val_att_to_match_row.ATTRIBUTE22 := l_alias_attribute_value;
ELSIF p_segment = 'ATTRIBUTE23'  THEN
  p_alias_val_att_to_match_row.ATTRIBUTE23 := l_alias_attribute_value;
ELSIF p_segment = 'ATTRIBUTE24'  THEN
  p_alias_val_att_to_match_row.ATTRIBUTE24 := l_alias_attribute_value;
ELSIF p_segment = 'ATTRIBUTE25'  THEN
  p_alias_val_att_to_match_row.ATTRIBUTE25 := l_alias_attribute_value;
ELSIF p_segment = 'ATTRIBUTE26'  THEN
  p_alias_val_att_to_match_row.ATTRIBUTE26 := l_alias_attribute_value;
ELSIF p_segment = 'ATTRIBUTE27'  THEN
  p_alias_val_att_to_match_row.ATTRIBUTE27 := l_alias_attribute_value;
ELSIF p_segment = 'ATTRIBUTE28'  THEN
  p_alias_val_att_to_match_row.ATTRIBUTE28 := l_alias_attribute_value;
ELSIF p_segment = 'ATTRIBUTE29'  THEN
  p_alias_val_att_to_match_row.ATTRIBUTE29 := l_alias_attribute_value;
ELSIF p_segment = 'ATTRIBUTE30'  THEN
  p_alias_val_att_to_match_row.ATTRIBUTE30 := l_alias_attribute_value;
END IF;


END set_attribute_on_att_to_match;

-- --------------------------------------------------------------------------
-- |------------------------< get_alias_val_att_to_match>--------------------|
-- --------------------------------------------------------------------------
-- | This procedure is used to create the alias_val_att_to_match for a	     |
-- | certain alias_value_id (use when DDF context type of alias		     |
-- --------------------------------------------------------------------------
PROCEDURE get_alias_val_att_to_match
  (p_alias_definition_id	IN NUMBER,
   p_alias_value_id		IN NUMBER,
   p_alias_val_att_to_match	IN OUT NOCOPY t_alias_val_att_to_match)
   IS


cursor crs_mapping_info is
select  hmc.bld_blk_info_type_id,segment,bld_blk_info_type,
	hatc.component_type,hatc.component_name,bldu.building_block_category,
	reference_object
from hxc_mapping_components hmc,
     hxc_alias_types hat,
     hxc_alias_type_components hatc,
     hxc_alias_definitions had,
     hxc_bld_blk_info_type_usages bldu,
     hxc_bld_blk_info_types bld
where had.alias_definition_id = p_alias_definition_id
and   had.alias_type_id = hat.alias_type_id
and   hatc.alias_type_id = hat.alias_type_id
and   hmc.mapping_component_id = hatc.mapping_component_id
and   bld.bld_blk_info_type_id = hmc.bld_blk_info_type_id
and   bld.bld_blk_info_type_id = hmc.bld_blk_info_type_id
and   bld.bld_blk_info_type_id = bldu.bld_blk_info_type_id
order by hatc.component_name;


l_index			NUMBER;
l_match_to_delete	BOOLEAN;

BEGIN

-- first we need to look if the definition of this alias
-- exists in the reference global pl/sql table.
IF g_alias_def_val_att_rec.exists(p_alias_value_id) THEN
   -- populate the out parameter
   FOR l_index in
   	g_alias_def_val_att_rec(p_alias_value_id).start_index..g_alias_def_val_att_rec(p_alias_value_id).end_index
   	 LOOP
   	 p_alias_val_att_to_match(l_index) := g_alias_val_att_to_match(l_index);
   END LOOP;

ELSE
  -- find the first available index in the g_alias_val_att_to_match
  IF g_alias_val_att_to_match.exists(g_alias_val_att_to_match.last) THEN
    l_index := g_alias_val_att_to_match.last + 1;
  ELSE
    l_index := 1 ;
  END if;

  -- record then the index
  g_alias_def_val_att_rec(p_alias_value_id).start_index := l_index;

  FOR c_mapping_info in crs_mapping_info LOOP


 ----dbms_output.put_line
 --          ('p_alias_val_att_to_match(l_index).SEGMENT: '||p_alias_val_att_to_match(l_index).SEGMENT);

     p_alias_val_att_to_match(l_index).BLD_BLK_INFO_TYPE_ID 	:= c_mapping_info.bld_blk_info_type_id;
     p_alias_val_att_to_match(l_index).BLD_BLK_INFO_TYPE 	:= c_mapping_info.bld_blk_info_type;
     p_alias_val_att_to_match(l_index).COMPONENT_NAME		:= c_mapping_info.component_name;
     p_alias_val_att_to_match(l_index).COMPONENT_TYPE		:= c_mapping_info.component_type;
     p_alias_val_att_to_match(l_index).REFERENCE_OBJECT		:= c_mapping_info.reference_object;
     p_alias_val_att_to_match(l_index).SEGMENT			:= c_mapping_info.segment;
     p_alias_val_att_to_match(l_index).MAPPING_ATT_CAT		:= c_mapping_info.building_block_category;


   -- for the specify component_type we need to find the value to put in the
   -- attribute information.
   set_attribute_on_att_to_match(
   		p_alias_val_att_to_match_row 	=> p_alias_val_att_to_match(l_index),
   		p_alias_value_id		=> p_alias_value_id,
   		p_component_type		=> c_mapping_info.component_type,
   		p_segment			=> c_mapping_info.segment,
   		p_bld_blk_info_type		=> c_mapping_info.bld_blk_info_type,
   		p_attribute_mapping_category    => c_mapping_info.building_block_category,
   		p_match_to_delete		=> l_match_to_delete);


   IF (l_match_to_delete = TRUE) THEN
     p_alias_val_att_to_match.delete(l_index);
   ELSE
     g_alias_val_att_to_match(l_index) := p_alias_val_att_to_match(l_index);

     l_index := l_index + 1;
   END IF;

  END LOOP;

  -- keep the record in the global table
  g_alias_def_val_att_rec(p_alias_value_id).end_index := g_alias_val_att_to_match.last;

END IF;

END get_alias_val_att_to_match;


-- --------------------------------------------------------------------------
-- |------------------------< get_alias_val_att_to_match>--------------------|
-- --------------------------------------------------------------------------
-- | This procedure is used to create the alias_val_att_to_match for a	     |
-- | certain alias_value_id (use when DDF context type of alias		     |
-- --------------------------------------------------------------------------
PROCEDURE get_alias_val_att_to_match
  (p_alias_definition_id	IN NUMBER,
   p_alias_val_att_to_match	IN OUT NOCOPY t_alias_val_att_to_match)
   IS


cursor crs_mapping_info is
select  hmc.bld_blk_info_type_id,segment,bld_blk_info_type,
	hatc.component_type,hatc.component_name,bldu.building_block_category,
	reference_object
from hxc_mapping_components hmc,
     hxc_alias_types hat,
     hxc_alias_type_components hatc,
     hxc_alias_definitions had,
     hxc_bld_blk_info_type_usages bldu,
     hxc_bld_blk_info_types bld
where had.alias_definition_id = p_alias_definition_id
and   had.alias_type_id = hat.alias_type_id
and   hatc.alias_type_id = hat.alias_type_id
and   hmc.mapping_component_id = hatc.mapping_component_id
and   bld.bld_blk_info_type_id = hmc.bld_blk_info_type_id
and   bld.bld_blk_info_type_id = hmc.bld_blk_info_type_id
and   bld.bld_blk_info_type_id = bldu.bld_blk_info_type_id
order by hatc.component_name;


l_index			NUMBER;
l_match_to_delete	BOOLEAN;

BEGIN

-- first we need to look if the definition of this alias
-- exists in the reference global pl/sql table.
IF g_alias_def_att_rec.exists(p_alias_definition_id) THEN
   -- populate the out parameter
   FOR l_index in
   	g_alias_def_att_rec(p_alias_definition_id).start_index..g_alias_def_att_rec(p_alias_definition_id).end_index
   	 LOOP
   	 p_alias_val_att_to_match(l_index) := g_alias_def_att_to_match(l_index);
   END LOOP;

ELSE
  -- find the first available index in the g_alias_def_att_to_match
  IF g_alias_def_att_to_match.exists(g_alias_def_att_to_match.last) THEN
    l_index := g_alias_def_att_to_match.last + 1;
  ELSE
    l_index := 1 ;
  END if;

  -- record then the index
  g_alias_def_att_rec(p_alias_definition_id).start_index := l_index;

  FOR c_mapping_info in crs_mapping_info LOOP


 ----dbms_output.put_line
 --          ('p_alias_val_att_to_match(l_index).SEGMENT: '||p_alias_val_att_to_match(l_index).SEGMENT);

     p_alias_val_att_to_match(l_index).BLD_BLK_INFO_TYPE_ID 	:= c_mapping_info.bld_blk_info_type_id;
     p_alias_val_att_to_match(l_index).BLD_BLK_INFO_TYPE 	:= c_mapping_info.bld_blk_info_type;
     p_alias_val_att_to_match(l_index).COMPONENT_NAME		:= c_mapping_info.component_name;
     p_alias_val_att_to_match(l_index).COMPONENT_TYPE		:= c_mapping_info.component_type;
     p_alias_val_att_to_match(l_index).REFERENCE_OBJECT		:= c_mapping_info.reference_object;
     p_alias_val_att_to_match(l_index).SEGMENT			:= c_mapping_info.segment;
     p_alias_val_att_to_match(l_index).MAPPING_ATT_CAT		:= c_mapping_info.building_block_category;


   -- for the specify component_type we need to find the value to put in the
   -- attribute information.
   set_attribute_on_att_to_match(
   		p_alias_val_att_to_match_row 	=> p_alias_val_att_to_match(l_index),
   		p_alias_value_id		=> null,
   		p_component_type		=> c_mapping_info.component_type,
   		p_segment			=> c_mapping_info.segment,
   		p_bld_blk_info_type		=> c_mapping_info.bld_blk_info_type,
   		p_attribute_mapping_category    => c_mapping_info.building_block_category,
   		p_match_to_delete		=> l_match_to_delete);


     g_alias_def_att_to_match(l_index) := p_alias_val_att_to_match(l_index);

     l_index := l_index + 1;

  END LOOP;

  -- keep the record in the global table
  g_alias_def_att_rec(p_alias_definition_id).end_index := g_alias_def_att_to_match.last;

END IF;

END get_alias_val_att_to_match;

-- --------------------------------------------------------------------------
-- |------------------------< get_tbb_id_reference_table>--------------------|
-- --------------------------------------------------------------------------
-- | This procedure creates a pl/sql reference table for attributes index    |
-- | attached to a tim_building_block_id				     |
-- --------------------------------------------------------------------------

PROCEDURE get_tbb_id_reference_table
  (p_attributes 		IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE,--hxc_self_service_time_deposit.building_block_attribute_info,
   p_tbb_id_reference_table	IN OUT NOCOPY t_tbb_id_reference)
   IS

l_attribute_index 		NUMBER;

l_tbb_id 			NUMBER;
l_att_id			NUMBER;

BEGIN
-- for each tbb_id create an entry in the tbb_id_reference_table
l_attribute_index := p_attributes.first;

LOOP
 EXIT WHEN NOT p_attributes.exists(l_attribute_index);

 l_tbb_id := p_attributes(l_attribute_index).BUILDING_BLOCK_ID;
 l_att_id := p_attributes(l_attribute_index).TIME_ATTRIBUTE_ID;

 IF p_tbb_id_reference_table.exists (l_tbb_id) THEN

  p_tbb_id_reference_table(l_tbb_id).ATTRIBUTE_INDEX :=
  	p_tbb_id_reference_table(l_tbb_id).ATTRIBUTE_INDEX ||'|'||l_attribute_index;
 ELSE
  p_tbb_id_reference_table(l_tbb_id).ATTRIBUTE_INDEX := '|'||l_attribute_index;
 END IF;

 l_attribute_index := p_attributes.next(l_attribute_index);

END LOOP;

END get_tbb_id_reference_table;

-- ----------------------------------------------------------------------------
-- |------------------------< get_tbb_date_reference_table>--------------------|
-- ----------------------------------------------------------------------------
-- | This procedure creates a pl/sql reference table for the day date	       |
-- | attached to a detail time_building_block_id			       |
-- ----------------------------------------------------------------------------
PROCEDURE get_tbb_date_reference_table
  (p_blocks	 		IN OUT NOCOPY HXC_BLOCK_TABLE_TYPE,--hxc_self_service_time_deposit.timecard_info,
   p_tbb_date_reference_table	IN OUT NOCOPY t_tbb_date_reference_table,
   p_timecard_start_time	OUT    NOCOPY DATE,
   p_timecard_stop_time		OUT    NOCOPY DATE)
   IS

l_tbb_index 		NUMBER;

l_tbb_id		NUMBER;
l_parent_tbb_id		NUMBER;
l_start_time		DATE;
l_stop_time		DATE;
l_scope			hxc_time_building_blocks.SCOPE%TYPE;
--l_template		BOOLEAN := FALSE;
--l_tbb_date_reference_table 	t_tbb_date_reference_table;

BEGIN

-- The first round we are looking for the date attached to the day.
-- for each tbb_id create an entry in the tbb_id_reference_table
l_tbb_index := p_blocks.first;

LOOP
 EXIT WHEN NOT p_blocks.exists(l_tbb_index);

 l_start_time 	:= FND_DATE.CANONICAL_TO_DATE(p_blocks(l_tbb_index).START_TIME);
 l_stop_time 	:= FND_DATE.CANONICAL_TO_DATE(p_blocks(l_tbb_index).STOP_TIME);
 l_tbb_id	:= p_blocks(l_tbb_index).TIME_BUILDING_BLOCK_ID;
 l_scope        := p_blocks(l_tbb_index).SCOPE;



  IF (l_scope = 'TIMECARD' or l_scope = 'TIMECARD_TEMPLATE')
  THEN
     p_timecard_start_time := l_start_time;
     p_timecard_stop_time  := l_stop_time;
  END IF;


--dbms_output.put_line ('l_start_time:'||l_start_time);
--dbms_output.put_line ('l_stop_time:'||l_stop_time);
--dbms_output.put_line ('l_tbb_id:'||l_tbb_id);
--dbms_output.put_line ('l_scope:'||l_scope);



 -- we are recording the date attached to the day
 IF( not(p_tbb_date_reference_table.exists(l_tbb_id) )
     AND l_scope = 'DAY') THEN
--dbms_output.put_line ('add one '||l_tbb_id);

  p_tbb_date_reference_table(l_tbb_id).START_TIME	 :=  l_start_time;
  p_tbb_date_reference_table(l_tbb_id).STOP_TIME	 :=  l_stop_time;

 END IF;

 l_tbb_index := p_blocks.next(l_tbb_index);

END LOOP;

-- The second round we are looking for the date attached to the detail.
-- by looking into the table previsouly created
l_tbb_index := p_blocks.first;

LOOP
 EXIT WHEN NOT p_blocks.exists(l_tbb_index);

 l_tbb_id		:= p_blocks(l_tbb_index).TIME_BUILDING_BLOCK_ID;
 l_parent_tbb_id	:= p_blocks(l_tbb_index).PARENT_BUILDING_BLOCK_ID;
 l_scope        	:= p_blocks(l_tbb_index).SCOPE;

 -- we are recording the date attached to the day
 IF (not(p_tbb_date_reference_table.exists(l_tbb_id))
    AND l_scope = 'DETAIL') THEN
   -- we are looking for his parent
   l_start_time 	:= p_tbb_date_reference_table(l_parent_tbb_id).START_TIME;
   l_stop_time 		:= p_tbb_date_reference_table(l_parent_tbb_id).STOP_TIME;
--dbms_output.put_line ('add one '||l_tbb_id);

--dbms_output.put_line ('l_start_time:'||l_start_time);
--dbms_output.put_line ('l_stop_time:'||l_stop_time);


   p_tbb_date_reference_table(l_tbb_id).START_TIME	 :=  l_start_time;
   p_tbb_date_reference_table(l_tbb_id).STOP_TIME	 :=  l_stop_time;

 END IF;

 l_tbb_index := p_blocks.next(l_tbb_index);

END LOOP;

END get_tbb_date_reference_table;


-- ----------------------------------------------------------------------------
-- |------------------< check_alternate_with_layout for SS >--------------------|
-- ----------------------------------------------------------------------------
-- |  This function check that the reference object of the alias is the same    |
-- |  of the layout							        |
--------------------------------------------------------------------------------
FUNCTION check_alias_with_layout
		(p_layout_alias_ref_name	IN VARCHAR2,
		 p_layout_att_cat		IN VARCHAR2,
		 p_resource_id			IN NUMBER,
		 p_layout_id			IN NUMBER,
		 p_alias_label			IN VARCHAR2,
		 p_alias_definition_id		IN NUMBER,
		 p_pref_start_date		IN DATE,
		 p_pref_end_date		IN DATE)
		 RETURN BOOLEAN IS

l_alias_type 		hxc_alias_types.alias_type%TYPE;
l_reference_object	hxc_alias_types.reference_object%TYPE;
l_prompt		hxc_alias_definitions_tl.prompt%TYPE;

l_index_global		NUMBER;

l_find_alias		BOOLEAN := FALSE;

BEGIN

get_alias_definition_info
      (p_alias_definition_id,
       l_alias_type,
       l_reference_object,
       l_prompt);

IF (g_alias_def_item.exists(g_alias_def_item.last)) THEN
   l_index_global := g_alias_def_item.last + 1;
ELSE
   l_index_global := 1;
END IF;


IF p_layout_alias_ref_name = l_reference_object THEN
   -- we are adding the information into the alias table
   -- to do the translation
   g_alias_def_item(l_index_global).ALIAS_DEFINITION_ID     := p_alias_definition_id;
   g_alias_def_item(l_index_global).ITEM_ATTRIBUTE_CATEGORY := p_layout_att_cat;
   g_alias_def_item(l_index_global).RESOURCE_ID	   	    := p_resource_id;
   g_alias_def_item(l_index_global).LAYOUT_ID	   	    := p_layout_id;
   g_alias_def_item(l_index_global).ALIAS_LABEL	   	    := p_alias_label;
   g_alias_def_item(l_index_global).PREF_START_DATE   	    := p_pref_start_date;
   g_alias_def_item(l_index_global).PREF_END_DATE	    := p_pref_end_date;

-- bug 3083904 (minimal impact)
-- implemented this way just in case to
-- revert back the solution.
l_find_alias := FALSE;

END IF;

RETURN l_find_alias;

END check_alias_with_layout;

-- ----------------------------------------------------------------------------
-- |------------------------< get_alias_def_item    for SS >--------------------|
-- ----------------------------------------------------------------------------
-- |  This procedure returns by looking on the preference of the timekeeper    |
-- |  a pl/sql table that contains the alias attribute information	       |
--------------------------------------------------------------------------------
PROCEDURE get_alias_def_item
    		(p_resource_id 		IN NUMBER,
    		 p_attributes		IN OUT NOCOPY 	HXC_ATTRIBUTE_TABLE_TYPE,--hxc_self_service_time_deposit.building_block_attribute_info,
    		 p_alias_def_item	IN OUT NOCOPY 	t_alias_def_item,
    		 p_start_time		IN DATE,
    		 p_stop_time		IN DATE,
    		 p_cache_label 		IN BOOLEAN DEFAULT FALSE) IS


CURSOR csr_lay_alias_comp(p_layout_id NUMBER)
IS
select layout_component_id, QUALIFIER_ATTRIBUTE24,
       QUALIFIER_ATTRIBUTE27,QUALIFIER_ATTRIBUTE26,LABEL
from  hxc_layout_components_v
where layout_id = p_layout_id;
--and   QUALIFIER_ATTRIBUTE26 like 'OTL_ALIAS%';

l_attribute_index	NUMBER;
l_pref_index		NUMBER;
l_alternate_name_index	NUMBER;
l_index_global		NUMBER;
l_comp_index		NUMBER;

l_layout_id		NUMBER;

l_pref_table      hxc_preference_evaluation.t_pref_table;

l_layout_comp_id 	NUMBER 	     := NULL;
l_att_cat    		varchar2(80) := NULL;
l_alias_ref 		varchar2(80) := NULL;
l_alias_label		varchar2(80) := NULL;

l_index_public_temp     NUMBER;
l_public_template       BOOLEAN := FALSE;
l_public_template_for_pref_evl BOOLEAN := FALSE;
l_find_alias		BOOLEAN;
l_timecard_layout_id    number;

BEGIN

-- first we need to find the layout id
-- by looking into the attribute table
l_attribute_index := p_attributes.first;
LOOP
  EXIT WHEN
     (NOT p_attributes.exists(l_attribute_index));

  IF (p_attributes(l_attribute_index).ATTRIBUTE_CATEGORY = 'LAYOUT') THEN
    --found the layout id
    l_layout_id := to_number(p_attributes(l_attribute_index).ATTRIBUTE2);
    l_timecard_layout_id := to_number(p_attributes(l_attribute_index).ATTRIBUTE1);

  END IF;

  IF  (p_attributes(l_attribute_index).ATTRIBUTE_CATEGORY = 'TEMPLATES'
  AND  p_attributes(l_attribute_index).ATTRIBUTE2 = 'PUBLIC')
  THEN
    -- we are in the case of the public template.
    -- Therefore we need to take alias definition id from the
    -- attributes.

     --Always use the timecard layoutid for the publictemplates.
     l_layout_id := l_timecard_layout_id;

     IF (p_attributes(l_attribute_index).ATTRIBUTE5 is not null
     or p_attributes(l_attribute_index).ATTRIBUTE6 is not null
     or p_attributes(l_attribute_index).ATTRIBUTE7 is not null
     or p_attributes(l_attribute_index).ATTRIBUTE8 is not null
     or p_attributes(l_attribute_index).ATTRIBUTE9 is not null
     or p_attributes(l_attribute_index).ATTRIBUTE10 is not null
     or p_attributes(l_attribute_index).ATTRIBUTE11 is not null
     or p_attributes(l_attribute_index).ATTRIBUTE12 is not null
     or p_attributes(l_attribute_index).ATTRIBUTE13 is not null
     or p_attributes(l_attribute_index).ATTRIBUTE14 is not null
     ) THEN
	    l_public_template   := TRUE;
	    l_index_public_temp := l_attribute_index;
     END IF;
    l_public_template_for_pref_evl := TRUE;
    -- The reason for adding a new variable here is because l_public_template
    -- variable is specifically used to check the whether the alias translation
    -- needs to be done for public templates. This variable would yield false
    -- for project specific layouts, since there wouldnt be any alternate name.
    -- if we take out the not null checks for all the attributes, then alias
    -- translation process would be carried for projects timecard also which would
    -- have a slight performance impact. Need to confirm with joel regarding this
    --point.

  END IF;

  l_attribute_index := p_attributes.next(l_attribute_index);

END LOOP;

-- If the layout_id is null then we
-- need to pick the one attached to the
-- preference at the sysdate
IF l_layout_id is null THEN

   l_layout_id := to_number(
       hxc_preference_evaluation.resource_preferences(
        p_resource_id ,'TC_W_TCRD_LAYOUT',2));
END IF;

IF l_timecard_layout_id is null THEN

   l_timecard_layout_id:= to_number(
       hxc_preference_evaluation.resource_preferences(
        p_resource_id ,'TC_W_TCRD_LAYOUT',1));
END IF;



-- Before going further we need to check if we are in the case of the
-- public template and work on the attribute which could contain the
-- alias definition id;
IF (l_public_template) THEN

 g_alias_def_item.delete;
 g_comp_label.delete;

 FOR layout_comp IN csr_lay_alias_comp(l_layout_id) LOOP

   --l_layout_comp_id 	:= layout_comp.layout_component_id;
   l_att_cat 		:= layout_comp.QUALIFIER_ATTRIBUTE26;
   l_alias_ref  	:= layout_comp.QUALIFIER_ATTRIBUTE24;
   l_alias_label	:= layout_comp.label;

   l_find_alias		:= FALSE;

   IF p_attributes(l_index_public_temp).ATTRIBUTE5 is not null THEN

     l_find_alias :=
                check_alias_with_layout
		(p_layout_alias_ref_name	=> l_alias_ref,
		 p_layout_att_cat		=> l_att_cat,
		 p_resource_id			=> p_resource_id,
		 p_layout_id			=> l_layout_id,
		 p_alias_label			=> l_alias_label,
		 p_alias_definition_id		=> to_number(p_attributes(l_index_public_temp).ATTRIBUTE5),
		 p_pref_start_date		=> p_start_time,
		 p_pref_end_date		=> p_stop_time);

   END IF;

   IF p_attributes(l_index_public_temp).ATTRIBUTE6 is not null THEN

     l_find_alias :=
                check_alias_with_layout
		(p_layout_alias_ref_name	=> l_alias_ref,
		 p_layout_att_cat		=> l_att_cat,
		 p_resource_id			=> p_resource_id,
		 p_layout_id			=> l_layout_id,
		 p_alias_label			=> l_alias_label,
		 p_alias_definition_id		=> to_number(p_attributes(l_index_public_temp).ATTRIBUTE6),
		 p_pref_start_date		=> p_start_time,
		 p_pref_end_date		=> p_stop_time);

   END IF;

   IF p_attributes(l_index_public_temp).ATTRIBUTE7 is not null THEN

     l_find_alias :=
                check_alias_with_layout
		(p_layout_alias_ref_name	=> l_alias_ref,
		 p_layout_att_cat		=> l_att_cat,
		 p_resource_id			=> p_resource_id,
		 p_layout_id			=> l_layout_id,
		 p_alias_label			=> l_alias_label,
		 p_alias_definition_id		=> to_number(p_attributes(l_index_public_temp).ATTRIBUTE7),
		 p_pref_start_date		=> p_start_time,
		 p_pref_end_date		=> p_stop_time);

   END IF;

   IF p_attributes(l_index_public_temp).ATTRIBUTE8 is not null THEN

     l_find_alias :=
                check_alias_with_layout
		(p_layout_alias_ref_name	=> l_alias_ref,
		 p_layout_att_cat		=> l_att_cat,
		 p_resource_id			=> p_resource_id,
		 p_layout_id			=> l_layout_id,
		 p_alias_label			=> l_alias_label,
		 p_alias_definition_id		=> to_number(p_attributes(l_index_public_temp).ATTRIBUTE8),
		 p_pref_start_date		=> p_start_time,
		 p_pref_end_date		=> p_stop_time);

   END IF;

   IF p_attributes(l_index_public_temp).ATTRIBUTE9 is not null THEN

     l_find_alias :=
                check_alias_with_layout
		(p_layout_alias_ref_name	=> l_alias_ref,
		 p_layout_att_cat		=> l_att_cat,
		 p_resource_id			=> p_resource_id,
		 p_layout_id			=> l_layout_id,
		 p_alias_label			=> l_alias_label,
		 p_alias_definition_id		=> to_number(p_attributes(l_index_public_temp).ATTRIBUTE9),
		 p_pref_start_date		=> p_start_time,
		 p_pref_end_date		=> p_stop_time);

   END IF;

   IF p_attributes(l_index_public_temp).ATTRIBUTE10 is not null THEN

     l_find_alias :=
                check_alias_with_layout
		(p_layout_alias_ref_name	=> l_alias_ref,
		 p_layout_att_cat		=> l_att_cat,
		 p_resource_id			=> p_resource_id,
		 p_layout_id			=> l_layout_id,
		 p_alias_label			=> l_alias_label,
		 p_alias_definition_id		=> to_number(p_attributes(l_index_public_temp).ATTRIBUTE10),
		 p_pref_start_date		=> p_start_time,
		 p_pref_end_date		=> p_stop_time);

   END IF;

   IF p_attributes(l_index_public_temp).ATTRIBUTE11 is not null THEN

     l_find_alias :=
                check_alias_with_layout
		(p_layout_alias_ref_name	=> l_alias_ref,
		 p_layout_att_cat		=> l_att_cat,
		 p_resource_id			=> p_resource_id,
		 p_layout_id			=> l_layout_id,
		 p_alias_label			=> l_alias_label,
		 p_alias_definition_id		=> to_number(p_attributes(l_index_public_temp).ATTRIBUTE11),
		 p_pref_start_date		=> p_start_time,
		 p_pref_end_date		=> p_stop_time);

   END IF;

   IF p_attributes(l_index_public_temp).ATTRIBUTE12 is not null THEN

     l_find_alias :=
                check_alias_with_layout
		(p_layout_alias_ref_name	=> l_alias_ref,
		 p_layout_att_cat		=> l_att_cat,
		 p_resource_id			=> p_resource_id,
		 p_layout_id			=> l_layout_id,
		 p_alias_label			=> l_alias_label,
		 p_alias_definition_id		=> to_number(p_attributes(l_index_public_temp).ATTRIBUTE12),
		 p_pref_start_date		=> p_start_time,
		 p_pref_end_date		=> p_stop_time);

   END IF;

   IF p_attributes(l_index_public_temp).ATTRIBUTE13 is not null THEN

     l_find_alias :=
                check_alias_with_layout
		(p_layout_alias_ref_name	=> l_alias_ref,
		 p_layout_att_cat		=> l_att_cat,
		 p_resource_id			=> p_resource_id,
		 p_layout_id			=> l_layout_id,
		 p_alias_label			=> l_alias_label,
		 p_alias_definition_id		=> to_number(p_attributes(l_index_public_temp).ATTRIBUTE13),
		 p_pref_start_date		=> p_start_time,
		 p_pref_end_date		=> p_stop_time);

   END IF;

   IF p_attributes(l_index_public_temp).ATTRIBUTE14 is not null THEN

     l_find_alias :=
                check_alias_with_layout
		(p_layout_alias_ref_name	=> l_alias_ref,
		 p_layout_att_cat		=> l_att_cat,
		 p_resource_id			=> p_resource_id,
		 p_layout_id			=> l_layout_id,
		 p_alias_label			=> l_alias_label,
		 p_alias_definition_id		=> to_number(p_attributes(l_index_public_temp).ATTRIBUTE14),
		 p_pref_start_date		=> p_start_time,
		 p_pref_end_date		=> p_stop_time);

   END IF;

  END LOOP;
  -- associate the global table to the out parameters
  p_alias_def_item := g_alias_def_item;
  -- in this case we stop here.
  return;

END IF;



-- look if we have already the information of the resource into
-- the global table
-- looking the first row is enought. This table handle only
-- the information for one layout therefore if the layout_id
-- in the table is different with the parameter we are deleting the
-- table info.

--if g_debug then
	--hr_utility.trace('layout_id '||l_layout_id);
	--hr_utility.trace('g_alias_def_item '||g_alias_def_item.first);
--end if;

l_index_global := g_alias_def_item.first;


-- we will not use
IF g_alias_def_item.exists(l_index_global) THEN

   IF g_alias_def_item(l_index_global).LAYOUT_ID = l_layout_id and
      trunc(g_alias_def_item(l_index_global).PREF_START_DATE) = trunc(p_start_time) and
      trunc(g_alias_def_item(l_index_global).PREF_END_DATE) = trunc(p_stop_time) and
      g_alias_def_item(l_index_global).RESOURCE_ID = p_resource_id THEN
      --
      p_alias_def_item := g_alias_def_item;

      -- before return let check that the g_comp_label
      -- is not null
      IF (p_cache_label and g_comp_label.count = 0)  THEN

         FOR layout_comp IN csr_lay_alias_comp(l_timecard_layout_id) LOOP

          --l_layout_comp_id 	:= layout_comp.layout_component_id;
          l_att_cat 	:= layout_comp.QUALIFIER_ATTRIBUTE26;
          l_alias_ref  	:= layout_comp.QUALIFIER_ATTRIBUTE24;
          l_alias_label	:= layout_comp.label;

          --IF (l_att_cat is not null) THEN
  	  l_comp_index := nvl(g_comp_label.last,0) + 1;

          IF l_att_cat is null and layout_comp.QUALIFIER_ATTRIBUTE27 is null THEN
           null;
          ELSE
            g_comp_label(l_comp_index).MAPPING_ATT_CAT	      := l_att_cat;
            g_comp_label(l_comp_index).SEGMENT		      := layout_comp.QUALIFIER_ATTRIBUTE27;
            g_comp_label(l_comp_index).ATTRIBUTE1	      := l_alias_label;
          END IF;
          --END IF;

	 END LOOP;
       END IF;
      -- finally we return
/*
if g_debug then
	hr_utility.trace('count '||p_alias_def_item.count);
	hr_utility.trace('ALIAS_DEFINITION_ID '||p_alias_def_item(p_alias_def_item.first).ALIAS_DEFINITION_ID);
	hr_utility.trace('ITEM_ATTRIBUTE_CATEGORY '||p_alias_def_item(p_alias_def_item.first).ITEM_ATTRIBUTE_CATEGORY);
	hr_utility.trace('RESOURCE_ID '||p_alias_def_item(p_alias_def_item.first).RESOURCE_ID);
	hr_utility.trace('LAYOUT_ID '||p_alias_def_item(p_alias_def_item.first).LAYOUT_ID);
	hr_utility.trace('ALIAS_LABEL '||p_alias_def_item(p_alias_def_item.first).ALIAS_LABEL);
	hr_utility.trace('PREF_START_DATE '||p_alias_def_item(p_alias_def_item.first).PREF_START_DATE);
	hr_utility.trace('PREF_END_DATE '||p_alias_def_item(p_alias_def_item.first).PREF_END_DATE);
end if;
*/
      return;
   ELSE
      --
      g_alias_def_item.delete;
      g_comp_label.delete;
   END IF;

END IF;

--g_alias_def_item.delete;
--dbms_output.put_line ('set 3 :');

-- we are calling the preference now for the resource
if(l_public_template_for_pref_evl) THEN
	hxc_preference_evaluation.resource_preferences(
	p_resource_id => p_resource_id ,
	p_start_evaluation_date => SYSDATE,--FND_DATE.CANONICAL_TO_DATE(p_start_time),
	p_end_evaluation_date => hr_general.end_of_time,--FND_DATE.CANONICAL_TO_DATE(p_stop_time),
	p_pref_table => l_pref_table);
ELSE
	hxc_preference_evaluation.resource_preferences(
	p_resource_id => p_resource_id ,
	p_start_evaluation_date => p_start_time,--FND_DATE.CANONICAL_TO_DATE(p_start_time),
	p_end_evaluation_date => p_stop_time,--FND_DATE.CANONICAL_TO_DATE(p_stop_time),
	p_pref_table => l_pref_table);
END IF;



-- find the index of the alternate name preference and
-- we are taking care in the case of a null layout
l_pref_index :=l_pref_table.FIRST;

LOOP
  EXIT WHEN
     (NOT l_pref_table.exists(l_pref_index));

 IF(l_pref_table(l_pref_index).preference_code = 'TC_W_TCRD_ALIASES') THEN

  l_alternate_name_index := l_pref_index;

--    ELSIF (l_pref_table(l_pref_index).preference_code = 'TC_W_TCRD_LAYOUT'
--    AND    l_layout_id is null) THEN
--       l_layout_id := l_pref_table(l_pref_index).attribute1;
--    END IF;

--    l_pref_index := l_pref_table.next(l_pref_index);

--END LOOP;

--
-- now we are ready to work out what alias need to go for the translation
--

-- first we find the type of the alias in the layout
-- we could have more than one.
  FOR layout_comp IN csr_lay_alias_comp(l_layout_id) LOOP

   --l_layout_comp_id 	:= layout_comp.layout_component_id;
   l_att_cat 		:= layout_comp.QUALIFIER_ATTRIBUTE26;
   l_alias_ref  	:= layout_comp.QUALIFIER_ATTRIBUTE24;
   l_alias_label	:= layout_comp.label;

   l_find_alias		:= FALSE;
/*
   IF (p_cache_label) THEN -- and l_att_cat is not null) THEN

     l_comp_index := nvl(g_comp_label.last,0) + 1;
     IF l_att_cat is null and layout_comp.QUALIFIER_ATTRIBUTE27 is null THEN
       null;
     ELSE
       g_comp_label(l_comp_index).MAPPING_ATT_CAT	      := l_att_cat;
       g_comp_label(l_comp_index).SEGMENT		      := layout_comp.QUALIFIER_ATTRIBUTE27;
       g_comp_label(l_comp_index).ATTRIBUTE1	      	      := l_alias_label;
     END IF;

   END IF;
*/

   -- we need to find the corresponding alias in the
   -- alternate name preference. We are checking on the
   -- reference object attached to the alias definition
   -- it is a little bit uguly here need to look
   -- on each attribute of the preference => 30 segs
   IF l_pref_table(l_alternate_name_index).ATTRIBUTE1 is not null THEN

     l_find_alias :=
                check_alias_with_layout
		(p_layout_alias_ref_name	=> l_alias_ref,
		 p_layout_att_cat		=> l_att_cat,
		 p_resource_id			=> p_resource_id,
		 p_layout_id			=> l_layout_id,
		 p_alias_label			=> l_alias_label,
		 p_alias_definition_id		=> to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE1),
		 p_pref_start_date		=> l_pref_table(l_alternate_name_index).START_DATE,
		 p_pref_end_date		=> l_pref_table(l_alternate_name_index).END_DATE);

   END IF;

   IF l_pref_table(l_alternate_name_index).ATTRIBUTE2 is not null THEN

      l_find_alias :=
                check_alias_with_layout
		(p_layout_alias_ref_name	=> l_alias_ref,
		 p_layout_att_cat		=> l_att_cat,
		 p_resource_id			=> p_resource_id,
		 p_alias_label			=> l_alias_label,
		 p_layout_id			=> l_layout_id,
		 p_alias_definition_id		=> to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE2),
		 p_pref_start_date		=> l_pref_table(l_alternate_name_index).START_DATE,
		 p_pref_end_date		=> l_pref_table(l_alternate_name_index).END_DATE);


   END IF;


   IF l_pref_table(l_alternate_name_index).ATTRIBUTE3 is not null THEN

      l_find_alias :=
                check_alias_with_layout
		(p_layout_alias_ref_name	=> l_alias_ref,
		 p_layout_att_cat		=> l_att_cat,
		 p_resource_id			=> p_resource_id,
		 p_layout_id			=> l_layout_id,
		 p_alias_label			=> l_alias_label,
		 p_alias_definition_id		=> to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE3),
		 p_pref_start_date		=> l_pref_table(l_alternate_name_index).START_DATE,
		 p_pref_end_date		=> l_pref_table(l_alternate_name_index).END_DATE);


   END IF;
   IF l_pref_table(l_alternate_name_index).ATTRIBUTE4 is not null THEN

      l_find_alias :=
                check_alias_with_layout
		(p_layout_alias_ref_name	=> l_alias_ref,
		 p_layout_att_cat		=> l_att_cat,
		 p_resource_id			=> p_resource_id,
		 p_layout_id			=> l_layout_id,
		 p_alias_label			=> l_alias_label,
		 p_alias_definition_id		=> to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE4),
		 p_pref_start_date		=> l_pref_table(l_alternate_name_index).START_DATE,
		 p_pref_end_date		=> l_pref_table(l_alternate_name_index).END_DATE);


   END IF;
   IF l_pref_table(l_alternate_name_index).ATTRIBUTE5 is not null THEN

      l_find_alias :=
                check_alias_with_layout
		(p_layout_alias_ref_name	=> l_alias_ref,
		 p_layout_att_cat		=> l_att_cat,
		 p_resource_id			=> p_resource_id,
		 p_layout_id			=> l_layout_id,
		 p_alias_label			=> l_alias_label,
		 p_alias_definition_id		=> to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE5),
		 p_pref_start_date		=> l_pref_table(l_alternate_name_index).START_DATE,
		 p_pref_end_date		=> l_pref_table(l_alternate_name_index).END_DATE);


   END IF;
   IF l_pref_table(l_alternate_name_index).ATTRIBUTE6 is not null THEN

      l_find_alias :=
                check_alias_with_layout
		(p_layout_alias_ref_name	=> l_alias_ref,
		 p_layout_att_cat		=> l_att_cat,
		 p_resource_id			=> p_resource_id,
		 p_layout_id			=> l_layout_id,
		 p_alias_label			=> l_alias_label,
		 p_alias_definition_id		=> to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE6),
		 p_pref_start_date		=> l_pref_table(l_alternate_name_index).START_DATE,
		 p_pref_end_date		=> l_pref_table(l_alternate_name_index).END_DATE);


   END IF;
   IF l_pref_table(l_alternate_name_index).ATTRIBUTE7 is not null THEN

      l_find_alias :=
                check_alias_with_layout
		(p_layout_alias_ref_name	=> l_alias_ref,
		 p_layout_att_cat		=> l_att_cat,
		 p_resource_id			=> p_resource_id,
		 p_layout_id			=> l_layout_id,
		 p_alias_label			=> l_alias_label,
		 p_alias_definition_id		=> to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE7),
		 p_pref_start_date		=> l_pref_table(l_alternate_name_index).START_DATE,
		 p_pref_end_date		=> l_pref_table(l_alternate_name_index).END_DATE);


   END IF;
   IF l_pref_table(l_alternate_name_index).ATTRIBUTE8 is not null THEN

      l_find_alias :=
                check_alias_with_layout
		(p_layout_alias_ref_name	=> l_alias_ref,
		 p_layout_att_cat		=> l_att_cat,
		 p_resource_id			=> p_resource_id,
		 p_layout_id			=> l_layout_id,
		 p_alias_label			=> l_alias_label,
		 p_alias_definition_id		=> to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE8),
		 p_pref_start_date		=> l_pref_table(l_alternate_name_index).START_DATE,
		 p_pref_end_date		=> l_pref_table(l_alternate_name_index).END_DATE);


   END IF;
   IF l_pref_table(l_alternate_name_index).ATTRIBUTE9 is not null THEN

      l_find_alias :=
                check_alias_with_layout
		(p_layout_alias_ref_name	=> l_alias_ref,
		 p_layout_att_cat		=> l_att_cat,
		 p_resource_id			=> p_resource_id,
		 p_layout_id			=> l_layout_id,
		 p_alias_label			=> l_alias_label,
		 p_alias_definition_id		=> to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE9),
		 p_pref_start_date		=> l_pref_table(l_alternate_name_index).START_DATE,
		 p_pref_end_date		=> l_pref_table(l_alternate_name_index).END_DATE);


   END IF;
   IF l_pref_table(l_alternate_name_index).ATTRIBUTE10 is not null THEN

      l_find_alias :=
                check_alias_with_layout
		(p_layout_alias_ref_name	=> l_alias_ref,
		 p_layout_att_cat		=> l_att_cat,
		 p_resource_id			=> p_resource_id,
		 p_layout_id			=> l_layout_id,
		 p_alias_label			=> l_alias_label,
		 p_alias_definition_id		=> to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE10),
		 p_pref_start_date		=> l_pref_table(l_alternate_name_index).START_DATE,
		 p_pref_end_date		=> l_pref_table(l_alternate_name_index).END_DATE);


   END IF;
   IF l_pref_table(l_alternate_name_index).ATTRIBUTE11 is not null THEN

      l_find_alias :=
                check_alias_with_layout
		(p_layout_alias_ref_name	=> l_alias_ref,
		 p_layout_att_cat		=> l_att_cat,
		 p_resource_id			=> p_resource_id,
		 p_layout_id			=> l_layout_id,
		 p_alias_label			=> l_alias_label,
		 p_alias_definition_id		=> to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE11),
		 p_pref_start_date		=> l_pref_table(l_alternate_name_index).START_DATE,
		 p_pref_end_date		=> l_pref_table(l_alternate_name_index).END_DATE);


   END IF;
   IF l_pref_table(l_alternate_name_index).ATTRIBUTE12 is not null THEN

      l_find_alias :=
                check_alias_with_layout
		(p_layout_alias_ref_name	=> l_alias_ref,
		 p_layout_att_cat		=> l_att_cat,
		 p_resource_id			=> p_resource_id,
		 p_layout_id			=> l_layout_id,
		 p_alias_label			=> l_alias_label,
		 p_alias_definition_id		=> to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE12),
		 p_pref_start_date		=> l_pref_table(l_alternate_name_index).START_DATE,
		 p_pref_end_date		=> l_pref_table(l_alternate_name_index).END_DATE);


   END IF;
   IF l_pref_table(l_alternate_name_index).ATTRIBUTE13 is not null THEN

      l_find_alias :=
                check_alias_with_layout
		(p_layout_alias_ref_name	=> l_alias_ref,
		 p_layout_att_cat		=> l_att_cat,
		 p_resource_id			=> p_resource_id,
		 p_layout_id			=> l_layout_id,
		 p_alias_label			=> l_alias_label,
		 p_alias_definition_id		=> to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE13),
		 p_pref_start_date		=> l_pref_table(l_alternate_name_index).START_DATE,
		 p_pref_end_date		=> l_pref_table(l_alternate_name_index).END_DATE);


   END IF;
   IF l_pref_table(l_alternate_name_index).ATTRIBUTE14 is not null THEN

      l_find_alias :=
                check_alias_with_layout
		(p_layout_alias_ref_name	=> l_alias_ref,
		 p_layout_att_cat		=> l_att_cat,
		 p_resource_id			=> p_resource_id,
		 p_layout_id			=> l_layout_id,
		 p_alias_label			=> l_alias_label,
		 p_alias_definition_id		=> to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE14),
		 p_pref_start_date		=> l_pref_table(l_alternate_name_index).START_DATE,
		 p_pref_end_date		=> l_pref_table(l_alternate_name_index).END_DATE);


   END IF;
   IF l_pref_table(l_alternate_name_index).ATTRIBUTE15 is not null THEN

      l_find_alias :=
                check_alias_with_layout
		(p_layout_alias_ref_name	=> l_alias_ref,
		 p_layout_att_cat		=> l_att_cat,
		 p_resource_id			=> p_resource_id,
		 p_layout_id			=> l_layout_id,
		 p_alias_label			=> l_alias_label,
		 p_alias_definition_id		=> to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE15),
		 p_pref_start_date		=> l_pref_table(l_alternate_name_index).START_DATE,
		 p_pref_end_date		=> l_pref_table(l_alternate_name_index).END_DATE);


   END IF;
   IF l_pref_table(l_alternate_name_index).ATTRIBUTE16 is not null THEN

      l_find_alias :=
                check_alias_with_layout
		(p_layout_alias_ref_name	=> l_alias_ref,
		 p_layout_att_cat		=> l_att_cat,
		 p_resource_id			=> p_resource_id,
		 p_layout_id			=> l_layout_id,
		 p_alias_label			=> l_alias_label,
		 p_alias_definition_id		=> to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE16),
		 p_pref_start_date		=> l_pref_table(l_alternate_name_index).START_DATE,
		 p_pref_end_date		=> l_pref_table(l_alternate_name_index).END_DATE);


   END IF;
   IF l_pref_table(l_alternate_name_index).ATTRIBUTE17 is not null THEN

      l_find_alias :=
                check_alias_with_layout
		(p_layout_alias_ref_name	=> l_alias_ref,
		 p_layout_att_cat		=> l_att_cat,
		 p_resource_id			=> p_resource_id,
		 p_layout_id			=> l_layout_id,
		 p_alias_label			=> l_alias_label,
		 p_alias_definition_id		=> to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE17),
		 p_pref_start_date		=> l_pref_table(l_alternate_name_index).START_DATE,
		 p_pref_end_date		=> l_pref_table(l_alternate_name_index).END_DATE);


   END IF;
   IF l_pref_table(l_alternate_name_index).ATTRIBUTE18 is not null THEN

      l_find_alias :=
                check_alias_with_layout
		(p_layout_alias_ref_name	=> l_alias_ref,
		 p_layout_att_cat		=> l_att_cat,
		 p_resource_id			=> p_resource_id,
		 p_layout_id			=> l_layout_id,
		 p_alias_label			=> l_alias_label,
		 p_alias_definition_id		=> to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE18),
		 p_pref_start_date		=> l_pref_table(l_alternate_name_index).START_DATE,
		 p_pref_end_date		=> l_pref_table(l_alternate_name_index).END_DATE);


   END IF;
   IF l_pref_table(l_alternate_name_index).ATTRIBUTE18 is not null THEN

      l_find_alias :=
                check_alias_with_layout
		(p_layout_alias_ref_name	=> l_alias_ref,
		 p_layout_att_cat		=> l_att_cat,
		 p_resource_id			=> p_resource_id,
		 p_layout_id			=> l_layout_id,
		 p_alias_label			=> l_alias_label,
		 p_alias_definition_id		=> to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE19),
		 p_pref_start_date		=> l_pref_table(l_alternate_name_index).START_DATE,
		 p_pref_end_date		=> l_pref_table(l_alternate_name_index).END_DATE);


   END IF;
   IF l_pref_table(l_alternate_name_index).ATTRIBUTE20 is not null THEN

      l_find_alias :=
                check_alias_with_layout
		(p_layout_alias_ref_name	=> l_alias_ref,
		 p_layout_att_cat		=> l_att_cat,
		 p_resource_id			=> p_resource_id,
		 p_layout_id			=> l_layout_id,
		 p_alias_label			=> l_alias_label,
		 p_alias_definition_id		=> to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE20),
		 p_pref_start_date		=> l_pref_table(l_alternate_name_index).START_DATE,
		 p_pref_end_date		=> l_pref_table(l_alternate_name_index).END_DATE);


   END IF;
   IF l_pref_table(l_alternate_name_index).ATTRIBUTE21 is not null THEN

      l_find_alias :=
                check_alias_with_layout
		(p_layout_alias_ref_name	=> l_alias_ref,
		 p_layout_att_cat		=> l_att_cat,
		 p_resource_id			=> p_resource_id,
		 p_layout_id			=> l_layout_id,
		 p_alias_label			=> l_alias_label,
		 p_alias_definition_id		=> to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE21),
		 p_pref_start_date		=> l_pref_table(l_alternate_name_index).START_DATE,
		 p_pref_end_date		=> l_pref_table(l_alternate_name_index).END_DATE);


   END IF;
   IF l_pref_table(l_alternate_name_index).ATTRIBUTE22 is not null THEN

      l_find_alias :=
                check_alias_with_layout
		(p_layout_alias_ref_name	=> l_alias_ref,
		 p_layout_att_cat		=> l_att_cat,
		 p_resource_id			=> p_resource_id,
		 p_layout_id			=> l_layout_id,
		 p_alias_label			=> l_alias_label,
		 p_alias_definition_id		=> to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE22),
		 p_pref_start_date		=> l_pref_table(l_alternate_name_index).START_DATE,
		 p_pref_end_date		=> l_pref_table(l_alternate_name_index).END_DATE);


   END IF;
   IF l_pref_table(l_alternate_name_index).ATTRIBUTE23 is not null THEN

      l_find_alias :=
                check_alias_with_layout
		(p_layout_alias_ref_name	=> l_alias_ref,
		 p_layout_att_cat		=> l_att_cat,
		 p_resource_id			=> p_resource_id,
		 p_layout_id			=> l_layout_id,
		 p_alias_label			=> l_alias_label,
		 p_alias_definition_id		=> to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE23),
		 p_pref_start_date		=> l_pref_table(l_alternate_name_index).START_DATE,
		 p_pref_end_date		=> l_pref_table(l_alternate_name_index).END_DATE);


   END IF;
   IF l_pref_table(l_alternate_name_index).ATTRIBUTE24 is not null THEN

      l_find_alias :=
                check_alias_with_layout
		(p_layout_alias_ref_name	=> l_alias_ref,
		 p_layout_att_cat		=> l_att_cat,
		 p_resource_id			=> p_resource_id,
		 p_layout_id			=> l_layout_id,
		 p_alias_label			=> l_alias_label,
		 p_alias_definition_id		=> to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE24),
		 p_pref_start_date		=> l_pref_table(l_alternate_name_index).START_DATE,
		 p_pref_end_date		=> l_pref_table(l_alternate_name_index).END_DATE);


   END IF;
   IF l_pref_table(l_alternate_name_index).ATTRIBUTE25 is not null THEN

      l_find_alias :=
                check_alias_with_layout
		(p_layout_alias_ref_name	=> l_alias_ref,
		 p_layout_att_cat		=> l_att_cat,
		 p_resource_id			=> p_resource_id,
		 p_layout_id			=> l_layout_id,
		 p_alias_label			=> l_alias_label,
		 p_alias_definition_id		=> to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE25),
		 p_pref_start_date		=> l_pref_table(l_alternate_name_index).START_DATE,
		 p_pref_end_date		=> l_pref_table(l_alternate_name_index).END_DATE);


   END IF;

   IF l_pref_table(l_alternate_name_index).ATTRIBUTE26 is not null THEN

      l_find_alias :=
                check_alias_with_layout
		(p_layout_alias_ref_name	=> l_alias_ref,
		 p_layout_att_cat		=> l_att_cat,
		 p_resource_id			=> p_resource_id,
		 p_layout_id			=> l_layout_id,
		 p_alias_label			=> l_alias_label,
		 p_alias_definition_id		=> to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE26),
		 p_pref_start_date		=> l_pref_table(l_alternate_name_index).START_DATE,
		 p_pref_end_date		=> l_pref_table(l_alternate_name_index).END_DATE);


   END IF;
   IF l_pref_table(l_alternate_name_index).ATTRIBUTE27 is not null THEN

      l_find_alias :=
                check_alias_with_layout
		(p_layout_alias_ref_name	=> l_alias_ref,
		 p_layout_att_cat		=> l_att_cat,
		 p_resource_id			=> p_resource_id,
		 p_layout_id			=> l_layout_id,
		 p_alias_label			=> l_alias_label,
		 p_alias_definition_id		=> to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE27),
		 p_pref_start_date		=> l_pref_table(l_alternate_name_index).START_DATE,
		 p_pref_end_date		=> l_pref_table(l_alternate_name_index).END_DATE);


   END IF;
   IF l_pref_table(l_alternate_name_index).ATTRIBUTE28 is not null THEN

      l_find_alias :=
                check_alias_with_layout
		(p_layout_alias_ref_name	=> l_alias_ref,
		 p_layout_att_cat		=> l_att_cat,
		 p_resource_id			=> p_resource_id,
		 p_layout_id			=> l_layout_id,
		 p_alias_label			=> l_alias_label,
		 p_alias_definition_id		=> to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE28),
		 p_pref_start_date		=> l_pref_table(l_alternate_name_index).START_DATE,
		 p_pref_end_date		=> l_pref_table(l_alternate_name_index).END_DATE);


   END IF;
   IF l_pref_table(l_alternate_name_index).ATTRIBUTE29 is not null THEN

      l_find_alias :=
                check_alias_with_layout
		(p_layout_alias_ref_name	=> l_alias_ref,
		 p_layout_att_cat		=> l_att_cat,
		 p_resource_id			=> p_resource_id,
		 p_layout_id			=> l_layout_id,
		 p_alias_label			=> l_alias_label,
		 p_alias_definition_id		=> to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE29),
		 p_pref_start_date		=> l_pref_table(l_alternate_name_index).START_DATE,
		 p_pref_end_date		=> l_pref_table(l_alternate_name_index).END_DATE);


   END IF;
   IF l_pref_table(l_alternate_name_index).ATTRIBUTE30 is not null THEN

      l_find_alias :=
                check_alias_with_layout
		(p_layout_alias_ref_name	=> l_alias_ref,
		 p_layout_att_cat		=> l_att_cat,
		 p_resource_id			=> p_resource_id,
		 p_layout_id			=> l_layout_id,
		 p_alias_label			=> l_alias_label,
		 p_alias_definition_id		=> to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE30),
		 p_pref_start_date		=> l_pref_table(l_alternate_name_index).START_DATE,
		 p_pref_end_date		=> l_pref_table(l_alternate_name_index).END_DATE);


   END IF;


  END LOOP;
 END IF;

 l_pref_index := l_pref_table.next(l_pref_index);

END LOOP;

--hr_utility.trace_on('','JOEL');
--hr_utility.trace(' l_timecard_layout_id '||l_timecard_layout_id);

-- add an extra check at the end of the procedure
-- to make sure the g_comp_label is not null
IF (p_cache_label and g_comp_label.count = 0)  THEN

--hr_utility.trace(' inside loop ');

  FOR layout_comp IN csr_lay_alias_comp(l_timecard_layout_id) LOOP

   --l_layout_comp_id 	:= layout_comp.layout_component_id;
   l_att_cat 		:= layout_comp.QUALIFIER_ATTRIBUTE26;
   l_alias_ref  	:= layout_comp.QUALIFIER_ATTRIBUTE24;
   l_alias_label	:= layout_comp.label;

   --IF (l_att_cat is not null) THEN

   l_comp_index := nvl(g_comp_label.last,0) + 1;

   IF l_att_cat is null and layout_comp.QUALIFIER_ATTRIBUTE27 is null THEN
     null;
   ELSE
     g_comp_label(l_comp_index).MAPPING_ATT_CAT	      := l_att_cat;
     g_comp_label(l_comp_index).SEGMENT		      := layout_comp.QUALIFIER_ATTRIBUTE27;
     g_comp_label(l_comp_index).ATTRIBUTE1	      := l_alias_label;
   END IF;

   --END IF;

  END LOOP;
END IF;

--hr_utility.trace_off;

-- associate the global table to the out parameters
p_alias_def_item := g_alias_def_item;

END get_alias_def_item;

-- ----------------------------------------------------------------------------
-- |------------------------< get_alias_def_item for TK      >--------------------|
-- ----------------------------------------------------------------------------
-- |  This procedure returns by looking on the preference of the timekeeper    |
-- |  a pl/sql table that contains the alias attribute information	       |
--------------------------------------------------------------------------------
PROCEDURE get_alias_def_item
(p_timekeeper_id 		in 	NUMBER
,p_alias_def_item		IN OUT NOCOPY 	t_alias_def_item) IS

l_index		NUMBER;
l_index_global	NUMBER;

l_pref_table    hxc_preference_evaluation.t_pref_table;


BEGIN

-- look if we have already the information of the timekeeper into
-- the global table
-- looking the first row is enought. This table handle only
-- the information for one timekeeper therefore if the timekeeper_id
-- in the table is different with the parameter we are deleting the
-- table info.

l_index_global := g_alias_def_item.first;

IF g_alias_def_item.exists(l_index_global) THEN

   IF g_alias_def_item(l_index_global).RESOURCE_ID = p_timekeeper_id THEN
      --
      p_alias_def_item := g_alias_def_item;
      return;
   ELSE
      --
      g_alias_def_item.delete;
   END IF;

END IF;

-- otherwise we need to do the calculation
-- first we need to find the preference for the timekeeper
hxc_preference_evaluation.resource_preferences(p_resource_id 	 => p_timekeeper_id,
                                               p_pref_table 	 => l_pref_table,
                                               p_evaluation_date => sysdate );

--
l_index_global := 0;

-- look now into the pref table the information that we need to.
l_index := l_pref_table.first;

  LOOP
   EXIT WHEN
   (NOT l_pref_table.exists(l_index));

    IF (l_pref_table(l_index).preference_code = 'TK_TCARD_ATTRIBUTES_DEFINITION') THEN

      IF l_pref_table(l_index).ATTRIBUTE1 is not null THEN

        l_index_global := l_index_global + 1;
        g_alias_def_item(l_index_global).ALIAS_DEFINITION_ID     := l_pref_table(l_index).ATTRIBUTE1;
        g_alias_def_item(l_index_global).ITEM_ATTRIBUTE_CATEGORY := 'OTL_ALIAS_ITEM_1';
        g_alias_def_item(l_index_global).RESOURCE_ID	   	 := p_timekeeper_id;
        g_alias_def_item(l_index_global).PREF_START_DATE	 := HR_GENERAL.START_OF_TIME;
        g_alias_def_item(l_index_global).PREF_END_DATE	   	 := HR_GENERAL.END_OF_TIME;



      END IF;

      IF l_pref_table(l_index).ATTRIBUTE2 is not null THEN

        l_index_global := l_index_global + 1;
        g_alias_def_item(l_index_global).ALIAS_DEFINITION_ID     := l_pref_table(l_index).ATTRIBUTE2;
        g_alias_def_item(l_index_global).ITEM_ATTRIBUTE_CATEGORY := 'OTL_ALIAS_ITEM_2';
        g_alias_def_item(l_index_global).RESOURCE_ID	   	 := p_timekeeper_id;
        g_alias_def_item(l_index_global).PREF_START_DATE	 := HR_GENERAL.START_OF_TIME;
        g_alias_def_item(l_index_global).PREF_END_DATE	   	 := HR_GENERAL.END_OF_TIME;

      END IF;

      IF l_pref_table(l_index).ATTRIBUTE3 is not null THEN

        l_index_global := l_index_global + 1;
        g_alias_def_item(l_index_global).ALIAS_DEFINITION_ID     := l_pref_table(l_index).ATTRIBUTE3;
        g_alias_def_item(l_index_global).ITEM_ATTRIBUTE_CATEGORY := 'OTL_ALIAS_ITEM_3';
        g_alias_def_item(l_index_global).RESOURCE_ID	   	 := p_timekeeper_id;
        g_alias_def_item(l_index_global).PREF_START_DATE	 := HR_GENERAL.START_OF_TIME;
        g_alias_def_item(l_index_global).PREF_END_DATE	   	 := HR_GENERAL.END_OF_TIME;

      END IF;

      IF l_pref_table(l_index).ATTRIBUTE4 is not null THEN

        l_index_global := l_index_global + 1;
        g_alias_def_item(l_index_global).ALIAS_DEFINITION_ID     := l_pref_table(l_index).ATTRIBUTE4;
        g_alias_def_item(l_index_global).ITEM_ATTRIBUTE_CATEGORY := 'OTL_ALIAS_ITEM_4';
        g_alias_def_item(l_index_global).RESOURCE_ID	   	 := p_timekeeper_id;
        g_alias_def_item(l_index_global).PREF_START_DATE	 := HR_GENERAL.START_OF_TIME;
        g_alias_def_item(l_index_global).PREF_END_DATE	   	 := HR_GENERAL.END_OF_TIME;

      END IF;

      IF l_pref_table(l_index).ATTRIBUTE5 is not null THEN

        l_index_global := l_index_global + 1;
        g_alias_def_item(l_index_global).ALIAS_DEFINITION_ID     := l_pref_table(l_index).ATTRIBUTE5;
        g_alias_def_item(l_index_global).ITEM_ATTRIBUTE_CATEGORY := 'OTL_ALIAS_ITEM_5';
        g_alias_def_item(l_index_global).RESOURCE_ID	   	 := p_timekeeper_id;
        g_alias_def_item(l_index_global).PREF_START_DATE	 := HR_GENERAL.START_OF_TIME;
        g_alias_def_item(l_index_global).PREF_END_DATE	   	 := HR_GENERAL.END_OF_TIME;

      END IF;

      IF l_pref_table(l_index).ATTRIBUTE6 is not null THEN

        l_index_global := l_index_global + 1;
        g_alias_def_item(l_index_global).ALIAS_DEFINITION_ID     := l_pref_table(l_index).ATTRIBUTE6;
        g_alias_def_item(l_index_global).ITEM_ATTRIBUTE_CATEGORY := 'OTL_ALIAS_ITEM_6';
        g_alias_def_item(l_index_global).RESOURCE_ID	   	 := p_timekeeper_id;
        g_alias_def_item(l_index_global).PREF_START_DATE	 := HR_GENERAL.START_OF_TIME;
        g_alias_def_item(l_index_global).PREF_END_DATE	   	 := HR_GENERAL.END_OF_TIME;

      END IF;

      IF l_pref_table(l_index).ATTRIBUTE7 is not null THEN

        l_index_global := l_index_global + 1;
        g_alias_def_item(l_index_global).ALIAS_DEFINITION_ID     := l_pref_table(l_index).ATTRIBUTE7;
        g_alias_def_item(l_index_global).ITEM_ATTRIBUTE_CATEGORY := 'OTL_ALIAS_ITEM_7';
        g_alias_def_item(l_index_global).RESOURCE_ID	   	 := p_timekeeper_id;
        g_alias_def_item(l_index_global).PREF_START_DATE	 := HR_GENERAL.START_OF_TIME;
        g_alias_def_item(l_index_global).PREF_END_DATE	   	 := HR_GENERAL.END_OF_TIME;

      END IF;

      IF l_pref_table(l_index).ATTRIBUTE8 is not null THEN

        l_index_global := l_index_global + 1;
        g_alias_def_item(l_index_global).ALIAS_DEFINITION_ID     := l_pref_table(l_index).ATTRIBUTE8;
        g_alias_def_item(l_index_global).ITEM_ATTRIBUTE_CATEGORY := 'OTL_ALIAS_ITEM_8';
        g_alias_def_item(l_index_global).RESOURCE_ID	   	 := p_timekeeper_id;
        g_alias_def_item(l_index_global).PREF_START_DATE	 := HR_GENERAL.START_OF_TIME;
        g_alias_def_item(l_index_global).PREF_END_DATE	   	 := HR_GENERAL.END_OF_TIME;

      END IF;

      IF l_pref_table(l_index).ATTRIBUTE9 is not null THEN

        l_index_global := l_index_global + 1;
        g_alias_def_item(l_index_global).ALIAS_DEFINITION_ID     := l_pref_table(l_index).ATTRIBUTE9;
        g_alias_def_item(l_index_global).ITEM_ATTRIBUTE_CATEGORY := 'OTL_ALIAS_ITEM_9';
        g_alias_def_item(l_index_global).RESOURCE_ID	   	 := p_timekeeper_id;
        g_alias_def_item(l_index_global).PREF_START_DATE	 := HR_GENERAL.START_OF_TIME;
        g_alias_def_item(l_index_global).PREF_END_DATE	   	 := HR_GENERAL.END_OF_TIME;

      END IF;

      IF l_pref_table(l_index).ATTRIBUTE10 is not null THEN

        l_index_global := l_index_global + 1;
        g_alias_def_item(l_index_global).ALIAS_DEFINITION_ID     := l_pref_table(l_index).ATTRIBUTE10;
        g_alias_def_item(l_index_global).ITEM_ATTRIBUTE_CATEGORY := 'OTL_ALIAS_ITEM_10';
        g_alias_def_item(l_index_global).RESOURCE_ID	   	 := p_timekeeper_id;
        g_alias_def_item(l_index_global).PREF_START_DATE	 := HR_GENERAL.START_OF_TIME;
        g_alias_def_item(l_index_global).PREF_END_DATE	   	 := HR_GENERAL.END_OF_TIME;

      END IF;

      IF l_pref_table(l_index).ATTRIBUTE11 is not null THEN

        l_index_global := l_index_global + 1;
        g_alias_def_item(l_index_global).ALIAS_DEFINITION_ID     := l_pref_table(l_index).ATTRIBUTE11;
        g_alias_def_item(l_index_global).ITEM_ATTRIBUTE_CATEGORY := 'OTL_ALIAS_ITEM_11';
        g_alias_def_item(l_index_global).RESOURCE_ID	   	 := p_timekeeper_id;
        g_alias_def_item(l_index_global).PREF_START_DATE	 := HR_GENERAL.START_OF_TIME;
        g_alias_def_item(l_index_global).PREF_END_DATE	   	 := HR_GENERAL.END_OF_TIME;

      END IF;

      IF l_pref_table(l_index).ATTRIBUTE12 is not null THEN

        l_index_global := l_index_global + 1;
        g_alias_def_item(l_index_global).ALIAS_DEFINITION_ID     := l_pref_table(l_index).ATTRIBUTE12;
        g_alias_def_item(l_index_global).ITEM_ATTRIBUTE_CATEGORY := 'OTL_ALIAS_ITEM_12';
        g_alias_def_item(l_index_global).RESOURCE_ID	   	 := p_timekeeper_id;
        g_alias_def_item(l_index_global).PREF_START_DATE	 := HR_GENERAL.START_OF_TIME;
        g_alias_def_item(l_index_global).PREF_END_DATE	   	 := HR_GENERAL.END_OF_TIME;

      END IF;

      IF l_pref_table(l_index).ATTRIBUTE13 is not null THEN

        l_index_global := l_index_global + 1;
        g_alias_def_item(l_index_global).ALIAS_DEFINITION_ID     := l_pref_table(l_index).ATTRIBUTE13;
        g_alias_def_item(l_index_global).ITEM_ATTRIBUTE_CATEGORY := 'OTL_ALIAS_ITEM_13';
        g_alias_def_item(l_index_global).RESOURCE_ID	   	 := p_timekeeper_id;
        g_alias_def_item(l_index_global).PREF_START_DATE	 := HR_GENERAL.START_OF_TIME;
        g_alias_def_item(l_index_global).PREF_END_DATE	   	 := HR_GENERAL.END_OF_TIME;

      END IF;

      IF l_pref_table(l_index).ATTRIBUTE14 is not null THEN

        l_index_global := l_index_global + 1;
        g_alias_def_item(l_index_global).ALIAS_DEFINITION_ID     := l_pref_table(l_index).ATTRIBUTE14;
        g_alias_def_item(l_index_global).ITEM_ATTRIBUTE_CATEGORY := 'OTL_ALIAS_ITEM_14';
        g_alias_def_item(l_index_global).RESOURCE_ID	   	 := p_timekeeper_id;
        g_alias_def_item(l_index_global).PREF_START_DATE	 := HR_GENERAL.START_OF_TIME;
        g_alias_def_item(l_index_global).PREF_END_DATE	   	 := HR_GENERAL.END_OF_TIME;

      END IF;

      IF l_pref_table(l_index).ATTRIBUTE15 is not null THEN

        l_index_global := l_index_global + 1;
        g_alias_def_item(l_index_global).ALIAS_DEFINITION_ID     := l_pref_table(l_index).ATTRIBUTE15;
        g_alias_def_item(l_index_global).ITEM_ATTRIBUTE_CATEGORY := 'OTL_ALIAS_ITEM_15';
        g_alias_def_item(l_index_global).RESOURCE_ID	   	 := p_timekeeper_id;
        g_alias_def_item(l_index_global).PREF_START_DATE	 := HR_GENERAL.START_OF_TIME;
        g_alias_def_item(l_index_global).PREF_END_DATE	   	 := HR_GENERAL.END_OF_TIME;

      END IF;

      IF l_pref_table(l_index).ATTRIBUTE16 is not null THEN

        l_index_global := l_index_global + 1;
        g_alias_def_item(l_index_global).ALIAS_DEFINITION_ID     := l_pref_table(l_index).ATTRIBUTE16;
        g_alias_def_item(l_index_global).ITEM_ATTRIBUTE_CATEGORY := 'OTL_ALIAS_ITEM_16';
        g_alias_def_item(l_index_global).RESOURCE_ID	   	 := p_timekeeper_id;
        g_alias_def_item(l_index_global).PREF_START_DATE	 := HR_GENERAL.START_OF_TIME;
        g_alias_def_item(l_index_global).PREF_END_DATE	   	 := HR_GENERAL.END_OF_TIME;

      END IF;

      IF l_pref_table(l_index).ATTRIBUTE17 is not null THEN

        l_index_global := l_index_global + 1;
        g_alias_def_item(l_index_global).ALIAS_DEFINITION_ID     := l_pref_table(l_index).ATTRIBUTE17;
        g_alias_def_item(l_index_global).ITEM_ATTRIBUTE_CATEGORY := 'OTL_ALIAS_ITEM_17';
        g_alias_def_item(l_index_global).RESOURCE_ID	   	 := p_timekeeper_id;
        g_alias_def_item(l_index_global).PREF_START_DATE	 := HR_GENERAL.START_OF_TIME;
        g_alias_def_item(l_index_global).PREF_END_DATE	   	 := HR_GENERAL.END_OF_TIME;

      END IF;

      IF l_pref_table(l_index).ATTRIBUTE18 is not null THEN

        l_index_global := l_index_global + 1;
        g_alias_def_item(l_index_global).ALIAS_DEFINITION_ID     := l_pref_table(l_index).ATTRIBUTE18;
        g_alias_def_item(l_index_global).ITEM_ATTRIBUTE_CATEGORY := 'OTL_ALIAS_ITEM_18';
        g_alias_def_item(l_index_global).RESOURCE_ID	   	 := p_timekeeper_id;
        g_alias_def_item(l_index_global).PREF_START_DATE	 := HR_GENERAL.START_OF_TIME;
        g_alias_def_item(l_index_global).PREF_END_DATE	   	 := HR_GENERAL.END_OF_TIME;

      END IF;

      IF l_pref_table(l_index).ATTRIBUTE19 is not null THEN

        l_index_global := l_index_global + 1;
        g_alias_def_item(l_index_global).ALIAS_DEFINITION_ID     := l_pref_table(l_index).ATTRIBUTE19;
        g_alias_def_item(l_index_global).ITEM_ATTRIBUTE_CATEGORY := 'OTL_ALIAS_ITEM_19';
        g_alias_def_item(l_index_global).RESOURCE_ID	   	 := p_timekeeper_id;
        g_alias_def_item(l_index_global).PREF_START_DATE	 := HR_GENERAL.START_OF_TIME;
        g_alias_def_item(l_index_global).PREF_END_DATE	   	 := HR_GENERAL.END_OF_TIME;

      END IF;

      IF l_pref_table(l_index).ATTRIBUTE20 is not null THEN

        l_index_global := l_index_global + 1;
        g_alias_def_item(l_index_global).ALIAS_DEFINITION_ID     := l_pref_table(l_index).ATTRIBUTE20;
        g_alias_def_item(l_index_global).ITEM_ATTRIBUTE_CATEGORY := 'OTL_ALIAS_ITEM_20';
        g_alias_def_item(l_index_global).RESOURCE_ID	   	 := p_timekeeper_id;
        g_alias_def_item(l_index_global).PREF_START_DATE	 := HR_GENERAL.START_OF_TIME;
        g_alias_def_item(l_index_global).PREF_END_DATE	   	 := HR_GENERAL.END_OF_TIME;

      END IF;
     END IF;

    l_index := l_pref_table.next(l_index);
END LOOP;

-- associate the global table to the out parameters
p_alias_def_item := g_alias_def_item;


END get_alias_def_item;



-- ----------------------------------------------------------------------------
-- |------------------------< get_alias_definition_info   >--------------------|
-- ----------------------------------------------------------------------------
-- | This procedure returns the alias_type, reference_object, prompt for a     |
-- | specific alias_definition_id					       |
-- ----------------------------------------------------------------------------
PROCEDURE get_alias_definition_info
 (p_alias_definition_id 	in  number,
  p_alias_type 		 out nocopy varchar2,
  p_reference_object	 out nocopy varchar2,
  p_prompt		 out nocopy varchar2)
 IS

--
-- Cursor to find the type
--
cursor c_alias_type is
select alias_type,reference_object,prompt
from hxc_alias_types hat
   , hxc_alias_definitions_tl hadtl
   , hxc_alias_definitions had
where hat.alias_type_id = had.alias_type_id
and   had.alias_definition_id = p_alias_definition_id
and   hadtl.language = userenv('LANG')
and   hadtl.alias_definition_id = p_alias_definition_id;

l_alias_type		hxc_alias_types.alias_type%TYPE;
l_reference_object	hxc_alias_types.reference_object%TYPE;

BEGIN

-- first look in the global table that we don't have the information
IF g_alias_definition_info.exists(p_alias_definition_id) THEN
  p_alias_type 		:= g_alias_definition_info(p_alias_definition_id).alias_type;
  p_reference_object 	:= g_alias_definition_info(p_alias_definition_id).reference_object;
  p_prompt		:= g_alias_definition_info(p_alias_definition_id).prompt;
ELSE

  -- open the cursor
  open  c_alias_type;
  Fetch c_alias_type Into p_alias_type,p_reference_object,p_prompt;
  close c_alias_type;

  -- record the information in the global table
  g_alias_definition_info(p_alias_definition_id).alias_type := p_alias_type;
  g_alias_definition_info(p_alias_definition_id).reference_object := p_reference_object;
  g_alias_definition_info(p_alias_definition_id).prompt := p_prompt;

END IF;

END get_alias_definition_info;

-- ----------------------------------------------------------------------------
-- |------------------------< get_alias_definition_info   >--------------------|
-- ----------------------------------------------------------------------------
-- | This function returns the alias_definition_id attached to an value id     |
-- ----------------------------------------------------------------------------

FUNCTION get_alias_def_from_value
 (p_alias_value_id 	in  number)
 RETURN NUMBER
 IS

l_alias_definition_id 	NUMBER := NULL;

BEGIN

   begin
     select 	alias_definition_id
     into	l_alias_definition_id
     from 	hxc_alias_values
     where	alias_value_id = p_alias_value_id;
   EXCEPTION
    WHEN OTHERS
       THEN
          return l_alias_definition_id;
   END;

RETURN 	l_alias_definition_id;

END get_alias_def_from_value;


-- ----------------------------------------------------------------------------
-- |------------------------< make_stmt		          >--------------------|
-- ----------------------------------------------------------------------------
-- | This procedure returns the select statement for a specific value set id   |
-- ----------------------------------------------------------------------------
FUNCTION make_stmt (p_vset_id 		in number,
		    p_alias_type	in varchar2)
	return varchar2 is

c	number;
l_stmt 	varchar2(2000);
l_where varchar2(2000) := null;

BEGIN

IF p_alias_type = 'VALUE_SET_TABLE' THEN

    select 'select to_char('||value_column_name||') display_value, '||
           replace(id_column_name, ',',  ' || ''ALIAS_SEPARATOR'' || ')||' id_value '||
    	 ' from '||application_table_name
    into l_stmt
    from   fnd_flex_validation_tables t
    where  t.flex_value_set_id = p_vset_id;

    select additional_where_clause
    into   l_where
    from   fnd_flex_validation_tables t
    where  t.flex_value_set_id = p_vset_id;

    if l_where is not null then
     l_stmt := l_stmt ||' '||l_where;
    end if;

ELSIF p_alias_type = 'VALUE_SET_INDEPENDENT' THEN

    l_stmt := 'select flex_value_meaning display_value, '||
         '  flex_value_id  id_value  '||
    	 ' from fnd_flex_values_vl t'||
         ' where t.flex_value_set_id = '||p_vset_id||
         ' and t.enabled_flag=''Y''' ||
	 ' and nvl(t.start_date_active,hr_general.start_of_time) <= fnd_profile.value(''OTL_TK_END_DATE'') '||
	 ' and nvl(t.end_date_active,hr_general.end_of_time) >= fnd_profile.value(''OTL_TK_START_DATE'') ';


END IF;
    -- test the SQL
    c := dbms_sql.open_cursor ;
--##MS trap any exceptions raised here so that we can close the cursor before
--     raising the error
    BEGIN
       dbms_sql.parse(c , l_stmt , dbms_sql.native) ;
    EXCEPTION
      WHEN OTHERS THEN
        dbms_sql.close_cursor(c);
        RAISE;
    END;

--##MS close cursor if the parse raised no exceptions
    dbms_sql.close_cursor(c);

    return (l_stmt);

 exception
 when others then
   fnd_message.set_name('HXC', 'HXC_------INVALID_SQL_STATMENT');
   fnd_message.raise_error;
 return ( null );

END make_stmt;



-- ----------------------------------------------------------------------------
-- |------------------------< replace_profile		  >--------------------|
-- ----------------------------------------------------------------------------
-- | This procedure replace the TK profile into the select statement	       |
-- | with the value of the TK form items				       |
-- ----------------------------------------------------------------------------
FUNCTION replace_profile
 (x_select 			IN	VARCHAR2,
  p_block_name			IN	VARCHAR2)
 RETURN VARCHAR2
    IS

l_x_select	VARCHAR2(2000);

BEGIN

l_x_select:=x_select;

select replace (upper(l_x_select),'FND_PROFILE.VALUE(''OTL_TK_ATTR_1'')', ':'||p_block_name||'ATTR_ID_1')
into l_x_select
from dual;

select replace (upper(l_x_select),'FND_PROFILE.VALUE(''OTL_TK_ATTR_2'')', ':'||p_block_name||'ATTR_ID_2')
into l_x_select
from dual;

select replace (upper(l_x_select),'FND_PROFILE.VALUE(''OTL_TK_ATTR_3'')', ':'||p_block_name||'ATTR_ID_3')
into l_x_select
from dual;

select replace (upper(l_x_select),'FND_PROFILE.VALUE(''OTL_TK_ATTR_4'')', ':'||p_block_name||'ATTR_ID_4')
into l_x_select
from dual;

select replace (upper(l_x_select),'FND_PROFILE.VALUE(''OTL_TK_ATTR_5'')', ':'||p_block_name||'ATTR_ID_5')
into l_x_select
from dual;

select replace (upper(l_x_select),'FND_PROFILE.VALUE(''OTL_TK_ATTR_6'')', ':'||p_block_name||'ATTR_ID_6')
into l_x_select
from dual;

select replace (upper(l_x_select),'FND_PROFILE.VALUE(''OTL_TK_ATTR_7'')', ':'||p_block_name||'ATTR_ID_7')
into l_x_select
from dual;

select replace (upper(l_x_select),'FND_PROFILE.VALUE(''OTL_TK_ATTR_8'')', ':'||p_block_name||'ATTR_ID_8')
into l_x_select
from dual;

select replace (upper(l_x_select),'FND_PROFILE.VALUE(''OTL_TK_ATTR_9'')', ':'||p_block_name||'ATTR_ID_9')
into l_x_select
from dual;

select replace (upper(l_x_select),'FND_PROFILE.VALUE(''OTL_TK_ATTR_10'')', ':'||p_block_name||'ATTR_ID_10')
into l_x_select
from dual;

select replace (upper(l_x_select),'FND_PROFILE.VALUE(''OTL_TK_ATTR_11'')', ':'||p_block_name||'ATTR_ID_11')
into l_x_select
from dual;

select replace (upper(l_x_select),'FND_PROFILE.VALUE(''OTL_TK_ATTR_12'')', ':'||p_block_name||'ATTR_ID_12')
into l_x_select
from dual;

select replace (upper(l_x_select),'FND_PROFILE.VALUE(''OTL_TK_ATTR_13'')', ':'||p_block_name||'ATTR_ID_13')
into l_x_select
from dual;

select replace (upper(l_x_select),'FND_PROFILE.VALUE(''OTL_TK_ATTR_14'')', ':'||p_block_name||'ATTR_ID_14')
into l_x_select
from dual;

select replace (upper(l_x_select),'FND_PROFILE.VALUE(''OTL_TK_ATTR_15'')', ':'||p_block_name||'ATTR_ID_15')
into l_x_select
from dual;

select replace (upper(l_x_select),'FND_PROFILE.VALUE(''OTL_TK_ATTR_16'')', ':'||p_block_name||'ATTR_ID_16')
into l_x_select
from dual;

select replace (upper(l_x_select),'FND_PROFILE.VALUE(''OTL_TK_ATTR_17'')', ':'||p_block_name||'ATTR_ID_17')
into l_x_select
from dual;

select replace (upper(l_x_select),'FND_PROFILE.VALUE(''OTL_TK_ATTR_18'')', ':'||p_block_name||'ATTR_ID_18')
into l_x_select
from dual;

select replace (upper(l_x_select),'FND_PROFILE.VALUE(''OTL_TK_ATTR_19'')', ':'||p_block_name||'ATTR_ID_19')
into l_x_select
from dual;

select replace (upper(l_x_select),'FND_PROFILE.VALUE(''OTL_TK_ATTR_20'')', ':'||p_block_name||'ATTR_ID_20')
into l_x_select
from dual;

select replace (upper(l_x_select),'FND_PROFILE.VALUE(''OTL_TK_RESOURCE_ID'')', ':'||'TIMECARD_INFO.'||'RESOURCE_ID')
into l_x_select
from dual;

select replace (upper(l_x_select),'FND_PROFILE.VALUE(''OTL_TK_TIMEKEEPER_ID'')', ':'||'HXCTKSTA.TIMEKEEPER_ID')
into l_x_select
from dual;

select replace (upper(l_x_select),'FND_PROFILE.VALUE(''OTL_TK_START_DATE'')', ':'||'HXCTKSTA.'||'FRDT')
into l_x_select
from dual;

select replace (upper(l_x_select),'FND_PROFILE.VALUE(''OTL_TK_END_DATE'')', ':'||'HXCTKSTA.'||'TODT')
into l_x_select
from dual;


return l_x_select;


end replace_profile;

-----------------------------------------------------------------
--  get_vset_id_col_type
-----------------------------------------------------------------
FUNCTION get_vset_id_col_type (p_vset_id 	in number)
	return varchar2 is

l_id_col_type 		VARCHAR2(1);
l_id_col_type_return	VARCHAR2(80) := 'CHAR';
l_to_char_in_col_id	NUMBER := 0;

BEGIN

select id_column_type,instr(id_column_name,'to_char')
into l_id_col_type, l_to_char_in_col_id
from   fnd_flex_validation_tables t
where  t.flex_value_set_id = p_vset_id;

-- if the type is a NUMBER
IF l_id_col_type = 'N' THEN
   -- if there is not a to_char in the column_name
   IF l_to_char_in_col_id = 0 THEN
     l_id_col_type_return := 'NUMBER';
   END IF;

END IF;

return l_id_col_type_return;

exception
when others then
   fnd_message.set_name('HXC', 'HXC_------INVALID_ID_COL_TYPE');
   fnd_message.raise_error;
return ( null );


END get_vset_id_col_type;



-- ----------------------------------------------------------------------------
-- |------------------------< get_vset_table_type_select  >--------------------|
-- ----------------------------------------------------------------------------
-- | This procedure returns the select statement for a specific value table    |
-- | set id   								       |
-- ----------------------------------------------------------------------------
PROCEDURE get_vset_table_type_select
 (p_alias_definition_id		IN	NUMBER,
  x_select 		 OUT NOCOPY VARCHAR2,
  p_id_type		 OUT NOCOPY VARCHAR2) IS

l_alias_type 		hxc_alias_types.alias_type%TYPE;
l_reference_object	hxc_alias_types.reference_object%TYPE;
l_prompt		hxc_alias_definitions_tl.prompt%TYPE;

l_select		VARCHAR2(200);
l_success		NUMBER(15);

BEGIN
-- first we need to check if the type associated
-- to the alias_definition is 'VALUE_SET_TABLE'
get_alias_definition_info
  (p_alias_definition_id,
   l_alias_type,
   l_reference_object,
   l_prompt);


IF l_alias_type <> 'VALUE_SET_TABLE' THEN
    fnd_message.set_name('HXC', 'HXC_------_INVALID_ALIAS_TYPE');
    fnd_message.raise_error;
END IF;

-- call the FND package to get the SQL
if l_reference_object is not null THEN
  x_select  := make_stmt (l_reference_object,l_alias_type);
  p_id_type := get_vset_id_col_type(l_reference_object);
ELSE
 fnd_message.set_name('HXC', 'HXC_------_INVALID_REFERENCE_OBJECT');
 fnd_message.raise_error;
END IF;

-- before sending back the information we do the profile replacement
-- x_select := replace_profile(x_select,p_block_name);

END get_vset_table_type_select;

-- ----------------------------------------------------------------------------
-- |------------------------< get_vset_indep_type_select  >--------------------|
-- ----------------------------------------------------------------------------
-- | This procedure returns the select statement for a specific value 	       |
-- | independant set id   						       |
-- ----------------------------------------------------------------------------
PROCEDURE get_vset_indep_type_select
 (p_alias_definition_id		IN	NUMBER,
  x_select 		 OUT NOCOPY VARCHAR2) IS

l_alias_type 		hxc_alias_types.alias_type%TYPE;
l_reference_object	hxc_alias_types.reference_object%TYPE;
l_prompt		hxc_alias_definitions_tl.prompt%TYPE;

l_select		VARCHAR2(200);
l_success		NUMBER(15);

BEGIN
-- first we need to check if the type associated
-- to the alias_definition is 'VALUE_SET_TABLE'
get_alias_definition_info
  (p_alias_definition_id,
   l_alias_type,
   l_reference_object,
   l_prompt);


IF l_alias_type <> 'VALUE_SET_INDEPENDENT' THEN
    fnd_message.set_name('HXC', 'HXC_------_INVALID_ALIAS_TYPE');
    fnd_message.raise_error;
END IF;

-- call the FND package to get the SQL
if l_reference_object is not null THEN
  x_select := make_stmt (l_reference_object,l_alias_type);
ELSE
 fnd_message.set_name('HXC', 'HXC_------_INVALID_REFERENCE_OBJECT');
 fnd_message.raise_error;
END IF;

END get_vset_indep_type_select;


-- ----------------------------------------------------------------------------
-- |------------------------< get_vset_none_type_property >--------------------|
-- ----------------------------------------------------------------------------
-- | This procedure returns the select statement for a specific value 	       |
-- | none set id   							       |
-- ----------------------------------------------------------------------------
PROCEDURE get_vset_none_type_property
 (p_alias_definition_id		IN	NUMBER,
  p_format_type		 OUT NOCOPY VARCHAR2,
  p_maximum_size	 OUT NOCOPY NUMBER,
  p_minimum_value	 OUT NOCOPY 	NUMBER,
  p_maximum_value	 OUT NOCOPY NUMBER,
  p_number_precision	 OUT NOCOPY NUMBER
  ) IS


-- Bug 7488230
-- The cursor below used to pull out the properties
-- for Value Set None type reference objects.
-- There could have been two issues
--   1. Value Set with Date Validation, with a min value and max value
--       Ideally another cursor should handle it, but since we have not
--       been intending this yet, it could be dealt with later.  The changes
--       would include a second cursor and variables, and thus a redefined package
--       Think it should work even without the min/max values, because the
--       Timekeeper would anyway trim it off.
--       The below cursor would not return any error anyways.
--   2. Value Set with Number validation, but the session expects a different
--       format.  Here, the Min value could be something like 10.45.  The value
--       set table would always have it in canonical format, ie.10.45.
--       When you are in an Env with 10.000,00 format for number, rdbms expects
--       ',' in place of '.'.  Hence a conversion of canonical to number is put in.
--       The Decode to ensure that this would happen only for a Number type value set
--       If a date type value set, it would return NULL.

/*
cursor c_vset_none_info (p_value_set_id number) is
select format_type,maximum_size,minimum_value,maximum_value,number_precision
from fnd_flex_value_sets
where validation_type = 'N'
and flex_value_set_id = p_value_set_id;
*/

CURSOR c_vset_none_info (p_value_set_id number)
    IS
SELECT format_type,
       maximum_size,
      DECODE(format_type,'N',fnd_number.canonical_to_number(minimum_value),
              NULL),
      DECODE(format_type,'N',fnd_number.canonical_to_number(maximum_value),
              NULL),
       number_precision
  FROM fnd_flex_value_sets
 WHERE validation_type = 'N'
   AND flex_value_set_id = p_value_set_id;


l_alias_type 		hxc_alias_types.alias_type%TYPE;
l_reference_object	hxc_alias_types.reference_object%TYPE;
l_prompt		hxc_alias_definitions_tl.prompt%TYPE;

l_select		VARCHAR2(200);
l_success		NUMBER(15);

BEGIN
-- first we need to check if the type associated
-- to the alias_definition is 'VALUE_SET_TABLE'
get_alias_definition_info
  (p_alias_definition_id,
   l_alias_type,
   l_reference_object,
   l_prompt);


IF l_alias_type <> 'VALUE_SET_NONE' THEN
    fnd_message.set_name('HXC', 'HXC_------_INVALID_ALIAS_TYPE');
    fnd_message.raise_error;
END IF;

-- call the FND package to get the property
if l_reference_object is not null THEN
  OPEN c_vset_none_info (l_reference_object);
  FETCH c_vset_none_info
     into p_format_type,p_maximum_size,p_minimum_value,p_maximum_value,p_number_precision;
  CLOSE c_vset_none_info;
ELSE
 fnd_message.set_name('HXC', 'HXC_------_INVALID_REFERENCE_OBJECT');
 fnd_message.raise_error;
END IF;

END get_vset_none_type_property;


-- ----------------------------------------------------------------------------
-- |------------------------< get_otl_an_context_type_select >-----------------|
-- ----------------------------------------------------------------------------
-- | This procedure returns the select statement for a specific alias_defintion|
-- | which is based on OTL DFF context					       |
-- ----------------------------------------------------------------------------
PROCEDURE get_otl_an_context_type_select
 (p_alias_definition_id		IN	NUMBER,
  p_timekeeper_person_type	IN	VARCHAR2 DEFAULT NULL,
  x_select 		 OUT NOCOPY VARCHAR2) IS

l_alias_type 		hxc_alias_types.alias_type%TYPE;
l_reference_object	hxc_alias_types.reference_object%TYPE;
l_prompt		hxc_alias_definitions_tl.prompt%TYPE;

l_select		VARCHAR2(200);
l_success		NUMBER(15);

BEGIN
-- first we need to check if the type associated
-- to the alias_definition is 'VALUE_SET_TABLE'
get_alias_definition_info
  (p_alias_definition_id,
   l_alias_type,
   l_reference_object,
   l_prompt);



IF l_alias_type <> 'OTL_ALT_DDF' THEN
    fnd_message.set_name('HXC', 'HXC_------_INVALID_ALIAS_TYPE');
    fnd_message.raise_error;
END IF;

-- call the FND package to get the SQL
IF l_reference_object is not null THEN --and p_timekeeper_person_type <> 'CWK' THEN
  -- mutilple case here
  IF l_reference_object = 'ELEMENTS_EXPENDITURE_SLF' THEN

      x_select := 'select distinct(havtl.alias_value_name) display_value, havtl.alias_value_id id_value '||
		  'from hxc_alias_values_tl havtl,'||
		  'hxc_alias_values hav,'||
		  'hxc_alias_definitions had,'||
		  'pa_online_expenditure_types_v pa,'||
		  'PAY_ELEMENT_TYPES_F_TL  ELEMENTTL, '||
		  'PAY_ELEMENT_TYPES_F  ELEMENT, '||
		  'PAY_ELEMENT_CLASSIFICATIONS_TL CLASSIFICATIONTL, '||
		  'PAY_ELEMENT_CLASSIFICATIONS CLASSIFICATION, '||
		  'BEN_BENEFIT_CLASSIFICATIONS BENEFIT, '||
		  'PAY_ELEMENT_LINKS_F  LINK, '||
		  'PER_ALL_ASSIGNMENTS_F  ASGT, '||
		  'PER_PERIODS_OF_SERVICE  SERVICE_PERIOD '||
		  'where hav.alias_definition_id = had.alias_definition_id '||
		  'and havtl.alias_value_id = hav.alias_value_id '||
		  'and havtl.language = userenv(''LANG'') '||
		  'and hav.attribute2 = pa.expenditure_type '||
		  'and hav.attribute3 = pa.system_linkage_function '||
  		  'and hav.attribute1 = ELEMENT.element_type_id '||
  		  'and hav.enabled_flag=''Y'' '||
  		  'and ELEMENT.ELEMENT_TYPE_ID = ELEMENTTL.ELEMENT_TYPE_ID '||
  		  'AND ELEMENTTL.LANGUAGE = USERENV(''LANG'') '||
  		  'AND CLASSIFICATION.CLASSIFICATION_ID = CLASSIFICATIONTL.CLASSIFICATION_ID (+) '||
  		  'AND DECODE(CLASSIFICATIONTL.CLASSIFICATION_ID,NULL,''1'',CLASSIFICATIONTL.LANGUAGE) = '||
      		  'DECODE(CLASSIFICATIONTL.CLASSIFICATION_ID,NULL,''1'',USERENV(''LANG'')) '||
  		  'AND ASGT.BUSINESS_GROUP_ID = LINK.BUSINESS_GROUP_ID '||
  		  'AND  ELEMENT.ELEMENT_TYPE_ID = LINK.ELEMENT_TYPE_ID '||
  		  'AND ELEMENT.BENEFIT_CLASSIFICATION_ID = BENEFIT.BENEFIT_CLASSIFICATION_ID (+) '||
  		  'AND ELEMENT.CLASSIFICATION_ID = CLASSIFICATION.CLASSIFICATION_ID '||
  		  'AND SERVICE_PERIOD.PERIOD_OF_SERVICE_ID = ASGT.PERIOD_OF_SERVICE_ID '||
  		  'AND ELEMENT.INDIRECT_ONLY_FLAG = ''N'' '||
  		  'AND UPPER (ELEMENT.ELEMENT_NAME) <> ''VERTEX'' '||
  		  'AND not exists '||
      		  '(select 1 '||
         		  'from HR_ORGANIZATION_INFORMATION HOI, '||
              		  'PAY_LEGISLATION_RULES PLR '||
        		  'WHERE  plr.rule_type in '||
             		  '(''ADVANCE'',''ADVANCE_INDICATOR'',''ADV_DEDUCTION'', '||
              		  '''PAY_ADVANCE_INDICATOR'',''ADV_CLEARUP'',''DEFER_PAY'') '||
          		  'AND   plr.rule_mode = to_char(element.element_type_id) '||
          		  'AND  plr.legislation_code = hoi.org_information9 '||
          		  'AND   HOI.ORGANIZATION_ID =  ASGT.ORGANIZATION_ID '||
      		  ') '||
		  'AND ELEMENT.CLOSED_FOR_ENTRY_FLAG = ''N'' '||
 		  'AND ELEMENT.ADJUSTMENT_ONLY_FLAG = ''N'' '||
 		  'AND ((LINK.PAYROLL_ID IS NOT NULL AND LINK.PAYROLL_ID = ASGT.PAYROLL_ID) '||
      		  'OR (LINK.LINK_TO_ALL_PAYROLLS_FLAG = ''Y'' AND ASGT.PAYROLL_ID IS NOT NULL) '||
  		  'OR (LINK.PAYROLL_ID IS NULL AND LINK.LINK_TO_ALL_PAYROLLS_FLAG = ''N'')) '||
 		  'AND  (LINK.ORGANIZATION_ID = ASGT.ORGANIZATION_ID OR LINK.ORGANIZATION_ID IS NULL) '||
 		  'AND  (LINK.POSITION_ID = ASGT.POSITION_ID OR LINK.POSITION_ID IS NULL) '||
 		  'AND  (LINK.JOB_ID = ASGT.JOB_ID OR LINK.JOB_ID IS NULL) '||
 		  'AND  (LINK.GRADE_ID = ASGT.GRADE_ID OR LINK.GRADE_ID IS NULL) '||
 		  'AND  (LINK.LOCATION_ID = ASGT.LOCATION_ID OR LINK.LOCATION_ID IS NULL) '||
 		  'AND  (LINK.PAY_BASIS_ID = ASGT.PAY_BASIS_ID OR LINK.PAY_BASIS_ID IS NULL) '||
 		  'AND  (LINK.EMPLOYMENT_CATEGORY = ASGT.EMPLOYMENT_CATEGORY OR '||
 		  'LINK.EMPLOYMENT_CATEGORY IS NULL) '||
 		  'AND  (ELEMENT.PROCESSING_TYPE = ''R'' OR ASGT.PAYROLL_ID IS NOT NULL) '||
 		  'and asgt.person_id = nvl(fnd_profile.value(''OTL_TK_RESOURCE_ID''),fnd_profile.value(''OTL_TK_TIMEKEEPER_ID'')) '||
		  'and '||p_alias_definition_id ||' = had.alias_definition_id '||

		  'AND ELEMENT.EFFECTIVE_START_DATE <= fnd_profile.value(''OTL_TK_END_DATE'') '||
		  'AND ELEMENT.EFFECTIVE_END_DATE >= fnd_profile.value(''OTL_TK_START_DATE'') '||
		  'AND date_from <= fnd_profile.value(''OTL_TK_END_DATE'') '||
		  'AND nvl(date_to,hr_general.end_of_time) >= fnd_profile.value(''OTL_TK_START_DATE'') '||
		  'AND ASGT.EFFECTIVE_START_DATE <= fnd_profile.value(''OTL_TK_END_DATE'') '||
		  'AND ASGT.EFFECTIVE_END_DATE >=fnd_profile.value(''OTL_TK_START_DATE'') '||
                  'AND LINK.EFFECTIVE_START_DATE <= fnd_profile.value(''OTL_TK_END_DATE'') '||
                  'AND LINK.EFFECTIVE_END_DATE >=fnd_profile.value(''OTL_TK_START_DATE'') '||
                  'AND  (LINK.PEOPLE_GROUP_ID IS NULL '||
		  '   OR EXISTS ( '||
		  '    SELECT 1 FROM PAY_ASSIGNMENT_LINK_USAGES_F USAGE '||
		  '    WHERE USAGE.ASSIGNMENT_ID = ASGT.ASSIGNMENT_ID '||
		  '    AND USAGE.ELEMENT_LINK_ID = LINK.ELEMENT_LINK_ID '||
		  '    AND USAGE.EFFECTIVE_START_DATE <= fnd_profile.value(''OTL_TK_END_DATE'') '||
		  '    AND USAGE.EFFECTIVE_END_DATE >= fnd_profile.value(''OTL_TK_START_DATE''))) '||
		  '  AND (SERVICE_PERIOD.ACTUAL_TERMINATION_DATE IS NULL '||
		  '   OR (SERVICE_PERIOD.ACTUAL_TERMINATION_DATE IS NOT NULL '||
		  '   AND fnd_profile.value(''OTL_TK_START_DATE'') <= DECODE(ELEMENT.POST_TERMINATION_RULE, '||
		  '      ''L'', SERVICE_PERIOD.LAST_STANDARD_PROCESS_DATE, '||
		  '      ''F'', NVL(SERVICE_PERIOD.FINAL_PROCESS_DATE, '||
		  '       hr_general.end_of_time), '||
		  '      SERVICE_PERIOD.ACTUAL_TERMINATION_DATE))) ';

   ELSIF l_reference_object = 'PAYROLL_ELEMENTS' THEN

     x_select := 'select   distinct(havt.alias_value_name)        Display_Value,'||
                 '         hav.alias_value_id            id_value '||
		 'from     hxc_alias_values              hav, '||
		 '         hxc_alias_values_tl          havt, '||
		 '         hxc_alias_definitions         had, '||
		 '         PAY_ELEMENT_TYPES_F_TL  ELEMENTTL, '||
		 '         PAY_ELEMENT_TYPES_F  ELEMENT, '||
		 '         PAY_ELEMENT_CLASSIFICATIONS_TL CLASSIFICATIONTL, '||
		 '         PAY_ELEMENT_CLASSIFICATIONS CLASSIFICATION, '||
		 '         BEN_BENEFIT_CLASSIFICATIONS BENEFIT, '||
		 '         PAY_ELEMENT_LINKS_F  LINK, '||
		 '         PER_ALL_ASSIGNMENTS_F  ASGT, '||
		 '         PER_PERIODS_OF_SERVICE  SERVICE_PERIOD '||
		 'where asgt.person_id = nvl(fnd_profile.value(''OTL_TK_RESOURCE_ID''),fnd_profile.value(''OTL_TK_TIMEKEEPER_ID'')) '||
		 '  and hav.attribute_category=''PAYROLL_ELEMENTS'' '||
		 '  and hav.attribute1 = ELEMENT.element_type_id '||
		 '  and hav.enabled_flag=''Y'' '||
		 '  and had.alias_definition_id = hav.alias_definition_id '||
		 '  and had.alias_definition_id = '||p_alias_definition_id||
		 '  AND ELEMENT.EFFECTIVE_START_DATE <= fnd_profile.value(''OTL_TK_END_DATE'') '||
		 '  AND ELEMENT.EFFECTIVE_END_DATE >= fnd_profile.value(''OTL_TK_START_DATE'') '||
		 '  and havt.language = USERENV(''LANG'') '||
		 '  and havt.alias_value_id = hav.alias_value_id '||
		 '  and hav.date_from <= fnd_profile.value(''OTL_TK_END_DATE'')  '||
		 '  and nvl(hav.date_to,hr_general.end_of_time) >=fnd_profile.value(''OTL_TK_START_DATE'')  '||
		 '  and ELEMENT.ELEMENT_TYPE_ID = ELEMENTTL.ELEMENT_TYPE_ID '||
		 '  AND ELEMENTTL.LANGUAGE = USERENV(''LANG'') '||
		 '  AND CLASSIFICATION.CLASSIFICATION_ID = CLASSIFICATIONTL.CLASSIFICATION_ID (+) '||
		 '  AND DECODE(CLASSIFICATIONTL.CLASSIFICATION_ID,NULL,''1'',CLASSIFICATIONTL.LANGUAGE) = '||
		 '      DECODE(CLASSIFICATIONTL.CLASSIFICATION_ID,NULL,''1'',USERENV(''LANG'')) '||
		 '  AND ASGT.BUSINESS_GROUP_ID = LINK.BUSINESS_GROUP_ID '||
		 '  AND  ELEMENT.ELEMENT_TYPE_ID = LINK.ELEMENT_TYPE_ID '||
		 '  AND ELEMENT.BENEFIT_CLASSIFICATION_ID = BENEFIT.BENEFIT_CLASSIFICATION_ID (+) '||
		 '  AND ELEMENT.CLASSIFICATION_ID = CLASSIFICATION.CLASSIFICATION_ID '||
		 '  AND SERVICE_PERIOD.PERIOD_OF_SERVICE_ID = ASGT.PERIOD_OF_SERVICE_ID '||
		 '  AND ASGT.EFFECTIVE_START_DATE  <= fnd_profile.value(''OTL_TK_END_DATE'')  '||
		 '  AND ASGT.EFFECTIVE_END_DATE  >= fnd_profile.value(''OTL_TK_START_DATE'')  '||
		 '  AND LINK.EFFECTIVE_START_DATE  <= fnd_profile.value(''OTL_TK_END_DATE'')  '||
		 '  AND LINK.EFFECTIVE_END_DATE >= fnd_profile.value(''OTL_TK_START_DATE'')  '||
		 '  AND ELEMENT.INDIRECT_ONLY_FLAG = ''N'' '||
		 '  AND UPPER (ELEMENT.ELEMENT_NAME) <> ''VERTEX'' '||
		 '  AND not exists '||
		 '      (select 1 '||
		 '         from HR_ORGANIZATION_INFORMATION HOI, '||
		 '              PAY_LEGISLATION_RULES PLR '||
		 '        WHERE  plr.rule_type in '||
		 '             (''ADVANCE'',''ADVANCE_INDICATOR'',''ADV_DEDUCTION'', '||
		 '              ''PAY_ADVANCE_INDICATOR'',''ADV_CLEARUP'',''DEFER_PAY'') '||
		 '          AND   plr.rule_mode = to_char(element.element_type_id) '||
		 '          AND  plr.legislation_code = hoi.org_information9 '||
		 '          AND   HOI.ORGANIZATION_ID =  ASGT.ORGANIZATION_ID '||
		 '      ) '||
		 'AND ELEMENT.CLOSED_FOR_ENTRY_FLAG = ''N'' '||
		 ' AND ELEMENT.ADJUSTMENT_ONLY_FLAG = ''N'' '||
		 ' AND ((LINK.PAYROLL_ID IS NOT NULL AND LINK.PAYROLL_ID = ASGT.PAYROLL_ID) '||
		 '      OR (LINK.LINK_TO_ALL_PAYROLLS_FLAG = ''Y'' AND ASGT.PAYROLL_ID IS NOT NULL) '||
		 '  OR (LINK.PAYROLL_ID IS NULL AND LINK.LINK_TO_ALL_PAYROLLS_FLAG = ''N'')) '||
		 ' AND  (LINK.ORGANIZATION_ID = ASGT.ORGANIZATION_ID OR LINK.ORGANIZATION_ID IS NULL) '||
		 ' AND  (LINK.POSITION_ID = ASGT.POSITION_ID OR LINK.POSITION_ID IS NULL) '||
		 ' AND  (LINK.JOB_ID = ASGT.JOB_ID OR LINK.JOB_ID IS NULL) '||
		 ' AND  (LINK.GRADE_ID = ASGT.GRADE_ID OR LINK.GRADE_ID IS NULL) '||
		 ' AND  (LINK.LOCATION_ID = ASGT.LOCATION_ID OR LINK.LOCATION_ID IS NULL) '||
		 ' AND  (LINK.PAY_BASIS_ID = ASGT.PAY_BASIS_ID OR LINK.PAY_BASIS_ID IS NULL) '||
		 ' AND  (LINK.EMPLOYMENT_CATEGORY = ASGT.EMPLOYMENT_CATEGORY OR '||
		 ' LINK.EMPLOYMENT_CATEGORY IS NULL) '||
		 ' AND  (LINK.PEOPLE_GROUP_ID IS NULL '||
		 '  OR EXISTS ( '||
		 '   SELECT 1 FROM PAY_ASSIGNMENT_LINK_USAGES_F USAGE '||
		 '   WHERE USAGE.ASSIGNMENT_ID = ASGT.ASSIGNMENT_ID '||
		 '   AND USAGE.ELEMENT_LINK_ID = LINK.ELEMENT_LINK_ID '||
		 '   AND (USAGE.EFFECTIVE_START_DATE  <= fnd_profile.value(''OTL_TK_END_DATE'')  '||
		 '    AND USAGE.EFFECTIVE_END_DATE >= fnd_profile.value(''OTL_TK_START_DATE'') ))) '||
		 ' AND  (ELEMENT.PROCESSING_TYPE = ''R'' OR ASGT.PAYROLL_ID IS NOT NULL) '||
		 ' AND (SERVICE_PERIOD.ACTUAL_TERMINATION_DATE IS NULL '||
		 '  OR (SERVICE_PERIOD.ACTUAL_TERMINATION_DATE IS NOT NULL '||
		 '  AND fnd_profile.value(''OTL_TK_START_DATE'')   <= DECODE(ELEMENT.POST_TERMINATION_RULE, '||
		 '     ''L'', NVL(SERVICE_PERIOD.LAST_STANDARD_PROCESS_DATE, hr_general.end_of_time),'||
		 '     ''F'', NVL(SERVICE_PERIOD.FINAL_PROCESS_DATE, '||
		 '      hr_general.end_of_time), '||
		 '     SERVICE_PERIOD.ACTUAL_TERMINATION_DATE))) ';
   ELSE

     x_select := 'select   havt.alias_value_name         Display_Value,'||
                 '         hav.alias_value_id            id_value '||
		 'from     hxc_alias_values              hav, '||
		 '         hxc_alias_values_tl          havt, '||
		 '         hxc_alias_definitions         had '||
		 'where hav.enabled_flag=''Y'' '||
		 '  and had.alias_definition_id = hav.alias_definition_id '||
		 '  and had.alias_definition_id = '||p_alias_definition_id||
		 '  and havt.language = USERENV(''LANG'') '||
		 '  and havt.alias_value_id = hav.alias_value_id '||
		 '  and hav.date_from <= fnd_profile.value(''OTL_TK_END_DATE'')  '||
		 '  and nvl(hav.date_to,hr_general.end_of_time) >=fnd_profile.value(''OTL_TK_START_DATE'') ';
   END IF;

 ELSE
   fnd_message.set_name('HXC', 'HXC_------_INVALID_REFERENCE_OBJECT');
   fnd_message.raise_error;
 END IF;

--if g_debug then
	--hr_utility.trace('x_select'||x_select);
--end if;

END get_otl_an_context_type_select;


-- ---------------------------------------------------------------------
-- |------------------------< get_value_from_index >--------------------|
-- ---------------------------------------------------------------------
-- | This procedure returns for a specific index the string value       |
-- | i.e.: val1 - val2 and index =2 will return val2		        |
-- ---------------------------------------------------------------------
FUNCTION get_value_from_index
   (p_str    VARCHAR2
   ,p_index  NUMBER
   )
RETURN VARCHAR2
IS

l_pos 		NUMBER := 1;
l_current_index NUMBER := 1;
l_end_index 	NUMBER := 0;

BEGIN
  IF (p_index = 1) THEN
    IF INSTR(p_str, hxc_alias_utility.ALIAS_SEPARATOR) = 0 THEN
      RETURN p_str;
    ELSE
      RETURN SUBSTR(p_str, 1, (INSTR(p_str, hxc_alias_utility.ALIAS_SEPARATOR) - 1));
    END IF;
  END IF;

  LOOP
    EXIT WHEN l_end_index = LENGTH(p_str);

    l_pos := l_pos + 1;

    l_current_index := INSTR(p_str, hxc_alias_utility.ALIAS_SEPARATOR, (l_current_index + 1) );

    IF (l_current_index = -1) THEN
       RETURN SUBSTR(p_str, l_end_index + 1, length(p_str) - l_end_index);
    ELSE
       l_end_index := INSTR(p_str, hxc_alias_utility.ALIAS_SEPARATOR, (l_current_index + 1));

       IF (l_end_index = 0) THEN
         l_end_index := LENGTH(p_str);
       ELSE
         l_end_index := l_end_index - l_current_index - 15;
       END IF;
    END IF;

    IF (l_pos = p_index) THEN
      RETURN SUBSTR(p_str, l_current_index + 15, l_end_index);
    END IF;

  END LOOP;

RETURN NULL;

END get_value_from_index;

-- ---------------------------------------------------------------------
-- |------------------------< query_invoice	   >--------------------|
-- ---------------------------------------------------------------------
-- | This procedure returns the result of a select statment	        |
-- ---------------------------------------------------------------------
FUNCTION query_invoice(p_select IN  VARCHAR2)
	RETURN VARCHAR2 IS

TYPE cur_typ IS REF CURSOR;
c cur_typ;

l_result VARCHAR2(300);

BEGIN

g_debug:=hr_utility.debug_enabled;

--if g_debug then
	--hr_utility.trace('p_select '||p_select);
--end if;

    OPEN c FOR p_select;
    FETCH c INTO l_result;
    CLOSE c;

    RETURN l_result;

END query_invoice;

-- ---------------------------------------------------------------------
-- |-----------------< get_apps_table_from_type	   >--------------------|
-- ---------------------------------------------------------------------
-- | This procedure returns the apps table of an alias definiton        |
-- ---------------------------------------------------------------------
FUNCTION get_apps_table_from_type(p_alias_definition_id IN  VARCHAR2)
	RETURN VARCHAR2 IS

l_apps_table VARCHAR2(240);

BEGIN

-- first look in the global table that we don't have the information
IF g_alias_apps_tab_info.exists(p_alias_definition_id) THEN
  l_apps_table 		:= g_alias_apps_tab_info(p_alias_definition_id).APPS_TAB_NAME;
ELSE

  select application_table_name
  into l_apps_table
  from   fnd_flex_validation_tables t,
  	 hxc_alias_types h,
  	 hxc_alias_definitions hd
  where  t.flex_value_set_id = h.reference_object
  and    hd.alias_definition_id = p_alias_definition_id
  and    hd.alias_type_id	= h.alias_type_id;

  -- add it into the global pl/sql table
  g_alias_apps_tab_info(p_alias_definition_id).APPS_TAB_NAME := l_apps_table;

END IF;

 RETURN l_apps_table;

 EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;


END get_apps_table_from_type;


-- ---------------------------------------------------------------------
-- |------------------------< get_sfl_from_alias_value  >---------------|
-- ---------------------------------------------------------------------
-- | This procedure returns the system linkage function attached to     |
-- | a specific alias value
-- ---------------------------------------------------------------------
FUNCTION get_sfl_from_alias_value(p_alias_value_id IN VARCHAR2)
	RETURN VARCHAR2 IS

l_sfl VARCHAR2(80);

BEGIN

 select attribute3
 into l_sfl
 from hxc_alias_values
 where alias_value_id = p_alias_value_id;

 RETURN l_sfl;

 EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;


END get_sfl_from_alias_value;

-- ---------------------------------------------------------------------
-- |-------------------< get_alias_att_to_match_to_dep  >---------------|
-- ---------------------------------------------------------------------
-- | This procedure creates the pl/sql table to match while the deposit |
-- | of the attribute						        |
-- ---------------------------------------------------------------------
PROCEDURE get_alias_att_to_match_to_dep(p_alias_definition_id 		NUMBER
     				       ,p_alias_old_value_id  		NUMBER
     				       ,p_alias_type			VARCHAR2
     				       ,p_original_value		VARCHAR2
     				       ,p_alias_val_att_to_match OUT NOCOPY t_alias_val_att_to_match
     				       ,p_att_to_delete		 OUT NOCOPY BOOLEAN) IS

l_alias_val_att_to_match	t_alias_val_att_to_match;
l_index_att_to_match		NUMBER;

l_select 			VARCHAR2(200) := NULL;
l_where_clause			VARCHAR2(300) := NULL;
l_apps_table			VARCHAR2(240);

l_number_column_id		NUMBER;

l_value 			VARCHAR2(200);


-- Bug No : 6943339
-- The below cursor pulls out the datatype of the reference
-- object based on which the alias value is built, and
-- returns it.

CURSOR get_ref_datatype (p_reference_object   NUMBER)
    IS SELECT format_type
         FROM fnd_flex_value_sets
        WHERE flex_value_set_id = p_reference_object ;

l_vset_data_type               VARCHAR2(5);


BEGIN

g_debug		:= hr_utility.debug_enabled;
l_value 	:= p_original_value;
p_att_to_delete := FALSE;

-- look for the alias definition information
-- get the alias attribute values to match with the attribute.

--if g_debug then
	--hr_utility.trace('p_alias_type'||p_alias_type);
	--hr_utility.trace('p_alias_definition_id'||p_alias_definition_id);
--end if;

IF p_alias_type like 'VALUE_SET%' THEN

  get_alias_val_att_to_match
       (p_alias_definition_id,
        l_alias_val_att_to_match);

--dump_alias_val_att_to_match(l_alias_val_att_to_match);

  -- but here we need to understand what to do.
  -- the most simple is we just have one column_id
  -- which mean the value will be store
  IF l_alias_val_att_to_match.count = 1 THEN
    -- we are checking the alias_component_type to be 'COLUMN_ID' or 'VALUE
    IF l_alias_val_att_to_match.exists(l_alias_val_att_to_match.first) THEN

      IF l_alias_val_att_to_match(l_alias_val_att_to_match.first).COMPONENT_TYPE = 'COLUMN_ID'
         or l_alias_val_att_to_match(l_alias_val_att_to_match.first).COMPONENT_TYPE = 'VALUE'
         THEN

             -- Bug No : 6943339
             -- Added the below code to do conversions to canonical format, if
             -- the value is getting stored for the alias.
             -- Doing it only for Value Set None.  Here we store the exact values
             -- and to enable proper retrieval, need to convert to canonical
             -- format.
             -- * Check in the associative array for value set formats if
             --   the data type exists.
             -- * If not, find that out and store it.
             -- * If the format is X ( based on FIELD_TYPE lookup ) it is a standard
             --   date format, so convert it to canonical date.
             -- * If the format is N, it is a standard number, convert to canonical number.

             IF p_alias_type = 'VALUE_SET_NONE'
             THEN
                IF NOT hxc_alias_translator.g_vset_fmt.EXISTS(TO_CHAR(l_alias_val_att_to_match(l_alias_val_att_to_match.FIRST).reference_object))
                THEN
                   OPEN get_ref_datatype(l_alias_val_att_to_match(l_alias_val_att_to_match.FIRST).reference_object);
                   FETCH get_ref_datatype
                    INTO l_vset_data_type;
                   CLOSE get_ref_datatype;
                   hxc_alias_translator.g_vset_fmt(TO_CHAR(l_alias_val_att_to_match(l_alias_val_att_to_match.FIRST).reference_object))
                             := l_vset_data_type;
                END IF;

                IF hxc_alias_translator.g_vset_fmt(TO_CHAR(l_alias_val_att_to_match(l_alias_val_att_to_match.FIRST).reference_object)) = 'X'
                THEN

                   l_value := FND_DATE.DATE_TO_CANONICAL(l_value);

                ELSIF hxc_alias_translator.g_vset_fmt(TO_CHAR(l_alias_val_att_to_match(l_alias_val_att_to_match.FIRST).reference_object)) = 'N'
                THEN
                   l_value := FND_NUMBER.NUMBER_TO_CANONICAL(l_value);
                END IF;


             END IF;


        -- we are updating the information in the
        -- attribute_to_match table.
 	set_attribute_to_match_info
  		(p_attribute_to_match 	=> l_alias_val_att_to_match,
   		 p_index_in_table	=> l_alias_val_att_to_match.first,
		 p_attribute_to_set	=> l_alias_val_att_to_match(l_alias_val_att_to_match.first).segment,
		 p_bld_blk_info_type	=> l_alias_val_att_to_match(l_alias_val_att_to_match.first).bld_blk_info_type,
		 p_mapping_att_cat	=> l_alias_val_att_to_match(l_alias_val_att_to_match.first).MAPPING_ATT_CAT,
		 p_value_to_set		=> l_value);

       END IF;
     END IF;
   ELSE
     -- there are some jobs to do here to calculate what to do.
     -- if there is more than one column_id then we need to split
     -- the number of value
     -- first we need to count the number of column_id contain
     -- in l_value_att_to_match table.
     l_number_column_id := 1;

     l_index_att_to_match := l_alias_val_att_to_match.first;

     -- first loop in the match table to find the column
     -- In this look we are setting up the column_id value
     LOOP
       EXIT WHEN
        (NOT l_alias_val_att_to_match.exists(l_index_att_to_match));

         IF l_alias_val_att_to_match(l_index_att_to_match).COMPONENT_TYPE = 'COLUMN_ID' THEN
            -- go through the string and check the to_check

            l_value :=
                get_value_from_index
   		(p_str    => p_original_value
   		,p_index  => l_number_column_id
   		);

            -- we are matching here the column value.
            set_attribute_to_match_info
  		(p_attribute_to_match 	=> l_alias_val_att_to_match,
   		 p_index_in_table	=> l_index_att_to_match,
		 p_attribute_to_set	=> l_alias_val_att_to_match(l_index_att_to_match).segment,
		 p_bld_blk_info_type	=> l_alias_val_att_to_match(l_index_att_to_match).bld_blk_info_type,
		 p_mapping_att_cat	=> l_alias_val_att_to_match(l_index_att_to_match).MAPPING_ATT_CAT,
		 p_value_to_set		=> l_value);

	    l_number_column_id := l_number_column_id + 1;

	    -- we need also to build the where clause to find the column
	    IF l_where_clause is null THEN
     	       l_where_clause := l_alias_val_att_to_match(l_index_att_to_match).COMPONENT_NAME||'='''||l_value||'''';

	    ELSE
	       l_where_clause := l_where_clause ||'and '
	                            ||l_alias_val_att_to_match(l_index_att_to_match).COMPONENT_NAME||
	                            '='''||l_value||'''';
	    END IF;

          END IF;

          l_index_att_to_match := l_alias_val_att_to_match.next(l_index_att_to_match);

       END LOOP;

       -- now we are looping to find the column and value to add in the
       -- match table.

       l_index_att_to_match := l_alias_val_att_to_match.first;

       -- from the type we need to know what is the application table that
       -- we need to run the query.
       l_apps_table :=
           get_apps_table_from_type (p_alias_definition_id => p_alias_definition_id);

       LOOP
          EXIT WHEN
            (NOT l_alias_val_att_to_match.exists(l_index_att_to_match));

            IF l_alias_val_att_to_match(l_index_att_to_match).COMPONENT_TYPE = 'COLUMN' THEN

              l_select := 'select '||l_alias_val_att_to_match(l_index_att_to_match).COMPONENT_NAME||
                          ' from '||l_apps_table||
                          ' where '||l_where_clause;

	      l_value := query_invoice(p_select => l_select);

 	       -- we are matching here the column value.
               set_attribute_to_match_info
  		(p_attribute_to_match	=> l_alias_val_att_to_match,
   		 p_index_in_table	=> l_index_att_to_match,
		 p_attribute_to_set	=> l_alias_val_att_to_match(l_index_att_to_match).segment,
		 p_bld_blk_info_type	=> l_alias_val_att_to_match(l_index_att_to_match).bld_blk_info_type,
		 p_mapping_att_cat	=> l_alias_val_att_to_match(l_index_att_to_match).MAPPING_ATT_CAT,
		 p_value_to_set		=> l_value);

	     END IF;

         l_index_att_to_match := l_alias_val_att_to_match.next(l_index_att_to_match);

        END LOOP;

   END IF;

-- else we are on the alias_value situation.
ELSE
   -- little bit more compilcated here.
   -- first we need to check what this the next value
--if g_debug then
	--hr_utility.trace('p_alias_old_value_id'||p_alias_old_value_id);
	--hr_utility.trace('p_original_value'||p_original_value);
--end if;
   IF p_original_value is not null THEN
     -- find the attribute to match
     get_alias_val_att_to_match
          (p_alias_definition_id,
           p_original_value,
           l_alias_val_att_to_match);

     --dump_alias_val_att_to_match(l_alias_val_att_to_match);

   ELSE
      IF p_alias_old_value_id is not null THEN
         -- find the attribute to match and then to blank out or delete
         get_alias_val_att_to_match
            (p_alias_definition_id,
             p_alias_old_value_id,
             l_alias_val_att_to_match);

         p_att_to_delete := TRUE;
      ELSE
         -- in the case that everything is null
         -- we need to remove all the attribute
         -- that match this definition
         get_alias_val_att_to_match
            (p_alias_definition_id,
             l_alias_val_att_to_match);

         p_att_to_delete := TRUE;

      END IF;

    END IF;

END IF;

p_alias_val_att_to_match := l_alias_val_att_to_match;

END get_alias_att_to_match_to_dep;

-- ----------------------------------------------------------------------------
-- |---------------------------< time_entry_rules_segment_trans >--------------------|
-- ----------------------------------------------------------------------------
PROCEDURE time_entry_rules_segment_trans
             (p_timecard_id	IN NUMBER
             ,p_timecard_ovn	IN NUMBER
             ,p_start_time	IN DATE
             ,p_stop_time	IN DATE
             ,p_resource_id	IN NUMBER
             ,p_attr_change_table IN OUT NOCOPY hxc_time_entry_rules_utils_pkg.t_change_att_tab)
             IS

cursor c_layout is
select
 a.time_attribute_id
,au.time_building_block_id
,null bld_blk_info_type
,a.attribute_category
,a.attribute1
,a.attribute2
,a.attribute3
,a.attribute4
,a.attribute5
,a.attribute6
,a.attribute7
,a.attribute8
,a.attribute9
,a.attribute10
,a.attribute11
,a.attribute12
,a.attribute13
,a.attribute14
,a.attribute15
,a.attribute16
,a.attribute17
,a.attribute18
,a.attribute19
,a.attribute20
,a.attribute21
,a.attribute22
,a.attribute23
,a.attribute24
,a.attribute25
,a.attribute26
,a.attribute27
,a.attribute28
,a.attribute29
,a.attribute30
,a.bld_blk_info_type_id
,a.object_version_number
,'N' NEW
,'N' CHANGED
,'N' PROCESS
,au.time_building_block_ovn BUILDING_BLOCK_OVN
from hxc_time_attribute_usages au,
hxc_time_attributes a,
hxc_time_building_blocks htbb
where 	a.time_attribute_id         = au.time_attribute_id
and     au.time_building_block_id   = htbb.time_building_block_id
and     au.time_building_block_ovn  = htbb.object_version_number
and     htbb.scope		    = 'TIMECARD'
and     htbb.time_building_block_id     = p_timecard_id
and     htbb.object_version_number      = p_timecard_ovn
and     htbb.resource_id		= p_resource_id
and     a.attribute_category = 'LAYOUT';


l_alias_def_item		t_alias_def_item;
l_alias_val_att_to_match	t_alias_val_att_to_match;
l_attributes			HXC_ATTRIBUTE_TABLE_TYPE;

l_index_alias_def	NUMBER;
l_index_change_att	NUMBER;
l_index_alias		NUMBER;
l_index			NUMBER;
l_index_comp		NUMBER;

l_change_att_cat 	VARCHAR2(80);
l_changed_att     	VARCHAR2(240);

l_match_found		BOOLEAN;

BEGIN

l_attributes := HXC_ATTRIBUTE_TABLE_TYPE();

-- first of all we need to check if we have the layout_id
-- of this timecard in the cache table
IF g_layout_attribute.exists(p_timecard_id) THEN

  l_attributes := g_layout_attribute;

ELSE

  g_layout_attribute   := HXC_ATTRIBUTE_TABLE_TYPE();
  -- we delete the global table
  g_layout_attribute.delete;
  -- we fetch the layout_id for the timecard

  -- finally we populate the global table
  FOR c_detail_attribute in c_layout LOOP

	  g_layout_attribute.extend;
	  g_layout_attribute(g_layout_attribute.last) :=
	     hxc_attribute_type (
	     c_detail_attribute.time_attribute_id,
	     c_detail_attribute.time_building_block_id,
	     c_detail_attribute.attribute_category,
	     c_detail_attribute.attribute1,
	     c_detail_attribute.attribute2,
	     c_detail_attribute.attribute3,
	     c_detail_attribute.attribute4,
	     c_detail_attribute.attribute5,
	     c_detail_attribute.attribute6,
	     c_detail_attribute.attribute7,
	     c_detail_attribute.attribute8,
	     c_detail_attribute.attribute9,
	     c_detail_attribute.attribute10,
	     c_detail_attribute.attribute11,
	     c_detail_attribute.attribute12,
	     c_detail_attribute.attribute13,
	     c_detail_attribute.attribute14,
	     c_detail_attribute.attribute15,
	     c_detail_attribute.attribute16,
	     c_detail_attribute.attribute17,
	     c_detail_attribute.attribute18,
	     c_detail_attribute.attribute19,
	     c_detail_attribute.attribute20,
	     c_detail_attribute.attribute21,
	     c_detail_attribute.attribute22,
	     c_detail_attribute.attribute23,
	     c_detail_attribute.attribute24,
	     c_detail_attribute.attribute25,
	     c_detail_attribute.attribute26,
	     c_detail_attribute.attribute27,
	     c_detail_attribute.attribute28,
	     c_detail_attribute.attribute29,
	     c_detail_attribute.attribute30,
	     c_detail_attribute.bld_blk_info_type_id,
	     c_detail_attribute.object_version_number,
	     c_detail_attribute.NEW,
	     c_detail_attribute.CHANGED,
	     c_detail_attribute.bld_blk_info_type,
	     c_detail_attribute.PROCESS,
	     c_detail_attribute.BUILDING_BLOCK_OVN);

   END LOOP;

  l_attributes := g_layout_attribute;

END IF;

-- now we call the procedure to get the alias definition item
-- now I know the attribute_category and the alias definition id for
-- the timecard


get_alias_def_item
    		(p_resource_id 		=> p_resource_id,
    		 p_attributes		=> l_attributes,
    		 p_alias_def_item	=> l_alias_def_item,
    		 p_start_time		=> p_start_time,
    		 p_stop_time		=> p_stop_time,
    		 p_cache_label		=> TRUE);

-- now we are getting the attribute to match for the each alias_definition
--if g_debug then
	--hr_utility.trace('--------------JOEL START----------------------------');
--end if;
--dump_alias_val_att_to_match(g_comp_label);
--if g_debug then
	--hr_utility.trace('--------------JOEL END----------------------------');
--end if;

l_index_alias_def := l_alias_def_item.first;

LOOP
 EXIT WHEN
 (NOT l_alias_def_item.exists(l_index_alias_def));

   l_alias_val_att_to_match.delete;

   get_alias_val_att_to_match
     (p_alias_definition_id	=> l_alias_def_item(l_index_alias_def).alias_definition_id,
      p_alias_val_att_to_match	=> l_alias_val_att_to_match);

--dump_alias_val_att_to_match(l_alias_val_att_to_match);
  -- now we need to go through the change attribute to see if we
  -- find a match

  l_match_found := FALSE;

  l_index_change_att := p_attr_change_table.first;
  LOOP
    EXIT WHEN
    (NOT p_attr_change_table.exists(l_index_change_att));

     l_change_att_cat := p_attr_change_table(l_index_change_att).attribute_category;
     l_changed_att     := p_attr_change_table(l_index_change_att).changed_attribute;

     -- now we need to go through the alias to match table
     l_index_alias := l_alias_val_att_to_match.first;
     LOOP
       EXIT WHEN
       (NOT l_alias_val_att_to_match.exists(l_index_alias));

       IF  l_change_att_cat = l_alias_val_att_to_match(l_index_alias).BLD_BLK_INFO_TYPE
       AND l_changed_att     = l_alias_val_att_to_match(l_index_alias).SEGMENT THEN
         l_match_found := TRUE;
       END IF;

       l_index_alias := l_alias_val_att_to_match.next(l_index_alias);

     END LOOP;

     -- and we are populating the field name based on the global
     -- pl/sql table
     l_index_comp := g_comp_label.first;
     LOOP
       EXIT WHEN
       (NOT g_comp_label.exists(l_index_comp));
/*
if g_debug then
	hr_utility.trace('-------STEP 1 ------');
	hr_utility.trace('upper(l_change_att_cat) '||nvl(upper(l_change_att_cat),-1));
	hr_utility.trace('upper(g_comp_label(l_index_comp).MAPPING_ATT_CAT '||nvl(upper(g_comp_label(l_index_comp).MAPPING_ATT_CAT),-1));
	hr_utility.trace('upper(l_changed_att) '||upper(l_changed_att));
	hr_utility.trace('upper(g_comp_label(l_index_comp).SEGMENT '||upper(g_comp_label(l_index_comp).SEGMENT));
	hr_utility.trace('-------------');
end if;
*/
       IF  nvl(upper(l_change_att_cat),-1) =
             nvl(upper(g_comp_label(l_index_comp).MAPPING_ATT_CAT),-1)
       AND upper(l_changed_att)    = upper(g_comp_label(l_index_comp).SEGMENT)
       THEN
         -- populate the field name
         p_attr_change_table(l_index_change_att).field_name :=
              g_comp_label(l_index_comp).ATTRIBUTE1;
--if g_debug then
	--hr_utility.trace(' g_comp_label(l_index_comp).ATTRIBUTE1 '|| g_comp_label(l_index_comp).ATTRIBUTE1);
--end if;
       END IF;

       l_index_comp := g_comp_label.next(l_index_comp);

     END LOOP;

     l_index_change_att := p_attr_change_table.next(l_index_change_att);

  END LOOP;

  -- before we go the next alias definition
  -- we need to check if we need or not to add the OTL_ALIAS
  -- in p_attr_change_table
  IF (l_match_found) THEN
    -- we are adding the information
    l_index := p_attr_change_table.last+1;
    p_attr_change_table(l_index).attribute_category
                          := l_alias_def_item(l_index_alias_def).ITEM_ATTRIBUTE_CATEGORY;
    p_attr_change_table(l_index).field_name
                          := l_alias_def_item(l_index_alias_def).ALIAS_LABEL;
    p_attr_change_table(l_index).changed_attribute := 'ATTRIBUTE1';

  END IF;

  l_index_alias_def := l_alias_def_item.next(l_index_alias_def);

END LOOP;

-- add a condition in the case we don't have
-- an alias in the layout.
IF (l_alias_def_item.count = 0) THEN

  l_index_change_att := p_attr_change_table.first;
  LOOP
    EXIT WHEN
    (NOT p_attr_change_table.exists(l_index_change_att));

     l_change_att_cat := p_attr_change_table(l_index_change_att).attribute_category;
     l_changed_att     := p_attr_change_table(l_index_change_att).changed_attribute;

     -- and we are populating the field name based on the global
     -- pl/sql table
     l_index_comp := g_comp_label.first;
     LOOP
       EXIT WHEN
       (NOT g_comp_label.exists(l_index_comp));
/*
if g_debug then
	hr_utility.trace('-------STEP 2------');
	hr_utility.trace('upper(l_change_att_cat) '||nvl(upper(l_change_att_cat),-1));
	hr_utility.trace('upper(g_comp_label(l_index_comp).MAPPING_ATT_CAT '||nvl(upper(g_comp_label(l_index_comp).MAPPING_ATT_CAT),-1));
	hr_utility.trace('upper(l_changed_att) '||upper(l_changed_att));
	hr_utility.trace('upper(g_comp_label(l_index_comp).SEGMENT '||upper(g_comp_label(l_index_comp).SEGMENT));
	hr_utility.trace('-------------');
end if;
*/

       IF  nvl(upper(l_change_att_cat),-1)
             = nvl(upper(g_comp_label(l_index_comp).MAPPING_ATT_CAT),-1)
       AND upper(l_changed_att)    = upper(g_comp_label(l_index_comp).SEGMENT)
       THEN
         -- populate the field name
         p_attr_change_table(l_index_change_att).field_name :=
              g_comp_label(l_index_comp).ATTRIBUTE1;
--if g_debug then
	--hr_utility.trace(' g_comp_label(l_index_comp).ATTRIBUTE1 '|| g_comp_label(l_index_comp).ATTRIBUTE1);
--end if;
	END IF;

       l_index_comp := g_comp_label.next(l_index_comp);

     END LOOP;

     l_index_change_att := p_attr_change_table.next(l_index_change_att);

  END LOOP;

END IF;

--if g_debug then
	--hr_utility.trace('--------------JOEL END---------------------------');
--end if;

/*
FOR I IN 1..p_attr_change_table.COUNT LOOP
  if g_debug then
	hr_utility.trace(' catg       ='|| p_attr_change_table(i).attribute_category ||
				 ' changed    ='|| p_attr_change_table(i).changed_attribute ||
				 ' field name  ='|| p_attr_change_table(i).field_name       ||
				 ' org_att_catg  ='|| p_attr_change_table(i).org_attribute_category  ||
				 ' org_changed_attr  ='|| p_attr_change_table(i).ORG_changed_attribute
				 );
  end if;
END LOOP;
*/

END time_entry_rules_segment_trans;




-- ---------------------------------------------------------------------
-- |-------------------< remove_empty_attribute         >---------------|
-- ---------------------------------------------------------------------
-- | Not in use							        |
-- ---------------------------------------------------------------------
/*
PROCEDURE remove_empty_attribute
        (p_attributes in out NOCOPY hxc_self_service_time_deposit.building_block_attribute_info) IS


l_index 		NUMBER;
l_index_to_delete 	NUMBER;

l_to_delete BOOLEAN;

BEGIN

   l_index := p_attributes.first;
   LOOP
   EXIT WHEN
     (NOT p_attributes.exists(l_index));

    l_to_delete := TRUE;

    -- we need to check that at least on attribute is not null
    --  otherwise we are removing it.
    IF p_attributes(l_index).ATTRIBUTE1 is not NULL THEN
       l_to_delete := FALSE;
    ELSIF p_attributes(l_index).ATTRIBUTE2 is not NULL THEN
       l_to_delete := FALSE;
    ELSIF p_attributes(l_index).ATTRIBUTE3 is not NULL THEN
       l_to_delete := FALSE;
    ELSIF p_attributes(l_index).ATTRIBUTE4 is not NULL THEN
       l_to_delete := FALSE;
    ELSIF p_attributes(l_index).ATTRIBUTE5 is not NULL THEN
       l_to_delete := FALSE;
    ELSIF p_attributes(l_index).ATTRIBUTE6 is not NULL THEN
       l_to_delete := FALSE;
    ELSIF p_attributes(l_index).ATTRIBUTE7 is not NULL THEN
       l_to_delete := FALSE;
    ELSIF p_attributes(l_index).ATTRIBUTE8 is not NULL THEN
       l_to_delete := FALSE;
    ELSIF p_attributes(l_index).ATTRIBUTE9 is not NULL THEN
       l_to_delete := FALSE;
    ELSIF p_attributes(l_index).ATTRIBUTE10 is not NULL THEN
       l_to_delete := FALSE;
    ELSIF p_attributes(l_index).ATTRIBUTE11 is not NULL THEN
       l_to_delete := FALSE;
    ELSIF p_attributes(l_index).ATTRIBUTE12 is not NULL THEN
       l_to_delete := FALSE;
    ELSIF p_attributes(l_index).ATTRIBUTE13 is not NULL THEN
       l_to_delete := FALSE;
    ELSIF p_attributes(l_index).ATTRIBUTE14 is not NULL THEN
       l_to_delete := FALSE;
    ELSIF p_attributes(l_index).ATTRIBUTE15 is not NULL THEN
       l_to_delete := FALSE;
    ELSIF p_attributes(l_index).ATTRIBUTE16 is not NULL THEN
       l_to_delete := FALSE;
    ELSIF p_attributes(l_index).ATTRIBUTE17 is not NULL THEN
       l_to_delete := FALSE;
    ELSIF p_attributes(l_index).ATTRIBUTE18 is not NULL THEN
       l_to_delete := FALSE;
    ELSIF p_attributes(l_index).ATTRIBUTE19 is not NULL THEN
       l_to_delete := FALSE;
    ELSIF p_attributes(l_index).ATTRIBUTE20 is not NULL THEN
       l_to_delete := FALSE;
    ELSIF p_attributes(l_index).ATTRIBUTE21 is not NULL THEN
       l_to_delete := FALSE;
    ELSIF p_attributes(l_index).ATTRIBUTE22 is not NULL THEN
       l_to_delete := FALSE;
    ELSIF p_attributes(l_index).ATTRIBUTE23 is not NULL THEN
       l_to_delete := FALSE;
    ELSIF p_attributes(l_index).ATTRIBUTE24 is not NULL THEN
       l_to_delete := FALSE;
    ELSIF p_attributes(l_index).ATTRIBUTE25 is not NULL THEN
       l_to_delete := FALSE;
    ELSIF p_attributes(l_index).ATTRIBUTE26 is not NULL THEN
       l_to_delete := FALSE;
    ELSIF p_attributes(l_index).ATTRIBUTE27 is not NULL THEN
       l_to_delete := FALSE;
    ELSIF p_attributes(l_index).ATTRIBUTE28 is not NULL THEN
       l_to_delete := FALSE;
    ELSIF p_attributes(l_index).ATTRIBUTE29 is not NULL THEN
       l_to_delete := FALSE;
    ELSIF p_attributes(l_index).ATTRIBUTE30 is not NULL THEN
       l_to_delete := FALSE;
    END IF;

    IF l_to_delete = FALSE AND p_attributes(l_index).ATTRIBUTE_CATEGORY is null THEN

       l_to_delete := TRUE;

    ELSIF l_to_delete AND p_attributes(l_index).BLD_BLK_INFO_TYPE like 'Dummy%'
       AND p_attributes(l_index).BLD_BLK_INFO_TYPE <> 'Dummy Paexpitdff Context' THEN
       l_to_delete := FALSE;
    END IF;

    IF l_to_delete THEN
      l_index_to_delete := l_index;
    END IF;

    l_index := p_attributes.next(l_index);

    -- now we can delete it
    IF l_to_delete THEN
      p_attributes.delete(l_index_to_delete);
    END IF;

   END LOOP;

END remove_empty_attribute;
*/

-- ---------------------------------------------------------------------
-- |-------------------< dump_alias_val_att_to_match   >---------------|
-- ---------------------------------------------------------------------
-- | Debug Procedure						        |
-- ---------------------------------------------------------------------
PROCEDURE dump_alias_val_att_to_match (p_alias_val_att_to_match IN OUT NOCOPY t_alias_val_att_to_match) IS

l_index number;

BEGIN

   l_index := p_alias_val_att_to_match.first;
   g_debug := hr_utility.debug_enabled;
   LOOP
   EXIT WHEN
     (NOT p_alias_val_att_to_match.exists(l_index));
/*
  if g_debug then
     hr_utility.trace('HXC_ALIAS_TRANSLATOR.dump_alias_attribute');
     hr_utility.trace('ATT_CAT:'||p_alias_val_att_to_match(l_index).attribute_category);
     hr_utility.trace('ATT1:'||p_alias_val_att_to_match(l_index).attribute1);
     hr_utility.trace('ATT2:'||p_alias_val_att_to_match(l_index).attribute2);
     hr_utility.trace('ATT3:'||p_alias_val_att_to_match(l_index).attribute3);
     hr_utility.trace('ATT4:'||p_alias_val_att_to_match(l_index).attribute4);
     hr_utility.trace('ATT5:'||p_alias_val_att_to_match(l_index).attribute5);
     hr_utility.trace('ATT6:'||p_alias_val_att_to_match(l_index).attribute6);
     hr_utility.trace('ATT7:'||p_alias_val_att_to_match(l_index).attribute7);
     hr_utility.trace('ATT8:'||p_alias_val_att_to_match(l_index).attribute8);
     hr_utility.trace('ATT9:'||p_alias_val_att_to_match(l_index).attribute9);
     hr_utility.trace('ATT10:'||p_alias_val_att_to_match(l_index).attribute10);
     hr_utility.trace('BLD_BLK_INFO_TYPE:'||p_alias_val_att_to_match(l_index).BLD_BLK_INFO_TYPE);
     hr_utility.trace('BLD_BLK_INFO_TYPE_ID:'||p_alias_val_att_to_match(l_index).BLD_BLK_INFO_TYPE_ID);
     hr_utility.trace('COMPONENT_TYPE:'||p_alias_val_att_to_match(l_index).COMPONENT_TYPE);
     hr_utility.trace('COMPONENT_NAME:'||p_alias_val_att_to_match(l_index).COMPONENT_NAME);
     hr_utility.trace('REFERENCE_OBJECT:'||p_alias_val_att_to_match(l_index).REFERENCE_OBJECT);
 end if;
*/
 if g_debug then
     hr_utility.trace('MAPP:'||p_alias_val_att_to_match(l_index).MAPPING_ATT_CAT);
     hr_utility.trace('SEGMENT:'||p_alias_val_att_to_match(l_index).SEGMENT);
 end if;
/*
     dbms_output.put_line('HXC_ALIAS_TRANSLATOR.dump_alias_attribute');
     dbms_output.put_line('ATT_CAT:'||p_alias_val_att_to_match(l_index).attribute_category);
     dbms_output.put_line('ATT1:'||p_alias_val_att_to_match(l_index).attribute1);
     dbms_output.put_line('ATT2:'||p_alias_val_att_to_match(l_index).attribute2);
     dbms_output.put_line('ATT3:'||p_alias_val_att_to_match(l_index).attribute3);
     dbms_output.put_line('ATT4:'||p_alias_val_att_to_match(l_index).attribute4);
     dbms_output.put_line('ATT5:'||p_alias_val_att_to_match(l_index).attribute5);
     dbms_output.put_line('ATT6:'||p_alias_val_att_to_match(l_index).attribute6);
     dbms_output.put_line('ATT7:'||p_alias_val_att_to_match(l_index).attribute7);
     dbms_output.put_line('ATT8:'||p_alias_val_att_to_match(l_index).attribute8);
     dbms_output.put_line('ATT9:'||p_alias_val_att_to_match(l_index).attribute9);
     dbms_output.put_line('ATT10:'||p_alias_val_att_to_match(l_index).attribute10);
     dbms_output.put_line('BLD_BLK_INFO_TYPE:'||p_alias_val_att_to_match(l_index).BLD_BLK_INFO_TYPE);
     dbms_output.put_line('BLD_BLK_INFO_TYPE_ID:'||p_alias_val_att_to_match(l_index).BLD_BLK_INFO_TYPE_ID);
     dbms_output.put_line('COMPONENT_TYPE:'||p_alias_val_att_to_match(l_index).COMPONENT_TYPE);
     dbms_output.put_line('COMPONENT_NAME:'||p_alias_val_att_to_match(l_index).COMPONENT_NAME);
     dbms_output.put_line('REFERENCE_OBJECT:'||p_alias_val_att_to_match(l_index).REFERENCE_OBJECT);
     dbms_output.put_line('SEGMENT:'||p_alias_val_att_to_match(l_index).SEGMENT);
*/
     l_index := p_alias_val_att_to_match.next(l_index);
   END LOOP;


END dump_alias_val_att_to_match;


-- ---------------------------------------------------------------------
-- |-------------------< dump_bb_attribute_info		>---------------|
-- ---------------------------------------------------------------------
-- | Debug Procedure						        |
-- ---------------------------------------------------------------------
PROCEDURE dump_bb_attribute_info
        (p_attributes in out NOCOPY HXC_ATTRIBUTE_TABLE_TYPE) IS--hxc_self_service_time_deposit.building_block_attribute_info) IS

l_index NUMBER;

BEGIN

   l_index := p_attributes.first;
   g_debug :=hr_utility.debug_enabled;
   LOOP
   EXIT WHEN
     (NOT p_attributes.exists(l_index));

    IF p_attributes(l_index).ATTRIBUTE_CATEGORY <> 'SECURITY' THEN
	    if g_debug then
		    hr_utility.trace('HXC_ALIAS_TRANSLATOR.dump_bb_attribute_info');
		    hr_utility.trace('time_attribute_id:'||p_attributes(l_index).TIME_ATTRIBUTE_ID);
		    hr_utility.trace('index:'||l_index);
		    hr_utility.trace('BBID:'||p_attributes(l_index).BUILDING_BLOCK_ID);
		    hr_utility.trace('BBITYPE:'||p_attributes(l_index).BLD_BLK_INFO_TYPE);
		    hr_utility.trace('BBITYPE_ID:'||p_attributes(l_index).BLD_BLK_INFO_TYPE_ID);
		    hr_utility.trace('ATT_CAT:'||p_attributes(l_index).ATTRIBUTE_CATEGORY);
		    hr_utility.trace('CHANGED :'||p_attributes(l_index).CHANGED);
		    hr_utility.trace('NEW :'||p_attributes(l_index).NEW);
		    hr_utility.trace(' ATT1:'||p_attributes(l_index).ATTRIBUTE1);
		    hr_utility.trace(' ATT2:'||p_attributes(l_index).ATTRIBUTE2);
		    hr_utility.trace(' ATT3:'||p_attributes(l_index).ATTRIBUTE3);
		    hr_utility.trace(' ATT4:'||p_attributes(l_index).ATTRIBUTE4);
		    hr_utility.trace(' ATT5:'||p_attributes(l_index).ATTRIBUTE5);
		    hr_utility.trace(' ATT6:'||p_attributes(l_index).ATTRIBUTE6);
		    hr_utility.trace(' ATT7:'||p_attributes(l_index).ATTRIBUTE7);
		    hr_utility.trace(' ATT8:'||p_attributes(l_index).ATTRIBUTE8);
		    hr_utility.trace(' ATT9:'||p_attributes(l_index).ATTRIBUTE9);
		    hr_utility.trace(' ATT10:'||p_attributes(l_index).ATTRIBUTE10);
		    hr_utility.trace(' ATT11:'||p_attributes(l_index).ATTRIBUTE11);
		    hr_utility.trace(' ATT12:'||p_attributes(l_index).ATTRIBUTE12);
		    hr_utility.trace(' ATT13:'||p_attributes(l_index).ATTRIBUTE13);
		    hr_utility.trace(' ATT14:'||p_attributes(l_index).ATTRIBUTE14);
		    hr_utility.trace(' ATT15:'||p_attributes(l_index).ATTRIBUTE15);
		    hr_utility.trace(' ATT16:'||p_attributes(l_index).ATTRIBUTE16);
		    hr_utility.trace(' ATT17:'||p_attributes(l_index).ATTRIBUTE17);
		    hr_utility.trace(' ATT18:'||p_attributes(l_index).ATTRIBUTE18);
		    hr_utility.trace(' ATT19:'||p_attributes(l_index).ATTRIBUTE19);
		    hr_utility.trace(' ATT20:'||p_attributes(l_index).ATTRIBUTE20);
		    hr_utility.trace(' ATT21:'||p_attributes(l_index).ATTRIBUTE21);
		    hr_utility.trace(' ATT22:'||p_attributes(l_index).ATTRIBUTE22);
		    hr_utility.trace(' ATT23:'||p_attributes(l_index).ATTRIBUTE23);
		    hr_utility.trace(' ATT24:'||p_attributes(l_index).ATTRIBUTE24);
		    hr_utility.trace(' ATT25:'||p_attributes(l_index).ATTRIBUTE25);
		    hr_utility.trace(' ATT26:'||p_attributes(l_index).ATTRIBUTE26);
		    hr_utility.trace(' ATT27:'||p_attributes(l_index).ATTRIBUTE27);
		    hr_utility.trace(' ATT28:'||p_attributes(l_index).ATTRIBUTE28);
		    hr_utility.trace(' ATT29:'||p_attributes(l_index).ATTRIBUTE29);
		    hr_utility.trace(' ATT30:'||p_attributes(l_index).ATTRIBUTE30);
	    end if;
    END IF;

    l_index := p_attributes.next(l_index);

   END LOOP;

END dump_bb_attribute_info;


-- ---------------------------------------------------------------------
-- |-------------------< dump_alias_def_item		>---------------|
-- ---------------------------------------------------------------------
-- | Debug Procedure						        |
-- ---------------------------------------------------------------------
PROCEDURE dump_alias_def_item (p_alias_def_item IN OUT NOCOPY t_alias_def_item) IS

l_index number;

BEGIN
--null;

   l_index := p_alias_def_item.first;
   g_debug := hr_utility.debug_enabled;

   LOOP
   EXIT WHEN
     (NOT p_alias_def_item.exists(l_index));
/*
  if g_debug then
     hr_utility.trace('HXC_ALIAS_TRANSLATOR.dump_alias_attribute');
     hr_utility.trace('ATT_CAT:'||p_alias_val_att_to_match(l_index).attribute_category);
     hr_utility.trace('ATT1:'||p_alias_val_att_to_match(l_index).attribute1);
     hr_utility.trace('ATT2:'||p_alias_val_att_to_match(l_index).attribute2);
     hr_utility.trace('ATT3:'||p_alias_val_att_to_match(l_index).attribute3);
     hr_utility.trace('ATT4:'||p_alias_val_att_to_match(l_index).attribute4);
     hr_utility.trace('ATT5:'||p_alias_val_att_to_match(l_index).attribute5);
     hr_utility.trace('ATT6:'||p_alias_val_att_to_match(l_index).attribute6);
     hr_utility.trace('ATT7:'||p_alias_val_att_to_match(l_index).attribute7);
     hr_utility.trace('ATT8:'||p_alias_val_att_to_match(l_index).attribute8);
     hr_utility.trace('ATT9:'||p_alias_val_att_to_match(l_index).attribute9);
     hr_utility.trace('ATT10:'||p_alias_val_att_to_match(l_index).attribute10);
     hr_utility.trace('BLD_BLK_INFO_TYPE:'||p_alias_val_att_to_match(l_index).BLD_BLK_INFO_TYPE);
     hr_utility.trace('BLD_BLK_INFO_TYPE_ID:'||p_alias_val_att_to_match(l_index).BLD_BLK_INFO_TYPE_ID);
     hr_utility.trace('COMPONENT_TYPE:'||p_alias_val_att_to_match(l_index).COMPONENT_TYPE);
     hr_utility.trace('COMPONENT_NAME:'||p_alias_val_att_to_match(l_index).COMPONENT_NAME);
     hr_utility.trace('REFERENCE_OBJECT:'||p_alias_val_att_to_match(l_index).REFERENCE_OBJECT);
     hr_utility.trace('SEGMENT:'||p_alias_val_att_to_match(l_index).SEGMENT);
  end if;
*/
  if g_debug then
     hr_utility.trace('HXC_ALIAS_TRANSLATOR.dump_alias_def_item');
     hr_utility.trace('ATT_DEF_ID: '||p_alias_def_item(l_index).ALIAS_DEFINITION_ID);
     hr_utility.trace('ATT_CATEGORY: '||p_alias_def_item(l_index).ITEM_ATTRIBUTE_CATEGORY);
     hr_utility.trace('LAYOUT_ID: '||p_alias_def_item(l_index).LAYOUT_ID);
  end if;

     l_index := p_alias_def_item.next(l_index);
   END LOOP;


END dump_alias_def_item;

----------------------------------------------------------------------------------
--- TEMPORARY FUNCTION
----------------------------------------------------------------------------------

--
-- USE IN SS....NEED TO ASK ANDREW
--
PROCEDURE alias_def_comma_list(p_alias_type IN VARCHAR2
        	              ,p_start_time IN VARCHAR2
	                      ,p_stop_time  IN VARCHAR2
			      ,p_resource_id IN NUMBER
			      ,p_alias_def_comma OUT NOCOPY VARCHAR2)
			      IS


l_alias_def_comma 	VARCHAR2(80) := null;
l_alias_definition 	t_alias_def_item;
l_index 		NUMBER;

BEGIN
     IF(1>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     fnd_log.string(1
               	,'HXC_ALIAS_UTILITY.alias_def_comma_list'
                ,'p_alias_type:'||p_alias_type||
                ' p_start_time:'||p_start_time||
                ' p_stop_time :'||p_stop_time||
                ' p_resource_id:'||p_resource_id);
      END IF;


	l_alias_definition:=
	 		get_list_alias_id
	 		  (p_alias_type => p_alias_type
                    	  ,p_start_time => p_start_time
                     	  ,p_stop_time  => p_stop_time
                     	  ,p_resource_id => to_number(p_resource_id));


l_index := l_alias_definition.FIRST;
LOOP
  EXIT WHEN
     (NOT l_alias_definition.exists(l_index));
     IF (l_alias_definition(l_index).ALIAS_DEFINITION_ID is not null) THEN

     	IF (l_index = l_alias_definition.FIRST) THEN
     		l_alias_def_comma := ','||l_alias_definition(l_index).ALIAS_DEFINITION_ID;

          IF(1>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   	  fnd_log.string(1
               	,'HXC_ALIAS_UTILITY.alias_def_comma_list'
                ,'l_alias_def_comma1:'||l_alias_def_comma);
          END IF;
     	ELSE
     		l_alias_def_comma := l_alias_def_comma||','||l_alias_definition(l_index).ALIAS_DEFINITION_ID;
         IF(1>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   	  fnd_log.string(1
               	,'HXC_ALIAS_UTILITY.alias_def_comma_list'
                ,'l_alias_def_comma2:'||l_alias_def_comma);
          END IF;
     	END IF;
     END IF;

     l_index := l_alias_definition.next(l_index);

END LOOP;

     l_alias_def_comma := l_alias_def_comma||',';
     IF(1>=FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     fnd_log.string(1
               	,'HXC_ALIAS_UTILITY.alias_def_comma_list'
                ,'l_alias_def_comma3:'||l_alias_def_comma);
     END IF;

p_alias_def_comma := l_alias_def_comma;


/*
l_alias_def_comma 	VARCHAR2(80) := null;
l_alternate_name_index	NUMBER;

l_pref_index		NUMBER;
l_pref_table      	hxc_preference_evaluation.t_pref_table;

l_alias_type 		hxc_alias_types.alias_type%TYPE;
l_reference_object	hxc_alias_types.reference_object%TYPE;
l_prompt		hxc_alias_definitions_tl.prompt%TYPE;


BEGIN

fnd_log.string(1
               	,'HXC_ALIAS_UTILITY.alias_def_comma_list'
                ,'p_alias_type:'||p_alias_type||
                ' p_start_time:'||p_start_time||
                ' p_stop_time :'||p_stop_time||
                ' p_resource_id:'||p_resource_id);


-- we are calling the preference now for the resource
hxc_preference_evaluation.resource_preferences(
   p_resource_id           => p_resource_id ,
   p_start_evaluation_date => FND_DATE.CANONICAL_TO_DATE(p_start_time),
   p_end_evaluation_date   => FND_DATE.CANONICAL_TO_DATE(p_stop_time),
   p_pref_table            => l_pref_table);

-- find the index of the alternate name preference and
-- we are taking care in the case of a null layout
l_pref_index :=l_pref_table.FIRST;

LOOP
  EXIT WHEN
     (NOT l_pref_table.exists(l_pref_index));

    IF(l_pref_table(l_pref_index).preference_code = 'TC_W_TCRD_ALIASES') THEN
      l_alternate_name_index := l_pref_index;
      exit;
    END IF;

    l_pref_index := l_pref_table.next(l_pref_index);

END LOOP;


IF l_pref_table(l_alternate_name_index).ATTRIBUTE1 is not null THEN

   get_alias_definition_info
      (to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE1),
       l_alias_type,
       l_reference_object,
       l_prompt);

   IF p_alias_type = l_reference_object THEN
      -- not sure we need put the ',' anymore
      p_alias_def_comma := ','||l_pref_table(l_alternate_name_index).ATTRIBUTE1;
      RETURN;
   END IF;

END IF;

IF l_pref_table(l_alternate_name_index).ATTRIBUTE2 is not null THEN

   get_alias_definition_info
      (to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE2),
       l_alias_type,
       l_reference_object,
       l_prompt);

   IF p_alias_type = l_reference_object THEN
      -- not sure we need put the ',' anymore
      p_alias_def_comma := ','||l_pref_table(l_alternate_name_index).ATTRIBUTE2;
      RETURN;
   END IF;

END IF;

IF l_pref_table(l_alternate_name_index).ATTRIBUTE3 is not null THEN

   get_alias_definition_info
      (to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE3),
       l_alias_type,
       l_reference_object,
       l_prompt);

   IF p_alias_type = l_reference_object THEN
      -- not sure we need put the ',' anymore
      p_alias_def_comma := ','||l_pref_table(l_alternate_name_index).ATTRIBUTE3;
      RETURN;
   END IF;

END IF;

IF l_pref_table(l_alternate_name_index).ATTRIBUTE4 is not null THEN

   get_alias_definition_info
      (to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE4),
       l_alias_type,
       l_reference_object,
       l_prompt);

   IF p_alias_type = l_reference_object THEN
      -- not sure we need put the ',' anymore
      p_alias_def_comma := ','||l_pref_table(l_alternate_name_index).ATTRIBUTE4;
      RETURN;
   END IF;

END IF;

IF l_pref_table(l_alternate_name_index).ATTRIBUTE5 is not null THEN

   get_alias_definition_info
      (to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE5),
       l_alias_type,
       l_reference_object,
       l_prompt);

   IF p_alias_type = l_reference_object THEN
      -- not sure we need put the ',' anymore
      p_alias_def_comma := ','||l_pref_table(l_alternate_name_index).ATTRIBUTE5;
      RETURN;
   END IF;

END IF;

IF l_pref_table(l_alternate_name_index).ATTRIBUTE6 is not null THEN

   get_alias_definition_info
      (to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE6),
       l_alias_type,
       l_reference_object,
       l_prompt);

   IF p_alias_type = l_reference_object THEN
      -- not sure we need put the ',' anymore
      p_alias_def_comma := ','||l_pref_table(l_alternate_name_index).ATTRIBUTE6;
      RETURN;
   END IF;

END IF;

IF l_pref_table(l_alternate_name_index).ATTRIBUTE7 is not null THEN

   get_alias_definition_info
      (to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE7),
       l_alias_type,
       l_reference_object,
       l_prompt);

   IF p_alias_type = l_reference_object THEN
      -- not sure we need put the ',' anymore
      p_alias_def_comma := ','||l_pref_table(l_alternate_name_index).ATTRIBUTE7;
      RETURN;
   END IF;

END IF;

IF l_pref_table(l_alternate_name_index).ATTRIBUTE8 is not null THEN

   get_alias_definition_info
      (to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE8),
       l_alias_type,
       l_reference_object,
       l_prompt);

   IF p_alias_type = l_reference_object THEN
      -- not sure we need put the ',' anymore
      p_alias_def_comma := ','||l_pref_table(l_alternate_name_index).ATTRIBUTE8;
      RETURN;
   END IF;

END IF;

IF l_pref_table(l_alternate_name_index).ATTRIBUTE9 is not null THEN

   get_alias_definition_info
      (to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE9),
       l_alias_type,
       l_reference_object,
       l_prompt);

   IF p_alias_type = l_reference_object THEN
      -- not sure we need put the ',' anymore
      p_alias_def_comma := ','||l_pref_table(l_alternate_name_index).ATTRIBUTE9;
      RETURN;
   END IF;

END IF;

IF l_pref_table(l_alternate_name_index).ATTRIBUTE10 is not null THEN

   get_alias_definition_info
      (to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE10),
       l_alias_type,
       l_reference_object,
       l_prompt);

   IF p_alias_type = l_reference_object THEN
      -- not sure we need put the ',' anymore
      p_alias_def_comma := ','||l_pref_table(l_alternate_name_index).ATTRIBUTE10;
      RETURN;
   END IF;

END IF;

IF l_pref_table(l_alternate_name_index).ATTRIBUTE11 is not null THEN

   get_alias_definition_info
      (to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE11),
       l_alias_type,
       l_reference_object,
       l_prompt);

   IF p_alias_type = l_reference_object THEN
      -- not sure we need put the ',' anymore
      p_alias_def_comma := ','||l_pref_table(l_alternate_name_index).ATTRIBUTE11;
      RETURN;
   END IF;

END IF;

IF l_pref_table(l_alternate_name_index).ATTRIBUTE12 is not null THEN

   get_alias_definition_info
      (to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE12),
       l_alias_type,
       l_reference_object,
       l_prompt);

   IF p_alias_type = l_reference_object THEN
      -- not sure we need put the ',' anymore
      p_alias_def_comma := ','||l_pref_table(l_alternate_name_index).ATTRIBUTE12;
      RETURN;
   END IF;

END IF;

IF l_pref_table(l_alternate_name_index).ATTRIBUTE13 is not null THEN

   get_alias_definition_info
      (to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE13),
       l_alias_type,
       l_reference_object,
       l_prompt);

   IF p_alias_type = l_reference_object THEN
      -- not sure we need put the ',' anymore
      p_alias_def_comma := ','||l_pref_table(l_alternate_name_index).ATTRIBUTE13;
      RETURN;
   END IF;

END IF;

IF l_pref_table(l_alternate_name_index).ATTRIBUTE14 is not null THEN

   get_alias_definition_info
      (to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE14),
       l_alias_type,
       l_reference_object,
       l_prompt);

   IF p_alias_type = l_reference_object THEN
      -- not sure we need put the ',' anymore
      p_alias_def_comma := ','||l_pref_table(l_alternate_name_index).ATTRIBUTE14;
      RETURN;
   END IF;

END IF;

IF l_pref_table(l_alternate_name_index).ATTRIBUTE15 is not null THEN

   get_alias_definition_info
      (to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE15),
       l_alias_type,
       l_reference_object,
       l_prompt);

   IF p_alias_type = l_reference_object THEN
      -- not sure we need put the ',' anymore
      p_alias_def_comma := ','||l_pref_table(l_alternate_name_index).ATTRIBUTE15;
      RETURN;
   END IF;

END IF;

IF l_pref_table(l_alternate_name_index).ATTRIBUTE16 is not null THEN

   get_alias_definition_info
      (to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE16),
       l_alias_type,
       l_reference_object,
       l_prompt);

   IF p_alias_type = l_reference_object THEN
      -- not sure we need put the ',' anymore
      p_alias_def_comma := ','||l_pref_table(l_alternate_name_index).ATTRIBUTE16;
      RETURN;
   END IF;

END IF;

IF l_pref_table(l_alternate_name_index).ATTRIBUTE17 is not null THEN

   get_alias_definition_info
      (to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE17),
       l_alias_type,
       l_reference_object,
       l_prompt);

   IF p_alias_type = l_reference_object THEN
      -- not sure we need put the ',' anymore
      p_alias_def_comma := ','||l_pref_table(l_alternate_name_index).ATTRIBUTE17;
      RETURN;
   END IF;

END IF;

IF l_pref_table(l_alternate_name_index).ATTRIBUTE18 is not null THEN

   get_alias_definition_info
      (to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE18),
       l_alias_type,
       l_reference_object,
       l_prompt);

   IF p_alias_type = l_reference_object THEN
      -- not sure we need put the ',' anymore
      p_alias_def_comma := ','||l_pref_table(l_alternate_name_index).ATTRIBUTE18;
      RETURN;
   END IF;

END IF;

IF l_pref_table(l_alternate_name_index).ATTRIBUTE19 is not null THEN

   get_alias_definition_info
      (to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE19),
       l_alias_type,
       l_reference_object,
       l_prompt);

   IF p_alias_type = l_reference_object THEN
      -- not sure we need put the ',' anymore
      p_alias_def_comma := ','||l_pref_table(l_alternate_name_index).ATTRIBUTE19;
      RETURN;
   END IF;

END IF;
IF l_pref_table(l_alternate_name_index).ATTRIBUTE20 is not null THEN

   get_alias_definition_info
      (to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE20),
       l_alias_type,
       l_reference_object,
       l_prompt);

   IF p_alias_type = l_reference_object THEN
      -- not sure we need put the ',' anymore
      p_alias_def_comma := ','||l_pref_table(l_alternate_name_index).ATTRIBUTE20;
      RETURN;
   END IF;

END IF;

IF l_pref_table(l_alternate_name_index).ATTRIBUTE21 is not null THEN

   get_alias_definition_info
      (to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE21),
       l_alias_type,
       l_reference_object,
       l_prompt);

   IF p_alias_type = l_reference_object THEN
      -- not sure we need put the ',' anymore
      p_alias_def_comma := ','||l_pref_table(l_alternate_name_index).ATTRIBUTE21;
      RETURN;
   END IF;

END IF;


IF l_pref_table(l_alternate_name_index).ATTRIBUTE22 is not null THEN

   get_alias_definition_info
      (to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE22),
       l_alias_type,
       l_reference_object,
       l_prompt);

   IF p_alias_type = l_reference_object THEN
      -- not sure we need put the ',' anymore
      p_alias_def_comma := ','||l_pref_table(l_alternate_name_index).ATTRIBUTE22;
      RETURN;
   END IF;

END IF;

IF l_pref_table(l_alternate_name_index).ATTRIBUTE23 is not null THEN

   get_alias_definition_info
      (to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE23),
       l_alias_type,
       l_reference_object,
       l_prompt);

   IF p_alias_type = l_reference_object THEN
      -- not sure we need put the ',' anymore
      p_alias_def_comma := ','||l_pref_table(l_alternate_name_index).ATTRIBUTE23;
      RETURN;
   END IF;

END IF;

IF l_pref_table(l_alternate_name_index).ATTRIBUTE24 is not null THEN

   get_alias_definition_info
      (to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE24),
       l_alias_type,
       l_reference_object,
       l_prompt);

   IF p_alias_type = l_reference_object THEN
      -- not sure we need put the ',' anymore
      p_alias_def_comma := ','||l_pref_table(l_alternate_name_index).ATTRIBUTE24;
      RETURN;
   END IF;

END IF;

IF l_pref_table(l_alternate_name_index).ATTRIBUTE25 is not null THEN

   get_alias_definition_info
      (to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE25),
       l_alias_type,
       l_reference_object,
       l_prompt);

   IF p_alias_type = l_reference_object THEN
      -- not sure we need put the ',' anymore
      p_alias_def_comma := ','||l_pref_table(l_alternate_name_index).ATTRIBUTE25;
      RETURN;
   END IF;

END IF;

IF l_pref_table(l_alternate_name_index).ATTRIBUTE26 is not null THEN

   get_alias_definition_info
      (to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE26),
       l_alias_type,
       l_reference_object,
       l_prompt);

   IF p_alias_type = l_reference_object THEN
      -- not sure we need put the ',' anymore
      p_alias_def_comma := ','||l_pref_table(l_alternate_name_index).ATTRIBUTE26;
      RETURN;
   END IF;

END IF;

IF l_pref_table(l_alternate_name_index).ATTRIBUTE27 is not null THEN

   get_alias_definition_info
      (to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE27),
       l_alias_type,
       l_reference_object,
       l_prompt);

   IF p_alias_type = l_reference_object THEN
      -- not sure we need put the ',' anymore
      p_alias_def_comma := ','||l_pref_table(l_alternate_name_index).ATTRIBUTE27;
      RETURN;
   END IF;

END IF;

IF l_pref_table(l_alternate_name_index).ATTRIBUTE28 is not null THEN

   get_alias_definition_info
      (to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE28),
       l_alias_type,
       l_reference_object,
       l_prompt);

   IF p_alias_type = l_reference_object THEN
      -- not sure we need put the ',' anymore
      p_alias_def_comma := ','||l_pref_table(l_alternate_name_index).ATTRIBUTE28;
      RETURN;
   END IF;

END IF;

IF l_pref_table(l_alternate_name_index).ATTRIBUTE29 is not null THEN

   get_alias_definition_info
      (to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE29),
       l_alias_type,
       l_reference_object,
       l_prompt);

   IF p_alias_type = l_reference_object THEN
      -- not sure we need put the ',' anymore
      p_alias_def_comma := ','||l_pref_table(l_alternate_name_index).ATTRIBUTE29;
      RETURN;
   END IF;

END IF;

IF l_pref_table(l_alternate_name_index).ATTRIBUTE30 is not null THEN

   get_alias_definition_info
      (to_number(l_pref_table(l_alternate_name_index).ATTRIBUTE30),
       l_alias_type,
       l_reference_object,
       l_prompt);

   IF p_alias_type = l_reference_object THEN
      -- not sure we need put the ',' anymore
      p_alias_def_comma := ','||l_pref_table(l_alternate_name_index).ATTRIBUTE30;
      RETURN;
   END IF;

END IF;

*/
END alias_def_comma_list;

--
-- This function is still used in the deposit wrapper utilities
-- NEED TO SPEAK WITH ANDY.
--
FUNCTION get_list_alias_id(p_alias_type IN VARCHAR2
                    	  ,p_start_time IN VARCHAR2
                     	  ,p_stop_time  IN VARCHAR2
                     	  ,p_resource_id IN NUMBER) RETURN t_alias_def_item IS


l_pref_table      	hxc_preference_evaluation.t_pref_table;
l_alias_definition 	t_alias_def_item;
l_index 		NUMBER;
l_pref_value 		t_alias_def_item;
l_index_pref_val	NUMBER;
l_alias_index 		NUMBER := 1;
l_alias_type 		VARCHAR2(80);
l_found 		BOOLEAN := FALSE;

BEGIN
/*
fnd_log.string(1
               	,'HXC_ALIAS_UTILITY.get_list_alias_id'
                ,'arrived:');

fnd_log.string(1
               	,'HXC_ALIAS_UTILITY.get_list_alias_id'
                ,'p_alias_type:'||p_alias_type||
                ' p_start_time:'||p_start_time||
                ' p_stop_time :'||p_stop_time||
                ' p_resource_id:'||p_resource_id);
*/
l_pref_table.DELETE;

hxc_preference_evaluation.resource_preferences(
	    p_resource_id           => p_resource_id ,
    	    p_start_evaluation_date => FND_DATE.CANONICAL_TO_DATE(p_start_time),
    	    p_end_evaluation_date   => FND_DATE.CANONICAL_TO_DATE(p_stop_time),
    	    p_pref_table            => l_pref_table);

l_index:=l_pref_table.FIRST;
/*
fnd_log.string(1
               	,'HXC_ALIAS_UTILITY.get_list_alias_id'
                ,'passed the pref :');
*/

LOOP
  EXIT WHEN
     (NOT l_pref_table.exists(l_index));

    IF(l_pref_table(l_index).preference_code = 'TC_W_TCRD_ALIASES') then

        l_index_pref_val := 1;
        l_pref_value.delete;

        l_pref_value(l_index_pref_val).ALIAS_DEFINITION_ID := l_pref_table(l_index).attribute1;
        l_index_pref_val := l_index_pref_val + 1;
        l_pref_value(l_index_pref_val).ALIAS_DEFINITION_ID := l_pref_table(l_index).attribute2;
        l_index_pref_val := l_index_pref_val + 1;
        l_pref_value(l_index_pref_val).ALIAS_DEFINITION_ID := l_pref_table(l_index).attribute3;
        l_index_pref_val := l_index_pref_val + 1;
        l_pref_value(l_index_pref_val).ALIAS_DEFINITION_ID := l_pref_table(l_index).attribute4;
        l_index_pref_val := l_index_pref_val + 1;
        l_pref_value(l_index_pref_val).ALIAS_DEFINITION_ID := l_pref_table(l_index).attribute5;
        l_index_pref_val := l_index_pref_val + 1;
        l_pref_value(l_index_pref_val).ALIAS_DEFINITION_ID := l_pref_table(l_index).attribute6;
        l_index_pref_val := l_index_pref_val + 1;
        l_pref_value(l_index_pref_val).ALIAS_DEFINITION_ID := l_pref_table(l_index).attribute7;
        l_index_pref_val := l_index_pref_val + 1;
        l_pref_value(l_index_pref_val).ALIAS_DEFINITION_ID := l_pref_table(l_index).attribute8;
        l_index_pref_val := l_index_pref_val + 1;
        l_pref_value(l_index_pref_val).ALIAS_DEFINITION_ID := l_pref_table(l_index).attribute9;
        l_index_pref_val := l_index_pref_val + 1;
        l_pref_value(l_index_pref_val).ALIAS_DEFINITION_ID := l_pref_table(l_index).attribute10;
        l_index_pref_val := l_index_pref_val + 1;
        l_pref_value(l_index_pref_val).ALIAS_DEFINITION_ID := l_pref_table(l_index).attribute11;
        l_index_pref_val := l_index_pref_val + 1;
        l_pref_value(l_index_pref_val).ALIAS_DEFINITION_ID := l_pref_table(l_index).attribute12;
        l_index_pref_val := l_index_pref_val + 1;
        l_pref_value(l_index_pref_val).ALIAS_DEFINITION_ID := l_pref_table(l_index).attribute13;
        l_index_pref_val := l_index_pref_val + 1;
        l_pref_value(l_index_pref_val).ALIAS_DEFINITION_ID := l_pref_table(l_index).attribute14;
        l_index_pref_val := l_index_pref_val + 1;
        l_pref_value(l_index_pref_val).ALIAS_DEFINITION_ID := l_pref_table(l_index).attribute15;
        l_index_pref_val := l_index_pref_val + 1;
        l_pref_value(l_index_pref_val).ALIAS_DEFINITION_ID := l_pref_table(l_index).attribute16;
        l_index_pref_val := l_index_pref_val + 1;
        l_pref_value(l_index_pref_val).ALIAS_DEFINITION_ID := l_pref_table(l_index).attribute17;
        l_index_pref_val := l_index_pref_val + 1;
        l_pref_value(l_index_pref_val).ALIAS_DEFINITION_ID := l_pref_table(l_index).attribute18;
        l_index_pref_val := l_index_pref_val + 1;
        l_pref_value(l_index_pref_val).ALIAS_DEFINITION_ID := l_pref_table(l_index).attribute19;
        l_index_pref_val := l_index_pref_val + 1;
        l_pref_value(l_index_pref_val).ALIAS_DEFINITION_ID := l_pref_table(l_index).attribute20;
        l_index_pref_val := l_index_pref_val + 1;
        l_pref_value(l_index_pref_val).ALIAS_DEFINITION_ID := l_pref_table(l_index).attribute21;
        l_index_pref_val := l_index_pref_val + 1;
        l_pref_value(l_index_pref_val).ALIAS_DEFINITION_ID := l_pref_table(l_index).attribute22;
        l_index_pref_val := l_index_pref_val + 1;
        l_pref_value(l_index_pref_val).ALIAS_DEFINITION_ID := l_pref_table(l_index).attribute23;
        l_index_pref_val := l_index_pref_val + 1;
        l_pref_value(l_index_pref_val).ALIAS_DEFINITION_ID := l_pref_table(l_index).attribute24;
        l_index_pref_val := l_index_pref_val + 1;
        l_pref_value(l_index_pref_val).ALIAS_DEFINITION_ID := l_pref_table(l_index).attribute25;
        l_index_pref_val := l_index_pref_val + 1;
        l_pref_value(l_index_pref_val).ALIAS_DEFINITION_ID := l_pref_table(l_index).attribute26;
        l_index_pref_val := l_index_pref_val + 1;
        l_pref_value(l_index_pref_val).ALIAS_DEFINITION_ID := l_pref_table(l_index).attribute27;
        l_index_pref_val := l_index_pref_val + 1;
        l_pref_value(l_index_pref_val).ALIAS_DEFINITION_ID := l_pref_table(l_index).attribute28;
        l_index_pref_val := l_index_pref_val + 1;
        l_pref_value(l_index_pref_val).ALIAS_DEFINITION_ID := l_pref_table(l_index).attribute29;
        l_index_pref_val := l_index_pref_val + 1;
        l_pref_value(l_index_pref_val).ALIAS_DEFINITION_ID := l_pref_table(l_index).attribute30;
        l_index_pref_val := l_index_pref_val + 1;

    	--fnd_log.string(1
        --       	,'HXC_ALIAS_UTILITY.get_list_alias_id'
        --        ,'l_index_pref_val1:'||l_index_pref_val);

        l_index_pref_val := l_pref_value.first;

    	--fnd_log.string(1
        --       	,'HXC_ALIAS_UTILITY.get_list_alias_id'
        --        ,'l_index_pref_val2:'||l_index_pref_val);


	LOOP
  	EXIT WHEN
     	 (NOT l_pref_value.exists(l_index_pref_val));

     	  IF (l_pref_value(l_index_pref_val).ALIAS_DEFINITION_ID is not null) THEN

	     	--fnd_log.string(1
               	--,'HXC_ALIAS_UTILITY.get_list_alias_id'
                --,'l_pref_value(l_index_pref_val).ALIAS_DEFINITION_ID :'||
                --	l_pref_value(l_index_pref_val).ALIAS_DEFINITION_ID);


		select reference_object
  		into l_alias_type
		from hxc_alias_definitions had,hxc_alias_types hat
		where hat.alias_type_id =had.alias_type_id
		and alias_definition_id =
  			l_pref_value(l_index_pref_val).ALIAS_DEFINITION_ID;

	     	--fnd_log.string(1
               	--,'HXC_ALIAS_UTILITY.get_list_alias_id'
                --,'l_alias_type:'||l_alias_type||
                --' p_alias_type:'||p_alias_type);


		IF l_alias_type = p_alias_type THEN
		-- add into the list
			l_alias_definition(l_alias_index).ALIAS_DEFINITION_ID :=
				l_pref_value(l_index_pref_val).ALIAS_DEFINITION_ID;
			l_alias_definition(l_alias_index).PREF_START_DATE :=
				l_pref_table(l_index).START_DATE;
			l_alias_definition(l_alias_index).PREF_END_DATE :=
				l_pref_table(l_index).END_DATE;
			l_alias_index := l_alias_index + 1;
			l_found := true;
		     	--fnd_log.string(1
        	       	--,'HXC_ALIAS_UTILITY.get_list_alias_id'
                	--,'l_pref_value(l_index_pref_val).ALIAS_DEFINITION_ID'||
                	--	l_pref_value(l_index_pref_val).ALIAS_DEFINITION_ID||
                	--' l_alias_definition(l_alias_index).START_DATE'||
                	--	l_pref_table(l_index).START_DATE);


		END IF;
	   END IF;

           l_index_pref_val := l_pref_value.next(l_index_pref_val);

	 END LOOP;

    END IF;

    l_index := l_pref_table.next(l_index);

END LOOP;

--IF not(l_found) THEN
--  fnd_message.set_name('HXC', 'HXC_ALIAS_DEF_NOT_FOUND');
--  fnd_msg_pub.add;
--END IF;

return l_alias_definition;

END get_list_alias_id;

-- USE IN TK
-- NEED TO SPEAK WITH NITIN
-- ----------------------------------------------------------------------------
-- |---------------------------< get_bld_blk_type_id      >--------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_bld_blk_type_id(p_type IN varchar2) RETURN NUMBER IS

CURSOR csr_bld_blk_id(p_type IN varchar2) IS
  SELECT bld_blk_info_type_id
    FROM hxc_bld_blk_info_types
   WHERE bld_blk_info_type = p_type;

l_type_id NUMBER;

BEGIN

    OPEN csr_bld_blk_id(p_type);
    FETCH csr_bld_blk_id INTO l_type_id;

    IF csr_bld_blk_id%NOTFOUND THEN
      CLOSE csr_bld_blk_id;
      FND_MESSAGE.SET_NAME('HXC','HXC_NO_BLD_BLK_TYPE_ID');
      fnd_msg_pub.add;

    END IF;

    CLOSE csr_bld_blk_id;

RETURN l_type_id;

  EXCEPTION
  WHEN OTHERS THEN
      fnd_message.set_name('HXC', 'HXC_ALIAS_EXCEPTION');
      fnd_msg_pub.add;



END get_bld_blk_type_id;

---
/*
Function convert_attribute_to_type
          (p_attributes in HXC_SELF_SERVICE_TIME_DEPOSIT.building_block_attribute_info)
          return HXC_ATTRIBUTE_TABLE_TYPE is

l_attributes HXC_ATTRIBUTE_TABLE_TYPE;--hxc_self_service_time_deposit.building_block_attribute_info;
l_index      NUMBER;

Begin

-- Initialize the collection

l_attributes := HXC_ATTRIBUTE_TABLE_TYPE();

l_index := p_attributes.first;

LOOP

  EXIT WHEN NOT p_attributes.exists(l_index);

  l_attributes.extend;

  l_attributes(l_attributes.last) :=
    HXC_ATTRIBUTE_TYPE
       (p_attributes(l_index).TIME_ATTRIBUTE_ID
       ,p_attributes(l_index).BUILDING_BLOCK_ID
       ,p_attributes(l_index).ATTRIBUTE_CATEGORY
       ,p_attributes(l_index).ATTRIBUTE1
       ,p_attributes(l_index).ATTRIBUTE2
       ,p_attributes(l_index).ATTRIBUTE3
       ,p_attributes(l_index).ATTRIBUTE4
       ,p_attributes(l_index).ATTRIBUTE5
       ,p_attributes(l_index).ATTRIBUTE6
       ,p_attributes(l_index).ATTRIBUTE7
       ,p_attributes(l_index).ATTRIBUTE8
       ,p_attributes(l_index).ATTRIBUTE9
       ,p_attributes(l_index).ATTRIBUTE10
       ,p_attributes(l_index).ATTRIBUTE11
       ,p_attributes(l_index).ATTRIBUTE12
       ,p_attributes(l_index).ATTRIBUTE13
       ,p_attributes(l_index).ATTRIBUTE14
       ,p_attributes(l_index).ATTRIBUTE15
       ,p_attributes(l_index).ATTRIBUTE16
       ,p_attributes(l_index).ATTRIBUTE17
       ,p_attributes(l_index).ATTRIBUTE18
       ,p_attributes(l_index).ATTRIBUTE19
       ,p_attributes(l_index).ATTRIBUTE20
       ,p_attributes(l_index).ATTRIBUTE21
       ,p_attributes(l_index).ATTRIBUTE22
       ,p_attributes(l_index).ATTRIBUTE23
       ,p_attributes(l_index).ATTRIBUTE24
       ,p_attributes(l_index).ATTRIBUTE25
       ,p_attributes(l_index).ATTRIBUTE26
       ,p_attributes(l_index).ATTRIBUTE27
       ,p_attributes(l_index).ATTRIBUTE28
       ,p_attributes(l_index).ATTRIBUTE29
       ,p_attributes(l_index).ATTRIBUTE30
       ,p_attributes(l_index).BLD_BLK_INFO_TYPE_ID
       ,p_attributes(l_index).OBJECT_VERSION_NUMBER
       ,p_attributes(l_index).NEW
       ,p_attributes(l_index).CHANGED
       ,p_attributes(l_index).BLD_BLK_INFO_TYPE
       ,'N' -- New process flag
       ,null -- building block ovn
       );

  l_index := p_attributes.next(l_index);

END LOOP;

return l_attributes;

End convert_attribute_to_type;


Function convert_timecard_to_type
          (p_blocks in HXC_SELF_SERVICE_TIME_DEPOSIT.timecard_info)
          return HXC_BLOCK_TABLE_TYPE is

l_blocks HXC_BLOCK_TABLE_TYPE;
l_index      NUMBER;


BEGIN

-- Initialize the collection

l_blocks := HXC_BLOCK_TABLE_TYPE();

l_index := p_blocks.first;

LOOP

  EXIT WHEN NOT p_blocks.exists(l_index);

  l_blocks.extend;

  l_blocks(l_blocks.last) :=
    HXC_BLOCK_TYPE
       (p_blocks(l_index).TIME_BUILDING_BLOCK_ID
       ,p_blocks(l_index).TYPE
       ,p_blocks(l_index).MEASURE
       ,p_blocks(l_index).UNIT_OF_MEASURE
       ,p_blocks(l_index).START_TIME
       ,p_blocks(l_index).STOP_TIME
       ,p_blocks(l_index).PARENT_BUILDING_BLOCK_ID
       ,p_blocks(l_index).PARENT_IS_NEW
       ,p_blocks(l_index).SCOPE
       ,p_blocks(l_index).OBJECT_VERSION_NUMBER
       ,p_blocks(l_index).APPROVAL_STATUS
       ,p_blocks(l_index).RESOURCE_ID
       ,p_blocks(l_index).RESOURCE_TYPE
       ,p_blocks(l_index).APPROVAL_STYLE_ID
       ,p_blocks(l_index).DATE_FROM
       ,p_blocks(l_index).DATE_TO
       ,p_blocks(l_index).COMMENT_TEXT
       ,p_blocks(l_index).PARENT_BUILDING_BLOCK_OVN
       ,p_blocks(l_index).NEW
       ,p_blocks(l_index).CHANGED
       ,NULL
       ,NULL
       );

  l_index := p_blocks.next(l_index);

END LOOP;

return l_blocks;

End convert_timecard_to_type;

*/
PROCEDURE get_translated_detail (p_detail_bb_id  in NUMBER,
                                 p_detail_bb_ovn in NUMBER,
                                 p_resource_id   in NUMBER,
                                 p_attributes OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE,
                                 p_messages   IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE)
                                 IS

cursor crs_tbb is
select
 timecard.TIME_BUILDING_BLOCK_ID 	tc_TIME_BUILDING_BLOCK_ID
,timecard.START_TIME 			tc_START_TIME
,timecard.STOP_TIME 			tc_STOP_TIME
,timecard.PARENT_BUILDING_BLOCK_ID 	tc_PARENT_BUILDING_BLOCK_ID
,timecard.PARENT_BUILDING_BLOCK_OVN 	tc_PARENT_BUILDING_BLOCK_OVN
,timecard.SCOPE 			tc_SCOPE
,timecard.OBJECT_VERSION_NUMBER		tc_OBJECT_VERSION_NUMBER
,day.TIME_BUILDING_BLOCK_ID 		day_TIME_BUILDING_BLOCK_ID
,day.START_TIME 			day_START_TIME
,day.STOP_TIME 				day_STOP_TIME
,day.PARENT_BUILDING_BLOCK_ID 		day_PARENT_BUILDING_BLOCK_ID
,day.PARENT_BUILDING_BLOCK_OVN 		day_PARENT_BUILDING_BLOCK_OVN
,day.SCOPE 				day_SCOPE
,day.OBJECT_VERSION_NUMBER 		day_OBJECT_VERSION_NUMBER
,detail.TIME_BUILDING_BLOCK_ID 		detail_TIME_BUILDING_BLOCK_ID
,detail.START_TIME 			detail_START_TIME
,detail.STOP_TIME 			detail_STOP_TIME
,detail.PARENT_BUILDING_BLOCK_ID 	detail_PARENT_BB_ID
,detail.PARENT_BUILDING_BLOCK_OVN 	detail_PARENT_BB_OVN
,detail.SCOPE 				detail_SCOPE
,detail.OBJECT_VERSION_NUMBER 		detail_OBJECT_VERSION_NUMBER
FROM hxc_time_building_blocks timecard,
     hxc_time_building_blocks day,
     hxc_time_building_blocks detail
where detail.time_building_block_id = p_detail_bb_id
and   detail.object_version_number  = p_detail_bb_ovn
and   detail.resource_id = p_resource_id
and   detail.scope = 'DETAIL'
and   day.scope = 'DAY'
and   day.resource_id = p_resource_id
and   detail.parent_building_block_id = day.time_building_block_id
and   detail.parent_building_block_ovn = day.object_version_number
and   timecard.scope = 'TIMECARD'
and   timecard.resource_id = p_resource_id
and   day.parent_building_block_id = timecard.time_building_block_id
and   day.parent_building_block_ovn = timecard.object_version_number;

cursor crs_timecard_attribute
(p_timecard_id in number,p_timecard_ovn in number) is
select
 a.time_attribute_id
,au.time_building_block_id
,bbit.bld_blk_info_type
,a.attribute_category
,a.attribute1
,a.attribute2
,a.attribute3
,a.attribute4
,a.attribute5
,a.attribute6
,a.attribute7
,a.attribute8
,a.attribute9
,a.attribute10
,a.attribute11
,a.attribute12
,a.attribute13
,a.attribute14
,a.attribute15
,a.attribute16
,a.attribute17
,a.attribute18
,a.attribute19
,a.attribute20
,a.attribute21
,a.attribute22
,a.attribute23
,a.attribute24
,a.attribute25
,a.attribute26
,a.attribute27
,a.attribute28
,a.attribute29
,a.attribute30
,a.bld_blk_info_type_id
,a.object_version_number
,'N' NEW
,'N' CHANGED
,'N' PROCESS
,au.time_building_block_ovn BUILDING_BLOCK_OVN
from hxc_bld_blk_info_types bbit,
hxc_time_attribute_usages au,
hxc_time_attributes a,
hxc_time_building_blocks htbb
where 	a.time_attribute_id         = au.time_attribute_id
and	a.bld_blk_info_type_id	    = bbit.bld_blk_info_type_id
and  au.time_building_block_id = htbb.time_building_block_id
and  au.time_building_block_ovn = htbb.object_version_number
and  htbb.scope			= 'TIMECARD'
and  htbb.time_building_block_id     = p_timecard_id
and  htbb.object_version_number      = p_timecard_ovn
and  htbb.resource_id		     = p_resource_id;


cursor crs_detail_attribute
IS
select
 a.time_attribute_id
,au.time_building_block_id
,bbit.bld_blk_info_type
,a.attribute_category
,a.attribute1
,a.attribute2
,a.attribute3
,a.attribute4
,a.attribute5
,a.attribute6
,a.attribute7
,a.attribute8
,a.attribute9
,a.attribute10
,a.attribute11
,a.attribute12
,a.attribute13
,a.attribute14
,a.attribute15
,a.attribute16
,a.attribute17
,a.attribute18
,a.attribute19
,a.attribute20
,a.attribute21
,a.attribute22
,a.attribute23
,a.attribute24
,a.attribute25
,a.attribute26
,a.attribute27
,a.attribute28
,a.attribute29
,a.attribute30
,a.bld_blk_info_type_id
,a.object_version_number
,'N' NEW
,'N' CHANGED
,'N' PROCESS
,au.time_building_block_ovn BUILDING_BLOCK_OVN
from hxc_bld_blk_info_types bbit,
hxc_time_attribute_usages au,
hxc_time_attributes a,
hxc_time_building_blocks htbb
where 	a.time_attribute_id         = au.time_attribute_id
and	a.bld_blk_info_type_id	    = bbit.bld_blk_info_type_id
and  au.time_building_block_id = htbb.time_building_block_id
and  au.time_building_block_ovn = htbb.object_version_number
and  htbb.scope			= 'DETAIL'
and  htbb.time_building_block_id     = p_detail_bb_id
and  htbb.object_version_number      = p_detail_bb_ovn
and  htbb.resource_id		     = p_resource_id;

l_tbb_block		HXC_BLOCK_TABLE_TYPE;

l_index		NUMBER := 1;
l_att_index	NUMBER := 1;

BEGIN

l_tbb_block    := HXC_BLOCK_TABLE_TYPE ();
p_attributes   := HXC_ATTRIBUTE_TABLE_TYPE();


-- now we need to build the type table
FOR c_tbb_info in crs_tbb LOOP

   -- insert the timecard
   l_tbb_block.extend;
   l_index := l_tbb_block.last;
   l_tbb_block(l_index) :=
	        hxc_block_type (
	        c_tbb_info.tc_TIME_BUILDING_BLOCK_ID,
	   	null,
	   	null,
	   	null,
	   	fnd_date.date_to_canonical(c_tbb_info.tc_START_TIME),
	   	fnd_date.date_to_canonical(c_tbb_info.tc_STOP_TIME),
	   	c_tbb_info.tc_PARENT_BUILDING_BLOCK_ID,
	   	null,
	   	c_tbb_info.tc_SCOPE,
	   	c_tbb_info.tc_OBJECT_VERSION_NUMBER,
	   	null,
	   	null,
	   	null,
	   	null,
	   	null,
	   	null,
	   	null,
	   	c_tbb_info.tc_PARENT_BUILDING_BLOCK_OVN,
	   	null,
	   	null,
	   	null,
	   	null,
                null);

   -- insert the day
   l_tbb_block.extend;
   l_index := l_tbb_block.last;
   l_tbb_block(l_index) :=
	        hxc_block_type (
	        c_tbb_info.day_TIME_BUILDING_BLOCK_ID,
	   	null,
	   	null,
	   	null,
	   	fnd_date.date_to_canonical(c_tbb_info.day_START_TIME),
	   	fnd_date.date_to_canonical(c_tbb_info.day_STOP_TIME),
	   	c_tbb_info.day_PARENT_BUILDING_BLOCK_ID,
	   	null,
	   	c_tbb_info.day_SCOPE,
	   	c_tbb_info.day_OBJECT_VERSION_NUMBER,
	   	null,
	   	null,
	   	null,
	   	null,
	   	null,
	   	null,
	   	null,
	   	c_tbb_info.day_PARENT_BUILDING_BLOCK_OVN,
	   	null,
	   	null,
	   	null,
	   	null,
                null);

   --insert the detail
   l_tbb_block.extend;
   l_index := l_tbb_block.last;
   l_tbb_block(l_index) :=
	        hxc_block_type (
	        c_tbb_info.detail_TIME_BUILDING_BLOCK_ID,
	   	null,
	   	null,
	   	null,
	   	fnd_date.date_to_canonical(c_tbb_info.detail_START_TIME),
	   	fnd_date.date_to_canonical(c_tbb_info.detail_STOP_TIME),
	   	c_tbb_info.detail_PARENT_BB_ID,
	   	null,
	   	c_tbb_info.detail_SCOPE,
	   	c_tbb_info.detail_OBJECT_VERSION_NUMBER,
	   	null,
	   	null,
	   	null,
	   	null,
	   	null,
	   	null,
	   	null,
	   	c_tbb_info.detail_PARENT_BB_OVN,
	   	null,
	   	null,
	   	null,
	   	null,
                null);

     -- insert the timecard attribute
     FOR c_timecard_attribute in crs_timecard_attribute
                     (c_tbb_info.tc_TIME_BUILDING_BLOCK_ID
                     ,c_tbb_info.tc_OBJECT_VERSION_NUMBER) LOOP

         p_attributes.extend;
	 l_att_index := p_attributes.last;
	 p_attributes(l_att_index) :=
	        hxc_attribute_type (
		     c_timecard_attribute.time_attribute_id,
		     c_timecard_attribute.time_building_block_id,
		     c_timecard_attribute.attribute_category,
		     c_timecard_attribute.attribute1,
		     c_timecard_attribute.attribute2,
		     c_timecard_attribute.attribute3,
		     c_timecard_attribute.attribute4,
		     c_timecard_attribute.attribute5,
		     c_timecard_attribute.attribute6,
		     c_timecard_attribute.attribute7,
		     c_timecard_attribute.attribute8,
		     c_timecard_attribute.attribute9,
		     c_timecard_attribute.attribute10,
		     c_timecard_attribute.attribute11,
		     c_timecard_attribute.attribute12,
		     c_timecard_attribute.attribute13,
		     c_timecard_attribute.attribute14,
		     c_timecard_attribute.attribute15,
		     c_timecard_attribute.attribute16,
		     c_timecard_attribute.attribute17,
		     c_timecard_attribute.attribute18,
		     c_timecard_attribute.attribute19,
		     c_timecard_attribute.attribute20,
		     c_timecard_attribute.attribute21,
		     c_timecard_attribute.attribute22,
		     c_timecard_attribute.attribute23,
		     c_timecard_attribute.attribute24,
		     c_timecard_attribute.attribute25,
		     c_timecard_attribute.attribute26,
		     c_timecard_attribute.attribute27,
		     c_timecard_attribute.attribute28,
		     c_timecard_attribute.attribute29,
		     c_timecard_attribute.attribute30,
		     c_timecard_attribute.bld_blk_info_type_id,
		     c_timecard_attribute.object_version_number,
		     c_timecard_attribute.NEW,
		     c_timecard_attribute.CHANGED,
	    	     c_timecard_attribute.bld_blk_info_type,
		     c_timecard_attribute.PROCESS,
		     c_timecard_attribute.BUILDING_BLOCK_OVN);

      END LOOP;


     -- insert the detail attribute
     -- now we are populating the attribute of this detail
     FOR c_detail_attribute in crs_detail_attribute LOOP

         p_attributes.extend;
	 l_att_index := p_attributes.last;
	 p_attributes(l_att_index) :=
	        hxc_attribute_type (
		     c_detail_attribute.time_attribute_id,
		     c_detail_attribute.time_building_block_id,
		     c_detail_attribute.attribute_category,
		     c_detail_attribute.attribute1,
		     c_detail_attribute.attribute2,
		     c_detail_attribute.attribute3,
		     c_detail_attribute.attribute4,
		     c_detail_attribute.attribute5,
		     c_detail_attribute.attribute6,
		     c_detail_attribute.attribute7,
		     c_detail_attribute.attribute8,
		     c_detail_attribute.attribute9,
		     c_detail_attribute.attribute10,
		     c_detail_attribute.attribute11,
		     c_detail_attribute.attribute12,
		     c_detail_attribute.attribute13,
		     c_detail_attribute.attribute14,
		     c_detail_attribute.attribute15,
		     c_detail_attribute.attribute16,
		     c_detail_attribute.attribute17,
		     c_detail_attribute.attribute18,
		     c_detail_attribute.attribute19,
		     c_detail_attribute.attribute20,
		     c_detail_attribute.attribute21,
		     c_detail_attribute.attribute22,
		     c_detail_attribute.attribute23,
		     c_detail_attribute.attribute24,
		     c_detail_attribute.attribute25,
		     c_detail_attribute.attribute26,
		     c_detail_attribute.attribute27,
		     c_detail_attribute.attribute28,
		     c_detail_attribute.attribute29,
		     c_detail_attribute.attribute30,
		     c_detail_attribute.bld_blk_info_type_id,
		     c_detail_attribute.object_version_number,
		     c_detail_attribute.NEW,
		     c_detail_attribute.CHANGED,
	    	     c_detail_attribute.bld_blk_info_type,
		     c_detail_attribute.PROCESS,
		     c_detail_attribute.BUILDING_BLOCK_OVN);

      END LOOP;

      -- call the alias translator
      hxc_alias_translator.do_retrieval_translation
              (p_attributes	=> p_attributes
              ,p_blocks		=> l_tbb_block
              ,p_start_time  	=> c_tbb_info.tc_start_time
              ,p_stop_time   	=> c_tbb_info.tc_stop_time
              ,p_resource_id 	=> p_resource_id
              ,p_processing_mode	 => hxc_alias_utility.c_ss_processing
              ,p_add_alias_display_value => true
              ,p_add_alias_ref_object	 => true
              ,p_messages	         => p_messages
              );

END LOOP;


END get_translated_detail;


END HXC_ALIAS_UTILITY;

/
