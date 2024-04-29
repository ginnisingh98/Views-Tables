--------------------------------------------------------
--  DDL for Package Body POS_SCO_TOLERANCE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_SCO_TOLERANCE_GRP" AS
/* $Header: POSGTOLB.pls 120.0 2005/06/01 15:45:57 appldev noship $ */

  G_PKG_NAME  CONSTANT    VARCHAR2(30) := 'POS_SCO_TOLERANCE_GRP';
  G_FILE_NAME CONSTANT    VARCHAR2(30) := 'POSGTOLS.pls';
  --g_module_prefix CONSTANT VARCHAR2(50) := 'po.plsql.' || g_pkg_name || '.';

 -- Read the profile option that enables/dISables the debug log
  g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');


PROCEDURE INITIALIZE_TOL_VALUES(itemtype        IN VARCHAR2,
  	                        itemkey         IN VARCHAR2,
  	                        actid           IN NUMBER,
  	                        funcmode        IN VARCHAR2,
                                resultout       OUT NOCOPY VARCHAR2)
IS
BEGIN

     POS_SCO_TOLERANCE_PVT.INITIALIZE_TOL_VALUES( itemtype,
                                                 itemkey,
                                                 actid,
                                                 funcmode,
                                                 resultout);


END INITIALIZE_TOL_VALUES;

PROCEDURE PROMISE_DATE_WITHIN_TOL( itemtype        IN  VARCHAR2,
 	                           itemkey         IN  VARCHAR2,
 	                           actid           IN  NUMBER,
 	                           funcmode        IN  VARCHAR2,
                                   resultout       OUT NOCOPY VARCHAR2)
IS

BEGIN


     POS_SCO_TOLERANCE_PVT.PROMISE_DATE_WITHIN_TOL (itemtype,
 	                                            itemkey,
 	                                            actid,
 	                           	            funcmode,
                                  	            resultout );





END PROMISE_DATE_WITHIN_TOL;

PROCEDURE UNIT_PRICE_WITHIN_TOL( itemtype        IN VARCHAR2,
 	                         itemkey         IN VARCHAR2,
 	                         actid           IN NUMBER,
 	                         funcmode        IN VARCHAR2,
                                 resultout       OUT NOCOPY VARCHAR2)
IS
BEGIN


     POS_SCO_TOLERANCE_PVT.UNIT_PRICE_WITHIN_TOL (itemtype,
                                                  itemkey,
                                                  actid,
                                                  funcmode,
                                                  resultout);



END UNIT_PRICE_WITHIN_TOL;


PROCEDURE SHIP_QUANTITY_WITHIN_TOL( itemtype        IN VARCHAR2,
 	                            itemkey         IN VARCHAR2,
 	                            actid           IN NUMBER,
 	                            funcmode        IN VARCHAR2,
                                    resultout       OUT NOCOPY VARCHAR2)
IS
BEGIN


    POS_SCO_TOLERANCE_PVT.SHIP_QUANTITY_WITHIN_TOL (itemtype,
                                                    itemkey,
                                                    actid,
                                                    funcmode,
                                                    resultout);



END  SHIP_QUANTITY_WITHIN_TOL ;



PROCEDURE DOC_AMOUNT_WITHIN_TOL( itemtype        IN VARCHAR2,
 	                         itemkey         IN VARCHAR2,
 	                         actid           IN NUMBER,
 	                         funcmode        IN VARCHAR2,
                                 resultout       OUT NOCOPY VARCHAR2)
IS
BEGIN


    POS_SCO_TOLERANCE_PVT.DOC_AMOUNT_WITHIN_TOL (itemtype,
                                                 itemkey,
                                                 actid,
                                                 funcmode,
                                                 resultout);



END DOC_AMOUNT_WITHIN_TOL;

PROCEDURE LINE_AMOUNT_WITHIN_TOL( itemtype        IN VARCHAR2,
 	                          itemkey         IN VARCHAR2,
 	                          actid           IN NUMBER,
 	                          funcmode        IN VARCHAR2,
                                  resultout       OUT NOCOPY VARCHAR2)
IS
BEGIN

   POS_SCO_TOLERANCE_PVT.LINE_AMOUNT_WITHIN_TOL(itemtype,
                                                itemkey,
                                                actid,
                                                funcmode,
                                                resultout);


END LINE_AMOUNT_WITHIN_TOL ;


