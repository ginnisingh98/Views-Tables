--------------------------------------------------------
--  DDL for Package Body ARP_TBAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_TBAT_PKG" AS
/* $Header: ARTIBATB.pls 120.6 2005/04/14 22:44:45 hyu ship $ */

  /*--------------------------------------------------------+
   |  Dummy constants for use in update and lock operations |
   +--------------------------------------------------------*/

  AR_TEXT_DUMMY   CONSTANT VARCHAR2(10) := '~~!@#$*&^';
  AR_NUMBER_DUMMY CONSTANT NUMBER(15)   := -999999999999999;
  AR_DATE_DUMMY   CONSTANT DATE         := to_date(1, 'J');
  AR_FLAG_DUMMY   CONSTANT VARCHAR2(10) := '~';

  /*---------------------------------------------------------------+
   |  Package global variables to hold the parsed update cursors.  |
   |  This allows the cursors to be reused without being reparsed. |
   +---------------------------------------------------------------*/

  pg_cursor1  integer := '';
  pg_cursor2  integer := '';

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
 |    display_batch_rec							     |
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
 |		      p_batch_rec					     |
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
 |     19-JUL-95  Charlie Tomberg     Created                                |
 |                                                                           |
 | 20-MAR-2000  J Rautiainen    Added BR project related columns             |
 |                              ISSUE_DATE, MATURITY_DATE,                   |
 |                              SPECIAL_INSTRUCTIONS, BATCH_PROCESS_STATUS   |
 |                              and SELECTION_CRITERIA_ID into table handlers|
 |                                                                           |
 | 31-OCT-2000 Y Rakotonirainy  Bug 1243304 : Added column 		     |
 |					      purged_children_flag and	     |
 |					      request_id 		     |
 | 				      	      into the table handlers. 	     |
 |                                                                           |
 +===========================================================================*/

PROCEDURE display_batch_rec( p_batch_rec ra_batches%rowtype )
                   IS


BEGIN

   arp_util.debug('arp_tbat_pgk.display_batch_rec()+');


   arp_util.debug('************** Dump of ra_batches record **************');
   arp_util.debug('batch_id: '           || p_batch_rec.batch_id);
   arp_util.debug('last_updated_by: '    || p_batch_rec.last_updated_by);
   arp_util.debug('created_by: '         || p_batch_rec.created_by);
   arp_util.debug('last_update_login: '  || p_batch_rec.last_update_login);
   arp_util.debug('program_id: '         || p_batch_rec.program_id);
   arp_util.debug('set_of_books_id: '    || p_batch_rec.set_of_books_id);
   arp_util.debug('name: '               || p_batch_rec.name);
   arp_util.debug('batch_source_id: '    || p_batch_rec.batch_source_id);
   arp_util.debug('batch_date: '         || p_batch_rec.batch_date);
   arp_util.debug('gl_date: '            || p_batch_rec.gl_date);
   arp_util.debug('status: '             || p_batch_rec.status);
   arp_util.debug('type: '               || p_batch_rec.type);
   arp_util.debug('control_count: '      || p_batch_rec.control_count);
   arp_util.debug('control_amount: '     || p_batch_rec.control_amount);
   arp_util.debug('comments: '           || p_batch_rec.comments);
   arp_util.debug('currency_code: '      || p_batch_rec.currency_code);
   arp_util.debug('exchange_rate_type: ' || p_batch_rec.exchange_rate_type);
   arp_util.debug('exchange_date: '      || p_batch_rec.exchange_date);
   arp_util.debug('exchange_rate: '      || p_batch_rec.exchange_rate);
   arp_util.debug('purged_children_flag:'|| p_batch_rec.purged_children_flag);
   arp_util.debug('attribute_category: ' || p_batch_rec.attribute_category);
   arp_util.debug('attribute1: '         || p_batch_rec.attribute1);
   arp_util.debug('attribute2: '         || p_batch_rec.attribute2);
   arp_util.debug('attribute3: '         || p_batch_rec.attribute3);
   arp_util.debug('attribute4: '         || p_batch_rec.attribute4);
   arp_util.debug('attribute5: '         || p_batch_rec.attribute5);
   arp_util.debug('attribute6: '         || p_batch_rec.attribute6);
   arp_util.debug('attribute7: '         || p_batch_rec.attribute7);
   arp_util.debug('attribute8: '         || p_batch_rec.attribute8);
   arp_util.debug('attribute9: '         || p_batch_rec.attribute9);
   arp_util.debug('attribute10: '        || p_batch_rec.attribute10);
   arp_util.debug('attribute11: '        || p_batch_rec.attribute11);
   arp_util.debug('attribute12: '        || p_batch_rec.attribute12);
   arp_util.debug('attribute13: '        || p_batch_rec.attribute13);
   arp_util.debug('attribute14: '        || p_batch_rec.attribute14);
   arp_util.debug('attribute15: '        || p_batch_rec.attribute15);
   arp_util.debug('program_application_id: ' || p_batch_rec.program_application_id);
   arp_util.debug('issue_date:             ' || p_batch_rec.issue_date);
   arp_util.debug('maturity_date:          ' || p_batch_rec.maturity_date);
   arp_util.debug('special_instructions:   ' || p_batch_rec.special_instructions);
   arp_util.debug('batch_process_status:   ' || p_batch_rec.batch_process_status);
   arp_util.debug('selection_criteria_id:  ' || p_batch_rec.selection_criteria_id);
   arp_util.debug('request_id:  ' 	     || p_batch_rec.request_id);
   arp_util.debug('************** End ra_batches record **************');

   arp_util.debug('arp_tbat_pgk.display_batch_rec()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_tbat_pgk.display_batch_rec()');
        RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    display_batch							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Selects and displays the values of all columns except creation_date    |
 |    and last_update_date.						     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_batch_id					     |
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

PROCEDURE display_batch(  p_batch_id IN ra_batches.batch_id%type)
                   IS

   l_batch_rec ra_batches%rowtype;

BEGIN

   arp_util.debug('arp_tbat_pgk.display_batch()+');

   arp_tbat_pkg.fetch_p(l_batch_rec, p_batch_id);

   arp_tbat_pkg.display_batch_rec (l_batch_rec);

   arp_util.debug('arp_tbat_pgk.display_batch()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_tbat_pgk.display_batch()');
        RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    bind_batch_variables                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Binds variables from the batch record variable to the bind variables   |
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
 |                    p_batch_rec      - ra_batches record                   |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     06-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 | 20-MAR-2000  J Rautiainen    Added BR project related columns             |
 |                              ISSUE_DATE, MATURITY_DATE,                   |
 |                              SPECIAL_INSTRUCTIONS, BATCH_PROCESS_STATUS   |
 |                              and SELECTION_CRITERIA_ID into table handlers|
 |                                                                           |
 | 31-OCT-2000 Y Rakotonirainy  Bug 1243304 : Added column 		     |
 |					      purged_children_flag and	     |
 |					      request_id 		     |
 | 				      	      into the table handlers. 	     |
 |                                                                           |
 +===========================================================================*/


PROCEDURE bind_batch_variables(p_update_cursor IN integer,
                               p_batch_rec     IN ra_batches%rowtype) IS

