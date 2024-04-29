--------------------------------------------------------
--  DDL for Package Body IBE_PROD_RELATION_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_PROD_RELATION_RULE_PVT" AS
/* $Header: IBEVCRRB.pls 120.0.12010000.3 2014/06/24 09:04:42 amaheshw ship $ */

FUNCTION check_map_rule_exists(
    p_relation_code           IN VARCHAR2,
    p_origin_object_type        IN VARCHAR2,
    p_origin_object_id           IN NUMBER,
    p_dest_object_type       IN VARCHAR2,
    p_dest_object_id     IN NUMBER) RETURN BOOLEAN
IS
 l_exists VARCHAR2(1) := '0';
 --Added by amaheshw Bug 18997051 - DUPLICATE CATEGORIES APPEARED FOR A SECTION
  l_exists1 VARCHAR2(1) := '0';
BEGIN

--Added by amaheshw Bug 18997051 - DUPLICATE CATEGORIES APPEARED FOR A SECTION
IF (p_relation_code = 'AUTOPLACEMENT') THEN
     SELECT '1'
   into l_exists1
   from dual where exists (select icrr.relation_rule_Id
   FROM   ibe_ct_relation_rules ICRR
   where ICRR.relation_type_code = p_relation_code
          and   ICRR.origin_object_type = p_origin_object_type
          and  ICRR.origin_object_id = p_origin_object_id
          and ICRR.dest_object_id =p_dest_object_id
          and ICRR.dest_object_type = p_dest_object_type);

 if (l_exists1 <> '1' ) then
   return FALSE;
 else
   return TRUE;
END IF;

End IF;
 --end of addition Bug 18997051

   SELECT '1'
   into l_exists
   from dual where exists (select icrr.relation_rule_Id
   FROM   ibe_ct_relation_rules ICRR, ibe_ct_related_items ICRI
   WHERE   ICRR.relation_rule_id = ICRI.relation_rule_id
          and              ICRI.organization_id = L_organization_Id
          and    ICRR.relation_type_code = p_relation_code
          and   ICRR.origin_object_type = p_origin_object_type
          and  ICRR.origin_object_id = p_origin_object_id
          and ICRR.dest_object_id =p_dest_object_id
          and ICRR.dest_object_type = p_dest_object_type);
 if (l_exists <> '1' ) then
   return FALSE;
 else
   return TRUE;
END IF;

  Exception
    when NO_DATA_FOUND then
       return FALSE;
END;


PROCEDURE Insert_SQL_Rule(
   p_api_version   IN  NUMBER                     ,
   p_init_msg_list IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit        IN  VARCHAR2 := FND_API.G_FALSE,
   x_return_status OUT NOCOPY VARCHAR2                   ,
   x_msg_count     OUT NOCOPY NUMBER                     ,
   x_msg_data      OUT NOCOPY VARCHAR2                   ,
   p_rel_type_code IN  VARCHAR2                   ,
   p_sql_statement IN  VARCHAR2
)
IS
   L_API_NAME        CONSTANT VARCHAR2(30) := 'Insert_SQL_Rule';
   L_API_VERSION     CONSTANT NUMBER       := 1.0;
   l_debug VARCHAR2(1);

BEGIN
      l_debug  := NVL(FND_PROFILE.VALUE('IBE_DEBUG'),'N');

   -- Standard Start of API savepoint
   SAVEPOINT Insert_SQL_Rule_PVT;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('IBE_Prod_Relation_Rule_PVT.Insert_SQL_Rule(+)');
   END IF;
   -- API body
   IF NOT Is_SQL_Valid( p_sql_statement ) THEN
      IF (l_debug = 'Y') THEN
         IBE_UTIL.debug('Invalid SQL statement');
      END IF;
      FND_MESSAGE.Set_Name('IBE', 'IBE_CT_INVALID_SQL_RULE');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   INSERT INTO IBE_CT_RELATION_RULES(
      relation_rule_id, object_version_number, created_by,
      creation_date, last_updated_by, last_update_date,
      relation_type_code, origin_object_type,
      dest_object_type, sql_statement
   )
   VALUES(
      IBE_CT_RELATION_RULES_S1.NEXTVAL, 1, L_USER_ID,
      SYSDATE, L_USER_ID, SYSDATE,
      p_rel_type_code, 'N',
      'N', p_sql_statement
   );

   IF SQL%NOTFOUND THEN
      IF (l_debug = 'Y') THEN
         IBE_UTIL.debug('Failed to insert the SQL rule.');
      END IF;
      FND_MESSAGE.Set_Name('IBE', 'IBE_CT_REL_RULE_NOT_CREATED');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   -- End of API body.
   IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('IBE_Prod_Relation_Rule_PVT.Insert_SQL_Rule(-)');
   END IF;

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count    ,
                             p_data    => x_msg_data     );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Insert_SQL_Rule_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Insert_SQL_Rule_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );

   WHEN OTHERS THEN
      ROLLBACK TO Insert_SQL_Rule_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                  L_API_NAME );
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );
END Insert_SQL_Rule;


