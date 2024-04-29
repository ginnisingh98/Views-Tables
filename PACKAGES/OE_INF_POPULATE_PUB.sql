--------------------------------------------------------
--  DDL for Package OE_INF_POPULATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_INF_POPULATE_PUB" AUTHID CURRENT_USER AS
/* $Header: OEXPIFPS.pls 120.0 2005/06/01 22:47:31 appldev noship $ */


PROCEDURE Populate_Interface
(   p_api_version_number            IN  NUMBER
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_order_number_from             IN  NUMBER
,   p_order_source_id               IN  NUMBER
);

FUNCTION GET_LINK_TO_LINE_REF
(   p_line_id                       IN NUMBER
)
RETURN VARCHAR2;

FUNCTION GET_TOP_MODEL_LINE_REF
(   p_line_id                       IN NUMBER
)
RETURN VARCHAR2;

FUNCTION GET_LINE_REF_FROM_LINE_ID
(   p_line_id                       IN NUMBER
)
RETURN VARCHAR2;

END OE_INF_POPULATE_PUB;

 

/