BEGIN

   arp_util.debug('arp_tbat_pkg.bind_batch_variables()+');

  /*------------------+
   |  Dummy constants |
   +------------------*/

   dbms_sql.bind_variable(p_update_cursor, ':ar_text_dummy',
                          AR_TEXT_DUMMY);
   dbms_sql.bind_variable(p_update_cursor, ':ar_number_dummy',
                          AR_NUMBER_DUMMY);
   dbms_sql.bind_variable(p_update_cursor, ':ar_date_dummy',
                          AR_DATE_DUMMY);
   dbms_sql.bind_variable(p_update_cursor, ':ar_flag_dummy',
                          AR_FLAG_DUMMY);

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

   dbms_sql.bind_variable(p_update_cursor, ':batch_id',
                          p_batch_rec.batch_id);
   dbms_sql.bind_variable(p_update_cursor, ':last_update_date',
                          p_batch_rec.last_update_date);
   dbms_sql.bind_variable(p_update_cursor, ':last_updated_by',
                          p_batch_rec.last_updated_by);
   dbms_sql.bind_variable(p_update_cursor, ':creation_date',
                          p_batch_rec.creation_date);
   dbms_sql.bind_variable(p_update_cursor, ':created_by',
                          p_batch_rec.created_by);
   dbms_sql.bind_variable(p_update_cursor, ':last_update_login',
                          p_batch_rec.last_update_login);
   dbms_sql.bind_variable(p_update_cursor, ':program_application_id',
                          p_batch_rec.program_application_id);
   dbms_sql.bind_variable(p_update_cursor, ':program_id',
                          p_batch_rec.program_id);
   dbms_sql.bind_variable(p_update_cursor, ':program_update_date',
                          p_batch_rec.program_update_date);
   dbms_sql.bind_variable(p_update_cursor, ':set_of_books_id',
                          p_batch_rec.set_of_books_id);
   dbms_sql.bind_variable(p_update_cursor, ':name',
                          p_batch_rec.name);
   dbms_sql.bind_variable(p_update_cursor, ':batch_source_id',
                          p_batch_rec.batch_source_id);
   dbms_sql.bind_variable(p_update_cursor, ':batch_date',
                          p_batch_rec.batch_date);
   dbms_sql.bind_variable(p_update_cursor, ':gl_date',
                          p_batch_rec.gl_date);
   dbms_sql.bind_variable(p_update_cursor, ':status',
                          p_batch_rec.status);
   dbms_sql.bind_variable(p_update_cursor, ':type',
                          p_batch_rec.type);
   dbms_sql.bind_variable(p_update_cursor, ':control_count',
                          p_batch_rec.control_count);
   dbms_sql.bind_variable(p_update_cursor, ':control_amount',
                          p_batch_rec.control_amount);
   dbms_sql.bind_variable(p_update_cursor, ':comments',
                          p_batch_rec.comments);
   dbms_sql.bind_variable(p_update_cursor, ':currency_code',
                          p_batch_rec.currency_code);
   dbms_sql.bind_variable(p_update_cursor, ':exchange_rate_type',
                          p_batch_rec.exchange_rate_type);
   dbms_sql.bind_variable(p_update_cursor, ':exchange_date',
                          p_batch_rec.exchange_date);
   dbms_sql.bind_variable(p_update_cursor, ':exchange_rate',
                          p_batch_rec.exchange_rate);
   dbms_sql.bind_variable(p_update_cursor, ':purged_children_flag',
                          p_batch_rec.purged_children_flag);
   dbms_sql.bind_variable(p_update_cursor, ':attribute_category',
                          p_batch_rec.attribute_category);
   dbms_sql.bind_variable(p_update_cursor, ':attribute1',
                          p_batch_rec.attribute1);
   dbms_sql.bind_variable(p_update_cursor, ':attribute2',
                          p_batch_rec.attribute2);
   dbms_sql.bind_variable(p_update_cursor, ':attribute3',
                          p_batch_rec.attribute3);
   dbms_sql.bind_variable(p_update_cursor, ':attribute4',
                          p_batch_rec.attribute4);
   dbms_sql.bind_variable(p_update_cursor, ':attribute5',
                          p_batch_rec.attribute5);
   dbms_sql.bind_variable(p_update_cursor, ':attribute6',
                          p_batch_rec.attribute6);
   dbms_sql.bind_variable(p_update_cursor, ':attribute7',
                          p_batch_rec.attribute7);
   dbms_sql.bind_variable(p_update_cursor, ':attribute8',
                          p_batch_rec.attribute8);
   dbms_sql.bind_variable(p_update_cursor, ':attribute9',
                          p_batch_rec.attribute9);
   dbms_sql.bind_variable(p_update_cursor, ':attribute10',
                          p_batch_rec.attribute10);
   dbms_sql.bind_variable(p_update_cursor, ':attribute11',
                          p_batch_rec.attribute11);
   dbms_sql.bind_variable(p_update_cursor, ':attribute12',
                          p_batch_rec.attribute12);
   dbms_sql.bind_variable(p_update_cursor, ':attribute13',
                          p_batch_rec.attribute13);
   dbms_sql.bind_variable(p_update_cursor, ':attribute14',
                          p_batch_rec.attribute14);
   dbms_sql.bind_variable(p_update_cursor, ':attribute15',
                          p_batch_rec.attribute15);

   dbms_sql.bind_variable(p_update_cursor, ':issue_date',
                          p_batch_rec.issue_date);
   dbms_sql.bind_variable(p_update_cursor, ':maturity_date',
                          p_batch_rec.maturity_date);
   dbms_sql.bind_variable(p_update_cursor, ':special_instructions',
                          p_batch_rec.special_instructions);
   dbms_sql.bind_variable(p_update_cursor, ':batch_process_status',
                          p_batch_rec.batch_process_status);
   dbms_sql.bind_variable(p_update_cursor, ':selection_criteria_id',
                          p_batch_rec.selection_criteria_id);
   dbms_sql.bind_variable(p_update_cursor, ':request_id',
                          p_batch_rec.request_id);

   arp_util.debug('arp_tbat_pkg.bind_batch_variables()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_tbat_pkg.bind_batch_variables()');
        RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    construct_batch_update_stmt 					     |
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
 |    This statement only updates columns in the batch record that do not    |
 |    contain the dummy values that indicate that they should not be changed.|
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     06-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 | 20-MAR-2000  J Rautiainen    Added BR project related columns             |
 |                              ISSUE_DATE, MATURITY_DATE,                   |
 |                              SPECIAL_INSTRUCTIONS, BATCH_PROCESS_STATUS   |
 |                              and SELECTION_CRITERIA_ID into table handlers|
 |                                                                           |
 | 31-OCT-2000 Y Rakotonirainy  Bug 1243304 : Added column 		     |
 |					      purged_children_flag and	     |
 |					      request_id 		     |
 | 				      	      into the table handlers. 	     |
 |                                                                           |
 +===========================================================================*/

PROCEDURE construct_batch_update_stmt( update_text OUT NOCOPY varchar2) IS

