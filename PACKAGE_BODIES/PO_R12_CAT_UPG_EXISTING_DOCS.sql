--------------------------------------------------------
--  DDL for Package Body PO_R12_CAT_UPG_EXISTING_DOCS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_R12_CAT_UPG_EXISTING_DOCS" AS
/* $Header: PO_R12_CAT_UPG_EXISTING_DOCS.plb 120.10 2006/08/18 21:58:34 pthapliy noship $ */

g_debug BOOLEAN := PO_R12_CAT_UPG_DEBUG.is_logging_enabled;

g_pkg_name CONSTANT VARCHAR2(30) := 'PO_R12_CAT_UPG_EXISTING_DOCS';
g_module_prefix CONSTANT VARCHAR2(100) := 'po.plsql.' || g_pkg_name || '.';

type VARCHAR2_SIZE_1   IS TABLE OF VARCHAR2(1);
type VARCHAR2_SIZE_25  IS TABLE OF VARCHAR2(25);
type VARCHAR2_SIZE_150 IS TABLE OF VARCHAR2(150);
type VARCHAR2_SIZE_240 IS TABLE OF VARCHAR2(240);

gInvItemIds                   DBMS_SQL.NUMBER_TABLE;
gPoOrgIds                     DBMS_SQL.NUMBER_TABLE;
gItemDescriptions             DBMS_SQL.VARCHAR2_TABLE;
gIpCategoryIds                DBMS_SQL.NUMBER_TABLE;

gPoHeaderIds                  DBMS_SQL.NUMBER_TABLE;
gPoLineIds                    DBMS_SQL.NUMBER_TABLE;

gPoReqTemplateNames           VARCHAR2_SIZE_25;
gPoReqTemplateLineIds         DBMS_SQL.NUMBER_TABLE;

gUpdatedAttribute             DBMS_SQL.VARCHAR2_TABLE;
gRecreateAttribRow            VARCHAR2_SIZE_1;
gRecreateAttribTLPRow         VARCHAR2_SIZE_1;

gImages                       VARCHAR2_SIZE_150;
gImageUrls                    VARCHAR2_SIZE_150;

--gNumLanguages    NUMBER;
NULL_ID          NUMBER := -2;
g_R12_UPGRADE_USER NUMBER := PO_R12_CAT_UPG_PVT.g_R12_UPGRADE_USER;
g_R12_MIGRATION_PROGRAM PO_HEADERS_ALL.last_updated_program%TYPE
                 := PO_R12_CAT_UPG_PVT.g_R12_MIGRATION_PROGRAM;

g_err_num NUMBER := PO_R12_CAT_UPG_PVT.g_application_err_num;

--------------------------------------------------------------------------------
--Start of Comments
--Name: process_modified_po_lines
--Pre-reqs:
--  The datamodel changes for Unified Catlog Upgrade should have been applied.
--Modifies:
--  a) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Update the po lines,which have been already upgraded, but certain attribtes
--  have changed - item_id, category_id, description.
--  Also create/update the corresponding attributes/attributesTLP records.
--  This API should be called during the upgrade phase only.
--Parameters:
--INend p_batch_size size of the po lines batch to be processed
-- p_start_id start rowid of the po_lines_all to be processed
-- p_end_id end rowid of the po_lines_all to be processed
--OUT:
-- x_return_status: status useful for the upgrade
-- x_rows_processed: rows processed - useful for the ad parallel upgrade
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE process_modified_po_lines(p_batch_size     IN NUMBER default 2500,
                                    p_base_lang      IN FND_LANGUAGES.language_code%TYPE  default null,
                                    p_start_id       IN NUMBER  default null,
                                    p_end_id         IN NUMBER  default null,
                                    x_return_status  IN OUT NOCOPY VARCHAR,
                                    x_rows_processed IN OUT NOCOPY NUMBER)
IS
  -- Recreate flag in the below sql means clear/delete+create that row
  -- for description change, you have to just update the description not recreate
  -- for item number change on line, you need to recreate the Attribute+TLP row
  --
  -- In the below sql, there is no need for a constraint on
  -- po headers to look for only quotes/agreements
  -- the check for pol.last_updated_program = g_R12_MIGRATION_PROGRAM is sufficient.
  -- there is an index on last_updated_program and only agreements/quotes will have this
  -- populated with g_R12_MIGRATION_PROGRAM.
  --

  -- SQL What: Cursor to get the PO lines that have been modified since the
  --           last run of the upgrade program.
  --           Whether to recreate the attribute/TLP record is based on
  --           what has changed - recreate only if iP_category_id/description/
  --           item_id has changed. Even if the PO category had changed but the
  --           mapped shopping category is the same as before, we wont recreate
  --           the attributes.
  --           NOTE: Keep the iP_category_id check as the
  --           first part of the decode, since we have some logic later for
  --           ip_category_id changes
  -- SQL Why : To update the columns of the PO lines and the corresponding
  --           attribute and TLP values.
  -- SQL Join: several
  CURSOR getModifiedLinesCsr(p_start_id NUMBER, p_end_id NUMBER)  is
    SELECT POL.po_line_id,  -- PoLineId
           TO_CHAR(NULL_ID), NULL_ID, -- TemplateName, TemplateId
           NVL(ICXM.SHOPPING_CATEGORY_ID, NULL_ID), -- iP Category Id
           NVL(POL.item_id, NULL_ID), POL.org_id, POL.item_description,
           POL.attribute13, -- Image
           POL.attribute14, -- Image URL
           DECODE( NVL(icxm.shopping_category_id, NULL_ID), TLP.ip_category_id,
                   decode(POL.item_description, TLP.description,
                   decode(POL.item_id, TLP.inventory_item_id,
                   NULL, 'ITEM_ID'), 'DESCRIPTION'), 'IP_CATEGORY_ID'), -- Attribute
           DECODE( NVL(icxm.shopping_category_id, NULL_ID), TLP.ip_category_id,
                   decode(POL.item_description, TLP.description,
                   decode(POL.item_id, TLP.inventory_item_id,
                   'N', 'Y'), 'Y'), 'Y'), -- Recreate Attribute
           DECODE( NVL(icxm.shopping_category_id, NULL_ID), TLP.ip_category_id,
                   decode(POL.item_description, TLP.description,
                   decode(POL.item_id, TLP.inventory_item_id,
                   'N', 'Y'), 'Y'), 'Y') -- Recreate Attribute TLP
    FROM PO_LINES_ALL POL, PO_ATTRIBUTE_VALUES_TLP TLP,
         ICX_CAT_PURCHASING_CAT_MAP_V ICXM
    WHERE POL.last_updated_program = g_R12_MIGRATION_PROGRAM
      AND POL.po_line_id = TLP.po_line_id
      AND POL.CATEGORY_ID = ICXM.po_category_id(+)
      AND TLP.language = p_base_lang
      AND (POL.item_description <> TLP.description
           OR NVL(POL.item_id, NULL_ID) <> TLP.inventory_item_id)
      AND POL.po_line_id between p_start_id and p_end_id --Bug#5156673
    UNION ALL
    SELECT POL.po_line_id,  -- PoLineId
           TO_CHAR(NULL_ID), NULL_ID, -- TemplateName, TemplateId
           POL.ip_category_id, NVL(POL.item_id, NULL_ID), POL.org_id, POL.item_description,
           POL.attribute13, -- Image
           POL.attribute14, -- Image URL
           'ITEM_TRANSLATION', 'N','Y' -- Attribute, Recreate Attrib, Recreate Attrib TLP
    FROM PO_LINES_ALL POL, MTL_SYSTEM_ITEMS_TL MTL,
         FINANCIALS_SYSTEM_PARAMS_ALL FSP
    WHERE POL.last_updated_program = g_R12_MIGRATION_PROGRAM
      AND POL.item_id IS NOT NULL
      AND POL.item_id = MTL.inventory_item_id
      AND POL.org_id  = FSP.org_id
      AND FSP.inventory_organization_id = MTL.organization_id
      AND MTL.language = MTL.source_lang
      AND NOT EXISTS
      (
          SELECT 'Upgraded Lines with newly added item master translations'
          FROM   PO_ATTRIBUTE_VALUES_TLP POATLP
          WHERE POATLP.po_line_id <> NULL_ID
            AND POATLP.po_line_id = POL.po_line_id
            AND POATLP.org_id = POL.org_id
            AND POATLP.language = MTL.language
      )
      AND POL.po_line_id between p_start_id and p_end_id --Bug#5156673
    UNION ALL
    SELECT po_line_id,  -- PoLineId
           TO_CHAR(NULL_ID), NULL_ID, -- TemplateName, TemplateId
           ip_category_id, nvl(inventory_item_id, NULL_ID), org_id, null, -- no need to get description(null)
           NULL, -- Image
           NULL, -- Image URL
           'LINE_DELETED', 'N', 'N' -- Attribute, Recreate Attrib, Recreate Attrib TLP
    FROM PO_ATTRIBUTE_VALUES POAT
    WHERE po_line_id <> NULL_ID --Bug#4865650
    AND NOT EXISTS ( SELECT 'PO Line deleted after pre-upgrade'
                       FROM PO_LINES_ALL POL
                       WHERE POL.po_line_id = POAT.po_line_id )
    AND POAT.po_line_id between p_start_id and p_end_id ;--Bug#5156673

  l_was_R12_upg_ever_run_before NUMBER := 0;

  l_api_name      CONSTANT VARCHAR2(30) := 'process_modified_po_lines';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

