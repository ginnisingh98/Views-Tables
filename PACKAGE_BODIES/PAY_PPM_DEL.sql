--------------------------------------------------------
--  DDL for Package Body PAY_PPM_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PPM_DEL" as
/* $Header: pyppmrhi.pkb 120.3.12010000.5 2010/03/30 06:46:19 priupadh ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_ppm_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_delete_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic for the datetrack
--   delete modes: ZAP, DELETE, FUTURE_CHANGE and DELETE_NEXT_CHANGE. The
--   execution is as follows:
--   1) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   2) If the delete mode is DELETE_NEXT_CHANGE then delete where the
--      effective start date is equal to the validation start date.
--   3) If the delete mode is not DELETE_NEXT_CHANGE then delete
--      all rows for the entity where the effective start date is greater
--      than or equal to the validation start date.
--   4) To raise any errors.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the
--   delete_dml procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be delete from the schema.
--
-- Post Failure:
--   On the delete dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   This is an internal private procedure which must be called from the
--   delete_dml procedure.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_dml
	(p_rec 			 in out nocopy pay_ppm_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'dt_delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode = 'DELETE_NEXT_CHANGE') then
    hr_utility.set_location(l_proc, 10);
    pay_ppm_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the where the effective start date is equal
    -- to the validation end date.
    --
    delete from pay_personal_payment_methods_f
    where       personal_payment_method_id = p_rec.personal_payment_method_id
    and	  effective_start_date = p_validation_start_date;
    --
    pay_ppm_shd.g_api_dml := false;   -- Unset the api dml status
  Else
    hr_utility.set_location(l_proc, 15);
    pay_ppm_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the row(s) where the effective start date is greater than
    -- or equal to the validation start date.
    --
    delete from pay_personal_payment_methods_f
    where        personal_payment_method_id = p_rec.personal_payment_method_id
    and	  effective_start_date >= p_validation_start_date;
    --
    pay_ppm_shd.g_api_dml := false;   -- Unset the api dml status
  End If;
  --
  -- If we are doing a 'ZAP' then we must set the effective start and end
  -- dates to null
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
Exception
  When Others Then
    pay_ppm_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_dml
	(p_rec 			 in out nocopy pay_ppm_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_delete_dml(p_rec			=> p_rec,
		p_effective_date	=> p_effective_date,
		p_datetrack_mode	=> p_datetrack_mode,
       		p_validation_start_date	=> p_validation_start_date,
		p_validation_end_date	=> p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_dml;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_pre_delete >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The dt_pre_delete process controls the execution of dml
--   for the datetrack modes: DELETE, FUTURE_CHANGE
--   and DELETE_NEXT_CHANGE only.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the pre_delete
--   procedure.
--
-- In Arguments:
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
--   This is an internal procedure which is required by Datetrack. Don't
--   remove or modify.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_pre_delete
	(p_rec 			 in out nocopy pay_ppm_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'dt_pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
 If (p_datetrack_mode <> 'ZAP') then
   --
   p_rec.effective_start_date :=
      pay_ppm_shd.g_old_rec.effective_start_date;
   --
   If (p_datetrack_mode = 'DELETE') then
     p_rec.effective_end_date := p_validation_start_date - 1;
   Else
     p_rec.effective_end_date := p_validation_end_date;
   End If;
   --
   -- Update the current effective end date record
   --
   pay_ppm_shd.upd_effective_end_date
     (p_effective_date	        => p_effective_date,
      p_base_key_value	        => p_rec.personal_payment_method_id,
      p_new_effective_end_date  => p_rec.effective_end_date,
      p_validation_start_date   => p_validation_start_date,
      p_validation_end_date	=> p_validation_end_date,
      p_object_version_number   => p_rec.object_version_number);
  Else
    p_rec.effective_start_date := null;
    p_rec.effective_end_date := null;
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End dt_pre_delete;
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
-- In Arguments:
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
--   maintenance should be reviewed before placing in this procedure. The call
--   to the dt_delete_dml procedure should NOT be removed.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete
	(p_rec 			 in out nocopy pay_ppm_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'pre_delete';
--
  -- Cursor C_Sel1 select comments to be deleted
  --
  Cursor C_Sel1 is
    /*Added DISTINCT as comment_id is not date-tracked in PAY_PERSONAL_PAYMENT_METHODS_F.
      Absence of DISTINCT causing locking contention due to locking same row of
      HR_COMMENTS for multiple times in case of ZAP operation.Bug#9358129.*/
    select DISTINCT t1.comment_id
    from   pay_personal_payment_methods_f t1
    where  t1.comment_id is not null
    and    t1.personal_payment_method_id = p_rec.personal_payment_method_id
    and    t1.effective_start_date <= p_validation_end_date
    and    t1.effective_end_date   >= p_validation_start_date
    and    not exists
           (select 1
            from   pay_personal_payment_methods_f t2
            where  t2.comment_id = t1.comment_id
            and    t2.personal_payment_method_id = t1.personal_payment_method_id

            and   (t2.effective_start_date > p_validation_end_date
             or    t2.effective_end_date   < p_validation_start_date));
  --
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Bug 9358415-- Only delete comments when datetrack mode is ZAP
  -- Delete any possible comments
  --
  If p_datetrack_mode = 'ZAP' then
    For Comm_Del In C_Sel1 Loop
      hr_comm_api.del(p_comment_id        => Comm_Del.comment_id);
    End Loop;
  End if;
  --
  dt_pre_delete
    (p_rec 		     => p_rec,
     p_effective_date	     => p_effective_date,
     p_datetrack_mode	     => p_datetrack_mode,
     p_validation_start_date => p_validation_start_date,
     p_validation_end_date   => p_validation_end_date);
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
-- In Arguments:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_delete
	(p_rec 			 in pay_ppm_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Start of API User Hook for post_delete.
  begin
    pay_ppm_rkd.after_delete
      (p_effective_date                 => p_effective_date
      ,p_datetrack_mode                 => p_datetrack_mode
      ,p_validation_start_date          => p_validation_start_date
      ,p_validation_end_date            => p_validation_end_date
      ,p_personal_payment_method_id     => p_rec.personal_payment_method_id
      ,p_effective_start_date           => p_rec.effective_start_date
      ,p_effective_end_date             => p_rec.effective_end_date
      ,p_object_version_number          => p_rec.object_version_number
      ,p_effective_start_date_o
          => pay_ppm_shd.g_old_rec.effective_start_date
      ,p_effective_end_date_o
          => pay_ppm_shd.g_old_rec.effective_end_date
      ,p_business_group_id_o
          => pay_ppm_shd.g_old_rec.business_group_id
      ,p_external_account_id_o
          => pay_ppm_shd.g_old_rec.external_account_id
      ,p_assignment_id_o
          => pay_ppm_shd.g_old_rec.assignment_id
      ,p_org_payment_method_id_o
          => pay_ppm_shd.g_old_rec.org_payment_method_id
      ,p_amount_o
          => pay_ppm_shd.g_old_rec.amount
      ,p_comment_id_o
          => pay_ppm_shd.g_old_rec.comment_id
      ,p_percentage_o
          => pay_ppm_shd.g_old_rec.percentage
      ,p_priority_o
          => pay_ppm_shd.g_old_rec.priority
      ,p_attribute_category_o
          => pay_ppm_shd.g_old_rec.attribute_category
      ,p_attribute1_o
          => pay_ppm_shd.g_old_rec.attribute1
      ,p_attribute2_o
          => pay_ppm_shd.g_old_rec.attribute2
      ,p_attribute3_o
          => pay_ppm_shd.g_old_rec.attribute3
      ,p_attribute4_o
          => pay_ppm_shd.g_old_rec.attribute4
      ,p_attribute5_o
          => pay_ppm_shd.g_old_rec.attribute5
      ,p_attribute6_o
          => pay_ppm_shd.g_old_rec.attribute6
      ,p_attribute7_o
          => pay_ppm_shd.g_old_rec.attribute7
      ,p_attribute8_o
          => pay_ppm_shd.g_old_rec.attribute8
      ,p_attribute9_o
          => pay_ppm_shd.g_old_rec.attribute9
      ,p_attribute10_o
          => pay_ppm_shd.g_old_rec.attribute10
      ,p_attribute11_o
          => pay_ppm_shd.g_old_rec.attribute11
      ,p_attribute12_o
          => pay_ppm_shd.g_old_rec.attribute12
      ,p_attribute13_o
          => pay_ppm_shd.g_old_rec.attribute13
      ,p_attribute14_o
          => pay_ppm_shd.g_old_rec.attribute14
      ,p_attribute15_o
          => pay_ppm_shd.g_old_rec.attribute15
      ,p_attribute16_o
          => pay_ppm_shd.g_old_rec.attribute16
      ,p_attribute17_o
          => pay_ppm_shd.g_old_rec.attribute17
      ,p_attribute18_o
          => pay_ppm_shd.g_old_rec.attribute18
      ,p_attribute19_o
          => pay_ppm_shd.g_old_rec.attribute19
      ,p_attribute20_o
          => pay_ppm_shd.g_old_rec.attribute20
      ,p_object_version_number_o
          => pay_ppm_shd.g_old_rec.object_version_number
      ,p_payee_type_o
          => pay_ppm_shd.g_old_rec.payee_type
      ,p_payee_id_o
          => pay_ppm_shd.g_old_rec.payee_id
      ,p_ppm_information_category_o
          => pay_ppm_shd.g_old_rec.ppm_information_category
      ,p_ppm_information1_o
          => pay_ppm_shd.g_old_rec.ppm_information1
      ,p_ppm_information2_o
          => pay_ppm_shd.g_old_rec.ppm_information2
      ,p_ppm_information3_o
          => pay_ppm_shd.g_old_rec.ppm_information3
      ,p_ppm_information4_o
          => pay_ppm_shd.g_old_rec.ppm_information4
      ,p_ppm_information5_o
          => pay_ppm_shd.g_old_rec.ppm_information5
      ,p_ppm_information6_o
          => pay_ppm_shd.g_old_rec.ppm_information6
      ,p_ppm_information7_o
          => pay_ppm_shd.g_old_rec.ppm_information7
      ,p_ppm_information8_o
          => pay_ppm_shd.g_old_rec.ppm_information8
      ,p_ppm_information9_o
          => pay_ppm_shd.g_old_rec.ppm_information9
      ,p_ppm_information10_o
          => pay_ppm_shd.g_old_rec.ppm_information10
      ,p_ppm_information11_o
          => pay_ppm_shd.g_old_rec.ppm_information11
      ,p_ppm_information12_o
          => pay_ppm_shd.g_old_rec.ppm_information12
      ,p_ppm_information13_o
          => pay_ppm_shd.g_old_rec.ppm_information13
      ,p_ppm_information14_o
          => pay_ppm_shd.g_old_rec.ppm_information14
      ,p_ppm_information15_o
          => pay_ppm_shd.g_old_rec.ppm_information15
      ,p_ppm_information16_o
          => pay_ppm_shd.g_old_rec.ppm_information16
      ,p_ppm_information17_o
          => pay_ppm_shd.g_old_rec.ppm_information17
      ,p_ppm_information18_o
          => pay_ppm_shd.g_old_rec.ppm_information18
      ,p_ppm_information19_o
          => pay_ppm_shd.g_old_rec.ppm_information19
      ,p_ppm_information20_o
          => pay_ppm_shd.g_old_rec.ppm_information20
      ,p_ppm_information21_o
          => pay_ppm_shd.g_old_rec.ppm_information21
      ,p_ppm_information22_o
          => pay_ppm_shd.g_old_rec.ppm_information22
      ,p_ppm_information23_o
          => pay_ppm_shd.g_old_rec.ppm_information23
      ,p_ppm_information24_o
          => pay_ppm_shd.g_old_rec.ppm_information24
      ,p_ppm_information25_o
          => pay_ppm_shd.g_old_rec.ppm_information25
      ,p_ppm_information26_o
          => pay_ppm_shd.g_old_rec.ppm_information26
      ,p_ppm_information27_o
          => pay_ppm_shd.g_old_rec.ppm_information27
      ,p_ppm_information28_o
          => pay_ppm_shd.g_old_rec.ppm_information28
      ,p_ppm_information29_o
          => pay_ppm_shd.g_old_rec.ppm_information29
      ,p_ppm_information30_o
          => pay_ppm_shd.g_old_rec.ppm_information30
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_PERSONAL_PAYMENT_METHODS_F'
        ,p_hook_type   => 'AD'
        );
  end;
  -- End of API User Hook for post_delete.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_rec			in out 	nocopy pay_ppm_shd.g_rec_type,
  p_effective_date	in 	date,
  p_datetrack_mode	in 	varchar2,
  p_validate   		in 	boolean default false
  ) is
