--------------------------------------------------------
--  DDL for Package Body PQH_PTE_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PTE_INS" as
/* $Header: pqpterhi.pkb 115.11 2002/12/12 23:13:54 sgoyal noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_pte_ins.';  -- Global package name
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
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml(p_rec in out nocopy pqh_pte_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  -- Insert the row into: pqh_ptx_extra_info
  --
  insert into pqh_ptx_extra_info
  (	ptx_extra_info_id,
	information_type,
	position_transaction_id,
        position_extra_info_id,
	information_category,
	information1,
	information2,
	information3,
	information4,
	information5,
	information6,
	information7,
	information8,
	information9,
	information10,
	information11,
	information12,
	information13,
	information14,
	information15,
	information16,
	information17,
	information18,
	information19,
	information20,
	information21,
	information22,
	information23,
	information24,
	information25,
	information26,
	information27,
	information28,
	information29,
	information30,
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
	attribute20,
	object_version_number
  )
  Values
  (	p_rec.ptx_extra_info_id,
	p_rec.information_type,
	p_rec.position_transaction_id,
        p_rec.position_extra_info_id,
	p_rec.information_category,
	p_rec.information1,
	p_rec.information2,
	p_rec.information3,
	p_rec.information4,
	p_rec.information5,
	p_rec.information6,
	p_rec.information7,
	p_rec.information8,
	p_rec.information9,
	p_rec.information10,
	p_rec.information11,
	p_rec.information12,
	p_rec.information13,
	p_rec.information14,
	p_rec.information15,
	p_rec.information16,
	p_rec.information17,
	p_rec.information18,
	p_rec.information19,
	p_rec.information20,
	p_rec.information21,
	p_rec.information22,
	p_rec.information23,
	p_rec.information24,
	p_rec.information25,
	p_rec.information26,
	p_rec.information27,
	p_rec.information28,
	p_rec.information29,
	p_rec.information30,
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
	p_rec.attribute20,
	p_rec.object_version_number
  );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqh_pte_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pqh_pte_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqh_pte_shd.constraint_error
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
Procedure pre_insert(p_rec  in out nocopy pqh_pte_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select pqh_ptx_extra_info_s.nextval from sys.dual;
--
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.ptx_extra_info_id;
  Close C_Sel1;
  --
  --
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
Procedure post_insert(p_rec in pqh_pte_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_insert.
  --
  begin
    --
    pqh_pte_rki.after_insert
      (
  p_ptx_extra_info_id             =>p_rec.ptx_extra_info_id
 ,p_information_type              =>p_rec.information_type
 ,p_position_transaction_id       =>p_rec.position_transaction_id
 ,p_position_extra_info_id        =>p_rec.position_extra_info_id
 ,p_information_category          =>p_rec.information_category
 ,p_information1                  =>p_rec.information1
 ,p_information2                  =>p_rec.information2
 ,p_information3                  =>p_rec.information3
 ,p_information4                  =>p_rec.information4
 ,p_information5                  =>p_rec.information5
 ,p_information6                  =>p_rec.information6
 ,p_information7                  =>p_rec.information7
 ,p_information8                  =>p_rec.information8
 ,p_information9                  =>p_rec.information9
 ,p_information10                 =>p_rec.information10
 ,p_information11                 =>p_rec.information11
 ,p_information12                 =>p_rec.information12
 ,p_information13                 =>p_rec.information13
 ,p_information14                 =>p_rec.information14
 ,p_information15                 =>p_rec.information15
 ,p_information16                 =>p_rec.information16
 ,p_information17                 =>p_rec.information17
 ,p_information18                 =>p_rec.information18
 ,p_information19                 =>p_rec.information19
 ,p_information20                 =>p_rec.information20
 ,p_information21                 =>p_rec.information21
 ,p_information22                 =>p_rec.information22
 ,p_information23                 =>p_rec.information23
 ,p_information24                 =>p_rec.information24
 ,p_information25                 =>p_rec.information25
 ,p_information26                 =>p_rec.information26
 ,p_information27                 =>p_rec.information27
 ,p_information28                 =>p_rec.information28
 ,p_information29                 =>p_rec.information29
 ,p_information30                 =>p_rec.information30
 ,p_attribute_category            =>p_rec.attribute_category
 ,p_attribute1                    =>p_rec.attribute1
 ,p_attribute2                    =>p_rec.attribute2
 ,p_attribute3                    =>p_rec.attribute3
 ,p_attribute4                    =>p_rec.attribute4
 ,p_attribute5                    =>p_rec.attribute5
 ,p_attribute6                    =>p_rec.attribute6
 ,p_attribute7                    =>p_rec.attribute7
 ,p_attribute8                    =>p_rec.attribute8
 ,p_attribute9                    =>p_rec.attribute9
 ,p_attribute10                   =>p_rec.attribute10
 ,p_attribute11                   =>p_rec.attribute11
 ,p_attribute12                   =>p_rec.attribute12
 ,p_attribute13                   =>p_rec.attribute13
 ,p_attribute14                   =>p_rec.attribute14
 ,p_attribute15                   =>p_rec.attribute15
 ,p_attribute16                   =>p_rec.attribute16
 ,p_attribute17                   =>p_rec.attribute17
 ,p_attribute18                   =>p_rec.attribute18
 ,p_attribute19                   =>p_rec.attribute19
 ,p_attribute20                   =>p_rec.attribute20
 ,p_object_version_number         =>p_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pqh_ptx_extra_info'
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
  p_rec        in out nocopy pqh_pte_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  pqh_pte_bus.insert_validate(p_rec);
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
  p_ptx_extra_info_id            out nocopy number,
  p_information_type             in varchar2,
  p_position_transaction_id      in number,
  p_position_extra_info_id       in number,
  p_information_category         in varchar2         default null,
  p_information1                 in varchar2         default null,
  p_information2                 in varchar2         default null,
  p_information3                 in varchar2         default null,
  p_information4                 in varchar2         default null,
  p_information5                 in varchar2         default null,
  p_information6                 in varchar2         default null,
  p_information7                 in varchar2         default null,
  p_information8                 in varchar2         default null,
  p_information9                 in varchar2         default null,
  p_information10                in varchar2         default null,
  p_information11                in varchar2         default null,
  p_information12                in varchar2         default null,
  p_information13                in varchar2         default null,
  p_information14                in varchar2         default null,
  p_information15                in varchar2         default null,
  p_information16                in varchar2         default null,
  p_information17                in varchar2         default null,
  p_information18                in varchar2         default null,
  p_information19                in varchar2         default null,
  p_information20                in varchar2         default null,
  p_information21                in varchar2         default null,
  p_information22                in varchar2         default null,
  p_information23                in varchar2         default null,
  p_information24                in varchar2         default null,
  p_information25                in varchar2         default null,
  p_information26                in varchar2         default null,
  p_information27                in varchar2         default null,
  p_information28                in varchar2         default null,
  p_information29                in varchar2         default null,
  p_information30                in varchar2         default null,
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
  p_attribute20                  in varchar2         default null,
  p_object_version_number        out nocopy number
  ) is
--
  l_rec	  pqh_pte_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pqh_pte_shd.convert_args
  (
  null,
  p_information_type,
  p_position_transaction_id,
  p_position_extra_info_id,
  p_information_category,
  p_information1,
  p_information2,
  p_information3,
  p_information4,
  p_information5,
  p_information6,
  p_information7,
  p_information8,
  p_information9,
  p_information10,
  p_information11,
  p_information12,
  p_information13,
  p_information14,
  p_information15,
  p_information16,
  p_information17,
  p_information18,
  p_information19,
  p_information20,
  p_information21,
  p_information22,
  p_information23,
  p_information24,
  p_information25,
  p_information26,
  p_information27,
  p_information28,
  p_information29,
  p_information30,
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
  p_attribute20,
  null
  );
  --
  -- Having converted the arguments into the pqh_pte_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_ptx_extra_info_id := l_rec.ptx_extra_info_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pqh_pte_ins;

/
