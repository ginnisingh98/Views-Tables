--------------------------------------------------------
--  DDL for Package Body PO_REQIMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQIMP_PKG" AS
/* $Header: jaaupirb.pls 120.5.12010000.2 2008/08/04 14:32:28 vgadde ship $ */

-- ** Declare global variables
l_error_msg          	po_interface_errors.error_message%TYPE ;
l_error_flag            number;
l_index                 NATURAL;

g_count                 NUMBER := 0; -- Bug 3032472 : Counts number of rec in  PO_APPROVED_SUPPLIER_LIST
g_autosource_flag      VARCHAR2(1); -- Bug 3032472 : To handle Min-Max set it to global variable. When Min-Max, 'P' will be populated.

-- ** Declare exceptions
l_incorrect_table       EXCEPTION;
l_null_segment          EXCEPTION;
l_invalid_segment       EXCEPTION;
l_no_rows_updated       EXCEPTION;
l_null_exp_acct         EXCEPTION;
l_update_failure        EXCEPTION;
l_no_data_found         EXCEPTION;



-- *
-- ** Create JA_AU_GET_CONV_RATES procedure
-- *

PROCEDURE JA_AU_GET_CONV_RATES
                       (x_item_id              IN
                        po_requisitions_interface.item_id%TYPE,
                        x_unit_of_purchase     IN
                        po_requisitions_interface.unit_of_measure%TYPE,
                        x_unit_of_measure      IN
                        po_requisitions_interface.unit_of_measure%TYPE,
                        x_to_rate              OUT NOCOPY
                        mtl_uom_conversions.conversion_rate%TYPE,
                        x_item_uom_class       OUT NOCOPY
                        mtl_uom_conversions.uom_class%TYPE,
                        x_from_rate            OUT NOCOPY
                        mtl_uom_conversions.conversion_rate%TYPE,
                        x_from_class           OUT NOCOPY
                        mtl_uom_conversions.uom_class%TYPE)
IS
CURSOR l_conversion_rates
    IS SELECT NVL(t.conversion_rate,0),
              t.uom_class,
              NVL(f.conversion_rate,0),
              f.uom_class
         FROM mtl_uom_conversions t,
              mtl_uom_conversions f
        WHERE t.inventory_item_id IN (x_item_id,0)
          AND t.unit_of_measure = x_unit_of_purchase
          AND f.inventory_item_id IN (x_item_id,0)
          AND f.unit_of_measure = x_unit_of_measure
     ORDER BY t.inventory_item_id desc, f.inventory_item_id desc ;

BEGIN

    OPEN l_conversion_rates ;

    FETCH l_conversion_rates
     INTO x_to_rate,
          x_item_uom_class,
          x_from_rate,
          x_from_class ;

    CLOSE l_conversion_rates ;

EXCEPTION
  WHEN OTHERS THEN NULL;
END JA_AU_GET_CONV_RATES ;


-- *
-- ** Create JA_AU_CONV_PRICE procedure
-- *

PROCEDURE JA_AU_CONV_PRICE
          (
          x_from_rate     IN
          mtl_uom_conversions.conversion_rate%TYPE,
          x_to_rate       IN
          mtl_uom_conversions.conversion_rate%TYPE,
          x_class_rate    IN
          mtl_uom_class_conversions.conversion_rate%TYPE,
          x_unit_price    IN OUT NOCOPY
          po_requisitions_interface.unit_price%TYPE
          )
IS
BEGIN

         x_unit_price := x_unit_price / x_from_rate ;

         x_unit_price := x_unit_price / x_class_rate ;

         if x_to_rate = 0 THEN
            x_unit_price := 0 ;
         ELSE
            x_unit_price := x_unit_price * x_to_rate ;
         END IF ;

         SELECT round(x_unit_price,2)
           INTO x_unit_price
           FROM dual ;

EXCEPTION
  WHEN OTHERS THEN NULL;
END JA_AU_CONV_PRICE;



-- *
-- ** Create JA_AU_GET_CLASS_RATE procedure
-- *

PROCEDURE JA_AU_GET_CLASS_RATE
          (x_item_id         IN
           po_requisitions_interface.item_id%TYPE,
           x_item_uom_class  IN
           mtl_uom_conversions.uom_class%TYPE,
           x_from_class      IN
           mtl_uom_conversions.uom_class%TYPE,
           x_class_rate      OUT NOCOPY
           mtl_uom_class_conversions.conversion_rate%TYPE)
IS
BEGIN

    SELECT nvl(conversion_rate,0)
      INTO x_class_rate
      FROM mtl_uom_class_conversions
     WHERE inventory_item_id = x_item_id
       AND to_uom_class = x_item_uom_class
       AND from_uom_class = x_from_class ;

EXCEPTION
  WHEN OTHERS THEN NULL;
END JA_AU_GET_CLASS_RATE ;


-- *
-- ** Create JA_AU_REORDER_UOM_CONVERT procedure
-- *

PROCEDURE JA_AU_REORDER_UOM_CONVERT
          (x_item_id           IN number,
           x_from_unit         IN po_requisitions_interface.unit_of_measure%TYPE,
           x_to_unit           IN po_requisitions_interface.unit_of_measure%TYPE,
           x_quantity          IN OUT NOCOPY          po_requisitions_interface.quantity%TYPE,
           x_unit_price        IN OUT NOCOPY          po_requisitions_interface.unit_price%TYPE
          )
IS

l_quantity 	  po_requisitions_interface.quantity%TYPE;
l_unit_price 	  po_requisitions_interface.unit_price%TYPE;
l_from_rate       mtl_uom_conversions.conversion_rate%TYPE;
l_to_rate         mtl_uom_conversions.conversion_rate%TYPE;
l_class_rate      mtl_uom_class_conversions.conversion_rate%TYPE;
l_from_class      mtl_uom_conversions.uom_class%TYPE;
l_item_uom_class  mtl_uom_conversions.uom_class%TYPE;
l_dummy           char(1);

BEGIN

    IF x_quantity is null THEN
       x_quantity := 0 ;
    END IF ;

    IF x_unit_price is null THEN
       x_unit_price := 0 ;
    END IF ;

    l_quantity := x_quantity ;
    l_unit_price := x_unit_price ;
    l_from_rate := 1;
    l_to_rate := 1;
    l_class_rate := 1 ;


    IF x_to_unit = x_from_unit THEN
       -- Bug 3032472 : Min-Max is treated differently.
       -- need rounding when from/to uom are same
       IF g_autosource_flag = 'P' THEN
	      GOTO round_qty;
       ELSE
	  -- this is the original logic from 11
          GOTO end_proc;
       END IF;

    END IF;


    JA_AU_get_conv_rates(x_item_id,
                        x_to_unit,
                        x_from_unit,
                        l_to_rate,
                        l_item_uom_class,
                        l_from_rate,
                        l_from_class) ;


    IF l_from_class = l_item_uom_class THEN
       GOTO calculate ;
    ELSE
       JA_AU_get_class_rate(x_item_id,
                           l_item_uom_class,
                           l_from_class,
                           l_class_rate) ;
    END IF ;