BEGIN
   arp_util.debug('arp_tbat_pkg.construct_batch_update_stmt()+');

   update_text :=
 'update ra_batches
   SET    batch_id =
               DECODE(:batch_id,
                      :ar_number_dummy, batch_id,
                                       :batch_id),
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
                                     :program_update_date),
          set_of_books_id =
               DECODE(:set_of_books_id,
                      :ar_number_dummy, set_of_books_id,
                                       :set_of_books_id),
          name =
               DECODE(:name,
                      :ar_text_dummy, name,
                                     :name),
          batch_source_id =
               DECODE(:batch_source_id,
                      :ar_number_dummy, batch_source_id,
                                       :batch_source_id),
          batch_date =
               DECODE(:batch_date,
                      :ar_date_dummy, batch_date,
                                     :batch_date),
          gl_date =
               DECODE(:gl_date,
                      :ar_date_dummy, gl_date,
                                     :gl_date),
          status =
               DECODE(:status,
                      :ar_text_dummy, status,
                                     :status),
          type =
               DECODE(:type,
                      :ar_text_dummy, type,
                                     :type),
          control_count =
               DECODE(:control_count,
                      :ar_number_dummy, control_count,
                                       :control_count),
          control_amount =
               DECODE(:control_amount,
                      :ar_number_dummy, control_amount,
                                       :control_amount),
          comments =
                DECODE(:comments,
                       :ar_text_dummy, comments,
                                      :comments),
          currency_code =
                DECODE(:currency_code,
                       :ar_text_dummy, currency_code,
                                      :currency_code),
          exchange_rate_type =
                DECODE(:exchange_rate_type,
                       :ar_text_dummy, exchange_rate_type,
                                      :exchange_rate_type),
          exchange_date =
                DECODE(:exchange_date,
                       :ar_date_dummy, exchange_date,
                                      :exchange_date),
          exchange_rate =
                DECODE(:exchange_rate,
                       :ar_number_dummy, exchange_rate,
                                        :exchange_rate),
          purged_children_flag =
                DECODE(:purged_children_flag,
                       :ar_flag_dummy, purged_children_flag,
                                        :purged_children_flag),
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
          issue_date =
                 DECODE(:issue_date,
                       :ar_date_dummy, issue_date,
                                      :issue_date),
          maturity_date =
                 DECODE(:maturity_date,
                       :ar_date_dummy, maturity_date,
                                      :maturity_date),
          special_instructions =
                 DECODE(:special_instructions,
                       :ar_text_dummy, special_instructions,
                                      :special_instructions),
          batch_process_status =
                 DECODE(:batch_process_status,
                       :ar_text_dummy, batch_process_status,
                                      :batch_process_status),
          selection_criteria_id =
                 DECODE(:selection_criteria_id,
                       :ar_number_dummy, selection_criteria_id,
                                         :selection_criteria_id),
          request_id =
                DECODE(:request_id,
                       :ar_number_dummy, request_id,
                                        :request_id) ';

   arp_util.debug('arp_tbat_pkg.construct_batch_update_stmt()-');

EXCEPTION
    WHEN OTHERS THEN
      arp_util.debug('EXCEPTION:  arp_tbat_pkg.construct_batch_update_stmt()');
      RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    generic_update                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure Updates records in ra_batches identified by the where   |
 |    clause that is passed in as a parameter. Only those columns in         |
 |    the batch record parameter that do not contain the special dummy values|
 |    are updated.                                                           |
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
 |                    p_where_clause - identifies which rows to update       |
 | 		      p_where1         - value to bind into where clause     |
 |		      p_batch_rec    - contains the new batch values         |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     06-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE generic_update(p_update_cursor IN OUT NOCOPY integer,
                         p_where_clause  IN     varchar2,
			 p_where1        IN     number,
                         p_batch_rec     IN     ra_batches%rowtype) IS

   l_count             number;
   l_update_statement  varchar2(10000);
   l_ra_batch_key_value_list   gl_ca_utility_pkg.r_key_value_arr;
   ra_batch_array   dbms_sql.number_table;

BEGIN
   arp_util.debug('arp_tbat_pkg.generic_update()+');

  /*--------------------------------------------------------------+
   |  If this update statement has not already been parsed, 	  |
   |  construct the statement and parse it.			  |
   |  Otherwise, use the already parsed statement and rebind its  |
   |  variables.						  |
   +--------------------------------------------------------------*/

   IF (p_update_cursor is null)
   THEN

         p_update_cursor := dbms_sql.open_cursor;

         /*---------------------------------+
          |  Construct the update statement |
          +---------------------------------*/

         arp_tbat_pkg.construct_batch_update_stmt(l_update_statement);

         l_update_statement := l_update_statement || p_where_clause;

         /*  add on mrc variables for bulk collect */
         l_update_statement := l_update_statement ||
             ' RETURNING batch_id INTO :ra_batch_key_value ';


         /*-----------------------------------------------+
          |  Parse, bind, execute and close the statement |
          +-----------------------------------------------*/

         dbms_sql.parse(p_update_cursor,
                        l_update_statement,
                        dbms_sql.v7);

           /*---------------------------+
            | Bind output variable      |
            +---------------------------*/
           dbms_sql.bind_array(p_update_cursor,':ra_batch_key_value',
                               ra_batch_array);


   END IF;

   arp_tbat_pkg.bind_batch_variables(p_update_cursor, p_batch_rec);

  /*-----------------------------------------+
   |  Bind the variables in the where clause |
   +-----------------------------------------*/

   dbms_sql.bind_variable(p_update_cursor, ':where_1',
                          p_where1);

   l_count := dbms_sql.execute(p_update_cursor);

   arp_util.debug( to_char(l_count) || ' rows updated');

   /*------------------------------------------+
    | get RETURNING COLUMN into OUT NOCOPY bind array |
    +------------------------------------------*/

    dbms_sql.variable_value( p_update_cursor, ':ra_batch_key_value',
                             ra_batch_array);


   /*------------------------------------------------------------+
    |  Raise the NO_DATA_FOUND exception if no rows were updated |
    +------------------------------------------------------------*/

   IF    (l_count = 0)
   THEN  RAISE NO_DATA_FOUND;
   END IF;

--{BUG#4301323
--    FOR I in ra_batch_array.FIRST..ra_batch_array.LAST LOOP
       /*---------------------------------------------+
        | call mrc engine to update RA_MC_BATCHES     |
        +---------------------------------------------*/
--       ar_mrc_engine.maintain_mrc_data(
--                        p_event_mode       => 'UPDATE',
--                        p_table_name       => 'RA_BATCHES',
--                        p_mode             => 'SINGLE',
--                        p_key_value        => ra_batch_array(I));
--   END LOOP;
--}

   arp_util.debug('arp_tbat_pkg.generic_update()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_tbat_pkg.generic_update()');
        arp_util.debug(l_update_statement);
        arp_util.debug('Error at character: ' ||
                           to_char(dbms_sql.last_error_position));
        RAISE;
END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    set_to_dummy							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure initializes all columns in the parameter batch record   |
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
 |                    p_batch_rec   - The record to initialize		     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     06-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 | 20-MAR-2000  J Rautiainen    Added BR project related columns             |
 |                              ISSUE_DATE, MATURITY_DATE,                   |
 |                              SPECIAL_INSTRUCTIONS, BATCH_PROCESS_STATUS   |
 |                              and SELECTION_CRITERIA_ID into table handlers|
 |                                                                           |
 | 31-OCT-2000 Y Rakotonirainy  Bug 1243304 : Added column 		     |
 |					      purged_children_flag and	     |
 |					      request_id 		     |
 | 				      	      into the table handlers. 	     |
 |                                                                           |
 +===========================================================================*/

PROCEDURE set_to_dummy( p_batch_rec OUT NOCOPY ra_batches%rowtype) IS

