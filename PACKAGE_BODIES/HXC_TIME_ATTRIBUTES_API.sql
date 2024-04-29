--------------------------------------------------------
--  DDL for Package Body HXC_TIME_ATTRIBUTES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TIME_ATTRIBUTES_API" as
/* $Header: hxctatapi.pkb 120.4 2005/10/23 02:14:30 gkrishna noship $ */

g_package varchar2(33) := '  hxc_time_attributes_api.';

g_debug boolean := hr_utility.debug_enabled;

-- private procedure
--   extract_info_types
--
-- description
--   returns an array of distinct information types from the timecard
--   parameter passed into the hxc_deposit_process_pkg.execute_deposit_process
--   procedure.  used by parse_table to extract attributes from the timecard
--   structure prior to insertion into hxc_time_attributes.
--
-- parameters
--   p_timecard         - pl/sql table of attributes
--   p_info_types (out) - array of distinct information types

procedure extract_info_types
  (p_timecard   in     timecard
  ,p_info_types in out nocopy info_type_table
  ) is

l_tc_loop           number:=1;
l_it_loop           number:=1;
l_info_types        info_type_table;
l_info_type_noted   boolean;

l_proc varchar2(30);
l_gaz varchar2(3);

begin


  --if g_debug then
  	--l_proc := 'extract_info_types ';
  	--hr_utility.set_location('gaz: '|| l_proc, 50);
  --end if;
  -- initialize array.  the maximum number of distinct information types
  -- is equal to the number of attributes in the timecard
  --l_gaz := to_char(p_timecard.count);
  --if g_debug then
  	--hr_utility.set_location('gaz count is  '|| l_gaz, 60);
  --end if;
  for l_rownum in 1..p_timecard.count loop
  --if g_debug then
  	--hr_utility.set_location('gaz: '|| l_proc, 60);
  --end if;
    l_info_types(l_rownum):=null;
  end loop;

  -- identify distinct information types and store them by iterative
  -- comparison of timecard and information type array
  --if g_debug then
  	--hr_utility.set_location('gaz: '|| l_proc, 70);
  --end if;
  l_info_types(l_it_loop) := p_timecard(l_tc_loop).information_type;

  for l_tc_loop in 1..p_timecard.count loop
  --if g_debug then
  	--hr_utility.set_location('gaz: '|| l_proc, 80);
  --end if;
    if p_timecard(l_tc_loop).information_type <> l_info_types(l_it_loop) then
      loop
  --if g_debug then
  	--hr_utility.set_location('gaz: '|| l_proc, 90);
  --end if;
        l_it_loop:=l_it_loop+1;
        if p_timecard(l_tc_loop).information_type = l_info_types(l_it_loop) then
  --if g_debug then
  	--hr_utility.set_location('gaz: '|| l_proc, 100);
  --end if;
          l_info_type_noted := true;
        end if;
  --if g_debug then
  	--hr_utility.set_location('gaz: '|| l_proc, 150);
  --end if;
        exit when l_info_types(l_it_loop) is null;
      end loop;
      if not l_info_type_noted then
  --if g_debug then
  	--hr_utility.set_location('gaz: '|| l_proc, 160);
  --end if;
        l_info_types(l_it_loop) := p_timecard(l_tc_loop).information_type;
      end if;
    end if;
    l_it_loop := 1;
  --if g_debug then
  	--hr_utility.set_location('gaz: '|| l_proc, 170);
  --end if;
    l_info_type_noted := false;
  end loop;
  --if g_debug then
  	--hr_utility.set_location('gaz: '|| l_proc, 180);
  --end if;

  -- delete empty cells from information type array
  for l_it_loop in 1..p_timecard.count loop
  --if g_debug then
  	--hr_utility.set_location('gaz: '|| l_proc, 190);
  --end if;
    if l_info_types(l_it_loop) is null then
  --if g_debug then
  	--hr_utility.set_location('gaz: '|| l_proc, 200);
  --end if;
      l_info_types.delete(l_it_loop);
    end if;
  end loop;

  --if g_debug then
  	--hr_utility.set_location('gaz: '|| l_proc, 210);
  --end if;
  -- assign out parameter
  p_info_types := l_info_types;

end extract_info_types;


