--------------------------------------------------------
--  DDL for Package Body ARP_AAH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_AAH_PKG" AS
/* $Header: ARTIAAHB.pls 120.5 2005/10/30 04:27:15 appldev ship $ */

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
 |    bind_aah_variables                                                     |
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
 |                    p_aah_rec       - ar_approval_action_history record    |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/


PROCEDURE bind_aah_variables(p_update_cursor IN integer,
                             p_aah_rec IN ar_approval_action_history%rowtype)
          IS

BEGIN

   arp_util.debug('arp_aah_pkg.bind_aah_variables()+');

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


   dbms_sql.bind_variable(p_update_cursor, ':approval_action_history_id',
                          p_aah_rec.approval_action_history_id);

   dbms_sql.bind_variable(p_update_cursor, ':approval_action_history_id',
                          p_aah_rec.approval_action_history_id);

   dbms_sql.bind_variable(p_update_cursor, ':action_name',
                          p_aah_rec.action_name);

   dbms_sql.bind_variable(p_update_cursor, ':adjustment_id',
                          p_aah_rec.adjustment_id);

   dbms_sql.bind_variable(p_update_cursor, ':action_date',
                          p_aah_rec.action_date);

   dbms_sql.bind_variable(p_update_cursor, ':comments',
                          p_aah_rec.comments);

   dbms_sql.bind_variable(p_update_cursor, ':attribute_category',
                          p_aah_rec.attribute_category);

   dbms_sql.bind_variable(p_update_cursor, ':attribute1',
                          p_aah_rec.attribute1);

   dbms_sql.bind_variable(p_update_cursor, ':attribute2',
                          p_aah_rec.attribute2);

   dbms_sql.bind_variable(p_update_cursor, ':attribute3',
                          p_aah_rec.attribute3);

   dbms_sql.bind_variable(p_update_cursor, ':attribute4',
                          p_aah_rec.attribute4);

   dbms_sql.bind_variable(p_update_cursor, ':attribute5',
                          p_aah_rec.attribute5);

   dbms_sql.bind_variable(p_update_cursor, ':attribute6',
                          p_aah_rec.attribute6);

   dbms_sql.bind_variable(p_update_cursor, ':attribute7',
                          p_aah_rec.attribute7);

   dbms_sql.bind_variable(p_update_cursor, ':attribute8',
                          p_aah_rec.attribute8);

   dbms_sql.bind_variable(p_update_cursor, ':attribute9',
                          p_aah_rec.attribute9);

   dbms_sql.bind_variable(p_update_cursor, ':attribute10',
                          p_aah_rec.attribute10);

   dbms_sql.bind_variable(p_update_cursor, ':attribute11',
                          p_aah_rec.attribute11);

   dbms_sql.bind_variable(p_update_cursor, ':attribute12',
                          p_aah_rec.attribute12);

   dbms_sql.bind_variable(p_update_cursor, ':attribute13',
                          p_aah_rec.attribute13);

   dbms_sql.bind_variable(p_update_cursor, ':attribute14',
                          p_aah_rec.attribute14);

   dbms_sql.bind_variable(p_update_cursor, ':attribute15',
                          p_aah_rec.attribute15);

   dbms_sql.bind_variable(p_update_cursor, ':created_by',
                          p_aah_rec.created_by);

   dbms_sql.bind_variable(p_update_cursor, ':creation_date',
                          p_aah_rec.creation_date);

   dbms_sql.bind_variable(p_update_cursor, ':last_updated_by',
                          p_aah_rec.last_updated_by);

   dbms_sql.bind_variable(p_update_cursor, ':last_update_date',
                          p_aah_rec.last_update_date);

   dbms_sql.bind_variable(p_update_cursor, ':last_update_login',
                          p_aah_rec.last_update_login);



   arp_util.debug('arp_aah_pkg.bind_aah_variables()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_aah_pkg.bind_aah_variables()');
        RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    construct_aah_update_stmt 					     |
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
 |    This statement only updates columns in the aah record that do not      |
 |    contain the dummy values that indicate that they should not be changed.|
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE construct_aah_update_stmt( update_text OUT NOCOPY varchar2) IS

