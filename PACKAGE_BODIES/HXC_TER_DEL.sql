--------------------------------------------------------
--  DDL for Package Body HXC_TER_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TER_DEL" as
/* $Header: hxcterrhi.pkb 120.2 2005/09/23 09:19:47 nissharm noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hxc_ter_del.';  -- Global package name

g_debug boolean := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
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
--   If a child integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_dml
  (p_rec in hxc_ter_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin


  if g_debug then
  	l_proc := g_package||'delete_dml';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  hxc_ter_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the hxc_time_entry_rules row.
  --
  delete from hxc_time_entry_rules
  where time_entry_rule_id = p_rec.time_entry_rule_id;
  --
  hxc_ter_shd.g_api_dml := false;   -- Unset the api dml status
  --
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    hxc_ter_shd.g_api_dml := false;   -- Unset the api dml status
    hxc_ter_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    hxc_ter_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_delete >------------------------------|
-- ----------------------------------------------------------------------------
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
--   If an error has occurred, an error message and exception will be raised
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
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete(p_rec in hxc_ter_shd.g_rec_type) is
--
  l_proc  varchar2(72);
--
Begin


  if g_debug then
  	l_proc := g_package||'pre_delete';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  	--
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End pre_delete;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_delete >------------------------------|
-- ----------------------------------------------------------------------------
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
--   If an error has occurred, an error message and exception will be raised
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
-- {End Of Comments}
-- -----------------------------------------------------------------------------
Procedure post_delete(p_rec in hxc_ter_shd.g_rec_type) is
--
  l_proc  varchar2(72);
--
Begin


  if g_debug then
  	l_proc := g_package||'post_delete';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
    begin
    --
   hxc_ter_rkd.after_delete
      (p_time_entry_rule_id
      => p_rec.time_entry_rule_id
      ,p_name_o
      => hxc_ter_shd.g_old_rec.name
      ,p_business_group_id_o	     => hxc_ter_shd.g_old_rec.business_group_id
      ,p_legislation_code_o	     => hxc_ter_shd.g_old_rec.legislation_code
      ,p_mapping_id_o => hxc_ter_shd.g_old_rec.mapping_id
      ,p_rule_usage_o
      => hxc_ter_shd.g_old_rec.rule_usage
      ,p_formula_id_o
      => hxc_ter_shd.g_old_rec.formula_id
      ,p_description_o
      => hxc_ter_shd.g_old_rec.description
      ,p_start_date_o
      => hxc_ter_shd.g_old_rec.start_date
      ,p_end_date_o
      => hxc_ter_shd.g_old_rec.end_date
      ,p_object_version_number_o
      => hxc_ter_shd.g_old_rec.object_version_number
      ,p_attribute_category_o
      => hxc_hph_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => hxc_hph_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => hxc_hph_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => hxc_hph_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => hxc_hph_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => hxc_hph_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => hxc_hph_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => hxc_hph_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => hxc_hph_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => hxc_hph_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => hxc_hph_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => hxc_hph_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => hxc_hph_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => hxc_hph_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => hxc_hph_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => hxc_hph_shd.g_old_rec.attribute15
      ,p_attribute16_o
      => hxc_hph_shd.g_old_rec.attribute16
      ,p_attribute17_o
      => hxc_hph_shd.g_old_rec.attribute17
      ,p_attribute18_o
      => hxc_hph_shd.g_old_rec.attribute18
      ,p_attribute19_o
      => hxc_hph_shd.g_old_rec.attribute19
      ,p_attribute20_o
      => hxc_hph_shd.g_old_rec.attribute20
      ,p_attribute21_o
      => hxc_hph_shd.g_old_rec.attribute21
      ,p_attribute22_o
      => hxc_hph_shd.g_old_rec.attribute22
      ,p_attribute23_o
      => hxc_hph_shd.g_old_rec.attribute23
      ,p_attribute24_o
      => hxc_hph_shd.g_old_rec.attribute24
      ,p_attribute25_o
      => hxc_hph_shd.g_old_rec.attribute25
      ,p_attribute26_o
      => hxc_hph_shd.g_old_rec.attribute26
      ,p_attribute27_o
      => hxc_hph_shd.g_old_rec.attribute27
      ,p_attribute28_o
      => hxc_hph_shd.g_old_rec.attribute28
      ,p_attribute29_o
      => hxc_hph_shd.g_old_rec.attribute29
      ,p_attribute30_o
      => hxc_hph_shd.g_old_rec.attribute30
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HXC_TIME_ENTRY_RULES'
        ,p_hook_type   => 'AD');
      --
  end;
  --
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_rec	      in hxc_ter_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'del';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- We must lock the row which we need to delete.
  --
  hxc_ter_shd.lck
    (p_rec.time_entry_rule_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  hxc_ter_bus.delete_validate(p_rec);
  --
  -- Call the supporting pre-delete operation
  --
  hxc_ter_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  hxc_ter_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  hxc_ter_del.post_delete(p_rec);
  --
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_time_entry_rule_id                in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec	  hxc_ter_shd.g_rec_type;
  l_proc  varchar2(72);
--
Begin
  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'del';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.time_entry_rule_id := p_time_entry_rule_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the hxc_ter_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  hxc_ter_del.del(l_rec);
  --
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End del;
--
end hxc_ter_del;

/
