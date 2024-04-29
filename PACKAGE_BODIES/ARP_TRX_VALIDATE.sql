--------------------------------------------------------
--  DDL for Package Body ARP_TRX_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_TRX_VALIDATE" AS
/* $Header: ARTUVALB.pls 120.27.12010000.2 2009/08/27 13:09:52 rasarasw ship $ */

   pg_ai_pds_exist_cursor               integer;
   pg_ai_overlapping_pds_cursor         integer;
   pg_form_pds_exist_cursor             integer;
   pg_form_overlapping_pds_cursor       integer;

   pg_salesrep_required_flag  ar_system_parameters.salesrep_required_flag%type;
   pg_set_of_books_id         ar_system_parameters.set_of_books_id%type;
   pg_base_curr_code          gl_sets_of_books.currency_code%type;




/*===========================================================================+
 | PROCEDURE                                                                 |
 |    add_to_error_list()                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Adds a message to the error list.                                      |
 |    Currently, this function just puts the message on the stack and raises |
 |    an exception. Later, however, it will put the messages on a stack so   |
 |    that we can display multiple messages at a time.                       |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_mode                                                 |
 |                    p_customer_trx_id                                      |
 |                    p_trx_number                                           |
 |                    p_line_number                                          |
 |                    p_other_line_number                                    |
 |                    p_message_name                                         |
 |                    p_error_location                                       |
 |                    p_token_name_1                                         |
 |                    p_token_1                                              |
 |                    p_token_name_2                                         |
 |                    p_token_2                                              |
 |                                                                           |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 |           IN/OUT:                                                         |
 |                    p_error_count                                          |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     07-DEC-95  Charlie Tomberg     Created                                |
 |     21-Aug-97  Mahesh Sabapathy    Default p_error_count to 0 when passed |
 |                                    in as NULL.                            |
 |                                                                           |
 +===========================================================================*/

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE add_to_error_list(
                                  p_mode              IN VARCHAR2,
                                  p_error_count       IN OUT NOCOPY INTEGER,
                                  p_customer_trx_id    IN  NUMBER,
                                  p_trx_number         IN  VARCHAR2,
                                  p_line_number        IN  NUMBER,
                                  p_other_line_number  IN  NUMBER,
                                  p_message_name       IN  VARCHAR2,
                                  p_error_location    IN varchar2 DEFAULT NULL,
                                  p_token_name_1      IN varchar2 DEFAULT NULL,
                                  p_token_1           IN varchar2 DEFAULT NULL,
                                  p_token_name_2      IN varchar2 DEFAULT NULL,
                                  p_token_2           IN varchar2 DEFAULT NULL,
                                  p_line_index        IN NUMBER   DEFAULT NULL,
                                  p_tax_index         IN NUMBER   DEFAULT NULL,
                                  p_freight_index     IN NUMBER   DEFAULT NULL,
                                  p_salescredit_index IN NUMBER   DEFAULT NULL
                                ) IS

   l_new_index    BINARY_INTEGER;

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_trx_validate.add_to_error_list()+');
   END IF;

   p_error_count := nvl(p_error_count,0) + 1;

 /*---------------------------------------------+
  |  Write error information to the debug pipe  |
  +---------------------------------------------*/

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('p_mode = ' || p_mode);
      arp_util.debug('adding: ctid: ' || p_customer_trx_id ||
                  '  trx_number: ' || p_trx_number ||
                  '  line: ' || TO_CHAR(p_line_number) || ',' ||
                  TO_CHAR(p_other_line_number) );
      arp_util.debug('  msg: ' || p_message_name || ' token 1 ' || p_token_1 ||
                  '  token 2 ' || p_token_2);
      arp_util.debug('error location: ' || p_error_location );
   END IF;

 /*---------------------+
  |  Process the error  |
  +---------------------*/

   fnd_message.set_name('AR', p_message_name);

   IF (p_token_1 IS NOT NULL )
   THEN
         fnd_message.set_token(p_token_name_1,
                               p_token_1);
   END IF;

   IF (p_token_2 IS NOT NULL )
   THEN
         fnd_message.set_token(p_token_name_2,
                               p_token_2);
   END IF;

   -- bug 2415895 : include p_mode = STANDARD, to ensure messages are loaded to message table

  -- Bug 2545343 : Reverted the fix for bug 2415895 to display proper error message

   IF (p_mode in ('PL/SQL'))
   THEN
        IF ( FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_ERROR ) )
        THEN
             fnd_message.set_name('AR', p_message_name);

             FND_MSG_PUB.Add;

             IF (p_token_1 IS NOT NULL )
             THEN
                   fnd_message.set_token(p_token_name_1,
                                         p_token_1);
             END IF;

             IF (p_token_2 IS NOT NULL )
             THEN
                   fnd_message.set_token(p_token_name_2,
                                         p_token_2);
             END IF;

        END IF;

        l_new_index := NVL(pg_Message_Tbl.last, 0) + 1;

        pg_Message_Tbl( l_new_index ).customer_trx_id     := p_customer_trx_id;
        pg_Message_Tbl( l_new_index ).line_number        := p_line_number;
        pg_Message_Tbl( l_new_index ).other_line_number      :=
                                                         p_other_line_number;

        pg_Message_Tbl( l_new_index ).line_index      := p_line_index;
        pg_Message_Tbl( l_new_index ).tax_index          := p_tax_index;
        pg_Message_Tbl( l_new_index ).freight_index        := p_freight_index;
        pg_Message_Tbl( l_new_index ).salescredit_index    := p_salescredit_index;

        pg_Message_Tbl( l_new_index ).message_name      := p_message_name;
        pg_Message_Tbl( l_new_index ).token_name_1      := p_token_name_1;
        pg_Message_Tbl( l_new_index ).token_1              := p_token_1;
        pg_Message_Tbl( l_new_index ).token_name_2      := p_token_name_2;
        pg_Message_Tbl( l_new_index ).token_2              := p_token_2;
        pg_Message_Tbl( l_new_index ).encoded_message     :=
                                                     fnd_message.get_encoded;

        fnd_message.set_name('AR', p_message_name);

        IF (p_token_1 IS NOT NULL )
        THEN
              fnd_message.set_token(p_token_name_1,
                                    p_token_1);
        END IF;

        IF (p_token_2 IS NOT NULL )
        THEN
              fnd_message.set_token(p_token_name_2,
                                    p_token_2);
        END IF;

        pg_Message_Tbl( l_new_index ).translated_message  := fnd_message.get;

   ELSE

        IF    (p_mode <> 'NO_EXCEPTION')
        THEN
              app_exception.raise_exception;
        END IF;
   END IF;


   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_trx_validate.add_to_error_list()-');
   END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('add_to_error_list: ' ||
                    'EXCEPTION:  arp_trx_validate.add_to_error_list()');
        END IF;
        RAISE;

END  add_to_error_list;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    ar_entity_version_check()                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_form_name                                             |
 |                   p_form_version                                          |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     05-JUL-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/


PROCEDURE ar_entity_version_check(p_form_name    IN varchar2,
                                  p_form_version IN number) IS


BEGIN

   arp_util.debug('ARP_TRX_VALIDATE.ar_entity_version_check()+');

   arp_util.debug('ARP_TRX_VALIDATE.ar_entity_version_check()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  ARP_TRX_VALIDATE.insert_batch()');
        RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_trx_number()                                                  |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_batch_source_id                                       |
 |                   p_trx_number                                            |
 |                   p_customer_trx_id                                       |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     30-OCT-95  Charlie Tomberg     Created                                |
 |     05-AUG-05  M Raymond           4537055 - Added support for batch
 |                                    source flag
 |                                    allow_duplicate_trx_num_flag'
 +===========================================================================*/

PROCEDURE validate_trx_number( p_batch_source_id IN NUMBER,
                               p_trx_number      IN  VARCHAR2,
                               p_customer_trx_id IN  NUMBER) IS

   -- get the flags for the batchsource
   CURSOR flags IS
     SELECT NVL(copy_doc_number_flag, 'N'),
            NVL(allow_duplicate_trx_num_flag, 'N')
     FROM   ra_batch_sources
     WHERE  batch_source_id = p_batch_source_id;

   -- check if the transaction number exists already
   CURSOR duptrx IS
      SELECT 'Y'   -- already exists in the transaction table
      FROM   ra_customer_trx
      WHERE  batch_source_id   = p_batch_source_id
      AND    trx_number        = p_trx_number
      AND    customer_trx_id  <> NVL(p_customer_trx_id, -99)
      UNION
      SELECT 'Y'  -- already exists in the interim table
      FROM   ra_recur_interim  ri,
             ra_customer_trx   ct
      WHERE  ct.customer_trx_id       = ri.customer_trx_id
      AND    ct.batch_source_id       = p_batch_source_id
      AND    ri.trx_number            = p_trx_number
      AND    NVL(ri.new_customer_trx_id, -98) <> NVL(p_customer_trx_id, -99)
      UNION
      SELECT 'Y'  -- already exists in the interface table
      FROM   ra_batch_sources    bs,
             ra_interface_lines  ril
      WHERE  ril.batch_source_name = bs.name
      AND    bs.batch_source_id    = p_batch_source_id
      AND    ril.trx_number        = p_trx_number
      AND    ril.customer_trx_id  <> NVL(p_customer_trx_id, -99);

   l_temp 		   VARCHAR2(1);
   l_copy_doc_num_flag	   ra_batch_sources_all.copy_doc_number_flag%TYPE;
   l_allow_duplicate_flag
     ra_batch_sources_all.allow_duplicate_trx_num_flag%TYPE;

BEGIN

   arp_util.debug('arp_trx_validate.validate_trx_number()+');

   /* Bug 2681166 Re-introduced the code commented out for bug 2493165 */

   /* Bug 2493165 Removed the following Document Sequencing changes
      to check for the copy_doc_number_flag before validating the
      Trx_Number . */

   /* Document sequencing changes: Check the copy document number flag
      in batch source. Validate the transaction number within batch
      source only if this flag is No */

  -- get the flags from the batch source.

  OPEN flags;
  FETCH flags INTO l_copy_doc_num_flag, l_allow_duplicate_flag;
  CLOSE flags;

  IF (l_copy_doc_num_flag = 'N' AND l_allow_duplicate_flag = 'N') THEN

    IF (p_batch_source_id  IS NOT NULL AND p_trx_number IS NOT NULL) THEN

      -- the fact that we got here means that duplicate trx numbers
      -- are not allowed.

      OPEN duptrx;
      FETCH duptrx INTO l_temp;

      IF duptrx%FOUND THEN
        -- a transaction number with the same value already exists,
        -- so disallow the creation of another with the same name.
        fnd_message.set_name('AR', 'AR_TW_INVALID_TRX_NUMBER');
        app_exception.raise_exception;
      END IF;

      CLOSE duptrx;

    END IF;

  END IF;
  arp_util.debug('ARP_TRX_VALIDATE.validate_trx_number()-');

