--------------------------------------------------------
--  DDL for Package Body ARP_PROCESS_COMMITMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROCESS_COMMITMENT" AS
/* $Header: ARTECOMB.pls 115.7 2003/08/28 17:22:42 kmahajan ship $ */

pg_msg_level_debug   binary_integer;

pg_text_dummy   varchar2(10);
pg_number_dummy number(15);

pg_base_curr_code     gl_sets_of_books.currency_code%type;
pg_base_precision     fnd_currencies.precision%type;
pg_base_min_acc_unit  fnd_currencies.minimum_accountable_unit%type;

TYPE changed_flags_rec_type IS RECORD
(
  inventory_item_id_changed_flag boolean,
  memo_line_id_changed_flag      boolean,
  description_changed_flag       boolean,
  extended_amount_changed_flag   boolean,
  int_line_attr1_changed_flag    boolean,
  int_line_attr2_changed_flag    boolean,
  int_line_attr3_changed_flag    boolean,
  int_line_attr4_changed_flag    boolean,
  int_line_attr5_changed_flag    boolean,
  int_line_attr6_changed_flag    boolean,
  int_line_attr7_changed_flag    boolean,
  int_line_attr8_changed_flag    boolean,
  int_line_attr9_changed_flag    boolean,
  int_line_attr10_changed_flag   boolean,
  int_line_attr11_changed_flag   boolean,
  int_line_attr12_changed_flag   boolean,
  int_line_attr13_changed_flag   boolean,
  int_line_attr14_changed_flag   boolean,
  int_line_attr15_changed_flag   boolean,
  int_line_context_changed_flag  boolean,
  attr_category_changed_flag     boolean,
  attribute1_changed_flag        boolean,
  attribute2_changed_flag        boolean,
  attribute3_changed_flag        boolean,
  attribute4_changed_flag        boolean,
  attribute5_changed_flag        boolean,
  attribute6_changed_flag        boolean,
  attribute7_changed_flag        boolean,
  attribute8_changed_flag        boolean,
  attribute9_changed_flag        boolean,
  attribute10_changed_flag       boolean,
  attribute11_changed_flag       boolean,
  attribute12_changed_flag       boolean,
  attribute13_changed_flag       boolean,
  attribute14_changed_flag       boolean,
  attribute15_changed_flag       boolean,
  ussgl_trx_code_changed_flag    boolean
);

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    header_pre_insert                                                      |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Header Pre-insert logic for commitments                                |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    dbms_sql.bind_variable                                                 |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     12-JUL-95  Martin Johnson      Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE header_pre_insert IS

BEGIN

   arp_util.debug('arp_process_commitment.header_pre_insert()+');

   arp_util.debug('arp_process_commitment.header_pre_insert()-');

EXCEPTION
    WHEN OTHERS THEN
     arp_util.debug('EXCEPTION:  arp_process_commitment.header_pre_insert()');
     RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_line_salescredit                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Inserts line level salescredit for commitments.                        |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     07-AUG-95  Martin Johnson      Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE insert_line_salescredit(
                      p_customer_trx_id IN
                        ra_customer_trx.customer_trx_id%type,
                      p_customer_trx_line_id IN
                        ra_customer_trx_lines.customer_trx_line_id%type,
                      p_salesrep_id IN
                        ra_cust_trx_line_salesreps.salesrep_id%type,
                      p_extended_amount IN
                        ra_customer_trx_lines.extended_amount%type) IS

   l_srep_rec
     ra_cust_trx_line_salesreps%rowtype;
   l_cust_trx_line_salesrep_id
     ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type;

BEGIN

   arp_util.debug('arp_process_commitment.insert_line_salescredit()+',
                  pg_msg_level_debug);

   IF p_salesrep_id is not null THEN

     l_srep_rec.customer_trx_id       := p_customer_trx_id;
     l_srep_rec.customer_trx_line_id  := p_customer_trx_line_id;
     l_srep_rec.salesrep_id           := p_salesrep_id;
     -- kmahajan - 08/25/2003 - added line below for Sales Group project
     l_srep_rec.revenue_salesgroup_id := arp_util.Get_Default_SalesGroup(p_salesrep_id, p_customer_trx_id);
     l_srep_rec.revenue_amount_split  := p_extended_amount;
     l_srep_rec.revenue_percent_split := 100;

     arp_ctls_pkg.insert_p(l_srep_rec,
                           l_cust_trx_line_salesrep_id);

   END IF;

   arp_util.debug('arp_process_commitment.insert_line_salescredit()-',
                  pg_msg_level_debug);


EXCEPTION
    WHEN OTHERS THEN
     arp_util.debug(
           'EXCEPTION:  arp_process_commitment.insert_line_salescredit()',
            pg_msg_level_debug);
     RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_dist_line                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Inserts the revenue distribution for commitments                       |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     07-AUG-95  Martin Johnson      Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE insert_dist_line(p_customer_trx_id IN
                             ra_customer_trx.customer_trx_id%type,
                           p_customer_trx_line_id IN
                             ra_customer_trx_lines.customer_trx_line_id%type,
                           p_gl_date IN
                             ra_cust_trx_line_gl_dist.gl_date%type,
                           p_status  OUT NOCOPY varchar2)
IS

   l_ccid                   number;
   l_concat_segments        varchar2(2000);
   l_num_failed_dist_rows   number;
   l_errorbuf               varchar2(200);
   l_result                 number;
   l_comt_dft_acct          Varchar2(2);
   l_passed_ccid            number;


