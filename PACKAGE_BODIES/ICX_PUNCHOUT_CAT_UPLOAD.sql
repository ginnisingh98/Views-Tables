--------------------------------------------------------
--  DDL for Package Body ICX_PUNCHOUT_CAT_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_PUNCHOUT_CAT_UPLOAD" AS
/* $Header: ICX_PUNCHOUT_CAT_UPLOAD.plb 120.0.12010000.18 2014/04/24 14:56:33 mzhussai noship $ */

  d_pkg_name CONSTANT VARCHAR2(50) := 'ICX_PUNCHOUT_CAT_UPLOAD';
 g_org_id NUMBER := 204;
 g_batch_id NUMBER;
 g_supplier_id NUMBER;
 g_supplier_site_id NUMBER;
 g_content_zone_id NUMBER;
 g_stored_column VARCHAR2(30);

-----------------------------------------------------------------------
 --Start of Comments
 --Name: update_punchout_option
 --Function:
 --  For all ids passed in, update repunchout option from item attr table
 --Parameters:
 --IN:
 --p_item_id_tbl
 --  Table of item ids
 --IN OUT:
 --OUT:
 --End of Comments
 ------------------------------------------------------------------------
 PROCEDURE update_punchout_option(
   p_item_id_tbl IN PO_TBL_NUMBER
   ) IS

   d_api_name CONSTANT VARCHAR2(30) := 'update_punchout_option';
   d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
   d_position NUMBER;

   l_query varchar2(250);
   l_punchout_option varchar2(700);
   BEGIN

   d_position := 10;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Start update_punchout_option');
   END IF;

   IF(g_stored_column IS NULL) THEN
      RETURN;
   END IF;

   d_position := 20;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'g_stored_column :' || g_stored_column);
   END IF;

   FOR i IN 1..p_item_id_tbl.COUNT
   LOOP

     l_query := 'select ' || g_stored_column || ' from ' || g_stored_table || ' where punchout_item_id = ' || p_item_id_tbl(i);

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, i || '. l_query :' || l_query);
   END IF;

    BEGIN
     execute immediate l_query into l_punchout_option;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
	  l_punchout_option := '';
	  IF (PO_LOG.d_stmt) THEN
	    PO_LOG.stmt(d_module, d_position, i || '. No Data Found.');
	  END IF;
    END;


     -- Update punchout option for each item

     update ICX_CAT_PUNCHOUT_ITEMS set punchout_option = l_punchout_option
     where punchout_item_id = p_item_id_tbl(i);

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, i || '. Update Executed');
   END IF;

   END LOOP;

   d_position := 30;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'End update_punchout_option');
   END IF;

 EXCEPTION
 WHEN OTHERS THEN
   IF (PO_LOG.d_stmt) THEN
	PO_LOG.stmt(d_module, d_position, 'Exception at update_punchout_option');
   END IF;
   RAISE;
 END update_punchout_option;

-----------------------------------------------------------------------
 --Start of Comments
 --Name: getPurchasingCatId
 --Function:
 --  returns purchasing category id from shopping category id
 --Parameters:
 --IN:
 --p_shopCatId
 --  Shopping category id
 --IN OUT:
 --OUT:
 --End of Comments
 ------------------------------------------------------------------------

FUNCTION getPurchasingCatId(
	p_shopCatId IN NUMBER
	)
   RETURN number
IS
 d_api_name CONSTANT VARCHAR2(30) := 'getPurchasingCatId';
 d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
 d_position NUMBER;

 x_return NUMBER;
 l_structure_id NUMBER;
 l_validate_flag VARCHAR2(1);
 l_category_set_id NUMBER;

BEGIN

   d_position := 10;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Start getPurchasingCatId');
   END IF;

   SELECT structure_id, validate_flag, category_set_id
   into l_structure_id, l_validate_flag, l_category_set_id
   FROM   mtl_default_sets_view
   WHERE  functional_area_id = 2;

   d_position := 20;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'l_structure_id: ' || l_structure_id);
     PO_LOG.stmt(d_module, d_position, 'l_validate_flag: ' || l_validate_flag);
     PO_LOG.stmt(d_module, d_position, 'l_validate_flag: ' || l_validate_flag);
   END IF;

    IF(l_validate_flag = G_YES) THEN

	SELECT PurchCategories.category_id
	into x_return
	FROM ICX_POR_CATEGORY_ORDER_MAP ProcurementCatMapping,
	     ICX_CAT_CATEGORIES_TL Categories1,
	     FND_LOOKUP_VALUES LookupValues,
	     MTL_CATEGORIES_KFV PurchCategories,
	     MTL_CATEGORY_SET_VALID_CATS mcsvc
	WHERE Categories1.type = 2
	AND   Categories1.rt_category_id = ProcurementCatMapping.rt_category_id
	AND   LookupValues.language=Categories1.language
	AND   LookupValues.lookup_code=to_char(Categories1.type)
	AND   LookupValues.lookup_type='ICX_CAT_TYPE_POPLIST_VALUES'
	AND   mcsvc.CATEGORY_SET_ID = l_category_set_id
	AND   mcsvc.CATEGORY_ID = PurchCategories.CATEGORY_ID
	AND   ProcurementCatMapping.external_source_key = to_char(PurchCategories.category_id)
	AND   PurchCategories.structure_id = l_structure_id
	AND   nvl(PurchCategories.START_DATE_ACTIVE, sysdate) <= sysdate
	AND   sysdate < nvl(PurchCategories.END_DATE_ACTIVE, sysdate+1)
	AND   sysdate < nvl(PurchCategories.DISABLE_DATE, sysdate+1)
	AND   Categories1.RT_CATEGORY_ID = p_shopCatId
	AND   rownum = 1;

	d_position := 30;

	IF (PO_LOG.d_stmt) THEN
	  PO_LOG.stmt(d_module, d_position, 'category_id: ' || x_return);
	END IF;

    ELSE

	SELECT PurchCategories.category_id
	into x_return
	FROM ICX_POR_CATEGORY_ORDER_MAP ProcurementCatMapping,
	     ICX_CAT_CATEGORIES_TL Categories1,
	     FND_LOOKUP_VALUES LookupValues,
	     MTL_CATEGORIES_KFV PurchCategories
	WHERE Categories1.type = 2
	AND   Categories1.rt_category_id = ProcurementCatMapping.rt_category_id
	AND   LookupValues.language=Categories1.language
	AND   LookupValues.lookup_code=to_char(Categories1.type)
	AND   LookupValues.lookup_type='ICX_CAT_TYPE_POPLIST_VALUES'
	AND   ProcurementCatMapping.external_source_key = to_char(PurchCategories.category_id)
	AND   PurchCategories.structure_id = l_structure_id
	AND   nvl(PurchCategories.START_DATE_ACTIVE, sysdate) <= sysdate
	AND   sysdate < nvl(PurchCategories.END_DATE_ACTIVE, sysdate+1)
	AND   sysdate < nvl(PurchCategories.DISABLE_DATE, sysdate+1)
	AND   Categories1.RT_CATEGORY_ID = p_shopCatId
	AND   rownum = 1;

	d_position := 40;

	IF (PO_LOG.d_stmt) THEN
	  PO_LOG.stmt(d_module, d_position, 'category_id: ' || x_return);
	END IF;

    END IF;

     d_position := 50;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'End getPurchasingCatId');
   END IF;

   RETURN x_return;

EXCEPTION
 WHEN OTHERS THEN
   IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'Exception at getPurchasingCatId');
   END IF;
    return -1;
END getPurchasingCatId;

 -----------------------------------------------------------------------
 --Start of Comments
 --Name: update_attr_values_intf
 --Function:
 --  For all ids passed in, reject the corresponding records in attr values
 --  interface
 --Parameters:
 --IN:
 --p_h_id_tbl
 --  Table of header ids
 --p_l_id_tbl
 --  Table of line ids
 --p_process_code
 --  Process code to update
 --IN OUT:
 --OUT:
 --End of Comments
 ------------------------------------------------------------------------
 PROCEDURE update_attr_values_intf
 ( p_h_id_tbl IN PO_TBL_NUMBER,
   p_l_id_tbl IN PO_TBL_NUMBER,
   p_process_code VARCHAR2
 ) IS

 d_api_name CONSTANT VARCHAR2(30) := 'update_attr_values_intf';
 d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
 d_position NUMBER;

 BEGIN
   d_position := 10;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Start update_attr_values_intf');
     PO_LOG.stmt(d_module, d_position, 'p_process_code: '|| p_process_code);
   END IF;

   IF (p_h_id_tbl IS NULL OR p_h_id_tbl.COUNT = 0) THEN
     d_position := 20;
     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'Returning.');
     END IF;
     RETURN;
   END IF;

     d_position := 30;
     FORALL i IN 1..p_h_id_tbl.COUNT
       UPDATE po_attr_values_interface
       SET process_code = p_process_code
       WHERE interface_line_id = p_l_id_tbl(i) AND
       interface_header_id = p_h_id_tbl(i);

     d_position := 40;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'End update_attr_values_intf');
   END IF;

 EXCEPTION
 WHEN OTHERS THEN
   IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'Exception at update_attr_values_intf');
   END IF;
   RAISE;
 END update_attr_values_intf;


 -----------------------------------------------------------------------
 --Start of Comments
 --Name: update_attr_values_tl_intf
 --Function:
 --  For all ids passed in, reject the corresponding records in attr values
 --  tlp interface
 --Parameters:
 --IN:
 --p_h_id_tbl
 --  Table of header ids
 --p_l_id_tbl
 --  Table of line ids
 --p_process_code
 --  Process code to update
 --IN OUT:
 --OUT:
 --End of Comments
 ------------------------------------------------------------------------
 PROCEDURE update_attr_values_tl_intf
 ( p_h_id_tbl IN PO_TBL_NUMBER,
   p_l_id_tbl IN PO_TBL_NUMBER,
   p_process_code VARCHAR2
 ) IS

 d_api_name CONSTANT VARCHAR2(30) := 'update_attr_values_tl_intf';
 d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
 d_position NUMBER;


 BEGIN
   d_position := 10;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Start update_attr_values_tl_intf');
     PO_LOG.stmt(d_module, d_position, 'p_process_code: '|| p_process_code);
   END IF;

   IF (p_h_id_tbl IS NULL OR p_h_id_tbl.COUNT = 0) THEN
     d_position := 20;
     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'Returning.');
     END IF;
     RETURN;
   END IF;

     d_position := 30;
     FORALL i IN 1..p_h_id_tbl.COUNT
       UPDATE po_attr_values_tlp_interface
       SET process_code = p_process_code
       WHERE interface_line_id = p_l_id_tbl(i) AND
       interface_header_id = p_h_id_tbl(i);

     d_position := 40;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'End update_attr_values_tl_intf');
   END IF;

 EXCEPTION
 WHEN OTHERS THEN
   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Exception at update_attr_values_tl_intf');
   END IF;
   RAISE;
 END update_attr_values_tl_intf;

 -----------------------------------------------------------------------
 --Start of Comments
 --Name: update_lines_intf_process
 --Function:
 --  For all ids passed in, update the corresponding records in lines
 --  interface with process code
 --Parameters:
 --IN:
 --p_id_tbl
 --  Table of line ids
 --p_process_code
 --  Process code to update
 --p_cascade
 --  flag to process related attr entry
 --IN OUT:
 --OUT:
 --End of Comments
 ------------------------------------------------------------------------
 PROCEDURE update_lines_intf_process (
   p_id_tbl IN PO_TBL_NUMBER,
   p_process_code VARCHAR2,
   p_cascade IN VARCHAR2
 ) IS

 d_api_name CONSTANT VARCHAR2(30) := 'update_lines_intf_process';
 d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
 d_position NUMBER;

 l_intf_line_id_tbl PO_TBL_NUMBER;
 l_intf_header_id_tbl PO_TBL_NUMBER;
 BEGIN
   d_position := 10;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Start update_lines_intf_process');
     PO_LOG.stmt(d_module, d_position, 'p_process_code: '|| p_process_code);
     PO_LOG.stmt(d_module, d_position, 'p_cascade: '|| p_cascade);
   END IF;

   IF (p_id_tbl IS NULL OR p_id_tbl.COUNT = 0) THEN
     d_position := 20;
     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'Returning.');
     END IF;
     RETURN;
   END IF;

    d_position := 30;

     FORALL i IN 1..p_id_tbl.COUNT
       UPDATE po_lines_interface
       SET process_code = p_process_code
       WHERE interface_line_id = p_id_tbl(i)
     RETURNING interface_line_id, interface_header_id
     BULK COLLECT INTO l_intf_line_id_tbl, l_intf_header_id_tbl;

     d_position := 40;

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'Lines Updation Complete');
     END IF;

   IF (p_cascade = G_YES) THEN

       d_position := 50;
   	update_attr_values_intf
       ( p_h_id_tbl => l_intf_header_id_tbl,
       	 p_l_id_tbl => l_intf_line_id_tbl,
       	 p_process_code => g_PROCESS_CODE_REJECTED);

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'Attr Values Updation Complete');
     END IF;

       d_position := 60;
       update_attr_values_tl_intf
       ( p_h_id_tbl => l_intf_header_id_tbl,
       	 p_l_id_tbl => l_intf_line_id_tbl,
       	 p_process_code => g_PROCESS_CODE_REJECTED);

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'Attr Values Tlp Updation Complete');
     END IF;

   END IF;

   d_position := 70;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'End update_lines_intf_process');
   END IF;

 EXCEPTION
 WHEN OTHERS THEN
   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Exception at update_lines_intf_process');
   END IF;
   RAISE;
 END update_lines_intf_process;

 -----------------------------------------------------------------------
 --Start of Comments
 --Name: reject_invalid_process_lines
 --Function: For errors in the parsing code, process code will be
 --          VALIDATE AND REJECT. System will reject these lines.
 --Parameters:
 --IN:
 --p_err_lines_tolerance
 --  No. of errors to ignore
 --IN OUT:
 --OUT:
 --x_rejected_lines_count
 --  No. of rejected line
 --x_err_tolerance_exceeded
 --  error tolerance exceed flag
 --End of Comments
 ------------------------------------------------------------------------
 PROCEDURE reject_invalid_process_lines(
   p_err_lines_tolerance IN NUMBER,
  x_rejected_lines_count OUT NOCOPY NUMBER,
  x_err_tolerance_exceeded OUT NOCOPY VARCHAR2
) IS

   d_api_name CONSTANT VARCHAR2(30) := 'reject_invalid_process_lines';
   d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
   d_position NUMBER;

   -- select lines with invalid line level action value
   CURSOR c_invalid_action_lines IS
   SELECT intf_lines.interface_line_id,
	  intf_headers.interface_header_id,
	  intf_lines.action
   FROM   po_lines_interface intf_lines,
	  po_headers_interface intf_headers
   WHERE  intf_lines.interface_header_id = intf_headers.interface_header_id
   AND    intf_headers.batch_id = g_batch_id
   AND    NVL(intf_lines.process_code, g_PROCESS_CODE_PENDING) = g_PROCESS_CODE_VAL_AND_REJECT;

   -- interface line id of lines that need to be rejected
   l_rej_intf_line_id_tbl   PO_TBL_NUMBER;
   l_rej_intf_header_id_tbl PO_TBL_NUMBER;
   l_rej_line_action_tbl    PO_TBL_VARCHAR30;

 BEGIN
   d_position := 0;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Start reject_invalid_process_lines');
     PO_LOG.stmt(d_module, d_position, 'p_err_lines_tolerance: '|| p_err_lines_tolerance);
   END IF;

   -- get all invalid lines from cursor
   OPEN c_invalid_action_lines();

   d_position := 10;

   FETCH c_invalid_action_lines
   BULK COLLECT INTO
     l_rej_intf_line_id_tbl, l_rej_intf_header_id_tbl, l_rej_line_action_tbl;

   d_position := 20;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'count of lines with invalid process code',
	       l_rej_intf_line_id_tbl.COUNT);
   END IF;

   -- reject the lines and the lower level entities associated with it
   update_lines_intf_process
   (
     p_id_tbl       => l_rej_intf_line_id_tbl,
     p_process_code => g_PROCESS_CODE_VAL_AND_REJECT,
     p_cascade => G_YES
   );

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Lines Reject Complete');
   END IF;
   d_position := 50;

   CLOSE c_invalid_action_lines;

     x_rejected_lines_count := l_rej_intf_line_id_tbl.Count;
     IF (x_rejected_lines_count > p_err_lines_tolerance) THEN
        x_err_tolerance_exceeded := G_YES;
     ELSE
        x_err_tolerance_exceeded := G_NO;
     END IF;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'End reject_invalid_process_lines');
   END IF;

 EXCEPTION
   WHEN OTHERS THEN
   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Exception at reject_invalid_process_lines');
   END IF;
     RAISE;
 END reject_invalid_process_lines;

 -----------------------------------------------------------------------
 --Start of Comments
 --Name: reject_invalid_action_lines
 --Function: The valid value of line level action is NULL or 'ADD' when
 --          user issues a PDOI request. System will reject lines with
 --          invalid action values.
 --Parameters:
 --IN:
 --p_err_lines_tolerance
 --  No. of errors to ignore
 --IN OUT:
 --OUT:
 --x_rejected_lines_count
 --  No. of rejected line
 --x_err_tolerance_exceeded
 --  error tolerance exceed flag
 --End of Comments
 ------------------------------------------------------------------------
 PROCEDURE reject_invalid_action_lines(
   p_err_lines_tolerance IN NUMBER,
  x_rejected_lines_count OUT NOCOPY NUMBER,
  x_err_tolerance_exceeded OUT NOCOPY VARCHAR2
) IS

   d_api_name CONSTANT VARCHAR2(30) := 'reject_invalid_action_lines';
   d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
   d_position NUMBER;

   -- select lines with invalid line level action value
   CURSOR c_invalid_action_lines IS
   SELECT intf_lines.interface_line_id,
	  intf_headers.interface_header_id,
	  intf_lines.action
   FROM   po_lines_interface intf_lines,
	  po_headers_interface intf_headers
   WHERE  intf_lines.interface_header_id = intf_headers.interface_header_id
   AND    intf_headers.batch_id = g_batch_id
   AND    NVL(intf_lines.action, g_ACTION_ADD) not in
	  (g_ACTION_ADD, g_ACTION_DELETE, g_ACTION_UPDATE, g_ACTION_SYNC);

   -- interface line id of lines that need to be rejected
   l_rej_intf_line_id_tbl   PO_TBL_NUMBER;
   l_rej_intf_header_id_tbl PO_TBL_NUMBER;
   l_rej_line_action_tbl    PO_TBL_VARCHAR30;

 BEGIN
   d_position := 0;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Start reject_invalid_action_lines');
     PO_LOG.stmt(d_module, d_position, 'p_err_lines_tolerance: '|| p_err_lines_tolerance);
   END IF;

   -- get all invalid lines from cursor
   OPEN c_invalid_action_lines();

   d_position := 10;

   FETCH c_invalid_action_lines
   BULK COLLECT INTO
     l_rej_intf_line_id_tbl, l_rej_intf_header_id_tbl, l_rej_line_action_tbl;

   d_position := 20;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'count of lines with invalid actions',
	       l_rej_intf_line_id_tbl.COUNT);
   END IF;

     d_position := 30;
   -- add error if an invalid line is found
   FOR i IN 1..l_rej_intf_line_id_tbl.COUNT
   LOOP

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, i || '. rejected interface line id',
		   l_rej_intf_line_id_tbl(i));
     END IF;

     PO_PDOI_ERR_UTL.add_fatal_error
     (
       p_interface_header_id  => l_rej_intf_header_id_tbl(i),
       p_interface_line_id    => l_rej_intf_line_id_tbl(i),
       p_error_message_name   => 'PO_PDOI_INVALID_ACTION',
       p_table_name           => 'PO_LINES_INTERFACE',
       p_column_name          => 'ACTION',
       p_column_value         => l_rej_line_action_tbl(i),
       p_token1_name          => 'VALUE',
       p_token1_value         => l_rej_line_action_tbl(i)
     );
   END LOOP;

   d_position := 40;

   -- reject the lines and the lower level entities associated with it
   update_lines_intf_process
   (
     p_id_tbl                  => l_rej_intf_line_id_tbl,
     p_process_code => g_PROCESS_CODE_REJECTED,
     p_cascade => G_YES
   );

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Lines Reject Complete');
   END IF;
   d_position := 50;

   CLOSE c_invalid_action_lines;

     x_rejected_lines_count := l_rej_intf_line_id_tbl.Count;
     IF (x_rejected_lines_count > p_err_lines_tolerance) THEN
        x_err_tolerance_exceeded := G_YES;
     ELSE
        x_err_tolerance_exceeded := G_NO;
     END IF;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'End reject_invalid_action_lines');
   END IF;

 EXCEPTION
   WHEN OTHERS THEN
   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Exception at reject_invalid_action_lines');
   END IF;
     RAISE;
 END reject_invalid_action_lines;

-----------------------------------------------------------------------
 --Start of Comments
 --Name: sync_endeca_item_attrs
 --Function:
 --  For all ids passed in, sync the corresponding endeca item attr records
 --Parameters:
 --IN:
 --p_item_id_tbl
 --  Table of item ids
 --IN OUT:
 --OUT:
 --End of Comments
 ------------------------------------------------------------------------
 PROCEDURE sync_endeca_item_attrs(
   p_item_id_tbl IN PO_TBL_NUMBER
   ) IS

   d_api_name CONSTANT VARCHAR2(30) := 'sync_endeca_item_attrs';
   d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
   d_position NUMBER;

   x_count number;
   l_attr_lang_tbl PO_TBL_VARCHAR5;
   BEGIN

   d_position := 10;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Start sync_endeca_item_attrs');
   END IF;

   FOR i IN 1..p_item_id_tbl.COUNT
   LOOP

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, i || '. Processing Item ID: '|| p_item_id_tbl(i));
     END IF;
     -- Update endeca attr table for each item
     x_count := 0;

     select count(*) into x_count
	    from ICX_CAT_ENDECA_ITEM_ATTRIBUTES
	    where
	    recordkey = to_char(p_item_id_tbl(i));

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'Count: '|| x_count);
     END IF;

     IF (x_count > 0) THEN

     	update ICX_CAT_ENDECA_ITEM_ATTRIBUTES set attributevalue = to_char(g_content_zone_id)
     	where recordkey = to_char(p_item_id_tbl(i));

        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'Update Complete');
        END IF;

     ELSE --insert

	select language_code
        BULK COLLECT INTO l_attr_lang_tbl
        from fnd_languages
	WHERE installed_flag in ('B', 'I');

	   IF (PO_LOG.d_stmt) THEN
	     PO_LOG.stmt(d_module, d_position, 'Number of language found: ',
		       l_attr_lang_tbl.COUNT);
	   END IF;

        FOR j IN 1..l_attr_lang_tbl.COUNT
        LOOP

     	insert into ICX_CAT_ENDECA_ITEM_ATTRIBUTES(recordkey,attributekey,attributevalue,language,updatetime) values(to_char(p_item_id_tbl(i)), 'ZONESB', to_char(g_content_zone_id), l_attr_lang_tbl(j), sysdate);
     	insert into ICX_CAT_ENDECA_ITEM_ATTRIBUTES(recordkey,attributekey,attributevalue,language,updatetime) values(to_char(p_item_id_tbl(i)), 'ZONESP', to_char(g_content_zone_id), l_attr_lang_tbl(j), sysdate);
     	insert into ICX_CAT_ENDECA_ITEM_ATTRIBUTES(recordkey,attributekey,attributevalue,language,updatetime) values(to_char(p_item_id_tbl(i)), 'ZONESI', to_char(g_content_zone_id), l_attr_lang_tbl(j), sysdate);

     	end loop;

        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'Insert Complete');
        END IF;

     END IF;

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, i || '. Completed Item ID: '|| p_item_id_tbl(i));
     END IF;

   END LOOP;

   d_position := 20;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'End sync_endeca_item_attrs');
   END IF;

 EXCEPTION
 WHEN OTHERS THEN
   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Exception at sync_endeca_item_attrs');
   END IF;
   RAISE;
 END sync_endeca_item_attrs;

