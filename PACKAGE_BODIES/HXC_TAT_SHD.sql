--------------------------------------------------------
--  DDL for Package Body HXC_TAT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TAT_SHD" as
/* $Header: hxtatrhi.pkb 120.2 2005/09/23 07:03:57 rchennur noship $ */
-- --------------------------------------------------------------------------
-- |                     Private Global Definitions                         |
-- --------------------------------------------------------------------------
g_package  varchar2(33)	:= '  hxc_tat_shd.';  -- global package name
g_debug boolean := hr_utility.debug_enabled;
-- --------------------------------------------------------------------------
-- |---------------------------< constraint_error >-------------------------|
-- --------------------------------------------------------------------------
procedure constraint_error
  (p_constraint_name in all_constraints.constraint_name%type
  ) is

l_proc 	varchar2(72) := g_package||'constraint_error';

begin

  null;

end constraint_error;

-- --------------------------------------------------------------------------
-- |-----------------------------< api_updating >---------------------------|
-- --------------------------------------------------------------------------
function api_updating
  (p_time_attribute_id     in number
  ,p_object_version_number in number
  ) return boolean is

-- cursor selects the 'current' row from the hr schema

cursor c_sel1 is
  select
     time_attribute_id
    ,object_version_number
    ,attribute_category
    ,attribute1
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
    ,bld_blk_info_type_id
    ,data_set_id
  from  hxc_time_attributes
  where time_attribute_id = p_time_attribute_id;

l_fct_ret boolean;

begin

  if (p_time_attribute_id is null and
      p_object_version_number is null
     ) then

    -- one of the primary key arguments is null therefore we must
    -- set the returning function value to false

    l_fct_ret := false;

  else

    if (p_time_attribute_id
        = hxc_tat_shd.g_old_rec.time_attribute_id and
        p_object_version_number
        = hxc_tat_shd.g_old_rec.object_version_number
       ) then

      -- the g_old_rec is current therefore we must
      -- set the returning function to true

      l_fct_ret := true;

    else

      -- select the current row into g_old_rec

      open c_sel1;
      fetch c_sel1 into hxc_tat_shd.g_old_rec;

      if c_sel1%notfound then
        close c_sel1;

        -- the primary key is invalid therefore we must error

        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      end if;

      close c_sel1;

      if (p_object_version_number
          <> hxc_tat_shd.g_old_rec.object_version_number) then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
      end if;

      l_fct_ret := true;

    end if;

  end if;

  return (l_fct_ret);

end api_updating;

-- --------------------------------------------------------------------------
-- |---------------------------------< lck >--------------------------------|
-- --------------------------------------------------------------------------
procedure lck
  (p_time_attribute_id     in number
  ,p_object_version_number in number
  ) is

-- cursor selects the 'current' row from the hr schema

cursor c_sel1 is
  select
     time_attribute_id
    ,object_version_number
    ,attribute_category
    ,attribute1
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
    ,bld_blk_info_type_id
    ,data_set_id
  from	hxc_time_attributes
  where	time_attribute_id = p_time_attribute_id
    for	update nowait;

l_proc	varchar2(72) ;

begin
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
  	l_proc := g_package||'lck';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'TIME_ATTRIBUTE_ID'
    ,p_argument_value     => p_time_attribute_id
    );

  open  c_sel1;
  fetch c_sel1 into hxc_tat_shd.g_old_rec;

  if c_sel1%notfound then
    close c_sel1;

    -- the primary key is invalid therefore we must error

    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  end if;

  close c_sel1;

  if (p_object_version_number
      <> hxc_tat_shd.g_old_rec.object_version_number) then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
  end if;

  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;

exception
  when hr_api.object_locked then
    fnd_message.set_name('PAY', 'HR_7165_OBJECT_LOCKED');
    fnd_message.set_token('TABLE_NAME', 'hxc_time_attributes');
    fnd_message.raise_error;
end lck;

-- --------------------------------------------------------------------------
-- |-----------------------------< convert_args >---------------------------|
-- --------------------------------------------------------------------------
function convert_args
  (p_time_attribute_id              in number
  ,p_object_version_number          in number
  ,p_attribute_category             in varchar2
  ,p_attribute1                     in varchar2
  ,p_attribute2                     in varchar2
  ,p_attribute3                     in varchar2
  ,p_attribute4                     in varchar2
  ,p_attribute5                     in varchar2
  ,p_attribute6                     in varchar2
  ,p_attribute7                     in varchar2
  ,p_attribute8                     in varchar2
  ,p_attribute9                     in varchar2
  ,p_attribute10                    in varchar2
  ,p_attribute11                    in varchar2
  ,p_attribute12                    in varchar2
  ,p_attribute13                    in varchar2
  ,p_attribute14                    in varchar2
  ,p_attribute15                    in varchar2
  ,p_attribute16                    in varchar2
  ,p_attribute17                    in varchar2
  ,p_attribute18                    in varchar2
  ,p_attribute19                    in varchar2
  ,p_attribute20                    in varchar2
  ,p_attribute21                    in varchar2
  ,p_attribute22                    in varchar2
  ,p_attribute23                    in varchar2
  ,p_attribute24                    in varchar2
  ,p_attribute25                    in varchar2
  ,p_attribute26                    in varchar2
  ,p_attribute27                    in varchar2
  ,p_attribute28                    in varchar2
  ,p_attribute29                    in varchar2
  ,p_attribute30                    in varchar2
  ,p_bld_blk_info_type_id           in number
  ,p_data_set_id                    in number
  ) return g_rec_type is

l_rec g_rec_type;

begin

  -- convert arguments into local l_rec structure.

  l_rec.time_attribute_id                := p_time_attribute_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.attribute_category               := p_attribute_category;
  l_rec.attribute1                       := p_attribute1;
  l_rec.attribute2                       := p_attribute2;
  l_rec.attribute3                       := p_attribute3;
  l_rec.attribute4                       := p_attribute4;
  l_rec.attribute5                       := p_attribute5;
  l_rec.attribute6                       := p_attribute6;
  l_rec.attribute7                       := p_attribute7;
  l_rec.attribute8                       := p_attribute8;
  l_rec.attribute9                       := p_attribute9;
  l_rec.attribute10                      := p_attribute10;
  l_rec.attribute11                      := p_attribute11;
  l_rec.attribute12                      := p_attribute12;
  l_rec.attribute13                      := p_attribute13;
  l_rec.attribute14                      := p_attribute14;
  l_rec.attribute15                      := p_attribute15;
  l_rec.attribute16                      := p_attribute16;
  l_rec.attribute17                      := p_attribute17;
  l_rec.attribute18                      := p_attribute18;
  l_rec.attribute19                      := p_attribute19;
  l_rec.attribute20                      := p_attribute20;
  l_rec.attribute21                      := p_attribute21;
  l_rec.attribute22                      := p_attribute22;
  l_rec.attribute23                      := p_attribute23;
  l_rec.attribute24                      := p_attribute24;
  l_rec.attribute25                      := p_attribute25;
  l_rec.attribute26                      := p_attribute26;
  l_rec.attribute27                      := p_attribute27;
  l_rec.attribute28                      := p_attribute28;
  l_rec.attribute29                      := p_attribute29;
  l_rec.attribute30                      := p_attribute30;
  l_rec.bld_blk_info_type_id             := p_bld_blk_info_type_id;
  l_rec.data_set_id                      := p_data_set_id;

  -- return the plsql record structure.

  return(l_rec);

end convert_args;

end hxc_tat_shd;

/
