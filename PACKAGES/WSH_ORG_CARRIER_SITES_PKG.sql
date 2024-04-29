--------------------------------------------------------
--  DDL for Package WSH_ORG_CARRIER_SITES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_ORG_CARRIER_SITES_PKG" AUTHID CURRENT_USER as
/* $Header: WSHOSTHS.pls 115.1 2002/11/13 20:11:37 nparikh noship $ */

TYPE OCSRecType IS RECORD (
  Carrier_site_id                NUMBER
, Organization_id                NUMBER
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
, program_application_id         NUMBER
, program_id                     NUMBER
, program_update_date            DATE
, request_id                     NUMBER
);

PROCEDURE assign_org_carrier_site(
  p_Org_Carrier_Site_info          IN     OCSRecType
, x_Rowid                          IN OUT NOCOPY  VARCHAR2
, x_Org_Carrier_site_id            IN OUT NOCOPY  NUMBER
, x_Return_Status                     OUT NOCOPY  VARCHAR2
, x_position                          OUT NOCOPY  VARCHAR2
, x_procedure                         OUT NOCOPY  VARCHAR2
, x_sqlerr                            OUT NOCOPY  VARCHAR2
, x_sql_code                          OUT NOCOPY  VARCHAR2
, x_exception_msg                     OUT NOCOPY  VARCHAR2
);

PROCEDURE Lock_Org_Carrier_site (
  p_rowid                       IN     VARCHAR2
, p_Org_Carrier_site_info       IN     OCSRecType
, x_Return_Status               OUT NOCOPY     VARCHAR2
);

END WSH_ORG_CARRIER_SITES_PKG;

 

/