BEGIN
   arp_util.debug('arp_aah_pkg.construct_aah_update_stmt()+');

   update_text :=
 'UPDATE ar_approval_action_history
  SET    approval_action_history_id =
               DECODE(:approval_action_history_id,
                      :ar_number_dummy,	approval_action_history_id,
					:approval_action_history_id),
          action_name =
               DECODE(:action_name,
                      :ar_text_dummy,	action_name,
					:action_name),
          adjustment_id =
               DECODE(:adjustment_id,
                      :ar_number_dummy,	adjustment_id,
					:adjustment_id),
          action_date =
               DECODE(:action_date,
                      :ar_date_dummy,	action_date,
					:action_date),
          comments =
               DECODE(:comments,
                      :ar_text_dummy,	comments,
					:comments),
          attribute_category =
               DECODE(:attribute_category,
                      :ar_text_dummy,	attribute_category,
					:attribute_category),
          attribute1 =
               DECODE(:attribute1,
                      :ar_text_dummy,	attribute1,
					:attribute1),
          attribute2 =
               DECODE(:attribute2,
                      :ar_text_dummy,	attribute2,
					:attribute2),
          attribute3 =
               DECODE(:attribute3,
                      :ar_text_dummy,	attribute3,
					:attribute3),
          attribute4 =
               DECODE(:attribute4,
                      :ar_text_dummy,	attribute4,
					:attribute4),
          attribute5 =
               DECODE(:attribute5,
                      :ar_text_dummy,	attribute5,
					:attribute5),
          attribute6 =
               DECODE(:attribute6,
                      :ar_text_dummy,	attribute6,
					:attribute6),
          attribute7 =
               DECODE(:attribute7,
                      :ar_text_dummy,	attribute7,
					:attribute7),
          attribute8 =
               DECODE(:attribute8,
                      :ar_text_dummy,	attribute8,
					:attribute8),
          attribute9 =
               DECODE(:attribute9,
                      :ar_text_dummy,	attribute9,
					:attribute9),
          attribute10 =
               DECODE(:attribute10,
                      :ar_text_dummy,	attribute10,
					:attribute10),
          attribute11 =
               DECODE(:attribute11,
                      :ar_text_dummy,	attribute11,
					:attribute11),
          attribute12 =
               DECODE(:attribute12,
                      :ar_text_dummy,	attribute12,
					:attribute12),
          attribute13 =
               DECODE(:attribute13,
                      :ar_text_dummy,	attribute13,
					:attribute13),
          attribute14 =
               DECODE(:attribute14,
                      :ar_text_dummy,	attribute14,
					:attribute14),
          attribute15 =
               DECODE(:attribute15,
                      :ar_text_dummy,	attribute15,
					:attribute15),
          created_by =
               DECODE(:created_by,
                      :ar_number_dummy,	created_by,
					:created_by),
          creation_date =
               DECODE(:creation_date,
                      :ar_date_dummy,	creation_date,
					:creation_date),
          last_updated_by =
               DECODE(:last_updated_by,
                      :ar_number_dummy,	:pg_user_id,
					:last_updated_by),
          last_update_date =
               DECODE(:last_update_date,
                      :ar_date_dummy,	sysdate,
					:last_update_date),
          last_update_login =
               DECODE(:last_update_login,
                      :ar_number_dummy,	nvl(:pg_conc_login_id,
                                            :pg_login_id),
					:last_update_login)';

   arp_util.debug('arp_aah_pkg.construct_aah_update_stmt()-');

EXCEPTION
    WHEN OTHERS THEN
       arp_util.debug('EXCEPTION:  arp_aah_pkg.construct_aah_update_stmt()');
       RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    generic_update                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure Updates records in ar_approval_action_history  	     |
 |     identified by the where clause that is passed in as a parameter. Only |
 |     those columns in the aah record parameter that do not contain the     |
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
 |		      p_aah_rec        - contains the new aah values         |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE generic_update(p_update_cursor IN OUT NOCOPY integer,
			 p_where_clause  IN varchar2,
			 p_where1        IN number,
                         p_aah_rec       IN ar_approval_action_history%rowtype) IS

   l_count             number;
   l_update_statement  varchar2(25000);

