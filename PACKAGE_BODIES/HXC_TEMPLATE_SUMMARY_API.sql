--------------------------------------------------------
--  DDL for Package Body HXC_TEMPLATE_SUMMARY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TEMPLATE_SUMMARY_API" AS
/* $Header: hxctempsumapi.pkb 120.2 2005/12/12 08:28:50 gkrishna noship $ */

FUNCTION TEMPLATE_PRESENT
           (p_template_id in hxc_template_summary.template_id%type)
RETURN HXC_TEMPLATE_SUMMARY.RESOURCE_ID%TYPE IS

l_resource_id hxc_template_summary.resource_id%type;

BEGIN

select resource_id
  into l_resource_id
  from hxc_template_summary
 where template_id = p_template_id;

return l_resource_id;

exception
  when others then
    return NULL;
END TEMPLATE_PRESENT;

PROCEDURE DELETE_TEMPLATE
            (
		p_template_id in number
            ) is

l_index number;
l_resource_id hxc_template_summary.resource_id%type;
Begin

-- Delete the existing template information in the summary.
--

--Tracking the resource id to find out who already created it, if the template
--already exists.

l_resource_id := template_present(p_template_id);



if( l_resource_id is not null) then
	hxc_template_summary_pkg.delete_summary_row
	  (p_template_id => p_template_id);
end if;

END DELETE_TEMPLATE;

--Called during the template migration.

PROCEDURE TEMPLATE_DEPOSIT
(
	p_template_id in hxc_template_summary.template_id%type,
	p_template_ovn in HXC_TEMPLATE_SUMMARY.TEMPLATE_OVN%type
)
is
cursor c_template_attributes(p_template_id hxc_template_summary.template_id%type,p_template_ovn in HXC_TEMPLATE_SUMMARY.TEMPLATE_OVN%type)
	is SELECT
            a.attribute_category
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
       FROM hxc_time_attributes a,
            hxc_time_attribute_usages au,
            hxc_bld_blk_info_types bbit
      WHERE au.time_building_block_id = p_template_id
        AND au.time_building_block_ovn = p_template_ovn
        AND au.time_attribute_id = a.time_attribute_id
        AND ( (a.attribute_category = 'TEMPLATES')
        OR (a.attribute_category = 'SECURITY')
        OR (a.attribute_category = 'LAYOUT'))
	AND a.bld_blk_info_type_id = bbit.bld_blk_info_type_id;

l_recurring_period hxc_template_summary.RECURRING_PERIOD_ID%type ;
l_layout_id  hxc_template_summary.LAYOUT_ID%type;
l_template_name hxc_template_summary.TEMPLATE_NAME%type;
l_description hxc_template_summary.DESCRIPTION%type ;
l_template_type hxc_template_summary.TEMPLATE_TYPE%type;
l_business_group_id hxc_template_summary.BUSINESS_GROUP_ID%type;
l_resource_id hxc_template_summary.resource_id%type;

BEGIN

--
-- 1. Delete the template, if it already exists.
--
l_resource_id := template_present(p_template_id);

if( l_resource_id is not null) then
	hxc_template_summary_pkg.delete_summary_row
		(p_template_id => p_template_id);
end if;

for template_attribute_rec in c_template_attributes(p_template_id,p_template_ovn)
loop
   if(template_attribute_rec.ATTRIBUTE_CATEGORY = 'TEMPLATES') then
      l_template_name := template_attribute_rec.ATTRIBUTE1;
      l_template_type := template_attribute_rec.ATTRIBUTE2;
      if(l_template_type='PUBLIC') THEN
	 l_recurring_period := template_attribute_rec.ATTRIBUTE3;
	 l_description := template_attribute_rec.ATTRIBUTE4;
       END IF;
    elsif(template_attribute_rec.ATTRIBUTE_CATEGORY = 'LAYOUT') then
	l_layout_id := template_attribute_rec.ATTRIBUTE1;
    elsif(template_attribute_rec.ATTRIBUTE_CATEGORY = 'SECURITY') then
	l_business_group_id := template_attribute_rec.ATTRIBUTE2;
    end if;
