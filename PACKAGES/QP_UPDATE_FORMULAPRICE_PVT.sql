--------------------------------------------------------
--  DDL for Package QP_UPDATE_FORMULAPRICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_UPDATE_FORMULAPRICE_PVT" AUTHID CURRENT_USER AS
/* $Header: QPXVUFPS.pls 120.1 2005/06/16 01:56:40 appldev  $ */

--GLOBAL Constant holding the package name

G_PKG_NAME		    CONSTANT  VARCHAR2(30) := 'QP_UPDATE_FORMULAPRICE_PVT';

PROCEDURE Update_Formula_Price
(
 errbuf                 OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
 retcode                OUT NOCOPY /* file.sql.39 change */   NUMBER,
 p_update_flagged_items IN    VARCHAR2,
 p_retrieve_all_flag    IN    VARCHAR2,
 p_price_formula_id     IN 	NUMBER
);

END QP_UPDATE_FORMULAPRICE_PVT;

 

/
