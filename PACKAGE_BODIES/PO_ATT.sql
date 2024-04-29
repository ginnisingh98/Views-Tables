--------------------------------------------------------
--  DDL for Package Body PO_ATT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ATT" AS
/* $Header: poatt04b.pls 120.1 2006/02/23 04:01:05 aagupta noship $ */
PROCEDURE mark_record (
  p_src_id      NUMBER,      -- media_id | document_id
  p_short_long  VARCHAR2, -- 'S' | 'L'
  p_source      VARCHAR2,-- 'DOCUMENT' | 'NOTE'
  p_operation   VARCHAR2,-- 'INSERT' | 'UPDATE'
  p_version     VARCHAR2 -- 'PO_10SC' | 'PO_R10'
) IS

BEGIN

  INSERT INTO po_att_tmp_records (
    src_id,
    short_long,
    source,
    operation,
    version
  ) VALUES (
    p_src_id,
    p_short_long,
    p_source,
    p_operation,
    p_version
  );

END;

PROCEDURE clear_mark (
  p_short_long  VARCHAR2, -- 'S' | 'L'
  p_source      VARCHAR2,-- 'DOCUMENT' | 'NOTE'
  p_operation   VARCHAR2,-- 'INSERT' | 'UPDATE'
  p_version     VARCHAR2 -- 'PO_10SC' | 'PO_R10'
) IS

BEGIN

  DELETE FROM po_att_tmp_records;
/* all tmp records should be deleted */

END;


FUNCTION get_table_name (
  p_entity_name VARCHAR2
) RETURN VARCHAR2 IS
BEGIN

  IF    p_entity_name = 'REQ_HEADERS' THEN return 'PO_REQUISITION_HEADERS';
  ELSIF p_entity_name = 'REQ_LINES' THEN return 'PO_REQUISITION_LINES';
  ELSIF p_entity_name = 'RCV_LINES' THEN return 'RCV_SHIPMENT_LINES';
  ELSIF p_entity_name = 'RCV_TRANSACTIONS' THEN return 'RCV_TRANSACTIONS';
  ELSIF p_entity_name = 'RCV_TRANSACTIONS_INTERFACE' THEN return 'RCV_TRANSACTIONS_INTERFACE';
  ELSIF p_entity_name = 'PO_HEADERS' THEN return 'PO_HEADERS';
  ELSIF p_entity_name = 'PO_LINES' THEN return 'PO_LINES';
  ELSIF p_entity_name = 'PO_RELEASES' THEN return 'PO_RELEASES';
  ELSIF p_entity_name = 'PO_SHIPMENTS' THEN return 'PO_LINE_LOCATIONS';
  ELSIF p_entity_name = 'RCV_HEADERS' THEN return 'RCV_SHIPMENT_HEADERS';
  ELSIF p_entity_name = 'MTL_SYSTEM_ITEMS' THEN return 'MTL_SYSTEM_ITEMS';
  ELSIF p_entity_name = 'PO_VENDORS' THEN return 'PO_VENDORS';
  ELSE return 'NOT_PO_TABLE';
  END IF;

END;

FUNCTION get_table_name (
  p_document_id NUMBER
) RETURN VARCHAR2 IS
  x_table_name VARCHAR2(30);
BEGIN

-- the following select may return more than one record. use this api
-- only you are sure there is only one return. for instance, when
-- insert a new attachment.
  BEGIN
    SELECT decode ( entity_name,
              'REQ_HEADERS',      'PO_REQUISITION_HEADERS',
              'REQ_LINES',        'PO_REQUISITION_LINES',
              'RCV_LINES',        'RCV_SHIPMENT_LINES',
              'RCV_TRANSACTIONS', 'RCV_TRANSACTIONS',
              'RCV_TRANSACTIONS_INTERFACE', 'RCV_TRANSACTIONS_INTERFACE',
              'PO_HEADERS',       'PO_HEADERS',
              'PO_LINES',         'PO_LINES',
              'PO_RELEASES',      'PO_RELEASES',
              'PO_SHIPMENTS',     'PO_LINE_LOCATIONS',
              'RCV_HEADERS',      'RCV_SHIPMENT_HEADERS',
              'MTL_SYSTEM_ITEMS', 'MTL_SYSTEM_ITEMS',
              'PO_VENDORS',       'PO_VENDORS',
              'NOT_PO_TABLE' )
    INTO   x_table_name
    FROM   fnd_attached_documents
    WHERE  document_id = p_document_id
    AND    rownum < 2; -- make sure zero or one record returned

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_table_name := 'NOT_ATTACHED';
  END;

  RETURN x_table_name;
