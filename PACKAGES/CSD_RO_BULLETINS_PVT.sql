--------------------------------------------------------
--  DDL for Package CSD_RO_BULLETINS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_RO_BULLETINS_PVT" AUTHID CURRENT_USER as
/* $Header: csdvrobs.pls 120.2.12010000.2 2008/08/08 17:38:15 swai ship $ */
-- Start of Comments
-- Package name     : CSD_RO_BULLETINS_PVT
-- Purpose          : Jan-10-2008    rfieldma created
-- History          :
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  CONSTANT NUMBER           := 30;
G_L_API_VERSION_NUMBER   CONSTANT NUMBER           := 1.0;
G_FREQ_ONE_REPAIR        CONSTANT VARCHAR2(10)     := 'ONE_REPAIR';
G_FREQ_ONE_INSTANCE      CONSTANT VARCHAR2(12)     := 'ONE_INSTANCE';
G_OBJ_VERSION_NUMBER_1   CONSTANT NUMBER           := 1;
G_SOURCE_TYPE_RULE       CONSTANT VARCHAR2(4)      := 'RULE';

--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Type name:CSD_RO_SC_IDS_TBL_TYPE
--   -------------------------------------------------------
--   Parameters:
--
--    Required:
--    Defaults:
--   History: Jan-16-2008    rfieldma    created
--
--   End of Comments
--
TYPE  CSD_RO_SC_IDS_TBL_TYPE      IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:RO_BULLETIN_REC_TYPE
--   -------------------------------------------------------
--   Parameters:
--    RO_BULLETIN_ID
--    REPAIR_LINE_ID
--    BULLETIN_ID
--    LAST_VIEWED_DATE
--    LAST_VIEWED_BY
--    SOURCE_TYPE
--    SOURCE_ID
--    OBJECT_VERSION_NUMBER
--    CREATED_BY
--    CREATION_DATE
--    LAST_UPDATED_BY
--    LAST_UPDATE_DATE
--    LAST_UPDATE_LOGIN
--
--    Required:
--    Defaults:     FND_API.G_MISS*
--   History: Jan-16-2008    rfieldma    created
--
--   End of Comments
--
TYPE RO_BULLETIN_REC_TYPE IS RECORD
(
    RO_BULLETIN_ID                  NUMBER       := FND_API.G_MISS_NUM
   ,REPAIR_LINE_ID                  NUMBER       := FND_API.G_MISS_NUM
   ,BULLETIN_ID                     NUMBER       := FND_API.G_MISS_NUM
   ,LAST_VIEWED_DATE                DATE         := FND_API.G_MISS_DATE
   ,LAST_VIEWED_BY                  NUMBER       := FND_API.G_MISS_NUM
   ,SOURCE_TYPE                     VARCHAR2(30) := FND_API.G_MISS_CHAR
   ,SOURCE_ID                       NUMBER       := FND_API.G_MISS_NUM
   ,OBJECT_VERSION_NUMBER           NUMBER       := FND_API.G_MISS_NUM
   ,CREATED_BY                      NUMBER       := FND_API.G_MISS_NUM
   ,CREATION_DATE                   DATE         := FND_API.G_MISS_DATE
   ,LAST_UPDATED_BY                 NUMBER       := FND_API.G_MISS_NUM
   ,LAST_UPDATE_DATE                DATE         := FND_API.G_MISS_DATE
   ,LAST_UPDATE_LOGIN               NUMBER       := FND_API.G_MISS_NUM
);

G_MISS_RO_BULLETIN_REC          RO_BULLETIN_REC_TYPE;
TYPE  RO_BULLETIN_TBL_TYPE      IS TABLE OF RO_BULLETIN_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_RO_BULLETIN_TBL          RO_BULLETIN_TBL_TYPE;

