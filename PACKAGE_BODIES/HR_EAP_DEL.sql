--------------------------------------------------------
--  DDL for Package Body HR_EAP_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_EAP_DEL" as
/* $Header: hreaprhi.pkb 115.0 2004/01/09 00:17 vkarandi noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_eap_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_sso_details >------------------------|
-- ----------------------------------------------------------------------------

PROCEDURE delete_sso_details (
            p_sso_id   IN number
) IS

l_ext_application_id  NUMBER(15) := NULL;
l_error number(15) := null;

l_proc     varchar2(72) := g_package || 'delete_sso_details';

CURSOR csr_app_id IS
select EXT_APPLICATION_ID
from hr_ki_ext_applications
where external_application_id=p_sso_id;


BEGIN

--
--Make sure that ext_application_id is not null
--

hr_utility.set_location('Entering:'||l_proc, 5);

  hr_api.mandatory_arg_error
  (p_api_name           => l_proc
  ,p_argument           => 'EXTERNAL_APPLICATION_ID'
  ,p_argument_value     => p_sso_id
  );

hr_utility.set_location('Validating:'||l_proc, 10);

OPEN csr_app_id;
FETCH csr_app_id INTO l_ext_application_id;
IF csr_app_id%NOTFOUND THEN

       close csr_app_id;
       fnd_message.set_name('PER','PER_449986_EAP_EAPP_ID_INVAL');
       fnd_message.raise_error;

END IF;
CLOSE csr_app_id;


hr_utility.set_location('Calling update SSO:'||l_proc, 20);

  -- delete the application
   hr_sso_utl.delete_application
   (
   p_appid => p_sso_id
   ,p_error => l_error
   );

   --if l_error =0 means application deleted from SSO

    if (l_error=0) then
        hr_eap_del.del
         (
         p_ext_application_id     => l_ext_application_id
         );
   else
     fnd_message.set_name('PER','PER_449987_EAP_SSODEL_ERR');
     fnd_message.raise_error;
   end if;

END delete_sso_details;
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
  (p_rec in hr_eap_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  -- Delete the hr_ki_ext_applications row.
  --
  delete from hr_ki_ext_applications
  where ext_application_id = p_rec.ext_application_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    --
    hr_eap_shd.constraint_error
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
Procedure pre_delete(p_rec in hr_eap_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_delete;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
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
-- {End Of Comments}
-- -----------------------------------------------------------------------------
Procedure post_delete(p_rec in hr_eap_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    hr_eap_rkd.after_delete
      (p_ext_application_id
      => p_rec.ext_application_id
      ,p_external_application_name_o
      => hr_eap_shd.g_old_rec.external_application_name
      ,p_external_application_id_o
      => hr_eap_shd.g_old_rec.external_application_id
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HR_KI_EXT_APPLICATIONS'
        ,p_hook_type   => 'AD');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_rec              in hr_eap_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  hr_eap_shd.lck
    (p_rec.ext_application_id
    );
  --
  -- Call the supporting delete validate operation
  --
  hr_eap_bus.delete_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  hr_eap_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  hr_eap_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  hr_eap_del.post_delete(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_ext_application_id                   in     number
  ) is
--
  l_rec   hr_eap_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.ext_application_id := p_ext_application_id;
  --
  --
  -- Having converted the arguments into the hr_eap_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  hr_eap_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end hr_eap_del;

/
