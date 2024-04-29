--------------------------------------------------------
--  DDL for Package Body JL_ZZ_PO_LIBRARY_1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_PO_LIBRARY_1_PKG" AS
/* $Header: jlzzul1b.pls 120.1.12010000.2 2008/08/25 06:44:19 vspuli ship $ */

  PROCEDURE get_fcc_code (fcc_code_type IN     VARCHAR2,
                          tran_nat_type IN     VARCHAR2,
                          so_org_id     IN     VARCHAR2,
                          inv_item_id   IN     NUMBER,
                          fcc_code      IN OUT NOCOPY VARCHAR2,
                          tran_nat      IN OUT NOCOPY VARCHAR2,
                          row_number    IN     NUMBER,
                          Errcd         IN OUT NOCOPY NUMBER) IS
  BEGIN
    Errcd := 0;
    SELECT fcc.meaning,
           tn.meaning
    INTO   fcc_code,
           tran_nat
    FROM   mtl_system_items mtl, fnd_lookups fcc, fnd_lookups tn
    WHERE  fcc.lookup_code = SUBSTR (mtl.global_attribute1, 1, 25)
    AND    fcc.lookup_type = fcc_code_type
    AND    tn.lookup_code = SUBSTR (mtl.global_attribute2, 1, 25)
    AND    tn.lookup_type = tran_nat_type
    AND    mtl.organization_id = so_org_id
    AND    mtl.inventory_item_id = inv_item_id
    AND    rownum = row_number;
    EXCEPTION
      WHEN OTHERS THEN
        Errcd := SQLCODE;
  END get_fcc_code;


  PROCEDURE get_total_tax (po_header_id IN     NUMBER,
                           total_tax    IN OUT NOCOPY VARCHAR2,
                           row_number   IN     NUMBER,
                           Errcd        IN OUT NOCOPY NUMBER) IS
  BEGIN
    Errcd := 0;
    SELECT SUM (global_attribute6)
    INTO   total_tax
    FROM   po_line_locations_all
    WHERE  po_header_id = po_header_id
    AND    rownum = row_number;
    EXCEPTION
      WHEN OTHERS THEN
        Errcd := SQLCODE;
  END get_total_tax;


  PROCEDURE get_fc_code (form_org_id  IN     NUMBER,
                         form_item_id IN     NUMBER,
                         fc_code      IN OUT NOCOPY VARCHAR2,
                         row_number   IN     NUMBER,
                         Errcd        IN OUT NOCOPY NUMBER) IS
  BEGIN
    Errcd := 0;
    SELECT global_attribute1
    INTO   fc_code
    FROM   mtl_system_items mtl
    WHERE  mtl.organization_id = form_org_id
    AND    inventory_item_id = form_item_id
    AND    rownum = row_number;
    EXCEPTION
      WHEN OTHERS THEN
        Errcd := SQLCODE;
  END get_fc_code;


  PROCEDURE get_global_attributes (form_line_loca_id IN     NUMBER,
                                   ga1               IN OUT NOCOPY VARCHAR2,
                                   ga2               IN OUT NOCOPY VARCHAR2,
                                   ga3               IN OUT NOCOPY VARCHAR2,
                                   ga4               IN OUT NOCOPY VARCHAR2,
                                   ga5               IN OUT NOCOPY VARCHAR2,
                                   ga6               IN OUT NOCOPY VARCHAR2,
                                   row_number        IN     NUMBER,
                                   Errcd             IN OUT NOCOPY NUMBER) IS
  BEGIN
    Errcd := 0;
    SELECT global_attribute1, global_attribute2,
           global_attribute3, global_attribute4,
           global_attribute5, global_attribute6
    INTO   ga1, ga2, ga3, ga4, ga5, ga6
    FROM   po_line_locations_all
    WHERE  line_location_id = form_line_loca_id
    AND    rownum = row_number;
    EXCEPTION
      WHEN OTHERS THEN
        Errcd := SQLCODE;
  END get_global_attributes;


  PROCEDURE get_total_tax_for_release (po_header_id2  IN     NUMBER,
                                       po_release_id2 IN     NUMBER,
                                       total_tax      IN OUT NOCOPY VARCHAR2,
                                       row_number     IN     NUMBER,
                                       Errcd          IN OUT NOCOPY NUMBER) IS
  BEGIN
    Errcd := 0;
    SELECT SUM (global_attribute6)
    INTO   total_tax
    FROM   po_line_locations_all
    WHERE  po_header_id = po_header_id2
    AND    po_release_id = po_release_id2
    AND    rownum = row_number;
    EXCEPTION
      WHEN OTHERS THEN
        Errcd := SQLCODE;
  END get_total_tax_for_release;


  PROCEDURE get_context_name3 (global_description IN OUT NOCOPY VARCHAR2,
                               row_number         IN     NUMBER,
                               Errcd              IN OUT NOCOPY NUMBER) IS
  BEGIN
    Errcd := 0;
    SELECT SUBSTR (description, 1, 30)
    INTO   global_description
    FROM   fnd_descr_flex_contexts_vl
    WHERE  application_id = 7003
    AND    descriptive_flexfield_name  = 'JG_PO_SYSTEM_PARAMETERS'
    AND    descriptive_flex_context_code = 'JL.BR.POXSTDPO.PO_OPTIONS'
    AND    enabled_flag = 'Y'
    AND    rownum = row_number;
    EXCEPTION
      WHEN OTHERS THEN
        Errcd := SQLCODE;
  END get_context_name3;


  PROCEDURE get_trx_reason1 (org_id     IN     NUMBER,
                             item_id    IN     NUMBER,
                             trx_reason IN OUT NOCOPY VARCHAR2,
                             fcc        IN OUT NOCOPY VARCHAR2,
                             row_number IN     NUMBER,
                             Errcd      IN OUT NOCOPY NUMBER) IS
  BEGIN
    Errcd := 0;
    SELECT global_attribute2, global_attribute1
    INTO   trx_reason, fcc
    FROM   mtl_system_items mtl
    WHERE  mtl.organization_id = org_id
    AND    mtl.inventory_item_id = item_id
    AND    rownum = row_number;
    EXCEPTION
      WHEN OTHERS THEN
        Errcd := SQLCODE;
  END get_trx_reason1;


  PROCEDURE get_trx_reason2 (trx_reason IN OUT NOCOPY VARCHAR2,
                             row_number IN     NUMBER,
                             Errcd      IN OUT NOCOPY NUMBER) IS
  BEGIN
    Errcd := 0;
    SELECT global_attribute1
    INTO   trx_reason
    FROM   po_system_parameters
    WHERE    rownum = row_number;
    EXCEPTION
      WHEN OTHERS THEN
        Errcd := SQLCODE;
  END get_trx_reason2;


  PROCEDURE get_displayed_field (tran_code  IN     VARCHAR2,
                                 disp_field IN OUT NOCOPY VARCHAR2,
                                 row_number IN     NUMBER,
                                 Errcd      IN OUT NOCOPY NUMBER) IS
  BEGIN
    Errcd := 0;
    SELECT displayed_field
    INTO   disp_field
    FROM   po_lookup_codes
    WHERE  lookup_code = tran_code
    AND    rownum = row_number;
    EXCEPTION
      WHEN OTHERS THEN
        Errcd := SQLCODE;
  END get_displayed_field;


