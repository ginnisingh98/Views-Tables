--------------------------------------------------------
--  DDL for Package Body HXC_RESOURCE_PERSONAL_PREF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_RESOURCE_PERSONAL_PREF_PKG" as
/* $Header: hxcrppref.pkb 115.8 2004/01/28 02:50:05 avramach noship $ */

g_package  varchar2(33) := '  hxc_resource_personal_pref_pkg.';

procedure manage_personal_pref
   (p_resource_id	       in     number
   ,p_login_id		       in     number
   ,p_preference_id            in     number
   ,p_preference_code          in     varchar2
   ,p_business_group_id        in     number
   ,p_legislation_code         in     varchar2
   ,p_pref_attribute_category  in     varchar2
   ,p_pref_attribute1          in     varchar2
   ,p_pref_attribute2          in     varchar2
   ,p_pref_attribute3          in     varchar2
   ,p_pref_attribute4          in     varchar2
   ,p_pref_attribute5          in     varchar2
   ,p_pref_attribute6          in     varchar2
   ,p_pref_attribute7          in     varchar2
   ,p_pref_attribute8          in     varchar2
   ,p_pref_attribute9          in     varchar2
   ,p_pref_attribute10         in     varchar2
   ,p_pref_attribute11         in     varchar2
   ,p_pref_attribute12         in     varchar2
   ,p_pref_attribute13         in     varchar2
   ,p_pref_attribute14         in     varchar2
   ,p_pref_attribute15         in     varchar2
   ,p_pref_attribute16         in     varchar2
   ,p_pref_attribute17         in     varchar2
   ,p_pref_attribute18         in     varchar2
   ,p_pref_attribute19         in     varchar2
   ,p_pref_attribute20         in     varchar2
   ,p_pref_attribute21         in     varchar2
   ,p_pref_attribute22         in     varchar2
   ,p_pref_attribute23         in     varchar2
   ,p_pref_attribute24         in     varchar2
   ,p_pref_attribute25         in     varchar2
   ,p_pref_attribute26         in     varchar2
   ,p_pref_attribute27         in     varchar2
   ,p_pref_attribute28         in     varchar2
   ,p_pref_attribute29         in     varchar2
   ,p_pref_attribute30         in     varchar2
  ) is

--l_pref_hierarchy_id 	number;
l_object_version_number number;
l_top_hcy_id		number;
l_pref_hcy_id		number;
l_pref_ovn		number;
l_resource_rule_id	number;
l_dummy			varchar2(1);
l_top_ovn               number;

cursor  c_resource_rule(l_pref_hierarchy_id in number) is
	select '1'
	from  hxc_resource_rules hrr
	where hrr.eligibility_criteria_id = to_char(p_login_id)
	and   hrr.eligibility_criteria_type = 'LOGIN'
	and   hrr.resource_type = 'PERSON'
	and   hrr.pref_hierarchy_id = l_pref_hierarchy_id;

-- Bug 3380737
cursor c_top_hierarchy  is
       select pref_hierarchy_id, max(object_version_number)
       from  hxc_pref_hierarchies
       where name = to_char(p_login_id)
       and   parent_pref_hierarchy_id is null
       and   type ='USER'
       group by pref_hierarchy_id;

cursor c_pref_hierarchy (l_top_hierarchy_id in number) is
       select pref_hierarchy_id, max(object_version_number)
       from hxc_pref_hierarchies hph
       where hph.name = p_preference_code
       and   hph.parent_pref_hierarchy_id = l_top_hierarchy_id
       group by pref_hierarchy_id;


begin

-- Check if the top hierarchy exists
open c_top_hierarchy;
fetch c_top_hierarchy into l_top_hcy_id,l_top_ovn;
if c_top_hierarchy%notfound then