BEGIN

   arp_util.debug('arp_process_commitment.insert_dist_line()+',
                  pg_msg_level_debug);

   /*--------------------------------------------------+
    |  Call AutoAccounting to insert the distribution  |
    +--------------------------------------------------*/

   p_status := 'OK';

   BEGIN


     l_passed_ccid   :=  null;
     l_comt_dft_acct  := NVL(FND_PROFILE.value('AR_COMMITMENT_DEFAULT_ACCOUNTING'),'A');

    if l_comt_dft_acct = 'T' then

     Begin

       select cust_trx_type.gl_id_rev
       into   l_passed_ccid
       from ra_customer_trx cust_trx,
            ra_cust_trx_types cust_trx_type
       where cust_trx_type.type ='DEP'  and
            cust_trx.cust_trx_type_id =cust_trx_type.cust_trx_type_id and
            cust_trx.CUSTOMER_TRX_ID = P_CUSTOMER_TRX_ID;
       arp_auto_accounting.g_deposit_flag := 'Y';

       if l_passed_ccid is null  then
          l_passed_ccid :=-1;
       end if;

     exception
        when no_data_found then
             null;
     end;

    end if;


       arp_auto_accounting.do_autoaccounting(
                         'I',
                         'REV',
                         p_customer_trx_id,
                         p_customer_trx_line_id,
                         null,
                         null,
                         p_gl_date,
                         null,
                         null,
                         l_passed_ccid,
                         null,
                         null,
                         null,
                         null,
                         null,
                         l_ccid,
                         l_concat_segments,
                         l_num_failed_dist_rows);
   EXCEPTION
     WHEN arp_auto_accounting.no_ccid THEN

       p_status := 'ARP_AUTO_ACCOUNTING.NO_CCID';
       arp_util.debug('EXCEPTION: arp_process_commitment.insert_dist_line()- no_ccid',
                       pg_msg_level_debug);

     WHEN NO_DATA_FOUND THEN

       null;
       arp_util.debug('EXCEPTION: arp_process_commitment.insert_dist_line()- NO_DATA_FOUND',
                       pg_msg_level_debug);
     WHEN OTHERS THEN

       arp_util.debug('EXCEPTION: arp_process_commitment.insert_dist_line()- OTHERS',
                       pg_msg_level_debug);
       RAISE;
   END;

   IF  arp_auto_accounting.g_deposit_flag is NOT NULL THEN
       arp_auto_accounting.g_deposit_flag := '';
   END IF;

   arp_util.debug('arp_process_commitment.insert_dist_line()-',
                  pg_msg_level_debug);

EXCEPTION
    WHEN OTHERS THEN
     arp_util.debug(
           'EXCEPTION:  arp_process_commitment.insert_dist_line- OTHERS',
            pg_msg_level_debug);

     IF  arp_auto_accounting.g_deposit_flag is NOT NULL THEN
          arp_auto_accounting.g_deposit_flag := '';
     END IF;

     RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    header_post_insert                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Header post-insert logic for commitments                               |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    dbms_sql.bind_variable                                                 |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     12-JUL-95  Martin Johnson      Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE header_post_insert ( p_customer_trx_id IN
                                 ra_customer_trx.customer_trx_id%type,
                               p_commitment_rec IN commitment_rec_type,
                               p_primary_salesrep_id IN
                                 ra_customer_trx.primary_salesrep_id%type,
                               p_gl_date IN
                                 ra_cust_trx_line_gl_dist.gl_date%type,
                              p_customer_trx_line_id OUT NOCOPY
                               ra_customer_trx_lines.customer_trx_line_id%type,
                              p_status   OUT NOCOPY varchar2
                             )
          IS

   l_line_rec             ra_customer_trx_lines%rowtype;
   l_customer_trx_line_id ra_customer_trx_lines.customer_trx_line_id%type;

BEGIN

   arp_util.debug('arp_process_commitment.header_post_insert()+');

   /*-----------------------------------------+
    |  Insert row into ra_customer_trx_lines  |
    +-----------------------------------------*/


   l_line_rec.customer_trx_id   := p_customer_trx_id;
   l_line_rec.line_type         := 'LINE';
   l_line_rec.line_number       := 1;
   l_line_rec.inventory_item_id := p_commitment_rec.inventory_item_id;
   l_line_rec.memo_line_id      := p_commitment_rec.memo_line_id;
   l_line_rec.description       := p_commitment_rec.description;
   l_line_rec.extended_amount   := p_commitment_rec.extended_amount;
   l_line_rec.revenue_amount    := p_commitment_rec.extended_amount;
   l_line_rec.interface_line_attribute1 :=
                          p_commitment_rec.interface_line_attribute1;
   l_line_rec.interface_line_attribute2 :=
                          p_commitment_rec.interface_line_attribute2;
   l_line_rec.interface_line_attribute3 :=
                          p_commitment_rec.interface_line_attribute3;
   l_line_rec.interface_line_attribute4 :=
                          p_commitment_rec.interface_line_attribute4;
   l_line_rec.interface_line_attribute5 :=
                          p_commitment_rec.interface_line_attribute5;
   l_line_rec.interface_line_attribute6 :=
                          p_commitment_rec.interface_line_attribute6;
   l_line_rec.interface_line_attribute7 :=
                          p_commitment_rec.interface_line_attribute7;
   l_line_rec.interface_line_attribute8 :=
                          p_commitment_rec.interface_line_attribute8;
   l_line_rec.interface_line_attribute9 :=
                          p_commitment_rec.interface_line_attribute9;
   l_line_rec.interface_line_attribute10 :=
                          p_commitment_rec.interface_line_attribute10;
   l_line_rec.interface_line_attribute11 :=
                          p_commitment_rec.interface_line_attribute11;
   l_line_rec.interface_line_attribute12 :=
                          p_commitment_rec.interface_line_attribute12;
   l_line_rec.interface_line_attribute13 :=
                          p_commitment_rec.interface_line_attribute13;
   l_line_rec.interface_line_attribute14 :=
                          p_commitment_rec.interface_line_attribute14;
   l_line_rec.interface_line_attribute15 :=
                          p_commitment_rec.interface_line_attribute15;
   l_line_rec.interface_line_context :=
                          p_commitment_rec.interface_line_context;
   l_line_rec.attribute_category := p_commitment_rec.attribute_category;
   l_line_rec.attribute1         := p_commitment_rec.attribute1;
   l_line_rec.attribute2         := p_commitment_rec.attribute2;
   l_line_rec.attribute3         := p_commitment_rec.attribute3;
   l_line_rec.attribute4         := p_commitment_rec.attribute4;
   l_line_rec.attribute5         := p_commitment_rec.attribute5;
   l_line_rec.attribute6         := p_commitment_rec.attribute6;
   l_line_rec.attribute7         := p_commitment_rec.attribute7;
   l_line_rec.attribute8         := p_commitment_rec.attribute8;
   l_line_rec.attribute9         := p_commitment_rec.attribute9;
   l_line_rec.attribute10        := p_commitment_rec.attribute10;
   l_line_rec.attribute11        := p_commitment_rec.attribute11;
   l_line_rec.attribute12        := p_commitment_rec.attribute12;
   l_line_rec.attribute13        := p_commitment_rec.attribute13;
   l_line_rec.attribute14        := p_commitment_rec.attribute14;
   l_line_rec.attribute15        := p_commitment_rec.attribute15;
   l_line_rec.default_ussgl_transaction_code :=
                          p_commitment_rec.default_ussgl_transaction_code;

   arp_ctl_pkg.insert_p(l_line_rec,
                        l_customer_trx_line_id);

   p_customer_trx_line_id := l_customer_trx_line_id;

   /*-----------------------------------+
    |  Insert salescredit for the line  |
    +-----------------------------------*/

   insert_line_salescredit(p_customer_trx_id,
                           l_customer_trx_line_id,
                           p_primary_salesrep_id,
                           p_commitment_rec.extended_amount);

   /*--------------------------------------------+
    |  Insert the REV distribution for the line  |
    +--------------------------------------------*/

   insert_dist_line(p_customer_trx_id,
                    l_customer_trx_line_id,
                    p_gl_date,
                    p_status);

   arp_util.debug('arp_process_commitment.header_post_insert()-');