-----------------------------------------------------------------------
--  Added Bug: 7323242
--  PRIVATE PROCEDURE
--  get_trx_reason_def_rule
--
--  DESCRIPTION
--    This procedure gets transaction reason defaulting rule from PO Options
--    form to determine from which inventory org, local or master that
--    the value of transaction reason code should get from
--
PROCEDURE get_trx_reason_def_rule(
             p_org_id                 IN             PO_REQUISITION_LINES.ORG_ID%TYPE,
             p_trx_reason_def_rule        OUT NOCOPY PO_SYSTEM_PARAMETERS.GLOBAL_ATTRIBUTE3%TYPE,
             p_error_code                 OUT NOCOPY NUMBER)
IS

  CURSOR get_trx_reason_def_rule_mo_csr(
    c_org_id PO_SYSTEM_PARAMETERS.ORG_ID%TYPE)
  IS
    SELECT   global_attribute3
      FROM   PO_SYSTEM_PARAMETERS_ALL
      WHERE  org_id = c_org_id;

  CURSOR get_trx_reason_def_rule_so_csr
  IS
    SELECT   global_attribute3
      FROM   PO_SYSTEM_PARAMETERS_ALL;


BEGIN

  p_error_code := 0;

  IF p_org_id IS NULL THEN
    -- single org
    OPEN get_trx_reason_def_rule_so_csr;
    FETCH get_trx_reason_def_rule_so_csr INTO
      p_trx_reason_def_rule;
    CLOSE get_trx_reason_def_rule_so_csr;
  ELSE
    OPEN get_trx_reason_def_rule_mo_csr(p_org_id);
    FETCH get_trx_reason_def_rule_mo_csr INTO
      p_trx_reason_def_rule;
    CLOSE get_trx_reason_def_rule_mo_csr;
  END IF;


  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := SQLCODE;
      IF get_trx_reason_def_rule_so_csr%ISOPEN THEN
        CLOSE get_trx_reason_def_rule_so_csr;
      END IF;
      IF get_trx_reason_def_rule_mo_csr%ISOPEN THEN
        CLOSE get_trx_reason_def_rule_mo_csr;
      END IF;