BEGIN

    arp_util.debug('arp_tbat_pkg.set_to_dummy()+');

    p_batch_rec.batch_id 		:= AR_NUMBER_DUMMY;
    p_batch_rec.last_update_date 	:= AR_DATE_DUMMY;
    p_batch_rec.last_updated_by 	:= AR_NUMBER_DUMMY;
    p_batch_rec.creation_date 		:= AR_DATE_DUMMY;
    p_batch_rec.created_by 		:= AR_NUMBER_DUMMY;
    p_batch_rec.last_update_login 	:= AR_NUMBER_DUMMY;
    p_batch_rec.program_application_id 	:= AR_NUMBER_DUMMY;
    p_batch_rec.program_id 		:= AR_NUMBER_DUMMY;
    p_batch_rec.program_update_date 	:= AR_DATE_DUMMY;
    p_batch_rec.set_of_books_id 	:= AR_NUMBER_DUMMY;
    p_batch_rec.name 			:= AR_TEXT_DUMMY;
    p_batch_rec.batch_source_id 	:= AR_NUMBER_DUMMY;
    p_batch_rec.batch_date 		:= AR_DATE_DUMMY;
    p_batch_rec.gl_date 		:= AR_DATE_DUMMY;
    p_batch_rec.status 			:= AR_TEXT_DUMMY;
    p_batch_rec.type 			:= AR_TEXT_DUMMY;
    p_batch_rec.control_count 		:= AR_NUMBER_DUMMY;
    p_batch_rec.control_amount 		:= AR_NUMBER_DUMMY;
    p_batch_rec.comments 		:= AR_TEXT_DUMMY;
    p_batch_rec.currency_code 		:= AR_TEXT_DUMMY;
    p_batch_rec.exchange_rate_type 	:= AR_TEXT_DUMMY;
    p_batch_rec.exchange_date 		:= AR_DATE_DUMMY;
    p_batch_rec.exchange_rate 		:= AR_NUMBER_DUMMY;
    p_batch_rec.purged_children_flag	:= AR_FLAG_DUMMY;
    p_batch_rec.attribute_category 	:= AR_TEXT_DUMMY;
    p_batch_rec.attribute1 		:= AR_TEXT_DUMMY;
    p_batch_rec.attribute2 		:= AR_TEXT_DUMMY;
    p_batch_rec.attribute3 		:= AR_TEXT_DUMMY;
    p_batch_rec.attribute4 		:= AR_TEXT_DUMMY;
    p_batch_rec.attribute5 		:= AR_TEXT_DUMMY;
    p_batch_rec.attribute6 		:= AR_TEXT_DUMMY;
    p_batch_rec.attribute7 		:= AR_TEXT_DUMMY;
    p_batch_rec.attribute8 		:= AR_TEXT_DUMMY;
    p_batch_rec.attribute9 		:= AR_TEXT_DUMMY;
    p_batch_rec.attribute10		:= AR_TEXT_DUMMY;
    p_batch_rec.attribute11 		:= AR_TEXT_DUMMY;
    p_batch_rec.attribute12 		:= AR_TEXT_DUMMY;
    p_batch_rec.attribute13 		:= AR_TEXT_DUMMY;
    p_batch_rec.attribute14 		:= AR_TEXT_DUMMY;
    p_batch_rec.attribute15 		:= AR_TEXT_DUMMY;
    p_batch_rec.issue_date              := AR_DATE_DUMMY;
    p_batch_rec.maturity_date           := AR_DATE_DUMMY;
    p_batch_rec.special_instructions    := AR_TEXT_DUMMY;
    p_batch_rec.batch_process_status    := AR_TEXT_DUMMY;
    p_batch_rec.selection_criteria_id   := AR_NUMBER_DUMMY;
    p_batch_rec.request_id		:= AR_NUMBER_DUMMY;

    arp_util.debug('arp_tbat_pkg.set_to_dummy()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_tbat_pkg.set_to_dummy()');
        RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    fetch_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure fetches a single row from ra_batches into a variable    |
 |    specified as a parameter based on the table's primary key, batch_id.   |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_batch_id	- identifies the record to fetch     |
 |              OUT:                                                         |
 |                    p_batch_rec	- contains the fetched record	     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     06-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE fetch_p( p_batch_rec  OUT NOCOPY ra_batches%rowtype,
                   p_batch_id    IN ra_batches.batch_id%type ) IS

BEGIN
    arp_util.debug('arp_tbat_pkg.fetch_p()+');

    SELECT *
    INTO   p_batch_rec
    FROM   ra_batches
    WHERE  batch_id = p_batch_id;

    arp_util.debug('arp_tbat_pkg.fetch_p()-');

    EXCEPTION
        WHEN  OTHERS THEN
            arp_util.debug('EXCEPTION: arp_tbat_pkg.fetch_p' );
            RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ra_batches row identified by the p_batch_id   |
 |    parameter.							     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_batch_id	- identifies the row to lock	     |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     06-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_p( p_batch_id    IN ra_batches.batch_id%type ) IS

  l_batch_id            ra_batches.batch_id%type;

BEGIN
    arp_util.debug('arp_tbat_pkg.lock_p()+');

    SELECT        batch_id
    INTO          l_batch_id
    FROM          ra_batches
    WHERE         batch_id = p_batch_id
    FOR UPDATE OF batch_id NOWAIT;

    arp_util.debug('arp_tbat_pkg.lock_p()-');

    EXCEPTION
        WHEN  OTHERS THEN
            arp_util.debug( 'EXCEPTION: arp_tbat_pkg.lock_p' );
            RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_fetch_p							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ra_batches row identified by the p_batch_id   |
 |    parameter and populates the p_batch_rec parameter with the row that    |
 |    was locked.							     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_batch_id	- identifies the row to lock	     |
 |              OUT:                                                         |
 |                    p_batch_rec	- contains the locked row	     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     06-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_fetch_p( p_batch_rec IN OUT NOCOPY ra_batches%rowtype,
                        p_batch_id  IN     ra_batches.batch_id%type ) IS

BEGIN
    arp_util.debug('arp_tbat_pkg.lock_fetch_p()+');

    SELECT *
    INTO   p_batch_rec
    FROM   ra_batches
    WHERE batch_id = p_batch_id
    FOR UPDATE OF batch_id NOWAIT;

    arp_util.debug('arp_tbat_pkg.lock_fetch_p()-');

    EXCEPTION
        WHEN  OTHERS THEN
            arp_util.debug( 'EXCEPTION: arp_tbat_pkg.lock_fetch_p' );
            RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_compare_p							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ra_batches row identified by the p_batch_id   |
 |    parameter only if no columns in that row have changed from when they   |
 |    were first selected in the form.					     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_batch_id	- identifies the row to lock	     |
 | 		      p_batch_rec	- batch record for comparison	     |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     06-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 | 20-MAR-2000  J Rautiainen    Added BR project related columns             |
 |                              ISSUE_DATE, MATURITY_DATE,                   |
 |                              SPECIAL_INSTRUCTIONS, BATCH_PROCESS_STATUS   |
 |                              and SELECTION_CRITERIA_ID into table handlers|
 |                                                                           |
 | 31-OCT-2000 Y Rakotonirainy  Bug 1243304 : Added columns 		     |
 |					      purged_children_flag and       |
 |					      request_id     		     |
 | 				      	      into the table handlers.       |
 |                                                                           |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_compare_p( p_batch_rec IN ra_batches%rowtype,
                          p_batch_id  IN ra_batches.batch_id%type ) IS

    l_new_batch_rec  ra_batches%rowtype;

