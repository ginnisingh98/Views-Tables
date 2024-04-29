--------------------------------------------------------
--  DDL for Package Body ASO_SECURITY_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_SECURITY_INT" AS
/* $Header: asoisecb.pls 120.4 2006/04/04 16:38:16 skulkarn ship $ */

-- Start of Comments
-- Package name : ASO_SECURITY_INT
-- Purpose      : API methods for implementing Quoting Security
-- End of Comments


G_PKG_NAME     CONSTANT    VARCHAR2(30)    := 'ASO_SECURITY_INT';
G_FILE_NAME    CONSTANT    VARCHAR2(12)    := 'asoisecb.pls';



FUNCTION Get_Quote_Access
(
    P_RESOURCE_ID                IN   NUMBER,
    P_QUOTE_NUMBER               IN   NUMBER
) RETURN VARCHAR2
IS

    CURSOR C_direct_access (l_quote_number NUMBER, l_resource_id NUMBER) IS
    SELECT update_access_flag
      FROM ASO_QUOTE_ACCESSES
     WHERE quote_number = l_quote_number
       AND resource_id = l_resource_id;

    CURSOR C_manager_access (l_resource_id NUMBER, l_quote_number NUMBER) IS
    SELECT ACC.ACCESS_ID,
           ACC.UPDATE_ACCESS_FLAG
      FROM JTF_RS_REP_MANAGERS MGR,
           JTF_RS_GROUP_USAGES UGS,
           ASO_QUOTE_ACCESSES  ACC
     WHERE UGS.USAGE = 'SALES'
       AND UGS.GROUP_ID = MGR.GROUP_ID
       AND MGR.HIERARCHY_TYPE IN ('MGR_TO_MGR', 'MGR_TO_REP')
       AND SYSDATE BETWEEN MGR.START_DATE_ACTIVE AND NVL(MGR.END_DATE_ACTIVE, SYSDATE)
       AND ACC.RESOURCE_ID = MGR.RESOURCE_ID
       AND NVL(ACC.RESOURCE_GRP_ID, MGR.GROUP_ID) = MGR.GROUP_ID
       AND MGR.PARENT_RESOURCE_ID = l_resource_id
       AND ACC.QUOTE_NUMBER = l_quote_number;

    l_access_level    VARCHAR2(10);
    l_profile_access  VARCHAR2(1);

BEGIN


    aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');


      -- API body
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('ASO_SECURITY_INT: ****** Start of Get_Quote_Access API ******', 1, 'Y');
    END IF;
    l_access_level   := 'NONE';
    l_profile_access := 'N';

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('ASO_SECURITY_INT: Get_Quote_Access: P_RESOURCE_ID:  ' || P_RESOURCE_ID, 1, 'Y');
    aso_debug_pub.add('ASO_SECURITY_INT: Get_Quote_Access: P_QUOTE_NUMBER: ' || P_QUOTE_NUMBER, 1, 'Y');
    END IF;

    FOR c_direct_access_rec IN C_direct_access(p_quote_number, p_resource_id) LOOP
        IF c_direct_access_rec.update_access_flag = 'Y' THEN

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('ASO_SECURITY_INT: Get_Quote_Access: resource has direct UPDATE access', 1, 'Y');
		  END IF;

            RETURN 'UPDATE';
        ELSE
            IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('ASO_SECURITY_INT: Get_Quote_Access: resource has direct READ access', 1, 'Y');
		  END IF;
            l_access_level := 'READ';
        END IF;
    END LOOP;

    IF FND_PROFILE.VALUE('ASO_API_MGR_ROLE_ACCESS') = 'UPDATE' THEN
        l_profile_access := 'Y';
    END IF;

    FOR c_manager_access_rec IN C_manager_access(p_resource_id, p_quote_number) LOOP
        IF aso_debug_pub.g_debug_flag = 'Y' THEN
	   aso_debug_pub.add('ASO_SECURITY_INT: Get_Quote_Access: resource is manager', 1, 'Y');
	   END IF;

        l_access_level := 'READ';
        IF l_profile_access = 'Y' OR c_manager_access_rec.UPDATE_ACCESS_FLAG = 'Y' THEN
            IF aso_debug_pub.g_debug_flag = 'Y' THEN
		  aso_debug_pub.add('ASO_SECURITY_INT: Get_Quote_Access: resource has profile UPDATE access OR subordinate of resource has direct UPDATE access', 1, 'Y');
            aso_debug_pub.add('ASO_SECURITY_INT: Get_Quote_Access: profile access:     ' || l_profile_access, 1, 'Y');
            aso_debug_pub.add('ASO_SECURITY_INT: Get_Quote_Access: subordinate access: ' || c_manager_access_rec.UPDATE_ACCESS_FLAG, 1, 'Y');
		  END IF;

            RETURN 'UPDATE';
        END IF;
    END LOOP;

    -- End of API body
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('ASO_SECURITY_INT: Get_Quote_Access: End of API body', 1, 'Y');
    END IF;
    RETURN l_access_level;

END Get_Quote_Access;




