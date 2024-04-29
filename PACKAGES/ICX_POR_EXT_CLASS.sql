--------------------------------------------------------
--  DDL for Package ICX_POR_EXT_CLASS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_POR_EXT_CLASS" AUTHID CURRENT_USER AS
/* $Header: ICXEXTCS.pls 115.4 2004/03/31 18:46:08 vkartik ship $*/

CATEGORY_TYPE		PLS_INTEGER := 2;
TEMPLATE_HEADER_TYPE	PLS_INTEGER := 3;

PROCEDURE extractClassificationData;

END ICX_POR_EXT_CLASS;

 

/