-- Create the top hierarchy with the name equals to login_id
    l_top_ovn := null;
    hxc_pref_hierarchies_api.create_pref_hierarchies
                (p_type                     => 'USER'
                ,p_name                     => to_char(p_login_id)
                ,p_business_group_id	    => p_business_group_id
                ,p_legislation_code	    => p_legislation_code
                ,p_parent_pref_hierarchy_id => null
                ,p_edit_allowed             => 'Y'
                ,p_displayed                => 'Y'
                ,p_pref_definition_id       => null
                ,p_attribute_category       => null
                ,p_attribute1               => null
                ,p_attribute2               => null
                ,p_attribute3               => null
                ,p_attribute4               => null
                ,p_attribute5               => null
                ,p_attribute6               => null
                ,p_attribute7               => null
                ,p_attribute8               => null
                ,p_attribute9               => null
                ,p_attribute10              => null
                ,p_attribute11              => null
                ,p_attribute12              => null
                ,p_attribute13              => null
                ,p_attribute14              => null
                ,p_attribute15              => null
                ,p_attribute16              => null
                ,p_attribute17              => null
                ,p_attribute18              => null
                ,p_attribute19              => null
                ,p_attribute20              => null
                ,p_attribute21              => null
                ,p_attribute22              => null
                ,p_attribute23              => null
                ,p_attribute24              => null
                ,p_attribute25              => null
                ,p_attribute26              => null
                ,p_attribute27              => null
                ,p_attribute28              => null
                ,p_attribute29              => null
                ,p_attribute30              => null
                ,p_orig_pref_hierarchy_id   => null
                ,p_orig_parent_hierarchy_id => null
                ,p_pref_hierarchy_id        => l_top_hcy_id
                ,p_object_version_number    => l_top_ovn);

 end if;
close c_top_hierarchy;

-- Check if the preference hierarchy exist
open c_pref_hierarchy(l_top_hcy_id);
fetch c_pref_hierarchy into l_pref_hcy_id,l_pref_ovn;
 if c_pref_hierarchy%notfound then

-- Create the pef hierarchy with the name equals to preference_code
    l_object_version_number := null;
    hxc_pref_hierarchies_api.create_pref_hierarchies
                (p_type                     => 'USER'
                ,p_name                     => p_preference_code
                ,p_business_group_id	    => p_business_group_id
                ,p_legislation_code	    => p_legislation_code
                ,p_parent_pref_hierarchy_id => l_top_hcy_id
                ,p_edit_allowed             => 'Y'
                ,p_displayed                => 'Y'
                ,p_pref_definition_id       => p_preference_id
                ,p_attribute_category       => p_pref_attribute_category
                ,p_attribute1               => p_pref_attribute1
                ,p_attribute2               => p_pref_attribute2
                ,p_attribute3               => p_pref_attribute3
                ,p_attribute4               => p_pref_attribute4
                ,p_attribute5               => p_pref_attribute5
                ,p_attribute6               => p_pref_attribute6
                ,p_attribute7               => p_pref_attribute7
                ,p_attribute8               => p_pref_attribute8
                ,p_attribute9               => p_pref_attribute9
                ,p_attribute10              => p_pref_attribute10
                ,p_attribute11              => p_pref_attribute11
                ,p_attribute12              => p_pref_attribute12
                ,p_attribute13              => p_pref_attribute13
                ,p_attribute14              => p_pref_attribute14
                ,p_attribute15              => p_pref_attribute15
                ,p_attribute16              => p_pref_attribute16
                ,p_attribute17              => p_pref_attribute17
                ,p_attribute18              => p_pref_attribute18
                ,p_attribute19              => p_pref_attribute19
                ,p_attribute20              => p_pref_attribute20
                ,p_attribute21              => p_pref_attribute21
                ,p_attribute22              => p_pref_attribute22
                ,p_attribute23              => p_pref_attribute23
                ,p_attribute24              => p_pref_attribute24
                ,p_attribute25              => p_pref_attribute25
                ,p_attribute26              => p_pref_attribute26
                ,p_attribute27              => p_pref_attribute27
                ,p_attribute28              => p_pref_attribute28
                ,p_attribute29              => p_pref_attribute29
                ,p_attribute30              => p_pref_attribute30
                ,p_orig_pref_hierarchy_id   => null
                ,p_orig_parent_hierarchy_id => null
                ,p_pref_hierarchy_id        => l_pref_hcy_id
                ,p_object_version_number    => l_object_version_number);
 else
 	-- Update the preference hierarchy
        l_object_version_number := l_pref_ovn;
 	   hxc_pref_hierarchies_api.update_pref_hierarchies
                (p_effective_date           => sysdate
                ,p_type                     => 'USER'
                ,p_name                     => p_preference_code
                ,p_business_group_id	    => p_business_group_id
                ,p_legislation_code	    => p_legislation_code
                ,p_parent_pref_hierarchy_id => l_top_hcy_id
                ,p_edit_allowed             => 'Y'
                ,p_displayed                => 'Y'
                ,p_pref_definition_id       => p_preference_id
                ,p_attribute_category       => p_pref_attribute_category
                ,p_attribute1               => p_pref_attribute1
                ,p_attribute2               => p_pref_attribute2
                ,p_attribute3               => p_pref_attribute3
                ,p_attribute4               => p_pref_attribute4
                ,p_attribute5               => p_pref_attribute5
                ,p_attribute6               => p_pref_attribute6
                ,p_attribute7               => p_pref_attribute7
                ,p_attribute8               => p_pref_attribute8
                ,p_attribute9               => p_pref_attribute9
                ,p_attribute10              => p_pref_attribute10
                ,p_attribute11              => p_pref_attribute11
                ,p_attribute12              => p_pref_attribute12
                ,p_attribute13              => p_pref_attribute13
                ,p_attribute14              => p_pref_attribute14
                ,p_attribute15              => p_pref_attribute15
                ,p_attribute16              => p_pref_attribute16
                ,p_attribute17              => p_pref_attribute17
                ,p_attribute18              => p_pref_attribute18
                ,p_attribute19              => p_pref_attribute19
                ,p_attribute20              => p_pref_attribute20
                ,p_attribute21              => p_pref_attribute21
                ,p_attribute22              => p_pref_attribute22
                ,p_attribute23              => p_pref_attribute23
                ,p_attribute24              => p_pref_attribute24
                ,p_attribute25              => p_pref_attribute25
                ,p_attribute26              => p_pref_attribute26
                ,p_attribute27              => p_pref_attribute27
                ,p_attribute28              => p_pref_attribute28
                ,p_attribute29              => p_pref_attribute29
                ,p_attribute30              => p_pref_attribute30
                ,p_orig_pref_hierarchy_id   => null
                ,p_orig_parent_hierarchy_id => null
                ,p_pref_hierarchy_id        => l_pref_hcy_id
                ,p_object_version_number    => l_object_version_number);

 end if;