<<calculate>>

    l_quantity := l_from_rate * x_quantity ;


    l_quantity := l_quantity / l_class_rate ;

    if l_to_rate = 0 THEN
       GOTO set_qty_zero ;
    ELSE
       l_quantity := l_quantity / l_to_rate ;


       GOTO calculate_unit_price ;
    END IF ;

<<set_qty_zero>>

    l_quantity := 0 ;

<<calculate_unit_price>>

-- *
-- ** Convert price
-- *

       JA_AU_conv_price(l_from_rate,
                       l_to_rate,
                       l_class_rate,
                       l_unit_price );

<<round_qty>>


    SELECT ceil(l_quantity)
      INTO l_quantity
      FROM dual ;

<<end_proc>>

    -- Bug 3032472
    IF g_count <> 0 THEN
      -- ASL is used
      x_quantity := l_quantity * l_to_rate / l_from_rate;

    ELSE
      x_quantity := l_quantity ;
    END IF;

    x_unit_price := l_unit_price ;

EXCEPTION
  WHEN OTHERS THEN NULL;
END JA_AU_REORDER_UOM_CONVERT ;


-- +=======================================================================+
-- | Procedure Name: JA_AU_PRICE_BREAK
-- |    Description: Gets best price break from quotation for a qty
-- |      Arguments: IN  : x_po_line_id
-- |                       x_unit_of_purchase
-- |                       x_quantity
-- |                 OUT : x_unit_price
-- +=======================================================================+

PROCEDURE JA_AU_PRICE_BREAK
          (x_po_line_id       IN  po_lines.po_line_id%TYPE,
           x_unit_of_purchase IN  po_line_locations.unit_meas_lookup_code%TYPE,
           x_quantity         IN  po_line_locations.quantity%TYPE,
           x_unit_price       OUT NOCOPY po_line_locations.price_override%TYPE)
IS

CURSOR l_price_break
    IS SELECT poll.price_override
         FROM po_line_locations poll
        WHERE price_override is not null
          AND sysdate between nvl(start_date,sysdate-1)
                          and nvl(end_date,sysdate+1)
          AND (poll.quantity is null
               OR
               poll.quantity <= x_quantity)
          AND unit_meas_lookup_code = x_unit_of_purchase
          AND po_line_id = x_po_line_id
          -- Bug : 4236157
          AND poll.shipment_type <> 'PREPAYMENT'
     ORDER BY price_override asc ;

BEGIN

    OPEN l_price_break ;

    FETCH l_price_break INTO x_unit_price ;

    CLOSE l_price_break ;


EXCEPTION
  WHEN OTHERS THEN NULL;
END JA_AU_PRICE_BREAK ;


-- *
-- ** Create JA_AU_SUGGESTED_DOCUMENT procedure
-- *

PROCEDURE JA_AU_SUGGESTED_DOCUMENT
          (x_item_id                 IN po_requisitions_interface.item_id%TYPE,
           x_document_header_id      OUT NOCOPY po_requisitions_interface.autosource_doc_header_id%TYPE,
           x_document_line_num       OUT NOCOPY po_requisitions_interface.autosource_doc_line_num%TYPE,
           x_po_line_id              OUT NOCOPY po_lines.po_line_id%TYPE,
           x_vendor_product_number   OUT NOCOPY po_requisitions_interface.suggested_vendor_item_num%TYPE ,
           x_vendor_id               OUT NOCOPY po_requisitions_interface.suggested_vendor_id%TYPE ,
           x_vendor_site_id          OUT NOCOPY po_requisitions_interface.suggested_vendor_site_id%TYPE ,
           x_vendor_contact_id       OUT NOCOPY po_requisitions_interface.suggested_vendor_contact_id%TYPE ,
           x_vendor_name             OUT NOCOPY po_requisitions_interface.suggested_vendor_name%TYPE ,
           x_vendor_site_code        OUT NOCOPY po_requisitions_interface.suggested_vendor_site%TYPE ,
           x_unit_price              OUT NOCOPY po_requisitions_interface.unit_price%TYPE ,
           x_unit_of_purchase        OUT NOCOPY po_lines.unit_meas_lookup_code%TYPE        ,
           x_suggested_vendor_id        IN po_requisitions_interface.suggested_vendor_id%TYPE        ,
           x_suggested_vendor_site_id   IN po_requisitions_interface.suggested_vendor_site_id%TYPE
          )
IS

CURSOR l_suggested_document IS
SELECT pad.document_header_id,
       pol.line_num,
       pol.po_line_id,
       pol.vendor_product_num,
       poh.vendor_id,
       poh.vendor_site_id ,
       poh.vendor_contact_id,
       pov.vendor_name,
       povs.vendor_site_code,
       nvl(pol.unit_price,0),
       pol.unit_meas_lookup_code
  FROM po_autosource_documents pad,
       po_headers poh,
       po_lines pol,
       po_vendors pov,
       po_vendor_sites povs,
       po_autosource_vendors ven,
       po_autosource_rules rul
 WHERE pad.autosource_rule_id = rul.autosource_rule_id
   AND pad.vendor_id = ven.vendor_id
   AND ven.autosource_rule_id = rul.autosource_rule_id
   AND ven.autosource_rule_id = pad.autosource_rule_id
   AND pad.document_header_id = poh.po_header_id
   AND pad.document_line_id   = pol.po_line_id
   AND  ((    poh.type_lookup_code = 'BLANKET'
              AND poh.approved_flag    = 'Y'
              AND nvl(poh.frozen_flag,'N') = 'N'
              AND nvl(poh.cancel_flag,'N') = 'N'
              AND nvl(pol.cancel_flag,'N') = 'N')
              OR
          (   poh.type_lookup_code = 'QUOTATION'
              AND poh.status_lookup_code = 'A'))
   AND poh.vendor_id = pov.vendor_id
   AND poh.vendor_site_id = povs.vendor_site_id(+)
   AND poh.vendor_id  = povs.vendor_id(+)
   AND SYSDATE between nvl(poh.start_date, SYSDATE)
   AND nvl(poh.end_date, SYSDATE+1)
   AND rul.item_id = x_item_id
   AND sysdate between  nvl(rul.start_date, sysdate)
   AND nvl(rul.end_date, sysdate+1)
ORDER BY vendor_rank asc, sequence_num ;


