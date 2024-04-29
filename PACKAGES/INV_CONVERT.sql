--------------------------------------------------------
--  DDL for Package INV_CONVERT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_CONVERT" AUTHID CURRENT_USER AS
/* $Header: INVUMCNS.pls 120.2.12010000.2 2010/01/30 05:55:31 ksaripal ship $ */

  /* ppuranik: bug 1323973
  ** ReadNoPackageState (RNPS) is added, so that
  ** inv_um_convert can be executed remotely with
  ** same purity level or lower.
  */

G_TRUE      CONSTANT NUMBER := 1;
G_FALSE     CONSTANT NUMBER := 0;

    --Start Bug 6761510
    -- The following types are used to cache the UOM conversions.  The three keys to this
    -- are the inventory item, from UOM code, and to UOM code.  This will yield the conversion
    -- rate by using a nested PLSQL table structure.
    TYPE to_uom_code_tb IS TABLE OF NUMBER INDEX BY VARCHAR2(3);
    TYPE from_uom_code_tb IS TABLE OF to_uom_code_tb INDEX BY VARCHAR2(3);
    TYPE item_uom_conversion_tb IS TABLE OF from_uom_code_tb INDEX BY BINARY_INTEGER;

    g_item_uom_conversion_tb      item_uom_conversion_tb;

    FUNCTION inv_um_convert(p_item_id       IN NUMBER,
                            p_from_uom_code IN VARCHAR2,
                            p_to_uom_code   IN VARCHAR2) RETURN NUMBER;
    --End Bug 6761510

  PROCEDURE pick_uom_convert(
      p_org_id                  NUMBER,
      p_item_id                 NUMBER,
      p_sub_code                VARCHAR2,
      p_loc_id                  NUMBER,
      p_alloc_uom               VARCHAR2,
      p_alloc_qty               NUMBER,
      x_pick_uom       OUT NOCOPY     VARCHAR2,
      x_pick_qty       OUT NOCOPY     NUMBER,
      x_uom_string     OUT NOCOPY     VARCHAR2,
      x_return_status  OUT NOCOPY     VARCHAR2,
      x_msg_data       OUT NOCOPY     VARCHAR2,
      x_msg_count      OUT NOCOPY     NUMBER);

  PROCEDURE inv_um_conversion(
      from_unit         	varchar2,
      to_unit           	varchar2,
      item_id           	number,
      lot_number                varchar2 DEFAULT NULL,
      organization_id         	number,
      uom_rate    	out nocopy 	number );
  pragma restrict_references(inv_um_conversion, WNDS,WNPS, RNPS);

  PROCEDURE inv_um_conversion(
      from_unit         	varchar2,
      to_unit           	varchar2,
      item_id           	number,
      uom_rate    	out nocopy 	number );
  pragma restrict_references(inv_um_conversion, WNDS,WNPS, RNPS);

  -- Will call the function inv_um_convert with NULL for lot number and org.
  FUNCTION inv_um_convert(
      item_id           number,
      precision		number,
      from_quantity     number,
      from_unit         varchar2,
      to_unit           varchar2,
      from_name		varchar2,
      to_name		varchar2) RETURN number;
  pragma restrict_references(inv_um_convert, WNDS,WNPS, RNPS);

  FUNCTION inv_um_convert(
      item_id           number,
      lot_number        varchar2 DEFAULT NULL,
      organization_id   number,
      precision		number,
      from_quantity     number,
      from_unit         varchar2,
      to_unit           varchar2,
      from_name		varchar2,
      to_name		varchar2) RETURN number;
  pragma restrict_references(inv_um_convert, WNDS,WNPS, RNPS);

  FUNCTION inv_um_convert_new(
      item_id           number,
      precision		number,
      from_quantity     number,
      from_unit         varchar2,
      to_unit           varchar2,
      from_name		varchar2,
      to_name		varchar2,
      capacity_type     varchar2 ) RETURN number;



  FUNCTION inv_um_convert_new(
      item_id           number,
      lot_number        varchar2 DEFAULT NULL,
      organization_id   number,
      precision		number,
      from_quantity     number,
      from_unit         varchar2,
      to_unit           varchar2,
      from_name		varchar2,
      to_name		varchar2,
      capacity_type     varchar2 ) RETURN number;


  FUNCTION validate_item_uom (p_uom_code IN VARCHAR2,
			      p_item_id  IN NUMBER,
			      p_organization_id IN NUMBER)
    return BOOLEAN;

  pragma restrict_references (validate_item_uom, WNDS,WNPS, RNPS);

-- Checks if quantities entered for dual uoms are within deviation.

FUNCTION within_deviation(
p_organization_id     IN number,
p_inventory_item_id   IN number,
p_lot_number          IN varchar2 DEFAULT NULL,
p_precision           IN number,
p_quantity            IN number,
p_uom_code1           IN varchar2,
p_quantity2           IN number,
p_uom_code2           IN varchar2,
p_unit_of_measure1    IN varchar2 DEFAULT NULL,
p_unit_of_measure2    IN varchar2 DEFAULT NULL)
RETURN NUMBER;


/* Bug 9335882. Added below procedure */
PROCEDURE create_uom_conversion ( p_from_uom_code VARCHAR2 ,
                                  p_to_uom_code VARCHAR2 ,
                                  p_item_id NUMBER ,
                                  p_uom_rate NUMBER ,
                                  x_return_status    OUT NOCOPY  VARCHAR2
                                ) ;

END inv_convert;

/