-- private procedure
--   parse_table
--
-- description
--   breaks down the pl/sql table passed to the deposit api into
--   its component attributes, prior to calling the HXC_TIME_ATTRIBUTES
--   row handler
--
-- parameters
--   p_process_id       - deposit process id
--   p_timecard         - attribute table
--   p_information_type - information type of attributes to parse
--   p_attribute1..30   - out parameters to contain mapped attribute values

procedure parse_table
  (p_process_id       in     number
  ,p_timecard         in     timecard
  ,p_information_type in     varchar2
  ,p_attribute1       in out nocopy varchar2
  ,p_attribute2       in out nocopy varchar2
  ,p_attribute3       in out nocopy varchar2
  ,p_attribute4       in out nocopy varchar2
  ,p_attribute5       in out nocopy varchar2
  ,p_attribute6       in out nocopy varchar2
  ,p_attribute7       in out nocopy varchar2
  ,p_attribute8       in out nocopy varchar2
  ,p_attribute9       in out nocopy varchar2
  ,p_attribute10      in out nocopy varchar2
  ,p_attribute11      in out nocopy varchar2
  ,p_attribute12      in out nocopy varchar2
  ,p_attribute13      in out nocopy varchar2
  ,p_attribute14      in out nocopy varchar2
  ,p_attribute15      in out nocopy varchar2
  ,p_attribute16      in out nocopy varchar2
  ,p_attribute17      in out nocopy varchar2
  ,p_attribute18      in out nocopy varchar2
  ,p_attribute19      in out nocopy varchar2
  ,p_attribute20      in out nocopy varchar2
  ,p_attribute21      in out nocopy varchar2
  ,p_attribute22      in out nocopy varchar2
  ,p_attribute23      in out nocopy varchar2
  ,p_attribute24      in out nocopy varchar2
  ,p_attribute25      in out nocopy varchar2
  ,p_attribute26      in out nocopy varchar2
  ,p_attribute27      in out nocopy varchar2
  ,p_attribute28      in out nocopy varchar2
  ,p_attribute29      in out nocopy varchar2
  ,p_attribute30      in out nocopy varchar2
  ,p_attribute_category in out nocopy varchar2
  ) is

type attribute_cluster is table of varchar2(150) index by binary_integer;
l_att_rec attribute_cluster;

l_rownum           number;
l_mapping_exists   boolean;
l_column_name      varchar2(30);
l_column_number    number;
l_information_type hxc_bld_blk_info_types.bld_blk_info_type%type;
l_set_attribute_category boolean := false;

e_no_attribute_mapping exception;

l_proc varchar2(30);

