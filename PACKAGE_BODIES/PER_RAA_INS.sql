--------------------------------------------------------
--  DDL for Package Body PER_RAA_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RAA_INS" as
/* $Header: peraarhi.pkb 115.20 2003/11/21 02:05:11 vvayanip ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_raa_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_recruitment_activity_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_recruitment_activity_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  per_raa_ins.g_recruitment_activity_id_i := p_recruitment_activity_id;
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
Procedure insert_dml
  (p_rec in out nocopy per_raa_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
  l_recruiting_site_response clob;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  --
  -- Insert the row into: per_recruitment_activities
  --
  insert into per_recruitment_activities
      (recruitment_activity_id
      ,business_group_id
      ,authorising_person_id
      ,run_by_organization_id
      ,internal_contact_person_id
      ,parent_recruitment_activity_id
      ,currency_code
      ,date_start
      ,name
      ,actual_cost
      ,comments
      ,contact_telephone_number
      ,date_closing
      ,date_end
      ,external_contact
      ,planned_cost
      ,recruiting_site_id
      ,recruiting_site_response
      ,last_posted_date
      ,type
      ,request_id
      ,program_application_id
      ,program_id
      ,program_update_date
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,attribute16
      ,attribute17
      ,attribute18
      ,attribute19
      ,attribute20
      ,posting_content_id
      ,status
      ,object_version_number
      )
  Values
    (p_rec.recruitment_activity_id
    ,p_rec.business_group_id
    ,p_rec.authorising_person_id
    ,p_rec.run_by_organization_id
    ,p_rec.internal_contact_person_id
    ,p_rec.parent_recruitment_activity_id
    ,p_rec.currency_code
    ,p_rec.date_start
    ,p_rec.name
    ,p_rec.actual_cost
    ,p_rec.comments
    ,p_rec.contact_telephone_number
    ,p_rec.date_closing
    ,p_rec.date_end
    ,p_rec.external_contact
    ,p_rec.planned_cost
    ,p_rec.recruiting_site_id
    ,empty_clob()
    ,p_rec.last_posted_date
    ,p_rec.type
    ,p_rec.request_id
    ,p_rec.program_application_id
    ,p_rec.program_id
    ,p_rec.program_update_date
    ,p_rec.attribute_category
    ,p_rec.attribute1
    ,p_rec.attribute2
    ,p_rec.attribute3
    ,p_rec.attribute4
    ,p_rec.attribute5
    ,p_rec.attribute6
    ,p_rec.attribute7
    ,p_rec.attribute8
    ,p_rec.attribute9
    ,p_rec.attribute10
    ,p_rec.attribute11
    ,p_rec.attribute12
    ,p_rec.attribute13
    ,p_rec.attribute14
    ,p_rec.attribute15
    ,p_rec.attribute16
    ,p_rec.attribute17
    ,p_rec.attribute18
    ,p_rec.attribute19
    ,p_rec.attribute20
    ,p_rec.posting_content_id
    ,p_rec.status
    ,p_rec.object_version_number
    ) returning recruiting_site_response into l_recruiting_site_response;
  --
  --
    if (p_rec.recruiting_site_response is not null) then
      hr_utility.set_location(l_proc, 10);
      dbms_lob.write(l_recruiting_site_response
                    ,length(p_rec.recruiting_site_response)
                    ,1
                    ,p_rec.recruiting_site_response);
    end if;

  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    per_raa_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    per_raa_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    per_raa_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
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
  (p_rec  in out nocopy per_raa_shd.g_rec_type
  ) is
--
  Cursor C_Sel1 is select per_recruitment_activities_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from per_recruitment_activities
     where recruitment_activity_id =
             per_raa_ins.g_recruitment_activity_id_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (per_raa_ins.g_recruitment_activity_id_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','per_recruitment_activities');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.recruitment_activity_id :=
      per_raa_ins.g_recruitment_activity_id_i;
    per_raa_ins.g_recruitment_activity_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.recruitment_activity_id;
    Close C_Sel1;
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
--   This private procedure contains any processing which is required after
--   the insert dml.
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
Procedure post_insert
  (p_rec                          in per_raa_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_raa_rki.after_insert
      (p_recruitment_activity_id
      => p_rec.recruitment_activity_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_authorising_person_id
      => p_rec.authorising_person_id
      ,p_run_by_organization_id
      => p_rec.run_by_organization_id
      ,p_internal_contact_person_id
      => p_rec.internal_contact_person_id
      ,p_parent_recruitment_activity
      => p_rec.parent_recruitment_activity_id
      ,p_currency_code
      => p_rec.currency_code
      ,p_date_start
      => p_rec.date_start
      ,p_name
      => p_rec.name
      ,p_actual_cost
      => p_rec.actual_cost
      ,p_comments
      => p_rec.comments
      ,p_contact_telephone_number
      => p_rec.contact_telephone_number
      ,p_date_closing
      => p_rec.date_closing
      ,p_date_end
      => p_rec.date_end
      ,p_external_contact
      => p_rec.external_contact
      ,p_planned_cost
      => p_rec.planned_cost
      ,p_recruiting_site_id
      => p_rec.recruiting_site_id
      ,p_recruiting_site_response
      => p_rec.recruiting_site_response
      ,p_last_posted_date
      => p_rec.last_posted_date
      ,p_type
      => p_rec.type
      ,p_request_id
      => p_rec.request_id
      ,p_program_application_id
      => p_rec.program_application_id
      ,p_program_id
      => p_rec.program_id
      ,p_program_update_date
      => p_rec.program_update_date
      ,p_attribute_category
      => p_rec.attribute_category
      ,p_attribute1
      => p_rec.attribute1
      ,p_attribute2
      => p_rec.attribute2
      ,p_attribute3
      => p_rec.attribute3
      ,p_attribute4
      => p_rec.attribute4
      ,p_attribute5
      => p_rec.attribute5
      ,p_attribute6
      => p_rec.attribute6
      ,p_attribute7
      => p_rec.attribute7
      ,p_attribute8
      => p_rec.attribute8
      ,p_attribute9
      => p_rec.attribute9
      ,p_attribute10
      => p_rec.attribute10
      ,p_attribute11
      => p_rec.attribute11
      ,p_attribute12
      => p_rec.attribute12
      ,p_attribute13
      => p_rec.attribute13
      ,p_attribute14
      => p_rec.attribute14
      ,p_attribute15
      => p_rec.attribute15
      ,p_attribute16
      => p_rec.attribute16
      ,p_attribute17
      => p_rec.attribute17
      ,p_attribute18
      => p_rec.attribute18
      ,p_attribute19
      => p_rec.attribute19
      ,p_attribute20
      => p_rec.attribute20
      ,p_posting_content_id
      => p_rec.posting_content_id
      ,p_status
      => p_rec.status
      ,p_object_version_number
      => p_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_RECRUITMENT_ACTIVITIES'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_rec                          in out nocopy per_raa_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  per_raa_bus.insert_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  per_raa_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  per_raa_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  per_raa_ins.post_insert
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_business_group_id              in     number
  ,p_date_start                     in     date
  ,p_name                           in     varchar2
  ,p_authorising_person_id          in     number   default null
  ,p_run_by_organization_id         in     number   default null
  ,p_internal_contact_person_id     in     number   default null
  ,p_parent_recruitment_activity   in     number   default null
  ,p_currency_code                  in     varchar2 default null
  ,p_actual_cost                    in     varchar2 default null
  ,p_comments                       in     varchar2 default null
  ,p_contact_telephone_number       in     varchar2 default null
  ,p_date_closing                   in     date     default null
  ,p_date_end                       in     date     default null
  ,p_external_contact               in     varchar2 default null
  ,p_planned_cost                   in     varchar2 default null
  ,p_recruiting_site_id             in     number   default null
  ,p_recruiting_site_response       in     varchar2 default null
  ,p_last_posted_date               in     date     default null
  ,p_type                           in     varchar2 default null
  ,p_request_id                     in     number   default null
  ,p_program_application_id         in     number   default null
  ,p_program_id                     in     number   default null
  ,p_program_update_date            in     date     default null
  ,p_attribute_category             in     varchar2 default null
  ,p_attribute1                     in     varchar2 default null
  ,p_attribute2                     in     varchar2 default null
  ,p_attribute3                     in     varchar2 default null
  ,p_attribute4                     in     varchar2 default null
  ,p_attribute5                     in     varchar2 default null
  ,p_attribute6                     in     varchar2 default null
  ,p_attribute7                     in     varchar2 default null
  ,p_attribute8                     in     varchar2 default null
  ,p_attribute9                     in     varchar2 default null
  ,p_attribute10                    in     varchar2 default null
  ,p_attribute11                    in     varchar2 default null
  ,p_attribute12                    in     varchar2 default null
  ,p_attribute13                    in     varchar2 default null
  ,p_attribute14                    in     varchar2 default null
  ,p_attribute15                    in     varchar2 default null
  ,p_attribute16                    in     varchar2 default null
  ,p_attribute17                    in     varchar2 default null
  ,p_attribute18                    in     varchar2 default null
  ,p_attribute19                    in     varchar2 default null
  ,p_attribute20                    in     varchar2 default null
  ,p_posting_content_id             in     number   default null
  ,p_status                         in     varchar2 default null
  ,p_recruitment_activity_id           out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec   per_raa_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  per_raa_shd.convert_args
    (null
    ,p_business_group_id
    ,p_authorising_person_id
    ,p_run_by_organization_id
    ,p_internal_contact_person_id
    ,p_parent_recruitment_activity
    ,p_currency_code
    ,p_date_start
    ,p_name
    ,p_actual_cost
    ,p_comments
    ,p_contact_telephone_number
    ,p_date_closing
    ,p_date_end
    ,p_external_contact
    ,p_planned_cost
    ,p_recruiting_site_id
    ,p_recruiting_site_response
    ,p_last_posted_date
    ,p_type
    ,p_request_id
    ,p_program_application_id
    ,p_program_id
    ,p_program_update_date
    ,p_attribute_category
    ,p_attribute1
    ,p_attribute2
    ,p_attribute3
    ,p_attribute4
    ,p_attribute5
    ,p_attribute6
    ,p_attribute7
    ,p_attribute8
    ,p_attribute9
    ,p_attribute10
    ,p_attribute11
    ,p_attribute12
    ,p_attribute13
    ,p_attribute14
    ,p_attribute15
    ,p_attribute16
    ,p_attribute17
    ,p_attribute18
    ,p_attribute19
    ,p_attribute20
    ,p_posting_content_id
    ,p_status
    ,null
    );
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Having converted the arguments into the per_raa_rec
  -- plsql record structure we call the corresponding record business process.
  --
  per_raa_ins.ins
     (l_rec
     );
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_recruitment_activity_id := l_rec.recruitment_activity_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
End ins;
--
end per_raa_ins;

/