END;

FUNCTION get_column_name (
  p_entity_name VARCHAR2
) RETURN VARCHAR2 IS
  x_column_name VARCHAR2(30);
BEGIN

-- the following select may return more than one record. use this api
-- only you are sure there is only one return. for instance, when
-- insert a new attachment.
  IF    p_entity_name = 'REQ_HEADERS' THEN return 'REQUISITION_HEADER_ID';
  ELSIF p_entity_name = 'REQ_LINES' THEN return 'REQUISITION_LINE_ID';
  ELSIF p_entity_name = 'RCV_LINES' THEN return 'SHIPMENT_LINE_ID';
  ELSIF p_entity_name = 'RCV_TRANSACTIONS' THEN return 'TRANSACTION_ID';
  ELSIF p_entity_name = 'RCV_TRANSACTIONS_INTERFACE' THEN RETURN 'INTERFACE_TRANSACTION_ID';
  ELSIF p_entity_name = 'PO_HEADERS' THEN RETURN 'PO_HEADER_ID';
  ELSIF p_entity_name = 'PO_LINES' THEN RETURN 'PO_LINE_ID';
  ELSIF p_entity_name = 'PO_RELEASES' THEN RETURN 'PO_RELEASE_ID';
  ELSIF p_entity_name = 'PO_SHIPMENTS' THEN RETURN 'LINE_LOCATION_ID';
  ELSIF p_entity_name = 'RCV_HEADERS' THEN RETURN 'SHIPMENT_HEADER_ID';
  ELSIF p_entity_name = 'MTL_SYSTEM_ITEMS' THEN RETURN 'INVENTORY_ITEM_ID';
  ELSIF p_entity_name = 'PO_VENDORS' THEN RETURN 'VENDOR_ID';
  ELSE RETURN 'NOT_PO_COLUMN';
  END IF;

END;


FUNCTION get_column_name (
  p_document_id NUMBER
) RETURN VARCHAR2 IS
  x_column_name VARCHAR2(30);
BEGIN

  BEGIN
    SELECT decode ( entity_name,
              'REQ_HEADERS',      'REQUISITION_HEADER_ID',
              'REQ_LINES',        'REQUISITION_LINE_ID',
              'RCV_LINES',        'SHIPMENT_LINE_ID',
              'RCV_TRANSACTIONS', 'TRANSACTION_ID',
              'RCV_TRANSACTIONS_INTERFACE', 'INTERFACE_TRANSACTION_ID',
              'PO_HEADERS',       'PO_HEADER_ID',
              'PO_LINES',         'PO_LINE_ID',
              'PO_RELEASES',      'PO_RELEASE_ID',
              'PO_SHIPMENTS',     'LINE_LOCATION_ID',
              'RCV_HEADERS',      'SHIPMENT_HEADER_ID',
              'MTL_SYSTEM_ITEMS', 'INVENTORY_ITEM_ID',
              'PO_VENDORS',       'VENDOR_ID',
              'NOT_PO_COLUMN' )
    INTO   x_column_name
    FROM   fnd_attached_documents
    WHERE  document_id = p_document_id
    AND    rownum < 2;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_column_name := 'NOT_ATTACHED';
  END;

  RETURN x_column_name;
END;


FUNCTION get_entity_name (
  p_table_name  VARCHAR2
) RETURN VARCHAR2 IS
  x_entity_name VARCHAR2(40);