begin


  -- initialize local attribute array
  --if g_debug then
  	--l_proc := ' parse_Table';
  	--hr_utility.set_location('gaz: '|| l_proc, 10);
  --end if;
  for l_rownum in 1..30 loop
    l_att_rec(l_rownum) := null;
  end loop;

  --if g_debug then
  	--hr_utility.set_location('gaz: '|| l_proc, 20);
  --end if;
  -- load attribute values from table into mapped position in local array
  for l_rownum in 1..p_timecard.count loop

  --if g_debug then
  	--hr_utility.set_location('gaz: '|| l_proc, 30);
  --end if;
    -- check that a mapping exists for the named attribute in the current
    -- deposit process
    /*l_mapping_exists := hxc_mapping_utilities.attribute_column
                          (p_timecard(l_rownum).attribute_name
                          ,'D'
                          ,p_process_id
                          ,l_column_name
                          ,l_information_type
                          );
    */
  --if g_debug then
  	--hr_utility.set_location('gaz: '|| l_proc, 40);
  --end if;
 --   if (l_mapping_exists) then
      -- copy attribute value from timecard to local array
 --if g_debug then
 	-- hr_utility.set_location('gaz: '|| l_proc, 50);
 	  --hr_utility.set_location('l info type is '|| l_information_type, 40);
 	 --hr_utility.set_location('p info type is '|| p_information_type, 40);
	 -- hr_utility.set_location('l column name is '|| l_column_name, 40);
 --end if;
   l_column_name      := p_timecard(l_rownum).column_name;
   l_information_type := p_timecard(l_rownum).info_mapping_type;

   IF (l_column_name is not null) and (l_information_type is not null) THEN
      if l_information_type = p_information_type then
	if l_column_name = 'ATTRIBUTE_CATEGORY' then
	  p_attribute_category := p_timecard(l_rownum).attribute_value;
          l_set_attribute_category := true;
        else
          l_column_number := to_number(ltrim(l_column_name, 'ATTRIBUTE'));
          l_att_rec(l_column_number) := p_timecard(l_rownum).attribute_value;
	end if;
      end if;
    else
      -- if no mapping exists then we have issues
      raise e_no_attribute_mapping;
    end if;

  end loop;

  -- MV: Added the OR part
  -- We need this because the previous checks do not work very well and
  -- therefore there is a chance that the attribute_category does not get
  -- set. When you use the TimeStore Deposit API, and you do not supply
  -- the attribute_category, it will get created anyway by the deposit
  -- wrapper.  However the attribute_value for this record will be NULL
  -- so in the previous checks, p_attribute_category is set to NULL and
  -- l_set_attribute_category set to true.  This means the next check
  -- would not evaluate to true and p_attribute_category stays NULL.
  -- With the added OR, we make sure p_attribute_category gets set.
  if (NOT l_set_attribute_category) OR (p_attribute_category IS NULL) then
   -- make sure the attribute category is set to the information type
   -- if the attribute category is not part of the mapping
    p_attribute_category := p_information_type;
  end if;

  -- copy local array to output parameters
  --if g_debug then
  	--hr_utility.set_location('gaz: '|| l_proc, 70);
  --end if;
  p_attribute1  := l_att_rec(1);
  p_attribute2  := l_att_rec(2);
  p_attribute3  := l_att_rec(3);
  p_attribute4  := l_att_rec(4);
  p_attribute5  := l_att_rec(5);
  p_attribute6  := l_att_rec(6);
  p_attribute7  := l_att_rec(7);
  p_attribute8  := l_att_rec(8);
  p_attribute9  := l_att_rec(9);
  p_attribute10 := l_att_rec(10);
  --if g_debug then
  	--hr_utility.set_location('gaz: '|| l_proc, 80);
  --end if;
  p_attribute11 := l_att_rec(11);
  p_attribute12 := l_att_rec(12);
  p_attribute13 := l_att_rec(13);
  p_attribute14 := l_att_rec(14);
  p_attribute15 := l_att_rec(15);
  p_attribute16 := l_att_rec(16);
  p_attribute17 := l_att_rec(17);
  p_attribute18 := l_att_rec(18);
  p_attribute19 := l_att_rec(19);
  p_attribute20 := l_att_rec(20);
 --if g_debug then
 	-- hr_utility.set_location('gaz: '|| l_proc, 90);
 --end if;
  p_attribute21 := l_att_rec(21);
  p_attribute22 := l_att_rec(22);
  p_attribute23 := l_att_rec(23);
  p_attribute24 := l_att_rec(24);
  p_attribute25 := l_att_rec(25);
  p_attribute26 := l_att_rec(26);
  p_attribute27 := l_att_rec(27);
  p_attribute28 := l_att_rec(28);
  p_attribute29 := l_att_rec(29);
  p_attribute30 := l_att_rec(30);
  --if g_debug then
  	--hr_utility.set_location('gaz: '|| l_proc, 100);
  --end if;

exception
  when e_no_attribute_mapping then
    fnd_message.set_name('HXC', 'HXC_NO_PROCESS_MAPPING');
    fnd_message.raise_error;
  when others then
    raise;

end parse_table;


-- ---------------------------------------------------------------------------
-- |---------------------< create_attributes >-------------------------------|
-- ---------------------------------------------------------------------------

procedure create_attributes
  (p_validate               in     boolean default false
  ,p_timecard               in     timecard
  ,p_process_id             in     number
  ,p_time_building_block_id in     number
  ,p_tbb_ovn                in     number
  ,p_time_attribute_id      in out nocopy number
  ,p_object_version_number  in out nocopy number
  ) is

--cursor c_attribute_usage_sequence is
--  select hxc_time_attribute_usages_s.nextval from dual;      -- refer Bug#3062133

cursor c_bld_blk_info_type_id(p_bld_blk_info_type varchar2) is
  select bld_blk_info_type_id
  from hxc_bld_blk_info_types
  where bld_blk_info_type = p_bld_blk_info_type;

