--------------------------------------------------------
--  DDL for Package Body PSP_ERA_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_ERA_UPD" as
/* $Header: PSPEARHB.pls 120.2 2006/03/26 01:08 dpaudel noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  psp_era_upd.';  -- Global package name
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
  (p_rec in out nocopy psp_era_shd.g_rec_type
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
  --
  --
  -- Update the psp_eff_report_approvals Row
  --
  update psp_eff_report_approvals
    set
     effort_report_approval_id       = p_rec.effort_report_approval_id
    ,effort_report_detail_id         = p_rec.effort_report_detail_id
    ,wf_role_name                    = p_rec.wf_role_name
    ,wf_orig_system_id               = p_rec.wf_orig_system_id
    ,wf_orig_system                  = p_rec.wf_orig_system
    ,approver_order_num              = p_rec.approver_order_num
    ,approval_status                 = p_rec.approval_status
    ,response_date                   = p_rec.response_date
    ,actual_cost_share               = p_rec.actual_cost_share
    ,overwritten_effort_percent      = p_rec.overwritten_effort_percent
    ,wf_item_key                     = p_rec.wf_item_key
    ,comments                        = p_rec.comments
    ,pera_information_category       = p_rec.pera_information_category
    ,pera_information1               = p_rec.pera_information1
    ,pera_information2               = p_rec.pera_information2
    ,pera_information3               = p_rec.pera_information3
    ,pera_information4               = p_rec.pera_information4
    ,pera_information5               = p_rec.pera_information5
    ,pera_information6               = p_rec.pera_information6
    ,pera_information7               = p_rec.pera_information7
    ,pera_information8               = p_rec.pera_information8
    ,pera_information9               = p_rec.pera_information9
    ,pera_information10              = p_rec.pera_information10
    ,pera_information11              = p_rec.pera_information11
    ,pera_information12              = p_rec.pera_information12
    ,pera_information13              = p_rec.pera_information13
    ,pera_information14              = p_rec.pera_information14
    ,pera_information15              = p_rec.pera_information15
    ,pera_information16              = p_rec.pera_information16
    ,pera_information17              = p_rec.pera_information17
    ,pera_information18              = p_rec.pera_information18
    ,pera_information19              = p_rec.pera_information19
    ,pera_information20              = p_rec.pera_information20
    ,wf_role_display_name            = p_rec.wf_role_display_name
    ,object_version_number           = p_rec.object_version_number
    ,notification_id                 = p_rec.notification_id
    ,eff_information_category        = p_rec.eff_information_category
    ,eff_information1                = p_rec.eff_information1
    ,eff_information2                = p_rec.eff_information2
    ,eff_information3                = p_rec.eff_information3
    ,eff_information4                = p_rec.eff_information4
    ,eff_information5                = p_rec.eff_information5
    ,eff_information6                = p_rec.eff_information6
    ,eff_information7                = p_rec.eff_information7
    ,eff_information8                = p_rec.eff_information8
    ,eff_information9                = p_rec.eff_information9
    ,eff_information10               = p_rec.eff_information10
    ,eff_information11               = p_rec.eff_information11
    ,eff_information12               = p_rec.eff_information12
    ,eff_information13               = p_rec.eff_information13
    ,eff_information14               = p_rec.eff_information14
    ,eff_information15               = p_rec.eff_information15
    where effort_report_approval_id = p_rec.effort_report_approval_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    psp_era_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    psp_era_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    psp_era_shd.constraint_error
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
  (p_rec in psp_era_shd.g_rec_type
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
  (p_rec                          in psp_era_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    psp_era_rku.after_update
      (p_effort_report_approval_id
      => p_rec.effort_report_approval_id
      ,p_effort_report_detail_id
      => p_rec.effort_report_detail_id
      ,p_wf_role_name
      => p_rec.wf_role_name
      ,p_wf_orig_system_id
      => p_rec.wf_orig_system_id
      ,p_wf_orig_system
      => p_rec.wf_orig_system
      ,p_approver_order_num
      => p_rec.approver_order_num
      ,p_approval_status
      => p_rec.approval_status
      ,p_response_date
      => p_rec.response_date
      ,p_actual_cost_share
      => p_rec.actual_cost_share
      ,p_overwritten_effort_percent
      => p_rec.overwritten_effort_percent
      ,p_wf_item_key
      => p_rec.wf_item_key
      ,p_comments
      => p_rec.comments
      ,p_pera_information_category
      => p_rec.pera_information_category
      ,p_pera_information1
      => p_rec.pera_information1
      ,p_pera_information2
      => p_rec.pera_information2
      ,p_pera_information3
      => p_rec.pera_information3
      ,p_pera_information4
      => p_rec.pera_information4
      ,p_pera_information5
      => p_rec.pera_information5
      ,p_pera_information6
      => p_rec.pera_information6
      ,p_pera_information7
      => p_rec.pera_information7
      ,p_pera_information8
      => p_rec.pera_information8
      ,p_pera_information9
      => p_rec.pera_information9
      ,p_pera_information10
      => p_rec.pera_information10
      ,p_pera_information11
      => p_rec.pera_information11
      ,p_pera_information12
      => p_rec.pera_information12
      ,p_pera_information13
      => p_rec.pera_information13
      ,p_pera_information14
      => p_rec.pera_information14
      ,p_pera_information15
      => p_rec.pera_information15
      ,p_pera_information16
      => p_rec.pera_information16
      ,p_pera_information17
      => p_rec.pera_information17
      ,p_pera_information18
      => p_rec.pera_information18
      ,p_pera_information19
      => p_rec.pera_information19
      ,p_pera_information20
      => p_rec.pera_information20
      ,p_wf_role_display_name
      => p_rec.wf_role_display_name
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_notification_id
      => p_rec.notification_id
      ,p_eff_information_category
      => p_rec.eff_information_category
      ,p_eff_information1
      => p_rec.eff_information1
      ,p_eff_information2
      => p_rec.eff_information2
      ,p_eff_information3
      => p_rec.eff_information3
      ,p_eff_information4
      => p_rec.eff_information4
      ,p_eff_information5
      => p_rec.eff_information5
      ,p_eff_information6
      => p_rec.eff_information6
      ,p_eff_information7
      => p_rec.eff_information7
      ,p_eff_information8
      => p_rec.eff_information8
      ,p_eff_information9
      => p_rec.eff_information9
      ,p_eff_information10
      => p_rec.eff_information10
      ,p_eff_information11
      => p_rec.eff_information11
      ,p_eff_information12
      => p_rec.eff_information12
      ,p_eff_information13
      => p_rec.eff_information13
      ,p_eff_information14
      => p_rec.eff_information14
      ,p_eff_information15
      => p_rec.eff_information15
      ,p_effort_report_detail_id_o
      => psp_era_shd.g_old_rec.effort_report_detail_id
      ,p_wf_role_name_o
      => psp_era_shd.g_old_rec.wf_role_name
      ,p_wf_orig_system_id_o
      => psp_era_shd.g_old_rec.wf_orig_system_id
      ,p_wf_orig_system_o
      => psp_era_shd.g_old_rec.wf_orig_system
      ,p_approver_order_num_o
      => psp_era_shd.g_old_rec.approver_order_num
      ,p_approval_status_o
      => psp_era_shd.g_old_rec.approval_status
      ,p_response_date_o
      => psp_era_shd.g_old_rec.response_date
      ,p_actual_cost_share_o
      => psp_era_shd.g_old_rec.actual_cost_share
      ,p_overwritten_effort_percent_o
      => psp_era_shd.g_old_rec.overwritten_effort_percent
      ,p_wf_item_key_o
      => psp_era_shd.g_old_rec.wf_item_key
      ,p_comments_o
      => psp_era_shd.g_old_rec.comments
      ,p_pera_information_category_o
      => psp_era_shd.g_old_rec.pera_information_category
      ,p_pera_information1_o
      => psp_era_shd.g_old_rec.pera_information1
      ,p_pera_information2_o
      => psp_era_shd.g_old_rec.pera_information2
      ,p_pera_information3_o
      => psp_era_shd.g_old_rec.pera_information3
      ,p_pera_information4_o
      => psp_era_shd.g_old_rec.pera_information4
      ,p_pera_information5_o
      => psp_era_shd.g_old_rec.pera_information5
      ,p_pera_information6_o
      => psp_era_shd.g_old_rec.pera_information6
      ,p_pera_information7_o
      => psp_era_shd.g_old_rec.pera_information7
      ,p_pera_information8_o
      => psp_era_shd.g_old_rec.pera_information8
      ,p_pera_information9_o
      => psp_era_shd.g_old_rec.pera_information9
      ,p_pera_information10_o
      => psp_era_shd.g_old_rec.pera_information10
      ,p_pera_information11_o
      => psp_era_shd.g_old_rec.pera_information11
      ,p_pera_information12_o
      => psp_era_shd.g_old_rec.pera_information12
      ,p_pera_information13_o
      => psp_era_shd.g_old_rec.pera_information13
      ,p_pera_information14_o
      => psp_era_shd.g_old_rec.pera_information14
      ,p_pera_information15_o
      => psp_era_shd.g_old_rec.pera_information15
      ,p_pera_information16_o
      => psp_era_shd.g_old_rec.pera_information16
      ,p_pera_information17_o
      => psp_era_shd.g_old_rec.pera_information17
      ,p_pera_information18_o
      => psp_era_shd.g_old_rec.pera_information18
      ,p_pera_information19_o
      => psp_era_shd.g_old_rec.pera_information19
      ,p_pera_information20_o
      => psp_era_shd.g_old_rec.pera_information20
      ,p_wf_role_display_name_o
      => psp_era_shd.g_old_rec.wf_role_display_name
      ,p_object_version_number_o
      => psp_era_shd.g_old_rec.object_version_number
      ,p_notification_id_o
      => psp_era_shd.g_old_rec.notification_id
      ,p_eff_information_category_o
      => psp_era_shd.g_old_rec.eff_information_category
      ,p_eff_information1_o
      => psp_era_shd.g_old_rec.eff_information1
      ,p_eff_information2_o
      => psp_era_shd.g_old_rec.eff_information2
      ,p_eff_information3_o
      => psp_era_shd.g_old_rec.eff_information3
      ,p_eff_information4_o
      => psp_era_shd.g_old_rec.eff_information4
      ,p_eff_information5_o
      => psp_era_shd.g_old_rec.eff_information5
      ,p_eff_information6_o
      => psp_era_shd.g_old_rec.eff_information6
      ,p_eff_information7_o
      => psp_era_shd.g_old_rec.eff_information7
      ,p_eff_information8_o
      => psp_era_shd.g_old_rec.eff_information8
      ,p_eff_information9_o
      => psp_era_shd.g_old_rec.eff_information9
      ,p_eff_information10_o
      => psp_era_shd.g_old_rec.eff_information10
      ,p_eff_information11_o
      => psp_era_shd.g_old_rec.eff_information11
      ,p_eff_information12_o
      => psp_era_shd.g_old_rec.eff_information12
      ,p_eff_information13_o
      => psp_era_shd.g_old_rec.eff_information13
      ,p_eff_information14_o
      => psp_era_shd.g_old_rec.eff_information14
      ,p_eff_information15_o
      => psp_era_shd.g_old_rec.eff_information15
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PSP_EFF_REPORT_APPROVALS'
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
  (p_rec in out nocopy psp_era_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.effort_report_detail_id = hr_api.g_number) then
    p_rec.effort_report_detail_id :=
    psp_era_shd.g_old_rec.effort_report_detail_id;
  End If;
  If (p_rec.wf_role_name = hr_api.g_varchar2) then
    p_rec.wf_role_name :=
    psp_era_shd.g_old_rec.wf_role_name;
  End If;
  If (p_rec.wf_orig_system_id = hr_api.g_number) then
    p_rec.wf_orig_system_id :=
    psp_era_shd.g_old_rec.wf_orig_system_id;
  End If;
  If (p_rec.wf_orig_system = hr_api.g_varchar2) then
    p_rec.wf_orig_system :=
    psp_era_shd.g_old_rec.wf_orig_system;
  End If;
  If (p_rec.approver_order_num = hr_api.g_number) then
    p_rec.approver_order_num :=
    psp_era_shd.g_old_rec.approver_order_num;
  End If;
  If (p_rec.approval_status = hr_api.g_varchar2) then
    p_rec.approval_status :=
    psp_era_shd.g_old_rec.approval_status;
  End If;
  If (p_rec.response_date = hr_api.g_date) then
    p_rec.response_date :=
    psp_era_shd.g_old_rec.response_date;
  End If;
  If (p_rec.actual_cost_share = hr_api.g_number) then
    p_rec.actual_cost_share :=
    psp_era_shd.g_old_rec.actual_cost_share;
  End If;
  If (p_rec.overwritten_effort_percent = hr_api.g_number) then
    p_rec.overwritten_effort_percent :=
    psp_era_shd.g_old_rec.overwritten_effort_percent;
  End If;
  If (p_rec.wf_item_key = hr_api.g_varchar2) then
    p_rec.wf_item_key :=
    psp_era_shd.g_old_rec.wf_item_key;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments :=
    psp_era_shd.g_old_rec.comments;
  End If;
  If (p_rec.pera_information_category = hr_api.g_varchar2) then
    p_rec.pera_information_category :=
    psp_era_shd.g_old_rec.pera_information_category;
  End If;
  If (p_rec.pera_information1 = hr_api.g_varchar2) then
    p_rec.pera_information1 :=
    psp_era_shd.g_old_rec.pera_information1;
  End If;
  If (p_rec.pera_information2 = hr_api.g_varchar2) then
    p_rec.pera_information2 :=
    psp_era_shd.g_old_rec.pera_information2;
  End If;
  If (p_rec.pera_information3 = hr_api.g_varchar2) then
    p_rec.pera_information3 :=
    psp_era_shd.g_old_rec.pera_information3;
  End If;
  If (p_rec.pera_information4 = hr_api.g_varchar2) then
    p_rec.pera_information4 :=
    psp_era_shd.g_old_rec.pera_information4;
  End If;
  If (p_rec.pera_information5 = hr_api.g_varchar2) then
    p_rec.pera_information5 :=
    psp_era_shd.g_old_rec.pera_information5;
  End If;
  If (p_rec.pera_information6 = hr_api.g_varchar2) then
    p_rec.pera_information6 :=
    psp_era_shd.g_old_rec.pera_information6;
  End If;
  If (p_rec.pera_information7 = hr_api.g_varchar2) then
    p_rec.pera_information7 :=
    psp_era_shd.g_old_rec.pera_information7;
  End If;
  If (p_rec.pera_information8 = hr_api.g_varchar2) then
    p_rec.pera_information8 :=
    psp_era_shd.g_old_rec.pera_information8;
  End If;
  If (p_rec.pera_information9 = hr_api.g_varchar2) then
    p_rec.pera_information9 :=
    psp_era_shd.g_old_rec.pera_information9;
  End If;
  If (p_rec.pera_information10 = hr_api.g_varchar2) then
    p_rec.pera_information10 :=
    psp_era_shd.g_old_rec.pera_information10;
  End If;
  If (p_rec.pera_information11 = hr_api.g_varchar2) then
    p_rec.pera_information11 :=
    psp_era_shd.g_old_rec.pera_information11;
  End If;
  If (p_rec.pera_information12 = hr_api.g_varchar2) then
    p_rec.pera_information12 :=
    psp_era_shd.g_old_rec.pera_information12;
  End If;
  If (p_rec.pera_information13 = hr_api.g_varchar2) then
    p_rec.pera_information13 :=
    psp_era_shd.g_old_rec.pera_information13;
  End If;
  If (p_rec.pera_information14 = hr_api.g_varchar2) then
    p_rec.pera_information14 :=
    psp_era_shd.g_old_rec.pera_information14;
  End If;
  If (p_rec.pera_information15 = hr_api.g_varchar2) then
    p_rec.pera_information15 :=
    psp_era_shd.g_old_rec.pera_information15;
  End If;
  If (p_rec.pera_information16 = hr_api.g_varchar2) then
    p_rec.pera_information16 :=
    psp_era_shd.g_old_rec.pera_information16;
  End If;
  If (p_rec.pera_information17 = hr_api.g_varchar2) then
    p_rec.pera_information17 :=
    psp_era_shd.g_old_rec.pera_information17;
  End If;
  If (p_rec.pera_information18 = hr_api.g_varchar2) then
    p_rec.pera_information18 :=
    psp_era_shd.g_old_rec.pera_information18;
  End If;
  If (p_rec.pera_information19 = hr_api.g_varchar2) then
    p_rec.pera_information19 :=
    psp_era_shd.g_old_rec.pera_information19;
  End If;
  If (p_rec.pera_information20 = hr_api.g_varchar2) then
    p_rec.pera_information20 :=
    psp_era_shd.g_old_rec.pera_information20;
  End If;
  If (p_rec.wf_role_display_name = hr_api.g_varchar2) then
    p_rec.wf_role_display_name :=
    psp_era_shd.g_old_rec.wf_role_display_name;
  End If;
  If (p_rec.notification_id = hr_api.g_number) then
    p_rec.notification_id :=
    psp_era_shd.g_old_rec.notification_id;
  End If;
  If (p_rec.eff_information_category = hr_api.g_varchar2) then
    p_rec.eff_information_category :=
    psp_era_shd.g_old_rec.eff_information_category;
  End If;
  If (p_rec.eff_information1 = hr_api.g_varchar2) then
    p_rec.eff_information1 :=
    psp_era_shd.g_old_rec.eff_information1;
  End If;
  If (p_rec.eff_information2 = hr_api.g_varchar2) then
    p_rec.eff_information2 :=
    psp_era_shd.g_old_rec.eff_information2;
  End If;
  If (p_rec.eff_information3 = hr_api.g_varchar2) then
    p_rec.eff_information3 :=
    psp_era_shd.g_old_rec.eff_information3;
  End If;
  If (p_rec.eff_information4 = hr_api.g_varchar2) then
    p_rec.eff_information4 :=
    psp_era_shd.g_old_rec.eff_information4;
  End If;
  If (p_rec.eff_information5 = hr_api.g_varchar2) then
    p_rec.eff_information5 :=
    psp_era_shd.g_old_rec.eff_information5;
  End If;
  If (p_rec.eff_information6 = hr_api.g_varchar2) then
    p_rec.eff_information6 :=
    psp_era_shd.g_old_rec.eff_information6;
  End If;
  If (p_rec.eff_information7 = hr_api.g_varchar2) then
    p_rec.eff_information7 :=
    psp_era_shd.g_old_rec.eff_information7;
  End If;
  If (p_rec.eff_information8 = hr_api.g_varchar2) then
    p_rec.eff_information8 :=
    psp_era_shd.g_old_rec.eff_information8;
  End If;
  If (p_rec.eff_information9 = hr_api.g_varchar2) then
    p_rec.eff_information9 :=
    psp_era_shd.g_old_rec.eff_information9;
  End If;
  If (p_rec.eff_information10 = hr_api.g_varchar2) then
    p_rec.eff_information10 :=
    psp_era_shd.g_old_rec.eff_information10;
  End If;
  If (p_rec.eff_information11 = hr_api.g_varchar2) then
    p_rec.eff_information11 :=
    psp_era_shd.g_old_rec.eff_information11;
  End If;
  If (p_rec.eff_information12 = hr_api.g_varchar2) then
    p_rec.eff_information12 :=
    psp_era_shd.g_old_rec.eff_information12;
  End If;
  If (p_rec.eff_information13 = hr_api.g_varchar2) then
    p_rec.eff_information13 :=
    psp_era_shd.g_old_rec.eff_information13;
  End If;
  If (p_rec.eff_information14 = hr_api.g_varchar2) then
    p_rec.eff_information14 :=
    psp_era_shd.g_old_rec.eff_information14;
  End If;
  If (p_rec.eff_information15 = hr_api.g_varchar2) then
    p_rec.eff_information15 :=
    psp_era_shd.g_old_rec.eff_information15;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy psp_era_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  psp_era_shd.lck
    (p_rec.effort_report_approval_id
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
  psp_era_bus.update_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  psp_era_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  psp_era_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  psp_era_upd.post_update
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
  (p_effort_report_approval_id    in     number
  ,p_object_version_number        in out nocopy number
  ,p_effort_report_detail_id      in     number    default hr_api.g_number
  ,p_wf_role_name                 in     varchar2  default hr_api.g_varchar2
  ,p_wf_orig_system_id            in     number    default hr_api.g_number
  ,p_wf_orig_system               in     varchar2  default hr_api.g_varchar2
  ,p_approver_order_num           in     number    default hr_api.g_number
  ,p_approval_status              in     varchar2  default hr_api.g_varchar2
  ,p_response_date                in     date      default hr_api.g_date
  ,p_actual_cost_share            in     number    default hr_api.g_number
  ,p_overwritten_effort_percent   in     number    default hr_api.g_number
  ,p_wf_item_key                  in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_pera_information_category    in     varchar2  default hr_api.g_varchar2
  ,p_pera_information1            in     varchar2  default hr_api.g_varchar2
  ,p_pera_information2            in     varchar2  default hr_api.g_varchar2
  ,p_pera_information3            in     varchar2  default hr_api.g_varchar2
  ,p_pera_information4            in     varchar2  default hr_api.g_varchar2
  ,p_pera_information5            in     varchar2  default hr_api.g_varchar2
  ,p_pera_information6            in     varchar2  default hr_api.g_varchar2
  ,p_pera_information7            in     varchar2  default hr_api.g_varchar2
  ,p_pera_information8            in     varchar2  default hr_api.g_varchar2
  ,p_pera_information9            in     varchar2  default hr_api.g_varchar2
  ,p_pera_information10           in     varchar2  default hr_api.g_varchar2
  ,p_pera_information11           in     varchar2  default hr_api.g_varchar2
  ,p_pera_information12           in     varchar2  default hr_api.g_varchar2
  ,p_pera_information13           in     varchar2  default hr_api.g_varchar2
  ,p_pera_information14           in     varchar2  default hr_api.g_varchar2
  ,p_pera_information15           in     varchar2  default hr_api.g_varchar2
  ,p_pera_information16           in     varchar2  default hr_api.g_varchar2
  ,p_pera_information17           in     varchar2  default hr_api.g_varchar2
  ,p_pera_information18           in     varchar2  default hr_api.g_varchar2
  ,p_pera_information19           in     varchar2  default hr_api.g_varchar2
  ,p_pera_information20           in     varchar2  default hr_api.g_varchar2
  ,p_wf_role_display_name         in     varchar2  default hr_api.g_varchar2
  ,p_notification_id              in     number    default hr_api.g_number
  ,p_eff_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_eff_information1             in     varchar2  default hr_api.g_varchar2
  ,p_eff_information2             in     varchar2  default hr_api.g_varchar2
  ,p_eff_information3             in     varchar2  default hr_api.g_varchar2
  ,p_eff_information4             in     varchar2  default hr_api.g_varchar2
  ,p_eff_information5             in     varchar2  default hr_api.g_varchar2
  ,p_eff_information6             in     varchar2  default hr_api.g_varchar2
  ,p_eff_information7             in     varchar2  default hr_api.g_varchar2
  ,p_eff_information8             in     varchar2  default hr_api.g_varchar2
  ,p_eff_information9             in     varchar2  default hr_api.g_varchar2
  ,p_eff_information10            in     varchar2  default hr_api.g_varchar2
  ,p_eff_information11            in     varchar2  default hr_api.g_varchar2
  ,p_eff_information12            in     varchar2  default hr_api.g_varchar2
  ,p_eff_information13            in     varchar2  default hr_api.g_varchar2
  ,p_eff_information14            in     varchar2  default hr_api.g_varchar2
  ,p_eff_information15            in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec   psp_era_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  psp_era_shd.convert_args
  (p_effort_report_approval_id
  ,p_effort_report_detail_id
  ,p_wf_role_name
  ,p_wf_orig_system_id
  ,p_wf_orig_system
  ,p_approver_order_num
  ,p_approval_status
  ,p_response_date
  ,p_actual_cost_share
  ,p_overwritten_effort_percent
  ,p_wf_item_key
  ,p_comments
  ,p_pera_information_category
  ,p_pera_information1
  ,p_pera_information2
  ,p_pera_information3
  ,p_pera_information4
  ,p_pera_information5
  ,p_pera_information6
  ,p_pera_information7
  ,p_pera_information8
  ,p_pera_information9
  ,p_pera_information10
  ,p_pera_information11
  ,p_pera_information12
  ,p_pera_information13
  ,p_pera_information14
  ,p_pera_information15
  ,p_pera_information16
  ,p_pera_information17
  ,p_pera_information18
  ,p_pera_information19
  ,p_pera_information20
  ,p_wf_role_display_name
  ,p_object_version_number
  ,p_notification_id
  ,p_eff_information_category
  ,p_eff_information1
  ,p_eff_information2
  ,p_eff_information3
  ,p_eff_information4
  ,p_eff_information5
  ,p_eff_information6
  ,p_eff_information7
  ,p_eff_information8
  ,p_eff_information9
  ,p_eff_information10
  ,p_eff_information11
  ,p_eff_information12
  ,p_eff_information13
  ,p_eff_information14
  ,p_eff_information15
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  psp_era_upd.upd
     (l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end psp_era_upd;

/