BEGIN
    arp_util.debug('arp_tbat_pkg.lock_compare_p()+');

    SELECT        *
    INTO          l_new_batch_rec
    FROM          ra_batches tbat
    WHERE         tbat.batch_id = p_batch_id
    AND NOT
       (
           NVL(tbat.name, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.name,
                        AR_TEXT_DUMMY, tbat.name,
                                         p_batch_rec.name),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(tbat.batch_id, AR_NUMBER_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.batch_id,
                        AR_NUMBER_DUMMY, tbat.batch_id,
                                         p_batch_rec.batch_id),
                 AR_NUMBER_DUMMY
              )
         OR
           NVL(tbat.last_update_date, AR_DATE_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.last_update_date,
                        AR_DATE_DUMMY, tbat.last_update_date,
                                         p_batch_rec.last_update_date),
                 AR_DATE_DUMMY
              )
         OR
           NVL(tbat.last_updated_by, AR_NUMBER_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.last_updated_by,
                        AR_NUMBER_DUMMY, tbat.last_updated_by,
                                         p_batch_rec.last_updated_by),
                 AR_NUMBER_DUMMY
              )
         OR
           NVL(tbat.creation_date, AR_DATE_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.creation_date,
                        AR_DATE_DUMMY, tbat.creation_date,
                                         p_batch_rec.creation_date),
                 AR_DATE_DUMMY
              )
         OR
           NVL(tbat.created_by, AR_NUMBER_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.created_by,
                        AR_NUMBER_DUMMY, tbat.created_by,
                                         p_batch_rec.created_by),
                 AR_NUMBER_DUMMY
              )
         OR
           NVL(tbat.last_update_login, AR_NUMBER_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.last_update_login,
                        AR_NUMBER_DUMMY, tbat.last_update_login,
                                         p_batch_rec.last_update_login),
                 AR_NUMBER_DUMMY
              )
         OR
           NVL(tbat.program_application_id, AR_NUMBER_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.program_application_id,
                        AR_NUMBER_DUMMY, tbat.program_application_id,
                                         p_batch_rec.program_application_id),
                 AR_NUMBER_DUMMY
              )
         OR
           NVL(tbat.program_id, AR_NUMBER_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.program_id,
                        AR_NUMBER_DUMMY, tbat.program_id,
                                         p_batch_rec.program_id),
                 AR_NUMBER_DUMMY
              )
         OR
           NVL(tbat.program_update_date, AR_DATE_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.program_update_date,
                        AR_DATE_DUMMY, tbat.program_update_date,
                                         p_batch_rec.program_update_date),
                 AR_DATE_DUMMY
              )
         OR
           NVL(tbat.set_of_books_id, AR_NUMBER_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.set_of_books_id,
                        AR_NUMBER_DUMMY, tbat.set_of_books_id,
                                         p_batch_rec.set_of_books_id),
                 AR_NUMBER_DUMMY
              )
         OR
           NVL(tbat.batch_source_id, AR_NUMBER_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.batch_source_id,
                        AR_NUMBER_DUMMY, tbat.batch_source_id,
                                         p_batch_rec.batch_source_id),
                 AR_NUMBER_DUMMY
              )
         OR
           NVL(trunc(tbat.batch_date), AR_DATE_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.batch_date,
                        AR_DATE_DUMMY, trunc(tbat.batch_date),
                                         p_batch_rec.batch_date),
                 AR_DATE_DUMMY
              )
         OR
           NVL(trunc(tbat.gl_date), AR_DATE_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.gl_date,
                        AR_DATE_DUMMY, trunc(tbat.gl_date),
                                         p_batch_rec.gl_date),
                 AR_DATE_DUMMY
              )
         OR
           NVL(tbat.status, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.status,
                        AR_TEXT_DUMMY, tbat.status,
                                         p_batch_rec.status),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(tbat.type, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.type,
                        AR_TEXT_DUMMY, tbat.type,
                                         p_batch_rec.type),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(tbat.control_count, AR_NUMBER_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.control_count,
                        AR_NUMBER_DUMMY, tbat.control_count,
                                         p_batch_rec.control_count),
                 AR_NUMBER_DUMMY
              )
         OR
           NVL(tbat.control_amount, AR_NUMBER_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.control_amount,
                        AR_NUMBER_DUMMY, tbat.control_amount,
                                         p_batch_rec.control_amount),
                 AR_NUMBER_DUMMY
              )
         OR
           NVL(tbat.comments, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.comments,
                        AR_TEXT_DUMMY, tbat.comments,
                                         p_batch_rec.comments),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(tbat.currency_code, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.currency_code,
                        AR_TEXT_DUMMY, tbat.currency_code,
                                         p_batch_rec.currency_code),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(tbat.exchange_rate_type, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.exchange_rate_type,
                        AR_TEXT_DUMMY, tbat.exchange_rate_type,
                                         p_batch_rec.exchange_rate_type),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(tbat.exchange_date, AR_DATE_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.exchange_date,
                        AR_DATE_DUMMY, tbat.exchange_date,
                                         p_batch_rec.exchange_date),
                 AR_DATE_DUMMY
              )
         OR
           NVL(tbat.exchange_rate, AR_NUMBER_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.exchange_rate,
                        AR_NUMBER_DUMMY, tbat.exchange_rate,
                                         p_batch_rec.exchange_rate),
                 AR_NUMBER_DUMMY
              )
         OR
           NVL(tbat.purged_children_flag, AR_FLAG_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.purged_children_flag,
                        AR_FLAG_DUMMY, tbat.purged_children_flag,
                                         p_batch_rec.purged_children_flag),
                 AR_FLAG_DUMMY
              )
         OR
           NVL(tbat.attribute_category, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.attribute_category,
                        AR_TEXT_DUMMY, tbat.attribute_category,
                                         p_batch_rec.attribute_category),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(tbat.attribute1, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.attribute1,
                        AR_TEXT_DUMMY, tbat.attribute1,
                                         p_batch_rec.attribute1),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(tbat.attribute2, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.attribute2,
                        AR_TEXT_DUMMY, tbat.attribute2,
                                         p_batch_rec.attribute2),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(tbat.attribute3, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.attribute3,
                        AR_TEXT_DUMMY, tbat.attribute3,
                                         p_batch_rec.attribute3),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(tbat.attribute4, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.attribute4,
                        AR_TEXT_DUMMY, tbat.attribute4,
                                         p_batch_rec.attribute4),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(tbat.attribute5, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.attribute5,
                        AR_TEXT_DUMMY, tbat.attribute5,
                                         p_batch_rec.attribute5),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(tbat.attribute6, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.attribute6,
                        AR_TEXT_DUMMY, tbat.attribute6,
                                         p_batch_rec.attribute6),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(tbat.attribute7, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.attribute7,
                        AR_TEXT_DUMMY, tbat.attribute7,
                                         p_batch_rec.attribute7),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(tbat.attribute8, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.attribute8,
                        AR_TEXT_DUMMY, tbat.attribute8,
                                         p_batch_rec.attribute8),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(tbat.attribute9, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.attribute9,
                        AR_TEXT_DUMMY, tbat.attribute9,
                                         p_batch_rec.attribute9),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(tbat.attribute10, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.attribute10,
                        AR_TEXT_DUMMY, tbat.attribute10,
                                         p_batch_rec.attribute10),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(tbat.attribute11, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.attribute11,
                        AR_TEXT_DUMMY, tbat.attribute11,
                                         p_batch_rec.attribute11),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(tbat.attribute12, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.attribute12,
                        AR_TEXT_DUMMY, tbat.attribute12,
                                         p_batch_rec.attribute12),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(tbat.attribute13, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.attribute13,
                        AR_TEXT_DUMMY, tbat.attribute13,
                                         p_batch_rec.attribute13),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(tbat.attribute14, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.attribute14,
                        AR_TEXT_DUMMY, tbat.attribute14,
                                         p_batch_rec.attribute14),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(tbat.attribute15, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.attribute15,
                        AR_TEXT_DUMMY, tbat.attribute15,
                                         p_batch_rec.attribute15),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(tbat.issue_date, AR_DATE_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.issue_date,
                        AR_DATE_DUMMY, tbat.issue_date,
                                       p_batch_rec.issue_date),
                 AR_DATE_DUMMY
              )
         OR
           NVL(tbat.maturity_date, AR_DATE_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.maturity_date,
                        AR_DATE_DUMMY, tbat.maturity_date,
                                       p_batch_rec.maturity_date),
                 AR_DATE_DUMMY
              )
         OR
           NVL(tbat.special_instructions, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.special_instructions,
                        AR_TEXT_DUMMY, tbat.special_instructions,
                                       p_batch_rec.special_instructions),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(tbat.batch_process_status, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.batch_process_status,
                        AR_TEXT_DUMMY, tbat.batch_process_status,
                                       p_batch_rec.batch_process_status),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(tbat.selection_criteria_id, AR_NUMBER_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.selection_criteria_id,
                        AR_NUMBER_DUMMY, tbat.selection_criteria_id,
                                       p_batch_rec.selection_criteria_id),
                 AR_NUMBER_DUMMY
              )
         OR
           NVL(tbat.request_id, AR_NUMBER_DUMMY) <>
           NVL(
                 DECODE(p_batch_rec.request_id,
                        AR_NUMBER_DUMMY, tbat.request_id,
                                         p_batch_rec.request_id),
                 AR_NUMBER_DUMMY
              )
       )
    FOR UPDATE OF batch_id NOWAIT;

    arp_util.debug('arp_tbat_pkg.lock_compare_p()-');

    EXCEPTION
        WHEN  OTHERS THEN
            arp_util.debug( 'EXCEPTION: arp_tbat_pkg.lock_compare_p' );
            RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_compare_cover                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Cover for calling the batch table handler lock_compare_p               |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_form_name                                            |
 |                    p_form_version                                         |
 |                    p_batch_id                                             |
 |                    p_name                                                 |
 |                    p_batch_source_id                                      |
 |                    p_batch_date                                           |
 |                    p_gl_date                                              |
 |                    p_status                                               |
 |                    p_type                                                 |
 |                    p_currency_code                                        |
 |                    p_exchange_rate_type                                   |
 |                    p_exchange_date                                        |
 |                    p_exchange_rate                                        |
 |                    p_control_count                                        |
 |                    p_control_amount                                       |
 |                    p_comments                                             |
 |                    p_set_of_books_id                                      |
 |                    p_purged_children_flag                                 |
 |                    p_attribute_category                                   |
 |                    p_attribute1 - 15                                      |
 |              OUT:                                                         |
 |                    None                                                   |
 |          IN  OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     10-NOV-95  Subash C            Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_compare_cover(
  p_form_name              IN varchar2,
  p_form_version           IN number,
  p_batch_id               IN ra_batches.batch_id%type,
  p_name                   IN ra_batches.name%type,
  p_batch_source_id        IN ra_batches.batch_source_id%type,
  p_batch_date             IN ra_batches.batch_date%type,
  p_gl_date                IN ra_batches.gl_date%type,
  p_status                 IN ra_batches.status%type,
  p_type                   IN ra_batches.type%type,
  p_currency_code          IN ra_batches.currency_code%type,
  p_exchange_rate_type     IN ra_batches.exchange_rate_type%type,
  p_exchange_date          IN ra_batches.exchange_date%type,
  p_exchange_rate          IN ra_batches.exchange_rate%type,
  p_control_count          IN ra_batches.control_count%type,
  p_control_amount         IN ra_batches.control_amount%type,
  p_comments               IN ra_batches.comments%type,
  p_set_of_books_id        IN ra_batches.set_of_books_id%type,
  p_purged_children_flag   IN ra_batches.purged_children_flag%type,
  p_attribute_category     IN ra_batches.attribute_category%type,
  p_attribute1             IN ra_batches.attribute1%type,
  p_attribute2             IN ra_batches.attribute2%type,
  p_attribute3             IN ra_batches.attribute3%type,
  p_attribute4             IN ra_batches.attribute4%type,
  p_attribute5             IN ra_batches.attribute5%type,
  p_attribute6             IN ra_batches.attribute6%type,
  p_attribute7             IN ra_batches.attribute7%type,
  p_attribute8             IN ra_batches.attribute8%type,
  p_attribute9             IN ra_batches.attribute9%type,
  p_attribute10            IN ra_batches.attribute10%type,
  p_attribute11            IN ra_batches.attribute11%type,
  p_attribute12            IN ra_batches.attribute12%type,
  p_attribute13            IN ra_batches.attribute13%type,
  p_attribute14            IN ra_batches.attribute14%type,
  p_attribute15            IN ra_batches.attribute15%type)
