--------------------------------------------------------
--  DDL for Package Body HXC_BLOCK_COLLECTION_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_BLOCK_COLLECTION_UTILS" AS
/* $Header: hxcbkcout.pkb 120.6 2006/06/13 23:38:00 arundell noship $ */

   C_END_OF_DAY CONSTANT NUMBER := .999988426;

   type block_id_list is table of hxc_time_building_blocks.time_building_block_id%type;
   type block_ovn_list is table of hxc_time_building_blocks.object_version_number%type;

   Procedure append_to_list
     (p_list1 in         block_id_list,
      p_list2 in out nocopy block_id_list,
      p_list3 in         block_ovn_list,
      p_list4 in out nocopy block_ovn_list) is

     l_id_idx binary_integer;

   begin
     l_id_idx := p_list1.first;
     Loop
       Exit when not p_list1.exists(l_id_idx);
       p_list2.extend;
       p_list2(p_list2.last) := p_list1(l_id_idx);
       p_list4.extend;
       p_list4(p_list4.last) := p_list3(l_id_idx);
       l_id_idx := p_list1.next(l_id_idx);
     End Loop;

   end append_to_list;

   Procedure load_attributes
     (p_block_id_list      in         block_id_list,
      p_block_ovn_list     in         block_ovn_list,
      p_load_template_attributes    in         varchar2,
      p_attributes      in out NOCOPY hxc_attribute_table_type
      ) is

     cursor c_attribute_type_info
          (p_block_id                 in hxc_time_building_blocks.time_building_block_id%type,
           p_block_ovn                in hxc_time_building_blocks.object_version_number%type,
           p_load_template_attributes in         varchar2) is
       select hxc_attribute_type
           (ta.TIME_ATTRIBUTE_ID,
            p_block_id,
            ta.ATTRIBUTE_CATEGORY,
            ta.ATTRIBUTE1,
            ta.ATTRIBUTE2,
            ta.ATTRIBUTE3,
            ta.ATTRIBUTE4,
            ta.ATTRIBUTE5,
            ta.ATTRIBUTE6,
            ta.ATTRIBUTE7,
            ta.ATTRIBUTE8,
            ta.ATTRIBUTE9,
            ta.ATTRIBUTE10,
            ta.ATTRIBUTE11,
            ta.ATTRIBUTE12,
            ta.ATTRIBUTE13,
            ta.ATTRIBUTE14,
            ta.ATTRIBUTE15,
            ta.ATTRIBUTE16,
            ta.ATTRIBUTE17,
            ta.ATTRIBUTE18,
            ta.ATTRIBUTE19,
            ta.ATTRIBUTE20,
            ta.ATTRIBUTE21,
            ta.ATTRIBUTE22,
            ta.ATTRIBUTE23,
            ta.ATTRIBUTE24,
            ta.ATTRIBUTE25,
            ta.ATTRIBUTE26,
            ta.ATTRIBUTE27,
            ta.ATTRIBUTE28,
            ta.ATTRIBUTE29,
            ta.ATTRIBUTE30,
            ta.BLD_BLK_INFO_TYPE_ID,
            ta.OBJECT_VERSION_NUMBER,
            'N',
            'N',
            bbit.BLD_BLK_INFO_TYPE,
            'N',
            p_block_ovn)
       from hxc_time_attribute_usages tau,
            hxc_bld_blk_info_types bbit,
            hxc_time_attributes ta
      where tau.time_building_block_id = p_block_Id
        and tau.time_building_block_ovn = p_block_ovn
        and tau.time_attribute_id = ta.time_attribute_id
        and (ta.attribute_category <> nvl(decode(p_load_template_attributes,'Y','TEMPLATES'),'$Sys_deF$')
             and
             ta.attribute_category <> nvl(decode(p_load_template_attributes,'Y','REASON'),'$Sys_deF$')
             and
             ta.attribute_category <> nvl(decode(p_load_template_attributes,'Y','SECURITY'),'$Sys_deF$')
             )
          and ta.bld_blk_info_type_id = bbit.bld_blk_info_type_id;

     l_attributes hxc_attribute_table_type;
     l_attribute_index binary_integer;
     l_block_index binary_integer;

   Begin
     if(p_attributes is null) then
       p_attributes := hxc_attribute_table_type();
     end if;
     l_attributes := hxc_attribute_table_type();
     l_block_index := p_block_id_list.first;
     Loop
       Exit when not p_block_id_list.exists(l_block_index);
       open  c_attribute_type_info(p_block_id_list(l_block_index),p_block_ovn_list(l_block_index),p_load_template_attributes);
     fetch c_attribute_type_info bulk collect into l_attributes;
     close c_attribute_type_info;
       l_attribute_index := l_attributes.first;
       Loop
      Exit when not l_attributes.exists(l_attribute_index);
      p_attributes.extend;
      p_attributes(p_attributes.last) := l_attributes(l_attribute_index);
      l_attribute_index := l_attributes.next(l_attribute_index);
       End Loop;
       l_block_index := p_block_id_list.next(l_block_index);
     End Loop;

   End load_attributes;

   Procedure load_top_level_block
     (p_top_level_block_id   in            hxc_time_building_blocks.time_building_block_id%type,
      p_blocks               in out nocopy hxc_block_table_type,
      p_top_level_start_date in out nocopy date,
      p_top_level_stop_date  in out nocopy date
      ) is

     CURSOR c_block_type_info
       (p_block_id in hxc_time_building_blocks.time_building_block_id%type) is
       select hxc_block_type
          (time_building_block_id,
           type,
           measure,
           unit_of_measure,
           fnd_date.date_to_canonical(start_time),
           fnd_date.date_to_canonical(stop_time),
           parent_building_block_id,
           'N',
           scope,
           object_version_number,
           approval_status,
           resource_id,
           resource_type,
           approval_style_id,
           fnd_date.date_to_canonical(date_from),
           fnd_date.date_to_canonical(date_to),
           comment_text,
           parent_building_block_ovn,
           'N',
           'N',
           'N',
           application_set_id,
           translation_display_key
           )
      from hxc_time_building_blocks
     where time_building_block_id = p_block_id
       and date_to = hr_general.end_of_time;

   Begin
      if(p_blocks is null) then
         p_blocks := hxc_block_table_type();
      end if;
      p_blocks.extend;
      open c_block_type_info(p_top_level_block_id);
      fetch c_block_type_info into p_blocks(1);
      if(c_block_type_info%notfound) then
         p_blocks := null;
      else
         p_top_level_start_date := fnd_date.canonical_to_date(p_blocks(1).start_time);
         p_top_level_stop_date := fnd_date.canonical_to_date(p_blocks(1).stop_time);
      end if;
      close c_block_type_info;
   End load_top_level_block;

   Procedure load_app_period_days
      (p_top_level_block_id  in            hxc_time_building_blocks.time_building_block_id%type,
       p_top_level_block_ovn in            hxc_time_building_blocks.object_version_number%type,
       p_start_time          in            date,
       p_stop_time           in            date,
       p_day_id_list            out nocopy block_id_list,
       p_day_ovn_list           out nocopy block_ovn_list,
       p_blocks              in out nocopy hxc_block_table_type,
       p_attributes          in out nocopy hxc_attribute_table_type
       ) is

      CURSOR c_block_type_info is
        select hxc_block_type
               (days.time_building_block_id,
                days.type,
                days.measure,
                days.unit_of_measure,
                fnd_date.date_to_canonical(days.start_time),
                fnd_date.date_to_canonical(days.stop_time),
                p_top_level_block_id,
                'N',
                days.scope,
                days.object_version_number,
                days.approval_status,
                days.resource_id,
                days.resource_type,
                days.approval_style_id,
                fnd_date.date_to_canonical(days.date_from),
                fnd_date.date_to_canonical(days.date_to),
                days.comment_text,
                p_top_level_block_ovn,
                'N',
                'N',
                'N',
                days.application_set_id,
                days.translation_display_key),
               days.time_building_block_id,
               days.object_version_number
          from hxc_time_building_blocks days,
               hxc_time_building_blocks top_level
         where top_level.time_building_block_id = p_top_level_block_id
           and top_level.object_version_number = p_top_level_block_ovn
           and days.resource_id = top_level.resource_id
           and trunc(days.start_time) between trunc(top_level.start_time) and trunc(top_level.stop_time)
           and days.scope = 'DAY'
           and days.date_to = hr_general.end_of_time
           and days.start_time >= p_start_time
           and days.stop_time <= p_stop_time
           and exists
         (select 'Y'
            from hxc_time_building_blocks timecard_check
           where timecard_check.scope = 'TIMECARD'
             and timecard_check.resource_id = days.resource_id
             and timecard_check.date_to = hr_general.end_of_time
             and timecard_check.time_building_block_id = days.parent_building_block_id
             and timecard_check.object_version_number = days.parent_building_block_ovn
                 )
         order by days.start_time;

      l_day_blocks hxc_block_table_type;
      l_day_index pls_integer;

   Begin

      l_day_blocks := hxc_block_table_type();
      open c_block_type_info;
      fetch c_block_type_info bulk collect into l_day_blocks,p_day_id_list,p_day_ovn_list;
      close c_block_type_info;
      l_day_index := l_day_blocks.first;
      Loop
         Exit when not l_day_blocks.exists(l_day_index);
         p_blocks.extend;
         p_blocks(p_blocks.last) := l_day_blocks(l_day_index);
         l_day_index := l_day_blocks.next(l_day_index);
      End Loop;

   End load_app_period_days;

   Procedure load_days
     (p_top_level_block_id    in         hxc_time_building_blocks.time_building_block_id%type,
      p_top_level_block_ovn   in         hxc_time_building_blocks.object_version_number%type,
      p_day_id_list           out nocopy block_id_list,
      p_day_ovn_list          out nocopy block_ovn_list,
      p_blocks          in out nocopy hxc_block_table_type,
      p_attributes         in out nocopy hxc_attribute_table_type
      ) is

     CURSOR c_block_type_info is
       select hxc_block_type
           (days.time_building_block_id,
            days.type,
            days.measure,
            days.unit_of_measure,
            fnd_date.date_to_canonical(days.start_time),
            fnd_date.date_to_canonical(days.stop_time),
            days.parent_building_block_id,
            'N',
            days.scope,
            days.object_version_number,
            days.approval_status,
            days.resource_id,
            days.resource_type,
            days.approval_style_id,
            fnd_date.date_to_canonical(days.date_from),
            fnd_date.date_to_canonical(days.date_to),
            days.comment_text,
            days.parent_building_block_ovn,
            'N',
            'N',
            'N',
            days.application_set_id,
            days.translation_display_key),
           days.time_building_block_id,
           days.object_version_number
      from hxc_time_building_blocks days,
           hxc_time_building_blocks top_level
     where top_level.time_building_block_id = p_top_level_block_id
       and top_level.object_version_number = p_top_level_block_ovn
       and days.parent_building_block_id = top_level.time_building_block_Id
       and days.parent_building_block_ovn = top_level.object_version_number
       and days.object_version_number = (select max(object_version_number)
                                           from hxc_time_building_blocks days_ovn
                                          where days_ovn.time_building_block_id = days.time_building_block_id
                                            and days_ovn.parent_building_block_id = top_level.time_building_block_Id
                                            and days_ovn.parent_building_block_ovn = top_level.object_version_number)
     order by days.start_time;

     l_day_blocks hxc_block_table_type;
     l_day_index pls_integer;
   Begin
     l_day_blocks := hxc_block_table_type();
     open c_block_type_info;
     fetch c_block_type_info bulk collect into l_day_blocks,p_day_id_list,p_day_ovn_list;
     close c_block_type_info;
     l_day_index := l_day_blocks.first;
     Loop
       Exit when not l_day_blocks.exists(l_day_index);
       p_blocks.extend;
       p_blocks(p_blocks.last) := l_day_blocks(l_day_index);
       l_day_index := l_day_blocks.next(l_day_index);
     End Loop;

   End load_days;

  Procedure add_missing_days
     (p_blocks     in out nocopy hxc_block_table_type,
      p_start_time in            date,
      p_stop_time  in            date
      ) is

     l_index           pls_integer;
     l_curr_day        date;
     l_day             hxc_block_type;
     l_temp_blocks     hxc_block_table_type;
     l_day_diff        number;

  Begin
     l_temp_blocks := hxc_block_table_type();
     -- Check for days missing at the start
     l_day_diff := trunc(fnd_date.canonical_to_date(p_blocks(2).start_time)) - trunc(p_start_time);
     l_day := p_blocks(2);
     if(l_day_diff > 0) then
        l_curr_day := p_start_time;
        -- Missing days from the front of the period.  Add them, preserving the order.
        l_temp_blocks.extend();
        l_temp_blocks(1) := p_blocks(1);
        For l_index in 2..(1+l_day_diff) Loop
           l_day.start_time := fnd_date.date_to_canonical(l_curr_day);
           l_day.stop_time := fnd_date.date_to_canonical((l_curr_day + C_END_OF_DAY));
           l_day.time_building_block_id := -2-l_index;
           l_temp_blocks.extend();
           l_temp_blocks(l_index) := l_day;
           l_curr_day := l_curr_day + 1;
        End Loop;
        -- append the existing days
        l_index := 2;
        Loop
           Exit when not p_blocks.exists(l_index);
           l_temp_blocks.extend();
           l_temp_blocks(l_temp_blocks.last) := p_blocks(l_index);
           l_index := p_blocks.next(l_index);
        End Loop;
     end if;
     if(l_temp_blocks.count>0) then
        p_blocks := l_temp_blocks;
     end if;
     -- Check for days missing at the end
     l_temp_blocks := hxc_block_table_type();
     l_day_diff := trunc(p_stop_time) - trunc(fnd_date.canonical_to_date(p_blocks(p_blocks.last).stop_time));
     l_day := p_blocks(2);
     if(l_day_diff > 0) then
        -- preppend the existing days
        l_index := p_blocks.first;
        Loop
           Exit when not p_blocks.exists(l_index);
           l_temp_blocks.extend();
           l_temp_blocks(l_temp_blocks.last) := p_blocks(l_index);
           l_index := p_blocks.next(l_index);
        End Loop;
        l_curr_day := (fnd_date.canonical_to_date(p_blocks(p_blocks.last).start_time)+1);
        For l_index in (l_temp_blocks.last+1) .. (l_temp_blocks.last+l_day_diff) Loop
           l_day.start_time := fnd_date.date_to_canonical(l_curr_day);
           l_day.stop_time := fnd_date.date_to_canonical((l_curr_day + C_END_OF_DAY));
           l_day.time_building_block_id := -2-l_index;
           l_temp_blocks.extend();
           l_temp_blocks(l_index) := l_day;
           l_curr_day := l_curr_day + 1;
        End Loop;
     end if;
     if(l_temp_blocks.count >0) then
        p_blocks := l_temp_blocks;
     end if;
  End add_missing_days;

  Procedure load_app_period_details
    (p_app_period_id   in            hxc_time_building_blocks.time_building_block_id%type,
     p_start_time      in            date,
     p_stop_time       in            date,
     p_detail_id_list  in out nocopy block_id_list,
     p_detail_ovn_list in out nocopy block_ovn_list,
     p_blocks          in out NOCOPY hxc_block_table_type,
     p_attributes      in out NOCOPY hxc_attribute_table_type,
     p_row_data           out NOCOPY hxc_trans_display_key_utils.translation_row_used,
     p_missing_rows    in out NOCOPY boolean) is

     CURSOR c_block_type_info
           (p_app_period_id  in hxc_time_building_blocks.time_building_block_id%type)
     is
       select hxc_block_type
              (details.time_building_block_id,
               details.type,
               details.measure,
               details.unit_of_measure,
               fnd_date.date_to_canonical(details.start_time),
               fnd_date.date_to_canonical(details.stop_time),
               details.parent_building_block_id,
               'N',
               details.scope,
               details.object_version_number,
               details.approval_status,
               details.resource_id,
               details.resource_type,
               details.approval_style_id,
               fnd_date.date_to_canonical(details.date_from),
               fnd_date.date_to_canonical(details.date_to),
               details.comment_text,
               details.parent_building_block_ovn,
               'N',
               'N',
               'N',
               details.application_set_id,
               details.translation_display_key),
              details.time_building_block_id,
              details.object_version_number
         from hxc_time_building_blocks details,
              hxc_time_building_blocks days,
              hxc_ap_detail_links adl
        where details.time_building_block_id = adl.time_building_block_id
          and details.object_version_number = adl.time_building_block_ovn
          and days.start_time >= p_start_time
          and days.stop_time <= p_stop_time
          and days.time_building_block_id = details.parent_building_block_id
          and days.object_version_number = details.parent_building_block_ovn
          and adl.application_period_id = p_app_period_id
          and details.date_to = hr_general.end_of_time;

     l_detail_blocks hxc_block_table_type;
     l_detail_index pls_integer;

   Begin

      l_detail_blocks := hxc_block_table_type();
      open c_block_type_info(p_app_period_id);
      fetch c_block_type_info bulk collect into l_detail_blocks,p_detail_id_list, p_detail_ovn_list;
      close c_block_type_info;

      l_detail_index := l_detail_blocks.first;
      Loop
         Exit when not l_detail_blocks.exists(l_detail_index);
         p_blocks.extend;
         p_blocks(p_blocks.last) := l_detail_blocks(l_detail_index);
         l_detail_index := l_detail_blocks.next(l_detail_index);
         if(p_missing_rows) then
            hxc_trans_display_key_utils.set_row_data
               (p_blocks(p_blocks.last).translation_display_key,
                p_row_data);
         end if;
      End Loop;

      If (p_missing_rows) then
         p_missing_rows := hxc_trans_display_key_utils.missing_rows(p_row_data);
      end if;

   End load_app_period_details;

   Procedure load_details
    (p_day_id_list     in     block_id_list,
     p_day_ovn_list    in     block_ovn_list,
     p_detail_id_list  in out nocopy block_id_list,
     p_detail_ovn_list in out nocopy block_ovn_list,
     p_blocks       in out NOCOPY hxc_block_table_type,
     p_attributes      in out NOCOPY hxc_attribute_table_type,
     p_row_data        out NOCOPY hxc_trans_display_key_utils.translation_row_used,
     p_missing_rows    in out NOCOPY boolean) is

     CURSOR c_block_type_info
           (p_day_id in hxc_time_building_blocks.time_building_block_id%type,
            p_day_ovn in hxc_time_building_blocks.object_version_number%type)
     is
       select hxc_block_type
           (details.time_building_block_id,
            details.type,
            details.measure,
            details.unit_of_measure,
            fnd_date.date_to_canonical(details.start_time),
            fnd_date.date_to_canonical(details.stop_time),
            details.parent_building_block_id,
            'N',
            details.scope,
            details.object_version_number,
            details.approval_status,
            details.resource_id,
            details.resource_type,
            details.approval_style_id,
            fnd_date.date_to_canonical(details.date_from),
            fnd_date.date_to_canonical(details.date_to),
            details.comment_text,
            details.parent_building_block_ovn,
            'N',
            'N',
            'N',
            details.application_set_id,
            details.translation_display_key)
      from hxc_time_building_blocks details
     where details.parent_building_block_id = p_day_id
       and details.parent_building_block_ovn = p_day_ovn
       and details.date_to = hr_general.end_of_time;

     l_day_index binary_integer;
     l_detail_blocks hxc_block_table_type;
     l_detail_index pls_integer;

   Begin
     p_detail_id_list := block_id_list();
     p_detail_ovn_list := block_ovn_list();
     l_detail_blocks := hxc_block_table_type();
     --
     -- When can use forall and bulkcollect together
     -- in SQL statements, change this to use forall!
     --
     l_day_index := p_day_id_list.first;
     Loop
       Exit when not p_day_id_list.exists(l_day_index);
       open c_block_type_info(p_day_id_list(l_day_index),p_day_ovn_list(l_day_index));
       fetch c_block_type_info bulk collect into l_detail_blocks;
       close c_block_type_info;
       l_detail_index := l_detail_blocks.first;
       Loop
      Exit when not l_detail_blocks.exists(l_detail_index);
      p_blocks.extend;
      p_blocks(p_blocks.last) := l_detail_blocks(l_detail_index);
      p_detail_id_list.extend;
      p_detail_id_list(p_detail_id_list.last) := p_blocks(p_blocks.last).time_building_block_id;
      p_detail_ovn_list.extend;
      p_detail_ovn_list(p_detail_ovn_list.last) := p_blocks(p_blocks.last).object_version_number;
      l_detail_index := l_detail_blocks.next(l_detail_index);
      if(p_missing_rows) then
         hxc_trans_display_key_utils.set_row_data
            (p_blocks(p_blocks.last).translation_display_key,
          p_row_data);
      end if;
       End Loop;
       l_day_index := p_day_id_list.next(l_day_index);
     End Loop;
     If (p_missing_rows) then
     p_missing_rows := hxc_trans_display_key_utils.missing_rows(p_row_data);
     end if;
   End load_details;

   PROCEDURE load_collection
     (p_top_level_block_id    in         hxc_time_building_blocks.time_building_block_id%type,
      p_load_template_attributes      in         varchar2,
      p_blocks             out NOCOPY hxc_block_table_type,
      p_attributes            out NOCOPY hxc_attribute_table_type,
      p_top_level_start_date     out NOCOPY date,
      p_top_level_stop_date      out NOCOPY date,
      p_row_data           out NOCOPY hxc_trans_display_key_utils.translation_row_used,
      p_missing_rows       in out NOCOPY boolean
      ) is

     l_day_id_list block_id_list;
     l_day_ovn_list block_ovn_list;
     l_detail_id_list block_id_list;
     l_detail_ovn_list block_ovn_list;

   Begin

    load_top_level_block
       (p_top_level_block_id,
     p_blocks,
     p_top_level_start_date,
     p_top_level_stop_date);

    if(p_blocks is not null) then
      load_days
     (p_top_level_block_id,
      p_blocks(1).object_version_number,
      l_day_id_list,
      l_day_ovn_list,
      p_blocks,
      p_attributes);
      load_details
     (l_day_id_list,
      l_day_ovn_list,
      l_detail_id_list,
      l_detail_ovn_list,
      p_blocks,
      p_attributes,
      p_row_data,
      p_missing_rows);
      l_detail_id_list.extend;
      l_detail_id_list(l_detail_id_list.last) := p_blocks(1).time_building_block_id;
      l_detail_ovn_list.extend;
      l_detail_ovn_list(l_detail_ovn_list.last) := p_blocks(1).object_version_number;

      append_to_list(l_day_id_list,l_detail_id_list,l_day_ovn_list,l_detail_ovn_list);

      load_attributes(l_detail_id_list,l_detail_ovn_list,p_load_template_attributes,p_attributes);

   else
      p_attributes := null;
    end if;
   End load_collection;

   PROCEDURE load_collection
     (p_top_level_block_id    in         hxc_time_building_blocks.time_building_block_id%type,
      p_blocks             out NOCOPY hxc_block_table_type,
      p_attributes            out NOCOPY hxc_attribute_table_type,
      p_row_data           out NOCOPY hxc_trans_display_key_utils.translation_row_used,
      p_missing_rows       in out NOCOPY boolean
      ) is

      l_discard_date1 date;
      l_discard_date2 date;

   Begin

      load_collection
      (p_top_level_block_id,
       null,
       p_blocks,
       p_attributes,
       l_discard_date1,
       l_discard_date2,
       p_row_data,
       p_missing_rows
       );

   End load_collection;
