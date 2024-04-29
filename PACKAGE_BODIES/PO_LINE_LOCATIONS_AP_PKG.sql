--------------------------------------------------------
--  DDL for Package Body PO_LINE_LOCATIONS_AP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_LINE_LOCATIONS_AP_PKG" AS
/* $Header: POLNLOCB.pls 120.0.12010000.1 2008/09/18 12:21:11 appldev noship $ */

     -----------------------------------------------------------------------
     -- Function get_last_receipt returns the last receipt date for the
     -- shipment line.
     --
     FUNCTION get_last_receipt(l_line_location_id IN NUMBER)
         RETURN DATE
     IS
         last_receipt_date DATE;

     BEGIN

         SELECT MAX(transaction_date)
         INTO   last_receipt_date
         FROM   rcv_transactions
         WHERE  po_line_location_id = l_line_location_id
         AND    transaction_type = 'RECEIVE';

         RETURN(last_receipt_date);

     END get_last_receipt;


     -----------------------------------------------------------------------
     -- Function get_requestors returns a concatenated list of requestors
     -- from the distributions for the shipment line.  If the list is longer
     -- than 2000 characters, the function will insert trailing ellipses ...
     --
     FUNCTION get_requestors(l_line_location_id IN NUMBER)
         RETURN VARCHAR2
     IS
         requestor_list VARCHAR2(2000) := NULL;
	 requestor      VARCHAR2(240);

         ---------------------------------------------------------------------
         -- Declare cursor to fetch the requestor names
         --
         CURSOR requestor_cursor IS
         SELECT HE.full_name
         FROM   hr_employees     HE,
		po_distributions PD
         WHERE  PD.line_location_id = l_line_location_id
	 AND    PD.deliver_to_person_id = HE.employee_id;

     BEGIN

         OPEN requestor_cursor;

         LOOP
             FETCH requestor_cursor INTO requestor;

             -- bug 643248
             -- need to account for '; ' AND ' ...' when calculating
             -- the limit of characters allowed in the requestor list
             EXIT WHEN requestor_cursor%NOTFOUND or
                       (NVL(LENGTH(requestor_list),0) +
   		        NVL(LENGTH(requestor),0) + 2 + 4 > 2000);

	         IF (requestor_list IS NOT NULL) THEN
	             requestor_list := requestor_list || '; ';
	         END IF;

 		 requestor_list := requestor_list || requestor;
         END LOOP;

         -- bug 643248
         -- attach trailing elipses outside loop, so that it is only performed
         -- ONCE
         IF (NVL(LENGTH(requestor_list),0) +
             NVL(LENGTH(requestor),0) + 2 + 4 > 2000) then
	   requestor_list := requestor_list || ' ...';
	 END IF;


         CLOSE requestor_cursor;

         RETURN(requestor_list);

     END get_requestors;


     -----------------------------------------------------------------------
     -- Function get_num_distributions returns the number of distributions
     -- lines for the shipment line.
     --
     FUNCTION get_num_distributions(l_line_location_id IN NUMBER)
         RETURN NUMBER
     IS
         num_distributions NUMBER := 0;
     BEGIN

	 SELECT count(*)
	 INTO   num_distributions
	 FROM   po_distributions PD
	 WHERE  PD.line_location_id = l_line_location_id;

         RETURN(num_distributions);

     END get_num_distributions;


END PO_LINE_LOCATIONS_AP_PKG;

/
