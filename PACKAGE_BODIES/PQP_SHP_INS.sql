--------------------------------------------------------
--  DDL for Package Body PQP_SHP_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_SHP_INS" as
/* $Header: pqshprhi.pkb 115.8 2003/02/17 22:14:48 tmehra noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqp_shp_ins.';  -- Global package name
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
  (p_rec in out nocopy pqp_shp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  pqp_shp_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: pqp_service_history_periods
  --
  insert into pqp_service_history_periods
      (service_history_period_id
      ,business_group_id
      ,assignment_id
      ,start_date
      ,end_date
      ,employer_name
      ,employer_address
      ,employer_type
      ,employer_subtype
      ,period_years
      ,period_days
      ,description
      ,continuous_service
      ,all_assignments
      ,object_version_number
      ,shp_attribute_category
      ,shp_attribute1
      ,shp_attribute2
      ,shp_attribute3
      ,shp_attribute4
      ,shp_attribute5
      ,shp_attribute6
      ,shp_attribute7
      ,shp_attribute8
      ,shp_attribute9
      ,shp_attribute10
      ,shp_attribute11
      ,shp_attribute12
      ,shp_attribute13
      ,shp_attribute14
      ,shp_attribute15
      ,shp_attribute16
      ,shp_attribute17
      ,shp_attribute18
      ,shp_attribute19
      ,shp_attribute20
      ,shp_information_category
      ,shp_information1
      ,shp_information2
      ,shp_information3
      ,shp_information4
      ,shp_information5
      ,shp_information6
      ,shp_information7
      ,shp_information8
      ,shp_information9
      ,shp_information10
      ,shp_information11
      ,shp_information12
      ,shp_information13
      ,shp_information14
      ,shp_information15
      ,shp_information16
      ,shp_information17
      ,shp_information18
      ,shp_information19
      ,shp_information20
      )
  Values
    (p_rec.service_history_period_id
    ,p_rec.business_group_id
    ,p_rec.assignment_id
    ,p_rec.start_date
    ,p_rec.end_date
    ,p_rec.employer_name
    ,p_rec.employer_address
    ,p_rec.employer_type
    ,p_rec.employer_subtype
    ,p_rec.period_years
    ,p_rec.period_days
    ,p_rec.description
    ,p_rec.continuous_service
    ,p_rec.all_assignments
    ,p_rec.object_version_number
    ,p_rec.shp_attribute_category
    ,p_rec.shp_attribute1
    ,p_rec.shp_attribute2
    ,p_rec.shp_attribute3
    ,p_rec.shp_attribute4
    ,p_rec.shp_attribute5
    ,p_rec.shp_attribute6
    ,p_rec.shp_attribute7
    ,p_rec.shp_attribute8
    ,p_rec.shp_attribute9
    ,p_rec.shp_attribute10
    ,p_rec.shp_attribute11
    ,p_rec.shp_attribute12
    ,p_rec.shp_attribute13
    ,p_rec.shp_attribute14
    ,p_rec.shp_attribute15
    ,p_rec.shp_attribute16
    ,p_rec.shp_attribute17
    ,p_rec.shp_attribute18
    ,p_rec.shp_attribute19
    ,p_rec.shp_attribute20
    ,p_rec.shp_information_category
    ,p_rec.shp_information1
    ,p_rec.shp_information2
    ,p_rec.shp_information3
    ,p_rec.shp_information4
    ,p_rec.shp_information5
    ,p_rec.shp_information6
    ,p_rec.shp_information7
    ,p_rec.shp_information8
    ,p_rec.shp_information9
    ,p_rec.shp_information10
    ,p_rec.shp_information11
    ,p_rec.shp_information12
    ,p_rec.shp_information13
    ,p_rec.shp_information14
    ,p_rec.shp_information15
    ,p_rec.shp_information16
    ,p_rec.shp_information17
    ,p_rec.shp_information18
    ,p_rec.shp_information19
    ,p_rec.shp_information20
    );
  --
  pqp_shp_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqp_shp_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_shp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pqp_shp_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_shp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqp_shp_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_shp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pqp_shp_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec  in out nocopy pqp_shp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select pqp_service_history_periods_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.service_history_period_id;
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
  (
   p_rec                          in pqp_shp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pqp_shp_rki.after_insert
      (
      p_service_history_period_id
      => p_rec.service_history_period_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_assignment_id
      => p_rec.assignment_id
      ,p_start_date
      => p_rec.start_date
      ,p_end_date
      => p_rec.end_date
      ,p_employer_name
      => p_rec.employer_name
      ,p_employer_address
      => p_rec.employer_address
      ,p_employer_type
      => p_rec.employer_type
      ,p_employer_subtype
      => p_rec.employer_subtype
      ,p_period_years
      => p_rec.period_years
      ,p_period_days
      => p_rec.period_days
      ,p_description
      => p_rec.description
      ,p_continuous_service
      => p_rec.continuous_service
      ,p_all_assignments
      => p_rec.all_assignments
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_shp_attribute_category
      => p_rec.shp_attribute_category
      ,p_shp_attribute1
      => p_rec.shp_attribute1
      ,p_shp_attribute2
      => p_rec.shp_attribute2
      ,p_shp_attribute3
      => p_rec.shp_attribute3
      ,p_shp_attribute4
      => p_rec.shp_attribute4
      ,p_shp_attribute5
      => p_rec.shp_attribute5
      ,p_shp_attribute6
      => p_rec.shp_attribute6
      ,p_shp_attribute7
      => p_rec.shp_attribute7
      ,p_shp_attribute8
      => p_rec.shp_attribute8
      ,p_shp_attribute9
      => p_rec.shp_attribute9
      ,p_shp_attribute10
      => p_rec.shp_attribute10
      ,p_shp_attribute11
      => p_rec.shp_attribute11
      ,p_shp_attribute12
      => p_rec.shp_attribute12
      ,p_shp_attribute13
      => p_rec.shp_attribute13
      ,p_shp_attribute14
      => p_rec.shp_attribute14
      ,p_shp_attribute15
      => p_rec.shp_attribute15
      ,p_shp_attribute16
      => p_rec.shp_attribute16
      ,p_shp_attribute17
      => p_rec.shp_attribute17
      ,p_shp_attribute18
      => p_rec.shp_attribute18
      ,p_shp_attribute19
      => p_rec.shp_attribute19
      ,p_shp_attribute20
      => p_rec.shp_attribute20
      ,p_shp_information_category
      => p_rec.shp_information_category
      ,p_shp_information1
      => p_rec.shp_information1
      ,p_shp_information2
      => p_rec.shp_information2
      ,p_shp_information3
      => p_rec.shp_information3
      ,p_shp_information4
      => p_rec.shp_information4
      ,p_shp_information5
      => p_rec.shp_information5
      ,p_shp_information6
      => p_rec.shp_information6
      ,p_shp_information7
      => p_rec.shp_information7
      ,p_shp_information8
      => p_rec.shp_information8
      ,p_shp_information9
      => p_rec.shp_information9
      ,p_shp_information10
      => p_rec.shp_information10
      ,p_shp_information11
      => p_rec.shp_information11
      ,p_shp_information12
      => p_rec.shp_information12
      ,p_shp_information13
      => p_rec.shp_information13
      ,p_shp_information14
      => p_rec.shp_information14
      ,p_shp_information15
      => p_rec.shp_information15
      ,p_shp_information16
      => p_rec.shp_information16
      ,p_shp_information17
      => p_rec.shp_information17
      ,p_shp_information18
      => p_rec.shp_information18
      ,p_shp_information19
      => p_rec.shp_information19
      ,p_shp_information20
      => p_rec.shp_information20
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_SERVICE_HISTORY_PERIODS'
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
  p_rec                          in out nocopy pqp_shp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  pqp_shp_bus.insert_validate
     (
   p_rec
     );
  --
  -- Call the supporting pre-insert operation
  --
  pqp_shp_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  pqp_shp_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  pqp_shp_ins.post_insert
     (
      p_rec
     );
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_business_group_id              in     number
  ,p_assignment_id                  in     number
  ,p_start_date                     in     date     default null
  ,p_end_date                       in     date     default null
  ,p_employer_name                  in     varchar2 default null
  ,p_employer_address               in     varchar2 default null
  ,p_employer_type                  in     varchar2 default null
  ,p_employer_subtype               in     varchar2 default null
  ,p_period_years                   in     number   default null
  ,p_period_days                    in     number   default null
  ,p_description                    in     varchar2 default null
  ,p_continuous_service             in     varchar2 default null
  ,p_all_assignments                in     varchar2 default null
  ,p_shp_attribute_category         in     varchar2 default null
  ,p_shp_attribute1                 in     varchar2 default null
  ,p_shp_attribute2                 in     varchar2 default null
  ,p_shp_attribute3                 in     varchar2 default null
  ,p_shp_attribute4                 in     varchar2 default null
  ,p_shp_attribute5                 in     varchar2 default null
  ,p_shp_attribute6                 in     varchar2 default null
  ,p_shp_attribute7                 in     varchar2 default null
  ,p_shp_attribute8                 in     varchar2 default null
  ,p_shp_attribute9                 in     varchar2 default null
  ,p_shp_attribute10                in     varchar2 default null
  ,p_shp_attribute11                in     varchar2 default null
  ,p_shp_attribute12                in     varchar2 default null
  ,p_shp_attribute13                in     varchar2 default null
  ,p_shp_attribute14                in     varchar2 default null
  ,p_shp_attribute15                in     varchar2 default null
  ,p_shp_attribute16                in     varchar2 default null
  ,p_shp_attribute17                in     varchar2 default null
  ,p_shp_attribute18                in     varchar2 default null
  ,p_shp_attribute19                in     varchar2 default null
  ,p_shp_attribute20                in     varchar2 default null
  ,p_shp_information_category       in     varchar2 default null
  ,p_shp_information1               in     varchar2 default null
  ,p_shp_information2               in     varchar2 default null
  ,p_shp_information3               in     varchar2 default null
  ,p_shp_information4               in     varchar2 default null
  ,p_shp_information5               in     varchar2 default null
  ,p_shp_information6               in     varchar2 default null
  ,p_shp_information7               in     varchar2 default null
  ,p_shp_information8               in     varchar2 default null
  ,p_shp_information9               in     varchar2 default null
  ,p_shp_information10              in     varchar2 default null
  ,p_shp_information11              in     varchar2 default null
  ,p_shp_information12              in     varchar2 default null
  ,p_shp_information13              in     varchar2 default null
  ,p_shp_information14              in     varchar2 default null
  ,p_shp_information15              in     varchar2 default null
  ,p_shp_information16              in     varchar2 default null
  ,p_shp_information17              in     varchar2 default null
  ,p_shp_information18              in     varchar2 default null
  ,p_shp_information19              in     varchar2 default null
  ,p_shp_information20              in     varchar2 default null
  ,p_service_history_period_id         out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec	  pqp_shp_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pqp_shp_shd.convert_args
    (null
    ,p_business_group_id
    ,p_assignment_id
    ,p_start_date
    ,p_end_date
    ,p_employer_name
    ,p_employer_address
    ,p_employer_type
    ,p_employer_subtype
    ,p_period_years
    ,p_period_days
    ,p_description
    ,p_continuous_service
    ,p_all_assignments
    ,null
    ,p_shp_attribute_category
    ,p_shp_attribute1
    ,p_shp_attribute2
    ,p_shp_attribute3
    ,p_shp_attribute4
    ,p_shp_attribute5
    ,p_shp_attribute6
    ,p_shp_attribute7
    ,p_shp_attribute8
    ,p_shp_attribute9
    ,p_shp_attribute10
    ,p_shp_attribute11
    ,p_shp_attribute12
    ,p_shp_attribute13
    ,p_shp_attribute14
    ,p_shp_attribute15
    ,p_shp_attribute16
    ,p_shp_attribute17
    ,p_shp_attribute18
    ,p_shp_attribute19
    ,p_shp_attribute20
    ,p_shp_information_category
    ,p_shp_information1
    ,p_shp_information2
    ,p_shp_information3
    ,p_shp_information4
    ,p_shp_information5
    ,p_shp_information6
    ,p_shp_information7
    ,p_shp_information8
    ,p_shp_information9
    ,p_shp_information10
    ,p_shp_information11
    ,p_shp_information12
    ,p_shp_information13
    ,p_shp_information14
    ,p_shp_information15
    ,p_shp_information16
    ,p_shp_information17
    ,p_shp_information18
    ,p_shp_information19
    ,p_shp_information20
    );
  --
  -- Having converted the arguments into the pqp_shp_rec
  -- plsql record structure we call the corresponding record business process.
  --
  pqp_shp_ins.ins
     (
      l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_service_history_period_id := l_rec.service_history_period_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pqp_shp_ins;

/