IS
  l_batch_rec        ra_batches%rowtype;
BEGIN
    arp_util.debug('arp_tbat_pkg.lock_compare_cover()+');

    arp_tbat_pkg.set_to_dummy(l_batch_rec);

    l_batch_rec.batch_id             := p_batch_id;
    l_batch_rec.name                 := p_name;
    l_batch_rec.batch_source_id      := p_batch_source_id;
    l_batch_rec.batch_date           := trunc(p_batch_date);
    l_batch_rec.gl_date              := trunc(p_gl_date);
    l_batch_rec.status               := p_status;
    l_batch_rec.type                 := p_type;
    l_batch_rec.currency_code        := p_currency_code;
    l_batch_rec.exchange_rate_type   := p_exchange_rate_type;
    l_batch_rec.exchange_date        := p_exchange_date;
    l_batch_rec.exchange_rate        := p_exchange_rate;
    l_batch_rec.control_count        := p_control_count;
    l_batch_rec.control_amount       := p_control_amount;
    l_batch_rec.comments             := p_comments;
    l_batch_rec.set_of_books_id      := p_set_of_books_id;
    l_batch_rec.purged_children_flag := p_purged_children_flag;
    l_batch_rec.attribute_category   := p_attribute_category;
    l_batch_rec.attribute1           := p_attribute1;
    l_batch_rec.attribute2           := p_attribute2;
    l_batch_rec.attribute3           := p_attribute3;
    l_batch_rec.attribute4           := p_attribute4;
    l_batch_rec.attribute5           := p_attribute5;
    l_batch_rec.attribute6           := p_attribute6;
    l_batch_rec.attribute7           := p_attribute7;
    l_batch_rec.attribute8           := p_attribute8;
    l_batch_rec.attribute9           := p_attribute9;
    l_batch_rec.attribute10          := p_attribute10;
    l_batch_rec.attribute11          := p_attribute11;
    l_batch_rec.attribute12          := p_attribute12;
    l_batch_rec.attribute13          := p_attribute13;
    l_batch_rec.attribute14          := p_attribute14;
    l_batch_rec.attribute15          := p_attribute15;


    arp_tbat_pkg.lock_compare_p(l_batch_rec,
                                p_batch_id);

    arp_util.debug('arp_tbat_pkg.lock_compare_cover()-');