PROCEDURE Add_Resource
(
    P_INIT_MSG_LIST              IN      VARCHAR2     := FND_API.G_FALSE,
    P_COMMIT                     IN      VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Access_Tbl             IN      Qte_Access_Tbl_Type,
    p_call_from_oafwk_flag       IN      VARCHAR2,
    X_Qte_Access_Tbl             OUT NOCOPY /* file.sql.39 change */     Qte_Access_Tbl_Type,
    X_RETURN_STATUS              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
    X_msg_count                  OUT NOCOPY /* file.sql.39 change */     NUMBER,
    X_msg_data                   OUT NOCOPY /* file.sql.39 change */     VARCHAR2
)
IS

    L_API_NAME                   VARCHAR2(50) := 'Add_Resource';

    CURSOR C_existing_resource (l_quote_number NUMBER, l_resource_id NUMBER) IS
    SELECT access_id
      FROM ASO_QUOTE_ACCESSES
     WHERE quote_number = l_quote_number
       AND resource_id = l_resource_id;

    CURSOR C_resource (l_access_id NUMBER) IS
    SELECT quote_number,
           resource_id,
           resource_grp_id,
           update_access_flag
      FROM ASO_QUOTE_ACCESSES
     WHERE access_id = l_access_id;

    CURSOR C_primary_resource (l_quote_number NUMBER) IS
    SELECT resource_id,quote_header_id,
           resource_grp_id
      FROM ASO_QUOTE_HEADERS_ALL
     WHERE quote_number = l_quote_number
       AND max_version_flag = 'Y';

    cursor c_access_id_exist( p_access_id number) is
    select access_id
    from aso_quote_accesses
    where access_id = p_access_id;

	CURSOR Lock_check(p_qte_number Number)
	IS SELECT price_request_id FROM
	ASO_QUOTE_HEADERS_ALL where quote_number = p_qte_number
	AND max_version_flag = 'Y';

    l_quote_number              NUMBER;
    l_resource_id               NUMBER;
    l_resource_grp_id           NUMBER;
    l_update_access_flag        VARCHAR2(1);
    l_primary_resource_id       NUMBER;
    l_primary_resource_grp_id   NUMBER;
    l_access_id                 NUMBER;
    l_exist_access_id           NUMBER;

    G_USER_ID                   NUMBER          := FND_GLOBAL.USER_ID;
    G_LOGIN_ID                  NUMBER          := FND_GLOBAL.CONC_LOGIN_ID;
    l_qte_header_rec		  ASO_QUOTE_PUB.Qte_Header_Rec_Type:=ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec;
    l_x_status 			  VARCHAR2(1);
    l_qte_access_tbl            Qte_Access_Tbl_Type := p_qte_access_tbl;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT Add_Resource_INT;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('ASO_SECURITY_INT: ****** Start of Add_Resource API ******', 1, 'Y');
        aso_debug_pub.add('Add_Resource: p_call_from_oafwk_flag: ' || p_call_from_oafwk_flag);
        aso_debug_pub.add('Add_Resource: p_qte_access_tbl.count: ' || p_qte_access_tbl.count);
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.To_Boolean(p_init_msg_list) THEN
        FND_Msg_Pub.initialize;
    END IF;

    -- API body
    X_Qte_Access_Tbl            := l_qte_access_tbl;

    FOR i IN 1..l_qte_access_tbl.count LOOP

        l_quote_number              := FND_API.G_MISS_NUM;
        l_resource_id               := FND_API.G_MISS_NUM;
        l_resource_grp_id           := FND_API.G_MISS_NUM;
        l_update_access_flag        := FND_API.G_MISS_CHAR;
        l_primary_resource_id       := FND_API.G_MISS_NUM;
        l_primary_resource_grp_id   := FND_API.G_MISS_NUM;
        l_access_id                 := FND_API.G_MISS_NUM;


	   If ((l_qte_access_tbl(i).batch_price_flag <> fnd_api.g_false) or
            (l_qte_access_tbl(i).batch_price_flag = fnd_api.g_miss_char)) then

	       FOR l_lock_rec IN Lock_check(l_qte_access_tbl(i).quote_number) LOOP

              IF l_lock_rec.price_request_id IS NOT NULL THEN

                   if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                         FND_MESSAGE.Set_Name('ASO', 'ASO_CONC_REQUEST_RUNNING');
                         FND_MSG_PUB.ADD;
                   end if;

                   raise fnd_api.g_exc_error;

              END IF;

	       END LOOP;

        end if;

        IF l_qte_access_tbl(i).access_id IS NOT NULL AND l_qte_access_tbl(i).access_id <> FND_API.G_MISS_NUM THEN

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('Add_Resource: LOOP for access_id: ' || l_qte_access_tbl(i).access_id);
		  END IF;

		  if (nvl(p_call_from_oafwk_flag, 'N')  =  fnd_api.g_false)
		     OR ((nvl(p_call_from_oafwk_flag, 'N') = fnd_api.g_true) and (l_qte_access_tbl(i).operation_code = 'UPDATE'))  then

                open  c_access_id_exist(l_qte_access_tbl(i).access_id);
                fetch c_access_id_exist into l_qte_access_tbl(i).access_id;

                if c_access_id_exist%notfound then

                     close c_access_id_exist;

                     x_return_status := fnd_api.g_ret_sts_error;

                     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                          FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                          FND_MESSAGE.Set_token('COLUMN', 'access_id');
                          FND_MESSAGE.Set_token('VALUE',  l_qte_access_tbl(i).access_id);
                          FND_MSG_PUB.Add;
                     END IF;

                     RAISE FND_API.G_EXC_ERROR;

                end if;

                close c_access_id_exist;

		  end if;

        ELSE

            IF l_qte_access_tbl(i).quote_number IS NOT NULL AND l_qte_access_tbl(i).quote_number <> FND_API.G_MISS_NUM THEN

                IF l_qte_access_tbl(i).resource_id IS NOT NULL AND l_qte_access_tbl(i).resource_id <> FND_API.G_MISS_NUM THEN

				IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('ASO_SECURITY_INT: Add_Resource: LOOP for resource_id:  ' || l_qte_access_tbl(i).resource_id, 1, 'Y');
                        aso_debug_pub.add('ASO_SECURITY_INT: Add_Resource: LOOP for quote_number: ' || l_qte_access_tbl(i).quote_number, 1, 'Y');
				END IF;

                    FOR l_access_rec IN C_existing_resource(l_qte_access_tbl(i).quote_number, l_qte_access_tbl(i).resource_id) LOOP
                        l_qte_access_tbl(i).access_id := l_access_rec.access_id;
				    l_qte_access_tbl(i).operation_code := 'UPDATE';
                    END LOOP;

                END IF;
            END IF;
        END IF;

	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('ASO_SECURITY_INT: Add_Resource: l_access_id: ' || l_access_id, 1, 'Y');
	   END IF;

	   IF nvl(p_call_from_oafwk_flag, 'N')  =  fnd_api.g_false THEN

            IF ((l_qte_access_tbl(i).access_id is null) OR (l_qte_access_tbl(i).access_id = fnd_api.g_miss_num)) THEN

	            l_qte_access_tbl(i).operation_code := 'CREATE';
            ELSE
	            l_qte_access_tbl(i).operation_code := 'UPDATE';
            END IF;

        END IF;

	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('ASO_SECURITY_INT: Add_Resource: l_qte_access_tbl(i).operation_code: ' || l_qte_access_tbl(i).operation_code, 1, 'Y');
	   END IF;

        IF l_qte_access_tbl(i).operation_code = 'CREATE' THEN

            -- 4535602
            OPEN C_existing_resource(l_qte_access_tbl(i).quote_number, l_qte_access_tbl(i).resource_id);
            FETCH C_existing_resource INTO l_exist_access_id;
            IF C_existing_resource%FOUND THEN
                x_return_status := fnd_api.g_ret_sts_error;

	           IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('ASO_SECURITY_INT: Add_Resource: duplicate resource: ' || l_exist_access_id, 1, 'Y');
	           END IF;
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                     FND_MESSAGE.Set_Name('ASO', 'ASO_DUPLICATE_RESOURCE_ID');
                     FND_MSG_PUB.Add;
                END IF;

                CLOSE C_existing_resource;

                RAISE FND_API.G_EXC_ERROR;
            END IF;
            CLOSE C_existing_resource;
            -- 4535602

            l_quote_number := l_qte_access_tbl(i).QUOTE_NUMBER;

	       IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('ASO_SECURITY_INT: Add_Resource: before Insert_Row: counter:     ' || i, 1, 'Y');
            END IF;

            ASO_QUOTE_ACCESSES_PKG.Insert_Row(
                px_ACCESS_ID             => l_qte_access_tbl(i).access_id,
                p_QUOTE_NUMBER           => l_qte_access_tbl(i).QUOTE_NUMBER,
                p_RESOURCE_ID            => l_qte_access_tbl(i).RESOURCE_ID,
                p_RESOURCE_GRP_ID        => l_qte_access_tbl(i).RESOURCE_GRP_ID,
                p_CREATED_BY             => G_USER_ID,
                p_CREATION_DATE          => SYSDATE,
                p_LAST_UPDATED_BY        => G_USER_ID,
                p_LAST_UPDATE_LOGIN      => G_LOGIN_ID,
                p_LAST_UPDATE_DATE       => SYSDATE,
                p_REQUEST_ID             => l_qte_access_tbl(i).REQUEST_ID,
                p_PROGRAM_APPLICATION_ID => l_qte_access_tbl(i).PROGRAM_APPLICATION_ID,
                p_PROGRAM_ID             => l_qte_access_tbl(i).PROGRAM_ID,
                p_PROGRAM_UPDATE_DATE    => l_qte_access_tbl(i).PROGRAM_UPDATE_DATE,
                p_KEEP_FLAG              => l_qte_access_tbl(i).KEEP_FLAG,
                p_UPDATE_ACCESS_FLAG     => l_qte_access_tbl(i).UPDATE_ACCESS_FLAG,
                p_CREATED_BY_TAP_FLAG    => l_qte_access_tbl(i).CREATED_BY_TAP_FLAG,
                p_TERRITORY_ID           => l_qte_access_tbl(i).TERRITORY_ID,
                p_TERRITORY_SOURCE_FLAG  => 'N',
                p_ROLE_ID                => l_qte_access_tbl(i).ROLE_ID,
                p_ATTRIBUTE_CATEGORY     => l_qte_access_tbl(i).ATTRIBUTE_CATEGORY,
                p_ATTRIBUTE1             => l_qte_access_tbl(i).ATTRIBUTE1,
                p_ATTRIBUTE2             => l_qte_access_tbl(i).ATTRIBUTE2,
                p_ATTRIBUTE3             => l_qte_access_tbl(i).ATTRIBUTE3,
                p_ATTRIBUTE4             => l_qte_access_tbl(i).ATTRIBUTE4,
                p_ATTRIBUTE5             => l_qte_access_tbl(i).ATTRIBUTE5,
                p_ATTRIBUTE6             => l_qte_access_tbl(i).ATTRIBUTE6,
                p_ATTRIBUTE7             => l_qte_access_tbl(i).ATTRIBUTE7,
                p_ATTRIBUTE8             => l_qte_access_tbl(i).ATTRIBUTE8,
                p_ATTRIBUTE9             => l_qte_access_tbl(i).ATTRIBUTE9,
                p_ATTRIBUTE10            => l_qte_access_tbl(i).ATTRIBUTE10,
                p_ATTRIBUTE11            => l_qte_access_tbl(i).ATTRIBUTE11,
                p_ATTRIBUTE12            => l_qte_access_tbl(i).ATTRIBUTE12,
                p_ATTRIBUTE13            => l_qte_access_tbl(i).ATTRIBUTE13,
                p_ATTRIBUTE14            => l_qte_access_tbl(i).ATTRIBUTE14,
                p_ATTRIBUTE15            => l_qte_access_tbl(i).ATTRIBUTE15,
			 p_ATTRIBUTE16            => l_qte_access_tbl(i).ATTRIBUTE16,
			 p_ATTRIBUTE17            => l_qte_access_tbl(i).ATTRIBUTE17,
			 p_ATTRIBUTE18            => l_qte_access_tbl(i).ATTRIBUTE18,
			 p_ATTRIBUTE19            => l_qte_access_tbl(i).ATTRIBUTE19,
			 p_ATTRIBUTE20            => l_qte_access_tbl(i).ATTRIBUTE20,
			 p_OBJECT_VERSION_NUMBER  => l_qte_access_tbl(i).OBJECT_VERSION_NUMBER
            );

            X_Qte_Access_Tbl(i).access_id := l_qte_access_tbl(i).access_id;

		  IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('ASO_SECURITY_INT: Add_Resource:  after Insert_Row: x_qte_access_tbl('||i||').access_id: ' || x_qte_access_tbl(i).access_id, 1, 'Y');
		  END IF;

        ELSIF l_qte_access_tbl(i).operation_code = 'UPDATE' THEN

		  IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('ASO_SECURITY_INT: Add_Resource: before Update_Row: counter:     ' || i, 1, 'Y');
		  END IF;

            ASO_QUOTE_ACCESSES_PKG.Update_Row(
                p_ACCESS_ID              => l_qte_access_tbl(i).access_id,
                p_QUOTE_NUMBER           => l_qte_access_tbl(i).QUOTE_NUMBER,
                p_RESOURCE_ID            => l_qte_access_tbl(i).RESOURCE_ID,
                p_RESOURCE_GRP_ID        => l_qte_access_tbl(i).RESOURCE_GRP_ID,
                p_CREATED_BY             => G_USER_ID,
                p_CREATION_DATE          => fnd_api.g_miss_date,
                p_LAST_UPDATED_BY        => G_USER_ID,
                p_LAST_UPDATE_LOGIN      => G_LOGIN_ID,
                p_LAST_UPDATE_DATE       => SYSDATE,
                p_REQUEST_ID             => l_qte_access_tbl(i).REQUEST_ID,
                p_PROGRAM_APPLICATION_ID => l_qte_access_tbl(i).PROGRAM_APPLICATION_ID,
                p_PROGRAM_ID             => l_qte_access_tbl(i).PROGRAM_ID,
                p_PROGRAM_UPDATE_DATE    => l_qte_access_tbl(i).PROGRAM_UPDATE_DATE,
                p_KEEP_FLAG              => l_qte_access_tbl(i).KEEP_FLAG,
                p_UPDATE_ACCESS_FLAG     => l_qte_access_tbl(i).UPDATE_ACCESS_FLAG,
                p_CREATED_BY_TAP_FLAG    => l_qte_access_tbl(i).CREATED_BY_TAP_FLAG,
                p_TERRITORY_ID           => l_qte_access_tbl(i).TERRITORY_ID,
                p_TERRITORY_SOURCE_FLAG  => l_qte_access_tbl(i).TERRITORY_SOURCE_FLAG,
                p_ROLE_ID                => l_qte_access_tbl(i).ROLE_ID,
                p_ATTRIBUTE_CATEGORY     => l_qte_access_tbl(i).ATTRIBUTE_CATEGORY,
                p_ATTRIBUTE1             => l_qte_access_tbl(i).ATTRIBUTE1,
                p_ATTRIBUTE2             => l_qte_access_tbl(i).ATTRIBUTE2,
                p_ATTRIBUTE3             => l_qte_access_tbl(i).ATTRIBUTE3,
                p_ATTRIBUTE4             => l_qte_access_tbl(i).ATTRIBUTE4,
                p_ATTRIBUTE5             => l_qte_access_tbl(i).ATTRIBUTE5,
                p_ATTRIBUTE6             => l_qte_access_tbl(i).ATTRIBUTE6,
                p_ATTRIBUTE7             => l_qte_access_tbl(i).ATTRIBUTE7,
                p_ATTRIBUTE8             => l_qte_access_tbl(i).ATTRIBUTE8,
                p_ATTRIBUTE9             => l_qte_access_tbl(i).ATTRIBUTE9,
                p_ATTRIBUTE10            => l_qte_access_tbl(i).ATTRIBUTE10,
                p_ATTRIBUTE11            => l_qte_access_tbl(i).ATTRIBUTE11,
                p_ATTRIBUTE12            => l_qte_access_tbl(i).ATTRIBUTE12,
                p_ATTRIBUTE13            => l_qte_access_tbl(i).ATTRIBUTE13,
                p_ATTRIBUTE14            => l_qte_access_tbl(i).ATTRIBUTE14,
                p_ATTRIBUTE15            => l_qte_access_tbl(i).ATTRIBUTE15,
                p_ATTRIBUTE16            => l_qte_access_tbl(i).ATTRIBUTE16,
                p_ATTRIBUTE17            => l_qte_access_tbl(i).ATTRIBUTE17,
                p_ATTRIBUTE18            => l_qte_access_tbl(i).ATTRIBUTE18,
                p_ATTRIBUTE19            => l_qte_access_tbl(i).ATTRIBUTE19,
                p_ATTRIBUTE20            => l_qte_access_tbl(i).ATTRIBUTE20,
			 p_OBJECT_VERSION_NUMBER  => l_qte_access_tbl(i).OBJECT_VERSION_NUMBER
            );

            X_Qte_Access_Tbl(i).access_id := l_qte_access_tbl(i).access_id;

		  IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('ASO_SECURITY_INT: Add_Resource:  after Update_Row: x_qte_access_tbl('||i||').access_id: ' || x_qte_access_tbl(i).access_id, 1, 'Y');
		  END IF;

            FOR l_resource_rec IN C_resource(l_qte_access_tbl(i).access_id) LOOP
                l_quote_number       := l_resource_rec.quote_number;
                l_resource_id        := l_resource_rec.resource_id;
                l_resource_grp_id    := l_resource_rec.resource_grp_id;
                l_update_access_flag := l_resource_rec.update_access_flag;

			 IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('ASO_SECURITY_INT: Add_Resource: *** C_resource LOOP variables ***', 1, 'Y');
                    aso_debug_pub.add('ASO_SECURITY_INT: Add_Resource: l_quote_number:            ' || l_quote_number, 1, 'Y');
                    aso_debug_pub.add('ASO_SECURITY_INT: Add_Resource: l_resource_id:             ' || l_resource_id, 1, 'Y');
                    aso_debug_pub.add('ASO_SECURITY_INT: Add_Resource: l_resource_grp_id:         ' || l_resource_grp_id, 1, 'Y');
                    aso_debug_pub.add('ASO_SECURITY_INT: Add_Resource: l_update_access_flag:      ' || l_update_access_flag, 1, 'Y');
			 END IF;
            END LOOP;

            FOR l_primary_resource_rec IN C_primary_resource(l_quote_number) LOOP
                l_primary_resource_id     := l_primary_resource_rec.resource_id;
                l_primary_resource_grp_id := l_primary_resource_rec.resource_grp_id;
			 l_qte_header_rec.quote_header_id := l_primary_resource_rec.quote_header_id;

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
			     aso_debug_pub.add('ASO_SECURITY_INT: Add_Resource: *** C_primary_resource LOOP variables ***', 1, 'Y');
                    aso_debug_pub.add('ASO_SECURITY_INT: Add_Resource: l_primary_resource_id:     ' || l_primary_resource_id, 1, 'Y');
                    aso_debug_pub.add('ASO_SECURITY_INT: Add_Resource: l_primary_resource_grp_id: ' || l_primary_resource_grp_id, 1, 'Y');
			 END IF;

            END LOOP;

            IF l_primary_resource_id = l_resource_id THEN
                IF l_update_access_flag <> 'Y' THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;

				IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('ASO_SECURITY_INT: Add_Resource: trying to set primary resource update_access_flag other than Y', 1, 'Y');
				END IF;
                    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                        FND_MESSAGE.Set_Name('ASO', 'ASO_SEC_ADD_INVALID_ACCESS');
                        FND_MSG_PUB.Add;
                    END IF;
                    RAISE FND_API.G_EXC_ERROR;
                ELSE
                    IF l_resource_grp_id IS NOT NULL AND l_resource_grp_id <> FND_API.G_MISS_NUM THEN
                        IF l_primary_resource_grp_id <> l_resource_grp_id THEN
					 IF aso_debug_pub.g_debug_flag = 'Y' THEN
                            aso_debug_pub.add('ASO_SECURITY_INT: Add_Resource: before update ASO_QUOTE_HEADERS_ALL', 1, 'Y');
                          END IF;

                          UPDATE ASO_QUOTE_HEADERS_ALL
                          SET resource_grp_id    = l_resource_grp_id,
                              last_update_date   =  sysdate,
                              last_updated_by    =  fnd_global.user_id,
                              last_update_login  =  fnd_global.conc_login_id
                          WHERE quote_number = l_quote_number
                          AND max_version_flag = 'Y';

                          IF SQL%ROWCOUNT = 0 THEN
					     IF aso_debug_pub.g_debug_flag = 'Y' THEN
                                  aso_debug_pub.add('ASO_SECURITY_INT: Add_Resource: inside update ASO_QUOTE_HEADERS_ALL: SQL%ROWCOUNT = 0', 1, 'Y');
						END IF;
                              x_return_status := FND_API.G_RET_STS_ERROR;
                              RAISE FND_API.G_EXC_ERROR;
                          END IF;

                          IF aso_debug_pub.g_debug_flag = 'Y' THEN
                              aso_debug_pub.add('ASO_SECURITY_INT: Add_Resource:  after update ASO_QUOTE_HEADERS_ALL', 1, 'Y');
					 END IF;

                        END IF;
                    END IF;
                END IF;
            END IF;

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('ASO_SECURITY_INT: Add_Resource: after Update_Row: x_qte_access_tbl('||i||').access_id:: ' || x_qte_access_tbl(i).access_id, 1, 'Y');
		  END IF;

        END IF;

    END LOOP;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('ASO_SECURITY_INT: End of Add_Resource: before update ASO_QUOTE_HEADERS_ALL', 1, 'Y');
        aso_debug_pub.add('ASO_SECURITY_INT: End of Add_Resource: l_quote_number: '||l_quote_number, 1, 'Y');
    END IF;

    UPDATE ASO_QUOTE_HEADERS_ALL
    SET last_update_date   =  sysdate,
        last_updated_by    =  fnd_global.user_id,
        last_update_login  =  fnd_global.conc_login_id
    WHERE quote_number = l_quote_number AND
		max_version_flag = 'Y';

    IF SQL%ROWCOUNT = 0 THEN
       IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('ASO_SECURITY_INT: End of Add_Resource: after update ASO_QUOTE_HEADERS_ALL: SQL%ROWCOUNT = 0', 1, 'Y');
       END IF;
       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Change START
    -- Release 12 TAP Changes
    -- Girish Sachdeva 8/30/2005
    -- Adding the call to insert record in the ASO_CHANGED_QUOTES

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
	aso_debug_pub.add('ASO_SECURITY_INT.Add_Resource : Calling ASO_UTILITY_PVT.UPDATE_CHANGED_QUOTES, quote number : ' || l_quote_number, 1, 'Y');
    END IF;

    -- Call to insert record in ASO_CHANGED_QUOTES
    ASO_UTILITY_PVT.UPDATE_CHANGED_QUOTES(l_quote_number);

    -- Change END

    -- End of API body
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('ASO_SECURITY_INT: Add_Resource: End of API body', 1, 'Y');
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_Msg_Pub.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count   => x_msg_count,
        p_data    => x_msg_data
    );

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_INT,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_INT,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );

        WHEN OTHERS THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_INT,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );

END Add_Resource;

PROCEDURE Add_Resource
(
    P_INIT_MSG_LIST              IN      VARCHAR2     := FND_API.G_FALSE,
    P_COMMIT                     IN      VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Access_Tbl             IN      Qte_Access_Tbl_Type,
    X_Qte_Access_Tbl             OUT NOCOPY /* file.sql.39 change */     Qte_Access_Tbl_Type,
    X_RETURN_STATUS              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
    X_msg_count                  OUT NOCOPY /* file.sql.39 change */     NUMBER,
    X_msg_data                   OUT NOCOPY /* file.sql.39 change */     VARCHAR2
)
IS

l_call_from_oafwk_flag   varchar2(1) := fnd_api.g_false;

Begin
    aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('ASO_SECURITY_INT: ****** Start of Add_Resource API not overloaded ******', 1, 'Y');
    END IF;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('ASO_SECURITY_INT: Before call to Add_Resource overloaded procedure', 1, 'Y');
    END IF;

    ASO_SECURITY_INT.Add_Resource(
            P_INIT_MSG_LIST              => P_INIT_MSG_LIST,
            P_COMMIT                     => P_COMMIT,
            P_Qte_Access_tbl             => p_qte_access_tbl,
		  p_call_from_oafwk_flag       => l_call_from_oafwk_flag,
            X_Qte_Access_tbl             => x_qte_access_tbl,
            X_RETURN_STATUS              => x_return_status,
            X_msg_count                  => X_msg_count,
            X_msg_data                   => X_msg_data );

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('ASO_SECURITY_INT: After call to Add_Resource overloaded procedure', 1, 'Y');
    END IF;

