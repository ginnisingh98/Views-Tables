--------------------------------------------------------
--  DDL for Package Body BEN_CSO_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CSO_UPD" as
/* $Header: becsorhi.pkb 115.0 2003/03/17 13:37:07 csundar noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_cso_upd.';  -- Global package name
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
  (p_rec in out nocopy ben_cso_shd.g_rec_type
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
  -- Update the ben_cwb_stock_optn_dtls Row
  --
  update ben_cwb_stock_optn_dtls
    set
     cwb_stock_optn_dtls_id          = p_rec.cwb_stock_optn_dtls_id
    ,grant_id                        = p_rec.grant_id
    ,grant_number                    = p_rec.grant_number
    ,grant_name                      = p_rec.grant_name
    ,grant_type                      = p_rec.grant_type
    ,grant_date                      = p_rec.grant_date
    ,grant_shares                    = p_rec.grant_shares
    ,grant_price                     = p_rec.grant_price
    ,value_at_grant                  = p_rec.value_at_grant
    ,current_share_price             = p_rec.current_share_price
    ,current_shares_outstanding      = p_rec.current_shares_outstanding
    ,vested_shares                   = p_rec.vested_shares
    ,unvested_shares                 = p_rec.unvested_shares
    ,exercisable_shares              = p_rec.exercisable_shares
    ,exercised_shares                = p_rec.exercised_shares
    ,cancelled_shares                = p_rec.cancelled_shares
    ,trading_symbol                  = p_rec.trading_symbol
    ,expiration_date                 = p_rec.expiration_date
    ,reason_code                     = p_rec.reason_code
    ,class                           = p_rec.class
    ,misc                            = p_rec.misc
    ,employee_number                 = p_rec.employee_number
    ,person_id                       = p_rec.person_id
    ,business_group_id               = p_rec.business_group_id
    ,prtt_rt_val_id                  = p_rec.prtt_rt_val_id
    ,object_version_number           = p_rec.object_version_number
    ,cso_attribute_category          = p_rec.cso_attribute_category
    ,cso_attribute1                  = p_rec.cso_attribute1
    ,cso_attribute2                  = p_rec.cso_attribute2
    ,cso_attribute3                  = p_rec.cso_attribute3
    ,cso_attribute4                  = p_rec.cso_attribute4
    ,cso_attribute5                  = p_rec.cso_attribute5
    ,cso_attribute6                  = p_rec.cso_attribute6
    ,cso_attribute7                  = p_rec.cso_attribute7
    ,cso_attribute8                  = p_rec.cso_attribute8
    ,cso_attribute9                  = p_rec.cso_attribute9
    ,cso_attribute10                 = p_rec.cso_attribute10
    ,cso_attribute11                 = p_rec.cso_attribute11
    ,cso_attribute12                 = p_rec.cso_attribute12
    ,cso_attribute13                 = p_rec.cso_attribute13
    ,cso_attribute14                 = p_rec.cso_attribute14
    ,cso_attribute15                 = p_rec.cso_attribute15
    ,cso_attribute16                 = p_rec.cso_attribute16
    ,cso_attribute17                 = p_rec.cso_attribute17
    ,cso_attribute18                 = p_rec.cso_attribute18
    ,cso_attribute19                 = p_rec.cso_attribute19
    ,cso_attribute20                 = p_rec.cso_attribute20
    ,cso_attribute21                 = p_rec.cso_attribute21
    ,cso_attribute22                 = p_rec.cso_attribute22
    ,cso_attribute23                 = p_rec.cso_attribute23
    ,cso_attribute24                 = p_rec.cso_attribute24
    ,cso_attribute25                 = p_rec.cso_attribute25
    ,cso_attribute26                 = p_rec.cso_attribute26
    ,cso_attribute27                 = p_rec.cso_attribute27
    ,cso_attribute28                 = p_rec.cso_attribute28
    ,cso_attribute29                 = p_rec.cso_attribute29
    ,cso_attribute30                 = p_rec.cso_attribute30
    where cwb_stock_optn_dtls_id = p_rec.cwb_stock_optn_dtls_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    ben_cso_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    ben_cso_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    ben_cso_shd.constraint_error
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
  (p_rec in ben_cso_shd.g_rec_type
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
  (p_effective_date               in date
  ,p_rec                          in ben_cso_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    ben_cso_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_cwb_stock_optn_dtls_id
      => p_rec.cwb_stock_optn_dtls_id
      ,p_grant_id
      => p_rec.grant_id
      ,p_grant_number
      => p_rec.grant_number
      ,p_grant_name
      => p_rec.grant_name
      ,p_grant_type
      => p_rec.grant_type
      ,p_grant_date
      => p_rec.grant_date
      ,p_grant_shares
      => p_rec.grant_shares
      ,p_grant_price
      => p_rec.grant_price
      ,p_value_at_grant
      => p_rec.value_at_grant
      ,p_current_share_price
      => p_rec.current_share_price
      ,p_current_shares_outstanding
      => p_rec.current_shares_outstanding
      ,p_vested_shares
      => p_rec.vested_shares
      ,p_unvested_shares
      => p_rec.unvested_shares
      ,p_exercisable_shares
      => p_rec.exercisable_shares
      ,p_exercised_shares
      => p_rec.exercised_shares
      ,p_cancelled_shares
      => p_rec.cancelled_shares
      ,p_trading_symbol
      => p_rec.trading_symbol
      ,p_expiration_date
      => p_rec.expiration_date
      ,p_reason_code
      => p_rec.reason_code
      ,p_class
      => p_rec.class
      ,p_misc
      => p_rec.misc
      ,p_employee_number
      => p_rec.employee_number
      ,p_person_id
      => p_rec.person_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_prtt_rt_val_id
      => p_rec.prtt_rt_val_id
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_cso_attribute_category
      => p_rec.cso_attribute_category
      ,p_cso_attribute1
      => p_rec.cso_attribute1
      ,p_cso_attribute2
      => p_rec.cso_attribute2
      ,p_cso_attribute3
      => p_rec.cso_attribute3
      ,p_cso_attribute4
      => p_rec.cso_attribute4
      ,p_cso_attribute5
      => p_rec.cso_attribute5
      ,p_cso_attribute6
      => p_rec.cso_attribute6
      ,p_cso_attribute7
      => p_rec.cso_attribute7
      ,p_cso_attribute8
      => p_rec.cso_attribute8
      ,p_cso_attribute9
      => p_rec.cso_attribute9
      ,p_cso_attribute10
      => p_rec.cso_attribute10
      ,p_cso_attribute11
      => p_rec.cso_attribute11
      ,p_cso_attribute12
      => p_rec.cso_attribute12
      ,p_cso_attribute13
      => p_rec.cso_attribute13
      ,p_cso_attribute14
      => p_rec.cso_attribute14
      ,p_cso_attribute15
      => p_rec.cso_attribute15
      ,p_cso_attribute16
      => p_rec.cso_attribute16
      ,p_cso_attribute17
      => p_rec.cso_attribute17
      ,p_cso_attribute18
      => p_rec.cso_attribute18
      ,p_cso_attribute19
      => p_rec.cso_attribute19
      ,p_cso_attribute20
      => p_rec.cso_attribute20
      ,p_cso_attribute21
      => p_rec.cso_attribute21
      ,p_cso_attribute22
      => p_rec.cso_attribute22
      ,p_cso_attribute23
      => p_rec.cso_attribute23
      ,p_cso_attribute24
      => p_rec.cso_attribute24
      ,p_cso_attribute25
      => p_rec.cso_attribute25
      ,p_cso_attribute26
      => p_rec.cso_attribute26
      ,p_cso_attribute27
      => p_rec.cso_attribute27
      ,p_cso_attribute28
      => p_rec.cso_attribute28
      ,p_cso_attribute29
      => p_rec.cso_attribute29
      ,p_cso_attribute30
      => p_rec.cso_attribute30
      ,p_grant_id_o
      => ben_cso_shd.g_old_rec.grant_id
      ,p_grant_number_o
      => ben_cso_shd.g_old_rec.grant_number
      ,p_grant_name_o
      => ben_cso_shd.g_old_rec.grant_name
      ,p_grant_type_o
      => ben_cso_shd.g_old_rec.grant_type
      ,p_grant_date_o
      => ben_cso_shd.g_old_rec.grant_date
      ,p_grant_shares_o
      => ben_cso_shd.g_old_rec.grant_shares
      ,p_grant_price_o
      => ben_cso_shd.g_old_rec.grant_price
      ,p_value_at_grant_o
      => ben_cso_shd.g_old_rec.value_at_grant
      ,p_current_share_price_o
      => ben_cso_shd.g_old_rec.current_share_price
      ,p_current_shares_outstanding_o
      => ben_cso_shd.g_old_rec.current_shares_outstanding
      ,p_vested_shares_o
      => ben_cso_shd.g_old_rec.vested_shares
      ,p_unvested_shares_o
      => ben_cso_shd.g_old_rec.unvested_shares
      ,p_exercisable_shares_o
      => ben_cso_shd.g_old_rec.exercisable_shares
      ,p_exercised_shares_o
      => ben_cso_shd.g_old_rec.exercised_shares
      ,p_cancelled_shares_o
      => ben_cso_shd.g_old_rec.cancelled_shares
      ,p_trading_symbol_o
      => ben_cso_shd.g_old_rec.trading_symbol
      ,p_expiration_date_o
      => ben_cso_shd.g_old_rec.expiration_date
      ,p_reason_code_o
      => ben_cso_shd.g_old_rec.reason_code
      ,p_class_o
      => ben_cso_shd.g_old_rec.class
      ,p_misc_o
      => ben_cso_shd.g_old_rec.misc
      ,p_employee_number_o
      => ben_cso_shd.g_old_rec.employee_number
      ,p_person_id_o
      => ben_cso_shd.g_old_rec.person_id
      ,p_business_group_id_o
      => ben_cso_shd.g_old_rec.business_group_id
      ,p_prtt_rt_val_id_o
      => ben_cso_shd.g_old_rec.prtt_rt_val_id
      ,p_object_version_number_o
      => ben_cso_shd.g_old_rec.object_version_number
      ,p_cso_attribute_category_o
      => ben_cso_shd.g_old_rec.cso_attribute_category
      ,p_cso_attribute1_o
      => ben_cso_shd.g_old_rec.cso_attribute1
      ,p_cso_attribute2_o
      => ben_cso_shd.g_old_rec.cso_attribute2
      ,p_cso_attribute3_o
      => ben_cso_shd.g_old_rec.cso_attribute3
      ,p_cso_attribute4_o
      => ben_cso_shd.g_old_rec.cso_attribute4
      ,p_cso_attribute5_o
      => ben_cso_shd.g_old_rec.cso_attribute5
      ,p_cso_attribute6_o
      => ben_cso_shd.g_old_rec.cso_attribute6
      ,p_cso_attribute7_o
      => ben_cso_shd.g_old_rec.cso_attribute7
      ,p_cso_attribute8_o
      => ben_cso_shd.g_old_rec.cso_attribute8
      ,p_cso_attribute9_o
      => ben_cso_shd.g_old_rec.cso_attribute9
      ,p_cso_attribute10_o
      => ben_cso_shd.g_old_rec.cso_attribute10
      ,p_cso_attribute11_o
      => ben_cso_shd.g_old_rec.cso_attribute11
      ,p_cso_attribute12_o
      => ben_cso_shd.g_old_rec.cso_attribute12
      ,p_cso_attribute13_o
      => ben_cso_shd.g_old_rec.cso_attribute13
      ,p_cso_attribute14_o
      => ben_cso_shd.g_old_rec.cso_attribute14
      ,p_cso_attribute15_o
      => ben_cso_shd.g_old_rec.cso_attribute15
      ,p_cso_attribute16_o
      => ben_cso_shd.g_old_rec.cso_attribute16
      ,p_cso_attribute17_o
      => ben_cso_shd.g_old_rec.cso_attribute17
      ,p_cso_attribute18_o
      => ben_cso_shd.g_old_rec.cso_attribute18
      ,p_cso_attribute19_o
      => ben_cso_shd.g_old_rec.cso_attribute19
      ,p_cso_attribute20_o
      => ben_cso_shd.g_old_rec.cso_attribute20
      ,p_cso_attribute21_o
      => ben_cso_shd.g_old_rec.cso_attribute21
      ,p_cso_attribute22_o
      => ben_cso_shd.g_old_rec.cso_attribute22
      ,p_cso_attribute23_o
      => ben_cso_shd.g_old_rec.cso_attribute23
      ,p_cso_attribute24_o
      => ben_cso_shd.g_old_rec.cso_attribute24
      ,p_cso_attribute25_o
      => ben_cso_shd.g_old_rec.cso_attribute25
      ,p_cso_attribute26_o
      => ben_cso_shd.g_old_rec.cso_attribute26
      ,p_cso_attribute27_o
      => ben_cso_shd.g_old_rec.cso_attribute27
      ,p_cso_attribute28_o
      => ben_cso_shd.g_old_rec.cso_attribute28
      ,p_cso_attribute29_o
      => ben_cso_shd.g_old_rec.cso_attribute29
      ,p_cso_attribute30_o
      => ben_cso_shd.g_old_rec.cso_attribute30
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'BEN_CWB_STOCK_OPTN_DTLS'
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
  (p_rec in out nocopy ben_cso_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.grant_id = hr_api.g_number) then
    p_rec.grant_id :=
    ben_cso_shd.g_old_rec.grant_id;
  End If;
  If (p_rec.grant_number = hr_api.g_varchar2) then
    p_rec.grant_number :=
    ben_cso_shd.g_old_rec.grant_number;
  End If;
  If (p_rec.grant_name = hr_api.g_varchar2) then
    p_rec.grant_name :=
    ben_cso_shd.g_old_rec.grant_name;
  End If;
  If (p_rec.grant_type = hr_api.g_varchar2) then
    p_rec.grant_type :=
    ben_cso_shd.g_old_rec.grant_type;
  End If;
  If (p_rec.grant_date = hr_api.g_date) then
    p_rec.grant_date :=
    ben_cso_shd.g_old_rec.grant_date;
  End If;
  If (p_rec.grant_shares = hr_api.g_number) then
    p_rec.grant_shares :=
    ben_cso_shd.g_old_rec.grant_shares;
  End If;
  If (p_rec.grant_price = hr_api.g_number) then
    p_rec.grant_price :=
    ben_cso_shd.g_old_rec.grant_price;
  End If;
  If (p_rec.value_at_grant = hr_api.g_number) then
    p_rec.value_at_grant :=
    ben_cso_shd.g_old_rec.value_at_grant;
  End If;
  If (p_rec.current_share_price = hr_api.g_number) then
    p_rec.current_share_price :=
    ben_cso_shd.g_old_rec.current_share_price;
  End If;
  If (p_rec.current_shares_outstanding = hr_api.g_number) then
    p_rec.current_shares_outstanding :=
    ben_cso_shd.g_old_rec.current_shares_outstanding;
  End If;
  If (p_rec.vested_shares = hr_api.g_number) then
    p_rec.vested_shares :=
    ben_cso_shd.g_old_rec.vested_shares;
  End If;
  If (p_rec.unvested_shares = hr_api.g_number) then
    p_rec.unvested_shares :=
    ben_cso_shd.g_old_rec.unvested_shares;
  End If;
  If (p_rec.exercisable_shares = hr_api.g_number) then
    p_rec.exercisable_shares :=
    ben_cso_shd.g_old_rec.exercisable_shares;
  End If;
  If (p_rec.exercised_shares = hr_api.g_number) then
    p_rec.exercised_shares :=
    ben_cso_shd.g_old_rec.exercised_shares;
  End If;
  If (p_rec.cancelled_shares = hr_api.g_number) then
    p_rec.cancelled_shares :=
    ben_cso_shd.g_old_rec.cancelled_shares;
  End If;
  If (p_rec.trading_symbol = hr_api.g_varchar2) then
    p_rec.trading_symbol :=
    ben_cso_shd.g_old_rec.trading_symbol;
  End If;
  If (p_rec.expiration_date = hr_api.g_date) then
    p_rec.expiration_date :=
    ben_cso_shd.g_old_rec.expiration_date;
  End If;
  If (p_rec.reason_code = hr_api.g_varchar2) then
    p_rec.reason_code :=
    ben_cso_shd.g_old_rec.reason_code;
  End If;
  If (p_rec.class = hr_api.g_varchar2) then
    p_rec.class :=
    ben_cso_shd.g_old_rec.class;
  End If;
  If (p_rec.misc = hr_api.g_varchar2) then
    p_rec.misc :=
    ben_cso_shd.g_old_rec.misc;
  End If;
  If (p_rec.employee_number = hr_api.g_varchar2) then
    p_rec.employee_number :=
    ben_cso_shd.g_old_rec.employee_number;
  End If;
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id :=
    ben_cso_shd.g_old_rec.person_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ben_cso_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.prtt_rt_val_id = hr_api.g_number) then
    p_rec.prtt_rt_val_id :=
    ben_cso_shd.g_old_rec.prtt_rt_val_id;
  End If;
  If (p_rec.cso_attribute_category = hr_api.g_varchar2) then
    p_rec.cso_attribute_category :=
    ben_cso_shd.g_old_rec.cso_attribute_category;
  End If;
  If (p_rec.cso_attribute1 = hr_api.g_varchar2) then
    p_rec.cso_attribute1 :=
    ben_cso_shd.g_old_rec.cso_attribute1;
  End If;
  If (p_rec.cso_attribute2 = hr_api.g_varchar2) then
    p_rec.cso_attribute2 :=
    ben_cso_shd.g_old_rec.cso_attribute2;
  End If;
  If (p_rec.cso_attribute3 = hr_api.g_varchar2) then
    p_rec.cso_attribute3 :=
    ben_cso_shd.g_old_rec.cso_attribute3;
  End If;
  If (p_rec.cso_attribute4 = hr_api.g_varchar2) then
    p_rec.cso_attribute4 :=
    ben_cso_shd.g_old_rec.cso_attribute4;
  End If;
  If (p_rec.cso_attribute5 = hr_api.g_varchar2) then
    p_rec.cso_attribute5 :=
    ben_cso_shd.g_old_rec.cso_attribute5;
  End If;
  If (p_rec.cso_attribute6 = hr_api.g_varchar2) then
    p_rec.cso_attribute6 :=
    ben_cso_shd.g_old_rec.cso_attribute6;
  End If;
  If (p_rec.cso_attribute7 = hr_api.g_varchar2) then
    p_rec.cso_attribute7 :=
    ben_cso_shd.g_old_rec.cso_attribute7;
  End If;
  If (p_rec.cso_attribute8 = hr_api.g_varchar2) then
    p_rec.cso_attribute8 :=
    ben_cso_shd.g_old_rec.cso_attribute8;
  End If;
  If (p_rec.cso_attribute9 = hr_api.g_varchar2) then
    p_rec.cso_attribute9 :=
    ben_cso_shd.g_old_rec.cso_attribute9;
  End If;
  If (p_rec.cso_attribute10 = hr_api.g_varchar2) then
    p_rec.cso_attribute10 :=
    ben_cso_shd.g_old_rec.cso_attribute10;
  End If;
  If (p_rec.cso_attribute11 = hr_api.g_varchar2) then
    p_rec.cso_attribute11 :=
    ben_cso_shd.g_old_rec.cso_attribute11;
  End If;
  If (p_rec.cso_attribute12 = hr_api.g_varchar2) then
    p_rec.cso_attribute12 :=
    ben_cso_shd.g_old_rec.cso_attribute12;
  End If;
  If (p_rec.cso_attribute13 = hr_api.g_varchar2) then
    p_rec.cso_attribute13 :=
    ben_cso_shd.g_old_rec.cso_attribute13;
  End If;
  If (p_rec.cso_attribute14 = hr_api.g_varchar2) then
    p_rec.cso_attribute14 :=
    ben_cso_shd.g_old_rec.cso_attribute14;
  End If;
  If (p_rec.cso_attribute15 = hr_api.g_varchar2) then
    p_rec.cso_attribute15 :=
    ben_cso_shd.g_old_rec.cso_attribute15;
  End If;
  If (p_rec.cso_attribute16 = hr_api.g_varchar2) then
    p_rec.cso_attribute16 :=
    ben_cso_shd.g_old_rec.cso_attribute16;
  End If;
  If (p_rec.cso_attribute17 = hr_api.g_varchar2) then
    p_rec.cso_attribute17 :=
    ben_cso_shd.g_old_rec.cso_attribute17;
  End If;
  If (p_rec.cso_attribute18 = hr_api.g_varchar2) then
    p_rec.cso_attribute18 :=
    ben_cso_shd.g_old_rec.cso_attribute18;
  End If;
  If (p_rec.cso_attribute19 = hr_api.g_varchar2) then
    p_rec.cso_attribute19 :=
    ben_cso_shd.g_old_rec.cso_attribute19;
  End If;
  If (p_rec.cso_attribute20 = hr_api.g_varchar2) then
    p_rec.cso_attribute20 :=
    ben_cso_shd.g_old_rec.cso_attribute20;
  End If;
  If (p_rec.cso_attribute21 = hr_api.g_varchar2) then
    p_rec.cso_attribute21 :=
    ben_cso_shd.g_old_rec.cso_attribute21;
  End If;
  If (p_rec.cso_attribute22 = hr_api.g_varchar2) then
    p_rec.cso_attribute22 :=
    ben_cso_shd.g_old_rec.cso_attribute22;
  End If;
  If (p_rec.cso_attribute23 = hr_api.g_varchar2) then
    p_rec.cso_attribute23 :=
    ben_cso_shd.g_old_rec.cso_attribute23;
  End If;
  If (p_rec.cso_attribute24 = hr_api.g_varchar2) then
    p_rec.cso_attribute24 :=
    ben_cso_shd.g_old_rec.cso_attribute24;
  End If;
  If (p_rec.cso_attribute25 = hr_api.g_varchar2) then
    p_rec.cso_attribute25 :=
    ben_cso_shd.g_old_rec.cso_attribute25;
  End If;
  If (p_rec.cso_attribute26 = hr_api.g_varchar2) then
    p_rec.cso_attribute26 :=
    ben_cso_shd.g_old_rec.cso_attribute26;
  End If;
  If (p_rec.cso_attribute27 = hr_api.g_varchar2) then
    p_rec.cso_attribute27 :=
    ben_cso_shd.g_old_rec.cso_attribute27;
  End If;
  If (p_rec.cso_attribute28 = hr_api.g_varchar2) then
    p_rec.cso_attribute28 :=
    ben_cso_shd.g_old_rec.cso_attribute28;
  End If;
  If (p_rec.cso_attribute29 = hr_api.g_varchar2) then
    p_rec.cso_attribute29 :=
    ben_cso_shd.g_old_rec.cso_attribute29;
  End If;
  If (p_rec.cso_attribute30 = hr_api.g_varchar2) then
    p_rec.cso_attribute30 :=
    ben_cso_shd.g_old_rec.cso_attribute30;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy ben_cso_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  ben_cso_shd.lck
    (p_rec.cwb_stock_optn_dtls_id
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
  ben_cso_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  ben_cso_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  ben_cso_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  ben_cso_upd.post_update
     (p_effective_date
     ,p_rec
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
  (p_effective_date               in     date
  ,p_cwb_stock_optn_dtls_id       in     number
  ,p_object_version_number        in out nocopy number
  ,p_grant_id                     in     number    default hr_api.g_number
  ,p_grant_number                 in     varchar2  default hr_api.g_varchar2
  ,p_grant_name                   in     varchar2  default hr_api.g_varchar2
  ,p_grant_type                   in     varchar2  default hr_api.g_varchar2
  ,p_grant_date                   in     date      default hr_api.g_date
  ,p_grant_shares                 in     number    default hr_api.g_number
  ,p_grant_price                  in     number    default hr_api.g_number
  ,p_value_at_grant               in     number    default hr_api.g_number
  ,p_current_share_price          in     number    default hr_api.g_number
  ,p_current_shares_outstanding   in     number    default hr_api.g_number
  ,p_vested_shares                in     number    default hr_api.g_number
  ,p_unvested_shares              in     number    default hr_api.g_number
  ,p_exercisable_shares           in     number    default hr_api.g_number
  ,p_exercised_shares             in     number    default hr_api.g_number
  ,p_cancelled_shares             in     number    default hr_api.g_number
  ,p_trading_symbol               in     varchar2  default hr_api.g_varchar2
  ,p_expiration_date              in     date      default hr_api.g_date
  ,p_reason_code                  in     varchar2  default hr_api.g_varchar2
  ,p_class                        in     varchar2  default hr_api.g_varchar2
  ,p_misc                         in     varchar2  default hr_api.g_varchar2
  ,p_employee_number              in     varchar2  default hr_api.g_varchar2
  ,p_person_id                    in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_prtt_rt_val_id               in     number    default hr_api.g_number
  ,p_cso_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_cso_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_cso_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_cso_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_cso_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_cso_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_cso_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_cso_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_cso_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_cso_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_cso_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_cso_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_cso_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_cso_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_cso_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_cso_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_cso_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_cso_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_cso_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_cso_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_cso_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_cso_attribute21              in     varchar2  default hr_api.g_varchar2
  ,p_cso_attribute22              in     varchar2  default hr_api.g_varchar2
  ,p_cso_attribute23              in     varchar2  default hr_api.g_varchar2
  ,p_cso_attribute24              in     varchar2  default hr_api.g_varchar2
  ,p_cso_attribute25              in     varchar2  default hr_api.g_varchar2
  ,p_cso_attribute26              in     varchar2  default hr_api.g_varchar2
  ,p_cso_attribute27              in     varchar2  default hr_api.g_varchar2
  ,p_cso_attribute28              in     varchar2  default hr_api.g_varchar2
  ,p_cso_attribute29              in     varchar2  default hr_api.g_varchar2
  ,p_cso_attribute30              in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec   ben_cso_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ben_cso_shd.convert_args
  (p_cwb_stock_optn_dtls_id
  ,p_grant_id
  ,p_grant_number
  ,p_grant_name
  ,p_grant_type
  ,p_grant_date
  ,p_grant_shares
  ,p_grant_price
  ,p_value_at_grant
  ,p_current_share_price
  ,p_current_shares_outstanding
  ,p_vested_shares
  ,p_unvested_shares
  ,p_exercisable_shares
  ,p_exercised_shares
  ,p_cancelled_shares
  ,p_trading_symbol
  ,p_expiration_date
  ,p_reason_code
  ,p_class
  ,p_misc
  ,p_employee_number
  ,p_person_id
  ,p_business_group_id
  ,p_prtt_rt_val_id
  ,p_object_version_number
  ,p_cso_attribute_category
  ,p_cso_attribute1
  ,p_cso_attribute2
  ,p_cso_attribute3
  ,p_cso_attribute4
  ,p_cso_attribute5
  ,p_cso_attribute6
  ,p_cso_attribute7
  ,p_cso_attribute8
  ,p_cso_attribute9
  ,p_cso_attribute10
  ,p_cso_attribute11
  ,p_cso_attribute12
  ,p_cso_attribute13
  ,p_cso_attribute14
  ,p_cso_attribute15
  ,p_cso_attribute16
  ,p_cso_attribute17
  ,p_cso_attribute18
  ,p_cso_attribute19
  ,p_cso_attribute20
  ,p_cso_attribute21
  ,p_cso_attribute22
  ,p_cso_attribute23
  ,p_cso_attribute24
  ,p_cso_attribute25
  ,p_cso_attribute26
  ,p_cso_attribute27
  ,p_cso_attribute28
  ,p_cso_attribute29
  ,p_cso_attribute30
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ben_cso_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ben_cso_upd;

/
