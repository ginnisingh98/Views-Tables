--------------------------------------------------------
--  DDL for Package Body ASO_APR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_APR_PUB" AS
  /*  $Header: asopaprb.pls 120.1 2005/06/29 12:36:23 appldev ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30):= 'ASO_APR_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asopaprb.pls';


  PROCEDURE get_all_approvers (
    p_api_version_number        IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 := fnd_api.g_false,
    p_commit                    IN       VARCHAR2 := fnd_api.g_false,
    p_object_id                 IN       NUMBER,
    p_object_type               IN       VARCHAR2,
    p_application_id            IN       NUMBER,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_approvers_list            OUT NOCOPY /* file.sql.39 change */       approvers_list_tbl_type,
    x_rules_list                OUT NOCOPY /* file.sql.39 change */       rules_list_tbl_type
  ) IS

 l_api_name varchar2(240):= 'GET_ALL_APPROVERS';

 BEGIN

    aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

      -- Standard Start of API savepoint
      SAVEPOINT  GET_ALL_APPROVERS_PUB;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'BEGIN get_all_approvers in ASO_APR_PUB package ',
        1,
        'N'
      );
    END IF;

    -- calling the hooks

    IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'C')) THEN

    ASO_APR_CUHK.get_all_approvers_PRE (
    p_object_id                 =>  p_object_id,
    p_object_type               => p_object_type,
    p_application_id            => p_application_id,
    x_return_status             => x_return_status,
    x_msg_count                 => x_msg_count,
    x_msg_data                  => x_msg_data );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
            FND_MESSAGE.Set_Token('API', 'ASO_APR_CUHK.get_all_approvers_PRE', FALSE);
            FND_MSG_PUB.ADD;
             END IF;
                 IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;
          END IF;
      END IF; -- customer hook

      -- vertical hook
        IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'V')) THEN

          ASO_APR_VUHK.get_all_approvers_PRE (
              p_object_id                 =>  p_object_id,
              p_object_type               => p_object_type,
              p_application_id            => p_application_id,
              x_return_status             => x_return_status,
              x_msg_count                 => x_msg_count,
              x_msg_data                  => x_msg_data );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
            FND_MESSAGE.Set_Token('API', 'ASO_APR_VUHK.get_all_approvers_PRE', FALSE);
            FND_MSG_PUB.ADD;
             END IF;
                 IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;
          END IF;
      END IF; -- vertical hook

    aso_apr_int.get_all_approvers (
      p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_object_id,
      p_object_type,
      p_application_id,
      fnd_api.g_true,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_approvers_list,
      x_rules_list
    );
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'After caling  get_all_approvers in ASO_APR_INT package ',
        1,
        'N'
      );
    END IF;

    -- Check return status from the above procedure call
   IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

    -- Calling the POST hooks

     IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'C')) THEN

          ASO_APR_CUHK.get_all_approvers_POST (
              p_object_id                 =>  p_object_id,
              p_object_type               => p_object_type,
              p_application_id            => p_application_id,
              x_return_status             => x_return_status,
              x_msg_count                 => x_msg_count,
              x_msg_data                  => x_msg_data );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
            FND_MESSAGE.Set_Token('API', 'ASO_APR_CUHK.get_all_approvers_POST', FALSE);
            FND_MSG_PUB.ADD;
             END IF;
                 IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;
          END IF;
      END IF; -- customer hook

       -- vertical hook
        IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'V')) THEN

          ASO_APR_VUHK.get_all_approvers_POST (
              p_object_id                 =>  p_object_id,
              p_object_type               => p_object_type,
              p_application_id            => p_application_id,
              x_return_status             => x_return_status,
              x_msg_count                 => x_msg_count,
              x_msg_data                  => x_msg_data );

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
            FND_MESSAGE.Set_Token('API', 'ASO_APR_VUHK.get_all_approvers_POST', FALSE);
            FND_MSG_PUB.ADD;
             END IF;
                 IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;
          END IF;
      END IF; -- vertical hook

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'END get_all_approvers in ASO_APR_PUB package ',
        1,
        'N'
      );
    END IF;

 EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
    ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

   WHEN OTHERS THEN
    ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

  END get_all_approvers;

  PROCEDURE start_approval_process (
    p_api_version_number        IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 := fnd_api.g_false,
    p_commit                    IN       VARCHAR2 := fnd_api.g_false,
    p_object_id                 IN       NUMBER,
    p_object_type               IN       VARCHAR2,
    p_application_id            IN       NUMBER,
    p_approver_sequence         IN       NUMBER := fnd_api.g_miss_num,
    p_requester_comments        IN       VARCHAR2,
    x_object_approval_id        OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_approval_instance_id      OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2
  ) IS

  l_api_name varchar2(240):= 'START_APPROVAL_PROCESS';

  BEGIN

       aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

   -- Standard Start of API savepoint
    	SAVEPOINT  START_APPROVAL_PROCESS_PUB;


    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'BEGIN start_approval_process in ASO_APR_PUB package ',
        1,
        'N'
      );
    END IF;

    -- calling the hooks

    IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'C')) THEN

       ASO_APR_CUHK.start_approval_process_PRE (
         p_object_id                 => p_object_id,
         p_object_type               => p_object_type,
         p_application_id            => p_application_id,
         p_approver_sequence         => p_approver_sequence,
         p_requester_comments        => p_requester_comments,
         x_return_status             => x_return_status,
         x_msg_count                 => x_msg_count,
         x_msg_data                  => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
            FND_MESSAGE.Set_Token('API', 'ASO_APR_CUHK.start_approval_process_PRE', FALSE);
            FND_MSG_PUB.ADD;
             END IF;
                 IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;
          END IF;
      END IF; -- customer hook

      -- vertical hook
        IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'V')) THEN

           ASO_APR_VUHK.start_approval_process_PRE (
             p_object_id                 => p_object_id,
             p_object_type               => p_object_type,
             p_application_id            => p_application_id,
             p_approver_sequence         => p_approver_sequence,
             p_requester_comments        => p_requester_comments,
             x_return_status             => x_return_status,
             x_msg_count                 => x_msg_count,
             x_msg_data                  => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
            FND_MESSAGE.Set_Token('API', 'ASO_APR_VUHK.start_approval_process_PRE', FALSE);
            FND_MSG_PUB.ADD;
             END IF;
                 IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;
          END IF;
      END IF; -- vertical hook

   aso_apr_int.start_approval_process (
      p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_object_id,
      p_object_type,
      p_application_id,
      p_approver_sequence,
      p_requester_comments,
      x_object_approval_id,
	 x_approval_instance_id,
      x_return_status,
      x_msg_count,
      x_msg_data
    );
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'AFTER calling  start_approval_process in ASO_APR_INT package ',
        1,
        'N'
      );
    END IF;


   -- Check return status from the above procedure call
   IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

    -- Calling the POST hooks

   IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'C')) THEN

      ASO_APR_CUHK.start_approval_process_POST (
         p_object_id                 => p_object_id,
         p_object_type               => p_object_type,
         p_application_id            => p_application_id,
         p_approver_sequence         => p_approver_sequence,
         p_requester_comments        => p_requester_comments,
         x_return_status             => x_return_status,
         x_msg_count                 => x_msg_count,
         x_msg_data                  => x_msg_data);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
            FND_MESSAGE.Set_Token('API', 'ASO_APR_CUHK.start_approval_process_POST', FALSE);
            FND_MSG_PUB.ADD;
             END IF;
                 IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;
          END IF;
      END IF; -- customer hook

      -- vertical hook
     IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'V')) THEN

       ASO_APR_VUHK.start_approval_process_POST (
         p_object_id                 => p_object_id,
         p_object_type               => p_object_type,
         p_application_id            => p_application_id,
         p_approver_sequence         => p_approver_sequence,
         p_requester_comments        => p_requester_comments,
         x_return_status             => x_return_status,
         x_msg_count                 => x_msg_count,
         x_msg_data                  => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
            FND_MESSAGE.Set_Token('API', 'ASO_APR_VUHK.start_approval_process_POST', FALSE);
            FND_MSG_PUB.ADD;
             END IF;
                 IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;
          END IF;
      END IF; -- vertical hook

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'END start_approval_process in ASO_APR_PUB package ',
        1,
        'N'
      );
    END IF;


 EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

    WHEN OTHERS THEN
     ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

  END start_approval_process;

  PROCEDURE cancel_approval_process (
    p_api_version_number        IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2,
    p_commit                    IN       VARCHAR2,
    p_object_id                 IN       NUMBER,
    p_object_type               IN       VARCHAR2,
    p_application_id            IN       NUMBER,
    p_itemtype                  IN       VARCHAR2,
    p_object_approval_id        IN       NUMBER,
    p_user_id                   IN       NUMBER,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2
  ) IS
  BEGIN

       aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'BEGIN cancel_approval_process in ASO_APR_PUB package ',
        1,
        'N'
      );
    END IF;
    aso_apr_int.cancel_approval_process (
      p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_object_id,
      p_object_type,
      p_application_id,
      p_itemtype,
	 p_object_approval_id,
      p_user_id,
	 x_return_status,
      x_msg_count,
      x_msg_data
    );
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'END cancel_approval_process in ASO_APR_PUB package ',
        1,
        'N'
      );
    END IF;
  END cancel_approval_process;

  PROCEDURE skip_approver (
    p_api_version_number        IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 := fnd_api.g_false,
    p_commit                    IN       VARCHAR2 := fnd_api.g_false,
    p_object_id                 IN       NUMBER,
    p_object_type               IN       VARCHAR2,
    p_approver_id               IN       NUMBER,
    p_approval_instance_id      IN       NUMBER,
    p_application_id            IN       NUMBER,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2
  ) IS
  BEGIN

    aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'BEGIN  skip_approver in ASO_APR_PUB package ',
        1,
        'N'
      );
    END IF;
    aso_apr_int.skip_approver (
      p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_object_id,
      p_object_type,
      p_approver_id,
      p_approval_instance_id,
      p_application_id,
      x_return_status,
      x_msg_count,
      x_msg_data
    );
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'END skip_approver in ASO_APR_PUB package ',
        1,
        'N'
      );
    END IF;
  END skip_approver;

  PROCEDURE get_rule_details (
    p_api_version_number        IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit                    IN       VARCHAR2 DEFAULT fnd_api.g_false,
    p_object_approval_id        IN       NUMBER,
    x_rules_list                OUT NOCOPY /* file.sql.39 change */       aso_apr_pub.rules_list_tbl_type,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2)

   IS
   BEGIN

       aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'BEGIN get_rule_details in ASO_APR_PUB package ',
        1,
        'N'
      );
    END IF;

    aso_apr_int.get_rule_details (
    p_api_version_number,
    p_init_msg_list,
    p_commit,
    p_object_approval_id,
    x_rules_list,
    x_return_status,
    x_msg_count,
    x_msg_data);

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'END get_rule_details in ASO_APR_PUB package ',
        1,
        'N'
      );
    END IF;


   END get_rule_details;

  PROCEDURE start_approval_workflow (
    p_api_version_number        IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit                    IN       VARCHAR2 DEFAULT fnd_api.g_false,
    p_object_approval_id        IN       NUMBER,
    p_itemtype                  IN       VARCHAR2,
    p_sender_name               IN       VARCHAR2,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2)
   IS
   BEGIN

       aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'BEGIN start_approval_workflow in ASO_APR_PUB package ',
        1,
        'N'
      );
    END IF;

    aso_apr_int.start_approval_workflow (
    p_api_version_number,
    p_init_msg_list,
    p_commit,
    p_object_approval_id,
    p_itemtype,
    p_sender_name,
    x_return_status,
    x_msg_count,
    x_msg_data);

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'END start_approval_workflow in ASO_APR_PUB package ',
        1,
        'N'
      );
    END IF;


   END start_approval_workflow;


END aso_apr_pub;

/
