--------------------------------------------------------
--  DDL for Package Body IRC_IDT_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_IDT_INS" as
/* $Header: iridtrhi.pkb 120.0 2005/07/26 15:07:27 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_idt_ins.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic. The processing of
--   this procedure are as follows:
--   1) Initialise the object  ersion_number to 1 if the object  ersion_number
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
--   object  ersion_number which is initialised within this procedure).
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
  (p_rec in out nocopy irc_idt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  --
  -- Insert the row into: irc_default_postings_tl
  --
  insert into irc_default_postings_tl
      (default_posting_id
      ,language
      ,source_language
      ,org_name
      ,org_description
      ,job_title
      ,brief_description
      ,detailed_description
      ,job_requirements
      ,additional_details
      ,how_to_apply
      ,image_url
      ,image_url_alt
      )
  Values
    (p_rec.default_posting_id
    ,p_rec.language
    ,p_rec.source_language
    ,p_rec.org_name
    ,empty_clob()
    ,p_rec.job_title
    ,empty_clob()
    ,empty_clob()
    ,empty_clob()
    ,empty_clob()
    ,empty_clob()
    ,empty_clob()
    ,empty_clob()
    );
  --
  irc_idt_shd.clob_dml(p_rec => p_rec
                      ,p_api_updating => false);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    irc_idt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    irc_idt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    irc_idt_shd.constraint_error
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
  (p_rec                          in out nocopy irc_idt_shd.g_rec_type
  ,p_default_posting_id           in number
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  p_rec.default_posting_id               := p_default_posting_id;
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
  (p_rec                          in irc_idt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    irc_idt_rki.after_insert
      (p_default_posting_id
      => p_rec.default_posting_id
      ,p_language
      => p_rec.language
      ,p_source_language
      => p_rec.source_language
      ,p_org_name
      => p_rec.org_name
      ,p_org_description
      => p_rec.org_description
      ,p_job_title
      => p_rec.job_title
      ,p_brief_description
      => p_rec.brief_description
      ,p_detailed_description
      => p_rec.detailed_description
      ,p_job_requirements
      => p_rec.job_requirements
      ,p_additional_details
      => p_rec.additional_details
      ,p_how_to_apply
      => p_rec.how_to_apply
      ,p_image_url
      => p_rec.image_url
      ,p_image_url_alt
      => p_rec.image_url_alt
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'IRC_DEFAULT_POSTINGS_TL'
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
  (p_rec                          in out nocopy irc_idt_shd.g_rec_type
  ,p_default_posting_id           in number
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  irc_idt_bus.insert_validate
     (p_rec
     );
  --
  -- Call the supporting pre-insert operation
  --
  irc_idt_ins.pre_insert
    (p_rec                         => p_rec
    ,p_default_posting_id          => p_default_posting_id
    );
  --
  -- Insert the row
  --
  irc_idt_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  irc_idt_ins.post_insert
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
  (p_default_posting_id             in     number
  ,p_language                       in     varchar2
  ,p_source_language                in     varchar2
  ,p_org_name                       in     varchar2
  ,p_org_description                in     varchar2
  ,p_job_title                      in     varchar2
  ,p_brief_description              in     varchar2
  ,p_detailed_description           in     varchar2
  ,p_job_requirements               in     varchar2
  ,p_additional_details             in     varchar2
  ,p_how_to_apply                   in     varchar2
  ,p_image_url                      in     varchar2
  ,p_image_url_alt                  in     varchar2
  ) is
--
  l_rec   irc_idt_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  irc_idt_shd.convert_args
    (null
    ,p_language
    ,p_source_language
    ,p_org_name
    ,p_org_description
    ,p_job_title
    ,p_brief_description
    ,p_detailed_description
    ,p_job_requirements
    ,p_additional_details
    ,p_how_to_apply
    ,p_image_url
    ,p_image_url_alt
    );
  --
  -- Having converted the arguments into the irc_idt_rec
  -- plsql record structure we call the corresponding record business process.
  --
  irc_idt_ins.ins
     (p_rec                         => l_rec
     ,p_default_posting_id          => p_default_posting_id
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< ins_tl >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins_tl
  (p_language_code               in varchar2
  ,p_default_posting_id           in number
  ,p_org_name                     in varchar2 default null
  ,p_org_description              in varchar2 default null
  ,p_job_title                    in varchar2 default null
  ,p_brief_description            in varchar2 default null
  ,p_detailed_description         in varchar2 default null
  ,p_job_requirements             in varchar2 default null
  ,p_additional_details           in varchar2 default null
  ,p_how_to_apply                 in varchar2 default null
  ,p_image_url                    in varchar2 default null
  ,p_image_url_alt                in varchar2 default null
  ) is
  --
  -- Cursor to obtain the list of base and installed languages
  --
  cursor csr_ins_langs is
    select l.language_code
      from fnd_languages l
     where l.installed_flag in ('I','B')
       and not exists (select null
                         from irc_default_postings_tl idt
                        where idt.default_posting_id = p_default_posting_id
                          and idt.language = l.language_code);
  --
  l_proc  varchar2(72)  := g_package || 'ins_tl';
  --
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  -- Insert a row for the base language and every installed language.
  --
  for l_lang in csr_ins_langs loop
    irc_idt_ins.ins
      (p_default_posting_id          => p_default_posting_id
      ,p_language                    => l_lang.language_code
      ,p_source_language             => p_language_code
      ,p_org_name                    => p_org_name
      ,p_org_description             => p_org_description
      ,p_job_title                   => p_job_title
      ,p_brief_description           => p_brief_description
      ,p_detailed_description        => p_detailed_description
      ,p_job_requirements            => p_job_requirements
      ,p_additional_details          => p_additional_details
      ,p_how_to_apply                => p_how_to_apply
      ,p_image_url                   => p_image_url
      ,p_image_url_alt               => p_image_url_alt
      );
  end loop;
  --
  hr_utility.set_location('Leaving:'||l_proc,20);
End ins_tl;
--
end irc_idt_ins;

/