End Add_Resource;


PROCEDURE Delete_Resource
(
    P_INIT_MSG_LIST              IN      VARCHAR2     := FND_API.G_FALSE,
    P_COMMIT                     IN      VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Access_Tbl             IN      Qte_Access_Tbl_Type,
    x_return_status              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
    X_msg_count                  OUT NOCOPY /* file.sql.39 change */     NUMBER,
    X_msg_data                   OUT NOCOPY /* file.sql.39 change */     VARCHAR2
)
IS

    L_API_NAME                   VARCHAR2(50) := 'Delete_Resource';

    CURSOR C_existing_resource (l_quote_number NUMBER, l_resource_id NUMBER) IS
    SELECT access_id
      FROM ASO_QUOTE_ACCESSES
     WHERE quote_number = l_quote_number
       AND resource_id = l_resource_id;

    CURSOR C_resource (l_access_id NUMBER) IS
    SELECT quote_number,
           resource_id
      FROM ASO_QUOTE_ACCESSES
     WHERE access_id = l_access_id;

    CURSOR C_primary_resource (l_quote_number NUMBER) IS
    SELECT resource_id
      FROM ASO_QUOTE_HEADERS_ALL
     WHERE quote_number = l_quote_number
       AND max_version_flag = 'Y';

     CURSOR C_Lock_check(p_qte_number Number)
     IS SELECT price_request_id FROM
     ASO_QUOTE_HEADERS_ALL where quote_number = p_qte_number
     AND max_version_flag = 'Y';

     CURSOR C_Quote_num(p_access_id Number) IS
     SELECT quote_number FROM
     ASO_QUOTE_ACCESSES WHERE
     access_id = p_access_id;

    l_primary_resource_id  NUMBER;
    l_resource_id          NUMBER;
    l_quote_number         NUMBER;
    l_access_id            NUMBER;

