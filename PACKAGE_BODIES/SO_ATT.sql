--------------------------------------------------------
--  DDL for Package Body SO_ATT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."SO_ATT" AS
/* $Header: oeatt04b.pls 115.2 99/07/16 08:25:20 porting shi $ */
PROCEDURE mark_record (
  p_src_id      NUMBER,      -- media_id | document_id
  p_short_long  VARCHAR2, -- 'S' | 'L'
  p_source      VARCHAR2,-- 'DOCUMENT' | 'NOTE'
  p_operation   VARCHAR2,-- 'INSERT' | 'UPDATE'
  p_version     VARCHAR2 -- 'SO_10SC' | 'SO_R10'
) IS
  x_document_id NUMBER;
  x_category_id NUMBER;
  x_usage_id    NUMBER;
  x_usage_type  VARCHAR2(1);
  x_application_id NUMBER;

BEGIN
  --  If source is DOCUMENT, then determine if it's
  --  an OE-related document
  IF (p_source = 'DOCUMENT') THEN
	--  call get_note_info with media_id and short/long
	get_note_info(p_src_id, p_short_long, x_document_id,
                      x_category_id, x_usage_id, x_usage_type,
	              x_application_id);
	IF (x_application_id <> 300) THEN
		RETURN;
	END IF;
  END IF;

  INSERT INTO so_note_replication (
    source_id,
    datatype_id,
    source_code,
    operation_code,
    version
  ) VALUES (
    p_src_id,
    decode(p_short_long,'S',1,'L',2),
    p_source,
    p_operation,
    p_version
  );

END;

PROCEDURE clear_mark (
  p_short_long  VARCHAR2, -- 'S' | 'L'
  p_source      VARCHAR2,-- 'DOCUMENT' | 'NOTE'
  p_operation   VARCHAR2,-- 'INSERT' | 'UPDATE'
  p_version     VARCHAR2 -- 'SO_10SC' | 'SO_R10'
) IS

BEGIN

  DELETE FROM so_note_replication
  WHERE datatype_id = decode(p_short_long,'S',1,'L',2)
  AND   source_code     = p_source
  AND   operation_code  = p_operation
  AND   version    = p_version;

END;

FUNCTION get_note_name (
  p_document_id NUMBER
) RETURN VARCHAR2 IS
  x_note_name VARCHAR2(2000);
  x_doc_desc VARCHAR2(30);
  x_language fnd_documents_tl.language%TYPE;
  x_check NUMBER;
  CURSOR doc IS
	SELECT SUBSTR(description,1,30)
	  FROM fnd_documents_tl
	 WHERE document_id = p_document_id
	   AND language = x_language;
  CURSOR check_unique IS
	SELECT 1
	  FROM sys.dual
	 WHERE EXISTS (SELECT 1
			 FROM so_notes
			WHERE name = x_doc_desc);
BEGIN

  x_language := fnd_global.current_language;

  fnd_message.set_name ('OE','OE_GEN_NOTE_NAME');
  fnd_message.set_token('DOCUMENT_ID',to_char(p_document_id));
  x_note_name := fnd_message.get;

  --  get Description from document
  OPEN doc;
  FETCH doc INTO x_doc_desc;
  CLOSE doc;

  --  determine if description is already used in so_notes
  --  so_notes has a non-unique index on name, but the
  --  form enforces uniqueness on name
  OPEN check_unique;
  FETCH check_unique INTO x_check;
  IF (check_unique%NOTFOUND) THEN
	--  if row found, use description rather than
	--  generated name
	x_note_name :=  x_doc_desc;
  END IF;

  CLOSE check_unique;

  RETURN substr( x_note_name, 1, 30 );
END;


FUNCTION get_note_error (
  p_msg_name VARCHAR2,
  p_document_id NUMBER DEFAULT NULL) RETURN VARCHAR2 IS
 x_note_name VARCHAR2(2000);
BEGIN

  IF (p_msg_name = 'OE_NOT_UPDATE_NOTE') THEN
	fnd_message.set_name('OE', p_msg_name);
	x_note_name := fnd_message.get;
  ELSIF (p_msg_name IN ('OE_NOT_NOTE_TOO_LONG','OE_NOT_DOCUMENT_TOO_LONG')
	) THEN
	  fnd_message.set_name ('OE', p_msg_name);
	  fnd_message.set_token('DOCUMENT_ID',to_char(p_document_id));
	  x_note_name := fnd_message.get;
  END IF;

  RETURN(x_note_name);

END get_note_error;



FUNCTION get_document_usage_type (
  p_note_id NUMBER
) RETURN VARCHAR2 IS
  x_note_type_code      VARCHAR2(30);
  x_override_flag       VARCHAR2(1);
  x_document_usage_type VARCHAR2(1);
