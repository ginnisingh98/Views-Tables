--------------------------------------------------------
--  DDL for Package Body HXC_TERG_UPL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TERG_UPL_PKG" AS
/* $Header: hxctergupl.pkb 115.0 2003/03/23 20:52:14 gpaytonm noship $ */
PROCEDURE load_time_entry_rule_group (
			p_time_entry_rule_group_name in VARCHAR2,
			p_owner                      in VARCHAR2,
			p_custom		     in VARCHAR2) IS
l_time_entry_rule_group_id number;
l_ovn                      number;

BEGIN
     SELECT TIME_ENTRY_RULE_GROUP_ID,
	    OBJECT_VERSION_NUMBER
       INTO l_time_entry_rule_group_id,
	    l_ovn
       FROM HXC_TIME_ENTRY_RULE_GROUPS_V
      WHERE TIME_ENTRY_RULE_GROUP_NAME = p_time_entry_rule_group_name;

EXCEPTION WHEN NO_DATA_FOUND
THEN
     hxc_heg_ins.ins (
		 p_name                  => p_time_entry_rule_group_name
		,p_entity_type           => 'TIME_ENTRY_RULES'
		,p_entity_group_id       => l_time_entry_rule_group_id
		,p_object_version_number => l_ovn);

end load_time_entry_rule_group;

PROCEDURE load_time_entry_rule_grp_comp (
			p_time_entry_rule_name    in VARCHAR2,
			p_time_entry_group_name   in VARCHAR2,
			p_outcome                 in VARCHAR2,
			p_owner                   in VARCHAR2,
			p_custom                  in VARCHAR2) IS
l_time_entry_rule_group_id number;
l_time_entry_rule_comp_id  number;
l_ovn                      number;
l_entity_id                number;
l_entity_type              varchar2(80) := 'TIME_ENTRY_RULES';
l_attribute_category       varchar2(30);
l_outcome		   varchar2(150);
l_attribute2		   varchar2(150);
l_attribute3		   varchar2(150);
l_attribute4		   varchar2(150);
l_attribute5		   varchar2(150);
l_attribute6		   varchar2(150);
l_attribute7		   varchar2(150);
l_attribute8		   varchar2(150);
l_attribute9		   varchar2(150);
l_attribute10		   varchar2(150);
l_attribute11		   varchar2(150);
l_attribute12		   varchar2(150);
l_attribute13		   varchar2(150);
l_attribute14		   varchar2(150);
l_attribute15		   varchar2(150);
l_attribute16		   varchar2(150);
l_attribute17		   varchar2(150);
l_attribute18		   varchar2(150);
l_attribute19		   varchar2(150);
l_attribute20		   varchar2(150);
l_attribute21		   varchar2(150);
l_attribute22		   varchar2(150);
l_attribute23		   varchar2(150);
l_attribute24		   varchar2(150);
l_attribute25		   varchar2(150);
l_attribute26		   varchar2(150);
l_attribute27		   varchar2(150);
l_attribute28		   varchar2(150);
l_attribute29		   varchar2(150);
l_attribute30		   varchar2(150);

function get_time_entry_group_id (p_time_entry_group_name in varchar2) return number is
 CURSOR csr_get_time_entry_grp_id is
     /*select time_entry_rule_group_id
       from hxc_time_entry_rule_groups_v
      where time_entry_rule_group_name = p_time_entry_group_name;*/
     select entity_group_id
       from hxc_entity_groups
      where entity_type = 'TIME_ENTRY_RULES'
	and name = p_time_entry_group_name;
 l_time_entry_group_id number;
begin
    open csr_get_time_entry_grp_id;
      fetch csr_get_time_entry_grp_id into l_time_entry_group_id;
    close csr_get_time_entry_grp_id;

    return l_time_entry_group_id;
end;

function get_time_entry_rule_id (p_time_entry_rule_name in VARCHAR2) return number is

CURSOR csr_get_ter_id is
    select time_entry_rule_id
      from hxc_time_entry_rules
     where name = p_time_entry_rule_name;
l_ter_id number;
begin
   open csr_get_ter_id;
     fetch csr_get_ter_id into l_ter_id;
   close csr_get_ter_id;

   return l_ter_id;
end;

function get_lookup_code (p_meaning in varchar2) return varchar2 is
cursor csr_get_lookup_code is
   select lookup_code
     from hr_lookups
    where lookup_type = 'HXC_TIME_ENTRY_RULE_OUTCOME' and
          meaning = p_meaning;
l_lookup_code varchar2(30);
begin
    open csr_get_lookup_code;
       fetch csr_get_lookup_code into l_lookup_code;
    close csr_get_lookup_code;

    return l_lookup_code;