BEGIN
     aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('ASO_SECURITY_INT: ****** Start of Delete_Resource API ******', 1, 'Y');
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT Delete_Resource_INT;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.To_Boolean(p_init_msg_list) THEN
        FND_Msg_Pub.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API body

    FOR i IN 1..P_Qte_Access_Tbl.count LOOP

        l_primary_resource_id  := FND_API.G_MISS_NUM;
        l_resource_id          := FND_API.G_MISS_NUM;
        l_quote_number         := FND_API.G_MISS_NUM;
        l_access_id            := FND_API.G_MISS_NUM;

        IF P_Qte_Access_Tbl(i).access_id IS NOT NULL AND P_Qte_Access_Tbl(i).access_id <> FND_API.G_MISS_NUM THEN
		  IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('ASO_SECURITY_INT: Delete_Resource: LOOP for access_id:    ' || P_Qte_Access_Tbl(i).access_id, 1, 'Y');
		  END IF;

            l_access_id := P_Qte_Access_Tbl(i).access_id;

            if ((p_qte_access_tbl(i).batch_price_flag <> fnd_api.g_false) or
                (p_qte_access_tbl(i).batch_price_flag = fnd_api.g_miss_char)) then

                 FOR l_quote_num_rec IN C_Quote_num(l_access_id) LOOP

                      FOR l_lock_rec IN C_lock_check(l_quote_num_rec.quote_number) LOOP

                          IF l_lock_rec.price_request_id IS NOT NULL THEN

                             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                                 FND_MESSAGE.Set_Name('ASO', 'ASO_CONC_REQUEST_RUNNING');
                                 FND_MSG_PUB.ADD;
                             END IF;

                             raise FND_API.G_EXC_ERROR;
                          END IF;

                      END LOOP;

                 END LOOP;

            end if;

        ELSE

            IF P_Qte_Access_Tbl(i).quote_number IS NOT NULL AND P_Qte_Access_Tbl(i).quote_number <> FND_API.G_MISS_NUM THEN
                IF P_Qte_Access_Tbl(i).resource_id IS NOT NULL AND P_Qte_Access_Tbl(i).resource_id <> FND_API.G_MISS_NUM THEN

                    if ((p_qte_access_tbl(i).batch_price_flag <> fnd_api.g_false) or
                        (p_qte_access_tbl(i).batch_price_flag = fnd_api.g_miss_char)) then

                         FOR l_lock_rec IN C_lock_check(P_Qte_Access_Tbl(i).quote_number) LOOP

                           IF l_lock_rec.price_request_id IS NOT NULL THEN

                               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                                    FND_MESSAGE.Set_Name('ASO', 'ASO_CONC_REQUEST_RUNNING');
                                    FND_MSG_PUB.ADD;
                               END IF;

                               raise FND_API.G_EXC_ERROR;

                           END IF;

                         END LOOP;

                    end if;

				IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('ASO_SECURITY_INT: Delete_Resource: LOOP for resource_id:  ' || P_Qte_Access_Tbl(i).resource_id, 1, 'Y');
                    aso_debug_pub.add('ASO_SECURITY_INT: Delete_Resource: LOOP for quote_number: ' || P_Qte_Access_Tbl(i).quote_number, 1, 'Y');
				END IF;

                    FOR l_access_rec IN C_existing_resource(P_Qte_Access_Tbl(i).quote_number, P_Qte_Access_Tbl(i).resource_id) LOOP
                        l_access_id := l_access_rec.access_id;
                    END LOOP;

                END IF;
            END IF;
        END IF;

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('ASO_SECURITY_INT: Delete_Resource: count: ' || P_Qte_Access_Tbl.count);
	   END IF;

        IF l_access_id IS NOT NULL AND l_access_id <> FND_API.G_MISS_NUM THEN

            FOR l_resource_rec IN C_resource(l_access_id) LOOP
                l_quote_number := l_resource_rec.quote_number;
                l_resource_id  := l_resource_rec.resource_id;

			 IF aso_debug_pub.g_debug_flag = 'Y' THEN
                  aso_debug_pub.add('ASO_SECURITY_INT: Delete_Resource: *** C_resource LOOP variables ***');
                  aso_debug_pub.add('ASO_SECURITY_INT: Delete_Resource: l_quote_number: ' || l_quote_number);
                  aso_debug_pub.add('ASO_SECURITY_INT: Delete_Resource: l_resource_id:  ' || l_resource_id);
			 END IF;
            END LOOP;

            IF l_quote_number IS NOT NULL AND l_quote_number <> FND_API.G_MISS_NUM THEN

                FOR l_primary_resource_rec IN C_primary_resource(l_quote_number) LOOP
                    l_primary_resource_id := l_primary_resource_rec.resource_id;

				IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('Delete_Resource: *** C_primary_resource LOOP variables ***');
                    aso_debug_pub.add('Delete_Resource: l_primary_resource_id: ' || l_primary_resource_id);
				END IF;
                END LOOP;

                IF l_primary_resource_id = l_resource_id THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;

				IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('ASO_SECURITY_INT: Delete_Resource: trying to delete primary salesrep', 1, 'Y');
				END IF;

                    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                        FND_MESSAGE.Set_Name('ASO', 'ASO_SEC_DELETE_PRIMARY_RES');
                        FND_MSG_PUB.Add;
                    END IF;
                    RAISE FND_API.G_EXC_ERROR;
                ELSE

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('ASO_SECURITY_INT: Delete_Resource: before Delete_Row: l_access_id: ' || l_access_id, 1, 'Y');

				END IF;

                    ASO_QUOTE_ACCESSES_PKG.Delete_Row(
                        p_ACCESS_ID => l_access_id
                    );

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('ASO_SECURITY_INT: Delete_Resource:  after Delete_Row', 1, 'Y');
				END IF;

                END IF;

            ELSE
                x_return_status := FND_API.G_RET_STS_ERROR;

			 IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('ASO_SECURITY_INT: Delete_Resource: trying to delete a non-existent entry', 1, 'Y');

			 END IF;
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    FND_MESSAGE.Set_Name('ASO', 'ASO_SEC_DELETE_INVALID_ID');
                    FND_MSG_PUB.Add;
                END IF;
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;

		  IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('ASO_SECURITY_INT: Delete_Resource: trying to delete without passing enough info', 1, 'Y');
		  END IF;

            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('ASO', 'ASO_SEC_DELETE_INSUFFICIENT');
                FND_MSG_PUB.Add;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    END LOOP;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('ASO_SECURITY_INT: End of Delete_Resource: before update ASO_QUOTE_HEADERS_ALL', 1, 'Y');
    END IF;

    UPDATE ASO_QUOTE_HEADERS_ALL
    SET last_update_date   =  sysdate,
        last_updated_by    =  fnd_global.user_id,
        last_update_login  =  fnd_global.conc_login_id
    WHERE quote_number = l_quote_number AND
		max_version_flag = 'Y';

    IF SQL%ROWCOUNT = 0 THEN
       IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('ASO_SECURITY_INT: End of Delete_Resource: after update ASO_QUOTE_HEADERS_ALL: SQL%ROWCOUNT = 0', 1, 'Y');
       END IF;
       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Change START
    -- Release 12 TAP Changes
    -- Girish Sachdeva 8/30/2005
    -- Adding the call to insert record in the ASO_CHANGED_QUOTES

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
	aso_debug_pub.add('ASO_SECURITY_INT.Delete_Resource : Calling ASO_UTILITY_PVT.UPDATE_CHANGED_QUOTES, quote number : ' || l_quote_number, 1, 'Y');
    end if;

    -- Call to insert record in ASO_CHANGED_QUOTES
    ASO_UTILITY_PVT.UPDATE_CHANGED_QUOTES(l_quote_number);

    -- Change END

    -- End of API body
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('ASO_SECURITY_INT: Delete_Resource: End of API body', 1, 'Y');
    END IF;
    -- Standard check of p_commit.
    IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_Msg_Pub.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count   => x_msg_count    ,
        p_data    => x_msg_data
    );

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_INT,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_INT,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );

        WHEN OTHERS THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_INT,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );

