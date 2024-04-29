--------------------------------------------------------
--  DDL for Package Body CSP_RESOURCE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_RESOURCE_PUB" AS
/* $Header: cspgtreb.pls 120.1 2005/10/11 23:49:01 hhaugeru noship $ */
-- Start of Comments
-- Package name     : CSP_RESOURCE_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_RESOURCE_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspgtreb.pls';

Procedure ASSIGN_RESOURCE_INV_LOC (
-- Start of Comments
-- Procedure    : ASSIGN_RESOURCE_INV_LOC
-- Purpose      : This procedure is used to create, update and delete the assignment of resource to different
--                inventory locations. It assigns a resource only to those inventory locations that
--                contain spares and is in the operation unit.
--
-- History      :
--  UserID       Date          Comments
--  -----------  --------      --------------------------
--   klou        01/20/00      Modify exception handlings and message libraries such that they are compliant with
--                             CRM standard.
--   klou        01/12/00      Add CSP_Resource_PVT.CSP_Rec_Type record parameters and p_action_code.
--                             p_action_code: 0 = insert, 1 = update, 2 = delete.
--                             Add update and delete operations.
--   klou        01/11/99      Add validatoins on Resource_id and Resource_type.
--   klou        12/16/99      Include validation of subinventory_type against Part-in and Part-out default code.
--   klou        12/15/99      a. replace the use of count() with exception no_data_found to check whether data exists in the table.
--                             b. include standard exception handling.
--   klou        12/14/99      Comment out validations for resource_id an resource_type because the jtf_resource_extn table is corrupted
--   klou        11/09/99      Create.
--
-- NOTES: If validations have been done in the precedent procedure from which this one is being called, doing a
--  full validation here is unnecessary. To avoid repeating the same validations, you can set the
--  p_validation_level to fnd_api.g_valid_level_none when making the procedure call. However, it is your
--  responsibility to make sure all proper validations have been done before calling this procedure.
--  You are recommended to let this procedure handle the validations if you are not sure.
--
-- NOTES: This procedure does not consider the fnd_api.g_miss_num and fnd_api.g_miss_char.
--
-- CAUTIONS: This procedure *ALWAYS* calls other procedures with validation_level set to FND_API.G_VALID_LEVEL_NONE.
--  If you do not do your own validations before calling this procedure, you should set the p_validation_level
--  to FND_API.G_VALID_LEVEL_FULL when making the call.
--
--End of Comments
     P_Api_Version_Number           IN   NUMBER
    ,P_Init_Msg_List                IN   VARCHAR2     := FND_API.G_FALSE
    ,P_Commit                       IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level             IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
    ,p_action_code                  IN   NUMBER       -- 0 = insert, 1 = update, 2 = delete
    ,px_CSP_INV_LOC_ASSIGNMENT_ID   IN OUT NOCOPY  NUMBER
    ,p_CREATED_BY                   IN   NUMBER
    ,p_CREATION_DATE                IN   DATE
    ,p_LAST_UPDATED_BY              IN   NUMBER
    ,p_LAST_UPDATE_DATE             IN   DATE
    ,p_LAST_UPDATE_LOGIN            IN   NUMBER
    ,p_RESOURCE_ID                  IN   NUMBER
    ,p_ORGANIZATION_ID              IN   NUMBER
    ,p_SUBINVENTORY_CODE            IN   VARCHAR2
    ,p_LOCATOR_ID                   IN   NUMBER
    ,p_RESOURCE_TYPE                IN   VARCHAR2
    ,p_EFFECTIVE_DATE_START         IN   DATE
    ,p_EFFECTIVE_DATE_END           IN   DATE
    ,p_DEFAULT_CODE                 IN   VARCHAR2
    ,p_ATTRIBUTE_CATEGORY           IN   VARCHAR2 := NULL
    ,p_ATTRIBUTE1                   IN   VARCHAR2 := NULL
    ,p_ATTRIBUTE2                   IN   VARCHAR2 := NULL
    ,p_ATTRIBUTE3                   IN   VARCHAR2 := NULL
    ,p_ATTRIBUTE4                   IN   VARCHAR2 := NULL
    ,p_ATTRIBUTE5                   IN   VARCHAR2 := NULL
    ,p_ATTRIBUTE6                   IN   VARCHAR2 := NULL
    ,p_ATTRIBUTE7                   IN   VARCHAR2 := NULL
    ,p_ATTRIBUTE8                   IN   VARCHAR2 := NULL
    ,p_ATTRIBUTE9                   IN   VARCHAR2 := NULL
    ,p_ATTRIBUTE10                  IN   VARCHAR2 := NULL
    ,p_ATTRIBUTE11                  IN   VARCHAR2 := NULL
    ,p_ATTRIBUTE12                  IN   VARCHAR2 := NULL
    ,p_ATTRIBUTE13                  IN   VARCHAR2 := NULL
    ,p_ATTRIBUTE14                  IN   VARCHAR2 := NULL
    ,p_ATTRIBUTE15                  IN   VARCHAR2 := NULL
    ,x_return_status                OUT NOCOPY  VARCHAR2
    ,x_msg_count                    OUT NOCOPY  NUMBER
    ,x_msg_data                     OUT NOCOPY  VARCHAR2
)

