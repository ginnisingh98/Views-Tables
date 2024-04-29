--------------------------------------------------------
--  DDL for Package Body PO_REQ_DIST_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQ_DIST_SV1" AS
/* $Header: POXRQD2B.pls 115.6 2003/12/19 18:57:52 jskim ship $ */

/*===========================================================================

  PROCEDURE NAME:       get_dist_num_account()

===========================================================================*/

PROCEDURE  get_dist_num_account(x_requisition_line_id IN OUT NOCOPY NUMBER,
				x_num_of_dist	      IN OUT NOCOPY NUMBER,
				x_code_combination_id IN OUT NOCOPY NUMBER)
IS

x_progress VARCHAR2(3) := NULL;

BEGIN
   x_progress := '001';

   SELECT count(distribution_id)
   INTO   x_num_of_dist
   FROM   po_req_distributions
   WHERE  requisition_line_id = x_requisition_line_id;

   --
   -- If there is one distribution then obtain
   -- the code combination id for the distribution.
   --
   IF (x_num_of_dist <> 1) THEN
     x_code_combination_id := null;
     return;

   ELSE

     x_progress := '020';

     SELECT code_combination_id
     INTO   x_code_combination_id
     FROM   po_req_distributions
     WHERE  requisition_line_id = x_requisition_line_id;

   END IF;


EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_num_of_dist := 0;

  WHEN OTHERS THEN
    --dbms_output.put_line('In Exception');
    po_message_s.sql_error('get_max_dist_num', x_progress, sqlcode);
    raise;

END get_dist_num_account;

/*===========================================================================

  PROCEDURE NAME:       get_dist_account()

===========================================================================*/

FUNCTION  get_dist_account(x_requisition_line_id IN NUMBER) return NUMBER
IS

x_progress VARCHAR2(3) := NULL;
x_num_of_dist NUMBER;
x_code_combination_id NUMBER;

BEGIN
   x_progress := '001';
-- Bug: 1702850 use _all table instead of stripe table
   SELECT count(distribution_id)
   INTO   x_num_of_dist
   FROM   po_req_distributions_all
   WHERE  requisition_line_id = x_requisition_line_id;

   --
   -- If there is one distribution then obtain
   -- the code combination id for the distribution.
   --
   IF (x_num_of_dist = 0) THEN
     return(null);

   ELSIF (x_num_of_dist > 1) THEN

      return(-11); /* Use -11 to signal multiple distributions. POXRQLNS.pld uses
                   ** this to display "Multiple" in the charge_account field */

   ELSIF (x_num_of_dist = 1) THEN
     x_progress := '020';

-- Bug: 1702850 use _all table instead of stripe table

     SELECT code_combination_id
     INTO   x_code_combination_id
     FROM   po_req_distributions_all
     WHERE  requisition_line_id = x_requisition_line_id;

     return(x_code_combination_id);

   END IF;


EXCEPTION

  WHEN OTHERS THEN
    /*  dbms_output.put_line('In Exception'); */
   /*  po_message_s.sql_error('get_dist_account', x_progress, sqlcode); */
    raise;

END get_dist_account;


/*===========================================================================

  PROCEDURE NAME:       update_dist_quantity()

===========================================================================*/


PROCEDURE  update_dist_quantity(x_requisition_line_id NUMBER,
				x_line_quantity	      NUMBER)

IS

x_progress VARCHAR2(3) := NULL;
x_num_of_dist  NUMBER  := NULL;
Recinfo   po_req_distributions%rowtype;

BEGIN
   x_progress := '001';

   SELECT count(distribution_id)
   INTO   x_num_of_dist
   FROM   po_req_distributions
   WHERE  requisition_line_id = x_requisition_line_id
   AND    NOT EXISTS (SELECT 'there are encumbered distributions'
                FROM   po_req_distributions prd2
                WHERE  prd2.requisition_line_id = x_requisition_line_id
                AND    ( nvl(prd2.encumbered_flag, 'N') <> 'N')
               );

   --
   -- If there is one distribution then obtain
   -- update the distribution quantity.
   --
   IF ((x_num_of_dist <> 1) OR
       (x_num_of_dist is null))THEN
     return;

   ELSE

     x_progress := '020';

     --
     -- Lock the distribution.
     --


     SELECT *
     INTO   Recinfo
     FROM   po_req_distributions
     WHERE  requisition_line_id = x_requisition_line_id
     FOR UPDATE OF req_line_quantity NOWAIT;

     x_progress := '030';

     UPDATE po_req_distributions prd
     SET    req_line_quantity = x_line_quantity
     WHERE  prd.requisition_line_id = x_requisition_line_id;

   END IF;


EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return;

  WHEN OTHERS THEN
    --dbms_output.put_line('In Exception');
    po_message_s.sql_error('update_dist_quantity', x_progress, sqlcode);
    raise;

END update_dist_quantity;

--< Bug 3265539 > Removed unused function get_project_num.

END po_req_dist_sv1;

/