BEGIN
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  l_progress := '010';

  -- SQL What: If this is the first time the upgrade script has been run
  --           then directly run the procedure PROCESS_NEW_PO_LINES.
  -- SQL Why : The procedure PROCESS_MODIFIED_PO_LINES is applicable only for those
  --           lines that have been modified since the last upgrade.
  -- SQL Join: last_updated_program
  SELECT count(*)
  INTO l_was_R12_upg_ever_run_before
  FROM po_lines_all pol
  WHERE pol.last_updated_program = g_R12_MIGRATION_PROGRAM
    AND POL.po_line_id between p_start_id and p_end_id
    AND rownum=1;

  l_progress := '030';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'lines_already_upgraded flag='||l_was_R12_upg_ever_run_before); END IF;

  IF (l_was_R12_upg_ever_run_before = 0) THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'early END'); END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    RETURN;
  END IF;

  l_progress := '040';
  LOOP
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Inside loop'); END IF;
    -- The following exception occurs if we dont do this check for existence:
    --     ORA-06531: Reference to uninitialized collection.
    IF (gPoLineIds.exists(1)) THEN
      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Modified Lines; gPoLineIds.DELETE'); END IF;
      gPoLineIds.DELETE;
      gIpCategoryIds.DELETE;
      gInvItemIds.DELETE;
      gPoOrgIds.DELETE;
      gItemDescriptions.DELETE;
      gImages.DELETE;
      gImageUrls.DELETE;
      gUpdatedAttribute.DELETE;
      gRecreateAttribRow.DELETE;
      gRecreateAttribTLPRow.DELETE;
      gPoReqTemplateNames.DELETE;
      gPoReqTemplateLineIds.DELETE;
    END IF;

    -- Get the PO Lines which have not been updated yet
    l_progress := '050';
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Opening Cursor'); END IF;
    OPEN getModifiedLinesCsr(p_start_id, p_end_id);

    l_progress := '060';
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Fetching cursor'); END IF;
    -- No need of LIMIT batchsize because the cursor is returning only
    -- a batch of lines (start and end line id)
    FETCH getModifiedLinesCsr
      BULK COLLECT into gPoLineIds,
                        gPoReqTemplateNames, gPoReqTemplateLineIds,
                        gIpCategoryIds, gInvItemIds,
                        gPoOrgIds, gItemDescriptions,
                        gImages,
                        gImageUrls,
                        gUpdatedAttribute,
                        gRecreateAttribRow, gRecreateAttribTLPRow;

    l_progress := '070';
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Closing cursor'); END IF;
    CLOSE getModifiedLinesCsr;

    l_progress := '080';
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'gPoLineIds.COUNT='||gPoLineIds.COUNT); END IF;
    EXIT WHEN gPoLineIds.COUNT = 0;

    l_progress := '090';

    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Updating PO Lines'); END IF;

    -- SQL What: Update the PO Lines with ip_category_id
    -- SQL Why : Part of catalog upgrade requirements
    -- SQL Join: po_line_id
    -- We are specifically not updating the last_updated_by, login columns
    -- because we want to preserve that information(updating -2 to these
    -- columns is not useful when we already have the
    -- last_updated_program updated to  g_R12_MIGRATION_PROGRAM
    FORALL i IN 1..gPoLineIds.COUNT
      UPDATE PO_LINES_ALL  POL
      SET ip_category_id = gIpCategoryIds(i),
          last_updated_program = g_R12_MIGRATION_PROGRAM
      WHERE po_line_id = gPoLineIds(i)
        AND gUpdatedAttribute(i) = 'IP_CATEGORY_ID';

    x_rows_processed := SQL%ROWCOUNT; --Bug#5156673:

    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of PO_LINES_ALL rows updated='||x_rows_processed); END IF;

    l_progress := '100';

    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'PO Lines: Deleting Attributes'); END IF;

    -- SQL What: For item change erase the attributes
    -- SQL Why : Instead of erasing the columns, just delete the rows from
    --           attributes table and recreate the row later.
    -- SQL Join: po_line_id
    FORALL i IN 1..gPoLineIds.COUNT
      DELETE FROM PO_ATTRIBUTE_VALUES POAT
      WHERE po_line_id = gPoLineIds(i)
        AND (gRecreateAttribRow(i) = 'Y' OR gUpdatedAttribute(i) = 'LINE_DELETED');

    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of PO_ATTRIBUTE_VALUES rows deleted='||SQL%rowcount); END IF;

    l_progress := '110';

    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Deleting Attribute TLP'); END IF;

    -- SQL What: For item change erase the attributes TLP
    -- SQL Why : Instead of erasing the columns, just delete the rows from
    --           attributes TLP table and recreate the row later.
    -- SQL Join: po_line_id
    FORALL i IN 1..gPoLineIds.COUNT
      DELETE FROM PO_ATTRIBUTE_VALUES_TLP POATLP
      WHERE po_line_id = gPoLineIds(i)
        AND (gRecreateAttribTLPRow(i) = 'Y' OR  gUpdatedAttribute(i) = 'LINE_DELETED');


    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of PO_ATTRIBUTE_VALUES_TLP rows deleted='||SQL%rowcount); END IF;

    l_progress := '120';
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Updating Attributes'); END IF;

    -- SQL What: Update the PO attribute values TLP when the description has changed
    -- SQL Why : Sync up the description at the TLP level
    -- SQL Join: po_line_id
    FORALL i IN 1..gPoLineIds.COUNT
      UPDATE PO_ATTRIBUTE_VALUES_TLP
      SET description = gItemDescriptions(i),
          last_updated_program = g_R12_MIGRATION_PROGRAM
      WHERE po_line_id = gPoLineIds(i)
        AND gUpdatedAttribute(i) = 'DESCRIPTION';

    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of PO_ATTRIBUTE_VALUES_TLP rows updated='||SQL%rowcount); END IF;

    l_progress := '130';

    -- Lines for which attributes records need to be created are in gPoLineIds
    CREATE_LINE_ATTRIBUTES(p_batch_size, p_base_lang);

    l_progress := '140';
    -- Lines for which attributes TLP records need to be created are in gPoLineIds
    CREATE_LINE_ATTRIBUTES_TLP(p_batch_size, p_base_lang);

    l_progress := '150';
    -- Commit is done by the calling program - poxukpol.sql

  END LOOP;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END process_modified_po_lines;

