--------------------------------------------------------
--  DDL for Package Body IBE_QUOTE_REL_OBJ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_QUOTE_REL_OBJ_PVT" AS
/* $Header: IBEVQROB.pls 115.2 2002/12/21 06:44:25 ajlee ship $ */

l_true VARCHAR2(1) := FND_API.G_TRUE;

FUNCTION Get_Related_Obj_Tbl(
   p_related_object_id      IN NUMBER   := FND_API.G_MISS_NUM ,
   p_quote_object_type_code IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_quote_object_id        IN NUMBER   := FND_API.G_MISS_NUM ,
   p_object_type_code       IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_object_id              IN NUMBER   := FND_API.G_MISS_NUM ,
   p_relationship_type_code IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_one_to_one             IN VARCHAR2 := FND_API.G_FALSE    ,
   p_for_all_versions       IN VARCHAR2 := FND_API.G_FALSE
)
RETURN ASO_Quote_Pub.Related_Obj_Tbl_Type
IS
   TYPE Csr_Type IS REF CURSOR;
   l_csr            Csr_Type;
   l_related_obj_rec        ASO_Quote_Pub.Related_Obj_Rec_Type;
   l_related_obj_tbl        ASO_Quote_Pub.Related_Obj_Tbl_Type;
BEGIN
   IF  FND_API.To_Boolean(p_for_all_versions)
   AND p_quote_object_type_code = 'HEADER' THEN
      -- CREATE
      IF p_related_object_id = FND_API.G_MISS_NUM THEN
         l_related_obj_rec.quote_object_type_code := p_quote_object_type_code;
         l_related_obj_rec.object_type_code       := p_object_type_code;
         l_related_obj_rec.object_id              := p_object_id;
         l_related_obj_rec.relationship_type_code := p_relationship_type_code;

         IF FND_API.To_Boolean(p_one_to_one) THEN
            OPEN l_csr FOR SELECT AQH1.quote_header_id
                           FROM aso_quote_headers AQH1,
                                aso_quote_headers AQH2
                           WHERE AQH1.quote_number = AQH2.quote_number
                             AND AQH2.quote_header_id = p_quote_object_id
                             AND NOT EXISTS (SELECT 1
                                             FROM aso_quote_related_objects
                                             WHERE quote_object_type_code = 'HEADER'
                                               AND quote_object_id        = AQH1.quote_header_id
                                               AND relationship_type_code = p_relationship_type_code);
         ELSE
            OPEN l_csr FOR SELECT AQH1.quote_header_id
                           FROM aso_quote_headers AQH1,
                                aso_quote_headers AQH2
                           WHERE AQH1.quote_number = AQH2.quote_number
                             AND AQH2.quote_header_id = p_quote_object_id;
         END IF;
         LOOP
            FETCH l_csr INTO l_related_obj_rec.quote_object_id;
            EXIT WHEN l_csr%NOTFOUND;
            l_related_obj_tbl(l_related_obj_tbl.COUNT + 1) := l_related_obj_rec;
         END LOOP;

         CLOSE l_csr;
      ELSE
         /* For delete.
          */
         OPEN l_csr FOR SELECT related_object_id
                        FROM aso_quote_related_objects
                        WHERE relationship_type_code = (SELECT relationship_type_code
                                                        FROM aso_quote_related_objects
                                                        WHERE related_object_id = p_related_object_id)
                          AND quote_object_id IN (SELECT quote_header_id
                                                 FROM aso_quote_headers
                                                 WHERE quote_number = (SELECT quote_number
                                                                       FROM aso_quote_headers
                                                                       WHERE quote_header_id = (SELECT quote_object_id
                                                                                                FROM aso_quote_related_objects
                                                                                                WHERE related_object_id = p_related_object_id)));
         LOOP
            FETCH l_csr INTO l_related_obj_rec.related_object_id;
            EXIT WHEN l_csr%NOTFOUND;

            l_related_obj_tbl(l_related_obj_tbl.COUNT + 1) := l_related_obj_rec;
         END LOOP;

         CLOSE l_csr;
      END IF;
   ELSE
      IF p_related_object_id = FND_API.G_MISS_NUM THEN
         l_related_obj_rec.quote_object_type_code := p_quote_object_type_code;
         l_related_obj_rec.quote_object_id        := p_quote_object_id;
         l_related_obj_rec.object_type_code       := p_object_type_code;
         l_related_obj_rec.object_id              := p_object_id;
         l_related_obj_rec.relationship_type_code := p_relationship_type_code;
      ELSE
         l_related_obj_rec.related_object_id      := p_related_object_id;
      END IF;

      l_related_obj_tbl(1) := l_related_obj_rec;
   END IF;

   RETURN l_related_obj_tbl;
