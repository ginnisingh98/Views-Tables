--------------------------------------------------------
--  DDL for Package Body IRC_IDO_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_IDO_UPD" as
/* $Header: iridorhi.pkb 120.5.12010000.2 2008/09/26 13:55:20 pvelugul ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_ido_upd.';  -- Global package name
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
  (p_rec in out nocopy irc_ido_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  irc_ido_shd.g_api_dml := true;  -- Set the dml status
  --
  --
  -- Update the irc_documents Row
  --
  update irc_documents
    set
     document_id                     = p_rec.document_id
    ,party_id                        = p_rec.party_id
    ,assignment_id                   = p_rec.assignment_id
    ,file_name                       = p_rec.file_name
    ,mime_type                       = p_rec.mime_type
    ,description                     = p_rec.description
    ,type                            = p_rec.type
    ,object_version_number           = p_rec.object_version_number
    ,end_date			     = p_rec.end_date
    ,character_doc		     = null
    where document_id = p_rec.document_id;
  --
  irc_ido_shd.g_api_dml := false;  -- Unset the dml status
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    irc_ido_shd.g_api_dml := false;  -- Unset the dml status
    --
    irc_ido_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    irc_ido_shd.g_api_dml := false;  -- Unset the dml status
    --
    irc_ido_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    irc_ido_shd.g_api_dml := false;  -- Unset the dml status
    --
    irc_ido_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    irc_ido_shd.g_api_dml := false;  -- Unset the dml status
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
  (p_rec in out nocopy irc_ido_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Derive file_format from MIME type
  --
  if (p_rec.mime_type = 'text/html') OR
     (p_rec.mime_type = 'text/xml') then
    p_rec.file_format := 'TEXT';
  else
    p_rec.file_format := 'BINARY';
  end if;

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
  (p_effective_date               in date
  ,p_rec                          in irc_ido_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    irc_ido_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_document_id
      => p_rec.document_id
      ,p_party_id
      => p_rec.party_id
      ,p_person_id => p_rec.person_id
      ,p_assignment_id
      => p_rec.assignment_id
      ,p_file_name
      => p_rec.file_name
      ,p_file_format
      => p_rec.file_format
      ,p_mime_type
      => p_rec.mime_type
      ,p_description
      => p_rec.description
      ,p_type
      => p_rec.type
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_end_date
      => p_rec.end_date
      ,p_party_id_o
      => irc_ido_shd.g_old_rec.party_id
     ,p_person_id_o => irc_ido_shd.g_old_rec.person_id
      ,p_assignment_id_o
      => irc_ido_shd.g_old_rec.assignment_id
      ,p_file_name_o
      => irc_ido_shd.g_old_rec.file_name
      ,p_file_format_o
      => irc_ido_shd.g_old_rec.file_format
      ,p_mime_type_o
      => irc_ido_shd.g_old_rec.mime_type
      ,p_description_o
      => irc_ido_shd.g_old_rec.description
      ,p_type_o
      => irc_ido_shd.g_old_rec.type
      ,p_object_version_number_o
      => irc_ido_shd.g_old_rec.object_version_number
      ,p_end_date_o
      => irc_ido_shd.g_old_rec.end_date
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'IRC_DOCUMENTS'
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
  (p_rec in out nocopy irc_ido_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.party_id = hr_api.g_number) then
    p_rec.party_id :=
    irc_ido_shd.g_old_rec.party_id;
  End If;
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id := irc_ido_shd.g_old_rec.person_id;
  End If;
  If (p_rec.assignment_id = hr_api.g_number) then
    p_rec.assignment_id :=
    irc_ido_shd.g_old_rec.assignment_id;
  End If;
  If (p_rec.file_name = hr_api.g_varchar2) then
    p_rec.file_name :=
    irc_ido_shd.g_old_rec.file_name;
  End If;
  If (p_rec.file_format = hr_api.g_varchar2) then
    p_rec.file_format :=
    irc_ido_shd.g_old_rec.file_format;
  End If;
  If (p_rec.mime_type = hr_api.g_varchar2) then
    p_rec.mime_type :=
    irc_ido_shd.g_old_rec.mime_type;
  End If;
  If (p_rec.description = hr_api.g_varchar2) then
    p_rec.description :=
    irc_ido_shd.g_old_rec.description;
  End If;
  If (p_rec.type = hr_api.g_varchar2) then
    p_rec.type :=
    irc_ido_shd.g_old_rec.type;
  End If;
  If (p_rec.end_date = hr_api.g_date) then
     p_rec.end_date :=
     irc_ido_shd.g_old_rec.end_date;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy irc_ido_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  irc_ido_shd.lck
    (p_rec.document_id
    ,p_rec.object_version_number
    );
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  irc_ido_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call the supporting pre-update operation
  --
  irc_ido_upd.pre_update(p_rec);
  --
  if p_rec.party_id is null then
   p_rec.party_id := irc_ido_shd.g_old_rec.party_id;
  end if;
  if p_rec.person_id is null then
    p_rec.person_id := irc_ido_shd.g_old_rec.person_id;
  end if;
  if p_rec.assignment_id is null then
   p_rec.assignment_id := irc_ido_shd.g_old_rec.assignment_id;
  end if;

  --
  -- Update the row.
  --
  irc_ido_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  irc_ido_upd.post_update
     (p_effective_date
     ,p_rec
     );
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in     date
  ,p_document_id                  in     number
  ,p_object_version_number        in out nocopy number
  ,p_mime_type                    in     varchar2  default hr_api.g_varchar2
  ,p_type                         in     varchar2  default hr_api.g_varchar2
  ,p_file_name                    in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_end_date			  in	 date	   default hr_api.g_date
  ) is
--
  l_rec   irc_ido_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  irc_ido_shd.convert_args
  (p_document_id
  ,null
  ,null
  ,null
  ,empty_clob()
  ,p_file_name
  ,p_mime_type
  ,p_description
  ,p_type
  ,empty_clob()
  ,p_object_version_number
  ,p_end_date
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  irc_ido_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end irc_ido_upd;

/
