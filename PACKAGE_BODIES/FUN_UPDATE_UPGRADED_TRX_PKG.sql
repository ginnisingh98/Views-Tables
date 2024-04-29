--------------------------------------------------------
--  DDL for Package Body FUN_UPDATE_UPGRADED_TRX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_UPDATE_UPGRADED_TRX_PKG" AS
/* $Header: funupgrb.pls 120.0 2006/06/16 11:13:10 cjain noship $ */

PROCEDURE UPDATE_UPGRADED_TRX (err_buf              OUT NOCOPY VARCHAR2,
                               ret_code             OUT NOCOPY VARCHAR2,
                               p_org_id             IN         NUMBER,
                               p_legal_entity_id    IN         NUMBER) IS
BEGIN

         FND_FILE.PUT_LINE(FND_FILE.LOG,'Parameters');
         FND_FILE.PUT_LINE(FND_FILE.LOG,'----------');
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Organization Id: ' || p_org_id );
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Legal Entity Id: ' || p_legal_entity_id);
         update fun_trx_batches
         set from_le_id = p_legal_entity_id
         where from_le_id = -1
         and initiator_id = p_org_id;
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Number of Initiator Batches updated: '|| SQL%ROWCOUNT);

         update fun_trx_headers
         set to_le_id = p_legal_entity_id
         where to_le_id  = -1
         and recipient_id = p_org_id;
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Number of Recipient Transactions updated: '|| SQL%ROWCOUNT);

         COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Updation Failed');
    RAISE;
END UPDATE_UPGRADED_TRX;

END FUN_UPDATE_UPGRADED_TRX_PKG;

/