-- Bug 3032472 : To support ASL
CURSOR l_asl_document IS
   SELECT paa.purchasing_unit_of_measure,
          pl.UNIT_MEAS_LOOKUP_CODE,
          pl.unit_price,
          ph.po_header_id,
          pl.line_num,
          pl.po_line_id,
          pl.unit_price
   FROM   po_approved_supplier_list pasl,
          po_vendors pv,
	      po_vendor_sites_all pvs,
	      po_asl_attributes paa,
	      po_asl_documents pad,
	      po_headers_all ph,
 	      po_lines_all pl,
          mrp_sr_source_org msso
   WHERE  pvs.vendor_site_id = pasl.vendor_site_id
   AND    pv.vendor_id = pasl.vendor_id
   AND    pasl.item_id = x_item_id
   AND    pasl.asl_id = paa.asl_id
   AND    pasl.asl_id = pad.asl_id
   AND    ph.po_header_id = pl.po_header_id
   AND  ((    ph.type_lookup_code = 'BLANKET'
	       AND ph.approved_flag    = 'Y'
               AND nvl(ph.frozen_flag,'N') = 'N'
	       AND nvl(ph.cancel_flag,'N') = 'N'
	       AND nvl(pl.cancel_flag,'N') = 'N')
	   OR
	  (   ph.type_lookup_code = 'QUOTATION'
	      AND ph.status_lookup_code = 'A'))
   AND    ph.po_header_id = pad.document_header_id
   AND SYSDATE between nvl(ph.start_date, SYSDATE) AND nvl(ph.end_date, SYSDATE+1)
   AND pl.item_id = x_item_id
   AND msso.vendor_id = pv.vendor_id
   AND (pasl.disable_flag IS NULL OR pasl.disable_flag = 'N')
   ORDER BY msso.allocation_percent desc, msso.rank, pad.sequence_num;   -- Added allocation_percent

-- Bug 3032472
l_unit_of_purchase_asl  po_asl_attributes.purchasing_unit_of_measure%TYPE;

-- Bug 5576820
CURSOR l_asl_document_new IS
   SELECT paa.purchasing_unit_of_measure,
          pl.UNIT_MEAS_LOOKUP_CODE,
          pl.unit_price,
          ph.po_header_id,
          pl.line_num,
          pl.po_line_id,
          pl.unit_price
   FROM   po_approved_supplier_list pasl,
          po_vendors pv,
	      po_vendor_sites_all pvs,
	      po_asl_attributes paa,
	      po_asl_documents pad,
	      po_headers_all ph,
 	      po_lines_all pl,
          mrp_sr_source_org msso
   WHERE  pvs.vendor_site_id = pasl.vendor_site_id
   AND    pv.vendor_id = pasl.vendor_id
   AND    pasl.item_id = x_item_id
   AND    pasl.asl_id = paa.asl_id
   AND    pasl.asl_id = pad.asl_id
   AND    ph.po_header_id = pl.po_header_id
   AND  ((    ph.type_lookup_code = 'BLANKET'
	       AND ph.approved_flag    = 'Y'
               AND nvl(ph.frozen_flag,'N') = 'N'
	       AND nvl(ph.cancel_flag,'N') = 'N'
	       AND nvl(pl.cancel_flag,'N') = 'N')
	   OR
	  (   ph.type_lookup_code = 'QUOTATION'
	      AND ph.status_lookup_code = 'A'))
   AND    ph.po_header_id = pad.document_header_id
   AND SYSDATE between nvl(ph.start_date, SYSDATE) AND nvl(ph.end_date, SYSDATE+1)
   AND pl.item_id = x_item_id
   AND msso.vendor_id = pv.vendor_id
   AND (pasl.disable_flag IS NULL OR pasl.disable_flag = 'N')
   AND pv.vendor_id = x_suggested_vendor_id
   AND pvs.vendor_site_id = x_suggested_vendor_site_id
   ORDER BY msso.allocation_percent desc, msso.rank, pad.sequence_num;   -- Added allocation_percent



BEGIN
    IF g_count <> 0 THEN
       if x_suggested_vendor_id is not null and
          x_suggested_vendor_site_id is not null then
       OPEN l_asl_document_new;
       FETCH l_asl_document_new into l_unit_of_purchase_asl,  -- unit of purchase at asl
                                 x_unit_of_purchase,      -- unit of purchase at line
                                 x_unit_price,            -- unit price
                                 x_document_header_id,    -- po_header_id
                                 x_document_line_num,      -- po_line_num
                                 x_po_line_id,             -- po_line_id
                                 x_unit_price;             -- po_line.unit_price

       CLOSE l_asl_document_new;
       else
       OPEN l_asl_document;
       FETCH l_asl_document into l_unit_of_purchase_asl,  -- unit of purchase at asl
                                 x_unit_of_purchase,      -- unit of purchase at line
                                 x_unit_price,            -- unit price
                                 x_document_header_id,    -- po_header_id
                                 x_document_line_num,      -- po_line_num
                                 x_po_line_id,             -- po_line_id
                                 x_unit_price;             -- po_line.unit_price

       CLOSE l_asl_document;
       end if;

       -- x_document_line_num := 1; -- Put dummy number so that ja_au_autosource handles well.

    ELSE
      OPEN l_suggested_document ;

      FETCH l_suggested_document
       INTO x_document_header_id,
            x_document_line_num,
            x_po_line_id,
            x_vendor_product_number,
            x_vendor_id,
            x_vendor_site_id ,
            x_vendor_contact_id,
            x_vendor_name,
            x_vendor_site_code,
            x_unit_price,
            x_unit_of_purchase  ;

      CLOSE l_suggested_document ;
    END IF;

EXCEPTION
  WHEN OTHERS THEN NULL;
END JA_AU_SUGGESTED_DOCUMENT ;




-- *
-- ** Create JA_AU_AUTOSOURCE procedure
-- *

PROCEDURE JA_AU_AUTOSOURCE
(
 x_item_id IN                    po_requisitions_interface.item_id%TYPE,
 x_organization_id IN            po_requisitions_interface.source_organization_id%TYPE,
 x_quantity IN OUT NOCOPY        po_requisitions_interface.quantity%TYPE,
 x_uom_code IN OUT NOCOPY        po_requisitions_interface.uom_code%TYPE,
 x_unit_of_measure IN OUT NOCOPY po_requisitions_interface.unit_of_measure%TYPE,
 x_rowid IN                      po_requisitions_interface.unit_of_measure%TYPE,
 x_autosource_doc_header_id IN   po_requisitions_interface.autosource_doc_header_id%TYPE,
 x_autosource_doc_line_num IN    po_requisitions_interface.autosource_doc_line_num%TYPE,
 x_suggested_vendor_id IN        po_requisitions_interface.suggested_vendor_id%TYPE,
 x_suggested_vendor_site_id IN   po_requisitions_interface.suggested_vendor_site_id%TYPE
)
IS
 l_document_header_id    po_requisitions_interface.autosource_doc_header_id%TYPE;
 l_document_line_num     po_requisitions_interface.autosource_doc_line_num%TYPE;
 l_vendor_id             po_requisitions_interface.suggested_vendor_id%TYPE ;
 l_vendor_site_id        po_requisitions_interface.suggested_vendor_site_id%TYPE ;
 l_vendor_contact_id     po_requisitions_interface.suggested_vendor_contact_id%TYPE ;
 l_vendor_product_number    po_requisitions_interface.suggested_vendor_item_num%TYPE ;
 l_unit_of_purchase         po_requisitions_interface.unit_of_measure%TYPE ;
 l_unit_of_measure          po_requisitions_interface.unit_of_measure%TYPE ;
 l_uom_code                 po_requisitions_interface.uom_code%TYPE ;
 l_unit_price               po_requisitions_interface.unit_price%TYPE ;
 l_quote_line_price         po_requisitions_interface.unit_price%TYPE ;
 l_vendor_name              po_requisitions_interface.suggested_vendor_name%TYPE ;
 l_vendor_site_code         po_requisitions_interface.suggested_vendor_site%TYPE ;
 l_po_line_id               po_lines.po_line_id%TYPE;
 l_dummy                    char(1);
 l_dummy2                   po_requisitions_interface.unit_price%TYPE ;
 l_uom_direct         varchar2(30);