BEGIN
  /*
  **    Note_Type_Code Override_Allowed_flag  ==>   document_usage_type
  **    -------------- ---------------------        -------------------
  **    Standard(SN)     Y                            Template (T)
  **    Standard(SN)     N                            Standard (S)
  **    One-Time(OT)     Y | N                        One-Time (O)
  */

  SELECT NOTE_TYPE_CODE, OVERRIDE_ALLOWED_FLAG
  INTO x_note_type_code, x_override_flag
  FROM so_notes
  WHERE note_id = p_note_id;

  If (x_note_type_code = 'SN') Then
     If (x_override_flag = 'Y') Then
	x_document_usage_type := 'T';
     Else
	x_document_usage_type := 'S';
     End If;
  Else
     x_document_usage_type := 'O';
  End If;

  RETURN x_document_usage_type;
END;



FUNCTION get_entity_name (p_header_id IN NUMBER, p_line_id IN NUMBER)
 RETURN VARCHAR2 IS
  x_entity_name VARCHAR2(40);
  x_order_category VARCHAR2(30);
  CURSOR c1 IS
    SELECT order_category
      FROM so_headers
     WHERE header_id = p_header_id;
BEGIN

  --  Get order_category
  OPEN c1;
  FETCH c1 INTO x_order_category;
  CLOSE c1;

  IF (x_order_category = 'RMA') THEN
	IF (p_line_id IS NOT NULL) THEN
		x_entity_name := 'SO_RETURN_LINES';
	ELSE
		x_entity_name := 'SO_RETURNS';
	END IF;
  ELSE
	IF (p_line_id IS NOT NULL) THEN
		x_entity_name := 'SO_LINES';
	ELSE
		x_entity_name := 'SO_HEADERS';
	END IF;
  END IF;

  RETURN x_entity_name;
END;


PROCEDURE get_category_id (
  p_usage_id    NUMBER,
  p_category_id OUT NUMBER
) IS
BEGIN

  SELECT snu.category_id
  INTO   p_category_id
  FROM   so_note_usages snu
  WHERE  snu.usage_id = p_usage_id;


  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    p_category_id := -1;
END;


PROCEDURE get_usage_id (
  p_category_id NUMBER,
  p_usage_id    OUT NUMBER
) IS
BEGIN

  SELECT snu.usage_id
  INTO   p_usage_id
  FROM   fnd_document_categories fdc,
         so_note_usages snu
  WHERE  fdc.category_id = snu.category_id
  AND    fdc.category_id = p_category_id;

END;


PROCEDURE get_media_id (
  p_document_id   NUMBER,
  p_media_id      OUT NUMBER,
  p_datatype_id   OUT NUMBER
) IS
BEGIN
  SELECT fd.datatype_id, fdt.media_id
  INTO   p_datatype_id, p_media_id
  FROM   fnd_documents_tl fdt,
         fnd_documents fd
  WHERE  fdt.language = fnd_global.current_language
  AND    fdt.document_id = fd.document_id
  AND    fd.document_id = p_document_id;

END;

FUNCTION get_doc_cat_application(p_document_id IN NUMBER) RETURN NUMBER
IS
  x_category_application NUMBER;
  CURSOR get_doc_cat_app IS
  SELECT fdc.application_id
    FROM fnd_document_categories fdc,
         fnd_documents fd
   WHERE fd.category_id = fdc.category_id
     AND fd.document_id = p_document_id;
BEGIN

  OPEN get_doc_cat_app;
  FETCH get_doc_cat_app INTO x_category_application;
  CLOSE get_doc_cat_app;

  RETURN(NVL(x_category_application,-1));

  EXCEPTION
    WHEN OTHERS THEN CLOSE get_doc_cat_app;
		     RETURN(-1);

END;

FUNCTION get_cat_application(p_category_id IN NUMBER) RETURN NUMBER
IS
 x_application_id NUMBER;
 CURSOR get_app IS
    SELECT application_id
      FROM fnd_document_categories
     WHERE category_id = p_category_id;
BEGIN
   --  get category_application based on category_id
  OPEN get_app;
  FETCH get_app INTO x_application_id;
  CLOSE get_app;

  RETURN( NVL(x_application_id,-1));

  EXCEPTION
    WHEN OTHERS THEN CLOSE get_app;
	             RETURN(-1);
END;

PROCEDURE get_note_info (
  p_media_id      NUMBER,
  p_short_long    VARCHAR2,
  p_document_id   OUT NUMBER,
  p_category_id   OUT NUMBER,
  p_usage_id      OUT NUMBER,
  p_usage_type    OUT VARCHAR2, -- 'O' | 'S'
  p_application_id OUT NUMBER
) IS
  x_category_id  NUMBER;
  x_application_id NUMBER;
 CURSOR c1 IS
  SELECT fd.document_id, fd.category_id,
         fd.usage_type,  fdc.application_id
  FROM   fnd_document_categories fdc,
         fnd_documents_tl fdt,
         fnd_documents fd
  WHERE  fdt.media_id = p_media_id
  AND    fdt.document_id = fd.document_id
  AND    fd.datatype_id = decode (p_short_long, 'S', 1, 2) --short/long
  AND    fd.category_id = fdc.category_id;
