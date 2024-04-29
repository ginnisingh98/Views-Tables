--------------------------------------------------------
--  DDL for Package OKL_AM_OM_REMARKET_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_OM_REMARKET_WF" AUTHID CURRENT_USER AS
/* $Header: OKLROWFS.pls 115.2 2002/12/18 12:49:12 kjinger noship $ */


  SUBTYPE artv_rec_type IS OKL_ASSET_RETURNS_PUB.artv_rec_type;
  SUBTYPE taiv_tbl_type IS okl_trx_ar_invoices_pub.taiv_tbl_type;

  PROCEDURE reduce_item_quantity(   itemtype	IN VARCHAR2,
				                    itemkey  	IN VARCHAR2,
			                 	    actid		IN NUMBER,
			                  	    funcmode	IN VARCHAR2,
				                    resultout OUT NOCOPY VARCHAR2);

  PROCEDURE dispose_asset(  itemtype	IN VARCHAR2,
				            itemkey  	IN VARCHAR2,
			                actid		IN NUMBER,
			                funcmode	IN VARCHAR2,
				            resultout OUT NOCOPY VARCHAR2 );

  PROCEDURE create_invoice(
                            itemtype	IN VARCHAR2,
				            itemkey  	IN VARCHAR2,
			                actid		IN NUMBER,
			                funcmode	IN VARCHAR2,
				            resultout OUT NOCOPY VARCHAR2 );

  PROCEDURE set_asset_return_status(
                            itemtype	IN VARCHAR2,
				            itemkey  	IN VARCHAR2,
			                actid		IN NUMBER,
			                funcmode	IN VARCHAR2,
				            resultout OUT NOCOPY VARCHAR2 );




END OKL_AM_OM_REMARKET_WF;

 

/
