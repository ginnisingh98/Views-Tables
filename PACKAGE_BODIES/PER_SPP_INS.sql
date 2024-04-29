--------------------------------------------------------
--  DDL for Package Body PER_SPP_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SPP_INS" as
/* $Header: pespprhi.pkb 120.2.12010000.4 2008/11/05 14:50:57 brsinha ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_spp_ins.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_insert_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic for datetrack. The
--   functions of this procedure are as follows:
--   1) Get the object_version_number.
--   2) To set the effective start and end dates to the corresponding
--      validation start and end dates. Also, the object version number
--      record attribute is set.
--   3) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   4) To insert the row into the schema with the derived effective start
--      and end dates and the object version number.
--   5) To trap any constraint violations that may have occurred.
--   6) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   insert_dml and pre_update (logic permitting) procedure and must have
--   all mandatory arguments set.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   The specified row will be inserted into the schema.
--
-- Post Failure:
--   On the insert dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check or unique integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   This is an internal datetrack maintenance procedure which should
--   not be modified in anyway.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_insert_dml
  (p_rec                     in out nocopy per_spp_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
-- Cursor to select 'old' created AOL who column values
--
  Cursor C_Sel1 Is
    select t.created_by,
           t.creation_date
    from   per_spinal_point_placements_f t
    where  t.placement_id       = p_rec.placement_id
    and    t.effective_start_date =
             per_spp_shd.g_old_rec.effective_start_date
    and    t.effective_end_date   = (p_validation_start_date - 1);
--
  l_proc                varchar2(72) := g_package||'dt_insert_dml';
  l_created_by          per_spinal_point_placements_f.created_by%TYPE;
  l_creation_date       per_spinal_point_placements_f.creation_date%TYPE;
  l_last_update_date   	per_spinal_point_placements_f.last_update_date%TYPE;
  l_last_updated_by     per_spinal_point_placements_f.last_updated_by%TYPE;
  l_last_update_login   per_spinal_point_placements_f.last_update_login%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Get the object version number for the insert
  --
  p_rec.object_version_number :=
    dt_api.get_object_version_number
      (p_base_table_name => 'per_spinal_point_placements_f'
      ,p_base_key_column => 'placement_id'
      ,p_base_key_value  => p_rec.placement_id
      );
  --
  -- Set the effective start and end dates to the corresponding
  -- validation start and end dates
  --
  p_rec.effective_start_date := p_validation_start_date;
  p_rec.effective_end_date   := p_validation_end_date;
  --
  -- If the datetrack_mode is not INSERT then we must populate the WHO
  -- columns with the 'old' creation values and 'new' updated values.
  --
  If (p_datetrack_mode <> hr_api.g_insert) then
    hr_utility.set_location(l_proc, 10);
    --
    -- Select the 'old' created values
    --
    Open C_Sel1;
    Fetch C_Sel1 Into l_created_by, l_creation_date;
    If C_Sel1%notfound Then
      --
      -- The previous 'old' created row has not been found. We need
      -- to error as an internal datetrack problem exists.
      --
      Close C_Sel1;
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','10');
      fnd_message.raise_error;
    End If;
    Close C_Sel1;
    --
    -- Set the AOL updated WHO values
    --
    l_last_update_date   := sysdate;
    l_last_updated_by    := fnd_global.user_id;
    l_last_update_login  := fnd_global.login_id;
  End If;
  --
  per_spp_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: per_spinal_point_placements_f
  --
  insert into per_spinal_point_placements_f
      (placement_id
      ,effective_start_date
      ,effective_end_date
      ,business_group_id
      ,assignment_id
      ,step_id
      ,auto_increment_flag
      ,parent_spine_id
      ,reason
      ,request_id
      ,program_application_id
      ,program_id
      ,program_update_date
      ,increment_number
      ,object_version_number
      ,information1
      ,information2
      ,information3
      ,information4
      ,information5
      ,information6
      ,information7
      ,information8
      ,information9
      ,information10
      ,information11
      ,information12
      ,information13
      ,information14
      ,information15
      ,information16
      ,information17
      ,information18
      ,information19
      ,information20
      ,information21
      ,information22
      ,information23
      ,information24
      ,information25
      ,information26
      ,information27
      ,information28
      ,information29
      ,information30
      ,information_category
      ,created_by
      ,creation_date
      ,last_update_date
      ,last_updated_by
      ,last_update_login
      )
  Values
    (p_rec.placement_id
    ,p_rec.effective_start_date
    ,p_rec.effective_end_date
    ,p_rec.business_group_id
    ,p_rec.assignment_id
    ,p_rec.step_id
    ,p_rec.auto_increment_flag
    ,p_rec.parent_spine_id
    ,p_rec.reason
    ,p_rec.request_id
    ,p_rec.program_application_id
    ,p_rec.program_id
    ,p_rec.program_update_date
    ,p_rec.increment_number
    ,p_rec.object_version_number
    ,p_rec.information1
    ,p_rec.information2
    ,p_rec.information3
    ,p_rec.information4
    ,p_rec.information5
    ,p_rec.information6
    ,p_rec.information7
    ,p_rec.information8
    ,p_rec.information9
    ,p_rec.information10
    ,p_rec.information11
    ,p_rec.information12
    ,p_rec.information13
    ,p_rec.information14
    ,p_rec.information15
    ,p_rec.information16
    ,p_rec.information17
    ,p_rec.information18
    ,p_rec.information19
    ,p_rec.information20
    ,p_rec.information21
    ,p_rec.information22
    ,p_rec.information23
    ,p_rec.information24
    ,p_rec.information25
    ,p_rec.information26
    ,p_rec.information27
    ,p_rec.information28
    ,p_rec.information29
    ,p_rec.information30
    ,p_rec.information_category
    ,l_created_by
    ,l_creation_date
    ,l_last_update_date
    ,l_last_updated_by
    ,l_last_update_login
    );
  --
  per_spp_shd.g_api_dml := false;   -- Unset the api dml status
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_spp_shd.g_api_dml := false;   -- Unset the api dml status
    per_spp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_spp_shd.g_api_dml := false;   -- Unset the api dml status
    per_spp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_spp_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_dml
  (p_rec                   in out nocopy per_spp_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc	varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  per_spp_ins.dt_insert_dml
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => p_datetrack_mode
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the insert dml. Presently, if the entity has a corresponding primary
--   key which is maintained by an associating sequence, the primary key for
--   the entity will be populated with the next sequence value in
--   preparation for the insert dml.
--   Also, if comments are defined for this entity, the comments insert
--   logic will also be called, generating a comment_id if required.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
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
--   Any pre-processing required before the insert dml is issued should be
--   coded within this procedure. As stated above, a good example is the
--   generation of a primary key number via a corresponding sequence.
--   It is important to note that any 3rd party maintenance should be reviewed
--   before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert
  (p_rec                   in out nocopy per_spp_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc	varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select per_spinal_point_placements_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.placement_id;
  Close C_Sel1;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_future_spp >---------------------------|
-- ----------------------------------------------------------------------------
-- Bug 2977842 starts here. Added new procedure to delete all the future spps
-- for the assignment.
--
PROCEDURE delete_future_spps(p_assignment_id  number
                            ,p_effective_date date ) IS

--
  --
  -- Fetch future SPP_Records
  --
  CURSOR csr_future_spp_records(p_assignment_id number, p_effective_date date) IS
  SELECT spp.placement_id,
         spp.object_version_number,
         spp.effective_start_date
  FROM   per_spinal_point_placements_f spp
  WHERE  spp.assignment_id = p_assignment_id
  AND    spp.effective_start_date > p_effective_date;
 -- ORDER BY placement_id;   Bug fix: 3648542
  --
  --
  l_previous_id per_spinal_point_placements_f.placement_id%type;
  l_object_version_number NUMBER;
  l_effective_start_date DATE;
  l_effective_end_date DATE;
  l_proc   VARCHAR2(72) := g_package||'delete_future_spps';
  --
--
BEGIN

  hr_utility.set_location('Entering : '||l_proc, 5);
  --
  l_previous_id := -1;
  --
  -- Delete all future SPP records.
    FOR c_future_spp IN csr_future_spp_records(p_assignment_id, p_effective_date) LOOP
    --
    hr_utility.set_location(l_proc||'/ pl_id = '||c_future_spp.placement_id, 10);
    hr_utility.set_location(l_proc||'/ ovn   = '||c_future_spp.object_version_number, 10);
    --
    -- If the record retrieved has a different placement id
    -- then perform a ZAP on this record. If the ID is the same
    -- as the previous id then do nothing as this record has already
    -- been deleted.
    --
    IF l_previous_id <> c_future_spp.placement_id THEN
      --
      hr_utility.set_location(l_proc, 20);
      --
      l_previous_id           := c_future_spp.placement_id;
      l_object_version_number := c_future_spp.object_version_number;
      --
      hr_sp_placement_api.delete_spp
        (p_effective_date        => c_future_spp.effective_start_date
        ,p_datetrack_mode	 => hr_api.g_zap
        ,p_placement_id		 => c_future_spp.placement_id
        ,p_object_version_number => l_object_version_number
        ,p_effective_start_date	 => l_effective_start_date
        ,p_effective_end_date	 => l_effective_end_date);
      --
    END IF;
    --
  END LOOP;
  --
  hr_utility.set_location('Leaving : '||l_proc, 30);

END delete_future_spps;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< sync_spp_asg >-----------------------------|
-- ----------------------------------------------------------------------------
-- Bug 2977842. Added new procedure to synchronise the spp
-- with the corresponding Assignment updates.
--
PROCEDURE Sync_spp_asg(p_assignment_id number
                      ,p_effective_date date) IS

--
  --
  --Select placements for the Assignment after the effective date.
  --
  Cursor future_spps(p_assignment_id number, p_effective_date date) IS
  select spp.placement_id
      --  ,spp.effective_start_date
      --  ,spp.effective_end_date
      --  ,spp.step_id
  from   per_spinal_point_placements_f spp
  where  spp.assignment_id = p_assignment_id
  and    spp.effective_start_date > p_effective_date;
  --
  -- select the earliest of (effective_start_date-1) for existing spps.
  --
  Cursor spp_end_date(p_assignment_id number, p_effective_date date) IS
  select min(spp.effective_start_date-1)
  from   per_spinal_point_placements_f spp
  where  spp.assignment_id = p_assignment_id
  and    spp.effective_start_date > p_effective_date;
  --
  --
  --
  Cursor Asg_updates(p_assignment_id number, p_start_date date, p_end_date date) IS
  select paa.assignment_id
        ,paa.effective_start_date
        ,paa.effective_end_date
        ,paa.grade_id
  from   per_all_assignments_f paa
  where  paa.assignment_id = p_assignment_id
  and    paa.effective_start_date between p_start_date and p_end_date
  order by paa.effective_start_date;
  --
  --
  --
  Cursor change_grade_update(p_assignment_id number, p_asg_eff_start_date date,
         p_grade_id number) IS
  select 'Y'
  from   per_all_assignments_f paa
  where  paa.assignment_id = p_assignment_id
  and    paa.effective_end_date = (p_asg_eff_start_date-1)
  and    paa.grade_id <> p_grade_id
  and    p_grade_id is not null
  and    paa.grade_id is not null;
  --
  -- Start of 3335915
  /*
  --check for assignment update with same grade.
  --
  Cursor same_grade_update(p_assignment_id number, p_asg_eff_start_date date,
         p_grade_id number) IS
  select 'Y'
  from   per_all_assignments_f paa
  where  paa.assignment_id = p_assignment_id
  and    paa.effective_end_date = (p_asg_eff_start_date-1)
  and    paa.grade_id = p_grade_id;
  --
  */
  -- End of 3335915
  --
  --
  Cursor change_grade_to_null(p_assignment_id number, p_asg_eff_start_date date,
         p_grade_id number) IS
  select 'Y'
  from   per_all_assignments_f paa
  where  paa.assignment_id = p_assignment_id
  and    paa.effective_end_date = (p_asg_eff_start_date-1)
  and    paa.grade_id is not null
  and    p_grade_id is null;
  --
  -- Placement details.
  --
  Cursor spp_details(p_assignment_id number, p_effective_date date) IS
  select spp.placement_id
        ,spp.effective_start_date
        ,spp.effective_end_date
        ,spp.object_version_number
        ,spp.step_id
  from   per_spinal_point_placements_f spp
  where  spp.assignment_id = p_assignment_id
  and    p_effective_date between spp.effective_start_date and spp.effective_end_date;
  --
  --
  --
  l_proc varchar2(72) := g_package||'sync_spp_asg';
  l_assignment_id per_all_assignments_f.assignment_id%type;
  l_placement_id per_spinal_point_placements_f.placement_id%type;
  l_future_spp_id per_spinal_point_placements_f.placement_id%type;
  l_end_date DATE;
  l_validation_start_date DATE;
  l_validation_end_date DATE;
  l_spp_delete_warning BOOLEAN;
  l_asg_eff_start_date date;
  l_asg_eff_end_date date;
  l_spp_eff_start_date date;
  l_spp_eff_end_date date;
  l_object_version_number number;
  l_grade_id per_grades.grade_id%type;
  l_step_id per_spinal_point_steps_f.step_id%type;
  l_dummy varchar2(2);
  l_effective_start_date date;
  l_effective_end_date date;
