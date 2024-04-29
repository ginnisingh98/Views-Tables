--------------------------------------------------------
--  DDL for Package CS_EXP_TERMINATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_EXP_TERMINATE_PVT" AUTHID CURRENT_USER as
/* $Header: csctexps.pls 115.0 99/07/16 08:52:17 porting ship  $ */

procedure exp_terminate_contract(
                                exp_term_date IN DATE
				);
END cs_exp_terminate_pvt;

 

/