BEGIN
   arp_util.debug('arp_aah_pkg.generic_update()+');

  /*--------------------------------------------------------------+
   |  If this update statement has not already been parsed, 	  |
   |  construct the statement and parse it.			  |
   |  Otherwise, use the already parsed statement and rebind its  |
   |  variables.						  |
   +--------------------------------------------------------------*/

   if (p_update_cursor is null)
   then

         p_update_cursor := dbms_sql.open_cursor;

         /*---------------------------------+
          |  Construct the update statement |
          +---------------------------------*/

         arp_aah_pkg.construct_aah_update_stmt(l_update_statement);

         l_update_statement := l_update_statement || p_where_clause;

         /*-----------------------------------------------+
          |  Parse, bind, execute and close the statement |
          +-----------------------------------------------*/

         dbms_sql.parse(p_update_cursor,
                        l_update_statement,
                        dbms_sql.v7);

   end if;

   arp_aah_pkg.bind_aah_variables(p_update_cursor, p_aah_rec);

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
   THEN raise NO_DATA_FOUND;
   END IF;


   arp_util.debug('arp_aah_pkg.generic_update()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_aah_pkg.generic_update()');
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
 |    This procedure initializes all columns in the parameter aah record     |
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
 |                    p_aah_rec   - The record to initialize		     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE set_to_dummy( p_aah_rec OUT NOCOPY ar_approval_action_history%rowtype) IS

BEGIN

    arp_util.debug('arp_aah_pkg.set_to_dummy()+');

    p_aah_rec.approval_action_history_id	:= AR_NUMBER_DUMMY;
    p_aah_rec.action_name			:= AR_TEXT_DUMMY;
    p_aah_rec.adjustment_id			:= AR_NUMBER_DUMMY;
    p_aah_rec.action_date			:= AR_DATE_DUMMY;
    p_aah_rec.comments				:= AR_TEXT_DUMMY;
    p_aah_rec.attribute_category		:= AR_TEXT_DUMMY;
    p_aah_rec.attribute1			:= AR_TEXT_DUMMY;
    p_aah_rec.attribute2			:= AR_TEXT_DUMMY;
    p_aah_rec.attribute3			:= AR_TEXT_DUMMY;
    p_aah_rec.attribute4			:= AR_TEXT_DUMMY;
    p_aah_rec.attribute5			:= AR_TEXT_DUMMY;
    p_aah_rec.attribute6			:= AR_TEXT_DUMMY;
    p_aah_rec.attribute7			:= AR_TEXT_DUMMY;
    p_aah_rec.attribute8			:= AR_TEXT_DUMMY;
    p_aah_rec.attribute9			:= AR_TEXT_DUMMY;
    p_aah_rec.attribute10			:= AR_TEXT_DUMMY;
    p_aah_rec.attribute11			:= AR_TEXT_DUMMY;
    p_aah_rec.attribute12			:= AR_TEXT_DUMMY;
    p_aah_rec.attribute13			:= AR_TEXT_DUMMY;
    p_aah_rec.attribute14			:= AR_TEXT_DUMMY;
    p_aah_rec.attribute15			:= AR_TEXT_DUMMY;
    p_aah_rec.created_by			:= AR_NUMBER_DUMMY;
    p_aah_rec.creation_date			:= AR_DATE_DUMMY;
    p_aah_rec.last_updated_by			:= AR_NUMBER_DUMMY;
    p_aah_rec.last_update_date			:= AR_DATE_DUMMY;
    p_aah_rec.last_update_login			:= AR_NUMBER_DUMMY;

    arp_util.debug('arp_aah_pkg.set_to_dummy()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_aah_pkg.set_to_dummy()');
        RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ar_approval_action_history row identified by  |
 |    p_approval_action_history_id parameter.				     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                 p_approval_action_history_id - identifies the row to lock |
 |              OUT:                                                         |
 |                  None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_p( p_approval_action_history_id
                  IN ar_approval_action_history.approval_action_history_id%type
                )
          IS

    l_approval_action_history_id
                    ar_approval_action_history.approval_action_history_id%type;

