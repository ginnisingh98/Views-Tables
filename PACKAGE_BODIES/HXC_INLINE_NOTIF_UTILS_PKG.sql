--------------------------------------------------------
--  DDL for Package Body HXC_INLINE_NOTIF_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_INLINE_NOTIF_UTILS_PKG" as
/* $Header: hxcinnotiutl.pkb 120.15 2006/10/02 23:34:10 arundell noship $ */

c_end_of_time_string CONSTANT VARCHAR2(19) := '4712/12/31 00:00:00';
c_new_get_type       CONSTANT VARCHAR2(3) := 'NEW';
c_old_get_type       CONSTANT VARCHAR2(3) := 'OLD';

g_debug boolean := hr_utility.debug_enabled;

type context_details is record
       (context fnd_descr_flex_contexts.descriptive_flex_context_code%type,
        block_id hxc_time_building_blocks.time_building_block_id%type,
	entered boolean
	);

type context_details_table is table of context_details index by binary_integer;

FUNCTION get_table_name(p_access IN VARCHAR2)
RETURN VARCHAR2
AS
BEGIN
  IF (instr(upper(p_access),'TIME')>0) THEN
    RETURN 'HXC_TIME_BUILDING_BLOCKS';
  ELSIF (instr(upper(p_access),'FLEX')>0) THEN
    RETURN 'HXC_TIME_ATTRIBUTES';
  ELSE
    RETURN '';
  END IF;
END get_table_name;

