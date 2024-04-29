--------------------------------------------------------
--  DDL for Package Body GMO_INSTRUCTION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMO_INSTRUCTION_GRP" AS
/*$Header: GMOGINTB.pls 120.3 2006/07/12 04:51:18 rahugupt noship $*/

PROCEDURE CREATE_DEFN_CONTEXT
(
    P_API_VERSION           IN NUMBER,
    P_INIT_MSG_LIST         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_VALIDATION_LEVEL      IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2,
    P_CURR_INSTR_PROCESS_ID IN NUMBER DEFAULT NULL,
    P_ENTITY_NAME           IN FND_TABLE_OF_VARCHAR2_255,
    P_ENTITY_KEY            IN FND_TABLE_OF_VARCHAR2_255,
    P_ENTITY_DISPLAYNAME    IN FND_TABLE_OF_VARCHAR2_255,
    P_INSTRUCTION_TYPE      IN FND_TABLE_OF_VARCHAR2_255,
    P_MODE                  IN VARCHAR2 DEFAULT GMO_CONSTANTS_GRP.G_INSTR_DEFN_MODE_UPDATE,
    P_CONTEXT_PARAMETERS    IN GMO_DATATYPES_GRP.GMO_DEFINITION_PARAM_TBL_TYPE,
    X_INSTRUCTION_PROCESS_ID OUT NOCOPY NUMBER

) IS PRAGMA AUTONOMOUS_TRANSACTION;

l_api_name      CONSTANT VARCHAR2(30)   := 'CREATE_DEFN_CONTEXT';
l_api_version   CONSTANT NUMBER         := 1.0;

BEGIN

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,l_api_name,G_PKG_NAME) THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
             FND_MSG_PUB.initialize;
      END IF;

      --  Initialize API return status to success
      X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

      -- CALL CORRESPONDING PRIVATE API
      GMO_INSTRUCTION_PVT.CREATE_DEFN_CONTEXT
      (
          P_CURR_INSTR_PROCESS_ID => P_CURR_INSTR_PROCESS_ID,
          P_ENTITY_NAME           => P_ENTITY_NAME,
          P_ENTITY_KEY            => P_ENTITY_KEY,
          P_ENTITY_DISPLAYNAME    => P_ENTITY_DISPLAYNAME,
          P_INSTRUCTION_TYPE      => P_INSTRUCTION_TYPE,
          P_MODE                  => P_MODE,
          P_CONTEXT_PARAMETERS    => P_CONTEXT_PARAMETERS,
          X_INSTRUCTION_PROCESS_ID => X_INSTRUCTION_PROCESS_ID,
          X_RETURN_STATUS          => X_RETURN_STATUS,
          X_MSG_COUNT              => X_MSG_COUNT,
          X_MSG_DATA               => X_MSG_DATA
      );

      IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          COMMIT  ;
      ELSE
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK;
                x_return_status := FND_API.G_RET_STS_ERROR;

		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_instruction_grp.create_defn_context', FALSE);
                end if;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_instruction_grp.create_defn_context', FALSE);
                end if;

    WHEN OTHERS THEN
                ROLLBACK;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
                END IF;

                FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_instruction_grp.create_defn_context', FALSE);
                end if;

END CREATE_DEFN_CONTEXT;

PROCEDURE CREATE_DEFN_CONTEXT
(
    P_API_VERSION           IN NUMBER,
    P_INIT_MSG_LIST         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_VALIDATION_LEVEL      IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2,

    P_CURR_INSTR_PROCESS_ID IN NUMBER DEFAULT NULL,
    P_ENTITY_NAME           IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
    P_ENTITY_KEY            IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
    P_ENTITY_DISPLAYNAME    IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
    P_INSTRUCTION_TYPE      IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
    P_MODE                  IN VARCHAR2 DEFAULT GMO_CONSTANTS_GRP.G_INSTR_DEFN_MODE_UPDATE,
    P_CONTEXT_PARAMETERS    IN GMO_DATATYPES_GRP.GMO_DEFINITION_PARAM_TBL_TYPE,
    X_INSTRUCTION_PROCESS_ID OUT NOCOPY NUMBER
)
IS PRAGMA AUTONOMOUS_TRANSACTION;

    l_api_name      CONSTANT VARCHAR2(30)   := 'CREATE_DEFN_CONTEXT';
    l_api_version   CONSTANT NUMBER         := 1.0;

    L_ENTITY_NAME FND_TABLE_OF_VARCHAR2_255;
    L_ENTITY_KEY FND_TABLE_OF_VARCHAR2_255;
    L_ENTITY_DISPLAYNAME FND_TABLE_OF_VARCHAR2_255;
    L_INSTRUCTION_TYPE FND_TABLE_OF_VARCHAR2_255;

