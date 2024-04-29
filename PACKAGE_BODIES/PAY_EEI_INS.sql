--------------------------------------------------------
--  DDL for Package Body PAY_EEI_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_EEI_INS" as
/* $Header: pyeeirhi.pkb 120.11 2006/07/12 05:28:45 vikgupta noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_eei_ins.';  -- Global package name
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
  (p_rec in out nocopy pay_eei_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  pay_eei_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: pay_element_type_extra_info
  --
  insert into pay_element_type_extra_info
      (element_type_extra_info_id
      ,element_type_id
      ,information_type
      ,request_id
      ,program_application_id
      ,program_id
      ,program_update_date
      ,eei_attribute_category
      ,eei_attribute1
      ,eei_attribute2
      ,eei_attribute3
      ,eei_attribute4
      ,eei_attribute5
      ,eei_attribute6
      ,eei_attribute7
      ,eei_attribute8
      ,eei_attribute9
      ,eei_attribute10
      ,eei_attribute11
      ,eei_attribute12
      ,eei_attribute13
      ,eei_attribute14
      ,eei_attribute15
      ,eei_attribute16
      ,eei_attribute17
      ,eei_attribute18
      ,eei_attribute19
      ,eei_attribute20
      ,eei_information_category
      ,eei_information1
      ,eei_information2
      ,eei_information3
      ,eei_information4
      ,eei_information5
      ,eei_information6
      ,eei_information7
      ,eei_information8
      ,eei_information9
      ,eei_information10
      ,eei_information11
      ,eei_information12
      ,eei_information13
      ,eei_information14
      ,eei_information15
      ,eei_information16
      ,eei_information17
      ,eei_information18
      ,eei_information19
      ,eei_information20
      ,eei_information21
      ,eei_information22
      ,eei_information23
      ,eei_information24
      ,eei_information25
      ,eei_information26
      ,eei_information27
      ,eei_information28
      ,eei_information29
      ,eei_information30
      ,object_version_number
      )
  Values
    (p_rec.element_type_extra_info_id
    ,p_rec.element_type_id
    ,p_rec.information_type
    ,p_rec.request_id
    ,p_rec.program_application_id
    ,p_rec.program_id
    ,p_rec.program_update_date
    ,p_rec.eei_attribute_category
    ,p_rec.eei_attribute1
    ,p_rec.eei_attribute2
    ,p_rec.eei_attribute3
    ,p_rec.eei_attribute4
    ,p_rec.eei_attribute5
    ,p_rec.eei_attribute6
    ,p_rec.eei_attribute7
    ,p_rec.eei_attribute8
    ,p_rec.eei_attribute9
    ,p_rec.eei_attribute10
    ,p_rec.eei_attribute11
    ,p_rec.eei_attribute12
    ,p_rec.eei_attribute13
    ,p_rec.eei_attribute14
    ,p_rec.eei_attribute15
    ,p_rec.eei_attribute16
    ,p_rec.eei_attribute17
    ,p_rec.eei_attribute18
    ,p_rec.eei_attribute19
    ,p_rec.eei_attribute20
    ,p_rec.eei_information_category
    ,p_rec.eei_information1
    ,p_rec.eei_information2
    ,p_rec.eei_information3
    ,p_rec.eei_information4
    ,p_rec.eei_information5
    ,p_rec.eei_information6
    ,p_rec.eei_information7
    ,p_rec.eei_information8
    ,p_rec.eei_information9
    ,p_rec.eei_information10
    ,p_rec.eei_information11
    ,p_rec.eei_information12
    ,p_rec.eei_information13
    ,p_rec.eei_information14
    ,p_rec.eei_information15
    ,p_rec.eei_information16
    ,p_rec.eei_information17
    ,p_rec.eei_information18
    ,p_rec.eei_information19
    ,p_rec.eei_information20
    ,p_rec.eei_information21
    ,p_rec.eei_information22
    ,p_rec.eei_information23
    ,p_rec.eei_information24
    ,p_rec.eei_information25
    ,p_rec.eei_information26
    ,p_rec.eei_information27
    ,p_rec.eei_information28
    ,p_rec.eei_information29
    ,p_rec.eei_information30
    ,p_rec.object_version_number
    );
  --
  pay_eei_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pay_eei_shd.g_api_dml := false;   -- Unset the api dml status
    pay_eei_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pay_eei_shd.g_api_dml := false;   -- Unset the api dml status
    pay_eei_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pay_eei_shd.g_api_dml := false;   -- Unset the api dml status
    pay_eei_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pay_eei_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert
  (p_rec  in out nocopy pay_eei_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select pay_element_type_extra_info_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.element_type_extra_info_id;
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
Procedure post_insert
  (p_rec                          in pay_eei_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pay_eei_rki.after_insert
      (p_element_type_extra_info_id
      => p_rec.element_type_extra_info_id
      ,p_element_type_id
      => p_rec.element_type_id
      ,p_information_type
      => p_rec.information_type
      ,p_request_id
      => p_rec.request_id
      ,p_program_application_id
      => p_rec.program_application_id
      ,p_program_id
      => p_rec.program_id
      ,p_program_update_date
      => p_rec.program_update_date
      ,p_eei_attribute_category
      => p_rec.eei_attribute_category
      ,p_eei_attribute1
      => p_rec.eei_attribute1
      ,p_eei_attribute2
      => p_rec.eei_attribute2
      ,p_eei_attribute3
      => p_rec.eei_attribute3
      ,p_eei_attribute4
      => p_rec.eei_attribute4
      ,p_eei_attribute5
      => p_rec.eei_attribute5
      ,p_eei_attribute6
      => p_rec.eei_attribute6
      ,p_eei_attribute7
      => p_rec.eei_attribute7
      ,p_eei_attribute8
      => p_rec.eei_attribute8
      ,p_eei_attribute9
      => p_rec.eei_attribute9
      ,p_eei_attribute10
      => p_rec.eei_attribute10
      ,p_eei_attribute11
      => p_rec.eei_attribute11
      ,p_eei_attribute12
      => p_rec.eei_attribute12
      ,p_eei_attribute13
      => p_rec.eei_attribute13
      ,p_eei_attribute14
      => p_rec.eei_attribute14
      ,p_eei_attribute15
      => p_rec.eei_attribute15
      ,p_eei_attribute16
      => p_rec.eei_attribute16
      ,p_eei_attribute17
      => p_rec.eei_attribute17
      ,p_eei_attribute18
      => p_rec.eei_attribute18
      ,p_eei_attribute19
      => p_rec.eei_attribute19
      ,p_eei_attribute20
      => p_rec.eei_attribute20
      ,p_eei_information_category
      => p_rec.eei_information_category
      ,p_eei_information1
      => p_rec.eei_information1
      ,p_eei_information2
      => p_rec.eei_information2
      ,p_eei_information3
      => p_rec.eei_information3
      ,p_eei_information4
      => p_rec.eei_information4
      ,p_eei_information5
      => p_rec.eei_information5
      ,p_eei_information6
      => p_rec.eei_information6
      ,p_eei_information7
      => p_rec.eei_information7
      ,p_eei_information8
      => p_rec.eei_information8
      ,p_eei_information9
      => p_rec.eei_information9
      ,p_eei_information10
      => p_rec.eei_information10
      ,p_eei_information11
      => p_rec.eei_information11
      ,p_eei_information12
      => p_rec.eei_information12
      ,p_eei_information13
      => p_rec.eei_information13
      ,p_eei_information14
      => p_rec.eei_information14
      ,p_eei_information15
      => p_rec.eei_information15
      ,p_eei_information16
      => p_rec.eei_information16
      ,p_eei_information17
      => p_rec.eei_information17
      ,p_eei_information18
      => p_rec.eei_information18
      ,p_eei_information19
      => p_rec.eei_information19
      ,p_eei_information20
      => p_rec.eei_information20
      ,p_eei_information21
      => p_rec.eei_information21
      ,p_eei_information22
      => p_rec.eei_information22
      ,p_eei_information23
      => p_rec.eei_information23
      ,p_eei_information24
      => p_rec.eei_information24
      ,p_eei_information25
      => p_rec.eei_information25
      ,p_eei_information26
      => p_rec.eei_information26
      ,p_eei_information27
      => p_rec.eei_information27
      ,p_eei_information28
      => p_rec.eei_information28
      ,p_eei_information29
      => p_rec.eei_information29
      ,p_eei_information30
      => p_rec.eei_information30
      ,p_object_version_number
      => p_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_ELEMENT_TYPE_EXTRA_INFO'
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
  (p_rec                          in out nocopy pay_eei_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  pay_eei_bus.insert_validate
     (p_rec
     );
  --
  -- Call the supporting pre-insert operation
  --
  pay_eei_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  pay_eei_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  pay_eei_ins.post_insert
     (p_rec
     );
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_element_type_id                in     number
  ,p_information_type               in     varchar2
  ,p_request_id                     in     number   default null
  ,p_program_application_id         in     number   default null
  ,p_program_id                     in     number   default null
  ,p_program_update_date            in     date     default null
  ,p_eei_attribute_category         in     varchar2 default null
  ,p_eei_attribute1                 in     varchar2 default null
  ,p_eei_attribute2                 in     varchar2 default null
  ,p_eei_attribute3                 in     varchar2 default null
  ,p_eei_attribute4                 in     varchar2 default null
  ,p_eei_attribute5                 in     varchar2 default null
  ,p_eei_attribute6                 in     varchar2 default null
  ,p_eei_attribute7                 in     varchar2 default null
  ,p_eei_attribute8                 in     varchar2 default null
  ,p_eei_attribute9                 in     varchar2 default null
  ,p_eei_attribute10                in     varchar2 default null
  ,p_eei_attribute11                in     varchar2 default null
  ,p_eei_attribute12                in     varchar2 default null
  ,p_eei_attribute13                in     varchar2 default null
  ,p_eei_attribute14                in     varchar2 default null
  ,p_eei_attribute15                in     varchar2 default null
  ,p_eei_attribute16                in     varchar2 default null
  ,p_eei_attribute17                in     varchar2 default null
  ,p_eei_attribute18                in     varchar2 default null
  ,p_eei_attribute19                in     varchar2 default null
  ,p_eei_attribute20                in     varchar2 default null
  ,p_eei_information_category       in     varchar2 default null
  ,p_eei_information1               in     varchar2 default null
  ,p_eei_information2               in     varchar2 default null
  ,p_eei_information3               in     varchar2 default null
  ,p_eei_information4               in     varchar2 default null
  ,p_eei_information5               in     varchar2 default null
  ,p_eei_information6               in     varchar2 default null
  ,p_eei_information7               in     varchar2 default null
  ,p_eei_information8               in     varchar2 default null
  ,p_eei_information9               in     varchar2 default null
  ,p_eei_information10              in     varchar2 default null
  ,p_eei_information11              in     varchar2 default null
  ,p_eei_information12              in     varchar2 default null
  ,p_eei_information13              in     varchar2 default null
  ,p_eei_information14              in     varchar2 default null
  ,p_eei_information15              in     varchar2 default null
  ,p_eei_information16              in     varchar2 default null
  ,p_eei_information17              in     varchar2 default null
  ,p_eei_information18              in     varchar2 default null
  ,p_eei_information19              in     varchar2 default null
  ,p_eei_information20              in     varchar2 default null
  ,p_eei_information21              in     varchar2 default null
  ,p_eei_information22              in     varchar2 default null
  ,p_eei_information23              in     varchar2 default null
  ,p_eei_information24              in     varchar2 default null
  ,p_eei_information25              in     varchar2 default null
  ,p_eei_information26              in     varchar2 default null
  ,p_eei_information27              in     varchar2 default null
  ,p_eei_information28              in     varchar2 default null
  ,p_eei_information29              in     varchar2 default null
  ,p_eei_information30              in     varchar2 default null
  ,p_element_type_extra_info_id        out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec	  pay_eei_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pay_eei_shd.convert_args
    (null
    ,p_element_type_id
    ,p_information_type
    ,p_request_id
    ,p_program_application_id
    ,p_program_id
    ,p_program_update_date
    ,p_eei_attribute_category
    ,p_eei_attribute1
    ,p_eei_attribute2
    ,p_eei_attribute3
    ,p_eei_attribute4
    ,p_eei_attribute5
    ,p_eei_attribute6
    ,p_eei_attribute7
    ,p_eei_attribute8
    ,p_eei_attribute9
    ,p_eei_attribute10
    ,p_eei_attribute11
    ,p_eei_attribute12
    ,p_eei_attribute13
    ,p_eei_attribute14
    ,p_eei_attribute15
    ,p_eei_attribute16
    ,p_eei_attribute17
    ,p_eei_attribute18
    ,p_eei_attribute19
    ,p_eei_attribute20
    ,p_eei_information_category
    ,p_eei_information1
    ,p_eei_information2
    ,p_eei_information3
    ,p_eei_information4
    ,p_eei_information5
    ,p_eei_information6
    ,p_eei_information7
    ,p_eei_information8
    ,p_eei_information9
    ,p_eei_information10
    ,p_eei_information11
    ,p_eei_information12
    ,p_eei_information13
    ,p_eei_information14
    ,p_eei_information15
    ,p_eei_information16
    ,p_eei_information17
    ,p_eei_information18
    ,p_eei_information19
    ,p_eei_information20
    ,p_eei_information21
    ,p_eei_information22
    ,p_eei_information23
    ,p_eei_information24
    ,p_eei_information25
    ,p_eei_information26
    ,p_eei_information27
    ,p_eei_information28
    ,p_eei_information29
    ,p_eei_information30
    ,null
    );
  --
  -- Having converted the arguments into the pay_eei_rec
  -- plsql record structure we call the corresponding record business process.
  --
  pay_eei_ins.ins
     (l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_element_type_extra_info_id := l_rec.element_type_extra_info_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pay_eei_ins;

/
