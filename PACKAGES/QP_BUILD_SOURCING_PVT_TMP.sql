--------------------------------------------------------
--  DDL for Package QP_BUILD_SOURCING_PVT_TMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_BUILD_SOURCING_PVT_TMP" AUTHID CURRENT_USER AS
/* $Header: QPXVBSTS.pls 120.0 2005/06/02 00:31:37 appldev noship $ */

PROCEDURE Get_Attribute_Values
(       p_req_type_code                 IN VARCHAR2
,       p_pricing_type_code             IN VARCHAR2
,       x_qual_ctxts_result_tbl 	OUT NOCOPY QP_ATTR_MAPPING_PUB.CONTEXTS_RESULT_TBL_TYPE
,       x_price_ctxts_result_tbl        OUT NOCOPY QP_ATTR_MAPPING_PUB.CONTEXTS_RESULT_TBL_TYPE
);

END QP_BUILD_SOURCING_PVT_TMP;

 

/