END Delete_Resource;


PROCEDURE Add_SalesRep_QuoteCreator
(
    P_INIT_MSG_LIST              IN            VARCHAR2     := FND_API.G_FALSE,
    P_COMMIT                     IN            VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Header_Rec             IN            ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    X_RETURN_STATUS              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
    X_msg_count                  OUT NOCOPY /* file.sql.39 change */     NUMBER,
    X_msg_data                   OUT NOCOPY /* file.sql.39 change */     VARCHAR2
)
IS

    L_API_NAME                   VARCHAR2(50) := 'Add_SalesRep_QuoteCreator';

    CURSOR C_user_resource_id (l_user_id NUMBER) IS
SELECT resource_id
      FROM jtf_rs_resource_extns
     WHERE user_id = l_user_id
       AND SYSDATE BETWEEN start_date_active AND NVL(end_date_active, SYSDATE);

    CURSOR C_get_resource_role ( l_resource_id NUMBER) IS
    SELECT rel.role_id
    FROM jtf_rs_role_relations rel, jtf_rs_roles_b rolb
    WHERE rel.role_id = rolb.role_id
    AND   rolb.role_type_code = 'SALES'
    AND   NVL(rolb.active_flag, 'Y') <> 'N'
    AND    NVL(rel.delete_flag , 'N') <> 'Y'
    AND   TRUNC(NVL(rel.start_date_active, SYSDATE)) <= TRUNC(SYSDATE)
    AND   TRUNC(NVL(rel.end_date_active, SYSDATE)) >= TRUNC(SYSDATE)
    AND   rel.role_resource_id = l_resource_id;



    c_profile_value          Varchar2(2000);
    l_qte_access_rec         Qte_Access_Rec_Type := G_MISS_QTE_ACCESS_REC;
    l_qte_access_tbl         Qte_Access_Tbl_Type := G_MISS_QTE_ACCESS_TBL;
    lx_qte_access_tbl        Qte_Access_Tbl_Type;
    G_USER_ID                  NUMBER          := FND_GLOBAL.USER_ID;
    G_LOGIN_ID                 NUMBER          := FND_GLOBAL.CONC_LOGIN_ID;
    l_obsolete_status        varchar2(1);
