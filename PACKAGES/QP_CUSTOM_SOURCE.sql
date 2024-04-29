--------------------------------------------------------
--  DDL for Package QP_CUSTOM_SOURCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_CUSTOM_SOURCE" AUTHID CURRENT_USER AS
/* $Header: QPXCSOUS.pls 120.1 2005/06/09 23:37:17 appldev  $ */

--GLOBAL Constant holding the package name

G_PKG_NAME		    CONSTANT  VARCHAR2(30) := 'QP_CUSTOM_SOURCE';

/*Customizable Public Procedure*/

PROCEDURE Get_Custom_Attribute_Values
(       p_req_type_code                 IN VARCHAR2
,       p_pricing_type_code             IN VARCHAR2
,       x_qual_ctxts_result_tbl         OUT NOCOPY /* file.sql.39 change */ QP_ATTR_MAPPING_PUB.CONTEXTS_RESULT_TBL_TYPE
,       x_price_ctxts_result_tbl        OUT NOCOPY /* file.sql.39 change */ QP_ATTR_MAPPING_PUB.CONTEXTS_RESULT_TBL_TYPE
);

END QP_CUSTOM_SOURCE;

 

/