PROCEDURE Insert_Mapping_Rules(
   p_api_version            IN  NUMBER                     ,
   p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
   x_return_status          OUT NOCOPY VARCHAR2                   ,
   x_msg_count              OUT NOCOPY NUMBER                     ,
   x_msg_data               OUT NOCOPY VARCHAR2                   ,
   p_rel_type_code          IN  VARCHAR2                   ,
   p_origin_object_type_tbl IN  JTF_Varchar2_Table_100     ,
   p_dest_object_type_tbl   IN  JTF_Varchar2_Table_100     ,
   p_origin_object_id_tbl   IN  JTF_Number_Table           ,
   p_dest_object_id_tbl     IN  JTF_Number_Table           ,
   p_preview                IN  VARCHAR2 := FND_API.G_FALSE
)
IS
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Insert_Mapping_Rules';
   L_API_VERSION CONSTANT NUMBER       := 1.0;
   i                      PLS_INTEGER;
   j                      PLS_INTEGER;
   l_rule_id              NUMBER;
   l_debug VARCHAR2(1);
   l_exists VARCHAR2(1);


BEGIN
      l_debug  := NVL(FND_PROFILE.VALUE('IBE_DEBUG'),'N');

   -- Standard Start of API savepoint
   SAVEPOINT Insert_Mapping_Rules_PVT;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('IBE_Prod_Relation_Rule_PVT.Insert_Mapping_Rules(+)');
   END IF;
   -- API body
   IF FND_API.to_Boolean( p_preview ) THEN
      IF (l_debug = 'Y') THEN
         IBE_UTIL.debug('Inserting the mapping rules from the Preview page.');
      END IF;
      FOR i IN 1..p_origin_object_type_tbl.COUNT LOOP
         BEGIN
         if (check_map_rule_exists(p_rel_type_code,p_origin_object_type_tbl(i),
                                    p_origin_object_id_tbl(i),p_dest_object_type_tbl(i),
                    p_dest_object_id_tbl(i))= FALSE ) THEN

            INSERT INTO IBE_CT_RELATION_RULES(
               relation_rule_id, object_version_number, created_by,
               creation_date, last_updated_by, last_update_date,
               relation_type_code, origin_object_type,
               dest_object_type, origin_object_id, dest_object_id
            )
            VALUES(
               ibe_ct_relation_rules_s1.nextval, 1, L_USER_ID,
               SYSDATE, L_USER_ID, SYSDATE,
               p_rel_type_code, p_origin_object_type_tbl(i),
               p_dest_object_type_tbl(i), p_origin_object_id_tbl(i), p_dest_object_id_tbl(i)
            )
            RETURNING relation_rule_id INTO l_rule_id;

            IF SQL%NOTFOUND THEN
               FND_MESSAGE.Set_Name('IBE', 'IBE_CT_REL_RULE_NOT_CREATED');
               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_ERROR;
            END IF;
           -- bug fix 3676064
           IF (p_rel_type_code <>'AUTOPLACEMENT') THEN
             IBE_Prod_Relation_PVT.Insert_Related_Items_Rows(
               p_rel_type_code      => p_rel_type_code            ,
               p_rel_rule_id        => l_rule_id                  ,
               p_origin_object_type => p_origin_object_type_tbl(i),
               p_dest_object_type   => p_dest_object_type_tbl(i)  ,
               p_origin_object_id   => p_origin_object_id_tbl(i)  ,
               p_dest_object_id     => p_dest_object_id_tbl(i)    );
           END If;
         end if;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               NULL;

         END;


      END LOOP;
   ELSE
      IF (l_debug = 'Y') THEN
         IBE_UTIL.debug('Inserting the mapping rules from the Create Rules page.');
      END IF;
      FOR i IN 1..p_origin_object_type_tbl.COUNT LOOP
         FOR j IN 1..p_dest_object_type_tbl.COUNT LOOP
            BEGIN
            /* Commented and added by amaheshw Bug 18997051 - DUPLICATE CATEGORIES APPEARED FOR A SECTION
            The p_dest_object_type_tbl and p_dest_object_id_tbl wrongly indexed with variable i. It should be j
            if (check_map_rule_exists(p_rel_type_code,p_origin_object_type_tbl(i),
                                    p_origin_object_id_tbl(i),p_dest_object_type_tbl(i),
                    p_dest_object_id_tbl(i))= FALSE ) THEN
          */
            if (check_map_rule_exists(p_rel_type_code,p_origin_object_type_tbl(i),
                                    p_origin_object_id_tbl(i),p_dest_object_type_tbl(j),
                    p_dest_object_id_tbl(j))= FALSE ) THEN

               INSERT INTO IBE_CT_RELATION_RULES(
                  relation_rule_id, object_version_number, created_by,
                  creation_date, last_updated_by, last_update_date,
                  relation_type_code, origin_object_type,
                  dest_object_type, origin_object_id, dest_object_id
               )
               VALUES(
                  ibe_ct_relation_rules_s1.nextval, 1, L_USER_ID,
                  SYSDATE, L_USER_ID, SYSDATE,
                  p_rel_type_code, p_origin_object_type_tbl(i),
                  p_dest_object_type_tbl(j), p_origin_object_id_tbl(i), p_dest_object_id_tbl(j)
               )
               RETURNING relation_rule_id INTO l_rule_id;

               IF SQL%NOTFOUND THEN
                  FND_MESSAGE.Set_Name('IBE', 'IBE_CT_REL_RULE_NOT_CREATED');
                  FND_MSG_PUB.Add;
                  RAISE FND_API.G_EXC_ERROR;
               END IF;
              -- bug fix 3676064
              IF (p_rel_type_code <>'AUTOPLACEMENT') THEN
               IBE_Prod_Relation_PVT.Insert_Related_Items_Rows(
                  p_rel_type_code      => p_rel_type_code            ,
                  p_rel_rule_id        => l_rule_id                  ,
                  p_origin_object_type => p_origin_object_type_tbl(i),
                  p_dest_object_type   => p_dest_object_type_tbl(j)  ,
                  p_origin_object_id   => p_origin_object_id_tbl(i)  ,
                  p_dest_object_id     => p_dest_object_id_tbl(j)    );
              END IF;
            end if;

            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  NULL;

            END;


         END LOOP;
      END LOOP;
   END IF;
   -- End of API body.
   IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('IBE_Prod_Relation_Rule_PVT.Insert_Mapping_Rules(-)');
   END IF;

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count    ,
                             p_data    => x_msg_data     );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Insert_Mapping_Rules_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Insert_Mapping_Rules_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );

   WHEN OTHERS THEN
      ROLLBACK TO Insert_Mapping_Rules_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                  L_API_NAME );
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );
END Insert_Mapping_Rules;