BEGIN
  OPEN c1;
  FETCH c1  INTO p_document_id,  x_category_id,
            p_usage_type,   x_application_id;

  CLOSE c1;
 p_category_id := x_category_id;
 p_application_id := NVL(x_application_id,-1);

 IF (x_application_id = 300) THEN
	get_usage_id (x_category_id, p_usage_id);
  END IF;

  RETURN;

 EXCEPTION
  WHEN OTHERS THEN
			IF (c1%ISOPEN) THEN
				CLOSE c1;
			END IF;

	                 p_application_id := -1;
			 RETURN;
END;

PROCEDURE get_note_type_code (
 p_usage_type    VARCHAR2,
 p_note_type_code  OUT VARCHAR2, -- 'SN' | 'OT'
 p_override_flag   OUT VARCHAR2  -- 'Y'  | 'N'
) IS
BEGIN
  /*
  **    document_usage_type ==> Note_Type_Code Override_Allowed_flag
  **    -------------------     -------------- ---------------------
  **    Template (T)            Standard(SN)     Y
  **    Standard (S)            Standard(SN)     N
  **    One-Time (O)            One-Time(OT)     Y
  */

  If (p_usage_type = 'T') Then
    p_note_type_code := 'SN';
    p_override_flag := 'Y';
  ElsIf (p_usage_type = 'S') Then
    p_note_type_code := 'SN';
    p_override_flag := 'N';
  ElsIf (p_usage_type = 'O') Then
    p_note_type_code := 'OT';
    p_override_flag := 'Y';
  End If;

END;

PROCEDURE insert_document (
    p_document_id        NUMBER,
    p_app_source_version VARCHAR2
) IS

  x_category_id             NUMBER;
  x_media_id                NUMBER;
  x_note_id                 NUMBER;
  x_last_update_date        DATE;
  x_last_updated_by         NUMBER;
  x_last_update_login       NUMBER;
  x_creation_date           DATE;
  x_created_by              NUMBER;
  x_name                    VARCHAR2(30);
  x_note_type_code          VARCHAR2(30);
  x_usage_id                NUMBER;
  x_override_flag           VARCHAR2(1);
  x_note                    VARCHAR2(32760);
  x_start_date_active       DATE;
  x_end_date_active         DATE;
  x_context                 VARCHAR2(30);
  x_attribute1              VARCHAR2(150);
  x_attribute2              VARCHAR2(150);
  x_attribute3              VARCHAR2(150);
  x_attribute4              VARCHAR2(150);
  x_attribute5              VARCHAR2(150);
  x_attribute6              VARCHAR2(150);
  x_attribute7              VARCHAR2(150);
  x_attribute8              VARCHAR2(150);
  x_attribute9              VARCHAR2(150);
  x_attribute10             VARCHAR2(150);
  x_attribute11             VARCHAR2(150);
  x_attribute12             VARCHAR2(150);
  x_attribute13             VARCHAR2(150);
  x_attribute14             VARCHAR2(150);
  x_attribute15             VARCHAR2(150);
  x_datatype_id             NUMBER;
  x_document_usage_type     VARCHAR2(1);


BEGIN

  SELECT
    note_id,              last_update_date,
    last_updated_by,      last_update_login,
    creation_date,        created_by,
    name,                 usage_id,
    start_date_active,    end_date_active,
    context,              attribute1,
    attribute2,           attribute3,
    attribute4,           attribute5,
    attribute6,           attribute7,
    attribute8,           attribute9,
    attribute10,          attribute11,
    attribute12,          attribute13,
    attribute14,          attribute15
  INTO
    x_note_id,            x_last_update_date,
    x_last_updated_by,    x_last_update_login,
    x_creation_date,      x_created_by,
    x_name,               x_usage_id,
    x_start_date_active,  x_end_date_active,
    x_context,            x_attribute1,
    x_attribute2,         x_attribute3,
    x_attribute4,         x_attribute5,
    x_attribute6,         x_attribute7,
    x_attribute8,         x_attribute9,
    x_attribute10,        x_attribute11,
    x_attribute12,        x_attribute13,
    x_attribute14,        x_attribute15
  FROM so_notes
  WHERE document_id     = p_document_id;

  x_document_usage_type := get_document_usage_type (x_note_id);

  BEGIN
    SELECT note
    INTO   x_note
    FROM   so_notes
    WHERE  document_id  = p_document_id;

    x_datatype_id := 1; -- default is short text;

    IF (x_note IS NULL) THEN
      x_note := so_att.get_note_error('OE_NOT_UPDATE_NOTE');
    ELSIF length (x_note) >= 2000 THEN
      x_datatype_id := 2; -- long text
    END IF;

    EXCEPTION
      WHEN VALUE_ERROR THEN -- long exceeds 32760
        x_note := so_att.get_note_error('OE_NOT_NOTE_TOO_LONG',p_document_id);
        x_datatype_id := 2;
      WHEN OTHERS THEN
        RAISE;
  END;


  get_category_id (x_usage_id, x_category_id);

  INSERT INTO fnd_documents (
    document_id,       creation_date,
    created_by,        last_update_date,
    last_updated_by,   last_update_login,
    datatype_id,       category_id,
    security_type,     security_id,
    publish_flag,      storage_type,
    usage_type,        app_source_version,
    start_date_active, end_date_active )
  SELECT
    p_document_id,        x_creation_date,
    x_created_by,         sysdate,
    1,                    1,
    x_datatype_id,        x_category_id,
    4,                    NULL,
    'N',                  NULL,
    x_document_usage_type, p_app_source_version,
    x_start_date_active,  x_end_date_active
  FROM dual;

  IF x_datatype_id = 1 THEN
    SELECT fnd_documents_short_text_s.nextval
    INTO   x_media_id
    FROM   dual;
  ELSE
    SELECT fnd_documents_long_text_s.nextval
    INTO   x_media_id
    FROM   dual;
  END IF;

  INSERT INTO fnd_documents_tl (
    document_id,        creation_date,
    created_by,         last_update_date,
    last_updated_by,    last_update_login,
    language,           description,
    file_name,          media_id,
    doc_attribute_category, doc_attribute1,
    doc_attribute2,         doc_attribute3,
    doc_attribute4,         doc_attribute5,
    doc_attribute6,         doc_attribute7,
    doc_attribute8,         doc_attribute9,
    doc_attribute10,        doc_attribute11,
    doc_attribute12,        doc_attribute13,
    doc_attribute14,        doc_attribute15,
    app_source_version,	source_lang )
  SELECT
    p_document_id,      x_creation_date,
    x_created_by,       sysdate,
    1,                  1,
    fnd_global.current_language, x_name,
    NULL,               x_media_id,
    x_context,          x_attribute1,
    x_attribute2,       x_attribute3,
    x_attribute4,       x_attribute5,
    x_attribute6,       x_attribute7,
    x_attribute8,       x_attribute9,
    x_attribute10,      x_attribute11,
    x_attribute12,      x_attribute13,
    x_attribute14,      x_attribute15,
    p_app_source_version, fnd_global.current_language
  FROM dual;

  IF x_datatype_id = 1 THEN
    INSERT INTO fnd_documents_short_text (
      media_id, short_text, app_source_version )
    SELECT
      x_media_id, x_note, p_app_source_version
    FROM dual;
  ELSE
    INSERT INTO fnd_documents_long_text (
      media_id, long_text, app_source_version )
    VALUES (
      x_media_id, x_note, p_app_source_version);
  END IF;