-----------------------------------------------------------------------
 --Start of Comments
 --Name: sync_attr_values_intf
 --Function:
 --  For all ids passed in, sync the corresponding records for attr values table
 --  interface
 --Parameters:
 --IN:
 --p_line_id_tbl
 --  Table of line ids
 --p_header_id_tbl
 --  Table of header ids
 --p_item_id_tbl
 --  Table of item ids
 --IN OUT:
 --OUT:
 --End of Comments
 ------------------------------------------------------------------------
 PROCEDURE sync_attr_values_intf(
   p_line_id_tbl IN PO_TBL_NUMBER,
   p_header_id_tbl IN PO_TBL_NUMBER,
   p_item_id_tbl IN PO_TBL_NUMBER
 ) IS

 d_api_name CONSTANT VARCHAR2(30) := 'sync_attr_values_intf';
 d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
 d_position NUMBER;

 l_intf_line_id_tbl PO_TBL_NUMBER;
 l_intf_header_id_tbl PO_TBL_NUMBER;

   x_old_attr item_attr_rec_type;

   x_count number;
   x_temp_item_id number;
   x_temp_attr_id number;
   x_creation_date date;
   x_created_by date;

   -- interface line id of lines that is accepted
   l_acc_intf_line_id_tbl   PO_TBL_NUMBER := PO_TBL_NUMBER();
   l_acc_intf_header_id_tbl   PO_TBL_NUMBER := PO_TBL_NUMBER();

 BEGIN
   d_position := 10;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Start sync_attr_values_intf');
   END IF;

   IF (p_line_id_tbl IS NULL OR p_line_id_tbl.COUNT = 0) THEN
     d_position := 20;
     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'Returning');
     END IF;
     RETURN;
   END IF;

    d_position := 30;

   FOR i IN 1..p_item_id_tbl.COUNT
   LOOP

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, i || '. Processing Item ID: '|| p_item_id_tbl(i));
     END IF;

     x_count := 0;

     select count(*) into x_count
	    from ICX_CAT_PCH_ITEM_ATTRS_TLP where
	    punchout_item_id = p_item_id_tbl(i);

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'Count: '|| x_count);
     END IF;

     IF (x_count > 0) THEN

	-- Fetch attr interface values for the line id and header id
     select
     punchout_item_id,
     attribute_values_id,
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
     into
	x_old_attr.punchout_item_id,
	x_old_attr.attribute_values_id,
	x_old_attr.org_id,
	x_old_attr.manufacturer_part_num,
	x_old_attr.picture,
	x_old_attr.thumbnail_image,
	x_old_attr.supplier_url,
	x_old_attr.manufacturer_url,
	x_old_attr.attachment_url,
	x_old_attr.unspsc,
	x_old_attr.availability,
	x_old_attr.lead_time,
	x_old_attr.text_base_attribute1,
	x_old_attr.text_base_attribute2,
	x_old_attr.text_base_attribute3,
	x_old_attr.text_base_attribute4,
	x_old_attr.text_base_attribute5,
	x_old_attr.text_base_attribute6,
	x_old_attr.text_base_attribute7,
	x_old_attr.text_base_attribute8,
	x_old_attr.text_base_attribute9,
	x_old_attr.text_base_attribute10,
	x_old_attr.text_base_attribute11,
	x_old_attr.text_base_attribute12,
	x_old_attr.text_base_attribute13,
	x_old_attr.text_base_attribute14,
	x_old_attr.text_base_attribute15,
	x_old_attr.text_base_attribute16,
	x_old_attr.text_base_attribute17,
	x_old_attr.text_base_attribute18,
	x_old_attr.text_base_attribute19,
	x_old_attr.text_base_attribute20,
	x_old_attr.text_base_attribute21,
	x_old_attr.text_base_attribute22,
	x_old_attr.text_base_attribute23,
	x_old_attr.text_base_attribute24,
	x_old_attr.text_base_attribute25,
	x_old_attr.text_base_attribute26,
	x_old_attr.text_base_attribute27,
	x_old_attr.text_base_attribute28,
	x_old_attr.text_base_attribute29,
	x_old_attr.text_base_attribute30,
	x_old_attr.text_base_attribute31,
	x_old_attr.text_base_attribute32,
	x_old_attr.text_base_attribute33,
	x_old_attr.text_base_attribute34,
	x_old_attr.text_base_attribute35,
	x_old_attr.text_base_attribute36,
	x_old_attr.text_base_attribute37,
	x_old_attr.text_base_attribute38,
	x_old_attr.text_base_attribute39,
	x_old_attr.text_base_attribute40,
	x_old_attr.text_base_attribute41,
	x_old_attr.text_base_attribute42,
	x_old_attr.text_base_attribute43,
	x_old_attr.text_base_attribute44,
	x_old_attr.text_base_attribute45,
	x_old_attr.text_base_attribute46,
	x_old_attr.text_base_attribute47,
	x_old_attr.text_base_attribute48,
	x_old_attr.text_base_attribute49,
	x_old_attr.text_base_attribute50,
	x_old_attr.text_base_attribute51,
	x_old_attr.text_base_attribute52,
	x_old_attr.text_base_attribute53,
	x_old_attr.text_base_attribute54,
	x_old_attr.text_base_attribute55,
	x_old_attr.text_base_attribute56,
	x_old_attr.text_base_attribute57,
	x_old_attr.text_base_attribute58,
	x_old_attr.text_base_attribute59,
	x_old_attr.text_base_attribute60,
	x_old_attr.text_base_attribute61,
	x_old_attr.text_base_attribute62,
	x_old_attr.text_base_attribute63,
	x_old_attr.text_base_attribute64,
	x_old_attr.text_base_attribute65,
	x_old_attr.text_base_attribute66,
	x_old_attr.text_base_attribute67,
	x_old_attr.text_base_attribute68,
	x_old_attr.text_base_attribute69,
	x_old_attr.text_base_attribute70,
	x_old_attr.text_base_attribute71,
	x_old_attr.text_base_attribute72,
	x_old_attr.text_base_attribute73,
	x_old_attr.text_base_attribute74,
	x_old_attr.text_base_attribute75,
	x_old_attr.text_base_attribute76,
	x_old_attr.text_base_attribute77,
	x_old_attr.text_base_attribute78,
	x_old_attr.text_base_attribute79,
	x_old_attr.text_base_attribute80,
	x_old_attr.text_base_attribute81,
	x_old_attr.text_base_attribute82,
	x_old_attr.text_base_attribute83,
	x_old_attr.text_base_attribute84,
	x_old_attr.text_base_attribute85,
	x_old_attr.text_base_attribute86,
	x_old_attr.text_base_attribute87,
	x_old_attr.text_base_attribute88,
	x_old_attr.text_base_attribute89,
	x_old_attr.text_base_attribute90,
	x_old_attr.text_base_attribute91,
	x_old_attr.text_base_attribute92,
	x_old_attr.text_base_attribute93,
	x_old_attr.text_base_attribute94,
	x_old_attr.text_base_attribute95,
	x_old_attr.text_base_attribute96,
	x_old_attr.text_base_attribute97,
	x_old_attr.text_base_attribute98,
	x_old_attr.text_base_attribute99,
	x_old_attr.text_base_attribute100,
	x_old_attr.num_base_attribute1,
	x_old_attr.num_base_attribute2,
	x_old_attr.num_base_attribute3,
	x_old_attr.num_base_attribute4,
	x_old_attr.num_base_attribute5,
	x_old_attr.num_base_attribute6,
	x_old_attr.num_base_attribute7,
	x_old_attr.num_base_attribute8,
	x_old_attr.num_base_attribute9,
	x_old_attr.num_base_attribute10,
	x_old_attr.num_base_attribute11,
	x_old_attr.num_base_attribute12,
	x_old_attr.num_base_attribute13,
	x_old_attr.num_base_attribute14,
	x_old_attr.num_base_attribute15,
	x_old_attr.num_base_attribute16,
	x_old_attr.num_base_attribute17,
	x_old_attr.num_base_attribute18,
	x_old_attr.num_base_attribute19,
	x_old_attr.num_base_attribute20,
	x_old_attr.num_base_attribute21,
	x_old_attr.num_base_attribute22,
	x_old_attr.num_base_attribute23,
	x_old_attr.num_base_attribute24,
	x_old_attr.num_base_attribute25,
	x_old_attr.num_base_attribute26,
	x_old_attr.num_base_attribute27,
	x_old_attr.num_base_attribute28,
	x_old_attr.num_base_attribute29,
	x_old_attr.num_base_attribute30,
	x_old_attr.num_base_attribute31,
	x_old_attr.num_base_attribute32,
	x_old_attr.num_base_attribute33,
	x_old_attr.num_base_attribute34,
	x_old_attr.num_base_attribute35,
	x_old_attr.num_base_attribute36,
	x_old_attr.num_base_attribute37,
	x_old_attr.num_base_attribute38,
	x_old_attr.num_base_attribute39,
	x_old_attr.num_base_attribute40,
	x_old_attr.num_base_attribute41,
	x_old_attr.num_base_attribute42,
	x_old_attr.num_base_attribute43,
	x_old_attr.num_base_attribute44,
	x_old_attr.num_base_attribute45,
	x_old_attr.num_base_attribute46,
	x_old_attr.num_base_attribute47,
	x_old_attr.num_base_attribute48,
	x_old_attr.num_base_attribute49,
	x_old_attr.num_base_attribute50,
	x_old_attr.num_base_attribute51,
	x_old_attr.num_base_attribute52,
	x_old_attr.num_base_attribute53,
	x_old_attr.num_base_attribute54,
	x_old_attr.num_base_attribute55,
	x_old_attr.num_base_attribute56,
	x_old_attr.num_base_attribute57,
	x_old_attr.num_base_attribute58,
	x_old_attr.num_base_attribute59,
	x_old_attr.num_base_attribute60,
	x_old_attr.num_base_attribute61,
	x_old_attr.num_base_attribute62,
	x_old_attr.num_base_attribute63,
	x_old_attr.num_base_attribute64,
	x_old_attr.num_base_attribute65,
	x_old_attr.num_base_attribute66,
	x_old_attr.num_base_attribute67,
	x_old_attr.num_base_attribute68,
	x_old_attr.num_base_attribute69,
	x_old_attr.num_base_attribute70,
	x_old_attr.num_base_attribute71,
	x_old_attr.num_base_attribute72,
	x_old_attr.num_base_attribute73,
	x_old_attr.num_base_attribute74,
	x_old_attr.num_base_attribute75,
	x_old_attr.num_base_attribute76,
	x_old_attr.num_base_attribute77,
	x_old_attr.num_base_attribute78,
	x_old_attr.num_base_attribute79,
	x_old_attr.num_base_attribute80,
	x_old_attr.num_base_attribute81,
	x_old_attr.num_base_attribute82,
	x_old_attr.num_base_attribute83,
	x_old_attr.num_base_attribute84,
	x_old_attr.num_base_attribute85,
	x_old_attr.num_base_attribute86,
	x_old_attr.num_base_attribute87,
	x_old_attr.num_base_attribute88,
	x_old_attr.num_base_attribute89,
	x_old_attr.num_base_attribute90,
	x_old_attr.num_base_attribute91,
	x_old_attr.num_base_attribute92,
	x_old_attr.num_base_attribute93,
	x_old_attr.num_base_attribute94,
	x_old_attr.num_base_attribute95,
	x_old_attr.num_base_attribute96,
	x_old_attr.num_base_attribute97,
	x_old_attr.num_base_attribute98,
	x_old_attr.num_base_attribute99,
	x_old_attr.num_base_attribute100,
	x_old_attr.text_cat_attribute1,
	x_old_attr.text_cat_attribute2,
	x_old_attr.text_cat_attribute3,
	x_old_attr.text_cat_attribute4,
	x_old_attr.text_cat_attribute5,
	x_old_attr.text_cat_attribute6,
	x_old_attr.text_cat_attribute7,
	x_old_attr.text_cat_attribute8,
	x_old_attr.text_cat_attribute9,
	x_old_attr.text_cat_attribute10,
	x_old_attr.text_cat_attribute11,
	x_old_attr.text_cat_attribute12,
	x_old_attr.text_cat_attribute13,
	x_old_attr.text_cat_attribute14,
	x_old_attr.text_cat_attribute15,
	x_old_attr.text_cat_attribute16,
	x_old_attr.text_cat_attribute17,
	x_old_attr.text_cat_attribute18,
	x_old_attr.text_cat_attribute19,
	x_old_attr.text_cat_attribute20,
	x_old_attr.text_cat_attribute21,
	x_old_attr.text_cat_attribute22,
	x_old_attr.text_cat_attribute23,
	x_old_attr.text_cat_attribute24,
	x_old_attr.text_cat_attribute25,
	x_old_attr.text_cat_attribute26,
	x_old_attr.text_cat_attribute27,
	x_old_attr.text_cat_attribute28,
	x_old_attr.text_cat_attribute29,
	x_old_attr.text_cat_attribute30,
	x_old_attr.text_cat_attribute31,
	x_old_attr.text_cat_attribute32,
	x_old_attr.text_cat_attribute33,
	x_old_attr.text_cat_attribute34,
	x_old_attr.text_cat_attribute35,
	x_old_attr.text_cat_attribute36,
	x_old_attr.text_cat_attribute37,
	x_old_attr.text_cat_attribute38,
	x_old_attr.text_cat_attribute39,
	x_old_attr.text_cat_attribute40,
	x_old_attr.text_cat_attribute41,
	x_old_attr.text_cat_attribute42,
	x_old_attr.text_cat_attribute43,
	x_old_attr.text_cat_attribute44,
	x_old_attr.text_cat_attribute45,
	x_old_attr.text_cat_attribute46,
	x_old_attr.text_cat_attribute47,
	x_old_attr.text_cat_attribute48,
	x_old_attr.text_cat_attribute49,
	x_old_attr.text_cat_attribute50,
	x_old_attr.num_cat_attribute1,
	x_old_attr.num_cat_attribute2,
	x_old_attr.num_cat_attribute3,
	x_old_attr.num_cat_attribute4,
	x_old_attr.num_cat_attribute5,
	x_old_attr.num_cat_attribute6,
	x_old_attr.num_cat_attribute7,
	x_old_attr.num_cat_attribute8,
	x_old_attr.num_cat_attribute9,
	x_old_attr.num_cat_attribute10,
	x_old_attr.num_cat_attribute11,
	x_old_attr.num_cat_attribute12,
	x_old_attr.num_cat_attribute13,
	x_old_attr.num_cat_attribute14,
	x_old_attr.num_cat_attribute15,
	x_old_attr.num_cat_attribute16,
	x_old_attr.num_cat_attribute17,
	x_old_attr.num_cat_attribute18,
	x_old_attr.num_cat_attribute19,
	x_old_attr.num_cat_attribute20,
	x_old_attr.num_cat_attribute21,
	x_old_attr.num_cat_attribute22,
	x_old_attr.num_cat_attribute23,
	x_old_attr.num_cat_attribute24,
	x_old_attr.num_cat_attribute25,
	x_old_attr.num_cat_attribute26,
	x_old_attr.num_cat_attribute27,
	x_old_attr.num_cat_attribute28,
	x_old_attr.num_cat_attribute29,
	x_old_attr.num_cat_attribute30,
	x_old_attr.num_cat_attribute31,
	x_old_attr.num_cat_attribute32,
	x_old_attr.num_cat_attribute33,
	x_old_attr.num_cat_attribute34,
	x_old_attr.num_cat_attribute35,
	x_old_attr.num_cat_attribute36,
	x_old_attr.num_cat_attribute37,
	x_old_attr.num_cat_attribute38,
	x_old_attr.num_cat_attribute39,
	x_old_attr.num_cat_attribute40,
	x_old_attr.num_cat_attribute41,
	x_old_attr.num_cat_attribute42,
	x_old_attr.num_cat_attribute43,
	x_old_attr.num_cat_attribute44,
	x_old_attr.num_cat_attribute45,
	x_old_attr.num_cat_attribute46,
	x_old_attr.num_cat_attribute47,
	x_old_attr.num_cat_attribute48,
	x_old_attr.num_cat_attribute49,
	x_old_attr.num_cat_attribute50,
	x_old_attr.last_update_login,
	x_old_attr.last_updated_by,
	x_old_attr.last_update_date,
	x_old_attr.created_by,
	x_old_attr.creation_date,
	x_old_attr.request_id,
	x_old_attr.program_application_id,
	x_old_attr.program_id,
	x_old_attr.program_update_date,
	x_old_attr.last_updated_program
	from ICX_CAT_PCH_ITEM_ATTRS
  where
	punchout_item_id = p_item_id_tbl(i);

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'OLD Item Data Collected');
     END IF;

	delete
	ICX_CAT_PCH_ITEM_ATTRS
  where
	punchout_item_id = p_item_id_tbl(i);

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'Item Deleted');
     END IF;

