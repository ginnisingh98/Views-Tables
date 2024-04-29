--------------------------------------------------------
--  DDL for Package Body PN_CREATE_ACC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_CREATE_ACC" as
  -- $Header: PNCRACCB.pls 120.6.12010000.2 2009/03/16 12:09:28 rkartha ship $


  CURSOR c_ar_data (
           p_low_lease_id    pn_leases.lease_id%TYPE,
           p_high_lease_id   pn_leases.lease_id%TYPE,
           p_sch_start_date  pn_payment_schedules.schedule_date%TYPE,
           p_sch_end_date    pn_payment_schedules.schedule_date%TYPE,
           p_period_name     pn_payment_schedules.period_name%TYPE,
           p_customer_id     pn_payment_terms.customer_id%TYPE)
  IS
  SELECT  pt.payment_term_id,
          pt.lease_id,
          pi.payment_item_id,
          pi.accounted_date,
          ps.schedule_date,
          pt.legal_entity_id,
          pt.set_of_books_id,
          pi.org_id,
          ps.payment_schedule_id,
          pi1.actual_amount,
          pi.due_date  -- Added for Bug#8303091
  FROM    PN_PAYMENT_TERMS pt,
          PN_LEASES_ALL le ,
          PN_PAYMENT_ITEMS_ALL     pi,
          PN_PAYMENT_ITEMS_ALL     pi1,
          PN_PAYMENT_SCHEDULES_ALL ps
  WHERE   pt.lease_id = le.lease_id
  AND     le.lease_class_code  in ('THIRD_PARTY','SUB_LEASE')
  AND     LE.LEASE_ID  BETWEEN P_LOW_LEASE_ID AND P_HIGH_LEASE_ID
  AND     ps.lease_id = le.lease_id
  AND     pi.payment_schedule_id = ps.payment_schedule_id
  AND     pi.payment_term_id = pt.payment_term_id
  AND     ps.payment_Status_lookup_code ='APPROVED'
  AND     ps.schedule_date between p_sch_start_date and p_sch_end_date
  AND     ps.period_name = nvl(p_period_name ,ps.period_name)
  AND     pi.payment_item_type_lookup_code  = 'NORMALIZED'
  AND     pi.transferred_to_ar_flag  is  NULL
  AND     PT.NORMALIZE = 'Y'
  AND     LE.STATUS ='F'
  AND     pt.customer_id = nvl(p_customer_id,pt.customer_id)
  AND     pi1.payment_schedule_id = pi.payment_schedule_id
  AND     pi1.payment_term_id = pi.payment_term_id
  AND     pi1.payment_item_type_lookup_code  = 'CASH'
  AND     ((pi1.transferred_to_ar_flag  ='Y' AND pi1.actual_Amount <>0 )
            OR (pi.transferred_to_ar_flag IS NULL AND pi1.actual_Amount = 0 ))
  ORDER BY ps.payment_schedule_id;

  CURSOR c_ar_data_le_upg (
           p_low_lease_id    pn_leases.lease_id%TYPE,
           p_high_lease_id   pn_leases.lease_id%TYPE,
           p_sch_start_date  pn_payment_schedules.schedule_date%TYPE,
           p_sch_end_date    pn_payment_schedules.schedule_date%TYPE,
           p_period_name     pn_payment_schedules.period_name%TYPE,
           p_customer_id     pn_payment_terms.customer_id%TYPE)
  IS
  SELECT  pt.payment_term_id payment_term_id,
          pt.legal_entity_id legal_entity_id,
          pt.org_id org_id,
          pt.customer_id customer_id,
          pt.cust_trx_type_id cust_trx_type_id
  FROM    PN_PAYMENT_TERMS pt,
          PN_LEASES_ALL le ,
          PN_PAYMENT_ITEMS_ALL     pi,
          PN_PAYMENT_ITEMS_ALL     pi1,
          PN_PAYMENT_SCHEDULES_ALL ps
  WHERE   pt.lease_id = le.lease_id
  AND     le.lease_class_code  in ('THIRD_PARTY','SUB_LEASE')
  AND     LE.LEASE_ID  BETWEEN P_LOW_LEASE_ID AND P_HIGH_LEASE_ID
  AND     ps.lease_id = le.lease_id
  AND     pi.payment_schedule_id = ps.payment_schedule_id
  AND     pi.payment_term_id = pt.payment_term_id
  AND     ps.payment_Status_lookup_code ='APPROVED'
  AND     ps.schedule_date between p_sch_start_date and p_sch_end_date
  AND     ps.period_name = nvl(p_period_name ,ps.period_name)
  AND     pi.payment_item_type_lookup_code  = 'NORMALIZED'
  AND     pi.transferred_to_ar_flag  is  NULL
  AND     PT.NORMALIZE = 'Y'
  AND     LE.STATUS ='F'
  AND     pt.customer_id = nvl(p_customer_id,pt.customer_id)
  AND     pi1.payment_schedule_id = pi.payment_schedule_id
  AND     pi1.payment_term_id = pi.payment_term_id
  AND     pi1.payment_item_type_lookup_code  = 'CASH'
  AND     ((pi1.transferred_to_ar_flag  ='Y' AND pi1.actual_amount <>0 )
            OR (pi.transferred_to_ar_flag IS NULL AND pi1.actual_amount = 0 ))
  AND     pt.legal_entity_id IS NULL
  ORDER BY pt.payment_term_id ;

  CURSOR c_ap_data(
           p_low_lease_id    pn_leases.lease_id%TYPE,
           p_high_lease_id   pn_leases.lease_id%TYPE,
           p_sch_start_date  pn_payment_schedules.schedule_date%TYPE,
           p_sch_end_date    pn_payment_schedules.schedule_date%TYPE,
           p_period_name     pn_payment_schedules.period_name%TYPE,
           p_vendor_id       pn_payment_terms.vendor_id%TYPE)
  IS
  SELECT  pt.payment_term_id,
          pt.lease_id,
          pt.set_of_books_id,
          pt.legal_entity_id,
          pi.payment_item_id,
          pi.due_date,
          ps.schedule_date,
          pi.org_id,
          ps.payment_schedule_id,
          pi1.actual_amount
  FROM    pn_payment_terms pt,
          pn_leases_all le ,
          pn_payment_items_all     pi,
          pn_payment_items_all     pi1,
          pn_payment_schedules_all ps
  WHERE   pt.lease_id = le.lease_id
  AND     le.lease_class_code                 =  'DIRECT'
  and     LE.LEASE_ID BETWEEN P_LOW_LEASE_ID AND P_HIGH_LEASE_ID
  and     ps.lease_id                         = le.lease_id
  and     pi.payment_schedule_id              = ps.payment_schedule_id
  and     pi.payment_term_id                  = pt.payment_term_id
  and     ps.payment_Status_lookup_code       ='APPROVED'
  and     ps.schedule_date BETWEEN p_sch_start_date AND p_sch_end_date
  and     ps.period_name = nvl(p_period_name ,ps.period_name)
  AND     pi.payment_item_type_lookup_code    = 'NORMALIZED'
  and     pi.transferred_to_ap_flag IS NULL
  and     PT.NORMALIZE                        = 'Y'
  AND     LE.STATUS                           ='F'
  AND     LE.parent_lease_id IS NULL
  and     pt.vendor_id = nvl(p_vendor_id,pt.vendor_id)
  and     pi1.payment_schedule_id             = pi.payment_schedule_id
  and     pi1.payment_term_id                 = pi.payment_term_id
  and     pi1.payment_item_type_lookup_code   = 'CASH'
  and     ((pi1.transferred_to_ap_flag        ='Y' AND pi1.actual_Amount <>0 )
            OR (pi.transferred_to_ap_flag IS NULL AND pi1.actual_Amount = 0 ))
  ORDER BY ps.payment_schedule_id;

  CURSOR c_ap_data_le_upg(
           p_low_lease_id    pn_leases.lease_id%TYPE,
           p_high_lease_id   pn_leases.lease_id%TYPE,
           p_sch_start_date  pn_payment_schedules.schedule_date%TYPE,
           p_sch_end_date    pn_payment_schedules.schedule_date%TYPE,
           p_period_name     pn_payment_schedules.period_name%TYPE,
           p_vendor_id       pn_payment_terms.vendor_id%TYPE)
  IS
  SELECT  pt.payment_term_id payment_term_id,
          pt.legal_entity_id legal_entity_id,
          pt.org_id org_id,
          pt.vendor_id vendor_id,
          pt.vendor_site_id vendor_site_id
  FROM    pn_payment_terms pt,
          pn_leases_all le ,
          pn_payment_items_all     pi,
          pn_payment_items_all     pi1,
          pn_payment_schedules_all ps
  WHERE   pt.lease_id = le.lease_id
  AND     le.lease_class_code                 =  'DIRECT'
  AND     LE.LEASE_ID BETWEEN P_LOW_LEASE_ID AND P_HIGH_LEASE_ID
  AND     ps.lease_id                         = le.lease_id
  AND     pi.payment_schedule_id              = ps.payment_schedule_id
  AND     pi.payment_term_id                  = pt.payment_term_id
  AND     ps.payment_Status_lookup_code       ='APPROVED'
  AND     ps.schedule_date BETWEEN p_sch_start_date AND p_sch_end_date
  AND     ps.period_name = nvl(p_period_name ,ps.period_name)
  AND     pi.payment_item_type_lookup_code    = 'NORMALIZED'
  AND     pi.transferred_to_ap_flag IS NULL
  AND     PT.NORMALIZE                        = 'Y'
  AND     LE.STATUS                           ='F'
  AND     LE.parent_lease_id IS NULL
  AND     pt.vendor_id = nvl(p_vendor_id,pt.vendor_id)
  AND     pi1.payment_schedule_id             = pi.payment_schedule_id
  AND     pi1.payment_term_id                 = pi.payment_term_id
  AND     pi1.payment_item_type_lookup_code   = 'CASH'
  AND     ((pi1.transferred_to_ap_flag        ='Y' AND pi1.actual_Amount <>0 )
            OR (pi.transferred_to_ap_flag IS NULL AND pi1.actual_Amount = 0 ))
  AND     pt.legal_entity_id IS NULL
  ORDER BY pt.payment_term_id;

CURSOR c_lease_num(p_lease_id pn_leases.lease_id%TYPE)
IS
SELECT lease_num
FROM pn_leases_all
WHERE lease_id = p_lease_id;

-------------------------------------------------------------------------------
-- PROCEDURE : CREATE_AP_ACC_R12
-- DESCRIPTION: Create accounting for normalize payment items in R12
-- HISTORY
-- 20-JUL-05  ftanudja  o Created for SLA uptake #4527233.
-- 01-DEC-05  Hareesha  o Changes for Lazy upgrade for LE uptake.
-- 12-MAY-06  sdmahesh  o Bug # 5219481
--                        Set transferred_to_ap_flag in PN_PAYMENT_ITEMS
--                        Stamped xla_event_id PN_PAYMENT_ITEMS
--                        Set transfer related information in PN_PAYMENT_SCHEDULES
-- 27-NOV-06 sdmahesh   o Changed event_id_tbl_typ to NUMBER
-------------------------------------------------------------------------------

PROCEDURE CREATE_AP_ACC_R12(
 P_start_date             IN      VARCHAR2  ,
 P_end_date               IN      VARCHAR2  ,
 P_low_lease_id           IN      NUMBER    ,
 P_high_lease_id          IN      NUMBER    ,
 P_period_name            IN      VARCHAR2  ,
 p_vendor_id              IN      NUMBER    ,
 P_Org_id                 IN      NUMBER
) AS

  l_low_lease_id   pn_leases.lease_id%TYPE;
  l_high_lease_id  pn_leases.lease_id%TYPE;
  l_sch_start_date pn_payment_schedules.schedule_date%TYPE;
  l_sch_end_date   pn_payment_schedules.schedule_date%TYPE;
  l_lia_account                NUMBER;
  l_prior_payment_schedule_id  NUMBER;
  l_created_by                 NUMBER;
  l_last_updated_by            NUMBER;
  l_last_update_login          NUMBER;
  l_last_update_date           DATE;
  l_creation_date              DATE;

  TYPE NUMBER_tbl_typ IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE item_id_tbl_typ IS TABLE OF pn_payment_items_all.payment_item_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE schedule_id_tbl_typ IS TABLE OF pn_payment_schedules_all.payment_schedule_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE event_id_tbl_typ IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  term_ID_tbl     NUMBER_tbl_typ;
  LE_tbl          NUMBER_tbl_typ;
  item_id_tbl     item_id_tbl_typ;
  schedule_id_tbl schedule_id_tbl_typ;
  event_id_tbl    event_id_tbl_typ;

  l_index         NUMBER;
  l_index_item    NUMBER;
  l_index_sched   NUMBER;
  l_failed        NUMBER;
  l_success       NUMBER;