EXCEPTION
    WHEN OTHERS THEN
     arp_util.debug('EXCEPTION:  arp_process_commitment.header_post_insert()');
     RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    header_pre_update                                                      |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Header pre-update logic for commitments                                |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    dbms_sql.bind_variable                                                 |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     12-JUL-95  Martin Johnson      Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE header_pre_update IS

BEGIN

   arp_util.debug('arp_process_commitment.header_pre_update()+');

   arp_util.debug('arp_process_commitment.header_pre_update()-');

EXCEPTION
    WHEN OTHERS THEN
     arp_util.debug('EXCEPTION:  arp_process_commitment.header_pre_update()');
     RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    set_flags								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Sets various change and status flags for the current record.  	     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 |          IN/ OUT:							     |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     08-AUG-95  Martin Johnson      Created                                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE set_flags(p_new_commitment_rec     IN commitment_rec_type,
                    p_changed_flags_rec     OUT NOCOPY changed_flags_rec_type)
IS

   l_old_commitment_rec ra_customer_trx_lines%rowtype;

BEGIN

   arp_util.debug('arp_process_commitment.set_flags()+',
                  pg_msg_level_debug);

   arp_ctl_pkg.fetch_p( l_old_commitment_rec,
                        p_new_commitment_rec.customer_trx_line_id );

   IF (
        nvl(l_old_commitment_rec.inventory_item_id, 0) <>
        nvl(p_new_commitment_rec.inventory_item_id, 0)
        AND
        nvl(p_new_commitment_rec.inventory_item_id, 0) <> pg_number_dummy
      )
     THEN  p_changed_flags_rec.inventory_item_id_changed_flag := TRUE;
     ELSE  p_changed_flags_rec.inventory_item_id_changed_flag := FALSE;
   END IF;

   IF (
        nvl(l_old_commitment_rec.memo_line_id, 0) <>
        nvl(p_new_commitment_rec.memo_line_id, 0)
        AND
        nvl(p_new_commitment_rec.memo_line_id, 0) <> pg_number_dummy
      )
     THEN  p_changed_flags_rec.memo_line_id_changed_flag := TRUE;
     ELSE  p_changed_flags_rec.memo_line_id_changed_flag := FALSE;
   END IF;

   IF (
        nvl(l_old_commitment_rec.description, '!@#$%') <>
        nvl(p_new_commitment_rec.description, '!@#$%')
        AND
        nvl(p_new_commitment_rec.description, '!@#$%') <> pg_text_dummy
      )
     THEN p_changed_flags_rec.description_changed_flag := TRUE;
     ELSE p_changed_flags_rec.description_changed_flag := FALSE;
   END IF;

   IF (
        nvl(l_old_commitment_rec.extended_amount, -999999.999999) <>
        nvl(p_new_commitment_rec.extended_amount, -999999.999999)
        AND
        nvl(p_new_commitment_rec.extended_amount, -999999.999999)
                                                        <> pg_number_dummy
      )
     THEN p_changed_flags_rec.extended_amount_changed_flag := TRUE;
     ELSE p_changed_flags_rec.extended_amount_changed_flag := FALSE;
   END IF;

   IF (
        nvl(l_old_commitment_rec.interface_line_attribute1, '!@#$%') <>
        nvl(p_new_commitment_rec.interface_line_attribute1, '!@#$%')
        AND
        nvl(p_new_commitment_rec.interface_line_attribute1, '!@#$%') <>
                                                             pg_text_dummy
      )
     THEN p_changed_flags_rec.int_line_attr1_changed_flag := TRUE;
     ELSE p_changed_flags_rec.int_line_attr1_changed_flag := FALSE;
   END IF;

   IF (
        nvl(l_old_commitment_rec.interface_line_attribute2, '!@#$%') <>
        nvl(p_new_commitment_rec.interface_line_attribute2, '!@#$%')
        AND
        nvl(p_new_commitment_rec.interface_line_attribute2, '!@#$%') <>
                                                             pg_text_dummy
      )
     THEN p_changed_flags_rec.int_line_attr2_changed_flag := TRUE;
     ELSE p_changed_flags_rec.int_line_attr2_changed_flag := FALSE;
   END IF;

   IF (
        nvl(l_old_commitment_rec.interface_line_attribute3, '!@#$%') <>
        nvl(p_new_commitment_rec.interface_line_attribute3, '!@#$%')
        AND
        nvl(p_new_commitment_rec.interface_line_attribute3, '!@#$%') <>
                                                             pg_text_dummy
      )
     THEN p_changed_flags_rec.int_line_attr3_changed_flag := TRUE;
     ELSE p_changed_flags_rec.int_line_attr3_changed_flag := FALSE;
   END IF;

   IF (
        nvl(l_old_commitment_rec.interface_line_attribute4, '!@#$%') <>
        nvl(p_new_commitment_rec.interface_line_attribute4, '!@#$%')
        AND
        nvl(p_new_commitment_rec.interface_line_attribute4, '!@#$%') <>
                                                             pg_text_dummy
      )
     THEN p_changed_flags_rec.int_line_attr4_changed_flag := TRUE;
     ELSE p_changed_flags_rec.int_line_attr4_changed_flag := FALSE;
   END IF;

   IF (
        nvl(l_old_commitment_rec.interface_line_attribute5, '!@#$%') <>
        nvl(p_new_commitment_rec.interface_line_attribute5, '!@#$%')
        AND
        nvl(p_new_commitment_rec.interface_line_attribute5, '!@#$%') <>
                                                             pg_text_dummy
      )
     THEN p_changed_flags_rec.int_line_attr5_changed_flag := TRUE;
     ELSE p_changed_flags_rec.int_line_attr5_changed_flag := FALSE;
   END IF;

   IF (
        nvl(l_old_commitment_rec.interface_line_attribute6, '!@#$%') <>
        nvl(p_new_commitment_rec.interface_line_attribute6, '!@#$%')
        AND
        nvl(p_new_commitment_rec.interface_line_attribute6, '!@#$%') <>
                                                             pg_text_dummy
      )
     THEN p_changed_flags_rec.int_line_attr6_changed_flag := TRUE;
     ELSE p_changed_flags_rec.int_line_attr6_changed_flag := FALSE;
   END IF;

   IF (
        nvl(l_old_commitment_rec.interface_line_attribute7, '!@#$%') <>
        nvl(p_new_commitment_rec.interface_line_attribute7, '!@#$%')
        AND
        nvl(p_new_commitment_rec.interface_line_attribute7, '!@#$%') <>
                                                             pg_text_dummy
      )
     THEN p_changed_flags_rec.int_line_attr7_changed_flag := TRUE;
     ELSE p_changed_flags_rec.int_line_attr7_changed_flag := FALSE;
   END IF;

   IF (
        nvl(l_old_commitment_rec.interface_line_attribute8, '!@#$%') <>
        nvl(p_new_commitment_rec.interface_line_attribute8, '!@#$%')
        AND
        nvl(p_new_commitment_rec.interface_line_attribute8, '!@#$%') <>
                                                             pg_text_dummy
      )
     THEN p_changed_flags_rec.int_line_attr8_changed_flag := TRUE;
     ELSE p_changed_flags_rec.int_line_attr8_changed_flag := FALSE;
   END IF;

   IF (
        nvl(l_old_commitment_rec.interface_line_attribute9, '!@#$%') <>
        nvl(p_new_commitment_rec.interface_line_attribute9, '!@#$%')
        AND
        nvl(p_new_commitment_rec.interface_line_attribute9, '!@#$%') <>
                                                             pg_text_dummy
      )
     THEN p_changed_flags_rec.int_line_attr9_changed_flag := TRUE;
     ELSE p_changed_flags_rec.int_line_attr9_changed_flag := FALSE;
   END IF;

   IF (
        nvl(l_old_commitment_rec.interface_line_attribute10, '!@#$%') <>
        nvl(p_new_commitment_rec.interface_line_attribute10, '!@#$%')
        AND
        nvl(p_new_commitment_rec.interface_line_attribute10, '!@#$%') <>
                                                             pg_text_dummy
      )
     THEN p_changed_flags_rec.int_line_attr10_changed_flag := TRUE;
     ELSE p_changed_flags_rec.int_line_attr10_changed_flag := FALSE;
   END IF;

   IF (
        nvl(l_old_commitment_rec.interface_line_attribute11, '!@#$%') <>
        nvl(p_new_commitment_rec.interface_line_attribute11, '!@#$%')
        AND
        nvl(p_new_commitment_rec.interface_line_attribute11, '!@#$%') <>
                                                             pg_text_dummy
      )
     THEN p_changed_flags_rec.int_line_attr11_changed_flag := TRUE;
     ELSE p_changed_flags_rec.int_line_attr11_changed_flag := FALSE;
   END IF;

   IF (
        nvl(l_old_commitment_rec.interface_line_attribute12, '!@#$%') <>
        nvl(p_new_commitment_rec.interface_line_attribute12, '!@#$%')
        AND
        nvl(p_new_commitment_rec.interface_line_attribute12, '!@#$%') <>
                                                             pg_text_dummy
      )
     THEN p_changed_flags_rec.int_line_attr12_changed_flag := TRUE;
     ELSE p_changed_flags_rec.int_line_attr12_changed_flag := FALSE;
   END IF;

   IF (
        nvl(l_old_commitment_rec.interface_line_attribute13, '!@#$%') <>
        nvl(p_new_commitment_rec.interface_line_attribute13, '!@#$%')
        AND
        nvl(p_new_commitment_rec.interface_line_attribute13, '!@#$%') <>
                                                             pg_text_dummy
      )
     THEN p_changed_flags_rec.int_line_attr13_changed_flag := TRUE;
     ELSE p_changed_flags_rec.int_line_attr13_changed_flag := FALSE;
   END IF;

   IF (
        nvl(l_old_commitment_rec.interface_line_attribute14, '!@#$%') <>
        nvl(p_new_commitment_rec.interface_line_attribute14, '!@#$%')
        AND
        nvl(p_new_commitment_rec.interface_line_attribute14, '!@#$%') <>
                                                             pg_text_dummy
      )
     THEN p_changed_flags_rec.int_line_attr14_changed_flag := TRUE;
     ELSE p_changed_flags_rec.int_line_attr14_changed_flag := FALSE;
   END IF;

   IF (
        nvl(l_old_commitment_rec.interface_line_attribute15, '!@#$%') <>
        nvl(p_new_commitment_rec.interface_line_attribute15, '!@#$%')
        AND
        nvl(p_new_commitment_rec.interface_line_attribute15, '!@#$%') <>
                                                             pg_text_dummy
      )
     THEN p_changed_flags_rec.int_line_attr15_changed_flag := TRUE;
     ELSE p_changed_flags_rec.int_line_attr15_changed_flag := FALSE;
   END IF;

   IF (
        nvl(l_old_commitment_rec.interface_line_context, '!@#$%') <>
        nvl(p_new_commitment_rec.interface_line_context, '!@#$%')
        AND
        nvl(p_new_commitment_rec.interface_line_context, '!@#$%') <>
                                                             pg_text_dummy
      )
     THEN p_changed_flags_rec.int_line_context_changed_flag := TRUE;
     ELSE p_changed_flags_rec.int_line_context_changed_flag := FALSE;
   END IF;

   IF (
        nvl(l_old_commitment_rec.attribute_category, '!@#$%') <>
        nvl(p_new_commitment_rec.attribute_category, '!@#$%')
        AND
        nvl(p_new_commitment_rec.attribute_category, '!@#$%') <>
                                                             pg_text_dummy
      )
     THEN p_changed_flags_rec.attr_category_changed_flag := TRUE;
     ELSE p_changed_flags_rec.attr_category_changed_flag := FALSE;
   END IF;

   IF (
        nvl(l_old_commitment_rec.attribute1, '!@#$%') <>
        nvl(p_new_commitment_rec.attribute1, '!@#$%')
        AND
        nvl(p_new_commitment_rec.attribute1, '!@#$%') <>
                                                             pg_text_dummy
      )
     THEN p_changed_flags_rec.attribute1_changed_flag := TRUE;
     ELSE p_changed_flags_rec.attribute1_changed_flag := FALSE;
   END IF;

   IF (
        nvl(l_old_commitment_rec.attribute2, '!@#$%') <>
        nvl(p_new_commitment_rec.attribute2, '!@#$%')
        AND
        nvl(p_new_commitment_rec.attribute2, '!@#$%') <>
                                                             pg_text_dummy
      )
     THEN p_changed_flags_rec.attribute2_changed_flag := TRUE;
     ELSE p_changed_flags_rec.attribute2_changed_flag := FALSE;
   END IF;

   IF (
        nvl(l_old_commitment_rec.attribute3, '!@#$%') <>
        nvl(p_new_commitment_rec.attribute3, '!@#$%')
        AND
        nvl(p_new_commitment_rec.attribute3, '!@#$%') <>
                                                             pg_text_dummy
      )
     THEN p_changed_flags_rec.attribute3_changed_flag := TRUE;
     ELSE p_changed_flags_rec.attribute3_changed_flag := FALSE;
   END IF;

   IF (
        nvl(l_old_commitment_rec.attribute4, '!@#$%') <>
        nvl(p_new_commitment_rec.attribute4, '!@#$%')
        AND
        nvl(p_new_commitment_rec.attribute4, '!@#$%') <>
                                                             pg_text_dummy
      )
     THEN p_changed_flags_rec.attribute4_changed_flag := TRUE;
     ELSE p_changed_flags_rec.attribute4_changed_flag := FALSE;
   END IF;

   IF (
        nvl(l_old_commitment_rec.attribute5, '!@#$%') <>
        nvl(p_new_commitment_rec.attribute5, '!@#$%')
        AND
        nvl(p_new_commitment_rec.attribute5, '!@#$%') <>
                                                             pg_text_dummy
      )
     THEN p_changed_flags_rec.attribute5_changed_flag := TRUE;
     ELSE p_changed_flags_rec.attribute5_changed_flag := FALSE;
   END IF;

   IF (
        nvl(l_old_commitment_rec.attribute6, '!@#$%') <>
        nvl(p_new_commitment_rec.attribute6, '!@#$%')
        AND
        nvl(p_new_commitment_rec.attribute6, '!@#$%') <>
                                                             pg_text_dummy
      )
     THEN p_changed_flags_rec.attribute6_changed_flag := TRUE;
     ELSE p_changed_flags_rec.attribute6_changed_flag := FALSE;
   END IF;

   IF (
        nvl(l_old_commitment_rec.attribute7, '!@#$%') <>
        nvl(p_new_commitment_rec.attribute7, '!@#$%')
        AND
        nvl(p_new_commitment_rec.attribute7, '!@#$%') <>
                                                             pg_text_dummy
      )
     THEN p_changed_flags_rec.attribute7_changed_flag := TRUE;
     ELSE p_changed_flags_rec.attribute7_changed_flag := FALSE;
   END IF;

   IF (
        nvl(l_old_commitment_rec.attribute8, '!@#$%') <>
        nvl(p_new_commitment_rec.attribute8, '!@#$%')
        AND
        nvl(p_new_commitment_rec.attribute8, '!@#$%') <>
                                                             pg_text_dummy
      )
     THEN p_changed_flags_rec.attribute8_changed_flag := TRUE;
     ELSE p_changed_flags_rec.attribute8_changed_flag := FALSE;
   END IF;

   IF (
        nvl(l_old_commitment_rec.attribute9, '!@#$%') <>
        nvl(p_new_commitment_rec.attribute9, '!@#$%')
        AND
        nvl(p_new_commitment_rec.attribute9, '!@#$%') <>
                                                             pg_text_dummy
      )
     THEN p_changed_flags_rec.attribute9_changed_flag := TRUE;
     ELSE p_changed_flags_rec.attribute9_changed_flag := FALSE;
   END IF;

   IF (
        nvl(l_old_commitment_rec.attribute10, '!@#$%') <>
        nvl(p_new_commitment_rec.attribute10, '!@#$%')
        AND
        nvl(p_new_commitment_rec.attribute10, '!@#$%') <>
                                                             pg_text_dummy
      )
     THEN p_changed_flags_rec.attribute10_changed_flag := TRUE;
     ELSE p_changed_flags_rec.attribute10_changed_flag := FALSE;
   END IF;

   IF (
        nvl(l_old_commitment_rec.attribute11, '!@#$%') <>
        nvl(p_new_commitment_rec.attribute11, '!@#$%')
        AND
        nvl(p_new_commitment_rec.attribute11, '!@#$%') <>
                                                             pg_text_dummy
      )
     THEN p_changed_flags_rec.attribute11_changed_flag := TRUE;
     ELSE p_changed_flags_rec.attribute11_changed_flag := FALSE;
   END IF;

   IF (
        nvl(l_old_commitment_rec.attribute12, '!@#$%') <>
        nvl(p_new_commitment_rec.attribute12, '!@#$%')
        AND
        nvl(p_new_commitment_rec.attribute12, '!@#$%') <>
                                                             pg_text_dummy
      )
     THEN p_changed_flags_rec.attribute12_changed_flag := TRUE;
     ELSE p_changed_flags_rec.attribute12_changed_flag := FALSE;
   END IF;

   IF (
        nvl(l_old_commitment_rec.attribute13, '!@#$%') <>
        nvl(p_new_commitment_rec.attribute13, '!@#$%')
        AND
        nvl(p_new_commitment_rec.attribute13, '!@#$%') <>
                                                             pg_text_dummy
      )
     THEN p_changed_flags_rec.attribute13_changed_flag := TRUE;
     ELSE p_changed_flags_rec.attribute13_changed_flag := FALSE;
   END IF;

   IF (
        nvl(l_old_commitment_rec.attribute14, '!@#$%') <>
        nvl(p_new_commitment_rec.attribute14, '!@#$%')
        AND
        nvl(p_new_commitment_rec.attribute14, '!@#$%') <>
                                                             pg_text_dummy
      )
     THEN p_changed_flags_rec.attribute14_changed_flag := TRUE;
     ELSE p_changed_flags_rec.attribute14_changed_flag := FALSE;
   END IF;

   IF (
        nvl(l_old_commitment_rec.attribute15, '!@#$%') <>
        nvl(p_new_commitment_rec.attribute15, '!@#$%')
        AND
        nvl(p_new_commitment_rec.attribute15, '!@#$%') <>
                                                             pg_text_dummy
      )
     THEN p_changed_flags_rec.attribute15_changed_flag := TRUE;
     ELSE p_changed_flags_rec.attribute15_changed_flag := FALSE;
   END IF;

   IF (
        nvl(l_old_commitment_rec.default_ussgl_transaction_code, '!@#$%') <>
        nvl(p_new_commitment_rec.default_ussgl_transaction_code, '!@#$%')
        AND
        nvl(p_new_commitment_rec.default_ussgl_transaction_code, '!@#$%') <>
                                                             pg_text_dummy
      )
     THEN p_changed_flags_rec.ussgl_trx_code_changed_flag := TRUE;
     ELSE p_changed_flags_rec.ussgl_trx_code_changed_flag := FALSE;
   END IF;

   arp_util.debug('arp_process_commitment.set_flags()-',
                  pg_msg_level_debug);