--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:TYPE_RO_BULLETIN_PARAMS_REC_TYPE
--   -------------------------------------------------------
--   This record holds all the params set by the user when running
--   the concurrent program to link repair orders to bulletins.
--   (LINK_BULLETINS_TO_REPAIRS_CONC_PROG)
--   Parameters:
--    BULLETIN_TYPE_CODE
--    RO_FLOW_STATUS_ID
--    RO_INV_ORG_ID
--    RO_REPAIR_ORG_ID
--    RO_INV_ITEM_ID
-- -------------------
--   End of Comments
-- -------------------
TYPE RO_BULLETIN_PARAMS_REC_TYPE IS RECORD
(
     BULLETIN_TYPE_CODE   VARCHAR2(30)  := NULL
    ,RO_FLOW_STATUS_ID    NUMBER        := NULL
    ,RO_INV_ORG_ID        NUMBER        := NULL
    ,RO_REPAIR_ORG_ID     NUMBER        := NULL
    ,RO_INV_ITEM_ID       NUMBER        := NULL
);

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  CREATE_RO_BULLETIN
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_RO_BULLETIN_Rec         IN   CSD_RO_BULLETIN_REC_TYPE  Required
--
--   OUT:
--       x_return_status           OUT  NOCOPY VARCHAR2
--       x_msg_count               OUT  NOCOPY NUMBER
--       x_msg_data                OUT  NOCOPY VARCHAR2
--       x_RO_BULLETIN_ID          OUT  NOCOPY NUMBER
--   History: Jan-16-2008    rfieldma    created
-- -------------------
--   End of Comments
-- -------------------
PROCEDURE CREATE_RO_BULLETIN(
   p_api_version_number         IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2   := FND_API.G_FALSE,
   p_commit                     IN   VARCHAR2   := FND_API.G_FALSE,
   p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
   p_ro_bulletin_rec            IN   RO_BULLETIN_Rec_Type  /*:= G_MISS_CSD_RO_BULLETIN_REC*/,
   x_ro_bulletin_id             OUT  NOCOPY NUMBER,
   x_return_status              OUT  NOCOPY VARCHAR2,
   x_msg_count                  OUT  NOCOPY NUMBER,
   x_msg_data                   OUT  NOCOPY VARCHAR2
);

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  UPDATE_RO_BULLETIN
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_RO_BULLETIN_Rec         IN   CSD_RO_BULLETIN_REC_TYPE  Required
--
--   OUT:
--       x_return_status           OUT NOCOPY VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   History: Jan-16-2008    rfieldma    created
-- -------------------
--   End of Comments
-- -------------------
PROCEDURE UPDATE_RO_BULLETIN(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2   := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    p_ro_bulletin_rec            IN   RO_BULLETIN_Rec_Type,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2
);

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  DELETE_RO_BULLETIN
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_ro_bulletin_id          IN   NUMBER     Required
--
--   OUT:
--       x_return_status           OUT  NOCOPY VARCHAR2
--       x_msg_count               OUT  NOCOPY NUMBER
--       x_msg_data                OUT  NOCOPY VARCHAR2
--   History: Jan-16-2008    rfieldma    created
-- -------------------
--   End of Comments
-- -------------------
PROCEDURE DELETE_RO_BULLETIN(
   p_api_version_number         IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2   := FND_API.G_FALSE,
   p_commit                     IN   VARCHAR2   := FND_API.G_FALSE,
   p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
   p_ro_bulletin_id             IN   NUMBER,
   x_return_status              OUT  NOCOPY VARCHAR2,
   x_msg_count                  OUT  NOCOPY NUMBER,
   x_msg_data                   OUT  NOCOPY VARCHAR2
);

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  LOCK_RO_BULLETIN
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_ro_bulletin_rec         IN   RO_BULLETIN_REC_TYPE  Required
--   OUT:
--       x_return_status           OUT  NOCOPY VARCHAR2
--       x_msg_count               OUT  NOCOPY NUMBER
--       x_msg_data                OUT  NOCOPY VARCHAR2
--   History: Jan-16-2008    rfieldma    created
-- -------------------
--   End of Comments
-- -------------------
PROCEDURE LOCK_RO_BULLETIN(
   p_api_version_number         IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2   := FND_API.G_FALSE,
   p_commit                     IN   VARCHAR2   := FND_API.G_FALSE,
   p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
   p_ro_bulletin_rec            IN   RO_BULLETIN_Rec_Type,
   x_return_status              OUT  NOCOPY VARCHAR2,
   x_msg_count                  OUT  NOCOPY NUMBER,
   x_msg_data                   OUT  NOCOPY VARCHAR2
);


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  LINK_BULLETINS_TO_RO
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_repair_line_id          IN   NUMBER     Required
--       px_sc_ids_tbl             IN OUT NOCOPY  CSD_RO_SC_IDS_TBL_TYPE Required
--   OUT:
--       x_return_status           OUT  NOCOPY VARCHAR2
--       x_msg_count               OUT  NOCOPY NUMBER
--       x_msg_data                OUT  NOCOPY VARCHAR2
--   History:  Jan-16-2008    rfieldma    created
-- -------------------
--   End of Comments
-- -------------------
PROCEDURE LINK_BULLETINS_TO_RO(
   p_api_version_number         IN            NUMBER,
   p_init_msg_list              IN            VARCHAR2   := FND_API.G_FALSE,
   p_commit                     IN            VARCHAR2   := FND_API.G_FALSE,
   p_validation_level           IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
   p_repair_line_id             IN            NUMBER,
   px_ro_sc_ids_tbl             IN OUT NOCOPY CSD_RO_SC_IDS_TBL_TYPE,
   x_return_status              OUT    NOCOPY VARCHAR2,
   x_msg_count                  OUT    NOCOPY NUMBER,
   x_msg_data                   OUT    NOCOPY VARCHAR2
);

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  CREATE_NEW_RO_BULLETIN_LINK
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_repair_line_id          IN   NUMBER     Required
--       p_bulletin_id             IN   NUMBER     Required
--       p_rule_id                 IN   NUMBER     Required
--       px_sc_ids_tbl             IN OUT NOCOPY  CSD_RO_SC_IDS_TBL_TYPE Required
--   OUT:
--       x_return_status           OUT  NOCOPY VARCHAR2
--       x_msg_count               OUT  NOCOPY NUMBER
--       x_msg_data                OUT  NOCOPY VARCHAR2
--   History:  Jan-17-2008    rfieldma    created
-- -------------------
--   End of Comments
-- -------------------
PROCEDURE CREATE_NEW_RO_BULLETIN_LINK(
   p_api_version_number  IN            NUMBER,
   p_commit              IN            VARCHAR2,
   p_init_msg_list       IN            VARCHAR2,
   p_validation_level    IN            NUMBER,
   p_repair_line_id      IN            NUMBER,
   p_bulletin_id         IN            NUMBER,
   p_rule_id             IN            NUMBER,
   px_ro_sc_ids_tbl      IN OUT NOCOPY CSD_RO_SC_IDS_TBL_TYPE,
   x_return_status       OUT    NOCOPY VARCHAR2,
   x_msg_count           OUT    NOCOPY NUMBER,
   x_msg_data            OUT    NOCOPY VARCHAR2
);

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  GET_CSD_REPAIRS_OBJ_VER_NUM
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_repair_line_id          IN   NUMBER     Required
--   OUT:
--       NUMBER obj_ver_num
--   History:  Jan-17-2008    rfieldma    created
-- -------------------
--   End of Comments
-- -------------------
FUNCTION GET_CSD_REPAIRS_OBJ_VER_NUM(
   p_repair_line_id      IN            NUMBER
) RETURN NUMBER;

