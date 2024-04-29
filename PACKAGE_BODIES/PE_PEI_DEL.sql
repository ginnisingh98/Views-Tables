--------------------------------------------------------
--  DDL for Package Body PE_PEI_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PE_PEI_DEL" as
/* $Header: pepeirhi.pkb 120.1 2005/07/25 05:01:42 jpthomas noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pe_pei_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic. The functions of
--   this procedure are as follows:
--   1) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   (Note: Sue 1/29/97 Removed the need for setting g_api_dml as this is a new
--    table and therefore there is no ovn trigger to use it).
--   2) To delete the specified row from the schema using the primary key in
--      the predicates.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the del
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be delete from the schema.
--
-- Post Failure:
--   On the delete dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a child integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--   (Note: Sue 1/29/97 Removed the need for setting g_api_dml as this is a new
--    table and therefore there is no ovn trigger to use it).
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_dml(p_rec in pe_pei_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Delete the per_people_extra_info row.
  --
  delete from per_people_extra_info
  where person_extra_info_id = p_rec.person_extra_info_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    pe_pei_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    Raise;
End delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the delete dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the del procedure.
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
--   Any pre-processing required before the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete(p_rec in pe_pei_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_delete;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   delete dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the del procedure.
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
--   Any post-processing required after the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_delete(p_rec in pe_pei_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- This is a hook point and the user hook for post_delete is called here.
  --
  begin
     pe_pei_rkd.after_delete	(
	p_person_extra_info_id_o	=>	pe_pei_shd.g_old_rec.person_extra_info_id		,
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
			,p_hook_type  => 'AD'
	        );
  end;
  -- End of API User Hook for post_delete.
  --
  if pe_pei_shd.g_old_rec.information_type = 'PQH_ROLE_USERS'then
    declare
      l_user_name varchar2(50);
      l_start_date date;
      l_expiration_date date;
      cursor c1 is
      select usr.user_name, usr.start_date, usr.start_date
      from fnd_user usr
      where usr.employee_id = pe_pei_shd.g_old_rec.person_id;
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
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_rec	      in pe_pei_shd.g_rec_type,
  p_validate  in boolean default false
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
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
    SAVEPOINT del_pe_pei;
  End If;
  --
  -- We must lock the row which we need to delete.
  --
  pe_pei_shd.lck
	(
	p_rec.person_extra_info_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  pe_pei_bus.delete_validate(p_rec);
  --
  -- Call the supporting pre-delete operation
  --
  pre_delete(p_rec);
  --
  -- Delete the row.
  --
  delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  post_delete(p_rec);
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
    ROLLBACK TO del_pe_pei;
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_person_extra_info_id               in number,
  p_object_version_number              in number,
  p_validate                           in boolean default false
  ) is
--
  l_rec	  pe_pei_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.person_extra_info_id:= p_person_extra_info_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the pe_pei_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec, p_validate);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end pe_pei_del;

/
