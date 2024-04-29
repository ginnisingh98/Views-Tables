--------------------------------------------------------
--  DDL for Package Body PO_ATTRIBUTE_VALUES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ATTRIBUTE_VALUES_PVT" AS
/* $Header: PO_ATTRIBUTE_VALUES_PVT.plb 120.30.12010000.15 2014/07/04 08:35:37 linlilin ship $ */

-- The module base for this package.
D_PACKAGE_BASE CONSTANT VARCHAR2(50) := PO_LOG.get_package_base('PO_ATTRIBUTE_VALUES_PVT');

-- The module base for the subprogram.
D_handle_attributes CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'handle_attributes');
D_set_attribute_values CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'set_attribute_values');
D_set_attribute_values_tlp CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'set_attribute_values_tlp');
D_transfer_intf_item_attribs CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'transfer_intf_item_attribs');
D_get_translations CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'get_translations');
D_get_tlp_ids_for_lines CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'get_tlp_ids_for_lines');
D_create_translations CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'create_translations');
D_create_default_attr_tlp CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'create_default_attr_tlp');
D_create_attributes_tlp_MI CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'create_attributes_tlp_MI');
D_create_default_attributes CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'create_default_attributes');
D_create_default_attributes_MI CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'create_default_attributes_MI');
D_gen_draft_line_translations CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'gen_draft_line_translations');
D_wipeout_category_attributes CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'wipeout_category_attributes');
D_update_attributes CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'update_attributes');
D_copy_attributes CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'copy_attributes');
D_get_ip_category_id CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'get_ip_category_id');
D_delete_attributes CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'delete_attributes');
D_delete_attributes_for_header CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'delete_attributes_for_header');
D_get_base_lang CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'get_base_lang');
D_get_item_attributes_values CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'get_item_attributes_values');
D_get_item_attributes_tlp CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'get_item_attributes_tlp_values');

TYPE PO_TBL_VARCHAR4 IS TABLE OF VARCHAR2(4) INDEX BY pls_integer;
TYPE PO_TBL_VARCHAR480 IS TABLE OF VARCHAR2(480) INDEX BY pls_integer;

-- iP defined value to signify NULL value
g_NOT_REQUIRED_ID CONSTANT NUMBER := -2;

g_base_language VARCHAR2(4) := get_base_lang();

-- cursor to select the non-translatable descriptors (type is 0 or 1) of
-- a particular category or base
CURSOR descriptors_csr
(
  p_category_id NUMBER,
  p_language  VARCHAR2
)
IS
SELECT attribute_id,
       attribute_name,
       type,
       rt_category_id,
       stored_in_table,
       stored_in_column,
       sequence
  FROM ICX_CAT_AGREEMENT_ATTRS_V -- replaced ICX_CAT_ATTRIBUTES_TL
 WHERE rt_category_id = p_category_id
   AND language = p_language
   AND type IN (0,1)
   AND stored_in_table = 'PO_ATTRIBUTE_VALUES'
ORDER BY attribute_id, stored_in_table;

-- cursor to select the translatable descriptors (type is 2) of
-- a particular category or base
CURSOR descriptors_tlp_csr
(
  p_category_id NUMBER,
  p_language VARCHAR2
)
IS
SELECT attribute_id,
       attribute_name,
       type,
       rt_category_id,
       stored_in_table,
       stored_in_column,
       sequence
  FROM ICX_CAT_AGREEMENT_ATTRS_V -- replaced ICX_CAT_ATTRIBUTES_TL
 WHERE rt_category_id = p_category_id
   AND language = p_language
   AND type = 2
   AND stored_in_table = 'PO_ATTRIBUTE_VALUES_TLP'
ORDER BY attribute_id, stored_in_table;

-- Cursor to select data from po_attribute_values
CURSOR attr_values_csr
(
  p_interface_header_id NUMBER,
  p_po_header_id NUMBER
)
IS
SELECT PAII.interface_line_number,
       PAV.*
  FROM PO_LINES_ALL POL,
       PO_ATTRIBUTE_VALUES PAV,
       PON_AUC_ITEMS_INTERFACE PAII
 WHERE POL.po_header_id = p_po_header_id
   AND POL.po_line_id = pav.po_line_id
   AND PAII.source_doc_id = p_po_header_id
   AND PAII.source_line_id = pol.po_line_id
   AND PAII.interface_auction_header_id = p_interface_header_id;

-- Cursor to select data from po_attribute_values_tlp
CURSOR attr_values_tlp_csr
(
  p_interface_header_id NUMBER,
  p_po_header_id NUMBER,
  p_language VARCHAR2
)
IS
SELECT PAII.interface_line_number,
       PAVT.*
  FROM PO_LINES_ALL POL,
       PO_ATTRIBUTE_VALUES_TLP PAVT,
       PON_AUC_ITEMS_INTERFACE PAII
 WHERE POL.po_header_id = p_po_header_id
   AND POL.po_line_id = pavt.po_line_id
   AND PAVT.language = p_language
   AND PAII.source_doc_id = p_po_header_id
   AND PAII.source_line_id = pol.po_line_id
   AND PAII.interface_auction_header_id = p_interface_header_id;

-- Cursor to select data from po_attribute_values
-- This is to facilitate callback from Sourcing in the req to negotiation flow
CURSOR pon_attr_values_csr
(
  p_auction_header_id NUMBER
) IS
SELECT PAIP.line_number,
       PAV.*
  FROM PON_AUCTION_ITEM_PRICES_ALL PAIP,
       ( SELECT PB.auction_header_id, PB.line_number, blanket_po_header_id, blanket_po_line_num
		 FROM PON_BACKING_REQUISITIONS PB, PO_REQUISITION_LINES_ALL PRL
		 WHERE PB.auction_header_id = p_auction_header_id
		   AND PB.requisition_header_id = PRL.requisition_header_id
		   AND PB.requisition_line_id = PRL.requisition_line_id
		   AND PRL.blanket_po_header_id IS NOT NULL
           AND PRL.blanket_po_line_num IS NOT NULL
		 GROUP BY  PB.auction_header_id,PB.line_number, blanket_po_header_id, blanket_po_line_num) PBR,
       PO_ATTRIBUTE_VALUES PAV,
       PO_LINES_ALL POL
 WHERE PAIP.auction_header_id = PBR.auction_header_id
   AND PAIP.line_number = PBR.line_number
   AND POL.po_header_id = PBR.blanket_po_header_id
   AND POL.line_num = PBR.blanket_po_line_num
   AND PAV.po_line_id = POL.po_line_id;

-- Cursor to select data from po_attribute_values
-- This is to facilitate callback from Sourcing in the req to negotiation flow
CURSOR pon_attr_values_tlp_csr
(
  p_auction_header_id NUMBER,
  p_language VARCHAR2
)
IS
SELECT PAIP.line_number,
       PAVT.*
  FROM PON_AUCTION_ITEM_PRICES_ALL PAIP,
       ( SELECT PB.auction_header_id, PB.line_number, blanket_po_header_id, blanket_po_line_num
		 FROM PON_BACKING_REQUISITIONS PB, PO_REQUISITION_LINES_ALL PRL
		 WHERE PB.auction_header_id = p_auction_header_id
		   AND PB.requisition_header_id = PRL.requisition_header_id
		   AND PB.requisition_line_id = PRL.requisition_line_id
		   AND PRL.blanket_po_header_id IS NOT NULL
           AND PRL.blanket_po_line_num IS NOT NULL
		 GROUP BY  PB.auction_header_id,PB.line_number, blanket_po_header_id, blanket_po_line_num) PBR,
       PO_ATTRIBUTE_VALUES_TLP PAVT,
       PO_LINES_ALL POL
 WHERE PAIP.auction_header_id = PBR.auction_header_id
   AND PAIP.line_number = PBR.line_number
   AND POL.po_header_id = PBR.blanket_po_header_id
   AND POL.line_num = PBR.blanket_po_line_num
   AND PAVT.po_line_id = POL.po_line_id
   AND PAVT.language = p_language;

TYPE attr_value_typ IS TABLE OF attr_values_csr%ROWTYPE INDEX BY PLS_INTEGER;
TYPE attr_value_tlp_typ IS TABLE OF attr_values_tlp_csr%ROWTYPE INDEX BY PLS_INTEGER;
TYPE descriptors_typ IS TABLE OF descriptors_csr%ROWTYPE INDEX BY PLS_INTEGER;
TYPE descriptors_tlp_typ IS TABLE OF descriptors_tlp_csr%ROWTYPE INDEX BY PLS_INTEGER;
TYPE pon_attributes_typ IS TABLE OF pon_attributes_interface%ROWTYPE INDEX BY PLS_INTEGER;

PROCEDURE set_attribute_values
(
  x_pon_attributes IN OUT NOCOPY pon_attributes_interface%ROWTYPE,
  x_attr_values IN OUT NOCOPY attr_values_csr%ROWTYPE,
  x_descriptors IN OUT NOCOPY descriptors_csr%ROWTYPE
);

PROCEDURE set_attribute_values_tlp
(
  x_pon_attributes IN OUT NOCOPY pon_attributes_interface%ROWTYPE,
  x_attr_values_tlp IN OUT NOCOPY attr_values_tlp_csr%ROWTYPE,
  x_descriptors_tlp IN OUT NOCOPY descriptors_tlp_csr%ROWTYPE
);




--------------------------------------------------------------------------------
--Start of Comments
--Name: handle_attributes
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  For Sourcing to PO flow.
--    Handles the descriptors.
--
--Parameters:
--IN:
--p_interface_header_id
--  The interface_header_id of the record that sourcing populates before
--  calling the autocreate backend API.
--p_po_header_id
--  The PO header for which the attribute and TLP rows need to be handled.
--p_language
--  The language for which the TLP rows need to be created
--OUT:
-- None
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE handle_attributes
(
  p_interface_header_id IN NUMBER
, p_po_header_id IN NUMBER DEFAULT NULL
, p_language IN VARCHAR2 DEFAULT NULL
)
IS
  d_mod CONSTANT VARCHAR2(100) := D_handle_attributes;
  l_progress      VARCHAR2(4);

  --variables for handling non-translatable attributes
  l_attr_values attr_value_typ;
  l_base_descriptors descriptors_typ;
  l_cat_descriptors descriptors_typ;

  --varialbes for handling translatable attributes
  l_attr_values_tlp attr_value_tlp_typ;
  l_base_descriptors_tlp descriptors_tlp_typ;
  l_cat_descriptors_tlp descriptors_tlp_typ;

  l_pon_attributes pon_attributes_typ;
  l_count NUMBER := 1;
  l_language ICX_CAT_AGREEMENT_ATTRS_V.LANGUAGE%TYPE;

BEGIN
  l_progress := '010';

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_interface_header_id',p_interface_header_id);
    PO_LOG.proc_begin(d_mod,'p_po_header_id',p_po_header_id);
    PO_LOG.proc_begin(d_mod,'p_language',p_language);
  END IF;

  -- If language is not passed in assume language of user session
  IF (p_language IS NULL) THEN
    l_language := userenv('LANG');
  ELSE
    l_language := p_language;
  END IF;

  l_progress := '020';
  -- fetch all non-translatable base descriptors information
  -- base descriptors have rt_category_id as 0. Hence pass in 0
  OPEN descriptors_csr(0,l_language);
  FETCH descriptors_csr
    BULK COLLECT INTO l_base_descriptors;
  ClOSE descriptors_csr;

  IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'l_base_descriptors.COUNT='||l_base_descriptors.COUNT); END IF;

  l_progress := '030';
  -- fetch all translatable base descriptors information
  -- base descriptors have rt_category_id as 0. Hence pass in 0
  OPEN descriptors_tlp_csr(0,l_language);
  FETCH descriptors_tlp_csr
    BULK COLLECT INTO l_base_descriptors_tlp;
  ClOSE descriptors_tlp_csr;

  IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'l_base_descriptors_tlp.COUNT='||l_base_descriptors_tlp.COUNT); END IF;

  l_progress := '040';
  -- if a specific PO header id is not passed in then
  -- Sourcing is in the req to negotiation flow
  -- use a different cursor to get all attribute values for many differnet PO blanket lines
  IF (p_po_header_id IS NULL) THEN
    l_progress := '050';
    OPEN pon_attr_values_csr(p_interface_header_id);
    FETCH pon_attr_values_csr
      BULK COLLECT INTO l_attr_values;
    CLOSE pon_attr_values_csr;
  ELSE
    l_progress := '060';
    OPEN attr_values_csr(p_interface_header_id, p_po_header_id);
    FETCH attr_values_csr
      BULK COLLECT INTO l_attr_values;
    CLOSE attr_values_csr;
  END IF;

  IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'l_attr_values.COUNT='||l_attr_values.COUNT); END IF;

  l_progress := '070';
  --for each attribute value record for this header loop through
  --and fetch base and category descriptor name, value and other
  --information required for sourcing
  FOR i IN 1..l_attr_values.COUNT --attribute values
  LOOP
    l_progress := '080';

    FOR j IN 1..l_base_descriptors.COUNT  --base descriptors
    LOOP
      l_progress := '090';
      l_pon_attributes(l_count).interface_auction_header_id := p_interface_header_id;

      l_progress := '100';
      set_attribute_values(x_pon_attributes => l_pon_attributes(l_count),
                           x_attr_values => l_attr_values(i),
                           x_descriptors => l_base_descriptors(j));

      l_count := l_count + 1;
    END LOOP; --base descriptors

    l_progress := '110';
    IF (l_attr_values(i).ip_category_id > 0) THEN  --for each ip_category
      l_progress := '120';

      -- fetch all non-translatable category descriptors information
      -- TODO there is an opportunity to cache the category descriptors as we fetch them
      OPEN descriptors_csr(l_attr_values(i).ip_category_id, l_language);
      FETCH descriptors_csr
        BULK COLLECT INTO l_cat_descriptors;
      ClOSE descriptors_csr;

      IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'l_cat_descriptors.COUNT='||l_cat_descriptors.COUNT); END IF;

      l_progress := '130';
      FOR j IN 1..l_cat_descriptors.COUNT --category descriptors
      LOOP
        l_progress := '140';
        l_pon_attributes(l_count).interface_auction_header_id := p_interface_header_id;

        l_progress := '150';
        set_attribute_values(x_pon_attributes => l_pon_attributes(l_count),
                             x_attr_values => l_attr_values(i),
                             x_descriptors => l_cat_descriptors(j));

        l_count := l_count + 1;
      END LOOP; --category descriptors
    END IF; --for each ip_category
  END LOOP; --attribute values

  IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'After set_attribute_values in loop'); END IF;

  l_progress := '160';
  -- if a specific PO header id is not passed in then
  -- Sourcing is in the req to negotiation flow
  -- use a different cursor to get all attribute values for many differnet PO blanket lines
  IF (p_po_header_id IS NULL) THEN
    l_progress := '170';
    OPEN pon_attr_values_tlp_csr(p_interface_header_id, l_language);
    FETCH pon_attr_values_tlp_csr
        BULK COLLECT INTO l_attr_values_tlp;
    CLOSE pon_attr_values_tlp_csr;
  ELSE
    l_progress := '180';
    OPEN attr_values_tlp_csr(p_interface_header_id, p_po_header_id, l_language);
    FETCH attr_values_tlp_csr
        BULK COLLECT INTO l_attr_values_tlp;
    CLOSE attr_values_tlp_csr;
  END IF;

  IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'l_attr_values_tlp.COUNT='||l_attr_values_tlp.COUNT); END IF;

  l_progress := '190';
  --for each attribute value tlp record for this header loop through
  --and fetch base and category descriptor name, tlp value and other
  --information required for sourcing
  FOR i IN 1..l_attr_values_tlp.COUNT --attribute values tlp
  LOOP
    l_progress := '200';

    FOR j IN 1..l_base_descriptors_tlp.COUNT  --base descriptors tlp
    LOOP
      l_progress := '210';
      l_pon_attributes(l_count).interface_auction_header_id := p_interface_header_id;

      l_progress := '220';
      set_attribute_values_tlp(x_pon_attributes => l_pon_attributes(l_count),
                               x_attr_values_tlp => l_attr_values_tlp(i),
                               x_descriptors_tlp => l_base_descriptors_tlp(j));
      l_count := l_count + 1;
    END LOOP; --base descriptors tlp


    l_progress := '230';
    IF (l_attr_values_tlp(i).ip_category_id > 0) THEN  -- for each ip_category
      l_progress := '240';
      -- fetch all translatable category descriptors information
      -- TODO there is an opportunity to cache the category descriptors as we fetch them
      OPEN descriptors_tlp_csr(l_attr_values_tlp(i).ip_category_id, l_language);
      FETCH descriptors_tlp_csr
        BULK COLLECT INTO l_cat_descriptors_tlp;
      ClOSE descriptors_tlp_csr;

      IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'l_cat_descriptors_tlp.COUNT='||l_cat_descriptors_tlp.COUNT); END IF;

      l_progress := '250';
      FOR j IN 1..l_cat_descriptors_tlp.COUNT --category descriptors tlp
      LOOP
        l_progress := '260';
        l_pon_attributes(l_count).interface_auction_header_id := p_interface_header_id;

        l_progress := '270';
        set_attribute_values_tlp(x_pon_attributes => l_pon_attributes(l_count),
                             x_attr_values_tlp => l_attr_values_tlp(i),
                             x_descriptors_tlp => l_cat_descriptors_tlp(j));
        l_count := l_count + 1;
      END LOOP; --category descriptors tlp
    END IF; --for each ip_category
  END LOOP; --attribute values tlp

  IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'After set_attribute_values_tlp in loop'); END IF;

  l_progress := '280';
  --insert data into pon_attributes_interface
  FORALL i IN 1..l_pon_attributes.COUNT
    INSERT INTO PON_ATTRIBUTES_INTERFACE VALUES l_pon_attributes(i);

  IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Number of rows inserted in PON_ATTRIBUTES_INTERFACE='||SQL%rowcount); END IF;

  IF PO_LOG.d_proc THEN PO_LOG.proc_end(d_mod); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN PO_LOG.exc(d_mod,l_progress,'Unhandled exception:'||SQLCODE || SQLERRM); END IF;
    RAISE;
END handle_attributes;

--------------------------------------------------------------------------------
--Start of Comments
--Name: set_attribute_values
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  For Sourcing to PO flow.
--    Transpose the attribute values from sourcing to PO.
--
--Parameters:
--IN/OUT:
--x_pon_attributes
--  A rows of PON_ATTRIBUTES_INTERFACE table carrying the attribute values
--x_attr_values
--  Attribute values cursor row type.
--x_descriptors
--  descriptors_csr row type
--OUT:
-- None
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE set_attribute_values
(
  x_pon_attributes IN OUT NOCOPY pon_attributes_interface%ROWTYPE
, x_attr_values IN OUT NOCOPY attr_values_csr%ROWTYPE
, x_descriptors IN OUT NOCOPY descriptors_csr%ROWTYPE
)
IS
  d_mod CONSTANT VARCHAR2(100) := D_set_attribute_values;
  l_progress     VARCHAR2(4);
BEGIN
  l_progress := '010';

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'x_attr_values.interface_line_number',x_attr_values.interface_line_number);
    PO_LOG.proc_begin(d_mod,'x_descriptors.sequence',x_descriptors.sequence);
    PO_LOG.proc_begin(d_mod,'x_descriptors.attribute_name',x_descriptors.attribute_name);
    PO_LOG.proc_begin(d_mod,'x_descriptors.rt_category_id',x_descriptors.rt_category_id);
    PO_LOG.proc_begin(d_mod,'x_descriptors.attribute_id',x_descriptors.attribute_id);
    PO_LOG.proc_begin(d_mod,'x_descriptors.type',x_descriptors.type);
    PO_LOG.proc_begin(d_mod,'x_descriptors.stored_in_column',x_descriptors.stored_in_column);
  END IF;

  --move data from descriptors and attribute values into x_pon_attributes
  x_pon_attributes.interface_line_number := x_attr_values.interface_line_number;
  x_pon_attributes.interface_sequence_number := x_descriptors.sequence;
  x_pon_attributes.attribute_name := x_descriptors.attribute_name;
  x_pon_attributes.ip_category_id := NVL(x_descriptors.rt_category_id, -2);  -- negative 2 means  no category
  x_pon_attributes.ip_descriptor_id := x_descriptors.attribute_id;

  --PON is expecting data type to be either TXT or NUM..minor conversion
  --0 is text, 1 is NUM and 2 is translatable text

  l_progress := '020';
  IF (x_descriptors.type IN (0,2)) THEN
    x_pon_attributes.datatype := 'TXT';
  ELSIF (x_descriptors.type = 1) THEN
    x_pon_attributes.datatype := 'NUM';
  END IF;

  IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'x_pon_attributes.datatype='||x_pon_attributes.datatype); END IF;

  l_progress := '030';
  IF (x_descriptors.stored_in_column = 'ATTACHMENT_URL') THEN
    x_pon_attributes.value := x_attr_values.ATTACHMENT_URL;
  ELSIF (x_descriptors.stored_in_column = 'ATTRIBUTE_VALUES_ID') THEN
    x_pon_attributes.value := x_attr_values.ATTRIBUTE_VALUES_ID;
  ELSIF (x_descriptors.stored_in_column = 'AVAILABILITY') THEN
    x_pon_attributes.value := x_attr_values.AVAILABILITY;
  ELSIF (x_descriptors.stored_in_column = 'CREATED_BY') THEN
    x_pon_attributes.value := x_attr_values.CREATED_BY;
  ELSIF (x_descriptors.stored_in_column = 'CREATION_DATE') THEN
    x_pon_attributes.value := x_attr_values.CREATION_DATE;
  ELSIF (x_descriptors.stored_in_column = 'INVENTORY_ITEM_ID') THEN
    x_pon_attributes.value := x_attr_values.INVENTORY_ITEM_ID;
  ELSIF (x_descriptors.stored_in_column = 'IP_CATEGORY_ID') THEN
    x_pon_attributes.value := x_attr_values.IP_CATEGORY_ID;
  ELSIF (x_descriptors.stored_in_column = 'LAST_UPDATED_BY') THEN
    x_pon_attributes.value := x_attr_values.LAST_UPDATED_BY;
  ELSIF (x_descriptors.stored_in_column = 'LAST_UPDATE_DATE') THEN
    x_pon_attributes.value := x_attr_values.LAST_UPDATE_DATE;
  ELSIF (x_descriptors.stored_in_column = 'LAST_UPDATE_LOGIN') THEN
    x_pon_attributes.value := x_attr_values.LAST_UPDATE_LOGIN;
  ELSIF (x_descriptors.stored_in_column = 'LEAD_TIME') THEN
    x_pon_attributes.value := x_attr_values.LEAD_TIME;
  ELSIF (x_descriptors.stored_in_column = 'MANUFACTURER_PART_NUM') THEN
    x_pon_attributes.value := x_attr_values.MANUFACTURER_PART_NUM;
  ELSIF (x_descriptors.stored_in_column = 'MANUFACTURER_URL') THEN
    x_pon_attributes.value := x_attr_values.MANUFACTURER_URL;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE1') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE1;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE10') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE10;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE100') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE100;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE11') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE11;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE12') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE12;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE13') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE13;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE14') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE14;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE15') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE15;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE16') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE16;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE17') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE17;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE18') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE18;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE19') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE19;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE2') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE2;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE20') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE20;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE21') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE21;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE22') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE22;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE23') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE23;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE24') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE24;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE25') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE25;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE26') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE26;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE27') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE27;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE28') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE28;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE29') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE29;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE3') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE3;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE30') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE30;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE31') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE31;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE32') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE32;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE33') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE33;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE34') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE34;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE35') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE35;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE36') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE36;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE37') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE37;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE38') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE38;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE39') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE39;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE4') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE4;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE40') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE40;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE41') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE41;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE42') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE42;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE43') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE43;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE44') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE44;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE45') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE45;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE46') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE46;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE47') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE47;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE48') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE48;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE49') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE49;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE5') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE5;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE50') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE50;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE51') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE51;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE52') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE52;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE53') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE53;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE54') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE54;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE55') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE55;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE56') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE56;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE57') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE57;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE58') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE58;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE59') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE59;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE6') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE6;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE60') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE60;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE61') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE61;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE62') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE62;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE63') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE63;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE64') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE64;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE65') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE65;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE66') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE66;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE67') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE67;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE68') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE68;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE69') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE69;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE7') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE7;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE70') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE70;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE71') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE71;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE72') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE72;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE73') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE73;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE74') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE74;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE75') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE75;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE76') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE76;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE77') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE77;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE78') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE78;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE79') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE79;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE8') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE8;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE80') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE80;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE81') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE81;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE82') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE82;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE83') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE83;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE84') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE84;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE85') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE85;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE86') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE86;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE87') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE87;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE88') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE88;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE89') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE89;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE9') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE9;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE90') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE90;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE91') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE91;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE92') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE92;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE93') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE93;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE94') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE94;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE95') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE95;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE96') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE96;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE97') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE97;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE98') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE98;
  ELSIF (x_descriptors.stored_in_column = 'NUM_BASE_ATTRIBUTE99') THEN
    x_pon_attributes.value := x_attr_values.NUM_BASE_ATTRIBUTE99;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE1') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE1;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE10') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE10;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE11') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE11;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE12') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE12;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE13') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE13;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE14') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE14;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE15') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE15;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE16') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE16;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE17') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE17;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE18') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE18;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE19') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE19;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE2') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE2;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE20') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE20;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE21') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE21;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE22') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE22;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE23') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE23;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE24') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE24;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE25') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE25;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE26') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE26;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE27') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE27;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE28') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE28;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE29') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE29;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE3') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE3;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE30') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE30;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE31') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE31;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE32') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE32;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE33') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE33;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE34') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE34;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE35') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE35;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE36') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE36;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE37') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE37;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE38') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE38;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE39') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE39;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE4') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE4;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE40') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE40;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE41') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE41;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE42') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE42;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE43') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE43;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE44') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE44;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE45') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE45;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE46') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE46;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE47') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE47;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE48') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE48;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE49') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE49;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE5') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE5;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE50') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE50;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE6') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE6;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE7') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE7;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE8') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE8;
  ELSIF (x_descriptors.stored_in_column = 'NUM_CAT_ATTRIBUTE9') THEN
    x_pon_attributes.value := x_attr_values.NUM_CAT_ATTRIBUTE9;
  ELSIF (x_descriptors.stored_in_column = 'ORG_ID') THEN
    x_pon_attributes.value := x_attr_values.ORG_ID;
  ELSIF (x_descriptors.stored_in_column = 'PICTURE') THEN
    x_pon_attributes.value := x_attr_values.PICTURE;
  ELSIF (x_descriptors.stored_in_column = 'PO_LINE_ID') THEN
    x_pon_attributes.value := x_attr_values.PO_LINE_ID;
  ELSIF (x_descriptors.stored_in_column = 'PROGRAM_APPLICATION_ID') THEN
    x_pon_attributes.value := x_attr_values.PROGRAM_APPLICATION_ID;
  ELSIF (x_descriptors.stored_in_column = 'PROGRAM_ID') THEN
    x_pon_attributes.value := x_attr_values.PROGRAM_ID;
  ELSIF (x_descriptors.stored_in_column = 'PROGRAM_UPDATE_DATE') THEN
    x_pon_attributes.value := x_attr_values.PROGRAM_UPDATE_DATE;
  ELSIF (x_descriptors.stored_in_column = 'REQUEST_ID') THEN
    x_pon_attributes.value := x_attr_values.REQUEST_ID;
  ELSIF (x_descriptors.stored_in_column = 'REQ_TEMPLATE_LINE_NUM') THEN
    x_pon_attributes.value := x_attr_values.REQ_TEMPLATE_LINE_NUM;
  ELSIF (x_descriptors.stored_in_column = 'REQ_TEMPLATE_NAME') THEN
    x_pon_attributes.value := x_attr_values.REQ_TEMPLATE_NAME;
  ELSIF (x_descriptors.stored_in_column = 'SUPPLIER_URL') THEN
    x_pon_attributes.value := x_attr_values.SUPPLIER_URL;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE1') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE1;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE10') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE10;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE100') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE100;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE11') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE11;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE12') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE12;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE13') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE13;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE14') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE14;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE15') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE15;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE16') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE16;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE17') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE17;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE18') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE18;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE19') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE19;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE2') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE2;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE20') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE20;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE21') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE21;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE22') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE22;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE23') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE23;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE24') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE24;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE25') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE25;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE26') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE26;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE27') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE27;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE28') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE28;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE29') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE29;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE3') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE3;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE30') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE30;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE31') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE31;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE32') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE32;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE33') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE33;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE34') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE34;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE35') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE35;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE36') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE36;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE37') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE37;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE38') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE38;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE39') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE39;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE4') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE4;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE40') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE40;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE41') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE41;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE42') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE42;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE43') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE43;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE44') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE44;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE45') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE45;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE46') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE46;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE47') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE47;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE48') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE48;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE49') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE49;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE5') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE5;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE50') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE50;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE51') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE51;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE52') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE52;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE53') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE53;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE54') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE54;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE55') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE55;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE56') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE56;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE57') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE57;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE58') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE58;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE59') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE59;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE6') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE6;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE60') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE60;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE61') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE61;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE62') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE62;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE63') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE63;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE64') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE64;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE65') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE65;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE66') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE66;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE67') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE67;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE68') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE68;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE69') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE69;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE7') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE7;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE70') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE70;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE71') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE71;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE72') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE72;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE73') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE73;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE74') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE74;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE75') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE75;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE76') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE76;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE77') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE77;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE78') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE78;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE79') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE79;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE8') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE8;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE80') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE80;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE81') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE81;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE82') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE82;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE83') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE83;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE84') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE84;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE85') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE85;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE86') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE86;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE87') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE87;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE88') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE88;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE89') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE89;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE9') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE9;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE90') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE90;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE91') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE91;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE92') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE92;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE93') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE93;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE94') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE94;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE95') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE95;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE96') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE96;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE97') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE97;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE98') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE98;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_BASE_ATTRIBUTE99') THEN
    x_pon_attributes.value := x_attr_values.TEXT_BASE_ATTRIBUTE99;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE1') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE1;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE10') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE10;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE11') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE11;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE12') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE12;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE13') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE13;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE14') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE14;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE15') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE15;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE16') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE16;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE17') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE17;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE18') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE18;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE19') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE19;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE2') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE2;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE20') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE20;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE21') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE21;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE22') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE22;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE23') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE23;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE24') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE24;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE25') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE25;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE26') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE26;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE27') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE27;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE28') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE28;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE29') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE29;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE3') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE3;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE30') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE30;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE31') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE31;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE32') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE32;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE33') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE33;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE34') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE34;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE35') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE35;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE36') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE36;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE37') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE37;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE38') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE38;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE39') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE39;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE4') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE4;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE40') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE40;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE41') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE41;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE42') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE42;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE43') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE43;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE44') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE44;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE45') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE45;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE46') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE46;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE47') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE47;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE48') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE48;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE49') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE49;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE5') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE5;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE50') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE50;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE6') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE6;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE7') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE7;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE8') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE8;
  ELSIF (x_descriptors.stored_in_column = 'TEXT_CAT_ATTRIBUTE9') THEN
    x_pon_attributes.value := x_attr_values.TEXT_CAT_ATTRIBUTE9;
  ELSIF (x_descriptors.stored_in_column = 'THUMBNAIL_IMAGE') THEN
    x_pon_attributes.value := x_attr_values.THUMBNAIL_IMAGE;
  ELSIF (x_descriptors.stored_in_column = 'UNSPSC') THEN
    x_pon_attributes.value := x_attr_values.UNSPSC;
  END IF;

  IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'x_pon_attributes.value='||x_pon_attributes.value); END IF;

  IF PO_LOG.d_proc THEN PO_LOG.proc_end(d_mod); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN PO_LOG.exc(d_mod,l_progress,'Unhandled exception:'||SQLCODE || SQLERRM); END IF;
    RAISE;
END set_attribute_values;

--------------------------------------------------------------------------------
--Start of Comments
--Name: set_attribute_values_tlp
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  For Sourcing to PO flow.
--    Transpose the attribute values TLP from sourcing to PO.
--
--Parameters:
--IN/OUT:
--x_pon_attributes
--  A rows of PON_ATTRIBUTES_INTERFACE table carrying the attribute values
--x_attr_values_tlp
--  Attribute values TLP cursor row type.
--x_descriptors_tlp
--  descriptors_tlp_csr row type
--OUT:
-- None
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE set_attribute_values_tlp
(
  x_pon_attributes IN OUT NOCOPY pon_attributes_interface%ROWTYPE
, x_attr_values_tlp IN OUT NOCOPY attr_values_tlp_csr%ROWTYPE
, x_descriptors_tlp IN OUT NOCOPY descriptors_tlp_csr%ROWTYPE
)
IS
  d_mod CONSTANT VARCHAR2(100) := D_set_attribute_values_tlp;
  l_progress     VARCHAR2(4);
