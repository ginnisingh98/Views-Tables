--------------------------------------------------------
--  DDL for Package POS_SCO_TOLERANCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_SCO_TOLERANCE_PVT" AUTHID CURRENT_USER AS
/* $Header: POSPTOLS.pls 120.9 2006/08/23 12:16:12 svadlama noship $ */

  G_PKG_NAME  CONSTANT    VARCHAR2(30) := 'POS_SCO_TOLERANCE_PVT';
  G_FILE_NAME CONSTANT    VARCHAR2(30) := 'POSPTOLS.pls';


PROCEDURE INITIALIZE_TOL_VALUES               (itemtype        IN VARCHAR2,
  	                                       itemkey         IN VARCHAR2,
  	                                       actid           IN NUMBER,
  	                                       funcmode        IN VARCHAR2,
                                               resultout       OUT NOCOPY VARCHAR2);

PROCEDURE PROMISE_DATE_WITHIN_TOL             (itemtype        IN  VARCHAR2,
 	                                       itemkey         IN  VARCHAR2,
 	                                       actid           IN  NUMBER,
 	                                       funcmode        IN  VARCHAR2,
                                               resultout       OUT NOCOPY VARCHAR2);

PROCEDURE UNIT_PRICE_WITHIN_TOL               (itemtype        IN VARCHAR2,
 	                                       itemkey         IN VARCHAR2,
 	                                       actid           IN NUMBER,
 	                                       funcmode        IN VARCHAR2,
                                               resultout       OUT NOCOPY VARCHAR2);

PROCEDURE SHIP_QUANTITY_WITHIN_TOL            (itemtype        IN VARCHAR2,
 	                                       itemkey         IN VARCHAR2,
 	                                       actid           IN NUMBER,
 	                                       funcmode        IN VARCHAR2,
                                               resultout       OUT NOCOPY VARCHAR2);

PROCEDURE DOC_AMOUNT_WITHIN_TOL               (itemtype        IN VARCHAR2,
 	                                       itemkey         IN VARCHAR2,
 	                                       actid           IN NUMBER,
 	                                       funcmode        IN VARCHAR2,
                                               resultout       OUT NOCOPY VARCHAR2);

FUNCTION CALCULATE_NEW_DOC_AMOUNT(  p_po_header_id IN NUMBER , p_po_release_id IN NUMBER, p_complex_po_style IN VARCHAR2)
RETURN NUMBER;


PROCEDURE LINE_AMOUNT_WITHIN_TOL              (itemtype        IN VARCHAR2,
 	                                       itemkey         IN VARCHAR2,
 	                                       actid           IN NUMBER,
 	                                       funcmode        IN VARCHAR2,
                                               resultout       OUT NOCOPY VARCHAR2);

FUNCTION  CALCULATE_NEW_LINE_AMOUNT( p_po_header_id IN NUMBER, p_po_release_id IN NUMBER, p_po_line_id IN NUMBER, p_complex_po_style IN VARCHAR2)
RETURN NUMBER;

PROCEDURE SHIP_AMOUNT_WITHIN_TOL              (itemtype        IN VARCHAR2,
 	                                       itemkey         IN VARCHAR2,
 	                                       actid           IN NUMBER,
 	                                       funcmode        IN VARCHAR2,
                                               resultout       OUT NOCOPY VARCHAR2);

FUNCTION CALCULATE_NEW_SHIP_AMOUNT( p_po_header_id         IN NUMBER,
                                    p_po_release_id        IN NUMBER,
                                    p_line_location_id     IN NUMBER,
                                    p_split_flag           IN VARCHAR2,
                                    p_po_style_type        IN VARCHAR2,
                                    p_po_shipment_num      IN NUMBER)
RETURN NUMBER;


PROCEDURE ROUTE_TO_REQUESTER                  (itemtype        IN VARCHAR2,
  	                                       itemkey         IN VARCHAR2,
  	                                       actid           IN NUMBER,
  	                                       funcmode        IN VARCHAR2,
                                               resultout       OUT NOCOPY VARCHAR2);