BEGIN
    arp_util.debug('arp_aah_pkg.lock_p()+');


    SELECT        approval_action_history_id
    INTO          l_approval_action_history_id
    FROM          ar_approval_action_history
    WHERE         approval_action_history_id = p_approval_action_history_id
    FOR UPDATE OF approval_action_history_id NOWAIT;

    arp_util.debug('arp_aah_pkg.lock_p()-');

    EXCEPTION
        WHEN  OTHERS THEN
	    arp_util.debug( 'EXCEPTION: arp_aah_pkg.lock_p' );
            RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_f_adj_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ar_approval_action_history rows identified by |
 |    p_adjustment_id parameter.					     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_adjustment_id 	- identifies the rows to lock	     |
 |              OUT:                                                         |
 |                  None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_f_adj_id( p_adjustment_id
                           IN ar_adjustments.adjustment_id%type )
          IS

    CURSOR LOCK_C IS
    SELECT        approval_action_history_id
    FROM          ar_approval_action_history
    WHERE         adjustment_id = p_adjustment_id
    FOR UPDATE OF approval_action_history_id NOWAIT;


BEGIN
    arp_util.debug('arp_aah_pkg.lock_f_adj_id()+');

    OPEN lock_c;
    CLOSE lock_c;

    arp_util.debug('arp_aah_pkg.lock_f_adj_id()-');

    EXCEPTION
        WHEN  OTHERS THEN
	    arp_util.debug( 'EXCEPTION: arp_aah_pkg.lock_f_adj_id' );
            RAISE;
END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_fetch_p							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ar_approval_action_history row identified     |
 |    by the p_approval_action_history_id parameter and populates the        |
 |    p_aah_rec parameter with the row that was locked.		  	     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                 p_approval_action_history_id - identifies the row to lock |
 |              OUT:                                                         |
 |                 p_aah_rec			- contains the locked row    |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_fetch_p( p_aah_rec IN OUT NOCOPY ar_approval_action_history%rowtype,
                        p_approval_action_history_id IN
		ar_approval_action_history.approval_action_history_id%type) IS

BEGIN
    arp_util.debug('arp_aah_pkg.lock_fetch_p()+');

    SELECT        *
    INTO          p_aah_rec
    FROM          ar_approval_action_history
    WHERE         approval_action_history_id = p_approval_action_history_id
    FOR UPDATE OF approval_action_history_id NOWAIT;

    arp_util.debug('arp_aah_pkg.lock_fetch_p()-');

    EXCEPTION
        WHEN  OTHERS THEN
            arp_util.debug( 'EXCEPTION: arp_aah_pkg.lock_fetch_p' );
            RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_compare_p							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ar_approval_action_history row identified     |
 |    by the p_approval_action_history_id parameter only if no columns in    |
 |    that row have changed from when they were first selected in the form.  |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                 p_approval_action_history_id - identifies the row to lock |
 | 		   p_aah_rec    	- aah record for comparison	     |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_compare_p(
              p_approval_action_history_id IN
                 ar_approval_action_history.approval_action_history_id%type,
              p_aah_rec IN ar_approval_action_history%rowtype) IS

    l_dummy_aah_rec ar_approval_action_history%rowtype;

