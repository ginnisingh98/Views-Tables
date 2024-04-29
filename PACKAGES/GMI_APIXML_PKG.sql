--------------------------------------------------------
--  DDL for Package GMI_APIXML_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_APIXML_PKG" AUTHID CURRENT_USER AS
/* $Header: GMIXAPIS.pls 115.4 2002/11/04 20:41:02 jdiiorio noship $ */

PROCEDURE api_selector (
 item_type	IN	 VARCHAR2,
 item_key	IN	 VARCHAR2,
 actid	 	IN	 NUMBER,
 command	IN	 VARCHAR2,
 resultout	IN OUT NOCOPY VARCHAR2 );

PROCEDURE process_transaction (
 item_type	IN	 VARCHAR2,
 item_key	IN	 VARCHAR2,
 actid	 	IN	 NUMBER,
 funcmode	IN	 VARCHAR2,
 resultout	IN OUT NOCOPY VARCHAR2 );

PROCEDURE create_item (
 item_type	IN	 VARCHAR2,
 item_key	IN	 VARCHAR2,
 actid	 	IN	 NUMBER,
 funcmode	IN	 VARCHAR2,
 resultout	IN OUT NOCOPY VARCHAR2 );

PROCEDURE create_lot (
 item_type	IN	 VARCHAR2,
 item_key	IN	 VARCHAR2,
 actid	 	IN	 NUMBER,
 funcmode	IN	 VARCHAR2,
 resultout	IN OUT NOCOPY VARCHAR2 );

PROCEDURE create_lot_conversion (
 item_type	IN	 VARCHAR2,
 item_key	IN	 VARCHAR2,
 actid	 	IN	 NUMBER,
 funcmode	IN	 VARCHAR2,
 resultout	IN OUT NOCOPY VARCHAR2 );


PROCEDURE confirm_api_selector (
 item_type	IN	 VARCHAR2,
 item_key	IN	 VARCHAR2,
 actid	 	IN	 NUMBER,
 command	IN	 VARCHAR2,
 resultout	IN OUT NOCOPY VARCHAR2 );

PROCEDURE send_error_cbod (

  item_type	IN	 VARCHAR2,
  item_key	IN	 VARCHAR2,
  actid	 	IN	 NUMBER,
  command	IN	 VARCHAR2,
  resultout	IN OUT NOCOPY VARCHAR2 );

END Gmi_Apixml_Pkg;

 

/