BEGIN

    l_document_header_id    := 0;
    l_unit_price            := 0;
    l_quote_line_price      := 0;
    l_document_line_num     := 0;
    l_vendor_id             := 0;
    l_vendor_site_id        := 0;
    l_vendor_site_code      := null;
    l_vendor_name           := null;
    l_vendor_product_number := null;
    l_unit_of_purchase      := null;

    if x_unit_of_measure is null THEN

       SELECT unit_of_measure
         INTO l_unit_of_measure
         FROM mtl_units_of_measure
        WHERE uom_code = x_uom_code ;

    ELSE

       l_unit_of_measure := x_unit_of_measure ;
       l_uom_code := x_uom_code ;

    END IF ;

    SELECT count(*) INTO g_count FROM PO_APPROVED_SUPPLIER_LIST;


    if x_autosource_doc_header_id is not null and
       x_autosource_doc_line_num is not null then
            select unit_meas_lookup_code
              into l_uom_direct
              from po_lines_all
             where po_header_id = x_autosource_doc_header_id
               and line_num = x_autosource_doc_line_num;
    end if;


    JA_AU_suggested_document(x_item_id,
                            l_document_header_id,
                            l_document_line_num,
                            l_po_line_id,
                            l_vendor_product_number,
                            l_vendor_id,
                            l_vendor_site_id,
                            l_vendor_contact_id,
                            l_vendor_name,
                            l_vendor_site_code,
                            l_unit_price,
                            l_unit_of_purchase,
                            x_suggested_vendor_id,
                            x_suggested_vendor_site_id);


    if l_uom_direct is not null then
      l_unit_of_purchase := l_uom_direct;
    end if;

    if l_unit_of_purchase is not null THEN

       SELECT uom_code
         INTO l_uom_code
         FROM mtl_units_of_measure
        WHERE unit_of_measure = l_unit_of_purchase ;

    ELSE

       l_unit_of_purchase := l_unit_of_measure ;

    END IF ;
    if x_autosource_doc_header_id is not null and
       x_autosource_doc_line_num is not null then
         l_document_line_num := x_autosource_doc_line_num;
    end if;

    IF l_document_line_num is null or l_document_line_num = 0 THEN
       SELECT list_price_per_unit
         INTO l_unit_price
         FROM mtl_system_items
        WHERE inventory_item_id = x_item_id
          AND organization_id = x_organization_id ;

       UPDATE po_requisitions_interface
          SET unit_price = l_unit_price
        WHERE rowid = x_rowid ;

       COMMIT WORK ;
    ELSE
       l_dummy2 := 0 ;

       JA_AU_reorder_uom_convert(x_item_id,
                                l_unit_of_measure,
                                l_unit_of_purchase,
                                x_quantity,
                                l_dummy2 ) ;

       l_quote_line_price := l_unit_price ;

       JA_AU_price_break(l_po_line_id,
                        l_unit_of_purchase,
                        x_quantity,
                        l_unit_price) ;

       IF l_unit_price is null THEN
           l_unit_price := l_quote_line_price  ;
       END IF;

       -- Bug 3032472
       IF g_count <> 0 THEN
         UPDATE po_requisitions_interface
         SET quantity = x_quantity
             -- uom_code = l_uom_code,
             -- unit_of_measure = l_unit_of_purchase
         WHERE rowid = x_rowid;
       ELSE
         UPDATE po_requisitions_interface
            SET unit_of_measure             = l_unit_of_purchase,
                uom_code                    = l_uom_code,
                unit_price                  = l_unit_price,
                quantity                    = x_quantity,
                autosource_doc_header_id    = l_document_header_id,
                autosource_doc_line_num     = l_document_line_num,
                suggested_vendor_name       = l_vendor_name,
                suggested_vendor_id         = l_vendor_id,
                suggested_vendor_site       = l_vendor_site_code,
                suggested_vendor_site_id    = l_vendor_site_id,
                suggested_vendor_contact_id = l_vendor_contact_id,
                suggested_vendor_contact    = null,
                suggested_vendor_phone      = null,
                suggested_vendor_item_num   = l_vendor_product_number
          WHERE rowid = x_rowid ;
       END IF;

       COMMIT WORK ;

    END IF ;


EXCEPTION
  WHEN OTHERS THEN NULL;
END JA_AU_AUTOSOURCE ;


-- *
-- ** Create JA_AU_UOI_CONVERSION procedure
-- *

PROCEDURE JA_AU_UOI_CONVERSION
          (x_item_id                 IN
           po_requisitions_interface.item_id%TYPE,
           x_source_organization_id  IN
           po_requisitions_interface.source_organization_id%TYPE,
           x_quantity                IN
           po_requisitions_interface.quantity%TYPE,
           x_unit_price              IN
           po_requisitions_interface.unit_price%TYPE,
           x_unit_of_measure         IN
           po_requisitions_interface.unit_of_measure%TYPE,
           x_rowid                   IN
           po_requisitions_interface.unit_of_measure%TYPE
          )
IS

l_quantity
po_requisitions_interface.quantity%TYPE;
l_unit_price
po_requisitions_interface.unit_price%TYPE;
l_unit_of_issue
po_requisitions_interface.unit_of_measure%TYPE;
l_uoi_code
po_requisitions_interface.uom_code%TYPE;

BEGIN

    SELECT nvl(unit_of_issue,primary_unit_of_measure)
      INTO l_unit_of_issue
      FROM mtl_system_items
     WHERE inventory_item_id = x_item_id
       AND organization_id = x_source_organization_id ;


     IF x_unit_of_measure <> l_unit_of_issue THEN


            l_quantity := x_quantity ;
            l_unit_price := x_unit_price ;

            JA_AU_reorder_uom_convert(x_item_id,
                                     x_unit_of_measure,
                                     l_unit_of_issue,
                                     l_quantity,
                                     l_unit_price );


            SELECT uom_code
              INTO l_uoi_code
              FROM mtl_units_of_measure
             WHERE unit_of_measure = l_unit_of_issue ;

            UPDATE po_requisitions_interface
               SET unit_of_measure = l_unit_of_issue,
                   uom_code = l_uoi_code,
                   quantity = l_quantity,
                   unit_price = l_unit_price
             WHERE rowid = x_rowid  ;

            COMMIT WORK ;

     END IF ;


