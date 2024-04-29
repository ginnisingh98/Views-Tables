--------------------------------------------------------
--  DDL for Package Body PE_PEI_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PE_PEI_UPD" as
/* $Header: pepeirhi.pkb 120.1 2005/07/25 05:01:42 jpthomas noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pe_pei_upd.';  -- Global package name
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
--   (Note: Sue 1/29/97 Removed the need for setting g_api_dml as this is a new
--    table and therefore there is no ovn trigger to use it).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Pre Conditions:
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
--   (Note: Sue 1/29/97 Removed the need for setting g_api_dml as this is a new
--    table and therefore there is no ovn trigger to use it).
--
-- Developer Implementation Notes:
--   The update 'set' attribute list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml(p_rec in out NOCOPY pe_pei_shd.g_rec_type) is
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
  -- Update the per_people_extra_info Row
  --
  update per_people_extra_info
  set
  person_extra_info_id              = p_rec.person_extra_info_id,
  request_id                        = p_rec.request_id,
  program_application_id            = p_rec.program_application_id,
  program_id                        = p_rec.program_id,
  program_update_date               = p_rec.program_update_date,
  pei_attribute_category            = p_rec.pei_attribute_category,
  pei_attribute1                    = p_rec.pei_attribute1,
  pei_attribute2                    = p_rec.pei_attribute2,
  pei_attribute3                    = p_rec.pei_attribute3,
  pei_attribute4                    = p_rec.pei_attribute4,
  pei_attribute5                    = p_rec.pei_attribute5,
  pei_attribute6                    = p_rec.pei_attribute6,
  pei_attribute7                    = p_rec.pei_attribute7,
  pei_attribute8                    = p_rec.pei_attribute8,
  pei_attribute9                    = p_rec.pei_attribute9,
  pei_attribute10                   = p_rec.pei_attribute10,
  pei_attribute11                   = p_rec.pei_attribute11,
  pei_attribute12                   = p_rec.pei_attribute12,
  pei_attribute13                   = p_rec.pei_attribute13,
  pei_attribute14                   = p_rec.pei_attribute14,
  pei_attribute15                   = p_rec.pei_attribute15,
  pei_attribute16                   = p_rec.pei_attribute16,
  pei_attribute17                   = p_rec.pei_attribute17,
  pei_attribute18                   = p_rec.pei_attribute18,
  pei_attribute19                   = p_rec.pei_attribute19,
  pei_attribute20                   = p_rec.pei_attribute20,
  pei_information_category          = p_rec.pei_information_category,
  pei_information1                  = p_rec.pei_information1,
  pei_information2                  = p_rec.pei_information2,
  pei_information3                  = p_rec.pei_information3,
  pei_information4                  = p_rec.pei_information4,
  pei_information5                  = p_rec.pei_information5,
  pei_information6                  = p_rec.pei_information6,
  pei_information7                  = p_rec.pei_information7,
  pei_information8                  = p_rec.pei_information8,
  pei_information9                  = p_rec.pei_information9,
  pei_information10                 = p_rec.pei_information10,
  pei_information11                 = p_rec.pei_information11,
  pei_information12                 = p_rec.pei_information12,
  pei_information13                 = p_rec.pei_information13,
  pei_information14                 = p_rec.pei_information14,
  pei_information15                 = p_rec.pei_information15,
  pei_information16                 = p_rec.pei_information16,
  pei_information17                 = p_rec.pei_information17,
  pei_information18                 = p_rec.pei_information18,
  pei_information19                 = p_rec.pei_information19,
  pei_information20                 = p_rec.pei_information20,
  pei_information21                 = p_rec.pei_information21,
  pei_information22                 = p_rec.pei_information22,
  pei_information23                 = p_rec.pei_information23,
  pei_information24                 = p_rec.pei_information24,
  pei_information25                 = p_rec.pei_information25,
  pei_information26                 = p_rec.pei_information26,
  pei_information27                 = p_rec.pei_information27,
  pei_information28                 = p_rec.pei_information28,
  pei_information29                 = p_rec.pei_information29,
  pei_information30                 = p_rec.pei_information30,
  object_version_number             = p_rec.object_version_number
  where person_extra_info_id = p_rec.person_extra_info_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pe_pei_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pe_pei_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pe_pei_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
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
-- Pre Conditions:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update(p_rec in pe_pei_shd.g_rec_type) is
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
-- Pre Conditions:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update(p_rec in pe_pei_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_update';
  l_eot   date         := to_date('31/12/4712','dd/mm/yyyy');
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- This is a hook point and the user hook for post_update is called here.
  --
  begin
     pe_pei_rku.after_update	(
	p_person_extra_info_id		=>	p_rec.person_extra_info_id	,
	p_person_id			=>	p_rec.person_id			,
	p_information_type		=>	p_rec.information_type		,
	p_request_id			=>	p_rec.request_id			,
	p_program_application_id	=>	p_rec.program_application_id	,
	p_program_id			=>	p_rec.program_id			,
	p_program_update_date		=>	p_rec.program_update_date	,
	p_pei_attribute_category	=>	p_rec.pei_attribute_category	,
	p_pei_attribute1		=>	p_rec.pei_attribute1		,
	p_pei_attribute2		=>	p_rec.pei_attribute2		,
	p_pei_attribute3		=>	p_rec.pei_attribute3		,
	p_pei_attribute4		=>	p_rec.pei_attribute4		,
	p_pei_attribute5		=>	p_rec.pei_attribute5		,
	p_pei_attribute6		=>	p_rec.pei_attribute6		,
	p_pei_attribute7		=>	p_rec.pei_attribute7		,
	p_pei_attribute8		=>	p_rec.pei_attribute8		,
	p_pei_attribute9		=>	p_rec.pei_attribute9		,
	p_pei_attribute10		=>	p_rec.pei_attribute10		,
	p_pei_attribute11		=>	p_rec.pei_attribute11		,
	p_pei_attribute12		=>	p_rec.pei_attribute12		,
	p_pei_attribute13		=>	p_rec.pei_attribute13		,
	p_pei_attribute14		=>	p_rec.pei_attribute14		,
	p_pei_attribute15		=>	p_rec.pei_attribute15		,
	p_pei_attribute16		=>	p_rec.pei_attribute16		,
	p_pei_attribute17		=>	p_rec.pei_attribute17		,
	p_pei_attribute18		=>	p_rec.pei_attribute18		,
	p_pei_attribute19		=>	p_rec.pei_attribute19		,
	p_pei_attribute20		=>	p_rec.pei_attribute20		,
	p_pei_information_category	=>	p_rec.pei_information_category,
	p_pei_information1		=>	p_rec.pei_information1		,
	p_pei_information2		=>	p_rec.pei_information2		,
	p_pei_information3		=>	p_rec.pei_information3		,
	p_pei_information4		=>	p_rec.pei_information4		,
	p_pei_information5		=>	p_rec.pei_information5		,
	p_pei_information6		=>	p_rec.pei_information6		,
	p_pei_information7		=>	p_rec.pei_information7		,
	p_pei_information8		=>	p_rec.pei_information8		,
	p_pei_information9		=>	p_rec.pei_information9		,
	p_pei_information10		=>	p_rec.pei_information10		,
	p_pei_information11		=>	p_rec.pei_information11		,
	p_pei_information12		=>	p_rec.pei_information12		,
	p_pei_information13		=>	p_rec.pei_information13		,
	p_pei_information14		=>	p_rec.pei_information14		,
	p_pei_information15		=>	p_rec.pei_information15		,
	p_pei_information16		=>	p_rec.pei_information16		,
	p_pei_information17		=>	p_rec.pei_information17		,
	p_pei_information18		=>	p_rec.pei_information18		,
	p_pei_information19		=>	p_rec.pei_information19		,
	p_pei_information20		=>	p_rec.pei_information20		,
	p_pei_information21		=>	p_rec.pei_information21		,
	p_pei_information22		=>	p_rec.pei_information22		,
	p_pei_information23		=>	p_rec.pei_information23		,
	p_pei_information24		=>	p_rec.pei_information24		,
	p_pei_information25		=>	p_rec.pei_information25		,
	p_pei_information26		=>	p_rec.pei_information26		,
	p_pei_information27		=>	p_rec.pei_information27		,
	p_pei_information28		=>	p_rec.pei_information28		,
	p_pei_information29		=>	p_rec.pei_information29		,
	p_pei_information30		=>	p_rec.pei_information30		,
	p_person_id_o			=>	pe_pei_shd.g_old_rec.person_id			,
	p_information_type_o		=>	pe_pei_shd.g_old_rec.information_type		,
	p_request_id_o			=>	pe_pei_shd.g_old_rec.request_id			,
	p_program_application_id_o	=>	pe_pei_shd.g_old_rec.program_application_id	,
	p_program_id_o			=>	pe_pei_shd.g_old_rec.program_id			,
	p_program_update_date_o		=>	pe_pei_shd.g_old_rec.program_update_date		,
	p_pei_attribute_category_o	=>	pe_pei_shd.g_old_rec.pei_attribute_category	,
	p_pei_attribute1_o		=>	pe_pei_shd.g_old_rec.pei_attribute1			,
	p_pei_attribute2_o		=>	pe_pei_shd.g_old_rec.pei_attribute2			,
	p_pei_attribute3_o		=>	pe_pei_shd.g_old_rec.pei_attribute3			,
	p_pei_attribute4_o		=>	pe_pei_shd.g_old_rec.pei_attribute4			,
	p_pei_attribute5_o		=>	pe_pei_shd.g_old_rec.pei_attribute5			,
	p_pei_attribute6_o		=>	pe_pei_shd.g_old_rec.pei_attribute6			,
	p_pei_attribute7_o		=>	pe_pei_shd.g_old_rec.pei_attribute7			,
	p_pei_attribute8_o		=>	pe_pei_shd.g_old_rec.pei_attribute8			,
	p_pei_attribute9_o		=>	pe_pei_shd.g_old_rec.pei_attribute9			,
	p_pei_attribute10_o		=>	pe_pei_shd.g_old_rec.pei_attribute10		,
	p_pei_attribute11_o		=>	pe_pei_shd.g_old_rec.pei_attribute11		,
	p_pei_attribute12_o		=>	pe_pei_shd.g_old_rec.pei_attribute12		,
	p_pei_attribute13_o		=>	pe_pei_shd.g_old_rec.pei_attribute13		,
	p_pei_attribute14_o		=>	pe_pei_shd.g_old_rec.pei_attribute14		,
	p_pei_attribute15_o		=>	pe_pei_shd.g_old_rec.pei_attribute15		,
	p_pei_attribute16_o		=>	pe_pei_shd.g_old_rec.pei_attribute16		,
	p_pei_attribute17_o		=>	pe_pei_shd.g_old_rec.pei_attribute17		,
	p_pei_attribute18_o		=>	pe_pei_shd.g_old_rec.pei_attribute18		,
	p_pei_attribute19_o		=>	pe_pei_shd.g_old_rec.pei_attribute19		,
	p_pei_attribute20_o		=>	pe_pei_shd.g_old_rec.pei_attribute20		,
	p_pei_information_category_o	=>	pe_pei_shd.g_old_rec.pei_information_category	,
	p_pei_information1_o		=>	pe_pei_shd.g_old_rec.pei_information1		,
	p_pei_information2_o		=>	pe_pei_shd.g_old_rec.pei_information2		,
	p_pei_information3_o		=>	pe_pei_shd.g_old_rec.pei_information3		,
	p_pei_information4_o		=>	pe_pei_shd.g_old_rec.pei_information4		,
	p_pei_information5_o		=>	pe_pei_shd.g_old_rec.pei_information5		,
	p_pei_information6_o		=>	pe_pei_shd.g_old_rec.pei_information6		,
	p_pei_information7_o		=>	pe_pei_shd.g_old_rec.pei_information7		,
	p_pei_information8_o		=>	pe_pei_shd.g_old_rec.pei_information8		,
	p_pei_information9_o		=>	pe_pei_shd.g_old_rec.pei_information9		,
	p_pei_information10_o		=>	pe_pei_shd.g_old_rec.pei_information10		,
	p_pei_information11_o		=>	pe_pei_shd.g_old_rec.pei_information11		,
	p_pei_information12_o		=>	pe_pei_shd.g_old_rec.pei_information12		,
	p_pei_information13_o		=>	pe_pei_shd.g_old_rec.pei_information13		,
	p_pei_information14_o		=>	pe_pei_shd.g_old_rec.pei_information14		,
	p_pei_information15_o		=>	pe_pei_shd.g_old_rec.pei_information15		,
	p_pei_information16_o		=>	pe_pei_shd.g_old_rec.pei_information16		,
	p_pei_information17_o		=>	pe_pei_shd.g_old_rec.pei_information17		,
	p_pei_information18_o		=>	pe_pei_shd.g_old_rec.pei_information18		,
	p_pei_information19_o		=>	pe_pei_shd.g_old_rec.pei_information19		,
	p_pei_information20_o		=>	pe_pei_shd.g_old_rec.pei_information20		,
	p_pei_information21_o		=>	pe_pei_shd.g_old_rec.pei_information21		,
	p_pei_information22_o		=>	pe_pei_shd.g_old_rec.pei_information22		,
	p_pei_information23_o		=>	pe_pei_shd.g_old_rec.pei_information23		,
	p_pei_information24_o		=>	pe_pei_shd.g_old_rec.pei_information24		,
	p_pei_information25_o		=>	pe_pei_shd.g_old_rec.pei_information25		,
	p_pei_information26_o		=>	pe_pei_shd.g_old_rec.pei_information26		,
	p_pei_information27_o		=>	pe_pei_shd.g_old_rec.pei_information27		,
	p_pei_information28_o		=>	pe_pei_shd.g_old_rec.pei_information28		,
	p_pei_information29_o		=>	pe_pei_shd.g_old_rec.pei_information29		,
	p_pei_information30_o		=>	pe_pei_shd.g_old_rec.pei_information30
	);
     exception
        when hr_api.cannot_find_prog_unit then
             hr_api.cannot_find_prog_unit_error
		 (	p_module_name => 'PER_PEOPLE_EXTRA_INFO'
			,p_hook_type  => 'AU'
	        );
  end;
  -- End of API User Hook for post_update.
  --
  --
  if p_rec.INFORMATION_TYPE = 'PQH_ROLE_USERS' then
   if nvl(pe_pei_shd.g_old_rec.pei_information5,'N') = 'N'
    and nvl(p_rec.PEI_INFORMATION5,'N') = 'Y' then
      declare
        l_user_name varchar2(50);
        l_start_date date;
        l_expiration_date date;
        cursor c1 is
        select usr.user_name, usr.start_date, nvl(usr.end_date, hr_general.end_of_time)
        from fnd_user usr
        where usr.employee_id = p_rec.person_id;
      begin
        open c1;
        fetch c1 into l_user_name, l_start_date, l_expiration_date;
        if c1%found then
          close c1;

          WF_LOCAL_SYNCH.propagate_user_role(p_user_orig_system      => 'PER',
                              p_user_orig_system_id   => p_rec.person_id,
                              p_role_orig_system      => 'PQH_ROLE',
                              p_role_orig_system_id   => p_rec.pei_information3,
                              p_start_date            => l_start_date,
                              p_expiration_date       => l_expiration_date);
        else
          close c1;
        end if;
      end;
   elsif nvl(pe_pei_shd.g_old_rec.pei_information5,'N') = 'Y'
    and nvl(p_rec.PEI_INFORMATION5,'N') = 'Y'
    and (pe_pei_shd.g_old_rec.pei_information3 <> p_rec.PEI_INFORMATION3) then
      declare
      l_user_name varchar2(50);
      l_start_date date;
      l_expiration_date date;
            cursor c1 is
      select usr.user_name, usr.start_date, usr.start_date
      from fnd_user usr
      where usr.employee_id = p_rec.person_id;

      begin
        open c1;
        fetch c1 into l_user_name, l_start_date, l_expiration_date;
        if c1%found then
          close c1;

        WF_LOCAL_SYNCH.propagate_user_role(p_user_orig_system      => 'PER',
                              p_user_orig_system_id   => pe_pei_shd.g_old_rec.person_id,
                              p_role_orig_system      => 'PQH_ROLE',
                              p_role_orig_system_id   => pe_pei_shd.g_old_rec.pei_information3,
                              p_start_date            => l_start_date,
                              p_expiration_date       => l_expiration_date
                              );
	else
	close c1;
	end if;
      end;
      declare
        l_user_name varchar2(50);
        l_start_date date;
        l_expiration_date date;
        cursor c1 is
        select usr.user_name, usr.start_date, nvl(usr.end_date, hr_general.end_of_time)
        from fnd_user usr
        where usr.employee_id = p_rec.person_id;
      begin
        open c1;
        fetch c1 into l_user_name, l_start_date, l_expiration_date;
        if c1%found then
          close c1;

          WF_LOCAL_SYNCH.propagate_user_role(p_user_orig_system      => 'PER',
                              p_user_orig_system_id   => p_rec.person_id,
                              p_role_orig_system      => 'PQH_ROLE',
                              p_role_orig_system_id   => p_rec.pei_information3,
                              p_start_date            => l_start_date,
                              p_expiration_date       => l_expiration_date);
        else
          close c1;
        end if;
      end;
    elsif nvl(pe_pei_shd.g_old_rec.pei_information5,'N') = 'Y'
    and nvl(p_rec.PEI_INFORMATION5,'N') = 'N' then
    declare
     l_user_name varchar2(50);
     l_start_date date;
     l_expiration_date date;
        cursor c1 is
        select usr.user_name, usr.start_date, usr.start_date
        from fnd_user usr
        where usr.employee_id = p_rec.person_id;

    begin
    open c1;
        fetch c1 into l_user_name, l_start_date, l_expiration_date;
        if c1%found then
          close c1;
        WF_LOCAL_SYNCH.propagate_user_role(p_user_orig_system      => 'PER',
                              p_user_orig_system_id   => pe_pei_shd.g_old_rec.person_id,
                              p_role_orig_system      => 'PQH_ROLE',
                              p_role_orig_system_id   => pe_pei_shd.g_old_rec.pei_information3,
                              p_start_date            => l_start_date,
                              p_expiration_date       => l_expiration_date);
	else
	  close c1;
	end if;
    end;
    end if;
  end if;
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
-- Pre Conditions:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs(p_rec in out NOCOPY pe_pei_shd.g_rec_type) is
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
    pe_pei_shd.g_old_rec.person_id;
  End If;
  If (p_rec.information_type = hr_api.g_varchar2) then
    p_rec.information_type :=
    pe_pei_shd.g_old_rec.information_type;
  End If;
  If (p_rec.request_id = hr_api.g_number) then
    p_rec.request_id :=
    pe_pei_shd.g_old_rec.request_id;
  End If;
  If (p_rec.program_application_id = hr_api.g_number) then
    p_rec.program_application_id :=
    pe_pei_shd.g_old_rec.program_application_id;
  End If;
  If (p_rec.program_id = hr_api.g_number) then
    p_rec.program_id :=
    pe_pei_shd.g_old_rec.program_id;
  End If;
  If (p_rec.program_update_date = hr_api.g_date) then
    p_rec.program_update_date :=
    pe_pei_shd.g_old_rec.program_update_date;
  End If;
  If (p_rec.pei_attribute_category = hr_api.g_varchar2) then
    p_rec.pei_attribute_category :=
    pe_pei_shd.g_old_rec.pei_attribute_category;
  End If;
  If (p_rec.pei_attribute1 = hr_api.g_varchar2) then
    p_rec.pei_attribute1 :=
    pe_pei_shd.g_old_rec.pei_attribute1;
  End If;
  If (p_rec.pei_attribute2 = hr_api.g_varchar2) then
    p_rec.pei_attribute2 :=
    pe_pei_shd.g_old_rec.pei_attribute2;
  End If;
  If (p_rec.pei_attribute3 = hr_api.g_varchar2) then
    p_rec.pei_attribute3 :=
    pe_pei_shd.g_old_rec.pei_attribute3;
  End If;
  If (p_rec.pei_attribute4 = hr_api.g_varchar2) then
    p_rec.pei_attribute4 :=
    pe_pei_shd.g_old_rec.pei_attribute4;
  End If;
  If (p_rec.pei_attribute5 = hr_api.g_varchar2) then
    p_rec.pei_attribute5 :=
    pe_pei_shd.g_old_rec.pei_attribute5;
  End If;
  If (p_rec.pei_attribute6 = hr_api.g_varchar2) then
    p_rec.pei_attribute6 :=
    pe_pei_shd.g_old_rec.pei_attribute6;
  End If;
  If (p_rec.pei_attribute7 = hr_api.g_varchar2) then
    p_rec.pei_attribute7 :=
    pe_pei_shd.g_old_rec.pei_attribute7;
  End If;
  If (p_rec.pei_attribute8 = hr_api.g_varchar2) then
    p_rec.pei_attribute8 :=
    pe_pei_shd.g_old_rec.pei_attribute8;
  End If;
  If (p_rec.pei_attribute9 = hr_api.g_varchar2) then
    p_rec.pei_attribute9 :=
    pe_pei_shd.g_old_rec.pei_attribute9;
  End If;
  If (p_rec.pei_attribute10 = hr_api.g_varchar2) then
    p_rec.pei_attribute10 :=
    pe_pei_shd.g_old_rec.pei_attribute10;
  End If;
  If (p_rec.pei_attribute11 = hr_api.g_varchar2) then
    p_rec.pei_attribute11 :=
    pe_pei_shd.g_old_rec.pei_attribute11;
  End If;
  If (p_rec.pei_attribute12 = hr_api.g_varchar2) then
    p_rec.pei_attribute12 :=
    pe_pei_shd.g_old_rec.pei_attribute12;
  End If;
  If (p_rec.pei_attribute13 = hr_api.g_varchar2) then
    p_rec.pei_attribute13 :=
    pe_pei_shd.g_old_rec.pei_attribute13;
  End If;
  If (p_rec.pei_attribute14 = hr_api.g_varchar2) then
    p_rec.pei_attribute14 :=
    pe_pei_shd.g_old_rec.pei_attribute14;
  End If;
  If (p_rec.pei_attribute15 = hr_api.g_varchar2) then
    p_rec.pei_attribute15 :=
    pe_pei_shd.g_old_rec.pei_attribute15;
  End If;
  If (p_rec.pei_attribute16 = hr_api.g_varchar2) then
    p_rec.pei_attribute16 :=
    pe_pei_shd.g_old_rec.pei_attribute16;
  End If;
  If (p_rec.pei_attribute17 = hr_api.g_varchar2) then
    p_rec.pei_attribute17 :=
    pe_pei_shd.g_old_rec.pei_attribute17;
  End If;
  If (p_rec.pei_attribute18 = hr_api.g_varchar2) then
    p_rec.pei_attribute18 :=
    pe_pei_shd.g_old_rec.pei_attribute18;
  End If;
  If (p_rec.pei_attribute19 = hr_api.g_varchar2) then
    p_rec.pei_attribute19 :=
    pe_pei_shd.g_old_rec.pei_attribute19;
  End If;
  If (p_rec.pei_attribute20 = hr_api.g_varchar2) then
    p_rec.pei_attribute20 :=
    pe_pei_shd.g_old_rec.pei_attribute20;
  End If;
  If (p_rec.pei_information_category = hr_api.g_varchar2) then
    p_rec.pei_information_category :=
    pe_pei_shd.g_old_rec.pei_information_category;
  End If;
  If (p_rec.pei_information1 = hr_api.g_varchar2) then
    p_rec.pei_information1 :=
    pe_pei_shd.g_old_rec.pei_information1;
  End If;
  If (p_rec.pei_information2 = hr_api.g_varchar2) then
    p_rec.pei_information2 :=
    pe_pei_shd.g_old_rec.pei_information2;
  End If;
  If (p_rec.pei_information3 = hr_api.g_varchar2) then
    p_rec.pei_information3 :=
    pe_pei_shd.g_old_rec.pei_information3;
  End If;
  If (p_rec.pei_information4 = hr_api.g_varchar2) then
    p_rec.pei_information4 :=
    pe_pei_shd.g_old_rec.pei_information4;
  End If;
  If (p_rec.pei_information5 = hr_api.g_varchar2) then
    p_rec.pei_information5 :=
    pe_pei_shd.g_old_rec.pei_information5;
  End If;
  If (p_rec.pei_information6 = hr_api.g_varchar2) then
    p_rec.pei_information6 :=
    pe_pei_shd.g_old_rec.pei_information6;
  End If;
  If (p_rec.pei_information7 = hr_api.g_varchar2) then
    p_rec.pei_information7 :=
    pe_pei_shd.g_old_rec.pei_information7;
  End If;
  If (p_rec.pei_information8 = hr_api.g_varchar2) then
    p_rec.pei_information8 :=
    pe_pei_shd.g_old_rec.pei_information8;
  End If;
  If (p_rec.pei_information9 = hr_api.g_varchar2) then
    p_rec.pei_information9 :=
    pe_pei_shd.g_old_rec.pei_information9;
  End If;
  If (p_rec.pei_information10 = hr_api.g_varchar2) then
    p_rec.pei_information10 :=
    pe_pei_shd.g_old_rec.pei_information10;
  End If;
  If (p_rec.pei_information11 = hr_api.g_varchar2) then
    p_rec.pei_information11 :=
    pe_pei_shd.g_old_rec.pei_information11;
  End If;
  If (p_rec.pei_information12 = hr_api.g_varchar2) then
    p_rec.pei_information12 :=
    pe_pei_shd.g_old_rec.pei_information12;
  End If;
  If (p_rec.pei_information13 = hr_api.g_varchar2) then
    p_rec.pei_information13 :=
    pe_pei_shd.g_old_rec.pei_information13;
  End If;
  If (p_rec.pei_information14 = hr_api.g_varchar2) then
    p_rec.pei_information14 :=
    pe_pei_shd.g_old_rec.pei_information14;
  End If;
  If (p_rec.pei_information15 = hr_api.g_varchar2) then
    p_rec.pei_information15 :=
    pe_pei_shd.g_old_rec.pei_information15;
  End If;
  If (p_rec.pei_information16 = hr_api.g_varchar2) then
    p_rec.pei_information16 :=
    pe_pei_shd.g_old_rec.pei_information16;
  End If;
  If (p_rec.pei_information17 = hr_api.g_varchar2) then
    p_rec.pei_information17 :=
    pe_pei_shd.g_old_rec.pei_information17;
  End If;
  If (p_rec.pei_information18 = hr_api.g_varchar2) then
    p_rec.pei_information18 :=
    pe_pei_shd.g_old_rec.pei_information18;
  End If;
  If (p_rec.pei_information19 = hr_api.g_varchar2) then
    p_rec.pei_information19 :=
    pe_pei_shd.g_old_rec.pei_information19;
  End If;
  If (p_rec.pei_information20 = hr_api.g_varchar2) then
    p_rec.pei_information20 :=
    pe_pei_shd.g_old_rec.pei_information20;
  End If;
  If (p_rec.pei_information21 = hr_api.g_varchar2) then
    p_rec.pei_information21 :=
    pe_pei_shd.g_old_rec.pei_information21;
  End If;
  If (p_rec.pei_information22 = hr_api.g_varchar2) then
    p_rec.pei_information22 :=
    pe_pei_shd.g_old_rec.pei_information22;
  End If;
  If (p_rec.pei_information23 = hr_api.g_varchar2) then
    p_rec.pei_information23 :=
    pe_pei_shd.g_old_rec.pei_information23;
  End If;
  If (p_rec.pei_information24 = hr_api.g_varchar2) then
    p_rec.pei_information24 :=
    pe_pei_shd.g_old_rec.pei_information24;
  End If;
  If (p_rec.pei_information25 = hr_api.g_varchar2) then
    p_rec.pei_information25 :=
    pe_pei_shd.g_old_rec.pei_information25;
  End If;
  If (p_rec.pei_information26 = hr_api.g_varchar2) then
    p_rec.pei_information26 :=
    pe_pei_shd.g_old_rec.pei_information26;
  End If;
  If (p_rec.pei_information27 = hr_api.g_varchar2) then
    p_rec.pei_information27 :=
    pe_pei_shd.g_old_rec.pei_information27;
  End If;
  If (p_rec.pei_information28 = hr_api.g_varchar2) then
    p_rec.pei_information28 :=
    pe_pei_shd.g_old_rec.pei_information28;
  End If;
  If (p_rec.pei_information29 = hr_api.g_varchar2) then
    p_rec.pei_information29 :=
    pe_pei_shd.g_old_rec.pei_information29;
  End If;
  If (p_rec.pei_information30 = hr_api.g_varchar2) then
    p_rec.pei_information30 :=
    pe_pei_shd.g_old_rec.pei_information30;
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
  p_rec        in out NOCOPY pe_pei_shd.g_rec_type,
  p_validate   in     boolean default false
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT upd_pe_pei;
  End If;
  --
  -- We must lock the row which we need to update.
  --
  pe_pei_shd.lck
	(
	p_rec.person_extra_info_id,
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
  pe_pei_bus.update_validate(p_rec);
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
  --
  -- If we are validating then raise the Validate_Enabled exception
  --
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO upd_pe_pei;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_person_extra_info_id         in number,
  p_request_id                   in number           default hr_api.g_number,
  p_program_application_id       in number           default hr_api.g_number,
  p_program_id                   in number           default hr_api.g_number,
  p_program_update_date          in date             default hr_api.g_date,
  p_pei_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_pei_attribute1               in varchar2         default hr_api.g_varchar2,
  p_pei_attribute2               in varchar2         default hr_api.g_varchar2,
  p_pei_attribute3               in varchar2         default hr_api.g_varchar2,
  p_pei_attribute4               in varchar2         default hr_api.g_varchar2,
  p_pei_attribute5               in varchar2         default hr_api.g_varchar2,
  p_pei_attribute6               in varchar2         default hr_api.g_varchar2,
  p_pei_attribute7               in varchar2         default hr_api.g_varchar2,
  p_pei_attribute8               in varchar2         default hr_api.g_varchar2,
  p_pei_attribute9               in varchar2         default hr_api.g_varchar2,
  p_pei_attribute10              in varchar2         default hr_api.g_varchar2,
  p_pei_attribute11              in varchar2         default hr_api.g_varchar2,
  p_pei_attribute12              in varchar2         default hr_api.g_varchar2,
  p_pei_attribute13              in varchar2         default hr_api.g_varchar2,
  p_pei_attribute14              in varchar2         default hr_api.g_varchar2,
  p_pei_attribute15              in varchar2         default hr_api.g_varchar2,
  p_pei_attribute16              in varchar2         default hr_api.g_varchar2,
  p_pei_attribute17              in varchar2         default hr_api.g_varchar2,
  p_pei_attribute18              in varchar2         default hr_api.g_varchar2,
  p_pei_attribute19              in varchar2         default hr_api.g_varchar2,
  p_pei_attribute20              in varchar2         default hr_api.g_varchar2,
  p_pei_information_category     in varchar2         default hr_api.g_varchar2,
  p_pei_information1             in varchar2         default hr_api.g_varchar2,
  p_pei_information2             in varchar2         default hr_api.g_varchar2,
  p_pei_information3             in varchar2         default hr_api.g_varchar2,
  p_pei_information4             in varchar2         default hr_api.g_varchar2,
  p_pei_information5             in varchar2         default hr_api.g_varchar2,
  p_pei_information6             in varchar2         default hr_api.g_varchar2,
  p_pei_information7             in varchar2         default hr_api.g_varchar2,
  p_pei_information8             in varchar2         default hr_api.g_varchar2,
  p_pei_information9             in varchar2         default hr_api.g_varchar2,
  p_pei_information10            in varchar2         default hr_api.g_varchar2,
  p_pei_information11            in varchar2         default hr_api.g_varchar2,
  p_pei_information12            in varchar2         default hr_api.g_varchar2,
  p_pei_information13            in varchar2         default hr_api.g_varchar2,
  p_pei_information14            in varchar2         default hr_api.g_varchar2,
  p_pei_information15            in varchar2         default hr_api.g_varchar2,
  p_pei_information16            in varchar2         default hr_api.g_varchar2,
  p_pei_information17            in varchar2         default hr_api.g_varchar2,
  p_pei_information18            in varchar2         default hr_api.g_varchar2,
  p_pei_information19            in varchar2         default hr_api.g_varchar2,
  p_pei_information20            in varchar2         default hr_api.g_varchar2,
  p_pei_information21            in varchar2         default hr_api.g_varchar2,
  p_pei_information22            in varchar2         default hr_api.g_varchar2,
  p_pei_information23            in varchar2         default hr_api.g_varchar2,
  p_pei_information24            in varchar2         default hr_api.g_varchar2,
  p_pei_information25            in varchar2         default hr_api.g_varchar2,
  p_pei_information26            in varchar2         default hr_api.g_varchar2,
  p_pei_information27            in varchar2         default hr_api.g_varchar2,
  p_pei_information28            in varchar2         default hr_api.g_varchar2,
  p_pei_information29            in varchar2         default hr_api.g_varchar2,
  p_pei_information30            in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out NOCOPY number,
  p_validate                     in boolean      default false
  ) is
--
  l_rec	  pe_pei_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pe_pei_shd.convert_args
  (
  p_person_extra_info_id,
  hr_api.g_number,
  hr_api.g_varchar2,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
  p_pei_attribute_category,
  p_pei_attribute1,
  p_pei_attribute2,
  p_pei_attribute3,
  p_pei_attribute4,
  p_pei_attribute5,
  p_pei_attribute6,
  p_pei_attribute7,
  p_pei_attribute8,
  p_pei_attribute9,
  p_pei_attribute10,
  p_pei_attribute11,
  p_pei_attribute12,
  p_pei_attribute13,
  p_pei_attribute14,
  p_pei_attribute15,
  p_pei_attribute16,
  p_pei_attribute17,
  p_pei_attribute18,
  p_pei_attribute19,
  p_pei_attribute20,
  p_pei_information_category,
  p_pei_information1,
  p_pei_information2,
  p_pei_information3,
  p_pei_information4,
  p_pei_information5,
  p_pei_information6,
  p_pei_information7,
  p_pei_information8,
  p_pei_information9,
  p_pei_information10,
  p_pei_information11,
  p_pei_information12,
  p_pei_information13,
  p_pei_information14,
  p_pei_information15,
  p_pei_information16,
  p_pei_information17,
  p_pei_information18,
  p_pei_information19,
  p_pei_information20,
  p_pei_information21,
  p_pei_information22,
  p_pei_information23,
  p_pei_information24,
  p_pei_information25,
  p_pei_information26,
  p_pei_information27,
  p_pei_information28,
  p_pei_information29,
  p_pei_information30,
  p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec, p_validate);
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pe_pei_upd;

/
