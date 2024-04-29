--------------------------------------------------------
--  DDL for Package BIM_PRODUCT_CATEG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIM_PRODUCT_CATEG_PKG" AUTHID CURRENT_USER AS
/* $Header: bimprods.pls 115.0 2000/01/07 16:15:21 pkm ship  $ */

FUNCTION GET_INTEREST_CODE_ID(
           p_interest_type_id  IN NUMBER,
           p_interest_code     IN VARCHAR2,
           p_code_type         IN VARCHAR2 )
RETURN NUMBER ;

END BIM_PRODUCT_CATEG_PKG;

 

/
