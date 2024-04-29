--------------------------------------------------------
--  DDL for Package ARP_PROCESS_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROCESS_BATCH" AUTHID CURRENT_USER AS
/* $Header: ARTEBATS.pls 115.2 2002/11/15 03:36:16 anukumar ship $ */

PROCEDURE check_dup_batch_name(p_name            IN varchar2,
                               p_batch_source_id IN varchar2);

PROCEDURE ar_empty_batch ( p_batch_id IN number );

PROCEDURE insert_batch(
               p_form_name              IN varchar2,
               p_form_version           IN number,
               p_batch_rec		IN ra_batches%rowtype,
               p_batch_id              OUT NOCOPY ra_batches.batch_id%type,
               p_name               IN OUT NOCOPY ra_batches.name%type);

PROCEDURE update_batch(
                p_form_name	      IN varchar2,
                p_form_version        IN number,
                p_batch_id            IN ra_batches.batch_id%type,
                p_batch_rec           IN ra_batches%rowtype);


PROCEDURE delete_batch(p_form_name		IN varchar2,
                       p_form_version		IN number,
                       p_batch_id		IN ra_batches.batch_id%type,
		       p_batch_rec		IN ra_batches%rowtype);

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
  p_name               IN OUT NOCOPY ra_batches.name%type);

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
  p_attribute15            IN ra_batches.attribute15%type);


PROCEDURE delete_batch_cover(
  p_form_name              IN varchar2,
  p_form_version           IN number,
  p_batch_id               IN ra_batches.batch_id%type);


END ARP_PROCESS_BATCH;

 

/