--
BEGIN
--
  hr_utility.set_location('Entering '||l_proc, 10);
  --
  l_end_date := null;
  l_assignment_id := p_assignment_id;

  -- End date SPP.
  open future_spps(p_assignment_id, p_effective_date);
  fetch future_spps into l_future_spp_id;
  if future_spps%found then
  --
    open spp_end_date(p_assignment_id, p_effective_date);
    fetch spp_end_date into l_end_date;
    if spp_end_date%found and l_end_date is not null then
    --
      open spp_details(p_assignment_id, p_effective_date);
      fetch spp_details into l_placement_id, l_spp_eff_start_date, l_spp_eff_end_date,
                             l_object_version_number, l_step_id;
      if spp_details%found then
      --
        hr_utility.set_location(l_proc, 20);
        hr_sp_placement_api.delete_spp
                (p_validate		  => false
                ,p_effective_date	  => l_end_date
                ,p_datetrack_mode	  => 'DELETE'
                ,p_placement_id		  => l_placement_id
                ,p_object_version_number  => l_object_version_number
                ,p_effective_start_date	  => l_effective_start_date
                ,p_effective_end_date	  => l_effective_end_date
                );
      --
      end if;
      close spp_details;
    --
    end if;
    close spp_end_date;
  --
  end if;
  close future_spps;
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Keep the SPPs in synchronous with Assignment updates.
  --
  l_validation_start_date := p_effective_date+1;
  l_validation_end_date   := nvl(l_end_date,hr_api.g_eot);
  --
  FOR asg_rec in asg_updates(p_assignment_id, l_validation_start_date, l_validation_end_date)  LOOP
  --
    l_asg_eff_start_date := asg_rec.effective_start_date;
    l_asg_eff_end_date   := asg_rec.effective_end_date;
    l_grade_id := asg_rec.grade_id;
    l_dummy := 'N';
    l_placement_id := null;
    l_object_version_number := null;

   hr_utility.set_location('Assignment ID '||l_assignment_id, 40);
   hr_utility.set_location('Effective start date '||l_asg_eff_start_date, 40);
   hr_utility.set_location('Effective end date '||l_asg_eff_end_date, 40);
   hr_utility.set_location('Grade ID '||l_grade_id, 40);
   --
   -- Start of 3335915
   /*
   open same_grade_update(l_assignment_id, l_asg_eff_start_date, l_grade_id);
   fetch same_grade_update into l_dummy;
   if same_grade_update%found and l_dummy ='Y' then
      hr_utility.set_location('Assignment update is not a Grade Update', 50);
      --
      open spp_details(l_assignment_id, l_asg_eff_start_date);
      fetch spp_details into l_placement_id, l_spp_eff_start_date,
	                       l_spp_eff_end_date, l_object_version_number, l_step_id;
      --
      if spp_details%found then
        hr_utility.set_location('SPP found', 60);
        hr_utility.set_location('Placement ID: '||l_placement_id, 60);
	hr_utility.set_location('Effective start date: '||l_spp_eff_start_date, 60);
	hr_utility.set_location('Effective end date: '||l_spp_eff_end_date, 60);
	hr_utility.set_location('Object version number: '||l_object_version_number, 60);
	hr_utility.set_location('Step ID: '||l_step_id, 60);
        --
	BEGIN
	    hr_utility.set_location(l_proc, 70);
		hr_sp_placement_api.update_spp
	   	              (p_effective_date        => l_asg_eff_start_date
			      ,p_datetrack_mode        => 'UPDATE'
			      ,p_placement_id          => l_placement_id
			      ,p_object_version_number => l_object_version_number
			      ,p_step_id               => l_step_id
			      ,p_effective_start_date  => l_effective_start_date
			      ,p_effective_end_date    => l_effective_end_date);
	EXCEPTION
         when others then
	        hr_utility.trace('Cannot process Placement id '||to_char(l_placement_id));
                hr_utility.trace('Effective start date '||to_char(l_spp_eff_start_date));
                hr_utility.trace('Encountered error - ORA: '||to_char(SQLCODE));
        END;
	--
     else
     	hr_utility.set_location(l_proc||' No SPP found.', 80);
     end if;
     close spp_details;
   end if;
   close same_grade_update;
   --
   */
   -- End of 3335915
   --
   --
   open change_grade_to_null(l_assignment_id, l_asg_eff_start_date, l_grade_id);
   fetch change_grade_to_null into l_dummy;
   if change_grade_to_null%found and l_dummy = 'Y' then

      hr_utility.set_location('Updation on Assignment was grade to null ', 90);
      hr_utility.set_location('End date the SPP', 90);

      open spp_details(l_assignment_id, l_asg_eff_start_date);
      fetch spp_details into l_placement_id, l_spp_eff_start_date,
	                       l_spp_eff_end_date, l_object_version_number, l_step_id;
      if spp_details%found then
        hr_utility.set_location('SPP found', 100);
        hr_utility.set_location('Placement ID: '||l_placement_id, 100);
	hr_utility.set_location('Effective start date: '||l_spp_eff_start_date, 100);
	hr_utility.set_location('Effective end date: '||l_spp_eff_end_date, 100);
	hr_utility.set_location('Object version number: '||l_object_version_number, 100);
	hr_utility.set_location('Step ID: '||l_step_id, 100);
        --
	BEGIN
        hr_sp_placement_api.delete_spp
                (p_validate		  => false
                ,p_effective_date	  => l_asg_eff_start_date-1
                ,p_datetrack_mode	  => 'DELETE'
                ,p_placement_id		  => l_placement_id
                ,p_object_version_number  => l_object_version_number
                ,p_effective_start_date	  => l_effective_start_date
                ,p_effective_end_date	  => l_effective_end_date
                );
          hr_utility.set_location('SPP end dated with '||
	                (to_char((l_asg_eff_start_date-1),'DD-MON-RRRR')), 110);

        EXCEPTION
	 when others then
                hr_utility.trace('Cannot process Placement id '||to_char(l_placement_id));
                hr_utility.trace('Effective start date '||to_char(l_spp_eff_start_date));
                hr_utility.trace('Encountered error - ORA: '||to_char(SQLCODE));
        END;
	--
      else
        hr_utility.set_location('No SPP found.', 120);
      end if;
      close spp_details;

   end if;
   close change_grade_to_null;
   hr_utility.set_location(l_proc, 125);
   --
   --
   --
   open change_grade_update(l_assignment_id, l_asg_eff_start_date, l_grade_id);
   fetch change_grade_update into l_dummy;
   if change_grade_update%found and l_dummy = 'Y' then

        hr_utility.set_location('Updation on Assignment was Grade1 to Grade2 ', 130);
        hr_utility.set_location('So if any SPP found then update with lowest step_id', 130);

        open spp_details(l_assignment_id, l_asg_eff_start_date);
	fetch spp_details into l_placement_id, l_spp_eff_start_date,
	                       l_spp_eff_end_date, l_object_version_number,l_step_id;

        if spp_details%found then

            hr_utility.set_location('SPP found', 140);
            hr_utility.set_location('Placement ID: '||l_placement_id, 140);
	    hr_utility.set_location('Effective start date: '||l_spp_eff_start_date, 140);
	    hr_utility.set_location('Effective end date: '||l_spp_eff_end_date, 140);
	    hr_utility.set_location('Object version number: '||l_object_version_number, 140);
	    hr_utility.set_location('Step ID: '||l_step_id, 140);

	    hr_assignment_internal.maintain_spp_asg
                             (p_assignment_id          => l_assignment_id
                             ,p_datetrack_mode        => 'UPDATE'
                             ,p_validation_start_date => l_asg_eff_start_date
                             ,p_validation_end_date   => l_asg_eff_end_date
                             ,p_grade_id	      => l_grade_id
                             ,p_spp_delete_warning    => l_spp_delete_warning);
	else

           hr_utility.set_location('No SPP found.', 160);

        end if;
	close spp_details;


   end if;
   close change_grade_update;
   hr_utility.set_location(l_proc, 170);
  --
  END LOOP;
  hr_utility.set_location('Leaving '||l_proc, 180);
  --
