--------------------------------------------------------
--  DDL for Package POR_RCV_VALIDATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POR_RCV_VALIDATION_PKG" AUTHID CURRENT_USER AS
/* $Header: PORRCVVS.pls 115.5 2002/12/24 20:36:43 mrjiang noship $ */

procedure getTolerableQty(pLineLocationId	IN NUMBER,
		     	  pTotalQty		IN NUMBER,
			  pTolerableQty		OUT NOCOPY NUMBER,
			  pExceptionCode	OUT NOCOPY VARCHAR2);

END POR_RCV_VALIDATION_PKG;

 

/