END;


PROCEDURE update_document (
  p_document_id        NUMBER,
  p_app_source_version VARCHAR2
) IS

  x_category_id             NUMBER;
  x_media_id                NUMBER;
  x_note_id                 NUMBER;
  x_last_update_date        DATE;
  x_last_updated_by         NUMBER;
  x_last_update_login       NUMBER;
  x_creation_date           DATE;
  x_created_by              NUMBER;
  x_name                    VARCHAR2(30);
  x_note_type_code          VARCHAR2(30);
  x_usage_id                NUMBER;
  x_override_flag           VARCHAR2(1);
  x_note                    VARCHAR2(32760);
  x_start_date_active       DATE;
  x_end_date_active         DATE;
  x_context                 VARCHAR2(30);
  x_attribute1              VARCHAR2(150);
  x_attribute2              VARCHAR2(150);
  x_attribute3              VARCHAR2(150);
  x_attribute4              VARCHAR2(150);
  x_attribute5              VARCHAR2(150);
  x_attribute6              VARCHAR2(150);
  x_attribute7              VARCHAR2(150);
  x_attribute8              VARCHAR2(150);
  x_attribute9              VARCHAR2(150);
  x_attribute10             VARCHAR2(150);
  x_attribute11             VARCHAR2(150);
  x_attribute12             VARCHAR2(150);
  x_attribute13             VARCHAR2(150);
  x_attribute14             VARCHAR2(150);
  x_attribute15             VARCHAR2(150);
  x_datatype_id             NUMBER;
  x_document_usage_type     VARCHAR2(1);