end;
BEGIN
l_time_entry_rule_group_id := get_time_entry_group_id (p_time_entry_group_name);
l_entity_id := get_time_entry_rule_id (p_time_entry_rule_name);
     SELECT  htc.ENTITY_GROUP_COMP_ID   ,
	     htc.ENTITY_GROUP_ID        ,
	     htc.ENTITY_ID              ,
	     htc.ENTITY_TYPE            ,
	     htc.ATTRIBUTE_CATEGORY     ,
	     htc.ATTRIBUTE1             ,
	     htc.ATTRIBUTE2             ,
	     htc.ATTRIBUTE3             ,
	     htc.ATTRIBUTE4             ,
 	     htc.ATTRIBUTE5             ,
	     htc.ATTRIBUTE6             ,
	     htc.ATTRIBUTE7             ,
	     htc.ATTRIBUTE8             ,
	     htc.ATTRIBUTE9             ,
	     htc.ATTRIBUTE10            ,
	     htc.ATTRIBUTE11            ,
	     htc.ATTRIBUTE12            ,
	     htc.ATTRIBUTE13            ,
	     htc.ATTRIBUTE14            ,
	     htc.ATTRIBUTE15            ,
	     htc.ATTRIBUTE16            ,
	     htc.ATTRIBUTE17            ,
	     htc.ATTRIBUTE18            ,
	     htc.ATTRIBUTE19            ,
	     htc.ATTRIBUTE20            ,
	     htc.ATTRIBUTE21            ,
	     htc.ATTRIBUTE22            ,
	     htc.ATTRIBUTE23            ,
	     htc.ATTRIBUTE24            ,
	     htc.ATTRIBUTE25            ,
	     htc.ATTRIBUTE26            ,
	     htc.ATTRIBUTE27            ,
	     htc.ATTRIBUTE28            ,
	     htc.ATTRIBUTE29            ,
	     htc.ATTRIBUTE30            ,
	     htc.OBJECT_VERSION_NUMBER
	INTO l_time_entry_rule_comp_id ,
	     l_time_entry_rule_group_id ,
	     l_entity_id ,
	     l_entity_type,
	     l_attribute_category,
	     l_outcome,
	     l_attribute2,
	     l_attribute3,
	     l_attribute4,
	     l_attribute5,
	     l_attribute6,
	     l_attribute7,
	     l_attribute8,
	     l_attribute9,
	     l_attribute10,
	     l_attribute11,
	     l_attribute12,
	     l_attribute13,
	     l_attribute14,
	     l_attribute15,
	     l_attribute16,
	     l_attribute17,
	     l_attribute18,
	     l_attribute19,
	     l_attribute20,
	     l_attribute21,
	     l_attribute22,
	     l_attribute23,
	     l_attribute24,
	     l_attribute25,
	     l_attribute26,
	     l_attribute27,
	     l_attribute28,
	     l_attribute29,
	     l_attribute30,
	     l_ovn
       FROM  HXC_ENTITY_GROUPS HTE,
             HXC_ENTITY_GROUP_COMPS HTC
      WHERE  HTC.ENTITY_GROUP_ID = HTE.ENTITY_GROUP_ID AND
	     HTE.ENTITY_GROUP_ID = l_time_entry_rule_group_id AND
             HTC.ENTITY_ID = l_entity_id ;

EXCEPTION
WHEN NO_DATA_FOUND then
      l_outcome := get_lookup_code (p_outcome);
      hxc_egc_ins.ins (
		 p_effective_date            => to_date('01-01-1900','dd-mm-rrrr')
		,p_entity_group_id           => l_time_entry_rule_group_id
		,p_entity_id                 => l_entity_id
		,p_entity_type               => l_entity_type
		,p_attribute_category        => l_attribute_category
		,p_attribute1                => l_outcome
		,p_attribute2                => l_attribute2
		,p_attribute3                => l_attribute3
		,p_attribute4                => l_attribute4
		,p_attribute5                => l_attribute5
		,p_attribute6                => l_attribute6
		,p_attribute7                => l_attribute7
		,p_attribute8                => l_attribute8
		,p_attribute9                => l_attribute9
		,p_attribute10               => l_attribute10
		,p_attribute11               => l_attribute11
		,p_attribute12               => l_attribute12
		,p_attribute13               => l_attribute13
		,p_attribute14               => l_attribute14
		,p_attribute15               => l_attribute15
		,p_attribute16               => l_attribute16
		,p_attribute17               => l_attribute17
		,p_attribute18               => l_attribute18
		,p_attribute19               => l_attribute19
		,p_attribute20               => l_attribute20
		,p_attribute21               => l_attribute21
		,p_attribute22               => l_attribute22
		,p_attribute23               => l_attribute23
		,p_attribute24               => l_attribute24
		,p_attribute25               => l_attribute25
		,p_attribute26               => l_attribute26
		,p_attribute27               => l_attribute27
		,p_attribute28               => l_attribute28
		,p_attribute29               => l_attribute29
		,p_attribute30               => l_attribute30
		,p_entity_group_comp_id      => l_time_entry_rule_comp_id
		,p_object_version_number     => l_ovn
		,p_called_from_form          => 'N' );
END load_time_entry_rule_grp_comp;

END hxc_terg_upl_pkg;

/