insert into ICX_CAT_PCH_ITEM_ATTRS(
	punchout_item_id,
	attribute_values_id,
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
	program_update_date)
	select			-- values
	x_old_attr.punchout_item_id,
	x_old_attr.attribute_values_id,
	decode(nvl(org_id,x_old_attr.org_id),'#DEL',null,org_id),
	decode(nvl(manufacturer_part_num,x_old_attr.manufacturer_part_num),'#DEL',null,manufacturer_part_num),
	decode(nvl(picture,x_old_attr.picture),'#DEL',null,picture),
	decode(nvl(thumbnail_image,x_old_attr.thumbnail_image),'#DEL',null,thumbnail_image),
	decode(nvl(supplier_url,x_old_attr.supplier_url),'#DEL',null,supplier_url),
	decode(nvl(manufacturer_url,x_old_attr.manufacturer_url),'#DEL',null,manufacturer_url),
	decode(nvl(attachment_url, x_old_attr.attachment_url),'#DEL',null,attachment_url),
	decode(nvl(unspsc,x_old_attr.unspsc),'#DEL',null,unspsc),
	decode(nvl(availability,x_old_attr.availability),'#DEL',null,availability),
	decode(nvl(lead_time,x_old_attr.lead_time),'#DEL',null,lead_time),
	decode(nvl(text_base_attribute1, x_old_attr.text_base_attribute1),'#DEL',null,text_base_attribute1),
	decode(nvl(text_base_attribute2, x_old_attr.text_base_attribute2),'#DEL',null,text_base_attribute2),
	decode(nvl(text_base_attribute3, x_old_attr.text_base_attribute3),'#DEL',null,text_base_attribute3),
	decode(nvl(text_base_attribute4, x_old_attr.text_base_attribute4),'#DEL',null,text_base_attribute4),
	decode(nvl(text_base_attribute5, x_old_attr.text_base_attribute5),'#DEL',null,text_base_attribute5),
	decode(nvl(text_base_attribute6, x_old_attr.text_base_attribute6),'#DEL',null,text_base_attribute6),
	decode(nvl(text_base_attribute7, x_old_attr.text_base_attribute7),'#DEL',null,text_base_attribute7),
	decode(nvl(text_base_attribute8, x_old_attr.text_base_attribute8),'#DEL',null,text_base_attribute8),
	decode(nvl(text_base_attribute9, x_old_attr.text_base_attribute9),'#DEL',null,text_base_attribute9),
	decode(nvl(text_base_attribute10,x_old_attr.text_base_attribute10),'#DEL',null,text_base_attribute10),
	decode(nvl(text_base_attribute11,x_old_attr.text_base_attribute11),'#DEL',null,text_base_attribute11),
	decode(nvl(text_base_attribute12,x_old_attr.text_base_attribute12),'#DEL',null,text_base_attribute12),
	decode(nvl(text_base_attribute13,x_old_attr.text_base_attribute13),'#DEL',null,text_base_attribute13),
	decode(nvl(text_base_attribute14,x_old_attr.text_base_attribute14),'#DEL',null,text_base_attribute14),
	decode(nvl(text_base_attribute15,x_old_attr.text_base_attribute15),'#DEL',null,text_base_attribute15),
	decode(nvl(text_base_attribute16,x_old_attr.text_base_attribute16),'#DEL',null,text_base_attribute16),
	decode(nvl(text_base_attribute17,x_old_attr.text_base_attribute17),'#DEL',null,text_base_attribute17),
	decode(nvl(text_base_attribute18,x_old_attr.text_base_attribute18),'#DEL',null,text_base_attribute18),
	decode(nvl(text_base_attribute19,x_old_attr.text_base_attribute19),'#DEL',null,text_base_attribute19),
	decode(nvl(text_base_attribute20,x_old_attr.text_base_attribute20),'#DEL',null,text_base_attribute20),
	decode(nvl(text_base_attribute21,x_old_attr.text_base_attribute21),'#DEL',null,text_base_attribute21),
	decode(nvl(text_base_attribute22,x_old_attr.text_base_attribute22),'#DEL',null,text_base_attribute22),
	decode(nvl(text_base_attribute23,x_old_attr.text_base_attribute23),'#DEL',null,text_base_attribute23),
	decode(nvl(text_base_attribute24,x_old_attr.text_base_attribute24),'#DEL',null,text_base_attribute24),
	decode(nvl(text_base_attribute25,x_old_attr.text_base_attribute25),'#DEL',null,text_base_attribute25),
	decode(nvl(text_base_attribute26,x_old_attr.text_base_attribute26),'#DEL',null,text_base_attribute26),
	decode(nvl(text_base_attribute27,x_old_attr.text_base_attribute27),'#DEL',null,text_base_attribute27),
	decode(nvl(text_base_attribute28,x_old_attr.text_base_attribute28),'#DEL',null,text_base_attribute28),
	decode(nvl(text_base_attribute29,x_old_attr.text_base_attribute29),'#DEL',null,text_base_attribute29),
	decode(nvl(text_base_attribute30,x_old_attr.text_base_attribute30),'#DEL',null,text_base_attribute30),
	decode(nvl(text_base_attribute31,x_old_attr.text_base_attribute31),'#DEL',null,text_base_attribute31),
	decode(nvl(text_base_attribute32,x_old_attr.text_base_attribute32),'#DEL',null,text_base_attribute32),
	decode(nvl(text_base_attribute33,x_old_attr.text_base_attribute33),'#DEL',null,text_base_attribute33),
	decode(nvl(text_base_attribute34,x_old_attr.text_base_attribute34),'#DEL',null,text_base_attribute34),
	decode(nvl(text_base_attribute35,x_old_attr.text_base_attribute35),'#DEL',null,text_base_attribute35),
	decode(nvl(text_base_attribute36,x_old_attr.text_base_attribute36),'#DEL',null,text_base_attribute36),
	decode(nvl(text_base_attribute37,x_old_attr.text_base_attribute37),'#DEL',null,text_base_attribute37),
	decode(nvl(text_base_attribute38,x_old_attr.text_base_attribute38),'#DEL',null,text_base_attribute38),
	decode(nvl(text_base_attribute39,x_old_attr.text_base_attribute39),'#DEL',null,text_base_attribute39),
	decode(nvl(text_base_attribute40,x_old_attr.text_base_attribute40),'#DEL',null,text_base_attribute40),
	decode(nvl(text_base_attribute41,x_old_attr.text_base_attribute41),'#DEL',null,text_base_attribute41),
	decode(nvl(text_base_attribute42,x_old_attr.text_base_attribute42),'#DEL',null,text_base_attribute42),
	decode(nvl(text_base_attribute43,x_old_attr.text_base_attribute43),'#DEL',null,text_base_attribute43),
	decode(nvl(text_base_attribute44,x_old_attr.text_base_attribute44),'#DEL',null,text_base_attribute44),
	decode(nvl(text_base_attribute45,x_old_attr.text_base_attribute45),'#DEL',null,text_base_attribute45),
	decode(nvl(text_base_attribute46,x_old_attr.text_base_attribute46),'#DEL',null,text_base_attribute46),
	decode(nvl(text_base_attribute47,x_old_attr.text_base_attribute47),'#DEL',null,text_base_attribute47),
	decode(nvl(text_base_attribute48,x_old_attr.text_base_attribute48),'#DEL',null,text_base_attribute48),
	decode(nvl(text_base_attribute49,x_old_attr.text_base_attribute49),'#DEL',null,text_base_attribute49),
	decode(nvl(text_base_attribute50,x_old_attr.text_base_attribute50),'#DEL',null,text_base_attribute50),
	decode(nvl(text_base_attribute51,x_old_attr.text_base_attribute51),'#DEL',null,text_base_attribute51),
	decode(nvl(text_base_attribute52,x_old_attr.text_base_attribute52),'#DEL',null,text_base_attribute52),
	decode(nvl(text_base_attribute53,x_old_attr.text_base_attribute53),'#DEL',null,text_base_attribute53),
	decode(nvl(text_base_attribute54,x_old_attr.text_base_attribute54),'#DEL',null,text_base_attribute54),
	decode(nvl(text_base_attribute55,x_old_attr.text_base_attribute55),'#DEL',null,text_base_attribute55),
	decode(nvl(text_base_attribute56,x_old_attr.text_base_attribute56),'#DEL',null,text_base_attribute56),
	decode(nvl(text_base_attribute57,x_old_attr.text_base_attribute57),'#DEL',null,text_base_attribute57),
	decode(nvl(text_base_attribute58,x_old_attr.text_base_attribute58),'#DEL',null,text_base_attribute58),
	decode(nvl(text_base_attribute59,x_old_attr.text_base_attribute59),'#DEL',null,text_base_attribute59),
	decode(nvl(text_base_attribute60,x_old_attr.text_base_attribute60),'#DEL',null,text_base_attribute60),
	decode(nvl(text_base_attribute61,x_old_attr.text_base_attribute61),'#DEL',null,text_base_attribute61),
	decode(nvl(text_base_attribute62,x_old_attr.text_base_attribute62),'#DEL',null,text_base_attribute62),
	decode(nvl(text_base_attribute63,x_old_attr.text_base_attribute63),'#DEL',null,text_base_attribute63),
	decode(nvl(text_base_attribute64,x_old_attr.text_base_attribute64),'#DEL',null,text_base_attribute64),
	decode(nvl(text_base_attribute65,x_old_attr.text_base_attribute65),'#DEL',null,text_base_attribute65),
	decode(nvl(text_base_attribute66,x_old_attr.text_base_attribute66),'#DEL',null,text_base_attribute66),
	decode(nvl(text_base_attribute67,x_old_attr.text_base_attribute67),'#DEL',null,text_base_attribute67),
	decode(nvl(text_base_attribute68,x_old_attr.text_base_attribute68),'#DEL',null,text_base_attribute68),
	decode(nvl(text_base_attribute69,x_old_attr.text_base_attribute69),'#DEL',null,text_base_attribute69),
	decode(nvl(text_base_attribute70,x_old_attr.text_base_attribute70),'#DEL',null,text_base_attribute70),
	decode(nvl(text_base_attribute71,x_old_attr.text_base_attribute71),'#DEL',null,text_base_attribute71),
	decode(nvl(text_base_attribute72,x_old_attr.text_base_attribute72),'#DEL',null,text_base_attribute72),
	decode(nvl(text_base_attribute73,x_old_attr.text_base_attribute73),'#DEL',null,text_base_attribute73),
	decode(nvl(text_base_attribute74,x_old_attr.text_base_attribute74),'#DEL',null,text_base_attribute74),
	decode(nvl(text_base_attribute75,x_old_attr.text_base_attribute75),'#DEL',null,text_base_attribute75),
	decode(nvl(text_base_attribute76,x_old_attr.text_base_attribute76),'#DEL',null,text_base_attribute76),
	decode(nvl(text_base_attribute77,x_old_attr.text_base_attribute77),'#DEL',null,text_base_attribute77),
	decode(nvl(text_base_attribute78,x_old_attr.text_base_attribute78),'#DEL',null,text_base_attribute78),
	decode(nvl(text_base_attribute79,x_old_attr.text_base_attribute79),'#DEL',null,text_base_attribute79),
	decode(nvl(text_base_attribute80,x_old_attr.text_base_attribute80),'#DEL',null,text_base_attribute80),
	decode(nvl(text_base_attribute81,x_old_attr.text_base_attribute81),'#DEL',null,text_base_attribute81),
	decode(nvl(text_base_attribute82,x_old_attr.text_base_attribute82),'#DEL',null,text_base_attribute82),
	decode(nvl(text_base_attribute83,x_old_attr.text_base_attribute83),'#DEL',null,text_base_attribute83),
	decode(nvl(text_base_attribute84,x_old_attr.text_base_attribute84),'#DEL',null,text_base_attribute84),
	decode(nvl(text_base_attribute85,x_old_attr.text_base_attribute85),'#DEL',null,text_base_attribute85),
	decode(nvl(text_base_attribute86,x_old_attr.text_base_attribute86),'#DEL',null,text_base_attribute86),
	decode(nvl(text_base_attribute87,x_old_attr.text_base_attribute87),'#DEL',null,text_base_attribute87),
	decode(nvl(text_base_attribute88,x_old_attr.text_base_attribute88),'#DEL',null,text_base_attribute88),
	decode(nvl(text_base_attribute89,x_old_attr.text_base_attribute89),'#DEL',null,text_base_attribute89),
	decode(nvl(text_base_attribute90,x_old_attr.text_base_attribute90),'#DEL',null,text_base_attribute90),
	decode(nvl(text_base_attribute91,x_old_attr.text_base_attribute91),'#DEL',null,text_base_attribute91),
	decode(nvl(text_base_attribute92,x_old_attr.text_base_attribute92),'#DEL',null,text_base_attribute92),
	decode(nvl(text_base_attribute93,x_old_attr.text_base_attribute93),'#DEL',null,text_base_attribute93),
	decode(nvl(text_base_attribute94,x_old_attr.text_base_attribute94),'#DEL',null,text_base_attribute94),
	decode(nvl(text_base_attribute95,x_old_attr.text_base_attribute95),'#DEL',null,text_base_attribute95),
	decode(nvl(text_base_attribute96,x_old_attr.text_base_attribute96),'#DEL',null,text_base_attribute96),
	decode(nvl(text_base_attribute97,x_old_attr.text_base_attribute97),'#DEL',null,text_base_attribute97),
	decode(nvl(text_base_attribute98,x_old_attr.text_base_attribute98),'#DEL',null,text_base_attribute98),
	decode(nvl(text_base_attribute99,x_old_attr.text_base_attribute99),'#DEL',null,text_base_attribute99),
	decode(nvl(text_base_attribute100,x_old_attr.text_base_attribute100),'#DEL',null,text_base_attribute100),
	decode(nvl(num_base_attribute1,x_old_attr.num_base_attribute1),'#DEL',null,num_base_attribute1),
	decode(nvl(num_base_attribute2,x_old_attr.num_base_attribute2),'#DEL',null,num_base_attribute2),
	decode(nvl(num_base_attribute3,x_old_attr.num_base_attribute3),'#DEL',null,num_base_attribute3),
	decode(nvl(num_base_attribute4,x_old_attr.num_base_attribute4),'#DEL',null,num_base_attribute4),
	decode(nvl(num_base_attribute5,x_old_attr.num_base_attribute5),'#DEL',null,num_base_attribute5),
	decode(nvl(num_base_attribute6,x_old_attr.num_base_attribute6),'#DEL',null,num_base_attribute6),
	decode(nvl(num_base_attribute7,x_old_attr.num_base_attribute7),'#DEL',null,num_base_attribute7),
	decode(nvl(num_base_attribute8,x_old_attr.num_base_attribute8),'#DEL',null,num_base_attribute8),
	decode(nvl(num_base_attribute9,x_old_attr.num_base_attribute9),'#DEL',null,num_base_attribute9),
	decode(nvl(num_base_attribute10, x_old_attr.num_base_attribute10),'#DEL',null,num_base_attribute10),
	decode(nvl(num_base_attribute11, x_old_attr.num_base_attribute11),'#DEL',null,num_base_attribute11),
	decode(nvl(num_base_attribute12, x_old_attr.num_base_attribute12),'#DEL',null,num_base_attribute12),
	decode(nvl(num_base_attribute13, x_old_attr.num_base_attribute13),'#DEL',null,num_base_attribute13),
	decode(nvl(num_base_attribute14, x_old_attr.num_base_attribute14),'#DEL',null,num_base_attribute14),
	decode(nvl(num_base_attribute15, x_old_attr.num_base_attribute15),'#DEL',null,num_base_attribute15),
	decode(nvl(num_base_attribute16, x_old_attr.num_base_attribute16),'#DEL',null,num_base_attribute16),
	decode(nvl(num_base_attribute17, x_old_attr.num_base_attribute17),'#DEL',null,num_base_attribute17),
	decode(nvl(num_base_attribute18, x_old_attr.num_base_attribute18),'#DEL',null,num_base_attribute18),
	decode(nvl(num_base_attribute19, x_old_attr.num_base_attribute19),'#DEL',null,num_base_attribute19),
	decode(nvl(num_base_attribute20, x_old_attr.num_base_attribute20),'#DEL',null,num_base_attribute20),
	decode(nvl(num_base_attribute21, x_old_attr.num_base_attribute21),'#DEL',null,num_base_attribute21),
	decode(nvl(num_base_attribute22, x_old_attr.num_base_attribute22),'#DEL',null,num_base_attribute22),
	decode(nvl(num_base_attribute23, x_old_attr.num_base_attribute23),'#DEL',null,num_base_attribute23),
	decode(nvl(num_base_attribute24, x_old_attr.num_base_attribute24),'#DEL',null,num_base_attribute24),
	decode(nvl(num_base_attribute25, x_old_attr.num_base_attribute25),'#DEL',null,num_base_attribute25),
	decode(nvl(num_base_attribute26, x_old_attr.num_base_attribute26),'#DEL',null,num_base_attribute26),
	decode(nvl(num_base_attribute27, x_old_attr.num_base_attribute27),'#DEL',null,num_base_attribute27),
	decode(nvl(num_base_attribute28, x_old_attr.num_base_attribute28),'#DEL',null,num_base_attribute28),
	decode(nvl(num_base_attribute29, x_old_attr.num_base_attribute29),'#DEL',null,num_base_attribute29),
	decode(nvl(num_base_attribute30, x_old_attr.num_base_attribute30),'#DEL',null,num_base_attribute30),
	decode(nvl(num_base_attribute31, x_old_attr.num_base_attribute31),'#DEL',null,num_base_attribute31),
	decode(nvl(num_base_attribute32, x_old_attr.num_base_attribute32),'#DEL',null,num_base_attribute32),
	decode(nvl(num_base_attribute33, x_old_attr.num_base_attribute33),'#DEL',null,num_base_attribute33),
	decode(nvl(num_base_attribute34, x_old_attr.num_base_attribute34),'#DEL',null,num_base_attribute34),
	decode(nvl(num_base_attribute35, x_old_attr.num_base_attribute35),'#DEL',null,num_base_attribute35),
	decode(nvl(num_base_attribute36, x_old_attr.num_base_attribute36),'#DEL',null,num_base_attribute36),
	decode(nvl(num_base_attribute37, x_old_attr.num_base_attribute37),'#DEL',null,num_base_attribute37),
	decode(nvl(num_base_attribute38, x_old_attr.num_base_attribute38),'#DEL',null,num_base_attribute38),
	decode(nvl(num_base_attribute39, x_old_attr.num_base_attribute39),'#DEL',null,num_base_attribute39),
	decode(nvl(num_base_attribute40, x_old_attr.num_base_attribute40),'#DEL',null,num_base_attribute40),
	decode(nvl(num_base_attribute41, x_old_attr.num_base_attribute41),'#DEL',null,num_base_attribute41),
	decode(nvl(num_base_attribute42, x_old_attr.num_base_attribute42),'#DEL',null,num_base_attribute42),
	decode(nvl(num_base_attribute43, x_old_attr.num_base_attribute43),'#DEL',null,num_base_attribute43),
	decode(nvl(num_base_attribute44, x_old_attr.num_base_attribute44),'#DEL',null,num_base_attribute44),
	decode(nvl(num_base_attribute45, x_old_attr.num_base_attribute45),'#DEL',null,num_base_attribute45),
	decode(nvl(num_base_attribute46, x_old_attr.num_base_attribute46),'#DEL',null,num_base_attribute46),
	decode(nvl(num_base_attribute47, x_old_attr.num_base_attribute47),'#DEL',null,num_base_attribute47),
	decode(nvl(num_base_attribute48, x_old_attr.num_base_attribute48),'#DEL',null,num_base_attribute48),
	decode(nvl(num_base_attribute49, x_old_attr.num_base_attribute49),'#DEL',null,num_base_attribute49),
	decode(nvl(num_base_attribute50, x_old_attr.num_base_attribute50),'#DEL',null,num_base_attribute50),
	decode(nvl(num_base_attribute51, x_old_attr.num_base_attribute51),'#DEL',null,num_base_attribute51),
	decode(nvl(num_base_attribute52, x_old_attr.num_base_attribute52),'#DEL',null,num_base_attribute52),
	decode(nvl(num_base_attribute53, x_old_attr.num_base_attribute53),'#DEL',null,num_base_attribute53),
	decode(nvl(num_base_attribute54, x_old_attr.num_base_attribute54),'#DEL',null,num_base_attribute54),
	decode(nvl(num_base_attribute55, x_old_attr.num_base_attribute55),'#DEL',null,num_base_attribute55),
	decode(nvl(num_base_attribute56, x_old_attr.num_base_attribute56),'#DEL',null,num_base_attribute56),
	decode(nvl(num_base_attribute57, x_old_attr.num_base_attribute57),'#DEL',null,num_base_attribute57),
	decode(nvl(num_base_attribute58, x_old_attr.num_base_attribute58),'#DEL',null,num_base_attribute58),
	decode(nvl(num_base_attribute59, x_old_attr.num_base_attribute59),'#DEL',null,num_base_attribute59),
	decode(nvl(num_base_attribute60, x_old_attr.num_base_attribute60),'#DEL',null,num_base_attribute60),
	decode(nvl(num_base_attribute61, x_old_attr.num_base_attribute61),'#DEL',null,num_base_attribute61),
	decode(nvl(num_base_attribute62, x_old_attr.num_base_attribute62),'#DEL',null,num_base_attribute62),
	decode(nvl(num_base_attribute63, x_old_attr.num_base_attribute63),'#DEL',null,num_base_attribute63),
	decode(nvl(num_base_attribute64, x_old_attr.num_base_attribute64),'#DEL',null,num_base_attribute64),
	decode(nvl(num_base_attribute65, x_old_attr.num_base_attribute65),'#DEL',null,num_base_attribute65),
	decode(nvl(num_base_attribute66, x_old_attr.num_base_attribute66),'#DEL',null,num_base_attribute66),
	decode(nvl(num_base_attribute67, x_old_attr.num_base_attribute67),'#DEL',null,num_base_attribute67),
	decode(nvl(num_base_attribute68, x_old_attr.num_base_attribute68),'#DEL',null,num_base_attribute68),
	decode(nvl(num_base_attribute69, x_old_attr.num_base_attribute69),'#DEL',null,num_base_attribute69),
	decode(nvl(num_base_attribute70, x_old_attr.num_base_attribute70),'#DEL',null,num_base_attribute70),
	decode(nvl(num_base_attribute71, x_old_attr.num_base_attribute71),'#DEL',null,num_base_attribute71),
	decode(nvl(num_base_attribute72, x_old_attr.num_base_attribute72),'#DEL',null,num_base_attribute72),
	decode(nvl(num_base_attribute73, x_old_attr.num_base_attribute73),'#DEL',null,num_base_attribute73),
	decode(nvl(num_base_attribute74, x_old_attr.num_base_attribute74),'#DEL',null,num_base_attribute74),
	decode(nvl(num_base_attribute75, x_old_attr.num_base_attribute75),'#DEL',null,num_base_attribute75),
	decode(nvl(num_base_attribute76, x_old_attr.num_base_attribute76),'#DEL',null,num_base_attribute76),
	decode(nvl(num_base_attribute77, x_old_attr.num_base_attribute77),'#DEL',null,num_base_attribute77),
	decode(nvl(num_base_attribute78, x_old_attr.num_base_attribute78),'#DEL',null,num_base_attribute78),
	decode(nvl(num_base_attribute79, x_old_attr.num_base_attribute79),'#DEL',null,num_base_attribute79),
	decode(nvl(num_base_attribute80, x_old_attr.num_base_attribute80),'#DEL',null,num_base_attribute80),
	decode(nvl(num_base_attribute81, x_old_attr.num_base_attribute81),'#DEL',null,num_base_attribute81),
	decode(nvl(num_base_attribute82, x_old_attr.num_base_attribute82),'#DEL',null,num_base_attribute82),
	decode(nvl(num_base_attribute83, x_old_attr.num_base_attribute83),'#DEL',null,num_base_attribute83),
	decode(nvl(num_base_attribute84, x_old_attr.num_base_attribute84),'#DEL',null,num_base_attribute84),
	decode(nvl(num_base_attribute85, x_old_attr.num_base_attribute85),'#DEL',null,num_base_attribute85),
	decode(nvl(num_base_attribute86, x_old_attr.num_base_attribute86),'#DEL',null,num_base_attribute86),
	decode(nvl(num_base_attribute87, x_old_attr.num_base_attribute87),'#DEL',null,num_base_attribute87),
	decode(nvl(num_base_attribute88, x_old_attr.num_base_attribute88),'#DEL',null,num_base_attribute88),
	decode(nvl(num_base_attribute89, x_old_attr.num_base_attribute89),'#DEL',null,num_base_attribute89),
	decode(nvl(num_base_attribute90, x_old_attr.num_base_attribute90),'#DEL',null,num_base_attribute90),
	decode(nvl(num_base_attribute91, x_old_attr.num_base_attribute91),'#DEL',null,num_base_attribute91),
	decode(nvl(num_base_attribute92, x_old_attr.num_base_attribute92),'#DEL',null,num_base_attribute92),
	decode(nvl(num_base_attribute93, x_old_attr.num_base_attribute93),'#DEL',null,num_base_attribute93),
	decode(nvl(num_base_attribute94, x_old_attr.num_base_attribute94),'#DEL',null,num_base_attribute94),
	decode(nvl(num_base_attribute95, x_old_attr.num_base_attribute95),'#DEL',null,num_base_attribute95),
	decode(nvl(num_base_attribute96, x_old_attr.num_base_attribute96),'#DEL',null,num_base_attribute96),
	decode(nvl(num_base_attribute97, x_old_attr.num_base_attribute97),'#DEL',null,num_base_attribute97),
	decode(nvl(num_base_attribute98, x_old_attr.num_base_attribute98),'#DEL',null,num_base_attribute98),
	decode(nvl(num_base_attribute99, x_old_attr.num_base_attribute99),'#DEL',null,num_base_attribute99),
	decode(nvl(num_base_attribute100,x_old_attr.num_base_attribute100),'#DEL',null,num_base_attribute100),
	decode(nvl(text_cat_attribute1,x_old_attr.text_cat_attribute1),'#DEL',null,text_cat_attribute1),
	decode(nvl(text_cat_attribute2,x_old_attr.text_cat_attribute2),'#DEL',null,text_cat_attribute2),
	decode(nvl(text_cat_attribute3,x_old_attr.text_cat_attribute3),'#DEL',null,text_cat_attribute3),
	decode(nvl(text_cat_attribute4,x_old_attr.text_cat_attribute4),'#DEL',null,text_cat_attribute4),
	decode(nvl(text_cat_attribute5,x_old_attr.text_cat_attribute5),'#DEL',null,text_cat_attribute5),
	decode(nvl(text_cat_attribute6,x_old_attr.text_cat_attribute6),'#DEL',null,text_cat_attribute6),
	decode(nvl(text_cat_attribute7,x_old_attr.text_cat_attribute7),'#DEL',null,text_cat_attribute7),
	decode(nvl(text_cat_attribute8,x_old_attr.text_cat_attribute8),'#DEL',null,text_cat_attribute8),
	decode(nvl(text_cat_attribute9,x_old_attr.text_cat_attribute9),'#DEL',null,text_cat_attribute9),
	decode(nvl(text_cat_attribute10, x_old_attr.text_cat_attribute10),'#DEL',null,text_cat_attribute10),
	decode(nvl(text_cat_attribute11, x_old_attr.text_cat_attribute11),'#DEL',null,text_cat_attribute11),
	decode(nvl(text_cat_attribute12, x_old_attr.text_cat_attribute12),'#DEL',null,text_cat_attribute12),
	decode(nvl(text_cat_attribute13, x_old_attr.text_cat_attribute13),'#DEL',null,text_cat_attribute13),
	decode(nvl(text_cat_attribute14, x_old_attr.text_cat_attribute14),'#DEL',null,text_cat_attribute14),
	decode(nvl(text_cat_attribute15, x_old_attr.text_cat_attribute15),'#DEL',null,text_cat_attribute15),
	decode(nvl(text_cat_attribute16, x_old_attr.text_cat_attribute16),'#DEL',null,text_cat_attribute16),
	decode(nvl(text_cat_attribute17, x_old_attr.text_cat_attribute17),'#DEL',null,text_cat_attribute17),
	decode(nvl(text_cat_attribute18, x_old_attr.text_cat_attribute18),'#DEL',null,text_cat_attribute18),
	decode(nvl(text_cat_attribute19, x_old_attr.text_cat_attribute19),'#DEL',null,text_cat_attribute19),
	decode(nvl(text_cat_attribute20, x_old_attr.text_cat_attribute20),'#DEL',null,text_cat_attribute20),
	decode(nvl(text_cat_attribute21, x_old_attr.text_cat_attribute21),'#DEL',null,text_cat_attribute21),
	decode(nvl(text_cat_attribute22, x_old_attr.text_cat_attribute22),'#DEL',null,text_cat_attribute22),
	decode(nvl(text_cat_attribute23, x_old_attr.text_cat_attribute23),'#DEL',null,text_cat_attribute23),
	decode(nvl(text_cat_attribute24, x_old_attr.text_cat_attribute24),'#DEL',null,text_cat_attribute24),
	decode(nvl(text_cat_attribute25, x_old_attr.text_cat_attribute25),'#DEL',null,text_cat_attribute25),
	decode(nvl(text_cat_attribute26, x_old_attr.text_cat_attribute26),'#DEL',null,text_cat_attribute26),
	decode(nvl(text_cat_attribute27, x_old_attr.text_cat_attribute27),'#DEL',null,text_cat_attribute27),
	decode(nvl(text_cat_attribute28, x_old_attr.text_cat_attribute28),'#DEL',null,text_cat_attribute28),
	decode(nvl(text_cat_attribute29, x_old_attr.text_cat_attribute29),'#DEL',null,text_cat_attribute29),
	decode(nvl(text_cat_attribute30, x_old_attr.text_cat_attribute30),'#DEL',null,text_cat_attribute30),
	decode(nvl(text_cat_attribute31, x_old_attr.text_cat_attribute31),'#DEL',null,text_cat_attribute31),
	decode(nvl(text_cat_attribute32, x_old_attr.text_cat_attribute32),'#DEL',null,text_cat_attribute32),
	decode(nvl(text_cat_attribute33, x_old_attr.text_cat_attribute33),'#DEL',null,text_cat_attribute33),
	decode(nvl(text_cat_attribute34, x_old_attr.text_cat_attribute34),'#DEL',null,text_cat_attribute34),
	decode(nvl(text_cat_attribute35, x_old_attr.text_cat_attribute35),'#DEL',null,text_cat_attribute35),
	decode(nvl(text_cat_attribute36, x_old_attr.text_cat_attribute36),'#DEL',null,text_cat_attribute36),
	decode(nvl(text_cat_attribute37, x_old_attr.text_cat_attribute37),'#DEL',null,text_cat_attribute37),
	decode(nvl(text_cat_attribute38, x_old_attr.text_cat_attribute38),'#DEL',null,text_cat_attribute38),
	decode(nvl(text_cat_attribute39, x_old_attr.text_cat_attribute39),'#DEL',null,text_cat_attribute39),
	decode(nvl(text_cat_attribute40, x_old_attr.text_cat_attribute40),'#DEL',null,text_cat_attribute40),
	decode(nvl(text_cat_attribute41, x_old_attr.text_cat_attribute41),'#DEL',null,text_cat_attribute41),
	decode(nvl(text_cat_attribute42, x_old_attr.text_cat_attribute42),'#DEL',null,text_cat_attribute42),
	decode(nvl(text_cat_attribute43, x_old_attr.text_cat_attribute43),'#DEL',null,text_cat_attribute43),
	decode(nvl(text_cat_attribute44, x_old_attr.text_cat_attribute44),'#DEL',null,text_cat_attribute44),
	decode(nvl(text_cat_attribute45, x_old_attr.text_cat_attribute45),'#DEL',null,text_cat_attribute45),
	decode(nvl(text_cat_attribute46, x_old_attr.text_cat_attribute46),'#DEL',null,text_cat_attribute46),
	decode(nvl(text_cat_attribute47, x_old_attr.text_cat_attribute47),'#DEL',null,text_cat_attribute47),
	decode(nvl(text_cat_attribute48, x_old_attr.text_cat_attribute48),'#DEL',null,text_cat_attribute48),
	decode(nvl(text_cat_attribute49, x_old_attr.text_cat_attribute49),'#DEL',null,text_cat_attribute49),
	decode(nvl(text_cat_attribute50, x_old_attr.text_cat_attribute50),'#DEL',null,text_cat_attribute50),
	decode(nvl(num_cat_attribute1,x_old_attr.num_cat_attribute1),'#DEL',null,num_cat_attribute1),
	decode(nvl(num_cat_attribute2,x_old_attr.num_cat_attribute2),'#DEL',null,num_cat_attribute2),
	decode(nvl(num_cat_attribute3,x_old_attr.num_cat_attribute3),'#DEL',null,num_cat_attribute3),
	decode(nvl(num_cat_attribute4,x_old_attr.num_cat_attribute4),'#DEL',null,num_cat_attribute4),
	decode(nvl(num_cat_attribute5,x_old_attr.num_cat_attribute5),'#DEL',null,num_cat_attribute5),
	decode(nvl(num_cat_attribute6,x_old_attr.num_cat_attribute6),'#DEL',null,num_cat_attribute6),
	decode(nvl(num_cat_attribute7,x_old_attr.num_cat_attribute7),'#DEL',null,num_cat_attribute7),
	decode(nvl(num_cat_attribute8,x_old_attr.num_cat_attribute8),'#DEL',null,num_cat_attribute8),
	decode(nvl(num_cat_attribute9,x_old_attr.num_cat_attribute9),'#DEL',null,num_cat_attribute9),
	decode(nvl(num_cat_attribute10,x_old_attr.num_cat_attribute10),'#DEL',null,num_cat_attribute10),
	decode(nvl(num_cat_attribute11,x_old_attr.num_cat_attribute11),'#DEL',null,num_cat_attribute11),
	decode(nvl(num_cat_attribute12,x_old_attr.num_cat_attribute12),'#DEL',null,num_cat_attribute12),
	decode(nvl(num_cat_attribute13,x_old_attr.num_cat_attribute13),'#DEL',null,num_cat_attribute13),
	decode(nvl(num_cat_attribute14,x_old_attr.num_cat_attribute14),'#DEL',null,num_cat_attribute14),
	decode(nvl(num_cat_attribute15,x_old_attr.num_cat_attribute15),'#DEL',null,num_cat_attribute15),
	decode(nvl(num_cat_attribute16,x_old_attr.num_cat_attribute16),'#DEL',null,num_cat_attribute16),
	decode(nvl(num_cat_attribute17,x_old_attr.num_cat_attribute17),'#DEL',null,num_cat_attribute17),
	decode(nvl(num_cat_attribute18,x_old_attr.num_cat_attribute18),'#DEL',null,num_cat_attribute18),
	decode(nvl(num_cat_attribute19,x_old_attr.num_cat_attribute19),'#DEL',null,num_cat_attribute19),
	decode(nvl(num_cat_attribute20,x_old_attr.num_cat_attribute20),'#DEL',null,num_cat_attribute20),
	decode(nvl(num_cat_attribute21,x_old_attr.num_cat_attribute21),'#DEL',null,num_cat_attribute21),
	decode(nvl(num_cat_attribute22,x_old_attr.num_cat_attribute22),'#DEL',null,num_cat_attribute22),
	decode(nvl(num_cat_attribute23,x_old_attr.num_cat_attribute23),'#DEL',null,num_cat_attribute23),
	decode(nvl(num_cat_attribute24,x_old_attr.num_cat_attribute24),'#DEL',null,num_cat_attribute24),
	decode(nvl(num_cat_attribute25,x_old_attr.num_cat_attribute25),'#DEL',null,num_cat_attribute25),
	decode(nvl(num_cat_attribute26,x_old_attr.num_cat_attribute26),'#DEL',null,num_cat_attribute26),
	decode(nvl(num_cat_attribute27,x_old_attr.num_cat_attribute27),'#DEL',null,num_cat_attribute27),
	decode(nvl(num_cat_attribute28,x_old_attr.num_cat_attribute28),'#DEL',null,num_cat_attribute28),
	decode(nvl(num_cat_attribute29,x_old_attr.num_cat_attribute29),'#DEL',null,num_cat_attribute29),
	decode(nvl(num_cat_attribute30,x_old_attr.num_cat_attribute30),'#DEL',null,num_cat_attribute30),
	decode(nvl(num_cat_attribute31,x_old_attr.num_cat_attribute31),'#DEL',null,num_cat_attribute31),
	decode(nvl(num_cat_attribute32,x_old_attr.num_cat_attribute32),'#DEL',null,num_cat_attribute32),
	decode(nvl(num_cat_attribute33,x_old_attr.num_cat_attribute33),'#DEL',null,num_cat_attribute33),
	decode(nvl(num_cat_attribute34,x_old_attr.num_cat_attribute34),'#DEL',null,num_cat_attribute34),
	decode(nvl(num_cat_attribute35,x_old_attr.num_cat_attribute35),'#DEL',null,num_cat_attribute35),
	decode(nvl(num_cat_attribute36,x_old_attr.num_cat_attribute36),'#DEL',null,num_cat_attribute36),
	decode(nvl(num_cat_attribute37,x_old_attr.num_cat_attribute37),'#DEL',null,num_cat_attribute37),
	decode(nvl(num_cat_attribute38,x_old_attr.num_cat_attribute38),'#DEL',null,num_cat_attribute38),
	decode(nvl(num_cat_attribute39,x_old_attr.num_cat_attribute39),'#DEL',null,num_cat_attribute39),
	decode(nvl(num_cat_attribute40,x_old_attr.num_cat_attribute40),'#DEL',null,num_cat_attribute40),
	decode(nvl(num_cat_attribute41,x_old_attr.num_cat_attribute41),'#DEL',null,num_cat_attribute41),
	decode(nvl(num_cat_attribute42,x_old_attr.num_cat_attribute42),'#DEL',null,num_cat_attribute42),
	decode(nvl(num_cat_attribute43,x_old_attr.num_cat_attribute43),'#DEL',null,num_cat_attribute43),
	decode(nvl(num_cat_attribute44,x_old_attr.num_cat_attribute44),'#DEL',null,num_cat_attribute44),
	decode(nvl(num_cat_attribute45,x_old_attr.num_cat_attribute45),'#DEL',null,num_cat_attribute45),
	decode(nvl(num_cat_attribute46,x_old_attr.num_cat_attribute46),'#DEL',null,num_cat_attribute46),
	decode(nvl(num_cat_attribute47,x_old_attr.num_cat_attribute47),'#DEL',null,num_cat_attribute47),
	decode(nvl(num_cat_attribute48,x_old_attr.num_cat_attribute48),'#DEL',null,num_cat_attribute48),
	decode(nvl(num_cat_attribute49,x_old_attr.num_cat_attribute49),'#DEL',null,num_cat_attribute49),
	decode(nvl(num_cat_attribute50,x_old_attr.num_cat_attribute50),'#DEL',null,num_cat_attribute50),
	decode(nvl(last_update_login, x_old_attr.last_update_login),'#DEL',null,last_update_login),
	nvl(last_updated_by,x_old_attr.last_updated_by),
	sysdate,
	x_old_attr.created_by,
	x_old_attr.creation_date,
	decode(nvl(request_id,x_old_attr.request_id),'#DEL',null,request_id),
	decode(nvl(program_application_id,x_old_attr.program_application_id),'#DEL',null,program_application_id),
	decode(nvl(program_id,x_old_attr.program_id),'#DEL',null,program_id),
	sysdate
	from PO_ATTR_VALUES_INTERFACE
	where
	interface_line_id = p_line_id_tbl(i) AND
  interface_header_id = p_header_id_tbl(i);

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'New Item Data Inserted');
     END IF;

     ELSE

	insert into ICX_CAT_PCH_ITEM_ATTRS(
	punchout_item_id,
	attribute_values_id,
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
	program_update_date)
	select			-- values
	p_item_id_tbl(i),
	ICX_PCH_CAT_ATTR_SEQ.NEXTVAL,
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
	nvl(last_updated_by, -1),
	sysdate,
	nvl(created_by, -1),
	sysdate,
	request_id,
	program_application_id,
	program_id,
	sysdate
	FROM PO_ATTR_VALUES_INTERFACE
  where
	interface_line_id = p_line_id_tbl(i) AND
  interface_header_id = p_header_id_tbl(i);


     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'New Item Created');
     END IF;

     END IF;

       l_acc_intf_line_id_tbl.EXTEND;
       l_acc_intf_line_id_tbl(l_acc_intf_line_id_tbl.COUNT) := p_line_id_tbl(i);

       l_acc_intf_header_id_tbl.EXTEND;
       l_acc_intf_header_id_tbl(l_acc_intf_header_id_tbl.COUNT) := p_header_id_tbl(i);


     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, i || '. Completed Item ID: '|| p_item_id_tbl(i));
     END IF;

   END LOOP;

     d_position := 40;

   	update_attr_values_intf
       (p_h_id_tbl => l_acc_intf_header_id_tbl,
       p_l_id_tbl => l_acc_intf_line_id_tbl,
       p_process_code => g_PROCESS_CODE_ACCEPTED);

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'Attr Values Updation Complete');
     END IF;

       d_position := 50;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'End sync_attr_values_intf');
   END IF;

 EXCEPTION
 WHEN OTHERS THEN
   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Exception at sync_attr_values_intf');
   END IF;
   RAISE;
 END sync_attr_values_intf;