BEGIN
  l_progress := '010';

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'x_attr_values_tlp.interface_line_number',x_attr_values_tlp.interface_line_number);
    PO_LOG.proc_begin(d_mod,'x_descriptors_tlp.sequence',x_descriptors_tlp.sequence);
    PO_LOG.proc_begin(d_mod,'x_descriptors_tlp.attribute_name',x_descriptors_tlp.attribute_name);
    PO_LOG.proc_begin(d_mod,'x_descriptors_tlp.rt_category_id',x_descriptors_tlp.rt_category_id);
    PO_LOG.proc_begin(d_mod,'x_descriptors_tlp.attribute_id',x_descriptors_tlp.attribute_id);
    PO_LOG.proc_begin(d_mod,'x_descriptors_tlp.type',x_descriptors_tlp.type);
    PO_LOG.proc_begin(d_mod,'x_descriptors_tlp.stored_in_column',x_descriptors_tlp.stored_in_column);
  END IF;

  --move data from descriptors and attribute values into x_pon_attributes
  x_pon_attributes.interface_line_number := x_attr_values_tlp.interface_line_number;
  x_pon_attributes.interface_sequence_number := x_descriptors_tlp.sequence;
  x_pon_attributes.attribute_name := x_descriptors_tlp.attribute_name;
  x_pon_attributes.ip_category_id := NVL(x_descriptors_tlp.rt_category_id, -2);  -- negative 2 means  no category
  x_pon_attributes.ip_descriptor_id := x_descriptors_tlp.attribute_id;

  l_progress := '020';
  --PON is expecting data type to be either TXT or NUM..minor conversion
  --0 is text, 1 is NUM and 2 is translatable text
  IF (x_descriptors_tlp.type IN (0,2)) THEN
    x_pon_attributes.datatype := 'TXT';
  ELSIF (x_descriptors_tlp.type = 1) THEN
    x_pon_attributes.datatype := 'NUM';
  END IF;

  IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'x_pon_attributes.datatype='||x_pon_attributes.datatype); END IF;

  l_progress := '030';
  IF (x_descriptors_tlp.stored_in_column = 'ALIAS') THEN
    x_pon_attributes.value := x_attr_values_tlp.ALIAS;
  ELSIF (x_descriptors_tlp.stored_in_column = 'ATTRIBUTE_VALUES_TLP_ID') THEN
    x_pon_attributes.value := x_attr_values_tlp.ATTRIBUTE_VALUES_TLP_ID;
  ELSIF (x_descriptors_tlp.stored_in_column = 'COMMENTS') THEN
    x_pon_attributes.value := x_attr_values_tlp.COMMENTS;
  ELSIF (x_descriptors_tlp.stored_in_column = 'CREATED_BY') THEN
    x_pon_attributes.value := x_attr_values_tlp.CREATED_BY;
  ELSIF (x_descriptors_tlp.stored_in_column = 'CREATION_DATE') THEN
    x_pon_attributes.value := x_attr_values_tlp.CREATION_DATE;
  ELSIF (x_descriptors_tlp.stored_in_column = 'DESCRIPTION') THEN
    x_pon_attributes.value := x_attr_values_tlp.DESCRIPTION;
  ELSIF (x_descriptors_tlp.stored_in_column = 'INVENTORY_ITEM_ID') THEN
    x_pon_attributes.value := x_attr_values_tlp.INVENTORY_ITEM_ID;
  ELSIF (x_descriptors_tlp.stored_in_column = 'IP_CATEGORY_ID') THEN
    x_pon_attributes.value := x_attr_values_tlp.IP_CATEGORY_ID;
  ELSIF (x_descriptors_tlp.stored_in_column = 'LANGUAGE') THEN
    x_pon_attributes.value := x_attr_values_tlp.LANGUAGE;
  ELSIF (x_descriptors_tlp.stored_in_column = 'LAST_UPDATED_BY') THEN
    x_pon_attributes.value := x_attr_values_tlp.LAST_UPDATED_BY;
  ELSIF (x_descriptors_tlp.stored_in_column = 'LAST_UPDATE_DATE') THEN
    x_pon_attributes.value := x_attr_values_tlp.LAST_UPDATE_DATE;
  ELSIF (x_descriptors_tlp.stored_in_column = 'LAST_UPDATE_LOGIN') THEN
    x_pon_attributes.value := x_attr_values_tlp.LAST_UPDATE_LOGIN;
  ELSIF (x_descriptors_tlp.stored_in_column = 'LONG_DESCRIPTION') THEN
    x_pon_attributes.value := x_attr_values_tlp.LONG_DESCRIPTION;
  ELSIF (x_descriptors_tlp.stored_in_column = 'MANUFACTURER') THEN
    x_pon_attributes.value := x_attr_values_tlp.MANUFACTURER;
  ELSIF (x_descriptors_tlp.stored_in_column = 'ORG_ID') THEN
    x_pon_attributes.value := x_attr_values_tlp.ORG_ID;
  ELSIF (x_descriptors_tlp.stored_in_column = 'PO_LINE_ID') THEN
    x_pon_attributes.value := x_attr_values_tlp.PO_LINE_ID;
  ELSIF (x_descriptors_tlp.stored_in_column = 'PROGRAM_APPLICATION_ID') THEN
    x_pon_attributes.value := x_attr_values_tlp.PROGRAM_APPLICATION_ID;
  ELSIF (x_descriptors_tlp.stored_in_column = 'PROGRAM_ID') THEN
    x_pon_attributes.value := x_attr_values_tlp.PROGRAM_ID;
  ELSIF (x_descriptors_tlp.stored_in_column = 'PROGRAM_UPDATE_DATE') THEN
    x_pon_attributes.value := x_attr_values_tlp.PROGRAM_UPDATE_DATE;
  ELSIF (x_descriptors_tlp.stored_in_column = 'REQUEST_ID') THEN
    x_pon_attributes.value := x_attr_values_tlp.REQUEST_ID;
  ELSIF (x_descriptors_tlp.stored_in_column = 'REQ_TEMPLATE_LINE_NUM') THEN
    x_pon_attributes.value := x_attr_values_tlp.REQ_TEMPLATE_LINE_NUM;
  ELSIF (x_descriptors_tlp.stored_in_column = 'REQ_TEMPLATE_NAME') THEN
    x_pon_attributes.value := x_attr_values_tlp.REQ_TEMPLATE_NAME;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE1') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE1;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE10') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE10;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE100') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE100;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE11') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE11;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE12') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE12;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE13') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE13;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE14') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE14;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE15') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE15;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE16') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE16;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE17') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE17;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE18') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE18;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE19') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE19;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE2') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE2;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE20') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE20;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE21') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE21;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE22') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE22;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE23') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE23;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE24') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE24;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE25') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE25;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE26') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE26;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE27') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE27;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE28') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE28;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE29') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE29;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE3') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE3;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE30') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE30;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE31') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE31;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE32') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE32;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE33') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE33;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE34') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE34;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE35') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE35;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE36') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE36;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE37') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE37;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE38') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE38;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE39') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE39;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE4') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE4;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE40') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE40;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE41') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE41;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE42') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE42;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE43') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE43;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE44') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE44;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE45') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE45;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE46') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE46;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE47') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE47;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE48') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE48;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE49') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE49;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE5') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE5;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE50') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE50;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE51') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE51;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE52') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE52;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE53') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE53;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE54') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE54;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE55') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE55;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE56') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE56;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE57') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE57;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE58') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE58;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE59') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE59;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE6') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE6;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE60') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE60;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE61') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE61;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE62') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE62;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE63') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE63;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE64') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE64;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE65') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE65;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE66') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE66;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE67') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE67;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE68') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE68;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE69') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE69;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE7') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE7;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE70') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE70;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE71') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE71;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE72') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE72;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE73') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE73;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE74') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE74;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE75') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE75;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE76') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE76;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE77') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE77;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE78') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE78;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE79') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE79;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE8') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE8;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE80') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE80;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE81') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE81;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE82') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE82;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE83') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE83;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE84') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE84;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE85') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE85;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE86') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE86;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE87') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE87;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE88') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE88;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE89') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE89;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE9') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE9;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE90') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE90;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE91') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE91;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE92') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE92;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE93') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE93;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE94') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE94;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE95') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE95;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE96') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE96;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE97') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE97;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE98') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE98;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_BASE_ATTRIBUTE99') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_BASE_ATTRIBUTE99;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE1') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE1;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE10') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE10;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE11') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE11;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE12') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE12;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE13') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE13;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE14') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE14;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE15') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE15;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE16') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE16;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE17') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE17;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE18') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE18;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE19') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE19;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE2') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE2;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE20') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE20;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE21') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE21;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE22') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE22;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE23') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE23;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE24') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE24;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE25') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE25;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE26') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE26;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE27') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE27;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE28') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE28;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE29') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE29;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE3') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE3;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE30') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE30;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE31') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE31;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE32') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE32;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE33') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE33;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE34') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE34;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE35') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE35;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE36') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE36;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE37') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE37;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE38') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE38;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE39') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE39;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE4') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE4;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE40') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE40;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE41') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE41;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE42') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE42;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE43') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE43;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE44') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE44;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE45') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE45;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE46') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE46;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE47') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE47;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE48') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE48;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE49') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE49;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE5') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE5;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE50') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE50;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE6') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE6;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE7') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE7;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE8') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE8;
  ELSIF (x_descriptors_tlp.stored_in_column = 'TL_TEXT_CAT_ATTRIBUTE9') THEN
    x_pon_attributes.value := x_attr_values_tlp.TL_TEXT_CAT_ATTRIBUTE9;
  END IF;

  IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'x_pon_attributes.value='||x_pon_attributes.value); END IF;

  IF PO_LOG.d_proc THEN PO_LOG.proc_end(d_mod); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN PO_LOG.exc(d_mod,l_progress,'Unhandled exception:'||SQLCODE || SQLERRM); END IF;
    RAISE;
END set_attribute_values_tlp;

--------------------------------------------------------------------------------
--Start of Comments
--Name: transfer_intf_item_attribs
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  For Sourcing to PO flow.
--    Create Attribute Values
--
--Parameters:
--IN:
--p_interface_header_id
--  The interface_header_id of the record populated by Sourcing before calling
--  the PO autocreate backend.
--OUT:
-- None
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE transfer_intf_item_attribs
(
  p_interface_header_id IN NUMBER
)
IS
  d_mod CONSTANT VARCHAR2(100) := D_transfer_intf_item_attribs;
  l_progress     VARCHAR2(4);