--
  l_proc			varchar2(72) := g_package||'del';
  l_validation_start_date	date;
  l_validation_end_date		date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the DateTrack delete mode is valid
  --
  dt_api.validate_dt_del_mode(p_datetrack_mode => p_datetrack_mode);
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT del_pay_ppm;
  End If;
  --
  -- We must lock the row which we need to delete.
  --
  pay_ppm_shd.lck
	(p_effective_date	 => p_effective_date,
      	 p_datetrack_mode	 => p_datetrack_mode,
      	 p_personal_payment_method_id	 => p_rec.personal_payment_method_id,
      	 p_object_version_number => p_rec.object_version_number,
      	 p_validation_start_date => l_validation_start_date,
      	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Return the effective end date
  --
  l_validation_end_date := pay_ppm_bus.return_effective_end_date
        (p_datetrack_mode              =>  p_datetrack_mode
        ,p_effective_date              =>  p_effective_date
        ,p_org_payment_method_id       =>
	   pay_ppm_shd.g_old_rec.org_payment_method_id
        ,p_business_group_id           =>
	   pay_ppm_shd.g_old_rec.business_group_id
        ,p_personal_payment_method_id  =>
	   pay_ppm_shd.g_old_rec.personal_payment_method_id
        ,p_assignment_id               =>
	   pay_ppm_shd.g_old_rec.assignment_id
        ,p_run_type_id               =>
	   pay_ppm_shd.g_old_rec.run_type_id
        ,p_priority                    =>
	   pay_ppm_shd.g_old_rec.priority
        ,p_validation_start_date       =>  l_validation_start_date
        ,p_validation_end_date         =>  l_validation_end_date
        );
  --
  -- Call the supporting delete validate operation
  --
  pay_ppm_bus.delete_validate
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting pre-delete operation
  --
  pre_delete
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Delete the row.
  --
  delete_dml
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting post-delete operation
  --
  post_delete
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
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
    ROLLBACK TO del_pay_ppm;
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_personal_payment_method_id	  in 	 number,
  p_effective_start_date     out nocopy date,
  p_effective_end_date	     out nocopy date,
  p_object_version_number in out nocopy number,
  p_effective_date	  in     date,
  p_datetrack_mode  	  in     varchar2,
  p_validate		  in     boolean default false
  ) is
--
  l_rec		pay_ppm_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.personal_payment_method_id		:= p_personal_payment_method_id;
  l_rec.object_version_number 	:= p_object_version_number;
  --
  -- Having converted the arguments into the pay_ppm_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec, p_effective_date, p_datetrack_mode, p_validate);
  --
  -- Set the out arguments
  --
  p_object_version_number := l_rec.object_version_number;
  p_effective_start_date  := l_rec.effective_start_date;
  p_effective_end_date    := l_rec.effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end pay_ppm_del;

/
