--------------------------------------------------------
--  DDL for Package Body POS_QUANTITIES_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_QUANTITIES_S" AS
/* $Header: POSTXQUB.pls 115.0 99/08/20 11:10:16 porting sh $ */

  /* getAvailableQuantity
   * --------------------
   * PL/SQL wrapper around rcv_quantities_s.get_available_quantity to return
   * some values.
   */
  FUNCTION getAvailableQuantity(p_lineLocationID IN NUMBER) RETURN NUMBER
  IS

    v_availableQuantity NUMBER;
    v_tolerableQuantity NUMBER;
    v_unitOfMeasure     VARCHAR2(25);
    x_progress          VARCHAR2(3);

  BEGIN

    x_progress := '001';

    rcv_quantities_s.get_available_quantity('RECEIVE',
                                            p_lineLocationID,
                                            'VENDOR',
                                            null,
                                            null,
                                            null,
                                            v_availableQuantity,
                                            v_tolerableQuantity,
                                            v_unitOfMeasure);

    RETURN v_availableQuantity;


  EXCEPTION
    WHEN OTHERS THEN
      po_message_s.sql_error('getAvailableQuantity', x_progress, sqlcode);
      RAISE;

  END getAvailableQuantity;









  /* getTolerableQuantity
   * --------------------
   * PL/SQL wrapper around rcv_quantities_s.get_available_quantity to return
   * some values.
   */
  FUNCTION getTolerableQuantity(p_lineLocationID IN NUMBER) RETURN NUMBER
  IS

    v_availableQuantity NUMBER;
    v_tolerableQuantity NUMBER;
    v_unitOfMeasure     VARCHAR2(25);
    x_progress          VARCHAR2(3);

  BEGIN

    x_progress := '001';

    rcv_quantities_s.get_available_quantity('RECEIVE',
                                            p_lineLocationID,
                                            'VENDOR',
                                            null,
                                            null,
                                            null,
                                            v_availableQuantity,
                                            v_tolerableQuantity,
                                            v_unitOfMeasure);

    RETURN v_tolerableQuantity;


  EXCEPTION
    WHEN OTHERS THEN
      po_message_s.sql_error('getTolerableQuantity', x_progress, sqlcode);
      RAISE;

  END getTolerableQuantity;

FUNCTION get_invoice_qty(x_line_location_id in number,
                 x_asn_unit_of_measure in varchar2,
                 x_item_id in number,
                 x_quantity in number) return number IS
x_conversion_rate number := 0;
x_asn_uom_code    varchar2(30);
x_po_uom_code     varchar2(30);
BEGIN

  IF (x_asn_unit_of_measure is not null) THEN

   SELECT uom_code
   INTO   x_asn_uom_code
   FROM   mtl_units_of_measure
   WHERE  unit_of_measure = x_asn_unit_of_measure;

   SELECT uom_code
   INTO   x_po_uom_code
   FROM   mtl_units_of_measure
   WHERE  unit_of_measure = (select nvl(poll.UNIT_MEAS_LOOKUP_CODE, pol.UNIT_MEAS_LOOKUP_CODE)
                             from po_line_locations_all poll,
                                  po_lines_all pol
                             where poll.line_location_id = x_line_location_id and
                                   poll.po_line_id = pol.po_line_id );

   inv_convert.inv_um_conversion(x_asn_uom_code,
				 x_po_uom_code,
				 x_item_id,
                                 x_conversion_rate);

  END IF;

  return (x_conversion_rate * x_quantity);

END get_invoice_qty;


END POS_QUANTITIES_S;


/