--
-- Public Functions and Procedures, see the package header for documentation.
--
-- +--------------------------------------------------------------------------+
-- |----------------------< get_application_period >--------------------------|
-- +--------------------------------------------------------------------------+
--
   PROCEDURE get_application_period
     (p_app_period_id in            hxc_time_building_blocks.time_building_block_id%type,
      p_blocks           out NOCOPY hxc_block_table_type,
      p_attributes       out NOCOPY hxc_attribute_table_type
     ) is

      cursor c_app_period_times
         (p_application_period_id in hxc_app_period_summary.application_period_id%type) is
      select start_time,
             stop_time
        from hxc_app_period_summary
       where application_period_id = p_application_period_id;

    l_start_time date;
    l_stop_time  date;

   Begin
      open c_app_period_times(p_app_period_id);
      fetch c_app_period_times into l_start_time, l_stop_time;
      if(c_app_period_times%found) then
         close c_app_period_times;
         get_application_period
            (p_app_period_id,
             l_start_time,
             l_stop_time,
             p_blocks,
             p_attributes
             );
      else
         close c_app_period_times;
      end if;

   End get_application_period;

   PROCEDURE get_application_period
     (p_app_period_id in            hxc_time_building_blocks.time_building_block_id%type,
      p_start_time    in            date,
      p_stop_time     in            date,
      p_blocks           out NOCOPY hxc_block_table_type,
      p_attributes       out NOCOPY hxc_attribute_table_type
     ) is

      cursor c_app_attribute
         (p_app_period_id hxc_time_building_blocks.time_building_block_id%type) is
        select hxc_attribute_type
                (-2,
                 p_blocks(1).time_building_block_id,
                 'APPROVAL',
                 favtl.application_name,
                 '',
                 p.full_name,
                 '',
                 '',
                 '',
                 hr_general.decode_lookup('HXC_APPROVAL_STATUS', apsum.approval_status),
                 '',
                 '',
                 '' ,
                 '' ,
                 '' ,
                 '' ,
                 '' ,
                 '' ,
                 '' ,
                 '' ,
                 '' ,
                 '' ,
                 '' ,
                 '' ,
                 '' ,
                 '' ,
                 '' ,
                 '' ,
                 '' ,
                 '' ,
                 '' ,
                 '' ,
                 '' ,
                 bbit.bld_blk_info_type_id,
                 1,
                 'N',
                 'N',
                 bbit.bld_blk_info_type,
                 'N',
                 p_blocks(1).object_version_number
                 )
          from hxc_app_period_summary apsum,
               fnd_application_tl favtl,
               hxc_time_recipients htr,
               per_all_people_f p,
               hxc_bld_blk_info_types bbit
         where apsum.application_period_id = p_app_period_id
           and favtl.application_id = htr.application_id
           and htr.time_recipient_id = apsum.time_recipient_id
           and favtl.language = userenv('LANG')
           and p.person_id (+) = apsum.approver_id
           and p.effective_end_date (+) = hr_general.end_of_time
           and bbit.bld_blk_info_type = 'APPROVAL';

      l_row_data              hxc_trans_display_key_utils.translation_row_used;
      l_missing_rows          boolean;
      l_app_period_start_time date;
      l_app_period_stop_time  date;
      l_attribute             hxc_attribute_type;
      l_block_id_list         block_id_list := block_id_list();
      l_block_ovn_list        block_ovn_list := block_ovn_list();
      l_day_id_list           block_id_list := block_id_list();
      l_day_ovn_list          block_ovn_list := block_ovn_list();
      daynum                  pls_integer;
      daysselected            pls_integer;

   Begin
      p_blocks := null;

      load_top_level_block
         (p_app_period_id,
          p_blocks,
          l_app_period_start_time,
          l_app_period_stop_time
          );

      if(p_blocks is not null) then
         l_block_id_list.extend;
         l_block_id_list(l_block_id_list.last) := p_blocks(1).time_building_block_id;
         l_block_ovn_list.extend;
         l_block_ovn_list(l_block_ovn_list.last) := p_blocks(1).object_version_number;
         --
         -- Reset start and stop time on the top level block for the alias translator
         -- if different periods - we're only interested in the period associated with
         -- the timecard anyway.
         --
         if(trunc(l_app_period_start_time) <> trunc(p_start_time)) then
            p_blocks(1).start_time := fnd_date.date_to_canonical(p_start_time);
         end if;
         if(trunc(l_app_period_stop_time) <> trunc(p_stop_time)) then
            p_blocks(1).stop_time := fnd_date.date_to_canonical(p_stop_time);
         end if;
         --
         -- Ok, now add the dummy application attribute, still used in the fragment view
         -- Since the block structure does not include the columns from the summary tables
         --
         if(p_attributes is null) then
            p_attributes := hxc_attribute_table_type();
         end if;
         open c_app_attribute(p_app_period_id);
         fetch c_app_attribute into l_attribute;
         if(c_app_attribute%found) then
            close c_app_attribute;
            p_attributes.extend();
            p_attributes(p_attributes.last) := l_attribute;
         else
            close c_app_attribute;
         end if;
         --
         -- Get the days associated with this Application Period
         --
         load_app_period_days
            (p_blocks(1).time_building_block_id,
             p_blocks(1).object_version_number,
             p_start_time,
             p_stop_time,
             l_day_id_list,
             l_day_ovn_list,
             p_blocks,
             p_attributes
             );
         append_to_list(l_day_id_list,l_block_id_list,l_day_ovn_list,l_block_ovn_list);
         daynum := trunc(p_stop_time)-trunc(p_start_time)+1;
         daysselected := l_day_id_list.count;
         if(daynum <> daysselected) then
            -- Add missing days
            add_missing_days
               (p_blocks,
                p_start_time,
                p_stop_time
                );
         end if;
         --
         -- Get the details associated with the application period
         --
         l_day_id_list := block_id_list();
         l_day_ovn_list := block_ovn_list();
         l_missing_rows := true;
         load_app_period_details
            (l_block_id_list(1),
             p_start_time,
             p_stop_time,
             l_day_id_list,
             l_day_ovn_list,
             p_blocks,
             p_attributes,
             l_row_data,
             l_missing_rows
             );
         append_to_list(l_day_id_list,l_block_id_list,l_day_ovn_list,l_block_ovn_list);
         --
         -- Get the appropriate attributes
         --
         load_attributes(l_block_id_list,l_block_ovn_list,hxc_timecard.c_yes,p_attributes);

      end if; -- Did the top level block exist?

   End get_application_period;
