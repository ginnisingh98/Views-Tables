--------------------------------------------------------
--  DDL for Package Body GMD_QC_LABELS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_QC_LABELS_UTIL" AS
/*  $Header: GMDULABB.pls 120.5 2006/02/27 10:38:59 plowe noship $
 *****************************************************************
 *                                                               *
 * Package  GMD_QC_LABELS_UTIL                                   *
 *                                                               *
 * Contents SAMPLE_GEN_SRS                                       *
 *                                                               *
 * Use      This is the UTIL layer for generating QC labels      *
 *                                                               *
 * History                                                       *
 *         Written by H Verdding, OPM Development (EMEA)         *
 *         magupta, Changed it for stability study.              *
 *    01-JUN-2005 - J. DiIorio Changed for OPM Convergence.      *
 *     1) Changed fields to refer to their converged counterpart.*
 *        For example, changed                                   *
 *        p_orgn_code to p_organization_id.                      *
 *     2) Added cursors to convert ids to their display values.  *
 *     3) All changes identified by JD.                          *
 * 4) Saikiran Vankadari 10-Nov-05 Bug# 4612611                  *
 *     Removed plant_code and added Item, revsion and storage orgn*
 *                                                               *
 *****************************************************************
*/

--   Global variables

G_PKG_NAME           CONSTANT  VARCHAR2(30):='GMD_QC_LABELS_UTIL';

PROCEDURE SAMPLE_GEN_SRS
( errbuf            OUT NOCOPY VARCHAR2,
  retcode           OUT NOCOPY VARCHAR2,
  p_organization_id IN  NUMBER DEFAULT NULL,
  p_from_sample_no  IN  VARCHAR2 DEFAULT NULL,
  p_to_sample_no    IN  VARCHAR2 DEFAULT NULL,
  p_delimiter       IN  VARCHAR2 DEFAULT ',',
  p_variant_id      IN  NUMBER DEFAULT NULL,
  p_time_point_id   IN  NUMBER DEFAULT NULL
)
IS
l_sample_id    NUMBER;
l_delim        VARCHAR2(1);
l_priority     VARCHAR2(80);
l_retain_as    VARCHAR2(15);
l_source       VARCHAR2(80);
l_batch_no     VARCHAR2(32);
l_form_no      VARCHAR2(32);
l_form_vers    VARCHAR2(4);
l_oprn_no      VARCHAR2(16);
l_oprn_vers    VARCHAR2(5);
l_recipe_no    VARCHAR2(32);
l_recipe_vers  VARCHAR2(5);
l_routing_no   VARCHAR2(32);
l_routing_vers VARCHAR2(5);
l_cust_name    VARCHAR2(360);
l_oper_unit    VARCHAR2(60);
l_ship_to      VARCHAR2(40);
l_order_type   VARCHAR2(30);
l_order_no     NUMBER;
l_line_no      NUMBER;
l_supp_code    VARCHAR2(30);
l_supp_name    VARCHAR2(80);
l_supp_site    VARCHAR2(15);
l_po_no        VARCHAR2(20);
l_po_lineno    NUMBER;
l_rcpt_no      VARCHAR2(30);
l_rcpt_lineno  NUMBER;
l_total_lines  BINARY_INTEGER := 0;

  -- Bug 3088216: added retain as to select for cursor

  -- JD changed orgn_code to organization_id.
  --    replaced orgn_code to organization_id, sample_uom to sample_qty_uom,
  --    whse_code to subinventory, location to locator_id, lot_no to parent_lot_number,
  --    sublot_no to lot_number, qc_lab_orgn_code to lab_organization_id,
  --    storage_whse to storage_subinventory, storage_location to storage_locator_id.

CURSOR c_get_sample
IS
SELECT sample_id, source, organization_id, sample_no, sample_desc, inventory_item_id, revision, priority,
       sample_qty, sample_qty_uom, subinventory, locator_id, parent_lot_number, lot_number,
       lab_organization_id, expiration_date, lot_retest_ind, storage_organization_id, storage_subinventory,
       storage_locator_id, sample_instance,date_drawn, resources, instance_id,
       time_point_id, retain_as
FROM GMD_SAMPLES
WHERE ((p_organization_id IS NULL) OR (ORGANIZATION_ID = p_organization_id))
AND ((p_from_sample_no IS NULL) OR (sample_no between p_from_sample_no and p_to_sample_no))
AND ((p_variant_id IS NULL) OR (variant_id = p_variant_id))
AND ((p_time_point_id IS NULL ) OR (time_point_id = p_time_point_id))
ORDER BY 1
;

CURSOR c_get_priority ( p_priority VARCHAR2)
IS
SELECT meaning
FROM   GEM_LOOKUPS
WHERE  LOOKUP_TYPE = 'GMD_QC_TEST_PRIORITY'
AND    LOOKUP_CODE = p_priority;