--------------------------------------------------------------------------------
--Start of Comments
--Name: process_new_po_lines
--Pre-reqs:
--  The datamodel changes for Unified Catlog Upgrade should have been applied.
--Modifies:
--  a) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Update the po lines,which have never been upgraded, with ip category id info.
--  Also create the corresponding attributes/attributesTLP records.
--  This API should be called during the upgrade phase only.
--Parameters:
--IN:
-- p_batch_size size of the po lines batch to be processed
-- p_start_id start po_line_id of the po_lines_all to be processed
-- p_end_id end po_line_id of the po_lines_all to be processed
--OUT:
-- x_return_status: status useful for the upgrade
-- x_rows_processed: rows processed - useful for the ad parallel upgrade
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE process_new_po_lines(     p_batch_size     IN NUMBER default 2500,
                                    p_base_lang      IN FND_LANGUAGES.language_code%TYPE  default null,
                                    p_start_id       IN NUMBER  default null,
                                    p_end_id         IN NUMBER  default null,
                                    x_return_status  IN OUT NOCOPY VARCHAR,
                                    x_rows_processed IN OUT NOCOPY NUMBER)
IS
  -- SQL What: Cursor to get the PO lines that have not been upgraded yet.
  -- SQL Why : To update the columns of the PO lines and the corresponding
  --           attribute and TLP values.
  -- SQL Join: type_lookup_code, po_header_id, last_updated_program
  CURSOR getNonUpgradedLinesCsr(p_start_id NUMBER, p_end_id NUMBER) IS
    SELECT po_line_id,       -- po_line_id
           to_char(NULL_ID), -- TemplateName
           NULL_ID,          -- TemplateId
           NVL(ICXM.SHOPPING_CATEGORY_ID, NULL_ID),
           NVL(item_id, NULL_ID),
           pol.org_id,
           item_description,
           POL.attribute13,  -- Image
           POL.attribute14,  -- ImageUrl
           NULL,             -- Attribute
           'Y',              -- Recreate Attrib Flag
           'Y'               -- Recreate Attrib TLP Flag
    FROM PO_LINES_ALL POL,
         PO_HEADERS_ALL POH,
         ICX_CAT_PURCHASING_CAT_MAP_V ICXM
    WHERE POL.last_updated_program IS NULL
      AND POL.po_header_id = POH.po_header_id
      AND POH.type_lookup_code IN ('BLANKET', 'QUOTATION')
      AND POL.CATEGORY_ID = ICXM.po_category_id(+)
      AND POL.po_line_id between p_start_id and p_end_id ;--Bug#5156673

  l_api_name      CONSTANT VARCHAR2(30) := 'process_new_po_lines';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

BEGIN
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  l_progress := '010';

  LOOP
    l_progress := '030';

    -- The following exception occurs if we dont do this check for existence:
    --     ORA-06531: Reference to uninitialized collection.
    IF (gPoLineIds.exists(1)) THEN
      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'New Lines; gPoLineIds.DELETE'); END IF;
      gPoLineIds.DELETE;
      gIpCategoryIds.DELETE;
      gInvItemIds.DELETE;
      gPoOrgIds.DELETE;
      gItemDescriptions.DELETE;
      gImages.DELETE;
      gImageUrls.DELETE;
      gUpdatedAttribute.DELETE;
      gRecreateAttribRow.DELETE;
      gRecreateAttribTLPRow.DELETE;
      gPoReqTemplateNames.DELETE;
      gPoReqTemplateLineIds.DELETE;
    END IF;

    -- Get the PO Lines which have not been updated yet
    l_progress := '040';
    OPEN getNonUpgradedLinesCsr(p_start_id, p_end_id);

    l_progress := '050';
    FETCH getNonUpgradedLinesCsr
    BULK COLLECT into gPoLineIds,
                      gPoReqTemplateNames, gPoReqTemplateLineIds,
                      gIpCategoryIds, gInvItemIds,
                      gPoOrgIds, gItemDescriptions,
                      gImages,
                      gImageUrls,
                      gUpdatedAttribute,
                      gRecreateAttribRow, gRecreateAttribTLPRow;

    l_progress := '060';
    CLOSE getNonUpgradedLinesCsr;


    l_progress := '070';
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Processing a batch with gPoLineIds.COUNT='||gPoLineIds.COUNT); END IF;
    EXIT WHEN gPoLineIds.COUNT = 0;

    l_progress := '080';

    -- Update the PO Lines with ip_category_id

    -- SQL What: Update the PO Lines with ip_category_id and stamp the
    --           last_updated_program with the Catalog Upgrade User
    -- SQL Why : Part of catalog upgrade requirements
    -- SQL Join: po_line_id
    -- We are specifically not updating the last_updated_by, login columns
    -- because we want to preserve that information(updating -2 to these
    -- columns is not useful when we already have the
    -- last_updated_program updated to  g_R12_MIGRATION_PROGRAM
    FORALL i IN 1..gPoLineIds.COUNT
      UPDATE PO_LINES_ALL  POL
      SET ip_category_id = gIpCategoryIds(i),
          last_updated_program = g_R12_MIGRATION_PROGRAM
      WHERE po_line_id = gPoLineIds(i);

    x_rows_processed := SQL%rowcount;--Bug#5156673

    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of PO_LINES_ALL rows updated='||x_rows_processed); END IF;

--    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of IP_CATEGORY_IDs loaded='||SQL%rowcount); END IF;

    l_progress := '100';
    -- Lines for which attributes need to be created are in gPoLineIds
    CREATE_LINE_ATTRIBUTES(p_batch_size, p_base_lang);

    l_progress := '110';
    -- Lines for which attributes TLP records need to be created are in gPoLineIds
    CREATE_LINE_ATTRIBUTES_TLP(p_batch_size, p_base_lang);

    l_progress := '120';
    -- Commit is done by the calling program - poxukpol.sql
  END LOOP;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_progress := '130';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END process_new_po_lines;

--------------------------------------------------------------------------------
--Start of Comments
--Name: create_line_attributes
--Pre-reqs:
--  The datamodel changes for Unified Catlog Upgrade should have been applied.
--Modifies:
--  a) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Create Line Attributes for a Agreements/Quotations/Requisition Templates.
--  This API should be called during the upgrade phase only.
--Parameters:
--IN:
-- None
--OUT:
-- None
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE create_line_attributes(p_batch_size IN NUMBER,
                                 p_base_lang  IN FND_LANGUAGES.language_code%TYPE)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'create_line_attributes';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

