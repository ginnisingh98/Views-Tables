--------------------------------------------------------
--  DDL for Package Body HXC_TBB_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TBB_DEL" as
/* $Header: hxctbbrhi.pkb 120.6.12010000.1 2008/07/28 11:19:46 appldev ship $ */

-- --------------------------------------------------------------------------
-- |                     Private Global Definitions                         |
-- --------------------------------------------------------------------------

g_package  varchar2(33)	:= '  hxc_tbb_del.';  -- global package name

g_debug boolean := hr_utility.debug_enabled;

-- --------------------------------------------------------------------------
-- |------------------------------< delete_dml >----------------------------|
-- --------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic. The functions of
--   this procedure are as follows:
--   1) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   2) To delete the specified row from the schema using the primary key in
--      the predicates.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the del
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be delete from the schema.
--
-- Post Failure:
--   On the delete dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   if a child integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   if any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {end Of Comments}
-- --------------------------------------------------------------------------
procedure delete_dml
  (p_rec in hxc_tbb_shd.g_rec_type
  ) is

  l_proc  varchar2(72);

begin



  if g_debug then
  	l_proc := g_package||'delete_dml';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

  -- delete the hxc_time_building_blocks row.

  delete from hxc_time_building_blocks
  where time_building_block_id = p_rec.time_building_block_id;

  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;

exception
  when hr_api.child_integrity_violated then
    -- child integrity has been violated
    hxc_tbb_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  when others Then
    raise;

end delete_dml;

-- --------------------------------------------------------------------------
-- |------------------------------< pre_delete >----------------------------|
-- --------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the delete dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the del procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   if an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any pre-processing required before the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {end Of Comments}
-- --------------------------------------------------------------------------
procedure pre_delete(p_rec in hxc_tbb_shd.g_rec_type) is

  l_proc  varchar2(72);

begin



  if g_debug then
  	l_proc := g_package||'pre_delete';
  	hr_utility.set_location('Entering:'||l_proc, 5);

  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;

end pre_delete;

-- --------------------------------------------------------------------------
-- |-----------------------------< post_delete >----------------------------|
-- --------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   delete dml.
--
-- Prerequistes:
--   This is an internal procedure which is called from the del procedure.
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
--   Any post-processing required after the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {end Of Comments}
-- ---------------------------------------------------------------------------
procedure post_delete(p_rec in hxc_tbb_shd.g_rec_type) is

  l_proc  varchar2(72);

begin



  if g_debug then
  	l_proc := g_package||'post_delete';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
    begin

    hxc_tbb_rkd.after_delete
      (p_time_building_block_id
      => p_rec.time_building_block_id
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
        ,p_hook_type   => 'AD');
  end;

  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;

end post_delete;

-- --------------------------------------------------------------------------
-- |---------------------------------< del >--------------------------------|
-- --------------------------------------------------------------------------
procedure del
  (p_rec in hxc_tbb_shd.g_rec_type
  ) is

  l_proc  varchar2(72);

begin

  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'del';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

  -- we must lock the row which we need to delete.

  hxc_tbb_shd.lck
    (p_rec.time_building_block_id
    ,p_rec.object_version_number
    );

  -- call the supporting delete validate operation

  hxc_tbb_bus.delete_validate(p_rec);

  -- call the supporting pre-delete operation

  hxc_tbb_del.pre_delete(p_rec);

  -- delete the row.

  hxc_tbb_del.delete_dml(p_rec);

  -- call the supporting post-delete operation

  hxc_tbb_del.post_delete(p_rec);

end del;

-- --------------------------------------------------------------------------
-- |---------------------------------< del >--------------------------------|
-- --------------------------------------------------------------------------
procedure del
  (p_time_building_block_id in number
  ,p_object_version_number  in number
  ) is

  l_rec	 hxc_tbb_shd.g_rec_type;
  l_proc varchar2(72);

begin

  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'del';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

  -- as the delete procedure accepts a plsql record structure we do need to
  -- convert the arguments into the record structure.
  -- we don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.

  l_rec.time_building_block_id := p_time_building_block_id;
  l_rec.object_version_number := p_object_version_number;

  -- having converted the arguments into the hxc_tbb_rec
  -- plsql record structure we must call the corresponding entity
  -- business process

  hxc_tbb_del.del(l_rec);

  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;

end del;

end hxc_tbb_del;

/