BEGIN
    arp_util.debug('arp_aah_pkg.lock_compare_p()+');

    SELECT        *
    INTO          l_dummy_aah_rec
    FROM          ar_approval_action_history aah
    WHERE         approval_action_history_id = p_approval_action_history_id
    AND NOT
       (
           NVL(aah.approval_action_history_id, AR_NUMBER_DUMMY) <>
           NVL(
                 DECODE(p_aah_rec.approval_action_history_id,
                        AR_NUMBER_DUMMY, aah.approval_action_history_id,
                                         p_aah_rec.approval_action_history_id),
                 AR_NUMBER_DUMMY
              )
         OR
           NVL(aah.action_name, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_aah_rec.action_name,
                        AR_TEXT_DUMMY,   aah.action_name,
                                         p_aah_rec.action_name),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(aah.adjustment_id, AR_NUMBER_DUMMY) <>
           NVL(
                 DECODE(p_aah_rec.adjustment_id,
                        AR_NUMBER_DUMMY, aah.adjustment_id,
                                         p_aah_rec.adjustment_id),
                 AR_NUMBER_DUMMY
              )
         OR
           NVL(aah.action_date, AR_DATE_DUMMY) <>
           NVL(
                 DECODE(p_aah_rec.action_date,
                        AR_DATE_DUMMY,   aah.action_date,
                                         p_aah_rec.action_date),
                 AR_DATE_DUMMY
              )
         OR
           NVL(aah.comments, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_aah_rec.comments,
                        AR_TEXT_DUMMY,   aah.comments,
                                         p_aah_rec.comments),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(aah.attribute_category, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_aah_rec.attribute_category,
                        AR_TEXT_DUMMY,   aah.attribute_category,
                                         p_aah_rec.attribute_category),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(aah.attribute1, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_aah_rec.attribute1,
                        AR_TEXT_DUMMY,   aah.attribute1,
                                         p_aah_rec.attribute1),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(aah.attribute2, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_aah_rec.attribute2,
                        AR_TEXT_DUMMY,   aah.attribute2,
                                         p_aah_rec.attribute2),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(aah.attribute3, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_aah_rec.attribute3,
                        AR_TEXT_DUMMY,   aah.attribute3,
                                         p_aah_rec.attribute3),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(aah.attribute4, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_aah_rec.attribute4,
                        AR_TEXT_DUMMY,   aah.attribute4,
                                         p_aah_rec.attribute4),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(aah.attribute5, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_aah_rec.attribute5,
                        AR_TEXT_DUMMY,   aah.attribute5,
                                         p_aah_rec.attribute5),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(aah.attribute6, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_aah_rec.attribute6,
                        AR_TEXT_DUMMY,   aah.attribute6,
                                         p_aah_rec.attribute6),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(aah.attribute7, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_aah_rec.attribute7,
                        AR_TEXT_DUMMY,   aah.attribute7,
                                         p_aah_rec.attribute7),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(aah.attribute8, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_aah_rec.attribute8,
                        AR_TEXT_DUMMY,   aah.attribute8,
                                         p_aah_rec.attribute8),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(aah.attribute9, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_aah_rec.attribute9,
                        AR_TEXT_DUMMY,   aah.attribute9,
                                         p_aah_rec.attribute9),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(aah.attribute10, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_aah_rec.attribute10,
                        AR_TEXT_DUMMY,   aah.attribute10,
                                         p_aah_rec.attribute10),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(aah.attribute11, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_aah_rec.attribute11,
                        AR_TEXT_DUMMY,   aah.attribute11,
                                         p_aah_rec.attribute11),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(aah.attribute12, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_aah_rec.attribute12,
                        AR_TEXT_DUMMY,   aah.attribute12,
                                         p_aah_rec.attribute12),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(aah.attribute13, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_aah_rec.attribute13,
                        AR_TEXT_DUMMY,   aah.attribute13,
                                         p_aah_rec.attribute13),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(aah.attribute14, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_aah_rec.attribute14,
                        AR_TEXT_DUMMY,   aah.attribute14,
                                         p_aah_rec.attribute14),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(aah.attribute15, AR_TEXT_DUMMY) <>
           NVL(
                 DECODE(p_aah_rec.attribute15,
                        AR_TEXT_DUMMY,   aah.attribute15,
                                         p_aah_rec.attribute15),
                 AR_TEXT_DUMMY
              )
         OR
           NVL(aah.created_by, AR_NUMBER_DUMMY) <>
           NVL(
                 DECODE(p_aah_rec.created_by,
                        AR_NUMBER_DUMMY, aah.created_by,
                                         p_aah_rec.created_by),
                 AR_NUMBER_DUMMY
              )
         OR
           NVL(aah.creation_date, AR_DATE_DUMMY) <>
           NVL(
                 DECODE(p_aah_rec.creation_date,
                        AR_DATE_DUMMY,   aah.creation_date,
                                         p_aah_rec.creation_date),
                 AR_DATE_DUMMY
              )
         OR
           NVL(aah.last_updated_by, AR_NUMBER_DUMMY) <>
           NVL(
                 DECODE(p_aah_rec.last_updated_by,
                        AR_NUMBER_DUMMY, aah.last_updated_by,
                                         p_aah_rec.last_updated_by),
                 AR_NUMBER_DUMMY
              )
         OR
           NVL(aah.last_update_date, AR_DATE_DUMMY) <>
           NVL(
                 DECODE(p_aah_rec.last_update_date,
                        AR_DATE_DUMMY,   aah.last_update_date,
                                         p_aah_rec.last_update_date),
                 AR_DATE_DUMMY
              )
         OR
           NVL(aah.last_update_login, AR_NUMBER_DUMMY) <>
           NVL(
                 DECODE(p_aah_rec.last_update_login,
                        AR_NUMBER_DUMMY, aah.last_update_login,
                                         p_aah_rec.last_update_login),
                 AR_NUMBER_DUMMY
              )
       )
    FOR UPDATE OF approval_action_history_id NOWAIT;

    arp_util.debug('arp_aah_pkg.lock_compare_p()-');

    EXCEPTION
        WHEN  OTHERS THEN
            arp_util.debug( 'EXCEPTION: arp_aah_pkg.lock_compare_p' );
            RAISE;