BEGIN

  IF    p_table_name='PO_HEADERS' THEN RETURN 'PO_HEADERS';
  ELSIF p_table_name='PO_LINES' THEN RETURN 'PO_LINES';
  ELSIF p_table_name='PO_LINE_LOCATIONS' THEN RETURN 'PO_SHIPMENTS';
  ELSIF p_table_name='PO_RELEASES' THEN RETURN 'PO_RELEASES';
  ELSIF p_table_name='PO_REQUISITION_HEADERS' THEN RETURN 'REQ_HEADERS';
  ELSIF p_table_name='PO_REQUISITION_LINES' THEN RETURN 'REQ_LINES';
  ELSIF p_table_name='RCV_SHIPMENT_HEADERS' THEN RETURN 'RCV_HEADERS';
  ELSIF p_table_name='RCV_SHIPMENT_LINES' THEN RETURN 'RCV_LINES';
  ELSIF p_table_name='RCV_TRANSACTIONS' THEN RETURN 'RCV_TRANSACTIONS';
  ELSIF p_table_name='RCV_TRANSACTIONS_INTERFACE' THEN RETURN 'RCV_TRANSACTIONS_INTERFACE';
  ELSIF p_table_name='MTL_SYSTEM_ITEMS' THEN RETURN 'MTL_SYSTEM_ITEMS';
  ELSIF p_table_name = 'PO_VENDORS' THEN return 'PO_VENDORS';
  ELSE RETURN 'NOT_PO_ENTITY';
  END IF;

END;


PROCEDURE get_category_id (
  p_usage_id    NUMBER,
  p_category_id OUT NOCOPY NUMBER
) IS
BEGIN
        SELECT fdc.category_id
        INTO   p_category_id
        FROM   fnd_document_categories fdc
        WHERE  upper(fdc.name) = decode(p_usage_id,  2,  'VENDOR'           ,
                                                     3,  'BUYER'            ,
                                                     4,  'RECEIVER'         ,
                                                     5,  'APPROVER'         ,
                                                     6,  'REQ INTERNAL'     ,
                                                     7,  'PO INTERNAL'      ,
                                                     8,  'RFQ INTERNAL'     ,
                                                     9,  'QUOTE INTERNAL'   ,
                                                     10, 'ITEM INTERNAL'    ,
                                                     11, 'RCV INTERNAL'     ,
                                                     12, 'INVOICE INTERNAL' ,
                                                     13, 'PAYABLES');

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    p_category_id := -1;
END;


PROCEDURE get_usage_id (
  p_category_id NUMBER,
  p_usage_id    OUT NOCOPY NUMBER
) IS

usg_name  VARCHAR2(30);

BEGIN

  SELECT decode(upper(fdc.name),'VENDOR'           ,2,
                                'BUYER'            ,3,
                                'RECEIVER'         ,4,
                                'APPROVER'         ,5,
                                'REQ INTERNAL'     ,6,
                                'PO INTERNAL'      ,7,
                                'RFQ INTERNAL'     ,8,
                                'QUOTE INTERNAL'   ,9,
                                'ITEM INTERNAL'    ,10,
                                'RCV INTERNAL'     ,11,
                                'INVOICE INTERNAL' ,12,
                                'PAYABLES'         ,13)

  INTO   p_usage_id
  FROM   fnd_document_categories fdc
  WHERE  fdc.category_id = p_category_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      p_usage_id := -1;
END;


PROCEDURE get_media_id (
  p_document_id   NUMBER,
  p_media_id      OUT NOCOPY NUMBER,
  p_datatype_id   OUT NOCOPY NUMBER
) IS
BEGIN

  SELECT fd.datatype_id, fd.media_id
  INTO   p_datatype_id, p_media_id
  FROM   fnd_documents_tl fdt,
         fnd_documents fd
  WHERE  fdt.language = userenv('LANG')
  AND    fdt.document_id = fd.document_id
  AND    fd.document_id = p_document_id;

END;


