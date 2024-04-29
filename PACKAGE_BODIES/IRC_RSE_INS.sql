--------------------------------------------------------
--  DDL for Package Body IRC_RSE_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_RSE_INS" as
/* $Header: irrserhi.pkb 120.0.12010000.2 2010/01/18 14:37:22 mkjayara ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_rse_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_recruiting_site_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_recruiting_site_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  irc_rse_ins.g_recruiting_site_id_i := p_recruiting_site_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End set_base_key_value;
--
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
  (p_rec in out nocopy irc_rse_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  irc_rse_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: irc_all_recruiting_sites
  --
  insert into irc_all_recruiting_sites
      (recruiting_site_id
      ,date_from
      ,date_to
      ,posting_username
      ,posting_password
      ,internal
      ,external
      ,third_party
      ,posting_cost
      ,posting_cost_period
      ,posting_cost_currency
      ,stylesheet
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
      ,internal_name
      ,posting_impl_class
      )
  Values
    (p_rec.recruiting_site_id
    ,p_rec.date_from
    ,p_rec.date_to
    ,p_rec.posting_username
    ,p_rec.posting_password
    ,p_rec.internal
    ,p_rec.external
    ,p_rec.third_party
    ,p_rec.posting_cost
    ,p_rec.posting_cost_period
    ,p_rec.posting_cost_currency
    ,p_rec.stylesheet
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
    ,p_rec.internal_name
    ,p_rec.posting_impl_class
    );
  --
  --
  irc_rse_shd.g_api_dml := false;  -- Unset the api dml status
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
   irc_rse_shd.g_api_dml := false;  -- Unset the api dml status
    --
    irc_rse_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    irc_rse_shd.g_api_dml := false;  -- Unset the api dml status
    --
    irc_rse_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    irc_rse_shd.g_api_dml := false;  -- Unset the api dml status
    --
    irc_rse_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    irc_rse_shd.g_api_dml := false;  -- Unset the api dml status
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
--   A Pl/Sql record structure.
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
  (p_rec  in out nocopy irc_rse_shd.g_rec_type
  ) is
--
  Cursor C_Sel1 is select irc_all_recruiting_sites_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from irc_all_recruiting_sites
     where recruiting_site_id =
             irc_rse_ins.g_recruiting_site_id_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (irc_rse_ins.g_recruiting_site_id_i is not null) Then
    --
    -- Verify registered primary key values not already in use
    --
    Open C_Sel2;
    Fetch C_Sel2 into l_exists;
    If C_Sel2%found Then
       Close C_Sel2;
       --
       -- The primary key values are already in use.
       --
       fnd_message.set_name('PER','PER_289391_KEY_ALREADY_USED');
       fnd_message.set_token('TABLE_NAME','irc_all_recruiting_sites');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.recruiting_site_id :=
      irc_rse_ins.g_recruiting_site_id_i;
    irc_rse_ins.g_recruiting_site_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.recruiting_site_id;
    Close C_Sel1;
  End If;
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
  ,p_rec                          in irc_rse_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    irc_rse_rki.after_insert
      (p_effective_date              => p_effective_date
      ,p_recruiting_site_id
      => p_rec.recruiting_site_id
      ,p_date_from
      => p_rec.date_from
      ,p_date_to
      => p_rec.date_to
      ,p_posting_username
      => p_rec.posting_username
      ,p_posting_password
      => p_rec.posting_password
      ,p_internal
      => p_rec.internal
      ,p_external
      => p_rec.external
      ,p_third_party
      => p_rec.third_party
      ,p_posting_cost
      => p_rec.posting_cost
      ,p_posting_cost_period
      => p_rec.posting_cost_period
      ,p_posting_cost_currency
      => p_rec.posting_cost_currency
      ,p_stylesheet
      => p_rec.stylesheet
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
      ,p_internal_name
      => p_rec.internal_name
      ,p_posting_impl_class
      => p_rec.posting_impl_class
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'IRC_ALL_RECRUITING_SITES'
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
  ,p_rec                          in out nocopy irc_rse_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  irc_rse_bus.insert_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  irc_rse_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  irc_rse_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  irc_rse_ins.post_insert
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date               in     date
  ,p_date_from                      in date default null
  ,p_date_to                        in date default null
  ,p_posting_username               in varchar2 default null
  ,p_posting_password               in varchar2 default null
  ,p_internal                       in     varchar2
  ,p_external                       in     varchar2
  ,p_third_party                    in     varchar2
  ,p_posting_cost                   in     number   default null
  ,p_posting_cost_period            in     varchar2 default null
  ,p_posting_cost_currency          in     varchar2 default null
  ,p_stylesheet            in     varchar2 default null
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
  ,p_internal_name                  in     varchar2
  ,p_recruiting_site_id                out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_posting_impl_class             in     varchar2 default null
  ) is
--
  l_rec   irc_rse_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  irc_rse_shd.convert_args
    (null
    ,p_date_from
    ,p_date_to
    ,p_posting_username
    ,p_posting_password
    ,p_internal
    ,p_external
    ,p_third_party
    ,p_posting_cost
    ,p_posting_cost_period
    ,p_posting_cost_currency
    ,p_stylesheet
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
    ,p_internal_name
    ,p_posting_impl_class
    );
  --
  -- Having converted the arguments into the irc_rse_rec
  -- plsql record structure we call the corresponding record business process.
  --
  irc_rse_ins.ins
     (p_effective_date
     ,l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_recruiting_site_id := l_rec.recruiting_site_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end irc_rse_ins;

/