BEGIN

  SELECT
    note_id,              last_update_date,
    last_updated_by,      last_update_login,
    creation_date,        created_by,
    name,                 usage_id,     note_type_code,
    start_date_active,    end_date_active,
    context,              attribute1,
    attribute2,           attribute3,
    attribute4,           attribute5,
    attribute6,           attribute7,
    attribute8,           attribute9,
    attribute10,          attribute11,
    attribute12,          attribute13,
    attribute14,          attribute15,
    override_allowed_flag
  INTO
    x_note_id,            x_last_update_date,
    x_last_updated_by,    x_last_update_login,
    x_creation_date,      x_created_by,
    x_name,               x_usage_id,   x_note_type_code,
    x_start_date_active,  x_end_date_active,
    x_context,            x_attribute1,
    x_attribute2,         x_attribute3,
    x_attribute4,         x_attribute5,
    x_attribute6,         x_attribute7,
    x_attribute8,         x_attribute9,
    x_attribute10,        x_attribute11,
    x_attribute12,        x_attribute13,
    x_attribute14,        x_attribute15,
    x_override_flag
  FROM so_notes
  WHERE
    document_id         = p_document_id;

  x_document_usage_type := get_document_usage_type (x_note_id);

  BEGIN
    SELECT note
    INTO   x_note
    FROM   so_notes
    WHERE  document_id  = p_document_id;

    EXCEPTION
      WHEN VALUE_ERROR THEN -- long exceeds 32760
        x_note := so_att.get_note_error('OE_NOT_NOTE_TOO_LONG',p_document_id);
      WHEN OTHERS THEN
        RAISE;
  END;

  get_category_id(x_usage_id, x_category_id);

  UPDATE fnd_documents
  SET    app_source_version = 'SO_R10',
         category_id = x_category_id,
         usage_type = DECODE(x_note_type_code,'OT','O',
				DECODE(x_override_flag,'Y','T',
					'S')),
	 start_date_active = x_start_date_active,
         end_date_active = x_end_date_active
  WHERE  document_id = p_document_id;

  UPDATE fnd_documents_tl
  SET app_source_version = 'SO_R10',
      description = x_name,
      doc_attribute_category = x_context,
      doc_attribute1 = x_attribute1,
      doc_attribute2 = x_attribute2,
      doc_attribute3 = x_attribute3,
      doc_attribute4 = x_attribute4,
      doc_attribute5 = x_attribute5,
      doc_attribute6 = x_attribute6,
      doc_attribute7 = x_attribute7,
      doc_attribute8 = x_attribute8,
      doc_attribute9 = x_attribute9,
      doc_attribute10 = x_attribute10,
      doc_attribute11 = x_attribute11,
      doc_attribute12 = x_attribute12,
      doc_attribute13 = x_attribute13,
      doc_attribute14 = x_attribute14,
      doc_attribute15 = x_attribute15
  WHERE document_id = p_document_id
  AND   language = fnd_global.current_language;

  get_media_id (p_document_id, x_media_id, x_datatype_id);

  IF x_datatype_id = 1 THEN
-- we could check if note >= 2000 even datatype_id=1, and set x_note to
-- 'note truncated'|| substr(x_note,1,1900). leave it this way for now.

    UPDATE fnd_documents_short_text
    SET    app_source_version = 'SO_R10',
           short_text = substr (x_note, 1, 1998)
    WHERE  media_id = x_media_id;
  ELSE
    UPDATE fnd_documents_long_text
    SET    app_source_version = 'SO_R10',
           long_text = x_note
    WHERE  media_id = x_media_id;
  END IF;

END;


PROCEDURE delete_document (
  p_document_id  NUMBER
) IS

  x_media_id      NUMBER;
  x_datatype_id   NUMBER;

BEGIN

  get_media_id (p_document_id, x_media_id, x_datatype_id);

  DELETE FROM fnd_documents
  WHERE document_id = p_document_id;

  DELETE FROM fnd_documents_tl
  WHERE document_id = p_document_id;

  IF x_datatype_id = 1 THEN
    DELETE FROM fnd_documents_short_text
    WHERE media_id = x_media_id;
  ELSE
    DELETE FROM fnd_documents_long_text
    WHERE media_id = x_media_id;
  END IF;

END;


PROCEDURE insert_attached_document (
  p_creation_date           DATE,
  p_created_by              NUMBER,
  p_note_id                 NUMBER,
  p_usage_id                NUMBER,
  p_automatically_added_flag VARCHAR2,
  p_header_id               NUMBER,
  p_line_id                 NUMBER,
  p_program_application_id  NUMBER,
  p_program_id              NUMBER,
  p_program_update_date     DATE,
  p_request_id              NUMBER,
  p_sequence_number         NUMBER,
  p_context                 VARCHAR2,
  p_attribute1              VARCHAR2,
  p_attribute2              VARCHAR2,
  p_attribute3              VARCHAR2,
  p_attribute4              VARCHAR2,
  p_attribute5              VARCHAR2,
  p_attribute6              VARCHAR2,
  p_attribute7              VARCHAR2,
  p_attribute8              VARCHAR2,
  p_attribute9              VARCHAR2,
  p_attribute10             VARCHAR2,
  p_attribute11             VARCHAR2,
  p_attribute12             VARCHAR2,
  p_attribute13             VARCHAR2,
  p_attribute14             VARCHAR2,
  p_attribute15             VARCHAR2,
  p_app_source_version      VARCHAR2,
  p_attached_document_id    IN OUT NUMBER
) IS

  x_document_id NUMBER;
  x_entity_name fnd_attached_documents.entity_name%TYPE;

