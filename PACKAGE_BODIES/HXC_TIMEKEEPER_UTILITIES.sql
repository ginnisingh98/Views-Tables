--------------------------------------------------------
--  DDL for Package Body HXC_TIMEKEEPER_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TIMEKEEPER_UTILITIES" AS
/* $Header: hxctkutil.pkb 120.15.12010000.15 2009/09/17 11:47:02 sabvenug ship $ */
g_debug boolean := hr_utility.debug_enabled;
-------------------------------------------------------------------------------
-- this procedure add a block in the block_table
--------	-----------------------------------------------------------------------
 PROCEDURE add_block (
  p_timecard IN OUT NOCOPY hxc_block_table_type,
  p_timecard_id IN NUMBER,
  p_ovn IN NUMBER,
  p_parent_id IN NUMBER,
  p_parent_ovn IN NUMBER,
  p_approval_style_id IN NUMBER,
  p_measure IN NUMBER,
  p_scope IN VARCHAR2,
  p_date_to IN DATE,
  p_date_from IN DATE,
  p_start_period IN DATE,
  p_end_period IN DATE,
  p_resource_id IN NUMBER,
  p_changed IN VARCHAR2,
  p_comment_text IN VARCHAR2,
  p_submit_flg IN BOOLEAN,
  p_application_set_id IN hxc_time_building_blocks.application_set_id%type,
  p_timecard_index_info IN OUT NOCOPY hxc_timekeeper_process.t_timecard_index_info
) IS
  l_type            hxc_time_building_blocks.TYPE%TYPE;
  l_parent_is_new   VARCHAR2 (1);
  l_approval_status hxc_time_building_blocks.approval_status%TYPE;
  l_new             VARCHAR2 (1);
  l_block_index     NUMBER
/*ADVICE(99): NUMBER has no precision [315] */
                                                                    := 0;
  l_date_from       VARCHAR2 (50);
  l_date_to         VARCHAR2 (50);

  l_changed	    VARCHAR2(1);
  l_application_set_id HXC_TIME_BUILDING_BLOCKS.APPLICATION_SET_ID%TYPE;
cursor c_app_set_id(p_timecard_id in hxc_time_building_blocks.time_building_block_id%type,
                    p_ovn in hxc_time_building_blocks.object_version_number%type)
is
select
    application_set_id
from
    hxc_time_building_blocks
where
    time_building_block_id = p_timecard_id
    and
    object_version_number=p_ovn;

 BEGIN

  l_changed := p_changed;

  IF p_measure IS NOT NULL THEN
   l_type := 'MEASURE';
  ELSE
   l_type := 'RANGE';
  END IF;

  IF (p_parent_id < 0) THEN
   l_parent_is_new := 'Y';
  ELSE
   l_parent_is_new := 'N';
  END IF;

  IF (p_submit_flg) THEN
   l_approval_status := 'SUBMITTED';
  ELSE
   l_approval_status := 'WORKING';
  END IF;

  IF (p_timecard_id < 0) THEN
   l_new := 'Y';
  ELSE
   l_new := 'N';
   /*fix for 5099360 */
   IF p_application_set_id IS NULL then
	   open c_app_set_id(p_timecard_id,p_ovn);
	   fetch c_app_set_id into l_application_set_id;
	   close c_app_set_id;
   ELSE
	   l_application_set_id:=p_application_set_id;
   END if;
   /*end of fix for 5099360 */
  END IF;

  l_date_from := fnd_date.date_to_canonical (p_date_from);
  l_date_to := fnd_date.date_to_canonical (p_date_to);


  IF p_timecard_index_info.EXISTS (p_timecard_id) THEN
   l_block_index := p_timecard_index_info (p_timecard_id).time_block_row_index;

   if g_debug then
   hr_utility.trace('l_block_index1 =  '||l_block_index);
   end if;
   --it is an update and we don't have to change detae from or date to
   IF  p_date_from IS NULL AND p_date_to IS NULL THEN
    l_date_from := p_timecard (l_block_index).date_from;
    l_date_to := p_timecard (l_block_index).date_to;
   END IF;
   -- check the changed flag
   IF l_changed <> 'Y' THEN

    IF  ((nvl(p_timecard (l_block_index).measure,-999) <> nvl(p_measure,-999))
     OR (nvl(fnd_date.date_to_canonical
         (to_date(p_timecard (l_block_index).start_time,'YYYY/MM/DD HH24:MI:SS')),-999)
         <> nvl(fnd_date.date_to_canonical(
          to_date(p_start_period,'YYYY/MM/DD HH24:MI:SS')),-999))
     OR (nvl(fnd_date.date_to_canonical (
          to_date(p_timecard (l_block_index).stop_time,'YYYY/MM/DD HH24:MI:SS')),-999)
         <> nvl(fnd_date.date_to_canonical(to_date(p_end_period,'YYYY/MM/DD HH24:MI:SS')),-999))
     OR (nvl(p_timecard (l_block_index).comment_text,-999)
         <> nvl(p_comment_text,-999))) THEN
      l_changed := 'Y';
    END IF;
   END IF;

  ELSE
   p_timecard.EXTEND;
   l_block_index := p_timecard.LAST;
   if g_debug then
   hr_utility.trace('l_block_index2 =  '||l_block_index);
   end if;

  END IF;

  if g_debug then
  hr_utility.trace('Going to create hxc_block_type');
  end if;

  p_timecard (l_block_index) := hxc_block_type (
                                 p_timecard_id,
                                 l_type,
                                 p_measure,
                                 'HOURS',
                                 fnd_date.date_to_canonical (p_start_period),
                                 fnd_date.date_to_canonical (p_end_period),
                                 p_parent_id,
                                 'N',
                                 p_scope,
                                 nvl(p_ovn,1),
                                 l_approval_status,
                                 p_resource_id,
                                 'PERSON',
                                 p_approval_style_id,
                                 l_date_from,
                                 l_date_to,
                                 p_comment_text,
                                 p_parent_ovn,
                                 l_new,
                                 l_changed,
                                 'N',
                                 l_APPLICATION_SET_ID,
                                 NULL
                                );
    if g_debug then
    hr_utility.trace('after create hxc_block_type');
    end if;

  p_timecard_index_info (p_timecard_id).time_block_row_index := l_block_index;

  if g_debug then
  hr_utility.trace('after p_timecard_index_info');
  end if;

 END add_block;

-------------------------------------------------------------------------------
-- this procedure add a attribute in the attribute_table
-------------------------------------------------------------------------------
 PROCEDURE add_attribute (
  p_attribute IN OUT NOCOPY hxc_attribute_table_type,
  p_attribute_id IN NUMBER,
  p_tbb_id IN NUMBER,
  p_tbb_ovn IN NUMBER,
  p_blk_type IN VARCHAR2,
  p_blk_id IN NUMBER,
  p_att_category IN VARCHAR2,
  p_att_1 IN VARCHAR2,
  p_att_2 IN VARCHAR2,
  p_att_3 IN VARCHAR2,
  p_att_4 IN VARCHAR2,
  p_att_5 IN VARCHAR2 DEFAULT NULL,
  p_att_6 IN VARCHAR2 DEFAULT NULL,
  p_att_7 IN VARCHAR2 DEFAULT NULL,
  p_att_8 IN VARCHAR2 DEFAULT NULL,
  p_attribute_index_info IN OUT NOCOPY hxc_timekeeper_process.t_attribute_index_info
 ) IS
  l_new             VARCHAR2 (1);
  l_attribute_index NUMBER
/*ADVICE(195): NUMBER has no precision [315] */
                                 := 0;
 BEGIN
  IF p_attribute_index_info.EXISTS (p_attribute_id) THEN
   l_attribute_index := p_attribute_index_info (p_attribute_id).attribute_block_row_index;
  ELSE
   p_attribute.EXTEND;
   l_attribute_index := p_attribute.LAST;
  END IF;

  IF p_attribute_id > 0 THEN
   l_new := 'N';
  ELSE
   l_new := 'Y';
  END IF;

  p_attribute (l_attribute_index) := hxc_attribute_type (
                                      p_attribute_id,
                                      p_tbb_id,
                                      p_att_category,
                                      p_att_1,
                                      p_att_2,
                                      p_att_3,
                                      p_att_4,
                                      p_att_5,
                                      p_att_6,
                                      p_att_7,
                                      p_att_8,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      p_blk_id,
                                      NULL,
                                      l_new,
                                      'Y',
                                      p_blk_type,
                                      'N',
                                      p_tbb_ovn
                                     );
  p_attribute_index_info (p_attribute_id).attribute_block_row_index := l_attribute_index;
 END add_attribute;


-------------------------------------------------------------------------------
-- this procedure create the attribute structure for an timecard_id
-------------------------------------------------------------------------------
 PROCEDURE create_attribute_structure (
  p_timecard_id IN NUMBER,
  p_timecard_ovn IN NUMBER,
  p_resource_id IN NUMBER,
  p_start_period
/*ADVICE(265): Unreferenced parameter [552] */
                 IN DATE,
  p_end_period
/*ADVICE(268): Unreferenced parameter [552] */
               IN DATE,
  p_attributes OUT NOCOPY hxc_attribute_table_type,
  p_add_hours_type_id
/*ADVICE(272): Unreferenced parameter [552] */
                      IN NUMBER,
  p_attribute_index_info OUT NOCOPY hxc_timekeeper_process.t_attribute_index_info
 ) IS
  CURSOR c_detail_attribute (
   timecard_id IN NUMBER,
   timecard_ovn IN NUMBER,
   l_resource_id IN NUMBER
  ) IS
   SELECT   a.time_attribute_id, au.time_building_block_id, bbit.bld_blk_info_type, a.attribute_category,
            a.attribute1, a.attribute2, a.attribute3, a.attribute4, a.attribute5, a.attribute6,
            a.attribute7, a.attribute8, a.attribute9, a.attribute10, a.attribute11, a.attribute12,
            a.attribute13, a.attribute14, a.attribute15, a.attribute16, a.attribute17, a.attribute18,
            a.attribute19, a.attribute20, a.attribute21, a.attribute22, a.attribute23, a.attribute24,
            a.attribute25, a.attribute26, a.attribute27, a.attribute28, a.attribute29, a.attribute30,
            a.bld_blk_info_type_id, a.object_version_number
   FROM     hxc_bld_blk_info_types bbit, hxc_time_attribute_usages au, hxc_time_attributes a
   WHERE    a.time_attribute_id = au.time_attribute_id
AND         a.bld_blk_info_type_id = bbit.bld_blk_info_type_id
AND         (au.time_building_block_id, au.time_building_block_ovn) IN
              (SELECT detail.time_building_block_id, detail.object_version_number
               FROM   hxc_time_building_blocks detail, hxc_time_building_blocks DAY
               WHERE  DAY.time_building_block_id = detail.parent_building_block_id
AND                   DAY.object_version_number = detail.parent_building_block_ovn
AND                   DAY.SCOPE = 'DAY'
AND                   detail.resource_id = l_resource_id
AND                   detail.SCOPE = 'DETAIL'
AND                   DAY.date_to = hr_general.end_of_time
AND                   detail.date_to = hr_general.end_of_time
AND                   DAY.parent_building_block_id = timecard_id
AND                   DAY.parent_building_block_ovn = timecard_ovn
AND                   DAY.resource_id = l_resource_id)
   UNION
   SELECT   a.time_attribute_id, au.time_building_block_id, bbit.bld_blk_info_type, a.attribute_category,
            a.attribute1, a.attribute2, a.attribute3, a.attribute4, a.attribute5, a.attribute6,
            a.attribute7, a.attribute8, a.attribute9, a.attribute10, a.attribute11, a.attribute12,
            a.attribute13, a.attribute14, a.attribute15, a.attribute16, a.attribute17, a.attribute18,
            a.attribute19, a.attribute20, a.attribute21, a.attribute22, a.attribute23, a.attribute24,
            a.attribute25, a.attribute26, a.attribute27, a.attribute28, a.attribute29, a.attribute30,
            a.bld_blk_info_type_id, a.object_version_number
   FROM     hxc_bld_blk_info_types bbit, hxc_time_attribute_usages au, hxc_time_attributes a
   WHERE    a.time_attribute_id = au.time_attribute_id
AND         a.bld_blk_info_type_id = bbit.bld_blk_info_type_id
AND         (au.time_building_block_id, au.time_building_block_ovn) IN
              (SELECT DAY.time_building_block_id, DAY.object_version_number
               FROM   hxc_time_building_blocks DAY
               WHERE  DAY.date_to = hr_general.end_of_time
AND                   DAY.SCOPE = 'DAY'
AND                   DAY.parent_building_block_id = timecard_id
AND                   DAY.parent_building_block_ovn = timecard_ovn
AND                   DAY.resource_id = l_resource_id)
   UNION
   SELECT   a.time_attribute_id, au.time_building_block_id, bbit.bld_blk_info_type, a.attribute_category,
            a.attribute1, a.attribute2, a.attribute3, a.attribute4, a.attribute5, a.attribute6,
            a.attribute7, a.attribute8, a.attribute9, a.attribute10, a.attribute11, a.attribute12,
            a.attribute13, a.attribute14, a.attribute15, a.attribute16, a.attribute17, a.attribute18,
            a.attribute19, a.attribute20, a.attribute21, a.attribute22, a.attribute23, a.attribute24,
            a.attribute25, a.attribute26, a.attribute27, a.attribute28, a.attribute29, a.attribute30,
            a.bld_blk_info_type_id, a.object_version_number
   FROM     hxc_bld_blk_info_types bbit, hxc_time_attribute_usages au, hxc_time_attributes a
   WHERE    a.time_attribute_id = au.time_attribute_id
AND         a.bld_blk_info_type_id = bbit.bld_blk_info_type_id
AND         (au.time_building_block_id, au.time_building_block_ovn) IN
              (SELECT time_building_block_id, object_version_number
               FROM   hxc_time_building_blocks htbb
               WHERE  htbb.date_to = hr_general.end_of_time
AND                   htbb.SCOPE = 'TIMECARD'
AND                   htbb.time_building_block_id = timecard_id
AND                   htbb.object_version_number = timecard_ovn
AND                   htbb.resource_id = l_resource_id)
   ORDER BY time_building_block_id;

  l_attribute_index NUMBER
/*ADVICE(345): NUMBER has no precision [315] */
                           := 0;
  l_attribute8  varchar2(150);
  l_attribute3  varchar2(150);
  l_attribute4  varchar2(150);
 BEGIN
  p_attributes := hxc_attribute_table_type ();

  FOR detail_attribute_info IN c_detail_attribute (p_timecard_id, p_timecard_ovn, p_resource_id) LOOP
   -- index the attribute table with the attribute_id
   p_attributes.EXTEND;
   l_attribute_index := p_attributes.LAST;
   /* start of changes made by senthil for 4295540 */
   if hxc_timekeeper_process.g_submit and detail_attribute_info.attribute_category = 'REASON' then
    l_attribute8:='N';
   else
    l_attribute8:=detail_attribute_info.attribute8;
   end if;
   /* end of changes made by senthil */

   --Condition Added By Mithun for Persistent resp Enhancement
   --condition was added so that Whenever TK makes modification to a timecard
   --The resp_id and user_id stored in attribute3 and attribute4 gets refreshed.
   if hxc_timekeeper_process.g_submit and detail_attribute_info.attribute_category = 'SECURITY' then
	l_attribute3:=FND_GLOBAL.USER_ID;
	l_attribute4:=FND_GLOBAL.RESP_ID;
   else
	l_attribute3:=detail_attribute_info.attribute3;
	l_attribute4:=detail_attribute_info.attribute4;
   end if;
   --End of Condition Added By Mithun

   p_attributes (l_attribute_index) := hxc_attribute_type (
                                        detail_attribute_info.time_attribute_id,
                                        detail_attribute_info.time_building_block_id,
                                        detail_attribute_info.attribute_category,
                                        detail_attribute_info.attribute1,
                                        detail_attribute_info.attribute2,
                                        l_attribute3,
                                        l_attribute4,
                                        detail_attribute_info.attribute5,
                                        detail_attribute_info.attribute6,
                                        detail_attribute_info.attribute7,
                                        l_attribute8,
                                        detail_attribute_info.attribute9,
                                        detail_attribute_info.attribute10,
                                        detail_attribute_info.attribute11,
                                        detail_attribute_info.attribute12,
                                        detail_attribute_info.attribute13,
                                        detail_attribute_info.attribute14,
                                        detail_attribute_info.attribute15,
                                        detail_attribute_info.attribute16,
                                        detail_attribute_info.attribute17,
                                        detail_attribute_info.attribute18,
                                        detail_attribute_info.attribute19,
                                        detail_attribute_info.attribute20,
                                        detail_attribute_info.attribute21,
                                        detail_attribute_info.attribute22,
                                        detail_attribute_info.attribute23,
                                        detail_attribute_info.attribute24,
                                        detail_attribute_info.attribute25,
                                        detail_attribute_info.attribute26,
                                        detail_attribute_info.attribute27,
                                        detail_attribute_info.attribute28,
                                        detail_attribute_info.attribute29,
                                        detail_attribute_info.attribute30,
                                        detail_attribute_info.bld_blk_info_type_id,
                                        detail_attribute_info.object_version_number,
                                        'N',
                                        'N',
                                        detail_attribute_info.bld_blk_info_type,
                                        'N',
                                        NULL
                                       );
   p_attribute_index_info (detail_attribute_info.time_attribute_id).attribute_block_row_index :=
                                                                                       l_attribute_index;
  END LOOP;
 END create_attribute_structure;


----------------------------------------------------------------------------
-- This Function is used to get which attribute is used to calculate the
-- Attribute category of the details associated with
----------------------------------------------------------------------------
 FUNCTION get_tk_dff_attrname (
  p_tkid
/*ADVICE(408): Unreferenced parameter [552] */
         IN NUMBER,
  p_insert_detail IN hxc_timekeeper_process.t_time_info,
  p_base_dff IN VARCHAR2,
  p_att_tab IN hxc_alias_utility.t_alias_att_info
 )
  RETURN VARCHAR2 IS
  att_dep_item      NUMBER
/*ADVICE(416): NUMBER has no precision [315] */
                          ;
  new_att_catg      VARCHAR2 (2000);
/*ADVICE(419): VARCHAR2 declaration with length greater than 500 characters [307] */

  l_reference_field fnd_descriptive_flexs.default_context_field_name%TYPE;

  CURSOR c_reference_field IS
   SELECT d.default_context_field_name
   FROM   fnd_descriptive_flexs d, fnd_application a, fnd_product_installations z
   WHERE  d.application_id = a.application_id
AND       z.application_id = a.application_id
AND       a.application_short_name = 'PA'
AND       z.status = 'I'
AND       d.descriptive_flexfield_name = 'PA_EXPENDITURE_ITEMS_DESC_FLEX';

 BEGIN
  g_debug :=hr_utility.debug_enabled;
  --get the number say 3 FROM ATTRIBUTE3 using substr function
  att_dep_item := TO_NUMBER (SUBSTR (p_base_dff, 10));
  if g_debug then
  	  hr_utility.trace('att_dep_item is '||att_dep_item);
          hr_utility.trace('in detail is '||p_insert_detail.attr_id_3);
  end if;
         ---depending upon the number select id value from the timecard block
  -- for 3 it will be attr_id_3
  IF att_dep_item = 1 THEN
   new_att_catg := p_insert_detail.attr_id_1;
  ELSIF att_dep_item = 2 THEN
   new_att_catg := p_insert_detail.attr_id_2;
  ELSIF att_dep_item = 3 THEN
   new_att_catg := p_insert_detail.attr_id_3;
  ELSIF att_dep_item = 4 THEN
   new_att_catg := p_insert_detail.attr_id_4;
  ELSIF att_dep_item = 5 THEN
   new_att_catg := p_insert_detail.attr_id_5;
  ELSIF att_dep_item = 6 THEN
   new_att_catg := p_insert_detail.attr_id_6;
  ELSIF att_dep_item = 7 THEN
   new_att_catg := p_insert_detail.attr_id_7;
  ELSIF att_dep_item = 8 THEN
   new_att_catg := p_insert_detail.attr_id_8;
  ELSIF att_dep_item = 9 THEN
   new_att_catg := p_insert_detail.attr_id_9;
  ELSIF att_dep_item = 10 THEN
   new_att_catg := p_insert_detail.attr_id_10;
  ELSIF att_dep_item = 11 THEN
   new_att_catg := p_insert_detail.attr_id_11;
  ELSIF att_dep_item = 11 THEN
   new_att_catg := p_insert_detail.attr_id_11;
  ELSIF att_dep_item = 12 THEN
   new_att_catg := p_insert_detail.attr_id_12;
  ELSIF att_dep_item = 13 THEN
   new_att_catg := p_insert_detail.attr_id_13;
  ELSIF att_dep_item = 14 THEN
   new_att_catg := p_insert_detail.attr_id_14;
  ELSIF att_dep_item = 15 THEN
   new_att_catg := p_insert_detail.attr_id_15;
  ELSIF att_dep_item = 16 THEN
   new_att_catg := p_insert_detail.attr_id_16;
  ELSIF att_dep_item = 17 THEN
   new_att_catg := p_insert_detail.attr_id_17;
  ELSIF att_dep_item = 18 THEN
   new_att_catg := p_insert_detail.attr_id_18;
  ELSIF att_dep_item = 19 THEN
   new_att_catg := p_insert_detail.attr_id_19;
  ELSIF att_dep_item = 20 THEN
   new_att_catg := p_insert_detail.attr_id_20;
  END IF;

  if g_debug then
  	  hr_utility.trace('new cat is '||new_att_catg);
  end if;
  IF new_att_catg IS NOT NULL THEN
   l_reference_field := NULL;
   if g_debug then
   	   hr_utility.trace('new cat is '||new_att_catg);
   end if;
   OPEN c_reference_field;
   FETCH c_reference_field INTO l_reference_field;
   CLOSE c_reference_field;

   IF l_reference_field = 'SYSTEM_LINKAGE_FUNCTION' THEN
    IF p_att_tab (att_dep_item).alias_type LIKE 'VALUE%' THEN
     SELECT DECODE (
             SUBSTR (new_att_catg, INSTR (new_att_catg, 'ALIAS_SEPARATOR') + 15),
             'OT', 'PAEXPITDFF - OT',
             'PAEXPITDFF - ST'
            )
     INTO   new_att_catg
     FROM   DUAL;
    ELSE
     SELECT DECODE (
             hxc_alias_utility.get_sfl_from_alias_value (new_att_catg),
             'OT', 'PAEXPITDFF - OT',
             'PAEXPITDFF - ST'
            )
     INTO   new_att_catg
     FROM   DUAL;
    END IF;
   ELSIF l_reference_field = 'EXPENDITURE_TYPE' THEN
    IF p_att_tab (att_dep_item).alias_type LIKE 'VALUE%' THEN
     SELECT hxc_deposit_wrapper_utilities.get_dupdff_code (
             'PAEXPITDFF - '|| SUBSTR (new_att_catg, 1, INSTR (new_att_catg, 'ALIAS_SEPARATOR') - 1)
            )
     INTO   new_att_catg
     FROM   DUAL;
    ELSE
     --      new_att_catg:=get_exp_type_from_alias( new_att_catg);
     new_att_catg :=
       hxc_deposit_wrapper_utilities.get_dupdff_code (
        'PAEXPITDFF - '|| get_exp_type_from_alias (new_att_catg)
       );
    END IF;
   -- :DETAIL_BLK.C_ATTRIBUTE_CATEGORY:=HXC_DEPOSIT_WRAPPER_UTILITIES.GET_DUPDFF_CODE(:DETAIL_BLK.C_ATTRIBUTE_CATEGORY) ;--3791698
   ELSIF l_reference_field = ''
/*ADVICE(525): In Oracle 8, VARCHAR2 variables of zero length assigned to CHAR variables will blank-pad
              these rather than making them NULL [111] */
                                OR l_reference_field IS NULL THEN
    IF (check_global_context ('PAEXPITDFF')) THEN
     new_att_catg := 'PAEXPITDFF - GLOBAL';
    END IF;
   END IF;
  END IF;

  /*if new_att_catg is not null then
 	   --now look for the type of that attribute if it is like '%VALUE%' then
 	   --it will be either PAEXPITDFF - OT OR PAEXPITDFF - ST
 	   if p_att_tab(att_dep_item).alias_type like 'VALUE%' then
 	      SELECT decode(SUBSTR(new_att_catg,INSTR(new_att_catg,'ALIAS_SEPARATOR')+15),'OT','PAEXPITDFF - OT','PAEXPITDFF - ST')
 	      INTO   new_att_catg
 	      FROM DUAL;
 	   else
 	      select decode(hxc_alias_utility.get_sfl_from_alias_value(new_att_catg),'OT','PAEXPITDFF - OT','PAEXPITDFF - ST')
 	      INTO   new_att_catg
 	      FROM DUAL;
 	   end if;
 	end if;*/
  if g_debug then
  	  hr_utility.trace('return new cat is '||new_att_catg);
  end if;
  RETURN (new_att_catg);
 END;


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
 PROCEDURE add_dff_attribute (
  p_attribute IN OUT NOCOPY hxc_attribute_table_type,
  p_attribute_id IN NUMBER,
  p_tbb_id IN NUMBER,
  p_tbb_ovn
/*ADVICE(559): Unreferenced parameter [552] */
            IN NUMBER,
  p_blk_type IN VARCHAR2,
  p_blk_id IN NUMBER,
  p_att_category IN VARCHAR2,
  p_att_1 IN VARCHAR2,
  p_att_2 IN VARCHAR2,
  p_att_3 IN VARCHAR2,
  p_att_4 IN VARCHAR2,
  p_att_5 IN VARCHAR2,
  p_att_6 IN VARCHAR2,
  p_att_7 IN VARCHAR2,
  p_att_8 IN VARCHAR2,
  p_att_9 IN VARCHAR2,
  p_att_10 IN VARCHAR2,
  p_att_11 IN VARCHAR2,
  p_att_12 IN VARCHAR2,
  p_att_13 IN VARCHAR2,
  p_att_14 IN VARCHAR2,
  p_att_15 IN VARCHAR2,
  p_att_16 IN VARCHAR2,
  p_att_17 IN VARCHAR2,
  p_att_18 IN VARCHAR2,
  p_att_19 IN VARCHAR2,
  p_att_20 IN VARCHAR2,
  p_att_21 IN VARCHAR2,
  p_att_22 IN VARCHAR2,
  p_att_23 IN VARCHAR2,
  p_att_24 IN VARCHAR2,
  p_att_25 IN VARCHAR2,
  p_att_26 IN VARCHAR2,
  p_att_27 IN VARCHAR2,
  p_att_28 IN VARCHAR2,
  p_att_29 IN VARCHAR2,
  p_att_30 IN VARCHAR2,
  p_attribute_index_info IN OUT NOCOPY hxc_timekeeper_process.t_attribute_index_info
 ) IS
  l_new             VARCHAR2 (1);
  l_attribute_index NUMBER
/*ADVICE(598): NUMBER has no precision [315] */
                                 := 0;
 BEGIN

--p_attribute :=HXC_ATTRIBUTE_TABLE_TYPE();
  IF p_attribute_index_info.EXISTS (p_attribute_id) THEN
   l_attribute_index := p_attribute_index_info (p_attribute_id).attribute_block_row_index;
  ELSE
   p_attribute.EXTEND;
   l_attribute_index := p_attribute.LAST;
  END IF;

  IF p_attribute_id > 0 THEN
   l_new := 'N';
  ELSE
   l_new := 'Y';
  END IF;

  p_attribute (l_attribute_index) := hxc_attribute_type (
                                      p_attribute_id,
                                      p_tbb_id,
                                      p_att_category,
                                      p_att_1,
                                      p_att_2,
                                      p_att_3,
                                      p_att_4,
                                      p_att_5,
                                      p_att_6,
                                      p_att_7,
                                      p_att_8,
                                      p_att_9,
                                      p_att_10,
                                      p_att_11,
                                      p_att_12,
                                      p_att_13,
                                      p_att_14,
                                      p_att_15,
                                      p_att_16,
                                      p_att_17,
                                      p_att_18,
                                      p_att_19,
                                      p_att_20,
                                      p_att_21,
                                      p_att_22,
                                      p_att_23,
                                      p_att_24,
                                      p_att_25,
                                      p_att_26,
                                      p_att_27,
                                      p_att_28,
                                      p_att_29,
                                      p_att_30,
                                      p_blk_id,
                                      NULL,
                                      l_new,
                                      'Y',
                                      p_blk_type,
                                      'Y',
                                      NULL
                                     );
  p_attribute_index_info (p_attribute_id).attribute_block_row_index := l_attribute_index;
 END add_dff_attribute;


-------------------------------------------------------------------------------
--used to order the timecard create ...but not used in the timekeeper process
-------------------------------------------------------------------------------
 PROCEDURE order_building_blocks (
  p_timecard IN OUT NOCOPY hxc_self_service_time_deposit.timecard_info,
  p_ord_timecard IN OUT NOCOPY hxc_self_service_time_deposit.timecard_info
 ) IS
  l_timecard_start NUMBER
/*ADVICE(670): NUMBER has no precision [315] */
                          := 1;
  l_block_count    NUMBER
/*ADVICE(673): NUMBER has no precision [315] */
                          := 0;
  n
/*ADVICE(676): Unreferenced variable [553] */
                   NUMBER
/*ADVICE(678): NUMBER has no precision [315] */
                          := 0;
 BEGIN
  IF (p_ord_timecard.COUNT > 0) THEN
   p_ord_timecard.DELETE;
  END IF;

  l_block_count := p_timecard.FIRST;

  LOOP
   EXIT WHEN NOT p_timecard.EXISTS (l_block_count);
   p_ord_timecard (l_timecard_start) := p_timecard (l_block_count);
   l_timecard_start := l_timecard_start + 1;
   l_block_count := p_timecard.NEXT (l_block_count);
  END LOOP;
 END order_building_blocks;


-------------------------------------------------------------------------------
-- This procedure dump the timkeeper date table information
-------------------------------------------------------------------------------
 PROCEDURE dump_timkeeper_data (
  p_timekeeper_data IN hxc_timekeeper_process.t_timekeeper_table
 ) IS
  l_index NUMBER
/*ADVICE(703): NUMBER has no precision [315] */
                ;
 BEGIN
  l_index := p_timekeeper_data.FIRST;

  LOOP
   EXIT WHEN (NOT p_timekeeper_data.EXISTS (l_index));
   l_index := p_timekeeper_data.NEXT (l_index);
  END LOOP;
 END;


-------------------------------------------------------------------------------
-- This procedure dump the buffer table information
-------------------------------------------------------------------------------
 PROCEDURE dump_buffer_table (
  p_buffer_table hxc_timekeeper_process.t_buffer_table
/*ADVICE(720): Mode of parameter is not specified with IN parameter [521] */

 ) IS
  l_index NUMBER
/*ADVICE(724): NUMBER has no precision [315] */
                ;
 BEGIN
  l_index := p_buffer_table.FIRST;

  LOOP
   EXIT WHEN (NOT p_buffer_table.EXISTS (l_index));
   l_index := p_buffer_table.NEXT (l_index);
  END LOOP;
 END dump_buffer_table;


-------------------------------------------------------------------------------
-- this procedure dump the resource tc table information
-------------------------------------------------------------------------------
 PROCEDURE dump_resource_tc_table (
  l_resource_tc_table hxc_timekeeper_process.t_resource_tc_table
/*ADVICE(741): Mode of parameter is not specified with IN parameter [521] */

 ) IS
  l_index NUMBER
/*ADVICE(745): NUMBER has no precision [315] */
                ;
 BEGIN
  l_index := l_resource_tc_table.FIRST;

  LOOP
   EXIT WHEN (NOT l_resource_tc_table.EXISTS (l_index));

   IF (1 >= fnd_log.g_current_runtime_level) THEN
    fnd_log.STRING (
     1,
     'hxc_timekeeper_process.l_resource_tc_table',
     'index_string:' || l_resource_tc_table (l_index).index_string || ' index:' || l_index
    );
   END IF;

   l_index := l_resource_tc_table.NEXT (l_index);
  END LOOP;
 END dump_resource_tc_table;