EXCEPTION
  WHEN OTHERS THEN
    arp_util.debug('EXCEPTION:  arp_trx_validate.validate_trx_number()');
    RAISE;

END validate_trx_number;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_doc_number()                                                  |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_cust_trx_type_id                                      |
 |                   p_doc_sequence_value                                    |
 |                   p_customer_trx_id                                       |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     02-JUL-96  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/


PROCEDURE validate_doc_number( p_cust_trx_type_id          IN  NUMBER,
                               p_doc_sequence_value        IN  NUMBER,
                               p_customer_trx_id           IN  NUMBER  )
                            IS

   l_temp varchar2(1);

BEGIN

   arp_util.debug('ARP_TRX_VALIDATE.validate_doc_number()+');

   BEGIN

        IF (
                  p_cust_trx_type_id   IS NOT NULL
             AND
                  p_doc_sequence_value IS NOT NULL
           )
        THEN
              SELECT 'Y'   --already exists
              INTO   l_temp
              FROM   ra_recur_interim  ri,
                     ra_customer_trx   ct
              WHERE  ct.customer_trx_id       = ri.customer_trx_id
              AND    ct.cust_trx_type_id      = p_cust_trx_type_id
              AND    ri.doc_sequence_value    = p_doc_sequence_value
              AND    NVL(ri.new_customer_trx_id, -98)
                                             <> NVL(p_customer_trx_id, -99)
            UNION
              SELECT 'Y'
              FROM   ra_cust_trx_types   ctt,
                     ra_interface_lines  ril
              WHERE  ril.cust_trx_type_name     = ctt.name(+)
              AND    NVL(ril.cust_trx_type_id,
                         ctt.cust_trx_type_id)  = p_cust_trx_type_id
              AND    ril.document_number        = p_doc_sequence_value
              AND    ril.customer_trx_id       <> NVL(p_customer_trx_id, -99);

             fnd_message.set_name('FND', 'UNIQUE-DUPLICATE SEQUENCE');
             app_exception.raise_exception;

        END IF;

   EXCEPTION
      WHEN NO_DATA_FOUND
        THEN NULL;
      WHEN OTHERS THEN RAISE;
   END;

   arp_util.debug('ARP_TRX_VALIDATE.validate_doc_number()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  ARP_TRX_VALIDATE.validate_doc_number()');
        RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    check_dup_line_number                                                  |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Checks to see if a line number has already been used on a particular   |
 |    transaction.                                                           |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_line_number                                          |
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
 |     24-JUL-95  Charlie Tomberg     Created                                |
 |     14-DEC-95  Martin Johnson      Changed message name                   |
 |                                                                           |
 +===========================================================================*/


PROCEDURE check_dup_line_number( p_line_number      IN  NUMBER,
                                 p_customer_trx_id  IN  NUMBER,
                                 p_customer_trx_line_id  IN  NUMBER)
                             IS

   l_count  number;

BEGIN

   arp_util.debug('arp_trx_validate.check_dup_line_number()+');

   SELECT count(*)
   INTO   l_count
   FROM   ra_customer_trx_lines
   WHERE  customer_trx_id = p_customer_trx_id
   AND    line_number     = p_line_number
   AND    line_type       = 'LINE'
   AND    customer_trx_line_id <> nvl(p_customer_trx_line_id, -100);

   IF  (l_count > 0)
   THEN
         fnd_message.set_name('AR', 'AR_TW_DUP_LINE_NUM');
         app_exception.raise_exception;
   END IF;

   arp_util.debug('arp_trx_validate.check_dup_line_number()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_trx_validate.check_dup_line_number()');

        arp_util.debug('');
        arp_util.debug('----- parameters for check_dup_line_number() -------');

        arp_util.debug('p_line_number      = ' || p_line_number);
        arp_util.debug('p_customer_trx_id  = ' || p_customer_trx_id );

        RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    check_has_one_line                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Checks to see if the line that is about to be deleted is the last line |
 |    on the transaction.                                                    |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_id                                      |
 |                    p_display_message                                      |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     25-JUL-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/


PROCEDURE check_has_one_line( p_customer_trx_id  IN  NUMBER,
                              p_display_message IN varchar2 default 'Y' )
                             IS

   l_count  number;

BEGIN

   arp_util.debug('arp_trx_validate.check_has_one_line()+');

   SELECT count(*)
   INTO   l_count
   FROM   ra_customer_trx_lines
   WHERE  customer_trx_id = p_customer_trx_id
   AND    link_to_cust_trx_line_id is NULL;

   IF  (l_count <= 1)
   THEN

       IF (p_display_message = 'Y')
       THEN fnd_message.set_name('AR', '1210');
       END IF;

       app_exception.raise_exception;
   END IF;

   arp_util.debug('arp_trx_validate.check_has_one_line()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_trx_validate.check_has_one_line()');

        arp_util.debug('');
        arp_util.debug('----- parameters for check_has_one_line() -------');

        arp_util.debug('p_customer_trx_id  = ' || p_customer_trx_id );
        arp_util.debug('p_display_message  = ' || p_display_message );

        RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    check_sign_and_overapp                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Checks to see if the transaction violates the creation sign or         |
 |    overapplication constraints.                                           |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_id                                      |
 |                    p_previous_customer_trx_id                             |
 |                    p_trx_open_receivables_flag                            |
 |                    p_prev_open_receivables_flag                           |
 |                    p_creation_sign                                        |
 |                    p_allow_overapplication_flag                           |
 |                    p_natural_application_flag                             |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     05-SEP-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE check_sign_and_overapp(
                      p_customer_trx_id              IN  NUMBER,
                      p_previous_customer_trx_id     IN  NUMBER,
                      p_trx_open_receivables_flag    IN  VARCHAR2,
                      p_prev_open_receivables_flag   IN  VARCHAR2,
                      p_creation_sign                IN  VARCHAR2,
                      p_allow_overapplication_flag   IN  VARCHAR2,
                      p_natural_application_flag     IN  VARCHAR2
                   )
                             IS

l_error_count  NUMBER ;

BEGIN

     IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('arp_trx_validate.check_sign_and_overapp()+');
     END IF;

     check_sign_and_overapp(
	     p_customer_trx_id     => p_customer_trx_id,
           p_previous_customer_trx_id   => p_previous_customer_trx_id,
           p_trx_open_receivables_flag  => p_trx_open_receivables_flag,
           p_prev_open_receivables_flag => p_prev_open_receivables_flag,
           p_creation_sign              => p_creation_sign,
           p_allow_overapplication_flag => p_allow_overapplication_flag ,
           p_natural_application_flag   => p_natural_application_flag ,
           p_error_mode                 => 'STANDARD',
           p_error_count                => l_error_count
                       );

     IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('arp_trx_validate.check_sign_and_overapp()-');
     END IF;


END check_sign_and_overapp;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    check_sign_and_overapp                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Checks to see if the transaction violates the creation sign or         |
 |    overapplication constraints.                                           |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_id                                      |
 |                    p_previous_customer_trx_id                             |
 |                    p_trx_open_receivables_flag                            |
 |                    p_prev_open_receivables_flag                           |
 |                    p_creation_sign                                        |
 |                    p_allow_overapplication_flag                           |
 |                    p_natural_application_flag                             |
 |                    p_error_mode  -- Bug3041195                            |
 |              OUT:                                                         |
 |                    p_error_count -- Bug3041195                            |
 |                                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                 Sahana         Bug3041195: Overloaded procedure           |
 |                                check_sign_and_overapp. Additional         |
 |                                parameters p_error_mode and p_error_count. |
 |                                Handling of error message is done          |
 |                                by add_to_error_list (similar              |
 |                                to do_completion_checking )                |
 +===========================================================================*/


PROCEDURE check_sign_and_overapp(
                      p_customer_trx_id              IN  NUMBER,
                      p_previous_customer_trx_id     IN  NUMBER,
                      p_trx_open_receivables_flag    IN  VARCHAR2,
                      p_prev_open_receivables_flag   IN  VARCHAR2,
                      p_creation_sign                IN  VARCHAR2,
                      p_allow_overapplication_flag   IN  VARCHAR2,
                      p_natural_application_flag     IN  VARCHAR2,
                      p_error_mode                   IN  VARCHAR2,
                      p_error_count     OUT NOCOPY        NUMBER
                   )
                             IS

   l_line_original              NUMBER;
   l_line_remaining             NUMBER;
   l_tax_original               NUMBER;
   l_tax_remaining              NUMBER;
   l_freight_original           NUMBER;
   l_freight_remaining          NUMBER;
   l_charges_original           NUMBER;
   l_charges_remaining          NUMBER;
   l_total_original             NUMBER;
   l_total_remaining            NUMBER;

   l_prev_line_original         NUMBER;
   l_prev_line_remaining        NUMBER;
   l_prev_tax_original          NUMBER;
   l_prev_tax_remaining         NUMBER;
   l_prev_freight_original      NUMBER;
   l_prev_freight_remaining     NUMBER;
   l_prev_charges_original      NUMBER;
   l_prev_charges_remaining     NUMBER;
   l_prev_total_original        NUMBER;
   l_prev_total_remaining       NUMBER;

   l_new_line                   NUMBER;
   l_new_tax                    NUMBER;
   l_new_freight                NUMBER;

   /* Bug 882789 */
   l_commit_adj_amount        NUMBER;
  /* Bug 2534132 */
   l_commit_line_amount        NUMBER;
   l_commit_tax_amount         NUMBER;
   l_commit_frt_amount         NUMBER;

   l_error_count               NUMBER := 0;
   l_error_message             VARCHAR2(30);


BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Overloaded:arp_trx_validate.check_sign_and_overapp()+');
    END IF;


   /*-------------------------------------------------------------------+
    |  Get the previous balance and the new balance of the transaction. |
    |  get_summary_trx_balances() returns the previous balances         |
    |  because the payment schedules have not yet been updated.         |
    +-------------------------------------------------------------------*/

   arp_trx_util.get_summary_trx_balances(  p_customer_trx_id,
                                           p_trx_open_receivables_flag,
                                           l_line_original,
                                           l_line_remaining,
                                           l_tax_original,
                                           l_tax_remaining,
                                           l_freight_original,
                                           l_freight_remaining,
                                           l_charges_original,
                                           l_charges_remaining,
                                           l_total_original,
                                           l_total_remaining );

   SELECT SUM(
               DECODE( ctl.line_type,
                       'TAX',     0,
                       'FREIGHT', 0,
                                  ctl.extended_amount
                     )
             ),
          SUM(
               DECODE( ctl.line_type,
                       'TAX',  ctl.extended_amount,
                               0 )
             ),
          SUM(
               DECODE( ctl.line_type,
                       'FREIGHT',  ctl.extended_amount,
                                   0 )
             )
   INTO   l_new_line,
          l_new_tax,
          l_new_freight
   FROM   ra_customer_trx_lines ctl
   WHERE  customer_trx_id = p_customer_trx_id;


  /*------------------------------------------------------+
   |  Check the creation sign of the entire transaction   |
   +------------------------------------------------------*/

   arp_non_db_pkg.check_creation_sign(
                p_creation_sign => p_creation_sign,
                p_amount => l_new_line + l_new_tax + l_new_freight,
                event    => NULL,
                p_message_name  => l_error_message);


   /*Bug3041195*/
   IF ( l_error_message IS NOT NULL )
   THEN
          arp_trx_validate.add_to_error_list(
                              p_error_mode,
                              l_error_count,
                              p_previous_customer_trx_id,
                              NULL,  -- trx_number,
                              NULL,  -- line_number
                              NULL,  -- other_line_number
                              l_error_message,
                              'Check Creation Sign',
                              NULL,
                              NULL,
                              NULL,
                              NULL
                           );
   END IF;





   /*------------------------------------------------+
    |  If the current transaction is a credit memo,  |
    |  get the credited transaction balances         |
    +------------------------------------------------*/

   IF ( p_previous_customer_trx_id IS NOT NULL )
   THEN
        arp_trx_util.get_summary_trx_balances(  p_previous_customer_trx_id,
                                                p_prev_open_receivables_flag,
                                                l_prev_line_original,
                                                l_prev_line_remaining,
                                                l_prev_tax_original,
                                                l_prev_tax_remaining,
                                                l_prev_freight_original,
                                                l_prev_freight_remaining,
                                                l_prev_charges_original,
                                                l_prev_charges_remaining,
                                                l_prev_total_original,
                                                l_prev_total_remaining );

       /*-----------------------------------+
        |  Check overapplication for line   |
        +-----------------------------------*/

        /* Bug 882789: Get commitment adjustment amount for the credited
           transaction. This amount should be added to l_prev_line_remaining
           when checking natural application since the commitment adjustment
           will be reversed when we complete the credit memo. Otherwise,
           natural application checking will fail since the credit amount
           is more than the amount remaining for the credited transaction */

        /* Bug 2534132: Get Line,tax and freight buckets of the Commitment Adjustment
           and add to the line_remaining, tax_remaining and freight_remaining while
           checking natural application since the commitment adjustment will be reversed
           when we complete the credit memo. */

        select nvl(sum(amount),0),nvl(sum(line_adjusted),0),nvl(sum(tax_adjusted),0),nvl(sum(freight_adjusted),0)
        into l_commit_adj_amount,l_commit_line_amount,l_commit_tax_amount,l_commit_frt_amount
        from ar_adjustments
        where customer_trx_id = p_previous_customer_trx_id
        and receivables_trx_id = -1;



      arp_non_db_pkg.check_natural_application(
	    p_creation_sign		  =>  p_creation_sign,
	    p_allow_overapplication_flag	  =>
                                          p_allow_overapplication_flag,
	    p_natural_app_only_flag	  =>  p_natural_application_flag,
	    p_sign_of_ps		  =>   '+',
	    p_chk_overapp_if_zero	  =>  'Y',
	    p_payment_amount		  =>  l_new_line,
	    p_discount_taken	        =>  0,
	    p_amount_due_remaining	  => l_prev_line_remaining -
		            l_commit_line_amount - /* Bug 2534132 */
		            nvl(l_line_original, 0),
	    p_amount_due_original	  =>   l_prev_line_original,
	    event		              =>   NULL,
	    p_message_name		  =>   l_error_message,
	    p_lockbox_record		  =>   FALSE
                     );


      /*Bug3041195*/
      IF ( l_error_message IS NOT NULL )
      THEN
          arp_trx_validate.add_to_error_list(
                              p_error_mode,
                              l_error_count,
                              p_previous_customer_trx_id,
                              NULL,  -- trx_number,
                              NULL,  -- line_number
                              NULL,  -- other_line_number
                              l_error_message,
                              'Check overapplication for line',
                              NULL,
                              NULL,
                              NULL,
                              NULL
                           );
       END IF;



       /*----------------------------------+
        |  Check overapplication for tax   |
        +----------------------------------*/

      arp_non_db_pkg.check_natural_application(
		p_creation_sign		=>  p_creation_sign,
		p_allow_overapplication_flag	 =>
                                        p_allow_overapplication_flag,
		p_natural_app_only_flag	=>  p_natural_application_flag,
		p_sign_of_ps		=>   '+',
		p_chk_overapp_if_zero	=>   'Y',
		p_payment_amount		=>  l_new_tax,
		p_discount_taken		=>  0,
		p_amount_due_remaining	=>  l_prev_tax_remaining-
			l_commit_tax_amount-/*Bug2534132*/
			nvl(l_tax_original,0),
		p_amount_due_original	=>  l_prev_tax_original,
		event		            =>  NULL,
		p_message_name		=>  l_error_message,
		p_lockbox_record		=>  FALSE
                                           );

      /*Bug3041195*/
      IF ( l_error_message IS NOT NULL )
      THEN
          arp_trx_validate.add_to_error_list(
                              p_error_mode,
                              l_error_count,
                              p_previous_customer_trx_id,
                              NULL,  -- trx_number,
                              NULL,  -- line_number
                              NULL,  -- other_line_number
                              l_error_message,
                              'Check overapplication for Tax',
                              NULL,
                              NULL,
                              NULL,
                              NULL
                           );
       END IF;


       /*--------------------------------------+
        |  Check overapplication for freight   |
        +--------------------------------------*/

      arp_non_db_pkg.check_natural_application(
		p_creation_sign		=>  p_creation_sign,
		p_allow_overapplication_flag	=>
                                        p_allow_overapplication_flag,
		p_natural_app_only_flag	=>  p_natural_application_flag,
		p_sign_of_ps		=>  '+',
		p_chk_overapp_if_zero	=>  'Y',
		p_payment_amount		=>  l_new_freight,
		p_discount_taken		=>  0,
		p_amount_due_remaining	=>  l_prev_freight_remaining-
			l_commit_frt_amount-/*Bug2534132*/
			nvl(l_freight_original,0),
		p_amount_due_original	=>   l_prev_freight_original,
		event		            =>   NULL,
		p_message_name		=>   l_error_message,
		p_lockbox_record		=>  FALSE
                                           );

      /*Bug3041195*/
      IF ( l_error_message IS NOT NULL )
      THEN
          arp_trx_validate.add_to_error_list(
                              p_error_mode,
                              l_error_count,
                              p_previous_customer_trx_id,
                              NULL,  -- trx_number,
                              NULL,  -- line_number
                              NULL,  -- other_line_number
                              l_error_message,
                              'Check overapplication for Freight',
                              NULL,
                              NULL,
                              NULL,
                              NULL
                           );
       END IF;




   END IF;

   p_error_count := l_error_count;
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Overloaded:arp_trx_validate.check_sign_and_overapp()+');
   END IF;


EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION: arp_trx_validate.check_sign_and_overapp()');
        p_error_count := l_error_count;
        arp_util.debug('');
        arp_util.debug('----- parameters for check_sign_and_overapp() ------');

        arp_util.debug( 'p_customer_trx_id:                = ' ||
                         p_customer_trx_id );
        arp_util.debug( 'p_previous_customer_trx_id:       = ' ||
                         p_previous_customer_trx_id );
        arp_util.debug( 'p_trx_open_receivables_flag:      = ' ||
                         p_trx_open_receivables_flag );
        arp_util.debug( 'p_prev_open_receivables_flag:     = ' ||
                         p_prev_open_receivables_flag );
        arp_util.debug( 'p_creation_sign:                  = ' ||
                         p_creation_sign );
        arp_util.debug( 'p_allow_overapplication_flag:     = ' ||
                         p_allow_overapplication_flag );
        arp_util.debug( 'p_natural_application_flag:  = ' ||
                         p_natural_application_flag );

        RAISE;

END;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    validate_paying_customer()                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_paying_customer_id                                   |
 |                    p_trx_date                                             |
 |                    p_bill_to_customer_id                                  |
 |                    p_ct_prev_paying_customer_id                           |
 |                    p_currency_code                                        |
 |                    p_pay_unrelated_invoices_flag                          |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     10-MAY-96  Charlie Tomberg     Created                                |
 |     08-Sep-97  Debbie Jancis          Modified the select when            |
 |                                    pay_unrelated_invoice_flag is N to fix |
 |                                    defaulting problem in Bug 462569.      |
 +===========================================================================*/


FUNCTION validate_paying_customer( p_paying_customer_id           IN NUMBER,
                                   p_trx_date                     IN date,
                                   p_bill_to_customer_id          IN NUMBER,
                                   p_ct_prev_paying_customer_id   IN NUMBER,
                                   p_currency_code                IN varchar2,
                                   p_pay_unrelated_invoices_flag  IN varchar2,
                                   p_ct_prev_trx_date             IN date)
                                 RETURN BOOLEAN
                            IS

   l_paying_customer_is_valid varchar2(1);

BEGIN

   arp_util.debug('ARP_TRX_VALIDATE.validate_paying_customer()+');

   BEGIN

