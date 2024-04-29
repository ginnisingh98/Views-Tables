--------------------------------------------------------
--  DDL for Package Body ARP_PROCESS_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROCESS_BATCH" AS
/* $Header: ARTEBATB.pls 115.5 2002/11/18 22:31:30 anukumar ship $ */


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    check_dup_batch_name()		                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Determines if a given batch name exists for a given batch source.	     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_name						     |
 |		      p_batch_source_id					     |
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
 |     16-NOV-01  Amit Bhati          Bug868793 : Changed Procedure          |
 |                                    for making batch name unique           |
 |                                    across all batch sources.              |
 |                                                                           |
 +===========================================================================*/


PROCEDURE check_dup_batch_name(p_name            IN varchar2,
                               p_batch_source_id IN varchar2) IS

   l_count number := 0;

BEGIN

   arp_util.debug('arp_process_batch.check_dup_batch_name()+');

/*Where clause is changed to solve bug 868793 : now batch name should be unique across batch sources */
   SELECT count(*)
   INTO   l_count
   FROM   ra_batches
   --WHERE  batch_source_id = p_batch_source_id
   WHERE  name = p_name;

   IF    (l_count > 0)
   THEN  fnd_message.set_name('AR', 'AR_DUP_BATCH_NAME');
         app_exception.raise_exception;
   END IF;

   arp_util.debug('arp_process_batch.check_dup_batch_name()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_process_batch.check_dup_batch_name()');

        arp_util.debug('');
        arp_util.debug('------ parameters for check_dup_batch_name() -------');

        arp_util.debug('p_name             = '|| p_name);
        arp_util.debug('p_batch_source_id  = '|| p_batch_source_id);

        RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    ar_empty_batch			                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validates that a batch to be deleted contains no transactions.	     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_batch_id	 				     |
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


PROCEDURE ar_empty_batch ( p_batch_id IN number ) IS

   l_count number := 0;

BEGIN

   arp_util.debug('arp_process_batch.ar_empty_batch()+');

   SELECT count(*)
   INTO   l_count
   FROM   ra_customer_trx
   WHERE  batch_id = p_batch_id;

   /* Bug1894153 : Changed the message name . */
   IF    (l_count > 0)
   THEN  fnd_message.set_name('AR', 'AR_DELNA_TRANSACTION_EXISTS');
         app_exception.raise_exception;
   END IF;

   arp_util.debug('arp_process_batch.ar_empty_batch()-');

EXCEPTION
    WHEN OTHERS THEN

        arp_util.debug('EXCEPTION:  arp_process_batch.ar_empty_batch()');

        arp_util.debug('');
        arp_util.debug('------ parameters for ar_empty_batch() -------');

        arp_util.debug('p_batch_id = '|| p_batch_id);

        RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    val_insert_batch			                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Does validation that is required when a new batch is inserted.	     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_batch_rec					     |
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


PROCEDURE val_insert_batch ( p_batch_rec IN ra_batches%rowtype ) IS


BEGIN

   arp_util.debug('arp_process_batch.val_insert_batch()+');

   arp_process_batch.check_dup_batch_name(p_batch_rec.name,
                                          p_batch_rec.batch_source_id);

   arp_util.debug('arp_process_batch.val_insert_batch()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_process_batch.val_insert_batch()');

        arp_util.debug('');
        arp_util.debug('------ parameters for val_insert_batch() -------');

        arp_tbat_pkg.display_batch_rec(p_batch_rec);

        RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    val_update_batch			                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Does validation that is required when a batch is updated.		     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_batch_rec					     |
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


PROCEDURE val_update_batch ( p_batch_rec IN ra_batches%rowtype ) IS


BEGIN

   arp_util.debug('arp_process_batchval_update_batch()+');

   arp_util.debug('arp_process_batch.val_update_batch()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_process_batch.val_update_batch()');

        arp_util.debug('');
        arp_util.debug('------ parameters for val_update_batch() -------');

        arp_tbat_pkg.display_batch_rec(p_batch_rec);

        RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    val_delete__batch			                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Does validation that is required when a batch is deleted.		     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_batch_rec					     |
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


PROCEDURE val_delete_batch ( p_batch_rec IN ra_batches%rowtype ) IS


BEGIN

   arp_util.debug('arp_process_batch.val_delete_batch()+');

   -- verify that the batch does not contain any transactions
      arp_process_batch.ar_empty_batch(p_batch_rec.batch_id);

   arp_util.debug('arp_process_batch.val_delete_batch()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_process_batch.val_delete_batch()');

        arp_util.debug('');
        arp_util.debug('------ parameters for val_delete_batch() -------');

        arp_tbat_pkg.display_batch_rec(p_batch_rec);

        RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_batch							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Inserts a record into ra_batches.					     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_form_name					     |
 |		      p_form_version					     |
 |		      p_batch_rec					     |
 |              OUT:                                                         |
 |                    P_batch_id					     |
 |          IN/ OUT:							     |
 |                    p_name						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     13-JUL-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/