-----------------------------------------------------------------------
 --Start of Comments
 --Name: sync_attr_values_tlp_intf
 --Function:
 --  For all ids passed in, sync the corresponding records for attr values tlp table
 --  interface
 --Parameters:
 --IN:
 --p_line_id_tbl
 --  Table of line ids
 --p_header_id_tbl
 --  Table of header ids
 --p_item_id_tbl
 --  Table of item ids
 --IN OUT:
 --OUT:
 --End of Comments
 ------------------------------------------------------------------------
 PROCEDURE sync_attr_values_tlp_intf(
   p_line_id_tbl IN PO_TBL_NUMBER,
   p_header_id_tbl IN PO_TBL_NUMBER,
   p_item_id_tbl IN PO_TBL_NUMBER,
   p_item_lang_tbl IN PO_TBL_VARCHAR5
 ) IS

 d_api_name CONSTANT VARCHAR2(30) := 'sync_attr_values_tlp_intf';
 d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
 d_position NUMBER;

 l_intf_line_id_tbl PO_TBL_NUMBER;
 l_intf_header_id_tbl PO_TBL_NUMBER;

   x_old_attr item_attr_tl_rec_type;

   x_count number;
   x_temp_item_id number;
   x_temp_attr_id number;
   x_creation_date date;
   x_created_by date;

   -- interface line id of lines that is accepted
   l_acc_intf_line_id_tbl   PO_TBL_NUMBER := PO_TBL_NUMBER();
   l_acc_intf_header_id_tbl   PO_TBL_NUMBER := PO_TBL_NUMBER();

   l_attr_lang_tbl PO_TBL_VARCHAR5;

 BEGIN
   d_position := 10;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Start sync_attr_values_tlp_intf');
   END IF;

   IF (p_line_id_tbl IS NULL OR p_line_id_tbl.COUNT = 0) THEN
     d_position := 20;
     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'Returning');
     END IF;
     RETURN;
   END IF;

    d_position := 30;

   FOR i IN 1..p_line_id_tbl.COUNT
   LOOP

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, i || '. Processing Item ID: '|| p_item_id_tbl(i));
     END IF;

     x_count := 0;
     select count(*) into x_count
	    from ICX_CAT_PCH_ITEM_ATTRS_TLP where
	    punchout_item_id = p_item_id_tbl(i);

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'Count: '|| x_count);
     END IF;

     IF (x_count > 0) THEN

	select language
        BULK COLLECT INTO l_attr_lang_tbl
        from PO_ATTR_VALUES_TLP_INTERFACE
	where
	interface_line_id = p_line_id_tbl(i) AND
        interface_header_id = p_header_id_tbl(i);

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'Languages collected from interface: ', l_attr_lang_tbl.COUNT);
     END IF;

        FOR j IN 1..l_attr_lang_tbl.COUNT
        LOOP

     select
	punchout_item_id,
	attribute_values_tlp_id,
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
	program_update_date
	into
	x_old_attr.punchout_item_id,
	x_old_attr.attribute_values_tlp_id,
	x_old_attr.org_id,
	x_old_attr.language,
	x_old_attr.description,
	x_old_attr.manufacturer,
	x_old_attr.comments,
	x_old_attr.alias,
	x_old_attr.long_description,
	x_old_attr.tl_text_base_attribute1,
	x_old_attr.tl_text_base_attribute2,
	x_old_attr.tl_text_base_attribute3,
	x_old_attr.tl_text_base_attribute4,
	x_old_attr.tl_text_base_attribute5,
	x_old_attr.tl_text_base_attribute6,
	x_old_attr.tl_text_base_attribute7,
	x_old_attr.tl_text_base_attribute8,
	x_old_attr.tl_text_base_attribute9,
	x_old_attr.tl_text_base_attribute10,
	x_old_attr.tl_text_base_attribute11,
	x_old_attr.tl_text_base_attribute12,
	x_old_attr.tl_text_base_attribute13,
	x_old_attr.tl_text_base_attribute14,
	x_old_attr.tl_text_base_attribute15,
	x_old_attr.tl_text_base_attribute16,
	x_old_attr.tl_text_base_attribute17,
	x_old_attr.tl_text_base_attribute18,
	x_old_attr.tl_text_base_attribute19,
	x_old_attr.tl_text_base_attribute20,
	x_old_attr.tl_text_base_attribute21,
	x_old_attr.tl_text_base_attribute22,
	x_old_attr.tl_text_base_attribute23,
	x_old_attr.tl_text_base_attribute24,
	x_old_attr.tl_text_base_attribute25,
	x_old_attr.tl_text_base_attribute26,
	x_old_attr.tl_text_base_attribute27,
	x_old_attr.tl_text_base_attribute28,
	x_old_attr.tl_text_base_attribute29,
	x_old_attr.tl_text_base_attribute30,
	x_old_attr.tl_text_base_attribute31,
	x_old_attr.tl_text_base_attribute32,
	x_old_attr.tl_text_base_attribute33,
	x_old_attr.tl_text_base_attribute34,
	x_old_attr.tl_text_base_attribute35,
	x_old_attr.tl_text_base_attribute36,
	x_old_attr.tl_text_base_attribute37,
	x_old_attr.tl_text_base_attribute38,
	x_old_attr.tl_text_base_attribute39,
	x_old_attr.tl_text_base_attribute40,
	x_old_attr.tl_text_base_attribute41,
	x_old_attr.tl_text_base_attribute42,
	x_old_attr.tl_text_base_attribute43,
	x_old_attr.tl_text_base_attribute44,
	x_old_attr.tl_text_base_attribute45,
	x_old_attr.tl_text_base_attribute46,
	x_old_attr.tl_text_base_attribute47,
	x_old_attr.tl_text_base_attribute48,
	x_old_attr.tl_text_base_attribute49,
	x_old_attr.tl_text_base_attribute50,
	x_old_attr.tl_text_base_attribute51,
	x_old_attr.tl_text_base_attribute52,
	x_old_attr.tl_text_base_attribute53,
	x_old_attr.tl_text_base_attribute54,
	x_old_attr.tl_text_base_attribute55,
	x_old_attr.tl_text_base_attribute56,
	x_old_attr.tl_text_base_attribute57,
	x_old_attr.tl_text_base_attribute58,
	x_old_attr.tl_text_base_attribute59,
	x_old_attr.tl_text_base_attribute60,
	x_old_attr.tl_text_base_attribute61,
	x_old_attr.tl_text_base_attribute62,
	x_old_attr.tl_text_base_attribute63,
	x_old_attr.tl_text_base_attribute64,
	x_old_attr.tl_text_base_attribute65,
	x_old_attr.tl_text_base_attribute66,
	x_old_attr.tl_text_base_attribute67,
	x_old_attr.tl_text_base_attribute68,
	x_old_attr.tl_text_base_attribute69,
	x_old_attr.tl_text_base_attribute70,
	x_old_attr.tl_text_base_attribute71,
	x_old_attr.tl_text_base_attribute72,
	x_old_attr.tl_text_base_attribute73,
	x_old_attr.tl_text_base_attribute74,
	x_old_attr.tl_text_base_attribute75,
	x_old_attr.tl_text_base_attribute76,
	x_old_attr.tl_text_base_attribute77,
	x_old_attr.tl_text_base_attribute78,
	x_old_attr.tl_text_base_attribute79,
	x_old_attr.tl_text_base_attribute80,
	x_old_attr.tl_text_base_attribute81,
	x_old_attr.tl_text_base_attribute82,
	x_old_attr.tl_text_base_attribute83,
	x_old_attr.tl_text_base_attribute84,
	x_old_attr.tl_text_base_attribute85,
	x_old_attr.tl_text_base_attribute86,
	x_old_attr.tl_text_base_attribute87,
	x_old_attr.tl_text_base_attribute88,
	x_old_attr.tl_text_base_attribute89,
	x_old_attr.tl_text_base_attribute90,
	x_old_attr.tl_text_base_attribute91,
	x_old_attr.tl_text_base_attribute92,
	x_old_attr.tl_text_base_attribute93,
	x_old_attr.tl_text_base_attribute94,
	x_old_attr.tl_text_base_attribute95,
	x_old_attr.tl_text_base_attribute96,
	x_old_attr.tl_text_base_attribute97,
	x_old_attr.tl_text_base_attribute98,
	x_old_attr.tl_text_base_attribute99,
	x_old_attr.tl_text_base_attribute100,
	x_old_attr.tl_text_cat_attribute1,
	x_old_attr.tl_text_cat_attribute2,
	x_old_attr.tl_text_cat_attribute3,
	x_old_attr.tl_text_cat_attribute4,
	x_old_attr.tl_text_cat_attribute5,
	x_old_attr.tl_text_cat_attribute6,
	x_old_attr.tl_text_cat_attribute7,
	x_old_attr.tl_text_cat_attribute8,
	x_old_attr.tl_text_cat_attribute9,
	x_old_attr.tl_text_cat_attribute10,
	x_old_attr.tl_text_cat_attribute11,
	x_old_attr.tl_text_cat_attribute12,
	x_old_attr.tl_text_cat_attribute13,
	x_old_attr.tl_text_cat_attribute14,
	x_old_attr.tl_text_cat_attribute15,
	x_old_attr.tl_text_cat_attribute16,
	x_old_attr.tl_text_cat_attribute17,
	x_old_attr.tl_text_cat_attribute18,
	x_old_attr.tl_text_cat_attribute19,
	x_old_attr.tl_text_cat_attribute20,
	x_old_attr.tl_text_cat_attribute21,
	x_old_attr.tl_text_cat_attribute22,
	x_old_attr.tl_text_cat_attribute23,
	x_old_attr.tl_text_cat_attribute24,
	x_old_attr.tl_text_cat_attribute25,
	x_old_attr.tl_text_cat_attribute26,
	x_old_attr.tl_text_cat_attribute27,
	x_old_attr.tl_text_cat_attribute28,
	x_old_attr.tl_text_cat_attribute29,
	x_old_attr.tl_text_cat_attribute30,
	x_old_attr.tl_text_cat_attribute31,
	x_old_attr.tl_text_cat_attribute32,
	x_old_attr.tl_text_cat_attribute33,
	x_old_attr.tl_text_cat_attribute34,
	x_old_attr.tl_text_cat_attribute35,
	x_old_attr.tl_text_cat_attribute36,
	x_old_attr.tl_text_cat_attribute37,
	x_old_attr.tl_text_cat_attribute38,
	x_old_attr.tl_text_cat_attribute39,
	x_old_attr.tl_text_cat_attribute40,
	x_old_attr.tl_text_cat_attribute41,
	x_old_attr.tl_text_cat_attribute42,
	x_old_attr.tl_text_cat_attribute43,
	x_old_attr.tl_text_cat_attribute44,
	x_old_attr.tl_text_cat_attribute45,
	x_old_attr.tl_text_cat_attribute46,
	x_old_attr.tl_text_cat_attribute47,
	x_old_attr.tl_text_cat_attribute48,
	x_old_attr.tl_text_cat_attribute49,
	x_old_attr.tl_text_cat_attribute50,
	x_old_attr.last_update_login,
	x_old_attr.last_updated_by,
	x_old_attr.last_update_date,
	x_old_attr.created_by,
	x_old_attr.creation_date,
	x_old_attr.request_id,
	x_old_attr.program_application_id,
	x_old_attr.program_id,
	x_old_attr.program_update_date
	from ICX_CAT_PCH_ITEM_ATTRS_TLP where
	punchout_item_id = p_item_id_tbl(i)
	AND language = l_attr_lang_tbl(j);

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'OLD Item Data Collected for Language: ' || l_attr_lang_tbl(j));
     END IF;

	delete
	ICX_CAT_PCH_ITEM_ATTRS_TLP where
	punchout_item_id = p_item_id_tbl(i)
	AND language = l_attr_lang_tbl(j);

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'Item Deleted for Language: ' || l_attr_lang_tbl(j));
     END IF;

	insert into ICX_CAT_PCH_ITEM_ATTRS_TLP(
	punchout_item_id,
	attribute_values_tlp_id,
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
	program_update_date
	)
	select 		--values
	x_old_attr.punchout_item_id,
	x_old_attr.attribute_values_tlp_id,
	decode(nvl(org_id,x_old_attr.org_id),'#DEL',null,org_id),
	l_attr_lang_tbl(j),
	decode(nvl(description,x_old_attr.description),'#DEL',null,description),
	decode(nvl(manufacturer,x_old_attr.manufacturer),'#DEL',null,manufacturer),
	decode(nvl(comments,x_old_attr.comments),'#DEL',null,comments),
	decode(nvl(alias,x_old_attr.alias),'#DEL',null,alias),
	decode(nvl(long_description,x_old_attr.long_description),'#DEL',null,long_description),
	decode(nvl(tl_text_base_attribute1,x_old_attr.tl_text_base_attribute1),'#DEL',null,tl_text_base_attribute1),
	decode(nvl(tl_text_base_attribute2,x_old_attr.tl_text_base_attribute2),'#DEL',null,tl_text_base_attribute2),
	decode(nvl(tl_text_base_attribute3,x_old_attr.tl_text_base_attribute3),'#DEL',null,tl_text_base_attribute3),
	decode(nvl(tl_text_base_attribute4,x_old_attr.tl_text_base_attribute4),'#DEL',null,tl_text_base_attribute4),
	decode(nvl(tl_text_base_attribute5,x_old_attr.tl_text_base_attribute5),'#DEL',null,tl_text_base_attribute5),
	decode(nvl(tl_text_base_attribute6,x_old_attr.tl_text_base_attribute6),'#DEL',null,tl_text_base_attribute6),
	decode(nvl(tl_text_base_attribute7,x_old_attr.tl_text_base_attribute7),'#DEL',null,tl_text_base_attribute7),
	decode(nvl(tl_text_base_attribute8,x_old_attr.tl_text_base_attribute8),'#DEL',null,tl_text_base_attribute8),
	decode(nvl(tl_text_base_attribute9,x_old_attr.tl_text_base_attribute9),'#DEL',null,tl_text_base_attribute9),
	decode(nvl(tl_text_base_attribute10,x_old_attr.tl_text_base_attribute10),'#DEL',null,tl_text_base_attribute10),
	decode(nvl(tl_text_base_attribute11,x_old_attr.tl_text_base_attribute11),'#DEL',null,tl_text_base_attribute11),
	decode(nvl(tl_text_base_attribute12,x_old_attr.tl_text_base_attribute12),'#DEL',null,tl_text_base_attribute12),
	decode(nvl(tl_text_base_attribute13,x_old_attr.tl_text_base_attribute13),'#DEL',null,tl_text_base_attribute13),
	decode(nvl(tl_text_base_attribute14,x_old_attr.tl_text_base_attribute14),'#DEL',null,tl_text_base_attribute14),
	decode(nvl(tl_text_base_attribute15,x_old_attr.tl_text_base_attribute15),'#DEL',null,tl_text_base_attribute15),
	decode(nvl(tl_text_base_attribute16,x_old_attr.tl_text_base_attribute16),'#DEL',null,tl_text_base_attribute16),
	decode(nvl(tl_text_base_attribute17,x_old_attr.tl_text_base_attribute17),'#DEL',null,tl_text_base_attribute17),
	decode(nvl(tl_text_base_attribute18,x_old_attr.tl_text_base_attribute18),'#DEL',null,tl_text_base_attribute18),
	decode(nvl(tl_text_base_attribute19,x_old_attr.tl_text_base_attribute19),'#DEL',null,tl_text_base_attribute19),
	decode(nvl(tl_text_base_attribute20,x_old_attr.tl_text_base_attribute20),'#DEL',null,tl_text_base_attribute20),
	decode(nvl(tl_text_base_attribute21,x_old_attr.tl_text_base_attribute21),'#DEL',null,tl_text_base_attribute21),
	decode(nvl(tl_text_base_attribute22,x_old_attr.tl_text_base_attribute22),'#DEL',null,tl_text_base_attribute22),
	decode(nvl(tl_text_base_attribute23,x_old_attr.tl_text_base_attribute23),'#DEL',null,tl_text_base_attribute23),
	decode(nvl(tl_text_base_attribute24,x_old_attr.tl_text_base_attribute24),'#DEL',null,tl_text_base_attribute24),
	decode(nvl(tl_text_base_attribute25,x_old_attr.tl_text_base_attribute25),'#DEL',null,tl_text_base_attribute25),
	decode(nvl(tl_text_base_attribute26,x_old_attr.tl_text_base_attribute26),'#DEL',null,tl_text_base_attribute26),
	decode(nvl(tl_text_base_attribute27,x_old_attr.tl_text_base_attribute27),'#DEL',null,tl_text_base_attribute27),
	decode(nvl(tl_text_base_attribute28,x_old_attr.tl_text_base_attribute28),'#DEL',null,tl_text_base_attribute28),
	decode(nvl(tl_text_base_attribute29,x_old_attr.tl_text_base_attribute29),'#DEL',null,tl_text_base_attribute29),
	decode(nvl(tl_text_base_attribute30,x_old_attr.tl_text_base_attribute30),'#DEL',null,tl_text_base_attribute30),
	decode(nvl(tl_text_base_attribute31,x_old_attr.tl_text_base_attribute31),'#DEL',null,tl_text_base_attribute31),
	decode(nvl(tl_text_base_attribute32,x_old_attr.tl_text_base_attribute32),'#DEL',null,tl_text_base_attribute32),
	decode(nvl(tl_text_base_attribute33,x_old_attr.tl_text_base_attribute33),'#DEL',null,tl_text_base_attribute33),
	decode(nvl(tl_text_base_attribute34,x_old_attr.tl_text_base_attribute34),'#DEL',null,tl_text_base_attribute34),
	decode(nvl(tl_text_base_attribute35,x_old_attr.tl_text_base_attribute35),'#DEL',null,tl_text_base_attribute35),
	decode(nvl(tl_text_base_attribute36,x_old_attr.tl_text_base_attribute36),'#DEL',null,tl_text_base_attribute36),
	decode(nvl(tl_text_base_attribute37,x_old_attr.tl_text_base_attribute37),'#DEL',null,tl_text_base_attribute37),
	decode(nvl(tl_text_base_attribute38,x_old_attr.tl_text_base_attribute38),'#DEL',null,tl_text_base_attribute38),
	decode(nvl(tl_text_base_attribute39,x_old_attr.tl_text_base_attribute39),'#DEL',null,tl_text_base_attribute39),
	decode(nvl(tl_text_base_attribute40,x_old_attr.tl_text_base_attribute40),'#DEL',null,tl_text_base_attribute40),
	decode(nvl(tl_text_base_attribute41,x_old_attr.tl_text_base_attribute41),'#DEL',null,tl_text_base_attribute41),
	decode(nvl(tl_text_base_attribute42,x_old_attr.tl_text_base_attribute42),'#DEL',null,tl_text_base_attribute42),
	decode(nvl(tl_text_base_attribute43,x_old_attr.tl_text_base_attribute43),'#DEL',null,tl_text_base_attribute43),
	decode(nvl(tl_text_base_attribute44,x_old_attr.tl_text_base_attribute44),'#DEL',null,tl_text_base_attribute44),
	decode(nvl(tl_text_base_attribute45,x_old_attr.tl_text_base_attribute45),'#DEL',null,tl_text_base_attribute45),
	decode(nvl(tl_text_base_attribute46,x_old_attr.tl_text_base_attribute46),'#DEL',null,tl_text_base_attribute46),
	decode(nvl(tl_text_base_attribute47,x_old_attr.tl_text_base_attribute47),'#DEL',null,tl_text_base_attribute47),
	decode(nvl(tl_text_base_attribute48,x_old_attr.tl_text_base_attribute48),'#DEL',null,tl_text_base_attribute48),
	decode(nvl(tl_text_base_attribute49,x_old_attr.tl_text_base_attribute49),'#DEL',null,tl_text_base_attribute49),
	decode(nvl(tl_text_base_attribute50,x_old_attr.tl_text_base_attribute50),'#DEL',null,tl_text_base_attribute50),
	decode(nvl(tl_text_base_attribute51,x_old_attr.tl_text_base_attribute51),'#DEL',null,tl_text_base_attribute51),
	decode(nvl(tl_text_base_attribute52,x_old_attr.tl_text_base_attribute52),'#DEL',null,tl_text_base_attribute52),
	decode(nvl(tl_text_base_attribute53,x_old_attr.tl_text_base_attribute53),'#DEL',null,tl_text_base_attribute53),
	decode(nvl(tl_text_base_attribute54,x_old_attr.tl_text_base_attribute54),'#DEL',null,tl_text_base_attribute54),
	decode(nvl(tl_text_base_attribute55,x_old_attr.tl_text_base_attribute55),'#DEL',null,tl_text_base_attribute55),
	decode(nvl(tl_text_base_attribute56,x_old_attr.tl_text_base_attribute56),'#DEL',null,tl_text_base_attribute56),
	decode(nvl(tl_text_base_attribute57,x_old_attr.tl_text_base_attribute57),'#DEL',null,tl_text_base_attribute57),
	decode(nvl(tl_text_base_attribute58,x_old_attr.tl_text_base_attribute58),'#DEL',null,tl_text_base_attribute58),
	decode(nvl(tl_text_base_attribute59,x_old_attr.tl_text_base_attribute59),'#DEL',null,tl_text_base_attribute59),
	decode(nvl(tl_text_base_attribute60,x_old_attr.tl_text_base_attribute60),'#DEL',null,tl_text_base_attribute60),
	decode(nvl(tl_text_base_attribute61,x_old_attr.tl_text_base_attribute61),'#DEL',null,tl_text_base_attribute61),
	decode(nvl(tl_text_base_attribute62,x_old_attr.tl_text_base_attribute62),'#DEL',null,tl_text_base_attribute62),
	decode(nvl(tl_text_base_attribute63,x_old_attr.tl_text_base_attribute63),'#DEL',null,tl_text_base_attribute63),
	decode(nvl(tl_text_base_attribute64,x_old_attr.tl_text_base_attribute64),'#DEL',null,tl_text_base_attribute64),
	decode(nvl(tl_text_base_attribute65,x_old_attr.tl_text_base_attribute65),'#DEL',null,tl_text_base_attribute65),
	decode(nvl(tl_text_base_attribute66,x_old_attr.tl_text_base_attribute66),'#DEL',null,tl_text_base_attribute66),
	decode(nvl(tl_text_base_attribute67,x_old_attr.tl_text_base_attribute67),'#DEL',null,tl_text_base_attribute67),
	decode(nvl(tl_text_base_attribute68,x_old_attr.tl_text_base_attribute68),'#DEL',null,tl_text_base_attribute68),
	decode(nvl(tl_text_base_attribute69,x_old_attr.tl_text_base_attribute69),'#DEL',null,tl_text_base_attribute69),
	decode(nvl(tl_text_base_attribute70,x_old_attr.tl_text_base_attribute70),'#DEL',null,tl_text_base_attribute70),
	decode(nvl(tl_text_base_attribute71,x_old_attr.tl_text_base_attribute71),'#DEL',null,tl_text_base_attribute71),
	decode(nvl(tl_text_base_attribute72,x_old_attr.tl_text_base_attribute72),'#DEL',null,tl_text_base_attribute72),
	decode(nvl(tl_text_base_attribute73,x_old_attr.tl_text_base_attribute73),'#DEL',null,tl_text_base_attribute73),
	decode(nvl(tl_text_base_attribute74,x_old_attr.tl_text_base_attribute74),'#DEL',null,tl_text_base_attribute74),
	decode(nvl(tl_text_base_attribute75,x_old_attr.tl_text_base_attribute75),'#DEL',null,tl_text_base_attribute75),
	decode(nvl(tl_text_base_attribute76,x_old_attr.tl_text_base_attribute76),'#DEL',null,tl_text_base_attribute76),
	decode(nvl(tl_text_base_attribute77,x_old_attr.tl_text_base_attribute77),'#DEL',null,tl_text_base_attribute77),
	decode(nvl(tl_text_base_attribute78,x_old_attr.tl_text_base_attribute78),'#DEL',null,tl_text_base_attribute78),
	decode(nvl(tl_text_base_attribute79,x_old_attr.tl_text_base_attribute79),'#DEL',null,tl_text_base_attribute79),
	decode(nvl(tl_text_base_attribute80,x_old_attr.tl_text_base_attribute80),'#DEL',null,tl_text_base_attribute80),
	decode(nvl(tl_text_base_attribute81,x_old_attr.tl_text_base_attribute81),'#DEL',null,tl_text_base_attribute81),
	decode(nvl(tl_text_base_attribute82,x_old_attr.tl_text_base_attribute82),'#DEL',null,tl_text_base_attribute82),
	decode(nvl(tl_text_base_attribute83,x_old_attr.tl_text_base_attribute83),'#DEL',null,tl_text_base_attribute83),
	decode(nvl(tl_text_base_attribute84,x_old_attr.tl_text_base_attribute84),'#DEL',null,tl_text_base_attribute84),
	decode(nvl(tl_text_base_attribute85,x_old_attr.tl_text_base_attribute85),'#DEL',null,tl_text_base_attribute85),
	decode(nvl(tl_text_base_attribute86,x_old_attr.tl_text_base_attribute86),'#DEL',null,tl_text_base_attribute86),
	decode(nvl(tl_text_base_attribute87,x_old_attr.tl_text_base_attribute87),'#DEL',null,tl_text_base_attribute87),
	decode(nvl(tl_text_base_attribute88,x_old_attr.tl_text_base_attribute88),'#DEL',null,tl_text_base_attribute88),
	decode(nvl(tl_text_base_attribute89,x_old_attr.tl_text_base_attribute89),'#DEL',null,tl_text_base_attribute89),
	decode(nvl(tl_text_base_attribute90,x_old_attr.tl_text_base_attribute90),'#DEL',null,tl_text_base_attribute90),
	decode(nvl(tl_text_base_attribute91,x_old_attr.tl_text_base_attribute91),'#DEL',null,tl_text_base_attribute91),
	decode(nvl(tl_text_base_attribute92,x_old_attr.tl_text_base_attribute92),'#DEL',null,tl_text_base_attribute92),
	decode(nvl(tl_text_base_attribute93,x_old_attr.tl_text_base_attribute93),'#DEL',null,tl_text_base_attribute93),
	decode(nvl(tl_text_base_attribute94,x_old_attr.tl_text_base_attribute94),'#DEL',null,tl_text_base_attribute94),
	decode(nvl(tl_text_base_attribute95,x_old_attr.tl_text_base_attribute95),'#DEL',null,tl_text_base_attribute95),
	decode(nvl(tl_text_base_attribute96,x_old_attr.tl_text_base_attribute96),'#DEL',null,tl_text_base_attribute96),
	decode(nvl(tl_text_base_attribute97,x_old_attr.tl_text_base_attribute97),'#DEL',null,tl_text_base_attribute97),
	decode(nvl(tl_text_base_attribute98,x_old_attr.tl_text_base_attribute98),'#DEL',null,tl_text_base_attribute98),
	decode(nvl(tl_text_base_attribute99,x_old_attr.tl_text_base_attribute99),'#DEL',null,tl_text_base_attribute99),
	decode(nvl(tl_text_base_attribute100,x_old_attr.tl_text_base_attribute100),'#DEL',null,tl_text_base_attribute100),
	decode(nvl(tl_text_cat_attribute1,x_old_attr.tl_text_cat_attribute1),'#DEL',null,tl_text_cat_attribute1),
	decode(nvl(tl_text_cat_attribute2,x_old_attr.tl_text_cat_attribute2),'#DEL',null,tl_text_cat_attribute2),
	decode(nvl(tl_text_cat_attribute3,x_old_attr.tl_text_cat_attribute3),'#DEL',null,tl_text_cat_attribute3),
	decode(nvl(tl_text_cat_attribute4,x_old_attr.tl_text_cat_attribute4),'#DEL',null,tl_text_cat_attribute4),
	decode(nvl(tl_text_cat_attribute5,x_old_attr.tl_text_cat_attribute5),'#DEL',null,tl_text_cat_attribute5),
	decode(nvl(tl_text_cat_attribute6,x_old_attr.tl_text_cat_attribute6),'#DEL',null,tl_text_cat_attribute6),
	decode(nvl(tl_text_cat_attribute7,x_old_attr.tl_text_cat_attribute7),'#DEL',null,tl_text_cat_attribute7),
	decode(nvl(tl_text_cat_attribute8,x_old_attr.tl_text_cat_attribute8),'#DEL',null,tl_text_cat_attribute8),
	decode(nvl(tl_text_cat_attribute9,x_old_attr.tl_text_cat_attribute9),'#DEL',null,tl_text_cat_attribute9),
	decode(nvl(tl_text_cat_attribute10,x_old_attr.tl_text_cat_attribute10),'#DEL',null,tl_text_cat_attribute10),
	decode(nvl(tl_text_cat_attribute11,x_old_attr.tl_text_cat_attribute11),'#DEL',null,tl_text_cat_attribute11),
	decode(nvl(tl_text_cat_attribute12,x_old_attr.tl_text_cat_attribute12),'#DEL',null,tl_text_cat_attribute12),
	decode(nvl(tl_text_cat_attribute13,x_old_attr.tl_text_cat_attribute13),'#DEL',null,tl_text_cat_attribute13),
	decode(nvl(tl_text_cat_attribute14,x_old_attr.tl_text_cat_attribute14),'#DEL',null,tl_text_cat_attribute14),
	decode(nvl(tl_text_cat_attribute15,x_old_attr.tl_text_cat_attribute15),'#DEL',null,tl_text_cat_attribute15),
	decode(nvl(tl_text_cat_attribute16,x_old_attr.tl_text_cat_attribute16),'#DEL',null,tl_text_cat_attribute16),
	decode(nvl(tl_text_cat_attribute17,x_old_attr.tl_text_cat_attribute17),'#DEL',null,tl_text_cat_attribute17),
	decode(nvl(tl_text_cat_attribute18,x_old_attr.tl_text_cat_attribute18),'#DEL',null,tl_text_cat_attribute18),
	decode(nvl(tl_text_cat_attribute19,x_old_attr.tl_text_cat_attribute19),'#DEL',null,tl_text_cat_attribute19),
	decode(nvl(tl_text_cat_attribute20,x_old_attr.tl_text_cat_attribute20),'#DEL',null,tl_text_cat_attribute20),
	decode(nvl(tl_text_cat_attribute21,x_old_attr.tl_text_cat_attribute21),'#DEL',null,tl_text_cat_attribute21),
	decode(nvl(tl_text_cat_attribute22,x_old_attr.tl_text_cat_attribute22),'#DEL',null,tl_text_cat_attribute22),
	decode(nvl(tl_text_cat_attribute23,x_old_attr.tl_text_cat_attribute23),'#DEL',null,tl_text_cat_attribute23),
	decode(nvl(tl_text_cat_attribute24,x_old_attr.tl_text_cat_attribute24),'#DEL',null,tl_text_cat_attribute24),
	decode(nvl(tl_text_cat_attribute25,x_old_attr.tl_text_cat_attribute25),'#DEL',null,tl_text_cat_attribute25),
	decode(nvl(tl_text_cat_attribute26,x_old_attr.tl_text_cat_attribute26),'#DEL',null,tl_text_cat_attribute26),
	decode(nvl(tl_text_cat_attribute27,x_old_attr.tl_text_cat_attribute27),'#DEL',null,tl_text_cat_attribute27),
	decode(nvl(tl_text_cat_attribute28,x_old_attr.tl_text_cat_attribute28),'#DEL',null,tl_text_cat_attribute28),
	decode(nvl(tl_text_cat_attribute29,x_old_attr.tl_text_cat_attribute29),'#DEL',null,tl_text_cat_attribute29),
	decode(nvl(tl_text_cat_attribute30,x_old_attr.tl_text_cat_attribute30),'#DEL',null,tl_text_cat_attribute30),
	decode(nvl(tl_text_cat_attribute31,x_old_attr.tl_text_cat_attribute31),'#DEL',null,tl_text_cat_attribute31),
	decode(nvl(tl_text_cat_attribute32,x_old_attr.tl_text_cat_attribute32),'#DEL',null,tl_text_cat_attribute32),
	decode(nvl(tl_text_cat_attribute33,x_old_attr.tl_text_cat_attribute33),'#DEL',null,tl_text_cat_attribute33),
	decode(nvl(tl_text_cat_attribute34,x_old_attr.tl_text_cat_attribute34),'#DEL',null,tl_text_cat_attribute34),
	decode(nvl(tl_text_cat_attribute35,x_old_attr.tl_text_cat_attribute35),'#DEL',null,tl_text_cat_attribute35),
	decode(nvl(tl_text_cat_attribute36,x_old_attr.tl_text_cat_attribute36),'#DEL',null,tl_text_cat_attribute36),
	decode(nvl(tl_text_cat_attribute37,x_old_attr.tl_text_cat_attribute37),'#DEL',null,tl_text_cat_attribute37),
	decode(nvl(tl_text_cat_attribute38,x_old_attr.tl_text_cat_attribute38),'#DEL',null,tl_text_cat_attribute38),
	decode(nvl(tl_text_cat_attribute39,x_old_attr.tl_text_cat_attribute39),'#DEL',null,tl_text_cat_attribute39),
	decode(nvl(tl_text_cat_attribute40,x_old_attr.tl_text_cat_attribute40),'#DEL',null,tl_text_cat_attribute40),
	decode(nvl(tl_text_cat_attribute41,x_old_attr.tl_text_cat_attribute41),'#DEL',null,tl_text_cat_attribute41),
	decode(nvl(tl_text_cat_attribute42,x_old_attr.tl_text_cat_attribute42),'#DEL',null,tl_text_cat_attribute42),
	decode(nvl(tl_text_cat_attribute43,x_old_attr.tl_text_cat_attribute43),'#DEL',null,tl_text_cat_attribute43),
	decode(nvl(tl_text_cat_attribute44,x_old_attr.tl_text_cat_attribute44),'#DEL',null,tl_text_cat_attribute44),
	decode(nvl(tl_text_cat_attribute45,x_old_attr.tl_text_cat_attribute45),'#DEL',null,tl_text_cat_attribute45),
	decode(nvl(tl_text_cat_attribute46,x_old_attr.tl_text_cat_attribute46),'#DEL',null,tl_text_cat_attribute46),
	decode(nvl(tl_text_cat_attribute47,x_old_attr.tl_text_cat_attribute47),'#DEL',null,tl_text_cat_attribute47),
	decode(nvl(tl_text_cat_attribute48,x_old_attr.tl_text_cat_attribute48),'#DEL',null,tl_text_cat_attribute48),
	decode(nvl(tl_text_cat_attribute49,x_old_attr.tl_text_cat_attribute49),'#DEL',null,tl_text_cat_attribute49),
	decode(nvl(tl_text_cat_attribute50,x_old_attr.tl_text_cat_attribute50),'#DEL',null,tl_text_cat_attribute50),
	decode(nvl(last_update_login,x_old_attr.last_update_login),'#DEL',null,last_update_login),
	nvl(last_updated_by,x_old_attr.last_updated_by),
	sysdate,
	x_old_attr.created_by,
	x_old_attr.creation_date,
	decode(nvl(request_id,x_old_attr.request_id),'#DEL',null,request_id),
	decode(nvl(program_application_id,x_old_attr.program_application_id),'#DEL',null,program_application_id),
	decode(nvl(program_id,x_old_attr.program_id),'#DEL',null,program_id),
	sysdate
	from PO_ATTR_VALUES_TLP_INTERFACE
	where
	interface_line_id = p_line_id_tbl(i) AND
        interface_header_id = p_header_id_tbl(i) AND
        language = l_attr_lang_tbl(j);

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'New Item Data Inserted for Language: '|| l_attr_lang_tbl(j));
     END IF;

        END LOOP;

	ELSE --Addition of attr tlp lines

	select language_code
        BULK COLLECT INTO l_attr_lang_tbl
        from fnd_languages
	WHERE installed_flag in ('B', 'I');

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'Languages collected from DB: ', l_attr_lang_tbl.COUNT);
     END IF;

        FOR j IN 1..l_attr_lang_tbl.COUNT
        LOOP

	insert into ICX_CAT_PCH_ITEM_ATTRS_TLP(
	punchout_item_id,
	attribute_values_tlp_id,
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
	program_update_date
	)
	select		--values
	p_item_id_tbl(i),
	ICX_PCH_CAT_ATTR_TLP_SEQ.NEXTVAL,
	org_id,
	l_attr_lang_tbl(j),
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
	nvl(last_updated_by, -1),
	sysdate,
	nvl(created_by, -1),
	sysdate,
	request_id,
	program_application_id,
	program_id,
	sysdate
	FROM PO_ATTR_VALUES_TLP_INTERFACE
  where
	interface_line_id = p_line_id_tbl(i) AND
        interface_header_id = p_header_id_tbl(i) AND
        language = p_item_lang_tbl(i);

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'New Item Created for Language: '|| l_attr_lang_tbl(j));
     END IF;

	END LOOP;

     END IF;

       l_acc_intf_line_id_tbl.EXTEND;
       l_acc_intf_line_id_tbl(l_acc_intf_line_id_tbl.COUNT) := p_line_id_tbl(i);

       l_acc_intf_header_id_tbl.EXTEND;
       l_acc_intf_header_id_tbl(l_acc_intf_header_id_tbl.COUNT) := p_header_id_tbl(i);


     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, i || '. Completed Item ID: '|| p_item_id_tbl(i));
     END IF;

   END LOOP;

     d_position := 40;

       update_attr_values_tl_intf
       (p_h_id_tbl => l_acc_intf_header_id_tbl,
       p_l_id_tbl => l_acc_intf_line_id_tbl,
       p_process_code => g_PROCESS_CODE_ACCEPTED);

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'Attr Values Tlp Updation Complete ');
     END IF;

     d_position := 50;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'End sync_attr_values_tlp_intf');
   END IF;

 EXCEPTION
 WHEN OTHERS THEN
   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Exception at sync_attr_values_tlp_intf');
   END IF;
   RAISE;
 END sync_attr_values_tlp_intf;