-------------------------------------------------------------------------------
-- this procedure dump the buffer table information
-------------------------------------------------------------------------------
 PROCEDURE dump_timecard (
  p_timecard IN hxc_self_service_time_deposit.timecard_info
 ) IS
  l_index NUMBER
/*ADVICE(773): NUMBER has no precision [315] */
                ;
 BEGIN
  l_index := p_timecard.FIRST;

  LOOP
   EXIT WHEN (NOT p_timecard.EXISTS (l_index));

   IF (1 >= fnd_log.g_current_runtime_level) THEN
    fnd_log.STRING (
     1,
     'hxc_timekeeper_process.dump_buffer_table',
     'time_building_block_id :' || p_timecard (l_index).time_building_block_id || ' ovn :'
     || p_timecard (l_index).object_version_number || ' start_time :' || p_timecard (l_index).start_time
     || ' stop_time :' || p_timecard (l_index).stop_time || ' parent_id :'
     || p_timecard (l_index).parent_building_block_id || ' parent_ovn :'
     || p_timecard (l_index).parent_building_block_ovn || ' resource_id :'
     || p_timecard (l_index).resource_id || ' resource_type :' || p_timecard (l_index).resource_type
     || ' type :' || p_timecard (l_index).TYPE
    );
    fnd_log.STRING (
     1,
     'hxc_timekeeper_process.dump_buffer_table',
     ' measure :' || p_timecard (l_index).measure || ' OFM :' || p_timecard (l_index).unit_of_measure
     || ' parent_is_new :' || p_timecard (l_index).parent_is_new || ' scope :' || p_timecard (l_index).SCOPE
     || ' app_status :' || p_timecard (l_index).approval_status || ' app_style_id :'
     || p_timecard (l_index).approval_style_id || ' date_from :' || p_timecard (l_index).date_from
     || ' date_to :' || p_timecard (l_index).date_to || ' comment_text :'
     || p_timecard (l_index).comment_text || ' new :' || p_timecard (l_index).NEW || ' changed :'
     || p_timecard (l_index).changed || ' index:' || l_index
    );
   END IF;

   l_index := p_timecard.NEXT (l_index);
  END LOOP;
 END dump_timecard;


-------------------------------------------------------------------------------
-- this procedure used to give all timecards including  midperiod timecards
-- saved in that range
-------------------------------------------------------------------------------
 PROCEDURE populate_tc_tab (
  resource_id IN NUMBER,
  tc_frdt IN DATE,
  tc_todt IN DATE,
  emp_tc_info OUT NOCOPY hxc_timekeeper_utilities.emptctab
 ) IS
  CURSOR get_tc_data (
   p_resource_id NUMBER,
   p_tc_frdt DATE,
   p_tc_todt DATE
  ) IS
   SELECT   time_building_block_id tbbid, start_time, stop_time, TO_DATE (start_time, 'dd-mm-rrrr')
   FROM     hxc_time_building_blocks
   WHERE    resource_id
/*ADVICE(829): Cursor references an external variable (use a parameter) [209] */
                        = p_resource_id
AND         SCOPE = 'TIMECARD'
AND         date_to = hr_general.end_of_time
AND         TO_DATE (p_tc_frdt, 'dd-mm-rrrr') BETWEEN TO_DATE (start_time, 'dd-mm-rrrr')
                                                  AND TO_DATE (stop_time, 'dd-mm-rrrr')
   UNION
   SELECT   time_building_block_id, start_time, stop_time, TO_DATE (start_time, 'dd-mm-rrrr')
   FROM     hxc_time_building_blocks
   WHERE    resource_id
/*ADVICE(839): Cursor references an external variable (use a parameter) [209] */
                        = p_resource_id
AND         SCOPE = 'TIMECARD'
AND         date_to = hr_general.end_of_time
AND         TO_DATE (p_tc_todt, 'dd-mm-rrrr') BETWEEN TO_DATE (start_time, 'dd-mm-rrrr')
                                                  AND TO_DATE (stop_time, 'dd-mm-rrrr')
   UNION
   SELECT   time_building_block_id, start_time, stop_time, TO_DATE (start_time, 'dd-mm-rrrr')
   FROM     hxc_time_building_blocks
   WHERE    resource_id
/*ADVICE(849): Cursor references an external variable (use a parameter) [209] */
                        = p_resource_id
AND         SCOPE = 'TIMECARD'
AND         date_to = hr_general.end_of_time
AND         TO_DATE (start_time, 'dd-mm-rrrr') >= TO_DATE (p_tc_frdt, 'dd-mm-rrrr')
AND         TO_DATE (stop_time, 'dd-mm-rrrr') <= TO_DATE (p_tc_todt, 'dd-mm-rrrr')
   MINUS
   SELECT   time_building_block_id, start_time, stop_time, TO_DATE (start_time, 'dd-mm-rrrr')
   FROM     hxc_time_building_blocks
   WHERE    resource_id
/*ADVICE(859): Cursor references an external variable (use a parameter) [209] */
                        = p_resource_id
AND         SCOPE = 'TIMECARD'
AND         date_to = hr_general.end_of_time
AND         TO_DATE (start_time, 'dd-mm-rrrr') = TO_DATE (p_tc_frdt, 'dd-mm-rrrr')
AND         TO_DATE (stop_time, 'dd-mm-rrrr') = TO_DATE (p_tc_todt, 'dd-mm-rrrr')
   ORDER BY 4;

  tc_tab_rec get_tc_data%ROWTYPE;
  p_index    NUMBER
/*ADVICE(869): NUMBER has no precision [315] */
                                   := 0;
 BEGIN
  --This procedure is used to get all the timecrds saved
  --in the time building blocks which are between from and to date.
  --used in timekeeper query and disabling of fields.
  emp_tc_info.DELETE;
  OPEN get_tc_data (resource_id, tc_frdt, tc_todt);

  LOOP
   FETCH get_tc_data INTO tc_tab_rec;
   EXIT WHEN get_tc_data%NOTFOUND;
   --We index the emp_tc_info table by julian date
   p_index := TO_NUMBER (TO_CHAR (tc_tab_rec.start_time, 'J'));
   emp_tc_info (p_index).timecard_id := tc_tab_rec.tbbid;
   emp_tc_info (p_index).resource_id := resource_id;
   emp_tc_info (p_index).tc_frdt := tc_tab_rec.start_time;
   emp_tc_info (p_index).tc_todt := tc_tab_rec.stop_time;
  END LOOP;
 END;


-------------------------------------------------------------------------------
-- this procedure used to query mid period timecards
-------------------------------------------------------------------------------
 PROCEDURE populate_query_tc_tab (
  resource_id IN NUMBER,
  tc_frdt IN DATE,
  tc_todt IN DATE,
  emp_qry_tc_info OUT NOCOPY hxc_timekeeper_utilities.emptctab
 ) IS
  CURSOR get_tc_data (
   p_resource_id NUMBER,
   p_tc_frdt DATE,
   p_tc_todt DATE
  ) IS
   /*
  	select start_time,stop_time,to_date(start_time)
  	from hxc_time_building_blocks
  	where resource_id = p_resource_id
  	and scope='TIMECARD'
  	and date_to=hr_general.end_of_time
  	and to_date(start_time,'dd-mm-rrrr') >=to_date(p_tc_frdt,'dd-mm-rrrr') and
  	to_date(stop_time,'dd-mm-rrrr') <=to_date(p_tc_todt,'dd-mm-rrrr')
  	union
  	select  tc_frdt,tc_todt,to_date(tc_frdt)
  	from dual
  	order by 3;
  	*/
   SELECT   TO_DATE (start_time, 'dd-mm-rrrr hh24:mi:ss') start_time,
            TO_DATE (stop_time, 'dd-mm-rrrr hh24:mi:ss') stop_time, TO_DATE (start_time, 'dd-mm-rrrr') orddt
   FROM     hxc_time_building_blocks
   WHERE    resource_id
/*ADVICE(922): Cursor references an external variable (use a parameter) [209] */
                        = p_resource_id
AND         SCOPE = 'TIMECARD'
AND         date_to = hr_general.end_of_time
AND         TO_DATE (start_time, 'dd-mm-rrrr') >= TO_DATE (p_tc_frdt, 'dd-mm-rrrr')
AND         TO_DATE (stop_time, 'dd-mm-rrrr') <= TO_DATE (p_tc_todt, 'dd-mm-rrrr')
   UNION
   SELECT   TO_DATE (tc_frdt
/*ADVICE(930): Cursor references an external variable (use a parameter) [209] */
                            , 'dd-mm-rrrr hh24:mi:ss'), TO_DATE (tc_todt
/*ADVICE(932): Cursor references an external variable (use a parameter) [209] */
                                                                        , 'dd-mm-rrrr hh24:mi:ss'),
            TO_DATE (tc_frdt
/*ADVICE(935): Cursor references an external variable (use a parameter) [209] */
                            , 'dd-mm-rrrr')
   FROM     DUAL
   ORDER BY 3;

  tc_tab_rec get_tc_data%ROWTYPE;
  p_index    NUMBER
/*ADVICE(942): NUMBER has no precision [315] */
                                   := 0;
 BEGIN
  ---This procedure is used to get the timecards which are exactly between the range selected
  ---used in timekeeper query and disabling of fields.
  -- if this table contains more than 1 row means in that period person is
  -- mid period case.
  emp_qry_tc_info.DELETE;
  OPEN get_tc_data (resource_id, tc_frdt, tc_todt);

  LOOP
   FETCH get_tc_data INTO tc_tab_rec;
   EXIT WHEN get_tc_data%NOTFOUND;
   p_index := p_index + 1;
   --p_index:=to_number(to_char(tc_tab_rec.start_time,'J'));
   emp_qry_tc_info (p_index).resource_id := resource_id;
   emp_qry_tc_info (p_index).tc_frdt := tc_tab_rec.start_time;
   emp_qry_tc_info (p_index).tc_todt := tc_tab_rec.stop_time;
  END LOOP;
 END;


-------------------------------------------------------------------------------
-- this procedure gives split of timecards
-- Used in save procedure to break the timecard
--when monthly timecard is
-------------------------------------------------------------------------------
 PROCEDURE split_timecard (
  p_resource_id IN NUMBER,
  p_start_date IN DATE,
  p_end_date IN DATE,
  p_spemp_tc_info IN hxc_timekeeper_utilities.emptctab,
  p_tc_list OUT NOCOPY hxc_timecard_utilities.periods
 ) IS
  m_periods
/*ADVICE(977): Unreferenced variable [553] */
                   VARCHAR2 (2000);
/*ADVICE(979): VARCHAR2 declaration with length greater than 500 characters [307] */

  newtab           hxc_timecard_utilities.periods;
  emp_tab_index    NUMBER
/*ADVICE(983): NUMBER has no precision [315] */
                                                  := 0;
  new_tab_index
/*ADVICE(986): Unreferenced variable [553] */
                   NUMBER
/*ADVICE(988): NUMBER has no precision [315] */
                                                  := 0;
  l_emp_negpref    VARCHAR2 (150);
  l_emp_recpref    NUMBER
/*ADVICE(992): NUMBER has no precision [315] */
                         ;
  l_emp_appstyle   NUMBER
/*ADVICE(995): NUMBER has no precision [315] */
                         ;
  l_emp_layout1    NUMBER
/*ADVICE(998): NUMBER has no precision [315] */
                         ;
  l_emp_layout2    NUMBER
/*ADVICE(1001): NUMBER has no precision [315] */
                         ;
  l_emp_layout3    NUMBER
/*ADVICE(1004): NUMBER has no precision [315] */
                         ;
  l_emp_layout4    NUMBER
/*ADVICE(1007): NUMBER has no precision [315] */
                         ;
  l_emp_layout5    NUMBER
/*ADVICE(1010): NUMBER has no precision [315] */
                         ;
  l_emp_layout6    NUMBER
/*ADVICE(1013): NUMBER has no precision [315] */
                         ;
  l_emp_layout7    NUMBER
/*ADVICE(1016): NUMBER has no precision [315] */
                         ;
  l_emp_layout8    NUMBER
/*ADVICE(1019): NUMBER has no precision [315] */
                         ;
  l_emp_edits      VARCHAR2 (150);
  l_pastdt         VARCHAR2 (30);
  l_futuredt       VARCHAR2 (30);
  l_emp_start_date DATE;
  l_emp_terminate_date DATE;
  l_audit_enabled  VARCHAR2 (150);
 BEGIN
  g_debug :=hr_utility.debug_enabled;
  newtab.DELETE;
  if g_debug then
  	  hr_utility.trace('p_resource_id '||p_resource_id);
          hr_utility.trace('p_end_date'||to_date(p_end_date,'dd-mm-rrrr'));
  	  hr_utility.trace('start '||to_date(p_start_date,'dd-mm-rrrr'));
  end if;
  l_emp_negpref := NULL;
  l_emp_recpref := NULL;
  l_emp_appstyle := NULL;
  l_emp_layout1 := NULL;
  l_emp_layout2 := NULL;
  l_emp_layout3 := NULL;
  l_emp_layout4 := NULL;
  l_emp_layout5 := NULL;
  l_emp_layout6 := NULL;
  l_emp_layout7 := NULL;
  l_emp_layout8 := NULL;
  l_emp_edits := NULL;
  hxc_timekeeper_utilities.get_emp_pref (
   p_resource_id,
   l_emp_negpref,
   l_emp_recpref,
   l_emp_appstyle,
   l_emp_layout1,
   l_emp_layout2,
   l_emp_layout3,
   l_emp_layout4,
   l_emp_layout5,
   l_emp_layout6,
   l_emp_layout7,
   l_emp_layout8,
   l_emp_edits,
   l_pastdt,
   l_futuredt,
   l_emp_start_date,
   l_emp_terminate_date,
   l_audit_enabled
  );

  if g_debug then
  	  hr_utility.trace(' just checking cout'||p_spemp_tc_info.count);
  end if;
  IF p_spemp_tc_info.COUNT > 0 THEN --this means the person is a mid period change
       --and we need to split the timecard.
     if g_debug then
       	     hr_utility.trace('get the periods');
     end if;

   get_resource_time_periods (
    p_resource_id => p_resource_id,
    p_resource_type => 'PERSON',
    p_current_date => SYSDATE,
    p_max_date_in_futur => TO_DATE (p_end_date, 'dd-mm-rrrr') + 1,
    p_max_date_in_past => TO_DATE (p_start_date, 'dd-mm-rrrr') - 1,
    p_recurring_period_id => l_emp_recpref,
    p_check_assignment => TRUE,
    p_periodtab => newtab
   );
   --New tab contains the timecard periods in that range through which
   --we loop and save the timecard
   if g_debug then
   	   hr_utility.trace('newtab.count'||newtab.count);
   end if;
   emp_tab_index := p_spemp_tc_info.FIRST;

   LOOP
    EXIT WHEN NOT p_spemp_tc_info.EXISTS (emp_tab_index);

    if g_debug then
    	    hr_utility.trace(emp_tab_index);
    end if;
    IF    TO_NUMBER (emp_tab_index) < TO_NUMBER (TO_CHAR (TO_DATE (p_start_date, 'dd-mm-rrrr'), 'J'))
       OR TO_NUMBER (emp_tab_index) > TO_NUMBER (TO_CHAR (TO_DATE (p_end_date, 'dd-mm-rrrr'), 'J')) THEN
     --remove the rows from the pl/sql table table which are out of range
     --incomplete timecard
     IF newtab.EXISTS (emp_tab_index) THEN
      newtab.DELETE (emp_tab_index);
     if g_debug then
     	     hr_utility.trace('in delete emptab ');
     end if;
     END IF;
    END IF;

    emp_tab_index := p_spemp_tc_info.NEXT (emp_tab_index);
   END LOOP;
  ELSE
   IF TO_DATE (TRUNC (p_start_date), 'dd-mm-rrrr') < TO_DATE (l_emp_start_date, 'dd-mm-rrrr') THEN
    if g_debug then
    	    hr_utility.trace('mid hire employee1 ');
            hr_utility.trace('p_start_date'|| l_emp_start_date);
    end if;
    newtab (TO_NUMBER (TO_CHAR (TO_DATE (l_emp_start_date, 'dd-mm-rrrr'), 'J'))).start_date := l_emp_start_date;
   /* changes done by senthil for emp terminate enhancement*/
   IF TO_DATE (TRUNC (p_end_date), 'dd-mm-rrrr') > TO_DATE (nvl(l_emp_terminate_date,p_end_date), 'dd-mm-rrrr') THEN
     if g_debug then
    	    hr_utility.trace('Terminated employee ');
            hr_utility.trace('p_end_date'|| nvl(l_emp_terminate_date,p_end_date));
     end if;
     newtab (TO_NUMBER (TO_CHAR (TO_DATE (l_emp_start_date, 'dd-mm-rrrr'), 'J'))).end_date := nvl(l_emp_terminate_date,p_end_date);
   else
     if g_debug then
      	      hr_utility.trace(' Normal employee ');
              hr_utility.trace('p_end_date'|| p_end_date);
     end if;
     newtab (TO_NUMBER (TO_CHAR (TO_DATE (l_emp_start_date, 'dd-mm-rrrr'), 'J'))).end_date := p_end_date;
   end if;
   /* end of changes made by senthil */
   ELSE
      if g_debug then
      	      hr_utility.trace(' Normal employee ');
               hr_utility.trace('p_start_date'|| p_start_date);
      end if;
    newtab (TO_NUMBER (TO_CHAR (TO_DATE (p_start_date, 'dd-mm-rrrr'), 'J'))).start_date := p_start_date;
   /* changes done by senthil for emp terminate enhancement*/
    IF TO_DATE (TRUNC (p_end_date), 'dd-mm-rrrr') > TO_DATE (nvl(l_emp_terminate_date,p_end_date), 'dd-mm-rrrr') THEN
     if g_debug then
    	    hr_utility.trace('Terminated employee ');
            hr_utility.trace('p_end_date'|| nvl(l_emp_terminate_date,p_end_date));
     end if;
     newtab (TO_NUMBER (TO_CHAR (TO_DATE (p_start_date, 'dd-mm-rrrr'), 'J'))).end_date := nvl(l_emp_terminate_date,p_end_date);
   else
     if g_debug then
      	      hr_utility.trace(' Normal employee ');
              hr_utility.trace('p_end_date'|| p_end_date);
     end if;
     newtab (TO_NUMBER (TO_CHAR (TO_DATE (p_start_date, 'dd-mm-rrrr'), 'J'))).end_date := p_end_date;
   end if;
   /* end of changes made by senthil */
   end if;

  END IF;
    if g_debug then
	    hr_utility.trace('newtab.count'||newtab.count);
    end if;
   p_tc_list := newtab;

   if g_debug then
   	   hr_utility.trace('p_tc_list.count'||p_tc_list.count);
   end if;
 END;


----------------------------------------------------------------------------
-- add_resource_to_perftab is used to popluate the global pl/sql resource
-- preference table
----------------------------------------------------------------------------
 PROCEDURE add_resource_to_perftab (
  p_resource_id IN NUMBER,
  p_pref_code IN VARCHAR2,
  p_attribute1 IN VARCHAR2,
  p_attribute2 IN VARCHAR2,
  p_attribute3 IN VARCHAR2,
  p_attribute4 IN VARCHAR2,
  p_attribute5 IN VARCHAR2,
  p_attribute6 IN VARCHAR2,
  p_attribute7 IN VARCHAR2,
  p_attribute8 IN VARCHAR2,
  p_attribute11 IN VARCHAR2
 ) IS
 BEGIN
  IF (p_pref_code = 'TC_W_ALW_NEG_TIME') THEN
   g_resource_perftab (p_resource_id).res_negentry := p_attribute1;
  ELSIF (p_pref_code = 'TC_W_TCRD_PERIOD') THEN
   g_resource_perftab (p_resource_id).res_recperiod := p_attribute1;
  ELSIF (p_pref_code = 'TC_W_TCRD_LAYOUT') THEN
   g_resource_perftab (p_resource_id).res_layout1 := p_attribute1;
   g_resource_perftab (p_resource_id).res_layout2 := p_attribute2;
   g_resource_perftab (p_resource_id).res_layout3 := p_attribute3;
   g_resource_perftab (p_resource_id).res_layout4 := p_attribute4;
   g_resource_perftab (p_resource_id).res_layout5 := p_attribute5; --CTK
   g_resource_perftab (p_resource_id).res_layout6 := p_attribute6; --CHECK OUT
   g_resource_perftab (p_resource_id).res_layout7 := p_attribute7;
   g_resource_perftab (p_resource_id).res_layout8 := p_attribute8;
  ELSIF (p_pref_code = 'TS_PER_APPROVAL_STYLE') THEN
   g_resource_perftab (p_resource_id).res_appstyle := p_attribute1;
  ELSIF (p_pref_code = 'TS_PER_AUDIT_REQUIREMENTS') THEN
   g_resource_perftab (p_resource_id).res_audit_enabled := p_attribute1;
  ELSIF (p_pref_code = 'TC_W_TCRD_ST_ALW_EDITS') THEN
   g_resource_perftab (p_resource_id).res_edits := p_attribute1;

   IF p_attribute6 IS NULL THEN
    g_resource_perftab (p_resource_id).res_past_date := '0001/01/01';
   ELSE
    g_resource_perftab (p_resource_id).res_past_date :=
                                             TO_CHAR ((SYSDATE - TO_NUMBER (p_attribute6)), 'YYYY/MM/DD');
   END IF;

   IF p_attribute11 IS NULL THEN
    g_resource_perftab (p_resource_id).res_future_date := '4712/12/31';
   ELSE
    g_resource_perftab (p_resource_id).res_future_date :=
                                            TO_CHAR ((SYSDATE + TO_NUMBER (p_attribute11)), 'YYYY/MM/DD');
   END IF;
  END IF;
 END;


----------------------------------------------------------------------------
-- Called from timekeeper process to get the preference
-- associated with a  resource
-- instead of calling preference evaluation cache the info.
----------------------------------------------------------------------------
 PROCEDURE get_emp_pref (
  p_resource_id IN NUMBER,
  neg_pref OUT NOCOPY VARCHAR2,
  recpref OUT NOCOPY NUMBER,
  appstyle OUT NOCOPY NUMBER,
  layout1 OUT NOCOPY NUMBER,
  layout2 OUT NOCOPY NUMBER,
  layout3 OUT NOCOPY NUMBER,
  layout4 OUT NOCOPY NUMBER,
  layout5 OUT NOCOPY NUMBER,
  layout6 OUT NOCOPY NUMBER,
  layout7 OUT NOCOPY NUMBER,
  layout8 OUT NOCOPY NUMBER,
  edits OUT NOCOPY VARCHAR2,
  l_pastdate OUT NOCOPY VARCHAR2,
  l_futuredate OUT NOCOPY VARCHAR2,
  l_emp_start_date OUT NOCOPY DATE,
  l_emp_terminate_date OUT NOCOPY DATE,
  l_audit_enabled OUT NOCOPY VARCHAR2
 ) IS
  l_index      NUMBER
/*ADVICE(1197): NUMBER has no precision [315] */
                                                      := 0;
  l_pref_table hxc_preference_evaluation.t_pref_table;


/*
  CURSOR c_emp_hireinfo (
   p_resource_id
/*ADVICE(1203): This definition hides another one [556] */
/*                 NUMBER
  ) IS
  select max(date_start) from
  per_periods_of_service
  where person_id = p_resource_id;  */



  -- Bug 7454062
  --
  -- Rewrote the above cursor as below.
  -- Changes :
  --   1. Added a UNION with per_periods_of_placement, cos we need
  --      CWK information also.
  --   2. Added two more input values, the timecard start and stop dates
  --      because we want to check which is the hire date which suits the
  --      given timecard.
  --      Example provided below before call to this cursor.
  --   3. Coalesce function would pick up which ever is not NULL in the
  --      order specified.  We dont want the AND clause to fail when
  --      the period of service is still active ( it has FPD and ATD Null in
  --      case of an active period of service ).
  --   4. The TC start and stop dates are picked up from the timekeeper profiles
  --      and they take care of the below scenarios.
  --
  --
  --
  --             A-------------------A
  --    *    T-------T
  --    *            T---------T
  --    *                        T---------T
  --
  --     A -- Assigment
  --     T -- Timecard.



  CURSOR c_emp_hireinfo ( p_resource_id    NUMBER,
                          p_tc_start_date  DATE,
                          p_tc_end_date    DATE )
      IS SELECT date_start
           FROM per_periods_of_service
          WHERE person_id        = p_resource_id
            AND date_start      <= p_tc_end_date
            AND COALESCE(final_process_date,actual_termination_date,
                         hr_general.end_of_time) >= p_tc_start_date
          UNION
         SELECT date_start
           FROM per_periods_of_placement
          WHERE person_id        = p_resource_id
            AND date_start      <= p_tc_end_date
            AND COALESCE((final_process_date+NVL(fnd_profile.value('HXC_CWK_TK_FPD'),0)),actual_termination_date,
                         hr_general.end_of_time) >= p_tc_start_date
          ORDER BY date_start ;


/*Cursor Modified By Mithun for CWK Terminate Bug*/
  /* changes done by senthil for emp terminate enhancement*/
/*  CURSOR c_emp_terminateinfo(
   p_resource_id NUMBER
  ) IS
  SELECT final_process_date, date_start
  FROM per_periods_of_service
  WHERE person_id = p_resource_id
  union all
  SELECT (final_process_date + NVL(fnd_profile.value('HXC_CWK_TK_FPD'),0)) final_process_date, date_start
  FROM PER_PERIODS_OF_placement
  WHERE person_id = p_resource_id
  ORDER BY date_start DESC;
*/



  -- Bug 7454062
  --
  -- Rewrote the above cursor as below
  -- Changes :
  --   1. Added tc start and stop input values to pick up
  --      the correct period of service suitable for
  --      the selected timecard range.
  --

  CURSOR c_emp_terminateinfo( p_resource_id NUMBER,
                              p_tc_start_date  DATE,
                              p_tc_end_date    DATE )
      IS SELECT final_process_date,
                date_start
           FROM per_periods_of_service
          WHERE person_id           = p_resource_id
            AND date_start         <= p_tc_end_date
            AND COALESCE(final_process_date,actual_termination_date,
                         hr_general.end_of_time) >= p_tc_start_date
          UNION
         SELECT (final_process_date + NVL(fnd_profile.value('HXC_CWK_TK_FPD'),0)) final_process_date,
                date_start
           FROM PER_PERIODS_OF_placement
          WHERE person_id           = p_resource_id
            AND date_start         <= p_tc_end_date
            AND COALESCE((final_process_date+NVL(fnd_profile.value('HXC_CWK_TK_FPD'),0)),actual_termination_date,
                         hr_general.end_of_time) >= p_tc_start_date
          ORDER BY date_start DESC;





--Added By Mithun for CWK Terminate Bug
  l_date_start	DATE;
  /* end of changes made by senthil */


  -- Bug 7454062
  l_tc_start_date  DATE;
  l_tc_end_date    DATE;


 BEGIN


  -- Bug 7454062

  l_tc_start_date  := FND_PROFILE.VALUE('OTL_TK_START_DATE');
  l_tc_end_date    := FND_PROFILE.VALUE('OTL_TK_END_DATE');

  IF p_resource_id IS NOT NULL THEN
   IF NOT g_resource_perftab.EXISTS (p_resource_id) THEN
    hxc_preference_evaluation.resource_preferences (
     p_resource_id,
     'TC_W_TCRD_LAYOUT,TS_PER_APPROVAL_STYLE,TC_W_ALW_NEG_TIME,TC_W_TCRD_PERIOD,TC_W_TCRD_ST_ALW_EDITS,TS_PER_AUDIT_REQUIREMENTS',
     l_pref_table
    );
    l_index := l_pref_table.FIRST;

    LOOP
     EXIT WHEN (NOT l_pref_table.EXISTS (l_index));
     add_resource_to_perftab (
      p_resource_id => p_resource_id,
      p_pref_code => l_pref_table (l_index).preference_code,
      p_attribute1 => l_pref_table (l_index).attribute1,
      p_attribute2 => l_pref_table (l_index).attribute2,
      p_attribute3 => l_pref_table (l_index).attribute3,
      p_attribute4 => l_pref_table (l_index).attribute4,
      p_attribute5 => l_pref_table (l_index).attribute5,
      p_attribute6 => l_pref_table (l_index).attribute6,
      p_attribute7 => l_pref_table (l_index).attribute7,
      p_attribute8 => l_pref_table (l_index).attribute8,
      p_attribute11 => l_pref_table (l_index).attribute11
     );
     l_index := l_pref_table.NEXT (l_index);
    END LOOP;

    -- Bug 7454062

    -- Moved the below code to outside the IF statement, as we want it to get calculated
    -- each time, a new date range may be specified for a second call.

   /*
    OPEN c_emp_hireinfo (p_resource_id => p_resource_id);
    FETCH c_emp_hireinfo INTO g_resource_perftab (p_resource_id).res_emp_start_date;
    CLOSE c_emp_hireinfo;
    /* changes done by senthil for emp terminate enhancement
    OPEN c_emp_terminateinfo (p_resource_id => p_resource_id);
/*Changed By Mithun for CWK Terminate Bug
    FETCH c_emp_terminateinfo INTO g_resource_perftab (p_resource_id).res_emp_terminate_date, l_date_start;
    CLOSE c_emp_terminateinfo;
    /* end of changes */


   END IF;


    -- Bug 7454062
    --
    -- Added start and stop dates of the timecards to the below cursors to have
    -- multiple periods of active assignment.
    -- For ex: First active assignment 1-Jan-2007 - 31-Dec-2007
    --         Second active assignment  1-Jun-2008 - end of time.
    --    Without the date inputs, the query for hire date would always return
    --     1-Jun-2008, hence no timecard can be entered in the first period.
    --    Similarly, without the date inputs, the terminate query would always
    --     return the final process date of the last active assignment, which is
    --     end of time in this case.  But for a timecard in 2007, we need termination
    --     date to be 31-Dec-2007.


    OPEN c_emp_hireinfo (p_resource_id   => p_resource_id,
                         p_tc_start_date => l_tc_start_date,
                         p_tc_end_date   => l_tc_end_date );

    FETCH c_emp_hireinfo INTO g_resource_perftab (p_resource_id).res_emp_start_date;
    CLOSE c_emp_hireinfo;


    OPEN c_emp_terminateinfo (p_resource_id   => p_resource_id,
                              p_tc_start_date => l_tc_start_date,
                              p_tc_end_date   => l_tc_end_date );

    FETCH c_emp_terminateinfo INTO g_resource_perftab (p_resource_id).res_emp_terminate_date, l_date_start;
    CLOSE c_emp_terminateinfo;



   neg_pref := g_resource_perftab (p_resource_id).res_negentry;
   recpref := TO_NUMBER (g_resource_perftab (p_resource_id).res_recperiod);
   appstyle := TO_NUMBER (g_resource_perftab (p_resource_id).res_appstyle);
   layout1 := TO_NUMBER (g_resource_perftab (p_resource_id).res_layout1);
   layout2 := TO_NUMBER (g_resource_perftab (p_resource_id).res_layout2);
   layout3 := TO_NUMBER (g_resource_perftab (p_resource_id).res_layout3);
   layout4 := TO_NUMBER (g_resource_perftab (p_resource_id).res_layout4);
   layout5 := TO_NUMBER (g_resource_perftab (p_resource_id).res_layout5);
   layout6 := TO_NUMBER (g_resource_perftab (p_resource_id).res_layout6);
   layout7 := TO_NUMBER (g_resource_perftab (p_resource_id).res_layout7);
   layout8 := TO_NUMBER (g_resource_perftab (p_resource_id).res_layout8);
   edits := g_resource_perftab (p_resource_id).res_edits;
   l_pastdate := g_resource_perftab (p_resource_id).res_past_date;
   l_futuredate := g_resource_perftab (p_resource_id).res_future_date;
   l_emp_start_date := g_resource_perftab (p_resource_id).res_emp_start_date;
   l_emp_terminate_date := g_resource_perftab (p_resource_id).res_emp_terminate_date;
   l_audit_enabled := g_resource_perftab (p_resource_id).res_audit_enabled;
  END IF;

 END;