PROCEDURE SHIP_AMOUNT_WITHIN_TOL( itemtype        IN VARCHAR2,
 	                          itemkey         IN VARCHAR2,
 	                          actid           IN NUMBER,
 	                          funcmode        IN VARCHAR2,
                                  resultout       OUT NOCOPY VARCHAR2)
IS
BEGIN


     POS_SCO_TOLERANCE_PVT.SHIP_AMOUNT_WITHIN_TOL(itemtype,
                                                  itemkey,
                                                  actid,
                                                  funcmode,
                                                  resultout);



END SHIP_AMOUNT_WITHIN_TOl;




PROCEDURE ROUTE_TO_REQUESTER(itemtype        IN VARCHAR2,
 	                     itemkey         IN VARCHAR2,
 	                     actid           IN NUMBER,
 	                     funcmode        IN VARCHAR2,
                             resultout       OUT NOCOPY VARCHAR2)

IS
BEGIN

    POS_SCO_TOLERANCE_PVT.ROUTE_TO_REQUESTER( itemtype,
                                           itemkey,
                                           actid,
                                           funcmode,
                                           resultout);





END ROUTE_TO_REQUESTER;

PROCEDURE MARK_SCO_FOR_REQ  (itemtype        IN VARCHAR2,
		             itemkey         IN VARCHAR2,
        		     actid           IN NUMBER,
	            	     funcmode        IN VARCHAR2,
                             resultout       OUT NOCOPY VARCHAR2)
IS
BEGIN


    POS_SCO_TOLERANCE_PVT.MARK_SCO_FOR_REQ( itemtype,
                                        itemkey,
                                        actid,
                                        funcmode,
                                        resultout);





 END MARK_SCO_FOR_REQ;


PROCEDURE ROUTE_SCO_BIZ_RULES( itemtype        IN VARCHAR2,
 	                       itemkey         IN VARCHAR2,
 	                       actid           IN NUMBER,
 	                       funcmode        IN VARCHAR2,
                               resultout       OUT NOCOPY VARCHAR2)
IS
BEGIN


     POS_SCO_TOLERANCE_PVT.ROUTE_SCO_BIZ_RULES(itemtype,
                                               itemkey,
                                               actid,
                                               funcmode,
                                               resultout);



END ROUTE_SCO_BIZ_RULES;



PROCEDURE AUTO_APP_BIZ_RULES( itemtype        IN VARCHAR2,
   	                      itemkey         IN VARCHAR2,
   	                      actid           IN NUMBER,
   	                      funcmode        IN VARCHAR2,
                              resultout       OUT NOCOPY VARCHAR2)
IS
BEGIN


     POS_SCO_TOLERANCE_PVT.AUTO_APP_BIZ_RULES(itemtype,
                                              itemkey,
                                              actid,
                                              funcmode,
                                              resultout);




END AUTO_APP_BIZ_RULES;



PROCEDURE PROMISE_DATE_CHANGE(itemtype        IN VARCHAR2,
  	                      itemkey         IN VARCHAR2,
  	                      actid           IN NUMBER,
  	                      funcmode        IN VARCHAR2,
                              resultout       OUT NOCOPY VARCHAR2)
IS
BEGIN

     POS_SCO_TOLERANCE_PVT.PROMISE_DATE_CHANGE(itemtype,
                                               itemkey,
                                               actid,
                                               funcmode,
                                               resultout);


END PROMISE_DATE_CHANGE;



PROCEDURE INITIATE_RCO_FLOW (itemtype        IN VARCHAR2,
   	                     itemkey         IN VARCHAR2,
   	                     actid           IN NUMBER,
   	                     funcmode        IN VARCHAR2,
                             resultout       OUT NOCOPY VARCHAR2)
IS
BEGIN


     POS_SCO_TOLERANCE_PVT.INITIATE_RCO_FLOW(itemtype,
                                             itemkey,
                                             actid,
                                             funcmode,
                                             resultout);



END INITIATE_RCO_FLOW;




PROCEDURE START_RCO_WORKFLOW (itemtype        IN VARCHAR2,
   	                      itemkey         IN VARCHAR2,
   	                      actid           IN NUMBER,
   	                      funcmode        IN VARCHAR2,
                              resultout       OUT NOCOPY VARCHAR2)
IS
BEGIN


     POS_SCO_TOLERANCE_PVT.START_RCO_WORKFLOW(itemtype,
                                              itemkey,
                                              actid,
                                              funcmode,
                                              resultout);


END START_RCO_WORKFLOW;

END POS_SCO_TOLERANCE_GRP;

/
