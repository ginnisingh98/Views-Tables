--------------------------------------------------------
--  DDL for Package Body HXC_APPROVAL_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_APPROVAL_WF_PKG" AS
/* $Header: hxcapprwf.pkb 120.29.12010000.14 2010/04/07 12:16:45 amakrish ship $ */
--
-- Possible Notification Status Constants.
--
  c_not_notified constant varchar2(12) := 'NOT_NOTIFIED';
  c_notified     constant varchar2(8) := 'NOTIFIED';
  c_finished     constant varchar2(8) := 'FINISHED';
  g_debug		  BOOLEAN     :=hr_utility.debug_enabled;

 g_trace          VARCHAR2(2000);

 TYPE approval_comp IS RECORD(
   approval_comp_id       hxc_approval_comps.approval_comp_id%TYPE
  ,object_version_number  hxc_approval_comps.object_version_number%TYPE
  ,approval_mechanism     hxc_approval_comps.approval_mechanism%TYPE
  ,approval_mechanism_id  hxc_approval_comps.approval_mechanism_id%TYPE
  ,wf_item_type           hxc_approval_comps.wf_item_type%TYPE
  ,wf_name                hxc_approval_comps.wf_name%TYPE
  ,time_category_id       hxc_approval_comps.time_category_id%TYPE
  ,approval_order         hxc_approval_comps.approval_order%TYPE
 );


 TYPE approval_attribute is RECORD(
   time_recipient_id VARCHAR2(150)
  ,item_key          VARCHAR2(150)
  --all the following fields are not needed. they are here just so custom code won't break
  ,approver_id       VARCHAR2(150)
  ,notified_status   VARCHAR2(150)
  ,approved_time     VARCHAR2(150)
  ,approver_comment  VARCHAR2(150)
  ,approval_status   VARCHAR2(150)
 );

 TYPE block_info IS RECORD(
   block_id  hxc_time_building_blocks.time_building_block_id%TYPE
  ,block_ovn hxc_time_building_blocks.object_version_number%TYPE
  ,added     VARCHAR2(1)
 );

 TYPE block_table IS TABLE OF
   block_info
 INDEX BY BINARY_INTEGER;

 ------   Project manager changes
 g_tab_project_id hxc_proj_manager_approval_pkg.tab_project_id;

 g_block_exist_for_ap varchar2(1);

-- Added for bug 9076079
 TYPE old_item_key_rec IS RECORD(is_diff_tc  VARCHAR2(1));

 TYPE old_item_key_tab IS TABLE OF
  old_item_key_rec
 INDEX BY BINARY_INTEGER;

 g_old_item_key old_item_key_tab;


 FUNCTION get_creation_date(
   p_app_id hxc_time_building_blocks.time_building_block_id%TYPE
  ,p_app_ovn hxc_time_building_blocks.object_version_number%TYPE
 )
 RETURN DATE
 IS
   CURSOR c_creation_date(
     p_app_id hxc_time_building_blocks.time_building_block_id%TYPE
    ,p_app_ovn hxc_time_building_blocks.object_version_number%TYPE
   )
   IS
   SELECT creation_date
     FROM hxc_time_building_blocks
    WHERE time_building_block_id = p_app_id
      AND object_version_number = p_app_ovn;

   l_creation_date hxc_time_building_blocks.creation_date%TYPE := NULL;
 BEGIN
   OPEN c_creation_date(
     p_app_id => p_app_id
    ,p_app_ovn => p_app_ovn
   );

   FETCH c_creation_date INTO l_creation_date;
   CLOSE c_creation_date;

   RETURN l_creation_date;

 END get_creation_date;



 --this procedure gets all the detail blocks associated with
 --timecard p_timecard_id and also fall between p_start_time
 --and p_stop_time of an application period

 PROCEDURE get_detail_blocks(
   p_timecard_id IN hxc_time_building_blocks.time_building_block_id%TYPE
  ,p_timecard_ovn hxc_time_building_blocks.object_version_number%TYPE
  ,p_start_time  IN hxc_time_building_blocks.start_time%TYPE
  ,p_stop_time   IN hxc_time_building_blocks.stop_time%TYPE
  ,p_detail_blocks IN OUT NOCOPY block_table
  ,p_new_detail_blocks IN OUT NOCOPY hxc_block_table_type
 )
 IS
   CURSOR c_detail_blocks(
     p_timecard_id  hxc_time_building_blocks.time_building_block_id%TYPE
    ,p_timecard_ovn hxc_time_building_blocks.object_version_number%TYPE
    ,p_start_time   hxc_time_building_blocks.start_time%TYPE
    ,p_stop_time    hxc_time_building_blocks.stop_time%TYPE
   )
   IS
   SELECT
   details.TIME_BUILDING_BLOCK_ID,
   details.TYPE,
   details.MEASURE,
   details.UNIT_OF_MEASURE,
   DECODE(details.type, 'RANGE', FND_DATE.DATE_TO_CANONICAL(details.start_time),
          FND_DATE.DATE_TO_CANONICAL(days.start_time) ) CANONICAL_START_TIME,
   DECODE(details.type, 'RANGE', FND_DATE.DATE_TO_CANONICAL(details.stop_time),
          FND_DATE.DATE_TO_CANONICAL(days.stop_time) ) CANONICAL_STOP_TIME,
   details.PARENT_BUILDING_BLOCK_ID,
   NULL PARENT_IS_NEW,
   details.SCOPE,
   details.OBJECT_VERSION_NUMBER,
   details.APPROVAL_STATUS,
   details.RESOURCE_ID,
   details.RESOURCE_TYPE,
   details.APPROVAL_STYLE_ID,
   FND_DATE.DATE_TO_CANONICAL(details.date_from) CANONICAL_DATE_FROM,
   FND_DATE.DATE_TO_CANONICAL(details.date_to) CANONICAL_DATE_TO,
   details.COMMENT_TEXT,
   details.PARENT_BUILDING_BLOCK_OVN,
   'N' NEW,
   'N' CHANGED,
   'N' PROCESS,
   details.APPLICATION_SET_ID,
   details.TRANSLATION_DISPLAY_KEY
     FROM hxc_time_building_blocks days
          ,hxc_time_building_blocks details
    WHERE days.parent_building_block_id = p_timecard_id
      AND days.parent_building_block_ovn = p_timecard_ovn
      AND days.scope = 'DAY'
      AND TRUNC(days.start_time) BETWEEN TRUNC(p_start_time) AND TRUNC(p_stop_time)
      AND days.date_to = hr_general.end_of_time
      AND details.scope = 'DETAIL'
      AND details.parent_building_block_id = days.time_building_block_id
      AND details.parent_building_block_ovn = days.object_version_number
      AND details.date_to = hr_general.end_of_time;

   l_cursor_blocks c_detail_blocks%ROWTYPE;

   l_detail_blocks block_table;
   l_new_detail_blocks hxc_block_table_type := hxc_block_table_type ();
   l_block_index PLS_INTEGER := 1;

 BEGIN
   OPEN c_detail_blocks(
     p_timecard_id  => p_timecard_id
    ,p_timecard_ovn => p_timecard_ovn
    ,p_start_time   => p_start_time
    ,p_stop_time    => p_stop_time
   );

   LOOP
     FETCH c_detail_blocks INTO l_cursor_blocks;
     EXIT WHEN c_detail_blocks%NOTFOUND;

     l_detail_blocks(l_block_index).block_id  := l_cursor_blocks.time_building_block_id;
     l_detail_blocks(l_block_index).block_ovn := l_cursor_blocks.object_version_number;
     l_detail_blocks(l_block_index).added     := 'N';

     l_new_detail_blocks.extend();
     l_new_detail_blocks(l_block_index) := HXC_BLOCK_TYPE(l_cursor_blocks.TIME_BUILDING_BLOCK_ID,
                                                          l_cursor_blocks.TYPE,
                                                          l_cursor_blocks.MEASURE,
                                                          l_cursor_blocks.UNIT_OF_MEASURE,
                                                          l_cursor_blocks.CANONICAL_START_TIME,
                                                          l_cursor_blocks.CANONICAL_STOP_TIME,
                                                          l_cursor_blocks.PARENT_BUILDING_BLOCK_ID,
                                                          l_cursor_blocks.PARENT_IS_NEW,
                                                          l_cursor_blocks.SCOPE,
                                                          l_cursor_blocks.OBJECT_VERSION_NUMBER,
                                                          l_cursor_blocks.APPROVAL_STATUS,
                                                          l_cursor_blocks.RESOURCE_ID,
                                                          l_cursor_blocks.RESOURCE_TYPE,
                                                          l_cursor_blocks.APPROVAL_STYLE_ID,
                                                          l_cursor_blocks.CANONICAL_DATE_FROM,
                                                          l_cursor_blocks.CANONICAL_DATE_TO,
                                                          l_cursor_blocks.COMMENT_TEXT,
                                                          l_cursor_blocks.PARENT_BUILDING_BLOCK_OVN,
                                                          l_cursor_blocks.NEW,
                                                          l_cursor_blocks.CHANGED,
                                                          l_cursor_blocks.PROCESS,
                                                          l_cursor_blocks.APPLICATION_SET_ID,
                                                          l_cursor_blocks.TRANSLATION_DISPLAY_KEY);

     l_block_index := l_block_index + 1;
   END LOOP;

   CLOSE c_detail_blocks;

   p_detail_blocks := l_detail_blocks;
   p_new_detail_blocks := l_new_detail_blocks;


 END get_detail_blocks;


 --this function returns all the attributes associated with the detail blocks
 PROCEDURE get_detail_attributes(
   p_detail_blocks         IN block_table,
   p_detail_attributes     IN OUT NOCOPY hxc_self_service_time_deposit.building_block_attribute_info,
   p_new_detail_attributes IN OUT NOCOPY hxc_attribute_table_type
 )

 IS
   l_attribute_index   PLS_INTEGER := 1;
   l_new_attributes    hxc_attribute_table_type := hxc_attribute_table_type ();
   l_detail_attributes hxc_self_service_time_deposit.building_block_attribute_info;
   l_block_index       PLS_INTEGER;

   CURSOR c_block_attributes(
     p_detail_id hxc_time_building_blocks.time_building_block_id%TYPE
    ,p_detail_ovn hxc_time_building_blocks.object_version_number%TYPE
   )
   IS
     select   a.time_attribute_id
              ,au.time_building_block_id building_block_id
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
        from hxc_time_attributes a,
             hxc_time_attribute_usages au,
             hxc_bld_blk_info_types bbit
       where au.time_building_block_id = p_detail_id
         and au.time_building_block_ovn = p_detail_ovn
         and au.time_attribute_id = a.time_attribute_id
         and a.bld_blk_info_type_id = bbit.bld_blk_info_type_id;

 l_cursor_attributes c_block_attributes%ROWTYPE;


 BEGIN
   l_block_index := p_detail_blocks.first;

   LOOP
     EXIT WHEN NOT p_detail_blocks.exists(l_block_index);

     OPEN c_block_attributes(
       p_detail_id  => p_detail_blocks(l_block_index).block_id
      ,p_detail_ovn => p_detail_blocks(l_block_index).block_ovn
     );

     LOOP
       FETCH c_block_attributes INTO l_detail_attributes(l_attribute_index);
       EXIT WHEN c_block_attributes%NOTFOUND;


       -- populate new structure
       l_new_attributes.extend();
       l_new_attributes(l_attribute_index) := HXC_ATTRIBUTE_TYPE (l_detail_attributes(l_attribute_index).TIME_ATTRIBUTE_ID,
                                                                  l_detail_attributes(l_attribute_index).BUILDING_BLOCK_ID,
                                                                  l_detail_attributes(l_attribute_index).ATTRIBUTE_CATEGORY,
                                                                  l_detail_attributes(l_attribute_index).ATTRIBUTE1,
                                                                  l_detail_attributes(l_attribute_index).ATTRIBUTE2,
                                                                  l_detail_attributes(l_attribute_index).ATTRIBUTE3,
                                                                  l_detail_attributes(l_attribute_index).ATTRIBUTE4,
                                                                  l_detail_attributes(l_attribute_index).ATTRIBUTE5,
                                                                  l_detail_attributes(l_attribute_index).ATTRIBUTE6,
                                                                  l_detail_attributes(l_attribute_index).ATTRIBUTE7,
                                                                  l_detail_attributes(l_attribute_index).ATTRIBUTE8,
                                                                  l_detail_attributes(l_attribute_index).ATTRIBUTE9,
                                                                  l_detail_attributes(l_attribute_index).ATTRIBUTE10,
                                                                  l_detail_attributes(l_attribute_index).ATTRIBUTE11,
                                                                  l_detail_attributes(l_attribute_index).ATTRIBUTE12,
                                                                  l_detail_attributes(l_attribute_index).ATTRIBUTE13,
                                                                  l_detail_attributes(l_attribute_index).ATTRIBUTE14,
                                                                  l_detail_attributes(l_attribute_index).ATTRIBUTE15,
                                                                  l_detail_attributes(l_attribute_index).ATTRIBUTE16,
                                                                  l_detail_attributes(l_attribute_index).ATTRIBUTE17,
                                                                  l_detail_attributes(l_attribute_index).ATTRIBUTE18,
                                                                  l_detail_attributes(l_attribute_index).ATTRIBUTE19,
                                                                  l_detail_attributes(l_attribute_index).ATTRIBUTE20,
                                                                  l_detail_attributes(l_attribute_index).ATTRIBUTE21,
                                                                  l_detail_attributes(l_attribute_index).ATTRIBUTE22,
                                                                  l_detail_attributes(l_attribute_index).ATTRIBUTE23,
                                                                  l_detail_attributes(l_attribute_index).ATTRIBUTE24,
                                                                  l_detail_attributes(l_attribute_index).ATTRIBUTE25,
                                                                  l_detail_attributes(l_attribute_index).ATTRIBUTE26,
                                                                  l_detail_attributes(l_attribute_index).ATTRIBUTE27,
                                                                  l_detail_attributes(l_attribute_index).ATTRIBUTE28,
                                                                  l_detail_attributes(l_attribute_index).ATTRIBUTE29,
                                                                  l_detail_attributes(l_attribute_index).ATTRIBUTE30,
                                                                  l_detail_attributes(l_attribute_index).BLD_BLK_INFO_TYPE_ID,
                                                                  l_detail_attributes(l_attribute_index).OBJECT_VERSION_NUMBER,
                                                                  l_detail_attributes(l_attribute_index).NEW,
                                                                  l_detail_attributes(l_attribute_index).CHANGED,
                                                                  l_detail_attributes(l_attribute_index).BLD_BLK_INFO_TYPE,
                                                                  NULL,
                                                                  1 );

       l_attribute_index := l_attribute_index + 1;
    END LOOP;

    CLOSE c_block_attributes;

    l_block_index := p_detail_blocks.next(l_block_index);
 END LOOP;

 p_detail_attributes     := l_detail_attributes;
 p_new_detail_attributes := l_new_attributes;

 END get_detail_attributes;

   Function same_block
      (p_app_id    IN hxc_time_building_blocks.time_building_block_id%TYPE,
       p_block_id  IN hxc_time_building_blocks.time_building_block_id%TYPE,
       p_block_ovn IN hxc_time_building_blocks.object_version_number%TYPE
       ) return boolean is

      cursor c_block
         (p_app_id   in hxc_time_building_blocks.time_building_block_id%TYPE,
          p_block_id in hxc_time_building_blocks.time_building_block_id%TYPE
          ) is
        select max(time_building_block_ovn)
          from hxc_ap_detail_links
         where application_period_id = p_app_id
           and time_building_block_id = p_block_id;

      cursor c_test_translation_key
         (p_block1_id in hxc_time_building_blocks.time_building_block_id%TYPE,
          p_block1_ovn in hxc_time_building_blocks.object_version_number%TYPE,
          p_block2_ovn in hxc_time_building_blocks.object_version_number%TYPE
          ) is
        select tbb2.object_version_number
          from hxc_time_building_blocks tbb1,
               hxc_time_building_blocks tbb2
         where tbb1.time_building_block_id = p_block1_id
           and tbb1.time_building_block_id =  tbb2.time_building_block_id
           and tbb1.object_version_number = p_block1_ovn
           and tbb2.object_version_number = p_block2_ovn
           and tbb1.type = tbb2.type
           and nvl(tbb1.measure,hr_api.g_number) = nvl(tbb2.measure,hr_api.g_number)
           and nvl(tbb1.unit_of_measure,hr_api.g_varchar2) = nvl(tbb2.unit_of_measure,hr_api.g_varchar2)
           and nvl(tbb1.start_time,hr_api.g_date) = nvl(tbb2.start_time,hr_api.g_date)
           and nvl(tbb1.stop_time,hr_api.g_date) = nvl(tbb2.stop_time,hr_api.g_date)
           and tbb1.approval_status = tbb2.approval_status
           and nvl(tbb1.approval_style_id,hr_api.g_number) = nvl(tbb2.approval_style_id,hr_api.g_number)
           and nvl(tbb1.comment_text,hr_api.g_varchar2) = nvl(tbb2.comment_text,hr_api.g_varchar2)
           and nvl(tbb1.application_set_id,hr_api.g_number) = nvl(tbb1.application_set_id,hr_api.g_number)
           and nvl(tbb1.data_set_id,hr_api.g_number) = nvl(tbb1.data_set_id,hr_api.g_number)
           and nvl(tbb1.translation_display_key,hr_api.g_varchar2) <> nvl(tbb2.translation_display_key,hr_api.g_varchar2);

      l_block_ovn hxc_ap_detail_links.time_building_block_ovn%type;

   Begin
      open c_block(p_app_id, p_block_id);
      fetch c_block into l_block_ovn;

      if (c_block%notfound) then
         close c_block;
         return false;
      elsif (p_block_ovn = l_block_ovn) then
         close c_block;
         return true;
      else
         close c_block;
         --
         -- check to see if it is just the translation display key
         -- that is different
         --
         open c_test_translation_key(p_block_id,p_block_ovn,l_block_ovn);
         fetch c_test_translation_key into l_block_ovn;
         if(c_test_translation_key%found) then
            close c_test_translation_key;
            return true;
         else
            close c_test_translation_key;
            return false;
         end if;
      end if;

   End same_block;

 function no_blocks(
   p_app_id        IN hxc_time_building_blocks.time_building_block_id%TYPE
  ,p_timecard_id    IN hxc_time_building_blocks.time_building_block_id%TYPE
 )

 RETURN NUMBER
 IS
   CURSOR c_no_blocks(
     p_app_id        IN hxc_time_building_blocks.time_building_block_id%TYPE
    ,p_timecard_id   IN hxc_time_building_blocks.time_building_block_id%TYPE
   )
   IS
     SELECT count(p_app_id)
       FROM hxc_ap_detail_links apdetail
            ,hxc_time_building_blocks days
            ,hxc_time_building_blocks details
      WHERE apdetail.application_period_id = p_app_id
        AND days.parent_building_block_id = p_timecard_id
        AND details.parent_building_block_id = days.time_building_block_id
        AND details.time_building_block_id = apdetail.time_building_block_id
        AND details.object_version_number = apdetail.time_building_block_ovn
        AND details.date_to <> hr_general.end_of_time
        and not exists(
                       select 1
                       from hxc_time_building_blocks details2
                       where details2.time_building_block_id = details.time_building_block_id
                       and details2.date_to = hr_general.end_of_time
                       );

   l_count number := 0;