EXCEPTION
  WHEN OTHERS THEN
     arp_util.debug(
           'EXCEPTION:  arp_process_commitment.set_flags()',
            pg_msg_level_debug);
     RAISE;


END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    header_post_update                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Header post-update logic for commitments                               |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     12-JUL-95  Martin Johnson      Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE header_post_update( p_commitment_rec        IN commitment_rec_type,
                              p_foreign_currency_code IN
                                fnd_currencies.currency_code%type,
                              p_exchange_rate         IN
                                ra_customer_trx.exchange_rate%type,
                              p_rerun_autoacc_flag    IN boolean )
IS

   l_changed_flags_rec changed_flags_rec_type;
   l_line_rec          ra_customer_trx_lines%rowtype;

BEGIN

   arp_util.debug('arp_process_commitment.header_post_update()+');

   set_flags( p_commitment_rec,
              l_changed_flags_rec );

   arp_ctl_pkg.set_to_dummy( l_line_rec );

   IF l_changed_flags_rec.inventory_item_id_changed_flag
     THEN l_line_rec.inventory_item_id := p_commitment_rec.inventory_item_id;
   END IF;

   IF l_changed_flags_rec.memo_line_id_changed_flag
     THEN l_line_rec.memo_line_id := p_commitment_rec.memo_line_id;
   END IF;

   IF l_changed_flags_rec.description_changed_flag
     THEN l_line_rec.description := p_commitment_rec.description;
   END IF;

   IF l_changed_flags_rec.extended_amount_changed_flag
     THEN l_line_rec.extended_amount := p_commitment_rec.extended_amount;
          l_line_rec.revenue_amount  := p_commitment_rec.extended_amount;
   END IF;

   IF l_changed_flags_rec.int_line_attr1_changed_flag
     THEN l_line_rec.interface_line_attribute1 :=
                        p_commitment_rec.interface_line_attribute1;
   END IF;

   IF l_changed_flags_rec.int_line_attr2_changed_flag
     THEN l_line_rec.interface_line_attribute2 :=
                        p_commitment_rec.interface_line_attribute2;
   END IF;

   IF l_changed_flags_rec.int_line_attr3_changed_flag
     THEN l_line_rec.interface_line_attribute3 :=
                        p_commitment_rec.interface_line_attribute3;
   END IF;

   IF l_changed_flags_rec.int_line_attr4_changed_flag
     THEN l_line_rec.interface_line_attribute4 :=
                        p_commitment_rec.interface_line_attribute4;
   END IF;

   IF l_changed_flags_rec.int_line_attr5_changed_flag
     THEN l_line_rec.interface_line_attribute5 :=
                        p_commitment_rec.interface_line_attribute5;
   END IF;

   IF l_changed_flags_rec.int_line_attr6_changed_flag
     THEN l_line_rec.interface_line_attribute6 :=
                        p_commitment_rec.interface_line_attribute6;
   END IF;

   IF l_changed_flags_rec.int_line_attr7_changed_flag
     THEN l_line_rec.interface_line_attribute7 :=
                        p_commitment_rec.interface_line_attribute7;
   END IF;

   IF l_changed_flags_rec.int_line_attr8_changed_flag
     THEN l_line_rec.interface_line_attribute8 :=
                        p_commitment_rec.interface_line_attribute8;
   END IF;

   IF l_changed_flags_rec.int_line_attr9_changed_flag
     THEN l_line_rec.interface_line_attribute9 :=
                        p_commitment_rec.interface_line_attribute9;
   END IF;

   IF l_changed_flags_rec.int_line_attr10_changed_flag
     THEN l_line_rec.interface_line_attribute10 :=
                        p_commitment_rec.interface_line_attribute10;
   END IF;

   IF l_changed_flags_rec.int_line_attr11_changed_flag
     THEN l_line_rec.interface_line_attribute11 :=
                        p_commitment_rec.interface_line_attribute11;
   END IF;

   IF l_changed_flags_rec.int_line_attr12_changed_flag
     THEN l_line_rec.interface_line_attribute12 :=
                        p_commitment_rec.interface_line_attribute12;
   END IF;

   IF l_changed_flags_rec.int_line_attr13_changed_flag
     THEN l_line_rec.interface_line_attribute13 :=
                        p_commitment_rec.interface_line_attribute13;
   END IF;

   IF l_changed_flags_rec.int_line_attr14_changed_flag
     THEN l_line_rec.interface_line_attribute14 :=
                        p_commitment_rec.interface_line_attribute14;
   END IF;

   IF l_changed_flags_rec.int_line_attr15_changed_flag
     THEN l_line_rec.interface_line_attribute15 :=
                        p_commitment_rec.interface_line_attribute15;
   END IF;

   IF l_changed_flags_rec.int_line_context_changed_flag
     THEN l_line_rec.interface_line_context :=
                        p_commitment_rec.interface_line_context;
   END IF;

   IF l_changed_flags_rec.attr_category_changed_flag
     THEN l_line_rec.attribute_category := p_commitment_rec.attribute_category;
   END IF;

   IF l_changed_flags_rec.attribute1_changed_flag
     THEN l_line_rec.attribute1 := p_commitment_rec.attribute1;
   END IF;

   IF l_changed_flags_rec.attribute2_changed_flag
     THEN l_line_rec.attribute2 := p_commitment_rec.attribute2;
   END IF;

   IF l_changed_flags_rec.attribute3_changed_flag
     THEN l_line_rec.attribute3 := p_commitment_rec.attribute3;
   END IF;

   IF l_changed_flags_rec.attribute4_changed_flag
     THEN l_line_rec.attribute4 := p_commitment_rec.attribute4;
   END IF;

   IF l_changed_flags_rec.attribute5_changed_flag
     THEN l_line_rec.attribute5 := p_commitment_rec.attribute5;
   END IF;

   IF l_changed_flags_rec.attribute6_changed_flag
     THEN l_line_rec.attribute6 := p_commitment_rec.attribute6;
   END IF;

   IF l_changed_flags_rec.attribute7_changed_flag
     THEN l_line_rec.attribute7 := p_commitment_rec.attribute7;
   END IF;

   IF l_changed_flags_rec.attribute8_changed_flag
     THEN l_line_rec.attribute8 := p_commitment_rec.attribute8;
   END IF;

   IF l_changed_flags_rec.attribute9_changed_flag
     THEN l_line_rec.attribute9 := p_commitment_rec.attribute9;
   END IF;

   IF l_changed_flags_rec.attribute10_changed_flag
     THEN l_line_rec.attribute10 := p_commitment_rec.attribute10;
   END IF;

   IF l_changed_flags_rec.attribute11_changed_flag
     THEN l_line_rec.attribute11 := p_commitment_rec.attribute11;
   END IF;

   IF l_changed_flags_rec.attribute12_changed_flag
     THEN l_line_rec.attribute12 := p_commitment_rec.attribute12;
   END IF;

   IF l_changed_flags_rec.attribute13_changed_flag
     THEN l_line_rec.attribute13 := p_commitment_rec.attribute13;
   END IF;

   IF l_changed_flags_rec.attribute14_changed_flag
     THEN l_line_rec.attribute14 := p_commitment_rec.attribute14;
   END IF;

   IF l_changed_flags_rec.attribute15_changed_flag
     THEN l_line_rec.attribute15 := p_commitment_rec.attribute15;
   END IF;

   IF l_changed_flags_rec.ussgl_trx_code_changed_flag
     THEN
          l_line_rec.default_ussgl_transaction_code :=
                               p_commitment_rec.default_ussgl_transaction_code;

   END IF;


   /*-----------------------------------------------+
    |  Call lines table handler to update the line  |
    +-----------------------------------------------*/

   arp_ctl_pkg.update_p( l_line_rec,
                         p_commitment_rec.customer_trx_line_id );


   /*-------------------------------------------------------------+
    |  If commitment amount changed, update the salescredits and  |
    |  distribution amounts                                       |
    +-------------------------------------------------------------*/

   IF l_changed_flags_rec.extended_amount_changed_flag
     THEN
       arp_ctls_pkg.update_amounts_f_ctl_id(
                                p_commitment_rec.customer_trx_line_id,
                                p_commitment_rec.extended_amount,
                                p_foreign_currency_code);

        -- Don't need to do this update to gl_dist if autoaccounting
        -- is going to do it anyway.

        IF not p_rerun_autoacc_flag THEN
            arp_ctlgd_pkg.update_amount_f_ctl_id(
                                p_commitment_rec.customer_trx_line_id,
                                p_commitment_rec.extended_amount,
                                p_foreign_currency_code,
                                pg_base_curr_code,
                                p_exchange_rate,
                                pg_base_precision,
                                pg_base_min_acc_unit);
        END IF;
   END IF;

   arp_util.debug('arp_process_commitment.header_post_update()-');