BEGIN

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,l_api_name,G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

  L_ENTITY_NAME := FND_TABLE_OF_VARCHAR2_255();
  L_ENTITY_KEY := FND_TABLE_OF_VARCHAR2_255();
  L_ENTITY_DISPLAYNAME := FND_TABLE_OF_VARCHAR2_255();
  L_INSTRUCTION_TYPE := FND_TABLE_OF_VARCHAR2_255();

  FOR J IN 1..P_INSTRUCTION_TYPE.count LOOP
      L_INSTRUCTION_TYPE.EXTEND;
      L_INSTRUCTION_TYPE(J) := P_INSTRUCTION_TYPE(J);
  END LOOP;

  FOR I IN 1..P_ENTITY_NAME.COUNT LOOP
    L_ENTITY_NAME.EXTEND;
    L_ENTITY_KEY.EXTEND;
    L_ENTITY_DISPLAYNAME.EXTEND;

    L_ENTITY_NAME(I) := P_ENTITY_NAME(I);
    L_ENTITY_KEY(I) := P_ENTITY_KEY(I);
    L_ENTITY_DISPLAYNAME(I) := P_ENTITY_DISPLAYNAME(I);
  END LOOP;

  BEGIN

        GMO_INSTRUCTION_PVT.CREATE_DEFN_CONTEXT
        (
            P_CURR_INSTR_PROCESS_ID => P_CURR_INSTR_PROCESS_ID,
            P_ENTITY_NAME => L_ENTITY_NAME,
            P_ENTITY_KEY => L_ENTITY_KEY,
            P_ENTITY_DISPLAYNAME => L_ENTITY_DISPLAYNAME,
            P_INSTRUCTION_TYPE => L_INSTRUCTION_TYPE,
            P_MODE => P_MODE,
            P_CONTEXT_PARAMETERS => P_CONTEXT_PARAMETERS,
            X_INSTRUCTION_PROCESS_ID => X_INSTRUCTION_PROCESS_ID,
            X_RETURN_STATUS => X_RETURN_STATUS,
            X_MSG_COUNT => X_MSG_COUNT,
            X_MSG_DATA => X_MSG_DATA
        );

  END;

  IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        COMMIT;
  ELSE
       RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK;
                x_return_status := FND_API.G_RET_STS_ERROR;

		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_instruction_grp.create_defn_context', FALSE);
                end if;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_instruction_grp.create_defn_context', FALSE);
                end if;

    WHEN OTHERS THEN
                ROLLBACK;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
                END IF;

                FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_instruction_grp.create_defn_context', FALSE);
                end if;
END CREATE_DEFN_CONTEXT;


PROCEDURE DELETE_ENTITY_FOR_PROCESS
(
       P_API_VERSION           IN NUMBER,
       P_INIT_MSG_LIST         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
       P_VALIDATION_LEVEL      IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
       X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
       X_MSG_COUNT             OUT NOCOPY NUMBER,
       X_MSG_DATA              OUT NOCOPY VARCHAR2,

       P_CURR_INSTR_PROCESS_ID   IN NUMBER,
       P_ENTITY_NAME             IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
       P_ENTITY_KEY              IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
       X_INSTRUCTION_PROCESS_ID  OUT NOCOPY NUMBER

)IS PRAGMA AUTONOMOUS_TRANSACTION;
    l_api_name      CONSTANT VARCHAR2(30)   := 'DELETE_ENTITY_FOR_PROCESS';
    l_api_version   CONSTANT NUMBER         := 1.0;

BEGIN

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,l_api_name,G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
   END IF;

  --  Initialize API return status to success
  X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

  BEGIN

        GMO_INSTRUCTION_PVT.DELETE_ENTITY_FOR_PROCESS
        (
            P_CURR_INSTR_PROCESS_ID => P_CURR_INSTR_PROCESS_ID,
            P_ENTITY_NAME => P_ENTITY_NAME,
            P_ENTITY_KEY => P_ENTITY_KEY,
            X_INSTRUCTION_PROCESS_ID => X_INSTRUCTION_PROCESS_ID,
            X_RETURN_STATUS => X_RETURN_STATUS,
            X_MSG_COUNT => X_MSG_COUNT,
            X_MSG_DATA => X_MSG_DATA
        );

  END;

  IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        COMMIT;
  ELSE
       RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK;
                x_return_status := FND_API.G_RET_STS_ERROR;

		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_instruction_grp.delete_entity_for_process', FALSE);
                end if;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_instruction_grp.delete_entity_for_process', FALSE);
                end if;

    WHEN OTHERS THEN
                ROLLBACK;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
                END IF;

                FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_instruction_grp.delete_entity_for_process', FALSE);
                end if;
END DELETE_ENTITY_FOR_PROCESS;


PROCEDURE CREATE_DEFN_CONTEXT
(
    P_API_VERSION           IN NUMBER,
    P_INIT_MSG_LIST         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_VALIDATION_LEVEL      IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2,

    P_CURR_INSTR_PROCESS_ID IN NUMBER DEFAULT NULL,
    P_ENTITY_NAME           IN VARCHAR2,
    P_ENTITY_KEY            IN VARCHAR2,
    P_ENTITY_DISPLAYNAME    IN VARCHAR2,
    P_INSTRUCTION_TYPE      IN VARCHAR2,
    P_MODE                  IN VARCHAR2 DEFAULT GMO_CONSTANTS_GRP.G_INSTR_DEFN_MODE_UPDATE,
    P_CONTEXT_PARAMETERS    IN GMO_DATATYPES_GRP.GMO_DEFINITION_PARAM_TBL_TYPE,
    X_INSTRUCTION_PROCESS_ID OUT NOCOPY NUMBER

) IS PRAGMA AUTONOMOUS_TRANSACTION;

    l_api_name      CONSTANT VARCHAR2(30)   := 'CREATE_DEFN_CONTEXT';
    l_api_version   CONSTANT NUMBER         := 1.0;

    L_ENTITY_NAME FND_TABLE_OF_VARCHAR2_255;
    L_ENTITY_KEY FND_TABLE_OF_VARCHAR2_255;
    L_ENTITY_DISPLAYNAME FND_TABLE_OF_VARCHAR2_255;
    L_INSTRUCTION_TYPE FND_TABLE_OF_VARCHAR2_255;

