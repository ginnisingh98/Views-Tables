--------------------------------------------------------
--  DDL for Package ARP_TBAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_TBAT_PKG" AUTHID CURRENT_USER AS
/* $Header: ARTIBATS.pls 120.4 2005/10/30 04:27:19 appldev ship $ */

procedure insert_p(
                    p_batch_rec   IN ra_batches%rowtype,
                    p_batch_id   OUT NOCOPY ra_batches.batch_id%type,
                    p_name       OUT NOCOPY ra_batches.name%type
                  );

PROCEDURE fetch_p( p_batch_rec  OUT NOCOPY ra_batches%rowtype,
                   p_batch_id    IN ra_batches.batch_id%type );


PROCEDURE update_p( p_batch_rec IN ra_batches%rowtype,
                    p_batch_id  IN ra_batches.batch_id%type);

PROCEDURE update_f_bs_id( p_batch_rec IN ra_batches%rowtype,
                          p_batch_source_id
                                IN ra_batch_sources.batch_source_id%type);

procedure delete_p( p_batch_id  IN ra_batches.batch_id%type);

procedure delete_f_bs_id( p_batch_source_id IN
                             ra_batches.batch_source_id%type);

PROCEDURE lock_p( p_batch_id 	IN ra_batches.batch_id%type );

PROCEDURE lock_fetch_p( p_batch_rec IN OUT NOCOPY ra_batches%rowtype,
                        p_batch_id IN ra_batches.batch_id%type );

PROCEDURE lock_compare_p( p_batch_rec IN ra_batches%rowtype,
                          p_batch_id IN ra_batches.batch_id%type );

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
  p_attribute15            IN ra_batches.attribute15%type);

PROCEDURE set_to_dummy( p_batch_rec OUT NOCOPY ra_batches%rowtype);


PROCEDURE display_batch(  p_batch_id IN ra_batches.batch_id%type);

PROCEDURE display_batch_rec( p_batch_rec ra_batches%rowtype );

END ARP_TBAT_PKG;

 

/
