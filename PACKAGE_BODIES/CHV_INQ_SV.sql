--------------------------------------------------------
--  DDL for Package Body CHV_INQ_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CHV_INQ_SV" as
/* $Header: CHVSIN1B.pls 120.1.12010000.5 2014/05/27 11:09:57 shikapoo ship $*/

/*=============================  CHV_INQ_SV  ===============================*/

/*===========================================================================

  FUNCTION NAME:	get_bucket_type()

===========================================================================*/
PROCEDURE get_receipt_qty(p_last_receipt_transaction_id in number,
        		  p_item_id                     in number,
		          p_purchasing_unit_of_measure  in varchar2,
			  p_purchasing_quantity      in out NOCOPY number,
			  p_shipment_number          in out NOCOPY varchar2,
			  p_receipt_transaction_date in out NOCOPY date) is

x_purchasing_uom_code       varchar2(3)    ;
x_purchasing_quantity       number         ;
x_conversion_rate           number         ;
x_receiving_uom_code        varchar2(3)    ;
x_receiving_unit_of_measure varchar2(25)   ;
x_quantity_received         number         ;
x_shipment_number           varchar2(30)   ;
x_transaction_date          date           ;

begin

  select rct.transaction_date,
         rsh.shipment_num,
         rsl.quantity_received,
         rsl.unit_of_measure
    into x_transaction_date,
         x_shipment_number,
         x_quantity_received,
         x_receiving_unit_of_measure
  from rcv_transactions rct,
       rcv_shipment_headers rsh,
       rcv_shipment_lines rsl
  where transaction_id = p_last_receipt_transaction_id
  and  rct.shipment_header_id = rsh.shipment_header_id
  and  rct.shipment_line_id   = rsl.shipment_line_id ;

/* Bug 1706360: Get the last_receipt_quantity (purchasing_quantity)
   as the sum(quantity_received) from rcv_shipment_lines for the receipt_num
   corresponding to p_last_receipt_transaction_id.
   Also added item id cond. to the foll. sql stmt. so that
   the qty received only against that item is computed. This is because
   more than one item can be received in the same receipt. */

select sum(quantity_received)
into x_quantity_received
from rcv_shipment_lines rsl
where rsl.shipment_header_id=(select rct.shipment_header_id
                              from rcv_transactions rct where
                              transaction_id = p_last_receipt_transaction_id)
and rsl.item_id = p_item_id;

--End of Bug 1706360

  select uom_code
    into x_receiving_uom_code
    FROM mtl_units_of_measure
   WHERE unit_of_measure = X_receiving_unit_of_measure ;

  select uom_code
    into x_purchasing_uom_code
    FROM mtl_units_of_measure
   WHERE unit_of_measure = p_purchasing_unit_of_measure ;

   inv_convert.inv_um_conversion(x_receiving_uom_code,
				 x_purchasing_uom_code,
				 p_item_id, x_conversion_rate) ;

   x_purchasing_quantity := round((x_conversion_rate * x_quantity_received),5) ;

   p_purchasing_quantity      := x_purchasing_quantity ;
   p_shipment_number          := x_shipment_number     ;
   p_receipt_transaction_date := x_transaction_date    ;

EXCEPTION WHEN OTHERS THEN
  NULL ;
END ;

/*===========================================================================

  PROCEDURE NAME:	get_bucket_dates()

===========================================================================*/
PROCEDURE get_bucket_dates(p_schedule_id        IN      NUMBER,
			   p_schedule_item_id 	IN      NUMBER,
			   p_column_name        IN      VARCHAR2,
			   p_bucket_descriptor  IN OUT NOCOPY  VARCHAR2,
			   p_bucket_start_date  IN OUT NOCOPY  DATE,
                           p_bucket_end_date    IN OUT NOCOPY  DATE) IS

bucket_rec      chv_horizontal_schedules%rowtype ;
start_date_rec  chv_horiz_date_schedules_v%rowtype ;
end_date_rec    chv_horiz_date_schedules_v%rowtype ;