PROCEDURE insert_batch(
               p_form_name              IN varchar2,
               p_form_version           IN number,
               p_batch_rec		ra_batches%rowtype,
               p_batch_id              OUT NOCOPY ra_batches.batch_id%type,
               p_name               IN OUT NOCOPY ra_batches.name%type)
                   IS

BEGIN

      arp_util.debug('arp_process_batch.insert_batch()+');

      /*----------------------------------------------+
       |   Check the form version to determine if it  |
       |   is compatible with the entity handler.     |
       +----------------------------------------------*/

      arp_trx_validate.ar_entity_version_check(p_form_name, p_form_version);

      /*-------------------------+
       |  Do required validation |
       +-------------------------*/

      arp_process_batch.val_insert_batch(p_batch_rec);

      /*---------------------------------------------+
       |  Call the table handler to insert the batch |
       +---------------------------------------------*/

      arp_tbat_pkg.insert_p( p_batch_rec,
                             p_batch_id,
                             p_name);

      arp_util.debug('arp_process_batch.insert_batch()-');

EXCEPTION
    WHEN OTHERS THEN

       /*---------------------------------------------+
        |  Display parameters and raise the exception |
        +---------------------------------------------*/

        arp_util.debug('EXCEPTION:  arp_process_batch.insert_batch()');

        arp_util.debug('');
        arp_util.debug('---------- parameters for insert_batch() ---------');

        arp_util.debug('p_form_name     = ' || p_form_name );
        arp_util.debug('p_form_version  = ' || p_form_version);
        arp_util.debug('');

        arp_tbat_pkg.display_batch_rec(p_batch_rec);

        RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_batch			                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Updates a ra_batches record					     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_form_name					     |
 |		      p_form_version					     |
 |                    p_batch_rec					     |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     13-JUL-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/


PROCEDURE update_batch(
                p_form_name	      IN varchar2,
                p_form_version        IN number,
                p_batch_id            IN ra_batches.batch_id%type,
                p_batch_rec	      IN ra_batches%rowtype ) IS



BEGIN

      arp_util.debug('arp_process_batch.update_batch()+');

      /*----------------------------------------------+
       |   Check the form version to determine if it  |
       |   is compatible with the entity handler.     |
       +----------------------------------------------*/


      arp_trx_validate.ar_entity_version_check(p_form_name, p_form_version);


      /*-------------------------+
       |  Do required validation |
       +-------------------------*/

      arp_process_batch.val_update_batch(p_batch_rec);


       /*-----------------------------------------------------+
        |  call the table-handler to update the batch record  |
        +-----------------------------------------------------*/

      arp_tbat_pkg.update_p( p_batch_rec,
                             p_batch_id);

      arp_util.debug('arp_process_batch.update_batch()-');

EXCEPTION
    WHEN OTHERS THEN

       /*---------------------------------------------+
        |  Display parameters and raise the exception |
        +---------------------------------------------*/

        arp_util.debug('EXCEPTION:  arp_process_batch.update_batch()');

        arp_util.debug('');
        arp_util.debug('---------- parameters for update_batch() ---------');

        arp_util.debug('p_form_name     = ' || p_form_name );
        arp_util.debug('p_form_version  = ' || p_form_version);
        arp_util.debug('p_batch_id      = ' || p_batch_id);
        arp_util.debug('');

        arp_tbat_pkg.display_batch_rec(p_batch_rec);

        RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_batch			                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Deletes records from ra_batches					     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_form_name					     |
 |		      p_form_version					     |
 |		      p_batch_id					     |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     13-JUL-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/


PROCEDURE delete_batch(p_form_name		IN varchar2,
                       p_form_version		IN number,
                       p_batch_id		IN ra_batches.batch_id%type,
                       p_batch_rec		IN ra_batches%rowtype) IS

BEGIN

   arp_util.debug('arp_process_batch.delete_batch()+');

      /*----------------------------------------------+
       |   Check the form version to determine if it  |
       |   is compatible with the entity handler.     |
       +----------------------------------------------*/

      arp_trx_validate.ar_entity_version_check(p_form_name, p_form_version);

      /*-------------------------+
       |  Do required validation |
       +-------------------------*/

      arp_process_batch.val_delete_batch(p_batch_rec);

      /*-----------------------------------------------------+
       |  call the table-handler to delete the batch record  |
       +-----------------------------------------------------*/

      arp_tbat_pkg.delete_p( p_batch_id );

      arp_util.debug('arp_process_batch.delete_batch()-');

