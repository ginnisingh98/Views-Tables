--------------------------------------------------------
--  DDL for Package Body PO_REQ_TEMPLATE_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQ_TEMPLATE_SV" AS
/* $Header: POXRQT1B.pls 120.3.12010000.3 2014/03/24 05:19:36 linlilin ship $*/

/*===========================================================================

  PROCEDURE NAME: insert_line

===========================================================================*/
g_fnd_debug CONSTANT VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

c_log_head    CONSTANT VARCHAR2(35) := 'po.plsql.po_req_template_sv.';
PROCEDURE insert_line (x_rowid        IN OUT NOCOPY VARCHAR2,
            x_express_name      IN  VARCHAR2,
      x_sequence_num      IN  NUMBER,
      x_creation_date     IN  DATE,
      x_last_update_date    IN  DATE,
      x_po_header_id      IN  NUMBER,
      x_po_line_id      IN  NUMBER,
      x_created_by      IN  NUMBER,
      x_last_update_login   IN  NUMBER,
      x_item_id     IN  NUMBER,
      x_line_type_id      IN  NUMBER,
      x_item_revision     IN  VARCHAR2,
      x_category_id     IN  NUMBER,
      x_unit_meas_lookup_code   IN  VARCHAR2,
      x_suggested_quantity    IN  NUMBER, --KitSupport FPJ
      x_unit_price      IN  NUMBER,
      x_suggested_vendor_id     IN  NUMBER,
      x_suggested_vendor_site_id  IN  NUMBER,
      x_suggested_vendor_contact_id IN  NUMBER,
      x_suggested_vendor_prod_code  IN  VARCHAR2,
      x_suggested_buyer_id    IN  NUMBER,
      x_rfq_required_flag   IN  VARCHAR2,
      x_vendor_source_context   IN  VARCHAR2,
      x_source_type_code    IN  VARCHAR2,
      x_source_organization_id  IN  NUMBER,
      x_source_subinventory   IN  VARCHAR2,
      x_item_description    IN  VARCHAR2,
      x_attribute_category    IN  VARCHAR2,
      x_attribute1      IN      VARCHAR2,
      x_attribute2      IN      VARCHAR2,
      x_attribute3      IN      VARCHAR2,
      x_attribute4      IN      VARCHAR2,
      x_attribute5      IN      VARCHAR2,
      x_attribute6      IN      VARCHAR2,
      x_attribute7      IN      VARCHAR2,
      x_attribute8      IN      VARCHAR2,
      x_attribute9      IN      VARCHAR2,
      x_attribute10     IN      VARCHAR2,
      x_attribute11     IN      VARCHAR2,
      x_attribute12     IN      VARCHAR2,
      x_attribute13     IN      VARCHAR2,
      x_attribute14     IN      VARCHAR2,
      x_attribute15     IN      VARCHAR2,
                        x_amount                        IN      NUMBER,  -- <SERVICES FPJ>
      x_negotiated_by_preparer_flag   IN  VARCHAR2, --<DBI FPJ>
                        p_org_id                        IN      NUMBER DEFAULT NULL   -- <R12 MOAC>
      )
IS
  x_progress       VARCHAR2(3) := '';

  l_ip_category_id PO_LINES_ALL.ip_category_id%TYPE; -- <Unified Catalog R12>

        CURSOR C IS
      SELECT rowid
      FROM   PO_REQEXPRESS_LINES
            WHERE  express_name = x_express_name
      AND    sequence_num = x_sequence_num;
