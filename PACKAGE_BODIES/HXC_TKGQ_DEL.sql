--------------------------------------------------------
--  DDL for Package Body HXC_TKGQ_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TKGQ_DEL" as
/* $Header: hxctkgqrhi.pkb 120.2 2005/09/23 09:33:26 rchennur noship $ */
--
g_package  varchar2(33) := '  hxc_tkgq_del.';  -- Global package name
g_debug boolean := hr_utility.debug_enabled;
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
  (p_rec in hxc_tkgq_shd.g_rec_type
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
  hxc_tkgq_shd.g_api_dml := true;  -- Set the api dml status

  -- first of all delete any child rows

  delete from hxc_tk_group_query_criteria tkgqc
  where  tkgqc.tk_group_query_id in
  ( select tkgq.tk_group_query_id
    from   hxc_tk_group_queries tkgq
    where  tkgq.tk_group_id = p_rec.tk_group_id );

  -- Delete the hxc_tk_group_queries row.

  delete from hxc_tk_group_queries tkgq
  where  tkgq.tk_group_query_id = p_rec.tk_group_query_id;

  --
  hxc_tkgq_shd.g_api_dml := false;   -- Unset the api dml status
  --
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    hxc_tkgq_shd.g_api_dml := false;   -- Unset the api dml status
    hxc_tkgq_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    hxc_tkgq_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_delete(p_rec in hxc_tkgq_shd.g_rec_type) is
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
-- -----------------------------------------------------------------------------
Procedure post_delete(p_rec in hxc_tkgq_shd.g_rec_type) is
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
    hxc_tkgq_rkd.after_delete
      (p_tk_group_query_id
      => p_rec.tk_group_query_id
      ,p_group_query_name_o
      => hxc_tkgq_shd.g_old_rec.group_query_name
      ,p_tk_group_id_o
      => hxc_tkgq_shd.g_old_rec.tk_group_id
      ,p_include_exclude_o
      => hxc_tkgq_shd.g_old_rec.include_exclude
      ,p_system_user_o
      => hxc_tkgq_shd.g_old_rec.system_user
      ,p_object_version_number_o
      => hxc_tkgq_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HXC_TK_GROUP_QUERY'
        ,p_hook_type   => 'AD');
      --
  end;
  --
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End post_delete;
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure is the record interface for the delete process
--   for the specified entity. The role of this process is to delete the
--   row from the HR schema. This process is the main backbone of the del
--   business process. The processing of this procedure is as follows:
--   1) The controlling validation process delete_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   2) The pre_delete process is then executed which enables any
--      logic to be processed before the delete dml process is executed.
--   3) The delete_dml process will physical perform the delete dml for the
--      specified row.
--   4) The post_delete process is then executed which enables any
--      logic to be processed after the delete dml process.
--
-- Prerequisites:
--   The main parameters to the business process have to be in the record
--   format.
--
-- In Parameters:
--
-- Post Success:
--   The specified row will be fully validated and deleted for the specified
--   entity without being committed.
--
-- Post Failure:
--   If an error has occurred, an error message will be raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- ----------------------------------------------------------------------------
Procedure del
  (p_rec	      in hxc_tkgq_shd.g_rec_type
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
  hxc_tkgq_shd.lck
    (p_rec.tk_group_query_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  hxc_tkgq_bus.delete_validate(p_rec);
  --
  -- Call the supporting pre-delete operation
  --
  hxc_tkgq_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  hxc_tkgq_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  hxc_tkgq_del.post_delete(p_rec);
  --
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure is the attribute interface for the delete
--   process for the specified entity and is the outermost layer. The role
--   of this process is to validate and delete the specified row from the
--   HR schema. The processing of this procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      explicitly coding the attribute parameters into the g_rec_type
--      datatype.
--   2) After the conversion has taken place, the corresponding record del
--      interface process is executed.
--
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--   The specified row will be fully validated and deleted for the specified
--   entity without being committed.
--
-- Post Failure:
--   If an error has occurred, an error message will be raised.
--
-- Developer Implementation Notes:
--   The attrbute in parameters should be modified as to the business process
--   requirements.
--
-- Access Status:
--   Internal Development Use Only.
--
-- ----------------------------------------------------------------------------
Procedure del
  (p_tk_group_query_id                    in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec	  hxc_tkgq_shd.g_rec_type;
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
  l_rec.tk_group_query_id := p_tk_group_query_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the hxc_tkgq_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  hxc_tkgq_del.del(l_rec);
  --
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End del;
--
end hxc_tkgq_del;

/
