--------------------------------------------------------
--  DDL for Package CTO_CUSTOM_CATALOG_DESC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_CUSTOM_CATALOG_DESC" AUTHID CURRENT_USER AS
/* $Header: CTOCUCLS.pls 115.0 2003/02/17 18:25:39 sbhaskar noship $ */
/*============================================================================+
|  Copyright (c) 1999 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|                                                                             |
| FILE NAME   : CTOCUCLS.pls                                                  |
| DESCRIPTION :                                                               |
|               Package specification for package which enables customers     |
|               to customize the catalog description of the configuration     |
|               item either during pre-configuration process or autocreate    |
|		Configuration item process.				      |
|                                                                             |
|               This package contains 2 functions namely :		      |
|		 - catalog_desc_method					      |
|		 - user_catalog_desc					      |
|									      |
|               * Function CATALOG_DESC_METHOD controls the flow of the code. |
|		This function should return one of the following values:      |
|		N = If you do NOT want to rollup the lower level's catalog    |
|                   value to upper level models. This is one of Oracle's std  |
|		    functionality. This is the default.                       |
|									      |
|		Y = If you want to rollup the lower level's catalog    	      |
|                   value to upper level models. This is als one of Oracle's  |
|		    std functionality.					      |
|									      |
|		C = Set this value if you do NOT want to use Oracle's std     |
|		    functionality.					      |
|									      |
|               * Function USER_CATALOG_DESC will be called only if function  |
|		CATALOG_DESC_METHOD returns "C" (custom).  This function has 3|
|		parameters:						      |
|			p_params					      |
|			p_catalog_dtls					      |
|			x_return_status					      |
|									      |
|		- p_params is a record-type and contains 2 elements namely:   |
|     			p_item_id    number				      |
|     			p_org_id     number				      |
|		Hence, p_params.p_item_id will have Inventory_Item_Id value for
|		the configuration item.					      |
|		And, p_params.p_org_id will have the organization_id value.   |
|									      |
|		- p_catalog_dtls is a table of records which contains 2       |
|		elements namely:					      |
|			cat_element_name	varchar2(30)		      |
|			cat_element_value	varchar2(30)		      |
|		p_catalog_dtls(i).cat_element_name will contain the element   |
|		name in its "i"th index.				      |
|		You need to update p_catalog_dtls(i).cat_element_value 	      |
|		with an appropriate value corresponding cat_element_name      |
|									      |
|		You SHOULD NEVER alter the index value of p_catalog_dtls pl/sql
|		table. Doing so will cause the process to fail.		      |
|									      |
|		- x_return_status is the OUT parameter which should be set    |
|		to one of the following values :			      |
|									      |
|			FND_API.G_RET_STS_SUCCESS			      |
|			to indicate success				      |
|									      |
|			FND_API.FND_API.G_RET_STS_ERROR 		      |
|			to indicate failure with expected status	      |
|									      |
|			FND_API.FND_API.G_RET_STS_UNEXP_ERROR 		      |
|			to indicate failure with unexpected status            |
|									      |
|		Note: This function will be called  for each newly 	      |
|		created configuration  					      |
|                                                                             |
| HISTORY     : 02/14/03  Shashi Bhaskaran    Initial Creation                |
|                                                                             |
*============================================================================*/

g_pkg_name     		CONSTANT  VARCHAR2(30) := 'CTO_CUSTOM_CATALOG_DESC';

type CATALOG_DTLS_REC is record (
     cat_element_name	MTL_DESCR_ELEMENT_VALUES.element_name%type,
     cat_element_value  MTL_DESCR_ELEMENT_VALUES.element_value%type
);

type INPARAMS is record (
     p_item_id    number,
     p_org_id     number
);

type CATALOG_DTLS_TBL_TYPE is table of CATALOG_DTLS_REC index by BINARY_INTEGER ;



function catalog_desc_method return varchar2;

procedure user_catalog_desc (
	p_params  	IN 		CTO_CUSTOM_CATALOG_DESC.inparams,
	p_catalog_dtls  IN OUT  NOCOPY  CTO_CUSTOM_CATALOG_DESC.catalog_dtls_tbl_type,
	x_return_status OUT     NOCOPY	VARCHAR2);


end CTO_CUSTOM_CATALOG_DESC;

 

/
