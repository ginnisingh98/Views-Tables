--------------------------------------------------------
--  DDL for Package Body PO_LINES_SV2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_LINES_SV2" as
/* $Header: POXPOL2B.pls 120.0.12010000.3 2011/09/14 18:15:44 yawang ship $ */

/*=============================  PO_LINES_SV2  ===============================*/
/*===========================================================================

  FUNCTION NAME:	get_max_line_num()

===========================================================================*/
 FUNCTION get_max_line_num
	(X_po_header_id NUMBER) return number is

 x_max_line_num NUMBER;
 X_Progress   varchar2(3) := '';

 BEGIN
        X_Progress := '010';

        SELECT nvl(max(line_num),0)
        INTO   X_max_line_num
        FROM   po_lines
        WHERE  po_header_id = X_po_header_id;

        return(x_max_line_num);

 EXCEPTION

        WHEN OTHERS THEN
             return(0);


 END get_max_line_num;


 /*===========================================================================

  PROCEDURE NAME:	update_line()
			Moved to PO_LINES_SV11
			ecso 3/19/97 for globalization

 ===========================================================================*/

/*RETROACTIVE FPI START */
Procedure retroactive_change(p_po_line_id IN number) IS
X_progress                VARCHAR2(3)  := '';
x_user_id NUMBER := fnd_global.user_id;

/* Bug 12648504 */
l_line_id NUMBER;

BEGIN
	 X_progress := '010';

	 /* Bug 12648504 Start , try to get the lock on the record in PO_LINES before updating the
	   record . If system can't get the lock then it trhows an exception with sqlcode -54
	 */

	 SELECT po_line_id INTO l_line_id
		   FROM
		   PO_LINES
		   WHERE
		   po_line_id = p_po_line_id FOR UPDATE OF RETROACTIVE_DATE NOWAIT;

        /* Bug 12648504 End */


        update po_lines
        set retroactive_date = sysdate,
	    last_update_date = sysdate,
            last_updated_by = x_user_id
        where po_line_id = p_po_line_id;
EXCEPTION
        WHEN OTHERS THEN

	/* Bug 12648504 Start ,Error code -54 means can't get lock on the record. */
	IF SQLCODE=-54 THEN
        RAISE;
        END IF;
	/* Bug 12648504 End */

          po_message_s.sql_error('retroactive_change', X_progress, sqlcode);
          raise;
END retroactive_change;
/*RETROACTIVE FPI END*/

-- <FPJ Retroactive START>
--------------------------------------------------------------------------------
--Start of Comments
--Name: retroactive_change
--Pre-reqs:
--  None.
--Modifies:
--  PO_LINE_LOCATIONS_ALL.retroactive_date.
--Locks:
--  None.
--Function:
--  This is the API which updates the column retroactive_date in po_line_locations
--  for Release ONLY with sysdate.
--  This procedure is called from PO_SHIPMENTS.price_override WHEN-VALIDATE-ITEM
--  trigger in the Enter Release form.
--  This will give the release shipment a different time with its corresponding
--  blanket agreement line, so that Approval Workflow will know this release had
--  some retroactive price change.
--Parameters:
--IN:
--p_line_location_id
--  the line_location_id for which the retroactive_Date needs to be updated.
--OUT:
--  None.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
Procedure retro_change_shipment(p_line_location_id IN number) IS
  l_progress VARCHAR2(3)  := '';
  l_user_id  NUMBER := FND_GLOBAL.user_id;
BEGIN
  l_progress := '010';

  --Bug12931756, update retroactive_date directly to the same date as
  --on the corresponding blanket agreement line. The approval workflow
  --would not update the retroactive_date again
  UPDATE po_line_locations pll
  SET    retroactive_date = (SELECT pl.retroactive_date
                               FROM po_lines_all pl
                              WHERE pl.po_line_id = pll.po_line_id),
         --retroactive_date = SYSDATE,
         last_update_date = SYSDATE,
         last_updated_by = l_user_id
  WHERE  line_location_id = p_line_location_id;
EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('retro_change_shipment', l_progress, sqlcode);
    raise;
END retro_change_shipment;
-- <FPJ Retroactive END>


END PO_LINES_SV2;

/
