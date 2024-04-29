--------------------------------------------------------
--  DDL for Package Body PQH_STS_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_STS_UPD" as
/* $Header: pqstsrhi.pkb 120.0 2005/05/29 02:43 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_sts_upd.';  -- Global package name
g_debug boolean := hr_utility.debug_enabled;
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
  (p_rec in out nocopy pqh_sts_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
     if g_debug then
   --
     hr_utility.set_location('Entering:'||l_proc, 5);
   --
     End if;
  --
  -- Increment the object version
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  --
  --
  -- Update the pqh_fr_stat_situations Row
  --
  update pqh_fr_stat_situations
    set
     statutory_situation_id          = p_rec.statutory_situation_id
    ,business_group_id               = p_rec.business_group_id
    ,situation_name                  = p_rec.situation_name
    ,type_of_ps                      = p_rec.type_of_ps
    ,situation_type                  = p_rec.situation_type
    ,sub_type                        = p_rec.sub_type
    ,source                          = p_rec.source
    ,location                        = p_rec.location
    ,reason                          = p_rec.reason
    ,default_flag                    = p_rec.is_default
    ,date_from                       = trunc(p_rec.date_from)
    ,date_to                         = trunc(p_rec.date_to)
    ,request_type                    = p_rec.request_type
    ,employee_agreement_needed       = p_rec.employee_agreement_needed
    ,manager_agreement_needed        = p_rec.manager_agreement_needed
    ,print_arrette                   = p_rec.print_arrette
    ,reserve_position                = p_rec.reserve_position
    ,allow_progression_flag          = p_rec.allow_progressions
    ,extend_probation_period_flag    = p_rec.extend_probation_period
    ,remuneration_paid               = p_rec.remuneration_paid
    ,pay_share                       = p_rec.pay_share
    ,pay_periods                     = p_rec.pay_periods
    ,frequency                       = p_rec.frequency
    ,first_period_max_duration       = p_rec.first_period_max_duration
    ,min_duration_per_request        = p_rec.min_duration_per_request
    ,max_duration_per_request        = p_rec.max_duration_per_request
    ,max_duration_whole_career       = p_rec.max_duration_whole_career
    ,renewable_allowed               = p_rec.renewable_allowed
    ,max_no_of_renewals              = p_rec.max_no_of_renewals
    ,max_duration_per_renewal        = p_rec.max_duration_per_renewal
    ,max_tot_continuous_duration     = p_rec.max_tot_continuous_duration
    ,object_version_number           = p_rec.object_version_number
    ,remunerate_assign_status_id     = p_rec.remunerate_assign_status_id
    where statutory_situation_id = p_rec.statutory_situation_id;
  --
  --
  --
     if g_debug then
   --
      hr_utility.set_location(' Leaving:'||l_proc, 10);
      --
      End if;
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    pqh_sts_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    pqh_sts_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    pqh_sts_shd.constraint_error
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
  (p_rec in pqh_sts_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_update';
--
Begin
     if g_debug then
   --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
    --
    End if;
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
  ,p_rec                          in pqh_sts_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
     if g_debug then
   --
     hr_utility.set_location('Entering:'||l_proc, 5);
     --
     end if;
  begin
    --
    pqh_sts_rku.after_update
      (p_effective_date              => trunc(p_effective_date)
      ,p_statutory_situation_id
      => p_rec.statutory_situation_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_situation_name
      => p_rec.situation_name
      ,p_type_of_ps
      => p_rec.type_of_ps
      ,p_situation_type
      => p_rec.situation_type
      ,p_sub_type
      => p_rec.sub_type
      ,p_source
      => p_rec.source
      ,p_location
      => p_rec.location
      ,p_reason
      => p_rec.reason
      ,p_is_default
      => p_rec.is_default
      ,p_date_from
      => trunc(p_rec.date_from)
      ,p_date_to
      => trunc(p_rec.date_to)
      ,p_request_type
      => p_rec.request_type
      ,p_employee_agreement_needed
      => p_rec.employee_agreement_needed
      ,p_manager_agreement_needed
      => p_rec.manager_agreement_needed
      ,p_print_arrette
      => p_rec.print_arrette
      ,p_reserve_position
      => p_rec.reserve_position
      ,p_allow_progressions
      => p_rec.allow_progressions
      ,p_extend_probation_period
      => p_rec.extend_probation_period
      ,p_remuneration_paid
      => p_rec.remuneration_paid
      ,p_pay_share
      => p_rec.pay_share
      ,p_pay_periods
      => p_rec.pay_periods
      ,p_frequency
      => p_rec.frequency
      ,p_first_period_max_duration
      => p_rec.first_period_max_duration
      ,p_min_duration_per_request
      => p_rec.min_duration_per_request
      ,p_max_duration_per_request
      => p_rec.max_duration_per_request
      ,p_max_duration_whole_career
      => p_rec.max_duration_whole_career
      ,p_renewable_allowed
      => p_rec.renewable_allowed
      ,p_max_no_of_renewals
      => p_rec.max_no_of_renewals
      ,p_max_duration_per_renewal
      => p_rec.max_duration_per_renewal
      ,p_max_tot_continuous_duration
      => p_rec.max_tot_continuous_duration
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_remunerate_assign_status_id
      => p_rec.remunerate_assign_status_id
      ,p_business_group_id_o
      => pqh_sts_shd.g_old_rec.business_group_id
      ,p_situation_name_o
      => pqh_sts_shd.g_old_rec.situation_name
      ,p_type_of_ps_o
      => pqh_sts_shd.g_old_rec.type_of_ps
      ,p_situation_type_o
      => pqh_sts_shd.g_old_rec.situation_type
      ,p_sub_type_o
      => pqh_sts_shd.g_old_rec.sub_type
      ,p_source_o
      => pqh_sts_shd.g_old_rec.source
      ,p_location_o
      => pqh_sts_shd.g_old_rec.location
      ,p_reason_o
      => pqh_sts_shd.g_old_rec.reason
      ,p_is_default_o
      => pqh_sts_shd.g_old_rec.is_default
      ,p_date_from_o
      => pqh_sts_shd.g_old_rec.date_from
      ,p_date_to_o
      => pqh_sts_shd.g_old_rec.date_to
      ,p_request_type_o
      => pqh_sts_shd.g_old_rec.request_type
      ,p_employee_agreement_needed_o
      => pqh_sts_shd.g_old_rec.employee_agreement_needed
      ,p_manager_agreement_needed_o
      => pqh_sts_shd.g_old_rec.manager_agreement_needed
      ,p_print_arrette_o
      => pqh_sts_shd.g_old_rec.print_arrette
      ,p_reserve_position_o
      => pqh_sts_shd.g_old_rec.reserve_position
      ,p_allow_progressions_o
      => pqh_sts_shd.g_old_rec.allow_progressions
      ,p_extend_probation_period_o
      => pqh_sts_shd.g_old_rec.extend_probation_period
      ,p_remuneration_paid_o
      => pqh_sts_shd.g_old_rec.remuneration_paid
      ,p_pay_share_o
      => pqh_sts_shd.g_old_rec.pay_share
      ,p_pay_periods_o
      => pqh_sts_shd.g_old_rec.pay_periods
      ,p_frequency_o
      => pqh_sts_shd.g_old_rec.frequency
      ,p_first_period_max_duration_o
      => pqh_sts_shd.g_old_rec.first_period_max_duration
      ,p_min_duration_per_request_o
      => pqh_sts_shd.g_old_rec.min_duration_per_request
      ,p_max_duration_per_request_o
      => pqh_sts_shd.g_old_rec.max_duration_per_request
      ,p_max_duration_whole_career_o
      => pqh_sts_shd.g_old_rec.max_duration_whole_career
      ,p_renewable_allowed_o
      => pqh_sts_shd.g_old_rec.renewable_allowed
      ,p_max_no_of_renewals_o
      => pqh_sts_shd.g_old_rec.max_no_of_renewals
      ,p_max_duration_per_renewal_o
      => pqh_sts_shd.g_old_rec.max_duration_per_renewal
      ,p_max_tot_continuous_duratio_o
      => pqh_sts_shd.g_old_rec.max_tot_continuous_duration
      ,p_object_version_number_o
      => pqh_sts_shd.g_old_rec.object_version_number
      ,p_remunerate_assign_stat_id_o
      => pqh_sts_shd.g_old_rec.remunerate_assign_status_id
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_FR_STAT_SITUATIONS'
        ,p_hook_type   => 'AU');
      --
  end;
  --
   if g_debug then
   --
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
   --
   End if;

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
  (p_rec in out nocopy pqh_sts_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    pqh_sts_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.situation_name = hr_api.g_varchar2) then
    p_rec.situation_name :=
    pqh_sts_shd.g_old_rec.situation_name;
  End If;
  If (p_rec.type_of_ps = hr_api.g_varchar2) then
    p_rec.type_of_ps :=
    pqh_sts_shd.g_old_rec.type_of_ps;
  End If;
  If (p_rec.situation_type = hr_api.g_varchar2) then
    p_rec.situation_type :=
    pqh_sts_shd.g_old_rec.situation_type;
  End If;
  If (p_rec.sub_type = hr_api.g_varchar2) then
    p_rec.sub_type :=
    pqh_sts_shd.g_old_rec.sub_type;
  End If;
  If (p_rec.source = hr_api.g_varchar2) then
    p_rec.source :=
    pqh_sts_shd.g_old_rec.source;
  End If;
  If (p_rec.location = hr_api.g_varchar2) then
    p_rec.location :=
    pqh_sts_shd.g_old_rec.location;
  End If;
  If (p_rec.reason = hr_api.g_varchar2) then
    p_rec.reason :=
    pqh_sts_shd.g_old_rec.reason;
  End If;
  If (p_rec.is_default = hr_api.g_varchar2) then
    p_rec.is_default :=
    pqh_sts_shd.g_old_rec.is_default;
  End If;
  If (p_rec.date_from = hr_api.g_date) then
    p_rec.date_from :=
    pqh_sts_shd.g_old_rec.date_from;
  End If;
  If (p_rec.date_to = hr_api.g_date) then
    p_rec.date_to :=
    pqh_sts_shd.g_old_rec.date_to;
  End If;
  If (p_rec.request_type = hr_api.g_varchar2) then
    p_rec.request_type :=
    pqh_sts_shd.g_old_rec.request_type;
  End If;
  If (p_rec.employee_agreement_needed = hr_api.g_varchar2) then
    p_rec.employee_agreement_needed :=
    pqh_sts_shd.g_old_rec.employee_agreement_needed;
  End If;
  If (p_rec.manager_agreement_needed = hr_api.g_varchar2) then
    p_rec.manager_agreement_needed :=
    pqh_sts_shd.g_old_rec.manager_agreement_needed;
  End If;
  If (p_rec.print_arrette = hr_api.g_varchar2) then
    p_rec.print_arrette :=
    pqh_sts_shd.g_old_rec.print_arrette;
  End If;
  If (p_rec.reserve_position = hr_api.g_varchar2) then
    p_rec.reserve_position :=
    pqh_sts_shd.g_old_rec.reserve_position;
  End If;
  If (p_rec.allow_progressions = hr_api.g_varchar2) then
    p_rec.allow_progressions :=
    pqh_sts_shd.g_old_rec.reserve_position;
  End If;
  If (p_rec.extend_probation_period  = hr_api.g_varchar2) then
    p_rec.extend_probation_period  :=
    pqh_sts_shd.g_old_rec.reserve_position;
  End If;
  If (p_rec.remuneration_paid = hr_api.g_varchar2) then
    p_rec.remuneration_paid :=
    pqh_sts_shd.g_old_rec.remuneration_paid;
  End If;
  If (p_rec.pay_share = hr_api.g_number) then
    p_rec.pay_share :=
    pqh_sts_shd.g_old_rec.pay_share;
  End If;
  If (p_rec.pay_periods = hr_api.g_number) then
    p_rec.pay_periods :=
    pqh_sts_shd.g_old_rec.pay_periods;
  End If;
  If (p_rec.frequency = hr_api.g_varchar2) then
    p_rec.frequency :=
    pqh_sts_shd.g_old_rec.frequency;
  End If;
  If (p_rec.first_period_max_duration = hr_api.g_number) then
    p_rec.first_period_max_duration :=
    pqh_sts_shd.g_old_rec.first_period_max_duration;
  End If;
  If (p_rec.min_duration_per_request = hr_api.g_number) then
    p_rec.min_duration_per_request :=
    pqh_sts_shd.g_old_rec.min_duration_per_request;
  End If;
  If (p_rec.max_duration_per_request = hr_api.g_number) then
    p_rec.max_duration_per_request :=
    pqh_sts_shd.g_old_rec.max_duration_per_request;
  End If;
  If (p_rec.max_duration_whole_career = hr_api.g_number) then
    p_rec.max_duration_whole_career :=
    pqh_sts_shd.g_old_rec.max_duration_whole_career;
  End If;
  If (p_rec.renewable_allowed = hr_api.g_varchar2) then
    p_rec.renewable_allowed :=
    pqh_sts_shd.g_old_rec.renewable_allowed;
  End If;
  If (p_rec.max_no_of_renewals = hr_api.g_number) then
    p_rec.max_no_of_renewals :=
    pqh_sts_shd.g_old_rec.max_no_of_renewals;
  End If;
  If (p_rec.max_duration_per_renewal = hr_api.g_number) then
    p_rec.max_duration_per_renewal :=
    pqh_sts_shd.g_old_rec.max_duration_per_renewal;
  End If;
  If (p_rec.max_tot_continuous_duration = hr_api.g_number) then
    p_rec.max_tot_continuous_duration :=
    pqh_sts_shd.g_old_rec.max_tot_continuous_duration;
  End If;
  If (p_rec.remunerate_assign_status_id = hr_api.g_number) then
    p_rec.remunerate_assign_status_id :=
    pqh_sts_shd.g_old_rec.remunerate_assign_status_id;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy pqh_sts_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin

 g_debug := hr_utility.debug_enabled;

if g_debug then
   --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  End if;
  --
  -- We must lock the row which we need to update.
  --
  pqh_sts_shd.lck
    (p_rec.statutory_situation_id
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
  pqh_sts_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  pqh_sts_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  pqh_sts_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  pqh_sts_upd.post_update
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
  ,p_statutory_situation_id       in     number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_situation_name               in     varchar2  default hr_api.g_varchar2
  ,p_type_of_ps                   in     varchar2  default hr_api.g_varchar2
  ,p_situation_type               in     varchar2  default hr_api.g_varchar2
  ,p_sub_type                     in     varchar2  default hr_api.g_varchar2
  ,p_source                       in     varchar2  default hr_api.g_varchar2
  ,p_location                     in     varchar2  default hr_api.g_varchar2
  ,p_reason                       in     varchar2  default hr_api.g_varchar2
  ,p_is_default                   in     varchar2  default hr_api.g_varchar2
  ,p_date_from                    in     date      default hr_api.g_date
  ,p_date_to                      in     date      default hr_api.g_date
  ,p_request_type                 in     varchar2  default hr_api.g_varchar2
  ,p_employee_agreement_needed    in     varchar2  default hr_api.g_varchar2
  ,p_manager_agreement_needed     in     varchar2  default hr_api.g_varchar2
  ,p_print_arrette                in     varchar2  default hr_api.g_varchar2
  ,p_reserve_position             in     varchar2  default hr_api.g_varchar2
  ,p_allow_progressions           in     varchar2  default hr_api.g_varchar2
  ,p_extend_probation_period      in     varchar2  default hr_api.g_varchar2
  ,p_remuneration_paid            in     varchar2  default hr_api.g_varchar2
  ,p_pay_share                    in     number    default hr_api.g_number
  ,p_pay_periods                  in     number    default hr_api.g_number
  ,p_frequency                    in     varchar2  default hr_api.g_varchar2
  ,p_first_period_max_duration    in     number    default hr_api.g_number
  ,p_min_duration_per_request     in     number    default hr_api.g_number
  ,p_max_duration_per_request     in     number    default hr_api.g_number
  ,p_max_duration_whole_career    in     number    default hr_api.g_number
  ,p_renewable_allowed            in     varchar2  default hr_api.g_varchar2
  ,p_max_no_of_renewals           in     number    default hr_api.g_number
  ,p_max_duration_per_renewal     in     number    default hr_api.g_number
  ,p_max_tot_continuous_duration  in     number    default hr_api.g_number
  ,p_remunerate_assign_status_id  in     number    default hr_api.g_number
  ) is
--
  l_rec   pqh_sts_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin

g_debug := hr_utility.debug_enabled;

if g_debug then
   --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  End if;
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pqh_sts_shd.convert_args
  (p_statutory_situation_id
  ,p_business_group_id
  ,p_situation_name
  ,p_type_of_ps
  ,p_situation_type
  ,p_sub_type
  ,p_source
  ,p_location
  ,p_reason
  ,p_is_default
  ,p_date_from
  ,p_date_to
  ,p_request_type
  ,p_employee_agreement_needed
  ,p_manager_agreement_needed
  ,p_print_arrette
  ,p_reserve_position
  ,p_allow_progressions
  ,p_extend_probation_period
  ,p_remuneration_paid
  ,p_pay_share
  ,p_pay_periods
  ,p_frequency
  ,p_first_period_max_duration
  ,p_min_duration_per_request
  ,p_max_duration_per_request
  ,p_max_duration_whole_career
  ,p_renewable_allowed
  ,p_max_no_of_renewals
  ,p_max_duration_per_renewal
  ,p_max_tot_continuous_duration
  ,p_object_version_number
  ,p_remunerate_assign_status_id
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pqh_sts_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  if g_debug then
   --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  End if;
  --
End upd;
--
end pqh_sts_upd;

/