BEGIN
     -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,l_api_name,G_PKG_NAME) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
     END IF;

    --  Initialize API return status to success
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    L_ENTITY_NAME := FND_TABLE_OF_VARCHAR2_255();
    L_ENTITY_KEY := FND_TABLE_OF_VARCHAR2_255();
    L_ENTITY_DISPLAYNAME := FND_TABLE_OF_VARCHAR2_255();
    L_INSTRUCTION_TYPE := FND_TABLE_OF_VARCHAR2_255();

    L_ENTITY_NAME.EXTEND;
    L_ENTITY_KEY.EXTEND;
    L_ENTITY_DISPLAYNAME.EXTEND;
    L_INSTRUCTION_TYPE.EXTEND;

    L_ENTITY_NAME(1) := P_ENTITY_NAME;
    L_ENTITY_KEY(1) := P_ENTITY_KEY;
    L_ENTITY_DISPLAYNAME(1) := P_ENTITY_DISPLAYNAME;
    L_INSTRUCTION_TYPE(1) := P_INSTRUCTION_TYPE;

    BEGIN

	GMO_INSTRUCTION_PVT.CREATE_DEFN_CONTEXT
        (
            P_CURR_INSTR_PROCESS_ID => P_CURR_INSTR_PROCESS_ID,
            P_ENTITY_NAME => L_ENTITY_NAME,
            P_ENTITY_KEY => L_ENTITY_KEY,
            P_ENTITY_DISPLAYNAME => L_ENTITY_DISPLAYNAME,
            P_INSTRUCTION_TYPE => L_INSTRUCTION_TYPE,
            P_MODE => P_MODE,
            P_CONTEXT_PARAMETERS => P_CONTEXT_PARAMETERS,
            X_INSTRUCTION_PROCESS_ID => X_INSTRUCTION_PROCESS_ID,
            X_RETURN_STATUS => X_RETURN_STATUS,
            X_MSG_COUNT => X_MSG_COUNT,
            X_MSG_DATA => X_MSG_DATA
        );

    END;

    IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        COMMIT  ;
    ELSE
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK;
                x_return_status := FND_API.G_RET_STS_ERROR;

		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_instruction_grp.create_defn_context', FALSE);
                end if;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_instruction_grp.create_defn_context', FALSE);
                end if;

    WHEN OTHERS THEN
                ROLLBACK;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
                END IF;

                FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_instruction_grp.create_defn_context', FALSE);
                end if;

END CREATE_DEFN_CONTEXT;

PROCEDURE CREATE_DEFN_FROM_DEFN
(
    P_API_VERSION           IN NUMBER,
    P_INIT_MSG_LIST         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_COMMIT                IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_VALIDATION_LEVEL      IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2,

    P_SOURCE_ENTITY_NAME   IN VARCHAR2,
    P_SOURCE_ENTITY_KEY    IN VARCHAR2,
    P_TARGET_ENTITY_NAME   IN VARCHAR2,
    P_TARGET_ENTITY_KEY    IN VARCHAR2,
    P_INSTRUCTION_TYPE      IN VARCHAR2,
    X_INSTRUCTION_SET_ID    OUT NOCOPY NUMBER

)
IS
    l_api_name      CONSTANT VARCHAR2(30)   := 'CREATE_DEFN_FROM_DEFN';
    l_api_version   CONSTANT NUMBER         := 1.0;

BEGIN

     -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,l_api_name,G_PKG_NAME) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
     END IF;

    --  Initialize API return status to success
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    GMO_INSTRUCTION_PVT.CREATE_DEFN_FROM_DEFN
    (
        P_SOURCE_ENTITY_NAME => P_SOURCE_ENTITY_NAME,
	P_SOURCE_ENTITY_KEY => P_SOURCE_ENTITY_KEY,
	P_TARGET_ENTITY_NAME => P_TARGET_ENTITY_NAME,
	P_TARGET_ENTITY_KEY => P_TARGET_ENTITY_KEY,
	P_INSTRUCTION_TYPE => P_INSTRUCTION_TYPE,
	X_INSTRUCTION_SET_ID => X_INSTRUCTION_SET_ID,
	X_RETURN_STATUS => X_RETURN_STATUS,
	X_MSG_COUNT => X_MSG_COUNT,
	X_MSG_DATA => X_MSG_DATA
    );


    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);

    IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        IF FND_API.To_Boolean( p_commit ) THEN
             COMMIT  ;
        END IF;
    ELSE
         RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN

                x_return_status := FND_API.G_RET_STS_ERROR;

		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_instruction_grp.create_defn_from_defn', FALSE);
                end if;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_instruction_grp.create_defn_from_defn', FALSE);
                end if;

    WHEN OTHERS THEN

                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
                END IF;

                FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_instruction_grp.create_defn_from_defn', FALSE);
                end if;

