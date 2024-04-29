--------------------------------------------------------
--  DDL for Package Body OTA_NHS_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_NHS_INS" as
/* $Header: otnhsrhi.pkb 120.1 2005/09/30 05:00:04 ssur noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_nhs_ins.';  -- Global package name
--
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_nota_history_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_nota_history_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  ota_nhs_ins.g_nota_history_id_i := p_nota_history_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End set_base_key_value;
--
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
-- Prerequisites:
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml(p_rec in out nocopy ota_nhs_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ota_nhs_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ota_notrng_histories
  --
  insert into ota_notrng_histories
  (   nota_history_id,
   person_id,
   contact_id,
   trng_title,
   provider,
   type,
   centre,
   completion_date,
   award,
   rating,
   duration,
   duration_units,
   activity_version_id,
   status,
   verified_by_id,
   nth_information_category,
   nth_information1,
   nth_information2,
   nth_information3,
   nth_information4,
   nth_information5,
   nth_information6,
   nth_information7,
   nth_information8,
   nth_information9,
   nth_information10,
   nth_information11,
   nth_information12,
   nth_information13,
   nth_information15,
   nth_information16,
   nth_information17,
   nth_information18,
   nth_information19,
   nth_information20,
   org_id,
   object_version_number,
   business_group_id,
   nth_information14,
        customer_id,
        organization_id
  )
  Values
  (   p_rec.nota_history_id,
   p_rec.person_id,
   p_rec.contact_id,
   p_rec.trng_title,
   p_rec.provider,
   p_rec.type,
   p_rec.centre,
   p_rec.completion_date,
   p_rec.award,
   p_rec.rating,
   p_rec.duration,
   p_rec.duration_units,
   p_rec.activity_version_id,
   p_rec.status,
   p_rec.verified_by_id,
   p_rec.nth_information_category,
   p_rec.nth_information1,
   p_rec.nth_information2,
   p_rec.nth_information3,
   p_rec.nth_information4,
   p_rec.nth_information5,
   p_rec.nth_information6,
   p_rec.nth_information7,
   p_rec.nth_information8,
   p_rec.nth_information9,
   p_rec.nth_information10,
   p_rec.nth_information11,
   p_rec.nth_information12,
   p_rec.nth_information13,
   p_rec.nth_information15,
   p_rec.nth_information16,
   p_rec.nth_information17,
   p_rec.nth_information18,
   p_rec.nth_information19,
   p_rec.nth_information20,
   p_rec.org_id,
   p_rec.object_version_number,
   p_rec.business_group_id,
   p_rec.nth_information14,
        p_rec.customer_id,
        p_rec.organization_id
  );
  --
  ota_nhs_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ota_nhs_shd.g_api_dml := false;   -- Unset the api dml status
    ota_nhs_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ota_nhs_shd.g_api_dml := false;   -- Unset the api dml status
    ota_nhs_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ota_nhs_shd.g_api_dml := false;   -- Unset the api dml status
    ota_nhs_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ota_nhs_shd.g_api_dml := false;   -- Unset the api dml status
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
-- Prerequisites:
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert(p_rec  in out nocopy ota_nhs_shd.g_rec_type) is
--
  Cursor C_Sel1 is select ota_notrng_histories_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from ota_notrng_histories
     where nota_history_id =
             ota_nhs_ins.g_nota_history_id_i;
--
  l_exists varchar2(1);
  l_proc  varchar2(72) := g_package||'pre_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (ota_nhs_ins.g_nota_history_id_i is not null) Then
    --
    -- Verify registered primary key values not already in use
    --
    Open C_Sel2;
    Fetch C_Sel2 into l_exists;
    If C_Sel2%found Then
       Close C_Sel2;
       --
       -- The primary key values are already in use.
       --
       fnd_message.set_name('PER','PER_289391_KEY_ALREADY_USED');
       fnd_message.set_token('TABLE_NAME','ota_notrng_histories');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.nota_history_id :=
      ota_nhs_ins.g_nota_history_id_i;
    ota_nhs_ins.g_nota_history_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.nota_history_id;
    Close C_Sel1;
    --
  End If;
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
-- Prerequisites:
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert(p_effective_date in date,
      p_rec in ota_nhs_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  begin
    --
    ota_nhs_rki.after_insert
      (p_effective_date              => p_effective_date
      ,p_nota_history_id
      => p_rec.nota_history_id
      ,p_person_id
      => p_rec.person_id
      ,p_contact_id
      => p_rec.contact_id
      ,p_trng_title
      => p_rec.trng_title
      ,p_provider
      => p_rec.provider
      ,p_type
      => p_rec.type
      ,p_centre
      => p_rec.centre
      ,p_completion_date
      => p_rec.completion_date
      ,p_award
      => p_rec.award
      ,p_rating
      => p_rec.rating
      ,p_duration
      => p_rec.duration
      ,p_duration_units
      => p_rec.duration_units
      ,p_activity_version_id
      => p_rec.activity_version_id
      ,p_status
      => p_rec.status
      ,p_verified_by_id
      => p_rec.verified_by_id
      ,p_nth_information_category
      => p_rec.nth_information_category
      ,p_nth_information1
      => p_rec.nth_information1
      ,p_nth_information2
      => p_rec.nth_information2
      ,p_nth_information3
      => p_rec.nth_information3
      ,p_nth_information4
      => p_rec.nth_information4
      ,p_nth_information5
      => p_rec.nth_information5
      ,p_nth_information6
      => p_rec.nth_information6
      ,p_nth_information7
      => p_rec.nth_information7
      ,p_nth_information8
      => p_rec.nth_information8
      ,p_nth_information9
      => p_rec.nth_information9
      ,p_nth_information10
      => p_rec.nth_information10
      ,p_nth_information11
      => p_rec.nth_information11
      ,p_nth_information12
      => p_rec.nth_information12
      ,p_nth_information13
      => p_rec.nth_information13
      ,p_nth_information15
      => p_rec.nth_information15
      ,p_nth_information16
      => p_rec.nth_information16
      ,p_nth_information17
      => p_rec.nth_information17
      ,p_nth_information18
      => p_rec.nth_information18
      ,p_nth_information19
      => p_rec.nth_information19
      ,p_nth_information20
      => p_rec.nth_information20
   ,p_org_id
      => p_rec.org_id
      ,p_object_version_number
      => p_rec.object_version_number
   ,p_business_group_id
      => p_rec.business_group_id
      ,p_nth_information14
      => p_rec.nth_information14
   ,p_customer_id
      => p_rec.customer_id
      ,p_organization_id
      => p_rec.organization_id
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'OTA_NOTRNG_HISTORIES'
        ,p_hook_type   => 'AI');
      --
  end;

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date       in  date,
  p_rec        in out nocopy ota_nhs_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ota_nhs_bus.insert_validate(p_effective_date  ,
                              p_rec);
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
  post_insert(p_effective_date,
              p_rec);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date               in     date ,
  p_nota_history_id              out nocopy number,
  p_person_id                    in number,
  p_contact_id                   in number           default null,
  p_trng_title                   in varchar2,
  p_provider                     in varchar2         default null,
  p_type                         in varchar2         default null,
  p_centre                       in varchar2         default null,
  p_completion_date              in date,
  p_award                        in varchar2         default null,
  p_rating                       in varchar2         default null,
  p_duration                     in number           default null,
  p_duration_units               in varchar2         default null,
  p_activity_version_id          in number           default null,
  p_status                       in varchar2,
  p_verified_by_id               in number           default null,
  p_nth_information_category     in varchar2         default null,
  p_nth_information1             in varchar2         default null,
  p_nth_information2             in varchar2         default null,
  p_nth_information3             in varchar2         default null,
  p_nth_information4             in varchar2         default null,
  p_nth_information5             in varchar2         default null,
  p_nth_information6             in varchar2         default null,
  p_nth_information7             in varchar2         default null,
  p_nth_information8             in varchar2         default null,
  p_nth_information9             in varchar2         default null,
  p_nth_information10            in varchar2         default null,
  p_nth_information11            in varchar2         default null,
  p_nth_information12            in varchar2         default null,
  p_nth_information13            in varchar2         default null,
  p_nth_information15            in varchar2         default null,
  p_nth_information16            in varchar2         default null,
  p_nth_information17            in varchar2         default null,
  p_nth_information18            in varchar2         default null,
  p_nth_information19            in varchar2         default null,
  p_nth_information20            in varchar2         default null,
  p_org_id                       in number           default null,
  p_object_version_number        out nocopy number,
  p_business_group_id            in number,
  p_nth_information14            in varchar2         default null,
  p_customer_id          in number       default null,
  p_organization_id           in number        default null
  ) is
--
  l_rec    ota_nhs_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ota_nhs_shd.convert_args
  (
  null,
  p_person_id,
  p_contact_id,
  p_trng_title,
  p_provider,
  p_type,
  p_centre,
  p_completion_date,
  p_award,
  p_rating,
  p_duration,
  p_duration_units,
  p_activity_version_id,
  p_status,
  p_verified_by_id,
  p_nth_information_category,
  p_nth_information1,
  p_nth_information2,
  p_nth_information3,
  p_nth_information4,
  p_nth_information5,
  p_nth_information6,
  p_nth_information7,
  p_nth_information8,
  p_nth_information9,
  p_nth_information10,
  p_nth_information11,
  p_nth_information12,
  p_nth_information13,
  p_nth_information15,
  p_nth_information16,
  p_nth_information17,
  p_nth_information18,
  p_nth_information19,
  p_nth_information20,
  p_org_id,
  null,
  p_business_group_id,
  p_nth_information14,
  p_customer_id,
  p_organization_id
  );
  --
  -- Having converted the arguments into the ota_nhs_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(p_effective_date               ,
      l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_nota_history_id := l_rec.nota_history_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ota_nhs_ins;

/
