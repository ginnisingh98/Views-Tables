--------------------------------------------------------
--  DDL for Package CUN_CST_HOOK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CUN_CST_HOOK_PVT" AUTHID CURRENT_USER AS
/* $Header: CUNCSTHS.pls 115.6.1157.5 2002/03/18 19:04:09 pkm ship      $ */

PROCEDURE process_cost_transaction ( p_transaction_id               NUMBER,
							O_err_msg                  OUT NUMBER) ;


END cun_cst_hook_pvt;

 

/