END CREATE_DEFN_FROM_DEFN;

PROCEDURE SEND_DEFN_ACKN
(
    P_API_VERSION           IN NUMBER,
    P_INIT_MSG_LIST         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_COMMIT                IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_VALIDATION_LEVEL      IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2,

    P_INSTRUCTION_PROCESS_ID    IN NUMBER,
    P_ENTITY_NAME               IN VARCHAR2,
    P_SOURCE_ENTITY_KEY         IN VARCHAR2,
    P_TARGET_ENTITY_KEY         IN VARCHAR2
)

IS

    l_api_name      CONSTANT VARCHAR2(30)   := 'SEND_DEFN_ACKN';
    l_api_version   CONSTANT NUMBER         := 1.0;

    L_ENTITY_NAME FND_TABLE_OF_VARCHAR2_255;
    L_SOURCE_ENTITY_KEY FND_TABLE_OF_VARCHAR2_255;
    L_TARGET_ENTITY_KEY FND_TABLE_OF_VARCHAR2_255;

BEGIN
      -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,l_api_name,G_PKG_NAME) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
     END IF;

     --  Initialize API return status to success
     X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

     L_ENTITY_NAME := FND_TABLE_OF_VARCHAR2_255();
     L_SOURCE_ENTITY_KEY := FND_TABLE_OF_VARCHAR2_255();
     L_TARGET_ENTITY_KEY := FND_TABLE_OF_VARCHAR2_255();

     L_ENTITY_NAME.EXTEND;
     L_SOURCE_ENTITY_KEY.EXTEND;
     L_TARGET_ENTITY_KEY.EXTEND;

     L_ENTITY_NAME(1) := P_ENTITY_NAME;
     L_SOURCE_ENTITY_KEY(1) := P_SOURCE_ENTITY_KEY;
     L_TARGET_ENTITY_KEY(1) := P_TARGET_ENTITY_KEY;

     GMO_INSTRUCTION_PVT.SEND_DEFN_ACKN
     (
             P_INSTRUCTION_PROCESS_ID => P_INSTRUCTION_PROCESS_ID,
             P_ENTITY_NAME => L_ENTITY_NAME,
             P_SOURCE_ENTITY_KEY => L_SOURCE_ENTITY_KEY,
             P_TARGET_ENTITY_KEY => L_TARGET_ENTITY_KEY,
             X_RETURN_STATUS => X_RETURN_STATUS,
             X_MSG_COUNT => X_MSG_COUNT,
             X_MSG_DATA => X_MSG_DATA
    );

    IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT  ;
        END IF;
    ELSE
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
                x_return_status := FND_API.G_RET_STS_ERROR;

		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_instruction_grp.send_defn_ackn', FALSE);
                end if;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_instruction_grp.send_defn_ackn', FALSE);
                end if;

    WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
                END IF;

                FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_instruction_grp.send_defn_ackn', FALSE);
                end if;

END SEND_DEFN_ACKN;

/* This procedure copies the data from temporary tables back to
   permenant tables, and also checks if there was any modification to
   permenant tables, before copying the data back to permentant tables
   and marks the instruction set as acknowledged */

PROCEDURE SEND_DEFN_ACKN
(
    P_API_VERSION           IN NUMBER,
    P_INIT_MSG_LIST         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_COMMIT                IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_VALIDATION_LEVEL      IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2,

    P_INSTRUCTION_PROCESS_ID    IN NUMBER,
    P_ENTITY_NAME               IN FND_TABLE_OF_VARCHAR2_255,
    P_SOURCE_ENTITY_KEY         IN FND_TABLE_OF_VARCHAR2_255,
    P_TARGET_ENTITY_KEY         IN FND_TABLE_OF_VARCHAR2_255
)

IS

  l_api_name      CONSTANT VARCHAR2(30)   := 'SEND_DEFN_ACKN';
  l_api_version   CONSTANT NUMBER         := 1.0;

BEGIN

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,l_api_name,G_PKG_NAME) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

   GMO_INSTRUCTION_PVT.SEND_DEFN_ACKN
   (
           P_INSTRUCTION_PROCESS_ID => P_INSTRUCTION_PROCESS_ID,
	   P_ENTITY_NAME => P_ENTITY_NAME,
	   P_SOURCE_ENTITY_KEY => P_SOURCE_ENTITY_KEY,
	   P_TARGET_ENTITY_KEY => P_SOURCE_ENTITY_KEY,
	   X_RETURN_STATUS => X_RETURN_STATUS,
	   X_MSG_COUNT => X_MSG_COUNT,
	   X_MSG_DATA => X_MSG_DATA
   );

    IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT  ;
        END IF;
    ELSE
        RAISE FND_API.G_EXC_ERROR;
    END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
                x_return_status := FND_API.G_RET_STS_ERROR;

		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_instruction_grp.send_defn_ackn', FALSE);
                end if;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_instruction_grp.send_defn_ackn', FALSE);
                end if;

    WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
                END IF;

                FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_instruction_grp.send_defn_ackn', FALSE);
                end if;
END SEND_DEFN_ACKN;

