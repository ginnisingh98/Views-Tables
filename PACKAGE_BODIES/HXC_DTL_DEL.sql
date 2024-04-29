--------------------------------------------------------
--  DDL for Package Body HXC_DTL_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_DTL_DEL" as
/* $Header: hxcdtlrhi.pkb 120.2 2005/09/23 08:07:34 sechandr noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hxc_dtl_del.';  -- Global package name
g_debug boolean :=hr_utility.debug_enabled;
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
  (p_rec in hxc_dtl_shd.g_rec_type
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
  --
  --
  -- Delete the hxc_alias_definitions_tl row.
  --
  delete from hxc_alias_definitions_tl
  where alias_definition_id = p_rec.alias_definition_id
    and language = p_rec.language;
  --
  --
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    --
    hxc_dtl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
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
Procedure pre_delete(p_rec in hxc_dtl_shd.g_rec_type) is
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
Procedure post_delete(p_rec in hxc_dtl_shd.g_rec_type) is
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
    hxc_dtl_rkd.after_delete
      (p_alias_definition_id
      => p_rec.alias_definition_id
      ,p_language
      => p_rec.language
      ,p_alias_definition_name_o
      => hxc_dtl_shd.g_old_rec.alias_definition_name
      ,p_description_o
      => hxc_dtl_shd.g_old_rec.description
      ,p_source_lang_o
      => hxc_dtl_shd.g_old_rec.source_lang
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HXC_ALIAS_DEFINITIONS_TL'
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
  (p_rec	      in hxc_dtl_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'del';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- We must lock the row which we need to delete.
  --
  hxc_dtl_shd.lck
    (p_rec.alias_definition_id
    ,p_rec.language
    );
  --
  -- Call the supporting delete validate operation
  --
  hxc_dtl_bus.delete_validate(p_rec);
  --
  -- Call the supporting pre-delete operation
  --
  hxc_dtl_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  hxc_dtl_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  hxc_dtl_del.post_delete(p_rec);
  --
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_alias_definition_id                  in     number
  ,p_language                             in     varchar2
  ) is
--
  l_rec	  hxc_dtl_shd.g_rec_type;
  l_proc  varchar2(72);
--
Begin
  g_debug:=hr_utility.debug_enabled;
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
  l_rec.alias_definition_id := p_alias_definition_id;
  l_rec.language := p_language;
  --
  --
  -- Having converted the arguments into the hxc_dtl_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  hxc_dtl_del.del(l_rec);
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End del;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< del_tl >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del_tl
  (p_alias_definition_id                  in number
  ) is
  --
  -- Cursor to obtain all the translation rows.
  --
  cursor csr_del_langs is
    select dtl.language
      from hxc_alias_definitions_tl dtl
     where dtl.alias_definition_id = p_alias_definition_id;
  --
  l_proc  varchar2(72);
  --
Begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'del_tl';
	hr_utility.set_location('Entering:'||l_proc,10);
  end if;
  --
  -- Delete all the translated rows
  --
  for l_lang in csr_del_langs loop
    hxc_dtl_del.del
      (p_alias_definition_id         => p_alias_definition_id
      ,p_language                    => l_lang.language
      );
  end loop;
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc,20);
  end if;
End del_tl;
--
end hxc_dtl_del;

/
