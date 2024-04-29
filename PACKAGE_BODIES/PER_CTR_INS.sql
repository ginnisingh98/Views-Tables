--------------------------------------------------------
--  DDL for Package Body PER_CTR_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CTR_INS" as
/* $Header: pectrrhi.pkb 120.2.12010000.3 2009/04/09 13:42:18 pchowdav ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_ctr_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_contact_relationship_id  number default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value (p_contact_relationship_id  in  number) is
    --
    l_proc       varchar2(72) := g_package||'set_base_key_value';
    --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  per_ctr_ins.g_contact_relationship_id := p_contact_relationship_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End set_base_key_value;

--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic. The processing of
--   this procedure are as follows:
--   1) Initialise the object_version_number to 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To insert the row into the schema.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the ins
--   procedure and must have all mandatory attributes set (except the
--   object_version_number which is initialised within this procedure).
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be inserted into the schema.
--
-- Post Failure:
--   On the insert dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml(p_rec in out nocopy per_ctr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  per_ctr_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: per_contact_relationships
  --
  insert into per_contact_relationships
  (   contact_relationship_id,
   business_group_id,
   person_id,
   contact_person_id,
   contact_type,
   comments,
   primary_contact_flag,
   request_id,
   program_application_id,
   program_id,
   program_update_date,
        date_start,
        start_life_reason_id,
        date_end,
        end_life_reason_id,
        rltd_per_rsds_w_dsgntr_flag,
        personal_flag,
   sequence_number,
        cont_attribute_category,
   cont_attribute1,
   cont_attribute2,
   cont_attribute3,
   cont_attribute4,
   cont_attribute5,
   cont_attribute6,
   cont_attribute7,
   cont_attribute8,
   cont_attribute9,
   cont_attribute10,
   cont_attribute11,
   cont_attribute12,
   cont_attribute13,
   cont_attribute14,
   cont_attribute15,
   cont_attribute16,
   cont_attribute17,
   cont_attribute18,
   cont_attribute19,
   cont_attribute20,
        cont_information_category,
   cont_information1,
   cont_information2,
   cont_information3,
   cont_information4,
   cont_information5,
   cont_information6,
   cont_information7,
   cont_information8,
   cont_information9,
   cont_information10,
   cont_information11,
   cont_information12,
   cont_information13,
   cont_information14,
   cont_information15,
   cont_information16,
   cont_information17,
   cont_information18,
   cont_information19,
   cont_information20,
   third_party_pay_flag,
   bondholder_flag,
        dependent_flag,
        beneficiary_flag,
   object_version_number
  )
  Values
  (   p_rec.contact_relationship_id,
   p_rec.business_group_id,
   p_rec.person_id,
   p_rec.contact_person_id,
   p_rec.contact_type,
   p_rec.comments,
   p_rec.primary_contact_flag,
   p_rec.request_id,
   p_rec.program_application_id,
   p_rec.program_id,
   p_rec.program_update_date,
        p_rec.date_start,
        p_rec.start_life_reason_id,
        p_rec.date_end,
        p_rec.end_life_reason_id,
        p_rec.rltd_per_rsds_w_dsgntr_flag,
        p_rec.personal_flag,
   p_rec.sequence_number,
   p_rec.cont_attribute_category,
   p_rec.cont_attribute1,
   p_rec.cont_attribute2,
   p_rec.cont_attribute3,
   p_rec.cont_attribute4,
   p_rec.cont_attribute5,
   p_rec.cont_attribute6,
   p_rec.cont_attribute7,
   p_rec.cont_attribute8,
   p_rec.cont_attribute9,
   p_rec.cont_attribute10,
   p_rec.cont_attribute11,
   p_rec.cont_attribute12,
   p_rec.cont_attribute13,
   p_rec.cont_attribute14,
   p_rec.cont_attribute15,
   p_rec.cont_attribute16,
   p_rec.cont_attribute17,
   p_rec.cont_attribute18,
   p_rec.cont_attribute19,
   p_rec.cont_attribute20,
   p_rec.cont_information_category,
   p_rec.cont_information1,
   p_rec.cont_information2,
   p_rec.cont_information3,
   p_rec.cont_information4,
   p_rec.cont_information5,
   p_rec.cont_information6,
   p_rec.cont_information7,
   p_rec.cont_information8,
   p_rec.cont_information9,
   p_rec.cont_information10,
   p_rec.cont_information11,
   p_rec.cont_information12,
   p_rec.cont_information13,
   p_rec.cont_information14,
   p_rec.cont_information15,
   p_rec.cont_information16,
   p_rec.cont_information17,
   p_rec.cont_information18,
   p_rec.cont_information19,
   p_rec.cont_information20,
   p_rec.third_party_pay_flag,
   p_rec.bondholder_flag,
        p_rec.dependent_flag,
        p_rec.beneficiary_flag,
   p_rec.object_version_number
  );
  --
  per_ctr_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_ctr_shd.g_api_dml := false;   -- Unset the api dml status
    per_ctr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    per_ctr_shd.g_api_dml := false;   -- Unset the api dml status
    per_ctr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_ctr_shd.g_api_dml := false;   -- Unset the api dml status
    per_ctr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_ctr_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
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
--
-- Pre Conditions:
--   This is an internal procedure which is called from the ins procedure.
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
--   Any pre-processing required before the insert dml is issued should be
--   coded within this procedure. As stated above, a good example is the
--   generation of a primary key number via a corresponding sequence.
--   It is important to note that any 3rd party maintenance should be reviewed
--   before placing in this procedure.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert(p_rec  in out nocopy per_ctr_shd.g_rec_type) is
    --
    l_proc  varchar2(72) := g_package||'pre_insert';
    --
    Cursor C_Sel1 is select per_contact_relationships_s.nextval from sys.dual;
    --
    Cursor C_Sel2 is
    select null
    from   per_contact_relationships
    where  contact_relationship_id = per_ctr_ins.g_contact_relationship_id;
    --
    l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  if per_ctr_ins.g_contact_relationship_id is not null then
    --
    -- Verify registered primary key values not already in use
    --
    Open  C_Sel2;
    Fetch C_Sel2 into l_exists;
    --
    If C_Sel2%found then
        close C_Sel2;
        --
        -- The primary key values are already in use.
        --
        fnd_message.set_name('PER','PER_289391_KEY_ALREADY_USED');
        fnd_message.set_token('TABLE_NAME','per_contact_relationships');
        fnd_message.raise_error;
    end if;
    close c_sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.contact_relationship_id := per_ctr_ins.g_contact_relationship_id;
    per_ctr_ins.g_contact_relationship_id := null;
    --
    else
        Open C_Sel1;
        Fetch C_Sel1 Into p_rec.contact_relationship_id;
        Close C_Sel1;
    end if;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_insert;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   insert dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the ins procedure.
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
--   Any post-processing required after the insert dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert(p_rec            in per_ctr_shd.g_rec_type,
                      p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
  --
  -- Start of Fix for WWBUG 1408379
  --
  l_old ben_con_ler.g_con_ler_rec;
  l_new ben_con_ler.g_con_ler_rec;
  --
  -- End of Fix for WWBUG 1408379
  --
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Start of API User Hook for post_insert.
  begin
    per_ctr_rki.after_insert
      (p_contact_relationship_id        => p_rec.contact_relationship_id
      ,p_business_group_id              => p_rec.business_group_id
      ,p_person_id                      => p_rec.person_id
      ,p_contact_person_id              => p_rec.contact_person_id
      ,p_contact_type                   => p_rec.contact_type
      ,p_comments                       => p_rec.comments
      ,p_primary_contact_flag           => p_rec.primary_contact_flag
      ,p_request_id                     => p_rec.request_id
      ,p_program_application_id         => p_rec.program_application_id
      ,p_program_id                     => p_rec.program_id
      ,p_program_update_date            => p_rec.program_update_date
      ,p_date_start                     => p_rec.date_start
      ,p_start_life_reason_id           => p_rec.start_life_reason_id
      ,p_date_end                       => p_rec.date_end
      ,p_end_life_reason_id             => p_rec.end_life_reason_id
      ,p_rltd_per_rsds_w_dsgntr_flag    => p_rec.rltd_per_rsds_w_dsgntr_flag
      ,p_personal_flag                  => p_rec.personal_flag
      ,p_sequence_number                => p_rec.sequence_number
      ,p_cont_attribute_category        => p_rec.cont_attribute_category
      ,p_cont_attribute1                => p_rec.cont_attribute1
      ,p_cont_attribute2                => p_rec.cont_attribute2
      ,p_cont_attribute3                => p_rec.cont_attribute3
      ,p_cont_attribute4                => p_rec.cont_attribute4
      ,p_cont_attribute5                => p_rec.cont_attribute5
      ,p_cont_attribute6                => p_rec.cont_attribute6
      ,p_cont_attribute7                => p_rec.cont_attribute7
      ,p_cont_attribute8                => p_rec.cont_attribute8
      ,p_cont_attribute9                => p_rec.cont_attribute9
      ,p_cont_attribute10               => p_rec.cont_attribute10
      ,p_cont_attribute11               => p_rec.cont_attribute11
      ,p_cont_attribute12               => p_rec.cont_attribute12
      ,p_cont_attribute13               => p_rec.cont_attribute13
      ,p_cont_attribute14               => p_rec.cont_attribute14
      ,p_cont_attribute15               => p_rec.cont_attribute15
      ,p_cont_attribute16               => p_rec.cont_attribute16
      ,p_cont_attribute17               => p_rec.cont_attribute17
      ,p_cont_attribute18               => p_rec.cont_attribute18
      ,p_cont_attribute19               => p_rec.cont_attribute19
      ,p_cont_attribute20               => p_rec.cont_attribute20
      ,p_cont_information_category        => p_rec.cont_information_category
      ,p_cont_information1                => p_rec.cont_information1
      ,p_cont_information2                => p_rec.cont_information2
      ,p_cont_information3                => p_rec.cont_information3
      ,p_cont_information4                => p_rec.cont_information4
      ,p_cont_information5                => p_rec.cont_information5
      ,p_cont_information6                => p_rec.cont_information6
      ,p_cont_information7                => p_rec.cont_information7
      ,p_cont_information8                => p_rec.cont_information8
      ,p_cont_information9                => p_rec.cont_information9
      ,p_cont_information10               => p_rec.cont_information10
      ,p_cont_information11               => p_rec.cont_information11
      ,p_cont_information12               => p_rec.cont_information12
      ,p_cont_information13               => p_rec.cont_information13
      ,p_cont_information14               => p_rec.cont_information14
      ,p_cont_information15               => p_rec.cont_information15
      ,p_cont_information16               => p_rec.cont_information16
      ,p_cont_information17               => p_rec.cont_information17
      ,p_cont_information18               => p_rec.cont_information18
      ,p_cont_information19               => p_rec.cont_information19
      ,p_cont_information20               => p_rec.cont_information20
      ,p_third_party_pay_flag           => p_rec.third_party_pay_flag
      ,p_bondholder_flag                => p_rec.bondholder_flag
      ,p_dependent_flag                 => p_rec.dependent_flag
      ,p_beneficiary_flag               => p_rec.beneficiary_flag
      ,p_object_version_number          => p_rec.object_version_number
      ,p_effective_date                 => p_effective_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_CONTACT_RELATIONSHIPS'
        ,p_hook_type   => 'AI'
        );
  end;
  --
  -- Start of Fix for 1408379
  --
  l_new.person_id := p_rec.person_id;
  l_new.contact_person_id := p_rec.contact_person_id;
  l_new.business_group_id := p_rec.business_group_id;
  l_new.date_start := p_rec.date_start;
  l_new.date_end := p_rec.date_end;
  l_new.contact_type := p_rec.contact_type;
  l_new.personal_flag := p_rec.personal_flag;
  l_new.start_life_reason_id := p_rec.start_life_reason_id;
  l_new.end_life_reason_id := p_rec.end_life_reason_id;
  l_new.rltd_per_rsds_w_dsgntr_flag := p_rec.rltd_per_rsds_w_dsgntr_flag;
  l_new.contact_relationship_id := p_rec.contact_relationship_id;
  --
  ben_con_ler.ler_chk(p_old            => l_old,
                      p_new            => l_new,
                      p_effective_date => p_effective_date);
  --
  -- End of Fix for 1408379
  --
  --
  -- End of API User Hook for post_insert.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec            in out nocopy per_ctr_shd.g_rec_type,
  p_effective_date in date,
  p_validate       in     boolean default false
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
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
    SAVEPOINT ins_per_ctr;
  End If;
  --
  -- Call the supporting insert validate operations
  --
  per_ctr_bus.insert_validate(p_rec
                             ,p_effective_date);
  --
  -- Call the supporting pre-insert operation
  --
  pre_insert(p_rec);
  --
  -- Insert the row
  --
  insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  post_insert(p_rec
             ,p_effective_date);
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
    ROLLBACK TO ins_per_ctr;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_contact_relationship_id     out nocopy number,
  p_business_group_id            in number,
  p_person_id                    in number,
  p_contact_person_id            in number,
  p_contact_type                 in varchar2,
  p_comments                     in long             default null,
  p_primary_contact_flag         in varchar2         default 'N',
  p_request_id                   in number           default null,
  p_program_application_id       in number           default null,
  p_program_id                   in number           default null,
  p_program_update_date          in date             default null,
  p_date_start                   in date             default null,
  p_start_life_reason_id         in number           default null,
  p_date_end                     in date             default null,
  p_end_life_reason_id           in number           default null,
  p_rltd_per_rsds_w_dsgntr_flag  in varchar2         default 'N',
  p_personal_flag                in varchar2         default 'N',
  p_sequence_number              in number           default null,
  p_cont_attribute_category      in varchar2         default null,
  p_cont_attribute1              in varchar2         default null,
  p_cont_attribute2              in varchar2         default null,
  p_cont_attribute3              in varchar2         default null,
  p_cont_attribute4              in varchar2         default null,
  p_cont_attribute5              in varchar2         default null,
  p_cont_attribute6              in varchar2         default null,
  p_cont_attribute7              in varchar2         default null,
  p_cont_attribute8              in varchar2         default null,
  p_cont_attribute9              in varchar2         default null,
  p_cont_attribute10             in varchar2         default null,
  p_cont_attribute11             in varchar2         default null,
  p_cont_attribute12             in varchar2         default null,
  p_cont_attribute13             in varchar2         default null,
  p_cont_attribute14             in varchar2         default null,
  p_cont_attribute15             in varchar2         default null,
  p_cont_attribute16             in varchar2         default null,
  p_cont_attribute17             in varchar2         default null,
  p_cont_attribute18             in varchar2         default null,
  p_cont_attribute19             in varchar2         default null,
  p_cont_attribute20             in varchar2         default null,
  p_cont_information_category      in varchar2         default null,
  p_cont_information1              in varchar2         default null,
  p_cont_information2              in varchar2         default null,
  p_cont_information3              in varchar2         default null,
  p_cont_information4              in varchar2         default null,
  p_cont_information5              in varchar2         default null,
  p_cont_information6              in varchar2         default null,
  p_cont_information7              in varchar2         default null,
  p_cont_information8              in varchar2         default null,
  p_cont_information9              in varchar2         default null,
  p_cont_information10             in varchar2         default null,
  p_cont_information11             in varchar2         default null,
  p_cont_information12             in varchar2         default null,
  p_cont_information13             in varchar2         default null,
  p_cont_information14             in varchar2         default null,
  p_cont_information15             in varchar2         default null,
  p_cont_information16             in varchar2         default null,
  p_cont_information17             in varchar2         default null,
  p_cont_information18             in varchar2         default null,
  p_cont_information19             in varchar2         default null,
  p_cont_information20             in varchar2         default null,
  p_third_party_pay_flag         in varchar2         default 'N',
  p_bondholder_flag              in varchar2         default 'N',
  p_dependent_flag               in varchar2         default 'N',
  p_beneficiary_flag             in varchar2         default 'N',
  p_object_version_number        out nocopy number,
  p_effective_date               in date      default null,
  p_validate                     in boolean   default false
) is
--
  l_rec    per_ctr_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  per_ctr_shd.convert_args
  (
  null,
  p_business_group_id,
  p_person_id,
  p_contact_person_id,
  p_contact_type,
  p_comments,
  p_primary_contact_flag,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
  p_date_start,
  p_start_life_reason_id,
  p_date_end,
  p_end_life_reason_id,
  p_rltd_per_rsds_w_dsgntr_flag,
  p_personal_flag,
  p_sequence_number,
  p_cont_attribute_category,
  p_cont_attribute1,
  p_cont_attribute2,
  p_cont_attribute3,
  p_cont_attribute4,
  p_cont_attribute5,
  p_cont_attribute6,
  p_cont_attribute7,
  p_cont_attribute8,
  p_cont_attribute9,
  p_cont_attribute10,
  p_cont_attribute11,
  p_cont_attribute12,
  p_cont_attribute13,
  p_cont_attribute14,
  p_cont_attribute15,
  p_cont_attribute16,
  p_cont_attribute17,
  p_cont_attribute18,
  p_cont_attribute19,
  p_cont_attribute20,
  p_cont_information_category,
  p_cont_information1,
  p_cont_information2,
  p_cont_information3,
  p_cont_information4,
  p_cont_information5,
  p_cont_information6,
  p_cont_information7,
  p_cont_information8,
  p_cont_information9,
  p_cont_information10,
  p_cont_information11,
  p_cont_information12,
  p_cont_information13,
  p_cont_information14,
  p_cont_information15,
  p_cont_information16,
  p_cont_information17,
  p_cont_information18,
  p_cont_information19,
  p_cont_information20,
  p_third_party_pay_flag,
  p_bondholder_flag,
  p_dependent_flag,
  p_beneficiary_flag,
  null
);
  --
  -- Having converted the arguments into the per_ctr_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec, p_effective_date, p_validate);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_contact_relationship_id := l_rec.contact_relationship_id;
  p_object_version_number := l_rec.object_version_number;
  --
-- Bug#885806: dbms_output call is replaced with hr_utility.trace call
   hr_utility.trace('RH OVN: '||l_rec.object_version_number);
-- dbms_output.put_line('RH OVN: '||l_rec.object_version_number);
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end per_ctr_ins;

/
