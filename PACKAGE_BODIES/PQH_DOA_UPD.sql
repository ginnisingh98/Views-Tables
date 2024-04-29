--------------------------------------------------------
--  DDL for Package Body PQH_DOA_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DOA_UPD" as
/* $Header: pqdoarhi.pkb 115.0 2003/01/06 09:20:29 svorugan noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_doa_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_update_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of dml from the datetrack mode
--   of CORRECTION only. It is important to note that the object version
--   number is only increment by 1 because the datetrack correction is
--   soley for one datetracked row.
--   This procedure controls the actual dml update logic. The functions of
--   this procedure are as follows:
--   1) Get the next object_version_number.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   update_dml procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   The specified row will be updated in the schema.
--
-- Post Failure:
--   On the update dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check or unique integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_dml
  (p_rec                   in out NOCOPY pqh_doa_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'dt_update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_datetrack_mode = hr_api.g_correction) then
    hr_utility.set_location(l_proc, 10);
    --
    -- Because we are updating a row we must get the next object
    -- version number.
    --
    p_rec.object_version_number :=
      dt_api.get_object_version_number
        (p_base_table_name => 'pqh_document_attributes_f'
        ,p_base_key_column => 'document_attribute_id'
        ,p_base_key_value  => p_rec.document_attribute_id
        );
    --
    pqh_doa_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Update the pqh_document_attributes_f Row
    --
    update  pqh_document_attributes_f
    set
     document_attribute_id                = p_rec.document_attribute_id
    ,document_id                          = p_rec.document_id
    ,attribute_id                         = p_rec.attribute_id
    ,tag_name                             = p_rec.tag_name
    ,object_version_number                = p_rec.object_version_number
    where   document_attribute_id = p_rec.document_attribute_id
    and     effective_start_date = p_validation_start_date
    and     effective_end_date   = p_validation_end_date;
    --
    pqh_doa_shd.g_api_dml := false;   -- Unset the api dml status
    --
    -- Set the effective start and end dates
    --
    p_rec.effective_start_date := p_validation_start_date;
    p_rec.effective_end_date   := p_validation_end_date;
  End If;
--
hr_utility.set_location(' Leaving:'||l_proc, 15);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqh_doa_shd.g_api_dml := false;   -- Unset the api dml status
    pqh_doa_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqh_doa_shd.g_api_dml := false;   -- Unset the api dml status
    pqh_doa_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pqh_doa_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure calls the dt_update_dml control logic which handles
--   the actual datetrack dml.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing contines.
--
-- Post Failure:
--   No specific error handling is required within this procedure.
--
-- Developer Implementation Notes:
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml
  (p_rec                      in out NOCOPY pqh_doa_shd.g_rec_type
  ,p_effective_date           in date
  ,p_datetrack_mode           in varchar2
  ,p_validation_start_date    in date
  ,p_validation_end_date      in date
  ) is
--
  l_proc        varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pqh_doa_upd.dt_update_dml
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => p_datetrack_mode
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_dml;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_pre_update >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The dt_pre_update procedure controls the execution
--   of dml for the datetrack modes of: UPDATE, UPDATE_OVERRIDE
--   and UPDATE_CHANGE_INSERT only. The execution required is as
--   follows:
--
--   1) Providing the datetrack update mode is not 'CORRECTION'
--      then set the effective end date of the current row (this
--      will be the validation_start_date - 1).
--   2) If the datetrack mode is 'UPDATE_OVERRIDE' then call the
--      corresponding delete_dml process to delete any future rows
--      where the effective_start_date is greater than or equal to
--      the validation_start_date.
--   3) Call the insert_dml process to insert the new updated row
--      details.
--
-- Prerequisites:
--   This is an internal procedure which is called from the
--   pre_update procedure.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   This is an internal procedure which is required by Datetrack. Don't
--   remove or modify.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_pre_update
  (p_rec                     in out NOCOPY     pqh_doa_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc                 varchar2(72) := g_package||'dt_pre_update';
  l_dummy_version_number number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode <> hr_api.g_correction) then
    --
    -- Update the current effective end date
    --
    pqh_doa_shd.upd_effective_end_date
      (p_effective_date         => p_effective_date
      ,p_base_key_value         => p_rec.document_attribute_id
      ,p_new_effective_end_date => (p_validation_start_date - 1)
      ,p_validation_start_date  => p_validation_start_date
      ,p_validation_end_date    => p_validation_end_date
      ,p_object_version_number  => l_dummy_version_number
      );
    --
    If (p_datetrack_mode = hr_api.g_update_override) then
      --
      -- As the datetrack mode is 'UPDATE_OVERRIDE' then we must
      -- delete any future rows
      --
      pqh_doa_del.delete_dml
        (p_rec                   => p_rec
        ,p_effective_date        => p_effective_date
        ,p_datetrack_mode        => p_datetrack_mode
        ,p_validation_start_date => p_validation_start_date
        ,p_validation_end_date   => p_validation_end_date
        );
    End If;
    --
    -- We must now insert the updated row
    --
    pqh_doa_ins.insert_dml
      (p_rec                    => p_rec
      ,p_effective_date         => p_effective_date
      ,p_datetrack_mode         => p_datetrack_mode
      ,p_validation_start_date  => p_validation_start_date
      ,p_validation_end_date    => p_validation_end_date
      );
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End dt_pre_update;
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
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
-- Developer Implementation Notes:
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure. The call
--   to the dt_update_dml procedure should NOT be removed.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update
  (p_rec                   in out NOCOPY pqh_doa_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  dt_pre_update
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => p_datetrack_mode
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_update;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< post_update >-------------------------------|
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
  (p_rec                   in pqh_doa_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pqh_doa_rku.after_update
      (p_effective_date
      => p_effective_date
      ,p_datetrack_mode
      => p_datetrack_mode
      ,p_validation_start_date
      => p_validation_start_date
      ,p_validation_end_date
      => p_validation_end_date
      ,p_document_attribute_id
      => p_rec.document_attribute_id
      ,p_effective_start_date
      => p_rec.effective_start_date
      ,p_effective_end_date
      => p_rec.effective_end_date
      ,p_document_id
      => p_rec.document_id
      ,p_attribute_id
      => p_rec.attribute_id
      ,p_tag_name
      => p_rec.tag_name
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_effective_start_date_o
      => pqh_doa_shd.g_old_rec.effective_start_date
      ,p_effective_end_date_o
      => pqh_doa_shd.g_old_rec.effective_end_date
      ,p_document_id_o
      => pqh_doa_shd.g_old_rec.document_id
      ,p_attribute_id_o
      => pqh_doa_shd.g_old_rec.attribute_id
      ,p_tag_name_o
      => pqh_doa_shd.g_old_rec.tag_name
      ,p_object_version_number_o
      => pqh_doa_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_DOCUMENT_ATTRIBUTES_F'
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
  (p_rec in out NOCOPY pqh_doa_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.document_id = hr_api.g_number) then
    p_rec.document_id :=
    pqh_doa_shd.g_old_rec.document_id;
  End If;
  If (p_rec.attribute_id = hr_api.g_number) then
    p_rec.attribute_id :=
    pqh_doa_shd.g_old_rec.attribute_id;
  End If;
  If (p_rec.tag_name = hr_api.g_varchar2) then
    p_rec.tag_name :=
    pqh_doa_shd.g_old_rec.tag_name;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date in     date
  ,p_datetrack_mode in     varchar2
  ,p_rec            in out NOCOPY pqh_doa_shd.g_rec_type
  ) is
--
  l_proc                        varchar2(72) := g_package||'upd';
  l_validation_start_date       date;
  l_validation_end_date         date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the DateTrack update mode is valid
  --
  dt_api.validate_dt_upd_mode(p_datetrack_mode => p_datetrack_mode);
  --
  -- We must lock the row which we need to update.
  --
  pqh_doa_shd.lck
    (p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_document_attribute_id            => p_rec.document_attribute_id
    ,p_object_version_number            => p_rec.object_version_number
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  pqh_doa_upd.convert_defs(p_rec);
  --
  pqh_doa_bus.update_validate
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  pre_update
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Update the row.
  --
  update_dml
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date                  => l_validation_end_date
    );
  --
  -- Call the supporting post-update operation
  --
  post_update
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
End upd;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< upd >-------------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_document_attribute_id        in     number
  ,p_object_version_number        in out NOCOPY number
  ,p_document_id                  in     number    default hr_api.g_number
  ,p_attribute_id                 in     number    default hr_api.g_number
  ,p_tag_name                     in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out NOCOPY date
  ,p_effective_end_date              out NOCOPY date
  ) is
--
  l_rec         pqh_doa_shd.g_rec_type;
  l_proc        varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pqh_doa_shd.convert_args
    (p_document_attribute_id
    ,null
    ,null
    ,p_document_id
    ,p_attribute_id
    ,p_tag_name
    ,p_object_version_number
    );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pqh_doa_upd.upd
    (p_effective_date
    ,p_datetrack_mode
    ,l_rec
    );
  --
  -- Set the out parameters
  --
  p_object_version_number            := l_rec.object_version_number;
  p_effective_start_date             := l_rec.effective_start_date;
  p_effective_end_date               := l_rec.effective_end_date;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pqh_doa_upd;

/
