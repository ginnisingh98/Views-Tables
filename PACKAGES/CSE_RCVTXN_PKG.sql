--------------------------------------------------------
--  DDL for Package CSE_RCVTXN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSE_RCVTXN_PKG" AUTHID CURRENT_USER AS
-- $Header: CSEPOEXS.pls 115.9 2002/12/05 22:52:12 stutika noship $

-------------------------------------------------------------------------------
--  PROCEDURE NAME:       Receiving Transaction Post Exit Procedure

--  DESCRIPTION:          Called from Receiving FORM

--  CHANGE HISTORY:       stutika     05/29/2001     Created
-------------------------------------------------------------------------------

  PROCEDURE PostTransaction_Exit      (p_transaction_id    IN NUMBER,
				       p_interface_trx_id  IN NUMBER,
				       p_return_status 	   OUT NOCOPY VARCHAR2);

END CSE_RCVTXN_PKG;

 

/