FUNCTION get_flex_value
  (p_column     IN VARCHAR2,
   p_context    IN VARCHAR2,
   p_det_bb_id  IN NUMBER,
   p_det_bb_ovn IN NUMBER,
   p_get_type   IN VARCHAR2
  )
  RETURN VARCHAR2
  AS

  Cursor cur_flex_value_set(p_context IN VARCHAR2,p_column IN VARCHAR2) is
  (select a.FLEX_VALUE_SET_ID  from
          FND_DESCR_FLEX_COLUMN_USAGES a,
          fnd_flex_value_sets b
   where a.descriptive_flexfield_name = 'OTC Information Types'
   and   a.application_id = 809
   and   a.DESCRIPTIVE_FLEX_CONTEXT_CODE = p_context
   and   a.flex_value_set_id = b.flex_value_set_id
   and   b.validation_type in ('F','I')
   AND   a.APPLICATION_COLUMN_NAME = p_column);

  TYPE GetFlexVal IS REF CURSOR;
  flex_cr   GetFlexVal;

  l_value    VARCHAR2(150);
  l_query    VARCHAR2(3000);

  l_id	     VARCHAR2(150);
  l_flex_valuset_id VARCHAR2(150);

  BEGIN
     if g_debug then
	hr_utility.trace(' p_context '||p_context);
	hr_utility.trace(' p_det_bb_id '||p_det_bb_id);
	hr_utility.trace(' p_det_bb_ovn '||p_det_bb_ovn);
     end if;

     l_query := ' select hta.'||p_column||fnd_global.local_chr('10');

     if(p_get_type = c_new_get_type) then
        if p_context like 'PAEXPITDFF%' THEN
           l_query := l_query ||
              'from hxc_time_building_blocks tbb, hxc_time_attribute_usages htau, hxc_time_attributes hta
              where htau.time_building_block_id= :p_det_bb_id
                and htau.time_building_block_ovn = :p_det_bb_ovn
                and tbb.time_building_block_id = htau.time_building_block_id
                and tbb.object_version_number = htau.time_building_block_ovn
                and tbb.date_to = hr_general.end_of_time
   	        and htau.time_attribute_id = hta.time_attribute_id
                and hta.attribute_category = :p_context';
        else
           l_query := l_query ||
              'from hxc_time_building_blocks tbb, hxc_time_attribute_usages htau, hxc_time_attributes hta, hxc_bld_blk_info_types bbit
              where htau.time_building_block_id= :p_det_bb_id
                and htau.time_building_block_ovn = :p_det_bb_ovn
                and tbb.time_building_block_id = htau.time_building_block_id
                and tbb.object_version_number = htau.time_building_block_ovn
                and tbb.date_to = hr_general.end_of_time
   	        and htau.time_attribute_id = hta.time_attribute_id
                and hta.bld_blk_info_type_id = bbit.bld_blk_info_type_id
                and bbit.bld_blk_info_type = :p_context';
        end if;
     else
        if p_context like 'PAEXPITDFF%' THEN
           l_query := l_query ||
              'from hxc_time_attribute_usages htau, hxc_time_attributes hta
              where htau.time_building_block_id= :p_det_bb_id
                and htau.time_building_block_ovn = :p_det_bb_ovn
   	        and htau.time_attribute_id = hta.time_attribute_id
                and hta.attribute_category = :p_context';
        else
           l_query := l_query ||
              'from hxc_time_attribute_usages htau, hxc_time_attributes hta, hxc_bld_blk_info_types bbit
              where htau.time_building_block_id= :p_det_bb_id
                and htau.time_building_block_ovn = :p_det_bb_ovn
   	        and htau.time_attribute_id = hta.time_attribute_id
                and hta.bld_blk_info_type_id = bbit.bld_blk_info_type_id
                and bbit.bld_blk_info_type = :p_context';
        end if;
     end if;

     OPEN flex_cr FOR l_query USING p_det_bb_id,p_det_bb_ovn,p_context;
     FETCH flex_cr INTO l_id;

     if g_debug then
	hr_utility.trace(' l_id '||l_id);
     end if;

    IF (flex_cr%found) THEN
       CLOSE flex_cr;


    IF (p_context like 'PAEXPITDFF%') THEN
       OPEN cur_flex_value_set(p_context,p_column);
       FETCH cur_flex_value_set INTO l_flex_valuset_id;
       if g_debug then
          hr_utility.trace(' l_flex_valuset_id '||l_flex_valuset_id);
       end if;
       IF (cur_flex_value_set%found) and (l_flex_valuset_id is not null)
            and (l_id is not null)
       THEN

          CLOSE cur_flex_value_set;
          l_value := hxc_time_category_utils_pkg.get_flex_value
             (p_flex_value_set_id => l_flex_valuset_id
              ,p_id 		  => l_id  );


          IF (l_value is null) THEN
             RETURN(l_id);
          ELSE
             RETURN(l_value);
          END IF;

       ELSE
          CLOSE cur_flex_value_set;
          RETURN(l_id);
       END IF;
    ELSE
       RETURN(l_id);
    END IF;

 ELSE
    CLOSE flex_cr;
    RETURN '';
 END IF;

END get_flex_value;



FUNCTION get_tbb_value
  (p_column     IN   VARCHAR2,
   p_det_bb_id  IN   NUMBER,
   p_det_bb_ovn IN  NUMBER,
   p_get_type   IN VARCHAR2
  )
  RETURN VARCHAR2
  AS

    TYPE GetFlexVal IS REF CURSOR;
    tbb_cr   GetFlexVal;
    l_query    VARCHAR2(3000);
    l_value    VARCHAR2(2000);
    l_column   VARCHAR2(50);

  BEGIN

     IF((upper(p_column) like 'START_TIME')or (upper(p_column) like 'STOP_TIME')) THEN
        l_column := 'to_char('||p_column||','||''''||'yyyy/MM/dd HH24:MI:ss'||''''||')';
     ELSE
        l_column := p_column;
     END IF;

     l_query := 'select '||l_column||'
                from hxc_time_building_blocks
                where time_building_block_id = :p_det_bb_id
                  and object_version_number = :p_det_bb_ovn';

     if(p_get_type=c_new_get_type) then
        l_query := l_query || fnd_global.local_chr('10') ||'and date_to = hr_general.end_of_time';
     end if;

     OPEN tbb_cr FOR l_query USING p_det_bb_id,p_det_bb_ovn;
     FETCH tbb_cr INTO l_value;
     IF (tbb_cr%found) THEN
        CLOSE tbb_cr;
        RETURN(l_value);
     ELSE
        CLOSE tbb_cr;
        RETURN '';
     END IF;

