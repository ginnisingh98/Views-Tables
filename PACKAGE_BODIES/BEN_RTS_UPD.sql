--------------------------------------------------------
--  DDL for Package Body BEN_RTS_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_RTS_UPD" as
/* $Header: bertsrhi.pkb 120.1 2006/01/09 14:37 maagrawa noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_rts_upd.';  -- Global package name
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
  (p_rec in out nocopy ben_rts_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Increment the object version
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  ben_rts_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ben_cwb_person_rates Row
  --
  update ben_cwb_person_rates
    set
     group_pl_id                     = p_rec.group_pl_id
    ,group_oipl_id                   = p_rec.group_oipl_id
    ,lf_evt_ocrd_dt                  = p_rec.lf_evt_ocrd_dt
    ,person_id                       = p_rec.person_id
    ,assignment_id                   = p_rec.assignment_id
    ,elig_flag                       = p_rec.elig_flag
    ,ws_val                          = p_rec.ws_val
    ,ws_mn_val                       = p_rec.ws_mn_val
    ,ws_mx_val                       = p_rec.ws_mx_val
    ,ws_incr_val                     = p_rec.ws_incr_val
    ,elig_sal_val                    = p_rec.elig_sal_val
    ,stat_sal_val                    = p_rec.stat_sal_val
    ,oth_comp_val                    = p_rec.oth_comp_val
    ,tot_comp_val                    = p_rec.tot_comp_val
    ,misc1_val                       = p_rec.misc1_val
    ,misc2_val                       = p_rec.misc2_val
    ,misc3_val                       = p_rec.misc3_val
    ,rec_val                         = p_rec.rec_val
    ,rec_mn_val                      = p_rec.rec_mn_val
    ,rec_mx_val                      = p_rec.rec_mx_val
    ,rec_incr_val                    = p_rec.rec_incr_val
    ,ws_val_last_upd_date            = p_rec.ws_val_last_upd_date
    ,ws_val_last_upd_by              = p_rec.ws_val_last_upd_by
    ,pay_proposal_id                 = p_rec.pay_proposal_id
    ,element_entry_value_id          = p_rec.element_entry_value_id
    ,inelig_rsn_cd                   = p_rec.inelig_rsn_cd
    ,elig_ovrid_dt                   = p_rec.elig_ovrid_dt
    ,elig_ovrid_person_id            = p_rec.elig_ovrid_person_id
    ,copy_dist_bdgt_val              = p_rec.copy_dist_bdgt_val
    ,copy_ws_bdgt_val                = p_rec.copy_ws_bdgt_val
    ,copy_rsrv_val                   = p_rec.copy_rsrv_val
    ,copy_dist_bdgt_mn_val           = p_rec.copy_dist_bdgt_mn_val
    ,copy_dist_bdgt_mx_val           = p_rec.copy_dist_bdgt_mx_val
    ,copy_dist_bdgt_incr_val         = p_rec.copy_dist_bdgt_incr_val
    ,copy_ws_bdgt_mn_val             = p_rec.copy_ws_bdgt_mn_val
    ,copy_ws_bdgt_mx_val             = p_rec.copy_ws_bdgt_mx_val
    ,copy_ws_bdgt_incr_val           = p_rec.copy_ws_bdgt_incr_val
    ,copy_rsrv_mn_val                = p_rec.copy_rsrv_mn_val
    ,copy_rsrv_mx_val                = p_rec.copy_rsrv_mx_val
    ,copy_rsrv_incr_val              = p_rec.copy_rsrv_incr_val
    ,copy_dist_bdgt_iss_val          = p_rec.copy_dist_bdgt_iss_val
    ,copy_ws_bdgt_iss_val            = p_rec.copy_ws_bdgt_iss_val
    ,copy_dist_bdgt_iss_date         = p_rec.copy_dist_bdgt_iss_date
    ,copy_ws_bdgt_iss_date           = p_rec.copy_ws_bdgt_iss_date
    ,comp_posting_date               = p_rec.comp_posting_date
    ,ws_rt_start_date                = p_rec.ws_rt_start_date
    ,currency                        = p_rec.currency
    ,object_version_number           = p_rec.object_version_number
    where group_per_in_ler_id = p_rec.group_per_in_ler_id
    and pl_id = p_rec.pl_id
    and oipl_id = p_rec.oipl_id;
  --
  ben_rts_shd.g_api_dml := false;   -- Unset the api dml status
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_rts_shd.g_api_dml := false;   -- Unset the api dml status
    ben_rts_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_rts_shd.g_api_dml := false;   -- Unset the api dml status
    ben_rts_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_rts_shd.g_api_dml := false;   -- Unset the api dml status
    ben_rts_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_rts_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec in ben_rts_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_update';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
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
  (p_rec                          in ben_rts_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  begin
    --
    ben_rts_rku.after_update
      (p_person_rate_id
      => p_rec.person_rate_id
      ,p_group_per_in_ler_id
      => p_rec.group_per_in_ler_id
      ,p_pl_id
      => p_rec.pl_id
      ,p_oipl_id
      => p_rec.oipl_id
      ,p_group_pl_id
      => p_rec.group_pl_id
      ,p_group_oipl_id
      => p_rec.group_oipl_id
      ,p_lf_evt_ocrd_dt
      => p_rec.lf_evt_ocrd_dt
      ,p_person_id
      => p_rec.person_id
      ,p_assignment_id
      => p_rec.assignment_id
      ,p_elig_flag
      => p_rec.elig_flag
      ,p_ws_val
      => p_rec.ws_val
      ,p_ws_mn_val
      => p_rec.ws_mn_val
      ,p_ws_mx_val
      => p_rec.ws_mx_val
      ,p_ws_incr_val
      => p_rec.ws_incr_val
      ,p_elig_sal_val
      => p_rec.elig_sal_val
      ,p_stat_sal_val
      => p_rec.stat_sal_val
      ,p_oth_comp_val
      => p_rec.oth_comp_val
      ,p_tot_comp_val
      => p_rec.tot_comp_val
      ,p_misc1_val
      => p_rec.misc1_val
      ,p_misc2_val
      => p_rec.misc2_val
      ,p_misc3_val
      => p_rec.misc3_val
      ,p_rec_val
      => p_rec.rec_val
      ,p_rec_mn_val
      => p_rec.rec_mn_val
      ,p_rec_mx_val
      => p_rec.rec_mx_val
      ,p_rec_incr_val
      => p_rec.rec_incr_val
      ,p_ws_val_last_upd_date
      => p_rec.ws_val_last_upd_date
      ,p_ws_val_last_upd_by
      => p_rec.ws_val_last_upd_by
      ,p_pay_proposal_id
      => p_rec.pay_proposal_id
      ,p_element_entry_value_id
      => p_rec.element_entry_value_id
      ,p_inelig_rsn_cd
      => p_rec.inelig_rsn_cd
      ,p_elig_ovrid_dt
      => p_rec.elig_ovrid_dt
      ,p_elig_ovrid_person_id
      => p_rec.elig_ovrid_person_id
      ,p_copy_dist_bdgt_val
      => p_rec.copy_dist_bdgt_val
      ,p_copy_ws_bdgt_val
      => p_rec.copy_ws_bdgt_val
      ,p_copy_rsrv_val
      => p_rec.copy_rsrv_val
      ,p_copy_dist_bdgt_mn_val
      => p_rec.copy_dist_bdgt_mn_val
      ,p_copy_dist_bdgt_mx_val
      => p_rec.copy_dist_bdgt_mx_val
      ,p_copy_dist_bdgt_incr_val
      => p_rec.copy_dist_bdgt_incr_val
      ,p_copy_ws_bdgt_mn_val
      => p_rec.copy_ws_bdgt_mn_val
      ,p_copy_ws_bdgt_mx_val
      => p_rec.copy_ws_bdgt_mx_val
      ,p_copy_ws_bdgt_incr_val
      => p_rec.copy_ws_bdgt_incr_val
      ,p_copy_rsrv_mn_val
      => p_rec.copy_rsrv_mn_val
      ,p_copy_rsrv_mx_val
      => p_rec.copy_rsrv_mx_val
      ,p_copy_rsrv_incr_val
      => p_rec.copy_rsrv_incr_val
      ,p_copy_dist_bdgt_iss_val
      => p_rec.copy_dist_bdgt_iss_val
      ,p_copy_ws_bdgt_iss_val
      => p_rec.copy_ws_bdgt_iss_val
      ,p_copy_dist_bdgt_iss_date
      => p_rec.copy_dist_bdgt_iss_date
      ,p_copy_ws_bdgt_iss_date
      => p_rec.copy_ws_bdgt_iss_date
      ,p_comp_posting_date
      => p_rec.comp_posting_date
      ,p_ws_rt_start_date
      => p_rec.ws_rt_start_date
      ,p_currency
      => p_rec.currency
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_group_per_in_ler_id_o
      => ben_rts_shd.g_old_rec.group_per_in_ler_id
      ,p_pl_id_o
      => ben_rts_shd.g_old_rec.pl_id
      ,p_oipl_id_o
      => ben_rts_shd.g_old_rec.oipl_id
      ,p_group_pl_id_o
      => ben_rts_shd.g_old_rec.group_pl_id
      ,p_group_oipl_id_o
      => ben_rts_shd.g_old_rec.group_oipl_id
      ,p_lf_evt_ocrd_dt_o
      => ben_rts_shd.g_old_rec.lf_evt_ocrd_dt
      ,p_person_id_o
      => ben_rts_shd.g_old_rec.person_id
      ,p_assignment_id_o
      => ben_rts_shd.g_old_rec.assignment_id
      ,p_elig_flag_o
      => ben_rts_shd.g_old_rec.elig_flag
      ,p_ws_val_o
      => ben_rts_shd.g_old_rec.ws_val
      ,p_ws_mn_val_o
      => ben_rts_shd.g_old_rec.ws_mn_val
      ,p_ws_mx_val_o
      => ben_rts_shd.g_old_rec.ws_mx_val
      ,p_ws_incr_val_o
      => ben_rts_shd.g_old_rec.ws_incr_val
      ,p_elig_sal_val_o
      => ben_rts_shd.g_old_rec.elig_sal_val
      ,p_stat_sal_val_o
      => ben_rts_shd.g_old_rec.stat_sal_val
      ,p_oth_comp_val_o
      => ben_rts_shd.g_old_rec.oth_comp_val
      ,p_tot_comp_val_o
      => ben_rts_shd.g_old_rec.tot_comp_val
      ,p_misc1_val_o
      => ben_rts_shd.g_old_rec.misc1_val
      ,p_misc2_val_o
      => ben_rts_shd.g_old_rec.misc2_val
      ,p_misc3_val_o
      => ben_rts_shd.g_old_rec.misc3_val
      ,p_rec_val_o
      => ben_rts_shd.g_old_rec.rec_val
      ,p_rec_mn_val_o
      => ben_rts_shd.g_old_rec.rec_mn_val
      ,p_rec_mx_val_o
      => ben_rts_shd.g_old_rec.rec_mx_val
      ,p_rec_incr_val_o
      => ben_rts_shd.g_old_rec.rec_incr_val
      ,p_ws_val_last_upd_date_o
      => ben_rts_shd.g_old_rec.ws_val_last_upd_date
      ,p_ws_val_last_upd_by_o
      => ben_rts_shd.g_old_rec.ws_val_last_upd_by
      ,p_pay_proposal_id_o
      => ben_rts_shd.g_old_rec.pay_proposal_id
      ,p_element_entry_value_id_o
      => ben_rts_shd.g_old_rec.element_entry_value_id
      ,p_inelig_rsn_cd_o
      => ben_rts_shd.g_old_rec.inelig_rsn_cd
      ,p_elig_ovrid_dt_o
      => ben_rts_shd.g_old_rec.elig_ovrid_dt
      ,p_elig_ovrid_person_id_o
      => ben_rts_shd.g_old_rec.elig_ovrid_person_id
      ,p_copy_dist_bdgt_val_o
      => ben_rts_shd.g_old_rec.copy_dist_bdgt_val
      ,p_copy_ws_bdgt_val_o
      => ben_rts_shd.g_old_rec.copy_ws_bdgt_val
      ,p_copy_rsrv_val_o
      => ben_rts_shd.g_old_rec.copy_rsrv_val
      ,p_copy_dist_bdgt_mn_val_o
      => ben_rts_shd.g_old_rec.copy_dist_bdgt_mn_val
      ,p_copy_dist_bdgt_mx_val_o
      => ben_rts_shd.g_old_rec.copy_dist_bdgt_mx_val
      ,p_copy_dist_bdgt_incr_val_o
      => ben_rts_shd.g_old_rec.copy_dist_bdgt_incr_val
      ,p_copy_ws_bdgt_mn_val_o
      => ben_rts_shd.g_old_rec.copy_ws_bdgt_mn_val
      ,p_copy_ws_bdgt_mx_val_o
      => ben_rts_shd.g_old_rec.copy_ws_bdgt_mx_val
      ,p_copy_ws_bdgt_incr_val_o
      => ben_rts_shd.g_old_rec.copy_ws_bdgt_incr_val
      ,p_copy_rsrv_mn_val_o
      => ben_rts_shd.g_old_rec.copy_rsrv_mn_val
      ,p_copy_rsrv_mx_val_o
      => ben_rts_shd.g_old_rec.copy_rsrv_mx_val
      ,p_copy_rsrv_incr_val_o
      => ben_rts_shd.g_old_rec.copy_rsrv_incr_val
      ,p_copy_dist_bdgt_iss_val_o
      => ben_rts_shd.g_old_rec.copy_dist_bdgt_iss_val
      ,p_copy_ws_bdgt_iss_val_o
      => ben_rts_shd.g_old_rec.copy_ws_bdgt_iss_val
      ,p_copy_dist_bdgt_iss_date_o
      => ben_rts_shd.g_old_rec.copy_dist_bdgt_iss_date
      ,p_copy_ws_bdgt_iss_date_o
      => ben_rts_shd.g_old_rec.copy_ws_bdgt_iss_date
      ,p_comp_posting_date_o
      => ben_rts_shd.g_old_rec.comp_posting_date
      ,p_ws_rt_start_date_o
      => ben_rts_shd.g_old_rec.ws_rt_start_date
      ,p_currency_o
      => ben_rts_shd.g_old_rec.currency
      ,p_object_version_number_o
      => ben_rts_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'BEN_CWB_PERSON_RATES'
        ,p_hook_type   => 'AU');
      --
  end;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
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
  (p_rec in out nocopy ben_rts_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.group_pl_id = hr_api.g_number) then
    p_rec.group_pl_id :=
    ben_rts_shd.g_old_rec.group_pl_id;
  End If;
  If (p_rec.group_oipl_id = hr_api.g_number) then
    p_rec.group_oipl_id :=
    ben_rts_shd.g_old_rec.group_oipl_id;
  End If;
  If (p_rec.lf_evt_ocrd_dt = hr_api.g_date) then
    p_rec.lf_evt_ocrd_dt :=
    ben_rts_shd.g_old_rec.lf_evt_ocrd_dt;
  End If;
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id :=
    ben_rts_shd.g_old_rec.person_id;
  End If;
  If (p_rec.assignment_id = hr_api.g_number) then
    p_rec.assignment_id :=
    ben_rts_shd.g_old_rec.assignment_id;
  End If;
  If (p_rec.elig_flag = hr_api.g_varchar2) then
    p_rec.elig_flag :=
    ben_rts_shd.g_old_rec.elig_flag;
  End If;
  If (p_rec.ws_val = hr_api.g_number) then
    p_rec.ws_val :=
    ben_rts_shd.g_old_rec.ws_val;
  End If;
  If (p_rec.ws_mn_val = hr_api.g_number) then
    p_rec.ws_mn_val :=
    ben_rts_shd.g_old_rec.ws_mn_val;
  End If;
  If (p_rec.ws_mx_val = hr_api.g_number) then
    p_rec.ws_mx_val :=
    ben_rts_shd.g_old_rec.ws_mx_val;
  End If;
  If (p_rec.ws_incr_val = hr_api.g_number) then
    p_rec.ws_incr_val :=
    ben_rts_shd.g_old_rec.ws_incr_val;
  End If;
  If (p_rec.elig_sal_val = hr_api.g_number) then
    p_rec.elig_sal_val :=
    ben_rts_shd.g_old_rec.elig_sal_val;
  End If;
  If (p_rec.stat_sal_val = hr_api.g_number) then
    p_rec.stat_sal_val :=
    ben_rts_shd.g_old_rec.stat_sal_val;
  End If;
  If (p_rec.oth_comp_val = hr_api.g_number) then
    p_rec.oth_comp_val :=
    ben_rts_shd.g_old_rec.oth_comp_val;
  End If;
  If (p_rec.tot_comp_val = hr_api.g_number) then
    p_rec.tot_comp_val :=
    ben_rts_shd.g_old_rec.tot_comp_val;
  End If;
  If (p_rec.misc1_val = hr_api.g_number) then
    p_rec.misc1_val :=
    ben_rts_shd.g_old_rec.misc1_val;
  End If;
  If (p_rec.misc2_val = hr_api.g_number) then
    p_rec.misc2_val :=
    ben_rts_shd.g_old_rec.misc2_val;
  End If;
  If (p_rec.misc3_val = hr_api.g_number) then
    p_rec.misc3_val :=
    ben_rts_shd.g_old_rec.misc3_val;
  End If;
  If (p_rec.rec_val = hr_api.g_number) then
    p_rec.rec_val :=
    ben_rts_shd.g_old_rec.rec_val;
  End If;
  If (p_rec.rec_mn_val = hr_api.g_number) then
    p_rec.rec_mn_val :=
    ben_rts_shd.g_old_rec.rec_mn_val;
  End If;
  If (p_rec.rec_mx_val = hr_api.g_number) then
    p_rec.rec_mx_val :=
    ben_rts_shd.g_old_rec.rec_mx_val;
  End If;
  If (p_rec.rec_incr_val = hr_api.g_number) then
    p_rec.rec_incr_val :=
    ben_rts_shd.g_old_rec.rec_incr_val;
  End If;
  If (p_rec.ws_val_last_upd_date = hr_api.g_date) then
    p_rec.ws_val_last_upd_date :=
    ben_rts_shd.g_old_rec.ws_val_last_upd_date;
  End If;
  If (p_rec.ws_val_last_upd_by = hr_api.g_number) then
    p_rec.ws_val_last_upd_by :=
    ben_rts_shd.g_old_rec.ws_val_last_upd_by;
  End If;
  If (p_rec.pay_proposal_id = hr_api.g_number) then
    p_rec.pay_proposal_id :=
    ben_rts_shd.g_old_rec.pay_proposal_id;
  End If;
  If (p_rec.element_entry_value_id = hr_api.g_number) then
    p_rec.element_entry_value_id :=
    ben_rts_shd.g_old_rec.element_entry_value_id;
  End If;
  If (p_rec.inelig_rsn_cd = hr_api.g_varchar2) then
    p_rec.inelig_rsn_cd :=
    ben_rts_shd.g_old_rec.inelig_rsn_cd;
  End If;
  If (p_rec.elig_ovrid_dt = hr_api.g_date) then
    p_rec.elig_ovrid_dt :=
    ben_rts_shd.g_old_rec.elig_ovrid_dt;
  End If;
  If (p_rec.elig_ovrid_person_id = hr_api.g_number) then
    p_rec.elig_ovrid_person_id :=
    ben_rts_shd.g_old_rec.elig_ovrid_person_id;
  End If;
  If (p_rec.copy_dist_bdgt_val = hr_api.g_number) then
    p_rec.copy_dist_bdgt_val :=
    ben_rts_shd.g_old_rec.copy_dist_bdgt_val;
  End If;
  If (p_rec.copy_ws_bdgt_val = hr_api.g_number) then
    p_rec.copy_ws_bdgt_val :=
    ben_rts_shd.g_old_rec.copy_ws_bdgt_val;
  End If;
  If (p_rec.copy_rsrv_val = hr_api.g_number) then
    p_rec.copy_rsrv_val :=
    ben_rts_shd.g_old_rec.copy_rsrv_val;
  End If;
  If (p_rec.copy_dist_bdgt_mn_val = hr_api.g_number) then
    p_rec.copy_dist_bdgt_mn_val :=
    ben_rts_shd.g_old_rec.copy_dist_bdgt_mn_val;
  End If;
  If (p_rec.copy_dist_bdgt_mx_val = hr_api.g_number) then
    p_rec.copy_dist_bdgt_mx_val :=
    ben_rts_shd.g_old_rec.copy_dist_bdgt_mx_val;
  End If;
  If (p_rec.copy_dist_bdgt_incr_val = hr_api.g_number) then
    p_rec.copy_dist_bdgt_incr_val :=
    ben_rts_shd.g_old_rec.copy_dist_bdgt_incr_val;
  End If;
  If (p_rec.copy_ws_bdgt_mn_val = hr_api.g_number) then
    p_rec.copy_ws_bdgt_mn_val :=
    ben_rts_shd.g_old_rec.copy_ws_bdgt_mn_val;
  End If;
  If (p_rec.copy_ws_bdgt_mx_val = hr_api.g_number) then
    p_rec.copy_ws_bdgt_mx_val :=
    ben_rts_shd.g_old_rec.copy_ws_bdgt_mx_val;
  End If;
  If (p_rec.copy_ws_bdgt_incr_val = hr_api.g_number) then
    p_rec.copy_ws_bdgt_incr_val :=
    ben_rts_shd.g_old_rec.copy_ws_bdgt_incr_val;
  End If;
  If (p_rec.copy_rsrv_mn_val = hr_api.g_number) then
    p_rec.copy_rsrv_mn_val :=
    ben_rts_shd.g_old_rec.copy_rsrv_mn_val;
  End If;
  If (p_rec.copy_rsrv_mx_val = hr_api.g_number) then
    p_rec.copy_rsrv_mx_val :=
    ben_rts_shd.g_old_rec.copy_rsrv_mx_val;
  End If;
  If (p_rec.copy_rsrv_incr_val = hr_api.g_number) then
    p_rec.copy_rsrv_incr_val :=
    ben_rts_shd.g_old_rec.copy_rsrv_incr_val;
  End If;
  If (p_rec.copy_dist_bdgt_iss_val = hr_api.g_number) then
    p_rec.copy_dist_bdgt_iss_val :=
    ben_rts_shd.g_old_rec.copy_dist_bdgt_iss_val;
  End If;
  If (p_rec.copy_ws_bdgt_iss_val = hr_api.g_number) then
    p_rec.copy_ws_bdgt_iss_val :=
    ben_rts_shd.g_old_rec.copy_ws_bdgt_iss_val;
  End If;
  If (p_rec.copy_dist_bdgt_iss_date = hr_api.g_date) then
    p_rec.copy_dist_bdgt_iss_date :=
    ben_rts_shd.g_old_rec.copy_dist_bdgt_iss_date;
  End If;
  If (p_rec.copy_ws_bdgt_iss_date = hr_api.g_date) then
    p_rec.copy_ws_bdgt_iss_date :=
    ben_rts_shd.g_old_rec.copy_ws_bdgt_iss_date;
  End If;
  If (p_rec.comp_posting_date = hr_api.g_date) then
    p_rec.comp_posting_date :=
    ben_rts_shd.g_old_rec.comp_posting_date;
  End If;
  If (p_rec.ws_rt_start_date = hr_api.g_date) then
    p_rec.ws_rt_start_date :=
    ben_rts_shd.g_old_rec.ws_rt_start_date;
  End If;
  If (p_rec.currency = hr_api.g_varchar2) then
    p_rec.currency :=
    ben_rts_shd.g_old_rec.currency;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy ben_rts_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- We must lock the row which we need to update.
  --
  ben_rts_shd.lck
    (p_rec.group_per_in_ler_id
    ,p_rec.pl_id
    ,p_rec.oipl_id
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
  ben_rts_bus.update_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  ben_rts_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  ben_rts_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  ben_rts_upd.post_update
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
  (p_group_per_in_ler_id          in     number
  ,p_pl_id                        in     number
  ,p_oipl_id                      in     number
  ,p_object_version_number        in out nocopy number
  ,p_group_pl_id                  in     number    default hr_api.g_number
  ,p_group_oipl_id                in     number    default hr_api.g_number
  ,p_lf_evt_ocrd_dt               in     date      default hr_api.g_date
  ,p_person_id                    in     number    default hr_api.g_number
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_elig_flag                    in     varchar2  default hr_api.g_varchar2
  ,p_ws_val                       in     number    default hr_api.g_number
  ,p_ws_mn_val                    in     number    default hr_api.g_number
  ,p_ws_mx_val                    in     number    default hr_api.g_number
  ,p_ws_incr_val                  in     number    default hr_api.g_number
  ,p_elig_sal_val                 in     number    default hr_api.g_number
  ,p_stat_sal_val                 in     number    default hr_api.g_number
  ,p_oth_comp_val                 in     number    default hr_api.g_number
  ,p_tot_comp_val                 in     number    default hr_api.g_number
  ,p_misc1_val                    in     number    default hr_api.g_number
  ,p_misc2_val                    in     number    default hr_api.g_number
  ,p_misc3_val                    in     number    default hr_api.g_number
  ,p_rec_val                      in     number    default hr_api.g_number
  ,p_rec_mn_val                   in     number    default hr_api.g_number
  ,p_rec_mx_val                   in     number    default hr_api.g_number
  ,p_rec_incr_val                 in     number    default hr_api.g_number
  ,p_ws_val_last_upd_date         in     date      default hr_api.g_date
  ,p_ws_val_last_upd_by           in     number    default hr_api.g_number
  ,p_pay_proposal_id              in     number    default hr_api.g_number
  ,p_element_entry_value_id       in     number    default hr_api.g_number
  ,p_inelig_rsn_cd                in     varchar2  default hr_api.g_varchar2
  ,p_elig_ovrid_dt                in     date      default hr_api.g_date
  ,p_elig_ovrid_person_id         in     number    default hr_api.g_number
  ,p_copy_dist_bdgt_val           in     number    default hr_api.g_number
  ,p_copy_ws_bdgt_val             in     number    default hr_api.g_number
  ,p_copy_rsrv_val                in     number    default hr_api.g_number
  ,p_copy_dist_bdgt_mn_val        in     number    default hr_api.g_number
  ,p_copy_dist_bdgt_mx_val        in     number    default hr_api.g_number
  ,p_copy_dist_bdgt_incr_val      in     number    default hr_api.g_number
  ,p_copy_ws_bdgt_mn_val          in     number    default hr_api.g_number
  ,p_copy_ws_bdgt_mx_val          in     number    default hr_api.g_number
  ,p_copy_ws_bdgt_incr_val        in     number    default hr_api.g_number
  ,p_copy_rsrv_mn_val             in     number    default hr_api.g_number
  ,p_copy_rsrv_mx_val             in     number    default hr_api.g_number
  ,p_copy_rsrv_incr_val           in     number    default hr_api.g_number
  ,p_copy_dist_bdgt_iss_val       in     number    default hr_api.g_number
  ,p_copy_ws_bdgt_iss_val         in     number    default hr_api.g_number
  ,p_copy_dist_bdgt_iss_date      in     date      default hr_api.g_date
  ,p_copy_ws_bdgt_iss_date        in     date      default hr_api.g_date
  ,p_comp_posting_date            in     date      default hr_api.g_date
  ,p_ws_rt_start_date             in     date      default hr_api.g_date
  ,p_currency                     in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec   ben_rts_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ben_rts_shd.convert_args
  (null   -- p_person_rate_id
  ,p_group_per_in_ler_id
  ,p_pl_id
  ,p_oipl_id
  ,p_group_pl_id
  ,p_group_oipl_id
  ,p_lf_evt_ocrd_dt
  ,p_person_id
  ,p_assignment_id
  ,p_elig_flag
  ,p_ws_val
  ,p_ws_mn_val
  ,p_ws_mx_val
  ,p_ws_incr_val
  ,p_elig_sal_val
  ,p_stat_sal_val
  ,p_oth_comp_val
  ,p_tot_comp_val
  ,p_misc1_val
  ,p_misc2_val
  ,p_misc3_val
  ,p_rec_val
  ,p_rec_mn_val
  ,p_rec_mx_val
  ,p_rec_incr_val
  ,p_ws_val_last_upd_date
  ,p_ws_val_last_upd_by
  ,p_pay_proposal_id
  ,p_element_entry_value_id
  ,p_inelig_rsn_cd
  ,p_elig_ovrid_dt
  ,p_elig_ovrid_person_id
  ,p_copy_dist_bdgt_val
  ,p_copy_ws_bdgt_val
  ,p_copy_rsrv_val
  ,p_copy_dist_bdgt_mn_val
  ,p_copy_dist_bdgt_mx_val
  ,p_copy_dist_bdgt_incr_val
  ,p_copy_ws_bdgt_mn_val
  ,p_copy_ws_bdgt_mx_val
  ,p_copy_ws_bdgt_incr_val
  ,p_copy_rsrv_mn_val
  ,p_copy_rsrv_mx_val
  ,p_copy_rsrv_incr_val
  ,p_copy_dist_bdgt_iss_val
  ,p_copy_ws_bdgt_iss_val
  ,p_copy_dist_bdgt_iss_date
  ,p_copy_ws_bdgt_iss_date
  ,p_comp_posting_date
  ,p_ws_rt_start_date
  ,p_currency
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ben_rts_upd.upd
     (l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End upd;
--
end ben_rts_upd;

/
