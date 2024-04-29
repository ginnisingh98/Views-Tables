--------------------------------------------------------
--  DDL for Package CSI_INV_TXN_HOOK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_INV_TXN_HOOK_PKG" AUTHID CURRENT_USER AS
-- $Header: csiinvts.pls 120.0 2005/05/24 17:25:29 appldev noship $

PROCEDURE postTransaction(p_header_id       IN NUMBER,
                          p_transaction_id  IN NUMBER,
                          x_return_status   OUT NOCOPY VARCHAR2);

end CSI_INV_TXN_HOOK_PKG;

 

/