END get_tbb_value;

PROCEDURE get_block_info
   (p_det_bb_id  IN            NUMBER,
    p_det_bb_ovn IN            NUMBER,
    p_get_type   IN            VARCHAR2,
    p_blocks     IN OUT NOCOPY hxc_self_service_time_deposit.timecard_info)
AS

  CURSOR c_time_building_blocks
          (p_bb_id   IN HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE,
           p_bb_ovn IN HXC_TIME_BUILDING_BLOCKS.OBJECT_VERSION_NUMBER%TYPE,
           p_get_type in varchar2) is
    select tbb1.TIME_BUILDING_BLOCK_ID
          ,tbb1.TYPE
          ,tbb1.MEASURE
          ,tbb1.UNIT_OF_MEASURE
          ,tbb1.START_TIME
          ,tbb1.STOP_TIME
          ,tbb1.PARENT_BUILDING_BLOCK_ID
          ,'N' PARENT_IS_NEW
          ,tbb1.SCOPE
          ,tbb1.OBJECT_VERSION_NUMBER
          ,tbb1.APPROVAL_STATUS
          ,tbb1.RESOURCE_ID
          ,tbb1.RESOURCE_TYPE
          ,tbb1.APPROVAL_STYLE_ID
          ,tbb1.DATE_FROM
          ,tbb1.DATE_TO
          ,tbb1.COMMENT_TEXT
          ,tbb1.PARENT_BUILDING_BLOCK_OVN
          ,'N' NEW
          ,'N' CHANGED
          ,'N' PROCESS
          ,tbb1.application_set_id
          ,tbb1.translation_display_key
          from hxc_time_building_blocks tbb1
          where tbb1.TIME_BUILDING_BLOCK_ID = p_bb_id
            and tbb1.OBJECT_VERSION_NUMBER = p_bb_ovn
            and decode(p_get_type,'NEW',hr_general.end_of_time,tbb1.date_to) = tbb1.date_to;

  l_block        hxc_self_service_time_deposit.building_block_info;
  l_block_index  NUMBER;

BEGIN

  IF p_blocks.count = 0
    THEN
      l_block_index := 1;
    ELSE
      l_block_index := p_blocks.last + 1;
  END IF;

  open c_time_building_blocks(p_det_bb_id,p_det_bb_ovn,p_get_type);
  fetch c_time_building_blocks into l_block;
  if(c_time_building_blocks%found) then
     p_blocks(l_block_index) := l_block;
  end if;
  close c_time_building_blocks;

END;

PROCEDURE get_attributes(
  p_block_id   IN hxc_time_building_blocks.time_building_block_id%TYPE
 ,p_block_ovn  IN hxc_time_building_blocks.object_version_number%TYPE
 ,p_attributes IN OUT NOCOPY hxc_self_service_time_deposit.building_block_attribute_info
 )
IS
  l_attribute_index NUMBER;
  l_temp_attribute  hxc_self_service_time_deposit.attribute_info;

  CURSOR c_block_attributes(
    p_building_block_id IN HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE
   ,p_ovn               IN HXC_TIME_BUILDING_BLOCKS.OBJECT_VERSION_NUMBER%TYPE
  )
  IS
    select   a.time_attribute_id
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
       from hxc_time_attributes a,
            hxc_time_attribute_usages au,
            hxc_bld_blk_info_types bbit
      where au.time_building_block_id = p_building_block_id
        and au.time_building_block_ovn = p_ovn
        and au.time_attribute_id = a.time_attribute_id
        and (not (a.attribute_category = 'SECURITY'))
        and a.bld_blk_info_type_id = bbit.bld_blk_info_type_id;


