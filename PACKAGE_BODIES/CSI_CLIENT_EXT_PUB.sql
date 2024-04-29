--------------------------------------------------------
--  DDL for Package Body CSI_CLIENT_EXT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_CLIENT_EXT_PUB" AS
-- $Header: csiclexb.pls 120.0 2005/05/25 02:35:08 appldev noship $

l_debug NUMBER := csi_t_gen_utility_pvt.g_debug_level;

PROCEDURE mtl_post_transaction(p_transaction_id  IN NUMBER,
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

END mtl_post_transaction;


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

PROCEDURE csi_error_resubmit(p_transaction_id  IN NUMBER,
                             x_return_status   OUT NOCOPY VARCHAR2,
                             x_error_message   OUT NOCOPY VARCHAR2)
IS
BEGIN

   -- Replace this with your code here

   x_return_status := FND_API.G_RET_STS_ERROR;
   x_error_message := NULL;

   -- After you put your custom code here you should then replace the x_return_status
   -- with the following line of commented out code . Initially "E" is being passed
   -- out in the return status so that the error will be retained in csi_txn_errors table.

   --x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_error_message := sqlerrm;

END csi_error_resubmit;

end CSI_CLIENT_EXT_PUB;

/