BEGIN
  l_progress := '010';

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_interface_header_id',p_interface_header_id);
  END IF;

  l_progress := '020';
  INSERT INTO PO_ATTRIBUTE_VALUES (
    ATTACHMENT_URL,
    ATTRIBUTE_VALUES_ID,
    AVAILABILITY,
    CREATED_BY,
    CREATION_DATE,
    INVENTORY_ITEM_ID,
    IP_CATEGORY_ID,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LEAD_TIME,
    MANUFACTURER_PART_NUM,
    MANUFACTURER_URL,
    NUM_BASE_ATTRIBUTE1,
    NUM_BASE_ATTRIBUTE10,
    NUM_BASE_ATTRIBUTE100,
    NUM_BASE_ATTRIBUTE11,
    NUM_BASE_ATTRIBUTE12,
    NUM_BASE_ATTRIBUTE13,
    NUM_BASE_ATTRIBUTE14,
    NUM_BASE_ATTRIBUTE15,
    NUM_BASE_ATTRIBUTE16,
    NUM_BASE_ATTRIBUTE17,
    NUM_BASE_ATTRIBUTE18,
    NUM_BASE_ATTRIBUTE19,
    NUM_BASE_ATTRIBUTE2,
    NUM_BASE_ATTRIBUTE20,
    NUM_BASE_ATTRIBUTE21,
    NUM_BASE_ATTRIBUTE22,
    NUM_BASE_ATTRIBUTE23,
    NUM_BASE_ATTRIBUTE24,
    NUM_BASE_ATTRIBUTE25,
    NUM_BASE_ATTRIBUTE26,
    NUM_BASE_ATTRIBUTE27,
    NUM_BASE_ATTRIBUTE28,
    NUM_BASE_ATTRIBUTE29,
    NUM_BASE_ATTRIBUTE3,
    NUM_BASE_ATTRIBUTE30,
    NUM_BASE_ATTRIBUTE31,
    NUM_BASE_ATTRIBUTE32,
    NUM_BASE_ATTRIBUTE33,
    NUM_BASE_ATTRIBUTE34,
    NUM_BASE_ATTRIBUTE35,
    NUM_BASE_ATTRIBUTE36,
    NUM_BASE_ATTRIBUTE37,
    NUM_BASE_ATTRIBUTE38,
    NUM_BASE_ATTRIBUTE39,
    NUM_BASE_ATTRIBUTE4,
    NUM_BASE_ATTRIBUTE40,
    NUM_BASE_ATTRIBUTE41,
    NUM_BASE_ATTRIBUTE42,
    NUM_BASE_ATTRIBUTE43,
    NUM_BASE_ATTRIBUTE44,
    NUM_BASE_ATTRIBUTE45,
    NUM_BASE_ATTRIBUTE46,
    NUM_BASE_ATTRIBUTE47,
    NUM_BASE_ATTRIBUTE48,
    NUM_BASE_ATTRIBUTE49,
    NUM_BASE_ATTRIBUTE5,
    NUM_BASE_ATTRIBUTE50,
    NUM_BASE_ATTRIBUTE51,
    NUM_BASE_ATTRIBUTE52,
    NUM_BASE_ATTRIBUTE53,
    NUM_BASE_ATTRIBUTE54,
    NUM_BASE_ATTRIBUTE55,
    NUM_BASE_ATTRIBUTE56,
    NUM_BASE_ATTRIBUTE57,
    NUM_BASE_ATTRIBUTE58,
    NUM_BASE_ATTRIBUTE59,
    NUM_BASE_ATTRIBUTE6,
    NUM_BASE_ATTRIBUTE60,
    NUM_BASE_ATTRIBUTE61,
    NUM_BASE_ATTRIBUTE62,
    NUM_BASE_ATTRIBUTE63,
    NUM_BASE_ATTRIBUTE64,
    NUM_BASE_ATTRIBUTE65,
    NUM_BASE_ATTRIBUTE66,
    NUM_BASE_ATTRIBUTE67,
    NUM_BASE_ATTRIBUTE68,
    NUM_BASE_ATTRIBUTE69,
    NUM_BASE_ATTRIBUTE7,
    NUM_BASE_ATTRIBUTE70,
    NUM_BASE_ATTRIBUTE71,
    NUM_BASE_ATTRIBUTE72,
    NUM_BASE_ATTRIBUTE73,
    NUM_BASE_ATTRIBUTE74,
    NUM_BASE_ATTRIBUTE75,
    NUM_BASE_ATTRIBUTE76,
    NUM_BASE_ATTRIBUTE77,
    NUM_BASE_ATTRIBUTE78,
    NUM_BASE_ATTRIBUTE79,
    NUM_BASE_ATTRIBUTE8,
    NUM_BASE_ATTRIBUTE80,
    NUM_BASE_ATTRIBUTE81,
    NUM_BASE_ATTRIBUTE82,
    NUM_BASE_ATTRIBUTE83,
    NUM_BASE_ATTRIBUTE84,
    NUM_BASE_ATTRIBUTE85,
    NUM_BASE_ATTRIBUTE86,
    NUM_BASE_ATTRIBUTE87,
    NUM_BASE_ATTRIBUTE88,
    NUM_BASE_ATTRIBUTE89,
    NUM_BASE_ATTRIBUTE9,
    NUM_BASE_ATTRIBUTE90,
    NUM_BASE_ATTRIBUTE91,
    NUM_BASE_ATTRIBUTE92,
    NUM_BASE_ATTRIBUTE93,
    NUM_BASE_ATTRIBUTE94,
    NUM_BASE_ATTRIBUTE95,
    NUM_BASE_ATTRIBUTE96,
    NUM_BASE_ATTRIBUTE97,
    NUM_BASE_ATTRIBUTE98,
    NUM_BASE_ATTRIBUTE99,
    NUM_CAT_ATTRIBUTE1,
    NUM_CAT_ATTRIBUTE10,
    NUM_CAT_ATTRIBUTE11,
    NUM_CAT_ATTRIBUTE12,
    NUM_CAT_ATTRIBUTE13,
    NUM_CAT_ATTRIBUTE14,
    NUM_CAT_ATTRIBUTE15,
    NUM_CAT_ATTRIBUTE16,
    NUM_CAT_ATTRIBUTE17,
    NUM_CAT_ATTRIBUTE18,
    NUM_CAT_ATTRIBUTE19,
    NUM_CAT_ATTRIBUTE2,
    NUM_CAT_ATTRIBUTE20,
    NUM_CAT_ATTRIBUTE21,
    NUM_CAT_ATTRIBUTE22,
    NUM_CAT_ATTRIBUTE23,
    NUM_CAT_ATTRIBUTE24,
    NUM_CAT_ATTRIBUTE25,
    NUM_CAT_ATTRIBUTE26,
    NUM_CAT_ATTRIBUTE27,
    NUM_CAT_ATTRIBUTE28,
    NUM_CAT_ATTRIBUTE29,
    NUM_CAT_ATTRIBUTE3,
    NUM_CAT_ATTRIBUTE30,
    NUM_CAT_ATTRIBUTE31,
    NUM_CAT_ATTRIBUTE32,
    NUM_CAT_ATTRIBUTE33,
    NUM_CAT_ATTRIBUTE34,
    NUM_CAT_ATTRIBUTE35,
    NUM_CAT_ATTRIBUTE36,
    NUM_CAT_ATTRIBUTE37,
    NUM_CAT_ATTRIBUTE38,
    NUM_CAT_ATTRIBUTE39,
    NUM_CAT_ATTRIBUTE4,
    NUM_CAT_ATTRIBUTE40,
    NUM_CAT_ATTRIBUTE41,
    NUM_CAT_ATTRIBUTE42,
    NUM_CAT_ATTRIBUTE43,
    NUM_CAT_ATTRIBUTE44,
    NUM_CAT_ATTRIBUTE45,
    NUM_CAT_ATTRIBUTE46,
    NUM_CAT_ATTRIBUTE47,
    NUM_CAT_ATTRIBUTE48,
    NUM_CAT_ATTRIBUTE49,
    NUM_CAT_ATTRIBUTE5,
    NUM_CAT_ATTRIBUTE50,
    NUM_CAT_ATTRIBUTE6,
    NUM_CAT_ATTRIBUTE7,
    NUM_CAT_ATTRIBUTE8,
    NUM_CAT_ATTRIBUTE9,
    ORG_ID,
    PICTURE,
    PO_LINE_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    PROGRAM_UPDATE_DATE,
    REQUEST_ID,
    REQ_TEMPLATE_LINE_NUM,
    REQ_TEMPLATE_NAME,
    SUPPLIER_URL,
    TEXT_BASE_ATTRIBUTE1,
    TEXT_BASE_ATTRIBUTE10,
    TEXT_BASE_ATTRIBUTE100,
    TEXT_BASE_ATTRIBUTE11,
    TEXT_BASE_ATTRIBUTE12,
    TEXT_BASE_ATTRIBUTE13,
    TEXT_BASE_ATTRIBUTE14,
    TEXT_BASE_ATTRIBUTE15,
    TEXT_BASE_ATTRIBUTE16,
    TEXT_BASE_ATTRIBUTE17,
    TEXT_BASE_ATTRIBUTE18,
    TEXT_BASE_ATTRIBUTE19,
    TEXT_BASE_ATTRIBUTE2,
    TEXT_BASE_ATTRIBUTE20,
    TEXT_BASE_ATTRIBUTE21,
    TEXT_BASE_ATTRIBUTE22,
    TEXT_BASE_ATTRIBUTE23,
    TEXT_BASE_ATTRIBUTE24,
    TEXT_BASE_ATTRIBUTE25,
    TEXT_BASE_ATTRIBUTE26,
    TEXT_BASE_ATTRIBUTE27,
    TEXT_BASE_ATTRIBUTE28,
    TEXT_BASE_ATTRIBUTE29,
    TEXT_BASE_ATTRIBUTE3,
    TEXT_BASE_ATTRIBUTE30,
    TEXT_BASE_ATTRIBUTE31,
    TEXT_BASE_ATTRIBUTE32,
    TEXT_BASE_ATTRIBUTE33,
    TEXT_BASE_ATTRIBUTE34,
    TEXT_BASE_ATTRIBUTE35,
    TEXT_BASE_ATTRIBUTE36,
    TEXT_BASE_ATTRIBUTE37,
    TEXT_BASE_ATTRIBUTE38,
    TEXT_BASE_ATTRIBUTE39,
    TEXT_BASE_ATTRIBUTE4,
    TEXT_BASE_ATTRIBUTE40,
    TEXT_BASE_ATTRIBUTE41,
    TEXT_BASE_ATTRIBUTE42,
    TEXT_BASE_ATTRIBUTE43,
    TEXT_BASE_ATTRIBUTE44,
    TEXT_BASE_ATTRIBUTE45,
    TEXT_BASE_ATTRIBUTE46,
    TEXT_BASE_ATTRIBUTE47,
    TEXT_BASE_ATTRIBUTE48,
    TEXT_BASE_ATTRIBUTE49,
    TEXT_BASE_ATTRIBUTE5,
    TEXT_BASE_ATTRIBUTE50,
    TEXT_BASE_ATTRIBUTE51,
    TEXT_BASE_ATTRIBUTE52,
    TEXT_BASE_ATTRIBUTE53,
    TEXT_BASE_ATTRIBUTE54,
    TEXT_BASE_ATTRIBUTE55,
    TEXT_BASE_ATTRIBUTE56,
    TEXT_BASE_ATTRIBUTE57,
    TEXT_BASE_ATTRIBUTE58,
    TEXT_BASE_ATTRIBUTE59,
    TEXT_BASE_ATTRIBUTE6,
    TEXT_BASE_ATTRIBUTE60,
    TEXT_BASE_ATTRIBUTE61,
    TEXT_BASE_ATTRIBUTE62,
    TEXT_BASE_ATTRIBUTE63,
    TEXT_BASE_ATTRIBUTE64,
    TEXT_BASE_ATTRIBUTE65,
    TEXT_BASE_ATTRIBUTE66,
    TEXT_BASE_ATTRIBUTE67,
    TEXT_BASE_ATTRIBUTE68,
    TEXT_BASE_ATTRIBUTE69,
    TEXT_BASE_ATTRIBUTE7,
    TEXT_BASE_ATTRIBUTE70,
    TEXT_BASE_ATTRIBUTE71,
    TEXT_BASE_ATTRIBUTE72,
    TEXT_BASE_ATTRIBUTE73,
    TEXT_BASE_ATTRIBUTE74,
    TEXT_BASE_ATTRIBUTE75,
    TEXT_BASE_ATTRIBUTE76,
    TEXT_BASE_ATTRIBUTE77,
    TEXT_BASE_ATTRIBUTE78,
    TEXT_BASE_ATTRIBUTE79,
    TEXT_BASE_ATTRIBUTE8,
    TEXT_BASE_ATTRIBUTE80,
    TEXT_BASE_ATTRIBUTE81,
    TEXT_BASE_ATTRIBUTE82,
    TEXT_BASE_ATTRIBUTE83,
    TEXT_BASE_ATTRIBUTE84,
    TEXT_BASE_ATTRIBUTE85,
    TEXT_BASE_ATTRIBUTE86,
    TEXT_BASE_ATTRIBUTE87,
    TEXT_BASE_ATTRIBUTE88,
    TEXT_BASE_ATTRIBUTE89,
    TEXT_BASE_ATTRIBUTE9,
    TEXT_BASE_ATTRIBUTE90,
    TEXT_BASE_ATTRIBUTE91,
    TEXT_BASE_ATTRIBUTE92,
    TEXT_BASE_ATTRIBUTE93,
    TEXT_BASE_ATTRIBUTE94,
    TEXT_BASE_ATTRIBUTE95,
    TEXT_BASE_ATTRIBUTE96,
    TEXT_BASE_ATTRIBUTE97,
    TEXT_BASE_ATTRIBUTE98,
    TEXT_BASE_ATTRIBUTE99,
    TEXT_CAT_ATTRIBUTE1,
    TEXT_CAT_ATTRIBUTE10,
    TEXT_CAT_ATTRIBUTE11,
    TEXT_CAT_ATTRIBUTE12,
    TEXT_CAT_ATTRIBUTE13,
    TEXT_CAT_ATTRIBUTE14,
    TEXT_CAT_ATTRIBUTE15,
    TEXT_CAT_ATTRIBUTE16,
    TEXT_CAT_ATTRIBUTE17,
    TEXT_CAT_ATTRIBUTE18,
    TEXT_CAT_ATTRIBUTE19,
    TEXT_CAT_ATTRIBUTE2,
    TEXT_CAT_ATTRIBUTE20,
    TEXT_CAT_ATTRIBUTE21,
    TEXT_CAT_ATTRIBUTE22,
    TEXT_CAT_ATTRIBUTE23,
    TEXT_CAT_ATTRIBUTE24,
    TEXT_CAT_ATTRIBUTE25,
    TEXT_CAT_ATTRIBUTE26,
    TEXT_CAT_ATTRIBUTE27,
    TEXT_CAT_ATTRIBUTE28,
    TEXT_CAT_ATTRIBUTE29,
    TEXT_CAT_ATTRIBUTE3,
    TEXT_CAT_ATTRIBUTE30,
    TEXT_CAT_ATTRIBUTE31,
    TEXT_CAT_ATTRIBUTE32,
    TEXT_CAT_ATTRIBUTE33,
    TEXT_CAT_ATTRIBUTE34,
    TEXT_CAT_ATTRIBUTE35,
    TEXT_CAT_ATTRIBUTE36,
    TEXT_CAT_ATTRIBUTE37,
    TEXT_CAT_ATTRIBUTE38,
    TEXT_CAT_ATTRIBUTE39,
    TEXT_CAT_ATTRIBUTE4,
    TEXT_CAT_ATTRIBUTE40,
    TEXT_CAT_ATTRIBUTE41,
    TEXT_CAT_ATTRIBUTE42,
    TEXT_CAT_ATTRIBUTE43,
    TEXT_CAT_ATTRIBUTE44,
    TEXT_CAT_ATTRIBUTE45,
    TEXT_CAT_ATTRIBUTE46,
    TEXT_CAT_ATTRIBUTE47,
    TEXT_CAT_ATTRIBUTE48,
    TEXT_CAT_ATTRIBUTE49,
    TEXT_CAT_ATTRIBUTE5,
    TEXT_CAT_ATTRIBUTE50,
    TEXT_CAT_ATTRIBUTE6,
    TEXT_CAT_ATTRIBUTE7,
    TEXT_CAT_ATTRIBUTE8,
    TEXT_CAT_ATTRIBUTE9,
    THUMBNAIL_IMAGE,
    UNSPSC,
    LAST_UPDATED_PROGRAM)
  SELECT
    ATTACHMENT_URL,
    PO_ATTRIBUTE_VALUES_S.nextval,
    AVAILABILITY,
    CREATED_BY,
    CREATION_DATE,
    INVENTORY_ITEM_ID,
    IP_CATEGORY_ID,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LEAD_TIME,
    MANUFACTURER_PART_NUM,
    MANUFACTURER_URL,
    NUM_BASE_ATTRIBUTE1,
    NUM_BASE_ATTRIBUTE10,
    NUM_BASE_ATTRIBUTE100,
    NUM_BASE_ATTRIBUTE11,
    NUM_BASE_ATTRIBUTE12,
    NUM_BASE_ATTRIBUTE13,
    NUM_BASE_ATTRIBUTE14,
    NUM_BASE_ATTRIBUTE15,
    NUM_BASE_ATTRIBUTE16,
    NUM_BASE_ATTRIBUTE17,
    NUM_BASE_ATTRIBUTE18,
    NUM_BASE_ATTRIBUTE19,
    NUM_BASE_ATTRIBUTE2,
    NUM_BASE_ATTRIBUTE20,
    NUM_BASE_ATTRIBUTE21,
    NUM_BASE_ATTRIBUTE22,
    NUM_BASE_ATTRIBUTE23,
    NUM_BASE_ATTRIBUTE24,
    NUM_BASE_ATTRIBUTE25,
    NUM_BASE_ATTRIBUTE26,
    NUM_BASE_ATTRIBUTE27,
    NUM_BASE_ATTRIBUTE28,
    NUM_BASE_ATTRIBUTE29,
    NUM_BASE_ATTRIBUTE3,
    NUM_BASE_ATTRIBUTE30,
    NUM_BASE_ATTRIBUTE31,
    NUM_BASE_ATTRIBUTE32,
    NUM_BASE_ATTRIBUTE33,
    NUM_BASE_ATTRIBUTE34,
    NUM_BASE_ATTRIBUTE35,
    NUM_BASE_ATTRIBUTE36,
    NUM_BASE_ATTRIBUTE37,
    NUM_BASE_ATTRIBUTE38,
    NUM_BASE_ATTRIBUTE39,
    NUM_BASE_ATTRIBUTE4,
    NUM_BASE_ATTRIBUTE40,
    NUM_BASE_ATTRIBUTE41,
    NUM_BASE_ATTRIBUTE42,
    NUM_BASE_ATTRIBUTE43,
    NUM_BASE_ATTRIBUTE44,
    NUM_BASE_ATTRIBUTE45,
    NUM_BASE_ATTRIBUTE46,
    NUM_BASE_ATTRIBUTE47,
    NUM_BASE_ATTRIBUTE48,
    NUM_BASE_ATTRIBUTE49,
    NUM_BASE_ATTRIBUTE5,
    NUM_BASE_ATTRIBUTE50,
    NUM_BASE_ATTRIBUTE51,
    NUM_BASE_ATTRIBUTE52,
    NUM_BASE_ATTRIBUTE53,
    NUM_BASE_ATTRIBUTE54,
    NUM_BASE_ATTRIBUTE55,
    NUM_BASE_ATTRIBUTE56,
    NUM_BASE_ATTRIBUTE57,
    NUM_BASE_ATTRIBUTE58,
    NUM_BASE_ATTRIBUTE59,
    NUM_BASE_ATTRIBUTE6,
    NUM_BASE_ATTRIBUTE60,
    NUM_BASE_ATTRIBUTE61,
    NUM_BASE_ATTRIBUTE62,
    NUM_BASE_ATTRIBUTE63,
    NUM_BASE_ATTRIBUTE64,
    NUM_BASE_ATTRIBUTE65,
    NUM_BASE_ATTRIBUTE66,
    NUM_BASE_ATTRIBUTE67,
    NUM_BASE_ATTRIBUTE68,
    NUM_BASE_ATTRIBUTE69,
    NUM_BASE_ATTRIBUTE7,
    NUM_BASE_ATTRIBUTE70,
    NUM_BASE_ATTRIBUTE71,
    NUM_BASE_ATTRIBUTE72,
    NUM_BASE_ATTRIBUTE73,
    NUM_BASE_ATTRIBUTE74,
    NUM_BASE_ATTRIBUTE75,
    NUM_BASE_ATTRIBUTE76,
    NUM_BASE_ATTRIBUTE77,
    NUM_BASE_ATTRIBUTE78,
    NUM_BASE_ATTRIBUTE79,
    NUM_BASE_ATTRIBUTE8,
    NUM_BASE_ATTRIBUTE80,
    NUM_BASE_ATTRIBUTE81,
    NUM_BASE_ATTRIBUTE82,
    NUM_BASE_ATTRIBUTE83,
    NUM_BASE_ATTRIBUTE84,
    NUM_BASE_ATTRIBUTE85,
    NUM_BASE_ATTRIBUTE86,
    NUM_BASE_ATTRIBUTE87,
    NUM_BASE_ATTRIBUTE88,
    NUM_BASE_ATTRIBUTE89,
    NUM_BASE_ATTRIBUTE9,
    NUM_BASE_ATTRIBUTE90,
    NUM_BASE_ATTRIBUTE91,
    NUM_BASE_ATTRIBUTE92,
    NUM_BASE_ATTRIBUTE93,
    NUM_BASE_ATTRIBUTE94,
    NUM_BASE_ATTRIBUTE95,
    NUM_BASE_ATTRIBUTE96,
    NUM_BASE_ATTRIBUTE97,
    NUM_BASE_ATTRIBUTE98,
    NUM_BASE_ATTRIBUTE99,
    NUM_CAT_ATTRIBUTE1,
    NUM_CAT_ATTRIBUTE10,
    NUM_CAT_ATTRIBUTE11,
    NUM_CAT_ATTRIBUTE12,
    NUM_CAT_ATTRIBUTE13,
    NUM_CAT_ATTRIBUTE14,
    NUM_CAT_ATTRIBUTE15,
    NUM_CAT_ATTRIBUTE16,
    NUM_CAT_ATTRIBUTE17,
    NUM_CAT_ATTRIBUTE18,
    NUM_CAT_ATTRIBUTE19,
    NUM_CAT_ATTRIBUTE2,
    NUM_CAT_ATTRIBUTE20,
    NUM_CAT_ATTRIBUTE21,
    NUM_CAT_ATTRIBUTE22,
    NUM_CAT_ATTRIBUTE23,
    NUM_CAT_ATTRIBUTE24,
    NUM_CAT_ATTRIBUTE25,
    NUM_CAT_ATTRIBUTE26,
    NUM_CAT_ATTRIBUTE27,
    NUM_CAT_ATTRIBUTE28,
    NUM_CAT_ATTRIBUTE29,
    NUM_CAT_ATTRIBUTE3,
    NUM_CAT_ATTRIBUTE30,
    NUM_CAT_ATTRIBUTE31,
    NUM_CAT_ATTRIBUTE32,
    NUM_CAT_ATTRIBUTE33,
    NUM_CAT_ATTRIBUTE34,
    NUM_CAT_ATTRIBUTE35,
    NUM_CAT_ATTRIBUTE36,
    NUM_CAT_ATTRIBUTE37,
    NUM_CAT_ATTRIBUTE38,
    NUM_CAT_ATTRIBUTE39,
    NUM_CAT_ATTRIBUTE4,
    NUM_CAT_ATTRIBUTE40,
    NUM_CAT_ATTRIBUTE41,
    NUM_CAT_ATTRIBUTE42,
    NUM_CAT_ATTRIBUTE43,
    NUM_CAT_ATTRIBUTE44,
    NUM_CAT_ATTRIBUTE45,
    NUM_CAT_ATTRIBUTE46,
    NUM_CAT_ATTRIBUTE47,
    NUM_CAT_ATTRIBUTE48,
    NUM_CAT_ATTRIBUTE49,
    NUM_CAT_ATTRIBUTE5,
    NUM_CAT_ATTRIBUTE50,
    NUM_CAT_ATTRIBUTE6,
    NUM_CAT_ATTRIBUTE7,
    NUM_CAT_ATTRIBUTE8,
    NUM_CAT_ATTRIBUTE9,
    ORG_ID,
    PICTURE,
    PO_LINE_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    PROGRAM_UPDATE_DATE,
    REQUEST_ID,
    REQ_TEMPLATE_LINE_NUM,
    REQ_TEMPLATE_NAME,
    SUPPLIER_URL,
    TEXT_BASE_ATTRIBUTE1,
    TEXT_BASE_ATTRIBUTE10,
    TEXT_BASE_ATTRIBUTE100,
    TEXT_BASE_ATTRIBUTE11,
    TEXT_BASE_ATTRIBUTE12,
    TEXT_BASE_ATTRIBUTE13,
    TEXT_BASE_ATTRIBUTE14,
    TEXT_BASE_ATTRIBUTE15,
    TEXT_BASE_ATTRIBUTE16,
    TEXT_BASE_ATTRIBUTE17,
    TEXT_BASE_ATTRIBUTE18,
    TEXT_BASE_ATTRIBUTE19,
    TEXT_BASE_ATTRIBUTE2,
    TEXT_BASE_ATTRIBUTE20,
    TEXT_BASE_ATTRIBUTE21,
    TEXT_BASE_ATTRIBUTE22,
    TEXT_BASE_ATTRIBUTE23,
    TEXT_BASE_ATTRIBUTE24,
    TEXT_BASE_ATTRIBUTE25,
    TEXT_BASE_ATTRIBUTE26,
    TEXT_BASE_ATTRIBUTE27,
    TEXT_BASE_ATTRIBUTE28,
    TEXT_BASE_ATTRIBUTE29,
    TEXT_BASE_ATTRIBUTE3,
    TEXT_BASE_ATTRIBUTE30,
    TEXT_BASE_ATTRIBUTE31,
    TEXT_BASE_ATTRIBUTE32,
    TEXT_BASE_ATTRIBUTE33,
    TEXT_BASE_ATTRIBUTE34,
    TEXT_BASE_ATTRIBUTE35,
    TEXT_BASE_ATTRIBUTE36,
    TEXT_BASE_ATTRIBUTE37,
    TEXT_BASE_ATTRIBUTE38,
    TEXT_BASE_ATTRIBUTE39,
    TEXT_BASE_ATTRIBUTE4,
    TEXT_BASE_ATTRIBUTE40,
    TEXT_BASE_ATTRIBUTE41,
    TEXT_BASE_ATTRIBUTE42,
    TEXT_BASE_ATTRIBUTE43,
    TEXT_BASE_ATTRIBUTE44,
    TEXT_BASE_ATTRIBUTE45,
    TEXT_BASE_ATTRIBUTE46,
    TEXT_BASE_ATTRIBUTE47,
    TEXT_BASE_ATTRIBUTE48,
    TEXT_BASE_ATTRIBUTE49,
    TEXT_BASE_ATTRIBUTE5,
    TEXT_BASE_ATTRIBUTE50,
    TEXT_BASE_ATTRIBUTE51,
    TEXT_BASE_ATTRIBUTE52,
    TEXT_BASE_ATTRIBUTE53,
    TEXT_BASE_ATTRIBUTE54,
    TEXT_BASE_ATTRIBUTE55,
    TEXT_BASE_ATTRIBUTE56,
    TEXT_BASE_ATTRIBUTE57,
    TEXT_BASE_ATTRIBUTE58,
    TEXT_BASE_ATTRIBUTE59,
    TEXT_BASE_ATTRIBUTE6,
    TEXT_BASE_ATTRIBUTE60,
    TEXT_BASE_ATTRIBUTE61,
    TEXT_BASE_ATTRIBUTE62,
    TEXT_BASE_ATTRIBUTE63,
    TEXT_BASE_ATTRIBUTE64,
    TEXT_BASE_ATTRIBUTE65,
    TEXT_BASE_ATTRIBUTE66,
    TEXT_BASE_ATTRIBUTE67,
    TEXT_BASE_ATTRIBUTE68,
    TEXT_BASE_ATTRIBUTE69,
    TEXT_BASE_ATTRIBUTE7,
    TEXT_BASE_ATTRIBUTE70,
    TEXT_BASE_ATTRIBUTE71,
    TEXT_BASE_ATTRIBUTE72,
    TEXT_BASE_ATTRIBUTE73,
    TEXT_BASE_ATTRIBUTE74,
    TEXT_BASE_ATTRIBUTE75,
    TEXT_BASE_ATTRIBUTE76,
    TEXT_BASE_ATTRIBUTE77,
    TEXT_BASE_ATTRIBUTE78,
    TEXT_BASE_ATTRIBUTE79,
    TEXT_BASE_ATTRIBUTE8,
    TEXT_BASE_ATTRIBUTE80,
    TEXT_BASE_ATTRIBUTE81,
    TEXT_BASE_ATTRIBUTE82,
    TEXT_BASE_ATTRIBUTE83,
    TEXT_BASE_ATTRIBUTE84,
    TEXT_BASE_ATTRIBUTE85,
    TEXT_BASE_ATTRIBUTE86,
    TEXT_BASE_ATTRIBUTE87,
    TEXT_BASE_ATTRIBUTE88,
    TEXT_BASE_ATTRIBUTE89,
    TEXT_BASE_ATTRIBUTE9,
    TEXT_BASE_ATTRIBUTE90,
    TEXT_BASE_ATTRIBUTE91,
    TEXT_BASE_ATTRIBUTE92,
    TEXT_BASE_ATTRIBUTE93,
    TEXT_BASE_ATTRIBUTE94,
    TEXT_BASE_ATTRIBUTE95,
    TEXT_BASE_ATTRIBUTE96,
    TEXT_BASE_ATTRIBUTE97,
    TEXT_BASE_ATTRIBUTE98,
    TEXT_BASE_ATTRIBUTE99,
    TEXT_CAT_ATTRIBUTE1,
    TEXT_CAT_ATTRIBUTE10,
    TEXT_CAT_ATTRIBUTE11,
    TEXT_CAT_ATTRIBUTE12,
    TEXT_CAT_ATTRIBUTE13,
    TEXT_CAT_ATTRIBUTE14,
    TEXT_CAT_ATTRIBUTE15,
    TEXT_CAT_ATTRIBUTE16,
    TEXT_CAT_ATTRIBUTE17,
    TEXT_CAT_ATTRIBUTE18,
    TEXT_CAT_ATTRIBUTE19,
    TEXT_CAT_ATTRIBUTE2,
    TEXT_CAT_ATTRIBUTE20,
    TEXT_CAT_ATTRIBUTE21,
    TEXT_CAT_ATTRIBUTE22,
    TEXT_CAT_ATTRIBUTE23,
    TEXT_CAT_ATTRIBUTE24,
    TEXT_CAT_ATTRIBUTE25,
    TEXT_CAT_ATTRIBUTE26,
    TEXT_CAT_ATTRIBUTE27,
    TEXT_CAT_ATTRIBUTE28,
    TEXT_CAT_ATTRIBUTE29,
    TEXT_CAT_ATTRIBUTE3,
    TEXT_CAT_ATTRIBUTE30,
    TEXT_CAT_ATTRIBUTE31,
    TEXT_CAT_ATTRIBUTE32,
    TEXT_CAT_ATTRIBUTE33,
    TEXT_CAT_ATTRIBUTE34,
    TEXT_CAT_ATTRIBUTE35,
    TEXT_CAT_ATTRIBUTE36,
    TEXT_CAT_ATTRIBUTE37,
    TEXT_CAT_ATTRIBUTE38,
    TEXT_CAT_ATTRIBUTE39,
    TEXT_CAT_ATTRIBUTE4,
    TEXT_CAT_ATTRIBUTE40,
    TEXT_CAT_ATTRIBUTE41,
    TEXT_CAT_ATTRIBUTE42,
    TEXT_CAT_ATTRIBUTE43,
    TEXT_CAT_ATTRIBUTE44,
    TEXT_CAT_ATTRIBUTE45,
    TEXT_CAT_ATTRIBUTE46,
    TEXT_CAT_ATTRIBUTE47,
    TEXT_CAT_ATTRIBUTE48,
    TEXT_CAT_ATTRIBUTE49,
    TEXT_CAT_ATTRIBUTE5,
    TEXT_CAT_ATTRIBUTE50,
    TEXT_CAT_ATTRIBUTE6,
    TEXT_CAT_ATTRIBUTE7,
    TEXT_CAT_ATTRIBUTE8,
    TEXT_CAT_ATTRIBUTE9,
    THUMBNAIL_IMAGE,
    UNSPSC,
    'AUTOCREATE_BACKEND_FOR_SOURCING'
  FROM PO_ATTR_VALUES_INTERFACE
  WHERE interface_header_id = p_interface_header_id;

  IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Number of rows inserted in PO_ATTRIBUTE_VALUES table='||SQL%rowcount); END IF;

  l_progress := '030';
  --insert tlp records from interface table
  INSERT INTO PO_ATTRIBUTE_VALUES_TLP (
    ALIAS,
    ATTRIBUTE_VALUES_TLP_ID,
    COMMENTS,
    CREATED_BY,
    CREATION_DATE,
    DESCRIPTION,
    INVENTORY_ITEM_ID,
    IP_CATEGORY_ID,
    LANGUAGE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LONG_DESCRIPTION,
    MANUFACTURER,
    ORG_ID,
    PO_LINE_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    PROGRAM_UPDATE_DATE,
    REQUEST_ID,
    REQ_TEMPLATE_LINE_NUM,
    REQ_TEMPLATE_NAME,
    TL_TEXT_BASE_ATTRIBUTE1,
    TL_TEXT_BASE_ATTRIBUTE10,
    TL_TEXT_BASE_ATTRIBUTE100,
    TL_TEXT_BASE_ATTRIBUTE11,
    TL_TEXT_BASE_ATTRIBUTE12,
    TL_TEXT_BASE_ATTRIBUTE13,
    TL_TEXT_BASE_ATTRIBUTE14,
    TL_TEXT_BASE_ATTRIBUTE15,
    TL_TEXT_BASE_ATTRIBUTE16,
    TL_TEXT_BASE_ATTRIBUTE17,
    TL_TEXT_BASE_ATTRIBUTE18,
    TL_TEXT_BASE_ATTRIBUTE19,
    TL_TEXT_BASE_ATTRIBUTE2,
    TL_TEXT_BASE_ATTRIBUTE20,
    TL_TEXT_BASE_ATTRIBUTE21,
    TL_TEXT_BASE_ATTRIBUTE22,
    TL_TEXT_BASE_ATTRIBUTE23,
    TL_TEXT_BASE_ATTRIBUTE24,
    TL_TEXT_BASE_ATTRIBUTE25,
    TL_TEXT_BASE_ATTRIBUTE26,
    TL_TEXT_BASE_ATTRIBUTE27,
    TL_TEXT_BASE_ATTRIBUTE28,
    TL_TEXT_BASE_ATTRIBUTE29,
    TL_TEXT_BASE_ATTRIBUTE3,
    TL_TEXT_BASE_ATTRIBUTE30,
    TL_TEXT_BASE_ATTRIBUTE31,
    TL_TEXT_BASE_ATTRIBUTE32,
    TL_TEXT_BASE_ATTRIBUTE33,
    TL_TEXT_BASE_ATTRIBUTE34,
    TL_TEXT_BASE_ATTRIBUTE35,
    TL_TEXT_BASE_ATTRIBUTE36,
    TL_TEXT_BASE_ATTRIBUTE37,
    TL_TEXT_BASE_ATTRIBUTE38,
    TL_TEXT_BASE_ATTRIBUTE39,
    TL_TEXT_BASE_ATTRIBUTE4,
    TL_TEXT_BASE_ATTRIBUTE40,
    TL_TEXT_BASE_ATTRIBUTE41,
    TL_TEXT_BASE_ATTRIBUTE42,
    TL_TEXT_BASE_ATTRIBUTE43,
    TL_TEXT_BASE_ATTRIBUTE44,
    TL_TEXT_BASE_ATTRIBUTE45,
    TL_TEXT_BASE_ATTRIBUTE46,
    TL_TEXT_BASE_ATTRIBUTE47,
    TL_TEXT_BASE_ATTRIBUTE48,
    TL_TEXT_BASE_ATTRIBUTE49,
    TL_TEXT_BASE_ATTRIBUTE5,
    TL_TEXT_BASE_ATTRIBUTE50,
    TL_TEXT_BASE_ATTRIBUTE51,
    TL_TEXT_BASE_ATTRIBUTE52,
    TL_TEXT_BASE_ATTRIBUTE53,
    TL_TEXT_BASE_ATTRIBUTE54,
    TL_TEXT_BASE_ATTRIBUTE55,
    TL_TEXT_BASE_ATTRIBUTE56,
    TL_TEXT_BASE_ATTRIBUTE57,
    TL_TEXT_BASE_ATTRIBUTE58,
    TL_TEXT_BASE_ATTRIBUTE59,
    TL_TEXT_BASE_ATTRIBUTE6,
    TL_TEXT_BASE_ATTRIBUTE60,
    TL_TEXT_BASE_ATTRIBUTE61,
    TL_TEXT_BASE_ATTRIBUTE62,
    TL_TEXT_BASE_ATTRIBUTE63,
    TL_TEXT_BASE_ATTRIBUTE64,
    TL_TEXT_BASE_ATTRIBUTE65,
    TL_TEXT_BASE_ATTRIBUTE66,
    TL_TEXT_BASE_ATTRIBUTE67,
    TL_TEXT_BASE_ATTRIBUTE68,
    TL_TEXT_BASE_ATTRIBUTE69,
    TL_TEXT_BASE_ATTRIBUTE7,
    TL_TEXT_BASE_ATTRIBUTE70,
    TL_TEXT_BASE_ATTRIBUTE71,
    TL_TEXT_BASE_ATTRIBUTE72,
    TL_TEXT_BASE_ATTRIBUTE73,
    TL_TEXT_BASE_ATTRIBUTE74,
    TL_TEXT_BASE_ATTRIBUTE75,
    TL_TEXT_BASE_ATTRIBUTE76,
    TL_TEXT_BASE_ATTRIBUTE77,
    TL_TEXT_BASE_ATTRIBUTE78,
    TL_TEXT_BASE_ATTRIBUTE79,
    TL_TEXT_BASE_ATTRIBUTE8,
    TL_TEXT_BASE_ATTRIBUTE80,
    TL_TEXT_BASE_ATTRIBUTE81,
    TL_TEXT_BASE_ATTRIBUTE82,
    TL_TEXT_BASE_ATTRIBUTE83,
    TL_TEXT_BASE_ATTRIBUTE84,
    TL_TEXT_BASE_ATTRIBUTE85,
    TL_TEXT_BASE_ATTRIBUTE86,
    TL_TEXT_BASE_ATTRIBUTE87,
    TL_TEXT_BASE_ATTRIBUTE88,
    TL_TEXT_BASE_ATTRIBUTE89,
    TL_TEXT_BASE_ATTRIBUTE9,
    TL_TEXT_BASE_ATTRIBUTE90,
    TL_TEXT_BASE_ATTRIBUTE91,
    TL_TEXT_BASE_ATTRIBUTE92,
    TL_TEXT_BASE_ATTRIBUTE93,
    TL_TEXT_BASE_ATTRIBUTE94,
    TL_TEXT_BASE_ATTRIBUTE95,
    TL_TEXT_BASE_ATTRIBUTE96,
    TL_TEXT_BASE_ATTRIBUTE97,
    TL_TEXT_BASE_ATTRIBUTE98,
    TL_TEXT_BASE_ATTRIBUTE99,
    TL_TEXT_CAT_ATTRIBUTE1,
    TL_TEXT_CAT_ATTRIBUTE10,
    TL_TEXT_CAT_ATTRIBUTE11,
    TL_TEXT_CAT_ATTRIBUTE12,
    TL_TEXT_CAT_ATTRIBUTE13,
    TL_TEXT_CAT_ATTRIBUTE14,
    TL_TEXT_CAT_ATTRIBUTE15,
    TL_TEXT_CAT_ATTRIBUTE16,
    TL_TEXT_CAT_ATTRIBUTE17,
    TL_TEXT_CAT_ATTRIBUTE18,
    TL_TEXT_CAT_ATTRIBUTE19,
    TL_TEXT_CAT_ATTRIBUTE2,
    TL_TEXT_CAT_ATTRIBUTE20,
    TL_TEXT_CAT_ATTRIBUTE21,
    TL_TEXT_CAT_ATTRIBUTE22,
    TL_TEXT_CAT_ATTRIBUTE23,
    TL_TEXT_CAT_ATTRIBUTE24,
    TL_TEXT_CAT_ATTRIBUTE25,
    TL_TEXT_CAT_ATTRIBUTE26,
    TL_TEXT_CAT_ATTRIBUTE27,
    TL_TEXT_CAT_ATTRIBUTE28,
    TL_TEXT_CAT_ATTRIBUTE29,
    TL_TEXT_CAT_ATTRIBUTE3,
    TL_TEXT_CAT_ATTRIBUTE30,
    TL_TEXT_CAT_ATTRIBUTE31,
    TL_TEXT_CAT_ATTRIBUTE32,
    TL_TEXT_CAT_ATTRIBUTE33,
    TL_TEXT_CAT_ATTRIBUTE34,
    TL_TEXT_CAT_ATTRIBUTE35,
    TL_TEXT_CAT_ATTRIBUTE36,
    TL_TEXT_CAT_ATTRIBUTE37,
    TL_TEXT_CAT_ATTRIBUTE38,
    TL_TEXT_CAT_ATTRIBUTE39,
    TL_TEXT_CAT_ATTRIBUTE4,
    TL_TEXT_CAT_ATTRIBUTE40,
    TL_TEXT_CAT_ATTRIBUTE41,
    TL_TEXT_CAT_ATTRIBUTE42,
    TL_TEXT_CAT_ATTRIBUTE43,
    TL_TEXT_CAT_ATTRIBUTE44,
    TL_TEXT_CAT_ATTRIBUTE45,
    TL_TEXT_CAT_ATTRIBUTE46,
    TL_TEXT_CAT_ATTRIBUTE47,
    TL_TEXT_CAT_ATTRIBUTE48,
    TL_TEXT_CAT_ATTRIBUTE49,
    TL_TEXT_CAT_ATTRIBUTE5,
    TL_TEXT_CAT_ATTRIBUTE50,
    TL_TEXT_CAT_ATTRIBUTE6,
    TL_TEXT_CAT_ATTRIBUTE7,
    TL_TEXT_CAT_ATTRIBUTE8,
    TL_TEXT_CAT_ATTRIBUTE9,
    LAST_UPDATED_PROGRAM)
  SELECT
    ALIAS,
    PO_ATTRIBUTE_VALUES_TLP_S.nextval,
    COMMENTS,
    CREATED_BY,
    CREATION_DATE,
    DESCRIPTION,
    INVENTORY_ITEM_ID,
    IP_CATEGORY_ID,
    LANGUAGE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LONG_DESCRIPTION,
    MANUFACTURER,
    ORG_ID,
    PO_LINE_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    PROGRAM_UPDATE_DATE,
    REQUEST_ID,
    REQ_TEMPLATE_LINE_NUM,
    REQ_TEMPLATE_NAME,
    TL_TEXT_BASE_ATTRIBUTE1,
    TL_TEXT_BASE_ATTRIBUTE10,
    TL_TEXT_BASE_ATTRIBUTE100,
    TL_TEXT_BASE_ATTRIBUTE11,
    TL_TEXT_BASE_ATTRIBUTE12,
    TL_TEXT_BASE_ATTRIBUTE13,
    TL_TEXT_BASE_ATTRIBUTE14,
    TL_TEXT_BASE_ATTRIBUTE15,
    TL_TEXT_BASE_ATTRIBUTE16,
    TL_TEXT_BASE_ATTRIBUTE17,
    TL_TEXT_BASE_ATTRIBUTE18,
    TL_TEXT_BASE_ATTRIBUTE19,
    TL_TEXT_BASE_ATTRIBUTE2,
    TL_TEXT_BASE_ATTRIBUTE20,
    TL_TEXT_BASE_ATTRIBUTE21,
    TL_TEXT_BASE_ATTRIBUTE22,
    TL_TEXT_BASE_ATTRIBUTE23,
    TL_TEXT_BASE_ATTRIBUTE24,
    TL_TEXT_BASE_ATTRIBUTE25,
    TL_TEXT_BASE_ATTRIBUTE26,
    TL_TEXT_BASE_ATTRIBUTE27,
    TL_TEXT_BASE_ATTRIBUTE28,
    TL_TEXT_BASE_ATTRIBUTE29,
    TL_TEXT_BASE_ATTRIBUTE3,
    TL_TEXT_BASE_ATTRIBUTE30,
    TL_TEXT_BASE_ATTRIBUTE31,
    TL_TEXT_BASE_ATTRIBUTE32,
    TL_TEXT_BASE_ATTRIBUTE33,
    TL_TEXT_BASE_ATTRIBUTE34,
    TL_TEXT_BASE_ATTRIBUTE35,
    TL_TEXT_BASE_ATTRIBUTE36,
    TL_TEXT_BASE_ATTRIBUTE37,
    TL_TEXT_BASE_ATTRIBUTE38,
    TL_TEXT_BASE_ATTRIBUTE39,
    TL_TEXT_BASE_ATTRIBUTE4,
    TL_TEXT_BASE_ATTRIBUTE40,
    TL_TEXT_BASE_ATTRIBUTE41,
    TL_TEXT_BASE_ATTRIBUTE42,
    TL_TEXT_BASE_ATTRIBUTE43,
    TL_TEXT_BASE_ATTRIBUTE44,
    TL_TEXT_BASE_ATTRIBUTE45,
    TL_TEXT_BASE_ATTRIBUTE46,
    TL_TEXT_BASE_ATTRIBUTE47,
    TL_TEXT_BASE_ATTRIBUTE48,
    TL_TEXT_BASE_ATTRIBUTE49,
    TL_TEXT_BASE_ATTRIBUTE5,
    TL_TEXT_BASE_ATTRIBUTE50,
    TL_TEXT_BASE_ATTRIBUTE51,
    TL_TEXT_BASE_ATTRIBUTE52,
    TL_TEXT_BASE_ATTRIBUTE53,
    TL_TEXT_BASE_ATTRIBUTE54,
    TL_TEXT_BASE_ATTRIBUTE55,
    TL_TEXT_BASE_ATTRIBUTE56,
    TL_TEXT_BASE_ATTRIBUTE57,
    TL_TEXT_BASE_ATTRIBUTE58,
    TL_TEXT_BASE_ATTRIBUTE59,
    TL_TEXT_BASE_ATTRIBUTE6,
    TL_TEXT_BASE_ATTRIBUTE60,
    TL_TEXT_BASE_ATTRIBUTE61,
    TL_TEXT_BASE_ATTRIBUTE62,
    TL_TEXT_BASE_ATTRIBUTE63,
    TL_TEXT_BASE_ATTRIBUTE64,
    TL_TEXT_BASE_ATTRIBUTE65,
    TL_TEXT_BASE_ATTRIBUTE66,
    TL_TEXT_BASE_ATTRIBUTE67,
    TL_TEXT_BASE_ATTRIBUTE68,
    TL_TEXT_BASE_ATTRIBUTE69,
    TL_TEXT_BASE_ATTRIBUTE7,
    TL_TEXT_BASE_ATTRIBUTE70,
    TL_TEXT_BASE_ATTRIBUTE71,
    TL_TEXT_BASE_ATTRIBUTE72,
    TL_TEXT_BASE_ATTRIBUTE73,
    TL_TEXT_BASE_ATTRIBUTE74,
    TL_TEXT_BASE_ATTRIBUTE75,
    TL_TEXT_BASE_ATTRIBUTE76,
    TL_TEXT_BASE_ATTRIBUTE77,
    TL_TEXT_BASE_ATTRIBUTE78,
    TL_TEXT_BASE_ATTRIBUTE79,
    TL_TEXT_BASE_ATTRIBUTE8,
    TL_TEXT_BASE_ATTRIBUTE80,
    TL_TEXT_BASE_ATTRIBUTE81,
    TL_TEXT_BASE_ATTRIBUTE82,
    TL_TEXT_BASE_ATTRIBUTE83,
    TL_TEXT_BASE_ATTRIBUTE84,
    TL_TEXT_BASE_ATTRIBUTE85,
    TL_TEXT_BASE_ATTRIBUTE86,
    TL_TEXT_BASE_ATTRIBUTE87,
    TL_TEXT_BASE_ATTRIBUTE88,
    TL_TEXT_BASE_ATTRIBUTE89,
    TL_TEXT_BASE_ATTRIBUTE9,
    TL_TEXT_BASE_ATTRIBUTE90,
    TL_TEXT_BASE_ATTRIBUTE91,
    TL_TEXT_BASE_ATTRIBUTE92,
    TL_TEXT_BASE_ATTRIBUTE93,
    TL_TEXT_BASE_ATTRIBUTE94,
    TL_TEXT_BASE_ATTRIBUTE95,
    TL_TEXT_BASE_ATTRIBUTE96,
    TL_TEXT_BASE_ATTRIBUTE97,
    TL_TEXT_BASE_ATTRIBUTE98,
    TL_TEXT_BASE_ATTRIBUTE99,
    TL_TEXT_CAT_ATTRIBUTE1,
    TL_TEXT_CAT_ATTRIBUTE10,
    TL_TEXT_CAT_ATTRIBUTE11,
    TL_TEXT_CAT_ATTRIBUTE12,
    TL_TEXT_CAT_ATTRIBUTE13,
    TL_TEXT_CAT_ATTRIBUTE14,
    TL_TEXT_CAT_ATTRIBUTE15,
    TL_TEXT_CAT_ATTRIBUTE16,
    TL_TEXT_CAT_ATTRIBUTE17,
    TL_TEXT_CAT_ATTRIBUTE18,
    TL_TEXT_CAT_ATTRIBUTE19,
    TL_TEXT_CAT_ATTRIBUTE2,
    TL_TEXT_CAT_ATTRIBUTE20,
    TL_TEXT_CAT_ATTRIBUTE21,
    TL_TEXT_CAT_ATTRIBUTE22,
    TL_TEXT_CAT_ATTRIBUTE23,
    TL_TEXT_CAT_ATTRIBUTE24,
    TL_TEXT_CAT_ATTRIBUTE25,
    TL_TEXT_CAT_ATTRIBUTE26,
    TL_TEXT_CAT_ATTRIBUTE27,
    TL_TEXT_CAT_ATTRIBUTE28,
    TL_TEXT_CAT_ATTRIBUTE29,
    TL_TEXT_CAT_ATTRIBUTE3,
    TL_TEXT_CAT_ATTRIBUTE30,
    TL_TEXT_CAT_ATTRIBUTE31,
    TL_TEXT_CAT_ATTRIBUTE32,
    TL_TEXT_CAT_ATTRIBUTE33,
    TL_TEXT_CAT_ATTRIBUTE34,
    TL_TEXT_CAT_ATTRIBUTE35,
    TL_TEXT_CAT_ATTRIBUTE36,
    TL_TEXT_CAT_ATTRIBUTE37,
    TL_TEXT_CAT_ATTRIBUTE38,
    TL_TEXT_CAT_ATTRIBUTE39,
    TL_TEXT_CAT_ATTRIBUTE4,
    TL_TEXT_CAT_ATTRIBUTE40,
    TL_TEXT_CAT_ATTRIBUTE41,
    TL_TEXT_CAT_ATTRIBUTE42,
    TL_TEXT_CAT_ATTRIBUTE43,
    TL_TEXT_CAT_ATTRIBUTE44,
    TL_TEXT_CAT_ATTRIBUTE45,
    TL_TEXT_CAT_ATTRIBUTE46,
    TL_TEXT_CAT_ATTRIBUTE47,
    TL_TEXT_CAT_ATTRIBUTE48,
    TL_TEXT_CAT_ATTRIBUTE49,
    TL_TEXT_CAT_ATTRIBUTE5,
    TL_TEXT_CAT_ATTRIBUTE50,
    TL_TEXT_CAT_ATTRIBUTE6,
    TL_TEXT_CAT_ATTRIBUTE7,
    TL_TEXT_CAT_ATTRIBUTE8,
    TL_TEXT_CAT_ATTRIBUTE9,
    'AUTOCREATE_BACKEND_FOR_SOURCING'
  FROM PO_ATTR_VALUES_TLP_INTERFACE
  WHERE interface_header_id = p_interface_header_id;

  IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Number of rows inserted in PO_ATTRIBUTE_VALUES_TLP table='||SQL%rowcount); END IF;

  IF PO_LOG.d_proc THEN PO_LOG.proc_end(d_mod); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN PO_LOG.exc(d_mod,l_progress,'Unhandled exception:'||SQLCODE || SQLERRM); END IF;
    RAISE;
END transfer_intf_item_attribs;

--------------------------------------------------------------------------------
--Start of Comments
--Name: get_translations
--Pre-reqs:
--  TLP row for the created/base language must exist.
--Modifies:
--  FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Gets the translations for each of the TLP row provided in the input
--  array.
--
--Parameters:
--IN:
--p_attr_values_tlp_id_list
--  The list of TLP row ID's which will provide data to join to MTL tables
--  to get the translations (item_id, etc.)
--OUT:
--x_tlp_id_to_be_copied_list
-- List of TLP ID's corresponding to each line for the languages for which
-- translation is available.
--x_tlp_new_descriptions_list
-- List of translated descriptions corresponding to each language
--x_tlp_language_list
-- The list of languages for which the translations are available
--x_tlp_long_descriptions_list
-- List of translated long item descriptions
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE get_translations
(
  p_attr_values_tlp_id_list   IN PO_TBL_NUMBER
, x_tlp_id_to_be_copied_list  OUT NOCOPY PO_TBL_NUMBER
, x_tlp_new_descriptions_list OUT NOCOPY PO_TBL_VARCHAR480
, x_tlp_language_list         OUT NOCOPY PO_TBL_VARCHAR4
, x_tlp_long_descriptions_list OUT NOCOPY PO_TBL_VARCHAR4000 -- Bug7039409: Added -- Bug 18921232
)
IS
  d_mod CONSTANT VARCHAR2(100) := D_get_translations;
  l_progress      VARCHAR2(4);

  l_key PO_SESSION_GT.key%TYPE;
  l_onetime_item_all_languages FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE;