END Get_Related_Obj_Tbl;


PROCEDURE Create_Relationship(
   p_api_version            IN  NUMBER   := 1.0            ,
   p_init_msg_list          IN  VARCHAR2 := FND_API.G_TRUE ,
   p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
   x_return_status          OUT NOCOPY VARCHAR2                   ,
   x_msg_count              OUT NOCOPY NUMBER                     ,
   x_msg_data               OUT NOCOPY VARCHAR2                   ,
   p_quote_object_type_code IN  VARCHAR2                   ,
   p_quote_object_id        IN  NUMBER                     ,
   p_object_type_code       IN  VARCHAR2                   ,
   p_object_id              IN  NUMBER                     ,
   p_relationship_type_code IN  VARCHAR2                   ,
   p_one_to_one             IN  VARCHAR2                   ,
   p_for_all_versions       IN  VARCHAR2                   ,
   x_related_obj_id         OUT NOCOPY NUMBER
)
IS
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Create_Relationship';
   L_API_VERSION CONSTANT NUMBER       := 1.0;
   l_related_obj_rec      ASO_Quote_Pub.Related_Obj_Rec_Type;
   l_related_obj_tbl      ASO_Quote_Pub.Related_Obj_Tbl_Type;
   l_related_object_id    NUMBER;
   i                      NUMBER;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Create_Relationship_Pvt;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call(L_API_VERSION,
                                      p_api_version,
                                      L_API_NAME   ,
                                      G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_Msg_Pub.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- API body
   IF FND_API.To_Boolean(p_one_to_one) THEN
      SELECT COUNT(*)
      INTO i
      FROM aso_quote_related_objects
      WHERE quote_object_type_code = p_quote_object_type_code
        AND quote_object_id        = p_quote_object_id
        AND relationship_type_code = p_relationship_type_code;

      IF i > 0 THEN
         FND_MESSAGE.Set_Name('IBE', 'IBE_QT_DUP_QUOTE_REL');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   l_related_obj_rec.quote_object_type_code := p_quote_object_type_code;
   l_related_obj_rec.quote_object_id        := p_quote_object_id;
   l_related_obj_rec.object_type_code       := p_object_type_code;
   l_related_obj_rec.object_id              := p_object_id;
   l_related_obj_rec.relationship_type_code := p_relationship_type_code;

   l_related_obj_tbl :=
      Get_Related_Obj_Tbl(p_quote_object_type_code => p_quote_object_type_code,
                          p_quote_object_id        => p_quote_object_id       ,
                          p_object_type_code       => p_object_type_code      ,
                          p_object_id              => p_object_id             ,
                          p_relationship_type_code => p_relationship_type_code,
                          p_one_to_one             => p_one_to_one,
                          p_for_all_versions       => p_for_all_versions);

   FOR i IN 1..l_related_obj_tbl.COUNT LOOP
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('Calling ASO_Rltship_Pub.Create_Object_Relationship at'
                     || TO_CHAR(SYSDATE, 'MM/DD/YYYY:HH24:MI:SS'));
      END IF;

      ASO_Rltship_Pub.Create_Object_Relationship(
         p_api_version_number => p_api_version             ,
         p_init_msg_list      => FND_API.G_TRUE            ,
         p_commit             => FND_API.G_FALSE           ,
         p_validation_level   => FND_API.G_VALID_LEVEL_NONE,
         x_return_status      => x_return_status           ,
         x_msg_count          => x_msg_count               ,
         x_msg_data           => x_msg_data                ,
         p_related_obj_rec    => l_related_obj_tbl(i)      ,
         x_related_object_id  => l_related_object_id);

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('Returned from ASO_Rltship_Pub.Create_Object_Relationship at'
                    || TO_CHAR(SYSDATE, 'MM/DD/YYYY:HH24:MI:SS'));
      END IF;
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF l_related_obj_tbl(i).quote_object_id = p_quote_object_id THEN
         x_related_obj_id := l_related_object_id;
      END IF;
   END LOOP;
   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count    ,
                             p_data    => x_msg_data);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_Relationship_Pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Relationship_Pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
   WHEN OTHERS THEN
      ROLLBACK TO Create_Relationship_Pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_Msg_Pub.Check_Msg_Level( FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 L_API_NAME);
      END IF;

      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
