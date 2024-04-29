--------------------------------------------------------
--  DDL for Package Body HXC_TBB_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TBB_UPD" as
/* $Header: hxctbbrhi.pkb 120.6.12010000.1 2008/07/28 11:19:46 appldev ship $ */

-- --------------------------------------------------------------------------
-- |                     Private Global Definitions                         |
-- --------------------------------------------------------------------------

g_package  varchar2(33)	:= '  hxc_tbb_upd.';  -- global package name

g_debug boolean := hr_utility.debug_enabled;

-- --------------------------------------------------------------------------
-- |------------------------------< update_dml >----------------------------|
-- --------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml update logic. The processing of
--   this procedure is:
--   1) Increment the object_version_number by 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be updated in the schema.
--
-- Post Failure:
--   On the update dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   if a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   if any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   The update 'set' attribute list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {end Of Comments}
-- --------------------------------------------------------------------------
procedure update_dml
  (p_rec in out nocopy hxc_tbb_shd.g_rec_type
  ) is

  l_proc  varchar2(72);

begin



  if g_debug then
  	l_proc := g_package||'update_dml';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

  -- increment the object version

  p_rec.object_version_number := p_rec.object_version_number + 1;

  -- update the hxc_time_building_blocks row

  update hxc_time_building_blocks
    set
     time_building_block_id      = p_rec.time_building_block_id
    ,type                        = p_rec.type
    ,measure                     = p_rec.measure
    ,unit_of_measure             = p_rec.unit_of_measure
    ,start_time                  = p_rec.start_time
    ,stop_time                   = p_rec.stop_time
    ,parent_building_block_id    = p_rec.parent_building_block_id
    ,parent_building_block_ovn   = p_rec.parent_building_block_ovn
    ,scope                       = p_rec.scope
    ,object_version_number       = p_rec.object_version_number
    ,approval_status             = p_rec.approval_status
    ,resource_id                 = p_rec.resource_id
    ,resource_type               = p_rec.resource_type
    ,approval_style_id           = p_rec.approval_style_id
    ,comment_text                = p_rec.comment_text
    ,application_set_id          = p_rec.application_set_id
    ,data_set_id                 = p_rec.data_set_id
    ,translation_display_key     = p_rec.translation_display_key
    ,last_updated_by		     = fnd_global.user_id
    ,last_update_date		     = sysdate
    ,last_update_login	             = fnd_global.login_id

    where time_building_block_id = p_rec.time_building_block_id;

  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;

exception
  when hr_api.check_integrity_violated then
    -- a check constraint has been violated
    hxc_tbb_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  when hr_api.parent_integrity_violated then
    -- parent integrity has been violated
    hxc_tbb_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  when hr_api.unique_integrity_violated then
    -- unique integrity has been violated
    hxc_tbb_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  when others then
    raise;

end update_dml;

-- --------------------------------------------------------------------------
-- |------------------------------< pre_update >----------------------------|
-- --------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   if an error has occurred, an error message and exception wil be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {end Of Comments}
-- --------------------------------------------------------------------------
procedure pre_update
  (p_rec in hxc_tbb_shd.g_rec_type
  ) is

  l_proc  varchar2(72);

begin



  if g_debug then
  	l_proc := g_package||'pre_update';
  	hr_utility.set_location('Entering:'||l_proc, 5);

  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;

end pre_update;

-- --------------------------------------------------------------------------
-- |-----------------------------< post_update >----------------------------|
-- --------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   if an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any post-processing required after the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {end Of Comments}
-- --------------------------------------------------------------------------
procedure post_update
  (p_effective_date               in date
  ,p_rec                          in hxc_tbb_shd.g_rec_type
  ) is

  l_proc  varchar2(72);

