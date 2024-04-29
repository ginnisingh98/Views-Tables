--------------------------------------------------------
--  DDL for Package CSE_REDO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSE_REDO_PKG" AUTHID CURRENT_USER AS
-- $Header: CSEREDOS.pls 120.2 2005/06/23 14:33:59 nnewadka noship $

  G_MISS_CHAR               CONSTANT    VARCHAR2(1) := FND_API.G_MISS_CHAR;
  G_MISS_NUM                CONSTANT    NUMBER      := FND_API.G_MISS_NUM;
  G_MISS_DATE               CONSTANT    DATE        := FND_API.G_MISS_DATE;
  G_RET_STS_SUCCESS   	    CONSTANT    VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR	    CONSTANT    VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR     CONSTANT    VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR ;
  G_False                   CONSTANT    VARCHAR2(1) := FND_API.G_FALSE;
  G_True                    CONSTANT    VARCHAR2(1) := FND_API.G_TRUE;
  G_VALID_LEVEL_FULL	    CONSTANT    NUMBER      := FND_API.G_VALID_LEVEL_FULL;
  G_API_NAME                CONSTANT    VARCHAR2(28):= 'CSE_REDO_PKG';

PROCEDURE Redo_Logic
        (P_Body_Text           IN    VARCHAR2,
         P_Txn_Type_Id         IN    NUMBER,
         P_Stage               IN    VARCHAR2,
         X_Return_Status       OUT   NOCOPY	VARCHAR2,
	 X_Error_Message       OUT   NOCOPY	VARCHAR2);


END CSE_REDO_PKG;

 

/