END get_trx_reason_def_rule;


-----------------------------------------------------------------------
--  Added Bug: 7323242
--  PRIVATE PROCEDURE
--  get_trx_reason_from_po
--
--  DESCRIPTION
--    This procedure gets transaction reason code from po_system_parameters
--
PROCEDURE get_trx_reason_from_po(
             p_org_id          IN            PO_SYSTEM_PARAMETERS.ORG_ID%TYPE,
             p_trx_reason_code    OUT NOCOPY MTL_SYSTEM_ITEMS.GLOBAL_ATTRIBUTE2%TYPE,
             p_error_code         OUT NOCOPY NUMBER)
IS

  CURSOR get_trx_reason_code_so_csr
  IS
    SELECT   global_attribute1
      FROM   PO_SYSTEM_PARAMETERS_ALL;

  CURSOR get_trx_reason_code_mo_csr(
    c_org_id    PO_SYSTEM_PARAMETERS_ALL.ORG_ID%TYPE)
  IS
    SELECT   global_attribute1
      FROM   PO_SYSTEM_PARAMETERS_ALL
      WHERE  org_id = c_org_id;

BEGIN

  p_error_code := 0;

  IF p_org_id IS NULL THEN
    -- single org
    OPEN get_trx_reason_code_so_csr;
    FETCH get_trx_reason_code_so_csr INTO
      p_trx_reason_code;
    CLOSE get_trx_reason_code_so_csr;
  ELSE
    OPEN get_trx_reason_code_mo_csr(p_org_id);
    FETCH get_trx_reason_code_mo_csr INTO
      p_trx_reason_code;
    CLOSE get_trx_reason_code_mo_csr;
  END IF;


  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := SQLCODE;
      IF get_trx_reason_code_so_csr%ISOPEN THEN
        CLOSE get_trx_reason_code_so_csr;
      END IF;
      IF get_trx_reason_code_mo_csr%ISOPEN THEN
        CLOSE get_trx_reason_code_mo_csr;
      END IF;

END get_trx_reason_from_po;


  -----------------------------------------------------------------------
