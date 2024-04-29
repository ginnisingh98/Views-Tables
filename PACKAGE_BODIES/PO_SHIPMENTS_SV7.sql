--------------------------------------------------------
--  DDL for Package Body PO_SHIPMENTS_SV7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_SHIPMENTS_SV7" as
/* $Header: POXPOS7B.pls 115.5 2003/10/17 22:42:33 prpeters ship $*/

/*===========================================================================

  FUNCTION NAME:	get_dest_type_dist()

===========================================================================*/
function get_dest_type_dist(X_po_header_id IN number,
                            X_po_line_id   IN number,
                            X_line_location_id  IN number)
         return boolean is

        X_distribs_exist  boolean;
        X_Progress        varchar2(3) := '';
        X_count           number;

begin

    X_Progress := '010';

    /* Check if there are any distributions who have
    ** destination type as SHOP FLOOR or INVENTORY */

    SELECT count(*)
    INTO   X_count
    FROM   po_distributions
    WHERE  line_location_id       = X_line_location_id
    AND    po_line_id             = X_po_line_id
    AND    po_header_id           = X_po_header_id
    AND    destination_type_code  IN ('SHOP FLOOR','INVENTORY')
    AND    distribution_type     <> 'AGREEMENT';  -- <Encumbrance FPJ>


    if X_count > 0 then
       X_distribs_exist := TRUE;
    else
       X_distribs_exist := FALSE;
    end if;

    return(X_distribs_exist);

exception

    when no_data_found then
         X_distribs_exist := FALSE;
         return(X_distribs_exist);
    when others then
         po_message_s.sql_error('get_dest_type_dist',X_Progress,sqlcode);
         raise;

end get_dest_type_dist;

/*===========================================================================

  PROCEDURE NAME:	get_original_date()

===========================================================================*/
 procedure get_original_date(X_line_location_id IN number,
                             X_Promised_Date    IN OUT NOCOPY DATE) is

 X_Progress varchar2(3) := '';

 begin

       X_Progress := '010';

       /* Get the Promised date from PLL_ARCHIVE
       ** for  given line_location_id where the revision_num
       ** is minimum */

       /* Bug# 3199923, Added the where promised_date is NULL
          to pick the revision where the promised_date was
          initially update to a value other than NULL*/

       select plla.promised_date
       into   X_promised_date
       from   po_line_locations_archive plla
       where  plla.line_location_id = X_line_location_id
       and    plla.revision_num = (select min(revision_num)
                                   from po_line_locations_archive plla2
                                   where plla2.line_location_id = X_line_location_id
                                     and plla2.promised_date is not NULL);


 exception

    when no_data_found then
         null;
    when others then
         po_message_s.sql_error('get_original_date',X_Progress,sqlcode);
         raise;

 end get_original_date;

/*===========================================================================

  PROCEDURE NAME:	get_dist_num()

===========================================================================*/
 procedure get_dist_num(X_line_location_id IN number,
                        X_dist_num IN OUT NOCOPY number,
                        X_code_combination_id IN OUT NOCOPY number) is

 X_Progress varchar2(3) := '';
 begin

       X_Progress := '010';

       select count(*)
       into   X_dist_num
       from   po_distributions
       where  line_location_id = X_line_location_id;

      X_Progress := '020';

      if X_dist_num = 1 then
         select code_combination_id
         into   X_code_combination_id
         from   po_distributions
         where  line_location_id = X_line_location_id;
      end if;

 exception

    when no_data_found then
         null;
    when others then
         po_message_s.sql_error('get_original_date',X_Progress,sqlcode);
         raise;

 end get_dist_num;

/*============================================================================

  PROCEDURE NAME: check_available_quantity()

=============================================================================*/

procedure check_available_quantity(X_source_shipment_id IN NUMBER,
                                   X_orig_quantity      IN NUMBER,
                                   X_quantity           IN NUMBER) is

 X_Progress varchar2(3) := '';
 X_available_quantity NUMBER ;
 X_unreleased_quantity NUMBER;

begin

      X_Progress := '010';

      SELECT (pll.quantity - nvl(pll.quantity_cancelled,0)) -
             (nvl(sum(pll2.quantity - nvl(pll2.quantity_cancelled,0)),0) -
              nvl(X_orig_quantity,0) +
              nvl(X_quantity,0)),
             (pll.quantity - nvl(pll.quantity_cancelled,0)) -
             (nvl(sum(pll2.quantity - nvl(pll2.quantity_cancelled,0) -
              nvl(X_orig_quantity,0)),0))
      INTO   X_unreleased_quantity,
             X_available_quantity
      FROM   po_line_locations pll2,
             po_line_locations pll
      WHERE  pll.line_location_id = pll2.source_shipment_id(+)
      AND    pll.line_location_id = X_source_shipment_id
      AND    pll.shipment_type <> 'PRICE BREAK'
      GROUP BY (pll.quantity - nvl(pll.quantity_cancelled,0));


      if X_unreleased_quantity < 0  then
         po_message_s.app_error('PO_PO_QTY_EXCEEDS_UNREL','QUANTITY',to_char(X_quantity),
                                'UNRELEASED', to_char(X_available_quantity));
      end if;

exception

    when no_data_found then
         null;
    when others then
         po_message_s.sql_error('check_available_quantity',X_Progress,sqlcode);
         raise;

 end check_available_quantity;

END  PO_SHIPMENTS_SV7;

/