BEGIN
   OPEN c_no_blocks(p_app_id, p_timecard_id);
   FETCH c_no_blocks INTO l_count;
   CLOSE c_no_blocks;

   RETURN l_count;
 END no_blocks;

 FUNCTION changed(
   p_detail_blocks IN OUT NOCOPY block_table
  ,p_attributes    IN hxc_self_service_time_deposit.building_block_attribute_info
  ,p_time_category_id IN hxc_time_categories.time_category_id%TYPE
  ,p_app_id        IN hxc_time_building_blocks.time_building_block_id%TYPE
  ,p_timecard_id   IN hxc_time_building_blocks.time_building_block_id%TYPE
 )
 RETURN BOOLEAN
 IS
   l_block_index NUMBER;
   l_count number := 0;
   l_same  boolean := true;

   l_proc varchar2(50) := 'HXC_APPROVAL_WF_PKG.changed';
 BEGIN
   g_debug:=hr_utility.debug_enabled;
   if g_debug then
	   hr_utility.set_location(l_proc, 10);
   end if;

   IF p_time_category_id IS NULL OR p_time_category_id = 0
   THEN
     l_block_index := p_detail_blocks.first;
     LOOP
       EXIT WHEN NOT p_detail_blocks.exists(l_block_index);
       if g_debug then
	       hr_utility.trace('detail_id=' || p_detail_blocks(l_block_index).block_id);
	       hr_utility.trace('detail_ovn=' || p_detail_blocks(l_block_index).block_ovn);
	       hr_utility.trace('detail_added=' || p_detail_blocks(l_block_index).added);
       end if;

       IF p_detail_blocks(l_block_index).added <> 'Y'
       THEN
          l_count := l_count + 1;
          if g_debug then
		hr_utility.set_location(l_proc, 20);
	  end if;

          IF NOT same_block(p_app_id, p_detail_blocks(l_block_index).block_id
                            , p_detail_blocks(l_block_index).block_ovn)
                 THEN
             if g_debug then
		hr_utility.set_location(l_proc, 30);
             end if;

		g_block_exist_for_ap := 'Y';

             RETURN TRUE;
          END IF;

       END IF;

       l_block_index := p_detail_blocks.next(l_block_index);
    END LOOP;

 ELSE
     if g_debug then
	hr_utility.set_location(l_proc, 40);
     end if;

     hxc_time_category_utils_pkg.initialise_time_category(
       p_time_category_id => p_time_category_id
      ,p_tco_att          => p_attributes
     );

     l_block_index := p_detail_blocks.first;
     LOOP
       EXIT WHEN NOT p_detail_blocks.exists(l_block_index);
       IF hxc_time_category_utils_pkg.chk_tc_bb_ok
            (p_detail_blocks(l_block_index).block_id)THEN
          p_detail_blocks(l_block_index).added := 'Y';
          l_count := l_count + 1;

          IF NOT same_block(p_app_id, p_detail_blocks(l_block_index).block_id
                            , p_detail_blocks(l_block_index).block_ovn)
	 THEN
	   if g_debug then
		hr_utility.set_location(l_proc, 60);
	   end if;

	   g_block_exist_for_ap := 'Y';

	   RETURN TRUE;
	 END IF;

       END IF;

       l_block_index := p_detail_blocks.next(l_block_index);
     END LOOP;
   END IF;

   IF no_blocks(p_app_id, p_timecard_id) = 0
   THEN
     if g_debug then
	hr_utility.trace('number not changed');
     end if;
     RETURN FALSE;
   ELSE
     if g_debug then
	hr_utility.trace('number changed');
     end if;
     RETURN TRUE;
   END IF;
 END changed;

 PROCEDURE remove_ap_detail_links(
   p_app_id             IN hxc_time_building_blocks.time_building_block_id%TYPE
  ,p_timecard_id        IN hxc_time_building_blocks.time_building_block_id%TYPE
 )
 IS
   CURSOR c_detail_blocks(
     p_timecard_id        IN hxc_time_building_blocks.time_building_block_id%TYPE
   )
   IS
     SELECT details.time_building_block_id
	   ,details.object_version_number
       FROM hxc_time_building_blocks days
	   ,hxc_time_building_blocks details
      WHERE days.parent_building_block_id = p_timecard_id
	AND details.parent_building_block_id = days.time_building_block_id
	AND days.scope = 'DAY'
	AND details.scope = 'DETAIL';

   CURSOR c_old_blocks(
     p_app_period  hxc_time_building_blocks.time_building_block_id%TYPE
   )
   IS
     SELECT details.time_building_block_id
	   ,details.object_version_number
       FROM hxc_ap_detail_links apdetail
	   ,hxc_time_building_blocks details
      WHERE apdetail.application_period_id = p_app_period
	AND apdetail.time_building_block_id = details.time_building_block_id
	AND apdetail.time_building_block_ovn = details.object_version_number
	AND details.date_to <> hr_general.end_of_time;


   l_detail_id hxc_time_building_blocks.time_building_block_id%TYPE;
   l_detail_ovn hxc_time_building_blocks.object_version_number%TYPE;
 BEGIN
   OPEN c_detail_blocks(p_timecard_id);

   LOOP
     FETCH c_detail_blocks INTO l_detail_id, l_detail_ovn;
     EXIT WHEN c_detail_blocks%NOTFOUND;

     delete from hxc_ap_detail_links
      where time_building_block_id = l_detail_id
	and time_building_block_ovn = l_detail_ovn
	and application_period_id = p_app_id;

   END LOOP;

   CLOSE c_detail_blocks;

   OPEN c_old_blocks(p_app_id);
   LOOP
     FETCH c_old_blocks INTO l_detail_id, l_detail_ovn;
     EXIT WHEN c_old_blocks%NOTFOUND;

      delete from hxc_ap_detail_links
      where time_building_block_id = l_detail_id
	and time_building_block_ovn = l_detail_ovn
	and application_period_id = p_app_id;
   END LOOP;

   CLOSE c_old_blocks;

 END remove_ap_detail_links;


 FUNCTION is_empty(
   p_detail_blocks IN OUT NOCOPY block_table
  ,p_attributes    IN hxc_self_service_time_deposit.building_block_attribute_info
  ,p_time_category_id IN hxc_time_categories.time_category_id%TYPE
 )
 RETURN BOOLEAN
 IS
   l_block_index NUMBER;
 BEGIN

   --
   -- Check the attributes are ok

   hxc_time_category_utils_pkg.initialise_time_category(
     p_time_category_id => p_time_category_id
    ,p_tco_att          => p_attributes
   );

   l_block_index := p_detail_blocks.first;
   LOOP
     EXIT WHEN NOT p_detail_blocks.exists(l_block_index);

     if g_debug then
	     hr_utility.trace('detail_id=' || p_detail_blocks(l_block_index).block_id);
	     hr_utility.trace('detail_ovn=' || p_detail_blocks(l_block_index).block_ovn);
	     hr_utility.trace('detail_added=' || p_detail_blocks(l_block_index).added);
     end if;

     IF hxc_time_category_utils_pkg.chk_tc_bb_ok(
	 p_detail_blocks(l_block_index).block_id
       )
     THEN
       RETURN FALSE;
     END IF;

     l_block_index := p_detail_blocks.next(l_block_index);
   END LOOP;

   RETURN TRUE;
 END is_empty;



 PROCEDURE link_ap_details(
   p_detail_blocks IN OUT NOCOPY block_table
  ,p_attributes    IN hxc_self_service_time_deposit.building_block_attribute_info
  ,p_time_category_id IN hxc_time_categories.time_category_id%TYPE
  ,p_app_id        IN hxc_time_building_blocks.time_building_block_id%TYPE
 )
 IS
   l_block_index NUMBER;
 BEGIN

   hxc_time_category_utils_pkg.initialise_time_category(
     p_time_category_id => p_time_category_id
    ,p_tco_att          => p_attributes
   );

   l_block_index := p_detail_blocks.first;
   LOOP
     EXIT WHEN NOT p_detail_blocks.exists(l_block_index);

     if g_debug then
	     hr_utility.trace('detail_id=' || p_detail_blocks(l_block_index).block_id);
	     hr_utility.trace('detail_ovn=' || p_detail_blocks(l_block_index).block_ovn);
	     hr_utility.trace('detail_added=' || p_detail_blocks(l_block_index).added);
     end if;

     IF hxc_time_category_utils_pkg.chk_tc_bb_ok(
	 p_detail_blocks(l_block_index).block_id
       )
     THEN
       --set added flag
       --we use this flag to find all the category 0 blocks
       p_detail_blocks(l_block_index).added := 'Y';

       --insert a line in hxc_detail_summary;
       hxc_ap_detail_links_pkg.insert_summary_row(
	 p_app_id
	,p_detail_blocks(l_block_index).block_id
	,p_detail_blocks(l_block_index).block_ovn
       );

      if g_debug then
	hr_utility.trace('linked!');
      end if;

     END IF;

     l_block_index := p_detail_blocks.next(l_block_index);
   END LOOP;

 END link_ap_details;

 PROCEDURE link_ap_details_all(
   p_detail_blocks IN OUT NOCOPY block_table
  ,p_app_id        IN hxc_time_building_blocks.time_building_block_id%TYPE
  ,p_time_category_id IN hxc_time_categories.time_category_id%TYPE
 )
 IS
   l_block_index NUMBER;

 BEGIN

   if g_debug then
	hr_utility.trace('in link_ap_details_all');
   end if;

   l_block_index := p_detail_blocks.first;
   LOOP
     EXIT WHEN NOT p_detail_blocks.exists(l_block_index);

     if g_debug then
	     hr_utility.trace('block_id=' || p_detail_blocks(l_block_index).block_id);
	     hr_utility.trace('block_ovn=' || p_detail_blocks(l_block_index).block_ovn);
	     hr_utility.trace('added=' || p_detail_blocks(l_block_index).added);
     end if;
     l_block_index := p_detail_blocks.next(l_block_index);
   END LOOP;

   l_block_index := p_detail_blocks.first;

   LOOP
     EXIT WHEN NOT p_detail_blocks.exists(l_block_index);

     IF p_time_category_id IS NULL
       OR (p_time_category_id = 0 and p_detail_blocks(l_block_index).added <> 'Y')
     THEN
       --set added flag
       --we use this flag to find all the category 0 blocks
       if g_debug then
		hr_utility.trace('inserting id=' || p_detail_blocks(l_block_index).block_id
		       || '|ovn=' || p_detail_blocks(l_block_index).block_ovn);
       end if;

       p_detail_blocks(l_block_index).added := 'Y';


       --insert a line in hxc_detail_summary;
       hxc_ap_detail_links_pkg.insert_summary_row(
	 p_app_id
	,p_detail_blocks(l_block_index).block_id
	,p_detail_blocks(l_block_index).block_ovn
       );


     END IF;

     l_block_index := p_detail_blocks.next(l_block_index);

   END LOOP;

   if g_debug then
	hr_utility.trace('end link_ap_details_all');
   end if;
 END link_ap_details_all;

 FUNCTION get_person_id(
   p_user_name IN fnd_user.user_name%TYPE
 )
 RETURN fnd_user.employee_id%TYPE
 IS
   CURSOR c_person_id(p_user_name fnd_user.user_name%TYPE)
       IS
   SELECT u.employee_id
     FROM FND_USER u
    WHERE u.user_name = p_user_name;

   l_person_id fnd_user.employee_id%TYPE;
 BEGIN
   OPEN c_person_id(p_user_name);

   FETCH c_person_id INTO l_person_id;
   IF c_person_id%NOTFOUND
   THEN
     CLOSE c_person_id;

     --raise; ???
   END IF;

   CLOSE c_person_id;

   RETURN l_person_id;
 END get_person_id;


 FUNCTION get_empty_attribute
 RETURN hxc_time_attributes_api.timecard
 IS
   t_attributes hxc_time_attributes_api.timecard;

 BEGIN
   t_attributes.delete;
   t_attributes(1).attribute_name   := NULL;
   t_attributes(1).attribute_value  := NULL;
   t_attributes(1).information_type := NULL;
   t_attributes(1).column_name      := NULL;
   t_attributes(1).info_mapping_type := NULL;

   RETURN t_attributes;

 END get_empty_attribute;
 Function find_mysterious_approver
	   (p_item_type in wf_items.item_type%type
	   ,p_item_key  in wf_item_activity_statuses.item_key%type
	   ) return number is

 cursor c_find_approver_role
	 (itemType in wf_items.item_type%type
	 ,itemKey in wf_item_activity_statuses.item_key%type) is
   select wlr.orig_system, wlr.orig_system_id
   from wf_notifications wn, wf_process_activities pa, wf_item_activity_statuses wias, wf_local_roles wlr
  where pa.activity_name in('TC_APR_NOTIFICATION', 'TC_APR_NOTIFICATION_ABS')
    and pa.activity_item_type = itemType
    and pa.instance_id = wias.process_activity
    and wias.notification_id = wn.notification_id
    and wias.item_key = itemKey
    and wlr.name = wn.recipient_role
    and wias.item_type = pa.activity_item_type;

 cursor c_find_employee_id
	 (userId in fnd_user.user_id%type) is
   select employee_id
     from fnd_user
    where user_id = userId;

 l_approver_id wf_local_roles.orig_system_id%type;
 l_approver_system wf_local_roles.orig_system%type;


 Begin

 open c_find_approver_role(p_item_type,p_item_key);
 fetch c_find_approver_role into l_approver_system, l_approver_id;
 if(c_find_approver_role%notfound) then
   close c_find_approver_role;
   l_approver_id := -1;
 else
   close c_find_approver_role;
   if((l_approver_system <> 'PER') AND (l_approver_system <> 'FND_USR')) then
     l_approver_id := -1;
   elsif(l_approver_system = 'FND_USR') then
     open c_find_employee_id(l_approver_id);
     fetch c_find_employee_id into l_approver_id;
     if (c_find_employee_id%notfound) then
       close c_find_employee_id;
       l_approver_id := -1;
     else
       close c_find_employee_id;
     end if;
    end if; -- other option is PER, and then it's already set properly
 end if;

 return l_approver_id;

 End find_mysterious_approver;

 PROCEDURE update_latest_details(p_app_bb_id in number)
  is

  l_bb_id number;
  l_bb_ovn number;
  l_other_app_id number;

  cursor get_building_blocks(p_app_bb_id in number)
  is
  select time_building_block_id, time_building_block_ovn
   from hxc_ap_detail_links
  where application_period_id = p_app_bb_id;

  cursor get_app_period(p_bb_id in number, p_bb_ovn in number ,p_app_bb_id in number)
  is
        select adl.application_period_id
   	 from hxc_ap_detail_links adl,
   	 hxc_app_period_summary haps
   	 where adl.time_building_block_id = p_bb_id
   	 and adl.time_building_block_ovn = p_bb_ovn
   	 and adl.application_period_id <> p_app_bb_id
   	 and adl.application_period_id = haps.application_period_id
 	 and haps.approval_status <> 'APPROVED';
  begin

  open get_building_blocks(p_app_bb_id);
  fetch get_building_blocks into l_bb_id,l_bb_ovn;

  LOOP
 	 exit when get_building_blocks%notfound;

 	 open get_app_period(l_bb_id, l_bb_ovn, p_app_bb_id);
 	 fetch get_app_period into l_other_app_id;

 	 IF get_app_period%notfound then
		 update hxc_latest_details
		 set last_update_date = sysdate
		 where time_building_block_id = l_bb_id
		 and object_version_number = l_bb_ovn;
	 END IF;
	 close get_app_period;

 	 fetch get_building_blocks into l_bb_id, l_bb_ovn;

  END LOOP;

  close get_building_blocks;

 END update_latest_details;

 PROCEDURE update_app_period(
   itemtype     IN varchar2,
   itemkey      IN varchar2,
   actid        IN number,
   funcmode     IN varchar2,
   result       IN OUT NOCOPY varchar2
 )
 IS
   t_attributes         hxc_time_attributes_api.timecard;
   l_attribute          approval_attribute;
   l_approver           varchar2(150);
   l_user_name          varchar2(150);
   l_appl_period_bb_id  number;
   l_appl_period_bb_ovn number;
   l_tc_resource_id     number;
   l_period_start_date  date;
   l_period_end_date    date;
   l_approval_status    hxc_time_building_blocks.approval_status%type;
   l_approver_comment   hxc_time_building_blocks.comment_text%TYPE;
   l_creation_date      hxc_time_building_blocks.creation_date%TYPE;
   l_wf_item_type       varchar2(500) := NULL;
   l_is_blank 		varchar2(10);
   l_proc               varchar2(100) := 'HXC_APPROVAL_WF_PKG.update_appl_period';


 BEGIN
   g_debug:=hr_utility.debug_enabled;
   if g_debug then
	hr_utility.set_location(l_proc, 10);
   end if;

   l_tc_resource_id := wf_engine.GetItemAttrNumber(
					 itemtype => itemtype,
					 itemkey  => itemkey  ,
					 aname    => 'RESOURCE_ID');


   if g_debug then
	hr_utility.set_location(l_proc, 30);
   end if;

   l_period_start_date := wf_engine.GetItemAttrDate(
					 itemtype => itemtype,
					 itemkey  => itemkey  ,
					 aname    => 'APP_START_DATE');

   if g_debug then
	hr_utility.set_location(l_proc, 40);
   end if;

   l_period_end_date := wf_engine.GetItemAttrDate(
					 itemtype => itemtype,
					 itemkey  => itemkey  ,
					 aname    => 'APP_END_DATE');

   if g_debug then
	hr_utility.set_location(l_proc, 50);
   end if;

   l_appl_period_bb_id := wf_engine.GetItemAttrNumber(
					 itemtype  => itemtype,
					 itemkey   => itemkey,
					 aname     => 'APP_BB_ID');

   if g_debug then
	hr_utility.set_location(l_proc, 60);
   end if;

   l_appl_period_bb_ovn := wf_engine.GetItemAttrNumber(
					 itemtype  => itemtype,
					 itemkey   => itemkey,
					 aname     => 'APP_BB_OVN');

   if g_debug then
	hr_utility.set_location(l_proc, 70);
   end if;

   -- Set up the approval status - get the value for the APPROVAL_STATUS
   -- attribute, which is set up in the activity previous to this one.
   --
   l_approval_status := wf_engine.GetItemAttrText(
				    itemtype => itemtype,
				    itemkey  => itemkey  ,
				    aname    => 'APPROVAL_STATUS');

   l_approver_comment := wf_engine.GetItemAttrText(
				     itemtype => itemtype,
				     itemkey  => itemkey,
				     aname    => 'APR_REJ_REASON');

   if g_debug then
	   hr_utility.set_location(l_proc, 80);

	   hr_utility.trace('l_approval_status is : ' || l_approval_status);
   end if;

   --get approver id
   --what happens to l_approver if AUTO_APPROVE??

   l_wf_item_type := wf_engine.GetItemAttrText(
		       itemtype => itemtype
		      ,itemkey  => itemkey
		      ,aname    => 'WF_ITEM_TYPE'
		     );

   IF l_wf_item_type IS NOT NULL
   THEN
     --current workflow doesn't populate this fied for custom
     --workflow either
     l_approver := NULL;
   ELSE
     IF l_approver_comment = 'AUTO_APPROVE'
       OR l_approver_comment = 'TIMED_OUT'
     THEN
       l_approver := NULL;
     ELSE
       --
       -- 115.90 Change.  Since this could be an e-mail notification
       -- response, our first check is to use the find approver
       -- function, since the employee id could be anyone in the case
       -- of e-mail.  The notification information definitely will
       -- provide the right approver.
       --
       l_approver := find_mysterious_approver
		       (itemtype, itemkey);
     END IF;
   END IF;
 /*

    Bug: 3205338: If the approver id is -1,
    i.e. fnd_global.employee_id is

 */

hr_utility.trace('OTL:pass 100 - '||itemkey);

-- Added for bug 9076079
IF g_old_item_key.exists(itemkey) then
       hr_utility.trace('OTL: Exists in g table');
       l_is_blank := g_old_item_key(itemkey).is_diff_tc;
ELSE
       hr_utility.trace('OTL: Not exists in g table');
       l_is_blank := wf_engine.GetItemAttrText(itemtype => itemtype,
                                               itemkey  => itemkey  ,
                                               aname    => 'IS_DIFF_TC',
                                               ignore_notfound => true);
END IF;

hr_utility.trace('OTL:pass 110');

if l_is_blank = 'Y' then
	l_approver_comment := l_approver_comment ||'BLANK_NOTIFICATION';