cursor c_get_data_set(p_tbb_id number,p_tbb_ovn number)
is
select data_set_id from hxc_time_building_blocks
where time_building_block_id = p_tbb_id
and object_version_number = p_tbb_ovn;


l_proc                    varchar2(72);

l_object_version_number   hxc_time_attributes.object_version_number%type;
l_time_attribute_id       hxc_time_attributes.time_attribute_id%type;
l_time_attribute_usage_id number;
l_rownum                  number;
l_info_type_table         info_type_table;
l_information_type        varchar2(80);
l_bld_blk_info_type_id    hxc_bld_blk_info_types.bld_blk_info_type_id%TYPE;

l_attribute1              hxc_time_attributes.attribute1%TYPE;
l_attribute2              hxc_time_attributes.attribute2%TYPE;
l_attribute3              hxc_time_attributes.attribute3%TYPE;
l_attribute4              hxc_time_attributes.attribute4%TYPE;
l_attribute5              hxc_time_attributes.attribute5%TYPE;
l_attribute6              hxc_time_attributes.attribute6%TYPE;
l_attribute7              hxc_time_attributes.attribute7%TYPE;
l_attribute8              hxc_time_attributes.attribute8%TYPE;
l_attribute9              hxc_time_attributes.attribute9%TYPE;
l_attribute10             hxc_time_attributes.attribute10%TYPE;
l_attribute11             hxc_time_attributes.attribute11%TYPE;
l_attribute12             hxc_time_attributes.attribute12%TYPE;
l_attribute13             hxc_time_attributes.attribute13%TYPE;
l_attribute14             hxc_time_attributes.attribute14%TYPE;
l_attribute15             hxc_time_attributes.attribute15%TYPE;
l_attribute16             hxc_time_attributes.attribute16%TYPE;
l_attribute17             hxc_time_attributes.attribute17%TYPE;
l_attribute18             hxc_time_attributes.attribute18%TYPE;
l_attribute19             hxc_time_attributes.attribute19%TYPE;
l_attribute20             hxc_time_attributes.attribute20%TYPE;
l_attribute21             hxc_time_attributes.attribute21%TYPE;
l_attribute22             hxc_time_attributes.attribute22%TYPE;
l_attribute23             hxc_time_attributes.attribute23%TYPE;
l_attribute24             hxc_time_attributes.attribute24%TYPE;
l_attribute25             hxc_time_attributes.attribute25%TYPE;
l_attribute26             hxc_time_attributes.attribute26%TYPE;
l_attribute27             hxc_time_attributes.attribute27%TYPE;
l_attribute28             hxc_time_attributes.attribute28%TYPE;
l_attribute29             hxc_time_attributes.attribute29%TYPE;
l_attribute30             hxc_time_attributes.attribute30%TYPE;
l_attribute_category      hxc_time_attributes.attribute_category%TYPE := null;

l_data_set_id hxc_time_attributes.data_set_id%type;
e_usage_data_missing exception;
begin

  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'create_attributes';
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;

  -- break down the timecard into its component attributes

  extract_info_types
    (p_timecard   => p_timecard
    ,p_info_types => l_info_type_table
    );

  if g_debug then
  	hr_utility.set_location('gaz: '|| l_proc, 50);
  end if;

  for l_rownum in 1..l_info_type_table.count loop

    l_information_type := l_info_type_table(l_rownum);

  if g_debug then
  	hr_utility.set_location('gaz: '|| l_proc, 60);
  end if;

    parse_table
      (p_process_id       => p_process_id
      ,p_timecard         => p_timecard
      ,p_information_type => l_information_type
      ,p_attribute1       => l_attribute1
      ,p_attribute2       => l_attribute2
      ,p_attribute3       => l_attribute3
      ,p_attribute4       => l_attribute4
      ,p_attribute5       => l_attribute5
      ,p_attribute6       => l_attribute6
      ,p_attribute7       => l_attribute7
      ,p_attribute8       => l_attribute8
      ,p_attribute9       => l_attribute9
      ,p_attribute10      => l_attribute10
      ,p_attribute11      => l_attribute11
      ,p_attribute12      => l_attribute12
      ,p_attribute13      => l_attribute13
      ,p_attribute14      => l_attribute14
      ,p_attribute15      => l_attribute15
      ,p_attribute16      => l_attribute16
      ,p_attribute17      => l_attribute17
      ,p_attribute18      => l_attribute18
      ,p_attribute19      => l_attribute19
      ,p_attribute20      => l_attribute20
      ,p_attribute21      => l_attribute21
      ,p_attribute22      => l_attribute22
      ,p_attribute23      => l_attribute23
      ,p_attribute24      => l_attribute24
      ,p_attribute25      => l_attribute25
      ,p_attribute26      => l_attribute26
      ,p_attribute27      => l_attribute27
      ,p_attribute28      => l_attribute28
      ,p_attribute29      => l_attribute29
      ,p_attribute30      => l_attribute30
      ,p_attribute_category => l_attribute_category
      );
