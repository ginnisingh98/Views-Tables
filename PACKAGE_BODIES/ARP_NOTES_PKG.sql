--------------------------------------------------------
--  DDL for Package Body ARP_NOTES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_NOTES_PKG" AS
/* $Header: ARTINOTB.pls 115.7 2004/02/10 09:02:01 ksankara ship $ */

  /*--------------------------------------------------------+
   |  Dummy constants for use in update and lock operations |
   +--------------------------------------------------------*/

  AR_TEXT_DUMMY   CONSTANT VARCHAR2(10) := '~~!@#$*&^';
  AR_FLAG_DUMMY   CONSTANT VARCHAR2(10) := '~';
  AR_NUMBER_DUMMY CONSTANT NUMBER(15)   := -999999999999999;
  AR_DATE_DUMMY   CONSTANT DATE         := to_date(1, 'J');

  /*-------------------------------------+
   |  WHO column values from FND_GLOBAL  |
   +-------------------------------------*/

  pg_user_id          number;
  pg_conc_login_id    number;
  pg_login_id         number;
  pg_prog_appl_id     number;
  pg_conc_program_id  number;



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
 |     16-DEC-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

FUNCTION get_number_dummy(p_null IN NUMBER DEFAULT null) RETURN number IS

BEGIN

    arp_util.debug('arp_notes_pkg.get_number_dummy()+');

    arp_util.debug('arp_notes_pkg.get_number_dummy()-');

    return(AR_NUMBER_DUMMY);

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_notes_pkg.get_number_dummy()');
        RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    set_to_dummy							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure initializes all columns in the parameter trx record     |
 |    to the appropriate dummy value for its datatype.			     |
 |    									     |
 |    The dummy values are defined in the following package level constants: |
 |	AR_TEXT_DUMMY 							     |
 |	AR_FLAG_DUMMY							     |
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
 |                    p_notes_rec   - The record to initialize		     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     16-DEC-95  Charlie Tomberg     Created                                |
 |     19-DEC-95  Shelley Eitzen      Added Customer Call Id
 |                                                                           |
 +===========================================================================*/

PROCEDURE set_to_dummy( p_notes_rec OUT NOCOPY ar_notes%rowtype) IS

BEGIN

    arp_util.debug('arp_notes_pkg.set_to_dummy()+');

    p_notes_rec.note_id                 := AR_NUMBER_DUMMY;
    p_notes_rec.customer_trx_id         := AR_NUMBER_DUMMY;
    p_notes_rec.customer_call_id        := AR_NUMBER_DUMMY;
    p_notes_rec.customer_call_topic_id  := AR_NUMBER_DUMMY;
    p_notes_rec.call_action_id 	        := AR_NUMBER_DUMMY;
--    p_notes_rec.note_date             := AR_DATE_DUMMY;
    p_notes_rec.note_type               := AR_TEXT_DUMMY;
    p_notes_rec.text                    := AR_TEXT_DUMMY;
    p_notes_rec.last_updated_by         := AR_NUMBER_DUMMY;
    p_notes_rec.last_update_date        := AR_DATE_DUMMY;
    p_notes_rec.last_update_login       := AR_NUMBER_DUMMY;
    p_notes_rec.creation_date           := AR_DATE_DUMMY;
    p_notes_rec.created_by              := AR_NUMBER_DUMMY;


    arp_util.debug('arp_notes_pkg.set_to_dummy()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_notes_pkg.set_to_dummy()');
        RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_f_ct_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ar_notes rows identified by the 	             |
 |    p_customer_trx_id parameter.					     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_id	- identifies the rows to lock	     |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     16-DEC-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_f_ct_id( p_customer_trx_id  IN ar_notes.customer_trx_id%type )
          IS

    l_customer_trx_id  ar_notes.customer_trx_id%type;