end if;

   t_attributes := get_empty_attribute;

   hxc_deposit_process_pkg.execute_deposit_process(
     p_process_name              => g_process_name
    ,p_source_name               => g_source_name
    ,p_effective_date            => trunc(sysdate)
    ,p_type                      => 'RANGE'
    ,p_measure                   => null
    ,p_unit_of_measure           => null
    ,p_start_time                => l_period_start_date
    ,p_stop_time                 => l_period_end_date
    ,p_parent_building_block_id  => null
    ,p_parent_building_block_ovn => null
    ,p_scope                     => 'APPLICATION_PERIOD'
    ,p_approval_style_id         => NULL
    ,p_approval_status           => l_approval_status
    ,p_resource_id               => l_tc_resource_id
    ,p_resource_type             => g_resource_type
    ,p_comment_text              => l_approver_comment
    ,p_timecard                  => t_attributes
    ,p_time_building_block_id    => l_appl_period_bb_id
    ,p_object_version_number     => l_appl_period_bb_ovn
   );


 if(l_approver = -1) then
   l_approver := find_mysterious_approver(itemtype,itemkey);
 end if;

   if g_debug then
	hr_utility.set_location(l_proc, 90);
   end if;

   --update hxc_application_period_summary table
   l_creation_date :=  get_creation_date(l_appl_period_bb_id, l_appl_period_bb_ovn);
   update hxc_app_period_summary
      set application_period_ovn = l_appl_period_bb_ovn
	 ,approval_status = l_approval_status
	 ,approver_id = l_approver
	 ,notification_status = 'FINISHED'
	 ,creation_date = l_creation_date
    where application_period_id = l_appl_period_bb_id;

   hxc_timecard_summary_api.reevaluate_timecard_statuses
     (p_application_period_id => l_appl_period_bb_id);

   update_latest_details(l_appl_period_bb_id);

   -- Set up the result as APPROVED or REJECTED, so that the process_appl_periods
   -- is only done again if this row has been APPROVED.
   --
   IF upper(l_approval_status) = 'APPROVED' THEN
     result := 'COMPLETE:APPROVED';
   ELSIF upper(l_approval_status) = 'REJECTED' THEN
     result := 'COMPLETE:REJECTED';
   END IF;


   if g_debug then
	hr_utility.set_location(l_proc, 110);
   end if;

 /*
    Since this could be the last operation in the approvals process
    as at the end of the workflow, there will be no more approval
    components to process and hence process_appl_periods (the next
    activity in the sequence), won't actually do anything, we issue
    a commit at this point, to commit the outstanding approval data
    from this transaction

    This is bug 3449786
 */

   commit;

   return;

 exception
   when others then
     -- The line below records this function call in the error system
     -- in the case of an exception.
     --
     if g_debug then
	     hr_utility.trace(sqlerrm);
	     hr_utility.trace('lllllllllllllllllll');
	     hr_utility.trace(hr_message.last_message_name);
	     hr_utility.trace('----');
     end if;
     IF sqlerrm like '%HXC_TIME_BLD_BLK_NOT_LATEST%' THEN
	RETURN;
     END IF;
     --
     if g_debug then
	hr_utility.set_location(l_proc, 999);
	hr_utility.trace('IN EXCEPTION IN update_appl_period');
     end if;
     --
     wf_core.context('HCAPPRWF', 'hxc_approval_wf_pkg.update_appl_period',
		     itemtype, itemkey, to_char(actid), funcmode);
     raise;
   result := '';
   return;
 --
 --
 END update_app_period;


 --this procedure basically creates a duplicate of the current application period
 --we need this for HR Supervisor mechanism
 PROCEDURE create_next_period(
   itemtype     IN varchar2,
   itemkey      IN varchar2,
   actid        IN number,
   funcmode     IN varchar2,
   result       IN OUT NOCOPY varchar2
 )
 IS
   CURSOR c_current_period(
     p_app_id hxc_time_building_blocks.time_building_block_id%TYPE
   )
   IS
   SELECT *
     FROM hxc_app_period_summary
    WHERE application_period_id = p_app_id;

   CURSOR c_timecards(
     p_app_id hxc_time_building_blocks.time_building_block_id%TYPE
   )
   IS
   SELECT timecard_id
     FROM hxc_tc_ap_links
    WHERE application_period_id = p_app_id;

   CURSOR c_ap_details(
     p_app_id hxc_time_building_blocks.time_building_block_id%TYPE
   )
   IS
   SELECT time_building_block_id
	 ,time_building_block_ovn
     FROM hxc_ap_detail_links
    WHERE application_period_id = p_app_id;


   l_current_period     hxc_app_period_summary%rowtype;
   l_timecard_id        hxc_time_building_blocks.time_building_block_id%TYPE;
   l_detail_id          hxc_time_building_blocks.time_building_block_id%TYPE;
   l_detail_ovn         hxc_time_building_blocks.object_version_number%TYPE;
   l_new_appl_bb_id     hxc_time_building_blocks.time_building_block_id%TYPE := NULL;
   l_new_appl_bb_ovn    hxc_time_building_blocks.object_version_number%TYPE := NULL;
   l_period_start_date  hxc_time_building_blocks.start_time%TYPE;
   l_period_end_date    hxc_time_building_blocks.stop_time%TYPE;
   l_tc_resource_id     hxc_time_building_blocks.resource_id%TYPE;
   l_attribute          approval_attribute;
   t_attributes         hxc_time_attributes_api.timecard;
   l_period_id          hxc_time_building_blocks.time_building_block_id%TYPE;
   l_creation_date      hxc_time_building_blocks.creation_date%TYPE;

   l_proc VARCHAR2(150) := 'create_next_period';
 BEGIN
   g_debug:=hr_utility.debug_enabled;
   if g_debug then
	hr_utility.trace('in create_next_period');
   end if;

   IF funcmode = 'RUN'
   THEN
     l_period_id := wf_engine.GetItemAttrNumber(
					 itemtype => itemtype,
					 itemkey  => itemkey  ,
					 aname    => 'APP_BB_ID');

     l_period_start_date := wf_engine.GetItemAttrDate(
					 itemtype => itemtype,
					 itemkey  => itemkey  ,
					 aname    => 'APP_START_DATE');

     l_period_end_date := wf_engine.GetItemAttrDate(
					 itemtype => itemtype,
					 itemkey  => itemkey  ,
					 aname    => 'APP_END_DATE');

     l_tc_resource_id := wf_engine.GetItemAttrNumber(
					 itemtype => itemtype,
					 itemkey  => itemkey  ,
					 aname    => 'RESOURCE_ID');

     t_attributes := get_empty_attribute;

     hxc_deposit_process_pkg.execute_deposit_process
	  (p_process_name              => g_process_name
	  ,p_source_name               => g_source_name
	  ,p_effective_date            => trunc(sysdate)
	  ,p_type                      => 'RANGE'
	  ,p_measure                   => null
	  ,p_unit_of_measure           => null
	  ,p_start_time                => trunc(l_period_start_date)
	  ,p_stop_time                 => trunc(l_period_end_date)
	  ,p_parent_building_block_id  => null
	  ,p_parent_building_block_ovn => null
	  ,p_scope                     => 'APPLICATION_PERIOD'
	  ,p_approval_style_id         => NULL
	  ,p_approval_status           => 'SUBMITTED'
	  ,p_resource_id               => l_tc_resource_id
	  ,p_resource_type             => g_resource_type
	  ,p_comment_text              => null
	  ,p_timecard                  => t_attributes
	  ,p_time_building_block_id    => l_new_appl_bb_id
	  ,p_object_version_number     => l_new_appl_bb_ovn);

     if g_debug then
	     hr_utility.trace('next period created=' || l_new_appl_bb_id);
	     hr_utility.trace('next period created=' || l_new_appl_bb_ovn);
     end if;

     --populating summary tables
     l_creation_date := get_creation_date(l_new_appl_bb_id, l_new_appl_bb_ovn);

     OPEN c_current_period(
       p_app_id => l_period_id
     );

     FETCH c_current_period INTO l_current_period;
     IF c_current_period%NOTFOUND
     THEN
       CLOSE c_current_period;

       hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE', l_proc);
       hr_utility.set_message_token('STEP', '20');
       hr_utility.raise_error;
     END IF;

     CLOSE c_current_period;

     g_trace := l_proc || '80';
 /*
     --populate hxc_app_period_summary with the new row
     INSERT INTO hxc_app_period_summary
       (APPLICATION_PERIOD_ID
       ,APPLICATION_PERIOD_OVN
       ,APPROVAL_STATUS
       ,TIME_RECIPIENT_ID
       ,TIME_CATEGORY_ID
       ,START_TIME
       ,STOP_TIME
       ,RESOURCE_ID
       ,RECIPIENT_SEQUENCE
       ,CATEGORY_SEQUENCE
       ,CREATION_DATE
       ,NOTIFICATION_STATUS
       ,APPROVER_ID
       ,APPROVAL_COMP_ID
      )
     VALUES
 */
     hxc_app_period_summary_pkg.insert_summary_row
       (l_new_appl_bb_id
       ,l_new_appl_bb_ovn
       ,'SUBMITTED'
       ,l_current_period.time_recipient_id
       ,l_current_period.time_category_id
       ,l_current_period.start_time
       ,l_current_period.stop_time
       ,l_current_period.resource_id
       ,l_current_period.recipient_sequence
       ,l_current_period.category_sequence
       ,l_creation_date
       ,'NOTIFIED'
       ,NULL
       ,l_current_period.approval_comp_id
       ,NULL
       ,NULL
       ,Null
       ,l_current_period.data_set_id
       );

     --populate hxc_tc_ap_links
     OPEN c_timecards(
       p_app_id => l_period_id
     );

     LOOP
       FETCH c_timecards into l_timecard_id;

       EXIT WHEN c_timecards%NOTFOUND;
 -- 115.76 Not changed this one, since this procedure
 -- no longer seems to be called.
       hxc_tc_ap_links_pkg.insert_summary_row(
	 l_timecard_id
	,l_new_appl_bb_id);

       --Bug 5554020.
       hxc_timecard_summary_api.reevaluate_timecard_statuses(l_new_appl_bb_id);

     END LOOP;

     CLOSE c_timecards;

     --populating hxc_ap_detail_links
     OPEN c_ap_details(
       p_app_id => l_period_id
     );

     LOOP
       FETCH c_ap_details INTO l_detail_id, l_detail_ovn;

       EXIT WHEN c_ap_details%NOTFOUND;
 /*
       INSERT INTO hxc_ap_detail_links
	     (application_period_id,
	      time_building_block_id,
	      time_building_block_ovn)
       VALUES
 */

       hxc_ap_detail_links_pkg.insert_summary_row
	     (l_new_appl_bb_id,
	      l_detail_id,
	      l_detail_ovn);
     END LOOP;

     CLOSE c_ap_details;

     --now set workflow attribute to the new application period
     wf_engine.SetItemAttrNumber(itemtype  => itemtype,
				itemkey   => itemkey,
				aname     => 'NEXT_APP_BB_ID',
				avalue    => l_new_appl_bb_id);

     wf_engine.SetItemAttrNumber(itemtype  => itemtype,
			       itemkey   => itemkey,
			       aname     => 'NEXT_APP_BB_OVN',
			       avalue    => l_new_appl_bb_ovn);

     result := 'COMPLETE';
     return;
   END IF;

 exception
   when others then
      -- The line below records this function call in the error system
      -- in the case of an exception.
      --
      if g_debug then
	hr_utility.set_location(l_proc, 999);
      --
	hr_utility.trace('IN EXCEPTION IN create_next_period');
      --
      end if;
      wf_core.context('HCAPPRWF', 'hxc_approval_wf_pkg.create_next_period',
		      itemtype, itemkey, to_char(actid), funcmode);
      raise;
      result := '';
      return;

 END create_next_period;


 ------------------------- get_approval_period_id --------------------------
 --
 FUNCTION get_approval_period_id(
   p_resource_id in HXC_TIME_BUILDING_BLOCKS.RESOURCE_ID%TYPE
  ,p_time_recipient_id in HXC_TIME_RECIPIENTS.TIME_RECIPIENT_ID%TYPE
  ,p_day_start_time in HXC_TIME_BUILDING_BLOCKS.START_TIME%TYPE
  ,p_timecard_start_time in HXC_TIME_BUILDING_BLOCKS.START_TIME%TYPE
  ,p_timecard_stop_time in HXC_TIME_BUILDING_BLOCKS.STOP_TIME%TYPE
 )
 RETURN HXC_RECURRING_PERIODS.RECURRING_PERIOD_ID%TYPE
 IS

   cursor csr_get_app_rec_period(
     p_time_recipient_id number,
     p_app_periods number)
   is
    select hapc.recurring_period_id
      from hxc_approval_period_comps hapc,
	   hxc_approval_period_sets haps
     where haps.approval_period_set_id = p_app_periods
       and hapc.approval_period_set_id = haps.approval_period_set_id
       and hapc.time_recipient_id = p_time_recipient_id;

   l_app_periods HXC_PREF_HIERARCHIES.ATTRIBUTE1%TYPE;
   l_recurring_period_id HXC_RECURRING_PERIODS.RECURRING_PERIOD_ID%TYPE;
   l_day_number NUMBER;
   l_day_count NUMBER;
   l_pref_found BOOLEAN;
   l_day_check DATE;

 BEGIN

   -- Attempt to find the approval period preference value

   BEGIN

     l_app_periods := hxc_preference_evaluation.resource_preferences(
		     p_resource_id  => p_resource_id,
		     p_pref_code    => 'TS_PER_APPROVAL_PERIODS',
		     p_attribute_n  => 1,
		     p_evaluation_date => trunc(p_day_start_time));

 EXCEPTION
   when others then
   --
   -- Ok, now we loop over all the days in the timecard period
   -- looking for an application period preference
   --
   l_day_number := trunc(p_timecard_stop_time) - trunc(p_timecard_start_time);
   l_day_count := 0;
   l_pref_found := false;

   LOOP
     EXIT WHEN l_day_count > l_day_number;
     EXIT WHEN l_pref_found;
     l_day_check := trunc(p_timecard_start_time) + l_day_count;
     BEGIN

       l_app_periods := hxc_preference_evaluation.resource_preferences(
			  p_resource_id  => p_resource_id,
			  p_pref_code    => 'TS_PER_APPROVAL_PERIODS',
			  p_attribute_n  => 1,
			  p_evaluation_date => l_day_check);

       l_pref_found := true;

     EXCEPTION
       When others then
	 null;
     END;

     l_day_count := l_day_count +1;

   END LOOP;

   if (NOT l_pref_found) then

    g_error_count := g_error_count + 1;
    g_error_table(g_error_count).MESSAGE_NAME := 'HXC_NO_APRL_PERIOD_PREF';
    g_error_table(g_error_count).APPLICATION_SHORT_NAME := 'HXC';
    --
     FND_MESSAGE.SET_NAME('HXC','HXC_NO_APRL_PERIOD_PREF');
     FND_MESSAGE.SET_TOKEN('DATE',FND_DATE.DATE_TO_CANONICAL(p_day_start_time));
     FND_MESSAGE.SET_TOKEN('RESOURCE_ID',p_resource_id);
     FND_MESSAGE.RAISE_ERROR;

   end if;

 END;

 --
 -- Use the application period id to get the recurring period id
 --

 open csr_get_app_rec_period(p_time_recipient_id,to_number(l_app_periods));
 fetch csr_get_app_rec_period into l_recurring_period_id;

 if csr_get_app_rec_period%NOTFOUND then
    close csr_get_app_rec_period;
    g_error_count := g_error_count + 1;
    g_error_table(g_error_count).MESSAGE_NAME := 'HXC_APR_NO_REC_PERIOD';
    g_error_table(g_error_count).APPLICATION_SHORT_NAME := 'HXC';
    --
    FND_MESSAGE.SET_NAME('HXC','HXC_APR_NO_REC_PERIOD');
    FND_MESSAGE.SET_TOKEN('TIME_RECIPIENT',p_time_recipient_id);
    FND_MESSAGE.SET_TOKEN('APP_PERIOD_PREF',l_app_periods);
    FND_MESSAGE.RAISE_ERROR;
 else
    close csr_get_app_rec_period;
 end if;

 return l_recurring_period_id;

 END get_approval_period_id;


 PROCEDURE get_application_period(
   p_app_period_func    IN VARCHAR2
  ,p_resource_id        IN hxc_time_building_blocks.resource_id%TYPE
  ,p_day                IN hxc_time_building_blocks.start_time%TYPE
  ,p_time_recipient     IN hxc_time_recipients.time_recipient_id%TYPE
  ,p_tc_start_time      IN hxc_time_building_blocks.start_time%TYPE
  ,p_tc_stop_time       IN hxc_time_building_blocks.stop_time%TYPE
  ,p_assignment_periods IN hxc_timecard_utilities.periods
  ,p_period_start      OUT NOCOPY hxc_time_building_blocks.start_time%TYPE
  ,p_period_end        OUT NOCOPY hxc_time_building_blocks.stop_time%TYPE
 )
 IS
   l_period_start_date  date;
   l_period_end_date    date;
   l_override_allowed   boolean;
   l_app_period         hxc_timecard_utilities.time_period;
   l_valid_periods      hxc_timecard_utilities.periods;


   l_call_proc          varchar2(2000);
   l_cursor             number;
   l_ret                number;

   l_rec_period_id     number;
   l_rec_start_date    date;
   l_rec_period_type   varchar2(80);
   l_duration_in_days  number(10);

   l_proc              varchar2(50) := 'get_application_period';

   cursor csr_get_rec_period_info(p_recurring_period_id number) is
    select hrp.start_date,
	   hrp.period_type,
	   hrp.duration_in_days
      from hxc_recurring_periods hrp
     where hrp.recurring_period_id = p_recurring_period_id;

 BEGIN

   IF p_app_period_func IS NOT NULL
   THEN
     if g_debug then
	hr_utility.set_location(l_proc, 95);
     end if;

     l_call_proc := p_app_period_func ||
		      '(p_building_block_date => ' || p_day ||
		      ',p_resource_id       => ' || p_resource_id ||
		      ',p_period_start_date => l_period_start_date' ||
		      ',p_period_end_date   => l_period_end_date' ||
		      ',p_override_allowed  => l_override_allowed)';

     if g_debug then
	     hr_utility.trace('Period Start Date (from function) is : ' ||
				    to_char(l_period_start_date, 'DD-MM-YYYY'));
	     hr_utility.trace('Period End Date (from function) is : ' ||
				    to_char(l_period_end_date, 'DD-MM-YYYY'));
     end if;

     l_cursor := dbms_sql.open_cursor;
     dbms_sql.parse(l_cursor, l_call_proc, DBMS_SQL.V7);
     l_ret := dbms_sql.execute(l_cursor);
     dbms_sql.close_cursor(l_cursor);

     if g_debug then
	hr_utility.set_location(l_proc, 110);
     end if;
   ELSE

     l_override_allowed := TRUE;

   END IF;

   -- If override allowed then, get application period start and
   -- end dates.

   IF l_override_allowed
   THEN

     if g_debug then
	hr_utility.set_location(l_proc, 120);
     end if;

     l_rec_period_id := get_approval_period_id(
			  p_resource_id
			 ,p_time_recipient
			 ,p_day
			 ,p_tc_start_time
			 ,p_tc_stop_time
			);

     if g_debug then
	hr_utility.trace('Recurring Period ID is : ' || to_char(l_rec_period_id));
     end if;

     open csr_get_rec_period_info(l_rec_period_id);
     fetch csr_get_rec_period_info into l_rec_start_date,
				    l_rec_period_type,
				    l_duration_in_days;
     close csr_get_rec_period_info;

     hxc_timecard_utilities.find_current_period(
       p_rec_period_start_date  => l_rec_start_date
      ,p_period_type            => l_rec_period_type
      ,p_duration_in_days       => l_duration_in_days
      ,p_current_date           => p_day
      ,p_period_start           => l_period_start_date
      ,p_period_end             => l_period_end_date
     );

     if g_debug then
	     hr_utility.trace('Appl Period Start Date is : ' ||
				    to_char(l_period_start_date, 'DD-MM-YYYY'));
	     hr_utility.trace('Appl Period End Date is : ' ||
				    to_char(l_period_end_date, 'DD-MM-YYYY'));
     end if;

   END IF;

   p_period_start := l_period_start_date;
   p_period_end   := l_period_end_date;

 -- JOEL
   --processing assignment to remove days without an active assignment
   l_app_period.start_date := l_period_start_date;
   l_app_period.end_date   := l_period_end_date;

   l_valid_periods.delete;

   hxc_timecard_utilities.process_assignments(
     p_period             => l_app_period
    ,p_assignment_periods => p_assignment_periods
    ,p_return_periods     => l_valid_periods
   );

   FOR i IN l_valid_periods.first .. l_valid_periods.last
   LOOP
     IF p_day BETWEEN l_valid_periods(i).start_date
       AND l_valid_periods(i).end_date
     THEN
       p_period_start := l_valid_periods(i).start_date;
       p_period_end   := l_valid_periods(i).end_date;

       EXIT;
     END IF;
   END LOOP;
 -- JOEL

 END get_application_period;


 FUNCTION get_rest_detail_blocks(
   p_detail_blocks IN block_table
 )
 RETURN NUMBER
 IS

   l_block_index NUMBER;
   l_block_count NUMBER := 0;

 BEGIN
   IF p_detail_blocks.count = 0
   THEN
     RETURN 0;
   END IF;
   FOR l_block_index in p_detail_blocks.first .. p_detail_blocks.last LOOP
     IF p_detail_blocks(l_block_index).added <> 'Y'
     THEN
       l_block_count := l_block_count + 1;
     END IF;
   END LOOP;

   RETURN l_block_count;

 END;


 FUNCTION has_details(
   p_app_id IN hxc_time_building_blocks.time_building_block_id%TYPE
 )
 RETURN BOOLEAN
 IS
   CURSOR c_details(
     p_app_id IN hxc_time_building_blocks.time_building_block_id%TYPE
   )
   IS
     SELECT details.time_building_block_id
       FROM hxc_ap_detail_links details
	   ,hxc_time_building_blocks blocks
      WHERE details.application_period_id = p_app_id
	AND details.time_building_block_id = blocks.time_building_block_id
	AND details.time_building_block_ovn = blocks.object_version_number
	AND blocks.date_to = hr_general.end_of_time;

   l_detail_id hxc_time_building_blocks.time_building_block_id%TYPE;
 BEGIN
   OPEN c_details(p_app_id);
   FETCH c_details INTO l_detail_id;
   IF c_details%NOTFOUND
   THEN
     CLOSE c_details;

     RETURN FALSE;
   END IF;

   CLOSE c_details;
   RETURN TRUE;
 END has_details;

 Procedure get_detail_links(p_app_id in hxc_time_building_blocks.time_building_block_id%TYPE,
			    p_timecard_id in hxc_time_building_blocks.time_building_block_id%TYPE,
			    p_blocks out nocopy block_table )
 IS
 Cursor c_detail_links IS
 select time_building_block_id, time_building_block_ovn
 from hxc_ap_detail_links
 where application_period_id = p_app_id
   and time_building_block_id
   not in ( select detail.time_building_block_id
	      from hxc_time_building_blocks detail,
			   hxc_time_building_blocks day
	     where detail.parent_building_block_id = day.time_building_block_id
			   and detail.parent_building_block_ovn = day.object_version_number
	       and day.scope = 'DAY'
			   and detail.scope = 'DETAIL'
			   and day.parent_building_block_id =  p_timecard_id
			   );


 l_block_index BINARY_INTEGER;
 BEGIN
 l_block_index := 1;

 Open c_detail_links;
 Loop
	 Fetch c_detail_links into p_blocks(l_block_index).block_id,
				   p_blocks(l_block_index).block_ovn;
	 Exit when c_detail_links%notfound;
	 l_block_index := l_block_index + 1;
 End Loop;
 Close c_detail_links;
 End get_detail_links;

 Procedure create_removed_links(p_removed_blocks block_table,
				p_app_id hxc_time_building_blocks.time_building_block_id%TYPE)

 IS
 Cursor c_detail_exists (p_app_id hxc_time_building_blocks.time_building_block_id%TYPE,
			 p_time_building_block_id hxc_time_building_blocks.time_building_block_id%TYPE
			 ) is
 select 1
 from hxc_ap_detail_links
 where application_period_id = p_app_id
 and time_building_block_id = p_time_building_block_id;

 l_block_index BINARY_INTEGER;
 l_dummy PLS_INTEGER;
 BEGIN

   l_block_index := p_removed_blocks.first;

   LOOP
     EXIT WHEN NOT p_removed_blocks.exists(l_block_index);


     open c_detail_exists(p_app_id,
			  p_removed_blocks(l_block_index).block_id
			 );

     fetch c_detail_exists into l_dummy;

     if c_detail_exists%notfound then
       --insert a line in hxc_detail_summary;
       hxc_ap_detail_links_pkg.insert_summary_row(
	 p_app_id
	,p_removed_blocks(l_block_index).block_id
	,p_removed_blocks(l_block_index).block_ovn
       );
      end if;
      close c_detail_exists;

     l_block_index := p_removed_blocks.next(l_block_index);

    END LOOP;

 End create_removed_links;