----------------------------------------------------------------------------
-- get_resource_time_periods return the list of period for
-- a range of time
-- The p_check_assignment is not used for the moment.
----------------------------------------------------------------------------
 PROCEDURE get_resource_time_periods (
  p_resource_id IN VARCHAR2,
  p_resource_type IN VARCHAR2,
  p_current_date IN DATE,
  p_max_date_in_futur IN DATE,
  p_max_date_in_past IN DATE,
  p_recurring_period_id IN NUMBER,
  p_check_assignment IN BOOLEAN,
  p_periodtab IN OUT NOCOPY hxc_timecard_utilities.periods
 ) IS
  CURSOR c_timecards (
   p_resource_id
/*ADVICE(1285): This definition hides another one [556] */
                 IN NUMBER,
   p_resource_type
/*ADVICE(1288): This definition hides another one [556] */
                   IN VARCHAR2,
   p_first_start_date IN DATE,
   p_last_end_date IN DATE
  ) IS
   SELECT TRUNC (start_time), TRUNC (stop_time)
   FROM   hxc_time_building_blocks
   WHERE  SCOPE = 'TIMECARD'
AND       date_to = hr_general.end_of_time
AND       resource_id = p_resource_id
AND       resource_type = p_resource_type
AND       stop_time >= p_first_start_date
AND       start_time <= p_last_end_date;


--ORDER BY START_TIME;
  CURSOR c_period_info (
   p_recurring_period_id
/*ADVICE(1306): This definition hides another one [556] */
                         NUMBER
  ) IS
   SELECT hrp.period_type, hrp.duration_in_days, hrp.start_date
   FROM   hxc_recurring_periods hrp
   WHERE  hrp.recurring_period_id = p_recurring_period_id;

/*
  CURSOR c_emp_hireinfo (
   p_resource_id
/*ADVICE(1315): This definition hides another one [556] */
/*                 NUMBER
  ) IS
  select max(date_start) from
    per_periods_of_service
  where person_id = p_resource_id;
   /*SELECT MIN (effective_start_date)
   FROM   per_people_f
   WHERE  person_id = p_resource_id;*/


  -- Bug 7454062
  --
  -- Rewrote the above cursor as below.
  -- We need the first hire date or the first period of service start date
  -- which falls within the given max date in past and max date in future
  -- rather than the last assignment's start date.  The above cursor
  -- would work only for the most recent assignment.
  -- COALESCE would pick up the first not NULL value amongst the ones
  -- given in bracket.


  CURSOR c_emp_hireinfo ( p_resource_id NUMBER,
                          p_past_date   DATE )
      IS SELECT date_start
           FROM per_periods_of_service
          WHERE person_id          = p_resource_id
            AND COALESCE(final_process_date,actual_termination_date,
                         hr_general.end_of_time) > p_past_date
          UNION
         SELECT date_start
	   FROM per_periods_of_placement
	  WHERE person_id          = p_resource_id
	    AND COALESCE(final_process_date,actual_termination_date,
                         hr_general.end_of_time) > p_past_date
           ORDER BY date_start ;



/*Cursor Modified By Mithun for CWK Terminate Bug*/
/* changes done by senthil for emp terminate enhancement*/
  CURSOR c_emp_terminateinfo(
   p_resource_id NUMBER
  ) IS
  SELECT final_process_date, date_start
  FROM per_periods_of_service
  WHERE person_id = p_resource_id
  union all
  select (final_process_date + NVL(fnd_profile.value('HXC_CWK_TK_FPD'),0)) final_process_date, date_start
  from per_periods_of_placement
  where person_id = p_resource_id
  ORDER BY date_start DESC;


  -- Bug 7454062
  --
  -- Added a cursor below to pick up the time periods for which the
  -- employee is inactive. From c_emp_hireinfo cursor, we pick up
  -- the earliest hire date for the person, and generate the time periods
  -- for this start date.  The below cursor is used to trim off the
  -- inactive periods from the list of time periods.
  -- LEAD picks up the next records date_start, and returns a NULL for the
  -- last record retrieved. COALESCE picks up the first non NULL value from
  -- the ones given in bracket.


  CURSOR c_emp_inactive ( p_resource_id    NUMBER )
      IS SELECT final_process_date   start_date,
                NVL(LEAD(date_start) OVER (ORDER BY date_start)-1,hr_general.end_of_time) end_date
           FROM ( SELECT date_start,
                         COALESCE(final_process_date+1,actual_termination_date+1,hr_general.end_of_time)
                               final_process_date
		    FROM per_periods_of_service
                   WHERE person_id = p_resource_id
	   	   UNION
                  SELECT date_start,
                         COALESCE((final_process_date+NVL(fnd_profile.value('HXC_CWK_TK_FPD'),0))+1,actual_termination_date+1,hr_general.end_of_time)
                                 final_process_date
	  	    FROM per_periods_of_placement
                   WHERE person_id = p_resource_id
		  )
          ORDER BY start_date;


--Added By Mithun for CWK Terminate Bug
  l_date_start	DATE;


  CURSOR c_term_timecards_exists(
     p_resource_id  IN NUMBER,
   p_terminate_date IN DATE
  ) IS
   SELECT count(*)
   FROM   hxc_time_building_blocks
   WHERE  SCOPE = 'TIMECARD'
AND       (date_to = hr_general.end_of_time or APPROVAL_STATUS='ERROR')
AND       resource_id = p_resource_id
AND p_terminate_date between start_time and stop_time;
  /* end of changes made by senthil */


-- index
  l_index                       NUMBER (15) ;
  l_index_timecard_tab          NUMBER (15);

-- PL/SQL Table
  l_timecard_tab                hxc_timecard_utilities.periods;
  l_temp_periods                hxc_period_evaluation.period_list;

  l_inactive_periods            hxc_period_evaluation.period_list;

  l_period_start                DATE;
  l_period_end                  DATE;
  l_tc_period_start_date        DATE;
  l_tc_period_end_date          DATE;
  l_rec_period_start_date       DATE;
  l_person_effective_start_date DATE;
  l_person_effective_end_date   DATE;
  l_touch_period_in_tc          BOOLEAN;

--l_dividend	NUMBER;
  l_period_type                 hxc_recurring_periods.period_type%TYPE;
  l_duration_in_days            hxc_recurring_periods.duration_in_days%TYPE;
  l_emp_max_date_in_past        DATE;
  l_emp_max_date_in_futur       DATE;
  l_start_date                  DATE;
  l_end_date                    DATE;
  l_first_rowindex              NUMBER(15);
  l_last_rowindex               NUMBER(15);
  l_term_tc_exists              NUMBER(15);
 BEGIN
   g_debug :=hr_utility.debug_enabled;
--
-- look for the recurring period type
--
  OPEN c_period_info (p_recurring_period_id => p_recurring_period_id);
  FETCH c_period_info INTO l_period_type, l_duration_in_days, l_rec_period_start_date;
/*ADVICE(1365): FETCH into a list of variables instead of a record [204] */

  CLOSE c_period_info;

  IF p_check_assignment = TRUE THEN
   OPEN c_emp_hireinfo (p_resource_id => p_resource_id,
                        p_past_date   => p_max_date_in_past);
   FETCH c_emp_hireinfo INTO l_person_effective_start_date;
   CLOSE c_emp_hireinfo;

  /*Changes Done By Mithun for CWK Terminate Bug*/
  /* changes done by senthil for emp terminate enhancement*/
   OPEN c_emp_terminateinfo (p_resource_id => p_resource_id);
   FETCH c_emp_terminateinfo INTO l_person_effective_end_date, l_date_start;
   CLOSE c_emp_terminateinfo;
   /* end of changes */

   --2789497
   IF p_max_date_in_past <= NVL (l_person_effective_start_date, p_max_date_in_past) THEN
    l_emp_max_date_in_past := NVL (l_person_effective_start_date, p_max_date_in_past);
   ELSE
    l_emp_max_date_in_past := p_max_date_in_past;
   END IF;
  --2789497
  /* changes done by senthil for emp terminate enhancement*/
   IF g_debug THEN
	   hr_utility.trace('terminate end_date'||NVL(l_person_effective_end_date,p_max_date_in_futur));
   END if;
   IF p_max_date_in_futur >= NVL(l_person_effective_end_date,p_max_date_in_futur) THEN
     l_emp_max_date_in_futur := NVL(l_person_effective_end_date,p_max_date_in_futur);
   ELSE
     l_emp_max_date_in_futur := p_max_date_in_futur;
   END IF;
   IF g_debug THEN
	   hr_utility.trace('p_max_date_in_futur'||p_max_date_in_futur);
	   hr_utility.trace('l_emp_max_date_in_futur'||l_emp_max_date_in_futur);
   END if;
   /* Changes done by senthil */

  ELSE
   l_emp_max_date_in_past := p_max_date_in_past;
   l_emp_max_date_in_futur := p_max_date_in_futur;
  END IF;


-- We are finding the timecard for this period and add them
-- to the pl/sql table
  OPEN c_timecards (
   p_resource_id => p_resource_id,
   p_resource_type => p_resource_type,
   p_first_start_date => l_emp_max_date_in_past,
   p_last_end_date => l_emp_max_date_in_futur
  );

  LOOP
   FETCH c_timecards INTO l_period_start, l_period_end;
/*ADVICE(1400): FETCH into a list of variables instead of a record [204] */

   EXIT WHEN c_timecards%NOTFOUND;
   -- add the timecard in the pl/sql table
   -- here we are indexing by date JULIAN number to order the pl/sql table.
   l_timecard_tab (TO_NUMBER (TO_CHAR (l_period_start, 'J'))).start_date := l_period_start;
   l_timecard_tab (TO_NUMBER (TO_CHAR (l_period_start, 'J'))).end_date := l_period_end;
  END LOOP;

  CLOSE c_timecards;

-- add the timecard table into the period tab
--p_periodtab := l_timecard_tab;
-- we are calling to get the all period.
-- between the start date and end date.
  l_temp_periods :=
    hxc_period_evaluation.get_period_list (
     p_current_date => p_current_date,
     p_recurring_period_type => l_period_type,
     p_duration_in_days => l_duration_in_days,
     p_rec_period_start_date => l_rec_period_start_date,
     p_max_date_in_futur => l_emp_max_date_in_futur,
     p_max_date_in_past => l_emp_max_date_in_past
    );


   -- Bug 7454062
   --
   -- The below construct added to trim off the inactive periods
   -- from the generated periods list l_temp_periods.
   -- Eg. Lets say this is how the periods of service are
   --
   --
   -- date_start        final_process_date
   -- 1-jan-07          30-jun-07
   -- 1-jan-08          30-jun-08
   -- 1-jan-09
   --
   --
   -- The below cursor would return something like this.
   -- start_date        end_date
   -- 1-Jul-07          31-Dec-07
   -- 1-Jul-08          31-Dec-08
   -- end_of_time       end_of_time
   --
   -- These date ranges are inactive periods and anything which falls in these date
   -- ranges needs to be deleted from l_temp_periods.
   --

   OPEN c_emp_inactive(p_resource_id);
   FETCH c_emp_inactive BULK
                     COLLECT INTO l_inactive_periods;
   CLOSE c_emp_inactive;

   -- l_temp_periods as well as l_inactive_periods is accessed in sorted order
   -- Hence we neednt Nest the GENERATED_PERIODS loop completely.  The iterator
   -- can start from where it left for the last iteration of INACTIVE_PERIODS
   l_index := l_temp_periods.FIRST;

   <<INACTIVE_PERIODS>>
   FOR i IN l_inactive_periods.FIRST..l_inactive_periods.LAST
   LOOP
      -- We neednt consider this inactive period if the start_date is end_of_time
      -- or the start_date and end_date dont have atleast one day in between.
      IF      (l_inactive_periods(i).start_date <> hr_general.end_of_time)
          AND (l_inactive_periods(i).end_date - l_inactive_periods(i).start_date > 1)

      THEN
         <<GENERATED_PERIODS>>
         LOOP
            EXIT WHEN NOT l_temp_periods.EXISTS(l_index);
            -- If the generated period is completely less than the inactive period
            -- do nothing, go to the next generated period.
            IF l_temp_periods(l_index).end_date < l_inactive_periods(i).start_date
            THEN
               NULL;
            -- If the generated period is completely greater than the inactive period
            -- exit this looping of generated period.  Check for the same generated period
            -- and the next inactive period.
            ELSIF l_inactive_periods(i).end_date < l_temp_periods(l_index).start_date
            THEN
               EXIT GENERATED_PERIODS ;
            -- If generated period's start_date falls between the inactive period
            ELSE
               IF (l_temp_periods(l_index).start_date BETWEEN l_inactive_periods(i).start_date
                                                          AND l_inactive_periods(i).end_date)
               THEN
                  -- and if the generated period's end_date falls between the inactive period
                  --     I-------------------------------------I
                  --           G---------G
                  IF l_temp_periods(l_index).end_date BETWEEN l_inactive_periods(i).start_date
                                                          AND l_inactive_periods(i).end_date
                  THEN
                     --  delete the generated period.
                     l_temp_periods.DELETE(l_index);
                  ELSE
                     -- generated period's end_date falls outside the inactive period.
                     --   I------------------------------------I
                     --                                 G------------G
                     -- Reset the start date also to outside the inactive period.
                     --   I------------------------------------I
                     --                                         G----G
                     l_temp_periods(l_index).start_date := l_inactive_periods(i).end_date+1;
                  END IF;
               -- Generated period's end_date falls in the inactive period.
               --         I------------------------------------I
               --    G----------G
               --
               ELSIF l_temp_periods(l_index).end_date BETWEEN l_inactive_periods(i).start_date
                                                          AND l_inactive_periods(i).end_date
               THEN
                    -- Reset the end_date to outside the inactive period.
                    --           I------------------------------------I
                    --     G----G
                    l_temp_periods(l_index).end_date := l_inactive_periods(i).start_date-1;
               END IF;
            END IF;
            l_index := l_temp_periods.NEXT(l_index);
         END LOOP GENERATED_PERIODS ;
      END IF;
   END LOOP INACTIVE_PERIODS ;

   -- Bug 7454062






-- add them to the pl/sql table
-- we are now populating the periodtab pl/sql table
-- and we are working out on the rows already in the table
  l_index := l_temp_periods.FIRST;

  LOOP
   EXIT WHEN NOT l_temp_periods.EXISTS (l_index);
   if g_debug then

       	   hr_utility.trace('###################');
	   hr_utility.trace('#### NEW PERIOD #########');
	   hr_utility.trace('###################');
   end if;
   l_period_start := l_temp_periods (l_index).start_date;
   l_period_end := l_temp_periods (l_index).end_date;
   -- help to know if during the process the period
   -- has been modified.
   l_touch_period_in_tc := FALSE;
   -- before to add the period we need to look if there is a tc period
   -- already into this table
   l_index_timecard_tab := l_timecard_tab.FIRST;

   LOOP
    EXIT WHEN NOT l_timecard_tab.EXISTS (l_index_timecard_tab);
    l_tc_period_start_date := l_timecard_tab (l_index_timecard_tab).start_date;
    l_tc_period_end_date := l_timecard_tab (l_index_timecard_tab).end_date;
    if g_debug then
    	    hr_utility.trace('####NEW TIMECARD');
     	    hr_utility.trace('l_period_start :'||l_period_start);
    	    hr_utility.trace('l_period_end :'||l_period_end);
    	    hr_utility.trace('l_tc_period_start_date :'||to_char(l_tc_period_start_date,'DD-MON-YYYY'));
    	    hr_utility.trace('l_tc_period_end_date :'||to_char(l_tc_period_end_date,'DD-MON-YYYY'));
            hr_utility.trace('###################');
    end if;
    IF      TRUNC (l_tc_period_start_date) > TRUNC (l_period_start)
        AND TRUNC (l_tc_period_end_date) < TRUNC (l_period_end) THEN
            -- the timecard is in the middle of a period
            -- we are splitting the period in 2 + the timecard which
            -- is already there.
            -- before the timecard
       if g_debug then
       	       hr_utility.trace('case 1 :');
       end if;
     p_periodtab (TO_NUMBER (TO_CHAR (l_period_start, 'J'))).start_date := l_period_start;
     p_periodtab (TO_NUMBER (TO_CHAR (l_period_start, 'J'))).end_date := l_tc_period_start_date - 1;
     if g_debug then
             hr_utility.trace('l_tab_period_start_date :'||to_char(l_period_start,'DD-MON-YYYY'));
     	     hr_utility.trace('l_tab_period_end_date :'||to_char(l_tc_period_start_date - 1,'DD-MON-YYYY'));
     end if;
            -- after the timecard
     p_periodtab (TO_NUMBER (TO_CHAR (l_tc_period_end_date + 1, 'J'))).start_date :=
                                                                                l_tc_period_end_date + 1;
     p_periodtab (TO_NUMBER (TO_CHAR (l_tc_period_end_date + 1, 'J'))).end_date := l_period_end;
     -- now we are overritting the start period
     l_period_start := l_tc_period_end_date + 1;
     if g_debug then
     	     hr_utility.trace('l_tab_period_start_date :'||to_char(l_tc_period_end_date + 1,'DD-MON-YYYY'));
     	     hr_utility.trace('l_tab_period_end_date :'||to_char(l_period_end,'DD-MON-YYYY'));
     end if;
     l_touch_period_in_tc := TRUE;
    ELSIF      TRUNC (l_tc_period_start_date) < TRUNC (l_period_start)
           AND TRUNC (l_tc_period_end_date) > TRUNC (l_period_end) THEN
     -- the timecard is outside of the period so we have nothing to
     -- do
     l_touch_period_in_tc := TRUE;
    if g_debug then
    	    hr_utility.trace('case 2 :');
    end if;
    ELSIF      TRUNC (l_tc_period_start_date) > TRUNC (l_period_start)
           AND TRUNC (l_tc_period_start_date) <= TRUNC (l_period_end)
           AND TRUNC (l_tc_period_end_date) >= TRUNC (l_period_end) THEN
           if g_debug then
           	   hr_utility.trace('case 3 :');
           end if;
            -- we are splitting the period in 2
            -- we are adding the period just before the timecard
     p_periodtab (TO_NUMBER (TO_CHAR (l_period_start, 'J'))).start_date := l_period_start;
     p_periodtab (TO_NUMBER (TO_CHAR (l_period_start, 'J'))).end_date := l_tc_period_start_date - 1;
     -- in this case we can exit of the loop;
     l_index_timecard_tab := l_timecard_tab.LAST;
     l_touch_period_in_tc := TRUE;
     if g_debug then
    	     hr_utility.trace('l_tab_period_start_date :'||to_char(l_period_start,'DD-MON-YYYY'));
    	     hr_utility.trace('l_tab_period_end_date :'||to_char(l_tc_period_start_date - 1,'DD-MON-YYYY'));
     end if;
    ELSIF      TRUNC (l_tc_period_start_date) <= TRUNC (l_period_start)
           AND TRUNC (l_tc_period_end_date) >= TRUNC (l_period_start)
           AND TRUNC (l_tc_period_end_date) < TRUNC (l_period_end) THEN
           if g_debug then
          	   hr_utility.trace('case 4 :');
           end if;
            -- we are splitting the period in 2
            -- we are adding the period just before the timecard
     p_periodtab (TO_NUMBER (TO_CHAR (l_tc_period_end_date + 1, 'J'))).start_date :=
                                                                                l_tc_period_end_date + 1;
     p_periodtab (TO_NUMBER (TO_CHAR (l_tc_period_end_date + 1, 'J'))).end_date := l_period_end;
     if g_debug then
     	     hr_utility.trace('l_tab_period_start_date :'||to_char(l_tc_period_end_date + 1,'DD-MON-YYYY'));
             hr_utility.trace('l_tab_period_end_date :'||to_char(l_period_end,'DD-MON-YYYY'));
     end if;
             -- now we are overritting the end/start period
     l_period_start := l_tc_period_end_date + 1;
     l_touch_period_in_tc := TRUE;
    ELSIF    (    TRUNC (l_tc_period_start_date) = TRUNC (l_period_start)
              AND TRUNC (l_tc_period_end_date) >= TRUNC (l_period_end)
             )
          OR (    TRUNC (l_tc_period_start_date) <= TRUNC (l_period_start)
              AND TRUNC (l_tc_period_end_date) = TRUNC (l_period_end)
             ) THEN
            if g_debug then
            	    hr_utility.trace('case 5 :');
            end if;
            -- we are splitting the period in 2
            -- we are adding the period just before the timecard
     p_periodtab (TO_NUMBER (TO_CHAR (l_tc_period_start_date, 'J'))).start_date :=
                                                                                  l_tc_period_start_date;
     p_periodtab (TO_NUMBER (TO_CHAR (l_tc_period_start_date, 'J'))).end_date := l_tc_period_end_date;
     -- now we are overritting the end/start period
     l_period_start := l_tc_period_end_date + 1;
     l_touch_period_in_tc := TRUE;
    END IF;

    -- in case of override
    p_periodtab (TO_NUMBER (TO_CHAR (l_tc_period_start_date, 'J'))).start_date := l_tc_period_start_date;
    p_periodtab (TO_NUMBER (TO_CHAR (l_tc_period_start_date, 'J'))).end_date := l_tc_period_end_date;
    l_index_timecard_tab := l_timecard_tab.NEXT (l_index_timecard_tab);
   END LOOP;
/*ADVICE(1531): Nested LOOPs should all be labeled [406] */


   IF NOT (l_touch_period_in_tc) THEN
      if g_debug then
      	      hr_utility.trace('case 6 :');
      end if;
       -- we are adding the period
    p_periodtab (TO_NUMBER (TO_CHAR (l_period_start, 'J'))).start_date := l_period_start;
    p_periodtab (TO_NUMBER (TO_CHAR (l_period_start, 'J'))).end_date := l_period_end;
   END IF;

     if g_debug then
     	     hr_utility.trace('count'||p_periodtab.count);
     end if;
   l_index := l_temp_periods.NEXT (l_index);
  END LOOP;

/* changes done by senthil for emp terminate enhancement*/
  IF p_periodtab.COUNT > 0 THEN
   l_last_rowindex := p_periodtab.LAST;
   l_start_date := p_periodtab (l_last_rowindex).start_date;
   l_end_date := p_periodtab (l_last_rowindex).end_date;
   IF l_end_date > l_person_effective_end_date THEN
     open c_term_timecards_exists(p_resource_id,l_person_effective_end_date);
     fetch c_term_timecards_exists into l_term_tc_exists;
     close c_term_timecards_exists;
     if l_term_tc_exists = 0  then
        p_periodtab (l_last_rowindex).end_date := l_person_effective_end_date;
     end if;
   END IF;
  END IF;
/* end of changes made by senthil */

  IF p_periodtab.COUNT > 0 THEN
   l_first_rowindex := p_periodtab.FIRST;
   l_start_date := p_periodtab (l_first_rowindex).start_date;
   l_end_date := p_periodtab (l_first_rowindex).end_date;

   IF l_person_effective_start_date < l_start_date THEN
    p_periodtab (TO_NUMBER (TO_CHAR (l_person_effective_start_date, 'J'))).start_date :=
                                                                           l_person_effective_start_date;
    p_periodtab (TO_NUMBER (TO_CHAR (l_person_effective_start_date, 'J'))).end_date := l_start_date - 1;
   ELSIF  l_person_effective_start_date > l_start_date AND l_person_effective_start_date > l_end_date THEN --2975015
    p_periodtab.DELETE (l_first_rowindex);
   ELSIF l_person_effective_start_date > l_start_date THEN
    p_periodtab (TO_NUMBER (TO_CHAR (l_person_effective_start_date, 'J'))).start_date :=
                                                                           l_person_effective_start_date;
    p_periodtab (TO_NUMBER (TO_CHAR (l_person_effective_start_date, 'J'))).end_date :=
                                                                 p_periodtab (l_first_rowindex).end_date;
    p_periodtab.DELETE (l_first_rowindex);
   END IF;
  END IF;
 END get_resource_time_periods;

 PROCEDURE tc_edit_allowed (
  p_timecard_id hxc_time_building_blocks.time_building_block_id%TYPE
/*ADVICE(1568): Mode of parameter is not specified with IN parameter [521] */
                                                                    ,
  p_timecard_ovn
/*ADVICE(1571): Unreferenced parameter [552] */
                 hxc_time_building_blocks.object_version_number%TYPE
/*ADVICE(1573): Mode of parameter is not specified with IN parameter [521] */
                                                                    ,
  p_timecard_status VARCHAR2
/*ADVICE(1576): Mode of parameter is not specified with IN parameter [521] */
                            ,
  p_edit_allowed_preference hxc_pref_hierarchies.attribute1%TYPE
/*ADVICE(1579): Mode of parameter is not specified with IN parameter [521] */
                                                                ,
  p_edit_allowed IN OUT NOCOPY VARCHAR2
 ) IS
  CURSOR csr_chk_transfer IS
   SELECT 1
   FROM   DUAL
   WHERE  EXISTS ( SELECT 1
                   FROM   hxc_transactions t, hxc_transaction_details td
                   WHERE  td.time_building_block_id = p_timecard_id
/*ADVICE(1589): Cursor references an external variable (use a parameter) [209] */

AND                       t.transaction_id = td.transaction_id
AND                       t.TYPE = 'RETRIEVAL'
AND                       t.status = 'SUCCESS');

  l_proc
/*ADVICE(1596): Unreferenced variable [553] */
              VARCHAR2 (72);
  l_tc_status hxc_time_building_blocks.approval_status%TYPE;
  l_dummy     NUMBER (1);
 BEGIN
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
  	  l_proc := 'hxc_timekeeper_utilities'
                     || 'tc_edit_allowed';
  	  hr_utility.set_location('Entering '||l_proc, 10);
  end if;
--l_tc_status := hxc_timecard_search_pkg.get_timecard_status_code(p_timecard_id,p_Timecard_Ovn);
  l_tc_status := p_timecard_status;


  if g_debug then
  	  hr_utility.set_location('Processing '||l_proc, 20);
  end if;
  IF (p_edit_allowed_preference = 'NEW_WORKING_REJECTED') THEN
   if g_debug then
           hr_utility.set_location('Processing '||l_proc, 30);
   end if;
   IF ((l_tc_status = 'REJECTED') OR (l_tc_status = 'WORKING')) THEN
    p_edit_allowed := 'TRUE';
   ELSE
    p_edit_allowed := 'FALSE';
   END IF;
  ELSIF (p_edit_allowed_preference = 'SUBMITTED') THEN
   if g_debug then
   	   hr_utility.set_location('Processing '||l_proc, 40);
   end if;
   IF ((l_tc_status = 'REJECTED') OR (l_tc_status = 'WORKING') OR (l_tc_status = 'SUBMITTED')) THEN
    p_edit_allowed := 'TRUE';
   ELSE
    p_edit_allowed := 'FALSE';
   END IF;
  ELSIF (p_edit_allowed_preference = 'APPROVALS_INITIATED') THEN
      if g_debug then
      	      hr_utility.set_location('Processing '||l_proc, 50);
      end if;
   -- all we need to do here is check that this timecard
   -- has not been transferred successfully to any recipient
   -- applications
   OPEN csr_chk_transfer;
   FETCH csr_chk_transfer INTO l_dummy;

   IF csr_chk_transfer%FOUND THEN
    p_edit_allowed := 'FALSE';
   ELSE
    p_edit_allowed := 'TRUE';
   END IF;
  ELSIF (p_edit_allowed_preference = 'RETRO') THEN
     if g_debug then
     	     hr_utility.set_location('Processing '||l_proc, 60);
     end if;
   IF (   (l_tc_status = 'REJECTED')
       OR (l_tc_status = 'WORKING')
       OR (l_tc_status = 'SUBMITTED')
       OR (l_tc_status = 'APPROVED')
       OR (l_tc_status = 'ERROR')
      ) THEN
    p_edit_allowed := 'TRUE';
   ELSE
    p_edit_allowed := 'FALSE';
   END IF;
  ELSE
   if g_debug then
   	   hr_utility.set_location('Processing '||l_proc, 70);
   end if;
   p_edit_allowed := 'FALSE';
  END IF;


-- if the status is ERROR, we don't need to look at
-- the pref -> JUST RETURN TRUE;
  IF (l_tc_status = 'ERROR') THEN
   p_edit_allowed := 'TRUE';
  END IF;

 if g_debug then
         hr_utility.set_location('Leaving '||l_proc, 80);
 end if;
 END tc_edit_allowed;

 PROCEDURE convert_type_to_message_table (
  p_old_messages IN hxc_message_table_type,
  p_messages OUT NOCOPY hxc_self_service_time_deposit.message_table
 ) IS
  l_index     NUMBER
/*ADVICE(1668): NUMBER has no precision [315] */
                    ;
  l_new_index NUMBER