--ajay bug 1081390
--removed the condition to check that the paying customer should have a
--bank account.

   BEGIN

   IF (p_pay_unrelated_invoices_flag = 'Y')
   THEN

       SELECT  'Y'
       INTO   l_paying_customer_is_valid
       FROM   hz_cust_accounts cust_acct
       WHERE  cust_acct.cust_account_id                 = p_paying_customer_id
       AND    (
                  cust_acct.cust_account_id = p_ct_prev_paying_customer_id
               OR
                  (
                        cust_acct.status = 'A'
                  )
              );

   ELSE

       SELECT  'Y'
       INTO   l_paying_customer_is_valid
       FROM   hz_cust_accounts cust_acct
       WHERE  cust_acct.cust_account_id                 = p_paying_customer_id
       AND    (
                  cust_acct.cust_account_id = p_ct_prev_paying_customer_id
               OR
                  (
                        cust_acct.status = 'A'
                  )
              )
       AND EXISTS
                (
                   SELECT 'X'
                     FROM   hz_cust_acct_relate cr
                     WHERE  cr.related_cust_account_id =  p_bill_to_customer_id
                       AND    cr.status = 'A'
                       AND    cr.bill_to_flag = 'Y'
                       AND    CUST_ACCT.CUST_ACCOUNT_ID = CR.CUST_ACCOUNT_ID
                   UNION ALL
                   SELECT 'X'
                     FROM   dual
                     where cust_acct.cust_account_id = TO_NUMBER(p_ct_prev_paying_customer_id)
                   UNION ALL
                   SELECT 'X'
                     FROM   dual
                     WHERE cust_acct.cust_account_id =TO_NUMBER(p_bill_to_customer_id)
                   UNION ALL
                   SELECT 'X'
                     FROM ar_paying_relationships_v rel,
                           hz_cust_accounts acc
                     WHERE rel.party_id = acc.party_id
                       AND rel.related_cust_account_id = p_bill_to_customer_id
                       AND p_ct_prev_trx_date BETWEEN effective_start_date
                                                  AND effective_end_date
                       AND  CUST_ACCT.CUST_ACCOUNT_ID = ACC.CUST_ACCOUNT_ID
                );

   END IF;

   EXCEPTION
     WHEN no_data_found THEN
     l_paying_customer_is_valid := 'N';

   END ;


   IF (l_paying_customer_is_valid = 'Y')
   THEN  RETURN(TRUE);
   ELSE  RETURN(FALSE);
   END IF;

   EXCEPTION
      WHEN OTHERS THEN RAISE;
   END;

   arp_util.debug('ARP_TRX_VALIDATE.validate_paying_customer()-');

EXCEPTION
    WHEN OTHERS THEN
       arp_util.debug('EXCEPTION:  ARP_TRX_VALIDATE.validate_paying_customer()');
       RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_trx_date()                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validates that all entities that have date ranges are still valid after|
 |    the transaction date changes.                                          |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_trx_date                                               |
 |                  p_prev_trx_date                                          |
 |                  p_commitment_trx_date                                    |
 |                  p_customer_trx_id                                        |
 |                  p_customer_trx_id                                        |
 |                  p_previous_customer_trx_id                               |
 |                  p_initial_customer_trx_id                                |
 |                  p_agreement_id                                           |
 |                  p_batch_source_id                                        |
 |                  p_cust_trx_type_id                                       |
 |                  p_term_id                                                |
 |                  p_ship_method_code                                       |
 |                  p_primary_salesrep_id                                    |
 |                  p_reason_code                                            |
 |                  p_status_trx                                             |
 |                  p_invoice_currency_code                                  |
 |                  p_receipt_method_id                                      |
 |                  p_bank_account_id                                        |
 |              OUT:                                                         |
 |                  p_due_date                                               |
 |                  p_result_flag                                            |
 |                  p_commitment_invalid_flag                                |
 |                  p_invalid_agreement_flag                                 |
 |                  p_invalid_source_flag                                    |
 |                  p_invalid_type_flag                                      |
 |                  p_invalid_term_flag                                      |
 |                  p_invalid_ship_method_flag                               |
 |                  p_invalid_primary_srep_flag                              |
 |                  p_invalid_reason_flag                                    |
 |                  p_invalid_status_flag                                    |
 |                  p_invalid_currency_flag                                  |
 |                  p_invalid_payment_mthd_flag                              |
 |                  p_invalid_bank_flag                                      |
 |                  p_invalid_salesrep_flag                                  |
 |                  p_invalid_memo_line_flag                                 |
 |                  p_invalid_uom_flag                                       |
 |                  p_invalid_tax_flag                                       |
 |                  p_invalid_cm_date_flag                                   |
 |                  p_invalid_child_date_flag                                |
 |                                                                           |
 |         IN / OUT:                                                         |
 |                  p_error_count                                            |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     31-OCT-95  Charlie Tomberg     Created                                |
 |     18-MAR-96  Martin Johnson      Removed validation of UOM since it     |
 |                                    is no longer validated against trx_date|
 |                                    (part of BugNo:337819)                 |
 |     22-MAY-2000 J Rautiainen       BR Implementation                      |
 |     28-SEP-2001 M Raymond          Performance problem in validate_trx_date
 |                                    caused by FTS of ra_cust_receipt_methods
 |                                    See bug 2001878 for details.           |
 |     18-JAN-2002 M Raymond          Fix for 2001878 introduced a requirement
 |                                    for payment methods at site level.
 |                                    Revised fix to allow for null methods
 |                                    at site level. See bug 2176210 for det.
 |     22-FEB-2002 M Raymond          Bug 2195793 - added validation for
 |                                    commitments with zero balance.
 |     02-MAY-2002 M Raymond         Bug 2340543 - Validation for 2195793
 |                                   should not fire for credit memos.
 |
 +===========================================================================*/

PROCEDURE validate_trx_date( p_error_mode                    IN VARCHAR2,
                             p_trx_date                      IN  DATE,
                             p_prev_trx_date                 IN  DATE,
                             p_commitment_trx_date           IN  DATE,
                             p_customer_trx_id               IN  NUMBER,
                             p_trx_number                    IN  VARCHAR2,
                             p_previous_customer_trx_id      IN  NUMBER,
                             p_initial_customer_trx_id       IN  NUMBER,
                             p_agreement_id                  IN  NUMBER,
                             p_batch_source_id               IN  NUMBER,
                             p_cust_trx_type_id              IN  NUMBER,
                             p_term_id                       IN  NUMBER,
                             p_ship_method_code              IN  VARCHAR2,
                             p_primary_salesrep_id           IN  NUMBER,
                             p_reason_code                   IN  VARCHAR2,
                             p_status_trx                    IN  VARCHAR2,
                             p_invoice_currency_code         IN  VARCHAR2,
                             p_receipt_method_id             IN  NUMBER,
                             p_bank_account_id               IN  NUMBER,
                             p_due_date                     OUT NOCOPY date,
                             p_result_flag                  OUT NOCOPY boolean,
                             p_commitment_invalid_flag      OUT NOCOPY boolean,
                             p_invalid_agreement_flag       OUT NOCOPY boolean,
                             p_invalid_source_flag          OUT NOCOPY boolean,
                             p_invalid_type_flag            OUT NOCOPY boolean,
                             p_invalid_term_flag            OUT NOCOPY boolean,
                             p_invalid_ship_method_flag     OUT NOCOPY boolean,
                             p_invalid_primary_srep_flag    OUT NOCOPY boolean,
                             p_invalid_reason_flag          OUT NOCOPY boolean,
                             p_invalid_status_flag          OUT NOCOPY boolean,
                             p_invalid_currency_flag        OUT NOCOPY boolean,
                             p_invalid_payment_mthd_flag    OUT NOCOPY boolean,
                             p_invalid_bank_flag            OUT NOCOPY boolean,
                             p_invalid_salesrep_flag        OUT NOCOPY boolean,
                             p_invalid_memo_line_flag       OUT NOCOPY boolean,
                             p_invalid_uom_flag             OUT NOCOPY boolean,
                             p_invalid_tax_flag             OUT NOCOPY boolean,
                             p_invalid_cm_date_flag         OUT NOCOPY boolean,
                             p_invalid_child_date_flag      OUT NOCOPY boolean,
                             p_error_count               IN OUT NOCOPY integer
                       ) IS

   l_temp    varchar2(128);
   l_temp2   varchar2(128);
   l_commit_bal  NUMBER;
   l_so_source_code  varchar2(100);

  /*--------------------------------------------------------------------+
   | 23-MAY-2000 J Rautiainen BR Implementation                         |
   | BR payment method does not have bank account associated with it    |
   | This cursor is used to branch code into a correct select statement |
   | in the payment method validation.                                  |
   +--------------------------------------------------------------------*/
  CURSOR receipt_creation_method_cur IS
    SELECT arc.creation_method_code
    FROM   ar_receipt_methods     arm,
           ar_receipt_classes     arc
    WHERE  arm.receipt_class_id   = arc.receipt_class_id
    AND    arm.receipt_method_id  = p_receipt_method_id;

  receipt_creation_method_rec receipt_creation_method_cur%ROWTYPE;

  /*Bug3348454 */
  l_bill_to_customer_id		ra_customer_trx.bill_to_customer_id%TYPE;
  l_paying_customer_id		ra_customer_trx.paying_customer_id%TYPE;