BEGIN
  l_progress := '010';

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_attr_values_tlp_id_list',p_attr_values_tlp_id_list);
  END IF;

  -- Get the profile value for "POR: Load One-Time Items in All Languages"
  l_onetime_item_all_languages := NVL(FND_PROFILE.value('POR_LOAD_ONETIME_ITEM_ALL_LANG'), 'N');
  IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Profile POR_LOAD_ONETIME_ITEM_ALL_LANG='||l_onetime_item_all_languages); END IF;

  -- SQL What: Pick a new key from session GT sequence .
  -- SQL Why : To get tlp_id's
  -- SQL Join: none
  SELECT PO_SESSION_GT_S.nextval
  INTO l_key
  FROM DUAL;

  l_progress := '020';
  -- SQL What: Now get translations for each of the TLP rows, for each available language
  -- SQL Why : They will be inserted into the TLP table
  -- SQL Join: attribute_values_tlp_id, inventory_item_id, org_id, inventory_organization_id, language
  -- MANUFACTURER will be populated from the base language only
  FORALL i IN 1 .. p_attr_values_tlp_id_list.COUNT
    INSERT INTO PO_SESSION_GT(key,
                              num1,
                              char1,
                              char2,
                              char3 -- Bug7039409: Added for long_description
                             )
    SELECT l_key,
           TLP.attribute_values_tlp_id,
           MTL.description,
           MTL.language,
           MTL.long_description     -- Bug7039409: Get long_description also
      FROM MTL_SYSTEM_ITEMS_TL MTL,
           FINANCIALS_SYSTEM_PARAMS_ALL FSP,
           PO_ATTRIBUTE_VALUES_TLP TLP
     WHERE TLP.inventory_item_id IS NOT NULL
       AND TLP.inventory_item_id <> g_ATTR_VALUES_NULL_ID -- '-2'
       AND TLP.attribute_values_tlp_id = p_attr_values_tlp_id_list(i)
       AND MTL.inventory_item_id = TLP.inventory_item_id
       AND FSP.org_id = TLP.org_id
       AND FSP.inventory_organization_id = MTL.organization_id
       AND MTL.language = MTL.source_lang
       AND MTL.language <> TLP.language -- dont fetch for already existing row

    UNION ALL

           -- One-time item case

    SELECT l_key,
           TLP.attribute_values_tlp_id,
           TLP.description,
           FNDLANG.language_code,
           NULL -- Bug7039409: long_description as NULL for one-time item
      FROM FND_LANGUAGES FNDLANG,
           PO_ATTRIBUTE_VALUES_TLP TLP
     WHERE (TLP.inventory_item_id IS NULL OR
            TLP.inventory_item_id = g_ATTR_VALUES_NULL_ID) -- '-2'
       AND FNDLANG.installed_flag IN ('B', 'I')
       AND FNDLANG.language_code <> TLP.language
       AND TLP.attribute_values_tlp_id = p_attr_values_tlp_id_list(i)
       AND l_onetime_item_all_languages = 'Y';

  l_progress := '030';
  -- SQL What: Transfer from session GT table to local arrays
  -- SQL Why : It will be used to populate the OUT parameters.
  -- SQL Join: key
  DELETE FROM PO_SESSION_GT
  WHERE  key = l_key
  RETURNING num1, char1, char2, char3
  BULK COLLECT INTO
    x_tlp_id_to_be_copied_list, -- OUT parameters
    x_tlp_new_descriptions_list,
    x_tlp_language_list,
    x_tlp_long_descriptions_list; -- Bug7039409: Get tlp_long_description

  IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Number of rows deleted from GT table='||SQL%rowcount); END IF;

  IF PO_LOG.d_proc THEN PO_LOG.proc_end(d_mod); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN PO_LOG.exc(d_mod,l_progress,'Unhandled exception'); END IF;
    RAISE;
END get_translations;

--------------------------------------------------------------------------------
--Start of Comments
--Name: get_tlp_ids_for_lines
--Pre-reqs:
--  TLP row for the created/base language must exist.
--Modifies:
--  FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Gets the ATTRIBUTE_VALUES_TLP_ID's for each of the PO_LINE_ID
--  specified in the input array (TLP row for created_language).
--
--Parameters:
--IN:
--p_po_line_id_list
--  For the case when the parent doc is a Blanket or Quotation, this parameter
--  specifies the list of PO_LINE_ID's for which TLP rows need to be created.
--OUT:
--x_tlp_id_list
-- List of TLP ID's corresponding to each line for the created_language
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE get_tlp_ids_for_lines
(
  p_po_line_id_list IN PO_TBL_NUMBER
, x_tlp_id_list     OUT NOCOPY PO_TBL_NUMBER
)
IS
  d_mod CONSTANT VARCHAR2(100) := D_get_tlp_ids_for_lines;
  l_progress      VARCHAR2(4);

  l_attr_values_tlp_id PO_ATTRIBUTE_VALUES_TLP.attribute_values_tlp_id%TYPE;
  l_key PO_SESSION_GT.key%TYPE;
BEGIN
  l_progress := '010';

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_po_line_id_list',p_po_line_id_list);
  END IF;

  -- SQL What: Pick a new key from session GT sequence .
  -- SQL Why : To get tlp_id's
  -- SQL Join: none
  SELECT PO_SESSION_GT_S.nextval
  INTO l_key
  FROM DUAL;

  l_progress := '020';
  -- SQL What: Get the primary key to the TLP row of the created_language
  -- SQL Why : This TLP row will be copied when creating translations
  -- SQL Join: po_line_id, po_header_id, language
  FORALL i IN 1 .. p_po_line_id_list.COUNT
    INSERT INTO PO_SESSION_GT(key,
                              num1
                             )
    SELECT l_key,
           TLP.attribute_values_tlp_id
      FROM PO_ATTRIBUTE_VALUES_TLP TLP,
           PO_LINES_ALL POL,
           PO_HEADERS_ALL POH
     WHERE TLP.po_line_id = p_po_line_id_list(i)
       AND p_po_line_id_list(i) <> g_NOT_REQUIRED_ID
       AND POL.po_line_id = TLP.po_line_id
       AND POH.po_header_id = POL.po_header_id
       AND language = POH.created_language;

  l_progress := '030';
  -- SQL What: Transfer from session GT table to local arrays
  -- SQL Why : It will be used to populate the OUT parameters.
  -- SQL Join: key
  DELETE FROM PO_SESSION_GT
  WHERE  key = l_key
  RETURNING num1
  BULK COLLECT INTO x_tlp_id_list; -- OUT parameter

  IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Number of rows deleted from GT table='||SQL%rowcount); END IF;

  IF PO_LOG.d_proc THEN PO_LOG.proc_end(d_mod); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN PO_LOG.exc(d_mod,l_progress,'Unhandled exception'); END IF;
    RAISE;
END get_tlp_ids_for_lines;

--------------------------------------------------------------------------------
--Start of Comments
--Name: create_translations
--Pre-reqs:
--  TLP row for the created/base language must exist.
--Modifies:
--  FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Create Translations in the TLP table from one of the 2 sources:
--      a) INV Item Master (if item_id is not null)
--      b) Copies the TLP row of the session language to all othe langs
--         (if item_id is null)
--
--Parameters:
--IN:
--p_doc_type
--  Specifies the type of the parent documents of the attributes.
--p_default_lang_tlp_id
--  The default language for which the TLP row already exists. For blankets
--  and quotations, it is the created_language specified at the header level.
--  Whereas for Req Templates, it is always the Base language of the
--  installation.
--p_po_line_id_list
--  For the case when the parent doc is a Blanket or Quotation, this parameter
--  specifies the list of PO_LINE_ID's for which TLP rows need to be created.
--p_req_template_name
--p_req_template_line_num
--p_org_id
--  For the case when the parent doc is a Req Template, this parameter
--  specifies the req template line for which TLP rows need to be created.
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE create_translations
(
  p_doc_type                 IN VARCHAR2, -- 'BLANKET', 'QUOTATION', 'REQ_TEMPLATE'
  p_default_lang_tlp_id      IN PO_ATTRIBUTE_VALUES_TLP.attribute_values_tlp_id%TYPE DEFAULT NULL,
  p_po_line_id               IN PO_LINES.po_line_id%TYPE DEFAULT NULL,
  p_default_lang_tlp_id_list IN PO_TBL_NUMBER DEFAULT NULL,
  p_po_line_id_list          IN PO_TBL_NUMBER DEFAULT NULL,
  p_req_template_name        IN PO_REQEXPRESS_LINES_ALL.express_name%TYPE DEFAULT NULL,
  p_req_template_line_num    IN PO_REQEXPRESS_LINES_ALL.sequence_num%TYPE DEFAULT NULL,
  p_org_id                   IN PO_LINES_ALL.org_id%TYPE DEFAULT NULL
)
IS
  d_mod CONSTANT VARCHAR2(100) := D_create_translations;
  l_progress      VARCHAR2(4);

  l_attr_values_tlp_id PO_ATTRIBUTE_VALUES_TLP.attribute_values_tlp_id%TYPE;
  l_attr_values_tlp_id_list PO_TBL_NUMBER := PO_TBL_NUMBER();
  l_tlp_id_to_be_copied_list PO_TBL_NUMBER := PO_TBL_NUMBER();
  l_tlp_new_descriptions_list PO_TBL_VARCHAR480;-- := PO_TBL_VARCHAR480();
  l_tlp_language_list PO_TBL_VARCHAR4;-- := PO_TBL_VARCHAR4();
  l_tlp_long_descriptions_list PO_TBL_VARCHAR4000; -- Bug7039409: Declared new table -- Bug 18921232

  l_po_line_id_list PO_TBL_NUMBER := PO_TBL_NUMBER();
  l_default_lang_tlp_id_list PO_TBL_NUMBER := PO_TBL_NUMBER();
BEGIN
  l_progress := '010';

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_doc_type',p_doc_type);
    PO_LOG.proc_begin(d_mod,'p_default_lang_tlp_id',p_default_lang_tlp_id);
    PO_LOG.proc_begin(d_mod,'p_po_line_id',p_po_line_id);
    PO_LOG.proc_begin(d_mod,'p_default_lang_tlp_id_list',p_default_lang_tlp_id_list);
    PO_LOG.proc_begin(d_mod,'p_po_line_id_list',p_po_line_id_list);
    PO_LOG.proc_begin(d_mod,'p_req_template_name',p_req_template_name);
    PO_LOG.proc_begin(d_mod,'p_req_template_line_num',p_req_template_line_num);
    PO_LOG.proc_begin(d_mod,'p_org_id',p_org_id);
  END IF;

  -- Wrap single po_line_id into the list collection
  IF (p_po_line_id IS NOT NULL) THEN
    l_po_line_id_list.extend;
    l_po_line_id_list(1) := p_po_line_id;
  ELSE
    IF (p_po_line_id_list IS NOT NULL) THEN
      -- Copy the list into a local array
      FOR i IN 1 .. p_po_line_id_list.COUNT
      LOOP
        l_po_line_id_list.extend;
        l_po_line_id_list(i) := p_po_line_id_list(i);
      END LOOP;
    END IF;
  END IF;

  l_progress := '020';
  -- Wrap single tlp_id into the list collection
  IF (p_default_lang_tlp_id IS NOT NULL) THEN
    l_default_lang_tlp_id_list.extend;
    l_default_lang_tlp_id_list(1) := p_default_lang_tlp_id;
  ELSE
    IF (p_default_lang_tlp_id_list IS NOT NULL) THEN
      -- Copy the list into a local array
      FOR i IN 1 .. p_default_lang_tlp_id_list.COUNT
      LOOP
        l_default_lang_tlp_id_list.extend;
        l_default_lang_tlp_id_list(i) := p_default_lang_tlp_id_list(i);
      END LOOP;
    END IF;
  END IF;

  l_progress := '030';
  -- Sometimes, the calling program may not have the TLP row ID for that TLP row
  -- which will be used to copy records in other languages (e.g. when called from
  -- transfer program). In those cases, query up the record here
  IF (l_default_lang_tlp_id_list IS NULL OR
      (l_default_lang_tlp_id_list.COUNT = 0)) THEN

    IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Getting TLP IDs from the document(s)...'); END IF;

    IF (p_doc_type IN ('BLANKET', 'QUOTATION') ) THEN
      l_progress := '040';
      get_tlp_ids_for_lines
      (
        p_po_line_id_list => l_po_line_id_list
      , x_tlp_id_list     => l_attr_values_tlp_id_list -- OUT
      );
    ELSIF (p_doc_type = 'REQ_TEMPLATE' ) THEN
      l_progress := '050';
      -- SQL What: Get the primary key to the TLP row of the base_language
      -- SQL Why : This TLP row will be copied when creating translations
      -- SQL Join: org_id, req_template_name, req_template_line_num, language
      SELECT attribute_values_tlp_id
      BULK COLLECT INTO l_attr_values_tlp_id_list
      FROM PO_ATTRIBUTE_VALUES_TLP
      WHERE req_template_name = p_req_template_name
        AND req_template_line_num = p_req_template_line_num
        AND org_id = p_org_id
        AND p_req_template_line_num <> g_NOT_REQUIRED_ID
        AND language = g_base_language;

      IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Number of TLP IDs fetched for ReqTemplate='||l_attr_values_tlp_id_list.COUNT); END IF;
    END IF;
  ELSE -- l_default_lang_tlp_id_list IS NOT NULL
    l_progress := '060';
    -- Copy the list into a local array
    FOR i IN 1 .. l_default_lang_tlp_id_list.COUNT
    LOOP
      l_attr_values_tlp_id_list.extend;
      l_attr_values_tlp_id_list(i) := l_default_lang_tlp_id_list(i);
    END LOOP;
  END IF;

  l_progress := '070';
  get_translations
  (
    p_attr_values_tlp_id_list   => l_attr_values_tlp_id_list
  , x_tlp_id_to_be_copied_list  => l_tlp_id_to_be_copied_list  -- OUT
  , x_tlp_new_descriptions_list => l_tlp_new_descriptions_list -- OUT
  , x_tlp_language_list         => l_tlp_language_list         -- OUT
  -- Bug7039409: Added new param x_tlp_long_descriptions_list
  , x_tlp_long_descriptions_list => l_tlp_long_descriptions_list -- OUT
  );

  l_progress := '080';
  -- SQL What: Now insert into the TLP table. Check that TLP row for that
  --           language does already exist.
  -- SQL Why : To create translations in multiple languages
  -- SQL Join: attribute_values_tlp_id
  FORALL i IN 1 .. l_tlp_id_to_be_copied_list.COUNT
    INSERT INTO PO_ATTRIBUTE_VALUES_TLP TLP
    (
      attribute_values_tlp_id,
      description,
      language,

      -- ... ALL OTHER COLUMNS FROM TLP

      po_line_id,
      req_template_name,
      req_template_line_num,
      ip_category_id,
      inventory_item_id,
      org_id,
      manufacturer,
      comments,
      alias,
      long_description,
      tl_text_base_attribute1,
      tl_text_base_attribute2,
      tl_text_base_attribute3,
      tl_text_base_attribute4,
      tl_text_base_attribute5,
      tl_text_base_attribute6,
      tl_text_base_attribute7,
      tl_text_base_attribute8,
      tl_text_base_attribute9,
      tl_text_base_attribute10,
      tl_text_base_attribute11,
      tl_text_base_attribute12,
      tl_text_base_attribute13,
      tl_text_base_attribute14,
      tl_text_base_attribute15,
      tl_text_base_attribute16,
      tl_text_base_attribute17,
      tl_text_base_attribute18,
      tl_text_base_attribute19,
      tl_text_base_attribute20,
      tl_text_base_attribute21,
      tl_text_base_attribute22,
      tl_text_base_attribute23,
      tl_text_base_attribute24,
      tl_text_base_attribute25,
      tl_text_base_attribute26,
      tl_text_base_attribute27,
      tl_text_base_attribute28,
      tl_text_base_attribute29,
      tl_text_base_attribute30,
      tl_text_base_attribute31,
      tl_text_base_attribute32,
      tl_text_base_attribute33,
      tl_text_base_attribute34,
      tl_text_base_attribute35,
      tl_text_base_attribute36,
      tl_text_base_attribute37,
      tl_text_base_attribute38,
      tl_text_base_attribute39,
      tl_text_base_attribute40,
      tl_text_base_attribute41,
      tl_text_base_attribute42,
      tl_text_base_attribute43,
      tl_text_base_attribute44,
      tl_text_base_attribute45,
      tl_text_base_attribute46,
      tl_text_base_attribute47,
      tl_text_base_attribute48,
      tl_text_base_attribute49,
      tl_text_base_attribute50,
      tl_text_base_attribute51,
      tl_text_base_attribute52,
      tl_text_base_attribute53,
      tl_text_base_attribute54,
      tl_text_base_attribute55,
      tl_text_base_attribute56,
      tl_text_base_attribute57,
      tl_text_base_attribute58,
      tl_text_base_attribute59,
      tl_text_base_attribute60,
      tl_text_base_attribute61,
      tl_text_base_attribute62,
      tl_text_base_attribute63,
      tl_text_base_attribute64,
      tl_text_base_attribute65,
      tl_text_base_attribute66,
      tl_text_base_attribute67,
      tl_text_base_attribute68,
      tl_text_base_attribute69,
      tl_text_base_attribute70,
      tl_text_base_attribute71,
      tl_text_base_attribute72,
      tl_text_base_attribute73,
      tl_text_base_attribute74,
      tl_text_base_attribute75,
      tl_text_base_attribute76,
      tl_text_base_attribute77,
      tl_text_base_attribute78,
      tl_text_base_attribute79,
      tl_text_base_attribute80,
      tl_text_base_attribute81,
      tl_text_base_attribute82,
      tl_text_base_attribute83,
      tl_text_base_attribute84,
      tl_text_base_attribute85,
      tl_text_base_attribute86,
      tl_text_base_attribute87,
      tl_text_base_attribute88,
      tl_text_base_attribute89,
      tl_text_base_attribute90,
      tl_text_base_attribute91,
      tl_text_base_attribute92,
      tl_text_base_attribute93,
      tl_text_base_attribute94,
      tl_text_base_attribute95,
      tl_text_base_attribute96,
      tl_text_base_attribute97,
      tl_text_base_attribute98,
      tl_text_base_attribute99,
      tl_text_base_attribute100,
      tl_text_cat_attribute1,
      tl_text_cat_attribute2,
      tl_text_cat_attribute3,
      tl_text_cat_attribute4,
      tl_text_cat_attribute5,
      tl_text_cat_attribute6,
      tl_text_cat_attribute7,
      tl_text_cat_attribute8,
      tl_text_cat_attribute9,
      tl_text_cat_attribute10,
      tl_text_cat_attribute11,
      tl_text_cat_attribute12,
      tl_text_cat_attribute13,
      tl_text_cat_attribute14,
      tl_text_cat_attribute15,
      tl_text_cat_attribute16,
      tl_text_cat_attribute17,
      tl_text_cat_attribute18,
      tl_text_cat_attribute19,
      tl_text_cat_attribute20,
      tl_text_cat_attribute21,
      tl_text_cat_attribute22,
      tl_text_cat_attribute23,
      tl_text_cat_attribute24,
      tl_text_cat_attribute25,
      tl_text_cat_attribute26,
      tl_text_cat_attribute27,
      tl_text_cat_attribute28,
      tl_text_cat_attribute29,
      tl_text_cat_attribute30,
      tl_text_cat_attribute31,
      tl_text_cat_attribute32,
      tl_text_cat_attribute33,
      tl_text_cat_attribute34,
      tl_text_cat_attribute35,
      tl_text_cat_attribute36,
      tl_text_cat_attribute37,
      tl_text_cat_attribute38,
      tl_text_cat_attribute39,
      tl_text_cat_attribute40,
      tl_text_cat_attribute41,
      tl_text_cat_attribute42,
      tl_text_cat_attribute43,
      tl_text_cat_attribute44,
      tl_text_cat_attribute45,
      tl_text_cat_attribute46,
      tl_text_cat_attribute47,
      tl_text_cat_attribute48,
      tl_text_cat_attribute49,
      tl_text_cat_attribute50,
      last_update_login,
      last_updated_by,
      last_update_date,
      created_by,
      creation_date,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      last_updated_program
    )
    SELECT
      PO_ATTRIBUTE_VALUES_TLP_S.nextval,
      l_tlp_new_descriptions_list(i),
      l_tlp_language_list(i),

      -- ... ALL OTHER COLUMNS FROM TLP

      TLP1.po_line_id,
      TLP1.req_template_name,
      TLP1.req_template_line_num,
      TLP1.ip_category_id,
      TLP1.inventory_item_id,
      TLP1.org_id,
      TLP1.manufacturer,               -- Copy value from base lang
      TLP1.comments,
      TLP1.alias,
      -- Bug7039409: Get long_description from l_tlp_long_descriptions_list
      -- instead of TLP1.long_description
      l_tlp_long_descriptions_list(i),
      TLP1.tl_text_base_attribute1,
      TLP1.tl_text_base_attribute2,
      TLP1.tl_text_base_attribute3,
      TLP1.tl_text_base_attribute4,
      TLP1.tl_text_base_attribute5,
      TLP1.tl_text_base_attribute6,
      TLP1.tl_text_base_attribute7,
      TLP1.tl_text_base_attribute8,
      TLP1.tl_text_base_attribute9,
      TLP1.tl_text_base_attribute10,
      TLP1.tl_text_base_attribute11,
      TLP1.tl_text_base_attribute12,
      TLP1.tl_text_base_attribute13,
      TLP1.tl_text_base_attribute14,
      TLP1.tl_text_base_attribute15,
      TLP1.tl_text_base_attribute16,
      TLP1.tl_text_base_attribute17,
      TLP1.tl_text_base_attribute18,
      TLP1.tl_text_base_attribute19,
      TLP1.tl_text_base_attribute20,
      TLP1.tl_text_base_attribute21,
      TLP1.tl_text_base_attribute22,
      TLP1.tl_text_base_attribute23,
      TLP1.tl_text_base_attribute24,
      TLP1.tl_text_base_attribute25,
      TLP1.tl_text_base_attribute26,
      TLP1.tl_text_base_attribute27,
      TLP1.tl_text_base_attribute28,
      TLP1.tl_text_base_attribute29,
      TLP1.tl_text_base_attribute30,
      TLP1.tl_text_base_attribute31,
      TLP1.tl_text_base_attribute32,
      TLP1.tl_text_base_attribute33,
      TLP1.tl_text_base_attribute34,
      TLP1.tl_text_base_attribute35,
      TLP1.tl_text_base_attribute36,
      TLP1.tl_text_base_attribute37,
      TLP1.tl_text_base_attribute38,
      TLP1.tl_text_base_attribute39,
      TLP1.tl_text_base_attribute40,
      TLP1.tl_text_base_attribute41,
      TLP1.tl_text_base_attribute42,
      TLP1.tl_text_base_attribute43,
      TLP1.tl_text_base_attribute44,
      TLP1.tl_text_base_attribute45,
      TLP1.tl_text_base_attribute46,
      TLP1.tl_text_base_attribute47,
      TLP1.tl_text_base_attribute48,
      TLP1.tl_text_base_attribute49,
      TLP1.tl_text_base_attribute50,
      TLP1.tl_text_base_attribute51,
      TLP1.tl_text_base_attribute52,
      TLP1.tl_text_base_attribute53,
      TLP1.tl_text_base_attribute54,
      TLP1.tl_text_base_attribute55,
      TLP1.tl_text_base_attribute56,
      TLP1.tl_text_base_attribute57,
      TLP1.tl_text_base_attribute58,
      TLP1.tl_text_base_attribute59,
      TLP1.tl_text_base_attribute60,
      TLP1.tl_text_base_attribute61,
      TLP1.tl_text_base_attribute62,
      TLP1.tl_text_base_attribute63,
      TLP1.tl_text_base_attribute64,
      TLP1.tl_text_base_attribute65,
      TLP1.tl_text_base_attribute66,
      TLP1.tl_text_base_attribute67,
      TLP1.tl_text_base_attribute68,
      TLP1.tl_text_base_attribute69,
      TLP1.tl_text_base_attribute70,
      TLP1.tl_text_base_attribute71,
      TLP1.tl_text_base_attribute72,
      TLP1.tl_text_base_attribute73,
      TLP1.tl_text_base_attribute74,
      TLP1.tl_text_base_attribute75,
      TLP1.tl_text_base_attribute76,
      TLP1.tl_text_base_attribute77,
      TLP1.tl_text_base_attribute78,
      TLP1.tl_text_base_attribute79,
      TLP1.tl_text_base_attribute80,
      TLP1.tl_text_base_attribute81,
      TLP1.tl_text_base_attribute82,
      TLP1.tl_text_base_attribute83,
      TLP1.tl_text_base_attribute84,
      TLP1.tl_text_base_attribute85,
      TLP1.tl_text_base_attribute86,
      TLP1.tl_text_base_attribute87,
      TLP1.tl_text_base_attribute88,
      TLP1.tl_text_base_attribute89,
      TLP1.tl_text_base_attribute90,
      TLP1.tl_text_base_attribute91,
      TLP1.tl_text_base_attribute92,
      TLP1.tl_text_base_attribute93,
      TLP1.tl_text_base_attribute94,
      TLP1.tl_text_base_attribute95,
      TLP1.tl_text_base_attribute96,
      TLP1.tl_text_base_attribute97,
      TLP1.tl_text_base_attribute98,
      TLP1.tl_text_base_attribute99,
      TLP1.tl_text_base_attribute100,
      TLP1.tl_text_cat_attribute1,
      TLP1.tl_text_cat_attribute2,
      TLP1.tl_text_cat_attribute3,
      TLP1.tl_text_cat_attribute4,
      TLP1.tl_text_cat_attribute5,
      TLP1.tl_text_cat_attribute6,
      TLP1.tl_text_cat_attribute7,
      TLP1.tl_text_cat_attribute8,
      TLP1.tl_text_cat_attribute9,
      TLP1.tl_text_cat_attribute10,
      TLP1.tl_text_cat_attribute11,
      TLP1.tl_text_cat_attribute12,
      TLP1.tl_text_cat_attribute13,
      TLP1.tl_text_cat_attribute14,
      TLP1.tl_text_cat_attribute15,
      TLP1.tl_text_cat_attribute16,
      TLP1.tl_text_cat_attribute17,
      TLP1.tl_text_cat_attribute18,
      TLP1.tl_text_cat_attribute19,
      TLP1.tl_text_cat_attribute20,
      TLP1.tl_text_cat_attribute21,
      TLP1.tl_text_cat_attribute22,
      TLP1.tl_text_cat_attribute23,
      TLP1.tl_text_cat_attribute24,
      TLP1.tl_text_cat_attribute25,
      TLP1.tl_text_cat_attribute26,
      TLP1.tl_text_cat_attribute27,
      TLP1.tl_text_cat_attribute28,
      TLP1.tl_text_cat_attribute29,
      TLP1.tl_text_cat_attribute30,
      TLP1.tl_text_cat_attribute31,
      TLP1.tl_text_cat_attribute32,
      TLP1.tl_text_cat_attribute33,
      TLP1.tl_text_cat_attribute34,
      TLP1.tl_text_cat_attribute35,
      TLP1.tl_text_cat_attribute36,
      TLP1.tl_text_cat_attribute37,
      TLP1.tl_text_cat_attribute38,
      TLP1.tl_text_cat_attribute39,
      TLP1.tl_text_cat_attribute40,
      TLP1.tl_text_cat_attribute41,
      TLP1.tl_text_cat_attribute42,
      TLP1.tl_text_cat_attribute43,
      TLP1.tl_text_cat_attribute44,
      TLP1.tl_text_cat_attribute45,
      TLP1.tl_text_cat_attribute46,
      TLP1.tl_text_cat_attribute47,
      TLP1.tl_text_cat_attribute48,
      TLP1.tl_text_cat_attribute49,
      TLP1.tl_text_cat_attribute50,
      FND_GLOBAL.login_id,        -- last_update_login
      FND_GLOBAL.user_id,         -- last_updated_by
      sysdate,                    -- last_update_date
      FND_GLOBAL.user_id,         -- created_by
      sysdate,                    -- creation_date
      FND_GLOBAL.conc_request_id, -- request_id
      TLP1.program_application_id,
      TLP1.program_id,
      TLP1.program_update_date,
      d_mod                       -- last_updated_program
    FROM PO_ATTRIBUTE_VALUES_TLP TLP1
    WHERE TLP1.attribute_values_tlp_id = l_tlp_id_to_be_copied_list(i)
      AND NOT EXISTS
          (SELECT 'TLP row for this language already exists'
           FROM PO_ATTRIBUTE_VALUES_TLP TLP2
           WHERE TLP2.po_line_id = TLP1.po_line_id
            AND TLP2.req_template_name = TLP1.req_template_name
            AND TLP2.req_template_line_num = TLP1.req_template_line_num
            AND TLP2.org_id = TLP1.org_id
            AND TLP2.language = l_tlp_language_list(i));

  l_progress := '090';
  IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Number of rows inserted into TLP table='||SQL%rowcount); END IF;

  IF PO_LOG.d_proc THEN PO_LOG.proc_end(d_mod); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN PO_LOG.exc(d_mod,l_progress,'Unhandled exception'); END IF;
    RAISE;
END create_translations;

--------------------------------------------------------------------------------
--Start of Comments
--Name: create_default_attr_tlp
--Pre-reqs:
--  None
--Modifies:
--  FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  To insert a row for the Attribute Values and TLP by defaulting values
--  from the line level.
--
--Parameters:
--IN:
--p_po_line_id
--p_req_template_name
--p_req_template_line_num
--p_ip_category_id
--p_inventory_item_id
--p_org_id
--p_description
--p_manufacturer
--  The default values of the Attr given by the calling program.
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE create_default_attr_tlp
(
  p_doc_type              IN VARCHAR2, -- 'BLANKET', 'QUOTATION', 'REQ_TEMPLATE'
  p_po_line_id            IN PO_LINES.po_line_id%TYPE,
  p_req_template_name     IN PO_REQEXPRESS_LINES_ALL.express_name%TYPE,
  p_req_template_line_num IN PO_REQEXPRESS_LINES_ALL.sequence_num%TYPE,
  p_ip_category_id        IN PO_LINES_ALL.ip_category_id%TYPE,
  p_inventory_item_id     IN PO_LINES_ALL.item_id%TYPE,
  p_org_id                IN PO_LINES_ALL.org_id%TYPE,
  p_description           IN PO_ATTRIBUTE_VALUES_TLP.description%TYPE,
  -- Bug 7039409: Added new param p_manufacturer
  p_manufacturer          IN PO_ATTRIBUTE_VALUES_TLP.manufacturer%TYPE
)
IS
  d_mod CONSTANT VARCHAR2(100) := D_create_default_attr_tlp;
  l_progress      VARCHAR2(4);

  l_default_lang PO_HEADERS_ALL.created_language%TYPE;
  l_description  PO_ATTRIBUTE_VALUES_TLP.description%TYPE;
  l_long_description PO_ATTRIBUTE_VALUES_TLP.long_description%TYPE;
BEGIN
  l_progress := '010';

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_doc_type',p_doc_type);
    PO_LOG.proc_begin(d_mod,'p_po_line_id',p_po_line_id);
    PO_LOG.proc_begin(d_mod,'p_req_template_name',p_req_template_name);
    PO_LOG.proc_begin(d_mod,'p_req_template_line_num',p_req_template_line_num);
    PO_LOG.proc_begin(d_mod,'p_org_id',p_org_id);
    PO_LOG.proc_begin(d_mod,'p_ip_category_id',p_ip_category_id);
    PO_LOG.proc_begin(d_mod,'p_inventory_item_id',p_inventory_item_id);
    PO_LOG.proc_begin(d_mod,'p_description',p_description);
    PO_LOG.proc_begin(d_mod,'p_manufacturer',p_manufacturer);
  END IF;

  IF (p_po_line_id IS NOT NULL) THEN
    l_progress := '020';
    -- SQL What: Get the created_language of the header, for the given line
    -- SQL Why : To create a default Attr TLP row for the default language
    -- SQL Join: po_line_id, po_header_id
    SELECT POH.created_language
    INTO l_default_lang
    FROM PO_HEADERS_ALL POH,
         PO_LINES_ALL POL
    WHERE POH.po_header_id = POL.po_header_id
      AND POL.po_line_id = p_po_line_id;
  ELSE
    l_progress := '030';
    l_default_lang := g_base_language;
  END IF;

  l_description := p_description;

  -- Bug 7039409: Get the tlp item attribute values.
  IF p_inventory_item_id IS NOT NULL THEN
    get_item_attributes_tlp_values(
      p_inventory_item_id,
      l_default_lang,
      l_long_description);
  END IF;

  l_progress := '050';
  -- SQL What: Insert default rows for Attribute values TLP.
  --           This SQL will insert multiple rows, one for each installed lang.
  -- SQL Why : To create a default Attr TLP row
  -- SQL Join: po_line_id
  INSERT INTO PO_ATTRIBUTE_VALUES_TLP (
    attribute_values_tlp_id,
    po_line_id,
    req_template_name,
    req_template_line_num,
    ip_category_id,
    inventory_item_id,
    org_id,
    language,
    description,
    manufacturer,
    long_description,
    -- WHO columns
    last_update_login,
    last_updated_by,
    last_update_date,
    created_by,
    creation_date,
    request_id,
    program_application_id,
    program_id,
    program_update_date,
    last_updated_program
   )
   SELECT
    PO_ATTRIBUTE_VALUES_TLP_S.nextval,
    NVL(p_po_line_id,-2),
    NVL(p_req_template_name,'-2'),
    NVL(p_req_template_line_num,-2),
    NVL(p_ip_category_id,-2),
    NVL(p_inventory_item_id,-2),
    NVL(p_org_id,-2),
    l_default_lang,
    l_description,
    p_manufacturer,
    l_long_description,
    -- WHO columns
    FND_GLOBAL.login_id,        -- last_update_login
    FND_GLOBAL.user_id,         -- last_updated_by
    sysdate,                    -- last_update_date
    FND_GLOBAL.user_id,         -- created_by
    sysdate,                    -- creation_date
    FND_GLOBAL.conc_request_id, -- request_id
    FND_GLOBAL.prog_appl_id,    -- program_application_id
    FND_GLOBAL.conc_program_id, -- program_id
    sysdate,                    -- program_update_date
    d_mod                       -- last_updated_program
   FROM DUAL
   WHERE NOT EXISTS
     (SELECT 'TLP row for this language already exists'
      FROM PO_ATTRIBUTE_VALUES_TLP TLP2
      WHERE TLP2.po_line_id = NVL(p_po_line_id,-2)
       AND TLP2.req_template_name = p_req_template_name
       AND TLP2.req_template_line_num = p_req_template_line_num
       AND TLP2.org_id = p_org_id
       AND TLP2.language = l_default_lang);

  l_progress := '060';
  IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Number of rows inserted in TLP table='||SQL%rowcount); END IF;

  create_translations
  (
    p_doc_type              => p_doc_type,
    p_po_line_id            => p_po_line_id,
    p_req_template_name     => p_req_template_name,
    p_req_template_line_num => p_req_template_line_num,
    p_org_id                => p_org_id
  );

  IF PO_LOG.d_proc THEN PO_LOG.proc_end(d_mod); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN PO_LOG.exc(d_mod,l_progress,'Unhandled exception'); END IF;
    RAISE;
