--------------------------------------------------------
--  DDL for Package Body CSP_ASL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_ASL_PUB" AS
/* $Header: cspgrecb.pls 115.8 2004/03/27 00:48:27 hhaugeru ship $ */
-- Start of Comments
-- Package name     : CSP_ASL_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


    G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspgrecb.pls';
    G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
    G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

PROCEDURE IMPORT_RECOMENDED_QUANTITIES(p_Api_Version_Number         IN   NUMBER,
                                       P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
                                       P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
                                       p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
                                       p_item_id                    IN   NUMBER,
                                       p_item_segment1              IN   VARCHAR2,
                                       p_item_segment2              IN   VARCHAR2,
                                       p_item_segment3              IN   VARCHAR2,
                                       p_item_segment4              IN   VARCHAR2,
                                       p_item_segment5              IN   VARCHAR2,
                                       p_item_segment6              IN   VARCHAR2,
                                       p_item_segment7              IN   VARCHAR2,
                                       p_item_segment8              IN   VARCHAR2,
                                       p_item_segment9              IN   VARCHAR2,
                                       p_item_segment10             IN   VARCHAR2,
                                       p_item_segment11             IN   VARCHAR2,
                                       p_item_segment12             IN   VARCHAR2,
                                       p_item_segment13             IN   VARCHAR2,
                                       p_item_segment14             IN   VARCHAR2,
                                       p_item_segment15             IN   VARCHAR2,
                                       p_item_segment16             IN   VARCHAR2,
                                       p_item_segment17             IN   VARCHAR2,
                                       p_item_segment18             IN   VARCHAR2,
                                       p_item_segment19             IN   VARCHAR2,
                                       p_item_segment20             IN   VARCHAR2,
                                       p_organization_id            IN   NUMBER,
                                       p_organization_name          IN   VARCHAR2,
                                       p_organization_code          IN   VARCHAR2,
                                       p_subinventory_code          IN   VARCHAR2,
                                       p_recommended_max            IN   NUMBER,
                                       p_recommended_min            IN   NUMBER,
                                       x_return_status              OUT NOCOPY  VARCHAR2,
                                       X_Msg_Count                  OUT NOCOPY  NUMBER,
                                       X_Msg_Data                   OUT NOCOPY  VARCHAR2) IS
  CURSOR csp_inv_org_code(inv_org_code VARCHAR2) IS
  SELECT ORGANIZATION_ID
  FROM   MTL_PARAMETERS
  WHERE  ORGANIZATION_CODE=inv_org_code;

  CURSOR csp_inv_org_name(inv_org_name VARCHAR2) IS
  SELECT ORGANIZATION_ID
  FROM   HR_ALL_ORGANIZATION_UNITS
  WHERE  NAME = inv_org_name;

  cursor get_delimiter is
  select CONCATENATED_SEGMENT_DELIMITER
  from FND_ID_FLEX_STRUCTURES_VL
  where APPLICATION_ID=401
  and ID_FLEX_CODE='MSTK';

  cursor get_no_of_segments_enabled is
  select count(*)
  from FND_ID_FLEX_SEGMENTS_VL
  where application_id= 401
  and ID_FLEX_CODE='MSTK'
  and ENABLED_FLAG='Y';

  Type v_cur_type IS REF CURSOR;
  l_cur             v_cur_type;

  l_api_version_number      NUMBER := 1.0;
  L_API_NAME                CONSTANT VARCHAR2(30) := 'IMPORT_RECOMENDED_QUANTITIES';
  l_organization_id  NUMBER;
  l_item_id          NUMBER;
  l_msg_count        NUMBER;
  l_header_id        NUMBER;
  l_sql_string         VARCHAR2(3000);
  I                  NUMBER;
  l_dummy               INTEGER;

  l_delimiter           varchar2(1);
  l_number_of_segments  number;
  conc_segments         varchar2(1000);