PROCEDURE Update_Rule(
   p_api_version   IN  NUMBER                     ,
   p_init_msg_list IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit        IN  VARCHAR2 := FND_API.G_FALSE,
   x_return_status OUT NOCOPY VARCHAR2                   ,
   x_msg_count     OUT NOCOPY NUMBER                     ,
   x_msg_data      OUT NOCOPY VARCHAR2                   ,
   p_rel_rule_id   IN  NUMBER                     ,
   p_obj_ver_num   IN  NUMBER                     ,
   p_sql_statement IN  VARCHAR2 := NULL
)
IS
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Update_Rule';
   L_API_VERSION CONSTANT NUMBER       := 1.0;
   l_debug VARCHAR2(1);

BEGIN
      l_debug  := NVL(FND_PROFILE.VALUE('IBE_DEBUG'),'N');

   -- Standard Start of API savepoint
   SAVEPOINT Update_Rule_PVT;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('IBE_Prod_Relation_Rule_PVT.Update_Rule(+)');
   END IF;
    -- API body
   IF p_sql_statement IS NOT NULL AND
   NOT Is_SQL_Valid( p_sql_statement ) THEN
      IF (l_debug = 'Y') THEN
         IBE_UTIL.debug('Invalid SQL statement.');
      END IF;
      FND_MESSAGE.Set_Name('IBE', 'IBE_CT_INVALID_SQL_RULE');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   UPDATE IBE_CT_RELATION_RULES
   SET object_version_number = object_version_number + 1,
       sql_statement         = p_sql_statement
   WHERE relation_rule_id      = p_rel_rule_id
     AND object_version_number = p_obj_ver_num;

   IF SQL%NOTFOUND THEN
      IF (l_debug = 'Y') THEN
         IBE_UTIL.debug('Update statement failed.');
      END IF;
      FND_MESSAGE.Set_Name('IBE', 'IBE_CT_REL_RULE_NOT_UPDATED');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   -- End of API body.
   IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('IBE_Prod_Relation_Rule_PVT.Update_Rule(-)');
   END IF;

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count    ,
                             p_data    => x_msg_data     );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Update_Rule_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Rule_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );

   WHEN OTHERS THEN
      ROLLBACK TO Update_Rule_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                  L_API_NAME );
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );
END Update_Rule;