BEGIN

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('ASO_SECURITY_INT: ****** Start of Add_SalesRep_QuoteCreator API ******', 1, 'Y');
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT Add_SalesRep_QuoteCreator_INT;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.To_Boolean(p_init_msg_list) THEN
        FND_Msg_Pub.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API body

    IF p_qte_header_rec.resource_id IS NOT NULL AND p_qte_header_rec.resource_id <> FND_API.G_MISS_NUM THEN

        l_qte_access_rec.QUOTE_NUMBER             := p_qte_header_rec.quote_number;
        l_qte_access_rec.RESOURCE_ID              := p_qte_header_rec.resource_id;
        l_qte_access_rec.RESOURCE_GRP_ID          := p_qte_header_rec.resource_grp_id;
        l_qte_access_rec.CREATED_BY               := G_USER_ID;
        l_qte_access_rec.CREATION_DATE            := SYSDATE;
        l_qte_access_rec.LAST_UPDATED_BY          := G_USER_ID;
        l_qte_access_rec.LAST_UPDATE_LOGIN        := G_LOGIN_ID;
        l_qte_access_rec.LAST_UPDATE_DATE         := SYSDATE;
        l_qte_access_rec.REQUEST_ID               := p_qte_header_rec.request_id;
        l_qte_access_rec.PROGRAM_APPLICATION_ID   := p_qte_header_rec.program_application_id;
        l_qte_access_rec.PROGRAM_ID               := p_qte_header_rec.program_id;
        l_qte_access_rec.PROGRAM_UPDATE_DATE      := p_qte_header_rec.program_update_date;
        l_qte_access_rec.UPDATE_ACCESS_FLAG       := 'Y';
        l_qte_access_rec.KEEP_FLAG                := 'N';
        l_qte_access_rec.batch_price_flag         := p_qte_header_rec.batch_price_flag;

        --bug 5131904
        OPEN C_get_resource_role (p_qte_header_rec.resource_id);
        IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('ASO_SECURITY_INT: Add_SalesRep_QuoteCreator:trying to get role from resource ', 1, 'N');
        END IF;

        FETCH C_get_resource_role INTO l_qte_access_rec.ROLE_ID;

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('ASO_SECURITY_INT: Add_SalesRep_QuoteCreator: l_qte_access_rec.ROLE_ID:  '|| l_qte_access_rec.ROLE_ID, 1, 'N');
        END IF;

        CLOSE C_get_resource_role;

        -- if the resource does not have a group, get it from the QOT Params
        IF (l_qte_access_rec.ROLE_ID IS NULL OR l_qte_access_rec.ROLE_ID = FND_API.G_MISS_NUM) THEN
           l_qte_access_rec.ROLE_ID := aso_utility_pvt.get_ou_attribute_value(aso_utility_pvt.G_DEFAULT_SALES_ROLE,p_qte_header_rec.org_id);
           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('ASO_SECURITY_INT: Add_SalesRep_QuoteCreator: getting role from QOT PARAMS ', 1, 'N');
              aso_debug_pub.add('ASO_SECURITY_INT: Add_SalesRep_QuoteCreator: l_qte_access_rec.ROLE_ID:  '|| l_qte_access_rec.ROLE_ID, 1, 'N');
           END IF;
        END IF;


        l_qte_access_tbl(1)                       := l_qte_access_rec;

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('ASO_SECURITY_INT: Add_SalesRep_QuoteCreator: before Add_Resource: p_qte_header_rec.resource_id:        ' || p_qte_header_rec.resource_id, 1, 'N');
        aso_debug_pub.add('ASO_SECURITY_INT: Add_SalesRep_QuoteCreator: before Add_resource: p_qte_header_rec.resource_grp_id:    ' || p_qte_header_rec.resource_grp_id, 1, 'N');

	   END IF;

        FOR c_user_resource_rec IN C_user_resource_id(G_USER_ID) LOOP
            IF c_user_resource_rec.resource_id <> p_qte_header_rec.resource_id AND c_user_resource_rec.resource_id IS NOT NULL THEN

                l_qte_access_tbl(2)                 := l_qte_access_rec;
                l_qte_access_tbl(2).RESOURCE_ID     := c_user_resource_rec.resource_id;

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('ASO_SECURITY_INT: Add_SalesRep_QuoteCreator: Before calling Get_Profile_Obsolete_Status', 1, 'N');
	           END IF;

                l_obsolete_status := aso_utility_pvt.Get_Profile_Obsolete_Status(p_profile_name   => 'AST_DEFAULT_ROLE_AND_GROUP',
			                                                                  p_application_id => 521);

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('After calling Get_Profile_Obsolete_Status: l_obsolete_status: ' || l_obsolete_status, 1, 'N');
	        END IF;

                if l_obsolete_status = 'T' then

                    c_profile_value := FND_PROFILE.Value_Specific( 'ASF_DEFAULT_GROUP_ROLE', G_USER_ID, NULL, 522);

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('c_profile_value: ' || c_profile_value, 1, 'N');
	            END IF;

                    l_qte_access_tbl(2).RESOURCE_GRP_ID := SUBSTR(c_profile_value, 1, INSTR(c_profile_value,'(')-1);

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('l_qte_access_tbl(2).RESOURCE_GRP_ID: ' || l_qte_access_tbl(2).RESOURCE_GRP_ID, 1, 'N');
                    END IF;

                    if l_qte_access_tbl(2).RESOURCE_GRP_ID is null then

                        c_profile_value := FND_PROFILE.Value_Specific( 'AST_DEFAULT_GROUP', G_USER_ID, NULL, 521);

                        IF aso_debug_pub.g_debug_flag = 'Y' THEN
                            aso_debug_pub.add('c_profile_value: ' || c_profile_value, 1, 'N');
                        END IF;

                        l_qte_access_tbl(2).RESOURCE_GRP_ID := to_number(c_profile_value);

                        IF aso_debug_pub.g_debug_flag = 'Y' THEN
                            aso_debug_pub.add('l_qte_access_tbl(2).RESOURCE_GRP_ID: ' || l_qte_access_tbl(2).RESOURCE_GRP_ID, 1, 'N');
                        END IF;

                    end if;

                else

                    c_profile_value := FND_PROFILE.Value_Specific( 'ASF_DEFAULT_GROUP_ROLE', G_USER_ID, NULL, 522);

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('c_profile_value: ' || c_profile_value, 1, 'N');
                    END IF;

                    l_qte_access_tbl(2).RESOURCE_GRP_ID := SUBSTR(c_profile_value, 1, INSTR(c_profile_value,'(')-1);

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('l_qte_access_tbl(2).RESOURCE_GRP_ID: ' || l_qte_access_tbl(2).RESOURCE_GRP_ID, 1, 'N');
                    END IF;

                    if l_qte_access_tbl(2).RESOURCE_GRP_ID is null then

                        c_profile_value := FND_PROFILE.Value_Specific( 'AST_DEFAULT_ROLE_AND_GROUP', G_USER_ID, NULL, 521);

                        IF aso_debug_pub.g_debug_flag = 'Y' THEN
                            aso_debug_pub.add('c_profile_value: ' || c_profile_value, 1, 'N');
                        END IF;

                        l_qte_access_tbl(2).RESOURCE_GRP_ID := substr(c_profile_value, instr(c_profile_value,':', -1) + 1, length(c_profile_value));

                        IF aso_debug_pub.g_debug_flag = 'Y' THEN
                            aso_debug_pub.add('l_qte_access_tbl(2).RESOURCE_GRP_ID: ' || l_qte_access_tbl(2).RESOURCE_GRP_ID, 1, 'N');
                        END IF;

                    end if;

                end if;


                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('ASO_SECURITY_INT: Add_SalesRep_QuoteCreator: before Add_Resource: c_user_resource_rec.resource_id:     ' || c_user_resource_rec.resource_id, 1, 'N');
                aso_debug_pub.add('ASO_SECURITY_INT: Add_SalesRep_QuoteCreator: before Add_Resource: l_qte_access_tbl(2).RESOURCE_GRP_ID: ' || l_qte_access_tbl(2).RESOURCE_GRP_ID, 1, 'N');
                END IF;

            END IF;

        END LOOP;

	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('ASO_SECURITY_INT: Add_SalesRep_QuoteCreator: before Add_Resource', 1, 'Y');
        END IF;

        ASO_SECURITY_INT.Add_Resource(
            P_INIT_MSG_LIST              => FND_API.G_FALSE,
            P_COMMIT                     => FND_API.G_FALSE,
            P_Qte_Access_tbl             => l_qte_access_tbl,
            X_Qte_Access_tbl             => lx_qte_access_tbl,
            X_RETURN_STATUS              => x_return_status,
            X_msg_count                  => X_msg_count,
            X_msg_data                   => X_msg_data
        );

	   l_qte_access_tbl := lx_qte_access_tbl;

	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('ASO_SECURITY_INT: Add_SalesRep_QuoteCreator:  after Add_Resource: x_return_status: ' || x_return_status, 1, 'Y');
        END IF;

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF;

    -- End of API body

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('ASO_SECURITY_INT: Add_SalesRep_QuoteCreator: End of API body', 1, 'Y');
    END IF;
    -- Standard check of p_commit.
    IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_Msg_Pub.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count   => x_msg_count    ,
        p_data    => x_msg_data
    );

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_INT,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_INT,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );

        WHEN OTHERS THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_INT,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );

END Add_SalesRep_QuoteCreator;


END ASO_SECURITY_INT;

/