IS
    l_api_version_number   CONSTANT NUMBER  := 1.0;
    l_api_name             CONSTANT VARCHAR2(30) := 'Assign_Resource_Inv_Loc';
    l_csp_rec              CSP_RESOURCE_PVT.CSP_Rec_Type;
    l_return_status     VARCHAR2(1);
    l_msg_count NUMBER := 0;
    l_msg_data  VARCHAR2(500);
    l_check_existence   NUMBER := 0;
    l_resource_type      VARCHAR2(50);
    l_assignment_id NUMBER;
    l_default_code VARCHAR2(10) := p_default_code;
    l_invalid_default_code    VARCHAR2(1) := FND_API.G_FALSE;
    EXCP_USER_DEFINED EXCEPTION;
    l_record_status     VARCHAR2(1) := FND_API.G_TRUE;
    l_resource_name     VARCHAR2(360);

BEGIN
  -- Start of API savepoint
     SAVEPOINT ASSIGN_RESOURCE_INV_LOC_PUB;

  -- initialize message list
    IF fnd_api.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                        	               p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
   --  END IF;

    -- check p_action_code
    /*IF p_action_code NOT IN (0, 1, 2) THEN
        l_msg_data := 'p_action_code must be 0, 1, or 2.';
        RAISE EXCP_USER_DEFINED;
    END IF;*/

    IF p_action_code in (0,1) THEN
      IF p_validation_level = FND_API.G_VALID_LEVEL_FULL THEN

       -- start full validations
        IF p_organization_id IS NULL THEN
               FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
               FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_organization_id', TRUE);
               FND_MSG_PUB.ADD;
              RAISE EXCP_USER_DEFINED;
        ELSIF p_organization_id IS NOT NULL AND p_action_code IN (0,1) THEN
        -- check whether the organizaton exists.
              BEGIN
                  select organization_id into l_check_existence
                  from mtl_parameters
                  where organization_id = p_organization_id;
              EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                       FND_MESSAGE.SET_NAME ('INV', 'INVALID ORGANIZATION');
                       FND_MSG_PUB.ADD;
                       RAISE EXCP_USER_DEFINED;
                  WHEN OTHERS THEN
                      fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                      fnd_message.set_token('ERR_FIELD', 'p_organization_id', TRUE);
                      fnd_message.set_token('ROUTINE', l_api_name, TRUE);
                      fnd_message.set_token('TABLE', 'mtl_organizations', TRUE);
                      FND_MSG_PUB.ADD;
                      RAISE EXCP_USER_DEFINED;
              END;
       ELSE -- it must be p_organization_id = null and action_code = 2. do nothing for this case.
          NULL;
     END IF;

    IF p_subinventory_code IS NULL THEN
        FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
        FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_subinventory_code', TRUE);
        FND_MSG_PUB.ADD;
        RAISE EXCP_USER_DEFINED;
    -- check whether the subinventory is a Spare subinventory in the organization.
    ELSE
/*        BEGIN
            SELECT SECONDARY_INVENTORY_ID INTO l_check_existence
            FROM csp_sec_inventories
            WHERE organization_id = p_organization_id
            AND secondary_inventory_name = p_subinventory_code;

         EXCEPTION
           WHEN NO_DATA_FOUND THEN
               fnd_message.set_name('CSP', 'CSP_NOT_SPARES_SUB');
               fnd_msg_pub.add;
               RAISE EXCP_USER_DEFINED;
            WHEN TOO_MANY_ROWS THEN
                -- this is a valid situation
                NULL;
            WHEN OTHERS THEN
                fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                fnd_message.set_token('ERR_FIELD', 'p_subinventory_code', TRUE);
                fnd_message.set_token('ROUTINE', l_api_name, TRUE);
                fnd_message.set_token('TABLE', 'csp_sec_inventories', TRUE);
                FND_MSG_PUB.ADD;
                RAISE EXCP_USER_DEFINED;
         END;
*/
         -- valide the p_locator_id if it is not null
         IF p_locator_id IS NOT NULL THEN
            BEGIN
                SELECT inventory_location_id INTO l_check_existence
                FROM mtl_item_locations
                WHERE organization_id = p_organization_id
                AND subinventory_code = p_subinventory_code
                AND inventory_location_id = p_locator_id;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    fnd_message.set_name('INV', 'INV_LOCATOR_NOT_AVAILABLE');
                    fnd_msg_pub.add;
                    RAISE EXCP_USER_DEFINED;
                /*WHEN TOO_MANY_ROWS THEN
                    l_msg_data := 'More than one same Locator ID was found. The locator table might not be set up correctly.';
                    RAISE EXCP_USER_DEFINED;*/
                WHEN OTHERS THEN
                    fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                    fnd_message.set_token('ERR_FIELD', 'p_locator_id', TRUE);
                    fnd_message.set_token('ROUTINE', l_api_name, TRUE);
                    fnd_message.set_token('TABLE', 'mtl_item_locations', TRUE);
                    fnd_msg_pub.ADD;
                    --l_msg_data := 'Unexpected errors occurred while validating the Locator ID. Please contact your system administrator.';
                    RAISE EXCP_USER_DEFINED;
           END;
        END IF;
     END IF;

    IF p_resource_id IS NULL THEN
        FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
        FND_MESSAGE.SET_TOKEN ('PARAMETER', 'p_resource_id', TRUE);
        FND_MSG_PUB.ADD;
        RAISE EXCP_USER_DEFINED;

  -- check whether the resource id and resource type exist.
     ELSE
      BEGIN