end loop;
if (l_business_group_id is null) then
l_business_group_id :=0;
end if;
if ((l_template_name is NOT null) and (l_business_group_id is not null) and
   (l_layout_id is not null) and (l_template_type is not null)) then

hxc_template_summary_pkg.insert_summary_row
	  (p_template_id => p_template_id,
  	   p_template_ovn => p_template_ovn,
	   p_template_name =>l_template_name,
	   p_description =>l_description,
	   p_template_type =>l_template_type,
	   p_layout_id => l_layout_id,
	   p_recurring_period_id =>l_recurring_period,
	   p_business_group_id =>l_business_group_id,
	   p_resource_id => NULL
	  );
-- Need to pickingup the resourceid from the hxc_time_building_blocks table directly.
end if;
END TEMPLATE_DEPOSIT;


--Called during the template deposition.

PROCEDURE TEMPLATE_DEPOSIT
            (p_blocks in hxc_block_table_type,
 	     p_attributes in HXC_ATTRIBUTE_TABLE_TYPE,
	     p_template_id in hxc_template_summary.TEMPLATE_ID%type
             ) is

l_recurring_period hxc_template_summary.RECURRING_PERIOD_ID%type ;
l_layout_id  hxc_template_summary.LAYOUT_ID%type;
l_template_name hxc_template_summary.TEMPLATE_NAME%type;
l_description hxc_template_summary.DESCRIPTION%type ;
l_template_type hxc_template_summary.TEMPLATE_TYPE%type;
l_business_group_id hxc_template_summary.BUSINESS_GROUP_ID%type;
l_resource_id hxc_template_summary.resource_id%type;
l_timecard_index number;
l_index number;

BEGIN
--
-- 1. Find the timecard index of the blocks
--
l_timecard_index := hxc_timecard_block_utils.find_active_timecard_index(p_blocks);

--
-- 2. Delete the template, if it already exists.
--
l_resource_id := template_present(p_template_id);

if( l_resource_id is not null) then
	hxc_template_summary_pkg.delete_summary_row
		(p_template_id => p_template_id);
end if;

--
-- 3. Generate the template summary informations.
--

l_index := p_attributes.first;

Loop
  Exit when not p_attributes.exists(l_index);

  if(p_attributes(l_index).BUILDING_BLOCK_ID = p_blocks(l_timecard_index).time_building_block_id) then

    if(p_attributes(l_index).ATTRIBUTE_CATEGORY = 'TEMPLATES') then
      l_template_name := p_attributes(l_index).ATTRIBUTE1;
      l_template_type := p_attributes(l_index).ATTRIBUTE2;

       if(l_template_type='PUBLIC') THEN
	 l_recurring_period := p_attributes(l_index).ATTRIBUTE3;
	 l_description := p_attributes(l_index).ATTRIBUTE4;
       END IF;
    elsif(p_attributes(l_index).ATTRIBUTE_CATEGORY = 'LAYOUT') then
	l_layout_id := p_attributes(l_index).ATTRIBUTE1;
    elsif(p_attributes(l_index).ATTRIBUTE_CATEGORY = 'SECURITY') then
	l_business_group_id := p_attributes(l_index).ATTRIBUTE2;
    end if;
  end if;
  l_index := p_attributes.next(l_index);
End Loop;


hxc_template_summary_pkg.insert_summary_row
	  (p_template_id => p_blocks(l_timecard_index).time_building_block_id,
  	   p_template_ovn => p_blocks(l_timecard_index).OBJECT_VERSION_NUMBER,
	   p_template_name =>l_template_name,
	   p_description =>l_description,
	   p_template_type =>l_template_type,
	   p_layout_id => l_layout_id,
	   p_recurring_period_id =>l_recurring_period,
	   p_business_group_id =>l_business_group_id,
	   p_resource_id => fnd_global.employee_id
	  );

END TEMPLATE_DEPOSIT;

END HXC_TEMPLATE_SUMMARY_API;

/