BEGIN

    IF (TRIM(x_express_name) IS NOT NULL AND
  x_sequence_num IS NOT NULL AND
  x_created_by IS NOT NULL) THEN

        x_progress := '010';
        -- <Unified Catalog R12 Start>
        -- Default the IP_CATEGORY_ID
        PO_ATTRIBUTE_VALUES_PVT.get_ip_category_id
        (
          p_po_category_id => x_category_id
        , x_ip_category_id => l_ip_category_id -- OUT
        );
        -- <Unified Catalog R12 End>

        x_progress := '015';
        --dbms_output.put_line('Before insert');

        -- <SERVICES FPJ>
        -- Added Amount to the INSERT statement
        INSERT INTO PO_REQEXPRESS_LINES (
      express_name,
      sequence_num,
      last_update_date,
      last_updated_by,
      creation_date,
      po_header_id,
      po_line_id,
      created_by,
      last_update_login,
      item_id,
      line_type_id,
      item_revision,
      category_id,
      unit_meas_lookup_code,
      suggested_quantity, --KitSupport FPJ
      unit_price,
      suggested_vendor_id,
      suggested_vendor_site_id,
      suggested_vendor_contact_id,
      suggested_vendor_product_code,
      suggested_buyer_id,
      rfq_required_flag,
      vendor_source_context,
      source_type_code,
      source_organization_id,
      source_subinventory,
      item_description,
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
      amount,
      negotiated_by_preparer_flag,--<DBI FPJ>
      Org_Id,                     -- <R12 MOAC>
      ip_category_id              -- <Unified Catalog R12>
      )
        VALUES (
      x_express_name,
      x_sequence_num,
      x_last_update_date,
      x_created_by,
      x_creation_date,
      x_po_header_id,
      x_po_line_id,
      x_created_by,
      x_last_update_login,
      x_item_id,
      x_line_type_id,
      x_item_revision,
      x_category_id,
      x_unit_meas_lookup_code,
      x_suggested_quantity, --KitSupport FPJ
      x_unit_price,
      x_suggested_vendor_id,
      x_suggested_vendor_site_id,
      x_suggested_vendor_contact_id,
      x_suggested_vendor_prod_code,
      x_suggested_buyer_id,
      x_rfq_required_flag,
      x_vendor_source_context,
      x_source_type_code,
      x_source_organization_id,
      x_source_subinventory,
      x_item_description,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_amount,
      x_negotiated_by_preparer_flag,      --<DBI FPJ>
      p_org_id,                           -- <R12 MOAC>
      l_ip_category_id                    -- <Unified Catalog R12>
      );

        --dbms_output.put_line('After insert');
        x_progress := '020';

        OPEN C;
        FETCH C INTO x_rowid;
        if (C%NOTFOUND) then
          CLOSE C;
          Raise NO_DATA_FOUND;
        end if;
        CLOSE C;

    -- <Unified Catalog R12 Start>
    -- Create default Attr and TLP rows for this PO Line
    PO_ATTRIBUTE_VALUES_PVT.create_default_attributes
    (
      p_doc_type              => 'REQ_TEMPLATE',
      p_po_line_id            => NULL,
      p_req_template_name     => x_express_name,
      p_req_template_line_num => x_sequence_num,
      p_ip_category_id        => l_ip_category_id,
      p_inventory_item_id     => x_item_id,
      p_org_id                => p_org_id,
      p_description           => x_item_description
    );
    -- <Unified Catalog R12 End>

    END IF;

EXCEPTION
    WHEN OTHERS THEN
  --dbms_output.put_line('Exception in insert_lines');
  PO_MESSAGE_S.SQL_ERROR('INSERT_HEADER', x_progress, sqlcode);
  RAISE;
END;

/*===========================================================================

  PROCEDURE NAME: update_line

===========================================================================*/

PROCEDURE update_line (x_rowid    VARCHAR2,
            x_express_name    VARCHAR2,
      x_sequence_num    NUMBER,
      x_last_updated_by NUMBER,
      x_last_update_date  DATE,
      x_po_header_id    NUMBER,
      x_po_line_id    NUMBER,
      x_last_update_login NUMBER,
      x_item_id   NUMBER,
      x_line_type_id    NUMBER,
      x_item_revision   VARCHAR2,
      x_category_id   NUMBER,
      x_unit_meas_lookup_code VARCHAR2,
      x_suggested_quantity  NUMBER, --KitSupport FPJ
      x_unit_price    NUMBER,
      x_suggested_vendor_id   NUMBER,
      x_suggested_vendor_site_id  NUMBER,
      x_suggested_vendor_contact_id NUMBER,
      x_suggested_vendor_prod_code  VARCHAR2,
      x_suggested_buyer_id    NUMBER,
      x_rfq_required_flag   VARCHAR2,
      x_vendor_source_context   VARCHAR2,
      x_source_type_code    VARCHAR2,
      x_source_organization_id  NUMBER,
      x_source_subinventory   VARCHAR2,
      x_item_description    VARCHAR2,
      x_attribute_category    VARCHAR2,
      x_attribute1      VARCHAR2,
      x_attribute2      VARCHAR2,
      x_attribute3      VARCHAR2,
      x_attribute4      VARCHAR2,
      x_attribute5      VARCHAR2,
      x_attribute6      VARCHAR2,
      x_attribute7      VARCHAR2,
      x_attribute8      VARCHAR2,
      x_attribute9      VARCHAR2,
      x_attribute10     VARCHAR2,
      x_attribute11     VARCHAR2,
      x_attribute12     VARCHAR2,
      x_attribute13     VARCHAR2,
      x_attribute14     VARCHAR2,
      x_attribute15     VARCHAR2,
                        x_amount                        NUMBER,  -- <SERVICES FPJ>
      x_negotiated_by_preparer_flag   VARCHAR2) --<DBI FPJ>