BEGIN

   arp_util.debug('ARP_TRX_VALIDATE.validate_trx_date()+');

   p_result_flag := TRUE;

  /*------------------------------------------------------------------+
   |  Validate that CM Date is >= the credited transaction's trx_date |
   +------------------------------------------------------------------*/

   arp_util.debug('Validate that CM Date is >= the credited transaction''s '||
                  'trx_date');

   IF (  p_trx_date < p_prev_trx_date )
   THEN
            p_invalid_cm_date_flag  := TRUE;
            p_result_flag           := FALSE;

            add_to_error_list(
                                p_error_mode,
                                p_error_count,
                                p_customer_trx_id,
                                p_trx_number,
                                NULL,
                                NULL,
                                'AR_TW_BAD_DATE_CM_DATE',
                                'TGW_HEADER.TRX_DATE',
                                NULL,
                                NULL,
                                NULL,
                                NULL
                             );

   END IF;

  /*---------------------------------------------------------------+
   |  Validate that the Child Date is >= the commitment's trx_date |
   +----------------------------------------------------------------*/

   arp_util.debug(
              'Validate that the Child Date is >= the commitment''s trx_date');

   IF (  p_trx_date < p_commitment_trx_date )
   THEN
            p_invalid_child_date_flag  := TRUE;
            p_result_flag              := FALSE;


            add_to_error_list(
                                p_error_mode,
                                p_error_count,
                                p_customer_trx_id,
                                p_trx_number,
                                NULL,
                                NULL,
                                'AR_TW_BAD_DATE_CHILD_DATE',
                                'TGW_HEADER.TRX_DATE',
                                NULL,
                                NULL,
                                NULL,
                                NULL
                             );


   END IF;

  /*-----------------------+
   |  Validate Commitment  |
   +-----------------------*/

  arp_util.debug('Validate Commitment');

  /* Bug 2340543 - Do not test commitment balance or date for
       credit memos */
  IF ( p_initial_customer_trx_id IS NOT NULL AND
       p_previous_customer_trx_id IS NULL)
  THEN

       /* Bug 2195793 - We have determined that it is a problem if
          you have an invoice pointing to a commitment if that
          commitment was exhausted by prior transactions.

          This could be caused by invoice copy (where commitment
          gets exhausted before last invoice is created) or if
          you leave invoices incomplete with a commitment assigned
          to them.

          To prevent this, we added a call to arp_bal_util to
          get the commitment balance at that moment.  If it is
          exhausted, we will flag an error. */

      BEGIN
            oe_profile.get( 'SO_SOURCE_CODE', l_so_source_code );

            SELECT  'invoice date is ok',
                    arp_bal_util.get_commitment_balance(
                             p_initial_customer_trx_id,
                             tt.TYPE,
                             l_so_source_code,
                             'N')
            INTO    l_temp,
                    l_commit_bal
            FROM    ra_customer_trx t,
                    ra_cust_trx_types tt
            WHERE   t.customer_trx_id = p_initial_customer_trx_id
            AND     t.cust_trx_type_id = tt.cust_trx_type_id
            AND     p_trx_date
            BETWEEN NVL( t.start_date_commitment, p_trx_date )
                AND NVL( t.end_date_commitment,   p_trx_date );

            IF (l_commit_bal = 0)
            THEN
              p_commitment_invalid_flag := TRUE;
              p_result_flag := FALSE;

              add_to_error_list(
                                p_error_mode,
                                p_error_count,
                                p_customer_trx_id,
                                p_trx_number,
                                NULL,
                                NULL,
                                'AR_ZERO_COMMITMENT',
                                'TGW_HEADER.CT_COMMITMENT_NUMBER',
                                NULL,
                                NULL,
                                NULL,
                                NULL
                             );

            END IF;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
              p_commitment_invalid_flag := TRUE;
              p_result_flag := FALSE;

              add_to_error_list(
                                p_error_mode,
                                p_error_count,
                                p_customer_trx_id,
                                p_trx_number,
                                NULL,
                                NULL,
                                'AR_TW_BAD_DATE_COMMITMENT',
                                'TGW_HEADER.CT_COMMITMENT_NUMBER',
                                NULL,
                                NULL,
                                NULL,
                                NULL
                             );

         WHEN OTHERS THEN RAISE;
      END;

  END IF;


  /*----------------------+
   |  Validate Agreement  |
   +----------------------*/

  arp_util.debug('Validate Agreement');

  IF   (p_agreement_id IS NOT NULL)
  THEN
       BEGIN
              SELECT 'invoice date is ok'
              INTO   l_temp
              FROM   so_agreements
              WHERE  agreement_id = p_agreement_id
              AND    p_trx_date  BETWEEN NVL(TRUNC(start_date_active),
                                             p_trx_date )
                                     AND NVL(TRUNC(end_date_active),
                                              p_trx_date);

       EXCEPTION
           WHEN NO_DATA_FOUND THEN
                p_invalid_agreement_flag := TRUE;
                p_result_flag := FALSE;

                add_to_error_list(
                                p_error_mode,
                                p_error_count,
                                p_customer_trx_id,
                                p_trx_number,
                                NULL,
                                NULL,
                                'AR_TW_BAD_DATE_AGREEMENT',
                                'TGW_HEADER.SOA_AGREEMENT_NAME',
                                NULL,
                                NULL,
                                NULL,
                                NULL
                             );

           WHEN OTHERS THEN RAISE;
       END;
  END IF;

  /*-------------------------+
   |  Validate Batch Source  |
   +-------------------------*/

  arp_util.debug('Validate Batch Source');

  IF   (p_batch_source_id IS NOT NULL)
  THEN
       BEGIN

              SELECT 'invoice date is ok'
              INTO   l_temp
              FROM   ra_batch_sources
              WHERE  batch_source_id = p_batch_source_id
                AND  p_trx_date BETWEEN NVL(start_date, p_trx_date)
                                    AND NVL(end_date,   p_trx_date);

       EXCEPTION
           WHEN NO_DATA_FOUND THEN
                p_invalid_source_flag := TRUE;
                p_result_flag := FALSE;

                add_to_error_list(
                                p_error_mode,
                                p_error_count,
                                p_customer_trx_id,
                                p_trx_number,
                                NULL,
                                NULL,
                                'AR_TW_BAD_DATE_SOURCE',
                                'TGW_HEADER.BS_BATCH_SOURCE_NAME',
                                NULL,
                                NULL,
                                NULL,
                                NULL
                             );

           WHEN OTHERS THEN RAISE;
       END;
  END IF;


  /*-----------------+
   |  Validate Type  |
   +-----------------*/

  arp_util.debug('Validate Type');

  IF ( p_cust_trx_type_id IS NOT NULL )
  THEN
        BEGIN
               SELECT tax_calculation_flag
               INTO   l_temp
               FROM   ra_cust_trx_types
               WHERE  CUST_TRX_TYPE_ID = p_cust_trx_type_id
               AND    p_trx_date  BETWEEN START_DATE
                                      AND NVL(END_DATE, p_trx_date);


       EXCEPTION
           WHEN NO_DATA_FOUND THEN
                p_invalid_type_flag := TRUE;
                p_result_flag := FALSE;

                add_to_error_list(
                                p_error_mode,
                                p_error_count,
                                p_customer_trx_id,
                                p_trx_number,
                                NULL,
                                NULL,
                                'AR_TW_BAD_DATE_TRX_TYPE',
                                'TGW_HEADER.CTT_TYPE_NAME',
                                NULL,
                                NULL,
                                NULL,
                                NULL
                             );

           WHEN OTHERS THEN RAISE;
       END;
  END IF;



  /*------------------+
   |  Validate Terms  |
   +------------------*/

  arp_util.debug('Validate Terms');

  IF    ( p_term_id IS NOT NULL )
  THEN
        BEGIN

               SELECT 'invoice date is ok'
               INTO   l_temp
               FROM   ra_terms
               WHERE  term_id = p_term_id
               AND    p_trx_date  BETWEEN START_DATE_ACTIVE
                                      AND NVL(END_DATE_ACTIVE,  p_trx_date);

       EXCEPTION
           WHEN NO_DATA_FOUND THEN
                p_invalid_term_flag := TRUE;
                p_result_flag := FALSE;

                add_to_error_list(
                                p_error_mode,
                                p_error_count,
                                p_customer_trx_id,
                                p_trx_number,
                                NULL,
                                NULL,
                                'AR_TW_BAD_DATE_TERM',
                                'TGW_HEADER.RAT_TERM_NAME',
                                NULL,
                                NULL,
                                NULL,
                                NULL
                             );

           WHEN OTHERS THEN RAISE;
       END;
  END IF;



  /*---------------------+
   |  Validate ship via  |
   +---------------------*/

  arp_util.debug('Validate ship via');

  IF ( p_ship_method_code IS NOT NULL )
  THEN

         BEGIN

               SELECT 'invoice date is ok'
               INTO   l_temp
               FROM   ORG_FREIGHT
               WHERE  freight_code    = p_ship_method_code
               AND    organization_id =
                              to_number(oe_profile.value('SO_ORGANIZATION_ID',arp_global.sysparam.org_id))
               AND p_trx_date <  NVL(TRUNC(DISABLE_DATE),  p_trx_date + 1);

       EXCEPTION
           WHEN NO_DATA_FOUND THEN
                p_invalid_ship_method_flag := TRUE;
                p_result_flag := FALSE;

                add_to_error_list(
                                p_error_mode,
                                p_error_count,
                                p_customer_trx_id,
                                p_trx_number,
                                NULL,
                                NULL,
                                'AR_TW_BAD_DATE_SHIP_METHOD',
                                'TFRT_HEADER.of_ship_via_description',
                                NULL,
                                NULL,
                                NULL,
                                NULL
                             );

           WHEN OTHERS THEN RAISE;
       END;
  END IF;


  /*---------------------+
   |  Validate CM Reason |
   +---------------------*/

  arp_util.debug('Validate CM Reason');

  IF (     p_previous_customer_trx_id  IS NOT NULL
       AND
           p_reason_code               IS NOT NULL
     )
  THEN
      BEGIN

            SELECT  'reason code is ok'
            INTO    l_temp
            FROM    ar_lookups
            WHERE   lookup_type = 'CREDIT_MEMO_REASON'
            AND     lookup_code =  p_reason_code
            AND     p_trx_date
            BETWEEN NVL( start_date_active, p_trx_date )
                AND NVL( end_date_active,   p_trx_date );

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
              p_invalid_reason_flag := TRUE;
              p_result_flag := FALSE;

              add_to_error_list(
                                p_error_mode,
                                p_error_count,
                                p_customer_trx_id,
                                p_trx_number,
                                NULL,
                                NULL,
                                'AR_TW_BAD_DATE_REASON',
                                'TGW_HEADER.AL_REASON_MEANING',
                                NULL,
                                NULL,
                                NULL,
                                NULL
                             );

         WHEN OTHERS THEN RAISE;
      END;

  END IF;



  /*-------------------+
   |  Validate Status  |
   +-------------------*/

  arp_util.debug('Validate Status');

  IF ( p_status_trx                IS NOT NULL )
  THEN
      BEGIN

            SELECT  'status code is ok'
            INTO    l_temp
            FROM    ar_lookups
            WHERE   lookup_type = 'INVOICE_TRX_STATUS'
            AND     lookup_code =  p_status_trx
            AND     p_trx_date
            BETWEEN NVL( start_date_active, p_trx_date )
                AND NVL( end_date_active,   p_trx_date );

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
              p_invalid_status_flag := TRUE;
              p_result_flag := FALSE;

              add_to_error_list(
                                p_error_mode,
                                p_error_count,
                                p_customer_trx_id,
                                p_trx_number,
                                NULL,
                                NULL,
                                'AR_TW_BAD_DATE_STATUS',
                                'TGW_HEADER.STATUS_TRX',
                                NULL,
                                NULL,
                                NULL,
                                NULL
                             );

         WHEN OTHERS THEN RAISE;
      END;

  END IF;



  /*----------------------------------------------------------------------+
   |  If the transaction that is being validated is a credit memo         |
   |  against a specific invoice, commitment or debit memo, the           |
   |  following validations are not done in order to allow these          |
   |  entities to default in from the transaction that is being credited. |
   +----------------------------------------------------------------------*/

  IF (p_previous_customer_trx_id  IS NULL)
  THEN

     /*-----------------------------+
      |  Validate Primary Salesrep  |
      +-----------------------------*/

     arp_util.debug('Validate Primary Salesrep');

     IF ( p_primary_salesrep_id IS NOT NULL )
     THEN
          BEGIN

                 SELECT 'invoice date is ok'
                 INTO   l_temp
                 FROM ra_salesreps
                 WHERE salesrep_id = p_primary_salesrep_id
                 AND    p_trx_date BETWEEN NVL(start_date_active,
                                               p_trx_date)
                                   AND     NVL(end_date_active,
                                               p_trx_date);


          EXCEPTION
           WHEN NO_DATA_FOUND THEN
                p_invalid_primary_srep_flag := TRUE;
                p_result_flag := FALSE;

                /* Bug 2191739 - call to message API for degovtized message */
                add_to_error_list(
                            p_error_mode,
                            p_error_count,
                            p_customer_trx_id,
                            p_trx_number,
                            NULL,
                            NULL,
                            gl_public_sector.get_message_name
                               (p_message_name => 'AR_TW_BAD_DATE_PRIMARY_SREP',
                                p_app_short_name => 'AR'),
                            'TGW_HEADER.RAS_PRIMARY_SALESREP_NAME',
                            NULL,
                            NULL,
                            NULL,
                            NULL
                             );

           WHEN OTHERS THEN RAISE;
           END;
     END IF;

     /*---------------------+
      |  Validate Currency  |
      +---------------------*/

     arp_util.debug('Validate Currency');

     IF ( p_invoice_currency_code  IS NOT NULL )
     THEN
           BEGIN

                 SELECT 'invoice date is ok'
                 INTo   l_temp
                 FROM   fnd_currencies
                 WHERE  currency_code = p_invoice_currency_code
                 AND    p_trx_date  BETWEEN NVL(START_DATE_ACTIVE, p_trx_date)
                                        AND NVL(END_DATE_ACTIVE,   p_trx_date);

        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              p_invalid_currency_flag := TRUE;
              p_result_flag := FALSE;

              add_to_error_list(
                                p_error_mode,
                                p_error_count,
                                p_customer_trx_id,
                                p_trx_number,
                                NULL,
                                NULL,
                                'AR_TW_BAD_DATE_CURRENCY',
                                'TGW_HEADER.INVOICE_CURRENCY_CODE',
                                NULL,
                                NULL,
                                NULL,
                                NULL
                             );

           WHEN OTHERS THEN RAISE;
        END;
     END IF;



     /*---------------------------+
      |  Validate Receipt Method  |
      +---------------------------*/

     arp_util.debug('Validate Receipt Method');