BEGIN

  SELECT document_id
  INTO   x_document_id
  FROM   so_notes
  WHERE  note_id = p_note_id;

  x_entity_name := get_entity_name(p_header_id, p_line_id);

  SELECT fnd_attached_documents_s.nextval
  INTO   p_attached_document_id
  FROM   dual;

  INSERT INTO fnd_attached_documents (
    attached_document_id,     document_id,
    creation_date,            created_by,
    last_update_date,         last_updated_by,
    last_update_login,        seq_num,
    entity_name,              pk1_value,
    pk2_value,
    program_application_id,   program_id,
    program_update_date,      request_id,
    automatically_added_flag, attribute_category,
    attribute1,               attribute2,
    attribute3,               attribute4,
    attribute5,               attribute6,
    attribute7,               attribute8,
    attribute9,               attribute10,
    attribute11,              attribute12,
    attribute13,              attribute14,
    attribute15,              app_source_version )
  SELECT
    p_attached_document_id,   x_document_id,
    p_creation_date,          p_created_by,
    sysdate,                  1,
    1,                        p_sequence_number,
    x_entity_name,            to_char(p_header_id),
    to_char(p_line_id),
    p_program_application_id, p_program_id,
    p_program_update_date,    p_request_id,
    p_automatically_added_flag, p_context,
    p_attribute1,             p_attribute2,
    p_attribute3,             p_attribute4,
    p_attribute5,             p_attribute6,
    p_attribute7,             p_attribute8,
    p_attribute9,             p_attribute10,
    p_attribute11,            p_attribute12,
    p_attribute13,            p_attribute14,
    p_attribute15,            p_app_source_version
  FROM dual;

END;

PROCEDURE update_attached_document (
  p_attached_document_id    NUMBER,
  p_creation_date           DATE,
  p_created_by              NUMBER,
  p_note_id                 NUMBER,
  p_usage_id                NUMBER,
  p_automatically_added_flag VARCHAR2,
  p_header_id               NUMBER,
  p_line_id                 NUMBER,
  p_program_application_id  NUMBER,
  p_program_id              NUMBER,
  p_program_update_date     DATE,
  p_request_id              NUMBER,
  p_sequence_number         NUMBER,
  p_context                 VARCHAR2,
  p_attribute1              VARCHAR2,
  p_attribute2              VARCHAR2,
  p_attribute3              VARCHAR2,
  p_attribute4              VARCHAR2,
  p_attribute5              VARCHAR2,
  p_attribute6              VARCHAR2,
  p_attribute7              VARCHAR2,
  p_attribute8              VARCHAR2,
  p_attribute9              VARCHAR2,
  p_attribute10             VARCHAR2,
  p_attribute11             VARCHAR2,
  p_attribute12             VARCHAR2,
  p_attribute13             VARCHAR2,
  p_attribute14             VARCHAR2,
  p_attribute15             VARCHAR2,
  p_app_source_version      VARCHAR2
) IS

  x_document_id NUMBER;

BEGIN

  SELECT document_id
  INTO   x_document_id
  FROM   so_notes
  WHERE  note_id = p_note_id;

-- you can only update flex fields and sequence number.
  UPDATE fnd_attached_documents
  SET    last_update_date = SYSDATE,
         seq_num     = p_sequence_number,
         document_id = x_document_id,
         attribute_category = p_context,
         attribute1  = p_attribute1,
         attribute2  = p_attribute2,
         attribute3  = p_attribute3,
         attribute4  = p_attribute4,
         attribute5  = p_attribute5,
         attribute6  = p_attribute6,
         attribute7  = p_attribute7,
         attribute8  = p_attribute8,
         attribute9  = p_attribute9,
         attribute10 = p_attribute10,
         attribute11 = p_attribute11,
         attribute12 = p_attribute12,
         attribute13 = p_attribute13,
         attribute14 = p_attribute14,
         attribute15 = p_attribute15,
         app_source_version = 'SO_R10'
  WHERE  attached_document_id = p_attached_document_id;

END;

PROCEDURE delete_attached_document (
  p_attached_document_id         NUMBER
) IS

 BEGIN

  DELETE FROM fnd_attached_documents
  WHERE attached_document_id = p_attached_document_id;

END;


PROCEDURE insert_category (
  p_creation_date           DATE,
  p_created_by              NUMBER,
  p_last_update_date        DATE,
  p_last_updated_by         NUMBER,
  p_last_update_login       NUMBER,
  p_name                    VARCHAR2,
  p_description             VARCHAR2,
  p_start_date_active       DATE,
  p_end_date_active         DATE,
  p_context                 VARCHAR2,
  p_attribute1              VARCHAR2,
  p_attribute2              VARCHAR2,
  p_attribute3              VARCHAR2,
  p_attribute4              VARCHAR2,
  p_attribute5              VARCHAR2,
  p_attribute6              VARCHAR2,
  p_attribute7              VARCHAR2,
  p_attribute8              VARCHAR2,
  p_attribute9              VARCHAR2,
  p_attribute10             VARCHAR2,
  p_attribute11             VARCHAR2,
  p_attribute12             VARCHAR2,
  p_attribute13             VARCHAR2,
  p_attribute14             VARCHAR2,
  p_attribute15             VARCHAR2,
  p_app_source_version      VARCHAR2,
  p_category_id             IN OUT NUMBER
) IS
 attach_function_id NUMBER;