EXCEPTION
  WHEN OTHERS THEN
    arp_util.debug('EXCEPTION : arp_tbat_pkg.lock_compare_cover');
    arp_util.debug('p_batch_id             : '||p_batch_id);
    arp_util.debug('p_name                 : '||p_name);
    arp_util.debug('p_batch_source_id      : '||p_batch_source_id);
    arp_util.debug('p_batch_date           : '||p_batch_date);
    arp_util.debug('p_gl_date              : '||p_gl_date);
    arp_util.debug('p_status               : '||p_status);
    arp_util.debug('p_type                 : '||p_type);
    arp_util.debug('p_currency_code        : '||p_currency_code);
    arp_util.debug('p_exchange_rate_type   : '||p_exchange_rate_type);
    arp_util.debug('p_exchange_date        : '||p_exchange_date);
    arp_util.debug('p_exchange_rate        : '||p_exchange_rate);
    arp_util.debug('p_control_count        : '||p_control_count);
    arp_util.debug('p_control_amount       : '||p_control_amount);
    arp_util.debug('p_comments             : '||p_comments);
    arp_util.debug('p_set_of_books_id      : '||p_set_of_books_id);
    arp_util.debug('p_purged_children_flag : '||p_purged_children_flag);
    arp_util.debug('p_attribute_category   : '||p_attribute_category);
    arp_util.debug('p_attribute1           : '||p_attribute1);
    arp_util.debug('p_attribute2           : '||p_attribute2);
    arp_util.debug('p_attribute3           : '||p_attribute3);
    arp_util.debug('p_attribute4           : '||p_attribute4);
    arp_util.debug('p_attribute5           : '||p_attribute5);
    arp_util.debug('p_attribute6           : '||p_attribute6);
    arp_util.debug('p_attribute7           : '||p_attribute7);
    arp_util.debug('p_attribute8           : '||p_attribute8);
    arp_util.debug('p_attribute9           : '||p_attribute9);
    arp_util.debug('p_attribute10          : '||p_attribute10);
    arp_util.debug('p_attribute11          : '||p_attribute11);
    arp_util.debug('p_attribute12          : '||p_attribute12);
    arp_util.debug('p_attribute13          : '||p_attribute13);
    arp_util.debug('p_attribute14          : '||p_attribute14);
    arp_util.debug('p_attribute15          : '||p_attribute15);

    RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure deletes the ra_batches row identified by the p_batch_id |
 |    parameter.							     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_batch_id	- identifies the row to delete	     |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     06-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

procedure delete_p( p_batch_id  IN ra_batches.batch_id%type) IS

   l_count  number;

BEGIN

   arp_util.debug('arp_tbat_pkg.delete_p()+');

 /*-----------------------------------------------------+
  |  Determine the number of transactions in the batch. |
  |  The procedure only deletes batches that do not 	|
  |  contain any transactions 				|
  +-----------------------------------------------------*/

   SELECT count(*)
   INTO   l_count
   FROM   ra_customer_trx
   WHERE  batch_id = p_batch_id;

   IF (l_count = 0)
   THEN
          delete FROM ra_batches
          where       batch_id = p_batch_id;
		/*---------------------------------+
  		|  Calling central MRC library     |
  		|  for MRC integration             |
  		+----------------------------------*/
--{BUG#4301323
--		ar_mrc_engine.maintain_mrc_data(
--             		p_event_mode        => 'DELETE',
--             		p_table_name        => 'RA_BATCHES',
--             		p_mode              => 'SINGLE',
--             		p_key_value         => p_batch_id );
--}
   ELSE
          fnd_message.set_name('AR', '250');
          app_exception.raise_exception;
   END IF;

   arp_util.debug('arp_tbat_pkg.delete_p()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_tbat_pkg.delete_p()');
        RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_f_bs_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure deletes the ra_batches rows identified by the           |
 |    p_batch_source_id parameter.					     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_batch_source_id	- identifies the rows to delete	     |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     06-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

procedure delete_f_bs_id( p_batch_source_id IN
                             ra_batches.batch_source_id%type) IS

   l_count  number;

BEGIN

   arp_util.debug('arp_tbat_pkg.delete_f_bs_id()+');

 /*-----------------------------------------------------+
  |  Determine the number of transactions in the batch. |
  |  The procedure only deletes batches that do not 	|
  |  contain any transactions 				|
  +-----------------------------------------------------*/

   SELECT count(*)
   INTO   l_count
   FROM   ra_customer_trx
   WHERE  batch_source_id = p_batch_source_id;

   IF (l_count = 0)
   THEN
          DELETE FROM ra_batches
          WHERE       batch_id = p_batch_source_id;
		/*---------------------------------+
  		|  Calling central MRC library     |
  		|  for MRC integration             |
  		+----------------------------------*/
--{BUG4301323
--		ar_mrc_engine.maintain_mrc_data(
--             		p_event_mode        => 'DELETE',
--             		p_table_name        => 'RA_BATCHES',
--             		p_mode              => 'SINGLE',
--             		p_key_value         => p_batch_source_id );
--}
   ELSE
          fnd_message.set_name('AR', '250');
          app_exception.raise_exception;
   END IF;

   arp_util.debug('arp_tbat_pkg.delete_f_bs_id()-');

EXCEPTION
    WHEN OTHERS THEN

        arp_util.debug('EXCEPTION:  arp_tbat_pkg.delete_f_bs_id()');
        RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure updates the ra_batches row identified by the p_batch_id |
 |    parameter.							     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_batch_id	- identifies the row to update	     |
 |                    p_batch_rec       - contains the new column values     |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |     set_to_dummy must be called before the values in p_batch_rec are      |
 |     changed and this function is called.				     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     06-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE update_p( p_batch_rec IN ra_batches%rowtype,
                    p_batch_id  IN ra_batches.batch_id%type) IS


BEGIN

   arp_util.debug('arp_tbat_pkg.update_p()+');

   arp_tbat_pkg.generic_update( pg_cursor1,
                                ' WHERE batch_id = :where_1',
                                p_batch_id,
                                p_batch_rec);

   arp_util.debug('arp_tbat_pkg.update_p()-');


EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_tbat_pkg.update_p()');
        RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_f_bs_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure updates the ra_batches rows that are contained in a     |
 |    particular batch source.						     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_batch_source_id	- identifies the rows to delete	     |
 |                    p_batch_rec       - contains the new column values     |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |     set_to_dummy must be called before the values in p_batch_rec are      |
 |     changed and this function is called.				     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     06-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE update_f_bs_id( p_batch_rec IN ra_batches%rowtype,
                          p_batch_source_id
                                IN ra_batch_sources.batch_source_id%type) IS


