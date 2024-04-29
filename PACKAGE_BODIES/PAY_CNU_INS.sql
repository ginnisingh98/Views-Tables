--------------------------------------------------------
--  DDL for Package Body PAY_CNU_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CNU_INS" as
/* $Header: pycnurhi.pkb 120.0 2005/05/29 04:04:56 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_cnu_ins.';  -- Global package name
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
  (p_rec in out nocopy pay_cnu_shd.g_rec_type
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
  -- Insert the row into: pay_fr_contribution_usages
  --
  insert into pay_fr_contribution_usages
      (contribution_usage_id
      ,date_from
      ,date_to
      ,group_code
      ,process_type
      ,element_name
      ,rate_type
      ,contribution_code
      ,retro_contribution_code
      ,contribution_type
      ,contribution_usage_type
      ,rate_category
      ,business_group_id
      ,object_version_number
	  ,code_rate_id
      )
  Values
    (p_rec.contribution_usage_id
    ,p_rec.date_from
    ,p_rec.date_to
    ,p_rec.group_code
    ,p_rec.process_type
    ,p_rec.element_name
    ,p_rec.rate_type
    ,p_rec.contribution_code
    ,p_rec.retro_contribution_code
    ,p_rec.contribution_type
    ,p_rec.contribution_usage_type
    ,p_rec.rate_category
    ,p_rec.business_group_id
    ,p_rec.object_version_number
	,p_rec.code_rate_id
    );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    pay_cnu_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    pay_cnu_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    pay_cnu_shd.constraint_error
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
  (p_rec  in out nocopy pay_cnu_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select pay_fr_contribution_usages_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.contribution_usage_id;
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
  (p_rec                          in pay_cnu_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    PAY_cnu_RKI.AFTER_INSERT(
       p_contribution_usage_id     => p_rec.contribution_usage_id
      ,p_date_from               => p_rec.date_from
      ,p_date_to                 => p_rec.date_to
      ,p_group_code              => p_rec.group_code
      ,p_process_type            => p_rec.process_type
      ,p_element_name            => p_rec.element_name
      ,p_rate_type               => p_rec.rate_type
      ,p_contribution_code       => p_rec.contribution_code
      ,p_retro_contribution_code => p_rec.retro_contribution_code
      ,p_contribution_type       => p_rec.contribution_type
      ,p_contribution_usage_type => p_rec.contribution_usage_type
      ,p_rate_category           => p_rec.rate_category
      ,p_business_group_id       => p_rec.business_group_id
      ,p_object_version_number   => p_rec.object_version_number
	  ,p_code_rate_id            => p_rec.code_Rate_id
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_FR_CONTRIBUTION_USAGES'
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
  (p_effective_date               in     date
  ,p_rec                          in out nocopy pay_cnu_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
  l_code_Rate_id          number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  pay_cnu_bus.insert_validate
     (p_effective_date
     ,p_rec
     ,l_code_rate_id
     );
  --
  -- update the row to the derived code_Rate_id
  --
  p_rec.code_Rate_id := l_code_Rate_id;
  --
  -- Call the supporting pre-insert operation
  --
  pay_cnu_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  pay_cnu_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  pay_cnu_ins.post_insert
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
  (p_effective_date                 in     date
  ,p_date_from                      in     date
  ,p_group_code                     in     varchar2
  ,p_process_type                   in     varchar2
  ,p_element_name                   in     varchar2
  ,p_contribution_type              in     varchar2
  ,p_contribution_usage_type        in     varchar2
  ,p_rate_category                  in     varchar2
  ,p_date_to                        in     date     default null
  ,p_rate_type                      in     varchar2 default null
  ,p_contribution_code              in     varchar2 default null
  ,p_retro_contribution_code        in     varchar2 default null
  ,p_business_group_id              in     number   default null
  ,p_contribution_usage_id             out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_code_rate_id                   in out nocopy number
  ) is
--
  l_rec	  pay_cnu_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pay_cnu_shd.convert_args
    (null
    ,p_date_from
    ,p_date_to
    ,p_group_code
    ,p_process_type
    ,p_element_name
    ,p_rate_type
    ,p_contribution_code
    ,p_retro_contribution_code
    ,p_contribution_type
    ,p_contribution_usage_type
    ,p_rate_category
    ,p_business_group_id
    ,null
    ,p_code_Rate_id
    );
  --
  -- Having converted the arguments into the pay_cnu_rec
  -- plsql record structure we call the corresponding record business process.
  --
  pay_cnu_ins.ins
     ( p_effective_date
      ,l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_contribution_usage_id := l_rec.contribution_usage_id;
  p_object_version_number := l_rec.object_version_number;
  p_code_rate_id          := l_rec.code_Rate_id;
  --
  -- The code rate id is IN OUT so it's value will be automatically passed back.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pay_cnu_ins;

/
