--------------------------------------------------------
--  DDL for Package MSC_WS_OTM_BPEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_WS_OTM_BPEL" AUTHID CURRENT_USER AS
/* $Header: MSCWOTMS.pls 120.8 2008/02/19 20:14:31 rolar noship $ */

/*TYPE MsgTokenValuePair IS RECORD
(
token  VARCHAR2(60),
value  VARCHAR2(60)
);
TYPE MsgTokenValuePairList   IS TABLE OF   MsgTokenValuePair;*/

--================ GET PLANNER  =======================

procedure GetPlanner_1( srInstanceId IN NUMBER,
                      inventoryItemId IN NUMBER,
                      orgId IN NUMBER,
                      planner OUT nocopy varchar2,
                      status OUT nocopy varchar2) ;

--================ Get Punchout URI ==================
function GetPunchoutURI(srInstanceId IN NUMBER,
                        otmReleaseGid IN varchar2) return varchar2;

--================ ODS =======================

procedure   AddLineId ( poIdString IN varchar2,
                        pnewArrivalDate IN varchar2,
                        ReleaseGid  IN  varchar2,
                        ReleaseLineGid IN varchar2,
                        tranzId out nocopy NUMBER,
                        status out nocopy varchar2);

procedure   AddLineSO ( pnewArrivalDate IN varchar2,
                        ReleaseGid  IN  varchar2,
                        ReleaseLineGid IN varchar2,
                        isInternalSO IN varchar2,
                        tranzId out nocopy NUMBER,
                        status out nocopy varchar2);
--================ PDS =======================

procedure UpdatePDS( status OUT nocopy VARCHAR2);
procedure UpdatePDS_1( tranzId IN NUMBER,
                       bpelOrderType IN NUMBER,
                       status OUT nocopy VARCHAR2);

PROCEDURE UpdatePDS_Order( transId IN NUMBER ,
                           order_type IN NUMBER,
                           status OUT nocopy varchar2);
PROCEDURE UpdatePDS_PO( planId IN NUMBER,
                        transId IN NUMBER,
                        status OUT nocopy varchar2);
PROCEDURE UpdatePDS_SO( planId IN NUMBER,
                        transId IN NUMBER,
                        status OUT nocopy varchar2);


PROCEDURE GenerateException( planId IN NUMBER, transId IN NUMBER, isPoShipment IN NUMBER, status out nocopy varchar2);
PROCEDURE GenerateException_SO( planId IN NUMBER, transId IN NUMBER, status out nocopy varchar2);


PROCEDURE UpdateNewColumnAndFirmDate_PO( planId IN NUMBER,
                                         transId IN NUMBER,
                                         isPoShipment out nocopy NUMBER,
                                         status out nocopy varchar2);

PROCEDURE UpdateNewColumnAndFirmDate_SO( planId IN NUMBER,
                                         transId IN NUMBER,
                                         status out nocopy varchar2);

-- ================= NOTIFICATION =============================
procedure SendNotification_1 ( tranzId IN NUMBER,
                               status out nocopy varchar2) ;

procedure GetDataForNotification(lineLocationId IN NUMBER,
                                 srInstanceId IN NUMBER,
                                 orderNumber OUT nocopy VARCHAR2,
                                 inventoryItemId out nocopy NUMBER,
                                 orgId out nocopy NUMBER);

--================ CP ====================================

procedure UpdateKeyDateInCP ( status OUT NOCOPY VARCHAR2);
procedure UpdateCP_1 ( tranzId IN NUMBER,
                       status OUT NOCOPY VARCHAR2);

procedure Update_CP ( lineLocationId IN NUMBER, arrivalDate IN DATE, status OUT NOCOPY VARCHAR2);
function getKeyDate(orderNumber IN VARCHAR2,
                              lineNumber IN VARCHAR2,
                              releaseNumber IN VARCHAR2,
                              lastRefreshNumber IN NUMBER) RETURN DATE;


--==================  general ================================
procedure AppsInit;

--==================  Purge older  than 90 days records ================================
procedure PurgeTransportationUpdates;


END;



/