/*--------------------------------------------------------------------*/
/* procedure name: LINK_BULLETINS_TO_REPAIRS_CP                       */
/* description : Links all active bulletins to all matching repairs   */
/*                                                                    */
/* STANDARD PARAMETERS                                                */
/*  In Parameters :                                                   */
/*                                                                    */
/*  Output Parameters:                                                */
/*   errbuf              VARCHAR2      Error message                  */
/*   retcode             VARCHAR2      Error Code                     */
/*                                                                    */
/* NON-STANDARD PARAMETERS                                            */
/*   In Parameters                                                    */
/*    p_repair_line_id   NUMBER   Optional   Repair Order Line Id     */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
PROCEDURE LINK_BULLETINS_TO_REPAIRS_CP (
    errbuf             OUT NOCOPY    varchar2,
    retcode            OUT NOCOPY    varchar2,
    --concurrent program parameters go here
    p_BULLETIN_TYPE_CODE IN   VARCHAR2      := NULL,
    p_RO_FLOW_STATUS_ID  IN   NUMBER        := NULL,
    p_RO_INV_ORG_ID      IN   NUMBER        := NULL,
    p_RO_REPAIR_ORG_ID   IN   NUMBER        := NULL,
    p_RO_INV_ITEM_ID     IN   NUMBER        := NULL);

/*--------------------------------------------------------------------*/
/* procedure name: LINK_BULLETIN_FOR_RULE                             */
/* description : Given a single rule, find all matching repair orders */
/*               and link them to the given bulletin, if applicable   */
/*                                                                    */
/* Called from : PROCEDURE  LINK_BULLETINS_TO_REPAIRS_CP              */
/* Input Parm  :                                                      */
/*    p_bulletin_rule_id      NUMBER     Req                          */
/*    p_bulletin_id           NUMBER     Req                          */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
PROCEDURE LINK_BULLETIN_FOR_RULE (
    p_api_version_number   IN   NUMBER,
    p_commit               IN   VARCHAR2,
    p_init_msg_list        IN   VARCHAR2,
    p_validation_level     IN   NUMBER,
    x_return_status        OUT  NOCOPY  VARCHAR2,
    x_msg_count            OUT  NOCOPY  NUMBER,
    x_msg_data             OUT  NOCOPY  VARCHAR2,
    p_bulletin_id          IN   NUMBER := NULL,
    p_bulletin_rule_id     IN   NUMBER,
    p_params               IN   RO_BULLETIN_PARAMS_REC_TYPE
);


/*--------------------------------------------------------------------*/
/* procedure name: APPLY_BULLETIN_SCS_TO_RO                           */
/* description : Given set of service codes from a service bulletin   */
/*               mark them as applicable for a repair order           */
/*                                                                    */
/* Called from : PROCEDURE  LINK_BULLETIN_FOR_RULE                    */
/* Input Parm  :                                                      */
/*    p_service_codes       CSD_RO_SC_IDS_TBL_TYPE     Req            */
/*    p_repair_line_id      NUMBER                     Req            */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
PROCEDURE APPLY_BULLETIN_SCS_TO_RO (
    p_api_version_number   IN   NUMBER,
    p_commit               IN   VARCHAR2,
    p_init_msg_list        IN   VARCHAR2,
    p_validation_level     IN   NUMBER,
    x_return_status        OUT  NOCOPY  VARCHAR2,
    x_msg_count            OUT  NOCOPY  NUMBER,
    x_msg_data             OUT  NOCOPY  VARCHAR2,
    p_service_codes        IN   CSD_RO_SC_IDS_TBL_TYPE,
    p_repair_line_id       IN   NUMBER
);

END CSD_RO_BULLETINS_PVT; /* package spec ends */

/