PROCEDURE SEND_DEFN_ACKN
(
    P_API_VERSION           IN NUMBER,
    P_INIT_MSG_LIST         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_COMMIT                IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_VALIDATION_LEVEL      IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2,

    P_INSTRUCTION_PROCESS_ID    IN NUMBER,
    P_ENTITY_NAME               IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
    P_SOURCE_ENTITY_KEY         IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
    P_TARGET_ENTITY_KEY         IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255

)
IS

  l_api_name      CONSTANT VARCHAR2(30)   := 'SEND_DEFN_ACKN';
  l_api_version   CONSTANT NUMBER         := 1.0;

BEGIN

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,l_api_name,G_PKG_NAME) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

   GMO_INSTRUCTION_PVT.SEND_DEFN_ACKN
   (
           P_INSTRUCTION_PROCESS_ID => P_INSTRUCTION_PROCESS_ID,
	   P_ENTITY_NAME => P_ENTITY_NAME,
	   P_SOURCE_ENTITY_KEY => P_SOURCE_ENTITY_KEY,
	   P_TARGET_ENTITY_KEY => P_TARGET_ENTITY_KEY,
	   X_RETURN_STATUS => X_RETURN_STATUS,
	   X_MSG_COUNT => X_MSG_COUNT,
	   X_MSG_DATA => X_MSG_DATA
   );

    IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT  ;
        END IF;
    ELSE
        RAISE FND_API.G_EXC_ERROR;
    END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
                x_return_status := FND_API.G_RET_STS_ERROR;

		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_instruction_grp.send_defn_ackn', FALSE);
                end if;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_instruction_grp.send_defn_ackn', FALSE);
                end if;

    WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
                END IF;

                FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_instruction_grp.send_defn_ackn', FALSE);
                end if;

END SEND_DEFN_ACKN;


PROCEDURE GET_DEFN_STATUS
(
    P_API_VERSION           IN NUMBER,
    P_INIT_MSG_LIST         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_VALIDATION_LEVEL      IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2,

    P_INSTRUCTION_PROCESS_ID IN NUMBER,
    X_DEFINITION_STATUS OUT NOCOPY VARCHAR2

)
IS

  l_api_name      CONSTANT VARCHAR2(30)   := 'GET_DEFN_STATUS';
  l_api_version   CONSTANT NUMBER         := 1.0;


BEGIN
  -- Standard Start of API savepoint
   SAVEPOINT  GET_DEFN_STATUS_GRP;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,l_api_name,G_PKG_NAME) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

   SELECT ATTRIBUTE_VALUE INTO X_DEFINITION_STATUS
   FROM GMO_INSTR_ATTRIBUTES_T
   WHERE ATTRIBUTE_NAME  = 'DEFINITION_STATUS'
   AND INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID;



   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO GET_DEFN_STATUS_GRP;
                x_return_status := FND_API.G_RET_STS_ERROR;

		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_instruction_grp.get_defn_status', FALSE);
                end if;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO GET_DEFN_STATUS_GRP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_instruction_grp.get_defn_status', FALSE);
                end if;

    WHEN OTHERS THEN
                ROLLBACK TO GET_DEFN_STATUS_GRP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
                END IF;

                FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_instruction_grp.get_defn_status', FALSE);
                end if;

END GET_DEFN_STATUS;

-- This procedure is used to fetch the instruction set and related
-- instruction details in XML format

PROCEDURE GET_INSTR_XML
(
    P_API_VERSION           IN NUMBER,
    P_INIT_MSG_LIST         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_VALIDATION_LEVEL      IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2,


    P_INSTRUCTION_PROCESS_ID IN NUMBER,
    X_OUTPUT_XML  OUT NOCOPY CLOB
)
IS

  l_api_name      CONSTANT VARCHAR2(30)   := 'GET_INSTR_XML';
  l_api_version   CONSTANT NUMBER         := 1.0;

  --This variable would hold the XML details in XMLType format.
  L_INSTR_XML XMLTYPE;

BEGIN
     -- Standard Start of API savepoint
     SAVEPOINT  GET_INSTR_XML_GRP;

     -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,l_api_name,G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
     END IF;

     --  Initialize API return status to success
     X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

     --Call Private API , which will return the XML Clob
     GMO_INSTRUCTION_PVT.GET_INSTR_XML
     (
          P_INSTRUCTION_PROCESS_ID => P_INSTRUCTION_PROCESS_ID,
	  X_OUTPUT_XML => X_OUTPUT_XML
     );

     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO GET_INSTR_XML_GRP;
                x_return_status := FND_API.G_RET_STS_ERROR;

		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_instruction_grp.GET_INSTR_XML', FALSE);
                end if;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO GET_INSTR_XML_GRP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_instruction_grp.GET_INSTR_XML', FALSE);
                end if;

    WHEN OTHERS THEN
                ROLLBACK TO GET_INSTR_XML_GRP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
                END IF;

                FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_instruction_grp.GET_INSTR_XML', FALSE);
                end if;

END GET_INSTR_XML;

-- This procedure is used to fetch the instruction instance details
-- in XML format

PROCEDURE GET_INSTR_INSTANCE_XML
(
    P_API_VERSION           IN NUMBER,
    P_INIT_MSG_LIST         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_VALIDATION_LEVEL      IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2,


    P_INSTRUCTION_PROCESS_ID IN NUMBER,
    X_OUTPUT_XML  OUT NOCOPY CLOB
)
IS

  l_api_name      CONSTANT VARCHAR2(30)   := 'GET_INSTR_XML';
  l_api_version   CONSTANT NUMBER         := 1.0;

  --This variable would hold the XML details in XMLType format.
  L_INSTR_XML XMLTYPE;

