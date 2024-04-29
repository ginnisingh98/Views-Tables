--------------------------------------------------------
--  DDL for Package Body PER_KAD_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_KAD_INS" as
/* $Header: pekadrhi.pkb 115.6 2002/12/06 11:27:37 pkakar ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_kad_ins.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic. The functions of this
--   procedure are as follows:
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
--   procedure and must have all mandatory arguments set (except the
--   object_version_number which is initialised within this procedure).
--
-- In Arguments:
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
Procedure insert_dml(p_rec in out nocopy per_kad_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  per_kad_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: per_addresses
  --
  insert into per_addresses
  (	address_id,
	business_group_id,
	person_id,
	date_from,
	primary_flag,
	style,
	address_line1,
	address_line2,
	address_line3,
	address_type,
	comments,
	country,
	date_to,
	postal_code,
	region_1,
	region_2,
	region_3,
	telephone_number_1,
	telephone_number_2,
	telephone_number_3,
	town_or_city,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	addr_attribute_category,
	addr_attribute1,
	addr_attribute2,
	addr_attribute3,
	addr_attribute4,
	addr_attribute5,
	addr_attribute6,
	addr_attribute7,
	addr_attribute8,
	addr_attribute9,
	addr_attribute10,
	addr_attribute11,
	addr_attribute12,
	addr_attribute13,
	addr_attribute14,
	addr_attribute15,
	addr_attribute16,
	addr_attribute17,
	addr_attribute18,
	addr_attribute19,
	addr_attribute20,
	object_version_number
  )
  Values
  (	p_rec.address_id,
	p_rec.business_group_id,
	p_rec.person_id,
	p_rec.date_from,
	p_rec.primary_flag,
	p_rec.style,
	p_rec.address_line1,
	p_rec.address_line2,
	p_rec.address_line3,
	p_rec.address_type,
	p_rec.comments,
	p_rec.country,
	p_rec.date_to,
	p_rec.postal_code,
	p_rec.region_1,
	p_rec.region_2,
	p_rec.region_3,
	p_rec.telephone_number_1,
	p_rec.telephone_number_2,
	p_rec.telephone_number_3,
	p_rec.town_or_city,
	p_rec.request_id,
	p_rec.program_application_id,
	p_rec.program_id,
	p_rec.program_update_date,
	p_rec.addr_attribute_category,
	p_rec.addr_attribute1,
	p_rec.addr_attribute2,
	p_rec.addr_attribute3,
	p_rec.addr_attribute4,
	p_rec.addr_attribute5,
	p_rec.addr_attribute6,
	p_rec.addr_attribute7,
	p_rec.addr_attribute8,
	p_rec.addr_attribute9,
	p_rec.addr_attribute10,
	p_rec.addr_attribute11,
	p_rec.addr_attribute12,
	p_rec.addr_attribute13,
	p_rec.addr_attribute14,
	p_rec.addr_attribute15,
	p_rec.addr_attribute16,
	p_rec.addr_attribute17,
	p_rec.addr_attribute18,
	p_rec.addr_attribute19,
	p_rec.addr_attribute20,
	p_rec.object_version_number
  );
  --
  per_kad_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_kad_shd.g_api_dml := false;   -- Unset the api dml status
    per_kad_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    per_kad_shd.g_api_dml := false;   -- Unset the api dml status
    per_kad_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_kad_shd.g_api_dml := false;   -- Unset the api dml status
    per_kad_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_kad_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert(p_rec  in out nocopy per_kad_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select per_addresses_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.address_id;
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
-- Pre Conditions:
--   This is an internal procedure which is called from the ins procedure.
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
--   Any post-processing required after the insert dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert(p_rec            in per_kad_shd.g_rec_type,
                      p_effective_date in date) is
  --
  l_proc  varchar2(72) := g_package||'post_insert';
  --
  -- Fix for WWBUG 1408379
  --
  l_old               ben_add_ler.g_add_ler_rec;
  l_new               ben_add_ler.g_add_ler_rec;
  --
  -- End of Fix for WWBUG 1408379
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Fix for WWBUG 1408379
  --
  l_new.person_id := p_rec.person_id;
  l_new.business_group_id := p_rec.business_group_id;
  l_new.date_from := p_rec.date_from;
  l_new.date_to := p_rec.date_to;
  l_new.primary_flag := p_rec.primary_flag;
  l_new.postal_code := p_rec.postal_code;
  l_new.region_2 := p_rec.region_2;
  l_new.address_type := p_rec.address_type;
  l_new.address_id := p_rec.address_id;
  --
  ben_add_ler.ler_chk(p_old            => l_old,
                      p_new            => l_new,
                      p_effective_date => l_new.date_from);
  --
  -- End of Fix for WWBUG 1408379
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_rec            in out nocopy per_kad_shd.g_rec_type
  ,p_validate       in     boolean default false
  ,p_effective_date in     date
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
    SAVEPOINT ins_per_add;
  End If;
  --
  -- Call the supporting insert validate operations
  --
  per_kad_bus.insert_validate(p_rec
                             ,p_effective_date
                             );
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
  post_insert(p_rec,p_effective_date);
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
    ROLLBACK TO ins_per_add;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_address_id                   out nocopy number
  ,p_business_group_id            in number
  ,p_person_id                    in number
  ,p_date_from                    in date
  ,p_primary_flag                 in varchar2
  ,p_style                        in varchar2
  ,p_address_line1                in varchar2         default null
  ,p_address_line2                in varchar2         default null
  ,p_address_line3                in varchar2         default null
  ,p_address_type                 in varchar2         default null
  ,p_comments                     in long             default null
  ,p_country                      in varchar2         default null
  ,p_date_to                      in date             default null
  ,p_postal_code                  in varchar2         default null
  ,p_region_1                     in varchar2         default null
  ,p_region_2                     in varchar2         default null
  ,p_region_3                     in varchar2         default null
  ,p_telephone_number_1           in varchar2         default null
  ,p_telephone_number_2           in varchar2         default null
  ,p_telephone_number_3           in varchar2         default null
  ,p_town_or_city                 in varchar2         default null
  ,p_request_id                   in number           default null
  ,p_program_application_id       in number           default null
  ,p_program_id                   in number           default null
  ,p_program_update_date          in date             default null
  ,p_addr_attribute_category      in varchar2         default null
  ,p_addr_attribute1              in varchar2         default null
  ,p_addr_attribute2              in varchar2         default null
  ,p_addr_attribute3              in varchar2         default null
  ,p_addr_attribute4              in varchar2         default null
  ,p_addr_attribute5              in varchar2         default null
  ,p_addr_attribute6              in varchar2         default null
  ,p_addr_attribute7              in varchar2         default null
  ,p_addr_attribute8              in varchar2         default null
  ,p_addr_attribute9              in varchar2         default null
  ,p_addr_attribute10             in varchar2         default null
  ,p_addr_attribute11             in varchar2         default null
  ,p_addr_attribute12             in varchar2         default null
  ,p_addr_attribute13             in varchar2         default null
  ,p_addr_attribute14             in varchar2         default null
  ,p_addr_attribute15             in varchar2         default null
  ,p_addr_attribute16             in varchar2         default null
  ,p_addr_attribute17             in varchar2         default null
  ,p_addr_attribute18             in varchar2         default null
  ,p_addr_attribute19             in varchar2         default null
  ,p_addr_attribute20             in varchar2         default null
  ,p_object_version_number        out nocopy number
  ,p_validate                     in boolean          default false
  ,p_effective_date               in date
  ) is
--
  l_rec	  per_kad_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  per_kad_shd.convert_args
  (
  null,
  p_business_group_id,
  p_person_id,
  p_date_from,
  p_primary_flag,
  p_style,
  p_address_line1,
  p_address_line2,
  p_address_line3,
  p_address_type,
  p_comments,
  p_country,
  p_date_to,
  p_postal_code,
  p_region_1,
  p_region_2,
  p_region_3,
  p_telephone_number_1,
  p_telephone_number_2,
  p_telephone_number_3,
  p_town_or_city,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
  p_addr_attribute_category,
  p_addr_attribute1,
  p_addr_attribute2,
  p_addr_attribute3,
  p_addr_attribute4,
  p_addr_attribute5,
  p_addr_attribute6,
  p_addr_attribute7,
  p_addr_attribute8,
  p_addr_attribute9,
  p_addr_attribute10,
  p_addr_attribute11,
  p_addr_attribute12,
  p_addr_attribute13,
  p_addr_attribute14,
  p_addr_attribute15,
  p_addr_attribute16,
  p_addr_attribute17,
  p_addr_attribute18,
  p_addr_attribute19,
  p_addr_attribute20,
  null
  );
  --
  -- Having converted the arguments into the per_kad_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec
     ,p_validate
     ,p_effective_date
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_address_id := l_rec.address_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end per_kad_ins;

/