BEGIN

  IF p_attributes.count = 0
  THEN
    l_attribute_index := 1;
  ELSE
    l_attribute_index := p_attributes.last + 1;
  END IF;

  OPEN c_block_attributes(
      p_building_block_id => p_block_id
     ,p_ovn               => p_block_ovn
    );

  LOOP
    FETCH c_block_attributes INTO l_temp_attribute;
    EXIT WHEN c_block_attributes%NOTFOUND;

      p_attributes(l_attribute_index) := l_temp_attribute;

      l_attribute_index := l_attribute_index + 1;
  END LOOP;

  CLOSE c_block_attributes;
END get_attributes;

PROCEDURE translate_alias_timecards(
  p_resource_id     IN VARCHAR2
 ,p_start_time      IN VARCHAR2
 ,p_stop_time       IN VARCHAR2
 ,p_block_array      IN OUT NOCOPY HXC_BLOCK_TABLE_TYPE
 ,p_attribute_array  IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE
)
IS
  l_resource_id       VARCHAR2(50) := NULL;

  l_messages_table	HXC_MESSAGE_TABLE_TYPE;

  l_bb_count       NUMBER;
  l_att_count      NUMBER;

BEGIN
  -- call translator alias package
  l_resource_id := p_resource_id;

  IF l_resource_id IS NULL
  THEN
    l_resource_id := p_block_array(1).resource_id;
  END IF;


  HXC_ALIAS_TRANSLATOR.do_retrieval_translation(
    p_attributes	=> p_attribute_array
   ,p_blocks  	        => p_block_array
   ,p_start_time  	=> p_start_time --FND_DATE.CANONICAL_TO_DATE(p_start_time)
   ,p_stop_time   	=> p_stop_time --FND_DATE.CANONICAL_TO_DATE(p_stop_time)
   ,p_resource_id 	=> l_resource_id
   ,p_messages		=> l_messages_table
  );

END translate_alias_timecards;



  FUNCTION get_olt_alias
     (p_det_bb_id  in number,
      p_det_bb_ovn in number,
      p_get_type   in varchar2,
      p_context    in varchar2
      ) return varchar2 is

     CURSOR get_otl_alias(p_alias_value_id NUMBER) IS
       SELECT alias_value_name
         FROM hxc_alias_values_tl
        WHERE alias_value_id = p_alias_value_id;

     l_get_otl_alias     get_otl_alias%rowtype;

     l_blocks            hxc_self_service_time_deposit.timecard_info;
     l_attributes        hxc_self_service_time_deposit.building_block_attribute_info;
     l_day_bb_id         NUMBER;
     l_day_bb_ovn        NUMBER;
     l_tim_bb_id         NUMBER;
     l_tim_bb_ovn        NUMBER;
     l_block_array       HXC_BLOCK_TABLE_TYPE;
     l_attribute_array   HXC_ATTRIBUTE_TABLE_TYPE;
     l_attribute_index   NUMBER;

  Begin
   get_block_info(p_det_bb_id, p_det_bb_ovn, p_get_type, l_blocks);
   if(l_blocks.count>0) then
      get_attributes(p_det_bb_id, p_det_bb_ovn, l_attributes);

      l_day_bb_id  := l_blocks(l_blocks.count).parent_building_block_id;
      l_day_bb_ovn := l_blocks(l_blocks.count).parent_building_block_ovn;

      get_block_info(l_day_bb_id, l_day_bb_ovn, p_get_type, l_blocks);
      get_attributes(l_day_bb_id, l_day_bb_ovn, l_attributes);

      l_tim_bb_id  := l_blocks(l_blocks.count).parent_building_block_id;
      l_tim_bb_ovn := l_blocks(l_blocks.count).parent_building_block_ovn;

      get_block_info(l_tim_bb_id, l_tim_bb_ovn, p_get_type, l_blocks);
      get_attributes(l_tim_bb_id, l_tim_bb_ovn, l_attributes);

      l_block_array := hxc_deposit_wrapper_utilities.blocks_to_array
         (p_blocks => l_blocks);
      l_attribute_array := hxc_deposit_wrapper_utilities.attributes_to_array
         (p_attributes => l_attributes);

      translate_alias_timecards
         (p_resource_id     => l_blocks(l_blocks.last).resource_id,
          p_start_time      => l_blocks(l_blocks.last).start_time,
          p_stop_time       => l_blocks(l_blocks.last).stop_time,
          p_block_array     => l_block_array,
          p_attribute_array => l_attribute_array
          );

      l_attribute_index := l_attribute_array.first;
      Loop
         exit when not l_attribute_array.exists(l_attribute_index);
         if((l_attribute_array(l_attribute_index).building_block_id = p_det_bb_id)
            and
               (UPPER(l_attribute_array(l_attribute_index).attribute_category) = upper(p_context))
            ) then
            open get_otl_alias(to_number(l_attribute_array(l_attribute_index).attribute1));
            fetch get_otl_alias into l_get_otl_alias;
            if(get_otl_alias%notfound) then
               close get_otl_alias;
               return('');
            else
               close get_otl_alias;
               return(l_get_otl_alias.alias_value_name);
            end if;
         end if;

         l_attribute_index := l_attribute_array.next(l_attribute_index);

      end loop;
   end if; -- no detail building block as required

   return('');