END Sync_spp_asg;
--
-- Bug 2977842 ends here.
--
-------------------------------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |----------------------------< post_insert >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   insert dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
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
--   Any post-processing required after the insert dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert
  (p_rec                   in per_spp_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ,p_replace_future_spp    in boolean  -- Added for bug 2977842.
  ) is
--
  l_proc	varchar2(72) := g_package||'post_insert';
--  Code changes start for bug 7457065
l_step_end_date        per_spinal_point_steps_f.effective_end_date%type;

  cursor c_step_end_date is
    select max(effective_end_date)
    from per_spinal_point_steps_f
    where step_id = p_rec.step_id;
--  Code changes end for bug 7457065

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- Code changes start for bug 7457065
  open c_step_end_date;
  fetch c_step_end_date into l_step_end_date;
  close c_step_end_date;
  --
  hr_utility.set_location(l_proc, 6);
  --
  if l_step_end_date < p_rec.effective_end_date then

    update per_spinal_point_placements_f
    set effective_end_date = l_step_end_date
    where placement_id = p_rec.placement_id
    and effective_start_date = p_rec.effective_start_date;

  end if;
  hr_utility.set_location(l_proc, 7);

  -- Code changes end for bug 7457065

  begin
    --
    per_spp_rki.after_insert
      (p_effective_date          => p_effective_date
      ,p_validation_start_date   => p_validation_start_date
      ,p_validation_end_date     => p_validation_end_date
      ,p_placement_id            => p_rec.placement_id
      ,p_effective_start_date    => p_rec.effective_start_date
      ,p_effective_end_date      => p_rec.effective_end_date
      ,p_business_group_id       => p_rec.business_group_id
      ,p_assignment_id           => p_rec.assignment_id
      ,p_step_id                 => p_rec.step_id
      ,p_auto_increment_flag     => p_rec.auto_increment_flag
      ,p_parent_spine_id         => p_rec.parent_spine_id
      ,p_reason                  => p_rec.reason
      ,p_request_id              => p_rec.request_id
      ,p_program_application_id  => p_rec.program_application_id
      ,p_program_id              => p_rec.program_id
      ,p_program_update_date     => p_rec.program_update_date
      ,p_increment_number        => p_rec.increment_number
      ,p_object_version_number   => p_rec.object_version_number
      ,p_information1            => p_rec.information1
      ,p_information2            => p_rec.information2
      ,p_information3            => p_rec.information3
      ,p_information4            => p_rec.information4
      ,p_information5            => p_rec.information5
      ,p_information6            => p_rec.information6
      ,p_information7            => p_rec.information7
      ,p_information8            => p_rec.information8
      ,p_information9            => p_rec.information9
      ,p_information10           => p_rec.information10
      ,p_information11           => p_rec.information11
      ,p_information12           => p_rec.information12
      ,p_information13           => p_rec.information13
      ,p_information14           => p_rec.information14
      ,p_information15           => p_rec.information15
      ,p_information16           => p_rec.information16
      ,p_information17           => p_rec.information17
      ,p_information18           => p_rec.information18
      ,p_information19           => p_rec.information19
      ,p_information20           => p_rec.information20
      ,p_information21           => p_rec.information21
      ,p_information22           => p_rec.information22
      ,p_information23           => p_rec.information23
      ,p_information24           => p_rec.information24
      ,p_information25           => p_rec.information25
      ,p_information26           => p_rec.information26
      ,p_information27           => p_rec.information27
      ,p_information28           => p_rec.information28
      ,p_information29           => p_rec.information29
      ,p_information30           => p_rec.information30
      ,p_information_category    => p_rec.information_category
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_SPINAL_POINT_PLACEMENTS_F'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  -- Bug 2977842 starts here.
  if p_replace_future_spp then
  --
     per_spp_ins.delete_future_spps(p_assignment_id  => p_rec.assignment_id
                                  ,p_effective_date => p_effective_date);
  --
  end if;
  --
  per_spp_ins.sync_spp_asg(p_assignment_id  => p_rec.assignment_id
                          ,p_effective_date => p_effective_date);
  --
  --Bug 2977842 ends here.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< ins_lck >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The ins_lck process has one main function to perform. When inserting
--   a datetracked row, we must validate the DT mode.
--
-- Prerequisites:
--   This procedure can only be called for the datetrack mode of INSERT.
--
-- In Parameters:
--
-- Post Success:
--   On successful completion of the ins_lck process the parental
--   datetracked rows will be locked providing the p_enforce_foreign_locking
--   argument value is TRUE.
--   If the p_enforce_foreign_locking argument value is FALSE then the
--   parential rows are not locked.
--
-- Post Failure:
--   The Lck process can fail for:
--   1) When attempting to lock the row the row could already be locked by
--      another user. This will raise the HR_Api.Object_Locked exception.
--   2) When attempting to the lock the parent which doesn't exist.
--      For the entity to be locked the parent must exist!
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins_lck
  (p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_rec                   in per_spp_shd.g_rec_type
  ,p_validation_start_date out nocopy date
  ,p_validation_end_date   out nocopy date
  ) is
