--------------------------------------------------------
--  DDL for Package Body ARP_CTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CTLS_PKG" AS
/* $Header: ARTITLSB.pls 120.14.12010000.1 2008/07/24 16:57:02 appldev ship $ */
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

  pg_salesrep_required_flag  ar_system_parameters.salesrep_required_flag%type;

  /*--------------------------------------------------------+
   |  Dummy constants for use in update and lock operations |
   +--------------------------------------------------------*/

  AR_TEXT_DUMMY   CONSTANT VARCHAR2(10) := '~~!@#$*&^';
  AR_NUMBER_DUMMY CONSTANT NUMBER(15)   := -999999999999999;
  AR_DATE_DUMMY   CONSTANT DATE         := to_date(1, 'J');

  /*---------------------------------------------------------------+
   |  Package global variables to hold the parsed update cursors.  |
   |  This allows the cursors to be reused without being reparsed. |
   +---------------------------------------------------------------*/

  pg_cursor1  integer := '';
  pg_cursor2  integer := '';
  pg_cursor3  integer := '';
  pg_cursor4  integer := '';

  /*-------------------------------------+
   |  WHO column values from FND_GLOBAL  |
   +-------------------------------------*/

  pg_user_id          number;
  pg_conc_login_id    number;
  pg_login_id         number;
  pg_prog_appl_id     number;
  pg_conc_program_id  number;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    erase_foreign_key_references                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Erases foreign key references to cust_trx_line_salesrep_id             |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_cust_trx_line_salesrep_id                            |
 |                    p_customer_trx_id                                      |
 |                    p_customer_trx_line_id                                 |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     27-SEP-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/


PROCEDURE erase_foreign_key_references( p_cust_trx_line_salesrep_id IN
                    ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type,
                                        p_customer_trx_id IN
                                          ra_customer_trx.customer_trx_id%type,
                                        p_customer_trx_line_id IN
                    ra_customer_trx_lines.customer_trx_line_id%type)
          IS

   l_srep_rec  ra_cust_trx_line_salesreps%rowtype;
   l_dist_rec  ra_cust_trx_line_gl_dist%rowtype;

BEGIN

   arp_util.debug('arp_ctls_pkg.erase_foreign_key_references()+');



      /*------------------------------------------------------------------+
       |  Erase foreign key references to the salescredit being deleted:  |
       |    ra_cust_trx_line_salesreps.prev_cust_trx_line_salesrep_id     |
       |    ra_cust_trx_line_gl_dist.cust_trx_line_salesrep_id		  |
       +------------------------------------------------------------------*/

      /*-------------------------------------------------------------------+
       | Erase ra_cust_trx_line_salesreps.prev_cust_trx_line_salesrep_id   |
       | and erase ra_cust_trx_line_gl_dist.cust_trx_line_salesrep_id      |
       +-------------------------------------------------------------------*/

      BEGIN
         arp_ctls_pkg.set_to_dummy(l_srep_rec);

         l_srep_rec.prev_cust_trx_line_salesrep_id := null;

         arp_ctlgd_pkg.set_to_dummy(l_dist_rec);

         l_dist_rec.cust_trx_line_salesrep_id := null;

        /*--------------------------------------------------+
         |  Do the appropriate updates depending on which   |
         |  parameters were passed in.                      |
         +--------------------------------------------------*/

         IF ( p_customer_trx_id IS NOT NULL )
         THEN
                 BEGIN
                      arp_ctls_pkg.update_f_ct_id(l_srep_rec,
                                                  p_customer_trx_id);
                 EXCEPTION
                    WHEN NO_DATA_FOUND THEN NULL;
                    WHEN OTHERS THEN RAISE;
                 END;

                 BEGIN
                      arp_ctlgd_pkg.update_f_ct_id( l_dist_rec,
                                                    p_customer_trx_id,
                                                    null,
                                                    null);
                 EXCEPTION
                    WHEN NO_DATA_FOUND THEN NULL;
                    WHEN OTHERS THEN RAISE;
                 END;

         ELSIF ( p_customer_trx_line_id IS NOT NULL )
            THEN
                 BEGIN
                      arp_ctls_pkg.update_f_ctl_id(l_srep_rec,
                                                   p_customer_trx_line_id);
                 EXCEPTION
                    WHEN NO_DATA_FOUND THEN NULL;
                    WHEN OTHERS THEN RAISE;
                 END;

                 BEGIN
                      arp_ctlgd_pkg.update_f_ctl_id( l_dist_rec,
                                                     p_customer_trx_line_id,
                                                     null,
                                                     null);
                 EXCEPTION
                    WHEN NO_DATA_FOUND THEN NULL;
                    WHEN OTHERS THEN RAISE;
                 END;

         ELSIF ( p_cust_trx_line_salesrep_id IS NOT NULL)
            THEN
                 BEGIN
                     arp_ctls_pkg.update_f_psr_id(l_srep_rec,
                                                  p_cust_trx_line_salesrep_id);
                 EXCEPTION
                    WHEN NO_DATA_FOUND THEN NULL;
                    WHEN OTHERS THEN RAISE;
                 END;

                 BEGIN
                   arp_ctlgd_pkg.update_f_ctls_id( l_dist_rec,
                                                   p_cust_trx_line_salesrep_id,
                                                   null,
                                                   null);
                 EXCEPTION
                    WHEN NO_DATA_FOUND THEN NULL;
                    WHEN OTHERS THEN RAISE;
                 END;

         END IF;


         EXCEPTION
         WHEN NO_DATA_FOUND THEN NULL;
         WHEN OTHERS THEN

         arp_util.debug(
                   'EXCEPTION:  arp_process_salescredit.delete_salescredit()');
         RAISE;
      END;

   arp_util.debug('arp_ctls_pkg.erase_foreign_key_references()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug(
                    'EXCEPTION:  arp_ctls_pkg.erase_foreign_key_references()');
        RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    bind_srep_variables                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Binds variables from the record variable to the bind variables         |
 |    in the dynamic SQL update statement.                                   |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    dbms_sql.bind_variable                                                 |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_update_cursor  - ID of the update cursor             |
 |                    p_srep_rec       - ra_cust_trx_line_salesreps record   |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     08-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/


PROCEDURE bind_srep_variables(p_update_cursor IN integer,
                              p_srep_rec IN ra_cust_trx_line_salesreps%rowtype)
          IS

BEGIN

   arp_util.debug('arp_ctls_pkg.bind_srep_variables()+');

  /*------------------+
   |  Dummy constants |
   +------------------*/

   dbms_sql.bind_variable(p_update_cursor, ':ar_text_dummy',
                          AR_TEXT_DUMMY);

   dbms_sql.bind_variable(p_update_cursor, ':ar_number_dummy',
                          AR_NUMBER_DUMMY);

   dbms_sql.bind_variable(p_update_cursor, ':ar_date_dummy',
                          AR_DATE_DUMMY);

  /*------------------+
   |  WHO variables   |
   +------------------*/

   dbms_sql.bind_variable(p_update_cursor, ':pg_user_id',
                          pg_user_id);

   dbms_sql.bind_variable(p_update_cursor, ':pg_login_id',
                          pg_login_id);

   dbms_sql.bind_variable(p_update_cursor, ':pg_conc_login_id',
                          pg_conc_login_id);


  /*----------------------------------------------+
   |  Bind variables for all columns in the table |
   +----------------------------------------------*/


   dbms_sql.bind_variable(p_update_cursor, ':cust_trx_line_salesrep_id',
                          p_srep_rec.cust_trx_line_salesrep_id);

   dbms_sql.bind_variable(p_update_cursor, ':customer_trx_id',
                          p_srep_rec.customer_trx_id);

   dbms_sql.bind_variable(p_update_cursor, ':customer_trx_line_id',
                          p_srep_rec.customer_trx_line_id);

   dbms_sql.bind_variable(p_update_cursor, ':salesrep_id',
                          p_srep_rec.salesrep_id);

   dbms_sql.bind_variable(p_update_cursor, ':revenue_amount_split',
                          p_srep_rec.revenue_amount_split);

   dbms_sql.bind_variable(p_update_cursor, ':non_revenue_amount_split',
                          p_srep_rec.non_revenue_amount_split);

   dbms_sql.bind_variable(p_update_cursor, ':non_revenue_percent_split',
                          p_srep_rec.non_revenue_percent_split);

   dbms_sql.bind_variable(p_update_cursor, ':revenue_percent_split',
                          p_srep_rec.revenue_percent_split);

   dbms_sql.bind_variable(p_update_cursor, ':prev_cust_trx_line_salesrep_id',
                          p_srep_rec.prev_cust_trx_line_salesrep_id);

   dbms_sql.bind_variable(p_update_cursor, ':attribute_category',
                          p_srep_rec.attribute_category);

   dbms_sql.bind_variable(p_update_cursor, ':attribute1',
                          p_srep_rec.attribute1);

   dbms_sql.bind_variable(p_update_cursor, ':attribute2',
                          p_srep_rec.attribute2);

   dbms_sql.bind_variable(p_update_cursor, ':attribute3',
                          p_srep_rec.attribute3);

   dbms_sql.bind_variable(p_update_cursor, ':attribute4',
                          p_srep_rec.attribute4);

   dbms_sql.bind_variable(p_update_cursor, ':attribute5',
                          p_srep_rec.attribute5);

   dbms_sql.bind_variable(p_update_cursor, ':attribute6',
                          p_srep_rec.attribute6);

   dbms_sql.bind_variable(p_update_cursor, ':attribute7',
                          p_srep_rec.attribute7);

   dbms_sql.bind_variable(p_update_cursor, ':attribute8',
                          p_srep_rec.attribute8);

   dbms_sql.bind_variable(p_update_cursor, ':attribute9',
                          p_srep_rec.attribute9);

   dbms_sql.bind_variable(p_update_cursor, ':attribute10',
                          p_srep_rec.attribute10);

   dbms_sql.bind_variable(p_update_cursor, ':attribute11',
                          p_srep_rec.attribute11);

   dbms_sql.bind_variable(p_update_cursor, ':attribute12',
                          p_srep_rec.attribute12);

   dbms_sql.bind_variable(p_update_cursor, ':attribute13',
                          p_srep_rec.attribute13);

   dbms_sql.bind_variable(p_update_cursor, ':attribute14',
                          p_srep_rec.attribute14);

   dbms_sql.bind_variable(p_update_cursor, ':attribute15',
                          p_srep_rec.attribute15);

/* BEGIN bug 3067675 */

   dbms_sql.bind_variable(p_update_cursor, ':revenue_salesgroup_id',
                          p_srep_rec.revenue_salesgroup_id);

   dbms_sql.bind_variable(p_update_cursor, ':non_revenue_salesgroup_id',
                          p_srep_rec.non_revenue_salesgroup_id);

/* END bug 3067675 */

   dbms_sql.bind_variable(p_update_cursor, ':last_update_date',
                          p_srep_rec.last_update_date);

   dbms_sql.bind_variable(p_update_cursor, ':last_updated_by',
                          p_srep_rec.last_updated_by);

   dbms_sql.bind_variable(p_update_cursor, ':creation_date',
                          p_srep_rec.creation_date);

   dbms_sql.bind_variable(p_update_cursor, ':created_by',
                          p_srep_rec.created_by);

   dbms_sql.bind_variable(p_update_cursor, ':last_update_login',
                          p_srep_rec.last_update_login);

   dbms_sql.bind_variable(p_update_cursor, ':program_application_id',
                          p_srep_rec.program_application_id);

   dbms_sql.bind_variable(p_update_cursor, ':program_id',
                          p_srep_rec.program_id);

   dbms_sql.bind_variable(p_update_cursor, ':program_update_date',
                          p_srep_rec.program_update_date);


   arp_util.debug('arp_ctls_pkg.bind_srep_variables()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ctls_pkg.bind_srep_variables()');
        RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    construct_srep_update_stmt 					     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Copies the text of the dynamic SQL update statement into the           |
 |    out NOCOPY paramater. The update statement does not contain a where clause    |
 |    since this is the dynamic part that is added later.                    |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    None.                                                  |
 |              OUT:                                                         |
 |                    update_text  - text of the update statement            |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |    This statement only updates columns in the srep record that do not     |
 |    contain the dummy values that indicate that they should not be changed.|
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     06-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE construct_srep_update_stmt( update_text OUT NOCOPY varchar2) IS