CURSOR c_get_source ( p_source VARCHAR2)
IS
SELECT meaning
FROM   GEM_LOOKUPS
WHERE  LOOKUP_TYPE = 'GMD_QC_SOURCE'
AND    LOOKUP_CODE = p_source;

--JD changed plant_code to organization_id.

CURSOR c_get_batch_info ( p_sample_id NUMBER)
IS
SELECT /*organization_id, BUG# 4612611*/ batch_no, formula_no, formula_vers, oprn_no, oprn_vers,
       recipe_no, recipe_version, routing_no, routing_vers
FROM   GMD_QC_E_WIP_SAMPLE_DTLS_V
WHERE  sample_id = p_sample_id;

-- bug 4924550 sql id  16293559
CURSOR c_get_cust_info ( p_sample_id NUMBER)
IS
/*SELECT customer_name, operating_unit_name,
       ship_to_site_name, order_type,
       order_number, order_line_number
FROM   GMD_QC_E_CUST_SAMPLE_DTLS_V
WHERE  sample_id = p_sample_id; */


SELECT
  hzp.party_name customer_name ,
  hrou.NAME operating_unit_name,
  hzcsua.LOCATION ship_to_site_name ,
  oeoha.order_number order_number,
  oetrtyp.NAME order_type ,
  oeola.line_number order_line_number
FROM
  gmd_samples gsmp ,
  hz_parties hzp ,
  hz_cust_accounts_all hzca ,
  hr_all_organization_units_tl hrou ,
  HR_ORGANIZATION_INFORMATION O2,
  hz_cust_site_uses_all hzcsua ,
  oe_order_headers_all oeoha ,
  oe_transaction_types_tl oetrtyp ,
  oe_order_lines_all oeola
WHERE
  hzp.party_id = hzca.party_id AND
  hzca.cust_account_id = gsmp.cust_id AND
  hrou.organization_id(+) = gsmp.org_id AND
  O2.ORGANIZATION_ID = hrou.ORGANIZATION_ID AND
  O2.ORG_INFORMATION1 = 'OPERATING_UNIT' AND
  O2.ORG_INFORMATION2 = 'Y' AND
  hrou.language = userenv('LANG') AND
  hzcsua.site_use_id(+) = gsmp.ship_to_site_id AND
  oeoha.header_id(+) = gsmp.order_id AND
  oetrtyp.transaction_type_id(+) = oeoha.order_type_id AND
  oetrtyp.language = userenv('LANG') AND
  oeola.line_id(+) = gsmp.order_line_id AND
  gsmp.SOURCE = 'C' AND
  sample_id = p_sample_id;

-- bug 4924550 sql id  16293585
-- bug 5065199 sql id  16293585
CURSOR c_get_supp_info ( p_sample_id NUMBER)
IS
/*SELECT supplier_code, supplier_name,supplier_site,
       po_number, po_line_number, receipt_number,
       receipt_line_number
FROM   GMD_QC_E_SUPP_SAMPLE_DTLS_V
WHERE  sample_id = p_sample_id; */

SELECT
  povend.segment1 supplier_code ,
  povend.vendor_name supplier_name ,
  povendsites.vendor_site_code supplier_site ,
  pohdrall.segment1 po_number,
  polinesall.line_num po_line_number ,
  rcvshiphdr.receipt_num receipt_number ,
  rcvshiplines.line_num receipt_line_number
 FROM
  gmd_samples gsmp ,
  po_vendors povend ,
  po_vendor_sites_all povendsites ,
  po_headers_all pohdrall ,
  po_lines_all polinesall ,
  rcv_shipment_headers rcvshiphdr ,
  rcv_shipment_lines rcvshiplines ,
  hr_operating_units hrops ,
  mtl_parameters mp
WHERE
  gsmp.supplier_id = povend.vendor_id AND
  gsmp.supplier_site_id = povendsites.vendor_site_id(+) AND
  gsmp.po_header_id = pohdrall.po_header_id(+) AND
  gsmp.po_line_id = polinesall.po_line_id(+) AND
  gsmp.receipt_id = rcvshiphdr.shipment_header_id(+) AND
  gsmp.receipt_line_id = rcvshiplines.shipment_line_id(+) AND
  gsmp.SOURCE = 'S' AND
  hrops.organization_id = gsmp.org_id AND
  mp.organization_id = gsmp.organization_id
  and gsmp.sample_id = p_sample_id;


--Added for stability study
--JD changed orgn_code to organization_id.

CURSOR c_get_stbl_info ( p_sample_id NUMBER)
IS
SELECT f.organization_id, f.ss_no,c.spec_name item_spec, c.spec_vers item_spec_version,
       d.spec_name storage_spec, d.spec_vers storage_spec_version,
       a.variant_no, b.name time_interval_name, b.scheduled_date