--          SELECT resource_id INTO l_check_existence
--          FROM jtf_rs_all_resources_vl
--          WHERE resource_id = p_resource_id
--          AND resource_type = p_resource_type;
        select csf_util_pvt.get_object_name(p_resource_type, p_resource_id) into l_resource_name
        from dual;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            fnd_message.set_name('CSP', 'CSP_INVALID_RES_ID_TYPE');
            fnd_msg_pub.add;
            RAISE EXCP_USER_DEFINED;
          /*WHEN TOO_MANY_ROWS THEN
            l_msg_data := 'Duplicate Resource ID found. There may be an error in your Resource table.';
            RAISE EXCP_USER_DEFINED;*/
          WHEN OTHERS THEN
            fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
            fnd_message.set_token('ERR_FIELD', 'p_resource_id', TRUE);
            fnd_message.set_token('ROUTINE', l_api_name, TRUE);
            fnd_message.set_token('TABLE', 'jtf_rs_all_resources_vl', TRUE);
            fnd_msg_pub.ADD;
            RAISE EXCP_USER_DEFINED;
        END;
       END IF;


   END IF;  -- end of validaitons

       /* --
         Validate the default code:
         p_default_code = 'IN', validate whether the p_subinventory_code is of a 'G' (good) type.
         p_default_code = 'OUT', validate whether the p_subinventory-code is of a 'B' (bad) type.
         p_default_code = NOT NULL, not 'IN' and not 'OUT', create a warning message and then set it to NULL
         p_default_code = NULL, do nothing.
         -- */
            DECLARE
                    l_subinventory_type  VARCHAR2(10);
                    l_good_type VARCHAR2(1) := fnd_api.g_false;
                    l_bad_type VARCHAR2(1) := fnd_api.g_false;
                    CURSOR c_Get_Condition_Type IS
                      SELECT condition_type
                        FROM csp_sec_inventories
                        WHERE secondary_inventory_name = p_subinventory_code
                        AND organization_id = p_organization_id;

            BEGIN
                --find the condition type of p_subinventory_code
                OPEN c_Get_Condition_Type;
                LOOP

                    FETCH c_Get_Condition_Type into l_subinventory_type;
                    EXIT WHEN c_Get_Condition_Type%NOTFOUND;
                        if  l_subinventory_type = 'G' then
                            l_good_type := fnd_api.g_true;
                        elsif l_subinventory_type = 'B' then
                            l_bad_type := fnd_api.g_true;
                        else null;
                        end if;
                END LOOP;
                CLOSE c_Get_Condition_Type;

                IF upper(l_default_code) = 'IN' THEN
                      IF fnd_api.to_boolean(l_bad_type) AND NOT fnd_api.to_boolean(l_good_type) THEN

                        fnd_message.set_name('CSP', 'CSP_INVALID_IN_OUT_SUB');
                        fnd_msg_pub.ADD;
                        RAISE EXCP_USER_DEFINED;
                      END IF;

               ELSIF upper(l_default_code) = 'OUT' THEN
                    IF fnd_api.to_boolean(l_good_type) AND NOT fnd_api.to_boolean(l_bad_type)THEN

                        fnd_message.set_name('CSP', 'CSP_INVALID_IN_OUT_SUB');
                        fnd_msg_pub.ADD;
                        RAISE EXCP_USER_DEFINED;
                    END IF;

               ELSIF l_default_code IS NOT NULL AND NOT fnd_api.to_boolean(l_good_type)
                    AND NOT fnd_api.to_boolean(l_bad_type) AND p_action_code = 0 THEN

                        fnd_message.set_name('CSP', 'CSP_RES_INV_WARNING');
                        fnd_msg_pub.ADD;
                        l_default_code := NULL;
               ELSE NULL;
               END IF;

           END;
 END IF;

      IF p_action_code = 0 THEN
     -- now we are ready to call the insert operation.
        IF px_CSP_INV_LOC_ASSIGNMENT_ID IS NOT NULL THEN
           -- we have to find out whether the record ready exists.
           BEGIN
               SELECT csp_inv_loc_assignment_id INTO l_check_existence
               FROM csp_inv_loc_assignments
               WHERE csp_inv_loc_assignment_id = px_csp_inv_loc_assignment_id;

               RAISE TOO_MANY_ROWS;
           EXCEPTION
            WHEN NO_DATA_FOUND THEN
                -- It's a good case.
                NULL;
           WHEN TOO_MANY_ROWS THEN
               fnd_message.set_name('CSP', 'CSP_DUPLICATE_RECORD');
               fnd_msg_pub.ADD;
               RAISE EXCP_USER_DEFINED;
           WHEN OTHERS THEN
                --l_msg_data := SQLERRM(SQLCODE);
                fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                fnd_message.set_token('ERR_FIELD', 'px_csp_inv_loc_assignment_id', TRUE);
                fnd_message.set_token('ROUTINE', l_api_name, TRUE);
                fnd_message.set_token('TABLE', 'csp_inv_loc_assignments', TRUE);
                fnd_msg_pub.ADD;
               RAISE EXCP_USER_DEFINED;
           END;
        END IF;