BEGIN

   arp_util.debug('arp_tbat_pkg.update_f_bs_id()+');

   arp_tbat_pkg.generic_update( pg_cursor2,
                                ' WHERE batch_source_id = :where_1',
                                p_batch_source_id,
                                p_batch_rec);

   arp_util.debug('arp_tbat_pkg.update_f_bs_id()-');


EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_tbat_pkg.update_f_bs_id()');
        RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure inserts a row into ra_batches that contains the column  |
 |    values specified in the p_batch_rec parameter. 			     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug   							     |
 |    arp_global.set_of_books_id					     |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_batch_rec       - contains the new column values     |
 |              OUT:                                                         |
 |                    p_batch_id	- unique ID of the new row           |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     06-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 | 20-MAR-2000  J Rautiainen    Added BR project related columns             |
 |                              ISSUE_DATE, MATURITY_DATE,                   |
 |                              SPECIAL_INSTRUCTIONS, BATCH_PROCESS_STATUS   |
 |                              and SELECTION_CRITERIA_ID into table handlers|
 |                                                                           |
 | 31-OCT-2000 Y Rakotonirainy  Bug 1243304 : Added column 		     |
 |					      purged_children_flag and	     |
 |					      request_id 		     |
 | 				      	      into the table handlers. 	     |
 |                                                                           |
 +===========================================================================*/

PROCEDURE insert_p(
                    p_batch_rec  IN  ra_batches%rowtype,
                    p_batch_id   OUT NOCOPY ra_batches.batch_id%type,
                    p_name       OUT NOCOPY ra_batches.name%type
                  ) IS


    l_batch_id    ra_batches.batch_id%type;
    l_batch_name  ra_batches.name%type;
    l_ra_batches_value_list      gl_ca_utility_pkg.r_key_value_arr; /* MRC */

 BEGIN

    arp_util.debug('arp_tbat_pkg.insert_p()+');

    p_batch_id := '';

    /*---------------------------*
     | Get the unique identifier |
     *---------------------------*/

    SELECT RA_BATCHES_S.NEXTVAL
    INTO   l_batch_id
    FROM   DUAL;

    /*-----------------------------------------------------------------*
     | Get the batch name if the source uses automatic batch numbering |
     *-----------------------------------------------------------------*/

    IF (p_batch_rec.name is null)
    THEN
         SELECT        to_char(last_batch_num + 1)
         INTO          l_batch_name
         FROM          ra_batch_sources
         WHERE         batch_source_id = p_batch_rec.batch_source_id
         AND           auto_batch_numbering_flag = 'Y'
         FOR UPDATE OF last_batch_num NOWAIT;

         UPDATE ra_batch_sources
         SET    last_batch_num = l_batch_name
         WHERE  batch_source_id = p_batch_rec.batch_source_id;
    ELSE
         l_batch_name := p_batch_rec.name;
    END IF;

    p_name := l_batch_name;

    /*-------------------*
     | Insert the record |
     *-------------------*/

   INSERT INTO ra_batches
               (
                 batch_id,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by,
                 last_update_login,
                 program_application_id,
                 program_id,
                 program_update_date,
                 set_of_books_id,
                 name,
                 batch_source_id,
                 batch_date,
                 gl_date,
                 status,
                 type,
                 control_count,
                 control_amount,
                 comments,
                 currency_code,
                 exchange_rate_type,
                 exchange_date,
                 exchange_rate,
                 purged_children_flag,
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
                 issue_date,
                 maturity_date,
                 special_instructions,
                 batch_process_status,
                 selection_criteria_id,
                 request_id
                 ,org_id
               )
             VALUES
               (
                 l_batch_id,			/* batch_id */
                 sysdate,			/* last_update_date */
                 pg_user_id,			/* last_updated_by */
                 sysdate,			/* creation_date */
                 pg_user_id,			/* created_by */
                 nvl(pg_conc_login_id,
                     pg_login_id),		/* last_update_login */
                 pg_prog_appl_id,		/* program_application_id */
                 pg_conc_program_id,		/* program_id */
                 sysdate,			/* program_update_date */
                 arp_global.set_of_books_id,	/* set_of_books_id */
                 l_batch_name,			/* name */
                 p_batch_rec.batch_source_id,	/* batch_source_id */
                 p_batch_rec.batch_date,	/* batch_date */
                 p_batch_rec.gl_date,		/* gl_date */
                 p_batch_rec.status,		/* status */
                 p_batch_rec.type,		/* type */
                 p_batch_rec.control_count,	/* control_count */
                 p_batch_rec.control_amount,	/* control_amount */
                 p_batch_rec.comments,		/* comments */
                 p_batch_rec.currency_code,	/* currency_code */
                 p_batch_rec.exchange_rate_type, /* exchange_rate_type */
                 p_batch_rec.exchange_date,	/* exchange_date */
                 p_batch_rec.exchange_rate,	/* exchange_rate */
                 p_batch_rec.purged_children_flag,/*purged_children_flag*/
                 p_batch_rec.attribute_category, /* attribute_category */
                 p_batch_rec.attribute1,	/* attribute1 */
                 p_batch_rec.attribute2,	/* attribute2 */
                 p_batch_rec.attribute3,	/* attribute3 */
                 p_batch_rec.attribute4,	/* attribute4 */
                 p_batch_rec.attribute5,	/* attribute5 */
                 p_batch_rec.attribute6,	/* attribute6 */
                 p_batch_rec.attribute7,	/* attribute7 */
                 p_batch_rec.attribute8,	/* attribute8 */
                 p_batch_rec.attribute9,	/* attribute9 */
                 p_batch_rec.attribute10,	/* attribute10 */
                 p_batch_rec.attribute11,	/* attribute11 */
                 p_batch_rec.attribute12,	/* attribute12 */
                 p_batch_rec.attribute13,	/* attribute13 */
                 p_batch_rec.attribute14,	/* attribute14 */
                 p_batch_rec.attribute15,	/* attribute15 */
                 p_batch_rec.issue_date,
                 p_batch_rec.maturity_date,
                 p_batch_rec.special_instructions,
                 p_batch_rec.batch_process_status,
                 p_batch_rec.selection_criteria_id,
                 p_batch_rec.request_id		/*request_id*/
                 ,arp_standard.sysparm.org_id /* SSA changes anuj */
               );

   p_batch_id := l_batch_id;

		/*---------------------------------+
                |  Calling central MRC library     |
                |  for MRC integration             |
                +----------------------------------*/
--{BUG4301323
--                ar_mrc_engine.maintain_mrc_data(
--                        p_event_mode        => 'INSERT',
--                        p_table_name        => 'RA_BATCHES',
--                        p_mode              => 'SINGLE',
--                        p_key_value         => l_batch_id);
--}
   arp_util.debug('arp_tbat_pkg.insert_p()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_tbat_pkg.insert_p()');
	RAISE;
END;


  /*---------------------------------------------+
   |   Package initialization section.           |
   |   Sets WHO column variables for later use.  |
   +---------------------------------------------*/

BEGIN

  pg_user_id          := fnd_global.user_id;
  pg_conc_login_id    := fnd_global.conc_login_id;
  pg_login_id         := fnd_global.login_id;
  pg_prog_appl_id     := fnd_global.prog_appl_id;
  pg_conc_program_id  := fnd_global.conc_program_id;


END ARP_TBAT_PKG;

/
