--------------------------------------------------------
--  DDL for Package Body PER_GENERIC_HIERARCHY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_GENERIC_HIERARCHY_PKG" as
   /* $Header: peghrval.pkb 115.7 2002/12/05 16:47:34 pkakar noship $ */
   --
   /*
   +==============================================================================+
   |                        Copyright (c) 1997 Oracle Corporation                 |
   |                           Redwood Shores, California, USA                    |
   |                               All rights reserved.                           |
   +==============================================================================+
   --
   Name
   	Generic Hierarchy Package
   Purpose
   	This package is used to perform operations for the generic hierarchy
           form such as validating hierarchies and copying hierarchies.
   History
     Version    Date       Who        What?
     ---------  ---------  ---------- --------------------------------------------
     115.0      25-Jan-01  gperry     Created
     115.1      30-Jan-01  gperry     Changed min levels to 2 for VETS hierarchy.
     115.2      02-Jan-01  gperry     Changed level default value.
     115.3      13-Feb-01  gperry     Fixed copy_hierarchy procedure so that the
                                      l_parent_hierarchy_node_id is set to null
                                      before looping through the nodes for a
                                      copy. This fixes the invalid parent node
                                      problem.
     115.4      25-May-01  vshukhat   Changed c1 cursor for validate_number_of_levels
     115.5      17-Feb-02  nsinghal   Add DDF(Informations) Column
     115.7      05-Dec-02  pkakar     Added nocopy to parameters
 */
   --
   g_package varchar2(30) := 'per_generic_hierarchy_pkg.';
   --
   -- Validate level node types Routine
   --
   procedure validate_level_node_type(p_hierarchy_node_id in number,
                                      p_node_type         in varchar2,
                                      p_level_number      in number,
                                      p_iteration         in number default 2) is
     --
     l_proc           varchar2(80) := g_package||'validate_level_node_type';
     l_type           varchar2(30);
     --
     cursor c1 is
       select hierarchy_node_id,
              node_type
       from   per_gen_hierarchy_nodes
       where  parent_hierarchy_node_id = p_hierarchy_node_id;
     --
     cursor c2 is
       select node_type
       from   per_gen_hierarchy_nodes
       where  hierarchy_node_id = p_hierarchy_node_id;
     --
   begin
     --
     if p_level_number = 1 then
       --
       -- We are looking at the parent node so we don't have to recurse through
       -- the whole tree.
       --
       open c2;
         --
         fetch c2 into l_type;
         if l_type <> p_node_type then
           --
           close c2;
           fnd_message.set_name('PER','HR_289050_LEVEL_NODE_MISMATCH');
           fnd_message.set_token('LEVEL',p_level_number);
           fnd_message.set_token('TYPE',p_node_type);
           fnd_message.raise_error;
           --
         end if;
         --
       close c2;
       --
       return;
       --
     end if;
     --
     hr_utility.set_location('Entering '||l_proc,10);
     --
     for l_count in c1 loop
       --
       exit when c1%notfound;
       --
       -- Recursively search down tree and keep count of levels
       --
       if p_iteration = p_level_number and
          l_count.node_type <> p_node_type then
         --
         fnd_message.set_name('PER','HR_289050_LEVEL_NODE_MISMATCH');
         fnd_message.set_token('LEVEL',p_level_number);
         fnd_message.set_token('TYPE',p_node_type);
         fnd_message.raise_error;
         --
       end if;
       --
       validate_level_node_type
         (p_hierarchy_node_id => l_count.hierarchy_node_id,
          p_node_type         => p_node_type,
          p_level_number      => p_level_number,
          p_iteration         => p_iteration+1);
       --
     end loop;
     --
     hr_utility.set_location('Leaving '||l_proc,10);
     --
   end validate_level_node_type;
   --
   -- Get parent node for the hierarchy version routine
   --
   function get_parent_node(p_hierarchy_version_id in number) return number is
     --
     cursor c1 is
       select hierarchy_node_id
       from   per_gen_hierarchy_nodes
       where  hierarchy_version_id = p_hierarchy_version_id
       and    parent_hierarchy_node_id is null;
     --
     l_hierarchy_node_id number;
     l_proc              varchar2(80) := g_package||'get_parent_node';
     --
   begin
     --
     hr_utility.set_location('Entering '||l_proc,10);
     --
     open c1;
       --
       fetch c1 into l_hierarchy_node_id;
       --
     close c1;
     --
     hr_utility.set_location('Leaving '||l_proc,10);
     --
     return l_hierarchy_node_id;
     --
   end get_parent_node;
   --
   -- Validate number of levels routine
   --
   procedure validate_number_of_levels
     (p_hierarchy_version_id in number,
      p_min_levels           in number,
      p_max_levels           in number) is
     --
     l_proc           varchar2(80) := g_package||'validate_number_of_levels';
     l_count          number;
     --
   -- Bug 1802107 VS 25-MAY-2001
   --
   cursor c1 is
       select max(level)
       from   per_gen_hierarchy_nodes
       start  with parent_hierarchy_node_id is null
       and    hierarchy_version_id = p_hierarchy_version_id
       connect by prior hierarchy_node_id = parent_hierarchy_node_id
       and    hierarchy_version_id = p_hierarchy_version_id;
     --
   /*
   cursor c1 is
       select count(distinct nvl(parent_hierarchy_node_id,-1))
       from   per_gen_hierarchy_nodes
       where  hierarchy_version_id = p_hierarchy_version_id;
   */
     --
   begin
     --
     hr_utility.set_location('Entering '||l_proc,10);
     --
     open c1;
       --
       fetch c1 into l_count;
       --
     close c1;
     --
     if l_count < p_min_levels or
        l_count > p_max_levels then
       --
       fnd_message.set_name('PER','HR_289051_LEVEL_ERROR');
       fnd_message.set_token('NUM_LEVELS',l_count);
       fnd_message.set_token('MIN',p_min_levels);
       fnd_message.set_token('MAX',p_max_levels);
       fnd_message.raise_error;
       --
     end if;
     --
     hr_utility.set_location('Leaving '||l_proc,10);
     --
   end validate_number_of_levels;
   --
   -- Reporting checks for the VETS reports
   --
   procedure vets_reporting_checks(p_hierarchy_version_id in number) is
     --
     l_proc              varchar2(80) := g_package||'vets_reporting_checks';
     l_hierarchy_node_id number;
     --
   begin
     --
     hr_utility.set_location('Entering '||l_proc,10);
     --
     -- Vets Validation Checks include
     --
     -- 1) Must be Three node levels maximum
     -- 2) Parent level must be Org
     -- 3) Second , Third level must be Locations
     --
     -- Get parent node
     --
     l_hierarchy_node_id := get_parent_node
                            (p_hierarchy_version_id => p_hierarchy_version_id);
     --
     validate_number_of_levels(p_hierarchy_version_id => p_hierarchy_version_id,
                               p_min_levels           => 2,
                               p_max_levels           => 3);
     --
     validate_level_node_type(p_hierarchy_node_id => l_hierarchy_node_id,
                              p_node_type         => 'PAR',
                              p_level_number      => 1);
     --
     validate_level_node_type(p_hierarchy_node_id => l_hierarchy_node_id,
                              p_node_type         => 'EST',
                              p_level_number      => 2);
     --
     validate_level_node_type(p_hierarchy_node_id => l_hierarchy_node_id,
                              p_node_type         => 'LOC',
                              p_level_number      => 3);
     --
     hr_utility.set_location('Leaving '||l_proc,10);
     --
   end vets_reporting_checks;
   --
   -- Main routine to validate a hierarchy
   --
   procedure validate_hierarchy(p_hierarchy_version_id in number) is
     --
     l_proc           varchar2(80) := g_package||'validate_hierarchy';
     l_type           varchar2(30);
     --
     cursor c1 is
       select a.type
       from   per_gen_hierarchy a,
              per_gen_hierarchy_versions b
       where  a.hierarchy_id = b.hierarchy_id
       and    b.hierarchy_version_id = p_hierarchy_version_id;
     --
   begin
     --
     hr_utility.set_location('Entering '||l_proc,10);
     --
     -- Get Hierarchy Type
     --
     open c1;
       --
       fetch c1 into l_type;
       --
       if c1%notfound then
         --
         close c1;
         fnd_message.set_name('PER','HR_289052_HIER_NOT_FOUND');
         fnd_message.raise_error;
         --
       end if;
       --
     close c1;
     --
     if l_type = 'FEDREP' then
       --
       vets_reporting_checks(p_hierarchy_version_id => p_hierarchy_version_id);
       --
     else
       --
       fnd_message.set_name('PER','HR_289053_HIER_TYPE_UNKNOWN');
       fnd_message.raise_error;
       --
     end if;
     --
     hr_utility.set_location('Leaving '||l_proc,10);
     --
   end validate_hierarchy;
   --
   procedure copy_hierarchy(p_hierarchy_id     in  number,
                            p_name             in  varchar2,
                            p_effective_date   in  date,
                            p_out_hierarchy_id out nocopy number) is
     --
     l_proc                     varchar2(80) := g_package||'copy_hierarchy';
     l_object_version_number    number;
     l_hierarchy_id             number;
     l_hierarchy_version_id     number;
     l_hierarchy_node_id        number;
     l_parent_hierarchy_node_id number := null;
     --
     cursor c1 is
       select *
       from   per_gen_hierarchy
       where  hierarchy_id = p_hierarchy_id;
     --
     l_c1 c1%rowtype;
     --
     cursor c2 is
       select *
       from   per_gen_hierarchy_versions
       where  hierarchy_id = p_hierarchy_id;
     --
     l_c2 c2%rowtype;
     --
     cursor c3(p_hierarchy_version_id number) is
       select *
       from   per_gen_hierarchy_nodes a
       where  hierarchy_version_id = p_hierarchy_version_id
       order  by decode(parent_hierarchy_node_id,null,1,2);
     --
     l_c3 c3%rowtype;
     --
     cursor c4 is
       select d.hierarchy_node_id parent_hierarchy_node_id,
              a.hierarchy_node_id
       from   per_gen_hierarchy_nodes a,
              per_gen_hierarchy_nodes b,
              per_gen_hierarchy_nodes c,
              per_gen_hierarchy_nodes d
       where  a.hierarchy_version_id = l_hierarchy_version_id
       and    a.entity_id = b.entity_id
       and    a.node_type = b.node_type
       and    b.hierarchy_version_id = l_c2.hierarchy_version_id
       and    a.parent_hierarchy_node_id is not null
       and    b.parent_hierarchy_node_id = c.hierarchy_node_id
       and    c.entity_id = d.entity_id
       and    c.node_type = d.node_type
       and    c.hierarchy_version_id = l_c2.hierarchy_version_id
       and    d.hierarchy_version_id = l_hierarchy_version_id;
     --
     l_c4 c4%rowtype;
     --
   begin
     --
     hr_utility.set_location('Entering '||l_proc,10);
     --
     -- Basically to copy a hierarchy do the following
     --
     -- 1) Attempt to create the hierarchy.
     -- 2) loop through all versions and create them.
     -- 3) loop through all nodes and create them
     --
     open c1;
       --
       fetch c1 into l_c1;
       --
       if c1%notfound then
         --
         fnd_message.set_name('PER','HR_289054_NO_HIERARCHY');
         fnd_message.raise_error;
         --
       end if;
       --
     close c1;
     --
     per_hierarchy_api.create_hierarchy
       (p_hierarchy_id                   => l_hierarchy_id
       ,p_business_group_id              => l_c1.business_group_id
       ,p_name                           => p_name
       ,p_type                           => l_c1.type
       ,p_request_id                     => l_c1.request_id
       ,p_program_application_id         => l_c1.request_id
       ,p_program_id                     => l_c1.request_id
       ,p_program_update_date            => l_c1.program_update_date
       ,p_object_version_number          => l_object_version_number
       ,p_attribute_category             => l_c1.attribute_category
       ,p_attribute1                     => l_c1.attribute1
       ,p_attribute2                     => l_c1.attribute2
       ,p_attribute3                     => l_c1.attribute3
       ,p_attribute4                     => l_c1.attribute4
       ,p_attribute5                     => l_c1.attribute5
       ,p_attribute6                     => l_c1.attribute6
       ,p_attribute7                     => l_c1.attribute7
       ,p_attribute8                     => l_c1.attribute8
       ,p_attribute9                     => l_c1.attribute9
       ,p_attribute10                    => l_c1.attribute10
       ,p_attribute11                    => l_c1.attribute11
       ,p_attribute12                    => l_c1.attribute12
       ,p_attribute13                    => l_c1.attribute13
       ,p_attribute14                    => l_c1.attribute14
       ,p_attribute15                    => l_c1.attribute15
       ,p_attribute16                    => l_c1.attribute16
       ,p_attribute17                    => l_c1.attribute17
       ,p_attribute18                    => l_c1.attribute18
       ,p_attribute19                    => l_c1.attribute19
       ,p_attribute20                    => l_c1.attribute20
       ,p_attribute21                    => l_c1.attribute21
       ,p_attribute22                    => l_c1.attribute22
       ,p_attribute23                    => l_c1.attribute23
       ,p_attribute24                    => l_c1.attribute24
       ,p_attribute25                    => l_c1.attribute25
       ,p_attribute26                    => l_c1.attribute26
       ,p_attribute27                    => l_c1.attribute27
       ,p_attribute28                    => l_c1.attribute28
       ,p_attribute29                    => l_c1.attribute29
       ,p_attribute30                    => l_c1.attribute30
       ,p_information_category           => l_c1.information_category
       ,p_information1                   => l_c1.information1
       ,p_information2                   => l_c1.information2
       ,p_information3                   => l_c1.information3
       ,p_information4                   => l_c1.information4
       ,p_information5                   => l_c1.information5
       ,p_information6                   => l_c1.information6
       ,p_information7                   => l_c1.information7
       ,p_information8                   => l_c1.information8
       ,p_information9                   => l_c1.information9
       ,p_information10                  => l_c1.information10
       ,p_information11                  => l_c1.information11
       ,p_information12                  => l_c1.information12
       ,p_information13                  => l_c1.information13
       ,p_information14                  => l_c1.information14
       ,p_information15                  => l_c1.information15
       ,p_information16                  => l_c1.information16
       ,p_information17                  => l_c1.information17
       ,p_information18                  => l_c1.information18
       ,p_information19                  => l_c1.information19
       ,p_information20                  => l_c1.information20
       ,p_information21                  => l_c1.information21
       ,p_information22                  => l_c1.information22
       ,p_information23                  => l_c1.information23
       ,p_information24                  => l_c1.information24
       ,p_information25                  => l_c1.information25
       ,p_information26                  => l_c1.information26
       ,p_information27                  => l_c1.information27
       ,p_information28                  => l_c1.information28
       ,p_information29                  => l_c1.information29
       ,p_information30                  => l_c1.information30
       ,p_effective_date                 => p_effective_date);
     --
     open c2;
       --
       loop
         --
         fetch c2 into l_c2;
         exit when c2%notfound;
         --
         per_hierarchy_versions_api.create_hierarchy_versions
           (p_hierarchy_version_id   => l_hierarchy_version_id
           ,p_business_group_id      => l_c2.business_group_id
           ,p_version_number         => l_c2.version_number
           ,p_hierarchy_id           => l_hierarchy_id
           ,p_date_from              => l_c2.date_from
           ,p_date_to                => l_c2.date_to
           ,p_status                 => l_c2.status
           ,p_validate_flag          => l_c2.validate_flag
           ,p_request_id             => l_c2.request_id
           ,p_program_application_id => l_c2.program_application_id
           ,p_program_id             => l_c2.program_id
           ,p_program_update_date    => l_c2.program_update_date
           ,p_object_version_number  => l_object_version_number
           ,p_attribute_category     => l_c2.attribute_category
           ,p_attribute1             => l_c2.attribute1
           ,p_attribute2             => l_c2.attribute2
           ,p_attribute3             => l_c2.attribute3
           ,p_attribute4             => l_c2.attribute4
           ,p_attribute5             => l_c2.attribute5
           ,p_attribute6             => l_c2.attribute6
           ,p_attribute7             => l_c2.attribute7
           ,p_attribute8             => l_c2.attribute8
           ,p_attribute9             => l_c2.attribute9
           ,p_attribute10            => l_c2.attribute10
           ,p_attribute11            => l_c2.attribute11
           ,p_attribute12            => l_c2.attribute12
           ,p_attribute13            => l_c2.attribute13
           ,p_attribute14            => l_c2.attribute14
           ,p_attribute15            => l_c2.attribute15
           ,p_attribute16            => l_c2.attribute16
           ,p_attribute17            => l_c2.attribute17
           ,p_attribute18            => l_c2.attribute18
           ,p_attribute19            => l_c2.attribute19
           ,p_attribute20            => l_c2.attribute20
           ,p_attribute21            => l_c2.attribute21
           ,p_attribute22            => l_c2.attribute22
           ,p_attribute23            => l_c2.attribute23
           ,p_attribute24            => l_c2.attribute24
           ,p_attribute25            => l_c2.attribute25
           ,p_attribute26            => l_c2.attribute26
           ,p_attribute27            => l_c2.attribute27
           ,p_attribute28            => l_c2.attribute28
           ,p_attribute29            => l_c2.attribute29
           ,p_attribute30            => l_c2.attribute30
           ,p_information_category   => l_c2.information_category
           ,p_information1           => l_c2.information1
           ,p_information2           => l_c2.information2
           ,p_information3           => l_c2.information3
           ,p_information4           => l_c2.information4
           ,p_information5           => l_c2.information5
           ,p_information6           => l_c2.information6
           ,p_information7           => l_c2.information7
           ,p_information8           => l_c2.information8
           ,p_information9           => l_c2.information9
           ,p_information10          => l_c2.information10
           ,p_information11          => l_c2.information11
           ,p_information12          => l_c2.information12
           ,p_information13          => l_c2.information13
           ,p_information14          => l_c2.information14
           ,p_information15          => l_c2.information15
           ,p_information16          => l_c2.information16
           ,p_information17          => l_c2.information17
           ,p_information18          => l_c2.information18
           ,p_information19          => l_c2.information19
           ,p_information20          => l_c2.information20
           ,p_information21          => l_c2.information21
           ,p_information22          => l_c2.information22
           ,p_information23          => l_c2.information23
           ,p_information24          => l_c2.information24
           ,p_information25          => l_c2.information25
           ,p_information26          => l_c2.information26
           ,p_information27          => l_c2.information27
           ,p_information28          => l_c2.information28
           ,p_information29          => l_c2.information29
           ,p_information30          => l_c2.information30
           ,p_effective_date         => p_effective_date);
         --
         l_parent_hierarchy_node_id := null;
         --
         open c3(l_c2.hierarchy_version_id);
           --
           loop
             --
             fetch c3 into l_c3;
             exit when c3%notfound;
             --
             per_hierarchy_nodes_api.create_hierarchy_nodes
               (p_hierarchy_node_id              => l_hierarchy_node_id
               ,p_business_group_id              => l_c3.business_group_id
               ,p_entity_id                      => l_c3.entity_id
               ,p_hierarchy_version_id           => l_hierarchy_version_id
               ,p_node_type                      => l_c3.node_type
               ,p_seq                            => l_c3.seq
               ,p_parent_hierarchy_node_id       => l_parent_hierarchy_node_id
               ,p_request_id                     => l_c3.request_id
               ,p_program_application_id         => l_c3.program_application_id
               ,p_program_id                     => l_c3.program_id
               ,p_program_update_date            => l_c3.program_update_date
               ,p_object_version_number          => l_object_version_number
               ,p_attribute_category             => l_c3.attribute_category
               ,p_attribute1                     => l_c3.attribute1
               ,p_attribute2                     => l_c3.attribute2
               ,p_attribute3                     => l_c3.attribute3
               ,p_attribute4                     => l_c3.attribute4
               ,p_attribute5                     => l_c3.attribute5
               ,p_attribute6                     => l_c3.attribute6
               ,p_attribute7                     => l_c3.attribute7
               ,p_attribute8                     => l_c3.attribute8
               ,p_attribute9                     => l_c3.attribute9
               ,p_attribute10                    => l_c3.attribute10
               ,p_attribute11                    => l_c3.attribute11
               ,p_attribute12                    => l_c3.attribute12
               ,p_attribute13                    => l_c3.attribute13
               ,p_attribute14                    => l_c3.attribute14
               ,p_attribute15                    => l_c3.attribute15
               ,p_attribute16                    => l_c3.attribute16
               ,p_attribute17                    => l_c3.attribute17
               ,p_attribute18                    => l_c3.attribute18
               ,p_attribute19                    => l_c3.attribute19
               ,p_attribute20                    => l_c3.attribute20
               ,p_attribute21                    => l_c3.attribute21
               ,p_attribute22                    => l_c3.attribute22
               ,p_attribute23                    => l_c3.attribute23
               ,p_attribute24                    => l_c3.attribute24
               ,p_attribute25                    => l_c3.attribute25
               ,p_attribute26                    => l_c3.attribute26
               ,p_attribute27                    => l_c3.attribute27
               ,p_attribute28                    => l_c3.attribute28
               ,p_attribute29                    => l_c3.attribute29
               ,p_attribute30                    => l_c3.attribute30
               ,p_information_category           => l_c3.information_category
              ,p_information1                    => l_c3.information1
              ,p_information2                    => l_c3.information2
              ,p_information3                    => l_c3.information3
              ,p_information4                    => l_c3.information4
              ,p_information5                    => l_c3.information5
              ,p_information6                    => l_c3.information6
              ,p_information7                    => l_c3.information7
              ,p_information8                    => l_c3.information8
              ,p_information9                    => l_c3.information9
              ,p_information10                   => l_c3.information10
              ,p_information11                   => l_c3.information11
              ,p_information12                   => l_c3.information12
              ,p_information13                   => l_c3.information13
              ,p_information14                   => l_c3.information14
              ,p_information15                   => l_c3.information15
              ,p_information16                   => l_c3.information16
              ,p_information17                   => l_c3.information17
              ,p_information18                   => l_c3.information18
              ,p_information19                   => l_c3.information19
              ,p_information20                   => l_c3.information20
              ,p_information21                   => l_c3.information21
              ,p_information22                   => l_c3.information22
              ,p_information23                   => l_c3.information23
              ,p_information24                   => l_c3.information24
              ,p_information25                   => l_c3.information25
              ,p_information26                   => l_c3.information26
              ,p_information27                   => l_c3.information27
              ,p_information28                   => l_c3.information28
              ,p_information29                   => l_c3.information29
              ,p_information30                   => l_c3.information30
              ,p_effective_date                  => p_effective_date);
             --
             l_parent_hierarchy_node_id := l_hierarchy_node_id;
             --
           end loop;
           --
           -- Now update each of the rows with its correct parent based on
           -- the parent definitions of the original version.
           -- Remember within a hierarchy the node type and entity id must be
           -- unique.
           --
           open c4;
             --
             loop
               --
               fetch c4 into l_c4;
               exit when c4%notfound;
               --
               update per_gen_hierarchy_nodes
               set    parent_hierarchy_node_id = l_c4.parent_hierarchy_node_id
               where  hierarchy_node_id = l_c4.hierarchy_node_id;
               --
             end loop;
             --
           close c4;
           --
         close c3;
         --
       end loop;
       --
     close c2;
     --
     hr_utility.set_location('Leaving '||l_proc,10);
     --
     p_out_hierarchy_id := l_hierarchy_id;
     --
     commit;
     --
   end copy_hierarchy;
   --
   procedure copy_hierarchy_version(p_hierarchy_version_id     in  number,
                                    p_new_version_number       in  number,
                                    p_date_from                in  date,
                                    p_date_to                  in  date,
                                    p_effective_date           in  date,
                                    p_out_hierarchy_version_id out nocopy number) is
     --
     l_proc                     varchar2(80) := g_package||'copy_hierarchy_version';
     l_hierarchy_version_id     number;
     l_hierarchy_node_id        number;
     l_parent_hierarchy_node_id number;
     l_object_version_number    number;
     --
     cursor c1 is
       select *
       from   per_gen_hierarchy_versions
       where  hierarchy_version_id = p_hierarchy_version_id;
     --
     l_c1 c1%rowtype;
     --
     cursor c2 is
       select *
       from   per_gen_hierarchy_nodes a
       where  hierarchy_version_id = p_hierarchy_version_id
       order  by decode(parent_hierarchy_node_id,null,1,2);
     --
     l_c2 c2%rowtype;
     --
     cursor c3 is
       select d.hierarchy_node_id parent_hierarchy_node_id,
              a.hierarchy_node_id
       from   per_gen_hierarchy_nodes a,
              per_gen_hierarchy_nodes b,
              per_gen_hierarchy_nodes c,
              per_gen_hierarchy_nodes d
       where  a.hierarchy_version_id = l_hierarchy_version_id
       and    a.entity_id = b.entity_id
       and    a.node_type = b.node_type
       and    b.hierarchy_version_id = p_hierarchy_version_id
       and    a.parent_hierarchy_node_id is not null
       and    b.parent_hierarchy_node_id = c.hierarchy_node_id
       and    c.entity_id = d.entity_id
       and    c.node_type = d.node_type
       and    c.hierarchy_version_id = p_hierarchy_version_id
       and    d.hierarchy_version_id = l_hierarchy_version_id;
     --
     l_c3 c3%rowtype;
     --
   begin
     --
     hr_utility.set_location('Entering '||l_proc,10);
     --
     -- 1) Create hierarchy version
     -- 2) Create all nodes for hierarchy version
     -- 3) Link the nodes to the correct parents
     --
     open c1;
       --
       fetch c1 into l_c1;
       if c1%notfound then
         --
         fnd_message.set_name('PER','HR_289055_NO_VERSION');
         fnd_message.raise_error;
         --
       end if;
       --
     close c1;
     --
     per_hierarchy_versions_api.create_hierarchy_versions
       (p_hierarchy_version_id   => l_hierarchy_version_id
       ,p_business_group_id      => l_c1.business_group_id
       ,p_version_number         => p_new_version_number
       ,p_hierarchy_id           => l_c1.hierarchy_id
       ,p_date_from              => p_date_from
       ,p_date_to                => p_date_to
       ,p_status                 => l_c1.status
       ,p_validate_flag          => l_c1.validate_flag
       ,p_request_id             => l_c1.request_id
       ,p_program_application_id => l_c1.program_application_id
       ,p_program_id             => l_c1.program_id
       ,p_program_update_date    => l_c1.program_update_date
       ,p_object_version_number  => l_object_version_number
       ,p_attribute_category     => l_c1.attribute_category
       ,p_attribute1             => l_c1.attribute1
       ,p_attribute2             => l_c1.attribute2
       ,p_attribute3             => l_c1.attribute3
       ,p_attribute4             => l_c1.attribute4
       ,p_attribute5             => l_c1.attribute5
       ,p_attribute6             => l_c1.attribute6
       ,p_attribute7             => l_c1.attribute7
       ,p_attribute8             => l_c1.attribute8
       ,p_attribute9             => l_c1.attribute9
       ,p_attribute10            => l_c1.attribute10
       ,p_attribute11            => l_c1.attribute11
       ,p_attribute12            => l_c1.attribute12
       ,p_attribute13            => l_c1.attribute13
       ,p_attribute14            => l_c1.attribute14
       ,p_attribute15            => l_c1.attribute15
       ,p_attribute16            => l_c1.attribute16
       ,p_attribute17            => l_c1.attribute17
       ,p_attribute18            => l_c1.attribute18
       ,p_attribute19            => l_c1.attribute19
       ,p_attribute20            => l_c1.attribute20
       ,p_attribute21            => l_c1.attribute21
       ,p_attribute22            => l_c1.attribute22
       ,p_attribute23            => l_c1.attribute23
       ,p_attribute24            => l_c1.attribute24
       ,p_attribute25            => l_c1.attribute25
       ,p_attribute26            => l_c1.attribute26
       ,p_attribute27            => l_c1.attribute27
       ,p_attribute28            => l_c1.attribute28
       ,p_attribute29            => l_c1.attribute29
       ,p_attribute30            => l_c1.attribute30
       ,p_information_category   => l_c1.information_category
       ,p_information1           => l_c1.information1
       ,p_information2           => l_c1.information2
       ,p_information3           => l_c1.information3
       ,p_information4           => l_c1.information4
       ,p_information5           => l_c1.information5
       ,p_information6           => l_c1.information6
       ,p_information7           => l_c1.information7
       ,p_information8           => l_c1.information8
       ,p_information9           => l_c1.information9
       ,p_information10          => l_c1.information10
       ,p_information11          => l_c1.information11
       ,p_information12          => l_c1.information12
       ,p_information13          => l_c1.information13
       ,p_information14          => l_c1.information14
       ,p_information15          => l_c1.information15
       ,p_information16          => l_c1.information16
       ,p_information17          => l_c1.information17
       ,p_information18          => l_c1.information18
       ,p_information19          => l_c1.information19
       ,p_information20          => l_c1.information20
       ,p_information21          => l_c1.information21
       ,p_information22          => l_c1.information22
       ,p_information23          => l_c1.information23
       ,p_information24          => l_c1.information24
       ,p_information25          => l_c1.information25
       ,p_information26          => l_c1.information26
       ,p_information27          => l_c1.information27
       ,p_information28          => l_c1.information28
       ,p_information29          => l_c1.information29
       ,p_information30          => l_c1.information30
       ,p_effective_date         => p_effective_date);
     --
     --
     l_parent_hierarchy_node_id := null;
     --
     open c2;
       --
       loop
         --
         fetch c2 into l_c2;
         exit when c2%notfound;
         --
         per_hierarchy_nodes_api.create_hierarchy_nodes
           (p_hierarchy_node_id              => l_hierarchy_node_id
           ,p_business_group_id              => l_c2.business_group_id
           ,p_entity_id                      => l_c2.entity_id
           ,p_hierarchy_version_id           => l_hierarchy_version_id
           ,p_node_type                      => l_c2.node_type
           ,p_seq                            => l_c2.seq
           ,p_parent_hierarchy_node_id       => l_parent_hierarchy_node_id
           ,p_request_id                     => l_c2.request_id
           ,p_program_application_id         => l_c2.program_application_id
           ,p_program_id                     => l_c2.program_id
           ,p_program_update_date            => l_c2.program_update_date
           ,p_object_version_number          => l_object_version_number
           ,p_attribute_category             => l_c2.attribute_category
           ,p_attribute1                     => l_c2.attribute1
           ,p_attribute2                     => l_c2.attribute2
           ,p_attribute3                     => l_c2.attribute3
           ,p_attribute4                     => l_c2.attribute4
           ,p_attribute5                     => l_c2.attribute5
           ,p_attribute6                     => l_c2.attribute6
           ,p_attribute7                     => l_c2.attribute7
           ,p_attribute8                     => l_c2.attribute8
           ,p_attribute9                     => l_c2.attribute9
           ,p_attribute10                    => l_c2.attribute10
           ,p_attribute11                    => l_c2.attribute11
           ,p_attribute12                    => l_c2.attribute12
           ,p_attribute13                    => l_c2.attribute13
           ,p_attribute14                    => l_c2.attribute14
           ,p_attribute15                    => l_c2.attribute15
           ,p_attribute16                    => l_c2.attribute16
           ,p_attribute17                    => l_c2.attribute17
           ,p_attribute18                    => l_c2.attribute18
           ,p_attribute19                    => l_c2.attribute19
           ,p_attribute20                    => l_c2.attribute20
           ,p_attribute21                    => l_c2.attribute21
           ,p_attribute22                    => l_c2.attribute22
           ,p_attribute23                    => l_c2.attribute23
           ,p_attribute24                    => l_c2.attribute24
           ,p_attribute25                    => l_c2.attribute25
           ,p_attribute26                    => l_c2.attribute26
           ,p_attribute27                    => l_c2.attribute27
           ,p_attribute28                    => l_c2.attribute28
           ,p_attribute29                    => l_c2.attribute29
           ,p_attribute30                    => l_c2.attribute30
           ,p_information_category           => l_c2.information_category
           ,p_information1                   => l_c2.information1
           ,p_information2                   => l_c2.information2
           ,p_information3                   => l_c2.information3
           ,p_information4                   => l_c2.information4
           ,p_information5                   => l_c2.information5
           ,p_information6                   => l_c2.information6
           ,p_information7                   => l_c2.information7
           ,p_information8                   => l_c2.information8
           ,p_information9                   => l_c2.information9
           ,p_information10                  => l_c2.information10
           ,p_information11                  => l_c2.information11
           ,p_information12                  => l_c2.information12
           ,p_information13                  => l_c2.information13
           ,p_information14                  => l_c2.information14
           ,p_information15                  => l_c2.information15
           ,p_information16                  => l_c2.information16
           ,p_information17                  => l_c2.information17
           ,p_information18                  => l_c2.information18
           ,p_information19                  => l_c2.information19
           ,p_information20                  => l_c2.information20
           ,p_information21                  => l_c2.information21
           ,p_information22                  => l_c2.information22
           ,p_information23                  => l_c2.information23
           ,p_information24                  => l_c2.information24
           ,p_information25                  => l_c2.information25
           ,p_information26                  => l_c2.information26
           ,p_information27                  => l_c2.information27
           ,p_information28                  => l_c2.information28
           ,p_information29                  => l_c2.information29
           ,p_information30                  => l_c2.information30
           ,p_effective_date                 => p_effective_date);
         --
         l_parent_hierarchy_node_id := l_hierarchy_node_id;
         --
       end loop;
       --
     close c2;
     --
     -- Now update each of the rows with its correct parent based on
     -- the parent definitions of the original version.
     -- Remember within a hierarchy the node type and entity id must be
     -- unique.
     --
     open c3;
       --
       loop
         --
         fetch c3 into l_c3;
         exit when c3%notfound;
         --
         update per_gen_hierarchy_nodes
         set    parent_hierarchy_node_id = l_c3.parent_hierarchy_node_id
         where  hierarchy_node_id = l_c3.hierarchy_node_id;
         --
       end loop;
       --
     close c3;
     --
     p_out_hierarchy_version_id := l_hierarchy_version_id;
     --
     hr_utility.set_location('Leaving '||l_proc,10);
     --
   end copy_hierarchy_version;
   --
   end per_generic_hierarchy_pkg;

/
