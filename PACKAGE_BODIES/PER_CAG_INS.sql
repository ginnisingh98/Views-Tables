--------------------------------------------------------
--  DDL for Package Body PER_CAG_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CAG_INS" as
/* $Header: pecagrhi.pkb 120.1 2006/10/18 08:42:10 grreddy noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_cag_ins.';  -- Global package name
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
--   (Note: Philippe  4/20/99 Removed the need for setting g_api_dml as this is a new
--    table and therfore there is no ovn trigger to use it).
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
Procedure insert_dml(p_rec in out nocopy per_cag_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  -- Insert the row into: per_collective_agreements
  --
  insert into per_collective_agreements
  (	collective_agreement_id,
	business_group_id,
	object_version_number,
	name,
	pl_id,
	status,
	cag_number,
	description,
	start_date,
	end_date,
	employer_organization_id,
	employer_signatory,
	bargaining_organization_id,
	bargaining_unit_signatory,
	jurisdiction,
	authorizing_body,
	authorized_date,
	cag_information_category,
	cag_information1,
	cag_information2,
	cag_information3,
	cag_information4,
	cag_information5,
	cag_information6,
	cag_information7,
	cag_information8,
	cag_information9,
	cag_information10,
	cag_information11,
	cag_information12,
	cag_information13,
	cag_information14,
	cag_information15,
	cag_information16,
	cag_information17,
	cag_information18,
	cag_information19,
	cag_information20,
	attribute_category,
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10,
	attribute11,
	attribute12,
	attribute13,
	attribute14,
	attribute15,
	attribute16,
	attribute17,
	attribute18,
	attribute19,
	attribute20
  )
  Values
  (	p_rec.collective_agreement_id,
	p_rec.business_group_id,
	p_rec.object_version_number,
	p_rec.name,
	p_rec.pl_id,
	p_rec.status,
	p_rec.cag_number,
	p_rec.description,
	p_rec.start_date,
	p_rec.end_date,
	p_rec.employer_organization_id,
	p_rec.employer_signatory,
	p_rec.bargaining_organization_id,
	p_rec.bargaining_unit_signatory,
	p_rec.jurisdiction,
	p_rec.authorizing_body,
	p_rec.authorized_date,
	p_rec.cag_information_category,
	p_rec.cag_information1,
	p_rec.cag_information2,
	p_rec.cag_information3,
	p_rec.cag_information4,
	p_rec.cag_information5,
	p_rec.cag_information6,
	p_rec.cag_information7,
	p_rec.cag_information8,
	p_rec.cag_information9,
	p_rec.cag_information10,
	p_rec.cag_information11,
	p_rec.cag_information12,
	p_rec.cag_information13,
	p_rec.cag_information14,
	p_rec.cag_information15,
	p_rec.cag_information16,
	p_rec.cag_information17,
	p_rec.cag_information18,
	p_rec.cag_information19,
	p_rec.cag_information20,
	p_rec.attribute_category,
	p_rec.attribute1,
	p_rec.attribute2,
	p_rec.attribute3,
	p_rec.attribute4,
	p_rec.attribute5,
	p_rec.attribute6,
	p_rec.attribute7,
	p_rec.attribute8,
	p_rec.attribute9,
	p_rec.attribute10,
	p_rec.attribute11,
	p_rec.attribute12,
	p_rec.attribute13,
	p_rec.attribute14,
	p_rec.attribute15,
	p_rec.attribute16,
	p_rec.attribute17,
	p_rec.attribute18,
	p_rec.attribute19,
	p_rec.attribute20
  );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_cag_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    per_cag_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_cag_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
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
Procedure pre_insert(p_rec  in out nocopy per_cag_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select per_collective_agreements_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.collective_agreement_id;
  Close C_Sel1;
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
Procedure post_insert(p_rec in per_cag_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  -- Start of API User Hook for post_insert.
  --
  begin
    --
    per_cag_rki.after_insert
      (p_collective_agreement_id    =>p_rec.collective_agreement_id,
       p_business_group_id          =>p_rec.business_group_id,
       p_object_version_number      =>p_rec.object_version_number,
       p_name                       =>p_rec.name,
	   p_pl_id                      =>p_rec.pl_id,
	   p_status                     =>p_rec.status,
       p_cag_number                 =>p_rec.cag_number,
       p_description                =>p_rec.description,
       p_start_date                 =>p_rec.start_date,
       p_end_date                   =>p_rec.end_date,
       p_employer_organization_id   =>p_rec.employer_organization_id,
       p_employer_signatory         =>p_rec.employer_signatory,
       p_bargaining_organization_id =>p_rec.bargaining_organization_id,
       p_bargaining_unit_signatory  =>p_rec.bargaining_unit_signatory,
       p_jurisdiction               =>p_rec.jurisdiction,
       p_authorizing_body           =>p_rec.authorizing_body,
       p_authorized_date            =>p_rec.authorized_date,
       p_cag_information_category   =>p_rec.cag_information_category,
       p_cag_information1           =>p_rec.cag_information1,
       p_cag_information2           =>p_rec.cag_information2,
       p_cag_information3           =>p_rec.cag_information3,
       p_cag_information4           =>p_rec.cag_information4,
       p_cag_information5           =>p_rec.cag_information5,
       p_cag_information6           =>p_rec.cag_information6,
       p_cag_information7           =>p_rec.cag_information7,
       p_cag_information8           =>p_rec.cag_information8,
       p_cag_information9           =>p_rec.cag_information9,
       p_cag_information10          =>p_rec.cag_information10,
       p_cag_information11          =>p_rec.cag_information11,
       p_cag_information12          =>p_rec.cag_information12,
       p_cag_information13          =>p_rec.cag_information13,
       p_cag_information14          =>p_rec.cag_information14,
       p_cag_information15          =>p_rec.cag_information15,
       p_cag_information16          =>p_rec.cag_information16,
       p_cag_information17          =>p_rec.cag_information17,
       p_cag_information18          =>p_rec.cag_information18,
       p_cag_information19          =>p_rec.cag_information19,
       p_cag_information20          =>p_rec.cag_information20,
       p_attribute_category         =>p_rec.attribute_category,
       p_attribute1                 =>p_rec.attribute1,
       p_attribute2                 =>p_rec.attribute2,
       p_attribute3                 =>p_rec.attribute3,
       p_attribute4                 =>p_rec.attribute4,
       p_attribute5                 =>p_rec.attribute5,
       p_attribute6                 =>p_rec.attribute6,
       p_attribute7                 =>p_rec.attribute7,
       p_attribute8                 =>p_rec.attribute8,
       p_attribute9                 =>p_rec.attribute9,
       p_attribute10                =>p_rec.attribute10,
       p_attribute11                =>p_rec.attribute11,
       p_attribute12                =>p_rec.attribute12,
       p_attribute13                =>p_rec.attribute13,
       p_attribute14                =>p_rec.attribute14,
       p_attribute15                =>p_rec.attribute15,
       p_attribute16                =>p_rec.attribute16,
       p_attribute17                =>p_rec.attribute17,
       p_attribute18                =>p_rec.attribute18,
       p_attribute19                =>p_rec.attribute19,
       p_attribute20                =>p_rec.attribute20
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'per_collective_agreements'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  -- End of API User Hook for post_insert.
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec        in out nocopy per_cag_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  per_cag_bus.insert_validate(p_rec);
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
  post_insert(p_rec);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_collective_agreement_id      out nocopy number,
  p_business_group_id            in number,
  p_object_version_number        out nocopy number,
  p_name                         in varchar2,
  p_pl_id                        in number,
  p_status                       in varchar2         default null,
  p_cag_number                   in number           default null,
  p_description                  in varchar2         default null,
  p_start_date                   in date             default null,
  p_end_date                     in date             default null,
  p_employer_organization_id     in number           default null,
  p_employer_signatory           in varchar2         default null,
  p_bargaining_organization_id   in number           default null,
  p_bargaining_unit_signatory    in varchar2         default null,
  p_jurisdiction                 in varchar2         default null,
  p_authorizing_body             in varchar2         default null,
  p_authorized_date              in date             default null,
  p_cag_information_category     in varchar2         default null,
  p_cag_information1             in varchar2         default null,
  p_cag_information2             in varchar2         default null,
  p_cag_information3             in varchar2         default null,
  p_cag_information4             in varchar2         default null,
  p_cag_information5             in varchar2         default null,
  p_cag_information6             in varchar2         default null,
  p_cag_information7             in varchar2         default null,
  p_cag_information8             in varchar2         default null,
  p_cag_information9             in varchar2         default null,
  p_cag_information10            in varchar2         default null,
  p_cag_information11            in varchar2         default null,
  p_cag_information12            in varchar2         default null,
  p_cag_information13            in varchar2         default null,
  p_cag_information14            in varchar2         default null,
  p_cag_information15            in varchar2         default null,
  p_cag_information16            in varchar2         default null,
  p_cag_information17            in varchar2         default null,
  p_cag_information18            in varchar2         default null,
  p_cag_information19            in varchar2         default null,
  p_cag_information20            in varchar2         default null,
  p_attribute_category           in varchar2         default null,
  p_attribute1                   in varchar2         default null,
  p_attribute2                   in varchar2         default null,
  p_attribute3                   in varchar2         default null,
  p_attribute4                   in varchar2         default null,
  p_attribute5                   in varchar2         default null,
  p_attribute6                   in varchar2         default null,
  p_attribute7                   in varchar2         default null,
  p_attribute8                   in varchar2         default null,
  p_attribute9                   in varchar2         default null,
  p_attribute10                  in varchar2         default null,
  p_attribute11                  in varchar2         default null,
  p_attribute12                  in varchar2         default null,
  p_attribute13                  in varchar2         default null,
  p_attribute14                  in varchar2         default null,
  p_attribute15                  in varchar2         default null,
  p_attribute16                  in varchar2         default null,
  p_attribute17                  in varchar2         default null,
  p_attribute18                  in varchar2         default null,
  p_attribute19                  in varchar2         default null,
  p_attribute20                  in varchar2         default null
  ) is
--
  l_rec	  per_cag_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  per_cag_shd.convert_args
  (
  null,
  p_business_group_id,
  null,
  p_name,
  p_pl_id,
  p_status,
  p_cag_number,
  p_description,
  p_start_date,
  p_end_date,
  p_employer_organization_id,
  p_employer_signatory,
  p_bargaining_organization_id,
  p_bargaining_unit_signatory,
  p_jurisdiction,
  p_authorizing_body,
  p_authorized_date,
  p_cag_information_category,
  p_cag_information1,
  p_cag_information2,
  p_cag_information3,
  p_cag_information4,
  p_cag_information5,
  p_cag_information6,
  p_cag_information7,
  p_cag_information8,
  p_cag_information9,
  p_cag_information10,
  p_cag_information11,
  p_cag_information12,
  p_cag_information13,
  p_cag_information14,
  p_cag_information15,
  p_cag_information16,
  p_cag_information17,
  p_cag_information18,
  p_cag_information19,
  p_cag_information20,
  p_attribute_category,
  p_attribute1,
  p_attribute2,
  p_attribute3,
  p_attribute4,
  p_attribute5,
  p_attribute6,
  p_attribute7,
  p_attribute8,
  p_attribute9,
  p_attribute10,
  p_attribute11,
  p_attribute12,
  p_attribute13,
  p_attribute14,
  p_attribute15,
  p_attribute16,
  p_attribute17,
  p_attribute18,
  p_attribute19,
  p_attribute20
  );
  --
  -- Having converted the arguments into the per_cag_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_collective_agreement_id := l_rec.collective_agreement_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end per_cag_ins;

/
