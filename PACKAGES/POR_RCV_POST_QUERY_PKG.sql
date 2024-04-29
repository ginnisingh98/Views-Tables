--------------------------------------------------------
--  DDL for Package POR_RCV_POST_QUERY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POR_RCV_POST_QUERY_PKG" AUTHID CURRENT_USER AS
/* $Header: PORRCVQS.pls 115.3 2003/01/30 00:26:56 jizhang noship $ */

procedure getDetails(pItemId		IN NUMBER,
		     pOrgId		IN NUMBER,
		     pRequestorId	IN NUMBER,
		     pDistributionId	IN NUMBER,
		     pOrderType		IN VARCHAR2,
		     pReqLineId		IN OUT NOCOPY NUMBER,
		     pItemNumber	OUT NOCOPY VARCHAR2,
		     pRequestorName	OUT NOCOPY VARCHAR2,
		     pReqNum		OUT NOCOPY VARCHAR2,
		     pReqHeaderId	OUT NOCOPY NUMBER,
		     pSPN		OUT NOCOPY VARCHAR2,
		     pDistributionNum	OUT NOCOPY NUMBER);

function getReqNum(pOrderType           IN VARCHAR2,
                   pReqLineId           IN Number,
                   pDistributionId      IN Number) RETURN VARCHAR2;


procedure getItemNumber(pItemId 	IN NUMBER,
			pOrgId		IN NUMBER,
			pItemNum	OUT NOCOPY VARCHAR2);

procedure getRequestorName(pRequestorId 	IN NUMBER,
			   pName		OUT NOCOPY VARCHAR2);

procedure getReqInfoREQ(pReqLineId          IN NUMBER,
                        pReqNum             OUT NOCOPY VARCHAR2,
                        pReqHeaderId        OUT NOCOPY NUMBER);

procedure getReqInfo(pDistributionId	IN NUMBER,
		     pReqNum		OUT NOCOPY VARCHAR2,
		     pReqHeaderId	OUT NOCOPY NUMBER,
		     pReqLineId		OUT NOCOPY NUMBER);

procedure getSPN(pDistributionId 	IN NUMBER,
		 pSPN			OUT NOCOPY VARCHAR2,
		 pDistributionNum	OUT NOCOPY NUMBER);

function getOrderType(pOrderTypeCode IN VARCHAR2) RETURN VARCHAR2;

function getOrderNumber(pReqHeaderId IN NUMBER) RETURN VARCHAR2;
function getSupplier(pReqHeaderId IN NUMBER) RETURN VARCHAR2;


END POR_RCV_POST_QUERY_PKG;

 

/