END get_olt_alias;

function context_index
          (p_context_details in context_details_table,
	   p_context in varchar2,
           p_block_id in hxc_time_building_blocks.time_building_block_id%type
           ) return pls_integer is
   l_index pls_integer;
begin
   l_index := p_context_details.first;
   loop
      exit when not p_context_details.exists(l_index);
      if(
         (p_context_details(l_index).context = p_context)
        AND
         (p_context_details(l_index).block_id = p_block_id)
        )then
	 return l_index;
      end if;
      l_index := p_context_details.next(l_index);
   end loop;
   return null;
end context_index;

function add_day_detail_record
           (p_day_detail in HXC_DAY_DETAIL_TYPE,
	    p_context_details in context_details_table)
         return boolean is
   l_return boolean;
begin
   l_return := true;

   if(instr(p_day_detail.context,'PAEXPITDFF')>0) then
      if( NOT p_context_details(context_index(p_context_details,p_day_detail.context,p_day_detail.detail_bb_id)).entered) then
	 l_return := false;
      end if;
   end if;

   return l_return;

end add_day_detail_record;

function parse_day_details_table
           (p_day_details_table in HXC_DAY_DETAIL_TABLE_TYPE,
	    p_context_details in context_details_table)
         return HXC_DAY_DETAIL_TABLE_TYPE is

   l_day_details_table HXC_DAY_DETAIL_TABLE_TYPE;
   l_index number;

Begin
   l_day_details_table := HXC_DAY_DETAIL_TABLE_TYPE();

   l_index := p_day_details_table.first;
   Loop
      Exit when not p_day_details_table.exists(l_index);

      if(add_day_detail_record(p_day_details_table(l_index),p_context_details)) then
	 l_day_details_table.extend;
	 l_day_details_table(l_day_details_table.last) := p_day_details_table(l_index);
      end if;

      l_index := p_day_details_table.next(l_index);
  End Loop;

  return l_day_details_table;

End parse_day_details_table;

procedure maintain_context_details
            (p_context_details in out nocopy context_details_table,
             p_block_id in hxc_time_building_blocks.time_building_block_id%type,
	     p_context in varchar2,
	     p_new_entry in varchar2,
	     p_old_entry in varchar2) is
   l_index pls_integer;
begin
   if(instr(p_context,'PAEXPITDFF') > 0) then
      l_index := context_index(p_context_details,p_context,p_block_id);
      if(l_index is null) then
	 l_index := nvl(p_context_details.last,0) + 1;
	 p_context_details(l_index).context := p_context;
         p_context_details(l_index).block_id := p_block_id;
	 p_context_details(l_index).entered := false;
      end if;

      if(p_context_details(l_index).entered) then
	 null;
      else
	 if((p_new_entry is not null) or (p_old_entry is not null)) then
	    p_context_details(l_index).entered := true;
	 end if;
      end if;
   end if;

