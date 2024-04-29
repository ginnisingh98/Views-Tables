--------------------------------------------------------
--  DDL for Package QP_PRICE_FORMULA_UPG_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_PRICE_FORMULA_UPG_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: QPXVUPFS.pls 120.0 2005/06/02 00:50:16 appldev noship $ */

 PROCEDURE Create_Parallel_Slabs(l_workers IN NUMBER);

 PROCEDURE Upgrade_Price_Formulas(l_worker IN NUMBER);

END QP_PRICE_FORMULA_UPG_UTIL_PVT;

 

/
