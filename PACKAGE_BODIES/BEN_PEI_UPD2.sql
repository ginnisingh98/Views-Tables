--------------------------------------------------------
--  DDL for Package Body BEN_PEI_UPD2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PEI_UPD2" as
/* $Header: bepeirhi.pkb 120.0 2005/05/28 10:33:49 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_pei_upd2.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure convert_defs(p_rec in out nocopy ben_pei_shd.g_rec_type) is
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
  If (p_rec.pl_id = hr_api.g_number) then
      p_rec.pl_id :=
      ben_pei_shd.g_old_rec.pl_id;
  End If;
  If (p_rec.plip_id = hr_api.g_number) then
      p_rec.plip_id :=
      ben_pei_shd.g_old_rec.plip_id;
  End If;
  If (p_rec.oipl_id = hr_api.g_number) then
      p_rec.oipl_id :=
      ben_pei_shd.g_old_rec.oipl_id;
  End If;
  If (p_rec.third_party_identifier = hr_api.g_varchar2) then
      p_rec.third_party_identifier :=
      ben_pei_shd.g_old_rec.third_party_identifier;
  End If;
  If (p_rec.organization_id = hr_api.g_number) then
      p_rec.organization_id :=
      ben_pei_shd.g_old_rec.organization_id;
  End If;
  If (p_rec.job_id = hr_api.g_number) then
      p_rec.job_id :=
      ben_pei_shd.g_old_rec.job_id;
  End If;
  If (p_rec.position_id = hr_api.g_number) then
      p_rec.position_id :=
      ben_pei_shd.g_old_rec.position_id;
  End If;
  If (p_rec.people_group_id = hr_api.g_number) then
      p_rec.people_group_id :=
      ben_pei_shd.g_old_rec.people_group_id;
  End If;
  If (p_rec.grade_id = hr_api.g_number) then
      p_rec.grade_id :=
      ben_pei_shd.g_old_rec.grade_id;
  End If;
  If (p_rec.payroll_id = hr_api.g_number) then
      p_rec.payroll_id :=
      ben_pei_shd.g_old_rec.payroll_id;
  End If;
  If (p_rec.home_state = hr_api.g_varchar2) then
      p_rec.home_state :=
      ben_pei_shd.g_old_rec.home_state;
  End If;
  If (p_rec.home_zip = hr_api.g_varchar2) then
      p_rec.home_zip :=
      ben_pei_shd.g_old_rec.home_zip;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
      p_rec.business_group_id :=
      ben_pei_shd.g_old_rec.business_group_id;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End convert_defs;
--
end ben_pei_upd2;

/