IS
  x_progress  VARCHAR2(3) := '';
  l_ip_category_id PO_LINES_ALL.ip_category_id%TYPE; -- <Unified Catalog R12>
BEGIN
    x_progress := '010';
    --dbms_output.put_line('Before Update');

    -- <Unified Catalog R12 Start>
    -- Get the new IP_CATEGORY_ID
    PO_ATTRIBUTE_VALUES_PVT.get_ip_category_id
    (
      p_po_category_id => x_category_id
    , x_ip_category_id => l_ip_category_id -- OUT
    );
    -- <Unified Catalog R12 End>

    -- <SERVICES FPJ>
    -- Added Amount to the UPDATE statement
    UPDATE PO_REQEXPRESS_LINES
    SET    express_name = x_express_name,
     sequence_num = x_sequence_num,
     last_update_date = x_last_update_date,
     last_updated_by = x_last_updated_by,
     po_header_id = x_po_header_id,
     po_line_id = x_po_line_id,
     last_update_login = x_last_update_login,
     item_id = x_item_id,
     line_type_id = x_line_type_id,
     item_revision = x_item_revision,
     category_id = x_category_id,
     unit_meas_lookup_code = x_unit_meas_lookup_code,
     suggested_quantity = x_suggested_quantity, --KitSupport FPJ
     unit_price = x_unit_price,
     suggested_vendor_id = x_suggested_vendor_id,
     suggested_vendor_site_id = x_suggested_vendor_site_id,
     suggested_vendor_contact_id = x_suggested_vendor_contact_id,
     suggested_vendor_product_code = x_suggested_vendor_prod_code,
     suggested_buyer_id = x_suggested_buyer_id,
     rfq_required_flag = x_rfq_required_flag,
     vendor_source_context = x_vendor_source_context,
     source_type_code = x_source_type_code,
     source_organization_id = x_source_organization_id,
     source_subinventory = x_source_subinventory,
     item_description = x_item_description,
     attribute_category = x_attribute_category,
     attribute1 = x_attribute1,
     attribute2 = x_attribute2,
     attribute3 = x_attribute3,
     attribute4 = x_attribute4,
     attribute5 = x_attribute5,
     attribute6 = x_attribute6,
     attribute7 = x_attribute7,
     attribute8 = x_attribute8,
     attribute9 = x_attribute9,
     attribute10 = x_attribute10,
     attribute11 = x_attribute11,
     attribute12 = x_attribute12,
     attribute13 = x_attribute13,
     attribute14 = x_attribute14,
     attribute15 = x_attribute15,
     amount      = x_amount,
     negotiated_by_preparer_flag = x_negotiated_by_preparer_flag, --<DBI FPJ>
     ip_category_id = l_ip_category_id --<Unified Catalog R12>
    WHERE  rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      Raise NO_DATA_FOUND;
    END IF;

    --<Unified Catalog R12: Start>
    PO_ATTRIBUTE_VALUES_PVT.update_attributes
    (
      p_doc_type              => 'REQ_TEMPLATE'
    , p_po_line_id            => NULL
    , p_req_template_name     => x_express_name
    , p_req_template_line_num => x_sequence_num
    , p_org_id                => PO_MOAC_UTILS_PVT.get_current_org_id
    , p_ip_category_id        => l_ip_category_id
    , p_language              => userenv('LANG')
    , p_item_description      => x_item_description
	, p_inventory_item_id     => x_item_id  --bug 18381792
    );
    --<Unified Catalog R12: End>

EXCEPTION
    WHEN OTHERS THEN
  --dbms_output.put_line('Exception in update_lines');
  PO_MESSAGE_S.SQL_ERROR('UPDATE_LINES', x_progress, sqlcode);
  RAISE;
END;

/*===========================================================================

  PROCEDURE NAME: lock_line

===========================================================================*/

