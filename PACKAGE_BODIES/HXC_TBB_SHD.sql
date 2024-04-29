--------------------------------------------------------
--  DDL for Package Body HXC_TBB_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TBB_SHD" as
/* $Header: hxctbbrhi.pkb 120.6.12010000.1 2008/07/28 11:19:46 appldev ship $ */
--
-- --------------------------------------------------------------------------
-- |                     private global definitions                         |
-- --------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hxc_tbb_shd.';  -- global package name

g_debug boolean := hr_utility.debug_enabled;
--
-- --------------------------------------------------------------------------
-- |---------------------------< constraint_error >-------------------------|
-- --------------------------------------------------------------------------
procedure constraint_error
  (p_constraint_name in all_constraints.constraint_name%type
  ) is
--
  l_proc varchar2(72) := g_package||'constraint_error';
--
begin
  --
  if (p_constraint_name = 'HXC_TIME_BUILDING_BLOCKS_FK1') Then
    fnd_message.set_name('HXC', 'HXC_NO_APPROVAL_STYLE');
    fnd_message.set_token('procedure', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  else
    fnd_message.set_name('PAY', 'HR_7877_API_INVALID_CONSTRAINT');
    fnd_message.set_token('procedure', l_proc);
    fnd_message.set_token('CONSTRAINT_NAME', p_constraint_name);
    fnd_message.raise_error;
  end if;
  --
end constraint_error;
--
-- --------------------------------------------------------------------------
-- |-----------------------------< api_updating >---------------------------|
-- --------------------------------------------------------------------------
function api_updating
  (p_time_building_block_id in number
  ,p_object_version_number  in number
  )
  return boolean is


  -- cursor selects the 'current' row from the hr schema

  cursor c_sel1 is
    select
       time_building_block_id
      ,type
      ,measure
      ,unit_of_measure
      ,start_time
      ,stop_time
      ,parent_building_block_id
      ,parent_building_block_ovn
      ,scope
      ,object_version_number
      ,approval_status
      ,resource_id
      ,resource_type
      ,approval_style_id
      ,date_from
      ,date_to
      ,comment_text
      ,application_set_id
      ,data_set_id
      ,translation_display_key
    from hxc_time_building_blocks
    where time_building_block_id = p_time_building_block_id;

  l_fct_ret boolean;

begin

  if (p_time_building_block_id is null and
      p_object_version_number is null
     ) then

    -- one of the primary key arguments is null therefore we must
    -- set the returning function value to false

    l_fct_ret := false;

  else

    if (p_time_building_block_id
        = hxc_tbb_shd.g_old_rec.time_building_block_id and
        p_object_version_number
        = hxc_tbb_shd.g_old_rec.object_version_number
       ) then

      -- The g_old_rec is current therefore we must
      -- set the returning function to true

      l_fct_ret := true;

    else

      -- select the current row into g_old_rec

      open c_sel1;
      fetch c_sel1 into hxc_tbb_shd.g_old_rec;

      if c_sel1%notfound then
        close c_sel1;

        -- the primary key is invalid therefore we must error

        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;

      end if;

      close c_sel1;

      if (p_object_version_number
          <> hxc_tbb_shd.g_old_rec.object_version_number) Then
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
  (p_time_building_block_id in number
  ,p_object_version_number  in number
  ) is

  -- cursor selects the 'current' row from the hr schema

  cursor c_sel1 is
    select
       time_building_block_id
      ,type
      ,measure
      ,unit_of_measure
      ,start_time
      ,stop_time
      ,parent_building_block_id
      ,parent_building_block_ovn
      ,scope
      ,object_version_number
      ,approval_status
      ,resource_id
      ,resource_type
      ,approval_style_id
      ,date_from
      ,date_to
      ,comment_text
      ,application_set_id
      ,data_set_id
      ,translation_display_key
    from hxc_time_building_blocks
    where time_building_block_id = p_time_building_block_id
    and object_version_number    = (select max(object_version_number)
                                    from hxc_time_building_blocks
                                    where time_building_block_id = p_time_building_block_id)
    for	update nowait;

  l_proc varchar2(72);

begin

  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'lck';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'TIME_BUILDING_BLOCK_ID'
    ,p_argument_value     => p_time_building_block_id
    );

  open c_sel1;
  fetch c_sel1 into hxc_tbb_shd.g_old_rec;

  if c_sel1%notfound then
    close c_sel1;

    -- the primary key is invalid therefore we must error

    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  end if;

  close c_sel1;

  if (p_object_version_number
      <> hxc_tbb_shd.g_old_rec.object_version_number) then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
  end if;

  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;

exception
  when hr_api.object_locked then

    -- the object is locked therefore we need to supply a meaningful
    -- error message.

    fnd_message.set_name('PAY', 'HR_7165_OBJECT_LOCKED');
    fnd_message.set_token('TABLE_NAME', 'hxc_time_building_blocks');
    fnd_message.raise_error;

end lck;

-- --------------------------------------------------------------------------
-- |-----------------------------< convert_args >---------------------------|
-- --------------------------------------------------------------------------
function convert_args
  (p_time_building_block_id         in number
  ,p_type                           in varchar2
  ,p_measure                        in number
  ,p_unit_of_measure                in varchar2
  ,p_start_time                     in date
  ,p_stop_time                      in date
  ,p_parent_building_block_id       in number
  ,p_parent_building_block_ovn      in number
  ,p_scope                          in varchar2
  ,p_object_version_number          in number
  ,p_approval_status                in varchar2
  ,p_resource_id                    in number
  ,p_resource_type                  in varchar2
  ,p_approval_style_id              in number
  ,p_date_from                      in date
  ,p_date_to                        in date
  ,p_comment_text                   in varchar2
  ,p_application_set_id             in number
  ,p_data_set_id                    in number
  ,p_translation_display_key        in varchar2
  ) return g_rec_type is

  l_rec g_rec_type;

begin

  -- convert arguments into local l_rec structure.

  l_rec.time_building_block_id           := p_time_building_block_id;
  l_rec.type                             := p_type;
  l_rec.measure                          := p_measure;
  l_rec.unit_of_measure                  := p_unit_of_measure;
  l_rec.start_time                       := p_start_time;
  l_rec.stop_time                        := p_stop_time;
  l_rec.parent_building_block_id         := p_parent_building_block_id;
  l_rec.parent_building_block_ovn        := p_parent_building_block_ovn;
  l_rec.scope                            := p_scope;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.approval_status                  := p_approval_status;
  l_rec.resource_id                      := p_resource_id;
  l_rec.resource_type                    := p_resource_type;
  l_rec.approval_style_id                := p_approval_style_id;
  l_rec.date_from                        := p_date_from;
  l_rec.date_to                          := p_date_to;
  l_rec.comment_text                     := p_comment_text;
  l_rec.application_set_id		 := p_application_set_id;
  l_rec.data_set_id                      := p_data_set_id;
  l_rec.translation_display_key          := p_translation_display_key;

  -- return the plsql record structure.

  return(l_rec);

end convert_args;

end hxc_tbb_shd;

/