BEGIN
     -- Standard Start of API savepoint
     SAVEPOINT  GET_INSTR_XML_GRP;

     -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,l_api_name,G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
     END IF;

     --  Initialize API return status to success
     X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

     --Call Private API , which will return the XML Clob
     GMO_INSTRUCTION_PVT.GET_INSTR_INSTANCE_XML
     (
          P_INSTRUCTION_PROCESS_ID => P_INSTRUCTION_PROCESS_ID,
          X_OUTPUT_XML => X_OUTPUT_XML
     );

     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO GET_INSTR_XML_GRP;
                x_return_status := FND_API.G_RET_STS_ERROR;

                FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_instruction_grp.GET_INSTR_INSTANCE_XML', FALSE);
                end if;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO GET_INSTR_XML_GRP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_instruction_grp.GET_INSTR_INSTANCE_XML', FALSE);
                end if;

    WHEN OTHERS THEN
                ROLLBACK TO GET_INSTR_XML_GRP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
                END IF;

                FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_instruction_grp.GET_INSTR_INSTANCE_XML', FALSE);
                end if;

END GET_INSTR_INSTANCE_XML;

PROCEDURE CREATE_INSTANCE_FROM_DEFN
(
    P_API_VERSION           IN NUMBER,
    P_INIT_MSG_LIST         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_COMMIT                IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_VALIDATION_LEVEL      IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2,

    P_DEFINITION_ENTITY_NAME    IN VARCHAR2,
    P_DEFINITION_ENTITY_KEY     IN VARCHAR2,
    P_INSTANCE_ENTITY_NAME      IN VARCHAR2,
    P_INSTANCE_ENTITY_KEY       IN VARCHAR2,
    P_INSTRUCTION_TYPE          IN VARCHAR2,
    X_INSTRUCTION_SET_ID        OUT NOCOPY NUMBER

) IS

  l_api_name      CONSTANT VARCHAR2(30)   := 'CREATE_INSTANCE_FROM_DEFN';
  l_api_version   CONSTANT NUMBER         := 1.0;

BEGIN
     -- Standard Start of API savepoint
     SAVEPOINT  CREATE_INSTANCE_FROM_DEFN_GRP;

     -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,l_api_name,G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
     END IF;

     --  Initialize API return status to success
     X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

     GMO_INSTRUCTION_PVT.CREATE_INSTANCE_FROM_DEFN
     (
          P_DEFINITION_ENTITY_NAME => P_DEFINITION_ENTITY_NAME,
	  P_DEFINITION_ENTITY_KEY => P_DEFINITION_ENTITY_KEY,
	  P_INSTANCE_ENTITY_NAME => P_INSTANCE_ENTITY_NAME,
          P_INSTANCE_ENTITY_KEY => P_INSTANCE_ENTITY_KEY,
          P_INSTRUCTION_TYPE => P_INSTRUCTION_TYPE,
	  X_INSTRUCTION_SET_ID => X_INSTRUCTION_SET_ID,
	  X_RETURN_STATUS => X_RETURN_STATUS,
          X_MSG_COUNT => X_MSG_COUNT,
          X_MSG_DATA => X_MSG_DATA
     );

     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);

     IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT  ;
     END IF;

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO CREATE_INSTANCE_FROM_DEFN_GRP;
		x_return_status := FND_API.G_RET_STS_ERROR;

		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_instruction_grp.CREATE_INSTANCE_FROM_DEFN', FALSE);
                end if;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO CREATE_INSTANCE_FROM_DEFN_GRP;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_instruction_grp.CREATE_INSTANCE_FROM_DEFN', FALSE);
                end if;

    WHEN OTHERS THEN
                ROLLBACK TO CREATE_INSTANCE_FROM_DEFN_GRP;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
                END IF;

                FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_instruction_grp.CREATE_INSTANCE_FROM_DEFN', FALSE);
                end if;

END CREATE_INSTANCE_FROM_DEFN;


PROCEDURE CREATE_INSTANCE_FROM_INSTANCE
(

    P_API_VERSION           IN NUMBER,
    P_INIT_MSG_LIST         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_COMMIT                IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_VALIDATION_LEVEL      IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2,

    P_SOURCE_ENTITY_NAME        IN VARCHAR2,
    P_SOURCE_ENTITY_KEY         IN VARCHAR2,
    P_TARGET_ENTITY_KEY         IN VARCHAR2,
    P_INSTRUCTION_TYPE          IN VARCHAR2,
    X_INSTRUCTION_SET_ID        OUT NOCOPY NUMBER

) IS

  l_api_name      CONSTANT VARCHAR2(30)   := 'CREATE_INSTANCE_FROM_INSTANCE';
  l_api_version   CONSTANT NUMBER         := 1.0;

