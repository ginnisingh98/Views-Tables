--------------------------------------------------------
--  DDL for Package Body CSE_CST_HOOK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSE_CST_HOOK_PVT" AS
-- $Header: CSECSTTB.pls 115.29 2002/12/09 23:33:01 jpwilson noship $

l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('CSE_DEBUG_OPTION'),'N');

PROCEDURE process_cost_transaction (p_transaction_id          NUMBER,
				    O_err_msg                  OUT NOCOPY NUMBER)
IS
BEGIN
NULL;
END process_cost_transaction ;

END CSE_CST_HOOK_PVT ;


/
