--------------------------------------------------------
--  DDL for Package Body PN_LEASE_DETAILS_SEND_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_LEASE_DETAILS_SEND_UPD" AS
  -- $Header: PNUPLEDB.pls 120.2 2005/12/01 10:00:53 appldev noship $

-------------------------------------------------------------------------------
-- PROCDURE     : UPDATE_LEASE_SE
-- INVOKED FROM :
-- PURPOSE      :
-- HISTORY      :
-- 14-JUL-05  hareesha o Bug 4284035 - Replaced pn_leases with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE update_lease_se (
   errbuf            OUT NOCOPY     VARCHAR2,
   retcode           OUT NOCOPY     VARCHAR2,
   p_lease_class     IN      VARCHAR2,
   p_lease_num_from  IN      VARCHAR2,
   p_lease_num_to    IN      VARCHAR2)
IS
   v_getleaseid                   pn_leases.lease_id%TYPE;
   s_count                        NUMBER := 0;
   l_lease_num                    pn_leases.lease_num%TYPE;
   v_batch_size                   NUMBER := 1000;
   v_counter                      NUMBER := 0;
   l_lastupdatedate               DATE   :=SYSDATE;
   l_lastupdatedby                NUMBER :=fnd_global.user_id;
   l_lastupdatelogin              NUMBER :=fnd_global.login_id;

   CURSOR c_getleaseid IS
      SELECT l.lease_id                        lleaseid,
             l.lease_class_code,
             l.name,
             l.lease_num,
             d.lease_detail_id,
             d.lease_change_id,
             d.lease_id,
             d.responsible_user                dresponsibleeuserid,
             d.expense_account_id,
             d.lease_commencement_date,
             d.lease_termination_date,
             d.lease_execution_date,
             d.last_update_date,
             d.last_updated_by,
             d.creation_date,
             d.created_by,
             d.last_update_login,
             d.attribute_category,
             d.attribute1,
             d.attribute2,
             d.attribute3,
             d.attribute4,
             d.attribute5,
             d.attribute6,
             d.attribute7,
             d.attribute8,
             d.attribute9,
             d.attribute10,
             d.attribute11,
             d.attribute12,
             d.attribute13,
             d.attribute14,
             d.attribute15,
             d.accrual_account_id,
             d.receivable_account_id,
             d.term_template_id
      FROM   pn_leases l, pn_lease_details_all d
      WHERE  l.lease_id = d.lease_id
      AND    lease_num BETWEEN NVL(p_lease_num_from,lease_num) AND
                               NVL(p_lease_num_to,lease_num)
      AND    lease_class_code = NVL(p_lease_class,lease_class_code)
      AND    l.status        = 'F'
      AND    d.send_entries  = 'Y';
BEGIN
   pnp_debug_pkg.debug('PN_LEASE_DETAILS_SEND_UPD.UPDATE_LEASE_SE (+)');

   -- Get from dirname from db later,
   -- and use sequence for unique filenames
   fnd_file.put_names('PNUPLEDB.log', 'PNUPLEDB.out', '/sqlcom/out');

   v_counter := 0;

   FOR v_lease IN c_getleaseid
   LOOP
      pn_lease_details_pkg.update_row
      (
        x_lease_detail_id          => v_lease.lease_detail_id
       ,x_lease_change_id          => 0
       ,x_lease_id                 => v_lease.lease_id
       ,x_responsible_user         => v_lease.dresponsibleeuserid
       ,x_expense_account_id       => v_lease.expense_account_id
       ,x_lease_commencement_date  => v_lease.lease_commencement_date
       ,x_lease_termination_date   => v_lease.lease_termination_date
       ,x_lease_execution_date     => v_lease.lease_execution_date
       ,x_last_update_date         => l_lastUpdateDate
       ,x_last_updated_by          => l_lastupdatedby
       ,x_last_update_login        => l_lastupdatelogin
       ,x_accrual_account_id       => v_lease.accrual_account_id
       ,x_receivable_account_id    => v_lease.receivable_account_id
       ,x_attribute_category       => v_lease.attribute_category
       ,x_attribute1               => v_lease.attribute1
       ,x_attribute2               => v_lease.attribute2
       ,x_attribute3               => v_lease.attribute3
       ,x_attribute4               => v_lease.attribute4
       ,x_attribute5               => v_lease.attribute5
       ,x_attribute6               => v_lease.attribute6
       ,x_attribute7               => v_lease.attribute7
       ,x_attribute8               => v_lease.attribute8
       ,x_attribute9               => v_lease.attribute9
       ,x_attribute10              => v_lease.attribute10
       ,x_attribute11              => v_lease.attribute11
       ,x_attribute12              => v_lease.attribute12
       ,x_attribute13              => v_lease.attribute13
       ,x_attribute14              => v_lease.attribute14
       ,x_attribute15              => v_lease.attribute15
       ,x_term_template_id         => v_lease.term_template_id
      );

      -------------------------------------------
      -- For Conc Log/Output files
      ------------------------------------------
      fnd_message.set_name ('PN','PN_UPLED_LS_DTLS');
      fnd_message.set_token ('ID',v_lease.lease_id);
      fnd_message.set_token ('NUM',v_lease.lease_num);
      fnd_message.set_token ('CLASS',v_lease.lease_class_code);
      pnp_debug_pkg.put_log_msg(fnd_message.get);
      pnp_debug_pkg.put_log_msg (' ');

      s_count := s_count + 1;
      IF v_counter = v_batch_size THEN
         COMMIT;
         v_counter := 0;
      END IF;
   END LOOP;
   COMMIT;

   pnp_debug_pkg.put_log_msg('
   ================================================================================');
   fnd_message.set_name ('PN','PN_UPLED_PROC');
   fnd_message.set_token ('NUM',s_count);
   pnp_debug_pkg.put_log_msg(fnd_message.get);
   pnp_debug_pkg.put_log_msg('
   ================================================================================');
   pnp_debug_pkg.debug('PN_LEASE_DETAILS_SEND_UPD.update_lease_se (-)');
EXCEPTION
   WHEN OTHERS THEN
      raise_application_error ('-20001','Error ' || TO_CHAR(sqlcode) );
      Errbuf  := SQLERRM;
      Retcode := 2;
END update_lease_se;

END pn_lease_details_send_upd;

/
