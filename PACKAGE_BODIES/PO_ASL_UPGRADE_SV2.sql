--------------------------------------------------------
--  DDL for Package Body PO_ASL_UPGRADE_SV2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ASL_UPGRADE_SV2" AS
/* $Header: POXA2LUB.pls 120.2 2006/01/30 18:16:00 pthapliy noship $*/

/*===========================================================================

  PROCEDURE NAME:       upgrade_autosource_vendors

===========================================================================*/

PROCEDURE upgrade_autosource_vendors(
  x_sr_receipt_id     NUMBER,
  x_autosource_rule_id  NUMBER,
  x_item_id   NUMBER,
  x_asl_status_id   NUMBER,
  x_upgrade_docs    VARCHAR2,
  x_usr_upgrade_docs  VARCHAR2
) IS
  x_progress        VARCHAR2(3) := '';
  x_vendor_id     NUMBER;
  x_vendor_rank     NUMBER;
  x_split       NUMBER;
  x_last_update_date    DATE;
  x_last_update_login   NUMBER;
  x_last_updated_by   NUMBER;
  x_created_by      NUMBER;
  x_creation_date     DATE;
  x_sr_source_id      NUMBER;
  x_asl_id      NUMBER;
  x_split_multiplier    NUMBER;
  x_add_percent     VARCHAR2(1) := '';
        x_ATTRIBUTE_CATEGORY     po_autosource_vendors.attribute_category%type;
        x_attribute1           po_autosource_vendors.attribute1%type;
        x_attribute2           po_autosource_vendors.attribute2%type;
        x_attribute3           po_autosource_vendors.attribute3%type;
        x_attribute4           po_autosource_vendors.attribute4%type;
        x_attribute5           po_autosource_vendors.attribute5%type;
        x_attribute6           po_autosource_vendors.attribute6%type;
        x_attribute7           po_autosource_vendors.attribute7%type;
        x_attribute8           po_autosource_vendors.attribute8%type;
        x_attribute9           po_autosource_vendors.attribute9%type;
        x_attribute10           po_autosource_vendors.attribute10%type;
        x_attribute11           po_autosource_vendors.attribute11%type;
        x_attribute12           po_autosource_vendors.attribute12%type;
        x_attribute13           po_autosource_vendors.attribute13%type;
        x_attribute14           po_autosource_vendors.attribute14%type;
        x_attribute15           po_autosource_vendors.attribute15%type;

        CURSOR C is
      SELECT  VENDOR_ID,
        VENDOR_RANK,
        nvl(SPLIT,0),
        LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
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
                    attribute15
      FROM    PO_AUTOSOURCE_VENDORS
      WHERE   AUTOSOURCE_RULE_ID = x_autosource_rule_id;

  CURSOR I is
      SELECT  MRP_SR_SOURCE_ORG_S.NEXTVAL
      FROM    SYS.DUAL;

BEGIN

     -- Determine whether we need to scale up the splits to sum to
     -- 100%

     po_asl_upgrade_sv3.get_split_multiplier(
    x_autosource_rule_id,
    x_split_multiplier,
    x_add_percent);

    -- Select all the vendors for this autosource rule.

    OPEN C;
    LOOP

        x_progress := '020';
        FETCH C into x_vendor_id,
    x_vendor_rank,
          x_split,
    x_last_update_date,
    x_last_update_login,
      x_last_updated_by,
    x_creation_date,
    x_created_by,
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
                x_attribute15
;

        EXIT WHEN C%NOTFOUND;

