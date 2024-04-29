--------------------------------------------------------
--  DDL for Package OKE_PRINT_CONTRACT_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_PRINT_CONTRACT_WF" AUTHID CURRENT_USER AS
/* $Header: OKEWCPPS.pls 115.1 2003/12/19 23:11:13 tweichen noship $ */

PROCEDURE Raise_Business_Event
( P_Header_ID             IN                     VARCHAR2
, P_Major_Version         IN                     NUMBER
, X_Item_Key              OUT         NOCOPY     VARCHAR2
);


PROCEDURE Initialize
( ItemType            IN     			 VARCHAR2
, ItemKey             IN     			 VARCHAR2
, ActID               IN    			 NUMBER
, FuncMode            IN    		         VARCHAR2
, ResultOut           OUT 	      NOCOPY     VARCHAR2
);

FUNCTION getEventData
( p_itemType                 IN            VARCHAR2
, p_itemKey                  IN            VARCHAR2
)RETURN CLOB;

END OKE_PRINT_CONTRACT_WF;

 

/