end maintain_context_details;

PROCEDURE fetch_day_details
  (p_app_bb_id        IN            NUMBER,
   p_tk_audit	      IN            VARCHAR2,
   p_day_detail_array IN OUT NOCOPY HXC_DAY_DETAIL_TABLE_TYPE,
   p_message_string      OUT NOCOPY VARCHAR2
  ) AS

  l_table_name      VARCHAR2(30);
  l_context         VARCHAR2(30);
  l_column          VARCHAR2(15);
  l_old_det_ovn     NUMBER;
  l_dd_count        NUMBER;
  l_det_bb_id       NUMBER;
  l_det_bb_ovn       NUMBER;
  l_last_creation_date DATE;

  l_day_detail_array HXC_DAY_DETAIL_TABLE_TYPE;
  l_index pls_integer;
  l_string varchar2(1);
  l_context_details context_details_table;

  cursor get_last_creation_dates(p_app_bb_id NUMBER) is
         select tab.creation_date
	 from (select distinct htbb.creation_date creation_date
	       from hxc_time_building_blocks htbb, hxc_ap_detail_links hadl
	       where htbb.time_building_block_id = hadl.time_building_block_id
	         and hadl.application_period_id = p_app_bb_id
	       order by creation_date desc) tab
	 where rownum <= 2;

  cursor get_tk_last_creation_dates(p_app_bb_id NUMBER) is
      select tab.creation_date
	  from (select distinct detail.creation_date creation_date
            from hxc_time_building_blocks detail,hxc_time_building_blocks day
            where day.parent_building_block_id =p_app_bb_id
            and detail.parent_building_block_id = day.time_building_block_id
            and detail.parent_building_block_ovn = day.object_version_number
            and detail.scope='DETAIL'
            order by 1 desc) tab
        where rownum <= 2;

  cursor get_old_det_ovn(p_det_bb_id NUMBER,p_last_creation_date DATE) is
         select NVL(max(object_version_number),-1)
	 from hxc_time_building_blocks htbb
	 where htbb.creation_date <= (p_last_creation_date+0.000011574)
           and date_to <> hr_general.end_of_time
	   and htbb.time_building_block_id = p_det_bb_id
           and htbb.approval_status = hxc_timecard.c_submitted_status;

 BEGIN

    g_debug := hr_utility.debug_enabled;

 l_day_detail_array := p_day_detail_array;

 if p_tk_audit ='YES' then
   open get_tk_last_creation_dates(p_app_bb_id);
   loop
   fetch get_tk_last_creation_dates into l_last_creation_date;
   exit when get_tk_last_creation_dates%notfound;
   end loop;

   IF(get_tk_last_creation_dates%rowcount<2) THEN
     l_last_creation_date := null;
   END IF;
   close get_tk_last_creation_dates;
 else
    open get_last_creation_dates(p_app_bb_id);
   loop
      fetch get_last_creation_dates into l_last_creation_date;
      exit when get_last_creation_dates%notfound;
   end loop;

   IF(get_last_creation_dates%rowcount<2) THEN
      l_last_creation_date := null;
   END IF;
   close get_last_creation_dates;

end if;

l_dd_count := l_day_detail_array.first;