--testing
--x_created_by := 99999;

  x_progress := '020';
  OPEN I;
  FETCH I into x_sr_source_id;
  IF (I%NOTFOUND) THEN
      close I;
      fnd_file.put_line(fnd_file.log, '** Cannot get sr_source_id');
      raise NO_DATA_FOUND;
  END IF;
  CLOSE I;

  -- Insert record into mpr_sr_source_org

  x_progress := '030';
     fnd_file.put_line(fnd_file.log,'Adding vendor to sourcing rule.  VENDOR_ID = '||x_vendor_id);

  INSERT INTO MRP_SR_SOURCE_ORG(
    sr_source_id,
    sr_receipt_id,
    vendor_id,
    source_type,
    allocation_percent,
    rank,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login,
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
                    attribute15
  ) VALUES (
    x_sr_source_id,
    x_sr_receipt_id,
    x_vendor_id,
    3,      -- source_type
    decode(x_split_multiplier, 1, x_split,
      decode(x_add_percent, 'N', round(x_split*x_split_multiplier),
          decode(x_vendor_rank, 1, round(x_split*x_split_multiplier)+1,
          round(x_split*x_split_multiplier)))),
    x_vendor_rank,
    x_last_update_date,
    x_last_updated_by,
    x_creation_date,
    x_created_by,
    x_last_update_login,
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
                x_attribute15
  );

  -- Create new ASL entry for this supplier-item relationship.

  x_progress := '040';
  create_asl_entry(x_vendor_id,
       x_item_id,
       x_asl_status_id,
         x_last_update_date,
       x_last_update_login,
       x_last_updated_by,
       x_created_by,
       x_creation_date,
       x_usr_upgrade_docs,
       x_asl_id);

        IF (x_upgrade_docs = 'Y') THEN

            x_progress := '050';
            upgrade_asl_documents(x_autosource_rule_id,
                        x_vendor_id,
                        x_asl_id);
        END IF;

    END LOOP;
    CLOSE C;

EXCEPTION
    WHEN OTHERS THEN
  fnd_file.put_line(fnd_file.log, '** Exception in upgrade_autosource_vendors');
        fnd_file.put_line(fnd_file.log, 'x_progress = '||x_progress);
  PO_MESSAGE_S.SQL_ERROR('UPGRADE_AUTOSOURCE_VENDORS', x_progress, sqlcode);
END;

/*===========================================================================

  PROCEDURE NAME:       create_asl_entry

===========================================================================*/

PROCEDURE create_asl_entry(x_vendor_id      NUMBER,
         x_item_id      NUMBER,
         x_asl_status_id    NUMBER,
         x_last_update_date   DATE,
         x_last_update_login    NUMBER,
         x_last_updated_by    NUMBER,
         x_created_by     NUMBER,
         x_creation_date    DATE,
         x_usr_upgrade_docs   VARCHAR2,
         x_asl_id   IN OUT NOCOPY  NUMBER
) IS
  x_progress      VARCHAR2(30) := '';
    x_record_unique       BOOLEAN;
  x_owning_organization_id  NUMBER;
  x_purch_uom po_lines.unit_meas_lookup_code%type;
        x_release_generation_method     po_asl_attributes.release_generation_method%type := '';



  CURSOR I2 is
      SELECT  PO_APPROVED_SUPPLIER_LIST_S.NEXTVAL
      FROM    SYS.DUAL;

BEGIN

    -- Check whether the global supplier-item relationship has already been
    -- defined.

    x_progress := '010';
    x_record_unique := po_asl_sv.check_record_unique(
                          NULL,
                          x_vendor_id,
                          NULL,
                          x_item_id,
                          NULL,
                          -1);

    IF x_record_unique THEN

        -- Get owning_organization_id from financials_system_parameters.

        x_progress := '1451';

  begin
        select mtl.organization_id
        into x_owning_organization_id
        from mtl_system_items msi, mtl_parameters mtl,
             financials_system_parameters fsp
        where msi.inventory_item_id = x_item_id
        and   msi.organization_id   = fsp.inventory_organization_id
        and   msi.organization_id   = mtl.master_organization_id
        and   msi.organization_id   = mtl.organization_id;
 exception
         when no_data_found then
          select mtl.organization_id
        into x_owning_organization_id
        from mtl_system_items msi, mtl_parameters mtl
        where msi.inventory_item_id = x_item_id
        and   msi.organization_id   = mtl.master_organization_id
        and   msi.organization_id   = mtl.organization_id;
end;