-----------------------------------------------------------------------
 --Start of Comments
 --Name: process_lines_sync
 --Function: creates new punchout item.
 --          System will update lines if already exist in the table.
 --Parameters:
 --IN:
 --p_err_lines_tolerance
 --  No. of errors to ignore
 --IN OUT:
 --OUT:
 --x_processed_lines_count
 --  No. of accepted line
 --x_rejected_lines_count
 --  No. of rejected line
 --x_err_tolerance_exceeded
 --  error tolerance exceed flag
--End of Comments
 ------------------------------------------------------------------------
 PROCEDURE process_lines_sync(
   p_err_lines_tolerance IN NUMBER,
  x_processed_lines_count OUT NOCOPY NUMBER,
  x_rejected_lines_count OUT NOCOPY NUMBER,
  x_err_tolerance_exceeded OUT NOCOPY VARCHAR2
) IS

   d_api_name CONSTANT VARCHAR2(30) := 'process_lines_sync';
   d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
   d_position NUMBER;

   -- select lines with UPDATE action value
   CURSOR c_add_action_lines IS
   	SELECT
    intf_lines.interface_line_id,
   	intf_lines.interface_header_id,
   	intf_lines.action,
	intf_lines.file_line_language,
	intf_lines.item,
	intf_lines.item_description,
  intf_lines.item_revision,
	intf_lines.uom_code,
	intf_lines.unit_price,
	intf_headers.currency_code,
	intf_headers.rate_type_code,
	intf_headers.rate_date,
	intf_headers.rate,
	intf_lines.ip_category_name,
	intf_lines.ip_category_id,
	intf_lines.category,
	intf_headers.vendor_id,
	intf_lines.vendor_product_num,
	intf_lines.supplier_part_auxid,
	intf_headers.vendor_name,
	intf_headers.vendor_site_id,
	intf_headers.vendor_contact_id,
	intf_lines.effective_date,
	intf_lines.expiration_date,
	intf_lines.last_updated_by,
	intf_lines.last_update_date,
	intf_lines.last_update_login,
	intf_lines.creation_date,
	intf_lines.created_by,
	intf_lines.request_id,
	intf_lines.program_application_id,
	intf_lines.program_id,
	intf_lines.program_update_date
	FROM   po_lines_interface intf_lines,
	po_headers_interface intf_headers
	WHERE  intf_lines.interface_header_id = intf_headers.interface_header_id
	AND    intf_headers.batch_id = g_batch_id
	AND    nvl(intf_lines.action, g_ACTION_UPDATE) in (g_ACTION_UPDATE, g_ACTION_SYNC)
	AND    nvl(intf_lines.process_code, g_PROCESS_CODE_PENDING) = g_PROCESS_CODE_PENDING
	ORDER BY 1;

   x_item items_rec_type;
   x_old_item item_rec_type_s;

   l_line_id_tbl   PO_TBL_NUMBER;
   l_header_id_tbl PO_TBL_NUMBER;
   l_line_action_tbl    PO_TBL_VARCHAR30;

   -- interface line id of lines that need to be rejected
   l_rej_intf_line_id_tbl   PO_TBL_NUMBER := PO_TBL_NUMBER();

   -- interface line id of lines that is accepted
   l_acc_intf_line_id_tbl   PO_TBL_NUMBER := PO_TBL_NUMBER();
   l_acc_intf_header_id_tbl   PO_TBL_NUMBER := PO_TBL_NUMBER();

   -- created or updated punchout item id
   l_pho_cat_item_id_tbl   PO_TBL_NUMBER := PO_TBL_NUMBER();
   l_pho_cat_item_lang_tbl   PO_TBL_VARCHAR5 := PO_TBL_VARCHAR5();

   x_count number;
   x_temp_item_id number;
   l_po_cat_id NUMBER;

 BEGIN
   d_position := 0;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Start process_lines_sync');
     PO_LOG.stmt(d_module, d_position, 'p_err_lines_tolerance: '|| p_err_lines_tolerance);
   END IF;

   -- get all add eligible lines from cursor
   OPEN c_add_action_lines();

   d_position := 10;

   FETCH c_add_action_lines
   BULK COLLECT INTO
        l_line_id_tbl				,
        l_header_id_tbl				,
        l_line_action_tbl			,
        x_item.line_lang_tbl			,
        x_item.item_tbl 			,
        x_item.item_desc_tbl                  ,
        x_item.item_revision_tbl              ,
        x_item.uom_code_tbl                   ,
        x_item.unit_price_tbl                 ,
        x_item.hd_currency_code_tbl           ,
        x_item.hd_rate_type_tbl               ,
        x_item.hd_rate_date_tbl               ,
        x_item.hd_rate_tbl                    ,
        x_item.ip_category_tbl                ,
        x_item.ip_category_id_tbl             ,
        x_item.category_tbl             ,
        x_item.hd_vendor_id_tbl               ,
        x_item.vendor_product_num_tbl         ,
        x_item.supplier_part_auxid_tbl        ,
        x_item.vendor_name_tbl                ,
        x_item.vendor_site_id_tbl             ,
        x_item.vendor_contact_id_tbl          ,
        x_item.effective_date_tbl             ,
        x_item.expiration_date_tbl            ,
        x_item.last_updated_by_tbl            ,
        x_item.last_update_date_tbl           ,
        x_item.last_update_login_tbl          ,
        x_item.creation_date_tbl              ,
        x_item.created_by_tbl                 ,
        x_item.request_id_tbl                 ,
        x_item.program_application_id_tbl     ,
        x_item.program_id_tbl                 ,
        x_item.program_update_date_tbl        ;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Collected items from cursor');
   END IF;

   d_position := 20;

   -- update if an alread existing line is found otherwise insert
   FOR i IN 1..x_item.item_tbl.COUNT
   LOOP

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, i || '. Processing Item: '|| x_item.vendor_product_num_tbl(i));
     END IF;

     x_count := 0;
      select
     	count(*)
	    into
	    x_count
	    from ICX_CAT_PUNCHOUT_ITEMS
	    where
	    supplier_id = g_supplier_id AND
	    nvl(supplier_site_id, 1) = nvl(g_supplier_site_id, 1) AND
	    supplier_part_num = x_item.vendor_product_num_tbl(i) AND
	    nvl(supplier_part_auxid, 1) = nvl(x_item.supplier_part_auxid_tbl(i), 1);

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'Count: '|| x_count);
     END IF;

     --If already exists merge item value with existing

     IF (x_count > 0) THEN

     select
     	punchout_item_id,
	--language,
	item,
	description,
	item_revision,
	uom_code,
	unit_price,
	currency_code,
	rate_type_code,
	rate_date,
	rate,
	ip_category_id,
	ip_category_name,
	po_category_name,
	supplier_id,
	supplier_part_num,
	supplier_part_auxid,
	supplier,
	supplier_site_id,
	supplier_contact_id,
	effective_date,
	expiration_date,
	last_update_login,
	last_updated_by,
	last_update_date,
	creation_date,
	created_by,
	request_id,
	program_application_id,
	program_id,
	program_update_date
	into
	x_temp_item_id				,
        --x_old_item.line_lang_tbl		,
        x_old_item.item_tbl 			,
        x_old_item.item_desc_tbl                  ,
        x_old_item.item_revision_tbl              ,
        x_old_item.uom_code_tbl                   ,
        x_old_item.unit_price_tbl                 ,
        x_old_item.hd_currency_code_tbl           ,
        x_old_item.hd_rate_type_tbl               ,
        x_old_item.hd_rate_date_tbl               ,
        x_old_item.hd_rate_tbl                    ,
        x_old_item.ip_category_id_tbl             ,
        x_old_item.ip_category_tbl                ,
        x_old_item.po_category_tbl                ,
        x_old_item.hd_vendor_id_tbl               ,
        x_old_item.vendor_product_num_tbl         ,
        x_old_item.supplier_part_auxid_tbl        ,
        x_old_item.vendor_name_tbl                ,
        x_old_item.vendor_site_id_tbl             ,
        x_old_item.vendor_contact_id_tbl          ,
        x_old_item.effective_date_tbl             ,
        x_old_item.expiration_date_tbl            ,
        x_old_item.last_update_login_tbl          ,
        x_old_item.last_updated_by_tbl            ,
        x_old_item.last_update_date_tbl           ,
        x_old_item.creation_date_tbl              ,
        x_old_item.created_by_tbl                 ,
        x_old_item.request_id_tbl                 ,
        x_old_item.program_application_id_tbl     ,
        x_old_item.program_id_tbl                 ,
        x_old_item.program_update_date_tbl
	from ICX_CAT_PUNCHOUT_ITEMS
	where
	    supplier_id = g_supplier_id AND
	    nvl(supplier_site_id, 1) = nvl(g_supplier_site_id, 1) AND
	    supplier_part_num = x_item.vendor_product_num_tbl(i) AND
	    nvl(supplier_part_auxid, 1) = nvl(x_item.supplier_part_auxid_tbl(i), 1);

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'Collected OLD Item Data');
     END IF;

	--if(x_item.line_lang_tbl(i) is NULL) then
	--	x_item.line_lang_tbl(i) := x_old_item.line_lang_tbl;
	--end if;
	if(x_item.item_tbl(i) is NULL) then
		x_item.item_tbl(i) := x_old_item.item_tbl;
	end if;
	if(x_item.item_desc_tbl(i) is NULL) then
		x_item.item_desc_tbl(i) := x_old_item.item_desc_tbl;
	elsif(x_item.item_desc_tbl(i) = '#DEL') then
		x_item.item_desc_tbl(i) := null;
	end if;
	if(x_item.item_revision_tbl(i) is NULL) then
		x_item.item_revision_tbl(i) := x_old_item.item_revision_tbl;
	elsif(x_item.item_revision_tbl(i) = '#DEL') then
		x_item.item_revision_tbl(i) := null;
	end if;
	if(x_item.uom_code_tbl(i) is NULL) then
		x_item.uom_code_tbl(i) := x_old_item.uom_code_tbl;
	end if;
	if(x_item.unit_price_tbl(i) is NULL) then
		x_item.unit_price_tbl(i) := x_old_item.unit_price_tbl;
	end if;
	if(x_item.hd_currency_code_tbl(i) is NULL) then
		x_item.hd_currency_code_tbl(i) := x_old_item.hd_currency_code_tbl;
	end if;
	if(x_item.hd_rate_type_tbl(i) is NULL) then
		x_item.hd_rate_type_tbl(i) := x_old_item.hd_rate_type_tbl;
	end if;
	if(x_item.hd_rate_date_tbl(i) is NULL) then
		x_item.hd_rate_date_tbl(i) := x_old_item.hd_rate_date_tbl;
	end if;
	if(x_item.hd_rate_tbl(i) is NULL) then
		x_item.hd_rate_tbl(i) := x_old_item.hd_rate_tbl;
	end if;
	if(x_item.ip_category_id_tbl(i) is NULL) then
		x_item.ip_category_id_tbl(i) := x_old_item.ip_category_id_tbl;
	end if;
	if(x_item.ip_category_tbl(i) is NULL) then
		x_item.ip_category_tbl(i) := x_old_item.ip_category_tbl;
	end if;
	if(x_item.category_tbl(i) is NULL) then
		x_item.category_tbl(i) := x_old_item.po_category_tbl;
	end if;
	if(x_item.supplier_part_auxid_tbl(i) is NULL) then
		x_item.supplier_part_auxid_tbl(i) := x_old_item.supplier_part_auxid_tbl;
	end if;
	if(x_item.vendor_contact_id_tbl(i) is NULL) then
		x_item.vendor_contact_id_tbl(i) := x_old_item.vendor_contact_id_tbl;
	end if;
	if(x_item.effective_date_tbl(i) is NULL) then
		x_item.effective_date_tbl(i) := x_old_item.effective_date_tbl;
	end if;
	if(x_item.expiration_date_tbl(i) is NULL) then
		x_item.expiration_date_tbl(i) := x_old_item.expiration_date_tbl;
	end if;

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'Data Merge Complete');
     END IF;

	IF(x_item.ip_category_id_tbl(i) is NULL OR x_item.ip_category_id_tbl(i) = '') THEN

		PO_PDOI_ERR_UTL.add_fatal_error
		(
		  p_interface_header_id  => l_header_id_tbl(i),
		  p_interface_line_id    => l_line_id_tbl(i),
		  p_error_message_name   => 'PO_PDOI_DERV_ERROR',
		  p_table_name           => 'PO_LINES_INTERFACE',
		  p_column_name          => 'IP_CATEGORY_ID',
		  p_column_value         => x_item.ip_category_id_tbl(i),
		  p_token1_name          => 'COLUMN_NAME',
		  p_token1_value         => 'IP_CATEGORY',
		  p_token2_name          => 'VALUE',
		  p_token2_value         => x_item.ip_category_tbl(i),
		  p_token3_name          => 'COLUMN_NAME',
		  p_token3_value         => 'CATEGORY',
		  p_token4_name          => 'VALUE',
		  p_token4_value         => x_item.category_tbl(i),
		  p_validation_id        => PO_VAL_CONSTANTS.c_ip_category_derv
		);

	       l_rej_intf_line_id_tbl.EXTEND;
	       l_rej_intf_line_id_tbl(l_rej_intf_line_id_tbl.COUNT) := l_line_id_tbl(i);

		IF (PO_LOG.d_stmt) THEN
		PO_LOG.stmt(d_module, d_position, 'Invalid Category line id',
			   l_line_id_tbl(i));
		END IF;

	ELSE

	     l_po_cat_id := getPurchasingCatId(x_item.ip_category_id_tbl(i));

	     IF (PO_LOG.d_stmt) THEN
	       PO_LOG.stmt(d_module, d_position, 'Purchasing Category ID: '|| l_po_cat_id);
	     END IF;

		update ICX_CAT_PUNCHOUT_ITEMS SET
		--language	 =  x_item.line_lang_tbl(i),
		item		 =  x_item.item_tbl(i),
		description	 =  x_item.item_desc_tbl(i),
		item_revision	 =  x_item.item_revision_tbl(i),
		uom_code	 =  x_item.uom_code_tbl(i),
		unit_price	 =  x_item.unit_price_tbl(i),
		currency_code	 =  x_item.hd_currency_code_tbl(i),
		rate_type_code	 =  x_item.hd_rate_type_tbl(i),
		rate_date	 =  x_item.hd_rate_date_tbl(i),
		rate		 =  x_item.hd_rate_tbl(i),
		ip_category_name	 =  x_item.ip_category_tbl(i),
		ip_category_id =  x_item.ip_category_id_tbl(i),
		po_category_id = l_po_cat_id,
		supplier_part_auxid =  x_item.supplier_part_auxid_tbl(i),
		supplier_contact_id =  x_item.vendor_contact_id_tbl(i),
		content_zone_id = g_content_zone_id,
	  effective_date = x_item.effective_date_tbl(i),
		expiration_date = x_item.expiration_date_tbl(i),
		last_update_login =  x_item.last_update_login_tbl(i),
		last_updated_by	 =  Nvl(x_item.last_updated_by_tbl(i),-1),
		last_update_date =  sysdate,
		request_id	 =  x_item.request_id_tbl(i),
		program_application_id =  x_item.program_application_id_tbl(i),
		program_id	 =  x_item.program_id_tbl(i),
		program_update_date = sysdate
		where
		punchout_item_id = x_temp_item_id;

	     IF (PO_LOG.d_stmt) THEN
	       PO_LOG.stmt(d_module, d_position, 'Item Updation Complete');
	     END IF;

	       l_acc_intf_line_id_tbl.EXTEND;
	       l_acc_intf_line_id_tbl(l_acc_intf_line_id_tbl.COUNT) := l_line_id_tbl(i);

	       l_acc_intf_header_id_tbl.EXTEND;
	       l_acc_intf_header_id_tbl(l_acc_intf_header_id_tbl.COUNT) := l_header_id_tbl(i);

	       l_pho_cat_item_id_tbl.EXTEND;
	       l_pho_cat_item_id_tbl(l_pho_cat_item_id_tbl.COUNT) := x_temp_item_id;

	       l_pho_cat_item_lang_tbl.EXTEND;
	       l_pho_cat_item_lang_tbl(l_pho_cat_item_lang_tbl.COUNT) := x_item.line_lang_tbl(i);
	END IF;

    ELSE

	IF(x_item.ip_category_id_tbl(i) is NULL OR x_item.ip_category_id_tbl(i) = '') THEN

		PO_PDOI_ERR_UTL.add_fatal_error
		(
		  p_interface_header_id  => l_header_id_tbl(i),
		  p_interface_line_id    => l_line_id_tbl(i),
		  p_error_message_name   => 'PO_PDOI_DERV_ERROR',
		  p_table_name           => 'PO_LINES_INTERFACE',
		  p_column_name          => 'IP_CATEGORY_ID',
		  p_column_value         => x_item.ip_category_id_tbl(i),
		  p_token1_name          => 'COLUMN_NAME',
		  p_token1_value         => 'IP_CATEGORY',
		  p_token2_name          => 'VALUE',
		  p_token2_value         => x_item.ip_category_tbl(i),
		  p_token3_name          => 'COLUMN_NAME',
		  p_token3_value         => 'CATEGORY',
		  p_token4_name          => 'VALUE',
		  p_token4_value         => x_item.category_tbl(i),
		  p_validation_id        => PO_VAL_CONSTANTS.c_ip_category_derv
		);

	       l_rej_intf_line_id_tbl.EXTEND;
	       l_rej_intf_line_id_tbl(l_rej_intf_line_id_tbl.COUNT) := l_line_id_tbl(i);

		IF (PO_LOG.d_stmt) THEN
		PO_LOG.stmt(d_module, d_position, 'Invalid Category line id',
			   l_line_id_tbl(i));
		END IF;

	ELSE
		select ICX_PUNCHOUT_CAT_ITEM_SEQ.NEXTVAL into x_temp_item_id from dual;

	     IF (PO_LOG.d_stmt) THEN
	       PO_LOG.stmt(d_module, d_position, 'New Item ID: '|| x_temp_item_id);
	     END IF;

		l_po_cat_id := getPurchasingCatId(x_item.ip_category_id_tbl(i));

	     IF (PO_LOG.d_stmt) THEN
	       PO_LOG.stmt(d_module, d_position, 'Purchasing Category ID: '|| l_po_cat_id);
	     END IF;

		insert into ICX_CAT_PUNCHOUT_ITEMS(
		punchout_item_id	,
		org_id			,
		--language		,
		item			,
		description		,
		item_revision		,
		uom_code		,
		unit_price		,
		currency_code		,
		rate_type_code		,
		rate_date		,
		rate			,
		ip_category_name	,
		ip_category_id		,
		po_category_id		,
		supplier_id		,
		supplier_part_num	,
		supplier_part_auxid	,
		supplier		,
		supplier_site_id	,
		supplier_contact_id	,
		content_zone_id,
	  effective_date		,
		expiration_date		,
		last_update_login	,
		last_updated_by		,
		last_update_date	,
		created_by		,
		creation_date		,
		request_id		,
		program_application_id	,
		program_id		,
		program_update_date
		)
		values(
		x_temp_item_id	,
		g_org_id	,
		--x_item.line_lang_tbl(i)			,
		x_item.item_tbl(i) 			,
		x_item.item_desc_tbl(i)                  ,
		x_item.item_revision_tbl(i)              ,
		x_item.uom_code_tbl(i)                   ,
		x_item.unit_price_tbl(i)                 ,
		x_item.hd_currency_code_tbl(i)           ,
		x_item.hd_rate_type_tbl(i)               ,
		x_item.hd_rate_date_tbl(i)               ,
		x_item.hd_rate_tbl(i)                    ,
		x_item.ip_category_tbl(i)                ,
		x_item.ip_category_id_tbl(i)             ,
		l_po_cat_id				,
		g_supplier_id               ,
		x_item.vendor_product_num_tbl(i)         ,
		x_item.supplier_part_auxid_tbl(i)        ,
		x_item.vendor_name_tbl(i)                ,
		g_supplier_site_id             ,
		x_item.vendor_contact_id_tbl(i)          ,
		g_content_zone_id                         ,
	  x_item.effective_date_tbl(i)             ,
		x_item.expiration_date_tbl(i)            ,
		x_item.last_update_login_tbl(i)          ,
		Nvl(x_item.last_updated_by_tbl(i),-1)            ,
		sysdate           			,
		Nvl(x_item.created_by_tbl(i),-1)                 ,
		sysdate              			,
		x_item.request_id_tbl(i)                 ,
		x_item.program_application_id_tbl(i)     ,
		x_item.program_id_tbl(i)                 ,
		sysdate
		);

	     IF (PO_LOG.d_stmt) THEN
	       PO_LOG.stmt(d_module, d_position, 'New Item Creation Complete');
	     END IF;

	      l_acc_intf_line_id_tbl.EXTEND;
	       l_acc_intf_line_id_tbl(l_acc_intf_line_id_tbl.COUNT) := l_line_id_tbl(i);

	       l_acc_intf_header_id_tbl.EXTEND;
	       l_acc_intf_header_id_tbl(l_acc_intf_header_id_tbl.COUNT) := l_header_id_tbl(i);

	       l_pho_cat_item_id_tbl.EXTEND;
	       l_pho_cat_item_id_tbl(l_pho_cat_item_id_tbl.COUNT) := x_temp_item_id;

	       l_pho_cat_item_lang_tbl.EXTEND;
	       l_pho_cat_item_lang_tbl(l_pho_cat_item_lang_tbl.COUNT) := x_item.line_lang_tbl(i);

	     END IF;

	 END IF;

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, i || '. Completed Item: '|| x_item.vendor_product_num_tbl(i));
     END IF;

   END LOOP;

   PO_INTERFACE_ERRORS_UTL.flush_errors_tbl;

   d_position := 35;

   -- reject the lines and the lower level entities associated with it
   update_lines_intf_process
   (
     p_id_tbl                  => l_rej_intf_line_id_tbl,
     p_process_code => g_PROCESS_CODE_REJECTED,
     p_cascade => G_YES
   );
     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'Lines Rejected');
     END IF;

   d_position := 40;


   -- accept the lines
   update_lines_intf_process
   (
     p_id_tbl                  => l_acc_intf_line_id_tbl,
     p_process_code => g_PROCESS_CODE_ACCEPTED,
     p_cascade => G_NO
   );
     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'Lines Accepted');
     END IF;

        d_position := 50;

   -- Sync attr values for accepted lines
   sync_attr_values_intf
   (p_line_id_tbl => l_acc_intf_line_id_tbl,
   p_header_id_tbl => l_acc_intf_header_id_tbl,
   p_item_id_tbl => l_pho_cat_item_id_tbl
   );
     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'Attr Value Sync Complete');
     END IF;

       d_position := 60;
   sync_attr_values_tlp_intf
   (p_line_id_tbl => l_acc_intf_line_id_tbl,
   p_header_id_tbl => l_acc_intf_header_id_tbl,
   p_item_id_tbl => l_pho_cat_item_id_tbl,
   p_item_lang_tbl => l_pho_cat_item_lang_tbl
   );

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'Attr Value Tlp Sync Complete');
     END IF;

   d_position := 70;
   sync_endeca_item_attrs
   (p_item_id_tbl => l_pho_cat_item_id_tbl
   );

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'Endeca Attr Sync Complete');
     END IF;

   d_position := 80;
   update_punchout_option
   (p_item_id_tbl => l_pho_cat_item_id_tbl
   );

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'Punchout Option Updation Complete');
     END IF;

   d_position := 90;