PROCEDURE MARK_SCO_FOR_REQ                    (itemtype        IN VARCHAR2,
		                               itemkey         IN VARCHAR2,
        		                       actid           IN NUMBER,
	            	                       funcmode        IN VARCHAR2,
                                               resultout       OUT NOCOPY VARCHAR2);

PROCEDURE ROUTE_SCO_BIZ_RULES                 (itemtype        IN VARCHAR2,
 	                                       itemkey         IN VARCHAR2,
 	                                       actid           IN NUMBER,
 	                                       funcmode        IN VARCHAR2,
                                               resultout       OUT NOCOPY VARCHAR2);

PROCEDURE AUTO_APP_BIZ_RULES                  (itemtype        IN VARCHAR2,
   	                                       itemkey         IN VARCHAR2,
   	                                       actid           IN NUMBER,
   	                                       funcmode        IN VARCHAR2,
                                               resultout       OUT NOCOPY VARCHAR2);


PROCEDURE PROMISE_DATE_CHANGE                 (itemtype        IN VARCHAR2,
  	                                       itemkey         IN VARCHAR2,
  	                                       actid           IN NUMBER,
  	                                       funcmode        IN VARCHAR2,
                                               resultout       OUT NOCOPY VARCHAR2);


PROCEDURE INITIATE_RCO_FLOW                   (itemtype        IN VARCHAR2,
     	                                       itemkey         IN VARCHAR2,
     	                                       actid           IN NUMBER,
     	                                       funcmode        IN VARCHAR2,
                                               resultout       OUT NOCOPY VARCHAR2);


PROCEDURE START_RCO_WORKFLOW                  (itemtype        IN VARCHAR2,
   	                                       itemkey         IN VARCHAR2,
   	                                       actid           IN NUMBER,
   	                                       funcmode        IN VARCHAR2,
                                               resultout       OUT NOCOPY VARCHAR2) ;


PROCEDURE INITIATERCOFLOW                     (p_po_header_id    IN NUMBER,
                                               p_po_release_id   IN NUMBER,
                                               x_change_group_id OUT NOCOPY NUMBER) ;

PROCEDURE STARTRCOWORKFLOW                    (p_change_request_group_id IN NUMBER);


PROCEDURE LOG_MESSAGE                         (p_proc_name      IN VARCHAR2,
                                               p_text           IN VARCHAR2,
                                               p_log_data       IN VARCHAR2);


FUNCTION CHANGE_WITHIN_TOL                    (p_oldValue         IN NUMBER,
                                               p_newValue         IN NUMBER,
	                                       p_maxINcrement_per IN NUMBER,
	                                       p_maxDecrement_per IN NUMBER,
	                                       p_maxINcrement_val IN NUMBER,
	                                       p_maxDecrement_val IN NUMBER)
RETURN BOOLEAN;



FUNCTION CHANGE_WITHIN_TOL_DATE               (p_oldValue         IN DATE,
		                               p_newValue         IN DATE,
		                               p_maxINcrement     IN NUMBER,
		                               p_maxDecrement     IN NUMBER)

RETURN BOOLEAN ;



FUNCTION ROUTE_SCO_BIZ_RULES_CHECK            (p_po_header_id     IN NUMBER,
                                               p_po_release_id    IN NUMBER,
                                               p_doc_type         IN VARCHAR2,
                                               p_change_group_id  IN NUMBER)

RETURN BOOLEAN ;


FUNCTION AUTO_APP_BIZ_RULES_CHECK             (p_po_header_id     IN NUMBER,
                                               p_po_release_id    IN NUMBER,
                                               p_doc_type         IN VARCHAR2)

RETURN BOOLEAN ;



FUNCTION ROUTETOREQUESTER                     (p_po_header_id     IN NUMBER,
                                               p_change_group_id  IN NUMBER,
                                               p_doc_type         IN VARCHAR2,
                                               p_prm_date_app_flag IN VARCHAR2,
                                               p_ship_qty_app_flag IN VARCHAR2,
                                               p_unit_price_app_flag IN VARCHAR2)

RETURN BOOLEAN;

FUNCTION PROMISEDATECHANGE                    (p_po_header_id     IN NUMBER,
                                               p_change_group_id  IN NUMBER)

RETURN BOOLEAN;



END POS_SCO_TOLERANCE_PVT;

 

/