begin



  if g_debug then
  	l_proc := g_package||'post_update';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  begin

    hxc_tbb_rku.after_update
      (p_effective_date
      => p_effective_date
      ,p_time_building_block_id
      => p_rec.time_building_block_id
      ,p_measure
      => p_rec.measure
      ,p_unit_of_measure
      => p_rec.unit_of_measure
      ,p_start_time
      => p_rec.start_time
      ,p_stop_time
      => p_rec.stop_time
      ,p_parent_building_block_id
      => p_rec.parent_building_block_id
      ,p_parent_building_block_ovn
      => p_rec.parent_building_block_ovn
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_approval_status
      => p_rec.approval_status
      ,p_approval_style_id
      => p_rec.approval_style_id
      ,p_date_from
      => p_rec.date_from
      ,p_date_to
      => p_rec.date_to
      ,p_comment_text
      => p_rec.comment_text
      ,p_application_set_id
      => p_rec.application_set_id
      ,p_translation_display_key
      => p_rec.translation_display_key
      ,p_type_o
      => hxc_tbb_shd.g_old_rec.type
      ,p_measure_o
      => hxc_tbb_shd.g_old_rec.measure
      ,p_unit_of_measure_o
      => hxc_tbb_shd.g_old_rec.unit_of_measure
      ,p_start_time_o
      => hxc_tbb_shd.g_old_rec.start_time
      ,p_stop_time_o
      => hxc_tbb_shd.g_old_rec.stop_time
      ,p_parent_building_block_id_o
      => hxc_tbb_shd.g_old_rec.parent_building_block_id
      ,p_parent_building_block_ovn_o
      => hxc_tbb_shd.g_old_rec.parent_building_block_ovn
      ,p_scope_o
      => hxc_tbb_shd.g_old_rec.scope
      ,p_object_version_number_o
      => hxc_tbb_shd.g_old_rec.object_version_number
      ,p_approval_status_o
      => hxc_tbb_shd.g_old_rec.approval_status
      ,p_resource_id_o
      => hxc_tbb_shd.g_old_rec.resource_id
      ,p_resource_type_o
      => hxc_tbb_shd.g_old_rec.resource_type
      ,p_approval_style_id_o
      => hxc_tbb_shd.g_old_rec.approval_style_id
      ,p_date_from_o
      => hxc_tbb_shd.g_old_rec.date_from
      ,p_date_to_o
      => hxc_tbb_shd.g_old_rec.date_to
      ,p_comment_text_o
      => hxc_tbb_shd.g_old_rec.comment_text
      ,p_application_set_id_o
      => hxc_tbb_shd.g_old_rec.application_set_id
      ,p_translation_display_key_o
      => hxc_tbb_shd.g_old_rec.translation_display_key
      );

  exception

    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HXC_TIME_BUILDING_BLOCKS'
        ,p_hook_type   => 'AU');

  end;

  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;

end post_update;

-- --------------------------------------------------------------------------
-- |-----------------------------< convert_defs >---------------------------|
-- --------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Convert_Defs procedure has one very important function:
--   It must return the record structure for the row with all system defaulted
--   values converted into its corresponding parameter value for update. When
--   we attempt to update a row through the Upd process , certain
--   parameters can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd process to determine which attributes
--   have NOT been specified we need to check if the parameter has a reserved
--   system default value. Therefore, for all parameters which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- Prerequisites:
--   This private function can only be called from the upd process.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to
--   conversion of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {end Of Comments}
-- --------------------------------------------------------------------------
procedure convert_defs
  (p_rec in out nocopy hxc_tbb_shd.g_rec_type
  ) is

begin

  -- we must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used.  if a system default
  -- is being used then we must set to the 'current' argument value.

  if (p_rec.type = hr_api.g_varchar2) then
    p_rec.type :=
    hxc_tbb_shd.g_old_rec.type;
  end if;

  if (p_rec.measure = hr_api.g_number) then
    p_rec.measure :=
    hxc_tbb_shd.g_old_rec.measure;
  end if;

  if (p_rec.unit_of_measure = hr_api.g_varchar2) then
    p_rec.unit_of_measure :=
    hxc_tbb_shd.g_old_rec.unit_of_measure;
  end if;

  if (p_rec.start_time = hr_api.g_date) then
    p_rec.start_time :=
    hxc_tbb_shd.g_old_rec.start_time;
  end if;

  if (p_rec.stop_time = hr_api.g_date) then
    p_rec.stop_time :=
    hxc_tbb_shd.g_old_rec.stop_time;
  end if;

  if (p_rec.parent_building_block_id = hr_api.g_number) then
    p_rec.parent_building_block_id :=
    hxc_tbb_shd.g_old_rec.parent_building_block_id;
  end if;

  if (p_rec.scope = hr_api.g_varchar2) then
    p_rec.scope :=
    hxc_tbb_shd.g_old_rec.scope;
  end if;

  if (p_rec.approval_status = hr_api.g_varchar2) then
    p_rec.approval_status :=
    hxc_tbb_shd.g_old_rec.approval_status;
  end if;

  if (p_rec.resource_id = hr_api.g_number) then
    p_rec.resource_id :=
    hxc_tbb_shd.g_old_rec.resource_id;
  end if;

  if (p_rec.resource_type = hr_api.g_varchar2) then
    p_rec.resource_type :=
    hxc_tbb_shd.g_old_rec.resource_type;
  end if;

  if (p_rec.approval_style_id = hr_api.g_number) then
    p_rec.approval_style_id :=
    hxc_tbb_shd.g_old_rec.approval_style_id;
  end if;

  if (p_rec.date_from = hr_api.g_date) then
    p_rec.date_from :=
    hxc_tbb_shd.g_old_rec.date_from;
  end if;

  if (p_rec.date_to = hr_api.g_date) then
    p_rec.date_to :=
    hxc_tbb_shd.g_old_rec.date_to;
  end if;

  if (p_rec.comment_text = hr_api.g_varchar2) then
    p_rec.comment_text :=
    hxc_tbb_shd.g_old_rec.comment_text;
  end if;

  if (p_rec.data_set_id = hr_api.g_number) then
    p_rec.data_set_id :=
    hxc_tbb_shd.g_old_rec.data_set_id;
  end if;


