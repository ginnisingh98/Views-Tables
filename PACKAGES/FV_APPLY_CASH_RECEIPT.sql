--------------------------------------------------------
--  DDL for Package FV_APPLY_CASH_RECEIPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_APPLY_CASH_RECEIPT" AUTHID CURRENT_USER as
-- $Header: FVXDCCRS.pls 120.3 2003/05/16 17:28:15 cmundis ship $

  g_PackageName VARCHAR2(30) := 'fv_apply_cash_receipt';

  PROCEDURE main
  (
    p_errbuf     OUT NOCOPY VARCHAR2,
    p_retcode    OUT NOCOPY VARCHAR2,
    p_batch_name IN VARCHAR2
  );

 End fv_apply_cash_receipt;

 

/
