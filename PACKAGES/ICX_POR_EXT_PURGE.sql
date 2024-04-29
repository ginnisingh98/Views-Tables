--------------------------------------------------------
--  DDL for Package ICX_POR_EXT_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_POR_EXT_PURGE" AUTHID CURRENT_USER AS
/* $Header: ICXEXTPS.pls 115.6 2004/03/31 18:46:28 vkartik ship $*/


NORMAL_MODE	PLS_INTEGER := 0;
CATEGORY_MODE	PLS_INTEGER := 1;
ITEM_MODE	PLS_INTEGER := 2;
ALL_MODE	PLS_INTEGER := 3;

VOID_ID		PLS_INTEGER := -1;

PROCEDURE purgeClassificationData(pMode     IN PLS_INTEGER DEFAULT NORMAL_MODE,
                                  pInvCatId IN NUMBER DEFAULT VOID_ID);
PROCEDURE purgeItemData(pMode 		    IN PLS_INTEGER DEFAULT NORMAL_MODE,
                        pInvCatItemId 	    IN NUMBER DEFAULT VOID_ID);

END ICX_POR_EXT_PURGE;

 

/