BEGIN
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  IF g_debug THEN
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'gPoLineIds.COUNT='||gPoLineIds.COUNT);
    IF (gPoLineIds.COUNT > 0) THEN
      PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'gPoLineIds(1)='||gPoLineIds(1));
      PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'gPoReqTemplateNames(1)='||gPoReqTemplateNames(1));
      PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'gPoReqTemplateLineIds(1)='||gPoReqTemplateLineIds(1));
      PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'gIpCategoryIds(1)='||gIpCategoryIds(1));
      PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'gInvItemIds(1)='||gInvItemIds(1));
      PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'gPoOrgIds(1)='||gPoOrgIds(1));
    END IF;
  END IF;

  l_progress := '010';
  -- SQL What: Create records in Attribute table
  -- SQL Why : Only those records that have gRecreateAttribRow(i)='Y', need to be
  --           created in the Attributes table. Insert 1 attribute record for every
  --           line that has been just processed and does not already exist in
  --           attributes table.
  -- SQL Join: several
  FORALL i IN 1..gPoLineIds.COUNT
    INSERT INTO PO_ATTRIBUTE_VALUES
    (
      ATTRIBUTE_VALUES_ID,
      PO_LINE_ID,
      REQ_TEMPLATE_NAME,
      REQ_TEMPLATE_LINE_NUM,
      IP_CATEGORY_ID,
      INVENTORY_ITEM_ID,
      ORG_ID,
      PICTURE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      last_updated_program,
      LAST_UPDATE_DATE,
      CREATED_BY,
      CREATION_DATE
    )
    SELECT PO_ATTRIBUTE_VALUES_S.nextval,
           gPoLineIds(i),
           gPoReqTemplateNames(i), -- req_template_name
           gPoReqTemplateLineIds(i), -- req_template_line_id
           gIpCategoryIds(i), -- ip_category_id
           gInvItemIds(i), -- inventory_item_id
           gPoOrgIds(i), -- org_id
           NVL(gImages(i), gImageUrls(i)), -- Image or URL
           g_R12_UPGRADE_USER, -- last_updated_by
           g_R12_UPGRADE_USER, -- last_update_login
           g_R12_MIGRATION_PROGRAM, -- last_update_program
           sysdate, -- last_update_date
           g_R12_UPGRADE_USER, -- created_by
           sysdate -- creation_date
    FROM DUAL
    WHERE gRecreateAttribRow(i) = 'Y'
      AND NOT EXISTS
       (SELECT /*+ INDEX(POAT, PO_ATTRIBUTE_VALUES_U2) */
              'Attr row already exists'
        FROM PO_ATTRIBUTE_VALUES POAT
        WHERE POAT.po_line_id = gPoLineIds(i)
          AND POAT.req_template_name = gPoReqTemplateNames(i)
          AND POAT.req_template_line_num = to_char(gPoReqTemplateLineIds(i))
          AND POAT.org_id = gPoOrgIds(i));

  l_progress := '020';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of PO_ATTRIBUTE_VALUES rows inserted='||SQL%rowcount); END IF;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception:'||SQLERRM); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END create_line_attributes;

--------------------------------------------------------------------------------
--Start of Comments
--Name: create_line_attributes_tlp
--Pre-reqs:
--  The datamodel changes for Unified Catlog Upgrade should have been applied.
--Modifies:
--  a) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Create Line Attributes TLP.
--  Create Line Attributes for TLP records for
--  Agreements/Quotations/Requisition Templates.
--  This API should be called during the upgrade phase only.
--Parameters:
--IN:
-- None
--OUT:
-- None
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE create_line_attributes_tlp(p_batch_size IN NUMBER,
                                     p_base_lang  IN FND_LANGUAGES.language_code%TYPE)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'create_line_attributes_tlp';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';
