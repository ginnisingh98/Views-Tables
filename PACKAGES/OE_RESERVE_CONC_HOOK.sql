--------------------------------------------------------
--  DDL for Package OE_RESERVE_CONC_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_RESERVE_CONC_HOOK" AUTHID CURRENT_USER as
/* $Header: OEXRSHOS.pls 120.0 2005/05/31 23:22:29 appldev noship $ */

-- Reserve Order Constants
RSV_RUN_SIMULATE            CONSTANT VARCHAR2(30) := 'SIMULATE';
RSV_RUN_RESERVE             CONSTANT VARCHAR2(30) := 'RESERVE';



Procedure Qty_Per_Business_Rule
(p_x_rsv_tbl           IN OUT NOCOPY /* file.sql.39 change */ OE_RESERVE_CONC.rsv_tbl_type);

Procedure Simulated_Results
(p_x_rsv_tbl           IN OUT NOCOPY /* file.sql.39 change */ OE_RESERVE_CONC.rsv_tbl_type);


END OE_RESERVE_CONC_HOOK;

 

/
