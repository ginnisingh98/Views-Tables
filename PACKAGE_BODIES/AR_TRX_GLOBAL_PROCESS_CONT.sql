--------------------------------------------------------
--  DDL for Package Body AR_TRX_GLOBAL_PROCESS_CONT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_TRX_GLOBAL_PROCESS_CONT" AS
/* $Header: ARINGTCB.pls 120.3 2005/06/16 20:41:25 vcrisost noship $ */


  pg_debug VARCHAR2(1) := nvl(fnd_profile.value('AFLOG_ENABLED'),'N');


PROCEDURE insert_row (
  p_trx_contingencies_tbl ar_invoice_api_pub.trx_contingencies_tbl_type,
  x_errmsg        OUT NOCOPY  VARCHAR2,
  x_return_status OUT NOCOPY  VARCHAR2) IS

BEGIN

  IF pg_debug = 'Y'  THEN
    ar_invoice_utils.debug ('ar_trx_global_process_cont.insert_row (+)');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_trx_contingencies_tbl.COUNT > 0 THEN

    FOR i IN  p_trx_contingencies_tbl.FIRST ..
              p_trx_contingencies_tbl.LAST LOOP
      INSERT INTO ar_trx_contingencies_gt
      (
        trx_contingency_id,
        trx_line_id,
        contingency_id,
        expiration_date,
        expiration_days,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login,
        completed_by,
        completed_flag,
        expiration_event_date,
        org_id
)
      VALUES
      (
        p_trx_contingencies_tbl(i).trx_contingency_id,
        p_trx_contingencies_tbl(i).trx_line_id,
        p_trx_contingencies_tbl(i).contingency_id,
        p_trx_contingencies_tbl(i).expiration_date,
        p_trx_contingencies_tbl(i).expiration_days,
        p_trx_contingencies_tbl(i).attribute_category,
        p_trx_contingencies_tbl(i).attribute1,
        p_trx_contingencies_tbl(i).attribute2,
        p_trx_contingencies_tbl(i).attribute3,
        p_trx_contingencies_tbl(i).attribute4,
        p_trx_contingencies_tbl(i).attribute5,
        p_trx_contingencies_tbl(i).attribute6,
        p_trx_contingencies_tbl(i).attribute7,
        p_trx_contingencies_tbl(i).attribute8,
        p_trx_contingencies_tbl(i).attribute9,
        p_trx_contingencies_tbl(i).attribute10,
        p_trx_contingencies_tbl(i).attribute11,
        p_trx_contingencies_tbl(i).attribute12,
        p_trx_contingencies_tbl(i).attribute13,
        p_trx_contingencies_tbl(i).attribute14,
        p_trx_contingencies_tbl(i).attribute15,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        fnd_global.login_id,
        p_trx_contingencies_tbl(i).completed_by,
        p_trx_contingencies_tbl(i).completed_flag,
        p_trx_contingencies_tbl(i).expiration_event_date,
        arp_standard.sysparm.org_id
      );

    END LOOP;

  END IF;

  IF pg_debug = 'Y' THEN
    ar_invoice_utils.debug ('ar_trx_global_process_cont.insert_row (-)');
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_errmsg := 'Error:  ar_trx_global_process_cont.insert_row ' ||sqlerrm;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      RETURN;

END insert_row;

END ar_trx_global_process_cont;

/