BEGIN
    SAVEPOINT IMPORT_RECOMENDED_QUANTITIS;
        IF NOT FND_API.Compatible_API_Call
            ( l_api_version_number
            , p_api_version_number
            , L_API_NAME
            , G_PKG_NAME
            )
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        --  Initialize message stack if required
        IF FND_API.to_Boolean(p_init_msg_list)
        THEN
            FND_MSG_PUB.initialize;
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_organization_id IS NOT NULL THEN
        l_organization_id := p_organization_id ;
        ELSE IF p_organization_name IS NOT NULL THEN
            OPEN csp_inv_org_name(p_organization_name);
            LOOP
                FETCH csp_inv_org_name INTO l_organization_id;
                EXIT WHEN csp_inv_org_name% NOTFOUND;
            END LOOP;
            ELSE IF p_organization_code IS NOT NULL THEN
                OPEN csp_inv_org_code(p_organization_code);
                LOOP
                    FETCH csp_inv_org_code INTO l_organization_id;
                    EXIT WHEN csp_inv_org_code% NOTFOUND;
                END LOOP;
            END IF;
        END IF;
    END IF;
    IF csp_inv_org_code% ISOPEN THEN
        CLOSE csp_inv_org_code;
    END IF;
    IF csp_inv_org_name% ISOPEN THEN
        CLOSE csp_inv_org_name;
    END IF;

    IF p_item_id  IS NULL THEN
       OPEN get_delimiter ;
        FETCH get_delimiter into l_delimiter;
        CLOSE get_delimiter ;
        OPEN get_no_of_segments_enabled;
        FETCH get_no_of_segments_enabled into l_number_of_segments;
        CLOSE get_no_of_segments_enabled;
        conc_segments := p_item_segment1;
       IF   l_number_of_segments > 1  THEN
           conc_segments :=  conc_segments || l_delimiter || p_item_segment2;
       END IF;
       IF   l_number_of_segments > 2  THEN
           conc_segments :=  conc_segments || l_delimiter|| p_item_segment3;
       END IF;
       IF   l_number_of_segments > 3 THEN
           conc_segments :=  conc_segments || l_delimiter|| p_item_segment2;
       END IF;
       IF   l_number_of_segments > 4 THEN
           conc_segments :=  conc_segments || l_delimiter|| p_item_segment2;
       END IF;
       IF   l_number_of_segments > 5 THEN
           conc_segments :=  conc_segments || l_delimiter|| p_item_segment2;
       END IF;
       IF   l_number_of_segments > 6 THEN
           conc_segments :=  conc_segments || l_delimiter|| p_item_segment2;
       END IF;
       IF   l_number_of_segments > 7 THEN
           conc_segments :=  conc_segments || l_delimiter|| p_item_segment2;
       END IF;
       IF   l_number_of_segments > 8 THEN
           conc_segments :=  conc_segments || l_delimiter|| p_item_segment2;
       END IF;
       IF   l_number_of_segments > 9 THEN
           conc_segments :=  conc_segments || l_delimiter|| p_item_segment2;
       END IF;
       IF   l_number_of_segments > 10 THEN
           conc_segments :=  conc_segments || l_delimiter|| p_item_segment2;
       END IF;
       IF   l_number_of_segments > 11 THEN
           conc_segments :=  conc_segments || l_delimiter|| p_item_segment2;
       END IF;
       IF   l_number_of_segments > 12 THEN
           conc_segments :=  conc_segments || l_delimiter|| p_item_segment2;
       END IF;
       IF   l_number_of_segments > 13 THEN
           conc_segments :=  conc_segments || l_delimiter|| p_item_segment2;
       END IF;
       IF   l_number_of_segments > 14 THEN
           conc_segments :=  conc_segments || l_delimiter|| p_item_segment2;
       END IF;
       IF   l_number_of_segments > 15 THEN
           conc_segments :=  conc_segments || l_delimiter|| p_item_segment2;
       END IF;
       IF   l_number_of_segments > 16 THEN
           conc_segments :=  conc_segments || l_delimiter|| p_item_segment2;
       END IF;
       IF   l_number_of_segments > 17 THEN
           conc_segments :=  conc_segments || l_delimiter|| p_item_segment2;
       END IF;
       IF   l_number_of_segments > 18 THEN
           conc_segments :=  conc_segments || l_delimiter|| p_item_segment2;
       END IF;
       IF   l_number_of_segments > 19 THEN
           conc_segments :=  conc_segments || l_delimiter|| p_item_segment2;
       END IF;
       l_sql_string := 'SELECT INVENTORY_ITEM_ID from mtl_system_items_b_kfv where CONCATENATED_SEGMENTS =' || '''' || conc_segments || '''';
       OPEN l_cur FOR
            l_sql_string;
       FETCH l_cur INTO l_item_id;
       CLOSE l_cur;
    ELSE
        l_item_id := p_item_id ;
    END IF;
        IF l_item_id IS NOT NULL THEN
            SELECT CSP_USAGE_HEADERS_S1.NEXTVAL INTO l_header_id FROM DUAL;
            INSERT INTO CSP_USAGE_HEADERS  (USAGE_HEADER_ID,INVENTORY_ITEM_ID,ORGANIZATION_ID,RECOMMENDED_MIN_QUANTITY,
                                        RECOMMENDED_MAX_QUANTITY,EXTERNAL_DATA,PROCESS_STATUS,CREATED_BY,
                                        CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,HEADER_DATA_TYPE)
                              VALUES   (l_header_id,l_item_id,l_organization_id, p_recommended_min,p_recommended_max,
                                        'Y','M',G_USER_ID, SYSDATE,  G_USER_ID, SYSDATE, G_LOGIN_ID,4);

            IF p_subinventory_code IS NOT NULL THEN
            INSERT INTO CSP_USAGE_HEADERS  (USAGE_HEADER_ID,INVENTORY_ITEM_ID,ORGANIZATION_ID,RECOMMENDED_MIN_QUANTITY,
                                        RECOMMENDED_MAX_QUANTITY,EXTERNAL_DATA,PROCESS_STATUS,CREATED_BY,
                                        CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,HEADER_DATA_TYPE,SECONDARY_INVENTORY)
                              VALUES   (l_header_id,l_item_id,l_organization_id, p_recommended_min,p_recommended_max,
                                        'Y','M',G_USER_ID, SYSDATE,  G_USER_ID, SYSDATE, G_LOGIN_ID,1,p_subinventory_code);

            END IF;
        END IF;
    IF FND_API.to_Boolean( p_commit )
        THEN
          COMMIT WORK;
    END IF;
    EXCEPTION
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO IMPORT_RECOMENDED_QUANTITIS;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        WHEN OTHERS THEN
                ROLLBACK TO IMPORT_RECOMENDED_QUANTITIS;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END IMPORT_RECOMENDED_QUANTITIES;