BEGIN
     SAVEPOINT  CREATE_INST_FRM_INST_SV;
     -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,l_api_name,G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
     END IF;

     --  Initialize API return status to success
     X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

     GMO_INSTRUCTION_PVT.CREATE_INSTANCE_FROM_INSTANCE
     (
         P_SOURCE_ENTITY_NAME => P_SOURCE_ENTITY_NAME,
	 P_SOURCE_ENTITY_KEY => P_SOURCE_ENTITY_KEY,
         P_TARGET_ENTITY_KEY => P_TARGET_ENTITY_KEY,
         P_INSTRUCTION_TYPE => P_INSTRUCTION_TYPE,
	 X_INSTRUCTION_SET_ID => X_INSTRUCTION_SET_ID,
	 X_RETURN_STATUS => X_RETURN_STATUS,
         X_MSG_COUNT => X_MSG_COUNT,
         X_MSG_DATA => X_MSG_DATA
     );

     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_ERROR;
     ELSE
         IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT  ;
         END IF;
     END IF;

     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO CREATE_INST_FRM_INST_SV;
                x_return_status := FND_API.G_RET_STS_ERROR;

		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_instruction_grp.CREATE_INSTANCE_FROM_INSTANCE', FALSE);
                end if;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO CREATE_INST_FRM_INST_SV;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_instruction_grp.CREATE_INSTANCE_FROM_INSTANCE', FALSE);
                end if;

    WHEN OTHERS THEN
                ROLLBACK TO CREATE_INST_FRM_INST_SV;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
                END IF;

                FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_instruction_grp.CREATE_INSTANCE_FROM_INSTANCE', FALSE);
                end if;

END CREATE_INSTANCE_FROM_INSTANCE;

PROCEDURE SEND_TASK_ACKN
(
    P_API_VERSION           IN NUMBER,
    P_INIT_MSG_LIST         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_VALIDATION_LEVEL      IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2,

    P_INSTRUCTION_ID IN NUMBER,
    P_INSTRUCTION_PROCESS_ID IN NUMBER,
    P_ENTITY_KEY IN VARCHAR2 DEFAULT NULL,
    P_TASK_ERECORD_ID  IN FND_TABLE_OF_VARCHAR2_255,
    P_TASK_IDENTIFIER IN FND_TABLE_OF_VARCHAR2_255,
    P_TASK_VALUE IN FND_TABLE_OF_VARCHAR2_255,
    P_DISABLE_TASK IN VARCHAR2 DEFAULT 'N'
)
IS PRAGMA AUTONOMOUS_TRANSACTION;

  l_api_name      CONSTANT VARCHAR2(30)   := 'SEND_TASK_ACKN';
  l_api_version   CONSTANT NUMBER         := 1.0;

BEGIN

     -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,l_api_name,G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
     END IF;

     --  Initialize API return status to success
     X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

     -- Call Private API
     GMO_INSTRUCTION_PVT.SEND_TASK_ACKN
     (
          P_INSTRUCTION_ID => P_INSTRUCTION_ID,
          P_INSTRUCTION_PROCESS_ID => P_INSTRUCTION_PROCESS_ID,
          P_ENTITY_KEY => P_ENTITY_KEY,
          P_TASK_ERECORD_ID => P_TASK_ERECORD_ID,
          P_TASK_IDENTIFIER => P_TASK_IDENTIFIER,
          P_TASK_VALUE => P_TASK_VALUE,
          P_DISABLE_TASK => P_DISABLE_TASK,
          X_RETURN_STATUS => X_RETURN_STATUS,
          X_MSG_COUNT => X_MSG_COUNT,
          X_MSG_DATA => X_MSG_DATA
     );

     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_ERROR;
     ELSE
            COMMIT;
     END IF;

     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK;
                x_return_status := FND_API.G_RET_STS_ERROR;

		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_instruction_grp.SEND_TASK_ACKN', FALSE);
                end if;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_instruction_grp.SEND_TASK_ACKN', FALSE);
                end if;

    WHEN OTHERS THEN
                ROLLBACK;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
                END IF;

                FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_instruction_grp.SEND_TASK_ACKN', FALSE);
                end if;

END SEND_TASK_ACKN;

PROCEDURE NULLIFY_INSTR_FOR_ENTITY
(

    P_API_VERSION           IN NUMBER,
    P_INIT_MSG_LIST         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_VALIDATION_LEVEL      IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2,

    P_ENTITY_NAME IN VARCHAR2,
    P_ENTITY_KEY IN VARCHAR2,
    P_INSTRUCTION_TYPE IN VARCHAR2

)
IS PRAGMA AUTONOMOUS_TRANSACTION;

  l_api_name      CONSTANT VARCHAR2(30)   := 'NULLIFY_INSTR_FOR_ENTITY';
  l_api_version   CONSTANT NUMBER         := 1.0;

BEGIN

     -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,l_api_name,G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
     END IF;

     --  Initialize API return status to success
     X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

     -- Call Private API
     GMO_INSTRUCTION_PVT.NULLIFY_INSTR_FOR_ENTITY
     (
         P_ENTITY_NAME => P_ENTITY_NAME,
	 P_ENTITY_KEY => P_ENTITY_KEY,
         P_INSTRUCTION_TYPE => P_INSTRUCTION_TYPE,
         X_RETURN_STATUS => X_RETURN_STATUS,
         X_MSG_COUNT => X_MSG_COUNT,
         X_MSG_DATA => X_MSG_DATA
     );

     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_ERROR;
     ELSE
            COMMIT;
     END IF;

     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK;
                x_return_status := FND_API.G_RET_STS_ERROR;

		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_instruction_grp.NULLIFY_INSTR_FOR_ENTITY', FALSE);
                end if;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_instruction_grp.NULLIFY_INSTR_FOR_ENTITY', FALSE);
                end if;

    WHEN OTHERS THEN
                ROLLBACK;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
                END IF;

                FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_instruction_grp.NULLIFY_INSTR_FOR_ENTITY', FALSE);
                end if;

