--------------------------------------------------------
--  DDL for Package Body PER_CPA_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CPA_INS" as
/* $Header: pecparhi.pkb 115.4 2002/12/04 15:03:48 pkakar noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)    := '  per_cpa_ins.';  -- Global package name
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
  (p_rec in out nocopy per_cpa_shd.g_rec_type
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
  -- Insert the row into: per_cagr_api_parameters
  --
  insert into per_cagr_api_parameters
      (cagr_api_param_id
      ,cagr_api_id
      ,display_name
      ,parameter_name
      ,column_type
      ,column_size
      ,uom_parameter
      ,uom_lookup
	  ,default_uom
	  ,hidden
      ,object_version_number
      )
  Values
    (p_rec.cagr_api_param_id
    ,p_rec.cagr_api_id
    ,p_rec.display_name
    ,p_rec.parameter_name
    ,p_rec.column_type
    ,p_rec.column_size
    ,p_rec.uom_parameter
    ,p_rec.uom_lookup
	,p_rec.default_uom
	,p_rec.hidden
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
    per_cpa_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    per_cpa_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    per_cpa_shd.constraint_error
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
  (p_rec  in out nocopy per_cpa_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select per_cagr_api_parameters_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.cagr_api_param_id;
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
  ,p_rec                          in per_cpa_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  /*
  begin
    --
	/*
    per_cpa_rki.after_insert
      (p_effective_date        => p_effective_date
      ,p_cagr_api_param_id     => p_rec.cagr_api_param_id
      ,p_cagr_api_id           => p_rec.cagr_api_id
      ,p_display_name          => p_rec.display_name
      ,p_parameter_name        => p_rec.parameter_name
      ,p_column_type           => p_rec.column_type
      ,p_column_size           => p_rec.column_size
      ,p_uom_parameter         => p_rec.uom_parameter
      ,p_uom_lookup            => p_rec.uom_lookup
	  ,p_default_uom           => p_rec.default_uom
      ,p_object_version_number => p_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_CAGR_API_PARAMETERS'
        ,p_hook_type   => 'AI');
      --
  end;
  */
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date               in date
  ,p_rec                          in out nocopy per_cpa_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  per_cpa_bus.insert_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call the supporting pre-insert operation
  --
  per_cpa_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  per_cpa_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  /*per_cpa_ins.post_insert
     (p_effective_date
     ,p_rec
     ); */
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date                 in     date
  ,p_cagr_api_id                    in     number
  ,p_display_name                   in     varchar2 default null
  ,p_parameter_name                 in     varchar2 default null
  ,p_column_type                    in     varchar2 default null
  ,p_column_size                    in     number   default null
  ,p_uom_parameter                  in     varchar2 default null
  ,p_uom_lookup                     in     varchar2 default null
  ,p_default_uom                    in     varchar2 default null
  ,p_hidden                         in     varchar2
  ,p_cagr_api_param_id                 out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec      per_cpa_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  per_cpa_shd.convert_args
    (null
    ,p_cagr_api_id
    ,p_display_name
    ,p_parameter_name
    ,p_column_type
    ,p_column_size
    ,p_uom_parameter
    ,p_uom_lookup
	,p_default_uom
	,p_hidden
    ,null
    );
  --
  -- Having converted the arguments into the per_cpa_rec
  -- plsql record structure we call the corresponding record business process.
  --
  per_cpa_ins.ins
    (p_effective_date
    ,l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_cagr_api_param_id := l_rec.cagr_api_param_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end per_cpa_ins;

/