--Modified the IF condition to fix Bug 2162888, added the check for customer_trx_id
     IF ( p_receipt_method_id IS NOT NULL ) AND ( p_customer_trx_id IS NOT NULL )
     THEN

      /*--------------------------------------------------------------------+
       | 23-MAY-2000 J Rautiainen BR Implementation                         |
       | BR payment method does not have bank account associated with it    |
       +--------------------------------------------------------------------*/
       OPEN receipt_creation_method_cur;
       FETCH receipt_creation_method_cur INTO receipt_creation_method_rec;
       CLOSE receipt_creation_method_cur;

       IF NVL(receipt_creation_method_rec.creation_method_code,'INV') = 'BR' THEN
          BEGIN

	   /*Bug3348454 Need not validate the customer attachment.
	     Only validate the receipt method*/

           SELECT     'invalid_payment method'
           INTO       l_temp
           FROM       ar_receipt_methods             arm,
                      ar_receipt_classes             arc
           WHERE      arm.receipt_class_id   = arc.receipt_class_id
           AND        arm.receipt_method_id  = p_receipt_method_id
           AND        p_trx_date BETWEEN NVL(arm.start_date,
                                             p_trx_date)
                                     AND NVL(arm.end_date,
                                             p_trx_date)
           AND        rownum = 1;

          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                p_invalid_payment_mthd_flag := TRUE;
                p_result_flag := FALSE;

                add_to_error_list(
                                p_error_mode,
                                p_error_count,
                                p_customer_trx_id,
                                p_trx_number,
                                NULL,
                                NULL,
                                'AR_TW_BAD_DATE_PAYMENT_METHOD',
                                'TGW_HEADER.ARM_RECEIPT_METHOD_NAME',
                                NULL,
                                NULL,
                                NULL,
                                NULL
                             );

             WHEN OTHERS THEN RAISE;
          END;

       ELSE
          BEGIN

	      /* If Payment Creation Code is NON BR then validate bank accounts also for this
                 receipt method accounts */

              BEGIN
		 SELECT arp_trx_defaults_3.get_party_id(paying_customer_id),
			arp_trx_defaults_3.get_party_id(bill_to_customer_id)
		 INTO l_paying_customer_id,l_bill_to_customer_id
		 FROM RA_CUSTOMER_TRX
		 WHERE customer_trx_id=p_customer_trx_id;
	      EXCEPTION
		 WHEN OTHERS THEN
		   RAISE;
	      END;

	     /* We need to validate the following.
	        1. Receipt Method end date.
		2. Receipt method account end date
		3. Receipt method should have atleast one
		   bank account with valid end dates
		4. Also bank account should be of invoice currency or
		   multi currency enabled.
	        5. and that valid bank account should have
		   atleast one bank valid branch.
		6. Additionally If payment method creation is MANUAL or AUTOMATIC
		   then the trx currency is as same as payment method currency or
		   multi currency flag should be 'Y'
		7. For Automatic methods if Payment type is NOT CREDIT_CARD
		   additionally the currency should be defined or associated
		   with paying or bill to customer bank accounts.This condition is
		   taken from paying customer payment method LOV.. to keep the
		   both validations in sync.*/

           SELECT     'invalid_payment method'
           INTO       l_temp
           FROM       ar_receipt_methods             arm,
                      ar_receipt_method_accounts     arma,
                      ce_bank_accounts     	     cba,
                      ce_bank_acct_uses              aba,
                      ar_receipt_classes             arc,
                      ce_bank_branches_v	     bp
           WHERE      arm.receipt_method_id  = arma.receipt_method_id
           AND        arm.receipt_class_id   = arc.receipt_class_id
           AND        arma.remit_bank_acct_use_id  = aba.bank_acct_use_id
           AND        aba.bank_account_id    = cba.bank_account_id
           /* New Condition added Begin*/
	   AND	      bp.branch_party_id = cba.bank_branch_id
	   AND	      p_trx_date	 <= NVL(bp.end_date,p_trx_date)
	   AND        (cba.currency_code = p_invoice_currency_code or
		             cba.receipt_multi_currency_flag ='Y') /* New condition */
           /*Removing the join consition based on currency code as part of bug fix 5346710
	   AND (arc.creation_method_code='MANUAL'
    		     or (arc.creation_method_code='AUTOMATIC'
                     and ( (nvl(arm.payment_channel_code,'*') = 'CREDIT_CARD' )
                     or
                     (nvl(arm.payment_channel_code,'*') <> 'CREDIT_CARD'
                     AND p_invoice_currency_code in
                         (select currency_code from iby_fndcpt_payer_assgn_instr_v where
		         party_id in (l_paying_customer_id,l_bill_to_customer_id))))))*/
           /* New Condition added Ends*/
           -- AND        aba.set_of_books_id    = arp_global.set_of_books_id
           AND        arm.receipt_method_id  = p_receipt_method_id
           AND        p_trx_date             <  NVL(cba.end_date,
                                                    TO_DATE('01/01/2200','DD/MM/YYYY') )
           AND        p_trx_date BETWEEN NVL(arm.start_date,
                                             p_trx_date)
                                     AND NVL(arm.end_date,
                                             p_trx_date)
           AND        p_trx_date BETWEEN NVL(arma.start_date,
                                             p_trx_date)
                                     AND NVL(arma.end_date,
                                             p_trx_date)
           AND        rownum = 1;

          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                p_invalid_payment_mthd_flag := TRUE;
                p_result_flag := FALSE;

                add_to_error_list(
                                p_error_mode,
                                p_error_count,
                                p_customer_trx_id,
                                p_trx_number,
                                NULL,
                                NULL,
                                'AR_TW_BAD_DATE_PAYMENT_METHOD',
                                'TGW_HEADER.ARM_RECEIPT_METHOD_NAME',
                                NULL,
                                NULL,
                                NULL,
                                NULL
                             );

             WHEN OTHERS THEN RAISE;
          END;
       END IF;
     END IF;


     /*--------------------------+
      |  Validate Customer Bank  |
      +--------------------------*/

     arp_util.debug('Validate Customer Bank'|| 'not reqd any more');
/* payment uptake removed validation for customer bank bug4646161 */



     /*----------------------+
      |  Validate Salesreps  |
      +----------------------*/

     arp_util.debug('Validate Salesreps');

     IF ( p_customer_trx_id IS NOT NULL )
     THEN
           BEGIN
                  l_temp := NULL;

                  SELECT  MIN(s.name),
                          TO_CHAR(MIN(ctl.line_number))
                  INTO    l_temp,
                          l_temp2
                  FROM    ra_cust_trx_line_salesreps ls,
                          ra_customer_trx_lines      ctl,
                          ra_salesreps               s
                  WHERE   ls.salesrep_id          = s.salesrep_id
                  AND     ls.customer_trx_id      = p_customer_trx_id
                  AND     ls.customer_trx_line_id = ctl.customer_trx_line_id(+)
                  AND      p_trx_date  NOT BETWEEN NVL(s.start_date_active,
                                                       p_trx_date)
                                               AND NVL(s.end_date_active,
                                                       p_trx_date);

                  IF ( l_temp || l_temp2 IS NOT NULL )
                  THEN
                        p_invalid_salesrep_flag := TRUE;
                        p_result_flag := FALSE;


                       /*----------------------------------------+
                        |  If no line number has been selected,  |
                        |  this is a default salescredit line.   |
                        +----------------------------------------*/

                        IF (l_temp2 IS NOT NULL)
                        THEN

                /* Bug 2191739 - call to message API for degovtized message */
                             add_to_error_list(
                                 p_error_mode,
                                 p_error_count,
                                 p_customer_trx_id,
                                 p_trx_number,
                                 l_temp2,
                                 NULL,
                                 gl_public_sector.get_message_name
                                  (p_message_name => 'AR_TW_BAD_DATE_SALESREP',
                                   p_app_short_name => 'AR'),
                                 'TGW_HEADER.TRX_DATE',
                                 'SALESREP_NAME',
                                 l_temp,
                                 'LINE_NUMBER',
                                 l_temp2
                                              );

                        ELSE

                /* Bug 2191739 - call to message API for degovtized message */
                             add_to_error_list(
                              p_error_mode,
                              p_error_count,
                              p_customer_trx_id,
                              p_trx_number,
                              l_temp2,
                              NULL,
                              gl_public_sector.get_message_name
                               (p_message_name => 'AR_TW_BAD_DATE_DEFAULT_SREP',
                                p_app_short_name => 'AR'),
                              'TGW_HEADER.TRX_DATE',
                              'SALESREP_NAME',
                              l_temp,
                              NULL,
                              NULL
                                              );

                        END IF;

                  END IF;

           EXCEPTION
              WHEN NO_DATA_FOUND THEN NULL;
              WHEN OTHERS THEN RAISE;
           END;
     END IF;


     /*----------------------+
      |  Validate Memo Line  |
      +----------------------*/

     arp_util.debug('Validate Memo Line');

     IF ( p_customer_trx_id  IS NOT NULL )
     THEN
           BEGIN

                  SELECT TO_CHAR(MIN(lines.line_number))
                  INTO   l_temp
                  FROM   ra_customer_trx_lines lines,
                         ar_memo_lines aml
                  WHERE  lines.customer_trx_id = p_customer_trx_id
                  AND    lines.memo_line_id    = aml.memo_line_id
                  AND    p_trx_date NOT BETWEEN NVL(aml.start_date, p_trx_date)
                                            AND NVL(aml.end_date, p_trx_date);

                  IF (l_temp  IS NOT NULL )
                  THEN

                         p_invalid_memo_line_flag := TRUE;
                         p_result_flag := FALSE;

                         add_to_error_list(
                                            p_error_mode,
                                            p_error_count,
                                            p_customer_trx_id,
                                            p_trx_number,
                                            l_temp,
                                            NULL,
                                            'AR_TW_BAD_DATE_MEMO_LINE',
                                            'TGW_HEADER.TRX_DATE',
                                            'LINE_NUMBER',
                                            l_temp,
                                            NULL,
                                            NULL
                                          );
                  END IF;


           EXCEPTION
              WHEN NO_DATA_FOUND THEN NULL;
              WHEN OTHERS THEN RAISE;
           END;
     END IF;

     /*---------------------+
      |  Validate tax code  |
      +---------------------*/

    /* 4594101 - Validation tests autotax rows (ar_vat_tax)
       and compares effective dates from table against trx_date.
       This logic is now handled by eTax.  This validation has been
       removed. */

   END IF;

   p_due_date := arpt_sql_func_util.Get_First_Due_Date( p_term_id,
                                                        p_trx_date );

   arp_util.debug('ARP_TRX_VALIDATE.validate_trx_date()-');


EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  ARP_TRX_VALIDATE.validate_trx_date()');
        RAISE;

END;

    /*----------------------------------------------------------------------+
     |  This overloaded call is provided for backward compatibility with    |
     |  an older version of this routine that did not have the p_error_mode |
     |  parameter.                                                          |
     +----------------------------------------------------------------------*/

PROCEDURE validate_trx_date( p_trx_date                      IN  DATE,
                             p_prev_trx_date                 IN  DATE,
                             p_commitment_trx_date           IN  DATE,
                             p_customer_trx_id               IN  NUMBER,
                             p_trx_number                    IN  VARCHAR2,
                             p_previous_customer_trx_id      IN  NUMBER,
                             p_initial_customer_trx_id       IN  NUMBER,
                             p_agreement_id                  IN  NUMBER,
                             p_batch_source_id               IN  NUMBER,
                             p_cust_trx_type_id              IN  NUMBER,
                             p_term_id                       IN  NUMBER,
                             p_ship_method_code              IN  VARCHAR2,
                             p_primary_salesrep_id           IN  NUMBER,
                             p_reason_code                   IN  VARCHAR2,
                             p_status_trx                    IN  VARCHAR2,
                             p_invoice_currency_code         IN  VARCHAR2,
                             p_receipt_method_id             IN  NUMBER,
                             p_bank_account_id               IN  NUMBER,
                             p_due_date                     OUT NOCOPY date,
                             p_result_flag                  OUT NOCOPY boolean,
                             p_commitment_invalid_flag      OUT NOCOPY boolean,
                             p_invalid_agreement_flag       OUT NOCOPY boolean,
                             p_invalid_source_flag          OUT NOCOPY boolean,
                             p_invalid_type_flag            OUT NOCOPY boolean,
                             p_invalid_term_flag            OUT NOCOPY boolean,
                             p_invalid_ship_method_flag     OUT NOCOPY boolean,
                             p_invalid_primary_srep_flag    OUT NOCOPY boolean,
                             p_invalid_reason_flag          OUT NOCOPY boolean,
                             p_invalid_status_flag          OUT NOCOPY boolean,
                             p_invalid_currency_flag        OUT NOCOPY boolean,
                             p_invalid_payment_mthd_flag    OUT NOCOPY boolean,
                             p_invalid_bank_flag            OUT NOCOPY boolean,
                             p_invalid_salesrep_flag        OUT NOCOPY boolean,
                             p_invalid_memo_line_flag       OUT NOCOPY boolean,
                             p_invalid_uom_flag             OUT NOCOPY boolean,
                             p_invalid_tax_flag             OUT NOCOPY boolean,
                             p_invalid_cm_date_flag         OUT NOCOPY boolean,
                             p_invalid_child_date_flag      OUT NOCOPY boolean,
                             p_error_count               IN OUT NOCOPY integer
                       ) IS
BEGIN

          validate_trx_date( 'NO_EXCEPTION',
                             p_trx_date,
                             p_prev_trx_date,
                             p_commitment_trx_date,
                             p_customer_trx_id,
                             p_trx_number,
                             p_previous_customer_trx_id,
                             p_initial_customer_trx_id,
                             p_agreement_id,
                             p_batch_source_id,
                             p_cust_trx_type_id,
                             p_term_id,
                             p_ship_method_code,
                             p_primary_salesrep_id,
                             p_reason_code,
                             p_status_trx,
                             p_invoice_currency_code,
                             p_receipt_method_id,
                             p_bank_account_id,
                             p_due_date,
                             p_result_flag,
                             p_commitment_invalid_flag,
                             p_invalid_agreement_flag,
                             p_invalid_source_flag,
                             p_invalid_type_flag,
                             p_invalid_term_flag,
                             p_invalid_ship_method_flag,
                             p_invalid_primary_srep_flag,
                             p_invalid_reason_flag,
                             p_invalid_status_flag,
                             p_invalid_currency_flag,
                             p_invalid_payment_mthd_flag,
                             p_invalid_bank_flag,
                             p_invalid_salesrep_flag,
                             p_invalid_memo_line_flag,
                             p_invalid_uom_flag,
                             p_invalid_tax_flag,
                             p_invalid_cm_date_flag,
                             p_invalid_child_date_flag,
                             p_error_count);

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   val_gl_dist_amounts                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure validates that the sum of the distribution amounts      |
 |    for a given transaction line is correct in each gl_date. The           |
 |    distributions with the header GL date must add up to the line's        |
 |    extended amount. The distributions with other GL dates must add up     |
 |    to zero for each GL date.                                              |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:  p_customer_trx_line_id                                  |
 |              OUT:                                                         |
 |                   p_result                                                |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     10-NOV-95  Martin Johnson      Created                                |
 |     14-DEC-95  Martin Johnson      Split error message into two messages  |
 |                                                                           |
 +===========================================================================*/

PROCEDURE val_gl_dist_amounts(
                      p_customer_trx_line_id  IN  NUMBER,
                      p_result OUT NOCOPY boolean ) IS

  l_d_gl_date     date;
  l_gl_date       date;
  l_rec_gl_date   date;
  l_amount        number;

  /*--------------------------------------------------+
   |  This sql will return no rows if data is valid.  |
   |  Needs to be a cursor to avoid error if multi    |
   |  rows rturned.                                   |
   +--------------------------------------------------*/

  /*--------------------------------------------------+
   |  Bug 1332304.                      |
   |  Reverting the change done in patch 959747.      |
   |  We need to pass the validation if either the    |
   |  percent or the amount are correct.              |
   +--------------------------------------------------*/

  CURSOR val_gl_dist_amounts IS

  SELECT   NVL(d.gl_date, rec.gl_date),
           DECODE(NVL(d.gl_date,  rec.gl_date),
           rec.gl_date, l.extended_amount,
                     0),
           d.gl_date,
           rec.gl_date
  FROM     ra_cust_trx_line_gl_dist rec,
           ra_cust_trx_line_gl_dist d,
           ra_customer_trx_lines l,
           ra_customer_trx t
  WHERE    l.customer_trx_line_id = d.customer_trx_line_id(+)
  AND      l.customer_trx_line_id = p_customer_trx_line_id
  AND      l.customer_trx_id      = t.customer_trx_id
  AND      rec.customer_trx_id    = l.customer_trx_id
  AND      rec.account_class      = 'REC'
  AND      rec.latest_rec_flag    = 'Y'
  AND      d.account_set_flag(+)  = 'N'
  GROUP by d.customer_trx_line_id,
           d.gl_date,
           rec.gl_date,
           l.extended_amount
  HAVING (
           (
              SUM(d.amount) <> DECODE( nvl(d.gl_date, rec.gl_date),
                                      rec.gl_date, l.extended_amount,
                                                   0)
           )
            AND           -- Changed 'OR' into 'AND'. Bug 1332304.
           (
              SUM(d.percent) <> DECODE( nvl(d.gl_date, rec.gl_date),
                                       rec.gl_date, 100,
                                                    0)
           )
         ) OR
         SUM(d.cust_trx_line_gl_dist_id) IS NULL
  ORDER BY d.gl_date;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('ARP_TRX_VALIDATE.val_gl_dist_amounts()+');
  END IF;

  OPEN val_gl_dist_amounts;

  FETCH val_gl_dist_amounts
   INTO l_gl_date,
        l_amount,
        l_d_gl_date,
        l_rec_gl_date;

  IF ( val_gl_dist_amounts%NOTFOUND )
    THEN
      CLOSE val_gl_dist_amounts;
      p_result := TRUE;

    ELSE

      CLOSE val_gl_dist_amounts;
      p_result := FALSE;

      IF ( l_gl_date = l_rec_gl_date )
        THEN
          fnd_message.set_name('AR', 'AR_TW_ACC_ASSGN_SUM_REC');
          fnd_message.set_token('GL_DATE',
                                TO_CHAR(l_gl_date, 'DD-MON-YYYY'));

        ELSE
          fnd_message.set_name('AR', 'AR_TW_ACC_ASSGN_SUM_ZERO');
          fnd_message.set_token('GL_DATE',
                                TO_CHAR(l_d_gl_date, 'DD-MON-YYYY'));

      END IF;

      app_exception.raise_exception;

  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('ARP_TRX_VALIDATE.val_gl_dist_amounts()-');
  END IF;

  EXCEPTION
    WHEN OTHERS
      THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION: ARP_TRX_VALIDATE.val_gl_dist_amounts()');
           arp_util.debug('val_gl_dist_amounts: ' || '  p_customer_trx_line_id = ' ||
                                        p_customer_trx_line_id );
           arp_util.debug('val_gl_dist_amounts: ' || '  l_gl_date = ' || l_gl_date );
           arp_util.debug('val_gl_dist_amounts: ' || '  l_amount = ' || l_amount );
        END IF;
        RAISE;

