--------------------------------------------------------
--  DDL for Package Body PAY_PMA_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PMA_INS" as
/* $Header: pypmarhi.pkb 115.2 2002/12/11 11:12:57 ssivasu2 noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_pma_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy pay_pma_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  pay_pma_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: pay_ca_pmed_accounts
  --
  insert into pay_ca_pmed_accounts
  (	organization_id,
	source_id,
	account_number,
	enabled,
	description,
	business_group_id,
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
	attribute21,
	attribute22,
	attribute23,
	attribute24,
	attribute25,
	attribute26,
	attribute27,
	attribute28,
	attribute29,
	attribute30,
	object_version_number
  )
  Values
  (	p_rec.organization_id,
	p_rec.source_id,
	p_rec.account_number,
	p_rec.enabled,
	p_rec.description,
	p_rec.business_group_id,
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
	p_rec.attribute21,
	p_rec.attribute22,
	p_rec.attribute23,
	p_rec.attribute24,
	p_rec.attribute25,
	p_rec.attribute26,
	p_rec.attribute27,
	p_rec.attribute28,
	p_rec.attribute29,
	p_rec.attribute30,
	p_rec.object_version_number
  );
  --
  pay_pma_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pay_pma_shd.g_api_dml := false;   -- Unset the api dml status
    pay_pma_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pay_pma_shd.g_api_dml := false;   -- Unset the api dml status
    pay_pma_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pay_pma_shd.g_api_dml := false;   -- Unset the api dml status
    pay_pma_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pay_pma_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert(p_rec  in out nocopy pay_pma_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select pay_wci_rates_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.source_id;
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
Procedure post_insert(p_rec in pay_pma_shd.g_rec_type) is
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
    pay_pma_rki.after_insert
      (
  p_organization_id               =>p_rec.organization_id
 ,p_source_id                     =>p_rec.source_id
 ,p_account_number                =>p_rec.account_number
 ,p_enabled                       =>p_rec.enabled
 ,p_description                   =>p_rec.description
 ,p_business_group_id             =>p_rec.business_group_id
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
 ,p_attribute21                   =>p_rec.attribute21
 ,p_attribute22                   =>p_rec.attribute22
 ,p_attribute23                   =>p_rec.attribute23
 ,p_attribute24                   =>p_rec.attribute24
 ,p_attribute25                   =>p_rec.attribute25
 ,p_attribute26                   =>p_rec.attribute26
 ,p_attribute27                   =>p_rec.attribute27
 ,p_attribute28                   =>p_rec.attribute28
 ,p_attribute29                   =>p_rec.attribute29
 ,p_attribute30                   =>p_rec.attribute30
 ,p_object_version_number         =>p_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pay_ca_pmed_accounts'
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
  p_rec        in out nocopy pay_pma_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  pay_pma_bus.insert_validate(p_rec);
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
  p_organization_id              in          number,
  p_source_id                    out nocopy  number,
  p_account_number               in          varchar2,
  p_enabled                      in          varchar2,
  p_description                  in          varchar2         default null,
  p_business_group_id            in          number           default null,
  p_attribute_category           in          varchar2         default null,
  p_attribute1                   in          varchar2         default null,
  p_attribute2                   in          varchar2         default null,
  p_attribute3                   in          varchar2         default null,
  p_attribute4                   in          varchar2         default null,
  p_attribute5                   in          varchar2         default null,
  p_attribute6                   in          varchar2         default null,
  p_attribute7                   in          varchar2         default null,
  p_attribute8                   in          varchar2         default null,
  p_attribute9                   in          varchar2         default null,
  p_attribute10                  in          varchar2         default null,
  p_attribute11                  in          varchar2         default null,
  p_attribute12                  in          varchar2         default null,
  p_attribute13                  in          varchar2         default null,
  p_attribute14                  in          varchar2         default null,
  p_attribute15                  in          varchar2         default null,
  p_attribute16                  in          varchar2         default null,
  p_attribute17                  in          varchar2         default null,
  p_attribute18                  in          varchar2         default null,
  p_attribute19                  in          varchar2         default null,
  p_attribute20                  in          varchar2         default null,
  p_attribute21                  in          varchar2         default null,
  p_attribute22                  in          varchar2         default null,
  p_attribute23                  in          varchar2         default null,
  p_attribute24                  in          varchar2         default null,
  p_attribute25                  in          varchar2         default null,
  p_attribute26                  in          varchar2         default null,
  p_attribute27                  in          varchar2         default null,
  p_attribute28                  in          varchar2         default null,
  p_attribute29                  in          varchar2         default null,
  p_attribute30                  in          varchar2         default null,
  p_object_version_number        out nocopy  number
  ) is
--
  l_rec	  pay_pma_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pay_pma_shd.convert_args
  (
  p_organization_id,
  null,
  p_account_number,
  p_enabled,
  p_description,
  p_business_group_id,
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
  p_attribute21,
  p_attribute22,
  p_attribute23,
  p_attribute24,
  p_attribute25,
  p_attribute26,
  p_attribute27,
  p_attribute28,
  p_attribute29,
  p_attribute30,
  null
  );
  --
  -- Having converted the arguments into the pay_pma_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_source_id := l_rec.source_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pay_pma_ins;

/
