--------------------------------------------------------
--  DDL for Package Body IRC_IDO_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_IDO_INS" as
/* $Header: iridorhi.pkb 120.5.12010000.2 2008/09/26 13:55:20 pvelugul ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_ido_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_document_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_document_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  irc_ido_ins.g_document_id_i := p_document_id;
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
  (p_rec in out nocopy irc_ido_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  irc_ido_shd.g_api_dml := true;  -- Set the api dml status
  --
  --
  -- Insert the row into: irc_documents
  --
  insert into irc_documents
      (document_id
      ,party_id
      ,person_id
      ,assignment_id
      ,character_doc
      ,binary_doc
      ,file_name
      ,file_format
      ,mime_type
      ,description
      ,type
      ,parsed_xml
      ,object_version_number
      ,end_date
      )
  Values
    (p_rec.document_id
    ,p_rec.party_id
    ,p_rec.person_id
    ,p_rec.assignment_id
    ,empty_clob()
    ,empty_blob()
    ,p_rec.file_name
    ,p_rec.file_format
    ,p_rec.mime_type
    ,p_rec.description
    ,p_rec.type
    ,empty_clob()
    ,p_rec.object_version_number
    ,p_rec.end_date
    );
  --
  irc_ido_shd.g_api_dml := false;  -- Unset the api dml status
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    irc_ido_shd.g_api_dml := false;  -- Unset the api dml status
    --
    irc_ido_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    irc_ido_shd.g_api_dml := false;  -- Unset the api dml status
    --
    irc_ido_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    irc_ido_shd.g_api_dml := false;  -- Unset the api dml status
    --
    irc_ido_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
    irc_ido_shd.g_api_dml := false;  -- Unset the api dml status
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
  (p_rec  in out nocopy irc_ido_shd.g_rec_type
  ) is
--
  Cursor C_Sel1 is select irc_documents_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from irc_documents
     where document_id =
             irc_ido_ins.g_document_id_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (irc_ido_ins.g_document_id_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','irc_documents');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.document_id :=
      irc_ido_ins.g_document_id_i;
    irc_ido_ins.g_document_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.document_id;
    Close C_Sel1;
  End If;
  --
  -- Derive file_format from MIME type
  --
  if (p_rec.mime_type = 'text/html') OR
     (p_rec.mime_type = 'text/xml') then
    p_rec.file_format := 'TEXT';
  else
    p_rec.file_format := 'BINARY';
  end if;
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
  ,p_rec                          in irc_ido_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    irc_ido_rki.after_insert
      (p_effective_date              => p_effective_date
      ,p_document_id
      => p_rec.document_id
      ,p_party_id
      => p_rec.party_id
      ,p_person_id => p_rec.person_id
      ,p_assignment_id
      => p_rec.assignment_id
      ,p_file_name
      => p_rec.file_name
      ,p_file_format
      => p_rec.file_format
      ,p_mime_type
      => p_rec.mime_type
      ,p_description
      => p_rec.description
      ,p_type
      => p_rec.type
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_end_date
      => p_rec.end_date
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'IRC_DOCUMENTS'
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
  ,p_rec                          in out nocopy irc_ido_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  irc_ido_bus.insert_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call the supporting pre-insert operation
  --
  irc_ido_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  irc_ido_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  irc_ido_ins.post_insert
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
  ,p_person_id                      in     number
  ,p_mime_type                      in     varchar2
  ,p_type                           in     varchar2
  ,p_assignment_id                  in     number   default null
  ,p_character_doc                  in     clob     default empty_clob()
  ,p_file_name                      in     varchar2 default null
  ,p_description                    in     varchar2 default null
  ,p_parsed_xml                     in     clob     default empty_clob()
  ,p_end_date			    in	   date	    default null
  ,p_document_id                       out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec   irc_ido_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  irc_ido_shd.convert_args
    (null
    ,null
    ,p_person_id
    ,p_assignment_id
    ,p_character_doc
    ,p_file_name
    ,p_mime_type
    ,p_description
    ,p_type
    ,p_parsed_xml
    ,null
    ,p_end_date
    );
  --
  -- Having converted the arguments into the irc_ido_rec
  -- plsql record structure we call the corresponding record business process.
  --
  irc_ido_ins.ins
     (p_effective_date
     ,l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_document_id := l_rec.document_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end irc_ido_ins;

/
