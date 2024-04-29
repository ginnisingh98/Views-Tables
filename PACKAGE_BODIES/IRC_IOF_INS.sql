--------------------------------------------------------
--  DDL for Package Body IRC_IOF_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_IOF_INS" as
/* $Header: iriofrhi.pkb 120.13.12010000.2 2009/03/06 06:12:46 kvenukop ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     private global definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_iof_ins.';  -- global package name
--
-- the following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_offer_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_offer_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
begin
  hr_utility.set_location('entering:'||l_proc, 10);
  --
  irc_iof_ins.g_offer_id_i := p_offer_id;
  --
  hr_utility.set_location(' leaving:'||l_proc, 20);
end set_base_key_value;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {start of comments}
--
-- description:
--   this procedure controls the actual dml insert logic. the processing of
--   this procedure are as follows:
--   1) initialise the object_version_number to 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) to set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) to insert the row into the schema.
--   4) to trap any constraint violations that may have occurred.
--   5) to raise any other errors.
--
-- prerequisites:
--   this is an internal private procedure which must be called from the ins
--   procedure and must have all mandatory attributes set (except the
--   object_version_number which is initialised within this procedure).
--
-- in parameters:
--   a pl/sql record structre.
--
-- post success:
--   the specified row will be inserted into the schema.
--
-- post failure:
--   on the insert dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   if a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   if any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- developer implementation notes:
--   none.
--
-- access status:
--   internal row handler use only.
--
-- {end of comments}
-- ----------------------------------------------------------------------------
procedure insert_dml
  (p_rec in out nocopy irc_iof_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
begin
  hr_utility.set_location('entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- initialise the object version
  --
  --
  --
  -- insert the row into: irc_offers
  --
  insert into irc_offers
      (offer_id
      ,offer_version
      ,latest_offer
      ,offer_status
      ,discretionary_job_title
      ,offer_extended_method
      ,respondent_id
      ,expiry_date
      ,proposed_start_date
      ,offer_letter_tracking_code
      ,offer_postal_service
      ,offer_shipping_date
      ,vacancy_id
      ,applicant_assignment_id
      ,offer_assignment_id
      ,address_id
      ,template_id
      ,offer_letter
      ,offer_letter_file_type
      ,offer_letter_file_name
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
      ,attribute21
      ,attribute22
      ,attribute23
      ,attribute24
      ,attribute25
      ,attribute26
      ,attribute27
      ,attribute28
      ,attribute29
      ,attribute30
      ,object_version_number
      )
  values
    (p_rec.offer_id
    ,p_rec.offer_version
    ,p_rec.latest_offer
    ,p_rec.offer_status
    ,p_rec.discretionary_job_title
    ,p_rec.offer_extended_method
    ,p_rec.respondent_id
    ,p_rec.expiry_date
    ,p_rec.proposed_start_date
    ,p_rec.offer_letter_tracking_code
    ,p_rec.offer_postal_service
    ,p_rec.offer_shipping_date
    ,p_rec.vacancy_id
    ,p_rec.applicant_assignment_id
    ,p_rec.offer_assignment_id
    ,p_rec.address_id
    ,p_rec.template_id
    ,empty_blob()
    ,p_rec.offer_letter_file_type
    ,p_rec.offer_letter_file_name
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
    ,p_rec.attribute21
    ,p_rec.attribute22
    ,p_rec.attribute23
    ,p_rec.attribute24
    ,p_rec.attribute25
    ,p_rec.attribute26
    ,p_rec.attribute27
    ,p_rec.attribute28
    ,p_rec.attribute29
    ,p_rec.attribute30
    ,p_rec.object_version_number
    );
  --
  --
  --
  hr_utility.set_location(' leaving:'||l_proc, 10);
exception
  when hr_api.check_integrity_violated then
    -- a check constraint has been violated
    --
    irc_iof_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(sqlerrm));
  when hr_api.parent_integrity_violated then
    -- parent integrity has been violated
    --
    irc_iof_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(sqlerrm));
  when hr_api.unique_integrity_violated then
    -- unique integrity has been violated
    --
    irc_iof_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(sqlerrm));
  when others then
    --
    raise;
end insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {start of comments}
--
-- description:
--   this private procedure contains any processing which is required before
--   the insert dml. presently, if the entity has a corresponding primary
--   key which is maintained by an associating sequence, the primary key for
--   the entity will be populated with the next sequence value in
--   preparation for the insert dml.
--
-- prerequisites:
--   this is an internal procedure which is called from the ins procedure.
--
-- in parameters:
--   a pl/sql record structure.
--
-- post success:
--   processing continues.
--
-- post failure:
--   if an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- developer implementation notes:
--   any pre-processing required before the insert dml is issued should be
--   coded within this procedure. as stated above, a good example is the
--   generation of a primary key number via a corresponding sequence.
--   it is important to note that any 3rd party maintenance should be reviewed
--   before placing in this procedure.
--
-- access status:
--   internal row handler use only.
--
-- {end of comments}
-- ----------------------------------------------------------------------------
procedure pre_insert
  (p_rec  in out nocopy irc_iof_shd.g_rec_type
  ) is
--
  cursor c_sel1 is select irc_offers_s.nextval from sys.dual;
--
  cursor c_sel2 is
    select null
      from irc_offers
     where offer_id =
             irc_iof_ins.g_offer_id_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
begin
  hr_utility.set_location('entering:'||l_proc, 5);
  --
  if (irc_iof_ins.g_offer_id_i is not null) then
    --
    -- verify registered primary key values not already in use
    --
    open c_sel2;
    fetch c_sel2 into l_exists;
    if c_sel2%found then
       close c_sel2;
       --
       -- the primary key values are already in use.
       --
       fnd_message.set_name('PER','PER_289391_KEY_ALREADY_USED');
       fnd_message.set_token('TABLE_NAME','irc_offers');
       fnd_message.raise_error;
    end if;
    close c_sel2;
    --
    -- use registered key values and clear globals
    --
    p_rec.offer_id :=
      irc_iof_ins.g_offer_id_i;
    irc_iof_ins.g_offer_id_i := null;
  else
    --
    -- no registerd key values, so select the next sequence number
    --
    --
    -- select the next sequence number
    --
    open c_sel1;
    fetch c_sel1 into p_rec.offer_id;
    close c_sel1;
  end if;
  --
  hr_utility.set_location(' leaving:'||l_proc, 10);
end pre_insert;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {start of comments}
--
-- description:
--   this private procedure contains any processing which is required after
--   the insert dml.
--
-- prerequisites:
--   this is an internal procedure which is called from the ins procedure.
--
-- in parameters:
--   a pl/sql record structre.
--
-- post success:
--   processing continues.
--
-- post failure:
--   if an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- developer implementation notes:
--   any post-processing required after the insert dml is issued should be
--   coded within this procedure. it is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- access status:
--   internal row handler use only.
--
-- {end of comments}
-- ----------------------------------------------------------------------------
procedure post_insert
  (p_effective_date               in date
  ,p_rec                          in irc_iof_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
begin
  hr_utility.set_location('entering:'||l_proc, 5);
  begin
    --
    irc_iof_rki.after_insert
      (p_effective_date              => p_effective_date
      ,p_offer_id
      => p_rec.offer_id
      ,p_offer_version
      => p_rec.offer_version
      ,p_latest_offer
      => p_rec.latest_offer
      ,p_offer_status
      => p_rec.offer_status
      ,p_discretionary_job_title
      => p_rec.discretionary_job_title
      ,p_offer_extended_method
      => p_rec.offer_extended_method
      ,p_respondent_id
      => p_rec.respondent_id
      ,p_expiry_date
      => p_rec.expiry_date
      ,p_proposed_start_date
      => p_rec.proposed_start_date
      ,p_offer_letter_tracking_code
      => p_rec.offer_letter_tracking_code
      ,p_offer_postal_service
      => p_rec.offer_postal_service
      ,p_offer_shipping_date
      => p_rec.offer_shipping_date
      ,p_vacancy_id
      => p_rec.vacancy_id
      ,p_applicant_assignment_id
      => p_rec.applicant_assignment_id
      ,p_offer_assignment_id
      => p_rec.offer_assignment_id
      ,p_address_id
      => p_rec.address_id
      ,p_template_id
      => p_rec.template_id
      ,p_offer_letter_file_type
      => p_rec.offer_letter_file_type
      ,p_offer_letter_file_name
      => p_rec.offer_letter_file_name
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
      ,p_attribute21
      => p_rec.attribute21
      ,p_attribute22
      => p_rec.attribute22
      ,p_attribute23
      => p_rec.attribute23
      ,p_attribute24
      => p_rec.attribute24
      ,p_attribute25
      => p_rec.attribute25
      ,p_attribute26
      => p_rec.attribute26
      ,p_attribute27
      => p_rec.attribute27
      ,p_attribute28
      => p_rec.attribute28
      ,p_attribute29
      => p_rec.attribute29
      ,p_attribute30
      => p_rec.attribute30
      ,p_object_version_number
      => p_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'irc_offers'
        ,p_hook_type   => 'ai');
      --
  end;
  --
  hr_utility.set_location(' leaving:'||l_proc, 10);
end post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
procedure ins
  (p_effective_date               in date
  ,p_rec                          in out nocopy irc_iof_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
begin
  hr_utility.set_location('entering:'||l_proc, 5);
  --
  -- call the supporting insert validate operations
  --
  irc_iof_bus.insert_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- call the supporting pre-insert operation
  --
  irc_iof_ins.pre_insert(p_rec);
  --
  -- insert the row
  --
  irc_iof_ins.insert_dml(p_rec);
  --
  -- call the supporting post-insert operation
  --
  irc_iof_ins.post_insert
     (p_effective_date
     ,p_rec
     );
  --
  -- call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  hr_utility.set_location('leaving:'||l_proc, 20);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
procedure ins
  (p_effective_date                 in     date
  ,p_latest_offer                   in     varchar2
  ,p_applicant_assignment_id        in     number
  ,p_offer_assignment_id            in     number
  ,p_offer_status                   in     varchar2
  ,p_discretionary_job_title        in     varchar2 default null
  ,p_offer_extended_method          in     varchar2 default null
  ,p_respondent_id                  in     number   default null
  ,p_expiry_date                    in     date     default null
  ,p_proposed_start_date            in     date     default null
  ,p_offer_letter_tracking_code     in     varchar2 default null
  ,p_offer_postal_service           in     varchar2 default null
  ,p_offer_shipping_date            in     date     default null
  ,p_address_id                     in     number   default null
  ,p_template_id                    in     number   default null
  ,p_offer_letter_file_type         in     varchar2 default null
  ,p_offer_letter_file_name         in     varchar2 default null
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
  ,p_attribute21                    in     varchar2 default null
  ,p_attribute22                    in     varchar2 default null
  ,p_attribute23                    in     varchar2 default null
  ,p_attribute24                    in     varchar2 default null
  ,p_attribute25                    in     varchar2 default null
  ,p_attribute26                    in     varchar2 default null
  ,p_attribute27                    in     varchar2 default null
  ,p_attribute28                    in     varchar2 default null
  ,p_attribute29                    in     varchar2 default null
  ,p_attribute30                    in     varchar2 default null
  ,p_offer_id                          out nocopy number
  ,p_offer_version                     out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec   irc_iof_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
begin
  hr_utility.set_location('entering:'||l_proc, 5);
  --
  -- call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  irc_iof_shd.convert_args
    (null  -- offer_id
    ,null  -- offer_version
    ,p_latest_offer
    ,p_offer_status
    ,p_discretionary_job_title
    ,p_offer_extended_method
    ,p_respondent_id
    ,p_expiry_date
    ,p_proposed_start_date
    ,p_offer_letter_tracking_code
    ,p_offer_postal_service
    ,p_offer_shipping_date
    ,null  -- vacancy_id
    ,p_applicant_assignment_id
    ,p_offer_assignment_id
    ,p_address_id
    ,p_template_id
    ,p_offer_letter_file_type
    ,p_offer_letter_file_name
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
    ,p_attribute21
    ,p_attribute22
    ,p_attribute23
    ,p_attribute24
    ,p_attribute25
    ,p_attribute26
    ,p_attribute27
    ,p_attribute28
    ,p_attribute29
    ,p_attribute30
    ,null  -- object_version_number
    );
  --
  -- having converted the arguments into the irc_iof_rec
  -- plsql record structure we call the corresponding record business process.
  --
  irc_iof_ins.ins
     (p_effective_date
     ,l_rec
     );
  --
  -- as the primary key argument(s)
  -- are specified as an out's we must set these values.
  --
  p_offer_id := l_rec.offer_id;
  p_object_version_number := l_rec.object_version_number;
  p_offer_version  := l_rec.offer_version;
  --
  hr_utility.set_location(' leaving:'||l_proc, 10);
end ins;
--
end irc_iof_ins;

/