PROCEDURE get_document_id (
  p_media_id      NUMBER,
  p_datatype_id   VARCHAR2,
  p_document_id   OUT NOCOPY NUMBER
) IS
BEGIN

  SELECT fd.document_id
  INTO   p_document_id
  FROM   fnd_documents_tl fdt,
         fnd_documents fd
  WHERE  fd.media_id = p_media_id
  AND    fdt.document_id = fd.document_id
  AND    fd.datatype_id = decode (p_datatype_id, 'S', 1, 2) --short/long
  AND    rownum = 1; -- make sure only one record returns

END;


PROCEDURE get_note_info (
  p_media_id      NUMBER,
  p_short_long    VARCHAR2,
  p_document_id   OUT NOCOPY NUMBER,
  p_category_id   OUT NOCOPY NUMBER,
  p_usage_id      OUT NOCOPY NUMBER,
  p_note_type     OUT NOCOPY VARCHAR2 -- 'O' | 'S'
) IS

  x_num  NUMBER;
  x_num2 NUMBER;

BEGIN

  get_document_id (p_media_id, p_short_long, x_num);

  p_document_id := x_num;

  SELECT category_id, usage_type
  INTO   x_num2, p_note_type
  FROM   fnd_documents
  WHERE  document_id = x_num;

  p_category_id := x_num2;

  get_usage_id (x_num2, p_usage_id);
  /* p_usage_id = -1 if no corresponding po usages found */
END;


PROCEDURE insert_document (
    p_note_id            NUMBER,
    p_app_source_version VARCHAR2
) IS

  x_category_id             NUMBER;
  x_media_id                NUMBER;
  x_po_note_id              NUMBER;
  x_last_update_date        DATE;
  x_last_updated_by         NUMBER;
  x_last_update_login       NUMBER;
  x_creation_date           DATE;
  x_created_by              NUMBER;
  x_title                   VARCHAR2(80);
  x_usage_id                NUMBER;
  x_note_type               VARCHAR2(25);
  x_note                    VARCHAR2(32760);
  x_start_date_active       DATE;
  x_end_date_active         DATE;
  x_request_id              NUMBER;
  x_program_application_id  NUMBER;
  x_program_id              NUMBER;
  x_program_update_date     DATE;
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
  x_datatype_id             NUMBER;
  x_document_id             NUMBER;

BEGIN

  SELECT
    document_id,          last_update_date,
    last_updated_by,      last_update_login,
    nvl(creation_date,sysdate),
    nvl(created_by,1),
    title,                usage_id,
    note_type,
    start_date_active,    end_date_active,
    request_id,           program_application_id,
    program_id,           program_update_date,
    attribute_category,   attribute1,
    attribute2,           attribute3,
    attribute4,           attribute5,
    attribute6,           attribute7,
    attribute8,           attribute9,
    attribute10,          attribute11,
    attribute12,          attribute13,
    attribute14,          attribute15
  INTO
    x_document_id,        x_last_update_date,
    x_last_updated_by,    x_last_update_login,
    x_creation_date,      x_created_by,
    x_title,              x_usage_id,
    x_note_type,
    x_start_date_active,  x_end_date_active,
    x_request_id,         x_program_application_id,
    x_program_id,         x_program_update_date,
    x_attribute_category, x_attribute1,
    x_attribute2,         x_attribute3,
    x_attribute4,         x_attribute5,
    x_attribute6,         x_attribute7,
    x_attribute8,         x_attribute9,
    x_attribute10,        x_attribute11,
    x_attribute12,        x_attribute13,
    x_attribute14,        x_attribute15
  FROM po_notes
  WHERE po_note_id     = p_note_id;

  BEGIN
    SELECT note
    INTO   x_note
    FROM   po_notes
    WHERE  po_note_id  = p_note_id;

/* Mdas, 3/12/97, Bug#441412, make the default datatype as long text. */