--
-- AR: 115.4 The attribute category must be the same as the
-- information type, they must not be different.
--
--  l_attribute_category := l_information_type;

  -- issue a savepoint
  savepoint create_attributes;

  -- get the information type id (bld_blk_info_type_id)
  -- MS added attribute category
  if g_debug then
  	hr_utility.set_location('gaz: '|| l_proc, 70);
  end if;
  open  c_bld_blk_info_type_id(l_info_type_table(l_rownum));
  fetch c_bld_blk_info_type_id into l_bld_blk_info_type_id;
  close c_bld_blk_info_type_id;
  if g_debug then
  	hr_utility.set_location('gaz: '|| l_proc, 80);
  end if;

 /* open c_get_data_set(p_time_building_block_id,p_tbb_ovn);
  fetch c_get_data_set into l_data_set_id;
  close c_get_data_set;*/

  -- call the row handler
  hxc_tat_ins.ins
    (p_effective_date        => null
    ,p_attribute_category    => l_attribute_category
    ,p_attribute1            => l_attribute1
    ,p_attribute2            => l_attribute2
    ,p_attribute3            => l_attribute3
    ,p_attribute4            => l_attribute4
    ,p_attribute5            => l_attribute5
    ,p_attribute6            => l_attribute6
    ,p_attribute7            => l_attribute7
    ,p_attribute8            => l_attribute8
    ,p_attribute9            => l_attribute9
    ,p_attribute10           => l_attribute10
    ,p_attribute11           => l_attribute11
    ,p_attribute12           => l_attribute12
    ,p_attribute13           => l_attribute13
    ,p_attribute14           => l_attribute14
    ,p_attribute15           => l_attribute15
    ,p_attribute16           => l_attribute16
    ,p_attribute17           => l_attribute17
    ,p_attribute18           => l_attribute18
    ,p_attribute19           => l_attribute19
    ,p_attribute20           => l_attribute20
    ,p_attribute21           => l_attribute21
    ,p_attribute22           => l_attribute22
    ,p_attribute23           => l_attribute23
    ,p_attribute24           => l_attribute24
    ,p_attribute25           => l_attribute25
    ,p_attribute26           => l_attribute26
    ,p_attribute27           => l_attribute27
    ,p_attribute28           => l_attribute28
    ,p_attribute29           => l_attribute29
    ,p_attribute30           => l_attribute30
    ,p_bld_blk_info_type_id  => l_bld_blk_info_type_id
    ,p_data_set_id           => NULL--l_data_set_id
    ,p_time_attribute_id     => l_time_attribute_id
    ,p_object_version_number => l_object_version_number
    );

  -- insert row into hxc_time_attribute_usages to associate attributes
  -- with a building block
  if g_debug then
  	hr_utility.set_location('gaz: '|| l_proc, 90);
  end if;

 -- open c_attribute_usage_sequence;            -- refer Bug#3062133
 -- fetch c_attribute_usage_sequence into l_time_attribute_usage_id;
 -- close c_attribute_usage_sequence;

  if g_debug then
  	hr_utility.set_location('gaz: '|| l_proc, 100);
  end if;

  if ((p_time_building_block_id IS NULL) OR (l_time_attribute_id is NULL)) then
       raise e_usage_data_missing;
  end if;

  insert into hxc_time_attribute_usages
    (time_attribute_usage_id
    ,time_attribute_id
    ,time_building_block_id
    ,time_building_block_ovn
    ,data_set_id
    ,created_by
    ,creation_date
    ,last_updated_by
    ,last_update_date
    ,last_update_login
  ) values
    (hxc_time_attribute_usages_s.nextval      -- refer Bug#3062133
    ,l_time_attribute_id
    ,p_time_building_block_id
    ,p_tbb_ovn
    ,l_data_set_id
    ,null
    ,sysdate
    ,null
    ,sysdate
    ,null
  )
  returning time_attribute_usage_id into l_time_attribute_usage_id;  -- refer Bug#3062133

  end loop;

  if p_validate then
    raise hr_api.validate_enabled;
  end if;

  -- set out parameters
  p_object_version_number := l_object_version_number;
  p_time_attribute_id     := l_time_attribute_id;

