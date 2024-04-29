--------------------------------------------------------
--  DDL for Package WSH_CARRIER_SHIP_METHODS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_CARRIER_SHIP_METHODS_PKG" AUTHID CURRENT_USER as
/* $Header: WSHCSTHS.pls 115.11 2002/11/18 20:12:36 nparikh ship $ */

TYPE CSMRecType IS RECORD (
  Carrier_Ship_Method_id         NUMBER
, Carrier_Id                     NUMBER
, ship_method_code               VARCHAR2(30)
, freight_code                   VARCHAR2(30)
, service_level			   VARCHAR2(30)
, carrier_site_id                NUMBER
, organization_id                NUMBER
, Enabled_Flag                   VARCHAR2(1)
, ATTRIBUTE_CATEGORY             VARCHAR2(150)
, ATTRIBUTE1                     VARCHAR2(150)
, ATTRIBUTE2                     VARCHAR2(150)
, ATTRIBUTE3                     VARCHAR2(150)
, ATTRIBUTE4                     VARCHAR2(150)
, ATTRIBUTE5                     VARCHAR2(150)
, ATTRIBUTE6                     VARCHAR2(150)
, ATTRIBUTE7                     VARCHAR2(150)
, ATTRIBUTE8                     VARCHAR2(150)
, ATTRIBUTE9                     VARCHAR2(150)
, ATTRIBUTE10                    VARCHAR2(150)
, ATTRIBUTE11                    VARCHAR2(150)
, ATTRIBUTE12                    VARCHAR2(150)
, ATTRIBUTE13                    VARCHAR2(150)
, ATTRIBUTE14                    VARCHAR2(150)
, ATTRIBUTE15                    VARCHAR2(150)
, Creation_Date                  DATE
, Created_By                     NUMBER
, Last_Update_Date               DATE
, Last_Updated_By                NUMBER
, Last_Update_Login              NUMBER
, Web_Enabled			 VARCHAR2(1)
);

PROCEDURE Create_Carrier_Ship_Method(
  p_Carrier_Ship_Method_Info       IN     CSMRecType
, x_Rowid            					  OUT NOCOPY  VARCHAR2
, x_Carrier_Ship_Method_id            OUT NOCOPY  NUMBER
, x_Return_Status                     OUT NOCOPY  VARCHAR2
);

PROCEDURE Lock_Carrier_Ship_Method (
  p_rowid                          IN     VARCHAR2
, p_Carrier_Ship_Method_Info       IN     CSMRecType
, x_Return_Status                     OUT NOCOPY  VARCHAR2
);

PROCEDURE Update_Carrier_Ship_Method(
  p_rowid                          IN     VARCHAR2
, p_Carrier_Ship_Method_Info       IN     CSMRecType
, x_Return_Status                     OUT NOCOPY  VARCHAR2
);

PROCEDURE Delete_Carrier_Ship_Method(
  p_rowid                          IN     VARCHAR2 := NULL
, p_carrier_ship_method_id         IN     NUMBER
, x_Return_Status                     OUT NOCOPY  VARCHAR2
);

END WSH_CARRIER_SHIP_METHODS_PKG;

 

/