--
-- +--------------------------------------------------------------------------+
-- |------------------------<     get_timecard     >--------------------------|
-- +--------------------------------------------------------------------------+
--
   PROCEDURE get_timecard
     (p_timecard_id    in         hxc_time_building_blocks.time_building_block_id%type,
      p_blocks         out NOCOPY hxc_block_table_type,
      p_attributes     out NOCOPY hxc_attribute_table_type
     ) is
      l_row_data     hxc_trans_display_key_utils.translation_row_used;
      l_missing_rows boolean;
   Begin
      -- Tell load collection we do not care about
      -- the row translation information.
      l_missing_rows := false;
      get_timecard
      (p_timecard_id  => p_timecard_id,
       p_blocks       => p_blocks,
       p_attributes   => p_attributes,
       p_row_data     => l_row_data,
       p_missing_rows => l_missing_rows
       );
   End get_timecard;
--
-- +--------------------------------------------------------------------------+
-- |------------------------<     get_timecard     >--------------------------|
-- +--------------------------------------------------------------------------+
--
   PROCEDURE get_timecard
     (p_timecard_id    in         hxc_time_building_blocks.time_building_block_id%type,
      p_blocks         out NOCOPY hxc_block_table_type,
      p_attributes     out NOCOPY hxc_attribute_table_type,
      p_row_data       out NOCOPY hxc_trans_display_key_utils.translation_row_used,
      p_missing_rows   in out NOCOPY boolean
     ) is
   Begin

     p_blocks := hxc_block_table_type();
     p_attributes := hxc_attribute_table_type();
     load_collection
       (p_timecard_id,
     p_blocks,
     p_attributes,
     p_row_data,
     p_missing_rows
     );
   End;
--
-- +--------------------------------------------------------------------------+
-- |------------------------<     get_template     >--------------------------|
-- +--------------------------------------------------------------------------+
--
   PROCEDURE get_template
     (p_template_id      in         hxc_time_building_blocks.time_building_block_id%type,
      p_blocks          out NOCOPY hxc_block_table_type,
      p_attributes         out NOCOPY hxc_attribute_table_type,
      p_template_start_time   out NOCOPY date,
      p_template_stop_time    out NOCOPY date
      )is

      l_row_data hxc_trans_display_key_utils.translation_row_used;
      l_missing_rows boolean;

   Begin
      p_blocks := hxc_block_table_type();
      p_attributes := hxc_attribute_table_type();
      l_missing_rows := false;

      load_collection
      (p_template_id,
       'Y',
       p_blocks,
       p_attributes,
       p_template_start_time,
       p_template_stop_time,
       l_row_data,
       l_missing_rows
       );

   End get_template;


END hxc_block_collection_utils;

/