BEGIN
   arp_util.debug('arp_ctls_pkg.construct_srep_update_stmt()+');

   update_text :=
 'UPDATE ra_cust_trx_line_salesreps
   SET    cust_trx_line_salesrep_id =
               DECODE(:cust_trx_line_salesrep_id,
                      :ar_number_dummy, cust_trx_line_salesrep_id,
                                        :cust_trx_line_salesrep_id),
          customer_trx_id =
               DECODE(:customer_trx_id,
                      :ar_number_dummy, customer_trx_id,
                                        :customer_trx_id),
          customer_trx_line_id =
               DECODE(:customer_trx_line_id,
                      :ar_number_dummy, customer_trx_line_id,
                                        :customer_trx_line_id),
          salesrep_id =
               DECODE(:salesrep_id,
                      :ar_number_dummy, salesrep_id,
                                        :salesrep_id),
          revenue_amount_split =
               DECODE(:revenue_amount_split,
                      :ar_number_dummy, revenue_amount_split,
                                        :revenue_amount_split),
          non_revenue_amount_split =
               DECODE(:non_revenue_amount_split,
                      :ar_number_dummy, non_revenue_amount_split,
                                        :non_revenue_amount_split),
          non_revenue_percent_split =
               DECODE(:non_revenue_percent_split,
                      :ar_number_dummy, non_revenue_percent_split,
                                        :non_revenue_percent_split),
          revenue_percent_split =
               DECODE(:revenue_percent_split,
                      :ar_number_dummy, revenue_percent_split,
                                        :revenue_percent_split),
          prev_cust_trx_line_salesrep_id =
               DECODE(:prev_cust_trx_line_salesrep_id,
                      :ar_number_dummy, prev_cust_trx_line_salesrep_id,
                                        :prev_cust_trx_line_salesrep_id),
          attribute_category =
               DECODE(:attribute_category,
                      :ar_text_dummy, attribute_category,
                                      :attribute_category),
          attribute1 =
               DECODE(:attribute1,
                      :ar_text_dummy, attribute1,
                                      :attribute1),
          attribute2 =
               DECODE(:attribute2,
                      :ar_text_dummy, attribute2,
                                      :attribute2),
          attribute3 =
               DECODE(:attribute3,
                      :ar_text_dummy, attribute3,
                                      :attribute3),
          attribute4 =
               DECODE(:attribute4,
                      :ar_text_dummy, attribute4,
                                      :attribute4),
          attribute5 =
               DECODE(:attribute5,
                      :ar_text_dummy, attribute5,
                                      :attribute5),
          attribute6 =
               DECODE(:attribute6,
                      :ar_text_dummy, attribute6,
                                      :attribute6),
          attribute7 =
               DECODE(:attribute7,
                      :ar_text_dummy, attribute7,
                                      :attribute7),
          attribute8 =
               DECODE(:attribute8,
                      :ar_text_dummy, attribute8,
                                      :attribute8),
          attribute9 =
               DECODE(:attribute9,
                      :ar_text_dummy, attribute9,
                                      :attribute9),
          attribute10 =
               DECODE(:attribute10,
                      :ar_text_dummy, attribute10,
                                      :attribute10),
          attribute11 =
               DECODE(:attribute11,
                      :ar_text_dummy, attribute11,
                                      :attribute11),
          attribute12 =
               DECODE(:attribute12,
                      :ar_text_dummy, attribute12,
                                      :attribute12),
          attribute13 =
               DECODE(:attribute13,
                      :ar_text_dummy, attribute13,
                                      :attribute13),
          attribute14 =
               DECODE(:attribute14,
                      :ar_text_dummy, attribute14,
                                      :attribute14),
          attribute15 =
               DECODE(:attribute15,
                      :ar_text_dummy, attribute15,
                                      :attribute15),
/* BEGIN bug 3067675 */
          revenue_salesgroup_id =
               DECODE(:revenue_salesgroup_id,
                      :ar_number_dummy, revenue_salesgroup_id,
                                      :revenue_salesgroup_id),
          non_revenue_salesgroup_id =
               DECODE(:non_revenue_salesgroup_id,
                      :ar_number_dummy, non_revenue_salesgroup_id,
                                      :non_revenue_salesgroup_id),
/* END bug 3067675 */
          last_update_date =
               DECODE(:last_update_date,
                      :ar_date_dummy, sysdate,
                                      :last_update_date),
          last_updated_by =
               DECODE(:last_updated_by,
                      :ar_number_dummy, :pg_user_id,
                                        :last_updated_by),
          creation_date =
               DECODE(:creation_date,
                      :ar_date_dummy, creation_date,
                                      :creation_date),
          created_by =
               DECODE(:created_by,
                      :ar_number_dummy, created_by,
                                        :created_by),
          last_update_login =
               DECODE(:last_update_login,
                      :ar_number_dummy, nvl(:pg_conc_login_id,
                                            :pg_login_id),
                                        :last_update_login),
          program_application_id =
               DECODE(:program_application_id,
                      :ar_number_dummy, program_application_id,
                                        :program_application_id),
          program_id =
               DECODE(:program_id,
                      :ar_number_dummy, program_id,
                                        :program_id),
          program_update_date =
               DECODE(:program_update_date,
                      :ar_date_dummy, program_update_date,
                                      :program_update_date)';

   arp_util.debug('arp_ctls_pkg.construct_srep_update_stmt()-');

EXCEPTION
    WHEN OTHERS THEN
       arp_util.debug('EXCEPTION:  arp_ctls_pkg.construct_srep_update_stmt()');
       RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    generic_update                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure Updates records in ra_cust_trx_line_salesreps  	     |
 |     identified by the where clause that is passed in as a parameter. Only |
 |     those columns in the srep record parameter that do not contain the    |
 |     special dummy values are updated. 				     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |    dbms_sql.open_cursor 						     |
 |    dbms_sql.parse							     |
 |    dbms_sql.execute							     |
 |    dbms_sql.close_cursor						     |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_update_cursor  - identifies the cursor to use 	     |
 |                    p_where_clause   - identifies which rows to update     |
 | 		      p_where1         - value to bind into where clause     |
 |		      p_srep_rec        - contains the new srep values       |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     08-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE generic_update(p_update_cursor IN OUT NOCOPY integer,
			 p_where_clause  IN varchar2,
			 p_where1        IN number,
                         p_srep_rec      IN ra_cust_trx_line_salesreps%rowtype)
          IS

   l_count             number;
   l_update_statement  varchar2(25000);

BEGIN
   arp_util.debug('arp_ctls_pkg.generic_update()+');

  /*--------------------------------------------------------------+
   |  If this update statement has not already been parsed, 	  |
   |  construct the statement and parse it.			  |
   |  Otherwise, use the already parsed statement and rebind its  |
   |  variables.						  |
   +--------------------------------------------------------------*/

   IF (p_update_cursor IS NULL)
   THEN

         p_update_cursor := dbms_sql.open_cursor;

         /*---------------------------------+
          |  Construct the update statement |
          +---------------------------------*/

         arp_ctls_pkg.construct_srep_update_stmt(l_update_statement);

         l_update_statement := l_update_statement || p_where_clause;

         /*-----------------------------------------------+
          |  Parse, bind, execute and close the statement |
          +-----------------------------------------------*/

         dbms_sql.parse(p_update_cursor,
                        l_update_statement,
                        dbms_sql.v7);

   END IF;

   arp_ctls_pkg.bind_srep_variables(p_update_cursor, p_srep_rec);

  /*-----------------------------------------+
   |  Bind the variables in the where clause |
   +-----------------------------------------*/

   dbms_sql.bind_variable(p_update_cursor, ':where_1',
                          p_where1);

   l_count := dbms_sql.execute(p_update_cursor);

   arp_util.debug( to_char(l_count) || ' rows updated');


   /*------------------------------------------------------------+
    |  Raise the NO_DATA_FOUND exception if no rows were updated |
    +------------------------------------------------------------*/

   IF   (l_count = 0)
   THEN RAISE NO_DATA_FOUND;
   END IF;

   dbms_sql.close_cursor(p_update_cursor);

   arp_util.debug('arp_ctls_pkg.generic_update()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ctls_pkg.generic_update()');
        arp_util.debug(l_update_statement);
        arp_util.debug('Error at character: ' ||
                           to_char(dbms_sql.last_error_position));
        IF dbms_sql.is_open( p_update_cursor ) THEN
                dbms_sql.close_cursor( p_update_cursor );
        END IF;

        RAISE;
END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    select_summary                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Selects the total revenue percent and amount for a given transaction   |
 |    or line. This procedure is used by the forms running totals mechanism. |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_customer_trx_id                                      |
 |		      p_customer_trx_line_id                                 |
 |		      p_amount_total                                         |
 |		      p_amount_total_rtot_db                                 |
 |		      p_percent_total                                        |
 |		      p_percent_total_rtot_db                                |
 |              OUT:                                                         |
 |		      None						     |
 |          IN/ OUT:							     |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     25-SEP-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/


PROCEDURE select_summary(p_customer_trx_id       IN      number,
                         p_customer_trx_line_id  IN      number,
                         p_mode                  IN      varchar2,
                         p_amount_total          IN OUT NOCOPY  number,
                         p_amount_total_rtot_db  IN OUT NOCOPY  number,
                         p_percent_total         IN OUT NOCOPY  number,
                         p_percent_total_rtot_db IN OUT NOCOPY  number ) IS

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_ctls_pkg.select_summary()+');
   END IF;

   SELECT NVL( SUM( NVL(revenue_amount_split,  0 ) ), 0),
          NVL( SUM( NVL(revenue_amount_split,  0 ) ), 0),
          NVL( SUM( NVL(revenue_percent_split, 0 ) ), 0),
          NVL( SUM( NVL(revenue_percent_split, 0 ) ), 0)
   INTO   p_amount_total,
          p_amount_total_rtot_db,
          p_percent_total,
          p_percent_total_rtot_db
   FROM   ra_cust_trx_line_salesreps
   WHERE  customer_trx_id = p_customer_trx_id
   AND    NVL( customer_trx_line_id, -10 ) =
          DECODE(p_mode,
                 'LINE', p_customer_trx_line_id,
                 'ALL',  customer_trx_line_id,
                         -10 );

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_ctls_pkg.select_summary()-');
   END IF;


EXCEPTION
 WHEN OTHERS THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION:  arp_ctls_pkg.select_summary()');
   END IF;
   RAISE;

END select_summary;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    display_salescredit						     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Displays the values of all columns except creation_date and 	     |
 |    last_update_date.							     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_cust_trx_line_salesrep_id			     |
 |              OUT:                                                         |
 |		      None						     |
 |          IN/ OUT:							     |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     13-JUL-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE display_salescredit(  p_cust_trx_line_salesrep_id IN
  		     ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type)
                   IS

   l_srep_rec   ra_cust_trx_line_salesreps%rowtype;

BEGIN

   arp_util.debug('arp_ctls_pkg.display_salescredit()+');

   arp_ctls_pkg.fetch_p(l_srep_rec, p_cust_trx_line_salesrep_id);

   arp_ctls_pkg.display_salescredit_rec(l_srep_rec);

   arp_util.debug('arp_ctls_pkg.display_salescredit()-');

EXCEPTION
 WHEN OTHERS THEN
   arp_util.debug('EXCEPTION:  arp_ctls_pkg.display_salescredit()');
   RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    display_salescredit_rec						     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Displays the values of all columns except creation_date and 	     |
 |    last_update_date.							     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_srep_rec					     |
 |              OUT:                                                         |
 |		      None						     |
 |          IN/ OUT:							     |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     17-JUL-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE display_salescredit_rec(  p_srep_rec IN
                                          ra_cust_trx_line_salesreps%rowtype)
                   IS


BEGIN

   arp_util.debug('arp_ctls_pkg.display_salescredit_rec()+');

   arp_util.debug('************** Dump of ra_cust_trx_line_salesreps record '||
                  '**************');

   arp_util.debug('cust_trx_line_salesrep_id: ' ||
                                   p_srep_rec.cust_trx_line_salesrep_id);
   arp_util.debug('customer_trx_id: '      || p_srep_rec.customer_trx_id);
   arp_util.debug('customer_trx_line_id: ' || p_srep_rec.customer_trx_line_id);
   arp_util.debug('salesrep_id: '          || p_srep_rec.salesrep_id);
   arp_util.debug('revenue_amount_split: ' || p_srep_rec.revenue_amount_split);
   arp_util.debug('non_revenue_amount_split: ' ||
                                   p_srep_rec.non_revenue_amount_split);
   arp_util.debug('non_revenue_percent_split: ' ||
                                   p_srep_rec.non_revenue_percent_split);
   arp_util.debug('revenue_percent_split: ' ||
                                   p_srep_rec.revenue_percent_split);
   arp_util.debug('original_line_salesrep_id: ' ||
                                   p_srep_rec.original_line_salesrep_id);
   arp_util.debug('prev_cust_trx_line_salesrep_id: ' ||
                                   p_srep_rec.prev_cust_trx_line_salesrep_id);
   arp_util.debug('attribute_category: ' || p_srep_rec.attribute_category);
   arp_util.debug('attribute1: '         || p_srep_rec.attribute1);
   arp_util.debug('attribute2: '         || p_srep_rec.attribute2);
   arp_util.debug('attribute3: '         || p_srep_rec.attribute3);
   arp_util.debug('attribute4: '         || p_srep_rec.attribute4);
   arp_util.debug('attribute5: '         || p_srep_rec.attribute5);
   arp_util.debug('attribute6: '         || p_srep_rec.attribute6);
   arp_util.debug('attribute7: '         || p_srep_rec.attribute7);
   arp_util.debug('attribute8: '         || p_srep_rec.attribute8);
   arp_util.debug('attribute9: '         || p_srep_rec.attribute9);
   arp_util.debug('attribute10: '        || p_srep_rec.attribute10);
   arp_util.debug('attribute11: '        || p_srep_rec.attribute11);
   arp_util.debug('attribute12: '        || p_srep_rec.attribute12);
   arp_util.debug('attribute13: '        || p_srep_rec.attribute13);
   arp_util.debug('attribute14: '        || p_srep_rec.attribute14);
   arp_util.debug('attribute15: '        || p_srep_rec.attribute15);
