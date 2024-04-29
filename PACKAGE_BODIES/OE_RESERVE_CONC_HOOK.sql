--------------------------------------------------------
--  DDL for Package Body OE_RESERVE_CONC_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_RESERVE_CONC_HOOK" AS
/* $Header: OEXRSHOB.pls 120.0 2005/06/01 00:11:34 appldev noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_RESERVE_CONC_HOOK';

Procedure Qty_Per_Business_Rule
(p_x_rsv_tbl           IN OUT NOCOPY /* file.sql.39 change */ OE_RESERVE_CONC.rsv_tbl_type)
IS
BEGIN
   -- Write your code here
   NULL;
END Qty_Per_Business_Rule;

Procedure Simulated_Results
(p_x_rsv_tbl           IN OUT NOCOPY /* file.sql.39 change */ OE_RESERVE_CONC.rsv_tbl_type)
IS
BEGIN
   -- Write your code here
   NULL;
END Simulated_Results;


END OE_RESERVE_CONC_HOOK;

/
