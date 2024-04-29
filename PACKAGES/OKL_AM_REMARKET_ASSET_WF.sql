--------------------------------------------------------
--  DDL for Package OKL_AM_REMARKET_ASSET_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_REMARKET_ASSET_WF" AUTHID CURRENT_USER AS
/* $Header: OKLRNWFS.pls 120.1 2005/10/30 04:02:36 appldev noship $ */

  G_REQUIRED_VALUE                  CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE	                CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN	                CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;

  PROCEDURE RAISE_RMK_CUSTOM_PROCESS_EVENT(p_asset_return_id IN NUMBER,
                                         p_item_number  IN VARCHAR2,
										 p_Item_Description IN VARCHAR2,
										 p_Item_Price IN NUMBER,
										 p_quantity IN NUMBER);

  PROCEDURE VALIDATE_ASSET_RETURN(itemtype	IN VARCHAR2,
				                itemkey  	IN VARCHAR2,
			                 	actid		IN NUMBER,
			                  	funcmode	IN VARCHAR2,
				                resultout OUT NOCOPY VARCHAR2	);

  PROCEDURE VALIDATE_ITEM_INFO( itemtype	IN VARCHAR2,
				                itemkey  	IN VARCHAR2,
			                 	actid		IN NUMBER,
			                  	funcmode	IN VARCHAR2,
				                resultout OUT NOCOPY VARCHAR2	);

  PROCEDURE CREATE_INV_ITEM  (itemtype	IN VARCHAR2,
				                itemkey  	IN VARCHAR2,
			                 	actid		IN NUMBER,
			                  	funcmode	IN VARCHAR2,
				                resultout OUT NOCOPY VARCHAR2	);

  PROCEDURE CREATE_INV_MISC_RECEIPT (itemtype	IN VARCHAR2,
				                itemkey  	IN VARCHAR2,
			                 	actid		IN NUMBER,
			                  	funcmode	IN VARCHAR2,
				                resultout OUT NOCOPY VARCHAR2	);

  PROCEDURE CREATE_ITEM_PRICE_LIST  (itemtype	IN VARCHAR2,
				                itemkey  	IN VARCHAR2,
			                 	actid		IN NUMBER,
			                  	funcmode	IN VARCHAR2,
				                resultout OUT NOCOPY VARCHAR2	);



END OKL_AM_REMARKET_ASSET_WF;

 

/