EXCEPTION
    WHEN OTHERS THEN

       /*---------------------------------------------+
        |  Display parameters and raise the exception |
        +---------------------------------------------*/

        arp_util.debug('EXCEPTION:  arp_process_batch.delete_batch()');

        arp_util.debug('');
        arp_util.debug('---------- parameters for delete_batch() ---------');

        arp_util.debug('p_form_name     = ' || p_form_name );
        arp_util.debug('p_form_version  = ' || p_form_version);
        arp_util.debug('p_batch_id      = ' || p_batch_id);
        arp_util.debug('');

        arp_tbat_pkg.display_batch_rec(p_batch_rec);

        RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_batch_cover                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Cover for calling the batch entity handler insert_batch                |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_form_name                                            |
 |                    p_form_version                                         |
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
 |                    p_batch_id                                             |
 |          IN  OUT:                                                         |
 |                    p_name                                                 |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     10-NOV-95  Subash C            Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE insert_batch_cover(
  p_form_name              IN varchar2,
  p_form_version           IN number,
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
  p_attribute15            IN ra_batches.attribute15%type,
  p_batch_id              OUT NOCOPY ra_batches.batch_id%type,
  p_name               IN OUT NOCOPY ra_batches.name%type)
IS
  l_batch_rec     ra_batches%rowtype;
  l_batch_id      ra_batches.batch_id%type;
  l_name          ra_batches.name%type;
BEGIN
    arp_util.debug('arp_process_batch.insert_batch_cover()+');

    l_batch_rec.batch_source_id      := p_batch_source_id;
    l_batch_rec.batch_date           := p_batch_date;
    l_batch_rec.gl_date              := p_gl_date;
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
    l_batch_rec.name                 := p_name;

    arp_process_batch.insert_batch(p_form_name,
                                   p_form_version,
                                   l_batch_rec,
                                   l_batch_id,
                                   l_name);

    p_batch_id   := l_batch_id;
    p_name       := l_name;

    arp_util.debug('arp_process_batch.insert_batch_cover()-');

EXCEPTION
  WHEN OTHERS THEN
    arp_util.debug('EXCEPTION : arp_process_batch.insert_batch_cover');
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
    arp_util.debug('p_name                 : '||p_name);
    RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_batch_cover                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Cover for calling the batch entity handler update_batch                |
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

PROCEDURE update_batch_cover(
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
  l_batch_rec   ra_batches%rowtype;
BEGIN

    arp_util.debug('arp_process_batch.update_batch_cover()+');

    arp_tbat_pkg.set_to_dummy(l_batch_rec);

    l_batch_rec.batch_id             := p_batch_id;
    l_batch_rec.name                 := p_name;
    l_batch_rec.batch_source_id      := p_batch_source_id;
    l_batch_rec.batch_date           := p_batch_date;
    l_batch_rec.gl_date              := p_gl_date;
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

    arp_process_batch.update_batch(p_form_name,
                                   p_form_version,
                                   p_batch_id,
                                   l_batch_rec);

    arp_util.debug('arp_process_batch.update_batch_cover()-');

EXCEPTION
  WHEN OTHERS THEN
    arp_util.debug('EXCEPTION : arp_process_batch.update_batch_cover');
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
 |    delete_batch_cover                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Cover for calling the batch entity handler delete_batch                |
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

PROCEDURE delete_batch_cover(
  p_form_name              IN varchar2,
  p_form_version           IN number,
  p_batch_id               IN ra_batches.batch_id%type)
IS
  l_batch_rec     ra_batches%rowtype;
BEGIN
    arp_util.debug('arp_process_batch.delete_batch_cover()+');

    arp_tbat_pkg.set_to_dummy(l_batch_rec);
    l_batch_rec.batch_id := p_batch_id;

    arp_process_batch.delete_batch(p_form_name,
                                   p_form_version,
                                   p_batch_id,
                                   l_batch_rec);

    arp_util.debug('arp_process_batch.delete_batch_cover()-');

EXCEPTION
  WHEN OTHERS THEN
    arp_util.debug('EXCEPTION : arp_process_batch.delete_batch_cover');

    arp_util.debug('p_form_name            : '||p_form_name);
    arp_util.debug('p_form_version         : '||p_form_version);
    arp_util.debug('p_batch_id             : '||p_batch_id);

    RAISE;
END;

END ARP_PROCESS_BATCH;

/