END create_default_attr_tlp;

--------------------------------------------------------------------------------
--Start of Comments
--Name: create_default_attributes
--Pre-reqs:
--  None
--Modifies:
--  FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  To insert a row for the Attribute Values and TLP by defaulting values
--  from the line level.
--
--Parameters:
--IN:
--p_po_line_id
--p_req_template_name
--p_req_template_line_num
--p_ip_category_id
--p_inventory_item_id
--p_org_id
--  The default values of the Attr given by the calling program.
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE create_default_attributes
(
  p_doc_type              IN VARCHAR2, -- 'BLANKET', 'QUOTATION', 'REQ_TEMPLATE'
  p_po_line_id            IN PO_LINES.po_line_id%TYPE,
  p_req_template_name     IN PO_REQEXPRESS_LINES_ALL.express_name%TYPE,
  p_req_template_line_num IN PO_REQEXPRESS_LINES_ALL.sequence_num%TYPE,
  p_ip_category_id        IN PO_LINES_ALL.ip_category_id%TYPE,
  p_inventory_item_id     IN PO_LINES_ALL.item_id%TYPE,
  p_org_id                IN PO_LINES_ALL.org_id%TYPE,
  p_description           IN PO_ATTRIBUTE_VALUES_TLP.description%TYPE
)
IS
  d_mod CONSTANT VARCHAR2(100) := D_create_default_attributes;
  l_progress      VARCHAR2(4);

  l_type_lookup_code PO_HEADERS_ALL.type_lookup_code%TYPE;
  -- Bug 7039409: Declared new variables
  l_manufacturer_part_num PO_ATTRIBUTE_VALUES.manufacturer_part_num%TYPE;
  l_manufacturer          PO_ATTRIBUTE_VALUES_TLP.manufacturer%TYPE;
  l_lead_time             PO_ATTRIBUTE_VALUES.lead_time%TYPE;
BEGIN
  l_progress := '010';

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_doc_type',p_doc_type);
    PO_LOG.proc_begin(d_mod,'p_po_line_id',p_po_line_id);
    PO_LOG.proc_begin(d_mod,'p_req_template_name',p_req_template_name);
    PO_LOG.proc_begin(d_mod,'p_req_template_line_num',p_req_template_line_num);
    PO_LOG.proc_begin(d_mod,'p_org_id',p_org_id);
    PO_LOG.proc_begin(d_mod,'p_ip_category_id',p_ip_category_id);
    PO_LOG.proc_begin(d_mod,'p_inventory_item_id',p_inventory_item_id);
    PO_LOG.proc_begin(d_mod,'p_description',p_description);
  END IF;

  l_progress := '020';
  IF (p_po_line_id IS NOT NULL) THEN
    IF (p_doc_type IS NULL) THEN
      l_progress := '030';
      -- SQL What: Get the document type for the PO line
      -- SQL Why : To check if it BLANKET or QUOTATION or not
      -- SQL Join: po_line_id
      SELECT POH.type_lookup_code
      INTO l_type_lookup_code
      FROM PO_HEADERS_ALL POH,
           PO_LINES_ALL POL
      WHERE POL.po_line_id = p_po_line_id
        AND POH.po_header_id = POL.po_header_id;
    ELSE
      l_type_lookup_code := p_doc_type;
    END IF;

    -- Do not create Attr/TLP if the doc type is not BLANKET or QUOTATION
    IF (l_type_lookup_code NOT IN ('BLANKET', 'QUOTATION')) THEN
      IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Returning without creating Attr/TLP. Doc type='||l_type_lookup_code); END IF;
      RETURN;
    END IF;
  END IF;

  -- Bug 7039409: Get the item attribute values.
  IF p_inventory_item_id IS NOT NULL THEN
    get_item_attributes_values(
      p_inventory_item_id,
      l_manufacturer_part_num,
      l_manufacturer,
      l_lead_time);
  END IF;

  l_progress := '040';
  -- SQL What: Insert a new row for Attribute values
  -- SQL Why : To create a default Attr row
  -- SQL Join: none
  INSERT INTO PO_ATTRIBUTE_VALUES (
    attribute_values_id,
    po_line_id,
    req_template_name,
    req_template_line_num,
    ip_category_id,
    inventory_item_id,
    org_id,
    manufacturer_part_num,
    lead_time,
    -- WHO columns
    last_update_login,
    last_updated_by,
    last_update_date,
    created_by,
    creation_date,
    request_id,
    program_application_id,
    program_id,
    program_update_date,
    last_updated_program
   )
   SELECT
    PO_ATTRIBUTE_VALUES_S.nextval,
    NVL(p_po_line_id,-2),
    NVL(p_req_template_name,'-2'),
    NVL(p_req_template_line_num,-2),
    NVL(p_ip_category_id,-2),
    NVL(p_inventory_item_id,-2),
    NVL(p_org_id,-2),
    l_manufacturer_part_num,
    l_lead_time,
    -- WHO columns
    FND_GLOBAL.login_id,        -- last_update_login
    FND_GLOBAL.user_id,         -- last_updated_by
    sysdate,                    -- last_update_date
    FND_GLOBAL.user_id,         -- created_by
    sysdate,                    -- creation_date
    FND_GLOBAL.conc_request_id, -- request_id
    FND_GLOBAL.prog_appl_id,    -- program_application_id
    FND_GLOBAL.conc_program_id, -- program_id
    sysdate,                    -- program_update_date
    d_mod                       -- last_updated_program
   FROM DUAL
   WHERE NOT EXISTS
     (SELECT 'Attribute row already exists'
      FROM PO_ATTRIBUTE_VALUES POATR
      WHERE POATR.po_line_id = NVL(p_po_line_id,-2)          --Added nvl for bug 15872639
       AND POATR.req_template_name = p_req_template_name
       AND POATR.req_template_line_num = p_req_template_line_num
       AND POATR.org_id = p_org_id);

  l_progress := '050';
  IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Number of rows inserted in ATR table='||SQL%rowcount); END IF;

  create_default_attr_tlp
  (
    p_doc_type              => p_doc_type,
    p_po_line_id            => p_po_line_id,
    p_req_template_name     => p_req_template_name,
    p_req_template_line_num => p_req_template_line_num,
    p_ip_category_id        => p_ip_category_id,
    p_inventory_item_id     => p_inventory_item_id,
    p_org_id                => p_org_id,
    p_description           => p_description,
    p_manufacturer          => l_manufacturer -- Bug7039409: Added new param
  );

  IF PO_LOG.d_proc THEN PO_LOG.proc_end(d_mod); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN PO_LOG.exc(d_mod,l_progress,'Unhandled exception'); END IF;
    RAISE;
END create_default_attributes;

PROCEDURE create_default_attributes_MI
(
  p_ip_category_id        IN PO_LINES_ALL.ip_category_id%TYPE,
  p_inventory_item_id     IN PO_LINES_ALL.item_id%TYPE,
  p_org_id                IN PO_LINES_ALL.org_id%TYPE,
  p_description           IN PO_ATTRIBUTE_VALUES_TLP.description%TYPE,
  p_organization_id       IN NUMBER,
  p_master_organization_id IN NUMBER
)
IS
  d_mod CONSTANT VARCHAR2(100) := D_create_default_attributes_MI;
  l_progress      VARCHAR2(4);
  l_manufacturer_part_num   PO_ATTRIBUTE_VALUES.MANUFACTURER_PART_NUM%TYPE;
  l_proc_lead_time   PO_ATTRIBUTE_VALUES.LEAD_TIME%TYPE;
  l_type_lookup_code PO_HEADERS_ALL.type_lookup_code%TYPE;
BEGIN
  l_progress := '010';

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_org_id',p_org_id);
    PO_LOG.proc_begin(d_mod,'p_ip_category_id',p_ip_category_id);
    PO_LOG.proc_begin(d_mod,'p_inventory_item_id',p_inventory_item_id);
    PO_LOG.proc_begin(d_mod,'p_description',p_description);
    PO_LOG.proc_begin(d_mod,'p_organization_id', p_organization_id);
    PO_LOG.proc_begin(d_mod,'p_master_organization_id',p_master_organization_id);
  END IF;

  l_progress := '020';

  -- list down the base descriptors in PO_ATTRIBUTE_VALUES
  -- LEAD_TIME     AVAILABILITY    UNSPSC    MANUFACTURER_PART_NUM
  -- PICTURE   THUMBNAIL_IMAGE   SUPPLIER_URL  MANUFACTURER_URL
  -- ATTACHMENT_URL
  BEGIN

  SELECT MFG_PART_NUM
  INTO l_manufacturer_part_num
  FROM(
       SELECT * FROM  MTL_MFG_PART_NUMBERS_ALL_V
       WHERE INVENTORY_ITEM_ID = p_inventory_item_id
       AND ORGANIZATION_ID = p_master_organization_id
       ORDER BY ROW_ID
      ) WHERE ROWNUM =1;

  EXCEPTION
  WHEN No_Data_Found THEN
    l_manufacturer_part_num:='';
  END;



  SELECT FULL_LEAD_TIME
  INTO l_proc_lead_time
  FROM mtl_system_items_b
  WHERE INVENTORY_ITEM_ID = p_inventory_item_id
  AND ORGANIZATION_ID = p_organization_id;



  IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,' MANUFACTURER_PART_NUM='||l_manufacturer_part_num||' Lead_Time ='||l_proc_lead_time); END IF;


  l_progress := '030';
  -- SQL What: Insert a new row for Attribute values
  -- SQL Why : To create a default Attr row
  -- SQL Join: none
  INSERT INTO PO_ATTRIBUTE_VALUES (
    attribute_values_id,
    po_line_id,
    req_template_name,
    req_template_line_num,
    ip_category_id,
    inventory_item_id,
    org_id,
    MANUFACTURER_PART_NUM,
    LEAD_TIME,
    -- WHO columns
    last_update_login,
    last_updated_by,
    last_update_date,
    created_by,
    creation_date,
    request_id,
    program_application_id,
    program_id,
    program_update_date,
    last_updated_program
   )
   SELECT
    PO_ATTRIBUTE_VALUES_S.nextval,
    -2,
    '-2',
    -2,
    NVL(p_ip_category_id,-2),
    NVL(p_inventory_item_id,-2),
    NVL(p_org_id,-2),
    l_manufacturer_part_num,
    l_proc_lead_time,
    -- WHO columns
    FND_GLOBAL.login_id,        -- last_update_login
    FND_GLOBAL.user_id,         -- last_updated_by
    sysdate,                    -- last_update_date
    FND_GLOBAL.user_id,         -- created_by
    sysdate,                    -- creation_date
    FND_GLOBAL.conc_request_id, -- request_id
    FND_GLOBAL.prog_appl_id,    -- program_application_id
    FND_GLOBAL.conc_program_id, -- program_id
    sysdate,                    -- program_update_date
    d_mod                       -- last_updated_program
   FROM DUAL
   WHERE NOT EXISTS
     (SELECT 'Attribute row already exists'
      FROM PO_ATTRIBUTE_VALUES POATR
      WHERE POATR.inventory_item_id = p_inventory_item_id
        AND POATR.org_id = p_org_id
        AND POATR.po_line_id   = -2
        AND POATR.req_template_name = '-2'
        AND POATR.req_template_line_num = -2);

  l_progress := '040';
  IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Number of rows inserted in ATR table='||SQL%rowcount); END IF;

  IF PO_LOG.d_proc THEN PO_LOG.proc_end(d_mod); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN PO_LOG.exc(d_mod,l_progress,'Unhandled exception'); END IF;
    RAISE;
END create_default_attributes_MI;

-- this is for master items

PROCEDURE wipeout_category_attributes_MI
(
  p_org_id                IN PO_LINES_ALL.org_id%TYPE,
  p_ip_category_id        IN PO_LINES_ALL.ip_category_id%TYPE,
  p_inventory_item_id     IN PO_ATTRIBUTE_VALUES_TLP.inventory_item_id%TYPE,
  p_language              IN PO_ATTRIBUTE_VALUES_TLP.language%TYPE,
  p_item_description      IN PO_ATTRIBUTE_VALUES_TLP.description%TYPE
)
IS
  d_mod CONSTANT VARCHAR2(100) := D_wipeout_category_attributes||'_MI';
  l_progress      VARCHAR2(4);

BEGIN
  l_progress := '010';

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_ip_category_id',p_ip_category_id);
    PO_LOG.proc_begin(d_mod,'p_inventory_item_id',p_inventory_item_id);
    PO_LOG.proc_begin(d_mod,'p_language',p_language);
    PO_LOG.proc_begin(d_mod,'p_org_id',p_org_id);
  END IF;

  l_progress := '020';
  -- SQL What: Wipeout category based attributes from AttributeValues table
  -- SQL Why : Because the category was changed
  -- SQL Join: po_line_id, req_template_name, req_template_line_num, org_id
  UPDATE PO_ATTRIBUTE_VALUES
  SET
    NUM_CAT_ATTRIBUTE1 = NULL,
    NUM_CAT_ATTRIBUTE2 = NULL,
    NUM_CAT_ATTRIBUTE3 = NULL,
    NUM_CAT_ATTRIBUTE4 = NULL,
    NUM_CAT_ATTRIBUTE5 = NULL,
    NUM_CAT_ATTRIBUTE6 = NULL,
    NUM_CAT_ATTRIBUTE7 = NULL,
    NUM_CAT_ATTRIBUTE8 = NULL,
    NUM_CAT_ATTRIBUTE9 = NULL,
    NUM_CAT_ATTRIBUTE10 = NULL,
    NUM_CAT_ATTRIBUTE11 = NULL,
    NUM_CAT_ATTRIBUTE12 = NULL,
    NUM_CAT_ATTRIBUTE13 = NULL,
    NUM_CAT_ATTRIBUTE14 = NULL,
    NUM_CAT_ATTRIBUTE15 = NULL,
    NUM_CAT_ATTRIBUTE16 = NULL,
    NUM_CAT_ATTRIBUTE17 = NULL,
    NUM_CAT_ATTRIBUTE18 = NULL,
    NUM_CAT_ATTRIBUTE19 = NULL,
    NUM_CAT_ATTRIBUTE20 = NULL,
    NUM_CAT_ATTRIBUTE21 = NULL,
    NUM_CAT_ATTRIBUTE22 = NULL,
    NUM_CAT_ATTRIBUTE23 = NULL,
    NUM_CAT_ATTRIBUTE24 = NULL,
    NUM_CAT_ATTRIBUTE25 = NULL,
    NUM_CAT_ATTRIBUTE26 = NULL,
    NUM_CAT_ATTRIBUTE27 = NULL,
    NUM_CAT_ATTRIBUTE28 = NULL,
    NUM_CAT_ATTRIBUTE29 = NULL,
    NUM_CAT_ATTRIBUTE30 = NULL,
    NUM_CAT_ATTRIBUTE31 = NULL,
    NUM_CAT_ATTRIBUTE32 = NULL,
    NUM_CAT_ATTRIBUTE33 = NULL,
    NUM_CAT_ATTRIBUTE34 = NULL,
    NUM_CAT_ATTRIBUTE35 = NULL,
    NUM_CAT_ATTRIBUTE36 = NULL,
    NUM_CAT_ATTRIBUTE37 = NULL,
    NUM_CAT_ATTRIBUTE38 = NULL,
    NUM_CAT_ATTRIBUTE39 = NULL,
    NUM_CAT_ATTRIBUTE40 = NULL,
    NUM_CAT_ATTRIBUTE41 = NULL,
    NUM_CAT_ATTRIBUTE42 = NULL,
    NUM_CAT_ATTRIBUTE43 = NULL,
    NUM_CAT_ATTRIBUTE44 = NULL,
    NUM_CAT_ATTRIBUTE45 = NULL,
    NUM_CAT_ATTRIBUTE46 = NULL,
    NUM_CAT_ATTRIBUTE47 = NULL,
    NUM_CAT_ATTRIBUTE48 = NULL,
    NUM_CAT_ATTRIBUTE49 = NULL,
    NUM_CAT_ATTRIBUTE50 = NULL,
    TEXT_CAT_ATTRIBUTE1 = NULL,
    TEXT_CAT_ATTRIBUTE2 = NULL,
    TEXT_CAT_ATTRIBUTE3 = NULL,
    TEXT_CAT_ATTRIBUTE4 = NULL,
    TEXT_CAT_ATTRIBUTE5 = NULL,
    TEXT_CAT_ATTRIBUTE6 = NULL,
    TEXT_CAT_ATTRIBUTE7 = NULL,
    TEXT_CAT_ATTRIBUTE8 = NULL,
    TEXT_CAT_ATTRIBUTE9 = NULL,
    TEXT_CAT_ATTRIBUTE10 = NULL,
    TEXT_CAT_ATTRIBUTE11 = NULL,
    TEXT_CAT_ATTRIBUTE12 = NULL,
    TEXT_CAT_ATTRIBUTE13 = NULL,
    TEXT_CAT_ATTRIBUTE14 = NULL,
    TEXT_CAT_ATTRIBUTE15 = NULL,
    TEXT_CAT_ATTRIBUTE16 = NULL,
    TEXT_CAT_ATTRIBUTE17 = NULL,
    TEXT_CAT_ATTRIBUTE18 = NULL,
    TEXT_CAT_ATTRIBUTE19 = NULL,
    TEXT_CAT_ATTRIBUTE20 = NULL,
    TEXT_CAT_ATTRIBUTE21 = NULL,
    TEXT_CAT_ATTRIBUTE22 = NULL,
    TEXT_CAT_ATTRIBUTE23 = NULL,
    TEXT_CAT_ATTRIBUTE24 = NULL,
    TEXT_CAT_ATTRIBUTE25 = NULL,
    TEXT_CAT_ATTRIBUTE26 = NULL,
    TEXT_CAT_ATTRIBUTE27 = NULL,
    TEXT_CAT_ATTRIBUTE28 = NULL,
    TEXT_CAT_ATTRIBUTE29 = NULL,
    TEXT_CAT_ATTRIBUTE30 = NULL,
    TEXT_CAT_ATTRIBUTE31 = NULL,
    TEXT_CAT_ATTRIBUTE32 = NULL,
    TEXT_CAT_ATTRIBUTE33 = NULL,
    TEXT_CAT_ATTRIBUTE34 = NULL,
    TEXT_CAT_ATTRIBUTE35 = NULL,
    TEXT_CAT_ATTRIBUTE36 = NULL,
    TEXT_CAT_ATTRIBUTE37 = NULL,
    TEXT_CAT_ATTRIBUTE38 = NULL,
    TEXT_CAT_ATTRIBUTE39 = NULL,
    TEXT_CAT_ATTRIBUTE40 = NULL,
    TEXT_CAT_ATTRIBUTE41 = NULL,
    TEXT_CAT_ATTRIBUTE42 = NULL,
    TEXT_CAT_ATTRIBUTE43 = NULL,
    TEXT_CAT_ATTRIBUTE44 = NULL,
    TEXT_CAT_ATTRIBUTE45 = NULL,
    TEXT_CAT_ATTRIBUTE46 = NULL,
    TEXT_CAT_ATTRIBUTE47 = NULL,
    TEXT_CAT_ATTRIBUTE48 = NULL,
    TEXT_CAT_ATTRIBUTE49 = NULL,
    TEXT_CAT_ATTRIBUTE50 = NULL,
    -- WHO columns
    LAST_UPDATE_LOGIN      = FND_GLOBAL.login_id,
    LAST_UPDATED_BY        = FND_GLOBAL.user_id,
    LAST_UPDATE_DATE       = sysdate,
    CREATED_BY             = FND_GLOBAL.user_id,
    CREATION_DATE          = sysdate,
    REQUEST_ID             = FND_GLOBAL.conc_request_id,
    PROGRAM_APPLICATION_ID = FND_GLOBAL.prog_appl_id,
    PROGRAM_ID             = FND_GLOBAL.conc_program_id,
    PROGRAM_UPDATE_DATE    = sysdate,
    LAST_UPDATED_PROGRAM   = d_mod
  WHERE po_line_id = -2
    AND req_template_name = '-2'
    AND req_template_line_num = -2
    AND inventory_item_id = p_inventory_item_id
    AND org_id = p_org_id;

  IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Number of ATTR rows wiped out='||SQL%rowcount); END IF;

  l_progress := '030';
  -- SQL What: Wipeout category based attributes from TLP table for all Langs
  -- SQL Why : Because the category was changed
  -- SQL Join: po_line_id, req_template_name, req_template_line_num, org_id
  UPDATE PO_ATTRIBUTE_VALUES_TLP
  SET
    TL_TEXT_CAT_ATTRIBUTE1 = NULL,
    TL_TEXT_CAT_ATTRIBUTE2 = NULL,
    TL_TEXT_CAT_ATTRIBUTE3 = NULL,
    TL_TEXT_CAT_ATTRIBUTE4 = NULL,
    TL_TEXT_CAT_ATTRIBUTE5 = NULL,
    TL_TEXT_CAT_ATTRIBUTE6 = NULL,
    TL_TEXT_CAT_ATTRIBUTE7 = NULL,
    TL_TEXT_CAT_ATTRIBUTE8 = NULL,
    TL_TEXT_CAT_ATTRIBUTE9 = NULL,
    TL_TEXT_CAT_ATTRIBUTE10 = NULL,
    TL_TEXT_CAT_ATTRIBUTE11 = NULL,
    TL_TEXT_CAT_ATTRIBUTE12 = NULL,
    TL_TEXT_CAT_ATTRIBUTE13 = NULL,
    TL_TEXT_CAT_ATTRIBUTE14 = NULL,
    TL_TEXT_CAT_ATTRIBUTE15 = NULL,
    TL_TEXT_CAT_ATTRIBUTE16 = NULL,
    TL_TEXT_CAT_ATTRIBUTE17 = NULL,
    TL_TEXT_CAT_ATTRIBUTE18 = NULL,
    TL_TEXT_CAT_ATTRIBUTE19 = NULL,
    TL_TEXT_CAT_ATTRIBUTE20 = NULL,
    TL_TEXT_CAT_ATTRIBUTE21 = NULL,
    TL_TEXT_CAT_ATTRIBUTE22 = NULL,
    TL_TEXT_CAT_ATTRIBUTE23 = NULL,
    TL_TEXT_CAT_ATTRIBUTE24 = NULL,
    TL_TEXT_CAT_ATTRIBUTE25 = NULL,
    TL_TEXT_CAT_ATTRIBUTE26 = NULL,
    TL_TEXT_CAT_ATTRIBUTE27 = NULL,
    TL_TEXT_CAT_ATTRIBUTE28 = NULL,
    TL_TEXT_CAT_ATTRIBUTE29 = NULL,
    TL_TEXT_CAT_ATTRIBUTE30 = NULL,
    TL_TEXT_CAT_ATTRIBUTE31 = NULL,
    TL_TEXT_CAT_ATTRIBUTE32 = NULL,
    TL_TEXT_CAT_ATTRIBUTE33 = NULL,
    TL_TEXT_CAT_ATTRIBUTE34 = NULL,
    TL_TEXT_CAT_ATTRIBUTE35 = NULL,
    TL_TEXT_CAT_ATTRIBUTE36 = NULL,
    TL_TEXT_CAT_ATTRIBUTE37 = NULL,
    TL_TEXT_CAT_ATTRIBUTE38 = NULL,
    TL_TEXT_CAT_ATTRIBUTE39 = NULL,
    TL_TEXT_CAT_ATTRIBUTE40 = NULL,
    TL_TEXT_CAT_ATTRIBUTE41 = NULL,
    TL_TEXT_CAT_ATTRIBUTE42 = NULL,
    TL_TEXT_CAT_ATTRIBUTE43 = NULL,
    TL_TEXT_CAT_ATTRIBUTE44 = NULL,
    TL_TEXT_CAT_ATTRIBUTE45 = NULL,
    TL_TEXT_CAT_ATTRIBUTE46 = NULL,
    TL_TEXT_CAT_ATTRIBUTE47 = NULL,
    TL_TEXT_CAT_ATTRIBUTE48 = NULL,
    TL_TEXT_CAT_ATTRIBUTE49 = NULL,
    TL_TEXT_CAT_ATTRIBUTE50 = NULL,
    -- WHO columns
    LAST_UPDATE_LOGIN      = FND_GLOBAL.login_id,
    LAST_UPDATED_BY        = FND_GLOBAL.user_id,
    LAST_UPDATE_DATE       = sysdate,
    CREATED_BY             = FND_GLOBAL.user_id,
    CREATION_DATE          = sysdate,
    REQUEST_ID             = FND_GLOBAL.conc_request_id,
    PROGRAM_APPLICATION_ID = FND_GLOBAL.prog_appl_id,
    PROGRAM_ID             = FND_GLOBAL.conc_program_id,
    PROGRAM_UPDATE_DATE    = sysdate,
    LAST_UPDATED_PROGRAM   = d_mod
  WHERE  po_line_id = -2
    AND req_template_name = '-2'
    AND req_template_line_num = -2
    AND inventory_item_id = p_inventory_item_id
    AND org_id = p_org_id;


  IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Number of TLP rows wiped out='||SQL%rowcount); END IF;

  IF PO_LOG.d_proc THEN PO_LOG.proc_end(d_mod); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN PO_LOG.exc(d_mod,l_progress,'Unhandled exception'); END IF;
    RAISE;
END wipeout_category_attributes_MI;

-- update attributes for master items
PROCEDURE update_attributes_MI
(
  p_org_id                IN PO_LINES_ALL.org_id%TYPE,
  p_ip_category_id        IN PO_LINES_ALL.ip_category_id%TYPE,
  p_inventory_item_id     IN PO_ATTRIBUTE_VALUES_TLP.inventory_item_id%TYPE,
  p_language              IN PO_ATTRIBUTE_VALUES_TLP.language%TYPE,
  p_item_description      IN PO_ATTRIBUTE_VALUES_TLP.description%TYPE,
  p_long_description      IN PO_ATTRIBUTE_VALUES_TLP.long_description%TYPE,
  p_organization_id       IN NUMBER,
  p_master_organization_id IN NUMBER
)
IS
  d_mod CONSTANT VARCHAR2(100) := D_update_attributes||'_MI';
  l_progress      VARCHAR2(4);

  l_type_lookup_code PO_HEADERS_ALL.type_lookup_code%TYPE;
  l_orig_ip_category_id PO_LINES_ALL.ip_category_id%TYPE;
  l_orig_item_description PO_ATTRIBUTE_VALUES_TLP.description%TYPE;
  l_manufacturer_part_num   PO_ATTRIBUTE_VALUES.MANUFACTURER_PART_NUM%TYPE;
  l_orig_long_desc    PO_ATTRIBUTE_VALUES_TLP.long_description%TYPE;
  l_new_long_description        PO_ATTRIBUTE_VALUES_TLP.long_description%TYPE := nvl(p_long_description,'   ');
  l_manufacturer       PO_ATTRIBUTE_VALUES_TLP.MANUFACTURER%TYPE;
  l_proc_lead_time     PO_ATTRIBUTE_VALUES.LEAD_TIME%TYPE;
  l_orig_manufacturer   PO_ATTRIBUTE_VALUES_TLP.MANUFACTURER%TYPE;
  l_inventory_org_id PO_LINES_ALL.org_id%TYPE;
  l_rec_tlp_for_lang VARCHAR2(100);

BEGIN
  l_progress := '010';


  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_inventory_item_id',p_inventory_item_id);
    PO_LOG.proc_begin(d_mod,'p_org_id',p_org_id);
    PO_LOG.proc_begin(d_mod,'p_ip_category_id',p_ip_category_id);
    PO_LOG.proc_begin(d_mod,'p_language',p_language);
    PO_LOG.proc_begin(d_mod,'p_item_description',p_item_description);
    PO_LOG.proc_begin(d_mod,'p_long_description',p_long_description);
    PO_LOG.proc_begin(d_mod,'p_organization_id', p_organization_id);
    PO_LOG.proc_begin(d_mod,'p_master_organization_id',p_master_organization_id);
  END IF;

  l_progress := '020';
  -- SQL What: Check if ip_category_id has changed
  -- SQL Why : If ip_category_id has changed, then NULL out the category based
  --           attributes i.e. all attribute columns that have 'CAT' in the
  --           name.
  -- SQL Join: po_line_id, req_template_name, req_template_line_num, org_id

  -- bug 17470000: handle the exception
  BEGIN
    SELECT ip_category_id
    INTO l_orig_ip_category_id
    FROM PO_ATTRIBUTE_VALUES
    WHERE po_line_id = -2
      AND req_template_name = '-2'
      AND req_template_line_num = -2
      AND inventory_item_id = p_inventory_item_id
      AND org_id = p_org_id;
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
       l_progress := '021';
       IF PO_LOG.d_stmt THEN
            PO_LOG.stmt(d_mod,l_progress,'EXCEPTION calling create attributes p_inventory_item_id='||p_inventory_item_id||' p_org_id= '||p_org_id);
       END IF;
       create_default_attributes_MI
       (
        p_ip_category_id      =>   p_ip_category_id,
        p_inventory_item_id   =>  p_inventory_item_id,
        p_org_id              =>  p_org_id,
        p_description         =>   p_item_description,
        p_organization_id     =>   p_organization_id,
        p_master_organization_id => p_master_organization_id
       );

  END;

  l_progress := '050';
  -- If ip_category_id has changed, then NULL out the category based attributes
  -- i.e. all attribute columns that have 'CAT' in the name.
        -- the         PO_ATTRIBUTE_VALUES is foing to be updated there for
        -- query the latest saved attributes in mtl
      -- list down the base descriptors in PO_ATTRIBUTE_VALUES
      -- LEAD_TIME     AVAILABILITY    UNSPSC    MANUFACTURER_PART_NUM
      -- PICTURE   THUMBNAIL_IMAGE   SUPPLIER_URL  MANUFACTURER_URL
      -- ATTACHMENT_URL
      BEGIN

        SELECT MFG_PART_NUM, MANUFACTURER_NAME
        INTO l_manufacturer_part_num, l_manufacturer
        FROM(
        SELECT MFG_PART_NUM,MANUFACTURER_NAME
        FROM  MTL_MFG_PART_NUMBERS_ALL_V
        WHERE INVENTORY_ITEM_ID =p_inventory_item_id
        AND ORGANIZATION_ID = p_master_organization_id
        ORDER BY ROW_ID ) WHERE ROWNUM =1;

      EXCEPTION
      WHEN No_Data_Found THEN
        l_manufacturer_part_num:='';
        l_manufacturer := '';
      END;

        SELECT FULL_LEAD_TIME
        INTO l_proc_lead_time
        FROM mtl_system_items_b
        WHERE INVENTORY_ITEM_ID =p_inventory_item_id
        AND ORGANIZATION_ID = p_organization_id;





      IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,' MANUFACTURER_PART_NUM='||l_manufacturer_part_num||' LEAD_TIME= '||l_proc_lead_time); END IF;
   l_progress := '070';



  IF (p_ip_category_id <> l_orig_ip_category_id) THEN
    l_progress := '060';
    IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'IPF_CATEGORY_ID has changed: p_ip_category_id='||p_ip_category_id||', l_orig_ip_category_id='||l_orig_ip_category_id); END IF;

    wipeout_category_attributes_MI
    (
      p_org_id                  => p_org_id,
      p_ip_category_id          => p_ip_category_id,
      p_inventory_item_id       => p_inventory_item_id,
      p_language                => p_language,
      p_item_description        => p_item_description
    );

  ELSE
      IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'IP_CATEGORY_ID has not changed.'); END IF;
  END IF;

  l_progress := '070';

    -- SQL What: Update Attribute values
    -- SQL Why : To keep in synch with the Line level values
    -- SQL Join: po_line_id, req_template_name, req_template_line_num, org_id
    UPDATE PO_ATTRIBUTE_VALUES
    SET ip_category_id = p_ip_category_id,
        MANUFACTURER_PART_NUM =  l_manufacturer_part_num,
	LEAD_TIME	       = l_proc_lead_time,
        -- WHO columns
        LAST_UPDATE_LOGIN      = FND_GLOBAL.login_id,
        LAST_UPDATED_BY        = FND_GLOBAL.user_id,
        LAST_UPDATE_DATE       = sysdate,
        CREATED_BY             = FND_GLOBAL.user_id,
        CREATION_DATE          = sysdate,
        REQUEST_ID             = FND_GLOBAL.conc_request_id,
        PROGRAM_APPLICATION_ID = FND_GLOBAL.prog_appl_id,
        PROGRAM_ID             = FND_GLOBAL.conc_program_id,
        PROGRAM_UPDATE_DATE    = sysdate,
        LAST_UPDATED_PROGRAM   = d_mod
    WHERE po_line_id = -2
    AND req_template_name = '-2'
    AND req_template_line_num = -2
    AND inventory_item_id = p_inventory_item_id
    AND org_id = p_org_id;


    IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Number of ATTR rows updated='||SQL%rowcount); END IF;



   l_progress := '085';