FROM   GMD_SS_VARIANTS A, GMD_SS_TIME_POINTS B,
       GMD_SPECIFICATIONS_B C, GMD_SPECIFICATIONS D,
       GMD_SAMPLES E,GMD_STABILITY_STUDIES f
WHERE  e.sample_id = p_sample_id
AND    e.variant_id = p_variant_id
AND    e.time_point_id = b.time_point_id
AND    e.variant_id    = b.variant_id
AND    a.variant_id = b.variant_id
AND    b.spec_id = c.spec_id
AND    a.storage_spec_id = d.spec_id
AND    a.ss_id = f.ss_id;

--JD changed orgn_code to organization_id.

CURSOR c_get_stbl_retained ( p_sample_id NUMBER)
IS
SELECT f.organization_id, f.ss_no,c.spec_name item_spec, c.spec_vers item_spec_version,
       d.spec_name storage_spec, d.spec_vers storage_spec_version,
       a.variant_no, null time_interval_name, null scheduled_date --null for retained sample.
FROM   GMD_SS_VARIANTS A,
       GMD_SPECIFICATIONS_B C, GMD_SPECIFICATIONS D,
       GMD_SAMPLES E,GMD_STABILITY_STUDIES f
WHERE  e.sample_id = p_sample_id
AND    e.variant_id = p_variant_id
AND    e.variant_id    = a.variant_id
AND    a.default_spec_id = c.spec_id
AND    a.storage_spec_id = d.spec_id
AND    a.ss_id = f.ss_id;

c_stbl_row   c_get_stbl_info%ROWTYPE;
c_stbl_row_retain   c_get_stbl_retained%ROWTYPE;


--JD changed storage_whse_code to storage_subinventory.
--   changed storage_location to storage_locator_id.

CURSOR c_get_variant_storage IS
SELECT a.instance_number, b.resources, b.storage_organization_id, b.storage_subinventory, b.storage_locator_id
FROM GMP_RESOURCE_INSTANCES a, GMD_SS_VARIANTS B
WHERE a.INSTANCE_ID(+) = b.resource_instance_id
AND   b.variant_id = p_variant_id;
c_variant_storage_row  c_get_variant_storage%ROWTYPE;

--end for stability study

  -- Bug 3088216: added retain as to sample labels
CURSOR c_get_retain_as(p_retain_as VARCHAR2) IS
SELECT meaning
FROM   GEM_LOOKUPS
WHERE  LOOKUP_TYPE = 'GMD_QC_RETAIN_AS'
  AND  LOOKUP_CODE = p_retain_as;

--JD Added cursor to get orgn_code for display.

CURSOR get_orgn_code (v_organization_id  mtl_parameters.organization_id%TYPE) IS
SELECT organization_code
FROM   mtl_parameters
WHERE  organization_id = v_organization_id;

--BUG# 4612611. Added the cursor
CURSOR c_get_item (p_organization_id mtl_parameters.organization_id%TYPE, p_inventory_item_id mtl_system_items_b.inventory_item_id%TYPE) IS
SELECT concatenated_segments
FROM mtl_system_items_b_kfv
WHERE organization_id = p_organization_id
AND inventory_item_id = p_inventory_item_id;

l_sample_orgn_code       mtl_parameters.organization_code%TYPE;
l_lab_orgn_code          mtl_parameters.organization_code%TYPE;
l_stab_orgn_code         mtl_parameters.organization_code%TYPE;
l_stab_retain_orgn_code  mtl_parameters.organization_code%TYPE;
l_smpl_storage_orgn_code mtl_parameters.organization_code%TYPE; --BUG# 4612611
l_item_code              mtl_system_items_b_kfv.concatenated_segments%TYPE; --BUG# 4612611


-- JD Added cursor to get location for display.

CURSOR get_locator (v_locator_id  mtl_item_locations.inventory_location_id%TYPE) IS
SELECT segment1
FROM   mtl_item_locations
WHERE  inventory_location_id = v_locator_id;

l_segment1           mtl_item_locations.segment1%TYPE;
l_store_segment1     mtl_item_locations.segment1%TYPE;


NO_PARAMETERS_DEFINED EXCEPTION;
NO_SAMPLES_FOUND      EXCEPTION;