BEGIN
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  l_progress := '020';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Inserting for description based items'); END IF;

  -- SQL What: Insert attributes TLP records for every line that has been just
  --           processed and the attribute row does not already exist in
  --           attributes_tlp table.
  -- SQL Why : Only those records that have gRecreateAttribTLPRow(i)='Y', need
  --           to be created in the Attributes table. Expense items will have
  --           only 1 TLP record it does not matter which global plsql structure
  --           we look at, for the count (we are using gInvItemIds.COUNT. For
  --           expense items you will still have this element, but the value
  --           will be null.
  -- SQL Join: several
  FORALL i in 1..gInvItemIds.COUNT
    INSERT INTO PO_ATTRIBUTE_VALUES_TLP
    (
      ATTRIBUTE_VALUES_TLP_ID,
      PO_LINE_ID,
      REQ_TEMPLATE_NAME,
      REQ_TEMPLATE_LINE_NUM,
      IP_CATEGORY_ID,
      INVENTORY_ITEM_ID,
      ORG_ID,
      LANGUAGE,
      DESCRIPTION,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      last_updated_program,
      LAST_UPDATE_DATE,
      CREATED_BY,
      CREATION_DATE
    )
    SELECT PO_ATTRIBUTE_VALUES_TLP_S.nextval,
           gPoLineIds(i),
           gPoReqTemplateNames(i), -- req_template_name
           gPoReqTemplateLineIds(i), -- req_template_line_id
           gIpCategoryIds(i), -- ip_category_id
           gInvItemIds(i), -- inventory_item_id
           gPoOrgIds(i), -- org_id
           p_base_lang,
           gItemDescriptions(i),
           g_R12_UPGRADE_USER, -- last_updated_by
           g_R12_UPGRADE_USER, -- last_update_login
           g_R12_MIGRATION_PROGRAM, -- last_update_program
           sysdate, -- last_update_date
           g_R12_UPGRADE_USER, -- created_by
           sysdate -- creation_date
    FROM DUAL
    WHERE gRecreateAttribTLPRow(i) = 'Y'
      AND gInvItemIds(i) = NULL_ID -- Description based non catalog item
      AND NOT EXISTS
       (SELECT /*+ INDEX(POATLP, PO_ATTRIBUTE_VALUES_TLP_U2) */
               NULL
        FROM PO_ATTRIBUTE_VALUES_TLP POATLP
        WHERE POATLP.po_line_id = gPoLineIds(i)
          AND POATLP.req_template_name = gPoReqTemplateNames(i)
          AND POATLP.req_template_line_num = to_char(gPoReqTemplateLineIds(i))
          AND POATLP.org_id = gPoOrgIds(i));

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of PO_ATTRIBUTE_VALUES_TLP rows inserted by default='||SQL%rowcount); END IF;

  l_progress := '030';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Inserting for item master items (pulling translations from INV)'); END IF;

  -- SQL What: Handle for Item master based documents. Pull translations
  --           from INV.
  -- SQL Why : Only those records that have gRecreateAttribTLPRow(i)='Y', need
  --           to be created in the Attributes table.
  -- SQL Join: several
  FORALL i in 1..gPoLineIds.COUNT
    INSERT INTO PO_ATTRIBUTE_VALUES_TLP
    (
      ATTRIBUTE_VALUES_TLP_ID,
      PO_LINE_ID,
      REQ_TEMPLATE_NAME,
      REQ_TEMPLATE_LINE_NUM,
      IP_CATEGORY_ID,
      INVENTORY_ITEM_ID,
      ORG_ID,
      LANGUAGE,
      DESCRIPTION,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      last_updated_program,
      LAST_UPDATE_DATE,
      CREATED_BY,
      CREATION_DATE
    )
    SELECT PO_ATTRIBUTE_VALUES_TLP_S.nextval,
           gPoLineIds(i),
           gPoReqTemplateNames(i), -- req_template_name
           gPoReqTemplateLineIds(i), -- req_template_line_id
           gIpCategoryIds(i), -- ip_category_id
           gInvItemIds(i), -- inventory_item_id
           gPoOrgIds(i), -- org_id
           mtl.language, -- Language
           -- For catalog language/base lang, the description is from PO Lines
           -- For the translations, the description is from items TL
           NVL(decode(mtl.language, p_base_lang, gItemDescriptions(i), mtl.description), mtl.description),  -- For null item_description, default from item master
           g_R12_UPGRADE_USER, -- last_updated_by
           g_R12_UPGRADE_USER, -- last_update_login
           g_R12_MIGRATION_PROGRAM, -- last_updated_program
           sysdate, -- last_update_date
           g_R12_UPGRADE_USER, -- created_by
           sysdate -- creation_date
    FROM MTL_SYSTEM_ITEMS_TL MTL, FINANCIALS_SYSTEM_PARAMS_ALL FSP
    WHERE gRecreateAttribTLPRow(i) = 'Y'
      AND gInvItemIds(i) <> NULL_ID -- Item master items
      AND gInvItemIds(i) = MTL.inventory_item_id
      AND gPoOrgIds(i)  = FSP.org_id
      AND FSP.inventory_organization_id = MTL.organization_id
      AND MTL.language = MTL.source_lang
      AND NOT EXISTS
      (SELECT /*+ INDEX(POATLP, PO_ATTRIBUTE_VALUES_TLP_U2) */
              NULL
        FROM PO_ATTRIBUTE_VALUES_TLP POATLP
        WHERE POATLP.language = MTL.language
          AND POATLP.po_line_id = gPoLineIds(i)
          AND POATLP.req_template_name = gPoReqTemplateNames(i)
          AND POATLP.req_template_line_num = to_char(gPoReqTemplateLineIds(i))
          AND POATLP.org_id = gPoOrgIds(i));

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of PO_ATTRIBUTE_VALUES_TLP rows inserted due to item master translation='||SQL%rowcount); END IF;

  l_progress := '040';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Inserting for item master items that have no translation available in base lang'); END IF;

  -- SQL What: Handle those item master record that dont have translation in
  --           the created_language of the Document header.
  -- SQL Why : We need to create a default row with language=created_language
  -- SQL Join: several
  --
  -- Assumption: Can we make the assumption or document that cst should not
  -- change the base language ? if so then we can always use the base language
  -- instead of joining with po_headers_all to get created_language.

  -- This sql#3 is used to create a default TLP row for the created_lang
  -- (only for Blankets/Quotations), if:
  -- 1. The created_lang is different from base_lang
  -- 2. The MTL translation for created_lang does not exist
  -- In this case, copy the description from the PO Line
  FORALL i in 1..gPoLineIds.COUNT
    INSERT INTO PO_ATTRIBUTE_VALUES_TLP
    (
      ATTRIBUTE_VALUES_TLP_ID,
      PO_LINE_ID,
      REQ_TEMPLATE_NAME,
      REQ_TEMPLATE_LINE_NUM,
      IP_CATEGORY_ID,
      INVENTORY_ITEM_ID,
      ORG_ID,
      LANGUAGE,
      DESCRIPTION,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      last_updated_program,
      LAST_UPDATE_DATE,
      CREATED_BY,
      CREATION_DATE
    )
    SELECT PO_ATTRIBUTE_VALUES_TLP_S.nextval,
           gPoLineIds(i),
           NULL_ID, --gPoReqTemplateNames(i), -- req_template_name
           NULL_ID, --gPoReqTemplateLineIds(i), -- req_template_line_id
           gIpCategoryIds(i), -- ip_category_id
           gInvItemIds(i), -- inventory_item_id
           gPoOrgIds(i), -- org_id
           POH.created_language, -- Language
           POL.item_description, -- item_description
           g_R12_UPGRADE_USER, -- last_updated_by
           g_R12_UPGRADE_USER, -- last_update_login
           g_R12_MIGRATION_PROGRAM, -- last_update_program
           sysdate, -- last_update_date
           g_R12_UPGRADE_USER, -- created_by
           sysdate -- creation_date
    FROM PO_HEADERS_ALL POH,
         PO_LINES_ALL POL
         --, PO_ATTRIBUTE_VALUES POAT
    WHERE gPoLineIds(i) <> NULL_ID
      AND gInvItemids(i) <> NULL_ID
      AND POL.po_line_id = gPoLineIds(i)
      AND POH.po_header_id = POL.po_header_id
      --AND POH.created_language <> p_base_lang (ECO bug 4862164)
      --AND POAT.po_line_id = POL.po_line_id -- make sure that the Attr row exists
      AND NOT EXISTS
      (SELECT /*+ INDEX(POATLP, PO_ATTRIBUTE_VALUES_TLP_U2) */
             'TLP row for created_lang already exists for Blanket/Quotation line'
        FROM PO_ATTRIBUTE_VALUES_TLP POATLP
        WHERE POATLP.language = POH.created_language
          AND POATLP.po_line_id = gPoLineIds(i));

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of PO_ATTRIBUTE_VALUES_TLP rows inserted due to nonexistence of item master in created_lang ='||SQL%rowcount); END IF;

  l_progress := '050';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END create_line_attributes_tlp;

--------------------------------------------------------------------------------
--Start of Comments
--Name: process_modified_rt_lines
--Pre-reqs:
--  The datamodel changes for Unified Catlog Upgrade should have been applied.
--Modifies:
--  a) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Create Attributes record for Req Templates
--  This API should be called during the upgrade phase only.
--Parameters:
--IN:
-- None
--OUT:
-- None
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE process_modified_rt_lines(p_batch_size IN NUMBER,
                                    p_base_lang  IN FND_LANGUAGES.language_code%TYPE)
