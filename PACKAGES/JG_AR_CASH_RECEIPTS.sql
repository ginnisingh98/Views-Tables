--------------------------------------------------------
--  DDL for Package JG_AR_CASH_RECEIPTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_AR_CASH_RECEIPTS" AUTHID CURRENT_USER as
/* $Header: jgzzrcrs.pls 120.4 2005/08/25 23:30:23 cleyvaol ship $ */

/*----------------------------------------------------------------------------*
 |   PUBLIC FUNCTIONS/PROCEDURES  					      |
 *----------------------------------------------------------------------------*/

PROCEDURE Validate_gbl(
                   p_global_attribute_category   IN OUT NOCOPY VARCHAR2 ,
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

PROCEDURE Reverse(
                   p_cash_receipt_id             IN     NUMBER,
                   p_return_status               OUT NOCOPY    VARCHAR2);

END JG_AR_CASH_RECEIPTS;

 

/