END NULLIFY_INSTR_FOR_ENTITY;


PROCEDURE GET_TASK_PARAMETER
(
  P_API_VERSION           IN NUMBER,
  P_INIT_MSG_LIST         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  P_VALIDATION_LEVEL      IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
  X_MSG_COUNT             OUT NOCOPY NUMBER,
  X_MSG_DATA              OUT NOCOPY VARCHAR2,

  P_INSTRUCTION_PROCESS_ID IN NUMBER,
  P_ATTRIBUTE_NAME IN VARCHAR2,
  X_ATTRIBUTE_VALUE OUT NOCOPY VARCHAR2

)
IS
   l_api_name      CONSTANT VARCHAR2(30)   := 'GET_TASK_PARAMETER';
   l_api_version   CONSTANT NUMBER         := 1.0;
   L_TASK_PARAM_VALUE VARCHAR2(1000);

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT  GET_TASK_PARAMETER_GRP;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,l_api_name,G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

     --  Initialize API return status to success
     X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

     -- Call the Private API to get the task value
     L_TASK_PARAM_VALUE := GMO_INSTRUCTION_PVT.GET_TASK_PARAMETER( P_INSTRUCTION_PROCESS_ID,
                                                                   P_ATTRIBUTE_NAME
								  );
     X_ATTRIBUTE_VALUE := L_TASK_PARAM_VALUE;
     X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO GET_TASK_PARAMETER_GRP;
                x_return_status := FND_API.G_RET_STS_ERROR;

		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_instruction_grp.GET_TASK_PARAMETER', FALSE);
                end if;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO GET_TASK_PARAMETER_GRP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_instruction_grp.GET_TASK_PARAMETER', FALSE);
                end if;

    WHEN OTHERS THEN
                ROLLBACK TO GET_TASK_PARAMETER_GRP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
                END IF;

                FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_instruction_grp.GET_TASK_PARAMETER', FALSE);
                end if;

END GET_TASK_PARAMETER;

--Bug 5383022: start

-- Start of comments
-- API name             : is_task_attribute_used
-- Type                 : Group API
-- Function             : This procedure is used to check if the task attribute is used
-- Pre-reqs             : None
--
-- IN                   : P_API_VERSION           API Version
--                        P_INIT_MSG_LIST         Initialize message list default = FALSE
--                        P_VALIDATION_LEVEL      Default validation level = FULL
--                        P_INSTRUCTION_PROCESS_ID - The instruction process ID
--                        p_attribute_name - attribute name
--                        p_attribute_key - attribute key
-- OUT                  : x_used_flag - used flag
--                        x_return_status - return status
--                        x_msg_count - message count
--                        x_msg_data - message data
--End of comments

procedure is_task_attribute_used
(
	P_API_VERSION		IN NUMBER,
	P_INIT_MSG_LIST         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
	P_VALIDATION_LEVEL      IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
	X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
	X_MSG_COUNT             OUT NOCOPY NUMBER,
	X_MSG_DATA              OUT NOCOPY VARCHAR2,

	p_instruction_process_id IN number,
	p_attribute_name IN varchar2,
	p_attribute_key IN varchar2,
	x_used_flag OUT NOCOPY varchar2
)

IS
   l_api_name      CONSTANT VARCHAR2(30)   := 'IS_TASK_ATTRIBUTE_USED';
   l_api_version   CONSTANT NUMBER         := 1.0;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT  IS_TASK_ATTRIBUTE_USED_GRP;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,l_api_name,G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

     --  Initialize API return status to success
     X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

     -- Call the Private API to get the task value
     GMO_INSTRUCTION_PVT.is_task_attribute_used(
	P_INSTRUCTION_PROCESS_ID => p_instruction_process_id,
	p_attribute_name => p_attribute_name,
	p_attribute_key => p_attribute_key,
	x_used_flag => x_used_flag,
	X_RETURN_STATUS => X_RETURN_STATUS,
	X_MSG_COUNT => X_MSG_COUNT,
	X_MSG_DATA => X_MSG_DATA
     );

     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO IS_TASK_ATTRIBUTE_USED_GRP;
                x_return_status := FND_API.G_RET_STS_ERROR;

		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_instruction_grp.IS_TASK_ATTRIBUTE_USED', FALSE);
                end if;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO IS_TASK_ATTRIBUTE_USED_GRP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_instruction_grp.IS_TASK_ATTRIBUTE_USED', FALSE);
                end if;

    WHEN OTHERS THEN
                ROLLBACK TO IS_TASK_ATTRIBUTE_USED_GRP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
                END IF;

                FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_instruction_grp.IS_TASK_ATTRIBUTE_USED', FALSE);
                end if;

END IS_TASK_ATTRIBUTE_USED;

--Bug 5383022: end

END GMO_INSTRUCTION_GRP;

/