FUNCTION item_attribute_exists
                (p_item_type in wf_items.item_type%type,
                 p_item_key  in wf_item_activity_statuses.item_key%type,
                 p_name      in wf_item_attribute_values.name%type)
                 return boolean is

      l_dummy varchar2(1);

    BEGIN

      select 'Y'
        into l_dummy
        from wf_item_attribute_values
       where item_type = p_item_type
         and item_key = p_item_key
         and name = p_name;

      return true;

    Exception
       When others then
         return false;

    END item_attribute_exists;


 PROCEDURE generate_app_period(
   p_item_type          IN wf_item_types.name%type
  ,p_item_key           IN wf_item_attribute_values.item_key%type
  ,p_timecard_id        IN hxc_time_building_blocks.time_building_block_id%TYPE
  ,p_resource_id        IN hxc_time_building_blocks.resource_id%TYPE
  ,p_start_time         IN hxc_time_building_blocks.start_time%TYPE
  ,p_stop_time          IN hxc_time_building_blocks.stop_time%TYPE
  ,p_time_recipient_id  IN hxc_time_recipients.time_recipient_id%TYPE
  ,p_recipient_sequence IN hxc_approval_comps.approval_order%TYPE
  ,p_approval_comp      IN approval_comp
  ,p_tc_resubmitted     IN VARCHAR2
 -- ,p_first              IN VARCHAR2
  ,p_detail_blocks      IN OUT NOCOPY block_table
  ,p_detail_attributes  IN hxc_self_service_time_deposit.building_block_attribute_info
 )
 IS

   CURSOR c_app_period(
     p_resource_id hxc_time_building_blocks.resource_id%TYPE
    ,p_start_time  hxc_time_building_blocks.start_time%TYPE
    ,p_stop_time   hxc_time_building_blocks.stop_time%TYPE
    ,p_time_recipient_id hxc_time_recipients.time_recipient_id%TYPE
    ,p_recipient_sequence IN hxc_approval_comps.approval_order%TYPE
    ,p_time_category_id  hxc_time_categories.time_category_id%TYPE
    ,p_category_sequence hxc_approval_comps.approval_order%TYPE
   )
   IS
   SELECT application_period_id
	 ,application_period_ovn
	 ,approval_status
	 ,notification_status
         ,approval_comp_id
     FROM hxc_app_period_summary
    WHERE resource_id = p_resource_id
      AND start_time = p_start_time
      AND stop_time = p_stop_time
      AND time_recipient_id = p_time_recipient_id
      AND recipient_sequence = p_recipient_sequence
      AND NVL(time_category_id, -1) = NVL(p_time_category_id, -1)
      AND NVL(category_sequence, -1) = NVL(p_category_sequence, -1)
      --following added may12 for hr supervisor
 ORDER BY application_period_id asc;

   CURSOR c_tc_ap_link(
     p_timecard_id hxc_time_building_blocks.time_building_block_id%TYPE
    ,p_app_period_id hxc_time_building_blocks.time_building_block_id%TYPE
   )
   IS
   SELECT 'Y'
     FROM hxc_tc_ap_links
    WHERE timecard_id = p_timecard_id
      AND application_period_id = p_app_period_id;

 cursor c_previous_actioner(
                            p_app_period_id in hxc_app_period_summary.application_period_id%type) is
 select approver_id
   from hxc_app_period_summary
  where application_period_id = p_app_period_id;

  CURSOR c_get_detail_blocks(p_application_period_id in hxc_time_building_blocks.time_building_block_id%type)
       is
  select adl.time_building_block_id,
           adl.time_building_block_ovn
  from hxc_ap_detail_links adl
  where adl.application_period_id = p_application_period_id;

  cursor get_max_ovn(p_bb_id in hxc_time_building_blocks.time_building_block_id%type)
  is
  select max(object_version_number)
  from hxc_time_building_blocks
  where time_building_block_id = p_bb_id;

  cursor get_item_key(p_bb_id in number)
  is
  select approval_item_key
  from hxc_app_period_summary
  where application_period_id = p_bb_id;


   l_app_id            hxc_time_building_blocks.time_building_block_id%TYPE := NULL;
   l_app_ovn           hxc_time_building_blocks.object_version_number%TYPE := NULL;
   l_approval_status   hxc_time_building_blocks.approval_status%TYPE := NULL;
   l_notification_status VARCHAR2(150) := NULL;
   l_app_comp_id       hxc_app_period_summary.approval_comp_id%type;
   l_app_id_temp       hxc_time_building_blocks.time_building_block_id%TYPE := NULL;
   l_app_ovn_temp      hxc_time_building_blocks.object_version_number%TYPE := NULL;
   l_app_status_temp   hxc_time_building_blocks.approval_status%TYPE := NULL;
   l_notif_status_temp VARCHAR2(150) := NULL;
   l_app_comp_id_temp  hxc_app_period_summary.approval_comp_id%type;
   l_first_app_period  BOOLEAN;
   l_time_category_id  hxc_time_categories.time_category_id%TYPE := NULL;
   l_category_sequence hxc_app_period_summary.category_sequence%TYPE := NULL;
   l_creation_date     DATE;
   t_attributes        hxc_time_attributes_api.timecard;
   l_tc_ap_link_exists VARCHAR2(50) := NULL;
   l_app_exists        BOOLEAN;
   l_removed_blocks     block_table;

   l_is_empty          Boolean := true;
   l_item_key_exists   NUMBER := 0;

   l_dummy number;
   l_number_of_details number;
   i number;
   l_max_ovn number;
   l_item_key number ;
   l_blank varchar2(2) := 'N';
   l_active_details	NUMBER;  -- 8620917
   type rec_type is record(p_id hxc_time_building_blocks.time_building_block_id%TYPE,
   p_ovn hxc_time_building_blocks.time_building_block_id%TYPE);


   TYPE tab_type IS TABLE OF rec_type INDEX BY BINARY_INTEGER;

   l_tab_type_a		tab_type;
   l_proc              VARCHAR2(100) := g_package || 'generate_app_period';

   l_tc_details NUMBER;   -- Bug 8685110

 BEGIN
   g_debug := true;
   g_trace := l_proc || '10';
   l_item_key := null;
   if g_debug then
	hr_utility.trace('start generating period');
   end if;

   l_time_category_id := p_approval_comp.time_category_id;

   IF l_time_category_id IS NULL
   THEN
     l_category_sequence := NULL;
   ELSE
     l_category_sequence := p_approval_comp.approval_order;
   END IF;


   OPEN c_app_period(
     p_resource_id
    ,p_start_time
    ,p_stop_time
    ,p_time_recipient_id
    ,p_recipient_sequence
    ,l_time_category_id
    ,l_category_sequence
   );

   l_first_app_period := TRUE;

   LOOP

     FETCH c_app_period INTO l_app_id_temp,
                             l_app_ovn_temp,
                             l_app_status_temp,
                             l_notif_status_temp,
                             l_app_comp_id_temp;

     EXIT WHEN c_app_period%NOTFOUND;

        hr_utility.trace('++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
        hr_utility.trace('|--------------------------------------------------------------------|');
        hr_utility.trace('| Application Period Id:'||l_app_id_temp||lpad('|',(68-(length(' Application Period Id:')+length(to_char(l_app_id_temp))))));
        hr_utility.trace('| Application Period Ovn:'||l_app_ovn_temp||lpad('|',(68-(length(' Application Period Ovn:')+length(to_char(l_app_ovn_temp))))));
        hr_utility.trace('| Application Period Status:'||l_app_status_temp||lpad('|',(68-(length(' Application Period Status:')+length(to_char(l_app_status_temp))))));
        hr_utility.trace('| Time Category Id:'||l_time_category_id||lpad('|',(68-(length(' Time Category Id:')+length(to_char(l_time_category_id))))));
        hr_utility.trace('|--------------------------------------------------------------------|');
        hr_utility.trace('++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');

     --for hr supervisor, end date all the later supervisor's app periods
     --only keep the first supervisor's app period. we will regenereate new
     --app periods for later supervisors
     --Here we also delete app period for default approval style when the new
     --timecard doesn't have any block for default approval style.
     IF l_first_app_period
     THEN

       l_app_id := l_app_id_temp;
       l_app_ovn := l_app_ovn_temp;
       l_approval_status := l_app_status_temp;
       l_notification_status := l_notif_status_temp;
       l_app_comp_id := l_app_comp_id_temp;

       l_first_app_period := FALSE;

     ELSE
       --should also end date them from hxc_time_building_blocks
       --remove them from hxc_app_period_summary
       --from hxc_tc_ap_links and hxc_ap_detail_links
       hxc_app_period_summary_api.app_period_delete(l_app_id_temp);

     END IF;

   END LOOP;

   CLOSE c_app_period;
   hr_utility.trace('l_time_category:'||l_time_category_id);

   --
   -- If this is a new application period, and has no associated details
   -- do not create it.  However, if it has been previously created,
   -- we must resend, even if empty, to ensure ELA timecards can be
   -- approved. 115.87
   -- 115.91 Change: We have some competing requirements here for
   -- Project Manager verses the rest of ELA.  Making this logic
   -- a bit clearer.
   IF l_time_category_id IS NOT NULL then
      -- This is an ELA application period
      IF l_time_category_id <> 0 then
         l_is_empty := is_empty(p_detail_blocks,p_detail_attributes,l_time_category_id);
	 -- This is not the default ELA approval style
	 IF l_is_empty then
	    -- There are no details associated with this application period
	    IF l_app_id is null then
	       -- This is a new application, do not generate a new, empty
	       -- application period.
               hr_utility.trace('Return(0)');
	       RETURN;
            END IF;
            IF ((l_app_id is not null)
                AND (l_app_ovn = 1)
                AND (l_notification_status = c_notified OR l_notification_status = c_not_notified )) then
               -- Application period is not new, but the approver has not seen it
               hr_utility.trace('Return(1)');
               RETURN;
            END IF;
         END IF;
      END IF;
   END IF;

   get_detail_links(l_app_id, p_timecard_id, l_removed_blocks);

  --if this timecard doesn't have any block for default style,
  --delete existing app period if any, and do nothing.
  IF l_time_category_id = 0
    AND p_detail_blocks.count > 0
  THEN

    l_is_empty := false; -- Bug 5640516.

    IF get_rest_detail_blocks(p_detail_blocks) = 0
    THEN
      IF l_app_id IS NOT NULL
      THEN
        --check to see if all the detail blocks associated with this
        --app period have been deleted. If so, delete this app period.
        --otherwise, it means, this app period still has details from
        --other timecards, can't delete the app period
        IF NOT has_details(l_app_id)
        THEN
          hxc_app_period_summary_api.app_period_delete(l_app_id);
        END IF;
      END IF;

      hr_utility.trace('Return(2)');
      RETURN;
    END IF;
  END IF;
  --
  -- 115.93 Change: Include check that the approval component id
  -- is the same in the statement below, otherwise we will surely
  -- need to regenerate the application period.  Bug 4302997.
  --
  hr_utility.trace('l_app_id:'||l_app_id);
  hr_utility.trace('l_approval_status:'||l_approval_status);
  hr_utility.trace('Approval Comp Comparison:'||l_app_comp_id||','||p_approval_comp.approval_comp_id);

  if(changed( p_detail_blocks,p_detail_attributes,l_time_category_id,l_app_id, p_timecard_id)) then
     hr_utility.trace('changed is true');
  else
     hr_utility.trace('changed is false');
  end if;

  select count(*) into l_number_of_details
  from hxc_ap_detail_links
  where application_period_id = l_app_id;

  hr_utility.trace('Count for '||l_app_id||' is:'||l_number_of_details);

  -- Bug 8685110
  -- this is to check if the timecard ever had any details attached to it
  select count(*) into l_tc_details
    from hxc_latest_details
   where resource_id = p_resource_id
     and trunc(start_time) >= trunc(p_start_time)
     and trunc(stop_time) <= trunc(p_stop_time);

  hr_utility.trace('l_tc_details = '||l_tc_details);

  IF l_app_id IS NOT NULL
    AND p_approval_comp.approval_comp_id = l_app_comp_id
    AND (NOT changed( p_detail_blocks,p_detail_attributes,l_time_category_id
       ,l_app_id, p_timecard_id))
  THEN
     --
     -- 115.107: An empty complete period should not be reattached to the
     -- timecard.
     --
     if(l_is_empty) then
       --
       -- 115.115 - Bug 5182298
       -- Now have two possibliities:
       --   1. The app period is empty now, and it was before, in which case
       -- we must just return and do nothing (discard this application period)
       --   2. The app period is empty now, but it wasn't before, in which case
       -- we should continue and generate the notification / app period

        if(l_number_of_details = 0 AND l_approval_status <> 'SUBMITTED') then
         -- it is case 1

	hr_utility.trace('into case1');
         -- if an empty timecard is approved/rejected and then resubmitted again, it has to go
         -- through the approval process, so skip this call
	  if (l_tc_details <> 0)  then -- Bug 8685110
         	hr_utility.trace('Return(3) - empty actioned App Period - do nothing');
         	RETURN;
         end if;
        else
         -- it is case 2

         -- if an empty timecard is waiting for approval and it is resubmitted before the
         -- approver can act on the notification, the new notification should be sent to the
         -- approver again, so skip this call

         if (l_tc_details <> 0)  then -- Bug 8685110
           hr_utility.trace('Return(3.5) - newly empty period - notify previous approver');
           open get_item_key(l_app_id);
	   fetch get_item_key into l_item_key;
	   close get_item_key;

	   hr_utility.trace('OTL:-10- before - '||l_item_key);

           If l_item_key is not null then

-- Added for bug 9076079
             select count(*)
               into l_item_key_exists
               from wf_items
               where item_key = to_char(l_item_key)
               and item_type = 'HXCEMP'
                and rownum < 2;


             hr_utility.trace('OTL:-10- before - l_item_key_exists = '||l_item_key_exists);

             IF l_item_key_exists <> 0 THEN
                hr_utility.trace('pass 11');
         	if(item_attribute_exists('HXCEMP',l_item_key,'IS_DIFF_TC')) then
	 		 wf_engine.SetItemAttrText(
	  				   itemtype => 'HXCEMP',
	 				   itemkey  => l_item_key,
	 				   aname    => 'IS_DIFF_TC',
	 				   avalue   => 'Y');
	        else
	                 wf_engine.additemattr
	   			            (itemtype     => 'HXCEMP',
	 			             itemkey      => l_item_key,
	 			             aname        => 'IS_DIFF_TC',
	 		    	             text_value   => 'Y');
	        end if;
	     ELSE
-- Added for bug 9076079
	        hr_utility.trace('OTL:pass 12');
	        g_old_item_key(l_item_key).is_diff_tc := 'Y';

	     END IF;

	        hr_utility.trace('OTL:-10- after');

           end if;

           l_blank := 'Y';
           null;
          end if;  -- Bug  8685110
        end if;

     else
        IF l_approval_status <> 'SUBMITTED' THEN
        --
        -- 115.76 Change.  Ensure this link is created using the normal
        -- interface, not this one which is internal.
        -- hxc_tc_ap_links_pkg.insert_summary_row(p_timecard_id, l_app_id);
        hxc_tc_ap_links_pkg.create_app_period_links(l_app_id);
        --
        -- 115.91 Change: At this point we also ensure the timecard
        -- status is reevaluated so that if a period is not sent due
        -- to other changes in the timecard, the timecard has the
        -- appropriate status.
        --
        hxc_timecard_summary_api.reevaluate_timecard_statuses(l_app_id);
        hr_utility.trace('Return(4) - populated actioned App period - no changes.  Use, but do not renotify');
        RETURN;
        END IF;
     end if;
  END IF;
g_block_exist_for_ap := 'N';

   hr_utility.trace('l_number_of_details = '||l_number_of_details);
   hr_utility.trace('g_block_exist_for_ap = '||g_block_exist_for_ap);
   hr_utility.trace('no_blocks(l_app_id, p_timecard_id) = '||no_blocks(l_app_id, p_timecard_id));
   hr_utility.trace('l_approval_status = '||l_approval_status);

   -- Reverted the changes in bug 8322444 and introduced new changes via 8620917
   /* After a approval notification is approved/rejected, if the user
   deletes a rejected/approved timecard row, then a blank notification has to be sent to the approver.

   If the row deletion is followed by a SAVE and SUBMIT operation then the foll. happens

   changed( p_detail_blocks,p_detail_attributes,l_time_category_id,l_app_id, p_timecard_id) = TRUE
   l_number_of_details <> 0
   g_block_exist_for_ap <> 'Y',
   BUT no_blocks(l_app_id, p_timecard_id) =  l_number_of_details CONDITION FAILS.

   In case of ELA approval, if a rejected timecard row is FULLY deleted, a blank FYI notification
   has to be sent to the previous approver

   Hence substituting the BLANK notification if the number of active detail RECORDS
   for the l_app_id is 0 and set l_blank = 'Y'
   */

  -- modified this query for bug 8920827
  SELECT count(*)
    INTO l_active_details
    FROM hxc_ap_detail_links apdetail
        ,hxc_time_building_blocks detail
        ,hxc_latest_details latest
   WHERE apdetail.application_period_id = l_app_id
     AND apdetail.time_building_block_id = latest.time_building_block_id
     AND latest.time_building_block_id = detail.time_building_block_id
     AND latest.object_version_number  = detail.object_version_number
     AND detail.date_to = hr_general.end_of_time;


  hr_utility.trace('l_active_details = '||l_active_details);


  IF changed( p_detail_blocks,p_detail_attributes,l_time_category_id,l_app_id, p_timecard_id) AND
    l_number_of_details <> 0 AND g_block_exist_for_ap <> 'Y'
    and (no_blocks(l_app_id, p_timecard_id) =  l_number_of_details
         OR l_active_details = 0)  -- Bug 8620917
    and (l_tc_details <> 0)        -- Bug 8685110 , no need to send blank notification for empty timecard
    THEN

	hr_utility.trace('to set l_blank');

  	 open get_item_key(l_app_id);
	 fetch get_item_key into l_item_key;
	 close get_item_key;

         If l_item_key is not null then

             select count(*)
               into l_item_key_exists
               from wf_items
              where item_key = to_char(l_item_key)
                and item_type = 'HXCEMP'
                and rownum < 2;

                hr_utility.trace('OTL:-20- before - l_item_key_exists = '||l_item_key_exists);
                hr_utility.trace('OTL:-20- before - '||l_item_key);

             IF l_item_key_exists <> 0 THEN
                hr_utility.trace('OTL: Item key exists in workflow tables');
         	if(item_attribute_exists('HXCEMP',l_item_key,'IS_DIFF_TC')) then
			 wf_engine.SetItemAttrText(
						   itemtype => 'HXCEMP',
						   itemkey  => l_item_key,
						   aname    => 'IS_DIFF_TC',
						   avalue   => 'Y');
                else
                         wf_engine.additemattr
  			            (itemtype     => 'HXCEMP',
			             itemkey      => l_item_key,
			             aname        => 'IS_DIFF_TC',
		    	             text_value   => 'Y');
                end if;
              ELSE
                HR_UTILITY.TRACE('OTL: Adding to g table');
		g_old_item_key(l_item_key).is_diff_tc := 'Y';
              END IF;



                hr_utility.trace('OTL:-20- after');
         end if;

         l_blank := 'Y';
  END IF;

  IF l_blank = 'Y' THEN

  	open c_get_detail_blocks(l_app_id);
  	fetch c_get_detail_blocks bulk collect INTO l_tab_type_a;
  	close c_get_detail_blocks;

  END IF;

  IF l_app_id IS NOT NULL
  THEN
    remove_ap_detail_links(l_app_id, p_timecard_id);
  END IF;

  --jxtan: when modifying detail blocks and resubmit the timecard,
  --p_tc_resubmitted is set to NO in deposit wrapper. Need to ask
  --andrew. For now added the extra logic here to deal with the scenario:
  --a timecard is approved, but resubmitted. in this case, update the ovn
  --of the application period
  IF l_app_id IS NULL -- no row
   OR (l_app_id IS NOT NULL AND l_approval_status <> 'SUBMITTED')
  THEN
     if(l_app_id is not null) then
        --
        -- Keep the previous approver, in case we need it!
        -- 115.92 Change
        --
        l_dummy := hxc_approval_wf_util.keep_previous_approver
                     (p_item_type,
                      p_item_key,
                      l_app_id
                      );
     end if;

    g_trace := l_proc || '30';

    if g_debug then
	hr_utility.trace('Generate it!');
    end if;

    t_attributes := get_empty_attribute;

    hxc_deposit_process_pkg.execute_deposit_process(
      p_process_name              => g_process_name
     ,p_source_name               => g_source_name
     ,p_effective_date            => trunc(sysdate)
     ,p_type                      => 'RANGE'
     ,p_measure                   => null
     ,p_unit_of_measure           => null
     ,p_start_time                => trunc(p_start_time)
     ,p_stop_time                 => trunc(p_stop_time)
     ,p_parent_building_block_id  => null
     ,p_parent_building_block_ovn => null
     ,p_scope                     => 'APPLICATION_PERIOD'
     ,p_approval_style_id         => NULL
     ,p_approval_status           => 'SUBMITTED'
     ,p_resource_id               => p_resource_id
     ,p_resource_type             => g_resource_type
     ,p_comment_text              => null
     ,p_timecard                  => t_attributes
     ,p_time_building_block_id    => l_app_id
     ,p_object_version_number     => l_app_ovn
    );

    g_trace := l_proc || '40';
    if g_debug then
	    hr_utility.trace('Generated the period');
	    hr_utility.trace('app_id=' || l_app_id);
	    hr_utility.trace('app_ovn=' || l_app_ovn);
	    hr_utility.trace('Populating hxc_app_period_summary');
    end if;
    l_creation_date := get_creation_date(l_app_id, l_app_ovn);

    g_trace := l_proc || '80';

    --populate hxc_app_period_summary with the new row
    hxc_app_period_summary_api.app_period_create(
       p_application_period_id  => l_app_id
      ,p_application_period_ovn => l_app_ovn
      ,p_approval_status        => 'SUBMITTED'
      ,p_time_recipient_id      => p_time_recipient_id
      ,p_time_category_id       => p_approval_comp.time_category_id
      ,p_start_time		=> p_start_time
      ,p_stop_time		=> p_stop_time
      ,p_resource_id		=> p_resource_id
      ,p_recipient_sequence	=> p_recipient_sequence
      ,p_category_sequence	=> l_category_sequence
      ,p_creation_date		=> l_creation_date
      ,p_notification_status	=> 'NOT_NOTIFIED'
      ,p_approver_id		=> NULL
      ,p_approval_comp_id	=> p_approval_comp.approval_comp_id
      ,p_approval_item_key     =>  l_item_key
    );

    g_trace := l_proc || '90';

 ELSE

    IF l_notification_status <> 'NOT_NOTIFIED' THEN
    -- don't create a new application period, but need to change status
      UPDATE hxc_app_period_summary
         SET notification_status = 'NOT_NOTIFIED'
             ,approval_comp_id = p_approval_comp.approval_comp_id
       WHERE application_period_id = l_app_id;
    elsif(p_approval_comp.approval_comp_id <> l_app_comp_id) then
       -- do not create a new application period, but ensure the
       -- correct approval component id is used.
      UPDATE hxc_app_period_summary
         SET approval_comp_id = p_approval_comp.approval_comp_id
       WHERE application_period_id = l_app_id;
    END IF;

 END IF;

  if g_debug then
	hr_utility.trace('Populating hxc_ap_detail_links');
  end if;
  --populate hxc_ap_detail_links
  IF l_time_category_id IS NULL
      OR l_time_category_id = 0
  THEN
      g_trace := l_proc || '100';

      if g_debug then
	hr_utility.trace('Populating all');
      end if;
      link_ap_details_all(
        p_detail_blocks    => p_detail_blocks
       ,p_app_id           => l_app_id
       ,p_time_category_id => l_time_category_id
      );

  ELSE
      g_trace := l_proc || '110';

      if g_debug then
	hr_utility.trace('Populating time category : ' || l_time_category_id );
      end if;
      link_ap_details(
        p_detail_blocks    => p_detail_blocks
       ,p_attributes       => p_detail_attributes
       ,p_time_category_id => l_time_category_id
       ,p_app_id           => l_app_id
      );

      g_trace := l_proc || '120';
  END IF;

IF (l_removed_blocks.COUNT > 0) THEN  -- Bug 8685110, this count is 0 for empty timecards
  create_removed_links(l_removed_blocks, l_app_id);
END IF;


IF l_tab_type_a.COUNT > 0 THEN  -- Bug 8685110
 IF l_blank = 'Y' THEN

    FOR i IN l_tab_type_a.first..l_tab_type_a.last LOOP

	open get_max_ovn(l_tab_type_a(i).p_id);
	fetch get_max_ovn into l_max_ovn;
	close get_max_ovn;

	hxc_ap_detail_links_pkg.insert_summary_row(l_app_id, l_tab_type_a(i).p_id, l_max_ovn);

    END LOOP;
 END IF;
END IF;

  g_trace := l_proc || '130';


  if g_debug then
	hr_utility.trace('Populating hxc_tc_ap_links');
  end if;
  --populate hxc_tc_ap_links

  OPEN c_tc_ap_link(p_timecard_id, l_app_id);
  FETCH c_tc_ap_link INTO l_tc_ap_link_exists;
  CLOSE c_tc_ap_link;

  g_trace := l_proc || '160';

  IF l_tc_ap_link_exists IS NULL
  THEN
    g_trace := l_proc || '170';
--
-- 115.76 Change.  It is ok to leave this call, since
-- the link is explicitly checked not to exist in the
-- first place.
--
    hxc_tc_ap_links_pkg.insert_summary_row(
      p_timecard_id           => p_timecard_id
     ,p_application_period_id => l_app_id
    );
--
--115.118, Bug - 5554020
--
   hxc_timecard_summary_api.reevaluate_timecard_statuses(l_app_id);

    g_trace := l_proc || '180';
  END IF;

  if g_debug then
	hr_utility.trace('End generating app period');
  end if;

EXCEPTION
  WHEN OTHERS THEN
    hr_utility.trace('exception in generate_app_period - '||sqlerrm);
    RAISE;

END generate_app_period;



------------------------- get_approval_style_id ----------------------------
--
FUNCTION get_approval_style_id(p_period_start_date date,
                               p_period_end_date   date,
                               p_resource_id       number) RETURN NUMBER IS
--
-- Andrew: Bug 3211251: Use date_to = end of time filter, instead of
-- max ovn sub-query.  Faster, and avoids picking up approval styles
-- from deleted timecards.
--
-- Andrew: Bug 4178239: This cursor could previously pick up the
-- approval styles associated with templates created in the same
-- week as the timecard being approved.  This could lead to the
-- incorrect approval style being used.  Thus, check the day
-- driving the style is attached to an active timecard before
-- choosing that style.
--
cursor csr_get_appr_style is
   SELECT day1.approval_style_id
     FROM hxc_time_building_blocks day1,
	  hxc_time_building_blocks timecard
    WHERE day1.resource_id = p_resource_id
      AND day1.scope = 'DAY'
      AND day1.start_time BETWEEN p_period_start_date AND p_period_end_date
      AND day1.date_to = hr_general.end_of_time
      AND timecard.time_building_block_id = day1.parent_building_block_id
      AND timecard.object_version_number = day1.parent_building_block_ovn
      AND timecard.scope = 'TIMECARD'
      AND timecard.date_to = hr_general.end_of_time
 ORDER BY day1.start_time desc;
--
l_approval_style_id number;
l_proc          varchar2(100) := 'HXC_APPROVAL_WF_PKG.get_approval_style_id';
--
BEGIN
--
if g_debug then
	hr_utility.set_location(l_proc, 10);
end if;
--
open csr_get_appr_style;
fetch csr_get_appr_style into l_approval_style_id;
IF csr_get_appr_style%NOTFOUND THEN
   --
   if g_debug then
	hr_utility.set_location(l_proc, 20);
   end if;
   --
   g_error_count := g_error_count + 1;
   g_error_table(g_error_count).MESSAGE_NAME := 'HXC_APR_NO_APPR_STYLE';
   g_error_table(g_error_count).APPLICATION_SHORT_NAME := 'HXC';
   --
   hr_utility.set_message(809, 'HXC_APR_NO_APPR_STYLE');
   hr_utility.raise_error;
   --
END IF;
--
close csr_get_appr_style;
--
RETURN(l_approval_style_id);
--
END get_approval_style_id;

  Function dayHasActiveAssignment
    (p_assignment_periods in hxc_timecard_utilities.periods,
     p_day_start          in date) return boolean is
    l_asg_index binary_integer;
    l_found     boolean;
  Begin
    l_asg_index := p_assignment_periods.first;
    l_found := false;
    Loop
      Exit when (not p_assignment_periods.exists(l_asg_index) OR l_found);
      if(trunc(p_day_start) between trunc(p_assignment_periods(l_asg_index).start_date)
         and trunc(p_assignment_periods(l_asg_index).end_date)) then
        l_found := true;
      end if;
      l_asg_index := p_assignment_periods.next(l_asg_index);
    End Loop;
    return l_found;
  End dayHasActiveAssignment;

PROCEDURE create_appl_period_info(itemtype     IN varchar2,
                                  itemkey      IN varchar2,
                                  actid        IN number,
                                  funcmode     IN varchar2,
                                  result       IN OUT NOCOPY varchar2) is
--
   cursor csr_get_app_set_from_tc
      (p_timecard_id in hxc_time_building_blocks.time_building_block_id%type,
       p_timecard_ovn in hxc_time_building_blocks.object_version_number%type) is
   select to_char(application_set_id)
     from hxc_time_building_blocks
    where time_building_block_id = p_timecard_id
      and object_version_number = p_timecard_ovn;
--
cursor csr_get_tc_info(p_bld_blk_id number,
                       p_ovn        number) is
   select tc.resource_id, tc.start_time, tc.stop_time
     from hxc_time_building_blocks tc
    where tc.time_building_block_id = p_bld_blk_id
      and tc.object_version_number = p_ovn;
--
cursor csr_get_apps(p_app_set     varchar2) is
   select htr.name,
          htr.application_id,
          htr.application_period_function,
          htr.time_recipient_id
     from hxc_application_sets_v has,
          hxc_application_set_comps_v hasc,
          hxc_time_recipients htr
    where to_char(has.application_set_id) = p_app_set
      and hasc.application_set_id = has.application_set_id
      and hasc.time_recipient_id = htr.time_recipient_id;
--
cursor csr_get_days(p_tc_bld_blk_id number,
		    p_tc_ovn        number) is
   select day.time_building_block_id,
          day.start_time,
          day.stop_time,
          day.object_version_number
     from hxc_time_building_blocks day
    where day.parent_building_block_id = p_tc_bld_blk_id
      and day.parent_building_block_ovn = p_tc_ovn
      and day.scope = 'DAY'
      and day.object_version_number = (select max(day2.object_version_number)
                                         from hxc_time_building_blocks day2
                                        where day.time_building_block_id =
                                              day2.time_building_block_id)
   order by 2;
--
------   Project manager changes
l_detail_project_id NUMBER;
l_tab_project_id hxc_proj_manager_approval_pkg.tab_project_id;

l_index number;
l_index_1  number;
l_index_2  number;
l_index_3  number;
l_no_project_manager number;
l_already_present  number;
l_approval_style_id number;
l_original_approval_order number;




l_tc_bld_blk_id      number;
l_tc_date_from       date;
l_tc_date_to         date;
l_tc_ovn             number;
l_tc_resubmitted     varchar2(10);
--
l_tc_resource_id     number;
l_tc_start_time      date;
l_tc_stop_time       date;
--
l_exist_bb_id        number;
l_exist_status       varchar2(30);
l_exist_ovn          number;
--l_first              number;
--
l_app_set            varchar2(150);
l_application        varchar2(80);
l_application_id     number;
l_time_recipient_id  number;
l_time_recipient     varchar2(150);
l_app_period_func    varchar2(240) := NULL;
--

--
l_rec_period_id      number;
--
l_day_bld_blk_id     number;
l_day_start_time     date;
l_day_stop_time      date;
l_day_ovn            number;
l_appl_period_bb_id  number;
l_appl_period_bb_ovn number;
l_period_start_date  date;
l_period_end_date    date;
l_override_allowed   boolean;
t_attributes         hxc_time_attributes_api.timecard;
--
l_all_apps           varchar2(1000);
l_cnt                number;
--
l_exists             varchar2(1);
l_chk_days           varchar2(1);
l_item_key           wf_items.item_key%type;
l_process_name       varchar2(30);
l_proc          varchar2(100) := 'HXC_APPROVAL_WF_PKG.create_appl_period_info';

--
  l_detail_blocks     block_table;
  l_detail_attributes     hxc_self_service_time_deposit.building_block_attribute_info;

  l_new_detail_blocks     hxc_block_table_type := hxc_block_table_type ();
  l_new_detail_attributes hxc_attribute_table_type := hxc_attribute_table_type ();

  l_approval_style    hxc_approval_styles.approval_style_id%TYPE;
  l_assignment_periods hxc_timecard_utilities.periods;


  CURSOR c_approval_comp(
    p_approval_style hxc_approval_styles.approval_style_id%TYPE
   ,p_time_recipient hxc_time_recipients.time_recipient_id%TYPE
  )
  IS
  SELECT approval_comp_id
        ,object_version_number
        ,approval_mechanism
        ,approval_mechanism_id
        ,wf_item_type
        ,wf_name
        ,time_category_id
        ,approval_order
    FROM hxc_approval_comps
   WHERE approval_style_id = p_approval_style
     AND time_recipient_id = p_time_recipient;


  CURSOR c_ela_comps(
    p_comp_id  hxc_approval_comps.approval_comp_id%TYPE
   ,p_comp_ovn hxc_approval_comps.object_version_number%TYPE
  )
  IS
  SELECT approval_comp_id
        ,object_version_number
        ,approval_mechanism
        ,approval_mechanism_id
        ,wf_item_type
        ,wf_name
        ,time_category_id
        ,approval_order
    FROM hxc_approval_comps
   WHERE parent_comp_id = p_comp_id
     AND parent_comp_ovn = p_comp_ovn
ORDER BY time_category_id desc;

 cursor c_app_overlap_data_set(l_app_start_date hxc_time_building_blocks.start_time%type,
                              l_app_stop_date hxc_time_building_blocks.start_time%type,
			      l_tc_start_time hxc_time_building_blocks.start_time%type )
 is
 select '1' from hxc_data_sets
 where (((l_app_start_date between start_date and end_date) and (l_app_start_date<l_tc_start_time))
        or l_app_stop_date between start_date and end_date)
 and status in('OFF_LINE','RESTORE_IN_PROGRESS','BACKUP_IN_PROGRESS');

  l_approval_comp approval_comp;
  l_ela_comp      approval_comp;
  l_default_comp  approval_comp;
  l_count         NUMBER;
  l_dummy         NUMBER;

  l_processed_app_start hxc_time_building_blocks.start_time%TYPE;
  l_processed_app_stop hxc_time_building_blocks.stop_time%TYPE;
  l_gen_app_period boolean;

BEGIN

g_debug:=hr_utility.debug_enabled;
g_trace := '10';
  if g_debug then
	hr_utility.set_location(l_proc, 10);
  end if;

  l_tc_bld_blk_id := wf_engine.GetItemAttrNumber
                             (itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'TC_BLD_BLK_ID');

  if g_debug then
	hr_utility.trace('Timecard BB ID is : ' || to_char(l_tc_bld_blk_id));
  end if;
  l_tc_ovn := wf_engine.GetItemAttrNumber
                             (itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'TC_BLD_BLK_OVN');

  if g_debug then
	hr_utility.trace('Timecard BB OVN is : ' || to_char(l_tc_ovn));
  end if;

  l_tc_resubmitted := wf_engine.GetItemAttrText
                             (itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'TC_RESUBMITTED');

  if g_debug then
	hr_utility.trace('Timecard Resubmitted is : ' || l_tc_resubmitted);
  end if;

  g_trace := '20';

  open csr_get_tc_info(l_tc_bld_blk_id,
                     l_tc_ovn);
  fetch csr_get_tc_info into l_tc_resource_id,
                           l_tc_start_time,
                           l_tc_stop_time;


  IF csr_get_tc_info%NOTFOUND
  THEN

    g_trace := '30';

    g_error_count := g_error_count + 1;
    g_error_table(g_error_count).MESSAGE_NAME := 'HXC_APR_NO_TIMECARD_INFO';
    g_error_table(g_error_count).APPLICATION_SHORT_NAME := 'HXC';

    hr_utility.set_message(809, 'HXC_APR_NO_TIMECARD_INFO');
    hr_utility.raise_error;
  END IF;
  g_trace := '40';

  close csr_get_tc_info;
-- Bug 4716082, try the application set on the timecard first, not the current preference
  open csr_get_app_set_from_tc(l_tc_bld_blk_id,l_tc_ovn);
  fetch csr_get_app_set_from_tc into l_app_set;
  if((csr_get_app_set_from_tc%notfound)OR(l_app_set is null)) then
     close csr_get_app_set_from_tc;
     g_trace := '45';
     l_app_set := hxc_preference_evaluation.resource_preferences
        (p_resource_id  => l_tc_resource_id,
         p_pref_code    => 'TS_PER_APPLICATION_SET',
         p_attribute_n  => 1);
  else
     g_trace := '47 -'||l_app_set;
     close csr_get_app_set_from_tc;
  end if;

  g_trace := '50';

  open csr_get_apps(l_app_set);
  fetch csr_get_apps into l_application,
                        l_application_id,
                        l_app_period_func,
                        l_time_recipient_id;

  IF csr_get_apps%NOTFOUND
  THEN

    g_trace := '60';

    g_error_count := g_error_count + 1;
    g_error_table(g_error_count).MESSAGE_NAME := 'HXC_APR_NO_APPL_SET_PREF';
    g_error_table(g_error_count).APPLICATION_SHORT_NAME := 'HXC';

    hr_utility.set_message(809, 'HXC_APR_NO_APPL_SET_PREF');
    hr_utility.raise_error;

  END IF;
  close csr_get_apps;

  l_assignment_periods
    := hxc_timecard_utilities.get_assignment_periods(l_tc_resource_id);


  g_trace := '70';

  open csr_get_apps(l_app_set);

  LOOP     -- loop through all apps for this timecard

    g_trace := '80';

    fetch csr_get_apps into l_application,
                           l_application_id,
			   l_app_period_func,
			   l_time_recipient_id;

    exit when csr_get_apps%NOTFOUND;

    g_trace := '90 Application=' || l_application;
    g_trace := '90 Time Recipient ID=' || to_char(l_time_recipient_id);

    if g_debug then
	    hr_utility.trace('90 Application=' || l_application);
	    hr_utility.trace('90 Time Recipient ID=' || to_char(l_time_recipient_id));
    end if;

    l_processed_app_start := NULL;
    l_processed_app_stop := NULL;

    -- open cursor to get all related DAY blocks for this timecard.

    open csr_get_days(l_tc_bld_blk_id, l_tc_ovn);
    LOOP      -- loop through all related days
      g_trace := '100';

      fetch csr_get_days into l_day_bld_blk_id,
			      l_day_start_time,
			      l_day_stop_time,
			      l_day_ovn;
      exit when csr_get_days%NOTFOUND;

      if(dayHasActiveAssignment(l_assignment_periods,l_day_start_time))then

         if g_debug then
         hr_utility.set_location(l_proc, 90);
         hr_utility.trace('day start=' || to_char(l_day_start_time, 'YYYY/MM/DD'));
         end if;

         get_application_period
           (p_app_period_func    => l_app_period_func,
            p_resource_id        => l_tc_resource_id,
            p_day                => l_day_start_time,
            p_time_recipient     => l_time_recipient_id,
            p_tc_start_time      => l_tc_start_time,
            p_tc_stop_time       => l_tc_stop_time,
            p_assignment_periods => l_assignment_periods,
            p_period_start       => l_period_start_date,
            p_period_end         => l_period_end_date
            );

         g_trace := '120' || 'app_start=' || to_char(l_period_start_date, 'YYYY/MM/DD')
           || '|app_end=' || to_char(l_period_end_date, 'YYYY/MM/DD');


         l_gen_app_period:=true;

         open c_app_overlap_data_set(l_period_start_date,l_period_end_date,l_tc_start_time);
         fetch c_app_overlap_data_set into l_dummy;
         if(c_app_overlap_data_set%found) then
           l_gen_app_period:=false;
         else
           l_gen_app_period:=true;
         end if;
         close c_app_overlap_data_set;

         IF l_processed_app_start IS NULL
            OR (l_processed_app_start IS NOT NULL
                AND l_processed_app_stop IS NOT NULL
                AND l_processed_app_start <> l_period_start_date) THEN
           l_processed_app_start := l_period_start_date;
           l_processed_app_stop := l_period_end_date;

           l_approval_style := get_approval_style_id
             (p_period_start_date => l_period_start_date,
              p_period_end_date   => l_period_end_date,
              p_resource_id       => l_tc_resource_id
              );

           g_trace := '130 approval style_id=' || l_approval_style;
           --prepare data
           get_detail_blocks(p_timecard_id  => l_tc_bld_blk_id,
                             p_timecard_ovn => l_tc_ovn,
                             p_start_time   => l_period_start_date,
                             p_stop_time    => l_period_end_date,
                             p_detail_blocks => l_detail_blocks,
                             p_new_detail_blocks => l_new_detail_blocks
                             );

           OPEN c_approval_comp(l_approval_style, l_time_recipient_id);
           FETCH c_approval_comp INTO l_approval_comp;

           if c_approval_comp%notfound then
             g_trace := l_approval_style||' - '||l_time_recipient_id;
             close c_approval_comp;
             fnd_message.set_name(801, 'HR_6153_ALL_PROCEDURE_FAIL');
             fnd_message.set_token('PROCEDURE', l_proc);
             fnd_message.set_token('STEP', '130');
             fnd_message.raise_error;
           end if;

           close c_approval_comp;

/* We check whether the approval style is Project manager, if so we
need to replace it with the special ELA approval style created */


           IF l_approval_comp.approval_mechanism = 'PROJECT_MANAGER' THEN

             -- Bug 4297436. Setting the original Project Manager Sequenceto the special ELA style app. period.
             -- Change for version 115.94

             l_original_approval_order :=  l_approval_comp.approval_order ;

             l_approval_style_id := l_approval_style;
             get_detail_attributes(p_detail_blocks 	=> l_detail_blocks,
                                   p_detail_attributes 	=> l_detail_attributes,
                                   p_new_detail_attributes => l_new_detail_attributes);

/* looping through all the projects present in the Timecard */

             l_index_1 := 1;
             l_index := l_detail_attributes.first;
             WHILE l_index IS NOT NULL LOOP
               IF l_detail_attributes(l_index).attribute_category = 'PROJECTS' THEN
                 l_detail_project_id := l_detail_attributes(l_index).attribute1;
                 l_already_present := 0;
                 /*l_no_project_manager := 0;

		IF NOT ( g_tab_project_id.exists(l_detail_project_id ) ) THEN
                  g_tab_project_id( l_detail_project_id).manager_id := NULL;
                  l_no_project_manager  := 1;
		ELSIF g_tab_project_id(l_detail_project_id).manager_id IS NULL THEN
                  l_no_project_manager  := 1;
		END IF;

		IF l_no_project_manager  = 1 THEN*/

                  l_index_2  := l_tab_project_id.first;
                  WHILE l_index_2 IS NOT NULL LOOP
                    IF l_tab_project_id(l_index_2).project_id = l_detail_project_id THEN
                      l_already_present := 1;
                      EXIT;
                    END IF;
                    l_index_2 :=  l_tab_project_id.next (l_index_2 );
                  END LOOP;
                  IF l_already_present = 0 THEN
                    l_tab_project_id(l_index_1).project_id := l_detail_attributes(l_index).attribute1;
                    l_index_1 := l_index_1 + 1;
                  END IF;
		--END IF;    --   if no project manager block
              END IF;    --   if PROJECTS block
              l_index := l_detail_attributes.next(l_index );
            END LOOP;

/* call the procedure to replace the proj. manager approval style by the special ELA approval style */

            hxc_proj_manager_approval_pkg.replace_projman_by_spl_ela
              (p_tab_project_id => l_tab_project_id,
               p_new_spl_ela_style_id =>	l_approval_style);

            l_index_3 := l_tab_project_id.first;


            WHILE l_index_3 IS NOT NULL LOOP
              g_tab_project_id( l_tab_project_id( l_index_3 ).project_id ).manager_id := l_tab_project_id( l_index_3 ).manager_id;
              l_index_3 := l_tab_project_id.next( l_index_3 ) ;
            END LOOP;

/* After replacement finding the approval comp associated with the spl. ela style */

            OPEN c_approval_comp(l_approval_style, l_time_recipient_id);
            FETCH c_approval_comp INTO l_approval_comp;
            CLOSE c_approval_comp;

            l_approval_comp.approval_order := l_original_approval_order ;

          END IF;         --- If Project manager block



          IF l_approval_comp.approval_mechanism = 'ENTRY_LEVEL_APPROVAL' THEN
            if g_debug then
              hr_utility.trace(l_proc || 'Entry level approvals 150');
            end if;

            g_trace := '150 ELA';

            --get detail attributes
            get_detail_attributes
              (p_detail_blocks => l_detail_blocks,
               p_detail_attributes => l_detail_attributes,
               p_new_detail_attributes => l_new_detail_attributes );


            -- push the block and attribute structures into the temporary
            -- tables used by Time Categories

            hxc_time_category_utils_pkg.push_timecard ( l_new_detail_blocks, l_new_detail_attributes, TRUE );

            if g_debug then
              hr_utility.trace(l_proc || 'Entry level approvals 160');
            end if;

            OPEN c_ela_comps(l_approval_comp.approval_comp_id,
                             l_approval_comp.object_version_number);

            LOOP
              FETCH c_ela_comps INTO l_ela_comp;
              EXIT WHEN c_ela_comps%NOTFOUND;

              IF l_ela_comp.time_category_id = 0 THEN
                l_default_comp := l_ela_comp;
              ELSE
                if g_debug then
                  hr_utility.trace(l_proc || 'Entry level approvals 170');
                end if;
                g_trace := '170 ELA generating period';

                if(l_gen_app_period) then
                  generate_app_period(p_item_type          => itemtype,
                                      p_item_key          => itemkey,
                                      p_timecard_id       => l_tc_bld_blk_id,
                                      p_resource_id       => l_tc_resource_id,
                                      p_start_time        => l_period_start_date,
                                      p_stop_time         => l_period_end_date,
                                      p_time_recipient_id => l_time_recipient_id,
                                      p_recipient_sequence=> l_approval_comp.approval_order,
                                      p_approval_comp     => l_ela_comp,
                                      p_tc_resubmitted    => l_tc_resubmitted,
                                      p_detail_blocks     => l_detail_blocks,
                                      p_detail_attributes => l_detail_attributes
                                      );
                end if;

                if g_debug then
                  hr_utility.trace(l_proc || 'Entry level approvals 180');
                end if;
                g_trace :=' 180 ELA finish generating period';

              END IF;

            END LOOP;

            CLOSE c_ela_comps;

            if g_debug then
              hr_utility.trace(l_proc || 'Entry level approvals 200');
            end if;
            g_trace := '200 any detail left??';

            --Now take care of the rest of the blocks
            l_count := get_rest_detail_blocks(l_detail_blocks);

            if g_debug then
              hr_utility.trace('210 rest_detail_count=' || l_count);
            end if;

            g_trace := '210 rest_detail_count=' || l_count;
            if g_debug then
              hr_utility.trace('220 rest_detail_count > 0');
	    end if;

            g_trace := '220 rest_detail_count > 0';

            if(l_gen_app_period) then
              generate_app_period(p_item_type         => itemtype,
                                  p_item_key          => itemkey,
                                  p_timecard_id       => l_tc_bld_blk_id,
                                  p_resource_id       => l_tc_resource_id,
                                  p_start_time        => l_period_start_date,
                                  p_stop_time         => l_period_end_date,
                                  p_time_recipient_id => l_time_recipient_id,
                                  p_recipient_sequence=> l_approval_comp.approval_order,
                                  p_approval_comp     => l_default_comp,
                                  p_tc_resubmitted    => l_tc_resubmitted,
                                  p_detail_blocks     => l_detail_blocks,
                                  p_detail_attributes => l_detail_attributes
                                  );
            end if;

            if g_debug then
              hr_utility.trace('230 finished generating period for rest details');
	    end if;
            g_trace := '230 finished generating period for rest details';
          ELSE
            if g_debug then
              hr_utility.trace('250 NON ELA');
            end if;
            g_trace := '250 NON ELA';

            -- non ELA mechanism
            if(l_gen_app_period) then
              generate_app_period(p_item_type         => itemtype,
                                  p_item_key          => itemkey,
                                  p_timecard_id       => l_tc_bld_blk_id,
                                  p_resource_id       => l_tc_resource_id,
                                  p_start_time        => l_period_start_date,
                                  p_stop_time         => l_period_end_date,
                                  p_time_recipient_id => l_time_recipient_id,
                                  p_recipient_sequence=> l_approval_comp.approval_order,
                                  p_approval_comp     => l_approval_comp,
                                  p_tc_resubmitted    => l_tc_resubmitted,
                                  p_detail_blocks     => l_detail_blocks,
                                  p_detail_attributes => l_detail_attributes
                                  );
            end if;

            if g_debug then
              hr_utility.trace( '260 finished generating period for NON ELA');
            end if;
            g_trace := '260 finished generating period for NON ELA';
          END IF;
        END IF;

      End If; -- Is the day within an active assignment.

    END LOOP; -- loop through all related days

    close csr_get_days;

  END LOOP; -- loop through all apps for this timecard

  --OIT Enhancement.
  --FYI Notification to WORKER on timecard SUBMISSION
 hxc_approval_wf_helper.set_notif_attribute_values
     (itemtype,
      itemkey,
      hxc_app_comp_notifications_api.c_action_submission,
      hxc_app_comp_notifications_api.c_recipient_worker
      );

  if g_debug then
	hr_utility.set_location(l_proc, 200);
  end if;
  close csr_get_apps;

  if g_debug then
	hr_utility.trace('300 END of create_appl_period_info');
  end if;


  g_trace := '300 END of create_appl_period_info';

  result := '';
  return;

exception
  when others then
     -- The line below records this function call in the error system
     -- in the case of an exception.
     --
     if g_debug then
	hr_utility.set_location(l_proc, 999);
     --
	hr_utility.trace('IN EXCEPTION IN create_appl_period_info');
     --
     end if;
     wf_core.context('HCAPPRWF', 'hxc_approval_wf_pkg.create_appl_period_info',
                     itemtype, itemkey, to_char(actid), funcmode, g_trace);

     raise;
     result := '';
     return;
--
--

END create_appl_period_info;
--

--


FUNCTION chk_app_approved(
  p_resource_id       IN hxc_time_building_blocks.resource_id%TYPE
 ,p_period_start_date IN hxc_time_building_blocks.start_time%TYPE
 ,p_period_end_date   IN hxc_time_building_blocks.stop_time%TYPE
 ,p_time_recipient_id IN hxc_time_recipients.time_recipient_id%TYPE
 ,p_recipient_sequence IN hxc_app_period_summary.recipient_sequence%TYPE
 ,p_time_category_id   IN hxc_time_categories.time_category_id%TYPE
 ,p_category_sequence  IN hxc_app_period_summary.category_sequence%TYPE
)
RETURN VARCHAR2
IS

  CURSOR csr_chk(
    p_date               DATE
   ,p_resource_id        hxc_time_building_blocks.resource_id%TYPE
   ,p_period_start_date  hxc_time_building_blocks.start_time%TYPE
   ,p_period_end_date    hxc_time_building_blocks.stop_time%TYPE
   ,p_time_recipient_id  hxc_time_recipients.time_recipient_id%TYPE
   ,p_recipient_sequence hxc_app_period_summary.recipient_sequence%TYPE
   ,p_time_category_id   hxc_time_categories.time_category_id%TYPE
   ,p_category_sequence  hxc_app_period_summary.category_sequence%TYPE
  )
  IS
  SELECT aps.approval_status
    FROM hxc_app_period_summary aps
   WHERE aps.resource_id = p_resource_id
     AND p_date BETWEEN aps.start_time AND aps.stop_time
     AND aps.approval_status <> 'APPROVED'
     AND (
            (aps.recipient_sequence < p_recipient_sequence)
         OR (p_category_sequence IS NOT NULL
             AND aps.time_recipient_id = p_time_recipient_id
             AND aps.recipient_sequence = p_recipient_sequence
             AND aps.time_category_id IS NOT NULL
             AND aps.category_sequence IS NOT NULL
             AND aps.time_category_id = p_time_category_id
             AND aps.category_sequence < p_category_sequence)
         )
     AND exists
      (select 'Y'
         from hxc_tc_ap_links tcl
        where tcl.application_period_id = aps.application_period_id
       );

  l_days      number := p_period_end_date - p_period_start_date + 1;
  l_date            date;
  l_approved        varchar2(1);
  l_approval_status varchar2(30);
  l_proc          varchar2(100) := 'HXC_APPROVAL_WF_PKG.chk_app_approved';

BEGIN

  if g_debug then
	hr_utility.set_location(l_proc, 10);
  end if;
  l_date := p_period_start_date;

  l_approved := 'Y';

  FOR i in 1 .. l_days LOOP

    OPEN csr_chk(
      p_date              => l_date
     ,p_resource_id       => p_resource_id
     ,p_period_start_date => p_period_start_date
     ,p_period_end_date    => p_period_end_date
     ,p_time_recipient_id  => p_time_recipient_id
     ,p_recipient_sequence => p_recipient_sequence
     ,p_time_category_id   => p_time_category_id
     ,p_category_sequence  => p_category_sequence
    );

    FETCH csr_chk into l_approval_status;

    IF csr_chk%FOUND
    THEN
      CLOSE csr_chk;

      RETURN 'N'; --not completed approved
    END IF;

    CLOSE csr_chk;

    l_date := p_period_start_date + i;

  END LOOP;

  if g_debug then
	hr_utility.set_location(l_proc, 4);
  end if;

  RETURN 'Y';

END chk_app_approved;


FUNCTION has_valid_assign(
  p_day                IN DATE
 ,p_assignment_periods IN hxc_timecard_utilities.periods
)
RETURN BOOLEAN
IS
   i pls_integer;
Begin

  i := p_assignment_periods.first;
  Loop
     Exit when NOT p_assignment_periods.exists(i);
     IF p_day BETWEEN p_assignment_periods(i).start_date AND p_assignment_periods(i).end_date then
        return true;
     End if;
     i := p_assignment_periods.next(i);
  End loop;

  return false;

End has_valid_assign;

FUNCTION is_submitted(
  p_day         IN DATE
 ,p_resource_id IN hxc_time_building_blocks.resource_id%TYPE
)
RETURN BOOLEAN
IS
  CURSOR c_submitted(
    p_day IN DATE
   ,p_resource_id IN hxc_time_building_blocks.resource_id%TYPE
  )
  IS
    SELECT 'Y'
      FROM hxc_time_building_blocks day
          ,hxc_time_building_blocks tc
     WHERE TRUNC(day.start_time) = p_day
       AND day.scope = 'DAY'
       AND day.approval_status = 'SUBMITTED'
       AND day.resource_id = p_resource_id
       AND day.date_to = hr_general.end_of_time
       AND day.parent_building_block_id = tc.time_building_block_id
       AND day.parent_building_block_ovn = tc.object_version_number
       AND tc.scope = 'TIMECARD'
       AND tc.date_to = hr_general.end_of_time;

  l_submitted VARCHAR2(1);
BEGIN
  OPEN c_submitted(p_day, p_resource_id);
  FETCH c_submitted INTO l_submitted;

  IF c_submitted%NOTFOUND
  THEN
    CLOSE c_submitted;
    RETURN FALSE;
  END IF;

  CLOSE c_submitted;
  RETURN TRUE;
END is_submitted;

--
-------------------------- chk_submitted_days ------------------------------
--
FUNCTION chk_submitted_days(p_period_start_date date,
                            p_period_end_date   date,
                            p_resource_id       number)
RETURN VARCHAR2 IS


l_assignment_periods    hxc_timecard_utilities.periods;
l_day           DATE;
l_proc          varchar2(100) := 'HXC_APPROVAL_WF_PKG.chk_submitted_days';
--
BEGIN
--
if g_debug then
	hr_utility.set_location(l_proc, 10);
end if;
--
BEGIN
  --added by jxtan to fix mid period hiring
  l_assignment_periods := hxc_timecard_utilities.get_assignment_periods(p_resource_id);

  l_day := p_period_start_date;
  LOOP
    EXIT WHEN l_day > p_period_end_date;
    IF has_valid_assign(l_day, l_assignment_periods)
    THEN
      IF NOT is_submitted(l_day, p_resource_id)
      THEN
        RETURN 'N';
      END IF;
    END IF;
    l_day := l_day + 1;
  END LOOP;

  RETURN 'Y';
END;

END chk_submitted_days;

PROCEDURE process_appl_periods(itemtype     IN varchar2,
                               itemkey      IN varchar2,
                               actid        IN number,
                               funcmode     IN varchar2,
                               result       IN OUT NOCOPY varchar2)
IS

  CURSOR csr_get_tc_info(
    p_bld_blk_id number,
    p_ovn        number
  )
  IS
   select tc.resource_id, tc.start_time, tc.stop_time,tc.last_updated_by
     from hxc_time_building_blocks tc
    where tc.time_building_block_id = p_bld_blk_id
      and tc.object_version_number = p_ovn;


  CURSOR csr_get_appl_periods(
    p_resource_id in hxc_app_period_summary.resource_id%type
   ,p_timecard_id in hxc_timecard_summary.timecard_id%type
  )
  IS
   select aps.application_period_id,
          aps.start_time,                 -- period_start_date
          aps.stop_time,                  -- period_end_date
          aps.application_period_ovn,
          aps.time_recipient_id,
          aps.recipient_sequence,
          aps.time_category_id,
          aps.category_sequence,
          aps.approval_item_key
     from hxc_app_period_summary aps, hxc_tc_ap_links tcl
    where aps.resource_id = p_resource_id
      and aps.approval_status = 'SUBMITTED'
      and aps.notification_status = 'NOT_NOTIFIED'
      and aps.application_period_id = tcl.application_period_id
      and tcl.timecard_id = p_timecard_id;


  CURSOR c_period_notified(
    p_period_id   number
  )
  IS
   select 'N'
     from hxc_app_period_summary
    where application_period_id = p_period_id
      and approval_status = 'SUBMITTED'
      and notification_status = 'NOT_NOTIFIED';

l_notified_status    varchar2(1);
l_tc_bld_blk_id      number;
l_tc_ovn             number;
l_tc_resubmitted     varchar2(10);
l_bb_new             varchar2(10);
--
l_tc_url             varchar2(1000);
l_tc_resource_id     number;
l_tc_start_time      date;
l_tc_stop_time       date;
--
l_application        varchar2(80);
l_application_id     number;
l_time_recipient_id  number;
l_time_recipient     varchar2(150);
l_time_recipient_seq number;
--

l_approval_recipient number;
l_approver_seq       number;
--
l_day_bld_blk_id     number;
l_day_start_time     date;
l_day_stop_time      date;
l_day_ovn            number;
l_appl_period_bb_id  number;
l_appl_period_bb_ovn number;
l_period_start_date  date;
l_period_end_date    date;
--
l_cnt                number;
l_approval_style_id  number;
l_exists             varchar2(1);
l_chk_days           varchar2(1);
l_approved           varchar2(1);
l_not_notified       varchar2(1);
l_item_key           wf_items.item_key%type;
l_process_name       varchar2(30);
l_proc          varchar2(100) := 'HXC_APPROVAL_WF_PKG.process_appl_periods';
l_last_updated_by number;

l_recipient_sequence hxc_approval_comps.approval_order%TYPE;
l_time_category_id   hxc_time_categories.time_category_id%TYPE;
l_category_sequence  hxc_approval_comps.approval_order%TYPE;
l_approval_item_key wf_items.item_key%type;
l_is_blank varchar2(1) := NULL;
l_process       varchar2(1) := 'Y';

BEGIN
 l_approval_item_key := null;
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	hr_utility.set_location(l_proc, 10);
  end if;
  l_tc_bld_blk_id := wf_engine.GetItemAttrNumber
                             (itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'TC_BLD_BLK_ID');

  if g_debug then
	hr_utility.trace('Timecard BB ID is : ' || to_char(l_tc_bld_blk_id));
  end if;
  l_tc_ovn := wf_engine.GetItemAttrNumber
                             (itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'TC_BLD_BLK_OVN');

  if g_debug then
	hr_utility.trace('Timecard BB OVN is : ' || to_char(l_tc_ovn));
  end if;
  l_tc_resubmitted := wf_engine.GetItemAttrText
                             (itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'TC_RESUBMITTED');

  if g_debug then
	hr_utility.trace('Timecard Resubmitted is : ' || l_tc_resubmitted);
  end if;
  l_bb_new := wf_engine.GetItemAttrText
                             (itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'BB_NEW');

  if g_debug then
	  hr_utility.trace('Building Block New is : ' || l_bb_new);
	  hr_utility.set_location(l_proc, 20);
  end if;

  open csr_get_tc_info(l_tc_bld_blk_id,
                     l_tc_ovn);
  fetch csr_get_tc_info into l_tc_resource_id,
                           l_tc_start_time,
                           l_tc_stop_time,
		l_last_updated_by;

  if g_debug then
	  hr_utility.set_location(l_proc, 30);
	  hr_utility.trace('Timecard Resource ID is : ' || to_char(l_tc_resource_id));
	  hr_utility.trace('Timecard Start Time is : ' ||
			  to_char(l_tc_start_time, 'DD-MM-YYYY'));
	  hr_utility.trace('Timecard End Time is : ' ||
			  to_char(l_tc_stop_time, 'DD-MM-YYYY'));
  end if;
  IF csr_get_tc_info%NOTFOUND
  THEN

    if g_debug then
	hr_utility.set_location(l_proc, 40);
    end if;

    g_error_count := g_error_count + 1;
    g_error_table(g_error_count).MESSAGE_NAME := 'HXC_APR_NO_TIMECARD_INFO';
    g_error_table(g_error_count).APPLICATION_SHORT_NAME := 'HXC';

    hr_utility.set_message(809, 'HXC_APR_NO_TIMECARD_INFO');
    hr_utility.raise_error;

  END IF;

  if g_debug then
	hr_utility.set_location(l_proc, 50);
  end if;

  close csr_get_tc_info;

  l_process_name := 'HXC_APPLY_NOTIFY';

  if g_debug then
	hr_utility.set_location(l_proc, 60);
  end if;

  l_approval_style_id := get_approval_style_id(l_tc_start_time,
                                             l_tc_stop_time,
                                             l_tc_resource_id);
  --
  if g_debug then
	hr_utility.set_location(l_proc, 70);
  --
	hr_utility.trace('l_approval_style_id is : ' || to_char(l_approval_style_id));
  -- For all the application periods created for this timecard,
  -- create a workflow process to continue with the approval - to
  -- apply the approval rules and notify the approver(s).

	hr_utility.set_location(l_proc, 110);
  end if;

  open csr_get_appl_periods(l_tc_resource_id, l_tc_bld_blk_id);

  LOOP

    if g_debug then
	hr_utility.set_location(l_proc, 120);
    end if;
    fetch csr_get_appl_periods into l_appl_period_bb_id,
				   l_period_start_date,
				   l_period_end_date,
				   l_appl_period_bb_ovn,
				   l_time_recipient,
                                   l_recipient_sequence,
                                   l_time_category_id,
                                   l_category_sequence,
                                   l_approval_item_key;


    exit when csr_get_appl_periods%NOTFOUND;

    if g_debug then
	hr_utility.trace('l_appl_period_bb_id is : ' ||
                     to_char(l_appl_period_bb_id));
        hr_utility.trace('l_appl_period_bb_ovn is : ' ||
                     to_char(l_appl_period_bb_ovn));
	hr_utility.trace('l_period_start_date is : ' ||
                     to_char(l_period_start_date, 'DD-MM-YYYY'));
	hr_utility.trace('l_period_end_date is : ' ||
                     to_char(l_period_end_date, 'DD-MM-YYYY'));
	hr_utility.trace('l_time_recipient is : ' || l_time_recipient);
	hr_utility.trace('l_approval_item_key is : ' || l_approval_item_key);

	hr_utility.set_location(l_proc, 150);
    end if;
    -- Check to see if all the days in the application period have
    -- submitted days.
    --

    l_chk_days := chk_submitted_days(l_period_start_date,
                                    l_period_end_date,
                                    l_tc_resource_id);

    IF l_tc_stop_time < l_period_end_date
    AND l_tc_resubmitted <> 'YES'
    THEN
      l_process := 'N';
    END IF;

    if g_debug then
	    hr_utility.trace('Checked days:'||l_chk_days);
	    hr_utility.set_location(l_proc, 160);
    end if;
    IF l_chk_days = 'Y' AND l_process = 'Y' THEN

       if g_debug then
          hr_utility.set_location(l_proc, 170);
       end if;
       --
       -- Check to see if all applications before this one in the approval
       -- style have approved all the days in this period.
       --
       l_approved :=  chk_app_approved
          (p_resource_id        => l_tc_resource_id
           ,p_period_start_date  => l_period_start_date
           ,p_period_end_date    => l_period_end_date
           ,p_time_recipient_id  => l_time_recipient
           ,p_recipient_sequence => l_recipient_sequence
           ,p_time_category_id   => l_time_category_id
           ,p_category_sequence  => l_category_sequence);

       if g_debug then
          hr_utility.trace('All previous approved:'||l_approved);
       end if;

       IF l_approved = 'Y' THEN

          OPEN c_period_notified(l_appl_period_bb_id);
          FETCH c_period_notified INTO l_notified_status;

          IF c_period_notified%NOTFOUND THEN
             CLOSE  c_period_notified;
             if g_debug then
		hr_utility.trace('already processed ' || l_appl_period_bb_id);
             end if;
          ELSE
             CLOSE c_period_notified;
             if g_debug then
                hr_utility.set_location(l_proc, 210);
                hr_utility.trace('itemtype is : ' || itemtype);
                hr_utility.trace('l_process_name is : ' || l_process_name);
             end if;
             --
             -- Setup l_item_key from a sequence.
             --
              if l_approval_item_key is not null then
              hr_utility.trace('OTL:pass 200 - '||l_approval_item_key);

                 IF g_old_item_key.exists(l_approval_item_key) then
                   hr_utility.trace('OTL: 200: exists in g table');
                   l_is_blank := g_old_item_key(l_approval_item_key).is_diff_tc;
                 ELSE

	            l_is_blank := wf_engine.GetItemAttrText(itemtype => itemtype,
	                                                    itemkey  => l_approval_item_key  ,
	                                                    aname    => 'IS_DIFF_TC',
	                                                    ignore_notfound => true);
	         END IF;
		 hr_utility.trace('OTL:pass 210');
	      else
	         l_is_blank := null;
	      end if;

               SELECT hxc_approval_item_key_s.nextval
                 INTO l_item_key
                 FROM dual;

               update hxc_app_period_summary
                  set notification_status = 'NOTIFIED',
                      approval_item_type = itemtype,
                      approval_process_name = l_process_name,
                      approval_item_key = l_item_key
                where application_period_id = l_appl_period_bb_id
                  and application_period_ovn = l_appl_period_bb_ovn;

             if g_debug then
		hr_utility.trace('l_item_key is : ' || l_item_key);
             end if;

             wf_engine.CreateProcess(itemtype => itemtype,
                                     itemkey  => l_item_key,
                                     process  => l_process_name);
             wf_engine.setitemowner(itemtype,
                                    l_item_key,
                                    HXC_FIND_NOTIFY_APRS_PKG.get_login(p_person_id=>l_tc_resource_id,
                                                                       p_user_id => l_last_updated_by)
                                    );
             if g_debug then
		hr_utility.set_location(l_proc, 260);
             end if;
		if(item_attribute_exists(itemtype,l_item_key,'IS_DIFF_TC')) then
	 		 wf_engine.SetItemAttrText(
	  				   itemtype => itemtype,
	 				   itemkey  => l_item_key,
	 				   aname    => 'IS_DIFF_TC',
	 				   avalue   => l_is_blank);
	        else
	                 wf_engine.additemattr
	   			            (itemtype     => itemtype,
	 			             itemkey      => l_item_key,
	 			             aname        => 'IS_DIFF_TC',
	 		    	             text_value   => l_is_blank);
	        end if;

             wf_engine.SetItemAttrDate(itemtype => itemtype,
                                       itemkey  => l_item_key,
                                       aname    => 'APP_START_DATE',
                                       avalue   => l_period_start_date);

             wf_engine.SetItemAttrText(itemtype      => itemtype,
                                       itemkey       => l_item_key,
                                       aname         => 'FORMATTED_APP_START_DATE',
                                       avalue        => to_char(l_period_start_date,'YYYY/MM/DD'));
             if g_debug then
                hr_utility.set_location(l_proc, 270);
                hr_utility.trace('APP_START_DATE is : ' ||
                                 to_char(l_period_start_date, 'DD-MM-YYYY'));
             end if;

             wf_engine.SetItemAttrDate(itemtype => itemtype,
                                       itemkey  => l_item_key,
                                       aname    => 'APP_END_DATE',
                                       avalue   => l_period_end_date);

             if g_debug then
                hr_utility.set_location(l_proc, 280);
                hr_utility.trace('APP_END_DATE is : ' ||
                                 to_char(l_period_end_date, 'DD-MM-YYYY'));
             end if;

             wf_engine.SetItemAttrNumber(itemtype  => itemtype,
                                         itemkey   => l_item_key,
                                         aname     => 'APP_BB_ID',
                                         avalue    => l_appl_period_bb_id);

             if g_debug then
                hr_utility.set_location(l_proc, 290);
                hr_utility.trace('APP_BB_ID is : ' || to_char(l_appl_period_bb_id));
             end if;

             wf_engine.SetItemAttrNumber(itemtype  => itemtype,
                                         itemkey   => l_item_key,
                                         aname     => 'APP_BB_OVN',
                                         avalue    => l_appl_period_bb_ovn);

             if g_debug then
                hr_utility.set_location(l_proc, 300);
                hr_utility.trace('APP_BB_OVN is : ' ||
                                 to_char(l_appl_period_bb_ovn));
             end if;

             wf_engine.SetItemAttrNumber(itemtype  => itemtype,
                                         itemkey   => l_item_key,
                                         aname     => 'RESOURCE_ID',
                                         avalue    => l_tc_resource_id);

             if g_debug then
                hr_utility.set_location(l_proc, 310);
                hr_utility.trace('RESOURCE_ID is : ' || to_char(l_tc_resource_id));
             end if;

             wf_engine.SetItemAttrText(itemtype  => itemtype,
                                       itemkey   => l_item_key,
                                       aname     => 'TIME_RECIPIENT_ID',
                                       avalue    => l_time_recipient);

             if g_debug then
                hr_utility.set_location(l_proc, 320);
                hr_utility.trace('TIME_RECIPIENT_ID is : ' || l_time_recipient);
             end if;

             wf_engine.SetItemAttrText(itemtype   => itemtype,
                                       itemkey    => l_item_key,
                                       aname      => 'TC_RESUBMITTED',
                                       avalue     => l_tc_resubmitted);

             if g_debug then
                hr_utility.set_location(l_proc, 330);
                hr_utility.trace('TC_RESUBMITTED is : ' || l_tc_resubmitted);
             end if;

             wf_engine.SetItemAttrText(itemtype   => itemtype,
                                       itemkey    => l_item_key,
                                       aname      => 'BB_NEW',
                                       avalue     => l_bb_new);

             if g_debug then
                hr_utility.set_location(l_proc, 335);
                hr_utility.trace('BB_NEW is : ' || l_bb_new);
             end if;

             wf_engine.SetItemAttrNumber(itemtype    => itemtype,
                                         itemkey     => l_item_key,
                                         aname       => 'TC_BLD_BLK_ID',
                                         avalue      => l_tc_bld_blk_id);

             if g_debug then
		hr_utility.set_location(l_proc, 340);
	        hr_utility.trace('TC_BLD_BLK_ID is : ' || to_char(l_tc_bld_blk_id));
             end if;

             wf_engine.SetItemAttrNumber(itemtype    => itemtype,
                                         itemkey     => l_item_key,
                                         aname       => 'TC_BLD_BLK_OVN',
                                         avalue      => l_tc_ovn);

             if g_debug then
		hr_utility.set_location(l_proc, 350);
	        hr_utility.trace('TC_BLD_BLK_OVN is : ' || to_char(l_tc_ovn));
             end if;

             wf_engine.SetItemAttrNumber(itemtype    => itemtype,
                                         itemkey     => l_item_key,
                                         aname       => 'APPROVAL_STYLE_ID',
                                         avalue      => l_approval_style_id);

            l_tc_url :='JSP:OA_HTML/OA.jsp?akRegionCode=HXCAPRVPAGE&akRegionApplicationId=' ||
                '809&retainAM=Y&Action=Details&AprvTimecardId=' || l_appl_period_bb_id ||
                '&AprvTimecardOvn=' || l_appl_period_bb_ovn ||
                '&AprvStartTime=' || to_char(l_period_start_date,'YYYY/MM/DD')||
                '&AprvStopTime=' || to_char(l_period_end_date,'YYYY/MM/DD') ||
                '&AprvResourceId=' || to_char(l_tc_resource_id) ||
                '&OAFunc=HXC_TIME_ENTER'||
                '&NtfId=-&#NID-';


             wf_engine.SetItemAttrText(itemtype      => itemtype,
                                       itemkey       => l_item_key,
                                       aname         => 'HXC_TIMECARD_URL',
                                       avalue        => l_tc_url);

             --
             -- For bug 4291206, copy the previous approvers
             -- in the new process
             -- 115.92 Change.
             --
             hxc_approval_wf_util.copy_previous_approvers
                (p_item_type   => itemtype,
                 p_current_key => itemkey,
                 p_copyto_key  => l_item_key);

             -- Update attribute4 with NOTIFIED and attribute2 with the Item Key.

             if g_debug then
                hr_utility.trace('APP_BB_OVN is : ' ||
                                 to_char(l_appl_period_bb_ovn));
                hr_utility.trace('APP_BB_ID is : ' || to_char(l_appl_period_bb_id));
                hr_utility.trace('Before Update');
                hr_utility.set_location(l_proc, 360);
             end if;

               update hxc_app_period_summary
                  set notification_status = 'NOTIFIED'
                where application_period_id = l_appl_period_bb_id
                  and application_period_ovn = l_appl_period_bb_ovn;


             wf_engine.StartProcess(itemtype => itemtype,
                                    itemkey  => l_item_key);

             if g_debug then
		hr_utility.set_location(l_proc, 365);
             end if;
          END IF; -- if not notified;
       END IF; -- approved

    END IF;  -- l_chk_days

    if g_debug then
       hr_utility.set_location(l_proc, 380);
    end if;

 END LOOP;

 if g_debug then
    hr_utility.trace('OUTSIDE END LOOP');
 end if;

 close csr_get_appl_periods;

 result := '';
 return;
exception
  when others then
     -- The line below records this function call in the error system
     -- in the case of an exception.
     --
     if g_debug then
	     hr_utility.set_location(l_proc, 999);
	     --
	     hr_utility.trace('IN EXCEPTION IN process_appl_periods');
     end if;
     --
     wf_core.context('HCAPPRWF', 'hxc_approval_wf_pkg.process_appl_periods',
                     itemtype, itemkey, to_char(actid), funcmode);
     raise;
     result := '';
     return;

END process_appl_periods;



-----------------------------------------new procedures

/*
FUNCTION get_approval_style(
  p_app_id   IN hxc_time_building_blocks.time_building_block_id
 ,p_app_ovn  IN hxc_time_building_blocks.object_version_number
) RETURN hxc_approval_styles.approval_style_id%TYPE
IS
  l_approval_style hxc_approval_styles.approval_style_id%TYPE;

  CURSOR c_approval_style(
    p_app_id   IN hxc_time_building_blocks.time_building_block_id
  )
  IS
  SELECT tc.approval_style_id
    FROM hxc_timecard_summary tc
        ,hxc_timecard_application_summary ta
   WHERE ta.application_period_id = p_app_id
     AND tc.time_building_block_id = ta.time_building_block_id

BEGIN
  OPEN c_approval_style(p_app_id);
  FETCH c_approval_style INTO l_appproval_style;

  IF c_approval_style%NOTFOUND
  THEN
    CLOSE c_approval_style;

    RETURN NULL;
  END IF;

  RETURN l_approval_style;
END get_approval_style;
*/


FUNCTION get_approval_style(
  p_timecard_id   IN hxc_time_building_blocks.time_building_block_id%TYPE
 ,p_timecard_ovn  IN hxc_time_building_blocks.object_version_number%TYPE
) RETURN hxc_approval_styles.approval_style_id%TYPE
IS
  l_approval_style_id hxc_approval_styles.approval_style_id%TYPE := NULL;
/*
  CURSOR c_approval_style(
    p_timecard_id IN hxc_time_building_blocks.time_building_block_id%TYPE
  )
  IS
  select approval_style_id
    from hxc_timecard_summary
    where timecard_id = p_timecard_id;
*/
BEGIN
/*
  OPEN c_approval_style(p_timecard_id);

  FETCH c_approval_style INTO l_approval_style_id;
  IF c_approval_style%NOTFOUND
  THEN
    CLOSE c_approval_style;
  END IF;
*/
  RETURN l_approval_style_id;
END get_approval_style;


-- Procedure
--	start_approval_wf_process
--
-- Description
--	Start the Approval workflow process for the given timecard.
-- This overloaded version added by A.Rundell, version 115.49, for
-- the second generation deposit wrapper.
--
PROCEDURE start_approval_wf_process
              (p_item_type      IN            varchar2
              ,p_item_key       IN            varchar2
              ,p_process_name   IN            varchar2
              ,p_tc_bb_id       IN            number
              ,p_tc_ovn         IN            number
              ,p_tc_resubmitted IN            varchar2
              ,p_bb_new         IN            varchar2
              )is

l_proc               varchar2(70) := 'HXC_APPROVAL_WF_PKG.start_approval_wf_process';
l_defer  FND_PROFILE_OPTION_VALUES.PROFILE_OPTION_VALUE%type;

Begin
--
-- Fetch the defer option
--

l_defer := fnd_profile.value('HXC_DEFER_WORKFLOW');

if(l_defer is null) then
  l_defer := 'Y';
end if;

--
-- Initialization
--
  g_error_table.delete;
  g_error_count := 0;
  if(l_defer='Y') then
    wf_engine.threshold := -1; -- Ensures a deferred process
  else
    wf_engine.threshold := 100;
  end if;

  wf_engine.createProcess
   (itemtype => p_item_type
   ,itemkey  => p_item_key
   ,process  => p_process_name
   );

  wf_engine.SetItemAttrNumber
   (itemtype	=> p_item_type
   ,itemkey  	=> p_item_key
   ,aname 	=> 'TC_BLD_BLK_ID'
   ,avalue	=> p_tc_bb_id
   );

  wf_engine.SetItemAttrNumber
   (itemtype    => p_item_type
   ,itemkey     => p_item_key
   ,aname       => 'TC_BLD_BLK_OVN'
   ,avalue      => p_tc_ovn
   );

  wf_engine.SetItemAttrText
   (itemtype      => p_item_type
   ,itemkey       => p_item_key
   ,aname         => 'TC_RESUBMITTED'
   ,avalue        => p_tc_resubmitted
   );

  wf_engine.SetItemAttrText
   (itemtype      => p_item_type
   ,itemkey       => p_item_key
   ,aname         => 'BB_NEW'
   ,avalue        => p_bb_new
   );

  wf_engine.StartProcess
   (itemtype => p_item_type
   ,itemkey  => p_item_key
   );

  wf_engine.threshold := 50;

END start_approval_wf_process;


--
--
-- Procedure
--	start_approval_wf_process
--
-- Description
--	Start the Approval workflow process for the given timecard
--
PROCEDURE start_approval_wf_process
            (p_item_type               IN varchar2
            ,p_item_key                IN varchar2
            ,p_tc_bb_id                IN number
            ,p_tc_ovn                  IN number
            ,p_tc_resubmitted          IN varchar2
            ,p_error_table    OUT NOCOPY hxc_self_service_time_deposit.message_table
  ,p_time_building_blocks IN hxc_self_service_time_deposit.timecard_info
  ,p_time_attributes      IN hxc_self_service_time_deposit.building_block_attribute_info
  ,p_bb_new                  IN varchar2)
is
--
--
-- l_item_key                   wf_items.item_key%type;
-- l_process_name    	        varchar2(30);
--
l_process_name	     wf_process_activities.process_name%type;
--
l_proc     varchar2(100) := 'HXC_APPROVAL_WF_PKG.start_approval_wf_process';
--
BEGIN
g_debug:=hr_utility.debug_enabled;
--
if g_debug then
	hr_utility.set_location(l_proc, 10);
	--
	hr_utility.trace('Start Approval - BB ID is : ' || to_char(p_tc_bb_id));
	hr_utility.trace('Start Approval - BB OVN is : ' || to_char(p_tc_ovn));
	hr_utility.trace('Start Approval - TC RESUBMITTED is : ' || p_tc_resubmitted);
	--
end if;
-- Nulls out the error table.
--
g_error_table.delete;
g_error_count := 0;
--
-- Sets up global variables for timecard records.
--
g_time_building_blocks := p_time_building_blocks;
g_time_attributes := p_time_attributes;
--
-- Creates a new runtime process for the WF item type passed.
-- p_process_name is HXC_APPROVAL.
--
l_process_name := 'HXC_APPROVAL';
--
wf_engine.threshold := -1;
--
wf_engine.createProcess(itemtype => p_item_type,
			itemkey  => p_item_key,
			process  => l_process_name);
--
if g_debug then
	hr_utility.set_location(l_proc, 20);
end if;
--
wf_engine.SetItemAttrNumber(itemtype	=> p_item_type,
			    itemkey  	=> p_item_key,
  		 	    aname 	=> 'TC_BLD_BLK_ID',
			    avalue	=> p_tc_bb_id);
--
if g_debug then
	hr_utility.set_location(l_proc, 30);
end if;
--
wf_engine.SetItemAttrNumber(itemtype    => p_item_type,
                            itemkey     => p_item_key,
                            aname       => 'TC_BLD_BLK_OVN',
                            avalue      => p_tc_ovn);
--
if g_debug then
	hr_utility.set_location(l_proc, 40);
end if;
--
wf_engine.SetItemAttrText(itemtype      => p_item_type,
                          itemkey       => p_item_key,
                          aname         => 'TC_RESUBMITTED',
                          avalue        => p_tc_resubmitted);
--
if g_debug then
	hr_utility.set_location(l_proc, 50);
end if;
--
IF p_bb_new = 'Y' THEN
   wf_engine.SetItemAttrText(itemtype      => p_item_type,
                             itemkey       => p_item_key,
                             aname         => 'BB_NEW',
                             avalue        => 'YES');
ELSE
   wf_engine.SetItemAttrText(itemtype      => p_item_type,
                             itemkey       => p_item_key,
                             aname         => 'BB_NEW',
                             avalue        => 'NO');
END IF;
--
if g_debug then
	hr_utility.set_location(l_proc, 60);
end if;
--
wf_engine.StartProcess(itemtype => p_item_type,
		       itemkey  => p_item_key);
--
wf_engine.threshold := 50;
--
if g_debug then
	hr_utility.set_location(l_proc, 70);
end if;
--
p_error_table := g_error_table;
--

--
END start_approval_wf_process;


--
---------------------------- upd_apr_details ------------------------------
--
PROCEDURE upd_apr_details(p_app_bb_id         IN     number,
                          p_app_bb_ovn        IN     number,
                          p_approver_id       IN     number,
                          p_approved_time     IN     date,
                          p_approval_comment  IN     varchar2,
                          p_approval_status   IN     varchar2,
                          p_delegated_for     IN     varchar2) is

--
/*
cursor csr_get_attributes(p_app_bb_id  in number,
                          p_app_bb_ovn in number) is
   select attribute1, attribute2,
          attribute8, attribute9
     from hxc_time_attributes
    where time_attribute_id = (select min(time_attribute_id)
                                 from hxc_time_attribute_usages
                                where time_building_block_id  = p_app_bb_id
                                  and time_building_block_ovn = p_app_bb_ovn);
*/
--
t_attributes         hxc_time_attributes_api.timecard;
l_appl_period_bb_id  number := p_app_bb_id;
l_appl_period_bb_ovn number := p_app_bb_ovn;
l_approver_id        number := p_approver_id;
-- l_time_recipient     varchar2(150);
-- l_item_key           varchar2(150);
l_notified_status    varchar2(150) := 'FINISHED';
l_approved_time      varchar2(150)
                  := fnd_date.date_to_canonical(p_approved_time);
--                  := to_char(p_approved_time, 'DD-MM-YYYY HH:MM:SS');
l_approval_comment   varchar2(150) := p_approval_comment;
l_approved_status    varchar2(150) := p_approval_status;
l_delegated_for      varchar2(150) := p_delegated_for;
-- l_approver_sequence  varchar2(150);
--
l_time_attribute_id  number;
l_ovn                number;
--
l_proc               varchar2(100) := 'HXC_APPROVAL_WF_PKG.upd_apr_details';
--
BEGIN
g_debug:=hr_utility.debug_enabled;
--
if g_debug then
	hr_utility.set_location(l_proc, 10);
	--
	hr_utility.trace('l_appl_period_bb_id is : ' || to_char(l_appl_period_bb_id));
	hr_utility.trace('l_appl_period_bb_ovn is : ' || to_char(l_appl_period_bb_ovn));
	hr_utility.trace('l_approver_id is : ' || to_char(l_approver_id));
	hr_utility.trace('l_approved_time is : ' || l_approved_time);
	hr_utility.trace('l_approval_comment is : ' || l_approval_comment);
	hr_utility.trace('l_approved_status is : ' || l_approved_status);
	--
	hr_utility.set_location(l_proc, 20);
end if;
-- Perf Rep Fix - SQL ID :3170802
-- Added attribute_category = APPROVAL to the where clause.

update hxc_time_attributes
   set attribute4 = l_notified_status,
       attribute5 = l_approved_time,
       attribute6 = l_approval_comment,
       attribute7 = l_approved_status,
       attribute8 = l_delegated_for
 where time_attribute_id in (select time_attribute_id
                               from hxc_time_attribute_usages
                              where time_building_block_id  = p_app_bb_id
                                and time_building_block_ovn = p_app_bb_ovn)
   and attribute3 = to_char(l_approver_id)
   and attribute_category = 'APPROVAL';
--
if g_debug then
	hr_utility.set_location(l_proc, 30);
end if;
--
END upd_apr_details;
--
--
-- Don't need these procedures for now.  Not using them but leaving them
-- here in case they are needed in future.
--

--
FUNCTION code_chk (p_code IN VARCHAR2) RETURN BOOLEAN IS
--
l_package_name user_source.name%TYPE;
l_dummy VARCHAR2(1);
l_code BOOLEAN := FALSE;
--
BEGIN
--
l_package_name := SUBSTR(p_code,1,INSTR(p_code,'.')-1);
--
BEGIN
  SELECT 'Y' into l_dummy
   FROM SYS.OBJ$ O, SYS.SOURCE$ S
   WHERE O.OBJ# = S.OBJ#
      AND O.TYPE# = 11 --PACKAGE BODY
      AND O.OWNER# = USERENV('SCHEMAID')
      AND O.NAME = l_package_name
      AND S.LINE = 1;
   --
   l_code := TRUE;
   --
   EXCEPTION
      WHEN OTHERS THEN
         l_code := FALSE;
END;
--
RETURN l_code;
--
END code_chk;
------------------------ is_appr_required ----------------------------
--
PROCEDURE is_appr_required(itemtype     IN varchar2,
                           itemkey      IN varchar2,
                           actid        IN number,
                           funcmode     IN varchar2,
                           result       IN OUT NOCOPY varchar2) is
--
cursor csr_get_extension(p_time_recipient number) is
   select htr.extension_function1
     from hxc_time_recipients htr
    where htr.time_recipient_id = p_time_recipient;

cursor c_appr_comp(p_app_bb_id number,p_app_bb_ovn number)
is
select approval_comp_id
from hxc_app_period_summary
where application_period_id = p_app_bb_id
and application_period_ovn = p_app_bb_ovn;

cursor c_app_comp_pm(p_bb_id number,p_bb_ovn number)
is
select hac.approval_comp_id
from hxc_approval_comps hac,
     hxc_approval_styles has,
    hxc_time_building_blocks htb
where htb.time_building_block_id =p_bb_id
and htb.object_version_number = p_bb_ovn
and htb.approval_style_id = has.approval_style_id
and has.approval_style_id = hac.APPROVAL_STYLE_ID
and hac.approval_mechanism = 'PROJECT_MANAGER'
and hac.parent_comp_id is null
and hac.parent_comp_ovn is null;

--
l_tc_bld_blk_id      number;
l_tc_ovn             number;
l_time_recipient     varchar2(150);
l_ext_func1          varchar2(2000);
l_auto_approval_flag varchar2(1);
l_message            varchar2(2000);
l_message_table      hxc_self_service_time_deposit.message_table;
l_func_sql           varchar2(2000);
l_app_bld_blk_id     number;
l_app_ovn            number;
l_token_table        hxc_deposit_wrapper_utilities.t_simple_table;
l_exception          varchar2(10000);
l_approval_component_id  number;
--
l_proc          varchar2(100) := 'HXC_APPROVAL_WF_PKG.is_appr_required';

--
BEGIN
g_debug:=hr_utility.debug_enabled;

--
if g_debug then
	hr_utility.set_location(l_proc, 10);
end if;
--
l_app_bld_blk_id := wf_engine.GetItemAttrNumber
                             (itemtype => itemtype,
                              itemkey  => itemkey  ,
                              aname    => 'APP_BB_ID');
--
if g_debug then
	hr_utility.set_location(l_proc, 20);
end if;
--
l_app_ovn := wf_engine.GetItemAttrNumber
                             (itemtype => itemtype,
                              itemkey  => itemkey  ,
                              aname    => 'APP_BB_OVN');
--
l_tc_bld_blk_id := wf_engine.GetItemAttrNumber
                             (itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'TC_BLD_BLK_ID');
--
if g_debug then
	hr_utility.trace('Timecard BB ID is : ' || to_char(l_tc_bld_blk_id));
end if;
--
l_tc_ovn := wf_engine.GetItemAttrNumber
                             (itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'TC_BLD_BLK_OVN');
--
l_time_recipient := wf_engine.GetItemAttrText(
                                        itemtype => itemtype,
                                        itemkey  => itemkey  ,
                                        aname    => 'TIME_RECIPIENT_ID');

if g_debug then
	hr_utility.set_location(l_proc, 30);
end if;
--
-- Sets up global variables for timecard records.
--
hxc_self_service_time_deposit.get_timecard_tables(
        p_timecard_id             => l_tc_bld_blk_id
       ,p_timecard_ovn            => l_tc_ovn
       ,p_timecard_blocks         => g_time_building_blocks
       ,p_timecard_app_attributes => g_time_app_attributes
       ,p_time_recipient_id       => to_number(l_time_recipient));

if g_debug then
	hr_utility.set_location(l_proc, 40);
end if;
--
-- Get the package.procedure from the extension_function1 column
-- on hxc_time_recipients.
--
-- package.procedure(
--        p_timecard_building_blocks => g_time_building_blocks,
--        p_time_attributes          => g_time_attributes,
--        x_autoapproval_flag        => l_auto_approval_flag,
--        x_messages                 => l_message);
--
-- 115.96 change.
-- Uncommenting this code that was commented out in version 115.91

--added to support OIT desuport

open c_appr_comp(l_app_bld_blk_id,l_app_ovn);
fetch c_appr_comp into l_approval_component_id;
close c_appr_comp;

--In the case of PM mechanism, the approval comp id on the app period summary table will be
--different to the app comp id on approval style, hence we need to fetch it from using timcard id
--for non PM cases the below cursor will not be found hence it retains the app com id found in the above cursor.
--If it is PM case then the original app comp id is fetched.
open c_app_comp_pm(l_tc_bld_blk_id,l_tc_ovn);
fetch c_app_comp_pm into l_approval_component_id;
close c_app_comp_pm;

if(hxc_notification_helper.run_extensions(l_approval_component_id)) then
open csr_get_extension(to_number(l_time_recipient));
fetch csr_get_extension into l_ext_func1;
close csr_get_extension;
--
IF l_ext_func1 IS NOT NULL THEN

   if g_debug then
	hr_utility.set_location(l_proc, 50);
   end if;

   IF code_chk(l_ext_func1) THEN

      if g_debug then
	hr_utility.set_location(l_proc, 60);
      end if;
      --
      l_func_sql := 'BEGIN '||fnd_global.newline
   ||l_ext_func1 ||fnd_global.newline
   ||'(x_autoapproval_flag => :1'   ||fnd_global.newline
   ||',x_messages          => :2);' ||fnd_global.newline
   ||'END;';
      --
      EXECUTE IMMEDIATE l_func_sql
            using IN OUT l_auto_approval_flag,
                  IN OUT l_message;
      --
   END IF;
END IF;

ELSE
	l_auto_approval_flag := 'N';
END IF;
if g_debug then
	hr_utility.set_location(l_proc, 70);
end if;
--
IF l_auto_approval_flag = 'Y' THEN

   if g_debug then
	hr_utility.set_location(l_proc, 80);
   end if;
   --
   wf_engine.SetItemAttrText(itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'APPR_REQ',
                             avalue   => 'NO');
   --
END IF;

if g_debug then
	hr_utility.set_location(l_proc, 90);
end if;
--
l_exception := NULL;
--
IF l_message IS NOT NULL THEN

   if g_debug then
	hr_utility.set_location(l_proc, 100);
   end if;
   --
   l_message_table := hxc_deposit_wrapper_utilities.string_to_messages
                              (p_message_string => l_message);
   --
   IF l_message_table.COUNT <> 0 THEN
      --
      FOR i in l_message_table.first .. l_message_table.last LOOP
         --
         FND_MESSAGE.SET_NAME
           (l_message_table(i).application_short_name
           ,l_message_table(i).message_name
           );
         --
         IF l_message_table(i).message_tokens IS NOT NULL THEN
            --
            -- parse string into a more accessible form
            --
            hxc_deposit_wrapper_utilities.string_to_table('&',
                        '&'||l_message_table(i).message_tokens,
                             l_token_table);
            --
            FOR l_token in 0..(l_token_table.count/2)-1 LOOP
               --
               FND_MESSAGE.SET_TOKEN
                 (TOKEN => l_token_table(2*l_token)
                 ,VALUE => l_token_table(2*l_token+1)
                 );
               --
            END LOOP;
            --
         END IF;
         --
         l_exception := SUBSTR((l_exception||fnd_message.get),1,10000);
         --
      END LOOP;
      --
   END IF;

   if g_debug then
	hr_utility.set_location(l_proc, 110);
   end if;
   --jxtan in new implementation, comment is save in hxc_time_building_blocks
   UPDATE hxc_time_building_blocks
      SET comment_text = substr(l_exception, 1, 2000)
    WHERE time_building_block_id = l_app_bld_blk_id
      AND object_version_number = l_app_ovn;

   if g_debug then
	hr_utility.set_location(l_proc, 120);
   end if;
   --
   wf_engine.SetItemAttrText(itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'EXT_MESSAGE',
                             avalue   => l_exception);
   --
END IF;

if g_debug then
	hr_utility.set_location(l_proc, 130);
end if;
--
IF upper(wf_engine.GetItemAttrText(itemtype => itemtype,
			           itemkey  => itemkey  ,
	     		           aname    => 'APPR_REQ')) = 'YES' THEN
   --
   result := 'COMPLETE:Y';
   --
   if g_debug then
	hr_utility.set_location(l_proc, 140);
	--
	hr_utility.trace('APPR_REQ attribute is : YES');
	--
   end if;
   return;
   --
ELSE
   --
   if g_debug then
	hr_utility.set_location(l_proc, 150);
	--
	hr_utility.trace('APPR_REQ attribute is : NO');
	--
   end if;
   wf_engine.SetItemAttrText(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'APPROVAL_STATUS',
                             avalue    => 'APPROVED');
   --
   wf_engine.SetItemAttrText(itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'APR_REJ_REASON',
                             avalue   => 'AUTO_APPROVE');

   if g_debug then
	hr_utility.set_location(l_proc, 160);
	--
	--
	hr_utility.trace('APPROVAL_STATUS attribute is : APPROVED');
	--
   end if;
  --OIT Enhancement.
  --FYI Notification to WORKER on timecard AUTO APPROVE
      HXC_APPROVAL_WF_HELPER.set_notif_attribute_values
                (itemtype,
                 itemkey,
                 hxc_app_comp_notifications_api.c_action_auto_approve,
                 hxc_app_comp_notifications_api.c_recipient_worker
          );
   result := 'COMPLETE:N';
   return;
   --
END IF;
--
if g_debug then
	hr_utility.set_location(l_proc, 170);
end if;
--
exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    --
    if g_debug then
	    hr_utility.set_location(l_proc, 999);
	    --
	    hr_utility.trace('IN EXCEPTION IN is_appr_required');
	    --
    end if;
    wf_core.context('HCAPPRWF',
                    'hxc_approval_wf_pkg.is_appr_required',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;
  result := '';
  return;
--
--
END is_appr_required;
--
--
------------------------ chk_appr_rules ----------------------------
--
PROCEDURE chk_appr_rules(itemtype     IN varchar2,
                         itemkey      IN varchar2,
                         actid        IN number,
                         funcmode     IN varchar2,
                         result       IN OUT NOCOPY varchar2) is
--
cursor csr_get_tc_info(p_app_bld_blk_id number,
                       p_app_ovn        number) is
   select day.resource_id,
	  day.time_building_block_id,
          day.approval_style_id,
          max(day.object_version_number)
     from hxc_time_building_blocks day,
          hxc_time_building_blocks app
    where app.time_building_block_id = p_app_bld_blk_id
      and app.object_version_number = p_app_ovn
      and app.scope = 'APPLICATION_PERIOD'
      and app.resource_id = day.resource_id
      and day.scope = 'DAY'
      and day.start_time between app.start_time and app.stop_time
 group by day.resource_id,
	  day.time_building_block_id,
          day.approval_style_id,
          day.object_version_number
 order by day.time_building_block_id;
--
cursor csr_get_appr_rule_id(p_appr_style_id     number,
                            p_time_recipient_id varchar2) is
   select dru.time_entry_rule_id
     from hxc_data_app_rule_usages dru
    where dru.approval_style_id = p_appr_style_id
      and to_char(dru.time_recipient_id) = p_time_recipient_id;
--
-- l_tc_bld_blk_id      number;
-- l_tc_ovn             number;
l_app_bld_blk_id     number;
l_app_ovn            number;
l_tc_date_from       date;
l_tc_date_to         date;
--
l_tc_resource_id     number;
l_tc_appr_style_id   hxc_data_app_rule_usages.approval_style_id%type;
l_day_bb_id          number;
l_day_ovn            number;
l_time_recipient     varchar2(150);
l_tc_start_time      date;
l_tc_stop_time       date;
l_data_appr_rule_id  hxc_time_entry_rules.time_entry_rule_id%type;
--
l_cnt                number;
-- l_item_key           wf_items.item_key%type;
l_current_rule       varchar2(1000);
l_all_rules          varchar2(1000);
--
l_proc          varchar2(100) := 'HXC_APPROVAL_WF_PKG.chk_appr_rules';
--
BEGIN
g_debug:=hr_utility.debug_enabled;
--
if g_debug then
	hr_utility.set_location(l_proc, 10);
end if;
--
l_app_bld_blk_id := wf_engine.GetItemAttrNumber
                             (itemtype => itemtype,
                              itemkey  => itemkey  ,
                              aname    => 'APP_BB_ID');
--
if g_debug then
	hr_utility.set_location(l_proc, 20);
end if;
--
l_app_ovn := wf_engine.GetItemAttrNumber
                             (itemtype => itemtype,
                              itemkey  => itemkey  ,
                              aname    => 'APP_BB_OVN');
--
if g_debug then
	hr_utility.set_location(l_proc, 30);
end if;
--
l_time_recipient := wf_engine.GetItemAttrText
			     (itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'TIME_RECIPIENT_ID');
--
if g_debug then
	hr_utility.set_location(l_proc, 40);
	--
	hr_utility.trace('l_app_bld_blk_id is : ' || to_char(l_app_bld_blk_id));
	hr_utility.trace('l_app_ovn is : ' || to_char(l_app_ovn));
	hr_utility.trace('l_time_recipient is : ' || l_time_recipient);
	--

	hr_utility.set_location(l_proc, 70);
	--
end if;
l_tc_appr_style_id := wf_engine.GetItemAttrNumber
                             (itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'APPROVAL_STYLE_ID');
--
if g_debug then
	hr_utility.trace('l_tc_appr_style_id is : ' || to_char(l_tc_appr_style_id));
end if;
--
open csr_get_appr_rule_id(l_tc_appr_style_id,
                          l_time_recipient);
fetch csr_get_appr_rule_id into l_data_appr_rule_id;
--
if g_debug then
	hr_utility.set_location(l_proc, 80);
	--
	hr_utility.trace('l_data_appr_rule_id is : ' || to_char(l_data_appr_rule_id));
	--
end if;
IF csr_get_appr_rule_id%NOTFOUND THEN

   CLOSE csr_get_appr_rule_id;
   --
   result := 'COMPLETE:N';
   l_all_rules := 'NO_RULES';
   --
   if g_debug then
	hr_utility.set_location(l_proc, 90);
        --
        -- hr_utility.trace('Setting Status to Approved');
        --
   end if;
   -- wf_engine.SetItemAttrText(itemtype  => itemtype,
   --                           itemkey   => itemkey,
   --                           aname     => 'APPROVAL_STATUS',
   --                           avalue    => 'APPROVED');
   --
   return;
   --
ELSE
   --
   result := 'COMPLETE:Y';
   --
   if g_debug then
	hr_utility.set_location(l_proc, 100);
   end if;
   --
   l_cnt := 1;
   --
   LOOP
      --
      IF l_cnt = 1 THEN
         l_all_rules := to_char(l_data_appr_rule_id) || '|';
      ELSE
         l_all_rules := l_all_rules || to_char(l_data_appr_rule_id) || '|';
      END IF;
      --
      l_cnt := l_cnt + 1;
      --
      fetch csr_get_appr_rule_id into l_data_appr_rule_id;
      exit when csr_get_appr_rule_id%NOTFOUND;
      --
   END LOOP;

   CLOSE csr_get_appr_rule_id;
   --
   if g_debug then
	   hr_utility.set_location(l_proc, 110);
	   --
	   hr_utility.trace('l_all_rules is : ' || l_all_rules);
	   --
   end if;
END IF;
--
IF l_all_rules <> 'NO_RULES' THEN
   --
   if g_debug then
	hr_utility.set_location(l_proc, 120);
   end if;
   --
   wf_engine.SetItemAttrText(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'ALL_RULES',
                             avalue    => l_all_rules);
   --
   if g_debug then
	hr_utility.trace('ALL_RULES Attribute is : ' || l_all_rules);
   end if;
   --
END IF;
--
return;
--
exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    --
    if g_debug then
	    hr_utility.set_location(l_proc, 999);
	    --
	    hr_utility.trace('IN EXCEPTION IN chk_appr_rules');
	    --
    end if;
    wf_core.context('HCAPPRWF', 'hxc_approval_wf_pkg.chk_appr_rules',
    itemtype, itemkey, to_char(actid), funcmode);
    raise;
  result := '';
  return;
--
--
END chk_appr_rules;
--
--
------------------------ find_approval_rule ----------------------------
--
PROCEDURE find_approval_rule(itemtype     IN varchar2,
                             itemkey      IN varchar2,
                             actid        IN number,
                             funcmode     IN varchar2,
                             result       IN OUT NOCOPY varchar2) is
--
l_current_rule      varchar2(1000);
l_all_rules         varchar2(1000);
--
l_app_bld_blk_id    number;
l_app_ovn           number;
l_cnt               number;
-- l_item_key          wf_items.item_key%type;
l_proc          varchar2(100) := 'HXC_APPROVAL_WF_PKG.find_approval_rule';
--
BEGIN
g_debug:=hr_utility.debug_enabled;
--
if g_debug then
	hr_utility.set_location(l_proc, 10);
end if;
--
l_all_rules := wf_engine.GetItemAttrText(itemtype => itemtype,
                                         itemkey  => itemkey  ,
                                         aname    => 'ALL_RULES');
--
if g_debug then
	hr_utility.set_location(l_proc, 20);
	--
	hr_utility.trace('ALL_RULES is : ' || l_all_rules);
	--
end if;
l_cnt := instr(l_all_rules, '|');
--
IF l_cnt <> 0 THEN
   --
   if g_debug then
	hr_utility.set_location(l_proc, 30);
   end if;
   --
   l_current_rule := substr(l_all_rules, 1, l_cnt - 1);
   l_all_rules := replace(l_all_rules, l_current_rule || '|');
   --
   if g_debug then
	hr_utility.trace('l_current_rule is : ' || l_current_rule);
   end if;
   --
   result := 'COMPLETE:Y';
   --
ELSE
   --
   if g_debug then
	hr_utility.set_location(l_proc, 40);
   end if;
   --
   result := 'COMPLETE:N';
   --
   if g_debug then
	hr_utility.trace('No More Rules - Setting status to APPROVED');
   end if;
   --
   wf_engine.SetItemAttrText(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'APPROVAL_STATUS',
                             avalue    => 'APPROVED');


   wf_engine.SetItemAttrText(itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'APR_REJ_REASON',
                             avalue   => 'AUTO_APPROVE');
  --OIT Enhancement.
  --FYI Notification to WORKER on timecard AUTO APPROVE
   hxc_approval_wf_helper.set_notif_attribute_values
             (itemtype,
              itemkey,
              hxc_app_comp_notifications_api.c_action_auto_approve,
              hxc_app_comp_notifications_api.c_recipient_worker
             );


   return;
   --
END IF;
--
wf_engine.SetItemAttrText(itemtype  => itemtype,
                          itemkey   => itemkey,
                          aname     => 'CURRENT_RULE',
                          avalue    => l_current_rule);
--
if g_debug then
	hr_utility.set_location(l_proc, 60);
	--
	hr_utility.trace('CURRENT_RULE is : ' || l_current_rule);
	--
end if;
wf_engine.SetItemAttrText(itemtype  => itemtype,
                          itemkey   => itemkey,
                          aname     => 'ALL_RULES',
                          avalue    => l_all_rules);
--
if g_debug then
	hr_utility.set_location(l_proc, 60);
	--
	hr_utility.trace('ALL_RULES is : ' || l_all_rules);
	--
end if;
return;
--
exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    --
    if g_debug then
	    hr_utility.set_location(l_proc, 999);
	    --
	    hr_utility.trace('IN EXCEPTION IN find_approval_rule');
	    --
    end if;
    wf_core.context('HCAPPRWF', 'hxc_approval_wf_pkg.find_approval_rule',
    itemtype, itemkey, to_char(actid), funcmode);
    raise;
  result := '';
  return;
--
--
END find_approval_rule;
--
--
FUNCTION was_approved(
  p_app_period_id  IN hxc_time_building_blocks.time_building_block_id%TYPE
 ,p_app_period_ovn IN hxc_time_building_blocks.object_version_number%TYPE
)
RETURN BOOLEAN
IS
  CURSOR c_was_approved(
    p_app_period_id  IN hxc_time_building_blocks.time_building_block_id%TYPE
   ,p_app_period_ovn IN hxc_time_building_blocks.object_version_number%TYPE
  )
  IS
    SELECT 'Y'
      FROM hxc_time_building_blocks
     WHERE time_building_block_id = p_app_period_id
       AND object_version_number < p_app_period_ovn
       AND approval_status = 'APPROVED';

  l_was_approved VARCHAR2(1) := 'N';
BEGIN
  OPEN c_was_approved(p_app_period_id, p_app_period_ovn);
  FETCH c_was_approved INTO l_was_approved;
  CLOSE c_was_approved;

  IF l_was_approved = 'Y'
  THEN
    RETURN TRUE;
  END IF;

  RETURN FALSE;

END was_approved;

FUNCTION same_no_blocks(
  p_timecard_id  IN hxc_time_building_blocks.time_building_block_id%TYPE
 ,p_timecard_ovn IN hxc_time_building_blocks.object_version_number%TYPE
)
RETURN BOOLEAN
IS
  CURSOR c_no_blocks(
     p_timecard_id  IN hxc_time_building_blocks.time_building_block_id%TYPE
    ,p_timecard_ovn IN hxc_time_building_blocks.object_version_number%TYPE
  )
  IS
    SELECT COUNT(*)
      FROM hxc_time_building_blocks
    START WITH time_building_block_id = p_timecard_id
           AND object_version_number = p_timecard_ovn
    CONNECT by prior time_building_block_id =
                     parent_building_block_id
             and prior object_version_number =
                       parent_building_block_ovn;

  CURSOR c_old_tc(
     p_timecard_id  IN hxc_time_building_blocks.time_building_block_id%TYPE
    ,p_timecard_ovn IN hxc_time_building_blocks.object_version_number%TYPE
  )
  IS
    SELECT object_version_number
      FROM hxc_time_building_blocks
     WHERE time_building_block_id = p_timecard_id
       AND approval_status = 'SUBMITTED'
       AND object_version_number < p_timecard_ovn
     ORDER BY object_version_number desc;

  l_current_tc_count NUMBER;
  l_old_tc_count     NUMBER;
  l_previous_tc_ovn hxc_time_building_blocks.object_version_number%TYPE := NULL;
BEGIN
  OPEN c_old_tc(p_timecard_id, p_timecard_ovn);
  FETCH c_old_tc INTO l_previous_tc_ovn;
  CLOSE c_old_tc;

  IF l_previous_tc_ovn IS NULL
  THEN
    RETURN FALSE;
  END IF;


  OPEN c_no_blocks(p_timecard_id, p_timecard_ovn);
  FETCH c_no_blocks INTO l_current_tc_count;
  CLOSE c_no_blocks;

  OPEN c_no_blocks(p_timecard_id, l_previous_tc_ovn);
  FETCH c_no_blocks INTO l_old_tc_count;
  CLOSE c_no_blocks;

  IF l_current_tc_count = l_old_tc_count
  THEN
    RETURN TRUE;
  END IF;

  RETURN FALSE;
END same_no_blocks;



------------------------ execute_appr_rule ----------------------------
--
PROCEDURE execute_appr_rule(itemtype     IN varchar2,
                            itemkey      IN varchar2,
                            actid        IN number,
                            funcmode     IN varchar2,
                            result       IN OUT NOCOPY varchar2) is
--
cursor  csr_get_appr_rule_info(p_data_appr_rule_id number,
	                       p_end_date          date) is
   select dar.name
         ,NVL( dar.description, dar.name ) ter_message_name
         ,dar.rule_usage
         ,dar.formula_id
         ,dar.mapping_id
         ,dar.attribute1
         ,dar.attribute2
         ,dar.attribute3
         ,dar.attribute4
         ,dar.attribute5
         ,dar.attribute6
         ,dar.attribute7
         ,dar.attribute8
         ,dar.attribute9
         ,dar.attribute10
         ,dar.attribute11
         ,dar.attribute12
         ,dar.attribute13
         ,dar.attribute14
         ,dar.attribute15
         ,ff.formula_name
         ,''
     from ff_formulas_f ff
         ,hxc_time_entry_rules dar
    where dar.time_entry_rule_id = p_data_appr_rule_id
      and p_end_date between dar.start_date and dar.end_date
      and ff.formula_id(+) = dar.formula_id
      and dar.start_date BETWEEN ff.effective_start_date(+)
                             AND ff.effective_end_date(+)
 order by dar.start_date;

CURSOR csr_get_tc_dates ( p_bb_id NUMBER, p_bb_ovn NUMBER )IS
SELECT start_time, stop_time
FROM   hxc_time_building_blocks
WHERE  time_building_block_id = p_bb_id
AND    object_version_number  = p_bb_ovn;
--
l_data_appr_rule_id  hxc_time_entry_rules.time_entry_rule_id%type;
l_rule_usage         hxc_time_entry_rules.rule_usage%type;
l_formula_id         hxc_time_entry_rules.formula_id%type;
l_tc_start_date         date;
l_tc_end_date           date;
--
l_app_start_date     date;
l_app_end_date       date;
l_tc_resource_id     number;
l_tc_bld_blk_id      number;
l_tc_ovn             number;
l_current_rule       varchar2(1000);
l_all_rules          varchar2(1000);
--
l_rule_rec           hxc_time_entry_rules_utils_pkg.csr_get_rules%rowtype;
l_outputs            ff_exec.outputs_t;
l_result             varchar2(1000);
--
l_error_table        hxc_self_service_time_deposit.message_table;
l_mapping_changed    boolean;
l_bld_blk_changed    boolean;
l_changed            varchar2(10);
l_cnt                number;
l_resubmit           varchar2(10);
l_bb_new             varchar2(10);
l_appl_period_bb_id  hxc_time_building_blocks.time_building_block_id%TYPE;
l_appl_period_bb_ovn hxc_time_building_blocks.object_version_number%TYPE;
-- l_item_key        wf_items.item_key%type;
l_proc               varchar2(100) := 'HXC_APPROVAL_WF_PKG.execute_appr_rule';
--
BEGIN
g_debug:=hr_utility.debug_enabled;
--
if g_debug then
	hr_utility.set_location(l_proc, 10);
end if;
--


l_current_rule := wf_engine.GetItemAttrText(itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'CURRENT_RULE');
--
if g_debug then
	hr_utility.set_location(l_proc, 20);
end if;
--
l_app_start_date := wf_engine.GetItemAttrDate(itemtype => itemtype,
                                              itemkey  => itemkey,
                                              aname    => 'APP_START_DATE');
--
if g_debug then
	hr_utility.set_location(l_proc, 25);
end if;
--
l_app_end_date := wf_engine.GetItemAttrDate(itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'APP_END_DATE');
--
if g_debug then
	hr_utility.set_location(l_proc, 30);
end if;
--
l_tc_resource_id := wf_engine.GetItemAttrNumber(
                                        itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'RESOURCE_ID');
--
if g_debug then
	hr_utility.set_location(l_proc, 40);
end if;
--
l_tc_bld_blk_id := wf_engine.GetItemAttrNumber
                             (itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'TC_BLD_BLK_ID');
--
if g_debug then
	hr_utility.trace('Timecard BB ID is : ' || to_char(l_tc_bld_blk_id));
end if;
--
l_tc_ovn := wf_engine.GetItemAttrNumber
                             (itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'TC_BLD_BLK_OVN');
--
if g_debug then
	hr_utility.trace('Timecard BB OVN is : ' || to_char(l_tc_ovn));
end if;
--
-- Set up l_resubmit to indicate whether this is a resubmission or not.
-- (YES means it is a resubmission; NO means it is a submission).
--
l_resubmit := wf_engine.GetItemAttrText(itemtype      => itemtype,
                                        itemkey       => itemkey,
                                        aname         => 'TC_RESUBMITTED');
--
if g_debug then
	hr_utility.set_location(l_proc, 50);
end if;
--
l_bb_new := wf_engine.GetItemAttrText(itemtype      => itemtype,
                                      itemkey       => itemkey,
                                      aname         => 'BB_NEW');
--
if g_debug then
	hr_utility.set_location(l_proc, 52);
end if;
--
l_data_appr_rule_id := to_number(l_current_rule);
--
if g_debug then
	hr_utility.trace('l_current_rule is : ' || l_current_rule);
	hr_utility.trace('l_app_end_date is : ' ||
			  to_char(l_app_end_date, 'DD-MM-YYYY'));
	hr_utility.trace('l_tc_resource_id is : ' || to_char(l_tc_resource_id));
	hr_utility.trace('l_resubmit is : ' || l_resubmit);
end if;
--
open csr_get_appr_rule_info(l_current_rule, l_app_end_date);
fetch csr_get_appr_rule_info into l_rule_rec;
close csr_get_appr_rule_info;
--
if g_debug then
	hr_utility.set_location(l_proc, 60);
end if;
--
IF (l_resubmit = 'YES' AND l_rule_rec.rule_usage <> 'SUBMISSION') OR
   (l_resubmit = 'NO'  AND l_rule_rec.rule_usage <> 'RESUBMISSION') THEN
   --
   if g_debug then
	hr_utility.set_location(l_proc, 70);
   end if;
   --
   -- Apply rule
   --
   IF l_rule_rec.mapping_id IS NOT NULL THEN
      --
      -- Mapping needs to be checked.  If any of the fields in the
      -- mapping have changed, and it is a resubmission
      -- then need to approve this timecard. Set l_changed to YES
      -- or NO accordingly, and use it to decide whether the formula,
      -- if there is one, needs to be applied.
      -- Then, check for formula, since it is possible to have both
      -- a mapping and a formula.
      --
      if g_debug then
	hr_utility.set_location(l_proc, 80);
      end if;
      --
      IF l_resubmit = 'YES' THEN
         --
         if g_debug then
		hr_utility.set_location(l_proc, 90);
	 end if;
         l_appl_period_bb_id := wf_engine.GetItemAttrNumber(
                                        itemtype  => itemtype,
                                        itemkey   => itemkey,
                                        aname     => 'APP_BB_ID');

         if g_debug then
		hr_utility.trace('APP_BB_ID is : ' || to_char(l_appl_period_bb_id));
	 end if;
         l_appl_period_bb_ovn := wf_engine.GetItemAttrNumber(
                                    itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'APP_BB_OVN');

         IF NOT was_approved(l_appl_period_bb_id, l_appl_period_bb_ovn)
         THEN
           wf_engine.SetItemAttrText(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'TO_APPROVE',
                             avalue    => 'YES');

           result := '';
           RETURN;
         END IF;

         --
         -- Check to see if any values in hxc_time_building_blocks have
         -- changed for the submitted timecard.
         --
         IF l_bb_new = 'YES' THEN
            l_bld_blk_changed := TRUE;
         ELSE
            l_bld_blk_changed := same_no_blocks(l_tc_bld_blk_id, l_tc_ovn);

            IF NOT l_bld_blk_changed
            THEN
              l_bld_blk_changed := hxc_mapping_utilities.chk_bld_blk_changed (
                         p_timecard_bb_id => l_tc_bld_blk_id
                        ,p_timecard_ovn   => l_tc_ovn
                        ,p_start_date     => l_app_start_date
                        ,p_end_date       => l_app_end_date
                        ,p_last_status    => 'SUBMITTED'
                        ,p_time_bld_blks  => g_time_building_blocks);
            END IF;
         END IF;
         --
         -- Check to see if the mappings have changed for the submitted
         -- timecard, if nothing in hxc_time_building_blocks has changed.
         --
         IF l_bld_blk_changed THEN
            --
            if g_debug then
		hr_utility.set_location(l_proc, 130);
	    end if;
            --
            l_changed := 'YES';
            --
         ELSE
            --
            if g_debug then
		hr_utility.set_location(l_proc, 140);
            end if;
	    --
            l_mapping_changed := hxc_mapping_utilities.chk_mapping_changed(
                         p_mapping_id           => l_rule_rec.mapping_id
                        ,p_timecard_bb_id       => l_tc_bld_blk_id
                        ,p_timecard_ovn         => l_tc_ovn
                        ,p_start_date           => l_app_start_date
                        ,p_end_date             => l_app_end_date
                        ,p_last_status          => 'SUBMITTED'
                        ,p_time_building_blocks => g_time_building_blocks
                        ,p_time_attributes      => g_time_attributes);
            --
            if g_debug then
		hr_utility.set_location(l_proc, 120);
            end if;
	    --
            -- If there are differences, set l_changed to YES; else set to NO.
            --
            IF l_mapping_changed THEN
               --
               if g_debug then
		hr_utility.set_location(l_proc, 130);
               end if;
	       --
               l_changed := 'YES';
               --
            ELSE
               --
               if g_debug then
		hr_utility.set_location(l_proc, 140);
               end if;
	       --
               l_changed := 'NO';
               --
            END IF;
            --
         END IF;
         --
      ELSE      -- not a resubmission, so fields in mapping are new.
         --
         -- Set l_changed to YES
         --
         if g_debug then
		hr_utility.set_location(l_proc, 150);
         end if;
	 --
         l_changed := 'YES';
         --
      END IF;
      --
   ELSE
      --
      -- No Mapping ID, but there might still be a formula so set
      -- l_changed to YES
      --
      if g_debug then
	hr_utility.set_location(l_proc, 160);
      end if;
      --
      l_changed := 'NO'; -- GPM v115.48 WWB 2724576
      --
   END IF;
   --
   if g_debug then
	hr_utility.set_location(l_proc, 170);
   end if;
   --
   -- Check to see is a formula needs to be applied.
   --
   IF (l_rule_rec.formula_id IS NOT NULL AND l_changed = 'NO') -- GPM v115.48 WWB 2724576
   THEN
      --
      if g_debug then
	      hr_utility.set_location(l_proc, 180);
	      --
	      hr_utility.trace('l_formula_name is : ' || l_rule_rec.formula_name);
	      --
	      hr_utility.set_location(l_proc, 190);
      end if;
      --
      -- call execute approval formula
      --

	-- get tc period start and stop times

      OPEN  csr_get_tc_dates ( l_tc_bld_blk_id, l_tc_ovn );
      FETCH csr_get_tc_dates INTO l_tc_start_date, l_tc_end_date;
      CLOSE csr_get_tc_dates;

      l_error_table.delete;
      --
	-- GPM v115.21
      l_result := hxc_ff_dict.execute_approval_formula(
                      p_resource_id          => l_tc_resource_id
                     ,p_period_start_date    => l_app_start_date
                     ,p_period_end_date	     => l_app_end_date
                     ,p_tc_period_start_date => l_tc_start_date
                     ,p_tc_period_end_date   => l_tc_end_date
                     ,p_rule_rec             => l_rule_rec
	             ,p_message_table        => l_error_table);
      --
      IF upper(l_result) = 'Y' THEN
         l_result := 'YES';
      END IF;
      --
      IF upper(l_result) = 'N' THEN
         l_result := 'NO';
      END IF;
      --
      IF upper(l_result) <> 'YES' AND upper(l_result) <> 'NO' THEN
         hr_utility.raise_error;
      END IF;
      --
      IF l_error_table.count > 0 THEN
         hr_utility.set_message(809, l_error_table(1).message_name);
         hr_utility.raise_error;
      END IF;
      --
      wf_engine.SetItemAttrText(itemtype  => itemtype,
                                itemkey   => itemkey,
                                aname     => 'TO_APPROVE',
                                avalue    => upper(l_result));
      --
      if g_debug then
	hr_utility.trace('TO_APPROVE is : ' || l_result);
      end if;
      --
   ELSE
      --
      -- Set TO_APPROVE to l_changed.
      --
      if g_debug then
	hr_utility.set_location(l_proc, 230);
      end if;
      --
      wf_engine.SetItemAttrText(itemtype  => itemtype,
                                itemkey   => itemkey,
                                aname     => 'TO_APPROVE',
                                avalue    => l_changed);
      --
      if g_debug then
	hr_utility.trace('TO_APPROVE is : ' || l_changed);
      end if;
      --
   END IF;
   --
ELSE
   --
   -- Set TO_APPROVE attribute to YES since the rule does not apply.
   --
   if g_debug then
	hr_utility.set_location(l_proc, 240);
   end if;
   --
   -- Modifying the 'TO_APPROVE' value from 'NO' to 'YES' and Commenting out the following code for bug#3497011.

/*   wf_engine.SetItemAttrText(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'TO_APPROVE',
                             avalue    => 'NO');
   --
   if g_debug then
	hr_utility.trace('TO_APPROVE is : NO');
   end if;	*/

   wf_engine.SetItemAttrText(itemtype  => itemtype,
                             itemkey   => itemkey,
                             aname     => 'TO_APPROVE',
                             avalue    => 'YES');
   --
   if g_debug then
	hr_utility.trace('TO_APPROVE is : YES');
   end if;--
END IF;
--
if g_debug then
	hr_utility.set_location(l_proc, 250);
end if;
--
--
result := '';
return;
--
exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    if g_debug then
	    hr_utility.set_location(l_proc, 999);
	    --
	    hr_utility.trace('IN EXCEPTION IN execute_appr_rule');
    end if;
    --
    wf_core.context('HCAPPRWF', 'hxc_approval_wf_pkg.execute_appr_rule',
                     itemtype, itemkey, to_char(actid), funcmode);
    raise;
  result := '';
  return;
--
--
END execute_appr_rule;
--
--
------------------------ chk_approval_req ----------------------------
--
PROCEDURE chk_approval_req(itemtype     IN varchar2,
                           itemkey      IN varchar2,
                           actid        IN number,
                           funcmode     IN varchar2,
                           result       IN OUT NOCOPY varchar2) is
--
l_current_rule      varchar2(1000);
l_all_rules         varchar2(1000);
l_to_approve        varchar2(1000);
--
l_cnt               number;
-- l_item_key       wf_items.item_key%type;
l_proc          varchar2(100) := 'HXC_APPROVAL_WF_PKG.chk_approval_req';
--
BEGIN
g_debug:=hr_utility.debug_enabled;
--
if g_debug then
	hr_utility.set_location(l_proc, 10);
end if;
--
l_to_approve := wf_engine.GetItemAttrText(itemtype => itemtype,
                                          itemkey  => itemkey  ,
                                          aname    => 'TO_APPROVE');
--
if g_debug then
	hr_utility.set_location(l_proc, 20);
end if;
--
if g_debug then
	hr_utility.trace('l_to_approve is : ' || l_to_approve);
end if;
--
IF l_to_approve = 'YES' THEN
   --
   if g_debug then
	hr_utility.set_location(l_proc, 30);
   end if;
   --
   result := 'COMPLETE:Y';
   --
   return;
   --
ELSE
   --
   if g_debug then
	hr_utility.set_location(l_proc, 40);
   end if;
   --
   result := 'COMPLETE:N';
   --
   return;
   --
END IF;
--
exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    --
    if g_debug then
	    hr_utility.set_location(l_proc, 999);
	    --
	    hr_utility.trace('IN EXCEPTION IN chk_approval_req');
    end if;
    --
    wf_core.context('HCAPPRWF', 'hxc_approval_wf_pkg.chk_approval_req',
    itemtype, itemkey, to_char(actid), funcmode);
    raise;
    --
  result := '';
  return;
--
--
END chk_approval_req;
--
--------------------------- get_override -------------------------------
--
FUNCTION get_override(p_timecard_bb_id NUMBER
                     ,p_timecard_ovn   NUMBER) RETURN NUMBER IS
--
l_return hxc_time_building_blocks.resource_id%TYPE;
--
cursor csr_get_override_id is
   select to_number(ta.attribute10)
     from hxc_time_attributes ta,
          hxc_time_attribute_usages tau,
          hxc_time_building_blocks tbb
    where tbb.time_building_block_id = p_timecard_bb_id
      and tbb.object_version_number  = p_timecard_ovn
      and tbb.time_building_block_id = tau.time_building_block_id
      and tbb.object_version_number  = tau.time_building_block_ovn
      and ta.time_attribute_id  = tau.time_attribute_id
      and ta.attribute_category = 'APPROVAL';
--
--
BEGIN
--
OPEN	csr_get_override_id;
FETCH	csr_get_override_id INTO l_return;
CLOSE	csr_get_override_id;
--
RETURN l_return;
--
end get_override;

PROCEDURE is_different_time_category (itemtype     IN varchar2,
                           itemkey      IN varchar2,
                           actid        IN number,
                           funcmode     IN varchar2,
                           result       IN OUT NOCOPY varchar2) is

l_is_blank varchar2(1);
l_total_hours number;
l_app_bb_id number;
l_approval_mechansim varchar2(20);

begin

l_is_blank := wf_engine.GetItemAttrText(itemtype => itemtype,
                                          itemkey  => itemkey  ,
                                          aname    => 'IS_DIFF_TC',
                                          ignore_notfound => true
                                          );

l_app_bb_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                          itemkey  => itemkey  ,
                                          aname    => 'APP_BB_ID');

if l_is_blank = 'Y' then

l_total_hours:= HXC_FIND_NOTIFY_APRS_PKG.category_timecard_hrs(l_app_bb_id,'');

 wf_engine.SetItemAttrNumber(
  			      itemtype => itemtype,
  			      itemkey  => itemkey,
  			      aname    => 'TOTAL_TC_HOURS',
  			      avalue   => l_total_hours);

		result := 'COMPLETE:Y';
else

		result := 'COMPLETE:N';

end if;

end is_different_time_category;
--
--
end hxc_approval_wf_pkg;

/
