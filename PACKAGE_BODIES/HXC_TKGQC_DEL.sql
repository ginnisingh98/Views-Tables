--------------------------------------------------------
--  DDL for Package Body HXC_TKGQC_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TKGQC_DEL" as
/* $Header: hxctkgqcrhi.pkb 120.2 2005/09/23 05:26:07 rchennur noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hxc_tkgqc_del.';  -- Global package name
g_debug boolean := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
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
-- ----------------------------------------------------------------------------
Procedure delete_dml
  (p_rec in hxc_tkgqc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) ;
--
Begin

  if g_debug then
	l_proc := g_package||'delete_dml';

	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  hxc_tkgqc_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the hxc_tk_group_query_criteria row.
  --
  delete from hxc_tk_group_query_criteria
  where tk_group_query_criteria_id = p_rec.tk_group_query_criteria_id;
  --
  hxc_tkgqc_shd.g_api_dml := false;   -- Unset the api dml status
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    hxc_tkgqc_shd.g_api_dml := false;   -- Unset the api dml status
    hxc_tkgqc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    hxc_tkgqc_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_delete >------------------------------|
-- ----------------------------------------------------------------------------
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
-- ----------------------------------------------------------------------------
Procedure pre_delete(p_rec in hxc_tkgqc_shd.g_rec_type) is
--
  l_proc  varchar2(72) ;
--
Begin

  if g_debug then
	l_proc := g_package||'pre_delete';

	hr_utility.set_location('Entering:'||l_proc, 5);
        hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End pre_delete;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This private procedure contains any processing which is required after
--   the delete dml.
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
-- -----------------------------------------------------------------------------
Procedure post_delete(p_rec in hxc_tkgqc_shd.g_rec_type) is
--
  l_proc  varchar2(72) ;
--
Begin

  if g_debug then
	l_proc := g_package||'post_delete';

	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  begin
    --
    hxc_tkgqc_rkd.after_delete
      (p_tk_group_query_criteria_id
      => p_rec.tk_group_query_criteria_id
      ,p_tk_group_query_id_o
      => hxc_tkgqc_shd.g_old_rec.tk_group_query_id
      ,p_criteria_type_o
      => hxc_tkgqc_shd.g_old_rec.criteria_type
      ,p_criteria_id_o
      => hxc_tkgqc_shd.g_old_rec.criteria_id
      ,p_object_version_number_o
      => hxc_tkgqc_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HXC_TK_GROUP_QUERY_CRITERIA'
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
  (p_rec              in hxc_tkgqc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) ;
--
Begin
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'del';

	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- We must lock the row which we need to delete.
  --
  hxc_tkgqc_shd.lck
    (p_rec.tk_group_query_criteria_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  hxc_tkgqc_bus.delete_validate(p_rec);
  --
  -- Call the supporting pre-delete operation
  --
  hxc_tkgqc_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  hxc_tkgqc_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  hxc_tkgqc_del.post_delete(p_rec);
  --
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_tk_group_query_criteria_id           in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   hxc_tkgqc_shd.g_rec_type;
  l_proc  varchar2(72) ;
--
Begin
  g_debug :=hr_utility.debug_enabled;
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
  l_rec.tk_group_query_criteria_id := p_tk_group_query_criteria_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the hxc_tkgqc_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  hxc_tkgqc_del.del(l_rec);
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End del;
--
end hxc_tkgqc_del;

/