END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    fetch_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure fetches a single row from ar_approval_action_history    |
 |    into a variable specified as a parameter based on the table's primary  |
 |    key, approval_action_history_id					     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |             p_approval_action_history_id - identifies the record to fetch |
 |              OUT:                                                         |
 |             p_aah_rec  - contains the fetched record	    	 	     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE fetch_p( p_aah_rec         OUT NOCOPY ar_approval_action_history%rowtype,
                 p_approval_action_history_id IN
                   ar_approval_action_history.approval_action_history_id%type)
          IS

BEGIN
    arp_util.debug('arp_aah_pkg.fetch_p()+');

    SELECT *
    INTO   p_aah_rec
    FROM   ar_approval_action_history
    WHERE  approval_action_history_id = p_approval_action_history_id;

    arp_util.debug('arp_aah_pkg.fetch_p()-');

    EXCEPTION
        WHEN  OTHERS THEN
            arp_util.debug( 'EXCEPTION: arp_aah_pkg.fetch_p' );
            RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure deletes the ar_approval_action_history row identified   |
 |    by the p_approval_action_history_id parameter.			     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |             p_approval_action_history_id  - identifies the rows to delete |
 |              OUT:                                                         |
 |              None						             |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

procedure delete_p( p_approval_action_history_id
                IN ar_approval_action_history.approval_action_history_id%type)
       IS


BEGIN


   arp_util.debug('arp_aah_pkg.delete_p()+');

   DELETE FROM ar_approval_action_history
   WHERE       approval_action_history_id = p_approval_action_history_id;

   arp_util.debug('arp_aah_pkg.delete_p()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_aah_pkg.delete_p()');

	RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_f_adj_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure deletes the ar_approval_action_history rows identified  |
 |    by the p_adjustment_id parameter	.				     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |           	      p_adjustment_id  - identifies the rows to delete       |
 |              OUT:                                                         |
 |                    None					             |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

procedure delete_f_adj_id( p_adjustment_id
                         IN ar_adjustments.adjustment_id%type)
       IS


BEGIN


   arp_util.debug('arp_aah_pkg.delete_f_adj_id()+');

   DELETE FROM ar_approval_action_history
   WHERE       adjustment_id = p_adjustment_id;

   arp_util.debug('arp_aah_pkg.delete_f_adj_id()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_aah_pkg.delete_f_adj_id()');

	RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure updates the ar_approval_action_history row identified   |
 |    by the p_approval_action_history_id parameter.			     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |               p_approval_action_history_id - identifies the row to update |
 |               p_aah_rec                 - contains the new column values  |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |     set_to_dummy must be called before the values in p_aah_rec are        |
 |     changed and this function is called.				     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE update_p( p_aah_rec IN ar_approval_action_history%rowtype,
                    p_approval_action_history_id  IN
                  ar_approval_action_history.approval_action_history_id%type)
          IS


BEGIN

   arp_util.debug('arp_aah_pkg.update_p()+  ' ||
                      to_char(sysdate, 'HH:MI:SS'));

   arp_aah_pkg.generic_update(  pg_cursor1,
			       ' WHERE approval_action_history_id = :where_1',
                               p_approval_action_history_id,
                               p_aah_rec);

   arp_util.debug('arp_aah_pkg.update_p()-  ' ||
                      to_char(sysdate, 'HH:MI:SS'));


EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_aah_pkg.update_p()');
        RAISE;
END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_f_adj_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure updates the ar_approval_action_history rows identified  |
 |    by the p_adjustment_id parameter.					     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |               p_adjustment_id	    - identifies the rows to update  |
 |               p_aah_rec                 - contains the new column values  |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |     set_to_dummy must be called before the values in p_aah_rec are        |
 |     changed and this function is called.				     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE update_f_adj_id( p_aah_rec     IN ar_approval_action_history%rowtype,
                          p_adjustment_id IN ar_adjustments.adjustment_id%type)
          IS