PROCEDURE Delete_Rules(
   p_api_version     IN  NUMBER                     ,
   p_init_msg_list   IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit          IN  VARCHAR2 := FND_API.G_FALSE,
   x_return_status   OUT NOCOPY VARCHAR2                   ,
   x_msg_count       OUT NOCOPY NUMBER                     ,
   x_msg_data        OUT NOCOPY VARCHAR2                   ,
   p_rel_rule_id_tbl IN  JTF_Varchar2_Table_100     ,
   p_obj_ver_num_tbl IN  JTF_Varchar2_Table_100
)
IS
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Delete_Rule';
   L_API_VERSION CONSTANT NUMBER       := 1.0;
   l_debug VARCHAR2(1);

BEGIN
      l_debug  := NVL(FND_PROFILE.VALUE('IBE_DEBUG'),'N');

   -- Standard Start of API savepoint
   SAVEPOINT Delete_Rule_PVT;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('IBE_Prod_Relation_Rule_PVT.Delete_Rule(+)');
   END IF;
   -- API body
   IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('Deleting rows in IBE_CT_RELATION_RULES.');
   END IF;
   FORALL i IN p_rel_rule_id_tbl.FIRST..p_rel_rule_id_tbl.LAST
      DELETE
      FROM ibe_ct_relation_rules
      WHERE relation_rule_id      = p_rel_rule_id_tbl(i)
        AND object_version_number = p_obj_ver_num_tbl(i);

      IF SQL%NOTFOUND THEN
         IF (l_debug = 'Y') THEN
            IBE_UTIL.debug('Failed delete statement for IBE_CT_RELATION_RULES.');
         END IF;
         FND_MESSAGE.Set_Name('IBE', 'IBE_CT_REL_RULE_NOT_DELETED');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

   IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('Deleting rows in IBE_CT_RELATED_ITEMS.');
   END IF;
   FORALL i IN p_rel_rule_id_tbl.FIRST..p_rel_rule_id_tbl.LAST
      DELETE
      FROM ibe_ct_related_items
      WHERE relation_rule_id = p_rel_rule_id_tbl(i);

   IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('Deleting rows in IBE_CT_REL_EXCLUSIONS.');
   END IF;
   IBE_Prod_Relation_PVT.Remove_Invalid_Exclusions();
   -- End of API body.
   IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('IBE_Prod_Relation_Rule_PVT.Delete_Rule(-)');
   END IF;

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Delete_Rule_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_Rule_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );

   WHEN OTHERS THEN
      ROLLBACK TO Delete_Rule_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                  L_API_NAME );
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );
END Delete_Rules;


