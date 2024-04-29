--------------------------------------------------------
--  DDL for Package POS_SCO_TOLERANCE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_SCO_TOLERANCE_GRP" AUTHID CURRENT_USER AS
/* $Header: POSGTOLS.pls 120.0 2005/06/01 13:35:19 appldev noship $ */

  G_PKG_NAME  CONSTANT    VARCHAR2(30) := 'POS_SCO_TOLERANCE_GRP';
  G_FILE_NAME CONSTANT    VARCHAR2(30) := 'POSGTOLS.pls';

PROCEDURE INITIALIZE_TOL_VALUES        (itemtype        IN VARCHAR2,
  	                                itemkey         IN VARCHAR2,
  	                                actid           IN NUMBER,
  	                                funcmode        IN VARCHAR2,
                                        resultOUT       OUT NOCOPY VARCHAR2);

PROCEDURE PROMISE_DATE_WITHIN_TOL      (itemtype        IN  VARCHAR2,
 	                                itemkey         IN  VARCHAR2,
 	                                actid           IN  NUMBER,
 	                                funcmode        IN  VARCHAR2,
                                        resultOUT       OUT NOCOPY VARCHAR2);

PROCEDURE UNIT_PRICE_WITHIN_TOL        (itemtype        IN VARCHAR2,
 	                                itemkey         IN VARCHAR2,
 	                                actid           IN NUMBER,
 	                                funcmode        IN VARCHAR2,
                                        resultOUT       OUT NOCOPY VARCHAR2);

PROCEDURE SHIP_QUANTITY_WITHIN_TOL     (itemtype        IN VARCHAR2,
 	                                itemkey         IN VARCHAR2,
 	                                actid           IN NUMBER,
 	                                funcmode        IN VARCHAR2,
                                        resultOUT       OUT NOCOPY VARCHAR2);

PROCEDURE DOC_AMOUNT_WITHIN_TOL        (itemtype        IN VARCHAR2,
 	                                itemkey         IN VARCHAR2,
 	                                actid           IN NUMBER,
 	                                funcmode        IN VARCHAR2,
                                        resultOUT       OUT NOCOPY VARCHAR2);

PROCEDURE LINE_AMOUNT_WITHIN_TOL       (itemtype        IN VARCHAR2,
 	                                itemkey         IN VARCHAR2,
 	                                actid           IN NUMBER,
 	                                funcmode        IN VARCHAR2,
                                        resultOUT       OUT NOCOPY VARCHAR2);

PROCEDURE SHIP_AMOUNT_WITHIN_TOL       (itemtype        IN VARCHAR2,
 	                                itemkey         IN VARCHAR2,
 	                                actid           IN NUMBER,
 	                                funcmode        IN VARCHAR2,
                                        resultOUT       OUT NOCOPY VARCHAR2);

PROCEDURE ROUTE_TO_REQUESTER           (itemtype        IN VARCHAR2,
  	                                itemkey         IN VARCHAR2,
  	                                actid           IN NUMBER,
  	                                funcmode        IN VARCHAR2,
                                        resultOUT       OUT NOCOPY VARCHAR2);

PROCEDURE MARK_SCO_FOR_REQ             (itemtype        IN VARCHAR2,
		                        itemkey         IN VARCHAR2,
        		                actid           IN NUMBER,
	            	                funcmode        IN VARCHAR2,
                                        resultOUT       OUT NOCOPY VARCHAR2);

PROCEDURE ROUTE_SCO_BIZ_RULES          (itemtype        IN VARCHAR2,
 	                                itemkey         IN VARCHAR2,
 	                                actid           IN NUMBER,
 	                                funcmode        IN VARCHAR2,
                                        resultOUT       OUT NOCOPY VARCHAR2);

PROCEDURE AUTO_APP_BIZ_RULES           (itemtype        IN VARCHAR2,
   	                                itemkey         IN VARCHAR2,
   	                                actid           IN NUMBER,
   	                                funcmode        IN VARCHAR2,
                                        resultOUT       OUT NOCOPY VARCHAR2);

PROCEDURE PROMISE_DATE_CHANGE          (itemtype        IN VARCHAR2,
  	                                itemkey         IN VARCHAR2,
  	                                actid           IN NUMBER,
  	                                funcmode        IN VARCHAR2,
                                        resultOUT       OUT NOCOPY VARCHAR2);


PROCEDURE INITIATE_RCO_FLOW            (itemtype        IN VARCHAR2,
     	                                itemkey         IN VARCHAR2,
     	                                actid           IN NUMBER,
     	                                funcmode        IN VARCHAR2,
                                        resultOUT       OUT NOCOPY VARCHAR2);


PROCEDURE START_RCO_WORKFLOW           (itemtype        IN VARCHAR2,
   	                                itemkey         IN VARCHAR2,
   	                                actid           IN NUMBER,
   	                                funcmode        IN VARCHAR2,
                                        resultOUT       OUT NOCOPY VARCHAR2) ;


END POS_SCO_TOLERANCE_GRP;
 

/