BEGIN

  SELECT *
    INTO bucket_rec
    FROM chv_horizontal_schedules
   WHERE schedule_id = p_schedule_id
     AND schedule_item_id = p_schedule_item_id
     AND row_select_order = 1 ;

  SELECT *
    INTO start_date_rec
    FROM chv_horiz_date_schedules_v
   WHERE schedule_id = p_schedule_id
     AND schedule_item_id = p_schedule_item_id
     AND row_select_order = 2 ;

  SELECT *
    INTO end_date_rec
    FROM chv_horiz_date_schedules_v
   WHERE schedule_id = p_schedule_id
     AND schedule_item_id = p_schedule_item_id
     AND row_select_order = 7 ;

  FOR i IN 1..1 LOOP

     if p_column_name = 'COLUMN1' then
        p_bucket_descriptor  :=  bucket_rec.column1 ;
        p_bucket_start_date  :=  start_date_rec.column1 ;
        p_bucket_end_date    :=  end_date_rec.column1 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN2' then
        p_bucket_descriptor  :=  bucket_rec.column2 ;
        p_bucket_start_date  :=  start_date_rec.column2 ;
        p_bucket_end_date    :=  end_date_rec.column2 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN3' then
        p_bucket_descriptor  :=  bucket_rec.column3 ;
        p_bucket_start_date  :=  start_date_rec.column3 ;
        p_bucket_end_date    :=  end_date_rec.column3 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN4' then
        p_bucket_descriptor  :=  bucket_rec.column4 ;
        p_bucket_start_date  :=  start_date_rec.column4 ;
        p_bucket_end_date    :=  end_date_rec.column4 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN5' then
        p_bucket_descriptor  :=  bucket_rec.column5 ;
        p_bucket_start_date  :=  start_date_rec.column5 ;
        p_bucket_end_date    :=  end_date_rec.column5 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN6' then
        p_bucket_descriptor  :=  bucket_rec.column6 ;
        p_bucket_start_date  :=  start_date_rec.column6 ;
        p_bucket_end_date    :=  end_date_rec.column6 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN7' then
        p_bucket_descriptor  :=  bucket_rec.column7 ;
        p_bucket_start_date  :=  start_date_rec.column7 ;
        p_bucket_end_date    :=  end_date_rec.column7 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN8' then
        p_bucket_descriptor  :=  bucket_rec.column8 ;
        p_bucket_start_date  :=  start_date_rec.column8 ;
        p_bucket_end_date    :=  end_date_rec.column8 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN9' then
        p_bucket_descriptor  :=  bucket_rec.column9 ;
        p_bucket_start_date  :=  start_date_rec.column9 ;
        p_bucket_end_date    :=  end_date_rec.column9 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN10' then
        p_bucket_descriptor  :=  bucket_rec.column10 ;
        p_bucket_start_date  :=  start_date_rec.column10 ;
        p_bucket_end_date    :=  end_date_rec.column10 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN11' then
        p_bucket_descriptor  :=  bucket_rec.column11 ;
        p_bucket_start_date  :=  start_date_rec.column11 ;
        p_bucket_end_date    :=  end_date_rec.column11 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN12' then
        p_bucket_descriptor  :=  bucket_rec.column12 ;
        p_bucket_start_date  :=  start_date_rec.column12 ;
        p_bucket_end_date    :=  end_date_rec.column12 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN13' then
        p_bucket_descriptor  :=  bucket_rec.column13 ;
        p_bucket_start_date  :=  start_date_rec.column13 ;
        p_bucket_end_date    :=  end_date_rec.column13 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN14' then
        p_bucket_descriptor  :=  bucket_rec.column14 ;
        p_bucket_start_date  :=  start_date_rec.column14 ;
        p_bucket_end_date    :=  end_date_rec.column14 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN15' then
        p_bucket_descriptor  :=  bucket_rec.column15 ;
        p_bucket_start_date  :=  start_date_rec.column15 ;
        p_bucket_end_date    :=  end_date_rec.column15 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN16' then
        p_bucket_descriptor  :=  bucket_rec.column16 ;
        p_bucket_start_date  :=  start_date_rec.column16 ;
        p_bucket_end_date    :=  end_date_rec.column16 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN17' then
        p_bucket_descriptor  :=  bucket_rec.column17 ;
        p_bucket_start_date  :=  start_date_rec.column17 ;
        p_bucket_end_date    :=  end_date_rec.column17 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN18' then
        p_bucket_descriptor  :=  bucket_rec.column18 ;
        p_bucket_start_date  :=  start_date_rec.column18 ;
        p_bucket_end_date    :=  end_date_rec.column18 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN19' then
        p_bucket_descriptor  :=  bucket_rec.column19 ;
        p_bucket_start_date  :=  start_date_rec.column19 ;
        p_bucket_end_date    :=  end_date_rec.column19 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN20' then
        p_bucket_descriptor  :=  bucket_rec.column20 ;
        p_bucket_start_date  :=  start_date_rec.column20 ;
        p_bucket_end_date    :=  end_date_rec.column20 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN21' then
        p_bucket_descriptor  :=  bucket_rec.column21 ;
        p_bucket_start_date  :=  start_date_rec.column21 ;
        p_bucket_end_date    :=  end_date_rec.column21 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN22' then
        p_bucket_descriptor  :=  bucket_rec.column22 ;
        p_bucket_start_date  :=  start_date_rec.column22 ;
        p_bucket_end_date    :=  end_date_rec.column22 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN23' then
        p_bucket_descriptor  :=  bucket_rec.column23 ;
        p_bucket_start_date  :=  start_date_rec.column23 ;
        p_bucket_end_date    :=  end_date_rec.column23 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN24' then
        p_bucket_descriptor  :=  bucket_rec.column24 ;
        p_bucket_start_date  :=  start_date_rec.column24 ;
        p_bucket_end_date    :=  end_date_rec.column24 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN25' then
        p_bucket_descriptor  :=  bucket_rec.column25 ;
        p_bucket_start_date  :=  start_date_rec.column25 ;
        p_bucket_end_date    :=  end_date_rec.column25 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN26' then
        p_bucket_descriptor  :=  bucket_rec.column26 ;
        p_bucket_start_date  :=  start_date_rec.column26 ;
        p_bucket_end_date    :=  end_date_rec.column26 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN27' then
        p_bucket_descriptor  :=  bucket_rec.column27 ;
        p_bucket_start_date  :=  start_date_rec.column27 ;
        p_bucket_end_date    :=  end_date_rec.column27 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN28' then
        p_bucket_descriptor  :=  bucket_rec.column28 ;
        p_bucket_start_date  :=  start_date_rec.column28 ;
        p_bucket_end_date    :=  end_date_rec.column28 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN29' then
        p_bucket_descriptor  :=  bucket_rec.column29 ;
        p_bucket_start_date  :=  start_date_rec.column29 ;
        p_bucket_end_date    :=  end_date_rec.column29 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN30' then
        p_bucket_descriptor  :=  bucket_rec.column30 ;
        p_bucket_start_date  :=  start_date_rec.column30 ;
        p_bucket_end_date    :=  end_date_rec.column30 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN31' then
        p_bucket_descriptor  :=  bucket_rec.column31 ;
        p_bucket_start_date  :=  start_date_rec.column31 ;
        p_bucket_end_date    :=  end_date_rec.column31 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN32' then
        p_bucket_descriptor  :=  bucket_rec.column32 ;
        p_bucket_start_date  :=  start_date_rec.column32 ;
        p_bucket_end_date    :=  end_date_rec.column32 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN33' then
        p_bucket_descriptor  :=  bucket_rec.column33 ;
        p_bucket_start_date  :=  start_date_rec.column33 ;
        p_bucket_end_date    :=  end_date_rec.column33 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN34' then
        p_bucket_descriptor  :=  bucket_rec.column34 ;
        p_bucket_start_date  :=  start_date_rec.column34 ;
        p_bucket_end_date    :=  end_date_rec.column34 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN35' then
        p_bucket_descriptor  :=  bucket_rec.column35 ;
        p_bucket_start_date  :=  start_date_rec.column35 ;
        p_bucket_end_date    :=  end_date_rec.column35 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN36' then
        p_bucket_descriptor  :=  bucket_rec.column36 ;
        p_bucket_start_date  :=  start_date_rec.column36 ;
        p_bucket_end_date    :=  end_date_rec.column36 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN37' then
        p_bucket_descriptor  :=  bucket_rec.column37 ;
        p_bucket_start_date  :=  start_date_rec.column37 ;
        p_bucket_end_date    :=  end_date_rec.column37 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN38' then
        p_bucket_descriptor  :=  bucket_rec.column38 ;
        p_bucket_start_date  :=  start_date_rec.column38 ;
        p_bucket_end_date    :=  end_date_rec.column38 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN39' then
        p_bucket_descriptor  :=  bucket_rec.column39 ;
        p_bucket_start_date  :=  start_date_rec.column39 ;
        p_bucket_end_date    :=  end_date_rec.column39 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN40' then
        p_bucket_descriptor  :=  bucket_rec.column40 ;
        p_bucket_start_date  :=  start_date_rec.column40 ;
        p_bucket_end_date    :=  end_date_rec.column40 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN41' then
        p_bucket_descriptor  :=  bucket_rec.column41 ;
        p_bucket_start_date  :=  start_date_rec.column41 ;
        p_bucket_end_date    :=  end_date_rec.column41 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN42' then
        p_bucket_descriptor  :=  bucket_rec.column42 ;
        p_bucket_start_date  :=  start_date_rec.column42 ;
        p_bucket_end_date    :=  end_date_rec.column42 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN43' then
        p_bucket_descriptor  :=  bucket_rec.column43 ;
        p_bucket_start_date  :=  start_date_rec.column43 ;
        p_bucket_end_date    :=  end_date_rec.column43 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN44' then
        p_bucket_descriptor  :=  bucket_rec.column44 ;
        p_bucket_start_date  :=  start_date_rec.column44 ;
        p_bucket_end_date    :=  end_date_rec.column44 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN45' then
        p_bucket_descriptor  :=  bucket_rec.column45 ;
        p_bucket_start_date  :=  start_date_rec.column45 ;
        p_bucket_end_date    :=  end_date_rec.column45 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN46' then
        p_bucket_descriptor  :=  bucket_rec.column46 ;
        p_bucket_start_date  :=  start_date_rec.column46 ;
        p_bucket_end_date    :=  end_date_rec.column46 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN47' then
        p_bucket_descriptor  :=  bucket_rec.column47 ;
        p_bucket_start_date  :=  start_date_rec.column47 ;
        p_bucket_end_date    :=  end_date_rec.column47 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN48' then
        p_bucket_descriptor  :=  bucket_rec.column48 ;
        p_bucket_start_date  :=  start_date_rec.column48 ;
        p_bucket_end_date    :=  end_date_rec.column48 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN49' then
        p_bucket_descriptor  :=  bucket_rec.column49 ;
        p_bucket_start_date  :=  start_date_rec.column49 ;
        p_bucket_end_date    :=  end_date_rec.column49 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN50' then
        p_bucket_descriptor  :=  bucket_rec.column50 ;
        p_bucket_start_date  :=  start_date_rec.column50 ;
        p_bucket_end_date    :=  end_date_rec.column50 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN51' then
        p_bucket_descriptor  :=  bucket_rec.column51 ;
        p_bucket_start_date  :=  start_date_rec.column51 ;
        p_bucket_end_date    :=  end_date_rec.column51 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN52' then
        p_bucket_descriptor  :=  bucket_rec.column52 ;
        p_bucket_start_date  :=  start_date_rec.column52 ;
        p_bucket_end_date    :=  end_date_rec.column52 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN53' then
        p_bucket_descriptor  :=  bucket_rec.column53 ;
        p_bucket_start_date  :=  start_date_rec.column53 ;
        p_bucket_end_date    :=  end_date_rec.column53 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN54' then
        p_bucket_descriptor  :=  bucket_rec.column54 ;
        p_bucket_start_date  :=  start_date_rec.column54 ;
        p_bucket_end_date    :=  end_date_rec.column54 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN55' then
        p_bucket_descriptor  :=  bucket_rec.column55 ;
        p_bucket_start_date  :=  start_date_rec.column55 ;
        p_bucket_end_date    :=  end_date_rec.column55 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN56' then
        p_bucket_descriptor  :=  bucket_rec.column56 ;
        p_bucket_start_date  :=  start_date_rec.column56 ;
        p_bucket_end_date    :=  end_date_rec.column56 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN57' then
        p_bucket_descriptor  :=  bucket_rec.column57 ;
        p_bucket_start_date  :=  start_date_rec.column57 ;
        p_bucket_end_date    :=  end_date_rec.column57 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN58' then
        p_bucket_descriptor  :=  bucket_rec.column58 ;
        p_bucket_start_date  :=  start_date_rec.column58 ;
        p_bucket_end_date    :=  end_date_rec.column58 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN59' then
        p_bucket_descriptor  :=  bucket_rec.column59 ;
        p_bucket_start_date  :=  start_date_rec.column59 ;
        p_bucket_end_date    :=  end_date_rec.column59 ;

     EXIT ;
     end if ;

     if p_column_name = 'COLUMN60' then
        p_bucket_descriptor  :=  bucket_rec.column60 ;
        p_bucket_start_date  :=  start_date_rec.column60 ;
        p_bucket_end_date    :=  end_date_rec.column60 ;

     EXIT ;
     end if ;

  END LOOP ;