/* BEGIN bug 3067675 */
   arp_util.debug('revenue_salesgroup_id: ' || p_srep_rec.revenue_salesgroup_id);
   arp_util.debug('non_revenue_salesgroup_id: ' || p_srep_rec.non_revenue_salesgroup_id);
/* END bug 3067675 */
   arp_util.debug('last_updated_by: '    || p_srep_rec.last_updated_by);
   arp_util.debug('created_by: '         || p_srep_rec.created_by);
   arp_util.debug('last_update_login: '  || p_srep_rec.last_update_login);
   arp_util.debug('program_application_id: ' ||
                                    p_srep_rec.program_application_id);
   arp_util.debug('program_id: ' || p_srep_rec.program_id);

   arp_util.debug('************** End ra_cust_trx_line_salesreps record ' ||
                  '**************');

   arp_util.debug('arp_ctls_pkg.display_salescredit_rec()-');

EXCEPTION
 WHEN OTHERS THEN
   arp_util.debug('EXCEPTION:  arp_ctls_pkg.display_salescredit_rec()');
   RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   display_salescredit_f_ctl_id					     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Displays the values of all columns except creation_date and 	     |
 |    last_update_date.							     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_customer_trx_line_id				     |
 |              OUT:                                                         |
 |		      None						     |
 |          IN/ OUT:							     |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     03-AUG-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/


PROCEDURE display_salescredit_f_ctl_id(  p_customer_trx_line_id IN
                         ra_customer_trx_lines.customer_trx_line_id%type)
                   IS


   CURSOR srep_cursor IS
          SELECT *
          FROM   ra_cust_trx_line_salesreps
          WHERE  customer_trx_line_id = p_customeR_trx_line_id
          ORDER BY salesrep_id,
                   revenue_amount_split,
                   non_revenue_amount_split,
                   cust_trx_line_salesrep_id;


BEGIN

   arp_util.debug('arp_ctls_pkg.display_salescredit_f_ctl_id()+');

   arp_util.debug('=====================================================' ||
                  '==========================');
   arp_util.debug('========= ' ||
                  ' Dump of ra_cust_trx_line_salesreps records for ctlid: '||
		  to_char( p_customer_trx_line_id ) || ' ' ||
                  '=========');

   FOR l_srep_rec IN srep_cursor LOOP
       display_salescredit(l_srep_rec.cust_trx_line_salesrep_id);
   END LOOP;

   arp_util.debug('===== End ' ||
                  ' Dump of ra_cust_trx_line_salesreps records for ctlid: '||
		  to_char( p_customer_trx_line_id ) || ' ' ||
                  '=========');
   arp_util.debug('=====================================================' ||
                  '==========================');

   arp_util.debug('arp_ctls_pkg.display_salescredit_f_ctl_id()-');

EXCEPTION
 WHEN OTHERS THEN
   arp_util.debug('EXCEPTION:  arp_ctls_pkg.display_salescredit_f_ctl_id()');
   RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    merge_srep_recs							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Merges the changed columns in p_new_srep_rec into the same columns     |
 |    p_old_srep_rec and puts the result into p_out_srep_rec. Columns that   |
 |    contain the dummy values are not changed.				     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_old_srep_rec 					     |
 |		      p_new_srep_rec 					     |
 |              OUT:                                                         |
 |                    None						     |
 |          IN/ OUT:							     |
 |		      p_out_srep_rec 					     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     14-JUL-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE merge_srep_recs(
                         p_old_srep_rec IN ra_cust_trx_line_salesreps%rowtype,
                         p_new_srep_rec IN
                                          ra_cust_trx_line_salesreps%rowtype,
                         p_out_srep_rec IN OUT NOCOPY
                                          ra_cust_trx_line_salesreps%rowtype)
                          IS

BEGIN

    arp_util.debug('arp_ctls_pkg.merge_srep_recs()+');


    if     (p_new_srep_rec.customer_trx_id = AR_NUMBER_DUMMY)
    then   p_out_srep_rec.customer_trx_id := p_old_srep_rec.customer_trx_id;
    else   p_out_srep_rec.customer_trx_id := p_new_srep_rec.customer_trx_id;
    end if;

    if     (p_new_srep_rec.customer_trx_line_id = AR_NUMBER_DUMMY)
    then   p_out_srep_rec.customer_trx_line_id :=
                                           p_old_srep_rec.customer_trx_line_id;
    else   p_out_srep_rec.customer_trx_line_id :=
                                           p_new_srep_rec.customer_trx_line_id;
    end if;

    if     (p_new_srep_rec.salesrep_id = AR_NUMBER_DUMMY)
    then   p_out_srep_rec.salesrep_id := p_old_srep_rec.salesrep_id;
    else   p_out_srep_rec.salesrep_id := p_new_srep_rec.salesrep_id;
    end if;

    if     (p_new_srep_rec.revenue_amount_split = AR_NUMBER_DUMMY)
    then   p_out_srep_rec.revenue_amount_split :=
                                           p_old_srep_rec.revenue_amount_split;
    else   p_out_srep_rec.revenue_amount_split :=
                                           p_new_srep_rec.revenue_amount_split;
    end if;

    if     (p_new_srep_rec.non_revenue_amount_split = AR_NUMBER_DUMMY)
    then   p_out_srep_rec.non_revenue_amount_split :=
                                       p_old_srep_rec.non_revenue_amount_split;
    else   p_out_srep_rec.non_revenue_amount_split :=
                                       p_new_srep_rec.non_revenue_amount_split;
    end if;

    if     (p_new_srep_rec.non_revenue_percent_split = AR_NUMBER_DUMMY)
    then   p_out_srep_rec.non_revenue_percent_split :=
                                      p_old_srep_rec.non_revenue_percent_split;
    else   p_out_srep_rec.non_revenue_percent_split :=
                                      p_new_srep_rec.non_revenue_percent_split;
    end if;

    if     (p_new_srep_rec.revenue_percent_split = AR_NUMBER_DUMMY)
    then   p_out_srep_rec.revenue_percent_split :=
                                         p_old_srep_rec.revenue_percent_split;
    else   p_out_srep_rec.revenue_percent_split :=
                                         p_new_srep_rec.revenue_percent_split;
    end if;

    if     (p_new_srep_rec.prev_cust_trx_line_salesrep_id = AR_NUMBER_DUMMY)
    then   p_out_srep_rec.prev_cust_trx_line_salesrep_id :=
                                p_old_srep_rec.prev_cust_trx_line_salesrep_id;
    else   p_out_srep_rec.prev_cust_trx_line_salesrep_id :=
                                p_new_srep_rec.prev_cust_trx_line_salesrep_id;
    end if;

    if     (p_new_srep_rec.attribute_category = AR_TEXT_DUMMY)
    then   p_out_srep_rec.attribute_category :=
                                            p_old_srep_rec.attribute_category;
    else   p_out_srep_rec.attribute_category :=
                                            p_new_srep_rec.attribute_category;
    end if;

    if     (p_new_srep_rec.attribute1 = AR_TEXT_DUMMY)
    then   p_out_srep_rec.attribute1 := p_old_srep_rec.attribute1;
    else   p_out_srep_rec.attribute1 := p_new_srep_rec.attribute1;
    end if;

    if     (p_new_srep_rec.attribute2 = AR_TEXT_DUMMY)
    then   p_out_srep_rec.attribute2 := p_old_srep_rec.attribute2;
    else   p_out_srep_rec.attribute2 := p_new_srep_rec.attribute2;
    end if;

    if     (p_new_srep_rec.attribute3 = AR_TEXT_DUMMY)
    then   p_out_srep_rec.attribute3 := p_old_srep_rec.attribute3;
    else   p_out_srep_rec.attribute3 := p_new_srep_rec.attribute3;
    end if;

    if     (p_new_srep_rec.attribute4 = AR_TEXT_DUMMY)
    then   p_out_srep_rec.attribute4 := p_old_srep_rec.attribute4;
    else   p_out_srep_rec.attribute4 := p_new_srep_rec.attribute4;
    end if;

    if     (p_new_srep_rec.attribute5 = AR_TEXT_DUMMY)
    then   p_out_srep_rec.attribute5 := p_old_srep_rec.attribute5;
    else   p_out_srep_rec.attribute5 := p_new_srep_rec.attribute5;
    end if;

    if     (p_new_srep_rec.attribute6 = AR_TEXT_DUMMY)
    then   p_out_srep_rec.attribute6 := p_old_srep_rec.attribute6;
    else   p_out_srep_rec.attribute6 := p_new_srep_rec.attribute6;
    end if;

    if     (p_new_srep_rec.attribute7 = AR_TEXT_DUMMY)
    then   p_out_srep_rec.attribute7 := p_old_srep_rec.attribute7;
    else   p_out_srep_rec.attribute7 := p_new_srep_rec.attribute7;
    end if;

    if     (p_new_srep_rec.attribute8 = AR_TEXT_DUMMY)
    then   p_out_srep_rec.attribute8 := p_old_srep_rec.attribute8;
    else   p_out_srep_rec.attribute8 := p_new_srep_rec.attribute8;
    end if;

    if     (p_new_srep_rec.attribute9 = AR_TEXT_DUMMY)
    then   p_out_srep_rec.attribute9 := p_old_srep_rec.attribute9;
    else   p_out_srep_rec.attribute9 := p_new_srep_rec.attribute9;
    end if;

    if     (p_new_srep_rec.attribute10 = AR_TEXT_DUMMY)
    then   p_out_srep_rec.attribute10 := p_old_srep_rec.attribute10;
    else   p_out_srep_rec.attribute10 := p_new_srep_rec.attribute10;
    end if;

    if     (p_new_srep_rec.attribute11 = AR_TEXT_DUMMY)
    then   p_out_srep_rec.attribute11 := p_old_srep_rec.attribute11;
    else   p_out_srep_rec.attribute11 := p_new_srep_rec.attribute11;
    end if;

    if     (p_new_srep_rec.attribute12 = AR_TEXT_DUMMY)
    then   p_out_srep_rec.attribute12 := p_old_srep_rec.attribute12;
    else   p_out_srep_rec.attribute12 := p_new_srep_rec.attribute12;
    end if;

    if     (p_new_srep_rec.attribute13 = AR_TEXT_DUMMY)
    then   p_out_srep_rec.attribute13 := p_old_srep_rec.attribute13;
    else   p_out_srep_rec.attribute13 := p_new_srep_rec.attribute13;
    end if;

    if     (p_new_srep_rec.attribute14 = AR_TEXT_DUMMY)
    then   p_out_srep_rec.attribute14 := p_old_srep_rec.attribute14;
    else   p_out_srep_rec.attribute14 := p_new_srep_rec.attribute14;
    end if;

    if     (p_new_srep_rec.attribute15 = AR_TEXT_DUMMY)
    then   p_out_srep_rec.attribute15 := p_old_srep_rec.attribute15;
    else   p_out_srep_rec.attribute15 := p_new_srep_rec.attribute15;
    end if;

/* BEGIN bug 3067675 */

    if     (p_new_srep_rec.revenue_salesgroup_id = AR_NUMBER_DUMMY)
    then   p_out_srep_rec.revenue_salesgroup_id := p_old_srep_rec.revenue_salesgroup_id;
    else   p_out_srep_rec.revenue_salesgroup_id := p_new_srep_rec.revenue_salesgroup_id;
    end if;

    if     (p_new_srep_rec.non_revenue_salesgroup_id = AR_NUMBER_DUMMY)
    then   p_out_srep_rec.non_revenue_salesgroup_id := p_old_srep_rec.non_revenue_salesgroup_id;
    else   p_out_srep_rec.non_revenue_salesgroup_id := p_new_srep_rec.non_revenue_salesgroup_id;
    end if;

/* END bug 3067675 */

    arp_util.debug('arp_ctls_pkg.merge_srep_recs()-');

EXCEPTION
  WHEN OTHERS THEN
      arp_util.debug('EXCEPTION:  merge_srep_recs.backout_salesrep()');
      RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    set_to_dummy							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure initializes all columns in the parameter srep record    |
 |    to the appropriate dummy value for its datatype.			     |
 |    									     |
 |    The dummy values are defined in the following package level constants: |
 |	AR_TEXT_DUMMY 							     |
 |	AR_NUMBER_DUMMY							     |
 |	AR_DATE_DUMMY							     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    None						     |
 |              OUT:                                                         |
 |                    p_srep_rec   - The record to initialize		     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     08-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE set_to_dummy( p_srep_rec OUT NOCOPY ra_cust_trx_line_salesreps%rowtype) IS