/*        select mtl.organization_id
        into x_owning_organization_id
        from mtl_system_items msi, mtl_parameters mtl
        where msi.inventory_item_id = x_item_id
        and msi.organization_id = mtl.master_organization_id
        and msi.organization_id = mtl.organization_id;
*/
--        SELECT   inventory_organization_id
--        INTO     x_owning_organization_id
--        FROM     financials_system_params_all
--        WHERE    rownum < 2;

        -- The reason we are doing the above is because we do not do
        -- anything with the owning org hence any owning org is fine.(R11)

        -- If supplier-item relationship has not yet been created,
        -- insert new record in po_approved_supplier_list.
        -- Temporarily set request_id to -99 so that we can identify
        -- the ASL records created in this upgrade.

        x_progress := '020';
        OPEN I2;
        FETCH I2 into x_asl_id;
        IF (I2%NOTFOUND) THEN
            close I2;
            fnd_file.put_line(fnd_file.log, '** Cannot get asl_id');
            raise NO_DATA_FOUND;
        END IF;
        CLOSE I2;

        x_progress := '030';
      fnd_file.put_line(fnd_file.log, 'x_item_id '||to_char(x_item_id));
        fnd_file.put_line(fnd_file.log, 'x_asl_id '||to_char(x_asl_id));
        fnd_file.put_line(fnd_file.log, 'x_vendor_id '||to_char(x_vendor_id));
        fnd_file.put_line(fnd_file.log, 'x_asl_status_id '||to_char(x_asl_status_id));
        fnd_file.put_line(fnd_file.log, 'x_creation_date '||to_char(x_creation_date));
    fnd_file.put_line(fnd_file.log, 'x_last_update_date '||to_char(x_last_update_date));
       fnd_file.put_line(fnd_file.log, 'owning_org '||to_char(x_owning_organization_id));
 fnd_file.put_line(fnd_file.log, 'update by '|| to_char(x_last_updated_by) );
 fnd_file.put_line(fnd_file.log, 'created by '||to_char(x_created_by) );

        INSERT INTO PO_APPROVED_SUPPLIER_LIST(
                asl_id                  ,
                using_organization_id   ,
                owning_organization_id  ,
                vendor_business_type    ,
                asl_status_id           ,
                last_update_date        ,
                last_updated_by         ,
                creation_date           ,
                created_by              ,
                vendor_id               ,
                item_id                 ,
                last_update_login       ,
                request_id
        )  VALUES                       (
                x_asl_id                  ,
                -1,
                x_owning_organization_id,               -- ??x_owning_organization_id
                'DIRECT',
                x_asl_status_id           ,
                x_last_update_date        ,
                x_last_updated_by         ,
                x_creation_date           ,
                x_created_by              ,
                x_vendor_id               ,
                x_item_id                 ,
                x_last_update_login       ,
                -99
        );