/*ADVICE(1671): NUMBER has no precision [315] */
                    ;
 BEGIN
  l_new_index := 1;
  l_index := p_old_messages.FIRST;

  LOOP
   EXIT WHEN NOT p_old_messages.EXISTS (l_index);
   p_messages (l_new_index).message_name := p_old_messages (l_index).message_name;
   p_messages (l_new_index).message_level := p_old_messages (l_index).message_level;
   p_messages (l_new_index).message_field := p_old_messages (l_index).message_field;
   p_messages (l_new_index).message_tokens := p_old_messages (l_index).message_tokens;
   p_messages (l_new_index).application_short_name := p_old_messages (l_index).application_short_name;
   p_messages (l_new_index).time_building_block_id := p_old_messages (l_index).time_building_block_id;
   p_messages (l_new_index).time_building_block_ovn := p_old_messages (l_index).time_building_block_ovn;
   p_messages (l_new_index).time_attribute_id := p_old_messages (l_index).time_attribute_id;
   p_messages (l_new_index).time_attribute_ovn := p_old_messages (l_index).time_attribute_ovn;
   l_new_index := l_new_index + 1;
   l_index := p_old_messages.NEXT (l_index);
  END LOOP;
 END convert_type_to_message_table;

 PROCEDURE manage_attributes (
  p_attribute_number IN NUMBER,
  p_insert_data_details IN hxc_timekeeper_process.t_time_info,
  p_old_value IN OUT NOCOPY VARCHAR2,
  p_new_value IN OUT NOCOPY VARCHAR2
 ) IS
 BEGIN
  IF p_attribute_number = 1 THEN
   p_new_value := p_insert_data_details.attr_id_1;
   p_old_value := p_insert_data_details.attr_oldid_1;
  ELSIF p_attribute_number = 2 THEN
   p_new_value := p_insert_data_details.attr_id_2;
   p_old_value := p_insert_data_details.attr_oldid_2;
  ELSIF p_attribute_number = 3 THEN
   p_new_value := p_insert_data_details.attr_id_3;
   p_old_value := p_insert_data_details.attr_oldid_3;
  ELSIF p_attribute_number = 4 THEN
   p_new_value := p_insert_data_details.attr_id_4;
   p_old_value := p_insert_data_details.attr_oldid_4;
  ELSIF p_attribute_number = 5 THEN
   p_new_value := p_insert_data_details.attr_id_5;
   p_old_value := p_insert_data_details.attr_oldid_5;
  ELSIF p_attribute_number = 6 THEN
   p_new_value := p_insert_data_details.attr_id_6;
   p_old_value := p_insert_data_details.attr_oldid_6;
  ELSIF p_attribute_number = 7 THEN
   p_new_value := p_insert_data_details.attr_id_7;
   p_old_value := p_insert_data_details.attr_oldid_7;
  ELSIF p_attribute_number = 8 THEN
   p_new_value := p_insert_data_details.attr_id_8;
   p_old_value := p_insert_data_details.attr_oldid_8;
  ELSIF p_attribute_number = 9 THEN
   p_new_value := p_insert_data_details.attr_id_9;
   p_old_value := p_insert_data_details.attr_oldid_9;
  ELSIF p_attribute_number = 10 THEN
   p_new_value := p_insert_data_details.attr_id_10;
   p_old_value := p_insert_data_details.attr_oldid_10;
  ELSIF p_attribute_number = 11 THEN
   p_new_value := p_insert_data_details.attr_id_11;
   p_old_value := p_insert_data_details.attr_oldid_11;
  ELSIF p_attribute_number = 12 THEN
   p_new_value := p_insert_data_details.attr_id_12;
   p_old_value := p_insert_data_details.attr_oldid_12;
  ELSIF p_attribute_number = 13 THEN
   p_new_value := p_insert_data_details.attr_id_13;
   p_old_value := p_insert_data_details.attr_oldid_13;
  ELSIF p_attribute_number = 14 THEN
   p_new_value := p_insert_data_details.attr_id_14;
   p_old_value := p_insert_data_details.attr_oldid_14;
  ELSIF p_attribute_number = 15 THEN
   p_new_value := p_insert_data_details.attr_id_15;
   p_old_value := p_insert_data_details.attr_oldid_15;
  ELSIF p_attribute_number = 16 THEN
   p_new_value := p_insert_data_details.attr_id_16;
   p_old_value := p_insert_data_details.attr_oldid_16;
  ELSIF p_attribute_number = 17 THEN
   p_new_value := p_insert_data_details.attr_id_17;
   p_old_value := p_insert_data_details.attr_oldid_17;
  ELSIF p_attribute_number = 18 THEN
   p_new_value := p_insert_data_details.attr_id_18;
   p_old_value := p_insert_data_details.attr_oldid_18;
  ELSIF p_attribute_number = 19 THEN
   p_new_value := p_insert_data_details.attr_id_19;
   p_old_value := p_insert_data_details.attr_oldid_19;
  ELSIF p_attribute_number = 20 THEN
   p_new_value := p_insert_data_details.attr_id_20;
   p_old_value := p_insert_data_details.attr_oldid_20;
  END IF;
 END;

 PROCEDURE manage_timeinfo (
  p_day_counter IN NUMBER,
  p_insert_detail IN hxc_timekeeper_process.t_time_info,
  p_measure IN OUT NOCOPY NUMBER,
  p_detail_id IN OUT NOCOPY hxc_time_building_blocks.time_building_block_id%TYPE,
  p_detail_ovn IN OUT NOCOPY NUMBER,
  p_detail_time_in IN OUT NOCOPY DATE,
  p_detail_time_out IN OUT NOCOPY DATE
 ) IS
  l_attribute_found
/*ADVICE(1773): Unreferenced variable [553] */
                    BOOLEAN;
 BEGIN
  IF p_day_counter = 0 THEN
   p_measure := p_insert_detail.day_1;
   p_detail_id := p_insert_detail.detail_id_1;
   p_detail_ovn := p_insert_detail.detail_ovn_1;
   p_detail_time_in := p_insert_detail.time_in_1;
   p_detail_time_out := p_insert_detail.time_out_1;
  ELSIF p_day_counter = 1 THEN
   p_measure := p_insert_detail.day_2;
   p_detail_id := p_insert_detail.detail_id_2;
   p_detail_ovn := p_insert_detail.detail_ovn_2;
   p_detail_time_in := p_insert_detail.time_in_2;
   p_detail_time_out := p_insert_detail.time_out_2;
  ELSIF p_day_counter = 2 THEN
   p_measure := p_insert_detail.day_3;
   p_detail_id := p_insert_detail.detail_id_3;
   p_detail_ovn := p_insert_detail.detail_ovn_3;
   p_detail_time_in := p_insert_detail.time_in_3;
   p_detail_time_out := p_insert_detail.time_out_3;
  ELSIF p_day_counter = 3 THEN
   p_measure := p_insert_detail.day_4;
   p_detail_id := p_insert_detail.detail_id_4;
   p_detail_ovn := p_insert_detail.detail_ovn_4;
   p_detail_time_in := p_insert_detail.time_in_4;
   p_detail_time_out := p_insert_detail.time_out_4;
  ELSIF p_day_counter = 4 THEN
   p_measure := p_insert_detail.day_5;
   p_detail_id := p_insert_detail.detail_id_5;
   p_detail_ovn := p_insert_detail.detail_ovn_5;
   p_detail_time_in := p_insert_detail.time_in_5;
   p_detail_time_out := p_insert_detail.time_out_5;
  ELSIF p_day_counter = 5 THEN
   p_measure := p_insert_detail.day_6;
   p_detail_id := p_insert_detail.detail_id_6;
   p_detail_ovn := p_insert_detail.detail_ovn_6;
   p_detail_time_in := p_insert_detail.time_in_6;
   p_detail_time_out := p_insert_detail.time_out_6;
  ELSIF p_day_counter = 6 THEN
   p_measure := p_insert_detail.day_7;
   p_detail_id := p_insert_detail.detail_id_7;
   p_detail_ovn := p_insert_detail.detail_ovn_7;
   p_detail_time_in := p_insert_detail.time_in_7;
   p_detail_time_out := p_insert_detail.time_out_7;
  ELSIF p_day_counter = 7 THEN
   p_measure := p_insert_detail.day_8;
   p_detail_id := p_insert_detail.detail_id_8;
   p_detail_ovn := p_insert_detail.detail_ovn_8;
   p_detail_time_in := p_insert_detail.time_in_8;
   p_detail_time_out := p_insert_detail.time_out_8;
  ELSIF p_day_counter = 8 THEN
   p_measure := p_insert_detail.day_9;
   p_detail_id := p_insert_detail.detail_id_9;
   p_detail_ovn := p_insert_detail.detail_ovn_9;
   p_detail_time_in := p_insert_detail.time_in_9;
   p_detail_time_out := p_insert_detail.time_out_9;
  ELSIF p_day_counter = 9 THEN
   p_measure := p_insert_detail.day_10;
   p_detail_id := p_insert_detail.detail_id_10;
   p_detail_ovn := p_insert_detail.detail_ovn_10;
   p_detail_time_in := p_insert_detail.time_in_10;
   p_detail_time_out := p_insert_detail.time_out_10;
  ELSIF p_day_counter = 10 THEN
   p_measure := p_insert_detail.day_11;
   p_detail_id := p_insert_detail.detail_id_11;
   p_detail_ovn := p_insert_detail.detail_ovn_11;
   p_detail_time_in := p_insert_detail.time_in_11;
   p_detail_time_out := p_insert_detail.time_out_11;
  ELSIF p_day_counter = 11 THEN
   p_measure := p_insert_detail.day_12;
   p_detail_id := p_insert_detail.detail_id_12;
   p_detail_ovn := p_insert_detail.detail_ovn_12;
   p_detail_time_in := p_insert_detail.time_in_12;
   p_detail_time_out := p_insert_detail.time_out_12;
  ELSIF p_day_counter = 12 THEN
   p_measure := p_insert_detail.day_13;
   p_detail_id := p_insert_detail.detail_id_13;
   p_detail_ovn := p_insert_detail.detail_ovn_13;
   p_detail_time_in := p_insert_detail.time_in_13;
   p_detail_time_out := p_insert_detail.time_out_13;
  ELSIF p_day_counter = 13 THEN
   p_measure := p_insert_detail.day_14;
   p_detail_id := p_insert_detail.detail_id_14;
   p_detail_ovn := p_insert_detail.detail_ovn_14;
   p_detail_time_in := p_insert_detail.time_in_14;
   p_detail_time_out := p_insert_detail.time_out_14;
  ELSIF p_day_counter = 14 THEN
   p_measure := p_insert_detail.day_15;
   p_detail_id := p_insert_detail.detail_id_15;
   p_detail_ovn := p_insert_detail.detail_ovn_15;
   p_detail_time_in := p_insert_detail.time_in_15;
   p_detail_time_out := p_insert_detail.time_out_15;
  ELSIF p_day_counter = 15 THEN
   p_measure := p_insert_detail.day_16;
   p_detail_id := p_insert_detail.detail_id_16;
   p_detail_ovn := p_insert_detail.detail_ovn_16;
   p_detail_time_in := p_insert_detail.time_in_16;
   p_detail_time_out := p_insert_detail.time_out_16;
  ELSIF p_day_counter = 16 THEN
   p_measure := p_insert_detail.day_17;
   p_detail_id := p_insert_detail.detail_id_17;
   p_detail_ovn := p_insert_detail.detail_ovn_17;
   p_detail_time_in := p_insert_detail.time_in_17;
   p_detail_time_out := p_insert_detail.time_out_17;
  ELSIF p_day_counter = 17 THEN
   p_measure := p_insert_detail.day_18;
   p_detail_id := p_insert_detail.detail_id_18;
   p_detail_ovn := p_insert_detail.detail_ovn_18;
   p_detail_time_in := p_insert_detail.time_in_18;
   p_detail_time_out := p_insert_detail.time_out_18;
  ELSIF p_day_counter = 18 THEN
   p_measure := p_insert_detail.day_19;
   p_detail_id := p_insert_detail.detail_id_19;
   p_detail_ovn := p_insert_detail.detail_ovn_19;
   p_detail_time_in := p_insert_detail.time_in_19;
   p_detail_time_out := p_insert_detail.time_out_19;
  ELSIF p_day_counter = 19 THEN
   p_measure := p_insert_detail.day_20;
   p_detail_id := p_insert_detail.detail_id_20;
   p_detail_ovn := p_insert_detail.detail_ovn_20;
   p_detail_time_in := p_insert_detail.time_in_20;
   p_detail_time_out := p_insert_detail.time_out_20;
  ELSIF p_day_counter = 20 THEN
   p_measure := p_insert_detail.day_21;
   p_detail_id := p_insert_detail.detail_id_21;
   p_detail_ovn := p_insert_detail.detail_ovn_21;
   p_detail_time_in := p_insert_detail.time_in_21;
   p_detail_time_out := p_insert_detail.time_out_21;
  ELSIF p_day_counter = 21 THEN
   p_measure := p_insert_detail.day_22;
   p_detail_id := p_insert_detail.detail_id_22;
   p_detail_ovn := p_insert_detail.detail_ovn_22;
   p_detail_time_in := p_insert_detail.time_in_22;
   p_detail_time_out := p_insert_detail.time_out_22;
  ELSIF p_day_counter = 22 THEN
   p_measure := p_insert_detail.day_23;
   p_detail_id := p_insert_detail.detail_id_23;
   p_detail_ovn := p_insert_detail.detail_ovn_23;
   p_detail_time_in := p_insert_detail.time_in_23;
   p_detail_time_out := p_insert_detail.time_out_23;
  ELSIF p_day_counter = 23 THEN
   p_measure := p_insert_detail.day_24;
   p_detail_id := p_insert_detail.detail_id_24;
   p_detail_ovn := p_insert_detail.detail_ovn_24;
   p_detail_time_in := p_insert_detail.time_in_24;
   p_detail_time_out := p_insert_detail.time_out_24;
  ELSIF p_day_counter = 24 THEN
   p_measure := p_insert_detail.day_25;
   p_detail_id := p_insert_detail.detail_id_25;
   p_detail_ovn := p_insert_detail.detail_ovn_25;
   p_detail_time_in := p_insert_detail.time_in_25;
   p_detail_time_out := p_insert_detail.time_out_25;
  ELSIF p_day_counter = 25 THEN
   p_measure := p_insert_detail.day_26;
   p_detail_id := p_insert_detail.detail_id_26;
   p_detail_ovn := p_insert_detail.detail_ovn_26;
   p_detail_time_in := p_insert_detail.time_in_26;
   p_detail_time_out := p_insert_detail.time_out_26;
  ELSIF p_day_counter = 26 THEN
   p_measure := p_insert_detail.day_27;
   p_detail_id := p_insert_detail.detail_id_27;
   p_detail_ovn := p_insert_detail.detail_ovn_27;
   p_detail_time_in := p_insert_detail.time_in_27;
   p_detail_time_out := p_insert_detail.time_out_27;
  ELSIF p_day_counter = 27 THEN
   p_measure := p_insert_detail.day_28;
   p_detail_id := p_insert_detail.detail_id_28;
   p_detail_ovn := p_insert_detail.detail_ovn_28;
   p_detail_time_in := p_insert_detail.time_in_28;
   p_detail_time_out := p_insert_detail.time_out_28;
  ELSIF p_day_counter = 28 THEN
   p_measure := p_insert_detail.day_29;
   p_detail_id := p_insert_detail.detail_id_29;
   p_detail_ovn := p_insert_detail.detail_ovn_29;
   p_detail_time_in := p_insert_detail.time_in_29;
   p_detail_time_out := p_insert_detail.time_out_29;
  ELSIF p_day_counter = 29 THEN
   p_measure := p_insert_detail.day_30;
   p_detail_id := p_insert_detail.detail_id_30;
   p_detail_ovn := p_insert_detail.detail_ovn_30;
   p_detail_time_in := p_insert_detail.time_in_30;
   p_detail_time_out := p_insert_detail.time_out_30;
  ELSIF p_day_counter = 30 THEN
   p_measure := p_insert_detail.day_31;
   p_detail_id := p_insert_detail.detail_id_31;
   p_detail_ovn := p_insert_detail.detail_ovn_31;
   p_detail_time_in := p_insert_detail.time_in_31;
   p_detail_time_out := p_insert_detail.time_out_31;
  END IF;
 END;

 PROCEDURE manage_detaildffinfo (
  p_detail_id IN hxc_time_building_blocks.time_building_block_id%TYPE,
  p_detail_ovn IN NUMBER,
  p_det_details IN OUT NOCOPY hxc_timekeeper_process.g_detail_data%TYPE,
  p_attributes IN OUT NOCOPY hxc_attribute_table_type,
  p_attribute_category IN VARCHAR2,
  p_tbb_id_reference_table IN OUT NOCOPY hxc_alias_utility.t_tbb_id_reference,
  p_attribute_index_info IN OUT NOCOPY hxc_timekeeper_process.t_attribute_index_info,
  p_timecard_index_info
/*ADVICE(1974): Unreferenced parameter [552] */
                        IN OUT NOCOPY hxc_timekeeper_process.t_timecard_index_info
 ) IS
  l_bldtyp_id       NUMBER
/*ADVICE(1978): NUMBER has no precision [315] */
                          ;
  l_attribute_index NUMBER
/*ADVICE(1981): NUMBER has no precision [315] */
                          ;
  l_attribute_found BOOLEAN;
 BEGIN
  IF  p_detail_id IS NOT NULL AND p_det_details.EXISTS (p_detail_id) THEN
   IF p_attribute_category IS NOT NULL THEN
    IF NVL (p_attribute_category, '-999') <> NVL (p_det_details (p_detail_id).dff_catg, '-999') THEN
     p_det_details (p_detail_id).dff_catg := p_attribute_category;
     p_det_details (p_detail_id).dff_attr1 := NULL;
     p_det_details (p_detail_id).dff_attr2 := NULL;
     p_det_details (p_detail_id).dff_attr3 := NULL;
     p_det_details (p_detail_id).dff_attr4 := NULL;
     p_det_details (p_detail_id).dff_attr5 := NULL;
     p_det_details (p_detail_id).dff_attr6 := NULL;
     p_det_details (p_detail_id).dff_attr7 := NULL;
     p_det_details (p_detail_id).dff_attr8 := NULL;
     p_det_details (p_detail_id).dff_attr9 := NULL;
     p_det_details (p_detail_id).dff_attr10 := NULL;
     p_det_details (p_detail_id).dff_attr11 := NULL;
     p_det_details (p_detail_id).dff_attr12 := NULL;
     p_det_details (p_detail_id).dff_attr13 := NULL;
     p_det_details (p_detail_id).dff_attr14 := NULL;
     p_det_details (p_detail_id).dff_attr15 := NULL;
     p_det_details (p_detail_id).dff_attr16 := NULL;
     p_det_details (p_detail_id).dff_attr17 := NULL;
     p_det_details (p_detail_id).dff_attr18 := NULL;
     p_det_details (p_detail_id).dff_attr19 := NULL;
     p_det_details (p_detail_id).dff_attr20 := NULL;
    END IF;
   ELSE
    p_det_details (p_detail_id).dff_catg := p_det_details (p_detail_id).dff_catg;
    p_det_details (p_detail_id).dff_attr1 := NULL;
    p_det_details (p_detail_id).dff_attr2 := NULL;
    p_det_details (p_detail_id).dff_attr3 := NULL;
    p_det_details (p_detail_id).dff_attr4 := NULL;
    p_det_details (p_detail_id).dff_attr5 := NULL;
    p_det_details (p_detail_id).dff_attr6 := NULL;
    p_det_details (p_detail_id).dff_attr7 := NULL;
    p_det_details (p_detail_id).dff_attr8 := NULL;
    p_det_details (p_detail_id).dff_attr9 := NULL;
    p_det_details (p_detail_id).dff_attr10 := NULL;
    p_det_details (p_detail_id).dff_attr11 := NULL;
    p_det_details (p_detail_id).dff_attr12 := NULL;
    p_det_details (p_detail_id).dff_attr13 := NULL;
    p_det_details (p_detail_id).dff_attr14 := NULL;
    p_det_details (p_detail_id).dff_attr15 := NULL;
    p_det_details (p_detail_id).dff_attr16 := NULL;
    p_det_details (p_detail_id).dff_attr17 := NULL;
    p_det_details (p_detail_id).dff_attr18 := NULL;
    p_det_details (p_detail_id).dff_attr19 := NULL;
    p_det_details (p_detail_id).dff_attr20 := NULL;
   END IF;

   IF      p_det_details.EXISTS (p_detail_id)
       AND (   NVL (p_det_details (p_detail_id).dff_catg, '-999') <>
                                                     NVL (p_det_details (p_detail_id).dff_oldcatg, '-999')
            OR NVL (p_det_details (p_detail_id).dff_attr1, '-999') <>
                                                    NVL (p_det_details (p_detail_id).dff_oldattr1, '-999')
            OR NVL (p_det_details (p_detail_id).dff_attr2, '-999') <>
                                                    NVL (p_det_details (p_detail_id).dff_oldattr2, '-999')
            OR NVL (p_det_details (p_detail_id).dff_attr3, '-999') <>
                                                    NVL (p_det_details (p_detail_id).dff_oldattr3, '-999')
            OR NVL (p_det_details (p_detail_id).dff_attr4, '-999') <>
                                                    NVL (p_det_details (p_detail_id).dff_oldattr4, '-999')
            OR NVL (p_det_details (p_detail_id).dff_attr5, '-999') <>
                                                    NVL (p_det_details (p_detail_id).dff_oldattr5, '-999')
            OR NVL (p_det_details (p_detail_id).dff_attr6, '-999') <>
                                                    NVL (p_det_details (p_detail_id).dff_oldattr6, '-999')
            OR NVL (p_det_details (p_detail_id).dff_attr7, '-999') <>
                                                    NVL (p_det_details (p_detail_id).dff_oldattr7, '-999')
            OR NVL (p_det_details (p_detail_id).dff_attr8, '-999') <>
                                                    NVL (p_det_details (p_detail_id).dff_oldattr8, '-999')
            OR NVL (p_det_details (p_detail_id).dff_attr9, '-999') <>
                                                    NVL (p_det_details (p_detail_id).dff_oldattr9, '-999')
            OR NVL (p_det_details (p_detail_id).dff_attr10, '-999') <>
                                                   NVL (p_det_details (p_detail_id).dff_oldattr10, '-999')
            OR NVL (p_det_details (p_detail_id).dff_attr11, '-999') <>
                                                   NVL (p_det_details (p_detail_id).dff_oldattr11, '-999')
            OR NVL (p_det_details (p_detail_id).dff_attr12, '-999') <>
                                                   NVL (p_det_details (p_detail_id).dff_oldattr12, '-999')
            OR NVL (p_det_details (p_detail_id).dff_attr13, '-999') <>
                                                   NVL (p_det_details (p_detail_id).dff_oldattr13, '-999')
            OR NVL (p_det_details (p_detail_id).dff_attr14, '-999') <>
                                                   NVL (p_det_details (p_detail_id).dff_oldattr14, '-999')
            OR NVL (p_det_details (p_detail_id).dff_attr15, '-999') <>
                                                   NVL (p_det_details (p_detail_id).dff_oldattr15, '-999')
            OR NVL (p_det_details (p_detail_id).dff_attr16, '-999') <>
                                                   NVL (p_det_details (p_detail_id).dff_oldattr16, '-999')
            OR NVL (p_det_details (p_detail_id).dff_attr17, '-999') <>
                                                   NVL (p_det_details (p_detail_id).dff_oldattr17, '-999')
            OR NVL (p_det_details (p_detail_id).dff_attr18, '-999') <>
                                                   NVL (p_det_details (p_detail_id).dff_oldattr18, '-999')
            OR NVL (p_det_details (p_detail_id).dff_attr19, '-999') <>
                                                   NVL (p_det_details (p_detail_id).dff_oldattr19, '-999')
            OR NVL (p_det_details (p_detail_id).dff_attr20, '-999') <>
                                                   NVL (p_det_details (p_detail_id).dff_oldattr20, '-999')
            OR NVL (p_det_details (p_detail_id).dff_attr21, '-999') <>
                                                   NVL (p_det_details (p_detail_id).dff_oldattr21, '-999')
            OR NVL (p_det_details (p_detail_id).dff_attr22, '-999') <>
                                                   NVL (p_det_details (p_detail_id).dff_oldattr22, '-999')
            OR NVL (p_det_details (p_detail_id).dff_attr23, '-999') <>
                                                   NVL (p_det_details (p_detail_id).dff_oldattr23, '-999')
            OR NVL (p_det_details (p_detail_id).dff_attr24, '-999') <>
                                                   NVL (p_det_details (p_detail_id).dff_oldattr24, '-999')
            OR NVL (p_det_details (p_detail_id).dff_attr25, '-999') <>
                                                   NVL (p_det_details (p_detail_id).dff_oldattr25, '-999')
            OR NVL (p_det_details (p_detail_id).dff_attr26, '-999') <>
                                                   NVL (p_det_details (p_detail_id).dff_oldattr26, '-999')
            OR NVL (p_det_details (p_detail_id).dff_attr27, '-999') <>
                                                   NVL (p_det_details (p_detail_id).dff_oldattr27, '-999')
            OR NVL (p_det_details (p_detail_id).dff_attr28, '-999') <>
                                                   NVL (p_det_details (p_detail_id).dff_oldattr28, '-999')
            OR NVL (p_det_details (p_detail_id).dff_attr29, '-999') <>
                                                   NVL (p_det_details (p_detail_id).dff_oldattr29, '-999')
            OR NVL (p_det_details (p_detail_id).dff_attr30, '-999') <>
                                                   NVL (p_det_details (p_detail_id).dff_oldattr30, '-999')
           ) THEN
    BEGIN
     SELECT bld_blk_info_type_id
     INTO   l_bldtyp_id
     FROM   hxc_bld_blk_info_types
     WHERE  bld_blk_info_type = 'Dummy Paexpitdff Context';
    EXCEPTION
     WHEN OTHERS THEN
      NULL;
/*ADVICE(2106): Use of NULL statements [532] */

/*ADVICE(2108): Exception masked by a NULL statement [533] */

/*ADVICE(2110): A WHEN OTHERS clause is used in the exception section without any other specific handlers
              [201] */

    END;

    IF NVL (l_bldtyp_id, -999) <> -999 THEN
     l_attribute_found := FALSE;
     --l_attribute_index :=
     hxc_alias_utility.attribute_check (
      p_bld_blk_info_type_id => l_bldtyp_id,
      p_time_building_block_id => p_detail_id,
      p_attributes => p_attributes,
      p_tbb_id_reference_table => p_tbb_id_reference_table,
      p_attribute_found => l_attribute_found,
      p_attribute_index => l_attribute_index
     );

     -- now we need to check if we need to create an attribute or do an update
     --IF l_attribute_index = -1 THEN
     IF NOT (l_attribute_found) THEN
      hxc_timekeeper_process.g_negative_index := hxc_timekeeper_process.g_negative_index - 1;
      l_attribute_index := hxc_timekeeper_process.g_negative_index;
      hxc_timekeeper_utilities.add_dff_attribute (
       p_attribute => p_attributes,
       p_attribute_id => l_attribute_index,
       p_tbb_id => p_detail_id,
       p_tbb_ovn => p_detail_ovn,
       p_blk_type => 'Dummy Paexpitdff Context',
       p_blk_id => l_bldtyp_id,
       p_att_category => p_det_details (p_detail_id).dff_catg,
       p_att_1 => p_det_details (p_detail_id).dff_attr1,
       p_att_2 => p_det_details (p_detail_id).dff_attr2,
       p_att_3 => p_det_details (p_detail_id).dff_attr3,
       p_att_4 => p_det_details (p_detail_id).dff_attr4,
       p_att_5 => p_det_details (p_detail_id).dff_attr5,
       p_att_6 => p_det_details (p_detail_id).dff_attr6,
       p_att_7 => p_det_details (p_detail_id).dff_attr7,
       p_att_8 => p_det_details (p_detail_id).dff_attr8,
       p_att_9 => p_det_details (p_detail_id).dff_attr9,
       p_att_10 => p_det_details (p_detail_id).dff_attr10,
       p_att_11 => p_det_details (p_detail_id).dff_attr11,
       p_att_12 => p_det_details (p_detail_id).dff_attr12,
       p_att_13 => p_det_details (p_detail_id).dff_attr13,
       p_att_14 => p_det_details (p_detail_id).dff_attr14,
       p_att_15 => p_det_details (p_detail_id).dff_attr15,
       p_att_16 => p_det_details (p_detail_id).dff_attr16,
       p_att_17 => p_det_details (p_detail_id).dff_attr17,
       p_att_18 => p_det_details (p_detail_id).dff_attr18,
       p_att_19 => p_det_details (p_detail_id).dff_attr19,
       p_att_20 => p_det_details (p_detail_id).dff_attr20,
       p_att_21 => p_det_details (p_detail_id).dff_attr21,
       p_att_22 => p_det_details (p_detail_id).dff_attr22,
       p_att_23 => p_det_details (p_detail_id).dff_attr23,
       p_att_24 => p_det_details (p_detail_id).dff_attr24,
       p_att_25 => p_det_details (p_detail_id).dff_attr25,
       p_att_26 => p_det_details (p_detail_id).dff_attr26,
       p_att_27 => p_det_details (p_detail_id).dff_attr27,
       p_att_28 => p_det_details (p_detail_id).dff_attr28,
       p_att_29 => p_det_details (p_detail_id).dff_attr29,
       p_att_30 => p_det_details (p_detail_id).dff_attr30,
       p_attribute_index_info => p_attribute_index_info
      );

      -- add the new attribute in the ref table
      IF p_tbb_id_reference_table.EXISTS (p_detail_id) THEN
       p_tbb_id_reference_table (p_detail_id).attribute_index :=
         p_tbb_id_reference_table (p_detail_id).attribute_index || '|'
         || hxc_timekeeper_process.g_negative_index;
      ELSE
       p_tbb_id_reference_table (p_detail_id).attribute_index :=
                                                           '|' || hxc_timekeeper_process.g_negative_index;
      END IF;
     ELSE
      l_attribute_index := p_attributes (l_attribute_index).time_attribute_id;
      hxc_timekeeper_utilities.add_dff_attribute (
       p_attribute => p_attributes,
       p_attribute_id => l_attribute_index,
       p_tbb_id => p_detail_id,
       p_tbb_ovn => p_detail_ovn,
       p_blk_type => 'Dummy Paexpitdff Context',
       p_blk_id => l_bldtyp_id,
       p_att_category => p_det_details (p_detail_id).dff_catg,
       p_att_1 => p_det_details (p_detail_id).dff_attr1,
       p_att_2 => p_det_details (p_detail_id).dff_attr2,
       p_att_3 => p_det_details (p_detail_id).dff_attr3,
       p_att_4 => p_det_details (p_detail_id).dff_attr4,
       p_att_5 => p_det_details (p_detail_id).dff_attr5,
       p_att_6 => p_det_details (p_detail_id).dff_attr6,
       p_att_7 => p_det_details (p_detail_id).dff_attr7,
       p_att_8 => p_det_details (p_detail_id).dff_attr8,
       p_att_9 => p_det_details (p_detail_id).dff_attr9,
       p_att_10 => p_det_details (p_detail_id).dff_attr10,
       p_att_11 => p_det_details (p_detail_id).dff_attr11,
       p_att_12 => p_det_details (p_detail_id).dff_attr12,
       p_att_13 => p_det_details (p_detail_id).dff_attr13,
       p_att_14 => p_det_details (p_detail_id).dff_attr14,
       p_att_15 => p_det_details (p_detail_id).dff_attr15,
       p_att_16 => p_det_details (p_detail_id).dff_attr16,
       p_att_17 => p_det_details (p_detail_id).dff_attr17,
       p_att_18 => p_det_details (p_detail_id).dff_attr18,
       p_att_19 => p_det_details (p_detail_id).dff_attr19,
       p_att_20 => p_det_details (p_detail_id).dff_attr20,
       p_att_21 => p_det_details (p_detail_id).dff_attr21,
       p_att_22 => p_det_details (p_detail_id).dff_attr22,
       p_att_23 => p_det_details (p_detail_id).dff_attr23,
       p_att_24 => p_det_details (p_detail_id).dff_attr24,
       p_att_25 => p_det_details (p_detail_id).dff_attr25,
       p_att_26 => p_det_details (p_detail_id).dff_attr26,
       p_att_27 => p_det_details (p_detail_id).dff_attr27,
       p_att_28 => p_det_details (p_detail_id).dff_attr28,
       p_att_29 => p_det_details (p_detail_id).dff_attr29,
       p_att_30 => p_det_details (p_detail_id).dff_attr30,
       p_attribute_index_info => p_attribute_index_info
      );
     END IF;
    END IF; ----no dff context in database
   END IF;
  END IF;
 END;

 PROCEDURE check_msg_set_process_flag (
  p_blocks IN OUT NOCOPY hxc_block_table_type,
  p_attributes IN OUT NOCOPY hxc_attribute_table_type,
  p_messages IN OUT NOCOPY hxc_message_table_type
 ) IS
  l_change_process_flag BOOLEAN        := FALSE;
  l_index               BINARY_INTEGER
/*ADVICE(2237): Consider using PLS_INTEGER instead of INTEGER and BINARY_INTEGER if on Oracle 7.3 or above
              [302] */
                                      ;
  l_delete_index        BINARY_INTEGER
/*ADVICE(2241): Consider using PLS_INTEGER instead of INTEGER and BINARY_INTEGER if on Oracle 7.3 or above
              [302] */
                                      ;
  l_timecard_status     VARCHAR2 (50)  := NULL;
/*ADVICE(2245): Initialization to NULL is superfluous [417] */

  l_timecard_id         NUMBER
/*ADVICE(2248): NUMBER has no precision [315] */
                              ;
  l_timecard_ovn        NUMBER
/*ADVICE(2251): NUMBER has no precision [315] */
                              ;
 BEGIN
  l_change_process_flag := FALSE;
  l_delete_index := NULL;
  l_index := p_messages.FIRST;

  WHILE l_index IS NOT NULL LOOP
   IF p_messages (l_index).message_name = 'HXC_TIMECARD_NOT_SUBMITTED' THEN
    l_change_process_flag := TRUE;
    l_delete_index := l_index;
    EXIT;