END Create_Relationship;


PROCEDURE Delete_Relationship(
   p_api_version            IN  NUMBER   := 1.0            ,
   p_init_msg_list          IN  VARCHAR2 := FND_API.G_TRUE ,
   p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
   x_return_status          OUT NOCOPY VARCHAR2                   ,
   x_msg_count              OUT NOCOPY NUMBER                     ,
   x_msg_data               OUT NOCOPY VARCHAR2                   ,
   p_quote_object_type_code IN  VARCHAR2                   ,
   p_quote_object_id        IN  NUMBER                     ,
   p_object_type_code       IN  VARCHAR2                   ,
   p_object_id              IN  NUMBER                     ,
   p_relationship_type_code IN  VARCHAR2                   ,
   p_for_all_versions       IN  VARCHAR2
)
IS
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Delete_Relationship';
   L_API_VERSION CONSTANT NUMBER       := 1.0;

   l_related_obj_rec ASO_Quote_Pub.Related_Obj_Rec_Type;
   l_related_obj_tbl ASO_Quote_Pub.Related_Obj_Tbl_Type;
   l_related_object_id  NUMBER;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Delete_Relationship_Pvt;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call(L_API_VERSION,
                                      p_api_version,
                                      L_API_NAME   ,
                                      G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_Msg_Pub.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- API body
   BEGIN
      SELECT related_object_id
      INTO l_related_obj_rec.related_object_id
      FROM aso_quote_related_objects
      WHERE quote_object_type_code = p_quote_object_type_code
        AND quote_object_id        = p_quote_object_id
        AND object_type_code       = p_object_type_code
        AND object_id              = p_object_id
        AND relationship_type_code = p_relationship_type_code;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         FND_MESSAGE.Set_Name('IBE', 'IBE_QT_QUOTE_REL_NOT_FOUND');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
   END;

   l_related_obj_tbl :=
      Get_Related_Obj_Tbl(p_related_object_id      => l_related_obj_rec.related_object_id,
                          p_quote_object_type_code => p_quote_object_type_code,
                          p_for_all_versions       => p_for_all_versions);

   FOR i IN 1..l_related_obj_tbl.COUNT LOOP
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('Calling ASO_Rltship_Pub.Delete_Object_Relationship at'
                     || TO_CHAR(SYSDATE, 'MM/DD/RRRR:HH24:MI:SS'));
      END IF;

      ASO_Rltship_Pub.Delete_Object_Relationship(
         p_api_version_number => p_api_version             ,
         p_init_msg_list      => FND_API.G_TRUE            ,
         p_commit             => FND_API.G_FALSE           ,
         p_validation_level   => FND_API.G_VALID_LEVEL_NONE,
         x_return_status      => x_return_status           ,
         x_msg_count          => x_msg_count               ,
         x_msg_data           => x_msg_data                ,
         p_related_obj_rec    => l_related_obj_tbl(i));

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('Returned from ASO_Rltship_Pub.Delete_Object_Relationship at'
                     || TO_CHAR(SYSDATE, 'MM/DD/RRRR:HH24:MI:SS'));
      END IF;

   END LOOP;
   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count    ,
                             p_data    => x_msg_data);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Delete_Relationship_Pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_Relationship_Pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
   WHEN OTHERS THEN
      ROLLBACK TO Delete_Relationship_Pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_Msg_Pub.Check_Msg_Level( FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 L_API_NAME);
      END IF;

      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
END Delete_Relationship;

END IBE_Quote_Rel_Obj_Pvt;

/