CLOSE c_add_action_lines;

   x_rejected_lines_count := l_rej_intf_line_id_tbl.Count;
     x_processed_lines_count := l_acc_intf_line_id_tbl.Count;
     IF (x_rejected_lines_count > p_err_lines_tolerance) THEN
        x_err_tolerance_exceeded := G_YES;
     ELSE
        x_err_tolerance_exceeded := G_NO;
     END IF;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'End process_lines_sync');
   END IF;

 EXCEPTION
   WHEN OTHERS THEN
   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Exception at process_lines_sync');
   END IF;
     RAISE;
 END process_lines_sync;

-----------------------------------------------------------------------
 --Start of Comments
 --Name: process_lines_add
 --Function: creates new punchout item.
 --          System will reject lines if already exist in the table.
 --Parameters:
 --IN:
 --p_err_lines_tolerance
 --  No. of errors to ignore
 --IN OUT:
 --OUT:
 --x_processed_lines_count
 --  No. of accepted line
 --x_rejected_lines_count
 --  No. of rejected line
 --x_err_tolerance_exceeded
 --  error tolerance exceed flag
--End of Comments
 ------------------------------------------------------------------------
 PROCEDURE process_lines_add(
   p_err_lines_tolerance IN NUMBER,
  x_processed_lines_count OUT NOCOPY NUMBER,
  x_rejected_lines_count OUT NOCOPY NUMBER,
  x_err_tolerance_exceeded OUT NOCOPY VARCHAR2
) IS

   d_api_name CONSTANT VARCHAR2(30) := 'process_lines_add';
   d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
   d_position NUMBER;

   -- select lines with add action value
   CURSOR c_add_action_lines IS
   	SELECT
    intf_lines.interface_line_id,
   	intf_lines.interface_header_id,
   	intf_lines.action,
	intf_lines.file_line_language,
	intf_lines.item,
	intf_lines.item_description,
	intf_lines.item_revision,
	intf_lines.uom_code,
	intf_lines.unit_price,
	intf_headers.currency_code,
	intf_headers.rate_type_code,
	intf_headers.rate_date,
	intf_headers.rate,
	intf_lines.ip_category_name,
        intf_lines.ip_category_id,
	intf_lines.category,
	intf_headers.vendor_id,
	intf_lines.vendor_product_num,
	intf_lines.supplier_part_auxid,
	intf_headers.vendor_name,
	intf_headers.vendor_site_id,
	intf_headers.vendor_contact_id,
	intf_lines.effective_date,
	intf_lines.expiration_date,
	intf_lines.last_updated_by,
	intf_lines.last_update_date,
	intf_lines.last_update_login,
	intf_lines.creation_date,
	intf_lines.created_by,
	intf_lines.request_id,
	intf_lines.program_application_id,
	intf_lines.program_id,
	intf_lines.program_update_date
	FROM   po_lines_interface intf_lines,
	po_headers_interface intf_headers
	WHERE  intf_lines.interface_header_id = intf_headers.interface_header_id
	AND    intf_headers.batch_id = g_batch_id
	AND    intf_lines.action = g_ACTION_ADD
	AND    nvl(intf_lines.process_code, g_PROCESS_CODE_PENDING) = g_PROCESS_CODE_PENDING
	ORDER BY 1;

   x_item items_rec_type;

   l_line_id_tbl   PO_TBL_NUMBER;
   l_header_id_tbl PO_TBL_NUMBER;
   l_line_action_tbl    PO_TBL_VARCHAR30;

   -- interface line id of lines that need to be rejected
   l_rej_intf_line_id_tbl   PO_TBL_NUMBER := PO_TBL_NUMBER();

   -- interface line id of lines that is accepted
   l_acc_intf_line_id_tbl   PO_TBL_NUMBER := PO_TBL_NUMBER();
   l_acc_intf_header_id_tbl   PO_TBL_NUMBER := PO_TBL_NUMBER();

   -- created or updated punchout item id
   l_pho_cat_item_id_tbl   PO_TBL_NUMBER := PO_TBL_NUMBER();
   l_pho_cat_item_lang_tbl   PO_TBL_VARCHAR5 := PO_TBL_VARCHAR5();

   x_count number;
   x_temp_item_id number;
   l_po_cat_id NUMBER;

 BEGIN
   d_position := 0;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Start process_lines_add');
     PO_LOG.stmt(d_module, d_position, 'p_err_lines_tolerance: '|| p_err_lines_tolerance);
   END IF;

   -- get all add eligible lines from cursor
   OPEN c_add_action_lines();

   d_position := 10;

   FETCH c_add_action_lines
   BULK COLLECT INTO
        l_line_id_tbl				,
        l_header_id_tbl				,
        l_line_action_tbl			,
        x_item.line_lang_tbl			,
        x_item.item_tbl 			,
        x_item.item_desc_tbl                  ,
        x_item.item_revision_tbl              ,
        x_item.uom_code_tbl                   ,
        x_item.unit_price_tbl                 ,
        x_item.hd_currency_code_tbl           ,
        x_item.hd_rate_type_tbl               ,
        x_item.hd_rate_date_tbl               ,
        x_item.hd_rate_tbl                    ,
        x_item.ip_category_tbl                ,
        x_item.ip_category_id_tbl             ,
        x_item.category_tbl             ,
        x_item.hd_vendor_id_tbl               ,
        x_item.vendor_product_num_tbl         ,
        x_item.supplier_part_auxid_tbl        ,
        x_item.vendor_name_tbl                ,
        x_item.vendor_site_id_tbl             ,
        x_item.vendor_contact_id_tbl          ,
        x_item.effective_date_tbl             ,
        x_item.expiration_date_tbl            ,
        x_item.last_updated_by_tbl            ,
        x_item.last_update_date_tbl           ,
        x_item.last_update_login_tbl          ,
        x_item.creation_date_tbl              ,
        x_item.created_by_tbl                 ,
        x_item.request_id_tbl                 ,
        x_item.program_application_id_tbl     ,
        x_item.program_id_tbl                 ,
        x_item.program_update_date_tbl        ;


   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Collected items from cursor');
   END IF;

   d_position := 20;

   -- add error if an alread existing line is found otherwise insert
   FOR i IN 1..x_item.item_tbl.COUNT
   LOOP

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, i || '. Processing Item: '|| x_item.vendor_product_num_tbl(i));
     END IF;

     x_count := 0;
     select count(*) into x_count
	from ICX_CAT_PUNCHOUT_ITEMS where
	supplier_id = g_supplier_id AND
	nvl(supplier_site_id, 1) = nvl(g_supplier_site_id, 1) AND
     	supplier_part_num = x_item.vendor_product_num_tbl(i) AND
     	nvl(supplier_part_auxid, 1) = nvl(x_item.supplier_part_auxid_tbl(i), 1);

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'Count: '|| x_count);
     END IF;

     IF (x_count > 0) THEN

       l_rej_intf_line_id_tbl.EXTEND;
       l_rej_intf_line_id_tbl(l_rej_intf_line_id_tbl.COUNT) := l_line_id_tbl(i);

	IF (PO_LOG.d_stmt) THEN
	PO_LOG.stmt(d_module, d_position, 'rejected interface line id',
		   l_line_id_tbl(i));
	END IF;

	PO_PDOI_ERR_UTL.add_fatal_error
	(
	p_interface_header_id  => l_header_id_tbl(i),
	p_interface_line_id    => l_line_id_tbl(i),
	p_error_message_name   => 'PO_PDOI_INVALID_ACTION',
	p_table_name           => 'PO_LINES_INTERFACE',
	p_column_name          => 'ACTION',
	p_column_value         => l_line_action_tbl(i),
	p_token1_name          => 'VALUE',
	p_token1_value         => l_line_action_tbl(i)
	);

     ELSE


	IF(x_item.ip_category_id_tbl(i) is NULL OR x_item.ip_category_id_tbl(i) = '') THEN

		PO_PDOI_ERR_UTL.add_fatal_error
		(
		  p_interface_header_id  => l_header_id_tbl(i),
		  p_interface_line_id    => l_line_id_tbl(i),
		  p_error_message_name   => 'PO_PDOI_DERV_ERROR',
		  p_table_name           => 'PO_LINES_INTERFACE',
		  p_column_name          => 'IP_CATEGORY_ID',
		  p_column_value         => x_item.ip_category_id_tbl(i),
		  p_token1_name          => 'COLUMN_NAME',
		  p_token1_value         => 'IP_CATEGORY',
		  p_token2_name          => 'VALUE',
		  p_token2_value         => x_item.ip_category_tbl(i),
		  p_token3_name          => 'COLUMN_NAME',
		  p_token3_value         => 'CATEGORY',
		  p_token4_name          => 'VALUE',
		  p_token4_value         => x_item.category_tbl(i),
		  p_validation_id        => PO_VAL_CONSTANTS.c_ip_category_derv
		);

	       l_rej_intf_line_id_tbl.EXTEND;
	       l_rej_intf_line_id_tbl(l_rej_intf_line_id_tbl.COUNT) := l_line_id_tbl(i);

		IF (PO_LOG.d_stmt) THEN
		PO_LOG.stmt(d_module, d_position, 'Invalid Category line id',
			   l_line_id_tbl(i));
		END IF;

	ELSE
		select ICX_PUNCHOUT_CAT_ITEM_SEQ.NEXTVAL into x_temp_item_id from dual;

		IF (PO_LOG.d_stmt) THEN
		PO_LOG.stmt(d_module, d_position, 'New Item ID: ',
			   x_temp_item_id);
		END IF;

		l_po_cat_id := getPurchasingCatId(x_item.ip_category_id_tbl(i));

		IF (PO_LOG.d_stmt) THEN
		PO_LOG.stmt(d_module, d_position, 'Purchasing Category ID: ',
			   l_po_cat_id);
		END IF;

		insert into ICX_CAT_PUNCHOUT_ITEMS(
		punchout_item_id	,
		org_id			,
		--language		,
		item			,
		description		,
		item_revision		,
		uom_code		,
		unit_price		,
		currency_code		,
		rate_type_code		,
		rate_date		,
		rate			,
		ip_category_name	,
		ip_category_id		,
		po_category_name		,
		po_category_id		,
		supplier_id		,
		supplier_part_num	,
		supplier_part_auxid	,
		supplier		,
		supplier_site_id	,
		supplier_contact_id	,
		content_zone_id   ,
	  effective_date		,
		expiration_date		,
		last_update_login	,
		last_updated_by		,
		last_update_date	,
		created_by		,
		creation_date		,
		request_id		,
		program_application_id	,
		program_id		,
		program_update_date
		)
		values(
		x_temp_item_id	,
		g_org_id	,
		--x_item.line_lang_tbl(i)			,
		x_item.item_tbl(i) 			,
		x_item.item_desc_tbl(i)                  ,
		x_item.item_revision_tbl(i)              ,
		x_item.uom_code_tbl(i)                   ,
		x_item.unit_price_tbl(i)                 ,
		x_item.hd_currency_code_tbl(i)           ,
		x_item.hd_rate_type_tbl(i)               ,
		x_item.hd_rate_date_tbl(i)               ,
		x_item.hd_rate_tbl(i)                    ,
		x_item.ip_category_tbl(i)                ,
		x_item.ip_category_id_tbl(i)             ,
		x_item.category_tbl(i)             ,
		l_po_cat_id				,
		g_supplier_id               ,
		x_item.vendor_product_num_tbl(i)         ,
		x_item.supplier_part_auxid_tbl(i)        ,
		x_item.vendor_name_tbl(i)                ,
		g_supplier_site_id             ,
		x_item.vendor_contact_id_tbl(i)          ,
		g_content_zone_id  ,
	  x_item.effective_date_tbl(i)             ,
		x_item.expiration_date_tbl(i)            ,
		x_item.last_update_login_tbl(i)          ,
		Nvl(x_item.last_updated_by_tbl(i),-1)            ,
		sysdate				           ,
		Nvl(x_item.created_by_tbl(i), -1)                 ,
		sysdate				           ,
		x_item.request_id_tbl(i)                 ,
		x_item.program_application_id_tbl(i)     ,
		x_item.program_id_tbl(i)                 ,
		sysdate
		);

	     IF (PO_LOG.d_stmt) THEN
	       PO_LOG.stmt(d_module, d_position, 'New Item Creation Complete');
	     END IF;

	       l_acc_intf_line_id_tbl.EXTEND;
	       l_acc_intf_line_id_tbl(l_acc_intf_line_id_tbl.COUNT) := l_line_id_tbl(i);

	       l_acc_intf_header_id_tbl.EXTEND;
	       l_acc_intf_header_id_tbl(l_acc_intf_header_id_tbl.COUNT) := l_header_id_tbl(i);

	       l_pho_cat_item_id_tbl.EXTEND;
	       l_pho_cat_item_id_tbl(l_pho_cat_item_id_tbl.COUNT) := x_temp_item_id;

	       l_pho_cat_item_lang_tbl.EXTEND;
	       l_pho_cat_item_lang_tbl(l_pho_cat_item_lang_tbl.COUNT) := x_item.line_lang_tbl(i);
	END IF;

     END IF;

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, i || '. Completed Item: '|| x_item.vendor_product_num_tbl(i));
     END IF;

   END LOOP;

   PO_INTERFACE_ERRORS_UTL.flush_errors_tbl;

   d_position := 40;

   -- reject the lines and the lower level entities associated with it
   update_lines_intf_process
   (
     p_id_tbl                  => l_rej_intf_line_id_tbl,
     p_process_code => g_PROCESS_CODE_REJECTED,
     p_cascade => G_YES
   );
     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'Lines Rejected');
     END IF;

   d_position := 50;

   -- accept the lines
   update_lines_intf_process
   (
     p_id_tbl                  => l_acc_intf_line_id_tbl,
     p_process_code => g_PROCESS_CODE_ACCEPTED,
     p_cascade => G_NO
   );
     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'Lines Accepted');
     END IF;