BEGIN

   arp_util.debug('arp_aah_pkg.update_f_adj_id()+  ' ||
                      to_char(sysdate, 'HH:MI:SS'));

   arp_aah_pkg.generic_update(  pg_cursor2,
			       ' WHERE adjustment_id = :where_1',
                               p_adjustment_id,
                               p_aah_rec);

   arp_util.debug('arp_aah_pkg.update_f_adj_id()-  ' ||
                      to_char(sysdate, 'HH:MI:SS'));


EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_aah_pkg.update_f_adj_id()');
        RAISE;
END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure inserts a row into ar_approval_action_history that      |
 |    contains the column values specified in the p_aah_rec parameter.       |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_aah_rec            - contains the new column values   |
 |              OUT:                                                         |
 |                   p_approval_action_history_id - unique ID of the new row |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE insert_p(
             p_aah_rec          IN ar_approval_action_history%rowtype,
             p_approval_action_history_id
                 OUT NOCOPY ar_approval_action_history.approval_action_history_id%type
                  ) IS


    l_approval_action_history_id
                    ar_approval_action_history.approval_action_history_id%type;


BEGIN

    arp_util.debug('arp_aah_pkg.insert_p()+');

    p_approval_action_history_id := '';

    /*---------------------------*
     | Get the unique identifier |
     *---------------------------*/

        SELECT AR_APPROVAL_ACTION_HISTORY_S.NEXTVAL
        INTO   l_approval_action_history_id
        FROM   DUAL;


    /*-------------------*
     | Insert the record |
     *-------------------*/

     INSERT INTO ar_approval_action_history
       (
         approval_action_history_id,
         action_name,
         adjustment_id,
         action_date,
         comments,
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
         created_by,
         creation_date,
         last_updated_by,
         last_update_date,
         last_update_login
       )
       VALUES
       (
         l_approval_action_history_id,
         p_aah_rec.action_name,
         p_aah_rec.adjustment_id,
         p_aah_rec.action_date,
         p_aah_rec.comments,
         p_aah_rec.attribute_category,
         p_aah_rec.attribute1,
         p_aah_rec.attribute2,
         p_aah_rec.attribute3,
         p_aah_rec.attribute4,
         p_aah_rec.attribute5,
         p_aah_rec.attribute6,
         p_aah_rec.attribute7,
         p_aah_rec.attribute8,
         p_aah_rec.attribute9,
         p_aah_rec.attribute10,
         p_aah_rec.attribute11,
         p_aah_rec.attribute12,
         p_aah_rec.attribute13,
         p_aah_rec.attribute14,
         p_aah_rec.attribute15,
         pg_user_id,			/* created_by */
         sysdate, 			/* creation_date */
         pg_user_id,			/* last_updated_by */
         sysdate,			/* last_update_date */
         nvl(pg_conc_login_id,
             pg_login_id)		/* last_update_login */
       );



   p_approval_action_history_id := l_approval_action_history_id;

   arp_util.debug('arp_aah_pkg.insert_p()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_aah_pkg.insert_p()');
	RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    display_aah_rec                                                        |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Displays the values of all columns except creation_date,               |
 |    last_update_date, and action_date                                      |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                       p_aah_rec                                           |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     30-AUG-95  Martin Johnson      Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE display_aah_rec(
            p_aah_rec IN ar_approval_action_history%rowtype) IS

