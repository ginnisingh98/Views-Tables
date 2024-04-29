--------------------------------------------------------
--  DDL for Package Body CSE_CLIENT_EXT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSE_CLIENT_EXT_PUB" AS
-- $Header: CSECLEXB.pls 115.6 2003/01/17 00:17:43 jpwilson noship $

l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('CSE_DEBUG_OPTION'),'N');

PROCEDURE rcv_post_transaction(p_transaction_id  IN NUMBER,
                               x_return_status   OUT NOCOPY VARCHAR2,
                               x_error_message   OUT NOCOPY VARCHAR2)
IS
BEGIN

   -- Replace this with your code here

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_error_message := NULL;

EXCEPTION

   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_error_message := sqlerrm;

END rcv_post_transaction;

end CSE_CLIENT_EXT_PUB;

/