BEGIN

  pnp_debug_pkg.put_log_msg('PN_CREATE_ACC.CREATE_AP_ACC_R12 (+)');

  IF P_START_DATE IS NULL THEN
    l_sch_start_date :=  to_date('01/01/0001','mm/dd/yyyy');
  ELSE
    l_sch_start_date := fnd_date.canonical_to_date(p_start_date);
  END IF;

  IF P_END_DATE IS NULL THEN
    l_sch_end_date :=  to_date('12/31/4712','mm/dd/yyyy');
  ELSE
    l_sch_end_date := fnd_date.canonical_to_date(p_end_date);
  END IF;

  IF P_LOW_LEASE_ID IS NULL THEN
    l_low_lease_id := -1;
  ELSE
    l_low_lease_id := p_low_lease_id;
  END IF;

  IF P_HIGH_LEASE_ID IS NULL THEN
    l_high_lease_id := 9999999999999;
  ELSE
    l_high_lease_id := p_high_lease_id;
  END IF;

  l_failed  := 0;
  l_success := 0;

  term_ID_tbl.DELETE;
  LE_tbl.DELETE;
  l_index := 1;

  FOR le_rec IN c_ap_data_le_upg (p_low_lease_id   => l_low_lease_id,
                                  p_high_lease_id  => l_high_lease_id,
                                  p_sch_start_date => l_sch_start_date,
                                  p_sch_end_date   => l_sch_end_date,
                                  p_period_name    => p_period_name,
                                  p_vendor_id      => p_vendor_id)
  LOOP

     term_ID_tbl(l_index) := le_rec.payment_term_id;

     l_lia_account :=
        PN_EXP_TO_AP.get_liability_acc(
           p_payment_term_id => le_rec.payment_term_id,
           p_vendor_id       => le_rec.vendor_id,
           p_vendor_site_id  => le_rec.vendor_site_id);

     LE_tbl(l_index) :=
        pn_r12_util_pkg.get_le_for_ap(
           p_code_combination_id => l_lia_account,
           p_location_id         => le_rec.vendor_site_id,
           p_org_id              => le_rec.org_id);

     l_index := l_index + 1;

  END LOOP;

  IF term_ID_tbl.COUNT > 0 THEN

    FORALL i IN term_ID_tbl.FIRST..term_ID_tbl.LAST
        UPDATE pn_payment_terms_all
        SET legal_entity_id = LE_tbl(i)
        WHERE payment_term_id = term_ID_tbl(i);

  END IF;

  pnp_debug_pkg.log('Before cursor c_term open');

  item_id_tbl.DELETE;
  schedule_id_tbl.DELETE;
  event_id_tbl.DELETE;

  l_index_item  := 1;
  l_index_sched := 1;
  l_prior_payment_schedule_id := -999;
  l_created_by         := FND_GLOBAL.user_id;
  l_last_updated_by    := FND_GLOBAL.USER_ID;
  l_last_update_login  := FND_GLOBAL.LOGIN_ID;
  l_last_update_date   := SYSDATE;
  l_creation_date      := SYSDATE;

  FOR acct_rec IN c_ap_data (p_low_lease_id   => l_low_lease_id,
                             p_high_lease_id  => l_high_lease_id,
                             p_sch_start_date => l_sch_start_date,
                             p_sch_end_date   => l_sch_end_date,
                             p_period_name    => p_period_name,
                             p_vendor_id      => p_vendor_id)
  LOOP

    BEGIN

      pn_xla_event_pkg.create_xla_event(
         p_payment_item_id => acct_rec.payment_item_id
        ,p_due_date        => acct_rec.due_date -- Added for Bug#8303091
        ,p_legal_entity_id => acct_rec.legal_entity_id
        ,p_ledger_id       => acct_rec.set_of_books_id
        ,p_org_id          => acct_rec.org_id
        ,p_bill_or_pay     => 'PAY'
        ,p_event_id        => event_id_tbl(l_index_item)
      );

      item_id_tbl(l_index_item) := acct_rec.payment_item_id;
      l_index_item := l_index_item + 1;

      IF ( acct_rec.payment_schedule_id <> l_Prior_Payment_Schedule_Id
          and acct_rec.actual_amount = 0 ) THEN

          l_Prior_Payment_Schedule_Id    := acct_rec.payment_schedule_id;
          schedule_id_tbl(l_index_sched) := acct_rec.payment_schedule_id;
          l_index_sched := l_index_sched + 1;

      END IF;

      l_success := l_success + 1;

      IF l_index_item > 1000 THEN

        pnp_debug_pkg.log('Updating payment items');

        FORALL i IN item_id_tbl.FIRST..item_id_tbl.LAST
          UPDATE pn_payment_items_all
          SET transferred_to_ap_flag = 'Y',
              xla_event_id           =  event_id_tbl(i),
              last_updated_by        =  l_last_updated_by,
              last_update_login      =  l_last_update_login,
              last_update_date       =  l_last_update_date
          WHERE payment_item_id      =  item_id_tbl(i);

        pnp_debug_pkg.log('Updating Payment schedules ');

        IF schedule_id_tbl.COUNT > 0 THEN

          FORALL i IN schedule_id_tbl.FIRST..schedule_id_tbl.LAST
            UPDATE PN_Payment_Schedules_all
            SET    Transferred_By_User_Id = l_last_updated_by,
                   Transfer_Date          = l_last_update_date,
                   last_updated_by        = l_last_updated_by,
                   last_update_login      = l_last_update_login,
                   last_update_date       = l_last_update_date
            WHERE  Payment_Schedule_Id    = schedule_id_tbl(i);

        END IF;

        item_id_tbl.DELETE;
        schedule_id_tbl.DELETE;
        event_id_tbl.DELETE;

        l_index_item  := 1;
        l_index_sched := 1;
        l_prior_payment_schedule_id := -999;

      END IF;

    EXCEPTION
       WHEN OTHERS THEN
         l_failed := l_failed + 1;

         IF l_failed = 1 THEN
           fnd_message.set_name ('PN','PN_XPEAM_ERR_LINES');
           fnd_message.set_token ('ER_LNO', ' ');
           pnp_debug_pkg.put_log_msg(fnd_message.get);
         END IF;

         fnd_message.set_name ('PN','PN_ITEM_ID');
         fnd_message.set_token ('ID', acct_rec.payment_item_id);
         pnp_debug_pkg.put_log_msg(fnd_message.get);
    END;
  END LOOP;

  pnp_debug_pkg.log('Updating remaining payment items');

  IF item_id_tbl.COUNT > 0 THEN

    FORALL i IN item_id_tbl.FIRST..item_id_tbl.LAST
      UPDATE pn_payment_items_all
      SET transferred_to_ap_flag = 'Y' ,
          xla_event_id           =  event_id_tbl(i),
          last_updated_by        =  l_last_updated_by,
          last_update_login      =  l_last_update_login,
          last_update_date       =  l_last_update_date
      WHERE payment_item_id      =  item_id_tbl(i);

  END IF;

  pnp_debug_pkg.log('Updating remaining Payment schedules');

  IF schedule_id_tbl.COUNT > 0 THEN

    FORALL i IN schedule_id_tbl.FIRST..schedule_id_tbl.LAST
      UPDATE PN_Payment_Schedules_all
      SET    Transferred_By_User_Id = l_last_updated_by,
             Transfer_Date          = l_last_update_date,
             last_updated_by        = l_last_updated_by,
             last_update_login      = l_last_update_login,
             last_update_date       = l_last_update_date
      WHERE  Payment_Schedule_Id    = schedule_id_tbl(i);

  END IF;

  pnp_debug_pkg.put_log_msg('
================================================================================');
  fnd_message.set_name ('PN','PN_XPEAM_FAIL_LN');
  fnd_message.set_token ('FAIL_LNO', to_char(l_failed));
  pnp_debug_pkg.put_log_msg(fnd_message.get);

  fnd_message.set_name ('PN','PN_XPEAM_SUCS_LN');
  fnd_message.set_token ('SUC_LNO', to_char(l_success));
  pnp_debug_pkg.put_log_msg(fnd_message.get);

  fnd_message.set_name ('PN','PN_XPEAM_PROC_LN');
  fnd_message.set_token ('PR_LNO', to_char(l_failed + l_success));
  pnp_debug_pkg.put_log_msg(fnd_message.get);

  pnp_debug_pkg.put_log_msg('
================================================================================');

  pnp_debug_pkg.put_log_msg('PN_CREATE_ACC.CREATE_AP_ACC_R12 (-)');

END CREATE_AP_ACC_R12;

-------------------------------------------------------------------------------
-- PROCEDURE : CREATE_AR_ACC_R12
-- DESCRIPTION: Create accounting for normalize billing items in R12
-- HISTORY
-- 20-JUL-05  ftanudja  o Created for SLA uptake. #4527233
-- 01-DEC-05  Hareesha  o Passed pn_mo_cache_utils.get_current_org_id
--                        while inserting
-- 01-DEC-05  Hareesha  o Changes for Lazy upgrade for LE uptake.
-- 12-MAY-06  sdmahesh  o Bug # 5219481
--                        Set transferred_to_ar_flag in PN_PAYMENT_ITEMS
--                        Stamped xla_event_id PN_PAYMENT_ITEMS
--                        Set transfer related information in PN_PAYMENT_SCHEDULES
-- 27-NOV-06 sdmahesh   o Changed event_id_tbl_typ to NUMBER
-------------------------------------------------------------------------------

PROCEDURE CREATE_AR_ACC_R12(
 P_start_date             IN      VARCHAR2  ,
 P_end_date               IN      VARCHAR2  ,
 P_low_lease_id           IN      NUMBER    ,
 P_high_lease_id          IN      NUMBER    ,
 P_period_name            IN      VARCHAR2  ,
 p_customer_id            IN      NUMBER    ,
 P_Org_id                 IN      NUMBER
) AS

  l_low_lease_id   pn_leases.lease_id%TYPE;
  l_high_lease_id  pn_leases.lease_id%TYPE;
  l_sch_start_date pn_payment_schedules.schedule_date%TYPE;
  l_sch_end_date   pn_payment_schedules.schedule_date%TYPE;

  TYPE item_id_tbl_typ IS TABLE OF pn_payment_items_all.payment_item_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE schedule_id_tbl_typ IS TABLE OF pn_payment_schedules_all.payment_schedule_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE NUMBER_tbl_typ IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE event_id_tbl_typ IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  term_ID_tbl                  NUMBER_tbl_typ;
  LE_tbl                       NUMBER_tbl_typ;
  item_id_tbl                  item_id_tbl_typ;
  schedule_id_tbl              schedule_id_tbl_typ;
  event_id_tbl                 event_id_tbl_typ;

  l_index                      NUMBER;
  l_index_item                 NUMBER;
  l_index_sched                NUMBER;
  l_prior_payment_schedule_id  NUMBER;
  l_created_by                 NUMBER;
  l_last_updated_by            NUMBER;
  l_last_update_login          NUMBER;
  l_last_update_date           DATE;
  l_creation_date              DATE;
  l_failed                     NUMBER;
  l_success                    NUMBER;

BEGIN

  pnp_debug_pkg.put_log_msg('PN_CREATE_ACC.CREATE_AR_ACC_R12 (+)');

  IF P_START_DATE IS NULL THEN
    l_sch_start_date :=  to_date('01/01/0001','mm/dd/yyyy');
  ELSE
    l_sch_start_date := fnd_date.canonical_to_date(p_start_date);
  END IF;

  IF P_END_DATE IS NULL THEN
    l_sch_end_date :=  to_date('12/31/4712','mm/dd/yyyy');
  ELSE
    l_sch_end_date := fnd_date.canonical_to_date(p_end_date);
  END IF;

  IF P_LOW_LEASE_ID IS NULL THEN
    l_low_lease_id := -1;
  ELSE
    l_low_lease_id := p_low_lease_id;
  END IF;

  IF P_HIGH_LEASE_ID IS NULL THEN
    l_high_lease_id := 9999999999999;
  ELSE
    l_high_lease_id := p_high_lease_id;
  END IF;

  l_failed  := 0;
  l_success := 0;

  term_ID_tbl.DELETE;
  LE_tbl.DELETE;

  l_index := 1;

  FOR le_rec IN c_ar_data_le_upg (p_low_lease_id   => l_low_lease_id,
                                  p_high_lease_id  => l_high_lease_id,
                                  p_sch_start_date => l_sch_start_date,
                                  p_sch_end_date   => l_sch_end_date,
                                  p_period_name    => p_period_name,
                                  p_customer_id    => p_customer_id)
  LOOP

     term_ID_tbl(l_index) := le_rec.payment_term_id;

     LE_tbl(l_index) :=
        pn_r12_util_pkg.get_le_for_ar(
           p_customer_id         => le_rec.customer_id,
           p_transaction_type_id => le_rec.cust_trx_type_id,
           p_org_id              => le_rec.org_id);

     l_index := l_index + 1;

  END LOOP;

  IF term_ID_tbl.COUNT > 0 THEN

    FORALL i IN term_ID_tbl.FIRST..term_ID_tbl.LAST
        UPDATE pn_payment_terms_all
        SET legal_entity_id = LE_tbl(i)
        WHERE payment_term_id = term_ID_tbl(i);

  END IF;

  pnp_debug_pkg.log('Before cursor c_term open');

  item_id_tbl.DELETE;
  schedule_id_tbl.DELETE;
  event_id_tbl.DELETE;

  l_index_item  := 1;
  l_index_sched := 1;
  l_prior_payment_schedule_id := -999;
  l_created_by         := FND_GLOBAL.user_id;
  l_last_updated_by    := FND_GLOBAL.USER_ID;
  l_last_update_login  := FND_GLOBAL.LOGIN_ID;
  l_last_update_date   := SYSDATE;
  l_creation_date      := SYSDATE;

  FOR acct_rec IN c_ar_data (p_low_lease_id   => l_low_lease_id,
                             p_high_lease_id  => l_high_lease_id,
                             p_sch_start_date => l_sch_start_date,
                             p_sch_end_date   => l_sch_end_date,
                             p_period_name    => p_period_name,
                             p_customer_id    => p_customer_id)
  LOOP
    BEGIN
      pn_xla_event_pkg.create_xla_event(
         p_payment_item_id => acct_rec.payment_item_id
        ,p_due_date        => acct_rec.due_date -- Added for Bug#8303091
        ,p_legal_entity_id => acct_rec.legal_entity_id
        ,p_ledger_id       => acct_rec.set_of_books_id
        ,p_org_id          => acct_rec.org_id
        ,p_bill_or_pay     => 'BILL'
        ,p_event_id        => event_id_tbl(l_index_item)
      );

      item_id_tbl(l_index_item) := acct_rec.payment_item_id;
      l_index_item := l_index_item + 1;

      IF ( acct_rec.payment_schedule_id <> l_Prior_Payment_Schedule_Id
          and acct_rec.actual_amount = 0 ) THEN

          l_Prior_Payment_Schedule_Id    := acct_rec.payment_schedule_id;
          schedule_id_tbl(l_index_sched) := acct_rec.payment_schedule_id;
          l_index_sched := l_index_sched + 1;

      END IF;

      l_success := l_success + 1;

      IF l_index_item = 1000 THEN

        pnp_debug_pkg.log('Updating payment items');

        FORALL i IN item_id_tbl.FIRST..item_id_tbl.LAST
          UPDATE pn_payment_items_all
          SET transferred_to_ar_flag = 'Y' ,
              xla_event_id           =  event_id_tbl(i),
              last_updated_by        =  l_last_updated_by,
              last_update_login      =  l_last_update_login,
              last_update_date       =  l_last_update_date
          WHERE payment_item_id      =  item_id_tbl(i);

        pnp_debug_pkg.log('Updating Payment schedules');

        IF schedule_id_tbl.COUNT > 0 THEN

          FORALL i IN schedule_id_tbl.FIRST..schedule_id_tbl.LAST
            UPDATE PN_Payment_Schedules_all
            SET    Transferred_By_User_Id = l_last_updated_by,
                   Transfer_Date          = l_last_update_date,
                   last_updated_by        = l_last_updated_by,
                   last_update_login      = l_last_update_login,
                   last_update_date       = l_last_update_date
            WHERE  Payment_Schedule_Id    = schedule_id_tbl(i);

        END IF;

        item_id_tbl.DELETE;
        schedule_id_tbl.DELETE;
        event_id_tbl.DELETE;

        l_index_item  := 1;
        l_index_sched := 1;
        l_prior_payment_schedule_id := -999;

      END IF;

    EXCEPTION
       WHEN OTHERS THEN
         l_failed := l_failed + 1;

         IF l_failed = 1 THEN
           fnd_message.set_name ('PN','PN_XPEAM_ERR_LINES');
           fnd_message.set_token ('ER_LNO', ' ');
           pnp_debug_pkg.put_log_msg(fnd_message.get);
         END IF;

         fnd_message.set_name ('PN','PN_ITEM_ID');
         fnd_message.set_token ('ID', acct_rec.payment_item_id);
         pnp_debug_pkg.put_log_msg(fnd_message.get);

    END;
  END LOOP;

  pnp_debug_pkg.log('Updating remaining payment items');

  IF item_id_tbl.COUNT > 0 THEN

    FORALL i IN item_id_tbl.FIRST..item_id_tbl.LAST
      UPDATE pn_payment_items_all
      SET transferred_to_ar_flag = 'Y' ,
          xla_event_id           =  event_id_tbl(i),
          last_updated_by        =  l_last_updated_by,
          last_update_login      =  l_last_update_login,
          last_update_date       =  l_last_update_date
      WHERE payment_item_id      =  item_id_tbl(i);

  END IF;

  pnp_debug_pkg.log('Updating remaining Payment schedules');

  IF schedule_id_tbl.COUNT > 0 THEN

    FORALL i IN schedule_id_tbl.FIRST..schedule_id_tbl.LAST
      UPDATE PN_Payment_Schedules_all
      SET    Transferred_By_User_Id = l_last_updated_by,
             Transfer_Date          = l_last_update_date,
             last_updated_by        = l_last_updated_by,
             last_update_login      = l_last_update_login,
             last_update_date       = l_last_update_date
      WHERE  Payment_Schedule_Id    = schedule_id_tbl(i);

  END IF;

  pnp_debug_pkg.put_log_msg('
================================================================================');
  fnd_message.set_name ('PN','PN_XPEAM_FAIL_LN');
  fnd_message.set_token ('FAIL_LNO', to_char(l_failed));
  pnp_debug_pkg.put_log_msg(fnd_message.get);

  fnd_message.set_name ('PN','PN_XPEAM_SUCS_LN');
  fnd_message.set_token ('SUC_LNO', to_char(l_success));
  pnp_debug_pkg.put_log_msg(fnd_message.get);

  fnd_message.set_name ('PN','PN_XPEAM_PROC_LN');
  fnd_message.set_token ('PR_LNO', to_char(l_failed + l_success));
  pnp_debug_pkg.put_log_msg(fnd_message.get);

  pnp_debug_pkg.put_log_msg('
================================================================================');

  pnp_debug_pkg.put_log_msg('PN_CREATE_ACC.CREATE_AR_ACC_R12 (-)');

END CREATE_AR_ACC_R12;

-------------------------------------------------------------------------------
-- PROCDURE     : CREATE_ACC
-- INVOKED FROM :
-- PURPOSE      :
-- HISTORY      :
-- 14-jul-05  sdmahesh o Bug 4284035 - Replaced pn_ae_headers,pn_ae_lines pnl
--                       with _ALL table.
-- 01-DEC-05  Hareesha o passed pn_mo_cache_utils.get_current_org_id to
--                       get_profile_value.
-- 01-DEC-05  Hareesha o Added check to call c_default_gl_period only
--                       incase of R12 only.
-------------------------------------------------------------------------------
PROCEDURE CREATE_ACC (
 errbuf                         out NOCOPY        varchar2,
 retcode                        out NOCOPY        varchar2,
 P_journal_category             IN         VARCHAR2,
 p_default_gl_date              IN         VARCHAR2,
 P_batch_name                   in         varchar2,
 P_start_date                   IN         VARCHAR2,
 P_end_date                     IN         VARCHAR2,
 P_low_lease_id                 IN         NUMBER  ,
 P_high_lease_id                IN         NUMBER  ,
 P_period_name                  in         varchar2,
 p_vendor_id                    in         Number  ,
 p_customer_id                  in         number  ,
 P_selection_type               in         varchar2,
 p_gl_transfer_mode             in         varchar2 ,
 p_submit_journal_import        in         varchar2 ,
 p_process_days                 in         varchar2,
 p_debug_flag                   in         varchar2 ,
 P_validate_account             in         varchar2 ,
 P_Org_id                       IN         NUMBER
) as

p_default_period    varchar2(250);
l_from_date         date;
l_to_date           date;
l_message       VARCHAR2(2000);

CURSOR c_default_gl_period IS
   SELECT period_name
   FROM   gl_period_statuses
   WHERE  closing_status        IN ('O', 'F')
   AND    set_of_books_id        = pn_mo_cache_utils.get_profile_value('PN_SET_OF_BOOKS_ID',
                                                            pn_mo_cache_utils.get_current_org_id)
   AND    application_id         = 101
   AND    adjustment_period_flag = 'N'
   AND    fnd_date.canonical_to_date(p_default_gl_date) BETWEEN start_date AND end_date;

CURSOR c_min_max_date IS
        SELECT min(accounting_date),
               max(accounting_date)
        FROM   pn_ae_headers_all pnh,
               pn_ae_lines_all pnl
        WHERE  pnh.ae_header_id = pnl.ae_header_id
        AND    pnl.gl_sl_link_id IS NULL ;

BEGIN
   --Print all input parameters
fnd_message.set_name ('PN','PN_CRACC_INP_PARAMS');
fnd_message.set_token ('JC', P_journal_category);
fnd_message.set_token ('BATCH_NAME', p_batch_name);
fnd_message.set_token ('DATE', to_char(fnd_date.canonical_to_date(p_default_gl_date),'mm/dd/yyyy'));
fnd_message.set_token ('NAME', p_period_name);
fnd_message.set_token ('ST_DATE', to_char(fnd_date.canonical_to_date(p_start_date),'mm/dd/yyyy'));
fnd_message.set_token ('END_DATE',to_char(fnd_date.canonical_to_date(p_end_date),'mm/dd/yyyy'));
fnd_message.set_token ('NUM_LOW', p_low_lease_id);
fnd_message.set_token ('NUM_HIGH', p_high_lease_id);
fnd_message.set_token ('VEND_ID', p_vendor_id);
fnd_message.set_token ('CUST_ID', p_customer_id);
fnd_message.set_token ('MODE', p_gl_transfer_mode);
fnd_message.set_token ('IMP_FLAG', p_submit_journal_import);
fnd_message.set_token ('ACCNT_FLAG', p_validate_account);
fnd_message.set_token ('ORG_ID', p_org_id);
fnd_message.set_token ('TYPE', p_selection_type);
pnp_debug_pkg.put_log_msg(fnd_message.get);

IF pn_r12_util_pkg.is_r12 THEN
  NULL;
ELSE
   OPEN c_default_gl_period;
   FETCH c_default_gl_period INTO   p_default_period;
    IF c_default_gl_period%NOTFOUND THEN
       CLOSE  c_default_gl_period;
       fnd_message.set_name('PN','PN_GL_PERIOD_NOT_OPEN');
       errbuf  := fnd_message.get;
       Retcode := 2;
       ROLLBACK;
       RETURN;
    END IF;
    CLOSE  c_default_gl_period;
END IF;

pnp_debug_pkg.log('Default GL period Name    = '|| p_default_period);

 IF p_journal_category ='PM REVENUE'  THEN

    IF pn_r12_util_pkg.is_r12 THEN
          CREATE_AR_ACC_R12 (
                           P_start_date         ,
                           P_end_date           ,
                           P_low_lease_id       ,
                           P_high_lease_id      ,
                           P_period_name        ,
                           p_customer_id        ,
                           P_Org_id);

    ELSE
          CREATE_AR_ACC(   P_journal_category   ,
                           p_default_gl_date    ,
                           p_default_period     ,
                           P_start_date         ,
                           P_end_date           ,
                           P_low_lease_id       ,
                           P_high_lease_id      ,
                           P_period_name        ,
                           p_customer_id        ,
                           P_Org_id
                            );
    END IF;


 ELSIF p_journal_category ='PM EXPENSE'  then

    IF pn_r12_util_pkg.is_r12 THEN

              CREATE_AP_ACC_R12 (
                           P_start_date         ,
                           P_end_date           ,
                           P_low_lease_id       ,
                           P_high_lease_id      ,
                           P_period_name        ,
                           p_vendor_id          ,
                           P_Org_id);
     ELSE
              CREATE_AP_ACC(
                           P_journal_category   ,
                           p_default_gl_date    ,
                           p_default_period     ,
                           P_start_date         ,
                           P_end_date           ,
                           P_low_lease_id       ,
                           P_high_lease_id      ,
                           P_period_name        ,
                           p_vendor_id          ,
                           P_Org_id
                             );
     END IF;

 ELSIF p_journal_category ='A'  then

    IF pn_r12_util_pkg.is_r12 THEN

          CREATE_AP_ACC_R12 (
                           P_start_date         ,
                           P_end_date           ,
                           P_low_lease_id       ,
                           P_high_lease_id      ,
                           P_period_name        ,
                           p_vendor_id          ,
                           P_Org_id);

          CREATE_AR_ACC_R12 (
                           P_start_date         ,
                           P_end_date           ,
                           P_low_lease_id       ,
                           P_high_lease_id      ,
                           P_period_name        ,
                           p_customer_id        ,
                           P_Org_id);
     ELSE

      CREATE_AR_ACC(
                        P_journal_category   ,
                        p_default_gl_date    ,
                        p_default_period     ,
                        P_start_date         ,
                        P_end_date           ,
                        P_low_lease_id       ,
                        P_high_lease_id      ,
                        P_period_name        ,
                        p_customer_id        ,
                        P_Org_id
                    );

        CREATE_AP_ACC(
                          P_journal_category   ,
                          p_default_gl_date    ,
                          p_default_period     ,
                          P_start_date         ,
                          P_end_date           ,
                          P_low_lease_id       ,
                          P_high_lease_id      ,
                          P_period_name        ,
                          p_vendor_id          ,
                          P_Org_id
                     );

      END IF;
   END IF;

   IF NOT pn_r12_util_pkg.is_r12 THEN

      /*  Call GL transfer only for valied date range */

      OPEN c_min_max_date ;
      FETCH c_min_max_date INTO l_from_date ,l_to_date;
      CLOSE  c_min_max_date;

      pnp_debug_pkg.log('From Date to xla Procedure = '||To_char(l_from_date,'MM/DD/YYYY'));
      pnp_debug_pkg.log('To Date to xla Procedure   = '||To_char(l_to_date,'MM/DD/YYYY'));

      /*  Call GL transfer only for valied date range */

     IF NOT(l_from_date is null AND l_to_date is null)  THEN

     PN_GL_TRANSFER.gl_transfer(
                       p_journal_category       ,
                       P_selection_type         ,
                       P_batch_name             ,
                       trunc(l_from_date)       ,
                       trunc(l_to_date)         ,
                       P_validate_account       ,
                       p_gl_transfer_mode       ,
                       p_submit_journal_import  ,
                       p_process_days           ,
                       p_debug_flag
                       );
     END IF;

   END IF;

EXCEPTION
       WHEN OTHERS THEN
           Errbuf  := SQLERRM;
           Retcode := 2;
           rollback;
           return;
END CREATE_ACC;

-------------------------------------------------------------------------------
-- FUNCTION:    GET_ACCOUNTED_AMOUNT
-- SCOPE:       PUBLIC
-- DESCRIPTION: Gets the accounted amount according to the currency conv rules
--              This procedure is called if the accounted amount in the
--              pay/bill item is found to be null.
--
-- HISTORY:
--  29-FEB-2004  Kiran         o Created. Bug#3446051
-------------------------------------------------------------------------------
FUNCTION GET_ACCOUNTED_AMOUNT( p_amount              IN NUMBER,
                               p_functional_currency IN VARCHAR2,
                               p_currency            IN VARCHAR2,
                               p_rate                IN NUMBER,
                               p_conv_date           IN DATE,
                               p_conv_type           IN VARCHAR2)

RETURN NUMBER IS
-- variables for curr conversion
l_conv_type VARCHAR2(15);
l_conv_date DATE;
-- amt to return
l_accounted_amt NUMBER;

BEGIN

  pnp_debug_pkg.log('PN_CREATE_ACC.GET_ACCOUNTED_AMOUNT ----- (+)');

  IF p_conv_date > SYSDATE THEN
    l_conv_date := SYSDATE;
  ELSE
    l_conv_date := p_conv_date;
  END IF;

  IF UPPER(l_conv_type) = 'USER' THEN
    l_accounted_amt := NVL(p_amount,0) * NVL(p_rate,0);
  ELSE
    l_accounted_amt := PNP_UTIL_FUNC.export_curr_amount
                         (currency_code        => p_currency,
                          export_currency_code => p_functional_currency,
                          export_date          => l_conv_date,
                          conversion_type      => p_conv_type,
                          actual_amount        => NVL(p_amount,0),
                          p_called_from        => 'NOTPNTAUPMT');
  END IF;

  pnp_debug_pkg.log('Accounted Amount = '||l_accounted_amt);
  pnp_debug_pkg.log('PN_CREATE_ACC.GET_ACCOUNTED_AMOUNT ----- (-)');

  RETURN l_accounted_amt;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END GET_ACCOUNTED_AMOUNT;
-------------------------------------------------------------------------------
-- PROCEDURE :  CREATE_AR_ACC
-- DESCRIPTION: This is  create the accounting lines for Normalized Billing
--              items
-- History
--  17-Oct-2002  Ashish Kumar   o Created
--  29-Sep-2003  Ashish         o Bug#3160981 in the cursor c_term change the
--                                lease_class_code from SUBLEASE to SUB_LEASE
--  29-FEB-2004  Kiran          o Added call to GET_ACCOUNTED_AMOUNT() to
--                                ensure accounted_Amount is NOT NULL.
--                              o Added code to split accounted_Amount per
--                                distributions
--                              o indented code - bug # 3446951
--  14-jul-2005 SatyaDeep       o replaced pn_distributions,pn_payment_terms,
--                                pn_leases,pn__payment_items,pn_payment_schedules
--                                with their respective _ALL tables
--  01-DEC-05   Hareesha        o Passed pn_mo_cache_utils.get_current_org_id
--                                to get_profile_value.
--                                Inserted pn_mo_cache_utils.get_current_org_id as
--                                org_id into interface tables.
--  25-DEC-06   acprakas        o Bug#5739873. Modified procedure to form
--                                header and line description with lease number
--                                instead of lease id.
--------------------------------------------------------------------------------
PROCEDURE CREATE_AR_ACC(
 P_journal_category       IN      VARCHAR2 ,
 p_default_gl_date        IN      VARCHAR2 ,
 p_default_period         IN      VARCHAR2 ,
 P_start_date             IN      VARCHAR2 ,
 P_end_date               IN      VARCHAR2 ,
 P_low_lease_id           IN      NUMBER   ,
 P_high_lease_id          IN      NUMBER   ,
 P_period_name            IN      VARCHAR2 ,
 p_customer_id            IN      NUMBER   ,
 P_Org_id                 IN      NUMBER
)
   AS
   v_pn_lease_id                      PN_LEASES.lease_id%TYPE;
   v_pn_period_name                   PN_PAYMENT_SCHEDULES.period_name%TYPE;
   v_pn_code_combination_id           PN_PAYMENT_TERMS.code_combination_id%TYPE;
   v_pn_term_id                       PN_PAYMENT_TERMS.ap_ar_term_id%TYPE;
   v_pn_trx_type_id                   PN_PAYMENT_TERMS.cust_trx_type_id%TYPE;
   v_transaction_date                 PN_PAYMENT_ITEMS.due_date%TYPE;
   v_normalize                        PN_PAYMENT_TERMS.normalize%type;
   v_pn_payment_item_id               PN_PAYMENT_ITEMS.payment_item_id%TYPE;
   v_pn_payment_term_id               PN_PAYMENT_ITEMS.payment_term_id%TYPE;
   v_pn_currency_code                 PN_PAYMENT_ITEMS.currency_code%TYPE;
   v_pn_export_currency_code          PN_PAYMENT_ITEMS.export_currency_code%TYPE;
   v_pn_export_currency_amount        PN_PAYMENT_ITEMS.export_currency_amount%TYPE;
   v_pn_payment_schedule_id           PN_PAYMENT_ITEMS.payment_schedule_id%TYPE;
   v_pn_accounted_date                PN_PAYMENT_ITEMS.accounted_date%TYPE;
   v_pn_rate                          PN_PAYMENT_ITEMS.rate%TYPE;
   l_amt                              NUMBER;
   l_prior_payment_schedule_id        NUMBER   := -999;
   l_created_by                       NUMBER := FND_GLOBAL.user_id;
   l_last_updated_by                  NUMBER := FND_GLOBAL.USER_ID;
   l_last_update_login                NUMBER := FND_GLOBAL.LOGIN_ID;
   l_last_update_date                 DATE := sysdate;
   l_creation_date                    DATE := SYSDATE;
   l_msgBuff                          VARCHAR2 (2000) := NULL;
   l_context                          VARCHAR2(2000);
   l_precision                        NUMBER;
   l_ext_precision                    NUMBER;
   l_min_acct_unit                    NUMBER;
   t_count                            NUMBER := 0;
   s_count                            NUMBER := 0;
   l_err_msg1                         VARCHAR2(2000);
   l_err_msg2                         VARCHAR2(2000);
   l_err_msg3                         VARCHAR2(2000);
   l_err_msg4                         VARCHAR2(2000);
   l_total_rev_amt                    NUMBER := 0;
   l_total_rev_percent                NUMBER := 0;
   l_diff_amt                         NUMBER := 0;
   l_set_of_books_id                  NUMBER := TO_NUMBER(pn_mo_cache_utils.get_profile_value('PN_SET_OF_BOOKS_ID'
                                                          ,pn_mo_cache_utils.get_current_org_id));
   l_func_curr_code                   gl_sets_of_books.currency_code%TYPE;
   l_conv_rate_type                   pn_currencies.conversion_type%TYPE;
   v_pn_EVENT_TYPE_CODE               pn_payment_terms.EVENT_TYPE_CODE%TYPE;
   l_header_ID                        PN_AE_HEADERS.AE_HEADER_ID%TYPE;
   l_LINE_ID                          PN_AE_LINES.AE_LINE_ID%TYPE;
   l_EVENT_ID                         PN_ACCOUNTING_EVENTS.ACCOUNTING_EVENT_ID%TYPE;
   l_event_number                     NUMBER;
   l_rev_number                       NUMBER;
   l_unearn_number                    NUMBER;
   v_pn_accounted_amount              NUMBER;
   l_term_id                          NUMBER := 0;
   v_cash_actual_amount               NUMBER := 0;
   l_start_date                       RA_CUST_TRX_LINE_GL_DIST.gl_date%type ;
   l_sch_start_date                   DATE ;
   l_sch_end_date                     DATE;
   l_low_lease_id                     PN_LEASES.lease_id%TYPE;
   l_high_lease_id                    PN_LEASES.lease_id%TYPE;
   l_total_acc_amt                    NUMBER := 0;
   l_total_acc_percent                NUMBER := 0;
   l_header_desc                      VARCHAR2(240);
   l_line_desc                        VARCHAR2(240);
   l_message                          VARCHAR2(2000);
   v_pn_lease_num	              PN_LEASES.lease_num%TYPE; --Bug#5739873

CURSOR get_func_curr_code(p_set_of_books_id IN NUMBER) IS
  SELECT currency_code ,chart_of_accounts_id
  FROM   gl_sets_of_books
  WHERE  set_of_books_id = p_set_of_books_id;

CURSOR get_acnt_info(p_term_id NUMBER) IS
  SELECT account_id,
         account_class,
         percentage
  FROM   pn_distributions_all
  WHERE  payment_term_id = p_term_id;

TYPE acnt_type IS
  TABLE OF get_acnt_info%ROWTYPE
  INDEX BY BINARY_INTEGER;

rev_acnt_tab                   acnt_type;
acc_acnt_tab                   acnt_type;
l_rev_cnt                      NUMBER := 0;
l_acc_cnt                      NUMBER := 0;

CURSOR get_send_flag(p_lease_id NUMBER) IS
  SELECT nvl(send_entries, 'Y')
  FROM   pn_lease_details_all
  WHERE  lease_id = p_lease_id;

CURSOR C_TERM IS
  SELECT  pt.payment_term_id,
          pt.ap_ar_term_id,
          pt.cust_trx_type_id,
          le.lease_id,
          pt.normalize,
          PT.EVENT_TYPE_CODE,
          pi.payment_item_id,
          pi.currency_code,
          pi.export_currency_amount,
          pi.export_currency_code,
          pi.payment_schedule_id,
          ps.period_name,
          pi.due_date,
          pi.accounted_date,
          pi.rate,
          pi.accounted_amount,
          pi1.actual_amount,
          ps.schedule_date
  FROM    PN_PAYMENT_TERMS pt,
          PN_LEASES_ALL le ,
          PN_PAYMENT_ITEMS_ALL     pi,
          PN_PAYMENT_ITEMS_ALL     pi1,
          PN_PAYMENT_SCHEDULES_ALL ps
  WHERE   pt.lease_id = le.lease_id
  AND     le.lease_class_code  in ('THIRD_PARTY','SUB_LEASE')
  AND     LE.LEASE_ID  BETWEEN L_LOW_LEASE_ID AND L_HIGH_LEASE_ID
  AND     ps.lease_id = le.lease_id
  AND     pi.payment_schedule_id = ps.payment_schedule_id
  AND     pi.payment_term_id = pt.payment_term_id
  AND     ps.payment_Status_lookup_code ='APPROVED'
  AND     ps.schedule_date between l_sch_start_date and l_sch_end_date
  AND     ps.period_name = nvl(p_period_name ,ps.period_name)
  AND     pi.payment_item_type_lookup_code  = 'NORMALIZED'
  AND     pi.transferred_to_ar_flag  is  NULL
  AND     PT.NORMALIZE = 'Y'
  AND     LE.STATUS ='F'
  AND     pt.customer_id = nvl(p_customer_id,pt.customer_id)
  AND     pi1.payment_schedule_id = pi.payment_schedule_id
  AND     pi1.payment_term_id = pi.payment_term_id
  AND     pi1.payment_item_type_lookup_code  = 'CASH'
  AND     ((pi1.transferred_to_ar_flag  ='Y' AND pi1.actual_Amount <>0 )
            OR (pi.transferred_to_ar_flag IS NULL AND pi1.actual_Amount = 0 ))
  ORDER BY pt.payment_term_id ;

CURSOR C_VALID_PERIOD IS
  SELECT  1
  FROM   gl_period_statuses
  WHERE  closing_status        IN ('O', 'F')
  AND    set_of_books_id        =  pn_mo_cache_utils.get_profile_value('PN_SET_OF_BOOKS_ID',
                                                              pn_mo_cache_utils.get_current_org_id)
  AND    application_id         = 101
  AND    adjustment_period_flag = 'N'
  AND    period_name  = v_pn_period_name;

l_valid_period      NUMBER := 0;
l_period_name       VARCHAR2(250);
v_schedule_date     DATE ;
l_chart_of_id       NUMBER;

l_send_flag  pn_lease_details_all.send_entries%TYPE := 'Y';
l_lease_id   NUMBER := 0;

-- variables for accounted amt.
l_item_accounted_amt NUMBER;
l_accounted_amt      NUMBER;
l_total_rev_acc_amt  NUMBER;
l_diff_acc_amt       NUMBER;

BEGIN

  pnp_debug_pkg.log('at start of the Procedure CREATE_AR_ACC');

  if p_start_date is null then
    l_sch_start_date :=  to_date('01/01/0001','mm/dd/yyyy');
  else
    l_sch_start_date := fnd_date.canonical_to_date(p_start_date);
  end if;

  if p_end_date is null then
    l_sch_end_date :=  to_date('12/31/4712','mm/dd/yyyy');
  else
    l_sch_end_date := fnd_date.canonical_to_date(p_end_date);
  end if;

  if p_low_lease_id is null then
    l_low_lease_id := -1;
  else
    l_low_lease_id := p_low_lease_id;
  end if;

  if p_high_lease_id is null then
    l_high_lease_id := 9999999999999;
  else
    l_high_lease_id := p_high_lease_id;
  end if;

  pnp_debug_pkg.log('Before cursor c_term open');

  OPEN c_term ;

  LOOP

    l_context := 'Fetching from the cursor';
    FETCH c_term INTO
    v_pn_payment_term_id,
    v_pn_term_id,
    v_pn_trx_type_id,
    v_pn_lease_id,
    v_normalize,
    v_pn_event_type_code,
    v_pn_payment_item_id,
    v_pn_currency_code,
    v_pn_export_currency_amount,
    v_pn_export_currency_code,
    v_pn_payment_schedule_id,
    v_pn_period_name,
    v_transaction_date,
    v_pn_accounted_date,
    v_pn_rate,
    v_pn_accounted_amount,
    v_cash_actual_amount,
    v_schedule_date;
    EXIT WHEN c_term%NOTFOUND ;

    /* Get send entries flag for the lease */
    IF l_lease_id <> v_pn_lease_id THEN
       OPEN  get_send_flag(v_pn_lease_id);
       FETCH get_send_flag INTO l_send_flag;
       CLOSE get_send_flag;
       l_lease_id := v_pn_lease_id;

       fnd_message.set_name ('PN','PN_CRACC_LEASE_SEND');
       fnd_message.set_token ('NUM', l_lease_id);
       fnd_message.set_token ('FLAG', l_send_flag);
       pnp_debug_pkg.put_log_msg(fnd_message.get);

    END IF;

    /*  Do processing only if send_flag is Yes  */
    IF (nvl(l_send_flag,'Y') = 'Y')    THEN

       pnp_debug_pkg.put_log_msg('
================================================================================');
       fnd_message.set_name ('PN','PN_LEASE_ID');
       fnd_message.set_token ('ID', v_pn_lease_id);
       l_message := fnd_message.get;
       fnd_message.set_name ('PN','PN_ITEM_ID');
       fnd_message.set_token ('ID', v_pn_payment_item_id);
       l_message := l_message||' - '||fnd_message.get;
       fnd_message.set_name ('PN','PN_SCHEDULED_DATE');
       fnd_message.set_token ('DATE', to_char(v_schedule_date,'mm/dd/yyyy'));
       l_message := l_message||' - '||fnd_message.get;
       pnp_debug_pkg.put_log_msg(l_message);
       pnp_debug_pkg.put_log_msg('
================================================================================');

       /* Check for Conversion Type and Conversion Rate for Currency Code */

       OPEN  get_func_curr_code(l_set_of_books_id);
       FETCH get_func_curr_code INTO l_func_curr_code ,l_chart_of_id;
       CLOSE get_func_curr_code;

       l_conv_rate_type
         := PNP_UTIL_FUNC.check_conversion_type
             ( l_func_curr_code
              ,pn_mo_cache_utils.get_current_org_id);

       fnd_message.set_name ('PN','PN_CRACC_CV_TYPE');
       fnd_message.set_token ('CT', l_conv_rate_type);
       pnp_debug_pkg.put_log_msg(fnd_message.get);

       fnd_message.set_name ('PN','PN_CRACC_CV_RATE');
       fnd_message.set_token ('CR', v_pn_rate);
       pnp_debug_pkg.put_log_msg(fnd_message.get);


       /* if the accounted amount is null, then, GET IT!
          Ensure we populate accounted_CR/DR in the AE Lines */
       IF v_pn_accounted_amount IS NULL THEN
          l_item_accounted_amt := GET_ACCOUNTED_AMOUNT
                                  (p_amount              => v_pn_export_currency_amount,
                                   p_functional_currency => l_func_curr_code,
                                   p_currency            => v_pn_currency_code,
                                   p_rate                => v_pn_rate,
                                   p_conv_date           => v_transaction_date,
                                   p_conv_type           => l_conv_rate_type);
       ELSE
          l_item_accounted_amt := v_pn_accounted_amount;
       END IF;

       t_count := t_count + 1;

       /* Default the precision to 2 */
       l_precision := 2;

       /* Get the correct precision for the currency so that the amount can be rounded off */
       fnd_currency.get_info(v_pn_export_currency_code, l_precision, l_ext_precision, l_min_acct_unit);

       OPEN c_valid_period;
       FETCH c_valid_period INTO l_valid_period;
       IF c_valid_period%notfound THEN
          l_start_date := fnd_date.canonical_to_date(p_default_gl_date);
          l_period_name := p_default_period;
       ELSE
          l_start_date
            := PNP_UTIL_FUNC.Get_Start_Date
               ( V_PN_PERIOD_NAME
                ,pn_mo_cache_utils.get_current_org_id);
          l_period_name := v_pn_period_name;
       END IF;
       CLOSE c_valid_period;

       fnd_message.set_name ('PN','PN_CRACC_ACC_DATE');
       fnd_message.set_token ('DATE', to_char(l_start_date,'mm/dd/yyyy'));
       pnp_debug_pkg.put_log_msg(fnd_message.get);

       fnd_message.set_name ('PN','PN_CRACC_ACC_PRD');
       fnd_message.set_token ('PERIOD', l_period_name);
       pnp_debug_pkg.put_log_msg(fnd_message.get);

       /* if pay term changed, re init, create accounting EVENT */
       IF l_term_id <> v_pn_payment_term_id THEN

          l_term_id := v_pn_payment_term_id ;

          /* Initailize the tables */
          acc_acnt_tab.DELETE;
          rev_acnt_tab.DELETE;

          l_acc_cnt        := 0;
          l_rev_cnt        := 0;

          FOR acnt_rec IN get_acnt_info(v_pn_payment_term_id)
          LOOP
            IF acnt_rec.account_class  = 'REV' THEN
               l_rev_cnt := l_rev_cnt + 1;
               rev_acnt_tab(l_rev_cnt) := acnt_rec;
            ELSIF acnt_rec.account_class  = 'UNEARN' THEN
               l_acc_cnt := l_acc_cnt + 1;
               acc_acnt_tab(l_acc_cnt) := acnt_rec;
            END IF;
          END LOOP;

          SELECT nvl(max(event_number),0) + 1
          INTO   l_event_number
          FROM   PN_ACCOUNTING_EVENTS_ALL
          WHERE  source_table = 'PN_PAYMENT_TERMS'
          AND    SOURCE_ID = v_pn_payment_term_id
          AND    EVENT_TYPE_CODE = v_pn_event_type_code;

          pnp_debug_pkg.log('Before event insert');

          INSERT INTO PN_ACCOUNTING_EVENTS_ALL
             (
               ACCOUNTING_EVENT_ID        ,
               EVENT_TYPE_CODE            ,
               ACCOUNTING_DATE            ,
               EVENT_NUMBER               ,
               EVENT_STATUS_CODE          ,
               SOURCE_TABLE               ,
               SOURCE_ID                  ,
               CREATION_DATE              ,
               CREATED_BY                 ,
               LAST_UPDATE_DATE           ,
               LAST_UPDATED_BY            ,
               LAST_UPDATE_LOGIN          ,
               PROGRAM_UPDATE_DATE        ,
               PROGRAM_ID                 ,
               PROGRAM_APPLICATION_ID     ,
               REQUEST_ID                 ,
               ORG_ID                     ,
               CANNOT_ACCOUNT_FLAG
             )
          VALUES
              (PN_ACCOUNTING_EVENTS_S.nextval,
               nvl(V_PN_EVENT_TYPE_CODE ,'ABS'),
               SYSDATE,
               l_event_number,
               'ACCOUNTED',
               'PN_PAYMENT_TERMS',
               l_term_id,
               l_creation_date,
               l_created_by,
               l_last_update_date,
               l_last_updated_by,
               l_last_update_login,
               SYSDATE,
               FND_GLOBAL.conc_program_id,
               FND_GLOBAL.prog_appl_id,
               FND_GLOBAL.conc_request_id,
               pn_mo_cache_utils.get_current_org_id,
               NULL
              )
          RETURNING ACCOUNTING_EVENT_ID INTO l_EVENT_id  ;

       END IF;  /* if pay term changed, re init, create accounting EVENT */

       pnp_debug_pkg.log('Before header insert');

       OPEN c_lease_num(v_pn_lease_id);
       FETCH c_lease_num INTO v_pn_lease_num;
       CLOSE c_lease_num;

       l_header_desc := 'Property Manager - '|| 'Lease Number - ' ||v_pn_lease_num ;   --Bug#5739873


       INSERT INTO PN_AE_HEADERS_ALL
             (AE_HEADER_ID           ,
              ACCOUNTING_EVENT_ID    ,
              SET_OF_BOOKS_ID        ,
              AE_CATEGORY            ,
              CROSS_CURRENCY_FLAG    ,
              PERIOD_NAME            ,
              ACCOUNTING_DATE        ,
              GL_TRANSFER_FLAG       ,
              GL_TRANSFER_RUN_ID     ,
              DESCRIPTION            ,
              ORG_ID                 ,
              CREATION_DATE          ,
              CREATED_BY             ,
              LAST_UPDATE_DATE       ,
              LAST_UPDATED_BY        ,
              LAST_UPDATE_LOGIN      ,
              PROGRAM_UPDATE_DATE    ,
              PROGRAM_APPLICATION_ID ,
              PROGRAM_ID             ,
              REQUEST_ID             ,
              ACCOUNTING_ERROR_CODE
             )
       VALUES
            (PN_AE_HEADERS_S.nextval,
             l_EVENT_ID,
             l_set_of_books_id ,
             'PM REVENUE' ,
             'N',
             l_period_name,
             l_start_date,
             'N',
             -1,
             l_header_desc,
             pn_mo_cache_utils.get_current_org_id,
             l_creation_date,
             l_created_by,
             l_last_update_date,
             l_last_updated_by,
             l_last_update_login,
             SYSDATE,
             FND_GLOBAL.prog_appl_id,
             FND_GLOBAL.conc_program_id,
             FND_GLOBAL.conc_request_id,
             NULL
            )
       RETURNING AE_HEADER_ID INTO l_header_id;

       l_total_rev_amt := 0;
       l_total_rev_percent := 0;
       l_rev_number := 0;

       l_accounted_amt := 0;
       l_total_rev_acc_amt := 0;
       l_diff_acc_amt := 0;

       /* for each REVENUE account, create AE line */
       FOR i IN 1..rev_acnt_tab.COUNT LOOP
          -- actual amount percentages
          l_amt := ROUND((v_pn_export_currency_amount * rev_acnt_tab(i).percentage)/100,l_precision);
          l_total_rev_amt := l_total_rev_amt + l_amt;
          -- accounted amount percentages
          l_accounted_amt
            := ROUND((l_item_accounted_amt * rev_acnt_tab(i).percentage)/100,l_precision);
          l_total_rev_acc_amt := l_total_rev_acc_amt + l_accounted_amt;
          -- percentage
          l_total_rev_percent := l_total_rev_percent + nvl(rev_acnt_tab(i).percentage,100);

          IF l_total_rev_percent = 100 THEN
             -- correction for actual
             l_diff_amt := l_total_rev_amt - v_pn_export_currency_amount ;
             l_amt := l_amt - l_diff_amt;
             -- correction for accounted
             l_diff_acc_amt := l_total_rev_acc_amt - l_item_accounted_amt;
             l_accounted_amt := l_accounted_amt - l_diff_acc_amt;
          END IF;

          fnd_message.set_name ('PN','PN_CRACC_CRD_AMT');
          fnd_message.set_token ('AMT', to_char(round(l_amt,l_precision)));
          pnp_debug_pkg.put_log_msg(fnd_message.get);

          fnd_message.set_name ('PN','PN_CRACC_REC_ACC ');
          fnd_message.set_token ('ACC', FA_RX_FLEX_PKG.get_value(
                                              p_application_id => 101,
                                              p_id_flex_code   => 'GL#',
                                              p_id_flex_num    =>  l_chart_of_id,
                                              p_qualifier      => 'ALL',
                                              p_ccid           => rev_acnt_tab(i).account_id));
          pnp_debug_pkg.put_log_msg(fnd_message.get);

          pnp_debug_pkg.log('Inserting into lines for Revenue');

          l_line_desc := 'Property Manager - '|| 'Lease Number - ' ||v_pn_lease_num ;   --Bug#5739873
          l_rev_number := l_rev_number + 1;

          INSERT INTO PN_AE_LINES_ALL
            (
             AE_LINE_ID              ,
             AE_HEADER_ID            ,
             AE_LINE_NUMBER          ,
             AE_LINE_TYPE_CODE       ,
             CODE_COMBINATION_ID     ,
             CURRENCY_CODE           ,
             CURRENCY_CONVERSION_TYPE,
             CURRENCY_CONVERSION_DATE,
             CURRENCY_CONVERSION_RATE,
             ENTERED_DR              ,
             ENTERED_CR              ,
             ACCOUNTED_DR            ,
             ACCOUNTED_CR            ,
             SOURCE_TABLE            ,
             SOURCE_ID               ,
             DESCRIPTION             ,
             ACCOUNTING_ERROR_CODE   ,
             ORG_ID                  ,
             CREATION_DATE           ,
             CREATED_BY              ,
             LAST_UPDATE_DATE        ,
             LAST_UPDATED_BY         ,
             LAST_UPDATE_LOGIN       ,
             PROGRAM_UPDATE_DATE     ,
             PROGRAM_APPLICATION_ID  ,
             PROGRAM_ID              ,
             REQUEST_ID
            )
          VALUES
            (
              PN_AE_LINES_S.NEXTVAL,
              L_HEADER_ID,
              l_rev_number,
              rev_acnt_tab(i).account_class,
              rev_acnt_tab(i).account_id,
              v_pn_export_currency_code,
              l_conv_rate_type ,
              v_pn_accounted_date,
              v_pn_rate,
              null,
              l_amt,
              null,
              l_accounted_amt,
              'PN_PAYMENT_ITEMS',
              V_PN_PAYMENT_ITEM_ID,
              l_line_desc,
              NULL,
              pn_mo_cache_utils.get_current_org_id,
              l_creation_date,
              l_created_by,
              l_last_update_date,
              l_last_updated_by,
              l_last_update_login,
              SYSDATE,
              FND_GLOBAL.prog_appl_id,
              FND_GLOBAL.conc_program_id,
              FND_GLOBAL.conc_request_id
            );

          pnp_debug_pkg.log('Inserted into lines for Revenue');

       END LOOP; /* for each REVENUE account, create AE line */

       l_amt := 0;
       l_diff_amt := 0;
       l_unearn_number := 0;
       l_total_acc_amt := 0;
       l_total_acc_percent := 0;

       l_accounted_amt := 0;
       l_total_rev_acc_amt := 0;
       l_diff_acc_amt := 0;

       /* for each UNEARN account, create AE line */
       FOR i IN 1..acc_acnt_tab.COUNT LOOP
          -- actual amount percentages
          l_amt      := ROUND((v_pn_export_currency_amount * acc_acnt_tab(i).percentage)/100,l_precision);
          l_total_acc_amt := l_total_acc_amt + l_amt;
          -- accounted amount percentages
          l_accounted_amt
            := ROUND((l_item_accounted_amt * acc_acnt_tab(i).percentage)/100,l_precision);
          l_total_rev_acc_amt := l_total_rev_acc_amt + l_accounted_amt;
          -- percentage
          l_total_acc_percent := l_total_acc_percent + nvl(acc_acnt_tab(i).percentage,100);

          IF l_total_acc_percent = 100 THEN
             -- correction for actual
             l_diff_amt := l_total_acc_amt - v_pn_export_currency_amount ;
             l_amt := l_amt - l_diff_amt;
             -- correction for accounted
             l_diff_acc_amt := l_total_rev_acc_amt - l_item_accounted_amt;
             l_accounted_amt := l_accounted_amt - l_diff_acc_amt;
          END IF;

         fnd_message.set_name ('PN','PN_CRACC_DB_ASS_AMT');
         fnd_message.set_token ('AMT', to_char(round(l_amt,l_precision)));
         pnp_debug_pkg.put_log_msg(fnd_message.get);

         fnd_message.set_name ('PN','PN_CRACC_ASST_ACC ');
         fnd_message.set_token ('ACC', FA_RX_FLEX_PKG.get_value(
                                             p_application_id => 101,
                                             p_id_flex_code   => 'GL#',
                                             p_id_flex_num    =>  l_chart_of_id,
                                             p_qualifier      => 'ALL',
                                             p_ccid           => acc_acnt_tab(i).account_id));
         pnp_debug_pkg.put_log_msg(fnd_message.get);

          pnp_debug_pkg.log('Inserting into lines for Accrued Asset');
          l_line_desc := 'Property Manager - '|| 'Lease Number - ' ||v_pn_lease_num ;   --Bug#5739873

          l_unearn_number := l_unearn_number + 1;

          INSERT INTO PN_AE_LINES_ALL
     (
              AE_LINE_ID              ,
              AE_HEADER_ID            ,
              AE_LINE_NUMBER          ,
              AE_LINE_TYPE_CODE       ,
              CODE_COMBINATION_ID     ,
              CURRENCY_CODE           ,
              CURRENCY_CONVERSION_TYPE,
              CURRENCY_CONVERSION_DATE,
              CURRENCY_CONVERSION_RATE,
              ENTERED_DR              ,
              ENTERED_CR              ,
              ACCOUNTED_DR            ,
              ACCOUNTED_CR            ,
              SOURCE_TABLE            ,
              SOURCE_ID               ,
              DESCRIPTION             ,
              ACCOUNTING_ERROR_CODE   ,
              ORG_ID                  ,
              CREATION_DATE           ,
              CREATED_BY              ,
              LAST_UPDATE_DATE        ,
              LAST_UPDATED_BY         ,
              LAST_UPDATE_LOGIN       ,
              PROGRAM_UPDATE_DATE     ,
              PROGRAM_APPLICATION_ID  ,
              PROGRAM_ID              ,
              REQUEST_ID
             )
          VALUES (
              PN_AE_LINES_S.nextval,
              L_HEADER_ID,
              l_unearn_number,
              acc_acnt_tab(i).account_class ,
              acc_acnt_tab(i).account_id,
              v_pn_export_currency_code,
              l_conv_rate_type ,
              v_pn_accounted_date,
              v_pn_rate,
              l_amt,
              null,
              l_accounted_amt,
              null,
              'PN_PAYMENT_ITEMS',
              V_PN_PAYMENT_ITEM_ID,
              l_line_desc,
              null,
              pn_mo_cache_utils.get_current_org_id,
              l_creation_date,
              l_created_by,
              l_last_update_date,
              l_last_updated_by,
              l_last_update_login,
              SYSDATE,
              FND_GLOBAL.prog_appl_id,
              FND_GLOBAL.conc_program_id,
              FND_GLOBAL.conc_request_id
             );

          pnp_debug_pkg.log('Inserted into lines for Accrued Asset');

       END LOOP; /* for each UNEARN account, create AE line */

       l_context := 'Updating Payment Items';
       pnp_debug_pkg.log('Updating payment items for payment item id : ' ||
                            to_char(v_pn_payment_item_id) );

       UPDATE pn_payment_items_all
       SET transferred_to_ar_flag = 'Y' ,
           ar_ref_code            =  v_pn_payment_item_id,
           last_updated_by        =  l_last_updated_by,
           last_update_login      =  l_last_update_login,
           last_update_date       =  l_last_update_date
       WHERE payment_item_id      = v_pn_payment_item_id;



       IF ( V_PN_Payment_Schedule_Id <> l_Prior_Payment_Schedule_Id
          AND v_cash_actual_amount = 0 ) THEN

          l_Prior_Payment_Schedule_Id  :=  V_PN_Payment_Schedule_Id;
          l_context := 'Updating Payment Schedules';
          pnp_debug_pkg.log('Updating billing schedules for billing sch id : ' ||
                             to_char(V_PN_Payment_Schedule_Id) );

          UPDATE PN_Payment_Schedules_all
          SET Transferred_By_User_Id = l_last_updated_by,
              Transfer_Date          = l_last_update_date,
              last_updated_by        = l_last_updated_by,
              last_update_login      = l_last_update_login,
              last_update_date       = l_last_update_date
          WHERE Payment_Schedule_Id  = V_PN_Payment_Schedule_Id;

       END IF;

       s_count := s_count + 1;

    END IF; /* for send_flag check */

  END LOOP;

  CLOSE c_term;

pnp_debug_pkg.put_log_msg('
================================================================================');
  fnd_message.set_name ('PN','PN_CRACC_TOTAL_ITEMS_PRCSD');
  fnd_message.set_token ('NUM', to_char(s_count));
  pnp_debug_pkg.put_log_msg(fnd_message.get);
  pnp_debug_pkg.put_log_msg('
================================================================================');

END CREATE_AR_ACC;

-------------------------------------------------------------------------------
-- PROCEDURE : CREATE_AP_ACC
-- DESCRIPTION: Create the accounting lines for Normalized Payment items
-- History
--  17-Oct-2002  Ashish Kumar   o Created
--  29-FEB-2004  Kiran          o Added call to GET_ACCOUNTED_AMOUNT() to
--                                ensure accounted_Amount is NOT NULL.
--                              o Added code to split accounted_Amount per
--                                distributions
--                              o indented code - bug # 3446951
--  14-jul-2005 SatyaDeep       o replaced pn_distributions,pn_payment_terms,
--                                pn_leases,pn__payment_items,pn_payment_schedules
--                                with their respective _ALL tables
--  01-DEC-05  Hareesha         o Passed pn_mo_cache_utils.get_current_org_id to
--                                get_profile_value.
--                                Inserted pn_mo_cache_utils.get_current_org_id
--                                as org_id into interface tables.
--  25-DEC-06  acprakas         o Bug#5739873. Modified procedure to form
--                                header and line description with lease number
--                                instead of lease id.
-------------------------------------------------------------------------------

PROCEDURE CREATE_AP_ACC(
 P_journal_category       IN      VARCHAR2  ,
 p_default_gl_date        IN      VARCHAR2  ,
 p_default_period         IN      VARCHAR2  ,
 P_start_date             IN      VARCHAR2  ,
 P_end_date               IN      VARCHAR2  ,
 P_low_lease_id           IN      NUMBER    ,
 P_high_lease_id          IN      NUMBER    ,
 P_period_name            IN      VARCHAR2  ,
 p_vendor_id              IN      NUMBER    ,
 P_Org_id                 IN      NUMBER
)
   AS
   v_pn_lease_id                      PN_LEASES.lease_id%TYPE;
   v_pn_period_name                   PN_PAYMENT_SCHEDULES.period_name%TYPE;
   v_pn_code_combination_id           PN_PAYMENT_TERMS.code_combination_id%TYPE;
   v_pn_distribution_set_id           pn_payment_terms.distribution_set_id%TYPE;
   v_pn_project_id                    pn_payment_terms.project_id%type;
   v_transaction_date                 PN_PAYMENT_ITEMS.due_date%TYPE;
   v_normalize                        PN_PAYMENT_TERMS.normalize%type;
   v_pn_payment_item_id               PN_PAYMENT_ITEMS.payment_item_id%TYPE;
   v_pn_payment_term_id               PN_PAYMENT_ITEMS.payment_term_id%TYPE;
   v_pn_currency_code                 PN_PAYMENT_ITEMS.currency_code%TYPE;
   v_pn_export_currency_code          PN_PAYMENT_ITEMS.export_currency_code%TYPE;
   v_pn_export_currency_amount        PN_PAYMENT_ITEMS.export_currency_amount%TYPE;
   v_pn_payment_schedule_id           PN_PAYMENT_ITEMS.payment_schedule_id%TYPE;
   v_pn_accounted_date                PN_PAYMENT_ITEMS.accounted_date%TYPE;
   v_pn_rate                          PN_PAYMENT_ITEMS.rate%TYPE;
   l_amt                              NUMBER;
   l_prior_payment_schedule_id        NUMBER   := -999;
   l_created_by                       NUMBER := FND_GLOBAL.user_id;
   l_last_updated_by                  NUMBER := FND_GLOBAL.USER_ID;
   l_last_update_login                NUMBER := FND_GLOBAL.LOGIN_ID;
   l_last_update_date                 DATE := sysdate;
   l_creation_date                    DATE := SYSDATE;  --ASH
   l_msgBuff                          VARCHAR2 (2000) := NULL;
   l_context                          VARCHAR2(2000);
   l_precision                        NUMBER;
   l_ext_precision                    NUMBER;
   l_min_acct_unit                    NUMBER;
   t_count                            NUMBER := 0;
   s_count                            NUMBER := 0;
   l_err_msg1                         VARCHAR2(2000);
   l_err_msg2                         VARCHAR2(2000);
   l_err_msg3                         VARCHAR2(2000);
   l_err_msg4                         VARCHAR2(2000);
   l_total_exp_amt                    number := 0;
   l_total_exp_percent                number := 0;
   l_diff_amt                         number := 0;
   l_set_of_books_id                  NUMBER := TO_NUMBER(pn_mo_cache_utils.get_profile_value('PN_SET_OF_BOOKS_ID',
                                                                                 pn_mo_cache_utils.get_current_org_id));
   l_func_curr_code                   gl_sets_of_books.currency_code%TYPE;
   l_conv_rate_type                   pn_currencies.conversion_type%TYPE;
   v_pn_EVENT_TYPE_CODE               pn_payment_terms.EVENT_TYPE_CODE%type;
   l_header_ID                        PN_AE_HEADERS.AE_HEADER_ID%type;
   l_LINE_ID                          PN_AE_LINES.AE_LINE_ID%type;
   l_EVENT_ID                         PN_ACCOUNTING_EVENTS.ACCOUNTING_EVENT_ID%type;
   l_event_number                     number;
   l_exp_number                       number;
   l_acc_number                       number;
   v_pn_accounted_amount              number;
   l_term_id                          number := 0;
   v_cash_actual_amount               number := 0;
   l_start_date                       RA_CUST_TRX_LINE_GL_DIST.gl_date%type ;
   l_sch_start_date                   date ;
   l_sch_end_date                     date;
   l_low_lease_id                     PN_LEASES.lease_id%TYPE;
   l_high_lease_id                    PN_LEASES.lease_id%TYPE;
   l_total_acc_amt                    NUMBER := 0;
   l_total_acc_percent                NUMBER := 0;
   l_header_desc                      varchar2(240);
   l_line_desc                        varchar2(240);
   l_message                          VARCHAR2(250);
   v_pn_lease_num	              PN_LEASES.lease_num%TYPE; --Bug#5739873

   CURSOR get_func_curr_code(p_set_of_books_id IN NUMBER) IS
     SELECT currency_code ,chart_of_accounts_id
     FROM   gl_sets_of_books
     where  set_of_books_id = p_set_of_books_id;

  CURSOR get_acnt_info(p_term_id NUMBER) IS
    SELECT account_id,
           account_class,
           percentage
    FROM   pn_distributions_all
    WHERE  payment_term_id = p_term_id;

  TYPE acnt_type IS
    TABLE OF get_acnt_info%ROWTYPE
    INDEX BY BINARY_INTEGER;

  exp_acnt_tab                   acnt_type;
  acc_acnt_tab                   acnt_type;
  l_exp_cnt                      NUMBER := 0;
  l_acc_cnt                      NUMBER := 0;

  CURSOR get_send_flag(p_lease_id NUMBER) IS
    SELECT nvl(send_entries, 'Y')
    FROM   pn_lease_details_all
    WHERE  lease_id = p_lease_id;

  CURSOR C_TERM IS
  SELECT  pt.payment_term_id,
          pt.project_id,
          pt.distribution_set_id,
          le.lease_id,
          pt.normalize,
          PT.EVENT_TYPE_CODE,
          pi.payment_item_id,
          pi.currency_code,
          pi.export_currency_amount,
          pi.export_currency_code,
          pi.payment_schedule_id,
          ps.period_name,
          pi.due_date,
          pi.accounted_date,
          pi.rate,
          pi.accounted_amount,
          pi1.actual_amount,
          ps.schedule_date
  FROM    pn_payment_terms pt,
          pn_leases_all le ,
          pn_payment_items_all     pi,
          pn_payment_items_all     pi1,
          pn_payment_schedules_all ps
  WHERE   pt.lease_id = le.lease_id
  AND     le.lease_class_code   =  'DIRECT'
  and     LE.LEASE_ID  BETWEEN L_LOW_LEASE_ID AND L_HIGH_LEASE_ID
  and     ps.lease_id         = le.lease_id
  and     pi.payment_schedule_id            = ps.payment_schedule_id
  and     pi.payment_term_id              = pt.payment_term_id
  and     ps.payment_Status_lookup_code ='APPROVED'
  and     ps.schedule_date between l_sch_start_date and l_sch_end_date
  and     ps.period_name = nvl(p_period_name ,ps.period_name)
  AND     pi.payment_item_type_lookup_code  = 'NORMALIZED'
  and     pi.transferred_to_ap_flag  is  NULL
  and     PT.NORMALIZE                     = 'Y'
  AND     LE.STATUS                         ='F'
  AND     LE.parent_lease_id                is  NULL
  and     pt.vendor_id =  nvl(p_vendor_id,pt.vendor_id)
  and     pi1.payment_schedule_id            = pi.payment_schedule_id
  and     pi1.payment_term_id              = pi.payment_term_id
  and     pi1.payment_item_type_lookup_code  = 'CASH'
  and     ((pi1.transferred_to_ap_flag  ='Y' and pi1.actual_Amount <>0 )
            or (pi.transferred_to_ap_flag  is  NULL and pi1.actual_Amount = 0 ))
        order by pt.payment_term_id;

  CURSOR C_VALID_PERIOD IS
  SELECT  1
    FROM   gl_period_statuses
    WHERE  closing_status        IN ('O', 'F')
    AND    set_of_books_id        =  pn_mo_cache_utils.get_profile_value('PN_SET_OF_BOOKS_ID',
                                                                pn_mo_cache_utils.get_current_org_id)
    AND   application_id         = 101
    AND   adjustment_period_flag = 'N'
    AND   period_name  = v_pn_period_name;

  l_valid_period      number := 0;
  l_period_name       varchar2(250);
  l_chart_of_id       number;
  v_schedule_date     date ;

  l_send_flag            pn_lease_details_all.send_entries%TYPE := 'Y';
  l_lease_id                     NUMBER := 0;

  -- variables for accounted amt.
  l_item_accounted_amt NUMBER;
  l_accounted_amt      NUMBER;
  l_total_exp_acc_amt  NUMBER;
  l_diff_acc_amt       NUMBER;

BEGIN

  pnp_debug_pkg.log('at start of the Procedure CREATE_AP_ACC');

  IF P_START_DATE IS NULL THEN
    l_sch_start_date :=  to_date('01/01/0001','mm/dd/yyyy');
  ELSE
    l_sch_start_date := fnd_date.canonical_to_date(p_start_date);
  END IF;

  IF P_END_DATE IS NULL THEN
    l_sch_end_date :=  to_date('12/31/4712','mm/dd/yyyy');
  ELSE
    l_sch_end_date := fnd_date.canonical_to_date(p_end_date);
  END IF;

  IF P_LOW_LEASE_ID IS NULL THEN
    l_low_lease_id := -1;
  ELSE
    l_low_lease_id := p_low_lease_id;
  END IF;

  IF P_HIGH_LEASE_ID IS NULL THEN
    l_high_lease_id := 9999999999999;
  ELSE
    l_high_lease_id := p_high_lease_id;
  END IF;

  pnp_debug_pkg.log('Before cursor c_term open');

  OPEN C_TERM ;
  LOOP

    l_context := 'Fetching from the cursor';
    FETCH c_term INTO
      v_pn_payment_term_id,
      v_pn_project_id,
      v_pn_distribution_set_id,
      v_pn_lease_id,
      v_normalize,
      v_pn_event_type_code,
      v_pn_payment_item_id,
      v_pn_currency_code,
      v_pn_export_currency_amount,
      v_pn_export_currency_code,
      v_pn_payment_schedule_id,
      v_pn_period_name,
      v_transaction_date,
      v_pn_accounted_date,
      v_pn_rate,
      v_pn_accounted_amount,
      v_cash_actual_amount,
      v_schedule_date;
    EXIT WHEN c_term%NOTFOUND ;


    /* Get send entries flag for the lease */
    IF l_lease_id <> v_pn_lease_id THEN
       OPEN  get_send_flag(v_pn_lease_id);
       FETCH get_send_flag INTO l_send_flag;
       CLOSE get_send_flag;
       l_lease_id := v_pn_lease_id;
       fnd_message.set_name ('PN','PN_CRACC_LEASE_SEND');
       fnd_message.set_token ('NUM', l_lease_id);
       fnd_message.set_token ('FLAG', l_send_flag);
       pnp_debug_pkg.put_log_msg(fnd_message.get);

    END IF;

    /*  Do processing only if send_flag is Yes  */
    IF (nvl(l_send_flag,'Y') = 'Y')    THEN


      pnp_debug_pkg.put_log_msg('
================================================================================');
      fnd_message.set_name ('PN','PN_LEASE_ID');
      fnd_message.set_token ('ID', v_pn_lease_id);
      l_message := fnd_message.get;
      fnd_message.set_name ('PN','PN_ITEM_ID');
      fnd_message.set_token ('ID', v_pn_payment_item_id);
      l_message := l_message||' - '||fnd_message.get;
      fnd_message.set_name ('PN','PN_SCHEDULED_DATE');
      fnd_message.set_token ('DATE', to_char(v_schedule_date,'mm/dd/yyyy'));
      l_message := l_message||' - '||fnd_message.get;
      pnp_debug_pkg.put_log_msg(l_message);
      pnp_debug_pkg.put_log_msg('
================================================================================');


      /* Check for Conversion Type and Conversion Rate for Currency Code */
      OPEN  get_func_curr_code(l_set_of_books_id);
      FETCH get_func_curr_code INTO l_func_curr_code,l_chart_of_id;
      CLOSE get_func_curr_code;

      l_conv_rate_type
        := PNP_UTIL_FUNC.check_conversion_type
            ( l_func_curr_code
             ,pn_mo_cache_utils.get_current_org_id);

      fnd_message.set_name ('PN','PN_CRACC_CV_TYPE');
      fnd_message.set_token ('CT', l_conv_rate_type);
      pnp_debug_pkg.put_log_msg(fnd_message.get);


      fnd_message.set_name ('PN','PN_CRACC_CV_RATE');
      fnd_message.set_token ('CR', v_pn_rate);
      pnp_debug_pkg.put_log_msg(fnd_message.get);


      /* if the accounted amount is null, then, GET IT!
         Ensure we populate accounted_CR/DR in the AE Lines */
      IF v_pn_accounted_amount IS NULL THEN
        l_item_accounted_amt := GET_ACCOUNTED_AMOUNT
                                (p_amount              => v_pn_export_currency_amount,
                                 p_functional_currency => l_func_curr_code,
                                 p_currency            => v_pn_currency_code,
                                 p_rate                => v_pn_rate,
                                 p_conv_date           => v_transaction_date,
                                 p_conv_type           => l_conv_rate_type);
      ELSE
        l_item_accounted_amt := v_pn_accounted_amount;
      END IF;

      /* Default the precision to 2 */
      l_precision := 2;

      /* Get the correct precision for the currency so that the amount can be rounded off */
      fnd_currency.get_info(v_pn_export_currency_code, l_precision, l_ext_precision, l_min_acct_unit);

      OPEN C_VALID_PERIOD;
      FETCH c_valid_period INTO l_valid_period;
      IF c_valid_period%NOTFOUND THEN
         l_start_date := fnd_date.canonical_to_date(p_default_gl_date);
         l_period_name := p_default_period;
      ELSE
         l_start_date
           := PNP_UTIL_FUNC.Get_Start_Date
               ( V_PN_PERIOD_NAME
                ,pn_mo_cache_utils.get_current_org_id);
         l_period_name := v_pn_period_name;
      END IF;
      CLOSE C_VALID_PERIOD;



     fnd_message.set_name ('PN','PN_CRACC_ACC_DATE');
     fnd_message.set_token ('DATE', to_char(l_start_date,'mm/dd/yyyy'));
     pnp_debug_pkg.put_log_msg(fnd_message.get);

     fnd_message.set_name ('PN','PN_CRACC_ACC_PRD');
     fnd_message.set_token ('PERIOD', l_period_name);
     pnp_debug_pkg.put_log_msg(fnd_message.get);

      IF l_term_id <> v_pn_payment_term_id THEN

         l_term_id   := v_pn_payment_term_id ;

         /* Initailize the tables */
         acc_acnt_tab.DELETE;
         exp_acnt_tab.DELETE;

         l_acc_cnt        := 0;
         l_exp_cnt        := 0;

         FOR acnt_rec IN get_acnt_info(v_pn_payment_term_id)
         LOOP
            IF acnt_rec.account_class  = 'EXP' THEN
               l_exp_cnt := l_exp_cnt + 1;
               exp_acnt_tab(l_exp_cnt) := acnt_rec;
            ELSIF acnt_rec.account_class  = 'ACC' THEN
               l_acc_cnt := l_acc_cnt + 1;
               acc_acnt_tab(l_acc_cnt) := acnt_rec;
            END IF;
         END LOOP;

         SELECT nvl(max(event_number),0) + 1
         INTO l_event_number
         FROM pn_accounting_events_all
         WHERE  source_table = 'PN_PAYMENT_TERMS'
         AND SOURCE_ID = v_pn_payment_term_id
         AND EVENT_TYPE_CODE = v_pn_event_type_code;

         pnp_debug_pkg.log('Before event insert');


         l_context := 'Inserting into PN_ACCOUNTING_EVENTS';

         INSERT INTO PN_ACCOUNTING_EVENTS_ALL
          (
            ACCOUNTING_EVENT_ID        ,
            EVENT_TYPE_CODE            ,
            ACCOUNTING_DATE            ,
            EVENT_NUMBER               ,
            EVENT_STATUS_CODE          ,
            SOURCE_TABLE               ,
            SOURCE_ID                  ,
            CREATION_DATE              ,
            CREATED_BY                 ,
            LAST_UPDATE_DATE           ,
            LAST_UPDATED_BY            ,
            LAST_UPDATE_LOGIN          ,
            PROGRAM_UPDATE_DATE        ,
            PROGRAM_ID                 ,
            PROGRAM_APPLICATION_ID     ,
            REQUEST_ID                 ,
            ORG_ID                     ,
            CANNOT_ACCOUNT_FLAG
          )
         VALUES
          (
            PN_ACCOUNTING_EVENTS_S.nextval,
            nvl(V_PN_EVENT_TYPE_CODE ,'ABS') ,
            SYSDATE,
            l_event_number,
            'ACCOUNTED',
            'PN_PAYMENT_TERMS',
            v_pn_payment_term_id,
            l_creation_date,
            l_created_by,
            l_last_update_date,
            l_last_updated_by,
            l_last_update_login,
            SYSDATE,
            FND_GLOBAL.conc_program_id,
            FND_GLOBAL.prog_appl_id,
            FND_GLOBAL.conc_request_id,
            pn_mo_cache_utils.get_current_org_id,
            NULL
          )
         RETURNING ACCOUNTING_EVENT_ID INTO l_EVENT_id  ;

      END IF;

      pnp_debug_pkg.log('Before header insert');


      OPEN c_lease_num(v_pn_lease_id);
      FETCH c_lease_num INTO v_pn_lease_num;
      CLOSE c_lease_num;

      l_header_desc := 'Property Manager - '|| 'Lease Number - ' ||v_pn_lease_num ;  --Bug#5739873

      INSERT INTO PN_AE_HEADERS_ALL
      (
        AE_HEADER_ID           ,
        ACCOUNTING_EVENT_ID    ,
        SET_OF_BOOKS_ID        ,
        AE_CATEGORY            ,
        CROSS_CURRENCY_FLAG    ,
        PERIOD_NAME            ,
        ACCOUNTING_DATE        ,
        GL_TRANSFER_FLAG       ,
        GL_TRANSFER_RUN_ID     ,
        DESCRIPTION            ,
        ORG_ID                 ,
        CREATION_DATE          ,
        CREATED_BY             ,
        LAST_UPDATE_DATE       ,
        LAST_UPDATED_BY        ,
        LAST_UPDATE_LOGIN      ,
        PROGRAM_UPDATE_DATE    ,
        PROGRAM_APPLICATION_ID ,
        PROGRAM_ID             ,
        REQUEST_ID             ,
        ACCOUNTING_ERROR_CODE
      )
      VALUES
      (
        PN_AE_HEADERS_S.nextval,
        l_EVENT_ID,
        l_set_of_books_id ,
        'PM EXPENSE' ,
        'N',
        l_period_name,
        l_start_date,
        'N',
        -1,
        l_header_desc,
        pn_mo_cache_utils.get_current_org_id,
        l_creation_date,
        l_created_by,
        l_last_update_date,
        l_last_updated_by,
        l_last_update_login,
        SYSDATE,
        FND_GLOBAL.prog_appl_id,
        FND_GLOBAL.conc_program_id,
        FND_GLOBAL.conc_request_id,
        NULL
      )
      RETURNING AE_HEADER_ID INTO l_header_id;

      l_total_exp_amt := 0;
      l_total_exp_percent := 0;
      l_exp_number := 0;

      l_accounted_amt := 0;
      l_diff_acc_amt := 0;
      l_total_exp_acc_amt := 0;

      FOR I IN 1..EXP_ACNT_TAB.COUNT LOOP
        -- actual amount percentages
        l_amt := ROUND((v_pn_export_currency_amount * exp_acnt_tab(i).percentage)/100,l_precision);
        l_total_exp_amt := l_total_exp_amt + l_amt;
        -- accounted amount percentages
        l_accounted_amt :=
          ROUND((l_item_accounted_amt * exp_acnt_tab(i).percentage)/100,l_precision);
        l_total_exp_acc_amt := l_total_exp_acc_amt + l_accounted_amt;
        -- percentage
        l_total_exp_percent := l_total_exp_percent + nvl(exp_acnt_tab(i).percentage,100);

        IF l_total_exp_percent = 100 THEN
           -- correction for actual amount
           l_diff_amt := l_total_exp_amt - v_pn_export_currency_amount ;
           l_amt := l_amt - l_diff_amt;
           -- correction for accounted amont
           l_diff_acc_amt := l_total_exp_acc_amt - l_item_accounted_amt;
           l_accounted_amt := l_accounted_amt - l_diff_acc_amt;
        END IF;

        fnd_message.set_name ('PN','PN_CRACC_DBT_AMT');
        fnd_message.set_token ('AMT', to_char(round(l_amt,l_precision)));
        pnp_debug_pkg.put_log_msg(fnd_message.get);

        fnd_message.set_name ('PN','PN_CRACC_EXP_ACC ');
        fnd_message.set_token ('ACC', FA_RX_FLEX_PKG.get_value(
                                              p_application_id => 101,
                                              p_id_flex_code   => 'GL#',
                                              p_id_flex_num    =>  l_chart_of_id,
                                              p_qualifier      => 'ALL',
                                              p_ccid           => exp_acnt_tab(i).account_id));

        pnp_debug_pkg.put_log_msg(fnd_message.get);

        pnp_debug_pkg.log('Inserting into lines for Expense');

	l_line_desc := 'Property Manager - '|| 'Lease Number - ' ||v_pn_lease_num ;   --Bug#5739873
        l_exp_number := l_exp_number +1;

        INSERT INTO PN_AE_LINES_ALL
        (
          AE_LINE_ID              ,
          AE_HEADER_ID            ,
          AE_LINE_NUMBER          ,
          AE_LINE_TYPE_CODE       ,
          CODE_COMBINATION_ID     ,
          CURRENCY_CODE           ,
          CURRENCY_CONVERSION_TYPE,
          CURRENCY_CONVERSION_DATE,
          CURRENCY_CONVERSION_RATE,
          ENTERED_DR              ,
          ENTERED_CR              ,
          ACCOUNTED_DR            ,
          ACCOUNTED_CR            ,
          SOURCE_TABLE            ,
          SOURCE_ID               ,
          DESCRIPTION             ,
          ACCOUNTING_ERROR_CODE   ,
          ORG_ID                  ,
          CREATION_DATE           ,
          CREATED_BY              ,
          LAST_UPDATE_DATE        ,
          LAST_UPDATED_BY         ,
          LAST_UPDATE_LOGIN       ,
          PROGRAM_UPDATE_DATE     ,
          PROGRAM_APPLICATION_ID  ,
          PROGRAM_ID              ,
          REQUEST_ID
        )
        VALUES
        (
          PN_AE_LINES_S.nextval,
          L_HEADER_ID,
          l_exp_number,
          exp_acnt_tab(i).account_class,
          exp_acnt_tab(i).account_id,
          v_pn_export_currency_code,
          l_conv_rate_type ,
          v_pn_accounted_date,
          v_pn_rate,
          l_amt,
          null,
          l_accounted_amt,
          null,
          'PN_PAYMENT_ITEMS',
          V_PN_PAYMENT_ITEM_ID,
          l_line_desc,
          NULL,
          pn_mo_cache_utils.get_current_org_id,
          l_creation_date,
          l_created_by,
          l_last_update_date,
          l_last_updated_by,
          l_last_update_login,
          SYSDATE,
          FND_GLOBAL.prog_appl_id,
          FND_GLOBAL.conc_program_id,
          FND_GLOBAL.conc_request_id
        );

        pnp_debug_pkg.log('Inserted into lines for Expense');

      END LOOP;

      l_amt := 0;
      l_diff_amt := 0;
      l_acc_number := 0;
      l_total_acc_amt := 0;
      l_total_acc_percent := 0;

      l_accounted_amt := 0;
      l_diff_acc_amt := 0;
      l_total_exp_acc_amt := 0;

      FOR I IN 1..ACC_ACNT_TAB.COUNT LOOP
        -- actual amount percentages
        l_amt      := round((v_pn_export_currency_amount * acc_acnt_tab(i).percentage)/100,l_precision);
        l_total_acc_amt := l_total_acc_amt + l_amt;
        -- accounted amount percentages
        l_accounted_amt :=
          ROUND((l_item_accounted_amt * acc_acnt_tab(i).percentage)/100,l_precision);
        l_total_exp_acc_amt := l_total_exp_acc_amt + l_accounted_amt;
        -- percentage
        l_total_acc_percent := l_total_acc_percent + nvl(acc_acnt_tab(i).percentage,100);

        IF l_total_acc_percent = 100 THEN
           -- correction for actual amount
           l_diff_amt := l_total_acc_amt - v_pn_export_currency_amount ;
           l_amt := l_amt - l_diff_amt;
           -- correction for accounted amont
           l_diff_acc_amt := l_total_exp_acc_amt - l_item_accounted_amt;
           l_accounted_amt := l_accounted_amt - l_diff_acc_amt;
        END IF;

        fnd_message.set_name ('PN','PN_CRACC_CR_LIA_AMT');
        fnd_message.set_token ('AMT', to_char(round(l_amt,l_precision)));
        pnp_debug_pkg.put_log_msg(fnd_message.get);

        fnd_message.set_name ('PN','PN_CRACC_LIA_ACC ');
        fnd_message.set_token ('ACC', FA_RX_FLEX_PKG.get_value(
                                              p_application_id => 101,
                                              p_id_flex_code   => 'GL#',
                                              p_id_flex_num    =>  l_chart_of_id,
                                              p_qualifier      => 'ALL',
                                              p_ccid           => acc_acnt_tab(i).account_id));

        pnp_debug_pkg.put_log_msg(fnd_message.get);

        pnp_debug_pkg.log('Inserting into lines for Accrued Liability');
        l_line_desc := 'Property Manager - '|| 'Lease Number - ' ||v_pn_lease_num ;   --Bug#5739873


        l_acc_number := l_acc_number +1;

        INSERT INTO PN_AE_LINES_ALL
        (
          AE_LINE_ID              ,
          AE_HEADER_ID            ,
          AE_LINE_NUMBER          ,
          AE_LINE_TYPE_CODE       ,
          CODE_COMBINATION_ID     ,
          CURRENCY_CODE           ,
          CURRENCY_CONVERSION_TYPE,
          CURRENCY_CONVERSION_DATE,
          CURRENCY_CONVERSION_RATE,
          ENTERED_DR              ,
          ENTERED_CR              ,
          ACCOUNTED_DR            ,
          ACCOUNTED_CR            ,
          SOURCE_TABLE            ,
          SOURCE_ID               ,
          DESCRIPTION             ,
          ACCOUNTING_ERROR_CODE   ,
          ORG_ID                  ,
          CREATION_DATE           ,
          CREATED_BY              ,
          LAST_UPDATE_DATE        ,
          LAST_UPDATED_BY         ,
          LAST_UPDATE_LOGIN       ,
          PROGRAM_UPDATE_DATE     ,
          PROGRAM_APPLICATION_ID  ,
          PROGRAM_ID              ,
          REQUEST_ID
        )
        VALUES
        (
          PN_AE_LINES_S.nextval,
          L_HEADER_ID,
          l_acc_number,
          acc_acnt_tab(i).account_class ,
          acc_acnt_tab(i).account_id,
          v_pn_export_currency_code,
          l_conv_rate_type ,
          v_pn_accounted_date,
          v_pn_rate,
          NULL,
          l_amt,
          NULL,
          l_accounted_amt,
          'PN_PAYMENT_ITEMS',
          V_PN_PAYMENT_ITEM_ID,
          l_line_desc,
          NULL,
          pn_mo_cache_utils.get_current_org_id,
          l_creation_date,
          l_created_by,
          l_last_update_date,
          l_last_updated_by,
          l_last_update_login,
          SYSDATE,
          FND_GLOBAL.prog_appl_id,
          FND_GLOBAL.conc_program_id,
          FND_GLOBAL.conc_request_id
        );

        pnp_debug_pkg.log('Inserted into lines for Accrued Liability');

      END LOOP;

      l_context := 'Updating Payment Items';
      pnp_debug_pkg.log('Updating payment items for payment item id : ' ||
                            to_char(v_pn_payment_item_id) );

      UPDATE pn_payment_items_all
      SET transferred_to_ap_flag = 'Y' ,
          last_updated_by        =  l_last_updated_by,
          last_update_login      =  l_last_update_login,
          last_update_date       =  l_last_update_date
      WHERE payment_item_id      = v_pn_payment_item_id;

      IF ( V_PN_Payment_Schedule_Id <> l_Prior_Payment_Schedule_Id
          and v_cash_actual_amount = 0 ) THEN

          l_Prior_Payment_Schedule_Id  :=  V_PN_Payment_Schedule_Id;

          l_context := 'Updating Payment Schedules';

          pnp_debug_pkg.log('Updating Payment schedules for Payment sch id : ' ||
                             to_char(V_PN_Payment_Schedule_Id) );

          UPDATE PN_Payment_Schedules_all
          SET    Transferred_By_User_Id = l_last_updated_by,
                 Transfer_Date          = l_last_update_date,
                 last_updated_by        = l_last_updated_by,
                 last_update_login      = l_last_update_login,
                 last_update_date       = l_last_update_date
          WHERE  Payment_Schedule_Id    = V_PN_Payment_Schedule_Id;

       END IF;
       s_count := s_count + 1;

    END IF; /* for send_flag check */

  END LOOP;

  CLOSE c_term;

pnp_debug_pkg.put_log_msg('
================================================================================');
fnd_message.set_name ('PN','PN_CRACC_TOTAL_PAY_ITEMS_PRCSD');
fnd_message.set_token ('NUM', to_char(s_count));
pnp_debug_pkg.put_log_msg(fnd_message.get);
pnp_debug_pkg.put_log_msg('
================================================================================');
END CREATE_AP_ACC;

END PN_CREATE_ACC;

/