/*        IF p_EFFECTIVE_DATE_START IS NULL OR p_EFFECTIVE_DATE_END IS NULL THEN
            fnd_message.set_name('CSP', 'CSP_INVALID_START_END_DATES');
            fnd_msg_pub.add;
            RAISE EXCP_USER_DEFINED;
        END IF;
*/
         -- validate whether the combination already exists, if yes, raise the EXCP_DUPLICATE_RECORD exception
            validate_assignment_record (
              p_resource_id  => p_resource_id
             ,p_resource_type => p_resource_type
             ,p_organization_id  => p_organization_id
             ,p_subinventory_code  => p_subinventory_code
             ,p_default_code       => p_default_code
             ,x_return_status      => l_record_status);

             IF FND_API.to_Boolean(l_record_status ) THEN
               fnd_message.set_name('CSP', 'CSP_DUPLICATE_RECORD');
               fnd_msg_pub.ADD;
               RAISE EXCP_USER_DEFINED;
             END IF;

      -- construct the l_csp_rec record
          l_csp_rec.CSP_INV_LOC_ASSIGNMENT_ID := px_CSP_INV_LOC_ASSIGNMENT_ID;
          l_csp_rec.CREATED_BY := p_CREATED_BY;
          l_csp_rec.CREATION_DATE := p_CREATION_DATE;
          l_csp_rec.LAST_UPDATED_BY := p_LAST_UPDATED_BY;
          l_csp_rec.LAST_UPDATE_DATE := p_LAST_UPDATE_DATE;
          l_csp_rec.LAST_UPDATE_LOGIN := p_LAST_UPDATE_LOGIN;
          l_csp_rec.RESOURCE_ID := p_RESOURCE_ID;
          l_csp_rec.ORGANIZATION_ID := p_ORGANIZATION_ID;
          l_csp_rec.SUBINVENTORY_CODE := p_SUBINVENTORY_CODE;
          l_csp_rec.LOCATOR_ID := p_LOCATOR_ID;
          l_csp_rec.RESOURCE_TYPE := p_RESOURCE_TYPE;
          l_csp_rec.EFFECTIVE_DATE_START := p_EFFECTIVE_DATE_START;
          l_csp_rec.EFFECTIVE_DATE_END := p_EFFECTIVE_DATE_END;
          l_csp_rec.DEFAULT_CODE := p_DEFAULT_CODE;
          l_csp_rec.ATTRIBUTE_CATEGORY := p_ATTRIBUTE_CATEGORY;
          l_csp_rec.ATTRIBUTE1 := p_ATTRIBUTE1;
          l_csp_rec.ATTRIBUTE2 := p_ATTRIBUTE2;
          l_csp_rec.ATTRIBUTE3 := p_ATTRIBUTE3;
          l_csp_rec.ATTRIBUTE4 := p_ATTRIBUTE4;
          l_csp_rec.ATTRIBUTE5 := p_ATTRIBUTE5;
          l_csp_rec.ATTRIBUTE6 := p_ATTRIBUTE6;
          l_csp_rec.ATTRIBUTE7 := p_ATTRIBUTE7;
          l_csp_rec.ATTRIBUTE8 := p_ATTRIBUTE8;
          l_csp_rec.ATTRIBUTE9 := p_ATTRIBUTE9;
          l_csp_rec.ATTRIBUTE10 := p_ATTRIBUTE10;
          l_csp_rec.ATTRIBUTE11 := p_ATTRIBUTE11;
          l_csp_rec.ATTRIBUTE12 := p_ATTRIBUTE12;
          l_csp_rec.ATTRIBUTE13 := p_ATTRIBUTE13;
          l_csp_rec.ATTRIBUTE14 := p_ATTRIBUTE14;
          l_csp_rec.ATTRIBUTE15 := p_ATTRIBUTE15;

          CSP_RESOURCE_PVT.Create_resource(
            P_Api_Version_Number         => p_api_version_number,
            P_Init_Msg_List              => FND_API.G_TRUE,
            P_Commit                     => FND_API.G_FALSE,
            p_validation_level           => FND_API.G_VALID_LEVEL_NONE,
            P_CSP_Rec                    => l_csp_rec,
            X_CSP_INV_LOC_ASSIGNMENT_ID  => l_assignment_id,
            X_Return_Status              => l_return_status,
            X_Msg_Count                  => l_msg_count,
            X_Msg_Data                    => l_msg_data
           );
    ELSIF p_action_code in(1, 2) THEN

        -- make sure the record exists.
        IF px_CSP_INV_LOC_ASSIGNMENT_ID IS NULL THEN
            FND_MESSAGE.SET_NAME ('CSP', 'CSP_MISSING_PARAMETERS');
            FND_MESSAGE.SET_TOKEN ('PARAMETER', 'px_csp_inv_loc_assignment_id', TRUE);
            FND_MSG_PUB.ADD;
            RAISE EXCP_USER_DEFINED;
        ELSE
            BEGIN
                SELECT csp_inv_loc_assignment_id INTO l_check_existence
                FROM csp_inv_loc_assignments
                WHERE csp_inv_loc_assignment_id = px_csp_inv_loc_assignment_id;


            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    fnd_message.set_name('CSP', 'CSP_INVALID_ASSIGNMENT_ID');
                    fnd_message.set_token('ASSIGNMENT_ID', to_char(px_csp_inv_loc_assignment_id), TRUE);
                    fnd_msg_pub.add;
                    RAISE EXCP_USER_DEFINED;
               -- WHEN TOO_MANY_ROWS THEN
                --    l_msg_data := 'Too many Assignment ID '||px_csp_inv_loc_assignment_id||' found. You may have a data setup problem.';
                 --   RAISE EXCP_USER_DEFINED;
                WHEN OTHERS THEN
                   --l_msg_data := SQLERRM(SQLCODE);
                   -- l_msg_data := l_msg_data||'. Unexpected errors occurred while validating the Assignment ID. Please contact your system administrator.';
                    fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                    fnd_message.set_token('ERR_FIELD', 'px_csp_inv_loc_assignment_id', TRUE);
                    fnd_message.set_token('ROUTINE', l_api_name, TRUE);
                    fnd_message.set_token('TABLE', 'csp_inv_loc_assignments', TRUE);
                    fnd_msg_pub.ADD;
                    RAISE EXCP_USER_DEFINED;
           END;
             -- construct the l_csp_rec record
              l_csp_rec.CSP_INV_LOC_ASSIGNMENT_ID := px_CSP_INV_LOC_ASSIGNMENT_ID;
              l_csp_rec.CREATED_BY := p_CREATED_BY;
              l_csp_rec.CREATION_DATE := p_CREATION_DATE;
              l_csp_rec.LAST_UPDATED_BY := p_LAST_UPDATED_BY;
              l_csp_rec.LAST_UPDATE_DATE := p_LAST_UPDATE_DATE;
              l_csp_rec.LAST_UPDATE_LOGIN := p_LAST_UPDATE_LOGIN;
              l_csp_rec.RESOURCE_ID := p_RESOURCE_ID;
              l_csp_rec.ORGANIZATION_ID := p_ORGANIZATION_ID;
              l_csp_rec.SUBINVENTORY_CODE := p_SUBINVENTORY_CODE;
              l_csp_rec.LOCATOR_ID := p_LOCATOR_ID;
              l_csp_rec.RESOURCE_TYPE := p_RESOURCE_TYPE;
              l_csp_rec.EFFECTIVE_DATE_START := p_EFFECTIVE_DATE_START;
              l_csp_rec.EFFECTIVE_DATE_END := p_EFFECTIVE_DATE_END;
              l_csp_rec.DEFAULT_CODE := p_DEFAULT_CODE;
              l_csp_rec.ATTRIBUTE_CATEGORY := p_ATTRIBUTE_CATEGORY;
              l_csp_rec.ATTRIBUTE1 := p_ATTRIBUTE1;
              l_csp_rec.ATTRIBUTE2 := p_ATTRIBUTE2;
              l_csp_rec.ATTRIBUTE3 := p_ATTRIBUTE3;
              l_csp_rec.ATTRIBUTE4 := p_ATTRIBUTE4;
              l_csp_rec.ATTRIBUTE5 := p_ATTRIBUTE5;
              l_csp_rec.ATTRIBUTE6 := p_ATTRIBUTE6;
              l_csp_rec.ATTRIBUTE7 := p_ATTRIBUTE7;
              l_csp_rec.ATTRIBUTE8 := p_ATTRIBUTE8;
              l_csp_rec.ATTRIBUTE9 := p_ATTRIBUTE9;
              l_csp_rec.ATTRIBUTE10 := p_ATTRIBUTE10;
              l_csp_rec.ATTRIBUTE11 := p_ATTRIBUTE11;
              l_csp_rec.ATTRIBUTE12 := p_ATTRIBUTE12;
              l_csp_rec.ATTRIBUTE13 := p_ATTRIBUTE13;
              l_csp_rec.ATTRIBUTE14 := p_ATTRIBUTE14;
              l_csp_rec.ATTRIBUTE15 := p_ATTRIBUTE15;

            IF p_action_code = 1 THEN
                -- we have to make sure that by updating an existing a record. A
                -- duplicate record will not be created.
                DECLARE
                    l_csp_rec_update        CSP_RESOURCE_PVT.CSP_Rec_Type;
                    l_result NUMBER;
                    CURSOR C_Get_Inv_Loc_Assignments IS
                        SELECT CSP_INV_LOC_ASSIGNMENT_ID       ,
                               CREATED_BY                      ,
                               CREATION_DATE                   ,
                               LAST_UPDATED_BY                 ,
                               LAST_UPDATE_DATE                ,
                               LAST_UPDATE_LOGIN               ,
                               RESOURCE_ID                     ,
                               ORGANIZATION_ID                 ,
                               SUBINVENTORY_CODE               ,
                               LOCATOR_ID                      ,
                               RESOURCE_TYPE                   ,
                               EFFECTIVE_DATE_START            ,
                               EFFECTIVE_DATE_END              ,
                               DEFAULT_CODE                    ,
                               ATTRIBUTE_CATEGORY              ,
                               ATTRIBUTE1                      ,
                               ATTRIBUTE2                      ,
                               ATTRIBUTE3                      ,
                               ATTRIBUTE4                      ,
                               ATTRIBUTE5                      ,
                               ATTRIBUTE6                      ,
                               ATTRIBUTE7                      ,
                               ATTRIBUTE8                      ,
                               ATTRIBUTE9                      ,
                               ATTRIBUTE10                     ,
                               ATTRIBUTE11                     ,
                               ATTRIBUTE12                     ,
                               ATTRIBUTE13                     ,
                               ATTRIBUTE14                     ,
                               ATTRIBUTE15
                         FROM csp_inv_loc_assignments
                         WHERE csp_inv_loc_assignment_id = px_csp_inv_loc_assignment_id;

                BEGIN

                    OPEN C_Get_Inv_Loc_Assignments;
                    FETCH C_Get_Inv_Loc_Assignments INTO l_csp_rec_update;
                    IF C_Get_Inv_Loc_Assignments%NOTFOUND THEN
                       CLOSE C_Get_Inv_Loc_Assignments;
                        fnd_message.set_name('CSP', 'CSP_INVALID_ASSIGNMENT_ID');
                        fnd_message.set_token('ASSIGNMENT_ID', to_char(px_csp_inv_loc_assignment_id), TRUE);
                        fnd_msg_pub.add;
                       RAISE EXCP_USER_DEFINED;
                    END IF;
                    CLOSE C_Get_Inv_Loc_Assignments;

                      SELECT csp_inv_loc_assignment_id into l_result
                      FROM csp_inv_loc_assignments
                      WHERE resource_id = p_resource_id
                      AND   resource_type = p_resource_type
                      AND   organization_id = p_organization_id
                      AND   subinventory_code = p_subinventory_code
                      AND   default_code = p_default_code
                      AND   csp_inv_loc_assignment_id <> px_csp_inv_loc_assignment_id;

                      RAISE TOO_MANY_ROWS;
                 EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                      /*
                        -- The update will not create a duplicate record.
                        -- But we also need to check the subinventory In-Good, and Out-Bad
                        -- conditions are maintained after the update.
                        IF p_subinventory_code IS NOT NULL OR p_default_code IS NOT NULL THEN
                           /* --
                           Validate the default code:
                           p_default_code = 'IN', validate whether the p_subinventory_code is of a 'G' (good) type.
                           p_default_code = 'OUT', validate whether the p_subinventory-code is of a 'B' (bad) type.
                           p_default_code = NOT NULL, not 'IN' and not 'OUT', create a warning message and then set it to NULL
                           p_default_code = NULL, do nothing.
                           -- */
                              /*DECLARE
                                      l_subinventory_type  VARCHAR2(10);
                                      l_good_type VARCHAR2(1) := fnd_api.g_false;
                                      l_bad_type VARCHAR2(1) := fnd_api.g_false;
                                      CURSOR c_Get_Condition_Type IS
                                        SELECT condition_type
                                          FROM csp_sec_inventories
                                          WHERE secondary_inventory_name = decode(p_subinventory_code, null, l_csp_rec_update.subinventory_code, p_subinventory_code)
                                          AND organization_id = decode(p_organization_id, null, l_csp_rec_update.organization_id, p_organization_id);

                              BEGIN
                                  --find the condition type of p_subinventory_code
                                  OPEN c_Get_Condition_Type;
                                  LOOP
                                      FETCH c_Get_Condition_Type into l_subinventory_type;
                                      EXIT WHEN c_Get_Condition_Type%NOTFOUND;

                                          if  l_subinventory_type = 'G' then
                                              l_good_type := fnd_api.g_true;
                                          elsif l_subinventory_type = 'B' then
                                              l_bad_type := fnd_api.g_true;
                                          else null;
                                          end if;
                                  END LOOP;
                                  IF c_Get_Condition_Type%rowcount = 0 THEN
                                    l_msg_data := 'The subinventory is not a spares inventory.';
                                    CLOSE c_Get_Condition_Type;
                                    RAISE EXCP_USER_DEFINED;
                                  END IF;
                                    CLOSE c_Get_Condition_Type;

                                  IF upper(nvl(p_default_code, l_csp_rec_update.default_code)) = 'IN' THEN
                                        IF fnd_api.to_boolean(l_bad_type) AND NOT fnd_api.to_boolean(l_good_type) THEN
                                          l_msg_data := 'Only a Good subinventory is allowed to be assigned as a Part-In subinventory.';
                                          l_msg_data := l_msg_data ||' Please check the condition type of subinventory '||p_subinventory_code||'.';
                                          RAISE EXCP_USER_DEFINED;
                                        END IF;

                                 ELSIF upper(nvl(p_default_code, l_csp_rec_update.default_code)) = 'OUT' THEN
                                      IF fnd_api.to_boolean(l_good_type) AND NOT fnd_api.to_boolean(l_bad_type)THEN
                                          l_msg_data := 'Only a Bad subinventory is allowed to be assigned as a Part-Out subinventory.';
                                          l_msg_data := l_msg_data ||' Please check the condition type of subinventory '||p_subinventory_code||'.';
                                          RAISE EXCP_USER_DEFINED;
                                      END IF;

                                -- ELSIF decode(p_default_code, null, l_csp_rec_update.default_code, p_default_code) IS NOT NULL AND NOT fnd_api.to_boolean(l_good_type)
                                  --    AND NOT fnd_api.to_boolean(l_bad_type) THEN
                                        --  l_msg_data := 'Warning: Default Code is not an "IN" or an "OUT" type. Please query the record and re-assign a valid Default Code.';
                                        --  fnd_message.set_name(l_msg_data, 'API_ASSIGN_RESOURCE_INV_LOC');
                                      --    fnd_message.set_token('ROUTINE', 'Assign_Resource_Inv_Loc');
                                     --     fnd_msg_pub.ADD;
                                   --       l_default_code := NULL;
                                 ELSE NULL;
                                 END IF;
                             END;
                          END IF;
                          */

                        /*
                          -- we also need to make sure the resource_type and resource_id are valid
                              BEGIN
                                SELECT resource_id INTO l_check_existence
                                FROM jtf_rs_all_resources_vl
                                WHERE resource_id = decode(p_resource_id, null, l_csp_rec_update.resource_id, p_resource_id)
                                AND resource_type = decode(p_resource_type, null, l_csp_rec_update.resource_type, p_resource_type);

                              EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                  l_msg_data := 'Resource ID or Resource Type is invalid.';
                                  RAISE EXCP_USER_DEFINED;
                                WHEN TOO_MANY_ROWS THEN
                                  l_msg_data := 'Duplicate Resource ID found. There may be an error in your Resource table.';
                                  RAISE EXCP_USER_DEFINED;
                                WHEN OTHERS THEN
                                  l_msg_data := 'Unexpected errors found while validating the Resource ID. Please contact your system administrator.';
                                  RAISE EXCP_USER_DEFINED;
                              END;
                              */
                              NULL;
                    WHEN TOO_MANY_ROWS THEN
                       fnd_message.set_name('CSP', 'CSP_DUPLICATE_RECORD');
                       fnd_msg_pub.add;
                       RAISE EXCP_USER_DEFINED;
                    WHEN EXCP_USER_DEFINED THEN
                        RAISE EXCP_USER_DEFINED;
                    WHEN OTHERS THEN
                       -- l_msg_data := SQLERRM(SQLCODE);
                        --l_msg_data := l_msg_data||'. This update operation is not allowed because updating this record creates a duplicate record with an existing one.';
                        fnd_message.set_name('CSP', 'CSP_UNEXPECTED_ERRORS');
                        fnd_message.set_token('ERR_FIELD', 'px_csp_inv_loc_assignment_id', TRUE);
                        fnd_message.set_token('ROUTINE', l_api_name, TRUE);
                        fnd_message.set_token('TABLE', 'csp_inv_loc_assignments', TRUE);
                        fnd_msg_pub.ADD;
                        RAISE EXCP_USER_DEFINED;
                END;

            -- call the update procedure
                 IF l_csp_rec.last_update_date IS NULL THEN
                    l_csp_rec.last_update_date := sysdate;
                 END IF;
                 IF l_csp_rec.creation_date IS NULL THEN
                    BEGIN
                        SELECT creation_date INTO l_csp_rec.creation_date
                        FROM csp_inv_loc_assignments
                        WHERE csp_inv_loc_assignment_id = l_csp_rec.csp_inv_loc_assignment_id;
                    END;
                 END IF;
                 CSP_RESOURCE_PVT.Update_resource(
                    P_Api_Version_Number         => p_api_version_number,
                    P_Init_Msg_List              => FND_API.G_TRUE,
                    P_Commit                     => FND_API.G_FALSE,
                    p_validation_level           => FND_API.G_VALID_LEVEL_NONE,
                    P_CSP_Rec                    => l_csp_rec,
                    X_Return_Status              => l_return_status,
                    X_Msg_Count                  => l_msg_count,
                    X_Msg_Data                   => l_msg_data
                   );
            ELSE
           -- call the delete procedure
                  CSP_RESOURCE_PVT.Delete_resource(
                    P_Api_Version_Number         => p_api_version_number,
                    P_Init_Msg_List              => FND_API.G_TRUE,
                    P_Commit                     => FND_API.G_FALSE,
                    p_validation_level           => FND_API.G_VALID_LEVEL_NONE,
                    P_CSP_Rec                    => l_csp_rec,
                    X_Return_Status              => l_return_status,
                    X_Msg_Count                  => l_msg_count,
                    X_Msg_Data                    => l_msg_data
                   );
           END IF;
         END IF;
     ELSE
           -- l_msg_data := 'p_action_code must be 0, 1, or 2.';
           fnd_message.set_name('INV', 'INV-INVALID ACTION');
           fnd_message.set_token('ROUTINE', l_api_name, TRUE);
           fnd_msg_pub.add;
           RAISE EXCP_USER_DEFINED;
    END IF;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSE
            x_return_status := fnd_api.g_ret_sts_success;
            px_CSP_INV_LOC_ASSIGNMENT_ID := l_assignment_id;
            IF fnd_api.to_boolean(p_commit) THEN
                commit work;
            END IF;
        END IF;