--
  l_proc		  varchar2(72) := g_package||'ins_lck';
  l_validation_start_date date;
  l_validation_end_date	  date;
  --bug 3158554 starts here.
  -- Additional local variables
  l_validation_start_date1  date;
  l_validation_start_date2  date;
  l_validation_end_date1    date;
  l_validation_end_date2    date;
  l_enforce_foreign_locking boolean;
  -- bug 3158554 ends here.
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Validate the datetrack mode mode getting the validation start
  -- and end dates for the specified datetrack operation.
  --
  -- bug 3158554 start here.
  --
  -- Always perform locking for set-up data parent
  -- tables, unless this is a Data Pump session AND
  -- the 'PUMP_DT_ENFORCE_FOREIGN_LOCKS' switch
  -- has been set to no.
  if hr_pump_utils.current_session_running then
    l_enforce_foreign_locking := hr_pump_utils.dt_enforce_foreign_locks;
  else
     l_enforce_foreign_locking := true;
  end if;

  dt_api.validate_dt_mode
    (p_effective_date	       => p_effective_date
    ,p_datetrack_mode          => p_datetrack_mode
    ,p_base_table_name         => 'per_spinal_point_placements_f'
    ,p_base_key_column         => 'placement_id'
    ,p_base_key_value          => p_rec.placement_id
    ,p_parent_table_name1      => 'per_spinal_point_steps_f'
    ,p_parent_key_column1      => 'step_id'
    ,p_parent_key_value1       => p_rec.step_id
   -- ,p_parent_table_name2      => 'per_all_assignments_f'
   -- ,p_parent_key_column2      => 'assignment_id'
   -- ,p_parent_key_value2       => p_rec.assignment_id
    ,p_enforce_foreign_locking => l_enforce_foreign_locking
    ,p_validation_start_date   => l_validation_start_date1
    ,p_validation_end_date     => l_validation_end_date1
    );
  --
  -- Always perform locking for transaction data parent tables.
  --
  dt_api.validate_dt_mode
    (p_effective_date	       => p_effective_date
    ,p_datetrack_mode          => p_datetrack_mode
    ,p_base_table_name         => 'per_spinal_point_placements_f'
    ,p_base_key_column         => 'placement_id'
    ,p_base_key_value          => p_rec.placement_id
    --,p_parent_table_name1      => 'per_spinal_point_steps_f'
    --,p_parent_key_column1      => 'step_id'
    --,p_parent_key_value1       => p_rec.step_id
    ,p_parent_table_name2      => 'per_all_assignments_f'
    ,p_parent_key_column2      => 'assignment_id'
    ,p_parent_key_value2       => p_rec.assignment_id
    ,p_enforce_foreign_locking => true
    ,p_validation_start_date   => l_validation_start_date2
    ,p_validation_end_date     => l_validation_end_date2
    );

  --
  -- Set the validation start and end date OUT arguments
  -- taking the most restrictive replies from the two calls
  -- to dt_api.validate_dt_mode. i.e. The latest VSD and the
  -- earliest VED.
  --
  if l_validation_start_date1 > l_validation_start_date2 then
    p_validation_start_date := l_validation_start_date1;
  else
    p_validation_start_date := l_validation_start_date2;
  end if;
  --
  if l_validation_end_date1 > l_validation_end_date2 then
    p_validation_end_date := l_validation_end_date2;
  else
    p_validation_end_date := l_validation_end_date1;
  end if;

  --p_validation_start_date := l_validation_start_date;
  --p_validation_end_date   := l_validation_end_date;
  --
  -- bug 3158554 ends here..
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End ins_lck;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date in     date
  ,p_rec            in out nocopy per_spp_shd.g_rec_type
  ,p_replace_future_spp in boolean -- Added for bug 2977842.
  ) is