PROCEDURE lock_line (x_rowid    VARCHAR2,
            x_express_name    VARCHAR2,
      x_sequence_num    NUMBER,
      x_po_header_id    NUMBER,
      x_po_line_id    NUMBER,
      x_item_id   NUMBER,
      x_line_type_id    NUMBER,
      x_item_revision   VARCHAR2,
      x_category_id   NUMBER,
      x_unit_meas_lookup_code VARCHAR2,
      x_suggested_quantity  NUMBER, --KitSupport FPJ
      x_unit_price    NUMBER,
      x_suggested_vendor_id   NUMBER,
      x_suggested_vendor_site_id  NUMBER,
      x_suggested_vendor_contact_id NUMBER,
      x_suggested_vendor_prod_code  VARCHAR2,
      x_suggested_buyer_id    NUMBER,
      x_rfq_required_flag   VARCHAR2,
      x_vendor_source_context   VARCHAR2,
      x_source_type_code    VARCHAR2,
      x_source_organization_id  NUMBER,
      x_source_subinventory   VARCHAR2,
      x_item_description    VARCHAR2,
      x_attribute_category    VARCHAR2,
      x_attribute1      VARCHAR2,
      x_attribute2      VARCHAR2,
      x_attribute3      VARCHAR2,
      x_attribute4      VARCHAR2,
      x_attribute5      VARCHAR2,
      x_attribute6      VARCHAR2,
      x_attribute7      VARCHAR2,
      x_attribute8      VARCHAR2,
      x_attribute9      VARCHAR2,
      x_attribute10     VARCHAR2,
      x_attribute11     VARCHAR2,
      x_attribute12     VARCHAR2,
      x_attribute13     VARCHAR2,
      x_attribute14     VARCHAR2,
      x_attribute15     VARCHAR2,
                        x_amount                        NUMBER)  -- <SERVICES FPJ>
IS
    CURSOR C IS
        SELECT  *
        FROM    PO_REQEXPRESS_LINES
        WHERE   rowid = x_rowid
        FOR UPDATE of express_name NOWAIT;
    Recinfo C%ROWTYPE;
   l_api_name CONSTANT VARCHAR2(30) := 'lock_line';
BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    IF (C%NOTFOUND) then
        CLOSE C;
        FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.Raise_Exception;
    END IF;
    CLOSE C;

    -- <SERVICES FPJ>
    -- Added Amount to the IF statement so that it can be locked
    -- when necessary.
    IF (
               (Recinfo.express_name = X_express_name)
     AND (Recinfo.sequence_num = x_sequence_num)
           AND (   (Recinfo.po_header_id = X_po_header_id)
                OR (    (Recinfo.po_header_id IS NULL)
                    AND (X_po_header_id IS NULL)))
           AND (   (Recinfo.po_line_id = X_po_line_id)
                OR (    (Recinfo.po_line_id IS NULL)
                    AND (X_po_line_id IS NULL)))
           AND (   (Recinfo.item_id = X_item_id)
                OR (    (Recinfo.item_id IS NULL)
                    AND (X_item_id IS NULL)))
           AND (   (Recinfo.line_type_id = X_line_type_id)
                OR (    (Recinfo.line_type_id IS NULL)
                    AND (X_line_type_id IS NULL)))
           AND (   (TRIM(Recinfo.item_revision) = TRIM(X_item_revision))
                OR (    (TRIM(Recinfo.item_revision) IS NULL)
                    AND (TRIM(X_item_revision) IS NULL)))
           AND (   (Recinfo.category_id = X_category_id)
                OR (    (Recinfo.category_id IS NULL)
                    AND (X_category_id IS NULL)))
           AND (   (TRIM(Recinfo.unit_meas_lookup_code) =TRIM( X_unit_meas_lookup_code))
                OR (    (TRIM(Recinfo.unit_meas_lookup_code) IS NULL)
                    AND (TRIM(X_unit_meas_lookup_code) IS NULL)))
           AND (   (Recinfo.suggested_quantity = X_suggested_quantity) --KitSupport FPJ
                OR (    (Recinfo.suggested_quantity IS NULL)
                    AND (X_suggested_quantity IS NULL)))
           AND (   (Recinfo.unit_price = X_unit_price)
                OR (    (Recinfo.unit_price IS NULL)
                    AND (X_unit_price IS NULL)))
           AND (   (Recinfo.suggested_vendor_id = X_suggested_vendor_id)
                OR (    (Recinfo.suggested_vendor_id IS NULL)
                    AND (X_suggested_vendor_id IS NULL)))
           AND (   (Recinfo.suggested_vendor_site_id = X_suggested_vendor_site_id)
                OR (    (Recinfo.suggested_vendor_site_id IS NULL)
                    AND (X_suggested_vendor_site_id IS NULL)))
           AND (   (Recinfo.suggested_vendor_contact_id = X_suggested_vendor_contact_id)
                OR (    (Recinfo.suggested_vendor_contact_id IS NULL)
                    AND (X_suggested_vendor_contact_id IS NULL)))
           AND (   (TRIM(Recinfo.suggested_vendor_product_code) = TRIM(X_suggested_vendor_prod_code))
                OR (    (TRIM(Recinfo.suggested_vendor_product_code) IS NULL)
                    AND (TRIM(X_suggested_vendor_prod_code) IS NULL)))
           AND (   (Recinfo.suggested_buyer_id = X_suggested_buyer_id)
                OR (    (Recinfo.suggested_buyer_id IS NULL)
                    AND (X_suggested_buyer_id IS NULL)))
           AND (   (TRIM(Recinfo.rfq_required_flag) = TRIM(X_rfq_required_flag))
                OR (    (TRIM(Recinfo.rfq_required_flag) IS NULL)
                    AND (TRIM(X_rfq_required_flag) IS NULL)))
           AND (   (TRIM(Recinfo.vendor_source_context ) =TRIM(X_vendor_source_context))
                OR (    (TRIM(Recinfo.vendor_source_context) IS NULL)
                    AND (TRIM(X_vendor_source_context) IS NULL)))
           AND (   (TRIM(Recinfo.source_type_code) = TRIM(X_source_type_code))
                OR (    (TRIM(Recinfo.source_type_code) IS NULL)
                    AND (TRIM(X_source_type_code) IS NULL)))
           AND (   (TRIM(Recinfo.source_organization_id) = TRIM(X_source_organization_id))
                OR (    (TRIM(Recinfo.source_organization_id) IS NULL)
                    AND (TRIM(X_source_organization_id) IS NULL)))
           AND (   (TRIM(Recinfo.source_subinventory) = TRIM(X_source_subinventory))
                OR (    (TRIM(Recinfo.source_subinventory) IS NULL)
                    AND (TRIM(X_source_subinventory) IS NULL)))
           AND (   (TRIM(Recinfo.item_description) = TRIM(X_item_description))
                OR (    (TRIM(Recinfo.item_description) IS NULL)
                    AND (TRIM(X_item_description) IS NULL)))
           AND (   (TRIM(Recinfo.attribute_category) = TRIM(X_attribute_category))
                OR (    (TRIM(Recinfo.attribute_category) IS NULL)
                    AND (TRIM(X_attribute_category) IS NULL)))
           AND (   (TRIM(Recinfo.attribute1) = TRIM(X_attribute1))
                OR (    (TRIM(Recinfo.attribute1) IS NULL)
                    AND (TRIM(X_attribute1) IS NULL)))
           AND (   (TRIM(Recinfo.attribute2) = TRIM(X_attribute2))
                OR (    (TRIM(Recinfo.attribute2) IS NULL)
                    AND (TRIM(X_attribute2) IS NULL)))
           AND (   (TRIM(Recinfo.attribute3) = TRIM(X_attribute3))
                OR (    (TRIM(Recinfo.attribute3) IS NULL)
                    AND (TRIM(X_attribute3) IS NULL)))
           AND (   (TRIM(Recinfo.attribute4) = TRIM(X_attribute4))
                OR (    (TRIM(Recinfo.attribute4) IS NULL)
                    AND (TRIM(X_attribute4) IS NULL)))
           AND (   (TRIM(Recinfo.attribute5) = TRIM(X_attribute5))
                OR (    (TRIM(Recinfo.attribute5) IS NULL)
                    AND (TRIM(X_attribute5) IS NULL)))
           AND (   (TRIM(Recinfo.attribute6) = TRIM(X_attribute6))
                OR (    (TRIM(Recinfo.attribute6) IS NULL)
                    AND (TRIM(X_attribute6) IS NULL)))
           AND (   (TRIM(Recinfo.attribute7 )= TRIM(X_attribute7))
                OR (    (TRIM(Recinfo.attribute7) IS NULL)
                    AND (TRIM(X_attribute7) IS NULL)))
           AND (   (TRIM(Recinfo.attribute8) = TRIM(X_attribute8))
                OR (    (TRIM(Recinfo.attribute8) IS NULL)
                    AND (TRIM(X_attribute8) IS NULL)))
           AND (   (TRIM(Recinfo.attribute9) = TRIM(X_attribute9))
                OR (    (TRIM(Recinfo.attribute9) IS NULL)
                    AND (TRIM(X_attribute9) IS NULL)))
           AND (   (TRIM(Recinfo.attribute10) = TRIM(X_attribute10))
                OR (    (TRIM(Recinfo.attribute10) IS NULL)
                    AND (TRIM(X_attribute10) IS NULL)))
           AND (   (TRIM(Recinfo.attribute11) = TRIM(X_attribute11))
                OR (    (TRIM(Recinfo.attribute11) IS NULL)
                    AND (TRIM(X_attribute11) IS NULL)))
           AND (   (TRIM(Recinfo.attribute12) = TRIM(X_attribute12))
                OR (    (TRIM(Recinfo.attribute12) IS NULL)
                    AND (TRIM(X_attribute12) IS NULL)))
           AND (   (TRIM(Recinfo.attribute13) = TRIM(X_attribute13))
                OR (    (TRIM(Recinfo.attribute13) IS NULL)
                    AND (TRIM(X_attribute13) IS NULL)))
           AND (   (TRIM(Recinfo.attribute14) = TRIM(X_attribute14))
                OR (    (TRIM(Recinfo.attribute14) IS NULL)
                    AND (TRIM(X_attribute14) IS NULL)))
           AND (   (TRIM(Recinfo.attribute15) = TRIM(X_attribute15))
                OR (    (TRIM(Recinfo.attribute15) IS NULL)
                    AND (TRIM(X_attribute15) IS NULL)))
           AND (   (Recinfo.amount = x_amount)
                OR (    (Recinfo.amount IS NULL)
                    AND (x_amount IS NULL)))
     ) THEN
  return;

    ELSE

          IF (g_fnd_debug = 'Y') THEN
        IF (NVL(TRIM(x_express_name),'-999') <> NVL( TRIM(Recinfo.express_name),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form express_name '||x_express_name ||' Database  express_name '||Recinfo.express_name);
        END IF;
        IF (NVL(x_sequence_num,-999) <> NVL(Recinfo.sequence_num,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form sequence_num'||x_sequence_num ||' Database  sequence_num '|| Recinfo.sequence_num);
        END IF;
        IF (NVL(x_po_header_id,-999) <> NVL(Recinfo.po_header_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form po_header_id'||x_po_header_id ||' Database  po_header_id '|| Recinfo.po_header_id);
        END IF;
        IF (NVL(x_po_line_id,-999) <> NVL(Recinfo.po_line_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form po_line_id'||x_po_line_id ||' Database  po_line_id '|| Recinfo.po_line_id);
        END IF;
        IF (NVL(x_item_id,-999) <> NVL(Recinfo.item_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form item_id'||x_item_id ||' Database  item_id '|| Recinfo.item_id);
        END IF;
        IF (NVL(x_line_type_id,-999) <> NVL(Recinfo.line_type_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form line_type_id'||x_line_type_id ||' Database  line_type_id '|| Recinfo.line_type_id);
        END IF;
        IF (NVL(TRIM(x_item_revision),'-999') <> NVL( TRIM(Recinfo.item_revision),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form item_revision '||x_item_revision ||' Database  item_revision '||Recinfo.item_revision);
        END IF;
        IF (NVL(x_category_id,-999) <> NVL(Recinfo.category_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form category_id'||x_category_id ||' Database  category_id '|| Recinfo.category_id);
        END IF;
        IF (NVL(TRIM(x_unit_meas_lookup_code),'-999') <> NVL( TRIM(Recinfo.unit_meas_lookup_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form unit_meas_lookup_code '||x_unit_meas_lookup_code ||' Database  unit_meas_lookup_code '||Recinfo.unit_meas_lookup_code);
        END IF;
        IF (NVL(x_suggested_quantity,-999) <> NVL(Recinfo.suggested_quantity,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form suggested_quantity'||x_suggested_quantity ||' Database  suggested_quantity '|| Recinfo.suggested_quantity);
        END IF;
        IF (NVL(x_unit_price,-999) <> NVL(Recinfo.unit_price,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form unit_price'||x_unit_price ||' Database  unit_price '|| Recinfo.unit_price);
        END IF;
        IF (NVL(x_suggested_vendor_id,-999) <> NVL(Recinfo.suggested_vendor_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form suggested_vendor_id'||x_suggested_vendor_id ||' Database  suggested_vendor_id '|| Recinfo.suggested_vendor_id);
        END IF;
        IF (NVL(x_suggested_vendor_site_id,-999) <> NVL(Recinfo.suggested_vendor_site_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form suggested_vendor_site_id'||x_suggested_vendor_site_id ||' Database  suggested_vendor_site_id '|| Recinfo.suggested_vendor_site_id);
        END IF;
        IF (NVL(x_suggested_vendor_contact_id,-999) <> NVL(Recinfo.suggested_vendor_contact_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form suggested_vendor_contact_id'||x_suggested_vendor_contact_id ||' Database  suggested_vendor_contact_id '|| Recinfo.suggested_vendor_contact_id);
        END IF;
        IF (NVL(TRIM(x_suggested_vendor_prod_code),'-999') <> NVL( TRIM(Recinfo.suggested_vendor_product_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form suggested_vendor_prod_code '||x_suggested_vendor_prod_code ||' Database  suggested_vendor_prod_code '||Recinfo.suggested_vendor_product_code);
        END IF;
        IF (NVL(x_suggested_buyer_id,-999) <> NVL(Recinfo.suggested_buyer_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form suggested_buyer_id'||x_suggested_buyer_id ||' Database  suggested_buyer_id '|| Recinfo.suggested_buyer_id);
        END IF;
        IF (NVL(TRIM(x_rfq_required_flag),'-999') <> NVL( TRIM(Recinfo.rfq_required_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form rfq_required_flag '||x_rfq_required_flag ||' Database  rfq_required_flag '||Recinfo.rfq_required_flag);
        END IF;
        IF (NVL(TRIM(x_vendor_source_context),'-999') <> NVL( TRIM(Recinfo.vendor_source_context),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form vendor_source_context '||x_vendor_source_context ||' Database  vendor_source_context '||Recinfo.vendor_source_context);
        END IF;
        IF (NVL(TRIM(x_source_type_code),'-999') <> NVL( TRIM(Recinfo.source_type_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form source_type_code '||x_source_type_code ||' Database  source_type_code '||Recinfo.source_type_code);
        END IF;
        IF (NVL(x_source_organization_id,-999) <> NVL(Recinfo.source_organization_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form source_organization_id'||x_source_organization_id ||' Database  source_organization_id '|| Recinfo.source_organization_id);
        END IF;
        IF (NVL(TRIM(x_source_subinventory),'-999') <> NVL( TRIM(Recinfo.source_subinventory),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form source_subinventory '||x_source_subinventory ||' Database  source_subinventory '||Recinfo.source_subinventory);
        END IF;
        IF (NVL(TRIM(x_item_description),'-999') <> NVL( TRIM(Recinfo.item_description),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form item_description '||x_item_description ||' Database  item_description '||Recinfo.item_description);
        END IF;
        IF (NVL(TRIM(x_attribute_category),'-999') <> NVL( TRIM(Recinfo.attribute_category),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute_category '||x_attribute_category ||' Database  attribute_category '||Recinfo.attribute_category);
        END IF;
        IF (NVL(TRIM(x_attribute1),'-999') <> NVL( TRIM(Recinfo.attribute1),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute1 '||x_attribute1 ||' Database  attribute1 '||Recinfo.attribute1);
        END IF;
        IF (NVL(TRIM(x_attribute2),'-999') <> NVL( TRIM(Recinfo.attribute2),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute2 '||x_attribute2 ||' Database  attribute2 '||Recinfo.attribute2);
        END IF;
        IF (NVL(TRIM(x_attribute3),'-999') <> NVL( TRIM(Recinfo.attribute3),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute3 '||x_attribute3 ||' Database  attribute3 '||Recinfo.attribute3);
        END IF;
        IF (NVL(TRIM(x_attribute4),'-999') <> NVL( TRIM(Recinfo.attribute4),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute4 '||x_attribute4 ||' Database  attribute4 '||Recinfo.attribute4);
        END IF;
        IF (NVL(TRIM(x_attribute5),'-999') <> NVL( TRIM(Recinfo.attribute5),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute5 '||x_attribute5 ||' Database  attribute5 '||Recinfo.attribute5);
        END IF;
        IF (NVL(TRIM(x_attribute6),'-999') <> NVL( TRIM(Recinfo.attribute6),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute6 '||x_attribute6 ||' Database  attribute6 '||Recinfo.attribute6);
        END IF;
        IF (NVL(TRIM(x_attribute7),'-999') <> NVL( TRIM(Recinfo.attribute7),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute7 '||x_attribute7 ||' Database  attribute7 '||Recinfo.attribute7);
        END IF;
        IF (NVL(TRIM(x_attribute8),'-999') <> NVL( TRIM(Recinfo.attribute8),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute8 '||x_attribute8 ||' Database  attribute8 '||Recinfo.attribute8);
        END IF;
        IF (NVL(TRIM(x_attribute9),'-999') <> NVL( TRIM(Recinfo.attribute9),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute9 '||x_attribute9 ||' Database  attribute9 '||Recinfo.attribute9);
        END IF;
        IF (NVL(TRIM(x_attribute10),'-999') <> NVL( TRIM(Recinfo.attribute10),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute10 '||x_attribute10 ||' Database  attribute10 '||Recinfo.attribute10);
        END IF;
        IF (NVL(TRIM(x_attribute11),'-999') <> NVL( TRIM(Recinfo.attribute11),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute11 '||x_attribute11 ||' Database  attribute11 '||Recinfo.attribute11);
        END IF;
        IF (NVL(TRIM(x_attribute12),'-999') <> NVL( TRIM(Recinfo.attribute12),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute12 '||x_attribute12 ||' Database  attribute12 '||Recinfo.attribute12);
        END IF;
        IF (NVL(TRIM(x_attribute13),'-999') <> NVL( TRIM(Recinfo.attribute13),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute13 '||x_attribute13 ||' Database  attribute13 '||Recinfo.attribute13);
        END IF;
        IF (NVL(TRIM(x_attribute14),'-999') <> NVL( TRIM(Recinfo.attribute14),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute14 '||x_attribute14 ||' Database  attribute14 '||Recinfo.attribute14);
        END IF;
        IF (NVL(TRIM(x_attribute15),'-999') <> NVL( TRIM(Recinfo.attribute15),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute15 '||x_attribute15 ||' Database  attribute15 '||Recinfo.attribute15);
        END IF;
        IF (NVL(x_amount,-999) <> NVL(Recinfo.amount,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form amount'||x_amount ||' Database  amount '|| Recinfo.amount);
        END IF;
    END IF;

  FND_MESSAGE.set_name('FND', 'FORM_RECORD_CHANGED');
   APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

END;

/*===========================================================================

  PROCEDURE NAME: delete_line

===========================================================================*/

PROCEDURE delete_line (x_rowid VARCHAR2)
IS
  -- <Unified Catalog R12 Start>
  l_req_template_name     PO_REQEXPRESS_LINES_ALL.express_name%TYPE;
  l_req_template_line_num PO_REQEXPRESS_LINES_ALL.sequence_num%TYPE;
  l_org_id                PO_REQEXPRESS_LINES_ALL.org_id%TYPE;
  -- <Unified Catalog R12 End>
BEGIN

    DELETE FROM PO_REQEXPRESS_LINES
    WHERE  rowid = X_Rowid
    -- <Unified Catalog R12 Start>
    RETURNING
      express_name,
      sequence_num,
      org_id
    INTO
      l_req_template_name,
      l_req_template_line_num,
      l_org_id;
    -- <Unified Catalog R12 End>

    IF (SQL%NOTFOUND) THEN
      Raise NO_DATA_FOUND;
    END IF;

    -- <Unified Catalog R12 Start>
    -- Delete the Attr and TLP rows associated with this line.
    PO_ATTRIBUTE_VALUES_PVT.delete_attributes
    (
      p_doc_type              => 'REQ_TEMPLATE'
    , p_req_template_name     => l_req_template_name
    , p_req_template_line_num => l_req_template_line_num
    , p_org_id                => l_org_id
    );
    -- <Unified Catalog R12 End>

END;


END PO_REQ_TEMPLATE_SV;

/
