--------------------------------------------------------
--  DDL for Package CST_PERIODCLOSEOPTION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_PERIODCLOSEOPTION_PUB" AUTHID CURRENT_USER AS
/* $Header: CSTINVRS.pls 120.1 2005/08/09 01:45:47 cmuthu noship $ */

procedure shipping_txn_hook(
  P_API_VERSION         IN      NUMBER,
  I_ORG_ID              IN      NUMBER,
  I_ACCT_PERIOD_ID      IN      NUMBER,
  X_CLOSE_OPTION        OUT NOCOPY     NUMBER,
  X_RETURN_STATUS       OUT NOCOPY  NUMBER,
  X_MSG_COUNT           OUT NOCOPY  NUMBER,
  X_MSG_DATA            OUT NOCOPY  VARCHAR2
);

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- FUNCTION                                                                --
-- get_shippingtxnhook_value: returns the value of the shipping hook       --
--                            (CST_PERIODCLOSEOPTION_PUB.shipping_txn_hook)--
-- PARAMETERS                                                              --
-- p_org_id          Organization ID                                       --
-- p_acct_period_id  Accounting Period ID                                  --
-----------------------------------------------------------------------------
FUNCTION get_shippingtxnhook_value (
 p_org_id            IN          NUMBER,
 p_acct_period_id    IN          NUMBER)
return NUMBER;

END cst_periodCloseOption_pub;

 

/
