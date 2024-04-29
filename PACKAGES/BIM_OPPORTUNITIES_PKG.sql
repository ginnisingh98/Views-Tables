--------------------------------------------------------
--  DDL for Package BIM_OPPORTUNITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIM_OPPORTUNITIES_PKG" AUTHID CURRENT_USER AS
/* $Header: bimopprs.pls 115.2 2000/01/07 16:15:16 pkm ship  $ */

FUNCTION ORDERS_GENERATED(p_opportunity_id NUMBER) RETURN NUMBER;

END BIM_OPPORTUNITIES_PKG;

 

/