IS
  -- SQL What: Cursor to get modified RT lines
  --           Whether to recreate the attribute/TLP record is based on
  --           what has changed - recreate only if iP_category_id/description/
  --           item_id has changed. Even if the PO category had changed but the
  --           mapped shopping category is the same as before, we wont recreate
  --           the attributes.
  --           NOTE: Keep the iP_category_id check as the
  --           first part of the decode, since we have some logic later for
  --           ip_category_id changes
  -- SQL Why : To update the attributes
  -- SQL Join: several
  CURSOR getModifiedTemplatesCsr IS
    SELECT NULL_ID,  -- PoLineId
           express_name, sequence_num, -- TemplateName, TemplateId
           NVL(ICXM.shopping_category_id, NULL_ID),
           NVL(PORL.item_id, NULL_ID), PORL.org_id, PORL.item_description,
           NULL, -- Image
           NULL, -- ImageUrl
           DECODE(
              NVL(ICXM.shopping_category_id, NULL_ID), POATLP.ip_category_id,
              DECODE(PORL.item_id, POATLP.inventory_item_id,
              DECODE(PORL.item_description, POATLP.description,
                NULL, 'DESCRIPTION'), 'ITEM_ID'), 'IP_CATEGORY_ID'), -- Attribute Modified
           DECODE(
              NVL(ICXM.shopping_category_id, NULL_ID), POATLP.ip_category_id,
              DECODE(PORL.item_id, POATLP.inventory_item_id,
              DECODE(PORL.item_description, POATLP.description,
                'N', 'Y'), 'Y'), 'Y'), --  Recreate Attribute
           DECODE(
              NVL(ICXM.shopping_category_id, NULL_ID), POATLP.ip_category_id,
              DECODE(PORL.item_id, POATLP.inventory_item_id,
              DECODE(PORL.item_description, POATLP.description,
                'N', 'Y'), 'Y'), 'Y') --  Recreate Attribute TLP
    FROM PO_REQEXPRESS_LINES_ALL PORL,
         PO_ATTRIBUTE_VALUES_TLP POATLP,
         ICX_CAT_PURCHASING_CAT_MAP_V ICXM
    WHERE PORL.last_updated_program = g_R12_MIGRATION_PROGRAM
      AND PORL.express_name = POATLP.req_template_name
      AND PORL.sequence_num  = POATLP.req_template_line_num
      AND PORL.org_id = POATLP.org_id
      AND PORL.last_update_date > POATLP.last_update_date
      AND (   NVL(PORL.item_id, NULL_ID) <> POATLP.inventory_item_id
           OR PORL.item_description <> POATLP.description)
      AND POATLP.language = p_base_lang
      AND PORL.CATEGORY_ID = ICXM.po_category_id(+)
    UNION ALL
    SELECT NULL_ID,  -- PoLineId
           express_name, sequence_num, -- TemplateName, TemplateId
           PORL.ip_category_id, -- iP Category Id
           NVL(PORL.item_id, NULL_ID), PORL.org_id, PORL.item_description,
           NULL, -- Image
           NULL, -- ImageUrl
           'ITEM_TRANSLATION', 'N','Y' -- Attribute, Recreate Attrib, Recreate Attrib TLP
    FROM PO_REQEXPRESS_LINES_ALL PORL,
         MTL_SYSTEM_ITEMS_TL MTL,
         FINANCIALS_SYSTEM_PARAMS_ALL FSP
    WHERE PORL.last_updated_program = g_R12_MIGRATION_PROGRAM
      AND item_id IS NOT NULL
      AND PORL.item_id = MTL.inventory_item_id  -- If item had changed then it would have been taken care by 'ITEM_ID' attribute change portion of this sql(it recreates the attributes)
      AND PORL.org_id = FSP.org_id
      AND FSP.inventory_organization_id = MTL.organization_id
      AND MTL.language = MTL.source_lang
      AND NOT EXISTS
      (
          SELECT 'Upgraded Lines with newly added item master translations'
          FROM   PO_ATTRIBUTE_VALUES_TLP POATLP
          WHERE POATLP.req_template_name <> to_char(NULL_ID) -- Only look for Template records
            AND PORL.express_name = POATLP.req_template_name
            AND PORL.sequence_num = POATLP.req_template_line_num
            AND PORL.org_id = POATLP.org_id
            AND PORL.item_id = MTL.inventory_item_id
            AND POATLP.language = MTL.language
      )
    UNION ALL
    SELECT NULL_ID,  -- PoLineId
           req_template_name, req_template_line_num, -- TemplateName, TemplateId
           ip_category_id, NVL(inventory_item_id, NULL_ID), org_id, null, -- description notneeded(null)
           NULL, -- Image
           NULL, -- ImageUrl
           'LINE_DELETED', 'N','N' -- Attribute, Recreate Attrib, Recreate Attrib TLP
    FROM PO_ATTRIBUTE_VALUES POAT
    WHERE req_template_line_num <> NULL_ID --Bug#4865650
      AND NOT EXISTS
      -- Req Template lines that have been deleted but have attribute reference
      -- (Need to be purged)
      (
          SELECT 'Req Template lines deleted'
          FROM  PO_REQEXPRESS_LINES_ALL PORL
          WHERE PORL.express_name = POAT.req_template_name
            AND PORL.sequence_num = POAT.req_template_line_num
            AND PORL.org_id = POAT.org_id
      );

  l_api_name      CONSTANT VARCHAR2(30) := 'process_modified_rt_lines';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_was_R12_upg_ever_run_before NUMBER := 0;
  l_current_batch NUMBER; -- Bug 5468308: Track the progress of the script
