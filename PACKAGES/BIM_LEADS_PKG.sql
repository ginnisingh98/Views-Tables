--------------------------------------------------------
--  DDL for Package BIM_LEADS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIM_LEADS_PKG" AUTHID CURRENT_USER AS
/* $Header: bimleads.pls 115.2 2000/01/07 16:14:30 pkm ship  $ */

FUNCTION ORDERS_GENERATED(p_lead_id NUMBER) RETURN NUMBER;

END BIM_LEADS_PKG;

 

/