BEGIN
 --Start change for stability study
 -- JD changed orgn_code to organization_id.

 IF (p_variant_id IS NULL) THEN
   IF p_organization_id is NULL OR
      p_from_sample_no is NULL OR
      p_to_sample_no is NULL OR
      p_delimiter is NULL THEN
    RAISE NO_PARAMETERS_DEFINED;
   END IF;
 ELSIF p_time_point_id IS NULL  AND
       p_variant_id  IS NULL THEN
   RAISE NO_PARAMETERS_DEFINED;
 END IF;
 --End change for stability study.


 l_delim := p_delimiter;
 -- l_delim := ',';

 -- Define Static Headings

 FND_FILE.PUT(FND_FILE.OUTPUT,'ORGN CODE '|| l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'SAMPLE NO' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'SAMPLE DESC' || l_delim);
  -- FND_FILE.PUT(FND_FILE.OUTPUT,'SAMPLE DISPOSITION' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'SAMPLE QTY' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'SAMPLE UOM' || l_delim);
  -- Bug 3088216: added Retain As to headings
 FND_FILE.PUT(FND_FILE.OUTPUT,'RETAIN AS ' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'ITEM CODE ' || l_delim); --BUG# 4612611
 FND_FILE.PUT(FND_FILE.OUTPUT,'REVISION ' || l_delim);  --BUG# 4612611
 FND_FILE.PUT(FND_FILE.OUTPUT,'PRIORITY' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'SOURCE' || l_delim);
--JD
-- Changed label whse_code to subinventory.
-- Changed label location to locator.
-- Changed label lot_no to Parent_lot_number.
-- Changed label sublot_no to lot_number.

 FND_FILE.PUT(FND_FILE.OUTPUT,'SUBINVENTORY' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'LOCATOR' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'PARENT LOT NUMBER' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'LOT NUMBER' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'QC LAB ORGN' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'DATE DRAWN' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'EXPIRATION DATE' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'LOT RETEST IND' || l_delim);
--JD
-- Changed label storage_whse_code to storage_subinventory.
-- Changed label storage_location to storage_locator.
 FND_FILE.PUT(FND_FILE.OUTPUT,'STORAGE ORGN' || l_delim); --BUG# 4612611
 FND_FILE.PUT(FND_FILE.OUTPUT,'STORAGE SUBINVENTORY' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'STORAGE LOCATOR' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'RESOURCES' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'RESOURCE INSTANCE' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'SAMPLE INSTANCE' || l_delim);
 --FND_FILE.PUT(FND_FILE.OUTPUT,'PLANT CODE' || l_delim); --BUG# 4612611
 FND_FILE.PUT(FND_FILE.OUTPUT,'BATCH NO' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'FORMULA NO' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'FORMULA VERS' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'OPRN NO' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'OPRN VERS' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'RECIPE NO' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'RECIPE VERSION' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'ROUTING NO' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'ROUTING VERS' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'CUSTOMER NAME' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'OPERATING UNIT' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'SHIP TO SITE' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'ORDER TYPE ' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'ORDER NO  ' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'LINE NO  ' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'SUPPLIER CODE  ' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'SUPPLIER NAME  ' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'SUPPLIER SITE  ' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'PO NUMBER  ' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'PO LINE NUMBER  ' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'RECIEPT NUMBER  ' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'RECIEPT LINE NUMBER  ');

 --Added for stability study
 FND_FILE.PUT(FND_FILE.OUTPUT,'STABILITY STUDY ORGN  ' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'STABILTY STUDY NO  ' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'ITEM SPEC  ' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'ITEM SPEC VERS ' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'STORAGE SPEC ' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'STORAGE_SPEC_VERSION  ' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'VARIANT NUMBER  ' || l_delim);
 FND_FILE.PUT(FND_FILE.OUTPUT,'TIME INTERVAL NAME  ' || l_delim);
 FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'SCHEDULED START DATE  ' || l_delim);



 FOR samp in c_get_sample LOOP

    EXIT WHEN c_get_sample%NOTFOUND;

    -- JD convert sample organization_id to organization code for display.
    IF (samp.organization_id IS NOT NULL) THEN
       OPEN get_orgn_code(samp.organization_id);
       FETCH get_orgn_code INTO l_sample_orgn_code;
       IF (get_orgn_code%NOTFOUND) THEN
          l_sample_orgn_code := NULL;
       END IF;
       CLOSE get_orgn_code;
    ELSE
       l_sample_orgn_code := NULL;
    END IF;

    -- JD changed samp.orgn_code to l_sample_orgn_code.
    -- JD changed samp.sample_uom to samp.sample_qty_uom.

    FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||l_sample_orgn_code||   '"' || l_delim);
    FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||samp.sample_no||   '"' || l_delim);
    FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||samp.sample_desc|| '"' || l_delim);
    FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||samp.sample_qty||  '"' || l_delim);
    FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||samp.sample_qty_uom||  '"' || l_delim);
 --   FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||samp.sample_disposition|| '"' || l_delim);

      -- Bug 3088216: If retain as exists, get the value
    IF samp.retain_as IS NOT NULL THEN
       OPEN c_get_retain_as(samp.retain_as);
       FETCH c_get_retain_as INTO l_retain_as;
       CLOSE c_get_retain_as;
       FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||l_retain_as || '"' || l_delim);
    ELSE
       FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||samp.retain_as || '"' || l_delim);
    END IF;

    OPEN c_get_item(samp.organization_id, samp.inventory_item_id);  --BUG# 4612611
    FETCH c_get_item INTO l_item_code;
    CLOSE c_get_item;

    FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||l_item_code || '"' || l_delim); --BUG# 4612611
    FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||samp.revision || '"' || l_delim); --BUG# 4612611

    IF samp.priority is NOT NULL THEN
       OPEN c_get_priority(samp.priority);
        FETCH c_get_priority INTO l_priority;
       CLOSE c_get_priority;
       FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||l_priority || '"' || l_delim);
    ELSE
       FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||samp.priority || '"' || l_delim);
    END IF;

    IF samp.source is NOT NULL THEN
       OPEN c_get_source(samp.source);
        FETCH c_get_source INTO l_source;
       CLOSE c_get_source;
       FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||l_source || '"' || l_delim);
    ELSE
       FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||samp.source || '"' || l_delim);
    END IF;