BEGIN

  SELECT fnd_document_categories_s.nextval
  INTO   p_category_id
  FROM   dual;

  INSERT INTO fnd_document_categories (
    category_id,
    application_id,           creation_date,
    created_by,               last_update_date,
    last_updated_by,          last_update_login,
    name,
    start_date_active,        end_date_active,
    default_datatype_id,
    attribute_category,
    attribute1,               attribute2,
    attribute3,               attribute4,
    attribute5,               attribute6,
    attribute7,               attribute8,
    attribute9,               attribute10,
    attribute11,              attribute12,
    attribute13,              attribute14,
    attribute15)
  SELECT
    p_category_id,
    300,                      p_creation_date,
    p_created_by,             p_last_update_date,
    p_last_updated_by,        p_last_update_login,
    p_name,
    p_start_date_active,      p_end_date_active,
    1,
    p_context,
    p_attribute1,             p_attribute2,
    p_attribute3,             p_attribute4,
    p_attribute5,             p_attribute6,
    p_attribute7,             p_attribute8,
    p_attribute9,             p_attribute10,
    p_attribute11,            p_attribute12,
    p_attribute13,            p_attribute14,
    p_attribute15
  FROM dual;

  INSERT INTO fnd_document_categories_tl (
    category_id,              language,
    name,                     user_name,
    creation_date,
    created_by,               last_update_date,
    last_updated_by,          last_update_login,
    app_source_version,       source_lang )
  SELECT
    p_category_id,            fnd_global.current_language,
    p_name,                   p_name,
    p_creation_date,
    p_created_by,             p_last_update_date,
    p_last_updated_by,        p_last_update_login,
    p_app_source_version,     fnd_global.current_language
  FROM dual;

  -- lookup the attachment_function_id of the OEXOEMOE form
  SELECT attachment_function_id
    INTO attach_function_id
    FROM fnd_attachment_functions
   WHERE function_name = 'OEXOEMOE'
     AND function_type = 'O';

  --  create fnd_doc_category_usages record to link category
  --  to the OEXOEMOE form so documents with this category
  --  can be viewed in 10SC
  INSERT INTO fnd_doc_category_usages (
	doc_category_usage_id,
	category_id,
	attachment_function_id,	enabled_flag,
  	creation_date, created_by,
	last_update_date, last_updated_by, last_update_login)
	VALUES (
	fnd_doc_category_usages_s.nextval,
	p_category_id,
	attach_function_id, 'Y',
	SYSDATE, 1,
	SYSDATE, 1, 1);

END;

PROCEDURE update_category (
  p_category_id             NUMBER,
  p_creation_date           DATE,
  p_created_by              NUMBER,
  p_last_update_date        DATE,
  p_last_updated_by         NUMBER,
  p_last_update_login       NUMBER,
  p_name                    VARCHAR2,
  p_description             VARCHAR2,
  p_start_date_active       DATE,
  p_end_date_active         DATE,
  p_context                 VARCHAR2,
  p_attribute1              VARCHAR2,
  p_attribute2              VARCHAR2,
  p_attribute3              VARCHAR2,
  p_attribute4              VARCHAR2,
  p_attribute5              VARCHAR2,
  p_attribute6              VARCHAR2,
  p_attribute7              VARCHAR2,
  p_attribute8              VARCHAR2,
  p_attribute9              VARCHAR2,
  p_attribute10             VARCHAR2,
  p_attribute11             VARCHAR2,
  p_attribute12             VARCHAR2,
  p_attribute13             VARCHAR2,
  p_attribute14             VARCHAR2,
  p_attribute15             VARCHAR2,
  p_app_source_version      VARCHAR2
) IS

BEGIN

  UPDATE fnd_document_categories
  SET    last_update_date = p_last_update_date,
         last_updated_by  = p_last_updated_by,
         last_update_login = p_last_update_login,
         name             = p_name,
         start_date_active = p_start_date_active,
         end_date_active = p_end_date_active,
         attribute_category = p_context,
         attribute1  = p_attribute1,
         attribute2  = p_attribute2,
         attribute3  = p_attribute3,
         attribute4  = p_attribute4,
         attribute5  = p_attribute5,
         attribute6  = p_attribute6,
         attribute7  = p_attribute7,
         attribute8  = p_attribute8,
         attribute9  = p_attribute9,
         attribute10 = p_attribute10,
         attribute11 = p_attribute11,
         attribute12 = p_attribute12,
         attribute13 = p_attribute13,
         attribute14 = p_attribute14,
         attribute15 = p_attribute15
  WHERE  category_id = p_category_id;

  UPDATE fnd_document_categories_tl
  SET    last_update_date = p_last_update_date,
         last_updated_by  = p_last_updated_by,
         last_update_login = p_last_update_login,
         name             = p_name,
         user_name        = p_name,
         app_source_version = 'SO_R10'
  WHERE  category_id = p_category_id;

END;

PROCEDURE insert_usage (
  p_creation_date           DATE,
  p_created_by              NUMBER,
  p_last_update_date        DATE,
  p_last_updated_by         NUMBER,
  p_last_update_login       NUMBER,
  p_name                    VARCHAR2,
  p_user_name               VARCHAR2,
  p_category_id             NUMBER,
  p_app_source_version      VARCHAR2,
  p_usage_id                IN OUT NUMBER
) IS
 CURSOR c IS
   SELECT 1
     FROM so_note_usages
    WHERE name = substr(p_user_name,1,15);
 dummy number;