FUNCTION Get_Rule_Type(p_origin_object_type IN VARCHAR2,
                       p_dest_object_type   IN VARCHAR2)
RETURN VARCHAR2
IS
   l_rule_type_code VARCHAR2(2) := p_origin_object_type || p_dest_object_type;
   l_rule_type      VARCHAR2(50);
BEGIN
   SELECT meaning
   INTO l_rule_type
   FROM fnd_lookups
   WHERE lookup_type = 'IBE_REL_MAPPING_RULE_TYPES'
     AND lookup_code = l_rule_type_code;

   RETURN l_rule_type;
END Get_Rule_Type;


FUNCTION Get_Display_Name(p_object_type IN VARCHAR2,
                          p_object_id   IN NUMBER)
RETURN VARCHAR2
IS
   TYPE section_path_csr_type IS REF CURSOR;
   l_section_path_csr section_path_csr_type;
   l_section_id        NUMBER;
   l_section_disp_name VARCHAR2(120);
   l_master_msite_id   NUMBER;
   l_display_name      VARCHAR2(240);

BEGIN
   IF p_object_type = 'C' THEN
      SELECT MCV.description
      INTO l_display_name
      FROM mtl_categories_vl MCV
      WHERE MCV.category_id = p_object_id;
   ELSIF p_object_type = 'S' THEN
      -- Get the master minisite id
      SELECT JMB.msite_id
      INTO l_master_msite_id
      FROM ibe_msites_b JMB
      WHERE JMB.master_msite_flag = 'Y' AND JMB.site_type = 'I';

      -- Open a cursor that retrieves the sections path from the root section
      -- to p_object_id's immediate parent, in the reverse order
      OPEN l_section_path_csr FOR
         'SELECT JDMSS.parent_section_id ' ||
         'FROM ibe_dsp_msite_sct_sects JDMSS ' ||
         'START WITH JDMSS.child_section_id = :section_id ' ||
                'AND JDMSS.mini_site_id     = :master_mini_site_id1 ' ||
         'CONNECT BY JDMSS.child_section_id = PRIOR JDMSS.parent_section_id ' ||
                'AND JDMSS.mini_site_id     = :master_mini_site_id2 ' ||
                'AND JDMSS.parent_section_id IS NOT NULL'
      USING p_object_id, l_master_msite_id, l_master_msite_id;

      -- Loop through the cursor constructing the section path string
      LOOP
         FETCH l_section_path_csr INTO l_section_id;
         EXIT WHEN l_section_path_csr%NOTFOUND;

         IF l_section_id IS NOT NULL THEN
            SELECT JDSV.display_name
            INTO l_section_disp_name
            FROM ibe_dsp_sections_vl JDSV
            WHERE JDSV.section_id = l_section_id;

            l_display_name := l_section_disp_name || '/' || l_display_name;
         END IF;
      END LOOP;

      CLOSE l_section_path_csr;

      SELECT JDSV.display_name
      INTO l_section_disp_name
      FROM ibe_dsp_sections_vl JDSV
      WHERE JDSV.section_id = p_object_id;

      l_display_name := l_display_name || l_section_disp_name;
   ELSE
      SELECT MSIV.description
      INTO l_display_name
      FROM mtl_system_items_vl MSIV
      WHERE inventory_item_id = p_object_id
        AND organization_id   = L_ORGANIZATION_ID;
   END IF;

   RETURN l_display_name;
END Get_Display_Name;


FUNCTION Is_SQL_Valid(p_sql_stmt IN VARCHAR2)
RETURN BOOLEAN
IS
  l_cursor   NUMBER;
  l_is_valid BOOLEAN;
BEGIN
  l_cursor := DBMS_SQL.Open_Cursor;
  BEGIN
     DBMS_SQL.Parse(l_cursor, p_sql_stmt, DBMS_SQL.NATIVE);
     l_is_valid := TRUE;
  EXCEPTION
     WHEN OTHERS THEN
        l_is_valid := FALSE;
  END;

  DBMS_SQL.Close_Cursor(l_cursor);
  RETURN l_is_valid;
END Is_SQL_Valid;

END IBE_Prod_Relation_Rule_PVT;

/
