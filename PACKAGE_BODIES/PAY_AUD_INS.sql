--------------------------------------------------------
--  DDL for Package Body PAY_AUD_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AUD_INS" as
/* $Header: pyaudrhi.pkb 115.4 2002/12/09 10:29:32 alogue ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_aud_ins.';  -- Global package name
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
  (p_rec in out nocopy pay_aud_shd.g_rec_type
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
  -- Insert the row into: pay_stat_trans_audit
  --
  insert into pay_stat_trans_audit
      (stat_trans_audit_id
      ,transaction_type
      ,transaction_subtype
      ,transaction_date
      ,transaction_effective_date
      ,business_group_id
      ,person_id
      ,assignment_id
      ,source1
      ,source1_type
      ,source2
      ,source2_type
      ,source3
      ,source3_type
      ,source4
      ,source4_type
      ,source5
      ,source5_type
      ,transaction_parent_id
      ,audit_information_category
      ,audit_information1
      ,audit_information2
      ,audit_information3
      ,audit_information4
      ,audit_information5
      ,audit_information6
      ,audit_information7
      ,audit_information8
      ,audit_information9
      ,audit_information10
      ,audit_information11
      ,audit_information12
      ,audit_information13
      ,audit_information14
      ,audit_information15
      ,audit_information16
      ,audit_information17
      ,audit_information18
      ,audit_information19
      ,audit_information20
      ,audit_information21
      ,audit_information22
      ,audit_information23
      ,audit_information24
      ,audit_information25
      ,audit_information26
      ,audit_information27
      ,audit_information28
      ,audit_information29
      ,audit_information30
      ,title
      ,object_version_number
      )
  Values
    (p_rec.stat_trans_audit_id
    ,p_rec.transaction_type
    ,p_rec.transaction_subtype
    ,p_rec.transaction_date
    ,p_rec.transaction_effective_date
    ,p_rec.business_group_id
    ,p_rec.person_id
    ,p_rec.assignment_id
    ,p_rec.source1
    ,p_rec.source1_type
    ,p_rec.source2
    ,p_rec.source2_type
    ,p_rec.source3
    ,p_rec.source3_type
    ,p_rec.source4
    ,p_rec.source4_type
    ,p_rec.source5
    ,p_rec.source5_type
    ,p_rec.transaction_parent_id
    ,p_rec.audit_information_category
    ,p_rec.audit_information1
    ,p_rec.audit_information2
    ,p_rec.audit_information3
    ,p_rec.audit_information4
    ,p_rec.audit_information5
    ,p_rec.audit_information6
    ,p_rec.audit_information7
    ,p_rec.audit_information8
    ,p_rec.audit_information9
    ,p_rec.audit_information10
    ,p_rec.audit_information11
    ,p_rec.audit_information12
    ,p_rec.audit_information13
    ,p_rec.audit_information14
    ,p_rec.audit_information15
    ,p_rec.audit_information16
    ,p_rec.audit_information17
    ,p_rec.audit_information18
    ,p_rec.audit_information19
    ,p_rec.audit_information20
    ,p_rec.audit_information21
    ,p_rec.audit_information22
    ,p_rec.audit_information23
    ,p_rec.audit_information24
    ,p_rec.audit_information25
    ,p_rec.audit_information26
    ,p_rec.audit_information27
    ,p_rec.audit_information28
    ,p_rec.audit_information29
    ,p_rec.audit_information30
    ,p_rec.title
    ,p_rec.object_version_number
    );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    pay_aud_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    pay_aud_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    pay_aud_shd.constraint_error
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
  (p_rec  in out nocopy pay_aud_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select pay_stat_trans_audit_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.stat_trans_audit_id;
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
  ,p_rec                          in pay_aud_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pay_aud_rki.after_insert
      (p_effective_date              => p_effective_date
      ,p_stat_trans_audit_id
      => p_rec.stat_trans_audit_id
      ,p_transaction_type
      => p_rec.transaction_type
      ,p_transaction_subtype
      => p_rec.transaction_subtype
      ,p_transaction_date
      => p_rec.transaction_date
      ,p_transaction_effective_date
      => p_rec.transaction_effective_date
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_person_id
      => p_rec.person_id
      ,p_assignment_id
      => p_rec.assignment_id
      ,p_source1
      => p_rec.source1
      ,p_source1_type
      => p_rec.source1_type
      ,p_source2
      => p_rec.source2
      ,p_source2_type
      => p_rec.source2_type
      ,p_source3
      => p_rec.source3
      ,p_source3_type
      => p_rec.source3_type
      ,p_source4
      => p_rec.source4
      ,p_source4_type
      => p_rec.source4_type
      ,p_source5
      => p_rec.source5
      ,p_source5_type
      => p_rec.source5_type
      ,p_transaction_parent_id
      => p_rec.transaction_parent_id
      ,p_audit_information_category
      => p_rec.audit_information_category
      ,p_audit_information1
      => p_rec.audit_information1
      ,p_audit_information2
      => p_rec.audit_information2
      ,p_audit_information3
      => p_rec.audit_information3
      ,p_audit_information4
      => p_rec.audit_information4
      ,p_audit_information5
      => p_rec.audit_information5
      ,p_audit_information6
      => p_rec.audit_information6
      ,p_audit_information7
      => p_rec.audit_information7
      ,p_audit_information8
      => p_rec.audit_information8
      ,p_audit_information9
      => p_rec.audit_information9
      ,p_audit_information10
      => p_rec.audit_information10
      ,p_audit_information11
      => p_rec.audit_information11
      ,p_audit_information12
      => p_rec.audit_information12
      ,p_audit_information13
      => p_rec.audit_information13
      ,p_audit_information14
      => p_rec.audit_information14
      ,p_audit_information15
      => p_rec.audit_information15
      ,p_audit_information16
      => p_rec.audit_information16
      ,p_audit_information17
      => p_rec.audit_information17
      ,p_audit_information18
      => p_rec.audit_information18
      ,p_audit_information19
      => p_rec.audit_information19
      ,p_audit_information20
      => p_rec.audit_information20
      ,p_audit_information21
      => p_rec.audit_information21
      ,p_audit_information22
      => p_rec.audit_information22
      ,p_audit_information23
      => p_rec.audit_information23
      ,p_audit_information24
      => p_rec.audit_information24
      ,p_audit_information25
      => p_rec.audit_information25
      ,p_audit_information26
      => p_rec.audit_information26
      ,p_audit_information27
      => p_rec.audit_information27
      ,p_audit_information28
      => p_rec.audit_information28
      ,p_audit_information29
      => p_rec.audit_information29
      ,p_audit_information30
      => p_rec.audit_information30
      ,p_title
      => p_rec.title
      ,p_object_version_number
      => p_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_STAT_TRANS_AUDIT'
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
  ,p_rec                          in out nocopy pay_aud_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  pay_aud_bus.insert_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call the supporting pre-insert operation
  --
  pay_aud_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  pay_aud_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  pay_aud_ins.post_insert
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
  ,p_transaction_type               in     varchar2
  ,p_transaction_date               in     date
  ,p_transaction_effective_date     in     date
  ,p_business_group_id              in     number
  ,p_transaction_subtype            in     varchar2 default null
  ,p_person_id                      in     number   default null
  ,p_assignment_id                  in     number   default null
  ,p_source1                        in     varchar2 default null
  ,p_source1_type                   in     varchar2 default null
  ,p_source2                        in     varchar2 default null
  ,p_source2_type                   in     varchar2 default null
  ,p_source3                        in     varchar2 default null
  ,p_source3_type                   in     varchar2 default null
  ,p_source4                        in     varchar2 default null
  ,p_source4_type                   in     varchar2 default null
  ,p_source5                        in     varchar2 default null
  ,p_source5_type                   in     varchar2 default null
  ,p_transaction_parent_id          in     number   default null
  ,p_audit_information_category     in     varchar2 default null
  ,p_audit_information1             in     varchar2 default null
  ,p_audit_information2             in     varchar2 default null
  ,p_audit_information3             in     varchar2 default null
  ,p_audit_information4             in     varchar2 default null
  ,p_audit_information5             in     varchar2 default null
  ,p_audit_information6             in     varchar2 default null
  ,p_audit_information7             in     varchar2 default null
  ,p_audit_information8             in     varchar2 default null
  ,p_audit_information9             in     varchar2 default null
  ,p_audit_information10            in     varchar2 default null
  ,p_audit_information11            in     varchar2 default null
  ,p_audit_information12            in     varchar2 default null
  ,p_audit_information13            in     varchar2 default null
  ,p_audit_information14            in     varchar2 default null
  ,p_audit_information15            in     varchar2 default null
  ,p_audit_information16            in     varchar2 default null
  ,p_audit_information17            in     varchar2 default null
  ,p_audit_information18            in     varchar2 default null
  ,p_audit_information19            in     varchar2 default null
  ,p_audit_information20            in     varchar2 default null
  ,p_audit_information21            in     varchar2 default null
  ,p_audit_information22            in     varchar2 default null
  ,p_audit_information23            in     varchar2 default null
  ,p_audit_information24            in     varchar2 default null
  ,p_audit_information25            in     varchar2 default null
  ,p_audit_information26            in     varchar2 default null
  ,p_audit_information27            in     varchar2 default null
  ,p_audit_information28            in     varchar2 default null
  ,p_audit_information29            in     varchar2 default null
  ,p_audit_information30            in     varchar2 default null
  ,p_title                          in     varchar2 default null
  ,p_stat_trans_audit_id              out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
--
  l_rec	  pay_aud_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pay_aud_shd.convert_args
    (null
    ,p_transaction_type
    ,p_transaction_subtype
    ,p_transaction_date
    ,p_transaction_effective_date
    ,p_business_group_id
    ,p_person_id
    ,p_assignment_id
    ,p_source1
    ,p_source1_type
    ,p_source2
    ,p_source2_type
    ,p_source3
    ,p_source3_type
    ,p_source4
    ,p_source4_type
    ,p_source5
    ,p_source5_type
    ,p_transaction_parent_id
    ,p_audit_information_category
    ,p_audit_information1
    ,p_audit_information2
    ,p_audit_information3
    ,p_audit_information4
    ,p_audit_information5
    ,p_audit_information6
    ,p_audit_information7
    ,p_audit_information8
    ,p_audit_information9
    ,p_audit_information10
    ,p_audit_information11
    ,p_audit_information12
    ,p_audit_information13
    ,p_audit_information14
    ,p_audit_information15
    ,p_audit_information16
    ,p_audit_information17
    ,p_audit_information18
    ,p_audit_information19
    ,p_audit_information20
    ,p_audit_information21
    ,p_audit_information22
    ,p_audit_information23
    ,p_audit_information24
    ,p_audit_information25
    ,p_audit_information26
    ,p_audit_information27
    ,p_audit_information28
    ,p_audit_information29
    ,p_audit_information30
    ,p_title
    ,null
    );
  --
  -- Having converted the arguments into the pay_aud_rec
  -- plsql record structure we call the corresponding record business process.
  --
  pay_aud_ins.ins
     (p_effective_date
     ,l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_stat_trans_audit_id := l_rec.stat_trans_audit_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pay_aud_ins;

/