END val_gl_dist_amounts;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    val_and_dflt_pay_mthd_and_bank()                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validates the payment method and the bank columns.                     |
 |    If either is invalid, they are redefaulted.                            |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |    arp_process_credit_util.check_payment_method                           |
 |    arp_process_credit_util.check_bank_account                             |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_trx_date                             |
 |                   p_currency_code                         |
 |                   p_paying_customer_id                     |
 |                   p_paying_site_use_id                     |
 |                   p_bill_to_customer_id                     |
 |                   p_bill_to_site_use_id                     |
 |                   p_in_receipt_method_id                     |
 |                   p_in_customer_bank_account_id                 |
 |              OUT:                                                         |
 |                   p_payment_method_name                                   |
 |                   p_receipt_method_id                                     |
 |                   p_creation_method_code                                  |
 |                   p_customer_bank_account_id                              |
 |                   p_bank_account_num                                      |
 |                   p_bank_name                                             |
 |                   p_bank_branch_name                                      |
 |                   p_bank_branch_id                                        |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     08-FEB-96  Charlie Tomberg     Created                                |
 |     23-JUN-99  Ajay Pandit         Modified the procedure for fixing      |
 |                                    bug no 913071 so that the defaulting   |
 |                                    and validation for the bank accounts   |
 |                                    is not done when payment method is     |
 |                                    MANUAL                                 |
 |     06-OCT-04  Surendra Rajan      Added parameter p_trx_manual_flag to   |
 |                                    fix bug 3770337                        |
 +===========================================================================*/

PROCEDURE val_and_dflt_pay_mthd_and_bank(
                                      p_trx_date                    IN  date,
                                      p_currency_code               IN  varchar2,
                                      p_paying_customer_id          IN  number,
                                      p_paying_site_use_id          IN  number,
                                      p_bill_to_customer_id         IN  number,
                                      p_bill_to_site_use_id         IN  number,
                                      p_in_receipt_method_id        IN  number,
                                      p_in_customer_bank_account_id IN  number,
                                      p_payment_type_code           IN  varchar2,
                                      p_payment_method_name        OUT NOCOPY  varchar2,
                                      p_receipt_method_id          OUT NOCOPY  number,
                                      p_creation_method_code       OUT NOCOPY  varchar2,
                                      p_customer_bank_account_id   OUT NOCOPY  number,
                                      p_bank_account_num           OUT NOCOPY  varchar2,
                                      p_bank_name                  OUT NOCOPY  varchar2,
                                      p_bank_branch_name           OUT NOCOPY  varchar2,
                                      p_bank_branch_id             OUT NOCOPY  number,
                                      p_trx_manual_flag            IN VARCHAR2  DEFAULT 'N'
                          ) IS

   l_dummy  integer;

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_trx_validate.val_and_dflt_pay_mthd_and_bank()+');
   END IF;

   IF (  arp_process_credit_util.check_payment_method
                             (
                                 p_trx_date,
                                 p_bill_to_customer_id,
                                 p_bill_to_site_use_id,
                                 p_paying_customer_id,
                                 p_paying_site_use_id,
                                 p_currency_code,
                                 l_dummy,
                                 p_payment_method_name,
                                 p_receipt_method_id,
                                 p_creation_method_code
                             ) = FALSE )
   THEN

       arp_trx_defaults_3.get_payment_method_default(
                                    p_trx_date,
                                    p_currency_code,
                                    p_paying_customer_id,
                                    p_paying_site_use_id,
                                    p_bill_to_customer_id,
                                    p_bill_to_site_use_id,
                                    p_payment_method_name,
                                    p_receipt_method_id,
                                    p_creation_method_code,
                                    p_trx_manual_flag
                                  );
   END IF;
/*Bug 913072 : */
   IF (p_creation_method_code = 'MANUAL'or p_creation_method_code IS NULL) THEN /*Bug 3312212*/
     p_customer_bank_account_id := NULL;
     p_bank_account_num := NULL;
     p_bank_name  := NULL;
     p_bank_branch_name := NULL;
     p_bank_branch_id := NULL;
   ELSE

   IF ( arp_process_credit_util.check_bank_account(
                                p_trx_date,
                                p_currency_code,
                                p_bill_to_customer_id,
                                p_bill_to_site_use_id,
                                p_paying_customer_id,
                                p_paying_site_use_id,
                                l_dummy,
                                p_customer_bank_account_id,
                                l_dummy) = FALSE )
   THEN

         arp_trx_defaults_3.get_bank_defaults(
                               p_trx_date,
                               p_currency_code,
                               p_paying_customer_id,
                               p_paying_site_use_id,
                               p_bill_to_customer_id,
                               p_bill_to_site_use_id,
                               p_payment_type_code,
                               p_customer_bank_account_id,
                               p_bank_account_num,
                               p_bank_name,
                               p_bank_branch_name,
                               p_bank_branch_id,
                               p_trx_manual_flag
                          );
   END IF;
   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_trx_validater.val_and_dflt_pay_mthd_and_bank()-');
   END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('val_and_dflt_pay_mthd_and_bank: ' ||
            'EXCEPTION:  arp_process_header.val_and_dflt_pay_mthd_and_bank()');
         arp_util.debug('val_and_dflt_pay_mthd_and_bank: ' ||
            '------- parameters for val_and_dflt_pay_mthd_and_bank ----');
         arp_util.debug('val_and_dflt_pay_mthd_and_bank: ' || 'p_trx_date                     = ' ||
                      TO_CHAR(p_trx_date) );
         arp_util.debug('val_and_dflt_pay_mthd_and_bank: ' || 'p_currency_code                = ' ||
                      p_currency_code );
         arp_util.debug('val_and_dflt_pay_mthd_and_bank: ' || 'p_paying_customer_id           = ' ||
                      p_paying_customer_id );
         arp_util.debug('val_and_dflt_pay_mthd_and_bank: ' || 'p_paying_site_use_id           = ' ||
                      p_paying_site_use_id );
         arp_util.debug('val_and_dflt_pay_mthd_and_bank: ' || 'p_bill_to_customer_id          = ' ||
                      p_bill_to_customer_id );
         arp_util.debug('val_and_dflt_pay_mthd_and_bank: ' || 'p_bill_to_site_use_id          = ' ||
                      p_bill_to_site_use_id );
         arp_util.debug('val_and_dflt_pay_mthd_and_bank: ' || 'p_in_receipt_method_id         = ' ||
                      p_in_receipt_method_id );
         arp_util.debug('val_and_dflt_pay_mthd_and_bank: ' || 'p_in_customer_bank_account_id  = ' ||
                      p_in_customer_bank_account_id );
      END IF;

      RAISE;

END val_and_dflt_pay_mthd_and_bank;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    do_completion_checking()                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Checks if the transaction can be completed.                            |
 |                                                                           |
 |    The following checks are performed:                                    |
 |    - Insure that at least one line or freight line exists.                |
 |    - Insure that all entities that have start / end dates  are valid for  |
 |        the specified trx date.                                            |
 |    - Insure that if a commitment has been specified, it is valid   with   |
 |        the transaction's trx_date and gl_date                             |
 |    - If salescredits are required, the total salescredits for each line   |
 |        must equal 100% of the line amount.                                |
 |    - If salescredits are not required, either no salescredits exist for   |
 |        a line or they sum to 100%.                                        |
 |    - Check the existance and validtity of account assignments or          |
 |      account sets:                                                        |
 |        Constraints:                                                       |
 |          - records exists for each line                                   |
 |          - all code combinations are valid                                |
 |          - For account assignments, the sum of the assignment amounts     |
 |            must equal the line amount.                                    |
 |          - For account sets, the sum of the percents for each line and    |
 |            account class must equal 100%.                                 |
 |    - If an invoicing rule has been specified, verify that all lines       |
 |        have accounting rules and rule start dates.                        |
 |    - If TAX_CALCULATION_FLAG is Yes, then tax is required for all invoice |
 |        lines unless it's a memo line not of type LINE.                    |
 |    - Tax is also required if TAX_CALCULATION_FLAG is No and               |
 |      TAX_EXEMPT_FLAG is Require.                                          |
 |    - Check the creation sign of the transaction                           |
 |    - Verify that the GL Date is in an Opened, Future or                   |
 |         Never Opened (Arrears only) Period.                               |
 |                                                                           |
 |    The following validations only apply to credit memos against           |
 |    transactions.                                                          |
 |                                                                           |
 |    - Check for illegal overapplications.                                  |
 |    - The GL Date must be >= the credited transaction's GL Date.           |
 |    - There can be no later credit memos applied to the same transaction.  |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_bal_util.get_commitment_balance                                    |
 |    arp_ct_pkg.fetch_p                                                     |
 |    arp_non_db_pkg.check_creation_sign                                     |
 |    arp_non_db_pkg.check_natural_application                               |
 |    arp_trx_global.profile_info.use_inv_acct_for_cm_flag                   |
 |    arp_trx_util.get_summary_trx_balances                                  |
 |    arp_trx_validate.validate_trx_date                                     |
 |    arp_util.debug                                                         |
 |    arp_util.validate_and_default_gl_date                                  |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                     p_customer_trx_id                                     |
 |                     p_so_source_code                                      |
 |                     p_so_installed_flag                                   |
 |                                                                           |
 |              OUT:                                                         |
 |                     p_error_count                                         |
 |                                                                           |
 | RETURNS    : p_error_count                                                |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     06-DEC-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE do_completion_checking(
                                  p_customer_trx_id        IN  NUMBER,
                                  p_so_source_code        IN varchar2,
                                  p_so_installed_flag     IN varchar2,
                                  p_error_mode            IN VARCHAR2,
                                  p_error_count          OUT NOCOPY number
                                ) IS


BEGIN
     arp_trx_complete_chk.do_completion_checking(
                                p_customer_trx_id,
                                p_so_source_code,
                                p_so_installed_flag,
                                p_error_mode,
                                p_error_count);
END;

PROCEDURE init IS
BEGIN

  pg_base_curr_code    := arp_global.functional_currency;
  pg_salesrep_required_flag :=
          arp_trx_global.system_info.system_parameters.salesrep_required_flag;
  pg_set_of_books_id   :=
          arp_trx_global.system_info.system_parameters.set_of_books_id;
END init;

BEGIN
   init;
END ARP_TRX_VALIDATE;

/