EXCEPTION
  WHEN OTHERS THEN
  NULL ;

END ;
/*===========================================================================

  FUNCTION NAME:	get_asl_org()

===========================================================================*/
FUNCTION  get_asl_org(p_organization_id 	IN   NUMBER,
		      p_vendor_id 	        IN   NUMBER,
		      p_vendor_site_id 	        IN   NUMBER,
		      p_item_id 	        IN   NUMBER)
					RETURN NUMBER is

x_organization_id number := -1 ;

BEGIN

      SELECT poatt.using_organization_id
        INTO x_organization_id
	FROM  po_asl_attributes_val_v poatt
       WHERE poatt.using_organization_id = p_organization_id
	 AND poatt.vendor_id             = p_vendor_id
	 AND poatt.vendor_site_id        = p_vendor_site_id
	 AND poatt.item_id               = p_item_id;

      return(x_organization_id) ;

EXCEPTION
  WHEN OTHERS THEN
  return(x_organization_id) ;
END ;

/*===========================================================================

  FUNCTION NAME:        get_last_receipt_id()

===========================================================================*/
function get_last_receipt_id(x_vendor_id      in number,
                                   x_vendor_site_id  in number,
                                   x_item_id         in number,
                                   x_organization_id in number,
                                   x_cum_period_start_date in date,
                                   x_cum_period_end_date in date)
                 return number is

