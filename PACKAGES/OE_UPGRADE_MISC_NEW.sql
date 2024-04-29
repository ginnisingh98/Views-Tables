--------------------------------------------------------
--  DDL for Package OE_UPGRADE_MISC_NEW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_UPGRADE_MISC_NEW" AUTHID CURRENT_USER AS
/* $Header: OEXNUMSS.pls 120.0 2005/06/01 00:42:22 appldev noship $ */

-- Procedure to convert the passed in Freight Amount to the specified
-- currency.

 PROCEDURE CONVERT_CURRENCY
 (   p_freight_amount           IN  NUMBER
 ,   p_from_currency            IN  VARCHAR2
 ,   p_to_currency              IN  VARCHAR2
 ,   p_conversion_date          IN  DATE
 ,   p_conversion_rate          IN  NUMBER
 ,   p_conversion_type          IN  VARCHAR2
 ,   x_return_status            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
 ,   x_freight_amount           OUT NOCOPY /* file.sql.39 change */ NUMBER
 );


 PROCEDURE CREATE_FREIGHT_RECORD
 (
     p_header_id                 IN  NUMBER
 ,   p_line_id                   IN  NUMBER
 ,   p_freight_charge_id         IN  NUMBER
 ,   p_currency_code             IN  VARCHAR2
 ,   p_charge_type_code          IN  VARCHAR2
 ,   p_adjusted_amount           IN  VARCHAR2
 ,   p_creation_date             IN  DATE
 ,   p_created_by                IN  NUMBER
 ,   p_last_update_date          IN  DATE
 ,   p_last_updated_by           IN  NUMBER
 ,   p_last_update_login         IN  NUMBER
 ,   p_context                   IN  VARCHAR2
 ,   p_attribute1                IN  VARCHAR2
 ,   p_attribute2                IN  VARCHAR2
 ,   p_attribute3                IN  VARCHAR2
 ,   p_attribute4                IN  VARCHAR2
 ,   p_attribute5                IN  VARCHAR2
 ,   p_attribute6                IN  VARCHAR2
 ,   p_attribute7                IN  VARCHAR2
 ,   p_attribute8                IN  VARCHAR2
 ,   p_attribute9                IN  VARCHAR2
 ,   p_attribute10               IN  VARCHAR2
 ,   p_attribute11               IN  VARCHAR2
 ,   p_attribute12               IN  VARCHAR2
 ,   p_attribute13               IN  VARCHAR2
 ,   p_attribute14               IN  VARCHAR2
 ,   p_attribute15               IN  VARCHAR2
 ,   p_ac_context                IN  VARCHAR2
 ,   p_ac_attribute1             IN  VARCHAR2
 ,   p_ac_attribute2             IN  VARCHAR2
 ,   p_ac_attribute3             IN  VARCHAR2
 ,   p_ac_attribute4             IN  VARCHAR2
 ,   p_ac_attribute5             IN  VARCHAR2
 ,   p_ac_attribute6             IN  VARCHAR2
 ,   p_ac_attribute7             IN  VARCHAR2
 ,   p_ac_attribute8             IN  VARCHAR2
 ,   p_ac_attribute9             IN  VARCHAR2
 ,   p_ac_attribute10            IN  VARCHAR2
 ,   p_ac_attribute11            IN  VARCHAR2
 ,   p_ac_attribute12            IN  VARCHAR2
 ,   p_ac_attribute13            IN  VARCHAR2
 ,   p_ac_attribute14            IN  VARCHAR2
 ,   p_ac_attribute15            IN  VARCHAR2
 ,   p_invoice_status            IN  VARCHAR2
 ,   x_return_status             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
 );

PROCEDURE Round_Amount(
  p_Amount                       IN  NUMBER
, p_Currency_Code                IN  VARCHAR2
, x_Round_Amount                 OUT NOCOPY /* file.sql.39 change */ NUMBER
, x_return_status                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

FUNCTION GET_SOB_CURRENCY(p_org_id IN NUMBER) RETURN VARCHAR2;

END OE_Upgrade_Misc_New;

 

/