d_position := 60;

-- Sync attr values for accepted lines
   sync_attr_values_intf
   (p_line_id_tbl => l_acc_intf_line_id_tbl,
   p_header_id_tbl => l_acc_intf_header_id_tbl,
   p_item_id_tbl => l_pho_cat_item_id_tbl
   );

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'Attr Value Sync Complete');
     END IF;

d_position := 70;

   sync_attr_values_tlp_intf
   (p_line_id_tbl => l_acc_intf_line_id_tbl,
   p_header_id_tbl => l_acc_intf_header_id_tbl,
   p_item_id_tbl => l_pho_cat_item_id_tbl,
   p_item_lang_tbl => l_pho_cat_item_lang_tbl
   );

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'Attr Value Tlp Sync Complete');
     END IF;

   d_position := 80;

   sync_endeca_item_attrs
   (p_item_id_tbl => l_pho_cat_item_id_tbl
   );

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'Endeca Attr Sync Complete');
     END IF;

   d_position := 90;

   update_punchout_option
   (p_item_id_tbl => l_pho_cat_item_id_tbl
   );

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'Punchout Option Updation Complete');
     END IF;

   d_position := 100;

   CLOSE c_add_action_lines;

     x_rejected_lines_count := l_rej_intf_line_id_tbl.Count;
     x_processed_lines_count := l_acc_intf_line_id_tbl.Count;
     IF (x_rejected_lines_count > p_err_lines_tolerance) THEN
        x_err_tolerance_exceeded := G_YES;
     ELSE
        x_err_tolerance_exceeded := G_NO;
     END IF;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'End process_lines_add');
   END IF;

 EXCEPTION
   WHEN OTHERS THEN
   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Exception at process_lines_add');
   END IF;
     RAISE;
 END process_lines_add;

-----------------------------------------------------------------------
 --Start of Comments
 --Name: process_lines
 --Function: creates new punchout item.
 --          System will reject lines if already exist in the table.
 --Parameters:
 --IN:
 --p_err_lines_tolerance
 --  No. of errors to ignore
 --IN OUT:
 --OUT:
 --x_processed_lines_count
 --  No. of accepted line
 --x_rejected_lines_count
 --  No. of rejected line
 --x_err_tolerance_exceeded
 --  error tolerance exceed flag
--End of Comments
 ------------------------------------------------------------------------
PROCEDURE process_lines(
  p_err_lines_tolerance IN NUMBER,
  x_processed_lines_count OUT NOCOPY NUMBER,
  x_rejected_lines_count OUT NOCOPY NUMBER,
  x_err_tolerance_exceeded OUT NOCOPY VARCHAR2
) IS

   d_api_name CONSTANT VARCHAR2(30) := 'process_lines';
   d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
   d_position NUMBER;

l_processed_lines_count NUMBER;
l_rejected_lines_count NUMBER;
l_err_tolerance_exceeded VARCHAR2(1);

t_processed_lines_count NUMBER;
t_rejected_lines_count NUMBER;
x_err_lines_tolerance NUMBER;
BEGIN
   d_position := 0;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Start process_lines');
     PO_LOG.stmt(d_module, d_position, 'p_err_lines_tolerance: '|| p_err_lines_tolerance);
   END IF;

   --initialize temp variables
   t_processed_lines_count := 0;
   t_rejected_lines_count := 0;
   x_err_lines_tolerance := p_err_lines_tolerance;
   x_err_tolerance_exceeded := G_NO;

   -- reject lines with error process code.

  d_position := 10;
  reject_invalid_process_lines(
    p_err_lines_tolerance => x_err_lines_tolerance,
    x_rejected_lines_count => l_rejected_lines_count,
    x_err_tolerance_exceeded => l_err_tolerance_exceeded
  );

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Rejected Invalid lines');
     PO_LOG.stmt(d_module, d_position, 'l_rejected_lines_count: '|| l_rejected_lines_count);
     PO_LOG.stmt(d_module, d_position, 'l_err_tolerance_exceeded: '|| l_err_tolerance_exceeded);
   END IF;

  d_position := 20;

  -- return if error tolerance exceeded

   t_rejected_lines_count := t_rejected_lines_count + l_rejected_lines_count;
   x_rejected_lines_count := t_rejected_lines_count;
  IF(l_err_tolerance_exceeded = G_YES) THEN
    x_err_tolerance_exceeded := G_YES;
    RETURN;
  ELSE
    IF(t_rejected_lines_count > p_err_lines_tolerance) THEN
        x_err_tolerance_exceeded := G_YES;
        RETURN;
    ELSE
        x_err_lines_tolerance := x_err_lines_tolerance - t_rejected_lines_count;
    END IF;
  END IF;


   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'x_rejected_lines_count: '|| x_rejected_lines_count);
     PO_LOG.stmt(d_module, d_position, 'x_err_lines_tolerance: '|| x_err_lines_tolerance);
   END IF;

   -- reject lines with invalid line level action.
   -- line level action can only be NULL or 'ADD' or 'SYNC' or 'DELETE'

  d_position := 30;
  reject_invalid_action_lines(
    p_err_lines_tolerance => x_err_lines_tolerance,
    x_rejected_lines_count => l_rejected_lines_count,
    x_err_tolerance_exceeded => l_err_tolerance_exceeded
  );

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Rejected Invalid lines');
     PO_LOG.stmt(d_module, d_position, 'l_rejected_lines_count: '|| l_rejected_lines_count);
     PO_LOG.stmt(d_module, d_position, 'l_err_tolerance_exceeded: '|| l_err_tolerance_exceeded);
   END IF;

  d_position := 40;

  -- return if error tolerance exceeded

  t_rejected_lines_count := t_rejected_lines_count + l_rejected_lines_count;
   x_rejected_lines_count := t_rejected_lines_count;

  IF(l_err_tolerance_exceeded = G_YES) THEN
    x_err_tolerance_exceeded := G_YES;
    RETURN;
  ELSE
    IF(t_rejected_lines_count > p_err_lines_tolerance) THEN
        x_err_tolerance_exceeded := G_YES;
        RETURN;
    ELSE
        x_err_lines_tolerance := x_err_lines_tolerance - t_rejected_lines_count;
    END IF;
  END IF;

   d_position := 50;


   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'x_rejected_lines_count: '|| x_rejected_lines_count);
     PO_LOG.stmt(d_module, d_position, 'x_err_lines_tolerance: '|| x_err_lines_tolerance);
   END IF;

   -- procees eligible add lines

   process_lines_add(
    p_err_lines_tolerance => x_err_lines_tolerance,
    x_processed_lines_count => l_processed_lines_count,
    x_rejected_lines_count => l_rejected_lines_count,
    x_err_tolerance_exceeded => l_err_tolerance_exceeded
  );

  d_position := 60;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'l_processed_lines_count: '|| l_processed_lines_count);
     PO_LOG.stmt(d_module, d_position, 'l_rejected_lines_count: '|| l_rejected_lines_count);
     PO_LOG.stmt(d_module, d_position, 'l_err_tolerance_exceeded: '|| l_err_tolerance_exceeded);
   END IF;

  -- return if error tolerance exceeded

    t_processed_lines_count := t_processed_lines_count + l_processed_lines_count;
    t_rejected_lines_count := t_rejected_lines_count + l_rejected_lines_count;
   x_processed_lines_count:= t_processed_lines_count;
   x_rejected_lines_count := t_rejected_lines_count;

   IF(l_err_tolerance_exceeded = G_YES) THEN
    x_err_tolerance_exceeded := G_YES;
    RETURN;
  ELSE
    IF(t_rejected_lines_count > p_err_lines_tolerance) THEN
        x_err_tolerance_exceeded := G_YES;
        RETURN;
    ELSE
        x_err_lines_tolerance := x_err_lines_tolerance - t_rejected_lines_count;
    END IF;
  END IF;


  d_position := 70;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'x_processed_lines_count: '|| x_processed_lines_count);
     PO_LOG.stmt(d_module, d_position, 'x_rejected_lines_count: '|| x_rejected_lines_count);
     PO_LOG.stmt(d_module, d_position, 'x_err_lines_tolerance: '|| x_err_lines_tolerance);
   END IF;

   -- procees eligible sync lines
   process_lines_sync(
    p_err_lines_tolerance => x_err_lines_tolerance,
    x_processed_lines_count => l_processed_lines_count,
    x_rejected_lines_count => l_rejected_lines_count,
    x_err_tolerance_exceeded => l_err_tolerance_exceeded
  );

    d_position := 80;
   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'l_processed_lines_count: '|| l_processed_lines_count);
     PO_LOG.stmt(d_module, d_position, 'l_rejected_lines_count: '|| l_rejected_lines_count);
     PO_LOG.stmt(d_module, d_position, 'l_err_tolerance_exceeded: '|| l_err_tolerance_exceeded);
   END IF;

    -- return if error tolerance exceeded

    t_processed_lines_count := t_processed_lines_count + l_processed_lines_count;
    t_rejected_lines_count := t_rejected_lines_count + l_rejected_lines_count;
   x_processed_lines_count:= t_processed_lines_count;
   x_rejected_lines_count := t_rejected_lines_count;

    IF(l_err_tolerance_exceeded = G_YES) THEN
    x_err_tolerance_exceeded := G_YES;
    RETURN;
    IF(t_rejected_lines_count > p_err_lines_tolerance) THEN
        x_err_tolerance_exceeded := G_YES;
        RETURN;
    ELSE
        x_err_lines_tolerance := x_err_lines_tolerance - t_rejected_lines_count;
    END IF;
  END IF;


  d_position := 90;
   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'x_processed_lines_count: '|| x_processed_lines_count);
     PO_LOG.stmt(d_module, d_position, 'x_rejected_lines_count: '|| x_rejected_lines_count);
     PO_LOG.stmt(d_module, d_position, 'x_err_lines_tolerance: '|| x_err_lines_tolerance);
   END IF;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'End process_lines');
   END IF;

 EXCEPTION
   WHEN OTHERS THEN
   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Exception at process_lines');
   END IF;
     RAISE;
 END process_lines;

 -----------------------------------------------------------------------
 --Start of Comments
 --Name: delete_expired_items
 --Function:
 --  Update endeca tables for expired items
 --Parameters:
 --IN:
 --IN OUT:
 --OUT:
 --End of Comments
 ------------------------------------------------------------------------
 PROCEDURE delete_expired_items
 IS

   d_api_name CONSTANT VARCHAR2(30) := 'delete_expired_items';
   d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
   d_position NUMBER;

   -- select expired items cursor

   CURSOR c_invalid_items IS
   SELECT punchout_item_id
   FROM   ICX_CAT_PUNCHOUT_ITEMS
   WHERE  NVL(expiration_date, sysdate + 1) < sysdate;

   -- interface line id of lines that need to be rejected
   l_exp_item_id_tbl   PO_TBL_NUMBER;

 BEGIN
   d_position := 0;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Start delete_expired_items');
   END IF;

   -- get all expired items
   OPEN c_invalid_items();

   d_position := 10;

   FETCH c_invalid_items
   BULK COLLECT INTO l_exp_item_id_tbl;

   d_position := 20;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Number of expired items found: ',
	       l_exp_item_id_tbl.COUNT);
   END IF;

   -- update endeca table to delete expired items
   FOR i IN 1..l_exp_item_id_tbl.COUNT
   LOOP

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'Processing Item ID: '|| l_exp_item_id_tbl(i));
     END IF;

     delete from ICX_CAT_ENDECA_ITEM_ATTRIBUTES where recordkey = to_char(l_exp_item_id_tbl(i));

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'Deleted');
     END IF;

     INSERT INTO ICX_CAT_ENDECA_ITEM_ATTRIBUTES( recordkey, attributekey, attributevalue) values(to_char(l_exp_item_id_tbl(i)),'##DELETERECORD##','##DELETERECORD##');

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'Inserted with Detete Tag ');
     END IF;

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'Completed Item ID: '|| l_exp_item_id_tbl(i));
     END IF;

   END LOOP;

   CLOSE c_invalid_items;

   d_position := 30;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'End delete_expired_items');
   END IF;

 EXCEPTION
 WHEN OTHERS THEN
   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Exception at delete_expired_items');
   END IF;
   RAISE;
 END delete_expired_items;

