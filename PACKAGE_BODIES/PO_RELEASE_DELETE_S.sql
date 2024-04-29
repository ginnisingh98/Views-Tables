--------------------------------------------------------
--  DDL for Package Body PO_RELEASE_DELETE_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_RELEASE_DELETE_S" AS

/* $Header: poreldeb.pls 115.0 99/07/17 02:27:35 porting ship $ */


/*===========================================================================

  PROCEDURE DELETE_RELEASE_UPDATE

===========================================================================*/

PROCEDURE DELETE_RELEASE_UPDATE (X_po_release_id IN NUMBER) IS

X_line_location_id                NUMBER      := 0;
X_po_line_id			  NUMBER      := 0;
X_delete_quantity		  NUMBER      := 0;

CURSOR get_shipments IS
SELECT pll.line_location_id,
       pll.po_line_id,
       pll.quantity
FROM   po_line_locations pll
WHERE  pll.po_release_id = X_po_release_id;


BEGIN


   OPEN get_shipments;

   /* 	Loop through the lines and check to see how much of the contract has
 	been used up by other po's that have been created
   */
   LOOP

     FETCH     get_shipments INTO X_line_location_id,
				  X_po_line_id,
				  X_delete_quantity;
     EXIT WHEN get_shipments%NOTFOUND;

     --dbms_output.put_line('X_line_location_id = ' || X_line_location_id);



     UPDATE po_lines
     SET    quantity   = quantity - X_Delete_quantity
     WHERE  po_line_id = X_po_line_id;

     --dbms_output.put_line('X_delete_quantity = ' || X_Delete_quantity);

   END LOOP;

   RETURN;

   /* If something fails then return a 0 as failure */
   EXCEPTION
      WHEN OTHERS THEN
      raise;

END delete_release_update;

END po_release_delete_s;

/
