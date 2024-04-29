--------------------------------------------------------
--  DDL for Package QP_BUILD_SOURCING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_BUILD_SOURCING_PVT" AUTHID CURRENT_USER AS
/* $Header: QPXVATTS.pls 120.0 2005/06/02 00:52:33 appldev noship $ */

/*
 * PLEASE DON'T ADD ANY VARIABLES TO THIS PACKAGE.
 * ADDING VARIABLES TO THIS PACKAGE WILL MAKE THIS PACKAGE STATEFUL,
 * MEANING SESSION MEMORY IMAGE OF THE PACKAGE BECOMES INVALID
 * WHEN PACKAGE IS RECOMPILED.
 * */

 -- bug2892096 Added global variable to store request type code
 -- Removed the global variable for the bug#3848849
 --G_REQ_TYPE_CODE VARCHAR2(10);

PROCEDURE Get_Attribute_Values
(       p_req_type_code                 IN VARCHAR2
,       p_pricing_type_code             IN VARCHAR2
,       x_qual_ctxts_result_tbl 	OUT NOCOPY QP_ATTR_MAPPING_PUB.CONTEXTS_RESULT_TBL_TYPE
,       x_price_ctxts_result_tbl        OUT NOCOPY QP_ATTR_MAPPING_PUB.CONTEXTS_RESULT_TBL_TYPE
);

FUNCTION Is_Attribute_Used(p_attribute_context IN VARCHAR2, p_attribute_code IN VARCHAR2) RETURN VARCHAR2;

END QP_BUILD_SOURCING_PVT;

 

/
