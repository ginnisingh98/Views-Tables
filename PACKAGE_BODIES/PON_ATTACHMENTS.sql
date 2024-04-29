--------------------------------------------------------
--  DDL for Package Body PON_ATTACHMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_ATTACHMENTS" AS
/* $Header: PONATCHB.pls 120.2 2007/06/28 20:25:31 sssahai ship $ */

FUNCTION check_attachment_exists(p_entity_name IN VARCHAR2,
                                 p_pk1_value IN VARCHAR2 DEFAULT NULL,
                                 p_pk2_value IN VARCHAR2 DEFAULT NULL,
                                 p_pk3_value IN VARCHAR2 DEFAULT NULL,
                                 p_pk4_value IN VARCHAR2 DEFAULT NULL,
                                 p_pk5_value IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2

IS

l_has_attachments VARCHAR2(1);

BEGIN

  SELECT decode(count(1), 0, 'N', 'Y')
  INTO   l_has_attachments
  FROM   fnd_attached_documents
  WHERE  entity_name = p_entity_name AND
         decode(p_pk1_value, null, -1, pk1_value) = decode(p_pk1_value, null, -1, p_pk1_value) AND
         decode(p_pk2_value, null, -1, pk2_value) = decode(p_pk2_value, null, -1, p_pk2_value) AND
         decode(p_pk3_value, null, -1, pk3_value) = decode(p_pk3_value, null, -1, p_pk3_value) AND
         decode(p_pk4_value, null, -1, pk4_value) = decode(p_pk4_value, null, -1, p_pk4_value) AND
         decode(p_pk5_value, null, -1, pk5_value) = decode(p_pk5_value, null, -1, p_pk5_value) AND
         rownum = 1;

  RETURN l_has_attachments;

END check_attachment_exists;


PROCEDURE add_attachment_blob(
p_file_name in VARCHAR2,
p_file_content_type in VARCHAR2,
p_file_format in VARCHAR2,
p_file_id out nocopy NUMBER
) IS
l_file_id NUMBER;
BEGIN
  INSERT INTO fnd_lobs (
    file_id,
    file_content_type,
    file_name,
    file_format,
    file_data) VALUES (
    fnd_lobs_s.nextval,
    p_file_content_type,
    p_file_name,
    p_file_format,
    empty_blob())
    RETURNING file_id INTO l_file_id;

  p_file_id := l_file_id;
END add_attachment_blob;

-- without column1
PROCEDURE add_attachment(
        p_seq_num                 in NUMBER,
        p_category_id             in NUMBER,
        p_document_description    in VARCHAR2,
        p_datatype_id             in NUMBER,
        p_short_text              in VARCHAR2,
        p_file_name               in VARCHAR2,
        p_url                     in VARCHAR2,
        p_entity_name             in VARCHAR2,
        p_pk1_value               in VARCHAR2,
        p_pk2_value               in VARCHAR2,
        p_pk3_value               in VARCHAR2,
        p_pk4_value               in VARCHAR2,
        p_pk5_value               in VARCHAR2,
        p_media_id                in NUMBER,
	p_user_id                 in NUMBER,
        x_attached_document_id    out nocopy NUMBER,
        x_file_id                 out nocopy NUMBER
) IS
BEGIN
    PON_ATTACHMENTS.add_attachment(
        p_seq_num                 => p_seq_num                ,
        p_category_id             => p_category_id            ,
        p_document_description    => p_document_description   ,
        p_datatype_id             => p_datatype_id            ,
        p_short_text              => p_short_text             ,
        p_file_name               => p_file_name              ,
        p_url                     => p_url                    ,
        p_entity_name             => p_entity_name            ,
        p_pk1_value               => p_pk1_value              ,
        p_pk2_value               => p_pk2_value              ,
        p_pk3_value               => p_pk3_value              ,
        p_pk4_value               => p_pk4_value              ,
        p_pk5_value               => p_pk5_value              ,
        p_media_id                => p_media_id               ,
        p_user_id                 => p_user_id                ,
	p_column1                 => NULL                     ,
	x_attached_document_id    => x_attached_document_id   ,
        x_file_id                 => x_file_id
      );
END add_attachment;

-- with column1
PROCEDURE add_attachment(
        p_seq_num                 in NUMBER,
        p_category_id             in NUMBER,
        p_document_description    in VARCHAR2,
        p_datatype_id             in NUMBER,
        p_short_text              in VARCHAR2,
        p_file_name               in VARCHAR2,
        p_url                     in VARCHAR2,
        p_entity_name             in VARCHAR2,
        p_pk1_value               in VARCHAR2,
        p_pk2_value               in VARCHAR2,
        p_pk3_value               in VARCHAR2,
        p_pk4_value               in VARCHAR2,
        p_pk5_value               in VARCHAR2,
        p_media_id                in NUMBER,
	p_user_id                 in NUMBER,
	p_column1                 IN VARCHAR2,
        x_attached_document_id    out nocopy NUMBER,
        x_file_id                 out nocopy NUMBER
) IS
 l_rowid                varchar2(30);
 l_attached_document_id number;
 l_media_id             number:= add_attachment.p_media_id;
 l_document_id          number;

 l_file_name            varchar2(255);
 l_creation_date        date := SYSDATE;
 l_created_by           number;
 l_last_update_date     date := SYSDATE;
 l_last_updated_by      number;
 l_lang                 varchar2(40);
BEGIN
  -- Set file name
  IF (p_datatype_id = 1) THEN
    l_file_name := add_attachment.p_file_name;
  ELSIF (p_datatype_id = 5 ) THEN
    l_file_name := p_url;
    l_media_id := NULL;
  ELSIF (p_datatype_id in (6,7) ) THEN
    l_file_name := add_attachment.p_file_name;
  END IF;

  -- Set the WHO Columns.
  l_created_by := p_user_id;
  l_last_updated_by := l_created_by;

  -- Attached Document Id has to be populated from the sequence.
  SELECT fnd_attached_documents_s.nextval
  INTO l_attached_document_id
  FROM sys.dual;

  -- Set the language parameter
  SELECT USERENV('LANG')
  INTO l_lang
  FROM dual;

  -- Call the server side package for adding the attachment and documents.
  fnd_attached_documents_pkg.insert_row (
        x_rowid                 => l_rowid                      ,
        x_attached_document_id  => l_attached_document_id       ,
        x_document_id           => l_document_id                ,
        x_creation_date         => l_creation_date              ,
        x_created_by            => l_created_by                 ,
        x_last_update_date      => l_last_update_date           ,
        x_last_updated_by       => l_last_updated_by            ,
        x_last_update_login     => NULL                         ,
        x_seq_num               => p_seq_num                    ,
        x_entity_name           => p_entity_name                ,
        x_column1               => p_column1                    ,
        x_pk1_value             => p_pk1_value                  ,
        x_pk2_value             => p_pk2_value                  ,
        x_pk3_value             => p_pk3_value                  ,
        x_pk4_value             => p_pk4_value                  ,
        x_pk5_value             => p_pk5_value                  ,
        x_automatically_added_flag      => 'N'                  ,
        x_request_id            => NULL                         ,
        x_program_application_id        =>NULL                  ,
        x_program_id            => NULL                         ,
        x_program_update_date   => NULL                         ,
        x_attribute_category    => NULL                         ,
        x_attribute1            => NULL                         ,
        x_attribute2            => NULL                         ,
        x_attribute3            => NULL                         ,
        x_attribute4            => NULL                         ,
        x_attribute5            => NULL                         ,
        x_attribute6            => NULL                         ,
        x_attribute7            => NULL                         ,
        x_attribute8            => NULL                         ,
        x_attribute9            => NULL                         ,
        x_attribute10           => NULL                         ,
        x_attribute11           => NULL                         ,
        x_attribute12           => NULL                         ,
        x_attribute13           => NULL                         ,
        x_attribute14           => NULL                         ,
        x_attribute15           => NULL                         ,
        x_datatype_id           => p_datatype_id                ,
        x_category_id           => p_category_id                ,
        x_security_type         => 4                            ,
        x_security_id           => NULL                         ,
        x_publish_flag          => 'Y'                          ,
        x_image_type            => NULL                         ,
        x_storage_type          => NULL                         ,
        x_usage_type            => 'O'                          ,
        x_language              => l_lang                       ,
        x_description           => p_document_description       ,
        x_file_name             => l_file_name                  ,
        x_media_id              => l_media_id                   ,
        x_doc_attribute_category        => NULL                 ,
        x_doc_attribute1        => NULL                         ,
        x_doc_attribute2        => NULL                         ,
        x_doc_attribute3        => NULL                         ,
        x_doc_attribute4        => NULL                         ,
        x_doc_attribute5        => NULL                         ,
        x_doc_attribute6        => NULL                         ,
        x_doc_attribute7        => NULL                         ,
        x_doc_attribute8        => NULL                         ,
        x_doc_attribute9        => NULL                         ,
        x_doc_attribute10       => NULL                         ,
        x_doc_attribute11       => NULL                         ,
        x_doc_attribute12       => NULL                         ,
        x_doc_attribute13       => NULL                         ,
        x_doc_attribute14       => NULL                         ,
        x_doc_attribute15       => NULL
  );

  IF (p_datatype_id = PON_ATTACHMENTS.SHORT_TEXT) THEN
    INSERT INTO fnd_documents_short_text(
      media_id,
      short_text)
      VALUES (
      l_media_id,
      p_short_text);
  END IF;

  x_attached_document_id := l_attached_document_id;
  x_file_id := l_media_id;

END add_attachment;


PROCEDURE add_long_text_attachment(
        p_seq_num                 in NUMBER,
        p_category_id             in NUMBER,
        p_document_description    in VARCHAR2,
        p_long_text               in LONG,
        p_file_name               in VARCHAR2,
        p_url                     in VARCHAR2,
        p_entity_name             in VARCHAR2,
        p_pk1_value               in VARCHAR2,
        p_pk2_value               in VARCHAR2,
        p_pk3_value               in VARCHAR2,
        p_pk4_value               in VARCHAR2,
        p_pk5_value               in VARCHAR2,
        p_media_id                in NUMBER,
        p_user_id                 in NUMBER,
	p_column1                 IN VARCHAR2,
	x_attached_document_id    out nocopy NUMBER,
        x_file_id                 out nocopy NUMBER
) IS
 l_rowid                varchar2(30);
 l_attached_document_id number;
 l_media_id             number:= add_long_text_attachment.p_media_id;
 l_document_id          number;

 l_file_name            varchar2(255);
 l_creation_date        date := SYSDATE;
 l_created_by           number;
 l_last_update_date     date := SYSDATE;
 l_last_updated_by      number;
 l_lang                 varchar2(40);
 l_progress             NUMBER; -- Debug Purposes
BEGIN
  -- Set file name
  l_progress  := 1;
  l_file_name := add_long_text_attachment.p_file_name;

  -- Set the WHO Columns.
  l_progress   := 2;
  l_created_by := p_user_id;
  l_last_updated_by := l_created_by;

  -- Attached Document Id has to be populated from the sequence.
  l_progress   := 3;
  SELECT fnd_attached_documents_s.nextval
  INTO l_attached_document_id
  FROM sys.dual;

  -- Set the language parameter
  l_progress   := 4;
  SELECT USERENV('LANG')
  INTO l_lang
  FROM dual;

  -- Call the server side package for adding the attachment and documents.
  l_progress   := 5;
  fnd_attached_documents_pkg.insert_row (
        x_rowid                 => l_rowid                      ,
        x_attached_document_id  => l_attached_document_id       ,
        x_document_id           => l_document_id                ,
        x_creation_date         => l_creation_date              ,
        x_created_by            => l_created_by                 ,
        x_last_update_date      => l_last_update_date           ,
        x_last_updated_by       => l_last_updated_by            ,
        x_last_update_login     => NULL                         ,
        x_seq_num               => p_seq_num                    ,
        x_entity_name           => p_entity_name                ,
        x_column1               => p_column1                    ,
        x_pk1_value             => p_pk1_value                  ,
        x_pk2_value             => p_pk2_value                  ,
        x_pk3_value             => p_pk3_value                  ,
        x_pk4_value             => p_pk4_value                  ,
        x_pk5_value             => p_pk5_value                  ,
        x_automatically_added_flag      => 'N'                  ,
        x_request_id            => NULL                         ,
        x_program_application_id        =>NULL                  ,
        x_program_id            => NULL                         ,
        x_program_update_date   => NULL                         ,
        x_attribute_category    => NULL                         ,
        x_attribute1            => NULL                         ,
        x_attribute2            => NULL                         ,
        x_attribute3            => NULL                         ,
        x_attribute4            => NULL                         ,
        x_attribute5            => NULL                         ,
        x_attribute6            => NULL                         ,
        x_attribute7            => NULL                         ,
        x_attribute8            => NULL                         ,
        x_attribute9            => NULL                         ,
        x_attribute10           => NULL                         ,
        x_attribute11           => NULL                         ,
        x_attribute12           => NULL                         ,
        x_attribute13           => NULL                         ,
        x_attribute14           => NULL                         ,
        x_attribute15           => NULL                         ,
        x_datatype_id           => PON_ATTACHMENTS.LONG_TEXT    ,
        x_category_id           => p_category_id                  ,
        x_security_type         => 4                            ,
        x_security_id           => NULL                         ,
        x_publish_flag          => 'Y'                          ,
        x_image_type            => NULL                         ,
        x_storage_type          => NULL                         ,
        x_usage_type            => 'O'                          ,
        x_language              => l_lang                       ,
        x_description           => p_document_description         ,
        x_file_name             => l_file_name                  ,
        x_media_id              => l_media_id                   ,
        x_doc_attribute_category        => NULL                 ,
        x_doc_attribute1        => NULL                         ,
        x_doc_attribute2        => NULL                         ,
        x_doc_attribute3        => NULL                         ,
        x_doc_attribute4        => NULL                         ,
        x_doc_attribute5        => NULL                         ,
        x_doc_attribute6        => NULL                         ,
        x_doc_attribute7        => NULL                         ,
        x_doc_attribute8        => NULL                         ,
        x_doc_attribute9        => NULL                         ,
        x_doc_attribute10       => NULL                         ,
        x_doc_attribute11       => NULL                         ,
        x_doc_attribute12       => NULL                         ,
        x_doc_attribute13       => NULL                         ,
        x_doc_attribute14       => NULL                         ,
        x_doc_attribute15       => NULL
  );

  -- Insert available Long Text into FND_DOCUMENTS_LONG_TEXT
  l_progress  := 6;
  INSERT INTO fnd_documents_long_text
  (
      media_id,
      long_text
  ) VALUES (
      l_media_id,
      p_long_text
  );

  -- Save obtained values
  l_progress  := 7;
  x_attached_document_id := l_attached_document_id;
  x_file_id := l_media_id;

EXCEPTION
  When Others Then
    Raise_Application_Error(
                              -20001,
                              'Error at Step : ' || l_progress || ' ' ||
                              'in add_long_text_attachment(...) ' ||
                               SQLERRM,
                               true
                           );

END add_long_text_attachment;


PROCEDURE add_attachment_frm_doc_catalog(
       p_seq_num                in  NUMBER,
       p_entity_name            in  VARCHAR2,
       p_pk1_value              in  VARCHAR2,
       p_pk2_value              in  VARCHAR2,
       p_pk3_value              in  VARCHAR2,
       p_pk4_value              in  VARCHAR2,
       p_pk5_value              in  VARCHAR2,
       p_document_id            in  NUMBER,
       p_column1                IN VARCHAR2,
       x_attached_document_id   out nocopy  NUMBER
)
IS

 l_rowid                varchar2(30);
 l_attached_document_id number;
 l_media_id             number;
 l_document_id          number:= add_attachment_frm_doc_catalog.p_document_id;
 l_datatype_id          number;
 l_category_id          number;
 l_file_name            varchar2(255);
 l_description          FND_DOCUMENTS_TL.DESCRIPTION%Type;
 l_creation_date        date := SYSDATE;
 l_created_by           number;
 l_last_update_date     date := SYSDATE;
 l_last_updated_by      number;
 l_lang                 varchar2(40);
 l_usage_type           FND_DOCUMENTS.USAGE_TYPE%Type;

 l_create_doc           varchar2(1):= 'N';

 l_doc_attribute_category  FND_DOCUMENTS_TL.DOC_ATTRIBUTE_CATEGORY%Type;
 l_doc_attribute1          FND_DOCUMENTS_TL.DOC_ATTRIBUTE1%Type;
 l_doc_attribute2          FND_DOCUMENTS_TL.DOC_ATTRIBUTE2%Type;
 l_doc_attribute3          FND_DOCUMENTS_TL.DOC_ATTRIBUTE3%Type;
 l_doc_attribute4          FND_DOCUMENTS_TL.DOC_ATTRIBUTE4%Type;
 l_doc_attribute5          FND_DOCUMENTS_TL.DOC_ATTRIBUTE5%Type;
 l_doc_attribute6          FND_DOCUMENTS_TL.DOC_ATTRIBUTE6%Type;
 l_doc_attribute7          FND_DOCUMENTS_TL.DOC_ATTRIBUTE7%Type;
 l_doc_attribute8          FND_DOCUMENTS_TL.DOC_ATTRIBUTE8%Type;
 l_doc_attribute9          FND_DOCUMENTS_TL.DOC_ATTRIBUTE9%Type;
 l_doc_attribute10         FND_DOCUMENTS_TL.DOC_ATTRIBUTE10%Type;
 l_doc_attribute11         FND_DOCUMENTS_TL.DOC_ATTRIBUTE11%Type;
 l_doc_attribute12         FND_DOCUMENTS_TL.DOC_ATTRIBUTE12%Type;
 l_doc_attribute13         FND_DOCUMENTS_TL.DOC_ATTRIBUTE13%Type;
 l_doc_attribute14         FND_DOCUMENTS_TL.DOC_ATTRIBUTE14%Type;
 l_doc_attribute15         FND_DOCUMENTS_TL.DOC_ATTRIBUTE15%Type;

 l_progress             number := 0; -- For debugging purposes

BEGIN

  -- Select Language.
  l_progress := 1;
  Select USERENV('LANG') into l_lang
  From   Dual;

  -- Attached Document ID population from sequence.
  l_progress := 2;
  Select FND_ATTACHED_DOCUMENTS_S.nextval
  Into   l_attached_document_id
  From   Dual
  ;

  -- Select Document Properties
  l_progress := 3;
  Select DTL.FILE_NAME, D.MEDIA_ID, DTL.DESCRIPTION,
         D.DATATYPE_ID, D.CATEGORY_ID, D.USAGE_TYPE,
         DTL.DOC_ATTRIBUTE_CATEGORY, DTL.DOC_ATTRIBUTE1,
         DTL.DOC_ATTRIBUTE2, DTL.DOC_ATTRIBUTE3,
         DTL.DOC_ATTRIBUTE4, DTL.DOC_ATTRIBUTE5,
         DTL.DOC_ATTRIBUTE6, DTL.DOC_ATTRIBUTE7,
         DTL.DOC_ATTRIBUTE8, DTL.DOC_ATTRIBUTE9,
         DTL.DOC_ATTRIBUTE10, DTL.DOC_ATTRIBUTE11,
         DTL.DOC_ATTRIBUTE12, DTL.DOC_ATTRIBUTE13,
         DTL.DOC_ATTRIBUTE14, DTL.DOC_ATTRIBUTE15
  Into   l_file_name, l_media_id, l_description,
         l_datatype_id, l_category_id, l_usage_type,
         l_doc_attribute_category, l_doc_attribute1,
         l_doc_attribute2, l_doc_attribute3,
         l_doc_attribute4, l_doc_attribute5,
         l_doc_attribute6, l_doc_attribute7,
         l_doc_attribute8, l_doc_attribute9,
         l_doc_attribute10, l_doc_attribute11,
         l_doc_attribute12, l_doc_attribute13,
         l_doc_attribute14, l_doc_attribute15
  From   FND_DOCUMENTS D, FND_DOCUMENTS_TL DTL
  Where  DTL.DOCUMENT_ID = D.DOCUMENT_ID
  And    DTL.DOCUMENT_ID = l_document_id
  And    DTL.LANGUAGE    = l_lang
  ;

  -- Set WHO columns
  l_progress := 4;
  l_created_by      := 1;
  l_last_updated_by := l_created_by;

  -- (Re)set relevant attributes (including desc. flex. segments) based upon
  -- document properties retrieved above.  We create only an attachment
  -- in case if the document is of the usage type 'Standard'; in all
  -- other cases a new document with the usage type 'One-Time' is
  -- created and the attachment is made out of it. Excepting the usage type,
  -- such a new document would be a replica of the original document.

  If ( l_usage_type <> 'S') Then
    l_progress := 5;
    l_document_id := NULL;    -- The following FND API call creates a new
                              -- document on containing a NULL value for its
                              -- 'x_document_id' parameter.
    l_usage_type  := 'O';     -- 'O' stands for a 'One-Time' Document.
    l_create_doc  := 'Y';     -- Create a 'copy' of the document.
  End If;

  -- Call FND Procedure to create the attachment.
  l_progress := 6;
  fnd_attached_documents_pkg.insert_row (
        x_rowid                 => l_rowid                      ,
        x_attached_document_id  => l_attached_document_id       ,
        x_document_id           => l_document_id                ,
        x_creation_date         => l_creation_date              ,
        x_created_by            => l_created_by                 ,
        x_last_update_date      => l_last_update_date           ,
        x_last_updated_by       => l_last_updated_by            ,
        x_last_update_login     => NULL                         ,
        x_seq_num               => p_seq_num                    ,
        x_entity_name           => p_entity_name                ,
        x_column1               => p_column1                    ,
        x_pk1_value             => p_pk1_value                  ,
        x_pk2_value             => p_pk2_value                  ,
        x_pk3_value             => p_pk3_value                  ,
        x_pk4_value             => p_pk4_value                  ,
        x_pk5_value             => p_pk5_value                  ,
        x_automatically_added_flag      => 'N'                  ,
        x_request_id            => NULL                         ,
        x_program_application_id        =>NULL                  ,
        x_program_id            => NULL                         ,
        x_program_update_date   => NULL                         ,
        x_attribute_category    => NULL                         ,
        x_attribute1            => NULL                         ,
        x_attribute2            => NULL                         ,
        x_attribute3            => NULL                         ,
        x_attribute4            => NULL                         ,
        x_attribute5            => NULL                         ,
        x_attribute6            => NULL                         ,
        x_attribute7            => NULL                         ,
        x_attribute8            => NULL                         ,
        x_attribute9            => NULL                         ,
        x_attribute10           => NULL                         ,
        x_attribute11           => NULL                         ,
        x_attribute12           => NULL                         ,
        x_attribute13           => NULL                         ,
        x_attribute14           => NULL                         ,
        x_attribute15           => NULL                         ,
        x_datatype_id           => l_datatype_id                ,
        x_category_id           => l_category_id                ,
        x_security_type         => 4                            ,
        x_security_id           => NULL                         ,
        x_publish_flag          => 'Y'                          ,
        x_image_type            => NULL                         ,
        x_storage_type          => NULL                         ,
        x_usage_type            => l_usage_type                 ,
        x_language              => l_lang                       ,
        x_description           => l_description                ,
        x_file_name             => l_file_name                  ,
        x_media_id              => l_media_id                   ,
        x_doc_attribute_category   => l_doc_attribute_category  ,
        x_doc_attribute1        => l_doc_attribute1             ,
        x_doc_attribute2        => l_doc_attribute2             ,
        x_doc_attribute3        => l_doc_attribute3             ,
        x_doc_attribute4        => l_doc_attribute4             ,
        x_doc_attribute5        => l_doc_attribute5             ,
        x_doc_attribute6        => l_doc_attribute6             ,
        x_doc_attribute7        => l_doc_attribute7             ,
        x_doc_attribute8        => l_doc_attribute8             ,
        x_doc_attribute9        => l_doc_attribute9             ,
        x_doc_attribute10       => l_doc_attribute10            ,
        x_doc_attribute11       => l_doc_attribute11            ,
        x_doc_attribute12       => l_doc_attribute12            ,
        x_doc_attribute13       => l_doc_attribute13            ,
        x_doc_attribute14       => l_doc_attribute14            ,
        x_doc_attribute15       => l_doc_attribute15            ,
        x_create_doc            => l_create_doc
  );

  -- Save Obtained Values
  l_progress := 7;
  x_attached_document_id := l_attached_document_id;

EXCEPTION
  When Others Then
    Raise_Application_Error(
                              -20001,
                              'Error at Step : ' || l_progress || ' ' ||
                              'in add_attachment_frm_doc_catalog(...) ' ||
                               SQLERRM,
                               true
                           );

END add_attachment_frm_doc_catalog;

--without column1
PROCEDURE add_attachment_frm_ui(
        p_seq_num                 in NUMBER,
        p_category_id             in NUMBER,
        p_document_description    in VARCHAR2,
        p_datatype_id             in NUMBER,
        p_short_text              in VARCHAR2,
        p_long_text               in LONG,
        p_file_name               in VARCHAR2,
        p_url                     in VARCHAR2,
        p_entity_name             in VARCHAR2,
        p_pk1_value               in VARCHAR2,
        p_pk2_value               in VARCHAR2,
        p_pk3_value               in VARCHAR2,
        p_pk4_value               in VARCHAR2,
        p_pk5_value               in VARCHAR2,
        p_media_id                in NUMBER,
        p_user_id                 in NUMBER,
	p_document_id             in NUMBER,
        x_attached_document_id    out nocopy NUMBER,
	x_file_id                 out nocopy NUMBER
) IS
BEGIN
    PON_ATTACHMENTS.add_attachment_frm_ui(
        p_seq_num                 => p_seq_num                ,
        p_category_id             => p_category_id            ,
        p_document_description    => p_document_description   ,
        p_datatype_id             => p_datatype_id            ,
	p_short_text              => p_short_text             ,
	p_long_text               => p_long_text              ,
        p_file_name               => p_file_name              ,
        p_url                     => p_url                    ,
        p_entity_name             => p_entity_name            ,
        p_pk1_value               => p_pk1_value              ,
        p_pk2_value               => p_pk2_value              ,
        p_pk3_value               => p_pk3_value              ,
        p_pk4_value               => p_pk4_value              ,
        p_pk5_value               => p_pk5_value              ,
        p_media_id                => p_media_id               ,
        p_user_id                 => p_user_id                ,
        p_document_id             => p_document_id            ,
        p_column1                 => NULL                     ,
	x_attached_document_id    => x_attached_document_id   ,
        x_file_id                 => x_file_id
    );
END add_attachment_frm_ui;


--with column1
PROCEDURE add_attachment_frm_ui(
        p_seq_num                 in NUMBER,
        p_category_id             in NUMBER,
        p_document_description    in VARCHAR2,
        p_datatype_id             in NUMBER,
        p_short_text              in VARCHAR2,
        p_long_text               in LONG,
        p_file_name               in VARCHAR2,
        p_url                     in VARCHAR2,
        p_entity_name             in VARCHAR2,
        p_pk1_value               in VARCHAR2,
        p_pk2_value               in VARCHAR2,
        p_pk3_value               in VARCHAR2,
        p_pk4_value               in VARCHAR2,
        p_pk5_value               in VARCHAR2,
        p_media_id                in NUMBER,
        p_user_id                 in NUMBER,
	p_document_id             in NUMBER,
	p_column1                 IN VARCHAR2,
        x_attached_document_id    out nocopy NUMBER,
        x_file_id                 out nocopy NUMBER
) IS
  l_attached_document_id   FND_ATTACHED_DOCUMENTS.ATTACHED_DOCUMENT_ID%Type
                                  := 0;
  l_file_id                FND_DOCUMENTS_TL.MEDIA_ID%Type
                                  := 0;
  l_datatype_id            FND_DOCUMENTS.DATATYPE_ID%Type
                                  := add_attachment_frm_ui.p_datatype_id;
  l_progress               NUMBER := 0;   -- For debugging purposes
BEGIN

  If ( p_document_id Is Not NULL) Then


  --  Call the procedure to create attachment from Document Catalog

    l_progress := 1;
    PON_ATTACHMENTS.add_attachment_frm_doc_catalog(
       p_seq_num                => p_seq_num        ,
       p_entity_name            => p_entity_name    ,
       p_pk1_value              => p_pk1_value      ,
       p_pk2_value              => p_pk2_value      ,
       p_pk3_value              => p_pk3_value      ,
       p_pk4_value              => p_pk4_value      ,
       p_pk5_value              => p_pk5_value      ,
       p_document_id            => p_document_id    ,
       p_column1                => p_column1        ,
       x_attached_document_id   => l_attached_document_id
    );

  ElsIf ( l_datatype_id = PON_ATTACHMENTS.LONG_TEXT ) Then

  --  Call procedure to create a long text attachment

    l_progress := 2;
    PON_ATTACHMENTS.add_long_text_attachment (
        p_seq_num                => p_seq_num                 ,
        p_category_id            => p_category_id             ,
        p_document_description   => p_document_description    ,
        p_long_text              => p_long_text               ,
        p_file_name              => p_file_name               ,
        p_url                    => p_url                     ,
        p_entity_name            => p_entity_name             ,
        p_pk1_value              => p_pk1_value               ,
        p_pk2_value              => p_pk2_value               ,
        p_pk3_value              => p_pk3_value               ,
        p_pk4_value              => p_pk4_value               ,
        p_pk5_value              => p_pk5_value               ,
        p_media_id               => p_media_id                ,
        p_user_id                => p_user_id                 ,
        p_column1                => p_column1                 ,
	x_attached_document_id   => l_attached_document_id    ,
        x_file_id                => l_file_id
    );

  Else

  --  Default situation : create URL/Short Text/File type of attachment.

    l_progress := 3;
    PON_ATTACHMENTS.add_attachment(
        p_seq_num                 => p_seq_num                ,
        p_category_id             => p_category_id            ,
        p_document_description    => p_document_description   ,
        p_datatype_id             => p_datatype_id            ,
        p_short_text              => p_short_text             ,
        p_file_name               => p_file_name              ,
        p_url                     => p_url                    ,
        p_entity_name             => p_entity_name            ,
        p_pk1_value               => p_pk1_value              ,
        p_pk2_value               => p_pk2_value              ,
        p_pk3_value               => p_pk3_value              ,
        p_pk4_value               => p_pk4_value              ,
        p_pk5_value               => p_pk5_value              ,
        p_media_id                => p_media_id               ,
        p_user_id                 => p_user_id                ,
	p_column1                 => p_column1                ,
	x_attached_document_id    => l_attached_document_id   ,
        x_file_id                 => l_file_id
    );

  End If;

  l_progress             := 4;
  x_attached_document_id := l_attached_document_id;
  x_file_id              := l_file_id;

EXCEPTION
  When Others Then
    Raise_Application_Error(
                              -20001,
                              'Error at Step : ' || l_progress || ' ' ||
                              'in add_attachment_frm_ui(...) ' ||
                               SQLERRM,
                               true
                           );

END add_attachment_frm_ui;

PROCEDURE delete_attachment(
        p_attached_document_id    in NUMBER,
        p_datatype_id             in NUMBER
) IS

l_attached_document_id Number :=  delete_attachment.p_attached_document_id;
l_datatype_id          number;
l_file_name            varchar2(255);
l_usage_type           Varchar2(1);
l_attached_count       Number := 0 ;

BEGIN

  --
  -- Deletion Logic :
  --
  -- 1. Do NOT delete the document associated with the attachment
  --    if the document's usage type is not 'One-Time'.
  --
  -- 2. Do NOT delete a document if it is attached to multiple
  --    attachments.
  --

  Select doc.Usage_Type Into l_usage_type
  From   Fnd_Documents doc
  Where  doc.Document_Id =
     (
       Select att.Document_Id
       From   Fnd_Attached_Documents att
       Where  att.Attached_Document_Id = l_attached_document_id
     );

  Select Count(*) Into l_attached_count
  From   Fnd_Attached_Documents
  Where  Document_Id =
     (
       Select a.Document_Id
       From   Fnd_Attached_Documents a
       Where  a.Attached_Document_Id = l_attached_document_id
     );

  If ( (l_usage_type = 'O') AND (l_attached_count <= 1) ) Then
    -- Call the procedure to delete the attachment and document.
    fnd_attached_documents3_pkg.delete_row (
                                l_attached_document_id,
                                p_datatype_id,
                                'Y'
                                           );
  Else
    -- Call the procedure to delete just the attachment.
    fnd_attached_documents3_pkg.delete_row (
                                l_attached_document_id,
                                p_datatype_id,
                                'N'
                                           );
  End If;

END delete_attachment;


END PON_ATTACHMENTS;

/
