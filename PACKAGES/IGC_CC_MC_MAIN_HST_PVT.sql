--------------------------------------------------------
--  DDL for Package IGC_CC_MC_MAIN_HST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CC_MC_MAIN_HST_PVT" AUTHID CURRENT_USER as
/* $Header: IGCCMMHS.pls 120.4.12010000.2 2008/08/04 14:51:25 sasukuma ship $ */


/* ================================================================================
                         PROCEDURE Insert_Row => IGC_CC_MC_HEADER_HISTORY
   ===============================================================================*/


PROCEDURE get_rsobs_Headers(
   p_api_version               IN     NUMBER,
   p_init_msg_list             IN     VARCHAR2 := FND_API.G_FALSE,
   p_commit                    IN     VARCHAR2 := FND_API.G_FALSE,
   p_validation_level          IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   X_return_status             OUT NOCOPY    VARCHAR2,
   X_msg_count                 OUT NOCOPY    NUMBER,
   X_msg_data                  OUT NOCOPY    VARCHAR2,
   p_CC_Header_Id              IN     NUMBER,
   p_Set_Of_Books_Id           IN     NUMBER,
   l_Application_Id            IN     NUMBER,
   p_org_id                    IN     NUMBER,
   l_Conversion_Date           IN     DATE,
   p_CC_Version_num            IN     NUMBER,
   p_CC_Version_Action         IN     VARCHAR2);

/* ================================================================================
                         PROCEDURE Insert_Row => IGC_CC_MC_ACCT_LINE_HISTORY
   ===============================================================================*/

PROCEDURE get_rsobs_Acct_Lines(
   p_api_version               IN       NUMBER,
   p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
   p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
   p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   X_return_status             OUT NOCOPY      VARCHAR2,
   X_msg_count                 OUT NOCOPY      NUMBER,
   X_msg_data                  OUT NOCOPY      VARCHAR2,
   p_CC_Acct_Line_Id           IN       NUMBER,
   p_Set_Of_Books_Id           IN       NUMBER,
   l_Application_Id            IN       NUMBER,
   p_org_id                    IN       NUMBER,
   l_Conversion_Date           IN       DATE,
   p_CC_Acct_Func_Amt          IN       NUMBER,
   p_CC_Acct_Encmbrnc_Amt      IN       NUMBER,
   p_CC_Acct_Version_Num       IN       NUMBER,
   p_CC_Acct_Version_Action    IN       VARCHAR2,
   p_CC_Func_Withheld_Amt      IN       NUMBER);

/* ================================================================================
                         PROCEDURE Insert_Row => IGC_CC_DET_PF_HISTORY
   ===============================================================================*/

PROCEDURE get_rsobs_DET_PF(
   p_api_version               IN       NUMBER,
   p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
   p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
   p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   X_return_status             OUT NOCOPY      VARCHAR2,
   X_msg_count                 OUT NOCOPY      NUMBER,
   X_msg_data                  OUT NOCOPY      VARCHAR2,
   p_CC_DET_PF_Line_Id         IN       NUMBER,
   p_Set_Of_Books_Id           IN       NUMBER,
   l_Application_Id            IN       NUMBER,
   p_org_id                    IN       NUMBER,
   l_Conversion_Date           IN       DATE,
   p_CC_DET_PF_Func_Amt        IN       NUMBER,
   p_CC_DET_PF_ENCMBRNC_AMT    IN       NUMBER,
   p_Det_PF_Version_Num        IN       NUMBER,
   p_Det_PF_Version_Action     IN       VARCHAR2);


END IGC_CC_MC_MAIN_HST_PVT;

/