close c_pref_hierarchy;

-- Bug 3380737
-- Update the Top_most_Parent to reflect that the child preference has been created/modified.
	hxc_pref_hierarchies_api.update_pref_hierarchies
                (p_effective_date           => sysdate
		,p_type                     => 'USER'
                ,p_name                     => to_char(p_login_id)
                ,p_business_group_id	    => p_business_group_id
                ,p_legislation_code	    => p_legislation_code
                ,p_parent_pref_hierarchy_id => null
                ,p_edit_allowed             => 'Y'
                ,p_displayed                => 'Y'
                ,p_pref_definition_id       => null
                ,p_attribute_category       => null
                ,p_attribute1               => null
                ,p_attribute2               => null
                ,p_attribute3               => null
                ,p_attribute4               => null
                ,p_attribute5               => null
                ,p_attribute6               => null
                ,p_attribute7               => null
                ,p_attribute8               => null
                ,p_attribute9               => null
                ,p_attribute10              => null
                ,p_attribute11              => null
                ,p_attribute12              => null
                ,p_attribute13              => null
                ,p_attribute14              => null
                ,p_attribute15              => null
                ,p_attribute16              => null
                ,p_attribute17              => null
                ,p_attribute18              => null
                ,p_attribute19              => null
                ,p_attribute20              => null
                ,p_attribute21              => null
                ,p_attribute22              => null
                ,p_attribute23              => null
                ,p_attribute24              => null
                ,p_attribute25              => null
                ,p_attribute26              => null
                ,p_attribute27              => null
                ,p_attribute28              => null
                ,p_attribute29              => null
                ,p_attribute30              => null
                ,p_orig_pref_hierarchy_id   => null
                ,p_orig_parent_hierarchy_id => null
                ,p_pref_hierarchy_id        => l_top_hcy_id
                ,p_object_version_number    => l_top_ovn);

-- Check if the Rule exist
open c_resource_rule(l_top_hcy_id);
fetch c_resource_rule into l_dummy;
if c_resource_rule%notfound then

  l_object_version_number := null;
  -- Create the rule with the name equals to resource id
          hxc_resource_rules_api.create_resource_rules
               (p_name                        => to_char(p_login_id),
                p_business_group_id	      => p_business_group_id,
                p_legislation_code	      => p_legislation_code,
                p_eligibility_criteria_type   => 'LOGIN',
                p_eligibility_criteria_id     => to_char(p_login_id),
                p_pref_hierarchy_id           => l_top_hcy_id,
                p_rule_evaluation_order       => 0,
                p_resource_type               => 'PERSON',
                p_start_date                  => sysdate,
                p_end_date                    => null,
                p_resource_rule_id            => l_resource_rule_id,
                p_object_version_number       => l_object_version_number);

end if;
close c_resource_rule;

end manage_personal_pref;

end hxc_resource_personal_pref_pkg;

/
