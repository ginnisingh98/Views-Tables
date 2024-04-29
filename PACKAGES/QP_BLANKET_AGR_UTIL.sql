--------------------------------------------------------
--  DDL for Package QP_BLANKET_AGR_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_BLANKET_AGR_UTIL" AUTHID CURRENT_USER AS
/* $Header: QPXBKUTS.pls 120.0 2005/06/02 00:31:04 appldev noship $ */

-- Global Constants
G_PKG_NAME	VARCHAR2(30) := 'QP_BLANKET_AGR_UTIL';


FUNCTION GET_ATTRIBUTE_CODE( p_FlexField_Name      IN  VARCHAR2,
                    	     p_Context_Name        IN  VARCHAR2,
                    	     p_attribute           IN  VARCHAR2 ) RETURN VARCHAR2;

END QP_BLANKET_AGR_UTIL;

 

/
