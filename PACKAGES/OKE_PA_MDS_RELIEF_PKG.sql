--------------------------------------------------------
--  DDL for Package OKE_PA_MDS_RELIEF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_PA_MDS_RELIEF_PKG" AUTHID CURRENT_USER AS
/* $Header: OKEVMDSS.pls 120.0 2005/05/25 17:56:27 appldev noship $ */


TYPE mds_rec_type IS RECORD (
	  mtl_transaction_id Number
	, organization_id Number
	, inventory_item_id Number
	, transaction_source_id Number
	, transaction_source_type_id Number
	, trx_source_delivery_id Number
	, trx_source_line_id Number
	, revision Varchar2(3)
	, subinventory_code Varchar2(10)
	, locator_id Number
	, primary_quantity Number
	, transaction_quantity Number
	, transaction_source_name Varchar2(30)
	, transaction_date Date
	, mps_transaction_id Number
	, quantity Number
	, order_quantity Number
	, project_id Number
	, task_id Number
	, unit_number Varchar2(30)
  );


TYPE mds_tbl_type IS TABLE OF mds_rec_type
INDEX BY BINARY_INTEGER;

-- GLOBAL MESSAGE CONSTANTS

  G_FND_APP			CONSTANT VARCHAR2(200) := OKE_API.G_FND_APP;

  G_FORM_UNABLE_TO_RESERVE_REC 	CONSTANT VARCHAR2(200) := OKE_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED 	CONSTANT VARCHAR2(200) := OKE_API.G_FORM_RECORD_DELETED;

  G_FORM_RECORD_CHANGED 	CONSTANT VARCHAR2(200) := OKE_API.G_FORM_RECORD_CHANGED;

  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKE_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKE_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := OKE_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKE_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKE_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKE_API.G_CHILD_TABLE_TOKEN;
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKE_MDS_RELIEF';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKE_API.G_APP_NAME;



Procedure Mds_Relief( ERRBUF	OUT NOCOPY VARCHAR2
		    , RETCODE	OUT NOCOPY NUMBER);



END;




 

/