--  Added Bug: 7323242
--  PUBLIC PROCEDURE
--  get_trx_reason_cd_per_req_line
--
--  DESCRIPTION
--    This procedure is called from JL library, it gets the transaction
--    reason code from mtl_system_items based on a given item_id and the
--    organization that user specified from the Transaction Nature
--    Defaulting Rule GDF in PO Options form.  If no item is provided or
--    Transaction Reason code is not available from mtl_system_items for
--    the specified Local/Master inventory organization, the
--    Transaction Reason code from PO Options form will be returned

PROCEDURE get_trx_reason_cd_per_req_line(
               p_master_inv_org_id IN  MTL_SYSTEM_ITEMS.ORGANIZATION_ID%TYPE
             , p_inventory_org_id  IN  MTL_SYSTEM_ITEMS.ORGANIZATION_ID%TYPE
             , p_item_id           IN  MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID%TYPE
             , p_org_id            IN  PO_REQUISITION_LINES.ORG_ID%TYPE
             , x_trx_reason_code   OUT NOCOPY PO_REQUISITION_LINES.TRANSACTION_REASON_CODE%TYPE
             , x_error_code          OUT NOCOPY NUMBER)
IS

  l_trx_reason_def_rule   PO_SYSTEM_PARAMETERS.GLOBAL_ATTRIBUTE3%TYPE;
  l_def_from_org_id       NUMBER;
  l_fcc VARCHAR2(15);
BEGIN

  --
  -- init return transaction reason code
  --
  x_trx_reason_code := NULL;
  x_error_code := 0;

  IF p_item_id IS NOT NULL THEN
    --
    -- get transaction reason code from mtl system items if
    -- item is known.
    -- determine which organization to use from po system parameters
    --
    get_trx_reason_def_rule(
             p_org_id,
             l_trx_reason_def_rule,
             x_error_code);
    IF x_error_code <> 0 THEN
      RETURN;
    END IF;

    IF NVL(l_trx_reason_def_rule, 'MASTER INVENTORY ORGANIZATION')  = 'INVENTORY ORGANIZATION' THEN
      l_def_from_org_id := p_inventory_org_id;

      get_trx_reason1(
             l_def_from_org_id,
             p_item_id,
             x_trx_reason_code,
	     l_fcc,
	     1,
             x_error_code);

      IF x_error_code <> 0 THEN
        RETURN;
      END IF;
      IF x_trx_reason_code IS NULL THEN
        --
        -- try to get trx reason code based on
        -- master inventory org
        --
        l_def_from_org_id := p_master_inv_org_id;

        get_trx_reason1(
             l_def_from_org_id,
             p_item_id,
             x_trx_reason_code,
	     l_fcc,
	     1,
             x_error_code);

        IF (x_error_code <> 0  OR
            x_trx_reason_code IS NOT NULL) THEN
          --
          -- return if error occurs or
          -- trx reason code is found at Master org
          --
          RETURN;
        END IF;
      ELSE
        --
        -- found trx reason code based on local org
        --
        RETURN;
      END IF;
    ELSIF NVL(l_trx_reason_def_rule, 'MASTER INVENTORY ORGANIZATION') = 'MASTER INVENTORY ORGANIZATION' THEN
      l_def_from_org_id := p_master_inv_org_id;
        get_trx_reason1(
             l_def_from_org_id,
             p_item_id,
             x_trx_reason_code,
	     l_fcc,
	     1,
             x_error_code);
      IF (x_error_code <> 0  OR
          x_trx_reason_code IS NOT NULL) THEN
        --
        -- return if error occurs or
        -- trx reason code is found
        --
        RETURN;
      END IF;
    END IF;
  END IF;  -- of p_item_id is NOT NULL
  --
  -- get here then 1 of the following is true
  -- p_item_id is NULL or
  -- p_item_id is not NULL but trx reason code is
  -- not available for Local/Master org
  -- need to get trx reason code from
  -- PO system parameters
  --

  get_trx_reason_from_po(
             p_org_id,
             x_trx_reason_code,
             x_error_code);

END  get_trx_reason_cd_per_req_line;

END JL_ZZ_PO_LIBRARY_1_PKG;

/