BEGIN
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  l_progress := '020';

  -- SQL What: If this is the first time the upgrade script has been run
  --           then directly run the procedure PROCESS_NEW_RT_LINES.
  -- SQL Why : The procedure PROCESS_MODIFIED_RT_LINES is applicable only
  --           for those lines that have been modified since the last upgrade.
  -- SQL Join: last_updated_program
  SELECT count(*)
    INTO l_was_R12_upg_ever_run_before
    FROM PO_REQEXPRESS_LINES_ALL PORL
   WHERE PORL.last_updated_program = g_R12_MIGRATION_PROGRAM
     AND rownum=1;

  l_progress := '030';

  IF (l_was_R12_upg_ever_run_before = 0) THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'early END'); END IF;
    RETURN;
  END IF;

  l_progress := '040';
  l_current_batch := 0;
  LOOP
    l_current_batch := l_current_batch + 1;
    -- The following exception occurs if we dont do this check for existence:
    --     ORA-06531: Reference to uninitialized collection.
    IF (gPoLineIds.exists(1)) THEN
      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Modified RTs; gPoLineIds.DELETE'); END IF;
      gPoLineIds.DELETE;
      gIpCategoryIds.DELETE;
      gInvItemIds.DELETE;
      gPoOrgIds.DELETE;
      gItemDescriptions.DELETE;
      gImages.DELETE;
      gImageUrls.DELETE;
      gUpdatedAttribute.DELETE;
      gRecreateAttribRow.DELETE;
      gRecreateAttribTLPRow.DELETE;
      gPoReqTemplateNames.DELETE;
      gPoReqTemplateLineIds.DELETE;
    END IF;

    -- Get the RT ids for which attribute rows need to be created
    l_progress := '050';
    OPEN getModifiedTemplatesCsr;

    l_progress := '060';
    -- Bug 5468308: Adding FND log messages at Unexpected level.
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, l_log_head||'.'||l_progress,
      'current_batch='||l_current_batch);
    END IF;

    FETCH getModifiedTemplatesCsr
      BULK COLLECT into gPoLineIds,
                        gPoReqTemplateNames, gPoReqTemplateLineIds,
                        gIpCategoryIds, gInvItemIds,
                        gPoOrgIds, gItemDescriptions,
                        gImages,
                        gImageUrls,
                        gUpdatedAttribute,
                        gRecreateAttribRow, gRecreateAttribTLPRow
      LIMIT p_batch_size;

    l_progress := '070';
    CLOSE getModifiedTemplatesCsr;

    l_progress := '080';
    EXIT WHEN gPoReqTemplateLineIds.COUNT = 0;

    l_progress := '090';

    -- SQL What: Update the PO_REQEXPRESS_LINES_ALL with ip_category_id
    -- SQL Why : Part of catalog upgrade requirements
    -- SQL Join: express_name, sequence_num, org_id
    -- We are specifically not updating the last_updated_by, login columns
    -- because we want to preserve that information(updating -2 to these
    -- columns is not useful when we already have the
    -- last_updated_program updated to  g_R12_MIGRATION_PROGRAM
    FORALL i IN 1..gPoReqTemplateLineIds.COUNT
      UPDATE PO_REQEXPRESS_LINES_ALL PORL
      SET ip_category_id = gIpCategoryIds(i),
          last_updated_program = g_R12_MIGRATION_PROGRAM
      WHERE PORL.express_name = gPoReqTemplateNames(i)
        AND PORL.sequence_num = to_char(gPoReqTemplateLineIds(i))
        AND PORL.org_id = gPoOrgIds(i)
        AND gUpdatedAttribute(i) = 'IP_CATEGORY_ID';

    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of PO_REQEXPRESS_LINES_ALL rows updated='||SQL%rowcount); END IF;

    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Deleting Attributes:Template'); END IF;

    l_progress := '100';
    -- SQL What: For item change erase the attributes
    -- SQL Why : Instead of erasing the columns, just delete the rows from
    --           attributes table and recreate the row later.
    -- SQL Join: express_name, sequence_num, org_id
    FORALL i IN 1..gPoLineIds.COUNT
      DELETE FROM PO_ATTRIBUTE_VALUES
      WHERE req_template_name = gPoReqTemplateNames(i)
        AND req_template_line_num = to_char(gPoReqTemplateLineIds(i))
        AND org_id = gPoOrgIds(i)
        AND (gRecreateAttribRow(i) = 'Y' OR gUpdatedAttribute(i) = 'LINE_DELETED');

    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of PO_ATTRIBUTE_VALUES rows deleted='||SQL%rowcount); END IF;

    l_progress := '110';

    -- SQL What: For item change erase the attributes ATLP
    -- SQL Why : Instead of erasing the columns, just delete the rows from
    --           attributes TLP table and recreate the row later.
    -- SQL Join: express_name, sequence_num, org_id
    FORALL i IN 1..gPoLineIds.COUNT
      DELETE FROM PO_ATTRIBUTE_VALUES_TLP
      WHERE req_template_name = gPoReqTemplateNames(i)
        AND req_template_line_num = to_char(gPoReqTemplateLineIds(i))
        AND org_id = gPoOrgIds(i)
        AND (gRecreateAttribTLPRow(i) = 'Y' OR gUpdatedAttribute(i) = 'LINE_DELETED');

    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of PO_ATTRIBUTE_VALUES_TLP rows deleted='||SQL%rowcount); END IF;

    l_progress := '120';

    -- SQL What: Update the PO attribute values TLP when the description has
    --           changed.
    -- SQL Why : Sync up the description
    -- SQL Join: express_name, sequence_num, org_id
    FORALL i in 1..gPoLineIds.COUNT
      UPDATE PO_ATTRIBUTE_VALUES_TLP
      SET description = gItemDescriptions(i),
          last_updated_program = g_R12_MIGRATION_PROGRAM
      WHERE req_template_name = gPoReqTemplateNames(i)
        AND req_template_line_num = to_char(gPoReqTemplateLineIds(i))
        AND org_id = gPoOrgIds(i)
        AND gUpdatedAttribute(i) = 'DESCRIPTION';

    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of PO_ATTRIBUTE_VALUES_TLP rows updated='||SQL%rowcount); END IF;

    l_progress := '130';

    -- Lines for which attributes records need to be created are in
    -- gPoReqTemplateNames/gPoReqTemplateLineIds tables
    CREATE_LINE_ATTRIBUTES(p_batch_size, p_base_lang);

    l_progress := '140';
    -- Lines for which attributes TLP records need to be created are in
    -- gPoReqTemplateNames/gPoReqTemplateLineIds tables
    CREATE_LINE_ATTRIBUTES_TLP(p_batch_size, p_base_lang);

    -- Commit after every batch
    COMMIT;
  END LOOP;

  l_progress := '150';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END process_modified_rt_lines;

--------------------------------------------------------------------------------
--Start of Comments
--Name: process_new_rt_lines
--Pre-reqs:
--  The datamodel changes for Unified Catlog Upgrade should have been applied.
--Modifies:
--  a) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Create Attributes record for Req Templates that have been created after
--  last run of the Pass 1 upgrade program.
--  This API should be called during the upgrade phase only.
--Parameters:
--IN:
-- None
--OUT:
-- None
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE process_new_rt_lines(p_batch_size IN NUMBER,
                               p_base_lang  IN FND_LANGUAGES.language_code%TYPE)
