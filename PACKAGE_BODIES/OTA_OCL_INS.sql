--------------------------------------------------------
--  DDL for Package Body OTA_OCL_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_OCL_INS" as
/* $Header: otoclrhi.pkb 120.1.12000000.2 2007/02/07 09:19:37 niarora noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_ocl_ins.';  -- Global package name
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
  (p_rec in out nocopy ota_ocl_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  --
  -- Insert the row into: ota_competence_languages
  --
  insert into ota_competence_languages
      (competence_language_id
      ,competence_id
      ,language_code
      ,min_proficiency_level_id
      ,business_group_id
      ,object_version_number
      ,ocl_information_category
      ,ocl_information1
      ,ocl_information2
      ,ocl_information3
      ,ocl_information4
      ,ocl_information5
      ,ocl_information6
      ,ocl_information7
      ,ocl_information8
      ,ocl_information9
      ,ocl_information10
      ,ocl_information11
      ,ocl_information12
      ,ocl_information13
      ,ocl_information14
      ,ocl_information15
      ,ocl_information16
      ,ocl_information17
      ,ocl_information18
      ,ocl_information19
      ,ocl_information20
      )
  Values
    (p_rec.competence_language_id
    ,p_rec.competence_id
    ,p_rec.language_code
    ,p_rec.min_proficiency_level_id
    ,p_rec.business_group_id
    ,p_rec.object_version_number
    ,p_rec.ocl_information_category
    ,p_rec.ocl_information1
    ,p_rec.ocl_information2
    ,p_rec.ocl_information3
    ,p_rec.ocl_information4
    ,p_rec.ocl_information5
    ,p_rec.ocl_information6
    ,p_rec.ocl_information7
    ,p_rec.ocl_information8
    ,p_rec.ocl_information9
    ,p_rec.ocl_information10
    ,p_rec.ocl_information11
    ,p_rec.ocl_information12
    ,p_rec.ocl_information13
    ,p_rec.ocl_information14
    ,p_rec.ocl_information15
    ,p_rec.ocl_information16
    ,p_rec.ocl_information17
    ,p_rec.ocl_information18
    ,p_rec.ocl_information19
    ,p_rec.ocl_information20
    );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    ota_ocl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    ota_ocl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    ota_ocl_shd.constraint_error
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
  (p_rec  in out nocopy ota_ocl_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ota_competence_languages_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.competence_language_id;
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
  (p_effective_date               in date
  ,p_rec                          in ota_ocl_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    ota_ocl_rki.after_insert
      (p_effective_date              => p_effective_date
      ,p_competence_language_id
      => p_rec.competence_language_id
      ,p_competence_id
      => p_rec.competence_id
      ,p_language_code
      => p_rec.language_code
      ,p_min_proficiency_level_id
      => p_rec.min_proficiency_level_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_ocl_information_category
      => p_rec.ocl_information_category
      ,p_ocl_information1
      => p_rec.ocl_information1
      ,p_ocl_information2
      => p_rec.ocl_information2
      ,p_ocl_information3
      => p_rec.ocl_information3
      ,p_ocl_information4
      => p_rec.ocl_information4
      ,p_ocl_information5
      => p_rec.ocl_information5
      ,p_ocl_information6
      => p_rec.ocl_information6
      ,p_ocl_information7
      => p_rec.ocl_information7
      ,p_ocl_information8
      => p_rec.ocl_information8
      ,p_ocl_information9
      => p_rec.ocl_information9
      ,p_ocl_information10
      => p_rec.ocl_information10
      ,p_ocl_information11
      => p_rec.ocl_information11
      ,p_ocl_information12
      => p_rec.ocl_information12
      ,p_ocl_information13
      => p_rec.ocl_information13
      ,p_ocl_information14
      => p_rec.ocl_information14
      ,p_ocl_information15
      => p_rec.ocl_information15
      ,p_ocl_information16
      => p_rec.ocl_information16
      ,p_ocl_information17
      => p_rec.ocl_information17
      ,p_ocl_information18
      => p_rec.ocl_information18
      ,p_ocl_information19
      => p_rec.ocl_information19
      ,p_ocl_information20
      => p_rec.ocl_information20
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'OTA_COMPETENCE_LANGUAGES'
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
  (p_effective_date               in date
  ,p_rec                          in out nocopy ota_ocl_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ota_ocl_bus.insert_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call the supporting pre-insert operation
  --
  ota_ocl_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  ota_ocl_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  ota_ocl_ins.post_insert
     (p_effective_date
     ,p_rec
     );
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date               in     date
  ,p_competence_id                  in     number
  ,p_language_code                    in     varchar2
  ,p_business_group_id              in     number
  ,p_min_proficiency_level_id       in     number   default null
  ,p_ocl_information_category       in     varchar2 default null
  ,p_ocl_information1               in     varchar2 default null
  ,p_ocl_information2               in     varchar2 default null
  ,p_ocl_information3               in     varchar2 default null
  ,p_ocl_information4               in     varchar2 default null
  ,p_ocl_information5               in     varchar2 default null
  ,p_ocl_information6               in     varchar2 default null
  ,p_ocl_information7               in     varchar2 default null
  ,p_ocl_information8               in     varchar2 default null
  ,p_ocl_information9               in     varchar2 default null
  ,p_ocl_information10              in     varchar2 default null
  ,p_ocl_information11              in     varchar2 default null
  ,p_ocl_information12              in     varchar2 default null
  ,p_ocl_information13              in     varchar2 default null
  ,p_ocl_information14              in     varchar2 default null
  ,p_ocl_information15              in     varchar2 default null
  ,p_ocl_information16              in     varchar2 default null
  ,p_ocl_information17              in     varchar2 default null
  ,p_ocl_information18              in     varchar2 default null
  ,p_ocl_information19              in     varchar2 default null
  ,p_ocl_information20              in     varchar2 default null
  ,p_competence_language_id            out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec	  ota_ocl_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ota_ocl_shd.convert_args
    (null
    ,p_competence_id
    ,p_language_code
    ,p_min_proficiency_level_id
    ,p_business_group_id
    ,null
    ,p_ocl_information_category
    ,p_ocl_information1
    ,p_ocl_information2
    ,p_ocl_information3
    ,p_ocl_information4
    ,p_ocl_information5
    ,p_ocl_information6
    ,p_ocl_information7
    ,p_ocl_information8
    ,p_ocl_information9
    ,p_ocl_information10
    ,p_ocl_information11
    ,p_ocl_information12
    ,p_ocl_information13
    ,p_ocl_information14
    ,p_ocl_information15
    ,p_ocl_information16
    ,p_ocl_information17
    ,p_ocl_information18
    ,p_ocl_information19
    ,p_ocl_information20
    );
  --
  -- Having converted the arguments into the ota_ocl_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ota_ocl_ins.ins
     (p_effective_date
     ,l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_competence_language_id := l_rec.competence_language_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ota_ocl_ins;

/