/*ADVICE(2263): An EXIT statement is used in a WHILE loop [502] */

   END IF;

   l_index := p_messages.NEXT (l_index);
  END LOOP;

  IF l_change_process_flag THEN
   -- if we passed the above then we need to change the status
   -- to be process so that the TC get's submitted this
   -- is when rejected TC is submitted without any change
   l_timecard_id :=
        p_blocks (hxc_timecard_block_utils.find_active_timecard_index (p_blocks)).time_building_block_id;
   l_timecard_ovn :=
         p_blocks (hxc_timecard_block_utils.find_active_timecard_index (p_blocks)).object_version_number;
   l_timecard_status := hxc_timecard_search_pkg.get_timecard_status_code (l_timecard_id, l_timecard_ovn);

   IF l_timecard_status = 'REJECTED' THEN
    l_index := p_blocks.FIRST;

    WHILE l_index IS NOT NULL LOOP
     p_blocks (l_index).process := 'Y';
     p_blocks (l_index).changed := 'Y';
     l_index := p_blocks.NEXT (l_index);
    END LOOP;

    l_index := p_attributes.FIRST;

    WHILE l_index IS NOT NULL LOOP
     p_attributes (l_index).process := 'Y';
     p_attributes (l_index).changed := 'Y';
     l_index := p_attributes.NEXT (l_index);
    END LOOP;

    IF l_delete_index IS NOT NULL THEN
     --now delete the error as we have handled it
     p_messages.DELETE (l_delete_index);
    END IF;
   END IF;
  END IF;
 END check_msg_set_process_flag;


-- ----------------------------------------------------------------------------
--  Used to loop through all the persons in TK group
--  and do bulk pref evaluation
-- ----------------------------------------------------------------------------
 PROCEDURE cache_employee_pref_in_group (
  p_group_id IN NUMBER,
  p_timekeeper_id IN NUMBER
 ) IS
  l_resource_pref_index NUMBER
/*ADVICE(2315): NUMBER has no precision [315] */
                              ;
  l_pref_table          hxc_preference_evaluation.t_pref_table;
  l_resource_table      hxc_preference_evaluation.t_resource_pref_table;
  l_query_append        VARCHAR2 (32000);
/*ADVICE(2320): VARCHAR2 declaration with length greater than 500 characters [307] */


  CURSOR c_emp_hireinfo (
   p_resource_id NUMBER
  ) IS
   SELECT MIN (effective_start_date)
   FROM   per_people_f
   WHERE  person_id = p_resource_id;

/*Cursor Modified By Mithun for CWK Terminate Bug*/
  /* changes done by senthil for emp terminate enhancement*/
  CURSOR c_emp_terminateinfo(
   p_resource_id NUMBER
  ) IS
  SELECT final_process_date, date_start
  FROM per_periods_of_service
  WHERE person_id = p_resource_id
  union all
  select (final_process_date + NVL(fnd_profile.value('HXC_CWK_TK_FPD'),0)) final_process_date, date_start
  from per_periods_of_placement
  where person_id = p_resource_id
  ORDER BY date_start DESC;

--Added By Mithun for CWK Terminate Bug
  date_start	DATE;

  /*end of changes by senthil */
 BEGIN
  l_query_append := ' in (select htgqc.criteria_id resource_id  ';
  l_query_append :=
                  l_query_append || ' from  hxc_tk_group_queries htgq, HXC_TK_GROUP_QUERY_CRITERIA htgqc ';
  l_query_append := l_query_append
                    || ' where htgq.tk_group_query_id = htgqc.tk_group_query_id and htgq.tk_group_id='
                    || p_group_id || ' ) ';
  l_pref_table.DELETE;
  l_resource_table.DELETE;
  g_start_stop_pref_cache.DELETE;
  hxc_preference_evaluation.resource_prefs_bulk (
   p_evaluation_date => SYSDATE,
   p_pref_table => l_pref_table,
   p_resource_pref_table => l_resource_table,
   p_resource_sql => l_query_append
  );
  l_resource_pref_index := l_resource_table.FIRST;

  LOOP
   EXIT WHEN (NOT l_resource_table.EXISTS (l_resource_pref_index));

   IF p_timekeeper_id <> l_resource_pref_index THEN
    IF g_start_stop_pref_cache.EXISTS (l_resource_table (l_resource_pref_index).start_index) THEN
     g_resource_perftab (l_resource_pref_index) :=
                          g_start_stop_pref_cache (l_resource_table (l_resource_pref_index).start_index);
     OPEN c_emp_hireinfo (p_resource_id => l_resource_pref_index);
     FETCH c_emp_hireinfo INTO g_resource_perftab (l_resource_pref_index).res_emp_start_date;
     CLOSE c_emp_hireinfo;
    /*Changes Done By Mithun for CWK Terminate Bug*/
     /* changes done by senthil for emp terminate enhancement*/
     OPEN c_emp_terminateinfo (p_resource_id => l_resource_pref_index);
     FETCH c_emp_terminateinfo INTO g_resource_perftab (l_resource_pref_index).res_emp_terminate_date, date_start;
     CLOSE c_emp_terminateinfo;
     /*end of changes by senthil*/
    ELSE
     OPEN c_emp_hireinfo (p_resource_id => l_resource_pref_index);
     FETCH c_emp_hireinfo INTO g_resource_perftab (l_resource_pref_index).res_emp_start_date;
     CLOSE c_emp_hireinfo;

     /*Changes Done By Mithun for CWK Terminate Bug*/
     /* changes done by senthil for emp terminate enhancement*/
     OPEN c_emp_terminateinfo (p_resource_id => l_resource_pref_index);
     FETCH c_emp_terminateinfo INTO g_resource_perftab (l_resource_pref_index).res_emp_terminate_date, date_start;
     CLOSE c_emp_terminateinfo;
     /*end of changes by senthil*/
     FOR l_index IN
       l_resource_table (l_resource_pref_index).start_index .. l_resource_table (l_resource_pref_index).stop_index LOOP
      hxc_timekeeper_utilities.add_resource_to_perftab (
       p_resource_id => l_resource_pref_index,
       p_pref_code => l_pref_table (l_index).preference_code,
       p_attribute1 => l_pref_table (l_index).attribute1,
       p_attribute2 => l_pref_table (l_index).attribute2,
       p_attribute3 => l_pref_table (l_index).attribute3,
       p_attribute4 => l_pref_table (l_index).attribute4,
       p_attribute5 => l_pref_table (l_index).attribute5,
       p_attribute6 => l_pref_table (l_index).attribute6,
       p_attribute7 => l_pref_table (l_index).attribute7,
       p_attribute8 => l_pref_table (l_index).attribute8,
       p_attribute11 => l_pref_table (l_index).attribute11
      );
     END LOOP;
/*ADVICE(2378): Nested LOOPs should all be labeled [406] */


     g_start_stop_pref_cache (l_resource_table (l_resource_pref_index).start_index) :=
                                                               g_resource_perftab (l_resource_pref_index);
    END IF;
   END IF;

   l_resource_pref_index := l_resource_table.NEXT (l_resource_pref_index);
  END LOOP;
 END cache_employee_pref_in_group;


-- ----------------------------------------------------------------------------
--  Used to loop through all the persons in TK group
--  and get the recurring period informations
-- ----------------------------------------------------------------------------
 PROCEDURE get_group_period_list (
  p_group_id IN NUMBER,
  p_business_group_id IN NUMBER,
  p_periodname_list OUT NOCOPY hxc_timekeeper_utilities.t_group_list
 ) IS
/*start of fix 5083261*/
  CURSOR c_pref_cursor IS
select recurring_period_id rec_period,rownum periodname_index from (
   SELECT distinct c.recurring_period_id,c.name
      FROM            hxc_pref_hierarchies a, hxc_resource_rules b, hxc_recurring_periods c
      WHERE           a.attribute_category = 'TC_W_TCRD_PERIOD'
	  and a.attribute1 = c.recurring_period_id
   AND                a.top_level_parent_id = b.pref_hierarchy_id
   AND                p_business_group_id = NVL (a.business_group_id, p_business_group_id) order by c.name);
/*end of fix 5083261*/
  l_pref_resource
/*ADVICE(2415): Unreferenced variable [553] */
                     hxc_preference_evaluation.t_pref_table;
  l_periodname_list
/*ADVICE(2418): Unreferenced variable [553] */
                     hxc_timekeeper_utilities.t_group_list;
  l_pref_index
/*ADVICE(2421): Unreferenced variable [553] */
                     NUMBER
/*ADVICE(2423): NUMBER has no precision [315] */
                           ;
  l_periodname_index NUMBER
/*ADVICE(2426): NUMBER has no precision [315] */
                           ;
 BEGIN
  p_periodname_list.DELETE;

  FOR l_pref IN c_pref_cursor LOOP
/*start fix for 5083261 */
l_periodname_index := l_pref.periodname_index;
/*end of fix 5083261*/
   p_periodname_list (l_periodname_index).recurring_period_id := l_pref.rec_period;
   p_periodname_list (l_periodname_index).GROUP_ID := p_group_id;
  END LOOP;
 END;


-----------------------------------------------------------------------------
--  Used to get the select statement depending upon the alias
------------------------------------------------------------------------------
 PROCEDURE get_type_sql (
  p_aliasid IN NUMBER,
  p_person_type IN VARCHAR2 DEFAULT NULL,
  p_alias_typ OUT NOCOPY VARCHAR2,
  p_alias_sql OUT NOCOPY LONG
/*ADVICE(2447): Use of LONG [117] */
                      ,
  p_maxsize OUT NOCOPY NUMBER,
  p_minvalue OUT NOCOPY NUMBER,
  p_maxvalue OUT NOCOPY NUMBER,
  p_precision OUT NOCOPY NUMBER,
  p_colmtype OUT NOCOPY VARCHAR2
 ) IS
  l_alias_type       VARCHAR2 (80)   := NULL;
/*ADVICE(2456): Initialization to NULL is superfluous [417] */

  l_ref_obj          VARCHAR2 (2000) := NULL;
/*ADVICE(2459): VARCHAR2 declaration with length greater than 500 characters [307] */

/*ADVICE(2461): Initialization to NULL is superfluous [417] */

  l_s_query          LONG
/*ADVICE(2464): Use of LONG [117] */
                                     := NULL;
/*ADVICE(2466): Initialization to NULL is superfluous [417] */

  l_index
/*ADVICE(2469): Unreferenced variable [553] */
                     NUMBER
/*ADVICE(2471): NUMBER has no precision [315] */
                                     := 0;
  l_a                VARCHAR2 (300);
  l_max_size         NUMBER
/*ADVICE(2475): NUMBER has no precision [315] */
                                     := 0;
  l_min_value        NUMBER
/*ADVICE(2478): NUMBER has no precision [315] */
                                     := 0;
  l_max_value        NUMBER
/*ADVICE(2481): NUMBER has no precision [315] */
                                     := 0;
  l_number_precision NUMBER
/*ADVICE(2484): NUMBER has no precision [315] */
                                     := 0;
  l_colmtype         VARCHAR2 (10);
 BEGIN
  hxc_alias_utility.get_alias_definition_info (
   p_alias_definition_id => p_aliasid,
   p_alias_type => l_alias_type,
   p_reference_object => l_ref_obj,
   p_prompt => l_a
  );

  IF l_alias_type = 'VALUE_SET_TABLE' THEN
   hxc_alias_utility.get_vset_table_type_select (
    p_alias_definition_id => p_aliasid,
    x_select => l_s_query,
    p_id_type => l_colmtype
   );
   l_s_query := 'select display_value,id_value from (' || l_s_query || ') ';
  ELSIF l_alias_type = 'VALUE_SET_INDEPENDENT' THEN
   hxc_alias_utility.get_vset_indep_type_select (
    p_alias_definition_id => p_aliasid,
    x_select => l_s_query
   );
   l_s_query := 'select display_value,id_value from (' || l_s_query || ') ';
   l_colmtype := 'NUMBER';
  ELSIF l_alias_type = 'OTL_ALT_DDF' THEN
   hxc_alias_utility.get_otl_an_context_type_select (
    p_alias_definition_id => p_aliasid,
    p_timekeeper_person_type => p_person_type,
    x_select => l_s_query
   );
   l_s_query := 'select display_value,id_value from (' || l_s_query || ') ';
   l_colmtype := 'NUMBER';
  ELSIF l_alias_type = 'VALUE_SET_NONE' THEN
   hxc_alias_utility.get_vset_none_type_property (
    p_alias_definition_id => p_aliasid,
    p_format_type => l_s_query,
    p_maximum_size => l_max_size,
    p_minimum_value => l_min_value,
    p_maximum_value => l_max_value,
    p_number_precision => l_number_precision
   );
  END IF;

  p_alias_typ := l_alias_type;
  p_alias_sql := l_s_query;
  p_maxsize := l_max_size;
  p_minvalue := l_min_value;
  p_maxvalue := l_max_value;
  p_precision := l_number_precision;
  p_colmtype := l_colmtype;
 END get_type_sql;


-- ----------------------------------------------------------------------------
--  Used in form to get alias information for all the Timekeeper layout attributes
-- ----------------------------------------------------------------------------
 PROCEDURE populate_alias_table (
  p_timekeeper_id IN NUMBER,
  p_tk_layout_info OUT NOCOPY hxc_timekeeper_utilities.tk_layout_tab,
  p_att_alias_table OUT NOCOPY hxc_timekeeper_utilities.att_alias_list
 ) IS
  l_pref_table       hxc_preference_evaluation.t_pref_table;
  l_index            NUMBER
/*ADVICE(2548): NUMBER has no precision [315] */
                                                            := 0;
  m_alias_typ        VARCHAR2 (80)                          := NULL;
/*ADVICE(2551): Initialization to NULL is superfluous [417] */

  m_alias_sql        LONG
/*ADVICE(2554): Use of LONG [117] */
                                                            := NULL;
/*ADVICE(2556): Initialization to NULL is superfluous [417] */

  m_alias_maxsize    NUMBER
/*ADVICE(2559): NUMBER has no precision [315] */
                           ;
  m_alias_minvalue   NUMBER
/*ADVICE(2562): NUMBER has no precision [315] */
                           ;
  m_alias_maxvalue   NUMBER
/*ADVICE(2565): NUMBER has no precision [315] */
                           ;
  m_alias_precision  NUMBER
/*ADVICE(2568): NUMBER has no precision [315] */
                           ;
  m_alias_lovcoltype VARCHAR2 (10);
  /*Start fix for Bug 5055770 */
  l_person_type      PER_PERSON_TYPES.SYSTEM_PERSON_TYPE%TYPE:=NULL;
  /*End fix for Bug 5055770 */
/*ADVICE(2572): Initialization to NULL is superfluous [417] */


  CURSOR c_get_type (
   p_person_id NUMBER
  ) IS
   SELECT typ.system_person_type
   FROM   per_person_types typ, per_person_type_usages_f ptu
   WHERE  typ.person_type_id = ptu.person_type_id
AND       SYSDATE BETWEEN ptu.effective_start_date AND ptu.effective_end_date
AND       ptu.person_id = p_person_id;
 BEGIN
  hxc_preference_evaluation.resource_preferences (p_timekeeper_id, l_pref_table, SYSDATE);
  OPEN c_get_type (p_timekeeper_id);
  FETCH c_get_type INTO l_person_type;
  CLOSE c_get_type;
  l_index := l_pref_table.FIRST;

  LOOP
   EXIT WHEN (NOT l_pref_table.EXISTS (l_index));

   IF (l_pref_table (l_index).preference_code = 'TK_TCARD_SETUP') THEN
    p_tk_layout_info (1).tk_timeflag := l_pref_table (l_index).attribute1;
    p_tk_layout_info (1).tk_empno := l_pref_table (l_index).attribute3;
    p_tk_layout_info (1).tk_empname := l_pref_table (l_index).attribute2;
    p_tk_layout_info (1).tk_base_attr := l_pref_table (l_index).attribute4;
    p_tk_layout_info (1).tk_applset := l_pref_table (l_index).attribute5;

    -- Added for Enh 3303359
        --    Caching the pref value for Default Recurring Period
    hxc_timekeeper_utilities.g_default_rec_period:= l_pref_table (l_index).attribute6;


   ELSIF (l_pref_table (l_index).preference_code = 'TK_TCARD_CLA') THEN --CTK
    p_tk_layout_info (1).tk_audit_enabled := l_pref_table (l_index).attribute1;
    p_tk_layout_info (1).tk_data_entry_required := l_pref_table (l_index).attribute2;
    p_tk_layout_info (1).tk_notification_to := l_pref_table (l_index).attribute3;
    p_tk_layout_info (1).tk_notification_type := l_pref_table (l_index).attribute4;
   ELSIF (l_pref_table (l_index).preference_code = 'TK_TCARD_ATTRIBUTES_DEFINITION') THEN
    m_alias_sql := NULL;
    m_alias_typ := NULL;
    p_att_alias_table (1).attr_name := 'ATTRIBUTE1';
    p_att_alias_table (1).alias_id := l_pref_table (l_index).attribute1;

    IF p_att_alias_table (1).alias_id IS NOT NULL THEN
     get_type_sql (
      p_aliasid => p_att_alias_table (1).alias_id,
      p_person_type => l_person_type,
      p_alias_typ => m_alias_typ,
      p_alias_sql => m_alias_sql,
      p_maxsize => m_alias_maxsize,
      p_minvalue => m_alias_minvalue,
      p_maxvalue => m_alias_maxvalue,
      p_precision => m_alias_precision,
      p_colmtype => m_alias_lovcoltype
     );
     p_att_alias_table (1).alias_sql := m_alias_sql;
     p_att_alias_table (1).alias_type := m_alias_typ;
     p_att_alias_table (1).alias_maxsize := m_alias_maxsize;
     p_att_alias_table (1).alias_minvalue := m_alias_minvalue;
     p_att_alias_table (1).alias_maxvalue := m_alias_maxvalue;
     p_att_alias_table (1).alias_precision := m_alias_precision;
     p_att_alias_table (1).alias_lovcoltype := m_alias_lovcoltype;
    END IF;

    p_att_alias_table (2).attr_name := 'ATTRIBUTE2';
    p_att_alias_table (2).alias_id := l_pref_table (l_index).attribute2;

    IF p_att_alias_table (2).alias_id IS NOT NULL THEN
     get_type_sql (
      p_aliasid => p_att_alias_table (2).alias_id,
      p_person_type => l_person_type,
      p_alias_typ => m_alias_typ,
      p_alias_sql => m_alias_sql,
      p_maxsize => m_alias_maxsize,
      p_minvalue => m_alias_minvalue,
      p_maxvalue => m_alias_maxvalue,
      p_precision => m_alias_precision,
      p_colmtype => m_alias_lovcoltype
     );
     p_att_alias_table (2).alias_sql := m_alias_sql;
     p_att_alias_table (2).alias_type := m_alias_typ;
     p_att_alias_table (2).alias_maxsize := m_alias_maxsize;
     p_att_alias_table (2).alias_minvalue := m_alias_minvalue;
     p_att_alias_table (2).alias_maxvalue := m_alias_maxvalue;
     p_att_alias_table (2).alias_precision := m_alias_precision;
     p_att_alias_table (2).alias_lovcoltype := m_alias_lovcoltype;
    END IF;

    p_att_alias_table (3).attr_name := 'ATTRIBUTE3';
    p_att_alias_table (3).alias_id := l_pref_table (l_index).attribute3;

    IF p_att_alias_table (3).alias_id IS NOT NULL THEN
     get_type_sql (
      p_aliasid => p_att_alias_table (3).alias_id,
      p_person_type => l_person_type,
      p_alias_typ => m_alias_typ,
      p_alias_sql => m_alias_sql,
      p_maxsize => m_alias_maxsize,
      p_minvalue => m_alias_minvalue,
      p_maxvalue => m_alias_maxvalue,
      p_precision => m_alias_precision,
      p_colmtype => m_alias_lovcoltype
     );
     p_att_alias_table (3).alias_sql := m_alias_sql;
     p_att_alias_table (3).alias_type := m_alias_typ;
     p_att_alias_table (3).alias_maxsize := m_alias_maxsize;
     p_att_alias_table (3).alias_minvalue := m_alias_minvalue;
     p_att_alias_table (3).alias_maxvalue := m_alias_maxvalue;
     p_att_alias_table (3).alias_precision := m_alias_precision;
     p_att_alias_table (3).alias_lovcoltype := m_alias_lovcoltype;
    END IF;

    p_att_alias_table (4).attr_name := 'ATTRIBUTE4';
    p_att_alias_table (4).alias_id := l_pref_table (l_index).attribute4;

    IF p_att_alias_table (4).alias_id IS NOT NULL THEN
     get_type_sql (
      p_aliasid => p_att_alias_table (4).alias_id,
      p_person_type => l_person_type,
      p_alias_typ => m_alias_typ,
      p_alias_sql => m_alias_sql,
      p_maxsize => m_alias_maxsize,
      p_minvalue => m_alias_minvalue,
      p_maxvalue => m_alias_maxvalue,
      p_precision => m_alias_precision,
      p_colmtype => m_alias_lovcoltype
     );
     p_att_alias_table (4).alias_sql := m_alias_sql;
     p_att_alias_table (4).alias_type := m_alias_typ;
     p_att_alias_table (4).alias_maxsize := m_alias_maxsize;
     p_att_alias_table (4).alias_minvalue := m_alias_minvalue;
     p_att_alias_table (4).alias_maxvalue := m_alias_maxvalue;
     p_att_alias_table (4).alias_precision := m_alias_precision;
     p_att_alias_table (4).alias_lovcoltype := m_alias_lovcoltype;
    END IF;

    p_att_alias_table (5).attr_name := 'ATTRIBUTE5';
    p_att_alias_table (5).alias_id := l_pref_table (l_index).attribute5;

    IF p_att_alias_table (5).alias_id IS NOT NULL THEN
     get_type_sql (
      p_aliasid => p_att_alias_table (5).alias_id,
      p_person_type => l_person_type,
      p_alias_typ => m_alias_typ,
      p_alias_sql => m_alias_sql,
      p_maxsize => m_alias_maxsize,
      p_minvalue => m_alias_minvalue,
      p_maxvalue => m_alias_maxvalue,
      p_precision => m_alias_precision,
      p_colmtype => m_alias_lovcoltype
     );
     p_att_alias_table (5).alias_sql := m_alias_sql;
     p_att_alias_table (5).alias_type := m_alias_typ;
     p_att_alias_table (5).alias_maxsize := m_alias_maxsize;
     p_att_alias_table (5).alias_minvalue := m_alias_minvalue;
     p_att_alias_table (5).alias_maxvalue := m_alias_maxvalue;
     p_att_alias_table (5).alias_precision := m_alias_precision;
     p_att_alias_table (5).alias_lovcoltype := m_alias_lovcoltype;
    END IF;

    p_att_alias_table (6).attr_name := 'ATTRIBUTE6';
    p_att_alias_table (6).alias_id := l_pref_table (l_index).attribute6;

    IF p_att_alias_table (6).alias_id IS NOT NULL THEN
     get_type_sql (
      p_aliasid => p_att_alias_table (6).alias_id,
      p_person_type => l_person_type,
      p_alias_typ => m_alias_typ,
      p_alias_sql => m_alias_sql,
      p_maxsize => m_alias_maxsize,
      p_minvalue => m_alias_minvalue,
      p_maxvalue => m_alias_maxvalue,
      p_precision => m_alias_precision,
      p_colmtype => m_alias_lovcoltype
     );
     p_att_alias_table (6).alias_sql := m_alias_sql;
     p_att_alias_table (6).alias_type := m_alias_typ;
     p_att_alias_table (6).alias_maxsize := m_alias_maxsize;
     p_att_alias_table (6).alias_minvalue := m_alias_minvalue;
     p_att_alias_table (6).alias_maxvalue := m_alias_maxvalue;
     p_att_alias_table (6).alias_precision := m_alias_precision;
     p_att_alias_table (6).alias_lovcoltype := m_alias_lovcoltype;
    END IF;

    p_att_alias_table (7).attr_name := 'ATTRIBUTE7';
    p_att_alias_table (7).alias_id := l_pref_table (l_index).attribute7;

    IF p_att_alias_table (7).alias_id IS NOT NULL THEN
     get_type_sql (
      p_aliasid => p_att_alias_table (7).alias_id,
      p_person_type => l_person_type,
      p_alias_typ => m_alias_typ,
      p_alias_sql => m_alias_sql,
      p_maxsize => m_alias_maxsize,
      p_minvalue => m_alias_minvalue,
      p_maxvalue => m_alias_maxvalue,
      p_precision => m_alias_precision,
      p_colmtype => m_alias_lovcoltype
     );
     p_att_alias_table (7).alias_sql := m_alias_sql;
     p_att_alias_table (7).alias_type := m_alias_typ;
     p_att_alias_table (7).alias_maxsize := m_alias_maxsize;
     p_att_alias_table (7).alias_minvalue := m_alias_minvalue;
     p_att_alias_table (7).alias_maxvalue := m_alias_maxvalue;
     p_att_alias_table (7).alias_precision := m_alias_precision;
     p_att_alias_table (7).alias_lovcoltype := m_alias_lovcoltype;
    END IF;

    p_att_alias_table (8).attr_name := 'ATTRIBUTE8';
    p_att_alias_table (8).alias_id := l_pref_table (l_index).attribute8;

    IF p_att_alias_table (8).alias_id IS NOT NULL THEN
     get_type_sql (
      p_aliasid => p_att_alias_table (8).alias_id,
      p_person_type => l_person_type,
      p_alias_typ => m_alias_typ,
      p_alias_sql => m_alias_sql,
      p_maxsize => m_alias_maxsize,
      p_minvalue => m_alias_minvalue,
      p_maxvalue => m_alias_maxvalue,
      p_precision => m_alias_precision,
      p_colmtype => m_alias_lovcoltype
     );
     p_att_alias_table (8).alias_sql := m_alias_sql;
     p_att_alias_table (8).alias_type := m_alias_typ;
     p_att_alias_table (8).alias_maxsize := m_alias_maxsize;
     p_att_alias_table (8).alias_minvalue := m_alias_minvalue;
     p_att_alias_table (8).alias_maxvalue := m_alias_maxvalue;
     p_att_alias_table (8).alias_precision := m_alias_precision;
     p_att_alias_table (8).alias_lovcoltype := m_alias_lovcoltype;
    END IF;

    p_att_alias_table (9).attr_name := 'ATTRIBUTE9';
    p_att_alias_table (9).alias_id := l_pref_table (l_index).attribute9;

    IF p_att_alias_table (9).alias_id IS NOT NULL THEN
     get_type_sql (
      p_aliasid => p_att_alias_table (9).alias_id,
      p_person_type => l_person_type,
      p_alias_typ => m_alias_typ,
      p_alias_sql => m_alias_sql,
      p_maxsize => m_alias_maxsize,
      p_minvalue => m_alias_minvalue,
      p_maxvalue => m_alias_maxvalue,
      p_precision => m_alias_precision,
      p_colmtype => m_alias_lovcoltype
     );
     p_att_alias_table (9).alias_sql := m_alias_sql;
     p_att_alias_table (9).alias_type := m_alias_typ;
     p_att_alias_table (9).alias_maxsize := m_alias_maxsize;
     p_att_alias_table (9).alias_minvalue := m_alias_minvalue;
     p_att_alias_table (9).alias_maxvalue := m_alias_maxvalue;
     p_att_alias_table (9).alias_precision := m_alias_precision;
     p_att_alias_table (9).alias_lovcoltype := m_alias_lovcoltype;
    END IF;

    p_att_alias_table (10).attr_name := 'ATTRIBUTE10';
    p_att_alias_table (10).alias_id := l_pref_table (l_index).attribute10;

    IF p_att_alias_table (10).alias_id IS NOT NULL THEN
     get_type_sql (
      p_aliasid => p_att_alias_table (10).alias_id,
      p_person_type => l_person_type,
      p_alias_typ => m_alias_typ,
      p_alias_sql => m_alias_sql,
      p_maxsize => m_alias_maxsize,
      p_minvalue => m_alias_minvalue,
      p_maxvalue => m_alias_maxvalue,
      p_precision => m_alias_precision,
      p_colmtype => m_alias_lovcoltype
     );
     p_att_alias_table (10).alias_sql := m_alias_sql;
     p_att_alias_table (10).alias_type := m_alias_typ;
     p_att_alias_table (10).alias_maxsize := m_alias_maxsize;
     p_att_alias_table (10).alias_minvalue := m_alias_minvalue;
     p_att_alias_table (10).alias_maxvalue := m_alias_maxvalue;
     p_att_alias_table (10).alias_precision := m_alias_precision;
     p_att_alias_table (10).alias_lovcoltype := m_alias_lovcoltype;
    END IF;

    p_att_alias_table (11).attr_name := 'ATTRIBUTE11';
    p_att_alias_table (11).alias_id := l_pref_table (l_index).attribute11;

    IF p_att_alias_table (11).alias_id IS NOT NULL THEN
     get_type_sql (
      p_aliasid => p_att_alias_table (11).alias_id,
      p_person_type => l_person_type,
      p_alias_typ => m_alias_typ,
      p_alias_sql => m_alias_sql,
      p_maxsize => m_alias_maxsize,
      p_minvalue => m_alias_minvalue,
      p_maxvalue => m_alias_maxvalue,
      p_precision => m_alias_precision,
      p_colmtype => m_alias_lovcoltype
     );
     p_att_alias_table (11).alias_sql := m_alias_sql;
     p_att_alias_table (11).alias_type := m_alias_typ;
     p_att_alias_table (11).alias_maxsize := m_alias_maxsize;
     p_att_alias_table (11).alias_minvalue := m_alias_minvalue;
     p_att_alias_table (11).alias_maxvalue := m_alias_maxvalue;
     p_att_alias_table (11).alias_precision := m_alias_precision;
     p_att_alias_table (11).alias_lovcoltype := m_alias_lovcoltype;
    END IF;

    p_att_alias_table (12).attr_name := 'ATTRIBUTE12';
    p_att_alias_table (12).alias_id := l_pref_table (l_index).attribute12;

    IF p_att_alias_table (12).alias_id IS NOT NULL THEN
     get_type_sql (
      p_aliasid => p_att_alias_table (12).alias_id,
      p_person_type => l_person_type,
      p_alias_typ => m_alias_typ,
      p_alias_sql => m_alias_sql,
      p_maxsize => m_alias_maxsize,
      p_minvalue => m_alias_minvalue,
      p_maxvalue => m_alias_maxvalue,
      p_precision => m_alias_precision,
      p_colmtype => m_alias_lovcoltype
     );
     p_att_alias_table (12).alias_sql := m_alias_sql;
     p_att_alias_table (12).alias_type := m_alias_typ;
     p_att_alias_table (12).alias_maxsize := m_alias_maxsize;
     p_att_alias_table (12).alias_minvalue := m_alias_minvalue;
     p_att_alias_table (12).alias_maxvalue := m_alias_maxvalue;
     p_att_alias_table (12).alias_precision := m_alias_precision;
     p_att_alias_table (12).alias_lovcoltype := m_alias_lovcoltype;
    END IF;

    p_att_alias_table (13).attr_name := 'ATTRIBUTE13';
    p_att_alias_table (13).alias_id := l_pref_table (l_index).attribute13;

    IF p_att_alias_table (13).alias_id IS NOT NULL THEN
     get_type_sql (
      p_aliasid => p_att_alias_table (13).alias_id,
      p_person_type => l_person_type,
      p_alias_typ => m_alias_typ,
      p_alias_sql => m_alias_sql,
      p_maxsize => m_alias_maxsize,
      p_minvalue => m_alias_minvalue,
      p_maxvalue => m_alias_maxvalue,
      p_precision => m_alias_precision,
      p_colmtype => m_alias_lovcoltype
     );
     p_att_alias_table (13).alias_sql := m_alias_sql;
     p_att_alias_table (13).alias_type := m_alias_typ;
     p_att_alias_table (13).alias_maxsize := m_alias_maxsize;
     p_att_alias_table (13).alias_minvalue := m_alias_minvalue;
     p_att_alias_table (13).alias_maxvalue := m_alias_maxvalue;
     p_att_alias_table (13).alias_precision := m_alias_precision;
     p_att_alias_table (13).alias_lovcoltype := m_alias_lovcoltype;
    END IF;

    p_att_alias_table (14).attr_name := 'ATTRIBUTE14';
    p_att_alias_table (14).alias_id := l_pref_table (l_index).attribute14;

    IF p_att_alias_table (14).alias_id IS NOT NULL THEN
     get_type_sql (
      p_aliasid => p_att_alias_table (14).alias_id,
      p_person_type => l_person_type,
      p_alias_typ => m_alias_typ,
      p_alias_sql => m_alias_sql,
      p_maxsize => m_alias_maxsize,
      p_minvalue => m_alias_minvalue,
      p_maxvalue => m_alias_maxvalue,
      p_precision => m_alias_precision,
      p_colmtype => m_alias_lovcoltype
     );
     p_att_alias_table (14).alias_sql := m_alias_sql;
     p_att_alias_table (14).alias_type := m_alias_typ;
     p_att_alias_table (14).alias_maxsize := m_alias_maxsize;
     p_att_alias_table (14).alias_minvalue := m_alias_minvalue;
     p_att_alias_table (14).alias_maxvalue := m_alias_maxvalue;
     p_att_alias_table (14).alias_precision := m_alias_precision;
     p_att_alias_table (14).alias_lovcoltype := m_alias_lovcoltype;
    END IF;

    p_att_alias_table (15).attr_name := 'ATTRIBUTE15';
    p_att_alias_table (15).alias_id := l_pref_table (l_index).attribute15;

    IF p_att_alias_table (15).alias_id IS NOT NULL THEN
     get_type_sql (
      p_aliasid => p_att_alias_table (15).alias_id,
      p_person_type => l_person_type,
      p_alias_typ => m_alias_typ,
      p_alias_sql => m_alias_sql,
      p_maxsize => m_alias_maxsize,
      p_minvalue => m_alias_minvalue,
      p_maxvalue => m_alias_maxvalue,
      p_precision => m_alias_precision,
      p_colmtype => m_alias_lovcoltype
     );
     p_att_alias_table (15).alias_sql := m_alias_sql;
     p_att_alias_table (15).alias_type := m_alias_typ;
     p_att_alias_table (15).alias_maxsize := m_alias_maxsize;
     p_att_alias_table (15).alias_minvalue := m_alias_minvalue;
     p_att_alias_table (15).alias_maxvalue := m_alias_maxvalue;
     p_att_alias_table (15).alias_precision := m_alias_precision;
     p_att_alias_table (15).alias_lovcoltype := m_alias_lovcoltype;
    END IF;

    p_att_alias_table (16).attr_name := 'ATTRIBUTE16';
    p_att_alias_table (16).alias_id := l_pref_table (l_index).attribute16;

    IF p_att_alias_table (16).alias_id IS NOT NULL THEN
     get_type_sql (
      p_aliasid => p_att_alias_table (16).alias_id,
      p_person_type => l_person_type,
      p_alias_typ => m_alias_typ,
      p_alias_sql => m_alias_sql,
      p_maxsize => m_alias_maxsize,
      p_minvalue => m_alias_minvalue,
      p_maxvalue => m_alias_maxvalue,
      p_precision => m_alias_precision,
      p_colmtype => m_alias_lovcoltype
     );
     p_att_alias_table (16).alias_sql := m_alias_sql;
     p_att_alias_table (16).alias_type := m_alias_typ;
     p_att_alias_table (16).alias_maxsize := m_alias_maxsize;
     p_att_alias_table (16).alias_minvalue := m_alias_minvalue;
     p_att_alias_table (16).alias_maxvalue := m_alias_maxvalue;
     p_att_alias_table (16).alias_precision := m_alias_precision;
     p_att_alias_table (16).alias_lovcoltype := m_alias_lovcoltype;
    END IF;

    p_att_alias_table (17).attr_name := 'ATTRIBUTE17';
    p_att_alias_table (17).alias_id := l_pref_table (l_index).attribute17;

    IF p_att_alias_table (17).alias_id IS NOT NULL THEN
     get_type_sql (
      p_aliasid => p_att_alias_table (17).alias_id,
      p_person_type => l_person_type,
      p_alias_typ => m_alias_typ,
      p_alias_sql => m_alias_sql,
      p_maxsize => m_alias_maxsize,
      p_minvalue => m_alias_minvalue,
      p_maxvalue => m_alias_maxvalue,
      p_precision => m_alias_precision,
      p_colmtype => m_alias_lovcoltype
     );
     p_att_alias_table (17).alias_sql := m_alias_sql;
     p_att_alias_table (17).alias_type := m_alias_typ;
     p_att_alias_table (17).alias_maxsize := m_alias_maxsize;
     p_att_alias_table (17).alias_minvalue := m_alias_minvalue;
     p_att_alias_table (17).alias_maxvalue := m_alias_maxvalue;
     p_att_alias_table (17).alias_precision := m_alias_precision;
     p_att_alias_table (17).alias_lovcoltype := m_alias_lovcoltype;
    END IF;

    p_att_alias_table (18).attr_name := 'ATTRIBUTE18';
    p_att_alias_table (18).alias_id := l_pref_table (l_index).attribute18;

    IF p_att_alias_table (18).alias_id IS NOT NULL THEN
     get_type_sql (
      p_aliasid => p_att_alias_table (18).alias_id,
      p_person_type => l_person_type,
      p_alias_typ => m_alias_typ,
      p_alias_sql => m_alias_sql,
      p_maxsize => m_alias_maxsize,
      p_minvalue => m_alias_minvalue,
      p_maxvalue => m_alias_maxvalue,
      p_precision => m_alias_precision,
      p_colmtype => m_alias_lovcoltype
     );
     p_att_alias_table (18).alias_sql := m_alias_sql;
     p_att_alias_table (18).alias_type := m_alias_typ;
     p_att_alias_table (18).alias_maxsize := m_alias_maxsize;
     p_att_alias_table (18).alias_minvalue := m_alias_minvalue;
     p_att_alias_table (18).alias_maxvalue := m_alias_maxvalue;
     p_att_alias_table (18).alias_precision := m_alias_precision;
     p_att_alias_table (18).alias_lovcoltype := m_alias_lovcoltype;
    END IF;

    p_att_alias_table (19).attr_name := 'ATTRIBUTE19';
    p_att_alias_table (19).alias_id := l_pref_table (l_index).attribute19;

    IF p_att_alias_table (19).alias_id IS NOT NULL THEN
     get_type_sql (
      p_aliasid => p_att_alias_table (19).alias_id,
      p_person_type => l_person_type,
      p_alias_typ => m_alias_typ,
      p_alias_sql => m_alias_sql,
      p_maxsize => m_alias_maxsize,
      p_minvalue => m_alias_minvalue,
      p_maxvalue => m_alias_maxvalue,
      p_precision => m_alias_precision,
      p_colmtype => m_alias_lovcoltype
     );
     p_att_alias_table (19).alias_sql := m_alias_sql;
     p_att_alias_table (19).alias_type := m_alias_typ;
     p_att_alias_table (19).alias_maxsize := m_alias_maxsize;
     p_att_alias_table (19).alias_minvalue := m_alias_minvalue;
     p_att_alias_table (19).alias_maxvalue := m_alias_maxvalue;
     p_att_alias_table (19).alias_precision := m_alias_precision;
     p_att_alias_table (19).alias_lovcoltype := m_alias_lovcoltype;
    END IF;

    p_att_alias_table (20).attr_name := 'ATTRIBUTE20';
    p_att_alias_table (20).alias_id := l_pref_table (l_index).attribute20;

    IF p_att_alias_table (20).alias_id IS NOT NULL THEN
     get_type_sql (
      p_aliasid => p_att_alias_table (20).alias_id,
      p_person_type => l_person_type,
      p_alias_typ => m_alias_typ,
      p_alias_sql => m_alias_sql,
      p_maxsize => m_alias_maxsize,
      p_minvalue => m_alias_minvalue,
      p_maxvalue => m_alias_maxvalue,
      p_precision => m_alias_precision,
      p_colmtype => m_alias_lovcoltype
     );
     p_att_alias_table (20).alias_sql := m_alias_sql;
     p_att_alias_table (20).alias_type := m_alias_typ;
     p_att_alias_table (20).alias_maxsize := m_alias_maxsize;
     p_att_alias_table (20).alias_minvalue := m_alias_minvalue;
     p_att_alias_table (20).alias_maxvalue := m_alias_maxvalue;
     p_att_alias_table (20).alias_precision := m_alias_precision;
     p_att_alias_table (20).alias_lovcoltype := m_alias_lovcoltype;
    END IF;

   ELSIF (l_pref_table (l_index).preference_code = 'TS_ABS_PREFERENCES') THEN

       if ( nvl(fnd_profile.value('HR_ABS_OTL_INTEGRATION'),'N') = 'Y'
        and nvl(l_pref_table (l_index).attribute1,'N') = 'Y'
        and nvl(l_pref_table (l_index).attribute5,'N') = 'Y') then

          hxc_timekeeper_utilities.g_tk_show_absences:= 1;

       else

          hxc_timekeeper_utilities.g_tk_show_absences:= 0;

    end if;

   END IF;

   l_index := l_pref_table.NEXT (l_index);
  END LOOP;
 END;


