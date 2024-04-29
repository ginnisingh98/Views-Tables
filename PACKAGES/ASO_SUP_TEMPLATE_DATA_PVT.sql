--------------------------------------------------------
--  DDL for Package ASO_SUP_TEMPLATE_DATA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_SUP_TEMPLATE_DATA_PVT" AUTHID CURRENT_USER as
/* $Header: asovstms.pls 120.1 2005/06/29 12:45:17 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_SUP_TEMPLATE_DATA_PVT
-- Purpose          :
--
--   Procedures:
--
-- History          :
-- NOTE             :
--
-- End of Comments
--
TYPE Template_Rec_Type is RECORD
(
  template_id         NUMBER,
  created_by          NUMBER ,
  creation_date       DATE ,
  last_updated_by     NUMBER,
  last_update_date    DATE,
  last_update_login    NUMBER,
  TEMPLATE_NAME       VARCHAR2(240),
  DESCRIPTION         VARCHAR2(2000) ,
  TEMPLATE_LEVEL      VARCHAR2(30),
  TEMPLATE_CONTEXT    VARCHAR2(40),
  CONTEXT             VARCHAR2(30),
  ATTRIBUTE1          VARCHAR2(240),
  ATTRIBUTE2           VARCHAR2(240),
  ATTRIBUTE3          VARCHAR2(240),
  ATTRIBUTE4          VARCHAR2(240),
  ATTRIBUTE5          VARCHAR2(240) ,
  ATTRIBUTE6          VARCHAR2(240),
  ATTRIBUTE7          VARCHAR2(240),
  ATTRIBUTE8          VARCHAR2(240),
  ATTRIBUTE9          VARCHAR2(240),
  ATTRIBUTE10         VARCHAR2(240),
  ATTRIBUTE11         VARCHAR2(240),
  ATTRIBUTE12         VARCHAR2(240),
  ATTRIBUTE13         VARCHAR2(240),
  ATTRIBUTE14         VARCHAR2(240),
  ATTRIBUTE15         VARCHAR2(240),
  ATTRIBUTE16         VARCHAR2(240),
  ATTRIBUTE17         VARCHAR2(240),
  ATTRIBUTE18         VARCHAR2(240),
  ATTRIBUTE19         VARCHAR2(240),
  ATTRIBUTE20         VARCHAR2(240)

);

G_Miss_Template_Rec                       Template_Rec_Type;



FUNCTION Validate_Template(
     p_template_context       IN   VARCHAR2,
     p_template_level         IN      VARCHAR2)
RETURN VARCHAR2;

PROCEDURE CREATE_TEMPLATE
(
 P_Api_Version_Number          IN         NUMBER,
 P_Init_Msg_List               IN         VARCHAR2     := FND_API.G_FALSE,
 P_Commit                      IN         VARCHAR2     := FND_API.G_FALSE,
 P_TEMPLATE_REC     IN          ASO_SUP_TEMPLATE_DATA_PVT.TEMPLATE_REC_TYPE,
 X_Template_id                 OUT NOCOPY /* file.sql.39 change */           NUMBER,
 X_Return_Status               OUT NOCOPY /* file.sql.39 change */           VARCHAR2,
 X_Msg_Count                   OUT NOCOPY /* file.sql.39 change */           VARCHAR2,
 X_Msg_Data                    OUT NOCOPY /* file.sql.39 change */           VARCHAR2 );

PROCEDURE UPDATE_TEMPLATE
(
 P_Api_Version_Number          IN         NUMBER,
 P_Init_Msg_List               IN         VARCHAR2     := FND_API.G_FALSE,
 P_Commit                      IN         VARCHAR2     := FND_API.G_FALSE,
 P_TEMPLATE_REC     IN          ASO_SUP_TEMPLATE_DATA_PVT.TEMPLATE_REC_TYPE,
 X_Return_Status               OUT NOCOPY /* file.sql.39 change */           VARCHAR2,
 X_Msg_Count                   OUT NOCOPY /* file.sql.39 change */           VARCHAR2,
 X_Msg_Data                    OUT NOCOPY /* file.sql.39 change */           VARCHAR2 );

End ASO_SUP_TEMPLATE_DATA_PVT;

 

/
