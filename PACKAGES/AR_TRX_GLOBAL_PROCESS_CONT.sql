--------------------------------------------------------
--  DDL for Package AR_TRX_GLOBAL_PROCESS_CONT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_TRX_GLOBAL_PROCESS_CONT" AUTHID CURRENT_USER AS
/* $Header: ARINGTCS.pls 120.0 2004/09/30 20:51:18 orashid noship $ */

PROCEDURE insert_row (
  p_trx_contingencies_tbl ar_invoice_api_pub.trx_contingencies_tbl_type,
  x_errmsg        OUT NOCOPY  VARCHAR2,
  x_return_status OUT NOCOPY  VARCHAR2 );

END ar_trx_global_process_cont;

 

/
