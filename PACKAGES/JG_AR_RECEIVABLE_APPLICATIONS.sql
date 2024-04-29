--------------------------------------------------------
--  DDL for Package JG_AR_RECEIVABLE_APPLICATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_AR_RECEIVABLE_APPLICATIONS" AUTHID CURRENT_USER as
/* $Header: jgzzrras.pls 120.7 2005/08/25 23:36:00 cleyvaol ship $ */

/*----------------------------------------------------------------------------*
 |   PUBLIC FUNCTIONS/PROCEDURES  					      |
 *----------------------------------------------------------------------------*/

Type gdf_rec is Record (
                 global_attribute1         VARCHAR2(150),
                 global_attribute2         VARCHAR2(150),
                 global_attribute3         VARCHAR2(150),
                 global_attribute4         VARCHAR2(150),
                 global_attribute5         VARCHAR2(150),
                 global_attribute6         VARCHAR2(150),
                 global_attribute7         VARCHAR2(150),
                 global_attribute8         VARCHAR2(150),
                 global_attribute9         VARCHAR2(150),
                 global_attribute10        VARCHAR2(150),
                 global_attribute11        VARCHAR2(150),
                 global_attribute12        VARCHAR2(150),
                 global_attribute13        VARCHAR2(150),
                 global_attribute14        VARCHAR2(150),
                 global_attribute15        VARCHAR2(150),
                 global_attribute16        VARCHAR2(150),
                 global_attribute17        VARCHAR2(150),
                 global_attribute18        VARCHAR2(150),
                 global_attribute19        VARCHAR2(150),
                 global_attribute20        VARCHAR2(150),
                 global_attribute_category VARCHAR2(150)
                 );

PROCEDURE   Apply(p_apply_before_after          IN     VARCHAR2 ,
                  p_global_attribute_category   IN OUT NOCOPY VARCHAR2 ,
                  p_set_of_books_id             IN     NUMBER   ,
                  p_cash_receipt_id             IN     VARCHAR2 ,
                  p_receipt_date                IN     DATE     ,
                  p_applied_payment_schedule_id IN     NUMBER   ,
                  p_amount_applied              IN     NUMBER   ,
                  p_unapplied_amount            IN     NUMBER   ,
                  p_due_date                    IN     DATE     ,
                  p_receipt_method_id           IN     NUMBER   ,
                  p_remittance_bank_account_id  IN     NUMBER   ,
                  p_global_attribute1           IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute2           IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute3           IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute4           IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute5           IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute6           IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute7           IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute8           IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute9           IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute10          IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute11          IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute12          IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute13          IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute14          IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute15          IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute16          IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute17          IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute18          IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute19          IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute20          IN OUT NOCOPY VARCHAR2 ,
                  p_return_status               OUT NOCOPY    VARCHAR2);

PROCEDURE Unapply(
                  p_cash_receipt_id             IN     VARCHAR2 ,
                  p_applied_payment_schedule_id IN     NUMBER   ,
                  p_return_status               OUT NOCOPY    VARCHAR2);


PROCEDURE create_interest_adjustment(
                   p_post_quickcash_req_id IN NUMBER,
                   x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE delete_interest_adjustment(
                   p_cash_receipt_id IN NUMBER,
                   x_return_status OUT NOCOPY VARCHAR2);

END JG_AR_RECEIVABLE_APPLICATIONS;

 

/