-- ----------------------------------------------------------------------------
--  Used in form in post query to enable /disable days in timecard row
-- ----------------------------------------------------------------------------
 PROCEDURE populate_disable_tc_tab (
  resource_id IN NUMBER,
  tc_frdt IN DATE,
  tc_todt IN DATE,
  p_emptcinfo OUT NOCOPY hxc_timekeeper_utilities.emptctab
 ) IS
  CURSOR get_tc_data (
   p_resource_id NUMBER,
   p_tc_frdt DATE,
   p_tc_todt DATE
  ) IS
   SELECT   time_building_block_id tbbid, start_time, stop_time, TO_DATE (start_time, 'dd-mm-rrrr')
   FROM     hxc_time_building_blocks
   WHERE    resource_id
/*ADVICE(3110): Cursor references an external variable (use a parameter) [209] */
                        = p_resource_id
AND         SCOPE = 'TIMECARD'
AND         date_to = hr_general.end_of_time
AND         TO_DATE (start_time, 'dd-mm-rrrr') < TO_DATE (p_tc_todt, 'dd-mm-rrrr')
AND         TO_DATE (stop_time, 'dd-mm-rrrr') > TO_DATE (p_tc_frdt, 'dd-mm-rrrr')
AND         (   TO_DATE (start_time, 'dd-mm-rrrr') <> TO_DATE (p_tc_frdt, 'dd-mm-rrrr')
             OR TO_DATE (stop_time, 'dd-mm-rrrr') <> TO_DATE (p_tc_todt, 'dd-mm-rrrr')
            )
   ORDER BY 4;

  tc_tab_rec get_tc_data%ROWTYPE;
  p_index    NUMBER
/*ADVICE(3123): NUMBER has no precision [315] */
                                   := 0;
 BEGIN
  OPEN get_tc_data (resource_id, tc_frdt, tc_todt);

  LOOP
   FETCH get_tc_data INTO tc_tab_rec;
   EXIT WHEN get_tc_data%NOTFOUND;

   IF p_emptcinfo.COUNT > 0 THEN
    p_index := p_emptcinfo.LAST + 1;
   ELSE
    p_index := 1;
   END IF;

   p_emptcinfo (p_index).timecard_id := tc_tab_rec.tbbid;
   p_emptcinfo (p_index).resource_id := resource_id;
   p_emptcinfo (p_index).tc_frdt := tc_tab_rec.start_time;
   p_emptcinfo (p_index).tc_todt := tc_tab_rec.stop_time;
  END LOOP;

  CLOSE get_tc_data;
 END;


-- ----------------------------------------------------------------------------
-- Used in form to enable /disable days in timecard row
--  when new row is created for a person manually
-- ----------------------------------------------------------------------------
 PROCEDURE new_timecard (
  p_resource_id IN NUMBER,
  p_start_date IN DATE,
  p_end_date IN DATE,
  p_emptcinfo OUT NOCOPY hxc_timekeeper_utilities.emptctab
 ) IS
  m_periods
/*ADVICE(3159): Unreferenced variable [553] */
                   VARCHAR2 (2000);
/*ADVICE(3161): VARCHAR2 declaration with length greater than 500 characters [307] */

  l_newtab         hxc_timecard_utilities.periods;
  l_emp_tab_index  NUMBER
/*ADVICE(3165): NUMBER has no precision [315] */
                                                  := 0;
  l_new_tab_index
/*ADVICE(3168): Unreferenced variable [553] */
                   NUMBER
/*ADVICE(3170): NUMBER has no precision [315] */
                                                  := 0;
  l_emp_negpref
/*ADVICE(3173): This item should be defined in a deeper scope [558] */
                   VARCHAR2 (150);
  l_emp_recpref    NUMBER
/*ADVICE(3176): NUMBER has no precision [315] */
                         ;
  l_emp_appstyle
/*ADVICE(3179): This item should be defined in a deeper scope [558] */
                   NUMBER
/*ADVICE(3181): NUMBER has no precision [315] */
                         ;
  l_emp_layout1
/*ADVICE(3184): This item should be defined in a deeper scope [558] */
                   NUMBER
/*ADVICE(3186): NUMBER has no precision [315] */
                         ;
  l_emp_layout2
/*ADVICE(3189): This item should be defined in a deeper scope [558] */
                   NUMBER
/*ADVICE(3191): NUMBER has no precision [315] */
                         ;
  l_emp_layout3
/*ADVICE(3194): This item should be defined in a deeper scope [558] */
                   NUMBER
/*ADVICE(3196): NUMBER has no precision [315] */
                         ;
  l_emp_layout4
/*ADVICE(3199): This item should be defined in a deeper scope [558] */
                   NUMBER
/*ADVICE(3201): NUMBER has no precision [315] */
                         ;
  l_emp_layout5
/*ADVICE(3204): This item should be defined in a deeper scope [558] */
                   NUMBER
/*ADVICE(3206): NUMBER has no precision [315] */
                         ;
  l_emp_layout6
/*ADVICE(3209): This item should be defined in a deeper scope [558] */
                   NUMBER
/*ADVICE(3211): NUMBER has no precision [315] */
                         ;
  l_emp_layout7
/*ADVICE(3214): This item should be defined in a deeper scope [558] */
                   NUMBER
/*ADVICE(3216): NUMBER has no precision [315] */
                         ;
  l_emp_layout8
/*ADVICE(3219): This item should be defined in a deeper scope [558] */
                   NUMBER
/*ADVICE(3221): NUMBER has no precision [315] */
                         ;
  l_emp_edits
/*ADVICE(3224): This item should be defined in a deeper scope [558] */
                   VARCHAR2 (150);
  l_pastdt
/*ADVICE(3227): This item should be defined in a deeper scope [558] */
                   VARCHAR2 (30);
  l_futuredt
/*ADVICE(3230): This item should be defined in a deeper scope [558] */
                   VARCHAR2 (30);
  l_emp_start_date
/*ADVICE(3233): This item should be defined in a deeper scope [558] */
                   DATE;
  l_emp_terminate_date
/*ADVICE(3233): This item should be defined in a deeper scope [558] */
                   DATE;
  l_index          NUMBER
/*ADVICE(3236): NUMBER has no precision [315] */
                                                  := 0;
  l_audit_enabled
/*ADVICE(3239): This item should be defined in a deeper scope [558] */
                   VARCHAR2 (150);
 BEGIN
  BEGIN
   hxc_timekeeper_utilities.get_emp_pref (
    p_resource_id,
    l_emp_negpref,
    l_emp_recpref,
    l_emp_appstyle,
    l_emp_layout1,
    l_emp_layout2,
    l_emp_layout3,
    l_emp_layout4,
    l_emp_layout5,
    l_emp_layout6,
    l_emp_layout7,
    l_emp_layout8,
    l_emp_edits,
    l_pastdt,
    l_futuredt,
    l_emp_start_date,
    l_emp_terminate_date,
    l_audit_enabled
   );
  EXCEPTION
   WHEN OTHERS THEN
    l_emp_recpref := NULL;
/*ADVICE(3265): A WHEN OTHERS clause is used in the exception section without any other specific handlers
              [201] */

  END;

  l_newtab.DELETE;
  hxc_timekeeper_utilities.get_resource_time_periods (
   p_resource_id => p_resource_id,
   p_resource_type => 'PERSON',
   p_current_date => SYSDATE,
   p_max_date_in_futur => TO_DATE (p_end_date, 'dd-mm-rrrr') + 1,
   p_max_date_in_past => TO_DATE (p_start_date, 'dd-mm-rrrr') - 1,
   p_recurring_period_id => l_emp_recpref,
   p_check_assignment => TRUE,
   p_periodtab => l_newtab
  );
  l_emp_tab_index := l_newtab.FIRST;

  LOOP
   EXIT WHEN NOT l_newtab.EXISTS (l_emp_tab_index);

   IF      TO_NUMBER (l_emp_tab_index) >= TO_NUMBER (TO_CHAR (TO_DATE (p_start_date, 'dd-mm-rrrr'), 'J'))
       AND TO_NUMBER (TO_CHAR (l_newtab (l_emp_tab_index).end_date, 'J')) <=
                                             TO_NUMBER (TO_CHAR (TO_DATE (p_end_date, 'dd-mm-rrrr'), 'J')) THEN
    IF p_emptcinfo.COUNT > 0 THEN
     l_index := p_emptcinfo.LAST + 1;
    ELSE
     l_index := 1;
    END IF;

    p_emptcinfo (l_index).resource_id := p_resource_id;
    p_emptcinfo (l_index).tc_frdt := l_newtab (l_emp_tab_index).start_date;
    p_emptcinfo (l_index).tc_todt := l_newtab (l_emp_tab_index).end_date;
   END IF;

   l_emp_tab_index := l_newtab.NEXT (l_emp_tab_index);
  END LOOP;
 END;

-------------------------
--POP_DETAIL_TEMP
-----------------
/* This procedure is used to populate the pl/sql blocks from hxc_tk_detail_temp after the save process
and then repoulate it back to the table once database commit is triggered from the forms
has one parameter action, it has following values
1 - hxc_tk_detail_temp--->pl/sql table
2 - pl/sql table --> hxc_tk_detail_temp
*/
procedure populate_detail_temp(p_action in number) is
j binary_integer :=0;
indx binary_integer;
l_detail_blocks  hxc_tk_detail_temp_tab;
cursor csr_tk is select * from hxc_tk_detail_temp;
begin
l_detail_blocks:=hxc_timekeeper_utilities.g_hxc_tk_detail_temp_tab;
if p_action =1 then
	open csr_tk;
	loop
	        j:=j+1;
	      /* Fetch entire row into record stored by jth element. */
		 fetch csr_tk into l_detail_blocks(j);
		 exit when csr_tk%NOTFOUND;
	end loop;
	close csr_tk;

ELSE
	/* start of fix for 5398144 */
	if l_detail_blocks.count > 0 then
		FOR indx IN l_detail_blocks.FIRST .. l_detail_blocks.LAST loop
		insert into hxc_tk_detail_temp
			(RESOURCE_ID,
			TIMECARD_ID,
			DETAILID,
			COMMENT_TEXT,
			DFF_CATG     ,
			DETAIL_ACTION ,
			DFF_ATTR1      ,
			DFF_ATTR2       ,
			DFF_ATTR3        ,
			DFF_ATTR4         ,
			DFF_ATTR5          ,
			DFF_ATTR6           ,
			DFF_ATTR7            ,
			DFF_ATTR8             ,
			DFF_ATTR9              ,
			DFF_ATTR10              ,
			DFF_ATTR11              ,
			DFF_ATTR12              ,
			DFF_ATTR13              ,
			DFF_ATTR14              ,
			DFF_ATTR15              ,
			DFF_ATTR16              ,
			DFF_ATTR17              ,
			DFF_ATTR18              ,
			DFF_ATTR19              ,
			DFF_ATTR20              ,
			DFF_ATTR21              ,
			DFF_ATTR22              ,
			DFF_ATTR23              ,
			DFF_ATTR24              ,
			DFF_ATTR25              ,
			DFF_ATTR26              ,
			DFF_ATTR27              ,
			DFF_ATTR28              ,
			DFF_ATTR29              ,
			DFF_ATTR30              ,
			DFF_OLDATTR1            ,
			DFF_OLDATTR2            ,
			DFF_OLDATTR3            ,
			DFF_OLDATTR4            ,
			DFF_OLDATTR5            ,
			DFF_OLDATTR6            ,
			DFF_OLDATTR7            ,
			DFF_OLDATTR8            ,
			DFF_OLDATTR9            ,
			DFF_OLDATTR10           ,
			DFF_OLDATTR11           ,
			DFF_OLDATTR12           ,
			DFF_OLDATTR13           ,
			DFF_OLDATTR14           ,
			DFF_OLDATTR15           ,
			DFF_OLDATTR16           ,
			DFF_OLDATTR17           ,
			DFF_OLDATTR18           ,
			DFF_OLDATTR19           ,
			DFF_OLDATTR20           ,
			DFF_OLDATTR21           ,
			DFF_OLDATTR22           ,
			DFF_OLDATTR23           ,
			DFF_OLDATTR24           ,
			DFF_OLDATTR25           ,
			DFF_OLDATTR26           ,
			DFF_OLDATTR27           ,
			DFF_OLDATTR28           ,
			DFF_OLDATTR29           ,
			DFF_OLDATTR30           ,
			DFF_OLDCATG             ,
			CHANGE_REASON           ,
			CHANGE_COMMENT          ,
			LATE_REASON             ,
			LATE_COMMENT            ,
			LATE_CHANGE             ,
			DESC_FLEX               ,
			ATTRIBUTE_CATEGORY      ,
			AUDIT_DATETIME          ,
			AUDIT_HISTORY           ,
			DISP_INDEX              ,
			OLD_CHANGE_REASON       ,
			OLD_CHANGE_COMMENT      ,
			OLD_LATE_REASON         ,
			OLD_LATE_COMMENT        ,
			OLD_AUDIT_HISTORY       ,
			OLD_LATE_CHANGE         ,
			OLD_AUDIT_DATETIME      )
			values
			(
			l_detail_blocks(indx).RESOURCE_ID,
			l_detail_blocks(indx).TIMECARD_ID,
			l_detail_blocks(indx).DETAILID,
			l_detail_blocks(indx).COMMENT_TEXT,
			l_detail_blocks(indx).DFF_CATG     ,
			l_detail_blocks(indx).DETAIL_ACTION ,
			l_detail_blocks(indx).DFF_ATTR1      ,
			l_detail_blocks(indx).DFF_ATTR2       ,
			l_detail_blocks(indx).DFF_ATTR3        ,
			l_detail_blocks(indx).DFF_ATTR4         ,
			l_detail_blocks(indx).DFF_ATTR5          ,
			l_detail_blocks(indx).DFF_ATTR6           ,
			l_detail_blocks(indx).DFF_ATTR7            ,
			l_detail_blocks(indx).DFF_ATTR8             ,
			l_detail_blocks(indx).DFF_ATTR9              ,
			l_detail_blocks(indx).DFF_ATTR10              ,
			l_detail_blocks(indx).DFF_ATTR11              ,
			l_detail_blocks(indx).DFF_ATTR12              ,
			l_detail_blocks(indx).DFF_ATTR13              ,
			l_detail_blocks(indx).DFF_ATTR14              ,
			l_detail_blocks(indx).DFF_ATTR15              ,
			l_detail_blocks(indx).DFF_ATTR16              ,
			l_detail_blocks(indx).DFF_ATTR17              ,
			l_detail_blocks(indx).DFF_ATTR18              ,
			l_detail_blocks(indx).DFF_ATTR19              ,
			l_detail_blocks(indx).DFF_ATTR20              ,
			l_detail_blocks(indx).DFF_ATTR21              ,
			l_detail_blocks(indx).DFF_ATTR22              ,
			l_detail_blocks(indx).DFF_ATTR23              ,
			l_detail_blocks(indx).DFF_ATTR24              ,
			l_detail_blocks(indx).DFF_ATTR25              ,
			l_detail_blocks(indx).DFF_ATTR26              ,
			l_detail_blocks(indx).DFF_ATTR27              ,
			l_detail_blocks(indx).DFF_ATTR28              ,
			l_detail_blocks(indx).DFF_ATTR29              ,
			l_detail_blocks(indx).DFF_ATTR30              ,
			l_detail_blocks(indx).DFF_OLDATTR1            ,
			l_detail_blocks(indx).DFF_OLDATTR2            ,
			l_detail_blocks(indx).DFF_OLDATTR3            ,
			l_detail_blocks(indx).DFF_OLDATTR4            ,
			l_detail_blocks(indx).DFF_OLDATTR5            ,
			l_detail_blocks(indx).DFF_OLDATTR6            ,
			l_detail_blocks(indx).DFF_OLDATTR7            ,
			l_detail_blocks(indx).DFF_OLDATTR8            ,
			l_detail_blocks(indx).DFF_OLDATTR9            ,
			l_detail_blocks(indx).DFF_OLDATTR10           ,
			l_detail_blocks(indx).DFF_OLDATTR11           ,
			l_detail_blocks(indx).DFF_OLDATTR12           ,
			l_detail_blocks(indx).DFF_OLDATTR13           ,
			l_detail_blocks(indx).DFF_OLDATTR14           ,
			l_detail_blocks(indx).DFF_OLDATTR15           ,
			l_detail_blocks(indx).DFF_OLDATTR16           ,
			l_detail_blocks(indx).DFF_OLDATTR17           ,
			l_detail_blocks(indx).DFF_OLDATTR18           ,
			l_detail_blocks(indx).DFF_OLDATTR19           ,
			l_detail_blocks(indx).DFF_OLDATTR20           ,
			l_detail_blocks(indx).DFF_OLDATTR21           ,
			l_detail_blocks(indx).DFF_OLDATTR22           ,
			l_detail_blocks(indx).DFF_OLDATTR23           ,
			l_detail_blocks(indx).DFF_OLDATTR24           ,
			l_detail_blocks(indx).DFF_OLDATTR25           ,
			l_detail_blocks(indx).DFF_OLDATTR26           ,
			l_detail_blocks(indx).DFF_OLDATTR27           ,
			l_detail_blocks(indx).DFF_OLDATTR28           ,
			l_detail_blocks(indx).DFF_OLDATTR29           ,
			l_detail_blocks(indx).DFF_OLDATTR30           ,
			l_detail_blocks(indx).DFF_OLDCATG             ,
			l_detail_blocks(indx).CHANGE_REASON           ,
			l_detail_blocks(indx).CHANGE_COMMENT          ,
			l_detail_blocks(indx).LATE_REASON             ,
			l_detail_blocks(indx).LATE_COMMENT            ,
			l_detail_blocks(indx).LATE_CHANGE             ,
			l_detail_blocks(indx).DESC_FLEX               ,
			l_detail_blocks(indx).ATTRIBUTE_CATEGORY      ,
			l_detail_blocks(indx).AUDIT_DATETIME          ,
			l_detail_blocks(indx).AUDIT_HISTORY           ,
			l_detail_blocks(indx).DISP_INDEX              ,
			l_detail_blocks(indx).OLD_CHANGE_REASON       ,
			l_detail_blocks(indx).OLD_CHANGE_COMMENT      ,
			l_detail_blocks(indx).OLD_LATE_REASON         ,
			l_detail_blocks(indx).OLD_LATE_COMMENT        ,
			l_detail_blocks(indx).OLD_AUDIT_HISTORY       ,
			l_detail_blocks(indx).OLD_LATE_CHANGE         ,
			l_detail_blocks(indx).OLD_AUDIT_DATETIME      );
	        end loop;
    	END if;
	/* end of fix for 5398144 */
end if;
hxc_timekeeper_utilities.g_hxc_tk_detail_temp_tab:=l_detail_blocks;
end;


 FUNCTION get_exp_type_from_alias (
  p_alias_value_id IN VARCHAR2
 )
  RETURN VARCHAR2 IS
  CURSOR c_alias_to_pa_info (
   p_id IN hxc_alias_values.alias_value_id%TYPE
  ) IS
   SELECT attribute2
   FROM   hxc_alias_values
   WHERE  alias_value_id = p_id AND attribute_category = 'ELEMENTS_EXPENDITURE_SLF';

  l_expenditure_type VARCHAR2 (250);
 BEGIN
  OPEN c_alias_to_pa_info (p_alias_value_id);
  FETCH c_alias_to_pa_info INTO l_expenditure_type;
  CLOSE c_alias_to_pa_info;
  RETURN l_expenditure_type;
 END get_exp_type_from_alias;

 FUNCTION check_global_context (
  p_context_prefix IN VARCHAR2
 )
  RETURN BOOLEAN IS
  l_dummy VARCHAR2 (10);
 BEGIN
  SELECT 'Y'
  INTO   l_dummy
  FROM   fnd_descr_flex_contexts
  WHERE  application_id = 809
AND      descriptive_flexfield_name = 'OTC Information Types'
AND      descriptive_flex_context_code LIKE p_context_prefix || '%GLOBAL%';

  RETURN TRUE;
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
   RETURN FALSE;
 END;


 /*Added for Enh 3303359
        Caching the pref value for Default Recurring Period

        A form cant reference pkg global variables and hence a separate function to
        get the global variable

        */


 FUNCTION get_pref_setting(p_pref IN VARCHAR2)
            RETURN NUMBER
  is

  begin

  	if p_pref is null then

     		return -1;

  	elsif p_pref = 'DEFAULT_RECURRING_PERIOD' then

     		return to_number(g_default_rec_period);

 	 elsif p_pref = 'VIEW_ABSENCE_STATUS' then

     		return to_number(g_tk_show_absences);

 	 else

    		 return -1;

  	end if;

  END; -- get_pref_setting