LOOP
   EXIT WHEN NOT l_day_detail_array.exists(l_dd_count);

   l_det_bb_id := l_day_detail_array(l_dd_count).detail_bb_id;
   l_det_bb_ovn := l_day_detail_array(l_dd_count).detail_bb_ovn;

   l_table_name := get_table_name(l_day_detail_array(l_dd_count).tabaccess);
   l_context  := l_day_detail_array(l_dd_count).context;
   l_column   := l_day_detail_array(l_dd_count).attribute;
   maintain_context_details
      (l_context_details,
       l_det_bb_id,
       l_context,
       l_day_detail_array(l_dd_count).new_entry,
       l_day_detail_array(l_dd_count).old_entry);
   IF(instr(upper(l_context),'OTL_ALIAS')>0) THEN

      l_day_detail_array(l_dd_count).new_entry := get_olt_alias(l_det_bb_id,l_det_bb_ovn,c_new_get_type,l_context);
      OPEN get_old_det_ovn(l_det_bb_id, l_last_creation_date);
      FETCH get_old_det_ovn INTO l_old_det_ovn;

      IF(l_last_creation_date IS null) THEN
	 l_day_detail_array(l_dd_count).old_entry := '';
      ELSE
	 IF (l_old_det_ovn = -1) THEN
	    l_day_detail_array(l_dd_count).old_entry := '';
	 ELSE
	    l_day_detail_array(l_dd_count).old_entry := get_olt_alias(l_det_bb_id,l_old_det_ovn,c_old_get_type,l_context);
	 END IF;
      END IF;
      CLOSE get_old_det_ovn;

   ELSE

      IF(l_table_name = 'HXC_TIME_ATTRIBUTES') THEN
	 l_day_detail_array(l_dd_count).new_entry := get_flex_value(l_column,l_context,l_det_bb_id,l_det_bb_ovn,c_new_get_type);
      ELSIF (l_table_name = 'HXC_TIME_BUILDING_BLOCKS') THEN
         l_day_detail_array(l_dd_count).new_entry := get_tbb_value(l_column,l_det_bb_id,l_det_bb_ovn,c_new_get_type);
      END IF;


      IF(l_last_creation_date IS null) THEN
         l_day_detail_array(l_dd_count).old_entry := '';
      ELSE
         OPEN get_old_det_ovn(l_det_bb_id,l_last_creation_date);
         FETCH get_old_det_ovn INTO l_old_det_ovn;

         IF (l_old_det_ovn = -1) THEN
	    l_day_detail_array(l_dd_count).old_entry := '';
         ELSE
	    IF(l_table_name = 'HXC_TIME_ATTRIBUTES') THEN
	       l_day_detail_array(l_dd_count).old_entry := get_flex_value(l_column,l_context,l_det_bb_id,l_old_det_ovn,c_old_get_type);
	    ELSIF (l_table_name = 'HXC_TIME_BUILDING_BLOCKS') THEN
	       l_day_detail_array(l_dd_count).old_entry := get_tbb_value(l_column,l_det_bb_id,l_old_det_ovn,c_old_get_type);
	    END IF;
         END IF;

         CLOSE get_old_det_ovn;

      END IF;
   END IF;
   maintain_context_details
      (l_context_details,
       l_det_bb_id,
       l_context,
       l_day_detail_array(l_dd_count).new_entry,
       l_day_detail_array(l_dd_count).old_entry);
   l_dd_count := l_day_detail_array.next(l_dd_count);

END LOOP;

p_day_detail_array := parse_day_details_table(l_day_detail_array, l_context_details);

END fetch_day_details;

procedure tokenizer ( iStart IN NUMBER,
      sPattern in VARCHAR2,
      sBuffer in VARCHAR2,
      sResult OUT NOCOPY VARCHAR2,
      iNextPos OUT NOCOPY NUMBER)
      AS
      nPos1 number;
      nPos2 number;
      BEGIN

      nPos1 := Instr (sBuffer ,sPattern ,iStart);
      IF nPos1 = 0 then
       sResult := NULL ;
      ELSE
       nPos2 := Instr (sBuffer ,sPattern ,nPos1 + 1);
       IF nPos2 = 0 then
        sResult := Rtrim(Ltrim(Substr(sBuffer ,nPos1+1)));
        iNextPos := nPos2;
       else
        sResult := Substr(sBuffer ,nPos1 + 1 , nPos2 - nPos1 - 1);
        iNextPos := nPos2;
       END IF;
      END IF;
 END tokenizer ;


 PROCEDURE get_alias_values_from_db
      (p_bb_id IN NUMBER,
       p_bb_ovn IN NUMBER,
       p_layout_comp_id IN NUMBER,
       p_alias_value_list OUT NOCOPY VARCHAR2
      )
      IS
  TYPE AliasValueCurTyp IS REF CURSOR;

