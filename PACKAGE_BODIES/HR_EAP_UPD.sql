--------------------------------------------------------
--  DDL for Package Body HR_EAP_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_EAP_UPD" as
/* $Header: hreaprhi.pkb 115.0 2004/01/09 00:17 vkarandi noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_eap_upd.';  -- Global package name


-- ----------------------------------------------------------------------------
-- |----------------------------< update_sso_details >------------------------|
-- ----------------------------------------------------------------------------

PROCEDURE update_sso_details (
            p_ext_application_id   IN number,
            p_app_code             IN VARCHAR2,
            p_apptype              IN VARCHAR2,
            p_appurl               IN VARCHAR2,
            p_logout_url           IN VARCHAR2,
            p_userfld              IN VARCHAR2,
            p_pwdfld               IN VARCHAR2,
            p_authused             IN VARCHAR2,
            p_fname1               IN VARCHAR2 DEFAULT NULL,
            p_fval1                IN VARCHAR2 DEFAULT NULL,
            p_fname2               IN VARCHAR2 DEFAULT NULL,
            p_fval2                IN VARCHAR2 DEFAULT NULL,
            p_fname3               IN VARCHAR2 DEFAULT NULL,
            p_fval3                IN VARCHAR2 DEFAULT NULL,
            p_fname4               IN VARCHAR2 DEFAULT NULL,
            p_fval4                IN VARCHAR2 DEFAULT NULL,
            p_fname5               IN VARCHAR2 DEFAULT NULL,
            p_fval5                IN VARCHAR2 DEFAULT NULL,
            p_fname6               IN VARCHAR2 DEFAULT NULL,
            p_fval6                IN VARCHAR2 DEFAULT NULL,
            p_fname7               IN VARCHAR2 DEFAULT NULL,
            p_fval7                IN VARCHAR2 DEFAULT NULL,
            p_fname8               IN VARCHAR2 DEFAULT NULL,
            p_fval8                IN VARCHAR2 DEFAULT NULL,
            p_fname9               IN VARCHAR2 DEFAULT NULL,
            p_fval9                IN VARCHAR2 DEFAULT NULL) IS

l_app_id  NUMBER(15) := NULL;

l_proc     varchar2(72) := g_package || 'update_sso_details';

CURSOR csr_app_id IS
select external_application_id
from hr_ki_ext_applications
where ext_application_id=p_ext_application_id;


BEGIN

--
--Make sure that ext_application_id is not null
--

hr_utility.set_location('Entering:'||l_proc, 5);

  hr_api.mandatory_arg_error
  (p_api_name           => l_proc
  ,p_argument           => 'EXT_APPLICATION_ID'
  ,p_argument_value     => p_ext_application_id
  );

hr_utility.set_location('Validating:'||l_proc, 10);

OPEN csr_app_id;
FETCH csr_app_id INTO l_app_id;
IF csr_app_id%NOTFOUND THEN

       close csr_app_id;
       fnd_message.set_name('PER','PER_449986_EAP_EAPP_ID_INVAL');
       fnd_message.raise_error;

END IF;
CLOSE csr_app_id;


hr_utility.set_location('Calling update SSO:'||l_proc, 20);

  -- update the application

  hr_sso_utl.PSTORE_MODIFY_APP_INFO (
        p_appid          => l_app_id,
        p_app_name       => p_app_code,
        p_apptype        => p_apptype,
        p_appurl         => p_appurl,
        p_logout_url     => p_logout_url,
        p_userfield      => p_userfld,
        p_pwdfield       => p_pwdfld,
        p_authneeded     => p_authused,
        p_fname1         => p_fname1,
        p_fval1          => p_fval1,
        p_fname2         => p_fname2,
        p_fval2          => p_fval2,
        p_fname3         => p_fname3,
        p_fval3          => p_fval3,
        p_fname4         => p_fname4,
        p_fval4          => p_fval4,
        p_fname5         => p_fname5,
        p_fval5          => p_fval5,
        p_fname6         => p_fname6,
        p_fval6          => p_fval6,
        p_fname7         => p_fname7,
        p_fval7          => p_fval7,
        p_fname8         => p_fname8,
        p_fval8          => p_fval8,
        p_fname9         => p_fname9,
        p_fval9          => p_fval9);


-- update record into hr_ki_ext_applications

  hr_eap_upd.upd
    (
     p_ext_application_id           => p_ext_application_id
    ,p_external_application_name    => p_app_code

    );


END update_sso_details;


--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
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
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   The update 'set' attribute list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml
  (p_rec in out nocopy hr_eap_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  --
  -- Update the hr_ki_ext_applications Row
  --
  update hr_ki_ext_applications
    set
     ext_application_id              = p_rec.ext_application_id
    ,external_application_name       = p_rec.external_application_name

    where ext_application_id = p_rec.ext_application_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    hr_eap_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    hr_eap_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    hr_eap_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
    Raise;
End update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_update >------------------------------|
-- ----------------------------------------------------------------------------
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
--   If an error has occurred, an error message and exception wil be raised
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
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update
  (p_rec in hr_eap_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after
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
--   If an error has occurred, an error message and exception will be raised
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
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update
  (p_rec                          in hr_eap_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    hr_eap_rku.after_update
      (p_ext_application_id
      => p_rec.ext_application_id
      ,p_external_application_name
      => p_rec.external_application_name
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
        ,p_hook_type   => 'AU');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
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
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs
  (p_rec in out nocopy hr_eap_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.external_application_name = hr_api.g_varchar2) then
    p_rec.external_application_name :=
    hr_eap_shd.g_old_rec.external_application_name;
  End If;
  If (p_rec.external_application_id = hr_api.g_varchar2) then
    p_rec.external_application_id :=
    hr_eap_shd.g_old_rec.external_application_id;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy hr_eap_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  hr_eap_shd.lck
    (p_rec.ext_application_id
    );
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  hr_eap_bus.update_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  hr_eap_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  hr_eap_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  hr_eap_upd.post_update
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_ext_application_id           in     number
  ,p_external_application_name    in     varchar2  default hr_api.g_varchar2

  ) is
--

  l_rec   hr_eap_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  hr_eap_shd.convert_args
  (p_ext_application_id
  ,p_external_application_name
  ,hr_api.g_varchar2
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  hr_eap_upd.upd
     (l_rec
     );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end hr_eap_upd;

/