/* Whenever translations are provided need to make sure inventory calls
      our api. In our update_attributes_mi we should insert records in
      to attributes tlp if record doesn't exist already.

So check for this language if the record is present in tlp
if not present than insert record for that lang
if present update the record for that lang
*/

  l_rec_tlp_for_lang := '';

 BEGIN
   SELECT 'TLP row for this language already exists'
   INTO l_rec_tlp_for_lang
   FROM PO_ATTRIBUTE_VALUES_TLP TLP2
      WHERE TLP2.po_line_id = -2
       AND TLP2.req_template_name = '-2'
       AND TLP2.req_template_line_num = -2
       AND TLP2.org_id = p_org_id
       AND inventory_item_id= p_inventory_item_id
       AND TLP2.language = p_language;
 EXCEPTION
  WHEN No_Data_Found THEN
    l_rec_tlp_for_lang:='';
 END;

  IF (l_rec_tlp_for_lang IS NULL OR l_rec_tlp_for_lang = '' ) THEN
    IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'no records hence insert into PO_ATTRIBUTE_VALUES_TLP ' ); END IF;
      l_progress := '090';

 INSERT INTO PO_ATTRIBUTE_VALUES_TLP TLP
    (
      attribute_values_tlp_id,
      description,
      language,
      po_line_id,
      req_template_name,
      req_template_line_num,
      ip_category_id,
      inventory_item_id,
      org_id,
      manufacturer,
      long_description,
      last_update_login,
      last_updated_by,
      last_update_date,
      created_by,
      creation_date,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      last_updated_program
    )
    SELECT
      PO_ATTRIBUTE_VALUES_TLP_S.nextval,
      p_item_description,
      p_language,
      -2,
      '-2',
      -2,
      p_ip_category_id,
      p_inventory_item_id,
      p_org_id,
      l_manufacturer,
      l_new_long_description,
      FND_GLOBAL.login_id,        -- last_update_login
      FND_GLOBAL.user_id,         -- last_updated_by
      sysdate,                    -- last_update_date
      FND_GLOBAL.user_id,         -- created_by
      sysdate,                    -- creation_date
      FND_GLOBAL.conc_request_id, -- request_id
      FND_GLOBAL.prog_appl_id,
      FND_GLOBAL.conc_program_id, -- program_id
      sysdate,                    -- program_update_date
      d_mod                       -- last_updated_program
    FROM dual;

  ELSE
       IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,' records present hence update PO_ATTRIBUTE_VALUES_TLP ' || l_rec_tlp_for_lang); END IF;
    l_progress := '095';
        SELECT description,Nvl(LONG_DESCRIPTION,''),Nvl(MANUFACTURER,'')
        INTO l_orig_item_description,l_orig_long_desc,l_orig_manufacturer
        FROM PO_ATTRIBUTE_VALUES_TLP
        WHERE po_line_id = -2
        AND req_template_name = '-2'
        AND req_template_line_num = -2
        AND inventory_item_id = p_inventory_item_id
        AND org_id = p_org_id
        AND language = p_language;


       IF ( (p_ip_category_id <> l_orig_ip_category_id) OR
              (p_item_description is null AND  l_orig_item_description is not null ) OR
              (p_item_description is not null AND (  l_orig_item_description is null OR   l_orig_item_description <>p_item_description)) OR
              ( l_new_long_description is null AND l_orig_long_desc is not null ) OR
              (l_new_long_description is not null AND ( l_orig_long_desc is null OR  l_orig_long_desc <> l_new_long_description)) OR
              (l_manufacturer is null AND l_orig_manufacturer is not null ) OR
              (l_manufacturer is not null AND ( l_orig_manufacturer is null OR  l_orig_manufacturer <> l_manufacturer))
           )THEN
    -- SQL What: Update Attribute TLP values
    -- SQL Why : To keep in synch with the Line level values
    -- SQL Join: po_line_id, req_template_name, req_template_line_num, org_id, language



	  UPDATE PO_ATTRIBUTE_VALUES_TLP
	    SET ip_category_id = p_ip_category_id,
		description = p_item_description,
		manufacturer =   l_manufacturer,
		long_description =  l_new_long_description,
		-- WHO columns
		LAST_UPDATE_LOGIN      = FND_GLOBAL.login_id,
		LAST_UPDATED_BY        = FND_GLOBAL.user_id,
		LAST_UPDATE_DATE       = sysdate,
		CREATED_BY             = FND_GLOBAL.user_id,
		CREATION_DATE          = sysdate,
		REQUEST_ID             = FND_GLOBAL.conc_request_id,
		PROGRAM_APPLICATION_ID = FND_GLOBAL.prog_appl_id,
		PROGRAM_ID             = FND_GLOBAL.conc_program_id,
		PROGRAM_UPDATE_DATE    = sysdate,
		LAST_UPDATED_PROGRAM   = d_mod
	    WHERE po_line_id = -2
	    AND req_template_name = '-2'
	    AND req_template_line_num = -2
	    AND inventory_item_id = p_inventory_item_id
	    AND org_id = p_org_id
	    AND language = p_language;

	    IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Number of TLP rows updated='||SQL%rowcount); END IF;
	  END IF;

  END IF;


  l_progress := '100';

  IF PO_LOG.d_proc THEN PO_LOG.proc_end(d_mod); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN PO_LOG.exc(d_mod,l_progress,'Unhandled exception'); END IF;
    RAISE;
END update_attributes_MI;



--BUG 6599217:END

--------------------------------------------------------------------------------
--Start of Comments
--Name: gen_draft_line_translations
--Pre-reqs:
--  A TLP row for the Header's created_launguage should already have
--  been inserted for each line in the given PO Header.
--Modifies:
--  FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Create Translations in the TLP table for each of the modified line
--  present in the PO_LINES_DRAFT_ALL table for a given draft_id.
--  (for a Blanket or Quotation).
--  It creates translations from one of the 2 sources:
--      a) INV Item Master (if item_id is not null)
--      b) Copies the TLP row of the created language to all other langs
--         (if item_id is null)
--
--Parameters:
--IN:
--p_draft_id
--  The DRAFT_ID to get the modifed PO Lines for which translations need to
--  be created.
--p_doc-type
--  The document type of the document.
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE gen_draft_line_translations
(
  p_draft_id IN NUMBER
, p_doc_type IN VARCHAR2
)
IS
  d_mod CONSTANT VARCHAR2(100) := D_gen_draft_line_translations;
  l_progress      VARCHAR2(4);

  l_language_codes  PO_TBL_NUMBER;
  l_tlp_row         PO_ATTRIBUTE_VALUES_TLP%rowtype;
  l_po_line_id_list PO_TBL_NUMBER;
  l_tlp_id_list     PO_TBL_NUMBER;
BEGIN
  l_progress := '010';

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_draft_id',p_draft_id);
    PO_LOG.proc_begin(d_mod,'p_doc_type',p_doc_type);
  END IF;

  IF (p_doc_type IN ('BLANKET', 'QUOTATION')) THEN

    -- SQL What: Get the PO_LINE_ID's and TLP_ID's for the PO
    --           Fetch only the lines that are modified. Since the
    --           PO_LINES_DRAFT_ALL table would contain only the lines that are
    --           modified, we join to it to get the list of PO_LINE_ID's.
    -- SQL Why : To create the TLP translations for each line
    -- SQL Join: draft_id, po_header_id, po_line_id, language
    SELECT POLD.po_line_id, TLP.attribute_values_tlp_id
    BULK COLLECT INTO l_po_line_id_list, l_tlp_id_list
    FROM PO_LINES_DRAFT_ALL POLD,
         PO_ATTRIBUTE_VALUES_TLP TLP,
         PO_HEADERS_ALL POH
    WHERE POLD.draft_id = p_draft_id
      AND NVL(POLD.change_accepted_flag, 'Y') = 'Y'
      AND POLD.po_line_id = TLP.po_line_id
      AND POH.po_header_id = POLD.po_header_id
      AND TLP.language = POH.created_language;

    l_progress := '020';
    create_translations
    (
      p_doc_type                 => p_doc_type,
      p_default_lang_tlp_id_list => l_tlp_id_list,
      p_po_line_id_list          => l_po_line_id_list
    );
  ELSE
    IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Invalid doc type='||p_doc_type||'. No translations created.'); END IF;
  END IF; -- IF (p_doc_type IN ('BLANKET', 'QUOTATION'))

  IF PO_LOG.d_proc THEN PO_LOG.proc_end(d_mod); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN PO_LOG.exc(d_mod,l_progress,'Unhandled exception'); END IF;
    RAISE;
END gen_draft_line_translations;

--------------------------------------------------------------------------------
--Start of Comments
--Name: wipeout_category_attributes
--Pre-reqs:
--  None
--Modifies:
--  FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  To set the vlaue of all the category based descriptors in the Attribute
--  Values and TLP tables as NULL.
--
--Parameters:
--IN:
--p_po_line_id
--p_req_template_name
--p_req_template_line_num
--p_org_id
--  The default values of the Attr given by the calling program.
--p_ip_category_id
--p_inventory_item_id
--p_item_description
--  The fields that can be updated
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE wipeout_category_attributes
(
  p_po_line_id            IN NUMBER
, p_req_template_name     IN VARCHAR2
, p_req_template_line_num IN NUMBER
, p_org_id                IN NUMBER
)
IS
  d_mod CONSTANT VARCHAR2(100) := D_wipeout_category_attributes;
  l_progress      VARCHAR2(4);

BEGIN
  l_progress := '010';

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_po_line_id',p_po_line_id);
    PO_LOG.proc_begin(d_mod,'p_req_template_name',p_req_template_name);
    PO_LOG.proc_begin(d_mod,'p_req_template_line_num',p_req_template_line_num);
    PO_LOG.proc_begin(d_mod,'p_org_id',p_org_id);
  END IF;

  l_progress := '020';
  -- SQL What: Wipeout category based attributes from AttributeValues table
  -- SQL Why : Because the category was changed
  -- SQL Join: po_line_id, req_template_name, req_template_line_num, org_id
  UPDATE PO_ATTRIBUTE_VALUES
  SET
    NUM_CAT_ATTRIBUTE1 = NULL,
    NUM_CAT_ATTRIBUTE2 = NULL,
    NUM_CAT_ATTRIBUTE3 = NULL,
    NUM_CAT_ATTRIBUTE4 = NULL,
    NUM_CAT_ATTRIBUTE5 = NULL,
    NUM_CAT_ATTRIBUTE6 = NULL,
    NUM_CAT_ATTRIBUTE7 = NULL,
    NUM_CAT_ATTRIBUTE8 = NULL,
    NUM_CAT_ATTRIBUTE9 = NULL,
    NUM_CAT_ATTRIBUTE10 = NULL,
    NUM_CAT_ATTRIBUTE11 = NULL,
    NUM_CAT_ATTRIBUTE12 = NULL,
    NUM_CAT_ATTRIBUTE13 = NULL,
    NUM_CAT_ATTRIBUTE14 = NULL,
    NUM_CAT_ATTRIBUTE15 = NULL,
    NUM_CAT_ATTRIBUTE16 = NULL,
    NUM_CAT_ATTRIBUTE17 = NULL,
    NUM_CAT_ATTRIBUTE18 = NULL,
    NUM_CAT_ATTRIBUTE19 = NULL,
    NUM_CAT_ATTRIBUTE20 = NULL,
    NUM_CAT_ATTRIBUTE21 = NULL,
    NUM_CAT_ATTRIBUTE22 = NULL,
    NUM_CAT_ATTRIBUTE23 = NULL,
    NUM_CAT_ATTRIBUTE24 = NULL,
    NUM_CAT_ATTRIBUTE25 = NULL,
    NUM_CAT_ATTRIBUTE26 = NULL,
    NUM_CAT_ATTRIBUTE27 = NULL,
    NUM_CAT_ATTRIBUTE28 = NULL,
    NUM_CAT_ATTRIBUTE29 = NULL,
    NUM_CAT_ATTRIBUTE30 = NULL,
    NUM_CAT_ATTRIBUTE31 = NULL,
    NUM_CAT_ATTRIBUTE32 = NULL,
    NUM_CAT_ATTRIBUTE33 = NULL,
    NUM_CAT_ATTRIBUTE34 = NULL,
    NUM_CAT_ATTRIBUTE35 = NULL,
    NUM_CAT_ATTRIBUTE36 = NULL,
    NUM_CAT_ATTRIBUTE37 = NULL,
    NUM_CAT_ATTRIBUTE38 = NULL,
    NUM_CAT_ATTRIBUTE39 = NULL,
    NUM_CAT_ATTRIBUTE40 = NULL,
    NUM_CAT_ATTRIBUTE41 = NULL,
    NUM_CAT_ATTRIBUTE42 = NULL,
    NUM_CAT_ATTRIBUTE43 = NULL,
    NUM_CAT_ATTRIBUTE44 = NULL,
    NUM_CAT_ATTRIBUTE45 = NULL,
    NUM_CAT_ATTRIBUTE46 = NULL,
    NUM_CAT_ATTRIBUTE47 = NULL,
    NUM_CAT_ATTRIBUTE48 = NULL,
    NUM_CAT_ATTRIBUTE49 = NULL,
    NUM_CAT_ATTRIBUTE50 = NULL,
    TEXT_CAT_ATTRIBUTE1 = NULL,
    TEXT_CAT_ATTRIBUTE2 = NULL,
    TEXT_CAT_ATTRIBUTE3 = NULL,
    TEXT_CAT_ATTRIBUTE4 = NULL,
    TEXT_CAT_ATTRIBUTE5 = NULL,
    TEXT_CAT_ATTRIBUTE6 = NULL,
    TEXT_CAT_ATTRIBUTE7 = NULL,
    TEXT_CAT_ATTRIBUTE8 = NULL,
    TEXT_CAT_ATTRIBUTE9 = NULL,
    TEXT_CAT_ATTRIBUTE10 = NULL,
    TEXT_CAT_ATTRIBUTE11 = NULL,
    TEXT_CAT_ATTRIBUTE12 = NULL,
    TEXT_CAT_ATTRIBUTE13 = NULL,
    TEXT_CAT_ATTRIBUTE14 = NULL,
    TEXT_CAT_ATTRIBUTE15 = NULL,
    TEXT_CAT_ATTRIBUTE16 = NULL,
    TEXT_CAT_ATTRIBUTE17 = NULL,
    TEXT_CAT_ATTRIBUTE18 = NULL,
    TEXT_CAT_ATTRIBUTE19 = NULL,
    TEXT_CAT_ATTRIBUTE20 = NULL,
    TEXT_CAT_ATTRIBUTE21 = NULL,
    TEXT_CAT_ATTRIBUTE22 = NULL,
    TEXT_CAT_ATTRIBUTE23 = NULL,
    TEXT_CAT_ATTRIBUTE24 = NULL,
    TEXT_CAT_ATTRIBUTE25 = NULL,
    TEXT_CAT_ATTRIBUTE26 = NULL,
    TEXT_CAT_ATTRIBUTE27 = NULL,
    TEXT_CAT_ATTRIBUTE28 = NULL,
    TEXT_CAT_ATTRIBUTE29 = NULL,
    TEXT_CAT_ATTRIBUTE30 = NULL,
    TEXT_CAT_ATTRIBUTE31 = NULL,
    TEXT_CAT_ATTRIBUTE32 = NULL,
    TEXT_CAT_ATTRIBUTE33 = NULL,
    TEXT_CAT_ATTRIBUTE34 = NULL,
    TEXT_CAT_ATTRIBUTE35 = NULL,
    TEXT_CAT_ATTRIBUTE36 = NULL,
    TEXT_CAT_ATTRIBUTE37 = NULL,
    TEXT_CAT_ATTRIBUTE38 = NULL,
    TEXT_CAT_ATTRIBUTE39 = NULL,
    TEXT_CAT_ATTRIBUTE40 = NULL,
    TEXT_CAT_ATTRIBUTE41 = NULL,
    TEXT_CAT_ATTRIBUTE42 = NULL,
    TEXT_CAT_ATTRIBUTE43 = NULL,
    TEXT_CAT_ATTRIBUTE44 = NULL,
    TEXT_CAT_ATTRIBUTE45 = NULL,
    TEXT_CAT_ATTRIBUTE46 = NULL,
    TEXT_CAT_ATTRIBUTE47 = NULL,
    TEXT_CAT_ATTRIBUTE48 = NULL,
    TEXT_CAT_ATTRIBUTE49 = NULL,
    TEXT_CAT_ATTRIBUTE50 = NULL,
    -- WHO columns
    LAST_UPDATE_LOGIN      = FND_GLOBAL.login_id,
    LAST_UPDATED_BY        = FND_GLOBAL.user_id,
    LAST_UPDATE_DATE       = sysdate,
    CREATED_BY             = FND_GLOBAL.user_id,
    CREATION_DATE          = sysdate,
    REQUEST_ID             = FND_GLOBAL.conc_request_id,
    PROGRAM_APPLICATION_ID = FND_GLOBAL.prog_appl_id,
    PROGRAM_ID             = FND_GLOBAL.conc_program_id,
    PROGRAM_UPDATE_DATE    = sysdate,
    LAST_UPDATED_PROGRAM   = d_mod
  WHERE po_line_id = NVL(p_po_line_id, -2)
    AND req_template_name = NVL(p_req_template_name, '-2')
    AND req_template_line_num = NVL(p_req_template_line_num, -2)
    AND org_id = p_org_id;

  IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Number of ATTR rows wiped out='||SQL%rowcount); END IF;

  l_progress := '030';
  -- SQL What: Wipeout category based attributes from TLP table for all Langs
  -- SQL Why : Because the category was changed
  -- SQL Join: po_line_id, req_template_name, req_template_line_num, org_id
  UPDATE PO_ATTRIBUTE_VALUES_TLP
  SET
    TL_TEXT_CAT_ATTRIBUTE1 = NULL,
    TL_TEXT_CAT_ATTRIBUTE2 = NULL,
    TL_TEXT_CAT_ATTRIBUTE3 = NULL,
    TL_TEXT_CAT_ATTRIBUTE4 = NULL,
    TL_TEXT_CAT_ATTRIBUTE5 = NULL,
    TL_TEXT_CAT_ATTRIBUTE6 = NULL,
    TL_TEXT_CAT_ATTRIBUTE7 = NULL,
    TL_TEXT_CAT_ATTRIBUTE8 = NULL,
    TL_TEXT_CAT_ATTRIBUTE9 = NULL,
    TL_TEXT_CAT_ATTRIBUTE10 = NULL,
    TL_TEXT_CAT_ATTRIBUTE11 = NULL,
    TL_TEXT_CAT_ATTRIBUTE12 = NULL,
    TL_TEXT_CAT_ATTRIBUTE13 = NULL,
    TL_TEXT_CAT_ATTRIBUTE14 = NULL,
    TL_TEXT_CAT_ATTRIBUTE15 = NULL,
    TL_TEXT_CAT_ATTRIBUTE16 = NULL,
    TL_TEXT_CAT_ATTRIBUTE17 = NULL,
    TL_TEXT_CAT_ATTRIBUTE18 = NULL,
    TL_TEXT_CAT_ATTRIBUTE19 = NULL,
    TL_TEXT_CAT_ATTRIBUTE20 = NULL,
    TL_TEXT_CAT_ATTRIBUTE21 = NULL,
    TL_TEXT_CAT_ATTRIBUTE22 = NULL,
    TL_TEXT_CAT_ATTRIBUTE23 = NULL,
    TL_TEXT_CAT_ATTRIBUTE24 = NULL,
    TL_TEXT_CAT_ATTRIBUTE25 = NULL,
    TL_TEXT_CAT_ATTRIBUTE26 = NULL,
    TL_TEXT_CAT_ATTRIBUTE27 = NULL,
    TL_TEXT_CAT_ATTRIBUTE28 = NULL,
    TL_TEXT_CAT_ATTRIBUTE29 = NULL,
    TL_TEXT_CAT_ATTRIBUTE30 = NULL,
    TL_TEXT_CAT_ATTRIBUTE31 = NULL,
    TL_TEXT_CAT_ATTRIBUTE32 = NULL,
    TL_TEXT_CAT_ATTRIBUTE33 = NULL,
    TL_TEXT_CAT_ATTRIBUTE34 = NULL,
    TL_TEXT_CAT_ATTRIBUTE35 = NULL,
    TL_TEXT_CAT_ATTRIBUTE36 = NULL,
    TL_TEXT_CAT_ATTRIBUTE37 = NULL,
    TL_TEXT_CAT_ATTRIBUTE38 = NULL,
    TL_TEXT_CAT_ATTRIBUTE39 = NULL,
    TL_TEXT_CAT_ATTRIBUTE40 = NULL,
    TL_TEXT_CAT_ATTRIBUTE41 = NULL,
    TL_TEXT_CAT_ATTRIBUTE42 = NULL,
    TL_TEXT_CAT_ATTRIBUTE43 = NULL,
    TL_TEXT_CAT_ATTRIBUTE44 = NULL,
    TL_TEXT_CAT_ATTRIBUTE45 = NULL,
    TL_TEXT_CAT_ATTRIBUTE46 = NULL,
    TL_TEXT_CAT_ATTRIBUTE47 = NULL,
    TL_TEXT_CAT_ATTRIBUTE48 = NULL,
    TL_TEXT_CAT_ATTRIBUTE49 = NULL,
    TL_TEXT_CAT_ATTRIBUTE50 = NULL,
    -- WHO columns
    LAST_UPDATE_LOGIN      = FND_GLOBAL.login_id,
    LAST_UPDATED_BY        = FND_GLOBAL.user_id,
    LAST_UPDATE_DATE       = sysdate,
    CREATED_BY             = FND_GLOBAL.user_id,
    CREATION_DATE          = sysdate,
    REQUEST_ID             = FND_GLOBAL.conc_request_id,
    PROGRAM_APPLICATION_ID = FND_GLOBAL.prog_appl_id,
    PROGRAM_ID             = FND_GLOBAL.conc_program_id,
    PROGRAM_UPDATE_DATE    = sysdate,
    LAST_UPDATED_PROGRAM   = d_mod
  WHERE po_line_id = NVL(p_po_line_id, -2)
    AND req_template_name = NVL(p_req_template_name, '-2')
    AND req_template_line_num = NVL(p_req_template_line_num, -2)
    AND org_id = p_org_id;

  IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Number of TLP rows wiped out='||SQL%rowcount); END IF;

  IF PO_LOG.d_proc THEN PO_LOG.proc_end(d_mod); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN PO_LOG.exc(d_mod,l_progress,'Unhandled exception'); END IF;
    RAISE;
END wipeout_category_attributes;


--------------------------------------------------------------------------------
--Start of Comments
--Name: update_attributes
--Pre-reqs:
--  None
--Modifies:
--  FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  To update the Attribute Values and TLP, by using the updated fields
--  at the Line Level.
--  Only the category_id or item_description can change in a saved PO line.
--
--Parameters:
--IN:
--p_po_line_id
--p_req_template_name
--p_req_template_line_num
--p_org_id
--  The default values of the Attr given by the calling program.
--p_ip_category_id
--p_item_description
--  The fields that can be updated
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE update_attributes
(
  p_doc_type              IN VARCHAR2, -- 'BLANKET', 'QUOTATION', 'REQ_TEMPLATE'
  p_po_line_id            IN PO_LINES.po_line_id%TYPE,
  p_req_template_name     IN PO_REQEXPRESS_LINES_ALL.express_name%TYPE,
  p_req_template_line_num IN PO_REQEXPRESS_LINES_ALL.sequence_num%TYPE,
  p_org_id                IN PO_LINES_ALL.org_id%TYPE,
  p_ip_category_id        IN PO_LINES_ALL.ip_category_id%TYPE,
  p_language              IN PO_ATTRIBUTE_VALUES_TLP.language%TYPE,
  p_item_description      IN PO_ATTRIBUTE_VALUES_TLP.description%TYPE,
  p_inventory_item_id     IN PO_ATTRIBUTE_VALUES_TLP.inventory_item_id%TYPE --bug 18381792
)
IS
  d_mod CONSTANT VARCHAR2(100) := D_update_attributes;
  l_progress      VARCHAR2(4);

  l_type_lookup_code PO_HEADERS_ALL.type_lookup_code%TYPE;
  l_orig_ip_category_id PO_LINES_ALL.ip_category_id%TYPE;
  l_orig_item_description PO_ATTRIBUTE_VALUES_TLP.description%TYPE;
  l_orig_long_description      PO_ATTRIBUTE_VALUES_TLP.long_description%TYPE;
  l_long_description      MTL_SYSTEM_ITEMS_TL.long_description%TYPE;
  l_lead_time               MTL_SYSTEM_ITEMS_B.full_lead_time%TYPE;
  l_orig_lead_time               PO_ATTRIBUTE_VALUES.lead_time%TYPE;
  l_inventory_item_id PO_ATTRIBUTE_VALUES_TLP.inventory_item_id%TYPE;
  l_created_language PO_HEADERS_ALL.CREATED_LANGUAGE%TYPE; -- BUG18642828
BEGIN
  l_progress := '010';

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_po_line_id',p_po_line_id);
    PO_LOG.proc_begin(d_mod,'p_req_template_name',p_req_template_name);
    PO_LOG.proc_begin(d_mod,'p_req_template_line_num',p_req_template_line_num);
    PO_LOG.proc_begin(d_mod,'p_org_id',p_org_id);
    PO_LOG.proc_begin(d_mod,'p_ip_category_id',p_ip_category_id);
    PO_LOG.proc_begin(d_mod,'p_language',p_language);
    PO_LOG.proc_begin(d_mod,'p_item_description',p_item_description);
  END IF;

  l_progress := '020';
  IF (p_po_line_id IS NOT NULL) THEN
    IF (p_doc_type IS NULL) THEN
      l_progress := '030';
      -- SQL What: Get the document type for the PO line
      -- SQL Why : To check if it BLANKET or QUOTATION or not
      -- SQL Join: po_line_id
      SELECT POH.type_lookup_code
      INTO l_type_lookup_code
      FROM PO_HEADERS_ALL POH,
           PO_LINES_ALL POL
      WHERE POL.po_line_id = p_po_line_id
        AND POH.po_header_id = POL.po_header_id;
    ELSE
      l_type_lookup_code := p_doc_type;
    END IF;

    -- Do not create Attr/TLP if the doc type is not BLANKET or QUOTATION
    IF (l_type_lookup_code NOT IN ('BLANKET', 'QUOTATION')) THEN
      IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Returning without creating Attr/TLP. Doc type='||l_type_lookup_code); END IF;
      RETURN;
    END IF;
  END IF;

  l_progress := '040';
  -- SQL What: Check if ip_category_id has changed
  -- SQL Why : If ip_category_id has changed, then NULL out the category based
  --           attributes i.e. all attribute columns that have 'CAT' in the
  --           name.
  -- SQL Join: po_line_id, req_template_name, req_template_line_num, org_id
  BEGIN -- bug 18381792
    SELECT ip_category_id,inventory_item_id,lead_time
    INTO l_orig_ip_category_id,l_inventory_item_id,l_orig_lead_time
    FROM PO_ATTRIBUTE_VALUES
    WHERE po_line_id = NVL(p_po_line_id, -2)
      AND req_template_name = NVL(p_req_template_name, '-2')
      AND req_template_line_num = NVL(p_req_template_line_num, -2)
      AND org_id = p_org_id;
  -- bug 18381792 begin
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
       l_progress := '041';
       IF PO_LOG.d_stmt THEN
            PO_LOG.stmt(d_mod,l_progress,'EXCEPTION calling create attributes p_inventory_item_id='||l_inventory_item_id||' p_org_id= '||p_org_id);
       END IF;
       create_default_attributes
       (
        p_doc_type              => p_doc_type,
        p_po_line_id            => p_po_line_id,
        p_req_template_name     => p_req_template_name,
        p_req_template_line_num => p_req_template_line_num,
        p_ip_category_id        => p_ip_category_id,
        p_inventory_item_id     => p_inventory_item_id,
        p_org_id                => p_org_id,
        p_description           => p_item_description
       );
  END;
  -- bug 18381792 end

  l_progress := '050';
  -- If ip_category_id has changed, then NULL out the category based attributes
  -- i.e. all attribute columns that have 'CAT' in the name.
  IF (p_ip_category_id <> l_orig_ip_category_id) THEN
    l_progress := '060';

    IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'IP_CATEGORY_ID has changed: p_ip_category_id='||p_ip_category_id||', l_orig_ip_category_id='||l_orig_ip_category_id); END IF;

    wipeout_category_attributes
    (
      p_po_line_id            => p_po_line_id
    , p_req_template_name     => p_req_template_name
    , p_req_template_line_num => p_req_template_line_num
    , p_org_id                => p_org_id
    );

    l_progress := '070';
    -- SQL What: Update Attribute values
    -- SQL Why : To keep in synch with the Line level values
    -- SQL Join: po_line_id, req_template_name, req_template_line_num, org_id
    UPDATE PO_ATTRIBUTE_VALUES
    SET ip_category_id = p_ip_category_id,
        -- WHO columns
        LAST_UPDATE_LOGIN      = FND_GLOBAL.login_id,
        LAST_UPDATED_BY        = FND_GLOBAL.user_id,
        LAST_UPDATE_DATE       = sysdate,
        CREATED_BY             = FND_GLOBAL.user_id,
        CREATION_DATE          = sysdate,
        REQUEST_ID             = FND_GLOBAL.conc_request_id,
        PROGRAM_APPLICATION_ID = FND_GLOBAL.prog_appl_id,
        PROGRAM_ID             = FND_GLOBAL.conc_program_id,
        PROGRAM_UPDATE_DATE    = sysdate,
        LAST_UPDATED_PROGRAM   = d_mod
    WHERE po_line_id = NVL(p_po_line_id, -2)
      AND req_template_name = NVL(p_req_template_name, '-2')
      AND req_template_line_num = NVL(p_req_template_line_num, -2)
      AND org_id = p_org_id;

    IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Number of ATTR rows updated='||SQL%rowcount); END IF;

  ELSE
    IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'IP_CATEGORY_ID has not changed.'); END IF;
  END IF;

  l_progress := '080';

  -- <Bug 7655719>
  -- Handle NO_DATA_FOUND exception, as for one time item there can be only one
  -- entry in PO_ATTRIBUTE_VALUES_TLP, corresponding to the base lang,
  -- if profile "POR: Load One-Time Items in All Languages" is set to No.
  BEGIN
    -- SQL What: Check if item_description has changed
    -- SQL Why : No need to update TLP row if item_description and
    --           ip_category_id have not changed.
    -- SQL Join: po_line_id, req_template_name, req_template_line_num, org_id
    SELECT description,long_description
    INTO l_orig_item_description,l_orig_long_description
    FROM PO_ATTRIBUTE_VALUES_TLP
    WHERE po_line_id = NVL(p_po_line_id, -2)
      AND req_template_name = NVL(p_req_template_name, '-2')
      AND req_template_line_num = NVL(p_req_template_line_num, -2)
      AND org_id = p_org_id
      AND language = p_language;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_orig_item_description := NULL;
  END;

  IF (p_item_description = l_orig_item_description) THEN
    IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'ITEM_DESCRIPTION has not changed.'); END IF;
  ELSE
    IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'ITEM_DESCRIPTION has changed.'); END IF;
  END IF;

  l_progress := '090';