IS
  -- SQL What: Cursor to get RT lines that have not been upgraded
  -- SQL Why : To update the attributes
  -- SQL Join: last_updated_program
  CURSOR getNonUpgradedTemplatesCsr IS
   SELECT NULL_ID,  -- PoLineId
           express_name, sequence_num, -- TemplateName, TemplateId
           NVL(ICXM.SHOPPING_CATEGORY_ID, NULL_ID), -- ip_category_id
           NVL(PORL.item_id, NULL_ID), PORL.org_id, PORL.item_description,
           NULL, -- Image
           NULL, -- ImageUrl
           NULL, 'Y','Y' -- Attribute, Recreate Attrib, Recreate Attrib TLP
    FROM PO_REQEXPRESS_LINES_ALL PORL,
         ICX_CAT_PURCHASING_CAT_MAP_V ICXM
    WHERE last_updated_program is null
      AND PORL.CATEGORY_ID = ICXM.po_category_id(+) ;

  l_api_name      CONSTANT VARCHAR2(30) := 'process_new_rt_lines';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_current_batch NUMBER; -- Bug 5468308: Track the progress of the script
BEGIN
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  l_progress := '030';
  l_current_batch := 0;
  LOOP
    l_current_batch := l_current_batch + 1;

    -- The following exception occurs if we dont do this check for existence:
    --     ORA-06531: Reference to uninitialized collection.
    IF (gPoLineIds.exists(1)) THEN
      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'New RTs; gPoLineIds.DELETE'); END IF;
      gPoLineIds.DELETE;
      gIpCategoryIds.DELETE;
      gInvItemIds.DELETE;
      gPoOrgIds.DELETE;
      gItemDescriptions.DELETE;
      gImages.DELETE;
      gImageUrls.DELETE;
      gUpdatedAttribute.DELETE;
      gRecreateAttribRow.DELETE;
      gRecreateAttribTLPRow.DELETE;
      gPoReqTemplateNames.DELETE;
      gPoReqTemplateLineIds.DELETE;
    END IF;

    -- Get the Requisition Template Lines that have not been updated yet
    l_progress := '040';
    OPEN getNonUpgradedTemplatesCsr;

    l_progress := '050';
    -- Bug 5468308: Adding FND log messages at Unexpected level.
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, l_log_head||'.'||l_progress,
      'current_batch='||l_current_batch);
    END IF;

    FETCH getNonUpgradedTemplatesCsr
      BULK COLLECT into gPoLineIds,
                        gPoReqTemplateNames, gPoReqTemplateLineIds,
                        gIpCategoryIds, gInvItemIds,
                        gPoOrgIds, gItemDescriptions,
                        gImages,
                        gImageUrls,
                        gUpdatedAttribute,
                        gRecreateAttribRow, gRecreateAttribTLPRow
      LIMIT p_batch_size;

    l_progress := '060';
    CLOSE getNonUpgradedTemplatesCsr;

    l_progress := '070';
    EXIT WHEN gPoReqTemplateLineIds.COUNT = 0;

    l_progress := '080';

    -- SQL What: Update the PO_REQEXPRESS_LINES_ALL with ip_category_id
    -- SQL Why : Part of catalog upgrade requirements
    -- SQL Join: express_name, sequence_num, org_id
    -- We are specifically not updating the last_updated_by, login columns
    -- because we want to preserve that information(updating -2 to these
    -- columns is not useful when we already have the
    -- last_updated_program updated to  g_R12_MIGRATION_PROGRAM
    FORALL i IN 1..gPoReqTemplateLineIds.COUNT
      UPDATE PO_REQEXPRESS_LINES_ALL  PORL
      SET ip_category_id = gIpCategoryIds(i),
          last_updated_program = g_R12_MIGRATION_PROGRAM
      WHERE express_name = gPoReqTemplateNames(i)
        AND sequence_num = to_char(gPoReqTemplateLineIds(i))
        AND org_id = gPoOrgIds(i);

    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of PO_REQEXPRESS_LINES_ALL rows updated='||SQL%rowcount); END IF;

    l_progress := '090';

    -- Lines for which attributes need to be created are in gPoLineIds
    CREATE_LINE_ATTRIBUTES(p_batch_size, p_base_lang);

    l_progress := '100';
    -- Lines for which attributes TLP records need to be created are in gPoLineIds
    CREATE_LINE_ATTRIBUTES_TLP(p_batch_size, p_base_lang);

    l_progress := '110';
    -- Commit after every batch
    COMMIT;
  END LOOP;

  l_progress := '120';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END process_new_rt_lines;

/*
FUNCTION logAndReturnAudSid
  l_upgrade_job_number NUMBER;
  l_err_loc NUMBER;
begin
    l_err_loc := 100;
    SELECT NVL(MIN(job_number), 1)
    INTO   l_upgrade_job_number
    FROM   icx_cat_r12_upgrade_jobs;

    l_err_loc := 110;
    IF (l_upgrade_job_number > 0) THEN
      l_upgrade_job_number := ICX_CAT_UTIL_PVT.g_upgrade_user;
    ELSE
      l_upgrade_job_number := l_upgrade_job_number - 1;
    END IF;

    l_err_loc := 120;

end;
*/

--
-- Set debug on procedure - used only for debugging
--
PROCEDURE debug_profiles_on
IS
BEGIN
    FND_PROFILE.put('PO_SET_DEBUG_WORKFLOW_ON', 'Y');

    fnd_profile.put('AFLOG_ENABLED', 'Y');
    fnd_profile.put('AFLOG_MODULE', 'po.plsql.%,icx%'); -- note: comma-delimited list
    fnd_profile.put('AFLOG_LEVEL', 1);
    fnd_profile.put('AFLOG_FILENAME', '');
    fnd_log_repository.init;

END debug_profiles_on;


--------------------------------------------------------------------------------
--Start of Comments
--Name: upgrade_existing_docs
--Pre-reqs:
--  None: This is a dummy procedure(implementd for iP)
--Modifies:
--  None: This is a dummy procedure(implementd for iP)
--Locks:
--  None.
--Function:
--  Dummy API, since iP Maintains the same codeline for 11.5.10 and R12
--  they have the call to upgrade_existing_docs in the common code
--  In PO this functionality is implemented in poxujpoh.sql, poxukpol.sql and
--  poxukrt.sql. So we dont need to implement any logic for this API
--  in R12. Having it dummy so that the iP upgrade code will not throw
--  compilation error
--Parameters:
-- Not applicable: Dummy procedure
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE upgrade_existing_docs (
  p_batch_size    IN  NUMBER
, x_return_status OUT NOCOPY VARCHAR2)
IS
BEGIN
  -- Dummy API, since iP Maintains the same codeline for 11.5.10 and R12
  -- they have the call to upgrade_existing_docs in the common code
  -- In PO this functionality is implemented in poxujpoh.sql, poxukpol.sql and
  -- poxukrt.sql. So we dont need to implement any logic for this API
  -- in R12. Having it dummy so that the iP upgrade code will not throw
  -- compilation error
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END upgrade_existing_docs;

END PO_R12_CAT_UPG_EXISTING_DOCS;

/