aliasval_cv   AliasValueCurTyp;

l_select hxc_layout_comp_qualifiers.qualifier_attribute27%type;
l_time_building_block_id number;
l_time_building_block_ovn number;
l_query varchar2(32000);
l_bld_blk_info_type hxc_bld_blk_info_types.bld_blk_info_type%type;
l_separator varchar2(10);
l_position number;
l_start_position number;

p_alias_value varchar2(250);
p_alias_name varchar2(250);
l_alias_list varchar2(250);
l_alias_name varchar2(250);
l_dummy_alias_name varchar2(250);

cursor get_alias_list(p_layout_comp_id in number)
is
 select QUALIFIER_ATTRIBUTE28||'|'||QUALIFIER_ATTRIBUTE28||'|'||QUALIFIER_ATTRIBUTE7
 from HXC_LAYOUT_COMP_QUALIFIERS where LAYOUT_COMPONENT_ID = p_layout_comp_id ;

cursor get_alias_location(p_layout_comp_id in number,p_alias_name in varchar2)
is
SELECT
  Distinct A.Qualifier_Attribute26,
  A.Qualifier_Attribute27
FROM
  Hxc_Layout_Comp_Qualifiers A,
  Hxc_Layout_Components B,
  Hxc_Layouts C
WHERE
  C.Layout_Id = (Select Layout_Id From Hxc_Layout_Components Where Layout_Component_Id = P_Layout_Comp_Id) And
  A.Layout_Component_Id = B.Layout_Component_Id And
  A.Qualifier_Attribute28=p_alias_name;


BEGIN

open get_alias_list(p_layout_comp_id );
fetch get_alias_list into l_alias_list;
close get_alias_list;

l_alias_list := '|'||l_alias_list;
l_position:=-1;
l_separator := '|';
l_start_position := 1;

while (l_position <> 0)
 loop
   --Tokenize twice to get the alias name from alias - cui name pair like
   --STATE|State|COUNTY|County|CITY|City for work location lov
   tokenizer (l_start_position ,l_separator,l_alias_list,l_alias_name,l_position);
   l_start_position := l_position;
   tokenizer (l_start_position ,l_separator,l_alias_list,l_dummy_alias_name,l_position);
   l_start_position := l_position;

   open get_alias_location(p_layout_comp_id ,l_alias_name ) ;
   fetch get_alias_location into l_bld_blk_info_type,l_select;
   close get_alias_location;

   --Dynamic query to select alias value as get_alias_location gives storing attribute
   -- and building block info type for each alias name
   l_query:= 'select ta.'|| l_select;
   l_query:= l_query || ' from
     hxc_time_attributes ta,
     hxc_time_attribute_usages tau,
     HXC_BLD_BLK_INFO_TYPES bbit
     where tau.time_building_block_id = :l_time_building_block_id and tau.time_building_block_ovn = :l_time_building_block_ovn
     and tau.time_attribute_id = ta.time_attribute_id
     and bbit.bld_blk_info_type_id = ta.bld_blk_info_type_id
     and bbit.bld_blk_info_type = :l_bld_blk_info_type';

   OPEN aliasval_cv FOR l_query using p_bb_id,p_bb_ovn,l_bld_blk_info_type;
   FETCH aliasval_cv INTO p_alias_value;
   close aliasval_cv;

   p_alias_value_list:=p_alias_value_list || p_alias_value ||'*#*';
 end loop;
end get_alias_values_from_db;

END hxc_inline_notif_utils_pkg;

/