-- bug 18642828 begin
  BEGIN
    SELECT POH.created_language
    INTO l_created_language
    FROM PO_HEADERS_ALL POH,
         PO_LINES_ALL POL
    WHERE POL.po_line_id = p_po_line_id
      AND POH.po_header_id = POL.po_header_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_created_language := NULL;
  END;
-- bug 18642828 end

  IF ( (p_ip_category_id <> l_orig_ip_category_id) OR
       (p_item_description <> l_orig_item_description) ) THEN
    -- SQL What: Update Attribute TLP values
    -- SQL Why : To keep in synch with the Line level values
    -- SQL Join: po_line_id, req_template_name, req_template_line_num, org_id, language
    UPDATE PO_ATTRIBUTE_VALUES_TLP
    SET ip_category_id = p_ip_category_id,
        description = p_item_description,
        -- WHO columns
        LAST_UPDATE_LOGIN      = FND_GLOBAL.login_id,
        LAST_UPDATED_BY        = FND_GLOBAL.user_id,
        LAST_UPDATE_DATE       = sysdate,
        CREATED_BY             = FND_GLOBAL.user_id,
        CREATION_DATE          = sysdate,
        REQUEST_ID             = FND_GLOBAL.conc_request_id,
        PROGRAM_APPLICATION_ID = FND_GLOBAL.prog_appl_id,
        PROGRAM_ID             = FND_GLOBAL.conc_program_id,
        PROGRAM_UPDATE_DATE    = sysdate,
        LAST_UPDATED_PROGRAM   = d_mod
    WHERE po_line_id = NVL(p_po_line_id, -2)
      AND req_template_name = NVL(p_req_template_name, '-2')
      AND req_template_line_num = NVL(p_req_template_line_num, -2)
      AND org_id = p_org_id
      AND (language = p_language
      OR   l_created_language = USERENV('LANG') --bug 18642828
      OR  NVL(fnd_profile.value('UPDATE_BPA_DESC_FOR_ALL_LANG'), 'Y') = 'Y'); --bug 18642828;

    IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Number of TLP rows updated='||SQL%rowcount); END IF;
  END IF;

   l_progress := '100';

 	   -- <Bug 13249142>
 	   BEGIN
 	     -- SQL What: Gets the long_descripton from master items table
 	     -- SQL Why : Need to update long description value of Po_attribute_values
 	     --           if it does not match with master items long_description .
 	     -- SQL Join:
 	     SELECT long_description
 	         INTO   l_long_description
 	         FROM   mtl_system_items_tl
 	         WHERE  inventory_item_id = l_inventory_item_id
 	                 AND organization_id = p_org_id
 	                 AND language = p_language;

 	   EXCEPTION
 	     WHEN NO_DATA_FOUND THEN
 	       l_long_description := NULL;
 	   END;

 	   l_progress := '110';
 	   IF ((l_long_description <> l_orig_long_description) or(l_long_description is null and l_orig_long_description is not null)
 	           or (l_long_description is not null and l_orig_long_description is null)) THEN

 	     -- SQL What: Update Attribute TLP values
 	     -- SQL Why : To keep in synch with the Line level values
 	     -- SQL Join: po_line_id, req_template_name, req_template_line_num, org_id, language
 	     UPDATE PO_ATTRIBUTE_VALUES_TLP
 	     SET long_description = l_long_description,
 	         -- WHO columns
 	         LAST_UPDATE_LOGIN      = FND_GLOBAL.login_id,
 	         LAST_UPDATED_BY        = FND_GLOBAL.user_id,
 	         LAST_UPDATE_DATE       = sysdate,
 	         REQUEST_ID             = FND_GLOBAL.conc_request_id,
 	         PROGRAM_APPLICATION_ID = FND_GLOBAL.prog_appl_id,
 	         PROGRAM_ID             = FND_GLOBAL.conc_program_id,
 	         PROGRAM_UPDATE_DATE    = sysdate,
 	         LAST_UPDATED_PROGRAM   = d_mod
 	     WHERE po_line_id = NVL(p_po_line_id, -2)
 	       AND req_template_name = NVL(p_req_template_name, '-2')
 	       AND req_template_line_num = NVL(p_req_template_line_num, -2)
 	       AND org_id = p_org_id
 	       AND language = p_language;

 	     IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Number of TLP rows updated='||SQL%rowcount); END IF;
 	   ELSE
 	   IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'long description has not changed.'); END IF;
 	   END IF;

 	   l_progress := '120';
 	    BEGIN
 	     -- SQL What: Gets the lead time from mtl_system_items_b table
 	     -- SQL Why : Need to update lead_time value of Po_attribute_values
 	     --           if it does not match withmtl_system_items_b lead_time.
 	     -- SQL Join:
 	     SELECT full_lead_time
 	         INTO   l_lead_time
 	         FROM   mtl_system_items_b
 	         WHERE  inventory_item_id = l_inventory_item_id
 	                 AND organization_id = p_org_id;

 	   EXCEPTION
 	     WHEN NO_DATA_FOUND THEN
 	       l_lead_time := NULL;
 	   END;

 	    l_progress := '130';
 	   -- If lead_time mismatched.
 	      IF ((l_orig_lead_time <> l_lead_time)or (l_orig_lead_time is not null and l_lead_time is null)
 	             or (l_orig_lead_time is null and l_lead_time is not null)) THEN
 	     l_progress := '060';-- SQL What: Update Attribute values
 	     -- SQL Why : To keep in synch with the Line level values
 	     -- SQL Join: po_line_id, req_template_name, req_template_line_num, org_id
 	     UPDATE PO_ATTRIBUTE_VALUES
 	     SET lead_time = l_lead_time,
 	         -- WHO columns
 	         LAST_UPDATE_LOGIN      = FND_GLOBAL.login_id,
 	         LAST_UPDATED_BY        = FND_GLOBAL.user_id,
 	         LAST_UPDATE_DATE       = sysdate,
 	         REQUEST_ID             = FND_GLOBAL.conc_request_id,
 	         PROGRAM_APPLICATION_ID = FND_GLOBAL.prog_appl_id,
 	         PROGRAM_ID             = FND_GLOBAL.conc_program_id,
 	         PROGRAM_UPDATE_DATE    = sysdate,
 	         LAST_UPDATED_PROGRAM   = d_mod
 	     WHERE po_line_id = NVL(p_po_line_id, -2)
 	       AND req_template_name = NVL(p_req_template_name, '-2')
 	       AND req_template_line_num = NVL(p_req_template_line_num, -2)
 	       AND org_id = p_org_id;

 	     IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Number of ATTR rows updated='||SQL%rowcount); END IF;

 	   ELSE
 	     IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'lead time has not changed.'); END IF;
 	   END IF;

  IF PO_LOG.d_proc THEN PO_LOG.proc_end(d_mod); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN PO_LOG.exc(d_mod,l_progress,'Unhandled exception'); END IF;
    RAISE;
END update_attributes;

--------------------------------------------------------------------------------
--Start of Comments
--Name: copy_attributes
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  To copy the Attribute Values and TLP rows from a given document to a new
--  document.
--
--Parameters:
--IN:
--p_orig_po_line_id
--  The PO_LINE_ID of the document from which the data has to be copied.
--p_new_po_line_id
--  The PO_LINE_ID of the new document.
--OUT:
-- None
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE copy_attributes
(
  p_orig_po_line_id IN PO_LINES.po_line_id%TYPE
, p_new_po_line_id  IN PO_LINES.po_line_id%TYPE
)
IS
  d_mod CONSTANT VARCHAR2(100) := D_copy_attributes;
  l_progress      VARCHAR2(4);

BEGIN
  l_progress := '010';

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_orig_po_line_id',p_orig_po_line_id);
    PO_LOG.proc_begin(d_mod,'p_new_po_line_id',p_new_po_line_id);
  END IF;

--Bug# 5520701: PICTURE column needed to be inserted.

  -- SQL What: Insert a new row for Attribute values
  -- SQL Why : To copy the Attr from old doc to new doc
  -- SQL Join: po_line_id

  INSERT INTO PO_ATTRIBUTE_VALUES (
    attribute_values_id,
    po_line_id,
    req_template_name,
    req_template_line_num,
    ip_category_id,
    inventory_item_id,
    org_id,
    manufacturer_part_num,
    picture,
    thumbnail_image,
    supplier_url,
    manufacturer_url,
    attachment_url,
    unspsc,
    availability,
    lead_time,
    text_base_attribute1,
    text_base_attribute2,
    text_base_attribute3,
    text_base_attribute4,
    text_base_attribute5,
    text_base_attribute6,
    text_base_attribute7,
    text_base_attribute8,
    text_base_attribute9,
    text_base_attribute10,
    text_base_attribute11,
    text_base_attribute12,
    text_base_attribute13,
    text_base_attribute14,
    text_base_attribute15,
    text_base_attribute16,
    text_base_attribute17,
    text_base_attribute18,
    text_base_attribute19,
    text_base_attribute20,
    text_base_attribute21,
    text_base_attribute22,
    text_base_attribute23,
    text_base_attribute24,
    text_base_attribute25,
    text_base_attribute26,
    text_base_attribute27,
    text_base_attribute28,
    text_base_attribute29,
    text_base_attribute30,
    text_base_attribute31,
    text_base_attribute32,
    text_base_attribute33,
    text_base_attribute34,
    text_base_attribute35,
    text_base_attribute36,
    text_base_attribute37,
    text_base_attribute38,
    text_base_attribute39,
    text_base_attribute40,
    text_base_attribute41,
    text_base_attribute42,
    text_base_attribute43,
    text_base_attribute44,
    text_base_attribute45,
    text_base_attribute46,
    text_base_attribute47,
    text_base_attribute48,
    text_base_attribute49,
    text_base_attribute50,
    text_base_attribute51,
    text_base_attribute52,
    text_base_attribute53,
    text_base_attribute54,
    text_base_attribute55,
    text_base_attribute56,
    text_base_attribute57,
    text_base_attribute58,
    text_base_attribute59,
    text_base_attribute60,
    text_base_attribute61,
    text_base_attribute62,
    text_base_attribute63,
    text_base_attribute64,
    text_base_attribute65,
    text_base_attribute66,
    text_base_attribute67,
    text_base_attribute68,
    text_base_attribute69,
    text_base_attribute70,
    text_base_attribute71,
    text_base_attribute72,
    text_base_attribute73,
    text_base_attribute74,
    text_base_attribute75,
    text_base_attribute76,
    text_base_attribute77,
    text_base_attribute78,
    text_base_attribute79,
    text_base_attribute80,
    text_base_attribute81,
    text_base_attribute82,
    text_base_attribute83,
    text_base_attribute84,
    text_base_attribute85,
    text_base_attribute86,
    text_base_attribute87,
    text_base_attribute88,
    text_base_attribute89,
    text_base_attribute90,
    text_base_attribute91,
    text_base_attribute92,
    text_base_attribute93,
    text_base_attribute94,
    text_base_attribute95,
    text_base_attribute96,
    text_base_attribute97,
    text_base_attribute98,
    text_base_attribute99,
    text_base_attribute100,
    num_base_attribute1,
    num_base_attribute2,
    num_base_attribute3,
    num_base_attribute4,
    num_base_attribute5,
    num_base_attribute6,
    num_base_attribute7,
    num_base_attribute8,
    num_base_attribute9,
    num_base_attribute10,
    num_base_attribute11,
    num_base_attribute12,
    num_base_attribute13,
    num_base_attribute14,
    num_base_attribute15,
    num_base_attribute16,
    num_base_attribute17,
    num_base_attribute18,
    num_base_attribute19,
    num_base_attribute20,
    num_base_attribute21,
    num_base_attribute22,
    num_base_attribute23,
    num_base_attribute24,
    num_base_attribute25,
    num_base_attribute26,
    num_base_attribute27,
    num_base_attribute28,
    num_base_attribute29,
    num_base_attribute30,
    num_base_attribute31,
    num_base_attribute32,
    num_base_attribute33,
    num_base_attribute34,
    num_base_attribute35,
    num_base_attribute36,
    num_base_attribute37,
    num_base_attribute38,
    num_base_attribute39,
    num_base_attribute40,
    num_base_attribute41,
    num_base_attribute42,
    num_base_attribute43,
    num_base_attribute44,
    num_base_attribute45,
    num_base_attribute46,
    num_base_attribute47,
    num_base_attribute48,
    num_base_attribute49,
    num_base_attribute50,
    num_base_attribute51,
    num_base_attribute52,
    num_base_attribute53,
    num_base_attribute54,
    num_base_attribute55,
    num_base_attribute56,
    num_base_attribute57,
    num_base_attribute58,
    num_base_attribute59,
    num_base_attribute60,
    num_base_attribute61,
    num_base_attribute62,
    num_base_attribute63,
    num_base_attribute64,
    num_base_attribute65,
    num_base_attribute66,
    num_base_attribute67,
    num_base_attribute68,
    num_base_attribute69,
    num_base_attribute70,
    num_base_attribute71,
    num_base_attribute72,
    num_base_attribute73,
    num_base_attribute74,
    num_base_attribute75,
    num_base_attribute76,
    num_base_attribute77,
    num_base_attribute78,
    num_base_attribute79,
    num_base_attribute80,
    num_base_attribute81,
    num_base_attribute82,
    num_base_attribute83,
    num_base_attribute84,
    num_base_attribute85,
    num_base_attribute86,
    num_base_attribute87,
    num_base_attribute88,
    num_base_attribute89,
    num_base_attribute90,
    num_base_attribute91,
    num_base_attribute92,
    num_base_attribute93,
    num_base_attribute94,
    num_base_attribute95,
    num_base_attribute96,
    num_base_attribute97,
    num_base_attribute98,
    num_base_attribute99,
    num_base_attribute100,
    text_cat_attribute1,
    text_cat_attribute2,
    text_cat_attribute3,
    text_cat_attribute4,
    text_cat_attribute5,
    text_cat_attribute6,
    text_cat_attribute7,
    text_cat_attribute8,
    text_cat_attribute9,
    text_cat_attribute10,
    text_cat_attribute11,
    text_cat_attribute12,
    text_cat_attribute13,
    text_cat_attribute14,
    text_cat_attribute15,
    text_cat_attribute16,
    text_cat_attribute17,
    text_cat_attribute18,
    text_cat_attribute19,
    text_cat_attribute20,
    text_cat_attribute21,
    text_cat_attribute22,
    text_cat_attribute23,
    text_cat_attribute24,
    text_cat_attribute25,
    text_cat_attribute26,
    text_cat_attribute27,
    text_cat_attribute28,
    text_cat_attribute29,
    text_cat_attribute30,
    text_cat_attribute31,
    text_cat_attribute32,
    text_cat_attribute33,
    text_cat_attribute34,
    text_cat_attribute35,
    text_cat_attribute36,
    text_cat_attribute37,
    text_cat_attribute38,
    text_cat_attribute39,
    text_cat_attribute40,
    text_cat_attribute41,
    text_cat_attribute42,
    text_cat_attribute43,
    text_cat_attribute44,
    text_cat_attribute45,
    text_cat_attribute46,
    text_cat_attribute47,
    text_cat_attribute48,
    text_cat_attribute49,
    text_cat_attribute50,
    num_cat_attribute1,
    num_cat_attribute2,
    num_cat_attribute3,
    num_cat_attribute4,
    num_cat_attribute5,
    num_cat_attribute6,
    num_cat_attribute7,
    num_cat_attribute8,
    num_cat_attribute9,
    num_cat_attribute10,
    num_cat_attribute11,
    num_cat_attribute12,
    num_cat_attribute13,
    num_cat_attribute14,
    num_cat_attribute15,
    num_cat_attribute16,
    num_cat_attribute17,
    num_cat_attribute18,
    num_cat_attribute19,
    num_cat_attribute20,
    num_cat_attribute21,
    num_cat_attribute22,
    num_cat_attribute23,
    num_cat_attribute24,
    num_cat_attribute25,
    num_cat_attribute26,
    num_cat_attribute27,
    num_cat_attribute28,
    num_cat_attribute29,
    num_cat_attribute30,
    num_cat_attribute31,
    num_cat_attribute32,
    num_cat_attribute33,
    num_cat_attribute34,
    num_cat_attribute35,
    num_cat_attribute36,
    num_cat_attribute37,
    num_cat_attribute38,
    num_cat_attribute39,
    num_cat_attribute40,
    num_cat_attribute41,
    num_cat_attribute42,
    num_cat_attribute43,
    num_cat_attribute44,
    num_cat_attribute45,
    num_cat_attribute46,
    num_cat_attribute47,
    num_cat_attribute48,
    num_cat_attribute49,
    num_cat_attribute50,
    last_update_login,
    last_updated_by,
    last_update_date,
    created_by,
    creation_date,
    request_id,
    program_application_id,
    program_id,
    program_update_date,
    last_updated_program
  )
  SELECT
    PO_ATTRIBUTE_VALUES_S.nextval,
    p_new_po_line_id,
    POATR.req_template_name,
    POATR.req_template_line_num,
    POATR.ip_category_id,
    POATR.inventory_item_id,
    POATR.org_id,
    POATR.manufacturer_part_num,
    POATR.picture,
    POATR.thumbnail_image,
    POATR.supplier_url,
    POATR.manufacturer_url,
    POATR.attachment_url,
    POATR.unspsc,
    POATR.availability,
    POATR.lead_time,
    POATR.text_base_attribute1,
    POATR.text_base_attribute2,
    POATR.text_base_attribute3,
    POATR.text_base_attribute4,
    POATR.text_base_attribute5,
    POATR.text_base_attribute6,
    POATR.text_base_attribute7,
    POATR.text_base_attribute8,
    POATR.text_base_attribute9,
    POATR.text_base_attribute10,
    POATR.text_base_attribute11,
    POATR.text_base_attribute12,
    POATR.text_base_attribute13,
    POATR.text_base_attribute14,
    POATR.text_base_attribute15,
    POATR.text_base_attribute16,
    POATR.text_base_attribute17,
    POATR.text_base_attribute18,
    POATR.text_base_attribute19,
    POATR.text_base_attribute20,
    POATR.text_base_attribute21,
    POATR.text_base_attribute22,
    POATR.text_base_attribute23,
    POATR.text_base_attribute24,
    POATR.text_base_attribute25,
    POATR.text_base_attribute26,
    POATR.text_base_attribute27,
    POATR.text_base_attribute28,
    POATR.text_base_attribute29,
    POATR.text_base_attribute30,
    POATR.text_base_attribute31,
    POATR.text_base_attribute32,
    POATR.text_base_attribute33,
    POATR.text_base_attribute34,
    POATR.text_base_attribute35,
    POATR.text_base_attribute36,
    POATR.text_base_attribute37,
    POATR.text_base_attribute38,
    POATR.text_base_attribute39,
    POATR.text_base_attribute40,
    POATR.text_base_attribute41,
    POATR.text_base_attribute42,
    POATR.text_base_attribute43,
    POATR.text_base_attribute44,
    POATR.text_base_attribute45,
    POATR.text_base_attribute46,
    POATR.text_base_attribute47,
    POATR.text_base_attribute48,
    POATR.text_base_attribute49,
    POATR.text_base_attribute50,
    POATR.text_base_attribute51,
    POATR.text_base_attribute52,
    POATR.text_base_attribute53,
    POATR.text_base_attribute54,
    POATR.text_base_attribute55,
    POATR.text_base_attribute56,
    POATR.text_base_attribute57,
    POATR.text_base_attribute58,
    POATR.text_base_attribute59,
    POATR.text_base_attribute60,
    POATR.text_base_attribute61,
    POATR.text_base_attribute62,
    POATR.text_base_attribute63,
    POATR.text_base_attribute64,
    POATR.text_base_attribute65,
    POATR.text_base_attribute66,
    POATR.text_base_attribute67,
    POATR.text_base_attribute68,
    POATR.text_base_attribute69,
    POATR.text_base_attribute70,
    POATR.text_base_attribute71,
    POATR.text_base_attribute72,
    POATR.text_base_attribute73,
    POATR.text_base_attribute74,
    POATR.text_base_attribute75,
    POATR.text_base_attribute76,
    POATR.text_base_attribute77,
    POATR.text_base_attribute78,
    POATR.text_base_attribute79,
    POATR.text_base_attribute80,
    POATR.text_base_attribute81,
    POATR.text_base_attribute82,
    POATR.text_base_attribute83,
    POATR.text_base_attribute84,
    POATR.text_base_attribute85,
    POATR.text_base_attribute86,
    POATR.text_base_attribute87,
    POATR.text_base_attribute88,
    POATR.text_base_attribute89,
    POATR.text_base_attribute90,
    POATR.text_base_attribute91,
    POATR.text_base_attribute92,
    POATR.text_base_attribute93,
    POATR.text_base_attribute94,
    POATR.text_base_attribute95,
    POATR.text_base_attribute96,
    POATR.text_base_attribute97,
    POATR.text_base_attribute98,
    POATR.text_base_attribute99,
    POATR.text_base_attribute100,
    POATR.num_base_attribute1,
    POATR.num_base_attribute2,
    POATR.num_base_attribute3,
    POATR.num_base_attribute4,
    POATR.num_base_attribute5,
    POATR.num_base_attribute6,
    POATR.num_base_attribute7,
    POATR.num_base_attribute8,
    POATR.num_base_attribute9,
    POATR.num_base_attribute10,
    POATR.num_base_attribute11,
    POATR.num_base_attribute12,
    POATR.num_base_attribute13,
    POATR.num_base_attribute14,
    POATR.num_base_attribute15,
    POATR.num_base_attribute16,
    POATR.num_base_attribute17,
    POATR.num_base_attribute18,
    POATR.num_base_attribute19,
    POATR.num_base_attribute20,
    POATR.num_base_attribute21,
    POATR.num_base_attribute22,
    POATR.num_base_attribute23,
    POATR.num_base_attribute24,
    POATR.num_base_attribute25,
    POATR.num_base_attribute26,
    POATR.num_base_attribute27,
    POATR.num_base_attribute28,
    POATR.num_base_attribute29,
    POATR.num_base_attribute30,
    POATR.num_base_attribute31,
    POATR.num_base_attribute32,
    POATR.num_base_attribute33,
    POATR.num_base_attribute34,
    POATR.num_base_attribute35,
    POATR.num_base_attribute36,
    POATR.num_base_attribute37,
    POATR.num_base_attribute38,
    POATR.num_base_attribute39,
    POATR.num_base_attribute40,
    POATR.num_base_attribute41,
    POATR.num_base_attribute42,
    POATR.num_base_attribute43,
    POATR.num_base_attribute44,
    POATR.num_base_attribute45,
    POATR.num_base_attribute46,
    POATR.num_base_attribute47,
    POATR.num_base_attribute48,
    POATR.num_base_attribute49,
    POATR.num_base_attribute50,
    POATR.num_base_attribute51,
    POATR.num_base_attribute52,
    POATR.num_base_attribute53,
    POATR.num_base_attribute54,
    POATR.num_base_attribute55,
    POATR.num_base_attribute56,
    POATR.num_base_attribute57,
    POATR.num_base_attribute58,
    POATR.num_base_attribute59,
    POATR.num_base_attribute60,
    POATR.num_base_attribute61,
    POATR.num_base_attribute62,
    POATR.num_base_attribute63,
    POATR.num_base_attribute64,
    POATR.num_base_attribute65,
    POATR.num_base_attribute66,
    POATR.num_base_attribute67,
    POATR.num_base_attribute68,
    POATR.num_base_attribute69,
    POATR.num_base_attribute70,
    POATR.num_base_attribute71,
    POATR.num_base_attribute72,
    POATR.num_base_attribute73,
    POATR.num_base_attribute74,
    POATR.num_base_attribute75,
    POATR.num_base_attribute76,
    POATR.num_base_attribute77,
    POATR.num_base_attribute78,
    POATR.num_base_attribute79,
    POATR.num_base_attribute80,
    POATR.num_base_attribute81,
    POATR.num_base_attribute82,
    POATR.num_base_attribute83,
    POATR.num_base_attribute84,
    POATR.num_base_attribute85,
    POATR.num_base_attribute86,
    POATR.num_base_attribute87,
    POATR.num_base_attribute88,
    POATR.num_base_attribute89,
    POATR.num_base_attribute90,
    POATR.num_base_attribute91,
    POATR.num_base_attribute92,
    POATR.num_base_attribute93,
    POATR.num_base_attribute94,
    POATR.num_base_attribute95,
    POATR.num_base_attribute96,
    POATR.num_base_attribute97,
    POATR.num_base_attribute98,
    POATR.num_base_attribute99,
    POATR.num_base_attribute100,
    POATR.text_cat_attribute1,
    POATR.text_cat_attribute2,
    POATR.text_cat_attribute3,
    POATR.text_cat_attribute4,
    POATR.text_cat_attribute5,
    POATR.text_cat_attribute6,
    POATR.text_cat_attribute7,
    POATR.text_cat_attribute8,
    POATR.text_cat_attribute9,
    POATR.text_cat_attribute10,
    POATR.text_cat_attribute11,
    POATR.text_cat_attribute12,
    POATR.text_cat_attribute13,
    POATR.text_cat_attribute14,
    POATR.text_cat_attribute15,
    POATR.text_cat_attribute16,
    POATR.text_cat_attribute17,
    POATR.text_cat_attribute18,
    POATR.text_cat_attribute19,
    POATR.text_cat_attribute20,
    POATR.text_cat_attribute21,
    POATR.text_cat_attribute22,
    POATR.text_cat_attribute23,
    POATR.text_cat_attribute24,
    POATR.text_cat_attribute25,
    POATR.text_cat_attribute26,
    POATR.text_cat_attribute27,
    POATR.text_cat_attribute28,
    POATR.text_cat_attribute29,
    POATR.text_cat_attribute30,
    POATR.text_cat_attribute31,
    POATR.text_cat_attribute32,
    POATR.text_cat_attribute33,
    POATR.text_cat_attribute34,
    POATR.text_cat_attribute35,
    POATR.text_cat_attribute36,
    POATR.text_cat_attribute37,
    POATR.text_cat_attribute38,
    POATR.text_cat_attribute39,
    POATR.text_cat_attribute40,
    POATR.text_cat_attribute41,
    POATR.text_cat_attribute42,
    POATR.text_cat_attribute43,
    POATR.text_cat_attribute44,
    POATR.text_cat_attribute45,
    POATR.text_cat_attribute46,
    POATR.text_cat_attribute47,
    POATR.text_cat_attribute48,
    POATR.text_cat_attribute49,
    POATR.text_cat_attribute50,
    POATR.num_cat_attribute1,
    POATR.num_cat_attribute2,
    POATR.num_cat_attribute3,
    POATR.num_cat_attribute4,
    POATR.num_cat_attribute5,
    POATR.num_cat_attribute6,
    POATR.num_cat_attribute7,
    POATR.num_cat_attribute8,
    POATR.num_cat_attribute9,
    POATR.num_cat_attribute10,
    POATR.num_cat_attribute11,
    POATR.num_cat_attribute12,
    POATR.num_cat_attribute13,
    POATR.num_cat_attribute14,
    POATR.num_cat_attribute15,
    POATR.num_cat_attribute16,
    POATR.num_cat_attribute17,
    POATR.num_cat_attribute18,
    POATR.num_cat_attribute19,
    POATR.num_cat_attribute20,
    POATR.num_cat_attribute21,
    POATR.num_cat_attribute22,
    POATR.num_cat_attribute23,
    POATR.num_cat_attribute24,
    POATR.num_cat_attribute25,
    POATR.num_cat_attribute26,
    POATR.num_cat_attribute27,
    POATR.num_cat_attribute28,
    POATR.num_cat_attribute29,
    POATR.num_cat_attribute30,
    POATR.num_cat_attribute31,
    POATR.num_cat_attribute32,
    POATR.num_cat_attribute33,
    POATR.num_cat_attribute34,
    POATR.num_cat_attribute35,
    POATR.num_cat_attribute36,
    POATR.num_cat_attribute37,
    POATR.num_cat_attribute38,
    POATR.num_cat_attribute39,
    POATR.num_cat_attribute40,
    POATR.num_cat_attribute41,
    POATR.num_cat_attribute42,
    POATR.num_cat_attribute43,
    POATR.num_cat_attribute44,
    POATR.num_cat_attribute45,
    POATR.num_cat_attribute46,
    POATR.num_cat_attribute47,
    POATR.num_cat_attribute48,
    POATR.num_cat_attribute49,
    POATR.num_cat_attribute50,
    FND_GLOBAL.login_id,        -- last_update_login
    FND_GLOBAL.user_id,         -- last_updated_by
    sysdate,                    -- last_update_date
    POATR.created_by,
    POATR.creation_date,
    FND_GLOBAL.conc_request_id, -- request_id
    POATR.program_application_id,
    POATR.program_id,
    POATR.program_update_date,
    d_mod                       -- last_updated_program
  FROM PO_ATTRIBUTE_VALUES POATR
  WHERE POATR.po_line_id = p_orig_po_line_id
    AND NOT EXISTS
        (SELECT 'ATTR row already exists'
         FROM PO_ATTRIBUTE_VALUES ATR2
         WHERE ATR2.po_line_id = p_new_po_line_id
          AND ATR2.req_template_name = POATR.req_template_name
          AND ATR2.req_template_line_num = POATR.req_template_line_num
          AND ATR2.org_id = POATR.org_id);

  l_progress := '020';
  IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Number of ATTR rows copied='||SQL%rowcount); END IF;

  -- SQL What: Insert new rows for Attribute  values TLP.
  --           This SQL will enter multiple rows, one for each installed lang.
  -- SQL Why : To copy the TLP from old doc to new doc
  -- SQL Join: po_line_id
  INSERT INTO PO_ATTRIBUTE_VALUES_TLP (
    attribute_values_tlp_id,
    po_line_id,
    req_template_name,
    req_template_line_num,
    ip_category_id,
    inventory_item_id,
    org_id,
    language,
    description,
    manufacturer,
    comments,
    alias,
    long_description,
    tl_text_base_attribute1,
    tl_text_base_attribute2,
    tl_text_base_attribute3,
    tl_text_base_attribute4,
    tl_text_base_attribute5,
    tl_text_base_attribute6,
    tl_text_base_attribute7,
    tl_text_base_attribute8,
    tl_text_base_attribute9,
    tl_text_base_attribute10,
    tl_text_base_attribute11,
    tl_text_base_attribute12,
    tl_text_base_attribute13,
    tl_text_base_attribute14,
    tl_text_base_attribute15,
    tl_text_base_attribute16,
    tl_text_base_attribute17,
    tl_text_base_attribute18,
    tl_text_base_attribute19,
    tl_text_base_attribute20,
    tl_text_base_attribute21,
    tl_text_base_attribute22,
    tl_text_base_attribute23,
    tl_text_base_attribute24,
    tl_text_base_attribute25,
    tl_text_base_attribute26,
    tl_text_base_attribute27,
    tl_text_base_attribute28,
    tl_text_base_attribute29,
    tl_text_base_attribute30,
    tl_text_base_attribute31,
    tl_text_base_attribute32,
    tl_text_base_attribute33,
    tl_text_base_attribute34,
    tl_text_base_attribute35,
    tl_text_base_attribute36,
    tl_text_base_attribute37,
    tl_text_base_attribute38,
    tl_text_base_attribute39,
    tl_text_base_attribute40,
    tl_text_base_attribute41,
    tl_text_base_attribute42,
    tl_text_base_attribute43,
    tl_text_base_attribute44,
    tl_text_base_attribute45,
    tl_text_base_attribute46,
    tl_text_base_attribute47,
    tl_text_base_attribute48,
    tl_text_base_attribute49,
    tl_text_base_attribute50,
    tl_text_base_attribute51,
    tl_text_base_attribute52,
    tl_text_base_attribute53,
    tl_text_base_attribute54,
    tl_text_base_attribute55,
    tl_text_base_attribute56,
    tl_text_base_attribute57,
    tl_text_base_attribute58,
    tl_text_base_attribute59,
    tl_text_base_attribute60,
    tl_text_base_attribute61,
    tl_text_base_attribute62,
    tl_text_base_attribute63,
    tl_text_base_attribute64,
    tl_text_base_attribute65,
    tl_text_base_attribute66,
    tl_text_base_attribute67,
    tl_text_base_attribute68,
    tl_text_base_attribute69,
    tl_text_base_attribute70,
    tl_text_base_attribute71,
    tl_text_base_attribute72,
    tl_text_base_attribute73,
    tl_text_base_attribute74,
    tl_text_base_attribute75,
    tl_text_base_attribute76,
    tl_text_base_attribute77,
    tl_text_base_attribute78,
    tl_text_base_attribute79,
    tl_text_base_attribute80,
    tl_text_base_attribute81,
    tl_text_base_attribute82,
    tl_text_base_attribute83,
    tl_text_base_attribute84,
    tl_text_base_attribute85,
    tl_text_base_attribute86,
    tl_text_base_attribute87,
    tl_text_base_attribute88,
    tl_text_base_attribute89,
    tl_text_base_attribute90,
    tl_text_base_attribute91,
    tl_text_base_attribute92,
    tl_text_base_attribute93,
    tl_text_base_attribute94,
    tl_text_base_attribute95,
    tl_text_base_attribute96,
    tl_text_base_attribute97,
    tl_text_base_attribute98,
    tl_text_base_attribute99,
    tl_text_base_attribute100,
    tl_text_cat_attribute1,
    tl_text_cat_attribute2,
    tl_text_cat_attribute3,
    tl_text_cat_attribute4,
    tl_text_cat_attribute5,
    tl_text_cat_attribute6,
    tl_text_cat_attribute7,
    tl_text_cat_attribute8,
    tl_text_cat_attribute9,
    tl_text_cat_attribute10,
    tl_text_cat_attribute11,
    tl_text_cat_attribute12,
    tl_text_cat_attribute13,
    tl_text_cat_attribute14,
    tl_text_cat_attribute15,
    tl_text_cat_attribute16,
    tl_text_cat_attribute17,
    tl_text_cat_attribute18,
    tl_text_cat_attribute19,
    tl_text_cat_attribute20,
    tl_text_cat_attribute21,
    tl_text_cat_attribute22,
    tl_text_cat_attribute23,
    tl_text_cat_attribute24,
    tl_text_cat_attribute25,
    tl_text_cat_attribute26,
    tl_text_cat_attribute27,
    tl_text_cat_attribute28,
    tl_text_cat_attribute29,
    tl_text_cat_attribute30,
    tl_text_cat_attribute31,
    tl_text_cat_attribute32,
    tl_text_cat_attribute33,
    tl_text_cat_attribute34,
    tl_text_cat_attribute35,
    tl_text_cat_attribute36,
    tl_text_cat_attribute37,
    tl_text_cat_attribute38,
    tl_text_cat_attribute39,
    tl_text_cat_attribute40,
    tl_text_cat_attribute41,
    tl_text_cat_attribute42,
    tl_text_cat_attribute43,
    tl_text_cat_attribute44,
    tl_text_cat_attribute45,
    tl_text_cat_attribute46,
    tl_text_cat_attribute47,
    tl_text_cat_attribute48,
    tl_text_cat_attribute49,
    tl_text_cat_attribute50,
    last_update_login,
    last_updated_by,
    last_update_date,
    created_by,
    creation_date,
    request_id,
    program_application_id,
    program_id,
    program_update_date,
    last_updated_program
   )
   SELECT
    PO_ATTRIBUTE_VALUES_TLP_S.nextval,
    p_new_po_line_id,
    POTLP.req_template_name,
    POTLP.req_template_line_num,
    POTLP.ip_category_id,
    POTLP.inventory_item_id,
    POTLP.org_id,
    POTLP.language,
    POTLP.description,
    POTLP.manufacturer,
    POTLP.comments,
    POTLP.alias,
    POTLP.long_description,
    POTLP.tl_text_base_attribute1,
    POTLP.tl_text_base_attribute2,
    POTLP.tl_text_base_attribute3,
    POTLP.tl_text_base_attribute4,
    POTLP.tl_text_base_attribute5,
    POTLP.tl_text_base_attribute6,
    POTLP.tl_text_base_attribute7,
    POTLP.tl_text_base_attribute8,
    POTLP.tl_text_base_attribute9,
    POTLP.tl_text_base_attribute10,
    POTLP.tl_text_base_attribute11,
    POTLP.tl_text_base_attribute12,
    POTLP.tl_text_base_attribute13,
    POTLP.tl_text_base_attribute14,
    POTLP.tl_text_base_attribute15,
    POTLP.tl_text_base_attribute16,
    POTLP.tl_text_base_attribute17,
    POTLP.tl_text_base_attribute18,
    POTLP.tl_text_base_attribute19,
    POTLP.tl_text_base_attribute20,
    POTLP.tl_text_base_attribute21,
    POTLP.tl_text_base_attribute22,
    POTLP.tl_text_base_attribute23,
    POTLP.tl_text_base_attribute24,
    POTLP.tl_text_base_attribute25,
    POTLP.tl_text_base_attribute26,
    POTLP.tl_text_base_attribute27,
    POTLP.tl_text_base_attribute28,
    POTLP.tl_text_base_attribute29,
    POTLP.tl_text_base_attribute30,
    POTLP.tl_text_base_attribute31,
    POTLP.tl_text_base_attribute32,
    POTLP.tl_text_base_attribute33,
    POTLP.tl_text_base_attribute34,
    POTLP.tl_text_base_attribute35,
    POTLP.tl_text_base_attribute36,
    POTLP.tl_text_base_attribute37,
    POTLP.tl_text_base_attribute38,
    POTLP.tl_text_base_attribute39,
    POTLP.tl_text_base_attribute40,
    POTLP.tl_text_base_attribute41,
    POTLP.tl_text_base_attribute42,
    POTLP.tl_text_base_attribute43,
    POTLP.tl_text_base_attribute44,
    POTLP.tl_text_base_attribute45,
    POTLP.tl_text_base_attribute46,
    POTLP.tl_text_base_attribute47,
    POTLP.tl_text_base_attribute48,
    POTLP.tl_text_base_attribute49,
    POTLP.tl_text_base_attribute50,
    POTLP.tl_text_base_attribute51,
    POTLP.tl_text_base_attribute52,
    POTLP.tl_text_base_attribute53,
    POTLP.tl_text_base_attribute54,
    POTLP.tl_text_base_attribute55,
    POTLP.tl_text_base_attribute56,
    POTLP.tl_text_base_attribute57,
    POTLP.tl_text_base_attribute58,
    POTLP.tl_text_base_attribute59,
    POTLP.tl_text_base_attribute60,
    POTLP.tl_text_base_attribute61,
    POTLP.tl_text_base_attribute62,
    POTLP.tl_text_base_attribute63,
    POTLP.tl_text_base_attribute64,
    POTLP.tl_text_base_attribute65,
    POTLP.tl_text_base_attribute66,
    POTLP.tl_text_base_attribute67,
    POTLP.tl_text_base_attribute68,
    POTLP.tl_text_base_attribute69,
    POTLP.tl_text_base_attribute70,
    POTLP.tl_text_base_attribute71,
    POTLP.tl_text_base_attribute72,
    POTLP.tl_text_base_attribute73,
    POTLP.tl_text_base_attribute74,
    POTLP.tl_text_base_attribute75,
    POTLP.tl_text_base_attribute76,
    POTLP.tl_text_base_attribute77,
    POTLP.tl_text_base_attribute78,
    POTLP.tl_text_base_attribute79,
    POTLP.tl_text_base_attribute80,
    POTLP.tl_text_base_attribute81,
    POTLP.tl_text_base_attribute82,
    POTLP.tl_text_base_attribute83,
    POTLP.tl_text_base_attribute84,
    POTLP.tl_text_base_attribute85,
    POTLP.tl_text_base_attribute86,
    POTLP.tl_text_base_attribute87,
    POTLP.tl_text_base_attribute88,
    POTLP.tl_text_base_attribute89,
    POTLP.tl_text_base_attribute90,
    POTLP.tl_text_base_attribute91,
    POTLP.tl_text_base_attribute92,
    POTLP.tl_text_base_attribute93,
    POTLP.tl_text_base_attribute94,
    POTLP.tl_text_base_attribute95,
    POTLP.tl_text_base_attribute96,
    POTLP.tl_text_base_attribute97,
    POTLP.tl_text_base_attribute98,
    POTLP.tl_text_base_attribute99,
    POTLP.tl_text_base_attribute100,
    POTLP.tl_text_cat_attribute1,
    POTLP.tl_text_cat_attribute2,
    POTLP.tl_text_cat_attribute3,
    POTLP.tl_text_cat_attribute4,
    POTLP.tl_text_cat_attribute5,
    POTLP.tl_text_cat_attribute6,
    POTLP.tl_text_cat_attribute7,
    POTLP.tl_text_cat_attribute8,
    POTLP.tl_text_cat_attribute9,
    POTLP.tl_text_cat_attribute10,
    POTLP.tl_text_cat_attribute11,
    POTLP.tl_text_cat_attribute12,
    POTLP.tl_text_cat_attribute13,
    POTLP.tl_text_cat_attribute14,
    POTLP.tl_text_cat_attribute15,
    POTLP.tl_text_cat_attribute16,
    POTLP.tl_text_cat_attribute17,
    POTLP.tl_text_cat_attribute18,
    POTLP.tl_text_cat_attribute19,
    POTLP.tl_text_cat_attribute20,
    POTLP.tl_text_cat_attribute21,
    POTLP.tl_text_cat_attribute22,
    POTLP.tl_text_cat_attribute23,
    POTLP.tl_text_cat_attribute24,
    POTLP.tl_text_cat_attribute25,
    POTLP.tl_text_cat_attribute26,
    POTLP.tl_text_cat_attribute27,
    POTLP.tl_text_cat_attribute28,
    POTLP.tl_text_cat_attribute29,
    POTLP.tl_text_cat_attribute30,
    POTLP.tl_text_cat_attribute31,
    POTLP.tl_text_cat_attribute32,
    POTLP.tl_text_cat_attribute33,
    POTLP.tl_text_cat_attribute34,
    POTLP.tl_text_cat_attribute35,
    POTLP.tl_text_cat_attribute36,
    POTLP.tl_text_cat_attribute37,
    POTLP.tl_text_cat_attribute38,
    POTLP.tl_text_cat_attribute39,
    POTLP.tl_text_cat_attribute40,
    POTLP.tl_text_cat_attribute41,
    POTLP.tl_text_cat_attribute42,
    POTLP.tl_text_cat_attribute43,
    POTLP.tl_text_cat_attribute44,
    POTLP.tl_text_cat_attribute45,
    POTLP.tl_text_cat_attribute46,
    POTLP.tl_text_cat_attribute47,
    POTLP.tl_text_cat_attribute48,
    POTLP.tl_text_cat_attribute49,
    POTLP.tl_text_cat_attribute50,
    FND_GLOBAL.login_id,        -- last_update_login
    FND_GLOBAL.user_id,         -- last_updated_by
    sysdate,                    -- last_update_date
    POTLP.created_by,
    POTLP.creation_date,
    FND_GLOBAL.conc_request_id, -- request_id
    POTLP.program_application_id,
    POTLP.program_id,
    POTLP.program_update_date,
    d_mod                       -- last_updated_program
  FROM PO_ATTRIBUTE_VALUES_TLP POTLP
  WHERE POTLP.po_line_id = p_orig_po_line_id
    AND NOT EXISTS
        (SELECT 'TLP row for this language already exists'
         FROM PO_ATTRIBUTE_VALUES_TLP TLP2
         WHERE TLP2.po_line_id = p_new_po_line_id
          AND TLP2.req_template_name = POTLP.req_template_name
          AND TLP2.req_template_line_num = POTLP.req_template_line_num
          AND TLP2.org_id = POTLP.org_id
          AND TLP2.language = POTLP.language);

  l_progress := '030';
  IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Number of TLP rows copied='||SQL%rowcount); END IF;

  IF PO_LOG.d_proc THEN PO_LOG.proc_end(d_mod); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN PO_LOG.exc(d_mod,l_progress,'Unhandled exception'); END IF;
    RAISE;