BEGIN
    arp_util.debug('arp_notes_pkg.lock_p()+');


    SELECT customer_trx_id
    INTO   l_customer_trx_id
    FROM   ar_notes
    WHERE  customer_trx_id = p_customer_trx_id
    FOR UPDATE OF customer_trx_id NOWAIT;

    arp_util.debug('arp_notes_pkg.lock_p()-');

    EXCEPTION
        WHEN  OTHERS THEN
	    arp_util.debug( 'EXCEPTION: arp_notes_pkg.lock_p' );
            RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_fetch_p							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ar_notes row identified by the 	             |
 |    p_note_id parameter and populates the p_notes_rec parameter with       |
 |    the row that was locked.						     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_noteid	        - identifies the row to lock	     |
 |              OUT:                                                         |
 |                    p_notes_rec	- contains the locked row	     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     16-DEC-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_fetch_p( p_notes_rec         IN OUT NOCOPY ar_notes%rowtype,
                        p_note_id           IN     ar_notes.note_id%type) IS

BEGIN
    arp_util.debug('arp_notes_pkg.lock_fetch_p()+');

    SELECT        *
    INTO          p_notes_rec
    FROM          ar_notes
    WHERE         note_id = p_note_id
    FOR UPDATE OF note_id NOWAIT;

    arp_util.debug('arp_notes_pkg.lock_fetch_p()-');

    EXCEPTION
        WHEN  OTHERS THEN
            arp_util.debug( 'EXCEPTION: arp_notes_pkg.lock_fetch_p' );
            RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_compare_p							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ar_notes row identified by the 	             |
 |    p_note_id parameter only if no columns in that row have 	             |
 |    changed from when they were first selected in the form.		     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_note_id	- identifies the row to lock	             |
 | 		      p_notes_rec    	- note record for comparison	     |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     16-DEC-95  Charlie Tomberg     Created                                |
 |     19-DEC-95  Shelley Eitzen      Added Customer Call Id                 |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_compare_p( p_notes_rec          IN ar_notes%rowtype,
                          p_note_id      IN ar_notes.note_id%type) IS

    l_new_note_rec  ar_notes%rowtype;