--    x_datatype_id := 1; -- default is short text; Commented out by Mdas
      x_datatype_id := 2;

    IF x_note IS NULL THEN
      x_note := 'R10-POXNOEEN.inp-#FND STORELONG PO_NOTES NOTE PO_NOTE_ID' ||
                ' should update this text later';
    ELSIF length (x_note) >= 1900 THEN -- leave 10 safe chars
      x_datatype_id := 2; -- long text
    END IF;

    EXCEPTION
      WHEN VALUE_ERROR THEN -- long exceeds 32760
        x_note := 'This long text exceeds 32760. ' ||
                  'Refer to po_notes. ' ||
                  'note id = ' || to_char(p_note_id);
        x_datatype_id := 2;
      WHEN OTHERS THEN
        RAISE;
  END;

  get_category_id (x_usage_id, x_category_id);
  /* -1 if cannot find corresponding category */

 IF x_datatype_id = 1 THEN
    SELECT fnd_documents_short_text_s.nextval
    INTO   x_media_id
    FROM   sys.dual;
  ELSE
    SELECT fnd_documents_long_text_s.nextval
    INTO   x_media_id
    FROM   sys.dual;
  END IF;


  INSERT INTO fnd_documents (
    document_id,     creation_date,
    created_by,      last_update_date,
    last_updated_by, last_update_login,
    datatype_id,     category_id,
    security_type,   security_id,
    publish_flag,    storage_type,
    usage_type,      app_source_version,
    file_name,       media_id
 )
  VALUES (
    x_document_id,   x_creation_date,
    x_created_by,    sysdate,
    1,               1,
    x_datatype_id,   x_category_id,
    4,               null,
    'N',             1,
    x_note_type,     p_app_source_version,
    NULL,               x_media_id
  );

  INSERT INTO fnd_documents_tl (
    document_id,        creation_date,
    created_by,         last_update_date,
    last_updated_by,    last_update_login,
    language,           description,
    doc_attribute_category, doc_attribute1,
    doc_attribute2,     doc_attribute3,
    doc_attribute4,     doc_attribute5,
    doc_attribute6,     doc_attribute7,
    doc_attribute8,     doc_attribute9,
    doc_attribute10,    doc_attribute11,
    doc_attribute12,    doc_attribute13,
    doc_attribute14,    doc_attribute15,
    source_lang,         app_source_version )
  VALUES (
    x_document_id,      x_creation_date,
    x_created_by,       sysdate,
    1,                  1,
    userenv('LANG'), x_title,
    x_attribute_category, x_attribute1,
    x_attribute2,       x_attribute3,
    x_attribute4,       x_attribute5,
    x_attribute6,       x_attribute7,
    x_attribute8,       x_attribute9,
    x_attribute10,      x_attribute11,
    x_attribute12,      x_attribute13,
    x_attribute14,      x_attribute15,
    userenv('LANG'),    p_app_source_version
  );

  IF x_datatype_id = 1 THEN
    INSERT INTO fnd_documents_short_text ( media_id, short_text, app_source_version )
    VALUES ( x_media_id, x_note, p_app_source_version );
  ELSE
    INSERT INTO fnd_documents_long_text ( media_id, long_text, app_source_version )
    VALUES ( x_media_id, x_note, p_app_source_version );
  END IF;

END;


PROCEDURE update_document (
  p_note_id            NUMBER,
  p_app_source_version VARCHAR2
) IS

  x_category_id             NUMBER;
  x_media_id                NUMBER;
  x_datatype_id             NUMBER;
  x_po_note_id              NUMBER;
  x_last_update_date        DATE;
  x_last_updated_by         NUMBER;
  x_last_update_login       NUMBER;
  x_creation_date           DATE;
  x_created_by              NUMBER;
  x_title                   VARCHAR2(80);
  x_usage_id                NUMBER;
  x_note_type               VARCHAR2(25);
  x_note                    VARCHAR2(32760);
  x_start_date_active       DATE;
  x_end_date_active         DATE;
  x_request_id              NUMBER;
  x_program_application_id  NUMBER;
  x_program_id              NUMBER;
  x_program_update_date     DATE;
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
  x_document_id             NUMBER;

