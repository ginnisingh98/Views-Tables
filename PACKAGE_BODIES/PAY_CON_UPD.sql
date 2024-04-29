--------------------------------------------------------
--  DDL for Package Body PAY_CON_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CON_UPD" as
/* $Header: pyconrhi.pkb 115.3 1999/12/03 16:45:29 pkm ship      $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_con_upd.';  -- Global package name
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
Procedure update_dml(p_rec in out pay_con_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  --
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  pay_con_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the pay_us_contribution_history Row
  --
  update pay_us_contribution_history
  set
  contr_history_id                  = p_rec.contr_history_id,
  person_id                         = p_rec.person_id,
  date_from                         = p_rec.date_from,
  date_to                           = p_rec.date_to,
  contr_type                        = p_rec.contr_type,
  business_group_id                 = p_rec.business_group_id,
  legislation_code                  = p_rec.legislation_code,
  amt_contr                         = p_rec.amt_contr,
  max_contr_allowed                 = p_rec.max_contr_allowed,
  includable_comp                   = p_rec.includable_comp,
  tax_unit_id                       = p_rec.tax_unit_id,
  source_system                     = p_rec.source_system,
  contr_information_category        = p_rec.contr_information_category,
  contr_information1                = p_rec.contr_information1,
  contr_information2                = p_rec.contr_information2,
  contr_information3                = p_rec.contr_information3,
  contr_information4                = p_rec.contr_information4,
  contr_information5                = p_rec.contr_information5,
  contr_information6                = p_rec.contr_information6,
  contr_information7                = p_rec.contr_information7,
  contr_information8                = p_rec.contr_information8,
  contr_information9                = p_rec.contr_information9,
  contr_information10               = p_rec.contr_information10,
  contr_information11               = p_rec.contr_information11,
  contr_information12               = p_rec.contr_information12,
  contr_information13               = p_rec.contr_information13,
  contr_information14               = p_rec.contr_information14,
  contr_information15               = p_rec.contr_information15,
  contr_information16               = p_rec.contr_information16,
  contr_information17               = p_rec.contr_information17,
  contr_information18               = p_rec.contr_information18,
  contr_information19               = p_rec.contr_information19,
  contr_information20               = p_rec.contr_information20,
  contr_information21               = p_rec.contr_information21,
  contr_information22               = p_rec.contr_information22,
  contr_information23               = p_rec.contr_information23,
  contr_information24               = p_rec.contr_information24,
  contr_information25               = p_rec.contr_information25,
  contr_information26               = p_rec.contr_information26,
  contr_information27               = p_rec.contr_information27,
  contr_information28               = p_rec.contr_information28,
  contr_information29               = p_rec.contr_information29,
  contr_information30               = p_rec.contr_information30,
  object_version_number             = p_rec.object_version_number
  where contr_history_id = p_rec.contr_history_id;
  --
  pay_con_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pay_con_shd.g_api_dml := false;   -- Unset the api dml status
    pay_con_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pay_con_shd.g_api_dml := false;   -- Unset the api dml status
    pay_con_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pay_con_shd.g_api_dml := false;   -- Unset the api dml status
    pay_con_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pay_con_shd.g_api_dml := false;   -- Unset the api dml status
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
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update(p_rec in pay_con_shd.g_rec_type) is
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
--   Any post-processing required after the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update(p_rec in pay_con_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_update.
  --
  begin
    --
    pay_con_rku.after_update
      (
  p_contr_history_id              =>p_rec.contr_history_id
 ,p_person_id                     =>p_rec.person_id
 ,p_date_from                     =>p_rec.date_from
 ,p_date_to                       =>p_rec.date_to
 ,p_contr_type                    =>p_rec.contr_type
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_legislation_code              =>p_rec.legislation_code
 ,p_amt_contr                     =>p_rec.amt_contr
 ,p_max_contr_allowed             =>p_rec.max_contr_allowed
 ,p_includable_comp               =>p_rec.includable_comp
 ,p_tax_unit_id                   =>p_rec.tax_unit_id
 ,p_source_system                 =>p_rec.source_system
 ,p_contr_information_category    =>p_rec.contr_information_category
 ,p_contr_information1            =>p_rec.contr_information1
 ,p_contr_information2            =>p_rec.contr_information2
 ,p_contr_information3            =>p_rec.contr_information3
 ,p_contr_information4            =>p_rec.contr_information4
 ,p_contr_information5            =>p_rec.contr_information5
 ,p_contr_information6            =>p_rec.contr_information6
 ,p_contr_information7            =>p_rec.contr_information7
 ,p_contr_information8            =>p_rec.contr_information8
 ,p_contr_information9            =>p_rec.contr_information9
 ,p_contr_information10           =>p_rec.contr_information10
 ,p_contr_information11           =>p_rec.contr_information11
 ,p_contr_information12           =>p_rec.contr_information12
 ,p_contr_information13           =>p_rec.contr_information13
 ,p_contr_information14           =>p_rec.contr_information14
 ,p_contr_information15           =>p_rec.contr_information15
 ,p_contr_information16           =>p_rec.contr_information16
 ,p_contr_information17           =>p_rec.contr_information17
 ,p_contr_information18           =>p_rec.contr_information18
 ,p_contr_information19           =>p_rec.contr_information19
 ,p_contr_information20           =>p_rec.contr_information20
 ,p_contr_information21           =>p_rec.contr_information21
 ,p_contr_information22           =>p_rec.contr_information22
 ,p_contr_information23           =>p_rec.contr_information23
 ,p_contr_information24           =>p_rec.contr_information24
 ,p_contr_information25           =>p_rec.contr_information25
 ,p_contr_information26           =>p_rec.contr_information26
 ,p_contr_information27           =>p_rec.contr_information27
 ,p_contr_information28           =>p_rec.contr_information28
 ,p_contr_information29           =>p_rec.contr_information29
 ,p_contr_information30           =>p_rec.contr_information30
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_person_id_o                   =>pay_con_shd.g_old_rec.person_id
 ,p_date_from_o                   =>pay_con_shd.g_old_rec.date_from
 ,p_date_to_o                     =>pay_con_shd.g_old_rec.date_to
 ,p_contr_type_o                  =>pay_con_shd.g_old_rec.contr_type
 ,p_business_group_id_o           =>pay_con_shd.g_old_rec.business_group_id
 ,p_legislation_code_o            =>pay_con_shd.g_old_rec.legislation_code
 ,p_amt_contr_o                   =>pay_con_shd.g_old_rec.amt_contr
 ,p_max_contr_allowed_o           =>pay_con_shd.g_old_rec.max_contr_allowed
 ,p_includable_comp_o             =>pay_con_shd.g_old_rec.includable_comp
 ,p_tax_unit_id_o                 =>pay_con_shd.g_old_rec.tax_unit_id
 ,p_source_system_o               =>pay_con_shd.g_old_rec.source_system
 ,p_contr_information_category_o  =>pay_con_shd.g_old_rec.contr_information_category
 ,p_contr_information1_o          =>pay_con_shd.g_old_rec.contr_information1
 ,p_contr_information2_o          =>pay_con_shd.g_old_rec.contr_information2
 ,p_contr_information3_o          =>pay_con_shd.g_old_rec.contr_information3
 ,p_contr_information4_o          =>pay_con_shd.g_old_rec.contr_information4
 ,p_contr_information5_o          =>pay_con_shd.g_old_rec.contr_information5
 ,p_contr_information6_o          =>pay_con_shd.g_old_rec.contr_information6
 ,p_contr_information7_o          =>pay_con_shd.g_old_rec.contr_information7
 ,p_contr_information8_o          =>pay_con_shd.g_old_rec.contr_information8
 ,p_contr_information9_o          =>pay_con_shd.g_old_rec.contr_information9
 ,p_contr_information10_o         =>pay_con_shd.g_old_rec.contr_information10
 ,p_contr_information11_o         =>pay_con_shd.g_old_rec.contr_information11
 ,p_contr_information12_o         =>pay_con_shd.g_old_rec.contr_information12
 ,p_contr_information13_o         =>pay_con_shd.g_old_rec.contr_information13
 ,p_contr_information14_o         =>pay_con_shd.g_old_rec.contr_information14
 ,p_contr_information15_o         =>pay_con_shd.g_old_rec.contr_information15
 ,p_contr_information16_o         =>pay_con_shd.g_old_rec.contr_information16
 ,p_contr_information17_o         =>pay_con_shd.g_old_rec.contr_information17
 ,p_contr_information18_o         =>pay_con_shd.g_old_rec.contr_information18
 ,p_contr_information19_o         =>pay_con_shd.g_old_rec.contr_information19
 ,p_contr_information20_o         =>pay_con_shd.g_old_rec.contr_information20
 ,p_contr_information21_o         =>pay_con_shd.g_old_rec.contr_information21
 ,p_contr_information22_o         =>pay_con_shd.g_old_rec.contr_information22
 ,p_contr_information23_o         =>pay_con_shd.g_old_rec.contr_information23
 ,p_contr_information24_o         =>pay_con_shd.g_old_rec.contr_information24
 ,p_contr_information25_o         =>pay_con_shd.g_old_rec.contr_information25
 ,p_contr_information26_o         =>pay_con_shd.g_old_rec.contr_information26
 ,p_contr_information27_o         =>pay_con_shd.g_old_rec.contr_information27
 ,p_contr_information28_o         =>pay_con_shd.g_old_rec.contr_information28
 ,p_contr_information29_o         =>pay_con_shd.g_old_rec.contr_information29
 ,p_contr_information30_o         =>pay_con_shd.g_old_rec.contr_information30
 ,p_object_version_number_o       =>pay_con_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pay_contribution_history'
        ,p_hook_type   => 'AU');
      --
  end;
  --
  -- End of API User Hook for post_update.
  --
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
--   A Pl/Sql record structre.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to conversion
--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs(p_rec in out pay_con_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'convert_defs';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id :=
    pay_con_shd.g_old_rec.person_id;
  End If;
  If (p_rec.date_from = hr_api.g_date) then
    p_rec.date_from :=
    pay_con_shd.g_old_rec.date_from;
  End If;
  If (p_rec.date_to = hr_api.g_date) then
    p_rec.date_to :=
    pay_con_shd.g_old_rec.date_to;
  End If;
  If (p_rec.contr_type = hr_api.g_varchar2) then
    p_rec.contr_type :=
    pay_con_shd.g_old_rec.contr_type;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    pay_con_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.legislation_code = hr_api.g_varchar2) then
    p_rec.legislation_code :=
    pay_con_shd.g_old_rec.legislation_code;
  End If;
  If (p_rec.amt_contr = hr_api.g_number) then
    p_rec.amt_contr :=
    pay_con_shd.g_old_rec.amt_contr;
  End If;
  If (p_rec.max_contr_allowed = hr_api.g_number) then
    p_rec.max_contr_allowed :=
    pay_con_shd.g_old_rec.max_contr_allowed;
  End If;
  If (p_rec.includable_comp = hr_api.g_number) then
    p_rec.includable_comp :=
    pay_con_shd.g_old_rec.includable_comp;
  End If;
  If (p_rec.tax_unit_id = hr_api.g_number) then
    p_rec.tax_unit_id :=
    pay_con_shd.g_old_rec.tax_unit_id;
  End If;
  If (p_rec.source_system = hr_api.g_varchar2) then
    p_rec.source_system :=
    pay_con_shd.g_old_rec.source_system;
  End If;
  If (p_rec.contr_information_category = hr_api.g_varchar2) then
    p_rec.contr_information_category :=
    pay_con_shd.g_old_rec.contr_information_category;
  End If;
  If (p_rec.contr_information1 = hr_api.g_varchar2) then
    p_rec.contr_information1 :=
    pay_con_shd.g_old_rec.contr_information1;
  End If;
  If (p_rec.contr_information2 = hr_api.g_varchar2) then
    p_rec.contr_information2 :=
    pay_con_shd.g_old_rec.contr_information2;
  End If;
  If (p_rec.contr_information3 = hr_api.g_varchar2) then
    p_rec.contr_information3 :=
    pay_con_shd.g_old_rec.contr_information3;
  End If;
  If (p_rec.contr_information4 = hr_api.g_varchar2) then
    p_rec.contr_information4 :=
    pay_con_shd.g_old_rec.contr_information4;
  End If;
  If (p_rec.contr_information5 = hr_api.g_varchar2) then
    p_rec.contr_information5 :=
    pay_con_shd.g_old_rec.contr_information5;
  End If;
  If (p_rec.contr_information6 = hr_api.g_varchar2) then
    p_rec.contr_information6 :=
    pay_con_shd.g_old_rec.contr_information6;
  End If;
  If (p_rec.contr_information7 = hr_api.g_varchar2) then
    p_rec.contr_information7 :=
    pay_con_shd.g_old_rec.contr_information7;
  End If;
  If (p_rec.contr_information8 = hr_api.g_varchar2) then
    p_rec.contr_information8 :=
    pay_con_shd.g_old_rec.contr_information8;
  End If;
  If (p_rec.contr_information9 = hr_api.g_varchar2) then
    p_rec.contr_information9 :=
    pay_con_shd.g_old_rec.contr_information9;
  End If;
  If (p_rec.contr_information10 = hr_api.g_varchar2) then
    p_rec.contr_information10 :=
    pay_con_shd.g_old_rec.contr_information10;
  End If;
  If (p_rec.contr_information11 = hr_api.g_varchar2) then
    p_rec.contr_information11 :=
    pay_con_shd.g_old_rec.contr_information11;
  End If;
  If (p_rec.contr_information12 = hr_api.g_varchar2) then
    p_rec.contr_information12 :=
    pay_con_shd.g_old_rec.contr_information12;
  End If;
  If (p_rec.contr_information13 = hr_api.g_varchar2) then
    p_rec.contr_information13 :=
    pay_con_shd.g_old_rec.contr_information13;
  End If;
  If (p_rec.contr_information14 = hr_api.g_varchar2) then
    p_rec.contr_information14 :=
    pay_con_shd.g_old_rec.contr_information14;
  End If;
  If (p_rec.contr_information15 = hr_api.g_varchar2) then
    p_rec.contr_information15 :=
    pay_con_shd.g_old_rec.contr_information15;
  End If;
  If (p_rec.contr_information16 = hr_api.g_varchar2) then
    p_rec.contr_information16 :=
    pay_con_shd.g_old_rec.contr_information16;
  End If;
  If (p_rec.contr_information17 = hr_api.g_varchar2) then
    p_rec.contr_information17 :=
    pay_con_shd.g_old_rec.contr_information17;
  End If;
  If (p_rec.contr_information18 = hr_api.g_varchar2) then
    p_rec.contr_information18 :=
    pay_con_shd.g_old_rec.contr_information18;
  End If;
  If (p_rec.contr_information19 = hr_api.g_varchar2) then
    p_rec.contr_information19 :=
    pay_con_shd.g_old_rec.contr_information19;
  End If;
  If (p_rec.contr_information20 = hr_api.g_varchar2) then
    p_rec.contr_information20 :=
    pay_con_shd.g_old_rec.contr_information20;
  End If;
  If (p_rec.contr_information21 = hr_api.g_varchar2) then
    p_rec.contr_information21 :=
    pay_con_shd.g_old_rec.contr_information21;
  End If;
  If (p_rec.contr_information22 = hr_api.g_varchar2) then
    p_rec.contr_information22 :=
    pay_con_shd.g_old_rec.contr_information22;
  End If;
  If (p_rec.contr_information23 = hr_api.g_varchar2) then
    p_rec.contr_information23 :=
    pay_con_shd.g_old_rec.contr_information23;
  End If;
  If (p_rec.contr_information24 = hr_api.g_varchar2) then
    p_rec.contr_information24 :=
    pay_con_shd.g_old_rec.contr_information24;
  End If;
  If (p_rec.contr_information25 = hr_api.g_varchar2) then
    p_rec.contr_information25 :=
    pay_con_shd.g_old_rec.contr_information25;
  End If;
  If (p_rec.contr_information26 = hr_api.g_varchar2) then
    p_rec.contr_information26 :=
    pay_con_shd.g_old_rec.contr_information26;
  End If;
  If (p_rec.contr_information27 = hr_api.g_varchar2) then
    p_rec.contr_information27 :=
    pay_con_shd.g_old_rec.contr_information27;
  End If;
  If (p_rec.contr_information28 = hr_api.g_varchar2) then
    p_rec.contr_information28 :=
    pay_con_shd.g_old_rec.contr_information28;
  End If;
  If (p_rec.contr_information29 = hr_api.g_varchar2) then
    p_rec.contr_information29 :=
    pay_con_shd.g_old_rec.contr_information29;
  End If;
  If (p_rec.contr_information30 = hr_api.g_varchar2) then
    p_rec.contr_information30 :=
    pay_con_shd.g_old_rec.contr_information30;
  End If;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_rec        in out pay_con_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pay_con_shd.lck
	(
	p_rec.contr_history_id,
	p_rec.object_version_number
	);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  pay_con_bus.update_validate(p_rec);
  --
  -- Call the supporting pre-update operation
  --
  pre_update(p_rec);
  --
  -- Update the row.
  --
  update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  post_update(p_rec);
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_contr_history_id             in number,
  p_person_id                    in number           default hr_api.g_number,
  p_date_from                    in date             default hr_api.g_date,
  p_date_to                      in date             default hr_api.g_date,
  p_contr_type                   in varchar2         default hr_api.g_varchar2,
  p_business_group_id            in number           default hr_api.g_number,
  p_legislation_code             in varchar2         default hr_api.g_varchar2,
  p_amt_contr                    in number           default hr_api.g_number,
  p_max_contr_allowed            in number           default hr_api.g_number,
  p_includable_comp              in number           default hr_api.g_number,
  p_tax_unit_id                  in number           default hr_api.g_number,
  p_source_system                in varchar2         default hr_api.g_varchar2,
  p_contr_information_category   in varchar2         default hr_api.g_varchar2,
  p_contr_information1           in varchar2         default hr_api.g_varchar2,
  p_contr_information2           in varchar2         default hr_api.g_varchar2,
  p_contr_information3           in varchar2         default hr_api.g_varchar2,
  p_contr_information4           in varchar2         default hr_api.g_varchar2,
  p_contr_information5           in varchar2         default hr_api.g_varchar2,
  p_contr_information6           in varchar2         default hr_api.g_varchar2,
  p_contr_information7           in varchar2         default hr_api.g_varchar2,
  p_contr_information8           in varchar2         default hr_api.g_varchar2,
  p_contr_information9           in varchar2         default hr_api.g_varchar2,
  p_contr_information10          in varchar2         default hr_api.g_varchar2,
  p_contr_information11          in varchar2         default hr_api.g_varchar2,
  p_contr_information12          in varchar2         default hr_api.g_varchar2,
  p_contr_information13          in varchar2         default hr_api.g_varchar2,
  p_contr_information14          in varchar2         default hr_api.g_varchar2,
  p_contr_information15          in varchar2         default hr_api.g_varchar2,
  p_contr_information16          in varchar2         default hr_api.g_varchar2,
  p_contr_information17          in varchar2         default hr_api.g_varchar2,
  p_contr_information18          in varchar2         default hr_api.g_varchar2,
  p_contr_information19          in varchar2         default hr_api.g_varchar2,
  p_contr_information20          in varchar2         default hr_api.g_varchar2,
  p_contr_information21          in varchar2         default hr_api.g_varchar2,
  p_contr_information22          in varchar2         default hr_api.g_varchar2,
  p_contr_information23          in varchar2         default hr_api.g_varchar2,
  p_contr_information24          in varchar2         default hr_api.g_varchar2,
  p_contr_information25          in varchar2         default hr_api.g_varchar2,
  p_contr_information26          in varchar2         default hr_api.g_varchar2,
  p_contr_information27          in varchar2         default hr_api.g_varchar2,
  p_contr_information28          in varchar2         default hr_api.g_varchar2,
  p_contr_information29          in varchar2         default hr_api.g_varchar2,
  p_contr_information30          in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out number
  ) is
--
  l_rec	  pay_con_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pay_con_shd.convert_args
  (
  p_contr_history_id,
  p_person_id,
  p_date_from,
  p_date_to,
  p_contr_type,
  p_business_group_id,
  p_legislation_code,
  p_amt_contr,
  p_max_contr_allowed,
  p_includable_comp,
  p_tax_unit_id,
  p_source_system,
  p_contr_information_category,
  p_contr_information1,
  p_contr_information2,
  p_contr_information3,
  p_contr_information4,
  p_contr_information5,
  p_contr_information6,
  p_contr_information7,
  p_contr_information8,
  p_contr_information9,
  p_contr_information10,
  p_contr_information11,
  p_contr_information12,
  p_contr_information13,
  p_contr_information14,
  p_contr_information15,
  p_contr_information16,
  p_contr_information17,
  p_contr_information18,
  p_contr_information19,
  p_contr_information20,
  p_contr_information21,
  p_contr_information22,
  p_contr_information23,
  p_contr_information24,
  p_contr_information25,
  p_contr_information26,
  p_contr_information27,
  p_contr_information28,
  p_contr_information29,
  p_contr_information30,
  p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec);
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pay_con_upd;

/