EXCEPTION
        WHEN EXCP_USER_DEFINED THEN

              fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
             x_return_status := FND_API.G_RET_STS_ERROR;

        WHEN FND_API.G_EXC_ERROR THEN

              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

        WHEN OTHERS THEN

              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

END ASSIGN_RESOURCE_INV_LOC;


PROCEDURE Validate_Assignment_Record (
-- Start of Comments
-- Procedure    : Validate_Assignment_Record
-- Purpose      : Thie procedure validates whether an assignment record already exists for a resource.
--                A resource is allowed to be assigned to different subinventory but duplicate record
--                is not allowed.
-- History      :
--  11-Dev-1999, modified to include the case where p_default_code is null.
--  15-Dec-1999, created by vernon.
--
-- Note         : If the record already exists, x_return_status is set to fnd_api.g_true, if not to fnd_api.g_false.
--End of Comments

        p_resource_id           IN  NUMBER
       ,p_resource_type         IN  VARCHAR2
       ,p_organization_id       IN  NUMBER
       ,p_subinventory_code     IN  VARCHAR2
       ,p_default_code          IN  VARCHAR2
       ,x_return_status         OUT NOCOPY VARCHAR2)
IS
    l_result NUMBER := -1;

BEGIN
       IF p_default_code IS NULL THEN
          SELECT csp_inv_loc_assignment_id into l_result
          FROM csp_inv_loc_assignments
          WHERE resource_id = p_resource_id
          AND   resource_type = p_resource_type
          AND   organization_id = p_organization_id
          AND   subinventory_code = p_subinventory_code;
 --         AND   default_code IS NULL;
       ELSE
          SELECT csp_inv_loc_assignment_id into l_result
          FROM csp_inv_loc_assignments
          WHERE resource_id = p_resource_id
          AND   resource_type = p_resource_type
          AND   organization_id = p_organization_id
          AND   subinventory_code = p_subinventory_code;
 --         AND   default_code = p_default_code;
      END IF;


        -- If the no_data_found exception was not thrown by the above statement, the record should already exits.
        x_return_status := FND_API.G_TRUE;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_FALSE;
    WHEN OTHERS THEN
        -- any other exceptions besides no_data_found should be considered invalid situations.
        x_return_status := FND_API.G_TRUE;

END Validate_Assignment_Record;

End CSP_RESOURCE_PUB;

/
