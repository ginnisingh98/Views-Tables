--------------------------------------------------------
--  DDL for Package Body HR_ORD_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ORD_INS" as
/* $Header: hrordrhi.pkb 115.7 2002/12/04 06:20:03 hjonnala noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_ord_ins.';  -- Global package name
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
  (p_rec in out nocopy hr_ord_shd.g_rec_type
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
  -- Insert the row into: hr_de_organization_links
  --
  insert into hr_de_organization_links
      (organization_link_id
      ,parent_organization_id
      ,child_organization_id
      ,business_group_id
      ,org_link_information_category
      ,org_link_information1
      ,org_link_information2
      ,org_link_information3
      ,org_link_information4
      ,org_link_information5
      ,org_link_information6
      ,org_link_information7
      ,org_link_information8
      ,org_link_information9
      ,org_link_information10
      ,org_link_information11
      ,org_link_information12
      ,org_link_information13
      ,org_link_information14
      ,org_link_information15
      ,org_link_information16
      ,org_link_information17
      ,org_link_information18
      ,org_link_information19
      ,org_link_information20
      ,org_link_information21
      ,org_link_information22
      ,org_link_information23
      ,org_link_information24
      ,org_link_information25
      ,org_link_information26
      ,org_link_information27
      ,org_link_information28
      ,org_link_information29
      ,org_link_information30
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
      ,org_link_type
      )
  Values
    (p_rec.organization_link_id
    ,p_rec.parent_organization_id
    ,p_rec.child_organization_id
    ,p_rec.business_group_id
    ,p_rec.org_link_information_category
    ,p_rec.org_link_information1
    ,p_rec.org_link_information2
    ,p_rec.org_link_information3
    ,p_rec.org_link_information4
    ,p_rec.org_link_information5
    ,p_rec.org_link_information6
    ,p_rec.org_link_information7
    ,p_rec.org_link_information8
    ,p_rec.org_link_information9
    ,p_rec.org_link_information10
    ,p_rec.org_link_information11
    ,p_rec.org_link_information12
    ,p_rec.org_link_information13
    ,p_rec.org_link_information14
    ,p_rec.org_link_information15
    ,p_rec.org_link_information16
    ,p_rec.org_link_information17
    ,p_rec.org_link_information18
    ,p_rec.org_link_information19
    ,p_rec.org_link_information20
    ,p_rec.org_link_information21
    ,p_rec.org_link_information22
    ,p_rec.org_link_information23
    ,p_rec.org_link_information24
    ,p_rec.org_link_information25
    ,p_rec.org_link_information26
    ,p_rec.org_link_information27
    ,p_rec.org_link_information28
    ,p_rec.org_link_information29
    ,p_rec.org_link_information30
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
    ,p_rec.org_link_type
    );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    hr_ord_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    hr_ord_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    hr_ord_shd.constraint_error
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
  (p_rec  in out nocopy hr_ord_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select hr_de_organization_links_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.organization_link_id;
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
  (p_effective_date               in date
  ,p_rec                          in hr_ord_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    hr_ord_rki.after_insert
      (p_effective_date              => p_effective_date
      ,p_organization_link_id
      => p_rec.organization_link_id
      ,p_parent_organization_id
      => p_rec.parent_organization_id
      ,p_child_organization_id
      => p_rec.child_organization_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_org_link_information_categor
      => p_rec.org_link_information_category
      ,p_org_link_information1
      => p_rec.org_link_information1
      ,p_org_link_information2
      => p_rec.org_link_information2
      ,p_org_link_information3
      => p_rec.org_link_information3
      ,p_org_link_information4
      => p_rec.org_link_information4
      ,p_org_link_information5
      => p_rec.org_link_information5
      ,p_org_link_information6
      => p_rec.org_link_information6
      ,p_org_link_information7
      => p_rec.org_link_information7
      ,p_org_link_information8
      => p_rec.org_link_information8
      ,p_org_link_information9
      => p_rec.org_link_information9
      ,p_org_link_information10
      => p_rec.org_link_information10
      ,p_org_link_information11
      => p_rec.org_link_information11
      ,p_org_link_information12
      => p_rec.org_link_information12
      ,p_org_link_information13
      => p_rec.org_link_information13
      ,p_org_link_information14
      => p_rec.org_link_information14
      ,p_org_link_information15
      => p_rec.org_link_information15
      ,p_org_link_information16
      => p_rec.org_link_information16
      ,p_org_link_information17
      => p_rec.org_link_information17
      ,p_org_link_information18
      => p_rec.org_link_information18
      ,p_org_link_information19
      => p_rec.org_link_information19
      ,p_org_link_information20
      => p_rec.org_link_information20
      ,p_org_link_information21
      => p_rec.org_link_information21
      ,p_org_link_information22
      => p_rec.org_link_information22
      ,p_org_link_information23
      => p_rec.org_link_information23
      ,p_org_link_information24
      => p_rec.org_link_information24
      ,p_org_link_information25
      => p_rec.org_link_information25
      ,p_org_link_information26
      => p_rec.org_link_information26
      ,p_org_link_information27
      => p_rec.org_link_information27
      ,p_org_link_information28
      => p_rec.org_link_information28
      ,p_org_link_information29
      => p_rec.org_link_information29
      ,p_org_link_information30
      => p_rec.org_link_information30
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
      ,p_org_link_type
      => p_rec.org_link_type
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HR_DE_ORGANIZATION_LINKS'
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
  ,p_rec                          in out nocopy hr_ord_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  hr_ord_bus.insert_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call the supporting pre-insert operation
  --
  hr_ord_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  hr_ord_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  hr_ord_ins.post_insert
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
  ,p_parent_organization_id         in     number
  ,p_child_organization_id          in     number
  ,p_business_group_id              in     number
  ,p_org_link_type                  in     varchar2
  ,p_org_link_information_categor   in     varchar2 default null
  ,p_org_link_information1          in     varchar2 default null
  ,p_org_link_information2          in     varchar2 default null
  ,p_org_link_information3          in     varchar2 default null
  ,p_org_link_information4          in     varchar2 default null
  ,p_org_link_information5          in     varchar2 default null
  ,p_org_link_information6          in     varchar2 default null
  ,p_org_link_information7          in     varchar2 default null
  ,p_org_link_information8          in     varchar2 default null
  ,p_org_link_information9          in     varchar2 default null
  ,p_org_link_information10         in     varchar2 default null
  ,p_org_link_information11         in     varchar2 default null
  ,p_org_link_information12         in     varchar2 default null
  ,p_org_link_information13         in     varchar2 default null
  ,p_org_link_information14         in     varchar2 default null
  ,p_org_link_information15         in     varchar2 default null
  ,p_org_link_information16         in     varchar2 default null
  ,p_org_link_information17         in     varchar2 default null
  ,p_org_link_information18         in     varchar2 default null
  ,p_org_link_information19         in     varchar2 default null
  ,p_org_link_information20         in     varchar2 default null
  ,p_org_link_information21         in     varchar2 default null
  ,p_org_link_information22         in     varchar2 default null
  ,p_org_link_information23         in     varchar2 default null
  ,p_org_link_information24         in     varchar2 default null
  ,p_org_link_information25         in     varchar2 default null
  ,p_org_link_information26         in     varchar2 default null
  ,p_org_link_information27         in     varchar2 default null
  ,p_org_link_information28         in     varchar2 default null
  ,p_org_link_information29         in     varchar2 default null
  ,p_org_link_information30         in     varchar2 default null
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
  ,p_organization_link_id              out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec   hr_ord_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  hr_ord_shd.convert_args
    (null
    ,p_parent_organization_id
    ,p_child_organization_id
    ,p_business_group_id
    ,p_org_link_information_categor
    ,p_org_link_information1
    ,p_org_link_information2
    ,p_org_link_information3
    ,p_org_link_information4
    ,p_org_link_information5
    ,p_org_link_information6
    ,p_org_link_information7
    ,p_org_link_information8
    ,p_org_link_information9
    ,p_org_link_information10
    ,p_org_link_information11
    ,p_org_link_information12
    ,p_org_link_information13
    ,p_org_link_information14
    ,p_org_link_information15
    ,p_org_link_information16
    ,p_org_link_information17
    ,p_org_link_information18
    ,p_org_link_information19
    ,p_org_link_information20
    ,p_org_link_information21
    ,p_org_link_information22
    ,p_org_link_information23
    ,p_org_link_information24
    ,p_org_link_information25
    ,p_org_link_information26
    ,p_org_link_information27
    ,p_org_link_information28
    ,p_org_link_information29
    ,p_org_link_information30
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
    ,null
    ,p_org_link_type
    );
  --
  -- Having converted the arguments into the hr_ord_rec
  -- plsql record structure we call the corresponding record business process.
  --
  hr_ord_ins.ins
     (p_effective_date
     ,l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_organization_link_id := l_rec.organization_link_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end hr_ord_ins;

/
