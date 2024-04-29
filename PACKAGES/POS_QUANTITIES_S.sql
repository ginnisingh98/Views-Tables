--------------------------------------------------------
--  DDL for Package POS_QUANTITIES_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_QUANTITIES_S" AUTHID CURRENT_USER AS
/* $Header: POSTXQUS.pls 115.0 99/08/20 11:10:21 porting sh $ */

  /* getAvailableQuantity
   * --------------------
   * PL/SQL wrapper around rcv_quantities_s.get_available_quantity to return
   * some values.
   */
  FUNCTION getAvailableQuantity(p_lineLocationID IN NUMBER) RETURN NUMBER;



  /* getTolerableQuantity
   * --------------------
   * PL/SQL wrapper around rcv_quantities_s.get_available_quantity to return
   * some values.
   */

  FUNCTION getTolerableQuantity(p_lineLocationID IN NUMBER) RETURN NUMBER;


  FUNCTION get_invoice_qty(x_line_location_id in number,
                           x_asn_unit_of_measure in varchar2,
                           x_item_id in number,
                           x_quantity in number) return number;

END POS_QUANTITIES_S;


 

/