BEGIN
    arp_util.debug('arp_notes_pkg.lock_compare_p()+');

    SELECT   *
    INTO     l_new_note_rec
    FROM     ar_notes n
    WHERE    n.note_id = p_note_id
    AND
       (
          NVL(n.note_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_notes_rec.note_id,
                        AR_NUMBER_DUMMY, n.note_id,
                                       p_notes_rec.note_id),
                 AR_NUMBER_DUMMY
              )
        AND
           NVL(n.note_type, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_notes_rec.note_type,
                        AR_TEXT_DUMMY, n.note_type,
                                       p_notes_rec.note_type),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(n.text, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_notes_rec.text,
                        AR_TEXT_DUMMY, n.text,
                                       p_notes_rec.text),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(n.customer_trx_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_notes_rec.customer_trx_id,
                        AR_NUMBER_DUMMY, n.customer_trx_id,
                                       p_notes_rec.customer_trx_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(n.customer_call_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_notes_rec.customer_call_id,
                        AR_NUMBER_DUMMY, n.customer_call_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(n.customer_call_topic_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_notes_rec.customer_call_topic_id,
                        AR_NUMBER_DUMMY, n.customer_call_topic_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(n.call_action_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_notes_rec.call_action_id ,
                        AR_NUMBER_DUMMY, n.call_action_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(n.created_by, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_notes_rec.created_by,
                        AR_NUMBER_DUMMY, n.created_by,
                                       p_notes_rec.created_by),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(TRUNC(n.creation_date), AR_DATE_DUMMY) =
           NVL(
                 DECODE(TRUNC(p_notes_rec.creation_date),
                        AR_DATE_DUMMY, TRUNC(n.creation_date),
                                       TRUNC(p_notes_rec.creation_date)),
                 AR_DATE_DUMMY
              )
         AND
           NVL(n.last_updated_by, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_notes_rec.last_updated_by,
                        AR_NUMBER_DUMMY, n.last_updated_by,
                                       p_notes_rec.last_updated_by),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(TRUNC(n.last_update_date), AR_DATE_DUMMY) =
           NVL(
                 DECODE(TRUNC(p_notes_rec.last_update_date),
                        AR_DATE_DUMMY, TRUNC(n.last_update_date),
                                       TRUNC(p_notes_rec.last_update_date)),
                 AR_DATE_DUMMY
              )
         AND
           NVL(n.last_update_login, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_notes_rec.last_update_login,
                        AR_NUMBER_DUMMY, n.last_update_login,
                                       p_notes_rec.last_update_login),
                 AR_NUMBER_DUMMY
              )
      )
    FOR UPDATE OF note_id NOWAIT;

    arp_util.debug('arp_notes_pkg.lock_compare_p()-');

    EXCEPTION
        WHEN  NO_DATA_FOUND THEN
                arp_util.debug(
                     'EXCEPTION: arp_notes_pkg.lock_compare_p NO_DATA_FOUND' );

                arp_util.debug('');
                arp_util.debug('============= Old Record =============');
                display_note_p(p_note_id);
                arp_util.debug('');
                arp_util.debug('============= New Record =============');
                display_note_rec(p_notes_rec);

                FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
                APP_EXCEPTION.Raise_Exception;
        WHEN  OTHERS THEN
                arp_util.debug( 'EXCEPTION: arp_notes_pkg.lock_compare_p' );
            RAISE;
END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    fetch_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure fetches a single row from ar_notes into a 	             |
 |    variable specified as a parameter based on the table's primary key,    |
 |    p_note_id. 							     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_note_id	- identifies the record to fetch             |
 |              OUT:                                                         |
 |                    p_notes_rec	- contains the fetched record	     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     16-DEC-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE fetch_p( p_notes_rec  OUT NOCOPY ar_notes%rowtype,
                   p_note_id    IN  ar_notes.note_id%type)  IS

BEGIN
    arp_util.debug('arp_notes_pkg.fetch_p()+');

    SELECT *
    INTO   p_notes_rec
    FROM   ar_notes
    WHERE  note_id = p_note_id;

    arp_util.debug('arp_notes_pkg.fetch_p()-');

    EXCEPTION
        WHEN  OTHERS THEN
            arp_util.debug( 'EXCEPTION: arp_notes_pkg.fetch_p' );
            RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_f_ct_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure deletes the ar_notes row identified by the 	     |
 |    p_customer_trx_id parameter.					     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_id	- identifies the row to delete	     |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     16-DEC-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

procedure delete_f_ct_id( p_customer_trx_id  IN ar_notes.customer_trx_id%type)
       IS


BEGIN


   arp_util.debug('arp_notes_pkg.delete_f_ct_id()+');

   DELETE FROM ar_notes
   WHERE       customer_trx_id = p_customer_trx_id;

   arp_util.debug('arp_notes_pkg.delete_f_ct_id()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_notes_pkg.delete_f_ct_id()');

	RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure updates the ar_notes row identified by the 	     |
 |    p_note_id parameter.		  				     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_note_id     	- identifies the row to update	     |
 |              OUT:                                                         |
 |                    None						     |
 |           IN OUT:                                                         |
 |                    p_notes_rec       - contains the new column values     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |     set_to_dummy must be called before the values in p_notes_rec are      |
 |     changed and this function is called.				     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     16-DEC-95  Charlie Tomberg     Created                                |
 |     19-DEC-95  Shelley Eitzen      Added Customer Call Id                 |
 |                                                                           |
 +===========================================================================*/

PROCEDURE update_p( p_notes_rec IN OUT NOCOPY ar_notes%rowtype,
                    p_note_id   IN     ar_notes.note_id%type) IS


BEGIN

   arp_util.debug('arp_notes_pkg.update_p()+  ' ||
                      to_char(sysdate, 'HH:MI:SS'));

   SELECT
            DECODE(p_notes_rec.last_updated_by,
                   AR_NUMBER_DUMMY, pg_user_id,
                                    p_notes_rec.last_updated_by),
            DECODE(p_notes_rec.last_update_date,
                   AR_DATE_DUMMY,  sysdate,
                                   p_notes_rec.last_update_date),
            DECODE(p_notes_rec.last_update_login,
                   AR_NUMBER_DUMMY, nvl(pg_conc_login_id,
                                         pg_login_id),
                                    p_notes_rec.last_update_login)
   INTO     p_notes_rec.last_updated_by,
            p_notes_rec.last_update_date,
            p_notes_rec.last_update_login
   FROM     DUAL;

   UPDATE ar_notes
   SET    customer_trx_id =
               DECODE(p_notes_rec.customer_trx_id,
                      AR_NUMBER_DUMMY, customer_trx_id,
                                       p_notes_rec.customer_trx_id),
          customer_call_id =
               DECODE(p_notes_rec.customer_call_id,
                      AR_NUMBER_DUMMY, customer_call_id,
                                       p_notes_rec.customer_call_id),
          customer_call_topic_id =
               DECODE(p_notes_rec.customer_call_topic_id,
                      AR_NUMBER_DUMMY, customer_call_topic_id,
                                       p_notes_rec.customer_call_topic_id),
          call_action_id =
               DECODE(p_notes_rec.call_action_id,
                      AR_NUMBER_DUMMY, call_action_id,
                                       p_notes_rec.call_action_id),
          note_type =
               DECODE(p_notes_rec.note_type,
                      AR_TEXT_DUMMY, note_type,
                                       p_notes_rec.note_type),
          text =
               DECODE(p_notes_rec.text,
                      AR_TEXT_DUMMY, text,
                                       p_notes_rec.text),
          created_by =
               DECODE(p_notes_rec.created_by,
                      AR_NUMBER_DUMMY, created_by,
                                       p_notes_rec.created_by),
          creation_date =
               DECODE(p_notes_rec.creation_date,
                      AR_DATE_DUMMY,  creation_date,
                                      p_notes_rec.creation_date),
          last_updated_by   = p_notes_rec.last_updated_by,
          last_update_date  = p_notes_rec.last_update_date,
          last_update_login = p_notes_rec.last_update_login
   WHERE note_id = p_note_id;



   arp_util.debug('arp_notes_pkg.update_p()-  ' ||
                      to_char(sysdate, 'HH:MI:SS'));


EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_notes_pkg.update_p()');
        RAISE;
END;



/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure inserts a row into ar_notes that contains the           |
 |    column values specified in the p_notes_rec parameter. 		     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN OUT:                                                      |
 |                    p_notes_rec  - contains the new column values          |
 |              OUT:                                                         |
 |                    p_note_id    - unique ID of the new row                |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     16-DEC-95  Charlie Tomberg     Created                                |
 |     19-DEC-95  Shelley Eitzen      Added Customer Call Id                 |
 |                                                                           |
 +===========================================================================*/

PROCEDURE insert_p(
                    p_notes_rec          IN OUT NOCOPY ar_notes%rowtype
                  ) IS


    l_note_id  ar_notes.note_id%type;

BEGIN

    arp_util.debug('arp_notes_pkg.insert_p()+');

  /*------------------------------+
   |  get the unique id            |
   +------------------------------*/

   SELECT ar_notes_s.nextval
   INTO   l_note_id
   FROM dual;

 /*---------------------------------+
  |  Populate the output parameters |
  +---------------------------------*/

   p_notes_rec.note_id           := l_note_id;
   p_notes_rec.last_updated_by   := pg_user_id;
   p_notes_rec.last_update_date  := sysdate;
   p_notes_rec.last_update_login := NVL(pg_conc_login_id, pg_login_id);
   p_notes_rec.created_by        := pg_user_id;
   p_notes_rec.creation_date     := NVL(p_notes_rec.creation_date, sysdate);


arp_util.debug('l_note_id                             : ' || to_char(l_note_id));
arp_util.debug('p_notes_rec.note_type                 : ' || p_notes_rec.note_type);
/* 3206020 */
/* arp_util.debug('p_notes_rec.text                      : ' || p_notes_rec.text); */
arp_util.debug('p_notes_rec.customer_trx_id           : ' ||
               to_char(p_notes_rec.customer_trx_id));
arp_util.debug('p_notes_rec.customer_call_id    : ' || to_char(p_notes_rec.customer_call_id));
arp_util.debug('p_notes_rec.customer_call_topic_id    : ' || to_char(p_notes_rec.customer_call_topic_id));
arp_util.debug('p_notes_rec.call_action_id            : ' || to_char(p_notes_rec.call_action_id));
arp_util.debug('p_notes_rec.last_updated_by           : ' || to_char(p_notes_rec.last_updated_by));
arp_util.debug('p_notes_rec.last_update_date          : ' || to_char(p_notes_rec.last_update_date));
arp_util.debug('p_notes_rec.last_update_login         : ' || to_char(p_notes_rec.last_update_login));
arp_util.debug('p_notes_rec.created_by                : ' || to_char(p_notes_rec.created_by));
arp_util.debug('p_notes_rec.creation_date             : ' || to_char(p_notes_rec.creation_date));


  /*------------------------------+
   |  insert the record            |
   +------------------------------*/
   INSERT INTO ar_notes
    (
     note_id,
     note_type,
     text,
     customer_trx_id,
     customer_call_id,
     customer_call_topic_id,
     call_action_id,
     last_updated_by,
     last_update_date,
     last_update_login,
     created_by,
     creation_date
    )
   VALUES
    (
     l_note_id,
     p_notes_rec.note_type,
     p_notes_rec.text,
     p_notes_rec.customer_trx_id,
     p_notes_rec.customer_call_id,
     p_notes_rec.customer_call_topic_id,
     p_notes_rec.call_action_id,
     p_notes_rec.last_updated_by,
     p_notes_rec.last_update_date,
     p_notes_rec.last_update_login,
     p_notes_rec.created_by,
     p_notes_rec.creation_date
    );


   arp_util.debug('arp_notes_pkg.insert_p()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_notes_pkg.insert_p()');
	RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    display_note_p                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Displays the values of all columns except last_update_date.            |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                       p_note_id                                           |
 |              OUT:                                                         |
 |          IN/ OUT:							     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     16-DEC-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE display_note_p( p_note_id  IN ar_notes.note_id%type ) IS


   l_notes_rec ar_notes%rowtype;

BEGIN

   arp_util.debug('arp_notes_pkg.display_note_p()+');

   arp_notes_pkg.fetch_p(l_notes_rec, p_note_id);

   arp_notes_pkg.display_note_rec(l_notes_rec);

   arp_util.debug('arp_notes_pkg.display_note_p()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_notes_pkg.display_note_p()');
        RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    display_note_rec                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Displays the values of all columns except last_update_date.            |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                       p_notes_rec                                         |
 |              OUT:                                                         |
 |          IN/ OUT:							     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     16-DEC-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE display_note_rec ( p_notes_rec IN ar_notes%rowtype ) IS

BEGIN

   arp_util.debug('arp_notes_pkg.display_note_rec()+');

   arp_util.debug('************ Dump of ar_notes record ************');
   arp_util.debug('customer_trx_id: '	     || p_notes_rec.customer_trx_id);

   arp_util.debug('note_id                  : ' || p_notes_rec.note_id);
   arp_util.debug('creation_date            : ' || p_notes_rec.creation_date);
   arp_util.debug('note_type                : ' || p_notes_rec.note_type);
   /* Bug 3206020 */
   /*arp_util.debug('text                     : ' || p_notes_rec.text); */
   arp_util.debug('customer_call_id         : ' || p_notes_rec.customer_call_id );
   arp_util.debug('customer_call_topic_id   : ' ||
                  p_notes_rec.customer_call_topic_id );
   arp_util.debug('call_action_id           : ' ||p_notes_rec.call_action_id );
   arp_util.debug('customer_trx_id          : ' ||p_notes_rec.customer_trx_id);

   arp_util.debug('************* End ar_notes record *************');

   arp_util.debug('arp_notes_pkg.display_note_rec()-');

EXCEPTION
 WHEN OTHERS THEN
   arp_util.debug('EXCEPTION: arp_notes_pkg.display_note_rec()');
   RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_compare_cover                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Converts column parameters to a ar_notes record and locks the notes    |
 |    record.                                                                |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 |               IN:                                                         |
 |                    p_note_id                                              |
 |                    p_last_updated_by                                      |
 |                    p_last_update_date                                     |
 |                    p_last_update_login                                    |
 |                    p_created_by                                           |
 |                    p_creation_date                                        |
 |                    p_note_type                                            |
 |                    p_text                                                 |
 |                    p_customer_call_id                                     |
 |                    p_customer_call_topic_id                               |
 |                    p_call_action_id                                       |
 |                    p_customer_trx_id                                      |
 |                                                                           |
 |              OUT:                                                         |
 |                  None                                                     |
 |          IN/ OUT:                                                         |
 |                  None                                                     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     16-DEC-95  Charlie Tomberg  Created                                   |
 |     19-DEC-95  Shelley Eitzen   Added Customer Call Id                    |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_compare_cover(
            p_note_id                  IN ar_notes.note_id%type,
            p_last_updated_by          IN ar_notes.last_updated_by%type,
            p_last_update_date         IN ar_notes.last_update_date%type,
            p_last_update_login        IN ar_notes.last_update_login%type,
            p_created_by               IN ar_notes.created_by%type,
            p_creation_date            IN ar_notes.creation_date%type,
            p_note_type                IN ar_notes.note_type%type,
            p_text                     IN ar_notes.text%type,
            p_customer_call_id         IN ar_notes.customer_call_id%type,
            p_customer_call_topic_id   IN ar_notes.customer_call_topic_id%type,
            p_call_action_id           IN ar_notes.call_action_id%type,
            p_customer_trx_id          IN ar_notes.customer_trx_id%type ) IS


  l_notes_rec    ar_notes%rowtype;

BEGIN
   arp_util.debug('arp_notes_pkg.lock_compare_cover()+');

  /*------------------------------------------------+
   |  Populate the header record with the values    |
   |  passed in as parameters.                      |
   +------------------------------------------------*/

   arp_notes_pkg.set_to_dummy(l_notes_rec);

   l_notes_rec.note_id                 := p_note_id;
   l_notes_rec.last_updated_by         := p_last_updated_by;
   l_notes_rec.last_update_date        := p_last_update_date;
   l_notes_rec.last_update_login       := p_last_update_login;
   l_notes_rec.created_by              := p_created_by;
   l_notes_rec.creation_date           := p_creation_date;
   l_notes_rec.note_type               := p_note_type;
   l_notes_rec.text                    := p_text;
   l_notes_rec.customer_call_id        := p_customer_call_id;
   l_notes_rec.customer_call_topic_id  := p_customer_call_topic_id;
   l_notes_rec.call_action_id          := p_call_action_id;
   l_notes_rec.customer_trx_id         := p_customer_trx_id;


  /*-----------------------------------------+
   |  Call the standard header table handler |
   +-----------------------------------------*/

   lock_compare_p( l_notes_rec, p_note_id);

   arp_util.debug('arp_notes_pkg.lock_compare_cover()-');

EXCEPTION
  WHEN OTHERS THEN
    arp_util.debug('EXCEPTION : arp_notes_pkg.lock_compare_cover()');

    arp_util.debug('----- parameters for lock_compare_cover() ' ||
                   '-----');
    arp_util.debug('p_note_id                 : ' || p_note_id);
    arp_util.debug('p_last_updated_by         : ' || p_last_updated_by);
    arp_util.debug('p_last_update_date        : ' || p_last_update_date);
    arp_util.debug('p_last_update_login       : ' || p_last_update_login);
    arp_util.debug('p_created_by              : ' || p_created_by);
    arp_util.debug('p_creation_date           : ' || p_creation_date);
    arp_util.debug('p_note_type               : ' || p_note_type);
    /* Bg 3206020 */
    /* arp_util.debug('p_text                    : ' || p_text); */
    arp_util.debug('p_customer_call_id        : ' || p_customer_call_id);
    arp_util.debug('p_customer_call_topic_id  : ' || p_customer_call_topic_id);
    arp_util.debug('p_call_action_id          : ' || p_call_action_id);
    arp_util.debug('p_customer_trx_id         : ' || p_customer_trx_id);

    RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_cover                                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Converts column parameters to a ar_notes record and                    |
 |    inserts the notes record.                                              |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 |               IN:                                                         |
 |                    p_note_id                                              |
 |                    p_note_type                                            |
 |                    p_text                                                 |
 |                    p_customer_call_id                                     |
 |                    p_customer_call_topic_id                               |
 |                    p_call_action_id                                       |
 |                                                                           |
 |              OUT:                                                         |
 |                    p_customer_trx_id                                      |
 |          IN/ OUT:                                                         |
 |                    p_last_updated_by                                      |
 |                    p_last_update_date                                     |
 |                    p_last_update_login                                    |
 |                    p_created_by                                           |
 |                    p_creation_date                                        |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     16-DEC-95  Charlie Tomberg  Created                                   |
 |     19-DEC-95  Shelley Eitzen   Added Customer Call ID                    |
 |                                                                           |
 +===========================================================================*/

PROCEDURE insert_cover(
            p_note_type                IN ar_notes.note_type%type,
            p_text                     IN ar_notes.text%type,
            p_customer_call_id         IN ar_notes.customer_call_id%type,
            p_customer_call_topic_id   IN ar_notes.customer_call_topic_id%type,
            p_call_action_id           IN ar_notes.call_action_id%type,
            p_customer_trx_id          IN ar_notes.customer_trx_id%type,
            p_note_id                 OUT NOCOPY ar_notes.note_id%type,
            p_last_updated_by      IN OUT NOCOPY ar_notes.last_updated_by%type,
            p_last_update_date     IN OUT NOCOPY ar_notes.last_update_date%type,
            p_last_update_login    IN OUT NOCOPY ar_notes.last_update_login%type,
            p_created_by           IN OUT NOCOPY ar_notes.created_by%type,
            p_creation_date        IN OUT NOCOPY ar_notes.creation_date%type ) IS


  l_notes_rec    ar_notes%rowtype;

BEGIN
   arp_util.debug('arp_notes_pkg.insert_cover()+');

  /*------------------------------------------------+
   |  Populate the header record with the values    |
   |  passed in as parameters.                      |
   +------------------------------------------------*/

   l_notes_rec.last_updated_by         := p_last_updated_by;
   l_notes_rec.last_update_date        := p_last_update_date;
   l_notes_rec.last_update_login       := p_last_update_login;
   l_notes_rec.created_by              := p_created_by;
   l_notes_rec.creation_date           := p_creation_date;
   l_notes_rec.note_type               := p_note_type;
   l_notes_rec.text                    := p_text;
   l_notes_rec.customer_call_id        := p_customer_call_id;
   l_notes_rec.customer_call_topic_id  := p_customer_call_topic_id;
   l_notes_rec.call_action_id          := p_call_action_id;
   l_notes_rec.customer_trx_id         := p_customer_trx_id;


  /*-----------------------------------------+
   |  Call the standard header table handler |
   +-----------------------------------------*/

   insert_p( l_notes_rec );

 /*-------------------------------+
  |  Populate the out NOCOPY parameters  |
  +-------------------------------*/

   /* Bug 2306546 : ON-LOCK trigger error.Assigned the required value to p_note_id
                    Previously it was not returning the value to out NOCOPY parameter p_note_id,
                    Which is called in ARXTWMAI.pld*/
   p_note_id            := l_notes_rec.note_id;
   p_last_updated_by    := l_notes_rec.last_updated_by;
   p_last_update_date   := l_notes_rec.last_update_date;
   p_last_update_login  := l_notes_rec.last_update_login;
   p_created_by         := l_notes_rec.created_by;
   p_creation_date      := l_notes_rec.creation_date;

   arp_util.debug('arp_notes_pkg.insert_cover()-');

EXCEPTION
  WHEN OTHERS THEN
    arp_util.debug('EXCEPTION : arp_notes_pkg.insert_cover()');

    arp_util.debug('----- parameters for insert_cover() ' ||
                   '-----');
    arp_util.debug('p_last_updated_by         : ' || p_last_updated_by);
    arp_util.debug('p_last_update_date        : ' || p_last_update_date);
    arp_util.debug('p_last_update_login       : ' || p_last_update_login);
    arp_util.debug('p_created_by              : ' || p_created_by);
    arp_util.debug('p_creation_date           : ' || p_creation_date);
    arp_util.debug('p_note_type               : ' || p_note_type);
    /* Bug 3206020 */
    /* arp_util.debug('p_text                    : ' || p_text); */
    arp_util.debug('p_customer_call_id        : ' || p_customer_call_id);
    arp_util.debug('p_customer_call_topic_id  : ' || p_customer_call_topic_id);
    arp_util.debug('p_call_action_id          : ' || p_call_action_id);
    arp_util.debug('p_customer_trx_id         : ' || p_customer_trx_id);

    RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_cover                                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Converts column parameters to a notes record and                       |
 |    updates the notes record.                                              |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 |               IN:                                                         |
 |                    p_note_id                                              |
 |                    p_created_by                                           |
 |                    p_creation_date                                        |
 |                    p_note_type                                            |
 |                    p_text                                                 |
 |                    p_customer_call_id                                     |
 |                    p_customer_call_topic_id                               |
 |                    p_call_action_id                                       |
 |                    p_customer_trx_id                                      |
 |                                                                           |
 |              OUT:                                                         |
 |                  None                                                     |
 |          IN/ OUT:                                                         |
 |                    p_last_updated_by                                      |
 |                    p_last_update_date                                     |
 |                    p_last_update_login                                    |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     16-DEC-95  Charlie Tomberg  Created                                   |
 |     19-DEC-95  Shelley Eitzen   Added Customer Call Id                    |
 |                                                                           |
 +===========================================================================*/


PROCEDURE update_cover(
            p_note_id                  IN ar_notes.note_id%type,
            p_created_by               IN ar_notes.created_by%type,
            p_creation_date            IN ar_notes.creation_date%type,
            p_note_type                IN ar_notes.note_type%type,
            p_text                     IN ar_notes.text%type,
            p_customer_call_id         IN ar_notes.customer_call_id%type,
            p_customer_call_topic_id   IN ar_notes.customer_call_topic_id%type,
            p_call_action_id           IN ar_notes.call_action_id%type,
            p_customer_trx_id          IN ar_notes.customer_trx_id%type,
            p_last_updated_by      IN OUT NOCOPY ar_notes.last_updated_by%type,
            p_last_update_date     IN OUT NOCOPY ar_notes.last_update_date%type,
            p_last_update_login    IN OUT NOCOPY ar_notes.last_update_login%type ) IS


  l_notes_rec    ar_notes%rowtype;

BEGIN
   arp_util.debug('arp_notes_pkg.update_cover()+');

  /*------------------------------------------------+
   |  Populate the header record with the values    |
   |  passed in as parameters.                      |
   +------------------------------------------------*/


   l_notes_rec.note_id                 := p_note_id;
   l_notes_rec.last_updated_by         := p_last_updated_by;
   l_notes_rec.last_update_date        := p_last_update_date;
   l_notes_rec.last_update_login       := p_last_update_login;
   l_notes_rec.created_by              := p_created_by;
   l_notes_rec.creation_date           := p_creation_date;
   l_notes_rec.note_type               := p_note_type;
   l_notes_rec.text                    := p_text;
   l_notes_rec.customer_call_id        := p_customer_call_id;
   l_notes_rec.customer_call_topic_id  := p_customer_call_topic_id;
   l_notes_rec.call_action_id          := p_call_action_id;
   l_notes_rec.customer_trx_id         := p_customer_trx_id;


  /*-----------------------------------------+
   |  Call the standard header table handler |
   +-----------------------------------------*/

   update_p( l_notes_rec, p_note_id);

  /*-------------------------------+
   |  Populate the out NOCOPY parameters  |
   +-------------------------------*/

   p_last_updated_by    := l_notes_rec.last_updated_by;
   p_last_update_date   := l_notes_rec.last_update_date;
   p_last_update_login  := l_notes_rec.last_update_login;

   arp_util.debug('arp_notes_pkg.update_cover()-');

EXCEPTION
  WHEN OTHERS THEN
    arp_util.debug('EXCEPTION : arp_notes_pkg.update_cover()');

    arp_util.debug('----- parameters for update_cover() ' ||
                   '-----');
    arp_util.debug('p_note_id                 : ' || p_note_id);
    arp_util.debug('p_last_updated_by         : ' || p_last_updated_by);
    arp_util.debug('p_last_update_date        : ' || p_last_update_date);
    arp_util.debug('p_last_update_login       : ' || p_last_update_login);
    arp_util.debug('p_created_by              : ' || p_created_by);
    arp_util.debug('p_creation_date           : ' || p_creation_date);
    arp_util.debug('p_note_type               : ' || p_note_type);
    /* Bug 3206020 */
    /* arp_util.debug('p_text                    : ' || p_text); */
    arp_util.debug('p_customer_call_id        : ' || p_customer_call_id);
    arp_util.debug('p_customer_call_topic_id  : ' || p_customer_call_topic_id);
    arp_util.debug('p_call_action_id          : ' || p_call_action_id);
    arp_util.debug('p_customer_trx_id         : ' || p_customer_trx_id);

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


END ARP_NOTES_PKG;

/
