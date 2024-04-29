--------------------------------------------------------
--  DDL for Package WSH_ORG_CARRIER_SERVICES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_ORG_CARRIER_SERVICES_PKG" AUTHID CURRENT_USER as
/* $Header: WSHOCTHS.pls 115.4 2003/12/08 12:10:46 msutar ship $ */

TYPE OCSRecType IS RECORD (
  Carrier_service_id             NUMBER
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
, DISTRIBUTION_ACCOUNT           NUMBER        DEFAULT NULL -- BugFix#3296461
);

TYPE CarRecType IS RECORD (
  P_FREIGHT_CODE                 VARCHAR2(30)
, P_CARRIER_NAME                 VARCHAR2(80)
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
);

PROCEDURE assign_org_carrier_service(
  p_Org_Carrier_Service_info       IN OCSRecType
, p_carrier_info                   IN CarRecType
, p_csm_info                       IN WSH_CARRIER_SHIP_METHODS_PKG.CSMRecType
, P_COMMIT                    IN  VARCHAR2 DEFAULT FND_API.G_FALSE
, x_Rowid            		     IN OUT NOCOPY  VARCHAR2
, x_Org_Carrier_Service_id         IN OUT NOCOPY  NUMBER
, x_Return_Status                     OUT NOCOPY  VARCHAR2
, x_position                          OUT NOCOPY  VARCHAR2
, x_procedure                         OUT NOCOPY  VARCHAR2
, x_sqlerr                            OUT NOCOPY  VARCHAR2
, x_sql_code                          OUT NOCOPY  VARCHAR2
, x_exception_msg                     OUT NOCOPY  VARCHAR2
);

PROCEDURE Lock_Org_Carrier_Service (
  p_rowid                          IN     VARCHAR2
, p_Org_Carrier_Service_info       IN     OCSRecType
, x_Return_Status                  OUT NOCOPY     VARCHAR2
);

END WSH_ORG_CARRIER_SERVICES_PKG;

 

/