--JD changed samp.whse_code to samp.subinventory.
--   Added cursor to get locator display value.
--   changed location to l_segment1.
--   changed lot_no to parent_lot_number.
--   changed sublot_no to lot_number.
--   changed qc_lab_orgn_code to l_lab_orgn_code.

    IF (samp.locator_id IS NOT NULL) THEN
       OPEN get_locator (samp.locator_id);
       FETCH get_locator INTO l_segment1;
       IF (get_locator%NOTFOUND) THEN
          l_segment1 := NULL;
       END IF;
       CLOSE get_locator;
    ELSE
       l_segment1 := NULL;
    END IF;

    -- JD convert qc_lab organization_id to lab_organization code for display.

    IF (samp.lab_organization_id IS NOT NULL) THEN
       OPEN get_orgn_code(samp.lab_organization_id);
       FETCH get_orgn_code INTO l_lab_orgn_code;
       IF (get_orgn_code%NOTFOUND) THEN
          l_lab_orgn_code := NULL;
       END IF;
       CLOSE get_orgn_code;
    ELSE
       l_lab_orgn_code := NULL;
    END IF;

    FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||samp.subinventory||   '"' || l_delim);
    FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||l_segment1||    '"' || l_delim);
    FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||samp.parent_lot_number||      '"' || l_delim);
    FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||samp.lot_number||   '"' || l_delim);
    FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||l_lab_orgn_code|| '"' || l_delim);
    FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||samp.date_drawn|| '"' || l_delim);
    FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||samp.expiration_date|| '"' || l_delim);
    FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||samp.lot_retest_ind|| '"' || l_delim);

    IF (samp.source ='T') THEN
      OPEN c_get_variant_storage;
      FETCH c_get_variant_storage into c_variant_storage_row;
      CLOSE c_get_variant_storage;

      IF (c_variant_storage_row.storage_organization_id IS NOT NULL) THEN --BUG# 4612611
        OPEN get_orgn_code(c_variant_storage_row.storage_organization_id);
        FETCH get_orgn_code INTO l_smpl_storage_orgn_code;
        CLOSE get_orgn_code;
      END IF;

      --   Added cursor to get locator display value.
      --   changed location to l_store_segment1.

      IF (c_variant_storage_row.storage_locator_id IS NOT NULL) THEN
         OPEN get_locator (c_variant_storage_row.storage_locator_id);
         FETCH get_locator INTO l_segment1;
         IF (get_locator%NOTFOUND) THEN
            l_store_segment1 := NULL;
         END IF;
         CLOSE get_locator;
      ELSE
         l_store_segment1 := NULL;
      END IF;

      FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||l_smpl_storage_orgn_code|| '"' || l_delim);  --BUG# 4612611
      FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||c_variant_storage_row.storage_subinventory|| '"' || l_delim);
      FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||l_store_segment1|| '"' || l_delim);
      FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||c_variant_storage_row.resources|| '"' || l_delim);
      FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||c_variant_storage_row.instance_number|| '"' || l_delim);

    ELSE

      IF (samp.storage_organization_id IS NOT NULL) THEN --BUG# 4612611
        OPEN get_orgn_code(samp.storage_organization_id);
        FETCH get_orgn_code INTO l_smpl_storage_orgn_code;
        CLOSE get_orgn_code;
      END IF;

      --  changed storage_location to l_segment1.
      --    changed storage_whse to storage_subinventory.

      IF (samp.storage_locator_id IS NOT NULL) THEN
         OPEN get_locator (samp.storage_locator_id);
         FETCH get_locator INTO l_segment1;
         CLOSE get_locator;
      END IF;

      FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||l_smpl_storage_orgn_code|| '"' || l_delim); --BUG# 4612611
      FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||samp.storage_subinventory|| '"' || l_delim);
      FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||l_segment1|| '"' || l_delim);
      FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||samp.resources|| '"' || l_delim);
      FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||samp.instance_id|| '"' || l_delim);
    END IF;

    FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||samp.sample_instance|| '"'  || l_delim);



    IF samp.source = 'W' THEN
       OPEN c_get_batch_info (samp.sample_id);
        FETCH c_get_batch_info INTO
           --l_plant_organization_id, --BUG# 4612611
           l_batch_no,
           l_form_no,
           l_form_vers,
           l_oprn_no,
           l_oprn_vers,
           l_recipe_no,
           l_recipe_vers,
           l_routing_no,
           l_routing_vers;
       CLOSE c_get_batch_info;



       --FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||l_plant_code|| '"' || l_delim);  --BUG# 4612611
       FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||l_batch_no||   '"' || l_delim);
       FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||l_form_no||    '"' || l_delim);
       FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||l_form_vers||  '"' || l_delim);
       FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||l_oprn_no||    '"' || l_delim);
       FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||l_oprn_vers||  '"' || l_delim);
       FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||l_recipe_no||  '"' || l_delim);
       FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||l_recipe_vers||'"' || l_delim);
       FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||l_routing_no|| '"' || l_delim);
       FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||l_routing_vers|| '"' || l_delim);
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- customer name
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- ship_to_site
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- order_type
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- order_no
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- line_no
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- supplier_code
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- supplier_name
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- supplier_site
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- po_number
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- po_line_number
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- reicpt_no
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "'); -- receipt_line_no

       --start for stability study
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "  ' || l_delim);  --stability study orgn
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim);   -- stability study no
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "  ' || l_delim);  --item spec
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim);   -- item spec vers
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim);    --storage spec
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim);  --storage_spec_version
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim);  --variant number
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim);  --time interval name
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim);  --scheduled start date
       --end for stability study






     ELSIF samp.source  = 'C' THEN
       OPEN c_get_cust_info (samp.sample_id);
        FETCH c_get_cust_info INTO
           l_cust_name,
           l_oper_unit,
           l_ship_to,
           l_order_type,
           l_order_no,
           l_line_no;
       CLOSE c_get_cust_info;
       --FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- plant_codce --BUG# 4612611
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- batch_no
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- formula_no
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- formula_vers
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- oprn_no
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- oprn_vers
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- recipe_no
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- recipe_vers
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- routing_no
       FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||l_cust_name||   '"' || l_delim);
       FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||l_oper_unit||   '"' || l_delim);
       FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||l_ship_to||     '"' || l_delim);
       FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||l_order_type||  '"' || l_delim);
       FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||l_order_no||    '"' || l_delim);
       FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||l_line_no||     '"' || l_delim);
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- supplier_code
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- supplier_name
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- supplier_site
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- po_number
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- po_line_number
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- reicpt_no
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "'); -- receipt_line_no


       --start for stability study
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "  ' || l_delim);  --stability study orgn
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim);   -- stability study no
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim);  --item spec
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim);   -- item spec vers
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim);    --storage spec
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim);  --storage_spec_version
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim);  --variant number
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim);  --time interval name
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim);  --scheduled start date
       --end for stability study

     ELSIF samp.source = 'S' THEN
       OPEN c_get_supp_info (samp.sample_id);
        FETCH c_get_supp_info INTO
           l_supp_code,
           l_supp_name,
           l_supp_site,
           l_po_no,
           l_po_lineno,
           l_rcpt_no,
           l_rcpt_lineno;

        CLOSE c_get_supp_info;
        --FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- plant_codce --BUG# 4612611
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- batch_no
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- plant_codce
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- plant_codce
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- formula_no
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- formula_vers
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- oprn_no
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- oprn_vers
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- recipe_no
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- recipe_vers
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- routing_no
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- routing_vers
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- customer name
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- ship_to_site
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- order_type
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- order_no
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- line_no
        FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||l_supp_code||   '"' || l_delim);
        FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||l_supp_name||   '"' || l_delim);
        FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||l_supp_site||   '"' || l_delim);
        FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||l_po_no||       '"' || l_delim);
        FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||l_po_lineno||   '"' || l_delim);
        FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||l_rcpt_no||     '"' || l_delim);
        FND_FILE.PUT(FND_FILE.OUTPUT,'"' ||l_rcpt_lineno|| '"');

               --start for stability study
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "  ' || l_delim);  --stability study orgn
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim);   -- stability study no
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim);  --item spec
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim);   -- item spec vers
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim);    --storage spec
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim);  --storage_spec_version
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim);  --variant number
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim);  --time interval name
       FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim);  --scheduled start date
       --end for stability study
     ELSIF samp.source = 'T' THEN
       IF (samp.time_point_id IS NOT NULL) THEN
         OPEN c_get_stbl_info (samp.sample_id);
         FETCH c_get_stbl_info INTO c_stbl_row;
         CLOSE c_get_stbl_info;
       ELSE
         OPEN c_get_stbl_retained(samp.sample_id);
         FETCH c_get_stbl_retained INTO c_stbl_row_retain;
         CLOSE c_get_stbl_retained;
       END IF;



        --FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- plant_codce --BUG# 4612611
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- batch_no
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- plant_codce
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- plant_codce
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- formula_no
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- formula_vers
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- oprn_no
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- oprn_vers
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- recipe_no
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- recipe_vers
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- routing_no
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- routing_vers
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- customer name
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- ship_to_site
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- order_type
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- order_no
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- line_no
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- supplier_code
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- supplier_name
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- supplier_site
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- po_number
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- po_line_number
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- reicpt_no
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "'); -- receipt_line_no

       IF (samp.time_point_id IS NOT NULL) THEN
         -- JD convert stab study organization_id to organization code for display.
         -- change c_stbl_row.orgn_code to l_stab_orgn_code.

         IF (c_stbl_row.organization_id IS NOT NULL) THEN
            OPEN get_orgn_code(c_stbl_row.organization_id);
            FETCH get_orgn_code INTO l_stab_orgn_code;
            IF (get_orgn_code%NOTFOUND) THEN
               l_stab_orgn_code := NULL;
            END IF;
            CLOSE get_orgn_code;
         ELSE
            l_stab_orgn_code := NULL;
         END IF;

         FND_FILE.PUT(FND_FILE.OUTPUT,'"'||l_stab_orgn_code ||'"' || l_delim);  --stability sudy orgn code
         FND_FILE.PUT(FND_FILE.OUTPUT,'"'||c_stbl_row.ss_no ||'"' || l_delim);   -- ss_no
         FND_FILE.PUT(FND_FILE.OUTPUT,'"'||c_stbl_row.item_spec ||'"' || l_delim);  --item spec
         FND_FILE.PUT(FND_FILE.OUTPUT,'"'||c_stbl_row.item_spec_version ||'"' || l_delim);   -- item spec vers
         FND_FILE.PUT(FND_FILE.OUTPUT,'"'||c_stbl_row.storage_spec ||'"' || l_delim);    --storage spec
         FND_FILE.PUT(FND_FILE.OUTPUT,'"'||c_stbl_row.storage_spec_version ||'"' || l_delim);  --storage_spec_version
         FND_FILE.PUT(FND_FILE.OUTPUT,'"'||c_stbl_row.variant_no ||'"' || l_delim);  --variant number
         FND_FILE.PUT(FND_FILE.OUTPUT,'"'||c_stbl_row.time_interval_name ||'"' || l_delim);  --time interval name
         FND_FILE.PUT(FND_FILE.OUTPUT,'"'||c_stbl_row.scheduled_date ||'"' || l_delim);  --scheduled start date
       ELSE
         -- JD convert retain ss organization_id to organization code for display.
         -- change c_stbl_row_retain.orgn_code to l_stab_orgn_code.

         IF (c_stbl_row_retain.organization_id IS NOT NULL) THEN
            OPEN get_orgn_code(c_stbl_row_retain.organization_id);
            FETCH get_orgn_code INTO l_stab_retain_orgn_code;
            IF (get_orgn_code%NOTFOUND) THEN
               l_stab_retain_orgn_code := NULL;
            END IF;
            CLOSE get_orgn_code;
         ELSE
            l_stab_retain_orgn_code := NULL;
         END IF;

         FND_FILE.PUT(FND_FILE.OUTPUT,'"'||l_stab_retain_orgn_code ||'"' || l_delim);  --stability sudy orgn code
         FND_FILE.PUT(FND_FILE.OUTPUT,'"'||c_stbl_row_retain.ss_no ||'"' || l_delim);   -- ss_no
         FND_FILE.PUT(FND_FILE.OUTPUT,'"'||c_stbl_row_retain.item_spec ||'"' || l_delim);  --item spec
         FND_FILE.PUT(FND_FILE.OUTPUT,'"'||c_stbl_row_retain.item_spec_version ||'"' || l_delim);   -- item spec vers
         FND_FILE.PUT(FND_FILE.OUTPUT,'"'||c_stbl_row_retain.storage_spec ||'"' || l_delim);    --storage spec
         FND_FILE.PUT(FND_FILE.OUTPUT,'"'||c_stbl_row_retain.storage_spec_version ||'"' || l_delim);  --storage_spec_version
         FND_FILE.PUT(FND_FILE.OUTPUT,'"'||c_stbl_row_retain.variant_no ||'"' || l_delim);  --variant number
         FND_FILE.PUT(FND_FILE.OUTPUT,'"'||c_stbl_row_retain.time_interval_name ||'"' || l_delim);  --time interval name
         FND_FILE.PUT(FND_FILE.OUTPUT,'"'||c_stbl_row_retain.scheduled_date ||'"' || l_delim);  --scheduled start date
       END IF;

     --end for stability study

     ELSE
        --FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- plant_codce --BUG# 4612611
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- batch_no
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- plant_codce
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- plant_codce
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- formula_no
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- formula_vers
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- oprn_no
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- oprn_vers
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- recipe_no
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- recipe_vers
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- routing_no
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- routing_vers
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- customer name
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- ship_to_site
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- order_type
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- order_no
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- line_no
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- supplier_code
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- supplier_name
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- supplier_site
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- po_number
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- po_line_number
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "' || l_delim); -- reicpt_no
        FND_FILE.PUT(FND_FILE.OUTPUT,'" "'); -- receipt_line_no
     END IF;

   l_total_lines := l_total_lines + 1.0;

   FND_FILE.NEW_LINE(FND_FILE.OUTPUT);

 END LOOP;