end convert_defs;

-- --------------------------------------------------------------------------
-- |---------------------------------< upd >--------------------------------|
-- --------------------------------------------------------------------------
procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy hxc_tbb_shd.g_rec_type
  ) is

  l_proc  varchar2(72);

begin

  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'upd';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

  -- we must lock the row which we need to update.

  hxc_tbb_shd.lck
    (p_rec.time_building_block_id
    ,p_rec.object_version_number
    );

  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.

  convert_defs(p_rec);
  hxc_tbb_bus.update_validate
     (p_effective_date
     ,p_rec
     );

  -- call the supporting pre-update operation

  hxc_tbb_upd.pre_update(p_rec);

  -- update the row.

  hxc_tbb_upd.update_dml(p_rec);

  -- call the supporting post-update operation

  hxc_tbb_upd.post_update
    (p_effective_date
    ,p_rec
    );

end upd;

-- --------------------------------------------------------------------------
-- |---------------------------------< upd >--------------------------------|
-- --------------------------------------------------------------------------
procedure upd
  (p_effective_date            in     date
  ,p_time_building_block_id    in     number
  ,p_object_version_number     in out nocopy number
  ,p_approval_status           in     varchar2  default hr_api.g_varchar2
  ,p_measure                   in     number    default hr_api.g_number
  ,p_unit_of_measure           in     varchar2  default hr_api.g_varchar2
  ,p_start_time                in     date      default hr_api.g_date
  ,p_stop_time                 in     date      default hr_api.g_date
  ,p_parent_building_block_id  in     number    default hr_api.g_number
  ,p_parent_building_block_ovn in     number    default hr_api.g_number
  ,p_approval_style_id         in     number    default hr_api.g_number
  ,p_date_from                 in     date      default hr_api.g_date
  ,p_date_to                   in     date      default hr_api.g_date
  ,p_comment_text              in     varchar2  default hr_api.g_varchar2
  ,p_application_set_id        in     number    default hr_api.g_number
  ,p_data_set_id               in     number    default hr_api.g_number
  ,p_translation_display_key   in     varchar2  default hr_api.g_varchar2
  ) is

  l_rec	  hxc_tbb_shd.g_rec_type;
  l_proc  varchar2(72);

begin

  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'upd';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

  -- call conversion function to turn arguments into the
  -- l_rec structure.

  l_rec :=
    hxc_tbb_shd.convert_args
    (p_time_building_block_id
    ,hr_api.g_varchar2
    ,p_measure
    ,p_unit_of_measure
    ,p_start_time
    ,p_stop_time
    ,p_parent_building_block_id
    ,p_parent_building_block_ovn
    ,hr_api.g_varchar2
    ,p_object_version_number
    ,p_approval_status
    ,hr_api.g_number
    ,hr_api.g_varchar2
    ,p_approval_style_id
    ,null
    ,null
    ,p_comment_text
    ,p_application_set_id
    ,p_data_set_id
    ,p_translation_display_key
    );

  -- having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.

  hxc_tbb_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;

  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;

end upd;

end hxc_tbb_upd;

/