PROCEDURE PURGE_OLD_RECOMMENDATIONS(P_Api_Version_Number         IN   NUMBER,
                                    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
                                    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
                                    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
                                    x_return_status              OUT NOCOPY  VARCHAR2,
                                    x_Msg_Count                  OUT NOCOPY  NUMBER,
                                    x_Msg_Data                   OUT NOCOPY  VARCHAR2) IS
     l_api_version_number      NUMBER := 1.0;
     L_API_NAME                CONSTANT VARCHAR2(30) := 'PURGE_OLD_RECOMMENDATIONS';
BEGIN
     SAVEPOINT PURGE_OLD_RECOMMENDATIONS;
     IF NOT FND_API.Compatible_API_Call
            ( l_api_version_number
            , p_api_version_number
            , L_API_NAME
            , G_PKG_NAME
            )
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        --  Initialize message stack if required
        IF FND_API.to_Boolean(p_init_msg_list)
        THEN
            FND_MSG_PUB.initialize;
        END IF;
        CSP_AUTO_ASLMSL_PVT.Purge_Planning_Data (
	    	P_Api_Version_Number         =>  l_api_version_number,
	    	P_Init_Msg_List              =>  FND_API.G_FALSE,
	    	P_Commit                     =>  FND_API.G_FALSE,
	    	P_validation_level           =>  FND_API.G_VALID_LEVEL_FULL,
	    	X_Return_Status              =>  x_return_status,
    		X_Msg_Count                  =>  x_msg_count,
    		X_Msg_Data                   =>  x_msg_data);

            IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
                IF FND_API.to_Boolean( p_commit )
                    THEN
                    COMMIT WORK;
                END IF;
            ELSE
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO PURGE_OLD_RECOMMENDATIONS;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        WHEN OTHERS THEN
                ROLLBACK TO PURGE_OLD_RECOMMENDATIONS;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END PURGE_OLD_RECOMMENDATIONS;
END CSP_ASL_PUB;

/