BEGIN

    arp_util.debug('arp_ctls_pkg.set_to_dummy()+');

    p_srep_rec.cust_trx_line_salesrep_id 	:= AR_NUMBER_DUMMY;
    p_srep_rec.customer_trx_id 			:= AR_NUMBER_DUMMY;
    p_srep_rec.customer_trx_line_id 		:= AR_NUMBER_DUMMY;
    p_srep_rec.salesrep_id 			:= AR_NUMBER_DUMMY;
    p_srep_rec.revenue_amount_split 		:= AR_NUMBER_DUMMY;
    p_srep_rec.non_revenue_amount_split 	:= AR_NUMBER_DUMMY;
    p_srep_rec.non_revenue_percent_split 	:= AR_NUMBER_DUMMY;
    p_srep_rec.revenue_percent_split 		:= AR_NUMBER_DUMMY;
    p_srep_rec.prev_cust_trx_line_salesrep_id 	:= AR_NUMBER_DUMMY;
    p_srep_rec.attribute_category	 	:= AR_TEXT_DUMMY;
    p_srep_rec.attribute1		 	:= AR_TEXT_DUMMY;
    p_srep_rec.attribute2		 	:= AR_TEXT_DUMMY;
    p_srep_rec.attribute3		 	:= AR_TEXT_DUMMY;
    p_srep_rec.attribute4		 	:= AR_TEXT_DUMMY;
    p_srep_rec.attribute5		 	:= AR_TEXT_DUMMY;
    p_srep_rec.attribute6 			:= AR_TEXT_DUMMY;
    p_srep_rec.attribute7		 	:= AR_TEXT_DUMMY;
    p_srep_rec.attribute8		 	:= AR_TEXT_DUMMY;
    p_srep_rec.attribute9 			:= AR_TEXT_DUMMY;
    p_srep_rec.attribute10		 	:= AR_TEXT_DUMMY;
    p_srep_rec.attribute11 			:= AR_TEXT_DUMMY;
    p_srep_rec.attribute12 			:= AR_TEXT_DUMMY;
    p_srep_rec.attribute13 			:= AR_TEXT_DUMMY;
    p_srep_rec.attribute14		 	:= AR_TEXT_DUMMY;
    p_srep_rec.attribute15 			:= AR_TEXT_DUMMY;
/* BEGIN bug 3067675 */
    p_srep_rec.revenue_salesgroup_id		:= AR_NUMBER_DUMMY;
    p_srep_rec.non_revenue_salesgroup_id	:= AR_NUMBER_DUMMY;
/* END bug 3067675 */
    p_srep_rec.last_update_date 		:= AR_DATE_DUMMY;
    p_srep_rec.last_updated_by 			:= AR_NUMBER_DUMMY;
    p_srep_rec.creation_date 			:= AR_DATE_DUMMY;
    p_srep_rec.created_by		 	:= AR_NUMBER_DUMMY;
    p_srep_rec.last_update_login 		:= AR_NUMBER_DUMMY;
    p_srep_rec.program_application_id 		:= AR_NUMBER_DUMMY;
    p_srep_rec.program_id		 	:= AR_NUMBER_DUMMY;
    p_srep_rec.program_update_date 		:= AR_DATE_DUMMY;

    arp_util.debug('arp_ctls_pkg.set_to_dummy()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ctls_pkg.set_to_dummy()');
        RAISE;

END;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_number_dummy							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure returns the value of the AR_NUMBER DUMMY constant.      |
 |    									     |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    None						     |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : value of AR_NUMBER_DUMMY                                     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     18-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

FUNCTION get_number_dummy(p_null IN NUMBER DEFAULT null) RETURN number IS

BEGIN

    arp_util.debug('arp_ctls_pkg.get_number_dummy()+');

    arp_util.debug('arp_ctls_pkg.get_number_dummy()-');

    return(AR_NUMBER_DUMMY);

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ctls_pkg.get_number_dummy()');
        RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ra_cust_trx_line_salesreps row identified by  |
 |    p_cust_trx_line_salesrep_id parameter.				     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_cust_trx_line_salesrep_id - identifies the row to lock |
 |              OUT:                                                         |
 |                  None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     08-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_p( p_cust_trx_line_salesrep_id
                  IN ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type
                )
          IS

    l_cust_trx_line_salesrep_id
                    ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type;

BEGIN
    arp_util.debug('arp_ctls_pkg.lock_p()+');


    SELECT        cust_trx_line_salesrep_id
    INTO          l_cust_trx_line_salesrep_id
    FROM          ra_cust_trx_line_salesreps
    WHERE         cust_trx_line_salesrep_id = p_cust_trx_line_salesrep_id
    FOR UPDATE OF cust_trx_line_salesrep_id NOWAIT;

    arp_util.debug('arp_ctls_pkg.lock_p()-');

    EXCEPTION
        WHEN  OTHERS THEN
	    arp_util.debug( 'EXCEPTION: arp_ctls_pkg.lock_p' );
            RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_f_ct_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ra_cust_trx_line_salesreps rows identified by |
 |    p_customer_trx_id parameter.					     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_customer_trx_id 	- identifies the rows to lock	     |
 |              OUT:                                                         |
 |                  None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     08-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_f_ct_id( p_customer_trx_id
                           IN ra_customer_trx.customer_trx_id%type )
          IS

    CURSOR LOCK_C IS
    SELECT        cust_trx_line_salesrep_id
    FROM          ra_cust_trx_line_salesreps
    WHERE         customer_trx_id = p_customer_trx_id
    FOR UPDATE OF cust_trx_line_salesrep_id NOWAIT;


BEGIN
    arp_util.debug('arp_ctls_pkg.lock_f_ct_id()+');

    OPEN lock_c;
    CLOSE lock_c;

    arp_util.debug('arp_ctls_pkg.lock_f_ct_id()-');

    EXCEPTION
        WHEN  OTHERS THEN
	    arp_util.debug( 'EXCEPTION: arp_ctls_pkg.lock_f_ct_id' );
            RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_f_ctl_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ra_cust_trx_line_salesreps rows identified by |
 |    p_customer_trx_line_id parameter.					     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_customer_trx_line_id - identifies the rows to lock     |
 |              OUT:                                                         |
 |                  None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     08-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_f_ctl_id( p_customer_trx_line_id
                           IN ra_customer_trx_lines.customer_trx_line_id%type)
          IS

    CURSOR lock_c IS
    SELECT        cust_trx_line_salesrep_id
    FROM          ra_cust_trx_line_salesreps
    WHERE         customer_trx_line_id = p_customer_trx_line_id
    FOR UPDATE OF cust_trx_line_salesrep_id NOWAIT;

BEGIN
    arp_util.debug('arp_ctls_pkg.lock_f_ctl_id()+');

    OPEN lock_c;
    CLOSE lock_c;

    arp_util.debug('arp_ctls_pkg.lock_f_ctl_id()-');

    EXCEPTION
        WHEN  OTHERS THEN
	    arp_util.debug( 'EXCEPTION: arp_ctls_pkg.lock_f_ctl_id' );
            RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_fetch_p							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ra_cust_trx_line_salesreps row identified     |
 |    by the p_cust_trx_line_salesrep_id parameter and populates the         |
 |    p_srep_rec parameter with the row that was locked.		     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_cust_trx_line_salesrep_id - identifies the row to lock |
 |              OUT:                                                         |
 |                  p_srep_rec			- contains the locked row    |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     08-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_fetch_p( p_srep_rec IN OUT NOCOPY ra_cust_trx_line_salesreps%rowtype,
                        p_cust_trx_line_salesrep_id IN
		ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type) IS

BEGIN
    arp_util.debug('arp_ctls_pkg.lock_fetch_p()+');

    SELECT        *
    INTO          p_srep_rec
    FROM          ra_cust_trx_line_salesreps
    WHERE         cust_trx_line_salesrep_id = p_cust_trx_line_salesrep_id
    FOR UPDATE OF cust_trx_line_salesrep_id NOWAIT;

    arp_util.debug('arp_ctls_pkg.lock_fetch_p()-');

    EXCEPTION
        WHEN  OTHERS THEN
            arp_util.debug( 'EXCEPTION: arp_ctls_pkg.lock_fetch_p' );
            RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_compare_p							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ra_cust_trx_line_salesreps row identified     |
 |    by the p_cust_trx_line_salesrep_id parameter only if no columns in     |
 |    that row have changed from when they were first selected in the form.  |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                 p_cust_trx_line_salesrep_id - identifies the row to lock  |
 | 		   p_srep_rec    	- srep record for comparison	     |
 |                 p_ignore_who_flag    - directs system to ignore who cols  |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     08-JUN-95  Charlie Tomberg     Created                                |
 |     29-JUN-95  Charlie Tomberg     Modified to use select for update      |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_compare_p( p_srep_rec IN ra_cust_trx_line_salesreps%rowtype,
                          p_cust_trx_line_salesrep_id IN
                  ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type,
                          p_ignore_who_flag BOOLEAN DEFAULT FALSE) IS

    l_new_srep_rec     ra_cust_trx_line_salesreps%rowtype;
    l_temp_srep_rec    ra_cust_trx_line_salesreps%rowtype;
    l_ignore_who_flag  varchar2(2);