END copy_attributes;

--------------------------------------------------------------------------------
--Start of Comments
--Name: get_ip_category_id
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  To get the IP_CATEGORY_IF from PO's category_id using the iProc view
--  ICX_CAT_PURCHASING_CAT_MAP_V.
--
--Parameters:
--IN:
--p_po_category_id
--  PO's category ID
--OUT:
--x_ip_category_id
--  The derived ip_category_is as OUT parameter
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE get_ip_category_id
(
  p_po_category_id IN NUMBER
, x_ip_category_id OUT NOCOPY NUMBER
)
IS
  d_mod CONSTANT VARCHAR2(100) := D_get_ip_category_id;
  l_progress      VARCHAR2(4);

BEGIN
  l_progress := '010';

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_po_category_id',p_po_category_id);
  END IF;

  -- SQL What: Default the IP_CATEGORY_ID
  -- SQL Why : To insert the correct default value of IP_CATEGORY ID
  -- SQL Join: PO_CATEGORY_ID
  SELECT NVL(shopping_category_id, -2)
  INTO x_ip_category_id
  FROM ICX_CAT_PURCHASING_CAT_MAP_V
  WHERE po_category_id = p_po_category_id;

  IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'x_ip_category_id='||x_ip_category_id); END IF;

  IF PO_LOG.d_proc THEN PO_LOG.proc_end(d_mod); END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF PO_LOG.d_exc THEN PO_LOG.exc(d_mod,l_progress,'NO_DATA_FOUND exception: Ignoring and setting ip_category_id=-2'); END IF;
    x_ip_category_id := -2;
  WHEN TOO_MANY_ROWS THEN
    IF PO_LOG.d_exc THEN PO_LOG.exc(d_mod,l_progress,'TOO_MANY_ROWS exception'); END IF;
    x_ip_category_id := -2; -- TODO: This is a temp fix. Resolve with iProc why this exceptions?
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN PO_LOG.exc(d_mod,l_progress,'Unhandled exception'); END IF;
    RAISE;
END get_ip_category_id;

--------------------------------------------------------------------------------
--Start of Comments
--Name: delete_attributes
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  To delete the Attribute Values and TLP rows for a given Blanket PO Line,
--  Quotation Line or ReqTemplate Line
--
--Parameters:
--IN:
--p_po_line_id
--p_req_template_name
--p_req_template_line_num
--p_org_id
--  The unique key to identify the Attr/TLP rows(s) to be delted.
--OUT:
-- None
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE delete_attributes
(
  p_doc_type              IN VARCHAR2, -- 'BLANKET', 'QUOTATION', 'REQ_TEMPLATE'
  p_po_line_id            IN PO_LINES.po_line_id%TYPE DEFAULT NULL,
  p_req_template_name     IN PO_REQEXPRESS_LINES_ALL.express_name%TYPE DEFAULT NULL,
  p_req_template_line_num IN PO_REQEXPRESS_LINES_ALL.sequence_num%TYPE DEFAULT NULL,
  p_org_id                IN PO_LINES_ALL.org_id%TYPE DEFAULT NULL
)
IS
  d_mod CONSTANT VARCHAR2(100) := D_delete_attributes;
  l_progress      VARCHAR2(4);

BEGIN
  l_progress := '010';

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_doc_type',p_doc_type);
    PO_LOG.proc_begin(d_mod,'p_po_line_id',p_po_line_id);
    PO_LOG.proc_begin(d_mod,'p_req_template_name',p_req_template_name);
    PO_LOG.proc_begin(d_mod,'p_req_template_line_num',p_req_template_line_num);
    PO_LOG.proc_begin(d_mod,'p_org_id',p_org_id);
  END IF;

  -- SQL What: Delete Attribute Values
  -- SQL Why : as required by this procedure
  -- SQL Join: po_line_id, req_template_name, req_template_line_num, org_id
  DELETE FROM PO_ATTRIBUTE_VALUES
  WHERE po_line_id = NVL(p_po_line_id, -2)
    AND req_template_name = NVL(p_req_template_name, '-2')
    AND req_template_line_num = NVL(p_req_template_line_num, -2)
    AND org_id = NVL(p_org_id, PO_MOAC_UTILS_PVT.get_current_org_id);

  l_progress := '020';
  IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Number of ATTR rows deleted='||SQL%rowcount); END IF;

  -- SQL What: Delete Attribute Values TLP
  -- SQL Why : as required by this procedure
  -- SQL Join: po_line_id, req_template_name, req_template_line_num, org_id
  DELETE FROM PO_ATTRIBUTE_VALUES_TLP
  WHERE po_line_id = NVL(p_po_line_id, -2)
    AND req_template_name = NVL(p_req_template_name, '-2')
    AND req_template_line_num = NVL(p_req_template_line_num, -2)
    AND org_id = NVL(p_org_id, PO_MOAC_UTILS_PVT.get_current_org_id);

  l_progress := '030';
  IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Number of TLP rows deleted='||SQL%rowcount); END IF;

  IF PO_LOG.d_proc THEN PO_LOG.proc_end(d_mod); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN PO_LOG.exc(d_mod,l_progress,'Unhandled exception'); END IF;
    RAISE;
END delete_attributes;

--------------------------------------------------------------------------------
--Start of Comments
--Name: delete_attributes_for_header
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  To delete the Attribute Values and TLP rows for all lines in a given Header.
--
--Parameters:
--IN:
--p_doc_type
--  The document type of the header. This can only be BLANKET or QUOTATION
--p_po_Header_id
--  The PO header for which the attribute and TLP rows need to be deleted.
--OUT:
-- None
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE delete_attributes_for_header
(
  p_doc_type     IN VARCHAR2, -- 'BLANKET', 'QUOTATION'
  p_po_header_id IN PO_LINES.po_header_id%TYPE
)
IS
  d_mod CONSTANT VARCHAR2(100) := D_delete_attributes_for_header;
  l_progress      VARCHAR2(4);

BEGIN
  l_progress := '010';

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_doc_type',p_doc_type);
    PO_LOG.proc_begin(d_mod,'p_po_header_id',p_po_header_id);
  END IF;

  IF (p_doc_type IN ('BLANKET', 'QUOTATION')) THEN
    -- SQL What: Delete Attribute Values for all lines in a PO Header
    -- SQL Why : as required by this procedure
    -- SQL Join: po_line_id, po_header_id
    DELETE FROM PO_ATTRIBUTE_VALUES POATR
    WHERE EXISTS
          (SELECT 'All PO Lines for the given Header'
           FROM PO_LINES_ALL POL
           WHERE POL.po_header_id = p_po_header_id
             AND POATR.po_line_id = POL.po_line_id);


    l_progress := '020';
    IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Number of ATTR rows deleted='||SQL%rowcount); END IF;

    -- SQL What: Delete Attribute Values TLP for all lines in a PO Header
    -- SQL Why : as required by this procedure
    -- SQL Join: po_line_id, po_header_id
    DELETE FROM PO_ATTRIBUTE_VALUES_TLP POTLP
    WHERE EXISTS
          (SELECT 'All PO Lines for the given Header'
           FROM PO_LINES_ALL POL
           WHERE POL.po_header_id = p_po_header_id
             AND POTLP.po_line_id = POL.po_line_id);

    l_progress := '030';
    IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Number of TLP rows deleted='||SQL%rowcount); END IF;
  ELSE
    IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Invalid doc_type='||p_doc_type); END IF;
  END IF;

  IF PO_LOG.d_proc THEN PO_LOG.proc_end(d_mod); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN PO_LOG.exc(d_mod,l_progress,'Unhandled exception'); END IF;
    RAISE;
END delete_attributes_for_header;

--------------------------------------------------------------------------------
--Start of Comments
--Name: get_base_lang
--Pre-reqs:
--  None
--Modifies:
--  a) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Gets the Base Language of the installed system.
--Parameters:
--IN:
-- None
--RETURN:
-- VARCHAR2 -- the base languages of the system.
--End of Comments
--------------------------------------------------------------------------------
FUNCTION get_base_lang
RETURN VARCHAR2
IS
  d_mod CONSTANT VARCHAR2(100) := D_get_base_lang;
  l_progress      VARCHAR2(4);
BEGIN
  l_progress := '010';
  IF PO_LOG.d_proc THEN PO_LOG.proc_begin(d_mod); END IF;

  l_progress := '020';
  IF (g_base_language IS NULL) THEN
    -- SQL What: Get the base language of the system installation.
    -- SQL Why : Will be used to populate the created_language column
    -- SQL Join: installed_flag
    SELECT language_code
    INTO g_base_language
    FROM FND_LANGUAGES
    WHERE installed_flag='B';
  END IF;

  l_progress := '030';
  IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'base_lang=<'||g_base_language||'>'); END IF;

  IF PO_LOG.d_proc THEN PO_LOG.proc_end(d_mod); END IF;
  RETURN g_base_language;
EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN PO_LOG.exc(d_mod,l_progress,'Unhandled exception'); END IF;
    RAISE;
END get_base_lang;

PROCEDURE create_attributes_tlp_MI
(
  p_inventory_item_id     IN PO_LINES_ALL.item_id%TYPE,
  p_ip_category_id        IN PO_LINES_ALL.ip_category_id%TYPE,
  p_org_id                IN PO_LINES_ALL.org_id%TYPE,
  p_language              IN PO_ATTRIBUTE_VALUES_TLP.language%TYPE,
  p_description           IN PO_ATTRIBUTE_VALUES_TLP.description%TYPE,
  p_long_description      IN PO_ATTRIBUTE_VALUES_TLP.long_description%TYPE,
  p_organization_id       IN NUMBER,
  p_master_organization_id IN NUMBER
)
IS
  d_mod CONSTANT VARCHAR2(100) :=  D_create_attributes_tlp_MI;
  l_progress      VARCHAR2(4);
  l_description  PO_ATTRIBUTE_VALUES_TLP.description%TYPE := nvl(p_description,'    ');
  l_manufacturer PO_ATTRIBUTE_VALUES_TLP.MANUFACTURER%TYPE;
  l_long_description PO_ATTRIBUTE_VALUES_TLP.LONG_DESCRIPTION%TYPE := nvl(p_long_description,'   ');

BEGIN
  l_progress := '010';


  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_org_id',p_org_id);
    PO_LOG.proc_begin(d_mod,'p_inventory_item_id',p_inventory_item_id);
    PO_LOG.proc_begin(d_mod,'p_ip_category_id',p_ip_category_id);
    PO_LOG.proc_begin(d_mod,'p_language',p_language);
    PO_LOG.proc_begin(d_mod,'p_description',p_description);
    PO_LOG.proc_begin(d_mod,'p_long_description',p_long_description);
    PO_LOG.proc_begin(d_mod,'p_organization_id', p_organization_id);
    PO_LOG.proc_begin(d_mod,'p_master_organization_id',p_master_organization_id);

  END IF;

  l_progress := '030';

  --  list down the base descriptors in PO_ATTRIBUTE_VALUES_TLP
  --  MANUFACTURER    COMMENTS    ALIAS    LONG_DESCRIPTION
  Begin
   SELECT MANUFACTURER_NAME
   INTO l_manufacturer
   FROM(
   SELECT * FROM  MTL_MFG_PART_NUMBERS_ALL_V
   WHERE INVENTORY_ITEM_ID =p_inventory_item_id
   AND ORGANIZATION_ID = p_master_organization_id
   ORDER BY ROW_ID ) WHERE ROWNUM =1;
  EXCEPTION
  WHEN No_Data_Found THEN
    l_manufacturer:='';
  END;


   l_progress := '035';

  -- SQL What: Insert default rows for Attribute values TLP.
  --           This SQL will insert multiple rows, one for each installed lang.
  -- SQL Why : To create a default Attr TLP row
  -- SQL Join: po_line_id
  INSERT INTO PO_ATTRIBUTE_VALUES_TLP (
    attribute_values_tlp_id,
    po_line_id,
    req_template_name,
    req_template_line_num,
    ip_category_id,
    inventory_item_id,
    org_id,
    language,
    description,
    long_description,
    manufacturer,
    -- WHO columns
    last_update_login,
    last_updated_by,
    last_update_date,
    created_by,
    creation_date,
    request_id,
    program_application_id,
    program_id,
    program_update_date,
    last_updated_program
   )
   SELECT
    PO_ATTRIBUTE_VALUES_TLP_S.nextval,
    -2,
    '-2',
    -2,
    NVL(p_ip_category_id,-2),
    NVL(p_inventory_item_id,-2),
    NVL(p_org_id,-2),
    p_language,
    l_description,
    l_long_description,
    l_manufacturer,
    -- WHO columns
    FND_GLOBAL.login_id,        -- last_update_login
    FND_GLOBAL.user_id,         -- last_updated_by
    sysdate,                    -- last_update_date
    FND_GLOBAL.user_id,         -- created_by
    sysdate,                    -- creation_date
    FND_GLOBAL.conc_request_id, -- request_id
    FND_GLOBAL.prog_appl_id,    -- program_application_id
    FND_GLOBAL.conc_program_id, -- program_id
    sysdate,                    -- program_update_date
    d_mod                       -- last_updated_program
   FROM DUAL
   WHERE NOT EXISTS
     (SELECT 'TLP row for this language already exists'
      FROM PO_ATTRIBUTE_VALUES_TLP TLP2
      WHERE  TLP2.inventory_item_id = p_inventory_item_id
        AND  TLP2.org_id = p_org_id
        AND  TLP2.language = p_language
        AND  TLP2.po_line_id = -2
        AND  TLP2.req_template_name = '-2'
        AND  TLP2.req_template_line_num = -2
      );

  l_progress := '060';
  IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,l_progress,'Number of rows inserted in TLP table='||SQL%rowcount); END IF;

  IF PO_LOG.d_proc THEN PO_LOG.proc_end(d_mod); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN PO_LOG.exc(d_mod,l_progress,'Unhandled exception'); END IF;
    RAISE;
END create_attributes_tlp_MI;

--------------------------------------------------------------------------------
--Start of Comments
--Bug 7039409: Added new procedure
--Name: get_item_attributes_values
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  To derive item attributes to be populated in PO_ATTRIBUTE_VALUES.
--
--Parameters:
--IN:
--  p_inventory_item_id
--OUT:
--  p_manufacturer_part_num
--  p_manufacturer
--  p_lead_time
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE get_item_attributes_values
(
  p_inventory_item_id       IN         PO_LINES_ALL.item_id%TYPE,
  p_manufacturer_part_num   OUT NOCOPY PO_ATTRIBUTE_VALUES.manufacturer_part_num%TYPE,
  p_manufacturer            OUT NOCOPY PO_ATTRIBUTE_VALUES_TLP.manufacturer%TYPE,
  p_lead_time               OUT NOCOPY PO_ATTRIBUTE_VALUES.lead_time%TYPE
)
IS
   l_manufacturer_id  po_requisition_lines_All.MANUFACTURER_ID%TYPE;
BEGIN
     get_item_attributes_values(p_inventory_item_id, p_manufacturer_part_num ,p_manufacturer, p_lead_time, l_manufacturer_id);
END get_item_attributes_values;


-------------------------------------------------------------------------------
--Start of Comments
--Bug 7387487: Added new procedure
--Name: get_item_attributes_values
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  To derive item attributes to be populated in PO_ATTRIBUTE_VALUES.
--
--Parameters:
--IN:
--  p_inventory_item_id
--OUT:
--  p_manufacturer_part_num
--  p_manufacturer
--  p_lead_time
--p_manufacturer_id
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE get_item_attributes_values
(
  p_inventory_item_id       IN         PO_LINES_ALL.item_id%TYPE,
  p_manufacturer_part_num   OUT NOCOPY PO_ATTRIBUTE_VALUES.manufacturer_part_num%TYPE,
  p_manufacturer            OUT NOCOPY PO_ATTRIBUTE_VALUES_TLP.manufacturer%TYPE,
  p_lead_time               OUT NOCOPY PO_ATTRIBUTE_VALUES.lead_time%TYPE,
  p_manufacturer_id         OUT NOCOPY po_requisition_lines_All.MANUFACTURER_ID%TYPE
)
IS
  d_mod                     CONSTANT VARCHAR2(100) := D_get_item_attributes_values;
  l_progress                VARCHAR2(4);
  l_master_organization_id  MTL_PARAMETERS.master_organization_id%TYPE;
  l_inv_organization_id     MTL_PARAMETERS.master_organization_id%TYPE;

BEGIN
  l_progress := '010';
  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_inventory_item_id',p_inventory_item_id);
  END IF;

  -- Get MASTER_ORGANIZATION_ID and INVENTORY_ORGANIZATION_ID
  -- Use master org to get mfg_part_num, manufacturer_name and long_description
  -- as these are Master level attributes.
  -- Use inventory org to get full_lead_time as this is Org level attribute.
  SELECT mtl.master_organization_id,
         fsp.inventory_organization_id
  INTO   l_master_organization_id,
         l_inv_organization_id
  FROM   mtl_parameters mtl,
         financials_system_parameters fsp
  WHERE  fsp.inventory_organization_id = mtl.organization_id;

  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,l_progress,'l_master_organization_id='||l_master_organization_id);
    PO_LOG.stmt(d_mod,l_progress,'l_inv_organization_id='||l_inv_organization_id);
  END IF;
  l_progress := '020';

  -- Get MANUFACTURER Related info
  BEGIN
    SELECT mfg_part_num,
           manufacturer_name,
           MANUFACTURER_ID
    INTO   p_manufacturer_part_num,
           p_manufacturer,
           p_manufacturer_id
    FROM  mtl_mfg_part_numbers_all_v WHERE row_id =
    (SELECT Min(row_id)
    FROM   mtl_mfg_part_numbers_all_v
    WHERE  inventory_item_id = p_inventory_item_id
           AND organization_id = l_master_organization_id);


  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,l_progress,'p_manufacturer_part_num='||p_manufacturer_part_num);
    PO_LOG.stmt(d_mod,l_progress,'p_manufacturer='||p_manufacturer);
  END IF;
  l_progress := '030';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      p_manufacturer_part_num := NULL;
      p_manufacturer := NULL;
  END;

  -- Get LEAD_TIME
  BEGIN
    SELECT full_lead_time
    INTO   p_lead_time
    FROM   mtl_system_items_b
    WHERE  inventory_item_id = p_inventory_item_id
         AND organization_id = l_inv_organization_id;

    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_mod,l_progress,'p_lead_time='||p_lead_time);
    END IF;

  --Bug 15976602,catch no data found exception
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      p_lead_time := NULL;
  END;
  --Bug 15976602

  IF PO_LOG.d_proc THEN PO_LOG.proc_end(d_mod);
  END IF;
END get_item_attributes_values;
--------------------------------------------------------------------------------
--Start of Comments
--Bug 7039409: Added new procedure
--Name: get_item_attributes_tlp_values
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  To derive tlp item attributes to be populated in PO_ATTRIBUTE_VALUES_TLP.
--
--Parameters:
--IN:
--  p_inventory_item_id
--  p_lang
--OUT:
--  p_long_description
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE get_item_attributes_tlp_values
(
  p_inventory_item_id       IN         PO_LINES_ALL.item_id%TYPE,
  p_lang                    IN         PO_ATTRIBUTE_VALUES_TLP.language%TYPE,
  p_long_description        OUT NOCOPY PO_ATTRIBUTE_VALUES_TLP.long_description%TYPE
)
IS
  d_mod                     CONSTANT VARCHAR2(100) := D_get_item_attributes_tlp;
  l_progress                VARCHAR2(4);
  l_master_organization_id  PO_LINES_ALL.org_id%TYPE;
BEGIN
  l_progress := '010';
  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_inventory_item_id',p_inventory_item_id);
    PO_LOG.proc_begin(d_mod,'p_lang',p_lang);
  END IF;

  -- Get MASTER_ORGANIZATION_ID
  SELECT mtl.master_organization_id
  INTO   l_master_organization_id
  FROM   mtl_parameters mtl,
         financials_system_parameters fsp
  WHERE  fsp.inventory_organization_id = mtl.organization_id;

  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,l_progress,'l_master_organization_id='||l_master_organization_id);
  END IF;
  l_progress := '020';

  -- Get LONG_DESCRIPTION
  BEGIN
    SELECT long_description
    INTO   p_long_description
    FROM   mtl_system_items_tl
    WHERE  inventory_item_id = p_inventory_item_id
           AND organization_id = l_master_organization_id
           AND language = p_lang;

    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_mod,l_progress,'p_long_description='||p_long_description);
    END IF;
  EXCEPTION
    -- If not found, get it for the base lang
    WHEN NO_DATA_FOUND THEN
      SELECT long_description
      INTO   p_long_description
      FROM   mtl_system_items_tl
      WHERE  inventory_item_id = p_inventory_item_id
             AND organization_id = l_master_organization_id
             AND language = g_base_language;
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_mod,l_progress,'NO_DATA_FOUND');
        PO_LOG.stmt(d_mod,l_progress,'p_long_description='||p_long_description);
      END IF;
  END;

  IF PO_LOG.d_proc THEN PO_LOG.proc_end(d_mod); END IF;
END get_item_attributes_tlp_values;

END;

/
