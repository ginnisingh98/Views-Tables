--------------------------------------------------------
--  DDL for Package Body PO_REQIMP_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQIMP_S" AS
/* $Header: POXRQIMB.pls 120.3.12010000.4 2011/05/17 11:12:36 uchennam ship $*/

--< Bug 3540365 Start >
g_bulk_limit CONSTANT NUMBER := 1000;  -- Bulk collect limit in number of rows
--< Bug 3540365 End >

PROCEDURE get_list_price_conversion(x_request_id IN NUMBER,x_currency_code IN VARCHAR2,x_set_of_books_id IN NUMBER) IS

x_progress	VARCHAR2(3)  := NULL ;
x_rowid 	VARCHAR2(250) := '';
x_item_id	NUMBER;
x_source_org_id	NUMBER := NULL;
x_rate_date	DATE;
x_gl_date	DATE;
x_creation_date	DATE;
x_list_price_conv_temp NUMBER;

CURSOR inv_lines IS
    select rowid, item_id,rate_date, gl_date, creation_date, source_organization_id
    from po_requisitions_interface
    where source_type_code = 'INVENTORY'
    and unit_price is NULL
    and item_id is not NULL
    and source_organization_id is not null
    and request_id = x_request_id;

BEGIN
    x_progress := '010';
    OPEN inv_lines;
    LOOP
      FETCH inv_lines into
		x_rowid,
                x_item_id,
                x_rate_date,
                x_gl_date,
                x_creation_date,
                x_source_org_id;
    EXIT WHEN inv_lines%NOTFOUND;

    begin
       Select round(gl_currency_api.get_closest_rate_sql(x_set_of_books_id,glsob.currency_code,
           trunc(nvl(nvl(nvl(x_rate_date,x_gl_date),x_creation_date),sysdate)),
                       psp.DEFAULT_RATE_TYPE, 30),10)
	INTO x_list_price_conv_temp
	FROM gl_sets_of_books glsob,org_organization_definitions ood,po_system_parameters psp
	WHERE  x_currency_code <> glsob.currency_code
	    AND  glsob.set_of_books_id = ood.set_of_books_id
	    AND ood.organization_id = x_source_org_id
	    AND psp.DEFAULT_RATE_TYPE in (select DEFAULT_RATE_TYPE from po_system_parameters);
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
         x_list_price_conv_temp := 1;
         WHEN OTHERS THEN
         x_list_price_conv_temp := 1;
       END;

      If (x_list_price_conv_temp < 0) then

     	update po_requisitions_interface
	     set unit_price = (select  msi.list_price_per_unit
                         FROM mtl_system_items msi
                        WHERE msi.inventory_item_id = x_item_id
                          AND msi.organization_id = x_source_org_id)
		where rowid = x_rowid;

      else

	update po_requisitions_interface
	     set unit_price = (select ( msi.list_price_per_unit * x_list_price_conv_temp)
                         FROM mtl_system_items msi
                        WHERE msi.inventory_item_id = x_item_id
                          AND msi.organization_id = x_source_org_id)
     		where rowid = x_rowid;
      end if;

  END LOOP;
  CLOSE inv_lines;

  EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('get_list_price', x_progress, sqlcode);
    RAISE;
END get_list_price_conversion;


PROCEDURE get_uom_conversion(x_request_id IN NUMBER,x_inventory_org_id IN NUMBER) IS

  x_progress		VARCHAR2(3)  := NULL ;
  x_rowid			VARCHAR2(250) := '';
  x_item_id			NUMBER;
  x_uom				VARCHAR2(30);
  x_uom_conversion_temp		NUMBER := 1;
  --Bug#11668528
  x_list_price NUMBER;
  x_destination_org_id NUMBER;
  x_line_type_id number;
  --Bug#11668528
CURSOR vendor_lines IS
    select rowid, item_id,unit_of_measure,
    DESTINATION_ORGANIZATION_ID,line_type_id --Bug#11668528
    from po_requisitions_interface
    where source_type_code = 'VENDOR'
    and unit_price is NULL
    and request_id = x_request_id;