BEGIN

  SELECT
    document_id,          last_update_date,
    last_updated_by,      last_update_login,
    creation_date,        created_by,
    title,                usage_id,
    note_type,
    start_date_active,    end_date_active,
    request_id,           program_application_id,
    program_id,           program_update_date,
    attribute_category,   attribute1,
    attribute2,           attribute3,
    attribute4,           attribute5,
    attribute6,           attribute7,
    attribute8,           attribute9,
    attribute10,          attribute11,
    attribute12,          attribute13,
    attribute14,          attribute15
  INTO
    x_document_id,        x_last_update_date,
    x_last_updated_by,    x_last_update_login,
    x_creation_date,      x_created_by,
    x_title,              x_usage_id,
    x_note_type,
    x_start_date_active,  x_end_date_active,
    x_request_id,         x_program_application_id,
    x_program_id,         x_program_update_date,
    x_attribute_category, x_attribute1,
    x_attribute2,         x_attribute3,
    x_attribute4,         x_attribute5,
    x_attribute6,         x_attribute7,
    x_attribute8,         x_attribute9,
    x_attribute10,        x_attribute11,
    x_attribute12,        x_attribute13,
    x_attribute14,        x_attribute15
  FROM po_notes
  WHERE
    po_note_id         = p_note_id;

  BEGIN
    SELECT note
    INTO   x_note
    FROM   po_notes
    WHERE  po_note_id  = p_note_id;

    EXCEPTION
      WHEN VALUE_ERROR THEN -- long exceeds 32760
        x_note := 'This long text exceeds 32760. ' ||
                  'Refer to po_notes. ' ||
                  'note id = ' || to_char(p_note_id);
      WHEN OTHERS THEN
        RAISE;
  END;

  get_category_id (x_usage_id, x_category_id);
  /* -1 if cannot find corresponding category */

  UPDATE fnd_documents
  SET    app_source_version = 'PO_R10',
         category_id = x_category_id
  WHERE  document_id = x_document_id;

  UPDATE fnd_documents_tl
  SET app_source_version = 'PO_R10',
      description = x_title,
      doc_attribute_category = x_attribute_category,
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
  WHERE document_id = x_document_id
  AND   language = userenv('LANG');

  get_media_id (x_document_id, x_media_id, x_datatype_id);

  IF x_datatype_id = 1 THEN
-- we could check if note >= 2000 even datatype_id=1, and set x_note to
-- 'note truncated'|| substr(x_note,1,1900). leave it this way for now.
    UPDATE fnd_documents_short_text
    SET    app_source_version = 'PO_R10',
           short_text = substr (x_note, 1, 1998)
    WHERE  media_id = x_media_id;
  ELSE
    UPDATE fnd_documents_long_text
    SET    app_source_version = 'PO_R10',
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
  p_po_note_id              NUMBER,
  p_table_name              VARCHAR2,
  p_column_name             VARCHAR2,
  p_foreign_id              NUMBER,
  p_sequence_num            NUMBER,
  p_attribute_category      VARCHAR2,
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
  p_attached_doc_id     OUT NOCOPY NUMBER
) IS

  x_document_id NUMBER;
  x_entity_name fnd_attached_documents.entity_name%TYPE;

BEGIN

  SELECT document_id
  INTO   x_document_id
  FROM   po_notes
  WHERE  po_note_id = p_po_note_id;

  x_entity_name := get_entity_name ( p_table_name );

  SELECT fnd_attached_documents_s.nextval
  INTO   p_attached_doc_id
  FROM   sys.dual;

  INSERT INTO fnd_attached_documents (
    attached_document_id,     document_id,
    creation_date,            created_by,
    last_update_date,         last_updated_by,
    last_update_login,        seq_num,
    entity_name,              pk1_value,
    automatically_added_flag, attribute_category,
    attribute1,               attribute2,
    attribute3,               attribute4,
    attribute5,               attribute6,
    attribute7,               attribute8,
    attribute9,               attribute10,
    attribute11,              attribute12,
    attribute13,              attribute14,
    attribute15,              app_source_version )
  VALUES (
    p_attached_doc_id,        x_document_id,
    p_creation_date,          p_created_by,
    sysdate,                  1,
    1,                        p_sequence_num,
    x_entity_name,            p_foreign_id,
    'Y',                      p_attribute_category,
    p_attribute1,             p_attribute2,
    p_attribute3,             p_attribute4,
    p_attribute5,             p_attribute6,
    p_attribute7,             p_attribute8,
    p_attribute9,             p_attribute10,
    p_attribute11,            p_attribute12,
    p_attribute13,            p_attribute14,
    p_attribute15,            p_app_source_version
  );