x_last_receipt_id number  := null ;
/* Bug 4618577 fixed. Added format mask to to_date function */
begin

 select max(rct.transaction_id)
        into x_last_receipt_id
        from   rcv_transactions rct,
	       rcv_shipment_lines rsl,
	       po_headers poh,
		   po_line_locations pll
	where  rct.shipment_line_id = rsl.shipment_line_id
	and    rct.transaction_type = 'RECEIVE'
	and    rct.transaction_date between
   		to_date(x_cum_period_start_date) and
                to_date(x_cum_period_end_date)
        and    rsl.to_organization_id = x_organization_id
        and    rsl.item_id            = x_item_id
        and    rsl.po_header_id       = poh.po_header_id
		and    rsl.po_line_location_id = pll.line_location_id
        and    poh.vendor_id          = x_vendor_id
        and    poh.vendor_site_id     = x_vendor_site_id
        -- Bug#18822988: Cummins GBPA Support : Start
        AND (( poh.type_lookup_code = 'BLANKET'
		         AND poh.supply_agreement_flag = 'Y')
 	          OR ( poh.type_lookup_code = 'STANDARD'
                   AND EXISTS (
                         SELECT 1 FROM po_headers ph1
                         WHERE   pll.from_header_id IS NOT NULL
                         AND     pll.from_header_id = ph1.po_header_id
                         AND     ph1.type_lookup_code = 'BLANKET'
                         AND     ph1.global_agreement_flag = 'Y'
                         AND     ph1.supply_agreement_flag = 'Y'
                         )
                 )	)
        -- Bug#18822988: Cummins GBPA Support : End
        and    rct.transaction_date in
        (select max(rct2.transaction_date)
        from   rcv_transactions rct2,
	       rcv_shipment_lines rsl2,
               po_headers poh2,
			   po_line_locations pll2
        where  rct2.shipment_line_id   = rsl2.shipment_line_id
        and    rct2.transaction_type   = 'RECEIVE'
        and    rct2.transaction_date between
                to_date(x_cum_period_start_date) and
                to_date(x_cum_period_end_date)
        and    rsl2.to_organization_id = x_organization_id
        and    rsl2.item_id            = x_item_id
        and    rsl2.po_header_id       = poh.po_header_id
		and    rsl2.po_line_location_id = pll2.line_location_id
        and    poh2.vendor_id          = x_vendor_id
        and    poh2.vendor_site_id     = x_vendor_site_id
        -- Bug#18822988: Cummins GBPA Support : Start
        AND ( ( poh2.type_lookup_code = 'BLANKET'
		        AND poh2.supply_agreement_flag = 'Y' )
			   OR ( poh2.type_lookup_code = 'STANDARD'
                   AND EXISTS (
                         SELECT 1 FROM po_headers ph1
                         WHERE   pll2.from_header_id IS NOT NULL
                         AND     pll2.from_header_id = ph1.po_header_id
                         AND     ph1.type_lookup_code = 'BLANKET'
                         AND     ph1.global_agreement_flag = 'Y'
                         AND     ph1.supply_agreement_flag = 'Y'
                         )
                 )));
		-- Bug#18822988: Cummins GBPA Support : End

    return(x_last_receipt_id) ;

exception when others then

    return('') ;

end ;

/*===========================================================================

  FUNCTION NAME: get_bucket_type()

==========================================================================*/
FUNCTION get_bucket_type(p_bucket_type_code IN VARCHAR2)
			RETURN varchar2 is

x_bucket_type_dsp   varchar2(80) ;

BEGIN

 SELECT displayed_field
   INTO x_bucket_type_dsp
   FROM po_lookup_codes
  WHERE lookup_type = 'SCHEDULE_BUCKET_TYPE'
    AND lookup_code = p_bucket_type_code ;

   return(x_bucket_type_dsp) ;

EXCEPTION
  WHEN OTHERS THEN
  return('') ;
END ;
END CHV_INQ_SV ;

/
