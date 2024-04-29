--------------------------------------------------------
--  DDL for Package Body PER_BPD_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_BPD_INS" as
/* $Header: pebpdrhi.pkb 115.6 2002/12/02 13:52:43 apholt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_bpd_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy per_bpd_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  -- Insert the row into: per_bf_payment_details
  --
  insert into per_bf_payment_details
  (      payment_detail_id,
      processed_assignment_id,
      personal_payment_method_id,
      business_group_id,
      check_number,
      payment_date,
      amount,
      check_type,
      object_version_number,
      bpd_attribute_category,
      bpd_attribute1,
      bpd_attribute2,
      bpd_attribute3,
      bpd_attribute4,
      bpd_attribute5,
      bpd_attribute6,
      bpd_attribute7,
      bpd_attribute8,
      bpd_attribute9,
      bpd_attribute10,
      bpd_attribute11,
      bpd_attribute12,
      bpd_attribute13,
      bpd_attribute14,
      bpd_attribute15,
      bpd_attribute16,
      bpd_attribute17,
      bpd_attribute18,
      bpd_attribute19,
      bpd_attribute20,
      bpd_attribute21,
      bpd_attribute22,
      bpd_attribute23,
      bpd_attribute24,
      bpd_attribute25,
      bpd_attribute26,
      bpd_attribute27,
      bpd_attribute28,
      bpd_attribute29,
      bpd_attribute30
  )
  Values
  (   p_rec.payment_detail_id,
      p_rec.processed_assignment_id,
      p_rec.personal_payment_method_id,
      p_rec.business_group_id,
      p_rec.check_number,
      p_rec.payment_date,
      p_rec.amount,
      p_rec.check_type,
      p_rec.object_version_number,
      p_rec.bpd_attribute_category,
      p_rec.bpd_attribute1,
      p_rec.bpd_attribute2,
      p_rec.bpd_attribute3,
      p_rec.bpd_attribute4,
      p_rec.bpd_attribute5,
      p_rec.bpd_attribute6,
      p_rec.bpd_attribute7,
      p_rec.bpd_attribute8,
      p_rec.bpd_attribute9,
      p_rec.bpd_attribute10,
      p_rec.bpd_attribute11,
      p_rec.bpd_attribute12,
      p_rec.bpd_attribute13,
      p_rec.bpd_attribute14,
      p_rec.bpd_attribute15,
      p_rec.bpd_attribute16,
      p_rec.bpd_attribute17,
      p_rec.bpd_attribute18,
      p_rec.bpd_attribute19,
      p_rec.bpd_attribute20,
      p_rec.bpd_attribute21,
      p_rec.bpd_attribute22,
      p_rec.bpd_attribute23,
      p_rec.bpd_attribute24,
      p_rec.bpd_attribute25,
      p_rec.bpd_attribute26,
      p_rec.bpd_attribute27,
      p_rec.bpd_attribute28,
      p_rec.bpd_attribute29,
      p_rec.bpd_attribute30
  );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_bpd_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    per_bpd_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_bpd_shd.constraint_error
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
Procedure pre_insert(p_rec  in out nocopy per_bpd_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
Cursor C_Sel1 is select per_bf_payment_details_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.payment_detail_id;
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
Procedure post_insert(p_effective_date   in  date,
                      p_rec in per_bpd_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_bpd_rki.after_insert
      (p_effective_date              => p_effective_date,
      p_payment_detail_id          => p_rec.payment_detail_id,
      p_processed_assignment_id    => p_rec.processed_assignment_id,
      p_personal_payment_method_id => p_rec.personal_payment_method_id,
      p_business_group_id          => p_rec.business_group_id,
      p_check_number               => p_rec.check_number,
      p_payment_date                 => p_rec.payment_date,
      p_amount                     => p_rec.amount,
      p_check_type                 => p_rec.check_type,
      p_object_version_number      => p_rec.object_version_number,
      p_bpd_attribute_category     => p_rec.bpd_attribute_category,
      p_bpd_attribute1             => p_rec.bpd_attribute1,
      p_bpd_attribute2             => p_rec.bpd_attribute2,
      p_bpd_attribute3             => p_rec.bpd_attribute3,
      p_bpd_attribute4             => p_rec.bpd_attribute4,
      p_bpd_attribute5             => p_rec.bpd_attribute5,
      p_bpd_attribute6             => p_rec.bpd_attribute6,
      p_bpd_attribute7             => p_rec.bpd_attribute7,
      p_bpd_attribute8             => p_rec.bpd_attribute8,
      p_bpd_attribute9             => p_rec.bpd_attribute9,
      p_bpd_attribute10            => p_rec.bpd_attribute10,
      p_bpd_attribute11            => p_rec.bpd_attribute11,
      p_bpd_attribute12            => p_rec.bpd_attribute12,
      p_bpd_attribute13            => p_rec.bpd_attribute13,
      p_bpd_attribute14            => p_rec.bpd_attribute14,
      p_bpd_attribute15            => p_rec.bpd_attribute15,
      p_bpd_attribute16            => p_rec.bpd_attribute16,
      p_bpd_attribute17            => p_rec.bpd_attribute17,
      p_bpd_attribute18            => p_rec.bpd_attribute18,
      p_bpd_attribute19            => p_rec.bpd_attribute19,
      p_bpd_attribute20            => p_rec.bpd_attribute20,
      p_bpd_attribute21            => p_rec.bpd_attribute21,
      p_bpd_attribute22            => p_rec.bpd_attribute22,
      p_bpd_attribute23            => p_rec.bpd_attribute23,
      p_bpd_attribute24            => p_rec.bpd_attribute24,
      p_bpd_attribute25            => p_rec.bpd_attribute25,
      p_bpd_attribute26            => p_rec.bpd_attribute26,
      p_bpd_attribute27            => p_rec.bpd_attribute27,
      p_bpd_attribute28            => p_rec.bpd_attribute28,
      p_bpd_attribute29            => p_rec.bpd_attribute29,
      p_bpd_attribute30            => p_rec.bpd_attribute30
      );
--
  exception
--
    when hr_api.cannot_find_prog_unit then
--
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_BF_PAYMENT_DETAILS'
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
  (
  p_effective_date   in  date,
  p_rec        in out nocopy per_bpd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  per_bpd_bus.insert_validate(p_effective_date,
                             p_rec
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
  post_insert(p_effective_date,
                             p_rec);
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_effective_date   in  date,
  p_payment_detail_id            out nocopy number,
  p_processed_assignment_id      in number,
  p_personal_payment_method_id   in number,
  p_business_group_id            in number,
  p_check_number                 in number           default null,
  p_payment_date                   in date             default null,
  p_amount                       in number           default null,
  p_check_type                   in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_bpd_attribute_category           in varchar2         default null,
  p_bpd_attribute1                  in varchar2         default null,
  p_bpd_attribute2                  in varchar2         default null,
  p_bpd_attribute3                  in varchar2         default null,
  p_bpd_attribute4                  in varchar2         default null,
  p_bpd_attribute5                  in varchar2         default null,
  p_bpd_attribute6                  in varchar2         default null,
  p_bpd_attribute7                  in varchar2         default null,
  p_bpd_attribute8                  in varchar2         default null,
  p_bpd_attribute9                  in varchar2         default null,
  p_bpd_attribute10                 in varchar2         default null,
  p_bpd_attribute11                 in varchar2         default null,
  p_bpd_attribute12                 in varchar2         default null,
  p_bpd_attribute13                 in varchar2         default null,
  p_bpd_attribute14                 in varchar2         default null,
  p_bpd_attribute15                 in varchar2         default null,
  p_bpd_attribute16                 in varchar2         default null,
  p_bpd_attribute17                 in varchar2         default null,
  p_bpd_attribute18                 in varchar2         default null,
  p_bpd_attribute19                 in varchar2         default null,
  p_bpd_attribute20                 in varchar2         default null,
  p_bpd_attribute21                 in varchar2         default null,
  p_bpd_attribute22                 in varchar2         default null,
  p_bpd_attribute23                 in varchar2         default null,
  p_bpd_attribute24                 in varchar2         default null,
  p_bpd_attribute25                 in varchar2         default null,
  p_bpd_attribute26                 in varchar2         default null,
  p_bpd_attribute27                 in varchar2         default null,
  p_bpd_attribute28                 in varchar2         default null,
  p_bpd_attribute29                 in varchar2         default null,
  p_bpd_attribute30                 in varchar2         default null
  ) is
--
  l_rec	  per_bpd_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
-- Call conversion function to turn arguments into the
-- p_rec structure.
--
  l_rec :=
  per_bpd_shd.convert_args
  (
  null,
  p_processed_assignment_id,
  p_personal_payment_method_id,
  p_business_group_id,
  p_check_number,
  p_payment_date,
  p_amount,
  p_check_type,
  null,
  p_bpd_attribute_category,
  p_bpd_attribute1,
  p_bpd_attribute2,
  p_bpd_attribute3,
  p_bpd_attribute4,
  p_bpd_attribute5,
  p_bpd_attribute6,
  p_bpd_attribute7,
  p_bpd_attribute8,
  p_bpd_attribute9,
  p_bpd_attribute10,
  p_bpd_attribute11,
  p_bpd_attribute12,
  p_bpd_attribute13,
  p_bpd_attribute14,
  p_bpd_attribute15,
  p_bpd_attribute16,
  p_bpd_attribute17,
  p_bpd_attribute18,
  p_bpd_attribute19,
  p_bpd_attribute20,
  p_bpd_attribute21,
  p_bpd_attribute22,
  p_bpd_attribute23,
  p_bpd_attribute24,
  p_bpd_attribute25,
  p_bpd_attribute26,
  p_bpd_attribute27,
  p_bpd_attribute28,
  p_bpd_attribute29,
  p_bpd_attribute30
  );
  --
  -- Having converted the arguments into the per_bpd_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(p_effective_date,
      l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_payment_detail_id := l_rec.payment_detail_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end per_bpd_ins;

/
