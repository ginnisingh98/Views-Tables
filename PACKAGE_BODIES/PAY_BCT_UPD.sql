--------------------------------------------------------
--  DDL for Package Body PAY_BCT_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BCT_UPD" as
/* $Header: pybctrhi.pkb 120.0.12000000.4 2007/08/20 08:21:49 ayegappa noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_bct_upd.';  -- Global package name
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
  (p_rec in out nocopy pay_bct_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
  l_range_flag varchar2(2)	:=	'F';
  l_control_total_dup1		pay_batch_control_totals.control_total%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  pay_bct_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- added for bug 6013383
  -- convert the Number format from Display format( 99,999.99 OR 99.999,99) to
  -- database format (99999.99)
  --
  hr_utility.set_location('Converting Control total from display format to database format: ' ||l_proc,6) ;
  --
  l_control_total_dup1 :=   p_rec.control_total;


  hr_chkfmt.checkformat (p_rec.control_total  ,
                       'NUMBER' ,
                       l_control_total_dup1,
                       null ,
                       null ,
		       'N'  ,
		       l_range_flag,
                       null );
  p_rec.control_total := l_control_total_dup1;
  --
  -- Update the pay_batch_control_totals Row

  update pay_batch_control_totals
    set
     batch_control_id                = p_rec.batch_control_id
    ,control_status                  = p_rec.control_status
    ,control_total                   = p_rec.control_total
    ,control_type                    = p_rec.control_type
    ,object_version_number           = p_rec.object_version_number
    where batch_control_id = p_rec.batch_control_id;
  --
  pay_bct_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pay_bct_shd.g_api_dml := false;   -- Unset the api dml status
    pay_bct_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pay_bct_shd.g_api_dml := false;   -- Unset the api dml status
    pay_bct_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pay_bct_shd.g_api_dml := false;   -- Unset the api dml status
    pay_bct_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pay_bct_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec in pay_bct_shd.g_rec_type
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
--   This private procedure contains any processing which is required after the
--   update dml.
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
  (p_session_date                 in date
  ,p_rec                          in pay_bct_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pay_bct_rku.after_update
      (p_session_date
      => p_session_date
      ,p_batch_control_id
      => p_rec.batch_control_id
      ,p_control_status
      => p_rec.control_status
      ,p_control_total
      => p_rec.control_total
      ,p_control_type
      => p_rec.control_type
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_batch_id_o
      => pay_bct_shd.g_old_rec.batch_id
      ,p_control_status_o
      => pay_bct_shd.g_old_rec.control_status
      ,p_control_total_o
      => pay_bct_shd.g_old_rec.control_total
      ,p_control_type_o
      => pay_bct_shd.g_old_rec.control_type
      ,p_object_version_number_o
      => pay_bct_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_BATCH_CONTROL_TOTALS'
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
  (p_rec in out nocopy pay_bct_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.batch_id = hr_api.g_number) then
    p_rec.batch_id :=
    pay_bct_shd.g_old_rec.batch_id;
  End If;
  If (p_rec.control_status = hr_api.g_varchar2) then
    p_rec.control_status :=
    pay_bct_shd.g_old_rec.control_status;
  End If;
  If (p_rec.control_total = hr_api.g_varchar2) then
    p_rec.control_total :=
    pay_bct_shd.g_old_rec.control_total;
  End If;
  If (p_rec.control_type = hr_api.g_varchar2) then
    p_rec.control_type :=
    pay_bct_shd.g_old_rec.control_type;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_session_date                 in     date
  ,p_rec                          in out nocopy pay_bct_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pay_bct_shd.lck
    (p_rec.batch_control_id
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
  pay_bct_bus.update_validate
     (p_session_date,
      p_rec
     );
  --
  -- Call the supporting pre-update operation
  --
  pay_bct_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  pay_bct_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  pay_bct_upd.post_update
     (p_session_date
     ,p_rec
     );
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_session_date                 in     date
  ,p_batch_control_id             in     number
  ,p_object_version_number        in out nocopy number
  ,p_control_status               in     varchar2  default hr_api.g_varchar2
  ,p_control_total                in     varchar2  default hr_api.g_varchar2
  ,p_control_type                 in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec	  pay_bct_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pay_bct_shd.convert_args
  (p_batch_control_id
  ,hr_api.g_number
  ,p_control_status
  ,p_control_total
  ,p_control_type
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pay_bct_upd.upd
     (p_session_date,
      l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pay_bct_upd;

/