exception
  when hr_api.validate_enabled then
    rollback to create_attributes;
  when e_usage_data_missing then
    rollback to create_attributes;
    fnd_message.set_name('HXC', 'HXC_USAGE_DATA_MISSING');
    fnd_message.raise_error;
  when others then
    raise;
end create_attributes;

procedure create_attribute
  (p_validate               in     boolean default false
  ,p_bld_blk_info_type_id   in     number
  ,p_attribute_category     in     varchar2
  ,p_attribute1             in     varchar2
  ,p_attribute2             in     varchar2
  ,p_attribute3             in     varchar2
  ,p_attribute4             in     varchar2
  ,p_attribute5             in     varchar2
  ,p_attribute6             in     varchar2
  ,p_attribute7             in     varchar2
  ,p_attribute8             in     varchar2
  ,p_attribute9             in     varchar2
  ,p_attribute10            in     varchar2
  ,p_attribute11            in     varchar2
  ,p_attribute12            in     varchar2
  ,p_attribute13            in     varchar2
  ,p_attribute14            in     varchar2
  ,p_attribute15            in     varchar2
  ,p_attribute16            in     varchar2
  ,p_attribute17            in     varchar2
  ,p_attribute18            in     varchar2
  ,p_attribute19            in     varchar2
  ,p_attribute20            in     varchar2
  ,p_attribute21            in     varchar2
  ,p_attribute22            in     varchar2
  ,p_attribute23            in     varchar2
  ,p_attribute24            in     varchar2
  ,p_attribute25            in     varchar2
  ,p_attribute26            in     varchar2
  ,p_attribute27            in     varchar2
  ,p_attribute28            in     varchar2
  ,p_attribute29            in     varchar2
  ,p_attribute30            in     varchar2
  ,p_time_building_block_id in     number
  ,p_tbb_ovn                in     number
  ,p_time_attribute_id      in out nocopy number
  ,p_object_version_number  in out nocopy number
  ) is

--cursor c_attribute_usage_sequence is                    -- refer Bug#3062133
  --select hxc_time_attribute_usages_s.nextval from dual;

cursor c_get_data_set(p_tbb_id number,p_tbb_ovn number)
is
select data_set_id from hxc_time_building_blocks
where time_building_block_id = p_tbb_id
and object_version_number = p_tbb_ovn;

l_time_attribute_id hxc_time_attributes.time_attribute_id%type;
l_object_version_number hxc_time_attributes.object_version_number%type;
l_time_attribute_usage_id hxc_time_attribute_usages.time_attribute_usage_id%type;