BEGIN
   arp_util.debug('arp_aah_pkg.display_aah_rec()+');

   arp_util.debug('******** Dump of ar_approval_action_history record ' ||
                  '*********');

   arp_util.debug('approval_action_history_id     : '||
                                     p_aah_rec.approval_action_history_id);
   arp_util.debug('created_by                     : '||
                                     p_aah_rec.created_by);
   arp_util.debug('last_updated_by                : '||
                                     p_aah_rec.last_updated_by);
   arp_util.debug('last_update_login              : '||
                                     p_aah_rec.last_update_login);
   arp_util.debug('action_name                    : '||
                                     p_aah_rec.action_name);
   arp_util.debug('adjustment_id                  : '||
                                     p_aah_rec.adjustment_id);
   arp_util.debug('comments                       : '||
                                     p_aah_rec.comments);
   arp_util.debug('attribute_category             : '||
                                     p_aah_rec.attribute_category);
   arp_util.debug('attribute1                     : '||
                                     p_aah_rec.attribute1);
   arp_util.debug('attribute2                     : '||
                                     p_aah_rec.attribute2);
   arp_util.debug('attribute3                     : '||
                                     p_aah_rec.attribute3);
   arp_util.debug('attribute4                     : '||
                                     p_aah_rec.attribute4);
   arp_util.debug('attribute5                     : '||
                                     p_aah_rec.attribute5);
   arp_util.debug('attribute6                     : '||
                                     p_aah_rec.attribute6);
   arp_util.debug('attribute7                     : '||
                                     p_aah_rec.attribute7);
   arp_util.debug('attribute8                     : '||
                                     p_aah_rec.attribute8);
   arp_util.debug('attribute9                     : '||
                                     p_aah_rec.attribute9);
   arp_util.debug('attribute10                    : '||
                                     p_aah_rec.attribute10);
   arp_util.debug('attribute11                    : '||
                                     p_aah_rec.attribute11);
   arp_util.debug('attribute12                    : '||
                                     p_aah_rec.attribute12);
   arp_util.debug('attribute13                    : '||
                                     p_aah_rec.attribute13);
   arp_util.debug('attribute14                    : '||
                                     p_aah_rec.attribute14);
   arp_util.debug('attribute15                    : '||
                                     p_aah_rec.attribute15);

   arp_util.debug('arp_aah_pkg.display_aah_rec()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION: arp_aah_pkg.display_aah_rec()');
        RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    display_aah_p                                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Displays the values of all columns except creation_date,               |
 |    last_update_date, and action_date                                      |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                       p_approval_action_history_id                        |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     30-AUG-95  Martin Johnson      Created                                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE display_aah_p(
            p_approval_action_history_id IN
              ar_approval_action_history.approval_action_history_id%type) IS

   l_aah_rec ar_approval_action_history%rowtype;
BEGIN
   arp_util.debug('arp_aah_pkg.display_aah_p()+');

   arp_aah_pkg.fetch_p(l_aah_rec, p_approval_action_history_id);

   arp_aah_pkg.display_aah_rec(l_aah_rec);

   arp_util.debug('arp_aah_pkg.display_aah_p()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_aah_pkg.display_aah_p()');

        arp_util.debug('');
        arp_util.debug('-------- parameters for display_aah_p() ------');
        arp_util.debug('p_approval_action_history_id  = ' ||
                       p_approval_action_history_id);

        RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    display_aah_f_adj_id						     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Displays the values of all columns except creation_date,               |
 |    last_update_date, and action_date                                      |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_adjustment_id					     |
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
 |     30-AUG-95  Martin Johnson      Created                                |
 |                                                                           |
 +===========================================================================*/


PROCEDURE display_aah_f_adj_id(  p_adjustment_id IN
                                        ar_adjustments.adjustment_id%type )
                   IS

   CURSOR aah_cursor IS
          SELECT approval_action_history_id
          FROM   ar_approval_action_history
          WHERE  adjustment_id = p_adjustment_id
       ORDER BY  approval_action_history_id;

BEGIN

   arp_util.debug('arp_aah_pkg.display_aah_f_adj_id()+');

   arp_util.debug('=====================================================' ||
                  '==========================');
   arp_util.debug('======= ' ||
                  ' Dump of ar_approval_action_history records for adj_id: '||
		  to_char( p_adjustment_id ) || ' ' ||
                  '======');

   FOR l_aah_rec IN aah_cursor LOOP
       display_aah_p(l_aah_rec.approval_action_history_id);
   END LOOP;

   arp_util.debug('==== End ' ||
                  ' Dump of ar_approval_action_history records for adj_id: '||
		  to_char( p_adjustment_id ) || ' ' ||
                  '=====');
   arp_util.debug('=====================================================' ||
                  '==========================');

   arp_util.debug('arp_aah_pkg.display_aah_f_adj_id()-');

EXCEPTION
 WHEN OTHERS THEN
   arp_util.debug('EXCEPTION:  arp_aah_pkg.display_aah_f_adj_id()');

   arp_util.debug('');
   arp_util.debug('-------- parameters for display_aah_f_adj_id() ------');
   arp_util.debug('p_adjustment_id  = ' ||
                       p_adjustment_id);

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


END ARP_AAH_PKG;

/
