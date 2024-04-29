--------------------------------------------------------
--  DDL for Package Body PAY_PRT_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PRT_UPD" as
/* $Header: pyprtrhi.pkb 115.13 2003/02/28 15:52:21 alogue noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_prt_upd.';  -- Global package name
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
--   This procedure controls the actual dml update logic. The functions of this
--   procedure are as follows:
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
  (p_rec                   in out nocopy pay_prt_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc    varchar2(72) := g_package||'dt_update_dml';
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
        (p_base_table_name => 'pay_run_types_f'
        ,p_base_key_column => 'run_type_id'
        ,p_base_key_value  => p_rec.run_type_id
        );
    --
    -- Update the pay_run_types_f Row
    --
    update  pay_run_types_f
    set
     run_type_id                          = p_rec.run_type_id
    ,run_type_name                        = p_rec.run_type_name
    ,run_method                           = p_rec.run_method
    ,business_group_id                    = p_rec.business_group_id
    ,legislation_code                     = p_rec.legislation_code
    ,shortname                            = p_rec.shortname
    ,srs_flag                             = p_rec.srs_flag
    ,run_information_category		  = p_rec.run_information_category
    ,run_information1			  = p_rec.run_information1
    ,run_information2			  = p_rec.run_information2
    ,run_information3			  = p_rec.run_information3
    ,run_information4			  = p_rec.run_information4
    ,run_information5			  = p_rec.run_information5
    ,run_information6			  = p_rec.run_information6
    ,run_information7			  = p_rec.run_information7
    ,run_information8			  = p_rec.run_information8
    ,run_information9			  = p_rec.run_information9
    ,run_information10			  = p_rec.run_information10
    ,run_information11			  = p_rec.run_information11
    ,run_information12			  = p_rec.run_information12
    ,run_information13			  = p_rec.run_information13
    ,run_information14			  = p_rec.run_information14
    ,run_information15			  = p_rec.run_information15
    ,run_information16			  = p_rec.run_information16
    ,run_information17			  = p_rec.run_information17
    ,run_information18			  = p_rec.run_information18
    ,run_information19			  = p_rec.run_information19
    ,run_information20			  = p_rec.run_information20
    ,run_information21			  = p_rec.run_information21
    ,run_information22			  = p_rec.run_information22
    ,run_information23			  = p_rec.run_information23
    ,run_information24			  = p_rec.run_information24
    ,run_information25			  = p_rec.run_information25
    ,run_information26			  = p_rec.run_information26
    ,run_information27			  = p_rec.run_information27
    ,run_information28			  = p_rec.run_information28
    ,run_information29			  = p_rec.run_information29
    ,run_information30			  = p_rec.run_information30
    ,object_version_number                = p_rec.object_version_number
    where   run_type_id = p_rec.run_type_id
    and     effective_start_date = p_validation_start_date
    and     effective_end_date   = p_validation_end_date;
    --
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
    --
    pay_prt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    pay_prt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
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
  (p_rec                      in out nocopy pay_prt_shd.g_rec_type
  ,p_effective_date           in date
  ,p_datetrack_mode           in varchar2
  ,p_validation_start_date    in date
  ,p_validation_end_date      in date
  ) is
--
  l_proc    varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pay_prt_upd.dt_update_dml
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
--  the validation_start_date.
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
  (p_rec                     in out nocopy pay_prt_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc             varchar2(72) := g_package||'dt_pre_update';
  l_dummy_version_number number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode <> hr_api.g_correction) then
    --
    -- Update the current effective end date
    --
    pay_prt_shd.upd_effective_end_date
      (p_effective_date         => p_effective_date
      ,p_base_key_value         => p_rec.run_type_id
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
      pay_prt_del.delete_dml
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
    pay_prt_ins.insert_dml
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
--
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
  (p_rec                   in out nocopy pay_prt_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc    varchar2(72) := g_package||'pre_update';
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
  (p_rec                   in pay_prt_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc    varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pay_prt_rku.after_update
      (p_effective_date
      => p_effective_date
      ,p_datetrack_mode
      => p_datetrack_mode
      ,p_validation_start_date
      => p_validation_start_date
      ,p_validation_end_date
      => p_validation_end_date
      ,p_run_type_id
      => p_rec.run_type_id
  --    ,p_run_type_name
  --    => p_rec.run_type_name
      ,p_effective_start_date
      => p_rec.effective_start_date
      ,p_effective_end_date
      => p_rec.effective_end_date
      ,p_shortname
      => p_rec.shortname
      ,p_srs_flag
      => p_rec.srs_flag
      ,p_run_information_category
      => p_rec.run_information_category
      ,p_run_information1
      => p_rec.run_information1
      ,p_run_information2
      => p_rec.run_information2
      ,p_run_information3
      => p_rec.run_information3
      ,p_run_information4
      => p_rec.run_information4
      ,p_run_information5
      => p_rec.run_information5
      ,p_run_information6
      => p_rec.run_information6
      ,p_run_information7
      => p_rec.run_information7
      ,p_run_information8
      => p_rec.run_information8
      ,p_run_information9
      => p_rec.run_information9
      ,p_run_information10
      => p_rec.run_information10
      ,p_run_information11
      => p_rec.run_information11
      ,p_run_information12
      => p_rec.run_information12
      ,p_run_information13
      => p_rec.run_information13
      ,p_run_information14
      => p_rec.run_information14
      ,p_run_information15
      => p_rec.run_information15
      ,p_run_information16
      => p_rec.run_information16
      ,p_run_information17
      => p_rec.run_information17
      ,p_run_information18
      => p_rec.run_information18
      ,p_run_information19
      => p_rec.run_information19
      ,p_run_information20
      => p_rec.run_information20
      ,p_run_information21
      => p_rec.run_information21
      ,p_run_information22
      => p_rec.run_information22
      ,p_run_information23
      => p_rec.run_information23
      ,p_run_information24
      => p_rec.run_information24
      ,p_run_information25
      => p_rec.run_information25
      ,p_run_information26
      => p_rec.run_information26
      ,p_run_information27
      => p_rec.run_information27
      ,p_run_information28
      => p_rec.run_information28
      ,p_run_information29
      => p_rec.run_information29
      ,p_run_information30
      => p_rec.run_information30
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_run_type_name_o
      => pay_prt_shd.g_old_rec.run_type_name
      ,p_run_method_o
      => pay_prt_shd.g_old_rec.run_method
      ,p_effective_start_date_o
      => pay_prt_shd.g_old_rec.effective_start_date
      ,p_effective_end_date_o
      => pay_prt_shd.g_old_rec.effective_end_date
      ,p_business_group_id_o
      => pay_prt_shd.g_old_rec.business_group_id
      ,p_legislation_code_o
      => pay_prt_shd.g_old_rec.legislation_code
      ,p_shortname_o
      => pay_prt_shd.g_old_rec.shortname
      ,p_srs_flag_o
      => pay_prt_shd.g_old_rec.srs_flag
      ,p_run_information_category_o
      => pay_prt_shd.g_old_rec.run_information_category
      ,p_run_information1_o
      => pay_prt_shd.g_old_rec.run_information1
      ,p_run_information2_o
      => pay_prt_shd.g_old_rec.run_information2
      ,p_run_information3_o
      => pay_prt_shd.g_old_rec.run_information3
      ,p_run_information4_o
      => pay_prt_shd.g_old_rec.run_information4
      ,p_run_information5_o
      => pay_prt_shd.g_old_rec.run_information5
      ,p_run_information6_o
      => pay_prt_shd.g_old_rec.run_information6
      ,p_run_information7_o
      => pay_prt_shd.g_old_rec.run_information7
      ,p_run_information8_o
      => pay_prt_shd.g_old_rec.run_information8
      ,p_run_information9_o
      => pay_prt_shd.g_old_rec.run_information9
      ,p_run_information10_o
      => pay_prt_shd.g_old_rec.run_information10
      ,p_run_information11_o
      => pay_prt_shd.g_old_rec.run_information11
      ,p_run_information12_o
      => pay_prt_shd.g_old_rec.run_information12
      ,p_run_information13_o
      => pay_prt_shd.g_old_rec.run_information13
      ,p_run_information14_o
      => pay_prt_shd.g_old_rec.run_information14
      ,p_run_information15_o
      => pay_prt_shd.g_old_rec.run_information15
      ,p_run_information16_o
      => pay_prt_shd.g_old_rec.run_information16
      ,p_run_information17_o
      => pay_prt_shd.g_old_rec.run_information17
      ,p_run_information18_o
      => pay_prt_shd.g_old_rec.run_information18
      ,p_run_information19_o
      => pay_prt_shd.g_old_rec.run_information19
      ,p_run_information20_o
      => pay_prt_shd.g_old_rec.run_information20
      ,p_run_information21_o
      => pay_prt_shd.g_old_rec.run_information21
      ,p_run_information22_o
      => pay_prt_shd.g_old_rec.run_information22
      ,p_run_information23_o
      => pay_prt_shd.g_old_rec.run_information23
      ,p_run_information24_o
      => pay_prt_shd.g_old_rec.run_information24
      ,p_run_information25_o
      => pay_prt_shd.g_old_rec.run_information25
      ,p_run_information26_o
      => pay_prt_shd.g_old_rec.run_information26
      ,p_run_information27_o
      => pay_prt_shd.g_old_rec.run_information27
      ,p_run_information28_o
      => pay_prt_shd.g_old_rec.run_information28
      ,p_run_information29_o
      => pay_prt_shd.g_old_rec.run_information29
      ,p_run_information30_o
      => pay_prt_shd.g_old_rec.run_information30
      ,p_object_version_number_o
      => pay_prt_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_RUN_TYPES_F'
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
  (p_rec in out nocopy pay_prt_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.run_type_name = hr_api.g_varchar2) then
    p_rec.run_type_name :=
    pay_prt_shd.g_old_rec.run_type_name;
  End If;
  If (p_rec.run_method = hr_api.g_varchar2) then
    p_rec.run_method :=
    pay_prt_shd.g_old_rec.run_method;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    pay_prt_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.legislation_code = hr_api.g_varchar2) then
    p_rec.legislation_code :=
    pay_prt_shd.g_old_rec.legislation_code;
  End If;
  If (p_rec.shortname = hr_api.g_varchar2) then
    p_rec.shortname :=
    pay_prt_shd.g_old_rec.shortname;
  End If;
  If (p_rec.srs_flag = hr_api.g_varchar2) then
    p_rec.srs_flag :=
    pay_prt_shd.g_old_rec.srs_flag;
  End If;
  If (p_rec.run_information_category = hr_api.g_varchar2) then
     p_rec.run_information_category :=
     pay_prt_shd.g_old_rec.run_information_category;
  End If;
  If (p_rec.run_information1 = hr_api.g_varchar2) then
     p_rec.run_information1 :=
     pay_prt_shd.g_old_rec.run_information1;
  End If;
  If (p_rec.run_information2 = hr_api.g_varchar2) then
     p_rec.run_information2 :=
     pay_prt_shd.g_old_rec.run_information2;
  End If;
  If (p_rec.run_information3 = hr_api.g_varchar2) then
     p_rec.run_information3 :=
     pay_prt_shd.g_old_rec.run_information3;
  End If;
  If (p_rec.run_information4 = hr_api.g_varchar2) then
     p_rec.run_information4 :=
     pay_prt_shd.g_old_rec.run_information4;
  End If;
  If (p_rec.run_information5 = hr_api.g_varchar2) then
     p_rec.run_information5 :=
     pay_prt_shd.g_old_rec.run_information5;
  End If;
  If (p_rec.run_information6 = hr_api.g_varchar2) then
     p_rec.run_information6 :=
     pay_prt_shd.g_old_rec.run_information6;
  End If;
  If (p_rec.run_information7 = hr_api.g_varchar2) then
     p_rec.run_information7 :=
     pay_prt_shd.g_old_rec.run_information7;
  End If;
  If (p_rec.run_information8 = hr_api.g_varchar2) then
     p_rec.run_information8 :=
     pay_prt_shd.g_old_rec.run_information8;
  End If;
  If (p_rec.run_information9 = hr_api.g_varchar2) then
     p_rec.run_information9 :=
     pay_prt_shd.g_old_rec.run_information9;
  End If;
  If (p_rec.run_information10 = hr_api.g_varchar2) then
     p_rec.run_information10 :=
     pay_prt_shd.g_old_rec.run_information10;
  End If;
  If (p_rec.run_information11 = hr_api.g_varchar2) then
     p_rec.run_information11 :=
     pay_prt_shd.g_old_rec.run_information11;
  End If;
  If (p_rec.run_information12 = hr_api.g_varchar2) then
     p_rec.run_information12 :=
     pay_prt_shd.g_old_rec.run_information12;
  End If;
  If (p_rec.run_information13 = hr_api.g_varchar2) then
     p_rec.run_information13 :=
     pay_prt_shd.g_old_rec.run_information13;
  End If;
  If (p_rec.run_information14 = hr_api.g_varchar2) then
     p_rec.run_information14 :=
     pay_prt_shd.g_old_rec.run_information14;
  End If;
  If (p_rec.run_information15 = hr_api.g_varchar2) then
     p_rec.run_information15 :=
     pay_prt_shd.g_old_rec.run_information15;
  End If;
  If (p_rec.run_information16 = hr_api.g_varchar2) then
     p_rec.run_information16 :=
     pay_prt_shd.g_old_rec.run_information16;
  End If;
  If (p_rec.run_information17 = hr_api.g_varchar2) then
     p_rec.run_information17 :=
     pay_prt_shd.g_old_rec.run_information17;
  End If;
  If (p_rec.run_information18 = hr_api.g_varchar2) then
     p_rec.run_information18 :=
     pay_prt_shd.g_old_rec.run_information18;
  End If;
  If (p_rec.run_information19 = hr_api.g_varchar2) then
     p_rec.run_information19 :=
     pay_prt_shd.g_old_rec.run_information19;
  End If;
  If (p_rec.run_information20 = hr_api.g_varchar2) then
     p_rec.run_information20 :=
     pay_prt_shd.g_old_rec.run_information20;
  End If;
  If (p_rec.run_information21 = hr_api.g_varchar2) then
     p_rec.run_information21 :=
     pay_prt_shd.g_old_rec.run_information21;
  End If;
  If (p_rec.run_information22 = hr_api.g_varchar2) then
     p_rec.run_information22 :=
     pay_prt_shd.g_old_rec.run_information22;
  End If;
  If (p_rec.run_information23 = hr_api.g_varchar2) then
     p_rec.run_information23 :=
     pay_prt_shd.g_old_rec.run_information23;
  End If;
  If (p_rec.run_information24 = hr_api.g_varchar2) then
     p_rec.run_information24 :=
     pay_prt_shd.g_old_rec.run_information24;
  End If;
  If (p_rec.run_information25 = hr_api.g_varchar2) then
     p_rec.run_information25 :=
     pay_prt_shd.g_old_rec.run_information25;
  End If;
  If (p_rec.run_information26 = hr_api.g_varchar2) then
     p_rec.run_information26 :=
     pay_prt_shd.g_old_rec.run_information26;
  End If;
  If (p_rec.run_information27 = hr_api.g_varchar2) then
     p_rec.run_information27 :=
     pay_prt_shd.g_old_rec.run_information27;
  End If;
  If (p_rec.run_information28 = hr_api.g_varchar2) then
     p_rec.run_information28 :=
     pay_prt_shd.g_old_rec.run_information28;
  End If;
  If (p_rec.run_information29 = hr_api.g_varchar2) then
     p_rec.run_information29 :=
     pay_prt_shd.g_old_rec.run_information29;
  End If;
  If (p_rec.run_information30 = hr_api.g_varchar2) then
     p_rec.run_information30 :=
     pay_prt_shd.g_old_rec.run_information30;
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
  ,p_rec            in out nocopy pay_prt_shd.g_rec_type
  ) is
--
  l_proc            varchar2(72) := g_package||'upd';
  l_validation_start_date   date;
  l_validation_end_date     date;
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
  pay_prt_shd.lck
    (p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_run_type_id                      => p_rec.run_type_id
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
  pay_prt_upd.convert_defs(p_rec);
  --
  pay_prt_bus.update_validate
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
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
    ,p_validation_end_date              => l_validation_end_date
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
End upd;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< upd >-------------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_run_type_id                  in     number
  ,p_object_version_number        in out nocopy number
-- ,p_run_type_name                in     varchar2  default hr_api.g_varchar2
  ,p_shortname                    in     varchar2  default hr_api.g_varchar2
  ,p_srs_flag                     in     varchar2  default hr_api.g_varchar2
  ,p_run_information_category	  in     varchar2  default hr_api.g_varchar2
  ,p_run_information1		  in     varchar2  default hr_api.g_varchar2
  ,p_run_information2		  in     varchar2  default hr_api.g_varchar2
  ,p_run_information3		  in     varchar2  default hr_api.g_varchar2
  ,p_run_information4		  in     varchar2  default hr_api.g_varchar2
  ,p_run_information5		  in     varchar2  default hr_api.g_varchar2
  ,p_run_information6		  in     varchar2  default hr_api.g_varchar2
  ,p_run_information7		  in     varchar2  default hr_api.g_varchar2
  ,p_run_information8		  in     varchar2  default hr_api.g_varchar2
  ,p_run_information9		  in     varchar2  default hr_api.g_varchar2
  ,p_run_information10		  in     varchar2  default hr_api.g_varchar2
  ,p_run_information11		  in     varchar2  default hr_api.g_varchar2
  ,p_run_information12		  in     varchar2  default hr_api.g_varchar2
  ,p_run_information13		  in     varchar2  default hr_api.g_varchar2
  ,p_run_information14		  in     varchar2  default hr_api.g_varchar2
  ,p_run_information15		  in     varchar2  default hr_api.g_varchar2
  ,p_run_information16		  in     varchar2  default hr_api.g_varchar2
  ,p_run_information17		  in     varchar2  default hr_api.g_varchar2
  ,p_run_information18		  in     varchar2  default hr_api.g_varchar2
  ,p_run_information19		  in     varchar2  default hr_api.g_varchar2
  ,p_run_information20		  in     varchar2  default hr_api.g_varchar2
  ,p_run_information21		  in     varchar2  default hr_api.g_varchar2
  ,p_run_information22		  in     varchar2  default hr_api.g_varchar2
  ,p_run_information23		  in     varchar2  default hr_api.g_varchar2
  ,p_run_information24		  in     varchar2  default hr_api.g_varchar2
  ,p_run_information25		  in     varchar2  default hr_api.g_varchar2
  ,p_run_information26		  in     varchar2  default hr_api.g_varchar2
  ,p_run_information27		  in     varchar2  default hr_api.g_varchar2
  ,p_run_information28		  in     varchar2  default hr_api.g_varchar2
  ,p_run_information29		  in     varchar2  default hr_api.g_varchar2
  ,p_run_information30		  in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ) is
--
  l_rec     pay_prt_shd.g_rec_type;
  l_proc    varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pay_prt_shd.convert_args
    (p_run_type_id
    ,hr_api.g_varchar2
    ,hr_api.g_varchar2
    ,null
    ,null
    ,hr_api.g_number
    ,hr_api.g_varchar2
    ,p_shortname
    ,p_srs_flag
    ,p_run_information_category
    ,p_run_information1
    ,p_run_information2
    ,p_run_information3
    ,p_run_information4
    ,p_run_information5
    ,p_run_information6
    ,p_run_information7
    ,p_run_information8
    ,p_run_information9
    ,p_run_information10
    ,p_run_information11
    ,p_run_information12
    ,p_run_information13
    ,p_run_information14
    ,p_run_information15
    ,p_run_information16
    ,p_run_information17
    ,p_run_information18
    ,p_run_information19
    ,p_run_information20
    ,p_run_information21
    ,p_run_information22
    ,p_run_information23
    ,p_run_information24
    ,p_run_information25
    ,p_run_information26
    ,p_run_information27
    ,p_run_information28
    ,p_run_information29
    ,p_run_information30
    ,p_object_version_number
    );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pay_prt_upd.upd
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
end pay_prt_upd;

/