/*Added 3 procs for HR OTL Absence Integration: Bug: 8775740
  --SVG START
 */

 ---------------------------------------------------------------------------------------

  FUNCTION get_pref_eval_date
  (p_resource_id	IN 	NUMBER
  ,p_tc_start_date	IN 	DATE
  ,p_tc_end_date	IN 	DATE)

   RETURN DATE

     IS

     Cursor active_periods(p_resource_id  	IN	NUMBER
                          ,p_tc_start_date	IN	DATE
                          ,p_tc_end_date	IN 	DATE)
       is

      SELECT date_start,
             final_process_date
        FROM per_periods_of_service
       WHERE person_id = p_resource_id
         AND date_start <= p_tc_end_date
         AND COALESCE(final_process_date,
                      actual_termination_date,
                      hr_general.end_of_time) >= p_tc_start_date
       UNION
      SELECT date_start,
             (final_process_date + NVL(fnd_profile.value('HXC_CWK_TK_FPD'),0)) final_process_date
        FROM per_periods_of_placement
       WHERE person_id           = p_resource_id
         AND date_start         <= p_tc_end_date
         AND COALESCE((final_process_date+NVL(fnd_profile.value('HXC_CWK_TK_FPD'),0))
                      ,actual_termination_date,
                       hr_general.end_of_time) >= p_tc_start_date
    ORDER BY date_start ;


    l_start_date	DATE;
    l_end_date		DATE;


   BEGIN

     if g_debug then

     	hr_utility.trace('Entered get_pref_eval_date ');

     end if;

     OPEN active_periods(p_resource_id,
                         p_tc_start_date,
                         p_tc_end_date);

     if g_debug then

     	hr_utility.trace('Opened active_periods ');

     end if;

     FETCH active_periods into l_start_date, l_end_date;

     if g_debug then

      	hr_utility.trace('Fetched active_periods ');
      	hr_utility.trace('l_start_date = '||l_start_date);
      	hr_utility.trace('l_end_date = '||l_end_date);
      	hr_utility.trace('p_tc_start_date = '||p_tc_start_date);
      	hr_utility.trace('p_tc_end_date = '||p_tc_end_date);

     end if;

     if (p_tc_start_date between nvl(l_start_date, hr_general.start_of_time)
                         and     nvl(l_end_date, hr_general.end_of_time)) then

                if g_debug then

                hr_utility.trace('Going to return p_tc_start_date ='|| p_tc_start_date);

                end if;

                return p_tc_start_date;

     else

     		if g_debug then

		hr_utility.trace('Going to return l_start_date ='|| l_start_date);

                end if;


                return l_start_date;
     end if;


   END; --get_pref_eval_date
 ---------------------------------------------------------------------------------------


   PROCEDURE populate_prepop_detail_id_info
    (p_timekeeper_data_rec      IN 	    hxc_timekeeper_process.t_time_info,
     p_tk_prepop_detail_id_tab  IN OUT NOCOPY hxc_timekeeper_process.g_tk_prepop_detail_id_tab_type)

     IS

     l_index		NUMBER;


   BEGIN

  if g_debug then
       hr_utility.trace(' Entered hxctkutil.populate_prepop_detail_id_info');
   end if;

    if (p_timekeeper_data_rec.detail_id_1 is not null and
       p_timekeeper_data_rec.detail_id_1 < 0 ) then

       l_index:= p_timekeeper_data_rec.detail_id_1 * -1 ;

       p_tk_prepop_detail_id_tab(l_index):=p_timekeeper_data_rec.resource_id;

    end if;

    if (p_timekeeper_data_rec.detail_id_2 is not null and
       p_timekeeper_data_rec.detail_id_2 < 0 ) then

       l_index:= p_timekeeper_data_rec.detail_id_2 * -1 ;

       p_tk_prepop_detail_id_tab(l_index):=p_timekeeper_data_rec.resource_id;

    end if;

    if (p_timekeeper_data_rec.detail_id_3 is not null and
       p_timekeeper_data_rec.detail_id_3 < 0 ) then

       l_index:= p_timekeeper_data_rec.detail_id_3 * -1 ;

       p_tk_prepop_detail_id_tab(l_index):=p_timekeeper_data_rec.resource_id;

    end if;

    if (p_timekeeper_data_rec.detail_id_4 is not null and
       p_timekeeper_data_rec.detail_id_4 < 0 ) then

       l_index:= p_timekeeper_data_rec.detail_id_4 * -1 ;

       p_tk_prepop_detail_id_tab(l_index):=p_timekeeper_data_rec.resource_id;

    end if;

    if (p_timekeeper_data_rec.detail_id_5 is not null and
       p_timekeeper_data_rec.detail_id_5 < 0 ) then

       l_index:= p_timekeeper_data_rec.detail_id_5 * -1 ;

       p_tk_prepop_detail_id_tab(l_index):=p_timekeeper_data_rec.resource_id;

    end if;

    if (p_timekeeper_data_rec.detail_id_6 is not null and
       p_timekeeper_data_rec.detail_id_6 < 0 ) then

       l_index:= p_timekeeper_data_rec.detail_id_6 * -1 ;

       p_tk_prepop_detail_id_tab(l_index):=p_timekeeper_data_rec.resource_id;

    end if;

    if (p_timekeeper_data_rec.detail_id_7 is not null and
       p_timekeeper_data_rec.detail_id_7 < 0 ) then

       l_index:= p_timekeeper_data_rec.detail_id_7 * -1 ;

       p_tk_prepop_detail_id_tab(l_index):=p_timekeeper_data_rec.resource_id;

    end if;

    if (p_timekeeper_data_rec.detail_id_8 is not null and
       p_timekeeper_data_rec.detail_id_8 < 0 ) then

       l_index:= p_timekeeper_data_rec.detail_id_8 * -1 ;

       p_tk_prepop_detail_id_tab(l_index):=p_timekeeper_data_rec.resource_id;

    end if;

    if (p_timekeeper_data_rec.detail_id_9 is not null and
       p_timekeeper_data_rec.detail_id_9 < 0 ) then

       l_index:= p_timekeeper_data_rec.detail_id_9 * -1 ;

       p_tk_prepop_detail_id_tab(l_index):=p_timekeeper_data_rec.resource_id;

    end if;

    if (p_timekeeper_data_rec.detail_id_10 is not null and
       p_timekeeper_data_rec.detail_id_10 < 0 ) then

       l_index:= p_timekeeper_data_rec.detail_id_10 * -1 ;

       p_tk_prepop_detail_id_tab(l_index):=p_timekeeper_data_rec.resource_id;

    end if;

    if (p_timekeeper_data_rec.detail_id_11 is not null and
       p_timekeeper_data_rec.detail_id_11 < 0 ) then

       l_index:= p_timekeeper_data_rec.detail_id_11 * -1 ;

       p_tk_prepop_detail_id_tab(l_index):=p_timekeeper_data_rec.resource_id;

    end if;

    if (p_timekeeper_data_rec.detail_id_12 is not null and
       p_timekeeper_data_rec.detail_id_12 < 0 ) then

       l_index:= p_timekeeper_data_rec.detail_id_12 * -1 ;

       p_tk_prepop_detail_id_tab(l_index):=p_timekeeper_data_rec.resource_id;

    end if;

    if (p_timekeeper_data_rec.detail_id_13 is not null and
       p_timekeeper_data_rec.detail_id_13 < 0 ) then

       l_index:= p_timekeeper_data_rec.detail_id_13 * -1 ;

       p_tk_prepop_detail_id_tab(l_index):=p_timekeeper_data_rec.resource_id;

    end if;

    if (p_timekeeper_data_rec.detail_id_14 is not null and
       p_timekeeper_data_rec.detail_id_14 < 0 ) then

       l_index:= p_timekeeper_data_rec.detail_id_14 * -1 ;

       p_tk_prepop_detail_id_tab(l_index):=p_timekeeper_data_rec.resource_id;

    end if;

    if (p_timekeeper_data_rec.detail_id_15 is not null and
       p_timekeeper_data_rec.detail_id_15 < 0 ) then

       l_index:= p_timekeeper_data_rec.detail_id_15 * -1 ;

       p_tk_prepop_detail_id_tab(l_index):=p_timekeeper_data_rec.resource_id;

    end if;

    if (p_timekeeper_data_rec.detail_id_16 is not null and
       p_timekeeper_data_rec.detail_id_16 < 0 ) then

       l_index:= p_timekeeper_data_rec.detail_id_16 * -1 ;

       p_tk_prepop_detail_id_tab(l_index):=p_timekeeper_data_rec.resource_id;

    end if;

    if (p_timekeeper_data_rec.detail_id_17 is not null and
       p_timekeeper_data_rec.detail_id_17 < 0 ) then

       l_index:= p_timekeeper_data_rec.detail_id_17 * -1 ;

       p_tk_prepop_detail_id_tab(l_index):=p_timekeeper_data_rec.resource_id;

    end if;

    if (p_timekeeper_data_rec.detail_id_18 is not null and
       p_timekeeper_data_rec.detail_id_18 < 0 ) then

       l_index:= p_timekeeper_data_rec.detail_id_18 * -1 ;

       p_tk_prepop_detail_id_tab(l_index):=p_timekeeper_data_rec.resource_id;

    end if;

    if (p_timekeeper_data_rec.detail_id_19 is not null and
       p_timekeeper_data_rec.detail_id_19 < 0 ) then

       l_index:= p_timekeeper_data_rec.detail_id_19 * -1 ;

       p_tk_prepop_detail_id_tab(l_index):=p_timekeeper_data_rec.resource_id;

    end if;

    if (p_timekeeper_data_rec.detail_id_20 is not null and
       p_timekeeper_data_rec.detail_id_20 < 0 ) then

       l_index:= p_timekeeper_data_rec.detail_id_20 * -1 ;

       p_tk_prepop_detail_id_tab(l_index):=p_timekeeper_data_rec.resource_id;

    end if;

    if (p_timekeeper_data_rec.detail_id_21 is not null and
         p_timekeeper_data_rec.detail_id_21 < 0 ) then

         l_index:= p_timekeeper_data_rec.detail_id_21 * -1 ;

         p_tk_prepop_detail_id_tab(l_index):=p_timekeeper_data_rec.resource_id;

      end if;

      if (p_timekeeper_data_rec.detail_id_22 is not null and
         p_timekeeper_data_rec.detail_id_22 < 0 ) then

         l_index:= p_timekeeper_data_rec.detail_id_22 * -1 ;

         p_tk_prepop_detail_id_tab(l_index):=p_timekeeper_data_rec.resource_id;

      end if;

      if (p_timekeeper_data_rec.detail_id_23 is not null and
         p_timekeeper_data_rec.detail_id_23 < 0 ) then

         l_index:= p_timekeeper_data_rec.detail_id_23 * -1 ;

         p_tk_prepop_detail_id_tab(l_index):=p_timekeeper_data_rec.resource_id;

      end if;


      if (p_timekeeper_data_rec.detail_id_24 is not null and
         p_timekeeper_data_rec.detail_id_24 < 0 ) then

         l_index:= p_timekeeper_data_rec.detail_id_24 * -1 ;

         p_tk_prepop_detail_id_tab(l_index):=p_timekeeper_data_rec.resource_id;

      end if;

      if (p_timekeeper_data_rec.detail_id_25 is not null and
         p_timekeeper_data_rec.detail_id_25 < 0 ) then

         l_index:= p_timekeeper_data_rec.detail_id_25 * -1 ;

         p_tk_prepop_detail_id_tab(l_index):=p_timekeeper_data_rec.resource_id;

      end if;

      if (p_timekeeper_data_rec.detail_id_26 is not null and
         p_timekeeper_data_rec.detail_id_26 < 0 ) then

         l_index:= p_timekeeper_data_rec.detail_id_26 * -1 ;

         p_tk_prepop_detail_id_tab(l_index):=p_timekeeper_data_rec.resource_id;

      end if;

      if (p_timekeeper_data_rec.detail_id_27 is not null and
         p_timekeeper_data_rec.detail_id_27 < 0 ) then

         l_index:= p_timekeeper_data_rec.detail_id_27 * -1 ;

         p_tk_prepop_detail_id_tab(l_index):=p_timekeeper_data_rec.resource_id;

      end if;

      if (p_timekeeper_data_rec.detail_id_28 is not null and
         p_timekeeper_data_rec.detail_id_28 < 0 ) then

         l_index:= p_timekeeper_data_rec.detail_id_28 * -1 ;

         p_tk_prepop_detail_id_tab(l_index):=p_timekeeper_data_rec.resource_id;

      end if;

      if (p_timekeeper_data_rec.detail_id_29 is not null and
         p_timekeeper_data_rec.detail_id_29 < 0 ) then

         l_index:= p_timekeeper_data_rec.detail_id_29 * -1 ;

         p_tk_prepop_detail_id_tab(l_index):=p_timekeeper_data_rec.resource_id;

      end if;

      if (p_timekeeper_data_rec.detail_id_30 is not null and
         p_timekeeper_data_rec.detail_id_30 < 0 ) then

         l_index:= p_timekeeper_data_rec.detail_id_30 * -1 ;

         p_tk_prepop_detail_id_tab(l_index):=p_timekeeper_data_rec.resource_id;

    end if;

    if (p_timekeeper_data_rec.detail_id_31 is not null and
         p_timekeeper_data_rec.detail_id_31 < 0 ) then

         l_index:= p_timekeeper_data_rec.detail_id_31 * -1 ;

         p_tk_prepop_detail_id_tab(l_index):=p_timekeeper_data_rec.resource_id;

    end if;

   if g_debug then
          hr_utility.trace(' Leaving hxctkutil.populate_prepop_detail_id_info');
   end if;


   END; -- populate_prepop_detail_id_info



    ---------------------------------------------------------------------------------------


    FUNCTION get_abs_co_absence_detail_id
    (p_absence_duration  	IN NUMBER  DEFAULT NULL,
     p_absence_start_time 	IN DATE    DEFAULT NULL,
     p_absence_stop_time	IN DATE    DEFAULT NULL,
     p_absence_attendance_id	IN NUMBER,
     p_transaction_id		IN NUMBER,
     p_lock_row_id		IN ROWID,
     p_resource_id		IN NUMBER,
     p_start_period      	IN  DATE,
     p_end_period		IN  DATE,
     p_tc_start			IN  DATE,
     p_tc_end			IN  DATE,
     p_day_value		IN NUMBER
     )

    RETURN NUMBER IS

     l_detail_id 		NUMBER;
     l_day_value		NUMBER;

     BEGIN


     l_day_value:= p_day_value -
                   (trunc(to_number(p_start_period - p_tc_start))
                      );
     if g_debug then
     hr_utility.trace('l_day_value = '||l_day_value);
     end if;
     -- Take care if Empty Paramter handliing routine

    if g_debug then
     hr_utility.trace (' SVG bfore l_detail_id select query');
    end if;

     SELECT time_building_block_id
       INTO   l_detail_id
       FROM hxc_abs_co_details
      WHERE start_time = p_start_period
        AND trunc(stop_time) = trunc(p_end_period)
        AND resource_id = p_resource_id
        --AND nvl(absence_attendance_id,transaction_id) = p_absence_attendance_id
        AND lock_rowid = p_lock_row_id
        --AND stage = 'PREP'
        AND ((stage='PREP' AND absence_attendance_id = p_absence_attendance_id)
                        OR
             (stage='PREP-SS' AND transaction_id = p_transaction_id))

        AND (
            (    UOM='D'
             and measure = p_absence_duration
             and start_date = end_date
             and trunc(to_number(start_date - start_time)) = (l_day_value - 1)
            )
            OR
            (    UOM='H'
             and start_date = p_absence_start_time
             and end_date = p_absence_stop_time
            ))
        AND sessionid = userenv('SESSIONID')
        AND rownum<2;

     if g_debug then
     hr_utility.trace (' SVG after l_detail_id select query');
     hr_utility.trace('SVG l_detail_id ='||l_detail_id);
     end if;

     return (l_detail_id);




     END ; -- get_abs_co_absence_detail_id




   ---------------------------------------------------------------------------------------------------


  PROCEDURE build_absence_prepop_table
     (p_tk_prepop_info	IN  hxc_timekeeper_utilities.t_tk_prepop_info_type,
      p_tk_abs_tab	OUT NOCOPY hxc_timekeeper_process.t_tk_abs_tab_type,
      p_start_period    IN  DATE,
      p_end_period	IN  DATE,
      p_tc_start      	IN  DATE,
      p_tc_end	        IN  DATE,
      p_lock_row_id	IN  ROWID,
      p_resource_id	IN  NUMBER,
      p_timekeeper_id	IN NUMBER
     )

    IS

    TYPE tmp_sort_rec IS RECORD
        (
         index_value	BINARY_INTEGER,
         clash_flag	VARCHAR2(1)
        );

    TYPE tmp_sort_tab_type IS TABLE OF tmp_sort_rec
      	INDEX BY VARCHAR2(200);

    tmp_sort_tab		tmp_sort_tab_type;
    index_string		VARCHAR2(200);
    clash_counter		NUMBER:=0;
    l_clash_flag		VARCHAR2(1):='N';

    l_prev_attr_id	VARCHAR2(150);
    l_prev_attr_category	VARCHAR2(80);

    l_abs_tab_index	BINARY_INTEGER:=1;
    l_clash_index		BINARY_INTEGER:=0;
    l_clash_index_tmp	BINARY_INTEGER:=0;

    attr_assg 		VARCHAR2(1000);
    day_assg1		VARCHAR2(3000);
    day_assg2		VARCHAR2(3000);

    attr_value		VARCHAR2(2);
    day_value		VARCHAR2(2);

    tmp_index 		VARCHAR2(200);
    tmp_bin_index		BINARY_INTEGER;
    l_detail_id		NUMBER;
   /*
    p_block_array		HXC_BLOCK_TABLE_TYPE;
    p_attribute_array	HXC_ATTRIBUTE_TABLE_TYPE;

    l_resp_id		NUMBER;
    l_approval_style_id	hxc_time_building_blocks.approval_style_id%TYPE;
    l_resp_appl_id	NUMBER;

    */

    BEGIN

    /*
    p_block_array:=  HXC_BLOCK_TABLE_TYPE();

    p_attribute_array:= HXC_ATTRIBUTE_TABLE_TYPE();

    if g_debug then
    hr_utility.trace('Before hxc_preference_evaluation.get_tc_resp');
    end if;

    hxc_preference_evaluation.get_tc_resp
                     (p_resource_id,
                      p_start_period,
                      p_end_period,
                      l_resp_id,
                      l_resp_appl_id);

        if g_debug then
        hr_utility.trace('After hxc_preference_evaluation.get_tc_resp');
        end if;

        l_approval_style_id := hxc_preference_evaluation.resource_preferences(
                                 p_resource_id,
                                'TS_PER_APPROVAL_STYLE',
                                 1,
                                 l_resp_id
                             );

        if g_debug then
        hr_utility.trace('l_approval_style_id = '||l_approval_style_id);
        end if;

    HXC_RETRIEVE_ABSENCES.add_absence_types ( p_person_id   => p_resource_id,
  	                                     p_start_date  => p_start_period,
     	                                     p_end_date    => p_end_period,
  	                                     p_block_array => p_block_array,
                                  	     p_approval_style_id =>l_approval_style_id,
                                  	     p_attribute_array => p_attribute_array,
                                               p_lock_rowid  => p_lock_row_id,
                                               p_source => 'TK',
                                               p_timekeeper_id => p_timekeeper_id,
                                               p_iteration_count => hxc_timekeeper_process.g_resource_prepop_count
                                             );
      */
     if g_debug then
     hr_utility.trace('Entering build_absence_prepop_table');

     hr_utility.trace('BAPT 1');


     hr_utility.trace('p_tk_prepop_info.count = '||p_tk_prepop_info.count);



     if p_tk_prepop_info.count>0 then

       FOR i in p_tk_prepop_info.FIRST .. p_tk_prepop_info.LAST
       LOOP

       if p_tk_prepop_info.EXISTS(i) then

       hr_utility.trace('p_tk_prepop_info(i).ALIAS_VALUE_ID = '||p_tk_prepop_info(i).ALIAS_VALUE_ID);
       hr_utility.trace('p_tk_prepop_info(i).ITEM_ATTRIBUTE_CATEGORY = '||p_tk_prepop_info(i).ITEM_ATTRIBUTE_CATEGORY);
       hr_utility.trace('p_tk_prepop_info(i).ABSENCE_DATE = '||p_tk_prepop_info(i).ABSENCE_DATE);
       hr_utility.trace('p_tk_prepop_info(i).ABSENCE_DURATION = '||p_tk_prepop_info(i).ABSENCE_DURATION);
       hr_utility.trace('p_tk_prepop_info(i).ABSENCE_START_TIME = '||p_tk_prepop_info(i).ABSENCE_START_TIME);
       hr_utility.trace('p_tk_prepop_info(i).ABSENCE_STOP_TIME = '||p_tk_prepop_info(i).ABSENCE_STOP_TIME);
       hr_utility.trace('p_tk_prepop_info(i).ABSENCE_ATTENDANCE_ID = '||p_tk_prepop_info(i).ABSENCE_ATTENDANCE_ID);
       hr_utility.trace('p_tk_prepop_info(i).TRANSACTION_ID = '||p_tk_prepop_info(i).TRANSACTION_ID);

       end if;

       END LOOP;

     end if;

     end if;




    IF p_tk_prepop_info.COUNT > 0 THEN







      FOR i in p_tk_prepop_info.FIRST .. p_tk_prepop_info.LAST
      LOOP



       index_string:= to_char(p_tk_prepop_info(i).ALIAS_VALUE_ID) || '-' ||
                      to_char(p_tk_prepop_info(i).ITEM_ATTRIBUTE_CATEGORY) || '-' ||
                      to_char(p_tk_prepop_info(i).ABSENCE_DATE,'YYYYMMDD');

       IF tmp_sort_tab.EXISTS(index_string) THEN

       	clash_counter:= clash_counter + 1;
       	l_clash_flag:= 'Y';
       	index_string:= index_string||to_char(clash_counter);

       ELSE

       	l_clash_flag:= 'N';

       END IF;



       tmp_sort_tab(index_string).index_value:= i;
       tmp_sort_tab(index_string).clash_flag:= l_clash_flag;

        if g_debug then
        hr_utility.trace('index_string = '||index_string);
        hr_utility.trace('index_value = '||tmp_sort_tab(index_string).index_value);
        hr_utility.trace('clash_flag = '||tmp_sort_tab(index_string).clash_flag);
        end if;



      END LOOP; -- p_tk_prepop_info plsql table

    END IF; -- p_tk_prepop_info.COUNT

       if g_debug then
       hr_utility.trace('BAPT 2');
       end if;

    l_prev_attr_id:= p_tk_prepop_info(tmp_sort_tab(tmp_sort_tab.FIRST).index_value).ALIAS_VALUE_ID;
    l_prev_attr_category:= p_tk_prepop_info(tmp_sort_tab(tmp_sort_tab.FIRST).index_value).ITEM_ATTRIBUTE_CATEGORY;

     if g_debug then
     hr_utility.trace('BAPT 3');
     end if;

   IF tmp_sort_tab.COUNT>0 THEN


      tmp_index:= tmp_sort_tab.FIRST;

      WHILE tmp_index is not null

      LOOP

      if tmp_sort_tab.EXISTS(tmp_index) then

      if g_debug then
      hr_utility.trace('BAPT 3001');
      end if;

      l_clash_index_tmp:=0;

      if g_debug then
      hr_utility.trace(' BAPT 301');
      end if;

       IF to_char(p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ALIAS_VALUE_ID) = l_prev_attr_id AND
          p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ITEM_ATTRIBUTE_CATEGORY = l_prev_attr_category THEN

             if g_debug then
             hr_utility.trace(' BAPT 302');
             end if;

    	if tmp_sort_tab(tmp_index).clash_flag='Y' then

    		l_clash_index:=	l_clash_index+1;
    		l_clash_index_tmp:= l_clash_index;

    	end if;
                if g_debug then
                hr_utility.trace(' BAPT 303');
                end if;

       ELSE
          if g_debug then
          hr_utility.trace(' BAPT 304');
          end if;

           l_abs_tab_index:= l_abs_tab_index + l_clash_index + 1;
     	l_clash_index:=0;

          if g_debug then
          hr_utility.trace(' BAPT 305');
          end if;

       END IF;

        if g_debug then
        hr_utility.trace('BAPT 31');
        end if;

     attr_value := substr(p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ITEM_ATTRIBUTE_CATEGORY,
                         16);

      if g_debug then
      hr_utility.trace('ABSENCE_DATE = '||p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_DATE);
      end if;

     day_value :=  to_char (
                   trunc( to_number( p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_DATE
                                     -- - p_start_period
      		                     - p_tc_start
      		                 )
                        ) +1
                           );

        if g_debug then
        hr_utility.trace('BAPT 32');
        end if;

      tmp_bin_index:=l_abs_tab_index+l_clash_index_tmp;


      if g_debug then
      hr_utility.trace('SVG inputs to get_abs_co_absence_detail_id');
      hr_utility.trace('-------');
      hr_utility.trace('p_absence_duration = '||p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_DURATION);
      hr_utility.trace('p_absence_start_time = '||p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_START_TIME);
      hr_utility.trace('p_absence_stop_time = '    ||p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_STOP_TIME);
      hr_utility.trace('p_absence_attendance_id = '||p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_ATTENDANCE_ID);
      hr_utility.trace('p_transaction_id = '||p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).transaction_id);
      hr_utility.trace('p_lock_row_id = '||p_lock_row_id);
      hr_utility.trace('p_resource_id = '||p_resource_id);
      hr_utility.trace('p_start_period = '||p_start_period);
      hr_utility.trace('p_end_period = '||p_end_period);
      hr_utility.trace('p_tc_start = '||p_tc_start);
      hr_utility.trace('p_tc_end = '||p_tc_end);
      hr_utility.trace('p_day_value = '||day_value);
       end if;



      l_detail_id:= get_abs_co_absence_detail_id
                        (p_absence_duration => p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_DURATION
                        ,p_absence_start_time => p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_START_TIME
                        ,p_absence_stop_time => p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_STOP_TIME
                        ,p_absence_attendance_id => p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_ATTENDANCE_ID
                        ,p_transaction_id => p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).TRANSACTION_ID
                        ,p_lock_row_id => p_lock_row_id
                        ,p_resource_id => p_resource_id
                        ,p_start_period => p_start_period
                        ,p_end_period => p_end_period
      		        ,p_tc_start     =>  p_tc_start
       			,p_tc_end       =>  p_tc_end
      		        ,p_day_value  => to_number(day_value)
                         );

       if g_debug then
       hr_utility.trace('attr_value = '||attr_value);
       end if;

      CASE attr_value

       WHEN '1' THEN

         	p_tk_abs_tab(tmp_bin_index).attr_id_1:=
         	  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ALIAS_VALUE_ID;

       WHEN '2' THEN

         	p_tk_abs_tab(tmp_bin_index).attr_id_2:=
         	  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ALIAS_VALUE_ID;

       WHEN '3' THEN

         	p_tk_abs_tab(tmp_bin_index).attr_id_3:=
         	  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ALIAS_VALUE_ID;

       WHEN '4' THEN

         	p_tk_abs_tab(tmp_bin_index).attr_id_4:=
         	  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ALIAS_VALUE_ID;

       WHEN '5' THEN

         	p_tk_abs_tab(tmp_bin_index).attr_id_5:=
         	  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ALIAS_VALUE_ID;

       WHEN '6' THEN

         	p_tk_abs_tab(tmp_bin_index).attr_id_6:=
         	  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ALIAS_VALUE_ID;

       WHEN '7' THEN

         	p_tk_abs_tab(tmp_bin_index).attr_id_7:=
         	  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ALIAS_VALUE_ID;

       WHEN '8' THEN

         	p_tk_abs_tab(tmp_bin_index).attr_id_8:=
         	  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ALIAS_VALUE_ID;

       WHEN '9' THEN

         	p_tk_abs_tab(tmp_bin_index).attr_id_9:=
         	  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ALIAS_VALUE_ID;

       WHEN '10' THEN

         	p_tk_abs_tab(tmp_bin_index).attr_id_10:=
         	  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ALIAS_VALUE_ID;

       WHEN '11' THEN

         	p_tk_abs_tab(tmp_bin_index).attr_id_11:=
         	  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ALIAS_VALUE_ID;

       WHEN '12' THEN

         	p_tk_abs_tab(tmp_bin_index).attr_id_12:=
         	  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ALIAS_VALUE_ID;

       WHEN '13' THEN

         	p_tk_abs_tab(tmp_bin_index).attr_id_13:=
         	  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ALIAS_VALUE_ID;

       WHEN '14' THEN

         	p_tk_abs_tab(tmp_bin_index).attr_id_14:=
         	  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ALIAS_VALUE_ID;

       WHEN '15' THEN

         	p_tk_abs_tab(tmp_bin_index).attr_id_15:=
         	  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ALIAS_VALUE_ID;

       WHEN '16' THEN

         	p_tk_abs_tab(tmp_bin_index).attr_id_16:=
         	  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ALIAS_VALUE_ID;

       WHEN '17' THEN

         	p_tk_abs_tab(tmp_bin_index).attr_id_17:=
         	  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ALIAS_VALUE_ID;

       WHEN '18' THEN

         	p_tk_abs_tab(tmp_bin_index).attr_id_18:=
         	  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ALIAS_VALUE_ID;


       WHEN '19' THEN

         	p_tk_abs_tab(tmp_bin_index).attr_id_19:=
         	  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ALIAS_VALUE_ID;

       WHEN '20' THEN

         	p_tk_abs_tab(tmp_bin_index).attr_id_20:=
         	  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ALIAS_VALUE_ID;



      END CASE;


       CASE day_value

           WHEN '1' THEN

             	p_tk_abs_tab(tmp_bin_index).time_in_1:=
  		  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_START_TIME;

  		p_tk_abs_tab(tmp_bin_index).time_out_1:=
                    p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_STOP_TIME;

                  if ((p_tk_abs_tab(tmp_bin_index).time_in_1 is null) AND
                     (p_tk_abs_tab(tmp_bin_index).time_out_1 is null)) then

                     p_tk_abs_tab(tmp_bin_index).day_1:=
             	     p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_DURATION;

                  end if;


                  p_tk_abs_tab(tmp_bin_index).detail_id_1:= l_detail_id;
                  p_tk_abs_tab(tmp_bin_index).detail_ovn_1:= 1;




           WHEN '2' THEN


             	p_tk_abs_tab(tmp_bin_index).time_in_2:=
  		  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_START_TIME;

  		p_tk_abs_tab(tmp_bin_index).time_out_2:=
                    p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_STOP_TIME;

                  if ((p_tk_abs_tab(tmp_bin_index).time_in_2 is null) AND
                     (p_tk_abs_tab(tmp_bin_index).time_out_2 is null)) then

                     p_tk_abs_tab(tmp_bin_index).day_2:=
             	     p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_DURATION;

                  end if;

                  p_tk_abs_tab(tmp_bin_index).detail_id_2:= l_detail_id;
                  p_tk_abs_tab(tmp_bin_index).detail_ovn_2:= 1;


           WHEN '3' THEN


             	p_tk_abs_tab(tmp_bin_index).time_in_3:=
  		  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_START_TIME;

  		p_tk_abs_tab(tmp_bin_index).time_out_3:=
                    p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_STOP_TIME;

                  if ((p_tk_abs_tab(tmp_bin_index).time_in_3 is null) AND
                     (p_tk_abs_tab(tmp_bin_index).time_out_3 is null)) then

                     p_tk_abs_tab(tmp_bin_index).day_3:=
             	     p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_DURATION;

                  end if;

                  p_tk_abs_tab(tmp_bin_index).detail_id_3:= l_detail_id;
                  p_tk_abs_tab(tmp_bin_index).detail_ovn_3:= 1;


           WHEN '4' THEN


             	p_tk_abs_tab(tmp_bin_index).time_in_4:=
  		  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_START_TIME;

  		p_tk_abs_tab(tmp_bin_index).time_out_4:=
                    p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_STOP_TIME;

                  if ((p_tk_abs_tab(tmp_bin_index).time_in_4 is null) AND
                     (p_tk_abs_tab(tmp_bin_index).time_out_4 is null)) then

                     p_tk_abs_tab(tmp_bin_index).day_4:=
             	     p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_DURATION;

                  end if;

                  p_tk_abs_tab(tmp_bin_index).detail_id_4:= l_detail_id;
                  p_tk_abs_tab(tmp_bin_index).detail_ovn_4:= 1;


           WHEN '5' THEN


             	p_tk_abs_tab(tmp_bin_index).time_in_5:=
  		  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_START_TIME;

  		p_tk_abs_tab(tmp_bin_index).time_out_5:=
                    p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_STOP_TIME;

                  if ((p_tk_abs_tab(tmp_bin_index).time_in_5 is null) AND
                     (p_tk_abs_tab(tmp_bin_index).time_out_5 is null)) then

                     p_tk_abs_tab(tmp_bin_index).day_5:=
             	     p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_DURATION;

                  end if;

                  p_tk_abs_tab(tmp_bin_index).detail_id_5:= l_detail_id;
                  p_tk_abs_tab(tmp_bin_index).detail_ovn_5:= 1;


           WHEN '6' THEN


             	p_tk_abs_tab(tmp_bin_index).time_in_6:=
  		  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_START_TIME;

  		p_tk_abs_tab(tmp_bin_index).time_out_6:=
                    p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_STOP_TIME;

                  if ((p_tk_abs_tab(tmp_bin_index).time_in_6 is null) AND
                     (p_tk_abs_tab(tmp_bin_index).time_out_6 is null)) then

                     p_tk_abs_tab(tmp_bin_index).day_6:=
             	     p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_DURATION;

                  end if;

                  p_tk_abs_tab(tmp_bin_index).detail_id_6:= l_detail_id;
                  p_tk_abs_tab(tmp_bin_index).detail_ovn_6:= 1;


           WHEN '7' THEN


             	p_tk_abs_tab(tmp_bin_index).time_in_7:=
  		  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_START_TIME;

  		p_tk_abs_tab(tmp_bin_index).time_out_7:=
                    p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_STOP_TIME;

                  if ((p_tk_abs_tab(tmp_bin_index).time_in_7 is null) AND
                     (p_tk_abs_tab(tmp_bin_index).time_out_7 is null)) then

                     p_tk_abs_tab(tmp_bin_index).day_7:=
             	     p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_DURATION;

                  end if;

                  p_tk_abs_tab(tmp_bin_index).detail_id_7:= l_detail_id;
                  p_tk_abs_tab(tmp_bin_index).detail_ovn_7:= 1;


           WHEN '8' THEN


             	p_tk_abs_tab(tmp_bin_index).time_in_8:=
  		  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_START_TIME;

  		p_tk_abs_tab(tmp_bin_index).time_out_8:=
                    p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_STOP_TIME;

                  if ((p_tk_abs_tab(tmp_bin_index).time_in_8 is null) AND
                     (p_tk_abs_tab(tmp_bin_index).time_out_8 is null)) then

                     p_tk_abs_tab(tmp_bin_index).day_8:=
             	     p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_DURATION;

                  end if;

                  p_tk_abs_tab(tmp_bin_index).detail_id_8:= l_detail_id;
                  p_tk_abs_tab(tmp_bin_index).detail_ovn_8:= 1;


           WHEN '9' THEN


             	p_tk_abs_tab(tmp_bin_index).time_in_9:=
  		  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_START_TIME;

  		p_tk_abs_tab(tmp_bin_index).time_out_9:=
                    p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_STOP_TIME;

                  if ((p_tk_abs_tab(tmp_bin_index).time_in_9 is null) AND
                     (p_tk_abs_tab(tmp_bin_index).time_out_9 is null)) then

                     p_tk_abs_tab(tmp_bin_index).day_9:=
             	     p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_DURATION;

                  end if;

                  p_tk_abs_tab(tmp_bin_index).detail_id_9:= l_detail_id;
                  p_tk_abs_tab(tmp_bin_index).detail_ovn_9:= 1;


           WHEN '10' THEN


             	p_tk_abs_tab(tmp_bin_index).time_in_10:=
  		  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_START_TIME;

  		p_tk_abs_tab(tmp_bin_index).time_out_10:=
                    p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_STOP_TIME;

                  if ((p_tk_abs_tab(tmp_bin_index).time_in_10 is null) AND
                     (p_tk_abs_tab(tmp_bin_index).time_out_10 is null)) then

                     p_tk_abs_tab(tmp_bin_index).day_10:=
             	     p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_DURATION;

                  end if;

                  p_tk_abs_tab(tmp_bin_index).detail_id_10:= l_detail_id;
                  p_tk_abs_tab(tmp_bin_index).detail_ovn_10:= 1;


           WHEN '11' THEN


             	p_tk_abs_tab(tmp_bin_index).time_in_11:=
  		  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_START_TIME;

  		p_tk_abs_tab(tmp_bin_index).time_out_11:=
                    p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_STOP_TIME;

                  if ((p_tk_abs_tab(tmp_bin_index).time_in_11 is null) AND
                     (p_tk_abs_tab(tmp_bin_index).time_out_11 is null)) then

                     p_tk_abs_tab(tmp_bin_index).day_11:=
             	     p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_DURATION;

                  end if;

                  p_tk_abs_tab(tmp_bin_index).detail_id_11:= l_detail_id;
                  p_tk_abs_tab(tmp_bin_index).detail_ovn_11:= 1;



           WHEN '12' THEN


             	p_tk_abs_tab(tmp_bin_index).time_in_12:=
  		  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_START_TIME;

  		p_tk_abs_tab(tmp_bin_index).time_out_12:=
                    p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_STOP_TIME;

                  if ((p_tk_abs_tab(tmp_bin_index).time_in_12 is null) AND
                     (p_tk_abs_tab(tmp_bin_index).time_out_12 is null)) then

                     p_tk_abs_tab(tmp_bin_index).day_12:=
             	     p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_DURATION;

                  end if;

                  p_tk_abs_tab(tmp_bin_index).detail_id_12:= l_detail_id;
                  p_tk_abs_tab(tmp_bin_index).detail_ovn_12:= 1;



           WHEN '13' THEN


             	p_tk_abs_tab(tmp_bin_index).time_in_13:=
  		  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_START_TIME;

  		p_tk_abs_tab(tmp_bin_index).time_out_13:=
                    p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_STOP_TIME;

                  if ((p_tk_abs_tab(tmp_bin_index).time_in_13 is null) AND
                     (p_tk_abs_tab(tmp_bin_index).time_out_13 is null)) then

                     p_tk_abs_tab(tmp_bin_index).day_13:=
             	     p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_DURATION;

                  end if;

                  p_tk_abs_tab(tmp_bin_index).detail_id_13:= l_detail_id;
                  p_tk_abs_tab(tmp_bin_index).detail_ovn_13:= 1;


           WHEN '14' THEN


             	p_tk_abs_tab(tmp_bin_index).time_in_14:=
  		  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_START_TIME;

  		p_tk_abs_tab(tmp_bin_index).time_out_14:=
                    p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_STOP_TIME;

                  if ((p_tk_abs_tab(tmp_bin_index).time_in_14 is null) AND
                     (p_tk_abs_tab(tmp_bin_index).time_out_14 is null)) then

                     p_tk_abs_tab(tmp_bin_index).day_14:=
             	     p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_DURATION;

                  end if;

                  p_tk_abs_tab(tmp_bin_index).detail_id_14:= l_detail_id;
                  p_tk_abs_tab(tmp_bin_index).detail_ovn_14:= 1;


           WHEN '15' THEN


             	p_tk_abs_tab(tmp_bin_index).time_in_15:=
  		  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_START_TIME;

  		p_tk_abs_tab(tmp_bin_index).time_out_15:=
                    p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_STOP_TIME;

                  if ((p_tk_abs_tab(tmp_bin_index).time_in_15 is null) AND
                     (p_tk_abs_tab(tmp_bin_index).time_out_15 is null)) then

                     p_tk_abs_tab(tmp_bin_index).day_15:=
             	     p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_DURATION;

                  end if;

                  p_tk_abs_tab(tmp_bin_index).detail_id_15:= l_detail_id;
                  p_tk_abs_tab(tmp_bin_index).detail_ovn_15:= 1;


           WHEN '16' THEN


             	p_tk_abs_tab(tmp_bin_index).time_in_16:=
  		  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_START_TIME;

  		p_tk_abs_tab(tmp_bin_index).time_out_16:=
                    p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_STOP_TIME;

                  if ((p_tk_abs_tab(tmp_bin_index).time_in_16 is null) AND
                     (p_tk_abs_tab(tmp_bin_index).time_out_16 is null)) then

                     p_tk_abs_tab(tmp_bin_index).day_16:=
             	     p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_DURATION;

                  end if;

                  p_tk_abs_tab(tmp_bin_index).detail_id_16:= l_detail_id;
                  p_tk_abs_tab(tmp_bin_index).detail_ovn_16:= 1;


           WHEN '17' THEN


             	p_tk_abs_tab(tmp_bin_index).time_in_17:=
  		  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_START_TIME;

  		p_tk_abs_tab(tmp_bin_index).time_out_17:=
                    p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_STOP_TIME;

                  if ((p_tk_abs_tab(tmp_bin_index).time_in_17 is null) AND
                     (p_tk_abs_tab(tmp_bin_index).time_out_17 is null)) then

                     p_tk_abs_tab(tmp_bin_index).day_17:=
             	     p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_DURATION;

                  end if;

                  p_tk_abs_tab(tmp_bin_index).detail_id_17:= l_detail_id;
                  p_tk_abs_tab(tmp_bin_index).detail_ovn_17:= 1;


           WHEN '18' THEN


             	p_tk_abs_tab(tmp_bin_index).time_in_18:=
  		  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_START_TIME;

  		p_tk_abs_tab(tmp_bin_index).time_out_18:=
                    p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_STOP_TIME;

                  if ((p_tk_abs_tab(tmp_bin_index).time_in_18 is null) AND
                     (p_tk_abs_tab(tmp_bin_index).time_out_18 is null)) then

                     p_tk_abs_tab(tmp_bin_index).day_18:=
             	     p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_DURATION;

                  end if;

                  p_tk_abs_tab(tmp_bin_index).detail_id_18:= l_detail_id;
                  p_tk_abs_tab(tmp_bin_index).detail_ovn_18:= 1;


           WHEN '19' THEN


             	p_tk_abs_tab(tmp_bin_index).time_in_19:=
  		  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_START_TIME;

  		p_tk_abs_tab(tmp_bin_index).time_out_19:=
                    p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_STOP_TIME;

                  if ((p_tk_abs_tab(tmp_bin_index).time_in_19 is null) AND
                     (p_tk_abs_tab(tmp_bin_index).time_out_19 is null)) then

                     p_tk_abs_tab(tmp_bin_index).day_19:=
             	     p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_DURATION;

                  end if;

                  p_tk_abs_tab(tmp_bin_index).detail_id_19:= l_detail_id;
                  p_tk_abs_tab(tmp_bin_index).detail_ovn_19:= 1;


           WHEN '20' THEN


             	p_tk_abs_tab(tmp_bin_index).time_in_20:=
  		  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_START_TIME;

  		p_tk_abs_tab(tmp_bin_index).time_out_20:=
                    p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_STOP_TIME;

                  if ((p_tk_abs_tab(tmp_bin_index).time_in_20 is null) AND
                     (p_tk_abs_tab(tmp_bin_index).time_out_20 is null)) then

                     p_tk_abs_tab(tmp_bin_index).day_20:=
             	     p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_DURATION;

                  end if;

                  p_tk_abs_tab(tmp_bin_index).detail_id_20:= l_detail_id;
                  p_tk_abs_tab(tmp_bin_index).detail_ovn_20:= 1;


           WHEN '21' THEN


             	p_tk_abs_tab(tmp_bin_index).time_in_21:=
  		  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_START_TIME;

  		p_tk_abs_tab(tmp_bin_index).time_out_21:=
                    p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_STOP_TIME;

                  if ((p_tk_abs_tab(tmp_bin_index).time_in_21 is null) AND
                     (p_tk_abs_tab(tmp_bin_index).time_out_21 is null)) then

                     p_tk_abs_tab(tmp_bin_index).day_21:=
             	     p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_DURATION;

                  end if;

                  p_tk_abs_tab(tmp_bin_index).detail_id_21:= l_detail_id;
                  p_tk_abs_tab(tmp_bin_index).detail_ovn_21:= 1;


           WHEN '22' THEN


             	p_tk_abs_tab(tmp_bin_index).time_in_22:=
  		  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_START_TIME;

  		p_tk_abs_tab(tmp_bin_index).time_out_22:=
                    p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_STOP_TIME;

                  if ((p_tk_abs_tab(tmp_bin_index).time_in_22 is null) AND
                     (p_tk_abs_tab(tmp_bin_index).time_out_22 is null)) then

                     p_tk_abs_tab(tmp_bin_index).day_22:=
             	     p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_DURATION;

                  end if;

                  p_tk_abs_tab(tmp_bin_index).detail_id_22:= l_detail_id;
                  p_tk_abs_tab(tmp_bin_index).detail_ovn_22:= 1;


           WHEN '23' THEN


             	p_tk_abs_tab(tmp_bin_index).time_in_23:=
  		  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_START_TIME;

  		p_tk_abs_tab(tmp_bin_index).time_out_23:=
                    p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_STOP_TIME;

                  if ((p_tk_abs_tab(tmp_bin_index).time_in_23 is null) AND
                     (p_tk_abs_tab(tmp_bin_index).time_out_23 is null)) then

                     p_tk_abs_tab(tmp_bin_index).day_23:=
             	     p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_DURATION;

                  end if;

                  p_tk_abs_tab(tmp_bin_index).detail_id_23:= l_detail_id;
                  p_tk_abs_tab(tmp_bin_index).detail_ovn_23:= 1;


           WHEN '24' THEN


             	p_tk_abs_tab(tmp_bin_index).time_in_24:=
  		  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_START_TIME;

  		p_tk_abs_tab(tmp_bin_index).time_out_24:=
                    p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_STOP_TIME;

                  if ((p_tk_abs_tab(tmp_bin_index).time_in_24 is null) AND
                     (p_tk_abs_tab(tmp_bin_index).time_out_24 is null)) then

                     p_tk_abs_tab(tmp_bin_index).day_24:=
             	     p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_DURATION;

                  end if;

                  p_tk_abs_tab(tmp_bin_index).detail_id_24:= l_detail_id;
                  p_tk_abs_tab(tmp_bin_index).detail_ovn_24:= 1;


           WHEN '25' THEN


             	p_tk_abs_tab(tmp_bin_index).time_in_25:=
  		  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_START_TIME;

  		p_tk_abs_tab(tmp_bin_index).time_out_25:=
                    p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_STOP_TIME;

                  if ((p_tk_abs_tab(tmp_bin_index).time_in_25 is null) AND
                     (p_tk_abs_tab(tmp_bin_index).time_out_25 is null)) then

                     p_tk_abs_tab(tmp_bin_index).day_25:=
             	     p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_DURATION;

                  end if;

                  p_tk_abs_tab(tmp_bin_index).detail_id_25:= l_detail_id;
                  p_tk_abs_tab(tmp_bin_index).detail_ovn_25:= 1;


           WHEN '26' THEN


             	p_tk_abs_tab(tmp_bin_index).time_in_26:=
  		  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_START_TIME;

  		p_tk_abs_tab(tmp_bin_index).time_out_26:=
                    p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_STOP_TIME;

                  if ((p_tk_abs_tab(tmp_bin_index).time_in_26 is null) AND
                     (p_tk_abs_tab(tmp_bin_index).time_out_26 is null)) then

                     p_tk_abs_tab(tmp_bin_index).day_26:=
             	     p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_DURATION;

                  end if;

                  p_tk_abs_tab(tmp_bin_index).detail_id_26:= l_detail_id;
                  p_tk_abs_tab(tmp_bin_index).detail_ovn_26:= 1;


           WHEN '27' THEN

             	p_tk_abs_tab(tmp_bin_index).time_in_27:=
  		  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_START_TIME;

  		p_tk_abs_tab(tmp_bin_index).time_out_27:=
                    p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_STOP_TIME;

                  if ((p_tk_abs_tab(tmp_bin_index).time_in_27 is null) AND
                     (p_tk_abs_tab(tmp_bin_index).time_out_27 is null)) then

                     p_tk_abs_tab(tmp_bin_index).day_27:=
             	     p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_DURATION;

                  end if;

                  p_tk_abs_tab(tmp_bin_index).detail_id_27:= l_detail_id;
                  p_tk_abs_tab(tmp_bin_index).detail_ovn_27:= 1;


           WHEN '28' THEN


             	p_tk_abs_tab(tmp_bin_index).time_in_28:=
  		  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_START_TIME;

  		p_tk_abs_tab(tmp_bin_index).time_out_28:=
                    p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_STOP_TIME;

                  if ((p_tk_abs_tab(tmp_bin_index).time_in_28 is null) AND
                     (p_tk_abs_tab(tmp_bin_index).time_out_28 is null)) then

                     p_tk_abs_tab(tmp_bin_index).day_28:=
             	     p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_DURATION;

                  end if;

                  p_tk_abs_tab(tmp_bin_index).detail_id_28:= l_detail_id;
                  p_tk_abs_tab(tmp_bin_index).detail_ovn_28:= 1;


           WHEN '29' THEN


             	p_tk_abs_tab(tmp_bin_index).time_in_29:=
  		  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_START_TIME;

  		p_tk_abs_tab(tmp_bin_index).time_out_29:=
                    p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_STOP_TIME;

                  if ((p_tk_abs_tab(tmp_bin_index).time_in_29 is null) AND
                     (p_tk_abs_tab(tmp_bin_index).time_out_29 is null)) then

                     p_tk_abs_tab(tmp_bin_index).day_29:=
             	     p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_DURATION;

                  end if;

                  p_tk_abs_tab(tmp_bin_index).detail_id_29:= l_detail_id;
                  p_tk_abs_tab(tmp_bin_index).detail_ovn_29:= 1;


           WHEN '30' THEN


             	p_tk_abs_tab(tmp_bin_index).time_in_30:=
  		  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_START_TIME;

  		p_tk_abs_tab(tmp_bin_index).time_out_30:=
                    p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_STOP_TIME;

                  if ((p_tk_abs_tab(tmp_bin_index).time_in_30 is null) AND
                     (p_tk_abs_tab(tmp_bin_index).time_out_30 is null)) then

                     p_tk_abs_tab(tmp_bin_index).day_30:=
             	     p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_DURATION;

                  end if;

                  p_tk_abs_tab(tmp_bin_index).detail_id_30:= l_detail_id;
                  p_tk_abs_tab(tmp_bin_index).detail_ovn_30:= 1;


           WHEN '31' THEN


             	p_tk_abs_tab(tmp_bin_index).time_in_31:=
  		  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_START_TIME;

  		p_tk_abs_tab(tmp_bin_index).time_out_31:=
                    p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_STOP_TIME;

                  if ((p_tk_abs_tab(tmp_bin_index).time_in_31 is null) AND
                     (p_tk_abs_tab(tmp_bin_index).time_out_31 is null)) then

                     p_tk_abs_tab(tmp_bin_index).day_31:=
             	     p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_DURATION;

                  end if;

                  p_tk_abs_tab(tmp_bin_index).detail_id_31:= l_detail_id;
                  p_tk_abs_tab(tmp_bin_index).detail_ovn_31:= 1;



         END CASE;



     /*
     attr_assg:='p_tk_abs_tab(tmp_bin_index).attr_id_' || attr_value  || ' := ' ||
                 'p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ALIAS_VALUE_ID ;' ;


     day_assg1:= 'p_tk_abs_tab(tmp_bin_index).day_' || day_value || ' := ' ||
                'p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_DURATION ; ' ;


     day_assg2:= 'p_tk_abs_tab(tmp_bin_index).time_in_' || day_value || ':=' ||
                'p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_START_TIME ; '||
                'p_tk_abs_tab(l_abs_tab_index+l_clash_index_tmp).time_out_' || day_value || ':=' ||
                'p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_STOP_TIME ; ' ;


     attr_assg:= 'BEGIN '||attr_assg||' END;';
     day_assg1:= 'BEGIN '||day_assg1||' END;' ;
     day_assg2:= 'BEGIN '||day_assg2||' END;' ;

          hr_utility.trace('BAPT 33');

     hr_utility.trace('attr_assg ='||attr_assg);
     hr_utility.trace('day_assg1 ='||day_assg1);
     hr_utility.trace('day_assg2 ='||day_assg2);

     EXECUTE IMMEDIATE attr_assg;

          hr_utility.trace('BAPT 34');

     IF g_debug THEN


     	hr_utility.trace('Alias Value = '||
     	  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ALIAS_VALUE_ID);
     	hr_utility.trace('ABSENCE_DURATION = '||
     	  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_DURATION);
     	hr_utility.trace('ABSENCE_START_TIME = '||
     	  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_START_TIME);
     	hr_utility.trace('ABSENCE_STOP_TIME = '||
     	  p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_STOP_TIME);


     END IF;


     if p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ABSENCE_START_TIME IS NOT NULL THEN

     EXECUTE IMMEDIATE (day_assg2);

     else

     EXECUTE IMMEDIATE (day_assg1);

     end if;
     */

     l_prev_attr_id:= p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ALIAS_VALUE_ID;
     l_prev_attr_category:= p_tk_prepop_info(tmp_sort_tab(tmp_index).index_value).ITEM_ATTRIBUTE_CATEGORY;

     end if;

     tmp_index:=tmp_sort_tab.NEXT(tmp_index);

     END LOOP;

    END IF;

       if g_debug then
       hr_utility.trace('BAPT 4');
       end if;

    END ;



   ---------------------------------------------------------------------------------------------------


    PROCEDURE PRE_POPULATE_ABSENCE_DETAILS
    (p_timekeeper_id 	IN 	NUMBER,
     p_start_period 	IN 	DATE,
     p_end_period 	IN 	DATE,
     p_tc_start		IN 	DATE,
     p_tc_end		IN	DATE,
     p_resource_id 	IN 	NUMBER,
     p_lock_row_id	IN 	ROWID,
     p_tk_abs_tab	OUT 	NOCOPY hxc_timekeeper_process.t_tk_abs_tab_type
     )

    IS

     CURSOR get_alias_info (
       p_element_type_id 		IN NUMBER,
       p_alias_definition_id	IN NUMBER,
       p_start_period		IN DATE,
       p_end_period		IN DATE
      ) IS

       SELECT hav.alias_value_id

       FROM   hxc_alias_values hav,
              hxc_alias_definitions had,
              hxc_alias_types hat

       WHERE  hav.attribute1=to_char(p_element_type_id) and
              hav.enabled_flag='Y' and
              hav.attribute_category='PAYROLL_ELEMENTS' and
              --nvl(hav.date_from,hr_general.start_of_time) <= p_start_period and
	      --nvl(hav.date_to,hr_general.end_of_time) >= p_end_period and
	      nvl(hav.date_from,hr_general.start_of_time) <= p_end_period and
              nvl(hav.date_to,hr_general.end_of_time) >= p_start_period and
              hav.alias_definition_id=p_alias_definition_id and
              hav.alias_definition_id=had.alias_definition_id and
              had.alias_type_id=hat.alias_type_id and
              hat.alias_type = 'OTL_ALT_DDF' and
              hat.reference_object = 'PAYROLL_ELEMENTS'and
              rownum < 2;


     l_abs_tab   		HXC_RETRIEVE_ABSENCES.ABS_TAB;
     l_alias_def_item 	HXC_ALIAS_UTILITY.t_alias_def_item;

     l_tk_prepop_info_counter 	binary_integer:=0;
     l_tk_prepop_info 		t_tk_prepop_info_type    ;

     l_abs_pending_appr_notif	EXCEPTION;

     p_block_array		  HXC_BLOCK_TABLE_TYPE;
     p_attribute_array	HXC_ATTRIBUTE_TABLE_TYPE;
     p_messages         HXC_MESSAGE_TABLE_TYPE;

    l_resp_id		NUMBER;
    l_approval_style_id	hxc_time_building_blocks.approval_style_id%TYPE;
    l_resp_appl_id	NUMBER;

    l_index 	NUMBER;


    BEGIN

    p_block_array:=  HXC_BLOCK_TABLE_TYPE();

    p_attribute_array:= HXC_ATTRIBUTE_TABLE_TYPE();

    p_messages:= HXC_MESSAGE_TABLE_TYPE();

    if g_debug then
    hr_utility.trace('Before hxc_preference_evaluation.get_tc_resp');
    end if;

    hxc_preference_evaluation.get_tc_resp
                     (p_resource_id,
                      p_start_period,
                      p_end_period,
                      l_resp_id,
                      l_resp_appl_id);

        if g_debug then
        hr_utility.trace('After hxc_preference_evaluation.get_tc_resp');
        end if;

        l_approval_style_id := hxc_preference_evaluation.resource_preferences(
                                 p_resource_id,
                                'TS_PER_APPROVAL_STYLE',
                                 1,
                                 l_resp_id
                             );

        if g_debug then
        hr_utility.trace('l_approval_style_id = '||l_approval_style_id);
        end if;


    HXC_RETRIEVE_ABSENCES.add_absence_types ( p_person_id   => p_resource_id,
  	                                     p_start_date  => p_start_period,
     	                                     p_end_date    => p_end_period,
  	                                     p_block_array => p_block_array,
                                  	     p_approval_style_id =>l_approval_style_id,
                                  	     p_attribute_array => p_attribute_array,
                                               p_lock_rowid  => p_lock_row_id,
                                               p_source => 'TK',
                                               p_timekeeper_id => p_timekeeper_id,
                                               p_iteration_count => hxc_timekeeper_process.g_resource_prepop_count
                                             );

     if g_debug then
     hr_utility.trace('INSIDE pre_populate absences');
     hr_utility.trace('PPA 1');
     end if;

     hxc_retrieve_absences.g_message_string:=null;
     g_abs_message_string:=null;
     hxc_retrieve_absences.g_messages := HXC_MESSAGE_TABLE_TYPE();
     hxc_retrieve_absences.g_messages.DELETE;
     g_exception_detected:= 'N';

     if g_debug then
         hr_utility.trace(' Resource= '||p_resource_id);
         hr_utility.trace('After instantiating - hxc_retrieve_absences.g_messages.count = '
                      ||hxc_retrieve_absences.g_messages.count);
     end if;

     hxc_retrieve_absences.retrieve_absences(p_person_id =>  p_resource_id,
                                             p_start_date => p_start_period,
                                             p_end_date   => p_end_period,
                                             p_abs_tab    => l_abs_tab);
       p_messages:= hxc_retrieve_absences.g_messages;
      if g_debug then
         hr_utility.trace(' Resource= '||p_resource_id);
         hr_utility.trace('After populating - hxc_retrieve_absences.g_messages.count = '
                           || hxc_retrieve_absences.g_messages.count);
         hr_utility.trace('After populating -p_messages.count = '
                           ||p_messages.count);
      end if;

      if p_messages.count>0 then
        l_index:= p_messages.first;
        g_abs_message_string:= p_messages(l_index).message_name;
     end if;
        if g_debug then
        hr_utility.trace('PPA 2');
        end if;

       g_abs_message_string:= hxc_retrieve_absences.g_message_string;

     if g_debug then
      hr_utility.trace('g_message_string = '||g_abs_message_string);
     end if;

     if (g_abs_message_string = 'HXC_ABS_PEND_APPR_DELETE' OR
        g_abs_message_string = 'HXC_ABS_PEND_APPR_ERROR' ) then

        hr_utility.trace('Raising exception for '|| p_resource_id);
        raise l_abs_pending_appr_notif;

      end if;






     IF g_debug then

            IF l_abs_tab.COUNT > 0
                THEN
                   FOR i IN l_abs_tab.FIRST..l_abs_tab.LAST
                   LOOP

                      hr_utility.trace('SVG entered loop');

                      hr_utility.trace(l_abs_tab(i).abs_date||
                        '-'||l_abs_tab(i).element_type_id||
                        '-'||l_abs_tab(i).abs_type_id||
                        '-'||l_abs_tab(i).duration||
                        '-'||l_abs_tab(i).abs_attendance_id||
                        '-'||l_abs_tab(i).transaction_id);
                   END LOOP;
            END IF;
      END IF;



     HXC_ALIAS_UTILITY.get_alias_def_item (p_timekeeper_id => p_timekeeper_id,
                                            p_alias_def_item => l_alias_def_item
                                          );

       if g_debug then
       hr_utility.trace('PPA 3');
       end if;

     IF g_debug then

        IF l_alias_def_item.COUNT > 0
            THEN
               FOR i IN l_alias_def_item.FIRST..l_alias_def_item.LAST
               LOOP
                  hr_utility.trace('ALIAS_DEFINITION_ID = '|| l_alias_def_item(i).ALIAS_DEFINITION_ID);
                  hr_utility.trace('ITEM_ATTRIBUTE_CATEGORY = '|| l_alias_def_item(i).ITEM_ATTRIBUTE_CATEGORY);
                  hr_utility.trace('RESOURCE_ID = '|| l_alias_def_item(i).RESOURCE_ID);
                  hr_utility.trace('LAYOUT_ID = '|| l_alias_def_item(i).LAYOUT_ID);
                  hr_utility.trace('ALIAS_LABEL = '|| l_alias_def_item(i).ALIAS_LABEL);
                  hr_utility.trace('PREF_START_DATE = '|| l_alias_def_item(i).PREF_START_DATE);
                  hr_utility.trace('PREF_END_DATE = '|| l_alias_def_item(i).PREF_END_DATE);
               END LOOP;
        END IF;

 END IF;



     IF l_abs_tab.COUNT > 0 THEN

      FOR abs_count in l_abs_tab.FIRST .. l_abs_tab.LAST
      LOOP
         if g_debug then
         hr_utility.trace('entering l_abs_tab loop');
	 hr_utility.trace('l_abs_tab(i).element_type_id='||l_abs_tab(abs_count).element_type_id);
         end if;

        IF l_alias_def_item.COUNT > 0 THEN

          FOR alias_def_count in l_alias_def_item.FIRST .. l_alias_def_item.LAST
          LOOP
                if g_debug then
                hr_utility.trace('l_abs_tab(abs_count).element_type_id = '|| l_abs_tab(abs_count).element_type_id);
		hr_utility.trace('l_alias_def_item(alias_def_count).ALIAS_DEFINITION_ID = '|| l_alias_def_item(alias_def_count).ALIAS_DEFINITION_ID);
		hr_utility.trace('p_start_period = '|| p_start_period);
                hr_utility.trace('p_end_period = '|| p_end_period);
                end if;

            	FOR alias_info in get_alias_info(
            					l_abs_tab(abs_count).element_type_id,
   						l_alias_def_item(alias_def_count).ALIAS_DEFINITION_ID,
   						p_start_period,
   		                                p_end_period
            					)
            	LOOP

            		l_tk_prepop_info_counter:= l_tk_prepop_info_counter + 1;

                        if g_debug then
                        hr_utility.trace('PPA entered the loop');
                        end if;

           		l_tk_prepop_info(l_tk_prepop_info_counter).ALIAS_VALUE_ID:=
            			alias_info.alias_value_id;

            		l_tk_prepop_info(l_tk_prepop_info_counter).ITEM_ATTRIBUTE_CATEGORY:=
            			l_alias_def_item(alias_def_count).ITEM_ATTRIBUTE_CATEGORY;

            		l_tk_prepop_info(l_tk_prepop_info_counter).ABSENCE_DATE:=
            			l_abs_tab(abs_count).abs_date;

            		l_tk_prepop_info(l_tk_prepop_info_counter).ABSENCE_DURATION:=
            			l_abs_tab(abs_count).duration;

            		l_tk_prepop_info(l_tk_prepop_info_counter).ABSENCE_START_TIME:=
            			l_abs_tab(abs_count).abs_start;

            		l_tk_prepop_info(l_tk_prepop_info_counter).ABSENCE_STOP_TIME:=
            			l_abs_tab(abs_count).abs_end;

            		l_tk_prepop_info(l_tk_prepop_info_counter).ABSENCE_ATTENDANCE_ID:=
			         l_abs_tab(abs_count).abs_attendance_id;

                        l_tk_prepop_info(l_tk_prepop_info_counter).transaction_id:=
	          		     l_abs_tab(abs_count).transaction_id;

              	END LOOP;

          END LOOP;


        END IF;

      END LOOP;


     END IF;

       if g_debug then
       hr_utility.trace('PPA 4');
       end if;

     IF l_tk_prepop_info.COUNT > 0 THEN

      build_absence_prepop_table(p_tk_prepop_info => l_tk_prepop_info,
       			      p_tk_abs_tab    =>  p_tk_abs_tab,
       			      p_start_period  =>  p_start_period,
       			      p_end_period    =>  p_end_period,
       			      p_tc_start      =>  p_tc_start,
       			      p_tc_end	      =>  p_tc_end,
       			      p_lock_row_id   =>  p_lock_row_id,
       			      p_resource_id   =>  p_resource_id ,
       			      p_timekeeper_id =>  p_timekeeper_id
       			      );

     END IF;

   EXCEPTION
   WHEN l_abs_pending_appr_notif then

       g_exception_detected:= 'Y';

   END; --  PRE_POPULATE_ABSENCE_DETAILS




------------------------------------------------------------------------------------------------


END hxc_timekeeper_utilities;

/
