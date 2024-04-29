--------------------------------------------------------
--  DDL for Package Body PO_TAX_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_TAX_INTERFACE_PVT" AS
/* $Header: PO_TAX_INTERFACE_PVT.plb 120.59.12010000.32 2014/10/31 17:22:14 chihchan ship $ */
G_PACKAGE_NAME CONSTANT VARCHAR2(30) := 'PO_TAX_INTERFACE_PVT';

-- Logging global constants
D_PACKAGE_BASE CONSTANT VARCHAR2(100) := PO_LOG.get_package_base(G_PACKAGE_NAME);

-- Private procedure declarations
PROCEDURE populate_zx_headers_with_po(p_po_header_id_tbl  IN  PO_TBL_NUMBER,
                                      p_calling_program   IN  VARCHAR2);

PROCEDURE populate_header_po(p_po_header_id  IN  NUMBER);

PROCEDURE populate_zx_headers_with_rel(p_po_release_id_tbl  IN  PO_TBL_NUMBER,
                                       p_calling_program    IN  VARCHAR2);

PROCEDURE populate_header_rel(p_po_release_id  IN  NUMBER);

PROCEDURE populate_zx_headers_with_req(p_requisition_header_id  IN  NUMBER,
                                       p_calling_program        IN  VARCHAR2);

PROCEDURE populate_zx_lines_with_po(p_po_header_id_tbl  IN  PO_TBL_NUMBER,
                                    p_calling_program   IN  VARCHAR2);

PROCEDURE populate_zx_lines_with_rel(p_po_release_id_tbl  IN  PO_TBL_NUMBER,
                                     p_calling_program    IN  VARCHAR2);

PROCEDURE populate_zx_lines_with_req(p_requisition_header_id  IN  NUMBER,
                                     p_calling_program        IN  VARCHAR2);

PROCEDURE populate_zx_dists_with_po(p_po_header_id_tbl  IN  PO_TBL_NUMBER,
                                    p_calling_program   IN  VARCHAR2);

PROCEDURE populate_all_dists_po(p_po_header_id  IN  NUMBER);

PROCEDURE populate_zx_dists_with_rel(p_po_release_id_tbl  IN  PO_TBL_NUMBER,
                                     p_calling_program    IN  VARCHAR2);

 -- Bug 11665348
PROCEDURE populate_zx_lines_with_po_cal(p_po_header_id_tbl  IN  PO_TBL_NUMBER,
                                    p_calling_program   IN  VARCHAR2);

PROCEDURE populate_zx_lines_with_rel_cal(p_po_release_id_tbl  IN  PO_TBL_NUMBER,
                                     p_calling_program    IN  VARCHAR2);
  -- Bug 11665348


PROCEDURE populate_all_dists_rel(p_po_release_id IN NUMBER);

PROCEDURE populate_zx_dists_with_req(p_requisition_header_id  IN  NUMBER,
                                     p_calling_program        IN  VARCHAR2);

PROCEDURE populate_zx_record(p_requisition_header_id  IN  NUMBER);

PROCEDURE initialize_zx_gt_tables;

PROCEDURE wipe_zx_gt_tables;

PROCEDURE log_header_tax_attributes(p_module_base IN VARCHAR2,
                                    p_progress    IN NUMBER);

PROCEDURE log_line_tax_attributes(p_module_base IN VARCHAR2,
                                  p_progress    IN NUMBER);

PROCEDURE log_dist_tax_attributes(p_module_base IN VARCHAR2,
                                  p_progress    IN NUMBER);

PROCEDURE log_po_tauc(p_module_base      IN VARCHAR2,
                      p_progress         IN NUMBER,
                      p_po_header_id_tbl IN PO_TBL_NUMBER);

PROCEDURE log_rel_tauc(p_module_base       IN VARCHAR2,
                       p_progress          IN NUMBER,
                       p_po_release_id_tbl IN PO_TBL_NUMBER);

PROCEDURE log_req_tauc(p_module_base           IN VARCHAR2,
                       p_progress              IN NUMBER,
                       p_requisition_header_id IN NUMBER);

PROCEDURE log_global_error_record(p_module_base           IN VARCHAR2,
                                  p_progress              IN NUMBER);

-- BUG# 18641338 fix starts
PROCEDURE update_non_tax_det_attrs_only(p_po_header_id_tbl  IN          PO_TBL_NUMBER,
                                        p_po_session_gt_key IN          PO_SESSION_GT.key%TYPE,
                                        x_return_status     OUT NOCOPY  VARCHAR2);

PROCEDURE log_sync_trx_records(p_module_base        IN VARCHAR2,
                               p_progress           IN NUMBER,
                               p_sync_trx_rec       IN ZX_API_PUB.sync_trx_rec_type,
                               p_sync_trx_lines_tbl IN ZX_API_PUB.sync_trx_lines_tbl_type%type);
-- BUG# 18641338 fix ends

CURSOR successful_documents_csr(p_requisition_header_id IN NUMBER) IS
  SELECT zxlgt.trx_line_id
  FROM zx_transaction_lines_gt zxlgt
  WHERE p_requisition_header_id=zxlgt.trx_id
  AND p_requisition_header_id NOT IN (SELECT trx_id FROM zx_errors_gt zxegt)
  AND zxlgt.application_id = PO_CONSTANTS_SV.APPLICATION_ID
  AND zxlgt.entity_code = PO_CONSTANTS_SV.REQ_ENTITY_CODE
  AND zxlgt.event_class_code = PO_CONSTANTS_SV.REQ_EVENT_CLASS_CODE;


-----------------------------------------------------------------------------
--Start of Comments
--Name: calculate_tax
--Pre-reqs:
--  Should be called when transaction data has been posted to the database
--  but not yet committed
--Modifies:
--  PO_LINE_LOCATIONS_ALL.tax_attribute_update_code
--  PO_LINE_LOCATIONS_ALL.original_shipment_id
--  PO_LINE_LOCATIONS_ALL.taxable_flag
--  PO_DISTRIBUTIONS_ALL.nonrecoverable_tax
--  PO_DISTRIBUTIONS_ALL.recoverable_tax
--Locks:
--  Transaction tables if update is allowed
--Function:
--  Calculate tax amounts for the documents passed in
--Parameters:
--IN:
--p_po_header_id_tbl
--  Table of po_header_id values for which tax is to be calculated
--p_po_release_id_tbl
--  Table of po_release_id values for which tax is to be calculated
--p_calling_program
--  Identifies the module that calls this procedure eg. 'PDOI'
--OUT:
--x_return_status
--  Standard API specification parameter
--  Can hold one of the following values:
--    FND_API.G_RET_STS_SUCCESS (='S')
--    FND_API.G_RET_STS_ERROR (='E')
--    FND_API.G_RET_STS_UNEXP_ERROR (='U')
--Notes:
--  1. Calls out to EBTax APIs calculate_tax and determine recovery to
--   generate tax lines and distributions. Populates recoverable_tax and
--   nonrecoverable_tax columns in distributions with the corrsponding tax
--   amounts calculated.
--  2. Returns all expected errors from etax API's in global tax error record
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE calculate_tax(p_po_header_id_tbl    IN          PO_TBL_NUMBER,
                        p_po_release_id_tbl   IN          PO_TBL_NUMBER,
                        p_calling_program     IN          VARCHAR2,
                        x_return_status       OUT NOCOPY  VARCHAR2
) IS
  l_module_name CONSTANT VARCHAR2(100) := 'CALCULATE_TAX';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(
                                            D_PACKAGE_BASE, l_module_name);
  d_progress NUMBER;
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(1000);
  l_count NUMBER;
  l_return_status VARCHAR2(1);
  l_po_session_gt_key PO_SESSION_GT.key%TYPE;
  l_transaction_line_rec_type ZX_API_PUB.transaction_line_rec_type;
BEGIN
  --          PO_SESSION_GT mappings:
  --------------------------------------------------
  --     /  INDEX_NUM1 = trx_id            \
  --    /   NUM1       = trx_line_id        \
  --   /    NUM2       = trx_line_dist_id    \
  --  /     CHAR1      = event_class_code     \
  --  \     CHAR2      = message_text         /
  --   \    CHAR3      = error_level         /
  --    \   CHAR4      = trx_num            /
  --     \                                 /

  SAVEPOINT calculate_tax_savepoint;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'p_po_header_id_tbl', p_po_header_id_tbl);
    PO_LOG.proc_begin(d_module_base, 'p_po_release_id_tbl', p_po_release_id_tbl);
    PO_LOG.proc_begin(d_module_base, 'p_calling_program', p_calling_program);
  END IF;

  d_progress := 0;

  -- By default return status is SUCCESS if no exception occurs
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Set global error record to uninitialized local record to set all its
  -- components to null
  G_TAX_ERRORS_TBL := null;
  d_progress := 10;
  initialize_zx_gt_tables(); -- Wipe ZX GT tables clean
  d_progress := 20;
  initialize_global_error_record();
  d_progress := 30;
  SELECT po_session_gt_s.NEXTVAL INTO l_po_session_gt_key FROM dual;

  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_module_base,d_progress,'l_po_session_gt_key='||l_po_session_gt_key);
  END IF;

  d_progress := 40;
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_module_base,d_progress,'initial values of tax_attribute_update_codes');
    log_po_tauc(d_module_base,d_progress,p_po_header_id_tbl);
    log_rel_tauc(d_module_base,d_progress,p_po_release_id_tbl);
  END IF;

  -- Percolate header and line level tax_attribute_update_code values to
  -- shipment level so that the shipment level values get filled up

  -- 1. If shipment tax_attribute_update_code is anything other than null
  -- or DIST_DELETE then don't update (note that even if it is DIST_DELETE,
  -- it will be overridden by line or headers value - last where clause
  -- 2. If both line and header level tax_attribute_update_code are null
  -- then keep the shipment level value. So the inner query is wrapped
  -- inside an nvl that rewrites the shipment tax_attribute_update_code
  -- if the shipment tax_attribute_update_code is being updated to null
  -- 3. If none of the above problems exist then update shipment
  -- tax_attribute_update_code with line or header tax_attribute_update_code
  -- whichever is non-null in that order
  -- 4.
   /* Bug 13925912: When tax determining attribute is changed only at distribution level corresponding
    shipment's tax_attribute_update_code is not updated and thus no records are inserted into
    zx_transaction_lines_gt and no call is being made to ZX calculate_tax API. Updating shipments
    tax_attribute_update_code accordingly to overcome above issue */

FORALL i IN 1..p_po_header_id_tbl.COUNT
   UPDATE   po_line_locations_all pll
   SET   pll.tax_attribute_update_code =
            NVL ((SELECT NVL (
            (SELECT  pod.tax_attribute_update_code
                            FROM   po_distributions_all pod
                           WHERE   pod.tax_attribute_update_code = 'UPDATE'
                             AND pod.line_location_id = pll.line_location_id
                             AND ROWNUM = 1),
                            NVL (pl.tax_attribute_update_code,
                                 ph.tax_attribute_update_code))
                  FROM   po_headers_all ph,
                         po_lines_all pl
                 WHERE       pll.po_line_id = pl.po_line_id
                         AND pll.po_header_id = ph.po_header_id
               ),
               pll.tax_attribute_update_code
            )
 WHERE   pll.po_header_id = p_po_header_id_tbl(i)
         AND (pll.tax_attribute_update_code IS NULL
              OR pll.tax_attribute_update_code = 'DIST_DELETE');

  d_progress := 50;
  FORALL i IN 1..p_po_release_id_tbl.COUNT
    UPDATE po_line_locations_all pll
    SET pll.tax_attribute_update_code =
      NVL(
        (SELECT NVL (
            (SELECT  pod.tax_attribute_update_code
                            FROM   po_distributions_all pod
                           WHERE   pod.tax_attribute_update_code = 'UPDATE'
                             AND pod.line_location_id = pll.line_location_id
                             AND ROWNUM = 1), pr.tax_attribute_update_code)
         FROM po_releases_all pr
         WHERE pll.po_release_id = pr.po_release_id
         -- following AND written only for clarity
         --AND ph.tax_attribute_update_code IS NOT NULL
        )
        ,pll.tax_attribute_update_code
      )
    WHERE
    pll.po_release_id = p_po_release_id_tbl(i)
    AND (pll.tax_attribute_update_code IS NULL
         OR pll.tax_attribute_update_code = 'DIST_DELETE');

    -- Replaced po_headers_all with po_releases_all for releases case.
    -- End bug 13925912

  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_module_base,d_progress,'tax_attribute_update_codes after denormalization');
    log_po_tauc(d_module_base,d_progress,p_po_header_id_tbl);
    log_rel_tauc(d_module_base,d_progress,p_po_release_id_tbl);
  END IF;

  -- Populate ZX headers and lines GT tables with transaction data
  d_progress := 60;
  populate_zx_headers_with_po(p_po_header_id_tbl, p_calling_program);
  d_progress := 70;
  populate_zx_headers_with_rel(p_po_release_id_tbl, p_calling_program);
  d_progress := 80;
  populate_zx_lines_with_po(p_po_header_id_tbl, p_calling_program);
  d_progress := 90;
  populate_zx_lines_with_rel(p_po_release_id_tbl, p_calling_program);

  d_progress := 100;
  -- Call eTax API calculate_tax to construct tax lines
  -- For lines wih line_level_action of COPY_AND_CREATE eTax will use
  -- Additional Tax Attributes from source doucment to create the tax lines
  BEGIN
    SELECT COUNT(1) INTO l_count FROM zx_transaction_lines_gt;
  EXCEPTION WHEN OTHERS THEN
    l_count := 0;
    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module_base,d_progress,'Exception while selecting from zx_transaction_lines_gt');
    END IF;
  END;

  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_module_base,d_progress,'Number of rows in zx_transaction_lines_gt='||l_count);
  END IF;

  IF (l_count <> 0) THEN

    d_progress := 110;
    -- Log table parameters
    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module_base,d_progress,'Table parameters before eTax default/redefault');
      log_header_tax_attributes(d_module_base,d_progress);
      log_line_tax_attributes(d_module_base,d_progress);
    END IF;

    -- Call the eTax defaulting/redefaulting APIs which populate the
    -- Additional Tax Attributes back into the ZX GT tables
    IF (p_calling_program = 'PDOI') THEN
      d_progress := 120;
      -- For PDOI, eTax needs to do extra validations since data is entered by
      -- user in interface tables. So call validate_and_default_tax_attribs
      -- Only need to default, not redefault because through PDOI POs can only
      -- be added to, not updated
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,d_progress,'Calling validate_and_default_tax_attr');
      END IF;
      ZX_API_PUB.validate_and_default_tax_attr(
        p_api_version           =>  1.0,
        p_init_msg_list         =>  FND_API.G_TRUE,
        p_commit                =>  FND_API.G_FALSE,
        p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL,
        x_return_status         =>  l_return_status,
        x_msg_count             =>  l_msg_count,
        x_msg_data              =>  l_msg_data
      );

      d_progress := 130;
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,d_progress,'validate_and_default_tax_attr returned with status '||l_return_status);
      END IF;

      -- Raise if any unexpected error
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- If expected errors, store error details in po_session_gt temporarily
      IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        d_progress := 140;
        x_return_status := l_return_status;
        INSERT INTO po_session_gt(
          key
          ,index_num1
          ,num1
          ,num2
          ,char1
          ,char2
          ,char3
          ,char4
        )
        SELECT
          l_po_session_gt_key
          ,zxvegt.trx_id
          ,zxvegt.trx_line_id
          ,null
          ,zxvegt.event_class_code
          ,zxvegt.message_text
          ,'VALIDATE'
          ,ph.segment1
        FROM zx_validation_errors_gt zxvegt, po_headers_all ph
        WHERE zxvegt.event_class_code = PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE
        AND zxvegt.trx_id = ph.po_header_id;

        d_progress := 150;
        INSERT INTO po_session_gt(
          key
          ,index_num1
          ,num1
          ,num2
          ,char1
          ,char2
          ,char3
          ,char4
        )
        SELECT
          l_po_session_gt_key
          ,zxvegt.trx_id
          ,zxvegt.trx_line_id
          ,null
          ,zxvegt.event_class_code
          ,zxvegt.message_text
          ,'VALIDATE'
          ,ph.segment1
        FROM zx_validation_errors_gt zxvegt, po_headers_all ph,
             po_releases_all pr
        WHERE zxvegt.event_class_code = PO_CONSTANTS_SV.REL_EVENT_CLASS_CODE
        AND zxvegt.trx_id = pr.po_release_id
        AND pr.po_header_id = ph.po_header_id;

        BEGIN
          SELECT COUNT(1) INTO l_count FROM zx_validation_errors_gt;
        EXCEPTION WHEN OTHERS THEN
          IF PO_LOG.d_stmt THEN
            PO_LOG.stmt(d_module_base,d_progress,'Exception while hitting zx_validation_errors_gt');
          END IF;
          l_count := 0;
        END;

        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,d_progress,'Number of records in zx_validation_errors_gt '||l_count);
        END IF;

      -- Bug 12907158
      RAISE FND_API.G_EXC_ERROR;

      END IF;

      d_progress := 160;
      -- Delete data from zx gt tables for which defaulting/redefaulting failed
      DELETE FROM zx_trx_headers_gt
      WHERE trx_id IN (SELECT DISTINCT index_num1 FROM po_session_gt psgt
                       WHERE psgt.key = l_po_session_gt_key
                       AND psgt.char1 = PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE);
      d_progress := 170;
      DELETE FROM zx_transaction_lines_gt
      WHERE trx_id IN (SELECT DISTINCT index_num1 FROM po_session_gt psgt
                       WHERE psgt.key = l_po_session_gt_key
                       AND psgt.char1 = PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE);

    ELSIF (p_calling_program <> 'COPY_DOCUMENT') THEN
      d_progress := 180;
      -- This API cannot handle the presence of COPY_AND_CREATE line level
      -- actions so call is prevented if calling program is COPY_DOCUMENT
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,d_progress,'Calling get_default_tax_det_attribs');
      END IF;
      ZX_API_PUB.get_default_tax_det_attribs(
        p_api_version           =>  1.0,
        p_init_msg_list         =>  FND_API.G_TRUE,
        p_commit                =>  FND_API.G_FALSE,
        p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL,
        x_return_status         =>  l_return_status,
        x_msg_count             =>  l_msg_count,
        x_msg_data              =>  l_msg_data
      );

      d_progress := 190;
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,d_progress,'get_default_tax_det_attribs returned with status '||l_return_status);
      END IF;

      -- This API cannot give expected errors. However raise unexpected errors
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END IF; -- IF (p_calling_program = 'PDOI')

   -- Bug 11665348
  END IF;    -- IF (l_count <> 0)


    -- Populate ZX headers and lines GT tables with transaction data
  d_progress := 196;
  populate_zx_lines_with_po_cal(p_po_header_id_tbl, p_calling_program);
  d_progress := 198;
  populate_zx_lines_with_rel_cal(p_po_release_id_tbl, p_calling_program);

  BEGIN
    SELECT COUNT(1) INTO l_count FROM zx_transaction_lines_gt;
  EXCEPTION WHEN OTHERS THEN
    l_count := 0;
    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module_base,d_progress,'Exception while selecting from zx_transaction_lines_gt');
    END IF;
  END;

  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_module_base,d_progress,'Number of rows in zx_transaction_lines_gt='||l_count);
  END IF;

   IF (l_count <> 0) THEN

   -- End bug 11665348

    d_progress := 200;
    -- Override product_type Additional Tax Attribute if not already populated
    -- by eTax defaulting/redefaulting API
    UPDATE zx_transaction_lines_gt zxlgt
    SET zxlgt.product_type =
      (SELECT DECODE(pl.purchase_basis,
                     'GOODS', 'GOODS',
                     'SERVICES')
       FROM po_line_locations_all pll, po_lines_all pl
       WHERE pll.line_location_id = zxlgt.trx_line_id
       AND pll.po_line_id = pl.po_line_id)
    WHERE zxlgt.product_type IS NULL
    AND zxlgt.line_level_action = 'CREATE';

    d_progress := 210;

    -- Log table parameters
    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module_base,d_progress,'Table parameters before calculate_tax');
      log_header_tax_attributes(d_module_base,d_progress);
      log_line_tax_attributes(d_module_base,d_progress);
    END IF;

    ZX_API_PUB.calculate_tax(
      p_api_version           =>  1.0,
      p_init_msg_list         =>  FND_API.G_TRUE,
      p_commit                =>  FND_API.G_FALSE,
      p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL,
      x_return_status         =>  l_return_status,
      x_msg_count             =>  l_msg_count,
      x_msg_data              =>  l_msg_data
    );

    d_progress := 220;
    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module_base,d_progress,'calculate_tax returned with status '||l_return_status);
    END IF;

    -- Raise if any unexpected error
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- If expected errors, store error details in po_session_gt temporarily
    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      x_return_status := l_return_status;
      d_progress := 230;
      INSERT INTO po_session_gt(
        key
        ,index_num1
        ,num1
        ,num2
        ,char1
        ,char2
        ,char3
        ,char4
      )
      SELECT
        l_po_session_gt_key
        ,zxegt.trx_id
        ,zxegt.trx_line_id
        ,zxegt.trx_line_dist_id
        ,zxegt.event_class_code
        ,zxegt.message_text
        ,'CALCULATE_TAX'
        ,ph.segment1
      FROM zx_errors_gt zxegt, po_headers_all ph
      WHERE zxegt.event_class_code = PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE
      AND zxegt.trx_id = ph.po_header_id;

      d_progress := 240;
      INSERT INTO po_session_gt(
        key
        ,index_num1
        ,num1
        ,num2
        ,char1
        ,char2
        ,char3
        ,char4
      )
      SELECT
        l_po_session_gt_key
        ,zxegt.trx_id
        ,zxegt.trx_line_id
        ,zxegt.trx_line_dist_id
        ,zxegt.event_class_code
        ,zxegt.message_text
        ,'CALCULATE_TAX'
        ,ph.segment1
      FROM zx_errors_gt zxegt, po_headers_all ph, po_releases_all pr
      WHERE zxegt.event_class_code = PO_CONSTANTS_SV.REL_EVENT_CLASS_CODE
      AND zxegt.trx_id = pr.po_release_id
      AND pr.po_header_id = ph.po_header_id;

      BEGIN
        SELECT COUNT(1) INTO l_count FROM zx_errors_gt;
      EXCEPTION WHEN OTHERS THEN
        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,d_progress,'Exception while hitting zx_errors_gt');
        END IF;
        l_count := 0;
      END;

    -- Bug 12907158
    RAISE FND_API.G_EXC_ERROR;


      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,d_progress,'Number of records in zx_errors_gt '||l_count);
      END IF;

    /* Bug#12317965: ZX_LINE_DET_FACTORS should not have records inserted, in case
                     the tax lines insertion in to ZX_LINES fails. */
    d_progress := 245;
    ROLLBACK TO SAVEPOINT calculate_tax_savepoint;

    END IF;

    d_progress := 250;
    -- Delete data from zx gt tables for which defaulting/redefaulting failed
    DELETE FROM zx_trx_headers_gt
    WHERE trx_id IN (SELECT DISTINCT index_num1 FROM po_session_gt psgt
                     WHERE psgt.key = l_po_session_gt_key
                     AND psgt.char1 = PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE
                     AND psgt.char3 = 'CALCULATE_TAX');
    d_progress := 260;
    DELETE FROM zx_trx_headers_gt
    WHERE trx_id IN (SELECT DISTINCT index_num1 FROM po_session_gt psgt
                     WHERE psgt.key = l_po_session_gt_key
                     AND psgt.char1 = PO_CONSTANTS_SV.REL_EVENT_CLASS_CODE
                     AND psgt.char3 = 'CALCULATE_TAX');
    d_progress := 270;
    DELETE FROM zx_transaction_lines_gt
    WHERE trx_id IN (SELECT DISTINCT index_num1 FROM po_session_gt psgt
                     WHERE psgt.key = l_po_session_gt_key
                     AND psgt.char1 = PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE
                     AND psgt.char3 = 'CALCULATE_TAX');
    d_progress := 280;
    DELETE FROM zx_transaction_lines_gt
    WHERE trx_id IN (SELECT DISTINCT index_num1 FROM po_session_gt psgt
                     WHERE psgt.key = l_po_session_gt_key
                     AND psgt.char1 = PO_CONSTANTS_SV.REL_EVENT_CLASS_CODE
                     AND psgt.char3 = 'CALCULATE_TAX');

  END IF; -- IF (l_count <> 0)

  d_progress := 290;
  -- Populate ZX distributions GT table with transaction distribution data
  populate_zx_dists_with_po(p_po_header_id_tbl, p_calling_program);
  d_progress := 300;
  populate_zx_dists_with_rel(p_po_release_id_tbl, p_calling_program);

  d_progress := 310;
  -- Call eTax API determine_recovery to distribute tax lines
  BEGIN
    SELECT COUNT(1) INTO l_count FROM zx_itm_distributions_gt;
  EXCEPTION WHEN OTHERS THEN
    l_count := 0;
    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module_base,d_progress,'Exception while selecting from zx_itm_distributions_gt');
    END IF;
  END;

  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_module_base,d_progress,'Number of rows in zx_itm_distributions_gt='||l_count);
  END IF;

  IF (l_count <> 0) THEN
    d_progress := 320;
    -- Update event_type_code on zx headers as required by determine_recovery API
    -- Update to DISTRIBUTED only if all distributions have
    -- tax_attribute_update_code = 'CREATE'
    UPDATE zx_trx_headers_gt zxhgt
    SET zxhgt.event_type_code =
      DECODE(zxhgt.event_class_code,
             PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE,
               NVL2((SELECT 'EXISTING DISTRIBUTIONS'
                     FROM DUAL
                     WHERE EXISTS
                       (SELECT 'Y'
                        FROM po_distributions_all pd
                        WHERE pd.po_header_id = zxhgt.trx_id
                        AND (pd.tax_attribute_update_code <> 'CREATE'
                             OR pd.tax_attribute_update_code IS NULL)
                       )
                    ),
                    PO_CONSTANTS_SV.PO_REDISTRIBUTED,
                    PO_CONSTANTS_SV.PO_DISTRIBUTED
                   ),
             --Release
             NVL2((SELECT 'EXISTING DISTRIBUTIONS'
                   FROM DUAL
                   WHERE EXISTS
                     (SELECT 'Y'
                      FROM po_distributions_all pd
                      WHERE pd.po_release_id = zxhgt.trx_id
                      AND (pd.tax_attribute_update_code <> 'CREATE'
                           OR pd.tax_attribute_update_code IS NULL)
                     )
                  ),
                  PO_CONSTANTS_SV.REL_REDISTRIBUTED,
                  PO_CONSTANTS_SV.REL_DISTRIBUTED
                 )
            );

    d_progress := 330;

    -- Log table parameters
    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module_base,d_progress,'Table parameters before determine_recovery');
      log_header_tax_attributes(d_module_base,d_progress);
      log_line_tax_attributes(d_module_base,d_progress);
      log_dist_tax_attributes(d_module_base,d_progress);
    END IF;

    ZX_API_PUB.determine_recovery(
      p_api_version           =>  1.0,
      p_init_msg_list         =>  FND_API.G_TRUE,
      p_commit                =>  FND_API.G_FALSE,
      p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL,
      x_return_status         =>  l_return_status,
      x_msg_count             =>  l_msg_count,
      x_msg_data              =>  l_msg_data
    );

    d_progress := 340;
    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module_base,d_progress,'determine_recovery returned with status '||l_return_status);
    END IF;

    -- Raise if any unexpected error
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- If expected errors, store error details in po_session_gt temporarily
    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      x_return_status := l_return_status;
      d_progress := 350;
      INSERT INTO po_session_gt(
        key
        ,index_num1
        ,num1
        ,num2
        ,char1
        ,char2
        ,char3
        ,char4
      )
      SELECT
        l_po_session_gt_key
        ,zxegt.trx_id
        ,zxegt.trx_line_id
        ,zxegt.trx_line_dist_id
        ,zxegt.event_class_code
        ,zxegt.message_text
        ,'DETERMINE_RECOVERY'
        ,ph.segment1
      FROM zx_errors_gt zxegt, po_headers_all ph
      WHERE zxegt.event_class_code = PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE
      AND zxegt.trx_id = ph.po_header_id;

      d_progress := 360;
      INSERT INTO po_session_gt(
        key
        ,index_num1
        ,num1
        ,num2
        ,char1
        ,char2
        ,char3
        ,char4
      )
      SELECT
        l_po_session_gt_key
        ,zxegt.trx_id
        ,zxegt.trx_line_id
        ,zxegt.trx_line_dist_id
        ,zxegt.event_class_code
        ,zxegt.message_text
        ,'DETERMINE_RECOVERY'
        ,ph.segment1
      FROM zx_errors_gt zxegt, po_headers_all ph, po_releases_all pr
      WHERE zxegt.event_class_code = PO_CONSTANTS_SV.REL_EVENT_CLASS_CODE
      AND zxegt.trx_id = pr.po_release_id
      AND pr.po_header_id = ph.po_header_id;

      d_progress := 370;
      BEGIN
        SELECT COUNT(1) INTO l_count FROM zx_errors_gt;
      EXCEPTION WHEN OTHERS THEN
        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,d_progress,'Exception while hitting zx_errors_gt');
        END IF;
        l_count := 0;
      END;

      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,d_progress,'Number of records in zx_errors_gt '||l_count);
      END IF;

      -- Bug 5169449. Removed deletions from headers and lines gt tables
      -- because if the control has come till determine_recovery then the
      -- tax lines for the document have been calculated correctly. Hence,
      -- for failure of determine_recovery, only the tauc's at distribution
      -- level should be retained. The tauc's at header and shipment level
      -- should be nulled out otherwise the header and line level action will
      -- get passed as CREATE in the next tax calculation (ie at the time of
      -- approve)
      d_progress := 380;
      DELETE FROM zx_itm_distributions_gt
      WHERE trx_id IN (SELECT DISTINCT index_num1 FROM po_session_gt psgt
                       WHERE psgt.key = l_po_session_gt_key
                       AND psgt.char1 = PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE
                       AND psgt.char3 = 'DETERMINE_RECOVERY');
      d_progress := 390;
      DELETE FROM zx_itm_distributions_gt
      WHERE trx_id IN (SELECT DISTINCT index_num1 FROM po_session_gt psgt
                       WHERE psgt.key = l_po_session_gt_key
                       AND psgt.char1 = PO_CONSTANTS_SV.REL_EVENT_CLASS_CODE
                       AND psgt.char3 = 'DETERMINE_RECOVERY');

      d_progress := 400;
      -- Update the distributions that errored out and yet have a tauc of null
      -- If this is not done, it is possible that all dist tauc's for a
      -- document get nulled out and hence tax redistribution does not take
      -- place despite determine_recovery erroring out for some of them
      UPDATE po_distributions_all
      SET tax_attribute_update_code = 'NO_ACTION'
      WHERE tax_attribute_update_code IS NULL
      AND po_distribution_id IN (SELECT psgt.NUM2 FROM po_session_gt psgt
                                 WHERE psgt.key = l_po_session_gt_key
                                 AND psgt.char3 = 'DETERMINE_RECOVERY');

    --Bug 12907158
    RAISE FND_API.G_EXC_ERROR;

    END IF; --IF (l_return_status = FND_API.G_RET_STS_ERROR)

    d_progress := 450;

    -- bug5650927
    -- Modified the subquery by adding a where clause so that trx_id is joined
    -- to different columns based on entity_code and event_class_code

    -- Populate recoverable/nonrecoverable tax columns in distributions table
    UPDATE po_distributions_all pd
    SET pd.recoverable_tax =
          (SELECT SUM(zxdist.rec_nrec_tax_amt)
           FROM zx_rec_nrec_dist zxdist
           WHERE zxdist.trx_line_dist_id = pd.po_distribution_id
           AND zxdist.recoverable_flag = 'Y'
           AND zxdist.application_id = PO_CONSTANTS_SV.APPLICATION_ID
           AND ( (zxdist.entity_code = PO_CONSTANTS_SV.PO_ENTITY_CODE
                  AND zxdist.event_class_code =
                        PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE
                  AND zxdist.trx_id = pd.po_header_id)
                 OR
                 (zxdist.entity_code = PO_CONSTANTS_SV.REL_ENTITY_CODE
                  AND zxdist.event_class_code =
                        PO_CONSTANTS_SV.REL_EVENT_CLASS_CODE
                  AND zxdist.trx_id = pd.po_release_id)))
       ,pd.nonrecoverable_tax =
          (SELECT SUM(zxdist.rec_nrec_tax_amt)
           FROM zx_rec_nrec_dist zxdist
           WHERE zxdist.trx_line_dist_id = pd.po_distribution_id
           AND zxdist.recoverable_flag = 'N'
           AND zxdist.application_id = PO_CONSTANTS_SV.APPLICATION_ID
           AND ( (zxdist.entity_code = PO_CONSTANTS_SV.PO_ENTITY_CODE
                  AND zxdist.event_class_code =
                        PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE
                  AND zxdist.trx_id = pd.po_header_id)
                 OR
                 (zxdist.entity_code = PO_CONSTANTS_SV.REL_ENTITY_CODE
                  AND zxdist.event_class_code =
                        PO_CONSTANTS_SV.REL_EVENT_CLASS_CODE
                  AND zxdist.trx_id = pd.po_release_id))),
		--Bug 10305728 start
        last_update_date = sysdate,
	    last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.login_id
        --Bug 10305728  end
    WHERE pd.po_distribution_id IN
      (SELECT trx_line_dist_id FROM zx_itm_distributions_gt);

  END IF;

  -- BUG# 18641338 fix starts
  d_progress := 455;
  update_non_tax_det_attrs_only(p_po_header_id_tbl,l_po_session_gt_key,x_return_status);
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_module_base,d_progress,'update_non_tax_det_attrs_only proc returned with status '||x_return_status);
  END IF;
  -- BUG# 18641338 fix ends

  d_progress := 460;

  -- Null out tax_attribute_update_code columns

  -- Headers and lines tables can be nulled out because they were
  -- denormalized. However in headers, the exception is where CREATE
  -- needs to be passed to eTax on PO updation as during an error occured
  -- during creation. For lines, this is not an issue because eTax requires
  -- no action for a line (while correct actions are required for header and
  -- shipment levels). So if an error occurs during creation, and user then
  -- updates a line, tax_attribute_update_code at line will be UPDATE, but
  -- shipment level tax_attribute_update_code's will be correct (because of
  -- denormalization) and will have a higher priority than those of the line
  FORALL i IN 1..p_po_header_id_tbl.COUNT
      UPDATE po_headers_all ph
      SET ph.tax_attribute_update_code = null
      WHERE ph.po_header_id = p_po_header_id_tbl(i)
      -- Bug 4774900 null out if even a single shipment has been processed
      -- correctly. That would mean that the header has been recorded
      -- in eTax, and next time we need to pass UPDATE
      AND EXISTS (SELECT 'Y'
                  FROM zx_transaction_lines_gt zxlgt
                  WHERE zxlgt.trx_id=ph.po_header_id);

  d_progress := 470;
  FORALL i IN 1..p_po_release_id_tbl.COUNT
      UPDATE po_releases_all pr
      SET pr.tax_attribute_update_code = null
      WHERE pr.po_release_id = p_po_release_id_tbl(i)
      AND EXISTS (SELECT 'Y'
                  FROM zx_transaction_lines_gt zxlgt
                  WHERE zxlgt.trx_id=pr.po_release_id);

  d_progress := 480;
  FORALL i IN 1..p_po_header_id_tbl.COUNT
      UPDATE po_lines_all
      SET tax_attribute_update_code = null
      WHERE po_header_id = p_po_header_id_tbl(i);

  d_progress := 490;

  -- bug5219124 START
  -- Separate the original update statement into two

  UPDATE po_line_locations_all
  SET tax_attribute_update_code = null,
      original_shipment_id = null,
	  last_update_date = sysdate,
      last_updated_by = fnd_global.user_id,
      last_update_login = fnd_global.login_id
  WHERE line_location_id IN (SELECT trx_line_id FROM zx_transaction_lines_gt);

  UPDATE po_line_locations_all
  SET tax_attribute_update_code = null,
      original_shipment_id = null,
	  last_update_date = sysdate,
      last_updated_by = fnd_global.user_id,
      last_update_login = fnd_global.login_id
  WHERE tax_attribute_update_code = 'DIST_DELETE'
  AND line_location_id IN (SELECT trx_line_id FROM zx_itm_distributions_gt);


  -- bug5219124 END

  d_progress := 500;
  UPDATE po_distributions_all
  SET tax_attribute_update_code = null,
      last_update_date = sysdate,
      last_updated_by = fnd_global.user_id,
      last_update_login = fnd_global.login_id
  WHERE po_distribution_id IN (SELECT trx_line_dist_id
                               FROM zx_itm_distributions_gt);

  d_progress := 510;

  -- bug5685869
  -- Add a join to zl.trx_id so that the index on zx_lines can be used
  -- more efficiently

  -- Set the taxable flag column of shipments which have tax lines
  UPDATE po_line_locations_all pll
  SET pll.taxable_flag =
    DECODE((SELECT COUNT(1) FROM zx_lines zl
            WHERE zl.trx_line_id = pll.line_location_id
            AND zl.application_id = PO_CONSTANTS_SV.APPLICATION_ID
            AND ( (zl.entity_code = PO_CONSTANTS_SV.PO_ENTITY_CODE
                   AND zl.event_class_code = PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE
                   AND zl.trx_id = pll.po_header_id)
                  OR
                  (zl.entity_code = PO_CONSTANTS_SV.REL_ENTITY_CODE
                   AND zl.event_class_code = PO_CONSTANTS_SV.REL_EVENT_CLASS_CODE
                   AND zl.trx_id = pll.po_release_id))),
           0, 'N',
           'Y'
          ),
	  last_update_date = sysdate,
      last_updated_by = fnd_global.user_id,
      last_update_login = fnd_global.login_id
  WHERE
    pll.line_location_id IN (SELECT trx_line_id FROM zx_transaction_lines_gt);


  d_progress := 520;
  -- Pour all errors in po_session_gt into global tax error record
  SELECT
    psgt.char3 --error_level
    ,decode(psgt.char1,--document_type_code
            PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE, PO_CONSTANTS_SV.PO,
            PO_CONSTANTS_SV.REL_EVENT_CLASS_CODE, PO_CONSTANTS_SV.RELEASE
           )
    ,psgt.index_num1 --document_id
    ,psgt.char4 --document_num
    ,null --line_id
    ,null --line_num
    ,pll.line_location_id --line_location_id
    ,pll.shipment_num --shipment_num
    ,pd.po_distribution_id --distribution_id
    ,pd.distribution_num --distribution_num
    ,psgt.char2 --message_text
  BULK COLLECT INTO G_TAX_ERRORS_TBL
  FROM po_session_gt psgt, po_line_locations_all pll, po_distributions_all pd
  WHERE psgt.num1 = pll.line_location_id
  AND psgt.num2 = pd.po_distribution_id(+)
  AND psgt.key = l_po_session_gt_key;

  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_module_base,d_progress,'Number of error records collected '||G_TAX_ERRORS_TBL.error_level.COUNT);
    log_global_error_record(d_module_base, d_progress);
  END IF;

  -- Bug 5363122. Wipe out ZX GT tables at the end of tax call
  wipe_zx_gt_tables();

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module_base);
    PO_LOG.proc_end(d_module_base, 'x_return_status', x_return_status);
  END IF;
  d_progress := 540;

EXCEPTION

/* Bug 12907158: Raise the expected error and collect the data into
               G_TAX_ERRORS_TBL so that they can be processed. */

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;


     SELECT
    psgt.char3 --error_level
    ,decode(psgt.char1,--document_type_code
            PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE, PO_CONSTANTS_SV.PO,
            PO_CONSTANTS_SV.REL_EVENT_CLASS_CODE, PO_CONSTANTS_SV.RELEASE
           )
    ,psgt.index_num1 --document_id
    ,psgt.char4 --document_num
    ,null --line_id
    ,null --line_num
    ,pll.line_location_id --line_location_id
    ,pll.shipment_num --shipment_num
    ,pd.po_distribution_id --distribution_id
    ,pd.distribution_num --distribution_num
    ,psgt.char2 --message_text
  BULK COLLECT INTO G_TAX_ERRORS_TBL
  FROM po_session_gt psgt, po_line_locations_all pll, po_distributions_all pd
  WHERE psgt.index_num1 = pll.po_header_id
  AND pll.line_location_id = pd.line_location_id
  AND psgt.key = l_po_session_gt_key;

  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_module_base,d_progress,'Number of error records collected '||G_TAX_ERRORS_TBL.error_level.COUNT);
    log_global_error_record(d_module_base, d_progress);
  END IF;

   ROLLBACK TO SAVEPOINT calculate_tax_savepoint;

  -- end Bug 12907158

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    ROLLBACK TO SAVEPOINT calculate_tax_savepoint;

    -- Initialize to flush out expected errors if any
    initialize_global_error_record();
    -- Add a new error
    append_error(p_error_level => null,
                 p_document_type_code => null,
                 p_document_id => null,
                 p_document_num => null,
                 p_line_id => null,
                 p_line_num => null,
                 p_line_location_id => null,
                 p_shipment_num => null,
                 p_distribution_id => null,
                 p_distribution_num => null,
                 p_message_text => l_msg_data);

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module_base, d_progress, l_msg_data);
      PO_LOG.proc_end(d_module_base, 'x_return_status', x_return_status);
    END IF;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    ROLLBACK TO SAVEPOINT calculate_tax_savepoint;

    -- Initialize to flush out expected errors if any
    initialize_global_error_record();
    -- Add a new error
    append_error(p_error_level => null,
                 p_document_type_code => null,
                 p_document_id => null,
                 p_document_num => null,
                 p_line_id => null,
                 p_line_num => null,
                 p_line_location_id => null,
                 p_shipment_num => null,
                 p_distribution_id => null,
                 p_distribution_num => null,
                 p_message_text => d_module_base||'#'||d_progress||':'
                                   ||SQLCODE || SQLERRM);

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module_base, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module_base, 'x_return_status', x_return_status);
    END IF;

END calculate_tax;


-----------------------------------------------------------------------------
--Start of Comments
--Name: calculate_tax
--Pre-reqs:
--  Should be called when transaction data has been posted to the database
--  but not yet committed
--Modifies:
--  PO_LINE_LOCATIONS_ALL.tax_attribute_update_code
--  PO_LINE_LOCATIONS_ALL.original_shipment_id
--  PO_LINE_LOCATIONS_ALL.taxable_flag
--  PO_DISTRIBUTIONS_ALL.nonrecoverable_tax
--  PO_DISTRIBUTIONS_ALL.recoverable_tax
--Locks:
--  Transaction tables if update is allowed
--Function:
--  Calculate tax amounts for the documents passed in
--Parameters:
--IN:
--p_po_header_id
--  po_header_id of the PO for which tax is to be calculated
--p_po_release_id
--  po_release_id of the Releasefor which tax is to be calculated
--p_calling_program
--  Identifies the module that calls this procedure eg. 'PDOI'
--OUT:
--x_return_status
--  Standard API specification parameter
--  Can hold one of the following values:
--    FND_API.G_RET_STS_SUCCESS (='S')
--    FND_API.G_RET_STS_ERROR (='E')
--    FND_API.G_RET_STS_UNEXP_ERROR (='U')
--Notes:
--  1. Wrapper procedure that calls its overloaded bulk version
--   Called from forms (where passing a pl/sql table from client side is not
--   possible and other modules where only a single document is processed
--   at a time
--  2. Returns all expected errors from etax API's in global tax error record
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE calculate_tax(p_po_header_id        IN          NUMBER,
                        p_po_release_id       IN          NUMBER,
                        p_calling_program     IN          VARCHAR2,
                        x_return_status       OUT NOCOPY  VARCHAR2
) IS
  l_module_name CONSTANT VARCHAR2(100) := 'CALCULATE_TAX_WRAPPER';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(
                                            D_PACKAGE_BASE, l_module_name);
  d_progress NUMBER;
  l_po_header_id_tbl  PO_TBL_NUMBER;
  l_po_release_id_tbl PO_TBL_NUMBER;
BEGIN

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'p_po_header_id', p_po_header_id);
    PO_LOG.proc_begin(d_module_base, 'p_po_release_id', p_po_release_id);
    PO_LOG.proc_begin(d_module_base, 'p_calling_program', p_calling_program);
  END IF;

  d_progress := 0;

  IF (p_po_header_id IS NULL) THEN
    l_po_header_id_tbl := PO_TBL_NUMBER();
  ELSE
    l_po_header_id_tbl := PO_TBL_NUMBER(p_po_header_id);
  END IF;

  IF (p_po_release_id IS NULL) THEN
    l_po_release_id_tbl := PO_TBL_NUMBER();
  ELSE
    l_po_release_id_tbl := PO_TBL_NUMBER(p_po_release_id);
  END IF;

  calculate_tax(p_po_header_id_tbl    => l_po_header_id_tbl,
                p_po_release_id_tbl   => l_po_release_id_tbl,
                p_calling_program     => p_calling_program,
                x_return_status       => x_return_status
  );

  d_progress := 10;
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_module_base,d_progress,'PO calculate_tax returned with status '||x_return_status);
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module_base);
    PO_LOG.proc_end(d_module_base, 'x_return_status', x_return_status);
  END IF;

  d_progress := 20;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    -- Initialize to flush out expected errors if any
    initialize_global_error_record();
    -- Add a new error
    append_error(p_error_level => null,
                 p_document_type_code => null,
                 p_document_id => null,
                 p_document_num => null,
                 p_line_id => null,
                 p_line_num => null,
                 p_line_location_id => null,
                 p_shipment_num => null,
                 p_distribution_id => null,
                 p_distribution_num => null,
                 p_message_text => d_module_base||'#'||d_progress||':'
                                  ||SQLCODE || SQLERRM);

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module_base, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module_base, 'x_return_status', x_return_status);
    END IF;
END calculate_tax;


-----------------------------------------------------------------------------
--Start of Comments
--Name: calculate_tax_requisition
--Pre-reqs:
--  Should be called when transaction data has been posted to the database
--  but not yet committed
--Modifies:
--  PO_REQUISITION_LINES_ALL.tax_attribute_update_code
--  PO_REQUISITION_LINES_ALL.original_shipment_id
--  PO_REQ_DISTRIBUTIONS_ALL.nonrecoverable_tax
--  PO_REQ_DISTRIBUTIONS_ALL.recoverable_tax
--Locks:
--  Transaction tables if update is allowed
--Function:
--  Calculate tax amounts for the requisition passed in
--Parameters:
--IN:
--p_requisition_header_id
--  requisition_header_id for which tax is to be calculated
--p_calling_program
--  Identifies the module that calls this procedure eg. 'REQIMPORT'
--OUT:
--x_return_status
--  Standard API specification parameter
--  Can hold one of the following values:
--    FND_API.G_RET_STS_SUCCESS (='S')
--    FND_API.G_RET_STS_ERROR (='E')
--    FND_API.G_RET_STS_UNEXP_ERROR (='U')
--Notes:
--  1. Calls out to EBTax APIs calculate_tax and determine recovery to
--   calculaterecoverable_tax and nonrecoverable_tax
--  2. Returns all expected errors from etax API's in global tax error record
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE calculate_tax_requisition(p_requisition_header_id  IN     NUMBER,
                                    p_calling_program        IN     VARCHAR2,
                                    x_return_status     OUT NOCOPY  VARCHAR2
) IS
  l_module_name CONSTANT VARCHAR2(100) := 'CALCULATE_TAX_REQUISITION';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(
                                            D_PACKAGE_BASE, l_module_name);
  d_progress NUMBER;
  l_count NUMBER;
  l_line_count NUMBER;
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(1000);
  l_trx_rec ZX_API_PUB.transaction_rec_type;
  l_org_id PO_HEADERS_ALL.org_id%TYPE;
  l_return_status VARCHAR2(1);
BEGIN

  SAVEPOINT calculate_tax_req_savepoint;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'p_requisition_header_id', p_requisition_header_id);
    PO_LOG.proc_begin(d_module_base, 'p_calling_program', p_calling_program);
  END IF;

  d_progress := 0;

  -- By default return status is SUCCESS if no exception occurs
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --<Bug 5242803> Skip all processing if requisition_header_id is null
  IF p_requisition_header_id IS NOT NULL THEN
    -- Set global error record to uninitialized local record to set all its
    -- components to null
    G_TAX_ERRORS_TBL := null;
    d_progress := 10;
    initialize_zx_gt_tables(); -- Wipe ZX GT tables clean
    d_progress := 20;
    initialize_global_error_record();

    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module_base,d_progress,'initial values of tax_attribute_update_codes');
      log_req_tauc(d_module_base,d_progress,p_requisition_header_id);
    END IF;

    -- Populate ZX headers and lines GT tables with transaction data
    d_progress := 30;
    populate_zx_headers_with_req(p_requisition_header_id, p_calling_program);

    d_progress := 40;
    populate_zx_lines_with_req(p_requisition_header_id, p_calling_program);

    d_progress := 50;
    -- Check if zx lines gt table is empty
    BEGIN
      SELECT COUNT(1) INTO l_line_count FROM zx_transaction_lines_gt;
    EXCEPTION WHEN OTHERS THEN
      l_line_count := 0;
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,d_progress,'Exception while selecting from zx_transaction_lines_gt');
      END IF;
    END;

    d_progress := 60;
    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module_base,d_progress,'Number of rows in zx_transaction_lines_gt='||l_line_count);
    END IF;

    IF (l_line_count <> 0) THEN
      d_progress := 70;
      -- Log table parameters
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,d_progress,'Table parameters before eTax default/redefault');
        log_header_tax_attributes(d_module_base,d_progress);
        log_line_tax_attributes(d_module_base,d_progress);
      END IF;

      -- Call the eTax defaulting/redefaulting APIs which populate the
      --  Additional Tax Attributes back into the ZX GT tables
      IF (p_calling_program = 'REQIMPORT') THEN
        d_progress := 80;
        -- For Req Import, eTax needs to do extra validations since data is
        -- entered by user in interface tables. So call
        -- validate_and_default_tax_attribs
        ZX_API_PUB.validate_and_default_tax_attr(
          p_api_version           =>  1.0,
          p_init_msg_list         =>  FND_API.G_TRUE,
          p_commit                =>  FND_API.G_FALSE,
          p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL,
          x_return_status         =>  l_return_status,
          x_msg_count             =>  l_msg_count,
          x_msg_data              =>  l_msg_data
        );

        d_progress := 90;
        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,d_progress,'validate_and_default_tax_attr returned with status '||l_return_status);
        END IF;

        -- Raise if any unexpected error
        IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- If there are any expected errors then set the return status
        -- accordingly and copy over errors into global tax errors record
        IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
          d_progress := 100;
          -- Read validation errors from zx_validation_errors_gt into the global
          -- error record defined in the spec
          SELECT
            'VALIDATE' --error_level,
            ,PO_CONSTANTS_SV.REQUISITION --document_type_code,
            ,p_requisition_header_id --document_id,
            ,prh.segment1 --document_num,
            ,zxvegt.trx_line_id --line_id,
            ,prl.line_num --line_num,
            ,null --line_location_id,
            ,null --shipment_num,
            ,null --distribution_id,
            ,null --distribution_num,
            ,zxvegt.message_text --message_text
          BULK COLLECT INTO G_TAX_ERRORS_TBL
          FROM zx_validation_errors_gt zxvegt, po_requisition_headers_all prh,
               po_requisition_lines_all prl
          WHERE zxvegt.trx_id = prh.requisition_header_id
          AND zxvegt.trx_line_id = prl.requisition_line_id(+);

          d_progress := 110;
          BEGIN
            SELECT COUNT(1) INTO l_count FROM zx_validation_errors_gt;
          EXCEPTION WHEN OTHERS THEN
            IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,d_progress,'Exception while hitting zx_validation_errors_gt');
            END IF;
            l_count := 0;
          END;

          IF PO_LOG.d_stmt THEN
            PO_LOG.stmt(d_module_base,d_progress,'Number of records in zx_validation_errors_gt '||l_count);
            PO_LOG.stmt(d_module_base,d_progress,'Number of error records collected '||G_TAX_ERRORS_TBL.error_level.COUNT);
          END IF;

          d_progress := 120;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

      ELSE
        d_progress := 130;
        ZX_API_PUB.get_default_tax_det_attribs(
          p_api_version           =>  1.0,
          p_init_msg_list         =>  FND_API.G_TRUE,
          p_commit                =>  FND_API.G_FALSE,
          p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL,
          x_return_status         =>  l_return_status,
          x_msg_count             =>  l_msg_count,
          x_msg_data              =>  l_msg_data
        );

        d_progress := 140;
        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,d_progress,'get_default_tax_det_attribs returned with status '||l_return_status);
        END IF;

        -- This API cannot give expected errors. However raise unexpected errors
        IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

      END IF; -- IF (p_calling_program = 'REQIMPORT')

      d_progress := 150;
      -- Override product_type Additional Tax Attribute if not already populated
      -- by eTax defaulting/redefaulting API
      UPDATE zx_transaction_lines_gt zxlgt
      SET zxlgt.product_type =
        (SELECT DECODE(prl.purchase_basis,
                       'GOODS', 'GOODS',
                       'SERVICES')
         FROM po_requisition_lines_all prl
         WHERE prl.requisition_line_id = zxlgt.trx_line_id)
      WHERE zxlgt.product_type IS NULL
      AND zxlgt.line_level_action = 'CREATE';

      d_progress := 160;

      -- Log table parameters
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,d_progress,'Table parameters before calculate_tax');
        log_header_tax_attributes(d_module_base,d_progress);
        log_line_tax_attributes(d_module_base,d_progress);
      END IF;

      ZX_API_PUB.calculate_tax(
        p_api_version           =>  1.0,
        p_init_msg_list         =>  FND_API.G_FALSE,
        p_commit                =>  FND_API.G_FALSE,
        p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL,
        x_return_status         =>  l_return_status,
        x_msg_count             =>  l_msg_count,
        x_msg_data              =>  l_msg_data
      );

      d_progress := 170;
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,d_progress,'calculate_tax returned with status '||l_return_status);
      END IF;


      -- Raise if any unexpected error
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- If there are any expected errors then set the return status accordingly
      -- and copy over errors into global tax errors record
      IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        x_return_status := l_return_status;
        d_progress := 180;
        -- Read validation errors from zx_errors_gt into the global
        -- error record defined in the spec
        SELECT
          'CALCULATE_TAX' --error_level,
          ,PO_CONSTANTS_SV.REQUISITION --document_type_code,
          ,p_requisition_header_id --document_id,
          ,prh.segment1 --document_num,
          ,zxegt.trx_line_id --line_id,
          ,prl.line_num --line_num,
          ,null --line_location_id,
          ,null --shipment_num,
          ,null --distribution_id,
          ,null --distribution_num,
          ,zxegt.message_text --message_text
        BULK COLLECT INTO G_TAX_ERRORS_TBL
        FROM zx_errors_gt zxegt, po_requisition_headers_all prh,
             po_requisition_lines_all prl
        WHERE zxegt.trx_id = prh.requisition_header_id
        AND zxegt.trx_line_id = prl.requisition_line_id(+);

        BEGIN
          SELECT COUNT(1) INTO l_count FROM zx_errors_gt;
        EXCEPTION WHEN OTHERS THEN
          IF PO_LOG.d_stmt THEN
            PO_LOG.stmt(d_module_base,d_progress,'Exception while hitting zx_errors_gt');
          END IF;
          l_count := 0;
        END;

        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,d_progress,'Number of records in zx_errors_gt '||l_count);
          PO_LOG.stmt(d_module_base,d_progress,'Number of error records collected '||G_TAX_ERRORS_TBL.error_level.COUNT);
        END IF;

        d_progress := 190;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END IF; -- IF (l_line_count <> 0)

    d_progress := 200;
    -- Populate ZX distributions GT table with transaction distribution data
    populate_zx_dists_with_req(p_requisition_header_id, p_calling_program);

    d_progress := 210;
    -- Call eTax API determine_recovery if zx distributions gt is not empty
    BEGIN
      SELECT COUNT(1) INTO l_count FROM zx_itm_distributions_gt;
    EXCEPTION WHEN OTHERS THEN
      l_count := 0;
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,d_progress,'Exception while selecting from zx_itm_distributions_gt');
      END IF;
    END;

    d_progress := 220;
    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module_base,d_progress,'Number of rows in zx_itm_distributions_gt='||l_count);
    END IF;

    IF (l_count <> 0) THEN
      d_progress := 230;
      -- Update event_type_code on zx headers as required by determine_recovery API
      UPDATE zx_trx_headers_gt
      SET event_type_code = PO_CONSTANTS_SV.REQ_DISTRIBUTED;

      d_progress := 240;

      -- Log table parameters
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,d_progress,'Table parameters before determine_recovery');
        log_header_tax_attributes(d_module_base,d_progress);
        log_line_tax_attributes(d_module_base,d_progress);
        log_dist_tax_attributes(d_module_base,d_progress);
      END IF;

      ZX_API_PUB.determine_recovery(
        p_api_version           =>  1.0,
        p_init_msg_list         =>  FND_API.G_FALSE,
        p_commit                =>  FND_API.G_FALSE,
        p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL,
        x_return_status         =>  l_return_status,
        x_msg_count             =>  l_msg_count,
        x_msg_data              =>  l_msg_data
      );

      d_progress := 250;
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,d_progress,'determine_recovery returned with status '||l_return_status);
      END IF;

      -- Raise if any unexpected error
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- If there are any expected errors then set the return status accordingly
      -- and copy over errors into global tax errors record
      IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        x_return_status := l_return_status;
        -- Read validation errors from zx_errors_gt into the global
        -- error record defined in the spec
        d_progress := 260;
        SELECT
          'DETERMINE_RECOVERY' --error_level,
          ,PO_CONSTANTS_SV.REQUISITION --document_type_code,
          ,p_requisition_header_id --document_id,
          ,prh.segment1 --document_num,
          ,zxegt.trx_line_id --line_id,
          ,prl.line_num --line_num,
          ,null --line_location_id,
          ,null --shipment_num,
          ,zxegt.trx_line_dist_id --distribution_id,
          ,prd.distribution_id --distribution_num,
          ,zxegt.message_text --message_text
        BULK COLLECT INTO G_TAX_ERRORS_TBL
        FROM zx_errors_gt zxegt, po_requisition_headers_all prh,
             po_requisition_lines_all prl, po_req_distributions_all prd
        WHERE zxegt.trx_id = prh.requisition_header_id
        AND zxegt.trx_line_id = prl.requisition_line_id(+)
        AND zxegt.trx_line_dist_id = prd.distribution_id(+);

        d_progress := 270;
        BEGIN
          SELECT COUNT(1) INTO l_count FROM zx_errors_gt;
        EXCEPTION WHEN OTHERS THEN
          IF PO_LOG.d_stmt THEN
            PO_LOG.stmt(d_module_base,d_progress,'Exception while hitting zx_errors_gt');
          END IF;
          l_count := 0;
        END;

        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,d_progress,'Number of records in zx_errors_gt '||l_count);
          PO_LOG.stmt(d_module_base,d_progress,'Number of error records collected '||G_TAX_ERRORS_TBL.error_level.COUNT);
        END IF;

        d_progress := 280;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      d_progress := 290;
      -- Populate recoverable/nonrecoverable tax columns in distributions table
      UPDATE po_req_distributions_all prd
      SET prd.recoverable_tax =
            (SELECT SUM(zxdist.rec_nrec_tax_amt)
             FROM zx_rec_nrec_dist_gt zxdist
             WHERE zxdist.trx_line_dist_id = prd.distribution_id
             AND zxdist.recoverable_flag = 'Y'
             AND zxdist.application_id = PO_CONSTANTS_SV.APPLICATION_ID
             AND zxdist.entity_code = PO_CONSTANTS_SV.REQ_ENTITY_CODE
             AND zxdist.event_class_code = PO_CONSTANTS_SV.REQ_EVENT_CLASS_CODE)
         ,prd.nonrecoverable_tax =
            (SELECT SUM(zxdist.rec_nrec_tax_amt)
             FROM zx_rec_nrec_dist_gt zxdist
             WHERE zxdist.trx_line_dist_id = prd.distribution_id
             AND zxdist.recoverable_flag = 'N'
             AND zxdist.application_id = PO_CONSTANTS_SV.APPLICATION_ID
             AND zxdist.entity_code = PO_CONSTANTS_SV.REQ_ENTITY_CODE
             AND zxdist.event_class_code = PO_CONSTANTS_SV.REQ_EVENT_CLASS_CODE)
      WHERE prd.distribution_id IN
        (SELECT trx_line_dist_id FROM zx_itm_distributions_gt);

    END IF; -- IF (l_count <> 0)

    -- If any lines were processed then update eTax repository with the line
    -- determining factors
    IF (l_line_count <> 0) THEN
      d_progress := 300;
      SELECT prh.org_id
      INTO l_org_id
      FROM po_requisition_headers_all prh
      WHERE prh.requisition_header_id=p_requisition_header_id;

      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,d_progress,'org_id = '||l_org_id);
      END IF;

      d_progress := 310;
      -- Call global_document_update API to delete all data for this requistion
      l_trx_rec.internal_organization_id := l_org_id;
      l_trx_rec.application_id           := PO_CONSTANTS_SV.APPLICATION_ID;
      l_trx_rec.entity_code              := PO_CONSTANTS_SV.REQ_ENTITY_CODE;
      l_trx_rec.event_class_code         := PO_CONSTANTS_SV.REQ_EVENT_CLASS_CODE;
      l_trx_rec.event_type_code          := PO_CONSTANTS_SV.REQ_DELETED;
      l_trx_rec.trx_id                   := p_requisition_header_id;
      l_trx_rec.application_doc_status   := null;

      d_progress := 320;
      ZX_API_PUB.global_document_update(
        p_api_version         =>  1.0,
        p_init_msg_list       =>  FND_API.G_FALSE,
        p_commit              =>  FND_API.G_FALSE,
        p_validation_level    =>  FND_API.G_VALID_LEVEL_FULL,
        x_return_status       =>  l_return_status,
        x_msg_count           =>  l_msg_count,
        x_msg_data            =>  l_msg_data,
        p_transaction_rec     =>  l_trx_rec);

      -- Raise if any unexpected error
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      d_progress := 330;
      -- Populate zx record TRX_LINE_DIST_TBL
      populate_zx_record(p_requisition_header_id);
      d_progress := 340;
      -- Populate the tax determining attributes in eTax repository if there were
      -- no errors in processing the document. Control will reach here only if
      -- all l_return_status until now have been successful
      ZX_API_PUB.insert_line_det_factors(
        p_api_version         =>  1.0,
        p_init_msg_list       =>  FND_API.G_FALSE,
        p_commit              =>  FND_API.G_FALSE,
        p_validation_level    =>  FND_API.G_VALID_LEVEL_FULL,
        x_return_status       =>  l_return_status,
        x_msg_count           =>  l_msg_count,
        x_msg_data            =>  l_msg_data);

      d_progress := 350;
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,d_progress,'insert_line_det_factors returned with status '||l_return_status);
      END IF;

      -- Raise if any unexpected error
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END IF; --IF (l_line_count <> 0)

    d_progress := 360;
    -- Null out tax_attribute_update_code columns
    update po_requisition_headers_all
    set tax_attribute_update_code = null
    where requisition_header_id = p_requisition_header_id;

    d_progress := 370;
    update po_requisition_lines_all
    set tax_attribute_update_code = null
    where requisition_header_id = p_requisition_header_id;

    -- Bug 5363122. Wipe out ZX GT tables at the end of tax call
    wipe_zx_gt_tables();

  END IF; -- IF p_requisition_header_id IS NOT NULL

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module_base);
    PO_LOG.proc_end(d_module_base, 'x_return_status', x_return_status);
  END IF;
  d_progress := 380;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    ROLLBACK TO SAVEPOINT calculate_tax_req_savepoint;

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module_base,d_progress,'Number of error records collected '||G_TAX_ERRORS_TBL.error_level.COUNT);
      log_global_error_record(d_module_base, d_progress);
      PO_LOG.exc(d_module_base, d_progress, null);
      PO_LOG.proc_end(d_module_base, 'x_return_status', x_return_status);
    END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    ROLLBACK TO SAVEPOINT calculate_tax_req_savepoint;

    -- Initialize to flush out expected errors if any
    initialize_global_error_record();
    -- Add a new error
    append_error(p_error_level => null,
                 p_document_type_code => null,
                 p_document_id => null,
                 p_document_num => null,
                 p_line_id => null,
                 p_line_num => null,
                 p_line_location_id => null,
                 p_shipment_num => null,
                 p_distribution_id => null,
                 p_distribution_num => null,
                 p_message_text => l_msg_data);

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module_base, d_progress, l_msg_data);
      PO_LOG.proc_end(d_module_base, 'x_return_status', x_return_status);
    END IF;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    ROLLBACK TO SAVEPOINT calculate_tax_req_savepoint;

    -- Initialize to flush out expected errors if any
    initialize_global_error_record();
    -- Add a new error
    append_error(p_error_level => null,
                 p_document_type_code => null,
                 p_document_id => null,
                 p_document_num => null,
                 p_line_id => null,
                 p_line_num => null,
                 p_line_location_id => null,
                 p_shipment_num => null,
                 p_distribution_id => null,
                 p_distribution_num => null,
                 p_message_text => d_module_base||'#'||d_progress||':'
                                  ||SQLCODE || SQLERRM);

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module_base, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module_base, 'x_return_status', x_return_status);
    END IF;
END calculate_tax_requisition;



-----------------------------------------------------------------------------
--Start of Comments
--Name: determine_recovery_po
--Pre-reqs:
--  None
--Modifies:
--  PO_DISTRIBUTIONS_ALL.nonrecoverable_tax
--  PO_DISTRIBUTIONS_ALL.recoverable_tax
--Locks:
--  Transaction tables if update is allowed
--Function:
--  Distribute tax lines and calculate recoverable and nonrecoverable tax
--  amounts
--Parameters:
--IN:
--p_po_header_id
--  po_header_id for which tax is to be distributed
--OUT:
--x_return_status
--  Standard API specification parameter
--  Can hold one of the following values:
--    FND_API.G_RET_STS_SUCCESS (='S')
--    FND_API.G_RET_STS_ERROR (='E')
--    FND_API.G_RET_STS_UNEXP_ERROR (='U')
--Notes:
--  1. Calls out to EBTax API determine recovery to distribute tax lines
--   Populates recoverable_tax and nonrecoverable_tax columns in distributions
--   with the corrsponding tax amounts calculated.
--  2. Returns all expected errors from etax API's in global tax error record
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE determine_recovery_po(p_po_header_id  IN         NUMBER,
                                x_return_status OUT NOCOPY VARCHAR2
) IS
  l_module_name CONSTANT VARCHAR2(100) := 'DETERMINE_RECOVERY_PO';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(
                                            D_PACKAGE_BASE, l_module_name);
  d_progress NUMBER;
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(1000);
  l_count NUMBER;
  l_return_status VARCHAR2(1);
BEGIN
  SAVEPOINT det_recovery_po_savepoint;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'p_po_header_id', p_po_header_id);
  END IF;

  d_progress := 0;

  -- By default return status is SUCCESS if no exception occurs
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Set global error record to uninitialized local record to set all its
  -- components to null
  G_TAX_ERRORS_TBL := null;
  initialize_zx_gt_tables(); -- Wipe ZX GT tables clean
  initialize_global_error_record();

  d_progress := 10;
  -- Populate ZX headers GT table with transaction header data
  populate_header_po(p_po_header_id);
  d_progress := 20;
  -- Populate ZX distributions GT table with transaction distribution data
  populate_all_dists_po(p_po_header_id);

  d_progress := 30;
  -- Call eTax API determine_recovery to distribute tax lines
  BEGIN
    SELECT COUNT(1) INTO l_count FROM zx_itm_distributions_gt;
  EXCEPTION WHEN OTHERS THEN
    l_count := 0;
  END;

  IF (l_count <> 0) THEN
    d_progress := 40;

    -- Log table parameters
    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module_base,d_progress,'Table parameters before determine_recovery');
      log_header_tax_attributes(d_module_base,d_progress);
      log_dist_tax_attributes(d_module_base,d_progress);
    END IF;

    ZX_API_PUB.determine_recovery(
      p_api_version           =>  1.0,
      p_init_msg_list         =>  FND_API.G_TRUE,
      p_commit                =>  FND_API.G_FALSE,
      p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL,
      x_return_status         =>  l_return_status,
      x_msg_count             =>  l_msg_count,
      x_msg_data              =>  l_msg_data
    );

    -- Raise if any unexpected error
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- If expected errors, store error details in po_session_gt temporarily
    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      x_return_status := l_return_status;
      -- Read validation errors from zx_errors_gt into the global
      -- error record defined in the spec
      SELECT
        'DETERMINE_RECOVERY' --error_level,
        ,PO_CONSTANTS_SV.PO --document_type_code,
        ,p_po_header_id --document_id,
        ,ph.segment1 --document_num,
        ,null --line_id,
        ,null --line_num,
        ,zxegt.trx_line_id --line_location_id,
        ,pll.shipment_num --shipment_num,
        ,zxegt.trx_line_dist_id --distribution_id,
        ,pd.distribution_num --distribution_num,
        ,zxegt.message_text --message_text
      BULK COLLECT INTO G_TAX_ERRORS_TBL
      FROM zx_errors_gt zxegt, po_headers_all ph,
           po_line_locations_all pll, po_distributions_all pd
      WHERE zxegt.trx_id = ph.po_header_id
      AND zxegt.trx_line_id = pll.line_location_id(+)
      AND zxegt.trx_line_dist_id = pd.po_distribution_id(+);

      BEGIN
        SELECT COUNT(1) INTO l_count FROM zx_errors_gt;
      EXCEPTION WHEN OTHERS THEN
        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,d_progress,'Exception while hitting zx_errors_gt');
        END IF;
        l_count := 0;
      END;

      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,d_progress,'Number of records in zx_errors_gt '||l_count);
        PO_LOG.stmt(d_module_base,d_progress,'Number of error records collected '||G_TAX_ERRORS_TBL.error_level.COUNT);
      END IF;

      RAISE FND_API.G_EXC_ERROR;
    END IF; --IF (l_return_status = FND_API.G_RET_STS_ERROR)

    d_progress := 50;
    -- Populate recoverable/nonrecoverable tax columns in distributions table
    UPDATE po_distributions_all pd
    SET pd.recoverable_tax =
          (SELECT SUM(zxdist.rec_nrec_tax_amt)
           FROM zx_rec_nrec_dist zxdist
           WHERE zxdist.trx_line_dist_id = pd.po_distribution_id
           AND zxdist.recoverable_flag = 'Y'
           AND zxdist.application_id = PO_CONSTANTS_SV.APPLICATION_ID
           AND zxdist.entity_code = PO_CONSTANTS_SV.PO_ENTITY_CODE
           AND zxdist.event_class_code = PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE)
       ,pd.nonrecoverable_tax =
          (SELECT SUM(zxdist.rec_nrec_tax_amt)
           FROM zx_rec_nrec_dist zxdist
           WHERE zxdist.trx_line_dist_id = pd.po_distribution_id
           AND zxdist.recoverable_flag = 'N'
           AND zxdist.application_id = PO_CONSTANTS_SV.APPLICATION_ID
           AND zxdist.entity_code = PO_CONSTANTS_SV.PO_ENTITY_CODE
           AND zxdist.event_class_code = PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE),
		--Bug 10305728 start
        last_update_date = sysdate,
     	last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.login_id
        --Bug 10305728  end
    WHERE pd.po_distribution_id IN
      (SELECT trx_line_dist_id FROM zx_itm_distributions_gt);

      /*  Bug 6157632 Start */
      UPDATE po_line_locations_all pll
  SET pll.taxable_flag =
    DECODE((SELECT COUNT(1) FROM zx_lines zl
            WHERE zl.trx_line_id = pll.line_location_id
            AND zl.application_id = PO_CONSTANTS_SV.APPLICATION_ID
            AND ( (zl.entity_code = PO_CONSTANTS_SV.PO_ENTITY_CODE
                   AND zl.event_class_code = PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE
                   AND zl.trx_id = pll.po_header_id)
                  OR
                  (zl.entity_code = PO_CONSTANTS_SV.REL_ENTITY_CODE
                   AND zl.event_class_code = PO_CONSTANTS_SV.REL_EVENT_CLASS_CODE
                   AND zl.trx_id = pll.po_release_id))),
           0, 'N',
           'Y'
          ),
		--Bug 10305728 start
	    tax_attribute_update_code = null,
        last_update_date = sysdate,
     	last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.login_id
    --Bug 10305728  end
  WHERE
    pll.line_location_id IN (SELECT line_location_id FROM po_distributions_all pd,zx_itm_distributions_gt zi WHERE pd.po_distribution_id=zi.trx_line_dist_id);
    /*  Bug 6157632 End */
  END IF;

  d_progress := 60;
  UPDATE po_distributions_all
  SET tax_attribute_update_code = null,
     --Bug 10305728 start
	 last_update_date = sysdate,
     last_updated_by = fnd_global.user_id,
     last_update_login = fnd_global.login_id
    --Bug 10305728  end
  WHERE po_distribution_id IN (SELECT trx_line_dist_id
                               FROM zx_itm_distributions_gt);

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module_base);
    PO_LOG.proc_end(d_module_base, 'x_return_status', x_return_status);
  END IF;
  d_progress := 70;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    ROLLBACK TO SAVEPOINT det_recovery_po_savepoint;

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module_base, d_progress, null);
      PO_LOG.proc_end(d_module_base, 'x_return_status', x_return_status);
    END IF;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    ROLLBACK TO SAVEPOINT det_recovery_po_savepoint;

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module_base, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module_base, 'x_return_status', x_return_status);
    END IF;

END determine_recovery_po;


-----------------------------------------------------------------------------
--Start of Comments
--Name: determine_recovery_rel
--Pre-reqs:
--  None
--Modifies:
--  PO_DISTRIBUTIONS_ALL.nonrecoverable_tax
--  PO_DISTRIBUTIONS_ALL.recoverable_tax
--Locks:
--  Transaction tables if update is allowed
--Function:
--  Distribute tax lines and calculate recoverable and nonrecoverable tax
--  amounts
--Parameters:
--IN:
--p_po_release_id
--  po_release_id for which tax is to be distributed
--OUT:
--x_return_status
--  Standard API specification parameter
--  Can hold one of the following values:
--    FND_API.G_RET_STS_SUCCESS (='S')
--    FND_API.G_RET_STS_ERROR (='E')
--    FND_API.G_RET_STS_UNEXP_ERROR (='U')
--Notes:
--  1. Calls out to EBTax API determine recovery to distribute tax lines
--   Populates recoverable_tax and nonrecoverable_tax columns in distributions
--   with the corrsponding tax amounts calculated.
--  2. Returns all expected errors from etax API's in global tax error record
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE determine_recovery_rel(p_po_release_id  IN       NUMBER,
                                x_return_status OUT NOCOPY VARCHAR2
) IS
  l_module_name CONSTANT VARCHAR2(100) := 'DETERMINE_RECOVERY_REL';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(
                                            D_PACKAGE_BASE, l_module_name);
  d_progress NUMBER;
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(1000);
  l_count NUMBER;
  l_return_status VARCHAR2(1);
BEGIN
  SAVEPOINT det_recovery_rel_savepoint;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'p_po_release_id', p_po_release_id);
  END IF;

  d_progress := 0;

  -- By default return status is SUCCESS if no exception occurs
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Set global error record to uninitialized local record to set all its
  -- components to null
  G_TAX_ERRORS_TBL := null;
  initialize_zx_gt_tables(); -- Wipe ZX GT tables clean
  initialize_global_error_record();

  d_progress := 10;
  -- Populate ZX headers GT table with transaction header data
  populate_header_rel(p_po_release_id);
  d_progress := 20;
  -- Populate ZX distributions GT table with transaction distribution data
  populate_all_dists_rel(p_po_release_id);

  d_progress := 30;
  -- Call eTax API determine_recovery to distribute tax lines
  BEGIN
    SELECT COUNT(1) INTO l_count FROM zx_itm_distributions_gt;
  EXCEPTION WHEN OTHERS THEN
    l_count := 0;
  END;

  IF (l_count <> 0) THEN
    d_progress := 40;

    -- Log table parameters
    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module_base,d_progress,'Table parameters before determine_recovery');
      log_header_tax_attributes(d_module_base,d_progress);
      log_dist_tax_attributes(d_module_base,d_progress);
    END IF;

    ZX_API_PUB.determine_recovery(
      p_api_version           =>  1.0,
      p_init_msg_list         =>  FND_API.G_TRUE,
      p_commit                =>  FND_API.G_FALSE,
      p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL,
      x_return_status         =>  l_return_status,
      x_msg_count             =>  l_msg_count,
      x_msg_data              =>  l_msg_data
    );

    -- Raise if any unexpected error
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- If expected errors, store error details in po_session_gt temporarily
    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      x_return_status := l_return_status;
      -- Read validation errors from zx_errors_gt into the global
      -- error record defined in the spec
      SELECT
        'DETERMINE_RECOVERY' --error_level,
        ,PO_CONSTANTS_SV.PO --document_type_code,
        ,p_po_release_id --document_id,
        ,ph.segment1 --document_num,
        ,null --line_id,
        ,null --line_num,
        ,zxegt.trx_line_id --line_location_id,
        ,pll.shipment_num --shipment_num,
        ,zxegt.trx_line_dist_id --distribution_id,
        ,pd.distribution_num --distribution_num,
        ,zxegt.message_text --message_text
      BULK COLLECT INTO G_TAX_ERRORS_TBL
      FROM zx_errors_gt zxegt, po_releases_all pr, po_headers_all ph,
           po_line_locations_all pll, po_distributions_all pd
      WHERE zxegt.trx_id = pr.po_release_id
      AND pr.po_header_id = ph.po_header_id
      AND zxegt.trx_line_id = pll.line_location_id(+)
      AND zxegt.trx_line_dist_id = pd.po_distribution_id(+);

      BEGIN
        SELECT COUNT(1) INTO l_count FROM zx_errors_gt;
      EXCEPTION WHEN OTHERS THEN
        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,d_progress,'Exception while hitting zx_errors_gt');
        END IF;
        l_count := 0;
      END;

      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,d_progress,'Number of records in zx_errors_gt '||l_count);
        PO_LOG.stmt(d_module_base,d_progress,'Number of error records collected '||G_TAX_ERRORS_TBL.error_level.COUNT);
      END IF;

      RAISE FND_API.G_EXC_ERROR;
    END IF; --IF (l_return_status = FND_API.G_RET_STS_ERROR)

    d_progress := 50;
    -- Populate recoverable/nonrecoverable tax columns in distributions table
    UPDATE po_distributions_all pd
    SET pd.recoverable_tax =
          (SELECT SUM(zxdist.rec_nrec_tax_amt)
           FROM zx_rec_nrec_dist zxdist
           WHERE zxdist.trx_line_dist_id = pd.po_distribution_id
           AND zxdist.recoverable_flag = 'Y'
           AND zxdist.application_id = PO_CONSTANTS_SV.APPLICATION_ID
           AND zxdist.entity_code = PO_CONSTANTS_SV.REL_ENTITY_CODE
           AND zxdist.event_class_code = PO_CONSTANTS_SV.REL_EVENT_CLASS_CODE)
       ,pd.nonrecoverable_tax =
          (SELECT SUM(zxdist.rec_nrec_tax_amt)
           FROM zx_rec_nrec_dist zxdist
           WHERE zxdist.trx_line_dist_id = pd.po_distribution_id
           AND zxdist.recoverable_flag = 'N'
           AND zxdist.application_id = PO_CONSTANTS_SV.APPLICATION_ID
           AND zxdist.entity_code = PO_CONSTANTS_SV.REL_ENTITY_CODE
           AND zxdist.event_class_code = PO_CONSTANTS_SV.REL_EVENT_CLASS_CODE)
    WHERE pd.po_distribution_id IN
      (SELECT trx_line_dist_id FROM zx_itm_distributions_gt);

      /*  Bug 6157632 Start */
      UPDATE po_line_locations_all pll
  SET pll.taxable_flag =
    DECODE((SELECT COUNT(1) FROM zx_lines zl
            WHERE zl.trx_line_id = pll.line_location_id
            AND zl.application_id = PO_CONSTANTS_SV.APPLICATION_ID
            AND ( (zl.entity_code = PO_CONSTANTS_SV.PO_ENTITY_CODE
                   AND zl.event_class_code = PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE
                   AND zl.trx_id = pll.po_header_id)
                  OR
                  (zl.entity_code = PO_CONSTANTS_SV.REL_ENTITY_CODE
                   AND zl.event_class_code = PO_CONSTANTS_SV.REL_EVENT_CLASS_CODE
                   AND zl.trx_id = pll.po_release_id))),
           0, 'N',
           'Y'
          )
  WHERE
    pll.line_location_id IN (SELECT line_location_id FROM po_distributions_all pd,zx_itm_distributions_gt zi WHERE pd.po_distribution_id=zi.trx_line_dist_id);
    /*  Bug 6157632 End */


  END IF;

  d_progress := 60;
  UPDATE po_distributions_all
  SET tax_attribute_update_code = null
  WHERE po_distribution_id IN (SELECT trx_line_dist_id
                               FROM zx_itm_distributions_gt);

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module_base);
    PO_LOG.proc_end(d_module_base, 'x_return_status', x_return_status);
  END IF;
  d_progress := 70;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    ROLLBACK TO SAVEPOINT det_recovery_rel_savepoint;

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module_base, d_progress, null);
      PO_LOG.proc_end(d_module_base, 'x_return_status', x_return_status);
    END IF;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    ROLLBACK TO SAVEPOINT det_recovery_rel_savepoint;

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module_base, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module_base, 'x_return_status', x_return_status);
    END IF;

END determine_recovery_rel;


-----------------------------------------------------------------------------
--Start of Comments
--Name: determine_recovery_req
--Pre-reqs:
--  None
--Modifies:
--  PO_REQ_DISTRIBUTIONS_ALL.nonrecoverable_tax
--  PO_REQ_DISTRIBUTIONS_ALL.recoverable_tax
--Locks:
--  Transaction tables if update is allowed
--Function:
--  Distributes tax lines and calculates_recoverable and nonrecoverable tax
--  amounts
--Parameters:
--IN:
--p_requisition_header_id
--  requisition_header_id for which tax is to be distributed
--OUT:
--x_return_status
--  Standard API specification parameter
--  Can hold one of the following values:
--    FND_API.G_RET_STS_SUCCESS (='S')
--    FND_API.G_RET_STS_ERROR (='E')
--    FND_API.G_RET_STS_UNEXP_ERROR (='U')
--Notes:
--  1. Calls out to EBTax API determine recovery to calculate recoverable_tax
--   and nonrecoverable_tax
--  2. Returns all expected errors from etax API in global tax error record
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE determine_recovery_req(p_requisition_header_id IN NUMBER,
                                 x_return_status OUT NOCOPY VARCHAR2
) IS
  l_module_name CONSTANT VARCHAR2(100) := 'DETERMINE_RECOVERY_REQ';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(
                                            D_PACKAGE_BASE, l_module_name);
  d_progress NUMBER;
  l_count NUMBER;
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(1000);
  l_return_status VARCHAR2(1);
BEGIN

  SAVEPOINT det_recovery_req_savepoint;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'p_requisition_header_id', p_requisition_header_id);
  END IF;

  d_progress := 0;

  -- By default return status is SUCCESS if no exception occurs
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Set global error record to uninitialized local record to set all its
  -- components to null
  G_TAX_ERRORS_TBL := null;
  initialize_zx_gt_tables(); -- Wipe ZX GT tables clean
  initialize_global_error_record();

  d_progress := 10;
  -- Populate ZX headers GT table with transaction header data
  populate_zx_headers_with_req(p_requisition_header_id, 'DETERMINE_RECOVERY_REQ');

  d_progress := 20;
  -- Populate ZX distributions GT table with transaction distribution data
  populate_zx_dists_with_req(p_requisition_header_id, 'DETERMINE_RECOVERY_REQ');

  d_progress := 30;
  -- Call eTax API determine_recovery if zx distributions gt is not empty
  BEGIN
    SELECT COUNT(1) INTO l_count FROM zx_itm_distributions_gt;
  EXCEPTION WHEN OTHERS THEN
    l_count := 0;
  END;

  IF (l_count <> 0) THEN
    d_progress := 40;

    -- Log table parameters
    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module_base,d_progress,'Table parameters before determine_recovery');
      log_header_tax_attributes(d_module_base,d_progress);
      log_dist_tax_attributes(d_module_base,d_progress);
    END IF;

    ZX_API_PUB.determine_recovery(
      p_api_version           =>  1.0,
      p_init_msg_list         =>  FND_API.G_FALSE,
      p_commit                =>  FND_API.G_FALSE,
      p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL,
      x_return_status         =>  l_return_status,
      x_msg_count             =>  l_msg_count,
      x_msg_data              =>  l_msg_data
    );

    -- Raise if any unexpected error
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- If there are any expected errors then set the return status accordingly
    -- and copy over errors into global tax errors record
    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      x_return_status := l_return_status;
      -- Read validation errors from zx_errors_gt into the global
      -- error record defined in the spec
      SELECT
        'DETERMINE_RECOVERY' --error_level,
        ,PO_CONSTANTS_SV.REQUISITION --document_type_code,
        ,p_requisition_header_id --document_id,
        ,prh.segment1 --document_num,
        ,zxegt.trx_line_id --line_id,
        ,prl.line_num --line_num,
        ,null --line_location_id,
        ,null --shipment_num,
        ,zxegt.trx_line_dist_id --distribution_id,
        ,prd.distribution_num --distribution_num,
        ,zxegt.message_text --message_text
      BULK COLLECT INTO G_TAX_ERRORS_TBL
      FROM zx_errors_gt zxegt, po_requisition_headers_all prh,
           po_requisition_lines_all prl, po_req_distributions_all prd
      WHERE zxegt.trx_id = prh.requisition_header_id
      AND zxegt.trx_line_id = prl.requisition_line_id(+)
      AND zxegt.trx_line_dist_id = prd.distribution_id(+);

      BEGIN
        SELECT COUNT(1) INTO l_count FROM zx_errors_gt;
      EXCEPTION WHEN OTHERS THEN
        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,d_progress,'Exception while hitting zx_errors_gt');
        END IF;
        l_count := 0;
      END;

      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,d_progress,'Number of records in zx_errors_gt '||l_count);
        PO_LOG.stmt(d_module_base,d_progress,'Number of error records collected '||G_TAX_ERRORS_TBL.error_level.COUNT);
      END IF;

      RAISE FND_API.G_EXC_ERROR;
    END IF;

    d_progress := 50;
    -- Populate recoverable/nonrecoverable tax columns in distributions table
    UPDATE po_req_distributions_all prd
    SET prd.recoverable_tax =
          (SELECT SUM(zxdist.rec_nrec_tax_amt)
           FROM zx_rec_nrec_dist_gt zxdist
           WHERE zxdist.trx_line_dist_id = prd.distribution_id
           AND zxdist.recoverable_flag = 'Y'
           AND zxdist.application_id = PO_CONSTANTS_SV.APPLICATION_ID
           AND zxdist.entity_code = PO_CONSTANTS_SV.REQ_ENTITY_CODE
           AND zxdist.event_class_code = PO_CONSTANTS_SV.REQ_EVENT_CLASS_CODE)
       ,prd.nonrecoverable_tax =
          (SELECT SUM(zxdist.rec_nrec_tax_amt)
           FROM zx_rec_nrec_dist_gt zxdist
           WHERE zxdist.trx_line_dist_id = prd.distribution_id
           AND zxdist.recoverable_flag = 'N'
           AND zxdist.application_id = PO_CONSTANTS_SV.APPLICATION_ID
           AND zxdist.entity_code = PO_CONSTANTS_SV.REQ_ENTITY_CODE
           AND zxdist.event_class_code = PO_CONSTANTS_SV.REQ_EVENT_CLASS_CODE)
    WHERE prd.distribution_id IN
      (SELECT trx_line_dist_id FROM zx_itm_distributions_gt);

  END IF; -- IF (l_count <> 0)

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module_base);
    PO_LOG.proc_end(d_module_base, 'x_return_status', x_return_status);
  END IF;
  d_progress := 60;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    ROLLBACK TO SAVEPOINT det_recovery_req_savepoint;

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module_base, d_progress, null);
      PO_LOG.proc_end(d_module_base, 'x_return_status', x_return_status);
    END IF;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    ROLLBACK TO SAVEPOINT det_recovery_req_savepoint;

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module_base, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module_base, 'x_return_status', x_return_status);
    END IF;
END determine_recovery_req;


-----------------------------------------------------------------------------
--Start of Comments
--Name: populate_zx_headers_with_po
--Pre-reqs:
--  None
--Modifies:
--  ZX_TRX_HEADERS_GT
--Locks:
--  ZX_TRX_HEADERS_GT
--Function:
--  Populate ZX_TRX_HEADERS_GT with transaction header data
--Parameters:
--IN:
--p_po_header_id_tbl
--  PL/SQL table with list of po_header_id's to process for tax_calculation
--p_calling_program
--  Identifies the module that calls this procedure eg. 'PDOI'
--Notes:
--  Used by calculate_tax procedure. Not to be used externally
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE populate_zx_headers_with_po(p_po_header_id_tbl  IN  PO_TBL_NUMBER,
                                      p_calling_program   IN  VARCHAR2
) IS
BEGIN

  -- Populate zx_trx_headers_gt for POs
  FORALL i IN 1..p_po_header_id_tbl.COUNT
    INSERT INTO zx_trx_headers_gt(
      internal_organization_id
      ,application_id
      ,entity_code
      ,event_class_code
      ,event_type_code
      ,trx_id
      ,trx_date
      ,trx_doc_revision
      ,ledger_id
      ,trx_currency_code
      ,currency_conversion_date
      ,currency_conversion_rate
      ,currency_conversion_type
      ,minimum_accountable_unit --Bug 5474336. Pass mau to EBTax
      ,precision
      ,legal_entity_id
      ,rounding_ship_from_party_id
      ,default_taxation_country
      ,quote_flag
      ,trx_number
      ,trx_description
      ,trx_communicated_date
      ,document_sub_type
      ,provnl_tax_determination_date
      -- Bug 5025018. Updated tax attribute mappings
      ,rounding_bill_to_party_id
      ,rndg_ship_from_party_site_id
    )
    SELECT
      ph.org_id --internal_organization_id
      ,PO_CONSTANTS_SV.APPLICATION_ID --application_id
      ,PO_CONSTANTS_SV.PO_ENTITY_CODE --entity_code
      ,PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE --event_class_code
      ,DECODE(ph.tax_attribute_update_code, --event_type_code
         'CREATE', PO_CONSTANTS_SV.PO_CREATED,
         'COPY_AND_CREATE', PO_CONSTANTS_SV.PO_CREATED,
         PO_CONSTANTS_SV.PO_ADJUSTED) --for null and 'UPDATE'
      ,ph.po_header_id --trx_id
      ,sysdate --trx_date
      ,ph.revision_num --trx_doc_revision
      ,(SELECT set_of_books_id --ledger_id
        FROM financials_system_params_all WHERE org_id=ph.org_id)
      ,ph.currency_code --trx_currency_code
      -- Bug#18613649 : pass creation_date if rate_date not available
      ,NVL(ph.rate_date, ph.creation_date)  --currency_conversion_date
      ,ph.rate --currency_conversion_rate
      ,ph.rate_type --currency_conversion_type
      --Bug 5474336. Pass mau to EBTax
      ,fc.minimum_accountable_unit --minimum_accountable_unit
      ,NVL(fc.precision, 2) --precision
      ,PO_CORE_S.get_default_legal_entity_id(ph.org_id) --legal_entity_id
      ,(SELECT pv.party_id FROM po_vendors pv --rounding_ship_from_party_id
        WHERE pv.vendor_id=ph.vendor_id)
      ,DECODE(p_calling_program, --default_taxation_country
              'COPY_DOCUMENT', null,
              zxldet.default_taxation_country)
      ,'N' --quote_flag
      ,ph.segment1 --trx_number
      ,ph.comments --trx_description
      ,sysdate --ph.print_date --trx_communicated_date
      ,DECODE(p_calling_program, --document_sub_type
              'COPY_DOCUMENT', null,
              zxldet.document_sub_type)
      ,DECODE(ph.document_creation_method, --provnl_tax_determination_date
         'CREATE_CONSUMPTION',
         (SELECT pll.need_by_date
          FROM po_line_locations_all pll
          WHERE pll.po_header_id=ph.po_header_id
          AND pll.need_by_date IS NOT NULL
          AND rownum=1),
          null)
      -- Bug 5025018. Updated tax attribute mappings
      ,ph.org_id --rounding_bill_to_party_id
      ,(SELECT pvs.party_site_id from po_vendor_sites_all pvs --rndg_ship_from_party_site_id
        WHERE pvs.vendor_site_id=ph.vendor_site_id)
    FROM po_headers_all ph, zx_lines_det_factors zxldet, fnd_currencies fc
    WHERE ph.po_header_id = p_po_header_id_tbl(i)
    AND fc.currency_code = ph.currency_code
    -- Conditions for getting Additional Tax Attributes
    -- Note that the po_header_id is of current document being processed,
    -- not of any source document. Get the first row obtained from join
    -- with zx_lines_det_factors because that table is denormalized
    AND zxldet.trx_id(+) = ph.po_header_id
    AND zxldet.application_id(+) = PO_CONSTANTS_SV.APPLICATION_ID
    AND zxldet.entity_code(+) = PO_CONSTANTS_SV.PO_ENTITY_CODE
    AND zxldet.event_class_code(+) = PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE
    AND zxldet.trx_level_type(+) = PO_CONSTANTS_SV.PO_TRX_LEVEL_TYPE
    AND rownum = 1;

END populate_zx_headers_with_po;


-----------------------------------------------------------------------------
--Start of Comments
--Name: populate_header_po
--Pre-reqs:
--  None
--Modifies:
--  ZX_TRX_HEADERS_GT
--Locks:
--  ZX_TRX_HEADERS_GT
--Function:
--  Populate ZX_TRX_HEADERS_GT with transaction header data
--Parameters:
--IN:
--p_po_header_id
--  po__header_id to process for tax distribution
--Notes:
--  Used by determine_recovery_po procedure. Not to be used externally
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE populate_header_po(p_po_header_id  IN  NUMBER) IS
BEGIN

  -- Populate zx_trx_headers_gt for the PO
  INSERT INTO zx_trx_headers_gt(
    internal_organization_id
    ,application_id
    ,entity_code
    ,event_class_code
    ,event_type_code
    ,trx_id
    ,trx_date
    ,trx_doc_revision
    ,ledger_id
    ,trx_currency_code
    ,currency_conversion_date
    ,currency_conversion_rate
    ,currency_conversion_type
    ,minimum_accountable_unit --Bug 5474336. Pass mau to EBTax
    ,precision
    ,legal_entity_id
    ,rounding_ship_from_party_id
    ,default_taxation_country
    ,quote_flag
    ,trx_number
    ,trx_description
    ,trx_communicated_date
    ,document_sub_type
    ,provnl_tax_determination_date
    -- Bug 5025018. Updated tax attribute mappings
    ,rounding_bill_to_party_id
    ,rndg_ship_from_party_site_id
  )
  SELECT
    ph.org_id --internal_organization_id
    ,PO_CONSTANTS_SV.APPLICATION_ID --application_id
    ,PO_CONSTANTS_SV.PO_ENTITY_CODE --entity_code
    ,PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE --event_class_code
    ,PO_CONSTANTS_SV.PO_REDISTRIBUTED --event_type_code
    ,ph.po_header_id --trx_id
    ,sysdate --trx_date
    ,ph.revision_num --trx_doc_revision
    ,(SELECT set_of_books_id --ledger_id
      FROM financials_system_params_all WHERE org_id=ph.org_id)
    ,ph.currency_code --trx_currency_code
    -- Bug#18613649 : pass creation_date if rate_date not available
    ,NVL(ph.rate_date, ph.creation_date)  --currency_conversion_date
    ,ph.rate --currency_conversion_rate
    ,ph.rate_type --currency_conversion_type
    --Bug 5474336. Pass mau to EBTax
    ,fc.minimum_accountable_unit --minimum_accountable_unit
    ,NVL(fc.precision, 2) --precision
    ,PO_CORE_S.get_default_legal_entity_id(ph.org_id) --legal_entity_id
    ,(SELECT pv.party_id FROM po_vendors pv --rounding_ship_from_party_id
      WHERE pv.vendor_id=ph.vendor_id)
    ,null --default_taxation_country
    ,'N' --quote_flag
    ,ph.segment1 --trx_number
    ,ph.comments --trx_description
    ,sysdate --ph.print_date --trx_communicated_date
    ,null --document_sub_type
    ,DECODE(ph.document_creation_method, --provnl_tax_determination_date
       'CREATE_CONSUMPTION',
       (SELECT pll.need_by_date
        FROM po_line_locations_all pll
        WHERE pll.po_header_id=ph.po_header_id
        AND pll.need_by_date IS NOT NULL
        AND rownum=1),
        null)
    -- Bug 5025018. Updated tax attribute mappings
    ,ph.org_id --rounding_bill_to_party_id
    ,(SELECT pvs.party_site_id from po_vendor_sites_all pvs --rndg_ship_from_party_site_id
      WHERE pvs.vendor_site_id=ph.vendor_site_id)
  FROM po_headers_all ph, fnd_currencies fc
  WHERE ph.po_header_id = p_po_header_id
  AND fc.currency_code = ph.currency_code;

END populate_header_po;


-----------------------------------------------------------------------------
--Start of Comments
--Name: populate_zx_headers_with_rel
--Pre-reqs:
--  None
--Modifies:
--  ZX_TRX_HEADERS_GT
--Locks:
--  ZX_TRX_HEADERS_GT
--Function:
--  Populate ZX_TRX_HEADERS_GT with transaction header data
--Parameters:
--IN:
--p_po_release_id_tbl
--  PL/SQL table with list of po_release_id's to process for tax_calculation
--p_calling_program
--  Identifies the module that calls this procedure eg. 'PDOI'
--Notes:
--  Used by calculate_tax procedure. Not to be used externally
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE populate_zx_headers_with_rel(p_po_release_id_tbl  IN  PO_TBL_NUMBER,
                                       p_calling_program    IN  VARCHAR2
) IS
BEGIN
  -- Populate zx_trx_headers_gt for Releases
  FORALL i in 1..p_po_release_id_tbl.COUNT
    INSERT INTO zx_trx_headers_gt(
      internal_organization_id
      ,application_id
      ,entity_code
      ,event_class_code
      ,event_type_code
      ,trx_id
      ,trx_date
      ,trx_doc_revision
      ,ledger_id
      ,trx_currency_code
      ,currency_conversion_date
      ,currency_conversion_rate
      ,currency_conversion_type
      ,minimum_accountable_unit --Bug 5474336. Pass mau to EBTax
      ,precision
      ,legal_entity_id
      ,rounding_ship_from_party_id
      ,default_taxation_country
      ,quote_flag
      ,trx_number
      ,trx_description
      ,trx_communicated_date
      ,document_sub_type
      ,provnl_tax_determination_date
      -- Bug 5025018. Updated tax attribute mappings
      ,rounding_bill_to_party_id
      ,rndg_ship_from_party_site_id
    )
    SELECT
      pr.org_id --internal_organization_id
      ,PO_CONSTANTS_SV.APPLICATION_ID --application_id
      ,PO_CONSTANTS_SV.REL_ENTITY_CODE --entity_code
      ,PO_CONSTANTS_SV.REL_EVENT_CLASS_CODE --event_class_code
      ,DECODE(pr.tax_attribute_update_code, --event_type_code
         'CREATE', PO_CONSTANTS_SV.REL_CREATED,
         'COPY_AND_CREATE', PO_CONSTANTS_SV.REL_CREATED,
         PO_CONSTANTS_SV.REL_ADJUSTED) -- for null and 'UPDATE'
      ,pr.po_release_id --trx_id
      ,sysdate --trx_date
      ,pr.revision_num --trx_doc_revision
      ,(select set_of_books_id  --ledger_id
        from financials_system_params_all where org_id=pr.org_id)
      ,ph.currency_code --trx_currency_code
      -- Bug#18613649 : pass creation_date if rate_date not available
      ,NVL(ph.rate_date, ph.creation_date)  --currency_conversion_date
      ,ph.rate --currency_conversion_rate
      ,ph.rate_type --currency_conversion_type
      --Bug 5474336. Pass mau to EBTax
      ,fc.minimum_accountable_unit --minimum_accountable_unit
      ,NVL(fc.precision, 2) --precision
      ,PO_CORE_S.get_default_legal_entity_id(pr.org_id) --legal_entity_id
      ,(SELECT pv.party_id FROM po_vendors pv --rounding_ship_from_party_id
        WHERE pv.vendor_id=ph.vendor_id)
      ,zxldet.default_taxation_country --default_taxation_country
      ,'N' --quote_flag
      ,ph.segment1 --trx_number
      ,null --trx_description
      ,sysdate --pr.print_date --trx_communicated_date
      ,zxldet.document_sub_type --document_sub_type
      ,DECODE(pr.document_creation_method, --provnl_tax_determination_date
         'CREATE_CONSUMPTION',
         (SELECT pll.need_by_date
          FROM po_line_locations_all pll
          WHERE pll.po_release_id=pr.po_release_id
          AND pll.need_by_date IS NOT NULL
          AND rownum=1),
          null)
      -- Bug 5025018. Updated tax attribute mappings
      ,pr.org_id --rounding_bill_to_party_id
      ,(SELECT pvs.party_site_id from po_vendor_sites_all pvs --rndg_ship_from_party_site_id
        WHERE pvs.vendor_site_id=ph.vendor_site_id)
    -- Using OUTER JOIN in FROM clause syntax here because (+) operator
    -- is not flexible enough to be used inside an OR condition
    FROM po_headers_all ph
         ,fnd_currencies fc
         ,po_releases_all pr
           -- Conditions for getting Additional Tax Attributes
           -- Copy from Planned PO if its a newly created Scheduled Release
           -- ELSE simply copy from existing release header (ie. in case of a
           -- shipment split or regular blanket/scheduled release create/update
           LEFT OUTER JOIN zx_lines_det_factors zxldet
             ON ((pr.po_header_id = zxldet.trx_id
                  AND PO_CONSTANTS_SV.APPLICATION_ID = zxldet.application_id
                  AND PO_CONSTANTS_SV.PO_ENTITY_CODE = zxldet.entity_code
                  AND PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE = zxldet.event_class_code
                  AND PO_CONSTANTS_SV.PO_TRX_LEVEL_TYPE = zxldet.trx_level_type
                  AND pr.release_type = PO_CONSTANTS_SV.SCHEDULED
                  AND pr.tax_attribute_update_code = 'CREATE')
                 OR
                 (pr.po_release_id = zxldet.trx_id
                  AND PO_CONSTANTS_SV.APPLICATION_ID = zxldet.application_id
                  AND PO_CONSTANTS_SV.REL_ENTITY_CODE = zxldet.entity_code
                  AND PO_CONSTANTS_SV.REL_EVENT_CLASS_CODE = zxldet.event_class_code
                  AND PO_CONSTANTS_SV.REL_TRX_LEVEL_TYPE = zxldet.trx_level_type)
                )
    WHERE pr.po_release_id = p_po_release_id_tbl(i)
    AND pr.po_header_id = ph.po_header_id
    AND fc.currency_code = ph.currency_code
    AND rownum = 1;

END populate_zx_headers_with_rel;


-----------------------------------------------------------------------------
--Start of Comments
--Name: populate_header_rel
--Pre-reqs:
--  None
--Modifies:
--  ZX_TRX_HEADERS_GT
--Locks:
--  ZX_TRX_HEADERS_GT
--Function:
--  Populate ZX_TRX_HEADERS_GT with transaction header data
--Parameters:
--IN:
--p_po_release_id
--  po_release_id to process for tax distribution
--Notes:
--  Used by determine_recovery_rel procedure. Not to be used externally
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE populate_header_rel(p_po_release_id  IN  NUMBER) IS
BEGIN

  -- Populate zx_trx_headers_gt for Releases
  INSERT INTO zx_trx_headers_gt(
    internal_organization_id
    ,application_id
    ,entity_code
    ,event_class_code
    ,event_type_code
    ,trx_id
    ,trx_date
    ,trx_doc_revision
    ,ledger_id
    ,trx_currency_code
    ,currency_conversion_date
    ,currency_conversion_rate
    ,currency_conversion_type
    ,minimum_accountable_unit --Bug 5474336. Pass mau to EBTax
    ,precision
    ,legal_entity_id
    ,rounding_ship_from_party_id
    ,default_taxation_country
    ,quote_flag
    ,trx_number
    ,trx_description
    ,trx_communicated_date
    ,document_sub_type
    ,provnl_tax_determination_date
    -- Bug 5025018. Updated tax attribute mappings
    ,rounding_bill_to_party_id
    ,rndg_ship_from_party_site_id
  )
  SELECT
    pr.org_id --internal_organization_id
    ,PO_CONSTANTS_SV.APPLICATION_ID --application_id
    ,PO_CONSTANTS_SV.REL_ENTITY_CODE --entity_code
    ,PO_CONSTANTS_SV.REL_EVENT_CLASS_CODE --event_class_code
    ,PO_CONSTANTS_SV.REL_REDISTRIBUTED --event_type_code
    ,pr.po_release_id --trx_id
    ,sysdate --trx_date
    ,pr.revision_num --trx_doc_revision
    ,(select set_of_books_id  --ledger_id
      from financials_system_params_all where org_id=pr.org_id)
    ,ph.currency_code --trx_currency_code
    -- Bug#18613649 : pass creation_date if rate_date not available
    ,NVL(ph.rate_date, ph.creation_date)  --currency_conversion_date
    ,ph.rate --currency_conversion_rate
    ,ph.rate_type --currency_conversion_type
    --Bug 5474336. Pass mau to EBTax
    ,fc.minimum_accountable_unit --minimum_accountable_unit
    ,NVL(fc.precision, 2) --precision
    ,PO_CORE_S.get_default_legal_entity_id(pr.org_id) --legal_entity_id
    ,(SELECT pv.party_id FROM po_vendors pv --rounding_ship_from_party_id
      WHERE pv.vendor_id=ph.vendor_id)
    ,null --default_taxation_country
    ,'N' --quote_flag
    ,ph.segment1 --trx_number
    ,null --trx_description
    ,sysdate --pr.print_date --trx_communicated_date
    ,null --document_sub_type
    ,DECODE(pr.document_creation_method, --provnl_tax_determination_date
       'CREATE_CONSUMPTION',
       (SELECT pll.need_by_date
        FROM po_line_locations_all pll
        WHERE pll.po_release_id=pr.po_release_id
        AND pll.need_by_date IS NOT NULL
        AND rownum=1),
        null)
    -- Bug 5025018. Updated tax attribute mappings
    ,ph.org_id --rounding_bill_to_party_id
    ,(SELECT pvs.party_site_id from po_vendor_sites_all pvs --rndg_ship_from_party_site_id
      WHERE pvs.vendor_site_id=ph.vendor_site_id)
  FROM po_releases_all pr, po_headers_all ph, fnd_currencies fc
  WHERE pr.po_release_id = p_po_release_id
  AND pr.po_header_id = ph.po_header_id
  AND fc.currency_code = ph.currency_code;

END populate_header_rel;


-----------------------------------------------------------------------------
--Start of Comments
--Name: populate_zx_headers_with_req
--Pre-reqs:
--  None
--Modifies:
--  ZX_TRX_HEADERS_GT
--Locks:
--  ZX_TRX_HEADERS_GT
--Function:
--  Populate ZX_TRX_HEADERS_GT with transaction header data
--Parameters:
--IN:
--p_requisition_header_id
--  PL/SQL table with list of po_header_id's to process for tax_calculation
--p_calling_program
--  Identifies the module that calls this procedure eg. 'PDOI'
--Notes:
--  Used by calculate_tax_requisition procedure. Not to be used externally
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE populate_zx_headers_with_req(p_requisition_header_id  IN  NUMBER,
                                       p_calling_program        IN  VARCHAR2
) IS
BEGIN
  -- populate zx_trx_headers_gt for the requisition
  -- Addition/Removal of any attribute entails similar change in
  -- populate_zx_record as well
  INSERT INTO zx_trx_headers_gt(
    internal_organization_id
    ,application_id
    ,entity_code
    ,event_class_code
    ,event_type_code
    ,trx_id
    ,trx_date
    ,ledger_id
    ,legal_entity_id
    ,rounding_bill_to_party_id
    ,quote_flag
    ,document_sub_type
    ,default_taxation_country
    ,icx_session_id
  )
  SELECT
    prh.org_id --internal_organization_id
    ,PO_CONSTANTS_SV.APPLICATION_ID --application_id
    ,PO_CONSTANTS_SV.REQ_ENTITY_CODE --entity_code
    ,PO_CONSTANTS_SV.REQ_EVENT_CLASS_CODE --event_class_code
    ,DECODE(p_calling_program, --event_type_code
      --If calling determine_recovery from ATI page flow
      'DETERMINE_RECOVERY_REQ', PO_CONSTANTS_SV.REQ_DISTRIBUTED,
      --Regular UI flow
      PO_CONSTANTS_SV.REQ_CREATED)
    ,prh.requisition_header_id --trx_id
    ,sysdate --trx_date
    ,(select set_of_books_id  --ledger_id
      from financials_system_params_all where org_id=prh.org_id)
    ,PO_CORE_S.get_default_legal_entity_id(prh.org_id) --legal_entity_id
    ,prh.org_id --rounding_bill_to_party_id
    ,'Y' --quote_flag
    ,zxldet.document_sub_type --document_sub_type
    ,zxldet.default_taxation_country --default_taxation_country
    ,DECODE(p_calling_program, --icx_session_id
      'DETERMINE_RECOVERY_REQ', null,
      FND_GLOBAL.session_id)
  FROM po_requisition_headers_all prh, zx_lines_det_factors zxldet
  WHERE prh.requisition_header_id = p_requisition_header_id
  -- Conditions for getting Additional Tax Attributes
  -- Note that the req_header_id is of current document being processed,
  -- not of any source document. Get the first row obtained from join
  -- with zx_lines_det_factors because that table is denormalized
  AND zxldet.trx_id(+) = prh.requisition_header_id
  AND zxldet.application_id(+) = PO_CONSTANTS_SV.APPLICATION_ID
  AND zxldet.entity_code(+) = PO_CONSTANTS_SV.REQ_ENTITY_CODE
  AND zxldet.event_class_code(+) = PO_CONSTANTS_SV.REQ_EVENT_CLASS_CODE
  AND zxldet.trx_level_type(+) = PO_CONSTANTS_SV.REQ_TRX_LEVEL_TYPE
  AND rownum = 1;

END populate_zx_headers_with_req;

/* Bug 11665348: Modified the procedures populate_zx_lines_with_po and
populate_zx_lines_with_rel so that they will dump the data into zx_transaction_lines_gt
only for the PO shipments which are not received and not billed and not shipped.
*/
-----------------------------------------------------------------------------
--Start of Comments
--Name: populate_zx_lines_with_po
--Pre-reqs:
--  None
--Modifies:
--  ZX_TRANSACTION_LINES_GT
--Locks:
--  ZX_TRANSACTION_LINES_GT
--Function:
--  Populate ZX_TRANSACTION_LINES_GT with transaction line and shipment data
--  which are not received/billed
--Parameters:
--IN:
--p_po_header_id_tbl
--  PL/SQL table with list of po_header_id's to process for tax_calculation
--p_calling_program
--  Identifies the module that calls this procedure eg. 'PDOI'
--Notes:
--  Used by calculate_tax procedure. Not to be used externally
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE populate_zx_lines_with_po(p_po_header_id_tbl  IN  PO_TBL_NUMBER,
                                    p_calling_program   IN  VARCHAR2
) IS
BEGIN

    -- Populate zx_transaction_lines_gt for POs
  FORALL i in 1..p_po_header_id_tbl.COUNT
    INSERT INTO zx_transaction_lines_gt(
      application_id
      ,entity_code
      ,event_class_code
      ,trx_id
      ,trx_level_type
      ,trx_line_id
      ,line_level_action
      ,line_class
      ,trx_line_type
      ,trx_line_date
      ,trx_business_category
      ,line_intended_use
      ,user_defined_fisc_class
      ,line_amt
      ,trx_line_quantity
      ,product_id
      ,product_org_id
      ,product_fisc_classification
      ,uom_code
      ,product_type
      ,product_code
      ,product_category
      ,fob_point
      ,ship_from_party_id
      ,bill_from_party_id
      ,ship_from_party_site_id
      ,bill_from_party_site_id
      ,ship_to_location_id
      ,ship_from_location_id
      ,bill_to_location_id
      ,bill_from_location_id /* 6524317 */
      ,account_ccid
      ,ref_doc_application_id
      ,ref_doc_entity_code
      ,ref_doc_event_class_code
      ,ref_doc_trx_id
      ,ref_doc_line_id
      ,line_trx_user_key1
      ,line_trx_user_key2
      -- Bug 5079867. Ordering of complex work payment lines in ATI page
      ,line_trx_user_key3
      ,trx_line_number
      ,trx_line_description
      ,product_description
      ,assessable_value
      ,line_amt_includes_tax_flag
      ,input_tax_classification_code
      ,source_application_id
      ,source_entity_code
      ,source_event_class_code
      ,source_trx_id
      ,source_line_id
      ,source_trx_level_type
      ,unit_price
      ,ref_doc_trx_level_type
      -- Bug 5025018. Updated tax attribute mappings
      ,ship_third_pty_acct_id
      ,bill_third_pty_acct_id
      ,ship_third_pty_acct_site_id
      ,bill_third_pty_acct_site_id
      ,ship_to_party_id
      ,user_upd_det_factors_flag --Bug 5632300
      ,defaulting_attribute1 --Bug#6902111
    )
    SELECT
      PO_CONSTANTS_SV.APPLICATION_ID --application_id
      ,PO_CONSTANTS_SV.PO_ENTITY_CODE --entity_code
      ,PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE --event_class_code
      ,ph.po_header_id --trx_id
      ,PO_CONSTANTS_SV.PO_TRX_LEVEL_TYPE --trx_level_type
      ,pll.line_location_id --trx_line_id
      ,pll.tax_attribute_update_code --line_level_action
      ,DECODE(pll.shipment_type,--line_class
              'PREPAYMENT', DECODE(pll.payment_type,
                                   'ADVANCE', 'ADVANCE',
                                   'FINANCING'),
              DECODE(pll.value_basis,
                     'QUANTITY', 'INVOICE',
                     'AMOUNT_MATCHED') /* Modified for bug 1018858 ,'AMOUNT' is not valid zx_line_class,so changed it to be 'AMOUNT_MATCHED'*/
             )
      ,'ITEM' --trx_line_type
      ,COALESCE(pll.need_by_date, pll.promised_date, sysdate) --trx_line_date
      ,DECODE(p_calling_program, --trx_business_category
              'COPY_DOCUMENT', null,
              zxldet.trx_business_category)
      ,DECODE(p_calling_program, --line_intended_use
              'COPY_DOCUMENT', null,
              zxldet.line_intended_use)
      ,DECODE(p_calling_program, --user_defined_fisc_class
              'COPY_DOCUMENT', null,
              zxldet.user_defined_fisc_class)
      ,NVL(pll.amount, pll.price_override*pll.quantity) --line_amt
      ,pll.quantity --trx_line_quantity
      ,pl.item_id --product_id
       -- Bug 5335818. Pass in inventory_organization_id
      ,(SELECT fsp.inventory_organization_id --product_org_id
        FROM financials_system_params_all fsp
        WHERE fsp.org_id=pll.org_id)
      ,DECODE(p_calling_program, --product_fisc_classification
              'COPY_DOCUMENT', null,
              zxldet.product_fisc_classification)
      ,(SELECT mum.uom_code FROM mtl_units_of_measure mum
        WHERE mum.unit_of_measure=pll.unit_meas_lookup_code) --uom_code
      ,DECODE(p_calling_program, --product_type
              'COPY_DOCUMENT', null,
              zxldet.product_type)
      ,msib.segment1 --product_code
      ,DECODE(p_calling_program, --product_category
              'COPY_DOCUMENT', null,
              zxldet.product_category)
      ,ph.fob_lookup_code --fob_point
      ,pv.party_id --ship_from_party_id
      ,pv.party_id --bill_from_party_id
      ,pvs.party_site_id --ship_from_party_site_id
      ,pvs.party_site_id --bill_from_party_site_id
      ,pll.ship_to_location_id --ship_to_location_id
      ,(SELECT hzps.location_id --ship_from_location_id
        FROM hz_party_sites hzps
        WHERE hzps.party_site_id = pvs.party_site_id)
      ,ph.bill_to_location_id --bill_to_location_id
      ,(SELECT pvs.location_id from po_vendor_sites_all pvs   /* 6524317 - Passing Location Id as Bill From Location Id */
        WHERE pvs.vendor_site_id=ph.vendor_site_id)
      -- Get account id from first distribution, if created
      -- otherwise from the expense account of the item
      ,NVL((SELECT pd.code_combination_id --account_ccid
            FROM po_distributions_all pd
            WHERE pd.line_location_id = pll.line_location_id
            AND rownum = 1),
           msib.expense_account
          )
      ,null --ref_doc_application_id
      ,null --ref_doc_entity_code
      ,null --ref_doc_event_class_code
      ,null --ref_doc_trx_id
      ,null --ref_doc_line_id
      ,pl.line_num --line_trx_user_key1
      ,PO_LOCATIONS_S.get_location_code(pll.ship_to_location_id) --line_trx_user_key2
      -- Bug 5079867. Ordering of complex work payment lines in ATI page
      ,DECODE(pll.payment_type, null, 0, --line_trx_user_key3
                'DELIVERY', 1,
                'ADVANCE', 2, 3)
      ,DECODE(pll.payment_type, --trx_line_number
              'ADVANCE', null,
              'DELIVERY', null,
              pll.shipment_num)
      ,DECODE(pll.shipment_type, --trx_line_description
              'STANDARD', DECODE(pll.payment_type,
                                 null, pl.item_description, --non complex work Standard PO
                                 pll.description --complex work Standard PO
                                ),
              pl.item_description -- for shipment_type='PLANNED'
             )
      ,DECODE(pll.shipment_type, --product_description
              'STANDARD', DECODE(pll.payment_type,
                                 null, pl.item_description, --non complex work Standard PO
                                 pll.description --complex work Standard PO
                                ),
              pl.item_description -- for shipment_type='PLANNED'
             )
      ,DECODE(p_calling_program, --assessable_value
              'COPY_DOCUMENT', null,
              zxldet.assessable_value)
      ,'N' --line_amt_includes_tax_flag
      --<<PDOI Enhancement bug#17063664 START>>
      -- The shipments can be updated through PDOI
      -- having requisition reference and new requisition
      -- line matches to the existing line and shipment
      -- In that case ,the tax name on the shipment should
      -- not be consideredto pass to zx table
      -- The tax name in po_line_locations_all table
      -- is updated to NULL value for all updated shipments
      -- when called from PDOI and restored back after
      -- at the caller after calculate tax api is completed.
      -- Tax classfication will be overridden from PDOI
      -- only when new shipments are being created.
      ,DECODE(p_calling_program, --input_tax_classification_code
              'PDOI', NVL(pll.tax_name,zxldet.input_tax_classification_code),
              'COPY_DOCUMENT', null,
              zxldet.input_tax_classification_code)
        --<<PDOI Enhancement bug#17063664 END>>
      -- Bug 7337548
      -- Copying requisition information as Source Document Information
      -- in case of Autocreate. This information will be used to copy
      -- Tax attributes when the attributes are overridden in requisition.
      -- Calling program for autocreate is 'AUTOCREATE','AUTOCREATED_DOC_WF'
      -- and 'PORELGEB'
      --<<PDOI Enhancement bug#17063664 START>>
      -- Added code to pass source information from PDOI
      -- if shipment is having requisition reference
      -- Source information is considered only if
      -- tax name is not provided in the interface tables
      ,DECODE(p_calling_program, --source_application_id
              'COPY_DOCUMENT', PO_CONSTANTS_SV.APPLICATION_ID,
              'AUTOCREATE', PO_CONSTANTS_SV.APPLICATION_ID,
              'AUTOCREATED_DOC_WF' ,PO_CONSTANTS_SV.APPLICATION_ID,
              'PORELGEB',PO_CONSTANTS_SV.APPLICATION_ID,
	      'PDOI',DECODE(pll.tax_name ,NULL
	                     ,DECODE(prl.min_req_line_id, NULL ,NULL,PO_CONSTANTS_SV.APPLICATION_ID)
			     ,NULL),
              null)
      ,DECODE(p_calling_program, --source_entity_code
              'COPY_DOCUMENT', PO_CONSTANTS_SV.PO_ENTITY_CODE,
              'AUTOCREATE', PO_CONSTANTS_SV.REQ_ENTITY_CODE,
              'AUTOCREATED_DOC_WF', PO_CONSTANTS_SV.REQ_ENTITY_CODE,
              'PORELGEB', PO_CONSTANTS_SV.REQ_ENTITY_CODE,
              'PDOI',DECODE(pll.tax_name ,NULL
	                     ,DECODE(prl.min_req_line_id, NULL ,NULL,PO_CONSTANTS_SV.REQ_ENTITY_CODE)
			     ,NULL),
              null)
      ,DECODE(p_calling_program, --source_event_class_code
              'COPY_DOCUMENT', PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE,
              'AUTOCREATE', PO_CONSTANTS_SV.REQ_EVENT_CLASS_CODE,
              'AUTOCREATED_DOC_WF', PO_CONSTANTS_SV.REQ_EVENT_CLASS_CODE,
              'PORELGEB', PO_CONSTANTS_SV.REQ_EVENT_CLASS_CODE,
              'PDOI',DECODE(pll.tax_name ,NULL
	                     ,DECODE(prl.min_req_line_id, NULL ,NULL,PO_CONSTANTS_SV.REQ_EVENT_CLASS_CODE)
			     ,NULL),
              null)
      ,DECODE(p_calling_program, -- source_trx_id
              'COPY_DOCUMENT', (SELECT source_shipment.po_header_id --source_trx_id
                                FROM po_line_locations_all source_shipment
                                WHERE source_shipment.line_location_id = pll.original_shipment_id
                                AND p_calling_program = 'COPY_DOCUMENT'),

              'AUTOCREATE',  (SELECT requisition_header_id      --source_trx_id
	                      FROM   po_requisition_lines_all
			      WHERE  requisition_line_id = prl.min_req_line_id
			      ),
              'AUTOCREATED_DOC_WF', (SELECT requisition_header_id      --source_trx_id
  	                             FROM   po_requisition_lines_all
			             WHERE  requisition_line_id = prl.min_req_line_id
			             ),
              'PORELGEB', (SELECT requisition_header_id      --source_trx_id
  	                   FROM   po_requisition_lines_all
			   WHERE  requisition_line_id = prl.min_req_line_id
			  ),
               'PDOI',DECODE(pll.tax_name ,NULL   --source_trx_id
	                     ,DECODE(prl.min_req_line_id, NULL ,NULL,
			              ( SELECT requisition_header_id
  	                                FROM   po_requisition_lines_all
			                WHERE  requisition_line_id = prl.min_req_line_id
				      )
				    )
			     ,NULL),
              null)
      ,DECODE(p_calling_program, --source_line_id
              'COPY_DOCUMENT', pll.original_shipment_id,
              'AUTOCREATE',prl.min_req_line_id,
              'AUTOCREATED_DOC_WF',prl.min_req_line_id,
              'PORELGEB',prl.min_req_line_id,
              'PDOI',DECODE(pll.tax_name ,NULL
	                     ,DECODE(prl.min_req_line_id, NULL ,NULL,prl.min_req_line_id)
			     ,NULL),
              null)
      ,DECODE(p_calling_program, --source_trx_level_type
              'COPY_DOCUMENT', PO_CONSTANTS_SV.PO_TRX_LEVEL_TYPE,
              'AUTOCREATE', PO_CONSTANTS_SV.REQ_TRX_LEVEL_TYPE ,
	      'AUTOCREATED_DOC_WF', PO_CONSTANTS_SV.REQ_TRX_LEVEL_TYPE ,
              'PORELGEB', PO_CONSTANTS_SV.REQ_TRX_LEVEL_TYPE ,
              'PDOI',DECODE(pll.tax_name ,NULL
	                     ,DECODE(prl.min_req_line_id, NULL ,NULL, PO_CONSTANTS_SV.REQ_TRX_LEVEL_TYPE)
			     ,NULL),
              null)
      ,pll.price_override --unit_price
      ,null --ref_doc_trx_level_type
      -- Bug 5025018. Updated tax attribute mappings
      ,pv.vendor_id --ship_third_pty_acct_id
      ,pv.vendor_id --bill_third_pty_acct_id
      ,pvs.vendor_site_id --ship_third_pty_acct_site_id
      ,pvs.vendor_site_id --bill_third_pty_acct_site_id
      ,pll.ship_to_organization_id --ship_to_party_id
      --Bug 5632300. Parameter to confirm that tax classification is overridden
      ,(SELECT 'Y' FROM DUAL --user_upd_det_factors_flag
        WHERE p_calling_program = 'PDOI'
        AND pll.tax_name IS NOT NULL)
      ,pll.ship_to_organization_id  --Bug#6902111
    FROM po_headers_all ph, po_lines_all pl, po_line_locations_all pll,
         zx_lines_det_factors zxldet, po_vendors pv,
         po_vendor_sites_all pvs, mtl_system_items_b msib,
         --<<PDOI Enhancement Bug#17063664 START>>
	 -- Added from clause query to get min requisition line ids
         -- for all shipments of the Purchase order
         (SELECT poll.line_location_id , MIN(prl.requisition_line_id) min_req_line_id
	  FROM  po_line_locations_all poll,po_requisition_lines_all prl
	  WHERE poll.po_header_id =  p_po_header_id_tbl(i)
	  AND   poll.line_location_id = prl.line_location_id(+)
          GROUP BY poll.line_location_id
	 ) prl
	 --<<PDOI Enhancement Bug#17063664 END>>
    WHERE ph.po_header_id = pll.po_header_id
    AND pl.po_line_id = pll.po_line_id
    ---Bug# 13091627 : Condition added to exclude the Release shipments for BLANKET/PLANNED PO
    AND pll.po_release_id IS NULL
    AND pll.tax_attribute_update_code IS NOT NULL
    AND pll.tax_attribute_update_code <> 'DIST_DELETE'
    -- Bug 11665348
    AND Nvl(pll.quantity_billed,0)=0
    AND Nvl(pll.quantity_received,0)=0
    AND Nvl(pll.quantity_shipped,0)=0
    AND Nvl(pll.amount_billed,0)=0
    AND Nvl(pll.amount_received,0)=0
    AND Nvl(pll.amount_shipped,0)=0
     -- end bug 11665348

    AND ph.po_header_id = p_po_header_id_tbl(i)
    -- Conditions for getting Additional Tax Attributes
    --  Do not put a condition on zxldet.trx_id here because that would
    --  entail bringing the source_header_id for the shipment being currently
    --  processed. Join with trx_line_id itself is unique because the document
    --  type has been classified with event_class_code and line_location_id
    --  will always be unique whether PO shipment or Release shipment
    AND zxldet.application_id(+) = PO_CONSTANTS_SV.APPLICATION_ID
    AND zxldet.entity_code(+) = PO_CONSTANTS_SV.PO_ENTITY_CODE
    AND zxldet.event_class_code(+) = PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE
    AND zxldet.trx_level_type(+) = PO_CONSTANTS_SV.PO_TRX_LEVEL_TYPE
    AND zxldet.trx_line_id(+) = pll.original_shipment_id
	AND zxldet.trx_id(+) = p_po_header_id_tbl(i)--bug:19892170
    -- Join with vendor tables to get party and party site information
    AND pv.vendor_id(+) = ph.vendor_id
    AND pvs.vendor_site_id(+) = ph.vendor_site_id
    -- Join with items table for item information
    AND msib.inventory_item_id(+) = pl.item_id
    AND msib.organization_id(+) = pl.org_id
    AND prl.line_location_id   =  pll.line_location_id;--<PDOI Enhancement Bug#17063664
    -- Conditions that determine that po line is 'Active'
    --AND nvl(pl.cancel_flag,'N') = 'N'
    --AND nvl(pl.closed_code,'OPEN') <> 'FINALLY CLOSED'
    --AND nvl(pll.cancel_flag,'N') = 'N'
    --AND nvl(pll.closed_code,'OPEN') <> 'FINALLY CLOSED';

END populate_zx_lines_with_po;


-----------------------------------------------------------------------------
--Start of Comments
--Name: populate_zx_lines_with_rel
--Pre-reqs:
--  None
--Modifies:
--  ZX_TRANSACTION_LINES_GT
--Locks:
--  ZX_TRANSACTION_LINES_GT
--Function:
--  Populate ZX_TRANSACTION_LINES_GT with transaction line and shipment data
--  which are not received/billed
--Parameters:
--IN:
--p_po_release_id_tbl
--  PL/SQL table with list of po_release_id's to process for tax_calculation
--p_calling_program
--  Identifies the module that calls this procedure eg. 'PDOI'
--Notes:
--  Used by calculate_tax procedure. Not to be used externally
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE populate_zx_lines_with_rel(p_po_release_id_tbl  IN  PO_TBL_NUMBER,
                                     p_calling_program    IN  VARCHAR2
) IS
BEGIN
  -- Populate zx_transaction_lines_gt for Releases
  FORALL i IN 1..p_po_release_id_tbl.COUNT
    INSERT INTO zx_transaction_lines_gt(
      application_id
      ,entity_code
      ,event_class_code
      ,trx_id
      ,trx_level_type
      ,trx_line_id
      ,line_level_action
      ,line_class
      ,trx_line_type
      ,trx_line_date
      ,trx_business_category
      ,line_intended_use
      ,user_defined_fisc_class
      ,line_amt
      ,trx_line_quantity
      ,product_id
      ,product_org_id
      ,product_fisc_classification
      ,uom_code
      ,product_type
      ,product_code
      ,product_category
      ,fob_point
      ,ship_from_party_id
      ,bill_from_party_id
      ,ship_from_party_site_id
      ,bill_from_party_site_id
      ,ship_to_location_id
      ,ship_from_location_id
      ,bill_to_location_id
      ,bill_from_location_id   /* 6524317 */
      ,account_ccid
      ,ref_doc_application_id
      ,ref_doc_entity_code
      ,ref_doc_event_class_code
      ,ref_doc_trx_id
      ,ref_doc_line_id
      ,line_trx_user_key1
      ,line_trx_user_key2
      ,trx_line_number
      ,trx_line_description
      ,product_description
      ,assessable_value
      ,line_amt_includes_tax_flag
      ,input_tax_classification_code
      ,source_application_id
      ,source_entity_code
      ,source_event_class_code
      ,source_trx_id
      ,source_line_id
      ,source_trx_level_type
      ,unit_price
      ,ref_doc_trx_level_type
      -- Bug 5025018. Updated tax attribute mappings
      ,ref_doc_line_quantity
      ,ship_third_pty_acct_id
      ,bill_third_pty_acct_id
      ,ship_third_pty_acct_site_id
      ,bill_third_pty_acct_site_id
      ,ship_to_party_id
      ,defaulting_attribute1 --Bug#6902111
    )
    SELECT
      PO_CONSTANTS_SV.APPLICATION_ID --application_id
      ,PO_CONSTANTS_SV.REL_ENTITY_CODE --entity_code
      ,PO_CONSTANTS_SV.REL_EVENT_CLASS_CODE --event_class_code
      ,pr.po_release_id --trx_id
      ,PO_CONSTANTS_SV.REL_TRX_LEVEL_TYPE --trx_level_type
      ,pll.line_location_id --trx_line_id
      ,pll.tax_attribute_update_code --line_level_action
      ,DECODE(pll.shipment_type,--line_class
              'PREPAYMENT', DECODE(pll.payment_type,
                                   'ADVANCE', 'ADVANCE',
                                   'FINANCING'),
              DECODE(pll.value_basis,
                     'QUANTITY', 'INVOICE',
                     'AMOUNT')
             )
      ,'ITEM' --trx_line_type
      ,COALESCE(pll.need_by_date, pll.promised_date, sysdate) --trx_line_date
      ,zxldet.trx_business_category --trx_business_category
      ,zxldet.line_intended_use --line_intended_use
      ,zxldet.user_defined_fisc_class --user_defined_fisc_class
      ,nvl(pll.amount, pll.price_override*pll.quantity) --line_amt
      ,pll.quantity --trx_line_quantity
      ,pl.item_id --product_id
       -- Bug 5335818. Pass in inventory_organization_id
      ,(SELECT fsp.inventory_organization_id --product_org_id
        FROM financials_system_params_all fsp
        WHERE fsp.org_id=pll.org_id)
      ,zxldet.product_fisc_classification --product_fisc_classification
      ,(SELECT mum.uom_code FROM mtl_units_of_measure mum
        WHERE mum.unit_of_measure=pll.unit_meas_lookup_code) --uom_code
      ,zxldet.product_type --product_type
      ,msib.segment1 --product_code
      ,zxldet.product_category --product_category
      ,ph.fob_lookup_code --fob_point
      ,pov.party_id --ship_from_party_id
      ,pov.party_id --bill_from_party_id
      ,pvs.party_site_id --ship_from_party_site_id
      ,pvs.party_site_id --bill_from_party_site_id
      ,pll.ship_to_location_id --ship_to_location_id
      ,(SELECT hzps.location_id --ship_from_location_id
        FROM hz_party_sites hzps
        WHERE hzps.party_site_id = pvs.party_site_id)
      ,ph.bill_to_location_id --bill_to_location_id
      ,(SELECT pvs.location_id from po_vendor_sites_all pvs   /* 6524317 - Passing Location Id as Bill From Location Id */
        WHERE pvs.vendor_site_id=ph.vendor_site_id)
      -- Get account id from first distribution, if created
      -- otherwise from the expense account of the item
      ,NVL((SELECT pd.code_combination_id --account_ccid
            FROM po_distributions_all pd
            WHERE pd.line_location_id = pll.line_location_id
            AND rownum = 1),
           msib.expense_account
          )
      -- If scheduled release, pass Planned PO as a reference
      ,DECODE(pr.release_type, --ref_doc_application_id
              PO_CONSTANTS_SV.SCHEDULED, PO_CONSTANTS_SV.APPLICATION_ID,
              null)
      ,DECODE(pr.release_type, --ref_doc_entity_code
              PO_CONSTANTS_SV.SCHEDULED, PO_CONSTANTS_SV.PO_ENTITY_CODE,
              null)
      ,DECODE(pr.release_type, --ref_doc_event_class_code
              PO_CONSTANTS_SV.SCHEDULED, PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE,
              null)
      ,DECODE(pr.release_type, --ref_doc_trx_id
              PO_CONSTANTS_SV.SCHEDULED, pr.po_header_id,
              null)
      ,DECODE(pr.release_type, --ref_doc_line_id
              PO_CONSTANTS_SV.SCHEDULED, pll.po_line_id,
              null)
      ,pl.line_num --line_trx_user_key1
      ,PO_LOCATIONS_S.get_location_code(pll.ship_to_location_id) --line_trx_user_key2
      ,DECODE(pll.payment_type, --trx_line_number
              'ADVANCE', null,
              'DELIVERY', null,
              pll.shipment_num)
      ,DECODE(pll.shipment_type, --trx_line_description
              'STANDARD', DECODE(pll.payment_type,
                                 null, pl.item_description, --non complex work Standard PO
                                 pll.description --complex work Standard PO
                                ),
              pl.item_description -- for shipment_type='PLANNED'
             )
      ,DECODE(pll.shipment_type, --product_description
              'STANDARD', DECODE(pll.payment_type,
                                 null, pl.item_description, --non complex work Standard PO
                                 pll.description --complex work Standard PO
                                ),
              pl.item_description -- for shipment_type='PLANNED'
             )
      ,zxldet.assessable_value --assessable_value
      ,'N' --line_amt_includes_tax_flag
      -- Releases cannot be created through PDOI
      ,zxldet.input_tax_classification_code --input_tax_classification_code
      -- Bug 7337548
      -- Copying requisition information as Source Document Information
      -- in case of Autocreate. This information will be used to copy
      -- Tax attributes when the attributes are overridden in requisition.
      -- Calling program for autocreate is 'AUTOCREATE','AUTOCREATED_DOC_WF'
      -- and 'PORELGEB'
      ,DECODE(p_calling_program, --source_application_id
              'AUTOCREATE', PO_CONSTANTS_SV.APPLICATION_ID,
              'AUTOCREATED_DOC_WF', PO_CONSTANTS_SV.APPLICATION_ID,
              'PORELGEB', PO_CONSTANTS_SV.APPLICATION_ID,
              null)
      ,DECODE(p_calling_program, --source_entity_code
              'AUTOCREATE', PO_CONSTANTS_SV.REQ_ENTITY_CODE,
              'AUTOCREATED_DOC_WF', PO_CONSTANTS_SV.REQ_ENTITY_CODE,
              'PORELGEB', PO_CONSTANTS_SV.REQ_ENTITY_CODE,
              null)
      ,DECODE(p_calling_program, --source_event_class_code
              'AUTOCREATE', PO_CONSTANTS_SV.REQ_EVENT_CLASS_CODE,
              'AUTOCREATED_DOC_WF', PO_CONSTANTS_SV.REQ_EVENT_CLASS_CODE,
              'PORELGEB', PO_CONSTANTS_SV.REQ_EVENT_CLASS_CODE,
              null)
      ,DECODE(p_calling_program, -- source_trx_id
              'AUTOCREATE',  (SELECT requisition_header_id FROM
                                po_requisition_lines_all
                                WHERE  requisition_line_id IN (SELECT Min(requisition_line_id)    --source_trx_id
                                                               FROM po_requisition_lines_all prl
                                                               WHERE prl.line_location_id = pll.line_location_id)
                                AND p_calling_program = 'AUTOCREATE'),
 	      'AUTOCREATED_DOC_WF',  (SELECT requisition_header_id FROM
                                po_requisition_lines_all
                                WHERE  requisition_line_id IN (SELECT Min(requisition_line_id)    --source_trx_id
                                                               FROM po_requisition_lines_all prl
                                                               WHERE prl.line_location_id = pll.line_location_id)
                                AND p_calling_program = 'AUTOCREATED_DOC_WF'),
 	       'PORELGEB',  (SELECT requisition_header_id FROM
                                po_requisition_lines_all
                                WHERE  requisition_line_id IN (SELECT Min(requisition_line_id)    --source_trx_id
                                                               FROM po_requisition_lines_all prl
                                                               WHERE prl.line_location_id = pll.line_location_id)
                                AND p_calling_program = 'PORELGEB'),
              null)
      ,DECODE(p_calling_program, --source_line_id
              'AUTOCREATE',(SELECT Min(requisition_line_id)    --source_line_id
                             FROM po_requisition_lines_all prl
                             WHERE prl.line_location_id = pll.line_location_id
                             AND p_calling_program = 'AUTOCREATE'),
              'AUTOCREATED_DOC_WF',(SELECT Min(requisition_line_id)    --source_line_id
                             FROM po_requisition_lines_all prl
                             WHERE prl.line_location_id = pll.line_location_id
                             AND p_calling_program = 'AUTOCREATED_DOC_WF'),
              'PORELGEB',(SELECT Min(requisition_line_id)    --source_line_id
                             FROM po_requisition_lines_all prl
                             WHERE prl.line_location_id = pll.line_location_id
                             AND p_calling_program = 'PORELGEB'),
			 null)
      ,DECODE(p_calling_program, --source_trx_level_type
              'AUTOCREATE', PO_CONSTANTS_SV.REQ_TRX_LEVEL_TYPE ,
              'AUTOCREATED_DOC_WF', PO_CONSTANTS_SV.REQ_TRX_LEVEL_TYPE ,
              'PORELGEB', PO_CONSTANTS_SV.REQ_TRX_LEVEL_TYPE ,
              null)
      ,pll.price_override --unit_price
      ,DECODE(pr.release_type, --ref_doc_trx_level_type
              PO_CONSTANTS_SV.SCHEDULED, PO_CONSTANTS_SV.PO_TRX_LEVEL_TYPE,
              null)
      -- Bug 5025018. Updated tax attribute mappings
      ,DECODE(pr.release_type, --ref_doc_line_quantity
              PO_CONSTANTS_SV.SCHEDULED, pll.quantity,
              null)
      ,pov.vendor_id --ship_third_pty_acct_id
      ,pov.vendor_id --bill_third_pty_acct_id
      ,pvs.vendor_site_id --ship_third_pty_acct_site_id
      ,pvs.vendor_site_id --bill_third_pty_acct_site_id
      ,pll.ship_to_organization_id --ship_to_party_id
	  ,pll.ship_to_organization_id  --Bug#6902111
    -- Using OUTER JOIN in FROM clause syntax here because (+) operator
    -- is not flexible enough to be used inside an OR condition
    FROM po_releases_all pr
         ,po_headers_all ph
           -- Join with vendor tables to get party and party site information
           LEFT OUTER JOIN po_vendors pov ON (ph.vendor_id = pov.vendor_id)
           LEFT OUTER JOIN po_vendor_sites_all pvs
             ON (ph.vendor_site_id = pvs.vendor_site_id)
         ,po_lines_all pl--Blanket/Scheduled header and line
           -- Join with items table for item information
           LEFT OUTER JOIN mtl_system_items_b msib
             ON (pl.item_id = msib.inventory_item_id
                 AND pl.org_id = msib.organization_id)
         ,po_line_locations_all pll
           -- Conditions for getting Additional Tax Attributes
           --  Do not put a condition on zxldet.trx_id here because that would
           --  entail bringing the source_header_id for the shipment being
           --  currently processed. Join with trx_line_id itself is unique
           --  because the document type has been classified with
           --  event_class_code and line_location_id will always be unique
           --  whether PO shipment or Release shipment
           LEFT OUTER JOIN zx_lines_det_factors zxldet ON
            ((PO_CONSTANTS_SV.APPLICATION_ID = zxldet.application_id
              AND PO_CONSTANTS_SV.REL_ENTITY_CODE = zxldet.entity_code
              AND PO_CONSTANTS_SV.REL_EVENT_CLASS_CODE = zxldet.event_class_code
              AND PO_CONSTANTS_SV.REL_TRX_LEVEL_TYPE = zxldet.trx_level_type
              AND pll.original_shipment_id = zxldet.trx_line_id
              AND pll.original_shipment_id IS NOT NULL)
             OR
             (PO_CONSTANTS_SV.APPLICATION_ID = zxldet.application_id
              AND PO_CONSTANTS_SV.PO_ENTITY_CODE = zxldet.entity_code
              AND PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE = zxldet.event_class_code
              AND PO_CONSTANTS_SV.PO_TRX_LEVEL_TYPE = zxldet.trx_level_type
              AND pll.source_shipment_id = zxldet.trx_line_id
              AND pll.shipment_type = PO_CONSTANTS_SV.SCHEDULED
              AND pll.tax_attribute_update_code = 'CREATE'
              AND pll.original_shipment_id IS NULL)
            )
    WHERE pr.po_release_id = pll.po_release_id
    AND pll.tax_attribute_update_code IS NOT NULL
    AND pll.tax_attribute_update_code <> 'DIST_DELETE'
        -- Bug 11665348
         AND Nvl(pll.quantity_billed,0)=0
         AND Nvl(pll.quantity_received,0)=0
         AND Nvl(pll.quantity_shipped,0)=0
         AND Nvl(pll.amount_billed,0)=0
         AND Nvl(pll.amount_received,0)=0
         AND Nvl(pll.amount_shipped,0)=0
     -- end bug 11665348

    AND pr.po_release_id = p_po_release_id_tbl(i)
    AND ph.po_header_id = pr.po_header_id
    AND pl.po_line_id = pll.po_line_id;

END populate_zx_lines_with_rel;

-----------------------------------------------------------------------------

/* Bug 11665348 : Creating 2 new procedures populate_zx_lines_with_po_cal and
   populate_zx_lines_with_rel_cal which populates the data in zx_transaction_lines_gt
   only when the shipments is received or billed or shipped. This has been done for these
   shipments to skip the call to get_default_tax_attribs as per the EB Tax suggestion in bug
   11665348 to fulfill requirement by PO PM team to retain the tax on received/billed shipments.
   These 2 procedures uses a join for zx_lines_det_factors and po_line_locations_all
   ON line_location_id instead of original_shipment_id as we need to pass value of
   input_tax_classification_code for receioved/billed PO shipments as per the suggestion
   of EB Tax team in bug 11711366
*/

-----------------------------------------------------------------------------
--Start of Comments
--Name: populate_zx_lines_with_po_cal
--Pre-reqs:
--  None
--Modifies:
--  ZX_TRANSACTION_LINES_GT
--Locks:
--  ZX_TRANSACTION_LINES_GT
--Function:
--  Populate ZX_TRANSACTION_LINES_GT with transaction line and shipment data
--  which are not already populated by populate_zx_lines_with_po
--Parameters:
--IN:
--p_po_header_id_tbl
--  PL/SQL table with list of po_header_id's to process for tax_calculation
--p_calling_program
--  Identifies the module that calls this procedure eg. 'PDOI'
--Notes:
--  Used by calculate_tax procedure. Not to be used externally
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE populate_zx_lines_with_po_cal(p_po_header_id_tbl  IN  PO_TBL_NUMBER,
                                    p_calling_program   IN  VARCHAR2
) IS
BEGIN

    -- Populate zx_transaction_lines_gt for POs
  FORALL i in 1..p_po_header_id_tbl.COUNT
    INSERT INTO zx_transaction_lines_gt(
      application_id
      ,entity_code
      ,event_class_code
      ,trx_id
      ,trx_level_type
      ,trx_line_id
      ,line_level_action
      ,line_class
      ,trx_line_type
      ,trx_line_date
      ,trx_business_category
      ,line_intended_use
      ,user_defined_fisc_class
      ,line_amt
      ,trx_line_quantity
      ,product_id
      ,product_org_id
      ,product_fisc_classification
      ,uom_code
      ,product_type
      ,product_code
      ,product_category
      ,fob_point
      ,ship_from_party_id
      ,bill_from_party_id
      ,ship_from_party_site_id
      ,bill_from_party_site_id
      ,ship_to_location_id
      ,ship_from_location_id
      ,bill_to_location_id
      ,bill_from_location_id /* 6524317 */
      ,account_ccid
      ,ref_doc_application_id
      ,ref_doc_entity_code
      ,ref_doc_event_class_code
      ,ref_doc_trx_id
      ,ref_doc_line_id
      ,line_trx_user_key1
      ,line_trx_user_key2
      -- Bug 5079867. Ordering of complex work payment lines in ATI page
      ,line_trx_user_key3
      ,trx_line_number
      ,trx_line_description
      ,product_description
      ,assessable_value
      ,line_amt_includes_tax_flag
      ,input_tax_classification_code
      ,source_application_id
      ,source_entity_code
      ,source_event_class_code
      ,source_trx_id
      ,source_line_id
      ,source_trx_level_type
      ,unit_price
      ,ref_doc_trx_level_type
      -- Bug 5025018. Updated tax attribute mappings
      ,ship_third_pty_acct_id
      ,bill_third_pty_acct_id
      ,ship_third_pty_acct_site_id
      ,bill_third_pty_acct_site_id
      ,ship_to_party_id
      ,user_upd_det_factors_flag --Bug 5632300
      ,defaulting_attribute1 --Bug#6902111
    )
    SELECT
      PO_CONSTANTS_SV.APPLICATION_ID --application_id
      ,PO_CONSTANTS_SV.PO_ENTITY_CODE --entity_code
      ,PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE --event_class_code
      ,ph.po_header_id --trx_id
      ,PO_CONSTANTS_SV.PO_TRX_LEVEL_TYPE --trx_level_type
      ,pll.line_location_id --trx_line_id
      ,pll.tax_attribute_update_code --line_level_action
      ,DECODE(pll.shipment_type,--line_class
              'PREPAYMENT', DECODE(pll.payment_type,
                                   'ADVANCE', 'ADVANCE',
                                   'FINANCING'),
              DECODE(pll.value_basis,
                     'QUANTITY', 'INVOICE',
                     'AMOUNT')
             )
      ,'ITEM' --trx_line_type
      ,COALESCE(pll.need_by_date, pll.promised_date, sysdate) --trx_line_date
      ,DECODE(p_calling_program, --trx_business_category
              'COPY_DOCUMENT', null,
              zxldet.trx_business_category)
      ,DECODE(p_calling_program, --line_intended_use
              'COPY_DOCUMENT', null,
              zxldet.line_intended_use)
      ,DECODE(p_calling_program, --user_defined_fisc_class
              'COPY_DOCUMENT', null,
              zxldet.user_defined_fisc_class)
      ,NVL(pll.amount, pll.price_override*pll.quantity) --line_amt
      ,pll.quantity --trx_line_quantity
      ,pl.item_id --product_id
       -- Bug 5335818. Pass in inventory_organization_id
      ,(SELECT fsp.inventory_organization_id --product_org_id
        FROM financials_system_params_all fsp
        WHERE fsp.org_id=pll.org_id)
      ,DECODE(p_calling_program, --product_fisc_classification
              'COPY_DOCUMENT', null,
              zxldet.product_fisc_classification)
      ,(SELECT mum.uom_code FROM mtl_units_of_measure mum
        WHERE mum.unit_of_measure=pll.unit_meas_lookup_code) --uom_code
      ,DECODE(p_calling_program, --product_type
              'COPY_DOCUMENT', null,
              zxldet.product_type)
      ,msib.segment1 --product_code
      ,DECODE(p_calling_program, --product_category
              'COPY_DOCUMENT', null,
              zxldet.product_category)
      ,ph.fob_lookup_code --fob_point
      ,pv.party_id --ship_from_party_id
      ,pv.party_id --bill_from_party_id
      ,pvs.party_site_id --ship_from_party_site_id
      ,pvs.party_site_id --bill_from_party_site_id
      ,pll.ship_to_location_id --ship_to_location_id
      ,(SELECT hzps.location_id --ship_from_location_id
        FROM hz_party_sites hzps
        WHERE hzps.party_site_id = pvs.party_site_id)
      ,ph.bill_to_location_id --bill_to_location_id
      ,(SELECT pvs.location_id from po_vendor_sites_all pvs   /* 6524317 - Passing Location Id as Bill From Location Id */
        WHERE pvs.vendor_site_id=ph.vendor_site_id)
      -- Get account id from first distribution, if created
      -- otherwise from the expense account of the item
      ,NVL((SELECT pd.code_combination_id --account_ccid
            FROM po_distributions_all pd
            WHERE pd.line_location_id = pll.line_location_id
            AND rownum = 1),
           msib.expense_account
          )
      ,null --ref_doc_application_id
      ,null --ref_doc_entity_code
      ,null --ref_doc_event_class_code
      ,null --ref_doc_trx_id
      ,null --ref_doc_line_id
      ,pl.line_num --line_trx_user_key1
      ,PO_LOCATIONS_S.get_location_code(pll.ship_to_location_id) --line_trx_user_key2
      -- Bug 5079867. Ordering of complex work payment lines in ATI page
      ,DECODE(pll.payment_type, null, 0, --line_trx_user_key3
                'DELIVERY', 1,
                'ADVANCE', 2, 3)
      ,DECODE(pll.payment_type, --trx_line_number
              'ADVANCE', null,
              'DELIVERY', null,
              pll.shipment_num)
      ,DECODE(pll.shipment_type, --trx_line_description
              'STANDARD', DECODE(pll.payment_type,
                                 null, pl.item_description, --non complex work Standard PO
                                 pll.description --complex work Standard PO
                                ),
              pl.item_description -- for shipment_type='PLANNED'
             )
      ,DECODE(pll.shipment_type, --product_description
              'STANDARD', DECODE(pll.payment_type,
                                 null, pl.item_description, --non complex work Standard PO
                                 pll.description --complex work Standard PO
                                ),
              pl.item_description -- for shipment_type='PLANNED'
             )
      ,DECODE(p_calling_program, --assessable_value
              'COPY_DOCUMENT', null,
              zxldet.assessable_value)
      ,'N' --line_amt_includes_tax_flag
      --<<PDOI Enhancement bug#17063664>>
      -- The shipments can be updated through PDOI
      -- having requisition reference and new requisition
      -- line matches to the existing line and shipment
      -- In that case ,the tax name on the shipment should
      -- not be consideredto pass to zx table
      -- The tax name in po_line_locations_all table
      -- is updated to NULL value for all updated shipments
      -- when called from PDOI and restored back after
      -- at the caller after calculate tax api is completed.
      -- Tax classfication will be overridden from PDOI
      -- only when new shipments are being created.
      ,DECODE(p_calling_program, --input_tax_classification_code
              'PDOI', NVL(pll.tax_name,zxldet.input_tax_classification_code),
              'COPY_DOCUMENT', null,
              zxldet.input_tax_classification_code)
      -- Bug 7337548
      -- Copying requisition information as Source Document Information
      -- in case of Autocreate. This information will be used to copy
      -- Tax attributes when the attributes are overridden in requisition.
      -- Calling program for autocreate is 'AUTOCREATE','AUTOCREATED_DOC_WF'
      -- and 'PORELGEB'
        --<<PDOI Enhancement bug#17063664 START>>
      -- Added code to pass source information from PDOI
      -- if shipment is having requisition reference
      -- Source information is considered only if
      -- tax name is not provided in the interface tables
      ,DECODE(p_calling_program, --source_application_id
              'COPY_DOCUMENT', PO_CONSTANTS_SV.APPLICATION_ID,
              'AUTOCREATE', PO_CONSTANTS_SV.APPLICATION_ID,
              'AUTOCREATED_DOC_WF' ,PO_CONSTANTS_SV.APPLICATION_ID,
              'PORELGEB',PO_CONSTANTS_SV.APPLICATION_ID,
	      'PDOI',DECODE(pll.tax_name ,NULL
	                     ,DECODE(prl.min_req_line_id, NULL ,NULL,PO_CONSTANTS_SV.APPLICATION_ID)
			     ,NULL),
              null)
      ,DECODE(p_calling_program, --source_entity_code
              'COPY_DOCUMENT', PO_CONSTANTS_SV.PO_ENTITY_CODE,
              'AUTOCREATE', PO_CONSTANTS_SV.REQ_ENTITY_CODE,
              'AUTOCREATED_DOC_WF', PO_CONSTANTS_SV.REQ_ENTITY_CODE,
              'PORELGEB', PO_CONSTANTS_SV.REQ_ENTITY_CODE,
              'PDOI',DECODE(pll.tax_name ,NULL
	                     ,DECODE(prl.min_req_line_id, NULL ,NULL,PO_CONSTANTS_SV.REQ_ENTITY_CODE)
			     ,NULL),
              null)
      ,DECODE(p_calling_program, --source_event_class_code
              'COPY_DOCUMENT', PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE,
              'AUTOCREATE', PO_CONSTANTS_SV.REQ_EVENT_CLASS_CODE,
              'AUTOCREATED_DOC_WF', PO_CONSTANTS_SV.REQ_EVENT_CLASS_CODE,
              'PORELGEB', PO_CONSTANTS_SV.REQ_EVENT_CLASS_CODE,
              'PDOI',DECODE(pll.tax_name ,NULL
	                     ,DECODE(prl.min_req_line_id, NULL ,NULL,PO_CONSTANTS_SV.REQ_EVENT_CLASS_CODE)
			     ,NULL),
              null)
      ,DECODE(p_calling_program, -- source_trx_id
              'COPY_DOCUMENT', (SELECT source_shipment.po_header_id --source_trx_id
                                FROM po_line_locations_all source_shipment
                                WHERE source_shipment.line_location_id = pll.original_shipment_id
                                AND p_calling_program = 'COPY_DOCUMENT'),

              'AUTOCREATE',  (SELECT requisition_header_id      --source_trx_id
	                      FROM   po_requisition_lines_all
			      WHERE  requisition_line_id = prl.min_req_line_id
			      ),
              'AUTOCREATED_DOC_WF', (SELECT requisition_header_id      --source_trx_id
  	                             FROM   po_requisition_lines_all
			             WHERE  requisition_line_id = prl.min_req_line_id
			             ),
              'PORELGEB', (SELECT requisition_header_id      --source_trx_id
  	                   FROM   po_requisition_lines_all
			   WHERE  requisition_line_id = prl.min_req_line_id
			  ),
               'PDOI',DECODE(pll.tax_name ,NULL   --source_trx_id
	                     ,DECODE(prl.min_req_line_id, NULL ,NULL,
			              ( SELECT requisition_header_id
  	                                FROM   po_requisition_lines_all
			                WHERE  requisition_line_id = prl.min_req_line_id
				      )
				    )
			     ,NULL),
              null)
      ,DECODE(p_calling_program, --source_line_id
              'COPY_DOCUMENT', pll.original_shipment_id,
              'AUTOCREATE',prl.min_req_line_id,
              'AUTOCREATED_DOC_WF',prl.min_req_line_id,
              'PORELGEB',prl.min_req_line_id,
              'PDOI',DECODE(pll.tax_name ,NULL
	                     ,DECODE(prl.min_req_line_id, NULL ,NULL,prl.min_req_line_id)
			     ,NULL),
              null)
      ,DECODE(p_calling_program, --source_trx_level_type
              'COPY_DOCUMENT', PO_CONSTANTS_SV.PO_TRX_LEVEL_TYPE,
              'AUTOCREATE', PO_CONSTANTS_SV.REQ_TRX_LEVEL_TYPE ,
	      'AUTOCREATED_DOC_WF', PO_CONSTANTS_SV.REQ_TRX_LEVEL_TYPE ,
              'PORELGEB', PO_CONSTANTS_SV.REQ_TRX_LEVEL_TYPE ,
              'PDOI',DECODE(pll.tax_name ,NULL
	                     ,DECODE(prl.min_req_line_id, NULL ,NULL, PO_CONSTANTS_SV.REQ_TRX_LEVEL_TYPE)
			     ,NULL),
              null)
      ,pll.price_override --unit_price
      ,null --ref_doc_trx_level_type
      -- Bug 5025018. Updated tax attribute mappings
      ,pv.vendor_id --ship_third_pty_acct_id
      ,pv.vendor_id --bill_third_pty_acct_id
      ,pvs.vendor_site_id --ship_third_pty_acct_site_id
      ,pvs.vendor_site_id --bill_third_pty_acct_site_id
      ,pll.ship_to_organization_id --ship_to_party_id
      --Bug 5632300. Parameter to confirm that tax classification is overridden
      ,(SELECT 'Y' FROM DUAL --user_upd_det_factors_flag
        WHERE p_calling_program = 'PDOI'
        AND pll.tax_name IS NOT NULL)
      ,pll.ship_to_organization_id  --Bug#6902111
    FROM po_headers_all ph, po_lines_all pl, po_line_locations_all pll,
         zx_lines_det_factors zxldet, po_vendors pv,
         po_vendor_sites_all pvs, mtl_system_items_b msib,
	 --<<PDOI Enhancement Bug#17063664 START>>
	 -- Added from clause query to get min requisition line ids
         -- for all shipments of the Purchase order
         (SELECT poll.line_location_id , MIN(prl.requisition_line_id) min_req_line_id
	  FROM  po_line_locations_all poll,po_requisition_lines_all prl
	  WHERE poll.po_header_id =  p_po_header_id_tbl(i)
	  AND   poll.line_location_id = prl.line_location_id(+)
          GROUP BY poll.line_location_id
	 ) prl
	 --<<PDOI Enhancement Bug#17063664 END>>
    WHERE ph.po_header_id = pll.po_header_id
    AND pl.po_line_id = pll.po_line_id
      ---Bug# 13091627 : Condition added to exclude the Release shipments for BLANKET/PLANNED PO
    AND pll.po_release_id IS NULL
    AND pll.tax_attribute_update_code IS NOT NULL
    AND pll.tax_attribute_update_code <> 'DIST_DELETE'
        -- Bug 18404042, improve bwc performance
    AND NOT EXISTS
        (SELECT 1
        FROM ZX_TRANSACTION_LINES_GT INNER_GT
        WHERE INNER_GT.APPLICATION_ID = PO_CONSTANTS_SV.APPLICATION_ID
        AND INNER_GT.ENTITY_CODE      = PO_CONSTANTS_SV.PO_ENTITY_CODE
        AND INNER_GT.EVENT_CLASS_CODE = PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE
        AND INNER_GT.TRX_ID           = PLL.PO_HEADER_ID
        and INNER_GT.TRX_LEVEL_TYPE   = PO_CONSTANTS_SV.PO_TRX_LEVEL_TYPE
        AND INNER_GT.TRX_LINE_ID      = PLL.LINE_LOCATION_ID)
     -- end bug 18404042
    AND ph.po_header_id = p_po_header_id_tbl(i)
    -- Conditions for getting Additional Tax Attributes
    --  Do not put a condition on zxldet.trx_id here because that would
    --  entail bringing the source_header_id for the shipment being currently
    --  processed. Join with trx_line_id itself is unique because the document
    --  type has been classified with event_class_code and line_location_id
    --  will always be unique whether PO shipment or Release shipment
    AND zxldet.application_id(+) = PO_CONSTANTS_SV.APPLICATION_ID
    AND zxldet.entity_code(+) = PO_CONSTANTS_SV.PO_ENTITY_CODE
    AND zxldet.event_class_code(+) = PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE
    AND zxldet.trx_level_type(+) = PO_CONSTANTS_SV.PO_TRX_LEVEL_TYPE
    AND zxldet.trx_line_id(+) = pll.line_location_id
	AND zxldet.trx_id(+) = p_po_header_id_tbl(i)--bug:14028744
   -- Bug 11665348: For received/billed PO shipments.
    -- Join with vendor tables to get party and party site information
    AND pv.vendor_id(+) = ph.vendor_id
    AND pvs.vendor_site_id(+) = ph.vendor_site_id
    -- Join with items table for item information
    AND msib.inventory_item_id(+) = pl.item_id
    AND msib.organization_id(+) = pl.org_id
    AND prl.line_location_id   =  pll.line_location_id; --PDOI Enhancement Bug#17063664
    -- Conditions that determine that po line is 'Active'
    --AND nvl(pl.cancel_flag,'N') = 'N'
    --AND nvl(pl.closed_code,'OPEN') <> 'FINALLY CLOSED'
    --AND nvl(pll.cancel_flag,'N') = 'N'
    --AND nvl(pll.closed_code,'OPEN') <> 'FINALLY CLOSED';

END populate_zx_lines_with_po_cal;


-----------------------------------------------------------------------------
--Start of Comments
--Name: populate_zx_lines_with_rel_cal
--Pre-reqs:
--  None
--Modifies:
--  ZX_TRANSACTION_LINES_GT
--Locks:
--  ZX_TRANSACTION_LINES_GT
--Function:
--  Populate ZX_TRANSACTION_LINES_GT with transaction line and shipment data
--  which are not already populated by populate_zx_lines_with_rel.
--Parameters:
--IN:
--p_po_release_id_tbl
--  PL/SQL table with list of po_release_id's to process for tax_calculation
--p_calling_program
--  Identifies the module that calls this procedure eg. 'PDOI'
--Notes:
--  Used by calculate_tax procedure. Not to be used externally
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE populate_zx_lines_with_rel_cal(p_po_release_id_tbl  IN  PO_TBL_NUMBER,
                                     p_calling_program    IN  VARCHAR2
) IS
BEGIN
  -- Populate zx_transaction_lines_gt for Releases
  FORALL i IN 1..p_po_release_id_tbl.COUNT
    INSERT INTO zx_transaction_lines_gt(
      application_id
      ,entity_code
      ,event_class_code
      ,trx_id
      ,trx_level_type
      ,trx_line_id
      ,line_level_action
      ,line_class
      ,trx_line_type
      ,trx_line_date
      ,trx_business_category
      ,line_intended_use
      ,user_defined_fisc_class
      ,line_amt
      ,trx_line_quantity
      ,product_id
      ,product_org_id
      ,product_fisc_classification
      ,uom_code
      ,product_type
      ,product_code
      ,product_category
      ,fob_point
      ,ship_from_party_id
      ,bill_from_party_id
      ,ship_from_party_site_id
      ,bill_from_party_site_id
      ,ship_to_location_id
      ,ship_from_location_id
      ,bill_to_location_id
      ,bill_from_location_id   /* 6524317 */
      ,account_ccid
      ,ref_doc_application_id
      ,ref_doc_entity_code
      ,ref_doc_event_class_code
      ,ref_doc_trx_id
      ,ref_doc_line_id
      ,line_trx_user_key1
      ,line_trx_user_key2
      ,trx_line_number
      ,trx_line_description
      ,product_description
      ,assessable_value
      ,line_amt_includes_tax_flag
      ,input_tax_classification_code
      ,source_application_id
      ,source_entity_code
      ,source_event_class_code
      ,source_trx_id
      ,source_line_id
      ,source_trx_level_type
      ,unit_price
      ,ref_doc_trx_level_type
      -- Bug 5025018. Updated tax attribute mappings
      ,ref_doc_line_quantity
      ,ship_third_pty_acct_id
      ,bill_third_pty_acct_id
      ,ship_third_pty_acct_site_id
      ,bill_third_pty_acct_site_id
      ,ship_to_party_id
      ,defaulting_attribute1 --Bug#6902111
    )
    SELECT
      PO_CONSTANTS_SV.APPLICATION_ID --application_id
      ,PO_CONSTANTS_SV.REL_ENTITY_CODE --entity_code
      ,PO_CONSTANTS_SV.REL_EVENT_CLASS_CODE --event_class_code
      ,pr.po_release_id --trx_id
      ,PO_CONSTANTS_SV.REL_TRX_LEVEL_TYPE --trx_level_type
      ,pll.line_location_id --trx_line_id
      ,pll.tax_attribute_update_code --line_level_action
      ,DECODE(pll.shipment_type,--line_class
              'PREPAYMENT', DECODE(pll.payment_type,
                                   'ADVANCE', 'ADVANCE',
                                   'FINANCING'),
              DECODE(pll.value_basis,
                     'QUANTITY', 'INVOICE',
                     'AMOUNT')
             )
      ,'ITEM' --trx_line_type
      ,COALESCE(pll.need_by_date, pll.promised_date, sysdate) --trx_line_date
      ,zxldet.trx_business_category --trx_business_category
      ,zxldet.line_intended_use --line_intended_use
      ,zxldet.user_defined_fisc_class --user_defined_fisc_class
      ,nvl(pll.amount, pll.price_override*pll.quantity) --line_amt
      ,pll.quantity --trx_line_quantity
      ,pl.item_id --product_id
       -- Bug 5335818. Pass in inventory_organization_id
      ,(SELECT fsp.inventory_organization_id --product_org_id
        FROM financials_system_params_all fsp
        WHERE fsp.org_id=pll.org_id)
      ,zxldet.product_fisc_classification --product_fisc_classification
      ,(SELECT mum.uom_code FROM mtl_units_of_measure mum
        WHERE mum.unit_of_measure=pll.unit_meas_lookup_code) --uom_code
      ,zxldet.product_type --product_type
      ,msib.segment1 --product_code
      ,zxldet.product_category --product_category
      ,ph.fob_lookup_code --fob_point
      ,pov.party_id --ship_from_party_id
      ,pov.party_id --bill_from_party_id
      ,pvs.party_site_id --ship_from_party_site_id
      ,pvs.party_site_id --bill_from_party_site_id
      ,pll.ship_to_location_id --ship_to_location_id
      ,(SELECT hzps.location_id --ship_from_location_id
        FROM hz_party_sites hzps
        WHERE hzps.party_site_id = pvs.party_site_id)
      ,ph.bill_to_location_id --bill_to_location_id
      ,(SELECT pvs.location_id from po_vendor_sites_all pvs   /* 6524317 - Passing Location Id as Bill From Location Id */
        WHERE pvs.vendor_site_id=ph.vendor_site_id)
      -- Get account id from first distribution, if created
      -- otherwise from the expense account of the item
      ,NVL((SELECT pd.code_combination_id --account_ccid
            FROM po_distributions_all pd
            WHERE pd.line_location_id = pll.line_location_id
            AND rownum = 1),
           msib.expense_account
          )
      -- If scheduled release, pass Planned PO as a reference
      ,DECODE(pr.release_type, --ref_doc_application_id
              PO_CONSTANTS_SV.SCHEDULED, PO_CONSTANTS_SV.APPLICATION_ID,
              null)
      ,DECODE(pr.release_type, --ref_doc_entity_code
              PO_CONSTANTS_SV.SCHEDULED, PO_CONSTANTS_SV.PO_ENTITY_CODE,
              null)
      ,DECODE(pr.release_type, --ref_doc_event_class_code
              PO_CONSTANTS_SV.SCHEDULED, PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE,
              null)
      ,DECODE(pr.release_type, --ref_doc_trx_id
              PO_CONSTANTS_SV.SCHEDULED, pr.po_header_id,
              null)
      ,DECODE(pr.release_type, --ref_doc_line_id
              PO_CONSTANTS_SV.SCHEDULED, pll.po_line_id,
              null)
      ,pl.line_num --line_trx_user_key1
      ,PO_LOCATIONS_S.get_location_code(pll.ship_to_location_id) --line_trx_user_key2
      ,DECODE(pll.payment_type, --trx_line_number
              'ADVANCE', null,
              'DELIVERY', null,
              pll.shipment_num)
      ,DECODE(pll.shipment_type, --trx_line_description
              'STANDARD', DECODE(pll.payment_type,
                                 null, pl.item_description, --non complex work Standard PO
                                 pll.description --complex work Standard PO
                                ),
              pl.item_description -- for shipment_type='PLANNED'
             )
      ,DECODE(pll.shipment_type, --product_description
              'STANDARD', DECODE(pll.payment_type,
                                 null, pl.item_description, --non complex work Standard PO
                                 pll.description --complex work Standard PO
                                ),
              pl.item_description -- for shipment_type='PLANNED'
             )
      ,zxldet.assessable_value --assessable_value
      ,'N' --line_amt_includes_tax_flag
      -- Releases cannot be created through PDOI
      ,zxldet.input_tax_classification_code --input_tax_classification_code
      -- Bug 7337548
      -- Copying requisition information as Source Document Information
      -- in case of Autocreate. This information will be used to copy
      -- Tax attributes when the attributes are overridden in requisition.
      -- Calling program for autocreate is 'AUTOCREATE','AUTOCREATED_DOC_WF'
      -- and 'PORELGEB'
      ,DECODE(p_calling_program, --source_application_id
              'AUTOCREATE', PO_CONSTANTS_SV.APPLICATION_ID,
              'AUTOCREATED_DOC_WF', PO_CONSTANTS_SV.APPLICATION_ID,
              'PORELGEB', PO_CONSTANTS_SV.APPLICATION_ID,
              null)
      ,DECODE(p_calling_program, --source_entity_code
              'AUTOCREATE', PO_CONSTANTS_SV.REQ_ENTITY_CODE,
              'AUTOCREATED_DOC_WF', PO_CONSTANTS_SV.REQ_ENTITY_CODE,
              'PORELGEB', PO_CONSTANTS_SV.REQ_ENTITY_CODE,
              null)
      ,DECODE(p_calling_program, --source_event_class_code
              'AUTOCREATE', PO_CONSTANTS_SV.REQ_EVENT_CLASS_CODE,
              'AUTOCREATED_DOC_WF', PO_CONSTANTS_SV.REQ_EVENT_CLASS_CODE,
              'PORELGEB', PO_CONSTANTS_SV.REQ_EVENT_CLASS_CODE,
              null)
      ,DECODE(p_calling_program, -- source_trx_id
              'AUTOCREATE',  (SELECT requisition_header_id FROM
                                po_requisition_lines_all
                                WHERE  requisition_line_id IN (SELECT Min(requisition_line_id)    --source_trx_id
                                                               FROM po_requisition_lines_all prl
                                                               WHERE prl.line_location_id = pll.line_location_id)
                                AND p_calling_program = 'AUTOCREATE'),
 	      'AUTOCREATED_DOC_WF',  (SELECT requisition_header_id FROM
                                po_requisition_lines_all
                                WHERE  requisition_line_id IN (SELECT Min(requisition_line_id)    --source_trx_id
                                                               FROM po_requisition_lines_all prl
                                                               WHERE prl.line_location_id = pll.line_location_id)
                                AND p_calling_program = 'AUTOCREATED_DOC_WF'),
 	       'PORELGEB',  (SELECT requisition_header_id FROM
                                po_requisition_lines_all
                                WHERE  requisition_line_id IN (SELECT Min(requisition_line_id)    --source_trx_id
                                                               FROM po_requisition_lines_all prl
                                                               WHERE prl.line_location_id = pll.line_location_id)
                                AND p_calling_program = 'PORELGEB'),
              null)
      ,DECODE(p_calling_program, --source_line_id
              'AUTOCREATE',(SELECT Min(requisition_line_id)    --source_line_id
                             FROM po_requisition_lines_all prl
                             WHERE prl.line_location_id = pll.line_location_id
                             AND p_calling_program = 'AUTOCREATE'),
              'AUTOCREATED_DOC_WF',(SELECT Min(requisition_line_id)    --source_line_id
                             FROM po_requisition_lines_all prl
                             WHERE prl.line_location_id = pll.line_location_id
                             AND p_calling_program = 'AUTOCREATED_DOC_WF'),
              'PORELGEB',(SELECT Min(requisition_line_id)    --source_line_id
                             FROM po_requisition_lines_all prl
                             WHERE prl.line_location_id = pll.line_location_id
                             AND p_calling_program = 'PORELGEB'),
			 null)
      ,DECODE(p_calling_program, --source_trx_level_type
              'AUTOCREATE', PO_CONSTANTS_SV.REQ_TRX_LEVEL_TYPE ,
              'AUTOCREATED_DOC_WF', PO_CONSTANTS_SV.REQ_TRX_LEVEL_TYPE ,
              'PORELGEB', PO_CONSTANTS_SV.REQ_TRX_LEVEL_TYPE ,
              null)
      ,pll.price_override --unit_price
      ,DECODE(pr.release_type, --ref_doc_trx_level_type
              PO_CONSTANTS_SV.SCHEDULED, PO_CONSTANTS_SV.PO_TRX_LEVEL_TYPE,
              null)
      -- Bug 5025018. Updated tax attribute mappings
      ,DECODE(pr.release_type, --ref_doc_line_quantity
              PO_CONSTANTS_SV.SCHEDULED, pll.quantity,
              null)
      ,pov.vendor_id --ship_third_pty_acct_id
      ,pov.vendor_id --bill_third_pty_acct_id
      ,pvs.vendor_site_id --ship_third_pty_acct_site_id
      ,pvs.vendor_site_id --bill_third_pty_acct_site_id
      ,pll.ship_to_organization_id --ship_to_party_id
	  ,pll.ship_to_organization_id  --Bug#6902111
    -- Using OUTER JOIN in FROM clause syntax here because (+) operator
    -- is not flexible enough to be used inside an OR condition
    FROM po_releases_all pr
         ,po_headers_all ph
           -- Join with vendor tables to get party and party site information
           LEFT OUTER JOIN po_vendors pov ON (ph.vendor_id = pov.vendor_id)
           LEFT OUTER JOIN po_vendor_sites_all pvs
             ON (ph.vendor_site_id = pvs.vendor_site_id)
         ,po_lines_all pl--Blanket/Scheduled header and line
           -- Join with items table for item information
           LEFT OUTER JOIN mtl_system_items_b msib
             ON (pl.item_id = msib.inventory_item_id
                 AND pl.org_id = msib.organization_id)
         ,po_line_locations_all pll
          LEFT OUTER JOIN zx_lines_det_factors zxldet ON
          -- Bug#12622509: The performance of the SQL is very bad, as FULL TABLE
          --               SCAN is performed on the table zx_lines_det_factors.
          (PO_CONSTANTS_SV.APPLICATION_ID = zxldet.application_id
           AND PO_CONSTANTS_SV.REL_ENTITY_CODE = zxldet.entity_code
           AND PO_CONSTANTS_SV.REL_EVENT_CLASS_CODE = zxldet.event_class_code
           AND PO_CONSTANTS_SV.REL_TRX_LEVEL_TYPE = zxldet.trx_level_type
           AND pll.line_location_id = zxldet.trx_line_id)
   -- Bug 11665348: For received/billed PO shipments
         /*  -- Conditions for getting Additional Tax Attributes
           --  Do not put a condition on zxldet.trx_id here because that would
           --  entail bringing the source_header_id for the shipment being
           --  currently processed. Join with trx_line_id itself is unique
           --  because the document type has been classified with
           --  event_class_code and line_location_id will always be unique
           --  whether PO shipment or Release shipment
           LEFT OUTER JOIN zx_lines_det_factors zxldet ON
            ((PO_CONSTANTS_SV.APPLICATION_ID = zxldet.application_id
              AND PO_CONSTANTS_SV.REL_ENTITY_CODE = zxldet.entity_code
              AND PO_CONSTANTS_SV.REL_EVENT_CLASS_CODE = zxldet.event_class_code
              AND PO_CONSTANTS_SV.REL_TRX_LEVEL_TYPE = zxldet.trx_level_type
              AND pll.original_shipment_id = zxldet.trx_line_id
              AND pll.original_shipment_id IS NOT NULL)
             OR
             (PO_CONSTANTS_SV.APPLICATION_ID = zxldet.application_id
              AND PO_CONSTANTS_SV.PO_ENTITY_CODE = zxldet.entity_code
              AND PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE = zxldet.event_class_code
              AND PO_CONSTANTS_SV.PO_TRX_LEVEL_TYPE = zxldet.trx_level_type
              AND pll.source_shipment_id = zxldet.trx_line_id
              AND pll.shipment_type = PO_CONSTANTS_SV.SCHEDULED
              AND pll.tax_attribute_update_code = 'CREATE'
              AND pll.original_shipment_id IS NULL)
            )       */
    WHERE pr.po_release_id = pll.po_release_id
    AND pll.tax_attribute_update_code IS NOT NULL
    AND pll.tax_attribute_update_code <> 'DIST_DELETE'
        -- Bug 11665348
     AND pll.line_location_id NOT IN (SELECT trx_line_id
                                     FROM zx_transaction_lines_gt)
     -- end bug 11665348
    AND pr.po_release_id = p_po_release_id_tbl(i)
    AND ph.po_header_id = pr.po_header_id
    AND pl.po_line_id = pll.po_line_id;

END populate_zx_lines_with_rel_cal;


-----------------------------------------------------------------------------
--End Bug 11665348

-----------------------------------------------------------------------------
--Start of Comments
--Name: populate_zx_lines_with_req
--Pre-reqs:
--  None
--Modifies:
--  ZX_TRANSACTION_LINES_GT
--Locks:
--  ZX_TRANSACTION_LINES_GT
--Function:
--  Populate ZX_TRANSACTION_LINES_GT with transaction line data
--Parameters:
--IN:
--p_requisition_header_id
--  requisition_header_id of the requisition to process for tax_calculation
--p_calling_program
--  Identifies the module that calls this procedure eg. 'PDOI'
--Notes:
--  Used by calculate_tax_requisition procedure. Not to be used externally
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE populate_zx_lines_with_req(p_requisition_header_id  IN  NUMBER,
                                     p_calling_program        IN  VARCHAR2
) IS
  l_functional_currency_code PO_REQUISITION_LINES_ALL.currency_code%TYPE;
  l_set_of_books_id FINANCIALS_SYSTEM_PARAMS_ALL.set_of_books_id%TYPE;
  l_rate_type PO_REQUISITION_LINES_ALL.rate_type%TYPE;
  l_rate PO_REQUISITION_LINES_ALL.rate%TYPE;
BEGIN

  -- <Bug 4742335 Start> Get the requisition's functional currency info.
  -- This piece of code is similar to PO_GA_PVT.get_currency_info except that
  -- this works for a requisition
  SELECT sob.currency_code, fsp.set_of_books_id, psp.default_rate_type
  INTO l_functional_currency_code, l_set_of_books_id, l_rate_type
  FROM financials_system_params_all fsp, gl_sets_of_books sob,
       po_requisition_headers_all prh, po_system_parameters_all psp
  WHERE fsp.set_of_books_id = sob.set_of_books_id
  AND fsp.org_id = prh.org_id
  AND prh.requisition_header_id = p_requisition_header_id
  AND psp.org_id = prh.org_id;

  -- Retrieve rate based on above values
  l_rate := PO_CORE_S.get_conversion_rate(
              x_set_of_books_id => l_set_of_books_id,
              x_from_currency   => l_functional_currency_code,
              x_conversion_date => sysdate,
              x_conversion_type => l_rate_type);
  -- <Bug 4742335 End>

  -- Populate zx_transaction_lines_gt for Requisitions
  -- Addition/Removal of any attribute entails similar change in
  -- populate_zx_record as well
  INSERT INTO zx_transaction_lines_gt(
    application_id
    ,entity_code
    ,event_class_code
    ,trx_id
    ,trx_level_type
    ,trx_line_id
    ,line_class
    ,line_level_action
    ,trx_line_type
    ,trx_line_date
    ,line_amt_includes_tax_flag
    ,line_amt
    ,trx_line_quantity
    ,unit_price
    ,product_id
    ,product_org_id
    ,uom_code
    ,product_code
    ,ship_to_party_id
    ,ship_from_party_id
    ,bill_to_party_id
    ,bill_from_party_id
    ,ship_from_party_site_id
    ,bill_from_party_site_id
    ,ship_to_location_id
    ,ship_from_location_id
    ,bill_to_location_id
    ,bill_from_location_id   /* 8752470 */
    ,ship_third_pty_acct_id
    ,ship_third_pty_acct_site_id
    ,historical_flag
    ,trx_line_currency_code
    ,trx_line_currency_conv_date
    ,trx_line_currency_conv_rate
    ,trx_line_currency_conv_type
    ,trx_line_mau
    ,trx_line_precision
    ,historical_tax_code_id
    ,trx_business_category
    ,product_category
    ,product_fisc_classification
    ,line_intended_use
    ,product_type
    ,user_defined_fisc_class
    ,assessable_value
    ,input_tax_classification_code
    ,account_ccid
    -- Bug 5025018. Updated tax attribute mappings
    ,bill_third_pty_acct_id
    ,bill_third_pty_acct_site_id
    -- Bug 5079867. Line number and description in ATI page
    ,trx_line_number
    ,trx_line_description
    ,product_description
    ,user_upd_det_factors_flag --Bug 5632300
    ,defaulting_attribute1 --Bug#6902111
  )
  SELECT
    PO_CONSTANTS_SV.APPLICATION_ID --application_id
    ,PO_CONSTANTS_SV.REQ_ENTITY_CODE --entity_code
    ,PO_CONSTANTS_SV.REQ_EVENT_CLASS_CODE --event_class_code
    ,prl.requisition_header_id --trx_id
    ,PO_CONSTANTS_SV.REQ_TRX_LEVEL_TYPE --trx_level_type
    ,prl.requisition_line_id --trx_line_id
    ,'INVOICE' --line_class
    ,nvl(prl.tax_attribute_update_code,'UPDATE') --line_level_action
    ,'ITEM' --trx_line_type
    ,NVL(prl.need_by_date, sysdate) --trx_line_date
    ,'N' --line_amt_includes_tax_flag
    ,nvl(prl.amount, prl.unit_price*prl.quantity) --line_amt
    ,prl.quantity --trx_line_quantity
    ,prl.unit_price --unit_price
    ,prl.item_id --product_id
     -- Bug 5335818. Pass in inventory_organization_id
    ,(SELECT fsp.inventory_organization_id --product_org_id
      FROM financials_system_params_all fsp
      WHERE fsp.org_id=prl.org_id)
    ,(SELECT mum.uom_code FROM mtl_units_of_measure mum
      WHERE mum.unit_of_measure=prl.unit_meas_lookup_code) --uom_code
    ,msib.segment1 --product_code
    ,prl.destination_organization_id --ship_to_party_id
    ,pv.party_id --ship_from_party_id
    ,prh.org_id --bill_to_party_id
    ,pv.party_id --bill_from_party_id
    ,pvs.party_site_id --ship_from_party_site_id
    ,pvs.party_site_id --bill_from_party_site_id
    ,prl.deliver_to_location_id --ship_to_location_id
    ,(SELECT hzps.location_id --ship_from_location_id
      FROM hz_party_sites hzps
      WHERE hzps.party_site_id = pvs.party_site_id)
    ,(SELECT location_id FROM hr_all_organization_units --bill_to_location_id
      WHERE organization_id=prh.org_id)
    , (SELECT pvs.location_id from po_vendor_sites_all pvs   /* 8752470 - Passing Location Id as Bill From Location Id */
        WHERE pvs.vendor_site_id=prl.vendor_site_id)
    ,prl.vendor_id --ship_third_pty_acct_id
    ,prl.vendor_site_id --ship_third_pty_acct_site_id
    ,null --historical_flag
    -- If prl.currency_code is null, insert values corresponding to functional
    -- currency for currency_code, rate_date, rate and rate_type
    ,NVL(prl.currency_code, l_functional_currency_code) --trx_line_currency_code
    ,NVL2(prl.currency_code, prl.rate_date, sysdate) --trx_line_currency_conv_date
    ,NVL2(prl.currency_code, prl.rate, l_rate) --trx_line_currency_conv_rate
    ,NVL2(prl.currency_code, prl.rate_type, l_rate_type) --trx_line_currency_conv_type
    ,fc.minimum_accountable_unit --trx_line_mau
    ,NVL(fc.precision, 2) --trx_line_precision
    ,null --historical_tax_code_id
    -- parent_req_line_id is persistent and is not nulled out as in case of
    -- PO, so need to insert ATAs(Additional Tax Attributes) here only if the
    -- action is create and parent_req_line_id is not null (so that ATAs
    -- are populated only for the req line split case)
    ,DECODE(prl.tax_attribute_update_code, --trx_business_category
            'CREATE', NVL2(prl.parent_req_line_id,
                           zxldet.trx_business_category, null),
            null
           )
    ,DECODE(prl.tax_attribute_update_code, --product_category
            'CREATE', NVL2(prl.parent_req_line_id,
                           zxldet.product_category, null),
            null
           )
    ,DECODE(prl.tax_attribute_update_code, --product_fisc_classification
            'CREATE', NVL2(prl.parent_req_line_id,
                           zxldet.product_fisc_classification, null),
            null
           )
    ,DECODE(prl.tax_attribute_update_code, --line_intended_use
            'CREATE', NVL2(prl.parent_req_line_id,
                           zxldet.line_intended_use, null),
            null
           )
    ,DECODE(prl.tax_attribute_update_code, --product_type
            'CREATE', NVL2(prl.parent_req_line_id,
                           zxldet.product_type, null),
            null
           )
    ,DECODE(prl.tax_attribute_update_code, --user_defined_fisc_class
            'CREATE', NVL2(prl.parent_req_line_id,
                           zxldet.user_defined_fisc_class, null),
            null
           )
    ,DECODE(prl.tax_attribute_update_code, --assessable_value
            'CREATE', NVL2(prl.parent_req_line_id,
                           zxldet.assessable_value, null),
            null
           )
    ,DECODE(p_calling_program, --input_tax_classification_code
            'REQIMPORT', prl.tax_name,
            DECODE(prl.tax_attribute_update_code,
                   'CREATE', NVL2(prl.parent_req_line_id,
                                  zxldet.input_tax_classification_code, null),
                   null
                  )
           )
    -- Get account id from first distribution, if created
    -- otherwise from the expense account of the item
    ,NVL((SELECT prd.code_combination_id --account_ccid
          FROM po_req_distributions_all prd
          WHERE prd.requisition_line_id = prl.requisition_line_id
          AND rownum = 1),
         msib.expense_account
        )
    -- Bug 5025018. Updated tax attribute mappings
    ,pv.vendor_id --bill_third_pty_acct_id
    ,pvs.vendor_site_id --bill_third_pty_acct_site_id
    -- Bug 5079867. Line number and description in ATI page
    ,prl.line_num --trx_line_number
    ,prl.item_description --trx_line_description
    ,prl.item_description --product_description
    --Bug 5632300. Parameter to confirm that tax classification is overridden

  -- Bug 14155908: When the req split is done passing the user_upd_det_factors_flag
  -- to zx_transaction_lines_gt as that of the parent req line's value in
  -- zx_lines_det_factors table.
    ,Decode (p_calling_program,
	    'REQUISITION_MODIFY', zxldet.user_upd_det_factors_flag,
            'REQIMPORT', NVL2(PRL.TAX_NAME,'Y',NULL))
    ,prl.destination_organization_id --Bug#6902111
  FROM po_requisition_headers_all prh, po_requisition_lines_all prl,
       zx_lines_det_factors zxldet, po_vendors pv, po_vendor_sites_all pvs,
       mtl_system_items_b msib, fnd_currencies fc
  WHERE prh.requisition_header_id = p_requisition_header_id
  AND prh.requisition_header_id = prl.requisition_header_id
  -- Conditions for getting Additional Tax Attributes
  --  Do not put a condition on zxldet.trx_id here because that would
  --  entail bringing the source_header_id for the shipment being currently
  --  processed. Join with trx_line_id itself is unique because the document
  --  type has been classified with event_class_code and requisition_line_id
  --  will always be unique
  AND zxldet.application_id(+) = PO_CONSTANTS_SV.APPLICATION_ID
  AND zxldet.entity_code(+) = PO_CONSTANTS_SV.REQ_ENTITY_CODE
  AND zxldet.event_class_code(+) = PO_CONSTANTS_SV.REQ_EVENT_CLASS_CODE
  AND zxldet.trx_level_type(+) = PO_CONSTANTS_SV.REQ_TRX_LEVEL_TYPE
  AND zxldet.trx_line_id(+) = prl.parent_req_line_id
  -- Join with vendor tables to get party and party site information
  AND pv.vendor_id(+) = prl.vendor_id
  AND pvs.vendor_site_id(+) = prl.vendor_site_id
  -- Join with items table for item information
  AND msib.inventory_item_id(+) = prl.item_id
  AND msib.organization_id(+) = prl.org_id
  -- Join with fnd_currencies for currency information
  AND fc.currency_code(+) = prl.currency_code
  -- Conditions that determine that requisition line is 'Active'
  AND nvl(prl.modified_by_agent_flag, 'N') = 'N'
  AND nvl(prl.cancel_flag, 'N') = 'N'
  AND nvl(prl.closed_code, 'OPEN') <> 'FINALLY CLOSED'
  AND prl.line_location_id IS NULL
  AND prl.at_sourcing_flag IS NULL;

END populate_zx_lines_with_req;


-----------------------------------------------------------------------------
--Start of Comments
--Name: populate_zx_dists_with_po
--Pre-reqs:
--  None
--Modifies:
--  ZX_ITM_DISTRIBUTIONS_GT
--Locks:
--  ZX_ITM_DISTRIBUTIONS_GT
--Function:
--  Populate ZX_ITM_DISTRIBUTIONS_GT with transaction distribution data
--Parameters:
--IN:
--p_po_header_id_tbl
--  PL/SQL table with list of po_header_id's to process for tax_calculation
--p_calling_program
--  Identifies the module that calls this procedure eg. 'PDOI'
--Notes:
--  Used by calculate_tax procedure. Not to be used externally
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE populate_zx_dists_with_po(p_po_header_id_tbl  IN  PO_TBL_NUMBER,
                                    p_calling_program   IN  VARCHAR2
) IS
BEGIN
  -- Populate ZX_ITM_DISTRIBUTIONS_GT with all such distributions for which:
  -- 1. A sibling distribution was changed OR
  -- 2. There was a change at a parent level (header, line, shipment) OR
  -- 3. A distribution was deleted, hence its shipment is marked as 'DIST_DELETE'
  -- All the above cases are in one sql so that the same distribution is not
  -- populated twice, hence the OR conditions

  FORALL i in 1..p_po_header_id_tbl.COUNT
    INSERT INTO zx_itm_distributions_gt(
      application_id
      ,entity_code
      ,event_class_code
      ,trx_id
      ,trx_line_id
      ,trx_level_type
      ,trx_line_dist_id
      ,dist_level_action
      ,trx_line_dist_date
      ,item_dist_number
      ,task_id
      ,award_id
      ,project_id
      ,expenditure_type
      ,expenditure_organization_id
      ,expenditure_item_date
      ,trx_line_dist_amt
      ,trx_line_dist_qty
      ,trx_line_quantity
      ,account_ccid
      ,currency_exchange_rate
      ,overriding_recovery_rate
    )
    SELECT
      PO_CONSTANTS_SV.APPLICATION_ID --application_id
      ,PO_CONSTANTS_SV.PO_ENTITY_CODE --entity_code
      ,PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE --event_class_code
      ,pd1.po_header_id --trx_id
      ,pll.line_location_id --trx_line_id
      ,PO_CONSTANTS_SV.PO_TRX_LEVEL_TYPE --trx_level_type
      ,pd1.po_distribution_id --trx_line_dist_id
      ,NVL(pd1.tax_attribute_update_code, 'NO_ACTION') --dist_level_action
      ,sysdate --trx_line_dist_date
      ,pd1.distribution_num --item_dist_number
      ,pd1.task_id --task_id
      ,pd1.award_id --award_id
      ,pd1.project_id --project_id
      ,pd1.expenditure_type --expenditure_type
      ,pd1.expenditure_organization_id --expenditure_organization_id
      ,pd1.expenditure_item_date --expenditure_item_date
      ,DECODE(nvl(pll.matching_basis,pl.matching_basis), --trx_line_dist_amt
              'AMOUNT', pd1.amount_ordered,
              pd1.quantity_ordered*pll.price_override)
      ,pd1.quantity_ordered --trx_line_dist_qty
      ,pll.quantity --trx_line_quantity
      ,pd1.code_combination_id --account_ccid
      ,pd1.rate --currency_exchange_rate
      , decode(pd1.tax_recovery_override_flag, 'Y', pd1.recovery_rate, null) --overriding_recovery_rate
    FROM po_distributions_all pd1, po_line_locations_all pll, po_lines_all pl
    WHERE pd1.po_header_id = p_po_header_id_tbl(i)
    AND pd1.line_location_id=pll.line_location_id
    AND pll.po_line_id=pl.po_line_id
    AND (EXISTS(SELECT 'SIBLING DIST WITH TAUC'
                FROM po_distributions_all pd2
                WHERE pd2.line_location_id = pd1.line_location_id
                --AND pd2.po_distribution_id<>pd1.po_distribution_id
                AND pd2.tax_attribute_update_code IS NOT NULL
               )
         --OR pd1.tax_attribute_update_code IS NOT NULL
         OR pll.tax_attribute_update_code IS NOT NULL
        )
    AND pd1.po_header_id IN
      (SELECT trx_id FROM zx_trx_headers_gt
       WHERE event_class_code = PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE);

END populate_zx_dists_with_po;


-----------------------------------------------------------------------------
--Start of Comments
--Name: populate_all_dists_po
--Pre-reqs:
--  None
--Modifies:
--  ZX_ITM_DISTRIBUTIONS_GT
--Locks:
--  ZX_ITM_DISTRIBUTIONS_GT
--Function:
--  Populate ZX_ITM_DISTRIBUTIONS_GT with transaction distribution data
--Parameters:
--IN:
--p_po_header_id
--  po_header_id to process
--Notes:
--  Used by determine_recovery_po procedure. Not to be used externally
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE populate_all_dists_po(p_po_header_id  IN  NUMBER) IS
BEGIN
  -- Populate ZX_ITM_DISTRIBUTIONS_GT with all distributions of the given PO

  INSERT INTO zx_itm_distributions_gt(
    application_id
    ,entity_code
    ,event_class_code
    ,trx_id
    ,trx_line_id
    ,trx_level_type
    ,trx_line_dist_id
    ,dist_level_action
    ,trx_line_dist_date
    ,item_dist_number
    ,task_id
    ,award_id
    ,project_id
    ,expenditure_type
    ,expenditure_organization_id
    ,expenditure_item_date
    ,trx_line_dist_amt
    ,trx_line_dist_qty
    ,trx_line_quantity
    ,account_ccid
    ,currency_exchange_rate
    ,overriding_recovery_rate
  )
  SELECT
    PO_CONSTANTS_SV.APPLICATION_ID --application_id
    ,PO_CONSTANTS_SV.PO_ENTITY_CODE --entity_code
    ,PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE --event_class_code
    ,pd.po_header_id --trx_id
    ,pll.line_location_id --trx_line_id
    ,PO_CONSTANTS_SV.PO_TRX_LEVEL_TYPE --trx_level_type
    ,pd.po_distribution_id --trx_line_dist_id
    ,'NO_ACTION' --dist_level_action
    ,sysdate --trx_line_dist_date
    ,pd.distribution_num --item_dist_number
    ,pd.task_id --task_id
    ,pd.award_id --award_id
    ,pd.project_id --project_id
    ,pd.expenditure_type --expenditure_type
    ,pd.expenditure_organization_id --expenditure_organization_id
    ,pd.expenditure_item_date --expenditure_item_date
    -- Bug 5202059. Pass in correct amount
    ,DECODE(nvl(pll.matching_basis,pl.matching_basis), --trx_line_dist_amt
            'AMOUNT', pd.amount_ordered,
            pd.quantity_ordered*pll.price_override)
    ,pd.quantity_ordered --trx_line_dist_qty
    ,pll.quantity --trx_line_quantity
    ,pd.code_combination_id --account_ccid
    ,pd.rate --currency_exchange_rate
    , decode(pd.tax_recovery_override_flag, 'Y', pd.recovery_rate, null) --overriding_recovery_rate
  FROM po_distributions_all pd, po_line_locations_all pll, po_lines_all pl
  WHERE pd.po_header_id = p_po_header_id
  AND pd.line_location_id=pll.line_location_id
  AND pll.po_line_id = pl.po_line_id
  -- Conditions that determine that po line is 'Active'
  AND nvl(pl.cancel_flag,'N') = 'N'
  AND nvl(pl.closed_code,'OPEN') <> 'FINALLY CLOSED'
  AND nvl(pll.cancel_flag,'N') = 'N'
  AND nvl(pll.closed_code,'OPEN') <> 'FINALLY CLOSED'
  --Bug 10305728 start
  AND (EXISTS(SELECT 'SIBLING DIST WITH TAUC'
              FROM po_distributions_all pd2
              WHERE pd2.line_location_id = pd.line_location_id
              AND pd2.tax_attribute_update_code IS NOT NULL
             )
       OR pll.tax_attribute_update_code IS NOT NULL
      );
  --Bug 10305728 end

END populate_all_dists_po;


-----------------------------------------------------------------------------
--Start of Comments
--Name: populate_zx_dists_with_rel
--Pre-reqs:
--  None
--Modifies:
--  ZX_ITM_DISTRIBUTIONS_GT
--Locks:
--  ZX_ITM_DISTRIBUTIONS_GT
--Function:
--  Populate ZX_ITM_DISTRIBUTIONS_GT with transaction distribution data
--Parameters:
--IN:
--p_po_release_id_tbl
--  PL/SQL table with list of po_release_id's to process for tax_calculation
--p_calling_program
--  Identifies the module that calls this procedure eg. 'PDOI'
--Notes:
--  Used by calculate_tax procedure. Not to be used externally
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE populate_zx_dists_with_rel(p_po_release_id_tbl  IN  PO_TBL_NUMBER,
                                     p_calling_program    IN  VARCHAR2
) IS
BEGIN
  -- Populate ZX_ITM_DISTRIBUTIONS_GT with all such distributions for which:
  -- 1. A sibling distribution was changed OR
  -- 2. There was a change at a parent level (header, line, shipment) OR
  -- 3. A distribution was deleted, hence its shipment is marked as 'DIST_DELETE'
  -- All the above cases are in one sql so that the same distribution is not
  -- populated twice, hence the OR conditions

  FORALL i in 1..p_po_release_id_tbl.COUNT
    INSERT INTO zx_itm_distributions_gt(
      application_id
      ,entity_code
      ,event_class_code
      ,trx_id
      ,trx_line_id
      ,trx_level_type
      ,trx_line_dist_id
      ,dist_level_action
      ,trx_line_dist_date
      ,item_dist_number
      ,task_id
      ,award_id
      ,project_id
      ,expenditure_type
      ,expenditure_organization_id
      ,expenditure_item_date
      ,trx_line_dist_amt
      ,trx_line_dist_qty
      ,trx_line_quantity
      ,account_ccid
      ,currency_exchange_rate
      ,overriding_recovery_rate
    )
    SELECT
      PO_CONSTANTS_SV.APPLICATION_ID --application_id
      ,PO_CONSTANTS_SV.REL_ENTITY_CODE --entity_code
      ,PO_CONSTANTS_SV.REL_EVENT_CLASS_CODE --event_class_code
      ,pd1.po_release_id --trx_id
      ,pll.line_location_id --trx_line_id
      ,PO_CONSTANTS_SV.REL_TRX_LEVEL_TYPE --trx_level_type
      ,pd1.po_distribution_id --trx_line_dist_id
      ,nvl(pd1.tax_attribute_update_code, 'NO_ACTION') --dist_level_action
      ,sysdate --trx_line_dist_date
      ,pd1.distribution_num --item_dist_number
      ,pd1.task_id --task_id
      ,pd1.award_id --award_id
      ,pd1.project_id --project_id
      ,pd1.expenditure_type --expenditure_type
      ,pd1.expenditure_organization_id --expenditure_organization_id
      ,pd1.expenditure_item_date --expenditure_item_date
      ,DECODE(pl.matching_basis, --trx_line_dist_amt
              'AMOUNT', pd1.amount_ordered,
              pd1.quantity_ordered*pll.price_override)
      ,pd1.quantity_ordered --trx_line_dist_qty
      ,pll.quantity --trx_line_quantity
      ,pd1.code_combination_id --account_ccid
      ,pd1.rate --currency_exchange_rate
      , decode(pd1.tax_recovery_override_flag, 'Y', pd1.recovery_rate, null) --overriding_recovery_rate
    FROM po_distributions_all pd1, po_line_locations_all pll, po_lines_all pl
    WHERE pd1.po_release_id = p_po_release_id_tbl(i)
    AND pd1.line_location_id=pll.line_location_id
    AND pll.po_line_id=pl.po_line_id
    AND (EXISTS(SELECT 'SIBLING DIST WITH TAUC'
                FROM po_distributions_all pd2
                WHERE pd2.line_location_id = pd1.line_location_id
                --AND pd2.po_distribution_id<>pd1.po_distribution_id
                AND pd2.tax_attribute_update_code IS NOT NULL
               )
         --OR pd1.tax_attribute_update_code IS NOT NULL
         OR pll.tax_attribute_update_code IS NOT NULL
        )
    AND pd1.po_release_id IN
      (SELECT trx_id FROM zx_trx_headers_gt
       WHERE event_class_code = PO_CONSTANTS_SV.REL_EVENT_CLASS_CODE);

END populate_zx_dists_with_rel;


-----------------------------------------------------------------------------
--Start of Comments
--Name: populate_all_dists_rel
--Pre-reqs:
--  None
--Modifies:
--  ZX_ITM_DISTRIBUTIONS_GT
--Locks:
--  ZX_ITM_DISTRIBUTIONS_GT
--Function:
--  Populate ZX_ITM_DISTRIBUTIONS_GT with transaction distribution data
--Parameters:
--IN:
--p_po_release_id
--  po_release_id to process
--Notes:
--  Used by determine_recovery_rel procedure. Not to be used externally
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE populate_all_dists_rel(p_po_release_id IN NUMBER) IS
BEGIN
  -- Populate ZX_ITM_DISTRIBUTIONS_GT with all distributions of the given Release

  INSERT INTO zx_itm_distributions_gt(
    application_id
    ,entity_code
    ,event_class_code
    ,trx_id
    ,trx_line_id
    ,trx_level_type
    ,trx_line_dist_id
    ,dist_level_action
    ,trx_line_dist_date
    ,item_dist_number
    ,task_id
    ,award_id
    ,project_id
    ,expenditure_type
    ,expenditure_organization_id
    ,expenditure_item_date
    ,trx_line_dist_amt
    ,trx_line_dist_qty
    ,trx_line_quantity
    ,account_ccid
    ,currency_exchange_rate
    ,overriding_recovery_rate
  )
  SELECT
    PO_CONSTANTS_SV.APPLICATION_ID --application_id
    ,PO_CONSTANTS_SV.REL_ENTITY_CODE --entity_code
    ,PO_CONSTANTS_SV.REL_EVENT_CLASS_CODE --event_class_code
    ,pd.po_release_id --trx_id
    ,pll.line_location_id --trx_line_id
    ,PO_CONSTANTS_SV.REL_TRX_LEVEL_TYPE --trx_level_type
    ,pd.po_distribution_id --trx_line_dist_id
    ,'NO_ACTION' --dist_level_action
    ,sysdate --trx_line_dist_date
    ,pd.distribution_num --item_dist_number
    ,pd.task_id --task_id
    ,pd.award_id --award_id
    ,pd.project_id --project_id
    ,pd.expenditure_type --expenditure_type
    ,pd.expenditure_organization_id --expenditure_organization_id
    ,pd.expenditure_item_date --expenditure_item_date
    -- Bug 5202059. Pass in correct amount
    ,DECODE(pl.matching_basis, --trx_line_dist_amt
            'AMOUNT', pd.amount_ordered,
            pd.quantity_ordered*pll.price_override)
    ,pd.quantity_ordered --trx_line_dist_qty
    ,pll.quantity --trx_line_quantity
    ,pd.code_combination_id --account_ccid
    ,pd.rate --currency_exchange_rate
    , decode(pd.tax_recovery_override_flag, 'Y', pd.recovery_rate, null) --overriding_recovery_rate
  FROM po_distributions_all pd, po_line_locations_all pll, po_lines_all pl
  WHERE pd.po_release_id = p_po_release_id
  AND pd.line_location_id = pll.line_location_id
  AND pll.po_line_id = pl.po_line_id
  -- Conditions that determine that po line is 'Active'
  AND nvl(pl.cancel_flag,'N') = 'N'
  AND nvl(pl.closed_code,'OPEN') <> 'FINALLY CLOSED'
  AND nvl(pll.cancel_flag,'N') = 'N'
  AND nvl(pll.closed_code,'OPEN') <> 'FINALLY CLOSED';

END populate_all_dists_rel;



-----------------------------------------------------------------------------
--Start of Comments
--Name: populate_zx_dists_with_req
--Pre-reqs:
--  None
--Modifies:
--  ZX_TRX_DISTS_GT
--Locks:
--  ZX_TRX_DISTS_GT
--Function:
--  Populate ZX_TRX_DISTS_GT with transaction distribution data
--Parameters:
--IN:
--p_requisition_header_id
--  requisition_header_id of the requisition to process for tax_calculation
--p_calling_program
--  Identifies the module that calls this procedure eg. 'PDOI'
--Notes:
--  Used by calculate_tax_requisition procedure. Not to be used externally
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE populate_zx_dists_with_req(p_requisition_header_id  IN  NUMBER,
                                     p_calling_program        IN  VARCHAR2
) IS
BEGIN
  -- Populate zx distributions table with requisition distributions data
  INSERT INTO zx_itm_distributions_gt(
    application_id
    ,entity_code
    ,event_class_code
    ,trx_id
    ,trx_line_id
    ,trx_level_type
    ,trx_line_dist_id
    ,dist_level_action
    ,trx_line_dist_date
    ,item_dist_number
    ,dist_intended_use
    ,task_id
    ,award_id
    ,project_id
    ,expenditure_type
    ,expenditure_organization_id
    ,expenditure_item_date
    ,trx_line_dist_amt
    ,trx_line_dist_qty
    ,trx_line_quantity
    ,account_ccid
    ,historical_flag
    ,overriding_recovery_rate)
  SELECT
    PO_CONSTANTS_SV.APPLICATION_ID --application_id
    ,PO_CONSTANTS_SV.REQ_ENTITY_CODE --entity_code
    ,PO_CONSTANTS_SV.REQ_EVENT_CLASS_CODE --event_class_code
    ,prl.requisition_header_id --trx_id
    ,prl.requisition_line_id --trx_line_id
    ,PO_CONSTANTS_SV.REQ_TRX_LEVEL_TYPE --trx_level_type
    ,prd.distribution_id --trx_line_dist_id
    ,'CREATE' --dist_level_action
    ,sysdate --trx_line_dist_date
    ,prd.distribution_num --item_dist_number
    ,null --dist_intended_use
    ,prd.task_id --task_id
    ,prd.award_id --award_id
    ,prd.project_id --project_id
    ,prd.expenditure_type --expenditure_type
    ,prd.expenditure_organization_id --expenditure_organization_id
    ,prd.expenditure_item_date --expenditure_item_date
    ,DECODE(prl.matching_basis,'AMOUNT', prd.REQ_LINE_AMOUNT, prd.req_line_quantity*prl.unit_price) --trx_line_dist_amt
    ,prd.req_line_quantity --trx_line_dist_qty
    ,prl.quantity --trx_line_quantity
    ,prd.code_combination_id --account_ccid
    ,null --historical_flag
    ,decode(prd.tax_recovery_override_flag, 'Y', prd.recovery_rate, null) --overriding_recovery_rate
  FROM po_requisition_lines_all prl, po_req_distributions_all prd
  WHERE prl.requisition_header_id = p_requisition_header_id
  AND prl.requisition_line_id = prd.requisition_line_id
  -- Conditions that determine that requisition line is 'Active'
  AND prl.SOURCE_TYPE_CODE<>'INVENTORY'
  AND nvl(prl.modified_by_agent_flag, 'N') = 'N'
  AND nvl(prl.cancel_flag, 'N') = 'N'
  AND nvl(prl.closed_code, 'OPEN') <> 'FINALLY CLOSED'
  AND prl.line_location_id IS NULL
  AND prl.at_sourcing_flag IS NULL;

END populate_zx_dists_with_req;



-----------------------------------------------------------------------------
--Start of Comments
--Name: calculate_tax_yes_no
--Pre-reqs:
--  Should be called before document is to be submitted for approval
--Modifies:
--  None
--Locks:
--  None
--Function:
--  Checks if tax needs to be re-calculated for a document before approval
--Parameters:
--IN:
--p_po_header_id
--  po_header_id of document for which tax re-calculation check has to be done
--p_po_release_id
--  po_header_id of document for which tax re-calculation check has to be done
--p_req_header_id
--  req_header_id of document for which tax re-calculation check has to be done
--OUT:
-- None
--RETURN:
--  Returns true if tax needs to be re-calculated else returns false
--Notes:
--  Checks if tax_attribute_update_code flag has a NOT NULL value
--  at any level in the document, if yes then return true else return false
--End of Comments
-----------------------------------------------------------------------------
FUNCTION calculate_tax_yes_no
        (p_po_header_id        IN          NUMBER,
         p_po_release_id       IN          NUMBER,
         p_req_header_id       IN          NUMBER)
RETURN VARCHAR2
IS

l_Result VARCHAR2(4);
l_module_name CONSTANT VARCHAR2(100) := 'CALCULATE_TAX_YES_NO';
d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(
                                          D_PACKAGE_BASE, l_module_name);
d_progress NUMBER;

BEGIN

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'p_po_header_id',  p_po_header_id);
    PO_LOG.proc_begin(d_module_base, 'p_po_release_id', p_po_release_id);
    PO_LOG.proc_begin(d_module_base, 'p_req_header_id', p_req_header_id);
  END IF;

  d_progress := 0;
  l_result := 'N';

  BEGIN

    IF p_po_header_id IS NOT NULL THEN

      d_progress := 10;

      SELECT 'Y' INTO l_result
      FROM DUAL
      WHERE EXISTS
       (SELECT 'Y'
        FROM  po_headers_all        POH,
              po_lines_all          POL,
              po_line_locations_all PLL,
              po_distributions_all  POD
        WHERE POH.po_header_id = p_po_header_id
          AND POH.po_header_id = POL.po_header_id
          AND POL.po_line_id   = PLL.po_line_id
          AND PLL.line_location_id = POD.line_location_id
          AND NVL(POL.cancel_flag,'N') = 'N'
          AND NVL(POL.closed_code,'OPEN') <> 'FINALLY CLOSED'
          AND NVL(PLL.cancel_flag,'N') = 'N'
          AND NVL(PLL.closed_code,'OPEN') <> 'FINALLY CLOSED'
          AND (POH.tax_attribute_update_code IS NOT NULL OR
               POL.tax_attribute_update_code IS NOT NULL OR
               PLL.tax_attribute_update_code IS NOT NULL OR
               POD.tax_attribute_update_code IS NOT NULL
              )
       );

    ELSIF p_po_release_id  IS NOT NULL THEN

      d_progress := 20;

      SELECT 'Y' INTO l_Result
      FROM DUAL
      WHERE EXISTS
       (SELECT 'Y'
        FROM  po_releases_all       POR,
              po_line_locations_all PLL,
              po_distributions_all  POD
        WHERE POR.po_release_id = p_po_release_id
          AND POR.po_release_id = PLL.po_release_id
          AND PLL.line_location_id = POD.line_location_id
          AND NVL(PLL.cancel_flag,'N') = 'N'
          AND NVL(PLL.closed_code,'OPEN') <> 'FINALLY CLOSED'
          AND (POR.tax_attribute_update_code IS NOT NULL OR
               PLL.tax_attribute_update_code IS NOT NULL OR
               POD.tax_attribute_update_code IS NOT NULL
              )
       );
    ELSIF p_req_header_id IS NOT NULL THEN

      d_progress := 30;

      SELECT 'Y' INTO l_Result
      FROM DUAL
      WHERE EXISTS
       (SELECT 'Y'
        FROM  po_requisition_headers_all  PRH,
              po_requisition_lines_all    PRL
        WHERE PRH.requisition_header_id = p_req_header_id
          AND PRH.requisition_header_id = PRL.requisition_header_id
          AND NVL(PRL.cancel_flag, 'N') = 'N'
          AND NVL(PRL.closed_code, 'OPEN') <> 'FINALLY CLOSED'
          AND (PRH.tax_attribute_update_code IS NOT NULL OR
               PRL.tax_attribute_update_code IS NOT NULL
              )
       );
    END IF;

    d_progress := 40;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_result := 'N';
  END;

  d_progress := 50;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module_base);
    PO_LOG.proc_end(d_module_base, 'l_result', l_result);
  END IF;

  RETURN l_result;

EXCEPTION
  WHEN OTHERS THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module_base, d_progress, SQLCODE || SQLERRM);
    END IF;
    RAISE;
END calculate_tax_yes_no;



-----------------------------------------------------------------------------
--Start of Comments
--Name: populate_zx_record
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
--  Populates zx record TRX_LINE_DIST_TBL
--Parameters:
--IN:
--p_req_header_id
--  req_header_id of requisition
--OUT:
-- None
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE populate_zx_record(p_requisition_header_id    IN    NUMBER) IS
  l_count NUMBER;
BEGIN
  l_count :=0;
  FOR i IN successful_documents_csr(p_requisition_header_id) LOOP
    l_count := l_count + 1;
    ZX_GLOBAL_STRUCTURES_PKG.INIT_TRX_LINE_DIST_TBL(l_count);

    SELECT
      zxhgt.internal_organization_id
      ,zxhgt.application_id
      ,zxhgt.entity_code
      ,zxhgt.event_class_code
      ,zxhgt.event_type_code
      ,zxhgt.trx_id
      ,zxhgt.trx_date
      ,zxhgt.ledger_id
      ,zxhgt.legal_entity_id
      ,zxhgt.rounding_bill_to_party_id
      ,zxhgt.quote_flag
      ,zxhgt.document_sub_type
      ,zxhgt.default_taxation_country

      ,zxlgt.trx_level_type
      ,zxlgt.trx_line_id
      ,zxlgt.line_class
      ,zxlgt.line_level_action
      ,zxlgt.trx_line_type
      ,zxlgt.trx_line_date
      ,zxlgt.trx_business_category
      ,zxlgt.line_intended_use
      ,zxlgt.user_defined_fisc_class
      ,zxlgt.line_amt_includes_tax_flag
      ,zxlgt.line_amt
      ,zxlgt.trx_line_quantity
      ,zxlgt.unit_price
      ,zxlgt.product_id
      ,zxlgt.product_fisc_classification
      ,zxlgt.product_org_id
      ,zxlgt.uom_code
      ,zxlgt.product_type
      ,zxlgt.product_code
      ,zxlgt.product_category
      ,zxlgt.ship_to_party_id
      ,zxlgt.ship_from_party_id
      ,zxlgt.bill_to_party_id
      ,zxlgt.bill_from_party_id
      ,zxlgt.ship_from_party_site_id
      ,zxlgt.bill_from_party_site_id
      ,zxlgt.ship_to_location_id
      ,ship_from_location_id
      ,zxlgt.bill_to_location_id
      ,zxlgt.bill_from_location_id      /* 8752470 */
      ,zxlgt.ship_third_pty_acct_id
      ,zxlgt.ship_third_pty_acct_site_id
      ,zxlgt.assessable_value
      ,zxlgt.historical_flag
      ,zxlgt.trx_line_currency_code
      ,zxlgt.trx_line_currency_conv_date
      ,zxlgt.trx_line_currency_conv_rate
      ,zxlgt.trx_line_currency_conv_type
      ,zxlgt.trx_line_mau
      ,zxlgt.trx_line_precision
      ,zxlgt.historical_tax_code_id
      ,zxlgt.input_tax_classification_code
      ,zxlgt.account_ccid
      -- Bug 5025018. Updated tax attribute mappings
      ,zxlgt.bill_third_pty_acct_id
      ,zxlgt.bill_third_pty_acct_site_id
      -- Bug 5079867. Line number and description in ATI page
      ,zxlgt.trx_line_number
      ,zxlgt.trx_line_description
      ,zxlgt.product_description
      -- Bug 5082762. Product Type dropped when line is updated
      ,zxlgt.user_upd_det_factors_flag
      ,zxlgt.DEFAULTING_ATTRIBUTE1 --Bug#6902111

    INTO
      ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.internal_organization_id(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.application_id(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.entity_code(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.event_class_code(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.event_type_code(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.trx_id(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.trx_date(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ledger_id(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.legal_entity_id(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.rounding_bill_to_party_id(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.quote_flag(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.document_sub_type(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.default_taxation_country(l_count)

      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.trx_level_type(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.trx_line_id(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.line_class(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.line_level_action(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.trx_line_type(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.trx_line_date(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.trx_business_category(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.line_intended_use(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.user_defined_fisc_class(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.line_amt_includes_tax_flag(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.line_amt(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.trx_line_quantity(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.unit_price(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.product_id(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.product_fisc_classification(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.product_org_id(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.uom_code(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.product_type(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.product_code(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.product_category(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ship_to_party_id(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ship_from_party_id(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.bill_to_party_id(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.bill_from_party_id(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ship_from_party_site_id(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.bill_from_party_site_id(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ship_to_location_id(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ship_from_location_id(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.bill_to_location_id(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.bill_from_location_id(l_count)      /* 8752470 */
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ship_third_pty_acct_id(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ship_third_pty_acct_site_id(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.assessable_value(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.historical_flag(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.trx_line_currency_code(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.trx_line_currency_conv_date(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.trx_line_currency_conv_rate(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.trx_line_currency_conv_type(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.trx_line_mau(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.trx_line_precision(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.historical_tax_code_id(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.input_tax_classification_code(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.account_ccid(l_count)
      -- Bug 5025018. Updated tax attribute mappings
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.bill_third_pty_acct_id(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.bill_third_pty_acct_site_id(l_count)
      -- Bug 5079867. Line number and description in ATI page
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.trx_line_number(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.trx_line_description(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.product_description(l_count)
      -- Bug 5082762. Product Type dropped when line is updated
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.user_upd_det_factors_flag(l_count)
      ,ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.DEFAULTING_ATTRIBUTE1(l_count) --Bug#6902111
    FROM zx_trx_headers_gt zxhgt, zx_transaction_lines_gt zxlgt
    WHERE zxlgt.trx_line_id = i.trx_line_id
    AND zxlgt.trx_id = zxhgt.trx_id;

  END LOOP;

END populate_zx_record;



-----------------------------------------------------------------------------
--Start of Comments
--Name: shipments_deleted_from_oa
--Pre-reqs:
--  Should be called before document is to be submitted for approval
--Modifies:
--  None
--Locks:
--  None
--Function:
--  Checks if tax needs to be re-calculated for a document before approval
--Parameters:
--IN:
--p_po_header_id
--  po_header_id of document for which shipments or distributions are deleted
--p_del_shipment_table
--  PL/SQL table of Numbers holding non-repeated deleted shipments Ids
--  deleted
--p_del_dist_shipment_table
--  /SQL table of Numbers holding non-repeated deleted shipments Ids for which
--  corresponding distributions are deleted
--OUT:
-- None
--Notes:
--  This routine populates zx tables with the shipments that are deleted or have
--  their distribution deleted
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE SHIPMENT_DIST_DELETED_FROM_OA
(
 P_PO_HEADER_ID              IN NUMBER,
 P_DEL_SHIPMENT_TABLE        IN PO_TBL_NUMBER,
 P_DEL_DIST_SHIPMENT_TABLE   IN PO_TBL_NUMBER
 )
 IS
  l_module_name CONSTANT VARCHAR2(100) := 'shipment_dist_deleted_from_oa';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(
                                           D_PACKAGE_BASE, l_module_name);
  d_progress NUMBER;

  -- Bug#14170238
  l_transaction_line_rec_type ZX_API_PUB.transaction_line_rec_type;
  l_return_status             VARCHAR2(1);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);
  l_line_location_org_id      NUMBER;

BEGIN
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'p_po_header_id', p_po_header_id);
    PO_LOG.proc_begin(d_module_base, 'p_del_shipment_table', P_DEL_SHIPMENT_TABLE.COUNT);
    PO_LOG.proc_begin(d_module_base, 'p_del_dist_shipment_table', P_DEL_DIST_SHIPMENT_TABLE.COUNT);
  END IF;

  d_progress := 0;
  --
  -- Update line tax_attribute_code to DIST_DELETE
  -- for which distributions are deleted
  --

  FORALL i IN 1..p_del_dist_shipment_table.COUNT
    UPDATE po_line_locations_all
       SET tax_attribute_update_code = NVL(tax_attribute_update_code,'DIST_DELETE')
     WHERE line_location_id = p_del_dist_shipment_table(i);

  IF PO_LOG.d_stmt THEN
     PO_LOG.stmt(d_module_base,d_progress,'Number of records updated in po_line_locations_all : '||
                SQL%ROWCOUNT);
  END IF;

  d_progress := 10;

  --
  -- Bug#14170238 : get internal_organization_id to pass to ebTax
  --
  SELECT org_id
    INTO l_line_location_org_id
  FROM po_headers_all
  WHERE po_header_id = p_po_header_id;

  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_module_base,d_progress,' l_line_location_org_id :  '||
                l_line_location_org_id);
  END IF;

  --
  -- Insert shipments ids that are deleted. However do not insert rows if
  -- there are no corresponding tax lines to delete
  --
 /* Bug#14170238 : call ZX_API_PUB.del_tax_line_and_distribution instead
  *
  FORALL i IN 1..p_del_shipment_table.COUNT
  INSERT INTO zx_transaction_lines_gt
   (
     application_id,
     entity_code,
     event_class_code,
     trx_id,
     trx_level_type,
     trx_line_id,
     line_level_action,
     line_amt,
     line_amt_includes_tax_flag
   )
  SELECT
      PO_CONSTANTS_SV.APPLICATION_ID,        --application_id
      PO_CONSTANTS_SV.PO_ENTITY_CODE,        --entity_code
      PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE,   --event_class_code
      p_po_header_id,                        --trx_id
      PO_CONSTANTS_SV.PO_TRX_LEVEL_TYPE,     --trx_level_type
      p_del_shipment_table(i),               --trx_line_id
      'DELETE',                              --line_level_action
      -1,
      'N'
  --<Bug 5135037> Added the EXISTS clause so that only one row is inserted
  --into gt table even if there are multiple tax lines for each shipment
  FROM dual
  WHERE EXISTS
    (SELECT 'TAX LINES EXIST'
       -- FROM zx_lines zl   Bug#14170238
     FROM zx_lines_det_factors zldf
     -- Restrict to only rows that have corresponding tax lines
     -- Since this is called from OA, so conditions are only for SPO
    WHERE zldf.trx_id = p_po_header_id
     AND zldf.trx_line_id = p_del_shipment_table(i)
     AND zldf.application_id = PO_CONSTANTS_SV.APPLICATION_ID
     AND zldf.entity_code = PO_CONSTANTS_SV.PO_ENTITY_CODE
     AND zldf.event_class_code = PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE
     AND zldf.trx_level_type = PO_CONSTANTS_SV.PO_TRX_LEVEL_TYPE
    );
  *
  */

    d_progress := 15;

  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_module_base,d_progress,'calling ZX_API_PUB.del_tax_line_and_distributions' );
  END IF;

  --
  -- Bug#14170238: populate transaction_line_rec_type before calling
  -- ZX delete API
  --
  FOR i IN 1..p_del_shipment_table.COUNT
    LOOP
         l_transaction_line_rec_type.internal_organization_id := l_line_location_org_id;
         l_transaction_line_rec_type.application_id           := PO_CONSTANTS_SV.APPLICATION_ID;
         l_transaction_line_rec_type.entity_code              := PO_CONSTANTS_SV.PO_ENTITY_CODE ;
         l_transaction_line_rec_type.event_class_code         := PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE;
         l_transaction_line_rec_type.event_type_code          := PO_CONSTANTS_SV.PO_ADJUSTED;
         l_transaction_line_rec_type.trx_id                   := p_po_header_id;
         l_transaction_line_rec_type.trx_level_type           := PO_CONSTANTS_SV.PO_TRX_LEVEL_TYPE;
         l_transaction_line_rec_type.trx_line_id              := p_del_shipment_table(i);

         l_return_status := FND_API.G_RET_STS_SUCCESS;

           ZX_API_PUB.del_tax_line_and_distributions(
               p_api_version             =>  1.0,
               p_init_msg_list           =>  FND_API.G_TRUE,
               p_commit                  =>  FND_API.G_FALSE,
               p_validation_level        =>  FND_API.G_VALID_LEVEL_FULL,
               x_return_status           =>  l_return_status,
               x_msg_count               =>  l_msg_count,
               x_msg_data                =>  l_msg_data,
               p_transaction_line_rec    =>  l_transaction_line_rec_type
           );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

    END LOOP;

  d_progress := 17;

  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_module_base,d_progress,'Return status from ZX' || l_return_status );
  END IF;

  d_progress := 20;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module_base);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module_base, d_progress, SQLCODE || SQLERRM);
    END IF;
    RAISE;
END SHIPMENT_DIST_DELETED_FROM_OA;



-----------------------------------------------------------------------------
--Start of Comments
--Name: append_error
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
--  Append an error to the global error record G_TAX_ERRORS_TBL
--Parameters:
--IN:
--p_error_level
--  The depth in current flow at which error occured
--p_document_type_code
--  Type of document for which error occured
--p_document_id
--  Id of document for which error occured
--p_document_num
--  Number of document for which error occured
--p_line_id
--  Id of line in the document for which error occured
--p_line_num
--  Number of line in the document for which error occured
--p_line_location_id
--  Id of shipment in the document for which error occured
--p_shipment_num
--  Number of shipment in the document for which error occured
--p_distribution_id
--  Id of distribution in the document for which error occured
--p_distribution_num
--  Number of distribution in the document for which error occured
--p_message_text
--  Error message to add
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE append_error(p_error_level         IN VARCHAR2,
                       p_document_type_code  IN VARCHAR2,
                       p_document_id         IN NUMBER,
                       p_document_num        IN VARCHAR2, --<Bug 9661881>
                       p_line_id             IN NUMBER,
                       p_line_num            IN NUMBER,
                       p_line_location_id    IN NUMBER,
                       p_shipment_num        IN NUMBER,
                       p_distribution_id     IN NUMBER,
                       p_distribution_num    IN NUMBER,
                       p_message_text        IN VARCHAR2
) IS
  l_module_name CONSTANT VARCHAR2(100) := 'APPEND_ERROR';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(
                                            D_PACKAGE_BASE, l_module_name);
  d_progress NUMBER;
  l_length NUMBER;
BEGIN
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'p_error_level', p_error_level);
    PO_LOG.proc_begin(d_module_base, 'p_document_type_code', p_document_type_code);
    PO_LOG.proc_begin(d_module_base, 'p_document_id', p_document_id);
    PO_LOG.proc_begin(d_module_base, 'p_document_num', p_document_num);
    PO_LOG.proc_begin(d_module_base, 'p_line_id', p_line_id);
    PO_LOG.proc_begin(d_module_base, 'p_line_num', p_line_num);
    PO_LOG.proc_begin(d_module_base, 'p_line_location_id', p_line_location_id);
    PO_LOG.proc_begin(d_module_base, 'p_shipment_num', p_shipment_num);
    PO_LOG.proc_begin(d_module_base, 'p_distribution_id', p_distribution_id);
    PO_LOG.proc_begin(d_module_base, 'p_distribution_num', p_distribution_num);
    PO_LOG.proc_begin(d_module_base, 'p_message_text', p_message_text);
  END IF;

  d_progress := 0;
  G_TAX_ERRORS_TBL.error_level.extend;
  G_TAX_ERRORS_TBL.document_type_code.extend;
  G_TAX_ERRORS_TBL.document_id.extend;
  G_TAX_ERRORS_TBL.document_num.extend;
  G_TAX_ERRORS_TBL.line_id.extend;
  G_TAX_ERRORS_TBL.line_num.extend;
  G_TAX_ERRORS_TBL.line_location_id.extend;
  G_TAX_ERRORS_TBL.shipment_num.extend;
  G_TAX_ERRORS_TBL.distribution_id.extend;
  G_TAX_ERRORS_TBL.distribution_num.extend;
  G_TAX_ERRORS_TBL.message_text.extend;

  d_progress := 10;
  l_length := G_TAX_ERRORS_TBL.error_level.COUNT;

  d_progress := 20;
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_module_base,d_progress,'l_length= '||l_length);
  END IF;

  d_progress := 30;
  G_TAX_ERRORS_TBL.error_level(l_length)        := p_error_level;
  G_TAX_ERRORS_TBL.document_type_code(l_length) := p_document_type_code;
  G_TAX_ERRORS_TBL.document_id(l_length)        := p_document_id;
  G_TAX_ERRORS_TBL.document_num(l_length)       := p_document_num;
  G_TAX_ERRORS_TBL.line_id(l_length)            := p_line_id;
  G_TAX_ERRORS_TBL.line_num(l_length)           := p_line_num;
  G_TAX_ERRORS_TBL.line_location_id(l_length)   := p_line_location_id;
  G_TAX_ERRORS_TBL.shipment_num(l_length)       := p_shipment_num;
  G_TAX_ERRORS_TBL.distribution_id(l_length)    := p_distribution_id;
  G_TAX_ERRORS_TBL.distribution_num(l_length)   := p_distribution_num;
  G_TAX_ERRORS_TBL.message_text(l_length)       := p_message_text;

  d_progress := 40;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module_base);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module_base, d_progress, SQLCODE || SQLERRM);
    END IF;
END append_error;



-----------------------------------------------------------------------------
--Start of Comments
--Name: initialize_zx_gt_tables
--Pre-reqs:
--  None
--Modifies:
--  ZX_TRX_HEADERS_GT
--  ZX_TRANSACTION_LINES_GT
--  ZX_ITM_DISTRIBUTIONS_GT
--  ZX_VALIDATION_ERRORS_GT
--  ZX_ERRORS_GT
--Locks:
--  ZX_TRX_HEADERS_GT
--  ZX_TRANSACTION_LINES_GT
--  ZX_ITM_DISTRIBUTIONS_GT
--  ZX_VALIDATION_ERRORS_GT
--  ZX_ERRORS_GT
--Function:
--  Wipe out all data from ZX Global Temporary tables used in PO transaction
--  except if there are lines populated that have action='DELETE'. This
--  exception is for HTML Orders case where deletions come pre-populated in
--  the GT tables
--Parameters:
--IN:
--Notes:
--  For internal use only. Used within this package by calculate_tax,
--  calculate_tax_requisition and determine_recovery.. procedures
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE initialize_zx_gt_tables IS
  l_module_name CONSTANT VARCHAR2(100) := 'INITIALIZE_ZX_GT_TABLES';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(
                                            D_PACKAGE_BASE, l_module_name);
  d_progress NUMBER;
  l_clear_tables VARCHAR2(1);
BEGIN
  d_progress := 0;

  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_module_base,d_progress,'Initial state of zx gt tables:');
    log_header_tax_attributes(d_module_base,d_progress);
    log_line_tax_attributes(d_module_base,d_progress);
    log_dist_tax_attributes(d_module_base,d_progress);
  END IF;

  BEGIN
    SELECT 'Y'
    INTO l_clear_tables
    FROM dual
    WHERE EXISTS
      (SELECT 'CLEAR'
       FROM zx_transaction_lines_gt zxlgt
       WHERE zxlgt.line_level_action <> 'DELETE');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_clear_tables := 'N';
  END;

  d_progress := 10;
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_module_base,d_progress,'l_clear_tables = '||l_clear_tables);
  END IF;

  IF (l_clear_tables = 'Y') THEN
    wipe_zx_gt_tables();
  END IF;
  d_progress := 20;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module_base);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module_base, d_progress, SQLCODE || SQLERRM);
    END IF;
END initialize_zx_gt_tables;



-----------------------------------------------------------------------------
--Start of Comments
--Name: wipe_zx_gt_tables
--Pre-reqs:
--  None
--Modifies:
--  ZX_TRX_HEADERS_GT
--  ZX_TRANSACTION_LINES_GT
--  ZX_ITM_DISTRIBUTIONS_GT
--  ZX_VALIDATION_ERRORS_GT
--  ZX_ERRORS_GT
--Locks:
--  ZX_TRX_HEADERS_GT
--  ZX_TRANSACTION_LINES_GT
--  ZX_ITM_DISTRIBUTIONS_GT
--  ZX_VALIDATION_ERRORS_GT
--  ZX_ERRORS_GT
--Function:
--  Wipe out all data from ZX Global Temporary tables
--Parameters:
--IN:
--Notes:
--  For internal use only. Used within this package by calculate_tax,
--  calculate_tax_requisition and initialize_zx_gt_tables
--  Introduced with Bug 5363122
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE wipe_zx_gt_tables IS
  l_module_name CONSTANT VARCHAR2(100) := 'WIPE_ZX_GT_TABLES';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(
                                            D_PACKAGE_BASE, l_module_name);
  d_progress NUMBER;
  l_clear_tables VARCHAR2(1);
BEGIN
  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
  END IF;

  DELETE ZX_TRX_HEADERS_GT;
  d_progress := 10;
  DELETE ZX_TRANSACTION_LINES_GT;
  d_progress := 20;
  DELETE ZX_ITM_DISTRIBUTIONS_GT;
  d_progress := 30;
  DELETE ZX_VALIDATION_ERRORS_GT;
  d_progress := 40;
  DELETE ZX_ERRORS_GT;

  d_progress := 50;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module_base);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module_base, d_progress, SQLCODE || SQLERRM);
    END IF;
END wipe_zx_gt_tables;



-----------------------------------------------------------------------------
--Start of Comments
--Name: initialize_global_error_record
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
--  Initialized global error record and resets its counter to 0
--Parameters:
--IN:
--OUT:
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE initialize_global_error_record IS BEGIN
  G_TAX_ERRORS_TBL.error_level        := PO_TBL_VARCHAR20();
  G_TAX_ERRORS_TBL.document_type_code := PO_TBL_VARCHAR25();
  G_TAX_ERRORS_TBL.document_id        := PO_TBL_NUMBER();
  G_TAX_ERRORS_TBL.document_num       := PO_TBL_VARCHAR20(); --<9661881>
  G_TAX_ERRORS_TBL.line_id            := PO_TBL_NUMBER();
  G_TAX_ERRORS_TBL.line_num           := PO_TBL_NUMBER();
  G_TAX_ERRORS_TBL.line_location_id   := PO_TBL_NUMBER();
  G_TAX_ERRORS_TBL.shipment_num       := PO_TBL_NUMBER();
  G_TAX_ERRORS_TBL.distribution_id    := PO_TBL_NUMBER();
  G_TAX_ERRORS_TBL.distribution_num   := PO_TBL_NUMBER();
  G_TAX_ERRORS_TBL.message_text       := PO_TBL_VARCHAR2000();
END initialize_global_error_record;



-----------------------------------------------------------------------------
--Start of Comments
--Name: any_tax_attributes_updated
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function
--  Determine whether any tax attributes are modified or not.
--Parameters:
--IN:
--p_doc_type
--  document type
--p_doc_level
--  this determines the level of the document HEADER,LINE
--p_doc_level_id
--  unique identifier of the level
--p_trx_currency
--  currency of the transaction
--p_rate_type
--  rate type of the document
--p_rate_date
--  rate date of the document
--p_rate
--  currency rate
--p_fob :
--  FOB of the document
--p_vendor_id
--  Supplier id
--p_vendor_site_id
--  Supplier Site id
--p_uom
--  Unit of measure
--p_price
--  unit price
--p_qty
--  quantity
--p_amt
--  Amount
--p_ship_to_org
--  Ship to Org
--p_ship_to_loc
--  Ship to Location ID
--p_need_by_date
--  Need by date
--p_src_doc
--  Source document
--p_src_ship
--  Source Shipment
--p_ccid
--  Code combination id
--p_tax_rec_rate
--  Tax Recovery Rate
--p_project
--  Project
--p_task
--  Project Task
--p_award
--  Project Award
--p_exp_type
--  Project Expenditure Type
--p_exp_org
--  Project Expenditure Organization
--p_exp_date
--  Project Expenditure date
-- OUT:
--End of Comments
-----------------------------------------------------------------------------
FUNCTION any_tax_attributes_updated(
  p_doc_type        IN  VARCHAR2,
  p_doc_level       IN  VARCHAR2,
  p_doc_level_id    IN  NUMBER,
  p_trx_currency    IN  VARCHAR2  DEFAULT NULL,
  p_rate_type       IN  VARCHAR2  DEFAULT NULL,
  p_rate_date       IN  DATE      DEFAULT NULL,
  p_rate            IN  NUMBER    DEFAULT NULL,
  p_fob             IN  VARCHAR2  DEFAULT NULL,
  p_vendor_id       IN  NUMBER    DEFAULT NULL,
  p_vendor_site_id  IN  NUMBER    DEFAULT NULL,
  p_bill_to_loc     IN  NUMBER    DEFAULT NULL, --<ECO 5524555>
  p_uom             IN  VARCHAR2  DEFAULT NULL,
  p_price           IN  NUMBER    DEFAULT NULL,
  p_qty             IN  NUMBER    DEFAULT NULL,
  p_price_override  IN  NUMBER    DEFAULT NULL, --<Bug 5647417>
  p_amt             IN  NUMBER    DEFAULT NULL,
  p_ship_to_org     IN  NUMBER    DEFAULT NULL,
  p_ship_to_loc     IN  NUMBER    DEFAULT NULL,
  p_need_by_date    IN  DATE      DEFAULT NULL,
  p_src_doc         IN  NUMBER    DEFAULT NULL,
  p_src_ship        IN  NUMBER    DEFAULT NULL,
  p_ccid            IN  NUMBER    DEFAULT NULL,
  p_tax_rec_rate    IN  NUMBER    DEFAULT NULL,
  p_project         IN  NUMBER    DEFAULT NULL,
  p_task            IN  NUMBER    DEFAULT NULL,
  p_award           IN  NUMBER    DEFAULT NULL,
  p_exp_type        IN  VARCHAR2  DEFAULT NULL,
  p_exp_org         IN  NUMBER    DEFAULT NULL,
  p_exp_date        IN  DATE      DEFAULT NULL,
  p_dist_quantity_ordered  IN  NUMBER    DEFAULT NULL,
  p_dist_amount_ordered  IN  NUMBER    DEFAULT NULL
) RETURN BOOLEAN IS
  pragma AUTONOMOUS_TRANSACTION;

  l_trx_currency    PO_HEADERS_ALL.CURRENCY_CODE%type;
  l_rate_type       PO_HEADERS_ALL.RATE_TYPE %type;
  l_rate_date       PO_HEADERS_ALL. RATE_DATE%type;
  l_rate            PO_HEADERS_ALL. RATE%type;
  l_fob             PO_HEADERS_ALL.FOB_LOOKUP_CODE%type ;
  l_vendor_id       PO_HEADERS_ALL.VENDOR_ID%type;
  l_vendor_site_id  PO_HEADERS_ALL.VENDOR_SITE_ID%type ;
  l_bill_to_loc     PO_HEADERS_ALL.BILL_TO_LOCATION_ID%type; --<ECO 5524555>
  l_uom             PO_LINES_ALL.UNIT_MEAS_LOOKUP_CODE%type;
  l_price           PO_LINES_ALL.UNIT_PRICE%type;
  l_qty             PO_LINE_LOCATIONS_ALL.QUANTITY%type;
  l_price_override  PO_LINE_LOCATIONS_ALL.PRICE_OVERRIDE%type; --<Bug 5647417>
  l_amt             PO_LINE_LOCATIONS_ALL.AMOUNT%type;
  l_ship_to_org     PO_LINE_LOCATIONS_ALL.SHIP_TO_ORGANIZATION_ID%type;
  l_ship_to_loc     PO_LINE_LOCATIONS_ALL.SHIP_TO_LOCATION_ID%type;
  l_need_by_date    PO_LINE_LOCATIONS_ALL.NEED_BY_DATE%type ;
  l_ccid            PO_DISTRIBUTIONS_ALL.CODE_COMBINATION_ID%type;
  l_tax_rec_rate    PO_DISTRIBUTIONS_ALL.RECOVERY_RATE%type;
  l_project         PO_DISTRIBUTIONS_ALL.PROJECT_ID%type;
  l_task            PO_DISTRIBUTIONS_ALL.TASK_ID%type;
  l_award           PO_DISTRIBUTIONS_ALL.AWARD_ID%type;
  l_exp_type        PO_DISTRIBUTIONS_ALL.EXPENDITURE_TYPE%type;
  l_exp_org         PO_DISTRIBUTIONS_ALL.EXPENDITURE_ORGANIZATION_ID%type;
  l_exp_date        PO_DISTRIBUTIONS_ALL.EXPENDITURE_ITEM_DATE%type;
  l_dist_quantity_ordered PO_DISTRIBUTIONS_ALL.QUANTITY_ORDERED%type;
  l_dist_amount_ordered PO_DISTRIBUTIONS_ALL.AMOUNT_ORDERED%type;

  l_module_name CONSTANT VARCHAR2(100) := 'ANY_TAX_ATTRIBUTES_UPDATED';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(
                                           D_PACKAGE_BASE, l_module_name);
  d_progress NUMBER;
BEGIN

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'p_doc_type', p_doc_type);
    PO_LOG.proc_begin(d_module_base, 'p_doc_level', p_doc_level);
    PO_LOG.proc_begin(d_module_base, 'p_doc_level_id',p_doc_level_id );
    PO_LOG.proc_begin(d_module_base,'p_trx_currency',p_trx_currency);
    PO_LOG.proc_begin(d_module_base,'p_rate_type',p_rate_type);
    PO_LOG.proc_begin(d_module_base,'p_rate_date',p_rate_date);
    PO_LOG.proc_begin(d_module_base,'p_rate',p_rate);
    PO_LOG.proc_begin(d_module_base,'p_fob',p_fob);
    PO_LOG.proc_begin(d_module_base,'p_vendor_id',p_vendor_id);
    PO_LOG.proc_begin(d_module_base,'p_vendor_site_id',p_vendor_site_id);
    PO_LOG.proc_begin(d_module_base,'p_bill_to_loc',p_bill_to_loc);
    PO_LOG.proc_begin(d_module_base,'p_uom',p_uom);
    PO_LOG.proc_begin(d_module_base,'p_price',p_price);
    PO_LOG.proc_begin(d_module_base,'p_qty',p_qty);
    PO_LOG.proc_begin(d_module_base,'p_price_override',p_price_override);
    PO_LOG.proc_begin(d_module_base,'p_amt',p_amt);
    PO_LOG.proc_begin(d_module_base,'p_ship_to_org',p_ship_to_org);
    PO_LOG.proc_begin(d_module_base,'p_ship_to_loc',p_ship_to_loc);
    PO_LOG.proc_begin(d_module_base,'p_need_by_date',p_need_by_date);
    PO_LOG.proc_begin(d_module_base,'p_src_doc',p_src_doc);
    PO_LOG.proc_begin(d_module_base,'p_src_ship',p_src_ship);
    PO_LOG.proc_begin(d_module_base,'p_ccid',p_ccid);
    PO_LOG.proc_begin(d_module_base,'p_tax_rec_rate',p_tax_rec_rate);
    PO_LOG.proc_begin(d_module_base,'p_project',p_project);
    PO_LOG.proc_begin(d_module_base,'p_task',p_task);
    PO_LOG.proc_begin(d_module_base,'p_award',p_award);
    PO_LOG.proc_begin(d_module_base,'p_exp_type',p_exp_type);
    PO_LOG.proc_begin(d_module_base,'p_exp_org',p_exp_org);
    PO_LOG.proc_begin(d_module_base,'p_exp_date',p_exp_date);
  END IF;

  d_progress := 0;
  IF (p_doc_type = 'PO') THEN
    CASE p_doc_level
      WHEN 'HEADER' THEN
        BEGIN
          -- PO Header Tax determining attributes
          d_progress := 10;
          SELECT currency_code,
                 rate_type,
                 rate_date,
                 rate,
                 fob_lookup_code,
                 vendor_id,
                 vendor_site_id,
                 bill_to_location_id --<ECO 5524555>
          INTO   l_trx_currency,
                 l_rate_type,
                 l_rate_date,
                 l_rate,
                 l_fob,
                 l_vendor_id,
                 l_vendor_site_id,
                 l_bill_to_loc --<ECO 5524555>
          FROM   po_headers_all
          WHERE  po_header_id = p_doc_level_id;
        END;
        IF ((nvl(l_trx_currency,'-99') = nvl(p_trx_currency,'-99'))  AND
           (nvl(l_rate_type,'-99')    = nvl(p_rate_type,'-99'))     AND
           (nvl(l_rate_date,sysdate) = nvl(p_rate_date,sysdate)) AND
           (nvl(l_rate,99)         = nvl(p_rate,99))            AND
           (nvl(l_fob,99)          = nvl(p_fob,99))             AND
           (nvl(l_vendor_id,99)    = nvl(p_vendor_id,99))       AND
           (nvl(l_vendor_site_id,99) = nvl(p_vendor_site_id,99)) AND
           (nvl(l_bill_to_loc,-99) = nvl(p_bill_to_loc,-99)) ) --<ECO 5524555>
        THEN
          PO_LOG.stmt(d_module_base,d_progress,'header is unchanged');
          return(FALSE);
        ELSE
          PO_LOG.stmt(d_module_base,d_progress,'header is changed');
          return (TRUE);
        END IF;
      WHEN 'LINE' THEN
        -- Line Tax determining attributes
        d_progress := 20;
        SELECT unit_meas_lookup_code,
               unit_price
        INTO   l_uom,
               l_price
        FROM   po_lines_all
        WHERE  po_line_id =p_doc_level_id;

       IF nvl(l_uom,-99)    = nvl(p_uom,-99)   AND
          nvl(l_price,-99)  = nvl(p_price,-99)
        THEN
          PO_LOG.stmt(d_module_base,d_progress,'line is unchanged');
          return(FALSE);
        ELSE
          PO_LOG.stmt(d_module_base,d_progress,'line is changed');
          return (TRUE);
        END IF;

      WHEN 'SHIPMENT' THEN
        -- Shipment Tax determining attributes
        d_progress := 30;
        SELECT quantity,
               price_override, --<Bug 5647417>
               amount,
               ship_to_organization_id,
               ship_to_location_id,
               need_by_date
        INTO   l_qty,
               l_price_override, --<Bug 5647417>
               l_amt,
               l_ship_to_org,
               l_ship_to_loc,
               l_need_by_date
        FROM   po_line_locations_all
        WHERE  line_location_id = p_doc_level_id;

        IF nvl(l_qty ,-99)   =  nvl(p_qty ,-99)    AND
           --<Bug 5647417> Shipment level price is also tax determining
           -- attribute because it results in change of amount
           nvl(l_price_override ,-99)   =  nvl(p_price_override ,-99) AND
           nvl(l_amt ,-99)   =  nvl(p_amt ,-99)    AND
           nvl(l_ship_to_org ,-99)  = nvl(p_ship_to_org,-99)    AND
           nvl(l_ship_to_loc,-99) = nvl(p_ship_to_loc ,-99)     AND
           nvl(l_need_by_date ,sysdate) = nvl(p_need_by_date,sysdate)
        THEN
          PO_LOG.stmt(d_module_base,d_progress,'shipment is unchanged');
          return(FALSE);
        ELSE
          PO_LOG.stmt(d_module_base,d_progress,'shipment is changed');
          return (TRUE);
        END IF;

      WHEN 'DISTRIBUTION' THEN
        -- Distribution Level Tax determining attributes
        d_progress := 40;
        SELECT CODE_COMBINATION_ID,
               RECOVERY_RATE,
               PROJECT_ID,
               TASK_ID,
               AWARD_ID,
               EXPENDITURE_TYPE,
               EXPENDITURE_ORGANIZATION_ID,
               EXPENDITURE_ITEM_DATE,
               QUANTITY_ORDERED,
               AMOUNT_ORDERED
        INTO   l_ccid,
               l_tax_rec_rate,
               l_project,
               l_task ,
               l_award,
               l_exp_type,
               l_exp_org,
               l_exp_date,
               l_dist_quantity_ordered,
               l_dist_amount_ordered
        FROM   po_distributions_all
        WHERE  po_distribution_id =p_doc_level_id;

        IF  nvl(l_tax_rec_rate,-99) =  nvl(p_tax_rec_rate ,-99)  AND
            nvl(l_project,-99)    = nvl(p_project,-99)         AND
            nvl(l_task,-99)     = nvl(p_task,-99)            AND
            nvl(l_award,-99)     = nvl(p_award,-99)           AND
            nvl(l_exp_type,-99)   = nvl(p_exp_type,-99)        AND
            nvl(l_exp_org,-99)   = nvl(p_exp_org,-99)         AND
            nvl(l_exp_date,sysdate) = nvl(p_exp_date,sysdate)    AND
            nvl(l_ccid,-99)   = nvl(p_ccid,-99)   AND
            nvl(l_dist_quantity_ordered,-99)  = nvl(p_dist_quantity_ordered,-99) AND
            nvl(l_dist_amount_ordered ,-99)  = nvl(p_dist_amount_ordered,-99)
        THEN
          PO_LOG.stmt(d_module_base,d_progress,'distribution is unchanged');
          return(FALSE);
        ELSE
          PO_LOG.stmt(d_module_base,d_progress,'distribution is changed');
          return (TRUE);
        END IF;

    END CASE;

  ELSIF (p_doc_type = 'RELEASE') THEN
    CASE p_doc_level
      WHEN 'HEADER' THEN
        -- RELEASE Header Tax determining attributes
        d_progress := 50;
        SELECT currency_code,
               rate_type,
               rate_date,
               rate,
               fob_lookup_code,
               vendor_id,
               vendor_site_id
        INTO   l_trx_currency,
               l_rate_type,
               l_rate_date,
               l_rate,
               l_fob,
               l_vendor_id,
               l_vendor_site_id
        FROM   po_headers_all
        WHERE  po_header_id = p_doc_level_id;

       IF ((nvl(l_trx_currency,'-99') = nvl(p_trx_currency,'-99'))  AND
           (nvl(l_rate_type,'-99')    = nvl(p_rate_type,'-99'))     AND
           (nvl(l_rate_date,sysdate) = nvl(p_rate_date,sysdate)) AND
           (nvl(l_rate,99)         = nvl(p_rate,99))            AND
           (nvl(l_fob,99)          = nvl(p_fob,99))             AND
           (nvl(l_vendor_id,99)    = nvl(p_vendor_id,99))       AND
           (nvl(l_vendor_site_id,99) = nvl(p_vendor_site_id,99)) AND
           (nvl(l_bill_to_loc,-99) = nvl(p_bill_to_loc,-99)) ) --<ECO 5524555>
        THEN
          PO_LOG.stmt(d_module_base,d_progress,'release header is unchanged');
          return(FALSE);
        ELSE
          PO_LOG.stmt(d_module_base,d_progress,'release header is changed');
          return (TRUE);
        END IF;

    END CASE;

  END IF;
  d_progress := 60;
EXCEPTION
   WHEN OTHERS THEN
     IF (PO_LOG.d_exc) THEN
       PO_LOG.exc(d_module_base, d_progress, SQLCODE || SQLERRM);
     END IF;
     return(TRUE);

END any_tax_attributes_updated;



-----------------------------------------------------------------------------
--Start of Comments
--Name: log_header_tax_attributes
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
--  Logs attributes in table zx_trx_headers_all
--Parameters:
--IN:
--p_module_base
--  Unique identifier for module in the package
--p_progress
--  Measure of depth traversed in the procedure
--Notes:
--  Used by calculate_tax, calculate_tax_req and determine_recovery_po/rel/req
--  procedures. For use within this package only.
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE log_header_tax_attributes(p_module_base IN VARCHAR2,
                                    p_progress    IN NUMBER) IS
  d_module_base CONSTANT VARCHAR2(100) := p_module_base;
  d_progress NUMBER := p_progress;
  TYPE zx_headers_type IS TABLE OF ZX_TRX_HEADERS_GT%ROWTYPE;
  l_zx_headers_tbl zx_headers_type;
BEGIN
  PO_LOG.stmt(d_module_base,d_progress,'Contents of zx_trx_headers_gt:');

  SELECT *
  BULK COLLECT INTO l_zx_headers_tbl
  FROM zx_trx_headers_gt;

  FOR i IN 1..l_zx_headers_tbl.COUNT LOOP
    PO_LOG.stmt(d_module_base,d_progress,'  row '||i||':');
    PO_LOG.stmt(d_module_base,d_progress,'    internal_organization_id = '||l_zx_headers_tbl(i).internal_organization_id);
    PO_LOG.stmt(d_module_base,d_progress,'    application_id = '||l_zx_headers_tbl(i).application_id);
    PO_LOG.stmt(d_module_base,d_progress,'    entity_code = '||l_zx_headers_tbl(i).entity_code);
    PO_LOG.stmt(d_module_base,d_progress,'    event_class_code = '||l_zx_headers_tbl(i).event_class_code);
    PO_LOG.stmt(d_module_base,d_progress,'    event_type_code = '||l_zx_headers_tbl(i).event_type_code);
    PO_LOG.stmt(d_module_base,d_progress,'    trx_id = '||l_zx_headers_tbl(i).trx_id);
    PO_LOG.stmt(d_module_base,d_progress,'    trx_date = '||l_zx_headers_tbl(i).trx_date);
    PO_LOG.stmt(d_module_base,d_progress,'    trx_doc_revision = '||l_zx_headers_tbl(i).trx_doc_revision);
    PO_LOG.stmt(d_module_base,d_progress,'    ledger_id = '||l_zx_headers_tbl(i).ledger_id);
    PO_LOG.stmt(d_module_base,d_progress,'    trx_currency_code = '||l_zx_headers_tbl(i).trx_currency_code);
    PO_LOG.stmt(d_module_base,d_progress,'    currency_conversion_date = '||l_zx_headers_tbl(i).currency_conversion_date);
    PO_LOG.stmt(d_module_base,d_progress,'    currency_conversion_rate = '||l_zx_headers_tbl(i).currency_conversion_rate);
    PO_LOG.stmt(d_module_base,d_progress,'    currency_conversion_type = '||l_zx_headers_tbl(i).currency_conversion_type);
    PO_LOG.stmt(d_module_base,d_progress,'    minimum_accountable_unit = '||l_zx_headers_tbl(i).minimum_accountable_unit);
    PO_LOG.stmt(d_module_base,d_progress,'    precision = '||l_zx_headers_tbl(i).precision);
    PO_LOG.stmt(d_module_base,d_progress,'    legal_entity_id = '||l_zx_headers_tbl(i).legal_entity_id);
    PO_LOG.stmt(d_module_base,d_progress,'    rounding_ship_from_party_id = '||l_zx_headers_tbl(i).rounding_ship_from_party_id);
    PO_LOG.stmt(d_module_base,d_progress,'    default_taxation_country = '||l_zx_headers_tbl(i).default_taxation_country);
    PO_LOG.stmt(d_module_base,d_progress,'    quote_flag = '||l_zx_headers_tbl(i).quote_flag);
    PO_LOG.stmt(d_module_base,d_progress,'    trx_number = '||l_zx_headers_tbl(i).trx_number);
    PO_LOG.stmt(d_module_base,d_progress,'    trx_description = '||l_zx_headers_tbl(i).trx_description);
    PO_LOG.stmt(d_module_base,d_progress,'    trx_communicated_date = '||l_zx_headers_tbl(i).trx_communicated_date);
    PO_LOG.stmt(d_module_base,d_progress,'    document_sub_type = '||l_zx_headers_tbl(i).document_sub_type);
    PO_LOG.stmt(d_module_base,d_progress,'    provnl_tax_determination_date = '||l_zx_headers_tbl(i).provnl_tax_determination_date);
    PO_LOG.stmt(d_module_base,d_progress,'    rounding_bill_to_party_id = '||l_zx_headers_tbl(i).rounding_bill_to_party_id);
    PO_LOG.stmt(d_module_base,d_progress,'    icx_session_id = '||l_zx_headers_tbl(i).icx_session_id);
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    PO_LOG.stmt(d_module_base,d_progress,'Failure while writing log '||SQLCODE||SQLERRM);
END log_header_tax_attributes;



-----------------------------------------------------------------------------
--Start of Comments
--Name: log_line_tax_attributes
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
--  Logs attributes in table zx_transaction_lines_all
--Parameters:
--IN:
--p_module_base
--  Unique identifier for module in the package
--p_progress
--  Measure of depth traversed in the procedure
--Notes:
--  Used by calculate_tax, calculate_tax_req and determine_recovery_po/rel/req
--  procedures. For use within this package only.
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE log_line_tax_attributes(p_module_base IN VARCHAR2,
                                  p_progress    IN NUMBER) IS
  d_module_base CONSTANT VARCHAR2(100) := p_module_base;
  d_progress NUMBER := p_progress;
  TYPE zx_lines_type IS TABLE OF ZX_TRANSACTION_LINES_GT%ROWTYPE;
  l_zx_lines_tbl zx_lines_type;
BEGIN
  PO_LOG.stmt(d_module_base,d_progress,'Contents of zx_transaction_lines_gt:');

  SELECT *
  BULK COLLECT INTO l_zx_lines_tbl
  FROM zx_transaction_lines_gt;

  FOR i IN 1..l_zx_lines_tbl.COUNT LOOP
    PO_LOG.stmt(d_module_base,d_progress,'  row '||i||':');
    PO_LOG.stmt(d_module_base,d_progress,'    application_id = '||l_zx_lines_tbl(i).application_id);
    PO_LOG.stmt(d_module_base,d_progress,'    entity_code = '||l_zx_lines_tbl(i).entity_code);
    PO_LOG.stmt(d_module_base,d_progress,'    event_class_code = '||l_zx_lines_tbl(i).event_class_code);
    PO_LOG.stmt(d_module_base,d_progress,'    trx_id = '||l_zx_lines_tbl(i).trx_id);
    PO_LOG.stmt(d_module_base,d_progress,'    trx_level_type = '||l_zx_lines_tbl(i).trx_level_type);
    PO_LOG.stmt(d_module_base,d_progress,'    trx_line_id = '||l_zx_lines_tbl(i).trx_line_id);
    PO_LOG.stmt(d_module_base,d_progress,'    line_level_action = '||l_zx_lines_tbl(i).line_level_action);
    PO_LOG.stmt(d_module_base,d_progress,'    line_class = '||l_zx_lines_tbl(i).line_class);
    PO_LOG.stmt(d_module_base,d_progress,'    trx_line_type = '||l_zx_lines_tbl(i).trx_line_type);
    PO_LOG.stmt(d_module_base,d_progress,'    trx_line_date = '||l_zx_lines_tbl(i).trx_line_date);
    PO_LOG.stmt(d_module_base,d_progress,'    trx_business_category = '||l_zx_lines_tbl(i).trx_business_category);
    PO_LOG.stmt(d_module_base,d_progress,'    line_intended_use = '||l_zx_lines_tbl(i).line_intended_use);
    PO_LOG.stmt(d_module_base,d_progress,'    user_defined_fisc_class = '||l_zx_lines_tbl(i).user_defined_fisc_class);
    PO_LOG.stmt(d_module_base,d_progress,'    line_amt = '||l_zx_lines_tbl(i).line_amt);
    PO_LOG.stmt(d_module_base,d_progress,'    trx_line_quantity = '||l_zx_lines_tbl(i).trx_line_quantity);
    PO_LOG.stmt(d_module_base,d_progress,'    product_id = '||l_zx_lines_tbl(i).product_id);
    PO_LOG.stmt(d_module_base,d_progress,'    product_fisc_classification = '||l_zx_lines_tbl(i).product_fisc_classification);
    PO_LOG.stmt(d_module_base,d_progress,'    uom_code = '||l_zx_lines_tbl(i).uom_code);
    PO_LOG.stmt(d_module_base,d_progress,'    product_type = '||l_zx_lines_tbl(i).product_type);
    PO_LOG.stmt(d_module_base,d_progress,'    product_code = '||l_zx_lines_tbl(i).product_code);
    PO_LOG.stmt(d_module_base,d_progress,'    product_category = '||l_zx_lines_tbl(i).product_category);
    PO_LOG.stmt(d_module_base,d_progress,'    fob_point = '||l_zx_lines_tbl(i).fob_point);
    PO_LOG.stmt(d_module_base,d_progress,'    ship_from_party_id = '||l_zx_lines_tbl(i).ship_from_party_id);
    PO_LOG.stmt(d_module_base,d_progress,'    bill_from_party_id = '||l_zx_lines_tbl(i).bill_from_party_id);
    PO_LOG.stmt(d_module_base,d_progress,'    ship_from_party_site_id = '||l_zx_lines_tbl(i).ship_from_party_site_id);
    PO_LOG.stmt(d_module_base,d_progress,'    bill_from_party_site_id = '||l_zx_lines_tbl(i).bill_from_party_site_id);
    PO_LOG.stmt(d_module_base,d_progress,'    ship_to_location_id = '||l_zx_lines_tbl(i).ship_to_location_id);
    PO_LOG.stmt(d_module_base,d_progress,'    ship_from_location_id = '||l_zx_lines_tbl(i).ship_from_location_id);
    PO_LOG.stmt(d_module_base,d_progress,'    bill_to_location_id = '||l_zx_lines_tbl(i).bill_to_location_id);
    PO_LOG.stmt(d_module_base,d_progress,'    bill_from_location_id = '||l_zx_lines_tbl(i).bill_from_location_id); /* 8752470 */
    PO_LOG.stmt(d_module_base,d_progress,'    account_ccid = '||l_zx_lines_tbl(i).account_ccid);
    PO_LOG.stmt(d_module_base,d_progress,'    ref_doc_application_id = '||l_zx_lines_tbl(i).ref_doc_application_id);
    PO_LOG.stmt(d_module_base,d_progress,'    ref_doc_entity_code = '||l_zx_lines_tbl(i).ref_doc_entity_code);
    PO_LOG.stmt(d_module_base,d_progress,'    ref_doc_event_class_code = '||l_zx_lines_tbl(i).ref_doc_event_class_code);
    PO_LOG.stmt(d_module_base,d_progress,'    ref_doc_trx_id = '||l_zx_lines_tbl(i).ref_doc_trx_id);
    PO_LOG.stmt(d_module_base,d_progress,'    ref_doc_line_id = '||l_zx_lines_tbl(i).ref_doc_line_id);
    PO_LOG.stmt(d_module_base,d_progress,'    line_trx_user_key1 = '||l_zx_lines_tbl(i).line_trx_user_key1);
    PO_LOG.stmt(d_module_base,d_progress,'    line_trx_user_key2 = '||l_zx_lines_tbl(i).line_trx_user_key2);
    PO_LOG.stmt(d_module_base,d_progress,'    trx_line_number = '||l_zx_lines_tbl(i).trx_line_number);
    PO_LOG.stmt(d_module_base,d_progress,'    trx_line_description = '||l_zx_lines_tbl(i).trx_line_description);
    PO_LOG.stmt(d_module_base,d_progress,'    product_description = '||l_zx_lines_tbl(i).product_description);
    PO_LOG.stmt(d_module_base,d_progress,'    assessable_value = '||l_zx_lines_tbl(i).assessable_value);
    PO_LOG.stmt(d_module_base,d_progress,'    line_amt_includes_tax_flag = '||l_zx_lines_tbl(i).line_amt_includes_tax_flag);
    PO_LOG.stmt(d_module_base,d_progress,'    input_tax_classification_code = '||l_zx_lines_tbl(i).input_tax_classification_code);
    PO_LOG.stmt(d_module_base,d_progress,'    source_application_id = '||l_zx_lines_tbl(i).source_application_id);
    PO_LOG.stmt(d_module_base,d_progress,'    source_entity_code = '||l_zx_lines_tbl(i).source_entity_code);
    PO_LOG.stmt(d_module_base,d_progress,'    source_event_class_code = '||l_zx_lines_tbl(i).source_event_class_code);
    PO_LOG.stmt(d_module_base,d_progress,'    source_trx_id = '||l_zx_lines_tbl(i).source_trx_id);
    PO_LOG.stmt(d_module_base,d_progress,'    source_line_id = '||l_zx_lines_tbl(i).source_line_id);
    PO_LOG.stmt(d_module_base,d_progress,'    source_trx_level_type = '||l_zx_lines_tbl(i).source_trx_level_type);
    PO_LOG.stmt(d_module_base,d_progress,'    unit_price = '||l_zx_lines_tbl(i).unit_price);
    PO_LOG.stmt(d_module_base,d_progress,'    ref_doc_trx_level_type = '||l_zx_lines_tbl(i).ref_doc_trx_level_type);
    PO_LOG.stmt(d_module_base,d_progress,'    product_org_id = '||l_zx_lines_tbl(i).product_org_id);
    PO_LOG.stmt(d_module_base,d_progress,'    ship_to_party_id = '||l_zx_lines_tbl(i).ship_to_party_id);
    PO_LOG.stmt(d_module_base,d_progress,'    bill_to_party_id = '||l_zx_lines_tbl(i).bill_to_party_id);
    PO_LOG.stmt(d_module_base,d_progress,'    trx_line_currency_code = '||l_zx_lines_tbl(i).trx_line_currency_code);
    PO_LOG.stmt(d_module_base,d_progress,'    trx_line_currency_conv_date = '||l_zx_lines_tbl(i).trx_line_currency_conv_date);
    PO_LOG.stmt(d_module_base,d_progress,'    trx_line_currency_conv_rate = '||l_zx_lines_tbl(i).trx_line_currency_conv_rate);
    PO_LOG.stmt(d_module_base,d_progress,'    trx_line_currency_conv_type = '||l_zx_lines_tbl(i).trx_line_currency_conv_type);
    PO_LOG.stmt(d_module_base,d_progress,'    trx_line_mau = '||l_zx_lines_tbl(i).trx_line_mau);
    PO_LOG.stmt(d_module_base,d_progress,'    trx_line_precision = '||l_zx_lines_tbl(i).trx_line_precision);
    PO_LOG.stmt(d_module_base,d_progress,'    user_upd_det_factors_flag = '||l_zx_lines_tbl(i).user_upd_det_factors_flag);
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    PO_LOG.stmt(d_module_base,d_progress,'Failure while writing log '||SQLCODE||SQLERRM);
END log_line_tax_attributes;



-----------------------------------------------------------------------------
--Start of Comments
--Name: log_dist_tax_attributes
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
--  Logs attributes in table zx_itm_distributions_all
--Parameters:
--IN:
--p_module_base
--  Unique identifier for module in the package
--p_progress
--  Measure of depth traversed in the procedure
--Notes:
--  Used by calculate_tax, calculate_tax_req and determine_recovery_po/rel/req
--  procedures. For use within this package only.
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE log_dist_tax_attributes(p_module_base IN VARCHAR2,
                                  p_progress    IN NUMBER) IS
  d_module_base CONSTANT VARCHAR2(100) := p_module_base;
  d_progress NUMBER := p_progress;
  TYPE zx_dists_type IS TABLE OF ZX_ITM_DISTRIBUTIONS_GT%ROWTYPE;
  l_zx_dists_tbl zx_dists_type;
BEGIN
  PO_LOG.stmt(d_module_base,d_progress,'Contents of zx_itm_distributions_gt:');

  SELECT *
  BULK COLLECT INTO l_zx_dists_tbl
  FROM zx_itm_distributions_gt;

  FOR i IN 1..l_zx_dists_tbl.COUNT LOOP
    PO_LOG.stmt(d_module_base,d_progress,'  row '||i||':');
    PO_LOG.stmt(d_module_base,d_progress,'    application_id = '||l_zx_dists_tbl(i).application_id);
    PO_LOG.stmt(d_module_base,d_progress,'    entity_code = '||l_zx_dists_tbl(i).entity_code);
    PO_LOG.stmt(d_module_base,d_progress,'    event_class_code = '||l_zx_dists_tbl(i).event_class_code);
    PO_LOG.stmt(d_module_base,d_progress,'    trx_id = '||l_zx_dists_tbl(i).trx_id);
    PO_LOG.stmt(d_module_base,d_progress,'    trx_line_id = '||l_zx_dists_tbl(i).trx_line_id);
    PO_LOG.stmt(d_module_base,d_progress,'    trx_level_type = '||l_zx_dists_tbl(i).trx_level_type);
    PO_LOG.stmt(d_module_base,d_progress,'    trx_line_dist_id = '||l_zx_dists_tbl(i).trx_line_dist_id);
    PO_LOG.stmt(d_module_base,d_progress,'    dist_level_action = '||l_zx_dists_tbl(i).dist_level_action);
    PO_LOG.stmt(d_module_base,d_progress,'    trx_line_dist_date = '||l_zx_dists_tbl(i).trx_line_dist_date);
    PO_LOG.stmt(d_module_base,d_progress,'    item_dist_number = '||l_zx_dists_tbl(i).item_dist_number);
    PO_LOG.stmt(d_module_base,d_progress,'    task_id = '||l_zx_dists_tbl(i).task_id);
    PO_LOG.stmt(d_module_base,d_progress,'    award_id = '||l_zx_dists_tbl(i).award_id);
    PO_LOG.stmt(d_module_base,d_progress,'    project_id = '||l_zx_dists_tbl(i).project_id);
    PO_LOG.stmt(d_module_base,d_progress,'    expenditure_type = '||l_zx_dists_tbl(i).expenditure_type);
    PO_LOG.stmt(d_module_base,d_progress,'    expenditure_organization_id = '||l_zx_dists_tbl(i).expenditure_organization_id);
    PO_LOG.stmt(d_module_base,d_progress,'    expenditure_item_date = '||l_zx_dists_tbl(i).expenditure_item_date);
    PO_LOG.stmt(d_module_base,d_progress,'    trx_line_dist_amt = '||l_zx_dists_tbl(i).trx_line_dist_amt);
    PO_LOG.stmt(d_module_base,d_progress,'    trx_line_dist_qty = '||l_zx_dists_tbl(i).trx_line_dist_qty);
    PO_LOG.stmt(d_module_base,d_progress,'    trx_line_quantity = '||l_zx_dists_tbl(i).trx_line_quantity);
    PO_LOG.stmt(d_module_base,d_progress,'    account_ccid = '||l_zx_dists_tbl(i).account_ccid);
    PO_LOG.stmt(d_module_base,d_progress,'    currency_exchange_rate = '||l_zx_dists_tbl(i).currency_exchange_rate);
    PO_LOG.stmt(d_module_base,d_progress,'    overriding_recovery_rate = '||l_zx_dists_tbl(i).overriding_recovery_rate);
    PO_LOG.stmt(d_module_base,d_progress,'    dist_intended_use = '||l_zx_dists_tbl(i).dist_intended_use);
    PO_LOG.stmt(d_module_base,d_progress,'    historical_flag = '||l_zx_dists_tbl(i).historical_flag);
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    PO_LOG.stmt(d_module_base,d_progress,'Failure while writing log '||SQLCODE||SQLERRM);
END log_dist_tax_attributes;



-----------------------------------------------------------------------------
--Start of Comments
--Name: log_po_tauc
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
--  Logs tax_attribute_update_code values for the given list of po's
--Parameters:
--IN:
--p_module_base
--  Unique identifier for module in the package
--p_progress
--  Measure of depth traversed in the procedure
--p_po_header_id_tbl
--  List of po header id's to log for
--Notes:
--  1. Used by calculate_tax procedure. For use within this package only
--  2. Everything is not collected in bulk because requirement is to log data
--     in a structured format. In any case, this procedure is called only
--     statement logging is on
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE log_po_tauc(p_module_base      IN VARCHAR2,
                      p_progress         IN NUMBER,
                      p_po_header_id_tbl IN PO_TBL_NUMBER) IS
  d_module_base   CONSTANT VARCHAR2(100) := p_module_base;
  d_progress      NUMBER := p_progress;
  l_line_id_tbl   PO_TBL_NUMBER;
  l_ship_id_tbl   PO_TBL_NUMBER;
  l_dist_id_tbl   PO_TBL_NUMBER;
  l_header_tauc   PO_HEADERS_ALL.tax_attribute_update_code%TYPE;
  l_line_tauc_tbl PO_TBL_VARCHAR15;
  l_ship_tauc_tbl PO_TBL_VARCHAR15;
  l_dist_tauc_tbl PO_TBL_VARCHAR15;
BEGIN

  FOR i IN 1..p_po_header_id_tbl.COUNT LOOP

    SELECT ph.tax_attribute_update_code
    INTO l_header_tauc
    FROM po_headers_all ph
    WHERE ph.po_header_id = p_po_header_id_tbl(i);

    PO_LOG.stmt(d_module_base,d_progress,'  po_header_id = '||p_po_header_id_tbl(i)||':'||l_header_tauc);

    l_line_id_tbl := null; l_line_tauc_tbl := null;
    SELECT pl.po_line_id, pl.tax_attribute_update_code
    BULK COLLECT INTO l_line_id_tbl, l_line_tauc_tbl
    FROM po_lines_all pl
    WHERE pl.po_header_id = p_po_header_id_tbl(i);

    FOR j IN 1..l_line_id_tbl.COUNT LOOP
      PO_LOG.stmt(d_module_base,d_progress,'    po_line_id = '||l_line_id_tbl(j)||':'||l_line_tauc_tbl(j));

      l_ship_id_tbl := null; l_ship_tauc_tbl := null;
      SELECT pll.line_location_id, pll.tax_attribute_update_code
      BULK COLLECT INTO l_ship_id_tbl, l_ship_tauc_tbl
      FROM po_line_locations_all pll
      WHERE pll.po_line_id = l_line_id_tbl(j);

      FOR k IN 1..l_ship_id_tbl.COUNT LOOP
        PO_LOG.stmt(d_module_base,d_progress,'      line_location_id = '||l_ship_id_tbl(k)||':'||l_ship_tauc_tbl(k));

        l_dist_id_tbl := null; l_dist_tauc_tbl := null;
        SELECT pd.po_distribution_id, pd.tax_attribute_update_code
        BULK COLLECT INTO l_dist_id_tbl, l_dist_tauc_tbl
        FROM po_distributions_all pd
        WHERE pd.line_location_id = l_ship_id_tbl(k);

        FOR l IN 1..l_dist_id_tbl.COUNT LOOP
          PO_LOG.stmt(d_module_base,d_progress,'        po_distribution_id = '||l_dist_id_tbl(l)||':'||l_dist_tauc_tbl(l));
        END LOOP;

      END LOOP;

    END LOOP;

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    PO_LOG.stmt(d_module_base,d_progress,'Failure while writing log '||SQLCODE||SQLERRM);
END log_po_tauc;



-----------------------------------------------------------------------------
--Start of Comments
--Name: log_rel_tauc
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
--  Logs tax_attribute_update_code values for the given list of releaes
--Parameters:
--IN:
--p_module_base
--  Unique identifier for module in the package
--p_progress
--  Measure of depth traversed in the procedure
--p_po_release_id_tbl
--  List of po header id's to log for
--Notes:
--  1. Used by calculate_tax procedure. For use within this package only
--  2. Everything is not collected in bulk because requirement is to log data
--     in a structured format. In any case, this procedure is called only
--     statement logging is on
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE log_rel_tauc(p_module_base       IN VARCHAR2,
                       p_progress          IN NUMBER,
                       p_po_release_id_tbl IN PO_TBL_NUMBER) IS
  d_module_base   CONSTANT VARCHAR2(100) := p_module_base;
  d_progress      NUMBER := p_progress;
  l_ship_id_tbl   PO_TBL_NUMBER;
  l_dist_id_tbl   PO_TBL_NUMBER;
  l_header_tauc   PO_RELEASES_ALL.tax_attribute_update_code%TYPE;
  l_ship_tauc_tbl PO_TBL_VARCHAR15;
  l_dist_tauc_tbl PO_TBL_VARCHAR15;
BEGIN

  FOR i IN 1..p_po_release_id_tbl.COUNT LOOP

    SELECT pr.tax_attribute_update_code
    INTO l_header_tauc
    FROM po_releases_all pr
    WHERE pr.po_release_id = p_po_release_id_tbl(i);

    PO_LOG.stmt(d_module_base,d_progress,'  po_release_id = '||p_po_release_id_tbl(i)||':'||l_header_tauc);

    l_ship_id_tbl := null; l_ship_tauc_tbl := null;
    SELECT pll.line_location_id, pll.tax_attribute_update_code
    BULK COLLECT INTO l_ship_id_tbl, l_ship_tauc_tbl
    FROM po_line_locations_all pll
    WHERE pll.po_release_id = p_po_release_id_tbl(i);

    FOR j IN 1..l_ship_id_tbl.COUNT LOOP
      PO_LOG.stmt(d_module_base,d_progress,'      line_location_id = '||l_ship_id_tbl(j)||':'||l_ship_tauc_tbl(j));

      l_dist_id_tbl := null; l_dist_tauc_tbl := null;
      SELECT pd.po_distribution_id, pd.tax_attribute_update_code
      BULK COLLECT INTO l_dist_id_tbl, l_dist_tauc_tbl
      FROM po_distributions_all pd
      WHERE pd.line_location_id = l_ship_id_tbl(j);

      FOR k IN 1..l_dist_id_tbl.COUNT LOOP
        PO_LOG.stmt(d_module_base,d_progress,'        po_distribution_id = '||l_dist_id_tbl(k)||':'||l_dist_tauc_tbl(k));
      END LOOP;

    END LOOP;

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    PO_LOG.stmt(d_module_base,d_progress,'Failure while writing log '||SQLCODE||SQLERRM);
END log_rel_tauc;



-----------------------------------------------------------------------------
--Start of Comments
--Name: log_req_tauc
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
--  Logs tax_attribute_update_code values for the given requisition
--Parameters:
--IN:
--p_module_base
--  Unique identifier for module in the package
--p_progress
--  Measure of depth traversed in the procedure
--p_requisition_header_id
--  req header id to log for
--Notes:
--  Used by calculate_tax_requisition procedure. For use within this
--  package only
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE log_req_tauc(p_module_base           IN VARCHAR2,
                       p_progress              IN NUMBER,
                       p_requisition_header_id IN NUMBER) IS
  d_module_base   CONSTANT VARCHAR2(100) := p_module_base;
  d_progress      NUMBER := p_progress;
  l_line_id_tbl   PO_TBL_NUMBER;
  l_header_tauc   PO_REQUISITION_HEADERS_ALL.tax_attribute_update_code%TYPE;
  l_line_tauc_tbl PO_TBL_VARCHAR15;
BEGIN

  SELECT prh.tax_attribute_update_code
  INTO l_header_tauc
  FROM po_requisition_headers_all prh
  WHERE prh.requisition_header_id = p_requisition_header_id;

  PO_LOG.stmt(d_module_base,d_progress,'  requisition_header_id = '||p_requisition_header_id||':'||l_header_tauc);

  l_line_id_tbl := null; l_line_tauc_tbl := null;
  SELECT prl.requisition_line_id, prl.tax_attribute_update_code
  BULK COLLECT INTO l_line_id_tbl, l_line_tauc_tbl
  FROM po_requisition_lines_all prl
  WHERE prl.requisition_header_id = p_requisition_header_id;

  FOR i IN 1..l_line_id_tbl.COUNT LOOP
    PO_LOG.stmt(d_module_base,d_progress,'    requisition_line_id = '||l_line_id_tbl(i)||':'||l_line_tauc_tbl(i));
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    PO_LOG.stmt(d_module_base,d_progress,'Failure while writing log '||SQLCODE||SQLERRM);
END log_req_tauc;


-----------------------------------------------------------------------------
--Start of Comments
--Name: log_global_error_record
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
--  Logs global tax error record G_TAX_ERRORS_TBL
--Parameters:
--IN:
--p_module_base
--  Unique identifier for module in the package
--p_progress
--  Measure of depth traversed in the procedure
--Notes:
--  Used by calculate_tax and calculate_tax_requisition procedures.
--  For use within this package only
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE log_global_error_record(p_module_base           IN VARCHAR2,
                                  p_progress              IN NUMBER) IS
  d_module_base   CONSTANT VARCHAR2(100) := p_module_base;
  d_progress      NUMBER := p_progress;
BEGIN
  PO_LOG.stmt(d_module_base,d_progress,'Global tax error record:');
  FOR i in 1..G_TAX_ERRORS_TBL.error_level.COUNT LOOP
    PO_LOG.stmt(d_module_base,d_progress,'  error level '||G_TAX_ERRORS_TBL.error_level(i));
    PO_LOG.stmt(d_module_base,d_progress,'  '||G_TAX_ERRORS_TBL.document_type_code(i)||' '||
                                              G_TAX_ERRORS_TBL.document_num(i)||'(id '||
                                              G_TAX_ERRORS_TBL.document_id(i)||'), '||
                                     'Line '||G_TAX_ERRORS_TBL.line_num(i)||'(id '||
                                              G_TAX_ERRORS_TBL.line_id(i)||'), '||
                                 'Shipment '||G_TAX_ERRORS_TBL.shipment_num(i)||'(id '||
                                              G_TAX_ERRORS_TBL.line_location_id(i)||'), '||
                             'Distribution '||G_TAX_ERRORS_TBL.distribution_num(i)||'(id '||
                                              G_TAX_ERRORS_TBL.distribution_id(i)||')');
    PO_LOG.stmt(d_module_base,d_progress,'  '||G_TAX_ERRORS_TBL.message_text(i));
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    PO_LOG.exc(d_module_base,d_progress,'Failure while logging global error record '||SQLCODE||SQLERRM);
END log_global_error_record;


-----------------------------------------------------------------------------
--Start of Comments
--Name: cancel_tax_lines
--Pre-reqs:
--  ZX GT tables should be populated with required data to cancel tax lines
--Modifies:
--  None
--Locks:
--  None
--Function:
--  Cancels tax lines after corresponding PO shipment has been cancelled
--Parameters:
--IN:
--p_api_version
--  Standard API specification parameter
--p_init_msg_list
--  Standard API specification parameter
--p_commit
--  Standard API specification parameter
--p_validation_level
--  Standard API specification parameter
--OUT:
--x_return_status
--  Standard API specification parameter
--x_msg_count
--  Standard API specification parameter
--x_msg_data
--  Standard API specification parameter
--Notes:
--  Wrapper over ZX_API_PUB.calculate_tax for cancel. Called from pocca.lpc.
--  Introduced with Bug 4695557.
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE cancel_tax_lines(p_document_type  IN VARCHAR2,
                           p_document_id    IN NUMBER,
                           p_line_id        IN NUMBER,
                           p_shipment_id    IN NUMBER,
                           x_return_status  OUT NOCOPY VARCHAR2,
                           x_msg_count      OUT NOCOPY NUMBER,
                           x_msg_data       OUT NOCOPY VARCHAR2
) IS
  l_module_name CONSTANT VARCHAR2(100) := 'CANCEL_TAX_LINES';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(
                                            D_PACKAGE_BASE, l_module_name);
  d_progress NUMBER;
  l_org_id   PO_HEADERS_ALL.org_id%TYPE;
BEGIN

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module_base, 'p_document_id', p_document_id);
    PO_LOG.proc_begin(d_module_base, 'p_line_id', p_line_id);
    PO_LOG.proc_begin(d_module_base, 'p_shipment_id', p_shipment_id);
  END IF;

--Bug 16366878: Moved these from "IF p_document_type = PO_CONSTANTS_SV.PO" to here so
--that ZX transaction tables data is wiped out for all type of documents in this API call.

      initialize_zx_gt_tables(); -- Wipe ZX GT tables clean
      initialize_global_error_record();


  d_progress := 0;
  IF p_document_type = PO_CONSTANTS_SV.PO THEN
    d_progress := 10;
    IF p_shipment_id <> 0 THEN
      d_progress := 20;

      /* bug 14350589 */
--Bug 16366878: Moved this code outside this IF so that its handled for all type of docs
            /* bug 14350589 */

      INSERT INTO zx_trx_headers_gt
      (
        internal_organization_id,
        application_id,
        entity_code,
        event_class_code,
        event_type_code,
        trx_id,
        trx_date,
        legal_entity_id,
        rounding_ship_from_party_id
      )
      SELECT
        ph.org_id,
        PO_CONSTANTS_SV.APPLICATION_ID,
        PO_CONSTANTS_SV.PO_ENTITY_CODE,
        PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE,
        PO_CONSTANTS_SV.PO_ADJUSTED,
        ph.po_header_id,
        sysdate, -- dummy value
        PO_CORE_S.get_default_legal_entity_id(ph.org_id),
        (SELECT party_id FROM po_vendors --rounding_ship_from_party_id
         WHERE vendor_id=ph.vendor_id)
      FROM po_headers_all ph
      WHERE ph.po_header_id = p_document_id;

      d_progress := 30;
      INSERT INTO zx_transaction_lines_gt
      (
        application_id,
        entity_code,
        event_class_code,
        trx_id,
        trx_level_type,
        trx_line_id,
        line_level_action,
        line_amt_includes_tax_flag,
        line_amt
      )
      VALUES
      (
        PO_CONSTANTS_SV.APPLICATION_ID,
        PO_CONSTANTS_SV.PO_ENTITY_CODE,
        PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE,
        p_document_id,
        PO_CONSTANTS_SV.PO_TRX_LEVEL_TYPE,
        p_shipment_id,
        'CANCEL',
        'N', -- dummy value
        0 -- dummy value
      );

      d_progress := 40;
      log_header_tax_attributes(d_module_base,d_progress);
      log_line_tax_attributes(d_module_base,d_progress);

      d_progress := 50;
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module_base,d_progress,'Before Calling ZX_API_PUB.calculate_tax');
      END IF;

      ZX_API_PUB.calculate_tax(
        p_api_version           =>   1.0,
        p_init_msg_list         =>   FND_API.G_TRUE,
        p_commit                =>   FND_API.G_FALSE,
        p_validation_level      =>   FND_API.G_VALID_LEVEL_FULL,
        x_return_status         =>   x_return_status,
        x_msg_count             =>   x_msg_count,
        x_msg_data              =>   x_msg_data);

      d_progress := 60;
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module_base,d_progress,'After Calling ZX_API_PUB.calculate_tax');
        PO_LOG.stmt(d_module_base,d_progress,'x_return_status', x_return_status);
        PO_LOG.stmt(d_module_base,d_progress,'x_msg_count', x_msg_count);
        PO_LOG.stmt(d_module_base,d_progress,'x_msg_data', x_msg_data);
      END IF;

    ELSIF p_line_id <> 0 THEN
      -- Partial document cancel. Populate eTax GT tables and call calculate_tax
      d_progress := 70;
      INSERT INTO zx_trx_headers_gt
      (
        internal_organization_id,
        application_id,
        entity_code,
        event_class_code,
        event_type_code,
        trx_id,
        trx_date,
        legal_entity_id,
        rounding_ship_from_party_id
      )
      SELECT
        ph.org_id,
        PO_CONSTANTS_SV.APPLICATION_ID,
        PO_CONSTANTS_SV.PO_ENTITY_CODE,
        PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE,
        PO_CONSTANTS_SV.PO_ADJUSTED,
        ph.po_header_id,
        sysdate, -- dummy value
        PO_CORE_S.get_default_legal_entity_id(ph.org_id),
        (SELECT party_id FROM po_vendors --rounding_ship_from_party_id
         WHERE vendor_id=ph.vendor_id)
      FROM po_headers_all ph
      WHERE ph.po_header_id = p_document_id;

      d_progress := 80;
      INSERT INTO zx_transaction_lines_gt
      (
        application_id,
        entity_code,
        event_class_code,
        trx_id,
        trx_level_type,
        trx_line_id,
        line_level_action,
        line_amt_includes_tax_flag,
        line_amt
      )
      SELECT
        PO_CONSTANTS_SV.APPLICATION_ID,
        PO_CONSTANTS_SV.PO_ENTITY_CODE,
        PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE,
        pll.po_header_id,
        PO_CONSTANTS_SV.PO_TRX_LEVEL_TYPE,
        pll.line_location_id,
        'CANCEL', --line_level_action
        'N', -- dummy value
         0 -- dummy value
      FROM po_line_locations_all pll
      WHERE pll.po_line_id = p_line_id;

      d_progress := 90;
      log_header_tax_attributes(d_module_base,d_progress);
      log_line_tax_attributes(d_module_base,d_progress);

      d_progress := 100;
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module_base,d_progress,'Before Calling ZX_API_PUB.calculate_tax');
      END IF;

      ZX_API_PUB.calculate_tax(
        p_api_version           =>   1.0,
        p_init_msg_list         =>   FND_API.G_TRUE,
        p_commit                =>   FND_API.G_FALSE,
        p_validation_level      =>   FND_API.G_VALID_LEVEL_FULL,
        x_return_status         =>   x_return_status,
        x_msg_count             =>   x_msg_count,
        x_msg_data              =>   x_msg_data);

      d_progress := 110;
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module_base,d_progress,'After Calling ZX_API_PUB.calculate_tax');
        PO_LOG.stmt(d_module_base,d_progress,'x_return_status', x_return_status);
        PO_LOG.stmt(d_module_base,d_progress,'x_msg_count', x_msg_count);
        PO_LOG.stmt(d_module_base,d_progress,'x_msg_data', x_msg_data);
      END IF;
    ELSIF p_document_id <> 0 THEN
      -- Complete document cancel. Call global_document_update API
      -- in Cancel mode
      d_progress := 120;
      SELECT ph.org_id
      INTO l_org_id
      FROM po_headers_all ph
      WHERE ph.po_header_id = p_document_id;

      d_progress := 130;
      IF (PO_LOG.d_stmt) THEN
         PO_LOG.stmt(d_module_base,d_progress,'l_org_id', l_org_id);
      END IF;

      d_progress := 140;
      PO_TAX_INTERFACE_PVT.global_document_update(
        p_api_version       =>  1.0,
        p_init_msg_list     =>  FND_API.G_FALSE,
        p_commit            =>  FND_API.G_FALSE,
        p_validation_level  =>  FND_API.G_VALID_LEVEL_FULL,
        x_return_status     =>  x_return_status,
        x_msg_count         =>  x_msg_count,
        x_msg_data          =>  x_msg_data,
        p_org_id            =>  l_org_id,
        p_document_type     =>  PO_CONSTANTS_SV.PO,
        p_document_id       =>  p_document_id,
        p_event_type_code   =>  PO_CONSTANTS_SV.PO_CANCELLED);

      d_progress := 150;
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module_base,d_progress,'After Calling PO_TAX_INTERFACE_PVT.global_document_update');
        PO_LOG.stmt(d_module_base,d_progress,'x_return_status', x_return_status);
        PO_LOG.stmt(d_module_base,d_progress,'x_msg_count', x_msg_count);
        PO_LOG.stmt(d_module_base,d_progress,'x_msg_data', x_msg_data);
      END IF;
    END IF; --IF p_shipment_id IS NOT NULL
  ELSIF p_document_type = PO_CONSTANTS_SV.RELEASE THEN
    d_progress := 160;
    IF p_shipment_id <> 0 THEN
      d_progress := 170;
      INSERT INTO zx_trx_headers_gt
      (
        internal_organization_id,
        application_id,
        entity_code,
        event_class_code,
        event_type_code,
        trx_id,
        trx_date,
        legal_entity_id,
        rounding_ship_from_party_id
      )
      SELECT
        pr.org_id, -- dummy value
        PO_CONSTANTS_SV.APPLICATION_ID,
        PO_CONSTANTS_SV.REL_ENTITY_CODE,
        PO_CONSTANTS_SV.REL_EVENT_CLASS_CODE,
        PO_CONSTANTS_SV.REL_ADJUSTED,
        pr.po_release_id,
        sysdate, -- dummy value
        PO_CORE_S.get_default_legal_entity_id(pr.org_id),
        (SELECT party_id FROM po_vendors --rounding_ship_from_party_id
         WHERE vendor_id=ph.vendor_id)
      FROM po_releases_all pr, po_headers_all ph
      WHERE pr.po_release_id = p_document_id
      AND pr.po_header_id = ph.po_header_id;

      d_progress := 180;
      INSERT INTO zx_transaction_lines_gt
      (
        application_id,
        entity_code,
        event_class_code,
        trx_id,
        trx_level_type,
        trx_line_id,
        line_level_action,
        line_amt_includes_tax_flag,
        line_amt
      )
      VALUES
      (
        PO_CONSTANTS_SV.APPLICATION_ID,
        PO_CONSTANTS_SV.REL_ENTITY_CODE,
        PO_CONSTANTS_SV.REL_EVENT_CLASS_CODE,
        p_document_id,
        PO_CONSTANTS_SV.REL_TRX_LEVEL_TYPE,
        p_shipment_id,
        'CANCEL',
        'N', -- dummy value
        0 -- dummy value
      );

      d_progress := 190;
      log_header_tax_attributes(d_module_base,d_progress);
      log_line_tax_attributes(d_module_base,d_progress);

      d_progress := 200;
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module_base,d_progress,'Before Calling ZX_API_PUB.calculate_tax');
      END IF;

      ZX_API_PUB.calculate_tax(
        p_api_version           =>   1.0,
        p_init_msg_list         =>   FND_API.G_TRUE,
        p_commit                =>   FND_API.G_FALSE,
        p_validation_level      =>   FND_API.G_VALID_LEVEL_FULL,
        x_return_status         =>   x_return_status,
        x_msg_count             =>   x_msg_count,
        x_msg_data              =>   x_msg_data);

      d_progress := 210;
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module_base,d_progress,'After Calling ZX_API_PUB.calculate_tax');
        PO_LOG.stmt(d_module_base,d_progress,'x_return_status', x_return_status);
        PO_LOG.stmt(d_module_base,d_progress,'x_msg_count', x_msg_count);
        PO_LOG.stmt(d_module_base,d_progress,'x_msg_data', x_msg_data);
      END IF;

    ELSIF p_document_id <> 0 THEN
      -- Complete document cancel. Call global_document_update API
      -- in Cancel mode
      d_progress := 220;
      SELECT pr.org_id
      INTO l_org_id
      FROM po_releases_all pr
      WHERE pr.po_release_id = p_document_id;

      d_progress := 230;
      IF (PO_LOG.d_stmt) THEN
         PO_LOG.stmt(d_module_base,d_progress,'l_org_id', l_org_id);
      END IF;

      d_progress := 240;
      PO_TAX_INTERFACE_PVT.global_document_update(
        p_api_version       =>  1.0,
        p_init_msg_list     =>  FND_API.G_FALSE,
        p_commit            =>  FND_API.G_FALSE,
        p_validation_level  =>  FND_API.G_VALID_LEVEL_FULL,
        x_return_status     =>  x_return_status,
        x_msg_count         =>  x_msg_count,
        x_msg_data          =>  x_msg_data,
        p_org_id            =>  l_org_id,
        p_document_type     =>  PO_CONSTANTS_SV.RELEASE,
        p_document_id       =>  p_document_id,
        p_event_type_code   =>  PO_CONSTANTS_SV.REL_CANCELLED);

      d_progress := 250;
      IF (PO_LOG.d_stmt) THEN
         PO_LOG.stmt(d_module_base,d_progress,'After Calling PO_TAX_INTERFACE_PVT.global_document_update');
         PO_LOG.stmt(d_module_base,d_progress,'x_return_status', x_return_status);
         PO_LOG.stmt(d_module_base,d_progress,'x_msg_count', x_msg_count);
         PO_LOG.stmt(d_module_base,d_progress,'x_msg_data', x_msg_data);
      END IF;

    END IF; --IF p_shipment_id IS NOT NULL
  END IF; --IF p_document_type = PO_CONSTANTS_SV.PO

  d_progress := 260;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module_base);
    PO_LOG.proc_end(d_module_base, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module_base, 'x_msg_count', x_msg_count);
    PO_LOG.proc_end(d_module_base, 'x_msg_data', x_msg_data);
  END IF;

  d_progress := 30;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module_base, d_progress, 'Unhandled exception in procedure cancel_tax_lines');
      PO_LOG.proc_end(d_module_base, 'x_return_status', x_return_status);
      PO_LOG.proc_end(d_module_base, 'x_msg_count', x_msg_count);
      PO_LOG.proc_end(d_module_base, 'x_msg_data', x_msg_data);
    END IF;
END cancel_tax_lines;


-----------------------------------------------------------------------------
--Start of Comments
--Name: global_document_update
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
--  Wrapper over Etax API ZX_API_PUB.global_document_update
--Parameters:
--IN:
--p_api_version
--  Standard API specification parameter
--p_init_msg_list
--  Standard API specification parameter
--p_commit
--  Standard API specification parameter
--p_validation_level
--  Standard API specification parameter
--p_org_id
--  organization id on the document
--p_document_type
--  'PO' or 'RELEASE'
--p_document_id
--  po_header_id or po_release_id of the document
--p_event_type_code
--  document level action code taken from PO_CONSTANTS_SV
--OUT:
--x_return_status
--  Standard API specification parameter
--x_msg_count
--  Standard API specification parameter
--x_msg_data
--  Standard API specification parameter
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE global_document_update(p_api_version      IN  NUMBER,
                                 p_init_msg_list    IN  VARCHAR2,
                                 p_commit           IN  VARCHAR2,
                                 p_validation_level IN  NUMBER,
                                 x_return_status    OUT NOCOPY VARCHAR2,
                                 x_msg_count        OUT NOCOPY NUMBER,
                                 x_msg_data         OUT NOCOPY VARCHAR2,
                                 p_org_id           IN  NUMBER,
                                 p_document_type    IN  VARCHAR2,
                                 p_document_id      IN  NUMBER,
                                 p_event_type_code  IN  VARCHAR2
) IS
  l_module_name CONSTANT VARCHAR2(100) := 'GLOBAL_DOCUMENT_UPDATE';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(
                                            D_PACKAGE_BASE, l_module_name);
  d_progress NUMBER;
  l_trx_rec  ZX_API_PUB.transaction_rec_type;
BEGIN
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'p_api_version', p_api_version);
    PO_LOG.proc_begin(d_module_base, 'p_init_msg_list', p_init_msg_list);
    PO_LOG.proc_begin(d_module_base, 'p_commit', p_commit);
    PO_LOG.proc_begin(d_module_base, 'p_validation_level', p_validation_level);
    PO_LOG.proc_begin(d_module_base, 'p_org_id', p_org_id);
    PO_LOG.proc_begin(d_module_base, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module_base, 'p_document_id', p_document_id);
    PO_LOG.proc_begin(d_module_base, 'p_event_type_code', p_event_type_code);
  END IF;

  d_progress := 0;
  IF p_document_type = PO_CONSTANTS_SV.PO THEN
    l_trx_rec.entity_code      := PO_CONSTANTS_SV.PO_ENTITY_CODE;
    l_trx_rec.event_class_code := PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE;
  ELSIF p_document_type = PO_CONSTANTS_SV.RELEASE THEN
    l_trx_rec.entity_code      := PO_CONSTANTS_SV.REL_ENTITY_CODE;
    l_trx_rec.event_class_code := PO_CONSTANTS_SV.REL_EVENT_CLASS_CODE;
  END IF;

  d_progress := 10;
  l_trx_rec.application_id           := PO_CONSTANTS_SV.APPLICATION_ID;
  l_trx_rec.internal_organization_id := p_org_id;
  l_trx_rec.event_type_code          := p_event_type_code;
  l_trx_rec.trx_id                   := p_document_id;
  l_trx_rec.application_doc_status   := null;

  d_progress := 20;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module_base,d_progress,'l_trx_rec.application_id', l_trx_rec.application_id);
    PO_LOG.stmt(d_module_base,d_progress,'l_trx_rec.entity_code', l_trx_rec.entity_code);
    PO_LOG.stmt(d_module_base,d_progress,'l_trx_rec.event_class_code', l_trx_rec.event_class_code);
    PO_LOG.stmt(d_module_base,d_progress,'l_trx_rec.internal_organization_id', l_trx_rec.internal_organization_id);
    PO_LOG.stmt(d_module_base,d_progress,'l_trx_rec.event_type_code', l_trx_rec.event_type_code);
    PO_LOG.stmt(d_module_base,d_progress,'l_trx_rec.trx_id', l_trx_rec.trx_id);
    PO_LOG.stmt(d_module_base,d_progress,'l_trx_rec.application_doc_status', l_trx_rec.application_doc_status);
    PO_LOG.stmt(d_module_base,d_progress,'Before Calling ZX_API_PUB.global_document_update');
  END IF;

  d_progress := 30;
  ZX_API_PUB.global_document_update(
    p_api_version         =>  p_api_version,
    p_init_msg_list       =>  p_init_msg_list,
    p_commit              =>  p_commit,
    p_validation_level    =>  p_validation_level,
    x_return_status       =>  x_return_status,
    x_msg_count           =>  x_msg_count,
    x_msg_data            =>  x_msg_data,
    p_transaction_rec     =>  l_trx_rec);

  d_progress := 40;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module_base);
    PO_LOG.proc_end(d_module_base, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module_base, 'x_msg_count', x_msg_count);
    PO_LOG.proc_end(d_module_base, 'x_msg_data', x_msg_data);
  END IF;

  d_progress := 50;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module_base, d_progress, 'Unhandled exception in procedure global_document_update');
      PO_LOG.proc_end(d_module_base, 'x_return_status', x_return_status);
      PO_LOG.proc_end(d_module_base, 'x_msg_count', x_msg_count);
      PO_LOG.proc_end(d_module_base, 'x_msg_data', x_msg_data);
    END IF;
END global_document_update;


-----------------------------------------------------------------------------
--Start of Comments
--Name: unapprove_doc_header
--Pre-reqs:
--  None
--Modifies:
--  PO_HEADERS_ALL.authorization_status
--  PO_HEADERS_ALL.approved_flag
--  PO_RELEASES_ALL.authorization_status
--  PO_RELEASES_ALL.approved_flag
--Locks:
--  PO_HEADERS_ALL
--  PO_RELEASES_ALL
--Function:
--  Unapprove the header for the given document
--Parameters:
--IN:
--p_document_id
--  Unique identifier for the document header that is to be unapproved
--p_document_type
--  Document Type (PO or RELEASE) for the document that is to be unapproved
--OUT:
--x_return_status
--  Standard API specification parameter
--  Can hold one of the following values:
--    FND_API.G_RET_STS_SUCCESS (='S')
--    FND_API.G_RET_STS_ERROR (='E')
--    FND_API.G_RET_STS_UNEXP_ERROR (='U')
--Notes:
--  Called from ManageTaxSvrCmd when the user changes any Additional Tax
--  Attribute on the Additional Tax Information page and presses Apply
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE unapprove_doc_header(p_document_id   IN         NUMBER,
                               p_document_type IN         VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2
) IS
  l_module_name CONSTANT VARCHAR2(100) := 'UNAPPROVE_DOC_HEADER';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(
                                            D_PACKAGE_BASE, l_module_name);
  d_progress NUMBER;
  l_authorization_status PO_HEADERS_ALL.authorization_status%TYPE;
BEGIN

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'p_document_id', p_document_id);
    PO_LOG.proc_begin(d_module_base, 'p_document_type', p_document_type);
  END IF;

  d_progress := 0;
  -- By default return status is SUCCESS if no exception occurs
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  d_progress := 10;
  IF p_document_type = PO_CONSTANTS_SV.PO THEN
    SELECT ph.authorization_status
    INTO l_authorization_status
    FROM po_headers_all ph
    WHERE ph.po_header_id = p_document_id;
  ELSIF p_document_type = PO_CONSTANTS_SV.RELEASE THEN
    SELECT pr.authorization_status
    INTO l_authorization_status
    FROM po_releases_all pr
    WHERE pr.po_release_id = p_document_id;
  END IF;

  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_module_base,d_progress,'l_authorization_status='||l_authorization_status);
  END IF;

  IF l_authorization_status = PO_CONSTANTS_SV.PRE_APPROVED THEN

    d_progress := 20;
    IF p_document_type = PO_CONSTANTS_SV.PO THEN
      UPDATE po_headers_all ph
      SET ph.authorization_status = PO_CONSTANTS_SV.IN_PROCESS,
          ph.approved_flag = 'N'
      WHERE ph.po_header_id = p_document_id;
    ELSIF p_document_type = PO_CONSTANTS_SV.RELEASE THEN
      UPDATE po_releases_all pr
      SET pr.authorization_status = PO_CONSTANTS_SV.IN_PROCESS,
          pr.approved_flag = 'N'
      WHERE pr.po_release_id = p_document_id;
    END IF;

  ELSIF l_authorization_status = PO_CONSTANTS_SV.APPROVED THEN

    d_progress := 30;
    IF p_document_type = PO_CONSTANTS_SV.PO THEN
      UPDATE po_headers_all ph
      SET ph.authorization_status = PO_CONSTANTS_SV.REQUIRES_REAPPROVAL,
          ph.approved_flag = 'R'
      WHERE ph.po_header_id = p_document_id;
    ELSIF p_document_type = PO_CONSTANTS_SV.RELEASE THEN
      UPDATE po_releases_all pr
      SET pr.authorization_status = PO_CONSTANTS_SV.REQUIRES_REAPPROVAL,
          pr.approved_flag = 'R'
      WHERE pr.po_release_id = p_document_id;
    END IF;

  END IF;

  d_progress := 40;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module_base);
    PO_LOG.proc_end(d_module_base, 'x_return_status', x_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module_base, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module_base, 'x_return_status', x_return_status);
    END IF;
END unapprove_doc_header;


-----------------------------------------------------------------------------
--Start of Comments
--Name: unapprove_schedules
--Pre-reqs:
--  None
--Modifies:
--  PO_LINE_LOCATIONS_ALL.approved_flag
--Locks:
--  PO_LINE_LOCATIONS_ALL
--Function:
--  Unapprove the given schedules if they are approved
--Parameters:
--IN:
--p_line_location_id_tbl
--  List of schedule ids that were modified in the Additional Tax Information
--  page
--OUT:
--x_return_status
--  Standard API specification parameter
--  Can hold one of the following values:
--    FND_API.G_RET_STS_SUCCESS (='S')
--    FND_API.G_RET_STS_ERROR (='E')
--    FND_API.G_RET_STS_UNEXP_ERROR (='U')
--Notes:
--  Called from ManageTaxSvrCmd when the user changes any schedule level
--  Additional Tax Attribute on the Additional Tax Information page and
--  presses Apply
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE unapprove_schedules(p_line_location_id_tbl  IN PO_TBL_NUMBER,
                              x_return_status OUT NOCOPY VARCHAR2
) IS
  l_module_name CONSTANT VARCHAR2(100) := 'UNAPPROVE_SCHEDULES';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(
                                            D_PACKAGE_BASE, l_module_name);
  d_progress NUMBER;
BEGIN

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'p_line_location_id_tbl', p_line_location_id_tbl);
  END IF;

  d_progress := 0;
  -- By default return status is SUCCESS if no exception occurs
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Unapprove line locations that are approved
  d_progress := 10;
  FORALL i IN 1..p_line_location_id_tbl.COUNT
    UPDATE po_line_locations_all pll
    SET pll.approved_flag = 'R'
    WHERE pll.line_location_id = p_line_location_id_tbl(i)
    AND pll.approved_flag = 'Y';

  d_progress := 20;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module_base);
    PO_LOG.proc_end(d_module_base, 'x_return_status', x_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module_base, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module_base, 'x_return_status', x_return_status);
    END IF;
END unapprove_schedules;

-- BUG# 18641338 fix starts
-----------------------------------------------------------------------------
--Start of Comments
--Name: log_sync_trx_records
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
--  Logs p_sync_trx_rec & p_sync_trx_lines_tbl records values
--Parameters:
--IN:
--p_module_base
--  Unique identifier for module in the package
--p_progress
--  Measure of depth traversed in the procedure
--p_sync_trx_rec
--  print p_sync_trx_rec record content
--p_sync_trx_lines_tbl
--  print p_sync_trx_lines_tbl record content
--Notes:
--  1. Used by update_non_tax_det_attrs_only procedure. For use within this package only
--  2. Everything is not collected in bulk because requirement is to log data
--     in a structured format. In any case, this procedure is called only when
--     statement logging is on
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE log_sync_trx_records (p_module_base        IN VARCHAR2,
                                p_progress           IN NUMBER,
                                p_sync_trx_rec       IN ZX_API_PUB.sync_trx_rec_type,
                                p_sync_trx_lines_tbl IN ZX_API_PUB.sync_trx_lines_tbl_type%type)
IS
  d_module_base           CONSTANT VARCHAR2(100) := p_module_base;
  d_progress              NUMBER := p_progress;
  l_sync_trx_rec          ZX_API_PUB.sync_trx_rec_type := p_sync_trx_rec;
  l_sync_trx_lines_tbl    ZX_API_PUB.sync_trx_lines_tbl_type%type := p_sync_trx_lines_tbl;
BEGIN
    --Logging of l_sync_trx_rec record begins
    PO_LOG.stmt(d_module_base,d_progress,' l_sync_trx_rec.APPLICATION_ID = '||l_sync_trx_rec.APPLICATION_ID);
    PO_LOG.stmt(d_module_base,d_progress,' l_sync_trx_rec.ENTITY_CODE = '||l_sync_trx_rec.ENTITY_CODE);
    PO_LOG.stmt(d_module_base,d_progress,' l_sync_trx_rec.EVENT_CLASS_CODE = '||l_sync_trx_rec.EVENT_CLASS_CODE);
    PO_LOG.stmt(d_module_base,d_progress,' l_sync_trx_rec.EVENT_TYPE_CODE = '||l_sync_trx_rec.EVENT_TYPE_CODE);
    PO_LOG.stmt(d_module_base,d_progress,' l_sync_trx_rec.TRX_ID = '||l_sync_trx_rec.TRX_ID);
    PO_LOG.stmt(d_module_base,d_progress,' l_sync_trx_rec.TRX_NUMBER = '||l_sync_trx_rec.TRX_NUMBER);
    PO_LOG.stmt(d_module_base,d_progress,' l_sync_trx_rec.TRX_DESCRIPTION = '||l_sync_trx_rec.TRX_DESCRIPTION);
    PO_LOG.stmt(d_module_base,d_progress,' l_sync_trx_rec.TRX_COMMUNICATED_DATE = '||l_sync_trx_rec.TRX_COMMUNICATED_DATE);
    PO_LOG.stmt(d_module_base,d_progress,' l_sync_trx_rec.BATCH_SOURCE_ID = '||l_sync_trx_rec.BATCH_SOURCE_ID);
    PO_LOG.stmt(d_module_base,d_progress,' l_sync_trx_rec.BATCH_SOURCE_NAME = '||l_sync_trx_rec.BATCH_SOURCE_NAME);
    PO_LOG.stmt(d_module_base,d_progress,' l_sync_trx_rec.DOC_SEQ_ID = '||l_sync_trx_rec.DOC_SEQ_ID);
    PO_LOG.stmt(d_module_base,d_progress,' l_sync_trx_rec.DOC_SEQ_NAME = '||l_sync_trx_rec.DOC_SEQ_NAME);
    PO_LOG.stmt(d_module_base,d_progress,' l_sync_trx_rec.DOC_SEQ_VALUE = '||l_sync_trx_rec.DOC_SEQ_VALUE);
    PO_LOG.stmt(d_module_base,d_progress,' l_sync_trx_rec.TRX_DUE_DATE = '||l_sync_trx_rec.TRX_DUE_DATE);
    PO_LOG.stmt(d_module_base,d_progress,' l_sync_trx_rec.TRX_TYPE_DESCRIPTION = '||l_sync_trx_rec.TRX_TYPE_DESCRIPTION);
    PO_LOG.stmt(d_module_base,d_progress,' l_sync_trx_rec.SUPPLIER_TAX_INVOICE_NUMBER = '||l_sync_trx_rec.SUPPLIER_TAX_INVOICE_NUMBER);
    PO_LOG.stmt(d_module_base,d_progress,' l_sync_trx_rec.SUPPLIER_TAX_INVOICE_DATE = '||l_sync_trx_rec.SUPPLIER_TAX_INVOICE_DATE);
    PO_LOG.stmt(d_module_base,d_progress,' l_sync_trx_rec.SUPPLIER_EXCHANGE_RATE = '||l_sync_trx_rec.SUPPLIER_EXCHANGE_RATE);
    PO_LOG.stmt(d_module_base,d_progress,' l_sync_trx_rec.TAX_INVOICE_DATE = '||l_sync_trx_rec.TAX_INVOICE_DATE);
    PO_LOG.stmt(d_module_base,d_progress,' l_sync_trx_rec.TAX_INVOICE_NUMBER = '||l_sync_trx_rec.TAX_INVOICE_NUMBER);
    PO_LOG.stmt(d_module_base,d_progress,' l_sync_trx_rec.PORT_OF_ENTRY_CODE = '||l_sync_trx_rec.PORT_OF_ENTRY_CODE);
    PO_LOG.stmt(d_module_base,d_progress,' l_sync_trx_rec.APPLICATION_DOC_STATUS = '||l_sync_trx_rec.APPLICATION_DOC_STATUS);
    --Logging of l_sync_trx_lines_tbl record begins
    FOR i IN 1..NVL(l_sync_trx_lines_tbl.APPLICATION_ID.LAST,-99)
     LOOP
        PO_LOG.stmt(d_module_base,d_progress,' l_sync_trx_lines_tbl.APPLICATION_ID = '||l_sync_trx_lines_tbl.APPLICATION_ID(i));
        PO_LOG.stmt(d_module_base,d_progress,' l_sync_trx_lines_tbl.ENTITY_CODE = '||l_sync_trx_lines_tbl.ENTITY_CODE(i));
        PO_LOG.stmt(d_module_base,d_progress,' l_sync_trx_lines_tbl.EVENT_CLASS_CODE = '||l_sync_trx_lines_tbl.EVENT_CLASS_CODE(i));
        PO_LOG.stmt(d_module_base,d_progress,' l_sync_trx_lines_tbl.TRX_ID = '||l_sync_trx_lines_tbl.TRX_ID(i));
        PO_LOG.stmt(d_module_base,d_progress,' l_sync_trx_lines_tbl.TRX_LEVEL_TYPE = '||l_sync_trx_lines_tbl.TRX_LEVEL_TYPE(i));
        PO_LOG.stmt(d_module_base,d_progress,' l_sync_trx_lines_tbl.TRX_LINE_ID = '||l_sync_trx_lines_tbl.TRX_LINE_ID(i));
        PO_LOG.stmt(d_module_base,d_progress,' l_sync_trx_lines_tbl.TRX_WAYBILL_NUMBER = '||l_sync_trx_lines_tbl.TRX_WAYBILL_NUMBER(i));
        PO_LOG.stmt(d_module_base,d_progress,' l_sync_trx_lines_tbl.TRX_LINE_DESCRIPTION = '||l_sync_trx_lines_tbl.TRX_LINE_DESCRIPTION(i));
        PO_LOG.stmt(d_module_base,d_progress,' l_sync_trx_lines_tbl.PRODUCT_DESCRIPTION = '||l_sync_trx_lines_tbl.PRODUCT_DESCRIPTION(i));
        PO_LOG.stmt(d_module_base,d_progress,' l_sync_trx_lines_tbl.TRX_LINE_GL_DATE = '||l_sync_trx_lines_tbl.TRX_LINE_GL_DATE(i));
        PO_LOG.stmt(d_module_base,d_progress,' l_sync_trx_lines_tbl.MERCHANT_PARTY_NAME = '||l_sync_trx_lines_tbl.MERCHANT_PARTY_NAME(i));
        PO_LOG.stmt(d_module_base,d_progress,' l_sync_trx_lines_tbl.MERCHANT_PARTY_DOCUMENT_NUMBER = '||l_sync_trx_lines_tbl.MERCHANT_PARTY_DOCUMENT_NUMBER(i));
        PO_LOG.stmt(d_module_base,d_progress,' l_sync_trx_lines_tbl.MERCHANT_PARTY_REFERENCE = '||l_sync_trx_lines_tbl.MERCHANT_PARTY_REFERENCE(i));
        PO_LOG.stmt(d_module_base,d_progress,' l_sync_trx_lines_tbl.MERCHANT_PARTY_TAXPAYER_ID = '||l_sync_trx_lines_tbl.MERCHANT_PARTY_TAXPAYER_ID(i));
        PO_LOG.stmt(d_module_base,d_progress,' l_sync_trx_lines_tbl.MERCHANT_PARTY_TAX_REG_NUMBER = '||l_sync_trx_lines_tbl.MERCHANT_PARTY_TAX_REG_NUMBER(i));
        PO_LOG.stmt(d_module_base,d_progress,' l_sync_trx_lines_tbl.ASSET_NUMBER = '||l_sync_trx_lines_tbl.ASSET_NUMBER(i));
     END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    PO_LOG.stmt(d_module_base,d_progress,'Failure while writing log in log_sync_trx_records proc '||SQLCODE||SQLERRM);
END log_sync_trx_records;
-----------------------------------------------------------------------------
--Start of Comments
--Name: update_non_tax_det_attrs_only
--  This proc can handle only SPO & BPA.
--Pre-reqs:
--  none
--Modifies:
--  Updates PO_HEADERS_ALL.COMMENTS & PO_LINES_ALL.ITEM_DESCRIPTION
--  values on to ZX_LINES_DET_FACTORS.TRX_DESCRIPTION & ZX_LINES_DET_FACTORS.TRX_LINE_DESCRIPTION/PRODUCT_DESCRIPTION table.
--Locks:
--  none
--Functional:
--  Updating only the non-tax determining attribute changes on to ZX API's that are done by the user on PO side.
--Technical:
--  Updating only the non-tax determining attribute changes on only those ZX transaction lines such that
--  their corresponding PO_LINE_LOCATIONS_ALL.TAX_ATTRIBUTE_UPDATE_CODE is NULL
--Parameters:
--IN:
--p_po_header_id_tbl
--  Table of po_header_id(SPO or BPA) values for which non-tax determining attribute changes
--  are to be committed on ZX APIs.
--OUT:
--x_return_status
--  Standard API specification parameter
--  Can hold one of the following values:
--    FND_API.G_RET_STS_SUCCESS (='S')
--    FND_API.G_RET_STS_ERROR (='E')
--    FND_API.G_RET_STS_UNEXP_ERROR (='U')
--Notes:
--  1. Calls out to EBTax API i.e., SYNCHRONIZE_TAX_REPOSITORY for committing the
--   non-tax determining attribute changes on ZX APIs that are done by the user on PO side.
--  2. Returns all expected errors from ebtax API's and are inserted into po_session_gt.
--
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE update_non_tax_det_attrs_only(p_po_header_id_tbl  IN          PO_TBL_NUMBER,
                                        p_po_session_gt_key IN          PO_SESSION_GT.key%TYPE,
                                        x_return_status     OUT NOCOPY  VARCHAR2) IS
  l_module_name CONSTANT VARCHAR2(100) := 'UPDATE_NON_TAX_DET_ATTRS_ONLY';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);
  d_progress                    NUMBER;
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(1000);
  l_count                       NUMBER;
  l_doc_type                    VARCHAR2(10);
  l_ship_null_tauc_count        NUMBER;
  p_po_release_id_tbl           PO_TBL_NUMBER;
  l_return_status               VARCHAR2(7);
  l_sync_trx_rec                ZX_API_PUB.sync_trx_rec_type;
  l_sync_trx_rec_null           ZX_API_PUB.sync_trx_rec_type;             --Uninitialized or Null record used to nullify the trx record for every loop.
  l_sync_trx_lines_tbl          ZX_API_PUB.sync_trx_lines_tbl_type%type;
  l_sync_trx_lines_tbl_null     ZX_API_PUB.sync_trx_lines_tbl_type%type;  --Uninitialized or Null record which is used to nullify the trx record for every loop.
BEGIN
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'p_po_header_id_tbl', p_po_header_id_tbl);
  END IF;
  SAVEPOINT update_ntda_savepoint;

  --For SPO or BPA
  IF p_po_header_id_tbl.COUNT <> 0 THEN

    d_progress := 10;
    FOR i IN 1..p_po_header_id_tbl.COUNT

    LOOP

      l_ship_null_tauc_count := 0;
      SELECT COUNT(1) INTO l_ship_null_tauc_count
      FROM PO_LINE_LOCATIONS_ALL PLL
      WHERE PLL.TAX_ATTRIBUTE_UPDATE_CODE IS NULL
      AND PLL.PO_HEADER_ID = p_po_header_id_tbl(i);

      d_progress := 20;
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,d_progress,'l_ship_null_tauc_count : '||l_ship_null_tauc_count);
      END IF;


      IF(l_ship_null_tauc_count <> 0) THEN
		-- bug 19666824
		-- move the logic here to avoid NO_DATA_FOUND exception when the document is deleted
			l_doc_type := NULL;
		  SELECT TYPE_LOOKUP_CODE INTO l_doc_type FROM PO_HEADERS_ALL WHERE PO_HEADER_ID = p_po_header_id_tbl(i);

		  d_progress := 30;
		  IF PO_LOG.d_stmt THEN
			PO_LOG.stmt(d_module_base,d_progress,'l_doc_type : '||l_doc_type);
		  END IF;

        IF(l_doc_type = 'STANDARD') THEN

            l_sync_trx_rec := l_sync_trx_rec_null;
            l_sync_trx_lines_tbl := l_sync_trx_lines_tbl_null;

            d_progress := 40;
            --Constructing l_sync_trx_rec record for po header.
            SELECT
            PO_CONSTANTS_SV.APPLICATION_ID,            --l_sync_trx_rec.APPLICATION_ID,
            PO_CONSTANTS_SV.PO_ENTITY_CODE,            --l_sync_trx_rec.ENTITY_CODE,
            PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE,       --l_sync_trx_rec.EVENT_CLASS_CODE,
            DECODE(PH.TAX_ATTRIBUTE_UPDATE_CODE,'CREATE',PO_CONSTANTS_SV.PO_CREATED,
                  'COPY_AND_CREATE',PO_CONSTANTS_SV.PO_CREATED,
                  PO_CONSTANTS_SV.PO_ADJUSTED),        --l_sync_trx_rec.EVENT_TYPE_CODE,
            PH.PO_HEADER_ID,                           --l_sync_trx_rec.TRX_ID,
            PH.SEGMENT1,                               --l_sync_trx_rec.TRX_NUMBER,
            PH.COMMENTS,                               --l_sync_trx_rec.TRX_DESCRIPTION,
            SYSDATE,                                   --l_sync_trx_rec.TRX_COMMUNICATED_DATE
            NULL,                                      --l_sync_trx_rec.BATCH_SOURCE_ID
            NULL,                                      --l_sync_trx_rec.BATCH_SOURCE_NAME
            NULL,                                      --l_sync_trx_rec.DOC_SEQ_ID
            NULL,                                      --l_sync_trx_rec.DOC_SEQ_NAME
            NULL,                                      --l_sync_trx_rec.DOC_SEQ_VALUE
            NULL,                                      --l_sync_trx_rec.TRX_DUE_DATE
            NULL,                                      --l_sync_trx_rec.TRX_TYPE_DESCRIPTION
            FND_API.G_MISS_CHAR,                       --l_sync_trx_rec.SUPPLIER_TAX_INVOICE_NUMBER
            FND_API.G_MISS_DATE,                       --l_sync_trx_rec.SUPPLIER_TAX_INVOICE_DATE
            FND_API.G_MISS_NUM,                        --l_sync_trx_rec.SUPPLIER_EXCHANGE_RATE
            FND_API.G_MISS_DATE,                       --l_sync_trx_rec.TAX_INVOICE_DATE
            FND_API.G_MISS_CHAR,                       --l_sync_trx_rec.TAX_INVOICE_NUMBER
            FND_API.G_MISS_CHAR,                       --l_sync_trx_rec.PORT_OF_ENTRY_CODE
            FND_API.G_MISS_CHAR                        --l_sync_trx_rec.APPLICATION_DOC_STATUS
            INTO  -- l_sync_trx_rec bug #19892170: replacing it with object columns
 		l_sync_trx_rec.APPLICATION_ID
		,l_sync_trx_rec.ENTITY_CODE
		,l_sync_trx_rec.EVENT_CLASS_CODE
		,l_sync_trx_rec.EVENT_TYPE_CODE
		,l_sync_trx_rec.TRX_ID
		,l_sync_trx_rec.TRX_NUMBER
		,l_sync_trx_rec.TRX_DESCRIPTION
		,l_sync_trx_rec.TRX_COMMUNICATED_DATE
		,l_sync_trx_rec.BATCH_SOURCE_ID
		,l_sync_trx_rec.BATCH_SOURCE_NAME
		,l_sync_trx_rec.DOC_SEQ_ID
		,l_sync_trx_rec.DOC_SEQ_NAME
		,l_sync_trx_rec.DOC_SEQ_VALUE
		,l_sync_trx_rec.TRX_DUE_DATE
		,l_sync_trx_rec.TRX_TYPE_DESCRIPTION
		,l_sync_trx_rec.SUPPLIER_TAX_INVOICE_NUMBER
		,l_sync_trx_rec.SUPPLIER_TAX_INVOICE_DATE
		,l_sync_trx_rec.SUPPLIER_EXCHANGE_RATE
		,l_sync_trx_rec.TAX_INVOICE_DATE
		,l_sync_trx_rec.TAX_INVOICE_NUMBER
		,l_sync_trx_rec.PORT_OF_ENTRY_CODE
		,l_sync_trx_rec.APPLICATION_DOC_STATUS
            FROM PO_HEADERS_ALL PH
            WHERE PH.PO_HEADER_ID=p_po_header_id_tbl(i);

            d_progress := 50;
            --Constructing l_sync_trx_lines_tbl record for po line(s)/shipment(s).
            SELECT
            PO_CONSTANTS_SV.APPLICATION_ID,               --l_sync_trx_lines_tbl.APPLICATION_ID
            PO_CONSTANTS_SV.PO_ENTITY_CODE,               --l_sync_trx_lines_tbl.ENTITY_CODE
            PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE,          --l_sync_trx_lines_tbl.EVENT_CLASS_CODE
            PLL.PO_HEADER_ID,                             --l_sync_trx_lines_tbl.TRX_ID
            PO_CONSTANTS_SV.PO_TRX_LEVEL_TYPE,            --l_sync_trx_lines_tbl.TRX_LEVEL_TYPE
            PLL.LINE_LOCATION_ID,                         --l_sync_trx_lines_tbl.TRX_LINE_ID
            NULL,                                         --l_sync_trx_lines_tbl.TRX_WAYBILL_NUMBER
            DECODE(PLL.SHIPMENT_TYPE,'STANDARD',
                    DECODE(PLL.PAYMENT_TYPE,NULL,PL.ITEM_DESCRIPTION, --non complex work Standard PO
                                                 PLL.DESCRIPTION),    --complex work Standard PO
                    PL.ITEM_DESCRIPTION                               --for shipment_type='PLANNED'
                  ),                                      --l_sync_trx_lines_tbl.TRX_LINE_DESCRIPTION
            DECODE(PLL.SHIPMENT_TYPE,'STANDARD',
                    DECODE(PLL.PAYMENT_TYPE,NULL,PL.ITEM_DESCRIPTION, --non complex work Standard PO
                                                 PLL.DESCRIPTION),    --complex work Standard PO
                    PL.ITEM_DESCRIPTION                               --for shipment_type='PLANNED'
                  ),                                      --l_sync_trx_lines_tbl.PRODUCT_DESCRIPTION
            NULL,                                         --l_sync_trx_lines_tbl.TRX_LINE_GL_DATE
            NULL,                                         --l_sync_trx_lines_tbl.MERCHANT_PARTY_NAME
            NULL,                                         --l_sync_trx_lines_tbl.MERCHANT_PARTY_DOCUMENT_NUMBER
            NULL,                                         --l_sync_trx_lines_tbl.MERCHANT_PARTY_REFERENCE
            NULL,                                         --l_sync_trx_lines_tbl.MERCHANT_PARTY_TAXPAYER_ID
            NULL,                                         --l_sync_trx_lines_tbl.MERCHANT_PARTY_TAX_REG_NUMBER
            NULL                                          --l_sync_trx_lines_tbl.ASSET_NUMBER
            BULK COLLECT INTO l_sync_trx_lines_tbl
            FROM PO_LINE_LOCATIONS_ALL PLL,PO_LINES_ALL PL
            WHERE PLL.PO_LINE_ID=PL.PO_LINE_ID AND PLL.TAX_ATTRIBUTE_UPDATE_CODE IS NULL
            AND PLL.PO_HEADER_ID=p_po_header_id_tbl(i);

            d_progress := 60;
            IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,d_progress,'Records values before calling sync_tax_repo API for po_header_id '||p_po_header_id_tbl(i)||' are :');
              log_sync_trx_records(d_module_base,d_progress,l_sync_trx_rec,l_sync_trx_lines_tbl);
            END IF;

            d_progress := 70;
            -- By default return status is SUCCESS if no exception occurs

            ZX_API_PUB.synchronize_tax_repository(
            p_api_version         =>  1.0,
            p_init_msg_list       =>  FND_API.G_TRUE,
            p_commit              =>  FND_API.G_FALSE,
            p_validation_level    =>  FND_API.G_VALID_LEVEL_FULL,
            x_return_status       =>  l_return_status,
            x_msg_count           =>  l_msg_count,
            x_msg_data            =>  l_msg_data,
            p_sync_trx_rec        =>  l_sync_trx_rec,
            p_sync_trx_lines_tbl  =>  l_sync_trx_lines_tbl);

            d_progress := 80;
            IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,d_progress,'synchronize_tax_repository returned with status for po_header_id '||p_po_header_id_tbl(i)||' is : '||l_return_status);
            END IF;

            -- Raise if any unexpected error
            IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            d_progress := 90;
            -- If expected errors, store error details in po_session_gt temporarily
            IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN

                INSERT INTO po_session_gt(
                  key,index_num1,num1,num2,
                  char1,char2,char3,char4
                )
                SELECT
                  p_po_session_gt_key
                  ,zxegt.trx_id
                  ,zxegt.trx_line_id
                  ,zxegt.trx_line_dist_id
                  ,zxegt.event_class_code
                  ,zxegt.message_text
                  ,'UPDATE_NON_TAX_DET_ATTRS_ONLY'
                  ,ph.segment1
                FROM zx_errors_gt zxegt, po_headers_all ph
                WHERE zxegt.event_class_code = PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE
                AND zxegt.trx_id = ph.po_header_id AND zxegt.APPLICATION_ID=PO_CONSTANTS_SV.APPLICATION_ID
                AND ph.po_header_id=p_po_header_id_tbl(i);

                d_progress := 100;
                BEGIN
                  SELECT COUNT(1) INTO l_count FROM zx_errors_gt;
                EXCEPTION WHEN OTHERS THEN
                  IF PO_LOG.d_stmt THEN
                    PO_LOG.stmt(d_module_base,d_progress,'Exception while hitting zx_errors_gt');
                  END IF;
                  l_count := 0;
                END;

                IF PO_LOG.d_stmt THEN
                  PO_LOG.stmt(d_module_base,d_progress,'Number of records in zx_errors_gt '||l_count);
                END IF;

                RAISE FND_API.G_EXC_ERROR;

              END IF; --FND_API.G_RET_STS_ERROR

        ELSIF(l_doc_type = 'BLANKET') THEN

          p_po_release_id_tbl := PO_TBL_NUMBER(); --Emptifying the po release ids table for every BPA.
          SELECT PO_RELEASE_ID BULK COLLECT INTO p_po_release_id_tbl FROM PO_RELEASES_ALL WHERE PO_HEADER_ID = p_po_header_id_tbl(i);

          FOR j IN 1..p_po_release_id_tbl.COUNT
          LOOP

              l_sync_trx_rec := l_sync_trx_rec_null;
              l_sync_trx_lines_tbl := l_sync_trx_lines_tbl_null;

              d_progress := 40;
              --Constructing l_sync_trx_rec record for release header.
              SELECT
              PO_CONSTANTS_SV.APPLICATION_ID,            --l_sync_trx_rec.APPLICATION_ID,
              PO_CONSTANTS_SV.REL_ENTITY_CODE,           --l_sync_trx_rec.ENTITY_CODE,
              PO_CONSTANTS_SV.REL_EVENT_CLASS_CODE,      --l_sync_trx_rec.EVENT_CLASS_CODE,
              DECODE(PR.TAX_ATTRIBUTE_UPDATE_CODE,'CREATE',PO_CONSTANTS_SV.REL_CREATED,
                    'COPY_AND_CREATE',PO_CONSTANTS_SV.REL_CREATED,
                    PO_CONSTANTS_SV.REL_ADJUSTED),       --l_sync_trx_rec.EVENT_TYPE_CODE,
              PR.PO_RELEASE_ID,                          --l_sync_trx_rec.TRX_ID,
              PH.SEGMENT1,                               --l_sync_trx_rec.TRX_NUMBER,
              NULL,                                      --l_sync_trx_rec.TRX_DESCRIPTION,
              SYSDATE,                                   --l_sync_trx_rec.TRX_COMMUNICATED_DATE
              NULL,                                      --l_sync_trx_rec.BATCH_SOURCE_ID
              NULL,                                      --l_sync_trx_rec.BATCH_SOURCE_NAME
              NULL,                                      --l_sync_trx_rec.DOC_SEQ_ID
              NULL,                                      --l_sync_trx_rec.DOC_SEQ_NAME
              NULL,                                      --l_sync_trx_rec.DOC_SEQ_VALUE
              NULL,                                      --l_sync_trx_rec.TRX_DUE_DATE
              NULL,                                      --l_sync_trx_rec.TRX_TYPE_DESCRIPTION
              FND_API.G_MISS_CHAR,                       --l_sync_trx_rec.SUPPLIER_TAX_INVOICE_NUMBER
              FND_API.G_MISS_DATE,                       --l_sync_trx_rec.SUPPLIER_TAX_INVOICE_DATE
              FND_API.G_MISS_NUM,                        --l_sync_trx_rec.SUPPLIER_EXCHANGE_RATE
              FND_API.G_MISS_DATE,                       --l_sync_trx_rec.TAX_INVOICE_DATE
              FND_API.G_MISS_CHAR,                       --l_sync_trx_rec.TAX_INVOICE_NUMBER
              FND_API.G_MISS_CHAR,                       --l_sync_trx_rec.PORT_OF_ENTRY_CODE
              FND_API.G_MISS_CHAR                        --l_sync_trx_rec.APPLICATION_DOC_STATUS

              INTO  -- l_sync_trx_rec bug #19892170: replacing it with object columns
                l_sync_trx_rec.APPLICATION_ID
                ,l_sync_trx_rec.ENTITY_CODE
                ,l_sync_trx_rec.EVENT_CLASS_CODE
                ,l_sync_trx_rec.EVENT_TYPE_CODE
                ,l_sync_trx_rec.TRX_ID
                ,l_sync_trx_rec.TRX_NUMBER
                ,l_sync_trx_rec.TRX_DESCRIPTION
                ,l_sync_trx_rec.TRX_COMMUNICATED_DATE
                ,l_sync_trx_rec.BATCH_SOURCE_ID
                ,l_sync_trx_rec.BATCH_SOURCE_NAME
                ,l_sync_trx_rec.DOC_SEQ_ID
                ,l_sync_trx_rec.DOC_SEQ_NAME
                ,l_sync_trx_rec.DOC_SEQ_VALUE
                ,l_sync_trx_rec.TRX_DUE_DATE
                ,l_sync_trx_rec.TRX_TYPE_DESCRIPTION
                ,l_sync_trx_rec.SUPPLIER_TAX_INVOICE_NUMBER
                ,l_sync_trx_rec.SUPPLIER_TAX_INVOICE_DATE
                ,l_sync_trx_rec.SUPPLIER_EXCHANGE_RATE
                ,l_sync_trx_rec.TAX_INVOICE_DATE
                ,l_sync_trx_rec.TAX_INVOICE_NUMBER
                ,l_sync_trx_rec.PORT_OF_ENTRY_CODE
                ,l_sync_trx_rec.APPLICATION_DOC_STATUS

              FROM PO_HEADERS_ALL PH,PO_RELEASES_ALL PR
              WHERE PH.PO_HEADER_ID=PR.PO_HEADER_ID AND PR.PO_RELEASE_ID=p_po_release_id_tbl(j);

              d_progress := 50;
              --Constructing l_sync_trx_lines_tbl record for release line(s)/shipment(s).
              SELECT
              PO_CONSTANTS_SV.APPLICATION_ID,               --l_sync_trx_lines_tbl.APPLICATION_ID
              PO_CONSTANTS_SV.REL_ENTITY_CODE,              --l_sync_trx_lines_tbl.ENTITY_CODE
              PO_CONSTANTS_SV.REL_EVENT_CLASS_CODE,         --l_sync_trx_lines_tbl.EVENT_CLASS_CODE
              PLL.PO_RELEASE_ID,                            --l_sync_trx_lines_tbl.TRX_ID
              PO_CONSTANTS_SV.REL_TRX_LEVEL_TYPE,           --l_sync_trx_lines_tbl.TRX_LEVEL_TYPE
              PLL.LINE_LOCATION_ID,                         --l_sync_trx_lines_tbl.TRX_LINE_ID
              NULL,                                         --l_sync_trx_lines_tbl.TRX_WAYBILL_NUMBER
              DECODE(PLL.SHIPMENT_TYPE,'STANDARD',
                      DECODE(PLL.PAYMENT_TYPE,NULL,PL.ITEM_DESCRIPTION, --non complex work Standard PO
                                                   PLL.DESCRIPTION),    --complex work Standard PO
                      PL.ITEM_DESCRIPTION                               --for shipment_type='PLANNED'
                    ),                                      --l_sync_trx_lines_tbl.TRX_LINE_DESCRIPTION
              DECODE(PLL.SHIPMENT_TYPE,'STANDARD',
                      DECODE(PLL.PAYMENT_TYPE,NULL,PL.ITEM_DESCRIPTION, --non complex work Standard PO
                                                   PLL.DESCRIPTION),    --complex work Standard PO
                      PL.ITEM_DESCRIPTION                               --for shipment_type='PLANNED'
                    ),                                      --l_sync_trx_lines_tbl.PRODUCT_DESCRIPTION
              NULL,                                         --l_sync_trx_lines_tbl.TRX_LINE_GL_DATE
              NULL,                                         --l_sync_trx_lines_tbl.MERCHANT_PARTY_NAME
              NULL,                                         --l_sync_trx_lines_tbl.MERCHANT_PARTY_DOCUMENT_NUMBER
              NULL,                                         --l_sync_trx_lines_tbl.MERCHANT_PARTY_REFERENCE
              NULL,                                         --l_sync_trx_lines_tbl.MERCHANT_PARTY_TAXPAYER_ID
              NULL,                                         --l_sync_trx_lines_tbl.MERCHANT_PARTY_TAX_REG_NUMBER
              NULL                                          --l_sync_trx_lines_tbl.ASSET_NUMBER
              BULK COLLECT INTO l_sync_trx_lines_tbl
              FROM PO_LINE_LOCATIONS_ALL PLL,PO_LINES_ALL PL
              WHERE PLL.PO_LINE_ID=PL.PO_LINE_ID AND PLL.TAX_ATTRIBUTE_UPDATE_CODE IS NULL
              AND PLL.PO_RELEASE_ID=p_po_release_id_tbl(j);

              d_progress := 60;
              IF PO_LOG.d_stmt THEN
                PO_LOG.stmt(d_module_base,d_progress,'Records values before calling sync_tax_repo API for po_release_id '||p_po_release_id_tbl(j)||' are :');
                log_sync_trx_records(d_module_base,d_progress,l_sync_trx_rec,l_sync_trx_lines_tbl);
              END IF;

              d_progress := 70;
              -- By default return status is SUCCESS if no exception occurs

              ZX_API_PUB.synchronize_tax_repository(
              p_api_version         =>  1.0,
              p_init_msg_list       =>  FND_API.G_TRUE,
              p_commit              =>  FND_API.G_FALSE,
              p_validation_level    =>  FND_API.G_VALID_LEVEL_FULL,
              x_return_status       =>  l_return_status,
              x_msg_count           =>  l_msg_count,
              x_msg_data            =>  l_msg_data,
              p_sync_trx_rec        =>  l_sync_trx_rec,
              p_sync_trx_lines_tbl  =>  l_sync_trx_lines_tbl);

              d_progress := 80;
              IF PO_LOG.d_stmt THEN
                PO_LOG.stmt(d_module_base,d_progress,'synchronize_tax_repository returned with status for po_release_id '||p_po_release_id_tbl(j)||' is : '||l_return_status);
              END IF;

              -- Raise if any unexpected error
              IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;

              d_progress := 90;
              -- If expected errors, store error details in po_session_gt temporarily
              IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN

                INSERT INTO po_session_gt(
                  key,index_num1,num1,num2,
                  char1,char2,char3,char4
                )
                SELECT
                  p_po_session_gt_key
                  ,zxegt.trx_id
                  ,zxegt.trx_line_id
                  ,zxegt.trx_line_dist_id
                  ,zxegt.event_class_code
                  ,zxegt.message_text
                  ,'UPDATE_NON_TAX_DET_ATTRS_ONLY'
                  ,ph.segment1
                FROM zx_errors_gt zxegt, po_headers_all ph, po_releases_all pr
                WHERE zxegt.event_class_code = PO_CONSTANTS_SV.REL_EVENT_CLASS_CODE
                AND zxegt.trx_id = pr.po_release_id AND pr.po_header_id = ph.po_header_id
                AND zxegt.application_id=PO_CONSTANTS_SV.APPLICATION_ID
                AND pr.po_release_id=p_po_release_id_tbl(j);

                d_progress := 100;
                BEGIN
                  SELECT COUNT(1) INTO l_count FROM zx_errors_gt;
                EXCEPTION WHEN OTHERS THEN
                  IF PO_LOG.d_stmt THEN
                    PO_LOG.stmt(d_module_base,d_progress,'Exception while hitting zx_errors_gt');
                  END IF;
                  l_count := 0;
                END;

                IF PO_LOG.d_stmt THEN
                  PO_LOG.stmt(d_module_base,d_progress,'Number of records in zx_errors_gt '||l_count);
                END IF;
                RAISE FND_API.G_EXC_ERROR;

              END IF; --FND_API.G_RET_STS_ERROR

          END LOOP; --p_po_release_id_tbl.COUNT

        END IF; --l_doc_type

      END IF; --l_ship_null_tauc_count

    END LOOP; --p_po_header_id_tbl.COUNT

  END IF; --p_po_header_id_tbl.COUNT <> 0

  --Control will come here when SPO and BPA doesn't throw either of FND_API.G_EXC_ERROR or FND_API.G_EXC_UNEXPECTED_ERROR exceptions.
  IF(x_return_status IS NULL) THEN      --Condition for checking when non-tax determining attribute changes are not done for neither of SPO nor BPA.
    x_return_status := FND_API.G_RET_STS_SUCCESS; --In that case x_return_status will be null hardcoding it to FND_API.G_RET_STS_SUCCESS for just knowing whether the proc has encountered any exception.
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module_base);
    PO_LOG.proc_end(d_module_base, 'x_return_status', x_return_status);
  END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR  THEN
      ROLLBACK TO SAVEPOINT update_ntda_savepoint;
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO SAVEPOINT update_ntda_savepoint;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT update_ntda_savepoint;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module_base);
    PO_LOG.proc_end(d_module_base, 'x_return_status', x_return_status);
  END IF;

END UPDATE_NON_TAX_DET_ATTRS_ONLY;
-----------------------------------------------------------------------------
-- BUG# 18641338 fix ends

END PO_TAX_INTERFACE_PVT;

/