EXCEPTION
  WHEN OTHERS THEN NULL;
END JA_AU_UOI_CONVERSION;



-- *
-- ** Create JA_AU_UPDATE_ERRORS procedure
-- *

PROCEDURE JA_AU_UPDATE_ERRORS
          (x_rowid      	IN
		varchar2,
           x_transaction_id	IN
		po_requisitions_interface.transaction_id%TYPE)
IS
BEGIN

     UPDATE po_requisitions_interface
        SET charge_account_id = 0,
	    request_id = NULL,
            process_flag = 'ERROR'
      WHERE rowid = x_rowid;

     IF SQL%NOTFOUND THEN
          RAISE l_update_failure;
     END IF;

     INSERT INTO po_interface_errors
	(
	 interface_type,
	 interface_transaction_id,
	 error_message,
	 processing_date,
	 creation_date,
	 created_by,
 	 last_update_date,
	 last_updated_by
	)
     VALUES
	(
	 'REQIMPORT',
	 x_transaction_id,
	 l_error_msg,
	 sysdate,
	 sysdate,
	 -1,
	 sysdate,
	 -1
	);

EXCEPTION
     WHEN l_update_failure THEN
--          DBMS_OUTPUT.NEW_LINE;
--          DBMS_OUTPUT.PUT('*** UPDATE FAILURE in JA_AU_UPDATE_ERRORS ***');
--          DBMS_OUTPUT.NEW_LINE;
--          DBMS_OUTPUT.PUT(SQLERRM);
--          DBMS_OUTPUT.NEW_LINE;
          null;
     WHEN OTHERS THEN
--          DBMS_OUTPUT.NEW_LINE;
--          DBMS_OUTPUT.PUT('*** ERROR in JA_AU_UPDATE_ERRORS ***');
--          DBMS_OUTPUT.NEW_LINE;
--          DBMS_OUTPUT.PUT(SQLERRM);
--          DBMS_OUTPUT.NEW_LINE;
          null;
END JA_AU_UPDATE_ERRORS;


-- *
-- ** Create JA_AU_GET_COA_SOB procedure
-- *

PROCEDURE JA_AU_GET_COA_SOB
          (x_rowid              IN
           varchar2,
           x_transaction_id     IN
           po_requisitions_interface.transaction_id%TYPE,
           x_org_id             IN
           org_organization_definitions.organization_id%TYPE,
           x_chart_of_accts_id  OUT NOCOPY
           org_organization_definitions.chart_of_accounts_id%TYPE,
           x_set_of_books_id    OUT NOCOPY
           org_organization_definitions.set_of_books_id%TYPE)
IS
BEGIN

     SELECT chart_of_accounts_id, set_of_books_id
     INTO x_chart_of_accts_id, x_set_of_books_id
     FROM org_organization_definitions
     WHERE organization_id = x_org_id
     AND nvl(disable_date, sysdate+1) > sysdate ;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
          l_error_msg := 'AUTOGL ERROR - Could not retrieve chart_of_accounts_id and/or set_of_books_id.';
          l_error_flag := -1;
          JA_AU_update_errors(x_rowid,x_transaction_id);
     WHEN OTHERS THEN
          l_error_flag := -1;
--          DBMS_OUTPUT.NEW_LINE;
--          DBMS_OUTPUT.PUT('*** ERROR in JA_AU_GET_COA_SOB ***');
--          DBMS_OUTPUT.NEW_LINE;
--          DBMS_OUTPUT.PUT(SQLERRM);
--          DBMS_OUTPUT.NEW_LINE;

END JA_AU_GET_COA_SOB;


-- *
-- ** Create JA_AU_GET_REPLN_EXP_ACCTS procedure
-- *

PROCEDURE JA_AU_GET_REPLN_EXP_ACCTS
          (x_rowid              IN
           varchar2,
           x_transaction_id     IN
           po_requisitions_interface.transaction_id%TYPE,
           x_org_id             IN
           org_organization_definitions.organization_id%TYPE,
           x_subinv             IN
           mtl_secondary_inventories.secondary_inventory_name%TYPE,
           x_item_id            IN
           mtl_system_items.inventory_item_id%TYPE,
           x_subinv_ccid        IN OUT NOCOPY
           mtl_secondary_inventories.expense_account%TYPE,
           x_item_ccid          IN OUT NOCOPY
           mtl_system_items.expense_account%TYPE)
IS
BEGIN

     l_error_msg := 'AUTOGL ERROR - Could not retrieve subinventory expense_account';

     SELECT nvl(expense_account, -1)
     INTO x_subinv_ccid
     FROM mtl_secondary_inventories
     WHERE organization_id = x_org_id
     AND secondary_inventory_name = x_subinv ;

     IF x_subinv_ccid = -1 THEN
          l_error_msg := 'AUTOGL ERROR - Subinventory expense_account was NULL';
          RAISE l_null_exp_acct;
     END IF;

     l_error_msg := 'AUTOGL ERROR - Could not retrieve item expense_account';

     SELECT nvl(expense_account, -1)
     INTO x_item_ccid
     FROM mtl_system_items
     WHERE organization_id = x_org_id
     AND inventory_item_id = x_item_id ;

     IF x_item_ccid = -1 THEN
          l_error_msg := 'AUTOGL ERROR - Item expense_account was NULL';
          RAISE l_null_exp_acct;
     END IF;

     l_error_msg := null;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
          JA_AU_update_errors(x_rowid,x_transaction_id);
          l_error_flag := -1;
     WHEN l_null_exp_acct THEN
          JA_AU_update_errors(x_rowid,x_transaction_id);
          l_error_flag := -1;
     WHEN OTHERS THEN
          l_error_flag := -1;
--          DBMS_OUTPUT.NEW_LINE;
--          DBMS_OUTPUT.PUT('*** ERROR in JA_AU_GET_REPLN_EXP_ACCTS ***');
--          DBMS_OUTPUT.NEW_LINE;
--          DBMS_OUTPUT.PUT(SQLERRM);
--          DBMS_OUTPUT.NEW_LINE;

END JA_AU_GET_REPLN_EXP_ACCTS;


-- *
-- ** Create JA_AU_GET_VALUE function
-- *

FUNCTION JA_AU_GET_VALUE
         (x_rowid       IN
          varchar2,
          x_transaction_id     IN
          po_requisitions_interface.transaction_id%TYPE,
          x_ccid                IN
          gl_code_combinations.code_combination_id%TYPE,
          x_segment     IN
          gl_code_combinations.segment1%TYPE)
RETURN gl_code_combinations.segment1%TYPE IS

l_value         gl_code_combinations.segment1%TYPE;