-----------------------------------------------------------------------
 --Start of Comments
 --Name: process_lines_add
 --Function: creates new punchout item.
 --          System will update lines if already exist in the table.
 --Parameters:
 --IN:
 --p_api_version
 --  Version of punchout upload program
 --p_batch_id
 --  Item batch id to process
 --p_batch_size
 --  Item batch size
 --p_interface_header_id
 --  po_headers_interface header id
 --p_tp_header_id
 --  ecx_tp_headers header id
 --p_org_id
 --  current org id
 --p_err_lines_tolerance
 --  No. of errors to ignore
 --IN OUT:
 --OUT:
 --x_processed_lines_count
 --  No. of accepted line
 --x_rejected_lines_count
 --  No. of rejected line
 --x_err_tolerance_exceeded
 --  error tolerance exceed flag
 --x_return_status
 --  process status
 --x_error_message
 --  process error message
--End of Comments
 ------------------------------------------------------------------------
 PROCEDURE start_upload
( p_api_version IN NUMBER,
  x_return_status OUT NOCOPY VARCHAR2,
  x_error_message OUT NOCOPY VARCHAR2,
  p_batch_id IN NUMBER,
  p_batch_size IN NUMBER,
  p_interface_header_id IN NUMBER,
  p_tp_header_id IN NUMBER,
  p_org_id IN NUMBER,
  p_err_lines_tolerance IN NUMBER,
  x_processed_lines_count OUT NOCOPY NUMBER,
  x_rejected_lines_count OUT NOCOPY NUMBER,
  x_err_tolerance_exceeded OUT NOCOPY VARCHAR2
) IS

d_api_version CONSTANT NUMBER := 1.0;
d_api_name CONSTANT VARCHAR2(30) := 'start_upload';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_processed_lines_count NUMBER;
l_rejected_lines_count NUMBER;
l_err_tolerance_exceeded VARCHAR2(1);
l_err_lines_tolerance NUMBER;
l_supplier_id NUMBER;
l_supplier_site_id NUMBER;
l_content_zone_id NUMBER;
l_stored_column VARCHAR2(30);

BEGIN

  d_position := 0;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Start start_upload');
     PO_LOG.stmt(d_module, d_position, 'p_api_version: '|| p_api_version);
     PO_LOG.stmt(d_module, d_position, 'p_batch_id: '|| p_batch_id);
     PO_LOG.stmt(d_module, d_position, 'p_batch_size: '|| p_batch_size);
     PO_LOG.stmt(d_module, d_position, 'p_interface_header_id: '|| p_interface_header_id);
     PO_LOG.stmt(d_module, d_position, 'p_tp_header_id: '|| p_tp_header_id);
     PO_LOG.stmt(d_module, d_position, 'p_org_id: '|| p_org_id);
     PO_LOG.stmt(d_module, d_position, 'p_err_lines_tolerance: '|| p_err_lines_tolerance);
   END IF;

  --  get supplier id and supplier site id from from xml gateway table

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Getting Supplier Info');
   END IF;

  SELECT h.party_id,   h.party_site_id INTO l_supplier_id, l_supplier_site_id
  FROM ecx_tp_headers h
  WHERE h.tp_header_id = p_tp_header_id;

  d_position := 10;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'l_supplier_id: '|| l_supplier_id);
     PO_LOG.stmt(d_module, d_position, 'l_supplier_site_id: '|| l_supplier_site_id);
   END IF;

 -- get zone id using supplier id and supplier site id

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Getting Content Zone Details');
   END IF;

 BEGIN

 SELECT zone_id INTO l_content_zone_id
    FROM ICX_CAT_PUNCHOUT_ZONE_DETAILS
    WHERE vendor_id = l_supplier_id
    AND vendor_site_id = l_supplier_site_id
    AND ROWNUM = 1;
 EXCEPTION
    WHEN NO_DATA_FOUND THEN
	l_content_zone_id := -1;
 END;

 d_position := 20;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'l_content_zone_id: '|| l_content_zone_id);
   END IF;

 -- get repunchout table and column

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Getting Content Zone Details');
   END IF;

 BEGIN

 SELECT stored_in_column
 INTO l_stored_column
 FROM ICX_CAT_ATTRIBUTES_TL
 WHERE KEY = g_RE_PUNCHOUT_KEY
 AND ROWNUM = 1;
 EXCEPTION
    WHEN NO_DATA_FOUND THEN
	l_stored_column := NULL;
 END;

 d_position := 30;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'l_stored_column: '|| l_stored_column);
   END IF;

  -- set global variables

  g_batch_id := p_batch_id;
  IF(p_org_id > 0) THEN
    g_org_id := p_org_id;
  END IF;
  g_supplier_id := l_supplier_id;
  g_supplier_site_id := l_supplier_site_id;
  g_content_zone_id := l_content_zone_id;
  g_stored_column := l_stored_column;

  d_position := 40;

  -- call process lines to process eligible interface lines

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Calling Process Lines');
   END IF;

  IF(p_err_lines_tolerance IS NULL) THEN
    l_err_lines_tolerance := 99999;
  END IF;
  process_lines(
    p_err_lines_tolerance => l_err_lines_tolerance,
    x_processed_lines_count => l_processed_lines_count,
    x_rejected_lines_count => l_rejected_lines_count,
    x_err_tolerance_exceeded => l_err_tolerance_exceeded
  );

  d_position := 50;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'l_processed_lines_count: '|| l_processed_lines_count);
     PO_LOG.stmt(d_module, d_position, 'l_rejected_lines_count: '|| l_rejected_lines_count);
     PO_LOG.stmt(d_module, d_position, 'l_err_tolerance_exceeded: '|| l_err_tolerance_exceeded);
     PO_LOG.stmt(d_module, d_position, 'Process Lines Complete');
   END IF;

  -- if error tolerance exceeded return else update interface header as accepted

      x_processed_lines_count := l_processed_lines_count;
      x_rejected_lines_count := l_rejected_lines_count;
    IF(l_err_tolerance_exceeded = G_YES) THEN
      x_err_tolerance_exceeded := G_YES;
      RETURN;
    ELSE
      UPDATE po_headers_interface SET
      process_code = g_PROCESS_CODE_ACCEPTED
      WHERE interface_header_id = p_interface_header_id;
    END IF;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'x_processed_lines_count: '|| x_processed_lines_count);
     PO_LOG.stmt(d_module, d_position, 'x_rejected_lines_count: '|| x_rejected_lines_count);
     PO_LOG.stmt(d_module, d_position, 'x_err_tolerance_exceeded: '|| x_err_tolerance_exceeded);
     PO_LOG.stmt(d_module, d_position, 'Updated Headers Interface');
   END IF;

    --IF(x_processed_lines_count > 0) THEN
    	x_return_status := G_SUCCESS;
    --ELSE
    --	x_return_status := G_FAILURE;
    --END IF;

  d_position := 60;

  -- clear the expired items

  delete_expired_items;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Cleared Expired Items');
   END IF;

  d_position := 70;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'End start_upload with Status: ' || x_return_status);
   END IF;

EXCEPTION
WHEN OTHERS THEN
   IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'Exception at start_upload');
   END IF;
  RAISE;
END start_upload;

-----------------------------------------------------------------------
 --Start of Comments
 --Name: send_error_notif
 --Function: Sends with error messages notification if job fails.
 --Parameters:
 --IN:
 --p_job_id
 --  Current Job Id
 --IN OUT:
 --OUT:
 --x_return_status
 --  process status
--End of Comments
 ------------------------------------------------------------------------
 PROCEDURE send_error_notif
( x_return_status OUT NOCOPY VARCHAR2,
  p_job_id IN NUMBER
) IS

d_api_name CONSTANT VARCHAR2(30) := 'send_error_notif';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

 l_supplier_id NUMBER;
l_supplier_site_id NUMBER;
l_notif_user_name VARCHAR2(100);
 l_tp_header_id NUMBER;
 l_error_msg VARCHAR2(9000);
 l_vendor_name VARCHAR2(240);
BEGIN

  d_position := 0;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Start start_upload');
     PO_LOG.stmt(d_module, d_position, 'p_job_id: '|| p_job_id);
   END IF;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Getting TP Header ID');
   END IF;
  -- get the tp header id if job failed otherwise return
    BEGIN

  SELECT error_msg, po_header_id
    INTO l_error_msg, l_tp_header_id
      FROM
      (SELECT failure_message ||'  ' ||system_failure_message AS error_msg, bj.po_header_id
      FROM
      ICX_CAT_BATCH_JOBS_ALL bj
      WHERE bj.job_number = p_job_id
      AND bj.job_status = 'ERROR'
      UNION ALL
      SELECT 'Concurrent Program Error' AS error_msg, bj.po_header_id
      FROM
      ICX_CAT_BATCH_JOBS_ALL bj, FND_CONCURRENT_REQUESTS cr
      WHERE bj.job_number = cr.request_id
      AND bj.job_number = p_job_id
      AND bj.job_status <> 'ERROR'
      AND cr.status_code IN ('E', 'T', 'X', 'D'));

  EXCEPTION
      WHEN NO_DATA_FOUND THEN
	    return;
  END;

  d_position := 10;
   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'l_tp_header_id: '|| l_tp_header_id);
   END IF;

  --  get supplier id and supplier site id from from xml gateway table

  SELECT h.party_id,   h.party_site_id INTO l_supplier_id, l_supplier_site_id
  FROM ecx_tp_headers h
  WHERE h.tp_header_id = l_tp_header_id;

  d_position := 20;
   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Got Supplier Info');
     PO_LOG.stmt(d_module, d_position, 'l_supplier_id: '|| l_supplier_id);
     PO_LOG.stmt(d_module, d_position, 'l_supplier_site_id: '|| l_supplier_site_id);
   END IF;

 -- get zone id using supplier id and supplier site id

 BEGIN

 SELECT fu.user_name
   INTO l_notif_user_name
    FROM ICX_CAT_PUNCHOUT_ZONE_DETAILS ipcz, fnd_user fu
    WHERE ipcz.vendor_id = l_supplier_id
    AND ipcz.vendor_site_id = l_supplier_site_id
    AND fu.user_id = ipcz.user_to_be_notified
    AND ROWNUM = 1;
 EXCEPTION
    WHEN NO_DATA_FOUND THEN
	  return;
 END;

 d_position := 30;
   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Got Content Zone Info');
     PO_LOG.stmt(d_module, d_position, 'l_notif_user_name: '|| l_notif_user_name);
   END IF;

 -- get supplier name
  BEGIN
   SELECT vendor_name INTO l_vendor_name
   FROM po_vendors
   WHERE vendor_id = l_supplier_id;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
	    return;
  END;

  d_position := 40;
   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Got Supplier Name');
     PO_LOG.stmt(d_module, d_position, 'l_vendor_name: '|| l_vendor_name);
   END IF;

  -- send notification to the user
   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Calling Send Notification');
   END IF;
 begin
 WF_ENGINE.CreateProcess('ICXBLKNT',To_Char(p_job_id),'NOTIFY_USER');
 WF_ENGINE.setItemAttrText('ICXBLKNT',To_Char(p_job_id),'SUPPLIER_NAME', l_vendor_name);
 WF_ENGINE.setItemAttrText('ICXBLKNT',To_Char(p_job_id),'ERROR_MESSAGE', l_error_msg);
 WF_ENGINE.setItemAttrText('ICXBLKNT',To_Char(p_job_id),'JOB_NUMBER', p_job_id);
 WF_ENGINE.setItemAttrText('ICXBLKNT',To_Char(p_job_id),'USER_TO_BE_NOTIFIED', l_notif_user_name);
 WF_ENGINE.StartProcess('ICXBLKNT',To_Char(p_job_id));
 commit;
end;

  d_position := 50;
   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Notification Sent');
   END IF;


   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'End send_error_notif with Status: ' || x_return_status);
   END IF;

EXCEPTION
WHEN OTHERS THEN
   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Exception at send_error_notif');
   END IF;
  RAISE;
END send_error_notif;


procedure get_ecx_header_id(p_party_id  IN PLS_INTEGER ,p_party_site_id  IN PLS_INTEGER ,p_party_type IN VARCHAR2,
                            x_tp_header_id  OUT NOCOPY PLS_INTEGER) as

l_company_admin_email ecx_tp_headers.company_admin_email%TYPE;

begin
 -- select data from ECX_TP_HEADERS.
 Select
    TP_HEADER_ID,
    COMPANY_ADMIN_EMAIL
 into
    x_tp_header_id,
    l_company_admin_email
 from
    ECX_TP_HEADERS
 where party_type    = p_party_type
 and   party_id      = p_party_id
 and   party_site_id = p_party_site_id;

Exception
  when others then
     x_tp_header_id :=null;
End  get_ecx_header_id;

procedure get_ecx_dtl_id(p_tp_header_id IN PLS_INTEGER ,p_ext_process_id IN PLS_INTEGER , p_map_code IN VARCHAR2 ,x_source_tp_location_code IN OUT NOCOPY VARCHAR2,x_tp_detail_id IN OUT NOCOPY PLS_INTEGER) as

begin

select
etd.tp_detail_id ,etd.source_tp_location_code
Into
x_tp_detail_id ,x_source_tp_location_code
from ecx_tp_details     etd
where etd.tp_header_id   = p_tp_header_id
and   etd.ext_process_id = p_ext_process_id
and   ((x_tp_detail_id is not null and etd.tp_detail_id=x_tp_detail_id)
       or etd.source_tp_location_code=x_source_tp_location_code)
and exists (select 'Y' from ecx_mappings em where em.map_code=p_map_code and em.map_id = etd.map_id )	;

exception
when others then
x_tp_detail_id :=null;

end  get_ecx_dtl_id;


procedure  manage_tp_details(p_party_id IN pls_integer ,p_party_site_id IN pls_integer, p_source_tp_location_code  IN   Varchar2 , x_tp_detail_id IN OUT NOCOPY PLS_INTEGER ,
x_return_status OUT NOCOPY PLS_INTEGER ,x_msg OUT NOCOPY Varchar2) as

x_tp_header_id        Pls_integer    := null;
l_ext_process_id      pls_integer := 0;
l_transaction_subtype varchar2(200)  :='CATALOG';
l_transaction_type    varchar2(200)  :='ICX';
l_ext_subtype         varchar2(200)  :='CATALOG';
l_ext_type            varchar2(200)  :='ICX';
l_party_type          varchar2(200)  :='S';
l_standard            varchar2(200)  :='OAG';
l_standard_type       varchar2(200)  :='XML';
l_direction           varchar2(200)  :='IN';
l_map_code            varchar2(200) := 'ICX_AUTO_CATALOG_001';
l_standard_id         pls_integer;
l_transaction_id      pls_integer;
old_source_tp_location_code   ecx_tp_details.source_tp_location_code%TYPE;
l_comp_email          ecx_tp_headers.company_admin_email%TYPE;

begin

-- Get Ids

select 	standard_id    into 	l_standard_id
from 	ecx_standards
where  	standard_code = l_standard
and	    standard_type = l_standard_type;

Select 	TRANSACTION_ID  into  l_transaction_id
from 	ECX_TRANSACTIONS
where 	transaction_type    = l_transaction_type
and   	transaction_subtype = l_transaction_subtype
and     party_type          = l_party_type;

select 	EXT_PROCESS_ID	into 	l_ext_process_id
from 	ECX_EXT_PROCESSES
where 	transaction_id  = l_transaction_id
and   	standard_id     = l_standard_id
and   	direction       = l_direction
and     ext_type=l_ext_type
and     ext_subtype=l_ext_subtype;


select  EMAIL_ADDRESS INTO   l_comp_email
from po_vendor_contacts
where   VENDOR_ID= p_party_id
AND vendor_site_id = p_party_site_id
AND TRUNC(NVL(inactive_date, sysdate + 1)) > TRUNC(sysdate)
AND ROWNUM=1;

 if (l_comp_email is null)
 then
      l_comp_email := fnd_profile.value('ECX_SYS_ADMIN_EMAIL');
    if (l_comp_email is null)
    then
       l_comp_email := 'sys_admin@oracle.com';
    end if;
 end if;

--Get Header Details

get_ecx_header_id(p_party_id,p_party_site_id,l_party_type,x_tp_header_id);

if(x_tp_header_id is null) then

x_tp_detail_id :=null ;

--Context setting required as create_trading_partner uses org striped view PO_VENDOR_SITES

 MO_GLOBAL.INIT('ICX');


ECX_TP_API.create_trading_partner
(
	p_party_type	       =>  l_party_type,
	p_party_id  	       =>  p_party_id,
	p_party_site_id	       =>  p_party_site_id,
	p_company_admin_email  =>  l_comp_email,
	x_tp_header_id	       =>  x_tp_header_id,
	x_return_status	       =>  x_return_status,
	x_msg		           =>  x_msg
);

if(x_tp_header_id is not NULL AND x_tp_header_id >0) then

ECX_TP_API.create_tp_detail(
x_return_status =>x_return_status,
x_msg =>x_msg,
x_tp_detail_id =>x_tp_detail_id,
p_tp_header_id =>x_tp_header_id ,
p_ext_process_id=>l_ext_process_id,
p_map_code =>l_map_code,
p_connection_type=>null,
p_hub_user_id=>null,
p_protocol_type=>null,
p_protocol_address=>null,
p_username=>null,
p_password=>null,
p_routing_id=>null,
p_source_tp_location_code=>p_source_tp_location_code,
p_external_tp_location_code=>null,
p_confirmation=>null
)	  ;

end if;

else

old_source_tp_location_code :=  p_source_tp_location_code  ;

get_ecx_dtl_id(x_tp_header_id,l_ext_process_id,l_map_code,old_source_tp_location_code,x_tp_detail_id);

if(x_tp_detail_id is null)	 then

ECX_TP_API.create_tp_detail(
x_return_status =>x_return_status,
x_msg =>x_msg,
x_tp_detail_id =>x_tp_detail_id,
p_tp_header_id =>x_tp_header_id ,
p_ext_process_id=>l_ext_process_id,
p_map_code =>l_map_code,
p_connection_type=>null,
p_hub_user_id=>null,
p_protocol_type=>null,
p_protocol_address=>null,
p_username=>null,
p_password=>null,
p_routing_id=>null,
p_source_tp_location_code=>p_source_tp_location_code,
p_external_tp_location_code=>null,
p_confirmation=>null
)	  ;

elsif(old_source_tp_location_code <> p_source_tp_location_code) then

ECX_TP_API.update_tp_detail(
x_return_status  => x_return_status,
x_msg	=> x_msg	,
p_tp_detail_id	=>	x_tp_detail_id ,
p_map_code	 =>	 l_map_code,
p_ext_process_id  => l_ext_process_id,
p_connection_type  =>null,
p_hub_user_id	 =>null,
p_protocol_type	 =>null,
p_protocol_address	=>	null,
p_username	 =>	null,
p_password	 =>	null,
p_routing_id	=> 	null,
p_source_tp_location_code  =>	p_source_tp_location_code,
p_external_tp_location_code	=> null,
p_confirmation	=>		null ,
p_passupd_flag	=>	null);

end if;

end if;

Exception

when others then

x_tp_detail_id :=null;

END manage_tp_details;


END ICX_PUNCHOUT_CAT_UPLOAD;

/