BEGIN

    x_progress := '010';
    OPEN vendor_lines;
    LOOP
      FETCH vendor_lines into
		x_rowid,
                x_item_id,
                x_uom,
                x_destination_org_id ,x_line_type_id;  --Bug#11668528
    EXIT WHEN vendor_lines%NOTFOUND;

    begin
       --Bug# 1347733
       --togeorge 12/05/2000
       --Switched the first two arguments in the call to the procedure po_uom_convert.
       --This is done to avoid inaccurate value after conversion.
       --SELECT  round(po_uom_s.po_uom_convert(msi.primary_unit_of_measure,  x_uom,  x_item_id),10)
       SELECT  round(po_uom_s.po_uom_convert(x_uom, msi.primary_unit_of_measure, x_item_id),10)
	INTO x_uom_conversion_temp
             FROM mtl_system_items msi
            WHERE msi.inventory_item_id = x_item_id
            AND  x_inventory_org_id = msi.organization_id
            AND msi.primary_unit_of_measure <> x_uom;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
	 x_uom_conversion_temp := 1;
         WHEN OTHERS THEN
	 x_uom_conversion_temp := 1;
       END;
       --Bug#11668528 Start
       BEGIN
       	   SELECT round(msi.list_price_per_unit * (x_uom_conversion_temp),10)
       	   INTO x_list_price
           FROM mtl_system_items msi,
                po_line_types plt
           WHERE msi.inventory_item_id = x_item_id
           AND msi.organization_id = x_destination_org_id
           AND plt.line_type_id = x_line_type_id
           AND plt.order_type_lookup_code = 'QUANTITY';
        EXCEPTION
          WHEN OTHERS THEN
             X_LIST_PRICE := NULL;
        END;

        IF x_list_price IS NULL THEN
            BEGIN
			       	   SELECT round(msi.list_price_per_unit * (x_uom_conversion_temp),10)
			       	   INTO x_list_price
			           FROM mtl_system_items msi,
			                po_line_types plt
			           WHERE msi.inventory_item_id = x_item_id
			           AND msi.organization_id = x_inventory_org_id
			           AND plt.line_type_id = x_line_type_id
			           AND plt.order_type_lookup_code = 'QUANTITY';
		        EXCEPTION
			          WHEN OTHERS THEN
			             X_LIST_PRICE := NULL;
		        END;
		     END IF;
       -->Bug# 1347733 End
       UPDATE po_requisitions_interface pri
       --Bug# 1347733
       --togeorge 12/05/2000
       --List price is multiplied with uom conversion instead of dividing.
       --This is done to avoid inaccurate value after conversion.
       --SET pri.unit_price = (SELECT round(msi.list_price_per_unit / (x_uom_conversion_temp),10)
       --Commented below to update price with x_list_price Bug# 11668528
       /*        SET pri.unit_price = (SELECT round(msi.list_price_per_unit * (x_uom_conversion_temp),10)
                             FROM mtl_system_items msi,
                                  po_line_types plt
                            WHERE msi.inventory_item_id = pri.item_id
                              AND pri.DESTINATION_ORGANIZATION_ID
                                         = msi.organization_id
                              AND pri.line_type_id = plt.line_type_id
                              AND plt.order_type_lookup_code = 'QUANTITY') Bug# 1347733 */
           SET  pri.unit_price = x_list_price
             WHERE rowid = x_rowid;
  END LOOP;
  CLOSE vendor_lines;

  EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('get_uom', x_progress, sqlcode);
    RAISE;
END get_uom_conversion;

--< Bug 3540365 Start >
--------------------------------------------------------------------------------
--Start of Comments
--Name: default_trx_reason_codes
--Pre-reqs:
--  None.
--Modifies:
--  PO_REQUISITIONS_INTERFACE
--Locks:
--  None.
--Function:
--  Defaults transaction reason codes based upon req line data in the interface
--  table only if defaulting is supported in the current installation.
--  Defaulting logic implemented by JL team. Writes to concurrent log file
--  when unexpected errors occur.
--Parameters:
--IN:
--p_request_id
--  The ID for the current requistion import request.
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE default_trx_reason_codes( p_request_id IN NUMBER )
IS

CURSOR l_null_pri_trx_csr IS
    SELECT transaction_id
         , destination_organization_id
         , item_id
      FROM po_requisitions_interface
     WHERE request_id = p_request_id
       AND transaction_reason_code IS NULL;

l_return_status          VARCHAR2(1);
l_default_supported_flag VARCHAR2(1);
l_progress               VARCHAR2(3);

l_fsp_inv_org_id FINANCIALS_SYSTEM_PARAMS_ALL.inventory_organization_id%TYPE;
l_org_id         FINANCIALS_SYSTEM_PARAMS_ALL.org_id%TYPE;

/*Bug#4430300 Replaced the references to JLBR data types with the po standard data types */
l_transaction_id_tbl  po_tbl_number;
l_dest_org_id_tbl     po_tbl_number;
l_item_id_tbl         po_tbl_number;
l_trx_reason_code_tbl po_tbl_varchar100;
l_error_code_tbl      po_tbl_number;

BEGIN
    l_progress := '000';

    -- Only proceed if defaulting of transaction reason is supported
    PO_JL_INTERFACE_PVT.chk_def_trx_reason_flag
        ( x_return_status       => l_return_status
        , x_def_trx_reason_flag => l_default_supported_flag
        );
    IF (l_return_status <> FND_API.g_ret_sts_success) THEN
        RAISE FND_API.g_exc_unexpected_error;
    ELSIF (NVL(l_default_supported_flag,'N') <> 'Y') THEN
        -- Exit procedure because defaulting is not supported.
        RETURN;
    END IF;

    l_progress := '010';
    -- Get data needed to call defaulting logic. This data is the same for each
    -- call to the defaulting API, so retrieve it outside the loop.
    SELECT org_id
         , inventory_organization_id
      INTO l_org_id
         , l_fsp_inv_org_id
      FROM financials_system_parameters;

    l_progress := '020';
    -- Bulk collect data from req lines for defaulting. Bulk process in a loop
    -- to ensure we do not take up too much memory for the collections.
    OPEN l_null_pri_trx_csr;
    LOOP
        FETCH l_null_pri_trx_csr BULK COLLECT
         INTO l_transaction_id_tbl
            , l_dest_org_id_tbl
            , l_item_id_tbl
        LIMIT g_bulk_limit;

        EXIT WHEN (l_transaction_id_tbl IS NULL) OR
                  (l_transaction_id_tbl.COUNT = 0);

        l_progress := '030';
        -- Derive transaction reasons for each req line
        PO_JL_INTERFACE_PVT.get_trx_reason_code
            ( p_fsp_inv_org_id       => l_fsp_inv_org_id
            , p_inventory_org_id_tbl => l_dest_org_id_tbl
            , p_item_id_tbl          => l_item_id_tbl
            , p_org_id               => l_org_id
            , x_return_status        => l_return_status
            , x_trx_reason_code_tbl  => l_trx_reason_code_tbl
            , x_error_code_tbl       => l_error_code_tbl
            );
        IF (l_return_status <> FND_API.g_ret_sts_success) THEN
            RAISE FND_API.g_exc_unexpected_error;
        END IF;

        -- Defaulting call was successful. Only update records if the API
        -- populated the output tables with values
        IF (l_trx_reason_code_tbl IS NOT NULL) AND
           (l_error_code_tbl IS NOT NULL)
        THEN
            l_progress := '040';
            -- Update the interface table with the derived transaction reasons.
            -- Do not update those lines with a non-zero error code; those lines
            -- failed defaulting, so the trx reason should be left NULL.
            FORALL i IN l_transaction_id_tbl.FIRST..l_transaction_id_tbl.LAST
                UPDATE po_requisitions_interface
                   SET transaction_reason_code = l_trx_reason_code_tbl(i)
                 WHERE transaction_id = l_transaction_id_tbl(i)
                   AND l_error_code_tbl(i) = 0;
        END IF;

        -- Need to exit when all records have been fetched
        EXIT WHEN l_null_pri_trx_csr%NOTFOUND;

    END LOOP;
EXCEPTION
    WHEN FND_API.g_exc_unexpected_error THEN
        -- Unexpected error status returned from our API calls. Write to log.
        FOR i IN 1..FND_MSG_PUB.count_msg LOOP
            FND_FILE.put_line(FND_FILE.LOG, l_progress||': '||FND_MSG_PUB.get(i,'F'));
        END LOOP;
    WHEN OTHERS THEN
        -- Any other exception should be written to log with generic error msg.
        FND_MSG_PUB.build_exc_msg
            ( p_pkg_name       => 'PO_REQIMP_S'
            , p_procedure_name => 'default_trx_reason_codes-'||l_progress
            );
        FND_FILE.put_line(FND_FILE.log, FND_MESSAGE.get);
END default_trx_reason_codes;
--< Bug 3540365 End >


--<INVCONV R12 START>
--------------------------------------------------------------------------------
--Start of Comments
--Name: REQIMPORT_DEF_VALIDATE_SEC_QTY
--Pre-reqs:
--  None.
--Modifies:
--  PO_REQUISITIONS_INTERFACE
--Locks:
--  None.
--Function:
--  Validates (deviation), Derives Secondary Quantities in  Req Import Tables for dual uom
--  controlled items. For internal orders it checks deviation for both source and
--  destination organization.
--Parameters:
--IN:
--p_request_id
--  The ID for the current requistion import request.
--End of Comments
--------------------------------------------------------------------------------

PROCEDURE REQIMPORT_DEF_VALIDATE_SEC_QTY
( p_request_id		IN 		 NUMBER
)


IS

  l_progress               VARCHAR2(3);

  l_rec PO_INTERFACE_ERRORS%ROWTYPE;
  l_rtn_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(2000);
  l_row_id ROWID;


  l_item_um2		MTL_UNITS_OF_MEASURE.UOM_CODE%TYPE;
  l_item_id		MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID%TYPE;
  l_tracking_qty_ind	MTL_SYSTEM_ITEMS.TRACKING_QUANTITY_IND%TYPE;
  l_secondary_default_ind MTL_SYSTEM_ITEMS.SECONDARY_DEFAULT_IND%TYPE;


  l_item_unit_of_measure_s	MTL_UNITS_OF_MEASURE.UNIT_OF_MEASURE%TYPE;
  l_item_um2_s		MTL_UNITS_OF_MEASURE.UOM_CODE%TYPE;
  l_tracking_qty_ind_s	MTL_SYSTEM_ITEMS.TRACKING_QUANTITY_IND%TYPE;
  l_secondary_default_ind_s MTL_SYSTEM_ITEMS.SECONDARY_DEFAULT_IND%TYPE;
  l_unit_of_measure_s   MTL_UNITS_OF_MEASURE.UNIT_OF_MEASURE%TYPE;

  l_sec_qty_source      NUMBER;

Cursor Cr_int_req IS
Select	pri.rowid,
        pri.transaction_id,
        pri.source_type_code,
	pri.source_organization_id,
	pri.destination_organization_id,
	pri.item_id,
	pri.secondary_unit_of_measure,
	pri.secondary_uom_code,
	pri.secondary_quantity,
	pri.quantity,
	pri.unit_of_measure,
	pri.preferred_grade
From	po_requisitions_interface pri
Where   pri.request_id = p_request_id
FOR UPDATE OF pri.secondary_unit_of_measure;

Cursor Cr_item_attr(p_inv_item_id IN NUMBER,p_organization_id IN NUMBER) IS
Select	m.tracking_quantity_ind,
	m.secondary_uom_code,
	m.secondary_default_ind
From	mtl_system_items m
Where	m.inventory_item_id = p_inv_item_id
And     m.organization_id = p_organization_id;

BEGIN
l_progress := '000';
--Loop for every record in the interface table for the current concurrent request.
FOR Cr_rec IN Cr_int_req LOOP

  l_item_um2		:= NULL;
  l_tracking_qty_ind	:= NULL;
  l_secondary_default_ind := NULL;

  l_tracking_qty_ind_s	       := NULL;
  l_item_um2_s		       := NULL;
  l_secondary_default_ind_s    := NULL;
  l_unit_of_measure_s          := NULL;
  l_sec_qty_source	:= NULL;

  --Only where item_id is specified.
  IF Cr_rec.item_id IS NOT NULL THEN

    -- Get Item Attributes
    BEGIN
       OPEN Cr_item_attr(cr_rec.item_id, cr_rec.destination_organization_id);
       FETCH Cr_item_attr INTO  l_tracking_qty_ind,
  	       			l_item_um2		,
  	       			l_secondary_default_ind;
       CLOSE Cr_item_attr;
    END;
    l_progress := '010';
    --If secondary quantity is not provided then compute it and update interface table.
    IF cr_rec.secondary_unit_of_measure IS NOT NULL AND
       l_tracking_qty_ind = 'PS' THEN

       IF (cr_rec.secondary_quantity IS NULL OR
           l_secondary_default_ind = 'F')
       THEN

          cr_rec.secondary_quantity := INV_CONVERT.inv_um_convert(
                                                  item_id        =>  cr_rec.item_id,
                                                  precision	 =>  6,
                                                  from_quantity  =>  cr_rec.quantity,
                                                  from_unit      => NULL,
                                                  to_unit        => NULL,
                                                  from_name	 =>  cr_rec.unit_of_measure ,
                                                  to_name	 =>  cr_rec.secondary_unit_of_measure );
          l_progress := '020';
          IF cr_rec.secondary_quantity <=0 THEN
                l_rec.interface_type     := 'REQIMPORT';
                l_rec.interface_transaction_id := cr_rec.transaction_id;
                l_rec.column_name        := 'SECONDARY_QUANTITY';
                l_rec.table_name         := 'PO_REQUISITIONS_INTERFACE';
                l_rec.error_message_name := 'INV_NO_CONVERSION_ERR';

                fnd_message.set_name('INV', l_rec.error_message_name);
                l_rec.error_message := FND_MESSAGE.get;

                PO_INTERFACE_ERRORS_GRP.log_error
                 ( p_api_version => 1.0,
                   p_init_msg_list => FND_API.G_TRUE,
                   x_return_status => l_rtn_status,
                   x_msg_count => l_msg_count,
                   x_msg_data => l_msg_data,
                   p_rec => l_rec,
                   x_row_id => l_row_id);

                IF (l_rtn_status <> FND_API.G_RET_STS_SUCCESS) THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
          ELSE
             UPDATE po_requisitions_interface
             SET    secondary_quantity = cr_rec.secondary_quantity
             WHERE  rowid = cr_rec.rowid;
          END IF;
          l_progress := '030';
       --If secondary quantity is specified then check deviation for type Default and No Default items
       --for fixed type items do the conversion and update interface table.
       ELSE
          l_progress := '040';

          IF INV_CONVERT.within_deviation(
                      p_organization_id      =>  cr_rec.destination_organization_id ,
                      p_inventory_item_id    =>  cr_rec.item_id,
                      p_lot_number           =>  null ,
                      p_precision            =>  6 ,
                      p_quantity             =>  cr_rec.quantity,
                      p_unit_of_measure1     =>  cr_rec.unit_of_measure ,
                      p_quantity2            =>  cr_rec.secondary_quantity ,
                      p_unit_of_measure2     =>  cr_rec.secondary_unit_of_measure,
                      p_uom_code1            =>  NULL,
                      p_uom_code2            =>  NULL) = 0 THEN

             l_rec.interface_type     := 'REQIMPORT';
             l_rec.interface_transaction_id := cr_rec.transaction_id;
             l_rec.column_name        := 'SECONDARY_QUANTITY';
             l_rec.table_name         := 'PO_REQUISITIONS_INTERFACE';
             l_rec.error_message      := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,p_encoded => 'F');

             l_progress := '050';

             PO_INTERFACE_ERRORS_GRP.log_error
                 ( p_api_version => 1.0,
                   p_init_msg_list => FND_API.G_TRUE,
                   x_return_status => l_rtn_status,
                   x_msg_count => l_msg_count,
                   x_msg_data => l_msg_data,
                   p_rec => l_rec,
                   x_row_id => l_row_id);

                IF (l_rtn_status <> FND_API.G_RET_STS_SUCCESS) THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
             l_progress := '060';
          END IF; /*NOT INV_CONVERT.within_deviation( */
       END IF; /*cr_rec.secondary_quantity IS NULL*/
    --Since item is not dual um controlled update all secondary attributes to NULL
    /*ELSIF l_tracking_qty_ind = 'P' THEN
       UPDATE po_requisitions_interface
       SET    secondary_quantity = NULL,
              secondary_uom_code = NULL,
              secondary_unit_of_measure = NULL
       WHERE  rowid = cr_rec.rowid;    */
    END IF; /*cr_rec.secondary_unit_of_measure IS NOT NULL*/

    l_progress := '070';
    --Internal Orders
    --Validate that quantity is within deviation for both source and destination organization
    --only if item is dual uom controlled in destination organization
    IF cr_rec.source_type_code = 'INVENTORY' AND
       cr_rec.source_organization_id IS NOT NULL AND
       cr_rec.secondary_unit_of_measure IS NOT NULL THEN

       -- Get Item Attributes for source organization
       BEGIN
          OPEN Cr_item_attr(cr_rec.item_id, cr_rec.source_organization_id);
          FETCH Cr_item_attr INTO  l_tracking_qty_ind_s,
  	       			   l_item_um2_s		,
  	       			   l_secondary_default_ind_s;
          CLOSE Cr_item_attr;
       END;
       l_progress := '080';
       IF l_tracking_qty_ind_s = 'PS' THEN

          IF l_item_um2_s <> l_item_um2 THEN

             l_sec_qty_source := INV_CONVERT.inv_um_convert(
                                        item_id   =>  cr_rec.item_id,
                                        precision =>  6,
                                        from_quantity  => cr_rec.secondary_quantity,
                                        from_unit =>  l_item_um2 ,
                                        to_unit	  =>  l_item_um2_s,
                                        from_name =>  NULL ,
                                        to_name	 =>   NULL
                                         );

             select unit_of_measure
             into   l_unit_of_measure_s
             from   mtl_units_of_measure
             where  uom_code = l_item_um2_s;

             l_progress := '090';

          ELSE
             l_sec_qty_source := cr_rec.secondary_quantity;
             l_unit_of_measure_s := cr_rec.secondary_unit_of_measure;
          END IF;

          IF INV_CONVERT.within_deviation(
                         p_organization_id   	=>  cr_rec.source_organization_id ,
                         p_inventory_item_id    =>  cr_rec.item_id,
                         p_lot_number           =>  null ,
                         p_precision            =>  6 ,
                         p_quantity             =>  cr_rec.quantity,
                         p_unit_of_measure1     =>  cr_rec.unit_of_measure  ,
                         p_quantity2            =>  l_sec_qty_source ,
                         p_unit_of_measure2     =>  l_unit_of_measure_s,
                         p_uom_code1            =>  NULL,
                         p_uom_code2            =>  NULL) = 0 THEN

             l_rec.interface_type     := 'REQIMPORT';
             l_rec.interface_transaction_id := cr_rec.transaction_id;
             l_rec.column_name        := 'SECONDARY_QUANTITY';
             l_rec.table_name         := 'PO_REQUISITIONS_INTERFACE';
             l_rec.error_message_name := 'PO_SRCE_ORG_OUT_OF_DEV';

             l_progress := '100';

             fnd_message.set_name('PO', l_rec.error_message_name);
             l_rec.error_message := FND_MESSAGE.get;

             PO_INTERFACE_ERRORS_GRP.log_error
              ( p_api_version => 1.0,
                p_init_msg_list => FND_API.G_TRUE,
                x_return_status => l_rtn_status,
                x_msg_count => l_msg_count,
                x_msg_data => l_msg_data,
                p_rec => l_rec,
                x_row_id => l_row_id);

             IF (l_rtn_status <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
          END IF; /*NOT INV_CONVERT.within_deviation( */
       END IF; /*l_tracking_qty_ind_s = 'PS'*/
    END IF; /*cr_rec.source_type_code = 'INVENTORY'*/

    l_progress := '110';
  ELSIF cr_rec.item_id IS NULL  THEN
    l_progress := '120';
       --since its a one time item update all process attributes to NULL.
       UPDATE po_requisitions_interface
       SET    secondary_quantity = NULL,
              secondary_uom_code = NULL,
              secondary_unit_of_measure = NULL,
              preferred_grade = NULL
       WHERE  rowid = cr_rec.rowid;
  END IF;
  l_progress := '130';
END LOOP;

EXCEPTION
  WHEN OTHERS THEN
     po_message_s.sql_error('reqimport_def_validate_sec_qty', l_progress, sqlcode);
     RAISE;

END REQIMPORT_DEF_VALIDATE_SEC_QTY;
--<INVCONV R12 END>

END PO_REQIMP_S;


/