BEGIN

  --  so_note_usages.name is enforced to be unique
  --  by R10
  OPEN C;
  FETCH C INTO dummy;
  IF (C%FOUND) THEN
	CLOSE C;
  	RAISE DUP_VAL_ON_INDEX;
	RETURN;
  END IF;

  CLOSE C;
  SELECT so_note_usages_s.nextval
  INTO   p_usage_id
  FROM   dual;



  INSERT INTO so_note_usages (
    usage_id,                 creation_date,
    created_by,               last_update_date,
    last_updated_by,          last_update_login,
    name,                     description,
    start_date_active,        end_date_active,
    context,
    attribute1,               attribute2,
    attribute3,               attribute4,
    attribute5,               attribute6,
    attribute7,               attribute8,
    attribute9,               attribute10,
    attribute11,              attribute12,
    attribute13,              attribute14,
    attribute15,
    category_id,              app_source_version )
  SELECT
    p_usage_id,               p_creation_date,
    p_created_by,             p_last_update_date,
    p_last_updated_by,        p_last_update_login,
    SUBSTR(p_user_name,1,15), SUBSTR(p_user_name,1,80),
    fdc.start_date_active,    fdc.end_date_active,
    fdc.attribute_category,
    fdc.attribute1,           fdc.attribute2,
    fdc.attribute3,           fdc.attribute4,
    fdc.attribute5,           fdc.attribute6,
    fdc.attribute7,           fdc.attribute8,
    fdc.attribute9,           fdc.attribute10,
    fdc.attribute11,          fdc.attribute12,
    fdc.attribute13,          fdc.attribute14,
    fdc.attribute15,
    p_category_id,            p_app_source_version
  FROM fnd_document_categories fdc
  WHERE category_id = p_category_id;


END;

PROCEDURE update_usage (
  p_category_id             NUMBER,
  p_creation_date           DATE,
  p_created_by              NUMBER,
  p_last_update_date        DATE,
  p_last_updated_by         NUMBER,
  p_last_update_login       NUMBER,
  p_name                    VARCHAR2,
  p_user_name               VARCHAR2,
  p_app_source_version      VARCHAR2
) IS
  x_start_date_active       DATE;
  x_end_date_active         DATE;
  x_attribute_category      VARCHAR2(30);
  x_attribute1              VARCHAR2(150);
  x_attribute2              VARCHAR2(150);
  x_attribute3              VARCHAR2(150);
  x_attribute4              VARCHAR2(150);
  x_attribute5              VARCHAR2(150);
  x_attribute6              VARCHAR2(150);
  x_attribute7              VARCHAR2(150);
  x_attribute8              VARCHAR2(150);
  x_attribute9              VARCHAR2(150);
  x_attribute10             VARCHAR2(150);
  x_attribute11             VARCHAR2(150);
  x_attribute12             VARCHAR2(150);
  x_attribute13             VARCHAR2(150);
  x_attribute14             VARCHAR2(150);
  x_attribute15             VARCHAR2(150);
  CURSOR C IS
    SELECT 1
      FROM so_note_usages
     WHERE name = substr(p_user_name,1,15)
       AND category_id <> p_category_id;
  dummy number;
BEGIN

  --  check for violation of the application-enforced unique
  --  key in R10
  OPEN c;
  FETCH c INTO dummy;
  IF (c%FOUND) THEN
	CLOSE c;
	RAISE DUP_VAL_ON_INDEX;
	RETURN;
  END IF;

  CLOSE c;

  SELECT     start_date_active,        end_date_active,
             attribute_category,
             attribute1,               attribute2,
             attribute3,               attribute4,
             attribute5,               attribute6,
             attribute7,               attribute8,
             attribute9,               attribute10,
             attribute11,              attribute12,
             attribute13,              attribute14,
             attribute15
  INTO
             x_start_date_active,      x_end_date_active,
             x_attribute_category,
             x_attribute1,             x_attribute2,
             x_attribute3,             x_attribute4,
             x_attribute5,             x_attribute6,
             x_attribute7,             x_attribute8,
             x_attribute9,             x_attribute10,
             x_attribute11,            x_attribute12,
             x_attribute13,            x_attribute14,
             x_attribute15
  FROM fnd_document_categories
  WHERE category_id = p_category_id;

  UPDATE so_note_usages
  SET    last_update_date = p_last_update_date,
         last_updated_by  = p_last_updated_by,
         last_update_login = p_last_update_login,
         name             = SUBSTR(p_user_name,1,15),
         start_date_active = x_start_date_active,
         end_date_active = x_end_date_active,
         context = x_attribute_category,
         attribute1  = x_attribute1,
         attribute2  = x_attribute2,
         attribute3  = x_attribute3,
         attribute4  = x_attribute4,
         attribute5  = x_attribute5,
         attribute6  = x_attribute6,
         attribute7  = x_attribute7,
         attribute8  = x_attribute8,
         attribute9  = x_attribute9,
         attribute10 = x_attribute10,
         attribute11 = x_attribute11,
         attribute12 = x_attribute12,
         attribute13 = x_attribute13,
         attribute14 = x_attribute14,
         attribute15 = x_attribute15,
         app_source_version = 'SO_R10'
  WHERE  category_id = p_category_id;

END;

END;

/