--testing
--using_organization_id: use 2 for ap349db1, 1 for ap309db1
--      use 23 for systest

        -- IF upgrading documents, get the release generation
        -- method for this asl entry.

        IF (x_usr_upgrade_docs IN ('CURRENT', 'FUTURE')) THEN

            BEGIN

            -- Get release generation method from top ranked blanket
            -- in currently effective autosource rule.  Check that
            -- the document is effective.

            SELECT  doc_generation_method
            INTO    x_release_generation_method
            FROM    po_autosource_documents_all pad,
                    po_autosource_rules     par
            WHERE   pad.autosource_rule_id = par.autosource_rule_id
            AND     par.item_id = x_item_id
            AND     pad.vendor_id = x_vendor_id
            AND     par.start_date <= sysdate
            AND     par.end_date > sysdate
            AND     rownum < 2
            AND     pad.sequence_num =
                       (SELECT  min(sequence_num)
                        FROM    po_autosource_documents_all pad2,
                                po_headers_all poh
                        WHERE   pad2.autosource_rule_id = pad.autosource_rule_id
                        AND     pad2.vendor_id = x_vendor_id
                        AND     pad2.document_type_code = 'BLANKET'
                        AND     pad2.document_header_id = poh.po_header_id
                        AND     nvl(poh.start_date, sysdate-1) <= sysdate
                        AND     nvl(poh.end_date, sysdate+1) > sysdate);

            EXCEPTION
              WHEN NO_DATA_FOUND THEN

                IF (x_usr_upgrade_docs = 'FUTURE') THEN

                  BEGIN

                  -- Get release generation method from top ranked blanket
                  -- in the first future autosource rule that contains a
                  -- blanket.

                  SELECT  pad.doc_generation_method
                  INTO    x_release_generation_method
                  FROM    po_autosource_rules      par,
                          po_autosource_documents_all  pad
                  WHERE   par.item_id = x_item_id
                  AND     pad.vendor_id = x_vendor_id
                  AND     rownum < 2
                  AND     par.autosource_rule_id = pad.autosource_rule_id
                  AND     par.start_date =
                           (SELECT min(par3.start_date)
                            FROM   po_autosource_documents_all pad3,
                                   po_autosource_rules     par3,
                                   po_headers_all        poh3
                            WHERE  par3.autosource_rule_id = pad3.autosource_rule_id
                            AND    pad3.vendor_id = x_vendor_id
                            AND    par3.item_id = x_item_id
                            AND    pad3.document_header_id = poh3.po_header_id
                            AND    nvl(poh3.start_date, sysdate-1) <= sysdate
                            AND    nvl(poh3.end_date, sysdate+1) > sysdate
                            AND    par3.start_date > sysdate
                            AND    pad3.document_type_code = 'BLANKET')
                  AND     pad.sequence_num =
                            (SELECT  min(sequence_num)
                             FROM    po_autosource_documents_all pad2,
                                     po_headers_all poh2
                             WHERE   pad2.autosource_rule_id = pad.autosource_rule_id
                             AND     pad2.vendor_id = x_vendor_id
                             AND     pad2.document_type_code = 'BLANKET'
                             AND     pad2.document_header_id = poh2.po_header_id
                             AND     nvl(poh2.start_date, sysdate-1) <= sysdate
                             AND     nvl(poh2.end_date, sysdate+1) > sysdate);

                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        NULL;
                  END;

                END IF;
            END;
        END IF;

        -- Create an attributes record for this ASL entry.

        x_progress := '040';

        INSERT INTO po_asl_attributes(
                asl_id,
                using_organization_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                document_sourcing_method,
                release_generation_method,
                enable_plan_schedule_flag,
                enable_ship_schedule_flag,
                enable_autoschedule_flag,
                enable_authorizations_flag,
                vendor_id,
                item_id
        ) VALUES (
                x_asl_id,
                -1,
                x_last_update_date,
                x_last_updated_by,
                x_creation_date,
                x_created_by,
                x_last_update_login,
                'ASL',
                x_release_generation_method,
                'N',
                'N',
                'N',
                'N',
                x_vendor_id,
                x_item_id
        );

    ELSE

        -- If supplier-item relationship already exists, return
        -- asl_id for this asl entry.

        x_progress := '050';
        SELECT asl_id
        INTO   x_asl_id
        FROM   po_approved_supplier_list pasl
        WHERE  pasl.vendor_id = x_vendor_id
        AND    pasl.item_id = x_item_id
        AND    using_organization_id = -1;

        fnd_file.put_line(fnd_file.log, 'ASL entry already exists.');

    END IF;

EXCEPTION
    WHEN OTHERS THEN
        fnd_file.put_line(fnd_file.log, '** Exception in create_asl_entry');
        fnd_file.put_line(fnd_file.log, 'x_progress = '||x_progress);
        fnd_file.put_line(fnd_file.log,'CREATE_ASL_ENTRY'|| sqlcode);
        PO_MESSAGE_S.SQL_ERROR('CREATE_ASL_ENTRY', x_progress, sqlcode);
END;
/*===========================================================================

  PROCEDURE NAME:       upgrade_asl_documents

===========================================================================*/

PROCEDURE upgrade_asl_documents(
        x_autosource_rule_id    NUMBER,
        x_vendor_id             NUMBER,
        x_asl_id                NUMBER
) IS
        x_progress                      VARCHAR2(3) := '';
        x_dummy_count                   NUMBER;
        x_sequence_num                  NUMBER;
        x_document_header_id            NUMBER;
        x_document_line_id              NUMBER;
        x_org_id                        NUMBER;
        x_last_update_date              DATE;
        x_last_update_login             NUMBER;
        x_last_updated_by               NUMBER;
        x_created_by                    NUMBER;
        x_creation_date                 DATE;
        x_request_id                    NUMBER;
        x_document_type_code    po_autosource_documents.document_type_code%type;
        x_doc_generation_method po_autosource_documents.doc_generation_method%type;

        CURSOR C IS
            SELECT  pad.document_type_code,
                    pad.document_header_id,
                    pad.document_line_id,
                    pad.last_update_date,
                    pad.last_updated_by,
                    pad.last_update_login,
                    pad.creation_date,
                    pad.created_by,
                    pad.doc_generation_method,
                    pad.org_id
            FROM    PO_AUTOSOURCE_DOCUMENTS_all pad,
                    PO_HEADERS_all poh
            WHERE   pad.autosource_rule_id = x_autosource_rule_id
            AND     pad.vendor_id = x_vendor_id
            AND     poh.po_header_id = pad.document_header_id
            AND     sysdate >= nvl(poh.start_date, sysdate-1)
            AND     sysdate < nvl(poh.end_date, sysdate+1)
            ORDER BY pad.sequence_num ;