-- JD changed p_orgn_code to p_organization_id.

 IF l_total_lines = 0 THEN
     RAISE NO_SAMPLES_FOUND;
 ELSIF (p_organization_id IS NOT NULL) THEN
     FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
     FND_FILE.PUT_LINE(FND_FILE.LOG,' Please Check View/Output For Output ');
     FND_FILE.PUT_LINE(FND_FILE.LOG,'Total Samples Generated => ' || l_total_lines ||' For Input Values Defined ');
     FND_FILE.PUT_LINE(FND_FILE.LOG,'ORGANIZATION_ID   => ' || p_organization_id);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'FROM SAMPLE => ' || p_from_sample_no);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'TO SAMPLE   => ' || p_to_sample_no);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'DELIMITER   => ' || p_delimiter);
     FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
 ELSE
     FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
     FND_FILE.PUT_LINE(FND_FILE.LOG,' Please Check View/Output For Output ');
     FND_FILE.PUT_LINE(FND_FILE.LOG,'Total Samples Generated => ' || l_total_lines ||' For Input Values Defined ');
     FND_FILE.PUT_LINE(FND_FILE.LOG,'VARIANT_ID   => ' || p_variant_id);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'TIME_POINT_ID => ' || p_time_point_id);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'DELIMITER   => ' || p_delimiter);
     FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
 END IF;


