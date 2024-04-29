--------------------------------------------------------
--  DDL for Package Body CST_PERIODCLOSEOPTION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_PERIODCLOSEOPTION_PUB" AS
/* $Header: CSTINVRB.pls 120.1 2005/08/09 01:53:53 cmuthu noship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CST_periodCloseOption_PUB';

procedure shipping_txn_hook(
  P_API_VERSION         IN      NUMBER,
  I_ORG_ID              IN      NUMBER,
  I_ACCT_PERIOD_ID      IN      NUMBER,
  X_CLOSE_OPTION        OUT NOCOPY     NUMBER,
  X_RETURN_STATUS       OUT NOCOPY  NUMBER,
  X_MSG_COUNT           OUT NOCOPY  NUMBER,
  X_MSG_DATA            OUT NOCOPY  VARCHAR2
) IS

          l_api_name    CONSTANT       VARCHAR2(30) := 'shipping_txn_hook';
          l_api_version CONSTANT       NUMBER       := 1.0;

BEGIN

    -- standard call to check for call compatibility
    if not fnd_api.compatible_api_call (
                              l_api_version,
                              p_api_version,
                              l_api_name,
                              G_PKG_NAME ) then
         raise fnd_api.g_exc_unexpected_error;
    end if;

    -------------------------------------------------------------------------
    -- initialize api return status to success
    -------------------------------------------------------------------------
    x_return_status :=0;
    x_msg_count := 0;
    x_close_option := 0;


EXCEPTION

  when others then
    x_return_status := 1;
    x_close_option := -1;
    x_msg_count := 1;


END shipping_txn_hook;

FUNCTION get_shippingtxnhook_value (p_org_id          IN     NUMBER,
                                    p_acct_period_id  IN     NUMBER)
return NUMBER
IS
 l_close_option NUMBER;
 l_return_status NUMBER;
 l_msg_count NUMBER;
 l_msg_data  VARCHAR2(240);
BEGIN
 CST_PERIODCLOSEOPTION_PUB.shipping_txn_hook
                       (p_api_version   => 1.0,
                       i_org_id         => p_org_id,
                       i_acct_period_id => p_acct_period_id,
                       x_close_option   => l_close_option,
                       x_return_status  => l_return_status,
                       x_msg_count      => l_msg_count,
                       x_msg_data       => l_msg_data);

 IF (l_return_status <> 0) THEN
    RETURN -1;
 ELSE
    RETURN l_close_option;
 END IF;
EXCEPTION
WHEN OTHERS THEN
   RETURN -1;
END get_shippingtxnhook_value;

END cst_periodCloseOption_pub;



/