END;

PROCEDURE insert_attached_document_item (
  p_creation_date           DATE,
  p_created_by              NUMBER,
  p_po_note_id              NUMBER,
  p_table_name              VARCHAR2,
  p_column_name             VARCHAR2,
  p_foreign_id              NUMBER,
  p_sequence_num            NUMBER,
  p_attribute_category      VARCHAR2,
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
  p_attached_doc_id     OUT NOCOPY NUMBER
) IS

  x_document_id NUMBER;
  x_entity_name fnd_attached_documents.entity_name%TYPE;
  x_organization_id NUMBER;

BEGIN

  SELECT document_id
  INTO   x_document_id
  FROM   po_notes
  WHERE  po_note_id = p_po_note_id;

  x_entity_name := get_entity_name ( p_table_name );

  SELECT fnd_attached_documents_s.nextval
  INTO   p_attached_doc_id
  FROM   sys.dual;

/* MDAS  In multi org scenario, this may fetch more than one row - Watch out */
  BEGIN
  SELECT inventory_organization_id
  INTO   x_organization_id
  FROM   financials_system_parameters;
  EXCEPTION
	WHEN NO_DATA_FOUND THEN
          x_organization_id :=-1;
   END;

  IF (x_organization_id = -1) THEN
     NULL;
  ELSE

  INSERT INTO fnd_attached_documents (
    attached_document_id,     document_id,
    creation_date,            created_by,
    last_update_date,         last_updated_by,
    last_update_login,        seq_num,
    entity_name,              pk1_value,
    pk2_value,
    automatically_added_flag, attribute_category,
    attribute1,               attribute2,
    attribute3,               attribute4,
    attribute5,               attribute6,
    attribute7,               attribute8,
    attribute9,               attribute10,
    attribute11,              attribute12,
    attribute13,              attribute14,
    attribute15,              app_source_version )
  VALUES (
    p_attached_doc_id,        x_document_id,
    p_creation_date,          p_created_by,
    sysdate,                  1,
    1,                        p_sequence_num,
    x_entity_name,           x_organization_id,
    p_foreign_id,
    'Y',                      p_attribute_category,
    p_attribute1,             p_attribute2,
    p_attribute3,             p_attribute4,
    p_attribute5,             p_attribute6,
    p_attribute7,             p_attribute8,
    p_attribute9,             p_attribute10,
    p_attribute11,            p_attribute12,
    p_attribute13,            p_attribute14,
    p_attribute15,            p_app_source_version
  );
 END IF;

END;

PROCEDURE update_attached_document (
  p_attached_doc_id         NUMBER,
  p_creation_date           DATE,
  p_created_by              NUMBER,
  p_po_note_id              NUMBER,
  p_table_name              VARCHAR2,
  p_column_name             VARCHAR2,
  p_foreign_id              NUMBER,
  p_sequence_num            NUMBER,
  p_attribute_category      VARCHAR2,
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
  FROM   po_notes
  WHERE  po_note_id = p_po_note_id;

-- you can only update flex fields and sequence number.
  UPDATE fnd_attached_documents
  SET    last_update_date = SYSDATE,
         seq_num     = p_sequence_num,
         document_id = x_document_id,
         attribute_category = p_attribute_category,
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
         app_source_version = 'PO_R10'
  WHERE  attached_document_id = p_attached_doc_id;

END;

PROCEDURE delete_attached_document (
  p_attached_doc_id         NUMBER
) IS

BEGIN

  DELETE FROM fnd_attached_documents
  WHERE attached_document_id = p_attached_doc_id;

END;


END;

/
