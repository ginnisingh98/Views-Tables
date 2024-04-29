--------------------------------------------------------
--  DDL for Package Body PQH_RLS_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RLS_UPD" as
/* $Header: pqrlsrhi.pkb 115.21 2004/02/18 12:06:25 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_rls_upd.';  -- Global package name
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
--   If a check,unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported,the error will be raised after the
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
  ( p_rec in out NOCOPY pqh_rls_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- Increment the object version
  p_rec.object_version_number :=p_rec.object_version_number + 1;
  --
  --
  --
  -- Update the pqh_roles Row
  --
  -- mvankada
  -- Added Developer DF Columns to update stmt
    update pqh_roles
      set
       role_id                         = p_rec.role_id
      ,role_name                       = p_rec.role_name
      ,role_type_cd                    = p_rec.role_type_cd
      ,enable_flag                     = p_rec.enable_flag
      ,object_version_number           = p_rec.object_version_number
      ,business_group_id               = p_rec.business_group_id
  ,information_category       = p_rec.information_category
  ,information1	              = p_rec.information1
  ,information2	              = p_rec.information2
  ,information3	    	      = p_rec.information3
  ,information4	     	      = p_rec.information4
  ,information5	     	      = p_rec.information5
  ,information6	      	      = p_rec.information6
  ,information7	    	      = p_rec.information7
  ,information8	     	      = p_rec.information8
  ,information9	     	      = p_rec.information9
  ,information10    	      = p_rec.information10
  ,information11     	      = p_rec.information11
  ,information12    	      = p_rec.information12
  ,information13    	      = p_rec.information13
  ,information14    	      = p_rec.information14
  ,information15   	      = p_rec.information15
  ,information16   	      = p_rec.information16
  ,information17   	      = p_rec.information17
  ,information18     	      = p_rec.information18
  ,information19    	      = p_rec.information19
  ,information20     	      = p_rec.information20
  ,information21     	      = p_rec.information21
  ,information22    	      = p_rec.information22
  ,information23    	      = p_rec.information23
  ,information24    	      = p_rec.information24
  ,information25   	      = p_rec.information25
  ,information26   	      = p_rec.information26
  ,information27   	      = p_rec.information27
  ,information28     	      = p_rec.information28
  ,information29    	      = p_rec.information29
  ,information30     	      = p_rec.information30
   where role_id = p_rec.role_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc,10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    pqh_rls_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    pqh_rls_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    pqh_rls_shd.constraint_error
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
--   If an error has occurred,an error message and exception wil be raised
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
  ( p_rec in pqh_rls_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  hr_utility.set_location(' Leaving:'||l_proc,10);
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
--   If an error has occurred,an error message and exception will be raised
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

-- mvankada
-- Added Developer DF columns
Procedure post_update
  (p_effective_date               in date
  ,p_rec                        in pqh_rls_shd.g_rec_type
  ) is
--
  l_start_date         date := trunc(sysdate);
  l_expiration_date    date := to_date('31/12/4712','DD/MM/RRRR');
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc,5);
  begin
    --
    pqh_rls_rku.after_update
    (p_effective_date         => p_effective_date
    ,p_role_id                => p_rec.role_id
    ,p_role_name              => p_rec.role_name
    ,p_role_type_cd           => p_rec.role_type_cd
    ,p_enable_flag            => p_rec.enable_flag
    ,p_object_version_number  => p_rec.object_version_number
    ,p_business_group_id      => p_rec.business_group_id
    ,p_information_category   => p_rec.information_category
    ,p_information1	      => p_rec.information1
    ,p_information2	      => p_rec.information2
    ,p_information3	      => p_rec.information3
    ,p_information4	      => p_rec.information4
    ,p_information5	      => p_rec.information5
    ,p_information6	      => p_rec.information6
    ,p_information7	      => p_rec.information7
    ,p_information8	      => p_rec.information8
    ,p_information9	      => p_rec.information9
    ,p_information10          => p_rec.information10
    ,p_information11          => p_rec.information11
    ,p_information12          => p_rec.information12
    ,p_information13          => p_rec.information13
    ,p_information14          => p_rec.information14
    ,p_information15          => p_rec.information15
    ,p_information16          => p_rec.information16
    ,p_information17          => p_rec.information17
    ,p_information18          => p_rec.information18
    ,p_information19          => p_rec.information19
    ,p_information20          => p_rec.information20
    ,p_information21          => p_rec.information21
    ,p_information22          => p_rec.information22
    ,p_information23          => p_rec.information23
    ,p_information24          => p_rec.information24
    ,p_information25          => p_rec.information25
    ,p_information26          => p_rec.information26
    ,p_information27          => p_rec.information27
    ,p_information28          => p_rec.information28
    ,p_information29          => p_rec.information29
    ,p_information30          => p_rec.information30
    ,p_role_name_o            => pqh_rls_shd.g_old_rec.role_name
    ,p_role_type_cd_o         => pqh_rls_shd.g_old_rec.role_type_cd
    ,p_enable_flag_o          => pqh_rls_shd.g_old_rec.enable_flag
    ,p_object_version_number_o => pqh_rls_shd.g_old_rec.object_version_number
    ,p_business_group_id_o    => pqh_rls_shd.g_old_rec.business_group_id
    ,p_information_category_o => pqh_rls_shd.g_old_rec.information_category
    ,p_information1_o	      => pqh_rls_shd.g_old_rec.information1
    ,p_information2_o	      => pqh_rls_shd.g_old_rec.information2
    ,p_information3_o	      => pqh_rls_shd.g_old_rec.information3
    ,p_information4_o	      => pqh_rls_shd.g_old_rec.information4
    ,p_information5_o	      => pqh_rls_shd.g_old_rec.information5
    ,p_information6_o	      => pqh_rls_shd.g_old_rec.information6
    ,p_information7_o	      => pqh_rls_shd.g_old_rec.information7
    ,p_information8_o	      => pqh_rls_shd.g_old_rec.information8
    ,p_information9_o	      => pqh_rls_shd.g_old_rec.information9
    ,p_information10_o	      => pqh_rls_shd.g_old_rec.information10
    ,p_information11_o	      => pqh_rls_shd.g_old_rec.information11
    ,p_information12_o	      => pqh_rls_shd.g_old_rec.information12
    ,p_information13_o	      => pqh_rls_shd.g_old_rec.information13
    ,p_information14_o	      => pqh_rls_shd.g_old_rec.information14
    ,p_information15_o	      => pqh_rls_shd.g_old_rec.information15
    ,p_information16_o	      => pqh_rls_shd.g_old_rec.information16
    ,p_information17_o	      => pqh_rls_shd.g_old_rec.information17
    ,p_information18_o	      => pqh_rls_shd.g_old_rec.information18
    ,p_information19_o	      => pqh_rls_shd.g_old_rec.information19
    ,p_information20_o	      => pqh_rls_shd.g_old_rec.information20
    ,p_information21_o	      => pqh_rls_shd.g_old_rec.information21
    ,p_information22_o	      => pqh_rls_shd.g_old_rec.information22
    ,p_information23_o	      => pqh_rls_shd.g_old_rec.information23
    ,p_information24_o	      => pqh_rls_shd.g_old_rec.information24
    ,p_information25_o	      => pqh_rls_shd.g_old_rec.information25
    ,p_information26_o	      => pqh_rls_shd.g_old_rec.information26
    ,p_information27_o	      => pqh_rls_shd.g_old_rec.information27
    ,p_information28_o	      => pqh_rls_shd.g_old_rec.information28
    ,p_information29_o	      => pqh_rls_shd.g_old_rec.information29
    ,p_information30_o	      => pqh_rls_shd.g_old_rec.information30
    );
    --
    if nvl(pqh_rls_shd.g_old_rec.enable_flag,'N') = 'N'
        and p_rec.enable_flag = 'Y' then
       hr_utility.set_location('Role enabled'||l_proc,10);
    declare
      l_user_name varchar2(50);
      l_plist wf_parameter_list_t;
      cursor c1 is
      select ppei.person_id,usr.user_name
      from
      per_people_extra_info ppei,
      fnd_user usr
      where
      ppei.information_type = 'PQH_ROLE_USERS'
      and ppei.PEI_INFORMATION3 = p_rec.role_id
      and ppei.PEI_INFORMATION5 = 'Y'
      and ppei.person_id = usr.employee_id;

    begin
      hr_utility.set_location('building list '||l_proc, 12);
      hr_utility.set_location('expiration date'||to_char(l_expiration_date,'dd/mm/RRRR'), 13);
      WF_EVENT.AddParameterToList('USER_NAME','PQH_ROLE:'|| p_rec.role_id, l_plist);
      WF_EVENT.AddParameterToList('DISPLAY_NAME',p_rec.role_name,l_plist);
      WF_EVENT.AddParameterToList('DESCRIPTION',p_rec.role_name,l_plist);
      WF_EVENT.AddParameterToList('orclWorkFlowNotificationPref','QUERY',l_plist);
      WF_EVENT.AddParameterToList('orclIsEnabled','ACTIVE',l_plist);
      WF_EVENT.AddParameterToList('orclWFOrigSystem','PQH_ROLE', l_plist);
      WF_EVENT.AddParameterToList('orclWFOrigSystemID',p_rec.role_id,l_plist);
      WF_EVENT.AddParameterToList('expirationdate', to_char(l_expiration_date,wf_engine.date_format),l_plist);
      WF_EVENT.AddParameterToList('RAISEERRORS','FALSE',l_plist);

      hr_utility.set_location('calling sync role '||l_proc, 14);
      WF_LOCAL_SYNCH.propagate_role(p_orig_system     => 'PQH_ROLE',
                                    p_orig_system_id  => p_rec.role_id,
                                    p_attributes      => l_plist,
                                    p_start_date      => l_start_date,
                                    p_expiration_date => l_expiration_date);

      hr_utility.set_location('sync role done'||l_proc, 15);
     for r1 in c1 loop
      l_plist := null;
      hr_utility.set_location('going persons loop '||l_proc, 17);
      WF_EVENT.AddParameterToList('expirationdate',to_char(l_expiration_date,wf_engine.date_format), l_plist);
      WF_EVENT.AddParameterToList('USER_NAME',r1.user_name,l_plist);
      WF_EVENT.AddParameterToList('orclIsEnabled','ACTIVE',l_plist);
      WF_EVENT.AddParameterToList('ExpirationDate',to_char(l_expiration_date,wf_engine.date_format),l_plist);
      WF_EVENT.AddParameterToList('StartDate',to_char(l_start_date,wf_engine.date_format),l_plist);
      WF_EVENT.AddParameterToList('RaiseErrorS','FALSE',l_plist);
      hr_utility.set_location('calling sync user '||l_proc, 19);
      WF_LOCAL_SYNCH.propagate_user_role(p_user_orig_system     => 'PER',
                                         p_user_orig_system_id  => r1.person_id,
                                         p_role_orig_system     => 'PQH_ROLE',
                                         p_role_orig_system_id  => p_rec.role_id,
                                         p_start_date           => l_start_date,
                                         p_expiration_date      => l_expiration_date);
      hr_utility.set_location('sync user done'||l_proc, 21);
     end loop;
    end;
    elsif nvl(pqh_rls_shd.g_old_rec.enable_flag,'N') = 'Y'
        and p_rec.enable_flag = 'N' then
        hr_utility.set_location('role being disabled '||l_proc, 30);
    declare
      l_plist wf_parameter_list_t;
      --
      cursor c0 is
      select *
      from wf_local_user_roles
      where ROLE_ORIG_SYSTEM = 'PQH_ROLE'
      and ROLE_ORIG_SYSTEM_ID = p_rec.role_id;
      --
    begin
       l_plist := null;
       hr_utility.set_location('building list'||l_proc, 32);
     wf_event.AddParameterToList( 'USER_NAME', 'PQH_ROLE:'|| p_rec.role_id, l_plist);
     wf_event.AddParameterToList( 'DELETE', 'TRUE', l_plist);
     wf_event.AddParameterToList( 'EXPIRATIONDATE', to_char(l_start_date,wf_engine.date_format), l_plist);
      WF_EVENT.AddParameterToList('RaiseErrorS','FALSE',l_plist);
     for r1 in c0 loop
        hr_utility.set_location('calling sync user '||l_proc, 34);
        -- setting the expiration date to today
        WF_LOCAL_SYNCH.propagate_user_role(p_user_orig_system      => 'PER',
                              p_user_orig_system_id   => r1.user_orig_system_id,
                              p_role_orig_system      => 'PQH_ROLE',
                              p_role_orig_system_id   => p_rec.role_id,
                              p_expiration_date       => l_start_date);
        hr_utility.set_location('sync user done'||l_proc, 36);
     end loop;
     l_plist := null;
     wf_event.AddParameterToList('USER_NAME', 'PQH_ROLE:'|| p_rec.role_id, l_plist);
     wf_event.AddParameterToList('EXPIRATIONDATE', to_char(p_effective_date,wf_engine.date_format), l_plist);
     wf_event.AddParameterToList('DELETE', 'TRUE', l_plist);
     WF_EVENT.AddParameterToList('RaiseErrorS','FALSE',l_plist);
     hr_utility.set_location('calling sync role '||l_proc, 38);
     WF_LOCAL_SYNCH.propagate_role(p_orig_system     => 'PQH_ROLE',
                                   p_orig_system_id  => p_rec.role_id,
                                   p_attributes      => l_plist,
                                   p_expiration_date => p_effective_date);
     hr_utility.set_location('sync role done'||l_proc, 40);
    end;
    end if;
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_update;
--
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
--   we attempt to update a row through the Upd process ,certain
--   parameters can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd process to determine which attributes
--   have NOT been specified we need to check if the parameter has a reserved
--   system default value. Therefore,for all parameters which have a
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
  ( p_rec in out NOCOPY pqh_rls_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  --  plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.role_name = hr_api.g_varchar2) then
    p_rec.role_name :=
    pqh_rls_shd.g_old_rec.role_name;
  End If;
  If (p_rec.role_type_cd = hr_api.g_varchar2) then
    p_rec.role_type_cd :=
    pqh_rls_shd.g_old_rec.role_type_cd;
  End If;
  If (p_rec.enable_flag = hr_api.g_varchar2) then
    p_rec.enable_flag :=
    pqh_rls_shd.g_old_rec.enable_flag;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    pqh_rls_shd.g_old_rec.business_group_id;
  End If;
  --
  -- mvankada
  -- For Developer DF columns

  If (p_rec.information_category = hr_api.g_varchar2) then
    p_rec.information_category :=
    pqh_rls_shd.g_old_rec.information_category;
  End If;
  If (p_rec.information1 = hr_api.g_varchar2) then
    p_rec.information1 :=
    pqh_rls_shd.g_old_rec.information1;
  End If;
  If (p_rec.information2 = hr_api.g_varchar2) then
    p_rec.information2 :=
    pqh_rls_shd.g_old_rec.information2;
  End If;
  If (p_rec.information3 = hr_api.g_varchar2) then
    p_rec.information3 :=
    pqh_rls_shd.g_old_rec.information3;
  End If;
  If (p_rec.information4 = hr_api.g_varchar2) then
    p_rec.information4 :=
    pqh_rls_shd.g_old_rec.information4;
  End If;
  If (p_rec.information5 = hr_api.g_varchar2) then
    p_rec.information5 :=
    pqh_rls_shd.g_old_rec.information5;
  End If;
  If (p_rec.information6 = hr_api.g_varchar2) then
    p_rec.information6 :=
    pqh_rls_shd.g_old_rec.information6;
  End If;
  If (p_rec.information7 = hr_api.g_varchar2) then
    p_rec.information7 :=
    pqh_rls_shd.g_old_rec.information7;
  End If;
  If (p_rec.information8 = hr_api.g_varchar2) then
    p_rec.information8 :=
    pqh_rls_shd.g_old_rec.information8;
  End If;
  If (p_rec.information9 = hr_api.g_varchar2) then
    p_rec.information9 :=
    pqh_rls_shd.g_old_rec.information9;
  End If;
  If (p_rec.information10 = hr_api.g_varchar2) then
    p_rec.information10 :=
    pqh_rls_shd.g_old_rec.information10;
  End If;
  If (p_rec.information11 = hr_api.g_varchar2) then
    p_rec.information11 :=
    pqh_rls_shd.g_old_rec.information11;
  End If;
  If (p_rec.information12 = hr_api.g_varchar2) then
    p_rec.information12 :=
    pqh_rls_shd.g_old_rec.information12;
  End If;
  If (p_rec.information13 = hr_api.g_varchar2) then
    p_rec.information13 :=
    pqh_rls_shd.g_old_rec.information13;
  End If;
  If (p_rec.information14 = hr_api.g_varchar2) then
    p_rec.information14 :=
    pqh_rls_shd.g_old_rec.information14;
  End If;
  If (p_rec.information15 = hr_api.g_varchar2) then
    p_rec.information15 :=
    pqh_rls_shd.g_old_rec.information15;
  End If;
  If (p_rec.information16 = hr_api.g_varchar2) then
    p_rec.information16 :=
    pqh_rls_shd.g_old_rec.information16;
  End If;
  If (p_rec.information17 = hr_api.g_varchar2) then
    p_rec.information17 :=
    pqh_rls_shd.g_old_rec.information17;
  End If;
  If (p_rec.information18 = hr_api.g_varchar2) then
    p_rec.information18 :=
    pqh_rls_shd.g_old_rec.information18;
  End If;
  If (p_rec.information19 = hr_api.g_varchar2) then
    p_rec.information19 :=
    pqh_rls_shd.g_old_rec.information19;
  End If;
  If (p_rec.information20 = hr_api.g_varchar2) then
    p_rec.information20 :=
    pqh_rls_shd.g_old_rec.information20;
  End If;
  If (p_rec.information21 = hr_api.g_varchar2) then
    p_rec.information21 :=
    pqh_rls_shd.g_old_rec.information21;
  End If;
  If (p_rec.information22 = hr_api.g_varchar2) then
    p_rec.information22 :=
    pqh_rls_shd.g_old_rec.information22;
  End If;
  If (p_rec.information23 = hr_api.g_varchar2) then
    p_rec.information23 :=
    pqh_rls_shd.g_old_rec.information23;
  End If;
  If (p_rec.information24 = hr_api.g_varchar2) then
    p_rec.information24 :=
    pqh_rls_shd.g_old_rec.information24;
  End If;
  If (p_rec.information25 = hr_api.g_varchar2) then
    p_rec.information25 :=
    pqh_rls_shd.g_old_rec.information25;
  End If;
  If (p_rec.information26 = hr_api.g_varchar2) then
    p_rec.information26 :=
    pqh_rls_shd.g_old_rec.information26;
  End If;
  If (p_rec.information27 = hr_api.g_varchar2) then
    p_rec.information27 :=
    pqh_rls_shd.g_old_rec.information27;
  End If;
  If (p_rec.information28 = hr_api.g_varchar2) then
    p_rec.information28 :=
    pqh_rls_shd.g_old_rec.information28;
  End If;
  If (p_rec.information29 = hr_api.g_varchar2) then
    p_rec.information29 :=
    pqh_rls_shd.g_old_rec.information29;
  End If;
  If (p_rec.information30 = hr_api.g_varchar2) then
    p_rec.information30 :=
    pqh_rls_shd.g_old_rec.information30;
  End If;

End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out NOCOPY pqh_rls_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- We must lock the row which we need to update.
  --
  pqh_rls_shd.lck
    (p_rec.role_id
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
  pqh_rls_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call the supporting pre-update operation
  --
  pqh_rls_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  pqh_rls_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  pqh_rls_upd.post_update
     (p_effective_date
     ,p_rec
     );
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------

-- mvankada
-- Passed  Developer DF columns as arguments for upd procedure

Procedure upd
  (p_effective_date          in    date
  ,p_role_id                 in    number
  ,p_object_version_number  in out NOCOPY number
  ,p_role_name              in varchar2
  ,p_business_group_id      in number
  ,p_role_type_cd           in varchar2
  ,p_enable_flag            in varchar2
  ,p_information_category   in varchar2
  ,p_information1           in varchar2
  ,p_information2           in varchar2
  ,p_information3           in varchar2
  ,p_information4           in varchar2
  ,p_information5           in varchar2
  ,p_information6           in varchar2
  ,p_information7           in varchar2
  ,p_information8           in varchar2
  ,p_information9           in varchar2
  ,p_information10          in varchar2
  ,p_information11          in varchar2
  ,p_information12          in varchar2
  ,p_information13          in varchar2
  ,p_information14          in varchar2
  ,p_information15          in varchar2
  ,p_information16          in varchar2
  ,p_information17          in varchar2
  ,p_information18          in varchar2
  ,p_information19          in varchar2
  ,p_information20          in varchar2
  ,p_information21          in varchar2
  ,p_information22          in varchar2
  ,p_information23          in varchar2
  ,p_information24          in varchar2
  ,p_information25          in varchar2
  ,p_information26          in varchar2
  ,p_information27          in varchar2
  ,p_information28          in varchar2
  ,p_information29          in varchar2
  ,p_information30          in varchar2
  ) is
--
  l_rec	  pqh_rls_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  -- mvanakda
  -- Added DDF Columns
  l_rec :=
  pqh_rls_shd.convert_args
  (p_role_id
  ,p_role_name
  ,p_role_type_cd
  ,p_enable_flag
  ,p_object_version_number
  ,p_business_group_id
  ,p_information_category
  ,p_information1
  ,p_information2
  ,p_information3
  ,p_information4
  ,p_information5
  ,p_information6
  ,p_information7
  ,p_information8
  ,p_information9
  ,p_information10
  ,p_information11
  ,p_information12
  ,p_information13
  ,p_information14
  ,p_information15
  ,p_information16
  ,p_information17
  ,p_information18
  ,p_information19
  ,p_information20
  ,p_information21
  ,p_information22
  ,p_information23
  ,p_information24
  ,p_information25
  ,p_information26
  ,p_information27
  ,p_information28
  ,p_information29
  ,p_information30
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pqh_rls_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc,10);
End upd;
--
end pqh_rls_upd;

/