--
  l_proc                        varchar2(72) := g_package||'ins';
  l_datetrack_mode              varchar2(30) := hr_api.g_insert;
  l_validation_start_date       date;
  l_validation_end_date         date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  per_spp_bus.insert_validate
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call the lock operation
  --
  per_spp_ins.ins_lck
    (p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_rec                   => p_rec
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call the supporting insert validate operations
  --
  per_spp_bus.insert_validate
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );

  --
  -- Call the supporting pre-insert operation
  --
  per_spp_ins.pre_insert
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Insert the row
  --
  per_spp_ins.insert_dml
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call the supporting post-insert operation
  --

  per_spp_ins.post_insert
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    ,p_replace_future_spp    => p_replace_future_spp  --Added for bug 2977842.
    );

  --
  hr_utility.set_location('Leaving:'||l_proc,10);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_assignment_id                  in     number
  ,p_step_id                        in     number
  ,p_auto_increment_flag            in     varchar2
   --  ,p_parent_spine_id           in     number
  ,p_reason                         in     varchar2
  ,p_request_id                     in     number
  ,p_program_application_id         in     number
  ,p_program_id                     in     number
  ,p_program_update_date            in     date
  ,p_increment_number               in     number
  ,p_information1                   in     varchar2
  ,p_information2                   in     varchar2
  ,p_information3                   in     varchar2
  ,p_information4                   in     varchar2
  ,p_information5                   in     varchar2
  ,p_information6                   in     varchar2
  ,p_information7                   in     varchar2
  ,p_information8                   in     varchar2
  ,p_information9                   in     varchar2
  ,p_information10                  in     varchar2
  ,p_information11                  in     varchar2
  ,p_information12                  in     varchar2
  ,p_information13                  in     varchar2
  ,p_information14                  in     varchar2
  ,p_information15                  in     varchar2
  ,p_information16                  in     varchar2
  ,p_information17                  in     varchar2
  ,p_information18                  in     varchar2
  ,p_information19                  in     varchar2
  ,p_information20                  in     varchar2
  ,p_information21                  in     varchar2
  ,p_information22                  in     varchar2
  ,p_information23                  in     varchar2
  ,p_information24                  in     varchar2
  ,p_information25                  in     varchar2
  ,p_information26                  in     varchar2
  ,p_information27                  in     varchar2
  ,p_information28                  in     varchar2
  ,p_information29                  in     varchar2
  ,p_information30                  in     varchar2
  ,p_information_category           in     varchar2
  ,p_placement_id                      out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_effective_start_date              out nocopy date
  ,p_effective_end_date                out nocopy date
  ,p_replace_future_spp             in     boolean   -- Added bug 2977842.
  ) is
  --
  l_rec         per_spp_shd.g_rec_type;
  l_proc        varchar2(72) := g_package||'ins';
  l_parent_spine_id	per_spinal_point_placements_f.parent_spine_id%TYPE;
  --
  cursor chk_step_valid_for_grade is
  select parent_spine_id
    from per_grade_spines_f pgs,
         per_all_assignments_f paa
   where paa.grade_id = pgs.grade_id
   and   paa.assignment_id = p_assignment_id
   and   p_effective_date between paa.effective_start_date
	                    		       and paa.effective_end_date
    and  p_effective_date between pgs.effective_start_date
			                           and pgs.effective_end_date;
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Get the parent_spine_id (Not passed in api as updated in the assignment
  --                          form)
  --
  open chk_step_valid_for_grade;
  fetch chk_step_valid_for_grade into l_parent_spine_id;
  --
  if chk_step_valid_for_grade%notfound then
    --
    close chk_step_valid_for_grade;
    --
    fnd_message.set_name('PER', 'HR_289834_STEP_INV_FOR_GRADE');
    hr_utility.raise_error;
    --
  end if;
  --
  close chk_step_valid_for_grade;
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  per_spp_shd.convert_args
    (null
    ,null
    ,null
    ,p_business_group_id
    ,p_assignment_id
    ,p_step_id
    ,p_auto_increment_flag
    ,l_parent_spine_id
    ,p_reason
    ,p_request_id
    ,p_program_application_id
    ,p_program_id
    ,p_program_update_date
    ,p_increment_number
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
    ,p_information_category
    ,null
    );
  --
  -- Having converted the arguments into the per_spp_rec
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  per_spp_ins.ins
    (p_effective_date
    ,l_rec
    ,p_replace_future_spp  --Added bug2977842.
    );
  --
  -- Set the OUT arguments.
  --
  p_placement_id                     := l_rec.placement_id;
  p_effective_start_date             := l_rec.effective_start_date;
  p_effective_end_date               := l_rec.effective_end_date;
  p_object_version_number            := l_rec.object_version_number;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 999);
  --
End ins;
--
end per_spp_ins;

/