EXCEPTION
    WHEN OTHERS THEN
     arp_util.debug('EXCEPTION:  arp_process_commitment.header_post_update()');
     RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    header_pre_delete                                                      |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Header pre-delete logic for commitments                                |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    dbms_sql.bind_variable                                                 |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     12-JUL-95  Martin Johnson      Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE header_pre_delete IS

BEGIN

   arp_util.debug('arp_process_commitment.header_pre_delete()+');

   arp_util.debug('arp_process_commitment.header_pre_delete()-');

EXCEPTION
    WHEN OTHERS THEN
     arp_util.debug('EXCEPTION:  arp_process_commitment.header_pre_delete()');
     RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    set_to_dummy							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure initializes all columns in the commitment record        |
 |    to the appropriate dummy value for its datatype.			     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    None						     |
 |              OUT:                                                         |
 |                    p_commitment_rec_rec   - The record to initialize	     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     16-AUG-95  Martin Johnson      Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE set_to_dummy( p_commitment_rec OUT NOCOPY commitment_rec_type ) IS

BEGIN

   arp_util.debug('arp_process_commitment.set_to_dummy()+',
                  pg_msg_level_debug);

   p_commitment_rec.customer_trx_line_id       := pg_number_dummy;
   p_commitment_rec.inventory_item_id          := pg_number_dummy;
   p_commitment_rec.memo_line_id               := pg_number_dummy;
   p_commitment_rec.description                := pg_text_dummy;
   p_commitment_rec.extended_amount            := pg_number_dummy;
   p_commitment_rec.interface_line_attribute1  := pg_text_dummy;
   p_commitment_rec.interface_line_attribute2  := pg_text_dummy;
   p_commitment_rec.interface_line_attribute3  := pg_text_dummy;
   p_commitment_rec.interface_line_attribute4  := pg_text_dummy;
   p_commitment_rec.interface_line_attribute5  := pg_text_dummy;
   p_commitment_rec.interface_line_attribute6  := pg_text_dummy;
   p_commitment_rec.interface_line_attribute7  := pg_text_dummy;
   p_commitment_rec.interface_line_attribute8  := pg_text_dummy;
   p_commitment_rec.interface_line_attribute9  := pg_text_dummy;
   p_commitment_rec.interface_line_attribute10 := pg_text_dummy;
   p_commitment_rec.interface_line_attribute11 := pg_text_dummy;
   p_commitment_rec.interface_line_attribute12 := pg_text_dummy;
   p_commitment_rec.interface_line_attribute13 := pg_text_dummy;
   p_commitment_rec.interface_line_attribute14 := pg_text_dummy;
   p_commitment_rec.interface_line_attribute15 := pg_text_dummy;
   p_commitment_rec.interface_line_context     := pg_text_dummy;
   p_commitment_rec.attribute_category         := pg_text_dummy;
   p_commitment_rec.attribute1                 := pg_text_dummy;
   p_commitment_rec.attribute2                 := pg_text_dummy;
   p_commitment_rec.attribute3                 := pg_text_dummy;
   p_commitment_rec.attribute4                 := pg_text_dummy;
   p_commitment_rec.attribute5                 := pg_text_dummy;
   p_commitment_rec.attribute6                 := pg_text_dummy;
   p_commitment_rec.attribute7                 := pg_text_dummy;
   p_commitment_rec.attribute8                 := pg_text_dummy;
   p_commitment_rec.attribute9                 := pg_text_dummy;
   p_commitment_rec.attribute10                := pg_text_dummy;
   p_commitment_rec.attribute11                := pg_text_dummy;
   p_commitment_rec.attribute12                := pg_text_dummy;
   p_commitment_rec.attribute13                := pg_text_dummy;
   p_commitment_rec.attribute14                := pg_text_dummy;
   p_commitment_rec.attribute15                := pg_text_dummy;

   arp_util.debug('arp_process_commitment.set_to_dummy()-',
                  pg_msg_level_debug);

EXCEPTION
    WHEN OTHERS THEN
     arp_util.debug(
           'EXCEPTION:  arp_process_commitment.set_to_dummy()',
            pg_msg_level_debug);
     RAISE;

END;

  /*---------------------------------------------+
   |   Package initialization section.           |
   +---------------------------------------------*/

BEGIN

   pg_msg_level_debug := arp_global.MSG_LEVEL_DEBUG;

   pg_text_dummy   := arp_ctl_pkg.get_text_dummy;
   pg_number_dummy := arp_ctl_pkg.get_number_dummy;

   pg_base_curr_code    := arp_global.functional_currency;
   pg_base_precision    := arp_global.base_precision;
   pg_base_min_acc_unit := arp_global.base_min_acc_unit;

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_process_commitment.initialization');
        RAISE;


END ARP_PROCESS_COMMITMENT;

/