BEGIN
    arp_util.debug('arp_ctls_pkg.lock_compare_p()+');

    IF     (p_ignore_who_flag = TRUE)
    THEN   l_ignore_who_flag := 'Y';
    ELSE   l_ignore_who_flag := 'N';
    END IF;

    SELECT   *
    INTO     l_new_srep_rec
    FROM     ra_cust_trx_line_salesreps tls
    WHERE    tls.cust_trx_line_salesrep_id = p_cust_trx_line_salesrep_id
    AND
       (
           NVL(tls.cust_trx_line_salesrep_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_srep_rec.cust_trx_line_salesrep_id,
                        AR_NUMBER_DUMMY, tls.cust_trx_line_salesrep_id,
                                   NULL, AR_NUMBER_DUMMY,
                                         p_srep_rec.cust_trx_line_salesrep_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(tls.customer_trx_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_srep_rec.customer_trx_id,
                        AR_NUMBER_DUMMY, tls.customer_trx_id,
                                   NULL, AR_NUMBER_DUMMY,
                                         p_srep_rec.customer_trx_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(tls.customer_trx_line_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_srep_rec.customer_trx_line_id,
                        AR_NUMBER_DUMMY, tls.customer_trx_line_id,
                                   NULL, AR_NUMBER_DUMMY,
                                         p_srep_rec.customer_trx_line_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(tls.salesrep_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_srep_rec.salesrep_id,
                        AR_NUMBER_DUMMY, tls.salesrep_id,
                                   NULL, AR_NUMBER_DUMMY,
                                         p_srep_rec.salesrep_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(tls.revenue_amount_split, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_srep_rec.revenue_amount_split,
                        AR_NUMBER_DUMMY, tls.revenue_amount_split,
                                   NULL, AR_NUMBER_DUMMY,
                                         p_srep_rec.revenue_amount_split),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(tls.non_revenue_amount_split, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_srep_rec.non_revenue_amount_split,
                        AR_NUMBER_DUMMY, tls.non_revenue_amount_split,
                                   NULL, AR_NUMBER_DUMMY,
                                         p_srep_rec.non_revenue_amount_split),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(tls.non_revenue_percent_split, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_srep_rec.non_revenue_percent_split,
                        AR_NUMBER_DUMMY, tls.non_revenue_percent_split,
                                   NULL, AR_NUMBER_DUMMY,
                                         p_srep_rec.non_revenue_percent_split),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(tls.revenue_percent_split, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_srep_rec.revenue_percent_split,
                        AR_NUMBER_DUMMY, tls.revenue_percent_split,
                                   NULL, AR_NUMBER_DUMMY,
                                         p_srep_rec.revenue_percent_split),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(tls.prev_cust_trx_line_salesrep_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_srep_rec.prev_cust_trx_line_salesrep_id,
                        AR_NUMBER_DUMMY, tls.prev_cust_trx_line_salesrep_id,
                                   NULL, AR_NUMBER_DUMMY,
                                    p_srep_rec.prev_cust_trx_line_salesrep_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(tls.attribute_category, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_srep_rec.attribute_category,
                        AR_TEXT_DUMMY, tls.attribute_category,
                                   NULL, AR_TEXT_DUMMY,
                                         p_srep_rec.attribute_category),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(tls.attribute1, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_srep_rec.attribute1,
                        AR_TEXT_DUMMY, tls.attribute1,
                                   NULL, AR_TEXT_DUMMY,
                                         p_srep_rec.attribute1),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(tls.attribute2, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_srep_rec.attribute2,
                        AR_TEXT_DUMMY, tls.attribute2,
                                   NULL, AR_TEXT_DUMMY,
                                         p_srep_rec.attribute2),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(tls.attribute3, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_srep_rec.attribute3,
                        AR_TEXT_DUMMY, tls.attribute3,
                                   NULL, AR_TEXT_DUMMY,
                                         p_srep_rec.attribute3),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(tls.attribute4, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_srep_rec.attribute4,
                        AR_TEXT_DUMMY, tls.attribute4,
                                   NULL, AR_TEXT_DUMMY,
                                         p_srep_rec.attribute4),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(tls.attribute5, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_srep_rec.attribute5,
                        AR_TEXT_DUMMY, tls.attribute5,
                                   NULL, AR_TEXT_DUMMY,
                                         p_srep_rec.attribute5),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(tls.attribute6, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_srep_rec.attribute6,
                        AR_TEXT_DUMMY, tls.attribute6,
                                   NULL, AR_TEXT_DUMMY,
                                         p_srep_rec.attribute6),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(tls.attribute7, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_srep_rec.attribute7,
                        AR_TEXT_DUMMY, tls.attribute7,
                                   NULL, AR_TEXT_DUMMY,
                                         p_srep_rec.attribute7),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(tls.attribute8, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_srep_rec.attribute8,
                        AR_TEXT_DUMMY, tls.attribute8,
                                   NULL, AR_TEXT_DUMMY,
                                         p_srep_rec.attribute8),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(tls.attribute9, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_srep_rec.attribute9,
                        AR_TEXT_DUMMY, tls.attribute9,
                                   NULL, AR_TEXT_DUMMY,
                                         p_srep_rec.attribute9),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(tls.attribute10, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_srep_rec.attribute10,
                        AR_TEXT_DUMMY, tls.attribute10,
                                   NULL, AR_TEXT_DUMMY,
                                         p_srep_rec.attribute10),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(tls.attribute11, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_srep_rec.attribute11,
                        AR_TEXT_DUMMY, tls.attribute11,
                                   NULL, AR_TEXT_DUMMY,
                                         p_srep_rec.attribute11),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(tls.attribute12, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_srep_rec.attribute12,
                        AR_TEXT_DUMMY, tls.attribute12,
                                   NULL, AR_TEXT_DUMMY,
                                         p_srep_rec.attribute12),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(tls.attribute13, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_srep_rec.attribute13,
                        AR_TEXT_DUMMY, tls.attribute13,
                                   NULL, AR_TEXT_DUMMY,
                                         p_srep_rec.attribute13),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(tls.attribute14, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_srep_rec.attribute14,
                        AR_TEXT_DUMMY, tls.attribute14,
                                   NULL, AR_TEXT_DUMMY,
                                         p_srep_rec.attribute14),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(tls.attribute15, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_srep_rec.attribute15,
                        AR_TEXT_DUMMY, tls.attribute15,
                                   NULL, AR_TEXT_DUMMY,
                                         p_srep_rec.attribute15),
                 AR_TEXT_DUMMY
              )
         AND
/* BEGIN bug 3067675 */
           NVL(tls.revenue_salesgroup_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_srep_rec.revenue_salesgroup_id,
                        AR_NUMBER_DUMMY, tls.revenue_salesgroup_id,
                                   NULL, AR_NUMBER_DUMMY,
                                         p_srep_rec.revenue_salesgroup_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(tls.non_revenue_salesgroup_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_srep_rec.non_revenue_salesgroup_id,
                        AR_NUMBER_DUMMY, tls.non_revenue_salesgroup_id,
                                   NULL, AR_NUMBER_DUMMY,
                                         p_srep_rec.non_revenue_salesgroup_id),
                 AR_NUMBER_DUMMY
              )
         AND
/* END bug 3067675 */
           NVL(tls.last_update_date, AR_DATE_DUMMY) =
           NVL(
                 DECODE(l_ignore_who_flag,
                        'Y',  NVL(tls.last_update_date, AR_DATE_DUMMY),
                              DECODE(
                                      p_srep_rec.last_update_date,
                                      AR_DATE_DUMMY, tls.last_update_date,
                                                  p_srep_rec.last_update_date
                                    )
                       ),
                 AR_DATE_DUMMY
              )
         AND
           NVL(tls.last_updated_by, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(l_ignore_who_flag,
                        'Y',   NVL(tls.last_updated_by, AR_NUMBER_DUMMY),
                               DECODE(
                                      p_srep_rec.last_updated_by,
                                      AR_NUMBER_DUMMY, tls.last_updated_by,
                                                  p_srep_rec.last_updated_by
                                     )
                        ),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(tls.creation_date, AR_DATE_DUMMY) =
           NVL(
                 DECODE(l_ignore_who_flag,
                        'Y',  NVL(tls.creation_date, AR_DATE_DUMMY),
                              DECODE(
                                     p_srep_rec.creation_date,
                                     AR_DATE_DUMMY, tls.creation_date,
                                                 p_srep_rec.creation_date
                                    )
                       ),
                 AR_DATE_DUMMY
              )
         AND
           NVL(tls.created_by, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(l_ignore_who_flag,
                        'Y',  NVL(tls.created_by, AR_NUMBER_DUMMY),
                              DECODE(
                                       p_srep_rec.created_by,
                                       AR_NUMBER_DUMMY, tls.created_by,
                                                      p_srep_rec.created_by
                                     )
                        ),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(tls.last_update_login, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(l_ignore_who_flag,
                        'Y',  NVL(tls.last_update_login, AR_NUMBER_DUMMY),
                              DECODE(
                                       p_srep_rec.last_update_login,
                                       AR_NUMBER_DUMMY, tls.last_update_login,
                                                 p_srep_rec.last_update_login
                                    )
                        ),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(tls.program_application_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(l_ignore_who_flag,
                        'Y',  NVL(tls.program_application_id, AR_NUMBER_DUMMY),
                              DECODE(
                                  p_srep_rec.program_application_id,
                                  AR_NUMBER_DUMMY, tls.program_application_id,
                                            p_srep_rec.program_application_id
                                     )
                        ),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(tls.program_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(l_ignore_who_flag,
                        'Y',  NVL(tls.program_id, AR_NUMBER_DUMMY),
                              DECODE(
                                      p_srep_rec.program_id,
                                      AR_NUMBER_DUMMY, tls.program_id,
                                                       p_srep_rec.program_id
                                    )
                        ),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(tls.program_update_date, AR_DATE_DUMMY) =
           NVL(
                 DECODE(l_ignore_who_flag,
                        'Y',  NVL(tls.program_update_date, AR_DATE_DUMMY),
                              DECODE(
                                       p_srep_rec.program_update_date,
                                       AR_DATE_DUMMY, tls.program_update_date,
                                                p_srep_rec.program_update_date
                                    )
                       ),
                 AR_DATE_DUMMY
              )
       )
    FOR UPDATE OF cust_trx_line_salesrep_id NOWAIT;


    arp_util.debug('arp_ctls_pkg.lock_compare_p()-');

    EXCEPTION
        WHEN NO_DATA_FOUND THEN

              arp_util.debug('');
              arp_util.debug('p_cust_trx_line_salesrep_id  = ' ||
                              p_cust_trx_line_salesrep_id );
              arp_util.debug('-------- new salescredit record --------');
              display_salescredit_rec( p_srep_rec );

              arp_util.debug('');

              arp_util.debug('-------- old salescredit record --------');

              fetch_p( l_temp_srep_rec,
                       p_cust_trx_line_salesrep_id );

              display_salescredit_rec( l_temp_srep_rec );

              FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
              APP_EXCEPTION.Raise_Exception;

        WHEN  OTHERS THEN
              arp_util.debug( 'EXCEPTION: arp_ctls_pkg.lock_compare_p' );
              arp_util.debug( SQLERRM );

              arp_util.debug('----- parameters for lock_compare_p -----');

              arp_util.debug('p_cust_trx_line_salesrep_id  = ' ||
                             p_cust_trx_line_salesrep_id );
              arp_util.debug('p_ignore_who_flag            =' ||
                      arp_trx_util.boolean_to_varchar2(p_ignore_who_flag));

              arp_util.debug('');
              arp_util.debug('-------- new salescredit record --------');
              display_salescredit_rec( p_srep_rec );

              arp_util.debug('');

              arp_util.debug('-------- old salescredit record --------');

              fetch_p( l_temp_srep_rec,
                       p_cust_trx_line_salesrep_id );

              display_salescredit_rec( l_temp_srep_rec );

              RAISE;

      END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    fetch_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure fetches a single row from ra_cust_trx_line_salesreps    |
 |    into a variable specified as a parameter based on the table's primary  |
 |    key, cust_trx_line_salesrep_id					     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              p_cust_trx_line_salesrep_id - identifies the record to fetch |
 |              OUT:                                                         |
 |                    p_srep_rec  - contains the fetched record	     	     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     08-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE fetch_p( p_srep_rec         OUT NOCOPY ra_cust_trx_line_salesreps%rowtype,
                   p_cust_trx_line_salesrep_id IN
                     ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type)
          IS

BEGIN
    arp_util.debug('arp_ctls_pkg.fetch_p()+');

    SELECT *
    INTO   p_srep_rec
    FROM   ra_cust_trx_line_salesreps
    WHERE  cust_trx_line_salesrep_id = p_cust_trx_line_salesrep_id;

    arp_util.debug('arp_ctls_pkg.fetch_p()-');

    EXCEPTION
        WHEN  OTHERS THEN
            arp_util.debug( 'EXCEPTION: arp_ctls_pkg.fetch_p' );
            RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure deletes the ra_cust_trx_line_salesreps row identified   |
 |    by the p_cust_trx_line_salesrep_id parameter.			     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              p_cust_trx_line_salesrep_id  - identifies the rows to delete |
 |              p_customer_trx_line_id                                       |
 |              OUT:                                                         |
 |              None						             |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     07-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

procedure delete_p( p_cust_trx_line_salesrep_id
                IN ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type,
                    p_customer_trx_line_id
                IN ra_customer_trx_lines.customer_trx_line_id%type  )
       IS

   rows NUMBER;

BEGIN


   arp_util.debug('arp_ctls_pkg.delete_p()+');

   wf_event.raise(
        p_event_name    => 'oracle.apps.ar.transaction.SalesCredit.delete',
        p_event_key     => to_char(p_cust_trx_line_salesrep_id) || '_' ||
                to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));

   DELETE FROM ra_cust_trx_line_salesreps
   WHERE       cust_trx_line_salesrep_id = p_cust_trx_line_salesrep_id;

   rows := SQL%ROWCOUNT;

   arp_util.debug( rows || ' records deleted');

   IF ( rows = 0 )
   THEN   arp_util.debug('EXCEPTION:  arp_ctls_pkg.delete_p()');
          RAISE NO_DATA_FOUND;
   END IF;

 /*---------------------------------------------------------------------+
  |  Erase all foreign key references if this is not a Default record.  |
  |  Default records will not have any other records pointing to them.  |
  +---------------------------------------------------------------------*/

   IF ( p_customer_trx_line_id IS NOT NULL )
   THEN
         erase_foreign_key_references( p_cust_trx_line_salesrep_id,
                                       NULL,
                                       NULL );
   END IF;

   arp_util.debug('arp_ctls_pkg.delete_p()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ctls_pkg.delete_p()');

	RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_f_ct_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure deletes the ra_cust_trx_line_salesreps rows identified  |
 |    by the p_customer_trx_id parameter.				     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |           	      p_customer_trx_id  - identifies the rows to delete     |
 |                    p_delete_default_recs_flag                             |
 |              OUT:                                                         |
 |                    None					             |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     07-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

procedure delete_f_ct_id( p_customer_trx_id
                         IN ra_customer_trx.customer_trx_id%type,
                         p_delete_default_recs_flag IN boolean DEFAULT TRUE)
       IS

   CURSOR srep_trx_cursor IS
        select cust_trx_line_salesrep_id from ra_cust_trx_line_salesreps
        where customer_trx_id = p_customer_trx_id;

   CURSOR srep_trx_line_cursor IS
        select cust_trx_line_salesrep_id from ra_cust_trx_line_salesreps
        where customer_trx_id = p_customer_trx_id
        and customer_trx_line_id IS NOT NULL;

BEGIN


   arp_util.debug('arp_ctls_pkg.delete_f_ct_id()+');

   IF ( p_delete_default_recs_flag = TRUE )
   THEN
          FOR l_srep_rec IN srep_trx_cursor LOOP
                wf_event.raise(
                  p_event_name => 'oracle.apps.ar.transaction.SalesCredit.delete',
                  p_event_key  => to_char(l_srep_rec.cust_trx_line_salesrep_id) || '_' ||
                to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
          END LOOP;

          DELETE FROM ra_cust_trx_line_salesreps
          WHERE       customer_trx_id = p_customer_trx_id;

   ELSE

          FOR l_srep_rec IN srep_trx_line_cursor LOOP
                wf_event.raise(
                  p_event_name => 'oracle.apps.ar.transaction.SalesCredit.delete',
                  p_event_key  => to_char(l_srep_rec.cust_trx_line_salesrep_id) || '_' ||
                to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
          END LOOP;

          DELETE FROM ra_cust_trx_line_salesreps
          WHERE       customer_trx_id       = p_customer_trx_id
          AND         customer_trx_line_id  IS NOT NULL;

   END IF;

   erase_foreign_key_references( NULL,
                                 p_customer_trx_id,
                                 NULL );

   arp_util.debug('arp_ctls_pkg.delete_f_ct_id()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ctls_pkg.delete_f_ct_id()');

	RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_f_ctl_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure deletes the ra_cust_trx_line_salesreps rows identified  |
 |    by the p_customer_trx_line_id parameter.				     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |        	    p_customer_trx_line_id  - identifies the rows to delete  |
 |              OUT:                                                         |
 |                  None					             |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     07-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

procedure delete_f_ctl_id( p_customer_trx_line_id
                         IN ra_customer_trx_lines.customer_trx_line_id%type)
       IS

   CURSOR srep_cursor IS
        select cust_trx_line_salesrep_id from ra_cust_trx_line_salesreps
        where customer_trx_line_id = p_customer_trx_line_id;

BEGIN


   arp_util.debug('arp_ctls_pkg.delete_f_ctl_id()+');

   FOR l_srep_rec IN srep_cursor LOOP
        wf_event.raise(
          p_event_name => 'transaction.SalesCredit.apps.ar.salescredits.delete',
          p_event_key  => to_char(l_srep_rec.cust_trx_line_salesrep_id) || '_' ||
                to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
   END LOOP;

   DELETE FROM ra_cust_trx_line_salesreps
   WHERE       customer_trx_line_id = p_customer_trx_line_id;

   erase_foreign_key_references( NULL,
                                 NULL,
                                 p_customer_trx_line_id );

   arp_util.debug('arp_ctls_pkg.delete_f_ctl_id()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ctls_pkg.delete_f_ctl_id()');

	RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure updates the ra_cust_trx_line_salesreps row identified   |
 |    by the p_cust_trx_line_salesrep_id parameter.			     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |               p_cust_trx_line_salesrep_id - identifies the row to update  |
 |               p_srep_rec                 - contains the new column values |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |     set_to_dummy must be called before the values in p_srep_rec are       |
 |     changed and this function is called.				     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     08-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE update_p( p_srep_rec IN ra_cust_trx_line_salesreps%rowtype,
                    p_cust_trx_line_salesrep_id  IN
                     ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type)
          IS


BEGIN

   arp_util.debug('arp_ctls_pkg.update_p()+  ' ||
                      to_char(sysdate, 'HH:MI:SS'));

   wf_event.raise(
        p_event_name  => 'oracle.apps.ar.transaction.SalesCredit.update',
        p_event_key   => to_char(p_cust_trx_line_salesrep_id) || '_' ||
                to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));

   arp_ctls_pkg.generic_update(  pg_cursor1,
			       ' WHERE cust_trx_line_salesrep_id = :where_1',
                               p_cust_trx_line_salesrep_id,
                               p_srep_rec);

   arp_util.debug('arp_ctls_pkg.update_p()-  ' ||
                      to_char(sysdate, 'HH:MI:SS'));


EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ctls_pkg.update_p()');
        RAISE;
END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_f_ct_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure updates the ra_cust_trx_line_salesreps rows identified  |
 |    by the p_customer_trx_id parameter.				     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |               p_customer_trx_id	    - identifies the rows to update  |
 |               p_srep_rec                 - contains the new column values |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |     set_to_dummy must be called before the values in p_srep_rec are       |
 |     changed and this function is called.				     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     08-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE update_f_ct_id( p_srep_rec IN ra_cust_trx_line_salesreps%rowtype,
                    p_customer_trx_id  IN ra_customer_trx.customer_trx_id%type)
          IS

   CURSOR srep_trx_cursor IS
        select cust_trx_line_salesrep_id from ra_cust_trx_line_salesreps
        where customer_trx_id = p_customer_trx_id;

BEGIN

   arp_util.debug('arp_ctls_pkg.update_f_ct_id()+  ' ||
                      to_char(sysdate, 'HH:MI:SS'));

   FOR l_srep_rec IN srep_trx_cursor LOOP
      wf_event.raise(
          p_event_name  => 'oracle.apps.ar.transaction.SalesCredit.update',
          p_event_key   => to_char(l_srep_rec.cust_trx_line_salesrep_id) || '_' ||
                to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
   END LOOP;

   arp_ctls_pkg.generic_update(  pg_cursor2,
			       ' WHERE customer_trx_id = :where_1',
                               p_customer_trx_id,
                               p_srep_rec);

   arp_util.debug('arp_ctls_pkg.update_f_ct_id()-  ' ||
                      to_char(sysdate, 'HH:MI:SS'));


EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ctls_pkg.update_f_ct_id()');
        RAISE;
END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_f_ctl_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure updates the ra_cust_trx_line_salesreps rows identified  |
 |    by the p_customer_trx_line_id parameter.				     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |               p_customer_trx_line_id	    - identifies the rows to update  |
 |               p_srep_rec                 - contains the new column values |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |     set_to_dummy must be called before the values in p_srep_rec are       |
 |     changed and this function is called.				     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     08-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE update_f_ctl_id( p_srep_rec IN ra_cust_trx_line_salesreps%rowtype,
                           p_customer_trx_line_id  IN
                               ra_customer_trx_lines.customer_trx_line_id%type)
          IS

   CURSOR srep_cursor IS
        select cust_trx_line_salesrep_id from ra_cust_trx_line_salesreps
        where customer_trx_line_id = p_customer_trx_line_id;

BEGIN

   arp_util.debug('arp_ctls_pkg.update_f_ctl_id()+  ' ||
                      to_char(sysdate, 'HH:MI:SS'));

   FOR l_srep_rec IN srep_cursor LOOP
     wf_event.raise(
       p_event_name  => 'transaction.SalesCredit.apps.ar.salescredits.update',
       p_event_key   => to_char(l_srep_rec.cust_trx_line_salesrep_id) || '_' ||
                to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
   END LOOP;

   arp_ctls_pkg.generic_update(  pg_cursor3,
			       ' WHERE customer_trx_line_id = :where_1',
                               p_customer_trx_line_id,
                               p_srep_rec);

   arp_util.debug('arp_ctls_pkg.update_f_ctl_id()-  ' ||
                      to_char(sysdate, 'HH:MI:SS'));


EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ctls_pkg.update_f_ctl_id()');
        RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_f_psr_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure updates the ra_cust_trx_line_salesreps rows identified  |
 |    by the prev_cust_trx_line_salesrep_id parameter.			     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |               p_prev_cust_trx_line_salesrep_id  - identifies the rows     |
 |                                                   to update               |
 |               p_srep_rec                 - contains the new column values |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |     set_to_dummy must be called before the values in p_srep_rec are       |
 |     changed and this function is called.				     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     08-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE update_f_psr_id( p_srep_rec IN ra_cust_trx_line_salesreps%rowtype,
                           p_prev_cust_trx_line_srep_id
                ra_cust_trx_line_salesreps.prev_cust_trx_line_salesrep_id%type)
          IS

   CURSOR srep_cursor IS
        select cust_trx_line_salesrep_id from ra_cust_trx_line_salesreps
        where prev_cust_trx_line_salesrep_id = p_prev_cust_trx_line_srep_id;

BEGIN

   arp_util.debug('arp_ctls_pkg.update_f_psr_id()+  ' ||
                      to_char(sysdate, 'HH:MI:SS'));

   FOR l_srep_rec IN srep_cursor LOOP
     wf_event.raise(
       p_event_name  => 'transaction.SalesCredit.apps.ar.salescredits.update',
       p_event_key   => to_char(l_srep_rec.cust_trx_line_salesrep_id) || '_' ||
                to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
   END LOOP;

   arp_ctls_pkg.generic_update(
                          pg_cursor3,
 		          ' WHERE  prev_cust_trx_line_salesrep_id = :where_1',
                          p_prev_cust_trx_line_srep_id,
                          p_srep_rec);

   arp_util.debug('arp_ctls_pkg.update_f_psr_id()-  ' ||
                      to_char(sysdate, 'HH:MI:SS'));


EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ctls_pkg.update_f_psr_id()');
        RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_amounts_f_ctl_id						     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure updates the ra_cust_trx_line_salesreps rows identified  |
 |    by the p_customer_trx_id parameter.				     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |               p_customer_trx_id	    - identifies the rows to update  |
 |               p_srep_rec                 - contains the new column values |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |     set_to_dummy must be called before the values in p_srep_rec are       |
 |     changed and this function is called.				     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     08-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE update_amounts_f_ctl_id(
                             p_customer_trx_line_id  IN
                               ra_customer_trx_lines.customer_trx_line_id%type,
                             p_line_amount           IN
                               ra_customer_trx_lines.extended_amount%type,
                             p_foreign_currency_code IN
                                            fnd_currencies.currency_code%type)
          IS

   CURSOR srep_cursor IS
        select cust_trx_line_salesrep_id from ra_cust_trx_line_salesreps
        where customer_trx_line_id = p_customer_trx_line_id;

BEGIN

   arp_util.debug('arp_ctls_pkg.update_amounts_f_ctl_id()+  ' ||
                      to_char(sysdate, 'HH:MI:SS'));

   arp_util.debug('p_line_amount           = ' || p_line_amount );
   arp_util.debug('p_customer_trx_line_id  = ' || p_customer_trx_line_id );
   arp_util.debug('p_foreign_currency_code = ' || p_foreign_currency_code );

   FOR l_srep_rec IN srep_cursor LOOP
     wf_event.raise(
       p_event_name  => 'transaction.SalesCredit.apps.ar.salescredits.update',
       p_event_key   => to_char(l_srep_rec.cust_trx_line_salesrep_id) || '_' ||
                to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
   END LOOP;

   update ra_cust_trx_line_salesreps
      set last_updated_by   = pg_user_id,
          last_update_date  = sysdate,
          last_update_login = pg_login_id,
          revenue_amount_split  = arpcurr.CurrRound(
                                             p_line_amount *
                                               ( revenue_percent_split / 100 ),
                                             p_foreign_currency_code
                                           ),
          non_revenue_amount_split  = arpcurr.CurrRound(
                                         p_line_amount *
                                           ( non_revenue_percent_split / 100 ),
                                         p_foreign_currency_code
                                       )
    where customer_trx_line_id   = p_customer_trx_line_id;

   arp_util.debug(SQL%ROWCOUNT || ' rows updated');

   arp_util.debug('arp_ctls_pkg.update_amounts_f_ctl_id()-  ' ||
                      to_char(sysdate, 'HH:MI:SS'));


EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ctls_pkg.update_amounts_f_ctl_id()');
        RAISE;
END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure inserts a row into ra_cust_trx_line_salesreps that      |
 |    contains the column values specified in the p_srep_rec parameter.      |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_srep_rec            - contains the new column values |
 |              OUT:                                                         |
 |                    p_cust_trx_line_salesrep_id - unique ID of the new row |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     06-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE insert_p(
             p_srep_rec          IN ra_cust_trx_line_salesreps%rowtype,
             p_cust_trx_line_salesrep_id
                  OUT NOCOPY ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type

                  ) IS


    l_cust_trx_line_salesrep_id
                    ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type;


BEGIN

    arp_util.debug('arp_ctls_pkg.insert_p()+');

    p_cust_trx_line_salesrep_id := '';

    /*---------------------------*
     | Get the unique identifier |
     *---------------------------*/

        SELECT RA_CUST_TRX_LINE_SALESREPS_S.NEXTVAL
        INTO   l_cust_trx_line_salesrep_id
        FROM   DUAL;


    /*-------------------*
     | Insert the record |
     *-------------------*/

      INSERT INTO ra_cust_trx_line_salesreps
       (
         cust_trx_line_salesrep_id,
         customer_trx_id,
         customer_trx_line_id,
         salesrep_id,
         revenue_amount_split,
         non_revenue_amount_split,
         non_revenue_percent_split,
         revenue_percent_split,
         prev_cust_trx_line_salesrep_id,
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
/* BEGIN bug 3067675 */
         revenue_salesgroup_id,
         non_revenue_salesgroup_id,
/* END bug 3067675 */
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         program_application_id,
         program_id,
         program_update_date
        ,org_id
       )
       VALUES
       (
         l_cust_trx_line_salesrep_id,
         p_srep_rec.customer_trx_id,
         p_srep_rec.customer_trx_line_id,
         p_srep_rec.salesrep_id,
         p_srep_rec.revenue_amount_split,
         p_srep_rec.non_revenue_amount_split,
         p_srep_rec.non_revenue_percent_split,
         p_srep_rec.revenue_percent_split,
         p_srep_rec.prev_cust_trx_line_salesrep_id,
         p_srep_rec.attribute_category,
         p_srep_rec.attribute1,
         p_srep_rec.attribute2,
         p_srep_rec.attribute3,
         p_srep_rec.attribute4,
         p_srep_rec.attribute5,
         p_srep_rec.attribute6,
         p_srep_rec.attribute7,
         p_srep_rec.attribute8,
         p_srep_rec.attribute9,
         p_srep_rec.attribute10,
         p_srep_rec.attribute11,
         p_srep_rec.attribute12,
         p_srep_rec.attribute13,
         p_srep_rec.attribute14,
         p_srep_rec.attribute15,
/* BEGIN bug 3067675 */
         p_srep_rec.revenue_salesgroup_id,
         p_srep_rec.non_revenue_salesgroup_id,
/* END bug 3067675 */
         sysdate,			/*last_update_date */
         pg_user_id,			/* last_updated_by */
         sysdate, 			/* creation_date */
         pg_user_id,			/* created_by */
         nvl(pg_conc_login_id,
             pg_login_id),		/* last_update_login */
         pg_prog_appl_id,		/* program_application_id */
         pg_conc_program_id,		/* program_id */
         sysdate			/* program_update_date */
          ,arp_standard.sysparm.org_id /* SSA changes anuj */
       );



   p_cust_trx_line_salesrep_id := l_cust_trx_line_salesrep_id;

   arp_util.debug('arp_ctls_pkg.insert_p()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ctls_pkg.insert_p()');
	RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_f_ct_ctl_id						     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure inserts rows into ra_cust_trx_line_salesreps that       |
 |    correspond to the default salescredits for the transaction	     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |			p_customer_trx_line_id				     |
 |                      p_customer_trx_id                                    |
 |		 	p_currency_code 				     |
 |			p_precision 					     |
 |			p_mau						     |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     24-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE insert_f_ct_ctl_id(
                          p_customer_trx_id IN
                              ra_customer_trx_lines.customer_trx_id%type,
                          p_customer_trx_line_id IN
                              ra_customer_trx_lines.customer_trx_line_id%type
                         ) IS


BEGIN

   arp_util.debug('arp_ctls_pkg.insert_f_ct_ctl_id()+');

   arp_util.debug('p_customer_trx_id         = ' || p_customer_trx_id);
   arp_util.debug('p_customer_trx_line_id    = ' || p_customer_trx_line_id);

----  temporary! Remove for production. ---- moose
        SELECT salesrep_required_flag
        INTO   pg_salesrep_required_flag
        FROM   ar_system_parameters;
----  --------------------------------------

   /* Bug 3828325/3837548 - Bind variable adversely affects performance.
      Adding IF-ELSE and separate execution path to only use
      p_customer_trx_line_id if it is not null */

   IF (p_customer_trx_line_id IS NOT NULL)
   THEN

     INSERT INTO ra_cust_trx_line_salesreps
      (
         cust_trx_line_salesrep_id,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         customer_trx_id,
         customer_trx_line_id,
         salesrep_id,
         revenue_percent_split,
         revenue_amount_split,
         revenue_salesgroup_id,
         non_revenue_percent_split,
         non_revenue_amount_split,
         non_revenue_salesgroup_id,
         org_id
      )
      SELECT ra_cust_trx_line_salesreps_s.nextval,
             sysdate,			/* last_update_date */
             pg_user_id,		/* last_updated_by */
             sysdate,			/* creation_date */
             pg_user_id,		/* created_by */
             nvl(pg_conc_login_id,
                   pg_login_id),	/* last_update_login */
             ctl.customer_trx_id,
             ctl.customer_trx_line_id,
             NVL( ctls.salesrep_id, ct.primary_salesrep_id ),
             NVL(
                  ctls.revenue_percent_split,
                  DECODE(
                           ctls.cust_trx_line_salesrep_id,
                           null, 100,
                                 null
                        )
                ),
             arpcurr.CurrRound(
                                 (
                                     NVL(
                                          ctls.revenue_percent_split,
                                          DECODE(
                                                ctls.cust_trx_line_salesrep_id,
                                                null, 100,
                                                      null
                                                )
                                        )
                                     / 100
                                 ) *  ctl.extended_amount,
	     		          ct.invoice_currency_code
                              ),
             NVL(
             	  ctls.revenue_salesgroup_id,
                  DECODE(
                           ctls.cust_trx_line_salesrep_id,
                           null, arp_util.Get_Default_SalesGroup(ct.primary_salesrep_id, ct.org_id, ct.trx_date),
                                 null
                        )
                ),
             ctls.non_revenue_percent_split,
             arpcurr.CurrRound(
                                 (ctls.non_revenue_percent_split / 100 ) *
                                       ctl.extended_amount,
	     		              ct.invoice_currency_code
                              ),
             ctls.non_revenue_salesgroup_id,
             ct.org_id
      FROM  ra_customer_trx ct,
            ra_cust_trx_line_salesreps ctls,
            ra_customer_trx_lines ctl
      WHERE ctl.customer_trx_id        = ctls.customer_trx_id(+)
      AND   ctl.customer_trx_id        = ct.customer_trx_id
      AND   ct.customer_trx_id         = p_customer_trx_id
      AND   ctl.line_type              = 'LINE'
      AND   ctl.customer_trx_line_id   = p_customer_trx_line_id
      AND   ctls.customer_trx_line_id(+)  IS NULL
  	     /*---------------------------------------------------------+
              |  Use the default salescredits if available. Otherwise,  |
              |  insert a salescredit that corresponds to the primary 	|
              |  salesrep unless 					|
              |    1) there is no primary salesrep  or			|
              |    2) the primary salesrep is 'No Sales Credit' and 	|
              |        salescredits are not required.			|
              | 5250222 - default if primary is not null, even if
              |    it is -3 salesrep ID
	      +---------------------------------------------------------*/
      AND   (
                ( ctls.cust_trx_line_salesrep_id IS NOT NULL )
             OR
                ( ct.primary_salesrep_id IS NOT NULL)
            );

   ELSE
     /* p_customer_trx_line_id is NULL */
     INSERT INTO ra_cust_trx_line_salesreps
      (
         cust_trx_line_salesrep_id,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         customer_trx_id,
         customer_trx_line_id,
         salesrep_id,
         revenue_percent_split,
         revenue_amount_split,
	 revenue_salesgroup_id, 	-- added here and in SELECT - bug 3067675
         non_revenue_percent_split,
         non_revenue_amount_split
	,non_revenue_salesgroup_id 	-- added here and in SELECT - bug 3067675
        ,org_id
      )
      SELECT ra_cust_trx_line_salesreps_s.nextval,
             sysdate,			/* last_update_date */
             pg_user_id,		/* last_updated_by */
             sysdate,			/* creation_date */
             pg_user_id,		/* created_by */
             nvl(pg_conc_login_id,
                   pg_login_id),	/* last_update_login */
             ctl.customer_trx_id,
             ctl.customer_trx_line_id,
             NVL( ctls.salesrep_id, ct.primary_salesrep_id ),
             NVL(
                  ctls.revenue_percent_split,
                  DECODE(
                           ctls.cust_trx_line_salesrep_id,
                           null, 100,
                                 null
                        )
                ),
             arpcurr.CurrRound(
                                 (
                                     NVL(
                                          ctls.revenue_percent_split,
                                          DECODE(
                                                ctls.cust_trx_line_salesrep_id,
                                                null, 100,
                                                      null
                                                )
                                        )
                                     / 100
                                 ) *  ctl.extended_amount,
	     		          ct.invoice_currency_code
                              ),
             NVL(
                  ctls.revenue_salesgroup_id,
                  DECODE(
                           ctls.cust_trx_line_salesrep_id,
                           null, arp_util.Get_Default_SalesGroup(ct.primary_salesrep_id, ct.org_id, ct.trx_date),
                                 null
                        )
                ),
             ctls.non_revenue_percent_split,
             arpcurr.CurrRound(
                                 (ctls.non_revenue_percent_split / 100 ) *
                                       ctl.extended_amount,
	     		              ct.invoice_currency_code
                              )
             ,ctls.non_revenue_salesgroup_id
             ,ct.org_id
      FROM  ra_customer_trx ct,
            ra_cust_trx_line_salesreps ctls,
            ra_customer_trx_lines ctl
      WHERE ctl.customer_trx_id        = ctls.customer_trx_id(+)
      AND   ctl.customer_trx_id        = ct.customer_trx_id
      AND   ct.customer_trx_id         = p_customer_trx_id
      AND   ctl.line_type              = 'LINE'
      AND   ctls.customer_trx_line_id(+)  IS NULL
  	     /*---------------------------------------------------------+
              |  Use the default salescredits if available. Otherwise,  |
              |  insert a salescredit that corresponds to the primary 	|
              |  salesrep unless 					|
              |    1) there is no primary salesrep  or			|
              |    2) the primary salesrep is 'No Sales Credit' and 	|
              |        salescredits are not required.			|
	      +---------------------------------------------------------*/
      AND   (
                ( ctls.cust_trx_line_salesrep_id IS NOT NULL )
             OR
                ( ct.primary_salesrep_id IS NOT NULL )
             );

   END IF;

   arp_util.debug('arp_ctls_pkg.insert_f_ct_ctl_id()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ctls_pkg.insert_f_ct_ctl_id()');
	RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_f_cm_ct_ctl_id     					     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure inserts rows into ra_cust_trx_line_salesreps that       |
 |    correspond to salescredits for the credited transaction or	     |
 |    a credited transaction line                                      	     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |			p_customer_trx_id				     |
 |			p_customer_trx_line_id				     |
 |		 	p_currency_code 				     |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-AUG-95  Subash Chadalavada  Created                                |
 |     05-SEP-02  J Beckett           Bug 2543675 - RAM sales credits        |
 |                                    excluded from credit memos             |
 |     19-NOV-02  J Beckett           Bug 2543675 - change backed out.       |
 |                                                                           |
 +===========================================================================*/

PROCEDURE insert_f_cm_ct_ctl_id(
             p_customer_trx_id      IN ra_customer_trx.customer_trx_id%type,
             p_customer_trx_line_id IN
                              ra_customer_trx_lines.customer_trx_line_id%type,
             p_currency_code        IN fnd_currencies.currency_code%type
           ) IS
BEGIN

   arp_util.debug('arp_ctls_pkg.insert_f_cm_ct_ctl_id()+');

   arp_util.debug('p_customer_trx_id       = ' || p_customer_trx_id);
   arp_util.debug('p_customer_trx_line_id  = ' || p_customer_trx_line_id);
   arp_util.debug('p_currency_code         = ' || p_currency_code);

   INSERT INTO ra_cust_trx_line_salesreps
      (
         cust_trx_line_salesrep_id,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         customer_trx_id,
         customer_trx_line_id,
         salesrep_id,
	 revenue_salesgroup_id, 	-- added here and in SELECT - bug 3067675
	 non_revenue_salesgroup_id, 	-- added here and in SELECT - bug 3067675
         prev_cust_trx_line_salesrep_id,
         revenue_percent_split,
         revenue_amount_split,
         non_revenue_percent_split,
         non_revenue_amount_split
         ,org_id
      )
      SELECT ra_cust_trx_line_salesreps_s.nextval,
             sysdate,			/* last_update_date */
             pg_user_id,		/* last_updated_by */
             sysdate,			/* creation_date */
             pg_user_id,		/* created_by */
             nvl(pg_conc_login_id,
                   pg_login_id),	/* last_update_login */
             ctl.customer_trx_id,
             ctl.customer_trx_line_id,
             nvl(prev_ctls.salesrep_id, cm_ct.primary_salesrep_id),
             decode(prev_ctls.cust_trx_line_salesrep_id,
               null, arp_util.Get_Default_SalesGroup(cm_ct.primary_salesrep_id, cm_ct.org_id, cm_ct.trx_date),
               prev_ctls.revenue_salesgroup_id),
             prev_ctls.non_revenue_salesgroup_id,
             prev_ctls.cust_trx_line_salesrep_id,
             decode(prev_ctls.cust_trx_line_salesrep_id,
               null, 100,
               prev_ctls.revenue_percent_split),
             arpcurr.CurrRound(
                                (decode(prev_ctls.cust_trx_line_salesrep_id,
                                   null, 100,
                                   prev_ctls.revenue_percent_split) / 100 ) *
                                            ctl.extended_amount,
	     		                    p_currency_code
                              ),        /* revenue_amount_split */
             prev_ctls.non_revenue_percent_split,
             arpcurr.CurrRound(
                                 (prev_ctls.non_revenue_percent_split / 100 ) *
                                            ctl.extended_amount,
	     		                    p_currency_code
                              )         /* non_revenue_amount_split */
           ,cm_ct.org_id
      FROM  ra_cust_trx_line_salesreps prev_ctls,
            ra_customer_trx_lines ctl,
            ra_customer_trx cm_ct
      WHERE ctl.previous_customer_trx_id      = prev_ctls.customer_trx_id(+)
      AND   ctl.previous_customer_trx_line_id =
                                           prev_ctls.customer_trx_line_id(+)
      AND   ctl.customer_trx_id               = p_customer_trx_id
      AND   cm_ct.customer_trx_id             = p_customer_trx_id
      AND   ctl.line_type                     = 'LINE'
      AND   ctl.customer_trx_line_id          = nvl(p_customer_trx_line_id,
                                                    ctl.customer_trx_line_id);

   arp_util.debug('arp_ctls_pkg.insert_f_cm_ct_ctl_id() : '||
                   SQL%ROWCOUNT||' rows inserted');

   arp_util.debug('arp_ctls_pkg.insert_f_cm_ct_ctl_id()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ctls_pkg.insert_f_cm_ct_ctl_id()');
        arp_util.debug('p_customer_trx_id       = ' || p_customer_trx_id);
        arp_util.debug('p_customer_trx_line_id  = ' || p_customer_trx_line_id);
        arp_util.debug('p_currency_code         = ' || p_currency_code);

	RAISE;
END;
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_f_cmn_ct_ctl_id                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure inserts rows into ra_cust_trx_line_salesreps that       |
 |    correspond to salescredits for the credit memo for a credited
 |    transaction line                                                       |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                      p_customer_trx_id                                    |
 |                      p_customer_trx_line_id                               |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     18-Jan-00  Satheesh Nambiar    Created                                |
 |     05-SEP-02  J Beckett           Bug 2543675 - RAM sales credits        |
 |                                    excluded from credit memos             |
 |     19-NOV-02  J Beckett           Bug 2543675 - change backed out.       |
 |                                                                           |
 +===========================================================================*/
PROCEDURE insert_f_cmn_ct_ctl_id(
             p_customer_trx_id      IN ra_customer_trx.customer_trx_id%type,
             p_customer_trx_line_id IN
                              ra_customer_trx_lines.customer_trx_line_id%type
             ) IS
BEGIN

   arp_util.debug('arp_ctls_pkg.insert_f_cmn_ct_ctl_id()+');

   arp_util.debug('p_customer_trx_id       = ' || p_customer_trx_id);
   arp_util.debug('p_customer_trx_line_id  = ' || p_customer_trx_line_id);

   INSERT INTO ra_cust_trx_line_salesreps
      (
         cust_trx_line_salesrep_id,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         customer_trx_id,
         customer_trx_line_id,
         salesrep_id,
	 revenue_salesgroup_id, 	-- added here and in SELECT - bug 3067675
	 non_revenue_salesgroup_id, 	-- added here and in SELECT - bug 3067675
         prev_cust_trx_line_salesrep_id,
         revenue_percent_split,
         revenue_amount_split,
         non_revenue_percent_split,
         non_revenue_amount_split
         ,org_id
      )
      SELECT ra_cust_trx_line_salesreps_s.nextval,
             sysdate,                   /* last_update_date */
             pg_user_id,                /* last_updated_by */
             sysdate,                   /* creation_date */
             pg_user_id,                /* created_by */
             nvl(pg_conc_login_id,
                   pg_login_id),        /* last_update_login */
             ctl.customer_trx_id,
             ctl.customer_trx_line_id,
             nvl(prev_ctls.salesrep_id, cm_ct.primary_salesrep_id),
             NVL(
                  prev_ctls.revenue_salesgroup_id,
                  DECODE(
                           prev_ctls.cust_trx_line_salesrep_id,
                           null, arp_util.Get_Default_SalesGroup(cm_ct.primary_salesrep_id, cm_ct.org_id, cm_ct.trx_date),
                                 null
                        )
                ),
             prev_ctls.non_revenue_salesgroup_id,
             prev_ctls.cust_trx_line_salesrep_id,
             NVL(
                  prev_ctls.revenue_percent_split,
                  DECODE(
                           prev_ctls.cust_trx_line_salesrep_id,
                           null, 100,
                                 null
                        )
                ),
                arpcurr.CurrRound(
                                 (
                                     NVL(
                                          prev_ctls.revenue_percent_split,
                                          DECODE(
                                            prev_ctls.cust_trx_line_salesrep_id,
                                                null, 100,
                                                      null
                                                )
                                        )
                                     / 100
                                 ) *  ctl.extended_amount,
                                  cm_ct.invoice_currency_code
                              ),
             prev_ctls.non_revenue_percent_split,
             arpcurr.CurrRound(
                                 (prev_ctls.non_revenue_percent_split / 100 ) *
                                       ctl.extended_amount,
                                      cm_ct.invoice_currency_code
                              ) /* non_revenue_amount_split */
          ,cm_ct.org_id
      FROM  ra_cust_trx_line_salesreps prev_ctls,
            ra_customer_trx_lines ctl,
            ra_customer_trx cm_ct
      WHERE ctl.previous_customer_trx_id      = prev_ctls.customer_trx_id(+)
      AND   ctl.previous_customer_trx_line_id =
                                           prev_ctls.customer_trx_line_id(+)
      AND   ctl.customer_trx_id               = p_customer_trx_id
      AND   cm_ct.customer_trx_id             = p_customer_trx_id
      AND   ctl.line_type                     = 'LINE'
      AND   ctl.customer_trx_line_id          = nvl(p_customer_trx_line_id,
                                                    ctl.customer_trx_line_id);

   arp_util.debug('arp_ctls_pkg.insert_f_cmn_ct_ctl_id() : '||
                   SQL%ROWCOUNT||' rows inserted');

   arp_util.debug('arp_ctls_pkg.insert_f_cmn_ct_ctl_id()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ctls_pkg.insert_f_cmn_ct_ctl_id()');
        arp_util.debug('p_customer_trx_id       = ' || p_customer_trx_id);
        arp_util.debug('p_customer_trx_line_id  = ' || p_customer_trx_line_id);


        RAISE;
END;
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_compare_cover						     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Converts column parameters to a salescredit record and                 |
 |    lockss a salescredit line.                                             |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_cust_trx_line_salesrep_id 			     |
 |                    p_customer_trx_id                                      |
 |                    p_customer_trx_line_id                                 |
 |                    p_salesrep_id                                          |
 |                    p_revenue_amount_split                                 |
 |                    p_non_revenue_amount_split                             |
 |                    p_non_revenue_percent_split                            |
 |                    p_revenue_percent_split                                |
 |                    p_prev_cust_trx_line_srep_id                           |
 |                    p_attribute_category                                   |
 |                    p_attribute1                                           |
 |                    p_attribute2                                           |
 |                    p_attribute3                                           |
 |                    p_attribute4                                           |
 |                    p_attribute5                                           |
 |                    p_attribute6                                           |
 |                    p_attribute7                                           |
 |                    p_attribute8                                           |
 |                    p_attribute9                                           |
 |                    p_attribute10                                          |
 |                    p_attribute11                                          |
 |                    p_attribute12                                          |
 |                    p_attribute13                                          |
 |                    p_attribute14                                          |
 |                    p_attribute15                                          |
 |                    p_revenue_salesgroup_id                                |
 |                    p_non_revenue_salesgroup_id                            |
 |              OUT:                                                         |
 |                    None						     |
 |          IN/ OUT:							     |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-SEP-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_compare_cover(
           p_cust_trx_line_salesrep_id   IN
                     ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type,
           p_customer_trx_id                 IN
                         ra_cust_trx_line_salesreps.customer_trx_id%type,
           p_customer_trx_line_id            IN
                         ra_cust_trx_line_salesreps.customer_trx_line_id%type,
           p_salesrep_id                     IN
                         ra_cust_trx_line_salesreps.salesrep_id%type,
           p_revenue_amount_split            IN
                         ra_cust_trx_line_salesreps.revenue_amount_split%type,
           p_non_revenue_amount_split        IN
                     ra_cust_trx_line_salesreps.non_revenue_amount_split%type,
           p_non_revenue_percent_split       IN
                    ra_cust_trx_line_salesreps.non_revenue_percent_split%type,
           p_revenue_percent_split           IN
                    ra_cust_trx_line_salesreps.revenue_percent_split%type,
           p_prev_cust_trx_line_srep_id      IN
               ra_cust_trx_line_salesreps.prev_cust_trx_line_salesrep_id%type,
           p_attribute_category              IN
                    ra_cust_trx_line_salesreps.attribute_category%type,
           p_attribute1                      IN
                    ra_cust_trx_line_salesreps.attribute1%type,
           p_attribute2                      IN
                    ra_cust_trx_line_salesreps.attribute2%type,
           p_attribute3                      IN
                    ra_cust_trx_line_salesreps.attribute3%type,
           p_attribute4                      IN
                    ra_cust_trx_line_salesreps.attribute4%type,
           p_attribute5                      IN
                    ra_cust_trx_line_salesreps.attribute5%type,
           p_attribute6                      IN
                    ra_cust_trx_line_salesreps.attribute6%type,
           p_attribute7                      IN
                    ra_cust_trx_line_salesreps.attribute7%type,
           p_attribute8                      IN
                    ra_cust_trx_line_salesreps.attribute8%type,
           p_attribute9                      IN
                    ra_cust_trx_line_salesreps.attribute9%type,
           p_attribute10                     IN
                    ra_cust_trx_line_salesreps.attribute10%type,
           p_attribute11                     IN
                    ra_cust_trx_line_salesreps.attribute11%type,
           p_attribute12                     IN
                    ra_cust_trx_line_salesreps.attribute12%type,
           p_attribute13                     IN
                    ra_cust_trx_line_salesreps.attribute13%type,
           p_attribute14                     IN
                    ra_cust_trx_line_salesreps.attribute14%type,
           p_attribute15                     IN
                    ra_cust_trx_line_salesreps.attribute15%type,
/* BEGIN bug 3067675 */
           p_revenue_salesgroup_id           IN
                    ra_cust_trx_line_salesreps.revenue_salesgroup_id%type DEFAULT null,
           p_non_revenue_salesgroup_id       IN
                    ra_cust_trx_line_salesreps.non_revenue_salesgroup_id%type DEFAULT null)
/* END bug 3067675 */
                   IS

      l_srep_rec ra_cust_trx_line_salesreps%rowtype;

BEGIN

      arp_util.debug('arp_ctls_pkg.lock_compare_cover()+');

     /*------------------------------------------------+
      |  Populate the salescredit record group with    |
      |  the values passed in as parameters.           |
      +------------------------------------------------*/

      arp_ctls_pkg.set_to_dummy(l_srep_rec);

      l_srep_rec.cust_trx_line_salesrep_id    := p_cust_trx_line_salesrep_id;
      l_srep_rec.customer_trx_id              := p_customer_trx_id;
      l_srep_rec.customer_trx_line_id         := p_customer_trx_line_id;
      l_srep_rec.salesrep_id                  := p_salesrep_id;
      l_srep_rec.revenue_amount_split         := p_revenue_amount_split;
      l_srep_rec.non_revenue_amount_split     := p_non_revenue_amount_split;
      l_srep_rec.non_revenue_percent_split    := p_non_revenue_percent_split;
      l_srep_rec.revenue_percent_split        := p_revenue_percent_split;
      l_srep_rec.prev_cust_trx_line_salesrep_id
                                     := p_prev_cust_trx_line_srep_id;
      l_srep_rec.attribute_category           := p_attribute_category;
      l_srep_rec.attribute1                   := p_attribute1;
      l_srep_rec.attribute2                   := p_attribute2;
      l_srep_rec.attribute3                   := p_attribute3;
      l_srep_rec.attribute4                   := p_attribute4;
      l_srep_rec.attribute5                   := p_attribute5;
      l_srep_rec.attribute6                   := p_attribute6;
      l_srep_rec.attribute7                   := p_attribute7;
      l_srep_rec.attribute8                   := p_attribute8;
      l_srep_rec.attribute9                   := p_attribute9;
      l_srep_rec.attribute10                  := p_attribute10;
      l_srep_rec.attribute11                  := p_attribute11;
      l_srep_rec.attribute12                  := p_attribute12;
      l_srep_rec.attribute13                  := p_attribute13;
      l_srep_rec.attribute14                  := p_attribute14;
      l_srep_rec.attribute15                  := p_attribute15;
/* BEGIN bug 3067675 */
      l_srep_rec.revenue_salesgroup_id        := p_revenue_salesgroup_id;
      l_srep_rec.non_revenue_salesgroup_id    := p_non_revenue_salesgroup_id;
/* END bug 3067675 */


     /*----------------------------------------------+
      |  Call the standard salescredit table handler |
      +----------------------------------------------*/

      lock_compare_p(
                       l_srep_rec,
                       p_cust_trx_line_salesrep_id,
                       TRUE   -- ignore who columns
                    );

      arp_util.debug('arp_ctls_pkg.lock_compare_cover()-');

EXCEPTION
  WHEN OTHERS THEN

    arp_util.debug(
           'EXCEPTION:  arp_ctls_pkg.lock_compare_cover()');

    arp_util.debug('------- parameters for lock_compare_cover() ' ||
                   '---------');
    arp_util.debug('p_customer_trx_id             = ' || p_customer_trx_id );
    arp_util.debug('p_customer_trx_line_id        = ' ||
                   p_customer_trx_line_id );
    arp_util.debug('p_salesrep_id                 = ' ||
                   p_salesrep_id );
    arp_util.debug('p_revenue_amount_split        = ' ||
                   p_revenue_amount_split );
    arp_util.debug('p_non_revenue_amount_split    = ' ||
                   p_non_revenue_amount_split );
    arp_util.debug('p_non_revenue_percent_split   = ' ||
                    p_non_revenue_percent_split );
    arp_util.debug('p_revenue_percent_split       = ' ||
                    p_revenue_percent_split );
    arp_util.debug('p_prev_cust_trx_line_srep_id  = ' ||
                   p_prev_cust_trx_line_srep_id );
    arp_util.debug('p_attribute_category          = ' ||
                   p_attribute_category );
    arp_util.debug('p_attribute1                  = ' || p_attribute1 );
    arp_util.debug('p_attribute2                  = ' || p_attribute2 );
    arp_util.debug('p_attribute3                  = ' || p_attribute3 );
    arp_util.debug('p_attribute4                  = ' || p_attribute4 );
    arp_util.debug('p_attribute5                  = ' || p_attribute5 );
    arp_util.debug('p_attribute6                  = ' || p_attribute6 );
    arp_util.debug('p_attribute7                  = ' || p_attribute7 );
    arp_util.debug('p_attribute8                  = ' || p_attribute8 );
    arp_util.debug('p_attribute9                  = ' || p_attribute9 );
    arp_util.debug('p_attribute10                 = ' || p_attribute10 );
    arp_util.debug('p_attribute11                 = ' || p_attribute11 );
    arp_util.debug('p_attribute12                 = ' || p_attribute12 );
    arp_util.debug('p_attribute13                 = ' || p_attribute13 );
    arp_util.debug('p_attribute14                 = ' || p_attribute14 );
    arp_util.debug('p_attribute15                 = ' || p_attribute15 );
/* BEGIN bug 3067675 */
    arp_util.debug('p_revenue_salesgroup_id       = ' || p_revenue_salesgroup_id );
    arp_util.debug('p_non_revenue_salesgroup_id   = ' || p_non_revenue_salesgroup_id );
/* END bug 3067675 */

    RAISE;

END;

  /*---------------------------------------------+
   |   Package initialization section.           |
   |   Sets WHO column variables for later use.  |
   +---------------------------------------------*/
PROCEDURE init IS
BEGIN

  arp_standard.debug('arp_ctls_pkg.init()+');

  pg_user_id          := fnd_global.user_id;
  pg_conc_login_id    := fnd_global.conc_login_id;
  pg_login_id         := fnd_global.login_id;
  pg_prog_appl_id     := fnd_global.prog_appl_id;
  pg_conc_program_id  := fnd_global.conc_program_id;

  pg_salesrep_required_flag :=
    arp_trx_global.system_info.system_parameters.salesrep_required_flag;

  arp_standard.debug('arp_ctls_pkg.init()-');
END init;

BEGIN
   init;
END ARP_CTLS_PKG;

/