BEGIN

  -- If ASL entry was not created in this upgrade, do not add source
  -- documents to it.

  SELECT  request_id
  INTO    x_request_id
  FROM    po_approved_supplier_list
  WHERE   asl_id = x_asl_id;

  IF (x_request_id IS NULL OR x_request_id <> -99) THEN
      null;
      fnd_file.put_line(fnd_file.log, 'Not adding source documents to existing ASL entry.');
      return;
  END IF;

  OPEN C;
  LOOP
      x_progress := '010';
      FETCH C into x_document_type_code,
                x_document_header_id,
                x_document_line_id,
                x_last_update_date,
                x_last_updated_by,
                x_last_update_login,
                x_creation_date,
                x_created_by,
                x_doc_generation_method,
                x_org_id;

      EXIT WHEN C%NOTFOUND;

      -- Make sure that this source document does not already exist for
      -- this ASL entry.

      x_progress := '020';
      SELECT   count(*)
      INTO     x_dummy_count
      FROM     po_asl_documents
      WHERE    asl_id = x_asl_id
      AND      using_organization_id = -1
      AND      document_header_id = x_document_header_id
      AND      document_type_code = x_document_type_code;

      IF x_dummy_count > 0 THEN

         null;
         fnd_file.put_line(fnd_file.log, 'Source document already exists for this this ASL entry.');
      ELSE

        -- Sequence number for this document is one above the highest
        -- sequence number.

        x_progress := '030';
        SELECT   nvl(max(sequence_num)+1, 1)
        INTO     x_sequence_num
        FROM     po_asl_documents
        WHERE    asl_id = x_asl_id
        AND      using_organization_id = -1;


        x_progress := '040';
        fnd_file.put_line(fnd_file.log, 'Upgrading source document.');
        fnd_file.put_line(fnd_file.log, 'DOCUMENT_TYPE_CODE = '||x_document_type_code);
        fnd_file.put_line(fnd_file.log, 'DOCUMENT_ID = '||x_document_header_id);

        INSERT INTO PO_ASL_DOCUMENTS(
                asl_id,
                using_organization_id,
                sequence_num,
                document_type_code,
                document_header_id,
                document_line_id,
                last_update_date,
                last_updated_by,
                last_update_login,
                creation_date,
                created_by,
                org_id
        ) VALUES (
                x_asl_id,
                -1,
                x_sequence_num,
                x_document_type_code,
                x_document_header_id,
                x_document_line_id,
                x_last_update_date,
                x_last_updated_by,
                x_last_update_login,
                x_creation_date,
                x_created_by,
                x_org_id
        );

/*
        -- If the ASL entry was created in the upgrade process, then get
        -- the release generation method from the top-ranked source document.

        IF (x_new_asl AND x_sequence_num = 1
            AND x_doc_generation_method IS NOT NULL) THEN

            x_progress := '050';
            UPDATE   po_asl_attributes
            SET      release_generation_method = x_doc_generation_method,
                     last_updated_by = x_last_updated_by,
                     last_update_date = x_last_update_date,
                     last_update_login = x_last_update_login
            WHERE    asl_id = x_asl_id
            AND      using_organization_id = -1;

        END IF;
*/
      END IF;

  END LOOP;
  CLOSE C;

EXCEPTION
    WHEN OTHERS THEN
        fnd_file.put_line(fnd_file.log,  '** Exception in upgrade_asl_documents');
        fnd_file.put_line(fnd_file.log, 'x_progress = '||x_progress);
        PO_MESSAGE_S.SQL_ERROR('UPGRADE_ASL_DOCUMENTS', x_progress, sqlcode);
END;



END PO_ASL_UPGRADE_SV2;

/
