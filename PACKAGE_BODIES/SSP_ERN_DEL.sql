--------------------------------------------------------
--  DDL for Package Body SSP_ERN_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."SSP_ERN_DEL" as
/* $Header: spernrhi.pkb 120.5.12010000.2 2008/08/13 13:25:38 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ssp_ern_del.';  -- Global package name
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
-- Pre Conditions:
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
--   Internal Table Handler Use Only.
--
-- ----------------------------------------------------------------------------
Procedure delete_dml(p_rec in ssp_ern_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  ssp_ern_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the ssp_earnings_calculations row.
  --
  delete from ssp_earnings_calculations
   where earnings_calculations_id = p_rec.earnings_calculations_id;
  --
  ssp_ern_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location('Leaving :'||l_proc, 100);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    ssp_ern_shd.g_api_dml := false;   -- Unset the api dml status
    ssp_ern_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ssp_ern_shd.g_api_dml := false;   -- Unset the api dml status
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
-- Pre Conditions:
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
--   Internal Table Handler Use Only.
--
-- ----------------------------------------------------------------------------
Procedure pre_delete(p_rec in ssp_ern_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  hr_utility.set_location('Leaving :'||l_proc, 100);
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
-- Pre Conditions:
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
--   Any post-processing required after the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal table Handler Use Only.
--
-- ----------------------------------------------------------------------------
Procedure post_delete(p_rec in ssp_ern_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  hr_utility.set_location('Leaving :'||l_proc, 100);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_rec	      in ssp_ern_shd.g_rec_type,
  p_validate  in boolean default false
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT del_ssp_ern;
  End If;
  --
  -- We must lock the row which we need to delete.
  --
  ssp_ern_shd.lck (p_rec.earnings_calculations_id,p_rec.object_version_number);
  --
  -- Call the supporting delete validate operation
  --
  ssp_ern_bus.delete_validate(p_rec);
  --
  -- Call the supporting pre-delete operation
  --
  pre_delete(p_rec);
  --
  -- Delete the row.
  --
  delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  post_delete(p_rec);
  --
  -- If we are validating then raise the Validate_Enabled exception
  --
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
  hr_utility.set_location('Leaving :'||l_proc, 100);
Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised rollback to savepoint
    --
    ROLLBACK TO del_ssp_ern;
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_earnings_calculations_id           in number,
  p_object_version_number              in number,
  p_validate                           in boolean default false
  ) is
--
  l_rec	  ssp_ern_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'del';
--
Begin
   hr_utility.set_location('Entering:'||l_proc, 1);
   --
   -- As the delete procedure accepts a plsql record structure we do need to
   -- convert the arguments into the record structure. We don't need to call
   -- the supplied conversion argument routine as we only need a few attributes.
   --
   l_rec.earnings_calculations_id:= p_earnings_calculations_id;
   l_rec.object_version_number := p_object_version_number;
   --
   -- Having converted the arguments into the ssp_ern_rec plsql record structure
   -- we must call the corresponding entity business process.
   --
   del(l_rec, p_validate);
   --
   hr_utility.set_location('Leaving :'||l_proc, 100);
End del;
--
end ssp_ern_del;

/