EXCEPTION
-- JD changed p_orgn_code to p_organization_id.

WHEN NO_SAMPLES_FOUND THEN
         IF (p_organization_id IS NOT NULL) THEN
           FND_FILE.PUT_LINE(FND_FILE.LOG,'No sample records found for :');
           FND_FILE.PUT_LINE(FND_FILE.LOG,'ORGANIZATION_ID   => ' || p_organization_id);
           FND_FILE.PUT_LINE(FND_FILE.LOG,'FROM SAMPLE => ' || p_from_sample_no);
           FND_FILE.PUT_LINE(FND_FILE.LOG,'TO SAMPLE   => ' || p_to_sample_no);
           FND_FILE.PUT_LINE(FND_FILE.LOG,'DELIMITER   => ' || p_delimiter);
         ELSE
            FND_FILE.PUT_LINE(FND_FILE.LOG,'No sample records found for :');
            FND_FILE.PUT_LINE(FND_FILE.LOG,'VARIANT_ID   => ' || p_variant_id);
            FND_FILE.PUT_LINE(FND_FILE.LOG,'TIME_POINT_ID => ' || p_time_point_id);
            FND_FILE.PUT_LINE(FND_FILE.LOG,'DELIMITER   => ' || p_delimiter);
         END IF;



WHEN NO_PARAMETERS_DEFINED THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Required Parameters Missing :');
         FND_FILE.PUT_LINE(FND_FILE.LOG,'ORGANIZATION_ID   => ' || p_organization_id);
         FND_FILE.PUT_LINE(FND_FILE.LOG,'FROM SAMPLE => ' || p_from_sample_no);
         FND_FILE.PUT_LINE(FND_FILE.LOG,'TO SAMPLE   => ' || p_to_sample_no);
         FND_FILE.PUT_LINE(FND_FILE.LOG,'DELIMITER   => ' || p_delimiter);
WHEN OTHERS THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Concurrant Program Raised WHEN OTHERS EXCEPTION');

END SAMPLE_GEN_SRS;




END GMD_QC_LABELS_UTIL;

/