l_data_set_id hxc_time_attributes.data_set_id%type;
e_usage_data_missing exception;
Begin

  savepoint create_attribute;

  open c_get_data_set(p_time_building_block_id,p_tbb_ovn);
  fetch c_get_data_set into l_data_set_id;
  close c_get_data_set;

  -- call the row handler
  hxc_tat_ins.ins
    (p_effective_date        => null
    ,p_attribute_category    => p_attribute_category
    ,p_attribute1            => p_attribute1
    ,p_attribute2            => p_attribute2
    ,p_attribute3            => p_attribute3
    ,p_attribute4            => p_attribute4
    ,p_attribute5            => p_attribute5
    ,p_attribute6            => p_attribute6
    ,p_attribute7            => p_attribute7
    ,p_attribute8            => p_attribute8
    ,p_attribute9            => p_attribute9
    ,p_attribute10           => p_attribute10
    ,p_attribute11           => p_attribute11
    ,p_attribute12           => p_attribute12
    ,p_attribute13           => p_attribute13
    ,p_attribute14           => p_attribute14
    ,p_attribute15           => p_attribute15
    ,p_attribute16           => p_attribute16
    ,p_attribute17           => p_attribute17
    ,p_attribute18           => p_attribute18
    ,p_attribute19           => p_attribute19
    ,p_attribute20           => p_attribute20
    ,p_attribute21           => p_attribute21
    ,p_attribute22           => p_attribute22
    ,p_attribute23           => p_attribute23
    ,p_attribute24           => p_attribute24
    ,p_attribute25           => p_attribute25
    ,p_attribute26           => p_attribute26
    ,p_attribute27           => p_attribute27
    ,p_attribute28           => p_attribute28
    ,p_attribute29           => p_attribute29
    ,p_attribute30           => p_attribute30
    ,p_bld_blk_info_type_id  => p_bld_blk_info_type_id
    ,p_data_set_id           => NULL--l_data_set_id
    ,p_time_attribute_id     => l_time_attribute_id
    ,p_object_version_number => l_object_version_number
    );

  -- insert row into hxc_time_attribute_usages to associate attributes
  -- with a building block

  --open c_attribute_usage_sequence;                   -- refer Bug#3062133
  --fetch c_attribute_usage_sequence into l_time_attribute_usage_id;
  --close c_attribute_usage_sequence;

 if ((p_time_building_block_id IS NULL) OR (l_time_attribute_id is NULL)) then
       raise e_usage_data_missing;
  end if;

  insert into hxc_time_attribute_usages
    (time_attribute_usage_id
    ,time_attribute_id
    ,time_building_block_id
    ,time_building_block_ovn
    ,data_set_id
    ,created_by
    ,creation_date
    ,last_updated_by
    ,last_update_date
    ,last_update_login
  ) values
    (hxc_time_attribute_usages_s.nextval               -- refer Bug#3062133
    ,l_time_attribute_id
    ,p_time_building_block_id
    ,p_tbb_ovn
    ,l_data_set_id
    ,null
    ,sysdate
    ,null
    ,sysdate
    ,null
  )
  returning time_attribute_usage_id into l_time_attribute_usage_id;	-- refer Bug#3062133

  if p_validate then
    raise hr_api.validate_enabled;
  end if;

  -- set out parameters
  p_object_version_number := l_object_version_number;
  p_time_attribute_id     := l_time_attribute_id;

exception
  when hr_api.validate_enabled then
    rollback to create_attribute;
  when e_usage_data_missing then
    rollback to create_attribute;
    fnd_message.set_name('HXC', 'HXC_USAGE_DATA_MISSING');
    fnd_message.raise_error;
  when others then
    raise;

End create_attribute;

-- ---------------------------------------------------------------------------
-- |---------------------< update_attributes >-------------------------------|
-- ---------------------------------------------------------------------------

procedure update_attributes
  (p_validate               in     boolean default false
  ,p_timecard               in     timecard
  ,p_process_id             in     number
  ,p_time_building_block_id in     number
  ,p_time_attribute_id      in     number
  ,p_object_version_number  in out nocopy number
  ) is

l_proc                  varchar2(72);
l_object_version_number hxc_time_attributes.object_version_number%type;

begin

  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'update_attributes';
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;

  -- issue a savepoint
  savepoint update_building_block;

  -- call the row handler
  hxc_tat_upd.upd
    (p_effective_date        => sysdate
    ,p_time_attribute_id     => p_time_attribute_id
    ,p_object_version_number => l_object_version_number
--    ,p_attribute_category    => null
    );

  if p_validate then
    raise hr_api.validate_enabled;
  end if;

  -- set out parameters
  p_object_version_number := l_object_version_number;

  if g_debug then
  	hr_utility.set_location('  Leaving:'|| l_proc, 20);
  end if;

exception
  when hr_api.validate_enabled then
    rollback to update_attributes;
  when others then
    raise;

end update_attributes;


-- ---------------------------------------------------------------------------
-- |---------------------< delete_attributes >-------------------------------|
-- ---------------------------------------------------------------------------

procedure delete_attributes
  (p_validate              in boolean default false
  ,p_time_attribute_id     in number
  ,p_object_version_number in number
  ) is

begin

  null;

end delete_attributes;


end hxc_time_attributes_api;

/