BEGIN

     IF SUBSTR(x_segment,1,9) = 'SEGMENT30' THEN
          SELECT nvl(segment30,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,9) = 'SEGMENT29' THEN
          SELECT nvl(segment29,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,9) = 'SEGMENT28' THEN
          SELECT nvl(segment28,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,9) = 'SEGMENT27' THEN
          SELECT nvl(segment27,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,9) = 'SEGMENT26' THEN
          SELECT nvl(segment26,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,9) = 'SEGMENT25' THEN
          SELECT nvl(segment25,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,9) = 'SEGMENT24' THEN
          SELECT nvl(segment24,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,9) = 'SEGMENT23' THEN
          SELECT nvl(segment23,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,9) = 'SEGMENT22' THEN
          SELECT nvl(segment22,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,9) = 'SEGMENT21' THEN
          SELECT nvl(segment21,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,9) = 'SEGMENT20' THEN
          SELECT nvl(segment20,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,9) = 'SEGMENT19' THEN
          SELECT nvl(segment19,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,9) = 'SEGMENT18' THEN
          SELECT nvl(segment18,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,9) = 'SEGMENT17' THEN
          SELECT nvl(segment17,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,9) = 'SEGMENT16' THEN
          SELECT nvl(segment16,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,9) = 'SEGMENT15' THEN
          SELECT nvl(segment15,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,9) = 'SEGMENT14' THEN
          SELECT nvl(segment14,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,9) = 'SEGMENT13' THEN
          SELECT nvl(segment13,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,9) = 'SEGMENT12' THEN
          SELECT nvl(segment12,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,9) = 'SEGMENT11' THEN
          SELECT nvl(segment11,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,9) = 'SEGMENT10' THEN
          SELECT nvl(segment10,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,8) = 'SEGMENT9' THEN
          SELECT nvl(segment9,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,8) = 'SEGMENT8' THEN
          SELECT nvl(segment8,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,8) = 'SEGMENT7' THEN
          SELECT nvl(segment7,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,8) = 'SEGMENT6' THEN
          SELECT nvl(segment6,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,8) = 'SEGMENT5' THEN
          SELECT nvl(segment5,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,8) = 'SEGMENT4' THEN
          SELECT nvl(segment4,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,8) = 'SEGMENT3' THEN
          SELECT nvl(segment3,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,8) = 'SEGMENT2' THEN
          SELECT nvl(segment2,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,8) = 'SEGMENT1' THEN
          SELECT nvl(segment1,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSE
          RAISE l_invalid_segment;
     END IF;

     IF l_value = '!@' THEN
          RAISE l_null_segment;
     END IF;

     return(l_value);

EXCEPTION
     WHEN l_invalid_segment THEN
          l_error_msg := 'AUTOGL ERROR - Incorrect AutoAccounting setup - Invalid Segment';
          JA_AU_update_errors(x_rowid,x_transaction_id);
     WHEN l_null_segment THEN
          l_error_msg := 'AUTOGL ERROR - Segment value in GL_CODE_COMBINATIONS is null';
          JA_AU_update_errors(x_rowid,x_transaction_id);
     WHEN NO_DATA_FOUND THEN
          l_error_msg := 'AUTOGL ERROR - Could not retrieve segment value from GL_CODE_COMBINATIONS.';
          JA_AU_update_errors(x_rowid,x_transaction_id);
     WHEN OTHERS THEN
--          DBMS_OUTPUT.NEW_LINE;
--          DBMS_OUTPUT.PUT('*** ERROR in JA_AU_GET_VALUE ***');
--          DBMS_OUTPUT.NEW_LINE;
--          DBMS_OUTPUT.PUT(SQLERRM);
--          DBMS_OUTPUT.NEW_LINE;
          null;

END JA_AU_GET_VALUE;


-- *
-- ** Create JA_AU_GET_SEGMENT_VALUE function
-- *

FUNCTION JA_AU_GET_SEGMENT_VALUE
         (x_rowid               IN
          varchar2,
          x_transaction_id     IN
          po_requisitions_interface.transaction_id%TYPE,
          x_table_name          IN
          JA_AU_ACCT_DEFAULT_SEGS.table_name%TYPE,
          x_constant            IN
          JA_AU_ACCT_DEFAULT_SEGS.constant%TYPE,
          x_segment             IN
          JA_AU_ACCT_DEFAULT_SEGS.segment%TYPE,
          x_subinv_ccid         IN
          mtl_secondary_inventories.expense_account%TYPE,
          x_item_ccid           IN
          mtl_system_items.expense_account%TYPE)
RETURN gl_code_combinations.segment1%TYPE IS

l_value         gl_code_combinations.segment1%TYPE;

BEGIN

     IF SUBSTR(x_constant,1,2) = '!~' THEN /* Not a constant */
          IF x_table_name = 'MTL_SECONDARY_INVENTORIES' THEN
               l_value := JA_AU_get_value(x_rowid,
					 x_transaction_id,
                                         x_subinv_ccid,
                                         x_segment);
          ELSIF x_table_name = 'MTL_SYSTEM_ITEMS' THEN
               l_value := JA_AU_get_value(x_rowid,
					 x_transaction_id,
                                         x_item_ccid,
                                         x_segment);
          ELSE
               l_value := '0';
               RAISE l_incorrect_table;
          END IF;
     ELSE
           l_value := RTRIM(SUBSTR(x_constant,1,25));
     END IF;

     return(l_value);

EXCEPTION
     WHEN l_incorrect_table THEN
          l_error_msg := 'AUTOGL ERROR - Incorrect AutoAccounting setup - Invalid Table.';
          JA_AU_update_errors(x_rowid,x_transaction_id);
          l_error_flag := -1;
          return(l_value);
     WHEN OTHERS THEN
          l_error_flag := -1;
--          DBMS_OUTPUT.NEW_LINE;
--          DBMS_OUTPUT.PUT('*** ERROR in JA_AU_GET_SEGMENT_VALUE ***');
--          DBMS_OUTPUT.NEW_LINE;
--          DBMS_OUTPUT.PUT(SQLERRM);
--          DBMS_OUTPUT.NEW_LINE;
          return(l_value);

END JA_AU_GET_SEGMENT_VALUE;

-- *
-- ** Create JA_AU_UPDATE_REQINTERFACE procedure
-- *

PROCEDURE JA_AU_UPDATE_REQINTERFACE
          (x_rowid      IN
           varchar2,
           x_transaction_id     IN
           po_requisitions_interface.transaction_id%TYPE,
           x_ccid       IN
           gl_code_combinations.code_combination_id%TYPE)
IS
BEGIN

     UPDATE po_requisitions_interface
        SET charge_account_id = x_ccid
      WHERE rowid = x_rowid;

     IF SQL%NOTFOUND THEN
          RAISE l_no_rows_updated;
     END IF;

     COMMIT WORK;

EXCEPTION
     WHEN l_no_rows_updated THEN
--          DBMS_OUTPUT.NEW_LINE;
--          DBMS_OUTPUT.PUT('*** Failed to update PO_REQUISITIONS_INTERFACE ***');
--          DBMS_OUTPUT.NEW_LINE;
--          DBMS_OUTPUT.PUT(SQLERRM);
--          DBMS_OUTPUT.NEW_LINE;
          l_error_msg := 'AUTOGL ERROR - Update of charge_account_id in po_requisitions_interface failed.';
          JA_AU_update_errors(x_rowid,x_transaction_id);
     WHEN OTHERS THEN
--          DBMS_OUTPUT.NEW_LINE;
--          DBMS_OUTPUT.PUT('*** ERROR in JA_AU_UPDATE_REQINTERFACE ***');
--          DBMS_OUTPUT.NEW_LINE;
--          DBMS_OUTPUT.PUT(SQLERRM);
--          DBMS_OUTPUT.NEW_LINE;
          null;
END JA_AU_UPDATE_REQINTERFACE;



-- *
-- ** Create JA_AU_AUTOACCOUNTING procedure
-- *
-- +=======================================================================+
-- |    This procedure will obtain the code_combination_id from the table
-- | GL_CODE_COMBINATIONS for the given item and subinventory. It will store
-- | the code_combination_id in the charge_account_id column of the table
-- | PO_REQUISITIONS_INTERFACE.
-- |    Any errors will be flagged by inserting a record in PO_INTERFACE_ERRORS
-- |    Possible errors are :
-- |     AUTOGL ERROR - Could not retrieve chart_of_accounts_id and/or
-- |		     set_of_books_id.
-- |     AUTOGL ERROR - Could not retrieve subinventory expense_account.
-- |     AUTOGL ERROR - Subinventory expense_account was NULL.
-- |     AUTOGL ERROR - Could not retrieve item expense_account.
-- |     AUTOGL ERROR - Item expense_account was NULL.
-- |     AUTOGL ERROR - Incorrect AutoAccounting setup - Invalid Table.
-- |     AUTOGL ERROR - Segment value in GL_CODE_COMBINATIONS is null.
-- |     AUTOGL ERROR - Incorrect AutoAccounting setup - Invalid Segment
-- |     AUTOGL ERROR - Could not retrieve segment value from GL_CODE_COMBINATIONS.
-- |     AUTOGL ERROR - Update of charge_account_id in po_requisitions_interface
-- |		     failed.
-- |     AUTOGL ERROR - Could not obtain or create CODE_COMBINATION_ID
-- +=======================================================================+

PROCEDURE JA_AU_AUTOACCOUNTING
          (x_rowid      	IN
           varchar2,
           x_org_id     	IN
           po_requisitions_interface.destination_organization_id%TYPE,
           x_subinv     	IN
           po_requisitions_interface.destination_subinventory%TYPE,
           x_item_id    	IN
           po_requisitions_interface.item_id%TYPE,
	   l_transaction_id    	IN
     	   po_requisitions_interface.transaction_id%TYPE)

IS

l_chart_of_accts_id     org_organization_definitions.organization_id%TYPE;
l_set_of_books_id       org_organization_definitions.set_of_books_id%TYPE;
l_subinv_ccid           mtl_secondary_inventories.expense_account%TYPE;
l_item_ccid             mtl_system_items.expense_account%TYPE;
l_table_name            JA_AU_ACCT_DEFAULT_SEGS.table_name%TYPE;
l_constant              JA_AU_ACCT_DEFAULT_SEGS.constant%TYPE;
l_segment               JA_AU_ACCT_DEFAULT_SEGS.segment%TYPE;
l_segvalues             fnd_flex_ext.segmentarray;
l_seglength             natural := 0;
l_segnumber             natural := 0;
l_ccid                  gl_code_combinations.code_combination_id%TYPE;
l_num_segs		number;
l_test_ccid		boolean;


CURSOR l_autoaccount_defns IS
SELECT nvl(upper(s.table_name), '!~') TABLE_NAME,
       nvl(s.constant, '!~') CONSTANT,
       s.segment
  FROM JA_AU_ACCT_DEFAULT_SEGS s, ja_au_account_defaults d
 WHERE s.gl_default_id = d.gl_default_id
   AND d.set_of_books_id = l_set_of_books_id
ORDER BY d.type,s.segment_num ;

BEGIN

     l_error_flag := 0;
     l_num_segs := 0;

     /* Initialise l_segvalues and l_ccid */
     FOR l_index IN 1..30 LOOP
          l_segvalues(l_index) := '%';
     END LOOP;
     l_ccid := 0;
     l_chart_of_accts_id := 0;
     l_set_of_books_id := 0;
     l_subinv_ccid := 0;
     l_item_ccid := 0;


     /* Obtain chart_of_accounts_id and set_of_books from
        org_organization_definitions*/
    JA_AU_get_coa_sob(x_rowid,
		     l_transaction_id,
                     x_org_id,
                     l_chart_of_accts_id,
                     l_set_of_books_id);

      IF l_error_flag = -1 THEN
          GOTO end_processing;
     END IF;

     /* Get the subinventory and item expense accounts */
     JA_AU_get_repln_exp_accts(x_rowid,
		     	      l_transaction_id,
                              x_org_id,
                              x_subinv,
                              x_item_id,
                              l_subinv_ccid,
                              l_item_ccid);

     IF l_error_flag = -1 THEN
          GOTO end_processing;
     END IF;


     /* Fetch the AutoAccounting definitions a row at a time and retrieve
        the segment value from GL_CODE_COMBINATIONS for the specified
        segment */
     OPEN l_autoaccount_defns;

     LOOP
          FETCH l_autoaccount_defns
           INTO l_table_name,
                l_constant,
                l_segment ;


          EXIT WHEN l_autoaccount_defns%NOTFOUND;

          l_num_segs := l_num_segs + 1;

          l_seglength := LENGTH(l_segment);
          l_segnumber := TO_NUMBER(SUBSTR(l_segment,8,l_seglength-7));

          l_segvalues(l_segnumber) := JA_AU_get_segment_value(x_rowid,
							     l_transaction_id,
                                                             l_table_name,
                                                             l_constant,
                                                             l_segment,
                                                             l_subinv_ccid,
                                                             l_item_ccid);

          IF l_error_flag = -1 THEN
               GOTO end_processing;
          END IF;

     END LOOP;

     CLOSE l_autoaccount_defns;

     l_test_ccid := fnd_flex_ext.get_combination_id('SQLGL',
					            'GL#',
						    l_chart_of_accts_id,
						    sysdate,
						    l_num_segs,
						    l_segvalues,
						    l_ccid);

     if (l_test_ccid = TRUE) then
   	commit;
     else
        l_test_ccid := fnd_flex_ext.get_combination_id('SQLGL',
						       'GL#',
						       l_chart_of_accts_id,
						       sysdate,
						       l_num_segs,
						       l_segvalues,
						       l_ccid);

        if (l_test_ccid = TRUE) then
	   commit;
        else
           l_error_msg := 'AUTOGL ERROR - Could not obtain or create CODE_COMBINATION_ID.';
           JA_AU_update_errors(x_rowid,l_transaction_id);
           goto end_processing;
        end if;
     end if;

     JA_AU_update_reqinterface(x_rowid,
			      l_transaction_id,
                              l_ccid);

<<end_processing>>
     commit;

EXCEPTION
  WHEN OTHERS THEN
--          DBMS_OUTPUT.NEW_LINE;
--          DBMS_OUTPUT.PUT('*** ERROR in JA_AU_AUTOACCOUNTING ***');
--          DBMS_OUTPUT.NEW_LINE;
--          DBMS_OUTPUT.PUT(SQLERRM);
--          DBMS_OUTPUT.NEW_LINE;
    null;
END JA_AU_AUTOACCOUNTING ;




-- + ============================================================================+
-- |     NAME: POST_VALIDATE_USER_EXTENSIONS
-- |     DESC: Top level procedure that you can use to add logic to ReqImport to
-- |           implement any extra functionality that you need. Make sure that
-- |           all the logic that accesses the PO_REQUISITIONS_INTERFACE table
-- |           restricts by the X_REQUEST_ID parameter.
-- |     ARGS: request_id
-- |     ALGR: None
-- +=============================================================================+

PROCEDURE POST_VALIDATE_USER_EXTENSIONS(x_request_id IN number)
IS


CURSOR l_po_interface_lines
    IS SELECT pri.source_type_code,
              pri.requisition_header_id,
              pri.requisition_line_id,
              pri.req_distribution_id,
              pri.requisition_type,
              pri.unit_price,
              pri.autosource_flag,
              pri.item_id,
              pri.charge_account_id,
              pri.unit_of_measure,
              pri.uom_code,
              pri.source_organization_id,
              pri.destination_organization_id,
              pri.source_subinventory,
              pri.destination_organization_id,
              pri.destination_subinventory,
	      pri.destination_type_code,
              pri.deliver_to_location_id,
              pri.quantity,
              pri.transaction_id,
              pri.rowid
              ,pri.autosource_doc_header_id
              ,pri.autosource_doc_line_num
              ,pri.suggested_vendor_id
              ,pri.suggested_vendor_site_id
         FROM po_requisitions_interface pri
        WHERE request_id = x_request_id ;


l_source_type_code
     po_requisitions_interface.source_type_code%TYPE;
l_requisition_header_id
     po_requisitions_interface.requisition_header_id%TYPE;
l_requisition_line_id
     po_requisitions_interface.requisition_line_id%TYPE;
l_req_distribution_id
     po_requisitions_interface.req_distribution_id%TYPE;
l_requisition_type
     po_requisitions_interface.requisition_type%TYPE;
l_unit_price
     po_requisitions_interface.unit_price%TYPE;
--Bug 3032472 : Move it to global variable
--l_autosource_flag
--     po_requisitions_interface.autosource_flag%TYPE;
l_item_id
     po_requisitions_interface.item_id%TYPE;
l_charge_account_id
     po_requisitions_interface.charge_account_id%TYPE;
l_unit_of_measure
     po_requisitions_interface.unit_of_measure%TYPE;
l_uom_code
     po_requisitions_interface.uom_code%TYPE;
l_source_organization_id
     po_requisitions_interface.source_organization_id%TYPE;
l_destination_organization_id
     po_requisitions_interface.source_organization_id%TYPE;
l_source_subinventory
     po_requisitions_interface.source_subinventory%TYPE;
l_dest_org_id
     po_requisitions_interface.destination_organization_id%TYPE;
l_dest_subinventory
     po_requisitions_interface.destination_subinventory%TYPE;
l_destination_type_code
     po_requisitions_interface.destination_type_code%TYPE;
l_deliver_to_location_id
     po_requisitions_interface.deliver_to_location_id%TYPE;
l_transaction_id
     po_requisitions_interface.transaction_id%TYPE;
l_quantity
     po_requisitions_interface.quantity%TYPE;
l_rowid                    varchar2(25) ;
l_autosource_doc_header_id
     po_requisitions_interface.autosource_doc_header_id%TYPE;
l_autosource_doc_line_num
     po_requisitions_interface.autosource_doc_line_num%TYPE;
l_suggested_vendor_id
     po_requisitions_interface.suggested_vendor_id%TYPE;
l_suggested_vendor_site_id
     po_requisitions_interface.suggested_vendor_site_id%TYPE;

l_call_autoacct    varchar2(1);   -- execution control for auto accounting procedure.
l_po_imp_req_flag  VARCHAR2(1);   -- pkg execution control profile variable


BEGIN

   -- JA_AU_PO_IMP_REQ_FLAG profile controls execution of this program.

   FND_PROFILE.GET('JA_AU_PO_IMP_REQ_FLAG',l_po_imp_req_flag);

   IF nvl(l_po_imp_req_flag,'N') <> 'Y' THEN

      return;

   END IF;
   --

   -- Get profile value which tells us if auto accounting is to be called.

    FND_PROFILE.GET('JA_AU_PO_AUTO_ACCT',l_call_autoacct);

    OPEN l_po_interface_lines ;

    LOOP

       FETCH l_po_interface_lines
        INTO l_source_type_code,
             l_requisition_header_id,
             l_requisition_line_id,
             l_req_distribution_id,
             l_requisition_type,
             l_unit_price,
             g_autosource_flag,
             l_item_id,
             l_charge_account_id,
             l_unit_of_measure,
             l_uom_code,
             l_source_organization_id,
             l_destination_organization_id,
             l_source_subinventory,
             l_dest_org_id,
             l_dest_subinventory,
	     l_destination_type_code,
             l_deliver_to_location_id,
             l_quantity,
             l_transaction_id,
             l_rowid ,
             l_autosource_doc_header_id ,
             l_autosource_doc_line_num ,
             l_suggested_vendor_id ,
             l_suggested_vendor_site_id ;

       EXIT WHEN l_po_interface_lines%NOTFOUND ;

       IF l_requisition_type = 'INTERNAL' THEN

          g_count := 0;  -- Bug 6277514

          JA_AU_uoi_conversion(l_item_id,
                               l_source_organization_id,
                               l_quantity,
                               l_unit_price,
			       l_unit_of_measure,
                               l_rowid) ;

	  IF (l_destination_type_code = 'INVENTORY')
                 and (l_call_autoacct = 'Y') THEN
             JA_AU_autoaccounting(l_rowid,
			          l_destination_organization_id,
			          l_dest_subinventory,
			          l_item_id,
			          l_transaction_id);
	  END IF;
       ELSE
            -- ** SGOGGIN JUNE 1996
            -- Modified to check if Autosourcing has been disabled in the
	          -- Interface table.
            IF g_autosource_flag IN ('Y','P') THEN  -- Bug 3032472
               JA_AU_autosource(l_item_id,
                            l_destination_organization_id,
                            l_quantity,
                            l_uom_code,
                            l_unit_of_measure,
                            l_rowid,
                            l_autosource_doc_header_id ,
                            l_autosource_doc_line_num ,
                            l_suggested_vendor_id ,
                            l_suggested_vendor_site_id) ;
            END IF;

       END IF;


    END LOOP ;
    CLOSE l_po_interface_lines ;


EXCEPTION
  WHEN OTHERS THEN NULL;
END POST_VALIDATE_USER_EXTENSIONS;


END PO_REQIMP_PKG;

/
