--------------------------------------------------------
--  DDL for Package PO_ACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ACTIONS" AUTHID CURRENT_USER AS
/* $Header: POXPOACS.pls 120.0 2005/06/01 21:10:27 appldev noship $ */

  -- Close PO

/* bug 1007829: frkhan
** New parameter p_action_date is added to close_po() function.
*/

  FUNCTION close_po(p_docid        IN     NUMBER,
                    p_doctyp       IN     VARCHAR2,
                    p_docsubtyp    IN     VARCHAR2,
                    p_lineid       IN     NUMBER,
                    p_shipid       IN     NUMBER,
                    p_action       IN     VARCHAR2,
                    p_reason       IN     VARCHAR2 DEFAULT NULL,
                    p_calling_mode IN     VARCHAR2 DEFAULT 'PO',
                    p_conc_flag    IN     VARCHAR2 DEFAULT 'N',
                    p_return_code  IN OUT NOCOPY VARCHAR2,
                    p_auto_close   IN     VARCHAR2 DEFAULT 'Y',
                    p_action_date  IN     DATE DEFAULT SYSDATE,
                    --<JFMIP FPI>
                    p_origin_doc_id IN    NUMBER DEFAULT NULL) RETURN BOOLEAN;


--<DBI Req Fulfillment 11.5.11>
--Get Shipment Closure Dates
FUNCTION get_closure_dates(p_call_mode  IN VARCHAR2,
                         p_line_location_id IN NUMBER
                         ) RETURN DATE;



END PO_ACTIONS;

 

/
